/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 27/06/2023 | Chamado 44296 - Inclus�o de Campos de Produto e Descri��o.
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 30/06/2023 | Chamado 44348 - Ajuste para acesso a altera��o na guia de impostos estaduais.
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 01/04/2024 | Chamado 46693 - Ajuste grava��o de campos.
===============================================================================================================================
*/

#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"


Static _aSF2  := {}
Static _aSD2P := {}
Static _aSD2I := {}

/*
===============================================================================================================================
Programa----------: MFIS011
Autor-------------: Igor Melga�o
Data da Criacao---: 23/12/2022
===============================================================================================================================
Descri��o---------: Acertos Fiscais Italac para Nota de Sa�da. Chamado: 43865 
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------:  
===============================================================================================================================
*/ 
User Function MFIS011(_cFiltro)
Local _oBrowse := Nil
Default _cFiltro := ""

_oBrowse := FWMBrowse():New()
_oBrowse:SetAlias("SF2")
_oBrowse:SetMenuDef( 'MFIS011' )
_oBrowse:SetOnlyFields( { 'F2_FILIAL' , 'F2_DOC' , 'F2_SERIE' , 'F2_CLIENTE', 'F2_LOJA' , 'F2_I_NCLIE' , 'F2_EMISSAO' , 'F2_DTDIGIT' } )
_oBrowse:SetDescription("Acertos Fiscais Italac (Notas de S�ida)")
If !Empty(_cFiltro)
    _oBrowse:SetFilterDefault( _cFiltro )
EndIf
_oBrowse:Activate()

Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Igor Melga�o
Data da Criacao---: 08/06/2021
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

ADD OPTION _aRotina Title 'Acertar'	                Action 'VIEWDEF.MFIS011'	OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title 'Visualizar'	            Action 'VIEWDEF.MFIS011'	OPERATION 2 ACCESS 0

//===========================================================================
//| FWMVCMenu - Gera o menu padr�o para o Modelo Informado (Inc/Alt/Vis/Exc) |
//===========================================================================
//Return( FWMVCMenu("MFIS011") )

Return( _aRotina )

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Igor Melga�o
Data da Criacao---: 08/06/2021
===============================================================================================================================
Descri��o---------: Rotina de defini��o do Modelo de Dados do MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _oModel - Objeto do modelo de dados do MVC 
===============================================================================================================================
*/ 
Static Function ModelDef()
Local _oModel
Local _oStruSF2  := FWFormStruct(1,"SF2",{ |x| ALLTRIM(x) $ 'F2_FILIAL,F2_DOC,F2_SERIE,F2_CLIENTE,F2_I_NFORN,F2_LOJA,F2_EMISSAO,F2_EMISSAO,F2_BASIMP5,F2_VALIMP5,F2_BASIMP6,F2_VALIMP6,F2_TIPO,F2_ESPECIE' } )
Local _oStruSD2I := FWFormStruct(1,"SD2",{ |x| ALLTRIM(x) $ 'D2_COD,D2_ITEM,D2_CF,D2_TES,D2_DIFAL,D2_BASEDES,D2_ICMSCOM,D2_CLASFIS' } )
Local _oStruSD2P := FWFormStruct(1,"SD2",{ |x| ALLTRIM(x) $ 'D2_COD,D2_ITEM,D2_BASIMP6,D2_ALQIMP6,D2_VALIMP6,D2_BASIMP5,D2_ALQIMP5,D2_VALIMP5' } )
Local _bPosValidacao := {||(U_MFIS011LOG())}
Local _bCommit   := {||U_MFIS011VAL()}
Local _aSD2Rel   := {}

_oStruSF2:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'F2_BASPIS' , ;             // [03] C identificador (ID) do Field
        'N' , ;                     // [04] C Tipo do campo
        14 , ;                      // [05] N Tamanho do campo
        2 , ;                       // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || SF2->F2_BASIMP6 } , ;  // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .F. )                       // [14] L Indica se o campo � virtual 

_oStruSF2:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'F2_VRPIS' , ;              // [03] C identificador (ID) do Field
        'N' , ;                     // [04] C Tipo do campo
        14 , ;                      // [05] N Tamanho do campo
        2 , ;                       // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || SF2->F2_VALIMP6 } , ;  // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .F. )                       // [14] L Indica se o campo � virtual 

_oStruSF2:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'F2_BASCOF' , ;             // [03] C identificador (ID) do Field
        'N' , ;                     // [04] C Tipo do campo
        14 , ;                      // [05] N Tamanho do campo
        2 , ;                       // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || SF2->F2_BASIMP5 } , ;  // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .F. )                       // [14] L Indica se o campo � virtual 

_oStruSF2:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'F2_VRCOF' , ;              // [03] C identificador (ID) do Field
        'N' , ;                     // [04] C Tipo do campo
        14 , ;                      // [05] N Tamanho do campo
        2 , ;                       // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || SF2->F2_VALIMP5 } , ;  // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .F. )                       // [14] L Indica se o campo � virtual 

//==================
_oStruSD2I:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'D2_CODIGO' , ;             // [03] C identificador (ID) do Field
        'C' , ;                     // [04] C Tipo do campo
        15 , ;                      // [05] N Tamanho do campo
        0 , ;                       // [06] N Decimal do campo
        {||} , ;                     // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || SD2->D2_COD } , ;  // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .F. )                       // [14] L Indica se o campo � virtual 

_oStruSD2I:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'D2_DESCRI' , ;             // [03] C identificador (ID) do Field
        'C' , ;                     // [04] C Tipo do campo
        50 , ;                      // [05] N Tamanho do campo
        0 , ;                       // [06] N Decimal do campo
        {||} , ;                     // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || POSICIONE("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC") } , ;  // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .F. )                       // [14] L Indica se o campo � virtual 

_oStruSD2I:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'D2_CLASSEF' , ;             // [03] C identificador (ID) do Field
        'C' , ;                     // [04] C Tipo do campo
        3 , ;                       // [05] N Tamanho do campo
        0 , ;                       // [06] N Decimal do campo
        {||U_MFIS011WHE('D2_CLASSEF')} , ;      // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || SD2->D2_CLASFIS } , ;  // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .F. )                       // [14] L Indica se o campo � virtual 

_oStruSD2I:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'D2_TRIBUT' , ;             // [03] C identificador (ID) do Field
        'C' , ;                     // [04] C Tipo do campo
        3 , ;                       // [05] N Tamanho do campo
        0 , ;                       // [06] N Decimal do campo
        {||U_MFIS011WHE('D2_TRIBUT')} , ;      // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || SD2->D2_TES } , ;  // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .F. )                       // [14] L Indica se o campo � virtual 

_oStruSD2I:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'D2_CODFISC' , ;             // [03] C identificador (ID) do Field
        'C' , ;                     // [04] C Tipo do campo
        5 , ;                       // [05] N Tamanho do campo
        0 , ;                       // [06] N Decimal do campo
        {||U_MFIS011WHE('D2_CODFISC')} , ;      // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || SD2->D2_CF } , ;  // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .F. )                       // [14] L Indica se o campo � virtual 

