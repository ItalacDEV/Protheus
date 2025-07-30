/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor       |    Data  |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges | 27/09/19 | Chamado 28346. Lucas. Revis�o de fontes.
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges | 22/07/22 | Chamado 40778. Lucas. Tratamento para Extrato Seco Total (EST).
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges | 26/07/22 | Chamado 40798. Lucas. Corrigido totalizador.
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 24/04/24 | Chamado 46580. Andre. Corre��o da impress�o do Excel nos tipos 3 e 4.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"
#Include "Fileio.ch"
#Include "report.ch"

#Define TITULO	"Recep��o do Leite de Terceiros - Detalhamento por Produtos"
#Define TITUL2	"Recep��o do Leite 3os"

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
User Function RGLT002()

If TRepInUse()
	U_RGLT002B()
Else
	U_RGLT002A()
EndIf

Return

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
User Function RGLT002B()

Local _oReport := nil
Private _aOrder := {"Data de Entrega"}
Private _oSect1_A := Nil
Private _oSect2_A := Nil

Pergunte("RGLT002",.F.)	          

_oReport := RGLT002D("RGLT002")
_oReport:PrintDialog()
	
Return Nil

/*
===============================================================================================================================
Programa----------: RGLT002D
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
Static Function RGLT002D(_cNome)

Local _oReport := Nil

_oReport := TReport():New(_cNome,TITULO,_cNome,{|_oReport| RGLT002SEL(_oReport)},"Emiss�o do Relat�rio Recep��o do Leite de Terceiros - Detalhamento por Produtos") // "Recep��o do Leite de Terceiros - Detalhamento por Produtos"
_oReport:SetLandscape()    
_oReport:SetTotalInLine(.F.)
   
// "Data de Recep��o + Tipo de Produto 
_oSect1_A := TRSection():New(_oReport, TITUL2 , {"TRBREL"},_aOrder , .F., .T.)  // "Recep��o do Leite de Terceiros - Detalhamento por Produtos"  
   
TRCell():New(_oSect1_A,"ZLX_DTENTR","TRBREL","Data Recep��o"      ,"@!",13)	   // 01 - Data da Recep��o
TRCell():New(_oSect1_A,"ZZX_CODPRD","TRBREL","Tipo Produto"       ,"@!",40)     // 02 - Tipo de Produto
TRCell():New(_oSect1_A,"CHAVEPESQ" ,"TRBREL","Agrupamento"        ,'@!',25)                       // 22 - Chave de Pesquisa      // 2-b
      
// "Detalhes da Recep��o 
_oSect2_A := TRSection():New(_oSect1_A, TITUL2 , {"TRBREL"}, , .F., .T.) // "Recep��o do Leite de Terceiros - Detalhamento por Produtos"  
TRCell():New(_oSect2_A,"ZLX_DTENTR","TRBREL","Data Recep��o"      ,"@!",13)	   // 01 - Data da Recep��o
TRCell():New(_oSect2_A,"ZZX_CODPRD","TRBREL","Tipo Produto"       ,"@!",40)     // 02 - Tipo de Produto

TRCell():New(_oSect2_A,"ZLX_CODIGO","TRBREL","C�digo Recep��o"    ,"@!",20)	                     // 03 - C�digo da Recep��o     // 1
TRCell():New(_oSect2_A,"FORNECE"   ,"TRBREL","Fornecedor"         ,"@!",30)	                     // 04 - Nome do Fornecedor     // 2-a   
TRCell():New(_oSect2_A,"ZLX_NRONF" ,"TRBREL","N�mero NF"          ,"@!",15)                       // 05 - N�mero da NF           // 3 
TRCell():New(_oSect2_A,"TRANSP"    ,"TRBREL","Transportador"      ,"@!",30) 	                     // 06 - Nome do Transportador  // 4
TRCell():New(_oSect2_A,"ZLX_PLACA" ,"TRBREL","Placa"              ,"@!",13)	                     // 07 - Placa do ve�culo       // 5
TRCell():New(_oSect2_A,"ZLX_PESOCA","TRBREL","Peso Cheio"         ,'@E 999,999,999,999' ,15)       // 08 - Peso Carregado         // 6  '@E 999,999,999,999',15
TRCell():New(_oSect2_A,"ZLX_PESOVA","TRBREL","Peso Vazio"         ,'@E 999,999,999,999',15)       // 09 - Peso Vazio             // 7  '@E 999,999,999,999',15
TRCell():New(_oSect2_A,"ZLX_PESOLI","TRBREL","Peso L�quido"       ,'@E 999,999,999,999',15)       // 10 - Peso L�quido           // 8  '@E 999,999,999,999',15
TRCell():New(_oSect2_A,"ZZX_DENSID","TRBREL","Densidade"          ,'@E 999,999,999,999.9999',19)     // 11 - Densidade              // 9  '@E 999,999,999,999.9999')
TRCell():New(_oSect2_A,"ZLX_VOLREC","TRBREL","Volume Recebido"    ,'@E 999,999,999,999',15)       // 12 - Volume Recebido        // 10 '@E 999,999,999,999',15)
TRCell():New(_oSect2_A,"ZLX_VOLNF" ,"TRBREL","Volume NF"          ,'@E 999,999,999,999',15)       // 13 - Volume NF              // 11
TRCell():New(_oSect2_A,"ZLX_DIFVOL","TRBREL","Dif.Balan�a"        ,'@E 999,999,999,999',15)       // 14 - Diferen�a de Volume    // 12
TRCell():New(_oSect2_A,"ZLX_PRCNF" ,"TRBREL","Pre�o Emitido"      ,'@E 999,999,999,999.9999',19)  // 15 - Pre�o NF               // 13
TRCell():New(_oSect2_A,"ZLX_PRCPRE","TRBREL","Pre�o Acertado"     ,'@E 999,999,999,999.9999',19)  // 16 - Pre�o Acertado         // 14
TRCell():New(_oSect2_A,"ZLX_DIFPRC","TRBREL","Dif.Pre�o"          ,'@E 999,999,999,999.9999',19)  // 17 - Diferen�a de Pre�o     // 15 
TRCell():New(_oSect2_A,"GORDURA"   ,"TRBREL","Teor MG"            ,'@E 99.99',5)                   // 18 - Teor de Gordura        // 16 
TRCell():New(_oSect2_A,"EXTRATO"   ,"TRBREL","Teor EST"           ,'@E 99.99',5)                   // 19 - Teor de Extrato Seco    // 16 
TRCell():New(_oSect2_A,"ZLX_STATUS","TRBREL","Classif."           ,'@!',15)                       // 20 - Status da Recep��o     // 17
TRCell():New(_oSect2_A,"ZLX_OBS"   ,"TRBREL","Observa��o"         ,'@!',30)	                     // 21 - Observa��o             // 18
TRCell():New(_oSect2_A,"ZLX_TIPOLT","TRBREL","Procedencia"        ,'@!',15)                       // 22 - Procedencia            // 2-b
TRCell():New(_oSect2_A,"CHAVEPESQ" ,"TRBREL","Dados Agrupamento"  ,'@!',25)                       // 23 - Chave de Pesquisa      // 2-b
   
_oSect2_A:Disable()
   
_oReport:SetTotalInLine(.F.)
_oSect1_A:SetPageBreak(.T.)	
    
_oSect2_A:SetPageBreak(.F.)	
_oSect2_A:SetTotalText("")
   
Return(_oReport)

/*
===============================================================================================================================
Programa--------: RGLT002SEL
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
Static Function RGLT002SEL(_oReport)

Local _cAlias		:= "TRBZLX"// GetNextAlias()
Local _nTotReg		:= 0
Local _cTextoRecep
Local _aStruct := {}
Local _nMedTeorG, _nMedGTeoG, _nQtdItG, _nQtdGItG, _nTotTeorG, _nTotGTeoG
Local _nMedTeorE, _nMedGTeoE, _nQtdItE, _nQtdGItE, _nTotTeorE, _nTotGTeoE
Local _nI
Local _cDescPrd

Private _cChavepesq 
Private _aTotaisPrd := {}

//================================================================================
// Cria as estruturas das tabelas tempor�rias
//================================================================================
Aadd(_aStruct,{"ZLX_DTENTR","D",8,0})   // 01 - Data da Recep��o
Aadd(_aStruct,{"ZZX_CODPRD","C",40,0})  // 02 - Tipo de Produto
Aadd(_aStruct,{"CHAVEPESQ","C",25,0})   // 03 - Agrupamento
Aadd(_aStruct,{"ZLX_CODIGO","C",15,0})  // 03 - C�digo da Recep��o     // 1
Aadd(_aStruct,{"FORNECE","C",30,0})     // 04 - Nome do Fornecedor     // 2-a
Aadd(_aStruct,{"ZLX_NRONF","C",15,0})    // 05 - N�mero da NF           // 3
Aadd(_aStruct,{"TRANSP","C",30,0})      // 06 - Nome do Transportador  // 4
Aadd(_aStruct,{"ZLX_PLACA","C",13,0})   // 07 - Placa do ve�culo       // 5
Aadd(_aStruct,{"ZLX_PESOCA","N",12,0})  // 08 - Peso Carregado         // 6
Aadd(_aStruct,{"ZLX_PESOVA","N",12,0})  // 09 - Peso Vazio             // 7
Aadd(_aStruct,{"ZLX_PESOLI","N",12,0})  // 10 - Peso L�quido           // 8
Aadd(_aStruct,{"ZZX_DENSID","N",16,4})  // 11 - Densidade              // 9
Aadd(_aStruct,{"ZLX_VOLREC","N",12,0})  // 12 - Volume Recebido        // 10
Aadd(_aStruct,{"ZLX_VOLNF","N",12,0})   // 13 - Volume NF              // 11
Aadd(_aStruct,{"ZLX_DIFVOL","N",12,0})  // 14 - Diferen�a de Volume    // 12
Aadd(_aStruct,{"ZLX_PRCNF","N",16,4})   // 15 - Pre�o NF               // 13
Aadd(_aStruct,{"ZLX_PRCPRE","N",16,4})  // 16 - Pre�o Acertado         // 14
Aadd(_aStruct,{"ZLX_DIFPRC","N",16,4})  // 17 - Diferen�a de Pre�o     // 15 
Aadd(_aStruct,{"GORDURA","N",5,2})     // 18 - Teor de Gordura        // 16 
Aadd(_aStruct,{"EXTRATO","N",5,2})     // 19 - Teor de Extrato Seco    // 17
Aadd(_aStruct,{"ZLX_STATUS","C",15,0})  // 20 - Status da Recep��o     // 18
Aadd(_aStruct,{"ZLX_OBS","C",30,0})     // 21 - Observa��o             // 19
Aadd(_aStruct,{"ZLX_TIPOLT","C",15,0})  // Procedencia
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

//=====================================================
_oSect1_A:Enable() 
_oSect2_A:Enable() 

//================================================================================
// Efetua a Sele��o de Dados do Relat�rio.
//================================================================================
RGLT002Q(_cAlias)

TCSetField(_cAlias,"ZLX_DTENTR","D",8,0)

COUNT TO _nTotReg
_oReport:SetMeter(_nTotReg)	
(_cAlias)->( DBGoTop())

//===============================================================
// Totais Gerais
//===============================================================
_nTotGVolRec := 0 // ZLX_VOLREC
_nTotGVolNF  := 0 // ZLX_VOLNF
_nTotGDifVol := 0 // ZLX_DIFVOL
_nTotGPlat   := 0 // ZLX_VOLREC // PLATAFORMAS  If(TRBZLX->ZLX_TIPOLT=="P",TRBZLX->ZLX_VOLREC,0)
_nTotGFil    := 0 // ZLX_VOLREC // FILIAIS      If(TRBZLX->ZLX_TIPOLT=="F",TRBZLX->ZLX_VOLREC,0)
_nTotGTerc   := 0 // ZLX_VOLREC // TERCEIROS    If(TRBZLX->ZLX_TIPOLT=="T",TRBZLX->ZLX_VOLREC,0)
_nTotGTot    := 0 // ZLX_VOLREC // TOTAIS"     
_nMedGTeoG   := 0 // Media Geral Teor de Gordura
_nQtdGItG    := 0 // Quantidade Geral de Itens do teor de gordura.
_nTotGTeoG   := 0 // Total Geral do teor de gordura.
_nMedGTeoE   := 0 // Media Geral Teor de Extrato Seco Total
_nQtdGItE    := 0 // Quantidade Geral de Itens do teor de Extrato Seco Total
_nTotGTeoE   := 0 // Total Geral do teor de Extrato Seco Total

While (_cAlias)->( !Eof() )
   If _oReport:Cancel()
	 Exit
   EndIf
   
   //===============================================================
   // SubTotais 
   //===============================================================
   _nTotPlat := 0 // ZLX_VOLREC // PLATAFORMAS  If(TRBZLX->ZLX_TIPOLT=="P",TRBZLX->ZLX_VOLREC,0)
   _nTotFil  := 0 // ZLX_VOLREC // FILIAIS      If(TRBZLX->ZLX_TIPOLT=="F",TRBZLX->ZLX_VOLREC,0)
   _nTotTerc := 0 // ZLX_VOLREC // TERCEIROS    If(TRBZLX->ZLX_TIPOLT=="T",TRBZLX->ZLX_VOLREC,0)
   _nTotTot  := 0 // ZLX_VOLREC // TOTAIS"      

   _nTotVolRec := 0 //ZLX_VOLREC
   _nTotVolNF  := 0 //ZLX_VOLNF
   _nTotDifVol := 0 //ZLX_DIFVOL
   _nTotTeorG  := 0 // Sub total do teor de gordura. // GORDURA	
   _nQtdItG    := 0 // Quantidade de itens teor de gordura.	
   _nTotTeorE  := 0 // Sub total do teor de gordura. // Extrato Seco Total.
   _nQtdItE    := 0 // Quantidade de itens teor de Extrato Seco Total.
   //====================================================================================================
   // Montando chave de quebra de se��o dos dados do relat�rio.
   //====================================================================================================		 
   _cChavepesq := Dtoc(TRBZLX->ZLX_DTENTR)+TRBZLX->ZZX_CODPRD
   _cCondicao := "(_cChavepesq  == Dtoc(TRBZLX->ZLX_DTENTR)+TRBZLX->ZZX_CODPRD)"
     
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
      
      _nQtdItG   += 1
      _nTotTeorG += TRBZLX->GORDURA
      _nQtdItE   += 1
      _nTotTeorE += TRBZLX->EXTRATO

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
                  
      _nQtdGItG   += 1
      _nTotGTeoG += TRBZLX->GORDURA
      _nQtdGItE   += 1
      _nTotGTeoE += TRBZLX->EXTRATO
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
      TRBREL->ZLX_CODIGO := TRBZLX->ZLX_CODIGO                                                          // 03 - C�digo da Recep��o     // 1
      TRBREL->FORNECE    := TRBZLX->FORNECE                                                             // 04 - Nome do Fornecedor     // 2-a
      TRBREL->ZLX_NRONF  := TRBZLX->ZLX_NRONF                                                           // 05 - N�mero da NF           // 3
      TRBREL->TRANSP     := TRBZLX->TRANSP                                                              // 06 - Nome do Transportador  // 4
      TRBREL->ZLX_PLACA  := TRBZLX->ZLX_PLACA                                                           // 07 - Placa do ve�culo       // 5
      TRBREL->ZLX_PESOCA := TRBZLX->ZLX_PESOCA                                                          // 08 - Peso Carregado         // 6
      TRBREL->ZLX_PESOVA := TRBZLX->ZLX_PESOVA                                                          // 09 - Peso Vazio             // 7
      TRBREL->ZLX_PESOLI := TRBZLX->ZLX_PESOLI                                                          // 10 - Peso L�quido           // 8
      TRBREL->ZZX_DENSID := TRBZLX->ZZX_DENSID                                                          // 11 - Densidade              // 9
      TRBREL->ZLX_VOLREC := TRBZLX->ZLX_VOLREC                                                          // 12 - Volume Recebido        // 10
      TRBREL->ZLX_VOLNF  := TRBZLX->ZLX_VOLNF                                                           // 13 - Volume NF              // 11
      TRBREL->ZLX_DIFVOL := TRBZLX->ZLX_DIFVOL                                                          // 14 - Diferen�a de Volume    // 12
      TRBREL->ZLX_PRCNF  := TRBZLX->ZLX_PRCNF                                                           // 15 - Pre�o NF               // 13
      TRBREL->ZLX_PRCPRE := TRBZLX->ZLX_PRCPRE                                                          // 16 - Pre�o Acertado         // 14
      TRBREL->ZLX_DIFPRC := TRBZLX->ZLX_DIFPRC                                                          // 17 - Diferen�a de Pre�o     // 15 
      TRBREL->GORDURA    := TRBZLX->GORDURA                                                             // 18 - Teor de Gordura        // 16 
      TRBREL->EXTRATO    := TRBZLX->EXTRATO                                                             // 18 - Teor de Extrato Seco Total // 16 
      TRBREL->ZLX_STATUS := U_ITRetBox(TRBZLX->ZLX_STATUS , 'ZLX_STATUS')                                // 19 - Status da Recep��o     // 17
      TRBREL->ZLX_OBS    := PadR( Posicione('ZLX',1,xFilial('ZLX')+TRBZLX->ZLX_CODIGO,'ZLX_OBS') , 30 ) // 20 - Observa��o             // 18
      TRBREL->ZLX_TIPOLT := U_ITRetBox(TRBZLX->ZLX_TIPOLT,'ZLX_TIPOLT')                                 // 21 - Procedencia            // 2-b
      TRBREL->POSICTOTAL := "0"                                                                         // Ordena a posi��o dos totais. Conte�do: 0 = Registro de dados.
      TRBREL->(MsUnLock())
      
      TRBZLX->( DBSkip() )
   EndDo
   
   //====================================================================================================
   // Grava subtotais.
   //====================================================================================================	
   _nMedTeorG := _nTotTeorG / _nQtdItG

   TRBREL->(RecLock("TRBREL",.T.))
   TRBREL->CHAVEPESQ  := _cChavepesq  // Agrupamento
   TRBREL->ZLX_CODIGO := "Total:"     // C�digo da Recep��o  
   TRBREL->ZLX_VOLREC := _nTotVolRec
   TRBREL->ZLX_VOLNF  := _nTotVolNF
   TRBREL->ZLX_DIFVOL := _nTotDifVol
   TRBREL->GORDURA    := _nMedTeorG
   TRBREL->EXTRATO    := _nMedTeorE
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
   //--------------------------------------------------------------------------------------------------------//
   
EndDo

//====================================================================================================
// Grava Totoais Gerais.
//====================================================================================================	
_nMedGTeoG := _nTotGTeoG / _nQtdGItG
_nMedGTeoE := _nTotGTeoE / _nQtdGItE

TRBREL->(RecLock("TRBREL",.T.))
TRBREL->CHAVEPESQ  := "ZZZZZZZZZZZZZZZZZZZ"  // Agrupamento  // Conte�do ZZZ... para ficar no final do relat�rio.
TRBREL->ZLX_CODIGO := "Total Geral:"         // C�digo da Recep��o  
TRBREL->ZLX_VOLREC := _nTotGVolRec
TRBREL->ZLX_VOLNF  := _nTotGVolNF
TRBREL->ZLX_DIFVOL := _nTotGDifVol
TRBREL->GORDURA    := _nMedGTeoG
TRBREL->EXTRATO    := _nMedGTeoE
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

//------------------------------------------------------------------------------------------------------------//

lExcelTP3:=(_oReport:nDevice = 4 .and. _oReport:nexcelprinttype = 3 )
lExcelTP4:=(_oReport:nDevice = 4 .and. _oReport:nexcelprinttype = 4 )

TRBREL->(DbGoTop())   

DO While TRBREL->( !Eof() )
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
   IF lExcelTP4 .OR. lExcelTP3
      _oSect1_A:Cell("ZLX_DTENTR"):Disable()
      _oSect1_A:Cell("ZZX_CODPRD"):Disable()
   ENDIF
   _oSect1_A:Cell("CHAVEPESQ"):Disable()
   _oSect1_A:Printline()
   
   _oSect2_A:init()

   IF !lExcelTP4 .AND. !lExcelTP3
      _oSect2_A:Cell("ZLX_DTENTR"):Disable()
      _oSect2_A:Cell("ZZX_CODPRD"):Disable()
   ENDIF

   Do While &(_cCondicao)
      _oReport:IncMeter()   
      
      //====================================================================================================
      // Data de Recep��o 
      //====================================================================================================
      _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)                                                        // 03 - C�digo da Recep��o     // 1
      _oSect2_A:Cell("FORNECE"):SetValue(TRBREL->FORNECE)                                                              // 04 - Nome do Fornecedor     // 2-a
      _oSect2_A:Cell("ZLX_NRONF"):SetValue(TRBREL->ZLX_NRONF)                                                          // 05 - N�mero da NF           // 3
      _oSect2_A:Cell("TRANSP"):SetValue(TRBREL->TRANSP)                                                                // 06 - Nome do Transportador  // 4
      _oSect2_A:Cell("ZLX_PLACA"):SetValue(TRBREL->ZLX_PLACA)                                                          // 07 - Placa do ve�culo       // 5
      _oSect2_A:Cell("ZLX_PESOCA"):SetValue(TRBREL->ZLX_PESOCA)                                                        // 08 - Peso Carregado         // 6
      _oSect2_A:Cell("ZLX_PESOVA"):SetValue(TRBREL->ZLX_PESOVA)                                                        // 09 - Peso Vazio             // 7
      _oSect2_A:Cell("ZLX_PESOLI"):SetValue(TRBREL->ZLX_PESOLI)                                                        // 10 - Peso L�quido           // 8
      _oSect2_A:Cell("ZZX_DENSID"):SetValue(TRBREL->ZZX_DENSID)                                                        // 11 - Densidade              // 9
      _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)                                                        // 12 - Volume Recebido        // 10
      _oSect2_A:Cell("ZLX_VOLNF"):SetValue(TRBREL->ZLX_VOLNF)                                                          // 13 - Volume NF              // 11
      _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(TRBREL->ZLX_DIFVOL)                                                        // 14 - Diferen�a de Volume    // 12
      _oSect2_A:Cell("ZLX_PRCNF"):SetValue(TRBREL->ZLX_PRCNF)                                                          // 15 - Pre�o NF               // 13
      _oSect2_A:Cell("ZLX_PRCPRE"):SetValue(TRBREL->ZLX_PRCPRE)                                                        // 16 - Pre�o Acertado         // 14
      _oSect2_A:Cell("ZLX_DIFPRC"):SetValue(TRBREL->ZLX_DIFPRC)                                                        // 17 - Diferen�a de Pre�o     // 15 
      _oSect2_A:Cell("GORDURA"):SetValue(TRBREL->GORDURA)                                                              // 18 - Teor de Gordura        // 16 
      _oSect2_A:Cell("EXTRATO"):SetValue(TRBREL->EXTRATO)                                                              // 18 - Teor de Gordura        // 16 
      _oSect2_A:Cell("ZLX_STATUS"):SetValue( U_ITRetBox(TRBREL->ZLX_STATUS , 'ZLX_STATUS' ))                           // 19 - Status da Recep��o     // 17
      _oSect2_A:Cell("ZLX_OBS"):SetValue(PadR( Posicione('ZLX',1,xFilial('ZLX')+TRBREL->ZLX_CODIGO,'ZLX_OBS') , 30 ))  // 20 - Observa��o             // 18
      _oSect2_A:Cell("ZLX_TIPOLT"):SetValue(U_ITRetBox(TRBREL->ZLX_TIPOLT,'ZLX_TIPOLT'))                               // 21 - Procedencia            // 2-b
      IF lExcelTP4
         _oSect2_A:Cell("CHAVEPESQ"):SetValue("")
      ENDIF
      _oSect2_A:Cell("CHAVEPESQ"):Disable()
      _oSect2_A:Printline()
      
      TRBREL->( DBSkip() )
   EndDo
   
   //====================================================================================================
   // Imprime os subtotais
   //====================================================================================================	
   _oReport:ThinLine()
   _oSect2_A:Cell("FORNECE"):SetValue("")                      // 04 - Nome do Fornecedor     // 2-a
   _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                    // 05 - N�mero da NF           // 3
   _oSect2_A:Cell("TRANSP"):SetValue("")                       // 06 - Nome do Transportador  // 4
   _oSect2_A:Cell("ZLX_PLACA"):SetValue("")                    // 07 - Placa do ve�culo       // 5
   _oSect2_A:Cell("ZLX_PESOCA"):SetValue(0)                    // 08 - Peso Carregado         // 6
   _oSect2_A:Cell("ZLX_PESOVA"):SetValue(0)                    // 09 - Peso Vazio             // 7
   _oSect2_A:Cell("ZLX_PESOLI"):SetValue(0)                    // 10 - Peso L�quido           // 8
   _oSect2_A:Cell("ZZX_DENSID"):SetValue(0)                    // 11 - Densidade              // 9
   _oSect2_A:Cell("ZLX_PRCNF"):SetValue(0)                     // 15 - Pre�o NF               // 13
   _oSect2_A:Cell("ZLX_PRCPRE"):SetValue(0)                    // 16 - Pre�o Acertado         // 14
   _oSect2_A:Cell("ZLX_DIFPRC"):SetValue(0)                    // 17 - Diferen�a de Pre�o     // 15 
   _oSect2_A:Cell("GORDURA"):SetValue(TRBREL->GORDURA)         // 18 - Teor de Gordura        // 16 
   _oSect2_A:Cell("EXTRATO"):SetValue(TRBREL->EXTRATO)         // 18 - Teor de Extrato Seco Total // 16 
   _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                   // 19 - Status da Recep��o     // 17
   _oSect2_A:Cell("ZLX_OBS"):SetValue("")                      // 20 - Observa��o             // 18
   _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")                   // 21 - Procedencia            // 2-b
   
   _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)   // 03 - C�digo da Recep��o     // 1
   _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)   // 12 - Volume Recebido        // 10
   _oSect2_A:Cell("ZLX_VOLNF"):SetValue(TRBREL->ZLX_VOLNF)     // 13 - Volume NF              // 11
   _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(TRBREL->ZLX_DIFVOL)   // 14 - Diferen�a de Volume    // 12
   _oSect2_A:Cell("CHAVEPESQ"):Disable()
   _oSect2_A:Printline()
   TRBREL->(DbSkip())
   
   //====================================================================================================
   // Ordena a posi��o dos totais. Conte�do: 1 = Registro de Sub Totais.
   //====================================================================================================
   _oReport:ThinLine()

   _oSect2_A:Cell("FORNECE"):SetValue("")                      // 04 - Nome do Fornecedor     // 2-a
   _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                    // 05 - N�mero da NF           // 3
   _oSect2_A:Cell("TRANSP"):SetValue("")                       // 06 - Nome do Transportador  // 4
   _oSect2_A:Cell("ZLX_PLACA"):SetValue("")                    // 07 - Placa do ve�culo       // 5
   _oSect2_A:Cell("ZLX_PESOCA"):SetValue(0)                    // 08 - Peso Carregado         // 6
   _oSect2_A:Cell("ZLX_PESOVA"):SetValue(0)                    // 09 - Peso Vazio             // 7
   _oSect2_A:Cell("ZLX_PESOLI"):SetValue(0)                    // 10 - Peso L�quido           // 8
   _oSect2_A:Cell("ZZX_DENSID"):SetValue(0)                    // 11 - Densidade              // 9
   _oSect2_A:Cell("ZLX_VOLNF"):SetValue(0)                     // 13 - Volume NF              // 11
   _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(0)                    // 14 - Diferen�a de Volume    // 12
   _oSect2_A:Cell("ZLX_PRCNF"):SetValue(0)                     // 15 - Pre�o NF               // 13
   _oSect2_A:Cell("ZLX_PRCPRE"):SetValue(0)                    // 16 - Pre�o Acertado         // 14
   _oSect2_A:Cell("ZLX_DIFPRC"):SetValue(0)                    // 17 - Diferen�a de Pre�o     // 15 
   _oSect2_A:Cell("GORDURA"):SetValue(0)                       // 18 - Teor de Gordura        // 16 
   _oSect2_A:Cell("EXTRATO"):SetValue(0)                       // 18 - Teor de Extrato Seco Total // 16 
   _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                   // 19 - Status da Recep��o     // 17
   _oSect2_A:Cell("ZLX_OBS"):SetValue("")                      // 20 - Observa��o             // 18
   _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")                   // 21 - Procedencia            // 2-b
   _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)   // 03 - C�digo da Recep��o     // 1
   _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)   // 12 - Volume Recebido        // 10
   _oSect2_A:Cell("CHAVEPESQ"):Disable()
   _oSect2_A:Printline()
   
   TRBREL->(DbSkip())

   //====================================================================================================
   // Ordena a posi��o dos totais. Conte�do: 3 = Registro de Sub FILIAIS.
   //====================================================================================================
   _oSect2_A:Cell("FORNECE"):SetValue("")                      // 04 - Nome do Fornecedor     // 2-a
   _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                    // 05 - N�mero da NF           // 3
   _oSect2_A:Cell("TRANSP"):SetValue("")                       // 06 - Nome do Transportador  // 4
   _oSect2_A:Cell("ZLX_PLACA"):SetValue("")                    // 07 - Placa do ve�culo       // 5
   _oSect2_A:Cell("ZLX_PESOCA"):SetValue(0)                    // 08 - Peso Carregado         // 6
   _oSect2_A:Cell("ZLX_PESOVA"):SetValue(0)                    // 09 - Peso Vazio             // 7
   _oSect2_A:Cell("ZLX_PESOLI"):SetValue(0)                    // 10 - Peso L�quido           // 8
   _oSect2_A:Cell("ZZX_DENSID"):SetValue(0)                    // 11 - Densidade              // 9
   _oSect2_A:Cell("ZLX_VOLNF"):SetValue(0)                     // 13 - Volume NF              // 11
   _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(0)                    // 14 - Diferen�a de Volume    // 12
   _oSect2_A:Cell("ZLX_PRCNF"):SetValue(0)                     // 15 - Pre�o NF               // 13
   _oSect2_A:Cell("ZLX_PRCPRE"):SetValue(0)                    // 16 - Pre�o Acertado         // 14
   _oSect2_A:Cell("ZLX_DIFPRC"):SetValue(0)                    // 17 - Diferen�a de Pre�o     // 15 
   _oSect2_A:Cell("GORDURA"):SetValue(0)                       // 18 - Teor de Gordura        // 16 
   _oSect2_A:Cell("EXTRATO"):SetValue(0)                       // 18 - Teor de Extrato Seco Total // 16 
   _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                   // 19 - Status da Recep��o     // 17
   _oSect2_A:Cell("ZLX_OBS"):SetValue("")                      // 20 - Observa��o             // 18
   _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")                   // 21 - Procedencia            // 2-b
   
   _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)   // 03 - C�digo da Recep��o     // 1
   _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)   // 12 - Volume Recebido        // 10
   _oSect2_A:Cell("CHAVEPESQ"):Disable()
   _oSect2_A:Printline()
   
   TRBREL->(DbSkip())
   
   //====================================================================================================
   // Ordena a posi��o dos totais. Conte�do: 4 = Registro de Sub TERCEIROS.
   //====================================================================================================
   _oSect2_A:Cell("FORNECE"):SetValue("")                      // 04 - Nome do Fornecedor     // 2-a
   _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                    // 05 - N�mero da NF           // 3
   _oSect2_A:Cell("TRANSP"):SetValue("")                       // 06 - Nome do Transportador  // 4
   _oSect2_A:Cell("ZLX_PLACA"):SetValue("")                    // 07 - Placa do ve�culo       // 5
   _oSect2_A:Cell("ZLX_PESOCA"):SetValue(0)                    // 08 - Peso Carregado         // 6
   _oSect2_A:Cell("ZLX_PESOVA"):SetValue(0)                    // 09 - Peso Vazio             // 7
   _oSect2_A:Cell("ZLX_PESOLI"):SetValue(0)                    // 10 - Peso L�quido           // 8
   _oSect2_A:Cell("ZZX_DENSID"):SetValue(0)                    // 11 - Densidade              // 9
   _oSect2_A:Cell("ZLX_VOLNF"):SetValue(0)                     // 13 - Volume NF              // 11
   _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(0)                    // 14 - Diferen�a de Volume    // 12
   _oSect2_A:Cell("ZLX_PRCNF"):SetValue(0)                     // 15 - Pre�o NF               // 13
   _oSect2_A:Cell("ZLX_PRCPRE"):SetValue(0)                    // 16 - Pre�o Acertado         // 14
   _oSect2_A:Cell("ZLX_DIFPRC"):SetValue(0)                    // 17 - Diferen�a de Pre�o     // 15 
   _oSect2_A:Cell("GORDURA"):SetValue(0)                       // 18 - Teor de Gordura        // 16 
   _oSect2_A:Cell("EXTRATO"):SetValue(0)                       // 18 - Teor de Extrato Seco Total // 16 
   _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                   // 19 - Status da Recep��o     // 17
   _oSect2_A:Cell("ZLX_OBS"):SetValue("")                      // 20 - Observa��o             // 18
   _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")                   // 21 - Procedencia            // 2-b
   
   _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)   // 03 - C�digo da Recep��o     // 1
   _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)   // 12 - Volume Recebido        // 10
   _oSect2_A:Cell("CHAVEPESQ"):Disable()
   _oSect2_A:Printline()
   
   TRBREL->(DbSkip())

   //====================================================================================================
   // Ordena a posi��o dos totais. Conte�do: 5 = Registro de Sub TOTAIS.
   //====================================================================================================
   _oSect2_A:Cell("FORNECE"):SetValue("")                      // 04 - Nome do Fornecedor     // 2-a
   _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                    // 05 - N�mero da NF           // 3
   _oSect2_A:Cell("TRANSP"):SetValue("")                       // 06 - Nome do Transportador  // 4
   _oSect2_A:Cell("ZLX_PLACA"):SetValue("")                    // 07 - Placa do ve�culo       // 5
   _oSect2_A:Cell("ZLX_PESOCA"):SetValue(0)                    // 08 - Peso Carregado         // 6
   _oSect2_A:Cell("ZLX_PESOVA"):SetValue(0)                    // 09 - Peso Vazio             // 7
   _oSect2_A:Cell("ZLX_PESOLI"):SetValue(0)                    // 10 - Peso L�quido           // 8
   _oSect2_A:Cell("ZZX_DENSID"):SetValue(0)                    // 11 - Densidade              // 9
   _oSect2_A:Cell("ZLX_VOLNF"):SetValue(0)                     // 13 - Volume NF              // 11
   _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(0)                    // 14 - Diferen�a de Volume    // 12
   _oSect2_A:Cell("ZLX_PRCNF"):SetValue(0)                     // 15 - Pre�o NF               // 13
   _oSect2_A:Cell("ZLX_PRCPRE"):SetValue(0)                    // 16 - Pre�o Acertado         // 14
   _oSect2_A:Cell("ZLX_DIFPRC"):SetValue(0)                    // 17 - Diferen�a de Pre�o     // 15 
   _oSect2_A:Cell("GORDURA"):SetValue(0)                       // 18 - Teor de Gordura        // 16 
   _oSect2_A:Cell("EXTRATO"):SetValue(0)                       // 18 - Teor de Extrato Seco Total  // 16 
   _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                   // 19 - Status da Recep��o     // 17
   _oSect2_A:Cell("ZLX_OBS"):SetValue("")                      // 20 - Observa��o             // 18
   _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")                   // 21 - Procedencia            // 2-b

   _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)   // 03 - C�digo da Recep��o     // 1
   _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)   // 12 - Volume Recebido        // 10
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
   		// Imprime linha separadora.
   		//====================================================================================================	
   		_oReport:ThinLine()
 	
   		//====================================================================================================
   		// Finaliza primeira se��o.
   		//====================================================================================================	 	  
   		_oSect1_A:Finish()
   		
   		//====================================================================================================
   		// Inicializando a primeira se��o
   		//====================================================================================================		 
   		_oSect1_A:Init()

   		//====================================================================================================
   		// Imprimindo primeira se��o "Data de emiss�o"
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
      // Ordena a posi��o dos totais. Conte�do: 1 = Registro de Sub Totais.
      //====================================================================================================
      _oSect2_A:Cell("FORNECE"):SetValue("")                    // 04 - Nome do Fornecedor     // 2-a
      _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                  // 05 - N�mero da NF           // 3
      _oSect2_A:Cell("TRANSP"):SetValue("")                     // 06 - Nome do Transportador  // 4
      _oSect2_A:Cell("ZLX_PLACA"):SetValue("")                  // 07 - Placa do ve�culo       // 5
      _oSect2_A:Cell("ZLX_PESOCA"):SetValue(0)                  // 08 - Peso Carregado         // 6
      _oSect2_A:Cell("ZLX_PESOVA"):SetValue(0)                  // 09 - Peso Vazio             // 7
      _oSect2_A:Cell("ZLX_PESOLI"):SetValue(0)                  // 10 - Peso L�quido           // 8
      _oSect2_A:Cell("ZZX_DENSID"):SetValue(0)                  // 11 - Densidade              // 9
      _oSect2_A:Cell("ZLX_PRCNF"):SetValue(0)                   // 15 - Pre�o NF               // 13
      _oSect2_A:Cell("ZLX_PRCPRE"):SetValue(0)                  // 16 - Pre�o Acertado         // 14
      _oSect2_A:Cell("ZLX_DIFPRC"):SetValue(0)                  // 17 - Diferen�a de Pre�o     // 15 
      _oSect2_A:Cell("GORDURA"):SetValue(TRBREL->GORDURA)       // 18 - Teor de Gordura        // 16 
      _oSect2_A:Cell("EXTRATO"):SetValue(TRBREL->EXTRATO)       // 18 - Teor de Extrato Seco Total  // 16 
      _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                 // 19 - Status da Recep��o     // 17
      _oSect2_A:Cell("ZLX_OBS"):SetValue("")                    // 20 - Observa��o             // 18
      _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")                 // 21 - Procedencia            // 2-b
      _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO) // 03 - C�digo da Recep��o     // 1
      _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC) // 12 - Volume Recebido        // 10
      _oSect2_A:Cell("ZLX_VOLNF"):SetValue(TRBREL->ZLX_VOLNF)   // 13 - Volume NF              // 11
      _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(TRBREL->ZLX_DIFVOL) // 14 - Diferen�a de Volume    // 12
      _oSect2_A:Cell("CHAVEPESQ"):Disable()
      _oSect2_A:Printline()
      TRBREL->(DbSkip())
   
      //====================================================================================================
      // Ordena a posi��o dos totais. Conte�do: 1 = Registro de Sub Totais.
      //====================================================================================================
      _oSect2_A:Cell("FORNECE"):SetValue("")                      // 04 - Nome do Fornecedor     // 2-a
      _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                    // 05 - N�mero da NF           // 3
      _oSect2_A:Cell("TRANSP"):SetValue("")                       // 06 - Nome do Transportador  // 4
      _oSect2_A:Cell("ZLX_PLACA"):SetValue("")                    // 07 - Placa do ve�culo       // 5
      _oSect2_A:Cell("ZLX_PESOCA"):SetValue(0)                    // 08 - Peso Carregado         // 6
      _oSect2_A:Cell("ZLX_PESOVA"):SetValue(0)                    // 09 - Peso Vazio             // 7
      _oSect2_A:Cell("ZLX_PESOLI"):SetValue(0)                    // 10 - Peso L�quido           // 8
      _oSect2_A:Cell("ZZX_DENSID"):SetValue(0)                    // 11 - Densidade              // 9
      _oSect2_A:Cell("ZLX_VOLNF"):SetValue(0)                     // 13 - Volume NF              // 11
      _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(0)                    // 14 - Diferen�a de Volume    // 12
      _oSect2_A:Cell("ZLX_PRCNF"):SetValue(0)                     // 15 - Pre�o NF               // 13
      _oSect2_A:Cell("ZLX_PRCPRE"):SetValue(0)                    // 16 - Pre�o Acertado         // 14
      _oSect2_A:Cell("ZLX_DIFPRC"):SetValue(0)                    // 17 - Diferen�a de Pre�o     // 15 
      _oSect2_A:Cell("GORDURA"):SetValue(0)                       // 18 - Teor de Gordura        // 16 
      _oSect2_A:Cell("EXTRATO"):SetValue(0)                       // 18 - Teor de Extrato Seco Total // 16 
      _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                   // 19 - Status da Recep��o     // 17
      _oSect2_A:Cell("ZLX_OBS"):SetValue("")                      // 20 - Observa��o             // 18
      _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")                   // 21 - Procedencia            // 2-b
      _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)   // 03 - C�digo da Recep��o     // 1
      _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)   // 12 - Volume Recebido        // 10
      _oSect2_A:Cell("CHAVEPESQ"):Disable()
      _oSect2_A:Printline()
   
      TRBREL->(DbSkip())

      //====================================================================================================
      // Ordena a posi��o dos totais. Conte�do: 3 = Registro de Sub FILIAIS.
      //====================================================================================================
      _oSect2_A:Cell("FORNECE"):SetValue("")                      // 04 - Nome do Fornecedor     // 2-a
      _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                    // 05 - N�mero da NF           // 3
      _oSect2_A:Cell("TRANSP"):SetValue("")                       // 06 - Nome do Transportador  // 4
      _oSect2_A:Cell("ZLX_PLACA"):SetValue("")                    // 07 - Placa do ve�culo       // 5
      _oSect2_A:Cell("ZLX_PESOCA"):SetValue(0)                    // 08 - Peso Carregado         // 6
      _oSect2_A:Cell("ZLX_PESOVA"):SetValue(0)                    // 09 - Peso Vazio             // 7
      _oSect2_A:Cell("ZLX_PESOLI"):SetValue(0)                    // 10 - Peso L�quido           // 8
      _oSect2_A:Cell("ZZX_DENSID"):SetValue(0)                    // 11 - Densidade              // 9
      _oSect2_A:Cell("ZLX_VOLNF"):SetValue(0)                     // 13 - Volume NF              // 11
      _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(0)                    // 14 - Diferen�a de Volume    // 12
      _oSect2_A:Cell("ZLX_PRCNF"):SetValue(0)                     // 15 - Pre�o NF               // 13
      _oSect2_A:Cell("ZLX_PRCPRE"):SetValue(0)                    // 16 - Pre�o Acertado         // 14
      _oSect2_A:Cell("ZLX_DIFPRC"):SetValue(0)                    // 17 - Diferen�a de Pre�o     // 15 
      _oSect2_A:Cell("GORDURA"):SetValue(0)                       // 18 - Teor de Gordura        // 16 
      _oSect2_A:Cell("EXTRATO"):SetValue(0)                       // 18 - Teor de Extrato Seco Total // 16 
      _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                   // 19 - Status da Recep��o     // 17
      _oSect2_A:Cell("ZLX_OBS"):SetValue("")                      // 20 - Observa��o             // 18
      _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")                   // 21 - Procedencia            // 2-b
      _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)   // 03 - C�digo da Recep��o     // 1
      _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)   // 12 - Volume Recebido        // 10
      _oSect2_A:Cell("CHAVEPESQ"):Disable()
      _oSect2_A:Printline()
   
      TRBREL->(DbSkip())
   
      //====================================================================================================
      // Ordena a posi��o dos totais. Conte�do: 4 = Registro de Sub TERCEIROS.
      //====================================================================================================
      _oSect2_A:Cell("FORNECE"):SetValue("")                      // 04 - Nome do Fornecedor     // 2-a
      _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                    // 05 - N�mero da NF           // 3
      _oSect2_A:Cell("TRANSP"):SetValue("")                       // 06 - Nome do Transportador  // 4
      _oSect2_A:Cell("ZLX_PLACA"):SetValue("")                    // 07 - Placa do ve�culo       // 5
      _oSect2_A:Cell("ZLX_PESOCA"):SetValue(0)                    // 08 - Peso Carregado         // 6
      _oSect2_A:Cell("ZLX_PESOVA"):SetValue(0)                    // 09 - Peso Vazio             // 7
      _oSect2_A:Cell("ZLX_PESOLI"):SetValue(0)                    // 10 - Peso L�quido           // 8
      _oSect2_A:Cell("ZZX_DENSID"):SetValue(0)                    // 11 - Densidade              // 9
      _oSect2_A:Cell("ZLX_VOLNF"):SetValue(0)                     // 13 - Volume NF              // 11
      _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(0)                    // 14 - Diferen�a de Volume    // 12
      _oSect2_A:Cell("ZLX_PRCNF"):SetValue(0)                     // 15 - Pre�o NF               // 13
      _oSect2_A:Cell("ZLX_PRCPRE"):SetValue(0)                    // 16 - Pre�o Acertado         // 14
      _oSect2_A:Cell("ZLX_DIFPRC"):SetValue(0)                    // 17 - Diferen�a de Pre�o     // 15 
      _oSect2_A:Cell("GORDURA"):SetValue(0)                       // 18 - Teor de Gordura        // 16 
      _oSect2_A:Cell("EXTRATO"):SetValue(0)                       // 18 - Teor de Extrato Seco Total // 16 
      _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                   // 19 - Status da Recep��o     // 17
      _oSect2_A:Cell("ZLX_OBS"):SetValue("")                      // 20 - Observa��o             // 18
      _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")                   // 21 - Procedencia            // 2-b
      _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)   // 03 - C�digo da Recep��o     // 1
      _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)   // 12 - Volume Recebido        // 10
      _oSect2_A:Cell("CHAVEPESQ"):Disable()
      _oSect2_A:Printline()
   
      TRBREL->(DbSkip())

      //====================================================================================================
      // Ordena a posi��o dos totais. Conte�do: 5 = Registro de Sub TOTAIS.
      //====================================================================================================
      _oSect2_A:Cell("FORNECE"):SetValue("")                      // 04 - Nome do Fornecedor     // 2-a
      _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                    // 05 - N�mero da NF           // 3
      _oSect2_A:Cell("TRANSP"):SetValue("")                       // 06 - Nome do Transportador  // 4
      _oSect2_A:Cell("ZLX_PLACA"):SetValue("")                    // 07 - Placa do ve�culo       // 5
      _oSect2_A:Cell("ZLX_PESOCA"):SetValue(0)                    // 08 - Peso Carregado         // 6
      _oSect2_A:Cell("ZLX_PESOVA"):SetValue(0)                    // 09 - Peso Vazio             // 7
      _oSect2_A:Cell("ZLX_PESOLI"):SetValue(0)                    // 10 - Peso L�quido           // 8
      _oSect2_A:Cell("ZZX_DENSID"):SetValue(0)                    // 11 - Densidade              // 9
      _oSect2_A:Cell("ZLX_VOLNF"):SetValue(0)                     // 13 - Volume NF              // 11
      _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(0)                    // 14 - Diferen�a de Volume    // 12
      _oSect2_A:Cell("ZLX_PRCNF"):SetValue(0)                     // 15 - Pre�o NF               // 13
      _oSect2_A:Cell("ZLX_PRCPRE"):SetValue(0)                    // 16 - Pre�o Acertado         // 14
      _oSect2_A:Cell("ZLX_DIFPRC"):SetValue(0)                    // 17 - Diferen�a de Pre�o     // 15 
      _oSect2_A:Cell("GORDURA"):SetValue(0)                       // 18 - Teor de Gordura        // 16 
      _oSect2_A:Cell("EXTRATO"):SetValue(0)                       // 18 - Teor de Extrato Seco Total  // 16 
      _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                   // 19 - Status da Recep��o     // 17
      _oSect2_A:Cell("ZLX_OBS"):SetValue("")                      // 20 - Observa��o             // 18
      _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")                   // 21 - Procedencia            // 2-b    

      _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)   // 03 - C�digo da Recep��o     // 1
      _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)   // 12 - Volume Recebido        // 10
      _oSect2_A:Cell("CHAVEPESQ"):Disable()
      _oSect2_A:Printline()
   
      _oReport:ThinLine()
      
      //=============================================================================
      // Total Geral por Produtos
      //=============================================================================
      For _nI := 1 To Len(_aTotaisPrd)
          TRBREL->(DbSkip())
            
          _oSect2_A:Cell("ZLX_NRONF"):SetValue("")                    // 05 - N�mero da NF           // 3
          _oSect2_A:Cell("ZLX_PLACA"):SetValue("")                    // 07 - Placa do ve�culo       // 5
          _oSect2_A:Cell("ZLX_PESOCA"):SetValue(0)                    // 08 - Peso Carregado         // 6
          _oSect2_A:Cell("ZLX_PESOVA"):SetValue(0)                    // 09 - Peso Vazio             // 7
          _oSect2_A:Cell("ZLX_PESOLI"):SetValue(0)                    // 10 - Peso L�quido           // 8
          _oSect2_A:Cell("ZZX_DENSID"):SetValue(0)                    // 11 - Densidade              // 9
          _oSect2_A:Cell("ZLX_VOLNF"):SetValue(0)                     // 13 - Volume NF              // 11
          _oSect2_A:Cell("ZLX_DIFVOL"):SetValue(0)                    // 14 - Diferen�a de Volume    // 12
          _oSect2_A:Cell("ZLX_PRCNF"):SetValue(0)                     // 15 - Pre�o NF               // 13
          _oSect2_A:Cell("ZLX_PRCPRE"):SetValue(0)                    // 16 - Pre�o Acertado         // 14
          _oSect2_A:Cell("ZLX_DIFPRC"):SetValue(0)                    // 17 - Diferen�a de Pre�o     // 15 
          _oSect2_A:Cell("GORDURA"):SetValue(0)                       // 18 - Teor de Gordura        // 16 
          _oSect2_A:Cell("EXTRATO"):SetValue(0)                       // 19 - Teor de Extrato Seco Total // 17
          _oSect2_A:Cell("ZLX_STATUS"):SetValue("")                   // 20 - Status da Recep��o     // 18
          _oSect2_A:Cell("ZLX_OBS"):SetValue("")                      // 21 - Observa��o             // 19
          _oSect2_A:Cell("ZLX_TIPOLT"):SetValue("")                   // 22 - Procedencia            // 2-b    

          _oSect2_A:Cell("FORNECE"):SetValue(TRBREL->FORNECE)         // 04 - Nome do Fornecedor     // 2-a
          _oSect2_A:Cell("TRANSP"):SetValue(TRBREL->TRANSP)           // 06 - Nome do Transportador  // 4
          _oSect2_A:Cell("ZLX_CODIGO"):SetValue(TRBREL->ZLX_CODIGO)   // 03 - C�digo da Recep��o     // 1
          _oSect2_A:Cell("ZLX_VOLREC"):SetValue(TRBREL->ZLX_VOLREC)   // 12 - Volume Recebido        // 10
          _oSect2_A:Cell("CHAVEPESQ"):Disable()
          _oSect2_A:Printline()
      Next
      
      _oReport:ThinLine()
       
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

#Include "Protheus.ch"
#Include "Fileio.ch"

#Define TITULO	"Recep��o do Leite de Terceiros - Detalhamento por Produtos"
#Define CRLF	Chr(13)+Chr(10)

/*
===============================================================================================================================
Programa--------: RGLT002
Autor-----------: Alexandre Villar
Data da Criacao-: 13/07/2015
===============================================================================================================================
Descri��o-------: Relat�rio dos registros de recebimentos de leite de terceiros - Detalhamento por produto
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function RGLT002A()

Local _aCabec1		:= { ' C�digo'  , 'Proced�ncia' , 'N�mero' , 'Transportador' , 'Placa' , ' Peso' , ' Peso' , '  Peso'  , 'Densidade' , ' Volume'  , 'Volume' , 'Dif. na' , ' Pre�o'  , '  Pre�o'  , 'Diferen�a' , 'Teor de' , 'Teor de' ,'Classif.' , 'Observa��es' }
Local _aCabec2		:= { 'Recep��o' , ''            , '     NF' , ''              , ''      , 'Cheio' , 'Vazio' , 'L�quido' , ''          , 'Recebido' , '   NF'  , 'Balan�a' , 'Emitido' , 'Acertado' , ' de pre�o' , 'Gordura' , 'EST'    ,''         , ''            }
Local _aColCab		:= { 0050       , 0280          , 0550      , 0780            , 1050    , 1200    , 1350    , 1500      , 1625        , 1800       , 1950     , 2100      , 2250      , 2400       , 2550        , 2700      , 2850     , 3000       , 3200         }
Local _aColItn		:= { 0050       , 0210          , 0550      , 0705            , 1050    , 1300    , 1450    , 1600      , 1725        , 1900       , 2050     , 2200      , 2350      , 2500       , 2650        , 2800      , 2950     , 3000       , 3150         }
Local _aDados		:= {}
Local _cPerg		:= "RGLT002"
Local _nOpca		:= 0
Local _aSays		:= {}
Local _aButtons		:= {}

Private _oReport	:= Nil

SET DATE FORMAT		TO "DD/MM/YYYY"

Pergunte( _cPerg , .F. )

aAdd( _aSays , OemToAnsi( "Este programa tem como objetivo gerar o relat�rio de registros da recep��o de leite "	) )
aAdd( _aSays , OemToAnsi( "de terceiros: detalhamento por produto. "												) )

aAdd( _aButtons , { 5 , .T. , {| | Pergunte( _cPerg )			} } )
aAdd( _aButtons , { 1 , .T. , {|o| _nOpca := 1 , o:oWnd:End()	} } )
aAdd( _aButtons , { 2 , .T. , {|o| _nOpca := 0 , o:oWnd:End()	} } )

FormBatch( "RGLT002" , _aSays , _aButtons ,, 155 , 500 )

If _nOpca == 1

	Processa( {|| _aDados := RGLT002ASEL() } , "Aguarde!" , "Selecionando registros das recep��es..." )
	
	IF Empty(_aDados)
		MsgInfo("N�o foram encontrados registros para exibir! Verifique os par�metros e tente novamente.","RGLT00201")
	Else
		Processa( {|| RGLT002APRT( _aCabec1 , _aCabec2 , _aColCab , _aColItn , _aDados ) } , 'Aguarde!' , 'Imprimindo registros...' )
	EndIF

Else
	MsgInfo("Opera��o cancelada pelo usu�rio!","RGLT00202")
EndIf

Return

/*
===============================================================================================================================
Programa--------: RGLT002ASEL
Autor-----------: Alexandre Villar
Data da Criacao-: 13/07/2015
===============================================================================================================================
Descri��o-------: Fun��o para consulta e prepara��o dos dados do relat�rio
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _aRet - Dados do relat�rio
===============================================================================================================================
*/
Static Function RGLT002ASEL()

