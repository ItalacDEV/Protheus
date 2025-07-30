/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/09/2019 | Chamado 28346. Retirada chamada da função itputx1
Lucas Borges  | 02/10/2019 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25
Lucas Borges  | 22/04/2025 | Chamado 50505. Alterada a picture do CNPJ para contemplar campo alfanumérico
===============================================================================================================================
*/

#include "rwmake.ch"

/*
===============================================================================================================================
Programa----------: MGPE013
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/08/2015
Descrição---------: Geracao Arquivo de Recibos de Pagamento - BB
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGPE013()

Private _cPerg     	:= 'MGPE013'
Private _cLin		:= ''
Private _nQtFunc	:= 0
Private _nHdl		:= 0
Private _lLiq		:= .F.
Private _lData		:= .F.
Private _lHeader	:= .F.
Private _lContinua	:= .T.
Private _oGeraTxt
Private _nTotais 	:= 0

pergunte(_cPerg,.F.)

dbSelectArea( "SRA" )
SRA->(dbSetOrder(1))

//-----------------------------------------------------------------------
// Montagem da tela de processamento.                                  
//-----------------------------------------------------------------------
@ 200,001 TO 410,480 DIALOG _oGeraTxt TITLE OemToAnsi( "Geracao do Arquivo de Pagamento" )
@ 002,010 TO 095,230
@ 010,018 Say " Este programa ira gerar o arquivo de demonstrativo de pagamento    "
@ 018,018 Say " para o Banco do Brasil.	 						   "
@ 026,018 Say "                                                                    "

@ 070,128 BMPBUTTON TYPE 05 ACTION Pergunte(_cPerg,.T.)
@ 070,158 BMPBUTTON TYPE 01 ACTION MGPE013O()
@ 070,188 BMPBUTTON TYPE 02 ACTION Close(_oGeraTxt)

Activate Dialog _oGeraTxt Centered

Return

/*
===============================================================================================================================
Programa----------: MGPE013O
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/08/2015
Descrição---------: Funcao chamada pelo botao OK na tela inicial de processamento. Executa a geracao do arquivo texto.    
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MGPE013O

Local _cfilloc
Local _ni
Local _lachou := .F.

Private _afils := {}
Private _aresults := {}
Private _cconta
Private _cagencia
Private _cdigito
Private _nrecno

//Grava log de utilização
u_itlogacs()

//Roda loop de filiais
If empty(MV_PAR11)
	
	_cfilloc := cfilant
		
	SM0->(Dbgotop())
		
	Do while !(SM0->(EOF()))
		
		aadd(_afils,ALLTRIM(SM0->M0_CODFIL))
		SM0->(Dbskip())
		
	Enddo
	SM0->(DBSeek('01' + cfilant))
	
Else
	
	_afils := {}
	_afils2 := {}
	
	If !empty(MV_PAR11)
	
		_afils := StrTokArr(MV_PAR11,";")
		
	Endif
	
	If !empty(MV_PAR12)
	
		_afils2 := StrTokArr(MV_PAR12,";")
		
	Endif
	
	For _ni := 1 to len(_afils2)
	
		aadd(_afils,_afils2[_ni])
		
	Next _ni
	
	_cfilloc := cfilant
		
Endif
	
For _ni := 1 to len(_afils)
	
		cfilant := _afils[_ni]
		_lHeader := .F.
		
		//Pega parâmetro com dados da agencia, conta/digito pagadora
		_lachou := .F.
		RCC->(Dbsetorder(1))
		If RCC->(dbseek(xfilial("RCC")+"S052"+cfilant))
		
			Do while !(RCC->(Eof())) .and. RCC->RCC_FILIAL == xfilial("RCC") .and. RCC->RCC_CODIGO = "S052" .and. RCC->RCC_FIL = cfilant
			
			  If substr(RCC->RCC_CONTEU,21,3) == "001"
			  
			  	_lachou := .T.
			  	_cagencia := alltrim(substr(RCC->RCC_CONTEU,24,5))
			  	_cconta := alltrim(substr(RCC->RCC_CONTEU,30,12))
			  	_cdigito := alltrim(substr(RCC->RCC_CONTEU,42,1))
			  	_nrecno := RCC->(Recno())
			  	
			  	exit
			  	
			  Endif
			  
			  RCC->(Dbskip())
			  
			Enddo
			
		Endif
		
		If SM0->(DBSeek('01' + cfilant)) .and. _lachou
		
			_nQtFunc := 0 //Zera leituras de funcionarios
			fwmsgrun(,{|oproc| MGPE013R(oproc)},"Geracao do Arquivo Holerite","Processando dados...")  
				
		Endif
		
Next
	
cfilant := _cfilloc
SM0->(DBSeek('01' + cfilant))
	

//Apresenta resultados da gravação
if len(_aresults) > 0

	U_ITListBox( 'Dados gravados nos arquivos' , {"Filial","CC","Matricula","Nome","Vencimentos","Descontos","Liquido","Salário","Cons. Liquido","Situação"} , _aresults , .T. , 1 )
	u_itmsg("Arquivos Gerado com no Diretorio : " + MV_PAR03, "Processo Concluído",,2 )
	
Else

	u_itmsg("Não foram gerados arquivos!","Atenção",,1 )

Endif



Close(_oGeraTxt)

Return

/*
===============================================================================================================================
Programa----------: MGPE013R
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/08/2015
Descrição---------: Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA monta a janela com a regua de processamento.    
Parametros--------: oproc - objeto da barra de processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MGPE013R(oproc)

Local _cMesArqRef
Local _cAcessaSR1  := &("{ || " + ChkRH("GPER030","SR1","2") + "}")
Local _cAcessaSRA  := &("{ || " + ChkRH("GPER030","SRA","2") + "}")
Local _cAcessaSRC  := &("{ || " + ChkRH("GPER030","SRC","2") + "}")

//Variaveis para emissao do arquivo de ferias
Local _cDataBas	:= ""
Local _cDBaseAt	:= ""
Local _cDFerias	:= ""
Local _cDAbonPe	:= ""
Local _npos := 1
Local _nconta := 0
Local _cCodBco, _cCodAgenc, _cCodContaC, _lGravouArqTxt, _cTextoMsg, _cFilParam  

Private _cMesAnoRef
Private _cFinPgt, _nSequenc

Private _nTOTVENC, _nTOTDESC, _nFlag, _nChave
Private _cDesc_Fil, _cDesc_End, _cDESC_CGC, _cDESC_FUNC
Private _cFilialAnt, _cFuncaoAnt, _cCcAnt, _nVez, _nOrdemZ

Private _nAteLim, _nBaseFgts, _nFgts, _nBaseIr, _nBaseIrFe, _nLiquido

Private _aLanca := {}
Private _aProve := {}
Private _aDesco := {}
Private _aBases := {}
Private _aInfo  := {}
Private _aCodFol:= {}

Pergunte(_cPerg,.F.)
 
//----------------------------------------------------------------
// Cria o Arquivo TXT                                         
//----------------------------------------------------------------

_nHdl	:= MSFCREATE(Alltrim(MV_PAR03)+"BBHOL_" + cfilant +".REM")

IF Ferror() # 0 .AND. _nHdl = -1

	_cMsg := "Erro de abertura, codigo DOS:" + STR(FERROR(),2) 
	Aviso( "Atencao", _cMsg, { "OK" } ) 
    Return

EndIF


_cMesAnoRef := StrZero(Month(MV_PAR01),2) + StrZero(Year(MV_PAR01),4)
_cMesArqRef  := If(MV_PAR02 == 4,"13"+Right(_cMesAnoRef,4),_cMesAnoRef)


//----------------------------------------------------------------
//  Selecionando a Ordem de impressao escolhida no parametro.     
//----------------------------------------------------------------
dbSelectArea( "SI3" )
dbSetOrder(1)
dbSelectArea( "SRF" )
dbSetOrder(1)
dbSelectArea( "SRH" )
dbSetOrder(1)
dbSelectArea( "SRJ" )
dbSetOrder(1)
dbSelectArea( "SRR" )
dbSetOrder(1)
dbSelectArea( "SRA" )
dbSetOrder(1)

//----------------------------------------------------------------
// Carrega Regua Processamento                                  
//----------------------------------------------------------------
_nconta := RecCount()

SRA->(dbGoTop())

//----------------------------------------------------------------
//  Selecionando o Primeiro Registro e montando Filtro.           
//----------------------------------------------------------------
dbSeek(CFILANT + MV_PAR06,.T.)
_cCond := "SRA->RA_FILIAL + SRA->RA_MAT <= CFILANT + MV_PAR07"

dbSelectArea("SRA")
ProcRegua(RecCount())

_nTOTVENC    := _nTOTDESC   := _nFlag      := _nChave     := 0
_cDesc_Fil   := _cDesc_End  := _cDESC_CGC   := _cDESC_FUNC := ""
_cFilialAnt := "  "
_cFuncaoAnt := "    "
_cCcAnt     := Space(9)
_nVez        := 0
_nOrdemZ     := 0
_nSequenc   := 0

If MV_PAR02 == 1			// Adiantamento
	_cFinPgt := "02"
ElseIf MV_PAR02 == 2		// Folha
	_cFinPgt := "01"
ElseIf MV_PAR02 == 3		// 1a Parcela
	_cFinPgt := "04"
ElseIf MV_PAR02 == 4		// 2a Parcela
	_cFinPgt := "04"
ElseIf MV_PAR02	== 5		// Extras
	_cFinPgt := "10"
ElseIf MV_PAR02 == 6		// Ferias
	_cFinPgt := "07"
EndIf

If !(!(Fp_CodFol(@_aCodFol,cfilant)) .Or. ! (fInfo(@_aInfo,cfilant)))
	
	_cDesc_Fil := _aInfo[3]
	_cDesc_End := _aInfo[4]                // Dados da Filial
	_cDesc_CGC := _aInfo[8]
	_lcontinua := .T.
	
Else

	u_itmsg("Filial " + cfilant + " não possui dados de folha cadastrados", "Atenção","Filial não será processada",1) 
	_lcontinua := .F.
			
Endif


dbSelectArea("SRA")
Do While SRA->(!Eof()) .And. &_cCond .And. _lContinua

	//----------------------------------------------------------------
	// Movimenta Regua Processamento                                
	//----------------------------------------------------------------
  	IF valtype(oproc) = "O"

      	oproc:cCaption := ("Processando filial " + alltrim(cfilant) + " - Registro " + strzero(_npos,6) + " de " + strzero(_nconta,6) + "...")
   		ProcessMessages()
 
    ENDIF
  	_npos++

	
	If (SRA->RA_FILIAL   < CFILANT)  .Or. (SRA->RA_FILIAL   > CFILANT) .Or. ;
		(SRA->RA_CC       < MV_PAR04)   .Or. (SRA->RA_CC       > MV_PAR05)  .Or. ;
		(SRA->RA_MAT      < MV_PAR06)  .Or. (SRA->RA_MAT      > MV_PAR07)
		SRA->(dbSkip())
		Loop
	EndIf
	
	//-------------------------------------
	//  Verifica Data Demissao          
	//-------------------------------------
	_cSitFunc := SRA->RA_SITFOLH
	_dDtPesqAf:= CTOD("01/" + Left(_cMesAnoRef,2) + "/" + Right(_cMesAnoRef,4),"DDMMYY")
	If _cSitFunc == "D" .And. (!Empty(SRA->RA_DEMISSA) .And. MesAno(SRA->RA_DEMISSA) > MesAno(_dDtPesqAf))
		_cSitFunc := " "
	Endif
	
	//----------------------------------------------------------------
	//  Consiste situacao e categoria dos funcionarios			     |
	//----------------------------------------------------------------
	If !( _cSitFunc $ MV_PAR08) .OR.  ! ( SRA->RA_CATFUNC $ MV_PAR09)
		dbSkip()
		Loop
	Endif
	If _cSitFunc $ "D" .And. Mesano(SRA->RA_DEMISSA) # Mesano(MV_PAR01)
		dbSkip()
		Loop
	Endif
	
	//----------------------------------------------------------------
	//Consiste que o funcionário tem conta no banco do brasil
	//----------------------------------------------------------------
	If !( substr(alltrim(SRA->RA_BCDEPSA),1,3) == '001' )
		dbSkip()
		Loop
	Endif
	
	_aLanca  := {}
	_aProve  := {}
	_aDesco  := {}
	_aBases  := {}
	
	_cDataBas	:= ""
	_cDBaseAt	:= ""
	_cDFerias	:= ""
	_cDAbonPe	:= ""
	
	_nAteLim := _nBaseFgts := _nFgts := _nBaseIr := _nBaseIrFe := _nLiquido := 0.00
	
	//----------------------------------------------------------------
	//  Consiste controle de acessos e filiais validas		        |
	//----------------------------------------------------------------
	_cFilParam := fValidFil()  
	If Empty(_cFilParam)
	   _cFilParam := ""
	EndIf
	
	If !(SRA->RA_FILIAL $ _cFilParam) .Or. !Eval(_cAcessaSRA) // !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(_cAcessaSRA)
		SRA->(dbSkip())
		Loop
	EndIf
	
	If SRA->RA_CODFUNC # _cFuncaoAnt           // Descricao da Funcao
		DescFun(Sra->Ra_Codfunc,Sra->Ra_Filial)
		_cFuncaoAnt := Sra->Ra_CodFunc
	Endif
	
	If SRA->RA_CC # _cCcAnt                   // Centro de Custo
		DescCC(Sra->Ra_Cc,Sra->Ra_Filial)
		_cCcAnt := SRA->RA_CC
	Endif
		
	_nTotvenc := 0
	
	SI3->(dbSeek( xFilial("SI3",SRA->RA_FILIAL)+SRA->RA_CC ))
	SRJ->(dbSeek( xFilial("SRJ",SRA->RA_FILIAL)+SRA->RA_CODFUNC ))
	SRH->(dbSeek( xFilial("SRH",SRA->RA_FILIAL)+SRA->RA_MAT ))
	
	If MV_PAR02 == 1 .OR. MV_PAR02 == 2
		_CROT := IIF(MV_PAR02==1,'ADI','FOL')
		dbSelectArea("SRC")
		If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
			Do While !Eof() .And. SRC->RC_FILIAL+SRC->RC_MAT == SRA->RA_FILIAL+SRA->RA_MAT
				If !Eval(_cAcessaSRC) 
					dbSkip()
					Loop
				EndIf
				
				If  SRC->RC_ROTEIR != _CROT
		    
					SRC->(dbSkip())
					Loop
			    
				EndIf
	
				If (MV_PAR02 == 1) .And. (Src->Rc_Pd == _aCodFol[7,1])      // Desconto de Adto
					MGPE013S("P",_aCodFol[6,1],SRC->RC_HORAS,SRC->RC_VALOR)
					_nTOTVENC += Src->Rc_Valor
				Elseif (MV_PAR02 == 1) .And. (Src->Rc_Pd == _aCodFol[12,1])
					MGPE013S("D",_aCodFol[9,1],SRC->RC_HORAS,SRC->RC_VALOR)
					_nTOTDESC += SRC->RC_VALOR
				Elseif (MV_PAR02 == 1) .And. (Src->Rc_Pd == _aCodFol[8,1])
					MGPE013S("P",_aCodFol[8,1],SRC->RC_HORAS,SRC->RC_VALOR)
					_nTOTVENC += SRC->RC_VALOR
				Else
					If PosSrv( Src->Rc_Pd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
						If (MV_PAR02 #1) .Or. (MV_PAR02 == 1 .And. PosSrv(Src->Rc_Pd,Sra->Ra_Filial,"RV_ADIANTA") == "S")
							MGPE013S("P",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
							_nTOTVENC += Src->Rc_Valor
						Endif
					Elseif PosSrv( Src->Rc_Pd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"
						If (MV_PAR02 #1) .Or. (MV_PAR02 == 1 .And. PosSrv(Src->Rc_Pd,Sra->Ra_Filial,"RV_ADIANTA") == "S")
							MGPE013S("D",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
							_nTOTDESC += Src->Rc_Valor
						Endif
					Elseif PosSrv( Src->Rc_Pd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "3"
						If (MV_PAR02 #1) .Or. (MV_PAR02 == 1 .And. PosSrv(Src->Rc_Pd,Sra->Ra_Filial,"RV_ADIANTA") == "S")
							MGPE013S("B",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
						Endif
					Endif
				Endif 
				If MV_PAR02 = 1
					If SRC->RC_PD == _aCodFol[10,1]
						_nBaseIr := SRC->RC_VALOR
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
				Elseif SRC->RC_PD == _aCodFol[47,1]
					_nLiquido := SRC->RC_VALOR
				Endif
				dbSelectArea("SRC")
				dbSkip()
			Enddo
		
		Else
	
			_CROT := IIF(MV_PAR02==1,'ADI','FOL')
			_cdtref := alltrim(str(year(MV_PAR01))) + ALLTRIM(strzero(MONTH(MV_PAR01),2))
		
			If SRD->(dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + ALLTRIM(_cdtref)))
			
				Do While !(SRD->(Eof())) .And. SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_DATARQ == SRA->RA_FILIAL+SRA->RA_MAT+ALLTRIM(_cdtref)
					
					If  SRD->RD_ROTEIR != _CROT
			    
						SRD->(dbSkip())
						Loop
			    
					EndIf
				
					If (MV_PAR02 == 1) .And. (SRD->RD_Pd == _aCodFol[7,1])      // Desconto de Adto
						MGPE013S("P",_aCodFol[6,1],SRD->RD_HORAS,SRD->RD_VALOR)
						_nTOTVENC += SRD->RD_Valor
					Elseif (MV_PAR02 == 1) .And. (SRD->RD_Pd == _aCodFol[12,1])
						MGPE013S("D",_aCodFol[9,1],SRD->RD_HORAS,SRD->RD_VALOR)
						_nTOTDESC += SRD->RD_VALOR
					Elseif (MV_PAR02 == 1) .And. (SRD->RD_Pd == _aCodFol[8,1])
						MGPE013S("P",_aCodFol[8,1],SRD->RD_HORAS,SRD->RD_VALOR)
						_nTOTVENC += SRD->RD_VALOR
					Else
					
						If PosSrv( SRD->RD_Pd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
							If (MV_PAR02 #1) .Or. (MV_PAR02 == 1 .And. PosSrv(SRD->RD_Pd,Sra->Ra_Filial,"RV_ADIANTA") == "S")
								MGPE013S("P",SRD->RD_PD,SRD->RD_HORAS,SRD->RD_VALOR)
								_nTOTVENC += SRD->RD_Valor
							Endif
						Elseif PosSrv( SRD->RD_Pd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"
							If (MV_PAR02 #1) .Or. (MV_PAR02 == 1 .And. PosSrv(SRD->RD_Pd,Sra->Ra_Filial,"RV_ADIANTA") == "S")
								MGPE013S("D",SRD->RD_PD,SRD->RD_HORAS,SRD->RD_VALOR)
								_nTOTDESC += SRD->RD_Valor
							Endif
						Elseif PosSrv( SRD->RD_Pd , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "3"
							If (MV_PAR02 #1) .Or. (MV_PAR02 == 1 .And. PosSrv(SRD->RD_Pd,Sra->Ra_Filial,"RV_ADIANTA") == "S")
								MGPE013S("B",SRD->RD_PD,SRD->RD_HORAS,SRD->RD_VALOR)
							Endif
						Endif
					Endif 
					If MV_PAR02 = 1
						If SRD->RD_PD == _aCodFol[10,1]
							_nBaseIr := SRD->RD_VALOR
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
					Elseif SRD->RD_PD == _aCodFol[47,1]
						_nLiquido := SRD->RD_VALOR
					Endif
					dbSelectArea("SRD")
					dbSkip()
				Enddo
			Endif
		
		Endif
	
	Elseif MV_PAR02 == 3 
		dbSelectArea("SRC")
		If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
			Do While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SRC->RC_FILIAL + SRC->RC_MAT
				If !Eval(_cAcessaSRC) .OR. alltrim(SRC->RC_ROTEIR) != '131'
					dbSkip()
					Loop
				EndIf
				If SRC->RC_PD == _aCodFol[22,1]
					MGPE013S("P",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
					_nTOTVENC += SRC->RC_VALOR
				Elseif SRC->RC_PD == _aCodFol[172,1]
					MGPE013S("D",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
					_nTOTDESC += SRC->RC_VALOR
				Elseif SRC->RC_PD == _aCodFol[108,1] .Or. SRC->RC_PD == _aCodFol[109,1] .Or. SRC->RC_PD == _aCodFol[173,1]
					MGPE013S("B",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
				Endif
				
				If SRC->RC_PD == _aCodFol[108,1]
					_nBaseFgts := SRC->RC_VALOR
				Elseif SRC->RC_PD == _aCodFol[109,1]
					_nFgts     := SRC->RC_VALOR
				Endif
				dbSelectArea("SRC")
				dbSkip()
			Enddo
			_nLiquido := _nTOTVENC - _nTOTDESC
		Endif
	Elseif MV_PAR02 == 4
		dbSelectArea("SRC")
		dbSetOrder(2)
		If dbSeek(SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT)
			Do While !Eof() .And. SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT == SRC->RC_FILIAL + SRC->RC_CC + SRC->RC_MAT
				If !Eval(_cAcessaSRC) .OR. alltrim(SRC->RC_ROTEIR) != '132'
					dbSkip()
					Loop
				EndIf
				If PosSrv( SRC->RC_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
					MGPE013S("P",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
					_nTOTVENC = _nTOTVENC + SRC->RC_VALOR
				Elseif PosSrv( SRC->RC_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"
					MGPE013S("D",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
					_nTOTDESC = _nTOTDESC + SRC->RC_VALOR
				Elseif PosSrv( SRC->RC_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "3"
					MGPE013S("B",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
				Endif
				
				If SRC->RC_PD == _aCodFol[19,1]
					_nAteLim += SRC->RC_VALOR
				Elseif SRC->RC_PD$ _aCodFol[108,1]
					_nBaseFgts += SRC->RC_VALOR
				Elseif SRC->RC_PD$ _aCodFol[109,1]
					_nFgts += SRC->RC_VALOR
				Elseif SRC->RC_PD == _aCodFol[27,1]
					_nBaseIr += SRC->RC_VALOR
				Elseif SRC->RC_PD == _aCodFol[21,1]
					_nLiquido := SRC->RC_VALOR
				Endif
				dbSkip()
			Enddo
		Endif
	Elseif MV_PAR02 == 5
		dbSelectArea("SR1")
		dbSetOrder(1)
		If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
			Do While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT ==	SR1->R1_FILIAL + SR1->R1_MAT
				If !Eval(_cAcessaSR1)
					dbSkip()
					Loop
				EndIf
				If PosSrv( SR1->R1_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
					MGPE013S("P",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR)
					_nTOTVENC = _nTOTVENC + SR1->R1_VALOR
				Elseif PosSrv( SR1->R1_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"
					MGPE013S("D",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR)
					_nTOTDESC = _nTOTDESC + SR1->R1_VALOR
				Elseif PosSrv( SR1->R1_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "3"
					MGPE013S("B",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR)
				Endif
				dbskip()
			Enddo
			_nLiquido := _nTOTVENC - _nTOTDESC
		Endif
	Endif
	
	dbSelectArea("SRA")
	
	If _nTOTVENC == 0 .And. _nTOTDESC == 0
		SRA->(dbSkip())
		Loop
	Endif
	
	_cDataBas	:= DtoC(SRH->RH_DATABAS)
	_cDBaseAt	:= DtoC(SRH->RH_DBASEAT)
	_cDFerias	:= Str(SRH->RH_DFERIAS)
	_cDAbonPe	:= Str(SRH->RH_DABONPE)

	_cTextoMsg := "" 
	
	//Há dados a ser informado
	If _lData
	
		//Verifica Header
		If !_lHeader
	
				//pega número sequencial do rcc
				DBSelectArea('RCC')
				RCC->( DBGoto(_nrecno) )
								
	
				// Monta Header de Arquivo - Visao 1
				_cLin := Replicate("0",20)									//01-20 preencher com zeros(000:.0)
				_cLin += "00"													//21-22 preencher com zeros (00)
				_cLin += "0"			 										//23-23 preencher com zero
				_cLin += STRZERO((VAL(SUBSTR(RCC_CONTEU,24,4))),4)				//24-27 prefixo da agência do BB, sem DV
				_cLin += STRZERO((VAL(SUBSTR(RCC_CONTEU,30,12))),11)		//28-38 num. da conta da empresa no BB, sem DV    
				_cLin += "EDO001"												//39-44 preencher com EDO001
				_cLin += STRZERO((VAL(SUBSTR(RCC_CONTEU,1,20))),12)		//45-56 número do contrato, atribuído pelo EDO
				_cLin += STRZERO((VAL(SUBSTR(RCC_CONTEU,43,6))+1),6)		//57-62 número seqüencial da remessa
				_cLin += "00315"												//63-67 código do   produto  - 00315
				_cLin += "00001"												//68-72 código da modalidade - 00001
				_cLin += Transf(Year(MV_PAR01),'9999')						//73-76 ano a que se refere o documento
				_cLin += StrZero(Month(MV_PAR01),2)						//77-78 mês a que se refere o documento
				_cLin += "00"													//79-80 número seqüencial de extraordinariedade
				_cLin += MGPE013D(MV_PAR10,"DDMMAAAA")						//81-88 data (ddmmaaaa) referente ao crédito
				_cLin += Space(12)											//89-100 preencher com brancos
				_cLin += CHR(13)+CHR(10)
				
				MGPE013G()
				
				
				MGPE013Z(STRZERO((VAL(SUBSTR(RCC_CONTEU,43,6))+1),6)) //Atualiza sequencia no RCC
				
				
				_lHeader := .T.

		Endif
		
		//Dados do Funcionario - Visao 2
		If _nLiquido == 0
			_nLiquido := _nTOTVENC-_nTOTDESC
		EndIf

        _cCodBco   := Subs(SRA->RA_BCDEPSA,1,3)

        _cCodAgenc := AllTrim(Subs(SRA->RA_BCDEPSA,4,5))

        _cCodContaC := AllTrim(SRA->RA_CTDEPSA)
        
        _lGravouArqTxt := .F.
        
        If _cCodBco == "001" .And. Len(_cCodAgenc) >= 5 .And. Len(_cCodContaC) >= 5
		   _cLin := StrZero(Val(SRA->RA_MAT),20)							//01-20 identificador do destinatário empresa
		   _cLin += "00"													//21-22 preencher com números zeros (00)
		   _cLin += "1"														//23-23 preencher com o número 1
		   _cLin += Subs(SRA->RA_BCDEPSA,4,4)								//24-27 prefixo da agência do BB, sem DV
		   _cLin += StrZero(Val(Left(AllTrim(SRA->RA_CTDEPSA),Len(AllTrim(SRA->RA_CTDEPSA))-1)),11)		//28-38 conta BB do destinatário no BB, sem DV
		   _cLin += StrZero(Len(_aLanca)+11,2)								//39-40 quantidade de linhas do texto
		   _cLin += Left(SRA->RA_NOME + Space(40),40)						//41-80 nome do destinatário
		   _cLin += StrZero(Val(SRA->RA_CIC),11)							//81-91 CPF do destinatário
		   _cLin += Space(09)											   	//92-100 preencher com brancos
		   _cLin += CHR(13)+CHR(10)

		   MGPE013G()
		   _nQtFunc++
		
		   // Monta Header de Lote - Registro Tipo "3" Segmento "E" --> Proventos
		   MGPE0133()
			
		   //Verifica Liquidos
		   If _nLiquido == 0
			  _nLiquido := _nTOTVENC-_nTOTDESC
		   EndIf
			
		   If MV_PAR02 <> 6
			  // Verifica Iconsistencias de Liquidos
			  _lliq := .T.
			  If _nLiquido != (_nTotVenc - _nTotDesc)
		         _lLiq := .F.
			  EndIf
		   Else
			  _lliq := .T.
		   EndIf
		   _lGravouArqTxt := .T.
		   
        Else
           _lLiq := .F. 
           _lGravouArqTxt := .F. 
        EndIf

	    If _lGravouArqTxt 
	       _cTextoMsg := "SUCESSO NA GRAVAÇÃO DO ARQUIVO DE ENVIO. "
	    Else
	       _cTextoMsg := "NÃO FOI POSSÍVEL GRAVAR ARQUIVO DE ENVIO. PROBLEMAS COM:" 
	       If _cCodBco <> "001" 
	          _cTextoMsg += " CODIGO DO BANCO INVÁLIDO. "
	       EndIf
	    
	       If Len(_cCodAgenc) < 5 
	          _cTextoMsg += " NUMERO DA AGENCIA INVÁLIDO. "
	       EndIf
	    
	       If Len(_cCodContaC) < 5
	          _cTextoMsg += " NUMERO DA CONTA CORRENTE INVÁLIDO. "
	       EndIf
	    EndIf
	Endif
	
	aadd(_aresults,{cfilant,DescCC(Sra->Ra_Cc,Sra->Ra_Filial),SRA->RA_MAT,SubStr(SRA->RA_NOME,1,30),Transform(_nTotvenc,"@E 9999999.99"),Transform(_nTotdesc,"@E 9999999.99"),;
			Transform(_nLiquido,"@E 9999999.99"),Transform(SRA->RA_SALARIO,"@E 9999999.99"),iif(_lliq,"OK","INCONSISTENTE"),_cTextoMsg})
			
	_nTotais := _nTotais + _nLiquido
	
	
	dbSelectArea("SRA")

	dbSkip()
	_nTOTDESC := _nTOTVENC := 0
EndDo

If _nQtFunc > 0

    aadd(_aresults,{cfilant,"Totais da Filial:","   ",strzero(_nQtFunc,6) + " funcionários","Conta pagadora: " + _cagencia + " - " + _cconta + "/" + _cdigito ,;
							" "," ",Transform(_nTotais,"@E 9999999.99")," ", "GRAVADO NO ARQUIVO DE ENVIO COM SUCESSO."})

Endif
							
_nTotais := 0


//Ha Dados a Serem Gerados
If _lData
	
	_cLin := Replicate("9",20)	//01-20 preencher com números Nove (999:.9)
	_cLin += "99"				//21-22 preencher com números Nove (99)
	_cLin += "9"					//23-23 preencher com o número Nove (9)
	_cLin += Replicate("9",15)	//24-38 preencher com números Nove (999:.9)
	_cLin += StrZero(_nQtFunc,11)	//39-49 quantidade de destinatários do arquivo
	_cLin += Space(51)			//50-100 preencher com brancos
	_cLin += CHR(13)+CHR(10)

	MGPE013G()
		
Endif



//----------------------------------------------------------------
//  Termino do relatorio                                          
//----------------------------------------------------------------
dbSelectArea("SRC")
dbSetOrder(1)          // Retorno a ordem 1
dbSelectArea("SRC")
dbSetOrder(1)          // Retorno a ordem 1
dbSelectArea("SRA")
SET FILTER TO

fClose( _nHdl )
If !(Type("MV_PAR03") == "U")
	fErase(Alltrim(MV_PAR03) + OrdBagExt())
Endif


Return

/*
===============================================================================================================================
Programa----------: MGPE013S
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/08/2015
Descrição---------: Somar as Verbas no Array  
Parametros--------: 	_cTipo - P provento, D desconto, B base
						_Verba - Verba
						_nHoras - quantidade de horas
						_nValor - valor da verba
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MGPE013S(_cTipo,_cPd,_nHoras,_nValor)

Local _cDesc_paga

_lData	:= .T.  //Há Dados a serem informados

_cDesc_paga := DescPd(_cPd,Sra->Ra_Filial)  // mostra como pagto

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
	Aadd(&_cArray,{_cPd+" "+left(_cDesc_Paga,19),_nHoras,_nValor })
Else
	&_cArray[nPos,2] += _nHoras
	&_cArray[nPos,3] += _nValor
Endif

Return

/*
===============================================================================================================================
Programa----------: MGPE013D
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/08/2015
Descrição---------: Converte datas
Parametros--------: 	dData - Data a ser convertida
						_xTipo - Mascara de conversão
Retorno-----------: cret - string com data convertida
===============================================================================================================================
*/
Static Function MGPE013D( dData, _xTipo )

