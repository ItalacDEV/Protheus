/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Darcio		  |20/06/2016| Chamado 15934. Foi criado relat�rio para apresentar todos os t�tulos que j� tiveram seu fluxo de 
			  |			 | caixa fechado, por�m h� diferen�a na data de fechamento com a data de vencimento real. 
Lucas Borges  |08/10/2024| Chamado 48465. Retirada manipula��o do SX1
===============================================================================================================================
*/
#include "report.ch"
#include "protheus.ch"
/*
===============================================================================================================================
Programa----------: RFIN014
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 20/06/2016
===============================================================================================================================
Descri��o---------: Relat�rio de Fechamento de Fluxo
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RFIN014()
Private oReport		:= Nil
Private oSecEntr_1	:= Nil
Private oSecDado_1	:= Nil

Private oBrkEntr_1	:= Nil

Private _aOrd		:= {  }
Private _cPerg		:= "RFIN014"

pergunte( _cPerg , .T. )

DEFINE REPORT oReport	NAME		_cPerg ;
						TITLE		"Relat�rio de Fechamento de Fluxo" ;
						PARAMETER	_cPerg ;
						ACTION		{|oReport| RFIN014PR( oReport ) } ;
						Description	"Este relat�rio emitir� a rela��o de de Fechamento de Fluxo de acordo com os par�metros informados pelo usu�rio."

//====================================================================================================
// Seta Padrao de impressao como Paisagem
//====================================================================================================
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)

oReport:nFontBody	:= 08
oReport:cFontBody	:= "Courier New"
oReport:nLineHeight	:= 45 // Define a altura da linha.

//====================================================================================================
// Secao dados do Investimento
//====================================================================================================
DEFINE SECTION oSecEntr_1 OF oReport TITLE "Entrada_ordem_1" TABLES "SF2" ORDERS _aOrd
DEFINE CELL NAME "E1_FILIAL" 	OF oSecEntr_1 ALIAS "SF2"  TITLE "Filial"				SIZE 20
DEFINE CELL NAME "E1_PREFIXO"	OF oSecEntr_1 ALIAS "SF2"  TITLE "Prefixo"				SIZE 20
DEFINE CELL NAME "E1_NUM"	  	OF oSecEntr_1 ALIAS "SF2"  TITLE "N�mero"				SIZE 20
DEFINE CELL NAME "E1_CLIENTE"	OF oSecEntr_1 ALIAS "SA1"  TITLE "Cliente"				SIZE 20
DEFINE CELL NAME "E1_LOJA"		OF oSecEntr_1 ALIAS "SF2"  TITLE "Loja"					SIZE 20
DEFINE CELL NAME "E1_NOMCLI"	OF oSecEntr_1 ALIAS "SF2"  TITLE "Raz�o Social"			SIZE 20
DEFINE CELL NAME "E1_VALOR"		OF oSecEntr_1 ALIAS "SF2"  TITLE "Valor"				SIZE 20 PICTURE "@E 99,999,999,999.99"
DEFINE CELL NAME "E1_EMISSAO"	OF oSecEntr_1 ALIAS "SF2"  TITLE "Emiss�o"				SIZE 20
DEFINE CELL NAME "E1_VENCTO"	OF oSecEntr_1 ALIAS "SF2"  TITLE "Venc Original"		SIZE 20
DEFINE CELL NAME "E1_VENCREA"	OF oSecEntr_1 ALIAS "SF2"  TITLE "Venc Atual"			SIZE 20
DEFINE CELL NAME "E1_I_FCFLU"	OF oSecEntr_1 ALIAS "SD2"  TITLE "Data Fechamento"		SIZE 20
DEFINE CELL NAME "E1_I_VCFLU"	OF oSecEntr_1 ALIAS "SF2"  TITLE "Venc Fluxo"			SIZE 20
DEFINE CELL NAME "CUSERLGA"		OF oSecEntr_1 ALIAS "SE1"  TITLE "Usr Alterou"			SIZE 20 BLOCK{|| U_RFIN014NO(QRY1->E1_USERLGA) }

oSecEntr_1:Disable()
oReport:PrintDialog()

Return()

/*
===============================================================================================================================
Programa----------: RFIN014PR
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 20/06/2012
===============================================================================================================================
Descri��o---------: Executa relat�rio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RFIN014PR( oReport )
Local 	_cFiltro  	:= "% "

oSecEntr_1:Enable()

oReport:SetTitle( "Fechamento de Fluxo  - Per�odo de " + DtoC(mv_par05) + " at� "  + DtoC(mv_par06) )
//==============
// Filtra Filial
//==============
If MV_PAR01 == MV_PAR02
	_cFiltro += " E1_FILIAL = '" + MV_PAR01 + "' "
Else
	_cFiltro += " E1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
EndIf
//===============
// Filtra Emiss�o
//===============
If DtoS( MV_PAR03 ) == DtoS( MV_PAR04 )
	_cFiltro += " AND E1_EMISSAO = '" + DtoS( MV_PAR03 ) + "' "
Else
	_cFiltro += " AND E1_EMISSAO BETWEEN '" + DtoS( MV_PAR03 ) + "' AND '" + DtoS( MV_PAR04 ) + "' "
EndIf
//===================================
// Filtra Data de Fechamento do Fluxo
//===================================
If DtoS( MV_PAR05 ) == DtoS( MV_PAR06 )
	_cFiltro += " AND E1_I_FCFLU = '" + DtoS( MV_PAR05 ) + "' "
Else
	_cFiltro += " AND E1_I_FCFLU BETWEEN '" + DtoS( MV_PAR05 ) + "' AND '" + DtoS( MV_PAR06 ) + "' "
EndIf
//===============
// Filtra Cliente
//===============
_cFiltro += " AND E1_CLIENTE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR09 + "' "
//============
// Filtra Loja
//============
_cFiltro += " AND E1_LOJA BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR10 + "' "
//==============================================================================
// As datas de Fechamento do Fluxo e Vencimento do Fluxo devem estar preenchidas
//==============================================================================
_cFiltro += " AND E1_I_FCFLU <> ' ' "
_cFiltro += " AND E1_I_VCFLU <> ' ' "
_cFiltro += " %"

//====================================================================================================
// Executa query para consultar Dados
//====================================================================================================
BEGIN REPORT QUERY oSecEntr_1
		
	BeginSql alias "QRY1"

		SELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_VALOR, E1_EMISSAO, E1_VENCTO, E1_VENCREA, E1_I_FCFLU, E1_I_VCFLU, E1_USERLGA
		FROM %table:SE1% SE1
		WHERE %exp:_cFiltro%
		  AND E1_I_VCFLU <> E1_VENCREA
		  AND SE1.%notDel%
		ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA

	EndSql
		 
END REPORT QUERY oSecEntr_1
		
oSecEntr_1:Print(.T.)

Return()

/*
===============================================================================================================================
Programa----------: RFIN014NO
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 21/06/2016
===============================================================================================================================
Descri��o---------: Fun��o criada descriptografar o c�digo do usu�rio de altera��o, e retornar o nome do mesmo
===============================================================================================================================
Parametros--------: _cUsrLga	-> Recebe o c�digo do usu�rio criptografado
===============================================================================================================================
Retorno-----------: _cRet		-> Retorna o nome do usu�rio
===============================================================================================================================
*/
User Function RFIN014NO(_cUsrLga)
Local _cRet := UsrRetName(SubStr(Embaralha(_cUsrLga,1),3,6))

Return(_cRet)
