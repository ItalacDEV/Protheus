/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 14/05/2018 | Incluidos tratamentos para o campo novo ZGH_NATURE - Chamado 23254
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 06/03/2018 | Incluidos tratamentos para o campo ZGH_NATURE na integração - Chamado 28358
-------------------------------------------------------------------------------------------------------------------------------
 Josué  Danich    | 26/06/2019 | Ajustes para loboguara - Chamado 28886      
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 16/12/2019 | Criação da Sub regra Amarração Bloco H - Chamado 31211. 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 26/02/2020 | Ajustes na validação do campo ZGH_TIPOPD e criação da integração - Chamado 32129
------------------------------------------------------------------------------------------------------------------------------
 Jonathan         | 28/09/2020 | Remoção de bugs apontados pelo Totvs CodeAnalysis. Chamado: 34262
------------------------------------------------------------------------------------------------------------------------------
Lucas Borges      | 24/07/2025 | Chamado 51340. Ajustar função para validação de ambiente de teste
===============================================================================================================================
*/

#Include 'FWMVCDEF.CH'

/*
===============================================================================================================================
Programa--------: AFIS008
Autor-----------: Josué Danich Prestes
Data da Criacao-: 06/11/2017
===============================================================================================================================
Descrição-------: Cadastro de regras do Sped 500 - Chamado 21797
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AFIS008()

Local oBrowse := Nil
oBrowse := FWMBrowse():New()

oBrowse:SetAlias("ZGH")
oBrowse:SetDescription("Cadastro de regras do SPED 500")
oBrowse:Activate()

Return(Nil)

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Josué Danich Prestes
Data da Criacao---: 06/11/2017
===============================================================================================================================
Descrição---------: Rotina para montagem do modelo de dados para o processamento
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ModelDef()
Local oStruZGH	:= FWFormStruct(1,"ZGH")
Local oModel	:= Nil

oModel := MpFormModel():New('AFIS008M')

oModel:AddFields("ZGHMASTER", , oStruZGH)

oModel:SetPrimaryKey( {'ZGH_FILIAL','ZGH_CLIENT',"ZGH_CLILOJ",'ZGH_FORNER',"ZGH_FORLOJ",'ZGH_GRUPO','ZGH_PRODUT',"ZGH_CFOP","ZGH_TPMOV" } )

Return(oModel)

/*
===============================================================================================================================
Programa----------: ViewDef
Autor-------------: Josué Danich Prestes
Data da Criacao---: 06/11/2017
===============================================================================================================================
Descrição---------: Rotina para montar a View de Dados para exibição
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ViewDef()
Local oModel	:= FWLoadModel('AFIS008')
Local oStruZGH	:= FWFormStruct(2,'ZGH')
Local oView		:= Nil

oView := FWFormView():New()

oStruZGH:AddGroup( 'GRUPO01' , 'NUMERO DA CONTA CONTABIL'   , '' , 2 )
oStruZGH:AddGroup( 'GRUPO02' , 'AMARRACAO COM O TITULO'     , '' , 2 )
oStruZGH:AddGroup( 'GRUPO03' , 'AMARRACAO COM A NOTA FISCAL', '' , 2 )
oStruZGH:AddGroup( 'GRUPO04' , 'AMARRACAO COM BLOCO M'      , '' , 2 )   
oStruZGH:AddGroup( 'GRUPO05' , 'AMARRACAO COM BLOCO H'      , '' , 2 )

oStruZGH:SetProperty( "ZGH_CONTA"	, MVC_VIEW_GROUP_NUMBER , 'GRUPO01' )

oStruZGH:SetProperty( "ZGH_NATURE"	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )
oStruZGH:SetProperty( "ZGH_NATDES"	, MVC_VIEW_GROUP_NUMBER , 'GRUPO02' )

oStruZGH:SetProperty( "ZGH_CLIENT"  , MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
oStruZGH:SetProperty( "ZGH_CLILOJ"  , MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
oStruZGH:SetProperty( "ZGH_DESCLI"  , MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
oStruZGH:SetProperty( "ZGH_FORNER"  , MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
oStruZGH:SetProperty( "ZGH_FORLOJ"  , MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
oStruZGH:SetProperty( "ZGH_DESFOR"  , MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
oStruZGH:SetProperty( "ZGH_PRODUT"  , MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
oStruZGH:SetProperty( "ZGH_DPROD"   , MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
oStruZGH:SetProperty( "ZGH_GRUPO"   , MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
oStruZGH:SetProperty( "ZGH_DGRUPO"  , MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
oStruZGH:SetProperty( "ZGH_CFOP"    , MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )
oStruZGH:SetProperty( "ZGH_TPMOV"   , MVC_VIEW_GROUP_NUMBER , 'GRUPO03' )

oStruZGH:SetProperty( "ZGH_IMPOST"  , MVC_VIEW_GROUP_NUMBER , 'GRUPO04' )
oStruZGH:SetProperty( "ZGH_ALIQ"    , MVC_VIEW_GROUP_NUMBER , 'GRUPO04' )

oStruZGH:SetProperty( "ZGH_TIPOPD"  , MVC_VIEW_GROUP_NUMBER , 'GRUPO05' )
                      
oView:SetModel(oModel)

oView:AddField('VIEW_ZGH',oStruZGH,"ZGHMASTER")

oView:CreateHorizontalBox( 'BOX001' , 100 )
oView:SetOwnerView( 'VIEW_ZGH' , 'BOX001' )

Return(oView)

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------:Josué Danich Prestes
Data da Criacao---: 06/11/2017
===============================================================================================================================
Descrição---------: Rotina para criação do menu da tela principal
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _aRotina - Array com as opções de menu
===============================================================================================================================
*/
Static Function MenuDef()
LOCAL _aRotina := {}

ADD OPTION _aRotina Title 'Visualizar'			Action 'VIEWDEF.AFIS008'	OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title 'Incluir'   			Action 'VIEWDEF.AFIS008'	OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Incluir Natureza'	Action 'VIEWDEF.AFIS008' 	OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Alterar'   			Action 'VIEWDEF.AFIS008'	OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title 'Excluir'				Action 'VIEWDEF.AFIS008'	OPERATION 5 ACCESS 0
ADD OPTION _aRotina Title 'Imprimir' 			Action 'VIEWDEF.AFIS008'	OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title 'Simulador'  			Action 'U_AFIS008Teste'	    OPERATION 2 ACCESS 0
//ADD OPTION _aRotina Title 'Importar'   			Action 'U_AFIS008Integ'	    OPERATION 2 ACCESS 0

Return(_aRotina)

/*
===============================================================================================================================
Programa----------: AFIS008M
Autor-------------: Josué Danich Prestes
Data da Criacao---: 06/11/2017
===============================================================================================================================
Descrição---------: Pontos de entrada da rotina
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _xret - lógico de retorno
===============================================================================================================================
*/
user function AFIS008M()
Local aParam     := PARAMIXB
Local oObj       := ''
Local cIdPonto   := ''
Local cIdModel   := ''
Local _xret 	 := .T.

oObj       := aParam[1]
cIdPonto   := aParam[2]
cIdModel   := aParam[3]

