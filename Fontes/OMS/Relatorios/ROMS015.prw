/*
===============================================================================================================================
               ULTIMAS ATUALIZACOES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  	  | 17/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#include "report.ch"
#include "protheus.ch"      

/*
===============================================================================================================================
Programa--------: ROMS015
Autor-----------: Fabiano Dias
Data da Criacao-: 26/02/2010
===============================================================================================================================
Descricao-------: Relatorio utilizado para exibir os dados do desconto contratual(ZAZ) dos clientes, com relacao ao financeiro
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function ROMS015()

Local aMes:={"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}

Private cPerg := "ROMS015"
Private QRY2,QRY3
Private oReport
Private oSecRede_2,oSecDado_2,oSecRede_3,oSecDado_3
Private oBrkRede_2,oBrkRede_3
Private aOrd  := {"Rede_Vencimento","Vencimento_Rede"} 

Private cNomeRede := "" //Armazena o nome e o codigo da rede corrente para que seja utilizada na impressao da quebra  
Private cMesVencim:= "" //Armazena o nome do mes corrente para que seja utilizada na impressao da quebra  

Private _aRedesDesc:= {}
//Variaveis para controle da impressao do totalizador % desconto
Private _nVlrBruto := 0
Private _nVlrDescI := 0
Private _nVlrDescP := 0                                      
//Variaveis para controle da impressao do totalizador valor unitario
Private _nVlrTotSe := 0
Private _nVlrQtdSe := 0
//Variaveis para controle geral
Private _nVlrBruGr := 0
Private _nVlrDeIGr := 0
Private _nVlrDePGr := 0
Private _nVlrTotGr := 0
Private _nVlrQtdGr := 0 

pergunte(cPerg,.F.)

DEFINE REPORT oReport NAME cPerg TITLE "Descontos Contratuais Anal.Financeira" PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} Description "Este relatório emitirá os descontos contratuais gerados de acordo com os parâmetros fornecdidos pelo usuário, esta é uma nnálise financeira."

//Seta Padrao de impressao como Paisagem
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)              
                             
oReport:nFontBody	:= 10
oReport:cFontBody	:= "Courier New"  
oReport:nLineHeight	:= 50 // Define a altura da linha.

//oReport:DisableOrientation()//Desabilita a escolha do tipo de orientacao da pagina retrato ou paisagem     
//oReport:SetEdit(.F.)  //Desabilita a opcao de personalizar do relatorio         
//oReport:SetEnvironment(2) //Deixa como cliente inicial a impressao               
oReport:SetMsgPrint('AGUARDE OS DADOS DO RELATORIO ESTAO SENDO PROCESSADOS')//mensagem exibida no momento da impressao


//======================================================
//Define secoes para primeira ordem - Rede Vencimento
//======================================================

//Secao dados da Rede
DEFINE SECTION oSecRede_2 OF oReport TITLE "Rede_ordem_1" TABLES "SA1","ACY" ORDERS aOrd

DEFINE CELL NAME "a1_grpven"	OF oSecRede_2 ALIAS "SA1"  TITLE "Rede"      SIZE 12
DEFINE CELL NAME "acy_descri"   OF oSecRede_2 ALIAS "ACY"  TITLE "Descrição" SIZE 40
oSecRede_2:Disable()         
oSecRede_2:SetLineStyle(.T.)  
oSecRede_2:SetLinesBefore(2) 

DEFINE SECTION oSecDado_2 OF oSecRede_2 TITLE "Dados_ordem_1" TABLES "SE1","SF2"

DEFINE CELL NAME "MESANO"	   	OF oSecDado_2 ALIAS ""    TITLE "Mês/Ano - Vencimento" SIZE 40 BLOCK{|| aMes[Val(QRY2->MES)] + '/' + QRY2->ANO}    
DEFINE CELL NAME "e1_valor"     OF oSecDado_2 ALIAS "SE1" TITLE "Valor a Vencer"       SIZE 25 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "e1_i_desco"   OF oSecDado_2 ALIAS "SD2" TITLE "Valor de Desconto"    SIZE 25 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "PORCDESC"     OF oSecDado_2 ALIAS ""    TITLE "% Desc. Contrato"     SIZE 25 PICTURE "@E 999.99"
  
//Desabilita Secao
oSecDado_2:Disable()            
oSecDado_2:SetCellBorder(5,2,,.T.)
oSecDado_2:SetCellBorder(5,2,,.F.) 
oSecDado_2:SetAutoSize(.T.)          
oSecDado_2:SetLinesBefore(2)  
oSecDado_2:SetHeaderPage(.T.)          

//Alinhamento de cabecalho                             
oSecDado_2:Cell("e1_valor"):SetHeaderAlign("RIGHT")  
oSecDado_2:Cell("e1_i_desco"):SetHeaderAlign("RIGHT")  
oSecDado_2:Cell("PORCDESC"):SetHeaderAlign("RIGHT")       

oSecDado_2:SetTotalInLine(.F.)

oSecDado_2:OnPrintLine({|| cNomeRede := QRY2->a1_grpven  + " - " + SubStr(QRY2->acy_descri,1,40)})             



//======================================================
//Define secoes para segunda ordem - Vencimento Rede
//======================================================

//Secao dados da Rede
DEFINE SECTION oSecRede_3 OF oReport TITLE "Rede_ordem_2" TABLES "SE1" ORDERS aOrd

DEFINE CELL NAME "MESANO"	   	OF oSecRede_3 ALIAS ""    TITLE "Mês/Ano - Vencimento" SIZE 40 BLOCK{|| aMes[Val(QRY3->MES)] + '/' + QRY3->ANO}    

oSecRede_3:Disable()       
oSecRede_3:SetLineStyle(.T.) 

DEFINE SECTION oSecDado_3 OF oSecRede_3 TITLE "Dados_ordem_2" TABLES "SE1","SF2","ACY"

DEFINE CELL NAME "a1_grpven"	OF oSecDado_3 ALIAS "SA1" TITLE "Rede"      		   SIZE 12
DEFINE CELL NAME "acy_descri"   OF oSecDado_3 ALIAS "ACY" TITLE "Descrição" 		   SIZE 40   
DEFINE CELL NAME "e1_valor"     OF oSecDado_3 ALIAS "SE1" TITLE "Valor a Vencer"       SIZE 25 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "e1_i_desco"   OF oSecDado_3 ALIAS "SD2" TITLE "Valor de Desconto"    SIZE 25 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "PORCDESC"     OF oSecDado_3 ALIAS ""    TITLE "% Desc. Contrato"     SIZE 25 PICTURE "@E 999.99"
  
//Desabilita Secao
oSecDado_3:Disable() 
oSecDado_3:SetCellBorder(5,2,,.T.)
oSecDado_3:SetCellBorder(5,2,,.F.) 
oSecDado_3:SetAutoSize(.T.)          
oSecDado_3:SetLinesBefore(2)  
oSecDado_3:SetHeaderPage(.T.)     

//Alinhamento de cabecalho                             
oSecDado_3:Cell("e1_valor"):SetHeaderAlign("RIGHT")  
oSecDado_3:Cell("e1_i_desco"):SetHeaderAlign("RIGHT")  
oSecDado_3:Cell("PORCDESC"):SetHeaderAlign("RIGHT")       

oSecDado_3:SetTotalInLine(.F.)

oSecDado_3:OnPrintLine({|| cMesVencim := aMes[Val(QRY3->MES)] + '/' + QRY3->ANO })             

oReport:PrintDialog()

Return               

/*
===============================================================================================================================
Programa--------: PrintReport
Autor-----------: Fabiano Dias
Data da Criacao-: 26/02/2010
===============================================================================================================================
Descricao-------: Relatorio utilizado para exibir os dados do desconto contratual(ZAZ) dos clientes, com relacao ao financeiro
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function PrintReport(oReport)

Local cFiltro   := "%"    
Private nOrdem  := oSecRede_2:GetOrder() //Busca ordem selecionada pelo usuario   

oReport:SetTitle("Relação de Descontos Contratuais Orderm  " + aOrd[nOrdem] + " - Emissao de " + dtoc(mv_par02) + " até "  + dtoc(mv_par03))

//Define o filtro de acordo com os parametros digitados
//Filtra Filial da SF2,SE1,SA1,ZAZ,SA3,ACY
if !empty(alltrim(mv_par01))	
	
	if !empty(xFilial("SF2"))
		cFiltro   += " AND F2.F2_FILIAL IN " + FormatIn(mv_par01,";")
	endif	                         
	if !empty(xFilial("SE1"))
		cFiltro   += " AND E1.E1_FILIAL IN " + FormatIn(mv_par01,";")
	endif         
	/*if !empty(xFilial("ZAZ"))
		cFiltro   += " AND ZAZ.ZAZ_FILIAL IN " + FormatIn(mv_par01,";")
	endif*/                	
	if !empty(xFilial("SA1"))
		cFiltro   += " AND A1.A1_FILIAL IN " + FormatIn(mv_par01,";")
	endif
	if !empty(xFilial("SA3"))
		cFiltro  += " AND SA3.A3_FILIAL IN " + FormatIn(mv_par01,";")
	endif
	if !empty(xFilial("ACY"))
		cFiltro  += " AND ACY.ACY_FILIAL IN " + FormatIn(mv_par01,";")
	endif
