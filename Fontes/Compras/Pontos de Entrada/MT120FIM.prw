/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer |10/01/2023| Chamado 42485. Alteracao no calculo do campo ZZH_VALOR.
Lucas Borges  |19/06/2025| Chamado 50617. Revisões diversas visando padronizar os fontes
===============================================================================================================================
Analista       - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
===============================================================================================================================
André Carvalho - Igor Melgaço  - 25/11/24 - 17/02/25 -  49104  - Ajustes para envio de email na alteração da previsão do pedido de compra
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"

Static _aDifItens := {} As Array
/*
===============================================================================================================================
Programa----------: MT120FIM
Autor-------------: Talita Teixeira
Data da Criacao---: 16/10/2014
Descrição---------: Ponto de entrada após a gravacao do pedido de venda
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MT120FIM

Local _cFil        := xFilial("SC7") As Character
Local _cPedido     := PARAMIXB[2] As Character
Local _nOpcao      := PARAMIXB[1] As Numeric
Local _nOpcA       := PARAMIXB[3] As Numeric
Local _nTOTAL      := " " As Character
Local _aCond       := " " As Character
Local _aDadVenc    := {} As Array
Local _dDtVenc     := DDATABASE As Date
Local _nprorp      := 0 As Numeric
Local _nI          := 1 As Numeric
Local _ligual      := .T. As Logical
Local _aArea       := FWGetarea() As Array
Local _aAreaSC7    := SC7->(FWGetArea()) As Array
Local nPtol        := SuperGetMV("IT_PTOLP3",.F.,10) As Numeric
Local cTipo        := SuperGetMV("IT_VALCMP",.F.,"") As Character
Local lDiff        := .F. As Logical
Local nDiff        := 0 As Numeric
Local cDatIni      := DtoS(SuperGetMV("IT_WFPCINI",.F.,"01/01/2016")) As Character
Local _nSeq        := 0 As Numeric
Local _cQryZY1     := "" As Character
Local _cGrpLeite   := AllTrim(SuperGetMV("IT_GRPLEIT",.F.,"")) As Character
Local _cGrpALeite  := Left(AllTrim(SuperGetMV("IT_GRPALEI",.F.,"")),Len(SY1->Y1_GRAPROV)) As Character
Local _cGrpAuto    := AllTrim(SuperGetMV("IT_GRPAUTO",.F.,"")) As Character
Local _lGrpLeite   := .F. As Logical
Local _cAprLeite   := "" As Character
Local _lGrpAuto    := .F. As Logical
Local _cAprAuto    := "" As Character
Local _cGestorPadrao := SuperGetMV("IT_GESTORP",.F.,"") As Character
Local _cGestorPC   := "" As Character
Local _cGrupoItem  As Character
Local _cGrpNaoObrigat := SuperGetMV("IT_GRPNOBR",.F.,"1000") As Character
Local _lDifdt      := .F. As Logical
Local _cAliasZY1   := "" As Character

Private cFilPC	:= SuperGetMV("IT_FILWFPC",.F.,"01") As Character
Private lFilPC	:= Iif(cFilAnt $ cFilPC,.T.,.F.) As Logical

If _nOpcA = 0 //Se clicar no cancela nao é para fazer nada 
   RETURN .F.
ENDIF
//============================================================================
// Grava ZZH para leitura de previsão de fluxo de caixa
//============================================================================
If _nOpcao == 3 .or. _nopcao == 4 .or. _nopcao == 9

	Dbselectarea("SC7")
	SC7->( Dbsetorder(1) )

    _lGravaC7_I_USOD:=0
	If SC7->( Dbseek(xfilial("SC7")+alltrim(_cPedido) ) )

		_nsc7 := SC7->(Recno())
		SY1->(dbSetOrder(3))
		SY1->(dbSeek(xFilial("SY1") + SC7->C7_USER))
		_lGrpLeite := Iif(SY1->Y1_GRUPCOM $ _cGrpLeite,.T.,.F.)  

        If !_lGrpLeite .AND. (IsInCallStack('A120COPIA') .OR. _nOpcao == 3 .or. _nopcao == 4)
    
	   	    _lGravaC7_I_USOD:=1
			_nsc7 := SC7->(Recno())
			_nsc1 := SC1->(Recno())
			_cfilsc7 := SC7->C7_FILIAL
			_cnumsc7 := SC7->C7_NUM

			If !Empty(SC7->C7_NUMSC) //Valida se ocorreram modificações de aplicação direta em relação a SC de origem
				SC7->(Dbsetorder(1))
				SC7->(Dbseek(_cfilsc7+_cnumsc7))

				_ldif := .F.

				Do while SC7->C7_FILIAL == _cfilsc7  .AND. SC7->C7_NUM == _cnumsc7
					SC1->(Dbsetorder(1))
					If SC1->(Dbseek(SC7->C7_FILIAL+SC7->C7_NUMSC+SC7->C7_ITEMSC))
						If SC1->C1_I_USOD != SC7->C7_I_USOD 
							_ldif := .T.
							exit
						Endif

						If SC1->C1_DATPRF != SC7->C7_DATPRF
							_lDifdt := .T.
						Endif
					Else
						_ldif := .T.
						exit
					Endif

					SC7->(Dbskip())
				Enddo

				If _ldif 
					If U_ITMSG("CONFIRMA APLICAÇÃO DIRETA DIVERSA DA SC ?",'Atenção!',,3,2,2)
						_lGravaC7_I_USOD:=2
					Else
						_lGravaC7_I_USOD:=3	
					Endif
				Endif
			Else
				_lGravaC7_I_USOD:=3	

				SC1->(DbGoto(_nsc1))
				SC7->(Dbgoto(_nsc7))	
			Endif				
        ENDIF

		SC7->(Dbgoto(_nsc7))

		Do while SC7->C7_FILIAL == xFilial("SC7") .and. alltrim(_cPedido) == alltrim(SC7->C7_NUM)
			SY1->(dbSeek(xFilial("SY1") + SC7->C7_USER))
			_lGrpLeite := Iif(SY1->Y1_GRUPCOM $ _cGrpLeite,.T.,.F.)  
		    _cAprLeite := Iif(_lGrpLeite,_cGrpALeite,"")//SY1->Y1_GRAPROV
		    
		    If .not. _lgrpleite
		    	_lGrpAuto := Iif(SY1->Y1_GRUPCOM $ _cGrpAuto,.T.,.F.)  
		    	_cAprAuto := Iif(_lGrpAuto,SY1->Y1_GRAPROV,"")
		    Endif
		    
				
     		dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + SC7->C7_PRODUTO))

			If !(SB1->B1_TIPO $ cTipo)
				dbSelectArea("SBZ")
				SB2->(dbSetOrder(1))
				SB2->(dbSeek(xFilial("SBZ") + SC7->C7_PRODUTO))
				
				_cGrupoItem := Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_GRUPO")
				
				If SC7->C7_PRECO > SBZ->BZ_UPRC  .And. !(_cGrupoItem $ _cGrpNaoObrigat)  
					nDiff := ((SC7->C7_PRECO - SBZ->BZ_UPRC) / SBZ->BZ_UPRC) * 100
					If nDiff > nPtol
						lDiff := .T.
					EndIf
				EndIf
			EndIf

   			Reclock("SC7",.F.)
     		//Se for cópia limpa campos de registro de eliminação de resíduo
     		If _nopcao == 4 .or. _nopcao == 9
     			SC7->C7_I_USREL := ""
     			SC7->C7_I_DTELR := STOD("")
     			SC7->C7_I_HRELR := ""
    			SC7->C7_I_DTRES	:= STOD("")
				SC7->C7_I_DTGER := date()
     		Endif
     		
       		SC7->(MSUNLOCK())
     
	  		//só continua se tiver data de faturamento marcada
			//também só faz se não teve residuo eliminado  
	  		If SC7->C7_I_DTFAT > ctod('01/01/2001') .AND. SC7->C7_RESIDUO != "S" 
    			_nsaldo 	:=  SC7->C7_QUANT - SC7->C7_QUJE
				If _nsaldo < 0
					_nsaldo := 0
				Endif

	        	_nTOTAL 	:= ( ( ( (SC7->C7_PRECO * SC7->C7_QUANT )+SC7->C7_VALIPI+SC7->C7_DESPESA) - SC7->C7_VLDESC ) / SC7->C7_QUANT ) * ( _nsaldo )
	    		_aCond		:= Condicao( _nTOTAL , SC7->C7_COND , 0 , SC7->C7_I_DTFAT )
	    		_ligual   	:= .T.
     
	     		//Arruma datas, proporcionalidade e monta matriz de vencimentos
	     		For _nI := 1 To Len( _aCond )
	        		_dDtVenc := DataValida( _aCond[_nI][01] ) //só dias úteis
	        		_nprorp := Round( _aCond[_nI][2]/_nTOTAL , 2 )  //indica proporcionalidade da parcela
 	            
	        		//se é primeira passagem grava a primeira proporção para comparar com as seeguintes
    	    		if _nI == 1
 		        		_ccondi := _nprorp
 	   	     		else
 	             		if _ccondi != _nprorp  //compara para ver se tem proporção diferente da primeira
 	                		_ligual := .F.
 	             		endif
 	        		endif  
	
	        		aAdd( _aDadVenc , { _dDtVenc , Round( _aCond[_nI][2] , 2 ), _nprorp, SC7->C7_ITEM } )
         		Next _nI
              
     			//verifica se _nprorp é igual para todas as parcelas
     			// se for deixa zerado para o BI calcular o valor com menor margemd e erro por arredondamento
     			if _ligual
         			For _nI := 1 To Len( _aDadVenc )
    	       	 		_aDadVenc[_nI][3] := 0
         			Next _nI
        		endif
  			Endif

			If _nOpcA <> 0
				If	(SC7->C7_QUJE == 0 .And. SC7->C7_QTDACLA == 0 .And. SC7->C7_CONAPRO == "L") .Or.;
					(SC7->C7_ACCPROC <> "1" .And. SC7->C7_CONAPRO == "B" .And. SC7->C7_QUJE <> SC7->C7_QUANT) .Or.;
					(SC7->C7_CONAPRO == "B" .And. SC7->C7_QUJE < SC7->C7_QUANT .And. SC7->C7_APROV == "PENLIB")
		
					If SC7->C7_QUJE == 0
						nTotItem := SC7->C7_TOTAL
					Else
						nTotItem := SC7->C7_TOTAL / SC7->C7_QUANT
						_nsaldo := SC7->C7_QUANT - SC7->C7_QUJE
						If _nsaldo < 0
							_nsaldo := 0
						Endif
						nTotItem := nTotItem * (_nsaldo)
					EndIf
					
					If _lGrpLeite 
						_cGestorPC := U_ITGESTOR(_cGrpLeite, SC7->C7_USER )
					EndIF
					
					If _lGrpAuto 
						_cGestorPC := U_ITGESTOR(_cGrpAuto, SC7->C7_USER )
					EndIF
					
				    Reclock("SC7",.F.)
			        IF SC7->C7_RESIDUO <> 'S'
					   If lFilPC .And. DtoS(SC7->C7_EMISSAO) >= cDatIni
							Replace SC7->C7_CONAPRO With "B"
							If _lGrpLeite     
								Replace SC7->C7_APROV	With Iif(!Empty(Alltrim(_cAprLeite)),_cAprLeite,"PENLIB")
								Replace SC7->C7_I_GCOM	With Iif(!Empty(Alltrim(_cGestorPC)),_cGestorPC,_cGestorPadrao)
								Replace SC7->C7_I_DTLIB	With Date()
								Replace SC7->C7_I_HRLIB	With Time()
							Elseif _lgrpauto
								Replace SC7->C7_APROV	With Iif(!Empty(Alltrim(_cAprAuto)),_cAprAuto,"PENLIB")
								Replace SC7->C7_I_GCOM	With Iif(!Empty(Alltrim(_cGestorPC)),_cGestorPC,_cGestorPadrao)
								Replace SC7->C7_I_DTLIB	With Date()
								Replace SC7->C7_I_HRLIB	With Time()
							Else 
								Replace SC7->C7_APROV	With "PENLIB"
							EndIf						
					   Else
							Replace SC7->C7_CONAPRO With "L"							
							Replace SC7->C7_APROV	With ""
					   EndIf

				    ELSE
					   Replace SC7->C7_CONAPRO With "L"	//Quando o item é residuo já entra nesse p.e. com SC7->C7_CONAPRO = "B" por isso forcei "L"
  				    EndIf
 				    MsUnLock()
 				    U_DELSCR() //APAGA SCR DO PEDIDO
				EndIf
			EndIf
  			SC7->( Dbskip () )
		Enddo
	
		SC7->(Dbgoto(_nsc7))

 		IF _lGravaC7_I_USOD == 3 //NÃO é GRUPO DO LEITE E ESCOLHEU rever APLICAÇÃO DIRETA
			U_ACOM035(1) //Chama tela de conferência de aplicação direta
   		Endif
		
		If _lGrpLeite 
			//Cria linhas de aprovador no SCR
			SAL->(Dbsetorder(1))
			If SAL->(Dbseek(xfilial("SAL")+_cAprLeite))
				Do while !(SAL->(Eof())) .and. alltrim(_cAprLeite) == SAL->AL_COD
					IF SAL->AL_MSBLQL = '1' 
						SAL->(Dbskip())  
						LOOP
					ENDIF									
					Reclock("SCR",.T.)
					SCR->CR_FILIAL 	:= xfilial("SCR")
					SCR->CR_num 	:= _cPedido
					SCR->CR_TIPO 	:= "PC"
					SCR->CR_GRUPO	:= SAL->AL_COD
					SCR->CR_USER	:= SAL->AL_USER
					SCR->CR_APROV	:= SAL->AL_APROV
					SCR->CR_NIVEL	:= SAL->AL_NIVEL
					SCR->CR_STATUS	:= IIF(SAL->AL_NIVEL=='01','02','01')
					SCR->CR_EMISSAO := DDATABASE
					SCR->CR_MOEDA	:= 1
					SCR->CR_TXMOEDA	:= 1
					SCR->(Msunlock())
								
					SAL->(Dbskip())
				Enddo
			Endif
		EndIF             
		
		If _lGrpAuto 
	
			//Cria linhas de aprovador no SCR
			SAL->(Dbsetorder(1))
			If SAL->(Dbseek(xfilial("SAL")+_cAprAuto))
				Do while !(SAL->(Eof())) .and. alltrim(_cAprAuto) == SAL->AL_COD
					IF SAL->AL_MSBLQL = '1' 
						SAL->(Dbskip())  
						LOOP
					ENDIF
					Reclock("SCR",.T.)
					SCR->CR_FILIAL 	:= xfilial("SCR")
					SCR->CR_num 	:= _cPedido
					SCR->CR_TIPO 	:= "PC"
					SCR->CR_GRUPO	:= SAL->AL_COD
					SCR->CR_USER	:= SAL->AL_USER
					SCR->CR_APROV	:= SAL->AL_APROV
					SCR->CR_NIVEL	:= SAL->AL_NIVEL
					SCR->CR_STATUS	:= IIF(SAL->AL_NIVEL=='01','02','01')
					SCR->CR_EMISSAO := DDATABASE
					SCR->CR_MOEDA	:= 1
					SCR->CR_TXMOEDA	:= 1
					SCR->(Msunlock())
								
					SAL->(Dbskip())
				Enddo
			Endif
		EndIF             

		_aDadVenc := aSort( _aDadVenc ,,, {|x,y| x[01] < y[01] } )
	
		//Inclusão, cópia ou Alteração
  		If (_nopcao == 3 .or. _nopcao == 4 .or. _nopcao == 9) .And. _nOpcA == 1
			//primeiro apaga todos os registros do pedido
    		Dbselectarea("ZZH")
    		ZZH->( DBSetOrder(1) )
   
    		If ZZH->( DBSeek(xFilial("ZZH") + alltrim(_cPedido) ) )
      			Do While alltrim(ZZH->ZZH_PEDIDO) == alltrim(_cPedido)
        			RecLock( "ZZH" , .F. ) 
        			ZZH->( DBDelete () )
        			MsUnlock()
        			ZZH-> ( DbSkip () )
      			Enddo
   	 		Endif
       
    		//Então reinclui     
    		For _nI := 1 To Len( _aDadVenc ) 
      			Dbselectarea("ZZH")
      			RecLock( "ZZH" , .T. ) 
      			ZZH->ZZH_FILIAL := xFilial("SC7")
      			ZZH->ZZH_PEDIDO := alltrim(_cPedido)
      			ZZH->ZZH_DATA   := _aDadVenc[_ni][1]
      			ZZH->ZZH_PRORP  := _aDadVenc[_ni][3]  
      			ZZH->ZZH_ITEMPC := _aDadVenc[_ni][4]
      			ZZH->ZZH_VALOR  := _aDadVenc[_ni][2]
      			ZZH->(MsUnlock())
    		Next _nI
 	 	Endif
    Endif
    
ElseIf _nopcao == 5 .And. _nOpcA == 1  //Exclusão

	U_DELSCR() //APAGA SCR DO PEDIDO

	Dbselectarea("ZZH")
	ZZH->( DBSetOrder(1) )
   
	if ZZH->( DBSeek(xFilial("SC7") + alltrim(_cPedido)))
		do while alltrim(ZZH->ZZH_PEDIDO) == alltrim(_cPedido) .and. ZZH->ZZH_FILIAL == xFilial("ZZH")
    		RecLock( "ZZH" , .F. ) 
    		ZZH->( DBDelete () )   	
    		ZZH->(MsUnlock())
       
    		ZZH-> ( DbSkip () )
    	enddo
    endif

	ZY2->( DBSETORDER(1) )
   
	if ZY2->( DBSEEK( xFilial("SC7") + ALLTRIM(_cPedido)))
		DO WHILE ALLTRIM(ZY2->ZY2_PEDIDO) == ALLTRIM(_cPedido) .AND. ZY2->ZY2_FILPED == xFilial("SC7")
           IF EMPTY(ZY2->ZY2_ORIGEM)
    		  ZY2->( RecLock( "ZY2" , .F. ) )
    		  ZY2->( DBDELETE() )   	
    		  ZY2->( MsUnlock() )
    		  ZY2->( DBSKIP() )
		   ENDIF
    	ENDDO
    ENDIF
	
	_cAliasZY1 := GetNextAlias()
	
	_cQryZY1 := "SELECT ZY1_FILIAL, ZY1_NUMPC, ZY1_SEQUEN, ZY1_DTMONI, ZY1_HRMONI, ZY1_COMENT, ZY1_CODUSR, ZY1_NOMUSR "
	_cQryZY1 += "FROM " + RetSqlName("ZY1") + " "
	_cQryZY1 += "WHERE ZY1_FILIAL = '" + xFilial("ZY1") + "' "
	_cQryZY1 += "  AND ZY1_NUMPC = '" + _cPedido + "' "
	_cQryZY1 += "  AND D_E_L_E_T_ = ' ' "
	_cQryZY1 := ChangeQuery(_cQryZY1)
	MPSysOpenQuery( _cQryZY1 , _cAliasZY1)

	If !(_cAliasZY1)->(Eof())
		While !(_cAliasZY1)->(Eof())
			_nSeq++
			(_cAliasZY1)->(dbSkip())
		End

		_nSeq++

		dbSelectArea("ZY1")
		ZY1->(dbSetOrder(1))
		ZY1->(RecLock("ZY1",.T.))
			Replace ZY1->ZY1_FILIAL	With xFilial("ZY1")
			Replace ZY1->ZY1_NUMPC	With _cPedido
			Replace ZY1->ZY1_SEQUEN	With StrZero(_nSeq++,4)
			Replace ZY1->ZY1_DTMONI	With dDataBase
			Replace ZY1->ZY1_HRMONI	With Time()
			Replace ZY1->ZY1_COMENT	With "********** O pedido " + _cPedido + " foi excluído. **********"
			Replace ZY1->ZY1_CODUSR	With __cUserID
			Replace ZY1->ZY1_NOMUSR	With AllTrim(UsrFullName(__cUserID))
		ZY1->(MsUnLock())
	EndIf
	(_cAliasZY1)->(dbCloseArea())
Endif

//==========================================================================================
// Tratamento feito para zerar os campos customizados, caso a rotina de cópia seja executada
//==========================================================================================
If IsInCallStack('A120COPIA') .or. (_nopcao == 4 .And. _nOpcA == 1)
	dbSelectArea('SC7')
	SC7->(dbSetOrder(1))
	SC7->(dbSeek(_cFil + _cPedido))
	
	While !SC7->(Eof()) .And. SC7->C7_FILIAL == _cFil .And. SC7->C7_NUM == _cPedido
		dbSelectArea("SY1")
		SY1->(dbSetOrder(3))
		SY1->(dbSeek(xFilial("SY1") + SC7->C7_USER))
		_lGrpLeite := Iif(SY1->Y1_GRUPCOM $ _cGrpLeite,.T.,.F.)  
	    _cAprLeite := Iif(_lGrpLeite,_cGrpALeite,"")//SY1->Y1_GRAPROV
	    
	    If !_lgrpleite
	    	_lGrpAuto := Iif(SY1->Y1_GRUPCOM $ _cGrpAuto,.T.,.F.)  
	    	_cAprAuto := Iif(_lGrpAuto,SY1->Y1_GRAPROV,"")
	    Endif
	    	
		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + SC7->C7_PRODUTO))
	
		If !(SB1->B1_TIPO $ cTipo)
			dbSelectArea("SBZ")
			SBZ->(dbSetOrder(1))
			SBZ->(dbSeek(xFilial("SBZ") + SC7->C7_PRODUTO))

			If SC7->C7_PRECO > SBZ->BZ_UPRC
				nDiff := ((SC7->C7_PRECO - SBZ->BZ_UPRC) / SBZ->BZ_UPRC) * 100
				If nDiff > nPtol
					lDiff := .T.
				EndIf
			EndIf
		EndIf

		If _lGrpLeite 
			_cGestorPC := U_ITGESTOR(_cGrpLeite, SC7->C7_USER )
		EndIF
		
		If _lGrpAuto 
			_cGestorPC := U_ITGESTOR(_cGrpAuto, SC7->C7_USER )
		EndIF

		RecLock("SC7", .F.)
		SC7->C7_I_GCOM	:= Space(TamSX3("C7_I_GCOM")[1])
		SC7->C7_I_DTLIB	:= StoD('//')
		SC7->C7_I_HRLIB	:= Space(TamSX3("C7_I_HRLIB")[1])
		SC7->C7_I_DTAPR	:= StoD('//')
		SC7->C7_I_HRAPR	:= Space(TamSX3("C7_I_HRAPR")[1])
		SC7->C7_I_SITWF	:= '1'
		SC7->C7_I_HTM	:= Space(TamSX3("C7_I_HTM")[1])
		SC7->C7_I_WFID	:= Space(TamSX3("C7_I_WFID")[1])
		SC7->C7_I_OBSAP	:= Space(TamSX3("C7_I_OBSAP")[1])
		SC7->C7_I_ENVIO	:= "00"

		If lFilPC .And. DtoS(SC7->C7_EMISSAO) >= cDatIni 
			Replace SC7->C7_CONAPRO With "B"
			If _lGrpLeite
				Replace SC7->C7_APROV	With Iif(!Empty(Alltrim(_cAprLeite)),_cAprLeite,"PENLIB")
				Replace SC7->C7_I_GCOM	With Iif(!Empty(Alltrim(_cGestorPC)),_cGestorPC,_cGestorPadrao)
				Replace SC7->C7_I_DTLIB	With Date()
				Replace SC7->C7_I_HRLIB	With Time()
			Elseif _lgrpauto
				Replace SC7->C7_APROV	With Iif(!Empty(Alltrim(_cAprauto)),_cAprAuto,"PENLIB")
				Replace SC7->C7_I_GCOM	With Iif(!Empty(Alltrim(_cGestorPC)),_cGestorPC,_cGestorPadrao)
				Replace SC7->C7_I_DTLIB	With Date()
				Replace SC7->C7_I_HRLIB	With Time()
			Else 
				Replace SC7->C7_APROV	With "PENLIB"
			EndIf
		Else
			Replace SC7->C7_CONAPRO With "L"							
			Replace SC7->C7_APROV	With ""
		EndIf

		If !Empty(SC7->C7_FORNECE) .And. !Empty(SC7->C7_LOJA)
			Replace SC7->C7_I_NFORN With Posicione("SA2",1,xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA,"A2_NOME")
		EndIf
		
		Replace SC7->C7_I_DESCD With Posicione("SB1",1,xFilial("SB1") + SC7->C7_PRODUTO,"B1_I_DESCD")
		
		If _lGrpLeite
			U_DELSCR() //APAGA SCR DO PEDIDO
			
			//Cria linhas de aprovador no SCR
			SAL->(Dbsetorder(1))
			If SAL->(Dbseek(xfilial("SAL")+_cAprLeite))
				Do while !(SAL->(Eof())) .and. alltrim(_cAprLeite) == SAL->AL_COD
					IF SAL->AL_MSBLQL = '1' 
						SAL->(Dbskip())  
						LOOP
					ENDIF
					Reclock("SCR",.T.)
					SCR->CR_FILIAL 	:= xfilial("SCR")
					SCR->CR_num 	:= _cPedido
					SCR->CR_TIPO 	:= "PC"
					SCR->CR_GRUPO	:= SAL->AL_COD
					SCR->CR_USER	:= SAL->AL_USER
					SCR->CR_APROV	:= SAL->AL_APROV
					SCR->CR_NIVEL	:= SAL->AL_NIVEL
					SCR->CR_STATUS	:= IIF(SAL->AL_NIVEL=='01','02','01')
					SCR->CR_EMISSAO := DDATABASE
					SCR->CR_MOEDA	:= 1
					SCR->CR_TXMOEDA	:= 1
					SCR->(Msunlock())
								
					SAL->(Dbskip())
				Enddo
			Endif
		ElseIf _lGrpAuto
			U_DELSCR() //APAGA SCR DO PEDIDO
			
			//Cria linhas de aprovador no SCR
			SAL->(Dbsetorder(1))
			If SAL->(Dbseek(xfilial("SAL")+_cAprauto))
				Do while !(SAL->(Eof())) .and. alltrim(_cAprauto) == SAL->AL_COD
					IF SAL->AL_MSBLQL = '1' 
						SAL->(Dbskip())  
						LOOP
					ENDIF
					Reclock("SCR",.T.)
					SCR->CR_FILIAL 	:= xfilial("SCR")
					SCR->CR_num 	:= _cPedido
					SCR->CR_TIPO 	:= "PC"
					SCR->CR_GRUPO	:= SAL->AL_COD
					SCR->CR_USER	:= SAL->AL_USER
					SCR->CR_APROV	:= SAL->AL_APROV
					SCR->CR_NIVEL	:= SAL->AL_NIVEL
					SCR->CR_STATUS	:= IIF(SAL->AL_NIVEL=='01','02','01')
					SCR->CR_EMISSAO := DDATABASE
					SCR->CR_MOEDA	:= 1
					SCR->CR_TXMOEDA	:= 1
					SCR->(Msunlock())
								
					SAL->(Dbskip())
				Enddo
				Endif
		Else
			U_DELSCR() //APAGA SCR DO PEDIDO
		EndIf
		MsUnLock()
		SC7->(dbSkip())
	EndDo
EndIf

If lDiff
	U_ACOM011V(_cFil, _cPedido, .F.)
EndIf

_cItens := ""

If Len(_aDifItens) > 0
   U_MCOM004Z(_cFil,_cPedido,_aDifItens,Inclui,.F.)
EndIf

FWRestArea(_aArea)
FWRestArea(_aAreaSC7)
Return

/*
===============================================================================================================================
Programa----------: DELSCR
Autor-------------: Josué Danich Prestes
Data da Criacao---: 27/10/2017
Descrição---------: Apaga SCR do pedido de compras posicionado
Parametros--------: Nenhum 
Retorno-----------: Nenhum
===============================================================================================================================
*/
User function delscr

Local _apeds:= {} As Array
Local _ni	:= 0 As Numeric

SCR->(Dbsetorder(1)) //CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
If SCR->(Dbseek(SC7->C7_FILIAL+"PC"+alltrim(SC7->C7_NUM)))
	Do while !(SCR->(Eof())) .and. SC7->C7_FILIAL == SCR->CR_FILIAL .AND. SCR->CR_TIPO == 'PC' .AND. alltrim(SCR->CR_NUM) == alltrim(SC7->C7_NUM)
		aadd(_apeds,SCR->(Recno()))
		SCR->(Dbskip())
	Enddo
	
	For _ni := 1 to len(_apeds)
		SCR->(Dbgoto(_apeds[_ni]))
		Reclock("SCR",.F.)
		SCR->(Dbdelete())
		SCR->(MSunlock())
	Next _ni
Endif

Return

User Function MT120VA(aItens As Array)
   _aDifItens := aItens
Return
