/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Alexandre Villar |   02/2015  | Atualização dos P.E. que interferem na rotina de Fechamento do Leite
-------------------------------------------------------------------------------------------------------------------------------
 Alexandre Villar | 26/02/2015 | Correção da tratativa de datas para retornar o valor correto. Chamado 9168
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 11/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: M461DUPC
Autor-------------: Talita Teixeira
Data da Criacao---: 20/11/2014
===============================================================================================================================
Descrição---------: Ponto de Entrada ao gerar titulos de cédito para fornecedor no caso de nota fiscal de devolução de compras.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function M461DUPCR()

Local _cDias		:= AllTrim( SE4->E4_COND )
Local _cCond		:= StrtoKarr( _cDias , ',' )
Local _dData		:= Stod('')
Local _dVencRea		:= Stod('')
Local _dVenc		:= Stod('')

If Len(_cCond) == 1 .Or. SE4->E4_TIPO == '7'
	
	If SE4->E4_TIPO == '7'
		_dData		:= StoD( cValToChar( Year( Date() ) ) + StrZero( Month( Date() ) , 2 ) + AllTrim( _cCond[2] ) )
		_dVencRea	:= DataValida( MonthSum( _dData , 1 ) )
	Else
		_dVenc		:= Date() + Val( _cDias )
		_dVencRea	:= DataValida( _dVenc )
	EndIf
	
	DBSelectArea('SE2')
	SE2->( RECLOCK( 'SE2' , .F. ) )
	SE2->E2_VENCTO	:= _dVenc
	SE2->E2_VENCREA	:= _dVencRea
	SE2->( MSUNLOCK() )
	
EndIf

Return