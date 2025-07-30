/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alexandre V.  |18/03/2016| Chamado 14774. Ajuste para padronizar a utiliza��o da rotina que retorna o nome da Filial. 
Lucas Borges  |09/10/2024| Chamado 48465. Retirada manipula��o do SX1
===============================================================================================================================
*/

#include "report.ch"
#include "protheus.ch"

/*
===============================================================================================================================
Programa--------: ROMS018
Autor-----------: Fabiano Dias da Silva
Data da Criacao-: 07/06/2010
===============================================================================================================================
Descri��o-------: Relat�rio das diverg�ncias de Fretes por Filial
===============================================================================================================================
Uso-------------: Italac
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/

User Function ROMS018()

Private cPerg := "ROMS018"
Private QRY1       
Private oReport
Private oSecFilial,oSecDados
Private oBrkFilial

Private cNomFilial:= "" //Armazena o nome da filial corrente para que seja utilizada na impressao da quebra  

pergunte(cPerg,.F.)

DEFINE REPORT oReport NAME cPerg TITLE "Relat�rio de Divergencias Frete" PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} Description "Este relat�rio emitir� a divergencia de valores de Frete gerados." 

//Seta Padrao de impressao como Paisagem
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)                                                        


//Secao dados da Filial
DEFINE SECTION oSecFilial OF oReport TITLE "FILIAL" TABLES "DAK"

DEFINE CELL NAME "DAK_FILIAL"	OF oSecFilial ALIAS "DAK" TITLE "FILIAL"    SIZE 12
DEFINE CELL NAME "NOMFIL"	    OF oSecFilial ALIAS ""    TITLE "DESCRICAO" SIZE 40 BLOCK{|| FWFilialName(,QRY1->DAK_FILIAL)}

oSecFilial:SetTotalInLine(.F.)

DEFINE SECTION oSecDados OF oSecFilial TITLE "DADOS FRETE" TABLES "DAK"

DEFINE CELL NAME "DAK_COD"	    OF oSecDados ALIAS "DAK" TITLE "CARGA"        	    SIZE 10
DEFINE CELL NAME "DAK_DATA"     OF oSecDados ALIAS "DAK" TITLE "DT MONTAGEM CARGA" 	SIZE 20     
DEFINE CELL NAME "FRTDAK"       OF oSecDados ALIAS "DAK" TITLE "FRETE DAK"     	    SIZE 20 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "FRTDAI"       OF oSecDados ALIAS ""    TITLE "FRETE DAI"     	    SIZE 20 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "FRTSF2"       OF oSecDados ALIAS ""    TITLE "FRETE SF2"     	    SIZE 20 PICTURE "@E 9,999,999,999.99"
DEFINE CELL NAME "FRTSD2"       OF oSecDados ALIAS ""    TITLE "FRETE SD2"     	    SIZE 20 PICTURE "@E 9,999,999,999.99"

//Alinhamento de cabecalho
oSecDados:Cell("FRTDAK"):SetHeaderAlign("RIGHT")       
oSecDados:Cell("FRTDAI"):SetHeaderAlign("RIGHT")  
oSecDados:Cell("FRTSF2"):SetHeaderAlign("RIGHT")       
oSecDados:Cell("FRTSD2"):SetHeaderAlign("RIGHT")

oSecDados:SetTotalInLine(.F.)                                               

oSecDados:OnPrintLine({|| cNomFilial := QRY1->DAK_FILIAL + ' - ' + FWFilialName(,QRY1->DAK_FILIAL)})

oReport:PrintDialog()

Return               

/*
===============================================================================================================================
Programa--------: PrintReport
Autor-----------: Fabiano Dias da Silva
Data da Criacao-: 07/06/2010
===============================================================================================================================
Descri��o-------: Processa a impress�o do Relat�rio das diverg�ncias de Fretes por Filial
===============================================================================================================================
Uso-------------: Italac
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/

Static Function PrintReport(oReport)

Local cFiltro   := "%"       
Local cFilFil   := "%"  

oReport:SetTitle("RELA��O DE DIVERGENCIA DE VALORES FRETE MONTAGEM DE CARGA de " + dtoc(mv_par02) + " at� "  + dtoc(mv_par03))

//Define o filtro de acordo com os parametros digitados
if !empty(alltrim(mv_par01))	
	
	if !empty(xFilial("DAK"))
		cFiltro   += " AND DAK.DAK_FILIAL IN " + FormatIn(mv_par01,";") 
		cFilFil   += " AND DAK.DAK_FILIAL IN " + FormatIn(mv_par01,";") 
	endif	                          

endif 

//Filtra Emissao da DAK
if !empty(mv_par02) .and. !empty(mv_par03)
	cFiltro  += " AND DAK.DAK_DATA BETWEEN '" + dtos(mv_par02) + "' AND '" + dtos(mv_par03) + "'"
endif

cFiltro   += "%"   
cFilFil   += "%" 
               
		//Quebra por Filial
		oBrkFilial:= TRBreak():New(oSecFilial,oSecFilial:CELL("DAK_FILIAL"),"SubTotal Filial: " + cNomFilial,.F.)          
		oBrkFilial:SetTotalText({|| "SubTotal Filial: " + cNomFilial})
		
		
		TRFunction():New(oSecDados:Cell("FRTDAK")      ,NIL,"SUM" 	 ,oBrkFilial,NIL,NIL,NIL,.F.,.F.)
		TRFunction():New(oSecDados:Cell("FRTDAI")		,NIL,"SUM" 	 ,oBrkFilial,NIL,NIL,NIL,.F.,.F.)
		TRFunction():New(oSecDados:Cell("FRTSF2")  		,NIL,"SUM" 	 ,oBrkFilial,NIL,NIL,NIL,.F.,.F.)
		TRFunction():New(oSecDados:Cell("FRTSD2")		,NIL,"SUM" 	 ,oBrkFilial,NIL,NIL,NIL,.F.,.F.)
		
		
		//Executa query para consultar Dados
		BEGIN REPORT QUERY oSecFilial
			BeginSql alias "QRY1"   	   	
			   	SELECT 
					DAK.DAK_FILIAL,DAK.DAK_COD,DAK.DAK_DATA,DAK.DAK_I_FRET FRTDAK,
					(SELECT SUM(DAI.DAI_I_FRET) FROM DAI010 DAI WHERE DAI.D_E_L_E_T_ = ' ' AND DAK.DAK_FILIAL = DAI.DAI_FILIAL AND DAK.DAK_COD = DAI.DAI_COD %exp:cFilFil%) FRTDAI,
					(SELECT SUM(SF2.F2_I_FRET)  FROM SF2010 SF2 WHERE SF2.D_E_L_E_T_ = ' ' AND DAK.DAK_FILIAL = SF2.F2_FILIAL AND DAK.DAK_COD = SF2.F2_CARGA %exp:cFilFil%) FRTSF2,
					(SELECT SUM(SD2.D2_I_FRET)  FROM SD2010 SD2 JOIN SF2010 SF2 ON SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
					AND SF2.F2_LOJA = SD2.D2_LOJA WHERE SD2.D_E_L_E_T_ = ' ' AND SF2.D_E_L_E_T_ = ' ' AND DAK.DAK_FILIAL = SF2.F2_FILIAL AND DAK.DAK_COD = SF2.F2_CARGA %exp:cFilFil%) FRTSD2
				FROM 
					%table:DAK% DAK
				WHERE 
					DAK.%notDel%                                                                                                                                                           
					%exp:cFiltro%
					AND ((DAK.DAK_I_FRET <> (SELECT SUM(DAI.DAI_I_FRET) FROM DAI010 DAI WHERE DAI.D_E_L_E_T_ = ' ' AND DAK.DAK_FILIAL = DAI.DAI_FILIAL AND DAK.DAK_COD = DAI.DAI_COD %exp:cFilFil%))
					OR (DAK.DAK_I_FRET <> (SELECT SUM(SF2.F2_I_FRET)  FROM SF2010 SF2 WHERE SF2.D_E_L_E_T_ = ' ' AND DAK.DAK_FILIAL = SF2.F2_FILIAL AND DAK.DAK_COD = SF2.F2_CARGA %exp:cFilFil%))
					OR (DAK.DAK_I_FRET <> (SELECT SUM(SD2.D2_I_FRET)  FROM SD2010 SD2 JOIN SF2010 SF2 ON SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
					AND SF2.F2_LOJA = SD2.D2_LOJA WHERE SD2.D_E_L_E_T_ = ' ' AND SF2.D_E_L_E_T_ = ' ' AND DAK.DAK_FILIAL = SF2.F2_FILIAL AND DAK.DAK_COD = SF2.F2_CARGA %exp:cFilFil%))) 
				ORDER BY 
					DAK.DAK_FILIAL,DAK.DAK_DATA,DAK.DAK_COD
			EndSql
		END REPORT QUERY oSecFilial               
	
		oSecDados:SetParentQuery()
		oSecDados:SetParentFilter({|cParam| QRY1->DAK_FILIAL == cParam},{|| QRY1->DAK_FILIAL })
	
		oSecFilial:Print(.T.)         

     
Return