Local _cRet := Space(08)

If _xTipo == "DDMMAAAA"
	_cRet := StrZero(Day(dData),2) + StrZero(Month(dData),2) + StrZero(Year(dData),4)
ElseIf _xTipo == "MMAAAA"
	_cRet := StrZero(Month(dData),2) + StrZero(Year(dData),4)
EndIf


Return( _cRet )


/*
===============================================================================================================================
Programa----------: MGPE0133
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/08/2015
Descrição---------: Dados das Verbas - Visao 3   
Parametros--------: 
Retorno-----------: 
===============================================================================================================================
*/
Static Function MGPE0133()

Local _ni, _nLen, _cVrb, _nProv, _nDesc, _nLiq, _nSeq
                                 
_nProv := _nDesc := _nLiq := 0
_nSeq  := 1

//Imprime cabecalho
	_cLin := StrZero(Val(SRA->RA_MAT),20)		//01-20 identificador do destinatário empresa
	_cLin += StrZero(_nSeq,2)						//21-22 seqüencial da linha do texto
	_cLin += "2"									//23-23 preencher com o número 2
	_cLin += "EMPRESA: GOIASMINAS  - CNPJ: " + Transform(_cDesc_CGC,'@R! NN.NNN.NNN/NNNN-99') + " 1" + space(28) + CHR(13)+CHR(10)
	MGPE013G()
    _nSeq++

	_cLin := StrZero(Val(SRA->RA_MAT),20)		//01-20 identificador do destinatário empresa
	_cLin += StrZero(_nSeq,2)						//21-22 seqüencial da linha do texto
	_cLin += "2"									//23-23 preencher com o número 2
	_cLin += StrZero(Val(SRA->RA_MAT),6) + " - " + SRA->RA_NOME + space(9) + "0" + space(28) + CHR(13)+CHR(10)
	MGPE013G()
    _nSeq++

	_cLin := StrZero(Val(SRA->RA_MAT),20)		//01-20 identificador do destinatário empresa
	_cLin += StrZero(_nSeq,2)						//21-22 seqüencial da linha do texto
	_cLin += "2"									//23-23 preencher com o número 2
	_cLin += "FUNCAO: " + StrZero(Val(SRA->RA_CODFUNC),5) + " - " + Left(SRJ->RJ_DESC+Space(30),30) + space(2) + "0" + space(28) + CHR(13)+CHR(10)
	MGPE013G()
    _nSeq++

	_cLin := StrZero(Val(SRA->RA_MAT),20)		//01-20 identificador do destinatário empresa
	_cLin += StrZero(_nSeq,2)						//21-22 seqüencial da linha do texto
	_cLin += "2"									//23-23 preencher com o número 2
	_cLin += "COMPETENCIA: " + strzero(month(MV_PAR01),2) + "/" + strzero(year(MV_PAR01),4) + space(28) + "1" + space(28) + CHR(13)+CHR(10)
	MGPE013G()
    _nSeq++

