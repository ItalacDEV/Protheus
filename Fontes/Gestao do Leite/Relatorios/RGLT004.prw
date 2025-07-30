/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 28/05/2018 | Alterar o relat�rio e substituir a ferramenta TMSPRINTER para Treport - Chamado 17422
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 30/04/2019 | Revis�o de fontes. Help 28346
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 27/09/2019 | Revis�o de fontes. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.Ch"

#Define TITULO	"Recep��o do Leite de Terceiros - Detalhamento do Frete"
#Define CRLF	Chr(13)+Chr(10)

/*
===============================================================================================================================
Programa--------: RGLT002
Autor-----------: Alexandre Villar  
Data da Criacao-: 13/07/2015
===============================================================================================================================
Descri��o-------: Relat�rio dos registros de recebimentos de leite de terceiros - Detalhamento por produto.
                  Migrado da ferramenta TMSPRINTER para TREPORT por Julio de Paula Paz.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function RGLT004()

If TRepInUse()
	U_RGLT004B()
Else
	U_RGLT004A()
EndIf

Return

/*
===============================================================================================================================
Programa--------: RGLT004B
Autor-----------: Alexandre Villar
Data da Criacao-: 13/07/2015
===============================================================================================================================
Descri��o-------: Relat�rio dos registros de recebimentos de leite de terceiros - Detalhamento por Frete.
                  Migrado da ferramenta TMSPRINTER para TREPORT por Julio de Paula Paz.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function RGLT004B()

Local _oReport := nil
Private _aOrder := {"Data de Entrega"}
Private _oSect1_A := Nil
Private _oSect2_A := Nil

Pergunte("RGLT004",.F.)	          

_oReport := RGLT004D("RGLT004")
_oReport:PrintDialog()
	
Return

/*
===============================================================================================================================
Programa----------: RGLT004D
Autor-------------: Alexandre Villar  
Data da Criacao---: 13/07/2015
===============================================================================================================================
Descri��o---------: Realiza as defini��es do relat�rio. (ReportDef)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RGLT004D(_cNome)

Local _oReport := Nil

_oReport := TReport():New(_cNome,TITULO,_cNome,{|_oReport| RGLT004SEL(_oReport)},"Emiss�o do Relat�rio Recep��o do Leite de Terceiros - Detalhamento por Frete") // "Recep��o do Leite de Terceiros - Detalhamento por Frete"
_oReport:SetLandscape()    
_oReport:SetTotalInLine(.F.)

// "Data de Recep��o + Tipo de Produto 
_oSect1_A := TRSection():New(_oReport, TITULO , {"TRBREL"},_aOrder , .F., .T.)  // "Recep��o do Leite de Terceiros - Detalhamento por Frete"  
TRCell():New(_oSect1_A,"ZLX_DTENTR","TRBREL","Data Recep��o"      ,"@!",13)	   // 01 - Data da Recep��o      - ok
TRCell():New(_oSect1_A,"ZZX_CODPRD","TRBREL","Tipo Produto"       ,"@!",40)     // 02 - Tipo de Produto       - ok
TRCell():New(_oSect1_A,"CHAVEPESQ" ,"TRBREL","Agrupamento"        ,'@!',25)     // 22 - Chave de Pesquisa     - ok    
_oSect1_A:Disable()

// "Detalhes do frete
_oSect2_A := TRSection():New(_oSect1_A, TITULO , {"TRBREL"}, , .F., .T.) // "Recep��o do Leite de Terceiros - Detalhamento por Frete"  
TRCell():New(_oSect2_A,"ZLX_CODIGO","TRBREL","C�digo Recep��o"   ,"@!",15)					  // 03 - C�digo da Recep��o                               1
TRCell():New(_oSect2_A,"FORNECE"   ,"TRBREL","Proced�ncia"       ,"@!",11)                     // 04 - Nome do Fornecedor                               2
TRCell():New(_oSect2_A,"ZLX_NRONF" ,"TRBREL","NF"                ,"@!",09)					  // 05 - N�mero da NF                                     3
TRCell():New(_oSect2_A,"TRANSP"    ,"TRBREL","Transportador"     ,"@!",30)					  // 06 - Nome do Transportador                            4
TRCell():New(_oSect2_A,"ZLX_PLACA" ,"TRBREL","Placa"             ,"@!",09)					  // 07 - Placa do ve�culo                                 5
TRCell():New(_oSect2_A,"ZLX_VOLREC","TRBREL","Vol.Receb."        ,'@E 999,999,999,999', 15 )   // 08 - Volume Recebido                                  6
TRCell():New(_oSect2_A,"ZLX_VOLNF" ,"TRBREL","Volume NF"         ,'@E 999,999,999,999',15)	  // 09 - Volume NF                                        7
TRCell():New(_oSect2_A,"ZLX_DIFVOL","TRBREL","Dif.Balan�"        ,'@E 999,999,999,999',15)	  // 10 - Diferen�a de Volume                              8
TRCell():New(_oSect2_A,"ZZV_CAPACI","TRBREL","Capacidade"        ,'@E 999,999,999,999',15)     // 11 - Capacidade do Ve�culo                            9
TRCell():New(_oSect2_A,"DIFVOLCAP" ,"TRBREL","Receb x Cap"       ,'@E 999,999,999,999',15)	  // 12 - Diferen�a de Volume x Capacidade                10
TRCell():New(_oSect2_A,"ZLX_VLRNF" ,"TRBREL","Valor NF"          ,'@E 999,999,999,999.99',18)  // 13 - Valor NF                                        11
TRCell():New(_oSect2_A,"ZLX_ICMSNF","TRBREL","ICMS NF"           ,'@E 999,999,999,999.99',18)  // 14 - ICMS da NF                                      12
TRCell():New(_oSect2_A,"ZLX_CTE"   ,"TRBREL","N�m. CTE"          ,'@!', 25)					  // 15 - N�mero do CTE                                   13
TRCell():New(_oSect2_A,"ZLX_VLRFRT","TRBREL","Valor do Frete"    ,'@E 999,999,999,999.99',18)  // 16 - Valor do Frete                                  14 
TRCell():New(_oSect2_A,"ZLX_PEDAGI","TRBREL","Ped�gio"           ,'@E 999,999,999,999.99',18)  // 17 - Valor de Ped�gio                                15
TRCell():New(_oSect2_A,"ZLX_ICMSFR","TRBREL","ICMS"              ,'@E 999,999,999,999.99',18)  // 18 - ICMS do Frete                                   16
TRCell():New(_oSect2_A,"ZLX_TVLFRT","TRBREL","Total Prest"       ,'@E 999,999,999,999.99',18 ) // 19 - Total do Frete                                  17
TRCell():New(_oSect2_A,"ZLX_ADCFRT","TRBREL","Acr�sc/Desc"       , '@E 999,999,999,999.99',18) // 20 - Adicional do Frete                              18
TRCell():New(_oSect2_A,"ZLX_STATUS","TRBREL","Classif"           ,'@!',15)		  			  // 21 - Status da Recep��o                              19
TRCell():New(_oSect2_A,"ZLX_OBS"   ,"TRBREL","Observa��es"       ,'@!', 30 )					  // 22 - Observa��o                                      20
TRCell():New(_oSect2_A,"ZLX_TIPOLT","TRBREL","Tipo do Leite"     ,"@!",15)					  // 23 - Procedencia                                     21
TRCell():New(_oSect2_A,"CHAVEPESQ" ,"TRBREL","Agrupamento"       ,'@!',25)                     // Chave de Pesquisa 
_oSect2_A:Disable()
   
_oReport:SetTotalInLine(.F.)
_oSect1_A:SetPageBreak(.T.)	
    
_oSect2_A:SetPageBreak(.F.)	
_oSect2_A:SetTotalText("")

/*
'C�digo Recep��o'   //  1
'Proced�ncia'       //  2 
'N�mero NF '        //  3
'Transportador'     //  4
'Placa'             //  5
'Volume Recebido'   //  6
'Volume NF'         //  7
'Dif. na Balan�a'   //  8
'Capac. do Ve�culo' //  9
'Receb. x Capac.'   // 10
'Valor NF'          // 11
'ICMS NF'           // 12
'N�m. CTE'          // 13
'Valor do Frete'    // 14
'Ped�gio'           // 15
'ICMS'              // 16
'Total Prest.'      // 17
'Acr�sc. Desc.'     // 18
'Classif.'          // 19
'Observa��es'       // 20
*/

Return(_oReport)

/*
===============================================================================================================================
Programa--------: RGLT004SEL
Autor-----------: Alexandre Villar
Data da Criacao-: 13/07/2015
===============================================================================================================================
Descri��o-------: Fun��o para consulta e prepara��o dos dados do relat�rio
===============================================================================================================================
Parametros------: _oReport = Objeto do relat�rio.
===============================================================================================================================
Retorno---------: _aRet - Dados do relat�rio
===============================================================================================================================
*/
Static Function RGLT004SEL(_oReport)

Local _cAlias		:= "TRBZLX" // GetNextAlias()
Local _nTotReg		:= 0
Local _nI			:= 0
Local _nTotValNF
Local _nTotICMNF 
Local _nTotValFret 
Local _nTotPedagio 
Local _nTotICMS    
Local _nTotPrest   
Local _nTotAcres  
Local _nTotPlat 
Local _nTotFil  
Local _nTotTerc 
Local _nTotTot  
Local _nTotVolRec 
Local _nTotVolNF  
Local _nTotDifVol 
//-----------------
Local _nTotGVolRec 
Local _nTotGVolNF  
Local _nTotGDifVol 
//-----------------
Local _nTotGValNF  
Local _nTotGICMNF   
Local _nTotGValFret 
Local _nTotGPedagio 
Local _nTotGICMS    
Local _nTotGPrest   
Local _nTotGAcres   
//-----------------
Local _nTotGPlat   
Local _nTotGFil    
Local _nTotGTerc   
Local _nTotGTot    

Local _aStruct := {}

Private _cChavepesq 
Private _aTotaisPrd := {}

//================================================================================
// Cria as estruturas das tabelas tempor�rias
//================================================================================
Aadd(_aStruct,{"ZLX_DTENTR","D",8,0})   // 01 - Data da Recep��o      
Aadd(_aStruct,{"ZZX_CODPRD","C",40,0})  // 02 - Tipo de Produto      
Aadd(_aStruct,{"CHAVEPESQ" ,"C",25,0})  // 22 - Chave de Pesquisa       
   // "Detalhes da Recep��o 
Aadd(_aStruct,{"ZLX_CODIGO","C",15,0})  // 03 - C�digo da Recep��o                               1
Aadd(_aStruct,{"FORNECE"   ,"C",40,0})  // 04 - Nome do Fornecedor                               2
Aadd(_aStruct,{"ZLX_NRONF" ,"C",09,0})  // 05 - N�mero da NF                                     3
Aadd(_aStruct,{"TRANSP"    ,"C",40,0})  // 06 - Nome do Transportador                            4
Aadd(_aStruct,{"ZLX_PLACA" ,"C",09,0})  // 07 - Placa do ve�culo                                 5
Aadd(_aStruct,{"ZLX_VOLREC","N",18,4})  // 08 - Volume Recebido                                  6
Aadd(_aStruct,{"ZLX_VOLNF" ,"N",18,4})  // 09 - Volume NF                                        7
Aadd(_aStruct,{"ZLX_DIFVOL","N",18,4})  // 10 - Diferen�a de Volume                              8
Aadd(_aStruct,{"ZZV_CAPACI","N",05,0})  // 11 - Capacidade do Ve�culo                            9
Aadd(_aStruct,{"DIFVOLCAP" ,"N",18,4})  // 12 - Diferen�a de Volume x Capacidade                10
Aadd(_aStruct,{"ZLX_VLRNF" ,"N",18,4})  // 13 - Valor NF                                        11
Aadd(_aStruct,{"ZLX_ICMSNF","N",18,4})  // 14 - ICMS da NF                                      12
Aadd(_aStruct,{"ZLX_CTE"   ,"C",44,0})  // 15 - N�mero do CTE                                   13
Aadd(_aStruct,{"ZLX_VLRFRT","N",18,4})  // 16 - Valor do Frete                                  14 
Aadd(_aStruct,{"ZLX_PEDAGI","N",18,4})  // 17 - Valor de Ped�gio                                15
Aadd(_aStruct,{"ZLX_ICMSFR","N",18,4})  // 18 - ICMS do Frete                                   16
Aadd(_aStruct,{"ZLX_TVLFRT","N",18,4})  // 19 - Total do Frete                                  17
Aadd(_aStruct,{"ZLX_ADCFRT","N",18,4})  // 20 - Adicional do Frete                              18
Aadd(_aStruct,{"ZLX_STATUS","C",15,0})  // 21 - Status da Recep��o                              19
Aadd(_aStruct,{"ZLX_OBS"   ,"C",30,0})  // 22 - Observa��o                                      20
Aadd(_aStruct,{"ZLX_TIPOLT","C",15,0})  // 23 - Procedencia                                     21
Aadd(_aStruct,{"POSICTOTAL","C",1,0})

//----------------------------------------------------------------------
// Cria arquivo de dados tempor�rio
//----------------------------------------------------------------------
_oTempTable := FWTemporaryTable():New( "TRBREL", _aStruct )
//------------------
//Cria��o da tabela
//------------------
_oTempTable:AddIndex( "01", {"CHAVEPESQ","POSICTOTAL"} )
_oTempTable:Create()
   
//================================================================================
// Ativa as se��es do relat�rio.
//================================================================================
_oSect1_A:Enable() 
_oSect2_A:Enable() 

//================================================================================
// Efetua a Sele��o de Dados do Relat�rio.
//================================================================================
RGLT004Q(_cAlias)

TCSetField(_cAlias,"ZLX_DTENTR","D",8,0)

(_cAlias)->( DBEval( {|| _nTotReg++ } ) )
(_cAlias)->( DBGoTop() )

