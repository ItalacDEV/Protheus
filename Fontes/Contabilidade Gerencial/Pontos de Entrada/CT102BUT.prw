/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'Protheus.ch' 

/*
===============================================================================================================================
Programa----------: CT102BUT
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 11/02/2019
===============================================================================================================================
Descri��o---------: Ponto de Entrada que permite adicionar novos bot�es para o array arotina, no menu da mbrowse em lan�amentos 
					cont�beis autom�ticos.
===============================================================================================================================
Parametros--------: aRotina
===============================================================================================================================
Retorno-----------: aRotina
===============================================================================================================================
*/
User Function CT102BUT
Local aRotina := {}

	aAdd(aRotina,{"Consulta LOG","U_CCTBLGA()",0,2,0,nil})
	
Return (aRotina)

/*
===============================================================================================================================
Programa----------: CCTBLGA
Autor-------------: Alexandre Villar
Data da Criacao---: 24/02/2014
===============================================================================================================================
Descri��o---------: Consulta dos campos de Log de Inclus�o/Altera��o da tabela CT2
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function CCTBLGA()

Local _aCabec	:= { 'Opera��o' , 'Tabela' , 'Usu�rio' , 'Data' }
Local _aDados	:= {}
Local _cAlias	:= ''
Local _lDados	:= .F.
Local _nI		:= 0

_cAlias := 'CT2'

aAdd( _aDados , { 'Inclus�o'	, _cAlias , FWLeUserlg( _cAlias +"_USERGI" , 1 ) , FWLeUserlg( _cAlias +"_USERGI" , 2 ) } )
aAdd( _aDados , { 'Altera��o'	, _cAlias , FWLeUserlg( _cAlias +"_USERGA" , 1 ) , FWLeUserlg( _cAlias +"_USERGA" , 2 ) } )

For _nI := 1 To Len( _aDados )
	
	If !Empty( _aDados[_nI][03] )
		
		_lDados := .T.
		Exit
		
	EndIf
	
Next _nI

If _lDados
	U_ITListBox( 'Log de Altera��es - Lan�amentos Cont�beis:' , _aCabec , _aDados , .F. , 1 , 'Dados das �ltimas altera��es (se existirem)' )
Else
	Aviso( 'Aten��o!' , 'N�o existem registros de LOG para o lan�amento selecionado! Verifique os dados e tente novamente.' , {'Voltar'} , 2 )
EndIf

Return()