/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Walaluer |08/04/2021| Chamado 35710. Nova Coluna de Valor previsto e Tratamento para o novo nivel 3.
Alex Walaluer |15/02/2023| Chamado 43007. Ajsute na coluna C7_TOTAL: (C7_TOTAL+C7_VALIPI +C7_VALFRE+ C7_DESPESA).
Lucas Borges  |08/10/2024| Chamado 48465. Retirada manipulação do SX1
===============================================================================================================================
*/
#include "report.ch"
#include "protheus.ch"
/*
===============================================================================================================================
Programa----------: RCOM001
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 15/02/2016
===============================================================================================================================
Descrição---------: Relatorio utilizado para exibir os dados das entradas.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RCOM001()
Private oReport		:= Nil
//Private oSecEntr_1	:= Nil
//Private oSecDado_1	:= Nil
//Private oSecEntr_2	:= Nil
//Private oSecDado_2	:= Nil
Private oSecDadoA1	:= Nil
Private oSecDadoS1	:= Nil
Private oSecEntrA1	:= Nil
Private oSecEntrS1	:= Nil
Private oSecTotal	:= Nil

Private oBrkEntrA1	:= Nil
Private oBrkEntrS1	:= Nil

Private _aOrd		:= { "Por Investimento"}
Private _cNomeInv	:= "" //Armazena o nome e o codigo de Investimento para ser utilizado na impressao da quebra
//Private _cNumPC     := "" //Armazena o numero do PC e nota fiscal para ser utilizado na impressao da quebra

Private _cPerg		:= "RCOM001"
//Private _nCont		:= 0

pergunte( _cPerg , .F. )

DEFINE REPORT oReport	NAME		_cPerg ;
						TITLE		"Relacao de Investimentos" ;
						PARAMETER	_cPerg ;
						ACTION		{|oReport| RCOM001PR( oReport ) } ;
						Description	"Este relatório emitirá a relação de Investimentos x Pedidos de Compras de acordo com a ordem e parâmetros informados pelo usuário."

//====================================================================================================
// Seta Padrao de impressao como Paisagem
//====================================================================================================
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)

oReport:nFontBody	:= 08
oReport:cFontBody	:= "Courier New"
oReport:nLineHeight	:= 45 // Define a altura da linha.

//====================================================================================================
// Secao dados do Investimento Sintetico
//====================================================================================================
DEFINE SECTION oSecEntrS1 OF oReport TITLE "Entrada_ordem_1" TABLES "SC7" ORDERS _aOrd
DEFINE CELL NAME "INVESTIMENTO"  OF oSecEntrS1 ALIAS "SC7"  TITLE "Nivel 1"		SIZE 20 BLOCK{|| QRY1->C7_I_CDINV}
DEFINE CELL NAME "ZZI_DESINV"    OF oSecEntrS1 ALIAS "SC7"  TITLE "Desc Nivel 1"	SIZE 30

oSecEntrS1:Disable()

//====================================================================================================
// Secao dados do Investimento Analitico
//====================================================================================================
DEFINE SECTION oSecEntrA1 OF oReport TITLE "Entrada_ordem_1" TABLES "SC7" ORDERS _aOrd
DEFINE CELL NAME "INVESTIMENTO"  OF oSecEntrA1 ALIAS "SC7"  TITLE "Nivel 1"		SIZE 20 BLOCK{|| QRY1->C7_I_CDINV}
DEFINE CELL NAME "ZZI_DESINV"    OF oSecEntrA1 ALIAS "SC7"  TITLE "Desc Nivel 1"	SIZE 30

oSecEntrA1:Disable()

//====================================================================================================
// Seção de dados do relatório Sintético
//====================================================================================================
//If MV_PAR05 == 1 
DEFINE SECTION oSecDadoS1 OF oSecEntrS1 TITLE "Dados_Sintetico" TABLES "SC7"
DEFINE CELL NAME "C7_EMISSAO"	OF oSecDadoS1 ALIAS "SC7"  TITLE "Dt PC"
DEFINE CELL NAME "C7_NUM"       OF oSecDadoS1 ALIAS "SC7"  TITLE "Pedido"
DEFINE CELL NAME "C7_I_NFORN"   OF oSecDadoS1 ALIAS "SC7"  TITLE "Razao Social"      SIZE 30
DEFINE CELL NAME "NOTAS"        OF oSecDadoS1 ALIAS ""     TITLE "Notas de Entrada"  SIZE 50 BLOCK{|| u_MontaListaNF(QRY1->C7_FILIAL, QRY1->C7_NUM) }
DEFINE CELL NAME "C7_TOTAL"     OF oSecDadoS1 ALIAS "SC7"  TITLE "Total PC"	         SIZE 20 PICTURE "@E 99,999,999,999.99"
DEFINE CELL NAME "D1_TOTAL"     OF oSecDadoS1 ALIAS "SC7"  TITLE "Total Nota"		 SIZE 20 PICTURE "@E 99,999,999,999.99"
DEFINE CELL NAME "D1_VALDEV"    OF oSecDadoS1 ALIAS "SC7"  TITLE "Total Devolução"	 SIZE 20 PICTURE "@E 99,999,999,999.99"
  
//====================================================================================================
// Desabilita Secao e configura salto em numero de linhas para a proxima secao
//====================================================================================================
oSecDadoS1:Disable()
oSecEntrS1:SetLinesBefore(5)


//====================================================================================================
// Seção da Totalizadora
//====================================================================================================

oSecTotal := TRSection():New(oReport, "Totalizadores", {""}, , .F., .T.)

TRCell():New(oSecTotal, "NIVEL"			    , "", "NIVEL"          , ""  , 10)
TRCell():New(oSecTotal, "INVEST"			, "", "Investimento"   , "@!", 10)
TRCell():New(oSecTotal, "DESCINV"			, "", "Descricao"	   , "@!", 50)
TRCell():New(oSecTotal, "TOTINS"			, "", "Valor Realizado", "@E 999,999,999.99",16)
TRCell():New(oSecTotal, "VLRPREV"			, "", "Valor Previsto" , "@E 999,999,999.99",16)
//====================================================================================================
// Alinhamento de cabecalho
//====================================================================================================
oSecDadoS1:Cell( "C7_TOTAL"   ):SetHeaderAlign("RIGHT")
oSecDadoS1:Cell( "C7_TOTAL"   ):SetClrBack(16777215)
oSecDadoS1:Cell( "C7_TOTAL"   ):SetBorder("<><><>",,,.F.)
oSecDadoS1:Cell( "D1_TOTAL"   ):SetHeaderAlign("RIGHT")
oSecDadoS1:Cell( "D1_VALDEV"  ):SetHeaderAlign("RIGHT")

oSecDadoS1:SetTotalInLine(.F.)
oSecDadoS1:OnPrintLine( {|| _cNomeInv := QRY1->C7_I_CDINV + '-' + ' - ' + AllTrim(QRY1->ZZI_DESINV) } )

//====================================================================================================
// Seção de dados do relatório Analitico.
//====================================================================================================

DEFINE SECTION oSecDadoA1       OF oSecEntrA1 TITLE "Dados_Analitico" TABLES "SC7"
DEFINE CELL NAME "NIVEL2"       OF oSecDadoA1 ALIAS ""     BLOCK {|| POSICIONE("ZZI",1,cFilAnt+QRY1->C7_I_SUBIN,"ZZI_NIVEL2")  } TITLE "Nivel 2"
DEFINE CELL NAME "DESCN2"       OF oSecDadoA1 ALIAS ""     BLOCK {|| POSICIONE("ZZI",1,cFilAnt+QRY1->C7_I_SUBIN,"ZZI_NIVE2D")  } TITLE "Desc Nivel 2" SIZE 45
DEFINE CELL NAME "C7_I_SUBIN"   OF oSecDadoA1 ALIAS "SC7"  TITLE "Nivel 3"
DEFINE CELL NAME "DESCSUBINV"   OF oSecDadoA1 ALIAS ""     BLOCK {|| POSICIONE("ZZI",1,cFilAnt+QRY1->C7_I_SUBIN,"ZZI_DESINV")  } TITLE "Desc Nivel 3" SIZE 45
DEFINE CELL NAME "D1_DTDIGIT"   OF oSecDadoA1 ALIAS "SC7"  TITLE "Dt Ent Nota"
//DEFINE CELL NAME "D1_DOC"     OF oSecDadoA1 ALIAS "SC7"  TITLE "Nota"
DEFINE CELL NAME "NOTAS"        OF oSecDadoA1 ALIAS ""     TITLE "Notas de Entrada"  SIZE 50 BLOCK{|| u_MontaListaNF(QRY1->C7_FILIAL, QRY1->C7_NUM) }
DEFINE CELL NAME "D1_CF"        OF oSecDadoA1 ALIAS "SC7"  TITLE "CFOP"
DEFINE CELL NAME "C7_I_NFORN"   OF oSecDadoA1 ALIAS "SC7"  TITLE "Razao Social" SIZE 20
DEFINE CELL NAME "C7_EMISSAO"	OF oSecDadoA1 ALIAS "SC7"  TITLE "Dt PC"
DEFINE CELL NAME "C7_NUM"       OF oSecDadoA1 ALIAS "SC7"  TITLE "Pedido"
DEFINE CELL NAME "C7_ITEM"      OF oSecDadoA1 ALIAS "SC7"  TITLE "It Ped"
DEFINE CELL NAME "C7_DESCRI"    OF oSecDadoA1 ALIAS "SC7"  TITLE "Descricao"         SIZE 20
DEFINE CELL NAME "C7_QUANT"     OF oSecDadoA1 ALIAS "SC7"  TITLE "Quant PC"	         SIZE 35 PICTURE "@E 99,999,999,999.99"
DEFINE CELL NAME "D1_QUANT"     OF oSecDadoA1 ALIAS "SC7"  TITLE "Quant Nota"        SIZE 35 PICTURE "@E 99,999,999,999.99"
DEFINE CELL NAME "C7_TOTAL"     OF oSecDadoA1 ALIAS "SC7"  TITLE "Total PC"	         SIZE 35 PICTURE "@E 99,999,999,999.99"
DEFINE CELL NAME "D1_TOTAL"     OF oSecDadoA1 ALIAS "SC7"  TITLE "Total Nota"		 SIZE 35 PICTURE "@E 99,999,999,999.99"
DEFINE CELL NAME "D1_VALDEV"    OF oSecDadoA1 ALIAS "SC7"  TITLE "Total Devolução"	 SIZE 35 PICTURE "@E 99,999,999,999.99"
DEFINE CELL NAME "C7_OBS"       OF oSecDadoA1 ALIAS "SC7"  TITLE "Observacoes"       SIZE 250


//====================================================================================================
// Alinhamento de cabecalho
//====================================================================================================
oSecDadoA1:Cell( "C7_TOTAL"   ):SetHeaderAlign("RIGHT")
oSecDadoA1:Cell( "C7_TOTAL"   ):SetClrBack(16777215)
oSecDadoA1:Cell( "C7_TOTAL"   ):SetBorder("<><><>",,,.F.)
oSecDadoA1:Cell( "D1_TOTAL"   ):SetHeaderAlign("RIGHT")
oSecDadoA1:Cell( "D1_VALDEV"  ):SetHeaderAlign("RIGHT")

oSecDadoA1:SetTotalInLine(.F.)
oSecDadoA1:OnPrintLine( {|| _cNomeInv := QRY1->C7_I_CDINV + '-' + ' - ' + AllTrim(QRY1->ZZI_DESINV) } )

//====================================================================================================
// Desabilita Secao e configura salto em numero de linhas para a proxima secao
//====================================================================================================
oSecDadoA1:Disable()
oSecEntrA1:SetLinesBefore(5)

oReport:PrintDialog()

Return()

/*
===============================================================================================================================
Programa----------: RCOM001PR
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 16/02/2012
===============================================================================================================================
Descrição---------: Executa relatório
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RCOM001PR( oReport )
Local 	_cFiltro  	:= "% "
//Local 	_cFiltro2	:= "% "
//Local 	_cCFOPs   	:= ""

If MV_PAR05 == 1 //Sintetico

   oReport:SetTitle( "Relação - Investimentos Sintético - Emissão de " + dtoc(mv_par01) + " até "  + dtoc(mv_par02) )
	
Else //analitico

   oReport:SetTitle( "Relação - Investimentos Analítico - Emissão de " + dtoc(mv_par01) + " até "  + dtoc(mv_par02) )
	
Endif

If MV_PAR06 == 1 //'Sim: Mostra os PCs com NF amarrada' ,;
                 //'Não: Mostra os PCs com ou sem NF amarrada.' }

   _cFiltro  += " AND (select D1_DTDIGIT from " +  retsqlname("SD1") + " d1 "
   _cFiltro  += "             WHERE D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO  = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1_TES <> ' ' AND "
   _cFiltro  += "                   ROWNUM = 1 AND D1.D_E_L_E_T_ = ' ') "
   _cFiltro  += " BETWEEN '"+ DTOS( MV_PAR07 ) +"' AND '"+ DTOS( MV_PAR08 ) +"' "
ENDIF
//====================================================================================================
// Filtra data de entrada
//====================================================================================================
_cFiltro  += " AND C7.C7_EMISSAO BETWEEN '"+ DtoS( MV_PAR01 ) +"' AND '"+ DtoS( MV_PAR02 ) +"' "

//====================================================================================================
// Filtra Investimento
//====================================================================================================
_cFiltro  += " AND C7.C7_I_CDINV BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"' "


IF MV_PAR09 = 2 .AND. !EMPTY(MV_PAR10)

   _cFiltro  += " AND ZZI_DESINV LIKE  '%"+ ALLTRIM(MV_PAR10) +"%' "

ELSEIF MV_PAR09 = 3 .AND. !EMPTY(MV_PAR10)

   _cFiltro  += " AND EXISTS (SELECT 1 FROM " +  RETSQLNAME("ZZI") + " ZZI "
   _cFiltro  += "             WHERE ZZI.ZZI_INVPAI = C7.C7_I_CDINV
   _cFiltro  += "               AND ZZI.ZZI_NIVE2D LIKE '%"+ ALLTRIM(MV_PAR10) +"'% "
   _cFiltro  += "               AND ZZI.D_E_L_E_T_ = ' ') "

ELSEIF MV_PAR09 = 4 .AND. !EMPTY(MV_PAR10)

   _cFiltro  += " AND EXISTS (SELECT 1 FROM " +  RETSQLNAME("ZZI") + " ZZI "
   _cFiltro  += "             WHERE ZZI.ZZI_INVPAI = C7.C7_I_CDINV
   _cFiltro  += "               AND ZZI.ZZI_TIPO = '3' "
   _cFiltro  += "               AND ZZI.ZZI_DESINV LIKE  '%"+ ALLTRIM(MV_PAR10) +"'% "
   _cFiltro  += "               AND ZZI.D_E_L_E_T_ = ' ') "

ENDIF

_cFiltro  += " %"

//====================================================================================================
// Relatorio Sintetico
//====================================================================================================
If MV_PAR05 == 1 //Sintetico
   oSecEntrS1:Enable()
   oSecDadoS1:Enable()

   //====================================================================================================
   // Quebra por Código de Investimento
   //====================================================================================================
   oBrkEntrS1:= TRBreak():New(oSecDadoS1,oSecEntrS1:CELL("INVESTIMENTO"),"Totais - Investimento: " + _cNomeInv,.F.)          
   oBrkEntrS1:SetTotalText( {|| "Totais - Investimento: " + _cNomeInv } )
		
   TRFunction():New( oSecDadoS1:Cell( "C7_TOTAL" )	,NIL,"SUM",oBrkEntrS1,NIL,NIL,NIL,.F.,.T.)
   TRFunction():New( oSecDadoS1:Cell( "D1_TOTAL" )	,NIL,"SUM",oBrkEntrS1,NIL,NIL,NIL,.F.,.T.)
   TRFunction():New( oSecDadoS1:Cell( "D1_VALDEV" ),NIL,"SUM",oBrkEntrS1,NIL,NIL,NIL,.F.,.T.)
Else // Analitico
   //====================================================================================================
   // Relatorio Analitico
   //====================================================================================================
   oSecEntrA1:Enable()
   oSecDadoA1:Enable()

   //====================================================================================================
   // Quebra por Código de Investimento
   //====================================================================================================
   oBrkEntrA1:= TRBreak():New(oSecDadoA1,oSecEntrA1:CELL("INVESTIMENTO"),"Totais - Investimento: " + _cNomeInv,.F.)          
   oBrkEntrA1:SetTotalText( {|| "Totais - Investimento: " + _cNomeInv } )
		
   TRFunction():New( oSecDadoA1:Cell( "C7_TOTAL" )	,NIL,"SUM",oBrkEntrA1,NIL,NIL,NIL,.F.,.T.)
   TRFunction():New( oSecDadoA1:Cell( "D1_TOTAL" )	,NIL,"SUM",oBrkEntrA1,NIL,NIL,NIL,.F.,.T.)
   TRFunction():New( oSecDadoA1:Cell( "D1_VALDEV" ),NIL,"SUM",oBrkEntrA1,NIL,NIL,NIL,.F.,.T.)
EndIf

//====================================================================================================
// Executa query para consultar Dados
//====================================================================================================
If MV_PAR05 == 1 //Sintetico

   BEGIN REPORT QUERY oSecEntrS1

	BeginSql alias "QRY1"
			
		SELECT C7_FILIAL , C7_I_CDINV , ZZI_DESINV,  C7_EMISSAO , C7_NUM, C7_FORNECE , C7_I_NFORN , C7_I_SUBIN,   
		       SUM(C7_TOTAL+C7_VALIPI+C7_VALFRE+C7_DESPESA) C7_TOTAL,
		       SUM(D1_TOTAL)  D1_TOTAL ,
		       SUM(D1_VALDEV) D1_VALDEV 
		FROM (
		   SELECT C7_FILIAL , C7_I_CDINV , ZZI_DESINV , C7_EMISSAO , C7_NUM, C7_FORNECE , C7_I_NFORN  , C7_I_SUBIN,
		        SUM(C7_TOTAL) C7_TOTAL ,
		        SUM(C7_VALIPI) C7_VALIPI, 
                SUM((select SUM(D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA)        from %table:SD1% d1 where D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO  = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1_TES <> ' ' AND D1.D_E_L_E_T_ = ' ')) D1_TOTAL,
                SUM((select SUM(D1_VALDEV+(D1_VALDEV*(D1_IPI/100))) 			from %table:SD1% d1 where D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO  = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1_TES <> ' ' AND D1.D_E_L_E_T_ = ' ')) D1_VALDEV,
                SUM(C7_DESPESA) C7_DESPESA,
                SUM(C7_VALFRE) C7_VALFRE
  		     FROM %table:SC7% C7 
		     LEFT JOIN  %table:ZZI% ZZI ON ZZI.ZZI_FILIAL = C7.C7_FILIAL AND ZZI.ZZI_CODINV = C7.C7_I_CDINV AND ZZI.D_E_L_E_T_= ' '
		     WHERE C7.D_E_L_E_T_= ' ' 
		     AND C7.C7_FILIAL =  %xFilial:SC7% 
		     AND C7.C7_I_APLIC = 'I' 
		     AND C7.C7_I_CDINV <> ' ' 
		     AND C7.C7_RESIDUO <> 'S'
			 %exp:_cFiltro%
		     GROUP BY C7.C7_FILIAL,C7.C7_I_CDINV , ZZI.ZZI_DESINV,C7.C7_EMISSAO, C7.C7_NUM,C7.C7_FORNECE, C7.C7_I_NFORN, C7_I_SUBIN
		     UNION//**********************************
		   SELECT C7_FILIAL , C7_I_CDINV , ZZI_DESINV , C7_EMISSAO , C7_NUM, C7_FORNECE , C7_I_NFORN  ,C7_I_SUBIN,
		        SUM(C7_TOTAL) C7_TOTAL ,
		        SUM(C7_VALIPI) C7_VALIPI, 
                SUM((select SUM(D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA)                 from %table:SD1% d1 where D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO  = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1_TES <> ' ' AND D1.D_E_L_E_T_ = ' ')) D1_TOTAL,
                SUM((select SUM(D1_VALDEV+(D1_VALDEV*(D1_IPI/100))) from %table:SD1% d1 where D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO  = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1_TES <> ' ' AND D1.D_E_L_E_T_ = ' ')) D1_VALDEV,
                SUM(C7_DESPESA) C7_DESPESA,
                SUM(C7_VALFRE) C7_VALFRE
		    FROM  %table:SC7% C7 
		    LEFT JOIN %table:ZZI% ZZI ON ZZI.ZZI_FILIAL = C7.C7_FILIAL AND ZZI.ZZI_CODINV = C7.C7_I_CDINV AND ZZI.D_E_L_E_T_= ' '
		    WHERE C7.D_E_L_E_T_= ' ' 
		    AND C7.C7_FILIAL = %xFilial:SC7% 
		    AND C7.C7_I_APLIC = 'I' 
		    AND C7.C7_I_CDINV <> ' ' 
		    AND C7.C7_RESIDUO =  'S' AND C7_QUJE <> 0
			%exp:_cFiltro% 
		    GROUP BY C7.C7_FILIAL,C7.C7_I_CDINV , ZZI.ZZI_DESINV,C7.C7_EMISSAO, C7.C7_NUM,C7.C7_FORNECE, C7.C7_I_NFORN, C7_I_SUBIN
		)
		GROUP BY C7_FILIAL,C7_I_CDINV, ZZI_DESINV,C7_EMISSAO, C7_NUM,C7_FORNECE, C7_I_NFORN, C7_I_SUBIN
		ORDER  BY C7_FILIAL,C7_I_CDINV,C7_EMISSAO, C7_NUM,C7_FORNECE, C7_I_NFORN                              
		         			
	EndSql
    
   END REPORT QUERY oSecEntrS1
     
Else //Analitico
   BEGIN REPORT QUERY oSecEntrA1
    
	BeginSql alias "QRY1"
			
		SELECT C7_FILIAL , C7_I_CDINV , ZZI_DESINV,  C7_EMISSAO , C7_NUM, C7_FORNECE , C7_I_NFORN ,   
		       (C7_TOTAL+C7_VALIPI+C7_VALFRE+C7_DESPESA) C7_TOTAL , C7_DESCRI, C7_ITEM,  C7_OBS , C7_I_SUBIN,
		       D1_TOTAL ,
		       D1_VALDEV,
		       D1_DOC,
		       D1_DTDIGIT,
		       D1_CF,
			   D1_QUANT,
			   C7_QUANT 
		FROM (
		   SELECT C7_FILIAL , C7_I_CDINV , ZZI_DESINV , C7_EMISSAO , C7_NUM, C7_FORNECE , C7_I_NFORN  ,  C7_DESCRI, C7_ITEM, C7_OBS , C7_I_SUBIN,
		        (C7_TOTAL) C7_TOTAL ,
		        (C7_VALIPI) C7_VALIPI, 
                ((select SUM(D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA)                 from %table:SD1% d1 where D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO  = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1_TES <> ' ' AND D1.D_E_L_E_T_ = ' ')) D1_TOTAL,
                ((select SUM(D1_VALDEV+(D1_VALDEV*(D1_IPI/100))) from %table:SD1% d1 where D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO  = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1_TES <> ' ' AND D1.D_E_L_E_T_ = ' ')) D1_VALDEV,
      	        (select  D1_DOC                      from %table:SD1% d1 where D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO  = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1_TES <> ' ' AND ROWNUM = 1 AND D1.D_E_L_E_T_ = ' ') D1_DOC ,
      	        (select  D1_CF                       from %table:SD1% d1 where D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO  = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1_TES <> ' ' AND ROWNUM = 1 AND D1.D_E_L_E_T_ = ' ') D1_CF ,
		        (select  D1_DTDIGIT                  from %table:SD1% d1 where D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO  = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1_TES <> ' ' AND ROWNUM = 1 AND D1.D_E_L_E_T_ = ' ') D1_DTDIGIT,
		        (select  D1_QUANT                    from %table:SD1% d1 where D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO  = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1_TES <> ' ' AND ROWNUM = 1 AND D1.D_E_L_E_T_ = ' ') D1_QUANT,
                (C7_DESPESA) C7_DESPESA,
				(C7_QUANT) C7_QUANT,
                (C7_VALFRE) C7_VALFRE
  		     FROM %table:SC7% C7 
		      LEFT JOIN  %table:ZZI% ZZI ON ZZI.ZZI_FILIAL = C7.C7_FILIAL AND ZZI.ZZI_CODINV = C7.C7_I_CDINV AND ZZI.D_E_L_E_T_= ' '
		      WHERE C7.D_E_L_E_T_= ' ' 
		      AND C7.C7_FILIAL =  %xFilial:SC7% 
		      AND C7.C7_I_APLIC = 'I' 
		      AND C7.C7_I_CDINV <> ' ' 
		      AND C7.C7_RESIDUO <> 'S'
			  %exp:_cFiltro%
		     UNION//**************************  UNICAO
		   SELECT C7_FILIAL , C7_I_CDINV , ZZI_DESINV , C7_EMISSAO , C7_NUM, C7_FORNECE , C7_I_NFORN  ,  C7_DESCRI, C7_ITEM, C7_OBS , C7_I_SUBIN,
		        (C7_TOTAL) C7_TOTAL ,
		        (C7_VALIPI) C7_VALIPI, 
                ((select SUM(D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA)                 from %table:SD1% d1 where D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO  = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1_TES <> ' ' AND D1.D_E_L_E_T_ = ' ')) D1_TOTAL,
                ((select SUM(D1_VALDEV+(D1_VALDEV*(D1_IPI/100))) from %table:SD1% d1 where D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO  = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1_TES <> ' ' AND D1.D_E_L_E_T_ = ' ')) D1_VALDEV,
      	        (select  D1_DOC                      from %table:SD1% d1 where D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO  = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1_TES <> ' ' AND ROWNUM = 1 AND D1.D_E_L_E_T_ = ' ') D1_DOC ,
      	        (select  D1_CF                       from %table:SD1% d1 where D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO  = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1_TES <> ' ' AND ROWNUM = 1 AND D1.D_E_L_E_T_ = ' ') D1_CF ,
		        (select  D1_DTDIGIT                  from %table:SD1% d1 where D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO  = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1_TES <> ' ' AND ROWNUM = 1 AND D1.D_E_L_E_T_ = ' ') D1_DTDIGIT,
		        (select  D1_QUANT                    from %table:SD1% d1 where D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO  = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1_TES <> ' ' AND ROWNUM = 1 AND D1.D_E_L_E_T_ = ' ') D1_QUANT,
		        (C7_DESPESA) C7_DESPESA,
				(C7_QUANT) C7_QUANT,
                (C7_VALFRE) C7_VALFRE
	         FROM  %table:SC7% C7 
		      LEFT JOIN %table:ZZI% ZZI ON ZZI.ZZI_FILIAL = C7.C7_FILIAL AND ZZI.ZZI_CODINV = C7.C7_I_CDINV AND ZZI.D_E_L_E_T_= ' '
		      WHERE C7.D_E_L_E_T_= ' ' 
		      AND C7.C7_FILIAL = %xFilial:SC7% 
		      AND C7.C7_I_APLIC = 'I' 
		      AND C7.C7_I_CDINV <> ' ' 
		      AND C7.C7_RESIDUO =  'S' AND C7_QUJE <> 0
			  %exp:_cFiltro% 
			)
		ORDER  BY C7_FILIAL,C7_I_CDINV,C7_EMISSAO, C7_NUM,C7_FORNECE, C7_I_NFORN   
		
	EndSql
	                           
   END REPORT QUERY oSecEntrA1   
   
Endif

//====================================================================================================
// Relatorio Sintetico
//====================================================================================================
If MV_PAR05 == 1 //Sintetico	
	RCOM01T()	
   oSecDadoS1:SetParentQuery()
   oSecDadoS1:SetParentFilter( {|cParam| QRY1->C7_I_CDINV +  QRY1->ZZI_DESINV == cParam} , {|| QRY1->C7_I_CDINV +  QRY1->ZZI_DESINV } )
   oSecEntrS1:Print(.T.)
Else // Analitico
   //====================================================================================================
   // Relatorio Analitico
   //====================================================================================================
   oSecDadoA1:SetParentQuery()
   oSecDadoA1:SetParentFilter( {|cParam| QRY1->C7_I_CDINV +  QRY1->ZZI_DESINV == cParam} , {|| QRY1->C7_I_CDINV +  QRY1->ZZI_DESINV } )
   oSecEntrA1:Print(.T.)
EndIf



Return()


/*
===============================================================================================================================
Programa----------: MontaListaNF
Autor-------------: Jerry
Data da Criacao---: 15/02/2016
===============================================================================================================================
Descrição---------: Rotina que retorna a lista de NF vinculadas ao PC
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MontaListaNF(cFilPC,cNumPCx)
Local cListaNF	:= ""     
Local cQuery	:= ""

cQuery := "SELECT DISTINCT D1_DOC "
cQuery += "FROM " + RetSqlName("SC7") + " C7 "
cQuery += "LEFT JOIN " + RetSqlName("SD1") + " D1 ON D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO  = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1_TES <> ' ' AND D1.D_E_L_E_T_ = ' ' "
cQuery += "WHERE C7.C7_FILIAL = '" + cFilPC + "' "
cQuery += "  AND C7_NUM = '" + cNumPCx + "' "
cQuery += "  AND C7.D_E_L_E_T_ = ' ' "
cQuery += "  AND C7.C7_QUJE <> 0 "
cQuery += "ORDER BY C7_FILIAL, C7_NUM " 

//===================================================================================
//Para que nao ocorra erro, quando duas pessoas acessarem o relatorio simultaneamente
//===================================================================================
If Select("TMPLSTNF") > 0 
	TMPLSTNF->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TCGenQry( ,, cQuery ) , 'TMPLSTNF' , .F. , .T. )

DbSelectArea("TMPLSTNF")
TMPLSTNF->( DbGotop() )  

If !TMPLSTNF->(Eof())

	While !TMPLSTNF->(Eof())
	
		cListaNF += AllTrim( TMPLSTNF->D1_DOC ) + " "	
		TMPLSTNF->(dbSkip())
	End          
	
EndIf                

TMPLSTNF->( DBCloseArea() )

Return( cListaNF )



/*
===============================================================================================================================
Programa----------: RCOM01T
Autor-------------: Jerry
Data da Criacao---: 15/07/2020
===============================================================================================================================
Descrição---------: Imprime totalizadores
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function RCOM01T()
	Local _aTot := {}
	Local _nX	:= 0
	Local _nY	:= 0
	Local _nPos := 0 

    ZZI->(DBSETORDER(1))//ZDA_FILIAL+ZZI_CODINV
	QRY1->(DbGotop())

	WHILE QRY1->(!EOF())
		IF (_nPos:= AScan(_aTot, {|x| x[1] == QRY1->C7_I_CDINV})) == 0
			Aadd(_aTot, { QRY1->C7_I_CDINV,;//1
						  QRY1->ZZI_DESINV,;//2
						  QRY1->C7_TOTAL  ,;//3
						  "Nivel 1"       ,;//4
						  POSICIONE("ZZI",1,cFilAnt+QRY1->C7_I_CDINV, "ZZI_VLRPRV")})//5

		    aSubNiveis:=RCOM01R(QRY1->C7_I_CDINV)
			FOR _nY := 1 TO LEN(aSubNiveis)
            
			    ZZI->(DBGOTO(aSubNiveis[_nY,5]))
			
			    Aadd(_aTot, { ZZI->ZZI_CODINV,;
			    			  ZZI->ZZI_DESINV,;
			    			  aSubNiveis[_nY,3],;
			    			  IF(ZZI->ZZI_TIPO="2","*Nivel 2","**Nivel 3"),;
			    			  ZZI->ZZI_VLRPRV})


			NEXT

			Aadd(_aTot, { " "," ", " "," "," "})

		ELSE
			_aTot[_nPos][3] += QRY1->C7_TOTAL
		ENDIF


		QRY1->(DbSkip())
	ENDDO
	
	oSecTotal:Init()
	FOR _nX := 1 TO Len(_aTot)

		oSecTotal:Cell("INVEST" ):SetValue(_aTot[_nX][1])
		oSecTotal:Cell("DESCINV"):SetValue(_aTot[_nX][2])
		oSecTotal:Cell("TOTINS" ):SetValue(_aTot[_nX][3])
		oSecTotal:Cell("NIVEL"  ):SetValue(_aTot[_nX][4])
		oSecTotal:Cell("VLRPREV"):SetValue(_aTot[_nX][5])
		oSecTotal:PrintLine()

	NEXT _nX
	oSecTotal:Finish()
	QRY1->(DbGotop())
Return


/*
===============================================================================================================================
Programa----------: RCOM01R
Autor-------------: Jerry
Data da Criacao---: 15/07/2020
===============================================================================================================================
Descrição---------: Retorna array com informaçoes dos sub investimentos
===============================================================================================================================
Parametros--------: _cCodIn - Codigo do investimentos
===============================================================================================================================
Retorno-----------: _aDados
===============================================================================================================================
*/
Static Function RCOM01R(_cCodIn)
	Local _cQRYY 		:= ""
	Local _cNwAlias		:= GetNextAlias()
	Local _aDados		:= {}
	Local _aDadosN2     := {} , I

	_cQRYY += "SELECT "
	_cQRYY += "C7_I_SUBIN, "//NIVEL 3
	_cQRYY += "SUM(C7_TOTAL+C7_VALIPI+C7_DESPESA) C7_TOTAL "
	_cQRYY += "FROM "+RetSqlName("SC7")+" C7 "
	_cQRYY += "WHERE C7.D_E_L_E_T_ = ' ' "
	_cQRYY += "AND C7_I_CDINV = '"+ALLTRIM(_cCodIn)+"' "//NIVEL 1 
	_cQRYY += "AND C7_FILIAL = '"+cFilAnt+"' "
	_cQRYY += "AND C7.C7_I_APLIC = 'I' "
	IF !EMPTY(MV_PAR01) .AND. !EMPTY(MV_PAR02)
		_cQRYY += "AND C7.C7_EMISSAO BETWEEN '"+ DtoS( MV_PAR01 ) +"' AND '"+ DtoS( MV_PAR02 ) +"' "
	ENDIF
    If MV_PAR06 = 1 //'Sim: Mostra os PCs com NF amarrada' ,;
                    //'Não: Mostra os PCs com ou sem NF amarrada.' 
      _cQRYY += " AND (select D1_DTDIGIT from " +  retsqlname("SD1") + " d1 "
      _cQRYY += "             WHERE D1.D1_FILIAL = C7.C7_FILIAL AND D1.D1_PEDIDO  = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1_TES <> ' ' AND "
      _cQRYY += "                   ROWNUM = 1 AND D1.D_E_L_E_T_ = ' ') "
      _cQRYY += " BETWEEN '"+ DTOS( MV_PAR07 ) +"' AND '"+ DTOS( MV_PAR08 ) +"' "    
    ENDIF

	_cQRYY += "GROUP BY C7_I_SUBIN "
	_cQRYY += "ORDER BY C7_I_SUBIN "

	DBUseArea( .T. , "TOPCONN" , TCGenQry(,,_cQRYY) , _cNwAlias , .F. , .T. )

	DO WHILE (_cNwAlias)->(!EOF())

        ZZI->(DBSEEK(xFilial() +(_cNwAlias)->C7_I_SUBIN ))
		Aadd(_aDados,{ (_cNwAlias)->C7_I_SUBIN,;// 01
					   ZZI->ZZI_NIVEL2        ,;// 02
					   (_cNwAlias)->C7_TOTAL  ,;// 03
					   ZZI->ZZI_CHAVE         ,;// 04
					   ZZI->(RECNO())         })// 05
        _cCodN2:=ZZI->ZZI_NIVEL2
        IF !EMPTY(_cCodN2) 
		   IF (_nPos:=ASCAN(_aDadosN2,{|A| A[2] == _cCodN2 })) = 0
         
		      ZZI->(DBSEEK(xFilial() +_cCodN2 ))
		      Aadd(_aDadosN2,{ (_cNwAlias)->C7_I_SUBIN,;// 01
		   	   		        _cCodN2                   ,;// 02
		   	   		        (_cNwAlias)->C7_TOTAL     ,;// 03
		   			        ZZI->ZZI_CHAVE            ,;// 04
		   			        ZZI->(RECNO())            })// 05
		   ELSE
              _aDadosN2[_nPos,3]+=(_cNwAlias)->C7_TOTAL
		   ENDIF				   
	    ENDIF				   
		(_cNwAlias)->(DbSkip())
	ENDDO
    
	FOR I := 1 TO LEN(_aDadosN2)
	    AADD(_aDados,_aDadosN2[I])
	Next

	_aDados	:= aSort( _aDados  ,,, {|x, y| X[4]+X[2]+X[1] < Y[4]+Y[2]+Y[1] } )

Return _aDados
