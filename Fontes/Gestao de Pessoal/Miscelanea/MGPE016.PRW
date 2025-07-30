/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço  |20/09/2022| Chamado 41279. Ajuste para funcionamento via Schedule.
Igor Melgaço  |04/10/2022| Chamado 41279. Ajuste para funcionamento via Schedule.
Lucas Borges  |13/10/2024| Chamado 48465. Retirada da função de conout
=========================================================================================================================================================
Analista         - Programador    - Inicio     - Envio      - Chamado - Motivo da Alteração
---------------------------------------------------------------------------------------------------------------------------------------------------------
Alexandro       - Igor Melgaço    - 02/05/2025 - 06/05/2025 - 50525   - Ajuste para remoção de diretório local C:\SMARTCLIENT\.
=========================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'
#include "rwmake.ch"
#include "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"   
#INCLUDE "RESTFUL.CH"


Static _lScheduler:= FWGetRunSchedule() .OR. SELECT("SX3") <= 0

/*
===============================================================================================================================
Programa----------: MGPE016
Autor-------------: Josué Danich Prestes
Data da Criacao---: 21/12/2016
Descrição---------: Rotina de leitura de equipamentos de ponto - Chamado 18026
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGPE016()

Private _lcontinua:= .T.
   
If _lScheduler

	FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE016"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01601"/*cMsgId*/, "MGPE01601 - Inicio Workflow de leitura de equipamentos de ponto."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01';
	TABLES "SX2, SX5, SP0 ";
	MODULO 'GPE'

	MV_PAR01 := ""
	MV_PAR02 := dDatabase - 31
	MV_PAR03 := dDatabase
	MV_PAR04 := "0"
	MV_PAR05 := 1

	U_MGPE016P()

	RESET ENVIRONMENT
	
Else
	Do while _lcontinua

		_lcontinua := .F.
		//_bProcess    := {|_oSelf| U_MGPE016P(_oSelf)  }
		_bProcess    := {|| _lcontinua:=.T.  }

		tNewProcess():New( "MGPE016", "Lê equipamentos ponto", _bProcess, "Rotina de leitura de equipamentos de ponto","MGPE016")
		
		IF _lcontinua
			fwmsgrun(,{|_oself| U_MGPE016P(_oself)},"Aguarde...","Processando relatório...")
		ENDIF
		
	Enddo
EndIf
Return

/*
===============================================================================================================================
Programa----------: MGPE016P
Autor-------------: Josué Danich Prestes
Data da Criacao---: 21/12/2016
Descrição---------: Lê equipamentos de ponto
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGPE016P(_oSelf)

Local _nconta	:=0 
Local _nproce	:=0
Local _nconta2	:= 0
Local _cAlias	:= GetNextAlias()
Local _nHandle	:= 0
Local _cDirTemp	:= ""

cQuery := " SELECT count(*) TOT  from " 
cQuery += retsqlname("SP0") + " SP0 WHERE SP0.D_E_L_E_T_ = ' '  " 

If !_lScheduler .And. !empty(alltrim(MV_PAR01))
	cQuery +=  " and SP0.P0_FILIAL = '" + cfilant + "'"
EndIf

cQuery += " AND (SP0.P0_I_CTRID ='W' OR SP0.P0_I_CTRID ='A') " 

If !empty(alltrim(MV_PAR01))
	cQuery += " AND SP0.P0_RELOGIO IN " + FormatIn( MV_PAR01 , ";" )
Endif

If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf

If !_lScheduler
	_oself:cCaption := "Lendo equipamentos"
	ProcessMessages()
Else
	FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE016"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01602"/*cMsgId*/, "MGPE01602 - Lendo equipamentos"/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
EndIf


DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , _cAlias , .T. , .F. )
	
_nconta := (_cAlias)->TOT

cQuery := " SELECT P0_RELOGIO,P0_FILIAL,P0_I_IP, P0_I_CTRID, P0_I_TIPO, P0_ARQUIVO   from " 
cQuery += retsqlname("SP0") + " SP0 WHERE SP0.D_E_L_E_T_ = ' '  "

If !_lScheduler .And. !empty(alltrim(MV_PAR01))
	cQuery +=  " and SP0.P0_FILIAL = '" + cfilant + "'"
EndIf

cQuery += " AND (SP0.P0_I_CTRID ='W' OR SP0.P0_I_CTRID ='A') " 

If !empty(alltrim(MV_PAR01)) 
	cQuery += " AND SP0.P0_RELOGIO IN " + FormatIn( MV_PAR01 , ";" )
Endif
 
If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , _cAlias , .T. , .F. )

