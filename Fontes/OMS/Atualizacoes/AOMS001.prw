/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer     | 09/10/2017 | Corre��o do erro de n�o existir acols - Chamado 21805
------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer     | 11/03/2019 | N�o validar o preenchimento das filais quando o codigo da opera��o for = "22". Chamado 28396
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges      | 14/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
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
Programa----------: AOMS001
Autor-------------: Xavier
Data da Criacao---: 30-03-2015
===============================================================================================================================
Descri��o---------: Fazer manuten��o na tabela de pre�os de transferencias de notas fiscais
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function AOMS001()
Local oBrowse
Local aArea := Z09->(GetArea())

U_ITLOGACS()//Grava log de utiliza��o da rotina

oBrowse := FWMBrowse():New()
oBrowse:SetAlias( 'Z09' )
oBrowse:SetFilterDefault( 'U_AOMS001C()' )
oBrowse:SetDescription( 'Tabela pre�o de transferencias' )
oBrowse:SetOnlyFields( { 'Z09_FILORI','Z09_FILDES','Z09_CODOPE' , 'Z09_DESOPE' , 'Z09_INIVIG' , 'Z09_FIMVIG' , 'Z09_DESVIO' } )
oBrowse:DisableDetails()

oBrowse:Activate()

RestArea(aArea)

Return .T.


/*
===============================================================================================================================
Programa----------: MENUDEF
Autor-------------: Xavier
Data da Criacao---: 30-03-2015
===============================================================================================================================
Descri��o---------: menu de op��es
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Vetor de op��es
===============================================================================================================================
*/

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.AOMS001' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.AOMS001' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.AOMS001' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.AOMS001' OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.AOMS001' OPERATION 9 ACCESS 0

Return aRotina

/*
===============================================================================================================================
Programa----------: MODELDEF
Autor-------------: Xavier
Data da Criacao---: 30-03-2015
===============================================================================================================================
Descri��o---------: Cria��o do modelo de dados
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Modelo dados
===============================================================================================================================
*/

Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruPAI := FWFormStruct( 1, 'Z09', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruFIL := FWFormStruct( 1, 'Z09', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel


//remover campos
oStruPAI:RemoveField( 'Z09_CODPRO' )
oStruPAI:RemoveField( 'Z09_DESPRO' )
oStruPAI:RemoveField( 'Z09_PRECO'  )
oStruPAI:RemoveField( 'Z09_FILORI' )
oStruPAI:RemoveField( 'Z09_FILDES' )
oStruFIL:RemoveField( 'Z09_CODOPE' )
oStruFIL:RemoveField( 'Z09_DESOPE' )
oStruFIL:RemoveField( 'Z09_INIVIG' )
oStruFIL:RemoveField( 'Z09_FIMVIG' )
oStruFIL:RemoveField( 'Z09_DESVIO' )


// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'MAOMS001' , /*bPreValidacao*/ , /*bPosValidacao*/ {|oMdl| MDPosVld(oMdl)}, /*bCommit*/ {|oMdl| MDGrv(oMdl)}, /*bCancel*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Tabela Preco de transferencias' )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields( 'Z09PAI', NIL, oStruPAI,/*bPre-Validacao*/ ,/*bPos-Validacao*/,/*bCarga*/ )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
oModel:AddGrid( 'Z09FIL', 'Z09PAI', oStruFIL , /*bLinePre*/, {|oMdl| AOMS001LV(oMdl)} , /*bPreVal*/ , /*bPosVal*/ , /*BLoad*/  )

//define a chave primaria
oModel:SetPrimaryKey( {"Z09_FILIAL", "Z09_CODOPE","Z09_INIVIG","Z09_FIMVIG"})

// Faz relaciomaneto entre os compomentes do model
_arelacao := {}

aadd(_arelacao, { 'Z09_FILIAL', 'xFilial( "Z09" ) ' })
aadd(_arelacao, { 'Z09_CODOPE', 'Z09_CODOPE' })
aadd(_arelacao, { 'Z09_INIVIG', 'Z09_INIVIG' })
aadd(_arelacao, { 'Z09_FIMVIG', 'Z09_FIMVIG' })
		
oModel:SetRelation( 'Z09FIL', _arelacao , Z09->( IndexKey( 4 ) ) )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'Z09FIL' ):SetUniqueLine( { 'Z09_CODPRO','Z09_FILORI','Z09_FILDES' } )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'Z09PAI' ):SetDescription( 'Dados da Operacao' )
oModel:GetModel( 'Z09FIL' ):SetDescription( 'Dados do Produto'  )

//define obrigatoriedade de linha digiada no grid
oModel:GetModel( 'Z09FIL' ):SetOptional( .F. )

