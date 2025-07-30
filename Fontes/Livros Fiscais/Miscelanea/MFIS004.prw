/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor           |    Data    |                              Motivo                      										 
------------------------------------------------------------------------------------------------------------------------------- 
Darcio Spörl     | 04/01/2017 | Chamado 17867. Foi criada a rotina para reprocessamento CDA 1298.
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer    | 18/04/2017 | Chamado 19729. Ajuste para gerar CDA só para venda fora do estado de Goias.
-------------------------------------------------------------------------------------------------------------------------------
Lucas B. Ferreira| 02/10/2019 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25.
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz        | 19/07/2021 | Chamado 37176. Realização de alterações e implementações de melhorias na rotina.
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz        | 11/08/2021 | Chamado 37442. Realização de ajustes nas condições que definem a gravação da tabela CDA.
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer    | 11/08/2022 | Chamado 40950. Grvacao de 3 novos campo:  CDA_SDOC, CDA_ORIGEM, CDA_TPNOTA
------------------:------------:----------------------------------------------------------------------------------------------:
Antonio Neves    | 27/11/2023 | Chamado 45390. Ajuste para a perda de credenciamento do transportador junto ao sefaz GO. 
------------------:------------:----------------------------------------------------------------------------------------------:
Igor Melgaço     | 05/07/2024 | Chamado 47548. Ajuste para a gravação orreta do campo CDA_NUMITE.
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: MFIS004 
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 04/01/2017
===============================================================================================================================
Descrição---------: Rotina para reprocessamento CDA 1298          
===============================================================================================================================
Parametros--------: Nenhum                               
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MFIS004() 

Local _aSays		:= {}
Local _aButtons		:= {}
Local _cPerg		:= "MFIS004"
Local _lExec		:= .T.
Local _nOpca		:= 0

Private _lCda1298	:= U_ItGetMV("IT_CDA1298",.F.)
Private _cCaj1298	:= U_ItGetMV("IT_CAJ1298","")
Private _cInf1298	:= U_ItGetMV("IT_INF1298","")
Private _nRed1298   := U_ItGetMV("IT_RED1298",0)
Private _nAlq1298	:= 0
Private _cAlq1298	:= U_ItGetMV("IT_ALQ1298","12")

If !_lCda1298
	MsgStop("Não é permitida a execução desta rotina nesta filial. Solicite a ativação desta filial para a execução desta.","MFI00401")
	Return .F.
EndIf

Pergunte( _cPerg , .F. )

aAdd( _aSays , OemToAnsi( " Este programa tem como objetivo alimentar a tabela CDA com as operações"	) )
aAdd( _aSays , OemToAnsi( " cujo a Italac assume o papel de substituto tributário nas operações "	) )
aAdd( _aSays , OemToAnsi( " interestaduais de saída referentes a IN1298."	) )

aAdd( _aButtons , { 05 , .T. , {| | Pergunte( _cPerg )			} } )
aAdd( _aButtons , { 01 , .T. , {|o| _nOpca := 1 , o:oWnd:End()	} } )
aAdd( _aButtons , { 02 , .T. , {|o| _nOpca := 0 , o:oWnd:End()	} } )

FormBatch( "MFIS004" , _aSays , _aButtons ,, 200 , 500 )
 
If _nOpca == 1

	If MV_PAR01 > MV_PAR02
		MsgStop("Datas início e fim para reprocessamento da CDA não são válidas! A data de início deve ser menor ou igual à data fim.","MFIS00402")
		Return  .F.
	EndIf
	
	If _lExec .And. MsgYesNo( 'Confirma execução ?' , 'MFIS00403' )
		Processa( {|| U_MFIS004I() } , 'Reprocessamento CDA 1298'			, 'Aguarde...' )
	EndIf

EndIf

Return

