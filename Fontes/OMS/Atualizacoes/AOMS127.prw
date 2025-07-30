/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 29/07/2021 | Ajuste para inclus�o do campo Z25_PESO (Peso M�nimo para Carregamento). Chamado 36841
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 24/09/2021 | Ajustes para cadastro com 4 grids. Chamado 36841
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 28/09/2021 | Ajustes na edi��o dos campos nas grids. Chamado 36841
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 28/09/2021 | Ajustes para valida��o de conteudo das grids. Chamado 36841
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 22/10/2021 | Adi��o de fun��o de pesquisa na Grid e ao marcar Meso ou Microrregi�o efetua��o sele��o em cascata. Chamado 36841
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 03/11/2021 | Corre��o de error.log na exclus�o e retirada de valida��o. Chamado 36841
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 03/11/2021 | Ajustes para alimenta��o das grids na abertura do cadastro na exclus�o. Chamado 36841
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o     | 11/11/2021 | Ajustes para marcadores de posi��o de registro nas grids. Chamado 36841
===============================================================================================================================
*/

#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

Static _oModPM       := Nil
Static _lAltOp       := .F.
Static _aLinhaSub    := {1,1,1,1,1}


/*
===============================================================================================================================
Programa----------: AOMS127
Autor-------------: Igor Melga�o
Data da Criacao---: 30/06/2021
===============================================================================================================================
Descri��o---------: Cadastro de Zona de Entrega (Modelo 2). Chamado: 36841
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------:  
===============================================================================================================================
*/ 
User Function AOMS127()
Local _oBrowse := Nil
Local _aArea   := GetArea()

_oBrowse := FWMBrowse():New()
_oBrowse:SetAlias("Z25")
_oBrowse:SetMenuDef( 'AOMS127' )
_oBrowse:SetDescription("Cadastro de Zona de Entrega")
_oBrowse:Activate()

RestArea(_aArea)

Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Igor Melga�o
Data da Criacao---: 30/06/2021
===============================================================================================================================
Descri��o---------: Rotina de defini��o autom�tica do menu via MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: aRotina - Defini��es do menu principal da Rotina.
===============================================================================================================================
*/
Static Function MenuDef()

//===========================================================================
//| FWMVCMenu - Gera o menu padr�o para o Modelo Informado (Inc/Alt/Vis/Exc) |
//===========================================================================

Return( FWMVCMenu("AOMS127") )

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Igor Melga�o
Data da Criacao---: 30/06/2021
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
Local _oStruZ25P := FWFormStruct(1,'Z25')
Local _oStruSX5F := FWFormStruct(1,'SX5',{|x| Alltrim(x) $ "|X5_FILIAL|X5_TABELA|X5_CHAVE|X5_DESCRI|"})
Local _oStruZ21F := FWFormStruct(1,'Z21',{|x| Alltrim(x) $ "|Z21_FILIAL|Z21_EST|Z21_COD|Z21_NOME|"})
Local _oStruZ22F := FWFormStruct(1,'Z22',{|x| Alltrim(x) $ "|Z22_FILIAL|Z22_EST|Z22_MESO|Z22_COD|Z22_NOME|"})
Local _oStruCC2F := FWFormStruct(1,'CC2',{|x| Alltrim(x) $ "|CC2_FILIAL|CC2_EST|CC2_I_MESO|CC2_I_MICR|CC2_CODMUN|CC2_MUN|"})

Local bVldPre    := {|| U_AOMS127G() }
Local bVldPos    := {|| U_AOMS127V() }
Local bVldCom    := {|_oModel| U_AOMS127C(_oModel) } 
Local bVldCanc   := {|| U_AOMS127FEC() }
Local _aSX5Rel   := {}
Local _aZ21Rel   := {}
Local _aZ22Rel   := {}
Local _aCC2Rel   := {}

_oStruZ25P:RemoveField('Z25_EST')
_oStruZ25P:RemoveField('Z25_MESO')
_oStruZ25P:RemoveField('Z25_NMESO')
_oStruZ25P:RemoveField('Z25_MICRO')
_oStruZ25P:RemoveField('Z25_NMICRO')
_oStruZ25P:RemoveField('Z25_CODMUN')
_oStruZ25P:RemoveField('Z25_MUN')

//Criando o FormModel, adicionando o Cabe�alho e Grid
_oModel := MPFormModel():New("AOMS127M",bVldPre,bVldPos, bVldCom,bVldCanc) 
_oModel:AddFields('Z25CAB',,_oStruZ25P)
_oModel:AddGrid('SX5DETAIL','Z25CAB'   ,_oStruSX5F,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/)
_oModel:AddGrid('Z21DETAIL','SX5DETAIL',_oStruZ21F,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/)
_oModel:AddGrid('Z22DETAIL','Z21DETAIL',_oStruZ22F,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/)
_oModel:AddGrid('CC2DETAIL','Z22DETAIL',_oStruCC2F,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*bLoad*/)

//Adiciona o relacionamento de Filho, Pai
aAdd(_aSX5Rel, {'X5_FILIAL' , 'xFilial( "SX5" )'} )
aAdd(_aSX5Rel, {'X5_TABELA' , '"12"'   } ) 

aAdd(_aZ21Rel, {'Z21_FILIAL', 'xFilial( "Z21" )'} )
aAdd(_aZ21Rel, {'Z21_EST'   , 'SX5DETAIL.X5_CHAVE'})

aAdd(_aZ22Rel, {'Z22_FILIAL', 'xFilial( "Z22" )'} )
aAdd(_aZ22Rel, {'Z22_EST'   , 'Z21DETAIL.Z21_EST'})
aAdd(_aZ22Rel, {'Z22_MESO'  , 'Z21DETAIL.Z21_COD'})

aAdd(_aCC2Rel, {'CC2_FILIAL', 'xFilial( "CC2" )'} )
aAdd(_aCC2Rel, {'CC2_EST'   , 'Z22DETAIL.Z22_EST'})
aAdd(_aCC2Rel, {'CC2_I_MESO', 'Z22DETAIL.Z22_MESO'})
aAdd(_aCC2Rel, {'CC2_I_MICR', 'Z22DETAIL.Z22_COD'})

