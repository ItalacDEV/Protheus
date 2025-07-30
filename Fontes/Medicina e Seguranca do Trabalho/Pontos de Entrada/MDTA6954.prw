/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 10/04/2018 | Chamado 23960. Realiza��o de ajustes nas rotinas de entrega e devolu��o de EPI.
-------------------------------------------------------------------------------------------------------------------------------
Josu� Danich  | 31/08/2018 | Chamado 25248. Controle de processamento paralelo.
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 02/10/2019 | Chamado 28346. Removidos os Warning na compila��o da release 12.1.25.
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 05/02/2024 | Chamado 46134. Retirada a chamada da funcao de validacao MDTA6954P(oproc).
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

Static _lDevAlmox := .F. // Indica que a rotina foi ou n�o chamada da fun��o customizada Dev.Almox.
Static _aRecnosEPIs := {}  // Array para armazenar os Recnos de EPIs que dever�oser impressos.
/*
===============================================================================================================================
Programa----------: MDTA6954
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 14/06/2016
===============================================================================================================================
Descri��o---------: Ponto de Entrada executado como �ltima valida��o e grava��es espec�ficas - Chamado 15889
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MDTA6954()

Local _aArea	:= GetArea()
Local _cMatric	:= SRA->RA_MAT
Local _nPosEpi	:= aScan(aHeader,{|x| AllTrim(x[2]) == "TNF_CODEPI"	})
Local _nPosFor	:= aScan(aHeader,{|x| AllTrim(x[2]) == "TNF_FORNEC"	})
Local _nPosLoj	:= aScan(aHeader,{|x| AllTrim(x[2]) == "TNF_LOJA"	})
Local _nPosCap	:= aScan(aHeader,{|x| AllTrim(x[2]) == "TNF_NUMCAP"	})
Local _nPosDte	:= aScan(aHeader,{|x| AllTrim(x[2]) == "TNF_DTENTR"	})
Local _nPosHre	:= aScan(aHeader,{|x| AllTrim(x[2]) == "TNF_HRENTR"	})
Local _nPosBmp	:= aScan(aHeader,{|x| AllTrim(x[2]) == "COLBMP"		})
Local _nPosQtdDev := aScan(aHeader,{|x| AllTrim(x[2]) == "TNF_QTDEVO"}) 
Local _nPosDtRec := aScan(aHeader,{|x| AllTrim(x[2]) == "TNF_DTRECI"})  
//Local oproc
Local _lRet := .T.
Local _nRegAtu := TNF->(Recno())
Local _nI 

//Verifica processamento paralelo de grava��o de Epi
//fwmsgrun(,{ |oproc| _lret := MDTA6954P(oproc)},"Aguardando processamento paralelo...","Aguarde...")

//Se n�o conseguir processamento exclusivo n�o permite grava��o
//If .not. _lret
//	Return .F.
//EndIf

DBSelectArea("TNF")
TNF->(DBSetOrder(1)) // TNF_FILIAL+TNF_FORNEC+TNF_LOJA+TNF_CODEPI+TNF_NUMCAP+TNF_MAT+DTOS(TNF_DTENTR)+TNF_HRENTR                                                                        
If TNF->(DBSeek(xFilial("TNF") + aCols[n][_nPosFor] + aCols[n][_nPosLoj] + aCols[n][_nPosEpi] + aCols[n][_nPosCap] + _cMatric + DtoS(aCols[n][_nPosDte]) + aCols[n][_nPosHre]))
   If TNF->TNF_I_TPDV == "S" .And. TNF->TNF_QTDENT == TNF->TNF_QTDEVO .And. aCols[n][_nPosBmp] == "BR_VERMELHO"
      RecLock("TNF",.F.)
      TNF->TNF_I_TPDV := "N"
      TNF->(MsUnLock())
   Else        
      If ! _lDevAlmox        //IsInCallStack("MDT695DVPA") // "NG695TudOk"
         If TNF->TNF_I_TPDV = 'T' .Or. TNF->TNF_I_TPDV = 'R' // Pela rotina padr�o de devolu��o de EPIs, devolu��o parcial, n�o h� baixa de estoques.
	        RecLock("TNF",.F.)
	        TNF->TNF_I_TPDV := " " 
	        TNF->(MsUnLock())
	     EndIf
	  EndIf
   EndIf
EndIf

//================================================================================
// Carrega array ADevEPI com os registros que deve�o ter o recibo impresso.
//================================================================================
_aRecnosEPIs := {}

For _nI := 1 To Len(aCols)
    // TNF_FILIAL+TNF_FORNEC+TNF_LOJA+TNF_CODEPI+TNF_NUMCAP+TNF_MAT+DTOS(TNF_DTENTR)+TNF_HRENTR                                                                        
    If TNF->(DbSeek(xFilial("TNF") + aCols[_nI][_nPosFor] + aCols[_nI][_nPosLoj] + aCols[_nI][_nPosEpi] + aCols[_nI][_nPosCap] + _cMatric + DtoS(aCols[_nI][_nPosDte]) + aCols[_nI][_nPosHre]))
       _nPosQtdDev := aScan(aHeader,{|x| AllTrim(x[2]) == "TNF_QTDEVO"})   
              
       If aCols[_nI,_nPosQtdDev] <> TNF->TNF_QTDEVO .And. !Empty(aCols[_nI,_nPosDtRec]) // TNF->TNF_DTRECI
          Aadd(ADevEPI,TNF->(Recno()))
          Aadd(_aRecnosEPIs,TNF->(Recno()))
       EndIf
    EndIf
Next _nI

//================================================================================
// Carrega o array ADevEPI com os EPIs liberados na rotina de estoques e custos.
//================================================================================
TNF->(DbSetOrder(3)) // TNF_FILIAL+TNF_MAT+TNF_CODEPI+DTOS(TNF_DTENTR)+TNF_HRENTR                                                                                                       
TNF->(DbSeek(xFilial("TNF")+M->RA_MAT))
   
Do While !TNF->(Eof()) .And. TNF->TNF_FILIAL+TNF->TNF_MAT == xFilial("TNF")+M->RA_MAT
      
   If TNF->TNF_I_IMPR == "1" // Sim
      Aadd(ADevEPI,TNF->(Recno()))
      Aadd(_aRecnosEPIs,TNF->(Recno()))
      
      TNF->(RecLock("TNF",.F.))
      TNF->TNF_I_IMPR := "2" // N�o
      TNF->(MsUnlock())
   EndIf
      
   TNF->(DbSkip())
EndDo

TNF->(DbGoTo(_nRegAtu))

RestArea(_aArea)
Return _lRet

/*
===============================================================================================================================
Programa----------: MDT6954G
Autor-------------: Julio de Paula Paz
Data da Criacao---: 31/10/2017
===============================================================================================================================
Descri��o---------: Muda conte�do de vari�vel est�tica para indicar se a rotina Customizada Dev.Almox. foi acionada ou n�o.
===============================================================================================================================
Parametros--------: _lValStatic = Valor do conte�do da vari�vel est�tica.(.T. = True / .F. = False)
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MDT6954G(_lValStatic)

Begin Sequence
   _lDevAlmox := _lValStatic
End Sequence

Return

/*
===============================================================================================================================
Programa----------: MDT6954H
Autor-------------: Julio de Paula Paz
Data da Criacao---: 14/11/2017
===============================================================================================================================
Descri��o---------: Zerar ou retornar o conte�do da vari�vel est�tica _aRecnosEPIs.
===============================================================================================================================
Parametros--------: _cTipoFunc = Tipo de funcionalidade da rotina (Zerar ou retornar o conte�do da vari�vel estatica
                                 _aRecnosEPIs).
===============================================================================================================================
Retorno-----------: _nRet = Retorna o conte�do da vari�vel estatica _aRecnosEPIs
===============================================================================================================================
*/
User Function MDT6954H(_cTipoFunc)

