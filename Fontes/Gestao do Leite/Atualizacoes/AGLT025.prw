/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 06/02/2016 | Ajustes no filtro de setores.  Chamados: 17833
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 28/09/2018 | Trocado campo ZLU_ALLSET para ZLU_SETALL - Chamado 26404
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 07/08/2019 | Modificada valida��o de acesso aos setores. Chamado 30185
===============================================================================================================================
*/

//===========================================================================
//| Defini��es de Includes                                                  |
//===========================================================================
#INCLUDE 'Protheus.ch' 

/*
===============================================================================================================================
Programa----------: AGLT025
Autor-------------: Abrahao P. Santos
Data da Criacao---: 17/11/2008
===============================================================================================================================
Descri��o---------: Cadastro de Desvio de Rotas/Linhas
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT025

Local _cFilter		:= ""

Private cDelFunc	:= "U_AGLT025V(2)" // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cCadastro	:= "Cadastro de Desvios de Rotas/Linhas"
Private aRotina		:= MenuDef()
Private cAlias		:= "ZLC"

//=====================================================================================
//Obtem Setores que podem ser acessados - 114 - "MBrowse - Visualiza outras filiais"
//Se o usu�rio visualiza toda as filiais no browse, filtro todos os setores. Do contra-
//�rio, filtro s� a filial corrente
//=====================================================================================
If Posicione("ZLU",1,xFilial("ZLU")+RetCodUsr(),"ZLU_SETALL") <> 'S'
	_cFilter :="ZLC_SETOR IN "+FormatIn(U_LisSetor(IIf(Substr(cAcesso,114,1)=='S',.F.,.T.)),";")
EndIf

MBrowse(,,,,cAlias,,,,,,,,,,,,,,_cFilter)

Return

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 18/09/2018
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
						6 - Altera determinados campos sem incluir novos Regs
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
					{ "Alterar"			, "U_AGLT025A"	 	, 0 , 4 } ,;
					{ "Excluir"			, "AxDeleta"		, 0 , 5 }  }

Return( aRotina )

/*
===============================================================================================================================
Programa----------: AGLT025A
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 02/08/2018
===============================================================================================================================
Descri��o---------: Funcao usada para alterar registro da ZLC
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT025A(cAlias,nReg,nOpc)

AxAltera(cAlias,nReg,nOpc,/*aAcho*/,/*aCpos*/,/*nColMens*/,/*cMensagem*/,"U_AGLT025V(1)"/*cTudoOk*/,/*cTransact*/,/*cFunc*/,/*aButtons*/,/*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/)
 
Return
/*
===============================================================================================================================
Programa----------: AGLT025V
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 08/07/2011
===============================================================================================================================
Descri��o---------: Funcao desenvolvida para validar a se um desvio de rota que ja possua eventos gerados no Mix
===============================================================================================================================
Parametros--------: _nOpcao -> 1 -> utiliza conte�do em m�moria
					_nOpcao -> 2 -> utiliza conte�do em m�moria
===============================================================================================================================
Retorno-----------: _lRet -> L -> Indica se foi encontrada referencia do registro usado em outra tabela
===============================================================================================================================
*/
User Function AGLT025V(_nOpcao)

Local _lRet := .T.
Local _cAlias	:= GetNextAlias()
Local _cFiltro := '%'

If _nOpcao == 1
	_cFiltro += " AND ZLF.ZLF_SETOR = '"  + M->ZLC_SETOR   + "'"
	_cFiltro += " AND ZLF.ZLF_LINROT = '" + M->ZLC_LINROT  + "'"
	_cFiltro += " AND ZLF.ZLF_A2COD = '"  + M->ZLC_FRETIS  + "'"
	_cFiltro += " AND ZLF.ZLF_A2LOJA = '" + M->ZLC_LJFRET  + "'"
	_cFiltro += " AND '" + DtoS(M->ZLC_DTCOLE) + "' >= ZLE.ZLE_DTINI AND '" + DtoS(M->ZLC_DTCOLE) + "' <= ZLE.ZLE_DTFIM"
Else
	_cFiltro += " AND ZLF.ZLF_SETOR = '"  + ZLC->ZLC_SETOR   + "'"
	_cFiltro += " AND ZLF.ZLF_LINROT = '" + ZLC->ZLC_LINROT  + "'"
	_cFiltro += " AND ZLF.ZLF_A2COD = '"  + ZLC->ZLC_FRETIS  + "'"
	_cFiltro += " AND ZLF.ZLF_A2LOJA = '" + ZLC->ZLC_LJFRET  + "'"
	_cFiltro += " AND '" + DtoS(ZLC->ZLC_DTCOLE) + "' >= ZLE.ZLE_DTINI AND '" + DtoS(ZLC->ZLC_DTCOLE) + "' <= ZLE.ZLE_DTFIM"
EndIf

_cFiltro += "%"

BeginSQL Alias _cAlias
	SELECT COUNT(1) QTD
	FROM %Table:ZLF% ZLF, %Table:ZLE% ZLE
	WHERE ZLF.D_E_L_E_T_ =' '
	AND ZLE.D_E_L_E_T_ =' '
	AND ZLE_FILIAL = %xFilial:ZLE%
	AND ZLF_FILIAL = %xFilial:ZLF%
	AND ZLE.ZLE_COD = ZLF.ZLF_CODZLE
	%exp:_cFiltro%
EndSQL

If (_cAlias)->QTD > 0
	_lRet := .F.
	MsgStop("N�o poder� ser realizada a inclus�o/altera��o/exclus�o do desvio de rota pois o trasnportador indicado ja possui eventos gerados no Mix."+;
			"Favor solicitar ao responsavel por efetuar os lan�amentos de eventos no Mix que exclua estes eventos e depois insira o desvio de rota.","AGLT01501")
EndIf

(_cAlias)->( DBCloseArea() )		

Return(_lRet)