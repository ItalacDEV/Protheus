/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor     |   Data   |                                             Motivo
===============================================================================================================================
Alex Wallauer| 02/03/23 | Chamado 43076. Busca da Assistente no Cadastro de Assistente Adm Comercial respons�vel.
Julio Paz    | 11/04/23 | Chamado 43518. Alterar rotina para gravar a data da ocorrencia nos campos F2_I_DENCL e F2_I_DENOL.
Alex Wallauer| 25/05/23 | Chamado 43840. Tratamento para replicar 22 campos do Trasit Time Logistico (ReplDatas TransTime()).
Julio Paz    | 29/08/23 | Chamado 44817/33947/44516.Corrigir error log chave �nica duplicada na grava��o ocorr�ncias de frete
Julio Paz    | 20/09/23 | Chamado 33947. Redefinir o envio de e-mails s�o enviados no cancelamento de cobran�a de ocorr�ncia.
Igor Melga�o | 05/12/23 | Chamado 45463. Ajuste para chamada da Ocorrencias de frete pelo MOMS016 e SPEDNFE.
Alex Wallauer| 13/12/23 | Chamado 45768. Andre. Criacao de E-mail para enviar ao COMERCIAL solitado pela torre de controle.
Alex Wallauer| 21/12/23 | Chamado 45921. Andre. Corre��o para n�o enviar e-mail para os analistas no ambiente de produ��o.
Alex Wallauer| 02/01/23 | Chamado 45921. Andre. Corre��o das colunas da tela encerramento m�ltiplos e cria��o do bot�o "Atualiza Telefones".
Alex Wallauer| 09/01/23 | Chamado 45985. Jerry. Corre��o do error.log na exclusao da pendencia.
Alex Wallauer| 01/02/24 | Chamado 46026. Jerry. Ajustes no calculo das datas Prev. Entrega Oper.Log e Prev. Entrega Cliente.
Alex Wallauer| 08/02/24 | Chamado 44782. Ajustes para a nova opcao de tipo de entrega: O = Agendado pelo Op.Log.
Antonio Neves| 21/03/24 | Chamado 46405. Dados do Operador Log�stico e Dados da Carga.
Julio Paz    | 28/03/24 | Chamado 46405. Ant�nio. Cria��o de tela para visualiza��o dos dados das NF das Cargas.
Igor Melga�o | 16/04/24 | Chamado 46405. Ant�nio. Mudan�a de local de acionamento da tela para visualiza��o dos dados das NF das Cargas.
Igor Melga�o | 08/04/24 | Chamado 46400. Cria��o de campos de Status para replicar na tabela ZF5.
Igor Melga�o | 12/04/24 | Chamado 46822. Adi��o de dados do Cliente no envio do Email.
Igor Melga�o | 16/04/24 | Chamado 46925. Ajuste para envio de e-mail depois de um Desarm Transaction.
Alex Wallauer| 07/05/24 | Chamado 47107. Vanderlei. Gravacao do cpos F2_I_DCHOL/F2_I_DCHCL para os tipos novos  "Q" e "R".
Alex Wallauer| 31/05/24 | Chamado 47403. Jerry. Ajustes no calculo do campo da Previs�o de entrega no cliente F2_I_PENCL.
Alex Wallauer| 22/07/24 | Chamado 47942. Vanderlei. Ajustes na gravacao das Previs�es de entrega via ocorrencia. Parte 1.
Alex Wallauer| 24/07/24 | Chamado 47681. Andre. Ajuste para n�o enviar e-mail do AOMS3Comercial mais de 1 vez p/ o mesmo Email.
Igor Melga�o | 25/07/24 | Chamado 47833. Antonio. Ajustes para valida��o e inclus�o de dados na ZM4 para aprova��o de prorroga��o de vecto
Alex Wallauer| 07/08/24 | Chamado 48035. Andre. Grava��o e tratamento do campo novo ZF5_CHVNDT da chave do Titulo NDT.
Alex Wallauer| 13/08/24 | Chamado 48035. Andre. Corre��o de error.log variable does not exist _OMODELGRID on AOMS003 DT().
Lucas Borges | 08/10/24 | Chamado 48465. Retirada manipula��o do SX1 e mudanca para D_E_L_E_T_ = ' '
Lucas Borges | 24/07/25 | Chamado 51340. Ajustar fun��o para valida��o de ambiente de teste
===========================================================================================================================================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Altera��o
===========================================================================================================================================================================================================================================================
Vanderlei- Alex Wallauer - 29/09/24 - 29/09/24 -  47942  - Corre��o do error.log (cannot find fun ction ALTRIM) da Parte 1.
Vanderlei- Alex Wallauer - 16/08/24 - 15/10/24 -  47942  - Ajustes na gravacao das Previs�es de entrega via ocorrencia. Parte 2.
Bremmer  - Alex Wallauer - 30/09/24 - 15/10/24 -  48653  - Cria��o do campo ZZL_EXOCRD de controle de delecao da linha de ocorrencia vinda do RDC.
Jerry    - Alex Wallauer - 01/10/24 - 15/10/24 -  48636  - Criado o campo ZEL_DIAUTI para definir se conta o S�bado para entrega ou n�o.
Vanderlei- Alex Wallauer - 01/10/24 - 15/10/24 -  48138  - Tratamento do Local de Embarque (ZG5_LOCEMB) no cadastro de Transit Time.
Jerry    - Alex Wallauer - 17/10/24 - 17/10/24 -  48636  - Corre��o do error.log (variable is not an object  on U_AOMS3 DTSF2(AOMS003.PRW) line:5601).
Jerry    - Alex Wallauer - 22/10/24 - 23/10/24 -  48636  - Corre��o da fun��o AOMS3DTSF2 () para funcionar com a filial da ocorrencia quando via WS
Bremmer  - Igor Melga�o  - 23/10/24 - 24/10/24 -  48911  - Ajuste antes de execauto para verficar se fornecedor esta bloqueado.
Vanderlei- Alex Wallauer - 28/11/24 - 29/11/24 -  48126  - Ajuste das datas _dZF5DTOCOR >= _dF2EMISSAO e_dZF5DTOCOR >= _dF2EMISSAO, e corre��o de erro.log.
Jerry    - Alex Wallauer - 22/01/25 - 05/02/25 -  49663  - Novo tratamento do campo ZF5_CHVNDT da chave do Titulo NDT para gravar a parcela.
Jerry    - Alex Wallauer - 19/12/25 - 20/03/25 -  49126  - Novos ajustes na grava��o das datas do SF2 na fun��o U_AOMS3 DTSF2().
Antonio  - Igor Melga�o  - 16/01/25 - 20/03/25 -  47833  - Ajustes para valida��o e inclus�o de dados na ZM4 para aprova��o de prorroga��o de vecto
Jerry    - Alex Wallauer - 10/02/25 - 20/03/25 -  49042  - Ajustes para trartar notas ficais de Transferencia de troca nota. 
Jerry    - Alex Wallauer - 24/03/25 - 24/03/25 -  49126  - Novos ajustes na grava��o das datas do SF2 na fun��o U_AOMS3 DTSF2().
Alex     - Alex Wallauer - 25/03/25 - 25/03/25 -  50297  - Corre��o do error.log: variable does not exist _OMODELGRID on U_AOMS00 3N()line:4350).
Alex     - Alex Wallauer - 26/03/25 - 26/03/25 -  49966  - Corre��o do error.log: variable does not exist _DF2EMISSAO on U_AOMS3D TSF2()line:5557.
Antonio  - Igor Melga�o  - 03/04/25 - 03/04/25 -  47833  - Ajustes para valida��o e inclus�o de dados na ZM4 para aprova��o de prorroga��o de vecto
Vanderlei- Alex Wallauer - 09/04/25 - 09/04/25 -  50428  - Liberacao do tipo = F para alteracao da data independe do  tipo de agendamento
Antonio  - Igor Melga�o  - 03/04/25 - 14/04/25 -  47833  - Ajustes para inclus�o de dados na ZM4 para aprova��o de prorroga��o de vecto
Lucas    - Igor Melga�o  - 02/05/25 - 02/05/25 -  50525  - Ajuste para remo��o de diret�rio local C:\SMARTCLIENT\.
Vanderlei- Alex Wallauer - 07/05/25 - 08/05/25 -  50639  - Corre��o no calculo da data de previs�o de entrega no cliente que era alterada indevidamente na ocorr�ncia integrada do RDC.
Antonio  - Igor Melga�o  - 17/07/25 - 18/07/25 -  51095  - Ajustes para nova tratativa para inclus�o de Ocorrencias de Prorroga��o de Vecto.
Jerry    - Igor Melga�o  - 21/07/25 - 21/07/25 -  51475  - Ajustes para corre��o de envio de e-mail.
===========================================================================================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"
#Include "FwMVCDef.ch"
#Include "RWMAKE.CH"
#Include "TopConn.ch"
#Include "ap5mail.ch"

Static _aItOcorre := {}
Static _lMOMS016  := .F.
Static _lEmail    := .F.
Static _aDadosEmailCom:={}

/*
===============================================================================================================================
Programa--------: AOMS003
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 18/04/2016
Descri��o-------: Cadastro de ocorr�ncias de frete - Chamado 15345
Parametros------: cFilter - Quando chamado de um bot�o "Ocorr�ncias de frete"
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AOMS003(cFilter As char)
 Private _oBrowse := Nil
 Private _lUsaMVC := .T.
 Private _cNomeFonte := "AOMS003"
 Private _lEnviou := .F.

 Public _cRetorno := "   "

 Default cFilter := ""

 _lMOMS016 := FWIsInCallStack("U_MOMS016") .OR. FWIsInCallStack("SPEDNFE")

 //====================================================================================================
 // Configura e inicializa a Classe do Browse
 //====================================================================================================
 _oBrowse := FWMBrowse():New()

 _oBrowse:SetAlias( "ZF5" )
 _oBrowse:SetMenuDef( 'AOMS003' )
 _oBrowse:SetDescription( "Ocorr�ncias de frete" )

 //====================================================================================================
 // Montagem das legendas
 //====================================================================================================
 _oBrowse:AddLegend('POSICIONE("ZFD",1,xFilial("ZFD")+ZF5->ZF5_STATUS,"ZFD_STATUS")=="P"',"GREEN", "Pendente" )
 _oBrowse:AddLegend('POSICIONE("ZFD",1,xFilial("ZFD")+ZF5->ZF5_STATUS,"ZFD_STATUS")=="E"',"RED",   "Efetivado" )
 _oBrowse:AddLegend('POSICIONE("ZFD",1,xFilial("ZFD")+ZF5->ZF5_STATUS,"ZFD_STATUS")=="N"',"GRAY",  "N�o Procede" )
 _oBrowse:AddLegend('POSICIONE("ZFD",1,xFilial("ZFD")+ZF5->ZF5_STATUS,"ZFD_STATUS")=="T"',"YELLOW","Em tratamento" )

 If !Empty(cFilter)
    _oBrowse:SetFilterDefault( cFilter )
 EndIf

 _oBrowse:Activate()

Return()

/*
===============================================================================================================================
Programa--------: MenuDef
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 13/04/2016
Descri��o-------: Rotina de defini��o autom�tica do menu via MVC
Parametros------: Nenhum
Retorno---------: aRotina - Defini��es do menu principal da Rotina.
===============================================================================================================================
*/
Static Function MenuDef()

 Local _aRot := {}

 If !_lMOMS016
    //ADICIONANDO OP��ES
    ADD OPTION _aRot TITLE 'Visualizar'      ACTION 'VIEWDEF.AOMS003' 	                            OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION _aRot TITLE 'Legenda'         ACTION 'U_AOMS003H' 		                            OPERATION 6                      ACCESS 0 //OPERATION 6
    ADD OPTION _aRot TITLE 'Incluir'         ACTION 'VIEWDEF.AOMS003' 	                            OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION _aRot TITLE 'Incl.por Carga'  ACTION 'U_AOMS072' 	                                OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION _aRot TITLE 'Alterar'         ACTION 'VIEWDEF.AOMS003' 	                            OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION _aRot TITLE 'Excluir'         ACTION 'VIEWDEF.AOMS003' 	                            OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    ADD OPTION _aRot TITLE 'Imprimir capa'   ACTION 'U_ROMS041' 		                            OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION _aRot TITLE 'Imprimir NDT'    ACTION 'U_ROMS055I' 	                                OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION _aRot TITLE 'Aviso Devolu��o' ACTION 'U_AOMS003J(ZF5->ZF5_DOCOC,ZF5->ZF5_SEROC)' 	OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION _aRot TITLE 'Canhoto'         ACTION 'U_VISCANHO( ZF5->ZF5_FILIAL, ZF5->ZF5_DOCOC )' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION _aRot TITLE 'Encerra Multip'  ACTION 'U_AOMS03M(.F.)'                                OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION _aRot TITLE "Atualiza Telefones" ACTION 'U_AOMS03M(.T.)' 	                        OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
 Else
    ADD OPTION _aRot TITLE 'Visualizar'      ACTION 'VIEWDEF.AOMS003' 	                            OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION _aRot TITLE 'Legenda'         ACTION 'U_AOMS003H' 		                            OPERATION 6                      ACCESS 0 //OPERATION 6
 EndIf

Return _aRot

/*
===============================================================================================================================
Programa--------: ModelDef
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 13/04/2016
Descri��o-------: Rotina de defini��o do Modelo de Dados do MVC
Parametros------: Nenhum
Retorno---------: oModel - Objeto do modelo de dados do MVC
===============================================================================================================================
*/
Static Function ModelDef()

 //====================================================================================================
 // Inicializa a estrutura do modelo de dados
 //====================================================================================================
 Local _oStrCAB	:= FWFormStruct( 1 , "ZF5" , {|_cCampo| AOMS003CPO( _cCampo , 1 ) } )
 Local _oStrITN	:= FWFormStruct( 1 , "ZF5" , {|_cCampo| AOMS003CPO( _cCampo , 2 ) } )
 Local _oModel	  As object
 Local _bValid	  As block
 Local _bLinePre  As block
 Local _bLinePost As block
 Local _bCommit   As block

 _oStrITN:AddField( ;
        '' , ;                      // [01] C Titulo do campo                                                 //cTitulo	 Caracteres	Titulo do campo	    X
        "LEGENDA", ;                // [02] C ToolTip do campo                                                //cTooltip Caracteres	Tooltip do campo    X
        "LEGENDA", ;                // [03] C identificador (ID) do Field                                     //cIdField Caracteres	Id do Field	        X
        'C' , ;                     // [04] C Tipo do campo                                                   //cTipo	 Caracteres	Tipo do campo	    X
        50  , ;                     // [05] N Tamanho do campo                                                //nTamanho Num�rico	Tamanho do campo    X
        0   , ;                     // [06] N Decimal do campo                                                //nDecimal Num�rico	Decimal do campo    0
        NIL , ;                     // [07] B Code-block de valida��o do campo                                //bValid	 CodeBlock  Bloco de c�digo de valida��o do campo {|| .T.}
        NIL , ;                     // [08] B Code-block de valida��o When do campo                           //bWhen    CodeBlock	Bloco de c�digo de valida��o when do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo                             //aValues	 Array	    Lista de valores permitido do campo	{}
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigat�rio                 //lObrigat L�gico	    Indica se o campo tem preenchimento obrigat�rio	.F.
        { || AOMS03Leg(.T.) } , ;   // [11] B Code-block de inicializacao do campo                            //bInit	 CodeBlock	Bloco de c�digo de inicializa��o do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave                               //lKey	 L�gico	    Indica se trata-se de um campo chave X
        .F. , ;                     // [13] L Indica se o campo pode receber valor em uma opera��o de update. //lNoUpd	 L�gico	    Indica se o campo n�o pode receber valor em uma opera��o de update	.F.
        .T. )                       // [14] L Indica se o campo � virtual                                     //lVirtual L�gico	    Indica se o campo � virtual	.F.
                                                                                                              //cValid	 Caracteres	Valid do usu�rio em formato texto e sem altera��o, usado para se criar o aHeader de compatibilidade	""

 _bValid := {|_oModel| U_AOMS003Q(_oModel)}
 _bCommit:= {|_oModel| U_AOMS003O(_oModel)}

 //====================================================================================================
 // Inicializa e configura o modelo de dados
 //====================================================================================================
 //oModel := MPFormModel():New('ASATF04M'  , /*bPreValidacao*/                                 , {|oModel| fValidGrid(oModel)}, /*bCommit*/, /*bCancel*/ )
 _oModel  := MPFormModel():New( 'AOMS003M' , /*{|_oModel| U_AOMS03MP(_oModel)}/*Pr�-Valida��o*/, _bValid                      , _bCommit)

 _oModel:SetDescription( 'Ocorr�ncias de Frete' )

 _oModel:AddFields( 'ZF5MASTER' ,, _oStrCAB )

 _bLinePre  := {|_oModel, _nLine, _cAction, _cField| U_AOMS003P(_oModel, _nLine, _cAction, _cField)}
 _bLinePost := {|_oModel, _nLine, _cAction, _cField| U_AOMS003N(_oModel, _nLine, _cAction, _cField)}
 //      AddGrid(<cId >     ,<cOwner >  ,<oModelStruct, _bLinePre, _bLinePost , _bPre > , _bLinePost >, _bLoad >)
 _oModel:AddGrid('ZF5DETAIL',"ZF5MASTER",_oStrITN     ,          ,_bLinePost  ,_bLinePre,/*bProsGrid*/ )

 _oModel:GetModel( 'ZF5MASTER' ):SetDescription( 'Dados da Nota Fiscal'	)
 _oModel:GetModel( 'ZF5DETAIL' ):SetDescription( 'Dados das Ocorrencias de Frete'	)

 _oModel:SetRelation( "ZF5DETAIL" , {	{ "ZF5_FILIAL",'xFilial("ZF5")'},;
                                       { "ZF5_DOCOC" ,"ZF5_DOCOC"     },;
                                       { "ZF5_SEROC" ,"ZF5_SEROC"     }}, ZF5->( IndexKey( 1 ) ) )

 _oModel:GetModel( 'ZF5DETAIL' ):SetUniqueLine( { 'ZF5_CODIGO' } )

 _oModel:SetPrimaryKey( { 'ZF5_FILIAL' , 'ZF5_DOCOC' , 'ZF5_SEROC', 'ZF5_CODIGO' } )

Return( _oModel )