//==================
_oStruSD2P:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'D2_CODIGO' , ;             // [03] C identificador (ID) do Field
        'C' , ;                     // [04] C Tipo do campo
        15 , ;                      // [05] N Tamanho do campo
        0 , ;                       // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || SD2->D2_COD } , ;  // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .F. )                       // [14] L Indica se o campo � virtual 

_oStruSD2P:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'D2_DESCRI' , ;             // [03] C identificador (ID) do Field
        'C' , ;                     // [04] C Tipo do campo
        50 , ;                      // [05] N Tamanho do campo
        0 , ;                       // [06] N Decimal do campo
        {||} , ;                     // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || POSICIONE("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC") } , ;  // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .F. )                       // [14] L Indica se o campo � virtual 

_oStruSD2P:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'D2_BASPIS' , ;             // [03] C identificador (ID) do Field
        'N' , ;                     // [04] C Tipo do campo
        14 , ;                      // [05] N Tamanho do campo
        2 , ;                       // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || SD2->D2_BASIMP6 } , ;  // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .F. )                       // [14] L Indica se o campo � virtual 

_oStruSD2P:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'D2_PERPIS' , ;             // [03] C identificador (ID) do Field
        'N' , ;                     // [04] C Tipo do campo
        8 , ;                      // [05] N Tamanho do campo
        4 , ;                       // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || SD2->D2_ALQIMP6 } , ;  // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .F. )                       // [14] L Indica se o campo � virtual 

_oStruSD2P:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'D2_VRPIS' , ;              // [03] C identificador (ID) do Field
        'N' , ;                     // [04] C Tipo do campo
        14 , ;                      // [05] N Tamanho do campo
        2 , ;                       // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || SD2->D2_VALIMP6  } , ;  // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .F. )                       // [14] L Indica se o campo � virtual 


_oStruSD2P:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'D2_BASCOF' , ;             // [03] C identificador (ID) do Field
        'N' , ;                     // [04] C Tipo do campo
        14 , ;                      // [05] N Tamanho do campo
        2 , ;                       // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || SD2->D2_BASIMP5 } , ;  // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .T. )                       // [14] L Indica se o campo � virtual 

_oStruSD2P:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'D2_PERCOF' , ;             // [03] C identificador (ID) do Field
        'N' , ;                     // [04] C Tipo do campo
        8 , ;                       // [05] N Tamanho do campo
        4 , ;                       // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || SD2->D2_ALQIMP5 } , ;  // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .T. )                       // [14] L Indica se o campo � virtual 

_oStruSD2P:AddField( ;
        AllTrim('') , ;             // [01] C Titulo do campo
        AllTrim('') , ;             // [02] C ToolTip do campo
        'D2_VRCOF' , ;              // [03] C identificador (ID) do Field
        'N' , ;                     // [04] C Tipo do campo
        14 , ;                      // [05] N Tamanho do campo
        2 , ;                       // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de valida��o do campo
        NIL , ;                     // [08] B Code-block de valida��o When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio
        { || SD2->D2_VALIMP5 } , ;  // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update.
        .T. )                       // [14] L Indica se o campo � virtual 

_oStruSF2:SetProperty("F2_FILIAL" , MODEL_FIELD_WHEN, {|| .F.})
_oStruSF2:SetProperty("F2_DOC"    , MODEL_FIELD_WHEN, {|| .F.})
_oStruSF2:SetProperty("F2_SERIE"  , MODEL_FIELD_WHEN, {|| .F.})
_oStruSF2:SetProperty("F2_CLIENTE", MODEL_FIELD_WHEN, {|| .F.})
_oStruSF2:SetProperty("F2_LOJA"   , MODEL_FIELD_WHEN, {|| .F.})
//_oStruSF2:SetProperty("F2_I_NFORN", MODEL_FIELD_WHEN, {|| .F.})
_oStruSF2:SetProperty("F2_EMISSAO", MODEL_FIELD_WHEN, {|| .F.})
_oStruSF2:SetProperty("F2_EMISSAO", MODEL_FIELD_WHEN, {|| .F.})
_oStruSF2:SetProperty("F2_BASIMP5", MODEL_FIELD_WHEN, {|| .F.})
_oStruSF2:SetProperty("F2_VALIMP5", MODEL_FIELD_WHEN, {|| .F.})
_oStruSF2:SetProperty("F2_BASIMP6", MODEL_FIELD_WHEN, {|| .F.})
_oStruSF2:SetProperty("F2_VALIMP6", MODEL_FIELD_WHEN, {|| .F.})
_oStruSF2:SetProperty("F2_ESPECIE", MODEL_FIELD_WHEN, {|| .F.})
_oStruSF2:SetProperty("F2_TIPO"   , MODEL_FIELD_WHEN, {|| .F.})
_oStruSF2:SetProperty("F2_BASPIS" , MODEL_FIELD_WHEN, {|| .F.})
_oStruSF2:SetProperty("F2_VRPIS"  , MODEL_FIELD_WHEN, {|| .F.})
_oStruSF2:SetProperty("F2_BASCOF" , MODEL_FIELD_WHEN, {|| .F.})
_oStruSF2:SetProperty("F2_VRCOF"  , MODEL_FIELD_WHEN, {|| .F.})

_oStruSD2I:SetProperty("D2_CF"       , MODEL_FIELD_WHEN, {|| U_MFIS009ALT("EST") })
_oStruSD2I:SetProperty("D2_TES"      , MODEL_FIELD_WHEN, {|| U_MFIS009ALT("EST") })
_oStruSD2I:SetProperty("D2_DIFAL"    , MODEL_FIELD_WHEN, {|| U_MFIS009ALT("EST") })
_oStruSD2I:SetProperty("D2_BASEDES"  , MODEL_FIELD_WHEN, {|| U_MFIS009ALT("EST") })
_oStruSD2I:SetProperty("D2_ICMSCOM"  , MODEL_FIELD_WHEN, {|| U_MFIS009ALT("EST") })

_oStruSD2I:SetProperty("D2_CLASSEF"  , MODEL_FIELD_WHEN, {|| U_MFIS009ALT("EST") })
_oStruSD2I:SetProperty("D2_TRIBUT"   , MODEL_FIELD_WHEN, {|| U_MFIS009ALT("EST") })
_oStruSD2I:SetProperty("D2_CODFISC"  , MODEL_FIELD_WHEN, {|| U_MFIS009ALT("EST") })

//_oStruSD2I:SetProperty("D2_ALQIMP5"  , MODEL_FIELD_INIT, {|| SD2->D2_ALQIMP5 })
//_oStruSD2I:SetProperty("D2_ALQIMP6"  , MODEL_FIELD_INIT, {|| SD2->D2_ALQIMP6 })

_aGatAux := FwStruTrigger( 'D2_BASCOF'	, 'D2_VRCOF'	, 'U_MFIS011IMP("COF")' , .F. )
_oStruSD2P:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'D2_PERCOF'	, 'D2_VRCOF'	, 'U_MFIS011IMP("COF")' , .F. )
_oStruSD2P:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'D2_BASPIS'	, 'D2_VRPIS'	, 'U_MFIS011IMP("PIS")' , .F. )
_oStruSD2P:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_aGatAux := FwStruTrigger( 'D2_PERPIS'	, 'D2_VRPIS'	, 'U_MFIS011IMP("PIS")' , .F. )
_oStruSD2P:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