//===============================================================
// Totais Gerais
//===============================================================
_nTotGVolRec := 0 // ZLX_VOLREC
_nTotGVolNF  := 0 // ZLX_VOLNF
_nTotGDifVol := 0 // ZLX_DIFVOL
//--------------------------------
_nTotGValNF   := 0  // 1
_nTotGICMNF   := 0  // 2
_nTotGValFret := 0  // 3
_nTotGPedagio := 0  // 4
_nTotGICMS    := 0  // 5
_nTotGPrest   := 0  // 6
_nTotGAcres   := 0  // 7
//--------------------------------
_nTotGPlat   := 0 // ZLX_VOLREC // PLATAFORMAS  If(TRBZLX->ZLX_TIPOLT=="P",TRBZLX->ZLX_VOLREC,0)
_nTotGFil    := 0 // ZLX_VOLREC // FILIAIS      If(TRBZLX->ZLX_TIPOLT=="F",TRBZLX->ZLX_VOLREC,0)
_nTotGTerc   := 0 // ZLX_VOLREC // TERCEIROS    If(TRBZLX->ZLX_TIPOLT=="T",TRBZLX->ZLX_VOLREC,0)
_nTotGTot    := 0 // ZLX_VOLREC // TOTAIS"     

ProcRegua(_nTotReg)
While (_cAlias)->( !Eof() )
   //====================================================================================================
   // Montando chave de quebra de se��o dos dados do relat�rio.
   //====================================================================================================		 
   _cChavepesq := Dtoc(TRBZLX->ZLX_DTENTR)+TRBZLX->ZZX_CODPRD
   _cCondicao := "(_cChavepesq  == Dtoc(TRBZLX->ZLX_DTENTR)+TRBZLX->ZZX_CODPRD)"

   //===============================================================
   // Zera as vari�veis de subtotais.
   //===============================================================
   _nTotPlat := 0
   _nTotFil  := 0
   _nTotTerc := 0
   _nTotTot  := 0

   _nTotVolRec  := 0
   _nTotVolNF   := 0
   _nTotDifVol  := 0
      
   _nTotValNF   := 0
   _nTotICMNF   := 0
   _nTotValFret := 0
   _nTotPedagio := 0
   _nTotICMS    := 0
   _nTotPrest   := 0
   _nTotAcres   := 0
     
   Do While &(_cCondicao)	

      //===============================================================
      // Soma Subtotais
      //===============================================================
      _nTotPlat += If(TRBZLX->ZLX_TIPOLT=="P",TRBZLX->ZLX_VOLREC,0) // PLATAFORMAS
      _nTotFil  += If(TRBZLX->ZLX_TIPOLT=="F",TRBZLX->ZLX_VOLREC,0) // FILIAIS
      _nTotTerc += If(TRBZLX->ZLX_TIPOLT=="T",TRBZLX->ZLX_VOLREC,0) // TERCEIROS
      _nTotTot  += TRBZLX->ZLX_VOLREC // TOTAIS      

      _nTotVolRec += TRBZLX->ZLX_VOLREC
      _nTotVolNF  += TRBZLX->ZLX_VOLNF
      _nTotDifVol += TRBZLX->ZLX_DIFVOL
      
      //------------------------------------------------------------
      _nTotValNF   += TRBZLX->ZLX_VLRNF   // 1
      _nTotICMNF   += TRBZLX->ZLX_ICMSNF  // 2
      _nTotValFret += TRBZLX->ZLX_VLRFRT  // 3
      _nTotPedagio += TRBZLX->ZLX_PEDAGI  // 4
      _nTotICMS    += TRBZLX->ZLX_ICMSFR  // 5
      _nTotPrest   += TRBZLX->ZLX_TVLFRT  // 6
      _nTotAcres   += TRBZLX->ZLX_ADCFRT  // 7

      //===============================================================
      // Soma Totais Gerais
      //===============================================================
      _nTotGVolRec += TRBZLX->ZLX_VOLREC
      _nTotGVolNF  += TRBZLX->ZLX_VOLNF
      _nTotGDifVol += TRBZLX->ZLX_DIFVOL
      _nTotGPlat   += If(TRBZLX->ZLX_TIPOLT=="P",TRBZLX->ZLX_VOLREC,0)  // PLATAFORMAS
      _nTotGFil    += If(TRBZLX->ZLX_TIPOLT=="F",TRBZLX->ZLX_VOLREC,0)  // FILIAIS
      _nTotGTerc   += If(TRBZLX->ZLX_TIPOLT=="T",TRBZLX->ZLX_VOLREC,0)  // TERCEIROS
      _nTotGTot    += TRBZLX->ZLX_VOLREC // TOTAIS     
      
      //---------------------------------------------------------------
      _nTotGValNF   += TRBZLX->ZLX_VLRNF   // 1
      _nTotGICMNF   += TRBZLX->ZLX_ICMSNF  // 2
      _nTotGValFret += TRBZLX->ZLX_VLRFRT  // 3
      _nTotGPedagio += TRBZLX->ZLX_PEDAGI  // 4
      _nTotGICMS    += TRBZLX->ZLX_ICMSFR  // 5
      _nTotGPrest   += TRBZLX->ZLX_TVLFRT  // 6
      _nTotGAcres   += TRBZLX->ZLX_ADCFRT  // 7 
      
      //===============================================================
      // Grava dados na tabela tempor�ria.
      //===============================================================
      TRBREL->(RecLock("TRBREL",.T.))
      TRBREL->ZLX_DTENTR := TRBZLX->ZLX_DTENTR  // 01 - Data da Recep��o
     
      //===============================================================
      // Total Geral por Produtos
      //===============================================================
      _nI := AsCan(_aTotaisPrd, {|x| x[1] == TRBZLX->ZZX_CODPRD})
      
      If _nI == 0
         _cDescPrd := Posicione('SX5',1,xfilial("SX5")+"Z7"+TRBZLX->ZZX_CODPRD,"X5_DESCRI")
         Aadd(_aTotaisPrd, {TRBZLX->ZZX_CODPRD, _cDescPrd, TRBZLX->ZLX_VOLREC})
      Else
         _aTotaisPrd[_nI,3] += TRBZLX->ZLX_VOLREC
      EndIf
      
      
      _cTextoRecep := 'Recep��o de '+ Posicione('SX5',1,xFilial('SX5')+'Z7'+PadR(TRBZLX->ZZX_CODPRD,TamSX3('X5_CHAVE')[01]),'X5_DESCRI')
      
      TRBREL->ZZX_CODPRD := _cTextoRecep                                                                // 02 - Tipo de Produto
      TRBREL->CHAVEPESQ  := Dtoc(TRBZLX->ZLX_DTENTR)+TRBZLX->ZZX_CODPRD                                 // 03 - Agrupamento       // Dtoc(TRBZLX->ZLX_DTENTR)+"-"+TRBZLX->ZZX_CODPRD
      
      TRBREL->ZLX_CODIGO  := TRBZLX->ZLX_CODIGO       // 03 - C�digo da Recep��o    
      TRBREL->FORNECE     := TRBZLX->FORNECE          // 04 - Fornecedor
	  TRBREL->ZLX_NRONF	  := TRBZLX->ZLX_NRONF		  // 05 - N�mero da NF
      TRBREL->TRANSP 	  := TRBZLX->TRANSP		      // 06 - Nome do Transportador
      TRBREL->ZLX_PLACA   := TRBZLX->ZLX_PLACA		  // 07 - Placa do ve�culo
      TRBREL->ZLX_VOLREC  := TRBZLX->ZLX_VOLREC		  // 08 - Volume Recebido
      TRBREL->ZLX_VOLNF	  := TRBZLX->ZLX_VOLNF		  // 09 - Volume NF
      TRBREL->ZLX_DIFVOL  := TRBZLX->ZLX_DIFVOL	      // 10 - Diferen�a de Volume
      TRBREL->ZZV_CAPACI  := Val(TRBZLX->ZZV_CAPACI)  // 11 - Capacidade do Ve�culo
      TRBREL->DIFVOLCAP	  := TRBZLX->ZLX_VOLREC - Val(TRBZLX->ZZV_CAPACI)        // 12 - Diferen�a de Volume x Capacidade  // _cAlias)->ZLX_VOLREC - Val( (_cAlias)->ZZV_CAPACI )
      TRBREL->ZLX_VLRNF	  := TRBZLX->ZLX_VLRNF		  // 13 - Valor NF
	  TRBREL->ZLX_ICMSNF  := TRBZLX->ZLX_ICMSNF		  // 14 - ICMS da NF
      TRBREL->ZLX_CTE 	  := TRBZLX->ZLX_CTE		  // 15 - N�mero do CTE
      TRBREL->ZLX_VLRFRT  := TRBZLX->ZLX_VLRFRT		  // 16 - Valor do Frete
      TRBREL->ZLX_PEDAGI  := TRBZLX->ZLX_PEDAGI		  // 17 - Valor de Ped�gio
      TRBREL->ZLX_ICMSFR  := TRBZLX->ZLX_ICMSFR		  // 18 - ICMS do Frete
      TRBREL->ZLX_TVLFRT  := TRBZLX->ZLX_TVLFRT		  // 19 - Total do Frete
      TRBREL->ZLX_ADCFRT  := TRBZLX->ZLX_ADCFRT		  // 20 - Adicional do Frete
      TRBREL->ZLX_STATUS  := U_ITRetBox(TRBZLX->ZLX_STATUS , 'ZLX_STATUS')         // 21 - Status da Recep��o
	  TRBREL->ZLX_OBS	  := PadR( Posicione('ZLX',1,xFilial('ZLX')+TRBZLX->ZLX_CODIGO,'ZLX_OBS') , 30 )	  // 22 - Observa��o
	  TRBREL->ZLX_TIPOLT  := U_ITRetBox(TRBZLX->ZLX_TIPOLT,'ZLX_TIPOLT')       // 23 - Procedencia
      TRBREL->POSICTOTAL := "0" 
      (_cAlias)->( DBSkip() )
      
   EndDo

   //====================================================================================================
   // Grava subtotais.
   //====================================================================================================	
   TRBREL->(RecLock("TRBREL",.T.))
   TRBREL->CHAVEPESQ  := _cChavepesq  // Agrupamento
   TRBREL->ZLX_CODIGO := "Total:"     // C�digo da Recep��o  
   TRBREL->ZLX_VOLREC := _nTotVolRec
   TRBREL->ZLX_VOLNF  := _nTotVolNF
   TRBREL->ZLX_DIFVOL := _nTotDifVol
//-------------------------------------------------------//   
   TRBREL->ZLX_VLRNF  := _nTotValNF      // 1
   TRBREL->ZLX_ICMSNF := _nTotICMNF      // 2
   TRBREL->ZLX_VLRFRT := _nTotValFret    // 3
   TRBREL->ZLX_PEDAGI := _nTotPedagio    // 4
   TRBREL->ZLX_ICMSFR := _nTotICMS       // 5
   TRBREL->ZLX_TVLFRT := _nTotPrest      // 6
   TRBREL->ZLX_ADCFRT := _nTotAcres      // 7
//-------------------------------------------------------//   
   TRBREL->POSICTOTAL := "1"          // Ordena a posi��o dos totais. Conte�do: 1 = Registro de Sub Totais.
   TRBREL->(MsUnlock())
   //--------------------------------------------------------------------------------------------------------//
   TRBREL->(RecLock("TRBREL",.T.))
   TRBREL->CHAVEPESQ  := _cChavepesq  // Agrupamento
   TRBREL->ZLX_CODIGO := "Plataformas:"     // C�digo da Recep��o  
   TRBREL->ZLX_VOLREC := _nTotPlat
   TRBREL->POSICTOTAL := "2"          // Ordena a posi��o dos totais. Conte�do: 2 = Registro de Sub PLATAFORMAS
   TRBREL->(MsUnlock())
   //--------------------------------------------------------------------------------------------------------//
   TRBREL->(RecLock("TRBREL",.T.))
   TRBREL->CHAVEPESQ  := _cChavepesq  // Agrupamento
   TRBREL->ZLX_CODIGO := "Filiais:"     // C�digo da Recep��o  
   TRBREL->ZLX_VOLREC := _nTotFil
   TRBREL->POSICTOTAL := "3"          // Ordena a posi��o dos totais. Conte�do: 3 = Registro de Sub FILIAIS.
   TRBREL->(MsUnlock())
   //--------------------------------------------------------------------------------------------------------//
   TRBREL->(RecLock("TRBREL",.T.))
   TRBREL->CHAVEPESQ  := _cChavepesq  // Agrupamento
   TRBREL->ZLX_CODIGO := "Terceiros:"     // C�digo da Recep��o  
   TRBREL->ZLX_VOLREC := _nTotTerc
   TRBREL->POSICTOTAL := "4"          // Ordena a posi��o dos totais. Conte�do: 4 = Registro de Sub TERCEIROS.
   TRBREL->(MsUnlock())
   //--------------------------------------------------------------------------------------------------------//
   TRBREL->(RecLock("TRBREL",.T.))
   TRBREL->CHAVEPESQ  := _cChavepesq  // Agrupamento
   TRBREL->ZLX_CODIGO := "Totais:"     // C�digo da Recep��o  
   TRBREL->ZLX_VOLREC := _nTotTot
   TRBREL->POSICTOTAL := "5"          // Ordena a posi��o dos totais. Conte�do: 5 = Registro de Sub TOTAIS.
   TRBREL->(MsUnlock())
EndDo

