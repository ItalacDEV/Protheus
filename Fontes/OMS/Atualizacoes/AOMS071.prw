/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Darcio Sporl	  | 12/05/2016 | Foi corrigida a valida��o quando se tem apenas um registros, e tentar coloc�-lo como n�o ativo,
				  |			   | o sistema n�o tem mais aprovadores para trazer e selecionar, o sistema est� gerando error.log. 
				  |			   | Chamado: 15444
-------------------------------------------------------------------------------------------------------------------------------
 Alex       	  | 13/06/2016 | Retirada a validacao para deixar mais de um ativo - Chamado 15214
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges      | 14/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'FWMVCDEF.CH'
#Include 'PROTHEUS.CH'

#define	MB_OK				0
/*
===================================================================================e===========================================
Programa----------: AOMS071
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 30/03/2016
===============================================================================================================================
Descri��o---------: Cadastro de Aprovadores de Workflow de libera��o de Cr�dito
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS071()

Local oBrowse		:= Nil
Local _cMensagem	:= ""

dbSelectArea("ZZL")
dbSetOrder(3) //ZZL_FILIAL + ZZL_CODUSU
If dbSeek(xFilial("ZZL") + __cUserId)
	If ZZL->ZZL_LIBCRE == "S"
		oBrowse := FWMBrowse():New()

		oBrowse:SetAlias("ZY0")
		oBrowse:SetDescription("Cadastro de Aprovador de Workflow de Libera��o de (Cr�dito - Pre�o - Bonifica��o)")
		oBrowse:Activate()
	Else
		_cMensagem := "<html>"
		_cMensagem += "<body>"
		_cMensagem += "<p>"
		_cMensagem += "<strong>"
		_cMensagem += "Usu�rio Inv�lido<br><br>"
		_cMensagem += "</strong>
		_cMensagem += "O usu�rio: " + cUserName + " n�o possui permiss�o para utilizar este cadastro.<br>"
		_cMensagem += "</p>
		_cMensagem += "<hr>"
		_cMensagem += "<p>"
		_cMensagem += "Verificar com a �rea de TI a possibilidade de habilitar o seu usu�rio."
		_cMensagem += "</p>
		_cMensagem += "</body>"
		_cMensagem += "</html>"
						
		MessageBox(_cMensagem, "Aten��o", MB_OK)
	EndIf
Else
	_cMensagem := "<html>"
	_cMensagem += "<body>"
	_cMensagem += "<p>"
	_cMensagem += "<strong>"
	_cMensagem += "Usu�rio Inv�lido<br><br>"
	_cMensagem += "</strong>
	_cMensagem += "O usu�rio: " + cUserName + " n�o possui permiss�o para utilizar este cadastro.<br>"
	_cMensagem += "</p>
	_cMensagem += "<hr>"
	_cMensagem += "<p>"
	_cMensagem += "Verificar com a �rea de TI a possibilidade de habilitar o seu usu�rio."
	_cMensagem += "</p>
	_cMensagem += "</body>"
	_cMensagem += "</html>"
					
	MessageBox(_cMensagem, "Aten��o", MB_OK)
EndIf

Return(Nil)

/*
===============================================================================================================================
Programa----------: ModelDef
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 30/03/2016
===============================================================================================================================
Descri��o---------: Rotina para montagem do modelo de dados para o processamento
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ModelDef()

Local oStruZY0	:= FWFormStruct(1,"ZY0")
Local oModel	:= Nil

oModel := MpFormModel():New('AOMS071M')

oModel:AddFields('ZY0MASTER', , oStruZY0)

oModel:SetPrimaryKey( {'ZY0_FILIAL','ZY0_CODUSR','ZY0_TIPO'} )

Return(oModel)

/*
===============================================================================================================================
Programa----------: ViewDef
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 30/03/2016
===============================================================================================================================
Descri��o---------: Rotina para montar a View de Dados para exibi��o
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ViewDef()

Local oModel	:= FWLoadModel('AOMS071')
Local oStruZZI	:= FWFormStruct(2,'ZY0')
Local oView		:= Nil

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_ZY0',oStruZZI,'ZY0MASTER')

oView:CreateHorizontalBox('TELA', 100)

oView:SetOwnerView('VIEW_ZY0','TELA')

Return(oView)

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 30/03/2016
===============================================================================================================================
Descri��o---------: Rotina para cria��o do menu da tela principal
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _aRotina - Array com as op��es de menu
===============================================================================================================================
*/
Static Function MenuDef()

Local _aRotina := {}

