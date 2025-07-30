/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor     |   Data   |                              Motivo                                                          
===============================================================================================================================
Julio Paz    | 14/02/18 | Chamado 23272. Alterar as op��es de filtro da tela de montegem de carga.
Alex Wallauer| 22/02/19 | Chamado 28114. N�o mostra pedidos de de Faturamento do Triangular.
Alex Wallauer| 09/08/21 | Chamado 37406. Controle para nao chamar o Pergunte() 2 vezes seguidas.
Lucas Borges | 09/10/24 | Chamado 48465. Retirada manipula��o do SX1.
==================================================================================================================================================================================================================
Analista        - Programador   - Inicio   - Envio    - Chamado - Motivo da Altera��o
==================================================================================================================================================================================================================
Bremmer         - Alex Wallauer - 10/10/24 - 05/11/24 - 48795  - Tratamento para o novo par�metro IT_NAGEND: TP Entrega = C5_I_AGEND $ P=Aguardando Agenda; R=Reagendar; N=Reagendar com Multa
Vanderlei Alves - Alex Wallauer - 20/03/25 - 21/03/25 - 50197  - Novo tratamento para cortes e desmembramentos de pedidos - IGNORAR: M->C5_I_BLSLD = "S"
==================================================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: OM200QRY
Autor-------------: Jeane
Data da Criacao---: 05/08/2009
===============================================================================================================================
Descri��o---------: Ponto de entrada na inicializa��o da montagem de carga para filtrar os Pedidos
===============================================================================================================================
Parametros--------: Padr�o ( PARAMIXB ) - Cont�m a query que far� o filtro para ser complementada
===============================================================================================================================
Retorno-----------: _cFiltro - Query que ser� utilizada para filtrar os pedidos
===============================================================================================================================
*/

STATIC _lPerOM200QRY := .T.//Esse ponto de entrada � chamado 2 vezes seguidas no OMSA200, PQ a SELECT principal tem UNION portando devolve o mesmo filtro para as 2 SELECTs do UNION

User function OM200QRY()
Local _cPerg   := "OM200QRY"
Local _cFiltro := PARAMIXB[1]
Local nQdePerg	  := 40
Local aPergOld	  := {}, nLoop
Local _cIT_NAGEND := SuperGetMV("IT_NAGEND",.F., "P;R;N")//P=Aguardando Agenda; R=Reagendar; N=Reagendar 

// 01) "Estado"		     ,"C",99,0,"G","LSTEST","MV_PAR01"
// 02) "Municipio"       ,"C",99,0,"G","LSTMU2","MV_PAR02"
// 03) "Vendedor"        ,"C",99,0,"G","LSTVEN","MV_PAR03"
// 04) "Supervisor"	     ,"C",99,0,"G","LSTSUP","MV_PAR04"
// 05) "Rede"	         ,"C",99,0,"G","LSTRED","MV_PAR05"
// 06) "Peso de ?"       ,"N",12,4,"G","      ","MV_PAR06"
// 07) "Peso ate ?"      ,"N",12,4,"G","      ","MV_PAR07"
// 08) "Tipo de Carga ?" ,"N",01,0,"C","      ","MV_PAR08","Paletizada", "Batida","Ambas"
// 09) "Tipo de Agenda ?","C",15,0,"G","LSTTPA","MV_PAR09"
//=========================================
//Salva as perguntas originais da rotina
//=========================================

For nLoop := 1 To nQdePerg
	aAdd( aPergOld, &( "MV_PAR" + StrZero( nLoop, 2 ) ) )
Next

