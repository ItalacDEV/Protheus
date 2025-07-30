/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alexandre V.  |23/03/2016| Chamado 14774. Ajuste para padronizar a utilização de rotinas de consultas customizadas.
Jerry         |11/04/2018| Chamado 24341. Incluir Dados do Operador Logístico e Seleção de Pedido Funcionári.
Lucas Borges  |09/10/2024| Chamado 48465. Retirada manipulação do SX1
===============================================================================================================================
*/

#Include 'Report.ch'
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa--------: ROMS006
Autor-----------: Jeovane
Data da Criacao-: 25/03/2009
Descrição-------: Relatório de Faturamento de Cargas por destinatários
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
User function ROMS006()

private oReport
Private oSF2_1,oSF2_1A
Private cPerg := "ROMS006"
Private QRY1
private cCliente := " "
private cRede := " "
private cFiltro := " " 
private cNomeFil := " "

pergunte(cPerg,.F.)

DEFINE REPORT oReport NAME "ROMS006" TITLE "Relação de Cargas Faturadas por Destinatário" PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)}

//Seta Padrao de impressao Paisagem.
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)


//====================================================================================================
//³Define secoes para secao Rede                     ³
//====================================================================================================

//Secao Filial
DEFINE SECTION oSF2FIL_1 OF oReport TITLE "Filial" TABLES "SD2"  
DEFINE CELL NAME "D2_FILIAL"	OF oSF2FIL_1 ALIAS "SD2"  TITLE "Cod "
DEFINE CELL NAME "NOMFIL"	    OF oSF2FIL_1 ALIAS "" BLOCK{|| FWFilialName(,QRY1->D2_FILIAL)} TITLE "Filial" SIZE 20

oSF2FIL_1:OnPrintLine({|| cNomeFil := QRY1->D2_FILIAL  + " -  " + FWFilialName(,QRY1->D2_FILIAL)  })
oSF2FIL_1:SetTotalText({|| "SUBTOTAL FILIAL: " + cNomeFil})                                                        

DEFINE BREAK oBrkFil OF oSF2FIL_1 WHEN oSF2FIL_1:CELL("D2_FILIAL") TITLE {|| "SUBTOTAL FILIAL: " + cNomeFil}

DEFINE SECTION oSF2_0 OF oSF2FIL_1 TITLE "Rede" TABLES "ACY" 
DEFINE CELL NAME "A1_GRPVEN" 	OF oSF2_0 ALIAS "SA1"
DEFINE CELL NAME "ACY_DESCRI" 	OF oSF2_0 ALIAS "SA1"

oSF2_0:SetLinesBefore(5)
oSF2_0:Enable()

DEFINE BREAK oBrkRede OF oSF2_0 WHEN oSF2_0:Cell("A1_GRPVEN") TITLE {|| "SUBTOTAL REDE: " + cRede}


//Secao Cliente
DEFINE SECTION oSF2_1 OF oSF2_0 TITLE "Cliente" TABLES "SA1" 
DEFINE CELL NAME "D2_CLIENTE"	    OF oSF2_1 ALIAS "SD2"  TITLE "Cod."
DEFINE CELL NAME "D2_LOJA"	        OF oSF2_1 ALIAS "SD2"  TITLE "Loja"
DEFINE CELL NAME "A1_NOME"	    OF oSF2_1 ALIAS "SA1"  TITLE "Cliente"   SIZE 60
DEFINE CELL NAME "A1_MUN"	        OF oSF2_1 ALIAS "SA1"  TITLE "Municipio" SIZE 40
DEFINE CELL NAME "A1_EST"	        OF oSF2_1 ALIAS "SA1"  TITLE "Estado"    SIZE 40