// Calcula Quantidade de Proventos
_nLen := Len(_aLanca)

If _nLen == 0
	Return
EndIf

// Processa Array
For _ni := 1 To _nLen

    //Monta inicio da linha texto
	_cLin := StrZero(Val(SRA->RA_MAT),20)		//01-20 identificador do destinatário empresa
	_cLin += StrZero(_nSeq,2)						//21-22 seqüencial da linha do texto
	_cLin += "2"									//23-23 preencher com o número 2

	_cVrb  := Iif(_aLanca[_ni][1] == "P", "PRO" , "DES")

    //Se encontrou a primeira ocorrencia de desconto, imprime total de proventos
    If _cVrb == "DES" .and. _nDesc == 0
		_cLin += "TOTAL DE PROVENTOS:      "
		_cLin += Transform(_nProv, '@E 999,999,999.99')
		_cLin += space(9)
		_cLin += "1"
		_cLin += space(28)
		_cLin += CHR(13)+CHR(10)
		MGPE013G()
        _nSeq++
		_cLin := StrZero(Val(SRA->RA_MAT),20)		//01-20 identificador do destinatário empresa
		_cLin += StrZero(_nSeq,2)						//21-22 seqüencial da linha do texto
		_cLin += "2"									//23-23 preencher com o número 2
    EndIf
	
	_nProv += Iif(_aLanca[_ni][1] == "P", _aLanca[_ni][5] , 0 )
	_nDesc += Iif(_aLanca[_ni][1] == "D", _aLanca[_ni][5] , 0 )
	_cLin += _cVrb + Space(1)										//24-27 Tipo (pro,des,bas)
	_cLin += _aLanca[_ni][2]+Space(1)								//28-31 Codigo da verba
	_cLin += Left(_aLanca[_ni][3],20)+Space(1)						//32-52 Descricao da verba
	_cLin += Transform(_aLanca[_ni][4], '@E 999.99')+space(1) 		//53-58 Horas do Lancamento
	_cLin += Transform(_aLanca[_ni][5], '@E 9999,999.99')+space(1) 	//60-70 Horas do Lancamento
	_cLin += "0"													//72-72 "1"-para saltar uma linha de intervalo/"0"-para linhas corridas
	_cLin += Space(28)											//73-100 preencher com brancos
	_cLin += CHR(13)+CHR(10)
	MGPE013G()
    _nSeq++