//====================================================================================================
// Caso as perguntas sejam canceladas processa sem os filtros
//====================================================================================================
If Pergunte( _cPerg , _lPerOM200QRY) .OR. !_lPerOM200QRY// COLOQUEI "!_lPerOM200QRY" pq o pergunte(,.F.) com .f. devolve falso
//  _cMensagem:="" 
//  For nLoop := 1 To 9
//     _cMensagem += "MV_PAR" + StrZero( nLoop, 2 ) +" = [ "+AllTrim(AllToChar( &( "MV_PAR" + StrZero( nLoop, 2 ) )  ))+" ]"+CHR(13)+CHR(10)
//  Next                
//  bBloco:={||  AVISO("ATENCAO",_cMensagem,{"FECHAR"},3) }
//  U_ITMSG("_lPerOM200QRY = "+IF(_lPerOM200QRY,".T.",".F."),'Aten��o!',,1,,,,,,bBloco)

	//================================================================================
	// Filtra Estado Cliente
	//================================================================================
	If !Empty( MV_PAR01 )
		_cFiltro += " AND SC5.C5_I_EST IN " + FormatIn( AllTrim( MV_PAR01 ) , ";" )
	endif

	If !Empty( _cIT_NAGEND )
		_cFiltro += " AND SC5.C5_I_AGEND NOT IN " + FormatIn( AllTrim( _cIT_NAGEND ) , ";" )
	endif
	
	//================================================================================
	// Filtra Cod Municipio Cliente
	//================================================================================
	If !Empty( MV_PAR02 )
		_cFiltro += " AND SC5.C5_I_CMUN IN " + FormatIn( AllTrim( MV_PAR02 ) , ";" )
	EndIf
	
	//================================================================================
	// Filtra vendedor
	//================================================================================
	If !Empty( MV_PAR03 )
		_cFiltro += " AND SC5.C5_VEND1 IN " + FormatIn( AllTrim( MV_PAR03 ) , ";" )
	EndIf
	
	//================================================================================
	// Filtra Supervisor
	//================================================================================
	If !Empty( MV_PAR04 )
		_cFiltro += " AND SC5.C5_VEND2 IN " + FormatIn( AllTrim( MV_PAR04 ) , ";" )
	EndIf
	
	//================================================================================
 	// Filtra Rede Cliente
	//================================================================================
	If !Empty( MV_PAR05 )
		_cFiltro += " AND SC5.C5_I_GRPVE IN " + FormatIn( AllTrim( MV_PAR05) , ";" )
	EndIf

	//================================================================================
	// Filtra Peso Bruto
	//================================================================================
	If MV_PAR06 > 0 .Or. MV_PAR07 > 0
		_cFiltro += " AND SC5.C5_I_PESBR BETWEEN " + AllTrim(Str(MV_PAR06)) + " AND " + AllTrim(Str(MV_PAR07)) + " "
	EndIf

	//================================================================================
	// Filtra Tipo de Carga
	//================================================================================
	If MV_PAR08 <> 3
		_cFiltro += " AND ( SC5.C5_I_TIPCA = '" + Alltrim(Str(MV_PAR08)) + "' OR SC5.C5_I_TIPCA = '')"
	EndIf

	//================================================================================
	// Filtra Tipo de Agendamento.
	//================================================================================
	If !Empty(MV_PAR09) // MV_PAR09 <> 5
	   //_cFiltro += " AND ( SC5.C5_I_AGEND = '" + AllTrim(Str(MV_PAR09)) + "' OR SC5.C5_I_AGEND = '')"
	   _cFiltro += " AND SC5.C5_I_AGEND IN " + FormatIn( AllTrim( MV_PAR09 ) , ";" )
	EndIf


EndIf

//=====================================================================================================================================//
// AWF - Projeto de unifica��o de pedidos de troca nota - Chamado 16548      
// Filtra Pedidos: - cujo pre�o informado est�o fora da tabela de pre�os praticada pela empresa;
//                 - A libera��o de pre�o est� vencida ou ocorreu mudan�a nos pre�os do pedido
//                 - O cliente do pedido foi alterado desde a libera��o de pre�o
//                 - Bloqueado por libera��o completa de cr�dito expirada
//                 - Bloqueado por valor de libera��o completa excedido
//                 - bonifica��o bloqueado
//                 - bonifica��o rejeitado
//                 - Avalia��o de cr�dito do pedido n�o foi aprovada
//                 - Trazer somente os pedidos que nao tema carga automatica gerada
//=====================================================================================================================================//

_cFiltro += " AND ( "
_cFiltro += " ( SC5.C5_I_BLCRE = 'L' OR SC5.C5_I_BLCRE = '' )"//Credito
_cFiltro += " AND  (SC5.C5_I_BLPRC ='L' OR  SC5.C5_I_BLPRC ='')"//Preco
_cFiltro += " AND  (SC5.C5_I_BLOQ = 'L' OR SC5.C5_I_BLOQ = '')"//Bonificacao
_cFiltro += " ) "
_cFiltro += " AND ( SC5.C5_I_CARGA = '' )"//Trazer somente os pedidos que nao tema carga automatica gerada