//Secao Carga - SubSecao da Secao Cliente - Analitico
DEFINE SECTION oSF2_1A OF oSF2_1 TITLE "Carga" TABLES "SB1"                                                          
DEFINE CELL NAME "D2_EMISSAO"   OF oSF2_1A ALIAS "SD2" TITLE "Faturamento"
DEFINE CELL NAME "C6_ENTREG"    OF oSF2_1A ALIAS "SC6" TITLE "Entrega"
DEFINE CELL NAME "D2_COD"	    OF oSF2_1A ALIAS "SD2" TITLE "Produto"
DEFINE CELL NAME "B1_I_DESCD" 	OF oSF2_1A ALIAS "SB1" TITLE "Descricao" SIZE 40
DEFINE CELL NAME "D2_QUANT"	    OF oSF2_1A ALIAS "SD2" PICTURE "@E 999,999,999,999.99" SIZE 16 
DEFINE CELL NAME "D2_UM"      	OF oSF2_1A ALIAS "SD2" TITLE "Un. M" SIZE 6
DEFINE CELL NAME "D2_QTSEGUM" 	OF oSF2_1A ALIAS "SD2" PICTURE "@E 999,999,999.99" SIZE 14 
DEFINE CELL NAME "D2_SEGUM" 	OF oSF2_1A ALIAS "SD2" TITLE "Seg. UM" SIZE 6
DEFINE CELL NAME "D2_PRCVEN"	OF oSF2_1A ALIAS "SD2" PICTURE "@E 999,999,999.99"
DEFINE CELL NAME "D2_TOTAL" 	OF oSF2_1A ALIAS "SD2" PICTURE "@E 999,999,999.99" 
DEFINE CELL NAME "C6_NUM"       OF oSF2_1A ALIAS "SC6" TITLE  "Pedido"
DEFINE CELL NAME "D2_DOC"       OF oSF2_1A ALIAS "SD2" TITLE  "Nota Fiscal"
DEFINE CELL NAME "DAI_COD"      OF oSF2_1A ALIAS "DAK" TITLE  "Carga"
DEFINE CELL NAME "DA3_PLACA"    OF oSF2_1A ALIAS "DA3" TITLE  "Placa"
DEFINE CELL NAME "A2_NREDUZ"    OF oSF2_1A ALIAS "SA2" TITLE  "Transportadora"

DEFINE CELL NAME "DAI_I_OPLO"   OF oSF2_1A ALIAS "DAI" TITLE "Op. Log." SIZE 8 BLOCK {|| QRY1->DAI_I_OPLO} PICTURE "@!"
DEFINE CELL NAME "DAI_I_OPLO" 	OF oSF2_1A ALIAS "DAI" TITLE "Nome Op Log" SIZE 8 BLOCK {||  If(!Empty(Alltrim(QRY1->DAI_I_OPLO)),posicione("SA2",1,xfilial("SA2") + QRY1->DAI_I_OPLO,"A2_NREDUZ")," ")}  PICTURE "@!"



oSF2_1A:Disable()
oSF2_1A:OnPrintLine({|| cCliente := QRY1->D2_CLIENTE + " - " + QRY1->A1_NOME,AllwaysTrue(),cRede := QRY1->A1_GRPVEN + " - " + QRY1->ACY_DESCRI })
oSF2_1A:SetTotalText({|| "SUBTOTAL CLIENTE:  " + cCliente})
oSF2_1A:SetTotalInLine(.F.)

