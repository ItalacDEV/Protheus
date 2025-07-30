/*  
===============================================================================================================================
                          ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 05/12/2018 | Ajuste de filtro para 13/Fol - Chamado 27251
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 17/09/2019 | Retirada chamada da função itputx1. Chamado 28346 
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges  	  | 26/09/2019 | Revisão de fontes. Chamado 28346
 -------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 31/07/2020 | Sequencia zerada por filial/arquivo agora - Chamado 33590
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "rwmake.ch" 

/*
===============================================================================================================================
Programa----------: MGPE012
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/08/2015
===============================================================================================================================
Descrição---------: Geracao Arquivo de Recibos de Pagamento - Itau	
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
    
User Function MGPE012()

Local _nOpca	:= 0
Local _aSays	:={ }
Local _aButtons	:= { } //<== arrays locais de preferencia
Local _cPerg	:= "MGPE012"
Local oproc
Local _afils	:= {}
Local _ni		:= 0

Private _cFilSRA	:= ""  
Private _nSeqFun	:= 0
Private _afiliais	:= {}
Private _cagencia
Private _cconta
Private _cdigito
Private _aresults	:= {}
Private _ngravados	:= 0
Private _ntotais	:= 0
Private _cagenciam	:= ""
Private _ccontam	:= ""
Private _ccnpjm		:= ""
Private _cagenciau	:= ""
Private _cdigitou	:= ""
Private _ccontau	:= ""
Private _csequ		:= ""

cCadastro := OemToAnsi("Exportacao de Hollerith Itau") 

Pergunte(_cPerg,.F.)
   
AADD(_aSays,OemToAnsi(" Este programa Gera o Arquivo de Holerite Eletronico Itau" ) ) 

AADD(_aButtons, { 17,.T.,{|| _cFilSRA := BuildExpr("SRA",,_cFilSRA) } } )
AADD(_aButtons, { 5,.T.,{|| Pergunte(_cPerg,.T. ) } } )
AADD(_aButtons, { 1,.T.,{|o| _nOpca := 1,FechaBatch() }} )
AADD(_aButtons, { 2,.T.,{|o| FechaBatch() }} )

//----------------------------------------------------------------
// Pega dados da matriz para usar em filiais que tem o mesmo 
// contrato
//----------------------------------------------------------------
_lachou := .F.
RCC->(Dbsetorder(1))
If RCC->(dbseek(xfilial("RCC")+"S052"+'01'))
		
	Do while !(RCC->(Eof())) .and. RCC->RCC_FILIAL == xfilial("RCC") .and. RCC->RCC_CODIGO = "S052" .and. RCC->RCC_FIL = '01'
			
			  If substr(RCC->RCC_CONTEU,21,3) == "341"
			  
			  	SM0->(DBSeek('01' + '01'))
			  	_lachou := .T.
			  	_cagenciam := alltrim(substr(RCC->RCC_CONTEU,24,5))
			  	_ccontam := alltrim(substr(RCC->RCC_CONTEU,30,12))
			  	_ccnpjm := StrZero(Val(SM0->M0_CGC),14)
			  	SM0->(DBSeek('01' + cfilant))
			  				  	
			  	exit
			  	
			  Endif
			  
			  RCC->(Dbskip())
	Enddo
	
Endif

If !_lachou

	u_itmsg("Não foram localizados dados bancarios da matriz","Atenção",,1)
	
	Return
	
Endif


	
FormBatch( cCadastro, _aSays, _aButtons )

//----------------------------------------------------------------
// Variaveis utilizadas para parametros                         
//----------------------------------------------------------------
If _nOpca == 1

	//Grava log de utilização
	u_itlogacs()

	//Roda loop de filiais
	If empty(MV_PAR14)
	
		_cfilloc := cfilant
		
		SM0->(Dbgotop())
		
		Do while !(SM0->(EOF()))
		
			aadd(_afils,ALLTRIM(SM0->M0_CODFIL))
			SM0->(Dbskip())
		
		Enddo
		SM0->(DBSeek('01' + cfilant))
	
	Else
	
		_afils := StrTokArr(MV_PAR14,";")
		_cfilloc := cfilant
		
	Endif
	
	For _ni := 1 to len(_afils)
	
		cfilant := _afils[_ni]

		//Pega parâmetro com dados da agencia, conta/digito pagadora
		_lachou := .F.
		RCC->(Dbsetorder(1))
		If RCC->(dbseek(xfilial("RCC")+"S052"+cfilant))
		
			Do while !(RCC->(Eof())) .and. RCC->RCC_FILIAL == xfilial("RCC") .and. RCC->RCC_CODIGO = "S052" .and. RCC->RCC_FIL = cfilant
			
			  If substr(RCC->RCC_CONTEU,21,3) == "341"
			  
			  	_lachou := .T.
			  	_cagencia := alltrim(substr(RCC->RCC_CONTEU,24,5))
			  	_cconta := alltrim(substr(RCC->RCC_CONTEU,30,12))
			  	_cdigito := alltrim(substr(RCC->RCC_CONTEU,42,1))
			  	_cseq := alltrim(substr(RCC->RCC_CONTEU,44,6))
			  	exit
			  	
			  Endif
			  
			  RCC->(Dbskip())
			  
			Enddo
			
		Endif

		_ngravados := 0
		_nSeqfun := 0
		
		If SM0->(DBSeek('01' + cfilant)) .and. _lachou
		
			If !(_cagencia == _cagenciau .and. _cconta == _ccontau .and. _cdigito == _cdigitou .and. _cseq == _csequ)
			
				_npos := ascan(_afiliais,{|_vAux|_vAux[1]==_cagencia .and. _vAux[2]==_cconta .and. _vAux[3]==_cdigito .and. _vAux[4] == _cseq })  
				
			 	If _npos == 0
			 	
			 		_nSeqFun := 0
			 		aadd(_afiliais,{_cagencia,_cconta,_cdigito,_cseq,0})
			 		_npos := len(_afiliais)
			 		
			 	Else
			 	
			 		_nSeqfun := 0
			 		
			 	Endif
			 	
			 Endif
			 
		
			fwmsgrun(,{|oproc| MGPE012P(oproc)},"Geracao do Arquivo Holerite","Processando dados...")  
			
			_afiliais[_npos,5] := _nSeqFun
			_cagenciau := _cagencia
			_ccontau := _cconta
			_cdigitou := _cdigito
			_csequ := _cseq
			
		Else
		
			u_itmsg("Dados bancarios ou filial " + cfilant + " não encontrados","Atenção","Registros dessa filial não serão processados",1)
		
		Endif
		
	Next
	
	cfilant := _cfilloc
	SM0->(DBSeek('01' + cfilant))
	
	If len(_aresults) > 0
		//Apresenta resultados da gravação
		U_ITListBox( 'Dados gravados nos arquivos' , {"Filial","CC","Matricula","Nome","Funcao","Vencimentos","Descontos","Liquido","Salário"} , _aresults , .T. , 1 )
	
		u_itmsg("Arquivos Gerado com no Diretorio : " + MV_PAR04, "Processo Concluído",,2 )
	
	Else

		u_itmsg("Não foram gerados arquivos!","Atenção",,1 )

	Endif

	

Endif


Return Nil

/*
===============================================================================================================================
Programa----------: MGPE012P
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/08/2015
===============================================================================================================================
Descrição---------: Gera o arquivo texto   
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function MGPE012P(oproc)

//----------------------------------------------------------------
// Define Variaveis Locais (Programa)                           
//----------------------------------------------------------------
Local _cMesAnoRef, _cAnoMesRef, _cMesArqRef, cArqNtx
Local _aOrdBag     := {}
Local _cArqMov     := ""
Local _cAcessaSR1  := &("{ || " + ChkRH("GPER030","SR1","2") + "}")
Local _cAcessaSRA  := &("{ || " + ChkRH("GPER030","SRA","2") + "}")
Local _cAcessaSRC  := &("{ || " + ChkRH("GPER030","SRC","2") + "}")
Local _cInicio, _cFim 
Local _cDesc_Fil := "" 
Local _cDesc_Red := ""
Local _cDesc_End := ""
Local _cCcAnt     := Space(9)
Local _nconta := 0
Local _npos := 1



//----------------------------------------------------------------
// Define Variaveis Private(Basicas)                            
//----------------------------------------------------------------
Private  _cAliasMov   := ""
Private _nAteLim := 0
Private  _nBaseFgts := 0 
Private  _nFgts := 0
Private  _nBaseIr := 0
Private  _nBaseIrFe := 0
Private  _nDedDep := 0
Private _nHandle

//----------------------------------------------------------------
// Define Variaveis Private(Programa)                          
//----------------------------------------------------------------
Private _aLanca := {}
Private _aProve := {}
Private _aDesco := {}
Private _aBases := {}
Private _aInfo  := {}
Private _aCodFol:= {}
Private _nSeq   := 0
Private _nTotVct:= 0     
Private _nTotDes:= 0     
Private _nTotLiq:= 0     
Private _nSeqd  := 0     
Private _nLiquido := 0  
Private _aTotLote := {0,0}
Private _cFinPgt := {}            
Private _nTotalLiq := 0    
Private _cCodAdto := ""
Private _cCodBaseAd := ""
Private _nTotvenc := 0
Private _nTotdesc:= 0


If  ! Fp_CodFol(@_aCodFol,cfilant) .Or. ! fInfo(@_aInfo,cfilant)

	u_itmsg("Filial " + cfilant + " não tem dados de folha cadastrados!","Atenção","Filial não será processada",1)
	Return

Endif
        
_cCodAdto   := _aCodFol[007,1]
_cCodBaseAd := _aCodFol[012,1]
_cDesc_Red := Alltrim(_aInfo[1])		
_cDesc_Fil := _aInfo[3]
_cDesc_End := _aInfo[4]                // Dados da Filial

_cMesAnoRef := SUBSTR(MV_PAR01,5,2) + SUBSTR(MV_PAR01,1,4)
_cAnoMesRef := Right(_cMesAnoRef,4) + Left(_cMesAnoRef,2)

If MV_PAR03 == 6  

		_cMesArqRef := "13" + Right(_cMesAnoRef,4)

Else

		_cMesArqRef := _cMesAnoRef

Endif	              

//----------------------------------------------------------------
// Cria o Arquivo TXT                                         
//----------------------------------------------------------------
_nHandle	:= MSFCREATE(Alltrim(alltrim(MV_PAR04)+ALLTRIM(CFILANT)+"_PGTOITAU.REM"))

IF Ferror() # 0 .AND. _nHandle = -1

	u_itmsg( "Erro de abertura, codigo DOS:" + STR(FERROR(),4) ,"Atencao",,1 ) 
    Return

EndIF


//----------------------------------------------------------------
// Selecionando a Ordem de impressao escolhida no parametro.    
//----------------------------------------------------------------
dbSelectArea( "SRA")

If MV_PAR02 == 1

	SRA->(dbSetOrder(1))

ElseIf MV_PAR02 == 2

	SRA->(dbSetOrder(2))

ElseIf MV_PAR02 == 3

	SRA->(dbSetOrder(3))

Endif

SRA->(dbGoTop())

//----------------------------------------------------------------
// Selecionando o Primeiro Registro e montando Filtro.          
//----------------------------------------------------------------
If MV_PAR02 == 1

	SRA->(dbSeek(cfilant + MV_PAR07,.T.))
	_cInicio := "SRA->RA_FILIAL + SRA->RA_MAT"
	_cFim    := cfilant + MV_PAR08

ElseIf MV_PAR02 == 2

	SRA->(dbSeek(cfilant + MV_PAR05 + MV_PAR07,.T.))
	_cInicio  := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
	_cFim     := cfilant + MV_PAR06 + MV_PAR08

ElseIf MV_PAR02 == 3

	SRA->(dbSeek(cfilant + MV_PAR09 + MV_PAR07,.T.))
	_cInicio := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
	_cFim    := cfilant + MV_PAR10 + MV_PAR08

Endif

dbSelectArea("SRA")
//----------------------------------------------------------------
// Carrega Regua Processamento                                  
//----------------------------------------------------------------
_nconta := RecCount()



// Monta Header de Arquivo Empresa - Registro Tipo "0"
MGPE012M() 

If MV_PAR03 == 1			// Adiantamento

   _cFinPgt := "J"

ElseIf MV_PAR03 == 2		// Folha

   _cFinPgt := "E" 

ElseIf MV_PAR03 == 3		// 1a Parcela
 
   _cFinPgt := "A"

ElseIf MV_PAR03 == 4		// 2a Parcela

   _cFinPgt := "B" 

Else					// Extras

   _cFinPgt := "I"	

EndIf


dbSelectArea("SRA")
While !EOF() .And. &_cInicio <= _cFim
	
	//----------------------------------------------------------------
	// Movimenta Regua Processamento                                
	//----------------------------------------------------------------
  	IF valtype(oproc) = "O"

      	oproc:cCaption := ("Processando filial " + alltrim(cfilant) + " - Registro " + strzero(_npos,6) + " de " + strzero(_nconta,6) + "...")
   		ProcessMessages()
 
    ENDIF
  	_npos++
  	
	//----------------------------------------------------------------
	// Consiste Parametrizacao do Intervalo de Impressao            
	//----------------------------------------------------------------
	If (SRA->RA_NOME < MV_PAR09)    .Or. (SRA->Ra_NOME > MV_PAR10)    .Or. ;
		(SRA->RA_MAT < MV_PAR07)     .Or. (SRA->Ra_MAT > MV_PAR08)     .Or. ;
		(SRA->RA_CC < MV_PAR05)       .Or. (SRA->Ra_CC > MV_PAR06)
		
		SRA->(dbSkip(1))
		Loop

	EndIf

	_aLanca:={}         // Zera Lancamentos
	_aProve:={}         // Zera Lancamentos
	_aDesco:={}         // Zera Lancamentos
	_aBases:={}         // Zera Lancamentos
	_nAteLim := _nBaseFgts := _nFgts := _nBaseIr := _nBaseIrFe := _nDedDep := 0.00
	_dDataPg := Ctod("  /  /  ")
	
	//----------------------------------------------------------------
	// Consiste situacao e categoria dos funcionarios			     |
	//----------------------------------------------------------------
	If !( SRA->RA_SITFOLH $ MV_PAR11 ) .OR.  ! ( SRA->RA_CATFUNC $ MV_PAR12 )

		SRA->(dbSkip())
		Loop

	Endif          
	                                                        
	If SRA->RA_SITFOLH $ "D" .And. SUBSTR(DTOS(SRA->RA_DEMISSA),1,6) < ALLTRIM(MV_PAR01)

		SRA->(dbSkip())
		Loop

	Endif
	
	//----------------------------------------------------------------
	// Consiste controle de acessos e filiais validas				 |
	//----------------------------------------------------------------
    If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(_cAcessaSRA)

       SRA->(dbSkip())
       Loop

    EndIf


	//----------------------------------------------------------------
	// Verifica se satisfaz a condicao de filtro do usuario         
	//----------------------------------------------------------------
	If _cFilSRA # Nil .And. !Empty(_cFilSRA) .And. !&_cFilSRA

		SRA->(dbSkip())
		Loop

	Endif

	//----------------------------------------------------------------
	//Consiste que o funcionário tem conta no banco itau
	//----------------------------------------------------------------
	If !( substr(alltrim(SRA->RA_BCDEPSA),1,3) == '341' )
		SRA->(dbSkip())
		Loop
	Endif


	If SRA->RA_CC #_cCcAnt                   // Centro de Custo

		MGPE012C(Sra->Ra_Cc,Sra->Ra_Filial)
		_cCcAnt:=SRA->RA_CC

	Endif
			
	/*
	==================================
	MV_PAR03
	1 - Adto
	2 - Folha
	3 - 1a.Parcela
	4 - 2a.Parcela
	5 - Valores Extras
	==================================
	*/
	
	If MV_PAR03 == 1 .OR. MV_PAR03 == 2
		
	  _CROT := IIF(MV_PAR03==1,'ADI','FOL')
		
	  //Verifica se tem no SRC
	  SRC->(Dbsetorder(4)) //RC_FILIAL+RC_MAT+RC_PERIODO+RC_ROTEIR+RC_SEMANA+RC_PD     

	  If SRC->(Dbseek(SRA->RA_FILIAL+SRA->RA_MAT+ALLTRIM(MV_PAR01)+_CROT))
		                                                                                                      
		
		SRC->(Dbsetorder(1))
		
		
		If SRC->(dbSeek(SRA->RA_FILIAL + SRA->RA_MAT))
			
			While !(SRC->(Eof())) .And. SRC->RC_FILIAL+SRC->RC_MAT == SRA->RA_FILIAL+SRA->RA_MAT
			    
			    If !Eval(_cAcessaSRC)
			    
			       SRC->(dbSkip())
			       Loop
			    
			    EndIf
			    
			    If  SRC->RC_ROTEIR != _CROT
		    
					SRC->(dbSkip())
					Loop
			    
				EndIf
				
				If (MV_PAR03 == 1) .And. (Src->Rc_Pd == _aCodFol[7,1])      // Desconto de Adto
				
					MGPE012S("P",_aCodFol[6,1],SRC->RC_HORAS,SRC->RC_VALOR)
					_nTotvenc += Src->Rc_Valor
					
				Elseif (MV_PAR03 == 1) .And. (Src->Rc_Pd == _aCodFol[12,1])
				
					MGPE012S("D",_aCodFol[9,1],SRC->RC_HORAS,SRC->RC_VALOR)
					_nTotdesc += SRC->RC_VALOR
					
				Elseif (MV_PAR03 == 1) .And. (Src->Rc_Pd == _aCodFol[8,1])
				
					MGPE012S("P",_aCodFol[8,1],SRC->RC_HORAS,SRC->RC_VALOR)
					_nTotvenc += SRC->RC_VALOR
					
				Else
				
					If PosSrv( Src->Rc_Pd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
					
						If (MV_PAR03 #1) .Or. (MV_PAR03 == 1 .And. PosSrv(Src->Rc_Pd,Sra->Ra_Filial,"RV_ADIANTA") == "S")
						
							MGPE012S("P",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
							_nTotvenc += Src->Rc_Valor
							
						Endif
						
					Elseif PosSrv( Src->Rc_Pd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"
					
						If (MV_PAR03 #1) .Or. (MV_PAR03 == 1 .And. PosSrv(Src->Rc_Pd,Sra->Ra_Filial,"RV_ADIANTA") == "S")
						
							MGPE012S("D",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
							_nTotdesc += Src->Rc_Valor
							
						Endif
						
					Elseif PosSrv( Src->Rc_Pd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "3"
					
						If (MV_PAR03 #1) .Or. (MV_PAR03 == 1 .And. PosSrv(Src->Rc_Pd,Sra->Ra_Filial,"RV_ADIANTA") == "S")
						
							MGPE012S("B",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
							
						Endif
						
					Endif
					
				Endif
				
				If MV_PAR03 = 1  
				  		   
					If SRC->RC_PD == _aCodFol[10,1]
					
						_nBaseIr := SRC->RC_VALOR
					   _dDataPg := SRC->RC_DATA
					   
					Endif
					
				ElseIf SRC->RC_PD == _aCodFol[13,1]
				
					_nAteLim += SRC->RC_VALOR
					
				Elseif SRC->RC_PD$ _aCodFol[108,1]+'*'+_aCodFol[17,1]
				
					_nBaseFgts += SRC->RC_VALOR
					
				Elseif SRC->RC_PD$ _aCodFol[109,1]+'*'+_aCodFol[18,1]
				
					_nFgts += SRC->RC_VALOR
					
				Elseif SRC->RC_PD == _aCodFol[15,1]
				
					_nBaseIr += SRC->RC_VALOR
					
				Elseif SRC->RC_PD == _aCodFol[16,1]
				
					_nBaseIrFe += SRC->RC_VALOR
					
              ElseIf SRC->RC_PD = _aCodFol[59,1]
                
                  _nDedDep += SRC->RC_VALOR
                    
              ElseIf SRC->RC_PD = _aCodFol[47,1]
                
                  _dDataPg := SRC->RC_DATA  
                      
              Elseif SRC->RC_PD == _aCodFol[47,1]
                
              	_nLiquido := SRC->RC_VALOR
               		
				Endif
				
				dbSelectArea("SRC")
				SRC->(dbSkip())
				
			Enddo
			
		Endif
		
	  Else
	  
	    //Procura no SRD
	    SRD->(Dbsetorder(1)) //RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ+RD_CC                                                                                                         
		
		_CROT := IIF(MV_PAR03==1,'ADI','FOL')
		
		If SRD->(dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + ALLTRIM(MV_PAR01)))
			
			While !(SRD->(Eof())) .And. SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_DATARQ == SRA->RA_FILIAL+SRA->RA_MAT+ALLTRIM(MV_PAR01)
			    
			    If  SRD->RD_ROTEIR != _CROT
			    
			       SRD->(dbSkip())
			       Loop
			    
			    EndIf
				
				If (MV_PAR03 == 1) .And. (SRD->RD_Pd == _aCodFol[7,1])      // Desconto de Adto
				
					MGPE012S("P",_aCodFol[6,1],SRD->RD_HORAS,SRD->RD_VALOR)
					_nTotvenc += SRD->RD_Valor
					
				Elseif (MV_PAR03 == 1) .And. (SRD->RD_Pd == _aCodFol[12,1])
				
					MGPE012S("D",_aCodFol[9,1],SRD->RD_HORAS,SRD->RD_VALOR)
					_nTotdesc += SRD->RD_VALOR
					
				Elseif (MV_PAR03 == 1) .And. (SRD->RD_Pd == _aCodFol[8,1])
				
					MGPE012S("P",_aCodFol[8,1],SRD->RD_HORAS,SRD->RD_VALOR)
					_nTotvenc += SRD->RD_VALOR
					
				Else
				
					If PosSrv( SRD->RD_Pd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
					
						If (MV_PAR03 #1) .Or. (MV_PAR03 == 1 .And. PosSrv(SRD->RD_Pd,Sra->Ra_Filial,"RV_ADIANTA") == "S")
						
							MGPE012S("P",SRD->RD_PD,SRD->RD_HORAS,SRD->RD_VALOR)
							_nTotvenc += SRD->RD_Valor
							
						Endif
						
					Elseif PosSrv( SRD->RD_Pd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"
					
						If (MV_PAR03 #1) .Or. (MV_PAR03 == 1 .And. PosSrv(SRD->RD_Pd,Sra->Ra_Filial,"RV_ADIANTA") == "S")
						
							MGPE012S("D",SRD->RD_PD,SRD->RD_HORAS,SRD->RD_VALOR)
							_nTotdesc += SRD->RD_Valor
							
						Endif
						
					Elseif PosSrv( SRD->RD_Pd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "3"
					
						If (MV_PAR03 #1) .Or. (MV_PAR03 == 1 .And. PosSrv(SRD->RD_Pd,Sra->Ra_Filial,"RV_ADIANTA") == "S")
						
							MGPE012S("B",SRD->RD_PD,SRD->RD_HORAS,SRD->RD_VALOR)
							
						Endif
						
					Endif
					
				Endif
				
				If MV_PAR03 = 1  
				  		   
					If SRD->RD_PD == _aCodFol[10,1]
					
						_nBaseIr := SRD->RD_VALOR
					   _dDataPg := SRD->RD_DATPGT
					   
					Endif
					
				ElseIf SRD->RD_PD == _aCodFol[13,1]
				
					_nAteLim += SRD->RD_VALOR
					
				Elseif SRD->RD_PD$ _aCodFol[108,1]+'*'+_aCodFol[17,1]
				
					_nBaseFgts += SRD->RD_VALOR
					
				Elseif SRD->RD_PD$ _aCodFol[109,1]+'*'+_aCodFol[18,1]
				
					_nFgts += SRD->RD_VALOR
					
				Elseif SRD->RD_PD == _aCodFol[15,1]
				
					_nBaseIr += SRD->RD_VALOR
					
				Elseif SRD->RD_PD == _aCodFol[16,1]
				
					_nBaseIrFe += SRD->RD_VALOR
					
              ElseIf SRD->RD_PD = _aCodFol[59,1]
                
                  _nDedDep += SRD->RD_VALOR
                    
              ElseIf SRD->RD_PD = _aCodFol[47,1]
                
                  _dDataPg := SRD->RD_DATPGT 
                      
              Elseif SRD->RD_PD == _aCodFol[47,1]
                
              	_nLiquido := SRD->RD_VALOR
               		
				Endif
				
				dbSelectArea("SRD")
				SRD->(dbSkip())
				
			Enddo
			
		Endif
	    
	  Endif
	
	/*
	==================================
	MV_PAR03
	1 - Adto
	2 - Folha
	3 - 1a.Parcela
	4 - 2a.Parcela
	5 - Valores Extras
	==================================
	*/
		
	Elseif MV_PAR03 == 3
	              
		dbSelectArea("SRC")
		If SRC->(dbSeek(SRA->RA_FILIAL + SRA->RA_MAT))
		
			While !(SRC->(Eof())) .And. SRA->RA_FILIAL + SRA->RA_MAT == SRC->RC_FILIAL + SRC->RC_MAT
			
			    If !Eval(_cAcessaSRC) .OR. alltrim(SRC->RC_ROTEIR) != '131'
			    
			       SRC->(dbSkip())
			       Loop
			       
			    EndIf
				If SRC->RC_PD == _aCodFol[22,1]
				
					MGPE012S("P",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
					_nTotvenc += SRC->RC_VALOR
					
				Elseif SRC->RC_PD == _aCodFol[172,1]
				
					MGPE012S("D",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
					_nTotdesc += SRC->RC_VALOR
					
				Elseif SRC->RC_PD == _aCodFol[108,1] .Or. SRC->RC_PD == _aCodFol[109,1] .Or. SRC->RC_PD == _aCodFol[173,1] 
				
					MGPE012S("B",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
					
				Endif
				
				If SRC->RC_PD == _aCodFol[108,1]
				
					_nBaseFgts := SRC->RC_VALOR
					
				Elseif SRC->RC_PD == _aCodFol[109,1]
				
					_nFgts     := SRC->RC_VALOR
					
              ElseIf SRC->RC_PD == _aCodFol[22,1]
                
                  _dDataPg := SRC->RC_DATA
                    
				Endif
                
              If SRC->RC_PD == _aCodFol[047,1]
              
					_nLiquido := SRC->RC_VALOR
					
				Endif           

				dbSelectArea("SRC")
				SRC->(dbSkip())
				
			Enddo
			
		Endif
		
	Elseif MV_PAR03 == 4  
	   
		dbSelectArea("SRC")
		SRC->(dbSetOrder(2))
		
		If SRC->(dbSeek(SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT))
		
			While !(SRC->(Eof())) .And. SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT == SRC->RC_FILIAL + SRC->RC_CC + SRC->RC_MAT
			
			    If !Eval(_cAcessaSRC) .OR. alltrim(SRC->RC_ROTEIR) != '132'
			    
			       SRC->(dbSkip())
			       Loop
			       
			    EndIf
			    
				If PosSrv( SRC->RC_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
				
					MGPE012S("P",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
					_nTotvenc = _nTotvenc + SRC->RC_VALOR
					
				Elseif PosSrv( SRC->RC_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"
				
					MGPE012S("D",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
					_nTotdesc = _nTotdesc + SRC->RC_VALOR
					
				Elseif PosSrv( SRC->RC_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "3"
				
					MGPE012S("B",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
					
				Endif

				If SRC->RC_PD == _aCodFol[19,1]
				
					_nAteLim += SRC->RC_VALOR
					
				Elseif SRC->RC_PD$ _aCodFol[108,1]
				
					_nBaseFgts += SRC->RC_VALOR
					
				Elseif SRC->RC_PD$ _aCodFol[109,1]
				
					_nFgts += SRC->RC_VALOR
					
				Elseif SRC->RC_PD == _aCodFol[27,1]
				
					_nBaseIr += SRC->RC_VALOR
					
				Elseif SRC->RC_PD == _aCodFol[62,1]
				
					_nDedDep += SRC->RC_VALOR
					
				Elseif SRC->RC_PD == _aCodFol[21,1]
				
				    _dDataPg := SRC->RC_DATA
				    
				Elseif SRC->RC_PD == _aCodFol[21,1]
				
               		_nLiquido := SRC->RC_VALOR
               		
				Endif
				
				SRC->(dbSkip())
				
			Enddo
			
		Endif
		
	Elseif MV_PAR03 == 5 
	   
		dbSelectArea("SR1")
		SR1->(dbSetOrder(1))
		If SR1->(dbSeek( SRA->RA_FILIAL + SRA->RA_MAT ))
		
			While !(SR1->(Eof())) .And. SRA->RA_FILIAL + SRA->RA_MAT ==	SR1->R1_FILIAL + SR1->R1_MAT
			
			    If !Eval(_cAcessaSR1)
			    
			       SR1->(dbSkip())
			       Loop
			       
			    EndIf
			    
				If PosSrv( SR1->R1_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
				
					MGPE012S("P",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR)
					_nTotvenc = _nTotvenc + SR1->R1_VALOR
					
				Elseif PosSrv( SR1->R1_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"
				
					MGPE012S("D",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR)
					_nTotdesc = _nTotdesc + SR1->R1_VALOR
					
				Elseif PosSrv( SR1->R1_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "3"
				
					MGPE012S("B",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR)
					
				Endif
				
				SR1->(dbskip())
				
			Enddo
			
		Endif
		
	Endif
	
	dbSelectArea("SRA")
	
	If _nTotvenc = 0 .And. _nTotdesc = 0
	
		SRA->(dbSkip())
		Loop
		
	Endif
    
	MGPE012I()   // Impressao do Recibo de Pagamento
   
	dbSelectArea("SRA")
	SRA->(dbSkip())
	_nTotdesc := _nTotvenc := 0
	
ENDDO

cLin6 := '34100015'+Space(9)+StrZero(_aTotLote[1]+1,6)+'000'+If((_nTotalLiq)==Int(_nTotalLiq),StrZero(_nTotalLiq,13)+'00',StrZero(Val(Replace(Transform(_nTotalLiq,"@E 9999999.99"),',','')),15))+'000000000000000000'

cLin7 := '34199999'+Space(9)+'000001'+StrZero(_aTotLote[1]+3,6)

_aTotLote[1]++


MGPE012G(cLin6,240)
MGPE012G(cLin7,240)
	 

//----------------------------------------------------------------
// Seleciona arq. defaut do Siga caso Imp. Mov. Anteriores      
//----------------------------------------------------------------
If !Empty( _cAliasMov )

	fFimArqMov( _cAliasMov , _aOrdBag , _cArqMov )
	
EndIf


//----------------------------------------------------------------
// Termino do relatorio                                         
//----------------------------------------------------------------

Fclose(_nHandle)

dbSelectArea("SRC")
dbSetOrder(1)          // Retorno a ordem 1
dbSelectArea("SRC")
dbSetOrder(1)          // Retorno a ordem 1
dbSelectArea("SRA")
SET FILTER TO
RetIndex("SRA")

If !(Type("cArqNtx") == "U")

	fErase(cArqNtx + OrdBagExt())
	
Endif

//Se não tem valores a pagar apaga o arquivo gerado
If _ngravados == 0 

	ferase(Alltrim(alltrim(MV_PAR04)+ALLTRIM(CFILANT)+"_PGTOITAU.REM"))
	
Else

     aadd(_aresults,{cfilant,"Totais da Filial:","   ",strzero(_ngravados,6) + " funcionários","Conta pagadora: " + _cagencia + " - " + _cconta + "/" + _cdigito ,;
							" "," ",Transform(_ntotais,"@E 9999999.99")," "})
							
     _ntotais := 0


Endif


/*
===============================================================================================================================
Programa----------: MGPE012I
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/08/2015
===============================================================================================================================
Descrição---------: IMRESSAO DO RECIBO FORMULARIO CONTINUO
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MGPE012I()

Local _nConta
Local _nMaxReg 
Local _nValIR := 0
Local _nPosAd

If MV_PAR03 == 2

	IF (_nPosAd := Ascan(_aLanca,{ |x| x[2] == _cCodAdto}))>0
	
		If (nPos := Ascan(_aBases,{ |x| _cCodBaseAd $ x[1]})) > 0
		
			_nValIR := _aBases[nPos,3]
			_aLanca[_nPosAd,5] -= _nValIR
			aAdd(_aLanca,{"D",_cCodBaseAd,Substr(_aBases[nPos,1],5,20),0,_nValIR})
			
		EndIf
		
	EndIf
	
EndIf

MGPE012H()       // Header do funcionário

_nMaxReg := If ( len(_aLanca) > 35,35,Len(_aLanca))                                                                         

For _nConta = 1 To _nMaxReg

	MGPE012N(_nConta)
	
Next

If _nLiquido == 0

   _nLiquido := _nTotvenc -_nTotdesc
   
EndIf

_aTotLote[1]++

_nSeqd := 0

_nTotVct += _nTotVenc    
_nTotDes += _nTotDesc  
        
If (_nTotVenc-_nTotDesc) > 0

	_nTotLiq += _nTotVenc - _nTotDesc 
	    
Endif

Return Nil
  
/*
===============================================================================================================================
Programa----------: MGPE012M
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/08/2015
===============================================================================================================================
Descrição---------: Impressao cabecalho
===============================================================================================================================
Parametros--------: 	
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/
Static Function MGPE012M()   // Cabecalho do Recibo()

Local _cLin0 := ""
Local _cLin1 := ""

_nSeq ++        
_aTotLote[1]++

dbSelectArea("SM0") 
dbSelectArea("SEE")

If _cagenciam == _cagencia .and. _cconta == _ccontam

	_ccnpj := _ccnpjm

Else

	_ccnpj := StrZero(Val(SM0->M0_CGC),14)

Endif


_cLin0 := '34100000      080'+If(SM0->M0_TPINSC=2,'2','1')+_ccnpj+Space(20)+STRZERO(VAL(ALLTRIM(_cagencia)),5)+Space(1)+STRZERO(VAL(ALLTRIM(_cconta)),12)+Space(1)+ALLTRIM(_cdigito)+ ;
		"GOIASMINAS IND LATICINIOS LTDA"+'BANCO ITAU'+Space(30)+'1'+GRAVADATA(DDATABASE,.F.,5)+SUBST(TIME(),1,2)+SUBST(TIME(),4,2)+SUBST(TIME(),7,2)+'00000000000000' 

_cLin1 := '34100011C3001040 '+If(SM0->M0_TPINSC=2,'2','1')+_ccnpj+Space(20)+STRZERO(VAL(ALLTRIM(_cagencia)),5)+Space(1)+STRZERO(VAL(ALLTRIM(_cconta)),12)+Space(1)+ALLTRIM(_cdigito)+ ;
		"GOIASMINAS IND LATICINIOS LTDA"+'01'+Space(38)+SubStr(SM0->M0_ENDCOB,1,30)+StrZero(VAL(Substr(SM0->M0_ENDCOB, AT(',',SM0->M0_ENDCOB)+1,5)),5)+Substr(SM0->M0_COMPCOB,1,15)+Substr(SM0->M0_CIDCOB,1,20)+Substr(SM0->M0_CEPCOB,1,8)+ ;
		Substr(SM0->M0_ESTCOB,1,2)+Space(8)	 

MGPE012G(_cLin0,240)
MGPE012G(_cLin1,240)

Return Nil

/*
===============================================================================================================================
Programa----------: MGPE012H
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/08/2015
===============================================================================================================================
Descrição---------: Monta Header do funcionario
===============================================================================================================================
Parametros--------: 	
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/
Static Function MGPE012H()   


Local _cFuncao := LEFT(Posicione("SRJ",1,xFilial("SRJ")+SRA->RA_CODFUNC,"RJ_DESC")+SPACE(50),50)
Local _cLin2 := ""
Local _cLin3 := ""

_nSeqFun ++
_ngravados++

_aTotLote[1]++
//Header - Funcionário (Registro Tipo 1)      

_cLin2 := '34100013'+StrZero(_nSeqFun,5)+'A001000'+SubStr(RA_BCDEPSA,1,3)+StrZero(VAL(SubStr(RA_BCDEPSA,4,5)),5)+Space(1)+ ;
			STRZERO(VAL(SUBSTR(ALLTRIM(RA_CTDEPSA),1,LEN(ALLTRIM(RA_CTDEPSA))-1)),12)+SPACE(1)+SubStr(RA_CTDEPSA,Len(ALLTRIM(RA_CTDEPSA)),1)+PADR(RA_NOME,30,'')+PADR(RA_MAT,20,'')+SubStr(DtoS(MV_PAR13),7,2)+SubStr(DtoS(MV_PAR13),5,2)+SubStr(DtoS(MV_PAR13),1,4)+ ;
   			'REA'+'000000000000000000000000000000'+ ;
   			'                    00000000000000000000000'+'                    '+'000000'+STRZERO(VAL(PADL(RA_CIC,14)),14)+'            0'   	            	                    

_nTotalLiq := 0

_cLin3 := '34100013'+StrZero(_nSeqFun,5)+'D   '+ SUBSTR(MV_PAR01,5,2) + SUBSTR(MV_PAR01,1,4) + ;
   			MGPE012C(Sra->Ra_Cc,Sra->Ra_Filial)+PADR(RA_MAT,10,'')+SubStr(_cFuncao,1,30)+'00000000000000000'+ ;
   			If(ALLTRIM(SubStr(RA_DEPIR,2,1))=='','0',ALLTRIM(SubStr(RA_DEPIR,2,1)))+'0'+ ;
   			If(ALLTRIM(SubStr(RA_DEPSF,2,1))=='','0',ALLTRIM(SubStr(RA_DEPSF,2,1)))+ALLTRIM(STR(INT(RA_HRSEMAN)))+ ;
   			If(_nAteLim==Int(_nAteLim),StrZero(_nAteLim,13)+'00',StrZero(Val(Replace(Transform(_nAteLim,"@E 9999999.99"),',','')),15))+ ;
   			If(_nFgts==Int(_nFgts),StrZero(_nFgts,13)+'00',StrZero(Val(Replace(Transform(_nFgts,"@E 9999999.99"),',','')),15))+	;
   			If(_nTotvenc==Int(_nTotvenc),StrZero(_nTotvenc,13)+'00',StrZero(Val(Replace(Transform(_nTotvenc,"@E 9999999.99"),',','')),15))+ ;
   			If(_nTotdesc==Int(_nTotdesc),StrZero(_nTotdesc,13)+'00',StrZero(Val(Replace(Transform(_nTotdesc,"@E 9999999.99"),',','')),15))+ ;
   			If((_nTotvenc-_nTotdesc)==Int(_nTotvenc-_nTotdesc),StrZero(_nTotvenc-_nTotdesc,13)+ ;
   			'00',StrZero(Val(Replace(Transform(_nTotvenc-_nTotdesc,"@E 9999999.99"),',','')),15))+ ;
   			If((RA_SALARIO)==Int(RA_SALARIO),StrZero(RA_SALARIO,13)+'00',StrZero(Val(Replace(Transform(RA_SALARIO,"@E 9999999.99"),',','')),15))+ ;
   			If((_nBaseIr)==Int(_nBaseIr),StrZero(_nBaseIr,13)+'00',StrZero(Val(Replace(Transform(_nBaseIr,"@E 9999999.99"),',','')),15))+ ;
   			If((_nBaseFgts)==Int(_nBaseFgts),StrZero(_nBaseFgts,13)+'00',StrZero(Val(Replace(Transform(_nBaseFgts,"@E 9999999.99"),',','')),15))+'01'
   			
aadd(_aresults,{cfilant,MGPE012C(Sra->Ra_Cc,Sra->Ra_Filial),RA_MAT,SubStr(RA_NOME,1,30),SubStr(_cFuncao,1,30),Transform(_nTotvenc,"@E 9999999.99"),Transform(_nTotdesc,"@E 9999999.99"),;
				Transform(_nTotvenc-_nTotdesc,"@E 9999999.99"),Transform(RA_SALARIO,"@E 9999999.99")})
				
_ntotais := _ntotais + _nTotvenc-_nTotdesc
   
MGPE012G(_cLin2,240)                    
MGPE012G(_cLin3,240)

Return Nil

/*
===============================================================================================================================
Programa----------: MGPE012N
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/08/2015
===============================================================================================================================
Descrição---------: Impressao das Verbas (Lancamentos) Form. Continuo 
===============================================================================================================================
Parametros--------: 	_nConta - verba no formato "Pnnnnnn" (Provento) ou "Dnnnnnn" (Desconto)
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/

Static Function MGPE012N(_nConta)   // Impressao dos Lancamentos()

Local _cTip := ""
Local _cTipr := ""
Local _cDet := ""


If _aLanca[_nConta,1] == "P"  /*Provento*/

   _cTip := "1" 
   
ElseIf _aLanca[_nConta,1] == "D"  /*Desconto*/

   _cTip := "2" 
   
EndIf   

If _aLanca[_nConta,4] == 00000

   _cTipr := "DIAS     "
   
Else

   _cTipr := "HORAS    "
   
EndIf   

If _aLanca[_nConta,1] # "B"

   _aTotLote[1]++
   _nSeqd ++                    

   _cDet := "34100013"+StrZero(_nSeqFun,5)+"E   "+_cTip+PADR(_aLanca[_nConta,3],23,'')+PADR(_aLanca[_nConta,4],7,'')+Space(5)+ ;
   			If(_aLanca[_nConta,5] = 0,"000000000",Strzero(_aLanca[_nConta,5]*100,15))+Space(35)+"000000000000000"+ ;
   			Space(35)+"000000000000000"+Space(35)+"000000000000000"+Space(22)


	MGPE012G(_cDet,240)
	
EndiF

Return Nil


/*
===============================================================================================================================
Programa----------: MGPE012S
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/08/2015
===============================================================================================================================
Descrição---------: Somar as verbas no array
===============================================================================================================================
Parametros--------: 	_cTipo - P provento, D desconto, B base
						_cPd - Verba
						_nHoras - quantidade de horas
						_nValor - valor da verba
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/

Static Function MGPE012S(_cTipo,_cPd,_nHoras,_nValor)

Local _cDesc_Paga := DescPd(_cPd,Sra->Ra_Filial)  // mostra como pagto
Local _cArray := ""

If _cTipo #'B'

    //--Array para Recibo Pre-Impresso
    nPos := Ascan(_aLanca,{ |X| X[2] = _cPd })
    
    If nPos == 0
    
        Aadd(_aLanca,{_cTipo,_cPd,_cDesc_Paga,_nHoras,_nValor})
        
    Else
    
       _aLanca[nPos,4] += _nHoras
       _aLanca[nPos,5] += _nValor
       
    Endif
    
Endif

//--Array para o Recibo Pre-Impresso
If _cTipo = 'P'

   _cArray := "_aProve"
   
Elseif _cTipo = 'D'

   _cArray := "_aDesco"
   
Elseif _cTipo = 'B'

   _cArray := "_aBases"
   
Endif

nPos := Ascan(&_cArray,{ |X| X[1] = _cPd })

If nPos == 0

    Aadd(&_cArray,{_cPd+" "+_cDesc_Paga,_nHoras,_nValor })
    
Else

    &_cArray[nPos,2] += _nHoras
    &_cArray[nPos,3] += _nValor
    
Endif

Return


/*
===============================================================================================================================
Programa----------: MGPE012G
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/08/2015
===============================================================================================================================
Descrição---------: Grava registro no arquivo texto
===============================================================================================================================
Parametros--------: 	cRegistro - string a ser gravada
						nbytes - tamanho da linha
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/
Static Function MGPE012G( _cRegistro, _nbytes )

Local _cMsg

_cRegistro := Left(_cRegistro+Space(_nBytes),_nBytes)+CHR(13)+CHR(10)

Fwrite(_nHandle,_cRegistro,Len(_cRegistro))

If Ferror() # 0

	_cMsg := "Erro de gravacao, codigo DOS:" + STR(Ferror(),2) 
	Help(" ",1, , ,_cMsg )
	Return (.F.)
	
Endif

Return 

/*
===============================================================================================================================
Programa--------: MGPE012C
Autor-----------: Josué Danich Prestes
Data da Criacao-: 09/11/2017
===============================================================================================================================
Descrição-------: Retorna descrição do centro de custo com 20 caracteres
===============================================================================================================================
Parametros------: _Ccc - Código do centro de custo
				  _cfilial - filial do centro de custo
===============================================================================================================================
Retorno---------: _cret - descrição do centro de custo
===============================================================================================================================
*/
Static Function MGPE012C( _Ccc,_cfilial )

Local _cret := ""

_cret := substr(DescCC(_Ccc,_cfilial),1,20)

Return _cret
