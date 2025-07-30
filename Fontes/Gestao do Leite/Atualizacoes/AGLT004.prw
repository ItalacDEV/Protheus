/*  
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 15/08/2019 | Modificada valida��o para dele��o de registros. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 27/09/2019 | Revis�o de fontes. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 19/05/2023 | Corrigido posicionamento na ZZL. Chamado 43886
===============================================================================================================================
*/                    

//===========================================================================
//| Defini��es de Includes                                                  |
//===========================================================================
#INCLUDE 'Protheus.ch' 

/*
===============================================================================================================================
Programa----------: AGLT004
Autor-------------: Jeovane
Data da Criacao---: 11/02/2009 
===============================================================================================================================
Descri��o---------: Cadastro de Setor
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT004

Local _cFilter		:= ""

Private cCadastro	:= "Cadastro Setor"
Private aRotina		:= MenuDef()
Private cAlias 		:= "ZL2"

//=====================================================================================
//Obtem Setores que podem ser acessados - 114 - "MBrowse - Visualiza outras filiais"
//Se o usu�rio visualiza toda as filiais no browse, filtro todos os setores. Do contra-
//�rio, filtro s� a filial corrente
//=====================================================================================
If Posicione("ZLU",1,xFilial("ZLU")+RetCodUsr(),"ZLU_SETALL") <> 'S'
	_cFilter :="ZL2_COD IN "+FormatIn(U_LisSetor(IIf(Substr(cAcesso,114,1)=='S',.F.,.T.)),";")
EndIf

MBrowse(,,,,cAlias,,,,,,,,,,,,,,_cFilter)

Return

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 02/08/2018
===============================================================================================================================
Descri��o---------: Utilizacao de Menu Funcional
===============================================================================================================================
Parametros--------: aRotina
					1. Nome a aparecer no cabecalho
					2. Nome da Rotina associada
					3. Reservado
					4. Tipo de Transa��o a ser efetuada:
						1 - Pesquisa e Posiciona em um Banco de Dados
						2 - Simplesmente Mostra os Campos
						3 - Inclui registros no Bancos de Dados
						4 - Altera o registro corrente
						5 - Remove o registro corrente do Banco de Dados
					5. Nivel de acesso
					6. Habilita Menu Funcional
===============================================================================================================================
Retorno-----------: Array com opcoes da rotina
===============================================================================================================================
*/
Static Function MenuDef()

Local aRotina := {	{ "Pesquisar"		, "AxPesqui" 		, 0 , 1 } ,;
					{ "Visualizar"		, "AxVisual" 		, 0 , 2 } ,;
					{ "Incluir"			, "AxInclui" 		, 0 , 3 } ,;
					{ "Alterar"			, "AxAltera" 		, 0 , 4 } ,;
					{ "Excluir"			, "U_AGLT004E"		, 0 , 5 }  }

Return( aRotina )

/*
===============================================================================================================================
Programa----------: AGLT004E
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 02/08/2018
===============================================================================================================================
Descri��o---------: Funcao usada para apagar registro da ZL2
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT004E(cAlias,nReg,nOpc)
Local bAxParam 	:= {|| .T.}
Local bVldExc	:= {|| U_ChkReg("ZLD","ZLD_SETOR = '"+ZL2->ZL2_COD+"' AND ZLD_FILIAL = '"+xFilial("ZLD")+"'") .And. ;
						U_ChkReg("ZL3","ZL3_SETOR = '"+ZL2->ZL2_COD+"' AND ZL3_FILIAL = '"+xFilial("ZL3")+"'")}

AxDeleta(cAlias,nReg,nOpc,/*cTransact*/,/*aCpos*/,/*aButtons*/,{bAxParam,bVldExc,bAxParam,bAxParam},/*aAuto*/,/*lMaximized*/)

Return

/*
===============================================================================================================================
Programa----------: AGLT004Mix
Autor-------------: Darcio Ribeiro Sporl
Data dsa Criacao---: 23/09/2016
===============================================================================================================================
Descri��o---------: Fun��o criada para habilitar ou n�o a altera��o do campo �ltimo valor mix
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lRet - .T. Habilita a digita��o do campos, .F. - caso contr�rio
===============================================================================================================================
*/
User Function AGLT004Mix()
Local _aArea	:= GetArea()
Local _lRet		:= .F.

dbSelectArea("ZZL")
ZZL->(DbSetOrder(3))
If ZZL->(DbSeek(xFilial("ZZL") + RetCodUsr()))
	If ZZL->ZZL_ALTMIX == "S"
		_lRet := .T.
	EndIf
EndIf

RestArea(_aArea)
Return(_lRet)
