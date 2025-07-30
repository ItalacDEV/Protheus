/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Josu� Prestes | 10/06/2019 | Ajuste para loboguara - Chamado 29593
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#include "Protheus.ch"               
#include "TopConn.ch"

/*
===============================================================================================================================
Programa----------: ACFG001
Autor-------------: Lucas Crevilari
Data da Criacao---: 24/10/2014
===============================================================================================================================
Descri��o---------: Tela para amarrar Filial ao Centro de Custo
===============================================================================================================================
Parametros--------:
===============================================================================================================================
Retorno-----------:
===============================================================================================================================
*/
User Function ACFG001
      
Local oBrowse := Nil

oBrowse := FWMBrowse():New()
oBrowse:SetAlias( "ZLH" )
oBrowse:SetDescription( "Cadastro Filial X Centro de Custo" )
oBrowse:Activate()

Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Lucas Crevilari
Data da Criacao---: 24/10/2014
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

Return( FWMVCMenu("ACFG001") )

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Lucas Crevilari
Data da Criacao---: 24/10/2014
===============================================================================================================================
Descri��o---------: Rotina de defini��o do Modelo de Dados do MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: oModel - Objeto do modelo de dados do MVC
===============================================================================================================================
*/

Static Function ModelDef()

Local oStruZLH 	:= FWFormStruct( 1 , "ZLH" )
Local oModel	:= Nil

oModel := MPFormModel():New( "ACFG001M" ,  /*bPreValidacao*/ , /*bPosValidacao*/ , /*bCommit*/ , /*bCancel*/ )
oModel:SetDescription( "Filial X Centro de Custo" )

oModel:AddFields( "ZLHMASTER", /*cOwner*/ , oStruZLH , /*bPreValidacao*/ , /*bPosValidacao*/ , /*bCarga*/ )

oModel:GetModel( "ZLHMASTER" ):SetDescription( "Filial X Centro de Custo" )

Return( oModel )

/*
===============================================================================================================================
Programa----------: ViewDef
Autor-------------: Lucas Crevilari
Data da Criacao---: 24/10/2014
===============================================================================================================================
Descri��o---------: Rotina de defini��o da View do MVC
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: oView - Objeto de exibi��o do MVC
===============================================================================================================================
*/

Static Function ViewDef()

Local oModel   	:= FWLoadModel( "ACFG001" )
Local oStruZLH 	:= FWFormStruct( 2 , "ZLH" )
Local oView		:= Nil

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "VIEW_ZLH" , oStruZLH , "ZLHMASTER" )

Return(oView)

/*
===============================================================================================================================
Programa----------: ITCTT
Autor-------------: Lucas Crevilari
Data da Criacao---: 24/10/2014
===============================================================================================================================
Descri��o---------: Consulta espec�fica usada no cadastro na ZLH. 
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: .T. - Compatibilidade com a utiliza��o em F3
===============================================================================================================================
*/
User Function ITCTT()

Local nI			:= 0
Private nTam		:= 1       
Private nMaxSelect	:= 10
Private aResAux		:= {}
Private MvRet		:= Alltrim(ReadVar())
Private MvPar		:= ""
Private cTitulo		:= "Consulta Centro de Custo"
Private MvParDef	:= ""  

#IFDEF WINDOWS
	oWnd := GetWndDefault()
#ENDIF