Local _aRet := {}

Begin Sequence
   If _cTipoFunc == "INICIALIZA"
      _aRecnosEPIs := {}
   Else
      _aRet := AClone(_aRecnosEPIs)
   EndIf

End Sequence

Return _aRet

/*
===============================================================================================================================
Programa----------: MDT6954P
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 31/08/2018
===============================================================================================================================
Descri��o---------: Valida��o de processamento paralelo
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: _lret - permite processamento exclusivo ou n�o
===============================================================================================================================

Static Function MDTA6954P(oproc)

Local _lret := .F.
Local _nid := 0
Local _nti := seconds()
Local _dti := date()
Local _cuser := " "
Local _cmaquina := " "

Do While Date() == _dti .and. Seconds()-_nti < 5

	//Verifica se tem processamento paralelo registrado em vari�vel p�blica
	_nid := Val(GetGlbValue("MDTA6954"))

	//Se tem processamento verifica se thread est� ativa e se n�o � a mesma do processo atual
	If _nid > 0 .and. _nid != Val(AllTrim(STR(ThreadID())))

		_amonitor := GetUserInfoArray()
	
		_npos := Ascan(_amonitor,{|aVal| aVal[3] == _nid})
	
		//Se a thread n�o est� mais ativa atualiza a vari�vel p�blica e libera processamento
		If _npos == 0 
			PutGlbValue("MDTA6954",ALLTRIM(STR(ThreadID())))
			Return .T.
		Else
			_cuser    := _amonitor[_npos][1]
			_cmaquina := _amonitor[_npos][2]
		EndIf
	
	Else

		//Se n�o achou processamento registrado ou � a mesma thread atual atualiza vari�vel p�blica e libera processamento
		PutGlbValue("MDTA6954",ALLTRIM(STR(ThreadID())))
		Return .T.
	
	EndIf

	Sleep(100)
	
Enddo

MsgStop("Existe processamento de entrega de EPI em execu��o, por favor tente novamente. Processo em execu��o pelo usu�rio " + _cuser + " na esta��o " + _cmaquina,"MDTA695401")

Return _lret*/