ADD OPTION _aRotina Title 'Visualizar'	Action 'VIEWDEF.AOMS071'	OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title 'Incluir'   	Action 'U_AOMS071I()'		OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title 'Alterar'   	Action 'U_AOMS071A()'		OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title 'Excluir'		Action 'VIEWDEF.AOMS071'	OPERATION 5 ACCESS 0
ADD OPTION _aRotina Title 'Imprimir' 	Action 'VIEWDEF.AOMS071'	OPERATION 8 ACCESS 0
ADD OPTION _aRotina Title 'Copiar' 		Action 'VIEWDEF.AOMS071'	OPERATION 9 ACCESS 0

Return(_aRotina)

/*
===============================================================================================================================
Programa----------: AOMS071I
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 31/03/2016
===============================================================================================================================
Descri��o---------: Fun��o criada para fazer a inclus�o de novos registros com valida��o.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: L�gico - .T. dados v�lidas, .F. dados inv�lidos
===============================================================================================================================
*/
User Function AOMS071I()

Local _aArea	:= GetArea()
Local _lRet		:= .T.
Local _cAlias	:= Alias()
Local _nReg		:= Recno()

Private cCadastro	:= "Cadastro de Aprovador de Workflow de Libera��o de (Cr�dito - Pre�o - Bonifica��o)"

AxInclui( _cAlias, _nReg, 3, , , , "U_AOMSITOK()", , , , , , , .T.)

RestArea(_aArea)
Return(_lRet)

/*
===============================================================================================================================
Programa----------: AOMSITOK
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 31/03/2016
===============================================================================================================================
Descri��o---------: Fun��o criada para fazer a valida��o de inclus�o.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: L�gico - .T. dados v�lidas, .F. dados inv�lidos
===============================================================================================================================
*/
User Function AOMSITOK()

Local _aArea	:= GetArea()
Local _lRet		:= .T.
Local _cQryD	:= ""

_cQryD := "SELECT COUNT(*) DUPLIC "
_cQryD += "FROM " + RetSqlName("ZY0") + " "
_cQryD += "WHERE ZY0_FILIAL = '" + xFilial("ZY0") + "' "
_cQryD += "  AND ZY0_CODUSR = '" + M->ZY0_CODUSR + "' "
_cQryD += "  AND ZY0_TIPO = '" + M->ZY0_TIPO + "' "
_cQryD += "  AND D_E_L_E_T_ = ' ' "

dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQryD ) , "TRBDUP" , .T., .F. )
	
dbSelectArea("TRBDUP")
TRBDUP->(dbGoTop())
	
If TRBDUP->DUPLIC > 0
	_lRet := .F.
	_aInfHlp := {}
	//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
	aAdd( _aInfHlp , { "Este registro n�o pode ser inclu�do   "	, "J� existe este usu�rio cadastrado.      "	} )
	aAdd( _aInfHlp , { "Favor tente cadastrar outro usu�rio.   "	, ""                                    } )
						
	U_ITCADHLP( _aInfHlp , "AOMS07101" )
EndIf

dbSelectArea("TRBDUP")
TRBDUP->(dbCloseArea())

RestArea(_aArea)
Return(_lRet)

/*
===============================================================================================================================
Programa----------: AOMS071A
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 31/03/2016
===============================================================================================================================
Descri��o---------: Fun��o criada para fazer a altera��o dos registros com valida��o.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: L�gico - .T. dados v�lidas, .F. dados inv�lidos
===============================================================================================================================
*/
User Function AOMS071A()

Local _aArea	:= GetArea()
Local _lRet		:= .T.
Local _cAlias	:= Alias()
Local _nReg		:= Recno()

Private cCadastro	:= "Cadastro de Aprovador de Workflow de Libera��o de (Cr�dito - Pre�o - Bonifica��o)"

AxAltera( _cAlias, _nReg, 4, , , , , "U_AOMSATOK()", , , , , , , .T.)

RestArea(_aArea)
Return(_lRet)

/*
===============================================================================================================================
Programa----------: AOMSATOK
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 31/03/2016
===============================================================================================================================
Descri��o---------: Fun��o criada para fazer a valida��o de altera��o.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: L�gico - .T. dados v�lidas, .F. dados inv�lidos
===============================================================================================================================
*/
User Function AOMSATOK()

Local _aArea	:= GetArea()
Local _lRet		:= .T.
Local _cQry		:= ""
Local _cQryA	:= ""
Local _aHeader	:= {}
Local _aCols	:= {}
Local _nI		:= 0

