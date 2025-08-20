/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     |15/02/2019| Chamado 28120. Corre��es nas leituras e valida��es dos Aprovadores sobre tabela Solic. Compras(SC1)
Lucas Borges  |17/10/2019| Chamado 28346. Removidos os Warning na compila��o da release 12.1.25
Lucas Borges  |09/05/2025| Chamado 50617. Corrigir chamada est�tica no nome das tabelas do sistema
===============================================================================================================================
*/

#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
 
#define	MB_OK				0

/*
===============================================================================================================================
Programa----------: ACOM001
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 31/07/2015                                    .
Descri��o---------: Cadastro de Aprovadores e Solicitantes de solicita��es de compras.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM001()
Local _oBrowse		:= Nil

dbSelectArea("ZZL")
ZZL->(dbSetOrder(3)) //ZZL_FILIAL + ZZL_CODUSU
If ZZL->(dbSeek(xFilial("ZZL") + __cUserId))
	If ZZL->ZZL_ADMCAS == "S"

		//====================================================================================================
		// Configura e inicializa a Classe do Browse
		//====================================================================================================
		_oBrowse := FWMBrowse():New()
		
		_oBrowse:SetAlias( 'ZZ7' )
		_oBrowse:SetMenuDef( 'ACOM001' )
		_oBrowse:SetDescription( 'Cadastro de Aprovadores de Solicitacao de Compra' )
		_oBrowse:DisableDetails()
		
		_oBrowse:AddLegend( 'ZZ7->ZZ7_TIPO == "A" .AND. ZZ7->ZZ7_STATUS == "N"' , 'GREEN'	, 'Aprovador Normal'		)
		_oBrowse:AddLegend( 'ZZ7->ZZ7_TIPO == "A" .AND. ZZ7->ZZ7_STATUS == "A"' , 'YELLOW'	, 'Aprovador Ausente'		)
		_oBrowse:AddLegend( 'ZZ7->ZZ7_TIPO == "A" .AND. ZZ7->ZZ7_STATUS == "B"' , 'BLACK'	, 'Aprovador Bloqueado'		)
		_oBrowse:AddLegend( 'ZZ7->ZZ7_TIPO == "S" .AND. ZZ7->ZZ7_STATUS == "N"' , 'BLUE'	, 'Solicitante Normal'		)
		_oBrowse:AddLegend( 'ZZ7->ZZ7_TIPO == "S" .AND. ZZ7->ZZ7_STATUS == "B"' , 'GRAY'	, 'Solicitante Bloqueado'	)
		
		_oBrowse:Activate()
	Else
		U_ITMSG("O usu�rio: " + cUserName + " n�o possui permiss�o para utilizar este cadastro.",;
		        "Usu�rio Inv�lido",;
		        "Verificar com a �rea de TI a possibilidade de habilitar o seu usu�rio.",2) 
	EndIf
Else
	U_ITMSG("O usu�rio: " + cUserName + " n�o possui permiss�o para utilizar este cadastro.",;
            "Usu�rio Inv�lido",;
            "Verificar com a �rea de TI a possibilidade de habilitar o seu usu�rio.",2) 
EndIf

Return()

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 31/07/2015                                    .
Descri��o---------: Rotina para cria��o do menu da tela principal
Parametros--------: Nenhum
Retorno-----------: _aRotina - Array com as op��es de menu.
===============================================================================================================================
*/
Static Function MenuDef()
Local _aRotina := {}

ADD OPTION _aRotina Title 'Visualizar'	Action 'VIEWDEF.ACOM001'	OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title 'Incluir'   	Action 'VIEWDEF.ACOM001'	OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Alterar'   	Action 'VIEWDEF.ACOM001'	OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title 'Excluir'		Action 'VIEWDEF.ACOM001'	OPERATION 5 ACCESS 0
ADD OPTION _aRotina Title 'Imprimir' 	Action 'VIEWDEF.ACOM001'	OPERATION 8 ACCESS 0
ADD OPTION _aRotina Title 'Copiar' 		Action 'U_ACOM001C()'		OPERATION 9 ACCESS 0

Return( _aRotina ) 

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 31/07/2015                                    .
Descri��o---------: Rotina para montagem do modelo de dados para o processamento
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ModelDef()

Local _oStruZZ7	:= FWFormStruct( 1 , 'ZZ7' )
Local _oStruZZ8	:= FWFormStruct( 1 , 'ZZ8' )
Local _oModel	:= Nil

_oModel := MpFormModel():New( 'ACOM001M' ,, {|_oModel| VALIDCOMIT(_oModel) } )

_oModel:AddFields(	'ZZ7MASTER'	,				, _oStruZZ7 )
_oModel:AddGrid(	'ZZ8DETAIL'	, 'ZZ7MASTER'	, _oStruZZ8 )

_oModel:SetRelation( 'ZZ8DETAIL', { { 'ZZ8_FILIAL' , 'xFilial( "ZZ8" )' } , { 'ZZ8_CODUSR' , 'ZZ7_CODUSR' } } , ZZ8->( IndexKey(1) ) )

_oModel:SetDescription( 'Cadastro de Aprovadores de Solicitacao de Compra' )

_oModel:GetModel( 'ZZ7MASTER' ):SetDescription( 'Dados Aprovador'	)
_oModel:GetModel( 'ZZ8DETAIL' ):SetDescription( 'Centro de Custo'	)

_oModel:GetModel( 'ZZ8DETAIL' ):SetUniqueLine( { 'ZZ8_CC' } )
_oModel:GetModel( 'ZZ8DETAIL' ):SetOptional( .T. )

_oModel:SetPrimaryKey( {'ZZ7_FILIAL','ZZ7_CODUSR' } )

Return( _oModel )

/*
===============================================================================================================================
Programa----------: ViewDef
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 31/07/2015                                    .
Descri��o---------: Rotina para montar a View de Dados para exibi��o.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ViewDef()
Local _oModel	:= FWLoadModel( 'ACOM001' )
Local _oStruZZ7	:= FWFormStruct( 2 , 'ZZ7' )
Local _oStruZZ8	:= FWFormStruct( 2 , 'ZZ8' )
Local _oView	:= FWFormView():New()

_oStruZZ8:RemoveField( "ZZ8_CODUSR" )

_oStruZZ7:AddGroup( 'GRUPO01' , 'Dados do Aprovador:', " " , 2 )

_oStruZZ7:SetProperty( 'ZZ7_CODUSR'	, MVC_VIEW_GROUP_NUMBER , "GRUPO01" )
_oStruZZ7:SetProperty( 'ZZ7_USER'	, MVC_VIEW_GROUP_NUMBER , "GRUPO01" )
_oStruZZ7:SetProperty( 'ZZ7_NOME'	, MVC_VIEW_GROUP_NUMBER , "GRUPO01" )
_oStruZZ7:SetProperty( 'ZZ7_TIPO' 	, MVC_VIEW_GROUP_NUMBER , "GRUPO01" )
_oStruZZ7:SetProperty( 'ZZ7_STATUS'	, MVC_VIEW_GROUP_NUMBER , "GRUPO01" )
_oStruZZ7:SetProperty( 'ZZ7_APRSUB'	, MVC_VIEW_GROUP_NUMBER , "GRUPO01" )
_oStruZZ7:SetProperty( 'ZZ7_USRSUB'	, MVC_VIEW_GROUP_NUMBER , "GRUPO01" )
_oStruZZ7:SetProperty( 'ZZ7_NOMESU'	, MVC_VIEW_GROUP_NUMBER , "GRUPO01" )
_oStruZZ7:SetProperty( 'ZZ7_DTSUBI'	, MVC_VIEW_GROUP_NUMBER , "GRUPO01" )
_oStruZZ7:SetProperty( 'ZZ7_DTSUBF'	, MVC_VIEW_GROUP_NUMBER , "GRUPO01" )

_oView:SetModel( _oModel )

_oView:AddField(	'VIEW_CAB'	, _oStruZZ7	, 'ZZ7MASTER'	)
_oView:AddGrid(		'VIEW_DET'	, _oStruZZ8	, 'ZZ8DETAIL'	)

_oView:CreateHorizontalBox( 'SUPERIOR'	, 50 )
_oView:CreateHorizontalBox( 'INFERIOR'	, 50 )

_oView:SetOwnerView( 'VIEW_CAB'	, 'SUPERIOR'	)
_oView:SetOwnerView( 'VIEW_DET'	, 'INFERIOR'	)

_oView:EnableTitleView( 'VIEW_DET' , 'Centro de Custo:' )

Return( _oView )

/*
===============================================================================================================================
Programa----------: ACOM001VLD
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 31/07/2015                                    .
Descri��o---------: Rotina para valida��o dos campos SX3
Parametros--------: Nenhum
Retorno-----------: _lRet -> .T. - Continua processo / .F. - n�o permite continua��o do processo
===============================================================================================================================

sdasdasdasd alsdalsdkalkjsd lajsld ajlsdjkasdasd
asdasdja 
sdasd
asdasda
sd a
sd
asdasda jsda
jsdiajsdpiajsd 
asda
sdapsjd asidasd 



*/
User Function ACOM001VLD()
Local _aArea		:= GetArea()
Local _aSave		:= FwSaveRows()
Local _cCampo		:= ReadVar()
Local _lRet			:= .T.
Local _cQry			:= ""
Local _cQryC		:= ""
Local _cAlias		:= GetNextAlias()
Local _nI			:= 0
Local _oModel		:= FWModelActive()
Local _oModelZZ8	:= _oModel:GetModel('ZZ8DETAIL')
Local _aInfHlp		:= {}