DBSelectArea("CTT")
CTT->( DBSetOrder(1) )
If CTT->( DBSeek(xFilial("CTT")) )

	While CTT->(!Eof())
		If !(SUBSTR(CTT->CTT_CUSTO,1,1) $ MvParDef)
			MvParDef += PadR( CTT->CTT_CUSTO , nTam ) 
			aAdd( aResAux , "Centro de Custo iniciado em "+PadR( CTT->CTT_CUSTO , nTam ) )
		Endif		
		CTT->( DBSkip() )
	EndDo

	//===========================================================================
	//| Mant�m a marca��o anterior                                              |
	//===========================================================================
   	If Len( AllTrim(&MvRet) ) == 0
		MvPar	:= PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len(aResAux) )
		&MvRet	:= PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len(aResAux) )
	Else
		MvPar	:= AllTrim( StrTran( &MvRet , ";" , "" ) )
	EndIf
	
	//===========================================================================
	//| Monta a tela de Op��es gen�rica do Sistema                              |
	//===========================================================================
	f_Opcoes( @MvPar , cTitulo , aResAux , MvParDef , 12 , 49 , .F. , nTam , nMaxSelect )

	//===========================================================================
	//| Tratamento do retorno para separa��o por ";"                            |
	//===========================================================================
	&MvRet := ""

	If !Empty(MvPar)
	
		For	nI:= 1 to Len(MvPar) Step nTam
			If !( SubStr( MvPar , nI , 1 ) $ "|*" )
				&MvRet  += SubStr(MvPar,nI,nTam) + ";"
			EndIf
		Next
	
		//===========================================================================
		//| Retira separa��o do �ltimo registro                                     |
		//===========================================================================
		&MvRet := SubStr(&MvRet,1,Len(&MvRet)-1)
	
	EndIf
	
Else
	Alert("N�o foi encontrado registros na tabela CTT")
EndIf                
           
Return(.T.)

/*
===============================================================================================================================
Programa----------: CFGFil
Autor-------------: Lucas Crevilari
Data da Criacao---: 24/10/2014
===============================================================================================================================
Descri��o---------: Verifica se n�o est� incluindo filial duplicada na ZLH.
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: .T. - Permite inclus�o (Filial ainda n�o cadastrada)
===============================================================================================================================
*/

User Function CFGFil(_cFil)
Local lRet := .T.
Local aSaveArea := GetArea()

cQuery := " SELECT COUNT(ZLH.ZLH_FIL) AS CONT"
cQuery += " FROM " + RetSqlName("ZLH") + " ZLH"
cQuery += " WHERE ZLH.D_E_L_E_T_ = ' ' AND ZLH.ZLH_FIL = '" + _cFil + "'"

If Select("cQuery") > 0
	cQuery->( dbCloseArea() )
EndIf

DBUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "cQuery", .T., .F. )

DBSelectArea("cQuery")
If cQuery->(!Eof()) .And. cQuery->CONT <> 0
	lRet := .F.
Endif
cQuery->( dbCloseArea() )                                                     
        
RestArea(aSaveArea)

Return(lRet)

/*
===============================================================================================================================
Programa----------: CTTZLH
Autor-------------: Lucas Crevilari
Data da Criacao---: 24/10/2014
===============================================================================================================================
Descri��o---------: Filtro utilizado na Consulta padr�o CTTZLH
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------:
===============================================================================================================================
*/          

User Function CTTZLH()

Local lOk 		:= .T.
Local cFiltro	:= ""
Local cCustFil	:= ""  
Local cCcusto	:= ""
Local nQtdReg	:= 0
Local lPrim 	:= .T.
Local x			:= 0

dbSelectArea("ZLH")
dbSetOrder(1)
If dbSeek(xFilial("ZLH")+cFilAnt)
	cCcusto := ALLTRIM(ZLH->ZLH_CCUSTO)
	If !EMPTY(cCcusto)
		nQtdReg := Len(cCcusto)
	Else
		lOk := .F.
	Endif
	
	If lOk
		For x := 1 To nQtdReg
			If SUBSTR(cCcusto,x,1) <> ";"
				cCustFil := SUBSTR(cCcusto,x,1)
				If lPrim
					cFiltro += "SUBSTR(CTT->CTT_CUSTO,1,1) == '"+cCustFil+"'"
				Else
					cFiltro += " .OR. SUBSTR(CTT->CTT_CUSTO,1,1) == '"+cCustFil+"'"
				Endif
	            lPrim := .F.
			Endif
		Next x
	Endif    
Endif

Return(cFiltro)