//====================================================================================================
// Grava Totais Gerais.
//====================================================================================================	
TRBREL->(RecLock("TRBREL",.T.))
TRBREL->CHAVEPESQ  := "ZZZZZZZZZZZZZZZZZZZ"  // Agrupamento  // Conte�do ZZZ... para ficar no final do relat�rio.
TRBREL->ZLX_CODIGO := "Total Geral:"     // C�digo da Recep��o  
TRBREL->ZLX_VOLREC := _nTotGVolRec
TRBREL->ZLX_VOLNF  := _nTotGVolNF
TRBREL->ZLX_DIFVOL := _nTotGDifVol
TRBREL->ZLX_VLRNF  := _nTotGValNF     // 1
TRBREL->ZLX_ICMSNF := _nTotGICMNF     // 2
TRBREL->ZLX_VLRFRT := _nTotGValFret   // 3
TRBREL->ZLX_PEDAGI := _nTotGPedagio   // 4
TRBREL->ZLX_ICMSFR := _nTotGICMS      // 5
TRBREL->ZLX_TVLFRT := _nTotGPrest     // 6
TRBREL->ZLX_ADCFRT := _nTotGAcres     // 7 
TRBREL->POSICTOTAL := "1"          // Ordena a posi��o dos totais. Conte�do: 1 = Registro de Sub Totais.
TRBREL->(MsUnlock())
//--------------------------------------------------------------------------------------------------------//
TRBREL->(RecLock("TRBREL",.T.))
TRBREL->CHAVEPESQ  := "ZZZZZZZZZZZZZZZZZZZ"  // Agrupamento // Conte�do ZZZ... para ficar no final do relat�rio.
TRBREL->ZLX_CODIGO := "Plataformas:"     // C�digo da Recep��o  
TRBREL->ZLX_VOLREC := _nTotGPlat
TRBREL->POSICTOTAL := "2"          // Ordena a posi��o dos totais. Conte�do: 2 = Registro de Sub PLATAFORMAS
TRBREL->(MsUnlock())
//--------------------------------------------------------------------------------------------------------//
TRBREL->(RecLock("TRBREL",.T.))
TRBREL->CHAVEPESQ  :="ZZZZZZZZZZZZZZZZZZZ"  // Agrupamento // Conte�do ZZZ... para ficar no final do relat�rio.
TRBREL->ZLX_CODIGO := "Filiais:"     // C�digo da Recep��o  
TRBREL->ZLX_VOLREC := _nTotGFil
TRBREL->POSICTOTAL := "3"          // Ordena a posi��o dos totais. Conte�do: 3 = Registro de Sub FILIAIS.
TRBREL->(MsUnlock())
//--------------------------------------------------------------------------------------------------------//
TRBREL->(RecLock("TRBREL",.T.))
TRBREL->CHAVEPESQ  := "ZZZZZZZZZZZZZZZZZZZ"  // Agrupamento // Conte�do ZZZ... para ficar no final do relat�rio.
TRBREL->ZLX_CODIGO := "Terceiros:"     // C�digo da Recep��o  
TRBREL->ZLX_VOLREC := _nTotGTerc
TRBREL->POSICTOTAL := "4"          // Ordena a posi��o dos totais. Conte�do: 4 = Registro de Sub TERCEIROS.
TRBREL->(MsUnlock())
//--------------------------------------------------------------------------------------------------------//
TRBREL->(RecLock("TRBREL",.T.))
TRBREL->CHAVEPESQ  := "ZZZZZZZZZZZZZZZZZZZ"  // Agrupamento // Conte�do ZZZ... para ficar no final do relat�rio.
TRBREL->ZLX_CODIGO := "Totais:"     // C�digo da Recep��o  
TRBREL->ZLX_VOLREC := _nTotGTot
TRBREL->POSICTOTAL := "5"          // Ordena a posi��o dos totais. Conte�do: 5 = Registro de Sub TOTAIS.
TRBREL->(MsUnlock())

//=============================================================================================================
// Total Geral por Produtos
//=============================================================================================================
For _nI := 1 To Len(_aTotaisPrd)
    TRBREL->(RecLock("TRBREL",.T.))
    TRBREL->CHAVEPESQ  := "ZZZZZZZZZZZZZZZZZZZ"  // Agrupamento // Conte�do ZZZ... para ficar no final do relat�rio.
    TRBREL->ZLX_CODIGO := "Total Geral Prd:"     // C�digo da Recep��o  
    TRBREL->FORNECE    := _aTotaisPrd[_nI,1]
    TRBREL->TRANSP     := _aTotaisPrd[_nI,2]
    TRBREL->ZLX_VOLREC := _aTotaisPrd[_nI,3]
    TRBREL->POSICTOTAL := "6"          // Ordena a posi��o dos totais. Conte�do: 5 = Registro de Sub TOTAIS.
    TRBREL->(MsUnlock())
Next

//--------------------------------------------------------------------------------------------------------//
TRBREL->(DbGoTop())   