If cIdPonto == 'MODELPOS' .AND. (Inclui .OR. Altera)
	
    If EMPTY(M->ZGH_NATURE) .AND. EMPTY(M->ZGH_IMPOST) .AND. EMPTY(M->ZGH_ALIQ) .and. EMPTY(M->ZGH_TIPOPD)
		
		If ( !EMPTY(alltrim(oobj:GetValue("ZGHMASTER","ZGH_FORNER"))) .OR. !EMPTY(alltrim(oobj:GetValue("ZGHMASTER","ZGH_FORLOJ"))) ) .AND.;
			( !EMPTY(alltrim(oobj:GetValue("ZGHMASTER","ZGH_CLIENT"))) .OR. !EMPTY(alltrim(oobj:GetValue("ZGHMASTER","ZGH_CLILOJ"))) )
			
			Help( ,, 'Atenção',, 'Forncedor+Loja ou Clente+Loja não podem ser preenchidos ao mesmo tempo!', 1, 0 )
			_xret := .F.
			
		Endif
		
		If EMPTY(alltrim(oobj:GetValue("ZGHMASTER","ZGH_GRUPO"))) .AND. EMPTY(alltrim(oobj:GetValue("ZGHMASTER","ZGH_PRODUT")))
			Help( ,, 'Atenção',, 'Grupo ou produto precisam ser preenchidos!', 1, 0 )
			_xret := .F.
		Endif
		
		If !EMPTY(alltrim(oobj:GetValue("ZGHMASTER","ZGH_GRUPO"))) .AND. !EMPTY(alltrim(oobj:GetValue("ZGHMASTER","ZGH_PRODUT")))
			Help( ,, 'Atenção',, 'Grupo e produto não podem ser preenchidos ao mesmo tempo!', 1, 0 )
			_xret := .F.
		Endif
		
		If EMPTY(alltrim(oobj:GetValue("ZGHMASTER","ZGH_CFOP"))) .AND. EMPTY(ALLTRIM(oobj:GetValue("ZGHMASTER","ZGH_TPMOV")))
			Help( ,, 'Atenção',, 'Cfop ou tipo de movimento precisam ser preenchidos!', 1, 0 )
			_xret := .F.
		Endif
		
		If !EMPTY(alltrim(oobj:GetValue("ZGHMASTER","ZGH_CFOP"))) .AND. !EMPTY(alltrim(oobj:GetValue("ZGHMASTER","ZGH_TPMOV")))
			Help( ,, 'Atenção',, 'Cfop e tipo de movimento não podem ser preenchidos ao mesmo tempo!', 1, 0 )
			_xret := .F.
		Endif
		
		If  !EMPTY(alltrim(oobj:GetValue("ZGHMASTER","ZGH_FORNER"))) .AND. !EMPTY(ALLTRIM(oobj:GetValue("ZGHMASTER","ZGH_TPMOV"))) .AND. ALLTRIM(oobj:GetValue("ZGHMASTER","ZGH_TPMOV")) # 'E'
			Help( ,, 'Atenção',, 'Quando Forncedor e Tipo de Movimento preenchidos, Tipo de Movimento só pode ser Entrada', 1, 0 )
			_xret := .F.
		Endif
		If  !EMPTY(alltrim(oobj:GetValue("ZGHMASTER","ZGH_CLIENT"))) .AND. !EMPTY(ALLTRIM(oobj:GetValue("ZGHMASTER","ZGH_TPMOV"))) .AND. ALLTRIM(oobj:GetValue("ZGHMASTER","ZGH_TPMOV")) # 'S'
			Help( ,, 'Atenção',, 'Quando Cliente e Tipo de Movimento preenchidos, Tipo de Movimento só pode ser Saida', 1, 0 )
			_xret := .F.
		Endif
		
		If  !EMPTY(alltrim(oobj:GetValue("ZGHMASTER","ZGH_FORNER"))) .AND. !EMPTY(ALLTRIM(oobj:GetValue("ZGHMASTER","ZGH_CFOP"))) .AND. ALLTRIM(oobj:GetValue("ZGHMASTER","ZGH_CFOP")) >= "5000"
			Help( ,, 'Atenção',, 'Quando Forncedor e CFOP preenchidos, CFOP só pode menor que 5000', 1, 0 )
			_xret := .F.
		Endif
		If  !EMPTY(alltrim(oobj:GetValue("ZGHMASTER","ZGH_CLIENT"))) .AND. !EMPTY(ALLTRIM(oobj:GetValue("ZGHMASTER","ZGH_CFOP"))) .AND. ALLTRIM(oobj:GetValue("ZGHMASTER","ZGH_CFOP")) < "5000"
			Help( ,, 'Atenção',, 'Quando Cliente e CFOP preenchidos, CFOP só pode maior que 5000', 1, 0 )
			_xret := .F.
		Endif
		
		ZGH->(DBSETORDER(3))//ZGH_FILIAL+ZGH_CLIENT+ZGH_CLILOJ+ZGH_FORNER+ZGH_FORLOJ+ZGH_GRUPO+ZGH_PRODUT+ZGH_CFOP+ZGH_TPMOV
		If  Inclui .AND. ZGH->(DBSEEK(xFilial("ZGH")+ M->(ZGH_CLIENT+ZGH_CLILOJ+ZGH_FORNER+ZGH_FORLOJ+ZGH_GRUPO+ZGH_PRODUT+ZGH_CFOP+ZGH_TPMOV) )) .And. Empty(M->ZGH_TIPOPD)
			Help( ,, 'Atenção',, 'Chave Cliente + Fornecedor + Grupo + Produto + CFOP + Tp Movimento já cadastrados', 1, 0 )
			_xret := .F.
		Endif
		
	ELSEIf !EMPTY(M->ZGH_NATURE)
		
		ZGH->(DBSETORDER(4))//ZGH_FILIAL+ZGH_NATURE
		nSalvaRec:=ZGH->(RECNO())//Para alteração
		If  ZGH->(DBSEEK(xFilial("ZGH")+M->ZGH_NATURE )) .AND. (Inclui .OR. nSalvaRec <> ZGH->(RECNO()))
			Help( ,, 'Atenção',, 'Natureza já foi cadastrada para outra conta: '+ZGH->ZGH_CONTA, 1, 0 )
			_xret := .F.
		Endif
		ZGH->(DBGOTO(nSalvaRec))

	ELSEIf !Empty(M->ZGH_TIPOPD)
		
		ZGH->(DbSetOrder(6))
		nSalvaRec:=ZGH->(RECNO())//Para alteração
		If ZGH->(DbSeek(xFilial("ZGH")+M->ZGH_TIPOPD)) .AND. (Inclui .OR. nSalvaRec <> ZGH->(RECNO()))
			Help( ,, 'Atenção',, 'O TIPO DE PRODUTO já foi cadastrada para outra conta: '+ZGH->ZGH_CONTA, 1, 0 )
			_xret := .F.
		EndIf
		ZGH->(DBGOTO(nSalvaRec))
		
	ELSEIf !EMPTY(M->ZGH_IMPOST) .OR. !EMPTY(M->ZGH_ALIQ)
		
		ZGH->(DBSETORDER(5))//ZGH_FILIAL+ZGH_IMPOST+ZGH_ALIQ
		nSalvaRec:=ZGH->(RECNO())//Para alteração
		If EMPTY(M->ZGH_IMPOST) .OR. EMPTY(M->ZGH_ALIQ)
			Help( ,, 'Atenção',, 'O imposto e a aliquota devem ser informados juntos', 1, 0 )
			_xret := .F.
		ELSEIf ZGH->(DBSEEK(xFilial("ZGH")+M->ZGH_IMPOST+STR(M->ZGH_ALIQ,7,4))) .AND. (Inclui .OR. nSalvaRec <> ZGH->(RECNO()))
			Help( ,, 'Atenção',, 'Imposto + aliquota já cadastrados', 1, 0 )
			_xret := .F.
		Endif
		ZGH->(DBGOTO(nSalvaRec))

	ENDIF
	
	
