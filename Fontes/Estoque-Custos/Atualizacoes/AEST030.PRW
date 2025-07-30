/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Xavier           | 20-04-2015 | chamado 9869 retirada da tela personalizada de escolha da filial, causando não conformidade  	
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 04/12/2015 | Revisão e normatização de fonte - Chamado 13081
-------------------------------------------------------------------------------------------------------------------------------|
 Josué Danich     | 10/06/2019 | Revisão para loboguara - Chamado 29593
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "TOPCONN.ch"

/*
===============================================================================================================================
Programa----------: AEST030
Autor-------------: Erich Buttner
Data da Criacao---: 06/08/2013
===============================================================================================================================
Descrição---------: Cadastro de Grupo de Tipos de Custo  - CHAMADO 3953  
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AEST030()


Local _ncont := 0

Private 	cCadastro 	:= "Grupos de Custo Gerencial"
Private 	aRotina   	:= {}
Private 	aTitulos  	:= {}
Private 	cArquivo 	:= ""
Private 	aCores    	:= {}
Private 	aLegenda 	:= {{"BR_VERMELHO","Bloqueado"}, {"BR_VERDE", "Ativo"}} 
Public 	aNmRet 	:= {}
Public 	cFlRet 	:= ""
Public 	aFlRet 	:= {}
Public 	cFlRet1	:= ""

Aadd(aRotina,{"Pesquisar" 	,"AxPesqui"   	,0,1 })
Aadd(aRotina,{"Visualizar"	,"AxVisual"    	,0,2 })
Aadd(aRotina,{"Incluir"		,"AxInclui"		,0,3 })
Aadd(aRotina,{"Alterar"		,"AxAltera"    	,0,4 })
Aadd(aRotina,{"Excluir"		,"AxDeleta"    	,0,5 })
Aadd(aRotina,{"Legenda"		,"BrwLegenda('Status dos grupos','Legenda',aLegenda)"  		,0,6 })

AADD(aCores,{"ZL5_MSBLQL == '2'" ,"BR_VERDE" })   
AADD(aCores,{"ZL5_MSBLQL <> '2'" ,"BR_VERMELHO" })    

DbSelectArea("ZL5")
DbSetOrder(2)

_aCpos:={"ZL5_TPCUST","ZL5_DTPCUS","ZL5_CODGRP","ZL5_DESGRP"}
_aCampos:={}

_astruct := ZL5->(Dbstruct())

For _nCont:=1 to Len(_aCpos)

	_np := ascan(_astruct,{|pos| alltrim(pos[1]) == alltrim(_acpos[_ncont])})

	If _np > 0 

		AADD(aTitulos,{Getsx3cache(_astruct[_np][1],"X3_TITULO"),;
						_astruct[_np][1],;
						_astruct[_np][2],;
						_astruct[_np][3],;
						_astruct[_np][4],;
						Getsx3cache(_astruct[_np][1],"X3_PICTURE")})

	EndIf

Next _nCont

DbSelectArea("ZL5")
DbSetOrder(2)
ZL5->(DbGoTop())

mBrowse( 6, 1,22,75,"ZL5"  ,aTitulos,,,, ,aCores)

ZL6->(DbCloseArea())


Return(.T.)

/*
===============================================================================================================================
Programa----------: AEST030G
Autor-------------: Josué Danich
Data da Criacao---: 04/12/2015
===============================================================================================================================
Descrição---------: Rotina para retornar próximo código de evento para campo ZL5->CODGRP
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _ccod - próximo valor para ZL5->CODGRP
===============================================================================================================================
*/
User Function AEST030G()

Local _ccod 	:= "000001"
Local _cquery := ""
Local _aarea	:= getarea()

_cquery	:= " SELECT " 
_cquery  	+= 	" MAX(ZL5_CODGRP) AS CODI" 
_cquery  	+= 	" FROM " + RetSqlName("ZL5") + " ZL5 "
_cquery  	+= 	" WHERE ZL5_FILIAL = '" + xFilial("ZL5") + "'"
_cquery  	+= 	" AND   ZL5_TPCUST  = '" + alltrim(M->ZL5_TPCUST) + "'"
_cquery 	+= 	" AND   ZL5.D_E_L_E_T_ 	= ' '	"

TcQuery _cquery New Alias ZL5T
	
DBSelectArea("ZL5T")

If .not. ZL5T->( Eof() )

	_ccod := strzero( ( val( ZL5T->CODI) + 1 ),6 )

Endif

If Select("ZL5T") > 0 

	ZL5T->( DBCloseArea() )

EndIf

restarea(_aarea)

RETURN _ccod