/*
===============================================================================================================================
Programa--------: ViewDef
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 13/04/2016
Descri��o-------: Rotina de defini��o da View do MVC
Parametros------: Nenhum
Retorno---------: oView - Objeto de exibi��o do MVC
===============================================================================================================================
*/
Static Function ViewDef()

 Local _oStrCAB:= FWFormStruct( 2 , "ZF5" , {|_cCampo| AOMS003CPO( _cCampo , 1 ) } )
 Local _oStrITN:= FWFormStruct( 2 , "ZF5" , {|_cCampo| AOMS003CPO( _cCampo , 2 ) } )
 Local _oModel	:= FWLoadModel( "AOMS003" )
 Local _oView	:= Nil

 _oStrITN:AddField( ;                           // Ord. Tipo Desc.
        'LEGENDA'                       , ;     // [01] C   Nome do Campo
        "00"                            , ;     // [02] C   Ordem
        ''                              , ;     // [03] C   Titulo do campo
        ''                              , ;     // [04] C   Descricao do campo
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

 //====================================================================================================
 // Inicializa o Objeto da View
 //====================================================================================================
 _oView := FWFormView():New()

 _oView:SetModel( _oModel )

 _oView:AddField( "VIEW_CAB" , _oStrCAB , "ZF5MASTER" )
 _oView:AddGrid(  "VIEW_ITN" , _oStrITN , "ZF5DETAIL" )

 _oView:CreateHorizontalBox( 'BOX0101' , 070 )
 _oView:CreateHorizontalBox( 'BOX0102' , 030 )

 _oView:SetOwnerView( "VIEW_CAB" , "BOX0101" )
 _oView:SetOwnerView( "VIEW_ITN" , "BOX0102" )


Return( _oView )


/*
===============================================================================================================================
Programa--------: AOMS003CPO
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 13/04/2016
Descri��o-------: Configura��o da inicializa��o de campos na tela
Parametros------: _cCampo: list de campos    ; _nOpc : inverte a lista
Retorno---------: oView - Objeto de exibi��o do MVC
===============================================================================================================================
*/
Static Function AOMS003CPO( _cCampo , _nOpc )
 Local _ccampos := ""
 Local _lRet := .F.

 _ccampos := 'ZF5_DOCOC;'
 _ccampos += 'ZF5_SEROC;'
 _ccampos += 'ZF5_REPRES;'
 _ccampos += 'ZF5_DATAE;'
 _ccampos += "ZF5_ASSNOM;"
 _ccampos += 'ZF5_VLRFRE;'
 _ccampos += 'ZF5_AGENDA;'
 _ccampos += 'ZF5_VOLUM;'
 _ccampos += 'ZF5_PEDIDO;'
 _ccampos += 'ZF5_TIPOV;'
 _ccampos += 'ZF5_COORD;'
 _ccampos += 'ZF5_NCOOR;'
 _ccampos += 'ZF5_CLIENT;'
 _ccampos += 'ZF5_NREPRE;'
 _ccampos += 'ZF5_PESON;'
 _ccampos += 'ZF5_LOJA;'
 _ccampos += 'ZF5_NCLIEN;'
 _ccampos += 'ZF5_UF;'
 _ccampos += 'ZF5_CIDADE;'
 //_ccampos += 'ZF5_TRANSP;' - Foi para os itens
 //_ccampos += 'ZF5_NTRANS;' - Foi para os itens
 //_ccampos += 'ZF5_LJTRAN;' - Foi para os itens
 _ccampos += 'ZF5_SEQCAR;'
 _ccampos += 'ZF5_CARGA;'
 _ccampos += 'ZF5_MOTORI;'
 _ccampos += 'ZF5_DMOTOR;'
 _ccampos += 'ZF5_VEICUL;'
 _ccampos += 'ZF5_DVEICU;'
 _ccampos += 'ZF5_DTCAR;'
 _ccampos += 'ZF5_PESO;'
 _ccampos += 'ZF5_DATAL;'
 _ccampos += 'ZF5_HORAL;'
 _ccampos += 'ZF5_DATAC;'
 _ccampos += 'ZF5_HORAC;'
 _ccampos += 'ZF5_RPCOM;'
 _ccampos += 'ZF5_RPLOGI;'
 _ccampos += 'ZF5_NRPCO;'
 _ccampos += 'ZF5_NRPLO;'
 _ccampos += 'ZF5_OBSFR;'
 _ccampos += 'ZF5_POSTOF;'
 _ccampos += 'ZF5_TELEFO;'
 _ccampos += 'ZF5_DAE;'
 _ccampos += 'ZF5_VALORI;'
 _ccampos += 'ZF5_SENHAM;'
 _ccampos += 'ZF5_OBSPF;'
 _ccampos += 'ZF5_PLACA;'
 _ccampos += 'ZF5_DATAS;'
 _ccampos += 'ZF5_HORAS;'
 _ccampos += "ZF5_GERENT;"
 _ccampos += "ZF5_NGEREN;"
 _ccampos += "ZF5_MERENT;"
 _ccampos += "ZF5_SITENT;"
 _ccampos += "ZF5_OPRLOG;"
 _cCampos += "ZF5_LOJOPE;"
 _cCampos += "ZF5_CGCOPR;"
 _cCampos += "ZF5_NOMOPE;"
 _cCampos += "ZF5_ESTOPE;"
 _cCampos += "ZF5_MUNOPE;"
 _cCampos += "ZF5_DDDOPE;"
 _cCampos += "ZF5_TELOPE;"

 _lret := Alltrim(_cCampo) $ _ccampos

 If _nOpc == 2
     _lRet := !_lRet
 EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa--------: AOMS003Z
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 13/04/2016
Descri��o-------: Gatilha campos autom�ticos do cabe�alho
Parametros------: _ccampo - nome do campo a ser preenchido
                  _nopc   - 1 usa M->ZF5_DOCOC
                            2 usa ZF5->ZF5_DOCOC
Retorno---------: _cret - valor do campo
===============================================================================================================================
*/
User Function AOMS003Z(_ccampo,_nopc)
 Local _cret := ""
 Local _cret3 := ""
 Local _cret4 := ""
 Local _cdococ := ""
 Local _aOrd := SaveOrd({"SF2","ZFC"})
 Local _cCarga, _cMotorista //, _cOPer
 Local _oModel
 Local _oModelMaster
 Local _oModelGrid
 Local _cTipoOcorr, _cFornece

 Default _nopc := 1

 If ! isincallstack("U_AOMS03M") .AND. !isincallstack("U_AOMS072I")
    _oModel       := FWModelActive()
    _oModelMaster := _oModel:GetModel("ZF5MASTER")//Sempre teste se a variavel valtype(_oModelMaster) = "O" ao usar abaixo para previnir
    _oModelGrid   := _oModel:GetModel("ZF5DETAIL")//Sempre teste se a variavel valtype(_oModelGrid)   = "O" ao usar abaixo para previnir
    M->ZF5_SEROC  := ALLTRIM(_oModelMaster:GetValue('ZF5_SEROC'))
 EndIf

 IF _NOPC == 1 .AND. !inclui//VISUAL
    _cSerie := ZF5->ZF5_SEROC
    _cdococ := ZF5->ZF5_DOCOC+_cSerie
    M->ZF5_DOCOC:=ZF5->ZF5_DOCOC
 ELSEIF _NOPC == 2 .OR. inclui//INCLUSAO E CHAMDO DO AOMS072.PRW TB
    _cSerie := ALLTRIM(M->ZF5_SEROC)
    _cdococ := M->ZF5_DOCOC+_cSerie
 ELSEIF _NOPC == 3//ALTERACAO
    ZF5->(DBGOTO( (cAliasAux)->REC_ZF5 ))
    _cSerie := ZF5->ZF5_SEROC
    _cdococ := ZF5->ZF5_DOCOC+_cSerie
    M->ZF5_DOCOC:=ZF5->ZF5_DOCOC
 EndIf

 SF2->(DbSetOrder(1))
 SF2->(DbSeek(xFilial("SF2")+ALLTRIM(_cdococ)))

 If _ccampo == "ZF5_DATAE"
    _cret := POSICIONE("SC5",,XFILIAL("SC5")+M->ZF5_DOCOC,"C5_I_DTENT","IT_NOTA")
 ELSEIf _ccampo == "ZF5_ASSNOM"
    _cret := POSICIONE("SC5",,XFILIAL("SC5")+M->ZF5_DOCOC,"C5_ASSNOM","IT_NOTA")
 EndIf

 If _ccampo == "ZF5_CARGA"
    If ! Empty(SF2->F2_CARGA)
       _cret := SF2->F2_CARGA
    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_SEQCAR"
    If ! Empty(SF2->F2_SEQCAR)
       _cret := SF2->F2_SEQCAR
    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_MOTORI"
    If ! Empty(SF2->F2_CARGA)
        _cret := Posicione("DAK",1,xFilial("ZF5")+SF2->F2_CARGA,"DAK_MOTORI")
    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_DMOTOR"
    If !Empty(SF2->F2_CARGA)
       _cret := Substr(alltrim(POSICIONE("DA4",1,XFILIAL("DA4")+POSICIONE("DAK",1,XFILIAL("ZF5")+ALLTRIM(SF2->F2_CARGA),"DAK_MOTORI") ,"DA4_NOME")),1,30)
          _cret3 := STRTRAN(STRTRAN(ALLTRIM(POSICIONE("DA4",1,XFILIAL("DA4")+POSICIONE("DAK",1,XFILIAL("ZF5")+ALLTRIM(SF2->F2_CARGA),"DAK_MOTORI") ,"DA4_TEL")),"-","")," ","")
          _cret3 := STRTRAN(_cret3,".","")
       _cret4:=""
       IF LEFT(_cret3,1) = "0"
          _cret3 := SUBSTR(_cret3,2)//Tiro o zero
          _cret4 := " - (" + LEFT(_cret3,2) + ") "
          _cret  += _cret4 + SUBSTR(_cret3,3)
       ELSEIF LEN(_cret3) > 9  .AND. LEN(_cret3) < 12
          _cret4 := " - (" + LEFT(_cret3,2) + ") "
          _cret  += _cret4 + SUBSTR(_cret3,3)
       ELSE
          _cret  += " - " + _cret3
       EndIf

    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_VEICUL"
    If ! Empty(SF2->F2_CARGA)
       _cret := Posicione("DAK",1,xFilial("ZF5")+AllTrim(SF2->F2_CARGA),"DAK_CAMINH")
    Else
       _cret :=  ""
    EndIf
 EndIf

 If _ccampo == "ZF5_DVEICU"
    If ! Empty(SF2->F2_CARGA)
       _cret3 := Posicione("DAK",1,xFilial("ZF5")+SF2->F2_CARGA,"DAK_CAMINH")
       _cret := Posicione("DA3",1,xFilial("DA3")+alltrim(_cret3),"DA3_DESC")
    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_PLACA"
    If ! Empty(SF2->F2_CARGA)
       _cret3 := Posicione("DAK",1,xFilial("ZF5")+AllTrim(SF2->F2_CARGA),"DAK_CAMINH")
       _cret := Posicione("DA3",1,xFilial("DA3")+AllTrim(_cret3),"DA3_PLACA")
    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_DTCAR"
    If ! Empty(SF2->F2_CARGA)
       _cret := Posicione("DAK",1,xFilial("ZF5")+AllTrim(SF2->F2_CARGA),"DAK_DATA")
    Else
       _cret := CTod("")
    EndIf
 EndIf

 If _ccampo == "ZF5_PESO"
    If ! Empty(SF2->F2_CARGA)
       _cret  := Posicione("DAK",1,xFilial("ZF5")+SF2->F2_CARGA,"DAK_PESO")
    Else
       _cret := 0
    EndIf
 EndIf

 If _ccampo == "ZF5_REPRES"
    If ! Empty(SF2->F2_VEND1)
       _cret := SF2->F2_VEND1
    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_NREPRE"
    If !Empty(SF2->F2_VEND1)
        _cret := Substr(alltrim(POSICIONE("SA3",1,XFILIAL("SA3")+SF2->F2_VEND1,"A3_NOME")),1,30)
        _cret3 := ALLTRIM(POSICIONE("SA3",1,XFILIAL("SA3")+SF2->F2_VEND1,"A3_TEL"))
        _cret4 := ALLTRIM(POSICIONE("SA3",1,XFILIAL("SA3")+SF2->F2_VEND1,"A3_DDDTEL"))

      _cret += " - (" + _cret4 + ") " + _cret3
    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_COORD"
    If ! Empty(SF2->F2_VEND2)
       _cret := SF2->F2_VEND2
    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_NCOOR"
    If ! Empty(SF2->F2_VEND2)
       _cret  := Substr(Alltrim(Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND2,"A3_NOME")),1,30)
       _cret3 := Alltrim(Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND2,"A3_TEL"))
       _cret4 := Alltrim(Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND2,"A3_DDDTEL"))
       _cret  += " - (" + _cret4 + ") " + _cret3
    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_CLIENT"
    If ! Empty(SF2->F2_CLIENTE)
       _cret := SF2->F2_CLIENTE
    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_LOJA"
    If ! Empty(SF2->F2_LOJA)
       _cret := SF2->F2_LOJA
    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_NCLIEN"
    If !Empty(SF2->F2_CLIENTE)
       _cret  := Substr(Alltrim(Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NREDUZ")),1,30)
       _cret3 := AllTrim(Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_TEL"))
       _cret4 := AllTrim(Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_DDD"))
       _cret += " - (" + _cret4 + ") " + _cret3
    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_UF"
    If ! Empty(SF2->F2_EST)
       _cret := SF2->F2_EST
    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_SEROC"
    If ! Empty(SF2->F2_SERIE)
       _cret := SF2->F2_SERIE
    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_CIDADE"
    If ! Empty(SF2->F2_CLIENTE)
        _cret := Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_MUN")
    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_PESON"
    If ! Empty(SF2->F2_PBRUTO)
       _cret := SF2->F2_PBRUTO
    Else
       _cret := 0
    EndIf
 EndIf

 If _ccampo == "ZF5_VOLUM"
    If ! Empty(SF2->F2_VOLUME1)
       _cret := Transform(SF2->F2_VOLUME1,"@E 999,999")
       _cret += "  " + AllTrim(SF2->F2_ESPECI1)
    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_TIPOV"
    If ! Empty(SF2->F2_CARGA)
       _cret3 := Posicione("DAK",1,xFilial("ZF5")+SF2->F2_CARGA,"DAK_CAMINH")
       _cret := Posicione("DA3",1,xFilial("DA3")+Alltrim(_cret3),"DA3_I_TPVC")
    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_VLRFRE"
    If ! Empty(SF2->F2_I_FRET)
       _cret := SF2->F2_I_FRET
    Else
       _cret := 0
    EndIf
 EndIf

 If _ccampo == "ZF5_PEDIDO"
    If ! Empty(SF2->F2_I_PEDID)
       _cret := 	SF2->F2_I_PEDID
    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_GERENT"
    If ! Empty(SF2->F2_VEND3)
       _cret := SF2->F2_VEND3
    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_NGEREN"
    If ! Empty(SF2->F2_VEND3)
        _cret  := Substr(alltrim(POSICIONE("SA3",1,XFILIAL("SA3")+SF2->F2_VEND3,"A3_NOME")),1,30)
        _cret3 := ALLTRIM(POSICIONE("SA3",1,XFILIAL("SA3")+SF2->F2_VEND3,"A3_TEL"))
        _cret4 := ALLTRIM(POSICIONE("SA3",1,XFILIAL("SA3")+SF2->F2_VEND3,"A3_DDDTEL"))

      _cret += " - (" + _cret4 + ") " + _cret3
    Else
       _cret := ""
    EndIf
 EndIf

 If _ccampo == "ZF5_RPCOM" .And. ! isincallstack("U_AOMS03M")
    _cret := Embaralha(Posicione("SC5",,xFilial("SC5")+M->ZF5_DOCOC,"C5_USERLGI","IT_NOTA"),1)
    _cret := SubStr(_cret,3,6)
    _oModelMaster:SetValue('ZF5_NRPCO',UsrRetName(_cret))
 EndIf

 If _ccampo == 'ZF5_TIPOO'
    _cTipoOcorr := M->ZF5_TIPOO
    _cret := _cTipoOcorr

    _cCarga := Posicione("SF2",1,xFilial("SF2")+AllTrim(M->ZF5_DOCOC+M->ZF5_SEROC),"F2_CARGA")
    If Empty(_cCarga) //SE TIVER CARGA PEGA DA CARGA SEN�O DO SF2
       _cFornece   := SF2->F2_I_CTRA
       _cLoja      := SF2->F2_I_LTRA
       _cNome      :=  Posicione("SA2",1,xFilial("SA2")+_cFornece+_cLoja, "A2_NREDUZ")
    ELSE
       _cMotorista := Posicione("DAK",1,xFilial("DAK")+_cCarga,"DAK_MOTORI")
       _cFornece   := Posicione("DA4",1,xFilial("DA4")+_cMotorista, "DA4_FORNEC")
       _cLoja      := DA4->DA4_LOJA
       _cNome      := Posicione("SA2",1,xFilial("SA2")+_cFornece+_cLoja, "A2_NREDUZ")
    EndIf
    IF VALTYPE(_oModelGrid) = "O"
       _oModelGrid:LoadValue("ZF5_TRANSP",_cFornece)
       _oModelGrid:LoadValue("ZF5_LJTRAN",_cLoja)
       _oModelGrid:LoadValue("ZF5_NTRANS",_cNome)
    EndIf
 EndIf


 If _ccampo == 'ZF5_TIPOC'
    _cTipoOcorr := M->ZF5_TIPOO
    _cret := ""

    If ! Empty(_cTipoOcorr)
       ZFC->(DbSetOrder(1))
       ZFC->(DbSeek(xFilial("ZFC")+_cTipoOcorr))
       _cret := ZFC->ZFC_CUSTO
       RestOrd(_aOrd)
    EndIf
 EndIf

 If _ccampo == 'ZF5_DEVOL'
    _cTipoOcorr := M->ZF5_TIPOO
    _cret := ""

    If ! Empty(_cTipoOcorr)
       ZFC->(DbSetOrder(1))
       ZFC->(DbSeek(xFilial("ZFC")+_cTipoOcorr))
       _cret := ZFC->ZFC_DEVOL
       RestOrd(_aOrd)
    EndIf
 EndIf

 If _ccampo == 'ZF5_SERVIC'
    _cTipoOcorr := M->ZF5_TIPOO
    _cret := ""

    If ! Empty(_cTipoOcorr)
       ZFC->(DbSetOrder(1))
       ZFC->(DbSeek(xFilial("ZFC")+_cTipoOcorr))
       _cret := ZFC->ZFC_SERVI
       RestOrd(_aOrd)
    EndIf
 EndIf

If _ccampo == 'ZF5_RPLOGI' .And. ! fwIsInCallStack("U_AOMS03M")
    _cret := AllTrim(U_ITGETMV( 'IT_RESPLOG' , ''))
    _oModelMaster:SetValue('ZF5_NRPLO',UsrRetName(_cret))
 EndIf

Return _cret

/*
===============================================================================================================================
Programa--------: AOMS003H
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 13/04/2016
Descri��o-------: Legenda para o fwbrowse principal
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AOMS003H()
 Local aLegenda := {}
 //Monta as cores
 AADD(aLegenda,{"BR_VERDE",   "Pendente"  })
 AADD(aLegenda,{"BR_VERMELHO","Encerrada"})
 AADD(aLegenda,{"BR_CINZA",   "N�o Procede"})
 AADD(aLegenda,{"BR_AMARELO", "Em tratamento"})
 BrwLegenda("Ocorr�ncias de Frete", "Frete", aLegenda)

Return

/*
===============================================================================================================================
Programa--------: AOMS003K
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 13/04/2016
Descri��o-------: Inicializa c�digo da ocorrencia
Parametros------: _lUsaMVC - Indica se a rotina que chamou esta fun��o utiliza MVC (True), ou n�o utiliza MVC (False)
                  _cNomeFonte - Nome do fonte que chamou esta fun��o.
Retorno   ------: _cret - novo c�digo de ocorr�ncia
===============================================================================================================================
*/
User Function AOMS003K(_lUsaMVC, _cNomeFonte)
 Local _cret := "000001"
 Local _oModel
 Local _oModelGrid

 Default _lUsaMVC := .T., _cNomeFonte := "AOMS003"

 Begin Sequence
   If _lUsaMVC .And. _cNomeFonte == "AOMS003"
      _oModel      := FwModelActivete()
      _oModelGrid  := _oModel:GetModel("ZF5DETAIL")

      _nUltReg:=_oModelGrid:Length()
      IF _nUltReg > 0
         _oModelGrid:GoLine(_nUltReg)
         _nProx:=VAL(_oModelGrid:GetValue('ZF5_CODIGO'))+1
      ELSE
         _nProx:=_oModelGrid:GetLine()+1
      EndIf

      _cret := StrZero(_nProx,6)

   ElseIf !  _lUsaMVC .And. _cNomeFonte == "AOMS072"
      _cret := StrZero(Len(aCols),6)
   EndIf

 End Sequence

Return _cret

/*
===============================================================================================================================
Programa--------: AOMS003V
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 13/04/2016
Descri��o-------: Valida numero de nota duplicado
Parametros------: Nenhum
Retorno   ------: L�gico validando ou n�o o numero de nota
===============================================================================================================================
*/
User Function AOMS003V()
 Local _lret := .T. As Logical
 Local _cQuery := "" As Character
 Local cAlias:=GetNextAlias() As Character

 _cQuery := " SELECT ZF5_TRANSP,ZF5_LJTRAN,ZF5_NTRANS"
 _cQuery += " FROM " + RetSqlName("ZF5") + " ZF5"
 _cQuery += " WHERE ZF5.ZF5_FILIAL = '" + xFilial("ZF5") + "'"
 _cQuery += " AND ZF5.ZF5_DOCOC = '" + M->ZF5_DOCOC + "'"
 _cQuery += " AND ZF5.D_E_L_E_T_ = ' ' "

 MPSysOpenQuery( _cQuery , cAlias)

 _ctransp := ""

 Do while .not. (cAlias)->( Eof() )

    IF !(cAlias)->ZF5_TRANSP + "/" + (cAlias)->ZF5_LJTRAN $ _ctransp
        _ctransp += (cAlias)->ZF5_TRANSP + "/" + (cAlias)->ZF5_LJTRAN + " - " + ALLTRIM((cAlias)->ZF5_NTRANS) + CHR(10) +CHR(13)
    EndIf

     (cAlias)->(Dbskip())

 Enddo

 (cAlias)->( Dbclosearea() )

 If len(_ctransp) > 0

    (U_ITMSG("J� existe ocorr�ncia para nota!","Aten��o",;
             "Ocorr�ncia, j� cadastrada para o(s) transportador(es) abaixo, " + ;
             ", para adicionar eventos nesse(s) transportador(s) ou outro use a op��o alterar:" + chr(10) + chr(13) + _ctransp ,,,,.T.))
    _lret := .F.

 EndIf

 If _lret
 
    _cSeek := M->ZF5_DOCOC+ALLTRIM(M->ZF5_SEROC)
    SF2->(DbSetOrder(1))
    IF SF2->(DbSeek(xFilial("SF2")+_cSeek)) .AND. SF2->F2_CLIENTE = "000001"
       IF (Posicione("SC5",,xFilial("SC5")+M->ZF5_DOCOC,"C5_I_TRCNF","IT_NOTA") = "S") .AND. SC5->C5_I_OPER = "20"
          _cSeekPV:=SC5->C5_I_FILFT+SC5->C5_I_PDFT
          cNotaFat:=POSICIONE("SC5",1,_cSeekPV,"C5_NOTA")
          cNotaFat:=SC5->C5_FILIAL+" "+cNotaFat+" - "+SC5->C5_SERIE
          U_ITMSG("Inclus�o de Ocorr�ncia de Nfe de Transfer�ncia, somente permitido para Nota de Venda vinculada a transfer�ncia","Aten��o","NFe de Venda vinculada: "+cNotaFat,,,,.T.)
          _lret := .F.
       EndIf
    EndIf

 EndIf

Return _lret

/*
===============================================================================================================================
Programa--------: AOMS003W
Autor-----------: Julio de Paula Paz
Data da Criacao-: 02/06/2016
Descri��o-------: Define tratamentos para campos, de acordo com o campo passado como par�metro, como fazer inicializa��o
                  padr�o, validar campos,
Parametros------: _cCampo = campo que chamou a rotina.
Retorno   ------: True ou False,valores de inicaliza��o de campos.
===============================================================================================================================
*/
User Function AOMS003W(_cCampo,_lMVC,_cFonte)
 Local _lxRet := .T.
 Local _oModel           := FwModelActivete()
 Local _oModelGrid       := _oModel:GetModel("ZF5DETAIL")
 Local _oModelMaster     := _oModel:GetModel("ZF5MASTER")
 Local _lCustoPreenchido := .T.
 Local _cCodFor, _cLojaFor, _cNomeFor, _nCustoTer
 Local _aOrd := SaveOrd({"SA2","SF2","SC5"})
 Local _cForPadrao := U_ITGETMV( 'IT_FORTERCE' , 'F046200020' ) // Como default deste par�metro est� o Fornecedor terceiro: Codigo: F04620 - Loja: 0020 - Nome: CASTROLANDA COOP AGROINDUSTRIA
 Local _cNumNf, _cSerieNf
 Local _nVlCobradoTon, _nPeso, _cCarga, _nCusto

 Default _lMVC := .T., _cFonte := "AOMS003"

 Begin Sequence
   If ! _lMVC
      If _cFonte == "AOMS072"
         _lxRet := U_AOMS072E(_cCampo)
      EndIf

      Break
   EndIf

   _nCustoTer := _oModel:GetValue( 'ZF5DETAIL', 'ZF5_CUSTER' )

   If Empty(_nCustoTer)
      _lCustoPreenchido := .F.
   EndIf

   _cCodFor  := _oModel:GetValue( 'ZF5DETAIL', 'ZF5_FORTER' )

   _cLojaFor := _oModel:GetValue( 'ZF5DETAIL', 'ZF5_LOJTER' )

   _cNomeFor := _oModel:GetValue( 'ZF5DETAIL', 'ZF5_NOMTER' )

   SA2->(DbSetOrder(1))
   SF2->(DbSetOrder(1))
   SC5->(DbSetOrder(1))

   If _cCampo == 'ZF5_CUSTER'
      If Empty(_nCustoTer)
         _oModel:LoadValue( 'ZF5DETAIL', 'ZF5_FORTER', Space(6))
         _oModel:LoadValue( 'ZF5DETAIL', 'ZF5_LOJTER', Space(4))
         _oModel:LoadValue( 'ZF5DETAIL', 'ZF5_NOMTER', Space(40))
      ElseIf Empty(_cCodFor)
         SA2->(DbSeek(xFilial("SA2")+_cForPadrao))
         _oModel:LoadValue( 'ZF5DETAIL', 'ZF5_FORTER', SA2->A2_COD)
         _oModel:LoadValue( 'ZF5DETAIL', 'ZF5_LOJTER', SA2->A2_LOJA)
         _oModel:LoadValue( 'ZF5DETAIL', 'ZF5_NOMTER', SA2->A2_NOME)
      EndIf

   ElseIf _cCampo == 'ZF5_FORTER'
      If ! _lCustoPreenchido .And. ! Empty(_cCodFor)
         U_ITMSG("O campo custo de terceiro precisa ser preenchido.","Aten��o",,1)
         _lxRet := .F.
         Break
      EndIf

      If _lCustoPreenchido
         If ! SA2->(DbSeek(xFilial("SA2")+_cCodFor))
            U_ITMSG("C�digo de Terceiro n�o cadastrado no cadastro de fornecedores.","Aten��o",,1)
            _lxRet := .F.
            Break
         Else
            _oModel:LoadValue( 'ZF5DETAIL', 'ZF5_LOJTER', SA2->A2_LOJA)
            _oModel:LoadValue( 'ZF5DETAIL', 'ZF5_NOMTER', SA2->A2_NOME)
         EndIf
      EndIf

   ElseIf _cCampo == 'ZF5_LOJTER'
      If ! _lCustoPreenchido .And. ! Empty(_cLojaFor)
         U_ITMSG("O campo custo de terceiro precisa ser preenchido.","Aten��o",,1)
         _lxRet := .F.
         Break
      EndIf

      If _lCustoPreenchido
         If ! SA2->(DbSeek(xFilial("SA2")+_cCodFor+_cLojaFor))
            U_ITMSG("C�digo+Loja de Terceiro n�o cadastrado no cadastro de fornecedores.","Aten��o",,1)
            _lxRet := .F.
            Break
         Else
            _oModel:LoadValue( 'ZF5DETAIL', 'ZF5_NOMTER', SA2->A2_NOME)
         EndIf
      EndIf

   ElseIf _cCampo == 'ZF5_NOMTER'
      If ! _lCustoPreenchido .And. ! Empty(_cNomeFor)
         U_ITMSG("O campo custo de terceiro precisa ser preenchido.","Aten��o",,1)
         _lxRet := .F.
         Break
      EndIf

   ElseIf _cCampo == 'ZF5_AGENDA'
      _cNumNf   := _oModelMaster:GetValue('ZF5_DOCOC' )
      _cSerieNf := ALLTRIM(_oModelMaster:GetValue('ZF5_SEROC' ))
      SF2->(DbSeek(xFilial("SF2")+_cNumNf+_cSerieNf))
      SC5->(DbSeek(SF2->(F2_FILIAL+F2_I_PEDIDO)))
      _oModelMaster:LoadValue('ZF5_AGENDA', AllTrim(SC5->C5_MENNOTA))
      _lxRet := AllTrim(SC5->C5_MENNOTA)

   ElseIf _cCampo == 'ZF5_VALTON'
      _nVlCobradoTon := 0
      _cCarga := POSICIONE("SF2",1,XFILIAL("SF2")+ALLTRIM(ZF5->ZF5_DOCOC+ZF5->ZF5_SEROC),"F2_CARGA")
      _nPeso  := POSICIONE("DAK",1,XFILIAL("ZF5")+ALLTRIM(_cCarga),"DAK_PESO")
      _nCusto := _oModelGrid:GetValue('ZF5_CUSTO' )

      _nVlCobradoTon  += (_nCusto / (_nPeso / 1000))
      _lxRet := _nVlCobradoTon
   Elseif _cCampo == 'ZF5_VALEMB'

      _lxRet := _oModelGrid:GetValue('ZF5_CUSTO' ) - M->ZF5_VALEMB

   Elseif _cCampo == 'ZF5_DVITEM'

      _lxret := .T.
      _lnotadev := (_oModelGrid:GetValue('ZF5_DEVOL' ) == "S" )
      _ctipoc := _oModelGrid:GetValue('ZF5_TIPOC' )

      //Se for vazio valida
      If Empty(M->ZF5_DVITEM)

         Break

      EndIf

      //Soma valores de itens selecionados para devolu��o
      If _lnotadev .and. !empty(_ctipoc)

         _cforn := alltrim(_oModelMaster:GetValue('ZF5_CLIENT'))
         _clojaf := alltrim(_oModelMaster:GetValue('ZF5_LOJA'))

      Else

         U_ITMSG("Selecione tipo de custo e marque a ocorr�ncia como devolu��o para indicar nota de devolu��o","Aten��o",,1)
         _lxret := .F.
         Break

      EndIf

      //Localiza nota de devolu��o
      SF1->(Dbsetorder(1))
      If SF1->(DbSeek(xfilial("SF1")+_oModelGrid:GetValue('ZF5_DOCDEV' )+_oModelGrid:GetValue('ZF5_SERDEV')+_cforn+_clojaf))


         SD1->(Dbsetorder(1))
         SD1->(DbSeek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))

         _lxret := .T.
         _ntotal := 0

         Do while SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA

            If SD1->D1_ITEM $ M->ZF5_DVITEM

               _ntotal += SD1->D1_TOTAL

            EndIf

            SD1->(Dbskip())

         Enddo

         If u_itgetmv("ITOCVALDEV",.F.)

            //Preenche campos de valores de acordo com a devolu��o
            _oModelGrid:SetValue('ZF5_CUSTO',_ntotal)
            _oModelGrid:SetValue('ZF5_VLRTOT',_ntotal - _oModelGrid:GetValue('ZF5_VALEMB' ))
            _oModelGrid:SetValue('ZF5_CUSTOI',0)
            _oModelGrid:SetValue('ZF5_CUSTOR',0)
            _oModelGrid:SetValue('ZF5_CUSTOC',0)
            _oModelGrid:SetValue('ZF5_CUSTOT',0)
            _oModelGrid:SetValue('ZF5_CUSTER',0)

            If _ctipoc == "I"
               _oModelGrid:SetValue('ZF5_CUSTOI',_ntotal - _oModelGrid:GetValue('ZF5_VALEMB' ))
            ElseIf _ctipoc == "R"
               _oModelGrid:SetValue('ZF5_CUSTOR',_ntotal - _oModelGrid:GetValue('ZF5_VALEMB' ))
            ElseIf _ctipoc == "C"
               _oModelGrid:SetValue('ZF5_CUSTOC',_ntotal - _oModelGrid:GetValue('ZF5_VALEMB' ))
            ElseIf _ctipoc == "T"
               _oModelGrid:SetValue('ZF5_CUSTOT',_ntotal - _oModelGrid:GetValue('ZF5_VALEMB' ))
            ElseIf _ctipoc == "3"
               _oModelGrid:SetValue('ZF5_CUSTER',_ntotal - _oModelGrid:GetValue('ZF5_VALEMB' ))
            EndIf

         EndIf

         Break

      Else

         U_ITMSG("Nota de devolu��o n�o foi localizada","Aten��o",,1)
         _lxret := .F.
         Break

      EndIf


   EndIf

 End Sequence

 RestOrd(_aOrd)

Return _lxRet

/*
===============================================================================================================================
Programa--------: AOMS003Q
Autor-----------: Julio de Paula Paz
Data da Criacao-: 18/07/2016
Descri��o-------: Realiza as valida��es do modelo de dados.
Parametros------: _oModel = Modelo de dados
Retorno   ------: True ou False.
===============================================================================================================================
*/
User Function AOMS003Q(_oModel As Object) As Logical
 Local _lRet := .T. As Logical
 Local _aOrd := SaveOrd({"ZFC","ZF5"}) As Array
 Local _aArea := GetArea("ZF5") As Array
 Local _oModelGrid   := _oModel:GetModel("ZF5DETAIL") As Object
 Local _oModelMaster := _oModel:GetModel("ZF5MASTER") As Object
 Local _cTipoOcorr := "" As Character
 Local _cTipoCusto := "" As Character
 Local _nI := 0 As Numeric
 Local _nCustoIt := 0 As Numeric
 Local _nCustoCli := 0 As Numeric
 Local _nCustoRepr := 0 As Numeric
 Local _nCustoTransp := 0 As Numeric
 Local _nCustoTerc := 0 As Numeric
 Local _cGerDevol := "" As Character
 Local _cServOcorr := "" As Character
 Local _cNfDev := "" As Character
 Local _cSerDev := "" As Character
 Local _nOperation := _oModel:GetOperation() As Numeric
 Local _lValidaLinha := .F. As Logical
 Local _cStatusOcorr := "" As Character
 Local _cFilial := "" As Character
 Local _cDococ := "" As Character
 Local _cserie := "" As Character
 Local _nK := 0 As Numeric
 Local _nJ := 0 As Numeric
 Local _cNaturOF := ""  As Character
 Local _cPeriodo := ""  As Character
 Local _cEnvCob := "" As Character
 Local _cMotivo  := ""  As Character
 Local _nSlvaLin := _oModelGrid:GetLine()//Salva a linha atual posicionada
 Local _lBloq := .F. As Logical
 Local _cUsersHab := SuperGetMV("IT_USPROTI",.F.,"") As Character
 Local _aAreaM0:= SM0->(FwGetArea()) As Array
 PRIVATE _cFilOld   := cfilant As Character
 PRIVATE _cFilSalva := cfilant As Character

 _lEmail:= .F.//VARIAVEL STATIC
 _aDadosEmailCom:={}//VARIAVEL STATIC

 Begin Transaction

 Begin Sequence

   _lEnviou := .F.

   //=============================================================================
   // Ajusta c�digo da Ocorr�ncia de Frete para evitar erro de chave duplicada.
   //=============================================================================
   If _lRet .AND. _nOperation == MODEL_OPERATION_INSERT .OR. _nOperation == MODEL_OPERATION_UPDATE

      U_AOMS03MP(_oModel)//Tirei da pre-validacao pq no OK final nem sempre a array _aItOcorre tava preenchida, com isso bagun�ava a numera��o

      ZF5->(DbSetOrder(4)) // ZF5_FILIAL+ZF5_DOCOC+ZF5_SEROC+ZF5_CODIGO

      If Empty(_aItOcorre)
         _nCodigo := 1
      Else
         _nCodigo := Val(_aItOcorre[1,3])

         For _nI := 1 To Len(_aItOcorre)
             If _nCodigo < Val(_aItOcorre[_nI,3])
                _nCodigo := Val(_aItOcorre[_nI,3])
             EndIf
         Next  _nI
      EndIf

      _nTotOc := Len(_aItOcorre)

      For _nI := 1 To _oModelGrid:Length()
          _oModelGrid:GoLine(_nI)
          If _nI <= _nTotOc
             _oModelGrid:LoadValue('ZF5_CODIGO', _aItOcorre[_nI,3] )
          Else
             Do While .T.
                _nCodigo += 1

                _cNrNota    := _oModelMaster:GetValue("ZF5_DOCOC")
                   _cSerieNota := _oModelMaster:GetValue("ZF5_SEROC")

                // �ndice 4 = ZF5_FILIAL+ZF5_DOCOC+ZF5_SEROC+ZF5_CODIGO
                If ZF5->(MsSeek(xFilial("ZF5") + U_ITKEY( _cNrNota,"ZF5_DOCOC") + U_ITKEY( _cSerieNota ,"ZF5_SEROC") + U_ITKEY( StrZero(_nCodigo,6) ,"ZF5_CODIGO")))
                   Loop
                Else
                   Exit
                EndIf
             EndDo

             _oModelGrid:LoadValue('ZF5_CODIGO', StrZero(_nCodigo,6))
          EndIf
      Next _nI

      _aItOcorre := {}

      ZF5->(DbSetOrder(1)) // ZF5_FILIAL+ZF5_DOCOC+ZF5_SEROC

   EndIf

   If _nOperation == MODEL_OPERATION_INSERT
      //Valida registro duplicado
      _cQuery	:= " SELECT count(ZF5_FILIAL) AS CONTA "
      _cQuery  	+= " FROM " + RetSqlName("ZF5") + " ZF5"
      _cQuery  	+= " WHERE ZF5.ZF5_FILIAL = '" + xFilial("ZF5") + "'"
      _cQuery   += " AND ZF5.ZF5_DOCOC = '" + ALLTRIM(_oModelMaster:GetValue("ZF5_DOCOC")) + "'"
      IF !EMPTY(ALLTRIM(_oModelMaster:GetValue("ZF5_SEROC")))
           _cQuery  += " AND ZF5.ZF5_SEROC = '" + ALLTRIM(_oModelMaster:GetValue("ZF5_SEROC")) + "'"
      EndIf
      _cQuery  	+= " AND ZF5.D_E_L_E_T_ = ' ' "
      cAlias:=GetNextAlias()
      MPSysOpenQuery( _cQuery , cAlias)
      If .not. (cAlias)->( Eof() )  .AND.  (cAlias)->CONTA > 0
         Help( ,, 'Aten��o',, 'J� existe registro com mesmo n�mero de nota fiscal e transportador!' , 1, 0, .F. )
         (cAlias)->( Dbclosearea() )
         _lRet := .F.
         Break
      EndIf
      (cAlias)->( Dbclosearea() )
   EndIf

   If _nOperation == MODEL_OPERATION_INSERT .or. _nOperation == MODEL_OPERATION_UPDATE

      //======================================================================
      // Valida se a carga foi entregue e se foi entrega parcial ou integral.
      //======================================================================
      If _oModelMaster:GetValue("ZF5_MERENT") == "S" .And. Empty(_oModelMaster:GetValue("ZF5_SITENT"))
         Help( ,, 'Aten��o',, 'Para mercadorias assinaladas como Entregues, � obrigat�rio informar se a entrega foi Integral ou Parcial.' , 1, 0, .F. )
            _lRet := .F.
         Break
      EndIf

      If (_oModelMaster:GetValue("ZF5_MERENT") == "N" .Or. _oModelMaster:GetValue("ZF5_MERENT") == " ") .And. ! Empty(_oModelMaster:GetValue("ZF5_SITENT"))
         _oModelMaster:LoadValue("ZF5_SITENT"," ")
         U_ITMSG("A mercadoria foi assinalada como n�o entregue. Sendo assim, o conte�do do campo Situa��o de Entrega (Integral/Parcial) foi removido.","Aten��o",,2)
      EndIf

      //======================================================================
      //Valida��o de total de custos
      //Valida��o de custo representante/italac vs tipo de representante
      //======================================================================
      _cNotaFiscal:=_oModelMaster:GetValue("ZF5_DOCOC")
      _cSerie     :=_oModelMaster:GetValue("ZF5_SEROC")
      SF2->(Dbsetorder(1))

      For _nI := 1 To _oModelGrid:Length()

         _oModelGrid:GoLine(_nI)
         _cEstonado:= _oModelGrid:GetValue("ZF5_ESTONO")
         If _cEstonado = "S" .OR. _oModelGrid:IsDeleted() //SE ESTORNADO OU DELETADO N�O LE
            LOOP
         EndIf

         _dDataOcorr:= _oModelGrid:GetValue("ZF5_DTOCOR")
         _nValtransp:= _oModelGrid:GetValue('ZF5_CUSTOT')
         _nValtot   := _oModelGrid:GetValue('ZF5_CUSTO')
         _nValoco   := _oModelGrid:GetValue('ZF5_VLRTOT')
         _nValita   := _oModelGrid:GetValue('ZF5_CUSTOI')
         _nValrep   := _oModelGrid:GetValue('ZF5_CUSTOR')
         _nValcli   := _oModelGrid:GetValue('ZF5_CUSTOC')
         _nValter   := _oModelGrid:GetValue('ZF5_CUSTER')
         _nValemb   := _oModelGrid:GetValue('ZF5_VALEMB')
         _cCodigo   := ALLTRIM(STR(VAL(_oModelGrid:GetValue('ZF5_CODIGO',_nI))))  // C�digo da ocorr�ncia por nota
         _cTipoOcorr:= _oModelGrid:GetValue("ZF5_TIPOO")
         _cDtTran   :=  Posicione("ZFC",1,xFilial("ZFC")+_cTipoOcorr,"ZFC_DTTRAN") // 1 = ZFC_FILIAL+ZFC_CODIGO

         If _dDataOcorr > DATE() .and. _cDtTran <> "F"
            Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ', Data da ocorrencia '+DTOC(_dDataOcorr)+' n�o pode ser maior que Hoje.' , 1, 0 )
            _lRet := .F.
            Break
         EndIf

         SF2->(DbSeek(xfilial("SF2")+_cNotaFiscal+_cSerie))
         If _dDataOcorr < SF2->F2_EMISSAO
            Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ', Data da ocorrencia '+DTOC(_dDataOcorr)+'n�o pode ser menor que emissao da NF: '+DTOC(SF2->F2_EMISSAO) , 1, 0 )
            _lRet := .F.
            Break
         EndIf

         If _nvaltot != (_nvaltransp+_nvalita+_nvalrep+_nvalcli+_nvalter+_nvalemb)
            Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Valor total da ocorr�ncia deve ser igual � somat�ria dos custos Italac, ' + ;
                      ' cliente, representante, transportador, terceiros e embutido no frete ' , 1, 0, .F. )
            _lRet := .F.
            Break
         EndIf

         If _nvaloco != (_nvaltransp+_nvalita+_nvalrep+_nvalcli+_nvalter)
            Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Custo da ocorr�ncia deve ser igual � somat�ria dos custos Italac, ' + ;
                     ' cliente, representante, transportador, terceiros ' , 1, 0, .F. )
             _lRet := .F.
             Break
         EndIf

         If (_oModelGrid:GetValue('ZF5_TIPOC') == "V")  .and. posicione("SA3",1,xfilial("SA3")+ALLTRIM(_oModelMaster:GetValue("ZF5_REPRES")),"A3_TIPO") <> "I"
             Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Tipo de Custo Vendedor Interno s� pode ser preenchido para Vendedor Interno. ', 1, 0 )
             _lRet := .F.
             Break
         EndIf

         If (_oModelGrid:GetValue('ZF5_TIPOC') == "R")  .and. posicione("SA3",1,xfilial("SA3")+ALLTRIM(_oModelMaster:GetValue("ZF5_REPRES")),"A3_TIPO") = "I"
             Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Tipo de Custo Representante Externo s� pode ser preenchido para Representante Externo. ', 1, 0 )
             _lRet := .F.
             Break
         EndIf

         If !_oModelGrid:IsDeleted() .and. _oModelGrid:IsInserted() 
            ZFC->(DbSetOrder(1))
            If ZFC->(DbSeek(xFilial("ZFC")+_oModelGrid:GetValue("ZF5_TIPOO")))
               If ZFC->ZFC_PROTIT == "S"
                  If !(RetCodUsr() $ _cUsersHab) .AND. _oModelGrid:GetValue("ZF5_DPRORR") > 0
                     _lRet := .F.
                     Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Usu�rio n�o tem permiss�o para usar este tipo de Ocorrencia.', 1, 0, .F. )
                     Break
                  EndIf
               EndIf
            EndIf
         EndIf

      Next _nI

      _cfilold:=cfilant

      //Valida��o de custo de devolu��o
      For _nI := 1 To _oModelGrid:Length()

         _oModelGrid:GoLine(_nI)
         _cEstonado:= _oModelGrid:GetValue("ZF5_ESTONO")
         If _cEstonado = "S" .OR. _oModelGrid:IsDeleted() //SE ESTORNADO OU DELETADO N�O LE
            LOOP
         EndIf

         _lnotadev := (_oModelGrid:GetValue('ZF5_DEVOL'  ) == "S" )
         _ctipoc   :=  _oModelGrid:GetValue('ZF5_TIPOC'  )
         _cdvitens :=  _oModelGrid:GetValue('ZF5_DVITEM' )

         //Soma valores de itens selecionados para devolu��o
         If _lnotadev .and. !empty(_ctipoc) .and. !empty(_cdvitens)

            _cforn := alltrim(_oModelMaster:GetValue('ZF5_CLIENT'))
            _clojaf := alltrim(_oModelMaster:GetValue('ZF5_LOJA'))

            //Localiza nota de devolu��o
            SF1->(Dbsetorder(1))
            If SF1->(DbSeek(xfilial("SF1")+_oModelGrid:GetValue('ZF5_DOCDEV' )+_oModelGrid:GetValue('ZF5_SERDEV')+_cforn+_clojaf))

               SD1->(Dbsetorder(1))
               SD1->(DbSeek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))

               _ntotal := 0

               Do while SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA

                  If SD1->D1_ITEM $ _cdvitens

                     _ntotal += SD1->D1_TOTAL

                  EndIf

                  SD1->(Dbskip())

               Enddo

            Else

               Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + " - N�o foi localizada nota de devolu��o - Verifique o item " + strzero(_ni,3), 1, 0 )
               _lret := .F.
               Break

            EndIf

            If _ntotal != _oModelGrid:GetValue('ZF5_CUSTO' ) .and. u_itgetmv("ITOCVALDEV", .F.);
                  .and.  POSICIONE("ZFD",1,xFilial("ZFD")+_oModelGrid:GetValue('ZF5_STATUS' ),"ZFD_STATUS") == "E"

               Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + " - Custo da ocorr�ncia diverge da nota de devolu��o! - Verifique o item " + strzero(_ni,3), 1, 0 )

               _lret := .F.
               Break

            EndIf


         Elseif !empty(_cdvitens)

            Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + " - Selecione tipo de custo e marque a ocorr�ncia como devolu��o para indicar nota de devolu��o  "  , 1, 0 )
            _lRet := .F.
            Break

         EndIf

      Next _nI

      //Valida��o de nota de d�bito e pedido de descarte
      _cNotaFiscal := _oModelMaster:GetValue("ZF5_DOCOC")
      _cSerie      := _oModelMaster:GetValue("ZF5_SEROC")
      For _nI := 1 To _oModelGrid:Length()

          _oModelGrid:GoLine(_nI)
          _cEstonado:= _oModelGrid:GetValue("ZF5_ESTONO")
          If _cEstonado = "S" .OR. _oModelGrid:IsDeleted() //SE ESTORNADO OU DELETADO N�O LE
             LOOP
          EndIf
          _nvaltransp  := _oModelGrid:GetValue('ZF5_CUSTOT',_nI)    //Custo transportador transportador
          _cndebit     := _oModelGrid:GetValue('ZF5_NDEBIT',_nI)   // Nota de debito
          _cgerdev     := _oModelGrid:GetValue('ZF5_GERDEV',_nI)   // Gera Pedido de descarte
          _cpeddev     := _oModelGrid:GetValue('ZF5_PEDDEV',_nI)   // Pedido de descarte
          _cdocdev     := _oModelGrid:GetValue('ZF5_DOCDEV',_nI)   // Documento de devolu��o
          _cserdev     := _oModelGrid:GetValue('ZF5_SERDEV',_nI)   // S�rie de documento de devolu��o
          _cdvitem     := _oModelGrid:GetValue('ZF5_DVITEM',_nI)   // Itens do documento de devolu��o
          _ctipocus    := _oModelGrid:GetValue('ZF5_TIPOC',_nI)   // Tipo de custo
          _cStatus     := _oModelGrid:GetValue('ZF5_STATUS',_nI)   // Status da ocorr�ncia
          _cCodigo     := ALLTRIM(STR(VAL(_oModelGrid:GetValue('ZF5_CODIGO',_nI))))  // C�digo da ocorr�ncia por nota
          _ccodter     := _oModelGrid:GetValue('ZF5_FORTER',_nI) //Fornecedor terceiro
          _clojter     := _oModelGrid:GetValue('ZF5_LOJTER',_nI) //Loja terceiro
          _nvalterc    := _oModelGrid:GetValue('ZF5_CUSTER',_nI) //Custo terceiro
          _ddtfinal    := _oModelGrid:GetValue('ZF5_DTFIN',_nI)
          _cmotcus     := _oModelGrid:GetValue('ZF5_MOTCUS',_nI)
          _cTipoO      := _oModelGrid:GetValue('ZF5_TIPOO',_nI)   // Tipo de ocorr�ncia
          _cMotivo     := _oModelGrid:GetValue('ZF5_MOTIVO',_nI)  // Motivo da ocorr�ncia
          _ctransp     := _oModelGrid:GetValue("ZF5_TRANSP",_nI)
          _clojat      := _oModelGrid:GetValue("ZF5_LJTRAN",_nI)

          If POSICIONE("ZFD",1,xFilial("ZFD")+_cStatus,"ZFD_STATUS") == "E"
             //Posiciona no registro gravado no banco para comparar
             ZF5->(Dbsetorder(4))
             If !(ZF5->(DbSeek(xfilial("ZF5")+_cNotaFiscal+_cserie+_oModelGrid:GetValue('ZF5_CODIGO',_nI)))) .and. _cndebit == "S"
                Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Para nota de d�bito, inclua a ocorr�ncia com status pendende e depois altere para status encerrado!' , 1, 0 )
                _lRet := .F.
                Break

             ElseIf !(ZF5->(DbSeek(xfilial("ZF5")+_cNotaFiscal+_cserie+_oModelGrid:GetValue('ZF5_CODIGO',_nI)))) .and. _cgerdev == "S"
                Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Para pedido de descarte, inclua a ocorr�ncia com status pendende e depois altere para status encerrado!' , 1, 0 )
                _lRet := .F.
                Break
             Elseif UPPER(ALLTRIM(ZF5->ZF5_MOTCUS)) != UPPER(ALLTRIM(_cmotcus))
                //Help( ,, 'Aten��o',, 'Ocorr�ncia ' + _cCodigo + ' - Salve o motivo de custo antes de encerrar a ocorr�ncia!' , 1, 0 )
                //ITmsg(_cMens,_ctitu,_csolu,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes)
                U_ITmsg('Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Salve o motivo de custo antes de encerrar a ocorr�ncia!','Aten��o',;
                        "Texto: ["+ALLTRIM(ZF5->ZF5_MOTCUS)+"] gravado  diferente do digitado ["+ALLTRIM(_cmotcus)+"]",,,,.T.)
                _lRet := .F.
                Break
             EndIf
          EndIf

          //Valida rela��o entre campos gera devolu��o e gera pedido de descarte
          If _oModelGrid:GetValue('ZF5_GERDEV',_nI ) == "S" .AND. _oModelGrid:GetValue('ZF5_DEVOL',_nI ) != "S"
             Help( ,, "Aten��o",, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + " - Para gerar pedido de descarte precisa ser ocorr�ncia de devolu��o!" , 1, 0 )
             _lRet := .F.
             Break
          EndIf

          //Valida se est� incluindo nota com custo terceiro ou transportador sem nota de d�bito
          If (_nvalterc > 0 .OR. _nvaltransp > 0) .AND. _cndebit != "S"
              If POSICIONE("ZFD",1,xFilial("ZFD")+_cStatus,"ZFD_STATUS") == "E"  .and. _ddtfinal > stod("20190103")
                 Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Ocorr�ncia com custo de transportador/terceiro s� pode ser encerrada com gera��o de nota de d�bito de transporte!' , 1, 0 )
                 _lRet := .F.
                 Break
               EndIf
          EndIf

          //Valida se itens de devolu��o n�o foram usados j�
          If _nOperation == MODEL_OPERATION_UPDATE
             //Posiciona no registro gravado no banco para comparar
             ZF5->(Dbsetorder(4))
             ZF5->(DbSeek(xfilial("ZF5")+_cNotaFiscal+_cserie+_oModelGrid:GetValue('ZF5_CODIGO')))

             //S� valida se est� encerrando
             If POSICIONE("ZFD",1,xFilial("ZFD")+ZF5->ZF5_STATUS,"ZFD_STATUS") != "E" .AND.;
                POSICIONE("ZFD",1,xFilial("ZFD")+_oModelGrid:GetValue('ZF5_STATUS'),"ZFD_STATUS") == "E"

               //S� valida se tem conte�do na ZF5_DVITEM
               If !empty(_oModelGrid:GetValue('ZF5_DVITEM'))

                  //Valida se est� em outra linha da ocorr�ncia atual
                  _aitens := Strtokarr2( _oModelGrid:GetValue('ZF5_DVITEM',_ni), '/')

                  For _nk := 1 to _oModelGrid:Length()
                      _oModelGrid:GoLine(_nk)
                      _cEstonado:= _oModelGrid:GetValue("ZF5_ESTONO",_nk)
                      If _cEstonado = "S" .OR. _oModelGrid:IsDeleted() //SE ESTORNADO OU DELETADO N�O LE
                         LOOP
                      EndIf
                      If _oModelGrid:GetValue('ZF5_DOCDEV',_nk) == _oModelGrid:GetValue('ZF5_DOCDEV',_ni)
                         For _nj := 1 to len(_aitens)
                            If _aitens[_nj] $ _oModelGrid:GetValue('ZF5_DVITEM',_nk) .and. _nk != _ni .and. !empty(_aitens[_nj])
                               Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Item de devolu��o j� utilizado na linha ' + strzero(_nk,3) + '!' , 1, 0 )
                               _lRet := .F.
                               Break
                            EndIf
                         Next _nj
                      EndIf
                  Next _nk

                  _oModelGrid:GoLine(_nI)

                  //Valida se est� em outra linha da base de dados
                  _cQry := " SELECT ZF5_DOCOC, ZF5_DVITEM FROM "+RetSqlName("ZF5")+" ZF5 "
                  _cQry += " WHERE ZF5.D_E_L_E_T_ = ' ' AND ZF5_FILIAL = '"+xFilial("ZF5")+"' "
                  _cQry += " AND ZF5_DOCDEV = '" + ALLTRIM(_oModelGrid:GetValue('ZF5_DOCDEV',_ni)) + "' "
                  _cQry += " AND ZF5_CLIENT = '" + ALLTRIM(_oModelMaster:GetValue('ZF5_CLIENT')) + "' "
                  _cQry += " AND ZF5_LOJA = '" + ALLTRIM(_oModelMaster:GetValue('ZF5_LOJA')) + "' "
                  _cQry += " AND ZF5_DOCOC <> '" + ALLTRIM(_oModelMaster:GetValue('ZF5_DOCOC')) + "' "
                  _cQry := ChangeQuery(_cQry)
                  cAlias:=GetNextAlias()
                  MPSysOpenQuery( _cQry , cAlias )

                  Do while (cAlias)->(!Eof())
                     For _nj := 1 to len(_aitens)
                        If _aitens[_nj] $ (cAlias)->ZF5_DVITEM .and. !empty(_aitens[_nj])
                           Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Item de devolu��o j� utilizado em ocorr�ncia da nota  ' + (cAlias)->ZF5_DOCOC + '!' , 1, 0 )
                           _lRet := .F.
                           Break
                        EndIf
                     Next _nj
                     (cAlias)->(Dbskip())
                  Enddo
                  (cAlias)->(DbCloseArea())
               EndIf
            EndIf
         EndIf

         //Valida se est� tentando alterar campos proibidos em uma ocorr�ncia encerrada com t�tulo de d�bito de transporte
         If _nOperation == MODEL_OPERATION_UPDATE

            //Posiciona no registro gravado no banco para comparar
            ZF5->(Dbsetorder(4))
            ZF5->(DbSeek(xfilial("ZF5")+_cNotaFiscal+_cserie+_oModelGrid:GetValue('ZF5_CODIGO')))
            If POSICIONE("ZFD",1,xFilial("ZFD")+ZF5->ZF5_STATUS,"ZFD_STATUS") == "E"

               If _oModelGrid:IsDeleted()
                  Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + 'Para deletar a linha, reabra ocorr�ncia primeiro!' , 1, 0 )
                  _lRet := .F.
                  Break
               EndIf

               If _cndebit != ZF5->ZF5_NDEBIT
                  Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6)+ ' - Para alterar gera��o de nota de d�bito reabra ocorr�ncia primeiro!' , 1, 0 )
                  _lRet := .F.
                  Break
               EndIf

               If _cpeddev != ZF5->ZF5_PEDDEV .or. _cgerdev != ZF5->ZF5_GERDEV
                  Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Para alterar pedido de descarte reabra ocorr�ncia primeiro!' , 1, 0 )
                  _lRet := .F.
                  Break
               EndIf

               If _cgerdev == "S" .and. (_cdocdev != ZF5->ZF5_DOCDEV .or. _cserdev != ZF5->ZF5_SERDEV .or. _cdvitem != ZF5->ZF5_DVITEM)
                  Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Para alterar dados de devolu��o reabra ocorr�ncia primeiro!' , 1, 0 )
                  _lRet := .F.
                  Break
               EndIf

               iF ZF5->ZF5_NDEBIT == "S" .AND. _ctipocus != ZF5->ZF5_TIPOC
                  Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Para alterar tipo de custo com nota de d�bito reabra ocorr�ncia primeiro!' , 1, 0 )
                  _lRet := .F.
                  Break
               EndIf

               iF ZF5->ZF5_NDEBIT == "S" .AND. _ctipocus == "T" .and.  _nvaltransp != ZF5->ZF5_CUSTOT
                   Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Para alterar valor de custo com nota de d�bito reabra ocorr�ncia primeiro!' , 1, 0 )
                   _lRet := .F.
                   Break
               EndIf

               iF ZF5->ZF5_NDEBIT == "S" .AND. _ctipocus == "3" .and.  _nvalterc != ZF5->ZF5_CUSTER
                   Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Para alterar valor de custo com nota de d�bito reabra ocorr�ncia primeiro!' , 1, 0 )
                   _lRet := .F.
                   Break
               EndIf

            EndIf
         EndIf

         //Valida se est� tentando reabrir uma ocorr�ncia com t�tulo de d�bito de transporte ou pedido de descarte
         //Exclui t�tulo se poss�vel
         If  _nOperation == MODEL_OPERATION_UPDATE .and. !_oModelGrid:IsDeleted()

             //Posiciona no registro gravado no banco para comparar
             ZF5->(DBSETORDER(4))
             ZF5->(DbSeek(xfilial("ZF5")+_cNotaFiscal+_cserie+_oModelGrid:GetValue('ZF5_CODIGO',_nI)))

             //VALIDA SE J� EXISTE PEDIDO DE DESCARTE
             If POSICIONE("ZFD",1,xFilial("ZFD")+_cStatus,"ZFD_STATUS") != "E" .and. POSICIONE("ZFD",1,xFilial("ZFD")+ZF5->ZF5_STATUS,"ZFD_STATUS") == "E"

                SC5->(Dbsetorder(1))
                If SC5->(DbSeek(xfilial("SC5")+_cpeddev))
                   If u_itmsg("Existe pedido de descarte para essa ocorr�ncia. Pedido ser� excluido com a reabertura da ocorr�ncia. Deseja continuar?",;
                              "Aten��o","Pedido: "+xfilial("SC5")+" "+_cpeddev+' - Ocorr�ncia: ' + STRZERO(VAL(_cCodigo),6),2,2,2)
                      //Tenta fazer exclus�o do pedido de descarte
                      _lret := AOMS003DP()
                      If !_lret
                         Break
                      EndIf
                   Else
                      Help( ,, 'Aten��o',, 'Processo cancelado' , 1, 0 )
                      _lRet := .F.
                      Break
                   EndIf
                Else
                  _oModelGrid:LoadValue('ZF5_PEDDEV',_nI)
                  _cpeddev := ' '
                EndIf
             EndIf //VALIDA SE J� EXISTE PEDIDO DE DESCARTE

             If POSICIONE("ZFD",1,xFilial("ZFD")+ZF5->ZF5_STATUS,"ZFD_STATUS") == "E"  .and.  POSICIONE("ZFD",1,xFilial("ZFD")+_cStatus,"ZFD_STATUS") != "E"
                _cfilold := cfilant
                //Se for nota de faturamento de um troca nota muda para a filial de carregamento para incluir a nota de d�bito
                SF2->(Dbsetorder(1))
                If SF2->(DbSeek(xfilial("SF2")+_cNotaFiscal+_cSerie))
                   SC5->(Dbsetorder(1))
                   If SC5->(DbSeek(xfilial("SC5")+SF2->F2_I_PEDID))
                      If SC5->C5_I_TRCNF = "S" .AND. SC5->C5_I_FLFNC != SC5->C5_FILIAL
                         cfilant := SC5->C5_I_FLFNC
                      Endif
                   Endif
                Endif

                _cFornece:=""
                _cLoja:=""
                If ZF5->ZF5_TIPOC == "T"
                   _cFornece := ALLTRIM(ZF5->ZF5_TRANSP)
                   _cLoja    := ZF5->ZF5_LJTRAN
                Elseif ZF5->ZF5_TIPOC == "3"
                   _cFornece := ZF5->ZF5_FORTER
                   _cLoja    := ZF5->ZF5_LOJTER
                Endif

               IF !EMPTY(ZF5->ZF5_CHVNDT)
                  IF LEN(ALLTRIM(ZF5->ZF5_CHVNDT)) = LEN(SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM)//CHAVE SEM PARCELA
                     _cSeekSE2:=ZF5->ZF5_CHVNDT + "01" + "NDF"+_cFornece+_cLoja//A chave e o cfilant j� estam com a filai certa
                  Else//CHAVE COM PARCELA - NOVA
                     _cSeekSE2:=ZF5->ZF5_CHVNDT + "NDF"+_cFornece+_cLoja//A chave e o cfilant j� estam com a filai certa
                  Endif
                  _cMostra:=_cSeekSE2
               ELSE//CHAVE ANTIGA
                  _cSeekSE2:=xfilial("SE2")+"NDT"+SUBSTR(_cNotaFiscal,2,8) + STRZERO(VAL(_cCodigo),6) + "01" + "NDF"//o cfilant j� na filiaa certa
               EndIf

               SE2->(Dbsetorder(1)) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
               If SE2->(DbSeek(_cSeekSE2))
                  IF EMPTY(ZF5->ZF5_CHVNDT)
                     _cMostra:=_cSeekSE2+SE2->E2_FORNECE+SE2->E2_LOJA
                  ENDIF
                  If u_itmsg("Existe t�tulo de d�bito de transporte para essa ocorr�ncia. T�tulo ser� excluido com a reabertura da ocorr�ncia. Deseja continuar?",;
                              "Aten��o","Chave Titulo: "+_cMostra+' - Ocorr�ncia: ' + STRZERO(VAL(_cCodigo),6),2,2,2)
                     _lerro := !(AOMS003DT( ZF5->(RECNO()),_oModelGrid ))//EXCLUI T�TULO DE D�BITO
                     If _lerro
                        // J� D� MENSAGEM DE ERRO DENTRO DA FUN��O AOMS003DT ()
                        //Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Erro ao excluir t�tulo de nota de d�bito, ocorr�ncia n�o ser� salva/apagada.' , 1, 0 )
                        _lRet := .F.
                        cfilant := _cfilold
                        Break
                     EndIf
                  Else
                      Help( ,, 'Aten��o',, 'Altera��o cancelada!' , 1, 0 )
                      _lRet := .F.
                      cfilant := _cfilold
                      Break
                  EndIf
               EndIf
               cfilant := _cfilold

            EndIf

         EndIf

             If !(_oModelGrid:IsDeleted())

               //S� aceita nota de d�bito para custo de terceiro ou transportador
               If _cndebit == "S" .and. _ctipocus != "T" .and. _ctipocus != "3"
                   Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Somente gera nota de d�bito para custo transportador ou terceiro!' , 1, 0 )
                   _lRet := .F.
                   Break
               EndIf
               //Valida consist�ncia de campos valor transportador
               If _cndebit == "S" .AND. _nvaltransp <= 0 .AND. _ctipocus == "T"
                  Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Para ter nota de d�bito � preciso indicar custo para transportador!' , 1, 0 )
                  _lRet := .F.
                  Break
               EndIf
               //Valida consist�ncia de campos valor terceiro
               If _cndebit == "S" .AND. _nvalterc <= 0 .AND. _ctipocus == "3"
                  Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Para ter nota de d�bito � preciso indicar custo para terceiro!' , 1, 0 )
                  _lRet := .F.
                  Break
               EndIf

               //Verifica se a ocorrencia de frete possui uma natureza espec�fica para gerar o titulo no Financeiro
               If !Empty(Alltrim(_cTipoO))
                  _cNaturOF := POSICIONE("ZFC",1,xFilial("ZFC")+_cTipoO,"ZFC_NATUR")
               Else
                  _cNaturOF := ""
               EndIf

               If !Empty(Alltrim(_cNaturOF))
                  _cnatureza := _cNaturOF
               Else
                  If _ctipocus == "T"  //Verificar aqui se � custo transportador ou custo terceiro
                     _cnatureza := u_itgetmv("ITNDNATUR","112021    ")
                  Elseif _ctipocus == "3"
                     _cnatureza := u_itgetmv("ITNTNATUR","112022    ")
                  EndIf
               EndIf

               //SE STATUS EST� ENCERRADO, VALIDA SE J� EXISTE PEDIDO DE DESCARTE
               If POSICIONE("ZFD",1,xFilial("ZFD")+_cStatus,"ZFD_STATUS") == "E" .and. _cgerdev == "S";
                       .and. POSICIONE("ZFD",1,xFilial("ZFD")+ZF5->ZF5_STATUS,"ZFD_STATUS")  != "E"

                  //Posiciona no registro gravado no banco para comparar
                  ZF5->(Dbsetorder(4))
                  ZF5->(DbSeek(xfilial("ZF5")+_cNotaFiscal+_cserie+_oModelGrid:GetValue('ZF5_CODIGO')))
                  SC5->(Dbsetorder(1))

                  If !(SC5->(DbSeek(xfilial("SC5")+_cpeddev)))

                     If !u_itmsg("Encerramento de ocorr�ncia ir� gerar pedido de descarte, confirma?","Aten��o",'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6),2,2,2)
                        Help( ,, 'Aten��o',, 'Processo cancelado pelo usu�rio.' , 1, 0 )
                        _lRet := .F.
                        Break
                     EndIf

                     //LOCALIZA DOCUMENTO DE DEVOLU��O
                     SF1->(Dbsetorder(1))
                     If SF1->(DbSeek(xfilial("SF1")+_cdocdev+_cserdev+ZF5->ZF5_CLIENT+ZF5->ZF5_LOJA+"D"))
                        SD1->(Dbsetorder(1))
                        If SD1->(DbSeek(xfilial("SD1")+_cdocdev+_cserdev+ZF5->ZF5_CLIENT+ZF5->ZF5_LOJA))
                        _aItensPV := {}
                        _njk := 0
                        Do while SF1->F1_FILIAL == SD1->D1_FILIAL .AND.;
                                 SF1->F1_DOC == SD1->D1_DOC .AND.;
                                 SF1->F1_FORNECE == SD1->D1_FORNECE .AND.;
                                 SF1->F1_LOJA == SD1->D1_LOJA .AND.;
                                 SF1->F1_SERIE == SD1->D1_SERIE

                           If SD1->D1_ITEM $ _cdvitem

                              _njk++
                              aAdd( _aItensPV , { { "C6_FILIAL"  , cfilant	   				    ,Nil},;
                                                  { "C6_ITEM"    , strzero(_njk,2)				,Nil},;
                                                  { "C6_PRODUTO" , SD1->D1_COD  				,Nil},;
                                                  { "C6_UM"    	 , SD1->D1_UM				    ,Nil},;
                                                  { "C6_QTDVEN"  , SD1->D1_QUANT   				,Nil},;
                                                  { "C6_UNSVEN"  , SD1->D1_QTSEGUM				,Nil},;
                                                  { "C6_LOCAL"   , U_ITGETMV("LOCDESC","31")	,nil},;
                                                  { "C6_PRCVEN"  , SD1->D1_TOTAL/SD1->D1_QUANT	,Nil},;
                                                  { "C6_VALOR"   , SD1->D1_TOTAL              	,Nil},;
                                                  { "C6_I_DEVFN" , SD1->D1_FORNECE           	,Nil},;
                                                  { "C6_I_DEVLJ" , SD1->D1_LOJA              	,Nil},;
                                                  { "C6_I_DEVDO" , SD1->D1_DOC               	,Nil},;
                                                  { "C6_I_DEVSE" , SD1->D1_SERIE              	,Nil},;
                                                  { "C6_I_DEVIT" , SD1->D1_ITEM               	,Nil},;
                                                  { "C6_ENTREGA" , date()+100      	            ,Nil}} )

                           EndIf

                           SD1->(Dbskip())

                        Enddo

                     Else

                        Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - N�o foi poss�vel localizar nota de devolu��o da ocorr�ncia' , 1, 0 )
                        _lRet := .F.
                        Break

                        EndIf

                     Else

                        Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - N�o foi poss�vel localizar nota de devolu��o da ocorr�ncia' , 1, 0 )
                        _lRet := .F.
                        Break

                     EndIf

                     If len(_aItensPV) == 0

                        Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - N�o foi poss�vel localizar itens da nota de devolu��o da ocorr�ncia' , 1, 0 )
                        _lRet := .F.
                        Break

                     EndIf

                  //Carrega cliente e loja da filial atual
                  ZZM->(Dbsetorder(1))
                  If !(ZZM->(DbSeek(xfilial("ZZM")+cfilant)))

                     Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - N�o foi poss�vel localizar filial atual no cadastro de filiais (ZZM)' , 1, 0 )
                     _lRet := .F.
                     Break

                  EndIf

                  SA1->(Dbsetorder(3))
                  If !(SA1->(DbSeek(xfilial("SA1")+ZZM->ZZM_CGC)))

                     Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - N�o foi poss�vel localizar filial atual no cadastro de clientes com cgc ' + ZZM->ZZM_CGC   , 1, 0 )
                     _lRet := .F.
                     Break

                  EndIf


                  //Cria pedido de descarte
                  aCabec := { { "C5_FILIAL"     , cfilant	                                                , Nil },;
                              { "C5_TIPO"   	, "N"		                                                   , Nil },;
                              { "C5_CLIENTE"	, SA1->A1_COD	                                             , Nil },;
                              { "C5_LOJACLI"	, SA1->A1_LOJA	                                             , Nil },;
                              { "C5_TIPOCLI"	, SA1->A1_TIPO	 	                                          , Nil },;
                              { "C5_CONDPAG"	, '001'													 	            , Nil },;
                              { "C5_VEND1"      , SA1->A1_VEND												            , Nil },;
                              { "C5_VEND2"      , Posicione('SA3',1,xFilial('SA3')+SA1->A1_VEND,'A3_SUPER')	, Nil },;
                              { "C5_VEND3"      , SA3->A3_GEREN											            , Nil },;
                              { "C5_EMISSAO"	, DATE()	                                                   , Nil },;
                              { "C5_TABELA" 	, ''														               , Nil },;
                              { "C5_MENNOTA"	, 'Descarte de devolu��o'							               , Nil },;
                              { "C5_TPFRETE"	, 'C'														               , Nil },;
                              { "C5_I_OBPED"    , 'Descarte devolu��o - Oc frete NF Venda ' + ZF5->ZF5_DOCOC+"/"+ZF5->ZF5_SEROC, Nil },;
                              { "C5_I_OPER"     , u_itgetmv("TPOPERDESC","22")			   			         , Nil },;
                              { "C5_TRANSP"     , ''														               , Nil },;
                              { "C5_I_DTENT"    ,  date()+100          										         , Nil },;
                              { "C5_I_AGEND"    , "I"	                                                      , Nil }}

                  lMSErroAuto := .F.

                  fwmsgrun(, { || MSExecAuto( {|x,y,z| Mata410(x,y,z) } , aCabec , _aItensPV , 3 )},"Aguarde...","Criando pedido de descarte...")

                  If lMsErroAuto

                     MostraErro()
                     Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - N�o foi poss�vel gerar o pedido de descarte' , 1, 0 )
                              _lret := .F.
                     Break

                  Else

                     _oModelGrid:LoadValue('ZF5_PEDDEV',SC5->C5_NUM)
                     _cpeddev := SC5->C5_NUM
                     U_ITMSG("Criado pedido de descarte " + SC5->C5_NUM,"Aten��o",'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6),3)

                  EndIf

               EndIf

            EndIf

            //********************************************************************************************************************************************************//
            //IDENTIFICA E VALDIA FORNECEDOR DO T�TULO A PAGAR COMO TRANSPORTADOR OU TERCEIRO
            If _ctipocus == "T"
               If empty(_ctransp)
                  Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - N�o h� transportador vinculado � nota, use custo de terceiros e indique o fornecedor' , 1, 0 )
                  _lRet := .F.
                  Break
               Endif
               _cFornece := ALLTRIM(_ctransp)
               _cLoja := _cLojat
               _cindice := xfilial("SA2")+alltrim(_cFornece)+_cLojat
               _nvalortit := _nvaltransp
            Elseif _ctipocus == "3"
               _cFornece := _ccodter
               _cLoja := _clojter
               _cindice := xfilial("SA2")+alltrim(_cFornece)+alltrim(_cLoja)
               _nvalortit := _nvalterc
            Endif

            SA2->(Dbsetorder(1))
            If _ctipocus == "T" .OR. _ctipocus == "3"
               If !SA2->(Dbseek(_cindice))
                  Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Fornecedor para gera��o de t�tulo de nota de d�bito n�o localizado.' , 1, 0 )
                  _lRet := .F.
                  Break
               Else
                       If SA2->A2_MSBLQL == '1'
                          Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Erro ao gravar t�tulo de nota de d�bito, ocorr�ncia n�o ser� salva. Fornecedor informado ' + Alltrim(_cFornece) + " - " + Alltrim(_cLoja) + ' encontra-se Bloqueado ou Inativo no cadastro de Fornecedores do Sistema!' , 1, 0 )
                       _lBloq := .T.
                       _lRet := .F.
                       cfilant := _cfilold
                       Break
                     Endif
                     _cLoja:=SA2->A2_LOJA
               Endif
             ENDIF

             //********************************************************************************************************************************************************//
            //SE STATUS EST� ENCERRADO, VALIDA SE J� EXISTE GERA��O DE T�TULO DE NOTA DE D�BITO ************************************
            If POSICIONE("ZFD",1,xFilial("ZFD")+_cStatus,"ZFD_STATUS") == "E" .and. _cndebit == "S";
                     .and. POSICIONE("ZFD",1,xFilial("ZFD")+ZF5->ZF5_STATUS,"ZFD_STATUS")  != "E"

               IF !EMPTY(ZF5->ZF5_CHVNDT)
                  IF LEN(ALLTRIM(ZF5->ZF5_CHVNDT)) = LEN(SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM)//CHAVE SEM PARCELA
                     _cSeekSE2:=ZF5->ZF5_CHVNDT + "01" + "NDF"+_cFornece+_cLoja//A chave e o cfilant j� estam com a filai certa
                  Else//CHAVE COM PARCELA - NOVO
                     _cSeekSE2:=ZF5->ZF5_CHVNDT + "NDF"+_cFornece+_cLoja//A chave e o cfilant j� estam com a filai certa
                  Endif
                  _cMostra:=_cSeekSE2
               ELSE
                  _cSeekSE2:=xfilial("SE2")+"NDT"+SUBSTR(_cNotaFiscal,2,8) + _cCodigo + "01" + "NDF"
               EndIf
               SE2->(Dbsetorder(1))
               If SE2->(DbSeek(_cSeekSE2))
                  If (_ctipocus == "T" .AND. SE2->E2_VALOR != _nvaltransp) .OR. (_ctipocus == "3" .AND. SE2->E2_VALOR != _nvalterc)
                     IF EMPTY(ZF5->ZF5_CHVNDT)
                        _cMostra:=_cSeekSE2+SE2->E2_FORNECE+SE2->E2_LOJA
                     ENDIF
                     //Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - J� existe t�tulo com valor diferente: R$ '+ALLTRIM(TRANS(SE2->E2_VALOR,'@E 999,999,999,999.99'))+'. Reabra a ocorr�ncia ou t�tulo e encerre novamente para alterar valor.' , 1, 0 )
                     U_ITmsg("Chave Titulo: "+_cMostra+' - Ocorr�ncia: ' + STRZERO(VAL(_cCodigo),6) + '. J� existe t�tulo com valor diferente: R$ '+ALLTRIM(TRANS(SE2->E2_VALOR,'@E 999,999,999,999.99')),'Aten��o!',"Reabra a ocorr�ncia ou t�tulo e encerre novamente para alterar valor.",,,,.T.)
                     _lRet := .F.
                     Break
                  EndIf
               Else
                  lMsErroAuto := .F.
                  _cfilold := cfilant
                  //Se for nota de faturamento de um troca nota muda para a filial de carregamento para incluir a nota de d�bito
                  SF2->(Dbsetorder(1))
                  If SF2->(DbSeek(xfilial("SF2")+_cNotaFiscal+_cSerie))
                     SC5->(Dbsetorder(1))
                     If SC5->(DbSeek(xfilial("SC5")+SF2->F2_I_PEDID))
                        If SC5->C5_I_TRCNF = "S" .AND. SC5->C5_I_FLFNC != SC5->C5_FILIAL
                           cfilant := SC5->C5_I_FLFNC
                        EndIf
                     EndIf
                  EndIf

                  // *******************************************************************************************************//
                  // ************************* GERA��O DO NUMERO DO TITULO POR PARCELA *********************//
                  // *************************************  ZF5_CHVNDT  ************************************//
                  _cNewParcela:="01"
                  SE2->(Dbsetorder(1))
                  _cSeekSE2:=xfilial("SE2")+"NDT"+SUBSTR(_cNotaFiscal,1,LEN(SE2->E2_NUM)) + _cNewParcela  + "NDF"+ALLTRIM(_cFornece)+_cLoja
                  DO WHILE SE2->(DbSeek(_cSeekSE2))
                     _cNewParcela:=SOMA1(_cNewParcela)
                     _cSeekSE2:=xfilial("SE2")+"NDT"+SUBSTR(_cNotaFiscal,1,LEN(SE2->E2_NUM)) + _cNewParcela + "NDF"+ALLTRIM(_cFornece)+_cLoja
                  ENDDO
                  // *************************************  ZF5_CHVNDT  ************************************//
                  // ************************* GERA��O DO NUMERO DO TITULO POR PARCELA *********************//
                  // *******************************************************************************************************//

                  //Defini��o de vencimento
                  If day(date()) < 8
                      _dvencto := stod(alltrim(str(year(date())))+alltrim(strzero(month(date()),2))+"08")
                  Elseif day(date()) > 7 .and.  day(date()) < 23
                      _dvencto := stod(alltrim(str(year(date())))+alltrim(strzero(month(date()),2))+"23")
                  ElseIf day(date()) >= 23
                     if month(date()) == 12
                         _dvencto := stod(alltrim(str(year(date())+1))+"0108")
                      Else
                          _dvencto := stod(alltrim(str(year(date())))+alltrim(strzero(month(date())+1,2))+"08")
                      EndIf
                  EndIf

                  _cmens := 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),8) + " - "
                  _cmens += "T�tulo " + cfilant + "/" +  _cNotaFiscal +"-"+ _cNewParcela + " contra " + SA2->A2_COD+"/"+SA2->A2_LOJA+" - "+ alltrim(SA2->A2_NREDUZ) + "  "
                  _cmens += "no valor de R$ " + transform(_nvalortit,"@E 999,999.99") + " com vencimento em " + dtoc(_dvencto) + "."

                  If !u_itmsg("Encerramento de ocorr�ncia ir� gerar t�tulo de d�bito de transporte, confirma?","Aten��o",_cmens,2,2,2)
                       Help( ,, 'Aten��o',, 'Processo cancelado pelo usu�rio.' , 1, 0 )
                      _lRet := .F.
                      cfilant := _cfilold
                      Break
                  Endif

                  If _lBloq
                     _lRet := .F.
                     cfilant := _cfilold
                     Break
                  Else
                     _aAutoSE2 := {}
                     AAdd( _aAutoSE2 , { "E2_PREFIXO"	, "NDT"								     , nil } )
                     AAdd( _aAutoSE2 , { "E2_NUM"		, SUBSTR(_cNotaFiscal,1,LEN(SE2->E2_NUM)), nil } )
                     AAdd( _aAutoSE2 , { "E2_PARCELA"	, _cNewParcela					         , nil } )
                     AAdd( _aAutoSE2 , { "E2_TIPO"		, "NDF"								     , nil } )
                     AAdd( _aAutoSE2 , { "E2_NATUREZ"	, _cnatureza			                 , nil } )
                     AAdd( _aAutoSE2 , { "E2_FORNECE"	, ALLTRIM(_cfornece)	                 , nil } )
                     AAdd( _aAutoSE2 , { "E2_LOJA"		, ALLTRIM(_cloja)	                     , nil } )
                     AAdd( _aAutoSE2 , { "E2_EMISSAO"	, date()			                     , nil } )
                     AAdd( _aAutoSE2 , { "E2_VENCTO"	, _dvencto	                             , nil } )
                     AAdd( _aAutoSE2 , { "E2_VALOR"     , _nvalortit		                     , nil } )
                     AAdd( _aAutoSE2 , { "E2_HIST"		, "Custo de ocorr�ncia de frete " + _cCodigo + "-" + ALLTRIM(ZF5->ZF5_MOTCUS) , Nil } )
                     AAdd( _aAutoSE2 , { "E2_DATALIB"	, date()			                     , nil } )
                     AAdd( _aAutoSE2 , { "E2_USUALIB"	, cUserName			                     , nil } )

                     _nModAux	:= nModulo
                     _cModAux	:= cModulo
                     nModulo	:= 6
                     cModulo	:= "FIN"
                     _cAOMS074Vld:=""
                     _cAOMS074   :="AOMS103"

                     fwmsgrun(,{ || MSExecAuto({|x,y| Fina050(x,y)},_aAutoSE2,3)},"Aguarde...", "Criando t�tulo de nota de d�bito...") //Inclusao

                      If lMsErroAuto
                         //Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Erro ao gravar t�tulo de nota de d�bito, ocorr�ncia n�o ser� salva.' , 1, 0 )
                         U_ITmsg('Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Erro ao gravar t�tulo de nota de d�bito, ocorr�ncia n�o ser� salva. Print essa e a proxima tela.','Aten��o!',_cAOMS074Vld,,,,.T.)  //HELP PARA O MVC
                         MostraErro()
                         _lRet := .F.
                         cfilant := _cfilold
                         nModulo := _nModAux
                         cModulo := _cModAux
                         Break
                      Else
                         //Posiciona no registro gravado no banco para comparar
                         ZF5->(DBSETORDER(4))
                         IF ZF5->(DbSeek(_cfilold+_cNotaFiscal+_cserie+_oModelGrid:GetValue('ZF5_CODIGO',_nI)))
                            ZF5->(RecLock("ZF5",.F.))
                            ZF5->ZF5_CHVNDT:=(SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA)
                            ZF5->(MSUNLOCK())
                           _oModelGrid:LoadValue('ZF5_CHVNDT',ZF5->ZF5_CHVNDT)
                         EndIf
                         //CRIA E APRESENTA PDF DE NOTA DE D�BITO E ENVIA EMAIL
                         U_ROMS055()
                      EndIf

                      cfilant := _cfilold
                      nModulo := _nModAux
                      cModulo := _cModAux
                   EndIf
               EndIf
             EndIf
         EndIf

      Next  _nI  ///ACABA AQUI - For _nI := 1 To _oModelGrid:Length()

   EndIf
   cfilant := _cfilold

   If _lRet .and. (_nOperation == MODEL_OPERATION_DELETE .or. _nOperation == MODEL_OPERATION_UPDATE)

      _cNotaFiscal := _oModelMaster:GetValue("ZF5_DOCOC")
      _cSerie      := _oModelMaster:GetValue("ZF5_SEROC")
      _cfilial     := xfilial("ZF5")//ZF5->ZF5_FILIAL
      _cdococ      := _cNotaFiscal//ZF5->ZF5_DOCOC
      ZF5->(Dbsetorder(4))

      For _nI := 1 To _oModelGrid:Length() //FOR 2

         _oModelGrid:GoLine(_nI)
         _cEstonado:= _oModelGrid:GetValue("ZF5_ESTONO")
         If _cEstonado = "S" .OR. _oModelGrid:IsDeleted() //SE ESTORNADO OU DELETADO N�O LE
            LOOP
         EndIf

         IF !ZF5->(DbSeek(_cfilial+_cdococ+_cserie+_oModelGrid:GetValue('ZF5_CODIGO'))) // Se n�o achar n�o valida, pois � linha nova
            LOOP
         EndIf
         _dencerrra   := ZF5->ZF5_DTFIN
         _cStatusOcorr:= ZF5->ZF5_STATUS
         _cCodigo     := ALLTRIM(STR(VAL(_oModelGrid:GetValue('ZF5_CODIGO'))))  // C�digo da ocorr�ncia por nota
         _csit := ""
         _lValidaLinha := .F.

         If _nOperation == MODEL_OPERATION_DELETE
            _lValidaLinha := .T.
         ElseIf _oModelGrid:IsDeleted()
            _lValidaLinha := .T.
         ElseIf _oModelGrid:IsUpdated() .And. U_AOMS003R(_oModel)
            _lValidaLinha := .T.
         EndIf

         //Valida se est� excluindo linha com ocorr�ncia encerrada
         If _lValidalinha .and. _nOperation == MODEL_OPERATION_DELETE .and. POSICIONE("ZFD",1,xFilial("ZFD")+ _cStatusOcorr,"ZFD_STATUS") == "E"
            _lRet := .F.
            Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Para excluir ocorr�ncias primeiro reabra o status de todas as linhas!' , 1, 0 )
            Break
         EndIf

         _cPeriodo := ""
           If _lValidaLinha
            If DAY(_dencerrra) <= 25
               _cPeriodo := StrZero(MONTH( _dencerrra),2) + "/" + StrZero(YEAR(_dencerrra),4)
               _csit := posicione("ZFZ",2,ZF5->ZF5_FILIAL + STRZERO(MONTH(_dencerrra),2) + "/" + STRZERO(YEAR(_dencerrra),4),"ZFZ_STATUS")

            Else

               If MONTH(_dencerrra) < 12
                  _cPeriodo := StrZero(MONTH( _dencerrra) + 1 ,2) + "/" + StrZero(YEAR(_dencerrra),4)
                  _csit := posicione("ZFZ",2,ZF5->ZF5_FILIAL + STRZERO(MONTH(_dencerrra)+1,2) + "/" + STRZERO(YEAR(_dencerrra),4),"ZFZ_STATUS")

               Else
                  _cPeriodo :=  "01/" + StrZero(YEAR(_dencerrra)+1,4)
                  _csit := posicione("ZFZ",2,ZF5->ZF5_FILIAL + "01/" + STRZERO(YEAR(_dencerrra)+1,4),"ZFZ_STATUS")

               EndIf

            EndIf

         EndIf

         If _csit == '2' .and. _lret
            _lRet := .F.
            Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - N�o � permitido alterar ocorr�ncia encerrada em per�odo ('+ _cPeriodo + ') j� encerrado!' , 1, 0 )
            Break
         EndIf

         If _csit == '1' .and. _lret .and. !(U_ITVACESS( 'ZZL' , 3 , 'ZZL_OCFRT' , 'C' ))
            _lRet := .F.
            Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - N�o � permitido alterar ocorr�ncia encerrada em per�odo (' + _cPeriodo + ') com encerramento log�stico!' , 1, 0 )
            Break
         EndIf

         //=========================================================================
         // N�o Alterar/Excluir o Tipo de Ocorr�ncia quando a integra��o for do RDC.
         //=========================================================================
         If ! Empty(_oModelGrid:GetValue('ZF5_CODRDC'))

            _lTemPermicao:=U_ITACSUSR('ZZL_EXOCRD','S')

            If (_nOperation == MODEL_OPERATION_DELETE .Or. _oModelGrid:IsDeleted()) .AND. !_lTemPermicao
               _lRet := .F.
               Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Usu�rio sem acesso para excluir ocorr�ncias vindas/integradas do sistema RDC!' , 1, 0 )
               Break
            EndIf

            If _oModelGrid:IsUpdated() // _nOperation == MODEL_OPERATION_UPDATE .Or.
               If AllTrim(ZF5->ZF5_TIPOO) <> AllTrim(_oModelGrid:GetValue('ZF5_TIPOO'))
                  _lRet := .F.
                  Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - N�o � permitido alterar o campo "tipo de ocorr�ncia", das ocorr�ncias vindas/integradas do sistema RDC!' , 1, 0 )
                  Break
               EndIf
            EndIf
         //-----------------------------------------------------------//
         EndIf

      Next _nI

   EndIf

   ZF5->(Restarea(_aarea))

   For _nI := 1 To _oModelGrid:Length()

       _oModelGrid:GoLine(_nI)
       _cEstonado    := _oModelGrid:GetValue("ZF5_ESTONO")
       If _cEstonado = "S" .OR. _oModelGrid:IsDeleted() //SE ESTORNADO OU DELETADO N�O LE PARA VALIDAR
          LOOP
       EndIf

       _cTipoOcorr   := _oModelGrid:GetValue('ZF5_TIPOO')
       _cTipoCusto   := _oModelGrid:GetValue('ZF5_TIPOC')   // Tipo de custo.
       _nCustoIt     := _oModelGrid:GetValue('ZF5_CUSTOI')  // Custo Italac
       _nCustoCli    := _oModelGrid:GetValue('ZF5_CUSTOC')  // Custo cliente
       _nCustoRepr   := _oModelGrid:GetValue('ZF5_CUSTOR')  // Custo Representante
       _nCustoTransp := _oModelGrid:GetValue('ZF5_CUSTOT')  // Custo Transportador
       _nCustoTerc   := _oModelGrid:GetValue('ZF5_CUSTER')  // Custo Terceiro
       _cGerDevol    := _oModelGrid:GetValue('ZF5_DEVOL')   // Gera Devolu��o S/N
       _cServOcorr   := _oModelGrid:GetValue('ZF5_SERVIC')  // Servi�o Ocorr�ncia - 1=Descarga;2=Deslocamento;3=Diaria;4=Reentrega;5=outros
       _cNfDev       := _oModelGrid:GetValue('ZF5_DOCDEV')  // Nota Fiscal de devolu��o
       _cSerDev      := _oModelGrid:GetValue('ZF5_SERDEV')  // Serie da Nota Fiscal de Devolu��o
       _nvaltransp   := _oModelGrid:GetValue('ZF5_CUSTOT')    //Custo transportador transportador
       _cndebit      := _oModelGrid:GetValue('ZF5_NDEBIT')   // Nota de debito
       _ctipocus     := _oModelGrid:GetValue('ZF5_TIPOC')   // Tipo de custo
       _cStatus      := _oModelGrid:GetValue('ZF5_STATUS')   // Status da ocorr�ncia
       _cCodigo      := ALLTRIM(STR(VAL(_oModelGrid:GetValue('ZF5_CODIGO'))))  // C�digo da ocorr�ncia por nota
       _cpeddev      := _oModelGrid:GetValue('ZF5_PEDDEV')

       ZFC->(DbSetOrder(1))
       ZFC->(DbSeek(xFilial("ZFC")+_cTipoOcorr))

       If !Empty(ZFC->ZFC_CUSTO) .And. ZFC->ZFC_CUSTO <>  _cTipoCusto
          _lRet := .F.
          Help( ,, "Aten��o",, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + " - O tipo de custo informado ("+_cTipoCusto+"), difere do tipo de custo do tipo de ocorr�ncia: ("+ZFC->ZFC_CUSTO+")", 1, 0 )
          Exit
       ElseIf _cTipoCusto == "I" // Italac
          If Empty(_nCustoIt)
             _lRet := .F.
             Help( ,, "Aten��o",, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + " - O campo custo italac deve ser preenchido.", 1, 0 )
             Exit
          ElseIf ! Empty(_nCustoRepr) .Or. ! Empty(_nCustoCli) .Or. ! Empty(_nCustoTerc)
             _lRet := .F.
             Help( ,, "Aten��o",, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + " - Por ter selecionado o tipo de custo Italac, voc� deve preencher apenas o campo de valor de custo Italac.", 1, 0 )
             Exit
          EndIf
       ElseIf _cTipoCusto == "T" // Transportador
          If Empty(_nCustoTransp)
             _lRet := .F.
             Help( ,, "Aten��o",, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + " - O campo custo transportador deve ser preenchido.", 1, 0 )
             Exit
          EndIf
       ElseIf _cTipoCusto $ "RV" // Representante Externo / Vendedor Interno
          If Empty(_nCustoRepr)
             _lRet := .F.
             Help( ,, "Aten��o",, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + " - O campo custo representante deve ser preenchido.", 1, 0 )
             Exit
          ElseIf ! Empty(_nCustoCli) .Or. ! Empty(_nCustoTerc) .Or. !Empty(_nCustoIt)
             _lRet := .F.
             Help( ,, "Aten��o",, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + " - Por ter selecionado o tipo de custo Representante, voc� deve preencher apenas o campo de valor de custo Representante.", 1, 0 )
             Exit
          EndIf
       ElseIf _cTipoCusto == "C" // Cliente
          If Empty(_nCustoCli)
             _lRet := .F.
             Help( ,, "Aten��o",, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + " - O campo custo cliente precisa ser preenchido.", 1, 0 )
             Exit
          ElseIf ! Empty(_nCustoRepr) .Or. ! Empty(_nCustoTerc) .Or. !Empty(_nCustoIt)
             _lRet := .F.
             Help( ,, "Aten��o",, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + " - Por ter selecionado o tipo de custo Cliente, voc� deve preencher apenas o campo de valor de custo Cliente.", 1, 0 )
             Exit
          EndIf

       ElseIf _cTipoCusto == "3" // Terceiros
          If Empty(_nCustoTerc)
             _lRet := .F.
             Help( ,, "Aten��o",, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + " - O campo custo de Terceiros precisa ser preenchido.", 1, 0 )
             Exit
          ElseIf ! Empty(_nCustoRepr) .Or. !Empty(_nCustoIt) .Or. ! Empty(_nCustoCli)
             _lRet := .F.
             Help( ,, "Aten��o",, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + " - Por ter selecionado o tipo de custo Terceiro, voc� deve preencher apenas o campo de valor de custo Terceiro.", 1, 0 )
             Exit
          EndIf
       EndIf

       If _cGerDevol == "S"
          If Empty(_cNfDev) .Or. Empty(_cSerDev)
             _lRet := .F.
             Help( ,, "Aten��o",, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + " - O numero e s�rie da nota fiscal de devolu��o devem ser preenchidos, pois o tipo de custo informado gera devolu��o.", 1, 0 )
             Exit
          EndIf
       EndIf

       If !Empty(ZFC->ZFC_SERVI) .And. _cServOcorr <> ZFC->ZFC_SERVI
          _lRet := .F.
          Help( ,, "Aten��o",, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + " - O tipo de servi�o informado ( "+_cServOcorr+" ) difere de tipo de servi�o do tipo de ocorr�ncia: ( "+ZFC->ZFC_SERVI+" )", 1, 0 )
          Exit
       EndIf

       //Se est� validado e � exclus�o ou altera��o de encerrado para outro status
       // e tem nota de d�bito, tenta deletar o t�tulo vinculado
       If _lRet .AND. ( _nOperation == MODEL_OPERATION_DELETE .OR.;
          (_nOperation == MODEL_OPERATION_UPDATE .AND.  ( _oModelGrid:IsDeleted()  .OR.   _oModelGrid:IsUpdated() )) )

          ZF5->(Dbsetorder(4))
          If ZF5->(DbSeek(_cfilial+_cdococ+_cserie+_oModelGrid:GetValue('ZF5_CODIGO')))

            //Exclui pedido de descarte se existir
            If POSICIONE("ZFD",1,xFilial("ZFD")+_cStatus,"ZFD_STATUS") != "E" .and. POSICIONE("ZFD",1,xFilial("ZFD")+ZF5->ZF5_STATUS,"ZFD_STATUS") == "E"
               SC5->(Dbsetorder(1))
               If SC5->(DbSeek(xfilial("SC5")+_cpeddev))
                  If u_itmsg("Existe pedido de descarte para essa ocorr�ncia. Pedido ser� excluido com a reabertura da ocorr�ncia. Deseja continuar?",;
                                     "Aten��o","Pedido: "+xfilial("SC5")+" "+_cpeddev+' - Ocorr�ncia: ' + STRZERO(VAL(_cCodigo),6),2,2,2)
                     //Tenta fazer exclus�o do pedido de descarte
                     _lret := AOMS003DP()
                     If !_lret
                        Break
                     EndIf
                  Else
                     Help( ,, 'Aten��o',, 'Processo cancelado' , 1, 0 )
                     _lRet := .F.
                     Break
                  EndIf
               Else
                  _oModelGrid:LoadValue('ZF5_PEDDEV','')
                  _cpeddev := ''
               EndIf
            EndIf
         //EXCLUI TITULO DE D�BITO SE EXISTIR
            If POSICIONE("ZFD",1,xFilial("ZFD")+ZF5->ZF5_STATUS,"ZFD_STATUS") == "E" .and. POSICIONE("ZFD",1,xFilial("ZFD")+_cStatus,"ZFD_STATUS") != "E"
               If ZF5->ZF5_NDEBIT == "S"
                  _cfilold := cfilant
                  //Se for nota de faturamento de um troca nota muda para a filial de carregamento para incluir a nota de d�bito
                  SF2->(Dbsetorder(1))
                  If SF2->(DbSeek(xfilial("SF2")+_cNotaFiscal+_cSerie))
                     SC5->(Dbsetorder(1))
                     If SC5->(DbSeek(xfilial("SC5")+SF2->F2_I_PEDID))
                         If SC5->C5_I_TRCNF = "S" .AND. SC5->C5_I_FLFNC != SC5->C5_FILIAL
                             cfilant := SC5->C5_I_FLFNC
                         EndIf
                     EndIf
                  EndIf
                  _cFornece:=""
                  _cLoja:=""
                  If ZF5->ZF5_TIPOC == "T"
                     _cFornece := ALLTRIM(ZF5->ZF5_TRANSP)
                     _cLoja    := ZF5->ZF5_LJTRAN
                  Elseif ZF5->ZF5_TIPOC == "3"
                     _cFornece := ZF5->ZF5_FORTER
                     _cLoja    := ZF5->ZF5_LOJTER
                  Endif

                  IF !EMPTY(ZF5->ZF5_CHVNDT)
                     IF LEN(ALLTRIM(ZF5->ZF5_CHVNDT)) = LEN(SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM)//CHAVE SEM PARCELA
                        _cSeekSE2:=ZF5->ZF5_CHVNDT + "01" + "NDF"+_cFornece+_cLoja//A chave e o cfilant j� estam com a filai certa
                     Else//CHAVE COM PARCELA - NOVO
                        _cSeekSE2:=ZF5->ZF5_CHVNDT + "NDF"+_cFornece+_cLoja//A chave e o cfilant j� estam com a filai certa
                     Endif
                  ELSE
                    _cSeekSE2:=xfilial("SE2")+"NDT"+SUBSTR(_cNotaFiscal,2,8) + _cCodigo + "01" + "NDF"//o cfilant j� t� na filial certa
                  EndIf
                  SE2->(Dbsetorder(1))
                  If SE2->(DbSeek(_cSeekSE2))
                     //EXCLUI T�TULO DE D�BITO
                     _lerro := !(AOMS003DT( ZF5->(RECNO()),_oModelGrid ))
                     If _lerro
                        // J� D� MENSAGEM DE ERRO DENTRO DA FUN��O AOMS003DT ()
                        //Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Erro ao excluir t�tulo de nota de d�bito, ocorr�ncia n�o ser� salva/apagada.' , 1, 0 )
                        _lRet := .F.
                        cfilant := _cfilold
                        Break
                     EndIf
                  EndIf
               EndIf
               cfilant := _cfilold
            EndIf

          EndIf
       EndIf
   Next _nI

   cfilant := _cfilold

   IF _lret  .AND. (_nOperation == MODEL_OPERATION_INSERT .OR. _nOperation == MODEL_OPERATION_UPDATE)

      ZF5->(Dbsetorder(4))
      _cNotaFiscal := _oModelMaster:GetValue("ZF5_DOCOC")
      _cSerie      := _oModelMaster:GetValue("ZF5_SEROC")
      For _nI := 1 To _oModelGrid:Length()

         _oModelGrid:GoLine(_nI)
         _cEstonado:= _oModelGrid:GetValue("ZF5_ESTONO",_nI)
         If _cEstonado = "S" .OR. _oModelGrid:IsDeleted() //SE ESTORNADO OU DELETADO N�O LE
            LOOP
         EndIf
         _cCodigo  := _oModelGrid:GetValue('ZF5_CODIGO',_nI)  // C�digo da ocorr�ncia por nota
         _cStatus  := _oModelGrid:GetValue('ZF5_STATUS',_nI)  // Status da ocorr�ncia
         _cTipoO   := _oModelGrid:GetValue('ZF5_TIPOO' ,_nI)  // Tipo de ocorr�ncia

         //Posiciona no registro gravado no banco para comparar
         lAchou:=ZF5->(DbSeek(xfilial("ZF5")+_cNotaFiscal+_cserie+_cCodigo))
         lEncerrou:= POSICIONE("ZFD",1,xFilial("ZFD")+_cStatus,"ZFD_STATUS") == "E" .AND.;
                     (!lAchou .OR. POSICIONE("ZFD",1,xFilial("ZFD")+ZF5->ZF5_STATUS,"ZFD_STATUS") != "E")//PARA N�O ENVIAR DE NOVO O ="E" GRAVADO

         //SE STATUS EST� ENCERRANDO, ENVIA E-MAIL DE COBRAN�A
         If lEncerrou .AND. !_lEnviou
            //SE GRAVA��O � V�LIDA SOLICITA ENVIO DE EMAIL DE COBRAN�A
            //SE FOR DEVOLU��O.
            _cEnvCob := Posicione("ZFC",1,xFilial("ZFC")+_cTipoO,"ZFC_ENVCOB")
            If _cEnvCob == "S" .And. U_ITMSG("Envia cancelamento de cobran�a para nota " + _cNotaFiscal + " com ocorr�ncia de devolu��o?","Aten��o",'Cancelamento do Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6),2,2,2)
               _cMotivo:= _oModelGrid:GetValue('ZF5_MOTIVO',_nI)  // Motivo da ocorr�ncia
                _cMotcus:= _oModelGrid:GetValue('ZF5_MOTCUS',_nI)  // Motivo do Custo
               //ENVIA WF DE CANCELAMENTO DE COBRAN�A
               U_AOMS003J(_cNotaFiscal,_cserie, .T.,.F. ,_cTipoO + "-" + ALLTRIM(_cMotivo),_cMotcus)
            EndIf
         EndIf

          _lPendente:= !lAchou .AND. (_cStatus == '000006'.AND. Posicione("ZFC",1,xFilial("ZFC")+_cTipoO,"ZFC_ENVREP") = "S")

          If _lPendente//ENVIA WF AO COMERCIAL
             
             _lEmail := .T.
             _aOcorreIt:= {}
             aAdd(_aOcorreIt,_oModelGrid:GetValue("ZF5_DTOCOR"))//01
             aAdd(_aOcorreIt,_oModelGrid:GetValue("ZF5_CODIGO"))//02
             aAdd(_aOcorreIt,_oModelGrid:GetValue("ZF5_MOTIVO"))//03
             aAdd(_aOcorreIt,_oModelGrid:GetValue("ZF5_MOTCUS"))//04
             aAdd(_aOcorreIt,_oModelGrid:GetValue("ZF5_TIPOO "))//05
             aAdd(_aOcorreIt,_oModelGrid:GetValue("ZF5_TRANSP"))//06
             aAdd(_aOcorreIt,_oModelGrid:GetValue("ZF5_LJTRAN"))//07
             aAdd(_aOcorreIt,_oModelGrid:GetValue("ZF5_NTRANS"))//08
             AADD(_aDadosEmailCom,_aOcorreIt)
          EndIf
      NEXT _nI
   EndIf

   ZF5->(Restarea(_aarea))

 End Sequence

 cfilant := _cFilSalva

 If !_lret
     disarmtransaction()
    _lEmail := .F.
    _oModelGrid:GoLine(_nSlvaLin)
 EndIf

 End Transaction

 RestOrd(_aOrd)
 FwRestArea(_aAreaM0)

Return _lRet

/*
===============================================================================================================================
Programa--------: AOMS003S
Autor-----------: Julio de Paula Paz
Data da Criacao-: 09/08/2016
Descri��o-------: Rotina de exibi��o e sele��o de dados para aprova��o ou rejei��o.
Parametros------: _cOpcao = Op��o selecionada pelo usu�rio = "REJEITAR" ou "APROVAR"
Retorno   ------: Nenhum
===============================================================================================================================
*/
User Function AOMS003S(_cOpcao)
 Local _lInverte := .F.
 Local _lRet := .F.
 Local _aSizeAut  := MsAdvSize(.T.)
 Local _bOk, _bCancel , _cTitulo
 Local _aCores
 Local _nLin1,_nCol1, _nLin2, _nCol2
 Local _aStructZF5
 Local _aOrd := SaveOrd({"ZF5"})
 Local _cMsg, _nI
 Local _oTemp

 Private _aCampos := {}
 Private _oMarkApr, _oDlgApr
 Private _cMarcaApr  := GetMark()
 Private _lMontaTela := .T.
 Private _cCodAprovar  := U_ITGETMV( 'IT_APROVAR' , '')
 Private _cCodRejeitar := U_ITGETMV( 'IT_REJEITAR' , '')
 Private aHeader := {}

 Begin Sequence
   aHeader := {}
   FillGetDados(1,"ZF5",1,,,{||.T.},,,,,,.T.)
   nUsado := Len(aHeader)

   //================================================================================
   // Define as cores dos itens de legenda.
   //================================================================================
   _aCores := {}
   aAdd(_aCores,{'POSICIONE("ZFD",1,xFilial("ZFD")+TRBZF5->ZF5_STATUS,"ZFD_STATUS")=="P"',"BR_VERDE"	})    // Pendente
   aAdd(_aCores,{'POSICIONE("ZFD",1,xFilial("ZFD")+TRBZF5->ZF5_STATUS,"ZFD_STATUS")=="E"',"BR_VERMELHO"	})    // Efetivado
   aAdd(_aCores,{'POSICIONE("ZFD",1,xFilial("ZFD")+TRBZF5->ZF5_STATUS,"ZFD_STATUS")=="N"',"BR_CINZA"	})    // N�o Procede
   aAdd(_aCores,{'POSICIONE("ZFD",1,xFilial("ZFD")+TRBZF5->ZF5_STATUS,"ZFD_STATUS")=="T"',"BR_AMARELO"	})    // Em tratamento

   If _cOpcao == "REJEITAR"
      _cTitulo := "Gest�o de Ocorr�ncias de Frete - Rejei��o de Ocorr�ncias"
   Else // "APROVAR"
      _cTitulo := "Gest�o de Ocorr�ncias de Frete - Aprova��o de Ocorr�ncias"
   EndIf

   // Cria tabela tempor�ria.
   _aStructZF5 := ZF5->(DbStruct())
   _nI := Ascan(_aStructZF5,{|x| x[1]="ZF5_STATC"})
   _aStructZF5[_nI,3] := 25 // Altera o tamanho do campo "ZF5_STATC" para 25 posi��es.

   _nI := Ascan(_aStructZF5,{|x| x[1]="ZF5_STATUS"})
   _aStructZF5[_nI,3] := 25 // Altera o tamanho do campo "ZF5_STATUS" para 25 posi��es.

   Aadd(_aStructZF5,{"WK_OK"   ,"C",2	,0 })
   Aadd(_aStructZF5,{"WKRECNO" ,"N",10  ,0 })

   // Abre o arquivo TRBZF5 criado dentro do banco de dados protheus.
   _oTemp := FWTemporaryTable():New( "TRBZF5",  _aStructZF5 )

   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _oTemp:AddIndex( "01", {"ZF5_DOCOC","ZF5_SEROC"} )
   _oTemp:Create()


   //================================================================================
   // Carrega dados na tabela tempor�ria.
   //================================================================================
   Processa( {||U_AOMS003D(  ) } , 'Aguarde!' , 'Filtrando dados...' )

   //================================================================================
   // Monta colunas do MsSelect
   //================================================================================
                    //Campo         , "" , Titulo                          , Picture
   Aadd( _aCampos , { "WK_OK"		,    , "Marca"                         ,"@!"})
   Aadd( _aCampos , { "ZF5_CODIGO"  , "" , "Codigo Ocorr"                  ,"@!"})

   For _nI := 1 To Len(aHeader)
       If X3Uso(aHeader[_nI,7]) .And. AllTrim(aHeader[_nI,2]) <> "ZF5_CODIGO"
          Aadd( _aCampos , { aHeader[_nI,2]		, "" , Alltrim(aHeader[_nI,1]) , aHeader[_nI,3]})
       EndIf
   Next _nI

   _bOk := {|| If(U_AOMS003L(_cOpcao),(_lRet := .T., _oDlgApr:End()),)}
   _bCancel := {|| _lRet := .F., _oDlgApr:End()}

   TRBZF5->(DbGotop())

   //================================================================================
   // Monta a tela de dados com MSSELECT.
   //================================================================================
   _nLin1 := 9
   _nCol1 := 0
   _nLin2 := _aSizeAut[6] * 0.079023  // 55
   _nCol2 := _aSizeAut[5] * 0.126138  // 194

   _aButtons:={}
   AADD(_aButtons,{"",{|| U_AOMS003F("T") },"Marc/Des","Marca/Desmarca Todos"})
   AADD(_aButtons,{"",{|| U_AOMS003G()    },"Legenda" ,"Legenda"})

   Define MsDialog _oDlgApr Title _cTitulo From _nLin1,_nCol1 To _nLin2,_nCol2 Of oMainWnd

      _oMarkApr := MsSelect():New("TRBZF5","WK_OK","",_aCampos,@_lInverte, @_cMarcaApr,{_aSizeAut[7]+20, 5, _aSizeAut[4], _aSizeAut[3]}) //,,,,,_aCores)
      _oMarkApr:bAval := {|| U_AOMS003F("P")}
      _lMontaTela := .F.
      _oDlgApr:lMaximized:=.T.

   Activate MsDialog _oDlgApr On Init (EnchoiceBar(_oDlgApr,_bOk,_bCancel,,_aButtons), _oMarkApr:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT , _oMarkApr:oBrowse:Refresh() )

   If _lRet
      If _cOpcao == "REJEITAR"
         _cMsg := "Confirma a rejei��o da(s) ocorr�ncia(s) de frete selecionada(s) e a altera��o de seu Status?"
      Else  // "APROVAR"
         _cMsg := "Confirma a aprova��o da(s) ocorr�ncia(s) de frete selecionada(s) e a altera��o de seu Status?"
      EndIf

      If !U_ITMSG(_cMsg,'Aten��o!',,2,2,2)
         Break
      EndIf

      If _cOpcao == "APROVAR"
         If Empty(_cCodAprovar)
            U_ITMSG("C�digo de 'Status' da aprova��o da ocorr�ncia n�o preenchido no par�metro IT_APROVAR. N�o � poss�vel aprovar a ocorr�ncia.","Aten��o",,1)
            Break
         EndIf

         ZFD->(DbSetOrder(1)) // ZFD_FILIAL+ZFD_CODIGO
         If ! ZFD->(DbSeek(xFilial("ZFD")+_cCodAprovar))
            U_ITMSG("C�digo de 'Status' da aprova��o da ocorr�ncia n�o cadastrado no cadastro de Status de Ocorr�ncias. N�o � poss�vel aprovar a ocorr�ncia.","Aten��o",,1)
            Break
         EndIf
      Else
         If Empty(_cCodRejeitar)
            U_ITMSG("C�digo de 'Status' de rejei��o da ocorr�ncia n�o preenchido no par�metro IT_REJEITAR. N�o � poss�vel rejeitar a ocorr�ncia.","Aten��o",,1)
            Break
         EndIf

         ZFD->(DbSetOrder(1)) // ZFD_FILIAL+ZFD_CODIGO
         If ! ZFD->(DbSeek(xFilial("ZFD")+_cCodRejeitar))
            U_ITMSG("C�digo de 'Status' da rejei��o da ocorr�ncia n�o cadastrado no cadastro de Status de Ocorr�ncias. N�o � poss�vel rejeitar a ocorr�ncia.","Aten��o",,1)
            Break
         EndIf
      EndIf

      _lAtualizou := .F.

      TRBZF5->(DbGoTop())
      Do While ! TRBZF5->(Eof())
         If ! Empty(TRBZF5->WK_OK)
            ZF5->(DbGoTo(TRBZF5->WKRECNO))
            If _cOpcao == "REJEITAR"
               ZF5->(RecLock("ZF5",.F.))
               ZF5->ZF5_STATUS := _cCodRejeitar
               ZF5->ZF5_APRREJ := "R" // Rejeitado
               ZF5->ZF5_USRAPR := SubStr(cUsuario, 7,15)
               ZF5->ZF5_DTAPRR := Date()
               ZF5->ZF5_HRAPRR := Substr(Time(),1,5)
               ZF5->(MsUnLock())
               _lAtualizou := .T.
            Else  // "APROVAR"
               _lAtualizou := .T.
               ZF5->(RecLock("ZF5",.F.))
               ZF5->ZF5_STATUS := _cCodAprovar
               ZF5->ZF5_APRREJ := "A" // Aprovado
               ZF5->ZF5_USRAPR := SubStr(cUsuario, 7,15)
               ZF5->ZF5_DTAPRR := Date()
               ZF5->ZF5_HRAPRR := Substr(Time(),1,5)
               ZF5->(MsUnLock())
            EndIf
         EndIf

         TRBZF5->(DbSkip())
      EndDo

      If _cOpcao == "APROVAR"
         If _lAtualizou
            U_ITMSG("Aprova��o realizada com sucesso.","Aten��o",,1)
         Else
            U_ITMSG("N�o foi poss�vel realizar a aprova��o.","Aten��o",,1)
         EndIf
      Else
         If _lAtualizou
            U_ITMSG("Rejei��o realizada com sucesso.","Aten��o",,1)
         Else
            U_ITMSG("N�o foi poss�vel realizar a rejei��o.","Aten��o",,1)
         EndIf
      EndIf
   EndIf

 End Sequence

 TRBZF5->(DbCloseArea())

 RestOrd(_aOrd)

Return Nil

/*
===============================================================================================================================
Programa--------: AOMS003D
Autor-----------: Julio de Paula Paz
Data da Criacao-: 17/08/2016
Descri��o-------: Carrega os dados das ocorr�ncias de frete filtrados do Comercial, para sele��o e aprova��o ou rejei��o.
Parametros------: Nenhum
Retorno   ------: Nenhum
===============================================================================================================================
*/
User Function AOMS003D()
 Local _cQry, _nTotreg
 Local _nRegAtu := ZF5->(Recno())
 Local _nI, _nJ
 Local _aStatusC := {}
 Local cAlias:=GetNextAlias()

 Begin Sequence

    _aStatusC := {{"P","PENDENTE"},{"T","TRATAMENTO"},{"E","ENCERRADO"},{"S","SEM CUSTO"} }

    _cQry := " SELECT ZF5.R_E_C_N_O_ AS NRRECNO FROM "+RetSqlName("ZF5")+" ZF5 "
    _cQry += " WHERE ZF5.D_E_L_E_T_ = ' ' AND ZF5_FILIAL = '"+xFilial("ZF5")+"' "

    MPSysOpenQuery( _cQry , cAlias )

    DbSelectArea(cAlias)
    COUNT TO _nTotreg

    If _nTotreg = 0
       U_ITMSG("N�o existem ocorr�ncias de frete a serem exibidas.","Aten��o",,1)
       Break
    EndIf

    ProcRegua(_nTotreg)

    (cAlias)->(DbGoTop())
    Do While ! (cAlias)->(Eof())
       IncProc("Filtrando dados de Ocorr�ncias de Frete...")

       ZF5->(DbGoTo((cAlias)->NRRECNO))

       TRBZF5->(DbAppend())
       For _nI := 1 To TRBZF5->(FCount())
           If AllTrim(TRBZF5->(FieldName(_nI))) $ "WK_OK/WKRECNO"
              Loop
           EndIf
           &("TRBZF5->"+TRBZF5->(FieldName(_nI))) :=  &("ZF5->"+TRBZF5->(FieldName(_nI)))
       Next _nI

       TRBZF5->ZF5_STATUS := Posicione("ZFD",1,xFilial("ZFD")+ZF5->ZF5_STATUS,"ZFD_DESCRI")
       _nJ := Ascan(_aStatusC,{|x| x[1]=ZF5->ZF5_STATC})
       TRBZF5->ZF5_STATC :=  If(_nJ > 0,_aStatusC[_nJ,2],"")
       TRBZF5->WKRECNO := (cAlias)->NRRECNO

       (cAlias)->(DbSkip())
    EndDo
    TRBZF5->(DbGoTop())

 End Sequence

 (cAlias)->(DbCloseArea())

 ZF5->(DbGoTo(_nRegAtu))

Return Nil

/*
===============================================================================================================================
Programa--------: AOMS003L
Autor-----------: Julio de Paula Paz
Data da Criacao-: 17/08/2016
Descri��o-------: Verifica se existe registros marcados na tela de ocorr�ncias de frete filtrados do Comercial,
                  para sele��o e aprova��o ou rejei��o.
Parametros------: _cOpcao = Op��o selecionada pelo usu�rio = "REJEITAR" ou "APROVAR"
Retorno   ------: Nenhum
===============================================================================================================================
*/
User Function AOMS003L(_cOpcao)
   Local _lRet := .F.
   Local _cMsg, _lTemMarca
   Local _nRegAtu := TRBZF5->(Recno())

   If _cOpcao == "REJEITAR"
      _cMsg := "N�o existem dados marcados para rejei��o."
   Else  // "APROVAR"
      _cMsg := "N�o existem dados marcados para aprova��o."
   EndIf

   _lTemMarca := .F.

   TRBZF5->(DbGoTop())
   Do While ! TRBZF5->(Eof())
      If ! Empty(TRBZF5->WK_OK)
         _lTemMarca := .T.
         _lRet := .T.
         Exit
      EndIf

      TRBZF5->(DbSkip())
   EndDo

   If ! _lTemMarca
      U_ITMSG(_cMsg,"Aten��o",,1)
   EndIf

   TRBZF5->(DbGoTo(_nRegAtu))

Return _lRet

/*
===============================================================================================================================
Programa--------: AOMS003F
Autor-----------: Julio de Paula Paz
Data da Criacao-: 17/08/2016
Descri��o-------: Fun��o para marcar e desmarcar todas as notas fiscais da carga.
Parametros------: _cTipoMarca = "T" = Marca e desmarca todos os registros.
                  _cTipoMarca = "P" = Marca e desmarca apena o registro posisionado.
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AOMS003F(_cTipoMarca)
    Local _cSimboloMarca := Space(2)
    Local _nRegAtu := TRBZF5->(Recno())

    If Empty(TRBZF5->WK_OK )
       _cSimboloMarca := _cMarcaApr
    Else
       _cSimboloMarca := Space(2)
    EndIf

    If _cTipoMarca == "P"
       TRBZF5->WK_OK := _cSimboloMarca
    Else
       TRBZF5->(DbGoTop())
       Do While ! TRBZF5->(Eof())
          TRBZF5->WK_OK := _cSimboloMarca
          TRBZF5->(DbSkip())
       EndDo

    EndIf

    TRBZF5->(DbGoTo(_nRegAtu))
    _oMarkApr:oBrowse:Refresh()

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS003G
Autor-------------: Julio de Paula Paz
Data da Criacao---: 09/06/2016
Descri��o---------: Legenda da rotina de aprova��o ou rejei��o de ocorr�ncias.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS003G()
   Local _aLegenda := {}

   Aadd(_aLegenda,{"BR_VERDE"    ,"Pendente"})
   Aadd(_aLegenda,{"BR_VERMELHO" ,"Efetivado"})
   Aadd(_aLegenda,{"BR_CINZA"    ,"N�o Procede"})
   Aadd(_aLegenda,{"BR_AMARELO"  ,"Em tratamento"})

   BrwLegenda("Gest�o de Ocorr�ncias de Frete", "Legenda", _aLegenda)


Return Nil

/*
===============================================================================================================================
Programa----------: AOMS003P
Autor-------------: Julio de Paula Paz
Data da Criacao---: 09/06/2016
Descri��o---------: Legenda da rotina de aprova��o ou rejei��o de ocorr�ncias.
Parametros--------: _oModelGrid = Modelo de Dados
                    _nLine      = Linha do grid
                    _cAction    = A��o
                    _cField     = Campo posicionado
Retorno-----------: True (.T.) ou False(.F.)
===============================================================================================================================
*/
User Function AOMS003P(_oModelGrid, _nLine, _cAction, _cField)
 Local _cSituacao    As char
 Local _cUsersHab    As char
 Local _oModel       As Object
 Local _oModelMaster As Object
 Local _nOperation   As Numeric
 Local _lTemSaldo    As Logical
 Local _lAchou       As Logical
 Local lTemObjeto    As Logical
 Local _lRet         := .T.

 Begin Sequence

    IF _cField == "LEGENDA" .AND. _cAction == 'CANSETVALUE'
       _lRet:=.F.
       AOMS03Leg(.F.)
       BREAK //********* SAIDA **********
    EndIf

    _nOperation:= _oModelGrid:GetOperation()
    _cUsersHab := SuperGetMV("IT_USPROTI",.F.,"002355") 
    _lTemSaldo := .F.
    _lAchou    := .F.
    lTemObjeto := .F.

    If _cAction == 'CANSETVALUE' .And. (_cField = "ZF5_TIPOO" .Or. _cField = "ZF5_DTOCOR")//WHEN DOS CAMPOS
       If _nOperation == MODEL_OPERATION_UPDATE .AND. !_oModelGrid:IsInserted()// ALTERANDO OCORENCIA J� GRAVADA
          _cTipoOcorr := _oModelGrid:GetValue("ZF5_TIPOO")
          _cDtTran    :=  Posicione("ZFC",1,xFilial("ZFC")+_cTipoOcorr,"ZFC_DTTRAN") // 1 = ZFC_FILIAL+ZFC_CODIGO
          If !EMPTY(_cTipoOcorr) .AND. _cDtTran $ "A,B,C,D,E,F"
             //Help( ,, 'Aten��o',, 'N�o � permitido alterar ocorr�ncias de frete com o tipo: '+_cDtTran , 1, 0 )
             //ITmsg(_cMens,_ctitu,_csolu,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes)
             IF _oModelGrid:GetValue("ZF5_ESTONO") = "S"
                U_ITmsg( 'N�o � permitido alterar Tipo/Data da ocorr�ncias de frete estornadas.' ,'Aten��o',;
                         "Aperte o DEL nessa ocorr�ncia para cancelar o estorno caso necessaro alterar outros campos.",1,,,.F.)
             Else
                U_ITmsg( 'N�o � permitido alterar Tipo/Data da ocorr�ncias de frete com o tipo igual a '+_cDtTran ,'Aten��o',;
                         "Aperte o DEL nessa ocorr�ncia para estornar-l�, e insira uma nova ocorrencia com as altera��es necessarias",1,,,.F.)
             EndIf
             _lRet := .F.
          EndIf
       EndIf
       BREAK //********* SAIDA **********
    EndIf

    _oModel:=FwModelActivete()//FWLoadModel( "AOMS003" )//oModelGrid:GetModel()
    IF VALTYPE(_oModel) = "O"
       _oModelMaster := _oModel:GetModel("ZF5MASTER")
       IF VALTYPE(_oModelMaster) = "O"
          lTemObjeto:=.T.
       EndIf
    EndIf

    If _cAction == 'DELETE' .AND. _nOperation == MODEL_OPERATION_UPDATE
       _cSituacao := _oModelGrid:GetValue('ZF5_APRREJ')
       If ! Empty(_cSituacao)
          _lRet := .F.
          Help( ,, 'Aten��o',, 'N�o � permitido apagar ocorr�ncias de frete rejeitadas ou aprovadas: '+_cSituacao , 1, 0 , .F. )
       EndIf
    EndIf

    If ZFC->(FIELDPOS("ZFC_PROTIT")) > 0
       IF lTemObjeto
          _cDoc   := _oModelMaster:GetValue("ZF5_DOCOC")
          _cSerie := _oModelMaster:GetValue("ZF5_SEROC")
       EndIf
       _cTipo     := "NF "
       _cCodigo   := _oModelGrid:GetValue("ZF5_CODIGO")
       
       If _cAction == 'DELETE' .AND. _nOperation == MODEL_OPERATION_UPDATE

          _cFilial   := xFilial("ZM4")
          ZFC->(DbSetOrder(1))
          If ZFC->(DbSeek(xFilial("ZFC")+_oModelGrid:GetValue("ZF5_TIPOO")))
             If ZFC->ZFC_PROTIT == "S"
                If __cUserId $ _cUsersHab .AND. _oModelGrid:GetValue("ZF5_DPRORR") > 0
                   ZM4->(dbSetOrder(1))
                   If lTemObjeto .AND. ZM4->(DbSeek(_cFilial+_cDoc+_cSerie+_cTipo+_cCodigo))
                      If ZM4->ZM4_STATUS == "A"
                         _lRet := .F.
                         Help( ,, 'Aten��o',, 'N�o � permitido deletar ocorr�ncias de frete com prorroga��o de vencimento aprovada.' , 1, 0  )
                      EndIf
                   EndIf
                Else
                   _lRet := .F.
                   Help( ,, 'Aten��o',, 'Usu�rio sem permiss�o para utilizar este tipo de ocorrencia.' , 1, 0 , .F.,,,,,{"Para habilitar a utiliza��o solicite ao administrador do sistema."})
                EndIf
             EndIf
          EndIf

       ElseIf _cField == "ZF5_TIPOO" .AND. _cAction == "SETVALUE" .AND. ( _nOperation == MODEL_OPERATION_UPDATE .OR. _nOperation == MODEL_OPERATION_INSERT)

          //Se registro j� gravado n�o deixa aterar ocorrencia qdo for Proroga��o de Vencto
          If _nOperation == MODEL_OPERATION_UPDATE
             ZF5->(DbSetOrder(4)) // ZF5_FILIAL+ZF5_DOCOC+ZF5_SEROC+ZF5_CODIGO
             If lTemObjeto .AND. ZF5->(DbSeek(xFilial("ZF5")+_cDoc+_cSerie+_cCodigo))
                If ZF5->ZF5_TIPOO <> M->ZF5_TIPOO
                   ZFC->(DbSetOrder(1))
                   If ZFC->(DbSeek(xFilial("ZFC")+ZF5->ZF5_TIPOO))
                      If ZFC->ZFC_PROTIT == "S"
                          _lRet := .F.
                          Help( ,, 'Aten��o',, 'N�o � permitido trocar este Tipo de ocorr�ncia de frete.' , 1, 0, .F.,,,,,{"Delete a ocorrencia e inclua uma nova."})
                      EndIf
                   EndIf
                EndIf
             EndIf
          EndIf

          //Verifica se h� saldo nos Titulos qdo for Proroga��o de Vencto
          ZFC->(DbSetOrder(1))
          If ZFC->(DbSeek(xFilial("ZFC")+M->ZF5_TIPOO))
             If ZFC->ZFC_PROTIT == "S"
                If lTemObjeto .AND. __cUserId $ _cUsersHab .AND. _oModelGrid:GetValue("ZF5_DPRORR") > 0
                   _lTemSaldo := .F.
                   _lAchou := .F.
                   SE1->(DbSetOrder(1))
                   If SE1->(DbSeek(xFilial("SE1")+_cSerie+_cDoc+Space(Len(SE1->E1_PARCELA))+_cTipo))
                      _lAchou := .T.
                   ElseIf SE1->(DbSeek(xFilial("SE1")+_cSerie+_cDoc+StrZero(1,Len(SE1->E1_PARCELA))+_cTipo))
                      _lAchou := .T.
                   EndIf

                   If _lAchou
                      Do While SE1->(xFilial("SE1")+_cDoc+_cSerie+_cTipo == E1_FILIAL+E1_NUM+E1_PREFIXO+E1_TIPO) .AND. SE1->(!EOF())
                         If SE1->E1_SALDO > 0
                            _lTemSaldo := .T.
                         EndIf
                         SE1->(DbSkip())
                      EndDo
                      If !_lTemSaldo
                          _lRet := .F.
                          Help( ,, 'Aten��o',, 'N�o � permitido este Tipo de ocorr�ncia de frete pois n�o h� saldo nos titulos para prorroga��o.' , 1, 0 , .F.,,,,,{"Selecione outro tipo de ocorrencia."})
                      EndIf
                   Else
                      _lRet := .F.
                      Help( ,, 'Aten��o',, 'N�o � permitido este Tipo de ocorr�ncia de frete pois n�o h� titulos para prorroga��o.' , 1, 0 , .F.,,,,,{"Selecione outro tipo de ocorrencia."})
                   EndIf
                ElseIF !__cUserId $ _cUsersHab .AND. _oModelGrid:GetValue("ZF5_DPRORR") > 0
                   _lRet := .F.
                   Help( ,, 'Aten��o',, 'Usu�rio em permiss�o para utilizar este tipo de ocorrencia.' , 1, 0 , .F.,,,,,{"Para habilitar a utiliza��o comunique o administrador do sistema."})
                EndIf
             EndIf
          EndIf
       EndIf
    EndIf

    // *******************  COLOQUE VALIDA�OES NOVAS ANTES DESSE IF POIS ELE ALTERA O CAMPO ZF5_ESTONO E LEGENDA ************************************
    If _cAction == 'DELETE'  .AND. _nOperation == MODEL_OPERATION_UPDATE .AND. !_oModelGrid:IsInserted()
       _cTipoOcorr := _oModelGrid:GetValue("ZF5_TIPOO")
       _cDtTran    :=  Posicione("ZFC",1,xFilial("ZFC")+_cTipoOcorr,"ZFC_DTTRAN") // 1 = ZFC_FILIAL+ZFC_CODIGO
       If _cDtTran $ "A,B,C,D,E,F"
          IF _oModelGrid:GetValue("ZF5_ESTONO") = "S"
             _oModelGrid:SetValue("ZF5_ESTONO","N")
             _oModelGrid:SetValue("ZF5_MOTCUS","Estorno Cancelado em "+Dtoc(Date())+" "+Substr(Time(),1,5)+" por "+Capital( AllTrim( UsrFullName( __cUserId ) ) ) )
             U_ITmsg( 'Cancelamento do estorno da Ocorrencia feito com sucesso.' ,'Aten��o',;
                      "caso necessario, aperte o DEL nessa ocorr�ncia novamente para estornar-l�.",2,,,.T.)
          Else
             _oModelGrid:SetValue("ZF5_ESTONO","S")
             _oModelGrid:SetValue("ZF5_MOTCUS","Estornado em "+Dtoc(Date())+" "+Substr(Time(),1,5)+" por "+Capital( AllTrim( UsrFullName( __cUserId ) ) ) )
             U_ITmsg( 'Ocorrencia estornada com sucesso.' ,'Aten��o',;
                      "caso necessario, aperte o DEL nessa ocorr�ncia novamente para cancelar o estorno.",2,,,.T.)
          EndIf
          _oModelGrid:SetValue("LEGENDA",AOMS03Leg(.T.))// REGRAVA A LEGENDA
          _lRet:= .F.
       EndIf
    EndIf

 End Sequence

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS003E
Autor-------------: Julio de Paula Paz
Data da Criacao---: 09/06/2016
Descri��o---------: Pr� valida��o da exclus�o de ocorr�ncias.
Parametros--------: _oModel = Modelo de Dados
Retorno-----------: True (.T.) ou False(.F.)
===============================================================================================================================
*/
User Function AOMS003E(_oModel)
 Local _lRet := .T.
 Local _nOperation := _oModel:GetOperation()
 Local _oModelGrid := _oModel:GetModel("ZF5DETAIL")
 Local _nI, _cSituacao

 Begin Sequence
    If _nOperation == MODEL_OPERATION_DELETE
       For _nI := 1 To _oModelGrid:Length()
           _oModelGrid:GoLine(_nI)
           _cEstonado:= _oModelGrid:GetValue("ZF5_ESTONO",_nI)
           If _cEstonado = "S" //SE ESTORNADO N�O LE
              LOOP
           EndIf
           _cSituacao := _oModelGrid:GetValue('ZF5_APRREJ')

           If ! Empty(_cSituacao)
              _lRet := .F.
              Help( ,, 'Aten��o',, 'N�o permitido apagar ocorr�ncias de frete rejeitadas ou aprovadas.' ,1, 0 , .F. )
              Exit
           EndIf
       Next nI
    EndIf

 End Sequence

Return _lRet

/*
===============================================================================================================================
Programa--------: AOMS003R
Autor-----------: Julio de Paula Paz
Data da Criacao-: 18/07/2016
Descri��o-------: Verifica se realmente houve altera��es na linha de grid posicionada. Ou seja, se h� diferen�a entre os dados
                  da tela e os dados gravados na base de dados.
Parametros------:  _oModelGrid = Modelo do grid de dados
                   _nLinha     = Numero da linha posicionada
Retorno   ------: True ou False.
===============================================================================================================================
*/
User Function AOMS003R( _oModel, _nLinha)
 Local _lRet := .F.
 Local _aOrd := SaveOrd({"ZF5"})
 Local _nRegAtu := ZF5->(Recno())
 Local _nI
 Local _oModelMaster := _oModel:GetModel("ZF5MASTER")
 Local _oModelGrid   := _oModel:GetModel("ZF5DETAIL")
 Local _aCpoDetail  := {}
 Local _nTotCampos
 Local _cNotaFiscal, _cSerie, _cCodigo

 Begin Sequence
    ZF5->(DbSetOrder(4)) // ZF5_FILIAL+ZF5_DOCOC+ZF5_SEROC+ZF5_CODIGO
    _nTotCampos := ZF5->(FCount())

    For _nI := 1 To _nTotCampos
        If AOMS003CPO(AllTrim(ZF5->(FieldName(_nI))) , 2 )
            Aadd(_aCpoDetail, AllTrim(ZF5->(FieldName(_nI))))
        EndIf
    Next _nI

   _cNotaFiscal := _oModelMaster:GetValue("ZF5_DOCOC")
   _cSerie      := _oModelMaster:GetValue("ZF5_SEROC")
   _cCodigo     := _oModelGrid:GetValue("ZF5_CODIGO")

   If ZF5->(DbSeek(xFilial("ZF5")+_cNotaFiscal+_cSerie+_cCodigo))
      For _nI := 1 To Len(_aCpoDetail)
          //====================================================================================
          // Compara o conte�do dos campos da base de dados com o conte�do dos campos de grid,
          // e informa se houve altera��o.
          //====================================================================================
          If ZF5->&(_aCpoDetail[_nI]) <> _oModelGrid:GetValue(_aCpoDetail[_nI])
             _lRet := .T.
             Break
          EndIf
      Next _nI
   EndIf

 End Sequence

 RestOrd(_aOrd)
 ZF5->(DbGoTo(_nRegAtu))

Return _lRet

/*
===============================================================================================================================
Programa--------: AOMS003I
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 18/07/2016
Descri��o-------: Gatilhos do campo de status
Parametros------:  Nenhum
Retorno   ------: _vret - Dados para campo gatilhado
===============================================================================================================================
*/
User Function AOMS003I()
 Local _vret
 Local _oModel
 Local _oModelMaster
 Local _oModelGrid

 _oModel      := FwModelActivete()
 _oModelMaster := _oModel:GetModel("ZF5MASTER")
 _oModelGrid   := _oModel:GetModel("ZF5DETAIL")

 If  !isincallstack("U_AOMS072")


   IF POSICIONE("ZFD",1,xFilial("ZFD")+M->ZF5_STATUS,"ZFD_STATUS") == "E" .AND. EMPTY(_oModelGrid:GetValue("ZF5_USRFIN"))

         _vret := __cUserId
         _oModelGrid:SetValue('ZF5_HRFIN',time())
         _oModelGrid:SetValue('ZF5_DTFIN',date())
           _oModelGrid:SetValue('ZF5_USRFIN', _vret)
         _oModelGrid:SetValue('ZF5_USNFIN', UsrFullName(_vret))

   Elseif POSICIONE("ZFD",1,xFilial("ZFD")+M->ZF5_STATUS,"ZFD_STATUS") == "E"

         _vret := _oModelGrid:GetValue("ZF5_USRFIN")

   Elseif POSICIONE("ZFD",1,xFilial("ZFD")+M->ZF5_STATUS,"ZFD_STATUS") != "E"

         _vret := "    "
         _oModelGrid:SetValue('ZF5_HRFIN',"   ")
         _oModelGrid:SetValue('ZF5_DTFIN',ctod(" / / "))
           _oModelGrid:SetValue('ZF5_USRFIN', "   ")
         _oModelGrid:SetValue('ZF5_USNFIN', "   ")

   EndIf

 Else


     nPosusrf := aScan(aHeader,{|x| AllTrim(x[2]) == "ZF5_USRFIN"})
     nPosdtf := aScan(aHeader,{|x| AllTrim(x[2]) == "ZF5_DTFIN"})
     nPoshrf := aScan(aHeader,{|x| AllTrim(x[2]) == "ZF5_HRFIN"})
     nPosusnf := aScan(aHeader,{|x| AllTrim(x[2]) == "ZF5_USNFIN"})

     IF POSICIONE("ZFD",1,xFilial("ZFD")+M->ZF5_STATUS,"ZFD_STATUS") == "E" .AND. EMPTY(acols[n][nposusrf])

         _vret := __cUserId
         acols[n][nPoshrf] := time()
         acols[n][nPosdtf] := date()
           acols[n][nPosusrf] :=  _vret
         acols[n][nPosusnf] := UsrFullName(_vret)

   Elseif POSICIONE("ZFD",1,xFilial("ZFD")+M->ZF5_STATUS,"ZFD_STATUS") == "E"

         _vret := acols[n][nPosusrf]

   Elseif POSICIONE("ZFD",1,xFilial("ZFD")+M->ZF5_STATUS,"ZFD_STATUS") != "E"

         _vret := "    "
         acols[n][nPoshrf] := " "
         acols[n][nPosdtf] := stod(" ")
           acols[n][nPosusrf] :=  "  "
         acols[n][nPosusnf] := "  "

   EndIf

 EndIf

Return _vret

/*
===============================================================================================================================
Programa--------: AOMS003X
Autor-----------: Julio de Paula Paz
Data da Criacao-: 26/10/2017
Descri��o-------: Valida e n�o permite a digita��o de caracteres especiais de acordo com o conte�do passado por par�metro.
Parametros------: _cDados = informa��o a ser validada.
Retorno   ------: .T. = Os dados est�o corretos. / .F. = Existe caracteres especiais nos dados validados.
===============================================================================================================================
*/
User Function AOMS003X(_cDados)
 Local _lRet := .T.
 Local _nI
 Local _cListaChar
 Local _cDigito

 Begin Sequence
    If Empty(_cDados)
       Break
    EndIf

    _cDados := Alltrim(_cDados)
    _cListaChar := "0123456789 ABCDEFGHIJKLMNOPQRSTUVXYWZ"

    For _nI := 1 To Len(_cDados)
        _cDigito := Upper(SubStr(_cDados,_nI,1))

        If ! _cDigito $ _cListaChar
           _lRet := .F.
           Help( ,, 'Aten��o',, 'N�o � permitido a digita��o de caracteres especiais neste campo. Neste campo s� � permitido a digita��o de letras, numeros e espa�os.', 1, 0, .F. )

           Break
        EndIf
    Next _nI

 End Sequence

Return _lRet


/*
===============================================================================================================================
Programa--------: AOMS03M
Autor-----------: Alex Wallauer
Data da Criacao-: 28/11/2017
Descri��o-------: Encerrar varias ocorrenias
Parametros------: _lAtuTel
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AOMS03M(_lAtuTel)
 LOCAL C
 Local _nI, _cExpr

 Private cAliasAux	:= GetNextAlias(),_cArqTrab
 Private aHeader := {}
 Private aCols   := {}
 Private _lUsaMVC    := .F.
 Private _cNomeFonte := "AOMS003"

 IF _lAtuTel
    aCampos:={"ZF5_STATUS","ZF5_STATUD","ZF5_DOCOC" ,"ZF5_SEROC" ,"ZF5_DMOTOR","ZF5_NREPRE","ZF5_NCOOR","ZF5_NCLIEN","ZF5_DATAE",;
              "ZF5_USNINI","ZF5_PEDIDO","ZF5_CLIENT","ZF5_LOJA"  ,"ZF5_MOTCUS","ZF5_ASSNOM","ZF5_CARGA","ZF5_DTINI" ,"ZF5_HRINI",;
              "ZF5_CODIGO","ZF5_TIPOO" ,"ZF5_MOTIVO","ZF5_AGENDA","ZF5_NTRANS","ZF5_TIPOC"}
 ELSE
    aCampos:={"ZF5_STATUS","ZF5_STATUD","ZF5_DOCOC" ,"ZF5_SEROC" ,"ZF5_DATAE" ,"ZF5_ASSNOM","ZF5_CARGA","ZF5_DTINI" ,"ZF5_HRINI" ,;
              "ZF5_USNINI","ZF5_PEDIDO","ZF5_CLIENT","ZF5_LOJA"  ,"ZF5_NCLIEN","ZF5_NREPRE","ZF5_NCOOR","ZF5_DMOTOR","ZF5_MOTCUS",;
              "ZF5_CODIGO","ZF5_TIPOO" ,"ZF5_MOTIVO","ZF5_AGENDA","ZF5_NTRANS","ZF5_TIPOC"}
 EndIf
 Private _cPerg := "AOMS003"

 //AjustaSX1()
 //================================================================================
 // Valida a parametriza��o inicial e chama fun��o para montagem da tela para
 // sele��o das NF que ter�o os recebimentos de canhoto informados.
 //================================================================================
 If Pergunte(_cPerg,.T.)
    lRet:=.T.
    Processa( {|| lRet:=AOMS03P(.F.,_lAtuTel) } )
    IF !lRet
       U_ITMSG("Sem registros para essa sele��o de dados","Aten��o",,3)
       RETURN
    EndIf
 ELSE
   RETURN
 EndIf

 FillGetDados(1,"ZF5",1,,,{||.T.},,,,,,.T.)

 _aFields:={}
 FOR C :=  1 TO LEN(aCampos)
     _cCampo := PadR(aCampos[C],10)

     _nI := AsCan(aHeader,{|x| AllTrim(x[2]) == AllTrim(_cCampo)})

     If _nI > 0

        _cExpr := U_AOMS03T(AllTrim(_cCampo))

        If _lAtuTel
           If AllTrim(_cCampo) $ "ZF5_DMOTOR/ZF5_NREPRE/ZF5_NCOOR/ZF5_NCLIEN"
              aAdd(_aFields,{ AllTrim( aHeader[_nI,1] )+" ( Tel. Atual )"      , aHeader[_nI,2], aHeader[_nI,8] , aHeader[_nI,4],aHeader[_nI,5],aHeader[_nI,3]})//+" Atual"
              IF !Empty(_cExpr)
                 _cBox:="{||" + _cExpr + "}"                                                                 //  Picture 0,Tamanho Decimal
                 aAdd(_aFields,{AllTrim(aHeader[_nI,1] )+" ( Tel. Atualizado )", &(_cBox)      , aHeader[_nI,8] ,"@!"   ,0,50     ,0      })
              EndIf
              LOOP//////////////////// LOOP
           EndIf
        EndIf

        If Empty(_cExpr)// Titulo                      Campo           Tipo             Tamanho        Decimal         Picture
           aAdd(_aFields,{ AllTrim( aHeader[_nI,1] ) , aHeader[_nI,2], aHeader[_nI,8] , aHeader[_nI,4],aHeader[_nI,5],aHeader[_nI,3]})
        Else
           _cBox:="{||" + _cExpr + "}"
           //              Titulo                     Codeblock Tipo           Picture 0,Tamanho Decimal
           aAdd(_aFields,{ AllTrim( aHeader[_nI,1] ), &(_cBox) ,aHeader[_nI,8],"@!"   ,0,50     ,0      })
        EndIf


     EndIf
 NEXT C

 aHeader := {}
 aCols   := {}

 (cAliasAux)->( DBGOTOP() )
 oMarkBRW:=FWMarkBrowse():New()		   											// Inicializa o Browse
 oMarkBRW:SetAlias( cAliasAux )			   										// Define Alias que ser� a Base do Browse
 oMarkBRW:SetDescription( "Ocorrencias de frete para ATUALIZAR TELEFONES" )	// Define o titulo do browse de marcacao
 oMarkBRW:SetFieldMark( "MARCA" )												// Define o campo que sera utilizado para a marca��o
 oMarkBRW:SetMenuDef( 'XXXXXX' )													// For�a a utiliza��o do menu da rotina atual
 oMarkBRW:SetAllMark( {|| oMarkBRW:AllMark()} )									// A��o do Clique no Header da Coluna de Marca��o

 IF _lAtuTel
    oMarkBRW:SetValid( {|| ((cAliasAux)->STATUS2="S") } )
    oMarkBRW:AddLegend('(cAliasAux)->STATUS2="S"',"RED"  , "DIFERENTE")// Permite adicionar legendas no Browse
    oMarkBRW:AddLegend('(cAliasAux)->STATUS2="N"',"GREEN", "IGUAL"    )// Permite adicionar legendas no Browse
 ELSE
    oMarkBRW:AddLegend('POSICIONE("ZFD",1,xFilial("ZFD")+(cAliasAux)->ZF5_STATUS,"ZFD_STATUS")=="P"',"GREEN", "Pendente"     )// Permite adicionar legendas no Browse
    oMarkBRW:AddLegend('POSICIONE("ZFD",1,xFilial("ZFD")+(cAliasAux)->ZF5_STATUS,"ZFD_STATUS")=="E"',"RED",   "Efetivado"    )// Permite adicionar legendas no Browse
    oMarkBRW:AddLegend('POSICIONE("ZFD",1,xFilial("ZFD")+(cAliasAux)->ZF5_STATUS,"ZFD_STATUS")=="N"',"GRAY",  "N�o Procede"  )// Permite adicionar legendas no Browse
    oMarkBRW:AddLegend('POSICIONE("ZFD",1,xFilial("ZFD")+(cAliasAux)->ZF5_STATUS,"ZFD_STATUS")=="T"',"YELLOW","Em tratamento")// Permite adicionar legendas no Browse
 EndIf
 oMarkBRW:SetFields( _aFields )													 		// Campos para exibi��o
 oMarkBRW:AddButton( "Confirmar"         , {|| Processa( {|| lRet:=AOMS03P(.T.,_lAtuTel) } )  } ,, 4 )// Adiciona um bot�o na �rea lateral do Browse //, IF(lRet,oMarkBRW:DeActivate(),)
 oMarkBRW:DisableConfig()                                                                // Desabilita a utiliza��o das configura��es do Browse
 oMarkBRW:Activate()																		// Ativacao da classe

 (cAliasAux)->( DBCloseArea() )

Return .F.


/*
===============================================================================================================================
Programa--------: AOMS03P
Autor-----------: Alex Wallauer
Data da Criacao-: 28/11/2017
Descri��o-------: Encerrar vairas ocorrenias
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS03P(_lGravar,_lAtuTel)
 Local _aCpos := {}
 Local _cQuery:= "",_nTot:=0
 Local _cNomeArq, _cCodFilial
 Local _cNomeCpo, _nI, _cCampoWork, _cCampoZF5
 Local _cNomeUsr, _vret

 ProcRegua(4)

 IF _lGravar

    IF (_lAtuTel .AND. U_ITMSG("Confirma o ATUALIZACAO dos registros Marcados?",'Aten��o!',,2,2,2)) .OR.;
       (!_lAtuTel .AND. U_ITMSG("Confirma o ENCERRAMENTO dos registros Marcados?",'Aten��o!',,2,2,2))

       IncProc("Gravando dados ...")
       _nTot:=0
       IncProc("Gravando dados ...")
       ProcRegua((cAliasAux)->(LASTREC()))
       (cAliasAux)->(DBGOTOP())
       nRecAux:=(cAliasAux)->( RECNO() )

       _vret := __cUserId
       _cNomeUsr := UsrFullName(_vret)

       DO WHILE (cAliasAux)->(!EOF())

          IncProc("Gravando dados ...")

           oMarkBRW:GoTo( (cAliasAux)->( RECNO() ) , .F. )

             If oMarkBRW:IsMark()

             nRecAux:=(cAliasAux)->( RECNO() )
             IF _lAtuTel
                oMarkBRW:GoTo( (cAliasAux)->( RECNO() ) , .T. )
                ZF5->(DBGOTO( (cAliasAux)->REC_ZF5 ))
                ZF5->(RECLOCK("ZF5",.F.))
                U_AOMS3Atu(.T.)
             ELSE
                ZF5->(DBGOTO( (cAliasAux)->REC_ZF5 ))
                ZF5->(RECLOCK("ZF5",.F.))
                ZF5->ZF5_STATUS:="000001"
                ZF5->ZF5_HRFIN := time()
                ZF5->ZF5_DTFIN := date()
                ZF5->ZF5_USRFIN:= _vret
                ZF5->ZF5_USNFIN:= _cNomeUsr
             EndIf
             ZF5->(MSUNLOCK())
             _nTot++
             IF !_lAtuTel
                (cAliasAux)->(DBDELETE())
             EndIf

          EndIf
          (cAliasAux)->(DBSKIP())

       ENDDO

    EndIf

    (cAliasAux)->(DBGOTOP())
     oMarkBRW:GoTo( nRecAux , .T. ) //(cAliasAux)->( RECNO() )

    IF _nTot > 0
       IF _lAtuTel
          U_ITMSG("Registros atualizados: "+AlLTRIM(STR(_nTot)),"Aten��o",,2)
       ELSE
          U_ITMSG("Registros encerrados: "+AlLTRIM(STR(_nTot)),"Aten��o",,2)
       EndIf
    ELSE
       U_ITMSG("N�o foram marcados registros","Aten��o",,1)
    EndIf

    RETURN _nTot > 0

 EndIf

 _aCpos := FWSX3Util():GetListFieldsStruct( "ZF5" , .T.  )//Com campos virtuais
 aAdd( _aCpos , { "REC_ZF5", "N" , 10, 0 } )
 aAdd( _aCpos , { "MARCA"  , "C" , 01, 0 } )
 aAdd( _aCpos , { "STATUS2", "C" , 01, 0 } )

 IncProc("1-Lendo dados ...")

 _oTemp2:= FWTemporaryTable():New(cAliasAux, _aCpos )
 _oTemp2:Create()

 _cQuery	:= " SELECT R_E_C_N_O_ REC_ZF5 "
 _cNomeArq  := RetSqlName("ZF5")
 _cQuery  	+= " FROM " + _cNomeArq + " ZF5"
 _cCodFilial:= xFilial("ZF5")
 _cQuery  	+= " WHERE ZF5.ZF5_FILIAL = '" + _cCodFilial + "'"
 _cQuery   	+= " AND ZF5.ZF5_DTFIN = '  ' AND ZF5.ZF5_NDEBIT <> 'S' "

 IF !EMPTY(MV_PAR03)
    _cQuery += " AND ZF5.ZF5_CLIENT = '" + MV_PAR03 + "'
 EndIf

 IF !EMPTY(MV_PAR03) .AND. !EMPTY(MV_PAR04)
    _cQuery  += " AND ZF5.ZF5_LOJA = '" + MV_PAR04 + "'
 EndIf

 IF !EMPTY(MV_PAR05) .AND. !EMPTY(MV_PAR06)
    _cQuery  += " AND ZF5.ZF5_DTINI BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "' "
 EndIf

 _cQuery  	+= " AND ZF5.D_E_L_E_T_ = ' ' AND ZF5.ZF5_STATUS IN ("
 _cQuery	+= " SELECT ZFD.ZFD_CODIGO "
 _cNomeArq  := RetSqlName("ZFD")
 _cQuery  	+= " FROM " + _cNomeArq + " ZFD"
 _cCodFilial:= xFilial("ZFD")
 _cQuery  	+= " WHERE ZFD.ZFD_FILIAL = '" + _cCodFilial + "'"
 _cQuery   	+= " AND ZFD.ZFD_STATUS <> 'E' "
 _cQuery  	+= " AND ZFD.D_E_L_E_T_ = ' ' )"

 IF !EMPTY(MV_PAR02)
    _cQuery  	+= " AND ZF5.ZF5_DOCOC IN ("
    _cQuery	    += " SELECT SF2.F2_DOC "
    _cNomeArq   := RetSqlName("SF2")
    _cQuery  	+= " FROM " + _cNomeArq + " SF2"
    _cCodFilial := xFilial("SF2")
    _cQuery  	+= " WHERE SF2.F2_FILIAL = '" + _cCodFilial + "'"
    _cQuery  	+= " AND SF2.F2_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "
    _cQuery  	+= " AND SF2.D_E_L_E_T_ = ' ' )"
 EndIf
 _cQuery += " ORDER BY ZF5.ZF5_DTINI,ZF5.ZF5_DOCOC "

 cAlias:=GetNextAlias()
 MPSysOpenQuery( _cQuery , cAlias)

 IncProc("2-Lendo dados ...")

 DBSelectArea(cAlias)
 Count to _nTot

 IncProc("3-Lendo dados ...")

 ProcRegua(_nTot)

 (cAlias)->(DbGoTop())

 Do While (cAlias)->(!Eof())

    IncProc("4-Lendo dados ...")
    ZF5->(DBGOTO( (cAlias)->REC_ZF5 ))

    (cAliasAux)->( DBAPPEND() )

    For _nI := 1 To ZF5->(FCount())
        _cNomeCpo := ZF5->(FieldName(_nI))
        If (cAliasAux)->(FieldPos(_cNomeCpo)) > 0
           _cCampoWork := cAliasAux + "->" + _cNomeCpo
           _cCampoZF5  := "ZF5->" + _cNomeCpo
           &(_cCampoWork) := &(_cCampoZF5)
        EndIf
    Next _nI
    IF _lAtuTel
       (cAliasAux)->STATUS2:="N"//Algum Diferente? N�O
       IF ALLTRIM((cAliasAux)->ZF5_DMOTOR) <> ALLTRIM(U_AOMS003Z("ZF5_DMOTOR")) .OR.;
          ALLTRIM((cAliasAux)->ZF5_NREPRE) <> ALLTRIM(U_AOMS003Z("ZF5_NREPRE")) .OR.;
          ALLTRIM((cAliasAux)->ZF5_NCOOR ) <> ALLTRIM(U_AOMS003Z("ZF5_NCOOR" )) .OR.;
          ALLTRIM((cAliasAux)->ZF5_NCLIEN) <> ALLTRIM(U_AOMS003Z("ZF5_NCLIEN"))
          (cAliasAux)->STATUS2:="S"//Algum Diferente? SIM
       EndIf
    EndIf

    (cAliasAux)->REC_ZF5:=(cAlias)->REC_ZF5

    (cAlias)->(DBSKIP())

 EndDo

 (cAlias)->(DBCloseArea() )

Return _nTot > 0

/*
===============================================================================================================================
Programa----------: AjustaSX1
Autor-------------: Fabiano Dias
Data da Criacao---: 04/07/2011
Descri��o---------: Funcao responsavel por verificar o cadastro das perguntas no SX1
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/

//Static Fun ction AjustaSX1()
  /*
 Local _aHlpPor := {}
  QAUNDO PRECISAR REABILITE A CHAMADA TB
 _aHlpPor := {{ 'Informe a data inicial de Emissao NFE' }}
 u_itputx1(_cPerg,"01","Dt Emissao NFE De?"," "," ","mv_ch1","D",8,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",_aHlpPor,_aHlpPor,_aHlpPor)

 _aHlpPor :={ { 'Informe a data final de Emissao NFE' }}
 u_itputx1(_cPerg,"02","Dt Emissao NFE Ate?"," "," ","mv_ch2","D",8,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",_aHlpPor,_aHlpPor,_aHlpPor)

 //Cliente
 aHelpPor := {{ 'Informe o cliente'}}
 u_itputx1(_cPerg,"03","Cliente"," "," ","mv_ch3","C",6,0,0,"G","","SA1","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)
 //Loja
 aHelpPor := {{ 'Informe a loja do cliente'}   }
 u_itputx1(_cPerg,"04","Loja "," "," ","mv_ch4","C",4,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

 _aHlpPor := {{ 'Informe a data inicial da Inclusao' }}
 u_itputx1(_cPerg,"05","Dt Inc Ocor De?"," "," ","mv_ch5","D",8,0,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","",_aHlpPor,_aHlpPor,_aHlpPor)

 _aHlpPor := {{ 'Informe a data final da Inclusao' }}
 u_itputx1(_cPerg,"06","Dt Inc Ocor Ate?"," "," ","mv_ch6","D",8,0,0,"G","","","","","mv_par06","","","","","","","","","","","","","","","","",_aHlpPor,_aHlpPor,_aHlpPor)
 */
//Return()

/*
===============================================================================================================================
Programa--------: AOMS03T
Autor-----------: Julio de Paula Paz
Data da Criacao-: 23/11/2018
Descri��o-------: Retornar as Strings com fun��es que exibir�o dados na fun��o FWMBrowse.
Parametros------: _cNomeCampo = Nome do campo que deve ter a String com fun��o retornada.
Retorno---------: _cRet = String com a fun��o que deve ser retornada.
===============================================================================================================================
*/
User Function AOMS03T(_cNomeCampo)
   Local _cRet := ""
   If AllTrim(_cNomeCampo) $ "ZF5_DMOTOR/ZF5_NREPRE/ZF5_NCOOR/ZF5_NCLIEN"
      _cRet := 'U_AOMS003Z("'+AllTrim(_cNomeCampo)+'",3)'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_DATAE"
      //_cRet := 'U_AOMS003Z("ZF5_DATAE")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_ASSNOM"
      //_cRet := 'U_AOMS003Z("ZF5_ASSNOM")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_PEDIDO"
      //_cRet := 'U_AOMS003Z("ZF5_PEDIDO")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_DTCAR"
      //_cRet := 'U_AOMS003Z("ZF5_DTCAR")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_STATUD"
      _cRet := 'POSICIONE("ZFD",1,XFILIAL("ZFD")+ZF5->ZF5_STATUS,"ZFD_DESCRI")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_CLIENT"
      //_cRet := 'U_AOMS003Z("ZF5_CLIENT")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_LOJA"
      //_cRet := 'U_AOMS003Z("ZF5_LOJA")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_NCLIEN"
      //_cRet := 'U_AOMS003Z("ZF5_NCLIEN")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_VOLUM"
      //_cRet := 'U_AOMS003Z("ZF5_VOLUM")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_REPRES"
      //_cRet := 'U_AOMS003Z("ZF5_REPRES")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_NREPRE"
      //_cRet := 'U_AOMS003Z("ZF5_NREPRE")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_PESO"
      //_cRet := 'U_AOMS003Z("ZF5_PESO")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_PESON"
      //_cRet := 'U_AOMS003Z("ZF5_PESON")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_COORD"
      //_cRet := 'U_AOMS003Z("ZF5_COORD")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_NCOOR"
      //_cRet := 'U_AOMS003Z("ZF5_NCOOR")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_VLRFRE"
      //_cRet := 'U_AOMS003Z("ZF5_VLRFRE")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_UF"
      //_cRet := 'U_AOMS003Z("ZF5_UF")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_MOTORI"
      //_cRet := 'U_AOMS003Z("ZF5_MOTORI")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_DMOTOR"
      //_cRet := 'U_AOMS003Z("ZF5_DMOTOR")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_CIDADE"
      //_cRet := 'U_AOMS003Z("ZF5_CIDADE")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_VEICUL"
      //_cRet := 'U_AOMS003Z("ZF5_VEICUL")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_DVEICU"
      //_cRet := 'U_AOMS003Z("ZF5_DVEICU")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_PLACA"
      //_cRet := 'U_AOMS003Z("ZF5_PLACA")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_TIPOV"
      //_cRet := 'U_AOMS003Z("ZF5_TIPOV")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_TRANSP"
      //_cRet := 'U_AOMS003Z("ZF5_TRANSP")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_NTRANS"
      //_cRet := 'U_AOMS003Z("ZF5_NTRANS")'
   ElseIf AllTrim(_cNomeCampo) =  "ZF5_STATE"
      _cRet := 'U_AOMS003U("ZF5_STATE")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_STATC"
      _cRet := 'U_AOMS003U("ZF5_STATC")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_TIPOV"
      _cRet := 'U_AOMS003U("ZF5_TIPOV")'
   ElseIf AllTrim(_cNomeCampo) == "ZF5_TIPOC"
      _cRet := 'U_AOMS003U("ZF5_TIPOC")'
      _lEnviou := .F.
   ElseIf AllTrim(_cNomeCampo) == "ZF5_SEROC"
      //_cRet := 'U_AOMS003U("ZF5_SEROC")'
   EndIf
Return _cRet

/*
===============================================================================================================================
Programa--------: AOMS003U
Autor-----------: Julio de Paula Paz
Data da Criacao-: 23/11/2018
Descri��o-------: Retornar as Strings relacionada aos par�metros passados pela fun��o.
Parametros------: _cNomeCampo = Nome do campo que deve retornar uma String.
Retorno---------: _cRet = String com a fun��o que deve ser retornada.
===============================================================================================================================
*/
User Function AOMS003U(_cNomeCampo)
    Local _cRet := ""
    ZF5->(DBGOTO( (cAliasAux)->REC_ZF5 ))

    If AllTrim(_cNomeCampo) == "ZF5_STATE"
       If ZF5->ZF5_STATE == "V"
          _cRet := "Valor"
       ElseIf ZF5->ZF5_STATE == "F"
          _cRet := "Formula"
       ElseIf ZF5->ZF5_STATE == "P"
          _cRet := "Percentual"
       EndIf

    ElseIf AllTrim(_cNomeCampo) == "ZF5_STATC"
       If ZF5->ZF5_STATC == "P"
          _cRet := "Pendente"
       ElseIf ZF5->ZF5_STATC == "T"
          _cRet := "Tratamento"
       ElseIf ZF5->ZF5_STATC == "E"
          _cRet := "Encerrado"
       ElseIf ZF5->ZF5_STATC == "S"
          _cRet := "Sem custo"
       EndIf

    ElseIf AllTrim(_cNomeCampo) == "ZF5_TIPOV"
       If ZF5->ZF5_TIPOV == "1"
          _cRet :="CARRETA"
       ElseIf ZF5->ZF5_TIPOV == "2"
          _cRet := "CAMINHAO"
       ElseIf ZF5->ZF5_TIPOV == "3"
          _cRet :=   "BI-TREM"
       ElseIf ZF5->ZF5_TIPOV == "4"
          _cRet := "UTILITARIO"
       ElseIf ZF5->ZF5_TIPOV  == "5"
          _cRet := "RODOTREM"
       EndIf

    ElseIf AllTrim(_cNomeCampo) == "ZF5_TIPOC"
       If ZF5->ZF5_TIPOC == "M"
          _cRet := "Misto"
       ElseIf ZF5->ZF5_TIPOC == "I"
          _cRet := "Italac"
       ElseIf ZF5->ZF5_TIPOC == "T"
          _cRet := "Transportador"
       ElseIf ZF5->ZF5_TIPOC == "R"
          _cRet := "Representante"
       ElseIf ZF5->ZF5_TIPOC == "C"
          _cRet := "Cliente"
       ElseIf ZF5->ZF5_TIPOC == "3"
          _cRet := "Terceiros"
       EndIf
    EndIf
Return _cRet


/*
===============================================================================================================================
Programa--------: AOMS003DT
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 26/12/2018
Descri��o-------: Exclui t�tulo de d�bito de transporte
Parametros------: nRecZF5 - recno do ZF5 a limpar
                 _oModelGrid - objeto
Retorno---------: _lretorno - Se excluiu com sucesso
===============================================================================================================================
*/
Static Function AOMS003DT(nRecZF5,_oModelGrid)
 Local _lretorno := .F.
 Local _aAutoSE2 := {}
 Local _aAreaSA2 := {}
 Local _lBloq := .F.

 AAdd( _aAutoSE2 , { "E2_FILIAL"    , SE2->E2_FILIAL     , nil } )
 AAdd( _aAutoSE2 , { "E2_PREFIXO"   , SE2->E2_PREFIXO , nil } )
 AAdd( _aAutoSE2 , { "E2_NUM"       , SE2->E2_NUM	     , nil } )
 AAdd( _aAutoSE2 , { "E2_PARCELA"	, SE2->E2_PARCELA    , nil } )
 AAdd( _aAutoSE2 , { "E2_TIPO"		, SE2->E2_TIPO	     , nil } )
 AAdd( _aAutoSE2 , { "E2_NATUREZ"	, SE2->E2_NATUREZ    , nil } )
 AAdd( _aAutoSE2 , { "E2_FORNECE"	, SE2->E2_FORNECE    , nil } )
 AAdd( _aAutoSE2 , { "E2_LOJA"		, SE2->E2_LOJA	     , nil } )
 AAdd( _aAutoSE2 , { "E2_EMISSAO"	, SE2->E2_EMISSAO    , nil } )
 AAdd( _aAutoSE2 , { "E2_VENCTO"    , SE2->E2_VENCTO     , nil } )
 AAdd( _aAutoSE2 , { "E2_VALOR"     , SE2->E2_VALOR      , nil } )
 AAdd( _aAutoSE2 , { "E2_HIST"		, SE2->E2_HIST       , Nil } )
 AAdd( _aAutoSE2 , { "E2_DATALIB"	, SE2->E2_DATALIB    , nil } )
 AAdd( _aAutoSE2 , { "E2_USUALIB"	, SE2->E2_USUALIB    , nil } )

 lMsErroAuto := .F.
 _cAOMS074Vld:= ""
 _cAOMS074 :="AOMS103"
 _ce2num   := SE2->E2_NUM
 _cFornece := SE2->E2_FORNECE
 _cLoja    := SE2->E2_LOJA
 _cSeekSE2 := SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA

 IF nRecZF5 > 0
    ZF5->(DBGOTO(nRecZF5))
 ENDIF
 _cCodigo  := ZF5->ZF5_CODIGO
 _aAreaSA2 := GetArea("SA2")

 SA2->( DBSetOrder(1) )
 If SA2->(DbSeek( xFilial('SA2') + Alltrim(_cfornece) + Alltrim(_cloja) ))
     If SA2->A2_MSBLQL == '1'
         Help( ,, 'Aten��o',, 'Erro ao excluir t�tulo: ' + SE2->E2_NUM + ' Parc.:' + SE2->E2_PARCELA + ' de nota de d�bito. Fornecedor informado ' + Alltrim(_cfornece) + " - " + Alltrim(_cloja) + ' encontra-se Bloqueado ou Inativo no cadastro de Fornecedores do Sistema!' , 1, 0, .F. )
       _lBloq := .T.
     Else
       _lBloq := .F.
    EndIf
 EndIf

 RestArea(_aAreaSA2)

 If _lBloq
    _lretorno := .F.
 Else
    _nModAux  := nModulo
    _cModAux  := cModulo
    nModulo   := 6
    cModulo   := "FIN"

    fwmsgrun(,{ || MSExecAuto({|v,h,k,l,m,n,o| Fina050(v,h,k,l,m,n,o)},_aAutoSE2,,5,,,.F.,.T.)},"Aguarde...", "Excluindo t�tulo de nota de d�bito da Ocorr�ncia " + STRZERO(VAL(_cCodigo),6)) //Exclus�o

    If lMsErroAuto .OR. !EMPTY(_cAOMS074Vld)
       U_ITmsg('Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Erro ao exclui t�tulo de nota de d�bito, ocorr�ncia n�o ser� salva. Print essa e a proxima tela.','Aten��o!',_cAOMS074Vld,,,,.T.)  //HELP PARA O MVC
       MostraErro()
    Else

       SE2->(Dbsetorder(1))
       If !(SE2->(DbSeek(_cSeekSE2)))

           //Posiciona no registro gravado no banco para comparar
           IF nRecZF5 > 0
              ZF5->(DBGOTO(nRecZF5))
              ZF5->(RecLock("ZF5",.F.))
              ZF5->ZF5_CHVNDT:=""
              ZF5->(MSUNLOCK())
             _oModelGrid:LoadValue('ZF5_CHVNDT',SPACE(LEN(ZF5->ZF5_CHVNDT)))
          EndIf

           _lretorno := .T.
       Else
          //Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Erro ao excluir t�tulo de nota de d�bito, ocorr�ncia n�o ser� salva/apagada.' , 1, 0 )
          //N�o pode ser help sen�o sobrep�e a mensagem de help do erro do MSExecAuto/Fina050
          U_ITMSG('Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6)  + ' - Erro ao excluir t�tulo de nota de d�bito, ocorr�ncia n�o ser� salva/apagada.','Aten��o!',,1)
       EndIf

    EndIf

 EndIf

 nModulo := _nModAux
 cModulo := _cModAux

Return _lretorno

/*
===============================================================================================================================
Programa----------: AOMS003Y
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 18/04/2012
Descri��o---------: Monta Tela para consulta de itens do documento de devolu��o selecionado F3
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function AOMS003Y()
 Local i            := 0
 Local _cAlias      := GetNextAlias()
 Local _oModel      := FwModelActivete()
 Local _oModelGrid  := _oModel:GetModel("ZF5DETAIL")
 Local _oModelMaster:= _oModel:GetModel("ZF5MASTER")

 Private nTam      := 0
 Private nMaxSelect:= 0
 Private aCat      := {}
 Private MvRet     := Alltrim(_oModelGrid:GetValue('ZF5_DVITEM'))
 Private MvPar     := ""
 Private cTitulo   := ""
 Private MvParDef  := ""

 M->ZF5_DVITEM := _oModelGrid:GetValue("ZF5_DVITEM")
 MvRet         := "M->ZF5_DVITEM"

 BEGIN SEQUENCE

 //Identifica fornecedor de nota de devolu��o
 If _oModelGrid:GetValue('ZF5_ORIDEV') != "I"

    _cforn := alltrim(_oModelMaster:GetValue('ZF5_CLIENT'))
    _clojaf := alltrim(_oModelMaster:GetValue('ZF5_LOJA'))

 Else

    _lachou := .F.
    ZZM->(Dbsetorder(1))
    If ZZM->(DbSeek(xfilial("ZZM")+cfilant))

       SA1->(Dbsetorder(3))
       If SA1->(DbSeek(xfilial("SA1")+alltrim(ZZM->ZZM_CGC)))

          _lachou := .T.
          _cforn := alltrim(SA1->A1_COD)
          _clojaf := alltrim(SA1->A1_LOJA)

       EndIf

    EndIf

    If !_lachou

       u_itmsg("Devolu��o de origem Italac para filial n�o localizada em cadastro de clientes.","Aten��o",,1)
       Break

    EndIf

 EndIf


 //Tratamento para carregar variaveis da lista de opcoes
 nTam       := 4
 nMaxSelect := 20
 cTitulo    := "ITENS DO DOCUMENTO DE DEVOLU��O"

 _cQuery := 	" SELECT	D1_ITEM,D1_COD"
 _cQuery +=	" FROM  " + retsqlname("SD1")
 _cQuery +=  " WHERE	D_E_L_E_T_ = ' ' "
 _cQuery +=  " AND	D1_FILIAL = '" + cfilant + "' AND D1_DOC = '" + alltrim(_oModelGrid:GetValue('ZF5_DOCDEV')) + "' "
 _cQuery +=  " AND	D1_SERIE = '" +  alltrim(_oModelGrid:GetValue('ZF5_SERDEV')) + "' "
 _cQuery +=  " AND	D1_FORNECE = '" + _cforn + "' AND D1_LOJA = '" + _clojaf + "' "
 _cQuery +=  " ORDER BY D1_ITEM "

 _cAlias:=GetNextAlias()
 MPSysOpenQuery( _cQuery , _cAlias )

 (_cAlias)->(DBGotop())

 If (_cAlias)->(Eof())

    u_itmsg("Documento de devolu��o n�o localizado.","Aten��o","Verifique se o documento de devolu��o j� foi classificado",1)
    Break

 EndIf

 While !(_cAlias)->(Eof())

     MvParDef += (_cAlias)->D1_ITEM
     aAdd(aCat,AllTrim((_cAlias)->D1_COD) + " - " +  posicione("SB1",1,xfilial("SB1")+AllTrim((_cAlias)->D1_COD),"B1_DESC"))

    (_cAlias)->(dbSkip())
 EndDo

 (_cAlias)->(dbCloseArea())

 If Len(AllTrim(&MvRet)) == 0
     MvPar:= PadR(AllTrim(StrTran(&MvRet,"/","")),Len(aCat))
     &MvRet:= PadR(AllTrim(StrTran(&MvRet,"/","")),Len(aCat))
 Else
     MvPar:= AllTrim(StrTran(&MvRet,";","/"))
 EndIf

 //Executa funcao que monta tela de opcoes
 If f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,.F.,nTam,nMaxSelect)

     //Tratamento para separar retorno com barra "/"
     &MvRet := ""
     for i:=1 to Len(MvPar) step nTam
         if !(SubStr(MvPar,i,1) $ " |*")
             &MvRet  += SubStr(MvPar,i,nTam) + "/"
         EndIf
     next i

    _oModelGrid:LoadValue('ZF5_DVITEM',&MvRet)

 EndIf

 END SEQUENCE

Return .T.

/*
===============================================================================================================================
Programa----------: AOMS003A
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 02/04/2019
Descri��o---------: Monta Tela para consulta de documentos de devolu��o do cliente selecionado
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS003A()
 Local _cAlias      := GetNextAlias()
 Local _oModel      := FwModelActivete()
 Local _oModelGrid  := _oModel:GetModel("ZF5DETAIL")
 Local _oModelMaster:= _oModel:GetModel("ZF5MASTER")

 Private nTam      := 0
 Private nMaxSelect:= 0
 Private aCat      := {}
 Private MvRet     := Alltrim(_oModelGrid:GetValue('ZF5_DOCDEV')) + "/" + Alltrim(_oModelGrid:GetValue('ZF5_SERDEV'))
 Private MvPar     := ""
 Private cTitulo   := ""
 Private MvParDef  := ""

 _cRetorno := Alltrim(_oModelGrid:GetValue('ZF5_DOCDEV')) + Alltrim(_oModelGrid:GetValue('ZF5_SERDEV'))

 M->ZF5_DOCDEV := _oModelGrid:GetValue("ZF5_DOCDEV")


 //Identifica fornecedor de nota de devolu��o
 If _oModelGrid:GetValue('ZF5_ORIDEV') != "I"

   _cforn := alltrim(_oModelMaster:GetValue('ZF5_CLIENT'))
   _clojaf := alltrim(_oModelMaster:GetValue('ZF5_LOJA'))

 Else

   _lachou := .F.
   ZZM->(Dbsetorder(1))
   If ZZM->(DbSeek(xfilial("ZZM")+cfilant))

      SA1->(Dbsetorder(3))
      If SA1->(DbSeek(xfilial("SA1")+alltrim(ZZM->ZZM_CGC)))

         _lachou := .T.
         _cforn := alltrim(SA1->A1_COD)
         _clojaf := alltrim(SA1->A1_LOJA)

      EndIf

   EndIf

   If !_lachou

      u_itmsg("Devolu��o de origem Italac para filial n�o localizada em cadastro de clientes.","Aten��o",,1)
      Break

   EndIf

 EndIf


 //Tratamento para carregar variaveis da lista de opcoes
 nTam       := 13
 nMaxSelect := 1
 cTitulo    := "DOCUMENTOS DE DEVOLU��O"
 _dlimit := date() - 180

 _cQuery := 	" SELECT	F1_DOC,F1_SERIE,F1_EMISSAO"
 _cQuery +=	" FROM  " + retsqlname("SF1")
 _cQuery +=  " WHERE	D_E_L_E_T_ = ' ' "
 _cQuery +=  " AND	F1_FILIAL = '" + cfilant + "' AND F1_EMISSAO >= '" + dtos(_dlimit) + "' "
 _cQuery +=  " AND	F1_FORNECE = '" + _cforn + "' AND F1_LOJA = '" + _clojaf + "' "
 _cQuery +=  " ORDER BY F1_EMISSAO DEsC"

 MPSysOpenQuery( _cQuery , _cAlias )

 (_cAlias)->(DBGotop())

 If (_cAlias)->(Eof())

    u_itmsg("Documento de devolu��o n�o localizado.","Aten��o","Verifique se o documento de devolu��o j� foi classificado",1)
    Break

 EndIf

 While !(_cAlias)->(Eof())
     MvParDef += (_cAlias)->F1_DOC+"/"+(_cAlias)->F1_SERIE
     aAdd(aCat,AllTrim((_cAlias)->F1_DOC) + " - " + AllTrim((_cAlias)->F1_SERIE) + " - " + dtoc(STOD(AllTrim((_cAlias)->F1_EMISSAO))) )
     (_cAlias)->(dbSkip())
 EndDo

 (_cAlias)->(dbCloseArea())

 //Executa funcao que monta tela de opcoes
 If f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,.F.,nTam,nMaxSelect)

    mvpar := strtran(mvpar,'*')
    _cRetorno := SUBSTR(MVPAR,1,9) + SUBSTR(MVPAR,11,3)

 EndIf

Return .T.

/*
===============================================================================================================================
Programa----------: AOMS003B
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 02/04/2019
Descri��o---------: Gatilho p�s consulta no campo de documento de devolu��o
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS003B()
 Local _oModel:=FwModelActivete()
 Local _oModelGrid:=_oModel:GetModel("ZF5DETAIL")
 Local _cret:=_oModelGrid:GetValue('ZF5_SERDEV')

 If valtype(_cRetorno) == "C"
    _cret := substr(_cRetorno,10,3)
 EndIf

Return _cret

/*
===============================================================================================================================
Programa----------: AOMS003DP
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 02/04/2019
Descri��o---------: Exclui pedido de descarte posicionado
Parametros--------: Nenhum (SC5 precisa estar posicionado)
Retorno-----------: _lret - sucesso da opera��o
===============================================================================================================================
*/
Static Function AOMS003DP()

 Local _aCabcPVEX := {}
 Local _aItenPVEx := {}
 Local _oModel           := FwModelActivete()
 Local _oModelGrid       := _oModel:GetModel("ZF5DETAIL")
 Local _lret := .F.

 _aCabcPVEx := {		   { "C5_FILIAL"  , SC5->C5_FILIAL           ,Nil},;
                                { "C5_NUM"     , SC5->C5_NUM         	   ,Nil},;
                                { "C5_TIPO"    , SC5->C5_TIPO    			,Nil},;
                                { "C5_CLIENTE" , SC5->C5_CLIENTE 			,Nil},;
                                { "C5_LOJACLI" , SC5->C5_LOJACLI 			,Nil},;
                                { "C5_CLIENT " , SC5->C5_CLIENT  			,Nil},; // Codigo do cliente
                                { "C5_LOJAENT" , SC5->C5_LOJAENT 			,Nil},; // Loja para entrada
                                { "C5_TIPOCLI" , SC5->C5_TIPOCLI 			,Nil},;
                                { "C5_CONDPAG" , SC5->C5_CONDPAG 			,Nil},;
                                { "C5_VEND1"   , SC5->C5_VEND1   			,Nil},;
                                { "C5_EMISSAO" , SC5->C5_EMISSAO        	,Nil},;
                                { "C5_TPFRETE" , SC5->C5_TPFRETE 			,Nil},;
                                { "C5_VOLUME1" , SC5->C5_VOLUME1 			,Nil},;
                                { "C5_ESPECI1" , SC5->C5_ESPECI1 			,Nil},;
                                { "C5_TPCARGA" , SC5->C5_TPCARGA 			,Nil},;
                                { "C5_I_AGEND" , SC5->C5_I_AGEND 			,Nil},;
                                { "C5_I_ENVRD" , "N"                		,Nil},;
                                  { "C5_I_IDPED" , SC5->C5_I_IDPED			   ,Nil} }


 SC6->(Dbsetorder(1))
 If SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))

    Do while SC5->C5_NUM == SC6->C6_NUM .AND. SC5->C5_FILIAL == SC6->C6_FILIAL

       aAdd( _aItenPVEx , {	{ "C6_FILIAL"  , SC6->C6_FILIAL	,Nil},;
                                                          { "C6_ITEM"    , SC6->C6_ITEM		,Nil},;
                                                          { "C6_PRODUTO" , SC6->C6_PRODUTO	,Nil},;
                                                          { "C6_QTDVEN"  , SC6->C6_QTDVEN	,Nil},;
                                                          { "C6_UM"      , SC6->C6_UM		,Nil},;
                                                          { "C6_PRCVEN"  , SC6->C6_PRCVEN	,Nil},;
                                                          { "C6_VALOR"   , SC6->C6_VALOR	,Nil},;
                                                          { "C6_PEDCLI"  , SC6->C6_PEDCLI	,Nil},;
                                                          { "C6_QTDLIB"  , SC6->C6_QTDLIB	,Nil},;
                                                          { "C6_LOCAL"   , SC6->C6_LOCAL	,Nil},;
                                                          { "C6_NUM"     , SC6->C6_NUM		,Nil}})

       SC6->(Dbskip())

    Enddo

 EndIf

 lMsErroAuto := .F.

 fwmsgrun(,{ || MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabcPVEx , _aItenPVEx , 5 )},"Aguarde","Excluindo pedido de descarte...")

 If lMsErroAuto

    MostraErro()
    Help( ,, 'Aten��o',, 'N�o foi poss�vel excluir pedido de descarte, ocorr�ncia n�o ser� exclu�da!' , 1, 0, .F. )
    _lRet := .F.

 Else

    //Valida se o pedido ainda existe
    SC5->(Dbsetorder(1))
    If SC5->(DbSeek(_aCabcPVEx[1][2]+_aCabcPVEx[2][2]))

       Help( ,, 'Aten��o',, 'N�o foi poss�vel excluir pedido de descarte, ocorr�ncia n�o ser� exclu�da!' , 1, 0, .F. )
       _lRet := .F.

    Else

       _oModelGrid:LoadValue('ZF5_PEDDEV',space(6))
       _cpeddev := SPACE(6)
       _lret := .T.

    EndIf

 EndIf

