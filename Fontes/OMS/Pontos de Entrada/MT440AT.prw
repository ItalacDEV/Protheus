/*
=====================================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
=====================================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich     | 30/09/2015 | Inclu�da valida��o de filialxusu�rioxarmaz�m - Chamado 12083                                 
-------------------------------------------------------------------------------------------------------------------------------------
 Alexandre Villar | 27/11/2015 | Inclu�da valida��o para verificar a configura��o do pedido com rela��o ao vencimento e frete 
                  |            | para informar ao usu�rio para que este confirme se quer continuar. Chamado 10369             
-------------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich     | 29/12/2015 | Incluida valida��o de estoque da exclus�o at� data atual - Chamado 13403                     
-------------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich     | 30/12/2015 | Retirada valida��o de estoque da exclus�o at� data atual - Chamado 13446                     
-------------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich     | 10/03/2016 | Bloqueio de libera��o de pedido com C5_LIBEROK = "S"  - Chamado 14690                        
-------------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 01/02/2021 | Remo��o de bugs apontados pelo Totvs CodeAnalysis. Chamado: 34262
=====================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"

/*
===============================================================================================================================
Programa----------: MT440AT
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 10/04/2012
===============================================================================================================================
Descri��o---------: Ponto de entrada que valida a libera��o de pedidos
===============================================================================================================================
Uso---------------: Liberacao de Pedidos de Vendas - Libera��o Manual			
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T. - Permite Libera��o .F. - N�o permite a Libera��o		
===============================================================================================================================
*/
User Function MT440AT()

Local _aArea	:= GetArea()            //Salva area geral
Local _lRet		:= .T.
Local _aRet		:= {}
Local _cmens	:= ""
Local _cCodUsr	:= ALLTRIM(RetCodUsr())

//====================================================================================================
// Verifica se o Pedido � uma Devolu��o/Utiliz.Fornec. para validar o Fornecedor
//====================================================================================================
If SC5->C5_TIPO $ "BD"

	DbSelectArea("SA2")
	SA2->( DbSetOrder(1) )
	If SA2->( DbSeek(xFilial("SA2") + SC5->( C5_CLIENTE + C5_LOJACLI ) ) )
	
		If SA2->A2_MSBLQL == '1'
		
			_lRet := .F.
			MsgStop( "O pedido ["+ SC5->C5_NUM +"] n�o ser� liberado pois o Fornecedor "+ SC5->C5_CLIENTE + "/" + SC5->C5_LOJACLI +" encontra-se bloqueado!" , "ATENCAO" )
			
		EndIf
		
	Else
		
		_lRet := .F.
		MsgStop( "O pedido ["+ SC5->C5_NUM +"] � do tipo 'Devolu��o/Utiliz.Fornec.' e n�o foi poss�vel posicionar no Fornecedor ["+ SC5->C5_CLIENTE + "/" + SC5->C5_LOJACLI +"]!" , "ATENCAO" )
		
	EndIf

//====================================================================================================
// Caso seja Pedido de Venda valida o Cliente
//====================================================================================================
Else

	DbSelectArea("SA1")
	SA1->( DbSetOrder(1) )
	If SA1->( DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI) )
	
		If SA1->A1_MSBLQL =='1'
		
			_lRet := .F.
			MsgStop( "O pedido ["+ SC5->C5_NUM +"] n�o ser� liberado pois o Cliente ["+ SC5->C5_CLIENTE +"/"+ SC5->C5_LOJACLI +"] encontra-se bloqueado!" , "ATENCAO" )
			
		EndIf
	
	Else
	
		_lRet := .F.
		MsgStop( "N�o ser� poss�vel liberar o pedido ["+ SC5->C5_NUM +"] pois o Cliente ["+ SC5->C5_CLIENTE +"/"+ SC5->C5_LOJACLI +" n�o foi encontrado no Sistema!" , "ATENCAO" )
		
	EndIf
	
	//====================================================================================================
	// Verifica se o Pedido � do Tipo "Normal" e suas amarra��es de Frete x Condi��o de Pagto.
	//====================================================================================================
	If SC5->C5_TIPO == 'N'
		
		If SC5->C5_CONDPAG == '001'
			
			If ITVERTES( SC5->C5_FILIAL , SC5->C5_NUM )
				
				_lRet := MsgYesNo(	'A condi��o de pagamento do pedido ['+ SC5->C5_NUM +'] foi configurada como [001 - � Vista] e foi utilizada uma TES que gera financeiro, '	+;
									'� recomendado verificar o recebimento ou a antecipa��o do pagamento!'+ CRLF +'Deseja prosseguir com a libera��o do Pedido de Venda?'		 , 'Aten��o!' )
				
			EndIf
			
		EndIf
		
		If SC5->C5_TPFRETE == 'F'
			
			_lRet := MsgYesNo(	'O frete do pedido ['+ SC5->C5_NUM +'] foi configurado como [FOB] � recomendado verificar as quest�es de embarque/descontos do frete!'+ CRLF +;
					 			'Deseja prosseguir com a libera��o do Pedido de Venda?' , 'Aten��o!' )
			
		EndIf
		
	EndIf