If (_cAlias)->(Eof())

	If !_lScheduler
		u_itmsg("Não foram encontrados relógios com os parâmetros informados!","Atenção",,1)
	Else
		FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE016"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01603"/*cMsgId*/, "MGPE01603 - Não foram encontrados relógios com os parâmetros informados!"/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	EndIf
	
	Return
	
Endif

Do while .not. (_cAlias)->(Eof())
	_nproce++

	If !_lScheduler
		_oself:cCaption := "Lendo equipamento " + strzero(_nproce,3) + " de " + strzero(_nconta,3)
	Else
		FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE016"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01604"/*cMsgId*/, "MGPE01604 - Lendo equipamento " + strzero(_nproce,3) + " de " + strzero(_nconta,3)/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	EndIf
	
	If val(MV_PAR04) == 0 
		NNSU := 1
	Else
		NNSU := val(MV_PAR04)
	Endif
	
	ZG6->(Dbgotop())
	
	If ZG6->(Dbseek((_cAlias)->P0_FILIAL+(_cAlias)->P0_RELOGIO))
		If ZG6->ZG6_DATA <= MV_PAR02
			NNSU := ZG6->ZG6_NSRI
			ZG6->(DbSkip())
			
			Do while (_cAlias)->P0_FILIAL == ZG6->ZG6_FILIAL .AND. (_cAlias)->P0_RELOGIO == ZG6->ZG6_RELOGI .AND. ZG6->ZG6_DATA < MV_PAR02
				NNSU := ZG6->ZG6_NSRI
				ZG6->(Dbskip())
			Enddo
		Endif
	Endif
	_cDirTemp := GetTempPath()
	_narqle := ferase(_cDirTemp+"temp.txt")
		
	If _narqle == -1 .and. file(_cDirTemp+"temp.txt")
		If !_lScheduler
			u_itmsg("Falha ao preparar o arquivo AFD","Erro",,1)
		Else
			FWLogMsg("ERROR"/*cSeverity*/, /*cTransactionId*/, "MGPE016"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01605"/*cMsgId*/, "MGPE01605 - Falha ao preparar o arquivo AFD"/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		EndIf
		Return
	Endif 

	//Tipo de processamento, usar o seguro para computadores que travarem com waitrun
	If MV_PAR05 = 2
		shellexecute("Open", "C:\Windows\System32\cmd.exe"," /c "+_cDirTemp+"LE.BAT " +  alltrim((_cAlias)->P0_I_IP)+ " " + alltrim(str(nnsu))  + _cDirTemp + "temp.txt",_cDirTemp,1)
		If !_lScheduler
			Do while !(u_itmsg("O processo de leitura terminou?","Continua?",,3,2,2))
			Enddo
		Endif
	Else
		waitrun(_cDirTemp+"le.bat " +  alltrim((_cAlias)->P0_I_IP)  + " " + alltrim(str(nnsu))  + _cDirTemp + "temp.txt", 3 )
	Endif
	
	//Copia arquivo para o servidor para usar
	
	_ctemp := "\spool\" + "temp.txt"
	_narqle := ferase(_ctemp)
		
	If _narqle == -1 .and. file(_ctemp)
		If !_lScheduler
			u_itmsg("Falha ao copiar o arquivo AFD","Erro",,1)
		Else
			FWLogMsg("ERROR"/*cSeverity*/, /*cTransactionId*/, "MGPE016"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01606"/*cMsgId*/, "MGPE01606 - Falha ao copiar o arquivo AFD"/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		EndIf
		Return
	Endif 
	
	_narqle := CpyT2S(_cDirTemp + "temp.txt","\spool")
	
	If !(_narqle)
		If !_lScheduler
			u_itmsg("Falha ao copiar o arquivo AFD","Erro",,1)
		Else
			FWLogMsg("ERROR"/*cSeverity*/, /*cTransactionId*/, "MGPE016"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01607"/*cMsgId*/, "MGPE01607 - Falha ao copiar o arquivo AFD"/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		EndIf
		Return
	Endif 
	
	_narqle := FT_FUSE(_ctemp)
		
	If _narqle == -1
		If !_lScheduler
			u_itmsg("Falha ao copiar o arquivo AFD","Erro",,1)
		Else
			FWLogMsg("ERROR"/*cSeverity*/, /*cTransactionId*/, "MGPE016"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01608"/*cMsgId*/, "MGPE01608 - Falha ao copiar o arquivo AFD"/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		EndIf
		Return
	Endif 

	_nconta2 := FT_FLastRec()

	If !_lScheduler
		_oself:cCaption := "Lendo arquivo resposta"
	Else
		FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE016"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01609"/*cMsgId*/, "MGPE01609 - Lendo arquivo resposta"/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	EndIf
		
	//Detecta layout de client
	FT_FGOTOP() //POSICIONA NO TOPO DO ARQUIVO
	_clinha := FT_FREADLN()

	_anovo := {}
	aadd(_anovo,_clinha + chr(13) + chr(10))	
	FT_FSKIP()
	_nconti := 0
	_nposi := 0
	_dult := stod("20010101")

	Do while .not. FT_FEOF()
		_clinha := FT_FREADLN()
		If stod(substr(_clinha,15,4)+substr(_clinha,13,2)+substr(_clinha,11,2)) > _dult
			_dult := stod(substr(_clinha,15,4)+substr(_clinha,13,2)+substr(_clinha,11,2))
			//Atualiza índice de nsr
			If ZG6->(Dbseek((_cAlias)->P0_FILIAL+(_cAlias)->P0_RELOGIO+DTOS(_dult)))
				Reclock("ZG6",.F.)
				ZG6->ZG6_NSRI := val(substr(_clinha,1,9))
			Else
				Reclock("ZG6",.T.)
				ZG6->ZG6_FILIAL := (_cAlias)->P0_FILIAL
				ZG6->ZG6_RELOGI := (_cAlias)->P0_RELOGIO
				ZG6->ZG6_DATA := _dult
				ZG6->ZG6_NSRI := val(substr(_clinha,1,9))
			Endif
			ZG6->(MSUNLOCK())
		Endif
	
		//Filtra só registros de marcação e dentro do filtro de data
		If substr(_clinha,10,1) == "3" .and. stod(substr(_clinha,15,4)+substr(_clinha,13,2)+substr(_clinha,11,2)) >= MV_PAR02 .AND. stod(substr(_clinha,15,4)+substr(_clinha,13,2)+substr(_clinha,11,2)) <= MV_PAR03
			aadd(_anovo,substr(_clinha,1,len(_clinha)-1)+ chr(13) + chr(10))
			_nconti++
		Endif

		FT_FSKIP()
		_nposi++

		If !_lScheduler
			_oself:cCaption :="Lendo arquivo resposta, posicao " + strzero(_nposi,15) + " de " + strzero(_nconta2,15)
		Else
			FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE016"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01610"/*cMsgId*/, "MGPE01610 - Lendo arquivo resposta, posicao " + strzero(_nposi,15) + " de " + strzero(_nconta2,15)/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		EndIf
	Enddo

	FT_FUSE() //Fecha arquivo temp.txt

	aadd(_anovo,"999999999000000000" + strzero(_nconti,9) + "0000000000000000009" + chr(13) + chr(10)) 

	//Cria arquivo temporario
	
	If _narqle == -1 .and. file(_ctemp)
		If !_lScheduler
			u_itmsg("Falha ao criar arquivo temporario","Erro",,1)
		Else
			FWLogMsg("ERROR"/*cSeverity*/, /*cTransactionId*/, "MGPE016"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01611"/*cMsgId*/, "MGPE01611 - Falha ao criar arquivo temporario"/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		EndIf
		Return
	Endif 

	_nHandle := FCreate(_ctemp)
	_ni := 1

	Do while _ni <= len(_anovo)
		FWrite(_nHandle,_anovo[_ni])
		_ni++

		If !_lScheduler
			//_oself:incregua2("Gravando arquivo  " + ALLTRIM((_cAlias)->P0_ARQUIVO) + "linha " + strzero(_ni,15) + " de " + strzero(len(_anovo),15))
			_oself:cCaption :="Gravando arquivo  " + ALLTRIM((_cAlias)->P0_ARQUIVO) + "linha " + strzero(_ni,15) + " de " + strzero(len(_anovo),15)
		Else
			FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE016"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01612"/*cMsgId*/, "MGPE01612 - Gravando arquivo  " + ALLTRIM((_cAlias)->P0_ARQUIVO) + "linha " + strzero(_ni,15) + " de " + strzero(len(_anovo),15)/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		EndIf

	Enddo

	FClose(_nHandle)	

	//copia arquivo definitivo
	__CopyFile(_ctemp, ALLTRIM((_cAlias)->P0_ARQUIVO))

	(_cAlias)->(Dbskip())
Enddo

If !_lScheduler
	u_itmsg("Arquivos atualizados","Processo concluído",,2)
Else
	FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE016"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01613"/*cMsgId*/, "MGPE01613 - Arquivos atualizados"/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
EndIf
  
_lcontinua := .F.

Return