Next

//imprime total de descontos
_cLin := StrZero(Val(SRA->RA_MAT),20)		//01-20 identificador do destinatário empresa
_cLin += StrZero(_nSeq,2)						//21-22 seqüencial da linha do texto
_cLin += "2"									//23-23 preencher com o número 2
_cLin += "TOTAL DE DESCONTOS:      "
_cLin += Transform(_nDesc, '@E 999,999,999.99')
_cLin += space(9)
_cLin += "1"
_cLin += space(28)
_cLin += CHR(13)+CHR(10)
MGPE013G()
_nSeq++
	
//Imprime total liquido
_cLin := StrZero(Val(SRA->RA_MAT),20)		//01-20 identificador do destinatário empresa
_cLin += StrZero(_nSeq,2)						//21-22 seqüencial da linha do texto
_cLin += "2"									//23-23 preencher com o número 2
_nLiq := _nProv - _nDesc
_cLin += "TOTAL LIQUIDO A RECEBER: "
_cLin += Transform(_nLiq, '@E 999,999,999.99')
_cLin += space(09)
_cLin += "1"
_cLin += space(28)
_cLin += CHR(13)+CHR(10)
MGPE013G()
_nSeq++

//Imprime base FGTS
_cLin := StrZero(Val(SRA->RA_MAT),20)		//01-20 identificador do destinatário empresa
_cLin += StrZero(_nSeq,2)						//21-22 seqüencial da linha do texto
_cLin += "2"									//23-23 preencher com o número 2
_cLin += "BASE FGTS: "
_cLin += Transform(_nBaseFgts, '@E 999,999,999.99')
_cLin += space(23)
_cLin += "0"
_cLin += space(28)
_cLin += CHR(13)+CHR(10)
MGPE013G()
_nSeq++

