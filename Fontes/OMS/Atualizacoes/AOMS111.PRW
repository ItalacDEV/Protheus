/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 16/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina. 
//====================================================================================================
#Include 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: AOMS111
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/12/2018
===============================================================================================================================
Descrição---------: Tela de indicação de produto em trânsito - Chamado 25853
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS111()

Local _aAlias		:= {}
Local _aColumns		:= {}

Private aRotina		:= menudef()
Private _aRegsSD2	:= {}
Private _aRegsSC7	:= {}
Private _aRegsAll	:= {}
Private _cPerg		:= "AOMS111"
Private _bChkMarca	:= {}
Private _bSelMarca	:= {}
Private _bAllMarca	:= {}
Private _dEmissIni	:= ""
Private _dEmissFim	:= ""
Private _cSolicIni	:= ""
Private _cSolicFim	:= ""
Private _cProDe		:= ""
Private _cProAte	:= ""
Private oMrkBrowse := nil

//--------------------------------------------------------
//Retorna as colunas para o preenchimento da FWMarkBrowse
//--------------------------------------------------------
fwmsgrun( ,{|| _aAlias := AOMS111QRY() } , 'Aguarde!' , 'Verificando os registros...' )
	
_cAliasMrk	:= _aAlias[1]
_aColumns 	:= _aAlias[2]

