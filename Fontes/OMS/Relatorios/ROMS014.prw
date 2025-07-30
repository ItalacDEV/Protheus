/*
===============================================================================================================================
               ULTIMAS ATUALIZACOES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Josu� Prestes     | 15/07/2015 |  Corre��o de �ndice de porcentagem conf. chamado 10427
-------------------------------------------------------------------------------------------------------------------------------
Josu� Prestes     | 09/12/2015 |  Ajuste de query para evitar divis�o por zero - Chamado 13123
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  	  | 17/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#include "report.ch"
#include "protheus.ch" 

/*
===============================================================================================================================
Programa----------: ROMS014
Autor-------------: Fabiano Dias Silva 
Data da Criacao---: 26/02/2010
===============================================================================================================================
Descri��o---------: Relatorio utilizado para exibir os dados do desconto contratual(ZAZ) dos clientes. 
------------------: 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function ROMS014()

Private cPerg := "ROMS014"
Private QRY1,QRY4,QRY5,QRY6       
Private oReport    
Private oSecRede_6,oSecCli,oSecDado_6
Private oSecRede_1,oSecDados_1,oSecRede_4,oSecDado_4,oSecDado_5
Private oBrkRede_1,oBrkRede_2
Private aOrd  := {"Rede_Produto","Filial_Produto","Produto","Cliente x Produto"}   

Private cNomeRede := "" //Armazena o nome e o codigo da rede corrente para que seja utilizada na impressao da quebra  
Private cNomFilial:= "" //Armazena o nome da filial corrente para que seja utilizada na impressao da quebra  
Private cNomeCli  := "" //Armazena o nome do cliente corrente para que seja utilizada na impressao da quebra na ordem cliente x Produto

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

DEFINE REPORT oReport NAME cPerg TITLE "Relat�rio de Descontos Contratuais" PARAMETER cPerg ACTION {|oReport| ROMS014PRI(oReport)} Description "Este relat�rio emitir� os descontos contratuais gerados de acordo com os par�metros fornecdidos pelo usu�rio, esta � uma nn�lise de faturamento." 

//Seta Padrao de impressao como Paisagem
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)                                                        

//====================================================================
//Define secoes para primeira ordem - Rede Produto    
//====================================================================

//Secao dados da Rede
DEFINE SECTION oSecRede_1 OF oReport TITLE "Rede_ordem_1" TABLES "SA1","ACY" ORDERS aOrd

DEFINE CELL NAME "a1_grpven"	OF oSecRede_1 ALIAS "SA1"  TITLE "Rede"      SIZE 12
DEFINE CELL NAME "acy_descri"   OF oSecRede_1 ALIAS "ACY"  TITLE "Descri��o" SIZE 40
oSecRede_1:Disable()

DEFINE SECTION oSecDados_1 OF oSecRede_1 TITLE "Dados_ordem_1" TABLES "SB1","SD2","SF2"

DEFINE CELL NAME "b1_cod"	    OF oSecDados_1 ALIAS "SB1" TITLE "Produto"        	 SIZE 20
DEFINE CELL NAME "b1_i_descd"   OF oSecDados_1 ALIAS "SB1" TITLE "Descri��o"      	 SIZE 40     
DEFINE CELL NAME "d2_quant"	    OF oSecDados_1 ALIAS "SD2" TITLE "Quantidade"     	 SIZE 22 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "d2_um"    	OF oSecDados_1 ALIAS "SD2" TITLE "U.M."           	 SIZE 06
DEFINE CELL NAME "d2_qtsegum"	OF oSecDados_1 ALIAS "SD2" TITLE "Qtde. 2a U.M."  	 SIZE 22 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "d2_segum"	    OF oSecDados_1 ALIAS "SD2" TITLE "2a U.M."        	 SIZE 10 
DEFINE CELL NAME "d2_prcven"    OF oSecDados_1 ALIAS "SD2" TITLE "Vlr.Unit."      	 SIZE 16 PICTURE "@E 9,999,999,999.9999"
DEFINE CELL NAME "d2_total"     OF oSecDados_1 ALIAS "SD2" TITLE "Vlr.Total"      	 SIZE 22 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "d2_valbrut"   OF oSecDados_1 ALIAS "SD2" TITLE "Vlr.Bruto"      	 SIZE 22 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "d2_i_vlrdc"   OF oSecDados_1 ALIAS "SD2" TITLE "Vlr.Desconto Int." SIZE 23 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "PORCINT"      OF oSecDados_1 ALIAS ""    TITLE "% Desconto Int"    SIZE 20 PICTURE "@E 999.99"
DEFINE CELL NAME "d2_i_vlpar"   OF oSecDados_1 ALIAS "SD2" TITLE "Vlr.Desconto Par." SIZE 23 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "PORCPAR"      OF oSecDados_1 ALIAS ""    TITLE "% Desconto Par"    SIZE 20 PICTURE "@E 999.99"


//Desabilita Secao
oSecDados_1:Disable()

//Desabilita Celulas
oSecDados_1:Cell("d2_i_vlrdc"):Disable()
oSecDados_1:Cell("d2_i_vlpar"):Disable() 
oSecDados_1:Cell("PORCINT"):Disable()   
oSecDados_1:Cell("PORCPAR"):Disable()

//Alinhamento de cabecalho
oSecDados_1:Cell("d2_quant"):SetHeaderAlign("RIGHT")       
oSecDados_1:Cell("d2_qtsegum"):SetHeaderAlign("RIGHT")  
oSecDados_1:Cell("d2_prcven"):SetHeaderAlign("RIGHT")       
oSecDados_1:Cell("d2_total"):SetHeaderAlign("RIGHT")
oSecDados_1:Cell("d2_valbrut"):SetHeaderAlign("RIGHT")       
oSecDados_1:Cell("d2_i_vlrdc"):SetHeaderAlign("RIGHT")  
oSecDados_1:Cell("d2_i_vlpar"):SetHeaderAlign("RIGHT")     
oSecDados_1:Cell("PORCINT"):SetHeaderAlign("RIGHT")  
oSecDados_1:Cell("PORCPAR"):SetHeaderAlign("RIGHT")  

oSecDados_1:SetTotalInLine(.F.)                                               

oSecDados_1:OnPrintLine({|| cNomeRede := QRY1->a1_grpven  + " - " + SubStr(QRY1->acy_descri,1,40)})


//====================================================================
//Define secoes para segunda ordem - Filial Produto   
//====================================================================

//Secao dados da Rede
DEFINE SECTION oSecRede_4 OF oReport TITLE "Rede_ordem_4" TABLES "SF2" ORDERS aOrd

DEFINE CELL NAME "f2_filial"	OF oSecRede_4 ALIAS "SF2" TITLE "Filial"    SIZE 12
DEFINE CELL NAME "NOMFIL"	    OF oSecRede_4 ALIAS ""    TITLE "Descri��o" SIZE 40 BLOCK{|| ROMS014NOM(QRY4->f2_filial)}
oSecRede_4:Disable()

DEFINE SECTION oSecDado_4 OF oSecRede_4 TITLE "Dados_ordem_4" TABLES "SB1","SD2"

DEFINE CELL NAME "b1_cod"	    OF oSecDado_4 ALIAS "SB1" TITLE "Produto"        	SIZE 20
DEFINE CELL NAME "b1_i_descd"   OF oSecDado_4 ALIAS "SB1" TITLE "Descri��o"      	SIZE 40     
DEFINE CELL NAME "d2_quant"	    OF oSecDado_4 ALIAS "SD2" TITLE "Quantidade"     	SIZE 22 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "d2_um"    	OF oSecDado_4 ALIAS "SD2" TITLE "U.M."           	SIZE 06
DEFINE CELL NAME "d2_qtsegum"	OF oSecDado_4 ALIAS "SD2" TITLE "Qtde. 2a U.M."  	SIZE 22 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "d2_segum"	    OF oSecDado_4 ALIAS "SD2" TITLE "2a U.M."        	SIZE 10 
DEFINE CELL NAME "d2_prcven"    OF oSecDado_4 ALIAS "SD2" TITLE "Vlr.Unit."      	SIZE 16 PICTURE "@E 9,999,999,999.9999"
DEFINE CELL NAME "d2_total"     OF oSecDado_4 ALIAS "SD2" TITLE "Vlr.Total"      	SIZE 22 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "d2_valbrut"   OF oSecDado_4 ALIAS "SD2" TITLE "Vlr.Bruto"      	SIZE 22 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "d2_i_vlrdc"   OF oSecDado_4 ALIAS "SD2" TITLE "Vlr.Desconto Int." SIZE 23 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "PORCINT"      OF oSecDado_4 ALIAS ""    TITLE "% Desconto Int"    SIZE 20 PICTURE "@E 999.99"
DEFINE CELL NAME "d2_i_vlpar"   OF oSecDado_4 ALIAS "SD2" TITLE "Vlr.Desconto Par." SIZE 23 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "PORCPAR"      OF oSecDado_4 ALIAS ""    TITLE "% Desconto Par"    SIZE 20 PICTURE "@E 999.99"


//Desabilita Secao
oSecDado_4:Disable()

//Desabilita Celulas
oSecDado_4:Cell("d2_i_vlrdc"):Disable()
oSecDado_4:Cell("d2_i_vlpar"):Disable() 
oSecDado_4:Cell("PORCINT"):Disable()   
oSecDado_4:Cell("PORCPAR"):Disable()

//Alinhamento de cabecalho
oSecDado_4:Cell("d2_quant"):SetHeaderAlign("RIGHT")       
oSecDado_4:Cell("d2_qtsegum"):SetHeaderAlign("RIGHT")  
oSecDado_4:Cell("d2_prcven"):SetHeaderAlign("RIGHT")       
oSecDado_4:Cell("d2_total"):SetHeaderAlign("RIGHT")
oSecDado_4:Cell("d2_valbrut"):SetHeaderAlign("RIGHT")       
oSecDado_4:Cell("d2_i_vlrdc"):SetHeaderAlign("RIGHT")  
oSecDado_4:Cell("d2_i_vlpar"):SetHeaderAlign("RIGHT")     
oSecDado_4:Cell("PORCINT"):SetHeaderAlign("RIGHT")  
oSecDado_4:Cell("PORCPAR"):SetHeaderAlign("RIGHT")  

oSecDado_4:SetTotalInLine(.F.)                                               

oSecDado_4:OnPrintLine({|| cNomFilial := QRY4->f2_filial + ' - ' + ROMS014NOM(QRY4->f2_filial)})
                                                        

//====================================================================
//Define secao para terceira ordem - Produto          
//====================================================================

DEFINE SECTION oSecDado_5 OF oReport TITLE "Dados_ordem_5" TABLES "SB1","SD2"

DEFINE CELL NAME "b1_cod"	    OF oSecDado_5 ALIAS "SB1" TITLE "Produto"        	SIZE 20
DEFINE CELL NAME "b1_i_descd"   OF oSecDado_5 ALIAS "SB1" TITLE "Descri��o"      	SIZE 40     
DEFINE CELL NAME "d2_quant"	    OF oSecDado_5 ALIAS "SD2" TITLE "Quantidade"     	SIZE 22 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "d2_um"    	OF oSecDado_5 ALIAS "SD2" TITLE "U.M."           	SIZE 06
DEFINE CELL NAME "d2_qtsegum"	OF oSecDado_5 ALIAS "SD2" TITLE "Qtde. 2a U.M."  	SIZE 22 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "d2_segum"	    OF oSecDado_5 ALIAS "SD2" TITLE "2a U.M."        	SIZE 10 
DEFINE CELL NAME "d2_prcven"    OF oSecDado_5 ALIAS "SD2" TITLE "Vlr.Unit."      	SIZE 16 PICTURE "@E 9,999,999,999.9999"
DEFINE CELL NAME "d2_total"     OF oSecDado_5 ALIAS "SD2" TITLE "Vlr.Total"      	SIZE 22 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "d2_valbrut"   OF oSecDado_5 ALIAS "SD2" TITLE "Vlr.Bruto"      	SIZE 22 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "d2_i_vlrdc"   OF oSecDado_5 ALIAS "SD2" TITLE "Vlr.Desconto Int." SIZE 23 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "PORCINT"      OF oSecDado_5 ALIAS ""    TITLE "% Desconto Int"    SIZE 20 PICTURE "@E 999.99"
DEFINE CELL NAME "d2_i_vlpar"   OF oSecDado_5 ALIAS "SD2" TITLE "Vlr.Desconto Par." SIZE 23 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "PORCPAR"      OF oSecDado_5 ALIAS ""    TITLE "% Desconto Par"    SIZE 20 PICTURE "@E 999.99"


//Desabilita Secao
oSecDado_5:Disable()

//Desabilita Celulas
oSecDado_5:Cell("d2_i_vlrdc"):Disable()
oSecDado_5:Cell("d2_i_vlpar"):Disable() 
oSecDado_5:Cell("PORCINT"):Disable()   
oSecDado_5:Cell("PORCPAR"):Disable()

//Alinhamento de cabecalho
oSecDado_5:Cell("d2_quant"):SetHeaderAlign("RIGHT")       
oSecDado_5:Cell("d2_qtsegum"):SetHeaderAlign("RIGHT")  
oSecDado_5:Cell("d2_prcven"):SetHeaderAlign("RIGHT")       
oSecDado_5:Cell("d2_total"):SetHeaderAlign("RIGHT")
oSecDado_5:Cell("d2_valbrut"):SetHeaderAlign("RIGHT")       
oSecDado_5:Cell("d2_i_vlrdc"):SetHeaderAlign("RIGHT")  
oSecDado_5:Cell("d2_i_vlpar"):SetHeaderAlign("RIGHT")     
oSecDado_5:Cell("PORCINT"):SetHeaderAlign("RIGHT")  
oSecDado_5:Cell("PORCPAR"):SetHeaderAlign("RIGHT")  

oSecDado_5:SetTotalInLine(.F.)                                               


//====================================================
//Define secoes para quarta ordem - Cliente x Produto 
//====================================================

//Secao dados da Rede
DEFINE SECTION oSecRede_6 OF oReport TITLE "Rede_ordem_4" TABLES "SA1","ACY" ORDERS aOrd

DEFINE CELL NAME "a1_grpven"	OF oSecRede_6 ALIAS "SA1"  TITLE "Rede"      SIZE 12
DEFINE CELL NAME "acy_descri"   OF oSecRede_6 ALIAS "ACY"  TITLE "Descri��o" SIZE 40 

oSecRede_6:Disable() 
oSecRede_6:SetLinesBefore(4)    

//Secao dados do Cliente
DEFINE SECTION oSecCli OF oSecRede_6 TITLE "Cliente_ordem_4" TABLES "SA1" 

DEFINE CELL NAME "A1_COD"    	OF oSecCli ALIAS "SA1"  TITLE "Cliente"   SIZE 09
DEFINE CELL NAME "A1_LOJA"      OF oSecCli ALIAS "SA1"  TITLE "Loja"      SIZE 07 
DEFINE CELL NAME "A1_NOME"      OF oSecCli ALIAS "SA1"  TITLE "Descri��o" SIZE 55 
DEFINE CELL NAME "municipio"    OF oSecCli ALIAS "SA1"  TITLE "Municipio" SIZE 30 BLOCK {|| AllTrim(QRY6->A1_COD_MUN) + '-' + AllTrim(QRY6->A1_MUN) } 
DEFINE CELL NAME "A1_EST"       OF oSecCli ALIAS "SA1"  TITLE "Estado"    SIZE 06  
DEFINE CELL NAME "cliente"      OF oSecCli ALIAS "SA1"  TITLE "Municipio" SIZE 30 BLOCK {|| QRY6->a1_grpven + QRY6->A1_COD + QRY6->A1_LOJA }  

//Desabilita Celulas
oSecCli:Cell("cliente"):Disable()  

oSecCli:Disable()        
                      
//Secao dados dos Produtos do Cliente
DEFINE SECTION oSecDado_6 OF oSecCli TITLE "Dados_ordem_4" TABLES "SB1","SD2","SF2"

DEFINE CELL NAME "b1_cod"	    OF oSecDado_6 ALIAS "SB1" TITLE "Produto"        	 SIZE 20
DEFINE CELL NAME "b1_i_descd"   OF oSecDado_6 ALIAS "SB1" TITLE "Descri��o"      	 SIZE 40     
DEFINE CELL NAME "d2_quant"	    OF oSecDado_6 ALIAS "SD2" TITLE "Quantidade"     	 SIZE 22 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "d2_um"    	OF oSecDado_6 ALIAS "SD2" TITLE "U.M."           	 SIZE 06
DEFINE CELL NAME "d2_qtsegum"	OF oSecDado_6 ALIAS "SD2" TITLE "Qtde. 2a U.M."  	 SIZE 22 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "d2_segum"	    OF oSecDado_6 ALIAS "SD2" TITLE "2a U.M."        	 SIZE 10 
DEFINE CELL NAME "d2_prcven"    OF oSecDado_6 ALIAS "SD2" TITLE "Vlr.Unit."      	 SIZE 16 PICTURE "@E 9,999,999,999.9999"
DEFINE CELL NAME "d2_total"     OF oSecDado_6 ALIAS "SD2" TITLE "Vlr.Total"      	 SIZE 22 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "d2_valbrut"   OF oSecDado_6 ALIAS "SD2" TITLE "Vlr.Bruto"      	 SIZE 22 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "d2_i_vlrdc"   OF oSecDado_6 ALIAS "SD2" TITLE "Vlr.Desconto Int." SIZE 23 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "PORCINT"      OF oSecDado_6 ALIAS ""    TITLE "% Desconto Int"    SIZE 20 PICTURE "@E 999.99"
DEFINE CELL NAME "d2_i_vlpar"   OF oSecDado_6 ALIAS "SD2" TITLE "Vlr.Desconto Par." SIZE 23 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "PORCPAR"      OF oSecDado_6 ALIAS ""    TITLE "% Desconto Par"    SIZE 20 PICTURE "@E 999.99"


//Desabilita Secao
oSecDado_6:Disable()

//Desabilita Celulas
oSecDado_6:Cell("d2_i_vlrdc"):Disable()
oSecDado_6:Cell("d2_i_vlpar"):Disable() 
oSecDado_6:Cell("PORCINT"):Disable()   
oSecDado_6:Cell("PORCPAR"):Disable()

//Alinhamento de cabecalho
oSecDado_6:Cell("d2_quant"):SetHeaderAlign("RIGHT")       
oSecDado_6:Cell("d2_qtsegum"):SetHeaderAlign("RIGHT")  
oSecDado_6:Cell("d2_prcven"):SetHeaderAlign("RIGHT")       
oSecDado_6:Cell("d2_total"):SetHeaderAlign("RIGHT")
oSecDado_6:Cell("d2_valbrut"):SetHeaderAlign("RIGHT")       
oSecDado_6:Cell("d2_i_vlrdc"):SetHeaderAlign("RIGHT")  
oSecDado_6:Cell("d2_i_vlpar"):SetHeaderAlign("RIGHT")     
oSecDado_6:Cell("PORCINT"):SetHeaderAlign("RIGHT")  
oSecDado_6:Cell("PORCPAR"):SetHeaderAlign("RIGHT")  

oSecDado_6:SetTotalInLine(.F.)                                            

oSecDado_6:OnPrintLine({|| cNomeRede := QRY6->a1_grpven  + " - " + SubStr(QRY6->acy_descri,1,40),cNomeCli := QRY6->A1_COD + '/' + QRY6->A1_LOJA + ' - ' + SubStr(QRY6->A1_NOME,1,40)}) 

oReport:PrintDialog()

Return               

/*
===============================================================================================================================
Programa----------: ROMS014PRI
Autor-------------: 
Data da Criacao---: 
===============================================================================================================================
Descri��o---------: Monta dados e corpo do relat�io
------------------: 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ROMS014PRI(oReport)

Local cFiltro   := "%"    
Private nOrdem  := oSecRede_1:GetOrder() //Busca ordem selecionada pelo usuario   

oReport:SetTitle("Rela��o de Descontos Contratuais Orderm  " + aOrd[nOrdem] + " - Emissao de " + dtoc(mv_par02) + " at� "  + dtoc(mv_par03))

//Define o filtro de acordo com os parametros digitados
//Filtra Filial da SF2,SD2,SA1,SB1,ZAZ,SA3,ACY
if !empty(alltrim(mv_par01))	
	
	if !empty(xFilial("SF2"))
		cFiltro   += " AND F2.F2_FILIAL IN " + FormatIn(mv_par01,";")
	endif	                         
	if !empty(xFilial("SD2"))
		cFiltro   += " AND D2.D2_FILIAL IN " + FormatIn(mv_par01,";")
	endif    
	if !empty(xFilial("ZAZ"))
		cFiltro   += " AND ZAZ.ZAZ_FILIAL IN " + FormatIn(mv_par01,";")
	endif                	
	if !empty(xFilial("SA1"))
		cFiltro   += " AND A1.A1_FILIAL IN " + FormatIn(mv_par01,";")
	endif
	if !empty(xFilial("SB1"))	
		cFiltro   += " AND B1.B1_FILIAL IN " + FormatIn(mv_par01,";")
	endif
	if !empty(xFilial("SA3"))
		cFiltro  += " AND SA3.A3_FILIAL IN " + FormatIn(mv_par01,";")
	endif
	if !empty(xFilial("ACY")) .And. nOrdem == 1
		cFiltro  += " AND ACY.ACY_FILIAL IN " + FormatIn(mv_par01,";")
	endif
endif 

//Filtra Emissao da SF2
if !empty(mv_par02) .and. !empty(mv_par03)
	cFiltro  += " AND F2.F2_EMISSAO BETWEEN '" + dtos(mv_par02) + "' AND '" + dtos(mv_par03) + "'"
endif

//Filtra Produto
if !empty(mv_par04) .and. !empty(mv_par05)
	cFiltro   += " AND D2.D2_COD BETWEEN '" + mv_par04 + "' AND '" + mv_par05 + "'"
endif

//Filtra Cliente
if !empty(mv_par06) .and. !empty(mv_par08)
	cFiltro   += " AND D2.D2_CLIENTE BETWEEN '" + mv_par06 + "' AND '" + mv_par08 + "'"
endif

//Filtra Loja Cliente
if !empty(mv_par07) .and. !empty(mv_par09)
	cFiltro   += " AND D2.D2_LOJA BETWEEN '" + mv_par07 + "' AND '" + mv_par09 + "'"   
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

//Filtra Grupo de Produtos
if !empty(mv_par15)
	cFiltro   += " AND SubStr(D2.D2_COD,1,4) IN " + FormatIn(mv_par15,";")
endif

//Filtra Produto Nivel 2
if !empty(mv_par16)
	cFiltro   += " AND B1.B1_I_NIV2 IN " + FormatIn(mv_par16,";")
endif

//Filtra Produto Nivel 3
if !empty(mv_par17)
	cFiltro   += " AND B1.B1_I_NIV3 IN " + FormatIn(mv_par17,";")
endif

//Filtra Produto Nivel 4
if !empty(mv_par18)
	cFiltro   += " AND B1.B1_I_NIV4 IN " + FormatIn(mv_par18,";")
endif          

//Filtra tipo de abatimento do contrato
If !Empty(mv_par19)   
	cFiltro   += " AND D2.D2_I_TPABA IN " + FormatIn(mv_par19,";")  
EndIf
             
//Filtra Sub Grupo de Produto
if !empty(mv_par21)
	cFiltro   += " AND B1.B1_I_SUBGR IN " + FormatIn(mv_par21,";")
endif               

cFiltro   += "%"
               
//Primeira Ordem - Rede_Produto
if nOrdem == 1    
    
		oSecRede_1:Enable()
		oSecDados_1:Enable()      
		                
		//Visualiza desconto Integral
		If mv_par20 == 1    
		
			oSecDados_1:Cell("d2_i_vlrdc"):Enable()
			oSecDados_1:Cell("PORCINT"):Enable()                                    
		
		//Visualiza desconto parcial
		ElseIf mv_par20 == 2   
		
			oSecDados_1:Cell("d2_i_vlpar"):Enable()   
			oSecDados_1:Cell("PORCPAR"):Enable()
			
		//Visualiza desconto integral e parcial
		Else         
		
			oSecDados_1:Cell("d2_i_vlrdc"):Enable()
			oSecDados_1:Cell("d2_i_vlpar"):Enable()
			oSecDados_1:Cell("PORCINT"):Enable()   
			oSecDados_1:Cell("PORCPAR"):Enable()
		
		EndIf               
		
		//Quebra por Rede		
		oBrkRede_1:= TRBreak():New(oSecDados_1,oSecRede_1:CELL("a1_grpven"),"SubTotal Rede: " + cNomeRede,.F.)          
		oBrkRede_1:SetTotalText({|| "SubTotal Rede: " + cNomeRede})
		
		TRFunction():New(oSecDados_1:Cell("d2_quant")  ,"VLRQTDE" ,"SUM"    ,oBrkRede_1,NIL,NIL,NIL                          			,.F.,.F.)
		TRFunction():New(oSecDados_1:Cell("d2_qtsegum"),NIL       ,"SUM"    ,oBrkRede_1,NIL,NIL,NIL                          			,.F.,.F.)
		TRFunction():New(oSecDados_1:Cell("d2_total")  ,"VLRTOTAL","SUM"    ,oBrkRede_1,NIL,NIL,NIL                          			,.F.,.F.)
		TRFunction():New(oSecDados_1:Cell("d2_valbrut"),"VLRBRUTO","SUM"    ,oBrkRede_1,NIL,NIL,NIL									,.F.,.F.)
		TRFunction():New(oSecDados_1:Cell("d2_i_vlrdc"),"VLRDESIN","SUM"    ,oBrkRede_1,NIL,NIL,NIL									,.F.,.F.)
		TRFunction():New(oSecDados_1:Cell("d2_i_vlpar"),"VLRDESPA","SUM"    ,oBrkRede_1,NIL,NIL,NIL									,.F.,.F.)
		TRFunction():New(oSecDados_1:Cell("d2_prcven") ,NIL       ,"ONPRINT",oBrkRede_1,NIL,NIL,{|| oSecDados_1:GetFunction("VLRTOTAL"):GetLastValue()/oSecDados_1:GetFunction("VLRQTDE"):GetLastValue() }		,.F.,.F.)
		TRFunction():New(oSecDados_1:Cell("PORCINT")   ,NIL       ,"ONPRINT",oBrkRede_1,NIL,NIL,{|| (oSecDados_1:GetFunction("VLRDESIN"):GetLastValue()/oSecDados_1:GetFunction("VLRTOTAL"):GetLastValue()) * 100 },.F.,.F.) 
		TRFunction():New(oSecDados_1:Cell("PORCPAR")   ,NIL       ,"ONPRINT",oBrkRede_1,NIL,NIL,{|| (oSecDados_1:GetFunction("VLRDESPA"):GetLastValue()/oSecDados_1:GetFunction("VLRTOTAL"):GetLastValue()) * 100 },.F.,.F.)
		
		
		//Imprime total geral da rede
		TRFunction():New(oSecDados_1:Cell("d2_quant")  ,"VLQTDE" ,"SUM" 	,NIL       ,NIL,NIL,NIL									,.F.,.T.)
		TRFunction():New(oSecDados_1:Cell("d2_qtsegum"),NIL,"SUM"          ,NIL       ,NIL,NIL,NIL									,.F.,.T.)
		TRFunction():New(oSecDados_1:Cell("d2_total")  ,"VLTOTAL","SUM"    ,NIL       ,NIL,NIL,NIL									,.F.,.T.)
		TRFunction():New(oSecDados_1:Cell("d2_valbrut"),"VLBRUTO","SUM"    ,NIL       ,NIL,NIL,NIL									,.F.,.T.)
		TRFunction():New(oSecDados_1:Cell("d2_i_vlrdc"),"VLDESIN","SUM"    ,NIL       ,NIL,NIL,NIL									,.F.,.T.)
		TRFunction():New(oSecDados_1:Cell("d2_i_vlpar"),"VLDESPA","SUM"    ,NIL       ,NIL,NIL,NIL									,.F.,.T.)
		TRFunction():New(oSecDados_1:Cell("d2_prcven") ,NIL      ,"ONPRINT",NIL       ,NIL,NIL,{|| oSecDados_1:GetFunction("VLTOTAL"):GetLastValue()/oSecDados_1:GetFunction("VLQTDE"):GetLastValue()}		,.F.,.T.)
		TRFunction():New(oSecDados_1:Cell("PORCINT")   ,NIL      ,"ONPRINT",		   ,NIL,NIL,{|| (oSecDados_1:GetFunction("VLDESIN"):GetLastValue()/oSecDados_1:GetFunction("VLTOTAL"):GetLastValue()) * 100 },.F.,.T.) 
		TRFunction():New(oSecDados_1:Cell("PORCPAR")   ,NIL      ,"ONPRINT",NIL       ,NIL,NIL,{|| (oSecDados_1:GetFunction("VLDESPA"):GetLastValue()/oSecDados_1:GetFunction("VLTOTAL"):GetLastValue()) * 100 },.F.,.T.)
		
		//Executa query para consultar Dados
		BEGIN REPORT QUERY oSecRede_1
			BeginSql alias "QRY1"   	   	
			   	SELECT 
			   	
					A1.a1_grpven,
					ACY.acy_descri,
					B1.b1_cod,
					B1.b1_i_descd,
					d2.d2_um,d2.d2_segum,
					SUM(d2.d2_total) / decode(SUM(d2.d2_quant),0,1,SUM(d2.d2_quant)) d2_prcven,
					SUM(d2.d2_quant) d2_quant,
					SUM(D2.d2_qtsegum) d2_qtsegum,
					SUM(d2.d2_total) d2_total,
					SUM(D2.d2_valbrut) d2_valbrut,
					SUM(d2.d2_i_vlrdc) d2_i_vlrdc,
					SUM(d2.d2_i_vlpar) d2_i_vlpar,
					round(((SUM(d2.d2_i_vlrdc) / SUM(D2.d2_total)) * 100),2) PORCINT,
					Round(((SUM(d2.d2_i_vlpar) / SUM(D2.d2_total)) * 100),2) PORCPAR
					
				FROM 
					%table:SF2% F2
					JOIN %table:SD2% D2  ON F2.f2_filial = d2.d2_filial AND F2.f2_doc = D2.d2_doc AND F2.f2_serie = D2.d2_serie AND F2.F2_CLIENTE = D2.D2_CLIENTE AND F2.F2_LOJA = D2.D2_LOJA
					JOIN %table:SA1% A1  ON F2.f2_cliente = A1.a1_cod AND F2.f2_loja = A1.a1_loja
					JOIN %table:SA3% SA3 ON F2.F2_VEND1 = SA3.A3_COD
					JOIN %table:ACY% ACY ON A1.a1_grpven = ACY.acy_grpven
					JOIN %table:SB1% B1  ON d2.d2_cod = B1.b1_cod
				WHERE 
					F2.%notDel%  
					AND D2.%notDel%  
					AND A1.%notDel%  
					AND SA3.%notDel%
					AND ACY.%notDel%
					AND B1.%notDel%     
					AND f2.f2_i_nrzaz <> ' '
      				AND d2.d2_i_vlrdc > 0
      				AND A1.a1_grpven <> ' '
					%exp:cFiltro%
			    GROUP BY
			   		A1.a1_grpven,ACY.acy_descri,B1.b1_cod,B1.b1_i_descd, d2.d2_um, d2.d2_segum
				ORDER BY 
					A1.a1_grpven,B1.b1_cod
			EndSql
		END REPORT QUERY oSecRede_1               
	
		oSecDados_1:SetParentQuery()
		oSecDados_1:SetParentFilter({|cParam| QRY1->a1_grpven == cParam},{|| QRY1->a1_grpven})
	
		oSecRede_1:Print(.T.)
        
		//segunda Ordem - Filial_Produto
		Elseif nOrdem == 2    
    
		oSecRede_4:Enable()
		oSecDado_4:Enable()      
		                
		//Visualiza desconto Integral
		If mv_par20 == 1                         
		
				oSecDado_4:Cell("d2_i_vlrdc"):Enable()
		        oSecDado_4:Cell("PORCINT"):Enable()                                    
		
		//Visualiza desconto parcial
		ElseIf mv_par20 == 2   
		
			    oSecDado_4:Cell("d2_i_vlpar"):Enable()   
			    oSecDado_4:Cell("PORCPAR"):Enable()
		
		//Visualiza desconto integral e parcial
		Else         
		
				oSecDado_4:Cell("d2_i_vlrdc"):Enable()
				oSecDado_4:Cell("d2_i_vlpar"):Enable()
				oSecDado_4:Cell("PORCINT"):Enable()   
				oSecDado_4:Cell("PORCPAR"):Enable()
		
		EndIf               
		
		//Quebra por Rede		
		oBrkRede_4:= TRBreak():New(oSecDado_4,oSecRede_4:CELL("f2_filial"),"SubTotal Filial: " + cNomFilial,.F.)          
		oBrkRede_4:SetTotalText({|| "SubTotal Filial: " + cNomFilial})
		
		TRFunction():New(oSecDado_4:Cell("d2_quant")  ,"VLRQTDE" ,"SUM" 	 ,oBrkRede_4,NIL,NIL,NIL						   		   ,.F.,.F.)
		TRFunction():New(oSecDado_4:Cell("d2_qtsegum"),NIL		  ,"SUM"     ,oBrkRede_4,NIL,NIL,NIL						   		   ,.F.,.F.)
		TRFunction():New(oSecDado_4:Cell("d2_total")  ,"VLRTOTAL","SUM" 	 ,oBrkRede_4,NIL,NIL,NIL						   		   ,.F.,.F.)
		TRFunction():New(oSecDado_4:Cell("d2_valbrut"),"VLRBRUTO","SUM" 	 ,oBrkRede_4,NIL,NIL,NIL						   		   ,.F.,.F.)
		TRFunction():New(oSecDado_4:Cell("d2_i_vlrdc"),"VLRDESIN","SUM" 	 ,oBrkRede_4,NIL,NIL,NIL						   		   ,.F.,.F.)
		TRFunction():New(oSecDado_4:Cell("d2_i_vlpar"),"VLRDESPA","SUM" 	 ,oBrkRede_4,NIL,NIL,NIL						           ,.F.,.F.)
		TRFunction():New(oSecDado_4:Cell("d2_prcven") ,NIL       ,"ONPRINT" ,oBrkRede_4,NIL,NIL,{|| oBrkRede_4:GetFunction("VLRTOTAL"):GetLastValue()/oBrkRede_4:GetFunction("VLRQTDE"):GetLastValue() }		,.F.,.F.)
		TRFunction():New(oSecDado_4:Cell("PORCINT")   ,NIL       ,"ONPRINT" ,oBrkRede_4,NIL,NIL,{|| (oBrkRede_4:GetFunction("VLRDESIN"):GetLastValue()/oBrkRede_4:GetFunction("VLRTOTAL"):GetLastValue()) * 100 },.F.,.F.) 
		TRFunction():New(oSecDado_4:Cell("PORCPAR")   ,NIL       ,"ONPRINT" ,oBrkRede_4,NIL,NIL,{|| (oBrkRede_4:GetFunction("VLRDESPA"):GetLastValue()/oBrkRede_4:GetFunction("VLRTOTAL"):GetLastValue()) * 100 },.F.,.F.)
		
		
		//Total Geral
		TRFunction():New(oSecDado_4:Cell("d2_quant")  ,"VLQTDE"  ,"SUM" 	 ,			,NIL,NIL,NIL								    ,.F.,.T.)
		TRFunction():New(oSecDado_4:Cell("d2_qtsegum"),NIL		  ,"SUM" 	 ,			,NIL,NIL,NIL								    ,.F.,.T.)
		TRFunction():New(oSecDado_4:Cell("d2_total")  ,"VLTOTAL" ,"SUM" 	 ,			,NIL,NIL,NIL								    ,.F.,.T.)
		TRFunction():New(oSecDado_4:Cell("d2_valbrut"),"VLBRUTO" ,"SUM" 	 ,			,NIL,NIL,NIL								    ,.F.,.T.)
		TRFunction():New(oSecDado_4:Cell("d2_i_vlrdc"),"VLDESIN" ,"SUM" 	 ,			,NIL,NIL,NIL								    ,.F.,.T.)
		TRFunction():New(oSecDado_4:Cell("d2_i_vlpar"),"PORCPAR" ,"SUM" 	 ,			,NIL,NIL,NIL								    ,.F.,.T.)
		TRFunction():New(oSecDado_4:Cell("d2_prcven") ,NIL       ,"ONPRINT" ,          ,NIL,NIL,{|| oSecDado_4:GetFunction("VLTOTAL"):GetLastValue()/oSecDado_4:GetFunction("VLQTDE"):GetLastValue()}		,.F.,.T.)
		TRFunction():New(oSecDado_4:Cell("PORCINT")   ,NIL       ,"ONPRINT" ,		    ,NIL,NIL,{|| (oSecDado_4:GetFunction("VLDESIN"):GetLastValue()/oSecDado_4:GetFunction("VLTOTAL"):GetLastValue()) * 100 },.F.,.T.) 
		TRFunction():New(oSecDado_4:Cell("PORCPAR")   ,NIL       ,"ONPRINT" ,          ,NIL,NIL,{|| (oSecDado_4:GetFunction("VLRDESPA"):GetLastValue()/oSecDado_4:GetFunction("VLTOTAL"):GetLastValue()) * 100 },.F.,.T.)

			
		//Executa query para consultar Dados
		BEGIN REPORT QUERY oSecRede_4
			BeginSql alias "QRY4"   	   	
			   	SELECT 
			   	
					F2.f2_filial,
					B1.b1_cod,
					B1.b1_i_descd,
					d2.d2_um,
					d2.d2_segum,
					SUM(d2.d2_total) / decode(SUM(d2.d2_quant),0,1,SUM(d2.d2_quant)) d2_prcven,
					SUM(d2.d2_quant) d2_quant,
					SUM(D2.d2_qtsegum) d2_qtsegum,
					SUM(d2.d2_total) d2_total,
					SUM(D2.d2_valbrut) d2_valbrut,
					SUM(d2.d2_i_vlrdc) d2_i_vlrdc,
					SUM(d2.d2_i_vlpar) d2_i_vlpar,
					round(((SUM(d2.d2_i_vlrdc) / SUM(D2.d2_total)) * 100),2) PORCINT,
					Round(((SUM(d2.d2_i_vlpar) / SUM(D2.d2_total)) * 100),2) PORCPAR
					
				FROM 
				
					%table:SF2% F2
					JOIN %table:SD2% D2  ON F2.f2_filial = d2.d2_filial AND F2.f2_doc = D2.d2_doc AND F2.f2_serie = D2.d2_serie 
					JOIN %table:SA1% A1  ON F2.f2_cliente = A1.a1_cod AND F2.f2_loja = A1.a1_loja
					JOIN %table:SA3% SA3 ON F2.F2_VEND1 = SA3.A3_COD
					JOIN %table:SB1% B1  ON d2.d2_cod = B1.b1_cod
				WHERE 
					F2.%notDel%  
					AND D2.%notDel%  
					AND A1.%notDel%  
					AND SA3.%notDel%					
					AND B1.%notDel%     
					AND f2.f2_i_nrzaz <> ' '
      				AND d2.d2_i_vlrdc > 0
					%exp:cFiltro%
			    GROUP BY
			   		F2.f2_filial,B1.b1_cod,B1.b1_i_descd, d2.d2_um, d2.d2_segum
				ORDER BY 
					F2.f2_filial,B1.b1_cod
					
			EndSql
			
		END REPORT QUERY oSecRede_4               
	
		oSecDado_4:SetParentQuery()
		oSecDado_4:SetParentFilter({|cParam| QRY4->f2_filial == cParam},{|| QRY4->f2_filial })
	
		oSecRede_4:Print(.T.)         
		
		
		//terceira Ordem - Produto
		Elseif nOrdem == 3    
    
		oSecDado_5:Enable()      
		                
		//Visualiza desconto Integral
		If mv_par20 == 1                         
		
				oSecDado_5:Cell("d2_i_vlrdc"):Enable()
		        oSecDado_5:Cell("PORCINT"):Enable()                                    
		
		//Visualiza desconto parcial
		ElseIf mv_par20 == 2   
		
			    oSecDado_5:Cell("d2_i_vlpar"):Enable()   
			    oSecDado_5:Cell("PORCPAR"):Enable()
		
		//Visualiza desconto integral e parcial
		Else         
		
				oSecDado_5:Cell("d2_i_vlrdc"):Enable()
				oSecDado_5:Cell("d2_i_vlpar"):Enable()
				oSecDado_5:Cell("PORCINT"):Enable()   
				oSecDado_5:Cell("PORCPAR"):Enable()
		
		EndIf               
		
		TRFunction():New(oSecDado_5:Cell("d2_quant")  ,"VLQTDE" ,"SUM" 	  ,NIL,NIL,NIL,NIL									 ,.F.,.T.)
		TRFunction():New(oSecDado_5:Cell("d2_qtsegum"),NIL		 ,"SUM" 	  ,NIL,NIL,NIL,NIL								     ,.F.,.T.)
		TRFunction():New(oSecDado_5:Cell("d2_total")  ,"VLTOTAL","SUM" 	  ,NIL,NIL,NIL,NIL									 ,.F.,.T.)
		TRFunction():New(oSecDado_5:Cell("d2_valbrut"),"VLBRUTO","SUM" 	  ,NIL,NIL,NIL,NIL									 ,.F.,.T.)
		TRFunction():New(oSecDado_5:Cell("d2_i_vlrdc"),"VLDESIN","SUM" 	  ,NIL,NIL,NIL,NIL									 ,.F.,.T.)
		TRFunction():New(oSecDado_5:Cell("d2_i_vlpar"),"VLRDESPA","SUM" 	  ,NIL,NIL,NIL,NIL									 ,.F.,.T.)
		TRFunction():New(oSecDado_5:Cell("d2_prcven") ,NIL      ,"ONPRINT"   ,NIL,NIL,NIL,{||  oSecDado_5:GetFunction("VLTOTAL"):GetLastValue()/oSecDado_5:GetFunction("VLQTDE"):GetLastValue()}		,.F.,.T.)
		TRFunction():New(oSecDado_5:Cell("PORCINT")   ,NIL      ,"ONPRINT"   ,NIL,NIL,NIL,{|| (oSecDado_5:GetFunction("VLDESIN"):GetLastValue()/oSecDado_5:GetFunction("VLTOTAL"):GetLastValue()) * 100 },.F.,.T.) 
		TRFunction():New(oSecDado_5:Cell("PORCPAR")   ,NIL      ,"ONPRINT"   ,NIL,NIL,NIL,{|| (oSecDado_5:GetFunction("VLRDESPA"):GetLastValue()/oSecDado_5:GetFunction("VLTOTAL"):GetLastValue()) * 100 },.F.,.T.)
		
		//Executa query para consultar Dados
		BEGIN REPORT QUERY oSecDado_5
			BeginSql alias "QRY5"   	   	
			   	SELECT 
					B1.b1_cod,
					B1.b1_i_descd,
					d2.d2_um,
					d2.d2_segum,
					SUM(d2.d2_total) / decode(SUM(d2.d2_quant),0,1,SUM(d2.d2_quant)) d2_prcven,
					SUM(d2.d2_quant) d2_quant,
					SUM(D2.d2_qtsegum) d2_qtsegum,
					SUM(d2.d2_total) d2_total,
					SUM(D2.d2_valbrut) d2_valbrut,
					SUM(d2.d2_i_vlrdc) d2_i_vlrdc,
					SUM(d2.d2_i_vlpar) d2_i_vlpar,
					round(((SUM(d2.d2_i_vlrdc) / SUM(D2.d2_total)) * 100),2) PORCINT,
					Round(((SUM(d2.d2_i_vlpar) / SUM(D2.d2_total)) * 100),2) PORCPAR
				FROM 
					%table:SF2% F2
					JOIN %table:SD2% D2  ON F2.f2_filial = d2.d2_filial AND F2.f2_doc = D2.d2_doc AND F2.f2_serie = D2.d2_serie 
					JOIN %table:SA1% A1  ON F2.f2_cliente = A1.a1_cod AND F2.f2_loja = A1.a1_loja
					JOIN %table:SA3% SA3 ON F2.F2_VEND1 = SA3.A3_COD
					JOIN %table:SB1% B1  ON d2.d2_cod = B1.b1_cod
				WHERE 
					F2.%notDel%  
					AND D2.%notDel%  
					AND A1.%notDel%  
					AND SA3.%notDel%
					AND B1.%notDel%     
					AND f2.f2_i_nrzaz <> ' '
      				AND d2.d2_i_vlrdc > 0
					%exp:cFiltro%
			    GROUP BY
			   		B1.b1_cod,B1.b1_i_descd, d2.d2_um, d2.d2_segum
				ORDER BY 
					B1.b1_cod
			EndSql
		END REPORT QUERY oSecDado_5               
	
		oSecDado_5:Print(.T.)
							
		
		//Ordem Cliente x Produto
		Elseif nOrdem == 4    
    
		oSecRede_6:Enable()
		oSecCli:Enable()
		oSecDado_6:Enable()      
		                
		//Visualiza desconto Integral
		If mv_par20 == 1    
		
				oSecDado_6:Cell("d2_i_vlrdc"):Enable()
		        oSecDado_6:Cell("PORCINT"):Enable()                                    
		
		//Visualiza desconto parcial
		ElseIf mv_par20 == 2   
		
			    oSecDado_6:Cell("d2_i_vlpar"):Enable()   
			    oSecDado_6:Cell("PORCPAR"):Enable()
		
		//Visualiza desconto integral e parcial
		Else         
		
				oSecDado_6:Cell("d2_i_vlrdc"):Enable()
				oSecDado_6:Cell("d2_i_vlpar"):Enable()
				oSecDado_6:Cell("PORCINT"):Enable()   
				oSecDado_6:Cell("PORCPAR"):Enable()
		
		EndIf  
		
		//Quebra por Cliente		
		oBrkRede_2:= TRBreak():New(oSecDado_6,oSecCli:CELL("cliente"),"SubTotal Cliente: " + cNomeCli,.F.)          
		oBrkRede_2:SetTotalText({|| "SubTotal Cliente: " + cNomeCli})
		
		TRFunction():New(oSecDado_6:Cell("d2_quant")  ,"VLRQTDE" ,"SUM"    ,oBrkRede_2,NIL,NIL,NIL                          		,.F.,.F.)
		TRFunction():New(oSecDado_6:Cell("d2_qtsegum"),NIL       ,"SUM"    ,oBrkRede_2,NIL,NIL,NIL                          		,.F.,.F.)
		TRFunction():New(oSecDado_6:Cell("d2_total")  ,"VLRTOTAL","SUM"    ,oBrkRede_2,NIL,NIL,NIL                          		,.F.,.F.)
		TRFunction():New(oSecDado_6:Cell("d2_valbrut"),"VLRBRUTO","SUM"    ,oBrkRede_2,NIL,NIL,NIL									,.F.,.F.)
		TRFunction():New(oSecDado_6:Cell("d2_i_vlrdc"),"VLRDESIN","SUM"    ,oBrkRede_2,NIL,NIL,NIL									,.F.,.F.)
		TRFunction():New(oSecDado_6:Cell("d2_i_vlpar"),"VLRDESPA","SUM"    ,oBrkRede_2,NIL,NIL,NIL									,.F.,.F.)
		TRFunction():New(oSecDado_6:Cell("d2_prcven") ,NIL       ,"ONPRINT",oBrkRede_2,NIL,NIL,{|| oSecDado_6:GetFunction("VLRTOTAL"):GetLastValue()/oSecDado_6:GetFunction("VLRQTDE"):GetLastValue() }		,.F.,.F.)
		TRFunction():New(oSecDado_6:Cell("PORCINT")   ,NIL       ,"ONPRINT",oBrkRede_2,NIL,NIL,{|| (oSecDado_6:GetFunction("VLRDESIN"):GetLastValue()/oSecDado_6:GetFunction("VLRTOTAL"):GetLastValue()) * 100 },.F.,.F.) 
		TRFunction():New(oSecDado_6:Cell("PORCPAR")   ,NIL       ,"ONPRINT",oBrkRede_2,NIL,NIL,{|| (oSecDado_6:GetFunction("VLRDESPA"):GetLastValue()/oSecDado_6:GetFunction("VLRTOTAL"):GetLastValue()) * 100 },.F.,.F.)             
		 						
		
		//Quebra por Rede		
		oBrkRede_1:= TRBreak():New(oReport,oSecRede_6:CELL("a1_grpven"),"SubTotal Rede: " + cNomeRede,.F.)          
		oBrkRede_1:SetTotalText({|| "SubTotal Rede: " + cNomeRede})
		
		TRFunction():New(oSecDado_6:Cell("d2_quant")  ,"VLRQTDRD" ,"SUM"    ,oBrkRede_1,NIL,NIL,NIL                          		,.F.,.F.)
		TRFunction():New(oSecDado_6:Cell("d2_qtsegum"),NIL       ,"SUM"    ,oBrkRede_1,NIL,NIL,NIL                          		,.F.,.F.)
		TRFunction():New(oSecDado_6:Cell("d2_total")  ,"VLRTOTRD","SUM"    ,oBrkRede_1,NIL,NIL,NIL                          		,.F.,.F.)
		TRFunction():New(oSecDado_6:Cell("d2_valbrut"),"VLRBRUTRD","SUM"    ,oBrkRede_1,NIL,NIL,NIL									,.F.,.F.)
		TRFunction():New(oSecDado_6:Cell("d2_i_vlrdc"),"VLRDESIRD","SUM"    ,oBrkRede_1,NIL,NIL,NIL									,.F.,.F.)
		TRFunction():New(oSecDado_6:Cell("d2_i_vlpar"),"VLRDESPRD","SUM"    ,oBrkRede_1,NIL,NIL,NIL									,.F.,.F.)
		TRFunction():New(oSecDado_6:Cell("d2_prcven") ,NIL       ,"ONPRINT",oBrkRede_1,NIL,NIL,{|| oSecDado_6:GetFunction("VLRTOTRD"):GetLastValue()/oSecDado_6:GetFunction("VLRQTDRD"):GetLastValue() }		,.F.,.F.)
		TRFunction():New(oSecDado_6:Cell("PORCINT")   ,NIL       ,"ONPRINT",oBrkRede_1,NIL,NIL,{|| (oSecDado_6:GetFunction("VLRDESIRD"):GetLastValue()/oSecDado_6:GetFunction("VLRTOTRD"):GetLastValue()) * 100 },.F.,.F.) 
		TRFunction():New(oSecDado_6:Cell("PORCPAR")   ,NIL       ,"ONPRINT",oBrkRede_1,NIL,NIL,{|| (oSecDado_6:GetFunction("VLRDESPRD"):GetLastValue()/oSecDado_6:GetFunction("VLRTOTRD"):GetLastValue()) * 100 },.F.,.F.)
		
		
		//Imprime total geral da rede
		TRFunction():New(oSecDado_6:Cell("d2_quant")  ,"VLQTDE" ,"SUM" 	,NIL       ,NIL,NIL,NIL									,.F.,.T.)
		TRFunction():New(oSecDado_6:Cell("d2_qtsegum"),NIL,"SUM"          ,NIL       ,NIL,NIL,NIL									,.F.,.T.)
		TRFunction():New(oSecDado_6:Cell("d2_total")  ,"VLTOTAL","SUM"    ,NIL       ,NIL,NIL,NIL									,.F.,.T.)
		TRFunction():New(oSecDado_6:Cell("d2_valbrut"),"VLBRUTO","SUM"    ,NIL       ,NIL,NIL,NIL									,.F.,.T.)
		TRFunction():New(oSecDado_6:Cell("d2_i_vlrdc"),"VLDESIN","SUM"    ,NIL       ,NIL,NIL,NIL									,.F.,.T.)
		TRFunction():New(oSecDado_6:Cell("d2_i_vlpar"),"VLDESPA","SUM"    ,NIL       ,NIL,NIL,NIL									,.F.,.T.)
		TRFunction():New(oSecDado_6:Cell("d2_prcven") ,NIL      ,"ONPRINT",NIL       ,NIL,NIL,{|| oSecDado_6:GetFunction("VLTOTAL"):GetLastValue()/oSecDado_6:GetFunction("VLQTDE"):GetLastValue()}		,.F.,.T.)
		TRFunction():New(oSecDado_6:Cell("PORCINT")   ,NIL      ,"ONPRINT",		   ,NIL,NIL,{|| (oSecDado_6:GetFunction("VLDESIN"):GetLastValue()/oSecDado_6:GetFunction("VLTOTAL"):GetLastValue()) * 100 },.F.,.T.) 
		TRFunction():New(oSecDado_6:Cell("PORCPAR")   ,NIL      ,"ONPRINT",NIL       ,NIL,NIL,{|| (oSecDado_6:GetFunction("VLDESPA"):GetLastValue()/oSecDado_6:GetFunction("VLTOTAL"):GetLastValue()) * 100 },.F.,.T.)
		
		//Executa query para consultar Dados
		BEGIN REPORT QUERY oSecRede_6
			BeginSql alias "QRY6"   	   	
			   	SELECT 
					A1.a1_grpven,
					ACY.acy_descri,
					B1.b1_cod,
					B1.b1_i_descd,
					d2.d2_um,
					d2.d2_segum,
					A1.A1_COD,
					A1.A1_LOJA,
					A1.A1_NOME,
					A1.A1_COD_MUN,
					A1.A1_MUN,
					A1.A1_EST,
					SUM(d2.d2_total) / decode(SUM(d2.d2_quant),0,1,SUM(d2.d2_quant)) d2_prcven,
					SUM(d2.d2_quant) 	d2_quant,
					SUM(D2.d2_qtsegum) d2_qtsegum,
					SUM(d2.d2_total) 	d2_total,
					SUM(D2.d2_valbrut) d2_valbrut,
					SUM(d2.d2_i_vlrdc) d2_i_vlrdc,
					SUM(d2.d2_i_vlpar) d2_i_vlpar,
					round(((SUM(d2.d2_i_vlrdc) / SUM(D2.d2_total)) * 100),2) PORCINT,
					Round(((SUM(d2.d2_i_vlpar) / SUM(D2.d2_total)) * 100),2) PORCPAR
					
				FROM 
					%table:SF2% F2
					JOIN %table:SD2% D2  ON F2.f2_filial = d2.d2_filial AND F2.f2_doc = D2.d2_doc AND F2.f2_serie = D2.d2_serie AND F2.F2_CLIENTE = D2.D2_CLIENTE AND F2.F2_LOJA = D2.D2_LOJA
					JOIN %table:SA1% A1  ON F2.f2_cliente = A1.a1_cod AND F2.f2_loja = A1.a1_loja
					JOIN %table:SA3% SA3 ON F2.F2_VEND1 = SA3.A3_COD
					JOIN %table:ACY% ACY ON A1.a1_grpven = ACY.acy_grpven
					JOIN %table:SB1% B1  ON d2.d2_cod = B1.b1_cod
				WHERE 
					F2.%notDel%  
					AND D2.%notDel%  
					AND A1.%notDel%  
					AND SA3.%notDel%
					AND ACY.%notDel%
					AND B1.%notDel%     
					AND f2.f2_i_nrzaz <> ' '
      				AND d2.d2_i_vlrdc > 0
      				AND A1.a1_grpven <> ' '
					%exp:cFiltro%
			    GROUP BY
			   		A1.a1_grpven,ACY.acy_descri,B1.b1_cod,B1.b1_i_descd,d2.d2_um,d2.d2_segum,A1.A1_COD,A1.A1_LOJA,A1.A1_NOME,A1.A1_COD_MUN,A1.A1_MUN,A1.A1_EST
				ORDER BY 
					A1.a1_grpven,A1.A1_COD,A1.A1_LOJA,B1.b1_cod
			EndSql
		END REPORT QUERY oSecRede_6               
	    
		oSecCli:SetParentQuery()
		oSecCli:SetParentFilter({|cParam| QRY6->a1_grpven == cParam},{|| QRY6->a1_grpven })
	
		oSecDado_6:SetParentQuery()
		oSecDado_6:SetParentFilter({|cParam| QRY6->A1_COD + QRY6->A1_LOJA == cParam},{|| QRY6->A1_COD + QRY6->A1_LOJA })
	
		oSecRede_6:Print(.T.)
		
	        
EndIf
     
Return
                           
/*
===============================================================================================================================
Programa----------: ROMS014NOM
Autor-------------: Jeovane   
Data da Criacao---: 29/07/2009
===============================================================================================================================
Descri��o---------: Busca nome da filial     
------------------: 
===============================================================================================================================
Parametros--------: cCodFil : Codigo da Filial a ser retornado o nome  
===============================================================================================================================
Retorno-----------: _cRet := Nome da filial
===============================================================================================================================
*/ 
Static function ROMS014NOM(cCodFil)
local _aAreaSM0 := SM0->(getArea())
local _cRet := " "

SM0->(dbSelectArea("SM0"))
SM0->(dbSetOrder(1))
SM0->(dbSeek(cEmpAnt+ cCodFil))
_cRet := SM0->M0_FILIAL 

//Restaura integridade da SM0
SM0->(dbSetOrder(_aAreaSM0[2]))
SM0->(dbGoTo(_aAreaSM0[3]))

return _cRet