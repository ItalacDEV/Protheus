/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
André Lisboa  | 13/09/2017 | Chamado 21424. Ajustes para a versão 12.
Josué Danich  | 13/10/2017 | Chamado 21979. Ajuste de gravação do recibo.
Julio Paz     | 07/11/2017 | Chamado 22134. Criação da função U_MDTA695R para carregar almoxarifado.
Julio Paz     | 06/04/2018 | Chamado 23960. Alterar a rotina de manutenção de E.PIs para imprimir o numero da SA.
Josué Danich  | 31/08/2018 | Chamado 25248. Controle de processamento paralelo.
Alex Wallauer | 06/09/2018 | Chamado 25283. Ajustes na gravação dos campos do SPC.
Alex Wallauer | 24/03/2020 | Chamado 32334. Ajustes na User Function MDTA695U() . 
Alex Wallauer | 01/04/2020 | Chamado 32334. Ajustes da variavel aCols para aColsAux . 
Jonathan      | 16/07/2020 | Chamado 33416. Ajuste da impressão do recibo de entrega. 
Jonathan      | 10/08/2020 | Chamado 33790. Ajuste na geração da SA.
Alex Wallauer | 08/10/2020 | Chamado 34318. Correção temporaria ate a Totvs Responder. 
Alex Wallauer | 25/11/2021 | Chamado 38534. Adicao do RecLock() antes do DBDelete() no SCR.
==============================================================================================================================================================
Analista - Programador   - Inicio     - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
Bruno    - Alex Wallauer - 24/02/25 - 24/04/25   - 50005   - Gravacao do campo TNF->TNF_INDDEV com "2" e TNF->TNF_DTRECI com CTOD("")
Bruno    - Julio Paz     - 06/03/25 - 25/04/25   - 50005   - Gravacao do campo TNF->TNF_INDDEV com "2" e TNF->TNF_DTRECI com CTOD("") apenas para as filiais do parâmetro IT_EPIBIO. Impressão do Recibo para filiais diferente que não estiverem no parâmetro IT_EPIBIO.
Bruno    - Julio Paz     - 06/05/25 - 06/05/25   - 50565   - Habilitar a impressão do recibo de entrega de EPI para todas as filiais. Independente do conteúdo do parâmetro IT_EPIBIO.
==============================================================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "TOTVS.CH"  
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"   

Static _cTNF_MATRIC
Static _cTNF_FILIAL
Static _aTNF_RECNO
Static _cTNFcA105Num