//Secao Carga - SubSecao da Secao Cliente - Analitico
DEFINE SECTION oSF2_1S OF oSF2_1 TITLE "Carga" TABLES "SB1"                                                          
DEFINE CELL NAME "D2_EMISSAO"   OF oSF2_1S ALIAS "SD2" TITLE "Faturamento"
DEFINE CELL NAME "C6_ENTREG"    OF oSF2_1S ALIAS "SC6" TITLE "Entrega"
DEFINE CELL NAME "D2_TOTAL" 	OF oSF2_1S ALIAS "SD2" PICTURE "@E 999,999,999.99" 
DEFINE CELL NAME "C6_NUM"       OF oSF2_1S ALIAS "SC6" TITLE  "Pedido"
DEFINE CELL NAME "D2_DOC"       OF oSF2_1S ALIAS "SD2" TITLE  "Nota Fiscal"
DEFINE CELL NAME "DAI_COD"      OF oSF2_1S ALIAS "DAK" TITLE  "Carga"
DEFINE CELL NAME "DA3_PLACA"    OF oSF2_1S ALIAS "DA3" TITLE  "Placa"
DEFINE CELL NAME "A2_NREDUZ"    OF oSF2_1S ALIAS "SA2" TITLE  "Transportadora"
DEFINE CELL NAME "DAI_I_OPLO"   OF oSF2_1S ALIAS "DAI" TITLE "Op. Log." SIZE 8 BLOCK {|| QRY1->DAI_I_OPLO} PICTURE "@!"
DEFINE CELL NAME "DAI_I_OPLO" 	OF oSF2_1S ALIAS "DAI" TITLE "Nome Op Log" SIZE 8 BLOCK {||  If(!Empty(Alltrim(QRY1->DAI_I_OPLO)),posicione("SA2",1,xfilial("SA2") + QRY1->DAI_I_OPLO,"A2_NREDUZ")," ")}  PICTURE "@!"


oSF2_1S:Disable()     
oSF2_1S:OnPrintLine({|| cCliente := QRY1->D2_CLIENTE + " - " + QRY1->A1_NOME,AllwaysTrue(),cRede := QRY1->A1_GRPVEN + " - " + QRY1->ACY_DESCRI })
oSF2_1S:SetTotalText({|| "SUBTOTAL CLIENTE:  " + cCliente})
oSF2_1S:SetTotalInLine(.F.)   

oReport:PrintDialog()

Return()

