/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alexandre V.  | 10/03/2015 | Corre��o de refer�ncia � vari�vel de ambiente na montagem do SQL de consulta para o relat�rio
			  |            | que estava apresentando erro durante a execu��o. Chamado 9281
-------------------------------------------------------------------------------------------------------------------------------
Alexandre V.  | 23/03/2016 | Ajuste para padronizar a utiliza��o de rotinas de consultas customizadas. Chamado 14774
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/09/2019 | Retirada chamada da fun��o itputx1. Chamado 28346 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 28/10/2021 | Criada uma Mensagem para quando n�o tiver dados. Chamado 38121
-------------------------------------------------------------------------------------------------------------------------------
Igor Melga�o  | 03/04/2024 | Inclus�o de parametros de filtro. Chamado 46774
===============================================================================================================================
 Analista     - Programador  - Inicio   - Envio    - Chamado - Motivo da Altera��o
=====================================================================================================================================================================================
Ant�nio Ramos - Julio Paz    - 04/07/25 - 07/07/25 - 51084   - Inclus�o de duas novas colunas conforme tipo de movimenta��o: D1_QUANT (Entrada) e D2_QUANT (Sa�da).
=====================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"

/*
===============================================================================================================================
Programa----------: MFIS001
Autor-------------: Lucas Borges
Data da Criacao---: 12/04/2012
===============================================================================================================================
Descri��o---------: Fun��o para gerar rela��o de documentos fiscais para confer�ncia externa - SPED PIS/COFINS
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MFIS001()

Local _cPerg := "MFIS001"

DO WHILE .T.
   If Pergunte( _cPerg )
   	  Processa( {|| MFIS001PRC() } , 'Aguarde!' , 'Iniciando o processamento...' )
   	  LOOP
   EndIf
   EXIT
ENDDO

Return()
                          
/*
===============================================================================================================================
Programa----------: MFIS001PRC
Autor-------------: Lucas Borges
Data da Criacao---: 12/04/2012
===============================================================================================================================
Descri��o---------: Fun��o que processa a leitura e organiza��o dos dados
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MFIS001PRC()

Local _aHeader	:= {}
Local _aDados	:= {}
Local _cFiltro	:= "% "
Local _nReg		:= 0

Private _cAlias	:= GetNextAlias()

//====================================================================================================
// Configura o Cabe�alho
//====================================================================================================
_aHeader := {	"Tipo Mov."			, "Codigo Filial"			, "Filial"			, "Data Emissao"	, "Data Entrada"		,;
				"Tipo"				, "Especie"					, "Serie"			, "Nota Fiscal"		, "Cliente/Fornecedor"	,;
				"Loja"				, "Nome Cliente Fornecedor"	, "Tipo Pessoa"		, "Estado"			, "Item"				,;
				"Codigo Produto"	, "Descricao do Produto"	, "NCM"				, "TES"				, "CFOP"				,;
				"Valor Total"		, "Base PIS"				, "Aliquota PIS"	, "Valor PIS"		, "CST PIS"				,;
				"Base COFINS"		, "Aliquota COFINS"			, "Valor COFINS"	, "CST COFINS"		, "Codigo Base Credito"	,;
				"Natureza Frete"	, "Tabela Natureza Receita"	, "Codigo Natureza Receita", "Quantidade"						 }

//====================================================================================================
// Verifica o filtro por Filiais - Incluido por Carlos Cleber 23/12/13
//====================================================================================================
If !Empty( MV_PAR01 )
_cFiltro += " AND FT.FT_FILIAL  IN "+ FormatIn( Alltrim(MV_PAR01) , ";" )
EndIf

_cFiltro += " AND FT.FT_ENTRADA BETWEEN '"+ DTOS( MV_PAR02 ) +"' AND '"+ DTOS(MV_PAR03) +"' "

If !Empty( MV_PAR06 )
   _cFiltro += " AND FT.FT_CSTPIS = '" +  MV_PAR06 + "' " 
EndIf

If !Empty( MV_PAR07 )
   _cFiltro += " AND FT.FT_CSTCOF = '" + MV_PAR07 + "' " 
EndIf

_cFiltro += " %"

If MV_PAR04 == 1 // Entradas

	BeginSql alias _cAlias

		SELECT 
		      'ENTRADA'			AS ENTRADA_SAIDA,
		      FT.FT_FILIAL		AS CODIGO_FILIAL, 
		      FT.FT_EMISSAO		AS DATA_EMISSAO,
		      FT.FT_ENTRADA		AS DATA_ENTRADA, 
		      D1.D1_TIPO		AS TIPO,
		      FT.FT_ESPECIE		AS ESPECIE,	
		      FT.FT_SERIE		AS SERIE,
		      FT.FT_NFISCAL		AS NOTA_FISCAL, 
		      FT.FT_CLIEFOR		AS CLIE_FOR,
		      FT.FT_LOJA		AS LOJA,
		      A2.A2_NOME		AS NOME_FORNECEDOR_CLIENTE,
		      A2.A2_TIPO		AS FISICA_JURIDICA,
		      A2.A2_EST	 		AS UF,
		      FT.FT_ITEM		AS ITEM,
		      FT.FT_PRODUTO		AS CODIGO_PRODUTO,
		      B1.B1_DESC		AS DESC_PRODUTO,
		      B1.B1_POSIPI		AS NCM,
		      D1.D1_TES			AS TES,
		      FT.FT_CFOP		AS CFOP,
		      D1.D1_TOTAL		AS VALOR_TOTAL,
		      FT.FT_BASEPIS		AS BASE_PIS, 
		      FT.FT_ALIQPIS		AS ALIQ_PIS, 
		      FT.FT_VALPIS		AS VALOR_PIS,
		      FT.FT_CSTPIS		AS CST_PIS,
		      FT.FT_BASECOF		AS BASE_COFINS, 
		      FT.FT_ALIQCOF		AS ALIQ_COFINS, 
		      FT.FT_VALCOF		AS VALOR_COFINS,
		      FT.FT_CSTCOF		AS CST_COFINS,
		      FT.FT_CODBCC		AS CODIGO_BASE_CREDITO,
		      FT.FT_INDNTFR		AS NATUREZA_FRETE,
		      FT.FT_TNATREC		AS TABELA_NATUREZA_RECEITA,
		      FT.FT_CNATREC		AS CODIGO_NATUREZA_RECEITA,
			  D1.D1_QUANT		AS QUANTNF
		FROM %table:SD1% D1 , %table:SB1% B1 , %table:SA2% A2 , %table:SFT% FT   
		WHERE
		    D1.%notDel%
		AND B1.%notDel%
		AND A2.%notDel%
		AND FT.%notDel%
		AND D1.D1_COD       = B1.B1_COD 
		AND D1.D1_FORNECE   = A2.A2_COD 
		AND D1.D1_LOJA      = A2.A2_LOJA
		AND FT.FT_FILIAL    = D1.D1_FILIAL
		AND FT.FT_NFISCAL   = D1.D1_DOC
		AND FT.FT_SERIE     = D1.D1_SERIE
		AND FT.FT_CLIEFOR   = D1.D1_FORNECE
		AND FT.FT_LOJA      = D1.D1_LOJA
		AND FT.FT_EMISSAO   = D1.D1_EMISSAO
		AND FT.FT_FORMUL    = D1.D1_FORMUL
		AND FT.FT_ITEM	    = D1.D1_ITEM
		AND FT.FT_PRODUTO	= D1.D1_COD
		AND FT.FT_TIPOMOV   = 'E'   
		AND D1.D1_TIPO      NOT IN ('D','B')  
		%exp:_cFiltro%
		
		UNION ALL
		
		SELECT 
		      'ENTRADA'			AS ENTRADA_SAIDA,
		      FT.FT_FILIAL		AS CODIGO_FILIAL, 
		      FT.FT_EMISSAO		AS DATA_EMISSAO,
		      FT.FT_ENTRADA		AS DATA_ENTRADA, 
		      D1.D1_TIPO		AS TIPO,
		      FT.FT_ESPECIE		AS ESPECIE,
		      FT.FT_SERIE		AS SERIE,
		      FT.FT_NFISCAL		AS NOTA_FISCAL, 
		      FT.FT_CLIEFOR		AS CLIE_FOR,
		      FT.FT_LOJA		AS LOJA,
		      A1.A1_NOME		AS NOME_FORNECEDOR_CLIENTE,
		      A1.A1_PESSOA		AS FISICA_JURIDICA,
		      A1.A1_EST			AS UF,
		      FT.FT_ITEM		AS ITEM,
		      FT.FT_PRODUTO		AS CODIGO_PRODUTO,
		      B1.B1_DESC		AS DESC_PRODUTO,
		      B1.B1_POSIPI		AS NCM,
		      D1.D1_TES			AS TES,
		      FT.FT_CFOP		AS CFOP,
		      D1.D1_TOTAL		AS VALOR_TOTAL,
		      FT.FT_BASEPIS		AS BASE_PIS, 
		      FT.FT_ALIQPIS		AS ALIQ_PIS, 
		      FT.FT_VALPIS		AS VALOR_PIS,
		      FT.FT_CSTPIS		AS CST_PIS,
		      FT.FT_BASECOF		AS BASE_COFINS, 
		      FT.FT_ALIQCOF		AS ALIQ_COFINS, 
		      FT.FT_VALCOF		AS VALOR_COFINS,
		      FT.FT_CSTCOF		AS CST_COFINS,
		      FT.FT_CODBCC		AS CODIGO_BASE_CREDITO,
		      FT.FT_INDNTFR		AS NATUREZA_FRETE,
		      FT.FT_TNATREC		AS TABELA_NATUREZA_RECEITA,
		      FT.FT_CNATREC		AS CODIGO_NATUREZA_RECEITA,
			  D1.D1_QUANT		AS QUANTNF
		FROM %table:SD1% D1 , %table:SB1% B1 , %table:SA1% A1 , %table:SFT% FT
		WHERE
		    D1.%notDel%
		AND B1.%notDel%
		AND A1.%notDel%
		AND FT.%notDel%
		AND D1.D1_COD       = B1.B1_COD 
		AND D1.D1_FORNECE   = A1.A1_COD 
		AND D1.D1_LOJA      = A1.A1_LOJA
		AND FT.FT_FILIAL    = D1.D1_FILIAL
		AND FT.FT_NFISCAL   = D1.D1_DOC
		AND FT.FT_SERIE     = D1.D1_SERIE
		AND FT.FT_CLIEFOR   = D1.D1_FORNECE
		AND FT.FT_LOJA      = D1.D1_LOJA
		AND FT.FT_EMISSAO   = D1.D1_EMISSAO
		AND FT.FT_FORMUL    = D1.D1_FORMUL
		AND FT.FT_ITEM		= D1.D1_ITEM
		AND FT.FT_PRODUTO	= D1.D1_COD
		AND FT.FT_TIPOMOV   = 'E'  
		AND D1.D1_TIPO      IN ('D','B')
		%exp:_cFiltro%
		
		ORDER BY ENTRADA_SAIDA , CODIGO_FILIAL , DATA_ENTRADA , SERIE , NOTA_FISCAL , ITEM

	EndSql

Else

	BeginSql alias _cAlias 	   	                                 

		SELECT 
		      'SAIDA'			AS ENTRADA_SAIDA,
		      FT.FT_FILIAL		AS CODIGO_FILIAL, 
		      FT.FT_EMISSAO		AS DATA_EMISSAO,
		      FT.FT_ENTRADA		AS DATA_ENTRADA, 
		      D2.D2_TIPO		AS TIPO,  
		      FT.FT_ESPECIE		AS ESPECIE,		      
		      FT.FT_SERIE		AS SERIE,
		      FT.FT_NFISCAL		AS NOTA_FISCAL, 
		      FT.FT_CLIEFOR		AS CLIE_FOR,
		      FT.FT_LOJA		AS LOJA,
		      A2.A2_NOME		AS NOME_FORNECEDOR_CLIENTE,
		      A2.A2_TIPO		AS FISICA_JURIDICA,
		      A2.A2_EST			AS UF,
		      FT.FT_ITEM		AS ITEM,
		      FT.FT_PRODUTO		AS CODIGO_PRODUTO,
		      B1.B1_DESC		AS DESC_PRODUTO,
		      B1.B1_POSIPI		AS NCM,
		      D2.D2_TES			AS TES,
		      FT.FT_CFOP		AS CFOP,
		      D2.D2_TOTAL		AS VALOR_TOTAL,
		      FT.FT_BASEPIS		AS BASE_PIS, 
		      FT.FT_ALIQPIS		AS ALIQ_PIS, 
		      FT.FT_VALPIS		AS VALOR_PIS,
		      FT.FT_CSTPIS		AS CST_PIS,
		      FT.FT_BASECOF		AS BASE_COFINS, 
		      FT.FT_ALIQCOF		AS ALIQ_COFINS, 
		      FT.FT_VALCOF		AS VALOR_COFINS,
		      FT.FT_CSTCOF		AS CST_COFINS,
		      FT.FT_CODBCC		AS CODIGO_BASE_CREDITO,
		      FT.FT_INDNTFR		AS NATUREZA_FRETE,
		      FT.FT_TNATREC		AS TABELA_NATUREZA_RECEITA,
		      FT.FT_CNATREC		AS CODIGO_NATUREZA_RECEITA,
			  D2.D2_QUANT		AS QUANTNF
		FROM %table:SD2% D2 , %table:SB1% B1 , %table:SA2% A2 , %table:SFT% FT
		WHERE
		    D2.%notDel%
		AND B1.%notDel%
		AND A2.%notDel%
		AND FT.%notDel%
		AND D2.D2_COD       = B1.B1_COD 
		AND D2.D2_CLIENTE   = A2.A2_COD 
		AND D2.D2_LOJA      = A2.A2_LOJA
		AND FT.FT_FILIAL    = D2.D2_FILIAL
		AND FT.FT_NFISCAL   = D2.D2_DOC
		AND FT.FT_SERIE     = D2.D2_SERIE
		AND FT.FT_CLIEFOR   = D2.D2_CLIENTE
		AND FT.FT_LOJA      = D2.D2_LOJA
		AND FT.FT_EMISSAO   = D2.D2_EMISSAO
		AND FT.FT_FORMUL    = D2.D2_FORMUL
		AND FT.FT_ITEM	    = D2.D2_ITEM
		AND FT.FT_PRODUTO	= D2.D2_COD
		AND FT.FT_TIPOMOV   = 'S'  
		AND D2.D2_TIPO      IN ('D','B')
		%exp:_cFiltro%
		
		UNION ALL
		
		SELECT 
		      'SAIDA'			AS ENTRADA_SAIDA,
		      FT.FT_FILIAL		AS CODIGO_FILIAL, 
		      FT.FT_EMISSAO		AS DATA_EMISSAO,
		      FT.FT_ENTRADA		AS DATA_ENTRADA, 
		      D2.D2_TIPO		AS TIPO,
		      FT.FT_ESPECIE		AS ESPECIE,		      
		      FT.FT_SERIE		AS SERIE,
		      FT.FT_NFISCAL		AS NOTA_FISCAL, 
		      FT.FT_CLIEFOR		AS CLIE_FOR,
		      FT.FT_LOJA		AS LOJA,
		      A1.A1_NOME		AS NOME_FORNECEDOR_CLIENTE,
		      A1.A1_PESSOA		AS FISICA_JURIDICA,
		      A1.A1_EST			AS UF,
		      FT.FT_ITEM		AS ITEM,
		      FT.FT_PRODUTO		AS CODIGO_PRODUTO,
		      B1.B1_DESC		AS DESC_PRODUTO,
		      B1.B1_POSIPI		AS NCM,
		      D2.D2_TES			AS TES,
		      FT.FT_CFOP		AS CFOP,
		      D2.D2_TOTAL		AS VALOR_TOTAL,
		      FT.FT_BASEPIS		AS BASE_PIS, 
		      FT.FT_ALIQPIS		AS ALIQ_PIS, 
		      FT.FT_VALPIS		AS VALOR_PIS,
		      FT.FT_CSTPIS		AS CST_PIS,
		      FT.FT_BASECOF		AS BASE_COFINS, 
		      FT.FT_ALIQCOF		AS ALIQ_COFINS, 
		      FT.FT_VALCOF		AS VALOR_COFINS,
		      FT.FT_CSTCOF		AS CST_COFINS,
		      FT.FT_CODBCC		AS CODIGO_BASE_CREDITO,
		      FT.FT_INDNTFR		AS NATUREZA_FRETE,
		      FT.FT_TNATREC		AS TABELA_NATUREZA_RECEITA,
		      FT.FT_CNATREC		AS CODIGO_NATUREZA_RECEITA,
			  D2.D2_QUANT		AS QUANTNF
		FROM %table:SD2% D2 , %table:SB1% B1 , %table:SA1% A1 , %table:SFT% FT
		WHERE
		    D2.%notDel%
		AND B1.%notDel%
		AND A1.%notDel%
		AND FT.%notDel%
		AND D2.D2_COD       = B1.B1_COD 
		AND D2.D2_CLIENTE   = A1.A1_COD 
		AND D2.D2_LOJA      = A1.A1_LOJA
		AND FT.FT_FILIAL    = D2.D2_FILIAL
		AND FT.FT_NFISCAL   = D2.D2_DOC
		AND FT.FT_SERIE     = D2.D2_SERIE
		AND FT.FT_CLIEFOR   = D2.D2_CLIENTE
		AND FT.FT_LOJA      = D2.D2_LOJA
		AND FT.FT_EMISSAO   = D2.D2_EMISSAO
		AND FT.FT_FORMUL    = D2.D2_FORMUL
		AND FT.FT_ITEM	    = D2.D2_ITEM
		AND FT.FT_PRODUTO   = D2.D2_COD
		AND FT.FT_TIPOMOV   = 'S'
		AND D2.D2_TIPO      NOT IN ('D','B')
		%exp:_cFiltro%
		
		ORDER BY ENTRADA_SAIDA , CODIGO_FILIAL , DATA_ENTRADA , SERIE , NOTA_FISCAL , ITEM
	
	EndSql
	
EndIf

DBSelectArea(_cAlias)
(_cAlias)->( DBGotop() )
Count to _nReg

ProcRegua(_nReg)

DBSelectArea(_cAlias)
(_cAlias)->( DBGotop() )

While (_cAlias)->( !Eof() )

	IncProc( "Processando dados da Filial: " + AllTrim( (_cAlias)->CODIGO_FILIAL ) + ' - DATA: ' + DTOC( STOD( (_cAlias)->DATA_ENTRADA ) ) )
	
	aAdd( _aDados , {					(_cAlias)->ENTRADA_SAIDA   				,;
										(_cAlias)->CODIGO_FILIAL   				,; 
						FWFilialName(,	(_cAlias)->CODIGO_FILIAL ) 				,;
						DTOC( STOD(		(_cAlias)->DATA_EMISSAO ) )				,;
						DTOC( STOD(		(_cAlias)->DATA_ENTRADA ) )				,;
										(_cAlias)->TIPO							,;
										(_cAlias)->ESPECIE						,;      
										(_cAlias)->SERIE						,;
										(_cAlias)->NOTA_FISCAL					,;
										(_cAlias)->CLIE_FOR						,;
										(_cAlias)->LOJA							,;
					MFIS001RC( AllTrim(	(_cAlias)->NOME_FORNECEDOR_CLIENTE ) )	,;
										(_cAlias)->FISICA_JURIDICA				,;
										(_cAlias)->UF							,;
										(_cAlias)->ITEM							,;
										(_cAlias)->CODIGO_PRODUTO				,;
					MFIS001RC( AllTrim(	(_cAlias)->DESC_PRODUTO ) )				,;
										(_cAlias)->NCM							,;
										(_cAlias)->TES							,;
										(_cAlias)->CFOP							,;
										(_cAlias)->VALOR_TOTAL					,;
										(_cAlias)->BASE_PIS						,;
										(_cAlias)->ALIQ_PIS						,;
										(_cAlias)->VALOR_PIS					,;
										(_cAlias)->CST_PIS						,;
										(_cAlias)->BASE_COFINS					,;
										(_cAlias)->ALIQ_COFINS					,;
										(_cAlias)->VALOR_COFINS					,;
										(_cAlias)->CST_COFINS					,;
										(_cAlias)->CODIGO_BASE_CREDITO			,;
										(_cAlias)->NATUREZA_FRETE				,;
										(_cAlias)->TABELA_NATUREZA_RECEITA		,;
										(_cAlias)->CODIGO_NATUREZA_RECEITA		,;
										(_cAlias)->QUANTNF})

(_cAlias)->( DBSkip() )
EndDo

(_cAlias)->( DBCloseArea() )

IF LEN(_aDados) > 0 
   U_ITListBox( 'MFIS001 - Lista de Registros Fiscais' , _aHeader , _aDados , .T. , 1 ) 
ELSE
   U_ITMSG("N�o foram encontrados dados para esses filtros",'Aten��o!',"Tente novamente com outros filtros",3)
ENDIF

Return()   

/*
===============================================================================================================================
Programa----------: MFIS001RC
Autor-------------: Lucas Borges
Data da Criacao---: 12/04/2012
===============================================================================================================================
Descri��o---------: Fun��o para remover caracteres especiais do texto
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MFIS001RC( _cString )

_cString := StrTran( _cString , '&' , "" )
_cString := StrTran( _cString , '<' , "" )
_cString := StrTran( _cString , '>' , "" )
_cString := StrTran( _cString , '%' , "" )
_cString := StrTran( _cString , '~' , "" )
_cString := StrTran( _cString , '^' , "" ) 
_cString := StrTran( _cString , '�' , "" )
_cString := StrTran( _cString , '`' , "" )

Return( _cString )