//Criando o relacionamento
_oModel:SetRelation('SX5DETAIL', _aSX5Rel, SX5->(IndexKey(1)))
_oModel:SetRelation('Z21DETAIL', _aZ21Rel, Z21->(IndexKey(1)))
_oModel:SetRelation('Z22DETAIL', _aZ22Rel, Z22->(IndexKey(1)))
_oModel:SetRelation('CC2DETAIL', _aCC2Rel, CC2->(IndexKey(1)))

_oModel:GetModel('SX5DETAIL'):SetLoadFilter( { {'X5_CHAVE' , '"EX    "'   , MVC_LOADFILTER_NOT_EQUAL } } )

_oModel:GetModel('SX5DETAIL'):SetNoDeleteLine(.T.)
_oModel:GetModel('SX5DETAIL'):SetNoInsertLine(.T.)
_oModel:GetModel('SX5DETAIL'):SetOptional(.T.)
_oModel:GetModel('SX5DETAIL'):SetOnlyQuery(.T.)
_oModel:GetModel('SX5DETAIL'):SetOnlyView(.T.) 

_oModel:GetModel('Z21DETAIL'):SetNoDeleteLine(.T.)
_oModel:GetModel('Z21DETAIL'):SetNoInsertLine(.T.)
_oModel:GetModel('Z21DETAIL'):SetOptional(.T.)
_oModel:GetModel('Z21DETAIL'):SetOnlyQuery(.T.)
_oModel:GetModel('Z21DETAIL'):SetOnlyView(.T.) 

_oModel:GetModel('Z22DETAIL'):SetNoDeleteLine(.T.)
_oModel:GetModel('Z22DETAIL'):SetNoInsertLine(.T.)
_oModel:GetModel('Z22DETAIL'):SetOptional(.T.)
_oModel:GetModel('Z22DETAIL'):SetOnlyQuery(.T.)
_oModel:GetModel('Z22DETAIL'):SetOnlyView(.T.) 

_oModel:GetModel('CC2DETAIL'):SetNoDeleteLine(.T.)
_oModel:GetModel('CC2DETAIL'):SetNoInsertLine(.T.)
_oModel:GetModel('CC2DETAIL'):SetOptional(.T.)
_oModel:GetModel('CC2DETAIL'):SetOnlyQuery(.T.)
_oModel:GetModel('CC2DETAIL'):SetOnlyView(.T.) 

//Insere campo de Selecao do Registro nas Grids
AOMS127F(1,_oStruSX5F,{||AOMS127B(_oModel,"SX5")})
AOMS127F(1,_oStruZ21F,{||AOMS127B(_oModel,"Z21")})
AOMS127F(1,_oStruZ22F,{||AOMS127B(_oModel,"Z22")})
AOMS127F(1,_oStruCC2F,{||AOMS127B(_oModel,"CC2")})

//Setando outras informa��es do Modelo de Dados
_oModel:SetDescription("Modelo de Dados do Cadastro Zona de Entrega")
_oModel:SetPrimaryKey( {} )
_oModel:GetModel("Z25CAB"):SetDescription("Formul�rio do Cadastro Zona de Entrega")

_oStruSX5F:SetProperty("OK",	MODEL_FIELD_WHEN, 		{|| .T. })
_oStruZ21F:SetProperty("OK",	MODEL_FIELD_WHEN, 		{|| .T. })
_oStruZ22F:SetProperty("OK",	MODEL_FIELD_WHEN, 		{|| .T. })
_oStruCC2F:SetProperty("OK",	MODEL_FIELD_WHEN, 		{|| .T. })

_oModel:SetActivate({|_oModel| FWMSGRUN( ,{||  U_AOMS127H(_oModel) } , "Carregando as grids de cadastro, Aguarde...",  ) })


Return _oModel

/*
===============================================================================================================================
Programa----------: ViewDef
Autor-------------: Igor Melga�o
Data da Criacao---: 30/06/2021
===============================================================================================================================
Descri��o---------: Rotina de defini��o da View do MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _oView - Objeto de exibi��o do MVC  
===============================================================================================================================
*/ 
Static Function ViewDef()
Local _oModel    := FWLoadModel("AOMS127")
Local _oStruZ25P := FWFormStruct(2,"Z25")
Local _oStruSX5F := FWFormStruct(2,'SX5',{|x| Alltrim(x) $ "|X5_FILIAL|X5_TABELA|X5_CHAVE|X5_DESCRI|"})
Local _oStruZ21F := FWFormStruct(2,'Z21',{|x| Alltrim(x) $ "|Z21_FILIAL|Z21_EST|Z21_COD|Z21_NOME|"})
Local _oStruZ22F := FWFormStruct(2,'Z22',{|x| Alltrim(x) $ "|Z22_FILIAL|Z22_EST|Z22_MESO|Z22_COD|Z22_NOME|"})
Local _oStruCC2F := FWFormStruct(2,'CC2',{|x| Alltrim(x) $ "|CC2_FILIAL|CC2_EST|CC2_I_MESO|CC2_I_MICR|CC2_CODMUN|CC2_MUN|"})
Local _oView     := Nil

_oView := FWFormView():New()
_oView:SetModel(_oModel)

//FWFORMVIEW():AddGrid(<cViewID >, <oStruct >, [ cSubModelID ], <uParam4 >, [ bGotFocus ])-> NIL
_oView:AddField("VIEW_Z25P",_oStruZ25P,"Z25CAB"   ,,)
_oView:AddGrid('VIEW_SX5F' ,_oStruSX5F,'SX5DETAIL',,)
_oView:AddGrid('VIEW_Z21F' ,_oStruZ21F,'Z21DETAIL',,)
_oView:AddGrid('VIEW_Z22F' ,_oStruZ22F,'Z22DETAIL',,)
_oView:AddGrid('VIEW_CC2F' ,_oStruCC2F,'CC2DETAIL',,)

//Setando o dimensionamento de tamanho
_oView:CreateHorizontalBox('CABEC',20)
_oView:CreateHorizontalBox('GRID1',40)
_oView:CreateHorizontalBox('GRID2',40)

_oView:CreateVerticalBox( 'ITN001' , 050 , 'GRID1' ,,, )
_oView:CreateVerticalBox( 'ITN002' , 050 , 'GRID1' ,,, )
_oView:CreateVerticalBox( 'ITN003' , 050 , 'GRID2' ,,, )
_oView:CreateVerticalBox( 'ITN004' , 050 , 'GRID2' ,,, )