/*
===============================================================================================================================
Programa----------: MFIS004I 
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 04/01/2017
===============================================================================================================================
Descrição---------: Função do reprocessamento CDA 1298          
===============================================================================================================================
Parametros--------: Nenhum                               
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MFIS004I()

Local _cQryTot	:= ""
Local _cQryDad	:= ""
Local _nI		:= 0
Local _cSeq     := StrZero(1,LEN(CDA->CDA_SEQ))
Local _cSeqSD2  := AVKEY(StrZero(1,LEN(SD2->D2_ITEM)),"CDA_NUMITE") 
Local _nJ, _nCDAValor, _nValRed, _lArrayUFAliq 

_cQryTot := "SELECT COUNT(*) AS TOTAL "
_cQryTot += "FROM " + RetSqlName("SF2") + " "
_cQryTot += "WHERE F2_FILIAL = '" + xFilial("SF2") + "' "
_cQryTot += "  AND F2_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "
_cQryTot += "  AND F2_DOC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
_cQryTot += "  AND F2_SERIE BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
_cQryTot += "  AND F2_CLIENTE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR09 + "' "
_cQryTot += "  AND F2_LOJA BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR10 + "' "
_cQryTot += "  AND D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQryTot),"TRBTOT",.T.,.F.)

dbSelectArea("TRBTOT")
TRBTOT->(dbGoTop())

If TRBTOT->TOTAL > 0

	ProcRegua(TRBTOT->TOTAL)

	_cQryDad := "SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_ESPECIE, F2_I_FRET, F2_I_CTRA, F2_I_LTRA, F2_EST, F2_TIPO "
	_cQryDad += "FROM " + RetSqlName("SF2") + " "
	_cQryDad += "WHERE F2_FILIAL = '" + xFilial("SF2") + "' "
	_cQryDad += "  AND F2_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "
	_cQryDad += "  AND F2_DOC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	_cQryDad += "  AND F2_SERIE BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
	_cQryDad += "  AND F2_CLIENTE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR09 + "' "
	_cQryDad += "  AND F2_LOJA BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR10 + "' "
	_cQryDad += "  AND D_E_L_E_T_ = ' '"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQryDad),"TRBDAD",.T.,.F.)

	TRBDAD->(dbGoTop())
	SA2->(dbSetOrder(1))
	CDA->(dbSetOrder(1))//CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI  +CDA_FORMUL+ CDA_NUMERO      +CDA_SERIE        +CDA_CLIFOR         +CDA_LOJA       +CDA_NUMITE+CDA_SEQ+  CDA_CODLAN+CDA_CALPRO

    _lArrayUFAliq := .T.
    If _cAlq1298 == "12" // Siguinifica que o parâmetro com as Strings com estados e aliquota para filial não existe. 
	   _nAlq1298 := 0    // E a função ItgetMv retornou valor Default = "12".
	   _lArrayUFAliq := .F.
	Else 
       _aUFAliq := U_MFIS004E(_cAlq1298) // Retorna um array para a filial logada, formado por {{"Estado","aliquota"},{"Estado","aliquota"},...}
	EndIf

	If !(TRBDAD->(Eof()))

	   DO While !(TRBDAD->(Eof()))
			//_nJ := 0
			_nI := _nI + 1
			IncProc( 'Processando Registro: ['+ StrZero( _nI , 6 ) +'] de ['+ StrZero( TRBTOT->TOTAL , 6 ) +']' )

			SA2->(dbSeek(xFilial("SA2") + TRBDAD->F2_I_CTRA + TRBDAD->F2_I_LTRA))
            
            If _lArrayUFAliq 
	           _nJ := Ascan(_aUFAliq, {|x| x[1] == TRBDAD->F2_EST})
			   If _nJ > 0
				  _cAlq1298 := _aUFAliq[_nJ,2]
				  _nAlq1298 := Val(_cAlq1298)
			   Else
                  _nAlq1298 := 0
			   EndIf 
			EndIf 

            If (TRBDAD->F2_FILIAL $ "01,02,06,08,09,0A,0B" .And. SA2->A2_I_CLASS $ "A,T,G,C" .And. SA2->A2_I_I1298 <> 'L' .And. SA2->A2_I_I1298 <> 'S' .AND. !EMPTY(TRBDAD->F2_I_FRET) .AND. SM0->M0_ESTENT <> SA2->A2_EST);
               .OR. (TRBDAD->F2_FILIAL $ "01,02,06,08,09,0A,0B" .And. SA2->A2_I_CLASS $ "A,T,G,C" .And. SA2->A2_I_I1298 <> 'L' .And. SA2->A2_I_I1298 <> 'S' .AND. !EMPTY(TRBDAD->F2_I_FRET) .AND. SM0->M0_ESTENT = SA2->A2_EST  .AND. SM0->M0_ESTENT <> TRBDAD->F2_EST);
               .Or. (TRBDAD->F2_FILIAL $ "20,23,24,25" .And. SA2->A2_I_CLASS $ "A,T,G,C" .And. !EMPTY(TRBDAD->F2_I_FRET) .AND.  TRBDAD->F2_EST <> SM0->M0_ESTENT .AND. SM0->M0_ESTENT <> SA2->A2_EST);							 
               .Or. (TRBDAD->F2_FILIAL $ "40,04" .And. SA2->A2_I_CLASS $ "A,T,G,C" .And. !EMPTY(TRBDAD->F2_I_FRET) .AND. SM0->M0_ESTENT <> SA2->A2_EST)	

			   If CDA->(dbSeek(TRBDAD->F2_FILIAL + "S" + TRBDAD->F2_ESPECIE + "S" + TRBDAD->F2_DOC + TRBDAD->F2_SERIE + TRBDAD->F2_CLIENTE + TRBDAD->F2_LOJA + _cSeqSD2 + _cSeq + _cCaj1298))
				  CDA->(RecLock("CDA",.F.))
				  CDA->(dbDelete())
				  CDA->(MsUnLock())
			   EndIF

                _nCDAValor := TRBDAD->F2_I_FRET * (_nAlq1298 / 100)   // 1000 * 10 /100 = 100  
				
				If _nRed1298 > 0
				   _nValRed   := _nCDAValor * _nRed1298 / 100         // 100 * 20 / 100 = 20
				   _nCDAValor := _nCDAValor - _nValRed                // 100 - 20 = 80 
                EndIf 
				If Empty(SA2->A2_I_F1298) .OR. TRBDAD->F2_EMISSAO > DTOS(SA2->A2_I_F1298)
				CDA->(RecLock("CDA",.T.))
				CDA->CDA_FILIAL	:= TRBDAD->F2_FILIAL
				CDA->CDA_TPMOVI	:= "S"
				CDA->CDA_ESPECI	:= TRBDAD->F2_ESPECIE
				CDA->CDA_FORMUL	:= "S"
				CDA->CDA_NUMERO	:= TRBDAD->F2_DOC
				CDA->CDA_SERIE	:= TRBDAD->F2_SERIE
				CDA->CDA_CLIFOR	:= TRBDAD->F2_CLIENTE
				CDA->CDA_LOJA	:= TRBDAD->F2_LOJA
				CDA->CDA_NUMITE	:= _cSeqSD2
				CDA->CDA_SEQ	:= _cSeq
				CDA->CDA_CODLAN	:= _cCaj1298
				CDA->CDA_CALPRO	:= 	"1"
				CDA->CDA_BASE	:= TRBDAD->F2_I_FRET
				CDA->CDA_ALIQ	:= _nAlq1298
				CDA->CDA_VALOR	:= _nCDAValor // TRBDAD->F2_I_FRET * (_nAlq1298 / 100)
				CDA->CDA_TPREG	:= ""
				CDA->CDA_CODOLD	:= ""
				CDA->CDA_IFCOMP := _cInf1298
				CDA->CDA_TPLANC	:= "2"
				CDA->CDA_VL197	:= ""
				CDA->CDA_CLANC	:= ""
				CDA->CDA_SDOC   := TRBDAD->F2_SERIE
                CDA->CDA_ORIGEM := '1'
                CDA->CDA_TPNOTA := TRBDAD->F2_TIPO
				CDA->(MsUnLock())
				EndIf
			EndIf

			(TRBDAD->(dbSkip()))
		End
	Else
		Aviso( 'MFIS00404' , 'Não foi retornado nenhum dado para sua consulta!' , {'Fechar'} )
	EndIf

	TRBDAD->(dbCloseArea())
Else
	Aviso( 'MFIS00405' , 'Não foi retornado nenhum dado para sua consulta!' , {'Fechar'} )
EndIf

TRBTOT->(dbCloseArea())

Return

/*
===============================================================================================================================
Programa----------: MFIS004N
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 04/01/2017
===============================================================================================================================
Descrição---------: Função do reprocessamento CDA 1298, chamada do ponto de entrada M460FIM          
===============================================================================================================================
Parametros--------: Nenhum                               
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MFIS004N()

Local _aSalvArea:= GetArea()
Local _cCaj1298	:= U_ItGetMV("IT_CAJ1298","")
Local _cInf1298	:= U_ItGetMV("IT_INF1298","")
Local _nAlq1298	
Local _cSeq     := StrZero(1,LEN(CDA->CDA_SEQ))
Local _cSeqSD2  := AVKEY(StrZero(1,LEN(SD2->D2_ITEM)),"CDA_NUMITE") 
Local _cAlq1298 := U_ItGetMV("IT_ALQ1298","12")
Local _nJ, _nCDAValor, _nValRed 
Local _nRed1298 := U_ItGetMV("IT_RED1298",0)

SA2->(dbSetOrder(1))
SA2->(dbSeek(xFilial("SA2") + SF2->F2_I_CTRA + SF2->F2_I_LTRA))
If _cAlq1298 == "12"
   _nAlq1298 := 0
Else 
   _aUFAliq := U_MFIS004E(_cAlq1298)
EndIf

If (SF2->F2_FILIAL $ "01,02,06,08,09,0A,0B" .And. SA2->A2_I_CLASS $ "A,T,G,C" .And. SA2->A2_I_I1298 <> 'L' .And. SA2->A2_I_I1298 <> 'S' .AND. !EMPTY(SF2->F2_I_FRET) .AND. SM0->M0_ESTENT <> SA2->A2_EST);
   .OR. (SF2->F2_FILIAL $ "01,02,06,08,09,0A,0B" .And. SA2->A2_I_CLASS $ "A,T,G,C" .And. SA2->A2_I_I1298 <> 'L' .And. SA2->A2_I_I1298 <> 'S' .AND. !EMPTY(SF2->F2_I_FRET) .AND. SM0->M0_ESTENT = SA2->A2_EST  .AND. SM0->M0_ESTENT <> SF2->F2_EST);
   .Or. (SF2->F2_FILIAL $ "20,23,24,25" .And. SA2->A2_I_CLASS $ "A,T,G,C" .And. !EMPTY(SF2->F2_I_FRET) .AND.  SF2->F2_EST <> SM0->M0_ESTENT .AND. SM0->M0_ESTENT <> SA2->A2_EST);							 
   .Or. (SF2->F2_FILIAL $ "40,04" .And. SA2->A2_I_CLASS $ "A,T,G,C" .And. !EMPTY(SF2->F2_I_FRET) .AND. SM0->M0_ESTENT <> SA2->A2_EST)	
  
   If _cAlq1298 <> "12"
	  _nJ := Ascan(_aUFAliq, {|x| x[1] == SF2->F2_EST})
	  If _nJ > 0
	     _cAlq1298 := _aUFAliq[_nJ,2]
		 _nAlq1298 := Val(_cAlq1298)
	  Else
         _nAlq1298 := 0
	  EndIf 
   EndIf 

	CDA->(dbSetOrder(1))//CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SERIE      +CDA_CLIFOR        +CDA_LOJA+CDA_NUMITE+CDA_SEQ+CDA_CODLAN+CDA_CALPRO
	If CDA->(dbSeek(SF2->F2_FILIAL + "S" + SF2->F2_ESPECIE + "S" + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA + _cSeqSD2 + _cSeq + _cCaj1298 ))
	   CDA->(RecLock("CDA",.F.))
	   CDA->(dbDelete())
	   CDA->(MsUnLock())
	EndIF

     _nCDAValor := SF2->F2_I_FRET * (_nAlq1298 / 100)   // 1000 * 10 /100 = 100  
				
	 If _nRed1298 > 0
	   _nValRed   := _nCDAValor * _nRed1298 / 100         // 100 * 20 / 100 = 20
	   _nCDAValor := _nCDAValor - _nValRed                // 100 - 20 = 80 
    EndIf 

	CDA->(RecLock("CDA",.T.))
	CDA->CDA_FILIAL	:= SF2->F2_FILIAL
	CDA->CDA_TPMOVI	:= "S"
	CDA->CDA_ESPECI	:= SF2->F2_ESPECIE
	CDA->CDA_FORMUL	:= "S"
	CDA->CDA_NUMERO	:= SF2->F2_DOC
	CDA->CDA_SERIE	:= SF2->F2_SERIE
	CDA->CDA_CLIFOR	:= SF2->F2_CLIENTE
	CDA->CDA_LOJA	:= SF2->F2_LOJA
	CDA->CDA_NUMITE	:= _cSeqSD2
	CDA->CDA_SEQ	:= _cSeq
	CDA->CDA_CODLAN	:= _cCaj1298
	CDA->CDA_CALPRO	:= 	"1"
	CDA->CDA_BASE	:= SF2->F2_I_FRET
	CDA->CDA_ALIQ	:= _nAlq1298
	CDA->CDA_VALOR	:= _nCDAValor // SF2->F2_I_FRET * (_nAlq1298 / 100)
	CDA->CDA_TPREG	:= ""
	CDA->CDA_CODOLD	:= ""
	CDA->CDA_IFCOMP := _cInf1298
	CDA->CDA_TPLANC	:= "2"
	CDA->CDA_VL197	:= ""
	CDA->CDA_CLANC	:= ""
	CDA->CDA_SDOC   := SF2->F2_SERIE
    CDA->CDA_ORIGEM := '1'
    CDA->CDA_TPNOTA := SF2->F2_TIPO
    CDA->(MsUnLock())

EndIf

RestArea(_aSalvArea)

Return .T.


/*
===============================================================================================================================
Programa----------: MFIS004E
Autor-------------: Julio de Paula Paz
Data da Criacao---: 19/07/2021
===============================================================================================================================
Descrição---------: Recebe um parâmetro e retorna um Array com siglas de estados e suas respectiva alicotas.        
===============================================================================================================================
Parametros--------: _cSiglaAliq = string com siglas dos estados e suas respectivas aliquotas.                            
===============================================================================================================================
Retorno-----------: _aRet = Array com as siglas dos estado e suas repectivas aliquotas.
===============================================================================================================================
*/
User Function MFIS004E(_cSiglaAliq)
Local _aUF, _nI, _nJ, _nX 
Local _nPosIni
Local _aRet := {}
Local _cUF, _cTaxa 

