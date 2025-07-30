/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |09/10/2024| Chamado 48465. Retirada manipula��o do SX1
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'
#Include "report.ch"
#INCLUDE 'TOPCONN.CH'

/*
===============================================================================================================================
Programa--------: RGPE024
Autor-----------: Julio de Paula Paz
Data da Criacao-: 11/09/2023
Descri��o-------: Relat�rio de Confer�ncia de Descri��o de Cargoss. Chamado 44099.
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function RGPE024()
Local _oReport := nil
Local _cPerg	:=	"RGPE024"

Private _aOrder := {'Cargo'}
Private _oSect1_A := Nil
Private _oSect1_B := Nil
Private _nOrdReport := 1
Private _oBreakFil

Begin Sequence 

   Pergunte(_cPerg,.F.)	          
	_oReport := RGPE024D(_cPerg)
	_oReport:PrintDialog()

End Sequence

Return Nil

/*
===============================================================================================================================
Programa----------: RGPE024D
Autor-------------: Julio de Paula Paz
Data da Criacao---: 11/09/2023
Descri��o---------: Realiza as defini��es do relat�rio. (ReportDef)
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RGPE024D(_cNome)
Local _oReport := Nil

Begin Sequence	
   _oReport := TReport():New(_cNome,"Relat�rio de Confer�ncia de Descri��o de Cargos" ,_cNome,{|_oReport| RGPE024P(_oReport)},"Relat�rio de Confer�ncia de Descri��o de Cargos")
   _oReport:SetLandscape()    
   _oReport:SetTotalInLine(.F.)

   _oSect1_A := TRSection():New(_oReport, "Relat�rio de Confer�ncia de Descri��o de Cargos"  , {"SRA","SQ3"},_aOrder , .F., .T.)
   TRCell():New(_oSect1_A,"RA_CARGO"	,"TRBSRA","Cargo"      ,"@!",10)
   TRCell():New(_oSect1_A,"RA_DCARGO"	,"TRBSRA","Desc. Cargo","@!",30)
   
   //_oSect1_B := TRSection():New(_oReport, "Relat�rio de Confer�ncia de Descri��o de Cargos"  , {"SRA","SQ3"},_aOrder , .F., .T.)
   //_oSect2_A := TRSection():New(_oSect1_A, "Por Dt.Emiss�o" , {"SF2","SA1","SA2"}, , .F., .T.)
   _oSect1_B := TRSection():New(_oSect1_A, "Relat�rio de Confer�ncia de Descri��o de Cargos"  , {"SRA","SQ3"}, , .F., .T.)
   TRCell():New(_oSect1_B,"RA_FILIAL"	 , "TRBSRA"  ,"Filial"      ,"@!",10)	
   TRCell():New(_oSect1_B,"RA_MAT"	    , "TRBSRA"  ,"Matricula"   ,"@!",10)		
   TRCell():New(_oSect1_B,"RA_NOME"	    , "TRBSRA"  ,"Nome"        ,"@!",40)		
   TRCell():New(_oSect1_B,"QB_DESCRIC"  , "TRBSRA"  ,"Depto"       ,"@!",25)		
   TRCell():New(_oSect1_B,"RA_CODFUNC"	 , "TRBSRA"  ,"Cod.Func�o"  ,"@!",10)
   TRCell():New(_oSect1_B,"RA_DESCFUN"  , "TRBSRA"  ,"Fun��o"      ,"@!",10)
   TRCell():New(_oSect1_B,"Q3_MEMO1"    , "TRBSRA"  ,"Desc.Fun��o" ,"@!",80) 
   _oSect1_B:SetTotalText(" ")              

   //Definindo a quebra
	_oBreak := TRBreak():New(_oSect1_A,{|| TRBSRA->RA_CARGO },{|| "..." },.F.,,.T.)
	_oSect1_A:SetHeaderBreak(.T.)

End Sequence
					
Return(_oReport)

/*
===============================================================================================================================
Programa----------: RGPE024P
Autor-------------: Julio de Paula Paz
Data da Criacao---: 11/09/2023
Descri��o---------: Realiza a impress�o do relat�rio. (ReportPrint)
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RGPE024P(_oReport)
Local _cQry       := ""		
Local _cWhere := ""
Local _nTotRegs
Local _cCargo, _cDepto, _cDescFunc

Begin Sequence                    

   //====================================================================================================
   // Monta a query de dados.
   //====================================================================================================	

   _nOrdReport := _oReport:GetOrder()    
   
   If ! Empty(MV_PAR01)
	   _cWhere += " AND RA_FILIAL = '" + MV_PAR01 + "' "
	EndIf 
    
	If ! Empty(MV_PAR02)
	   _cWhere += " AND RA_MAT = '" + MV_PAR02 + "' "  
	EndIf 

   If ! Empty(MV_PAR03)
	   _cWhere += " AND RA_DEPTO = '"+ MV_PAR03 + "' " 
	EndIf 

   If ! Empty(MV_PAR04)
	   _cWhere += " AND RA_CARGO = '"+ MV_PAR04 + "' " 
   EndIf 

   If ! Empty(MV_PAR05) 
	  _cWhere += " AND RA_SITFOLH IN (" + fSqlIn(MV_PAR05,1) + ") "		 
   EndIf 

   MV_PAR06 := StrTran(MV_PAR06, '*', "")

   If ! Empty(MV_PAR06) 
	  _cWhere += " AND RA_CATFUNC IN (" + fSqlIn(MV_PAR06,1) + ") "		 
   EndIf 
                                                                  
	_cQry += " SELECT RA_CARGO, RA_FILIAL, RA_MAT, RA_NOME, RA_DEPTO, RA_CODFUNC, SQ3.R_E_C_N_O_ AS NRRECNO	"
	_cQry += " FROM " + RetSqlName("SRA") + " SRA "
	_cQry += " INNER JOIN " + RetSqlName("SQ3") + " SQ3 ON (SRA.RA_FILIAL = SQ3.Q3_FILIAL AND SRA.RA_CARGO = SQ3.Q3_CARGO AND SQ3.D_E_L_E_T_ = ' ' )"
	_cQry += " WHERE  SRA.D_E_L_E_T_ = ' ' "
   _cQry := _cQry  + _cWhere

   _cQry += " ORDER BY RA_CARGO, RA_FILIAL "

   If Select("TRBSRA") <> 0
	   TRBSRA->(DbCloseArea())
   EndIf
	
   TCQUERY _cQry NEW ALIAS "TRBSRA"	
      	
   DbSelectArea("TRBSRA")
   TRBSRA->(dbGoTop())

   Count to _nTotRegs	

   IF _ntotRegs = 0
      U_ITMSG("N�o existe dados para emiss�o do relat�rio.",'Aten��o!',"Altere os filtros do relat�rio e tente novamente",3) 
      BREAK
   ENDIF

   TRBSRA->(dbGoTop())

   //====================================================================================================
   // Ativa a se��o do relat�rio conforme a ordem de emiss�o do relat�rio.
   //====================================================================================================	
   _oSect1_A:Enable() 
   _oSect1_B:Enable() 

   _oReport:SetMeter(_nTotRegs)	

   SQ3->(DbSetOrder(1)) // 1=Q3_FILIAL+Q3_CARGO+Q3_CC // Cargos
   SQB->(DbSetOrder(1)) // 1=QB_FILIAL+QB_DEPTO+QB_DESCRIC // Departamentos

   //====================================================================================================
   // Inicia a emiss�o do relat�rio 
   //====================================================================================================		
   TRBSRA->(dbGoTop())
   _cCargo := Space(6)
   _lFirstPag := .T.

   Do While !TRBSRA->(Eof())

      If _oReport:Cancel()
         Exit
      EndIf

      SQ3->(DbGoTo(TRBSRA->NRRECNO))
      //====================================================================================================
      // Inicializando a primeira se��o
      //====================================================================================================		 
      If _cCargo <> TRBSRA->RA_CARGO
         _cCargo := TRBSRA->RA_CARGO

	      _oSect1_A:Init()
         
	      _oReport:IncMeter()
	                  
         _oSect1_A:Cell("RA_CARGO"):SetValue(TRBSRA->RA_CARGO)
		   _oSect1_A:Cell("RA_DCARGO"):SetValue(SQ3->Q3_DESCSUM)
		   _oSect1_A:Printline()
         
         _oSect1_B:Init()

         If ! _lFirstPag
            _oSect1_B:PrintHeader(.T.,.T.)
         Else 
            _lFirstPag := .F.
         EndIf 

      EndIf 

      //====================================================================================================
      // Inicializando a segunda se��o
      //====================================================================================================		 
	   _oReport:IncMeter()
      _cDepto :=  Posicione("SQB",1,TRBSRA->RA_FILIAL + TRBSRA->RA_DEPTO ,"QB_DESCRIC")  

      _cDescFunc := MSMM(SQ3->Q3_DESCDET,80,,,,,,"SQ3",,"RDY")

      _cDesRedFu := Posicione("SRJ",1,TRBSRA->RA_FILIAL + TRBSRA->RA_CODFUNC ,"RJ_DESC")  // RJ_FILIAL+RJ_FUNCAO = 1

      _oSect1_B:Cell("RA_FILIAL"):SetValue(TRBSRA->RA_FILIAL)	
      _oSect1_B:Cell("RA_MAT"):SetValue(TRBSRA->RA_MAT)		
      _oSect1_B:Cell("RA_NOME"):SetValue(TRBSRA->RA_NOME) 
      _oSect1_B:Cell("QB_DESCRIC"):SetValue(_cDepto) 
      _oSect1_B:Cell("RA_CODFUNC"):SetValue(TRBSRA->RA_CODFUNC)
      _oSect1_B:Cell("RA_DESCFUN"):SetValue(_cDesRedFu)
      _oSect1_B:Cell("Q3_MEMO1"):SetValue(_cDescFunc)
      _oSect1_B:Printline()
      
      TRBSRA->(dbSkip())
   EndDo		
   
   //====================================================================================================
   // Finaliza segunda se��o.
   //====================================================================================================	
 	_oSect1_A:Finish()
 	
   //====================================================================================================
   // Imprime linha separadora.
   //====================================================================================================	
   _oReport:ThinLine()

   //====================================================================================================
   // Finaliza primeira se��o.
   //====================================================================================================	 	  
   _oSect1_B:Finish()

End Sequence

If Select("TRBSRA") <> 0
   TRBSRA->(DbCloseArea())
EndIf

Return Nil