If !(_cAliasMrk)->(Eof())
	//----------------------
	//Criação da MarkBrowse
	//----------------------
	oMrkBrowse:= FWMarkBrowse():New()
	oMrkBrowse:SetDataTable(.T.)
	oMrkBrowse:SetAlias(_cAliasMrk)
	oMrkBrowse:SetFieldMark("SD2_OK")
	oMrkBrowse:SetDescription("Produtos em trânsito para o documento de entrada " + SF2->F2_DOC + " do fornecedor " + POSICIONE("SA1",1,XFILIAL("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NREDUZ"))
	oMrkBrowse:SetColumns(_aColumns)
	oMrkBrowse:SetIniWindow({|| U_AOMS111I()})
	
	oMrkBrowse:Activate()

Else

	u_itmsg("Não existem registros de acordo com os filtros selecionados!","Atenção","Modifique os filtros e tente novamente",1)
	
EndIf

If !Empty (_cAliasMrk)
	dbSelectArea(_cAliasMrk)
	dbCloseArea()
	_cAliasMrk := ""
				
Endif

Return 

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 20/08/2015                                    .
===============================================================================================================================
Descrição---------: Rotina para criação do menu da tela principal
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _aRotina - Array com as opções de menu.
===============================================================================================================================
*/
Static Function MenuDef()
Local _aRotina := {}

ADD OPTION _aRotina Title 'Confirmar'	Action 'U_AOMS111G'	OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title 'Cancelar'   	Action 'U_AOMS111S'	OPERATION 3 ACCESS 0

Return(_aRotina)


/*
===============================================================================================================================
Programa----------: AOMS111QRY
Autor-------------: Josué Danich Prestes
Data da Criacao---: 28/12/2015
===============================================================================================================================
Descrição---------: Função utilizada para montar a query e arquivo temporário
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Array [1] - Tabela temporária / [2] - Colunas do browse
===============================================================================================================================
*/
Static Function AOMS111QRY()

Local _cAliasTrb	:= GetNextAlias()		
Local _aFields		:= {}
Local _cSelect		:= ""
Local _aColumns	:= {}
Local _nX			:= 0					

//Variaveis utilizadas para montar o where da query, referente aos filtros preenchidos pelo usuario.
Local _cWFilial	:= ""

Private _cTempTab	:= ""


_aFields		:= {	'D2_ITEM',;
							'D2_COD',;
							"B1_DESC",;
							'D2_QUANT',;
							'D2_UM',;
							'D2_PRCVEN',;
							'D2_TOTAL',;
							'D2_I_TRANS'}
						
_aStructt	:= SD2->(DBSTRUCT())
	
_aStructSD2 := {}	


AADD( _aStructSD2 , { "SD2_OK"		, 'C' , 04 , 0 } )
AADD( _aStructSD2 , { "B1_DESC"	, 'C' , 20 , 0 } )
	
For _nX := 1 To Len(_aFields)
	
	_cSelect += _aFields[_nX] + ", "
	_nn := ascan(_astructt,{|item| item[1] = _afields[_nx]})
	If _nn > 0
		aadd(_astructSD2,_astructt[_nn])
	Endif
	
Next _nX

_cWFilial := "%"
_cWFilial += " SD2.D2_FILIAL  = '" + SF2->F2_FILIAL + "'  AND  SD2.D2_DOC  = '" + SF2->F2_DOC + "'  AND " 
_cWFilial += " SD2.D2_SERIE  = '" + SF2->F2_SERIE + "' "
_cWFilial += "%"

If ( Select( _cAliasTrb ) > 0 )

	DbSelectArea(_cAliasTrb)
	DbCloseArea()

EndIf
	
BeginSQL alias _cAliasTrb

	SELECT 	D2_ITEM,
			D2_COD, 
			D2_QUANT, 
			D2_UM, 
			D2_TOTAL,
			D2_PRCVEN,
			D2_I_TRANS
	 		
	FROM %table:SD2% SD2
		
	WHERE
	
	%Exp:_cWFilial%	AND
	SD2.%notDel%

	ORDER BY D2_ITEM 

EndSql

//----------------------------------------------------------------------
// Cria arquivo de dados temporário
//----------------------------------------------------------------------
_ctempTab := getnextalias()
_otemp := FWTemporaryTable():New( _ctempTab,  _aStructSD2 )

If ( Select(  _ctempTab ) > 0 )

	DbSelectArea( _ctempTab)
	DbCloseArea()

EndIf

_otemp:Create()

Do While (_cAliasTrb)->(!Eof())

	Reclock(_cTempTab,.T.)
	(_cTempTab)->D2_ITEM := (_cAliasTrb)->D2_ITEM
	(_cTempTab)->D2_COD := (_cAliasTrb)->D2_COD
	(_cTempTab)->B1_DESC := posicione("SB1",1,xfilial("SB1")+(_cAliasTrb)->D2_COD,"B1_DESC")
	(_cTempTab)->D2_QUANT := (_cAliasTrb)->D2_QUANT
	(_cTempTab)->D2_UM := (_cAliasTrb)->D2_UM
	(_cTempTab)->D2_TOTAL := (_cAliasTrb)->D2_TOTAL
	(_cTempTab)->D2_PRCVEN := (_cAliasTrb)->D2_PRCVEN
	(_cTempTab)->SD2_OK :=  (_cAliasTrb)->D2_I_TRANS
	(_cTempTab)->(Msunlock())

	(_cAliasTrb)->(Dbskip())
	
Enddo

If ( Select( _cAliasTrb ) > 0 )

	DbSelectArea(_cAliasTrb)
	DbCloseArea()

EndIf

DBSelectArea(_cTempTab)
(_cTempTab)->( DBGoTop() )
While (_cTempTab)->(!Eof())
	
	aAdd( _aRegsAll , { (_cTempTab)->D2_ITEM } )
			
	(_cTempTab)->( DBSkip() )

EndDo

(_cTempTab)->( DBGoTop() )

For _nX := 1 To Len(_aFields)

	If	!_aFields[_nX] == "SD2_OK" .And. _aFields[_nX] $ _cSelect

		AAdd(_aColumns,FWBrwColumn():New())
			
		_aColumns[Len(_aColumns)]:SetTitle(RetTitle(_aFields[_nX])) 
		_aColumns[Len(_aColumns)]:SetSize(TamSX3(_aFields[_nX])[1]) 
		_aColumns[Len(_aColumns)]:SetDecimal(TamSX3(_aFields[_nX])[2])
			

		If  _aFields[_nX] == "D2_QUANT" .OR. _aFields[_nX] == "D2_PRCVEN" .OR. _aFields[_nX] == "D2_TOTAL"
			
				_aColumns[Len(_aColumns)]:SetData( &("{||" + _aFields[_nX] + "}") )
				_aColumns[Len(_aColumns)]:NALIGN := 2
	
						
		Else
			
				_aColumns[Len(_aColumns)]:SetData( &("{||" + _aFields[_nX] + "}") )
				_aColumns[Len(_aColumns)]:SetSize(10) 
			
		Endif
		
	Endif
		
Next _nX

(_cTempTab)->( DBGoTop() )

_aret := { _cTempTab , _aColumns } 

Return _aret

/*
===============================================================================================================================
Programa----------: AOMS111S
Autor-------------: Josué Danich Prestes
Data da Criacao---: 28/12/2015
===============================================================================================================================
Descrição---------: Fecha a janela
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS111S()

	If u_itmsg("Deseja sair sem gravar?","Atenção",,2,2,2)
		CloseBrowse()
	Endif
	
Return

/*
===============================================================================================================================
Programa----------: AOMS111S
Autor-------------: Josué Danich Prestes
Data da Criacao---: 28/12/2015
===============================================================================================================================
Descrição---------: Fecha a janela
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS111G()

Local _ccomp := "S"

IF u_itmsg("Confirma gravação das marcações?","Atenção",,2,2,2)
		
	(_cAliasMrk)->( DBGoTop() )
		
	Do while !(_cAliasMrk)->( Eof() )
		
		SD2->(Dbsetorder(3))
		If SD2->(Dbseek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+(_cAliasMrk)->D2_COD+(_cAliasMrk)->D2_ITEM))
			
			Reclock("SD2",.F.)
			If omrkbrowse:ismark()
				
				SD2->D2_I_TRANS:= "S"
					
			Else
				
				SD2->D2_I_TRANS:= "N"
				_ccomp := "N"
				
			Endif
			SD2->(Msunlock())

		Endif
		
		(_cAliasMrk)->( Dbskip() )
		
	Enddo
	
	Reclock("SF2",.F.)
	SF2->F2_I_TRANS:= _ccomp
	SF2->(Msunlock())

	CloseBrowse()
		
	Endif
	
Return

/*
===============================================================================================================================
Programa----------: AOMS111I
Autor-------------: Josué Danich Prestes
Data da Criacao---: 28/12/2015
===============================================================================================================================
Descrição---------: Carrega marcações no markbrowse
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS111I()

(_cAliasMrk)->(Dbgotop())

Do While (_cAliasMrk)->(!Eof())

	Reclock(_cAliasMrk,.F.)
	(_cAliasMrk)->SD2_OK := iif( ALLTRIM((_cAliasMrk)->SD2_OK)=='S', omrkbrowse:cmark , '    ')
	(_cAliasMrk)->(Msunlock())

	(_cAliasMrk)->(Dbskip())
	
Enddo
	
omrkbrowse:refresh()
omrkbrowse:gotop()
omrkbrowse:gobottom()
omrkbrowse:gotop()
omrkbrowse:refresh()

RETURN