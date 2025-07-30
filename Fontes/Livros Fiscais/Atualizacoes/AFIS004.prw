/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Alexandre V. | 22/12/2015 | Tratativa na cl�usula "ORDER BY" para remover a refer�ncia num�rica. Chamado 13062
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer| 31/01/2019 | Aviso para quando os campos F4_DUPLIC e F4_UPRC estiverem diferentes. Chamado 27890
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 02/04/2019 | Revis�o de fontes. Help 28346
===============================================================================================================================
*/

//===========================================================================
//| Defini��es de Includes                                                  |
//===========================================================================
#INCLUDE "protheus.ch"

/*
===============================================================================================================================
Programa--------: AFIS004
Autor-----------: Alexandre Villar
Data da Criacao-: 03/08/2015
===============================================================================================================================
Descri��o-------: Rotina para libera��o de TES pelas �reas: Fiscal, Pis/Cofins e Estoque - Chamado 9688
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AFIS004()

Local _aCores := {	{ "F4_MSBLQL <> '1' "							, "BR_VERDE"	},;  //TES Liberada
					{ "F4_MSBLQL == '1' .And. F4_I_BLFPE == 'SSS'"	, "BR_AMARELO"	},;  //TES bloqueada para uso
					{ "F4_MSBLQL == '1' .And. F4_I_BLFPE <> 'SSS'"	, "BR_VERMELHO"	} }  //TES bloqueada pelo cadastro

Private cCadastro	:= "Libera��o do cadastro de TES"
Private aRotina	:={}
aRotina		:= {	{ "Pesquisar"	, "AxPesqui"		, 0 , 01 } ,;
					{ "Visualizar"	, "AxVisual"		, 0 , 02 } ,;
					{ "Consultar"	, "U_AFIS004C()"	, 0 , 02 } ,;
					{ "Liberar"		, "U_AFIS004L()"	, 0 , 04 } ,;
					{ "Legenda"		, "U_AFIS004S()"	, 0 , 08 }  }

DBSelectArea("SF4")
SF4->( DBSetOrder(1) )
MBrowse( ,,,, "SF4" ,,,,,, _aCores )

Return()

/*
===============================================================================================================================
Programa--------: AFIS004S
Autor-----------: Alexandre Villar
Data da Criacao-: 03/08/2015
===============================================================================================================================
Descri��o-------: Legenda da tela
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AFIS004S()

Local _aCores := {	{ 'BR_VERDE'	, "TES Liberada"		  		},;
					{ 'BR_AMARELO'	, "TES Bloqueada para uso"		},;
					{ 'BR_VERMELHO'	, "TES Bloqueada pelo cadastro"	} }

BrwLegenda( cCadastro , "Legenda" , _aCores )

Return()

/*
===============================================================================================================================
Programa----------: AFIS004L
Autor-------------: Alexandre Villar
Data da Criacao---: 03/08/2015
===============================================================================================================================
Descri��o---------: Rotina para Liberar a TES bloqueada pelo cadastro
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AFIS004L()

Local _aDadLog	:= {}
Local _xValid	:= U_ITACSUSR( 'ZZL_LCADTE' )

//====================================================================================================
// Validacao para verificar se o Usuario tem acesso � rotina de manuten��o de TES
//====================================================================================================
If ValType(_xValid) == 'C' .And. !Empty(_xValid) .And. _xValid $ ('FPE')
	
//1) Quando F4_DUPLIC = 'N' .and. SF4->F4_UPRC = 'S'  ===========>  "Para TES que N�O geram financeiro o campo atualiza pre�o de compra deveria estar tamb�m como "N�O", deseja de continuar? "
	If SF4->F4_TIPO = 'E' .AND. SF4->F4_DUPLIC = 'N' .AND. SF4->F4_UPRC = 'S' .AND. !MSgYesNo("Para TES que N�O geram financeiro o campo atualiza pre�o de compra deveria estar tamb�m como N�O, deseja de continuar ?","AFIS00401")
	   Return .F.
	EndIf

//2) Quando F4_DUPLIC = 'S' .and. SF4->F4_UPRC = 'N'  ===========>  "Para TES que GERAM financeiro o campo atualiza pre�o de compra deveria estar com preenchido com "SIM", deseja de continuar?"
	If SF4->F4_TIPO = 'E' .AND. SF4->F4_DUPLIC = 'S' .and. SF4->F4_UPRC = 'N' .AND. !MsgYesNo("Para TES que GERAM financeiro o campo atualiza pre�o de compra deveria estar com preenchido com SIM, deseja de continuar?","AFIS00402")
	   Return .F.
	EndIf

//TES de saida (F4_TIPO = 'S') realizar a valida��o somente se F4_UPRC = 'S', caso esteja apresentar a seguinte mensagem: "Para TES de saida o campo atualiza pre�o deveria estar preenchido como "NAO", deseja continuar?"
	If SF4->F4_TIPO = 'S' .AND. M->F4_UPRC = 'S' .AND. !MsgYesNo("Para TES de saida o campo atualiza pre�o deveria estar preenchido como N�O, deseja de continuar?","AGLT00403")
	   RETURN .F.
	ENDIF

	If _xValid == 'F'
		
		If SubStr( SF4->F4_I_BLFPE , 1 , 1 ) == "S"
			Help(NIL, NIL, "AFIS00404", NIL, "A TES selecionada j� est� liberada pelo Depto. Fiscal!",1, 0, NIL, NIL, NIL, NIL, NIL, {"Selecione uma uma TES n�o liberada."})
		Else
			
			If MsgYesNo("Confirma a libera��o Fiscal para a TES: "+ SF4->F4_CODIGO +" ?","AFIS00405")
				
				aAdd( _aDadLog , { "F4_I_BLFPE" , SF4->F4_I_BLFPE , 'S' + SubStr( SF4->F4_I_BLFPE , 2 , 2 ) } )
				
				RecLock( 'SF4' , .F. )
				SF4->F4_I_BLFPE := 'S' + SubStr( SF4->F4_I_BLFPE , 2 , 2 )
				SF4->( MSUnlock() )
				
				U_ITGrvLog( _aDadLog , 'SF4' , 1 , SF4->( F4_FILIAL + F4_CODIGO ) , 'A' , RetCodUsr() , Date() , Time() )
				
			EndIf
			
		EndIf
	
	EndIf
	
	If _xValid == 'P'
		
		If SubStr( SF4->F4_I_BLFPE , 2 , 1 ) == "S"
			Help(NIL, NIL, "AFIS00406", NIL, "A TES selecionada j� est� liberada pelo respons�vel pelas configura��es de PIS/COFINS!",1, 0, NIL, NIL, NIL, NIL, NIL, {"Selecione uma uma TES n�o liberada."})
		Else
			If MsgYesNo("Confirma a libera��o de PIS/COFINS para a TES: "+ SF4->F4_CODIGO +" ?","AFIS00407")
				
				aAdd( _aDadLog , { "F4_I_BLFPE" , SF4->F4_I_BLFPE , SubStr( SF4->F4_I_BLFPE , 1 , 1 ) +'S'+ SubStr( SF4->F4_I_BLFPE , 3 , 1 ) } )
				
				RecLock( 'SF4' , .F. )
				SF4->F4_I_BLFPE := SubStr( SF4->F4_I_BLFPE , 1 , 1 ) +'S'+ SubStr( SF4->F4_I_BLFPE , 3 , 1 )
				SF4->( MSUnlock() )
				
				U_ITGrvLog( _aDadLog , 'SF4' , 1 , SF4->( F4_FILIAL + F4_CODIGO ) , 'A' , RetCodUsr() , Date() , Time() )
				
			EndIf
			
		EndIf
	
	EndIf
	
	If _xValid == 'E'
		
		If SubStr( SF4->F4_I_BLFPE , 3 , 1 ) == "S"
			Help(NIL, NIL, "AFIS00408", NIL, "A TES selecionada j� est� liberada pelo respons�vel pelas configura��es de Estoque!",1, 0, NIL, NIL, NIL, NIL, NIL, {"Selecione uma uma TES n�o liberada."})
		Else
			
			If MsgYesNo("Confirma a libera��o de Estoque para a TES: "+ SF4->F4_CODIGO +" ?","AFIS00409")
				
				aAdd( _aDadLog , { "F4_I_BLFPE" , SF4->F4_I_BLFPE , SubStr( SF4->F4_I_BLFPE , 1 , 2 ) +'S' } )
				
				RecLock( 'SF4' , .F. )
				SF4->F4_I_BLFPE := SubStr( SF4->F4_I_BLFPE , 1 , 2 ) +'S'
				SF4->( MSUnlock() )
				
				U_ITGrvLog( _aDadLog , 'SF4' , 1 , SF4->( F4_FILIAL + F4_CODIGO ) , 'A' , RetCodUsr() , Date() , Time() )
				
			EndIf
			
		EndIf
	
	EndIf
	
Else
	Help(NIL, NIL, "AFIS00410", NIL, "O usu�rio atual n�o tem permiss�o para libera��o do cadastro de TES na Gest�o de Usu�rios da Italac.",1, 0, NIL, NIL, NIL, NIL, NIL, {"Solicite o Acesso ao Depto responsavel."})	
EndIf

Return()

/*
===============================================================================================================================
Programa--------: AFIS004C
Autor-----------: Alexandre Villar
Data da Criacao-: 03/08/2015
===============================================================================================================================
Descri��o-------: Consulta hist�rico de altera��es da TES
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/

User Function AFIS004C()

Local _aLogReg	:= {}
Local _cAlias	:= GetNextAlias()
Local _cTitLog	:= 'Consulta hist�rico de altera��es da TES: '+ SF4->F4_CODIGO
Local _aHeader	:= { 'Data' , 'Hora' , 'Op��o' , 'Campo' , 'Conte�do Orig.' , 'Conte�do Alt.' , 'Usu�rio' }
Local _cTxtAux	:= ''
Local _aAllusers:= FWSFAllUsers() //n�o � permitirdo chamar a fun��o que retorna apenas o nome por estar dentro do loop
Local _nPos		:= 0

BeginSql alias _cAlias
	SELECT Z07_DATA, Z07_HORA, Z07_OPCAO, Z07_CAMPO, Z07_CONORG, Z07_CONALT, Z07_CODUSU
	FROM %table:Z07%
	WHERE D_E_L_E_T_ = ' '
	AND Z07_FILIAL = %xFilial:Z07%
	AND Z07_ALIAS = 'SF4'
	AND Z07_CHAVE = %exp:SF4->(F4_FILIAL+F4_CODIGO)%
EndSql
	
While (_cAlias)->( !Eof() )
	_nPos:= aScan(_aAllusers,{|x| x[2] == (_cAlias)->Z07_CODUSU})
	aAdd( _aLogReg , {	DtoC( StoD( (_cAlias)->Z07_DATA ) )								,;
						AllTrim( (_cAlias)->Z07_HORA )									,;
						IIF( (_cAlias)->Z07_OPCAO == 'I' , 'Inclus�o' , 'Altera��o' )	,;
						AllTrim( (_cAlias)->Z07_CAMPO )									,;
						AllTrim( (_cAlias)->Z07_CONORG )								,;
						AllTrim( (_cAlias)->Z07_CONALT )								,;
						IIf(_nPos>0,_aAllusers[_nPos][4],(_cAlias)->Z07_CODUSU) })
	
	(_cAlias)->( DBSkip() )
EndDo

(_cAlias)->( DBCloseArea() )

If Empty( _aLogReg )
	_aLogReg := { { '' , '' , '' , '' , '' , '' , '' } }
EndIf

_cTxtAux := 'Status para uso: '		+ IIF( SF4->F4_MSBLQL == '1' , 'Bloqueado' , 'Liberado' )						+ Space(20)
_cTxtAux += 'Status Fiscal: '		+ IIF( SubStr( SF4->F4_I_BLFPE , 1 , 1 ) == 'S' , 'Liberado' , 'Bloqueado' )	+ Space(20)
_cTxtAux += 'Status PIS/COFINS: '	+ IIF( SubStr( SF4->F4_I_BLFPE , 2 , 1 ) == 'S' , 'Liberado' , 'Bloqueado' )	+ Space(20)
_cTxtAux += 'Status Estoque: '		+ IIF( SubStr( SF4->F4_I_BLFPE , 3 , 1 ) == 'S' , 'Liberado' , 'Bloqueado' )

U_ITListBox( _cTitLog , _aHeader , _aLogReg , .T. , 1 , _cTxtAux )

Return()