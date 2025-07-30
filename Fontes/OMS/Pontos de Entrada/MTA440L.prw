/*  
===================================================================================================================================
                          ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
====================================================================================================================================
       Autor    |    Data    |                                             Motivo                                          
------------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer   | 20/09/2021 | Alteracao p/ deixar sempre o estoque positivo p/ filial 40 Oper.: 41 / LOCAL 50/52. Chamado 37771
------------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer   | 27/10/2021 | Alteracao p/ deixar o estoque positivo p/ fil 40 Oper.: 41 / LOCAL 50/52 sem calculo. Chamado 37771
-----------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer   | 28/09/2021 | Alteracao para deixar o estoque negativo para a filial 40 Operações: 06/10/31/41 . Chamado 37771
-----------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer   | 01/11/2021 | Alteracao para deixar o estoque negativo para a filial 40 Operações: 06/10/41 . Chamado 37771
-----------------------------------------------------------------------------------------------------------------------------------
André Lisboa    | 08/11/2022 | Chamado 41775 - Incluir tipo de operação "31" nas permissões de liberar o pedido sem estoque para filial 40
====================================================================================================================================
*/

#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa--------: MTA440L
Autor-----------: Alexandre Villar
Data da Criacao-: 16/07/2015
===============================================================================================================================
Descrição-------: P.E. na validação da quantidade disponível em estoque para liberação de pedidos de vendas
===============================================================================================================================
Uso-------------: Incrementar o saldo disponível com o estoque em poder de terceiros para as Filiais/Armazens configuradas.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _nValEst - Valor de estoque disponível em poder de terceiros (valor deve ser negativo para tratativa do P.E.)
===============================================================================================================================
*/

User Function MTA440L()

Local _nRet		:= 0
Local _cQuery	:= ''
Local _cAlias	:= ''
Local _cFilTer	:= AllTrim( U_ITGetMV( 'IT_EST3FIL' ,, '' ) ) // Verifica parâmetro de configurações das Filiais que usam estoque em poder de terceiros
Local _cLocTer	:= AllTrim( U_ITGetMV( 'IT_EST3LOC' ,, '' ) ) // Verifica parâmetro de configurações dos Armazéns que usam estoque em poder de terceiros

//====================================================================================================
// Considera estoque em poder de terceiros apenas nas Filiais/Armazéns configurados
//====================================================================================================
If SC6->C6_FILIAL $ _cFilTer .And. SC6->C6_LOCAL $ _cLocTer

	_cQuery := " SELECT SB2.B2_QNPT AS SALDO_TER "
	_cQuery += " FROM  "+ RetSqlName('SB2') +" SB2 "
	_cQuery += " WHERE "+ RetSqlCond('SB2')
	_cQuery += " AND SB2.B2_COD   = '"+ SC6->C6_PRODUTO +"' "
	_cQuery += " AND SB2.B2_LOCAL = '"+ SC6->C6_LOCAL   +"' "
	
	_cAlias := GetNextAlias()
	
	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T., .F. )
	
	//====================================================================================================
	// Se tiver saldo em poder de terceiros, devolver valor para ser utilizado na validação de estoque
	//====================================================================================================
	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	IF (_cAlias)->( !Eof() ) .And. (_cAlias)->SALDO_TER > 0
		
		_nRet := -(_cAlias)->SALDO_TER // O valor deve ser devolvido negativo por tratativas do P.E.
		
	EndIf
	
	(_cAlias)->( DBCloseArea() )

EndIf

IF (SC5->C5_FILIAL = "40" .AND. SC5->C5_I_OPER $ "06/10/31/41" .AND. SC6->C6_LOCAL $ "50/52")
    _nRet :=-10000000
	/*
    IF (SB2->B2_QATU - SC6->C6_QTDVEN) < 0
       _nRet :=  1
	   IF SB2->B2_QATU < 0
	      _nRet :=  SB2->B2_QATU * -1
	   ENDIF 
	   _nRet :=   _nRet +  SC6->C6_QTDVEN
	   _nRet :=   _nRet * -1 //Tem que retorna negativo para somar
	ENDIF*/
ENDIF

Return( _nRet )