Endif

Return _xret

/*
===============================================================================================================================
Programa----------: AFIS008Teste()
Autor-------------: Alex Wallauer
Data da Criacao---: 08/12/2017
===============================================================================================================================
Descrição---------: opcao de teste da rotina
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER FUNCTION AFIS008Teste()
LOCAL aFixos:={}

aRotina:={}
AADD( aRotina,	{ "Visualizar" ,"AxVisual"		, 0 , 2})
AADD( aRotina,	{ "Buscar"     ,"U_AFIS008Busca()"	, 0 , 4})
cCadastro:="Itens da NF do SPEE 500"

AADD(aFixos,{AVSX3("FT_CLIEFOR" ,5),"FT_CLIEFOR"                                              })
AADD(aFixos,{AVSX3("FT_LOJA"    ,5),"FT_LOJA"                                                 })
AADD(aFixos,{AVSX3("FT_CLIENT"  ,5),"FT_CLIENT"                                               })
AADD(aFixos,{AVSX3("FT_LOJENT"  ,5),"FT_LOJENT"                                               })
AADD(aFixos,{AVSX3("FT_PRODUTO" ,5),"FT_PRODUTO"                                              })
AADD(aFixos,{AVSX3("B1_GRUPO"   ,5),{|| E_Field2(SFT->FT_PRODUTO,"SB1",1,"B1_GRUPO") }})
AADD(aFixos,{AVSX3("FT_TIPOMOV" ,5),"FT_TIPOMOV"                                              })
AADD(aFixos,{AVSX3("FT_CFOP"    ,5),"FT_CFOP"                                                 })

mBrowse(,,,,"SFT",aFixos)

RETURN .T.

/*
===============================================================================================================================
Programa----------: AFIS008Busca()
Autor-------------: Alex Wallauer
Data da Criacao---: 08/12/2017
===============================================================================================================================
Descrição---------: opcao de teste da rotina
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
USER FUNCTION AFIS008Busca()
LOCAL cConta
PRIVATE _nRecZGH:=0//Usada dentro do PE SPDPIS07

cConta:=ExecBlock("SPDPIS07", .F., .F.,{;
            SFT->FT_FILIAL,;
			SFT->FT_TIPOMOV,;
			SFT->FT_SERIE,;
			SFT->FT_NFISCAL,;
			SFT->FT_CLIEFOR,;
			SFT->FT_LOJA,;
			SFT->FT_ITEM,;
			SFT->FT_PRODUTO})


IF _nRecZGH # 0
   ZGH->(DBGOTO( _nRecZGH ) )
   cCadastro:="Registro da conta encontrado: "+cConta
   AxVisual( "ZGH", _nRecZGH , 2 )
ELSE
   U_ITMSG("Registro da conta NÃO encontrado","Atenção",,3)
ENDIF

RETURN .T.

/*
===============================================================================================================================
Programa----------: AFIS008Val()
Autor-------------: Alex Wallauer
Data da Criacao---: 08/12/2017
===============================================================================================================================
Descrição---------: Chamado dos valid user dos campos - X3_VLDUSER - Mesmo coisa que o gatilho
===============================================================================================================================
Parametros--------: _cCampo: descrição simpres do campo que chamou
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================*/
USER FUNCTION AFIS008Val(_cCampo)
Local _oModel:=FWModelActive(),V
Local _aCpo:={"ZGH_FORNER","ZGH_FORLOJ","ZGH_DESFOR","ZGH_CLIENT","ZGH_CLILOJ","ZGH_DESCLI","ZGH_GRUPO","ZGH_DGRUPO",;
              "ZGH_PRODUT","ZGH_DPROD","ZGH_CFOP","ZGH_TPMOV","ZGH_NATURE","ZGH_NATDES","ZGH_TIPOPD"}

FOR V := 1 TO LEN(_aCpo)
    _cCpo:=_aCpo[V]
    _xVal:=&("M->"+_cCpo)
    _oModel:GETVALUE( "ZGHMASTER" , _cCpo  )
NEXT