While TRBREL->( !Eof() )
   If _oReport:Cancel()
	 Exit
   EndIf
					
   //====================================================================================================
   // Inicializando a primeira se��o
   //====================================================================================================		 
   _oSect1_A:Init()

   //====================================================================================================
   // Imprimindo primeira se��o "Data de emiss�o"
   //====================================================================================================		 
   _cChavepesq := TRBREL->CHAVEPESQ + "0" 
   _cCondicao := "(_cChavepesq  == TRBREL->CHAVEPESQ+TRBREL->POSICTOTAL)" 

   _oSect1_A:Cell("ZLX_DTENTR"):SetValue(TRBREL->ZLX_DTENTR)  // 01 - Data da Recep��o
   _oSect1_A:Cell("ZZX_CODPRD"):SetValue(TRBREL->ZZX_CODPRD)  // 02 - Tipo de Produto
   _oSect1_A:Cell("CHAVEPESQ"):SetValue(TRBREL->CHAVEPESQ)    // 03 - Agrupamento
   _oSect1_A:Cell("CHAVEPESQ"):Disable()
   _oSect1_A:Printline()
   
   _oSect2_A:init()
     
   Do While &(_cCondicao)
      _oReport:IncMeter()   

      //====================================================================================================
      // Detalhamento do frete
      //====================================================================================================
      _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)	// 03 - C�digo da Recep��o                               1
      _oSect2_A:Cell("FORNECE"):SetValue(TRBREL->FORNECE)       // 04 - Nome do Fornecedor                               2
      _oSect2_A:Cell("ZLX_NRONF"):SetValue(TRBREL->ZLX_NRONF)	// 05 - N�mero da NF                                     3
      _oSect2_A:Cell("TRANSP"):SetValue(TRBREL->TRANSP)		    // 06 - Nome do Transportador                            4
      _oSect2_A:Cell("ZLX_PLACA"):SetValue(TRBREL->ZLX_PLACA)	// 07 - Placa do ve�culo                                 5
      _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC) // 08 - Volume Recebido                                  6
      _oSect2_A:Cell("ZLX_VOLNF"):SetValue(TRBREL->ZLX_VOLNF)	// 09 - Volume NF                                        7
      _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(TRBREL->ZLX_DIFVOL) // 10 - Diferen�a de Volume                              8
      _oSect2_A:Cell("ZZV_CAPACI"):SetValue(TRBREL->ZZV_CAPACI) // 11 - Capacidade do Ve�culo                            9
      _oSect2_A:Cell("DIFVOLCAP"):SetValue(TRBREL->DIFVOLCAP)   // 12 - Diferen�a de Volume x Capacidade                10
      _oSect2_A:Cell("ZLX_VLRNF"):SetValue(TRBREL->ZLX_VLRNF)   // 13 - Valor NF                                        11
      _oSect2_A:Cell("ZLX_ICMSNF"):SetValue(TRBREL->ZLX_ICMSNF) // 14 - ICMS da NF                                      12
      _oSect2_A:Cell("ZLX_CTE"):SetValue(TRBREL->ZLX_CTE)	    // 15 - N�mero do CTE                                   13
      _oSect2_A:Cell("ZLX_VLRFRT"):SetValue(TRBREL->ZLX_VLRFRT) // 16 - Valor do Frete                                  14 
      _oSect2_A:Cell("ZLX_PEDAGI"):SetValue(TRBREL->ZLX_PEDAGI)	// 17 - Valor de Ped�gio                                15
      _oSect2_A:Cell("ZLX_ICMSFR"):SetValue(TRBREL->ZLX_ICMSFR) // 18 - ICMS do Frete                                   16
      _oSect2_A:Cell("ZLX_TVLFRT"):SetValue(TRBREL->ZLX_TVLFRT) // 19 - Total do Frete                                  17
      _oSect2_A:Cell("ZLX_ADCFRT"):SetValue(TRBREL->ZLX_ADCFRT) // 20 - Adicional do Frete                              18
      _oSect2_A:Cell("ZLX_STATUS"):SetValue(TRBREL->ZLX_STATUS) // 21 - Status da Recep��o                              19
      _oSect2_A:Cell("ZLX_OBS"):SetValue(TRBREL->ZLX_OBS)		// 22 - Observa��o                                      20
      _oSect2_A:Cell("ZLX_TIPOLT"):SetValue(TRBREL->ZLX_TIPOLT)	// 23 - Procedencia                                     21
      _oSect2_A:Cell("CHAVEPESQ"):Disable()
      _oSect2_A:Printline()
      
      TRBREL->( DBSkip() )
   EndDo
   
   //====================================================================================================
   // Imprime os subtotais
   //====================================================================================================	
   _oReport:ThinLine()
   _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)	// 03 - C�digo da Recep��o                               1
   _oSect2_A:Cell("FORNECE"):SetValue("")                       // 04 - Nome do Fornecedor                               2
   _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                     // 05 - N�mero da NF                                     3
   _oSect2_A:Cell("TRANSP"):SetValue("")		                // 06 - Nome do Transportador                            4
   _oSect2_A:Cell("ZLX_PLACA"):SetValue("")	                    // 07 - Placa do ve�culo                                 5
   _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)    // 08 - Volume Recebido                                  6
   _oSect2_A:Cell("ZLX_VOLNF"):SetValue(TRBREL->ZLX_VOLNF)	    // 09 - Volume NF                                        7
   _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(TRBREL->ZLX_DIFVOL)    // 10 - Diferen�a de Volume                              8
   _oSect2_A:Cell("ZZV_CAPACI"):SetValue(0)                     // 11 - Capacidade do Ve�culo                            9
   _oSect2_A:Cell("DIFVOLCAP"):SetValue(0)                      // 12 - Diferen�a de Volume x Capacidade                10
   _oSect2_A:Cell("ZLX_VLRNF"):SetValue(TRBREL->ZLX_VLRNF)      // 13 - Valor NF                                        11
   _oSect2_A:Cell("ZLX_ICMSNF"):SetValue(TRBREL->ZLX_ICMSNF)    // 14 - ICMS da NF                                      12
   _oSect2_A:Cell("ZLX_CTE"):SetValue("")	                    // 15 - N�mero do CTE                                   13
   _oSect2_A:Cell("ZLX_VLRFRT"):SetValue(TRBREL->ZLX_VLRFRT)    // 16 - Valor do Frete                                  14 
   _oSect2_A:Cell("ZLX_PEDAGI"):SetValue(TRBREL->ZLX_PEDAGI)	// 17 - Valor de Ped�gio                                15
   _oSect2_A:Cell("ZLX_ICMSFR"):SetValue(TRBREL->ZLX_ICMSFR)    // 18 - ICMS do Frete                                   16
   _oSect2_A:Cell("ZLX_TVLFRT"):SetValue(TRBREL->ZLX_TVLFRT)    // 19 - Total do Frete                                  17
   _oSect2_A:Cell("ZLX_ADCFRT"):SetValue(TRBREL->ZLX_ADCFRT)    // 20 - Adicional do Frete                              18
   _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                    // 21 - Status da Recep��o                              19
   _oSect2_A:Cell("ZLX_OBS"):SetValue("")		                // 22 - Observa��o                                      20
   _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")	                // 23 - Procedencia                                     21
   _oSect2_A:Cell("CHAVEPESQ"):Disable()
   _oSect2_A:Printline()
   
   TRBREL->(DbSkip())
   
   //====================================================================================================
   // Ordena a posi��o dos totais. Conte�do: 2 = Registro de Sub Totais.
   //====================================================================================================
   _oReport:ThinLine()
   _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)	// 03 - C�digo da Recep��o                               1
   _oSect2_A:Cell("FORNECE"):SetValue("")                       // 04 - Nome do Fornecedor                               2
   _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                     // 05 - N�mero da NF                                     3
   _oSect2_A:Cell("TRANSP"):SetValue("")		                // 06 - Nome do Transportador                            4
   _oSect2_A:Cell("ZLX_PLACA"):SetValue("")	                    // 07 - Placa do ve�culo                                 5
   _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)    // 08 - Volume Recebido                                  6
   _oSect2_A:Cell("ZLX_VOLNF"):SetValue(0)	                    // 09 - Volume NF                                        7
   _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(0)                     // 10 - Diferen�a de Volume                              8
   _oSect2_A:Cell("ZZV_CAPACI"):SetValue(0)                     // 11 - Capacidade do Ve�culo                            9
   _oSect2_A:Cell("DIFVOLCAP"):SetValue(0)                      // 12 - Diferen�a de Volume x Capacidade                10
   _oSect2_A:Cell("ZLX_VLRNF"):SetValue(0)                      // 13 - Valor NF                                        11
   _oSect2_A:Cell("ZLX_ICMSNF"):SetValue(0)                     // 14 - ICMS da NF                                      12
   _oSect2_A:Cell("ZLX_CTE"):SetValue("")	                    // 15 - N�mero do CTE                                   13
   _oSect2_A:Cell("ZLX_VLRFRT"):SetValue(0)                     // 16 - Valor do Frete                                  14 
   _oSect2_A:Cell("ZLX_PEDAGI"):SetValue(0)	                    // 17 - Valor de Ped�gio                                15
   _oSect2_A:Cell("ZLX_ICMSFR"):SetValue(0)                     // 18 - ICMS do Frete                                   16
   _oSect2_A:Cell("ZLX_TVLFRT"):SetValue(0)                     // 19 - Total do Frete                                  17
   _oSect2_A:Cell("ZLX_ADCFRT"):SetValue(0)                     // 20 - Adicional do Frete                              18
   _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                    // 21 - Status da Recep��o                              19
   _oSect2_A:Cell("ZLX_OBS"):SetValue("")		                // 22 - Observa��o                                      20
   _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")	                // 23 - Procedencia                                     21
   _oSect2_A:Cell("CHAVEPESQ"):Disable()
   _oSect2_A:Printline()
   
   TRBREL->(DbSkip())
   
   //====================================================================================================
   // Ordena a posi��o dos totais. Conte�do: 3 = Registro de Sub FILIAIS.
   //====================================================================================================
   _oReport:ThinLine()
   _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)	// 03 - C�digo da Recep��o                               1
   _oSect2_A:Cell("FORNECE"):SetValue("")                       // 04 - Nome do Fornecedor                               2
   _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                     // 05 - N�mero da NF                                     3
   _oSect2_A:Cell("TRANSP"):SetValue("")		                // 06 - Nome do Transportador                            4
   _oSect2_A:Cell("ZLX_PLACA"):SetValue("")	                    // 07 - Placa do ve�culo                                 5
   _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)    // 08 - Volume Recebido                                  6
   _oSect2_A:Cell("ZLX_VOLNF"):SetValue(0)	                    // 09 - Volume NF                                        7
   _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(0)                     // 10 - Diferen�a de Volume                              8
   _oSect2_A:Cell("ZZV_CAPACI"):SetValue(0)                     // 11 - Capacidade do Ve�culo                            9
   _oSect2_A:Cell("DIFVOLCAP"):SetValue(0)                      // 12 - Diferen�a de Volume x Capacidade                10
   _oSect2_A:Cell("ZLX_VLRNF"):SetValue(0)                      // 13 - Valor NF                                        11
   _oSect2_A:Cell("ZLX_ICMSNF"):SetValue(0)                     // 14 - ICMS da NF                                      12
   _oSect2_A:Cell("ZLX_CTE"):SetValue("")	                    // 15 - N�mero do CTE                                   13
   _oSect2_A:Cell("ZLX_VLRFRT"):SetValue(0)                     // 16 - Valor do Frete                                  14 
   _oSect2_A:Cell("ZLX_PEDAGI"):SetValue(0)	                    // 17 - Valor de Ped�gio                                15
   _oSect2_A:Cell("ZLX_ICMSFR"):SetValue(0)                     // 18 - ICMS do Frete                                   16
   _oSect2_A:Cell("ZLX_TVLFRT"):SetValue(0)                     // 19 - Total do Frete                                  17
   _oSect2_A:Cell("ZLX_ADCFRT"):SetValue(0)                     // 20 - Adicional do Frete                              18
   _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                    // 21 - Status da Recep��o                              19
   _oSect2_A:Cell("ZLX_OBS"):SetValue("")		                // 22 - Observa��o                                      20
   _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")	                // 23 - Procedencia                                     21
   _oSect2_A:Cell("CHAVEPESQ"):Disable()
   _oSect2_A:Printline()
   
   TRBREL->(DbSkip())
   
   //====================================================================================================
   // Ordena a posi��o dos totais. Conte�do: 4 = Registro de Sub TERCEIROS.
   //====================================================================================================
   _oReport:ThinLine()
   _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)	// 03 - C�digo da Recep��o                               1
   _oSect2_A:Cell("FORNECE"):SetValue("")                       // 04 - Nome do Fornecedor                               2
   _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                     // 05 - N�mero da NF                                     3
   _oSect2_A:Cell("TRANSP"):SetValue("")		                // 06 - Nome do Transportador                            4
   _oSect2_A:Cell("ZLX_PLACA"):SetValue("")	                    // 07 - Placa do ve�culo                                 5
   _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)    // 08 - Volume Recebido                                  6
   _oSect2_A:Cell("ZLX_VOLNF"):SetValue(0)	                    // 09 - Volume NF                                        7
   _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(0)                     // 10 - Diferen�a de Volume                              8
   _oSect2_A:Cell("ZZV_CAPACI"):SetValue(0)                     // 11 - Capacidade do Ve�culo                            9
   _oSect2_A:Cell("DIFVOLCAP"):SetValue(0)                      // 12 - Diferen�a de Volume x Capacidade                10
   _oSect2_A:Cell("ZLX_VLRNF"):SetValue(0)                      // 13 - Valor NF                                        11
   _oSect2_A:Cell("ZLX_ICMSNF"):SetValue(0)                     // 14 - ICMS da NF                                      12
   _oSect2_A:Cell("ZLX_CTE"):SetValue("")	                    // 15 - N�mero do CTE                                   13
   _oSect2_A:Cell("ZLX_VLRFRT"):SetValue(0)                     // 16 - Valor do Frete                                  14 
   _oSect2_A:Cell("ZLX_PEDAGI"):SetValue(0)	                    // 17 - Valor de Ped�gio                                15
   _oSect2_A:Cell("ZLX_ICMSFR"):SetValue(0)                     // 18 - ICMS do Frete                                   16
   _oSect2_A:Cell("ZLX_TVLFRT"):SetValue(0)                     // 19 - Total do Frete                                  17
   _oSect2_A:Cell("ZLX_ADCFRT"):SetValue(0)                     // 20 - Adicional do Frete                              18
   _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                    // 21 - Status da Recep��o                              19
   _oSect2_A:Cell("ZLX_OBS"):SetValue("")		                // 22 - Observa��o                                      20
   _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")	                // 23 - Procedencia                                     21
   _oSect2_A:Cell("CHAVEPESQ"):Disable()
   _oSect2_A:Printline()
   
   TRBREL->(DbSkip())
   //====================================================================================================
   // Ordena a posi��o dos totais. Conte�do: 5 = Registro de Sub TOTAIS.
   //====================================================================================================
   _oReport:ThinLine()
   _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)	// 03 - C�digo da Recep��o                               1
   _oSect2_A:Cell("FORNECE"):SetValue("")                       // 04 - Nome do Fornecedor                               2
   _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                     // 05 - N�mero da NF                                     3
   _oSect2_A:Cell("TRANSP"):SetValue("")		                // 06 - Nome do Transportador                            4
   _oSect2_A:Cell("ZLX_PLACA"):SetValue("")	                    // 07 - Placa do ve�culo                                 5
   _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)    // 08 - Volume Recebido                                  6
   _oSect2_A:Cell("ZLX_VOLNF"):SetValue(0)	                    // 09 - Volume NF                                        7
   _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(0)                     // 10 - Diferen�a de Volume                              8
   _oSect2_A:Cell("ZZV_CAPACI"):SetValue(0)                     // 11 - Capacidade do Ve�culo                            9
   _oSect2_A:Cell("DIFVOLCAP"):SetValue(0)                      // 12 - Diferen�a de Volume x Capacidade                10
   _oSect2_A:Cell("ZLX_VLRNF"):SetValue(0)                      // 13 - Valor NF                                        11
   _oSect2_A:Cell("ZLX_ICMSNF"):SetValue(0)                     // 14 - ICMS da NF                                      12
   _oSect2_A:Cell("ZLX_CTE"):SetValue("")	                    // 15 - N�mero do CTE                                   13
   _oSect2_A:Cell("ZLX_VLRFRT"):SetValue(0)                     // 16 - Valor do Frete                                  14 
   _oSect2_A:Cell("ZLX_PEDAGI"):SetValue(0)	                    // 17 - Valor de Ped�gio                                15
   _oSect2_A:Cell("ZLX_ICMSFR"):SetValue(0)                     // 18 - ICMS do Frete                                   16
   _oSect2_A:Cell("ZLX_TVLFRT"):SetValue(0)                     // 19 - Total do Frete                                  17
   _oSect2_A:Cell("ZLX_ADCFRT"):SetValue(0)                     // 20 - Adicional do Frete                              18
   _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                    // 21 - Status da Recep��o                              19
   _oSect2_A:Cell("ZLX_OBS"):SetValue("")		                // 22 - Observa��o                                      20
   _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")	                // 23 - Procedencia                                     21
   _oSect2_A:Cell("CHAVEPESQ"):Disable()
   _oSect2_A:Printline()
   
   TRBREL->(DbSkip())
   
   //====================================================================================================
   // Se for os registros de totais gerais Incia a impress�o final.
   //====================================================================================================	 	  
   If AllTrim(TRBREL->CHAVEPESQ)  == "ZZZZZZZZZZZZZZZZZZZ"

   		//====================================================================================================
   		// Finaliza segunda se��o.
   		//====================================================================================================	
   		_oSect2_A:Finish()  
 	
   		//====================================================================================================
   		// Imprime totais gerais
   		//====================================================================================================	 	  
   
   		_oSect1_A:Cell("ZLX_DTENTR"):SetValue(TRBREL->ZLX_DTENTR)  // 01 - Data da Recep��o
   		_oSect1_A:Cell("ZZX_CODPRD"):SetValue(TRBREL->ZZX_CODPRD)  // 02 - Tipo de Produto
   		_oSect1_A:Cell("CHAVEPESQ"):SetValue(TRBREL->CHAVEPESQ)    // 03 - Agrupamento
   		_oSect1_A:Cell("CHAVEPESQ"):Disable()
   		_oSect1_A:Cell("ZLX_DTENTR"):Disable()
   		_oSect1_A:Cell("ZZX_CODPRD"):Disable()
   		_oSect1_A:Printline()
   
   		_oSect2_A:init()
 
      //====================================================================================================
      // Ordena a posi��o dos totais. Conte�do: 2 = Registro de Sub Totais.
      //====================================================================================================
      _oReport:ThinLine()
      _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)	   // 03 - C�digo da Recep��o                               1
      _oSect2_A:Cell("FORNECE"):SetValue("")                       // 04 - Nome do Fornecedor                               2
      _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                     // 05 - N�mero da NF                                     3
      _oSect2_A:Cell("TRANSP"):SetValue("")		                   // 06 - Nome do Transportador                            4
      _oSect2_A:Cell("ZLX_PLACA"):SetValue("")	                   // 07 - Placa do ve�culo                                 5
      _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)    // 08 - Volume Recebido                                  6
      _oSect2_A:Cell("ZLX_VOLNF"):SetValue(TRBREL->ZLX_VOLNF)	   // 09 - Volume NF                                        7
      _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(TRBREL->ZLX_DIFVOL)    // 10 - Diferen�a de Volume                              8
      _oSect2_A:Cell("ZZV_CAPACI"):SetValue(0)                     // 11 - Capacidade do Ve�culo                            9
      _oSect2_A:Cell("DIFVOLCAP"):SetValue(0)                      // 12 - Diferen�a de Volume x Capacidade                10
      _oSect2_A:Cell("ZLX_VLRNF"):SetValue(TRBREL->ZLX_VLRNF)      // 13 - Valor NF                                        11
      _oSect2_A:Cell("ZLX_ICMSNF"):SetValue(TRBREL->ZLX_ICMSNF)    // 14 - ICMS da NF                                      12
      _oSect2_A:Cell("ZLX_CTE"):SetValue("")	                   // 15 - N�mero do CTE                                   13
      _oSect2_A:Cell("ZLX_VLRFRT"):SetValue(TRBREL->ZLX_VLRFRT)    // 16 - Valor do Frete                                  14 
      _oSect2_A:Cell("ZLX_PEDAGI"):SetValue(TRBREL->ZLX_PEDAGI)	   // 17 - Valor de Ped�gio                                15
      _oSect2_A:Cell("ZLX_ICMSFR"):SetValue(TRBREL->ZLX_ICMSFR)    // 18 - ICMS do Frete                                   16
      _oSect2_A:Cell("ZLX_TVLFRT"):SetValue(TRBREL->ZLX_TVLFRT)    // 19 - Total do Frete                                  17
      _oSect2_A:Cell("ZLX_ADCFRT"):SetValue(TRBREL->ZLX_ADCFRT)    // 20 - Adicional do Frete                              18
      _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                    // 21 - Status da Recep��o                              19
      _oSect2_A:Cell("ZLX_OBS"):SetValue("")		               // 22 - Observa��o                                      20
      _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")	                   // 23 - Procedencia                                     21
      _oSect2_A:Cell("CHAVEPESQ"):Disable()
      _oSect2_A:Printline()
   
      TRBREL->(DbSkip())
   
      //====================================================================================================
      // Ordena a posi��o dos totais. Conte�do: 1 = Registro de Sub Totais.
      //====================================================================================================
      _oReport:ThinLine()
      _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)	// 03 - C�digo da Recep��o                               1
      _oSect2_A:Cell("FORNECE"):SetValue("")                       // 04 - Nome do Fornecedor                               2
      _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                     // 05 - N�mero da NF                                     3
      _oSect2_A:Cell("TRANSP"):SetValue("")		                // 06 - Nome do Transportador                            4
      _oSect2_A:Cell("ZLX_PLACA"):SetValue("")	                    // 07 - Placa do ve�culo                                 5
      _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)    // 08 - Volume Recebido                                  6
      _oSect2_A:Cell("ZLX_VOLNF"):SetValue(0)	                    // 09 - Volume NF                                        7
      _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(0)                     // 10 - Diferen�a de Volume                              8
      _oSect2_A:Cell("ZZV_CAPACI"):SetValue(0)                     // 11 - Capacidade do Ve�culo                            9
      _oSect2_A:Cell("DIFVOLCAP"):SetValue(0)                      // 12 - Diferen�a de Volume x Capacidade                10
      _oSect2_A:Cell("ZLX_VLRNF"):SetValue(0)                      // 13 - Valor NF                                        11
      _oSect2_A:Cell("ZLX_ICMSNF"):SetValue(0)                     // 14 - ICMS da NF                                      12
      _oSect2_A:Cell("ZLX_CTE"):SetValue("")	                    // 15 - N�mero do CTE                                   13
      _oSect2_A:Cell("ZLX_VLRFRT"):SetValue(0)                     // 16 - Valor do Frete                                  14 
      _oSect2_A:Cell("ZLX_PEDAGI"):SetValue(0)	                    // 17 - Valor de Ped�gio                                15
      _oSect2_A:Cell("ZLX_ICMSFR"):SetValue(0)                     // 18 - ICMS do Frete                                   16
      _oSect2_A:Cell("ZLX_TVLFRT"):SetValue(0)                     // 19 - Total do Frete                                  17
      _oSect2_A:Cell("ZLX_ADCFRT"):SetValue(0)                     // 20 - Adicional do Frete                              18
      _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                    // 21 - Status da Recep��o                              19
      _oSect2_A:Cell("ZLX_OBS"):SetValue("")		                // 22 - Observa��o                                      20
      _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")	                // 23 - Procedencia                                     21
      _oSect2_A:Cell("CHAVEPESQ"):Disable()
      _oSect2_A:Printline()
   
      TRBREL->(DbSkip())

      //====================================================================================================
      // Ordena a posi��o dos totais. Conte�do: 3 = Registro de Sub FILIAIS.
      //====================================================================================================
      _oReport:ThinLine()
      _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)	// 03 - C�digo da Recep��o                               1
      _oSect2_A:Cell("FORNECE"):SetValue("")                       // 04 - Nome do Fornecedor                               2
      _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                     // 05 - N�mero da NF                                     3
      _oSect2_A:Cell("TRANSP"):SetValue("")		                // 06 - Nome do Transportador                            4
      _oSect2_A:Cell("ZLX_PLACA"):SetValue("")	                    // 07 - Placa do ve�culo                                 5
      _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)    // 08 - Volume Recebido                                  6
      _oSect2_A:Cell("ZLX_VOLNF"):SetValue(0)	                    // 09 - Volume NF                                        7
      _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(0)                     // 10 - Diferen�a de Volume                              8
      _oSect2_A:Cell("ZZV_CAPACI"):SetValue(0)                     // 11 - Capacidade do Ve�culo                            9
      _oSect2_A:Cell("DIFVOLCAP"):SetValue(0)                      // 12 - Diferen�a de Volume x Capacidade                10
      _oSect2_A:Cell("ZLX_VLRNF"):SetValue(0)                      // 13 - Valor NF                                        11
      _oSect2_A:Cell("ZLX_ICMSNF"):SetValue(0)                     // 14 - ICMS da NF                                      12
      _oSect2_A:Cell("ZLX_CTE"):SetValue("")	                    // 15 - N�mero do CTE                                   13
      _oSect2_A:Cell("ZLX_VLRFRT"):SetValue(0)                     // 16 - Valor do Frete                                  14 
      _oSect2_A:Cell("ZLX_PEDAGI"):SetValue(0)	                    // 17 - Valor de Ped�gio                                15
      _oSect2_A:Cell("ZLX_ICMSFR"):SetValue(0)                     // 18 - ICMS do Frete                                   16
      _oSect2_A:Cell("ZLX_TVLFRT"):SetValue(0)                     // 19 - Total do Frete                                  17
      _oSect2_A:Cell("ZLX_ADCFRT"):SetValue(0)                     // 20 - Adicional do Frete                              18
      _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                    // 21 - Status da Recep��o                              19
      _oSect2_A:Cell("ZLX_OBS"):SetValue("")		                // 22 - Observa��o                                      20
      _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")	                // 23 - Procedencia                                     21
      _oSect2_A:Cell("CHAVEPESQ"):Disable()
      _oSect2_A:Printline()
   
      TRBREL->(DbSkip())
      
      //====================================================================================================
      // Ordena a posi��o dos totais. Conte�do: 4 = Registro de Sub TERCEIROS.
      //====================================================================================================
      _oReport:ThinLine()
      _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)	// 03 - C�digo da Recep��o                               1
      _oSect2_A:Cell("FORNECE"):SetValue("")                       // 04 - Nome do Fornecedor                               2
      _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                     // 05 - N�mero da NF                                     3
      _oSect2_A:Cell("TRANSP"):SetValue("")		                // 06 - Nome do Transportador                            4
      _oSect2_A:Cell("ZLX_PLACA"):SetValue("")	                    // 07 - Placa do ve�culo                                 5
      _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)    // 08 - Volume Recebido                                  6
      _oSect2_A:Cell("ZLX_VOLNF"):SetValue(0)	                    // 09 - Volume NF                                        7
      _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(0)                     // 10 - Diferen�a de Volume                              8
      _oSect2_A:Cell("ZZV_CAPACI"):SetValue(0)                     // 11 - Capacidade do Ve�culo                            9
      _oSect2_A:Cell("DIFVOLCAP"):SetValue(0)                      // 12 - Diferen�a de Volume x Capacidade                10
      _oSect2_A:Cell("ZLX_VLRNF"):SetValue(0)                      // 13 - Valor NF                                        11
      _oSect2_A:Cell("ZLX_ICMSNF"):SetValue(0)                     // 14 - ICMS da NF                                      12
      _oSect2_A:Cell("ZLX_CTE"):SetValue("")	                    // 15 - N�mero do CTE                                   13
      _oSect2_A:Cell("ZLX_VLRFRT"):SetValue(0)                     // 16 - Valor do Frete                                  14 
      _oSect2_A:Cell("ZLX_PEDAGI"):SetValue(0)	                    // 17 - Valor de Ped�gio                                15
      _oSect2_A:Cell("ZLX_ICMSFR"):SetValue(0)                     // 18 - ICMS do Frete                                   16
      _oSect2_A:Cell("ZLX_TVLFRT"):SetValue(0)                     // 19 - Total do Frete                                  17
      _oSect2_A:Cell("ZLX_ADCFRT"):SetValue(0)                     // 20 - Adicional do Frete                              18
      _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                    // 21 - Status da Recep��o                              19
      _oSect2_A:Cell("ZLX_OBS"):SetValue("")		                // 22 - Observa��o                                      20
      _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")	                // 23 - Procedencia                                     21
      _oSect2_A:Cell("CHAVEPESQ"):Disable()
      _oSect2_A:Printline()
   
      TRBREL->(DbSkip())

      //====================================================================================================
      // Ordena a posi��o dos totais. Conte�do: 5 = Registro de Sub TOTAIS.
      //====================================================================================================
      _oReport:ThinLine()
      _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)	// 03 - C�digo da Recep��o                               1
      _oSect2_A:Cell("FORNECE"):SetValue("")                       // 04 - Nome do Fornecedor                               2
      _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                     // 05 - N�mero da NF                                     3
      _oSect2_A:Cell("TRANSP"):SetValue("")		                // 06 - Nome do Transportador                            4
      _oSect2_A:Cell("ZLX_PLACA"):SetValue("")	                    // 07 - Placa do ve�culo                                 5
      _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)    // 08 - Volume Recebido                                  6
      _oSect2_A:Cell("ZLX_VOLNF"):SetValue(0)	                    // 09 - Volume NF                                        7
      _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(0)                     // 10 - Diferen�a de Volume                              8
      _oSect2_A:Cell("ZZV_CAPACI"):SetValue(0)                     // 11 - Capacidade do Ve�culo                            9
      _oSect2_A:Cell("DIFVOLCAP"):SetValue(0)                      // 12 - Diferen�a de Volume x Capacidade                10
      _oSect2_A:Cell("ZLX_VLRNF"):SetValue(0)                      // 13 - Valor NF                                        11
      _oSect2_A:Cell("ZLX_ICMSNF"):SetValue(0)                     // 14 - ICMS da NF                                      12
      _oSect2_A:Cell("ZLX_CTE"):SetValue("")	                    // 15 - N�mero do CTE                                   13
      _oSect2_A:Cell("ZLX_VLRFRT"):SetValue(0)                     // 16 - Valor do Frete                                  14 
      _oSect2_A:Cell("ZLX_PEDAGI"):SetValue(0)	                    // 17 - Valor de Ped�gio                                15
      _oSect2_A:Cell("ZLX_ICMSFR"):SetValue(0)                     // 18 - ICMS do Frete                                   16
      _oSect2_A:Cell("ZLX_TVLFRT"):SetValue(0)                     // 19 - Total do Frete                                  17
      _oSect2_A:Cell("ZLX_ADCFRT"):SetValue(0)                     // 20 - Adicional do Frete                              18
      _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                    // 21 - Status da Recep��o                              19
      _oSect2_A:Cell("ZLX_OBS"):SetValue("")		                // 22 - Observa��o                                      20
      _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")	                // 23 - Procedencia                                     21
      _oSect2_A:Cell("CHAVEPESQ"):Disable()
      _oSect2_A:Printline()
   
       _oReport:ThinLine()
       
      //=============================================================================
      // Total Geral por Produtos
      //=============================================================================
      For _nI := 1 To Len(_aTotaisPrd)
 
          TRBREL->(DbSkip())
            
           _oSect2_A:Cell("FORNECE"):SetValue("")                       // 04 - Nome do Fornecedor                               2
          _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                     // 05 - N�mero da NF                                     3
           _oSect2_A:Cell("ZLX_PLACA"):SetValue("")	                    // 07 - Placa do ve�culo                                 5
          _oSect2_A:Cell("ZLX_VOLNF"):SetValue(0)	                    // 09 - Volume NF                                        7
          _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(0)                     // 10 - Diferen�a de Volume                              8
          _oSect2_A:Cell("ZZV_CAPACI"):SetValue(0)                     // 11 - Capacidade do Ve�culo                            9
          _oSect2_A:Cell("DIFVOLCAP"):SetValue(0)                      // 12 - Diferen�a de Volume x Capacidade                10
          _oSect2_A:Cell("ZLX_VLRNF"):SetValue(0)                      // 13 - Valor NF                                        11
          _oSect2_A:Cell("ZLX_ICMSNF"):SetValue(0)                     // 14 - ICMS da NF                                      12
          _oSect2_A:Cell("ZLX_CTE"):SetValue("")	                    // 15 - N�mero do CTE                                   13
          _oSect2_A:Cell("ZLX_VLRFRT"):SetValue(0)                     // 16 - Valor do Frete                                  14 
          _oSect2_A:Cell("ZLX_PEDAGI"):SetValue(0)	                    // 17 - Valor de Ped�gio                                15
          _oSect2_A:Cell("ZLX_ICMSFR"):SetValue(0)                     // 18 - ICMS do Frete                                   16
          _oSect2_A:Cell("ZLX_TVLFRT"):SetValue(0)                     // 19 - Total do Frete                                  17
          _oSect2_A:Cell("ZLX_ADCFRT"):SetValue(0)                     // 20 - Adicional do Frete                              18
          _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                    // 21 - Status da Recep��o                              19
          _oSect2_A:Cell("ZLX_OBS"):SetValue("")		                // 22 - Observa��o                                      20
          _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")	                // 23 - Procedencia                                     21

          _oSect2_A:Cell("FORNECE"):SetValue(TRBREL->FORNECE)         // 04 - Nome do Fornecedor     // 2-a
          _oSect2_A:Cell("TRANSP"):SetValue(TRBREL->TRANSP)           // 06 - Nome do Transportador  // 4
          _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)   // 03 - C�digo da Recep��o     // 1
          _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)   // 12 - Volume Recebido        // 10
          _oSect2_A:Cell("CHAVEPESQ"):Disable()
          _oSect2_A:Printline()
  
      Next
    
      Exit 
   EndIf
   
    //====================================================================================================
   // Finaliza segunda se��o.
   //====================================================================================================	
   _oSect2_A:Finish()  
 	
   //====================================================================================================
   // Imprime linha separadora.
   //====================================================================================================	
   _oReport:ThinLine()
 	
   //====================================================================================================
   // Finaliza primeira se��o.
   //====================================================================================================	 	  
   _oSect1_A:Finish()

