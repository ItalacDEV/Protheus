/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------        

===============================================================================================================================
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
Programa----------: MGPE027
Autor-------------: Igor Melgaço
Data da Criacao---: 31/10/2023
===============================================================================================================================
Descrição---------: Rotina de leitura de equipamentos de ponto via API - Chamado 45400
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGPE027()
Local _oSelf     := Nil
Local _aParRet   := {}
Local _aParAux   := {}
Local _bOK       := {||.T.  }
Local _nTamFun   := 0
Local _nI        := 0
//Local _lSchedule := FWGetRunSchedule() .OR. SELECT("SX3") <= 0

Default nOper := 0

If _lScheduler //Cria ambiente se for schedule
   
	MV_PAR01 := Space(99)
   MV_PAR02 := dDatabase
   MV_PAR03 := Space(20)

	RPCSetType(3)
	RpcSetEnv( "01" , "01" ,,,"GPE", "SCHEDULE_ATUA" , {'SRA','SP0'} )
	Sleep( 5000 ) //Aguarda 5 segundos para subam as configurações do ambiente.

   MGPE027P(_oSelf)

Else

   _nTamFun   := TamSX3("RA_MAT")[1]

   MV_PAR01 := Space(99)
   MV_PAR02 := CTOD("")
   MV_PAR03 := Space(20)

	AADD( _aParAux , { 1 , "Equipamentos:              "	, MV_PAR01, ""	   , ""	, "LS2SP0"  , "" , 099, .F. } )
	AADD( _aParAux , { 1 , "Data Inicial de Marcações: "	, MV_PAR02, "@D"	, ""  , ""	      , "" , 050, .F. } )
	AADD( _aParAux , { 1 , "NSU de:                    "	, MV_PAR03, ""	   , ""	, ""  		, "" , 020, .F. } )

	For _nI := 1 To Len( _aParAux )
		aAdd( _aParRet , _aParAux[_nI][03] )
	Next _nI

	If ParamBox( _aParAux , " Integração de Dados com o sistema ControlID " , @_aParRet, _bOK )
		FWMSGRUN( ,{|_oSelf|  MGPE027P(_oSelf)  } , "Hora Inicial: "+Time()+" Processando integração Control ID... " )
	Endif
      
Endif

Return