endif 

//Filtra Emissao da SF2
if !empty(mv_par02) .and. !empty(mv_par03)
	cFiltro  += " AND F2.F2_EMISSAO BETWEEN '" + dtos(mv_par02) + "' AND '" + dtos(mv_par03) + "'"
endif

//Filtra a data de vencimento real do titulo
if !empty(mv_par04) .and. !empty(mv_par05)
	cFiltro += " AND E1.E1_VENCREA BETWEEN '" + dtos(mv_par04) + "' AND '" + dtos(mv_par05) + "'"
endif      

//Filtra Cliente
if !empty(mv_par06) .and. !empty(mv_par08)
	cFiltro   += " AND F2.F2_CLIENTE BETWEEN '" + mv_par06 + "' AND '" + mv_par08 + "'"
endif

//Filtra Loja Cliente
if !empty(mv_par07) .and. !empty(mv_par09)  
	cFiltro += " AND F2.F2_LOJA BETWEEN '" + mv_par07 + "' AND '" + mv_par09 + "'"  
endif

//Filtra Rede Cliente
if !empty(mv_par10)
	cFiltro    += " AND A1.A1_GRPVEN IN " + FormatIn(mv_par10,";")
endif
     
//Filtra Estado Cliente
if !empty(mv_par11) 
	cFiltro   += " AND A1.A1_EST IN " + FormatIn(mv_par11,";")   