EndDo

(_cAlias)->( DBCloseArea() )
_oTempTable:Delete()

Return

//============================================================================================================================
//          RELAT�RIO ANTIGO UTILIZANDO A FERRAMENTE TMSPRINTER.                                                             |
//============================================================================================================================

/*
===============================================================================================================================
Programa--------: RGLT004A
Autor-----------: Alexandre Villar
Data da Criacao-: 13/07/2015
===============================================================================================================================
Descri��o-------: Relat�rio dos registros de recebimentos de leite de terceiros - Detalhamento por Frete
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function RGLT004A()

Local _aCabec1		:= { ' C�digo'  , 'Proced�ncia' , 'N�mero' , 'Transportador' , 'Placa' , ' Volume'  , 'Volume' , ' Dif. na' , 'Capac. do' , 'Receb. x' , 'Valor NF' , 'ICMS NF'  , 'N�m. CTE' , 'Valor do' , 'Ped�gio' , 'ICMS' , 'Total'  , 'Acr�sc.' , 'Classif.' , 'Observa��es' }
Local _aCabec2		:= { 'Recep��o' , ''            , '     NF' , ''              , ''      , 'Recebido' , '    NF' , 'Balan�a'  , '  Ve�culo' , ' Capac.'  , ''         , ''         , ''         , '   Frete' , ''        , ''     , 'Prest.' , '  Desc.' , ''         , ''            }
Local _aColCab		:= { 0050       , 0270          , 0550      , 0770            , 1050    , 1200       , 1350     , 1480       , 1615        , 1800       , 1950       , 2100       , 2240       , 2400       , 2550      , 2700   , 2820     , 2930      , 3050       , 3200          }
Local _aColItn		:= { 0050       , 0210          , 0550      , 0705            , 1050    , 1300       , 1450     , 1575       , 1725        , 1900       , 2050       , 2200       , 2370       , 2520       , 2650      , 2770   , 2910     , 3030      , 3050       , 3200          }
Local _aDados		:= {}
Local _cPerg		:= "RGLT004"
Local _nOpca		:= 0
Local _aSays		:= {}
Local _aButtons		:= {}

Private _oReport	:= Nil

SET DATE FORMAT TO "DD/MM/YYYY"

Pergunte( _cPerg , .F. )

aAdd( _aSays , OemToAnsi( "Este programa tem como objetivo gerar o relat�rio de registros da recep��o de leite "	) )
aAdd( _aSays , OemToAnsi( "de terceiros: detalhamento por frete. "													) )

aAdd( _aButtons , { 5 , .T. , {| | Pergunte( _cPerg )			} } )
aAdd( _aButtons , { 1 , .T. , {|o| _nOpca := 1 , o:oWnd:End()	} } )
aAdd( _aButtons , { 2 , .T. , {|o| _nOpca := 0 , o:oWnd:End()	} } )

FormBatch( "RGLT004" , _aSays , _aButtons ,, 155 , 500 )

If _nOpca == 1

	Processa( {|| _aDados := RGLT004ASEL() } , "Aguarde!" , "Selecionando registros das recep��es..." )
	
	If Empty(_aDados)
		MsgInfo("N�o foram encontrados registros para exibir! Verifique os par�metros e tente novamente.","RGLT00401")
	Else
		Processa( {|| RGLT004APRT( _aCabec1 , _aCabec2 , _aColCab , _aColItn , _aDados ) } , 'Aguarde!' , 'Imprimindo registros...' )
	EndIf

Else
	MsgInfo("Opera��o cancelada pelo usu�rio!","RGLT00402")
EndIf

Return

/*
===============================================================================================================================
Programa--------: RGLT004ASEL
Autor-----------: Alexandre Villar
Data da Criacao-: 13/07/2015
===============================================================================================================================
Descri��o-------: Fun��o para consulta e prepara��o dos dados do relat�rio
===============================================================================================================================
Uso-------------: Italac
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _aRet - Dados do relat�rio
===============================================================================================================================
*/
Static Function RGLT004ASEL()

