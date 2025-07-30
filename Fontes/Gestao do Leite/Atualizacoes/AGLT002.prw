/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 03/08/2018 | Inclu�do MenuDef para padroniza��o - Chamado 25767
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 15/08/2019 | Modificada valida��o para dele��o de registros. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 24/04/2034 | Inclu�da replica��o dos cadastros para todas as placas do transportador. Chamado 47051
===============================================================================================================================
*/

//===========================================================================
//| Defini��es de Includes                                                  |
//===========================================================================
#INCLUDE 'Protheus.ch' 

/*
===============================================================================================================================
Programa----------: AGLT002
Autor-------------: Abrahao P. Santos
Data da Criacao---: 12/11/2008
===============================================================================================================================
Descri��o---------: Rotina desenvolvida para possibilitar o cadastramento de Veiculos utilizados na coleta de leite nos retiros
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT002

Private cCadastro	:= "Cadastro de Veiculos"
Private aRotina		:= MenuDef()
Private cAlias		:= "ZL1"

mBrowse( 6, 1,22,75,cAlias,,,,,,)

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
					{ "Incluir"			, "U_AGLT002I" 		, 0 , 3 } ,;
					{ "Alterar"			, "U_AGLT002A" 		, 0 , 4 } ,;
					{ "Bloq. Inativos"	, "U_AGLT002B" 		, 0 , 1 } ,;
					{ "Excluir"			, "U_AGLT002E"		, 0 , 5 }  }

Return( aRotina )

/*
===============================================================================================================================
Programa----------: AGLT002E
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 02/08/2018
===============================================================================================================================
Descri��o---------: Funcao usada para apagar registro da ZL1
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT002E(cAlias,nReg,nOpc)
Local bAxParam 	:= {|| .T.}
Local bVldExc	:= {|| U_ChkReg("ZLD","ZLD_VEICUL = '"+ZL1->ZL1_COD+"' AND ZLD_FILIAL = '"+xFilial("ZLD")+"'") .And. ;
						U_ChkReg("ZL3","ZL3_VEICUL = '"+ZL1->ZL1_COD+"' AND ZL3_FILIAL = '"+xFilial("ZL3")+"'")}
AxDeleta(cAlias,nReg,nOpc,/*cTransact*/,/*aCpos*/,/*aButtons*/,{bAxParam,bVldExc,bAxParam,bAxParam},/*aAuto*/,/*lMaximized*/)

Return