//Amarrando a view com as box
_oView:SetOwnerView('VIEW_Z25P','CABEC')
_oView:SetOwnerView('VIEW_SX5F','ITN001')
_oView:SetOwnerView('VIEW_Z21F','ITN002')
_oView:SetOwnerView('VIEW_Z22F','ITN003')
_oView:SetOwnerView('VIEW_CC2F','ITN004')

//Habilitando t�tulo
_oView:EnableTitleView('VIEW_Z25P','Cabe�alho - Zona de Entrega')
_oView:EnableTitleView('VIEW_SX5F','Estados')
_oView:EnableTitleView('VIEW_Z21F','Mesorregi�es')
_oView:EnableTitleView('VIEW_Z22F','Microrregi�es')
_oView:EnableTitleView('VIEW_CC2F','Municipios')

_oView:SetViewProperty("VIEW_SX5F", "GRIDSEEK", {.T.})
_oView:SetViewProperty("VIEW_SX5F", "GRIDFILTER", {.T.}) 

_oView:SetViewProperty("VIEW_SX5F", "CHANGELINE", {{|_oView|U_AOMS127TIT(_oModel,2,_oView)}})
_oView:SetViewProperty("VIEW_Z21F", "CHANGELINE", {{|_oView|U_AOMS127TIT(_oModel,3,_oView)}})
_oView:SetViewProperty("VIEW_Z22F", "CHANGELINE", {{|_oView|U_AOMS127TIT(_oModel,4,_oView)}})
_oView:SetViewProperty("VIEW_CC2F", "CHANGELINE", {{|_oView|U_AOMS127TIT(_oModel,5,_oView)}})

//Tratativa padr�o para fechar a tela
_oView:SetCloseOnOk({||.T.})

//Acrescenta os Checks
AOMS127F(2,_oStruSX5F,{||AOMS127B(_oModel,"SX5")})
AOMS127F(2,_oStruZ21F,{||AOMS127B(_oModel,"Z21")})
AOMS127F(2,_oStruZ22F,{||AOMS127B(_oModel,"Z22")})
AOMS127F(2,_oStruCC2F,{||AOMS127B(_oModel,"CC2")})

//Remove os campos
_oStruZ25P:RemoveField('Z25_EST')
_oStruZ25P:RemoveField('Z25_MESO')
_oStruZ25P:RemoveField('Z25_NMESO')
_oStruZ25P:RemoveField('Z25_MICRO')
_oStruZ25P:RemoveField('Z25_NMICRO')
_oStruZ25P:RemoveField('Z25_CODMUN')
_oStruZ25P:RemoveField('Z25_MUN')

_oStruSX5F:RemoveField('X5_TABELA') 

_oStruCC2F:RemoveField('LEGEND') 

_oStruSX5F:SetProperty("LEGEND", 	MVC_VIEW_CANCHANGE, .T.)
_oStruZ21F:SetProperty("LEGEND", 	MVC_VIEW_CANCHANGE, .T.)
_oStruZ22F:SetProperty("LEGEND", 	MVC_VIEW_CANCHANGE, .T.)


_oStruSX5F:SetProperty("OK", 	MVC_VIEW_CANCHANGE, .T.)
_oStruZ21F:SetProperty("OK", 	MVC_VIEW_CANCHANGE, .T.)
_oStruZ22F:SetProperty("OK", 	MVC_VIEW_CANCHANGE, .T.)
_oStruCC2F:SetProperty("OK", 	MVC_VIEW_CANCHANGE, .T.)


_oStruSX5F:SetProperty("X5_CHAVE" , 	MVC_VIEW_CANCHANGE, .F.)
_oStruSX5F:SetProperty("X5_DESCRI", 	MVC_VIEW_CANCHANGE, .F.)

_oStruZ21F:SetProperty("Z21_EST", 	MVC_VIEW_CANCHANGE, .F.)
_oStruZ21F:SetProperty("Z21_COD", 	MVC_VIEW_CANCHANGE, .F.)
_oStruZ21F:SetProperty("Z21_NOME", 	MVC_VIEW_CANCHANGE, .F.)

_oStruZ22F:SetProperty("Z22_EST", 	MVC_VIEW_CANCHANGE, .F.)
_oStruZ22F:SetProperty("Z22_COD", 	MVC_VIEW_CANCHANGE, .F.)
_oStruZ22F:SetProperty("Z22_NOME", 	MVC_VIEW_CANCHANGE, .F.)

_oStruCC2F:SetProperty("CC2_EST"   , 	MVC_VIEW_CANCHANGE, .F.)
_oStruCC2F:SetProperty("CC2_I_MESO", 	MVC_VIEW_CANCHANGE, .F.)
_oStruCC2F:SetProperty("CC2_I_MICR", 	MVC_VIEW_CANCHANGE, .F.)
_oStruCC2F:SetProperty("CC2_CODMUN", 	MVC_VIEW_CANCHANGE, .F.)
_oStruCC2F:SetProperty("CC2_MUN"   , 	MVC_VIEW_CANCHANGE, .F.)

_oStruCC2F:SetProperty('OK'  	    , MVC_VIEW_ORDEM ,'01')
_oStruCC2F:SetProperty('CC2_EST'    , MVC_VIEW_ORDEM ,'02')
_oStruCC2F:SetProperty('CC2_I_MESO' , MVC_VIEW_ORDEM ,'03')
_oStruCC2F:SetProperty('CC2_I_MICR' , MVC_VIEW_ORDEM ,'04')
_oStruCC2F:SetProperty('CC2_MUN'    , MVC_VIEW_ORDEM ,'05')
_oStruCC2F:SetProperty('CC2_CODMUN' , MVC_VIEW_ORDEM ,'06')
	
Return _oView


/*
===============================================================================================================================
Programa----------: AOMS127V
Autor-------------: Igor Melga�o
Data da Criacao---: 30/06/2021
===============================================================================================================================
Descri��o---------: Rotina de valida��o
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _lReturn  
===============================================================================================================================
*/ 
User Function AOMS127V()
Local _lReturn      := .F.
Local _oModel       := FwModelActivete()
Local _nOperation   := _oModel:GetOperation()
Local i             := 0
Local j             := 0
Local k             := 0
Local m             := 0
Local ni            := 0
Local nj            := 0
Local nk            := 0
Local nm            := 0