//Imprime FGTS MES
_cLin := StrZero(Val(SRA->RA_MAT),20)		//01-20 identificador do destinatário empresa
_cLin += StrZero(_nSeq,2)						//21-22 seqüencial da linha do texto
_cLin += "2"									//23-23 preencher com o número 2
_cLin += "FGTS MES.: "
_cLin += Transform(_nFgts, '@E 999,999,999.99')
_cLin += space(23)
_cLin += "0"
_cLin += space(28)
_cLin += CHR(13)+CHR(10)
MGPE013G()
_nSeq++

//Imprime Base INSS
_cLin := StrZero(Val(SRA->RA_MAT),20)		//01-20 identificador do destinatário empresa
_cLin += StrZero(_nSeq,2)						//21-22 seqüencial da linha do texto
_cLin += "2"									//23-23 preencher com o número 2
_cLin += "BASE INSS: "
_cLin += Transform(_nAteLim, '@E 999,999,999.99')
_cLin += space(23)
_cLin += "0"
_cLin += space(28)
_cLin += CHR(13)+CHR(10)
MGPE013G()
_nSeq++

//Imprime base IR
_cLin := StrZero(Val(SRA->RA_MAT),20)		//01-20 identificador do destinatário empresa
_cLin += StrZero(_nSeq,2)						//21-22 seqüencial da linha do texto
_cLin += "2"									//23-23 preencher com o número 2
_cLin += "BASE IR..: "
_cLin += Transform(_nBaseIr, '@E 999,999,999.99')
_cLin += space(23)
_cLin += "0"
_cLin += space(28)
_cLin += CHR(13)+CHR(10)
MGPE013G()
_nSeq++