//=====================================================================================================================================//

//================================================================================
// Filtra Pedidos Liberados Parcialmente
//================================================================================
_cFiltro += " AND NOT EXISTS ( "
_cFiltro +=                    " SELECT "
_cFiltro +=                    "    SC6L.C6_ITEM "
_cFiltro +=                    " FROM "+ RetSqlName('SC6') +" SC6L "
_cFiltro +=                    " WHERE "
_cFiltro +=                    "     SC6L.D_E_L_E_T_ = ' ' "
_cFiltro +=                    " AND SC6L.C6_FILIAL  = SC9.C9_FILIAL "
_cFiltro +=                    " AND SC6L.C6_NUM     = SC9.C9_PEDIDO "
_cFiltro +=                    " AND NOT EXISTS ( SELECT SC9L.C9_PEDIDO FROM "+ RetSqlName('SC9') +" SC9L "
_cFiltro +=                    "                  WHERE SC9L.D_E_L_E_T_ = ' ' "
_cFiltro +=                    "                  AND   SC9L.C9_FILIAL  = SC6L.C6_FILIAL "
_cFiltro +=                    "                  AND   SC9L.C9_PEDIDO  = SC6L.C6_NUM "
_cFiltro +=                    "                  AND   SC9L.C9_ITEM    = SC6L.C6_ITEM 
_cFiltro +=                    "                  AND   SC9L.C9_BLEST	= ' ' "
_cFiltro +=                    "                  AND   SC9L.C9_BLCRED  = ' ' ) "
_cFiltro += " ) "



//================================================================================
//Valida��o usu�rioxfilialxarmaz�m
//================================================================================

//verifica se usu�rio tem registro de restri��o de armaz�ns na filial
DBSelectArea("Z14")
Z14->( DBSetOrder(1) )
	
If Z14->( DBSeek( xFilial("Z14") + alltrim(RetCodUsr()) + xfilial("SC9") ) ) 

	//se tem restri��o filtra para aparecer tudo que n�o � PA ou que esteja dentro da lista de armaz�ns permitidos
	_cFiltro += " AND ( "
	_cFiltro += " (  SELECT "
	_cFiltro += "      B1_TIPO " 
	_cFiltro += "    FROM " + RetSqlName('SB1') + " SB1T "
	_cFiltro += "    WHERE "
	_cFiltro += "      SB1T.B1_COD = SC9.C9_PRODUTO 
	_cFiltro += "      AND SB1.B1_FILIAL = '" + xfilial("SB1") + "'"
	_cFiltro += "      AND ROWNUM = 1 "
	_cFiltro += "      AND SB1T.D_E_L_E_T_ = ' ') <> 'PA' " 
	_cFiltro += " OR SC9.C9_LOCAL IN (" + STRTRAN ( alltrim(Z14->Z14_LOCAL) , ";" , ",")  + ")"
	_cFiltro += " ) "
	
	_cFiltro += " AND NOT EXISTS ( (  SELECT  C9_LOCAL  FROM " + RetSqlName('SC9') + " SC9T WHERE"
   	_cFiltro += "     SC9T.C9_FILIAL = SC9.C9_FILIAL"
   	_cFiltro += "     AND SC9T.C9_PEDIDO = SC9.C9_PEDIDO"
   	_cFiltro += "     AND ( SELECT B1_TIPO FROM " + RetSqlName('SB1') + " SB1T2 WHERE SB1T2.B1_FILIAL = ' ' 
   	_cFiltro += "               AND SB1T2.B1_COD = SC9T.C9_PRODUTO 
   	_cFiltro += "               AND SB1T2.D_E_L_E_T_ = ' ' AND ROWNUM =1) = 'PA'
  	_cFiltro += "     AND SC9T.C9_LOCAL NOT IN (" + STRTRAN ( alltrim(Z14->Z14_LOCAL) , ";" , ",") + ")"
   	_cFiltro += "     and SC9T.D_E_L_E_T_ = ' ' ) )

Endif