/*
===============================================================================================================================
Programa----------: MDTA6955
Autor-------------: Josué Danich Prestes
Data da Criacao---: 01/09/2015
===============================================================================================================================
Descrição---------: Ponto de entrada chamado após gravação e entrega de EPI ao funcionário via rotinas MDTA695 ou MDTA630
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
STATIC cNumSA:="XXXXXX"

User Function MDTA6955()

Local _aArea    := GetArea()
Local _cMat 	:= ""
Local _cnumcap 	:= ""
Local _cnumsem	:= ""
//Local _cCC	:= ""
Local _cArm		:= ""
Local _nori	    := 0
//Local _nITM		:= 0
Local _cMotivo  := ""     
Local _nPosMat, _nPosNumCap, _nPosNumSem
Local _aEpis	:= {}

n:= ogettnf695:nat
aColsAux:= ogettnf695:aCols
_nori := n

// Mantém posição da SCP/TNF para não interferir na gravação
_nPosSCP := SCP->( recno() )
_nPosTNF := TNF->( recno() )


//Commito os dados na SCP para validar o seek
SCP->(DBCOMMIT())
SCP->(FkCommit()) 

//Se for a função Funcionário x EPI
if alltrim(funname()) == "MDTA695"
	
	_ccpfilial := cFilAnt//SCP->CP_FILIAL
	_ccpnum := cNumSA //:= SCP->CP_NUM // o SPC não esta posicionado porido devemos usar a variavel PRIVATE "cNumSA" do padrão 

 //  MSGINFO("SA Posicionada, cNumSA: [ "+cNumSA+" ]","MDTA6955")

	SCP->(Dbsetorder(1))

	IF !_l655CTR .AND. LEN(aColsAux) == 1
		_aEpis := MTDAAUX(aColsAux)
		lRet := MDT695AUTO( _aEpis[1], 3 )
		SCP->(DBCOMMIT())
		SCP->(FkCommit())
	ENDIF

	//------------------------------------------------------------------------------------------------------------------------------------------------
	SCP->( DBGOTO( _nPosSCP ) )
	//ORDEM 1 CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL

	//VERIFICA A EXISTENCIA DO REGISTRO NA SCR, CASO EXISTA, ELE DELETA CHAMADO: 33790
	DbSelectArea('SCR')
	SCR->(DbSetOrder(1))

	IF SCR->(DbSeek(cFilAnt+"SA"+cNumSA))
		DO WHILE SCR->(!EOF()) .AND. SCR->CR_FILIAL == cFilAnt .AND. ALLTRIM(SCR->CR_TIPO) == "SA" .AND. ALLTRIM(SCR->CR_NUM) == ALLTRIM(cNumSA)
		   SCR->(RecLock('SCR',.F.))
		   SCR->(DBDelete())
		   SCR->(DBSkip())
		ENDDO
	ENDIF
	//------------------------------------------------------------------------------------------------------------------------------------------------
	//Posicina novamente para não gerar
	SCP->( DBGOTO( _nPosSCP ) )
	TNF->( DBGOTO( _nPosTNF ) )	

	If SCP->(Dbseek(_ccpfilial+_ccpnum))
	
		//Roda SCP atualizando campos
		Do while SCP->CP_FILIAL == _ccpfilial .and. SCP->CP_NUM == _ccpnum
	
			//roda todo o aColsAux atualizando campos 
			n := 1
	        nLinSalva:=0
			Do while n <= len(aColsAux)
	
				if 	!aColsAux[n,len(aHeader)+1] .and. ;
					alltrim(aColsAux[n][aSCAN(aHEADER, {|x| ALLTRIM(UPPER(X[2])) == "TNF_CODEPI" })]) == alltrim(SCP->CP_PRODUTO) .and. ;
					(aColsAux[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_QTDENT" })]) == SCP->CP_QUANT .and. ;
					EMPTY(alltrim((aColsAux[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_ITEMSA"})]))) .AND. ;
					EMPTY(alltrim((aColsAux[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_NUMSA" })]))) .AND. EMPTY(SCP->CP_I_DTSOL)//Para controle de itens repetido com mesm qtde
			
						//atualiza aColsAux para não repetir mesma linha na gravação da SA
			
						(aColsAux[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_NUMSA" })]) := alltrim(SCP->CP_NUM)
						(aColsAux[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_ITEMSA" })]) := alltrim(SCP->CP_ITEM)
						nLinSalva:=n//Salva a linha que acabou de gravar os campos acima , no proximo não vai entra nesse item de novo pq os camos já estão preenchidos
						EXIT // sai pq o proximo produto e qtde pode ser igual 
			 	
				Else
		
					n++
			
				Endif 
		
			Enddo 
         
          _cMat:=cMatricula//Variavel do padrão
	      IF nLinSalva <> 0//Controla qual item não gravou os campos abaixo ainda
		   	 n := nLinSalva
	
			//grava observação a partir do campo TNF_MAT2 que contém a matricula do funcionario
			_nPosMat := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_I_MAT2" })
			_cmat := alltrim(aColsAux[n][_nPosMat]) 
		
			//grava CA na solicitação ao armazém
			_nPosNumCap := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_NUMCAP" })
			_cnumcap := alltrim(aColsAux[n][_nPosNumCap])
	
			//pega número da semana
			_nPosNumSem := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_I_NSEM" })
			_cnumsem := alltrim(aColsAux[n][_nPosNumSem])

			//pega número da semana
			_nPosMot := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_MOTIVO" })
		    _cMotivo := alltrim(aColsAux[n][_nPosMot])

			// Se for material de reuso grava na observação
			_cArm := alltrim(aColsAux[n][ aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_LOCAL" }) ])
 	
	    ENDIF
			//Centro de Custo
//			_cCC := TNF_I_CC
	
			DbSelectArea("SCP")
			RecLock("SCP",.F.) 

   	        IF nLinSalva <> 0//Controla qual item não gravou os campos abaixo ainda
			   SCP->CP_OBS := "FUNCIONARIO: " + substr(alltrim(Posicione("SRA",1,xFilial("SRA") + _cMat, "RA_NOME")),1,25);
			     	       +  "  -  SETOR: " +  alltrim(Posicione("ZAK",1,xfilial("ZAK") + Posicione("SRA",1,xFilial("SRA") + _cMat, "RA_I_SETOR"),"ZAK_DESCRI"))
 	        ENDIF
			//se tiver campo de número de semana preenchido exporta para SA
			If !empty(_cnumsem) .AND. nLinSalva <> 0
 	
				SCP->CP_OBS := ALLTRIM(SCP->CP_OBS) + " - Letra Dia: " + alltrim(_cnumsem)
 		
			Endif
 	
			// Se o destino do material for para Reuso
			If _cArm == "05" .AND. nLinSalva <> 0
				SCP->CP_OBS := ALLTRIM(SCP->CP_OBS) + " - REUSO"
			Endif	
 	
//       	SCP->CP_CC		:= _cCC//Já ta gravado
			SCP->CP_I_DTSOL := DATE()
			SCP->CP_I_RSSOL := TIME()
			SCP->CP_I_CDUSU := U_UCFG001(1)
			SCP->CP_I_GRAPR := Posicione("ZZL",4,xFilial("ZZL")+Trim(SCP->CP_SOLICIT),"ZZL_GRPAPR")
			SCP->CP_STATSA	:= "L"
			SCP->CP_I_DTAPR :=	date()
			SCP->CP_I_HRAPR	:=	time()
			SCP->CP_I_CDAPR	:= 	SRA->RA_MAT
	        IF nLinSalva <> 0
			   SCP->CP_I_TNFMT:=_cMotivo
			   SCP->CP_I_NUMCA:=_cnumcap
            ENDIF
			SCP->( MsUnLock() )  
	
			SCP->( Dbskip() )
			
		Enddo
		
	endif
	
Endif


//se for a função EPI x funcionário
if alltrim(funname()) == "MDTA630"

	//grava observação a partir do obs gravado por padrão
	_cmat := right(alltrim(SCP->CP_OBS),6)
	
	DbSelectArea("SCP")
	RecLock("SCP",.F.) 

	SCP->CP_OBS := "FUNCIONARIO: " + substr(alltrim(Posicione("SRA",1,xFilial("SRA") + _cMat, "RA_NOME")),1,25);
 	+  "  -  SETOR: " +  alltrim(Posicione("ZAK",1,xfilial("ZAK") + Posicione("SRA",1,xFilial("SRA") + _cMat, "RA_I_SETOR"),"ZAK_DESCRI"))
 	
 	//se tiver campo de número de semana preenchido exporta para SA
 	If !empty(TNF->TNF_I_NSEM)
 	
 		SCP->CP_OBS := ALLTRIM(SCP->CP_OBS) + " - Letra Dia: " + alltrim(TNF->TNF_I_NSEM)
 		
 	Endif
 	
 	//grava CA na solicitação ao armazém
 	SCP->CP_I_NUMCA := TNF->TNF_NUMCAP

	SCP->( MsUnLock() )

endif

SCP->( dbgoto (_nPosSCP ) )
TNF->( dbgoto (_nPosTNF ) )

//chama ponto de entrada pós gravação de SCP
cA105Num := SCP->CP_NUM
//U_MT105GRV(SCP->CP_NUM) não precisa chamar já grva tudo aqui 

// Existe inclusão de EPIs sem impressão do Recibo de entrega.  
// Mantém posição da SCP/TNF para não interferir na gravação
_nPosSCP := SCP->( recno() )
_nPosTNF := TNF->( recno() )	
     
// Gera os dados para emissão do recibo de entrega de EPI.   
U_MDTA695T()   

SCP->( dbgoto (_nPosSCP ) )
TNF->( dbgoto (_nPosTNF ) )
   
//Limpa variável de processamento
PutGlbValue("MDTA6954","")
   
RestArea(_aArea)

Return Nil

/*
===============================================================================================================================
Programa----------: MDTA695R
Autor-------------: Julio de Paula Paz
Data da Criacao---: 23/10/2017
===============================================================================================================================
Descrição---------: Esta função carega o almoxarifado posicionado no msgetdados principal para outro secundário, através da
                    do incializador padrão do campo
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MDTA695R()
Local _cRet := "  " 
Local _nLocalT 
Local _nPosLoc, _cAlmox,_nPosRepEst 

Begin Sequence
   If Type("aHeadPrin") == "A" .And. Type("aOldTNF") == "A" .And. Type("nSalTNF") == "N"
      _nLocalT := aSCAN(aHeadPrin, {|x| AllTrim(Upper(X[2])) == "TNF_LOCAL" })
      _nPosRepEst := aSCAN(aHeader, {|x| AllTrim(Upper(X[2])) == "TLW_TIPODV" }) 
      
      _cAlmox := aOldTNF[nSalTNF,_nLocalT]
      
      _cRet := _cAlmox
      
      aCols[N,_nPosRepEst] := "2"
   Else
      _nPosLoc := aSCAN(aHeader, {|x| AllTrim(Upper(X[2])) == "TLW_LOCAL" })
      _cRet := aCols[N,_nPosLoc]
   EndIf

End Sequence

Return _cRet

/*
===============================================================================================================================
Programa----------: MDTA695T
Autor-------------: Julio de Paula Paz
Data da Criacao---: 04/04/2018
===============================================================================================================================
Descrição---------: Esta função inicia a leitura de dados para a impressão dos documentos de entrega.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MDTA695T()
Local _cQry
Local _nTotRegs
Local _aRecnoTNF := {}
//Local _aParametros 

Begin Sequence
   _cQry := "SELECT TNF.R_E_C_N_O_ AS NRRECNO FROM " + RetSqlName("TNF") + " TNF " 
   _cQry += " WHERE TNF.D_E_L_E_T_ <> '*' AND TNF_FILIAL = '" + xFilial("TNF") + "' "
   _cQry += " AND TNF_MAT = '" +M->RA_MAT+ "' AND TNF_DTRECI = '        ' "

   If Select("QRYTNF2") > 0
	  QRYTNF2->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "QRYTNF2" , .T. , .F. )

   QRYTNF2->(DbGoTop())

   _nTotRegs := 0
   Do While ! QRYTNF2->(Eof())
      _nTotRegs += 1
      
      Aadd(_aRecnoTNF,QRYTNF2->NRRECNO)
      
      QRYTNF2->(DbSkip())
   EndDo
   
   If Select("QRYTNF2") > 0
	  QRYTNF2->( DBCloseArea() )
   EndIf

   If _nTotRegs == 0
      Break
   EndIf
   
   _cTNF_MATRIC := M->RA_MAT
   _cTNF_FILIAL := xFilial("TNF")
   _aTNF_RECNO  := AClone(_aRecnoTNF)
   _cTNFcA105Num := cA105Num   
              
End Sequence

Return Nil

/*
===============================================================================================================================
Programa----------: MDTA695U
Autor-------------: Julio de Paula Paz
Data da Criacao---: 05/04/2018
===============================================================================================================================
Descrição---------: Esta função chama  a rotina customizada de entregas de EPIs.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MDTA695U()
//Local _cMatricula := _cTNF_MATRIC 
//Local _cFilial    := _cTNF_FILIAL 
Local _aRecnoTNF  := _aTNF_RECNO  
Local _nI
Local _lNrSAPreenchido
Local _cFilAsDig := SUPERGETMV('IT_EPIBIO',.F.,"01")

IF !EMPTY(_cTNFcA105Num) .OR. TYPE("cA105Num") <> "C"
   cA105Num := _cTNFcA105Num
ENDIF

Begin Sequence
   _nPosSCP := SCP->( recno() )
   _nPosTNF := TNF->( recno() )	

   _lNrSAPreenchido := .T.
   For _nI := 1 To Len(_aRecnoTNF)
       TNF->(DbGoTo(_aRecnoTNF[_nI]))
	   If Empty(TNF->TNF_NUMSA)
          _lNrSAPreenchido := .F.
       EndIf
   Next

   If ! _lNrSAPreenchido
      Break   
   EndIf

   M->RA_MAT := _cTNF_MATRIC

   //=================================
   //Emite recibo de entrega do EPI	
   //=================================	
   U_RMDT001() 
   
   //===============================================================================================
   // Habilitar a biometria apenas para as filiais diferentes das filiais do parâmetro IT_EPIBIO.
   //===============================================================================================
   If cFilAnt $ _cFilAsDig 
      For _nI := 1 To Len(_aRecnoTNF)
	      TNF->(DbGoTo(_aRecnoTNF[_nI]))
		  
          TNF->(RecLock("TNF",.F.))
          If TNF->TNF_INDDEV == "3"
             TNF->TNF_I_OBS  := "Epi em Solic. Armazem" // "Em solicitação ao armazém" 
		  EndIf 
          TNF->TNF_INDDEV := "2"   // VERIFICAR SE O INDDEV É 3 ANTES DE ALTERAR O CAMPO TNF_I_OBS.
          TNF->TNF_DTRECI := CTOD("")
          TNF->(MSUnlock())       
      Next
   EndIf 

   _cTNF_MATRIC := ""
   _cTNF_FILIAL := ""
   _aTNF_RECNO  := {}
   _cTNFcA105Num := ""
      
End Sequence

SCP->( Dbgoto (_nPosSCP ) )
TNF->( Dbgoto (_nPosTNF ) )

Return Nil

/*
===============================================================================================================================
Programa----------: MDTA695X
Autor-------------: Julio de Paula Paz
Data da Criacao---: 05/04/2018
===============================================================================================================================
Descrição---------: Esta verifica se existem documentos de entrega de EPIs para serem impressos.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MDTA695X()
Local _lRet := .F.

Begin Sequence
   If ValType(_aTNF_RECNO) == "A"
      If Len(_aTNF_RECNO) > 0
         _lRet := .T.
      EndIf
   EndIf
   
End Sequence

Return _lRet


/*
===============================================================================================================================
Programa----------: MTDAAUX
Autor-------------: Julio de Paula Paz
Data da Criacao---: 05/04/2018
===============================================================================================================================
Descrição---------: Esta verifica se existem documentos de entrega de EPIs para serem impressos.
===============================================================================================================================
Parametros--------: aCols -> aCols auxiliar.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MTDAAUX(_aColls)
	Local _nPosB1		:= SB1->(RECNO())
	Local _nItem		:= 1
	Local _aEpis		:= {}
	Local _nX			:= 0

//	ASORT(_aColls, , , { | x,y | x[2] < y[2] } )
	FOR _nX := 1 TO Len(_aColls)
		aAdd( _aEpis , {{_aColls[_nX][2],; 
						POSICIONE("SB1",1,xFilial("SB1")+_aColls[_nX][2], "B1_UM"),;
						_aColls[_nX][11],;
						SB1->B1_LOCPAD,;
						dDataBase,;
						dDataBase,;
						cUserName,;
						cCCSCP,;
						SB1->B1_DESC,;
						cObsSCP,;
						cNumSA,; 
						StrZero( _nItem, 2 ) }} )
		_nItem++
	NEXT _nX

	SB1->(DBGOTO( _nPosB1 ))

RETURN _aEpis

USER FUNCTION MDTA6959()
 LOCAL aCab:=PARAMIXB[1]
 //LOCAL aItem:=PARAMIXB[2]

 cNumSA:=aCab[1,2]

//MSGINFO("SA que vai Gerar, cNumSA: [ "+cNumSA+" ]","MDTA6959")

RETUR .T.