Return _lret

/*
===============================================================================================================================
Programa----------: AOMS003J
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 02/04/2019
Descri��o---------: Envia workflow de solicita��o de cancelamento de cobran�a
Parametros--------: _cNotaFiscal - numero da nota de sa�da da ocorr�ncia
                    _cserie      - s�rie da nota de sa�da da ocorr�ncia
                    _lvalidado - se j� fi pr� validada a ocorr�ncia
                    _cMotiCanc - Motivo do cancelamento
                    _cMotcus   - Motivo do Custo
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS003J(_cNotaFiscal,_cserie, _lvalidado,_lAuto, _cMotiCanc ,_cMotcus )
 Local _cEmail := u_itgetmv("IT_OCORAV1", "" )
 Local _cAnexo := " "
 Local oAssunto
 Local _cAssunto := "Solicita��o de cancelamento de cobran�a da nota fiscal " + _cNotaFiscal + "/" + _cSerie + " da filial " + cfilant
 Local oButCan
 Local oButEnv
 Local oCc
 Local oGetAssun
 Local oGetCc
 Local oGetPara
 Local oMens
 Local oPara
 Local _cSetor := ""
 Local cMailCom := " "
 Local _aConfig	:= U_ITCFGEML('')
 Local _cEmlLog	:= ""
 Local cHtml    := ""
 Local nOpcA    := 2

 Local cGetAnx	:= _cAnexo
 Local cGetAssun:= _cAssunto + Space(150)
 Local cGetCc	:= Space(200)
 Local cGetMens	:= ""
 Local cGetPara	:= _cEmail + Space(150)
 Local _aAreSM0:= SM0->(FwGetArea()) As Array


 Default _lvalidado := .F.
 Default _lAuto     := .F.
 Default _cMotiCanc := " "
 Default _cMotcus   := " "

 Private oDlgMail

cGetPara:= AllTrim(UsrRetMail(__cUserId))+Space(99)

 //Valida se ocorr�ncia pode emitir aviso de devolu��o
 //Se status est� encerrando, valida se j� existe nota de d�bito


 If !_lAuto
   If ! _lvalidado

      If ! POSICIONE("ZFD",1,xFilial("ZFD")+ZF5->ZF5_STATUS,"ZFD_STATUS") == "E"
         U_Itmsg("Ocorr�ncia n�o est� encerrada!","Aten��o",,1)
         Return
      EndIf

      If ! U_Itmsg("Envia e-mail de cancelamento de cobran�a para nota " + _cNotaFiscal + " com ocorr�ncia de devolu��o?","Aten��o",'Item ' + ALLTRIM(ZF5->ZF5_CODIGO),2,2,2)
         U_Itmsg("Envio de e-mail cancelado.","Aten��o",,1)
         Return
      EndIf

      _cMotiCanc := ZF5->ZF5_TIPOO + "-" + ALLTRIM(ZF5->ZF5_MOTIVO)
      _cMotcus   := ALLTRIM(ZF5->ZF5_MOTCUS)

   EndIf
 EndIf

 _cTel  :=""
 PswOrder(1)
 PSWSEEK(__cUserId , .T. )
 If (Len(PswRet()) # 0) // Quando nao for rotina automatica do configurador
     _cSetor:= AllTrim(PswRet()[1][12])		// Pega departamento do usuario
 EndIf

 If EMPTY(_cSetor)
      _cSetor := "Logistica"
 EndIf
 If EMPTY(_cTel)
    _cTel:=AllTrim( Posicione('SM0',1,"01"+cFilant,'M0_TEL') )
 EndIf

 cHtml := '� departamento de contas a receber,'
 cHtml += '<br><br>'
 cHtml += '&nbsp;&nbsp;&nbsp;Solicito cancelamento da cobran�a dos t�tulos referentes � nota fiscal - ' + _cNotaFiscal + "/"  + _cserie + ' de nossa filial '+ cfilant +' devido � ocorr�ncia de frete de devolu��o.<br>'
 cHtml += '&nbsp;&nbsp;&nbsp;Favor confirmar o recebimento, retornando com o seu CIENTE!'
 cHtml += '<br><br>'
 cHtml += 'Ocorr�ncia: ' + AllTrim(_cMotiCanc)
 IF !EMPTY(M->ZF5_MOTCUS)
    cHtml += '<br>'
    cHtml += 'Motivo do Custo: ' + AllTrim(M->ZF5_MOTCUS)
 EndIf
 cHtml += '<br><br>'
 cHtml += '<br><br>'
 cHtml += '&nbsp;&nbsp;&nbsp;A disposi��o!'
 cHtml += '<br><br>'
 cHtml += '<table class=MsoNormalTable border=0 cellpadding=0>'
 cHtml += '<tr>'
 cHtml +=     '<td style="padding:.75pt .75pt .75pt .75pt">'
 cHtml +=         '<p class=MsoNormal align=center style="text-align:center">'
 cHtml +=             '<b><span style="font-size:18.0pt;font-family:'+"'"+'Arial'+"'"+','+"'"+'sans-serif'+"'"+';color:#1D2668;mso-fareast-language:PT-BR">'+ Capital( AllTrim( UsrFullName( __cUserId ) ) ) +'</span></b>'
 cHtml +=             '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>
 cHtml +=     '</td>'
 cHtml +=     '<td style="background:#A2CFF0;padding:.75pt .75pt .75pt .75pt">&nbsp;</td>'
 cHtml +=     '<td style="padding:.75pt .75pt .75pt .75pt">
 cHtml +=         '<table class=MsoNormalTable border=0 cellpadding=0>'
 cHtml +=              '<tr>'
 cHtml +=                  '<td style="padding:.75pt .75pt .75pt .75pt">'
 cHtml +=                      '<p class=MsoNormal><b><span style="font-size:13.5pt;font-family:'+"'"+'Arial'+"'"+','+"'"+'sans-serif'+"'"+';color:#6FB4E3;mso-fareast-language:PT-BR">' + _cSetor + '</span></b>'
 cHtml +=                      '<b><span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></b>
 cHtml +=                      '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"><br></span>
 cHtml +=                      '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>
 cHtml +=                  '</td>'
 cHtml +=              '</tr>'
 cHtml +=              '<tr>'
 cHtml +=                  '<td style="padding:.75pt .75pt .75pt .75pt">
 cHtml +=                      '<p class=MsoNormal><span style="font-size:12.0pt;font-family:'+"'"+'Arial'+"'"+','+"'"+'sans-serif'+"'"+';color:#1D2668;mso-fareast-language:PT-BR">Tel: ' + _cTel + '</span>'
 cHtml +=                      '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>
 cHtml +=                  '</td>'
 cHtml +=              '</tr>'
 cHtml +=         '</table>'
 cHtml +=     '</td>'
 cHtml += '</tr>'
 cHtml += '</table>'
 cHtml += '<table class=MsoNormalTable border=0 cellpadding=0 width=437 style="width:327.75pt">'
 cHtml +=     '<tr>'
 cHtml +=         '<td style="padding:.75pt .75pt .75pt .75pt">'
 cHtml +=             '<p class=MsoNormal align=center style="text-align:center">'
 cHtml +=             '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR">'
 cHtml +=                 '<img width=400 height=51 src="http://www.italac.com.br/assinatura-italac/images/marcas-goiasminas-industria-de-laticinios-ltda.jpg">'
 cHtml +=             '</span>
 cHtml +=             '</p>'
 cHtml +=         '</td>'
 cHtml +=     '</tr>'
 cHtml += '</table>'
 cHtml += '<p class=MsoNormal><span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';display:none;mso-fareast-language:PT-BR">&nbsp;</span></p>'
 cHtml += '<table class=MsoNormalTable border=0 cellpadding=0>'
 cHtml +=     '<tr>'
 cHtml +=         '<td style="padding:.75pt .75pt .75pt .75pt">'
 cHtml +=             '<p class=MsoNormal align=center style="text-align:center">'
 cHtml +=             '<b><span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';color:#1D2668;mso-fareast-language:PT-BR">Pol�tica de Privacidade </span></b>'
 cHtml +=             '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>
 cHtml +=             '<p class=MsoNormal style="mso-margin-top-alt:auto;mso-margin-bottom-alt:auto;text-align:justify">'
 cHtml +=             '<span style="font-size:7.5pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';color:#1D2668;mso-fareast-language:PT-BR">
 cHtml +=                 'Esta mensagem � destinada exclusivamente para fins profissionais, para a(s) pessoa(s) a quem for dirigida, podendo conter informa��o confidencial e legalmente privilegiada. '
 cHtml +=                 'Ao receb�-la, se voc� n�o for destinat�rio desta mensagem, fica automaticamente notificado de abster-se a divulgar, copiar, distribuir, examinar ou, de qualquer forma, utilizar '
 cHtml +=                 'sua informa��o, por configurar ato ilegal. Caso voc� tenha recebido esta mensagem indevidamente, solicitamos que nos retorne este e-mail, promovendo, concomitantemente sua '
 cHtml +=                 'elimina��o de sua base de dados, registros ou qualquer outro sistema de controle. Fica desprovida de efic�cia e validade a mensagem que contiver v�nculos obrigacionais, expedida '
 cHtml +=                 'por quem n�o detenha poderes de representa��o, bem como n�o esteja legalmente habilitado para utilizar o referido endere�o eletr�nico, configurando falta grave conforme nossa '
 cHtml +=                 'pol�tica de privacidade corporativa. As informa��es nela contidas s�o de propriedade da Italac, podendo ser divulgadas apenas a quem de direito e devidamente reconhecido pela empresa.'
 cHtml += '<BR>Ambiente: ['+ GETENVSERVER() +'] / Fonte: [AOMS003] </BR>'
 cHtml +=             '</span>'
 cHtml +=             '<span style="font-size:7.5pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>'
 cHtml +=         '</td>'
 cHtml +=     '</tr>
 cHtml += '</table>'

 If !_lAuto
   DEFINE MSDIALOG oDlgMail TITLE "E-Mail" FROM 000, 000  TO 415, 584 COLORS 0, 16777215 PIXEL

      //======
      // Para:
      //======
      @ 005, 006 SAY oPara PROMPT "Para:" SIZE 015, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
      @ 005, 030 MSGET oGetPara VAR cGetPara SIZE 256, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL

      //===========
      // Com c�pia:
      //===========
      @ 021, 006 SAY oCc PROMPT "Cc:" SIZE 015, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
      @ 021, 030 MSGET oGetCc VAR cGetCc SIZE 256, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL

      //=========
      // Assunto:
      //=========
      @ 037, 006 SAY oAssunto PROMPT "Assunto:" SIZE 022, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
      @ 037, 030 MSGET oGetAssun VAR cGetAssun SIZE 256, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL

      //==========
      // Mensagem:
      //==========
      @ 069, 006 SAY oMens PROMPT "Mensagem:" SIZE 030, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
      _oFont		:= TFont():New( 'Courier new' ,, 12 , .F. )
      _oScrAux	:= TSimpleEditor():New( 080 , 006 , oDlgMail , 285 , 105 ,,,,, .T. )

      _oScrAux:Load( cHtml )

      @ 189, 201 BUTTON oButEnv PROMPT "&Enviar"		SIZE 037, 012 OF oDlgMail ACTION ( nOpcA := 1 , cHtml := _oScrAux:RetText() , oDlgMail:End() ) PIXEL
      @ 189, 245 BUTTON oButCan PROMPT "&Cancelar"	SIZE 037, 012 OF oDlgMail ACTION ( nOpcA := 2 , oDlgMail:End() ) PIXEL

   ACTIVATE MSDIALOG oDlgMail CENTERED
 Else
    nOpcA := 1
 EndIf

 If nOpcA == 1

     cGetMens := AOMS003TT(cGetMens)

     //====================================
     // Chama a fun��o para envio do e-mail
     //====================================
     U_ITENVMAIL( Lower(AllTrim(UsrRetMail(__cUserId))), cGetPara, cGetCc, cMailCom, cGetAssun, cHtml, cGetAnx, _aConfig[01], _aConfig[02], _aConfig[03], _aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

     U_ITMSG( _cEmlLog+CHR(10) +CHR(13)+"PARA: "+ALLTRIM(cGetPara)+CHR(10) +CHR(13)+"CC: "+ALLTRIM(cGetCc) , 'T�rmino do processamento!' , ,3 )

    _lEnviou := .T.

 Else
     u_itmsg( 'Envio de e-mail cancelado pelo usu�rio.' , 'Aten��o!' , ,1 )

    _lEnviou := .F.

 EndIf
FwRestArea(_aAreSM0)
Return

/*
===============================================================================================================================
Programa----------:AOMS003TT
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 12/02/2018
Descri��o---------: Fun��o criada para fazer a quebra de linha na mensagem digitada pelo usu�rio
Parametros--------: ExpC1	- Texto da mensagem
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS003TT(cGetMens)
 Local aTexto	:= StrTokArr( cGetMens, chr(10)+chr(13) )
 Local cRet		:= ""
 Local nI		:= 0

 For nI := 1 To Len(aTexto)
     cRet += aTexto[nI] + "<br>"
 Next nI

Return(cRet)

/*
===============================================================================================================================
Programa----------: AOMS003N
Autor-------------: Julio de Paula Paz
Data da Criacao---: 17/09/2019
Descri��o---------: Rotina de pos valida��o da linha de grid das ocorrencias de frete.
                    Chamado 29686. Validar a ocorr�ncia de sinistro e a exist�ncia de titulos de d�bito.
Parametros--------: _oModel = Modelo de dados.
Retorno-----------: _lRet = .T. ou .F.
===============================================================================================================================
*/
User Function AOMS003N(_oModel, _nLinha, _cAcao, _cCampo)
 Local _lRet := .T.
 Local _cNotaFiscal
 Local _cSerie
 Local _clojat
 Local _cCodigo
 Local _oModelMaster  := _oModel:GetModel("ZF5MASTER")
 Local _nI, _nLinAtu
 Local _cCodSinist := AllTrim(U_ITGETMV( 'IT_CODSINIS' , '000026'))
 Local _cUsersHab := SuperGetMV("IT_USPROTI",.F.,"") As Character

 Begin Sequence

    _cNotaFiscal:= _oModelMaster:GetValue("ZF5MASTER","ZF5_DOCOC")
    _cSerie     := _oModelMaster:GetValue("ZF5MASTER","ZF5_SEROC")
    _cLojat     := Posicione("SF2",1,xfilial("SF2")+_cNotaFiscal+_cSerie,"F2_I_LTRA")
    _nLinAtu    := _oModel:GetLine()
    _cCodigo    := Alltrim(str(val(_oModel:GetValue('ZF5_CODIGO'))))  // C�digo da ocorr�ncia por nota

    If _oModel:IsInserted(_nLinAtu) .Or. _oModel:IsUpdated(_nLinAtu)
         ZFC->(DbSetOrder(1))
         If ZFC->(DbSeek(xFilial("ZFC")+_oModel:GetValue("ZF5_TIPOO")))
            If ZFC->ZFC_PROTIT == "S"
               If !(RetCodUsr() $ _cUsersHab) .AND. _oModel:GetValue("ZF5_DPRORR") > 0
                  _lRet := .F.
                  Help( ,, 'Aten��o',, 'Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Usu�rio n�o tem permiss�o para usar este tipo de Ocorrencia.', 1, 0, .F. )
                  Break
               Else
                  If _oModel:GetValue("ZF5_DPRORR") == 0
                      U_ITMSG('Ocorr�ncia ' + STRZERO(VAL(_cCodigo),6) + ' - Aten��o pois esta ocorrencia esta sendo inclu�da ou atualizada com dias de prorroga��o igual a 0.',"Aten��o",,3)
                  EndIf
               EndIf
            EndIf
         EndIf
    EndIf

    If ! AllTrim( _oModel:GetValue("ZF5_TIPOO")) $ _cCodSinist
       Break
    EndIf

    SE2->(Dbsetorder(1)) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

    If _oModel:IsInserted(_nLinAtu) .Or. _oModel:IsUpdated(_nLinAtu)

       For _nI := 1 To _oModel:Length()
           _oModel:GoLine( _nI )
           _cCodigo := Alltrim(str(val(_oModel:GetValue('ZF5_CODIGO',_nI))))  // C�digo da ocorr�ncia por nota
           _cChave  := _oModel:GetValue('ZF5_CHVNDT',_nI)  // Chave: SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA
           _cFornece:= ""
           _cLoja   := ""
           If _oModel:GetValue('ZF5_TIPOC')  == "T"
              _cFornece := ALLTRIM(_oModel:GetValue("ZF5_TRANSP"))
              _cLoja    := _oModel:GetValue("ZF5_LJTRAN")
           Elseif _oModel:GetValue('ZF5_TIPOC')  == "3"
              _cFornece := _oModel:GetValue("ZF5_FORTER")
              _cLoja    := _oModel:GetValue("ZF5_LOJTER")
           Endif

           IF !EMPTY(_cChave)
              IF LEN(ALLTRIM(_cChave)) = LEN(SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM)//CHAVE SEM PARCELA
                 _cSeekSE2:=_cChave + "01" + "NDF"+_cFornece+_cLoja//A chave e o cfilant j� estam com a filai certa
              Else//CHAVE COM PARCELA - NOVO
                 _cSeekSE2:=_cChave + "NDF"+_cFornece+_cLoja//A chave e o cfilant j� estam com a filai certa
              Endif
              _cMostra:=_cSeekSE2
           ELSE//CHAVE ANTIGA
              _cSeekSE2:=xfilial("SE2")+"NDT"+SUBSTR(_cNotaFiscal,2,8) + _cCodigo + "01" + "NDF"
           EndIf

           If SE2->(DbSeek(_cSeekSE2))
              IF EMPTY(_cChave)
                 _cMostra:=_cSeekSE2+SE2->E2_FORNECE+SE2->E2_LOJA
              ENDIF
              U_ITMSG("J� existe uma nota de d�bito com a Chave: " + _cMostra + ", lan�ada para este mesmo tipo de ocorrencia.","Aten��o",,1)
              Break
           EndIf

       Next _nI

    EndIf

 End Sequence

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS003O
Autor-------------: Julio de Paula Paz
Data da Criacao---: 21/09/2021
Descri��o---------: Complementar a grava��o de dados.
Parametros--------: _oModel = Modelo de dados.
Retorno-----------: _lRet = .T.
===============================================================================================================================
*/
User Function AOMS003O(_oModel)
 Local _oModelMaster := _oModel:GetModel("ZF5MASTER") As Object
 Local _oModelGrid   := _oModel:GetModel("ZF5DETAIL") As Object
 Local _nOperation   := _oModel:GetOperation() As Numeric
 Local _cNotaFiscal  As Character
 Local _cSerie       As Character
 Local _cMercEntreg  As Character
 Local _cSitEntreg   As Character
 Local _nRegAtu      As Numeric
 Local _nI           As Numeric

 Begin Transaction

    FWFormCommit(_oModel)//Grava o que esta no model

    _cNotaFiscal := _oModelMaster:GetValue("ZF5_DOCOC")
    _cSerie      := _oModelMaster:GetValue("ZF5_SEROC")
    _nLinhas     := _oModel:GetModel('ZF5DETAIL'):Length()
    _nRegAtu     := ZF5->(Recno())

    If _nOperation == MODEL_OPERATION_UPDATE
       _nRegAtu := ZF5->(Recno())
       _cMercEntreg := _oModelMaster:GetValue("ZF5_MERENT")
       _cSitEntreg  := _oModelMaster:GetValue("ZF5_SITENT")

       ZF5->(DbSetOrder(1)) // 1 => ZF5_FILIAL+ZF5_DOCOC+ZF5_SEROC
       ZF5->(MsSeek(xFilial("ZF5")+_cNotaFiscal+_cSerie))
       Do While ! ZF5->(Eof()) .And. ZF5->(ZF5_FILIAL+ZF5_DOCOC+ZF5_SEROC) == xFilial("ZF5")+_cNotaFiscal+_cSerie
          ZF5->(RecLock("ZF5",.F.))
          ZF5->ZF5_MERENT := _cMercEntreg
          ZF5->ZF5_SITENT := _cSitEntreg
          ZF5->(MsUnLock())
          ZF5->(DbSkip())
       EndDo

       ZF5->(DbGoTo(_nRegAtu))

    EndIf

    If _nOperation == MODEL_OPERATION_INSERT .Or. _nOperation == MODEL_OPERATION_UPDATE

        For _nI := 1 to _nLinhas
          _oModel:GetModel('ZF5DETAIL'):GoLine( _nI )

            ZFC->(DbSetOrder(1))
            If ZFC->(DbSeek(xFilial("ZFC")+_oModelGrid:GetValue("ZF5_TIPOO")))
                If _oModelGrid:GetValue("ZF5_DPRORR") > 0
                    ZFC->(DbSetOrder(1))
                    If ZFC->(DbSeek(xFilial("ZFC")+_oModelGrid:GetValue("ZF5_TIPOO")))
                        If ZFC->ZFC_PROTIT == "S" 
                            ZM4->(dbSetOrder(1))
                            If !(ZM4->(DbSeek(xFilial("ZM4")+_cNotaFiscal+_cSerie+"NF "+_oModelGrid:GetValue("ZF5_CODIGO"))))
                                If !_oModelGrid:IsDeleted() .AND. _oModelGrid:IsUpdated()
                                    ZM4->(RecLock("ZM4",.T.))
                                    ZM4->ZM4_FILIAL := xFilial("ZM4")
                                    ZM4->ZM4_DOC    := _cNotaFiscal
                                    ZM4->ZM4_SERIE  := _cSerie
                                    ZM4->ZM4_TIPO   := "NF"
                                    ZM4->ZM4_CODIGO := _oModelGrid:GetValue("ZF5_CODIGO")
                                    ZM4->ZM4_DTSOL  := Date()
                                    ZM4->ZM4_SOLICI := __cUserID
                                    ZM4->ZM4_STATUS := "N"
                                    ZM4->(MsUnLock())
                                EndIf
                            Else
                                If _oModelGrid:IsDeleted()
                                    ZM4->(RecLock("ZM4",.F.))
                                    ZM4->(DbDelete())
                                    ZM4->(MsUnLock())
                                EndIf
                            EndIf
                        EndIf
                    EndIf
                EndIf
            EndIf
        Next _nI
        _aREcZF5:={}
        ZF5->(dbSetOrder(1))
        If ZF5->(dbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE))
            DO WHILE ZF5->(!EOF()) .AND. SF2->F2_FILIAL == ZF5->ZF5_FILIAL;
                                   .AND. SF2->F2_DOC    == ZF5->ZF5_DOCOC;
                                   .AND. SF2->F2_SERIE  == ZF5->ZF5_SEROC
                AADD(_aREcZF5,ZF5->(RECNO()) )
                ZF5->(DBSKIP())
            ENDDO
        EndIf
        U_AOMS3DTSF2("AOMS003",_aREcZF5,_oModel)//FUN��O CHAMADA NO AOMS072 e AOMS074 e M460FIM
    EndIf

 End Transaction

 If _lEmail
    FOR _nI := 1 TO LEN(_aDadosEmailCom)
        AOMS3Comercial(_aDadosEmailCom[_nI])
    Next _nI
    _lEmail := .F.
 EndIf