If _nOperation <> MODEL_OPERATION_DELETE
    ni := _oModel:aallsubmodels[2]:GetLine()
    For i := 1 To _oModel:aallsubmodels[2]:Length()
        _oModel:aallsubmodels[2]:GoLine(i)
        If _oModel:aallsubmodels[2]:GetValue("OK")

            nj := _oModel:aallsubmodels[3]:GetLine()
            For j := 1 To _oModel:aallsubmodels[3]:Length()
                _oModel:aallsubmodels[3]:GoLine(j)
                If _oModel:aallsubmodels[3]:GetValue("OK")

                    nk := _oModel:aallsubmodels[4]:GetLine()
                    For k := 1 To _oModel:aallsubmodels[4]:Length()
                        _oModel:aallsubmodels[4]:GoLine(k)
                        If _oModel:aallsubmodels[4]:GetValue("OK")

                            nm := _oModel:aallsubmodels[5]:GetLine()
                            For m := 1 To _oModel:aallsubmodels[5]:Length()
                                _oModel:aallsubmodels[5]:GoLine(m)
                                If _oModel:aallsubmodels[5]:GetValue("OK")
                                    _lReturn := .T.
                                    Exit
                                EndIf
                            Next
                            _oModel:aallsubmodels[5]:GoLine(nm)
                        EndIf
                    Next
                    _oModel:aallsubmodels[4]:GoLine(nk)
                EndIf
            Next
            _oModel:aallsubmodels[3]:GoLine(nj)
        EndIf

    Next
    _oModel:aallsubmodels[2]:GoLine(ni)

    If !_lReturn

    	U_ITMSG("N�o h� munic�pios selecionados! ",;
                "Aten��o",;
                "Selecione pelo menos um munic�pio.  ",3 , , , .T.)	
              
    EndIf
Else
    _lReturn := .T.
EndIf

Return _lReturn

/*
===============================================================================================================================
Programa----------: AOMS127C
Autor-------------: Igor Melga�o
Data da Criacao---: 02/07/2021
===============================================================================================================================
Descri��o---------: Rotina de Grava��o
===============================================================================================================================
Parametros--------: _oModel := Modelo Ativo
===============================================================================================================================
Retorno-----------: _lReturn  
===============================================================================================================================
*/ 
User Function AOMS127C(_oModel)
Local _lReturn      := .T.
Local _aOrd         := SaveOrd({"Z25"})
Local _nOperation   := _oModel:GetOperation() 
Local _oModelMaster := _oModel:GetModel("Z25CAB")
Local _cCod         := _oModelMaster:GetValue('Z25_COD' )
Local _cNome        := _oModelMaster:GetValue('Z25_NOME') 
Local _cPeso        := _oModelMaster:GetValue('Z25_PESO')
Local i             := 0
Local j             := 0
Local k             := 0
Local m             := 0
Local _lExclui      := .F.
Local _lInclui      := .F.

If _nOperation == MODEL_OPERATION_INSERT
    _lInclui := .T.
ElseIf _nOperation == MODEL_OPERATION_DELETE .OR. _lAltOp
    _lInclui := .F.
    _lAltOp  := .F.
    Dbselectarea('Z25')
    Dbsetorder(1)
    If Dbseek(xFilial("Z25")+_cCod)
        Do While xFilial("Z25")+_cCod == Z25->(Z25_FILIAL+Z25_COD)
            RecLock('Z25', .F.)
            DBDelete()
            Z25->(MsUnlock())
            Z25->(DbSkip())
        EndDo
    EndIf
ElseIf _nOperation == MODEL_OPERATION_UPDATE
    // Verfica os que foram desmarcados e exclui
    DbselectArea('Z25')
    Dbsetorder(1)
    If Dbseek(xFilial('Z25')+_cCod)
        Do While Z25->(Z25_FILIAL+Z25_COD) == xFilial('Z25')+_cCod

            lBusca := _oModel:aallsubmodels[2]:SeekLine({{"X5_CHAVE",Z25->Z25_EST},{"X5_TABELA","12"}})

            If lBusca .AND. _oModel:aallsubmodels[2]:GetValue("OK")           
                
                lBusca := _oModel:aallsubmodels[3]:SeekLine({{"Z21_COD",Z25->Z25_MESO},{"Z21_EST",Z25->Z25_EST}})
                
                If lBusca .AND. _oModel:aallsubmodels[3]:GetValue("OK")   

                    lBusca := _oModel:aallsubmodels[4]:SeekLine({{"Z22_COD",Z25->Z25_MICRO},{"Z22_MESO",Z25->Z25_MESO},{"Z22_EST",Z25->Z25_EST}})  

                    If lBusca .AND. _oModel:aallsubmodels[4]:GetValue("OK")  
                        
                        lBusca := _oModel:aallsubmodels[5]:SeekLine({{"CC2_CODMUN",Z25->Z25_CODMUN},{"CC2_EST",Z25->Z25_EST}})    
                        
                        If lBusca .AND. _oModel:aallsubmodels[5]:GetValue("OK")
                            //Desmarca os que j� existem na tabela para n�o incluir novamente
                            _oModel:aallsubmodels[5]:LoadValue("OK",.F. )  

                            _lExclui := .F.
                        Else
                            _oModel:aallsubmodels[5]:LoadValue("OK",.F. ) 

                            _lExclui := .T.
                        EndIf
                    Else
                        _lExclui := .T.
                    EndIf
                Else
                    _lExclui := .T.
                EndIf
            Else
                _lExclui := .T.
            EndIf

            If _lExclui
                RecLock('Z25', .F.)
                DBDelete()
                Z25->(MsUnlock())   
            EndIf
            Z25->(DBSkip())
        EndDo
    EndIf

    // Executa rotina de inclus�o
    _lInclui := .T.

EndIf