Local _aRet			:= {}
Local _cAlias		:= GetNextAlias()
Local _nTotReg		:= 0
Local _nRegAtu		:= 0

//================================================================================
// Efetua a Sele��o de Dados do Relat�rio.
//================================================================================
RGLT002Q(_cAlias)

(_cAlias)->( DBEval( {|| _nTotReg++ } ) )
(_cAlias)->( DBGoTop() )

ProcRegua(_nTotReg)
While (_cAlias)->( !Eof() )
	
	_nRegAtu++
	IncProc( "Lendo registros: ["+ StrZero( _nRegAtu , 6 ) +"] de ["+ StrZero( _nTotReg , 6 ) +"]" )
	
	aAdd( _aRet , {				(_cAlias)->ZLX_DTENTR									,; //01 - Data da Recep��o
								(_cAlias)->ZZX_CODPRD									,; //02 - Tipo de Produto
								(_cAlias)->ZLX_CODIGO									,; //03 - C�digo da Recep��o
					AllTrim(	(_cAlias)->FORNECE )									,; //04 - Nome do Fornecedor
								(_cAlias)->ZLX_NRONF									,; //05 - N�mero da NF
					AllTrim(	(_cAlias)->TRANSP )										,; //06 - Nome do Transportador
					AllTrim(	(_cAlias)->ZLX_PLACA )									,; //07 - Placa do ve�culo
			AllTrim( Transform(	(_cAlias)->ZLX_PESOCA , '@E 999,999,999,999'      ) )	,; //08 - Peso Carregado
			AllTrim( Transform(	(_cAlias)->ZLX_PESOVA , '@E 999,999,999,999'      ) )	,; //09 - Peso Vazio
			AllTrim( Transform(	(_cAlias)->ZLX_PESOLI , '@E 999,999,999,999'      ) )	,; //10 - Peso L�quido
			AllTrim( Transform(	(_cAlias)->ZZX_DENSID , '@E 999,999,999,999.9999' ) )	,; //11 - Densidade
			AllTrim( Transform(	(_cAlias)->ZLX_VOLREC , '@E 999,999,999,999'      ) )	,; //12 - Volume Recebido
			AllTrim( Transform(	(_cAlias)->ZLX_VOLNF  , '@E 999,999,999,999'      ) )	,; //13 - Volume NF
			AllTrim( Transform(	(_cAlias)->ZLX_DIFVOL , '@E 999,999,999,999'      ) )	,; //14 - Diferen�a de Volume
			AllTrim( Transform(	(_cAlias)->ZLX_PRCNF  , '@E 999,999,999,999.9999' ) )	,; //15 - Pre�o NF
			AllTrim( Transform(	(_cAlias)->ZLX_PRCPRE , '@E 999,999,999,999.9999' ) )	,; //16 - Pre�o Acertado
			AllTrim( Transform(	(_cAlias)->ZLX_DIFPRC , '@E 999,999,999,999.9999' ) )	,; //17 - Diferen�a de Pre�o
			AllTrim( Transform(	(_cAlias)->GORDURA    , '@E 99.99'   ) )	,; //18 - Teor de Gordura
         AllTrim( Transform(	(_cAlias)->EXTRATO    , '@E 99.99'   ) )	,; //19 - Teor de Extrato Seco Total
					U_ITRetBox(	(_cAlias)->ZLX_STATUS , 'ZLX_STATUS' )					,; //20 - Status da Recep��o
		PadR( Posicione('ZLX',1,xFilial('ZLX')+(_cAlias)->ZLX_CODIGO,'ZLX_OBS') , 30 )	,; //21 - Observa��o
					AllTrim(	(_cAlias)->ZLX_TIPOLT )									}) //22 - Procedencia