Return .T.


/*
===============================================================================================================================
Programa----------: ReplDatasTransTime
Autor-------------: Alex Wallauer
Data da Criacao---: 25/05/2023
Descri��o---------: Atualiza todas as data de previstas e entregas na 05 da 42 e na 20 (carregamento) da troca nota
Parametros--------: _nRecnoSF2Atual = Recno do SF2 posicionado
Retorno-----------: .F. ou .T.
===============================================================================================================================
*/
User Function ReplDatasTransTime( _nRecnoSF2Atual )//CHAMADA DA AOMS074.PRW TAMBEM
 LOCAL _lRet:=.F. , T
 LOCAL _aOrd:= SaveOrd({"SC5","SF2"}) // Salva a ordem dos indices.

 Local _cOperTriangular:= ALLTRIM(U_ITGETMV( "IT_OPERTRI","05,42"))// Tipos de opera��es da opera��o trigular
 Local _cOperRemessa   := RIGHT(_cOperTriangular,2)//42

 LOCAL _xF2_DTRC := SF2->F2_I_DTRC  // Entrega no Cliente (Dt.Canhoto)
 LOCAL _xF2_PENOL:= SF2->F2_I_PENOL // Previs�o de entrega no operador log�stico
 LOCAL _xF2_PENCL:= SF2->F2_I_PENCL // Previs�o de entrega no cliente
 LOCAL _xF2_DCHOL:= SF2->F2_I_DCHOL // Data de chegada no operador log�stico
 LOCAL _xF2_DCHCL:= SF2->F2_I_DCHCL // Data de chegada no cliente
 LOCAL _xF2_DENCL:= SF2->F2_I_DENCL // Data de entrega no cliente **
 LOCAL _xF2_DENOL:= SF2->F2_I_DENOL // Data de entrega no operador log�stico  EDI  **
 LOCAL _xF2_PENCO:= SF2->F2_I_PENCO // Previs�o de entrega no cliente (original)
 LOCAL _xF2_OUSER:= SF2->F2_I_OUSER // Usuario Informou o Op.Log
 LOCAL _xF2_ODATA:= SF2->F2_I_ODATA // Data inf.
 LOCAL _xF2_OHORA:= SF2->F2_I_OHORA // Hora Inf.
 LOCAL _xF2_CUSER:= SF2->F2_I_CUSER // Usu�rio de aprova��o do canhoto.
 LOCAL _xF2_CDATA:= SF2->F2_I_CDATA // Data de digita��o do Canhoto.
 LOCAL _xF2_CHORA:= SF2->F2_I_CHORA // hora de digita��o do Canhoto.
 LOCAL _xF2_CORIG:= SF2->F2_I_CORIG // Origem
 LOCAL _xF2_TT1TR:= SF2->F2_I_TT1TR // Transit Time 1o Trecho
 LOCAL _xF2_TT2TR:= SF2->F2_I_TT2TR // Transit Time 2o Trecho
 LOCAL _xF2_REDP := SF2->F2_I_REDP  // Transportadora de redespacho
 LOCAL _xF2_RELO := SF2->F2_I_RELO  // Loja Transportadora de redespacho
 LOCAL _xF2_OPER := SF2->F2_I_OPER  // Operador Logistico
 LOCAL _xF2_OPLO := SF2->F2_I_OPLO  // Loja do Operador Logistico
 LOCAL _cOBSC    := ""

 LOCAL aRecsSF2    := {}
 LOCAL _nRegrTriFat:= 0
 LOCAL _nRegrTransf:= 0
 LOCAL _nRegSF2    := 0
 LOCAL _nRegCopia  := 0

 SC5->(Dbsetorder(1))
 If SC5->(DbSeek(SF2->F2_FILIAL+ALLTRIM(SF2->F2_I_PEDID)))
    SF2->(Dbsetorder(1)) //F2_FILIAL+F2_DOC+F2_SERIE
    // ------------------ CONTROLE DA TRIANGULAR ------------------ //
    IF SC5->C5_I_OPER = _cOperRemessa//42
       If SC5->(DbSeek(SC5->C5_FILIAL+SC5->C5_I_PVFAT))// POSICIONA NO PV DE FATURAMENTO (05)
          _cOBSC:= "CANHOTO CONF NA NOTA DE REMESSA "+SF2->F2_FILIAL + "/" + SF2->F2_DOC//Pega o numero da nota antes de desposicionar
          IF SF2->(DbSeek(SC5->C5_FILIAL+SC5->C5_NOTA+SC5->C5_SERIE))
             _nRegrTriFat:= SF2->(RECNO()) //GUARDA A POSI��O DA SF2 NA NOTA NO PV DE FATURAMENTO (05)
             _nRegCopia  := _nRegrTriFat
          EndIf
       EndIf
    EndIf

    // ------------------ CONTROLE DA TROCA NOTA ------------------ //
    IF SC5->C5_I_TRCNF == "S" .AND. SC5->C5_NUM == SC5->C5_I_PDFT .AND. SC5->C5_I_OPER <> "20"// � PEDIDO DE FATURAMENTO , ATUALIZA O CARREGAMENTO (20)
       If SC5->(DbSeek(SC5->C5_I_FLFNC+SC5->C5_I_PDPR))
           _cOBSC:= "CANHOTO CONF NA NOTA DE FATURAMENTO "+SF2->F2_FILIAL + "/" + SF2->F2_DOC//Pega o numero da nota antes de desposicionar
          IF SF2->(DbSeek(SC5->C5_I_FLFNC+SC5->C5_NOTA+SC5->C5_SERIE))
            _nRegrTransf:= SF2->(RECNO()) //GUARDA A POSI��O DA SF2 NA NOTA NO PV DE CARREGAMENTO
            EndIf
       EndIf
     EndIf
    aRecsSF2:={_nRegrTriFat,_nRegrTransf}
 EndIf


 FOR T := 1 TO LEN(aRecsSF2)
     _nRegSF2:=aRecsSF2[T]

     IF _nRegSF2 > 0

        SF2->(Dbgoto(_nRegSF2))
        SF2->(Reclock("SF2",.F.))

        SF2->F2_I_DTRC  := _xF2_DTRC  // Entrega no Cliente (Dt.Canhoto)
        SF2->F2_I_PENOL := _xF2_PENOL // Previs�o de entrega no operador log�stico
        SF2->F2_I_PENCL := _xF2_PENCL // Previs�o de entrega no cliente
        SF2->F2_I_DCHOL := _xF2_DCHOL // Data de chegada no operador log�stico
        SF2->F2_I_DCHCL := _xF2_DCHCL // Data de chegada no cliente
        SF2->F2_I_DENCL := _xF2_DENCL // Data de entrega no cliente
        SF2->F2_I_DENOL := _xF2_DENOL // Data de entrega no operador log�stico  EDI // pode ser editado.
        SF2->F2_I_PENCO := _xF2_PENCO // Previs�o de entrega no cliente (original)
        SF2->F2_I_OUSER := _xF2_OUSER // Usuario Informou o Op.Log
        SF2->F2_I_ODATA := _xF2_ODATA // Data inf.
        SF2->F2_I_OHORA := _xF2_OHORA // Hora Inf.
        SF2->F2_I_CUSER := _xF2_CUSER // Usu�rio de aprova��o do canhoto.
        SF2->F2_I_CDATA := _xF2_CDATA // Data de digita��o do Canhoto.
        SF2->F2_I_CHORA := _xF2_CHORA // hora de digita��o do Canhoto.
        SF2->F2_I_CORIG := _xF2_CORIG // Origem
        SF2->F2_I_TT1TR := _xF2_TT1TR // Transit Time 1o Trecho
        SF2->F2_I_TT2TR := _xF2_TT2TR // Transit Time 2o Trecho
        SF2->F2_I_OBRC  := _cOBSC     // Observacao
        IF _nRegCopia = _nRegSF2
           SF2->F2_I_REDP  := _xF2_REDP  // Transportadora de redespacho
           SF2->F2_I_RELO  := _xF2_RELO  // Loja Transportadora de redespacho
           SF2->F2_I_OPER  := _xF2_OPER  // Operador Logistico
           SF2->F2_I_OPLO  := _xF2_OPLO  // Loja do Operador Logistico
        EndIf
        SF2->(Msunlock())
        _lRet:=.T.
     EndIf
 NEXT T

 RestOrd(_aOrd)
 SF2->(DBGOTO(_nRecnoSF2Atual))