If _lInclui
    For i := 1 To _oModel:aallsubmodels[2]:Length()
        _oModel:aallsubmodels[2]:GoLine(i)
        If _oModel:aallsubmodels[2]:GetValue("OK")

            For j := 1 To _oModel:aallsubmodels[3]:Length()
                _oModel:aallsubmodels[3]:GoLine(j)
                If _oModel:aallsubmodels[3]:GetValue("OK")

                    For k := 1 To _oModel:aallsubmodels[4]:Length()
                        _oModel:aallsubmodels[4]:GoLine(k)
                        If _oModel:aallsubmodels[4]:GetValue("OK")

                            For m := 1 To _oModel:aallsubmodels[5]:Length()
                                _oModel:aallsubmodels[5]:GoLine(m)
                                If _oModel:aallsubmodels[5]:GetValue("OK")
                                    RecLock('Z25', .T.)
                                    Z25->Z25_COD    := _cCod 
                                    Z25->Z25_NOME   := _cNome
                                    Z25->Z25_PESO   := _cPeso
                                    Z25->Z25_EST    := _oModel:aallsubmodels[5]:GetValue("CC2_EST")
                                    Z25->Z25_MESO   := _oModel:aallsubmodels[5]:GetValue("CC2_I_MESO")
                                    Z25->Z25_MICRO  := _oModel:aallsubmodels[5]:GetValue("CC2_I_MICR")
                                    Z25->Z25_CODMUN := _oModel:aallsubmodels[5]:GetValue("CC2_CODMUN")
                                    Z25->Z25_MUN    := _oModel:aallsubmodels[5]:GetValue("CC2_MUN")
                                    Z25->(MsUnlock())
                                EndIf
                            Next
                        EndIf
                    Next
                EndIf
            Next
        EndIf
    Next
EndIf

RestOrd(_aOrd)

Return _lReturn