DO CASE

   CASE _cCampo = "NAT"
	    If !EMPTY(M->ZGH_NATURE) 
           SED->(DBSETORDER(1))
	       If !SED->(DBSEEK(xFilial()+M->ZGH_NATURE ))
		      Help( ,, 'Atenção',, "Codigo da Natureza NÃO cadastrada", 1, 0 )
              RETURN .F.
           ENDIF
	       M->ZGH_NATDES:=POSICIONE("SED",1,XFILIAL("SED")+M->ZGH_NATURE,"ED_DESCRIC")
	       M->ZGH_TIPOPD := Space(2)  
	    ELSE
	       M->ZGH_NATDES:=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_NATDES")))
	    ENDIF                    

   CASE _cCampo = "FOR"
	    If !EMPTY(M->ZGH_FORNER) 
           SA2->(DBSETORDER(1))
	       If !SA2->(DBSEEK(xFilial("SA2")+M->ZGH_FORNER+ALLTRIM(M->ZGH_FORLOJ ) ))
		      Help( ,, 'Atenção',, "Codigo do Fornecedor NÃO cadastrado", 1, 0 )
            RETURN .F.
           ENDIF
	       M->ZGH_DESFOR:=POSICIONE("SA2",1,XFILIAL("SA2")+M->ZGH_FORNER+ALLTRIM(M->ZGH_FORLOJ),"A2_NREDUZ")
	       M->ZGH_CLIENT:=SPACE(LEN(ZGH->ZGH_CLIENT))
           M->ZGH_CLILOJ:=SPACE(LEN(ZGH->ZGH_CLILOJ))
           M->ZGH_DESCLI:=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_DESCLI")))
           M->ZGH_TIPOPD := Space(2)  
	    ELSE
	       M->ZGH_FORLOJ:=SPACE(LEN(ZGH->ZGH_FORLOJ))
           M->ZGH_DESFOR:=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_DESFOR")))
	    ENDIF

   CASE _cCampo = "CLI"
	    If !EMPTY(M->ZGH_CLIENT) 
           SA1->(DBSETORDER(1))
	       If !SA1->(DBSEEK(xFilial("SA1")+M->ZGH_CLIENT+ALLTRIM(M->ZGH_CLILOJ) ))
		      Help( ,, 'Atenção',, "Codigo do Cliente NÃO cadastrado", 1, 0 )
            RETURN .F.
           ENDIF
	       M->ZGH_DESCLI:=POSICIONE("SA1",1,XFILIAL("SA1")+M->ZGH_CLIENT+ALLTRIM(M->ZGH_CLILOJ),"A1_NREDUZ")
	       M->ZGH_FORNER:=SPACE(LEN(ZGH->ZGH_FORNER))
           M->ZGH_FORLOJ:=SPACE(LEN(ZGH->ZGH_FORLOJ))
           M->ZGH_DESFOR:=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_DESFOR")))      
           M->ZGH_TIPOPD := Space(2)  
	    ELSE
	       M->ZGH_CLILOJ:=SPACE(LEN(ZGH->ZGH_CLILOJ))
           M->ZGH_DESCLI:=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_DESCLI")))
	    ENDIF

   CASE _cCampo = "GRU"
	    If !EMPTY(M->ZGH_GRUPO) 
	       M->ZGH_DGRUPO:=POSICIONE('SBM',1,XFILIAL('SBM')+M->ZGH_GRUPO,"BM_DESC")
	       M->ZGH_PRODUT:=SPACE(LEN(ZGH->ZGH_PRODUT))
           M->ZGH_DPROD :=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_DPROD")))
           M->ZGH_TIPOPD := Space(2)  
           
	    ELSE
           M->ZGH_DGRUPO:=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_DGRUPO")))
	    ENDIF

   CASE _cCampo = "PROD"
	    If !EMPTY(M->ZGH_PRODUT) 
	       M->ZGH_DPROD :=POSICIONE('SB1',1,XFILIAL('SB1')+M->ZGH_PRODUT,"B1_DESC")
	       M->ZGH_GRUPO :=SPACE(LEN(ZGH->ZGH_GRUPO))
           M->ZGH_DGRUPO:=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_DGRUPO")))   
           M->ZGH_TIPOPD := Space(2)  
	    ELSE
           M->ZGH_DPROD :=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_DPROD")))
	    ENDIF

   CASE _cCampo = "CFOP"
	    If !EMPTY(M->ZGH_CFOP) 
	       M->ZGH_TPMOV :=SPACE(LEN(ZGH->ZGH_TPMOV))
	       M->ZGH_TIPOPD := Space(2)  
	    ENDIF

   CASE _cCampo = "TPMOV"
	    If !EMPTY(M->ZGH_TPMOV) 
	       M->ZGH_CFOP :=SPACE(LEN(ZGH->ZGH_CFOP))  
	       M->ZGH_TIPOPD := Space(2)  
	    ENDIF
   
ENDCASE

IF  _cCampo = "ALQ"
	M->ZGH_CLIENT:=SPACE(LEN(ZGH->ZGH_CLIENT))
	M->ZGH_CLILOJ:=SPACE(LEN(ZGH->ZGH_CLILOJ))
	M->ZGH_DESCLI:=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_DESCLI")))
	M->ZGH_FORNER:=SPACE(LEN(ZGH->ZGH_FORNER))
	M->ZGH_FORLOJ:=SPACE(LEN(ZGH->ZGH_FORLOJ))
	M->ZGH_DESFOR:=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_DESFOR")))
	M->ZGH_PRODUT:=SPACE(LEN(ZGH->ZGH_PRODUT))
	M->ZGH_DPROD :=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_DPROD")))
	M->ZGH_GRUPO :=SPACE(LEN(ZGH->ZGH_GRUPO))
	M->ZGH_DGRUPO:=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_DGRUPO")))
	M->ZGH_TPMOV :=SPACE(LEN(ZGH->ZGH_TPMOV))
	M->ZGH_CFOP  :=SPACE(LEN(ZGH->ZGH_CFOP))
	M->ZGH_NATURE:=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_NATURE")))
	M->ZGH_NATDES:=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_NATDES")))
    M->ZGH_TIPOPD:= Space(2)  
ELSEIF  _cCampo = "NAT"
	M->ZGH_CLIENT:=SPACE(LEN(ZGH->ZGH_CLIENT))
	M->ZGH_CLILOJ:=SPACE(LEN(ZGH->ZGH_CLILOJ))
	M->ZGH_DESCLI:=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_DESCLI")))
	M->ZGH_FORNER:=SPACE(LEN(ZGH->ZGH_FORNER))
	M->ZGH_FORLOJ:=SPACE(LEN(ZGH->ZGH_FORLOJ))
	M->ZGH_DESFOR:=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_DESFOR")))
	M->ZGH_PRODUT:=SPACE(LEN(ZGH->ZGH_PRODUT))
	M->ZGH_DPROD :=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_DPROD")))
	M->ZGH_GRUPO :=SPACE(LEN(ZGH->ZGH_GRUPO))
	M->ZGH_DGRUPO:=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_DGRUPO")))
	M->ZGH_TPMOV :=SPACE(LEN(ZGH->ZGH_TPMOV))
	M->ZGH_CFOP  :=SPACE(LEN(ZGH->ZGH_CFOP))
    M->ZGH_IMPOST:=" "
    M->ZGH_ALIQ  :=0
    M->ZGH_TIPOPD := Space(2)  
ElseIf _cCampo = "TIPOPRD" 
	If ! Empty(M->ZGH_TIPOPD)           	   
	   M->ZGH_CLIENT := SPACE(LEN(ZGH->ZGH_CLIENT))
	   M->ZGH_CLILOJ := SPACE(LEN(ZGH->ZGH_CLILOJ))
	   M->ZGH_DESCLI := SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_DESCLI")))
	   M->ZGH_FORNER := SPACE(LEN(ZGH->ZGH_FORNER))
	   M->ZGH_FORLOJ := SPACE(LEN(ZGH->ZGH_FORLOJ))
	   M->ZGH_DESFOR := SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_DESFOR")))
	   M->ZGH_PRODUT := SPACE(LEN(ZGH->ZGH_PRODUT))
	   M->ZGH_DPROD  := SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_DPROD")))
	   M->ZGH_GRUPO  := SPACE(LEN(ZGH->ZGH_GRUPO))
	   M->ZGH_DGRUPO := SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_DGRUPO")))
	   M->ZGH_TPMOV  := SPACE(LEN(ZGH->ZGH_TPMOV))
	   M->ZGH_CFOP   := SPACE(LEN(ZGH->ZGH_CFOP))
	   M->ZGH_NATURE := SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_NATURE")))
	   M->ZGH_NATDES := SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_NATDES")))
    EndIf 
ELSE
	M->ZGH_NATURE:=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_NATURE")))
	M->ZGH_NATDES:=SPACE(LEN(_OMODEL:GETVALUE("ZGHMASTER","ZGH_NATDES")))
    M->ZGH_IMPOST:=" "
    M->ZGH_ALIQ  :=0
    M->ZGH_TIPOPD := Space(2)  
ENDIF

FOR V := 1 TO LEN(_aCpo)
    _cCpo:=_aCpo[V]
    _xVal:=&("M->"+_cCpo)
    _nTam:=AVSX3(_cCpo,3)//X3_TAMANHO
    _oModel:LoadValue( "ZGHMASTER" , _cCpo , LEFT(_xVal,_nTam) )
NEXT