/*
===============================================================================================================================
Programa----------: AGLT002I
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 23/04/2024
===============================================================================================================================
Descri��o---------: Funcao usada para incluir registro da ZL1
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT002I(cAlias,nReg,nOpc)

If 1 == AxInclui(cAlias,nReg,nOpc,/*aAcho*/,/*cFunc*/,/*aCpos*/,/*cTudoOk*/,/*lF3*/,/*cTransact*/,/*aButtons*/,/*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/)
	Processa({|| AGLT002T(cAlias,nReg,nOpc) }, "Aguarde...", "Gerando novos cadastros...",.F.)
EndIf

Return

/*
===============================================================================================================================
Programa----------: AGLT002A
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 23/04/2024
===============================================================================================================================
Descri��o---------: Funcao usada para incluir registro da ZL1
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT002A(cAlias,nReg,nOpc)

If 1 == AxAltera(cAlias,nReg,nOpc,/*aAcho*/,/*aCpos*/,/*nColMens*/,/*cMensagem*/,/*cTudoOk*/,/*cTransact*/,/*cFunc*/,/*aButtons*/,/*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/)
	Processa({|| AGLT002T(cAlias,nReg,nOpc) }, "Aguarde...", "Gerando novos cadastros...",.F.)
EndIf

Return

/*
===============================================================================================================================
Programa----------: AGLT002T
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 23/04/2024
===============================================================================================================================
Descri��o---------: Atualiza todos os motoristas cujo transportador � o mesmo do motorista que est� sendo inclu�do/alterado.
					Dessa forma todos os cadastros s�o replicados.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AGLT002T(cAlias,nReg,nOpc)

Local _cAliasM	:= GetNextAlias()
Local _cAlias	:= ""
Local _aFields	:= FWSX3Util():GetAllFields( cAlias , .F. )
Local _nX		:=	0

	BeginSql alias _cAliasM
		SELECT ZL0.ZL0_COD, ZL0.ZL0_NOME
		FROM %Table:ZL0% ZL0, %Table:ZL0% X
		WHERE ZL0.D_E_L_E_T_ = ' '
		AND X.D_E_L_E_T_ = ' '
		AND ZL0.ZL0_FILIAL = X.ZL0_FILIAL
		AND ZL0.ZL0_FRETIS = X.ZL0_FRETIS
		AND ZL0.ZL0_FRETLJ = X.ZL0_FRETLJ
		AND X.ZL0_FILIAL = %xFilial:ZL1%
		AND X.ZL0_COD = %exp:ZL1->ZL1_MOTORI%
		AND ZL0.ZL0_ATIVO = 'S'
		AND X.ZL0_ATIVO = 'S'
		ORDER BY ZL0.ZL0_COD
	EndSql
	While (_cAliasM)->( !Eof() )
		_cAlias := GetNextAlias()
		BeginSql alias _cAlias
			SELECT ZL1_FILIAL, ZL1_PLACA, ZL1_PLCREB, ZL1_TABFRE, ZL1_TIPO, ZL1_CAPACI, ZL1_MARCA, ZL1_QTDDIV, ZL1_NSERIE, ZL1_TPTANQ, ZL1_MSBLQL
			FROM %Table:ZL0% ZL0 , %Table:ZL1% ZL1, %Table:ZL0% X
			WHERE ZL0.D_E_L_E_T_ = ' '
			AND  ZL1.D_E_L_E_T_ = ' '
			AND X.D_E_L_E_T_ = ' '
			AND ZL1_FILIAL = ZL0.ZL0_FILIAL
			AND ZL0.ZL0_FILIAL = X.ZL0_FILIAL
			AND ZL0.ZL0_FRETIS = X.ZL0_FRETIS
			AND ZL0.ZL0_FRETLJ = X.ZL0_FRETLJ
			AND ZL1_MOTORI = ZL0.ZL0_COD
			AND ZL1_MSBLQL = '2'
			AND ZL0.ZL0_ATIVO = 'S'
			AND X.ZL0_ATIVO = 'S'
			AND X.ZL0_COD = %exp:(_cAliasM)->ZL0_COD%
			AND ZL0.ZL0_FILIAL = %xFilial:ZL0%
			AND NOT EXISTS (SELECT 1 FROM %Table:ZL1% A 
			WHERE A.D_E_L_E_T_ = ' '
			AND A.ZL1_FILIAL = ZL1.ZL1_FILIAL
			AND A.ZL1_MOTORI = X.ZL0_COD
			AND A.ZL1_PLACA = ZL1.ZL1_PLACA
			AND A.ZL1_PLCREB = ZL1.ZL1_PLCREB
			AND A.ZL1_TABFRE = ZL1.ZL1_TABFRE)
			GROUP BY ZL1_FILIAL, ZL1_PLACA, ZL1_PLCREB, ZL1_TABFRE, ZL1_TIPO, ZL1_CAPACI, ZL1_MARCA, ZL1_QTDDIV, ZL1_NSERIE, ZL1_TPTANQ, ZL1_MSBLQL
		EndSql
		While (_cAlias)->( !Eof() )
			(cAlias)->(RecLock(cAlias, .T.))
				For _nX := 1 To Len(_aFields)
					If AllTrim(_aFields[_nX]) == "ZL1_COD"
						(cAlias)->&(_aFields[_nX]):= GetSxeNum( "ZL1" , "ZL1_COD" )
					ElseIf  allTrim(_aFields[_nX]) == "ZL1_MOTORI"
						(cAlias)->&(_aFields[_nX]):= (_cAliasM)->ZL0_COD
					ElseIf  AllTrim(_aFields[_nX]) == "ZL1_NOME"
						(cAlias)->&(_aFields[_nX]):= (_cAliasM)->ZL0_NOME
					Else
						(cAlias)->&(_aFields[_nX]):= (_cAlias)->&(_aFields[_nX])
					EndIf
				Next _nX
			(cAlias)->(MsUnLock())
			If __lSX8
				ConfirmSX8()
			EndIf
			(_cAlias)->( DBSkip() )
		EndDo
		(_cAlias)->(DbClosearea())
		(_cAliasM)->( DBSkip() )
	EndDo 

	(_cAliasM)->(DbClosearea())

Return

/*
===============================================================================================================================
Programa----------: AGLT002B
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 23/04/2024
===============================================================================================================================
Descri��o---------: Bloqueia todos os cadastros inativos de acordo com o per�odo informado.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT002B

Local _aArea := FWGetArea()
Local _oSelf := Nil

tNewProcess():New(	"AGLT002"										,; // Fun��o inicial
					"Bloqueia Ve�culos"							,; // Descri��o da Rotina
					{|_oSelf| AtVeicul(_oSelf) }					,; // Fun��o do processamento
					"Realiza o bloqueio dos ve�culos que n�o foram utilizados no per�odo informado ",; // Descri��o da Funcionalidade
					"AGLT002"										,; // Configura��o dos Par�metros
					{}												,; // Op��es adicionais para o painel lateral
					.F.												,; // Define cria��o do Painel auxiliar
					0												,; // Tamanho do Painel Auxiliar
					''												,; // Descri��o do Painel Auxiliar
					.F.												,; // Se .T. exibe o painel de execu��o. Se falso, apenas executa a fun��o sem exibir a r�gua de processamento.
					.F.                                              ) // Se .T. cria apenas uma regua de processamento.

FWRestArea(_aArea)

Return
Static Function AtVeicul(_oSelf)

Local _aSelFil	:= {}
Local _cFiltro := ""
Local _cUpdate := ""

//Chama fun��o que permitir� a sele��o das filiais
If MV_PAR01 == 1
	If Empty(_aSelFil)
		_aSelFil := AdmGetFil(.F.,.F.,"ZL1")
	EndIf
Else
	Aadd(_aSelFil,cFilAnt)
EndIf
_cFiltro := " AND ZL1_FILIAL "+ GetRngFil( _aSelFil, "ZL1", .T.,)

_cUpdate:=" UPDATE "+RetSqlName('ZL1')+" SET ZL1_MSBLQL = '1' " 
_cUpdate+=" WHERE D_E_L_E_T_ = ' '"
_cUpdate+=" AND (SYSDATE -CAST( I_N_S_D_T_ AT TIME ZONE '-06:00' AS DATE) > 45 OR I_N_S_D_T_ IS NULL)"
_cUpdate+=" AND ZL1_MSBLQL <> '1'"
_cUpdate+= _cFiltro
_cUpdate+=" AND NOT EXISTS (SELECT 1 FROM "+RetSqlName('ZLD')
_cUpdate+=" WHERE D_E_L_E_T_ = ' '"
_cUpdate+=" AND ZLD_DTCOLE BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "' " 
_cUpdate+=" AND ZLD_FILIAL = ZL1_FILIAL"
_cUpdate+=" AND ZLD_VEICUL = ZL1_COD"
_cUpdate+=" AND ZLD_MOTOR = ZL1_MOTORI)"
	
If TCSqlExec(_cUpdate) < 0
	FWAlertError("Erro ao bloquear os ve�culos: "+AllTrim(TCSQLError()),"AGLT00201")
Else
	_cFiltro := " AND ZL0_FILIAL "+ GetRngFil( _aSelFil, "ZL1", .T.,)
	_cUpdate:=" UPDATE "+RetSqlName('ZL0')+" SET ZL0_ATIVO = 'N' " 
	_cUpdate+=" WHERE D_E_L_E_T_ = ' '"
	_cUpdate+=" AND (SYSDATE -CAST( I_N_S_D_T_ AT TIME ZONE '-06:00' AS DATE) > 45 OR I_N_S_D_T_ IS NULL)"
	_cUpdate+=" AND ZL0_ATIVO <> 'N'"
	_cUpdate+= _cFiltro
	_cUpdate+=" AND NOT EXISTS (SELECT 1 FROM "+RetSqlName('ZLD')
	_cUpdate+=" WHERE D_E_L_E_T_ = ' '"
	_cUpdate+=" AND ZLD_DTCOLE BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "' " 
	_cUpdate+=" AND ZLD_FILIAL = ZL0_FILIAL"
	_cUpdate+=" AND ZLD_MOTOR = ZL0_COD)"
		
	If TCSqlExec(_cUpdate) < 0
		FWAlertError("Erro ao bloquear os Motoristas: "+AllTrim(TCSQLError()),"AGLT00203")
	Else
		FWAlertSuccess("Ve�culos e Motoristas bloqueados com sucesso!","AGLT00204")
	EndIf
EndIf



Return