/*
===============================================================================================================================
Programa----------: AOMS127C
Autor-------------: Igor Melga�o
Data da Criacao---: 02/07/2021
===============================================================================================================================
Descri��o---------: Rotina para apagar o modelo ativo
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/
User Function AOMS127G()

_oModPM  := Nil

Return .T.


/*
===============================================================================================================================
Programa----------: AOMS127FEC
Autor-------------: Igor Melga�o
Data da Criacao---: 03/11/2021
===============================================================================================================================
Descri��o---------: Rotina para restaurar vari�vel de controle para alimenta��o das grids na exclus�o 
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/
User Function AOMS127FEC()

_lAltOp := .F.

Return .T.

/*
===============================================================================================================================
Programa----------: AOMS127TIT
Autor-------------: Igor Melga�o
Data da Criacao---: 03/11/2021
===============================================================================================================================
Descri��o---------: Rotina para exibir a imagem de registro posicionado
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/
User Function AOMS127TIT(_oModel,nSubmodel,_oView)
Local _nLine := 0
Local _aView :={'VIEW_Z25P','VIEW_SX5F','VIEW_Z21F','VIEW_Z22F','VIEW_CC2F'}
Local i  := 0

If nSubmodel < 5
    _nLine := _oModel:aallsubmodels[nSubmodel]:GetLine()

    //Apago as linhas posicionadas
    For i := nSubmodel To 4
        _oModel:aallsubmodels[i]:GoLine(_aLinhaSub[i]) 
        _oModel:aallsubmodels[i]:LoadValue("LEGEND","")
    Next

    _oModel:aallsubmodels[nSubmodel]:GoLine(_nLine)

    For i := nSubmodel To 4
        _oModel:aallsubmodels[i]:LoadValue("LEGEND","NEXT")
        _aLinhaSub[i] := _oModel:aallsubmodels[i]:GetLine()
    Next

    For i := nSubmodel To 5
        _oView:Refresh(_aView[i])
    Next
EndIf

Return .T.


/*
===============================================================================================================================
Programa----------: AOMS127F
Autor-------------: Igor Melga�o
Data da Criacao---: 02/07/2021
===============================================================================================================================
Descri��o---------: Rotina para criar os campos Check das grids
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/
Static Function AOMS127F(nOpcao,oStruct, bValid)

	Do Case
	Case nOpcao == 1	//Model
		oStruct:AddField(		" - "						,;	//[01]  C   Titulo do campo		//"Conciliar"
								" - "						,;	//[02]  C   ToolTip do campo	//"Conciliar"
							 	"OK"						,;	//[03]  C   Id do Field
							 	"L"							,;	//[04]  C   Tipo do campo
								1							,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								0							,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								bValid						,;	//[07]  B   Code-block de valida��o do campo
								NIL							,;	//[08]  B   Code-block de valida��o When do campo
								NIL							,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.							,;	//[10]  L   Indica se o campo tem preenchimento obrigat�rio
								NIL							,;	//[11]  B   Code-block de inicializacao do campo
								.F.							,;	//[12]  L   Indica se trata-se de um campo chave
								.F.							,;	//[13]  L   Indica se o campo pode receber valor em uma opera��o de update.
								.F.							)	//[14]  L   Indica se o campo � virtual
	
    
    oStruct:AddField( ;
                        AllTrim('') , ;            // [01] C Titulo do campo
                        AllTrim('') , ;            // [02] C ToolTip do campo
                        'LEGEND' , ;               // [03] C identificador (ID) do Field
                        'C' , ;                    // [04] C Tipo do campo
                        50 , ;                     // [05] N Tamanho do campo
                        0 , ;                      // [06] N Decimal do campo
                        NIL , ;                    // [07] B Code-block de valida��o do campo
                        NIL , ;                    // [08] B Code-block de valida��o When do campo
                        NIL , ;                    // [09] A Lista de valores permitido do campo
                        NIL , ;                    // [10] L Indica se o campo tem preenchimento obrigat�rio
                        {|| iif(0 = 0, "","")} ,;                   // [11] B Code-block de inicializacao do campo
                        NIL , ;                    // [12] L Indica se trata de um campo chave
                        .T. , ;                    // [13] L Indica se o campo pode receber valor em uma opera��o de update.
                        .F. )                      // [14] L Indica se o campo � virtual

    
    Case nOpcao == 2	//View
		oStruct:AddField(	"OK"							,;	// [01]  C   Nome do Campo
							"01"							,;	// [02]  C   Ordem
							" - "							,;	// [03]  C   Titulo do campo		//"Conciliar"
							" - "							,;	// [04]  C   Descricao do campo		//"Conciliar"
							NIL								,;	// [05]  A   Array com Help
							"Check"							,;	// [06]  C   Tipo do campo
							NIL								,;	// [07]  C   Picture
							NIL								,;	// [08]  B   Bloco de Picture Var
							NIL								,;	// [09]  C   Consulta F3
							NIL								,;	// [10]  L   Indica se o campo � alteravel
							NIL								,;	// [11]  C   Pasta do campo
							NIL								,;	// [12]  C   Agrupamento do campo
							NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
							NIL								,;	// [14]  N   Tamanho maximo da maior op��o do combo
							NIL								,;	// [15]  C   Inicializador de Browse
							NIL								,;	// [16]  L   Indica se o campo � virtual
							NIL								,;	// [17]  C   Picture Variavel
							NIL								)	// [18]  L   Indica pulo de linha ap�s o campo

         oStruct:AddField(                         ;       // Ord. Tipo Desc.
                 'LEGEND'                        , ;     // [01] C   Nome do Campo
                 "00"                               , ;     // [02] C   Ordem
                 AllTrim( ''    )                   , ;     // [03] C   Titulo do campo
                 AllTrim( '' )                      , ;     // [04] C   Descricao do campo
                 { 'Legenda' }                      , ;     // [05] A   Array com Help
                 'C'                                , ;     // [06] C   Tipo do campo
                 '@BMP'                             , ;     // [07] C   Picture
                 NIL                                , ;     // [08] B   Bloco de Picture Var
                 ''                                 , ;     // [09] C   Consulta F3
                 .T.                                , ;     // [10] L   Indica se o campo � alteravel
                 NIL                                , ;     // [11] C   Pasta do campo
                 NIL                                , ;     // [12] C   Agrupamento do campo
                 NIL                                , ;     // [13] A   Lista de valores permitido do campo (Combo)
                 NIL                                , ;     // [14] N   Tamanho maximo da maior op��o do combo
                 "Iif(0 = 0, '','')"                         , ;     // [15] C   Inicializador de Browse
                 .F.                                , ;     // [16] L   Indica se o campo � virtual
                 NIL                                , ;     // [17] C   Picture Variavel
                 NIL                                )       // [18] L   Indica pulo de linha ap�s o campo


    EndCase
Return

/*
===============================================================================================================================
Programa----------: AOMS127H
Autor-------------: Igor Melga�o
Data da Criacao---: 21/09/2021
===============================================================================================================================
Descri��o---------: Rotina para Carregar as grids
===============================================================================================================================
Parametros--------: _oModel
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/
User Function AOMS127H(_oModel)
Local _aOrd         := SaveOrd({"Z25"})
Local _oModelMaster := _oModel:GetModel("Z25CAB")
Local cCodZ25       := _oModelMaster:GetValue('Z25_COD' )
Local lBusca        := .F.
Local _nOperation   := _oModel:GetOperation()
Local nLinha        := 0
Local nLinhaZ21     := 0
Local nLinhaZ22     := 0
Local nLinhaCC2     := 0

If _nOperation == MODEL_OPERATION_INSERT

    _oModel:aallsubmodels[2]:SetNoDeleteLine(.F.)
    _oModel:aallsubmodels[2]:SetNoInsertLine(.F.)

    _oModel:aallsubmodels[3]:SetNoDeleteLine(.F.)
    _oModel:aallsubmodels[3]:SetNoInsertLine(.F.)    

    _oModel:aallsubmodels[4]:SetNoDeleteLine(.F.)
    _oModel:aallsubmodels[4]:SetNoInsertLine(.F.)    

    _oModel:aallsubmodels[5]:SetNoDeleteLine(.F.)
    _oModel:aallsubmodels[5]:SetNoInsertLine(.F.)    

    DbSelectArea("SX5")
    DbSetOrder(1)
    DBSeek(xFilial("SX5")+"12")
    Do While SX5->X5_FILIAL + SX5->X5_TABELA == xFilial("SX5")+"12" .AND. !EOF()

        If Alltrim(SX5->X5_CHAVE) == "EX"
            SX5->(DbSkip())
            Loop
        EndIf 

        If !Empty(Alltrim(_oModel:aallsubmodels[2]:GetValue('X5_CHAVE' )))
            nLinha := _oModel:aallsubmodels[2]:GetLine()
            _oModel:aallsubmodels[2]:GoLine(nLinha+1)
            If !Empty(Alltrim(_oModel:aallsubmodels[2]:GetValue('X5_CHAVE' )))
                _oModel:aallsubmodels[2]:AddLine()
            EndIf
        EndIf
        _oModel:aallsubmodels[2]:LoadValue("X5_TABELA",SX5->X5_TABELA )  
        _oModel:aallsubmodels[2]:LoadValue("X5_CHAVE",SX5->X5_CHAVE )  
        _oModel:aallsubmodels[2]:LoadValue("X5_DESCRI",SX5->X5_DESCRI )  

        DbSelectArea("Z21")
        DbSetOrder(4)
        If DBSeek(xFilial("Z21")+Rtrim(SX5->X5_CHAVE))
            Do While Z21->Z21_FILIAL+Z21->Z21_EST == xFilial("Z21")+rtrim(SX5->X5_CHAVE) .AND. Z21->(!EOF())
                If !Empty(Alltrim(_oModel:aallsubmodels[3]:GetValue('Z21_EST' )))
                    _oModel:aallsubmodels[3]:AddLine()
                Else
                    nLinhaZ21 := _oModel:aallsubmodels[3]:GetLine()
                EndIf
                _oModel:aallsubmodels[3]:LoadValue("Z21_EST",Z21->Z21_EST )  
                _oModel:aallsubmodels[3]:LoadValue("Z21_COD", Z21->Z21_COD )  
                _oModel:aallsubmodels[3]:LoadValue("Z21_NOME",Z21->Z21_NOME )  

                DbSelectArea("Z22")
                DbSetOrder(4)
                If DBSeek(xFilial("Z22")+Z21->Z21_EST+Z21->Z21_COD)
                    Do While Z22->Z22_FILIAL+Z22->Z22_EST+Z22->Z22_MESO == xFilial("Z22")+Z21->Z21_EST+Z21->Z21_COD .AND. Z22->(!EOF())
                        If !Empty(Alltrim(_oModel:aallsubmodels[4]:GetValue('Z22_EST' )))
                            _oModel:aallsubmodels[4]:AddLine()
                        Else
                            nLinhaZ22 := _oModel:aallsubmodels[4]:GetLine()
                        EndIf
                        _oModel:aallsubmodels[4]:LoadValue("Z22_EST",Z22->Z22_EST )
                        _oModel:aallsubmodels[4]:LoadValue("Z22_MESO",Z22->Z22_MESO )    
                        _oModel:aallsubmodels[4]:LoadValue("Z22_COD", Z22->Z22_COD )  
                        _oModel:aallsubmodels[4]:LoadValue("Z22_NOME",Z22->Z22_NOME )  

                        DbSelectArea("CC2")
                        DbSetOrder(6)
                        If DBSeek( xFilial("CC2") + Z22->Z22_EST + Z22->Z22_MESO + Z22->Z22_COD )
                            Do While CC2->CC2_FILIAL + CC2->CC2_EST + CC2->CC2_I_MESO + CC2->CC2_I_MICR == xFilial("CC2") + Z22->Z22_EST + Z22->Z22_MESO + Z22->Z22_COD .AND. CC2->(!EOF())
                                If !Empty(Alltrim(_oModel:aallsubmodels[5]:GetValue('CC2_EST' )))
                                    _oModel:aallsubmodels[5]:AddLine()
                                Else
                                    nLinhaCC2 := _oModel:aallsubmodels[5]:GetLine()
                                EndIf
                                _oModel:aallsubmodels[5]:LoadValue("CC2_EST"   ,CC2->CC2_EST )
                                _oModel:aallsubmodels[5]:LoadValue("CC2_I_MESO",CC2->CC2_I_MESO )    
                                _oModel:aallsubmodels[5]:LoadValue("CC2_I_MICR",CC2->CC2_I_MICR )  
                                _oModel:aallsubmodels[5]:LoadValue("CC2_CODMUN",CC2->CC2_CODMUN )  
                                _oModel:aallsubmodels[5]:LoadValue("CC2_MUN"   ,CC2->CC2_MUN )  

                                CC2->(DbSkip())
                            EndDo
                            _oModel:aallsubmodels[5]:GoLine(nLinhaCC2)
                        EndIf

                        Z22->(DbSkip())
                    EndDo
                    _oModel:aallsubmodels[4]:GoLine(nLinhaZ22)
                EndIf

                Z21->(DbSkip())
            EndDo
            _oModel:aallsubmodels[3]:GoLine(nLinhaZ21)
        EndIf

        SX5->(DbSkip())
    EndDo
    
    _oModel:aallsubmodels[2]:SetNoDeleteLine(.T.)
    _oModel:aallsubmodels[2]:SetNoInsertLine(.T.)

    _oModel:aallsubmodels[3]:SetNoDeleteLine(.T.)
    _oModel:aallsubmodels[3]:SetNoInsertLine(.T.)    

    _oModel:aallsubmodels[4]:SetNoDeleteLine(.T.)
    _oModel:aallsubmodels[4]:SetNoInsertLine(.T.)    

    _oModel:aallsubmodels[5]:SetNoDeleteLine(.T.)
    _oModel:aallsubmodels[5]:SetNoInsertLine(.T.)    

ElseIf _nOperation == MODEL_OPERATION_UPDATE  .OR. _nOperation ==  MODEL_OPERATION_VIEW .OR. _nOperation ==  MODEL_OPERATION_DELETE  
    
    If  _nOperation ==  MODEL_OPERATION_DELETE
        _lAltOp := .T.
    	_oModel:DeActivate()
        _oModel:SetOperation( 4 )				   		// Opera��o: 3 � Inclus�o / 4 � Altera��o / 5 - Exclus�o
    	_oModel:Activate()
    EndIf

    DbselectArea('Z25')
    Dbsetorder(1)
    DbgoTop()
    If Dbseek(xFilial('Z25')+cCodZ25)
        Do While Z25->(Z25_FILIAL+Z25_COD) == xFilial('Z25')+cCodZ25

            lBusca := _oModel:aallsubmodels[2]:SeekLine({{"X5_CHAVE",Z25->Z25_EST},{"X5_TABELA","12"}})

            If lBusca
                _oModel:aallsubmodels[2]:LoadValue("OK",.T. )            
                
                nLinhaZ21 := _oModel:aallsubmodels[3]:GetLine()
                lBusca    := _oModel:aallsubmodels[3]:SeekLine({{"Z21_COD",Z25->Z25_MESO},{"Z21_EST",Z25->Z25_EST}})
                
                If lBusca
                    _oModel:aallsubmodels[3]:LoadValue("OK",.T. )

                    nLinhaZ22 := _oModel:aallsubmodels[4]:GetLine()
                    lBusca    := _oModel:aallsubmodels[4]:SeekLine({{"Z22_COD",Z25->Z25_MICRO},{"Z22_MESO",Z25->Z25_MESO},{"Z22_EST",Z25->Z25_EST}})  

                    If lBusca
                        _oModel:aallsubmodels[4]:LoadValue("OK",.T. )
             
                        nLinhaCC2 := _oModel:aallsubmodels[5]:GetLine()
                        lBusca    := _oModel:aallsubmodels[5]:SeekLine({{"CC2_CODMUN",Z25->Z25_CODMUN},{"CC2_EST",Z25->Z25_EST}})    
                        
                        If lBusca
                            _oModel:aallsubmodels[5]:LoadValue("OK",.T. )
                        EndIf
                        _oModel:aallsubmodels[5]:GoLine(nLinhaCC2)
                    EndIf
                    _oModel:aallsubmodels[4]:GoLine(nLinhaZ22)
                EndIf
                _oModel:aallsubmodels[3]:GoLine(nLinhaZ21)
            EndIf
            _oModel:aallsubmodels[2]:GoLine(1)
            Z25->(DBSkip())
        EndDo
    EndIf

EndIf

_oModel:aallsubmodels[2]:GoLine(1)

_oModel:aallsubmodels[2]:LoadValue("LEGEND","NEXT")
_oModel:aallsubmodels[3]:LoadValue("LEGEND","NEXT")
_oModel:aallsubmodels[4]:LoadValue("LEGEND","NEXT")


RestOrd(_aOrd)

Return .T.

/*
===============================================================================================================================
Programa----------: AOMS127N
Autor-------------: Igor Melga�o
Data da Criacao---: 21/09/2021
===============================================================================================================================
Descri��o---------: Fun��o para retornar a chave prim�ria do cadastro
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _cRet
===============================================================================================================================
*/
User function AOMS127N()