endif

//Filtra Cod Municipio Cliente
if !empty(mv_par12) 
	cFiltro   += " AND A1.A1_COD_MUN IN " + FormatIn(mv_par12,";")
endif

//Filtra Vendedor
if !empty(mv_par13) 
	cFiltro   += " AND SA3.A3_COD IN " + FormatIn(mv_par13,";")     
endif

//Filtra Supervisor
if !empty(mv_par14)
	cFiltro   += " AND SA3.A3_SUPER IN " + FormatIn(mv_par14,";")
endif
              
cFiltro   += "%"
               
//Primeira Ordem - Rede_Vencimento
if nOrdem == 1    
             
			oSecRede_2:Enable()
			oSecDado_2:Enable()      
			
			//Quebra por Rede		
			oBrkRede_2:= TRBreak():New(oSecDado_2,oSecRede_2:CELL("a1_grpven"),"Total Rede: " + cNomeRede,.F.)          
			oBrkRede_2:SetTotalText({|| "Total Rede: " + cNomeRede})
			
			TRFunction():New(oSecDado_2:Cell("e1_valor")  ,"VLTITULO","SUM"    ,oBrkRede_2,NIL,NIL,NIL								   ,.F.,.F.)
			TRFunction():New(oSecDado_2:Cell("e1_i_desco"),"VLDESCTO","SUM"    ,oBrkRede_2,NIL,NIL,NIL								   ,.F.,.F.)
			TRFunction():New(oSecDado_2:Cell("PORCDESC") ,NIL        ,"ONPRINT",oBrkRede_2,NIL,NIL,{|| (oSecDado_2:GetFunction("VLDESCTO"):GetLastValue()/oSecDado_2:GetFunction("VLTITULO"):GetLastValue()) * 100 }		,.F.,.F.)

			
			TRFunction():New(oSecDado_2:Cell("e1_valor")  ,"VLGRTIT","SUM"    ,			,NIL,NIL,NIL								   ,.F.,.T.)
			TRFunction():New(oSecDado_2:Cell("e1_i_desco"),"VLGRDES","SUM"    ,			,NIL,NIL,NIL								   ,.F.,.T.)
			TRFunction():New(oSecDado_2:Cell("PORCDESC")  ,NIL      ,"ONPRINT",		    ,NIL,NIL,{|| (oSecDado_2:GetFunction("VLGRDES"):GetLastValue()/oSecDado_2:GetFunction("VLGRTIT"):GetLastValue()) * 100 }		,.F.,.T.)
			
		
		//Executa query para consultar Dados
		BEGIN REPORT QUERY oSecRede_2
			BeginSql alias "QRY2"   	   	
			   	SELECT 
				 	A1.a1_grpven,ACY.acy_descri,SubStr(E1.e1_vencrea,5,2) mes,SubStr(E1.e1_vencrea,1,4) ano,
      			 	SUM(E1.e1_valor) e1_valor,
					SUM(E1.e1_i_desco) e1_i_desco,
					((SUM(E1.e1_i_desco) / SUM(E1.e1_valor)) * 100) PORCDESC    				
				FROM 
					%table:SE1% E1
					JOIN %table:SF2% F2  ON F2.f2_filial = E1.e1_filial AND F2.f2_doc = E1.e1_num AND F2.f2_serie = E1.e1_prefixo AND F2.F2_CLIENTE = E1.e1_cliente AND F2.f2_loja = E1.e1_loja
					//JOIN %table:ZAZ% ZAZ ON F2.f2_i_nrzaz = zaz.zaz_cod  
					//JOIN %table:ZB0% ZB0 ON zaz.zaz_cod = zb0.zb0_cod
					JOIN %table:SA1% A1  ON F2.f2_cliente = A1.a1_cod AND F2.f2_loja = A1.a1_loja
					JOIN %table:SA3% SA3 ON F2.F2_VEND1 = SA3.A3_COD
					JOIN %table:ACY% ACY ON A1.a1_grpven = ACY.acy_grpven
				WHERE 
					F2.%notDel%    
					AND E1.%notDel%  
					//AND ZAZ.%notDel%  
					//AND ZB0.%notDel%
					AND A1.%notDel%  
					AND SA3.%notDel%
					AND ACY.%notDel%    
					AND f2.f2_i_nrzaz <> ' '
      				AND A1.a1_grpven <> ' '
					%exp:cFiltro%
			    GROUP BY
			   		A1.a1_grpven,ACY.acy_descri,SubStr(E1.e1_vencrea,5,2),SubStr(E1.e1_vencrea,1,4)
				ORDER BY 
					A1.a1_grpven,SubStr(E1.e1_vencrea,1,4),SubStr(E1.e1_vencrea,5,2)
			EndSql
		END REPORT QUERY oSecRede_2               
	          
			oSecDado_2:SetParentQuery()
			oSecDado_2:SetParentFilter({|cParam| QRY2->a1_grpven == cParam},{|| QRY2->a1_grpven})
		
			oSecRede_2:Print(.T.)
			
		
		//Segunda Ordem - Vencimento Rede
		Elseif nOrdem == 2   
         	
			oSecRede_3:Enable()
			oSecDado_3:Enable()      
				
			//Quebra por Mes/Ano
			oBrkRede_3:= TRBreak():New(oSecDado_3,oSecRede_3:CELL("MESANO"),"Total: " + cMesVencim,.F.)          
			oBrkRede_3:SetTotalText({|| "Total: " + cMesVencim})
				
			TRFunction():New(oSecDado_3:Cell("e1_valor")  ,"VLTITULO","SUM"    ,oBrkRede_3,NIL,NIL,NIL								   ,.F.,.F.)
			TRFunction():New(oSecDado_3:Cell("e1_i_desco"),"VLDESCTO","SUM"    ,oBrkRede_3,NIL,NIL,NIL								   ,.F.,.F.)
			TRFunction():New(oSecDado_3:Cell("PORCDESC")  ,NIL       ,"ONPRINT",oBrkRede_3,NIL,NIL,{|| (oSecDado_3:GetFunction("VLDESCTO"):GetLastValue()/oSecDado_3:GetFunction("VLTITULO"):GetLastValue()) * 100 }		,.F.,.F.)
			
			TRFunction():New(oSecDado_3:Cell("e1_valor")  ,"VLGRTIT","SUM"    ,			,NIL,NIL,NIL									,.F.,.T.)
			TRFunction():New(oSecDado_3:Cell("e1_i_desco"),"VLGRDES","SUM"    ,			,NIL,NIL,NIL									,.F.,.T.)
			TRFunction():New(oSecDado_3:Cell("PORCDESC")  ,NIL      ,"ONPRINT",		    ,NIL,NIL,{|| (oSecDado_3:GetFunction("VLGRDES"):GetLastValue()/oSecDado_3:GetFunction("VLGRTIT"):GetLastValue()) * 100 }		,.F.,.T.)
		           
		
		//Executa query para consultar Dados
		BEGIN REPORT QUERY oSecRede_3
			BeginSql alias "QRY3"   	   	
			   	SELECT 
				 	A1.a1_grpven,ACY.acy_descri,SubStr(E1.e1_vencrea,5,2) mes,SubStr(E1.e1_vencrea,1,4) ano,
      			 	SUM(E1.e1_valor) e1_valor,
					SUM(E1.e1_i_desco) e1_i_desco,
					((SUM(E1.e1_i_desco) / SUM(E1.e1_valor)) * 100) PORCDESC    				
				FROM 
					%table:SE1% E1
					JOIN %table:SF2% F2  ON F2.f2_filial = E1.e1_filial AND F2.f2_doc = E1.e1_num AND F2.f2_serie = E1.e1_prefixo AND F2.F2_CLIENTE = E1.e1_cliente AND F2.f2_loja = E1.e1_loja
					JOIN %table:SA1% A1  ON F2.f2_cliente = A1.a1_cod AND F2.f2_loja = A1.a1_loja
					JOIN %table:SA3% SA3 ON F2.F2_VEND1 = SA3.A3_COD
					JOIN %table:ACY% ACY ON A1.a1_grpven = ACY.acy_grpven
				WHERE 
					F2.%notDel%    
					AND E1.%notDel%  
					AND A1.%notDel%  
					AND SA3.%notDel%
					AND ACY.%notDel%    
					AND f2.f2_i_nrzaz <> ' '
      				AND A1.a1_grpven <> ' '
					%exp:cFiltro%
			    GROUP BY
			   		A1.a1_grpven,ACY.acy_descri,SubStr(E1.e1_vencrea,5,2),SubStr(E1.e1_vencrea,1,4)
				ORDER BY 
					SubStr(E1.e1_vencrea,1,4),SubStr(E1.e1_vencrea,5,2),A1.a1_grpven
			EndSql
		END REPORT QUERY oSecRede_3               
	    
			oSecDado_3:SetParentQuery()
			oSecDado_3:SetParentFilter({|cParam| QRY3->ano + QRY3->mes == cParam},{|| QRY3->ano + QRY3->mes })
		
			oSecRede_3:Print(.T.)
		    
EndIf
     
Return