If 'ZZ7_TIPO' $ _cCampo
	If M->ZZ7_TIPO == 'S'
		M->ZZ7_APRSUB	:= Space(TamSX3("ZZ7_APRSUB")[1])
		M->ZZ7_USRSUB	:= Space(TamSX3("ZZ7_USRSUB")[1])
		M->ZZ7_NOMESU	:= Space(TamSX3("ZZ7_NOMESU")[1])
		M->ZZ7_DTSUBI	:= CtoD('//')
		M->ZZ7_DTSUBF	:= CtoD('//')
		M->ZZ7_STATUS	:= "N"
		
		_cQry := "SELECT COUNT(*) AS USADO "
		_cQry += "FROM " + RetSqlName("SC1") + " "
		_cQry += "WHERE C1_FILIAL = '" + xFilial("SC1") + "' "
		_cQry += "  AND C1_I_CODAP = '" + M->ZZ7_CODUSR + "' "
		_cQry += "  AND C1_APROV = 'B' "
		_cQry += "  AND D_E_L_E_T_ = ' ' "
		_cQry := ChangeQuery(_cQry)
		MPSysOpenQuery(_cQry,_cAlias)
		
		(_cAlias)->( dbGotop() )
		If (_cAlias)->( !Eof() )
			If (_cAlias)->USADO > 0
				_aInfHlp := {}
				//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
				aAdd( _aInfHlp , { "Altera��o de Tipo n�o permitido Aprov"		, "ador possui SC pendente.               "	} )
				aAdd( _aInfHlp , { "Por favor verificar SC's.            "		, "                                       "	} )
			
				U_ITCADHLP( _aInfHlp , "ACOM00107",.F. )
				
				U_ITMSG("Altera��o de Tipo n�o permitido Aprovador possui SC pendente.",;
		                "Aten��o",;
		                "Por favor verificar SC's.",3, , , .T.)
			
				_lRet := .F.
			Else
				For _nI := 1 To _oModelZZ8:Length()
					_oModelZZ8:GoLine(_nI)
					_oModelZZ8:DeleteLine()
				Next _nI
			EndIf
		Else
			For _nI := 1 To _oModelZZ8:Length()
				_oModelZZ8:GoLine(_nI)
				_oModelZZ8:DeleteLine()
			Next _nI
		EndIf
		
	EndIf
ElseIf 'ZZ7_STATUS' $ _cCampo
	If M->ZZ7_TIPO == 'S' .And. M->ZZ7_STATUS == 'A'
	
		_aInfHlp := {}
		//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
		aAdd( _aInfHlp , { "Para o tipo Solicitante, somente poder�o"	, " ser selecionado as situa��es N ou B."	} )
		aAdd( _aInfHlp , { "Favor selecionar uma op��o v�lida.  "		, ""										} )
				
		U_ITCADHLP( _aInfHlp , "ACOM00101",.F. )
		
		U_ITMSG("Para o tipo Solicitante, somente poder�o ser selecionado as situa��es N ou B.",;
		        "Aten��o",;
		        "Por favor verificar SC's.",3, , , .T.)

		_lRet := .F.
	EndIf
	If M->ZZ7_TIPO == 'A' .And. M->ZZ7_STATUS == 'N'
		M->ZZ7_APRSUB	:= Space(TamSX3("ZZ7_APRSUB")[1])
		M->ZZ7_USRSUB	:= Space(TamSX3("ZZ7_USRSUB")[1])
		M->ZZ7_NOMESU	:= Space(TamSX3("ZZ7_NOMESU")[1])
		M->ZZ7_DTSUBI	:= CtoD('//')
		M->ZZ7_DTSUBF	:= CtoD('//')
	EndIf
	If M->ZZ7_TIPO == 'A' .And. M->ZZ7_STATUS == 'B'
		For _nI := 1 To _oModelZZ8:Length()
			_oModelZZ8:GoLine(_nI)
			_oModelZZ8:LoadValue( 'ZZ8_MSBLQL' , '1' )
		Next _nI
	EndIf
ElseIf 'ZZ7_DTSUBI' $ _cCampo
	If !(Empty(M->ZZ7_DTSUBF))
		If M->ZZ7_DTSUBI > M->ZZ7_DTSUBF

			_aInfHlp := {}
			//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
			aAdd( _aInfHlp , { "A data in�cio n�o pode ser maior que a "	, "data final.                          "	} )
			aAdd( _aInfHlp , { "Favor selecionar uma data v�lida.      "	, ""                                        } )
				
			U_ITCADHLP( _aInfHlp , "ACOM00102",.F. )
			
			U_ITMSG("A data in�cio n�o pode ser maior que a data final. ",;
		            "Aten��o",;
		            "Favor selecionar uma data v�lida.",3, , , .T.)

			_lRet := .F.
		EndIf
	EndIf
ElseIf 'ZZ7_DTSUBF' $ _cCampo
	If !(Empty(M->ZZ7_DTSUBF))
		If M->ZZ7_DTSUBF < M->ZZ7_DTSUBI

			_aInfHlp := {}
			//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
			aAdd( _aInfHlp , { "A data final n�o pode ser menor que a "	, "data inicio.                          "	} )
			aAdd( _aInfHlp , { "Favor selecionar uma data v�lida.      "	, ""                                    } )
				
			U_ITCADHLP( _aInfHlp , "ACOM00103",.F. )
			
			U_ITMSG("A data final n�o pode ser menor que a data inicio. ",;
		            "Aten��o",;
		            "Favor selecionar uma data v�lida. ",3, , , .T.)
			

			_lRet := .F.
		EndIf
	EndIf
ElseIf 'ZZ7_CODUSR' $ _cCampo
	If !EMPTY(M->ZZ7_CODUSR)
		_lRet := UsrExist(M->ZZ7_CODUSR)
		If _lRet
			M->ZZ7_USER := UsrRetName(M->ZZ7_CODUSR)
			M->ZZ7_NOME := UsrFullName(M->ZZ7_CODUSR)
		EndIf
	EndIf