If !M->ZY0_ATIVO == "S"
	_cQry := "SELECT COUNT(*) TOTREG "
	_cQry += "FROM " + RetSqlName("ZY0") + " "
	_cQry += "WHERE ZY0_ATIVO = 'S' "
	_cQry += "  AND ZY0_CODUSR <> '" + M->ZY0_CODUSR + "' "
	_cQry += "  AND ZY0_TIPO = '" + M->ZY0_TIPO + "' "
	_cQry += "  AND D_E_L_E_T_ = ' ' "
	
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBZY0" , .T., .F. )
	
	dbSelectArea("TRBZY0")
	TRBZY0->(dbGoTop())
	
	If TRBZY0->TOTREG == 0
		_cQryA := "SELECT * "
		_cQryA += "FROM " + RetSqlName("ZY0") + " "
		_cQryA += "WHERE ZY0_TIPO = '" + M->ZY0_TIPO + "' "
		_cQryA += "  AND ZY0_CODUSR <> '" + M->ZY0_CODUSR + "' "
		_cQryA += "  AND D_E_L_E_T_ = ' ' "
		
		dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQryA ) , "TRBLST" , .T., .F. )
		
		dbSelectArea("TRBLST")
		TRBLST->(dbGoTop())
		
		If !TRBLST->(Eof())
		
			While !TRBLST->(Eof())
				aAdd(_aCols, {	.F. ,;
								TRBLST->ZY0_CODUSR	,;
								TRBLST->ZY0_NOMUSR	,;
								TRBLST->ZY0_TIPO	,;
								TRBLST->ZY0_ATIVO	})

				TRBLST->(dbSkip())
			End

			_aHeader := { ' ' , 'C�d. Usu�rio' , 'Nome' , 'Tipo' , 'Ativo ?' }
		
			If U_ITListBox( "Seleciona Aprovador Ativo" , _aHeader , @_aCols , .F. , 2 , "Escolha um Aprovador para ficar ativo" , .T. , {50,100,200} , 2 )
		
				For _nI := 1 To Len(_aCols)
					If _aCols[_nI][1]
						dbSelectArea("ZY0")
						dbSetOrder(1)
						dbSeek(xFilial("ZY0") + _aCols[_nI][2] )//+ _aCols[_nI][4])
					    DO WHILE !ZY0->(EOF()) .AND. ZY0->ZY0_FILIAL == xFilial("ZY0") .AND. ZY0->ZY0_CODUSR == _aCols[_nI][2]
						   IF _aCols[_nI][4] == ZY0->ZY0_TIPO
						      RecLock("ZY0", .F.)
							  ZY0->ZY0_ATIVO := "S"
							  MsUnLock()
							  EXIT
						   ENDIF  						
						   ZY0->(DBSKIP())
						ENDDO
					EndIf
				Next _nI

			Else
				_lRet := .F.
				_aInfHlp := {}
				//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
				aAdd( _aInfHlp , { "Um aprovador deve ser selecionado para  "	, "ficar ativo.                          "	} )
				aAdd( _aInfHlp , { "Favor selecionar um aprovador.         "	, ""                                    } )
					
				U_ITCADHLP( _aInfHlp , "AOMS07104" )
			EndIf
		Else
			_lRet := .F.
			_aInfHlp := {}
			//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
			aAdd( _aInfHlp , { "N�o h� outro aprovador para ser selecio"	, "nado.                                  "} )
			aAdd( _aInfHlp , { "Favor deixar este aprovador ativo.     "	, ""                                    } )
					
			U_ITCADHLP( _aInfHlp , "AOMS07107" )
		EndIf

		dbSelectArea("TRBLST")
		TRBLST->(dbCloseArea())

	EndIf
	
	dbSelectArea("TRBZY0")
	TRBZY0->(dbCloseArea())
EndIf

RestArea(_aArea)
Return(_lRet)

/*
===============================================================================================================================
Programa----------: AOMS071VC
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 31/03/2016
===============================================================================================================================
Descri��o---------: Fun��o criada para fazer valida��es de campos.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: L�gico - .T. dados v�lidas, .F. dados inv�lidos
===============================================================================================================================
*/
User Function AOMS071VC()

Local _aArea	:= GetArea()
Local _lRet		:= .T.
Local _cCampo	:= ReadVar()

If "ZY0_CODUSR" $ _cCampo
	M->ZY0_NOMINT := AllTrim(UsrFullName(M->ZY0_CODUSR))
	M->ZY0_NOMUSR := AllTrim(UsrRetName(M->ZY0_CODUSR))
EndIf

RestArea(_aArea)
Return(_lRet)