Begin Sequence
   If Empty(_cSiglaAliq)
      Break
   EndIf 

   _aUF := {}
   Aadd(_aUF,"RO")
   Aadd(_aUF,"AC")
   Aadd(_aUF,"AM")
   Aadd(_aUF,"RR")
   Aadd(_aUF,"PA")
   Aadd(_aUF,"AP")
   Aadd(_aUF,"TO")
   Aadd(_aUF,"MA")
   Aadd(_aUF,"PI")
   Aadd(_aUF,"CE")
   Aadd(_aUF,"RN")
   Aadd(_aUF,"PB")
   Aadd(_aUF,"PE")
   Aadd(_aUF,"AL")	
   Aadd(_aUF,"MG")
   Aadd(_aUF,"ES")
   Aadd(_aUF,"RJ")
   Aadd(_aUF,"SP")
   Aadd(_aUF,"PR")
   Aadd(_aUF,"SC")
   Aadd(_aUF,"RS")
   Aadd(_aUF,"MS")
   Aadd(_aUF,"MT")
   Aadd(_aUF,"GO")
   Aadd(_aUF,"DF")
   Aadd(_aUF,"SE")
   Aadd(_aUF,"BA")
   Aadd(_aUF,"EX")
   
   For _nI := 1 To Len(_aUF)
       _cUF   := _aUF[_nI]
       _cTaxa :=  0

	   _nPosIni := AT(_cUF, _cSiglaAliq)
	   If _nPosIni == 0
          Loop
	   EndIf 

	   _nPosIni := _nPosIni + 2 
	   _nX := 0

	   For _nJ := _nPosIni To Len(_cSiglaAliq)
	       If SubStr(_cSiglaAliq,_nJ,1) $ "0123456789"
		      _nX += 1 
		   Else 
		      Exit
           EndIf 
       Next 

       If _nX > 0
          _cTaxa := SubStr(_cSiglaAliq,_nPosIni,_nX)
       Else 
	      Loop   
	   EndIf 

       Aadd(_aRet,{_cUF,_cTaxa})

   Next

End Sequence

Return _aRet