Local _aRet			:= {}
Local _cAlias		:= GetNextAlias()
Local _nTotReg		:= 0
Local _nRegAtu		:= 0

//================================================================================
// Efetua a Sele��o de Dados do Relat�rio.
//================================================================================
RGLT004Q(_cAlias)

(_cAlias)->( DBEval( {|| _nTotReg++ } ) )
(_cAlias)->( DBGoTop() )

ProcRegua(_nTotReg)
While (_cAlias)->( !Eof() )
	
	_nRegAtu++
	IncProc( "Lendo registros: ["+ StrZero( _nRegAtu , 6 ) +"] de ["+ StrZero( _nTotReg , 6 ) +"]" )
	
	aAdd( _aRet , {				(_cAlias)->ZLX_DTENTR																	,; //01 - Data da Recep��o
								(_cAlias)->ZZX_CODPRD																	,; //02 - Codigo de Produto
								(_cAlias)->ZLX_CODIGO																	,; //03 - C�digo da Recep��o
					AllTrim(	(_cAlias)->FORNECE )																	,; //04 - Nome do Fornecedor
								(_cAlias)->ZLX_NRONF																	,; //05 - N�mero da NF
					AllTrim(	(_cAlias)->TRANSP )																		,; //06 - Nome do Transportador
					AllTrim(	(_cAlias)->ZLX_PLACA )																	,; //07 - Placa do ve�culo
			AllTrim( Transform(	(_cAlias)->ZLX_VOLREC									, '@E 999,999,999,999'      ) )	,; //08 - Volume Recebido
			AllTrim( Transform(	(_cAlias)->ZLX_VOLNF									, '@E 999,999,999,999'      ) )	,; //09 - Volume NF
			AllTrim( Transform(	(_cAlias)->ZLX_DIFVOL									, '@E 999,999,999,999'      ) )	,; //10 - Diferen�a de Volume
			AllTrim( Transform(	Val( (_cAlias)->ZZV_CAPACI )	 						, '@E 999,999,999,999'      ) )	,; //11 - Capacidade do Ve�culo
			AllTrim( Transform(	(_cAlias)->ZLX_VOLREC - Val( (_cAlias)->ZZV_CAPACI )	, '@E 999,999,999,999'      ) )	,; //12 - Diferen�a de Volume x Capacidade
			AllTrim( Transform(	(_cAlias)->ZLX_VLRNF									, '@E 999,999,999,999.99'   ) )	,; //13 - Valor NF
			AllTrim( Transform(	(_cAlias)->ZLX_ICMSNF									, '@E 999,999,999,999.99'   ) )	,; //14 - ICMS da NF
					AllTrim(	(_cAlias)->ZLX_CTE )																	,; //15 - N�mero do CTE
			AllTrim( Transform(	(_cAlias)->ZLX_VLRFRT								    , '@E 999,999,999,999.99'   ) )	,; //16 - Valor do Frete
			AllTrim( Transform(	(_cAlias)->ZLX_PEDAGI								    , '@E 999,999,999,999.99'   ) )	,; //17 - Valor de Ped�gio
			AllTrim( Transform(	(_cAlias)->ZLX_ICMSFR						    		, '@E 999,999,999,999.99'   ) )	,; //18 - ICMS do Frete
			AllTrim( Transform(	(_cAlias)->ZLX_TVLFRT									, '@E 999,999,999,999.99'   ) ) ,; //19 - Total do Frete
			AllTrim( Transform(	(_cAlias)->ZLX_ADCFRT								    , '@E 999,999,999,999.99'   ) )	,; //20 - Adicional do Frete
					U_ITRetBox(	(_cAlias)->ZLX_STATUS , 'ZLX_STATUS' )		  											,; //21 - Status da Recep��o
		PadR( Posicione('ZLX',1,xFilial('ZLX')+(_cAlias)->ZLX_CODIGO,'ZLX_OBS') , 30 )									,; //22 - Observa��o
					AllTrim(	(_cAlias)->ZLX_TIPOLT )																	}) //23 - Procedencia

(_cAlias)->( DBSkip() )
EndDo

(_cAlias)->( DBCloseArea() )

Return( _aRet )