RETURN _lRet

/*
===============================================================================================================================
Programa----------: AOMS03MP
Autor-------------: Julio de Paula Paz
Data da Criacao---: 21/09/2021
Descri��o---------: Pr�-Valida��o do Modelo de Dados.
Parametros--------: _oModel = Modelo de dados.
Retorno-----------: _lRet = .T.
===============================================================================================================================
*/
User Function AOMS03MP(_oModel)
 Local _lRet := .T.
 Local _nI
 Local _nOperation   := _oModel:GetOperation()
 Local _oModelMaster := _oModel:GetModel("ZF5MASTER")
 Local _oModelGrid   := _oModel:GetModel("ZF5DETAIL")

 Begin Sequence

    If _nOperation == MODEL_OPERATION_INSERT .Or. _nOperation == MODEL_OPERATION_UPDATE
       // ZF5MASTER
       _cNrNf    := _oModelMaster:GetValue('ZF5_DOCOC')
       _cSerieNf := _oModelMaster:GetValue('ZF5_SEROC')

       If Empty(_aItOcorre) .Or. (! Empty(_aItOcorre) .And. _aItOcorre[1,1] <> _cNrNf)
          _aItOcorre := {}
          For _nI := 1 To _oModelGrid:Length()
              _oModelGrid:GoLine(_nI)
              _cCodigo := _oModelGrid:GetValue('ZF5_CODIGO')

              Aadd(_aItOcorre,{_cNrNf,_cSerieNf,_cCodigo, xFilial("ZF5"),_nI})
          Next _nI
       EndIf
    EndIf

 End Sequence