ElseIf 'ZZ7_APRSUB' $ _cCampo
	If !EMPTY(M->ZZ7_APRSUB)
		_lRet := UsrExist(M->ZZ7_APRSUB)
		If _lRet
			M->ZZ7_USRSUB := UsrRetName(M->ZZ7_APRSUB)
			M->ZZ7_NOMESU := UsrFullName(M->ZZ7_APRSUB)
		EndIf
	EndIf
ElseIf 'ZZ8_CC' $ _cCampo
	dbSelectArea("CTT") 
	CTT->(dbSetOrder(1))
	If CTT->(dbseek(xFilial("CTT") + _oModelZZ8:GetValue("ZZ8_CC")))
		_oModelZZ8:LoadValue( 'ZZ8_DESCCC', CTT->CTT_DESC01 )
	Else
		aInfHlp := {}
		//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
		aAdd( _aInfHlp , { "O Centro de custo digitado n�o existe."	, "                                      "	} )
		aAdd( _aInfHlp , { "Favor digitar um CC correto, ou acessar"	, " a consulta via [F3]"                } )
				
		U_ITCADHLP( _aInfHlp , "ACOM00110",.F. )
		
		U_ITMSG("O Centro de custo digitado n�o existe.",;
		        "Aten��o",;
		        "Favor digitar um CC correto, ou acessar a consulta via [F3]",3, , , .T.)

		_lRet := .F.
	EndIf
ElseIf 'ZZ8_MSBLQL' $ _cCampo
	If M->ZZ8_MSBLQL == '2'
		_cQry := "SELECT COUNT(*) AS USADO "
		_cQry += "FROM " + RetSqlName("ZZ8") + " "
		_cQry += "WHERE ZZ8_FILIAL = '" + xFilial("ZZ8") + "' "
		_cQry += "  AND ZZ8_CODUSR <> '" + ZZ7_CODUSR + "' "
		_cQry += "  AND ZZ8_CC = '" + _oModelZZ8:GetValue("ZZ8_CC")  + "' "   
		_cQry += "  AND ZZ8_MSBLQL = '2' "
		_cQry += "  AND D_E_L_E_T_ = ' ' "
		_cQry := ChangeQuery(_cQry)
		MPSysOpenQuery(_cQry,_cAlias)
		
		(_cAlias)->( dbGotop() )

		If (_cAlias)->( !Eof() )
			If (_cAlias)->USADO > 0
				_cQryC := "SELECT ZZ8_CODUSR AS APROV "
				_cQryC += "FROM " + RetSqlName("ZZ8") + " "
				_cQryC += "WHERE ZZ8_FILIAL = '" + xFilial("ZZ8") + "' "
				_cQryC += "  AND ZZ8_CODUSR <> '" + ZZ7_CODUSR + "' "
				_cQryC += "  AND ZZ8_CC = '" +  _oModelZZ8:GetValue("ZZ8_CC") + "' "  
				_cQryC += "  AND ZZ8_MSBLQL = '2' "
				_cQryC += "  AND D_E_L_E_T_ = ' ' "
				_cQryC := ChangeQuery(_cQryC)
				MPSysOpenQuery(_cQryC,"TRBCAD")
				
				TRBCAD->( dbGotop() )
		
				If TRBCAD->( !Eof() )
					_aInfHlp := {}
					//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
					aAdd( _aInfHlp , { "Centro de Custo j� informado em outro "		, "cadastro. Aprov: " + TRBCAD->APROV + ".   "		} )
					aAdd( _aInfHlp , { "Favor verificar Centro de Custo infor-"		, "mado.                            "				} )
	
					U_ITCADHLP( _aInfHlp , "ACOM00108",.F. )
					
					U_ITMSG("Centro de Custo j� informado em outro cadastro. Aprov: " + TRBCAD->APROV + ".",;
		                    "Aten��o",;
		                    "Favor verificar Centro de Custo informado.",3, , , .T.)
	
					_lRet := .F.
				EndIf

				TRBCAD->( dbCloseArea() )
			EndIf
		EndIf

		(_cAlias)->( dbCloseArea() )

		If M->ZZ7_STATUS == "B"
			_aInfHlp := {}
			//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
			aAdd( _aInfHlp , { "Centro de Custo n�o pode ser desbloque"		, "ado, pois Aprovador est� bloqueado.    "	} )
			aAdd( _aInfHlp , { "Favor verificar Centro de Custo infor-"		, "mado.                                  "	} )
	
			U_ITCADHLP( _aInfHlp , "ACOM00112",.F. )
			
			U_ITMSG("Centro de Custo n�o pode ser desbloqueado, pois Aprovador est� bloqueado. ",;
		            "Aten��o",;
		            "Favor verificar Centro de Custo informado.  ",3, , , .T.)
	
			_lRet := .F.
		EndIf

	EndIf
	
EndIf

FwRestRows(_aSave)
RestArea(_aArea)
Return(_lRet)

/*
===============================================================================================================================
Programa----------: VALIDCOMIT
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 31/07/2015                                    .
Descri��o---------: Rotina para valida��o de valida��o TudoOk, valida as informa��es da tela antes de salvar o registro.
Parametros--------: _oModel -> Modelo de Dados
Retorno-----------: _lRet -> .T. - Continua processo / .F. - n�o permite continua��o do processo
===============================================================================================================================
*/
Static Function VALIDCOMIT(_oModel)
Local _aArea		:= GetArea()
Local _aSave		:= FwSaveRows()
Local _aInfHlp		:= {}
Local _lRet			:= .T.
Local _cCodUsr		:= _oModel:GetValue( 'ZZ7MASTER' , 'ZZ7_CODUSR' )
Local _cTipo		:= _oModel:GetValue( 'ZZ7MASTER' , 'ZZ7_TIPO' 	)
Local _cStatus		:= _oModel:GetValue( 'ZZ7MASTER' , 'ZZ7_STATUS' )
Local _cAprSub		:= _oModel:GetValue( 'ZZ7MASTER' , 'ZZ7_APRSUB'	)
Local _dDtSubI		:= _oModel:GetValue( 'ZZ7MASTER' , 'ZZ7_DTSUBI' )
Local _dDtSubF		:= _oModel:GetValue( 'ZZ7MASTER' , 'ZZ7_DTSUBF'	)
Local _nOper		:= _oModel:GetOperation()
Local _oModelZZ8	:= _oModel:GetModel('ZZ8DETAIL')
Local _cQry			:= ""
Local _cAlias		:= GetNextAlias()
Local _cQryC		:= ""
Local _nI			:= 0
Local _nJ			:= 0
Local _nTam			:= 0

