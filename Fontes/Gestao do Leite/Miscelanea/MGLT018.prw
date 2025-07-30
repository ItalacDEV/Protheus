/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alexandre V.  | 19/08/2015 | Corre��o de campos que foram convertidos em virtuais que n�o podem mais ser referenciados direta-
			  |			   | mente. Chamado 11454
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 11/04/2019 | Revis�o de fontes. Help 28346
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 27/09/2019 | Revis�o de fontes. Chamado 28346
===============================================================================================================================
*/

//===========================================================================
//| Defini��es de Includes                                                  |
//===========================================================================
#Include "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: MGLT018
Autor-------------: Alexandre Villar
Data da Criacao---: 11/12/2014
===============================================================================================================================
Descri��o---------: Rotina para processar o Estorno de Fechamento da Recep��o de Leite de Terceiros
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGLT018()

Local _aParam	:= {}
Local _aParRet	:= {}

Private _cUsrID	:= RetCodUsr()

aAdd( _aParam , { 2 , 'Tipo de Estorno' , 1 , { '1 - Per�odo' , '2 - Fornecedor' } , 60 , '.T.' , .T. } ) ; aAdd( _aParRet , _aParam[01][03] )

If Parambox( _aParam , 'Op��o de Processamento:' , @_aParRet ,,,,,,,, .F. , .F. )
	
	If ValType(_aParRet[01]) == 'C'
		_aParRet[01] := Val( SubStr(_aParRet[01],1,1) )
	EndIf
	
	If _aParRet[01] == 1
		MGLT018EFC()
	Else
		MGLT018ERT()
	EndIf
		
EndIf

Return()

/*
===============================================================================================================================
Programa----------: MGLT018EFC
Autor-------------: Alexandre Villar
Data da Criacao---: 11/12/2014
===============================================================================================================================
Descri��o---------: Rotina que processa o Estorno de Fechamento
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MGLT018EFC()

Local _aParam	:= {}
Local _aParRet	:= {}

aAdd( _aParam , { 01 , "Fechamento" , Space( TamSX3('ZLY_CODIGO')[01] ) , "" ,, "ZLY" , "" , 0  , .F. } ) ; aAdd( _aParRet , _aParam[01][03] )

If Parambox( _aParam , 'Op��es de Processamento:' , @_aParRet ,,,,,,,, .F. , .F. )
	
	DBSelectArea('ZLY')
	ZLY->( DBSetOrder(1) )
	If ZLY->( DBSeek( xFilial('ZLY') + _aParRet[01] ) )
		If Empty( ZLY->ZLY_DFECHA )
			MsgAlert("O per�odo informado n�o est� fechado!","MGLT01801")
		Else
			If Aviso("MGLT01802", 'Confirma o estorno do Fechamento: '+_aParRet[01]+' para o per�odo: ['+DtoC(ZLY->ZLY_REFINI)+'-'+DtoC(ZLY->ZLY_REFFIM)+']' , {'Sim','N�o'} , 2 ) == 1
				
				ZLY->( RecLock('ZLY',.F.) )
				ZLY->ZLY_DFECHA	:= StoD('')
				ZLY->ZLY_USRFEC	:= _cUsrID
				ZLY->( MsUnlock() )
				
				MsgInfo("Estorno do Fechamento "+ _aParRet[01] +" realizado com sucesso!","MGLT01803")
				
			Else
				MsgInfo("Processamento cancelado pelo usu�rio!","MGLT01804")
			EndIf
		EndIf
	EndIf

EndIf

Return()

/*
===============================================================================================================================
Programa----------: MGLT018ERT
Autor-------------: Alexandre Villar
Data da Criacao---: 11/12/2014
===============================================================================================================================
Descri��o---------: Rotina que processa o Estorno de Fechamento de Fornecedores
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MGLT018ERT()

Local _cAlias	:= GetNextAlias()
Local _cPerg	:= "MGLT018"
Local _aResumo	:= {}

If Pergunte( _cPerg )
	
	DBSelectArea('ZLY')
	ZLY->( DBSetOrder(1) )
	If ZLY->( DBSeek( xFilial('ZLY') + MV_PAR01 ) )
		
		If Empty( ZLY->ZLY_DFECHA )
			BeginSql alias _cAlias
				SELECT ZLX.R_E_C_N_O_ REGZLX, TRANS.A2_NREDUZ TRANS_NOME, FORN.A2_NREDUZ FORN_NOME
				FROM %table:ZLX% ZLX, %table:SA2% TRANS, %table:SA2% FORN
				WHERE ZLX.D_E_L_E_T_ = ' '
				AND TRANS.D_E_L_E_T_ (+) = ' '
				AND FORN.D_E_L_E_T_ = ' '
				AND ZLX_FORNEC = FORN.A2_COD
				AND ZLX_LJFORN = FORN.A2_LOJA
				AND ZLX_TRANSP (+) = TRANS.A2_COD
				AND ZLX_LJTRAN (+) = TRANS.A2_LOJA
				AND ZLX_STATUS = '3'
				AND ZLX_DTENTR BETWEEN %exp:ZLY->ZLY_REFINI% AND %exp:ZLY->ZLY_REFFIM%
				AND ZLX_FORNEC || ZLX_LJFORN BETWEEN %exp:MV_PAR02+MV_PAR03% AND %exp:MV_PAR04+MV_PAR05%
			EndSql
			
			While (_cAlias)->( !EOF() ) .And. !Empty( (_cAlias)->REGZLX )
			
				DBSelectArea("ZLX")
				ZLX->( DBGoTo( (_cAlias)->REGZLX ) )
				ZLX->( RecLock( "ZLX" , .F. ) )
				ZLX->ZLX_STATUS	:= '2'
				ZLX->ZLX_USRFEC	:= _cUsrID
				ZLX->ZLX_DTFECH	:= StoD('')
				ZLX->ZLX_HRFECH	:= ''
				ZLX->( MsUnlock() )
				
				aAdd( _aResumo , {	ZLX->ZLX_FILIAL,;
									ZLX->ZLX_CODIGO,;
									ZLX->ZLX_FORNEC +'/'+ ZLX->ZLX_LJFORN +' - '+ AllTrim((_cAlias)->FORN_NOME),;
									ZLX->ZLX_TRANSP +'/'+ ZLX->ZLX_LJTRAN +' - '+ AllTrim((_cAlias)->TRANS_NOME),;
									ZLX->ZLX_TIPOLT,;
									U_ITRetBox( ZLX->ZLX_TIPOLT , 'ZLX_TIPOLT' ),;
									DtoC(ZLX->ZLX_DTSAID)})
				
			(_cAlias)->( DBSkip() )
			EndDo
			
			If Empty(_aResumo)
				MsgAlert("N�o foram encontrados registros fechados para estornar de acordo com os par�metros informados!","MGLT01805")
			Else
				If Aviso("MGLT01806","Estorno do fechamento realizado com sucesso! "+ cValToChar(Len(_aResumo)) +" registros processados.",{"Detalhes","Fechar"}) == 1
					U_ITListBox('Resumo do Processamento',{'Filial','Recep��o','Fornecedor','Transportador','Tipo','Produto','Data Sa�da'},_aResumo,.T.,1,'Registros estornados:')
				EndIf
			EndIf
		Else
			MsgStop("N�o � poss�vel estornar o fechamento de um Transportador em um per�odo Fechado! Caso necess�rio o per�odo dever� ser reaberto.","MGLT01807")
		EndIf
	Else
		MsgAlert("O Fechamento indicado n�o foi encontrado! Verifique os dados e tente novamente.","MGLT01808")
	EndIf
EndIf

Return()