/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 08/05/2018 | Padronização dos cabeçalhos dos fontes e funções do módulo financeiro. Chamado 24726.
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges | 09/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 08/03/2021 | Incluir recurso para copiar arquivo gerado para o browse do usuário em acesso Web. Chamado 35771. 
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"          
#INCLUDE "TopConn.ch"

/*
===============================================================================================================================
Programa----------: AFIN018 
Autor-------------: Fabiano
Data da Criacao---: 19/07/2010 
===============================================================================================================================
Descrição---------: Gera XML (Excel) de Titulos do Contas a Receber.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AFIN018()          
Local _cDirSmartC, aAux, _cFileTxt, _nI, _nTamTexto

Private cPerg:="AFIN018"
Private _cFilial,_dDtEmiIni,_dDtEmiFin,_dDtVenIni,_dDtVenFim,_cCliIni,_cCliFin,_cLojaIni,_cLojaFin,_cArquivo

if Pergunte(cPerg,.t.) 
 
	_cFilial	:= mv_par01
	_dDtEmiIni	:= DTos(mv_par02)
	_dDtEmiFin	:= DToS(mv_par03)
	_dDtVenIni	:= DtoS(mv_par04)
	_dDtVenFim	:= DtoS(mv_par05)
	_cCliIni    := mv_par06
	_cCliFin    := mv_par08    
	_cLojaIni   := mv_par07
	_cLojaFin   := mv_par09
	_cArquivo   := mv_par10 
	
    If Empty(_cArquivo)
       U_ItMsg( 'Nome do arquivo não informado!' , 'Atenção!' , , 1)
	   Break
	EndIf 

    _cDirSmartC := GetClientDir()
	  
	If Empty(_cDirSmartC) // Usuário utilizando SmartClient HTML
       aAux := separa(_cArquivo,".")
         
	   _nTamTexto := Len(aAux[1])
	   _cFileTxt  := ""
	   _nI := Rat("/",aAux[1])
		 
	   If _nI > 0
          _cFileTxt := SubStr(aAux[1],_nI+1,_nTamTexto)  
	   EndIf
         
	   If Empty(_cFileTxt)
          _nI := Rat("\",aAux[1])
		  If _nI > 0
             _cFileTxt := SubStr(aAux[1],_nI+1,_nTamTexto)  
		  EndIf
	   EndIf
         
	   If Empty(_cFileTxt)
          _cFileTxt := aAux[1]
	   EndIf
         
	   _cArquivo := "\Spool\"+AllTrim(_cFileTxt)
		
    EndIf

	Processa({|| Execute() },"Processando...")

    If Empty(_cDirSmartC) // Usuário utilizando SmartClient HTML

	   If File(_cArquivo)
          CpyS2TW(_cArquivo)  // Copia o arquivo para o Browse de navegação Web do usuário
	      Sleep(10000)  // 10 segundos
	   EndIf

    EndIf
	
Endif            

Return

/*
===============================================================================================================================
Programa----------: Execute
Autor-------------: Fabiano
Data da Criacao---: 19/07/2010 
===============================================================================================================================
Descrição---------: Localiza Titulos e gera XML
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/                          
Static Function Execute()

Local oAlias 	:= GetNextAlias()             
Local cNome		:=""
Local aDados	:={}
Local aAux		:={}
Local nTotal	:=0
Local cFiltro   := ""

//=====================     
// Filtros
//=====================
If !Empty(_cFilial)
	cFiltro+=" AND E1.E1_FILIAL IN " + FormatIn(_cFilial,";")
EndIf

	cQuery:="SELECT" 
	cQuery+=" E1.E1_EMISSAO,E1.E1_VENCTO,E1.E1_NUM,E1.E1_PARCELA,E1.E1_CLIENTE,E1.E1_LOJA,"       
	cQuery+=" A1.A1_NOME,E1.E1_VALOR "
	cQuery+="FROM " + RETSQLNAME("SE1") + " E1 "   
	cQuery+=" JOIN " + RETSQLNAME("SA1") + " A1 ON E1.E1_CLIENTE = A1.A1_COD AND E1.E1_LOJA = A1.A1_LOJA "   
	cQuery+="WHERE" 
	cQuery+=" E1.D_E_L_E_T_ <> '*'"
	cQuery+=" AND A1.D_E_L_E_T_ <> '*'"
	cQuery+=" AND E1.E1_TIPO = 'NF '"
	cQuery+=" AND E1.E1_ORIGEM = 'MATA460'"
	cQuery+=" AND E1.E1_EMISSAO BETWEEN '" + _dDtEmiIni + "' AND '" + _dDtEmiFin + "'"
	cQuery+=" AND E1.E1_VENCTO BETWEEN '"  + _dDtVenIni + "' AND '" + _dDtVenFim + "'"
	cQuery+=" AND E1.E1_CLIENTE BETWEEN '" + _cCliIni   + "' AND '" + _cCliFin   + "'"
	cQuery+=" AND E1.E1_LOJA BETWEEN '"    + _cLojaIni  + "' AND '" + _cLojaFin  + "'"
	cQuery+= cFiltro   
	cQuery+=" ORDER BY"
	cQuery+=" E1.E1_VENCTO,E1.E1_NUM,E1.E1_PARCELA" 
	

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), oAlias, .T., .F. )
Count to nreg

ProcRegua(nreg)

(oAlias)->(Dbgotop())
                                                                   
aAdd( aDados , { "Emissao","Vencimento","Titulo/Parcela","Codigo Cliente","Razao Social","Valor" } )   
aAdd( aDados , { "","","","","","" })//Imprime Linhas em branco                     

While (oAlias)->(!eof())                                     
	
		IncProc("Processando Titulo: " + AllTrim((oAlias)->E1_NUM))
	
		//==================================
		// Adiciona Dados no array
		//==================================
		cNome	 := RemovCar(AllTrim((oAlias)->A1_NOME))//Funcao que remove caracteres especiais para nao ocorrer erro na geracao do xml	      
		aAdd( aDados , {DToC(StoD((oAlias)->E1_EMISSAO)),DToC(StoD((oAlias)->E1_VENCTO)),(oAlias)->E1_NUM +'/'+(oAlias)->E1_PARCELA,;
					    (oAlias)->E1_CLIENTE +'-'+(oAlias)->E1_LOJA,cNome,(oAlias)->E1_VALOR})	
		
		nTotal+=(oAlias)->E1_VALOR 
		
		(oAlias)->(Dbskip())
		
	Enddo                             
	                        
	dbSelectArea(oAlias)
	(oAlias)->(dbCloseArea())
	
	//==================================
	// SubTotal e Total Geral
	//==================================
	aAdd( aDados , { ""     ,"","","","",""     }) // Imprime Linhas em branco 
	aAdd( aDados , { "Total","","","","",nTotal })
	
//==================================
// Converte Array em XML
//==================================
aAux	 := separa(_cArquivo,".")
_cArquivo:= AllTrim(aAux[1])+".xml"

RayToXml(aDados,_cArquivo)

Return

/*
===============================================================================================================================
Programa----------: RayToXml
Autor-------------: Abrahao P. Santos
Data da Criacao---: 22/12/2008 
===============================================================================================================================
Descrição---------: Cria um arquivo XML de um Array.                                      
                    Converte array para XLM. 
===============================================================================================================================
Parametros--------: aTabela = Array de dados.
                    cFileName = Nome do arquivo.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
Static Function RayToXml(aTabela,cFileName)
                                    
Local y,i		:= 0
Private nHdlE	:= fCreate(cFileName)
Private cEOL	:= "CHR(13)+CHR(10)"

//==========================
// Cabecalho do XML
//==========================
cLin := '<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?> '
cLin += '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" '
cLin += ' xmlns:o="urn:schemas-microsoft-com:office:office" '
cLin += ' xmlns:x="urn:schemas-microsoft-com:office:excel" '
cLin += ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" '
cLin += ' xmlns:html="http://www.w3.org/TR/REC-html40"> '
cLin += ' <Styles><Style ss:ID="Default" ss:Name="Normal"></Style><Style ss:ID="s21"><NumberFormat ss:Format="Short Date"/></Style></Styles> '
cLin += ' <Worksheet ss:Name="Planilha"><Table> '
fWrite(nHdlE,cLin,Len(cLin))

//==========================
// Convertendo Array
//==========================
for i:=1 to len(aTabela)        
	//==========================
	// inicia linha
	//==========================
	cLin:="<Row>"
	fWrite(nHdlE,cLin,Len(cLin))
	
	for y:=1 to len(aTabela[i])
		
		if ValType(aTabela[i,y]) == "N"
			cLin:='<Cell><Data ss:Type="Number">'+ALLTRIM(str(aTabela[i,y]))+'</Data></Cell>'
		elseif ValType(aTabela[i,y]) == "D"
			cData:=dtos(aTabela[i,y])
		elseIf ValType(aTabela[i,y]) == "C"
			cLin:='<Cell><Data ss:Type="String">'+aTabela[i,y]+'</Data></Cell>'  
		else
			cLin:='<Cell><Data ss:Type="String">/Data></Cell>'	
		endif
		
		fWrite(nHdlE,cLin,Len(cLin))
		
	next y
	//==========================
	// finaliza linha
	//==========================
	cLin:="</Row>"
	fWrite(nHdlE,cLin,Len(cLin))
	
next i

//==========================
// Rodape do XML
//==========================
cLin := '</Table></Worksheet></Workbook>'
fWrite(nHdlE,cLin,Len(cLin))

fClose(nHdlE)

return       

/*
===============================================================================================================================
Programa----------: RemovCar
Autor-------------: Fabiano Dias
Data da Criacao---: 18/06/2010
===============================================================================================================================
Descrição---------: Remove caractres especias para que nao gere erro ao gerar o xml.                                      
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: cString = String com os caracteres especiais removidos.
===============================================================================================================================
*/
Static Function RemovCar(cString)

cString:= strtran(cString,'&',"")
cString:= strtran(cString,'<',"")
cString:= strtran(cString,'>',"")
cString:= strtran(cString,'%',"")
cString:= strtran(cString,'~',"")
cString:= strtran(cString,'^',"") 
cString:= strtran(cString,'´',"")
cString:= strtran(cString,'`',"")

Return cString                