If _nOper == MODEL_OPERATION_INSERT
	dbSelectArea("ZZ7")
	dbSetOrder(1)
	If dbSeek(xFilial("ZZ7") + _cCodUsr)
		_aInfHlp := {}
		//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
		aAdd( _aInfHlp , { "C�digo do Aprovador/Solicitante infor"		, "mado j� consta no cadastro.      "		} )
		aAdd( _aInfHlp , { "Verique o c�digo digitado ou acesse o"		, " cadastro via [F3].              "		} )
	
		U_ITCADHLP( _aInfHlp , "ACOM00114",.F. )
		
		U_ITMSG("C�digo do Aprovador/Solicitante informado j� consta no cadastro. ",;
		        "Aten��o",;
		        "Verique o c�digo digitado ou acesse o cadastro via [F3].  ",3 , , , .T.)
	
		_lRet := .F.
	EndIf

	If !UsrExist(_cCodUsr)
	
		_aInfHlp := {}
		//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
		aAdd( _aInfHlp , { "C�digo do Aprovador/Solicitante infor"		, "mado est� incorreto.             "		} )
		aAdd( _aInfHlp , { "Verique o c�digo digitado ou acesse o"		, " cadastro via [F3].              "		} )
	
		U_ITCADHLP( _aInfHlp , "ACOM00104",.F. )
		
		U_ITMSG("C�digo do Aprovador/Solicitante informado est� incorreto. ",;
		        "Aten��o",;
		        "Verique o c�digo digitado ou acesse o cadastro via [F3].",3 , , , .T.)
	
		_lRet := .F.
	
	EndIf
	
	If _cTipo == "A" .And. _cStatus == "A" .And. (Empty(_cAprSub) .Or. Empty(_dDtSubI) .Or. Empty(_dDtSubF))
	
		_aInfHlp := {}
		//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
		aAdd( _aInfHlp , { "Para Aprovador com status ausente,   "		, "informar substituto.             "		} )
		aAdd( _aInfHlp , { "Digite todas as informa��es do apro- "		, "vador subistituto.               "		} )
	
		U_ITCADHLP( _aInfHlp , "ACOM00105",.F. )
		
		U_ITMSG("Para Aprovador com status ausente, informar substituto. ",;
		        "Aten��o",;
		        "Digite todas as informa��es do aprovador subistituto.",3, , , .T.)
	
		_lRet := .F.
	
	EndIf
	For _nI := 1 To _oModelZZ8:Length()
		_oModelZZ8:Goline(_nI)
		If !_oModelZZ8:IsDeleted()
			dbSelectArea("CTT")
			CTT->(dbSetOrder(1))
			If CTT->(dbSeek(xFilial("CTT") + _oModelZZ8:GetValue("ZZ8_CC")))
				If CTT->CTT_BLOQ <> "2"
					_aInfHlp := {}
					//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
					aAdd( _aInfHlp , { "Centro de Custo informado est� bloqueado"	, ". Linha: " + AllTrim(Str(_nI)) + "              "		} )
					aAdd( _aInfHlp , { "Favor selecione um Centro de Custo   "		, "v�lido.                          "		} )
	
					U_ITCADHLP( _aInfHlp , "ACOM00106",.F. )
					
					U_ITMSG("Centro de Custo informado est� bloqueado. Linha: " + AllTrim(Str(_nI)) + ". ",; 
		                    "Aten��o",; 
		                    "Favor selecione um Centro de Custo v�lido. ", 3, , ,.T.) 
	
					_lRet := .F.
				EndIf
			EndIf
			_cQryC := "SELECT COUNT(*) AS CONTADOR "
			_cQryC += "FROM " + RetSqlName("ZZ8") + " "
			_cQryC += "WHERE ZZ8_CC = '" + _oModelZZ8:GetValue("ZZ8_CC") + "' "  
			_cQryC += "  AND ZZ8_CODUSR <> '" + _cCodUsr + "' "
			_cQryC += "  AND ZZ8_MSBLQL = '2' "
			_cQryC += "  AND D_E_L_E_T_ = ' ' "
			_cQryC := ChangeQuery(_cQryC)
			MPSysOpenQuery(_cQryC,"TRBCC")

			TRBCC->(dbGoTop())
			
			If TRBCC->CONTADOR > 0
				
				_aInfHlp := {}
				//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
				aAdd( _aInfHlp , { "Centro de Custo j� informado em outro "		, "cadastro.                        "		} )
				aAdd( _aInfHlp , { "Favor verificar Centro de Custo in-  "		, "formado.                         "		} )
	
				U_ITCADHLP( _aInfHlp , "ACOM00108", .F. )

				U_ITMSG("Centro de Custo j� informado em outro cadastro. ",;
		                "Aten��o",;
		                "Favor verificar Centro de Custo informado. ",3, , , .T.)
	
				_lRet := .F.
				
			EndIf
	
			TRBCC->(dbCloseArea())
		EndIf
	Next _nI

ElseIf _nOper == MODEL_OPERATION_UPDATE
	If !UsrExist(_cCodUsr)
	
		_aInfHlp := {}
		//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
		aAdd( _aInfHlp , { "C�digo do Aprovador/Solicitante infor"		, "mado est� incorreto.             "		} )
		aAdd( _aInfHlp , { "Verique o c�digo digitado ou acesse o"		, " cadastro via [F3].              "		} )
	
		U_ITCADHLP( _aInfHlp , "ACOM00104", .F. )
		
		U_ITMSG("C�digo do Aprovador/Solicitante informado est� incorreto. ",;
		        "Aten��o",;
		        "Verique o c�digo digitado ou acesse o cadastro via [F3]. ",3, , , .T.)
	
		_lRet := .F.
	
	EndIf

	If _cTipo == "A" .And. _cStatus == "A" .And. (Empty(_cAprSub) .Or. Empty(_dDtSubI) .Or. Empty(_dDtSubF))
	
		_aInfHlp := {}
		//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
		aAdd( _aInfHlp , { "Para Aprovador com status ausente,   "		, "informar substituto.             "		} )
		aAdd( _aInfHlp , { "Digite todas as informa��es do apro- "		, "vador subistituto.               "		} )
	
		U_ITCADHLP( _aInfHlp , "ACOM00105", .F. )
		
		U_ITMSG("Para Aprovador com status ausente, informar substituto. ",;
		        "Aten��o",;
		        "Digite todas as informa��es do aprovador subistituto. ",3, , , .T.)
	
		_lRet := .F.
	
	EndIf

	For _nI := 1 To _oModelZZ8:Length()
		_oModelZZ8:Goline(_nI)
		If !_oModelZZ8:IsDeleted()
			CTT->(dbSetOrder(1))
			If CTT->(dbSeek(xFilial("CTT") + _oModelZZ8:GetValue("ZZ8_CC")))
				If CTT->CTT_BLOQ <> "2"
					_aInfHlp := {}
					//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
					aAdd( _aInfHlp , { "Centro de Custo informado est� bloqueado"	, ". Linha: " + AllTrim(Str(_nI)) + "              "		} )
					aAdd( _aInfHlp , { "Favor selecione um Centro de Custo   "		, "v�lido.                          "		} )
	
					U_ITCADHLP( _aInfHlp , "ACOM00106", .F. )
					
					U_ITMSG("Centro de Custo informado est� bloqueado. Linha: " + AllTrim(Str(_nI)) + ". ",;
		                    "Aten��o",;
		                    "Favor selecione um Centro de Custo v�lido. ",3, , , .T.)
	
					_lRet := .F.
				EndIf
			EndIf
			_cQryC := "SELECT COUNT(*) AS CONTADOR "
			_cQryC += "FROM " + RetSqlName("ZZ8") + " "
			_cQryC += "WHERE ZZ8_CC = '" + _oModelZZ8:GetValue("ZZ8_CC") + "' " 
			_cQryC += "  AND ZZ8_CODUSR <> '" + _cCodUsr + "' "
			_cQryC += "  AND ZZ8_MSBLQL = '2' "
			_cQryC += "  AND D_E_L_E_T_ = ' '
			_cQryC := ChangeQuery(_cQryC)
			MPSysOpenQuery(_cQryC,"TRBCC")

			TRBCC->(dbGoTop())
			
			If TRBCC->CONTADOR > 0
				If _cStatus <> "B" .And. _oModelZZ8:GetValue("ZZ8_MSBLQL") <> '1'
					_aInfHlp := {}
					//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
					aAdd( _aInfHlp , { "Centro de Custo j� informado em outro "		, "cadastro.                        "		} )
					aAdd( _aInfHlp , { "Favor verificar Centro de Custo in-  "		, "formado.                         "		} )
	
					U_ITCADHLP( _aInfHlp , "ACOM00109", .F. )
					
					U_ITMSG("Centro de Custo j� informado em outro cadastro. ",;
		                    "Aten��o",;
		                    "Favor verificar Centro de Custo informado. ",3, , , .T.)
	
					_lRet := .F.
				EndIf
				
			EndIf
	
			TRBCC->(dbCloseArea())
		EndIf
	Next _nI

	For _nJ := 1 To _oModelZZ8:Length()
		_oModelZZ8:Goline(_nJ)
		If _oModelZZ8:IsUpdated()
			dbSelectArea("ZZ8")
			ZZ8->(dbSetOrder(1))
			If !ZZ8->(dbSeek(_oModelZZ8:GetValue("ZZ8_FILIAL") + _oModelZZ8:GetValue("ZZ8_CODUSR") + _oModelZZ8:GetValue("ZZ8_CC"))) .And. !Empty(_oModelZZ8:GetValue("ZZ8_FILIAL")) .And. !Empty(_oModelZZ8:GetValue("ZZ8_CODUSR"))
				_aInfHlp := {}
				//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
				aAdd( _aInfHlp , { "Altera��o n�o permitida. Centro de Cu-"		, "sto " + _oModelZZ8:GetValue("ZZ8_CC") + "                              "	} )
				aAdd( _aInfHlp , { "Bloqueie ou delete o registro.       "		, "                                       "	} )
			
				U_ITCADHLP( _aInfHlp , "ACOM00111", .F. )
				
				U_ITMSG("Altera��o n�o permitida. Centro de Custo " + _oModelZZ8:GetValue("ZZ8_CC") + ". ",;
		                "Aten��o",;
		                "Bloqueie ou delete o registro.",3, , , .T.)
			
				_lRet := .F.
			EndIf
		EndIf
		If _oModelZZ8:IsDeleted()
			_nTam := Len(AllTrim(_oModelZZ8:GetValue("ZZ8_CC")))
			_cQry := "SELECT COUNT(*) AS USADO "
			_cQry += "FROM " + RetSqlName("SC1") + " "
			_cQry += "WHERE C1_FILIAL = '" + xFilial("SC1") + "' "
			_cQry += "  AND C1_I_CODAP = '" + ZZ7_CODUSR + "' "
			_cQry += "  AND SUBSTR(C1_CC,1," + AllTrim(Str(_nTam)) + ") = '" + AllTrim(_oModelZZ8:GetValue("ZZ8_CC")) + "' "
			_cQry += "  AND D_E_L_E_T_ = ' ' "
			_cQry := ChangeQuery(_cQry)
			MPSysOpenQuery(_cQry,"TRBCC")
			
			TRBCC->( dbGotop() )
			If TRBCC->( !Eof() )
				If TRBCC->USADO > 0
					_aInfHlp := {}
					//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
					aAdd( _aInfHlp , { "Exclus�o n�o permitida C. Custo j�   "		, "utilizado em solicita��o.              "	} )
					aAdd( _aInfHlp , { "Se necess�rio alterar o campo Bloquei-"		, "o para SIM.                      "		} )
				
					U_ITCADHLP( _aInfHlp , "ACOM00113",.F. )
					
					U_ITMSG("Exclus�o n�o permitida C. Custo j� utilizado em solicita��o. ",;
		                    "Aten��o",;
		                    "Se necess�rio alterar o campo Bloqueio para SIM.",3, , , .T.)
				
					_lRet := .F.
				EndIf
			EndIf
			TRBCC->( dbCloseArea() )
		EndIf
	Next _nJ