Return

/*
===============================================================================================================================
Programa----------: MGPE013G
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/08/2015
Descrição---------: Grava linha no arquivo  
Parametros--------: 
Retorno-----------: 
===============================================================================================================================
*/
Static Function MGPE013G()

If fWrite(_nHdl,_cLin,Len(_cLin)) != Len(_cLin)
	MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
Endif

Return

/*
===============================================================================================================================
Programa----------: MGPE013C
Autor-------------: Josué Danich Prestes 
Data da Criacao---: 13/08/2015
Descrição---------: Rotina para abrir consulta de contratos de cnab
Parametros--------: Nenhum
Retorno-----------: Sempre .T.
===============================================================================================================================
*/
User Function MGPE013C()

Local _cRet		:= ''
Local _cQuery	:= ''
Local _cAlias	:= GetNextAlias()
Local _cTitAux	:= 'Contratos/Contas - Banco do Brasil'
Local _aDados	:= {}
Local _nconta	:= 0
Local _nI		:= 0
		
_cQuery := " SELECT SUBSTR( RCC.RCC_CONTEU , 21 , 3 )	AS BANCO," 
_cQuery += " LPAD(TRIM(SUBSTR( RCC.RCC_CONTEU , 1 , 20 )),12,'0') 	AS CONTRATO," 
_cQuery += " LPAD(TRIM(SUBSTR( RCC.RCC_CONTEU , 24 , 4 )),4,'0')	AS AGENCIA," 
_cQuery += " LPAD(TRIM(SUBSTR( RCC.RCC_CONTEU , 30 , 11 )),11,'0')	AS CONTA,"
_cQuery += " TRIM(SUBSTR( RCC.RCC_CONTEU , 42 , 1 ))	AS DIGITO,"
_cQuery += " LPAD(TRIM(SUBSTR( RCC.RCC_CONTEU , 43 , 6 )),6,'0')	AS SEQUENCIA,"
_cQuery += " R_E_C_N_O_ AS NUM"
_cQuery += " FROM "+ RetSqlName("RCC") + " RCC"
_cQuery += " WHERE RCC.RCC_FILIAL = '" + xfilial("RCC") + "'"
_cQuery += " AND D_E_L_E_T_		= ' ' AND SUBSTR( RCC.RCC_CONTEU , 21 , 3 ) = '001'"
_cQuery += " AND   RCC.RCC_CODIGO	= 'S052'"
		
		
If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TCGenQry(,,_cQuery) , _cAlias , .F. , .T. )

