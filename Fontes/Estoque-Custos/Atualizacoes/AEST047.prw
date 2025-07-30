#INCLUDE "rwmake.ch"
/*
===============================================================================================================================
Programa----------: AEST047
Autor-------------: Alex Wallauer
Data da Criacao---: 25/09/2019 
===============================================================================================================================
Descrição---------: Criacao de Tela de Cadastro do Nivel 5   
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function AEST047()

Local cAlias		:= "ZA0"
Private cCadastro	:= ""
Private aRotina		:= {}                

AADD(aRotina,{"Pesquisar"	,"AxPesqui",0,1})
AADD(aRotina,{"Visualizar"	,"AxVisual",0,2})
AADD(aRotina,{"Incluir"		,"AxInclui",0,3})
AADD(aRotina,{"Alterar"		,"U_ValZA0",0,4})
AADD(aRotina,{"Excluir"		,"U_ValZA0",0,5})
	
cCadastro	:= "Cadastro de Nivel 5"
dbSelectArea(cAlias)
dbSetOrder(1)
mBrowse(6,1,22,75,cAlias)

Return Nil
/*
===============================================================================================================================
Programa----------: ValZA0
Autor-------------: Alex Wallauer
Data da Criacao---: 25/09/2019 
===============================================================================================================================
Descrição---------: Validacao da Alteracao e Exclusao
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc  
===============================================================================================================================
Retorno-----------: Retorno Logico (.T. ou .F.) para exclusao ou alteracao 
===============================================================================================================================
*/
User Function ValZA0(cAlias,nReg,nOpc)

Local lRet		:= .T. 
Local _cCod		:= ZA0->ZA0_COD
Local cQuery	:= 	""

cQuery := "SELECT COUNT(B.B1_I_NIV5) AS CONT"
cQuery += " FROM " + RetSqlName("SB1") + " B"
cQuery += " WHERE B.D_E_L_E_T_ = ' ' AND B.B1_I_NIV5 = '"+_cCod+"' "

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TEMP", .T., .F. )
dbSelectArea("TEMP")

If TEMP->CONT <> 0
	lRet	:= .F.
Endif
	
TEMP->(dbCloseArea())

If lRet .and. nOpc == 4
	AxAltera(cAlias,nReg,nOpc)
ElseIf lRet .and. nOpc == 5 
	AxDeleta(cAlias,nReg,nOpc)
Endif

Return lRet 