EndIf

//=======================================================================
//Valida se o pedido j� foi liberado
//=======================================================================
If _lret .and. SC5->C5_LIBEROK == 'S' .and. EMPTY(SC5->C5_NOTA)

		_lRet:= .F.
		MsgStop( "O pedido ["+ SC5->C5_NUM +"] j� foi liberado!" , "ATENCAO" )

Endif


//=======================================================================
//Valida se usu�rio tem acesso � todos os armaz�ns usados no pedido
// e se pedido retroativo n�o gerar� saldos negativos
//=======================================================================
If _lret 

	DbSelectArea("SC6")
	DbSetOrder(1)
	
	If DbSeek(xFilial("SC6")+SC5->C5_NUM)

		Do while alltrim(SC5->C5_NUM) == alltrim(SC6->C6_NUM)

	
			//============================================
			//Valida armaz�mxprodutoxfilialxusu�rio
			//============================================
			_aRet := U_ACFG004E(_cCodUsr, alltrim(xFilial("SC6")), alltrim(SC6->C6_LOCAL),alltrim(SC6->C6_PRODUTO), .F.)
			
			//se ainda est� valido verifica se n�o teve erro
			If _lRet
		
		  	_lRet:= _aRet[1]
		
			Endif
		
			// adiciona armazens com problema se ainda n�o estiver na mensagem
			if empty(_cmens)
		
				_cmens += _aRet[2]
			
			elseif !(_aRet[2]$_cmens) .and. !(Empty(_aRet[2])) 
		
				_cmens += ", " + _aRet[2]
			
			Endif		
			
			SC6->( Dbskip() )
		
		Enddo
		
		//============================================
		//Mostra lista de armaz�ns com problema
		//============================================
		If !(_lRet)

			MessageBox( 'Usu�rio sem acesso ao(s) armaz�m(�ns) abaixo nessa filial: ' + CRLF + _cmens + CRLF + CRLF+;
					'Caso necess�rio solicite a manuten��o � um usu�rio com acesso ou, se necess�rio, solicite o acesso � �rea de TI/ERP.' , 'Aten��o!' , 48 )
	
		Endif
		
	EndIf

Endif

Restarea(_aArea)

Return (_lRet)

/*
===============================================================================================================================
Programa--------: ITVERTES
Autor-----------: Alexandre Villar
Data da Criacao-: 27/11/2015
===============================================================================================================================
Descri��o-------: Fun��o para verificar se o pedido est� configurado com uma TES que gera Financeiro
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _lRet - Valor l�gico que determina se o processo de libera��o deve continuar
===============================================================================================================================
*/

Static Function ITVERTES( _cFilPed , _cNumPed )

Local _lRet		:= .F.
Local _cQuery	:= ''
Local _cAlias	:= GetNextAlias()

_cQuery := " SELECT COUNT( 1 ) AS GERFIN "
_cQuery += " FROM  "+ RetSqlName('SC6') +" SC6, "+ RetSqlName('SF4') +" SF4 "
_cQuery += " WHERE "+ RetSqlDel('SC6,SF4')
_cQuery += " AND SF4.F4_FILIAL  = SC6.C6_FILIAL "
_cQuery += " AND SF4.F4_CODIGO  = SC6.C6_TES "
_cQuery += " AND SC6.C6_FILIAL  = '"+ _cFilPed +"' "
_cQuery += " AND SC6.C6_NUM     = '"+ _cNumPed +"' "
_cQuery += " AND SF4.F4_DUPLIC  = 'S' "

If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T., .F. )

DBSelectArea(_cAlias)
(_cAlias)->( DBGoTop() )
If (_cAlias)->( !Eof() )
	_lRet := ( (_cAlias)->GERFIN > 0 )
EndIf

(_cAlias)->( DBCloseArea() )

Return( _lRet )