DBSelectArea(_cAlias)
(_cAlias)->( DBGoTop() )
While (_cAlias)->( !Eof() )

	
	aAdd( _aDados , { .F. ,  alltrim((_cAlias)->CONTRATO)+"/"+ alltrim((_cAlias)->SEQUENCIA)+"/"+ alltrim(str((_cAlias)->NUM)) } )
	
	(_cAlias)->( DBSkip() )

EndDo

(_cAlias)->( DBCloseArea() )

If U_ITListBox( _cTitAux , { '__' ,  'Contrato/Sequência/Registro'  } , @_aDados , .F. , 2 , 'Selecione o contrato: ' )

	
	For _nI := 1 To Len( _aDados )
		
		If _aDados[_nI][01]
			
			_nconta++
			
			if _nconta > 1
			 
			  alert("Selecione apenas uma conta!")
			  return .T.
			 
			 else
			 
				_cRet += _aDados[_nI][02] +';'
			
			endif
			
		EndIf
		
	Next _nI
	
	&( ReadVar() ) := SubStr( _cRet , 1 , Len(_cRet) - 1 )

EndIf

Return( .T. )


Static Function MGPE013Z(_csequen)

//Grava nova sequência do banco para todos os registros do banco do brasil

RCC->(Dbsetorder(1))
If RCC->(dbseek(xfilial("RCC")+"S052"))
		
	Do while !(RCC->(Eof())) .and. RCC->RCC_FILIAL == xfilial("RCC") .and. RCC->RCC_CODIGO = "S052" 
			
		  If substr(RCC->RCC_CONTEU,21,3) == "001"

		  		RecLock( 'RCC' , .F. )
			
		  		RCC->RCC_CONTEU		:= SUBSTR(RCC->RCC_CONTEU,1,42) + STRZERO((VAL(_csequen)),6)
			
		  		RCC->( MsUnLock() )
		  				
		  Endif
		  	
		  RCC->(Dbskip())
		  
	Enddo
	
Endif

Return