//=========================================== 
//N�o mostra pedidos enviados para RDC
//=========================================== 
_cFiltro += " AND C5_I_ENVRD <> 'S' "

//=========================================== 
//Novo tratamento para cortes e desmembramentos de pedidos - IGNORAR: M->C5_I_BLSLD = "S"
//=========================================== 
If SC5->(FIELDPOS("C5_I_BLSLD")) > 0
   _cFiltro += " AND C5_I_BLSLD = 'N' "
EndIf


//=========================================== 
//N�o mostra pedidos de de Faturamento do Triangular
//=========================================== 
_cOperTriangular:= ALLTRIM(U_ITGETMV( "IT_OPERTRI","05,42"))// Tipos de opera��es da opera��o trigular
_cOperFat:= LEFT(_cOperTriangular,2)//05
_cFiltro += " AND C5_I_OPER <> '"+_cOperFat+"' "//05

//=========================================== 
// Restaura os par�metros originais da rotina
//===========================================

For nLoop := 1 To nQdePerg
	&( "MV_PAR" + StrZero( nLoop, 2 ) )	:= aPergOld[ nLoop ]
Next nLoop

_lPerOM200QRY := !_lPerOM200QRY

Return( _cFiltro )

/*
===============================================================================================================================
Programa----------: LSTMU2                                 
Autor-------------: Jeane
Data da Criacao---: 05/08/2009
===============================================================================================================================
Descri��o---------: Consulta para a pergunta de munic�pios
===============================================================================================================================
Parametros--------: _cPerg - Configura��o das Perguntas
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function LSTMU2()

Local _nI			:= 0

Private nTam		:= 0
Private nMaxSelect	:= 0
Private aCat		:= {}
Private MvRet		:= Alltrim( ReadVar() )
Private MvPar		:= ""
Private cTitulo		:= ""
Private MvParDef	:= ""

//#IFDEF WINDOWS
//	oWnd := GetWndDefault()
//#ENDIF

//================================================================================
// Tratamento para carregar variaveis da lista de opcoes j� selecionadas
//================================================================================
nTam		:= 5
nMaxSelect	:= 16 //16 * 6 = 96 (cod(5) +";") = 6
cTitulo		:= "Municipios"

CC2->( DBSetOrder(1) )
CC2->( DBSeek( xFilial("CC2") ) )
While CC2->(!Eof()) .AND. CC2->CC2_FILIAL == xFilial("CC2")
	
	//================================================================================
	// Caso tenha informado o(s) estado(s) s� adiciona municipios referentes
	//================================================================================
	If !Empty( MV_PAR01 )
	
    	If CC2->CC2_EST $ AllTrim( MV_PAR01 )
    	
    		MvParDef += AllTrim(CC2->CC2_CODMUN)
			aAdd( aCat , AllTrim( CC2->CC2_MUN ) )
			
    	EndIf
    	
	Else
	
		MvParDef += AllTrim( CC2->CC2_CODMUN )
		aAdd( aCat , AllTrim( CC2->CC2_MUN ) )
		
	EndIf
	
	CC2->( DBSkip() )
EndDo

If Len( AllTrim( &MvRet ) ) == 0

	MvPar  := PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len(aCat) )
	&MvRet := PadR( AllTrim( StrTran( &MvRet , ";" , "" ) ) , Len(aCat) )

Else

	MvPar  := AllTrim( StrTran( &MvRet , ";" , "/" ) )

EndIf

//================================================================================
// Executa funcao que monta tela de opcoes
//================================================================================
IF F_Opcoes( @MvPar , cTitulo , aCat , MvParDef , 12 , 49 , .F. , nTam , nMaxSelect )

   //================================================================================
   // Tratamento para separar retorno com barra ";"
   //================================================================================
   &MvRet := ""

   For _nI := 1 To Len( MvPar ) Step nTam

	   If !( SubStr( MvPar , _nI , 1 ) $ " |*" )
	   	  &MvRet += SubStr( MvPar , _nI , nTam ) + ";"
	   EndIf
	
   Next

//================================================================================
// Trata para tirar o ultimo caracter
//================================================================================
   &MvRet := SubStr( &MvRet , 1 , Len( &MvRet ) - 1 )

ENDIF

Return(.T.)