ElseIf _nOper == MODEL_OPERATION_DELETE
	_cQry := "SELECT COUNT(*) AS USADO "
	_cQry += "FROM " + RetSqlName("SC1") + " "
	_cQry += "WHERE C1_FILIAL = '" + xFilial("SC1") + "' "
	_cQry += "  AND C1_I_CODAP = '" + ZZ7_CODUSR + "' "
	_cQry += "  AND D_E_L_E_T_ = ' ' "
	_cQry := ChangeQuery(_cQry)
	MPSysOpenQuery(_cQry,_cAlias)
	
	(_cAlias)->( dbGotop() )
	If (_cAlias)->( !Eof() )
		If (_cAlias)->USADO > 0
			_aInfHlp := {}
			//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
			aAdd( _aInfHlp , { "Exclus�o n�o permitida Aprovador/Soli-"		, "citante j� utilizado em Sol. de Compra."	} )
			aAdd( _aInfHlp , { "Se necess�rio alterar o campo Bloquei-"		, "o para SIM.                      "		} )
		
			U_ITCADHLP( _aInfHlp , "ACOM00104", .F. )
			
			U_ITMSG("Exclus�o n�o permitida Aprovador/Solicitante j� utilizado em Sol. de Compra.",;
		            "Aten��o",;
		            "Se necess�rio alterar o campo Bloqueio para SIM. ",3, , , .T.)
		
			_lRet := .F.
		EndIf
	EndIf
EndIf

RestArea(_aArea)

FwRestRows(_aSave)

//======================================================================
// Grava log de Inclus�o/Altera��o/Exclus�o do Cadastro de Aprovadores 
// e Solicitantes de solicita��es de compras.
//====================================================================== 
U_ITLOGACS('VALIDCOMIT')

Return(_lRet)