//_aGatAux := FwStruTrigger( 'D2_CLASSEF'	, 'D2_CLASFIS'	, 'M->D2_CLASSEF' , .F. )
//_oStruSD2I:AddTrigger( _aGatAux[01] , _aGatAux[02] , _aGatAux[03] , _aGatAux[04] )

_oModel := MPFormModel():New('MFIS011M' ,  /*bPreValidacao*/ , _bPosValidacao , _bCommit /*bCommit*/ , /*bCancel*/)

_oModel:AddFields('SF2CAB', /*cOwner*/ ,_oStruSF2,/*bPreValidacao*/ , /*bPosValidacao*/ , /*bCarga*/)
_oModel:AddGrid('SD2DETAILI','SF2CAB'   ,_oStruSD2I,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/)
_oModel:AddGrid('SD2DETAILP','SF2CAB'   ,_oStruSD2P,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/)

aAdd(_aSD2Rel, {'D2_FILIAL' , 'SF2CAB.F2_FILIAL' } )
aAdd(_aSD2Rel, {'D2_SERIE'  , 'SF2CAB.F2_SERIE'  } )
aAdd(_aSD2Rel, {'D2_DOC'    , 'SF2CAB.F2_DOC'    } )
aAdd(_aSD2Rel, {'D2_CLIENTE', 'SF2CAB.F2_CLIENTE'} )
aAdd(_aSD2Rel, {'D2_LOJA'   , 'SF2CAB.F2_LOJA'   } )

_oModel:SetRelation('SD2DETAILI', _aSD2Rel, SD2->(IndexKey(1)))
_oModel:SetRelation('SD2DETAILP', _aSD2Rel, SD2->(IndexKey(1)))

_oModel:SetPrimaryKey( {"F2_FILIAL","F2_DOC","F2_SERIE","F2_CLIENTE","F2_LOJA" } )
_oModel:SetDescription("Acertos Fiscais Italac (Nota de S�ida)")

_oModel:GetModel( 'SD2DETAILI' ):SetNoInsertLine( .T. )
_oModel:GetModel( 'SD2DETAILI' ):SetNoDeleteLine( .T. )

_oModel:GetModel( 'SD2DETAILP' ):SetNoInsertLine( .T. )
_oModel:GetModel( 'SD2DETAILP' ):SetNoDeleteLine( .T. )

_oModel:SetVldActivate( { |_oModel| U_MFIS011FIS(_oModel) } )

Return _oModel

/*
===============================================================================================================================
Programa----------: ViewDef
Autor-------------: Igor Melga�o
Data da Criacao---: 08/06/2021
===============================================================================================================================
Descri��o---------: Rotina de defini��o da View do MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _oView - Objeto de exibi��o do MVC  
===============================================================================================================================
*/ 
Static Function ViewDef()
Local _oStruSF2  := FWFormStruct(2,"SF2",{ |x| ALLTRIM(x) $ 'F2_FILIAL,F2_DOC,F2_SERIE,F2_CLIENTE,F2_I_NFORN,F2_LOJA,F2_EMISSAO,F2_EMISSAO,F2_BASIMP5,F2_VALIMP5,F2_BASIMP6,F2_VALIMP6,F2_TIPO,F2_ESPECIE' } )
Local _oStruSD2I := FWFormStruct(2,"SD2",{ |x| ALLTRIM(x) $ 'D2_COD,D2_ITEM,D2_CF,D2_TES,D2_DIFAL,D2_BASEDES,D2_ICMSCOM,D2_CLASFIS' } )
Local _oStruSD2P := FWFormStruct(2,"SD2",{ |x| ALLTRIM(x) $ 'D2_COD,D2_ITEM,D2_BASIMP6,D2_ALQIMP6,D2_VALIMP6,D2_BASIMP5,D2_ALQIMP5,D2_VALIMP5' } )
Local _oModel    := FWLoadModel("MFIS011")
Local _oView     := Nil