//validacao da ativacao do modelo
oModel:SetVldActivate( { |oModel| AtivaModelo( oModel ) } )

Return oModel

/*
===============================================================================================================================
Programa----------: VIEWDEF
Autor-------------: Xavier
Data da Criacao---: 30-03-2015
===============================================================================================================================
Descri��o---------: Cria��o da vis�o dos dados
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Vis�o dos dados
===============================================================================================================================
*/
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oStruPAI := FWFormStruct( 2, 'Z09' )
Local oStruFIL := FWFormStruct( 2, 'Z09' )

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'AOMS001' )
Local oView

// remover campos
oStruPAI:RemoveField( 'Z09_CODPRO' )
oStruPAI:RemoveField( 'Z09_DESPRO' )
oStruPAI:RemoveField( 'Z09_PRECO'  )
oStruPAI:RemoveField( 'Z09_FILORI' )
oStruPAI:RemoveField( 'Z09_FILDES' )
oStruFIL:RemoveField( 'Z09_CODOPE' )
oStruFIL:RemoveField( 'Z09_DESOPE' )
oStruFIL:RemoveField( 'Z09_INIVIG' )
oStruFIL:RemoveField( 'Z09_FIMVIG' )
oStruFIL:RemoveField( 'Z09_DESVIO' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_PAI' , oStruPAI, 'Z09PAI'  )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_FIL' , oStruFIL, 'Z09FIL'  )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'BOXPAI'  , 24)
oView:CreateHorizontalBox( 'BOXFIL'  , 76)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_PAI' , 'BOXPAI'  )
oView:SetOwnerView( 'VIEW_FIL' , 'BOXFIL'  )

// Liga apresenta��o dos titulso dos componentes
oView:EnableTitleView( 'VIEW_PAI' )
oView:EnableTitleView( 'VIEW_FIL' )

//botao adicional
oView:AddUserButton( 'Importar Produtos', 'CLIPS', {|oView| ImportGrid(oView)},,,{MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} )
oView:AddUserButton( 'Pesquisar Produtos', 'CLIPS', {|oView| PesqProd(oView)} )

//fechamento da view
oView:SetCloseOnOk({|oModel| If(oModel:GetOperation()=MODEL_OPERATION_UPDATE,.T.,.F.)})

Return oView

/*
===============================================================================================================================
Programa----------: MDGRV
Autor-------------: Xavier
Data da Criacao---: 30-03-2015
===============================================================================================================================
Descri��o---------: Complemento de grava��o da modelo de dados
===============================================================================================================================
Parametros--------: objeto da modelo de dados
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MDGrv(oMdl)

Local oModelCab  := oMdl:GetModel( 'Z09PAI' )
Local nOperacao  := oMdl:GetOperation()
Local cOper      := oModelCab:GetValue("Z09_CODOPE")
Local aArea      := GetArea()

FwFormCommit(oMdl)

//alteracao
If nOperacao=MODEL_OPERATION_UPDATE
	
	dbselectarea("Z09")
	Z09->( dbsetorder(2) )
	Z09->(Dbseek(XFilial("Z09")+oModelCAB:GetValue("Z09_CODOPE")))
	
	While Z09->(!EOF()) .And. Z09->Z09_CODOPE == cOper
		
		RecLock("Z09",.F.)
		Z09->Z09_DESVIO := oModelCAB:GetValue("Z09_DESVIO")
		Z09->Z09_INIVIG := oModelCAB:GetValue("Z09_INIVIG")
		Z09->Z09_FIMVIG := oModelCAB:GetValue("Z09_FIMVIG")
		Z09->(MsUnLock())
		
		Z09->(DbSkip())
		
	EndDo
	
EndIf

RestArea(aArea)

Return .T.

/*
===============================================================================================================================
Programa----------: ImportGrid
Autor-------------: Xavier
Data da Criacao---: 30-03-2015
===============================================================================================================================
Descri��o---------: Importa��o dos dados para a modelo
===============================================================================================================================
Parametros--------: Objeto da vis�o de dados
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static function ImportGrid(oView)

Local oModel := FWModelActive()
Local oModelGrid := oModel:GetModel( 'Z09FIL' )
Local cAliasQry := GetNextAlias()
Local cTipo := 'PA'

//consultar banco de produtos
BeginSql Alias cAliasQry
	SELECT B1_COD, B1_DESC
	FROM %table:SB1%
	WHERE %NotDel%
	AND B1_FILIAL = %xfilial:SB1%
	AND	B1_TIPO = %Exp:cTipo%
	AND B1_MSBLQL <> '1'
	ORDER BY B1_COD
EndSql

(cAliasQry)->(DbGoTop())

//preenchimento do grid
While (cAliasQry)->(!EOF())
	
	If !oModelGrid:Seekline({ {"Z09_CODPRO",(cAliasQry)->B1_COD} },.F.)
		oModelGrid:AddLine()
		oModelGrid:SetValue( "Z09_CODPRO",(cAliasQry)->B1_COD )
	EndIf
	(cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

oModelGrid:GoLine(1)

Return .T.

/*
===============================================================================================================================
Programa----------: PesqProd
Autor-------------: Xavier
Data da Criacao---: 30-03-2015
===============================================================================================================================
Descri��o---------: Pesquisar produto na modelo de dados
===============================================================================================================================
Parametros--------: Objeto da vis�o de dados
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static function PesqProd(oView)

Local oModel := FWModelActive()
Local oModelGrid := oModel:GetModel( 'Z09FIL' )
Local oDlg , oButton1 , oGet1 , oSay1
Local cProd := Space(15)

DEFINE MSDIALOG oDlg TITLE "Pesquisar produto" FROM 000, 000  TO 100, 400 COLORS 0, 16777215 PIXEL
@ 017, 014 SAY oSay1 PROMPT "Codigo Produto:" SIZE 041, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 015, 055 MSGET oGet1 VAR cProd SIZE 097, 010 OF oDlg PICTURE "@!" COLORS 0, 16777215 F3 "Z09B1" PIXEL
DEFINE SBUTTON oButton1 FROM 030, 115 TYPE 01 OF oDlg ENABLE ACTION {|| oDlg:End()}
ACTIVATE MSDIALOG oDlg

//posicionar no grid
oModelGrid:Seekline({ {"Z09_CODPRO",cProd} },.F.)

Return .T.

/*
===============================================================================================================================
Programa----------: AtivaModelo
Autor-------------: Xavier
Data da Criacao---: 30-03-2015
===============================================================================================================================
Descri��o---------: Validar ativa��o do modelo
===============================================================================================================================
Parametros--------: Objeto da modelo de dados
===============================================================================================================================
Retorno-----------: Logico
===============================================================================================================================
*/
Static Function AtivaModelo(oModel)