/*
===============================================================================================================================
Programa----------: ACOM001C
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 31/07/2015                                    .
Descri��o---------: Rotina escrita para fazer a c�pia dos diretiros de um registro para o outro.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM001C()
Local _aArea	:= GetArea()
Local _cGetApo	:= Space(TamSX3("ZZ7_CODUSR")[1])
Local _cGetDst	:= Space(TamSX3("ZZ7_CODUSR")[1])
Local _cGetNao	:= Space(TamSX3("ZZ7_NOME")[1])
Local _cGetNds	:= Space(TamSX3("ZZ7_NOME")[1])
Local _cGetSao	:= Space(TamSX3("ZZ7_STATUS")[1])
Local _cGetSds	:= Space(TamSX3("ZZ7_STATUS")[1])
Local _nOpca	:= 0
Local _cQry		:= ""
Local _cQryC	:= ""
Local _cMsg		:= ""
Local _cAlias	:= GetNextAlias()

Local _oGetApo
Local _oGetDst
Local _oGetNao
Local _oGetNds
Local _oGetSao
Local _oGetSds

Local _oSayDst
Local _oSayApo
Local _oSayNao
Local _oSayNds
Local _oSaySao
Local _oSaySds
Local _oSButtonCn
Local _oSButtonOk

Private _oDlg

DEFINE MSDIALOG _oDlg TITLE "C�pia de direitos" FROM 000, 000  TO 170, 475 COLORS 0, 16777215 PIXEL

	@ 005, 006 SAY _oSayApo	PROMPT "Aprovador Origem:"	SIZE 046, 007 OF _oDlg COLORS 16711680, 16777215	PIXEL
	@ 017, 006 MSGET _oGetApo VAR _cGetApo SIZE 050, 010 OF _oDlg VALID VldInf(@_cGetApo,@_cGetNao,@_cGetSao,1) COLORS 0, 16777215 F3 "ZZ7APO"	PIXEL

	@ 005, 066 SAY _oSayNao	PROMPT "Nome:"				SIZE 025, 007 OF _oDlg COLORS 0, 16777215	PIXEL
	@ 017, 066 MSGET _oGetNao VAR _cGetNao SIZE 128, 010 OF _oDlg COLORS 0, 16777215 READONLY	PIXEL

	@ 005, 206 SAY _oSaySao	PROMPT "Situa��o:"			SIZE 025, 007 OF _oDlg COLORS 0, 16777215	PIXEL
	@ 017, 206 MSGET _oGetSao VAR _cGetSao SIZE 020, 010 OF _oDlg COLORS 0, 16777215 READONLY	PIXEL

	@ 033, 006 SAY _oSayDst	PROMPT "Aprovador Destino:"	SIZE 048, 007 OF _oDlg COLORS 16711680, 16777215	PIXEL
	@ 045, 006 MSGET _oGetDst VAR _cGetDst SIZE 050, 010 OF _oDlg VALID VldInf(@_cGetDst,@_cGetNds,@_cGetSds,2) COLORS 0, 16777215 F3 "ZZ7DST"	PIXEL

	@ 033, 066 SAY _oSayNds	PROMPT "Nome:"				SIZE 025, 007 OF _oDlg COLORS 0, 16777215	PIXEL
	@ 045, 066 MSGET _oGetNds VAR _cGetNds SIZE 128, 010 OF _oDlg COLORS 0, 16777215 READONLY	PIXEL

	@ 033, 206 SAY _oSaySds	PROMPT "Situa��o:"			SIZE 025, 007 OF _oDlg COLORS 0, 16777215	PIXEL
	@ 045, 206 MSGET _oGetSds VAR _cGetSds SIZE 020, 010 OF _oDlg COLORS 0, 16777215 READONLY	PIXEL
	
	DEFINE SBUTTON _oSButtonOk FROM 065, 085 TYPE 01 OF _oDlg ENABLE ACTION (_nOpca := 1, _oDlg:End())
	DEFINE SBUTTON _oSButtonCn FROM 065, 118 TYPE 02 OF _oDlg ENABLE ACTION _oDlg:End()

ACTIVATE MSDIALOG _oDlg CENTERED

If _nOpca == 1
	_cQry := "SELECT ZZ8_CC,ZZ8_CODUSR,ZZ8_MSBLQL "
	_cQry += "FROM " + RetSqlName("ZZ8") + " "
	_cQry += "WHERE ZZ8_FILIAL = '" + xFilial("ZZ8") + "' "
	_cQry += "  AND ZZ8_CODUSR = '" + _cGetApo + "' "
	_cQry += "  AND D_E_L_E_T_ = ' '
	_cQry := ChangeQuery(_cQry)
	MPSysOpenQuery(_cQry,_cAlias)

	(_cAlias)->( dbGotop() )
	If (_cAlias)->( !Eof() )
		While (_cAlias)->( !Eof() )
			dbSelectArea("ZZ8")
			ZZ8->(dbSetOrder(1))
			ZZ8->(dbSeek(xFilial("ZZ8") + _cGetDst))
			
			_cQryC := "SELECT COUNT(*) AS CONTADOR "
			_cQryC += "FROM " + RetSqlName("ZZ8") + " "
			_cQryC += "WHERE ZZ8_CC = '" + (_cAlias)->ZZ8_CC + "' "
			_cQryC += "  AND ZZ8_CODUSR <> '" + _cGetApo + "' "
			_cQryC += "  AND D_E_L_E_T_ = ' '
			_cQryC := ChangeQuery(_cQryC)
			MPSysOpenQuery(_cQryC,"TRBCC")
			
			TRBCC->(dbGoTop())
			
			If TRBCC->CONTADOR > 0
				_cMsg += "O Centro de custo " + AllTrim((_cAlias)->ZZ8_CC) + ", j� est� sendo utilizado em outro cadastro."
			Else
				RecLock("ZZ8", .T.)
					ZZ8->ZZ8_FILIAL	:= xFilial("ZZ8")
					ZZ8->ZZ8_CODUSR	:= _cGetDst
					ZZ8->ZZ8_CC		:= (_cAlias)->ZZ8_CC
					ZZ8->ZZ8_MSBLQL	:= "2"
				ZZ8->(MsUnLock())
			EndIf
			
			TRBCC->(dbCloseArea())
			
			(_cAlias)->( dbSkip() )
		End
		If !Empty(_cMsg)
			U_ITMSG(_cMsg,;
            "Aten��o", ,3, , , .T.)
		EndIf
	EndIf

	(_cAlias)->( dbCloseArea() )
	
   //===============================================================
   // Grava log da c�pia dos diretiros de um registro para o outro.
   //=============================================================== 
   U_ITLOGACS('ACOM001C')
Else
   U_ITMSG('Opera��o cancelada pelo usu�rio.',;
           "Aten��o", ,3, , , .T.)
EndIf

RestArea(_aArea)

Return

/*
===============================================================================================================================
Programa----------: VldInf
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 31/07/2015                                    .
Descri��o---------: Rotina de valida��o das informa��es digitas na tela de c�pia, e preenchimento dos campos virtuais
Parametros--------: _cCodUsr = C�digo do usu�rio aprovador.
                    _cNomeAp = Nome do aprovador
                    _cSituac = Situa��o / Status
                    _nCampo  = 1 = Aprovador de Origem / 2 = Aprovador de destino.
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function VldInf(_cCodUsr,_cNomeAp,_cSituac,_nCampo)
Local _aArea		:= GetArea()
Local _lRet			:= .T.
Local _cAprov		:= ""

If !Empty(_cCodUsr)
	dbSelectArea("ZZ7")
	ZZ7->(dbSetOrder(1))
	If ZZ7->(dbSeek(xFilial("ZZ7") + _cCodUsr))
		If _nCampo == 1
			If !(ZZ7->ZZ7_TIPO == "A" .And. ZZ7->ZZ7_STATUS == "B")
			   U_ITMSG("O usu�rio informado n�o est� apto a ser copiado.",;
                       "Aprovador Inv�lido",;
                       "Verificar no cadastro se o usu�rio informado � Aprovador e se est� como Bloqueado.",2, , , .T.) 
				
				_cCodUsr	:= Space(TamSX3("ZZ7_CODUSR")[1])
				_lRet		:= .F.
			Else
				_cNomeAp := ZZ7->ZZ7_NOME
				_cSituac := ZZ7->ZZ7_STATUS
			EndIf
		ElseIf _nCampo == 2
			If !(ZZ7->ZZ7_TIPO == "A" .And. ZZ7->ZZ7_STATUS <> "B")
			   U_ITMSG("O usu�rio informado n�o est� apto a ser copiado.",;
                       "Aprovador Inv�lido",;
                       "Verificar no cadastro se o usu�rio informado � Aprovador e sua situa��o est� diferente de Bloqueado.",2, , , .T.)
				
				_cCodUsr	:= Space(TamSX3("ZZ7_CODUSR")[1])
				_lRet		:= .F.
			Else
				_cNomeAp := ZZ7->ZZ7_NOME
				_cSituac := ZZ7->ZZ7_STATUS
			EndIf
		EndIf
	Else
	   U_ITMSG("C�digo digitado n�o existe no cadastro.",;
               "Aprovador n�o cadastrado",;
               "Favor digitar um c�digo v�lido ou acionar a consulta via tecla [F3].",2, , , .T.)
            
		_lRet := .F.
	EndIf
Else
	If _nCampo == 1
		_cAprov := "Aprovador Origem"
	ElseIf _nCampo == 2
		_cAprov := "Aprovador Destino"
	EndIf

	U_ITMSG("C�digo do " + _cAprov + " n�o preenchido.",;
            "Aprovador Obrigat�rio",;
            "Favor preencher o c�digo do " + _cAprov + ".",2, , , .T.) 
	
	_lRet := .F.
EndIf

RestArea(_aArea)

Return(_lRet)

/*
===============================================================================================================================
Programa----------: ACOM001T
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 08/09/2015
Descri��o---------: Rotina escrita para fazer a transfer�ncia de aprovadores
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM001T()
Local aArea		:= GetArea()
//==========================
// Dados do aprovador origem
//==========================
Local oGpAprO
Local oGAprO
Local cGAprO	:= Space(TamSX3("C1_I_CODAP")[1])
Local oGNomO
Local cGNomO	:= Space(TamSX3("ZZ7_NOME")[1])
Local oGSitO
Local cGSitO	:= Space(TamSX3("ZZ7_STATUS")[1])
Local oSAprO
Local oSNomO
Local oSSitO
//===========================
// Dados do aprovador destino
//===========================
Local oGpAprD
Local oGAprD
Local cGAprD	:= Space(TamSX3("C1_I_CODAP")[1])
Local oGNomD
Local cGNomD	:= Space(TamSX3("ZZ7_NOME")[1])
Local oGSitD
Local cGSitD	:= Space(TamSX3("ZZ7_STATUS")[1])
Local oSAprD
Local oSNomD
Local oSSitD

Local oSay1
Local nOpc		:= 0
Local nI		:= 0
Local nPosNum	:= 0
Local nPosIte	:= 0

Local oSButtonCa
Local oSButtonOk

Private aHeader		:= {}
Private aCols		:= {}

Private oMSNewGD
Private oDlg

//==================================================================
// Valida se o usu�rio corrente est� configurado como adm de compras
//==================================================================
dbSelectArea("ZZL")
ZZL->(dbSetOrder(3)) //ZZL_FILIAL + ZZL_CODUSU
If ZZL->(dbSeek(xFilial("ZZL") + __cUserId))
	If ZZL->ZZL_ADMCAS == "N"
       U_ITMSG(__cUserId + " - " + AllTrim(UsrFullName(__cUserId)) + " sem permiss�o para utilizar esta funcionalidade.",;
               "Transfer�ncia de Aprovador",;
               "Favor comunicar a �rea de Compras, que � respons�vel por solicitar para TI a libera��o desta funcionalidade.",2, , , .T.)
		
		RestArea(aArea)
		Return()
	EndIf
Else
   U_ITMSG(__cUserId + " - " + AllTrim(UsrFullName(__cUserId)) + " sem permiss�o para utilizar esta funcionalidade.",;
           "Transfer�ncia de Aprovador",;
           "Favor comunicar a �rea de Compras, que � respons�vel por solicitar para TI a libera��o desta funcionalidade.",2, , , .T.)
               
	RestArea(aArea)
	Return()
EndIf

// Define field properties
//                     1            2         3           4          5        6        7       8       9       10          11      12        13       14         15        16   17
// aAdd(aHeader,{trim(x3_titulo),x3_campo,x3_picture,x3_tamanho,x3_decimal,x3_valid,x3_usado,x3_tipo, x3_f3,x3_context,	x3_cbox,x3_relacao,x3_when,X3_TRIGGER,	X3_PICTVAR,.F.,.F.})

aCols   := {}  
aHeader := {}
FillGetDados(1,"SC1",1,,,{||.T.},,,,,,.T.)
nUsado := Len(aHeader)

DEFINE MSDIALOG oDlg TITLE "Transfer�ncia Aprovador" FROM 000, 000  TO 600, 1000 COLORS 0, 16777215 PIXEL

	@ 001, 003 GROUP oGpAprO TO 066, 232 PROMPT "Aprovador Origem" OF oDlg COLOR 0, 16777215 PIXEL
    @ 001, 268 GROUP oGpAprD TO 066, 497 PROMPT "Aprovador Destino" OF oDlg COLOR 0, 16777215 PIXEL
	//============================
	//Informa��es Aprovador Origem
	//============================
	@ 014, 006 SAY oSAprO PROMPT "Aprovador Origem?" SIZE 049, 007 OF oDlg COLORS 16711680, 16777215 PIXEL
	@ 023, 006 MSGET oGAprO VAR cGAprO SIZE 045, 010 OF oDlg PICTURE "@!" VALID {||AtuDados("O",cGAprO,@cGSitO,@cGNomO), TransfVld(cGAprO, cGAprD)} COLORS 0, 16777215 F3 "ZZ7TRF" PIXEL
	@ 014, 080 SAY oSSitO PROMPT "Situa��o" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 023, 080 MSGET oGSitO VAR cGSitO SIZE 018, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
	@ 037, 006 SAY oSNomO PROMPT "Nome" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 045, 006 MSGET oGNomO VAR cGNomO SIZE 180, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
	//=============================
	//Informa��es Aprovador Destino
	//=============================
	@ 015, 271 SAY oSAprD PROMPT "Aprovador Destino?" SIZE 049, 007 OF oDlg COLORS 16711680, 16777215 PIXEL
	@ 025, 271 MSGET oGAprD VAR cGAprD SIZE 045, 010 OF oDlg PICTURE "@!" VALID {||AtuDados("D",cGAprD,@cGSitD,@cGNomD), TransfVld(cGAprO, cGAprD)} COLORS 0, 16777215 F3 "ZZ7TRF" PIXEL
	@ 015, 352 SAY oSSitD PROMPT "Situa��o" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 025, 352 MSGET oGSitD VAR cGSitD SIZE 018, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
	@ 038, 271 SAY oSNomD PROMPT "Nome" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 045, 271 MSGET oGNomD VAR cGNomD SIZE 180, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL

	@ 074, 175 SAY oSay1 PROMPT "Solicita��es de Compras Pendentes para o Aprovador Origem" SIZE 150, 013 OF oDlg COLORS 0, 16777088 PIXEL

	oMSNewGD := MsNewGetDados():New( 095, 002, 295, 494, 0, "AllwaysTrue", "AllwaysTrue", "",,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeader, aCols)
	
	DEFINE SBUTTON oSButtonOk FROM 021, 237 TYPE 01 OF oDlg ENABLE ACTION (Iif(TransVldT(cGAprO, cGAprD),(nOpc := 1, oDlg:End()),nOpc := 2))
    DEFINE SBUTTON oSButtonCa FROM 037, 237 TYPE 02 OF oDlg ENABLE ACTION (nOpc := 2, oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

If nOpc == 1
	nPosNum    := aScan(aHeader,{|x| AllTrim(x[2]) == "C1_NUM"	  })
	nPosIte	   := aScan(aHeader,{|x| AllTrim(x[2]) == "C1_ITEM"	  })
	nPosRecSC1 := aScan(aHeader,{|x| AllTrim(x[2]) == "C1_REC_WT" }) 
	
	dbSelectArea("SC1")
	SC1->(dbSetOrder(1))
	For nI := 1 To Len(oMSNewGD:aCols)
	    If nPosNum > 0 .And. nPosIte > 0
		   SC1->(dbSeek(xFilial("SC1") + oMSNewGD:aCols[nI,nPosNum] + oMSNewGD:aCols[nI,nPosIte])) // oMSNewGD:aCols[nI,nPosFil]
		   SC1->(RecLock("SC1", .F.))
		   SC1->C1_I_CODAP :=  cGAprD
		   SC1->(MsUnLock())
		Else
		   If nPosRecSC1 > 0
		      SC1->(DbGoTo(nPosRecSC1))
		      SC1->(RecLock("SC1", .F.))
			  SC1->C1_I_CODAP := cGAprD
		      SC1->(MsUnLock())
		   EndIf 
		EndIf
	Next
	
	U_ITMSG("Transfer�ncia conclu�da com sucesso.",;
            "Transfer�ncia de Aprovador", ,2, , , .T.)
   
   //===============================================================
   // Grava log da transfer�ncia de aprovadores
   //=============================================================== 
   U_ITLOGACS('ACOM001T')        
             
Else
   U_ITMSG("Transfer�ncia n�o foi conclu�da. Favor refazer o processo.",;
           "Transfer�ncia de Aprovador", ,2, , , .T.)
EndIf
	
RestArea(aArea)
Return

/*
===============================================================================================================================
Programa----------: AtuDados
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 08/09/2015                                    .
Descri��o---------: Fun��o escrita para fazer a atualiza��o dos dados dos Aprovadores Origem/Destino
Parametros--------: cTipo - O = Aprovador Origem / D = Aprovador Destino
                  : cGApr - C�digo do Aprovador
                  : cGSit - Status do Aprovador
                  : cGNom - Nome do Aprovador
Retorno-----------: lRet - Retorno sempre .T., pois a fun��o faz somente a atualiza��o dos dados na tela
===============================================================================================================================
*/
Static Function AtuDados(cTipo,cGApr,cGSit,cGNom)
Local aArea		:= GetArea()
Local lRet		:= .T.
Local cQry		:= ""
Local cAlias	:= GetNextAlias()
Local nX		:= 0
Local aColsAux	:= {}
Local _cInicPadrao

