/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich     | 06/09/2017 | Usa __CUSERID quando poss�vel - Chamado 21323
=============================================================================================================================== 
*/
#Include 'Protheus.ch'  


/*
===============================================================================================================================
Programa----------: MT410ALT
Autor-------------: Alexandre Villar
Data da Criacao---: 24/02/2014
===============================================================================================================================
Descri��o---------: Ponto de entrada antes de opera��es de Exclus�o/C�pia/Altera��o no Pedido de Vendas para validar acesso
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function MT410ALT()

Local _aDadAux	:= {}
Local _cCodUsr	:= RetCodUsr()

//Se tiver a vari�vel __CUSERID v�lida usa ao inv�s da fun��o retcodusr para funcionar com os webservices
If type('__CUSERID') == 'C'

	_cCodUsr := __CUSERID
	
Endif

If Type('_cActLog') == 'C' .And. !Empty(_cActLog)
	
	If _cActLog == 'A'
		
		If Type('_aLogSC5') == 'A' .And. !Empty( _aLogSC5 )
			U_ITGrvLog( _aLogSC5 , "SC5" , 1 , SC5->( C5_FILIAL + C5_NUM ) , _cActLog , _cCodUsr , _dDtLgC5 , _cTmLgC5 )
		EndIf
		
		If Type('_aLogSC6') == 'A' .And. !Empty( _aLogSC6 )
			U_ITGrvLog( _aLogSC6 , "SC6" , 1 , SC5->( C5_FILIAL + C5_NUM ) , _cActLog , _cCodUsr , _dDtLgC5 , _cTmLgC5 )
		EndIf
	
	Else
		
		aAdd( _aDadAux , { 'C5_FILIAL'	, SC5->C5_FILIAL	, ''		} )
		aAdd( _aDadAux , { 'C5_NUM'		, SC5->C5_NUM		, ''		} )
		aAdd( _aDadAux , { 'C5_CLIENTE'	, SC5->C5_CLIENTE	, ''		} )
		aAdd( _aDadAux , { 'C5_LOJACLI'	, SC5->C5_LOJACLI	, ''		} )
		aAdd( _aDadAux , { 'C5_EMISSAO'	, SC5->C5_EMISSAO	, StoD('')	} )
		aAdd( _aDadAux , { 'C5_I_DTENT'	, SC5->C5_I_DTENT	, StoD('')	} )
		
		U_ITGrvLog( _aDadAux , "SC5" , 1 , SC5->( C5_FILIAL + C5_NUM ) , _cActLog , _cCodUsr , _dDtLgC5 , _cTmLgC5 )
		
	EndIf
	
EndIf

_aLogSC5 := {}
_aLogSC6 := {}
_cActLog := ''

Return()