/*
===============================================================================================================================
Programa--------: PrintReport
Autor-----------: Jeovane
Data da Criacao-: 25/03/2009
Descrição-------: Função que processa a impressão do relatório
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function PrintReport(oReport)

cFiltro := "%"     

oReport:SetTitle(oReport:Title() + " - " + if(mv_par19 == 1,"Sintetico.","Analitico." )+ " De " +  dtoc(mv_par02) + " até " + dtoc(mv_par03))

//Se usuario definiu relatorio sintetico
if mv_par19 == 1
 
 	DEFINE FUNCTION FROM oSF2_1S:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkRede
 	DEFINE FUNCTION FROM oSF2_1S:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT
 	
else
	DEFINE FUNCTION FROM oSF2_1A:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkRede
	DEFINE FUNCTION FROM oSF2_1A:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkRede
 	DEFINE FUNCTION FROM oSF2_1A:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkRede
 	
	DEFINE FUNCTION FROM oSF2_1A:Cell("D2_QUANT")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT
	DEFINE FUNCTION FROM oSF2_1A:Cell("D2_QTSEGUM") FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT
 	DEFINE FUNCTION FROM oSF2_1A:Cell("D2_TOTAL")   FUNCTION SUM BREAK oBrkFil NO END SECTION NO END REPORT
 	
end

IF !EMPTY(ALLTRIM(MV_PAR01))	
	If LEN(ALLTRIM(MV_PAR01)) < 5
		MV_PAR01:= LEFT(MV_PAR01,2)
		cFiltro += " AND SF2.F2_FILIAL = '" + MV_PAR01 + "' "
	ELSE
		cFiltro += " AND SF2.F2_FILIAL IN " + FormatIn(ALLTRIM(MV_PAR01),";")
	ENDIF
ENDIF


//Filtra Emissao da SF2
if !empty(mv_par02) .and. !empty(mv_par03)
	cFiltro += " AND SF2.F2_EMISSAO BETWEEN '" + dtos(mv_par02) + "' AND '" + dtos(mv_par03) + "'"
endif

//Filtra Cliente
if !empty(mv_par06) .and. !empty(mv_par08)
	cFiltro += " AND SF2.F2_CLIENTE BETWEEN '" + mv_par06 + "' AND '" + mv_par08 + "'"
endif

//Filtra Loja Cliente
if !empty(mv_par07) .and. !empty(mv_par09)
	cFiltro += " AND SF2.F2_LOJA BETWEEN '" + mv_par07 + "' AND '" + mv_par09 + "'"
endif

//Filtra Rede Cliente
if !empty(mv_par10)
	cFiltro += " AND SA1.A1_GRPVEN IN " + FormatIn(mv_par10,";")
endif

//Filtra Estado Cliente
if !empty(mv_par11)
	cFiltro += " AND SA1.A1_EST IN " + FormatIn(mv_par11,";")
endif

//Filtra Cod Municipio Cliente
if !empty(mv_par12)
	cFiltro += " AND SA1.A1_COD_MUN IN " + FormatIn(mv_par12,";")
endif

//Filtra Vendedor
if !empty(mv_par13)
	cFiltro += " AND SA3.A3_COD IN " + FormatIn(mv_par13,";")
endif

//Filtra Supervisor
if !empty(mv_par14)
	cFiltro += " AND SA3.A3_SUPER IN " + FormatIn(mv_par14,";")
endif

//Filtra Produto
if !empty(mv_par04) .and. !empty(mv_par05)
	cFiltro += " AND SD2.D2_COD BETWEEN '" + mv_par04 + "' AND '" + mv_par05 + "'"
endif

//Filtra Grupo de Produtos
if !empty(mv_par15)
	cFiltro += " AND SBM.BM_GRUPO IN " + FormatIn(mv_par15,";")
endif

//Filtra Produto Nivel 2
if !empty(mv_par16)
	cFiltro += " AND SB1.B1_I_NIV2 IN " + FormatIn(mv_par16,";")
endif

//Filtra Produto Nivel 3
if !empty(mv_par17)
	cFiltro += " AND SB1.B1_I_NIV3 IN " + FormatIn(mv_par17,";")
endif

//Filtra Produto Nivel 4
if !empty(mv_par18)
	cFiltro += " AND SB1.B1_I_NIV4 IN " + FormatIn(mv_par18,";")
endif

//Filtra Transportadoras
if !empty(mv_par20)
	cFiltro += " AND SA2.A2_COD IN " + FormatIn(mv_par20,";")
endif

//Filtra Grupo de Produtos
if !empty(mv_par21)
	cFiltro += " AND SB1.B1_I_SUBGR IN " + FormatIn(mv_par21,";")
endif  

//Filtra tipo do Fornecedor
if !empty(mv_par22)
	cFiltro    += " AND SA2.A2_I_CLASS IN " + FormatIn(mv_par22,";")
endif    

// Filtros de pedidos de funcionários
If mv_par23 == 1
	cFiltro += " AND C5_I_OPER = '02' AND C5_TIPO = 'N' "
EndIf


cFiltro += "%"

//Verifica se usuario quer relatorio sintetico ou analitico
if mv_par19 == 1 //Sintético

	oSF2_1S:Enable()
	
	BEGIN REPORT QUERY oSF2FIL_1
		BeginSql alias "QRY1"  
			SELECT 
				SUM(SD2.D2_QUANT) AS D2_QUANT,
				SUM(SD2.D2_QTSEGUM) AS D2_QTSEGUM,
				SUM(SD2.D2_TOTAL) AS D2_TOTAL,
				SD2.D2_CLIENTE,SD2.D2_LOJA,SA1.A1_NOME,
				SD2.D2_EMISSAO,SC6.C6_ENTREG,
				//SD2.D2_UM,
				//SD2.D2_SEGUM,
				SC6.C6_NUM,SD2.D2_DOC,DAI.DAI_COD,DA3.DA3_PLACA,SA2.A2_NREDUZ,DAI_I_OPLO,
				SA1.A1_GRPVEN,ACY.ACY_DESCRI,SD2.D2_FILIAL,A1_MUN,A1_EST
			FROM 
			    %table:SF2% SF2 
				JOIN %table:SD2% SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
				JOIN %table:SA3% SA3 ON SF2.F2_VEND1 = SA3.A3_COD
				JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA 
				JOIN %table:ACY% ACY ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN 
				JOIN %table:SC6% SC6 ON SD2.D2_PEDIDO = SC6.C6_NUM AND SD2.D2_FILIAL = SC6.C6_FILIAL AND SC6.C6_ITEM = SD2.D2_ITEMPV
				JOIN %table:SC5% SC5 ON SD2.D2_PEDIDO = SC5.C5_NUM AND SD2.D2_FILIAL = SC5.C5_FILIAL 
				JOIN %table:SB1% SB1 ON SD2.D2_COD = SB1.B1_COD   
				JOIN %table:SBM% SBM ON SB1.B1_GRUPO = SBM.BM_GRUPO 
				JOIN %table:DAI% DAI ON DAI.DAI_NFISCA = SD2.D2_DOC AND DAI.DAI_SERIE = SD2.D2_SERIE AND DAI.DAI_FILIAL = SD2.D2_FILIAL 
				JOIN %table:DAK% DAK ON DAI.DAI_COD = DAK.DAK_COD AND DAI.DAI_FILIAL = DAK.DAK_FILIAL 
				JOIN %table:DA3% DA3 ON DAK.DAK_CAMINH = DA3.DA3_COD  
				JOIN %table:DA4% DA4 ON DAK.DAK_MOTORI = DA4.DA4_COD 
				JOIN %table:SA2% SA2 ON SF2.F2_I_CTRA = SA2.A2_COD AND SF2.F2_I_LTRA = SA2.A2_LOJA
			WHERE 
				SF2.%notDel%
			    AND SA3.%notDel%
			    AND SD2.%notDel%
				AND SA1.%notDel%
   				AND ACY.%notDel%
				AND SC6.%notDel%
				AND SC5.%notDel%				
				AND SB1.%notDel%	
			    AND DAI.%notDel%
	   			AND DAK.%notDel%
   				AND DA3.%notDel% 
   				AND DA4.%notDel%
   				AND SA2.%notDel%
	   			%exp:cFiltro%    
	   		GROUP BY 
	   			SD2.D2_CLIENTE,SD2.D2_LOJA,SA1.A1_NOME,
				SD2.D2_EMISSAO,SC6.C6_ENTREG,
				//SD2.D2_UM,
				//SD2.D2_SEGUM,
				SC6.C6_NUM,SD2.D2_DOC,DAI.DAI_COD,DA3.DA3_PLACA,SA2.A2_NREDUZ,DAI.DAI_I_OPLO, SA1.A1_GRPVEN,ACY.ACY_DESCRI,SD2.D2_FILIAL,
			    A1_MUN,A1_EST
		   ORDER BY 
     			SD2.D2_FILIAL,SA1.A1_GRPVEN,SD2.D2_CLIENTE,SD2.D2_LOJA
		EndSql
	END REPORT QUERY oSF2FIL_1
else // Analítico
	
	oSF2_1A:Enable()
	
	BEGIN REPORT QUERY oSF2FIL_1
	BeginSql alias "QRY1"  
		SELECT  
			SD2.D2_CLIENTE,SD2.D2_LOJA,SA1.A1_NOME,SD2.D2_EMISSAO,SC6.C6_ENTREG,
			SD2.D2_COD,SB1.B1_I_DESCD,SD2.D2_QUANT,SD2.D2_QTSEGUM,SD2.D2_UM,SD2.D2_SEGUM,
			SD2.D2_PRCVEN,SD2.D2_TOTAL,SC6.C6_NUM,SD2.D2_DOC,DAI.DAI_COD,
			DA3.DA3_PLACA,SA2.A2_NREDUZ,DAI.DAI_I_OPLO,SA1.A1_GRPVEN,ACY.ACY_DESCRI,SD2.D2_FILIAL,A1_MUN,A1_EST
		FROM 
		    %table:SF2% SF2 
			JOIN %table:SD2% SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL 
			JOIN %table:SA3% SA3 ON SF2.F2_VEND1 = SA3.A3_COD
			JOIN %table:SA1% SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA 
			JOIN %table:ACY% ACY ON SA1.A1_GRPVEN = ACY.ACY_GRPVEN 
			JOIN %table:SC6% SC6 ON SD2.D2_PEDIDO = SC6.C6_NUM AND SD2.D2_FILIAL = SC6.C6_FILIAL AND SC6.C6_ITEM = SD2.D2_ITEMPV
			JOIN %table:SB1% SB1 ON SD2.D2_COD = SB1.B1_COD
			JOIN %table:SBM% SBM ON SB1.B1_GRUPO = SBM.BM_GRUPO 
			JOIN %table:DAI% DAI ON DAI.DAI_NFISCA = SD2.D2_DOC AND DAI.DAI_SERIE = SD2.D2_SERIE AND DAI.DAI_FILIAL = SD2.D2_FILIAL 
			JOIN %table:DAK% DAK ON DAI.DAI_COD = DAK.DAK_COD AND DAI.DAI_FILIAL = DAK.DAK_FILIAL 
			JOIN %table:DA3% DA3 ON DAK.DAK_CAMINH = DA3.DA3_COD  
			JOIN %table:DA4% DA4 ON DAK.DAK_MOTORI = DA4.DA4_COD 
			JOIN %table:SA2% SA2 ON SF2.F2_I_CTRA = SA2.A2_COD AND SF2.F2_I_LTRA = SA2.A2_LOJA 
			JOIN %table:SC5% SC5 ON SD2.D2_PEDIDO = SC5.C5_NUM AND SD2.D2_FILIAL = SC5.C5_FILIAL 
		WHERE
		    SF2.%notDel%
		    AND SA3.%notDel%
		    AND SD2.%notDel%
			AND SA1.%notDel%
			AND ACY.%notDel%
			AND SC6.%notDel%
			AND SB1.%notDel%	
		    AND DAI.%notDel%
   			AND DAK.%notDel%
			AND DA3.%notDel% 
			AND DA4.%notDel%
			AND SA2.%notDel%
   			%exp:cFiltro%
	   ORDER BY 
	   		SD2.D2_FILIAL,SA1.A1_GRPVEN,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_COD
    
	EndSql
	END REPORT QUERY oSF2FIL_1
endif
      
oSF2_0:SetParentQuery()
oSF2_0:SetParentFilter({|cParam| QRY1->D2_FILIAL == cParam },{|| QRY1->D2_FILIAL })

oSF2_1:SetParentQuery()
oSF2_1:SetParentFilter({|cParam| QRY1->D2_FILIAL+QRY1->A1_GRPVEN == cParam },{|| QRY1->D2_FILIAL+QRY1->A1_GRPVEN })


oSF2_1A:SetParentQuery()
oSF2_1A:SetParentFilter({|cParam| QRY1->D2_FILIAL+QRY1->D2_CLIENTE+QRY1->D2_LOJA == cParam },{|| QRY1->D2_FILIAL+QRY1->D2_CLIENTE+QRY1->D2_LOJA })

oSF2_1S:SetParentQuery()
oSF2_1S:SetParentFilter({|cParam| QRY1->D2_FILIAL+QRY1->D2_CLIENTE+QRY1->D2_LOJA == cParam },{|| QRY1->D2_FILIAL+QRY1->D2_CLIENTE+QRY1->D2_LOJA })

oSF2FIL_1:Print(.T.)

return