dbSelectArea("ZZ7")
ZZ7->(dbSetOrder(1))
If ZZ7->(dbSeek(xFilial("ZZ7") + cGApr))
	cGSit := ZZ7->ZZ7_STATUS
	cGNom := ZZ7->ZZ7_NOME
EndIf

If cTipo == "O"
	If ZZ7->ZZ7_TIPO <> "A"
	   lRet := .F.

       U_ITMSG("C�digo de Origem informado n�o � um aprovador.",;
               "Transfer�ncia de Aprovador",;
               "Favor verificar o c�digo informado.",2, , , .T.)
	EndIf
ElseIf cTipo == "D"
	If ZZ7->ZZ7_TIPO <> "A" .Or. ZZ7->ZZ7_STATUS == "B"
		lRet := .F.
		
		U_ITMSG("C�digo de Destino informado n�o � um Aprovador ou esta Bloqueado.",;
               "Transfer�ncia de Aprovador",;
               "Favor verificar o c�digo informado.",2, , , .T.)
	EndIf
EndIf

If cTipo == "O" .And. lRet
	cQry := " SELECT "
	
	For nX := 1 To Len(aHeader)
	    If ! (AllTrim(aHeader[nX,2]) $ "C1_ALI_WT/C1_REC_WT") .And. AllTrim(aHeader[nX,10]) <> "V"
		   If nX > 1 
			  cQry += ", " + aHeader[nX,2] + " " 
		   Else
			  cQry += aHeader[nX,2] + " "
		   EndIf
		EndIf
	Next nX
	
	cQry += ", R_E_C_N_O_ NRRECNO "
	
	oMSNewGD:aCols := {}
	
	cQry += "FROM " + RetSqlName("SC1") + " "
	cQry += "WHERE C1_FILIAL = '" + xFilial("SC1") + "' "
	cQry += "  AND C1_I_CODAP = '" + cGApr + "' "
	cQry += "  AND C1_APROV = 'B' "
	cQry += "  AND D_E_L_E_T_ = ' ' "
	
	cQry += "ORDER BY C1_FILIAL, C1_NUM, C1_ITEM "
	cQry := ChangeQuery(cQry)
	MPSysOpenQuery(cQry,cAlias)
	