Local _cRet    := ""
Local _aArea   := GetArea()     

Local _cAlias  := GetNextAlias()
Local _cFiltro := "%"  

_cFiltro += " AND Z25_FILIAL = '" + xFilial("Z25") + "'"
_cFiltro += "%"

BeginSql alias _cAlias
	SELECT
	      TO_NUMBER(NVL(MAX(Z25_COD),'0')) AS COD
	FROM
	      %table:Z25%
	WHERE
	      D_E_L_E_T_ = ' '
	      %exp:_cFiltro%	      
EndSql

dbSelectArea(_cAlias)
(_cAlias)->(dbGotop())    

_cRet:= StrZero((_cAlias)->COD + 1,6)          

//================================================================================
// Finaliza a area criada anteriormente.
//================================================================================
dbSelectArea(_cAlias)
(_cAlias)->(dbCloseArea())

While !MayIUseCode("Z25_COD" + xFilial("Z25") + _cRet)  //verifica se esta na memoria, sendo usado
	_cRet := Soma1(_cRet)						           // busca o proximo numero disponivel 
EndDo 

RestArea(_aArea)

Return _cRet

/*
===============================================================================================================================
Programa----------: AOMS127B
Autor-------------: Igor Melga�o
Data da Criacao---: 04/10/2021
===============================================================================================================================
Descri��o---------: Valida o acionamento do checkbox das grids para n�o marcar grid filha antes da grid pai
===============================================================================================================================
Parametros--------: _oModel - Model ativo
                    _cAlias - Grid onde a marca��o do check � executada
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS127B(_oModel,_cAlias)
Local _lReturn := .T.
Local _cMsg1 := ""
Local _cMsg2 := ""
Local _oView := FWViewActive() 
Local _lOk   := .F.
Local k := 0
Local j := 0
Local n := 0

IF _cAlias == "CC2"
    If !_oModel:aallsubmodels[4]:GetValue("OK") 
        _cMsg1 := "N�o � possivel marcar este Munic�pio!"
        _cMsg2 := "Marque a Microrregi�o antes de marcar o Munic�pio. "
        _lReturn := .F.
    ElseIf !_oModel:aallsubmodels[3]:GetValue("OK") //Meso
        _cMsg1 := "N�o � possivel marcar esta Microrregi�o!"
        _cMsg2 := "Marque a Mesorregi�o antes de marcar a Microrregi�o. "
        _lReturn := .F.    
    ElseIf !_oModel:aallsubmodels[2]:GetValue("OK") //Estado
        _cMsg1 := "N�o � possivel marcar esta Mesorregi�o!"
        _cMsg2 := "Marque o Estado antes de marcar a Mesorregi�o. "
        _lReturn := .F.
    EndIf
ELSEIF _cAlias == "Z22"
    If !_oModel:aallsubmodels[3]:GetValue("OK") //Meso
        _cMsg1 := "N�o � possivel marcar esta Microrregi�o!"
        _cMsg2 := "Marque a Mesorregi�o antes de marcar a Microrregi�o. "
        _lReturn := .F.    
    ElseIf !_oModel:aallsubmodels[2]:GetValue("OK") //Estado
        _cMsg1 := "N�o � possivel marcar esta Mesorregi�o!"
        _cMsg2 := "Marque o Estado antes de marcar a Mesorregi�o. "   
        _lReturn := .F.
    EndIf

    If _lReturn
        _lOk := _oModel:aallsubmodels[4]:GetValue("OK")
        For k := 1 To _oModel:aallsubmodels[5]:Length()
            _oModel:aallsubmodels[5]:GoLine(k)
            _oModel:aallsubmodels[5]:LoadValue("OK",_lOk )
        Next
        _oModel:aallsubmodels[5]:GoLine(1)
        _oView:Refresh('VIEW_CC2F')
    EndIf
ELSEIF _cAlias == "Z21"
    If !_oModel:aallsubmodels[2]:GetValue("OK") //Estado
        _cMsg1 := "N�o � possivel marcar esta Mesorregi�o!"
        _cMsg2 := "Marque o Estado antes de marcar a Mesorregi�o. "
        _lReturn := .F.
    EndIf

    If _lReturn
        _lOk := _oModel:aallsubmodels[3]:GetValue("OK")
        For k := 1 To _oModel:aallsubmodels[4]:Length()
            _oModel:aallsubmodels[4]:GoLine(k)
            _oModel:aallsubmodels[4]:LoadValue("OK",_lOk )
            
            For j := 1 To _oModel:aallsubmodels[5]:Length()
                _oModel:aallsubmodels[5]:GoLine(j)
                _oModel:aallsubmodels[5]:LoadValue("OK",_lOk )
            Next
            _oModel:aallsubmodels[5]:GoLine(1)
        Next
        _oModel:aallsubmodels[4]:GoLine(1)
        _oView:Refresh('VIEW_Z22F')
                    
        _oView:Refresh('VIEW_CC2F')
    EndIf
ELSEIF _cAlias == "SX5"
    
    _lReturn := .T.

    If _lReturn
        _lOk := _oModel:aallsubmodels[2]:GetValue("OK")
        For n := 1 To _oModel:aallsubmodels[3]:Length()   
            _oModel:aallsubmodels[3]:GoLine(n)
            _oModel:aallsubmodels[3]:LoadValue("OK",_lOk )
            
            For k := 1 To _oModel:aallsubmodels[4]:Length()
                _oModel:aallsubmodels[4]:GoLine(k)
                _oModel:aallsubmodels[4]:LoadValue("OK",_lOk )
                
                For j := 1 To _oModel:aallsubmodels[5]:Length()
                    _oModel:aallsubmodels[5]:GoLine(j)
                    _oModel:aallsubmodels[5]:LoadValue("OK",_lOk )
                Next
                _oModel:aallsubmodels[5]:GoLine(1)
            Next
            _oModel:aallsubmodels[4]:GoLine(1)
        Next
        _oModel:aallsubmodels[3]:GoLine(1)

        _oView:Refresh('VIEW_Z21F')
        _oView:Refresh('VIEW_Z22F')            
        _oView:Refresh('VIEW_CC2F')
    EndIf
ENDIF

If !_lReturn

    _oModel:SetErrorMessage('', '' , '' , '' , "AOMS127B", _cMsg1, _cMsg2)
     
EndIf

Return _lReturn 