Return _lRet


/*
===============================================================================================================================
Programa----------: AOMS3Comercial
Autor-------------: Alex Wallauer
Data da Criacao---: 14/12/2023
Descri��o---------: Monta e envia email para o comercial
Parametros--------: _aDadosOcorrencia = _aDadosEmailCom[E] as Static
Retorno-----------: .T.
===============================================================================================================================
*/
Static Function AOMS3Comercial(_aDadosOcorrencia As Array) As Logical
 Local _aConfig       := U_ITCFGEML('') , E  As Numeric, _nI As Numeric
 Local _cEmlLog       := "" As Character
 Local _cMsgEml       := "" As Character
 Local cGetCc	       := "" As Character
 Local cGetPara	    := "" As Character
 Local _cNomeFil      := cFilant+" - "+AllTrim( Posicione('SM0',1,"01"+cFilant,'M0_FILIAL') ) As Character
 //Local _cZFCDESC      := "" As Character
 Local cTit           := "" As Character
 Local cGetAssun      := "" As Character
 Local _cOperTria     := ALLTRIM(U_ITGETMV( "IT_OPERTRI","05,42")) As Character
 Local _cOperFat      := LEFT(_cOperTriangular,2) As Character //05
 Local _cOperRemessa  := RIGHT(_cOperTriangular,2) As Character //42
 Local _cZPG_EMAIL    := "" As Character
 Local _cRepresentante:= "" As Character
 Local _cCoordenador  := "" As Character
 Local _cFilsEnviaEm  := ALLTRIM(U_ITGETMV( "IT_OCOPMAIL","")) As Character
 Local _cNomeSA2      := "" As Character
 Local _cOpCod        := "" As Character
 Local _cOPLoja       := "" As Character
 Local _cCliCarre     := "" As Character
 Local _cLojCarre     := "" As Character
 Local _cNomCarre     := "" As Character
 Local _NfCarre       := "" As Character
 Local _cCNPJCarre    := "" As Character
 Local _cEndCarre     := "" As Character
 Local _cBairroCarre  := "" As Character

 IF !EMPTY(_cFilsEnviaEm) .AND. !cFilAnt $ _cFilsEnviaEm
    RETURN .F.
 EndIf

 M->ZF5_DTOCOR := _aDadosOcorrencia[01]
 M->ZF5_CODIGO := ALLTRIM(_aDadosOcorrencia[02])
 M->ZF5_MOTIVO := ALLTRIM(_aDadosOcorrencia[03])
 M->ZF5_MOTCUS := ALLTRIM(_aDadosOcorrencia[04])
 M->ZF5_TIPOO  := ALLTRIM(_aDadosOcorrencia[05])
 M->ZF5_TRANSP := ALLTRIM(_aDadosOcorrencia[06])
 M->ZF5_LJTRAN := ALLTRIM(_aDadosOcorrencia[07])
 M->ZF5_NTRANS := ALLTRIM(_aDadosOcorrencia[08])
 cTit          := "OCORRENCIA "+M->ZF5_MOTIVO
 cGetAssun     := cTit+" - Filial: "+_cNomeFil+" - Nfe: "+M->ZF5_DOCOC+" - Data Ocorr�ncia: "+DTOC(M->ZF5_DTOCOR)+ " - Sequencia "+M->ZF5_CODIGO

 SF2->(DBSETORDER(1))
 SF2->(DbSeek(xFilial("SF2")+M->ZF5_DOCOC+ALLTRIM(M->ZF5_SEROC)))
 SC5->(DBSETORDER(1))
 SC5->(DbSeek(SF2->(F2_FILIAL+F2_I_PEDIDO)))

 IF !EMPTY(SC5->C5_VEND1)
    _cRepresentante:=AllTrim(Posicione("SA3",1,xfilial("SA3")+SC5->C5_VEND1,"A3_EMAIL") )
 EndIf
 IF !EMPTY(SC5->C5_VEND2)
    _cCoordenador:=AllTrim(Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND2,"A3_EMAIL"))
 EndIf
 IF !EMPTY(SC5->C5_ASSCOD)
    _cZPG_EMAIL:=ALLTRIM(POSICIONE("ZPG",1,xFilial("ZPG")+SC5->C5_ASSCOD,"ZPG_EMAIL"))
 EndIf

 _acTo:={}
 IF !EMPTY(_cZPG_EMAIL)
    AADD(_acTo,Lower(_cZPG_EMAIL))
 EndIf
 IF !EMPTY(_cCoordenador)
    AADD(_acTo,Lower(_cCoordenador))
 EndIf
 IF !EMPTY(_cRepresentante) .AND. ASCAN(_acTo,Lower(_cRepresentante)) = 0
    AADD(_acTo,Lower(_cRepresentante))
 EndIf
 If !EMPTY(__cUserID)
    cGetCc  := LOWER(Alltrim(UsrRetMail(__cUserID))) // Pega e-mail do usuario
    AADD(_acTo,cGetCc)
 EndIf

 IF LEN(_acTo) = 0
    RETURN .F.
 EndIf

 _cTipoEntrega:=U_TipoEntrega(SC5->C5_I_AGEND)

 _aTLinhas:={}
 AADD(_aTLinhas,{"Motivo Ocorr�ncia  ",M->ZF5_TIPOO+" - "+M->ZF5_MOTIVO })
 AADD(_aTLinhas,{"Data Ocorr�ncia    ",DTOC(M->ZF5_DTOCOR) }) //M->ZF5_DTOCOR
 AADD(_aTLinhas,{"Nota fiscal        ",M->ZF5_DOCOC   }) //M->ZF5_DOCOC
 AADD(_aTLinhas,{"Serie NF           ",M->ZF5_SEROC   }) //M->ZF5_SEROC
 AADD(_aTLinhas,{"Data Emissao NF    ",DTOC(SF2->F2_EMISSAO)}) //SF2->F2_EMISSAO
 AADD(_aTLinhas,{"Natureza opera��o  ",POSICIONE("ZB4",1,xFilial("ZB4")+SC5->C5_I_OPER, "ZB4_DESCRI")}) //POSICIONE("ZB4",1,xFilial("ZB4")+SC5->C5_I_OPER, "ZB4_DESCRI"))
 AADD(_aTLinhas,{"Ordem de carga     ",M->ZF5_CARGA   }) //M->ZF5_CARGA
 AADD(_aTLinhas,{"Cliente            ",M->ZF5_NCLIEN  }) //M->ZF5_NCLIEN;
 AADD(_aTLinhas,{"Representante      ",ALLTRIM(M->ZF5_NREPRE)}) //M->ZF5_NREPRE
 AADD(_aTLinhas,{"Coordenador        ",M->ZF5_NCOOR   }) //M->ZF5_NCOOR
 AADD(_aTLinhas,{"Assistente         ",SC5->C5_ASSNOM  })// 
 AADD(_aTLinhas,{"Pedido             ",ALLTRIM(M->ZF5_PEDIDO)}) //M->ZF5_PEDIDO
 AADD(_aTLinhas,{"Volume NF          ",ALLTRIM(M->ZF5_VOLUM)}) //M->ZF5_VOLUM
 AADD(_aTLinhas,{"Peso NF            ",TRANS(M->ZF5_PESON,'@E 9,999,999,999,999.9999')   }) //M->ZF5_PESON
 AADD(_aTLinhas,{"Tipo carregamento  ",IF(SC5->C5_I_TPVEN="F","Carga Fechada","Carga Fracionada")}) //SC5->C5_I_TPVEN // NOME;
 AADD(_aTLinhas,{"Tipo de Entrega    ",_cTipoEntrega  }) //SC5->C5_I_AGEND // MOSTRAR NOME;
 AADD(_aTLinhas,{"Tipo da carga      ",Iif(SC5->C5_I_TIPCA="1","Paletizada",If(SC5->C5_I_TIPCA="2","Batida",""))}) //SC5->C5_I_TIPCA // MOSTRAR NOME;
 AADD(_aTLinhas,{"Data de agendamento",DTOC(SC5->C5_I_DTENT)  }) //SC5->C5_I_DTENT //
 AADD(_aTLinhas,{"Transportadora     ",ALLTRIM(M->ZF5_TRANSP)+" "+ALLTRIM(M->ZF5_LJTRAN)+" - "+ALLTRIM(M->ZF5_NTRANS) })//TRANSPORTADOR E LOJA FORAM PARA AS OCORRECIAS (GRID)
 If !Empty(SF2->F2_I_REDP)
    _cOpCod  := SF2->F2_I_REDP
    _cOPLoja := SF2->F2_I_RELO
 ElseIf !Empty(SF2->F2_I_OPER)
    _cOpCod  := SF2->F2_I_OPER
    _cOpLoja := SF2->F2_I_OPLO
 EndIf
 IF !EMPTY(_cOpCod) .AND. !Empty(_cOPLoja) .AND. SA2->(MSSEEK(xFilial("SA2")+_cOpCod+_cOPLoja))
    _cNomeSA2:=ALLTRIM(SA2->A2_NOME)
 EndIf
 AADD(_aTLinhas,{"Operador Logistico "  ,_cNomeSA2})
 AADD(_aTLinhas,{"C�digo da ocorrencia ",ALLTRIM(M->ZF5_CODIGO) })
 AADD(_aTLinhas,{"Motivo custo       "  ,ALLTRIM(M->ZF5_MOTCUS) })

 _cProdutos:=""
 SC6->(Dbsetorder(1))
 If SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))
    Do while SC5->C5_NUM == SC6->C6_NUM .AND. SC5->C5_FILIAL == SC6->C6_FILIAL .AND. SC5->(!EOF())
       _cProdutos+=ALLTRIM(POSICIONE("SB1",1,xfilial("SB1")+SC6->C6_PRODUTO,"B1_DESC"))+'<br>'
       SC6->(Dbskip())
    Enddo
 EndIf

 _cCliCarre     := SC5->C5_CLIENT
 _cLojCarre     := SC5->C5_LOJACLI

 If SC5->C5_I_TRCNF = 'S'
    _cFilFatur := SC5->C5_I_FILFT
    _cPedFatur := SC5->C5_I_PDFT
    _cFilcarre := SC5->C5_I_FLFNC
    _cPedCarre := SC5->C5_I_PDPR
    If SC5->C5_I_PDFT == SC5->C5_NUM //ESTOU NO DE Faturamento
       _cCliCarre := Posicione("SC5",1,SC5->C5_I_FLFNC+SC5->C5_I_PDPR,"C5_CLIENTE")
       _cLojCarre := SC5->C5_LOJACLI
       _NfCarre   := SC5->C5_NOTA
       _cNomCarre := Posicione("SA1",1,xFilial("SA1")+_cCliCarre+_cLojCarre,"A1_NOME")
    ElseIf SC5->C5_I_PDPR = SC5->C5_NUM //ESTOU NO DE Carregamento
       _cCliCarre := Posicione("SC5",1,SC5->C5_I_FILFT+SC5->C5_I_PDFT,"C5_CLIENTE")
       _cLojCarre := SC5->C5_LOJACLI
        _NfCarre  := SC5->C5_NOTA
       _cNomCarre := Posicione("SA1",1,xFilial("SA1")+_cCliCarre+_cLojCarre,"A1_NOME")
    EndIf
 ElseIf SC5->C5_I_OPER $ _cOperTria // Tipos de opera��es da opera��o trigular
    If SC5->C5_I_OPER = _cOperFat // Oper 05-Vendas
       _cCliCarre := Posicione("SC5",1,SC5->C5_FILIAL+SC5->C5_I_PVREM,"C5_CLIENTE")
       _cLojCarre := SC5->C5_LOJACLI
       _NfCarre   := SC5->C5_NOTA
       _cNomCarre := Posicione("SA1",1,xFilial("SA1")+_cCliCarre+_cLojCarre,"A1_NOME")
    ElseIf SC5->C5_I_OPER = _cOperRemessa // Oper 42-Remessa
       _cCliCarre := Posicione("SC5",1,SC5->C5_FILIAL+SC5->C5_I_PVFAT,"C5_CLIENTE")
       _cLojCarre := SC5->C5_LOJACLI
       _NfCarre   := SC5->C5_NOTA
       _cNomCarre := Posicione("SA1",1,xFilial("SA1")+_cCliCarre+_cLojCarre,"A1_NOME")
    EndIf
 EndIf

 _cNomCarre    := Posicione("SA1",1,xFilial("SA1")+_cCliCarre+_cLojCarre,"A1_NOME")
 _cCNPJCarre   := Posicione("SA1",1,xFilial("SA1")+_cCliCarre+_cLojCarre,"A1_CGC")
 _cEndCarre    := Posicione("SA1",1,xFilial("SA1")+_cCliCarre+_cLojCarre,"A1_END")
 _cBairroCarre := Posicione("SA1",1,xFilial("SA1")+_cCliCarre+_cLojCarre,"A1_BAIRRO")

 AADD(_aTLinhas,{"NF Vinculada     ",_NfCarre })//Usar mesma logica existente no programa ROMS067, vari�vel _NfCarre;
 AADD(_aTLinhas,{"Cliente vinculado",_cCliCarre + "-" + _cLojCarre + " " + _cNomCarre })//Usar mesma logica existente no programa ROMS067, vari�vel _cCliCarre;
 AADD(_aTLinhas,{"CNPJ             ",_cCNPJCarre })
 AADD(_aTLinhas,{"Endere�o         ",_cEndCarre })
 AADD(_aTLinhas,{"Bairro           ",_cBairroCarre })
 AADD(_aTLinhas,{"Munic�pio          ",M->ZF5_CIDADE  }) //M->ZF5_CIDADE
 AADD(_aTLinhas,{"Estado             ",M->ZF5_UF      }) //M->ZF5_UF
 AADD(_aTLinhas,{"Produtos"         ,_cProdutos })//Buscar todos os produto do pedido (ZF5_PEDIDO) buscando na tabela SC6,trazer nome do produto;

 _cMsgEml := '<html>'
 _cMsgEml += '<head><title>'+cTit+'</title></head>'
 _cMsgEml += '<body>'
 _cMsgEml += '<style type="text/css"><!--'
 _cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
 _cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
 _cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
 _cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'//#E5E5E5
 _cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
 _cMsgEml += '--></style>'
 _cMsgEml += '<center>'
 _cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="600" height="50"><br>'
 _cMsgEml += '<table class="bordasimples" width="600">'
 _cMsgEml += '    <tr>'
 _cMsgEml += '	     <td class="titulos"><center><b>'+cTit+'</b></center></td>'
 _cMsgEml += '	 </tr>'
 _cMsgEml += '</table>'
 _cMsgEml += '<br>'
 _cMsgEml += '<table class="bordasimples" width="600">'
 _cMsgEml += '    <tr>'
 _cMsgEml += '      <td align="center" colspan="2" class="grupos"><b>OCORRENCIA</b></td>'
 _cMsgEml += '    </tr>'
 _cMsgEml += '    <tr>'
 _cMsgEml += '      <td class="itens" align="center" width="30%"><b>Incluida por: </b></td>'
 _cMsgEml += '      <td class="itens" >'+ UsrFullName(__cUserID) +'</td>'
 _cMsgEml += '    </tr>'
 _cMsgEml += '    <tr>'
 _cMsgEml += '      <td class="itens" align="center" width="30%"><b>Filial:</b></td>'
 _cMsgEml += '      <td class="itens" >'+ _cNomeFil +'</td>'
 _cMsgEml += '    </tr>'
 If !SuperGetMV("IT_AMBTEST",.F.,.T.)
    _cMsgEml += ' <tr>'
    _cMsgEml += '   <td class="itens" align="center" width="30%"><b>Emails Oficial</b></td>'
    _cMsgEml += '   <td class="itens" >'+ _cZPG_EMAIL+"<br>"+_cCoordenador+"<br>"+_cRepresentante +'</td>'
    _cMsgEml += ' </tr>'
 EndIf
 _cMsgEml += '</table>'

 //          01   02   03   04   05
 _aSizeOK:={"20","80"}

 _cMsgEml += '<br>'
 _cMsgEml += '<table class="bordasimples" width="1300">'
 _cMsgEml += '    <tr>'
 _cMsgEml += '      <td align="center" colspan="'+ALLTRIM(STR(LEN(_aSizeOK)))+'" class="grupos"><b>DADOS DA OCORENCIA</b></td>'
 _cMsgEml += '    </tr>'
 _cMsgEml += '    #LISTAOK#'
 _cMsgEml += '</table>'
 _cMsgEml += '<br>'

 _cOKLista:=""
 FOR _nI := 1 TO LEN(_aTLinhas)
     _cOKLista += '    <tr>'
     _cOKLista += "      <td width='"+_aSizeOK[01]+"' BGCOLOR=#E5E5E5 ><font color= #000000 style='font-size: 15px; font-weight: bold;'>"+_aTLinhas[_nI][01]+"</font></td>
     _cOKLista += '      <td class="itens" align="left" width="'+_aSizeOK[02]+'%">'+ _aTLinhas[_nI][02]+'</td>'
     _cOKLista += '    </tr>'
 NEXT _nI

 _cMsgEml:=STRTRAN(_cMsgEml,"#LISTAOK#",_cOKLista)

 _cMsgEml += '</center>'
 _cMsgEml += '</body>'
 _cMsgEml += '</html>'

 ///////////////////////////////// RODAPE FIXO ///////////////////////////////
 _cTel:=""
 If (Len(PswRet()) # 0) // Quando nao for rotina automatica do configurador
     _cSetor:= AllTrim(PswRet()[1][12])		// Pega departamento do usuario
 EndIf
 If EMPTY(_cSetor)
      _cSetor := "Logistica"
 EndIf
 If EMPTY(_cTel)
    _cTel:=AllTrim( Posicione('SM0',1,"01"+cFilant,'M0_TEL') )
 EndIf

 _cMsgEml += '<br><br>'
 _cMsgEml += '<br><br>'
 _cMsgEml += '&nbsp;&nbsp;&nbsp;A disposi��o!'
 _cMsgEml += '<br><br>'
 _cMsgEml += '<table class=MsoNormalTable border=0 cellpadding=0>'
 _cMsgEml += '<tr>'
 _cMsgEml +=     '<td style="padding:.75pt .75pt .75pt .75pt">'
 _cMsgEml +=         '<p class=MsoNormal align=center style="text-align:center">'
 _cMsgEml +=             '<b><span style="font-size:18.0pt;font-family:'+"'"+'Arial'+"'"+','+"'"+'sans-serif'+"'"+';color:#1D2668;mso-fareast-language:PT-BR">'+ Capital( AllTrim( UsrFullName( __cUserId ) ) ) +'</span></b>'
 _cMsgEml +=             '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>
 _cMsgEml +=     '</td>'
 _cMsgEml +=     '<td style="background:#A2CFF0;padding:.75pt .75pt .75pt .75pt">&nbsp;</td>'
 _cMsgEml +=     '<td style="padding:.75pt .75pt .75pt .75pt">
 _cMsgEml +=         '<table class=MsoNormalTable border=0 cellpadding=0>'
 _cMsgEml +=              '<tr>'
 _cMsgEml +=                  '<td style="padding:.75pt .75pt .75pt .75pt">'
 _cMsgEml +=                      '<p class=MsoNormal><b><span style="font-size:13.5pt;font-family:'+"'"+'Arial'+"'"+','+"'"+'sans-serif'+"'"+';color:#6FB4E3;mso-fareast-language:PT-BR">' + _cSetor + '</span></b>'
 _cMsgEml +=                      '<b><span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></b>
 _cMsgEml +=                      '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"><br></span>
 _cMsgEml +=                      '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>
 _cMsgEml +=                  '</td>'
 _cMsgEml +=              '</tr>'
 _cMsgEml +=              '<tr>'
 _cMsgEml +=                  '<td style="padding:.75pt .75pt .75pt .75pt">
 _cMsgEml +=                      '<p class=MsoNormal><span style="font-size:12.0pt;font-family:'+"'"+'Arial'+"'"+','+"'"+'sans-serif'+"'"+';color:#1D2668;mso-fareast-language:PT-BR">Tel: '+_cTel+'</span>'
 _cMsgEml +=                      '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>
 _cMsgEml +=                  '</td>'
 _cMsgEml +=              '</tr>'
 _cMsgEml +=         '</table>'
 _cMsgEml +=     '</td>'
 _cMsgEml += '</tr>'
 _cMsgEml += '</table>'
 _cMsgEml += '<table class=MsoNormalTable border=0 cellpadding=0 width=437 style="width:327.75pt">'
 _cMsgEml +=     '<tr>'
 _cMsgEml +=         '<td style="padding:.75pt .75pt .75pt .75pt">'
 _cMsgEml +=             '<p class=MsoNormal align=center style="text-align:center">'
 _cMsgEml +=             '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR">'
 _cMsgEml +=                 '<img width=400 height=51 src="http://www.italac.com.br/assinatura-italac/images/marcas-goiasminas-industria-de-laticinios-ltda.jpg">'
 _cMsgEml +=             '</span>
 _cMsgEml +=             '</p>'
 _cMsgEml +=         '</td>'
 _cMsgEml +=     '</tr>'
 _cMsgEml += '</table>'
 _cMsgEml += '<p class=MsoNormal><span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';display:none;mso-fareast-language:PT-BR">&nbsp;</span></p>'
 _cMsgEml += '<table class=MsoNormalTable border=0 cellpadding=0>'
 _cMsgEml +=     '<tr>'
 _cMsgEml +=         '<td style="padding:.75pt .75pt .75pt .75pt">'
 _cMsgEml +=             '<p class=MsoNormal align=center style="text-align:center">'
 _cMsgEml +=             '<b><span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';color:#1D2668;mso-fareast-language:PT-BR">Pol�tica de Privacidade </span></b>'
 _cMsgEml +=             '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>
 _cMsgEml +=             '<p class=MsoNormal style="mso-margin-top-alt:auto;mso-margin-bottom-alt:auto;text-align:justify">'
 _cMsgEml +=             '<span style="font-size:7.5pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';color:#1D2668;mso-fareast-language:PT-BR">
 _cMsgEml +=                 'Esta mensagem � destinada exclusivamente para fins profissionais, para a(s) pessoa(s) a quem for dirigida, podendo conter informa��o confidencial e legalmente privilegiada. '
 _cMsgEml +=                 'Ao receb�-la, se voc� n�o for destinat�rio desta mensagem, fica automaticamente notificado de abster-se a divulgar, copiar, distribuir, examinar ou, de qualquer forma, utilizar '
 _cMsgEml +=                 'sua informa��o, por configurar ato ilegal. Caso voc� tenha recebido esta mensagem indevidamente, solicitamos que nos retorne este e-mail, promovendo, concomitantemente sua '
 _cMsgEml +=                 'elimina��o de sua base de dados, registros ou qualquer outro sistema de controle. Fica desprovida de efic�cia e validade a mensagem que contiver v�nculos obrigacionais, expedida '
 _cMsgEml +=                 'por quem n�o detenha poderes de representa��o, bem como n�o esteja legalmente habilitado para utilizar o referido endere�o eletr�nico, configurando falta grave conforme nossa '
 _cMsgEml +=                 'pol�tica de privacidade corporativa. As informa��es nela contidas s�o de propriedade da Italac, podendo ser divulgadas apenas a quem de direito e devidamente reconhecido pela empresa.'
 _cMsgEml += '<BR>Ambiente: ['+ GETENVSERVER() +'] / Fonte: [AOMS003] </BR>'
 _cMsgEml +=             '</span>'
 _cMsgEml +=             '<span style="font-size:7.5pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>'
 _cMsgEml +=         '</td>'
 _cMsgEml +=     '</tr>
 _cMsgEml += '</table>'

 _cMensagem:=""
 _lOK:=.F.
 _lErro:=.F.
 FOR E := 1 TO LEN(_acTo)

     cGetPara:=_acTo[E]
 //    ITEnvMail(cFrom        ,cEmailTo,_cEmailCo,cEmailBcc,cAssunto ,cMensagem,cAttach   ,cAccount    ,cPassword   ,cServer     ,cPortCon    ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro)
     U_ITENVMAIL(_aConfig[01], cGetPara,         ,         ,cGetAssun,_cMsgEml ,          ,_aConfig[01],_aConfig[02],_aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

     _cMensagem+="Para: "+cGetPara+" : "+_cEmlLog+CRLF
     IF "SUCESSO" $ UPPER(_cEmlLog)
        _lOK:=.T.
     ELSE
        _lErro:=.T.
     EndIf
 NEXT E
 _nTipo:=2 // V
 IF _lOK .AND. _lErro
    _nTipo:=3 // !
 ELSEIF !_lOK .AND. _lErro
    _nTipo:=1 // X
 EndIf
 U_ITMSG(_cMensagem,"Envio do E-MAIL",,_nTipo)

Return .T.



/*
===============================================================================================================================
Programa----------: AOMS003M
Autor-------------: Alex Wallauer
Data da Criacao---: 26/12/2023
Descri��o---------: Pontos de entradas do AOMS103
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER FUNCTION AOMS003M()
 Local aParam := PARAMIXB

 If aParam <> NIL
    //oObj    := aParam[1]
    cIdPonto  := aParam[2]
    //cIdModel:= aParam[3]
    //lIsGrid := (Len(aParam) > 3)

    If     cIdPonto == "MODELPOS" //"Chamada na valida��o total do modelo."
    ElseIf cIdPonto == "FORMPOS" //"Chamada na valida��o total do formul�rio."
     ElseIf cIdPonto == "FORMLINEPRE"//Chamada na pr� valida��o da linha do formul�rio
     ElseIf cIdPonto == "FORMLINEPOS"//Chamada na valida��o da linha do formul�rio
     ElseIf cIdPonto == "MODELCOMMITTTS"//Chamada ap�s a grava��o total do modelo e dentro da transa��o.
     ElseIf cIdPonto == "MODELCOMMITNTTS"//Chamada ap�s a grava��o total do modelo e fora da transa��o.
     ElseIf cIdPonto == "FORMCOMMITTTSPRE"//Chamada ap�s a grava��o da tabela do formul�rio.
     ElseIf cIdPonto == "FORMCOMMITTTSPOS"//Chamada ap�s a grava��o da tabela do formul�rio.
     ElseIf cIdPonto == "MODELCANCEL"
     ElseIf cIdPonto == "BUTTONBAR"
            aRet := {}
            aAdd( aRet ,{"Atualizar Telefones" , 'Atualiza Tels.' , {|| U_AOMS3Atu(.F.) } , "Atualizar Telefones" } )
           aAdd( aRet ,{"Verifica Carga" , 'Verifica Carga' , {|| U_VISCARGA( ZF5->ZF5_FILIAL, ZF5->ZF5_CARGA ) } , "Atualizar Telefones" } )
           RETURN aRet
    EndIf

 EndIf

RETURN .T.

/*
===============================================================================================================================
Programa----------: AOMS3Atu
Autor-------------: Alex Wallauer
Data da Criacao---: 26/12/2023
Descri��o---------: Atualiza os campos de nome + telefone
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER FUNCTION AOMS3Atu(_lGravar)
 Local _oModel := FWModelActive()
 Local _oModelMaster

 IF _lGravar .OR. _oModel:GetOperation() = 4

    M->ZF5_DMOTOR:=U_AOMS003Z("ZF5_DMOTOR")
    M->ZF5_NREPRE:=U_AOMS003Z("ZF5_NREPRE")
    M->ZF5_NCOOR :=U_AOMS003Z("ZF5_NCOOR" )
    M->ZF5_NCLIEN:=U_AOMS003Z("ZF5_NCLIEN")
    IF _lGravar
       ZF5->ZF5_DMOTOR        :=M->ZF5_DMOTOR
       ZF5->ZF5_NREPRE        :=M->ZF5_NREPRE
       ZF5->ZF5_NCOOR         :=M->ZF5_NCOOR
       ZF5->ZF5_NCLIEN        :=M->ZF5_NCLIEN
       (cAliasAux)->STATUS2   :="N"//Algum Diferente? N�O
       (cAliasAux)->MARCA     :=" "
       (cAliasAux)->ZF5_DMOTOR:=M->ZF5_DMOTOR
       (cAliasAux)->ZF5_NREPRE:=M->ZF5_NREPRE
       (cAliasAux)->ZF5_NCOOR :=M->ZF5_NCOOR
       (cAliasAux)->ZF5_NCLIEN:=M->ZF5_NCLIEN
    ELSE
       _oModelMaster:=_oModel:GetModel("ZF5MASTER")
       _oModelMaster:LoadValue("ZF5_DMOTOR",M->ZF5_DMOTOR)
       _oModelMaster:LoadValue("ZF5_NREPRE",M->ZF5_NREPRE)
       _oModelMaster:LoadValue("ZF5_NCOOR" ,M->ZF5_NCOOR )
       _oModelMaster:LoadValue("ZF5_NCLIEN",M->ZF5_NCLIEN)
    EndIf

 EndIf

RETURN .T.

/*
===============================================================================================================================
Programa----------: CalcTransiTime  #CalcTransiTime()
Autor-------------: Alex Wallauer
Data da Criacao---: 01/02/2024
Descri��o---------: Calcula Transit time da Unidade de Carregamento at� o Operador Log�stico e
                    Calcula Transit time do Endere�o do Operador Log�stico at� o Cliente
Parametros--------: _dDataMRef - Data para somar o DIAS de Transit time - SAIDA ITALAC
                    _dDtnoOL   - Data para somar o DIAS de Transit time - SAIDA OPERADOR LOGISTICO
Retorno-----------: {DIAS Transit time da Unidade de Carregamento at� o Operador Log�stico,
                     DIAS Transit time do Endere�o do Operador Log�stico at� o Cliente,
                     Dias do TRECHO 1,
                     Dias do TRECHO 2}
===============================================================================================================================
*/
USER Function CalcTransiTime(_dDataMRef,_dDtnoOL)
 Local lBuscaItalacCliente:=.F.// DESTINO DA ITALAC PARA O CLIENTE
 Local cCodOL      := ""
 Local cLojaOP     := ""
 Local cCodCli     := ""
 Local cLojaCli    := ""
 Local _cFilCarreg := ""
 Local _cEstado    := ""
 Local _dDataPENCO := CTOD("")
 Local _dDataPENOL := CTOD("")
 DEFAULT _dDtnoOL  := CTOD("")
 DEFAULT _dDataMRef:= _dDtnoOL
 SF2->(DBSetOrder(1))
 SC5->(DBSetOrder(1))
 SC5->(DbSeek(SF2->F2_FILIAL+SF2->F2_I_PEDID))

 cCodCli    := SF2->F2_CLIENTE
 cLojaCli   := SF2->F2_LOJA
 _cFilCarreg:= SC5->C5_FILIAL

 IF SC5->C5_I_TRCNF == "S"
    If !Empty(SC5->C5_I_FLFNC) //SE PEDIDO DE FATURAMENTO
        _cFilCarreg := SC5->C5_I_FLFNC
    EndIf

    If SC5->C5_I_FLFNC == SC5->C5_FILIAL //SE PEDIDO DE CARREGAMENTO
       IF  SC5->(DbSeek(SC5->C5_I_FILFT+SC5->C5_I_PDFT))// SEEK no PEDIDO de FATURAMENTO
           cCodCli := SC5->C5_CLIENTE
           cLojaCli:= SC5->C5_LOJACLI
       EndIf
    EndIf
 EndIf

 SA1->(DBSetOrder(1))
 SA1->(DbSeek(xFilial("SA1") + cCodCli + cLojaCli))
 _cEstado    := SA1->A1_EST
 _cCodMunic  := SA1->A1_COD_MUN
 _nDiasZ31   := 0//TRECHO 1 - Preenche na fun��o BuscaZ31() - M460FIM.PRW
 _nDiasZG5   := 0//TRECHO 2 - Preenche na fun��o BuscaZG5() - M460FIM.PRW
lBuscaItalacCliente:=.F.// DESTINO DA ITALAC PARA O CLIENTE
 
 DAI->(Dbsetorder(3))
 If DAI->(DbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE))//SE TEM CARGA

     IF !EMPTY(DAI->DAI_I_OPLO)
        cCodOL :=DAI->DAI_I_OPLO
        cLojaOP:=DAI->DAI_I_LOPL
     ELSE
        cCodOL :=DAI->DAI_I_TRED
        cLojaOP:=DAI->DAI_I_LTRE
     EndIf

     If !Empty(cCodOL)

       IF EMPTY(_dDtnoOL)
	    //***********************************************************************************
       //SE ALTERAR A LOGICA AQUI ALTERAR Na #GrvTransiTime() no M460FIM.PRW  TAMBEM
	    //***********************************************************************************

          //************************* DESTINO: DA ITALAC PARA OPERADOR LOGISTICO *************************
          SA2->(DBSetOrder(1))
          SA2->(DbSeek(xFilial("SA2") + cCodOL + cLojaOP))
          _cEstadoOP := SA2->A2_EST
          _cCodMunOP := SA2->A2_COD_MUN
                   //_cFilCarreg,_cCod ,_cLoja ,_cOperPedV    ,_cTipoVenda    ,_cEstado,_cCodMunic,@_dDataRef,@_nDiasZG5,_cLocalEmb
          U_BuscaZG5(_cFilCarreg,cCodOL,cLojaOP,SC5->C5_I_OPER,SC5->C5_I_TPVEN,_cEstadoOP,_cCodMunOP,@_dDataMRef,@_nDiasZG5,SC5->C5_I_LOCEM)// DESTINO: DA ITALAC PARA OPERADOR LOGISTICO
          IF EMPTY(_dDataMRef)
             _dDataMRef:=SF2->F2_EMISSAO
          EndIf
          _dDataPENOL:= U_IT_DTVALIDA(_dDataMRef)//Se a data calculada da entrega cair em um domingo ou em um feriado nacional, a data deve ser o pr�ximo dia �til.
          _dDataMRef := _dDataPENOL
        ELSE
           _dDataPENOL:= _dDtnoOL
        EndIf

 //************************* DESTINO: DO OPERADOR LOGISTICO PARA O CLIENTE *************************
        IF !EMPTY(_dDataPENOL)
           _dDataMRef := _dDataPENOL
                     //cCodOL,cLojaOP,cCodCli,cLojaCli,_dDataRef,@_nDiasUteis
           U_BuscaZ31(cCodOL,cLojaOP,cCodCli,cLojaCli,_dDataMRef,@_nDiasZ31)//DESTINO: DO OPERADOR LOGISTICO PARA O CLIENTE
           _dDataPENCO:= U_IT_DTVALIDA(_dDataMRef,_nDiasZ31)//SE A DATA CALCULADA DA ENTREGA DEVE CONTAR S� DIA UTIL
         EndIf

     Else// SE NAO TEM OPERADOR LOGISTICO
        lBuscaItalacCliente:=.T.// DESTINO DA ITALAC PARA O CLIENTE
     EndIf

 Else//SE NAO TEM CARGA
     lBuscaItalacCliente:=.T.// DESTINO DA ITALAC PARA O CLIENTE
 EndIf

 //***********************************************************************************
 //SE ALTERAR A LOGICA AQUI ALTERAR Na #GrvTransiTime() no M460FIM.PRW  TAMBEM
 //***********************************************************************************
 //************************* DESTINO: DA ITALAC PARA O CLIENTE *************************
 IF lBuscaItalacCliente
    _nDiasZG5 := 0
    IF ZEL->(FIELDPOS("ZEL_DIAUTI")) > 0 .AND. POSICIONE("ZEL",1,xFilial("ZEL")+SF2->F2_I_LOCEM,"ZEL_DIAUTI") = "2"//CD da 01 n�o entrega de Sabado
                //_cFilCarreg,_cCod  ,_cLoja  ,_cOperPedV   ,_cTipoVenda     ,_cEstado,_cCodMunic,         _dDataRef//A data n�o via como referencia pq vai ser calculada depois
       U_BuscaZG5(_cFilCarreg,cCodCli,cLojaCli,SC5->C5_I_OPER,SC5->C5_I_TPVEN,_cEstado,_cCodMunic,_dDataMRef,@_nDiasZG5,SC5->C5_I_LOCEM)// DESTINO: DA ITALAC PARA O CLIENTE
       IF EMPTY(_dDataMRef)
          _dDataMRef:=SF2->F2_EMISSAO
       EndIf
       _dDataPENCO:= U_IT_DTVALIDA(_dDataMRef,_nDiasZG5)//Data calculada da entrega deve contar s� dia util: n�o conta sabado, domingo e feriado nacional
    ELSE//Sabado � dia util ? 1-Sim e branco
                 //_cFilCarreg,_cCod  ,_cLoja  ,_cOperPedV    ,_cTipoVenda    ,_cEstado,_cCodMunic,@_dDataRef
        U_BuscaZG5(_cFilCarreg,cCodCli,cLojaCli,SC5->C5_I_OPER,SC5->C5_I_TPVEN,_cEstado,_cCodMunic,@_dDataMRef,@_nDiasZG5,SC5->C5_I_LOCEM)// DESTINO: DA ITALAC PARA O CLIENTE
       IF EMPTY(_dDataMRef)
          _dDataMRef:=SF2->F2_EMISSAO
       EndIf
       _dDataPENCO:= U_IT_DTVALIDA(_dDataMRef)//Se a data calculada da entrega cair em um domingo ou em um feriado nacional, a data deve ser o pr�ximo dia �til.
    EndIf
 EndIf

 aRet:={_dDataPENOL,;// SF2->F2_I_PENOL - Previs�o de entrega no operador log�stico
        _dDataPENCO,;// SF2->F2_I_PENCL - Previs�o de entrega no cliente
        _nDiasZG5  ,;// SF2->F2_I_TT1TR - Dias do TRECHO 1
        _nDiasZ31   }// SF2->F2_I_TT2TR - Dias do TRECHO 2

RETURN aRet


/*
===============================================================================================================================
Programa----------: AOMS03OPR
Autor-------------: Antonio Neves
Data da Criacao---: 20/03/2024
Descri��o---------: Retorna o Operador Log�stico
Parametros--------: __nOpc, __cFilial, __cDocOc, __cSerOc
Retorno-----------: _cInfOper
===============================================================================================================================
*/
User Function AOMS03OPR(__nOpc, __cFilial, __cDocOc, __cSerOc)

    Local _cInfOper   := ""
    Local _cCodOper   := ""
    Local _cLojOper   := ""

    If __nOpc == 1
        _cInfOper   := POSICIONE("SF2",1,__cFilial+__cDocOc+__cSerOc,"F2_I_OPER")
    ElseIf __nOpc == 2
        _cInfOper   := POSICIONE("SF2",1,__cFilial+__cDocOc+__cSerOc,"F2_I_OPLO")
    ElseIf __nOpc == 3
        _cCodOper   := POSICIONE("SF2",1,__cFilial+__cDocOc+__cSerOc,"F2_I_OPER")
        _cLojOper   := SF2->F2_I_OPLO
        _cInfOper   := POSICIONE("SA2",1,xFilial("SA4")+_cCodOper+_cLojOper,"A2_CGC")
    ElseIf __nOpc == 4
        _cCodOper   := POSICIONE("SF2",1,__cFilial+__cDocOc+__cSerOc,"F2_I_OPER")
        _cLojOper   := SF2->F2_I_OPLO
        _cInfOper   := POSICIONE("SA2",1,xFilial("SA2")+_cCodOper+_cLojOper,"A2_NOME")
    ElseIf __nOpc == 5
        _cCodOper   := POSICIONE("SF2",1,__cFilial+__cDocOc+__cSerOc,"F2_I_OPER")
        _cLojOper   := SF2->F2_I_OPLO
        _cInfOper   := POSICIONE("SA2",1,xFilial("SA2")+_cCodOper+_cLojOper,"A2_EST")
    ElseIf __nOpc == 6
        _cCodOper   := POSICIONE("SF2",1,__cFilial+__cDocOc+__cSerOc,"F2_I_OPER")
        _cLojOper   := SF2->F2_I_OPLO
        _cInfOper   := POSICIONE("SA2",1,xFilial("SA2")+_cCodOper+_cLojOper,"A2_MUN")
    ElseIf __nOpc == 7
        _cCodOper   := POSICIONE("SF2",1,__cFilial+__cDocOc+__cSerOc,"F2_I_OPER")
        _cLojOper   := SF2->F2_I_OPLO
        _cInfOper   := POSICIONE("SA2",1,xFilial("SA2")+_cCodOper+_cLojOper,"A2_DDD")
    ElseIf __nOpc == 8
        _cCodOper   := POSICIONE("SF2",1,__cFilial+__cDocOc+__cSerOc,"F2_I_OPER")
        _cLojOper   := SF2->F2_I_OPLO
        _cInfOper   := POSICIONE("SA2",1,xFilial("SA2")+_cCodOper+_cLojOper,"A2_TEL")
    EndIf


Return _cInfOper


/*
===============================================================================================================================
Programa----------: VISCARGA
Autor-------------: Antonio Neves
Data da Criacao---: 21/03/2024
Descri��o---------: Retorno Da Rela��o de Carga
Parametros--------: _cFilial = C�digo da Filial
                    _cCarga  = Numero da Carga
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function VISCARGA(_cFilial, _cCarga)
  Local _aItCarga  := {}
  Local _cNomeCli  := {}
  Local _aItens    := {}
  Local _nPesTot   := 0

  Begin Sequence

   SA1->(DbSetOrder(1))
   DAI->(DbSetOrder(1))

   If DAI->(MsSeek(_cFilial+U_ItKey(_cCarga,"DAI_COD")))
      Do While !DAI->(Eof()) .And. DAI->DAI_FILIAL == _cFilial .And. DAI->DAI_COD == U_ItKey(_cCarga,"DAI_COD")

         _cNomeCli := ""
         If SA1->(MsSeek(xFilial("SA1")+DAI->DAI_CLIENT+DAI->DAI_LOJA))
             _cNomeCli := SA1->A1_NOME
         EndIf

         _aItCarga := {}
         AADD(_aItCarga, DAI->DAI_NFISCA)
         AADD(_aItCarga, DAI->DAI_SERIE)
         AADD(_aItCarga, DAI->DAI_CLIENT)
         AADD(_aItCarga, DAI->DAI_LOJA)
         AADD(_aItCarga, _cNomeCli)
         AADD(_aItCarga, Transform(DAI->DAI_PESO,"@E 999,999,999.9999"))
         AADD(_aItens, _aItCarga)

         _nPestot += DAI->DAI_PESO

         DAI->(dbSKip())
      EndDo
   EndIf

   IF LEN(_aItens) = 0
      U_ITMSG("N�o existe Carga "+_cFilial+_cCarga,"Aten��o",,1)
      RETURN .F.
   EndIf

   _cTitulo:= "Rela��o de Carga: " + AllTrim(_cCarga) + "  - Peso Total: " + Transform(_nPestot,"@E 999,999,999.9999")
   _aCabec := {"Nota Fiscal", "Serie","Cliente","Loja","Raz�o Social","Peso da Nota"}

   U_ITListBox(_cTitulo , _aCabec , _aItens , .T. , 1 , "Exporta��o excel/arquivo")

 End Sequence

Return Nil


/*
===============================================================================================================================
Programa----------: AOMS3DTSF2
Autor-------------: Alex Wallauer
Data da Criacao---: 26/09/2024
Descri��o---------: Rotina de gravacao de datas do SF2 do programaa: AOMS003 / AOMS072 / AOMS074 / M460FIM
Parametros--------: _cOrigem: programa AOMS003 / AOMS072 / AOMS074 / M460FIM / _aRecZF5 := array de recnos do ZF5 / _oModel
Retorno-----------: .T. ou .F.
===============================================================================================================================*/
User Function AOMS3DTSF2(_cOrigem As Character,_aRecZF5 As Array,_oModel As Object) As Logical
 LOCAL _nI           As Numeric
 Local _oModelMaster As Object
 Local _oModelGrid   As Object
 Local _dDtTipoA     As Date
 Local _dDtTipoB     As Date
 Local _dDtTipoC     As Date
 Local _dDtTipoD     As Date
 Local _dDtTipoE     As Date
 Local _dDtTipoF     As Date
 Local _dZF5DTOCOR   As Date
 Local _cTipoOcorr   As Character
 Local _cDtTran      As Character
 Local _cAliasZDS    As Character
 Local _cQuery       As Character
 Local _cObsCom      As Character
 Local _cStatusSit   As Character
 Local _cStatusEmi   As Character
 Local _cListaSF2    As Character
 Local _cAmbiente    As Character
 Local _cZF5CODIGO   As Character
 Local _cListaOco    As Character
 Local _lGravaSF2    As Logical
 Local _lOriGravado  As Logical
 Local _aRec_TA_TF   As Array

 _dDtTipoA   := CTOD("")
 _dDtTipoB   := CTOD("")
 _dDtTipoC   := CTOD("")
 _dDtTipoD   := CTOD("")
 _dDtTipoE   := CTOD("")
 _dDtTipoF   := CTOD("")
 _cDtTran    := ""
 _cAliasZDS  := ""
 _cQuery     := ""
 _cObsCom    := ""
 _cStatusSit := ""
 _cStatusEmi := ""
 _cListaSF2  :="TIPO(ZFC_DTTRAN);CAMPO;ANTES;DEPOIS"+CRLF
 _cAmbiente  := ALLTRIM(UPPER(GETENVSERVER()))
 _lGravaSF2  := .T.
 _lOriGravado:= (_cOrigem = "AOMS003" .OR. _cOrigem = "AOMS072" .OR. _cOrigem = "AOMS074" .OR. _cOrigem = "M460FIM_GRAVA" .OR. _cOrigem = "M460FIM_LER")
 _aRec_TA_TF := {}

 IF _cOrigem = "TELA"//n�o usa por enquanto

    _oModelMaster:= _oModel:GetModel("ZF5MASTER")
    _oModelGrid  := _oModel:GetModel("ZF5DETAIL")
    _nLinhas     := _oModelGrid:Length()
    _oModelGrid:GoLine( _nLinhas )
    _cStatusSit  := _oModelGrid:GetValue("ZF5_STUSIT")
    _cStatusEmi  := _oModelGrid:GetValue("ZF5_STUEMI")
    _cObsCom     := _oModelGrid:GetValue("ZF5_OBSCOM")
    _cNotaFiscal := _oModelMaster:GetValue("ZF5_DOCOC")
    _cSerie      := _oModelMaster:GetValue("ZF5_SEROC")
    _cZF5Filial  := xFilial("ZF5")

 ELSEIF _lOriGravado

    _nLinhas    := LEN(_aRecZF5)
    _aRecZF5    := aSort(_aRecZF5)//ORDENA POR RECNO
     ZF5->(DBGOTO(_aRecZF5[_nLinhas]))
    _cStatusSit := ZF5->ZF5_STUSIT
    _cStatusEmi := ZF5->ZF5_STUEMI
    _cObsCom    := ZF5->ZF5_OBSCOM
    _cNotaFiscal:= ZF5->ZF5_DOCOC
    _cSerie     := ZF5->ZF5_SEROC
    _cZF5Filial := ZF5->ZF5_FILIAL
    IF _cOrigem = "M460FIM_LER"
       _lGravaSF2:= .F.
    ENDIF
 ELSE
    RETURN .F.
 EndIf

 _cListaOco:="ZF5_TIPOO;ZFC_DTTRAN;ZF5_DTOCOR;ZF5_CODIGO"+CRLF

 SF2->(DBSETORDER(1))
 SC5->(DBSETORDER(1))

 For _nI := 1 to _nLinhas

     IF _cOrigem = "TELA"//n�o usa por enquanto

        _oModelGrid:GoLine( _nI )
        _cTipoOcorr :=_oModelGrid:GetValue("ZF5_TIPOO")
        _dZF5DTOCOR :=_oModelGrid:GetValue("ZF5_DTOCOR")
        _cZF5CODIGO :=_oModelGrid:GetValue("ZF5_CODIGO")
        _cPedido    :=ALLTRIM(_oModelMaster:GetValue('ZF5_PEDIDO'))
        _cEstonado  :=_oModelGrid:GetValue("ZF5_ESTONO")

     ELSEIF _lOriGravado

        ZF5->(DBGOTO(_aRecZF5[_nI]))
        _cTipoOcorr :=ZF5->ZF5_TIPOO
        _dZF5DTOCOR :=ZF5->ZF5_DTOCOR
        _cZF5CODIGO :=ZF5->ZF5_CODIGO
        _cPedido    :=ALLTRIM(ZF5->ZF5_PEDIDO)
        _cEstonado  :=ZF5->ZF5_ESTONO
     EndIf

     SF2->(DbSeek(_cZF5Filial+_cNotaFiscal+_cSerie))
     SC5->(DbSeek(_cZF5Filial+_cPedido))

     _dF2EMISSAO  := SF2->F2_EMISSAO
     _lTemOperador:= (!EMPTY(SF2->F2_I_REDP) .OR. !EMPTY(SF2->F2_I_OPER))
     _lPVAgendado := .T.// Retirado dia 09/04/25 - Alex / Vanderlei solicitou - (SC5->C5_I_AGEND == "M" .or. SC5->C5_I_AGEND == "A")
     _cDtTran     := Posicione("ZFC",1,xFilial("ZFC")+_cTipoOcorr,"ZFC_DTTRAN") // 1 = ZFC_FILIAL+ZFC_CODIGO
     _lTemData    := .F.
     _aRec_TA_TF  := {0,0}

     If _cEstonado = "S"//SE ESTORNADO N�O LE PARA O SF2
        LOOP
     EndIf

     If _cDtTran == "A"  .AND. (_dZF5DTOCOR >= _dF2EMISSAO .AND. _dZF5DTOCOR <= DATE())
        _dDtTipoA := _dZF5DTOCOR
        _cListaOco+= "'"+_cTipoOcorr+";["+_cDtTran+"];"+DTOC(_dZF5DTOCOR)+";'"+_cZF5CODIGO+CRLF
        _lTemData:=.F.//Para por ZF5_DTATUA="N" em todos os Tipos "A" e por "S" s� no FOR apos o final
        IF _cOrigem = "TELA"//n�o usa por enquanto
           _aRec_TA_TF[1]:=_oModelGrid:GetLine()
        Else
           _aRec_TA_TF[1]:=ZF5->(RECNO())
        ENDIF

     ElseIf _cDtTran == "B"  .AND. (EMPTY(_dDtTipoB) .AND. _dZF5DTOCOR >= _dF2EMISSAO .AND. _dZF5DTOCOR <= DATE() ) .AND. _lTemOperador
        _dDtTipoB := _dZF5DTOCOR
        _cListaOco+= "'"+_cTipoOcorr+";["+_cDtTran+"];"+DTOC(_dZF5DTOCOR)+";'"+_cZF5CODIGO+CRLF
        _lTemData:=.T.

     ElseIf _cDtTran == "C"  .AND. (EMPTY(_dDtTipoC) .AND. _dZF5DTOCOR >= _dF2EMISSAO .AND. _dZF5DTOCOR <= DATE() ) .AND. _lTemOperador
        _dDtTipoC := _dZF5DTOCOR
        _cListaOco+= "'"+_cTipoOcorr+";["+_cDtTran+"];"+DTOC(_dZF5DTOCOR)+";'"+_cZF5CODIGO+CRLF
        _lTemData:=.T.

     ElseIf _cDtTran = "D"  .AND. (EMPTY(_dDtTipoD) .AND. _dZF5DTOCOR >= _dF2EMISSAO .AND. _dZF5DTOCOR <= DATE() )
        _dDtTipoD := _dZF5DTOCOR
        _cListaOco+= "'"+_cTipoOcorr+";["+_cDtTran+"];"+DTOC(_dZF5DTOCOR)+";'"+_cZF5CODIGO+CRLF
        _lTemData:=.T.

     ElseIf _cDtTran = "E"  .AND. (EMPTY(_dDtTipoE) .AND. _dZF5DTOCOR >= _dF2EMISSAO .AND. _dZF5DTOCOR <= DATE() )
        _dDtTipoE   := _dZF5DTOCOR
        _cListaOco+= "'"+_cTipoOcorr+";["+_cDtTran+"];"+DTOC(_dZF5DTOCOR)+";'"+_cZF5CODIGO+CRLF
        _lTemData:=.T.

     ElseIf _cDtTran == "F"  .AND. _dZF5DTOCOR >= _dF2EMISSAO .AND. _lPVAgendado//Tipo F pode aceitar data maior que DATE()
        _dDtTipoF := _dZF5DTOCOR
        _cListaOco+= _cTipoOcorr+";["+_cDtTran+"];"+DTOC(_dZF5DTOCOR)+";'"+_cZF5CODIGO+CRLF
        _lTemData :=.F.//Para por ZF5_DTATUA="N" em todos os Tipos "F" e por "S" s� no FOR apos o final
        IF _cOrigem = "TELA"//n�o usa por enquanto
           _aRec_TA_TF[2]:=_oModelGrid:GetLine()
        Else
           _aRec_TA_TF[2]:=ZF5->(RECNO())
        ENDIF
     EndIf

      If _lGravaSF2 .AND. _cDtTran $ "A,B,C,D,E,F" 
        IF _cOrigem = "TELA"//n�o usa por enquanto
           _oModelGrid:SetValue("ZF5_DTATUA", If(_lTemData,"S","N") )
        Else
           ZF5->(RecLock("ZF5",.F.))
           ZF5->ZF5_DTATUA := If(_lTemData,"S","N")
           ZF5->(MsUnlock())
        EndIf
      EndIf

 Next _nI

 IF _lGravaSF2 
    For _nI := 1 to LEN(_aRec_TA_TF)
        If _aRec_TA_TF[_nI] > 0
          IF _cOrigem = "TELA"//n�o usa por enquanto
             _oModelGrid:GoLine(_aRec_TA_TF[_nI])
             _oModelGrid:SetValue("ZF5_DTATUA", "S" )
          Else
             ZF5->(DBGoTo(_aRec_TA_TF[_nI]))
             ZF5->(RecLock("ZF5",.F.))
             ZF5->ZF5_DTATUA := "S"
             ZF5->(MsUnlock())
          EndIf
        EndIf
    Next _nI
 EndIf

 If _lGravaSF2 .AND. _cOrigem = "AOMS003" .AND. (!Empty(Alltrim(_cStatusSit)) .OR.  !Empty(Alltrim(_cStatusEmi)) )

    _cQuery := "SELECT ZDS.R_E_C_N_O_ RECZDS "
    _cQuery += "FROM "+RetSqlName("ZDS") + " ZDS "
    _cQuery += "WHERE ZDS.D_E_L_E_T_ = ' ' "
    _cQuery += "AND ZDS_NFORIG LIKE '%"+_cNotaFiscal+" "+Rtrim(_cSerie)+"%' "
    _cQuery += "AND ZDS_FILIAL = '"+_cZF5Filial+"' "
    _cQuery := ChangeQuery(_cQuery)
    _cAliasZDS := GetNextAlias()

    MPSysOpenQuery( _cQuery , _cAliasZDS )

    (_cAliasZDS)->(DbGoTop())

    Do While  (_cAliasZDS)->(!EOF())
       ZDS->(Dbgoto((_cAliasZDS)->RECZDS))
       ZDS->(RecLock("ZDS",.F.))
       If !Empty(Alltrim(_cStatusSit))
          ZDS->ZDS_STUSIT := _cStatusSit
       EndIf
       If !Empty(Alltrim(_cStatusEmi))
          ZDS->ZDS_STUEMI := _cStatusEmi
       EndIf
       If !Empty(Alltrim(_cObsCom))
          ZDS->ZDS_OBSCOM := ZDS->ZDS_OBSCOM + CRLF + _cObsCom
       EndIf
       ZDS->(MsUnLock())
       (_cAliasZDS)->(Dbskip())
    EndDo
    (_cAliasZDS)->(DbCloseArea())
 EndIf

 IF EMPTY(_dDtTipoA)
    _dDtTipoA:= _dF2EMISSAO
 EndIf

 If !EMPTY(_dDtTipoA) .Or.;
    !EMPTY(_dDtTipoB) .OR.;
    !EMPTY(_dDtTipoC) .OR.;
    !EMPTY(_dDtTipoD) .OR.;
    !EMPTY(_dDtTipoE) .OR.;
    !EMPTY(_dDtTipoF)

    IF _cOrigem = "TELA"//n�o usa por enquanto
       _cZF5DOCOC  := _oModelMaster:GetValue("ZF5_DOCOC")
       _cZF5SEROC  := _oModelMaster:GetValue("ZF5_SEROC")
       _cZF5CLIENT := _oModelMaster:GetValue("ZF5_CLIENT")
       _cZF5LOJA   := _oModelMaster:GetValue("ZF5_LOJA")
       _cPedido    := ALLTRIM(_oModelMaster:GetValue('ZF5_PEDIDO'))
    ELSEIF _lOriGravado
       ZF5->(DBGOTO(_aRecZF5[_nLinhas]))
       _cZF5DOCOC  := ZF5->ZF5_DOCOC
       _cZF5SEROC  := ZF5->ZF5_SEROC
       _cZF5CLIENT := ZF5->ZF5_CLIENT
       _cZF5LOJA   := ZF5->ZF5_LOJA
       _cPedido    := ALLTRIM(ZF5->ZF5_PEDIDO)
    EndIf
    IF _cOrigem = "M460FIM_LER"
       _dDtLTipoA:=_dDtTipoA
       _dDtLTipoB:=_dDtTipoB
       _dDtLTipoC:=_dDtTipoC
       _dDtLTipoD:=_dDtTipoD
       _dDtLTipoE:=_dDtTipoE
       _dDtLTipoF:=_dDtTipoF
    ENDIF
    SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
    If SF2->(MsSeek(_cZF5Filial +  _cZF5DOCOC +  _cZF5SEROC + _cZF5CLIENT + _cZF5LOJA))

       SC5->(Dbsetorder(1))
       SC5->(DbSeek(_cZF5Filial+_cPedido))
       _cLOG:="F2_FILIAL          ;F2_DOC          ;F2_I_PEDID         ;C5_FILIAL          ;C5_NUM         ;C5_I_AGEND         ;C5_I_DTENT               ;F2_I_PENOL - A           ;F2_I_PENCL - A - C - F   ;F2_I_DCHOL - B           ;F2_I_DENOL - C           ;F2_I_DCHCL - D           ;F2_I_DENCL - E           ;F2_I_TT1TR                     ;F2_I_TT2TR                     ;C5_I_OPER          ;C5_TIPO         ;F2_I_REDP          ;F2_I_OPER"+CRLF
       _cLOG+="'"+SF2->F2_FILIAL+";'"+SF2->F2_DOC+";"+SF2->F2_I_PEDID+";'"+SC5->C5_FILIAL+";"+SC5->C5_NUM+";"+SC5->C5_I_AGEND+";"+DTOC(SC5->C5_I_DTENT)+";"+DTOC(SF2->F2_I_PENOL)+";"+DTOC(SF2->F2_I_PENCL)+";"+DTOC(SF2->F2_I_DCHOL)+";"+DTOC(SF2->F2_I_DENOL)+";"+DTOC(SF2->F2_I_DCHCL)+";"+DTOC(SF2->F2_I_DENCL)+";"+cValToChar(SF2->F2_I_TT1TR)+";"+cValToChar(SF2->F2_I_TT2TR)+";'"+SC5->C5_I_OPER+";"+SC5->C5_TIPO+";'"+SF2->F2_I_REDP+";'"+SF2->F2_I_OPER+CRLF

       SF2->(RecLock("SF2",.F.))

       //TIPO A ******************************************************************************************************************************************
       IF !EMPTY(_dDtTipoA)// PREVIS�O DE ENTREGA no operador log�stico
          _aDatas:=U_CalcTransiTime(_dDtTipoA)
          _dDataTTUCOP:=_aDatas[1]      // Data com Transit-time da Unidade de Carregamento at� o Operador Log�stico
          _dDataTTEOPC:=_aDatas[2]      // Data com Transit Time do Endere�o (do Operador Log�stico ou da Italac) at� o Cliente
          IF _lGravaSF2
             _cListaSF2+="A;SF2->F2_I_PENOL;"+DTOC(SF2->F2_I_PENOL)+";"
             IF !EMPTY(SF2->F2_I_REDP) .OR. !EMPTY(SF2->F2_I_OPER)
                SF2->F2_I_PENOL :=_dDataTTUCOP// PREVIS�O DE ENTREGA NO OPERADOR LOG�STICO ** SF2 **
             EndIf
             _cListaSF2+=DTOC(SF2->F2_I_PENOL)+";Data com TT da Unid. de Carreg. ate o Oper.:;"+DTOC(_dDataTTUCOP)+CRLF
             _cListaSF2+="A;SF2->F2_I_PENCL;"+DTOC(SF2->F2_I_PENCL)+";"
             IF SC5->C5_I_DTENT > _dDataTTEOPC  .AND. (SC5->C5_I_AGEND == "M" .or. SC5->C5_I_AGEND == "A")
                SF2->F2_I_PENCL := SC5->C5_I_DTENT // PREVIS�O DE ENTREGA NO CLIENTE ** SF2 **
             ELSE
                SF2->F2_I_PENCL := _dDataTTEOPC // PREVIS�O DE ENTREGA NO CLIENTE ** SF2 **
             EndIf
             _cListaSF2+=DTOC(SF2->F2_I_PENCL)+";Data com TT do Oper. ate o Cliente:;"+DTOC(_dDataTTEOPC)+CRLF
          ELSE// _cOrigem = "M460FIM_LER"
             _dTADtTTUCOP:=_dDataTTUCOP
             IF SC5->C5_I_DTENT > _dDataTTEOPC  .AND. (SC5->C5_I_AGEND == "M" .or. SC5->C5_I_AGEND == "A")
                _dTADtTTEOPC := SC5->C5_I_DTENT // PREVIS�O DE ENTREGA NO CLIENTE
             ELSE
                _dTADtTTEOPC := _dDataTTEOPC    // PREVIS�O DE ENTREGA NO CLIENTE
             EndIf
          ENDIF
       EndIf

       IF (!EMPTY(SF2->F2_I_REDP) .OR. !EMPTY(SF2->F2_I_OPER))
          //TIPO B ******************************************************************************************************************************************
          // Data de CHEGADA no operador log�stico

          IF _lGravaSF2
             //If !Empty(_dDtTipoB) //.AND. EMPTY(SF2->F2_I_DCHOL) // retirado pq a Ocorrencia anterior pode ser deletada
             _cListaSF2+="B;SF2->F2_I_DCHOL;"+DTOC(SF2->F2_I_DCHOL)+";"
               SF2->F2_I_DCHOL := _dDtTipoB // DATA DE CHEGADA NO OPERADOR LOG�STICO ** SF2 **
             _cListaSF2+=DTOC(SF2->F2_I_DCHOL)+CRLF

             //TIPO C ******************************************************************************************************************************************
             //DATA DE ENTREGA NO OPERADOR LOG�STICO  EDI
             //If .T. //!Empty(_dDtTipoC) //.AND. EMPTY(SF2->F2_I_DENOL)  // retirado pq a Ocorrencia anterior pode ser deletada
             _cListaSF2+="C;SF2->F2_I_DENOL;"+DTOC(SF2->F2_I_DENOL)+";"
             SF2->F2_I_DENOL := _dDtTipoC   // DATA DE ENTREGA NO OPERADOR LOG�STICO  EDI ** SF2 **
             _cListaSF2+=DTOC(SF2->F2_I_DENOL)+CRLF
          EndIF

           // PREVIS�O de entrega no cliente em cima do TIPO B e TIPO C se tiver preenchido 1 das 2
           _dDataTTEOPC:=_dDtTipoB
           IF _dDtTipoC > _dDtTipoB
              _dDataTTEOPC:=_dDtTipoC
           EndIf
           If !Empty(_dDataTTEOPC)
              _aDatas:=U_CalcTransiTime(,_dDataTTEOPC)
              _dDataTTEOPC    := _aDatas[2]   // Data com Transit Time do Endere�o do Operador Log�stico at� o Cliente
              IF _lGravaSF2
                 _cListaSF2+="C;SF2->F2_I_PENCL;"+DTOC(SF2->F2_I_PENCL)+";"
                   IF SC5->C5_I_DTENT > _dDataTTEOPC  .AND. (SC5->C5_I_AGEND == "M" .or. SC5->C5_I_AGEND == "A")
                      SF2->F2_I_PENCL := SC5->C5_I_DTENT // PREVIS�O DE ENTREGA NO CLIENTE ** SF2 **
                    ELSE
                      SF2->F2_I_PENCL := _dDataTTEOPC // PREVIS�O DE ENTREGA NO CLIENTE ** SF2 **
                    EndIf
                 _cListaSF2+=DTOC(SF2->F2_I_PENCL)+";Data com TT do Oper. ate o Cliente:;"+DTOC(_dDataTTEOPC)+CRLF
              Else// _cOrigem = "M460FIM_LER"
                 _dTCDtTTEOPC:=_dTBDtTTEOPC:=_dDataTTEOPC
                 IF SC5->C5_I_DTENT > _dDataTTEOPC  .AND. (SC5->C5_I_AGEND == "M" .or. SC5->C5_I_AGEND == "A")
                    _dTCDtTTEOPC:=_dTBDtTTEOPC:=SC5->C5_I_DTENT
                 EndIf
              EndIf
           EndIf

       EndIf

       //TIPO D ******************************************************************************************************************************************
       If _lGravaSF2//!Empty(_dDtTipoD) //.AND. EMPTY(SF2->F2_I_DCHCL) // retirado pq a Ocorrencia anterior pode ser deletada
          _cListaSF2+="D;SF2->F2_I_DCHCL;"+DTOC(SF2->F2_I_DCHCL)+";"
          SF2->F2_I_DCHCL := _dDtTipoD // Data de CHEGADA no cliente ** SF2 **
          _cListaSF2+=DTOC(SF2->F2_I_DCHCL)+CRLF
       EndIf

       //TIPO "E" ******************************************************************************************************************************************
       If _lGravaSF2//!Empty(_dDtTipoE) //.And. Empty(SF2->F2_I_DENCL)// retirado pq a Ocorrencia anterior pode ser deletada
          _cListaSF2+="E;SF2->F2_I_DENCL;"+DTOC(SF2->F2_I_DENCL)+";"
           SF2->F2_I_DENCL := _dDtTipoE // Data de ENTREGA no cliente ** SF2 **
          _cListaSF2+=DTOC(SF2->F2_I_DENCL)+CRLF
       EndIf

       //TIPO "F" ******************************************************************************************************************************************
       If !Empty(_dDtTipoF) .AND. _lGravaSF2// REAGENDAMENTRO DE ENTREGA
          _cListaSF2+="F;SF2->F2_I_PENCL;"+DTOC(SF2->F2_I_PENCL)+";"
          SF2->F2_I_PENCL := _dDtTipoF // PREVIS�O de entrega no cliente ** SF2 **
          _cListaSF2+=DTOC(SF2->F2_I_PENCL)+CRLF
       EndIf

       SF2->(MsUnLock())

       IF U_ITGETMV("IT_GLOGDTOC",.F.) .OR. LEFT(_cAmbiente,6) $ "HOMOLO/DESENV"
          _cLOG     := "AMBIENTE:;"+ALLTRIM(GETENVSERVER())+";Origem:;"+_cOrigem+CRLF+_cLOG
          _cLOG     += CRLF
          _cLOG     += _cListaOco+CRLF
          _cLOG     += _cListaSF2+CRLF
          _cFileNome:= "/data/logs_generico/aoms003_"+SF2->F2_FILIAL+"_"+ALLTRIM(SF2->F2_DOC)+"_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+".csv"

          MemoWrite(LOWER(_cFileNome),_cLOG)

       EndIf

       IF _lGravaSF2
          U_ReplDatasTransTime( SF2->(RECNO()) )
       EndIF

    EndIf
 EndIf

RETURN .T.


/*
===============================================================================================================================
Programa----------: AOMS03Leg
Autor-------------: Alex Wallauer
Data da Criacao---: 26/12/2024
Descri��o---------: Tratamentos da Legenda
Parametros--------: Se _lLegenda = .T. devolve a cor da legenda, sen�o exibe a legenda.
Retorno-----------: Cor da Legenda ou .T.
===============================================================================================================================*/
Static Function AOMS03Leg(_lLegenda)
 Local _cRetorno As Char
 Local _aLegenda As Array
 Local _oModel  As Object
 Local _oModelGrid As Object
 Local _nLine  As Numeric
 Local _cEstonado := "N" As Char
 Local _cStatus   As Char

 IF _lLegenda//GRAVA��O DO CAMPO LEGENDA
    _oModel    := FWModelActive()
    _oModelGrid:= _oModel:GetModel("ZF5DETAIL")
    _nLine     := _oModelGrid:GetLine()
    _cRetorno  := "BR_AMARELO"
    IF _nLine > 0 //VIA TELA
       _cEstonado :=_oModelGrid:GetValue("ZF5_ESTONO")
       _cStatus   :=_oModelGrid:GetValue("ZF5_APRREJ")
    Else// CARGA INICAL NA ALTERA��O
       _cEstonado := ZF5->ZF5_ESTONO
       _cStatus   := ZF5->ZF5_APRREJ
    ENDIF
    Do Case
       Case _cEstonado ='S'
           _cRetorno := "BR_PRETO"
       Case _cStatus ='A'
           _cRetorno := "BR_VERDE"
       Case _cStatus ='R'
           _cRetorno := "BR_VERMELHO"
    End Case
    Return _cRetorno// **** SAIDA ****
 Else//WHEN DO CAMPO LEGENDA
    _aLegenda := {}
    aAdd( _aLegenda, { "BR_VERDE"    ,      "Aprovada"  })
    aAdd( _aLegenda, { "BR_VERMELHO" ,      "Rejeitada" })
    aAdd( _aLegenda, { "BR_PRETO"    ,      "Estornada" })
    aAdd( _aLegenda, { "BR_AMARELO"  ,      "Pendente"  })
    BrwLegenda( "Status das ocorrecias", "Legenda", _aLegenda )
 Endif
Return .T.