/*
===============================================================================================================================
Programa----------: MGPE027P
Autor-------------: Igor Melgaço
Data da Criacao---: 31/10/2023
===============================================================================================================================
Descrição---------: Lê equipamentos de ponto
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MGPE027P(_oSelf)

Local _nconta	:= 0 
Local _nproce	:= 0
Local _cAlias	:= GetNextAlias()
Local _nHandle	:= 0
Local i        := 0
Local aArquivo := {}
Local _lExec   := .F.
Local _nconti  := 0
Local _dult    := CTOD("")

cQuery := " SELECT count(*) TOT  from " 
cQuery += retsqlname("SP0") + " SP0 WHERE SP0.D_E_L_E_T_ <> '*'  " 

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
	ConOut("[MGPE027] - Lendo equipamentos" )
EndIf


DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , _cAlias , .T. , .F. )
	
_nconta := (_cAlias)->TOT

cQuery := " SELECT P0_RELOGIO,P0_FILIAL,P0_I_IP, P0_I_CTRID, P0_I_TIPO, P0_ARQUIVO, P0_TPREP   from " 
cQuery += retsqlname("SP0") + " SP0 WHERE SP0.D_E_L_E_T_ <> '*'  "

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
		U_ItConout("Não foram encontrados relógios com os parâmetros informados!")
	EndIf
	
	Return
	
Else

	//_oself:SetRegua1( _nconta )
	//_oself:IncRegua1("Lendo equipamentos")

	Do while .not. (_cAlias)->(Eof())

				
		//Bloco de leitura de equipamentos REP
		_nproce++

		If !_lScheduler
			_oself:cCaption := "Lendo equipamento " + strzero(_nproce,3) + " de " + strzero(_nconta,3)
		Else
			U_ItConout("Lendo equipamento " + strzero(_nproce,3) + " de " + strzero(_nconta,3))
		EndIf

		If Val(MV_PAR03) == 0 
			NNSU := 1
		Else
			NNSU := Val(MV_PAR03)
		Endif
		
		/*
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
		*/

		//Prepara dados para conexão com o Relogio
		l671 := !((_cAlias)->P0_TPREP == "1" .OR. Empty(Alltrim((_cAlias)->P0_TPREP)))
		cUrl   := "https://"+ALLTRIM((_cAlias)->P0_I_IP)
		cParms := '/login.fcgi'

		aHeader := {}
		Aadd(aHeader, "Content-Type: application/json")

		cBodyJson :=  '{'
		cBodyJson +=  '"login": "admin",'
		cBodyJson +=  '"password": "admin"'
		cBodyJson +=  '}'

		cResult := "" 
		
		//Tenta conexão com o relogio
		If U_MGPE026RES(cUrl,cParms,aHeader,cBodyJson,@cResult,5)

			cSession := cResult

			cUrl      := "https://"+ALLTRIM((_cAlias)->P0_I_IP)
			cParms    := '/get_afd.fcgi?session='+cSession+Iif(l671,'&mode=671','')
			If Empty(Alltrim(MV_PAR03))
				cBodyJson := '{"initial_date":{"day": '+Alltrim(Str(Day(MV_PAR02)))+',"month": '+Alltrim(Str(Month(MV_PAR02)))+',	"year": '+Alltrim(Str(Year(MV_PAR02)))+'}}'
			Else
				cBodyJson := '{"initial_nsr":'+Alltrim(MV_PAR03)+'}'
			EndIf
			U_MGPE026RES(cUrl,cParms,aHeader,cBodyJson,@cResult,6)

			cResult := StrTran(cResult,(_cAlias)->P0_ARQUIVO+".txt","")

			aArquivo := STRTOKARR(cResult,Chr(13)+Chr(10))

			aDel(aArquivo,Len(aArquivo))
			aSize(aArquivo,Len(aArquivo)-1)

			_dult := stod("20010101")

			_nconti := 0

			For i := 1 To Len(aArquivo)
				_clinha := aArquivo[i]

				If stod(substr(_clinha,15,4)+substr(_clinha,13,2)+substr(_clinha,11,2)) > _dult
				
					_dult := stod(substr(_clinha,15,4)+substr(_clinha,13,2)+substr(_clinha,11,2))

					//Atualiza índice de nsr
					If ZG6->(Dbseek((_cAlias)->P0_FILIAL+(_cAlias)->P0_RELOGIO+DTOS(_dult)))
				
						//Reclock("ZG6",.F.)
						//ZG6->ZG6_NSRI := val(substr(_clinha,1,9))
						
					Else
						/*
						Reclock("ZG6",.T.)
						ZG6->ZG6_FILIAL := (_cAlias)->P0_FILIAL
						ZG6->ZG6_RELOGI := (_cAlias)->P0_RELOGIO
						ZG6->ZG6_DATA := _dult
						ZG6->ZG6_NSRI := val(substr(_clinha,1,9))
						*/
					Endif
					
					//ZG6->(MSUNLOCK())
					
				Endif

				//Filtra só registros de marcação e dentro do filtro de data
				If substr(_clinha,10,1) == "3" //.and. stod(substr(_clinha,15,4)+substr(_clinha,13,2)+substr(_clinha,11,2)) >= MV_PAR02 //.AND. stod(substr(_clinha,15,4)+substr(_clinha,13,2)+substr(_clinha,11,2)) <= MV_PAR02

					_nconti++

				Endif

			Next
			aadd(aArquivo,"999999999000000000" + strzero(_nconti,9) + "0000000000000000009" + chr(13) + chr(10)) 


			_ctemp := "\temp\" + cusername + "_temp_"+DTOS(Date())+"_"+StrTran(TIME(),":","")+"_temp.txt"

   		_nHandle := FCreate(_ctemp)
	
   		_ni := 1
	
   		Do while _ni <= len(aArquivo)
	
				FWrite(_nHandle,aArquivo[_ni]+CHR(13)+CHR(10) )
				_ni++

				If !_lScheduler
					_oself:cCaption := "Gravando arquivo  " + ALLTRIM((_cAlias)->P0_ARQUIVO) + "linha " + strzero(_ni,15) + " de " + strzero(len(aArquivo),15)
				Else
					U_ItConout("Gravando arquivo  " + ALLTRIM((_cAlias)->P0_ARQUIVO) + "linha " + strzero(_ni,15) + " de " + strzero(len(aArquivo),15))
				EndIf

   		Enddo
	
   		FClose(_nHandle)	

   		//copia arquivo definitivo

			//If File(ALLTRIM((_cAlias)->P0_ARQUIVO))
			//	fErase(ALLTRIM((_cAlias)->P0_ARQUIVO))
			//EndIf

   		_lExec := __CopyFile(_ctemp, ALLTRIM((_cAlias)->P0_ARQUIVO))

			If !_lExec
				cLocal := "c:\smartclient\" + cusername + "_temp_"+DTOS(Date())+"_"+StrTran(TIME(),":","")+".txt"

				__CopyFile(_ctemp, cLocal)
				
				_lExec := __CopyFile(cLocal, ALLTRIM((_cAlias)->P0_ARQUIVO))

				If !_lExec

					cMsg := "Falha ao copiar o arquivo AFD "+ ALLTRIM((_cAlias)->P0_ARQUIVO)+CHR(13)+CHR(10)+CHR(13)+CHR(10)
					cMsg += "Arquivo temporário gerado na pasta " + _ctemp

					If !_lScheduler
						u_itmsg(,"Erro",cMsg,1)
					Else
						U_ItConout(cMsg)
					EndIf

				EndIf

				//Return
			Else
				cMsg := "Arquivo baixado :"+ALLTRIM((_cAlias)->P0_ARQUIVO)
				If _oSelf <> Nil
					_oSelf:cCaption := cMsg
					ProcessMessages() 
				Else
					U_ItConout(cMsg)           
				EndIf
			Endif 
		Else
			cMsg := "Eq. " + strzero(_nProce,3) + " de " + strzero(_nConta,3) +  " Filial: " + (_cAlias)->P0_FILIAL + " Rel: " + Alltrim((_cAlias)->P0_RELOGIO) + " IP: " + Alltrim((_cAlias)->P0_I_IP) + " Falha de Login: " + Time()

			If _oSelf <> Nil
				_oSelf:cCaption := cMsg
				ProcessMessages() 
			Else
				U_ItConout(cMsg)           
			EndIf
		EndIf

		(_cAlias)->(Dbskip())
	Enddo

Endif

If !_lScheduler
	u_itmsg("Arquivos atualizados","Processo concluído",,2)
Else
	U_ItConout("Arquivos atualizados")
EndIf
  
_lcontinua := .F.

Return

