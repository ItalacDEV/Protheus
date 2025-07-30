/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alexandre V.  | 20/01/2015 | Verifica��o para buscar apenas as cargas 'Faturadas' no per�odo, pois existem casos onde as
              |            | mesmas s�o geradas em um per�odo e faturadas em outro. Chamado 8635
-------------------------------------------------------------------------------------------------------------------------------
Alexandre V.  | 08/06/2015 | Atualiza��o da rotina para corre��o da chamada da tabela na Query. Chamado 10463
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/09/2019 | Retirada chamada da fun��o itputx1. Chamado 28346 
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"

#Define CRLF	Chr(13)+Chr(10)

/*
===============================================================================================================================
Programa----------: MGPE001
Autor-------------: Fabiano Dias
Data da Criacao---: 10/09/2010
===============================================================================================================================
Descri��o---------: Gera��o do arquivo TXT com o somat�rio total por Aut�nomo
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGPE001()

Local _cPerg := "MGPE001"

Pergunte( _cPerg )

//====================================================================================================
// Montagem da tela de processamento
//====================================================================================================
If MessageBox(	'Essa Rotina tem o objetivo de processar a gera��o do arquivo texto (TXT) com a rela��o de Aut�nomos e valores Totais do per�odo '			+;
				'conforme os par�metros definidos pelo usu�rio.'																					+ CRLF	+;
				'O Layout do arquivo trar� o c�digo do aut�nomo e o valor pago, independente de Filial. Confirma a gera��o do arquivo?'						,;
				'Confirma��o!' , 04 ) == 6
	
	Processa( {|| MGPE001TXT() } , 'Aguarde!' , 'Processando os dados...' )
	
Else
	Aviso( 'Aten��o!' , 'Opera��o cancelada pelo usu�rio!' , {'Fechar'} )
EndIf

Return

/*
===============================================================================================================================
Programa----------: MGPE001TXT
Autor-------------: Fabiano Dias
Data da Criacao---: 10/09/2010
===============================================================================================================================
Descri��o---------: Gera��o do arquivo TXT com o somat�rio total por Aut�nomo
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MGPE001TXT()

Local _cAlias		:= GetNextAlias()
Local _cQuery		:= ''
Local _cArqTxt		:= ''
Local _cLin			:= ''
Local _nHdl			:= 0
Local _nCont		:= 0

//====================================================================================================
// Validacoes dos Parametros - � obrigat�rio informar a data inicial e final para gerar o arquivo
//====================================================================================================
If Empty( MV_PAR01 ) .Or. Empty( MV_PAR02 ) .Or. Empty( MV_PAR05 ) 

	MessageBox( 'Os par�metros obrigat�rios n�o foram informados! Verifique os par�metros para processar corretamente a rotina.' , 'Atencao!' , 16 )
	Return()

EndIf

_cArqTxt	:= AllTrim( MV_PAR05 )
_nHdl		:= FCreate( _cArqTxt )

//====================================================================================================
// Processa a cria��o do arquivo f�sico
//====================================================================================================
If _nHdl == -1
	MessageBox( 'O arquivo: '+ _cArqTxt +' n�o foi criado! Verifique os par�metros e o acesso ao diret�rio de destino.' , 'Atencao!' , 16 )
	Return()
Endif     

//====================================================================================================
// Seleciona os produtores donos de tanque e seu volume de Leite no per�odo
//====================================================================================================
_cQuery := " SELECT "
_cQuery += "     AUTONOMO , "
_cQuery += "     SUM( TOTAL ) AS TOTAL "
_cQuery += " FROM ( "

_cQuery += "        SELECT
_cQuery += "            ZZ2.ZZ2_AUTONO AS AUTONOMO,
_cQuery += "            COALESCE( SUM( ZZ2.ZZ2_TOTAL ) , 0 ) AS TOTAL
_cQuery += "        FROM "+ RetSqlName('ZZ2') +" ZZ2 "
_cQuery += "        WHERE "
_cQuery += "            ZZ2.D_E_L_E_T_ =  ' ' "
_cQuery += "        AND ZZ2.ZZ2_CARGA  <> ' ' "
_cQuery += "        AND ZZ2.ZZ2_AUTONO BETWEEN '"+ MV_PAR03       +"' AND '"+ MV_PAR04       +"' "
_cQuery += "        AND EXISTS ( SELECT 1 FROM "+ RetSqlName('SF2') +" SF2 "
_cQuery += "                     WHERE "
_cQuery += "                         SF2.D_E_L_E_T_ = ' ' "
_cQuery += "                     AND SF2.F2_EMISSAO BETWEEN '"+ DtoS(MV_PAR01) +"' AND '"+ DtoS(MV_PAR02) +"' "
_cQuery += "                     AND SF2.F2_FILIAL  = ZZ2.ZZ2_FILIAL "
_cQuery += "                     AND SF2.F2_CARGA   = ZZ2.ZZ2_CARGA ) "
_cQuery += "        GROUP BY ZZ2.ZZ2_AUTONO "

_cQuery += "        UNION ALL "

_cQuery += "        SELECT "
_cQuery += "            ZZ2.ZZ2_AUTONO AS AUTONOMO , "
_cQuery += "            COALESCE( SUM( ZZ2.ZZ2_TOTAL ) , 0 ) AS TOTAL "
_cQuery += "        FROM "+ RetSqlName('ZZ2') +" ZZ2 "
_cQuery += "        INNER JOIN "+ RetSqlName('SA2') +" SA2 "
_cQuery += "        ON
_cQuery += "          ( SA2.A2_I_AUTAV = ZZ2.ZZ2_AUTONO
_cQuery += "         OR SA2.A2_I_AUT   = ZZ2.ZZ2_AUTONO )
_cQuery += "        AND SA2.D_E_L_E_T_ = ' '
_cQuery += "        INNER JOIN "+ RetSqlName('SE2') +" SE2 "
_cQuery += "        ON "
_cQuery += "            SE2.E2_FILIAL  = ZZ2.ZZ2_FILIAL "
_cQuery += "        AND SE2.E2_NUM     = ZZ2.ZZ2_RECIBO "
_cQuery += "        AND SE2.E2_PREFIXO = 'AUT' "
_cQuery += "        AND SE2.E2_TIPO    = 'RPA' "
_cQuery += "        AND SE2.E2_FORNECE = SA2.A2_COD "
_cQuery += "        AND SE2.E2_LOJA    = SA2.A2_LOJA "
_cQuery += "        AND SE2.D_E_L_E_T_ = ' ' "
_cQuery += "        WHERE
_cQuery += "            ZZ2.D_E_L_E_T_ = ' '
_cQuery += "        AND ZZ2.ZZ2_CARGA  = ' '
_cQuery += "        AND ZZ2.ZZ2_AUTONO BETWEEN '"+ MV_PAR03       +"' AND '"+ MV_PAR04       +"' "
_cQuery += "        AND SE2.E2_EMISSAO BETWEEN '"+ DtoS(MV_PAR01) +"' AND '"+ DtoS(MV_PAR02) +"' "
_cQuery += "        GROUP BY ZZ2_AUTONO "

_cQuery += " ) QRY "
_cQuery += " GROUP BY AUTONOMO "
_cQuery += " ORDER BY AUTONOMO "

If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .T. )

ProcRegua(0)

DBSelectArea(_cAlias)
(_cAlias)->( DBGotop() )
While (_cAlias)->( !Eof() )

	_nCont++
	IncProc( "Processando registros... ["+ StrZero( _nCont , 6 ) +"]" )
	
	_cLin 	:= PADR( (_cAlias)->AUTONOMO , 6 ) +" "								// Codigo do Autonomo
	_cLin 	+= PADL( AllTrim( Str( (_cAlias)->TOTAL , 17 , 2 ) ) , 17 , "0" )	// Valor total
	_cLin	+= CRLF
	
	FWrite( _nHdl , _cLin )
    
(_cAlias)->( DBSkip() )
EndDo

(_cAlias)->( DBCloseArea() )

//====================================================================================================
// Libera o arquivo gerado
//====================================================================================================
FClose( _nHdl )

Aviso( 'Conclu�do!' , 'Arquivo gerado com sucesso em:' +CRLF+ _cArqTxt , {'Ok'} , 2 )

Return()