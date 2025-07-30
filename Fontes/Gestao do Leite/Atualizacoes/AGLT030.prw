/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 09/01/2019 | Inclu�da fun��o para Reajustar valor do evento 000047 - Bonifica��o. Chamado 27573
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 06/05/2019 | Criados filtros de Setor e linha no rec�lculo da Bonifica��o. Chamado 29128
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 27/09/2019 | Revis�o de fontes. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#Include "Protheus.ch"
/*
===============================================================================================================================
Programa----------: AGLT030
Autor-------------: Abrahao P. Santos
Data da Criacao---: 02/03/2009
===============================================================================================================================
Descri��o---------: Rotina desenvolvida para fazer a manuten��o dos Eventos gerados na ZLF
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT030

Local _oBrowse := Nil

Private aRotina		:= MenuDef()
Private cCadastro	:= "Manuten��o dos Eventos - Gest�o do Leite"
//===========================================================================
//Configura��o da Classe do Browse
//===========================================================================
_oBrowse := FWMBrowse():New()

_oBrowse:SetAlias( "ZLF" )
_oBrowse:DisableDetails()
_oBrowse:SetMenuDef( 'AGLT030' )

_oBrowse:AddLegend( "ZLF_ACERTO == 'B' .AND. ZLF_STATUS == 'B'"	, 'RED'		, 'Registro Bloqueado'					)
_oBrowse:AddLegend( "ZLF_ACERTO == 'S' .AND. ZLF_STATUS == 'F'"	, 'GREEN'	, 'Registro Processado pelo Fechamento'	)
_oBrowse:AddLegend( "ZLF_ACERTO $ ' N' .AND. ZLF_STATUS <> 'F'"	, 'YELLOW'	, 'Registro Pendente'					)

_oBrowse:Activate()

Return

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 25/07/2018
===============================================================================================================================
Descri��o---------: Utilizacao de menu Funcional
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/
Static Function MenuDef()

Local aRotina := {	{ "Pesquisar"		, "AxPesqui"					, 0 , 1 } ,;
					{ "Visualizar"		, "AxVisual"					, 0 , 2 } ,;
					{ "Bloq/Desb Posici", "U_AGLT030B", 0 , 2 } ,;
					{ "Bloq/Desb Todos"	, "U_AGLT030T", 0 , 2 } ,;
					{ "Recalc. Bonific"	, "U_AGLT030R", 0 , 2 } ,;
					{ "Excluir"			, "U_AGLT030E", 0 , 5 }  }

Return( aRotina )

/*
===============================================================================================================================
Programa----------: AGLT030E
Autor-------------: Abrahao P. Santos
Data da Criacao---: 02/03/2009
===============================================================================================================================
Descri��o---------: Exclui evento posicionado
===============================================================================================================================
Parametros--------: ExpC1 = Alias do arquivo
					ExpN1 = Numero do registro
					ExpN2 = Numero da opcao selecionada
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT030E(cAlias,nReg,nOpc)

Local _nOpcao:= 0

If ZLF->ZLF_ACERTO $ "SB"
	MsgAlert('N�o � poss�vel excluir um Evento '+ IIF( ZLF->ZLF_ACERTO == 'S' , 'j� processado pelo Fechamento' , 'com bloqueio administrativo' ) +'!','AGLT03001')
Else
	_nOpcao := AxVisual(cAlias,nReg,nOpc)
	
	If _nOpcao == 1
		ZLF->( RecLock( "ZLF" , .F. ) )
		ZLF->( DbDelete() )
		ZLF->( MsUnlock() )
	EndIf
EndIf

Return

/*
===============================================================================================================================
Programa----------: AGLT030B
Autor-------------: Abrahao P. Santos
Data da Criacao---: 02/03/2009
===============================================================================================================================
Descri��o---------: Bloqueia/Desbloqueia registro posicionado
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT030B

If ZLF->ZLF_ACERTO <> 'B' .And. ZLF->ZLF_ACERTO <> 'S' .And. ZLF->ZLF_STATUS <> 'B' .And. ZLF->ZLF_STATUS <> 'F'
	If MsgYesNo('Confirma o bloqueio administrativo do registro selecionado?',"AGLT03002 - Bloqueio Registro")
		ZLF->( RecLock( "ZLF" , .F. ) )
		ZLF->ZLF_ACERTO := 'B'
		ZLF->ZLF_STATUS := 'B'
		ZLF->( MsUnlock() )
	EndIf
ElseIf ZLF->ZLF_ACERTO == 'B' .And. ZLF->ZLF_STATUS == 'B'
	If MsgYesNo('Confirma o debloqueio administrativo do registro selecionado?',"AGLT03003 - Desbloqueio Registro")
		ZLF->( RecLock( "ZLF" , .F. ) )
		ZLF->ZLF_ACERTO := 'N'
		ZLF->ZLF_STATUS := 'E'
		ZLF->( MsUnlock() )
	EndIf
Else
	MsgAlert('N�o � poss�vel realizar a opera��o no registro selecionado! Verifique o Status de acerto do registro atual e tente novamente.','AGLT03004')
EndIf

Return

/*
===============================================================================================================================
Programa----------: AGLT030T
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 25/06/2018
===============================================================================================================================
Descri��o---------: Bloqueia/Desbloqueia todos os registros do mesmo "grupo"
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT030T

Local _aArea 	:= GetArea()
Local _cAliasZLF:= GetNextAlias()
Local _cQuery	:= ''
Local _cFiltro	:= ''
Local _cSet		:= ''
Local _lBloq	:= ' '
Local _lProc	:= .F.

If ZLF->ZLF_ACERTO <> 'B' .And. ZLF->ZLF_ACERTO <> 'S' .And. ZLF->ZLF_STATUS <> 'B' .And. ZLF->ZLF_STATUS <> 'F'
	_cFiltro:= "% ZLF_ACERTO NOT IN ('B','S')"
	_cFiltro+= " AND ZLF_STATUS NOT IN ('B','F')%"
	_cSet	:= " SET ZLF_ACERTO = 'B', ZLF_STATUS = 'B'"
	_lBloq := 'S'
ElseIf ZLF->ZLF_ACERTO == 'B' .And. ZLF->ZLF_STATUS == 'B'
	_cFiltro:= "% ZLF_ACERTO = 'B' "
	_cFiltro+= " AND ZLF_STATUS = 'B' %"
	_cSet	:= " SET ZLF_ACERTO = 'N', ZLF_STATUS = 'E'"
	_lBloq := 'N'
EndIf

If Empty(_lBloq)
	MsgAlert( 'Registro n�o possui status v�lido para a opera��o. Favor verificar','AGLT03005')
Else
	BeginSQL Alias _cAliasZLF
		SELECT COUNT(1) QTD
		FROM %Table:ZLF%
		WHERE D_E_L_E_T_ =' '
		AND ZLF_FILIAL = %exp:ZLF->ZLF_FILIAL%
		AND ZLF_CODZLE = %exp:ZLF->ZLF_CODZLE%
		AND ZLF_A2COD =  %exp:ZLF->ZLF_A2COD%
		AND ZLF_A2LOJA = %exp:ZLF->ZLF_A2LOJA%
		AND ZLF_SETOR = %exp:ZLF->ZLF_SETOR%
		AND %Exp:_cFiltro%
	EndSQL
	
	If _lBloq == 'S' .And. MsgYesNo('Confirma o bloqueio administrativo dos registros desse mesmo Fornecedor? '+ cValToChar((_cAliasZLF)->QTD) +' registros ser�o alterados.';
						,"AGLT03006 - Bloq/Desb Todos")
		_lProc = .T.
	ElseIf _lBloq == 'N' .And.	MsgYesNo('Confirma o Desbloqueio administrativo dos registros desse mesmo Fornecedor? '+ cValToChar((_cAliasZLF)->QTD) +' registros ser�o alterados.';
						,"AGLT03007 - Bloq/Desb Todos")
		_lProc = .T.
	EndIf
	(_cAliasZLF)->(DbCloseArea())
	
Endif

If _lProc
	_cQuery:=" UPDATE "+RETSQLNAME('ZLF')
	_cQuery+=_cSet
	_cQuery+=" WHERE D_E_L_E_T_ = ' ' "
	_cQuery+=" AND ZLF_FILIAL = '" + ZLF->ZLF_FILIAL + "'"
	_cQuery+=" AND ZLF_CODZLE = '" + ZLF->ZLF_CODZLE + "'"
	_cQuery+=" AND ZLF_A2COD =  '" + ZLF->ZLF_A2COD + "'"
	_cQuery+=" AND ZLF_A2LOJA = '" + ZLF->ZLF_A2LOJA + "'"
	_cQuery+=" AND ZLF_SETOR = '" + ZLF->ZLF_SETOR + "'"
	_cQuery+=" AND " + StrTran(_cFiltro,'%','')

	If TCSqlExec( _cQuery ) < 0
		MsgStop( 'Erro ao atualizar Registros: '+AllTrim(TCSQLError()),'AGLT03008')
	Else
		MsgInfo('Registros atualizados com sucesso!','AGLT03009')
	EndIf
EndIf

RestArea(_aArea)

Return()

/*
===============================================================================================================================
Programa----------: AGLT030R
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 08/01/2019
===============================================================================================================================
Descri��o---------: Recalcula evento 000047 - Bonifica��o Extra ao Produtor
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AGLT030R

Local _aArea 	:= GetArea()
Local _cQuery	:= ''
Local _cFiltro	:= ''

If !Pergunte("AGLT030",.T.)
	Return
EndIf

//Se preencheu os setores, j� fiz a valida��o de acesso no SX1
//Se n�o preencheu e n�o tem acesso a todos, filtra de forma que n�o retorme registros
If !Empty(MV_PAR04) .Or. Empty(MV_PAR04) .And. Posicione("ZLU",1,xFilial("ZLU")+RetCodUsr(),"ZLU_SETALL") <> 'S'
	_cFiltro += " AND ZLF_SETOR IN "+ FormatIn( AllTrim(MV_PAR04) , ';' )
EndIf

//Verifica se foi fornecido o filtro de linha
If !Empty(MV_PAR05)
	_cFiltro += " AND ZLF_LINROT IN " + FormatIn(MV_PAR05,";")
EndIf

_cQuery:=" UPDATE "+RETSQLNAME('ZLF')
_cQuery+=" SET ZLF_TOTAL = ROUND(ZLF_QTDBOM*(ZLF_VLRLTR "+IIF(MV_PAR03==1,"+","-")+ cValToChar(MV_PAR02)+"),2), ZLF_VLRLTR = ZLF_VLRLTR "+IIF(MV_PAR03==1,"+","-")+ cValToChar(MV_PAR02)
_cQuery+=" WHERE D_E_L_E_T_ = ' ' "
_cQuery+=" AND ZLF_FILIAL = '" + ZLF->ZLF_FILIAL + "'"
_cQuery+=" AND ZLF_CODZLE = '" + MV_PAR01 + "'"
_cQuery+=" AND ZLF_EVENTO = '000047'"
_cQuery+=" AND ZLF_STATUS = 'A'"
_cQuery+= _cFiltro

If TCSqlExec( _cQuery ) < 0
	MsgStop( 'Erro ao atualizar Registros: '+AllTrim(TCSQLError()),'AGLT03010')
Else
	_cQuery:=" UPDATE "+RETSQLNAME('ZLF')
	_cQuery+=" SET D_E_L_E_T_ = '*'"
	_cQuery+=" WHERE D_E_L_E_T_ = ' ' "
	_cQuery+=" AND ZLF_FILIAL = '" + ZLF->ZLF_FILIAL + "'"
	_cQuery+=" AND ZLF_CODZLE = '" + MV_PAR01 + "'"
	_cQuery+=" AND ZLF_EVENTO = '000047'"
	_cQuery+=" AND ZLF_STATUS = 'A'"
	_cQuery+=" AND ZLF_TOTAL <= 0"
	_cQuery+= _cFiltro
	
	If TCSqlExec( _cQuery ) < 0
		MsgStop( 'Erro ao atualizar Registros: '+AllTrim(TCSQLError()),'AGLT03011')
	Else
		MsgInfo('Registros atualizados com sucesso!','AGLT03012')
	EndIf
EndIf

RestArea(_aArea)

Return