_oStruSF2:AddField( ;                       // Ord. Tipo Desc.
    'F2_BASPIS'                     , ;     // [01] C   Nome do Campo
    "90"                            , ;     // [02] C   Ordem
    AllTrim( 'Base PIS'    )        , ;     // [03] C   Titulo do campo
    AllTrim( '' )                   , ;     // [04] C   Descricao do campo
    { 'Legenda' }                   , ;     // [05] A   Array com Help
    'N'                             , ;     // [06] C   Tipo do campo
    '@E 99,999,999,999.99'          , ;     // [07] C   Picture
    NIL                             , ;     // [08] B   Bloco de Picture Var
    ''                              , ;     // [09] C   Consulta F3
    U_MFIS009ALT("FED")             , ;     // [10] L   Indica se o campo � alteravel
    NIL                             , ;     // [11] C   Pasta do campo
    NIL                             , ;     // [12] C   Agrupamento do campo
    NIL                             , ;     // [13] A   Lista de valores permitido do campo (Combo)
    NIL                             , ;     // [14] N   Tamanho maximo da maior op��o do combo
    NIL                             , ;     // [15] C   Inicializador de Browse
    .T.                             , ;     // [16] L   Indica se o campo � virtual
    NIL                             , ;     // [17] C   Picture Variavel
    NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 

_oStruSF2:AddField( ;                      // Ord. Tipo Desc.
    'F2_VRPIS'                      , ;     // [01] C   Nome do Campo
    "91"                            , ;     // [02] C   Ordem
    AllTrim( 'Valor PIS'    )       , ;     // [03] C   Titulo do campo
    AllTrim( '' )                   , ;     // [04] C   Descricao do campo
    { 'Legenda' }                   , ;     // [05] A   Array com Help
    'N'                             , ;     // [06] C   Tipo do campo
    '@E 99,999,999,999.99'          , ;     // [07] C   Picture
    NIL                             , ;     // [08] B   Bloco de Picture Var
    ''                              , ;     // [09] C   Consulta F3
    U_MFIS009ALT("FED")             , ;     // [10] L   Indica se o campo � alteravel
    NIL                             , ;     // [11] C   Pasta do campo
    NIL                             , ;     // [12] C   Agrupamento do campo
    NIL                             , ;     // [13] A   Lista de valores permitido do campo (Combo)
    NIL                             , ;     // [14] N   Tamanho maximo da maior op��o do combo
    NIL                             , ;     // [15] C   Inicializador de Browse
    .T.                             , ;     // [16] L   Indica se o campo � virtual
    NIL                             , ;     // [17] C   Picture Variavel
    NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 

_oStruSF2:AddField( ;                       // Ord. Tipo Desc.
    'F2_BASCOF'                     , ;     // [01] C   Nome do Campo
    "92"                            , ;     // [02] C   Ordem
    AllTrim( 'Base COFINS'    )     , ;     // [03] C   Titulo do campo
    AllTrim( '' )                   , ;     // [04] C   Descricao do campo
    { 'Legenda' }                   , ;     // [05] A   Array com Help
    'N'                             , ;     // [06] C   Tipo do campo
    '@E 99,999,999,999.99'          , ;     // [07] C   Picture
    NIL                             , ;     // [08] B   Bloco de Picture Var
    ''                              , ;     // [09] C   Consulta F3
    U_MFIS009ALT("FED")             , ;     // [10] L   Indica se o campo � alteravel
    NIL                             , ;     // [11] C   Pasta do campo
    NIL                             , ;     // [12] C   Agrupamento do campo
    NIL                             , ;     // [13] A   Lista de valores permitido do campo (Combo)
    NIL                             , ;     // [14] N   Tamanho maximo da maior op��o do combo
    NIL                             , ;     // [15] C   Inicializador de Browse
    .T.                             , ;     // [16] L   Indica se o campo � virtual
    NIL                             , ;     // [17] C   Picture Variavel
    NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 

_oStruSF2:AddField( ;                      // Ord. Tipo Desc.
    'F2_VRCOF'                      , ;     // [01] C   Nome do Campo
    "93"                            , ;     // [02] C   Ordem
    AllTrim( 'Valor COFINS'    )    , ;     // [03] C   Titulo do campo
    AllTrim( '' )                   , ;     // [04] C   Descricao do campo
    { 'Legenda' }                   , ;     // [05] A   Array com Help
    'N'                             , ;     // [06] C   Tipo do campo
    '@E 99,999,999,999.99'          , ;     // [07] C   Picture
    NIL                             , ;     // [08] B   Bloco de Picture Var
    ''                              , ;     // [09] C   Consulta F3
    U_MFIS009ALT("FED")             , ;     // [10] L   Indica se o campo � alteravel
    NIL                             , ;     // [11] C   Pasta do campo
    NIL                             , ;     // [12] C   Agrupamento do campo
    NIL                             , ;     // [13] A   Lista de valores permitido do campo (Combo)
    NIL                             , ;     // [14] N   Tamanho maximo da maior op��o do combo
    NIL                             , ;     // [15] C   Inicializador de Browse
    .T.                             , ;     // [16] L   Indica se o campo � virtual
    NIL                             , ;     // [17] C   Picture Variavel
    NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 

//==============================

_oStruSD2I:AddField( ;                       // Ord. Tipo Desc.
    'D2_CODIGO'                     , ;     // [01] C   Nome do Campo
    "01"                            , ;     // [02] C   Ordem
    AllTrim( 'Produto'    )         , ;     // [03] C   Titulo do campo
    AllTrim( '' )                   , ;     // [04] C   Descricao do campo
    { 'Legenda' }                   , ;     // [05] A   Array com Help
    'C'                             , ;     // [06] C   Tipo do campo
    '@!'                            , ;     // [07] C   Picture
    NIL                             , ;     // [08] B   Bloco de Picture Var
    ''                              , ;     // [09] C   Consulta F3
    .F.                             , ;     // [10] L   Indica se o campo � alteravel
    NIL                             , ;     // [11] C   Pasta do campo
    NIL                             , ;     // [12] C   Agrupamento do campo
    NIL                             , ;     // [13] A   Lista de valores permitido do campo (Combo)
    NIL                             , ;     // [14] N   Tamanho maximo da maior op��o do combo
    NIL                             , ;     // [15] C   Inicializador de Browse
    .T.                             , ;     // [16] L   Indica se o campo � virtual
    NIL                             , ;     // [17] C   Picture Variavel
    NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 

_oStruSD2I:AddField( ;                       // Ord. Tipo Desc.
    'D2_DESCRI'                     , ;     // [01] C   Nome do Campo
    "02"                            , ;     // [02] C   Ordem
    AllTrim( 'Descricao'  )         , ;     // [03] C   Titulo do campo
    AllTrim( '' )                   , ;     // [04] C   Descricao do campo
    { 'Legenda' }                   , ;     // [05] A   Array com Help
    'C'                             , ;     // [06] C   Tipo do campo
    '@!'                            , ;     // [07] C   Picture
    NIL                             , ;     // [08] B   Bloco de Picture Var
    ''                              , ;     // [09] C   Consulta F3
    .F.                             , ;     // [10] L   Indica se o campo � alteravel
    NIL                             , ;     // [11] C   Pasta do campo
    NIL                             , ;     // [12] C   Agrupamento do campo
    NIL                             , ;     // [13] A   Lista de valores permitido do campo (Combo)
    NIL                             , ;     // [14] N   Tamanho maximo da maior op��o do combo
    NIL                             , ;     // [15] C   Inicializador de Browse
    .T.                             , ;     // [16] L   Indica se o campo � virtual
    NIL                             , ;     // [17] C   Picture Variavel
    NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 

_oStruSD2I:AddField( ;                       // Ord. Tipo Desc.
    'D2_CLASSEF'                    , ;     // [01] C   Nome do Campo
    "06"                            , ;     // [02] C   Ordem
    AllTrim( 'Sit.Tribut.'    )     , ;     // [03] C   Titulo do campo
    AllTrim( '' )                   , ;     // [04] C   Descricao do campo
    { 'Legenda' }                   , ;     // [05] A   Array com Help
    'N'                             , ;     // [06] C   Tipo do campo
    '@!'                            , ;     // [07] C   Picture
    NIL                             , ;     // [08] B   Bloco de Picture Var
    ''                              , ;     // [09] C   Consulta F3
    U_MFIS009ALT("EST")             , ;     // [10] L   Indica se o campo � alteravel
    NIL                             , ;     // [11] C   Pasta do campo
    NIL                             , ;     // [12] C   Agrupamento do campo
    NIL                             , ;     // [13] A   Lista de valores permitido do campo (Combo)
    NIL                             , ;     // [14] N   Tamanho maximo da maior op��o do combo
    NIL                             , ;     // [15] C   Inicializador de Browse
    .T.                             , ;     // [16] L   Indica se o campo � virtual
    NIL                             , ;     // [17] C   Picture Variavel
    NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 

_oStruSD2I:AddField( ;                       // Ord. Tipo Desc.
    'D2_TRIBUT'                     , ;     // [01] C   Nome do Campo
    "07"                            , ;     // [02] C   Ordem
    AllTrim( 'Tipo Saida'    )      , ;     // [03] C   Titulo do campo
    AllTrim( '' )                   , ;     // [04] C   Descricao do campo
    { 'Legenda' }                   , ;     // [05] A   Array com Help
    'N'                             , ;     // [06] C   Tipo do campo
    '@!'                            , ;     // [07] C   Picture
    NIL                             , ;     // [08] B   Bloco de Picture Var
    'SF4'                           , ;     // [09] C   Consulta F3
    U_MFIS009ALT("EST")             , ;     // [10] L   Indica se o campo � alteravel
    NIL                             , ;     // [11] C   Pasta do campo
    NIL                             , ;     // [12] C   Agrupamento do campo
    NIL                             , ;     // [13] A   Lista de valores permitido do campo (Combo)
    NIL                             , ;     // [14] N   Tamanho maximo da maior op��o do combo
    NIL                             , ;     // [15] C   Inicializador de Browse
    .T.                             , ;     // [16] L   Indica se o campo � virtual
    NIL                             , ;     // [17] C   Picture Variavel
    NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 

_oStruSD2I:AddField( ;                       // Ord. Tipo Desc.
    'D2_CODFISC'                     , ;     // [01] C   Nome do Campo
    "08"                            , ;     // [02] C   Ordem
    AllTrim( 'Cod Fiscal'    )      , ;     // [03] C   Titulo do campo
    AllTrim( '' )                   , ;     // [04] C   Descricao do campo
    { 'Legenda' }                   , ;     // [05] A   Array com Help
    'C'                             , ;     // [06] C   Tipo do campo
    '@9'                            , ;     // [07] C   Picture
    NIL                             , ;     // [08] B   Bloco de Picture Var
    '13'                            , ;     // [09] C   Consulta F3
    U_MFIS009ALT("EST")             , ;     // [10] L   Indica se o campo � alteravel
    NIL                             , ;     // [11] C   Pasta do campo
    NIL                             , ;     // [12] C   Agrupamento do campo
    NIL                             , ;     // [13] A   Lista de valores permitido do campo (Combo)
    NIL                             , ;     // [14] N   Tamanho maximo da maior op��o do combo
    NIL                             , ;     // [15] C   Inicializador de Browse
    .T.                             , ;     // [16] L   Indica se o campo � virtual
    NIL                             , ;     // [17] C   Picture Variavel
    NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 


_oStruSD2P:AddField( ;                       // Ord. Tipo Desc.
    'D2_CODIGO'                     , ;     // [01] C   Nome do Campo
    "01"                            , ;     // [02] C   Ordem
    AllTrim( 'Produto'    )         , ;     // [03] C   Titulo do campo
    AllTrim( '' )                   , ;     // [04] C   Descricao do campo
    { 'Legenda' }                   , ;     // [05] A   Array com Help
    'C'                             , ;     // [06] C   Tipo do campo
    '@!'                            , ;     // [07] C   Picture
    NIL                             , ;     // [08] B   Bloco de Picture Var
    ''                              , ;     // [09] C   Consulta F3
    .F.                             , ;     // [10] L   Indica se o campo � alteravel
    NIL                             , ;     // [11] C   Pasta do campo
    NIL                             , ;     // [12] C   Agrupamento do campo
    NIL                             , ;     // [13] A   Lista de valores permitido do campo (Combo)
    NIL                             , ;     // [14] N   Tamanho maximo da maior op��o do combo
    NIL                             , ;     // [15] C   Inicializador de Browse
    .T.                             , ;     // [16] L   Indica se o campo � virtual
    NIL                             , ;     // [17] C   Picture Variavel
    NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 

_oStruSD2P:AddField( ;                       // Ord. Tipo Desc.
    'D2_DESCRI'                     , ;     // [01] C   Nome do Campo
    "02"                            , ;     // [02] C   Ordem
    AllTrim( 'Descricao'    )       , ;     // [03] C   Titulo do campo
    AllTrim( '' )                   , ;     // [04] C   Descricao do campo
    { 'Legenda' }                   , ;     // [05] A   Array com Help
    'C'                             , ;     // [06] C   Tipo do campo
    '@!'                            , ;     // [07] C   Picture
    NIL                             , ;     // [08] B   Bloco de Picture Var
    ''                              , ;     // [09] C   Consulta F3
    .F.                             , ;     // [10] L   Indica se o campo � alteravel
    NIL                             , ;     // [11] C   Pasta do campo
    NIL                             , ;     // [12] C   Agrupamento do campo
    NIL                             , ;     // [13] A   Lista de valores permitido do campo (Combo)
    NIL                             , ;     // [14] N   Tamanho maximo da maior op��o do combo
    NIL                             , ;     // [15] C   Inicializador de Browse
    .T.                             , ;     // [16] L   Indica se o campo � virtual
    NIL                             , ;     // [17] C   Picture Variavel
    NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 

_oStruSD2P:AddField( ;                       // Ord. Tipo Desc.
    'D2_BASPIS'                     , ;     // [01] C   Nome do Campo
    "06"                            , ;     // [02] C   Ordem
    AllTrim( 'Base PIS'    )        , ;     // [03] C   Titulo do campo
    AllTrim( '' )                   , ;     // [04] C   Descricao do campo
    { 'Legenda' }                   , ;     // [05] A   Array com Help
    'N'                             , ;     // [06] C   Tipo do campo
    '@E 99,999,999,999.99'          , ;     // [07] C   Picture
    NIL                             , ;     // [08] B   Bloco de Picture Var
    ''                              , ;     // [09] C   Consulta F3
    U_MFIS009ALT("FED")             , ;     // [10] L   Indica se o campo � alteravel
    NIL                             , ;     // [11] C   Pasta do campo
    NIL                             , ;     // [12] C   Agrupamento do campo
    NIL                             , ;     // [13] A   Lista de valores permitido do campo (Combo)
    NIL                             , ;     // [14] N   Tamanho maximo da maior op��o do combo
    NIL                             , ;     // [15] C   Inicializador de Browse
    .T.                             , ;     // [16] L   Indica se o campo � virtual
    NIL                             , ;     // [17] C   Picture Variavel
    NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 

_oStruSD2P:AddField( ;                      // Ord. Tipo Desc.
    'D2_PERPIS'                     , ;     // [01] C   Nome do Campo
    "07"                            , ;     // [02] C   Ordem
    AllTrim( '% PIS'    )        , ;     // [03] C   Titulo do campo
    AllTrim( '' )                   , ;     // [04] C   Descricao do campo
    { 'Legenda' }                   , ;     // [05] A   Array com Help
    'N'                             , ;     // [06] C   Tipo do campo
    '@E 999.9999'                   , ;     // [07] C   Picture
    NIL                             , ;     // [08] B   Bloco de Picture Var
    ''                              , ;     // [09] C   Consulta F3
    U_MFIS009ALT("FED")             , ;     // [10] L   Indica se o campo � alteravel
    NIL                             , ;     // [11] C   Pasta do campo
    NIL                             , ;     // [12] C   Agrupamento do campo
    NIL                             , ;     // [13] A   Lista de valores permitido do campo (Combo)
    NIL                             , ;     // [14] N   Tamanho maximo da maior op��o do combo
    NIL                             , ;     // [15] C   Inicializador de Browse
    .T.                             , ;     // [16] L   Indica se o campo � virtual
    NIL                             , ;     // [17] C   Picture Variavel
    NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 

_oStruSD2P:AddField( ;                      // Ord. Tipo Desc.
    'D2_VRPIS'                      , ;     // [01] C   Nome do Campo
    "08"                            , ;     // [02] C   Ordem
    AllTrim( 'Valor PIS'    )       , ;     // [03] C   Titulo do campo
    AllTrim( '' )                   , ;     // [04] C   Descricao do campo
    { 'Legenda' }                   , ;     // [05] A   Array com Help
    'N'                             , ;     // [06] C   Tipo do campo
    '@E 99,999,999,999.99'          , ;     // [07] C   Picture
    NIL                             , ;     // [08] B   Bloco de Picture Var
    ''                              , ;     // [09] C   Consulta F3
    U_MFIS009ALT("FED")             , ;     // [10] L   Indica se o campo � alteravel
    NIL                             , ;     // [11] C   Pasta do campo
    NIL                             , ;     // [12] C   Agrupamento do campo
    NIL                             , ;     // [13] A   Lista de valores permitido do campo (Combo)
    NIL                             , ;     // [14] N   Tamanho maximo da maior op��o do combo
    NIL                             , ;     // [15] C   Inicializador de Browse
    .T.                             , ;     // [16] L   Indica se o campo � virtual
    NIL                             , ;     // [17] C   Picture Variavel
    NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 

_oStruSD2P:AddField(                  ;     // Ord. Tipo Desc.
    'D2_BASCOF'                     , ;     // [01] C   Nome do Campo
    "09"                            , ;     // [02] C   Ordem
    AllTrim( 'Base COFINS'    )     , ;     // [03] C   Titulo do campo
    AllTrim( '' )                   , ;     // [04] C   Descricao do campo
    { 'Legenda' }                   , ;     // [05] A   Array com Help
    'N'                             , ;     // [06] C   Tipo do campo
    '@E 99,999,999,999.99'          , ;     // [07] C   Picture
    NIL                             , ;     // [08] B   Bloco de Picture Var
    ''                              , ;     // [09] C   Consulta F3
    U_MFIS009ALT("FED")             , ;     // [10] L   Indica se o campo � alteravel
    NIL                             , ;     // [11] C   Pasta do campo
    NIL                             , ;     // [12] C   Agrupamento do campo
    NIL                             , ;     // [13] A   Lista de valores permitido do campo (Combo)
    NIL                             , ;     // [14] N   Tamanho maximo da maior op��o do combo
    NIL                             , ;     // [15] C   Inicializador de Browse
    .T.                             , ;     // [16] L   Indica se o campo � virtual
    NIL                             , ;     // [17] C   Picture Variavel
    NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 

_oStruSD2P:AddField( ;                      // Ord. Tipo Desc.
    'D2_PERCOF'                     , ;     // [01] C   Nome do Campo
    "10"                            , ;     // [02] C   Ordem
    AllTrim( '% COFINS'    )        , ;     // [03] C   Titulo do campo
    AllTrim( '' )                   , ;     // [04] C   Descricao do campo
    { 'Legenda' }                   , ;     // [05] A   Array com Help
    'N'                             , ;     // [06] C   Tipo do campo
    '@E 999.9999'                   , ;     // [07] C   Picture
    NIL                             , ;     // [08] B   Bloco de Picture Var
    ''                              , ;     // [09] C   Consulta F3
    U_MFIS009ALT("FED")             , ;     // [10] L   Indica se o campo � alteravel
    NIL                             , ;     // [11] C   Pasta do campo
    NIL                             , ;     // [12] C   Agrupamento do campo
    NIL                             , ;     // [13] A   Lista de valores permitido do campo (Combo)
    NIL                             , ;     // [14] N   Tamanho maximo da maior op��o do combo
    NIL                             , ;     // [15] C   Inicializador de Browse
    .T.                             , ;     // [16] L   Indica se o campo � virtual
    NIL                             , ;     // [17] C   Picture Variavel
    NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 

_oStruSD2P:AddField( ;                      // Ord. Tipo Desc.
        'D2_VRCOF'                      , ;     // [01] C   Nome do Campo
        "11"                            , ;     // [02] C   Ordem
        AllTrim( 'Valor COFINS'    )    , ;     // [03] C   Titulo do campo
        AllTrim( '' )                   , ;     // [04] C   Descricao do campo
        { 'Legenda' }                   , ;     // [05] A   Array com Help
        'N'                             , ;     // [06] C   Tipo do campo
        '@E 99,999,999,999.99'          , ;     // [07] C   Picture
        NIL                             , ;     // [08] B   Bloco de Picture Var
        ''                              , ;     // [09] C   Consulta F3
        U_MFIS009ALT("FED")             , ;     // [10] L   Indica se o campo � alteravel
        NIL                             , ;     // [11] C   Pasta do campo
        NIL                             , ;     // [12] C   Agrupamento do campo
        NIL                             , ;     // [13] A   Lista de valores permitido do campo (Combo)
        NIL                             , ;     // [14] N   Tamanho maximo da maior op��o do combo
        NIL                             , ;     // [15] C   Inicializador de Browse
        .T.                             , ;     // [16] L   Indica se o campo � virtual
        NIL                             , ;     // [17] C   Picture Variavel
        NIL                             )       // [18] L   Indica pulo de linha ap�s o campo 
 
_oStruSD2I:RemoveField('D2_CLASFIS')
_oStruSD2I:RemoveField('D2_TES')
_oStruSD2I:RemoveField('D2_CF')
_oStruSD2I:RemoveField('D2_COD')
_oStruSD2P:RemoveField('D2_COD')

_oView := FWFormView():New()
_oView:SetModel(_oModel)

_oView:AddField("VIEW_SF2",_oStruSF2,"SF2CAB"   ,,)
_oView:AddGrid('VIEW_SD2I' ,_oStruSD2I,'SD2DETAILI',,)
_oView:AddGrid('VIEW_SD2P' ,_oStruSD2P,'SD2DETAILP',,)

//Setando o dimensionamento de tamanho
_oView:CreateHorizontalBox('CABEC',50)
_oView:CreateHorizontalBox('DETAIL',50)

_oView:CreateFolder('FOLDER1','DETAIL')

_oView:AddSheet('FOLDER1','SHEET1','Infoma��es Estaduais')
_oView:AddSheet('FOLDER1','SHEET2','Informa��es Federais')

_oView:CreateHorizontalBox('SHEET1_BOX',100,,,'FOLDER1','SHEET1')
_oView:CreateHorizontalBox('SHEET2_BOX',100,,,'FOLDER1','SHEET2')

//Amarrando a view com as box
_oView:SetOwnerView('VIEW_SF2','CABEC')
_oView:SetOwnerView('VIEW_SD2I','SHEET1_BOX')
_oView:SetOwnerView('VIEW_SD2P','SHEET2_BOX')

//Habilitando t�tulo
_oView:EnableTitleView('VIEW_SF2',"Cabe�alho da Nota")
_oView:EnableTitleView('VIEW_SD2I',"Itens da Nota")
_oView:EnableTitleView('VIEW_SD2P',"Itens da Nota")

_oView:AddUserButton( 'Log de Altera��es do Corpo da Nota', 'CLIPS', {|_oView| U_MFIS011CON("CAB")} )
_oView:AddUserButton( 'Log de Altera��es do Item da Nota', 'CLIPS', {|_oView| U_MFIS011CON("ITEM")} )

//Tratativa padr�o para fechar a tela
_oView:SetCloseOnOk({||.T.})

Return _oView


/*
===============================================================================================================================
Programa----------: MFIS011VAL
Autor-------------: Igor Melga�o
Data da Criacao---: 08/06/2021
===============================================================================================================================
Descri��o---------: Rotina de Valida��o
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _lReturn
===============================================================================================================================
*/ 
User Function MFIS011VAL()


Local _cOpcLog := 'A'
Local _oModel  := FWModelActive()
Local _cChave  := _oModel:GetValue( 'SF2CAB','F2_FILIAL')+_oModel:GetValue( 'SF2CAB','F2_DOC')+_oModel:GetValue( 'SF2CAB','F2_SERIE')+_oModel:GetValue( 'SF2CAB','F2_CLIENTE')+_oModel:GetValue( 'SF2CAB','F2_LOJA')
Local _cCodUsr := RetCodUsr()
Local _dDatLog := Date()
Local _cHorLog := Time()
Local i := 0
Local lRet := .T.

Local cData  := Dtoc(SF2->F2_EMISSAO)
Local cDoc   := SF2->F2_DOC
Local cSerie := SF2->F2_SERIE
Local cCli   := SF2->F2_CLIENTE
Local cLoja  := SF2->F2_LOJA


Local lRotAut  := .T.
Local aParam   := array(11)
Local lExec := .F.

//_oModel:CommitData()
lRet := FWFormCommit( _oModel )

If lRet
    Begin Sequence

    //=============================================================================
    // Ativa a filial "01" apenas para leitura das filiais do par�metro.
    //=============================================================================
    // RESET ENVIRONMENT
    // RpcSetType(3)

    //=============================================================================
    // Inicia processamento com base nas filiais do par�metro.
    //=============================================================================
    u_itconout( 'Abrindo o ambiente para filial 01...' )

    //===========================================================================================
    // Preparando o ambiente com a filial 01
    //===========================================================================================
    // PREPARE ENVIRONMENT EMPRESA "01" FILIAL cFilAnt MODULO "FIS" 
            
        aParam[1] := cData //Data Inicial
        aParam[2] := cData //Data Final
        aParam[3] := 2      // 1-S�ida 2-Sa�da 3-Ambos
        aParam[4] := cDoc   // Nota Fiscal Incial
        aParam[5] := cDoc   // Nota Fiscal Final
        aParam[6] := cSerie // S�rie Incial
        aParam[7] := cSerie // S�rie Final
        aParam[8] := cCli   // Cli/For Inicial
        aParam[9] := cCli   // Cli/For Final
        aParam[10] := cLoja // Loja Incial
        aParam[11] := cLoja // Loja Final

        //lExec := MATA930(lRotAut,aParam)
        FWMSGRUN(,{||  lExec := MATA930(lRotAut,aParam) },'Aguarde processamento...','Reprocessando Livro Fiscal...')

        //RESET ENVIRONMENT

    End Sequence

    DBSelectArea("SF2")
    DBSelectArea("SD2")

    U_ITGrvLog( _aSF2 , "SF2" , 1 , _cChave , _cOpcLog , _cCodUsr , _dDatLog , _cHorLog )
    
    For i := 1 To Len(_aSD2P)
        U_ITGrvLog( _aSD2P[i,2]  , "SD2" , 1 , _aSD2P[i,1] , _cOpcLog , _cCodUsr , _dDatLog , _cHorLog )
    Next

    For i := 1 To Len(_aSD2I)
        U_ITGrvLog( _aSD2I[i,2]  , "SD2" , 1 , _aSD2I[i,1] , _cOpcLog , _cCodUsr , _dDatLog , _cHorLog )
    Next
Endif

Return lRet



/*
===============================================================================================================================
Programa----------: MFIS011IMP
Autor-------------: Igor Melga�o
Data da Criacao---: 19/05/2023
===============================================================================================================================
Descri��o---------: Gatilho que calcula o Valor de Pis e Cofins
===============================================================================================================================
Parametros--------: cCampo: Pis ou Cofins
===============================================================================================================================
Retorno-----------: Vr do Imposto
===============================================================================================================================
*/
User Function MFIS011IMP(cCampo)
Local _oModel   := FWModelActive()
Local _oModelDET := _oModel:GetModel('SD2DETAILP')
Local _nBase    := 0
Local _nPerc    := 0
Local _nTotBase := 0
Local _nTotVr   := 0
Local i := 0
local _nImp := 0
Local _nLinPos := 0 

_nBase	:= _oModel:GetValue( 'SD2DETAILP' , Iif(cCampo == "PIS",'D2_BASPIS', 'D2_BASCOF') )
_nPerc	:= _oModel:GetValue( 'SD2DETAILP' , Iif(cCampo == "PIS",'D2_PERPIS', 'D2_PERCOF') )
_nImp   := _nPerc / 100 * _nBase

_oModel:LoadValue( 'SD2DETAILP',Iif(cCampo == "PIS",'D2_BASIMP6', 'D2_BASIMP5') ,_nBase)
_oModel:LoadValue( 'SD2DETAILP',Iif(cCampo == "PIS",'D2_ALQIMP6', 'D2_ALQIMP5') ,_nPerc)
_oModel:LoadValue( 'SD2DETAILP',Iif(cCampo == "PIS",'D2_VALIMP6', 'D2_VALIMP5') ,_nImp)

_nQtdLin	:= _oModelDET:Length()
_nLinPos    := _oModelDET:GetLine() 

For i := 1 to _nQtdLin
    _oModelDET:GoLine( i )
    _nTotBase += _oModel:GetValue( 'SD2DETAILP' , Iif(cCampo == "PIS",'D2_BASPIS', 'D2_BASCOF') )
    _nTotVr += _oModel:GetValue( 'SD2DETAILP' , Iif(cCampo == "PIS",'D2_VALIMP6', 'D2_VALIMP5') )     
Next

_oModel:LoadValue( 'SF2CAB',Iif(cCampo == "PIS",'F2_BASPIS' , 'F2_BASCOF' ),_nTotBase)
_oModel:LoadValue( 'SF2CAB',Iif(cCampo == "PIS",'F2_VRPIS'  , 'F2_VRCOF'  ),_nTotVr  )
_oModel:LoadValue( 'SF2CAB',Iif(cCampo == "PIS",'F2_BASIMP6', 'F2_BASIMP5'),_nTotBase)
_oModel:LoadValue( 'SF2CAB',Iif(cCampo == "PIS",'F2_VALIMP6', 'F2_VALIMP5'),_nTotVr  )

_oModelDET:GoLine( _nLinPos ) 

Return _nImp


/*
===============================================================================================================================
Programa----------: MFIS011FIS
Autor-------------: Igor Melga�o
Data da Criacao---: 23/05/2023
===============================================================================================================================
Descri��o---------: Valida��o para altera��o de acodordo com o MV_DATAFIS
===============================================================================================================================
Parametros--------: _oModel
===============================================================================================================================
Retorno-----------: lRet
===============================================================================================================================
*/
User Function MFIS011FIS(_oModel)
Local lRet := .T.
Local _dDtAux := GetMV( 'MV_DATAFIS' ,, StoD('') )
Local _cMenPro:= "Data de digita��o menor/igual ao bloqueio para opera��es Fiscais. Solicite o desbloqueio � Contabilidade."
Local _cMenRes:= "Solicite o desbloqueio � Contabilidade."
Local _nOper	:= _oModel:GetOperation()

If _nOper == MODEL_OPERATION_UPDATE .AND. SF2->F2_EMISSAO <= _dDtAux
    //help( cRotina , nLinha , cCampo , cNome , cMensagem , nLinha1 , nColuna , lPop , hWnd , nHeight , nWidth , lGravaLog , aSoluc )
    Help(NIL, NIL, "MFIS011FIS", NIL, _cMenPro,1, 0, NIL, NIL, NIL, NIL, NIL, {_cMenRes})
    lRet := .F.
EndIf

Return lRet

/*
===============================================================================================================================
Programa----------: MFIS011LOG
Autor-------------: Igor Melga�o
Data da Criacao---: 19/05/2023
===============================================================================================================================
Descri��o---------: Rotina para Verificar altera��es dos campos e guradar informa��o de Log
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: lRet
===============================================================================================================================
*/
User Function MFIS011LOG()
Local _oModel      := FWModelActive()
Local _oModelDETP  := _oModel:GetModel('SD2DETAILP')
Local _oModelDETI  := _oModel:GetModel('SD2DETAILI')
Local _aCpSF2      := {"F2_BASIMP6","F2_BASIMP5","F2_VALIMP6","F2_VALIMP5"}
Local _aCpSD2P     := {"D2_BASIMP6","D2_BASIMP5","D2_VALIMP6","D2_VALIMP5","D2_ALQIMP6","D2_ALQIMP5"}
Local _aCpSD2I     := {"D2_ITEM","D2_CF","D2_TES","D2_DIFAL","D2_BASEDES","D2_ICMSCOM","D2_CLASFIS"}
Local _nQtdLin     := 0
Local _aCamposSD2  := {}
Local i            := 0
Local j            := 0
Local k            := 0
Local lRet         := .T.

_aSF2 := {}
_aSD2P := {}
_aSD2I := {}

For i := 1 To Len(_aCpSF2)
    If SF2->&(_aCpSF2[i]) <> _oModel:GetValue( 'SF2CAB',_aCpSF2[i])
        AADD(_aSF2,{_aCpSF2[i],SF2->&(_aCpSF2[i]) ,_oModel:GetValue( 'SF2CAB',_aCpSF2[i])})
    EndIf
Next

_nQtdLin	:= _oModelDETP:Length()

For i := 1 to _nQtdLin

    _oModelDETP:GoLine( i )
    _oModelDETI:GoLine( i )

    _cD2_ITEM    := _oModel:GetValue( 'SD2DETAILP','D2_ITEM')
    _cChave      := _oModel:GetValue( 'SF2CAB','F2_FILIAL')+_oModel:GetValue( 'SF2CAB','F2_DOC')+_oModel:GetValue( 'SF2CAB','F2_SERIE')+_oModel:GetValue( 'SF2CAB','F2_CLIENTE')+_oModel:GetValue( 'SF2CAB','F2_LOJA')
    
    DBSelectArea("SD2")
    DBSetOrder(3)
    If DBSeek(_cChave)
        _aCamposSD2 := {}
        For j := 1 To Len(_aCpSD2P)
            If SD2->&(_aCpSD2P[j]) <> _oModel:GetValue( 'SD2DETAILP',_aCpSD2P[j])
                AADD(_aCamposSD2,{_aCpSD2P[j],SD2->&(_aCpSD2P[j]) ,_oModel:GetValue( 'SD2DETAILP',_aCpSD2P[j])})
            EndIf
        Next
        AADD(_aSD2P,{_cChave+_cD2_ITEM,_aCamposSD2})

        _aCamposSD2 := {}
        For k := 1 To Len(_aCpSD2I)
            If SD2->&(_aCpSD2I[k]) <> _oModel:GetValue( 'SD2DETAILI',_aCpSD2I[k])
                AADD(_aCamposSD2,{_aCpSD2I[k],SD2->&(_aCpSD2I[k]) ,_oModel:GetValue( 'SD2DETAILI',_aCpSD2I[k])})
            EndIf
        Next
        AADD(_aSD2I,{_cChave+_cD2_ITEM,_aCamposSD2})
    EndIf

Next

Return lRet




/*
===============================================================================================================================
Programa----------: MFIS011CON
Autor-------------: Igor Melga�o
Data da Criacao---: 19/05/2023
===============================================================================================================================
Descri��o---------: Consulta Hist�rico de Altera��es 
===============================================================================================================================
Parametros--------: _cChave
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MFIS011CON(_cTipo)
Local _oModel    := FWModelActive()
Local _aCabec    := {}
Local _cTabela   := ""
Local _cChave    := ""
Local _cCpoChave := ""
Local _cTitulo   := ""

If _cTipo == "CAB"
    _cTabela   := "SF2"
    _cChave    := SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA
    _cCpoChave := "SF2.F2_FILIAL || SF2.F2_DOC || SF2.F2_SERIE || SF2.F2_CLIENTE || SF2.F2_LOJA "
    _cTitulo   := "Log de Altera��es da Nota de Sa�da"

    AADD( _aCabec, {"Nota Fiscal / Serie",SF2->F2_DOC + " / " + SF2->F2_SERIE} )
    AADD( _aCabec, {"Fornecedor:",SF2->F2_CLIENTE + " - " + SF2->F2_LOJA + " " + Posicione("SA2",1,xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A2_NOME")} )
Else
    _cTabela   := "SD2"
    _cChave    := _oModel:GetValue( 'SF2CAB','F2_FILIAL')+_oModel:GetValue( 'SF2CAB','F2_DOC')+_oModel:GetValue( 'SF2CAB','F2_SERIE')+_oModel:GetValue( 'SF2CAB','F2_CLIENTE')+_oModel:GetValue( 'SF2CAB','F2_LOJA')+_oModel:GetValue( 'SD2DETAILP','D2_ITEM')
    _cCpoChave := "SD2.D2_FILIAL || SD2.D2_DOC || SD2.D2_SERIE || SD2.D2_CLIENTE || SD2.D2_LOJA || SD2.D2_ITEM"
    _cTitulo   := "Log de Altera��es do item da Nota de Sa�da"

    AADD( _aCabec, {"Nota Fiscal / Serie",SF2->F2_DOC + " / " + SF2->F2_SERIE} )
    AADD( _aCabec, {"Fornecedor:",SF2->F2_CLIENTE + " - " + SF2->F2_LOJA + " " + Posicione("SA2",1,xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A2_NOME")} )
EndIf

U_MFIS009T(_aCabec,_cTabela,_cChave,_cCpoChave,_cTitulo)

Return 


/*
===============================================================================================================================
Programa----------: MFIS011GAT
Autor-------------: Igor Melga�o
Data da Criacao---: 19/05/2023
===============================================================================================================================
Descri��o---------: Gatilho de Campos 
===============================================================================================================================
Parametros--------: _cCampo
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MFIS011WHE(_cCampo)
Local _oModel    := FWModelActive()

If _cCampo == "D2_TRIBUT"
    _oModel:LoadValue( 'SD2DETAILI','D2_TES' ,_oModel:GetValue( 'SD2DETAILI','D2_TRIBUT'))
ElseIf _cCampo == "D2_CLASSEF"
    _oModel:LoadValue( 'SD2DETAILI','D2_CLASFIS' ,_oModel:GetValue( 'SD2DETAILI','D2_CLASSEF'))
ElseIf _cCampo == "D2_CODFISC"
    _oModel:LoadValue( 'SD2DETAILI','D2_CF' ,_oModel:GetValue( 'SD2DETAILI','D2_CODFISC'))
EndIf

Return .T.