Local aArea		:= GetArea()
Local lRet      := .T.

If !U_ITVLDUSR(8)
	U_ITMSG('O usu�rio '+UsrRetName( RetCodUsr() )+' n�o possui acesso para manuten��o dos pre�os de transfer�ncias.',,'Informar ao suporte T.I. para realizar essa manuten��o.',,,,.T.)
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet

/*
===============================================================================================================================
Programa----------: MDPosVld
Autor-------------: Xavier
Data da Criacao---: 30-03-2015
===============================================================================================================================
Descri��o---------: Valida��o da modelo de dados
===============================================================================================================================
Parametros--------: Objeto do modelo de dados
===============================================================================================================================
Retorno-----------: Logico
===============================================================================================================================
===============================================================================================================================
*/
Static Function MDPosVld(oMdl)

Local oModelGrid := oMdl:GetModel( 'Z09FIL' )
Local lRet := .T.
Local nx := 0
Local aArea	:= GetArea()

//validar pre�o
For nx := 1 To oModelGrid:Length()
	oModelGrid:GoLine(nx)
	If !oModelGrid:IsDeleted()
		If oModelGrid:GetValue('Z09_PRECO',nx) <= 0
			lRet := .F.
			U_ITMSG('Produto '+Alltrim(oModelGrid:GetValue("Z09_CODPRO",nx))+' com pre�o zerado.',,'Acerte o pre�o do produto para um valor maior que zero',,,,.T.)
		EndIf
	Endif
Next nx

RestArea(aArea)

Return lRet

/*
===============================================================================================================================
Programa----------: AOMS001A
Autor-------------: Xavier
Data da Criacao---: 30-03-2015
===============================================================================================================================
Descri��o---------: Valida��o do periodo de vigencia executada na valida��o do dicionario
===============================================================================================================================
Parametros--------: dIniData = Data inicio da vigencia
					dFimData = Data fim da vigencia
===============================================================================================================================
Retorno-----------: Logico
===============================================================================================================================
*/
User Function AOMS001A(dIniData,dFimData)

Local _lRet := .T.


If dFimData <= dIniData .And. !Empty(dFimData)

	_lRet := .F.
	U_ITMSG("Data final da vig�ncia deve ser maior que a data inicio da vig�ncia.",,,,,,.T.)

EndIf

Return _lRet 

/*
===============================================================================================================================
Programa----------: AOMS001H
Autor-------------: Josu� Danich
Data da Criacao---: 15/09/2015
===============================================================================================================================
Descri��o---------: Valida��o do c�digo de opera��o
===============================================================================================================================
Parametros--------: _cCodop = C�digo da opera��o
===============================================================================================================================
Retorno-----------: Logico
===============================================================================================================================
*/
User Function AOMS001H(_cCodop)