(_cAlias)->( DBSkip() )
EndDo

(_cAlias)->( DBCloseArea() )

Return( _aRet )

/*
===============================================================================================================================
Programa--------: RGLT002APRT
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
Static Function RGLT002APRT( _aCabec1 , _aCabec2 , _aColCab , _aColItn , _aDados )

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
		
		RGLT002AVPG( @_oPrint , @_nLinha , .F. , _aCabec1 , _aCabec2 , _aColCab )
		
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
		RGLT002AVPG( @_oPrint , @_nLinha , .T. , _aCabec1 , _aCabec2 , _aColCab )
		
		If _cDtMov <> _aDados[_nI][01]
			
			_nLinha += 035
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha += 10
			_oPrint:Say( _nLinha , _aColCab[01] , 'Totais'									, _oFont03 )
			_oPrint:Say( _nLinha , _aColItn[10] , Transform( _nTotGer , '@E 999,999,999' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[11] , Transform( _nTotNF  , '@E 999,999,999' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[12] , Transform( _nTotDif , '@E 999,999,999' )	, _oFont03 ,,,, 1 )
			
			_nLinha += 050
			
			_oPrint:Say( _nLinha , _aColItn[01]       , 'Plataformas: '										, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotPlt , '@E 999,999,999.99' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
			_oPrint:Say( _nLinha , _aColItn[01]       , 'Filiais: '											, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotFil , '@E 999,999,999.99' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
			_oPrint:Say( _nLinha , _aColItn[01]       , 'Terceiros: '										, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotTer , '@E 999,999,999.99' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
			_oPrint:Say( _nLinha , _aColItn[01]       , 'Totais: '											, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotGer , '@E 999,999,999.99' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
			
			aAdd( _aResFim , {	_cTipPrd		,;
								_nTotGer		,;
								_nTotNF			,;
								_nTotDif		,;
								_nTotPlt		,;
								_nTotFil		,;
								_nTotTer		})
			
			_nTotPlt := _nTotFil := _nTotTer := _nTotGer := _nTotNF := _nTotDif := 0
			
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
			_oPrint:Say( _nLinha , _aColCab[01] , 'Totais'									, _oFont03 )
			_oPrint:Say( _nLinha , _aColItn[10] , Transform( _nTotGer , '@E 999,999,999' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[11] , Transform( _nTotNF  , '@E 999,999,999' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[12] , Transform( _nTotDif , '@E 999,999,999' )	, _oFont03 ,,,, 1 )
			
			_nLinha += 050
			
			RGLT002AVPG( @_oPrint , @_nLinha , .T. , {} , _aColCab )
			
			_oPrint:Say( _nLinha , _aColItn[01]       , 'Plataformas: '										, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotPlt , '@E 999,999,999.99' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
			_oPrint:Say( _nLinha , _aColItn[01]       , 'Filiais: '											, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotFil , '@E 999,999,999.99' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
			_oPrint:Say( _nLinha , _aColItn[01]       , 'Terceiros: '										, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotTer , '@E 999,999,999.99' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
			_oPrint:Say( _nLinha , _aColItn[01]       , 'Totais: '											, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotGer , '@E 999,999,999.99' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
			
			aAdd( _aResFim , {	_cTipPrd		,;
								_nTotGer		,;
								_nTotNF			,;
								_nTotDif		,;
								_nTotPlt		,;
								_nTotFil		,;
								_nTotTer		})
			
			_nTotPlt := _nTotFil := _nTotTer := _nTotGer := _nTotNF := _nTotDif := 0
			
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
		_oPrint:Say( _nLinha , _aColCab[01] , 'Totais'									, _oFont03 )
		_oPrint:Say( _nLinha , _aColItn[10] , Transform( _nTotGer , '@E 999,999,999' )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[11] , Transform( _nTotNF  , '@E 999,999,999' )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[12] , Transform( _nTotDif , '@E 999,999,999' )	, _oFont03 ,,,, 1 )
		
		_nLinha += 050
		
		RGLT002AVPG( @_oPrint , @_nLinha , .T. , {} , _aColCab )
		
		_oPrint:Say( _nLinha , _aColItn[01]       , 'Plataformas: '										, _oFont02 )
		_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotPlt , '@E 999,999,999.99' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
		_oPrint:Say( _nLinha , _aColItn[01]       , 'Filiais: '											, _oFont02 )
		_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotFil , '@E 999,999,999.99' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
		_oPrint:Say( _nLinha , _aColItn[01]       , 'Terceiros: '										, _oFont02 )
		_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotTer , '@E 999,999,999.99' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
		_oPrint:Say( _nLinha , _aColItn[01]       , 'Totais: '											, _oFont02 )
		_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotGer , '@E 999,999,999.99' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
		
		aAdd( _aResFim , {	_cTipPrd		,;
							_nTotGer		,;
							_nTotNF			,;
							_nTotDif		,;
							_nTotPlt		,;
							_nTotFil		,;
							_nTotTer		})
		
		_nTotPlt := _nTotFil := _nTotTer := _nTotGer := _nTotNF := _nTotDif := 0
		
		_cDtMov := _aDados[_nI][01]
		
		_nLinha += 050
		
		RGLT002AVPG( @_oPrint , @_nLinha , .T. , _aCabec1 , _aCabec2 , _aColCab )
		
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
		
		RGLT002AVPG( @_oPrint , @_nLinha , .T. , _aCabec1 , _aCabec2 , _aColCab )
		
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
		_oPrint:Say( _nLinha , _aColCab[01] , 'Totais'									, _oFont03 )
		_oPrint:Say( _nLinha , _aColItn[10] , Transform( _nTotGer , '@E 999,999,999' )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[11] , Transform( _nTotNF  , '@E 999,999,999' )	, _oFont03 ,,,, 1 )
		_oPrint:Say( _nLinha , _aColItn[12] , Transform( _nTotDif , '@E 999,999,999' )	, _oFont03 ,,,, 1 )
		
		_nLinha += 050
		
		RGLT002AVPG( @_oPrint , @_nLinha , .T. , {} , _aColCab )
		
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
							_nTotPlt		,;
							_nTotFil		,;
							_nTotTer		})
		
		_nTotPlt := _nTotFil := _nTotTer := _nTotGer := _nTotNF := _nTotDif := 0
		
		_cTipPrd := _aDados[_nI][02]
		
		_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
		_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
		_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
		_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
		
		_nLinha += 020
		_oPrint:Say( _nLinha , _aColItn[01] , 'Recep��o de '+ Posicione('SX5',1,xFilial('SX5')+'Z7'+PadR(_aDados[_nI][02],TamSX3('X5_CHAVE')[01]),'X5_DESCRI') , _oFont02 )
		_nLinha += 050
		
		RGLT002AVPG( @_oPrint , @_nLinha , .T. , _aCabec1 , _aCabec2 , _aColCab )
		
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
	
	RGLT002AVPG( @_oPrint , @_nLinha , .T. , _aCabec1 , _aCabec2 , _aColCab )
	
	For _nX := 1 To _nTotCol
		_oPrint:Say( _nLinha , _aColItn[_nX] , _aDados[_nI][_nX+2] , _oFont03 ,,,, IIF( StrZero(_nX,2) $ '06;07;08;09;10;11;12;13;14;15;16;17' , 1 , 0 ) )
	Next _nX
	
	_nConTot++
	_nTotGer	+= Val( StrTran( StrTran( _aDados[_nI][12] , '.' , '' ) , ',' , '.' ) )
	_nTotNF		+= Val( StrTran( StrTran( _aDados[_nI][13] , '.' , '' ) , ',' , '.' ) )
	_nTotDif	+= Val( StrTran( StrTran( _aDados[_nI][14] , '.' , '' ) , ',' , '.' ) )
	
	If _aDados[_nI][22] == 'F'
		_nTotFil += Val( StrTran( StrTran( _aDados[_nI][12] , '.' , '' ) , ',' , '.' ) )
	ElseIf _aDados[_nI][22] == 'P'
		_nTotPlt += Val( StrTran( StrTran( _aDados[_nI][12] , '.' , '' ) , ',' , '.' ) )
	ElseIf _aDados[_nI][22] == 'T'
		_nTotTer += Val( StrTran( StrTran( _aDados[_nI][12] , '.' , '' ) , ',' , '.' ) )
	EndIf
	
Next _nI

//=============================================================================
//| Verifica o posicionamento da p�gina                                       |
//=============================================================================
_nLinha += 035
_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha += 10
_oPrint:Say( _nLinha , _aColCab[01] , 'Totais'									, _oFont03 )
_oPrint:Say( _nLinha , _aColItn[10] , Transform( _nTotGer , '@E 999,999,999' )	, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[11] , Transform( _nTotNF  , '@E 999,999,999' )	, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[12] , Transform( _nTotDif , '@E 999,999,999' )	, _oFont03 ,,,, 1 )

_nLinha += 050

RGLT002AVPG( @_oPrint , @_nLinha , .T. , {} , _aColCab )

_oPrint:Say( _nLinha , _aColItn[01]       , 'Plataformas: '										, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotPlt , '@E 999,999,999.99' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
_oPrint:Say( _nLinha , _aColItn[01]       , 'Filiais: '											, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotFil , '@E 999,999,999.99' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
_oPrint:Say( _nLinha , _aColItn[01]       , 'Terceiros: '										, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotTer , '@E 999,999,999.99' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030
_oPrint:Say( _nLinha , _aColItn[01]       , 'Totais: '											, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 550 , Transform( _nTotGer , '@E 999,999,999.99' ) +' L'	, _oFont02 ,,,, 1 ) ; _nLinha += 030

aAdd( _aResFim , {	_cTipPrd		,;
					_nTotGer		,;
					_nTotNF			,;
					_nTotDif		,;
					_nTotPlt		,;
					_nTotFil		,;
					_nTotTer		})

_aResFim := aSort( _aResFim ,,, {|x,y| x[1] < y[1] } )

_cTipPrd	:= ''
_nLinha		:= 5000

RGLT002AVPG( @_oPrint , @_nLinha , .T. , {} , _aColCab )

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
			
			RGLT002AVPG( @_oPrint , @_nLinha , .T. , {} , _aColCab )
			
			_oPrint:Say( _nLinha , _aColItn[01]        , '> Total da Recep��o de '+ Posicione('SX5',1,xFilial('SX5')+'Z7'+PadR(_cTipPrd,TamSX3('X5_CHAVE')[01]),'X5_DESCRI') , _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 1000 , 'Total Recebido'	, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 1300 , 'Total das Notas'	, _oFont02 )
			_oPrint:Say( _nLinha , _aColItn[01] + 1600 , 'Direren�a'		, _oFont02 ) ; _nLinha += 40
			
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++ 
			
			_oPrint:Say( _nLinha , _aColItn[01] + 1200 , Transform( _nTotGer , '@E 999,999,999' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[01] + 1450 , Transform( _nTotNF  , '@E 999,999,999' )	, _oFont03 ,,,, 1 )
			_oPrint:Say( _nLinha , _aColItn[01] + 1690 , Transform( _nTotDif , '@E 999,999,999' )	, _oFont03 ,,,, 1 )
			
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
		_nTotPlt	:= 0
		_nTotFil	:= 0
		_nTotTer	:= 0
		
	EndIf
	
	_nTotGer += _aResFim[_nI][02]
	_nTotNF  += _aResFim[_nI][03]
	_nTotDif += _aResFim[_nI][04]
	_nTotPlt += _aResFim[_nI][05]
	_nTotFil += _aResFim[_nI][06]
	_nTotTer += _aResFim[_nI][07]
	
Next _nI

RGLT002AVPG( @_oPrint , @_nLinha , .T. , {} , _aColCab )

_oPrint:Say( _nLinha , _aColItn[01]        , '> Total da Recep��o de '+ Posicione('SX5',1,xFilial('SX5')+'Z7'+PadR(_cTipPrd,TamSX3('X5_CHAVE')[01]),'X5_DESCRI') , _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 1000 , 'Total Recebido'	, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 1300 , 'Total das Notas'	, _oFont02 )
_oPrint:Say( _nLinha , _aColItn[01] + 1600 , 'Direren�a'		, _oFont02 ) ; _nLinha += 40

_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++ 

_oPrint:Say( _nLinha , _aColItn[01] + 1200 , Transform( _nTotGer , '@E 999,999,999' )	, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[01] + 1450 , Transform( _nTotNF  , '@E 999,999,999' )	, _oFont03 ,,,, 1 )
_oPrint:Say( _nLinha , _aColItn[01] + 1690 , Transform( _nTotDif , '@E 999,999,999' )	, _oFont03 ,,,, 1 )

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

Return()

/*
===============================================================================================================================
Programa--------: RGLT002AVPG
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
Static Function RGLT002AVPG( _oPrint , _nLinha , _lFinPag , _aCabec1 , _aCabec2 , _aColCab )

Local _nLimPag		:= 2300 //3400

Default _lFinPag	:= .T.

If _nLinha > _nLimPag

	//====================================================================================================
	// Verifica se encerra a p�gina atual
	//====================================================================================================
	IF _lFinPag
		_oPrint:EndPage()
	EndIF
	
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
	
EndIF

Return

/*
===============================================================================================================================
Programa--------: RGLT002Q
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
Static Function RGLT002Q(_cAlias)

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
	SELECT ZLX.ZLX_DTENTR, ZZX.ZZX_CODPRD, ZLX.ZLX_CODIGO, A2F.A2_NREDUZ FORNECE, ZLX.ZLX_NRONF, A2T.A2_NREDUZ TRANSP,
	        ZLX.ZLX_PLACA, ZLX.ZLX_PESOCA, ZLX.ZLX_PESOVA, ZLX.ZLX_PESOVA, ZLX.ZLX_PESOLI, ZZX.ZZX_DENSID, ZLX.ZLX_VOLREC,
	        ZLX.ZLX_VOLNF, ZLX.ZLX_DIFVOL, ZLX.ZLX_PRCNF, ZLX.ZLX_PRCPRE, ZLX.ZLX_DIFPRC,
	        NVL(ROUND((SELECT SUM(ZAP_GORD) / COUNT(1)
	                    FROM %Table:ZAP% ZAP
	                   WHERE ZAP.D_E_L_E_T_ = ' '
	                     AND ZAP.ZAP_FILIAL = %xFilial:ZAP%
	                     AND ZLX.ZLX_CODANA = ZAP.ZAP_CODIGO),
	                  2), 0) AS GORDURA,
	        NVL(ROUND((SELECT SUM(ZAP_EST) / COUNT(1)
	                    FROM %Table:ZAP% ZAP
	                   WHERE ZAP.D_E_L_E_T_ = ' '
	                     AND ZAP.ZAP_FILIAL = %xFilial:ZAP%
	                     AND ZLX.ZLX_CODANA = ZAP.ZAP_CODIGO),
	                  2), 0) AS EXTRATO,
	        ZLX.ZLX_STATUS, ZLX.ZLX_TIPOLT
	   FROM %Table:ZLX% ZLX, %Table:SA2% A2T, %Table:SA2F% A2F, %Table:ZZX% ZZX, %Table:ZZV% ZZV
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