RETURN .T.
/*
===============================================================================================================================
Programa----------: AFIS008Integ()
Autor-------------: Alex Wallauer
Data da Criacao---: 26/12/2017
===============================================================================================================================
Descrição---------: Integra arquivo CSV 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER FUNCTION AFIS008Integ()
LOCAL aSemSX3  :={} , nI
PRIVATE _cFileCSV:="",cNomArq:=""
PRIVATE cAliasWK := GetNextAlias()

PRIVATE _aCols:={}

_cTimeIni:=TIME()

//_cFileCSV := cGetFile( "Documento Texto |*.CSV" ,"Selecione o CSV para apendar e validar",0,"C:\LIXO\AFIS008\",.T.,GETF_LOCALHARD)
_aParAux:={}
_aParRet:={}
MV_PAR81= Space(150)
aAdd( _aParAux , { 1 , "Selecione arquivo .CSV:"		,MV_PAR81, "@!"		, ""	, "DIR"		, "" , 100 , .F. } ) 
For nI := 1 To Len( _aParAux )
	aAdd( _aParRet , _aParAux[nI][03] )
Next
cTitle:="Selecione o CSV para apendar e validar"
//        aParametros,cTitle  ,aRet     ,bOk ,aButtons,lCentered,nPosX,nPosY,oDlgWizard,cLoad,lCanSave,lUserSave
IF !ParamBox( _aParAux ,cTitle,@_aParRet,    ,        ,         ,     ,     ,          ,     ,.T.     ,.T. )
	Return .T.
EndIf
_cFileCSV :=MV_PAR01

If !EMPTY(_cFileCSV)
	
	If !File(_cFileCSV)
		U_ITMSG("Arquivo "+_cFileCSV+" NÃO encontrado","Atenção",,3)
		RETURN .F.
	ENDIF
	
	_cTimeIni:=TIME()
	
	aCampos:={}
	//Layout do CSV SEGUIR A ORDEM ABAIXO
	AADD(aSemSX3,{"ZGH_FILIAL","C",LEN(ZGH->ZGH_FILIAL),0})
	AADD(aSemSX3,{"ZGH_CONTA", "C",LEN(ZGH->ZGH_CONTA ),0})
	AADD(aSemSX3,{"ZGH_CLIENT","C",LEN(ZGH->ZGH_CLIENT),0})
	AADD(aSemSX3,{"ZGH_CLILOJ","C",LEN(ZGH->ZGH_CLILOJ),0})
	AADD(aSemSX3,{"ZGH_FORNER","C",LEN(ZGH->ZGH_FORNER),0})
	AADD(aSemSX3,{"ZGH_FORLOJ","C",LEN(ZGH->ZGH_FORLOJ),0})
	AADD(aSemSX3,{"ZGH_PRODUT","C",LEN(ZGH->ZGH_PRODUT),0})
	AADD(aSemSX3,{"ZGH_GRUPO", "C",LEN(ZGH->ZGH_GRUPO ),0})
	AADD(aSemSX3,{"ZGH_CFOP",  "C",LEN(ZGH->ZGH_CFOP  ),0})
	AADD(aSemSX3,{"ZGH_TPMOV", "C",LEN(ZGH->ZGH_TPMOV ),0})
	AADD(aSemSX3,{"ZGH_NATURE","C",LEN(ZGH->ZGH_NATURE),0})
	AADD(aSemSX3,{"ZGH_TIPOPD","C",LEN(ZGH->ZGH_TIPOPD),0})
	AADD(aSemSX3,{"WK_MARCA"  ,"L",001,0})
	AADD(aSemSX3,{"WK_MSG"    ,"C",100,0})
	
	
	_oTemp:= FWTemporaryTable():New(cAliasWK,aSemSX3)
	_oTemp:AddIndex("1", {"ZGH_FILIAL","ZGH_CONTA"})
	_oTemp:Create()
	cNomArq:=_oTemp:GetRealName()
	
ELSEIF SuperGetMV("IT_AMBTEST",.F.,.T.)

ELSE
    RETURN .F.//********************************* SAI FORA
ENDIF

nPosChave:=15//POSICAO DA CHAVE COMPLETA

_nRepet:=0
_cTot  :=""
lRet:=.T.
FWMSGRUN( ,{|oproc| lRet:=AFIS008Ler(oproc) } ,"Aguarde... Processando: "+cNomArq )
IF !lRet
   (cAliasWK)->(dbCloseArea())
   RETURN .F.
ENDIF
_cTitAux:='REGRAS SPEED 500 - HrI: '+_cTimeIni+" / HrF: "+TIME()+" / Total: "+_cTot+" / Repetidos: "+STRZERO(_nRepet,7)+" / Arq.: "+cNomArq

DO WHILE LEN(_aCols) > 0

   _AHEADER:={" ",'FILIAL','CONTA','COD. CLIENTE','LOJA','COD, FORN','LOJA','PRODUTO','GRUPO','CFOP','TIPO','NATUREZA','TP PRODRO','OBSERVACAO',"CHAVE"}
   _ASIZES :={ 10,      30,     40,            40,    30,         40,    30,      50,      40,    40,    30,        50,        30 ,         200,    100}

   nPosResu:=nPosChave-1//POSICAO DA MENSAGEM
   aBotoes:={}                                           
   AADD( aBotoes , { "" , {|| FWMSGRUN(,{ |oProc| AFIS008GRV(oproc,.T.) }, "","") },"","ANALISE dos dados"} )
   AADD( aBotoes , { "" , {|| AVISO("ATENCAO",oLbxAux:aArray[oLbxAux:nAt][ nPosResu ],{"Fechar"},3) }	, "" , "Ver Resultado"		  } )
//    ITListBox(_cTitAux       , _aHeader, _aCols, _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons )
	_LOK:=U_ITLISTBOX( _cTitAux,_AHEADER , _aCols, .T.      , 4      ,          ,          ,_ASIZES  ,         ,     ,        , aBotoes )
	IF _LOK
		IF U_ITMSG("Confirma a GRAVACAO dos dados?",'Atenção!',,3,2,2)
           FWMSGRUN( ,{|oproc| AFIS008GRV(oproc,.F.) } ,"Aguarde", "Gravando..." )
		ELSE
		   LOOP
		ENDIF
	ENDIF
	EXIT
ENDDO

IF LEN(_aCols) = 0

	_aParAux:={}
	_aParRet:={}
	MV_PAR91:="1-GRAVACAO DOS DADOS"
	
	AADD( _aParAux , {2,"Escolah uma Opção:",MV_PAR91, {"1-GRAVACAO DOS DADOS",;
	                                                    "2-ANALISE DOS DADOS"},100,".T.",.T.,".T."})
	
	For nI := 1 To Len( _aParAux )
		aAdd( _aParRet , _aParAux[nI][03] )
	Next nI
	
	
	DO WHILE .T.		
		//        aParametros ,cTitle                 ,aRet      ,bOk                     ,aButtons,lCentered,nPosX,nPosY,oDlgWizard,cLoad,lCanSave,lUserSave
		IF ParamBox( _aParAux , "Selecione uma Opcao" , @_aParRet, {|| !EMPTY(MV_PAR01) } ,        , .T.     ,     ,     ,          ,     , .F.    , .F. )
			
			
			IF MV_PAR01 = "1"
				FWMSGRUN( ,{|oproc| AFIS008GRV(oproc,.F.) } ,"Aguarde", "Gravando..." )
				EXIT
			ELSE
				FWMSGRUN( ,{|oproc| AFIS008GRV(oproc,.T.) } ,"Analisando...", "Analisando..." )
				LOOP
			ENDIF
			
		ENDIF

		EXIT

	ENDDO
	
ENDIF

(cAliasWK)->(dbCloseArea())  
IF TYPE("_otemp") = "O"
   _oTemp:Delete()
ENDIF   

RETURN .T.


/*
===============================================================================================================================
Programa----------: AFIS008Ler()
Autor-------------: Alex Wallauer
Data da Criacao---: 27/12/2017
===============================================================================================================================
Descrição---------: Ler e valida arquivo CSV 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC FUNCTION AFIS008Ler(oproc)
LOCAL _cTimeIni:=TIME()

IF !EMPTY(_cFileCSV)
   oproc:cCaption := "Apendando, Aguarde... Hora Inicial :"+_cTimeIni+" / Arq.: "+cNomArq
   ProcessMessages()
   IF !AFIS008Ape(oProc)
      RETURN .F.
   ENDIF
ENDIF

ZGH->(DBSETORDER(3))//ZGH_FILIAL+ZGH_CLIENT+ZGH_CLILOJ+ZGH_FORNER+ZGH_FORLOJ+ZGH_GRUPO+ZGH_PRODUT+ZGH_CFOP+ZGH_TPMOV
_nConta:=(cAliasWK)->(LASTREC())
_cTot:=ALLTRIM(STR(_nConta))

oproc:cCaption := "Processando, Aguarde... Hora Inicial :"+_cTimeIni+" / Arq.: "+cNomArq
ProcessMessages()

//cQuery := "SELECT ZGH_FILIAL,ZGH_CLIENT,ZGH_CLILOJ,ZGH_FORNER,ZGH_FORLOJ,ZGH_GRUPO,ZGH_PRODUT,ZGH_CFOP,ZGH_TPMOV,ZGH_CONTA,ZGH.R_E_C_N_O_ ZGH_REC "
cQuery := "SELECT ZGH.R_E_C_N_O_ ZGH_REC "
cQuery += " FROM "+cNomArq+" ZGH "
cQuery += " WHERE ZGH.D_E_L_E_T_ = ' ' AND ZGH_FILIAL||ZGH_CLIENT||ZGH_CLILOJ||ZGH_FORNER||ZGH_FORLOJ||ZGH_GRUPO||ZGH_PRODUT||ZGH_CFOP||ZGH_TPMOV||ZGH_NATURE||ZGH_TIPOPD IN "
cQuery += "                      (SELECT  (ZGH_FILIAL||ZGH_CLIENT||ZGH_CLILOJ||ZGH_FORNER||ZGH_FORLOJ||ZGH_GRUPO||ZGH_PRODUT||ZGH_CFOP||ZGH_TPMOV||ZGH_NATURE||ZGH_TIPOPD) "
cQuery += "                                FROM "+cNomArq+" ZGH2 WHERE ZGH2.D_E_L_E_T_ = ' ' "
cQuery += "                                GROUP BY (ZGH_FILIAL||ZGH_CLIENT||ZGH_CLILOJ||ZGH_FORNER||ZGH_FORLOJ||ZGH_GRUPO||ZGH_PRODUT||ZGH_CFOP||ZGH_TPMOV||ZGH_NATURE||ZGH_TIPOPD) having COUNT(*) > 1 ) "
cQuery += " ORDER BY ZGH_FILIAL,ZGH_CLIENT,ZGH_CLILOJ,ZGH_FORNER,ZGH_FORLOJ,ZGH_GRUPO,ZGH_PRODUT,ZGH_CFOP,ZGH_TPMOV,ZGH_NATURE,ZGH_TIPOPD,ZGH_CONTA "

cAliasAux:="ZHG_QRY"
If select(cAliasAux) > 0
   (cAliasAux)->(DbCloseArea())
EndIf
		
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasAux, .F., .T.)

COUNT TO _nConta

IF _nConta = 0
	U_ITMSG("Não foi encontrado resgistros com Chave repetida.","ANALISE DE CHAVES DUPLICADAS",,2)
	RETURN .T.
ENDIF

_cTot2:=ALLTRIM(STR(_nConta))

_nConta:=0
_nRepet:=0
_aCols:={}
DBSELECTAREA( cAliasWK )

(cAliasAux)->(DbGotop())
DO While (cAliasAux)->(!Eof())

    (cAliasWK)->(DbGoto( (cAliasAux)->ZGH_REC ))
    _nConta++
    oproc:cCaption := "HI: "+_cTimeIni+" - Validando Regra: "+STRZERO(_nConta,7)+" / "+_cTot2+" - "+STRZERO(_nRepet,7)+" / Arq.: "+cNomArq
    ProcessMessages()

   IF (_nPos2:=ASCAN(_aCols,{|C|C[nPosChave]==(cAliasWK)->(ZGH_FILIAL+;
                                                           ZGH_CLIENT+;
                                                           ZGH_CLILOJ+;
                                                           ZGH_FORNER+;
                                                           ZGH_FORLOJ+;
                                                           ZGH_GRUPO+;
                                                           ZGH_PRODUT+;
                                                           ZGH_CFOP+;
                                                           ZGH_TPMOV+;
                                                           ZGH_NATURE+;
                                                           ZGH_TIPOPD)})) # 0
   
       _nRepet+=2
        
        _aCols[_nPos2,1]:=.F.
        IF (cAliasWK)->ZGH_CONTA # _aCols[_nPos2,3] //_aDupli[_nPos,2] 
           //Atualiza _aCols Anterior
           _aCols[_nPos2,nPosChave-1]:="[Chave repetida] [Com Conta diferente ("+ALLTRIM((cAliasWK)->ZGH_CONTA)+")] "
           //Atualiza _aCols Atual
           _cMsg:="[Chave repetida] [Com Conta diferente ("+_aCols[_nPos2,3]+")] "//_aDupli[_nPos,2]
        ELSE
           //Atualiza _aCols Anterior
           _aCols[_nPos2,nPosChave-1]:="[Chave repetida 1] "
           //Atualiza _aCols Atual
           _cMsg:="[Chave repetida 2] "
        ENDIF
        _nRecWKSalva:=(cAliasWK)->(RECNO())
        //Atualiza cAliasWK Anterior
        (cAliasWK)->(DBGOTO(_aCols[_nPos2,nPosChave+1]))
        (cAliasWK)->WK_MARCA:=.F.
        (cAliasWK)->WK_MSG  :=_aCols[_nPos2,nPosChave-1]
         //Atualiza cAliasWK Atual
        (cAliasWK)->(DBGOTO(_nRecWKSalva))
        (cAliasWK)->WK_MARCA:=.F.
        (cAliasWK)->WK_MSG  :=_cMsg

   ELSE

      (cAliasWK)->WK_MARCA:=.T.
      _cMsg:=""

   ENDIF

   AADD(_aCols,{(cAliasWK)->WK_MARCA,; //01
                ZGH_FILIAL,;           //02
                (cAliasWK)->ZGH_CONTA,;//03
                ZGH_CLIENT,;           //04
                ZGH_CLILOJ,;           //05
                ZGH_FORNER,;           //06
                ZGH_FORLOJ,;           //07
                ZGH_PRODUT,;           //08
                ZGH_GRUPO,;            //09
                ZGH_CFOP,;             //10
                ZGH_TPMOV,;            //11
                ZGH_NATURE,;           //12
                ZGH_TIPOPD,;           //13
                _cMsg,;                //14
                (cAliasWK)->(ZGH_FILIAL+ZGH_CLIENT+ZGH_CLILOJ+ZGH_FORNER+ZGH_FORLOJ+ZGH_GRUPO+ZGH_PRODUT+ZGH_CFOP+ZGH_TPMOV+ZGH_NATURE+ZGH_TIPOPD),;//15 - chave completa
                (cAliasWK)->(RECNO()) })//16
  
  (cAliasAux)->(DbSkip())

EndDo

_cTitAux:='REGRAS SPEED 500 - HrI: '+_cTimeIni+" / HrF: "+TIME()+" / Total: "+_cTot+" / Repetidos: "+STRZERO(_nRepet,7)+" / Arq.: "+cNomArq

IF LEN(_aCols) # 0 .AND. SuperGetMV("IT_AMBTEST",.F.,.T.)
   oproc:cCaption := _cTitAux
   _AHEADER:={" ",'FILIAL','CONTA','COD. CLIENTE','LOJA','COD, FORN','LOJA','PRODUTO','GRUPO','CFOP','TIPO','NATUREZA','TP PROD','OBSERVACAO',"CHAVE"}
   DlgToExcel( { { "ARRAY" , _cTitAux , _aHeader , _aCols } } )//já gera pq caso que pode cair
ENDIF

If select(cAliasAux) > 0
   (cAliasAux)->(DbCloseArea())
EndIf

RETURN .T.

/*
===============================================================================================================================
Programa----------: AFIS008Ape
Autor-------------: Alex Wallauer
Data da Criacao---: 27/02/2020
===============================================================================================================================
Descrição---------: Processamento de Importação de DADOS DO TYT
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function AFIS008Ape(oProc)

oProc:cCaption := ("Lendo dados de devoluções...")
ProcessMessages()
  
   
_cArq := ALLTRIM(_cFileCSV)
IF UPPER(RIGHT(_cArq,3)) <> "CSV" .OR. FT_FUSE(_cArq) == -1
	U_ITMSG("Não foi possível abrir o arquivo informado.",;
	"Arquivo inválido","O arquivo informado deve ser .CSV ou verificar se o arquivo informado esta correto.",1)
	RETURN .F.
ENDIF


FT_FGOTOP() //POSICIONA NO TOPO DO ARQUIVO
_cDados := FT_FREADLN()
	
If ! "FILIAL;CONT CONTABI;COD. CLIENTE;LOJ CLIENTE;COD. FORNECE;LOJ FORNCEDO;PRODUTO;GRUPO;CFOP;TIPO MOVIMEN;COD. NATUREZ;TIPO PROD." $ UPPER(ALLTRIM(_cDados))
	U_ITMSG("Arquivo informado com o cabeçalho incorreto.",;
            "Arquivo inválido","O arquivo deve conter o cabeçalho: Filial;Cont Contabi;Cod. Cliente;Loj Cliente;Cod. Fornece;Loj Forncedo;Produto;Grupo;CFOP;Tipo Movimen;Cod. Naturez;Tipo Prod.",1)
	RETURN .F.
ENDIF
	
_cTot:=FT_FLASTREC()-1
_cTot:=ALLTRIM(STR(_cTot))
_nTam:=LEN(_cTot)
_nCont:=_nConta:=0

_aLinRepetido={}
SB1->(DBSETORDER(1))
DA1->(DBSETORDER(1))
SA1->(DBSETORDER(1))

FT_FGOTOP() //POSICIONA NO TOPO DO ARQUIVO
FT_FSKIP()//PULA OS TITULOS
 	
DO WHILE !FT_FEOF()  //FACA ENQUANTO NAO FOR FIM DE ARQUIVO
 	
	_nCont++
	oProc:cCaption := ("Processando Dados: "+ STRZERO(_nCont,_nTam) +" de "+ _cTot)
	ProcessMessages()
	
	_cDados := ALLTRIM(FT_FREADLN())
	_cDados := STRTRAN(_cDados,'"','')//Tem que ter ate 6 colunas
	_cDados := STRTRAN(_cDados,',','.')//Campos com decimais
	
	//Verifica se é final de arquivo
	IF EMPTY(ALLTRIM(_cDados)) .OR. ALLTRIM(_cDados) = ';;;;;;;;;;;;;' 
		EXIT
	ENDIF

    IF ASCAN(_aLinRepetido,_cDados) = 0
        AADD(_aLinRepetido,_cDados)    
    ELSE
       FT_FSKIP()
       LOOP
    ENDIF
  	
	_aLinhas:= StrTokArr2(_cDados,";",.T.)

	IF EMPTY(VAL(_aLinhas[01])) 
       FT_FSKIP()
       LOOP
	ENDIF
	
    IF(LEN(_aLinhas) > 00,(cAliasWK)->(DBAPPEND())              ,)
	IF(LEN(_aLinhas) > 00,(cAliasWK)->ZGH_FILIAL := STRZERO(VAL(_aLinhas[01]),2),)
	IF(LEN(_aLinhas) > 01,(cAliasWK)->ZGH_CONTA  := _aLinhas[02],)
	IF(LEN(_aLinhas) > 02,(cAliasWK)->ZGH_CLIENT := _aLinhas[03],)
	IF(LEN(_aLinhas) > 03,(cAliasWK)->ZGH_CLILOJ := _aLinhas[04],)
	IF(LEN(_aLinhas) > 04,(cAliasWK)->ZGH_FORNER := _aLinhas[05],)
	IF(LEN(_aLinhas) > 05,(cAliasWK)->ZGH_FORLOJ := _aLinhas[06],)
	IF(LEN(_aLinhas) > 06,(cAliasWK)->ZGH_PRODUT := _aLinhas[07],)
	IF(LEN(_aLinhas) > 07,(cAliasWK)->ZGH_GRUPO  := _aLinhas[08],)
	IF(LEN(_aLinhas) > 08,(cAliasWK)->ZGH_CFOP   := _aLinhas[09],)
	IF(LEN(_aLinhas) > 09,(cAliasWK)->ZGH_TPMOV  := _aLinhas[10],)
	IF(LEN(_aLinhas) > 10,(cAliasWK)->ZGH_NATURE := _aLinhas[11],)
	IF(LEN(_aLinhas) > 11,(cAliasWK)->ZGH_TIPOPD := _aLinhas[12],)

    FT_FSKIP()

ENDDO

FT_FUSE()

RETURN .T.
	

/*
===============================================================================================================================
Programa----------: AFIS008Grv()
Autor-------------: Alex Wallauer
Data da Criacao---: 27/12/2017
===============================================================================================================================
Descrição---------: Grava os dados lidos do CSV
===============================================================================================================================
Parametros--------: oproc,_lAnalizar
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC FUNCTION AFIS008Grv(oproc,_lAnalizar)
LOCAL _nConta:=_nCont2:=0//,_nQbg:=250
LOCAL _cTimeIni:=TIME()
_aCols:={}

_nConta:=(cAliasWK)->(LASTREC())
_cTot:=ALLTRIM(STR(_nConta))
_nConta:=0
_nRepet:=0
oproc:cCaption := "Gravando, Aguarde... Hora Inicial :"+_cTimeIni
ProcessMessages()
ZGH->(DBSETORDER(3))//ZGH_FILIAL+ZGH_CLIENT+ZGH_CLILOJ+ZGH_FORNER+ZGH_FORLOJ+ZGH_GRUPO+ZGH_PRODUT+ZGH_CFOP+ZGH_TPMOV
DBSELECTAREA( cAliasWK )
(cAliasWK)->(DBGOTOP())
DO While (cAliasWK)->(!Eof())
    _nConta++
    oproc:cCaption := "HI: "+_cTimeIni+" - Gravando Regra: "+STRZERO(_nConta,6)+" / "+_cTot+" - "+STRZERO(_nRepet,7)//+" / Arq.: "+cNomArq
    ProcessMessages()
  
   IF !EMPTY((cAliasWK)->WK_MSG) //.OR. !(cAliasWK)->WK_MARCA 
      _nRepet++
      AADD(_aCols,{(cAliasWK)->WK_MARCA,ZGH_FILIAL,ZGH_CONTA,ZGH_CLIENT,ZGH_CLILOJ,ZGH_FORNER,ZGH_FORLOJ,ZGH_PRODUT,ZGH_GRUPO,ZGH_CFOP,ZGH_TPMOV,ZGH_TIPOPD,;
                   (cAliasWK)->WK_MSG,"IGNORADO" })
      (cAliasWK)->(DbSkip())
      LOOP
   ENDIF
   _lGrava:=.F.
   If !EMPTY((cAliasWK)->ZGH_NATURE) 
      ZGH->(DBSETORDER(4))//ZGH_FILIAL+ZGH_NATURE
	  If !ZGH->(DBSEEK(xFilial("ZGH")+(cAliasWK)->ZGH_NATURE ))
         _lGrava:=.T.
      ENDIF
   ELSEIf !EMPTY((cAliasWK)->ZGH_TIPOPD) 
      ZGH->(DBSETORDER(6))//ZGH_FILIAL+ZGH_TIPOPD
      IF !ZGH->(DBSEEK((cAliasWK)->(ZGH_FILIAL+ZGH_TIPOPD)))
         _lGrava:=.T.
      ENDIF
   ELSE
      ZGH->(DBSETORDER(3))//ZGH_FILIAL+ZGH_CLIENT+ZGH_CLILOJ+ZGH_FORNER+ZGH_FORLOJ+ZGH_GRUPO+ZGH_PRODUT+ZGH_CFOP+ZGH_TPMOV
      IF !ZGH->(DBSEEK((cAliasWK)->(ZGH_FILIAL+ZGH_CLIENT+ZGH_CLILOJ+ZGH_FORNER+ZGH_FORLOJ+ZGH_GRUPO+ZGH_PRODUT+ZGH_CFOP+ZGH_TPMOV)))
         _lGrava:=.T.
      ENDIF
   ENDIF

   IF _lGrava
      _nCont2++
      IF !_lAnalizar
         ZGH->(RECLOCK("ZGH",.T.))
         AVREPLACE(cAliasWK,"ZGH")
         ZGH->ZGH_FILIAL:=(cAliasWK)->ZGH_FILIAL
         ZGH->(MSUNLOCK())
         _cMsg:="[Cadastrado com sucesso]"
      ELSE
         _cMsg:="[Regra OK]"
      ENDIF   

      AADD(_aCols,{.T.,ZGH_FILIAL,ZGH_CONTA,ZGH_CLIENT,ZGH_CLILOJ,ZGH_FORNER,ZGH_FORLOJ,ZGH_PRODUT,ZGH_GRUPO,ZGH_CFOP,ZGH_TPMOV,ZGH_NATURE,ZGH_TIPOPD,;
                   _cMsg,(cAliasWK)->WK_MSG})
   ELSE
      _nRepet++
      _cMsg:="[Já cadastrado no sistema] "+IF( (cAliasWK)->ZGH_CONTA # ZGH->ZGH_CONTA,"[Com Conta diferente ("+ZGH->ZGH_CONTA+")] "," ") 
      AADD(_aCols,{.F.,ZGH_FILIAL,ZGH_CONTA,ZGH_CLIENT,ZGH_CLILOJ,ZGH_FORNER,ZGH_FORLOJ,ZGH_PRODUT,ZGH_GRUPO,ZGH_CFOP,ZGH_TPMOV,ZGH_NATURE,ZGH_TIPOPD,;
                   _cMsg,(cAliasWK)->WK_MSG})
   ENDIF

   (cAliasWK)->(DbSkip())

EndDo

IF LEN(_aCols) > 0

   IF _lAnalizar
      _cTitAux:='INTEGRAÇÃO DE REGRAS SPEED 500 - HrI: '+_cTimeIni+" / HrF: "+TIME()+" / Foram analizados "+_cTot+" / já cadastros: "+STRZERO(_nRepet,7)+" / Arq.: "+cNomArq
   ELSE  
      _cTitAux:='INTEGRAÇÃO DE REGRAS SPEED 500 - HrI: '+_cTimeIni+" / HrF: "+TIME()+" / Foram gravadas "+ALLTRIM(STR(_nCont2))+" de "+_cTot+" / já cadastros: "+STRZERO(_nRepet,7)+" / Arq.: "+cNomArq
   ENDIF  
   _AHEADER:={" ",'FILIAL','CONTA','COD. CLIENTE','LOJA','COD, FORN','LOJA','PRODUTO','GRUPO','CFOP','TIPO','NATUREZA','TP PROD','OBSERVACAO1','OBSERVACAO2'}
   _ASIZES :={ 10,      30,     40,            40,    30,         40,    30,      50,      40,    40,    30,        50,       30,         200,          100}
// DlgToExcel( { { "ARRAY" , _cTitAux , _aHeader , _aCols } } )//já gera pq caso que pode cair
   
   //ITLISTBOX( _CTITAUX,_AHEADER , _ACOLS,_LMAXSIZ,_NTIPO,_CMSGTOP , _LSELUNC , _ASIZES , _NCAMPO , BOK , BCANCEL )
   U_ITLISTBOX( _cTitAux,_AHEADER , _aCols, .T.    , 4    ,         ,          ,_ASIZES  , )

ELSE

   IF !_lAnalizar
      U_ITMSG("Foram gravadas "+ALLTRIM(STR(_nCont2))+" de "+_cTot+" Regras. HrI: "+_cTimeIni+" / HrF: "+TIME()+" / Arq.: "+cNomArq,'Atenção!',,2)
   ELSE   
      U_ITMSG("TUDO OK",'Atenção!',,2)
   ENDIF

ENDIF

RETURN .T.