Local lRet := .T.
Local aArea	:= GetArea()
Local cQuery	:= ''
Local cAlias	:= GetNextAlias()

If (Inclui .or. Altera) 

	//valida opera��o  n�o pode sobrepor com nenhum registro j� existente
	cQuery += " SELECT Z09.Z09_CODOPE FROM "+ RETSQLNAME('Z09') +" Z09 WHERE "+ RETSQLCOND('Z09') 
	cQuery += " AND Z09.Z09_CODOPE = '"+ _cCodop +"'"

	IIf( Select(cAlias) > 0 , (cAlias)->( DBCloseArea() ) , Nil )

	DBUseArea( .T. , "TOPCONN" , TCGenQry( ,, cQuery ) , cAlias , .F. , .T. )
	DBSelectArea(cAlias)

	//se achou mesma opera��o  alerta e bloqueia o cadastro
	If .not. (cAlias)->( Eof() )
  	    U_ITMSG("Opera��o conflitante com registro j� existente",,,,,,.T.)
		lRet := .F.
	
	Endif

Endif

RestArea(aArea)

Return lRet

/*
===============================================================================================================================
Programa----------: AOMS001C
Autor-------------: Xavier
Data da Criacao---: 30-03-2015
===============================================================================================================================
Descri��o---------: Filtrar dados na tela principal
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Logico
===============================================================================================================================
*/
User Function AOMS001C()

Local aArea	:= GetArea()
Local cQuery	:= ''
Local cAlias	:= GetNextAlias()
Local lRet		:= .F.

cQuery += " SELECT Z09.R_E_C_N_O_ AS REGZ09 FROM "+ RETSQLNAME('Z09') +" Z09 WHERE "+ RETSQLCOND('Z09') 
cQuery += " AND Z09.Z09_CODOPE = '"+ Z09->Z09_CODOPE +"' AND Z09.Z09_INIVIG = '" + DTOS(Z09->Z09_INIVIG) + "'" 
cQuery += " AND Z09.Z09_FIMVIG = '" + DTOS(Z09->Z09_FIMVIG) + "' AND ROWNUM = 1 ORDER BY 1 "


IIf( Select(cAlias) > 0 , (cAlias)->( DBCloseArea() ) , Nil )

DBUseArea( .T. , "TOPCONN" , TCGenQry( ,, cQuery ) , cAlias , .F. , .T. )
DBSelectArea(cAlias)
(cAlias)->( DBGoTop() )

lRet := ( (cAlias)->REGZ09 == Z09->( Recno() ) )

(cAlias)->( DBCloseArea() )

RestArea(aArea)

Return lRet

/*
===============================================================================================================================
Programa----------: AOMS001LV
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 09/09/2015
===============================================================================================================================
Descri��o---------: Validar linha do grid
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Logico
===============================================================================================================================
*/
Static Function AOMS001LV(oMdl)

Local _lret := .T.
Local _oModel	:= FWModelActive()
Local oModelGrid:= _oModel:GetModel( 'Z09FIL' )
Local _cFilori := oModelGrid:GetValue("Z09_FILORI")//ALLTRIM(aCols[n][aScan(aHeader,{|x| UPPER(Alltrim(x[2])) == "Z09_FILORI"})])
Local _cFildes := oModelGrid:GetValue("Z09_FILDES")//ALLTRIM(aCols[n][aScan(aHeader,{|x| UPPER(Alltrim(x[2])) == "Z09_FILDES"})])

If Z09->Z09_CODOPE <> "22"
	If  .NOT.( EMPTY(_cFilori) .AND.  EMPTY(_cFildes)).AND. ;
	    .NOT.(!EMPTY(_cFilori) .AND. !EMPTY(_cFildes) .AND. ALLTRIM(_cFilori) <> ALLTRIM(_cFildes) ) 

       U_ITMSG("Campos de filial origem / destino devem ser diferentes ou vazios.",," Acertar Linha: "+ALLTRIM(STR(oModelGrid:NLINE)),,,,.T.)
	   _lret := .F.
	
	Endif

ELSEIf  Z09->Z09_CODOPE = "22"
	If EMPTY(_cFilori) .OR. EMPTY(_cFildes) .OR. ALLTRIM(_cFilori) <> ALLTRIM(_cFildes)

       U_ITMSG("Campos de filial origem / destino devem ser preenchidos e iguais.",," Acertar Linha: "+ALLTRIM(STR(oModelGrid:NLINE)),,,,.T.)
	   _lret := .F.
	
	Endif
Endif	
    

Return _lret