/*
===============================================================================================================================
Programa--------: RGLT004APRT
Autor-----------: Alexandre Villar
Data da Criacao-: 13/07/2015
===============================================================================================================================
Descri��o-------: Fun��o para controlar e imprimir os dados do relat�rio
===============================================================================================================================
Parametros------: _aCabec1 - Primeira linha dos dados de cabe�alho
----------------: _aCabec2 - Segunda linha dos dados de cabe�alho
----------------: _aColCab - Posicionamento dos dados de cabe�alho
----------------: _aColItn - Ajuste do posicionamento dos dados
----------------: _aDados  - Dados do relat�rio
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function RGLT004APRT( _aCabec1 , _aCabec2 , _aColCab , _aColItn , _aDados )

Local _aResFim	:= {}
Local _nLinha	:= 300
Local _nTotCol	:= Len(_aCabec1)
Local _nI		:= 0
Local _nX		:= 0
Local _nConTot	:= 0
Local _oPrint	:= Nil
Local _cDtMov	:= ''
Local _cTipPrd	:= ''
Local _nTotFil	:= 0
Local _nTotPlt	:= 0
Local _nTotTer	:= 0
Local _nTotGer	:= 0
Local _nTotNF	:= 0
Local _nTotDif	:= 0
Local _nTotFrt	:= 0
Local _nTotPed	:= 0
Local _nTotICM	:= 0
Local _nTotPre	:= 0
Local _nTotAcr	:= 0
Local _nTotVNF	:= 0
Local _nTotINF	:= 0

Private _oFont01 := TFont():New( "Tahoma" ,, 14 , .F. , .T. ,, .T. ,, .T. , .F. )
Private _oFont02 := TFont():New( "Tahoma" ,, 08 , .F. , .T. ,, .T. ,, .T. , .F. )
Private _oFont03 := TFont():New( "Tahoma" ,, 08 , .F. , .F. ,, .T. ,, .T. , .F. )

//====================================================================================================
// Inicializa o objeto do relat�rio
//====================================================================================================
_oPrint := TMSPrinter():New( TITULO )
_oPrint:Setup()
_oPrint:SetLandscape()
_oPrint:SetPaperSize(9)

//====================================================================================================
// Processa a impress�o dos dados
//====================================================================================================
For _nI := 1 To Len( _aDados )
	
	//====================================================================================================
	// Inicializa a primeira p�gina do relat�rio
	//====================================================================================================
	IF _nI == 1

		_nLinha		:= 50000
		
		RGLT004AVPG( @_oPrint , @_nLinha , .F. , _aCabec1 , _aCabec2 , _aColCab )
		
		If _cDtMov <> _aDados[_nI][01]
			
			_cDtMov := _aDados[_nI][01]
			
			_nLinha += 030
			_oPrint:Say( _nLinha , _aColItn[01] , 'Movimenta��o do dia: '+ DtoC( StoD( _aDados[_nI][01] ) ) , _oFont02 )
			_nLinha += 035
			
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			
			_nLinha += 010
			
			_cTipPrd := _aDados[_nI][02]
			
			_oPrint:Say( _nLinha , _aColItn[01] , 'Recep��o de '+ Posicione('SX5',1,xFilial('SX5')+'Z7'+PadR(_aDados[_nI][02],TamSX3('X5_CHAVE')[01]),'X5_DESCRI') , _oFont02 )
			_nLinha += 060
			
		EndIf
		
		If _nTotCol > 0
		
			For _nX := 1 To _nTotCol
				_oPrint:Say( IIF( Empty( _aCabec2[_nX] ) , _nLinha + 07 , _nLinha ) , _aColCab[_nX] , _aCabec1[_nX] , _oFont02 )
			Next _nX
			
			_nLinha += 030
			
			For _nX := 1 To _nTotCol
				If !Empty( _aCabec2[_nX] )
					_oPrint:Say( _nLinha , _aColCab[_nX] , _aCabec2[_nX] , _oFont02 )
				EndIf
			Next _nX
			
			_nLinha += 050
			
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			
			_nLinha += 010
			
		EndIf
		
	//=============================================================================
	//| Encerra Lote do Setor atual                                               |
	//=============================================================================	
	ElseIF _nLinha > 2100
		
		_nLinha := 50000
		//=============================================================================
		//| Verifica o posicionamento da p�gina                                       |
		//=============================================================================
		RGLT004AVPG( @_oPrint , @_nLinha , .T. , _aCabec1 , _aCabec2 , _aColCab )
		
		If _cDtMov <> _aDados[_nI][01]
			
			_nLinha += 035
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha += 10
			_oPrint:Say( _nLinha , _aColCab[01] , 'Totais'										, _oFont03 )
			_oPrint:Say( _nLinha , _aColItn[06] , Transform( _nTotGer , '@E 999,999,999'    )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[07] , Transform( _nTotNF  , '@E 999,999,999'    )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[08] , Transform( _nTotDif , '@E 999,999,999'    )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[11] , Transform( _nTotVNF , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[12] , Transform( _nTotINF , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[14] , Transform( _nTotFrt , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[15] , Transform( _nTotPed , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[16] , Transform( _nTotICM , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[17] , Transform( _nTotPre , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[18] , Transform( _nTotAcr , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
			
			_nLinha += 050
			
			_oPrint:Say( _nLinha , _aColItn[01]       , 'Plataformas: '									, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotPlt , '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
			_oPrint:Say( _nLinha , _aColItn[01]       , 'Filiais: '										, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotFil , '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
			_oPrint:Say( _nLinha , _aColItn[01]       , 'Terceiros: '									, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotTer , '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
			_oPrint:Say( _nLinha , _aColItn[01]       , 'Totais: '										, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotGer , '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
			
			aAdd( _aResFim , {	_cTipPrd		,;
								_nTotGer		,;
								_nTotNF			,;
								_nTotDif		,;
								_nTotVNF		,;
								_nTotINF		,;
								_nTotFrt		,;
								_nTotPed		,;
								_nTotICM		,;
								_nTotPre		,;
								_nTotAcr		,;
								_nTotPlt		,;
								_nTotFil		,;
								_nTotTer		})
			
			_nTotPlt := _nTotFil := _nTotTer := _nTotGer := _nTotNF := _nTotDif := _nTotVNF := _nTotINF := _nTotFrt := _nTotPed := _nTotICM := _nTotPre := _nTotAcr := 0
			
			_cDtMov := _aDados[_nI][01]
			
			_nLinha += 030
			_oPrint:Say( _nLinha , _aColItn[01] , 'Movimenta��o do dia: '+ DtoC( StoD( _aDados[_nI][01] ) ) , _oFont02 )
			_nLinha += 035
			
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			
			_nLinha += 010
			
			_cTipPrd := _aDados[_nI][02]
			
			_oPrint:Say( _nLinha , _aColItn[01] , 'Recep��o de '+ Posicione('SX5',1,xFilial('SX5')+'Z7'+PadR(_aDados[_nI][02],TamSX3('X5_CHAVE')[01]),'X5_DESCRI') , _oFont02 )
			_nLinha += 060
			
			If _nTotCol > 0
				
				For _nX := 1 To _nTotCol
					_oPrint:Say( IIF( Empty( _aCabec2[_nX] ) , _nLinha + 07 , _nLinha ) , _aColCab[_nX] , _aCabec1[_nX] , _oFont02 )
				Next _nX
				
				_nLinha += 030
				
				For _nX := 1 To _nTotCol
					If !Empty( _aCabec2[_nX] )
						_oPrint:Say( _nLinha , _aColCab[_nX] , _aCabec2[_nX] , _oFont02 )
					EndIf
				Next _nX
				
				_nLinha += 050
				
				_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
				_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
				
				_nLinha += 010
				
			EndIf
			
		ElseIf _cTipPrd <> _aDados[_nI][02]
			
			_nLinha += 035
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha += 10
			_oPrint:Say( _nLinha , _aColCab[01] , 'Totais'										, _oFont03 )
			_oPrint:Say( _nLinha , _aColItn[06] , Transform( _nTotGer , '@E 999,999,999'    )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[07] , Transform( _nTotNF  , '@E 999,999,999'    )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[08] , Transform( _nTotDif , '@E 999,999,999'    )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[11] , Transform( _nTotVNF , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[12] , Transform( _nTotINF , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[14] , Transform( _nTotFrt , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[15] , Transform( _nTotPed , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[16] , Transform( _nTotICM , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[17] , Transform( _nTotPre , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[18] , Transform( _nTotAcr , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
			
			_nLinha += 050
			
			RGLT004AVPG( @_oPrint , @_nLinha , .T. , _aCabec1 , _aCabec2 , _aColCab )
			
			_oPrint:Say( _nLinha , _aColItn[01]       , 'Plataformas: '									, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotPlt , '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
			_oPrint:Say( _nLinha , _aColItn[01]       , 'Filiais: '										, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotFil , '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
			_oPrint:Say( _nLinha , _aColItn[01]       , 'Terceiros: '									, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotTer , '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
			_oPrint:Say( _nLinha , _aColItn[01]       , 'Totais: '										, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotGer , '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
			
			aAdd( _aResFim , {	_cTipPrd		,;
								_nTotGer		,;
								_nTotNF			,;
								_nTotDif		,;
								_nTotVNF		,;
								_nTotINF		,;
								_nTotFrt		,;
								_nTotPed		,;
								_nTotICM		,;
								_nTotPre		,;
								_nTotAcr		,;
								_nTotPlt		,;
								_nTotFil		,;
								_nTotTer		})
			
			_nTotPlt := _nTotFil := _nTotTer := _nTotGer := _nTotNF := _nTotDif := _nTotVNF := _nTotINF := _nTotFrt := _nTotPed := _nTotICM := _nTotPre := _nTotAcr := 0
			
			_cTipPrd := _aDados[_nI][02]
			
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			
			_nLinha += 020
			_oPrint:Say( _nLinha , _aColItn[01] , 'Recep��o de '+ Posicione('SX5',1,xFilial('SX5')+'Z7'+PadR(_aDados[_nI][02],TamSX3('X5_CHAVE')[01]),'X5_DESCRI') , _oFont02 )
			_nLinha += 050
		
		EndIf
		
		If _nTotCol > 0
			
			For _nX := 1 To _nTotCol
				_oPrint:Say( IIF( Empty( _aCabec2[_nX] ) , _nLinha + 07 , _nLinha ) , _aColCab[_nX] , _aCabec1[_nX] , _oFont02 )
			Next _nX
			
			_nLinha += 030
			
			For _nX := 1 To _nTotCol
				If !Empty( _aCabec2[_nX] )
					_oPrint:Say( _nLinha , _aColCab[_nX] , _aCabec2[_nX] , _oFont02 )
				EndIf
			Next _nX
			
			_nLinha += 050
			
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			
			_nLinha += 010
			
		EndIf
		
	ElseIf _cDtMov <> _aDados[_nI][01]
	
		_nLinha += 035
		_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha += 10
		_oPrint:Say( _nLinha , _aColCab[01] , 'Totais'										, _oFont03 )
		_oPrint:Say( _nLinha , _aColItn[06] , Transform( _nTotGer , '@E 999,999,999'    )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[07] , Transform( _nTotNF  , '@E 999,999,999'    )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[08] , Transform( _nTotDif , '@E 999,999,999'    )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[11] , Transform( _nTotVNF , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[12] , Transform( _nTotINF , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[14] , Transform( _nTotFrt , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[15] , Transform( _nTotPed , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[16] , Transform( _nTotICM , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[17] , Transform( _nTotPre , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[18] , Transform( _nTotAcr , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
		
		_nLinha += 050
		
		RGLT004AVPG( @_oPrint , @_nLinha , .T. , _aCabec1 , _aCabec2 , _aColCab )
		
		_oPrint:Say( _nLinha , _aColItn[01]       , 'Plataformas: '									, _oFont02 )
		_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotPlt , '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
		_oPrint:Say( _nLinha , _aColItn[01]       , 'Filiais: '										, _oFont02 )
		_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotFil , '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
		_oPrint:Say( _nLinha , _aColItn[01]       , 'Terceiros: '									, _oFont02 )
		_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotTer , '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
		_oPrint:Say( _nLinha , _aColItn[01]       , 'Totais: '										, _oFont02 )
		_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotGer , '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
		
		aAdd( _aResFim , {	_cTipPrd		,;
							_nTotGer		,;
							_nTotNF			,;
							_nTotDif		,;
							_nTotVNF		,;
							_nTotINF		,;
							_nTotFrt		,;
							_nTotPed		,;
							_nTotICM		,;
							_nTotPre		,;
							_nTotAcr		,;
							_nTotPlt		,;
							_nTotFil		,;
							_nTotTer		})
		
		_nTotPlt := _nTotFil := _nTotTer := _nTotGer := _nTotNF := _nTotDif := _nTotVNF := _nTotINF := _nTotFrt := _nTotPed := _nTotICM := _nTotPre := _nTotAcr := 0
		
		_cDtMov := _aDados[_nI][01]
		
		_nLinha += 050
		
		RGLT004AVPG( @_oPrint , @_nLinha , .T. , _aCabec1 , _aCabec2 , _aColCab )
		
		_oPrint:Say( _nLinha , _aColItn[01] , 'Movimenta��o do dia: '+ DtoC( StoD( _aDados[_nI][01] ) ) , _oFont02 )
		_nLinha += 035
		
		_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
		_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
		_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
		_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
		
		_nLinha += 010
		
		_cTipPrd := _aDados[_nI][02]
		
		_oPrint:Say( _nLinha , _aColItn[01] , 'Recep��o de '+ Posicione('SX5',1,xFilial('SX5')+'Z7'+PadR(_aDados[_nI][02],TamSX3('X5_CHAVE')[01]),'X5_DESCRI') , _oFont02 )
		_nLinha += 060
		
		RGLT004AVPG( @_oPrint , @_nLinha , .T. , _aCabec1 , _aCabec2 , _aColCab )
		
		If _nTotCol > 0
		
			For _nX := 1 To _nTotCol
				_oPrint:Say( IIF( Empty( _aCabec2[_nX] ) , _nLinha + 07 , _nLinha ) , _aColCab[_nX] , _aCabec1[_nX] , _oFont02 )
			Next _nX
			
			_nLinha += 030
			
			For _nX := 1 To _nTotCol
				If !Empty( _aCabec2[_nX] )
					_oPrint:Say( _nLinha , _aColCab[_nX] , _aCabec2[_nX] , _oFont02 )
				EndIf
			Next _nX
			
			_nLinha += 050
			
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			
			_nLinha += 010
			
		EndIf
		
	ElseIf _cTipPrd <> _aDados[_nI][02]
		
		_nLinha += 035
		_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha += 10
		_oPrint:Say( _nLinha , _aColCab[01] , 'Totais'										, _oFont03 )
		_oPrint:Say( _nLinha , _aColItn[06] , Transform( _nTotGer , '@E 999,999,999'    )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[07] , Transform( _nTotNF  , '@E 999,999,999'    )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[08] , Transform( _nTotDif , '@E 999,999,999'    )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[11] , Transform( _nTotVNF , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[12] , Transform( _nTotINF , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[14] , Transform( _nTotFrt , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[15] , Transform( _nTotPed , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[16] , Transform( _nTotICM , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[17] , Transform( _nTotPre , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[18] , Transform( _nTotAcr , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
		
		_nLinha += 050
		
		RGLT004AVPG( @_oPrint , @_nLinha , .T. , _aCabec1 , _aCabec2 , _aColCab )
		
		_oPrint:Say( _nLinha , _aColItn[01]       , 'Plataformas: '									, _oFont02 )
		_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotPlt , '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
		_oPrint:Say( _nLinha , _aColItn[01]       , 'Filiais: '										, _oFont02 )
		_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotFil , '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
		_oPrint:Say( _nLinha , _aColItn[01]       , 'Terceiros: '									, _oFont02 )
		_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotTer , '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
		_oPrint:Say( _nLinha , _aColItn[01]       , 'Totais: '										, _oFont02 )
		_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotGer , '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
		
		aAdd( _aResFim , {	_cTipPrd		,;
							_nTotGer		,;
							_nTotNF			,;
							_nTotDif		,;
							_nTotVNF		,;
							_nTotINF		,;
							_nTotFrt		,;
							_nTotPed		,;
							_nTotICM		,;
							_nTotPre		,;
							_nTotAcr		,;
							_nTotPlt		,;
							_nTotFil		,;
							_nTotTer		})
		
		_nTotPlt := _nTotFil := _nTotTer := _nTotGer := _nTotNF := _nTotDif := _nTotVNF := _nTotINF := _nTotFrt := _nTotPed := _nTotICM := _nTotPre := _nTotAcr := 0
		
		_cTipPrd := _aDados[_nI][02]
		
		_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
		_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
		_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
		_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
		
		_nLinha += 020
		_oPrint:Say( _nLinha , _aColItn[01] , 'Recep��o de '+ Posicione('SX5',1,xFilial('SX5')+'Z7'+PadR(_aDados[_nI][02],TamSX3('X5_CHAVE')[01]),'X5_DESCRI') , _oFont02 )
		_nLinha += 050
		
		RGLT004AVPG( @_oPrint , @_nLinha , .T. , _aCabec1 , _aCabec2 , _aColCab )
		
		If _nTotCol > 0
		
			For _nX := 1 To _nTotCol
				_oPrint:Say( IIF( Empty( _aCabec2[_nX] ) , _nLinha + 07 , _nLinha ) , _aColCab[_nX] , _aCabec1[_nX] , _oFont02 )
			Next _nX
			
			_nLinha += 030
			
			For _nX := 1 To _nTotCol
				If !Empty( _aCabec2[_nX] )
					_oPrint:Say( _nLinha , _aColCab[_nX] , _aCabec2[_nX] , _oFont02 )
				EndIf
			Next _nX
			
			_nLinha += 050
			
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			
			_nLinha += 010
			
		EndIf
		
	Else
	
		_nLinha += 030
		
	EndIF
	
	RGLT004AVPG( @_oPrint , @_nLinha , .T. , _aCabec1 , _aCabec2 , _aColCab )
	
	For _nX := 1 To _nTotCol
		_oPrint:Say( _nLinha , _aColItn[_nX] , _aDados[_nI][_nX+2] , _oFont03 ,,,, IIF( StrZero(_nX,2) $ '06;07;08;09;10;11;12;13;14;15;16;17;18' , 1 , 0 ) )
	Next _nX
	
	_nConTot++
	_nTotGer	+= Val( StrTran( StrTran( _aDados[_nI][08] , '.' , '' ) , ',' , '.' ) )
	_nTotNF		+= Val( StrTran( StrTran( _aDados[_nI][09] , '.' , '' ) , ',' , '.' ) )
	_nTotDif	+= Val( StrTran( StrTran( _aDados[_nI][10] , '.' , '' ) , ',' , '.' ) )
	_nTotVNF	+= Val( StrTran( StrTran( _aDados[_nI][13] , '.' , '' ) , ',' , '.' ) )
	_nTotINF	+= Val( StrTran( StrTran( _aDados[_nI][14] , '.' , '' ) , ',' , '.' ) )
	_nTotFrt	+= Val( StrTran( StrTran( _aDados[_nI][16] , '.' , '' ) , ',' , '.' ) )
	_nTotPed	+= Val( StrTran( StrTran( _aDados[_nI][17] , '.' , '' ) , ',' , '.' ) )
	_nTotICM	+= Val( StrTran( StrTran( _aDados[_nI][18] , '.' , '' ) , ',' , '.' ) )
	_nTotPre	+= Val( StrTran( StrTran( _aDados[_nI][19] , '.' , '' ) , ',' , '.' ) )
	_nTotAcr	+= Val( StrTran( StrTran( _aDados[_nI][20] , '.' , '' ) , ',' , '.' ) )
	
	If _aDados[_nI][23] == 'F'
		_nTotFil += Val( StrTran( StrTran( _aDados[_nI][08] , '.' , '' ) , ',' , '.' ) )
	ElseIf _aDados[_nI][23] == 'P'
		_nTotPlt += Val( StrTran( StrTran( _aDados[_nI][08] , '.' , '' ) , ',' , '.' ) )
	ElseIf _aDados[_nI][23] == 'T'
		_nTotTer += Val( StrTran( StrTran( _aDados[_nI][08] , '.' , '' ) , ',' , '.' ) )
	EndIf
	
Next _nI

//=============================================================================
//| Verifica o posicionamento da p�gina                                       |
//=============================================================================
_nLinha += 035
_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha += 10
_oPrint:Say( _nLinha , _aColCab[01] , 'Totais'										, _oFont03 )
_oPrint:Say( _nLinha , _aColItn[06] , Transform( _nTotGer , '@E 999,999,999'    )	, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[07] , Transform( _nTotNF  , '@E 999,999,999'    )	, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[08] , Transform( _nTotDif , '@E 999,999,999'    )	, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[11] , Transform( _nTotVNF , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[12] , Transform( _nTotINF , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[14] , Transform( _nTotFrt , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[15] , Transform( _nTotPed , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[16] , Transform( _nTotICM , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[17] , Transform( _nTotPre , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[18] , Transform( _nTotAcr , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )

_nLinha += 050

RGLT004AVPG( @_oPrint , @_nLinha , .T. , _aCabec1 , _aCabec2 , _aColCab )

_oPrint:Say( _nLinha , _aColItn[01]       , 'Plataformas: '										, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotPlt , '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
_oPrint:Say( _nLinha , _aColItn[01]       , 'Filiais: '											, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotFil , '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
_oPrint:Say( _nLinha , _aColItn[01]       , 'Terceiros: '										, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotTer , '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
_oPrint:Say( _nLinha , _aColItn[01]       , 'Totais: '											, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotGer , '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030

aAdd( _aResFim , {	_cTipPrd		,;
					_nTotGer		,;
					_nTotNF			,;
					_nTotDif		,;
					_nTotVNF		,;
					_nTotINF		,;
					_nTotFrt		,;
					_nTotPed		,;
					_nTotICM		,;
					_nTotPre		,;
					_nTotAcr		,;
					_nTotPlt		,;
					_nTotFil		,;
					_nTotTer		})

_aResFim := aSort( _aResFim ,,, {|x,y| x[1] < y[1] } )

_cTipPrd	:= ''
_nLinha		:= 5000

RGLT004AVPG( @_oPrint , @_nLinha , .T. , {} , _aColCab )

_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ;

_nLinha += 003

_oPrint:Say( _nLinha , _aColItn[01] , 'Resumo geral de todas as recep��es' , _oFont01 )

_nLinha += 055

_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha += 070

For _nI := 1 To Len( _aResFim )
	
	If _cTipPrd <> _aResFim[_nI][01]
	
		If _nI > 1
			
			RGLT004AVPG( @_oPrint , @_nLinha , .T. , {} , _aColCab )
			
			_oPrint:Say( _nLinha , _aColItn[01]        , '> Total da Recep��o de '+ Posicione('SX5',1,xFilial('SX5')+'Z7'+PadR(_cTipPrd,TamSX3('X5_CHAVE')[01]),'X5_DESCRI') , _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 0900 , 'Volume Recebido'	, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 1150 , 'Volume das NF'	, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 1400 , 'Direren�a Bal.'	, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 1650 , 'Valor das NF'		, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 1900 , 'ICMS das NF'		, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 2170 , 'Valor do Frete'	, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 2450 , 'Ped�gio'			, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 2660 , 'ICMS'				, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 2900 , 'Total Prest'		, _oFont02 )
			
			_nLinha += 40
			
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++ 
			
			_oPrint:Say( _nLinha , _aColItn[01] + 1110 , Transform( _nTotGer , '@E 999,999,999' )		, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[01] + 1370 , Transform( _nTotNF  , '@E 999,999,999' )		, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[01] + 1550 , Transform( _nTotDif , '@E 999,999,999' )		, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[01] + 1825 , Transform( _nTotVNF , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[01] + 2070 , Transform( _nTotINF , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[01] + 2350 , Transform( _nTotFrt , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[01] + 2550 , Transform( _nTotPed , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[01] + 2750 , Transform( _nTotICM , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[01] + 3050 , Transform( _nTotPre , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
			
			_nLinha += 010
			
			_oPrint:Line( _nLinha , 0050 , _nLinha + 120 , 0050 )
			_oPrint:Line( _nLinha , 0620 , _nLinha + 120 , 0620 )
			
			_oPrint:Say( _nLinha , _aColItn[01] + 0030 , 'Plataformas: '														, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 0550 , Transform( _nTotPlt						, '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 )
			_oPrint:Line( _nLinha , 0050 , _nLinha , 0620 ) ; _nLinha += 030
			
			_oPrint:Say( _nLinha , _aColItn[01] + 0030 , 'Filiais: '															, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 0550 , Transform( _nTotFil						, '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 )
			_oPrint:Line( _nLinha , 0050 , _nLinha , 0620 ) ; _nLinha += 030
			
			_oPrint:Say( _nLinha , _aColItn[01] + 0030 , 'Terceiros: '															, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 0550 , Transform( _nTotTer						, '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 )
			_oPrint:Line( _nLinha , 0050 , _nLinha , 0620 ) ; _nLinha += 030
			
			_oPrint:Say( _nLinha , _aColItn[01] + 0030 , 'Total: '																, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 0550 , Transform( _nTotPlt + _nTotFil + _nTotTer	, '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 )
			_oPrint:Line( _nLinha , 0050 , _nLinha , 0620 ) ; _nLinha += 030
			_oPrint:Line( _nLinha , 0050 , _nLinha , 0620 ) ; _nLinha += 100
			
		EndIf
		
		_cTipPrd	:= _aResFim[_nI][01]
		_nTotGer	:= 0
		_nTotNF		:= 0
		_nTotDif	:= 0
		_nTotVNF	:= 0
		_nTotINF	:= 0
		_nTotFrt	:= 0
		_nTotPed	:= 0
		_nTotICM	:= 0
		_nTotPre	:= 0
		_nTotAcr	:= 0
		_nTotPlt	:= 0
		_nTotFil	:= 0
		_nTotTer	:= 0
		
	EndIf
	
	_nTotGer	+= _aResFim[_nI][02]
	_nTotNF		+= _aResFim[_nI][03]
	_nTotDif	+= _aResFim[_nI][04]
	_nTotVNF	+= _aResFim[_nI][05]
	_nTotINF	+= _aResFim[_nI][06]
	_nTotFrt	+= _aResFim[_nI][07]
	_nTotPed	+= _aResFim[_nI][08]
	_nTotICM	+= _aResFim[_nI][09]
	_nTotPre	+= _aResFim[_nI][10]
	_nTotAcr	+= _aResFim[_nI][11]
	_nTotPlt	+= _aResFim[_nI][12]
	_nTotFil	+= _aResFim[_nI][13]
	_nTotTer	+= _aResFim[_nI][14]
	
Next _nI

RGLT004AVPG( @_oPrint , @_nLinha , .T. , {} , _aColCab )

_oPrint:Say( _nLinha , _aColItn[01]        , '> Total da Recep��o de '+ Posicione('SX5',1,xFilial('SX5')+'Z7'+PadR(_cTipPrd,TamSX3('X5_CHAVE')[01]),'X5_DESCRI') , _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 0900 , 'Volume Recebido'	, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 1150 , 'Volume das NF'	, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 1400 , 'Direren�a Bal.'	, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 1650 , 'Valor das NF'		, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 1900 , 'ICMS das NF'		, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 2170 , 'Valor do Frete'	, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 2450 , 'Ped�gio'			, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 2660 , 'ICMS'				, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 2900 , 'Total Prest'		, _oFont02 )

_nLinha += 040

_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++ 

_oPrint:Say( _nLinha , _aColItn[01] + 1110 , Transform( _nTotGer , '@E 999,999,999' )		, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[01] + 1370 , Transform( _nTotNF  , '@E 999,999,999' )		, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[01] + 1550 , Transform( _nTotDif , '@E 999,999,999' )		, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[01] + 1825 , Transform( _nTotVNF , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[01] + 2070 , Transform( _nTotINF , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[01] + 2350 , Transform( _nTotFrt , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[01] + 2550 , Transform( _nTotPed , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[01] + 2750 , Transform( _nTotICM , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[01] + 3050 , Transform( _nTotPre , '@E 999,999,999.99' )	, _oFont03 ,,,, 1 )

_nLinha += 010

_oPrint:Line( _nLinha , 0050 , _nLinha + 120 , 0050 )
_oPrint:Line( _nLinha , 0620 , _nLinha + 120 , 0620 )

_oPrint:Say( _nLinha , _aColItn[01] + 0030 , 'Plataformas: '														, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 0550 , Transform( _nTotPlt						, '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 )
_oPrint:Line( _nLinha , 0050 , _nLinha , 0620 ) ; _nLinha += 030

_oPrint:Say( _nLinha , _aColItn[01] + 0030 , 'Filiais: '															, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 0550 , Transform( _nTotFil						, '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 )
_oPrint:Line( _nLinha , 0050 , _nLinha , 0620 ) ; _nLinha += 030

_oPrint:Say( _nLinha , _aColItn[01] + 0030 , 'Terceiros: '															, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 0550 , Transform( _nTotTer						, '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 )
_oPrint:Line( _nLinha , 0050 , _nLinha , 0620 ) ; _nLinha += 030

_oPrint:Say( _nLinha , _aColItn[01] + 0030 , 'Total: '																, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 0550 , Transform( _nTotPlt + _nTotFil + _nTotTer	, '@E 999,999,999' ) +' L'	, _oFont02 ,,,, 1 )
_oPrint:Line( _nLinha , 0050 , _nLinha , 0620 ) ; _nLinha += 030
_oPrint:Line( _nLinha , 0050 , _nLinha , 0620 ) ; _nLinha += 100

//=============================================================================
//| Starta o objeto de impress�o                                              |
//=============================================================================
_oPrint:Preview()

Return

/*
===============================================================================================================================
Programa--------: RGLT004AVPG
Autor-----------: Alexandre Villar
Data da Criacao-: 29/04/2014
===============================================================================================================================
Descri��o-------: Valida��o do pocicionamento da p�gina atual para quebras
===============================================================================================================================
Parametros------: oPrint	- Objeto de Impress�o do Relat�rio
----------------: nLinha	- Vari�vel de controle do posicionamento
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function RGLT004AVPG( _oPrint , _nLinha , _lFinPag , _aCabec1 , _aCabec2 , _aColCab )

Local _nLimPag		:= 2300 //3400

Default _lFinPag	:= .T.

If _nLinha > _nLimPag

	//====================================================================================================
	// Verifica se encerra a p�gina atual
	//====================================================================================================
	If _lFinPag
		_oPrint:EndPage()
	EndIf
	
	//====================================================================================================
	// Inicializa a nova p�gina e o posicionamento
	//====================================================================================================
	_oPrint:StartPage()
	_nLinha	:= 280
	
	//====================================================================================================
	// Insere logo no cabecalho
	//====================================================================================================
	If File( "LGRL01.BMP" )
		_oPrint:SayBitmap( 050 , 020 , "LGRL01.BMP" , 410 , 170 )
	EndIf
	
	//====================================================================================================
	// Imprime quadro do T�tulo
	//====================================================================================================
	_oPrint:Line( 050 , 0400 , 050 , 3350 )
	_oPrint:Line( 240 , 0400 , 240 , 3350 )
	_oPrint:Line( 050 , 0400 , 240 , 0400 )
	_oPrint:Line( 050 , 3350 , 240 , 3350 )
	
	_oPrint:Say( 060 , 420 , TITULO +" ( "+ DtoC(Date()) +" - "+ Time() +")" , _oFont01 )
	_oPrint:Say( 120 , 420 , "Per�odo de Recep��o: "+ DTOC( MV_PAR01 ) +" - "+ DTOC( MV_PAR02 ) +" | Filial: "+ cFilAnt , _oFont02 )
	_oPrint:Say( 150 , 420 ,	"Considera: "+ IIF(MV_PAR03==1,'Leite de Filiais',IIF(MV_PAR03==2,'Leite de Terceiros',IIF(MV_PAR03==3,'Leite de Plataformas','Todas as Proced�ncias'))) , _oFont02 )
	
	//====================================================================================================
	// Adiciona cabecalho de conte�do
	//====================================================================================================
	_nLinha := 255
	
EndIf

Return

/*
===============================================================================================================================
Programa--------: RGLT004Q
Autor-----------: Lucas Borges Ferreira
Data da Criacao-: 25/07/2019
===============================================================================================================================
Descri��o-------: Query para extra��o dos dados
===============================================================================================================================
Parametros------: _cAlias -> Alias para realiza��o da consulta
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function RGLT004Q(_cAlias)

Local _cFiltro := "%"
//================================================================================
// Efetua a Sele��o de Dados do Relat�rio.
//================================================================================
If MV_PAR03 < 4
	_cFiltro += IIf( !Empty( MV_PAR03 ) , " AND ZLX.ZLX_TIPOLT = '"+ IIF( MV_PAR03 == 1 , 'F' , IIF( MV_PAR03 == 2 , 'T' , 'P' ) ) +"' ","")
EndIf

_cFiltro += IIf( !Empty( MV_PAR04 ) , " AND ZZX.ZZX_CODPRD IN "+ FormatIn( ALLTRIM(MV_PAR04) , ';' ),"")
_cFiltro += IIf( !Empty( MV_PAR13 ) , " AND ZLX.ZLX_PLACA  IN "+ FormatIn( MV_PAR13 , ';' ),"")
_cFiltro += IIf( !Empty( MV_PAR14 ) , " AND ZZV.ZZV_FXCAPA IN "+ FormatIn( MV_PAR14 , ';' ),"")
_cFiltro += IIf( !Empty( MV_PAR19 ) , " AND ZLX.ZLX_STATUS IN "+ FormatIn( MV_PAR19 , ';' ),"")
_cFiltro += "%"

BeginSql alias _cAlias
	SELECT DISTINCT ZLX.ZLX_DTENTR, ZZX.ZZX_CODPRD, ZLX.ZLX_CODIGO, A2F.A2_NREDUZ  FORNECE, ZLX.ZLX_NRONF,
	                A2T.A2_NREDUZ TRANSP, ZLX.ZLX_PLACA, ZLX.ZLX_VOLREC, ZLX.ZLX_VOLNF, ZLX.ZLX_DIFVOL,
	                ZZV.ZZV_CAPACI, ZLX.ZLX_VLRNF, ZLX.ZLX_ICMSNF, ZLX.ZLX_CTE, ZLX.ZLX_VLRFRT, ZLX.ZLX_PEDAGI,
	                ZLX.ZLX_ICMSFR, ZLX.ZLX_TVLFRT, ZLX.ZLX_ADCFRT, ZLX.ZLX_STATUS, ZLX.ZLX_TIPOLT
	  FROM %Table:ZLX% ZLX, %Table:SA2% A2T, %Table:SA2% A2F, %Table:ZZX% ZZX, %Table:ZZV% ZZV
	 WHERE ZLX.D_E_L_E_T_ = ' '
	   AND ZZX.D_E_L_E_T_ = ' '
	   AND ZZV.D_E_L_E_T_ = ' '
	   AND A2T.D_E_L_E_T_ = ' '
	   AND A2F.D_E_L_E_T_ = ' '
	   AND ZLX.ZLX_FILIAL = %xFilial:ZLX%
	   AND ZZX.ZZX_FILIAL = %xFilial:ZZX%
	   AND ZZV.ZZV_FILIAL = %xFilial:ZZV%
	   AND A2T.A2_FILIAL = %xFilial:SA2%
	   AND A2F.A2_FILIAL = %xFilial:SA2%
	   AND ZLX.ZLX_FILIAL = ZZX.ZZX_FILIAL
	   AND ZZX.ZZX_FILIAL = ZZV.ZZV_FILIAL
	   AND ZLX.ZLX_FORNEC = A2F.A2_COD
	   AND ZLX.ZLX_LJFORN = A2F.A2_LOJA
	   AND ZLX.ZLX_TRANSP = A2T.A2_COD
	   AND ZLX.ZLX_LJTRAN = A2T.A2_LOJA
	   AND ZZX.ZZX_CODIGO = ZLX.ZLX_CODANA
	   AND ZZX.ZZX_PLACA = ZZV.ZZV_PLACA
	   AND ZZX.ZZX_TRANSP = ZZV.ZZV_TRANSP
	   AND ZZX.ZZX_LJTRAN = ZZV.ZZV_LJTRAN
	   %exp:_cFiltro%
	   AND ZLX.ZLX_DTENTR BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
	   AND ZLX.ZLX_FORNEC BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR07%
	   AND ZLX.ZLX_LJFORN BETWEEN %exp:MV_PAR06% AND %exp:MV_PAR08%
	   AND ZLX.ZLX_TRANSP BETWEEN %exp:MV_PAR09% AND %exp:MV_PAR11%
	   AND ZLX.ZLX_LJTRAN BETWEEN %exp:MV_PAR10% AND %exp:MV_PAR12%
	   AND ZLX.ZLX_NRONF BETWEEN %exp:MV_PAR15% AND %exp:MV_PAR16%
	   AND ZLX.ZLX_CODIGO BETWEEN %exp:MV_PAR17% AND %exp:MV_PAR18%
	 ORDER BY ZLX.ZLX_DTENTR, ZZX.ZZX_CODPRD, ZLX.ZLX_CODIGO
EndSql

Return