//                     1            2         3           4          5        6        7       8       9       10          11      12        13       14         15        16   17
// aAdd(aHeader,{trim(x3_titulo),x3_campo,x3_picture,x3_tamanho,x3_decimal,x3_valid,x3_usado,x3_tipo, x3_f3,x3_context,	x3_cbox,x3_relacao,x3_when,X3_TRIGGER,	X3_PICTVAR,.F.,.F.})

    dbSelectArea(cAlias)
	(cAlias)->( dbGotop() )
	If (cAlias)->( !Eof() )
		While (cAlias)->( !Eof() )
			aColsAux := {}
			
			SC1->(DbGoTo((cAlias)->NRRECNO)) 
			
			For nX := 1 To Len(aHeader)
			    If AllTrim(aHeader[nX,10]) == "V" 
			       If AllTrim(aHeader[nX,2]) == "C1_ALI_WT"
			          aAdd(aColsAux, "SC1") 
			       ElseIf AllTrim(aHeader[nX,2]) == "C1_REC_WT" 
    			      aAdd(aColsAux,  (cAlias)->NRRECNO)
    			   Else
			          _cInicPadrao := GetSX3Cache(aHeader[nX,2],"X3_RELACAO")
			          If !Empty(_cInicPadrao)
			             aAdd(aColsAux, &(_cInicPadrao))
			          Else
			             aAdd(aColsAux, " ")
			          EndIf
			       EndIf
    			ElseIf aHeader[nX,8] == "D"  
				   aAdd(aColsAux, StoD((cAlias)->&(aHeader[nX,2])))
				Else
				   aAdd(aColsAux, (cAlias)->&(aHeader[nX,2]))
				EndIf
				
			Next nX

			(cAlias)->( dbSkip() )
			Aadd(aColsAux, .F.)
			Aadd(oMSNewGD:aCols, aColsAux)
		EndDo
	EndIf
	(cAlias)->( dbCloseArea() )	

	oMSNewGD:oBrowse:Refresh()
	oMSNewGD:Refresh()
EndIf

//====================================================================
// Grava log da atualiza��o dos dados dos Aprovadores Origem/Destino
//==================================================================== 
U_ITLOGACS('AtuDados')

RestArea(aArea)
Return(lRet)

/*
===============================================================================================================================
Programa----------: TransfVld
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 08/09/2015
Descri��o---------: Fun��o escrita para validar dos c�digos de Aprovador Origem e Aprovador Destino, que n�o podem ser iguais
Parametros--------: cGAprO - C�digo do Aprovador Origem
                  : cGAprD - C�digo do Aprovador Destino
Retorno-----------: lRet - .T. caso os c�digos forem diferente, .F. caso contr�rio, e o sistema n�o deixa salvar a solicita��o
===============================================================================================================================
*/
Static Function TransfVld(cGAprO, cGAprD)
Local aArea		:= GetArea()
Local lRet		:= .T.
Default cGAprO := ""
Default cGAprD := ""

If !Empty(cGAprO) .And. !Empty(cGAprD)
	If cGAprO == cGAprD
		lRet := .F.
		
		U_ITMSG("C�digo de Origem n�o pode ser o mesmo que o C�digo de Destino.",;
               "Transfer�ncia de Aprovador",;
               "Favor verificar os c�digos informados.",2, , , .T.)
		
	EndIf
EndIf

RestArea(aArea)
Return(lRet)

/*
===============================================================================================================================
Programa----------: TransVldT
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 08/09/2015
Descri��o---------: Fun��o escrita para validar dos c�digos de Aprovador Origem e Aprovador Destino
Parametros--------: cGAprO - C�digo do Aprovador Origem
                  : cGAprD - C�digo do Aprovador Destino
Retorno-----------: lRet - .T. caso os c�digos forem diferente, .F. caso contr�rio, e o sistema n�o deixa salvar a solicita��o
===============================================================================================================================
*/
Static Function TransVldT(cGAprO, cGAprD)
Local aArea		:= GetArea()
Local lRet		:= .T.

dbSelectArea("ZZ7")
ZZ7->(dbSetOrder(1))
If !ZZ7->(dbSeek(xFilial("ZZ7") + cGAprO))
	lRet := .F.
		
	U_ITMSG("C�digo de Origem informado n�o � val�do.",;
           "Transfer�ncia de Aprovador",;
           "Favor verificar o c�digo informado.",2, , , .T.)
EndIf

If !ZZ7->(dbSeek(xFilial("ZZ7") + cGAprD))
	lRet := .F.

	U_ITMSG("C�digo de Destino informado n�o � v�lido.",;
           "Transfer�ncia de Aprovador",;
           "Favor verificar o c�digo informado.",2, , , .T.)
EndIf

RestArea(aArea)
Return(lRet)

/*
===============================================================================================================================
Programa----------: ACOM001G
Autor-------------: Julio de Paula Paz
Data da Criacao---: 25/07/2017
Descri��o---------: Retorna o nome do usu�rio Protheus com base no c�digo de usu�rio informado.
Parametros--------: Nenhum
Retorno-----------: _cRet = Nome do usu�rio Protheus.
===============================================================================================================================
*/
User Function ACOM001G()
Local _cRet   := Space(20)
Local _aRetUser
Local _oModel := FWModelActive()
Local _cCodUsrP

Begin Sequence
   _cCodUsrP := _oModel:GetValue( 'ZZ7MASTER' , 'ZZ7_CODUSR' )
   
   If !Empty(_cCodUsrP)
      PswOrder(1)
      If PswSeek(_cCodUsrP,.T.) 
         _aRetUser := PSWRET(1)        
         _cRet := _aRetUser[1][2] // Nome do Usuario 
      EndIf
   EndIf

End Sequence

Return _cRet
