/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Igor Melga�o  |19/10/2022| Chamado 41618. Alterarado FAIXHORAACES de 0 para 2.
Igor Melga�o  |08/11/2022| Chamado 41618. Alterarado FAIXHORAACES de 2 para 0.
Lucas Borges  |13/10/2024| Chamado 48465. Retirada da fun��o de conout
Lucas Borges  |23/07/2025| Chamado 51340. Ajustar fun��o para valida��o de ambiente de teste
===============================================================================================================================
*/
#include "Protheus.ch"
#include "TopConn.ch"
#include "Fileio.ch"
#include "TBICONN.CH"
#include "TBICODE.CH"
#include "APWEBSRV.CH"  
/*
===============================================================================================================================
Programa----------: MGPE017
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 24/05/2017
Descri��o---------: Fonte criado para atualizar dados Suricato.
Parametros--------: _lweb - indica se est� sendo chamado a partir do webservice.
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGPE017(_lweb,_lLe_So_SA2)

Local oproc
Local _cfils 
Local _afils 
Local _ni := 1

Default _lweb := .F. 
Default _lLe_So_SA2:=.F.

If !(isincallstack("MDIEXECUTE") .or. isincallstack("SIGAADV")) //Detecta se est� sendo chamao na tela
	If _lweb
		FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01701"/*cMsgId*/, "MGPE01701 - Iniciando processo MGPE017 no web service..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		
        IF _lLe_So_SA2
		   U_MGPE017M()
        ELSE
		   U_MGPE017Y()
        ENDIF
		
		FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01702"/*cMsgId*/, "MGPE01702 - Iniciado processo MGPE017 no web service, encerrando processo local."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		
	Else
		FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01703"/*cMsgId*/, "MGPE01703 - Verificando semaforo..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		If !LockByName("MGPE017",.F.,.F.,.T.)
			FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01704"/*cMsgId*/, "MGPE01704 - Rotina ja em execu��o..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
			Return
		EndIf

		FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01705"/*cMsgId*/, "MGPE01705 - Abrindo o ambiente..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
   
		RPCSetType(3)
		RpcSetEnv( "01" , '01' ,,,"COM", "SCHEDULE_SURICATO" , {'ZP1','SRA'} )
		Sleep( 5000 ) //Aguarda 5 segundos para subam as configura��es do ambiente.

		_cfils := u_itgetmv("IT_FILSUR","01;10")
		_afils := StrTokArr(_cfils,";")
		_lVersao_Nova:=U_ITGETMV("ITSURNV",.F.)
		
		IF _lLe_So_SA2
		   U_MGPE017M()
			Return
		ENDIF

		For _ni := 1 to len(_afils)
			FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01706"/*cMsgId*/, "MGPE01706 - Atualizando dados para filial " + _afils[_ni]/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
			cfilant := _afils[_ni]

			U_MGPE017P(oproc)
			U_MGPE017P(oproc) //Executa duas vezes para garantir a atualiza��o de cracha de funcion�rio novo

			FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01707"/*cMsgId*/, "MGPE01707 - Completou atualiza��o de dados para filial " + _afils[_ni]/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		Next
	 
		FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01708"/*cMsgId*/, "MGPE01708 - Verificando Demitidos x Cad. Cliente para todas filiais"/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		U_MGPE0177()//Verificando Demitidos x Cad. Cliente
		FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01709"/*cMsgId*/, "MGPE01709 - Completou a verifica��o Demitidos x Cad. Cliente"/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		
		UnLockByName("MGPE017",.F.,.F.,.T.)
		FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01710"/*cMsgId*/, "MGPE01710 - Completou a execu��o da rotina"/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		
	Endif
Else
	If u_itmsg("Deseja atualizar dados do Suricato?","Exporta��o",,3,2,2)
      _lVersao_Nova:=U_ITGETMV("ITSURNV",.F.)
	   FWMSGRUN(,{|oProc|  U_MGPE017P(oProc) },'Aguarde processamento...','Lendo dados a serem exportados...')
		u_itmsg("Processo completado!","Aten��o",,2)
	Else
		If u_itmsg("Deseja veridicar Demitidos x Clientes?","Aten��o",,3,2,2)
	  		FWMSGRUN(,{|oproc|  U_MGPE0177(oproc)},'Aguarde processamento...','Lendo dados...')
		else
			If u_itmsg("Deseja atualizar dados do Suricato com os dados do Motoristas (ZL0)? ","Aten��o",,3,2,2)
				 _cMotoristas:=MGPE17F3()
				IF !EMPTY(_cMotoristas)
					FWMSGRUN(,{|oproc|  U_MGPE017M(oproc,_cMotoristas)},'Aguarde processamento...','Lendo dados...')
				ENDIF   
			else
				U_ITMSG("Processo cancelado!","Aten��o",,1)
			endif
		endif
	Endif
Endif

Return

/*
===============================================================================================================================
Programa----------: MGPE017P
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 24/05/2017
Descri��o---------: Rotina de execu��o principal
Parametros--------: oproc - objeto da barra de processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGPE017P(oproc)

Default oproc := nil

IF valtype(oproc) = "O"
   oproc:cCaption := ("1/3 - Atualizando colaboradores no Suricato...")
   ProcessMessages()
ENDIF

U_MGPE0171(oproc)

IF valtype(oproc) = "O"
   oproc:cCaption := ("2/3 - Atualizando crachas no Suricato...")
   ProcessMessages()
ENDIF

U_MGPE0172(oproc)

//Atualiza afastamentos
IF valtype(oproc) = "O"
   oproc:cCaption := ("3/3 - Atualizando afastamentos no Suricato...")
   ProcessMessages()
ENDIF

U_MGPE0175(oproc)

IF !valtype(oproc) = "O"//S� roda no Schedule
   U_MGPE0177()//Verificando Demitidos x Cad. Cliente
ENDIF

Return Nil

/*
===============================================================================================================================
Programa----------: MGPE0171
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 24/05/2017
Descri��o---------: Fun��o respons�vel pela exporta��o dos dados de colaboradores
Parametros--------: oproc - objeto da barra de processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGPE0171(oproc)

Local _cQry		:= ""
Local _ntot := 0
Local _npos := 1
Local _ngrprep := u_itgetmv("IT_SURREP",1)
Local _nusabio := u_itgetmv("IT_SURBIO",1)
Default oproc := nil

FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01711"/*cMsgId*/, "MGPE01711 - 1/3 -Atualizando dados de colaboradores, lendo dados de funcion�rios..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

_cQry := "SELECT RA_FILIAL,RA_SITFOLH, RA_DEMISSA,RA_MAT, RA_NOME, RA_DEMISSA,RA_ADMISSA,RA_SEXO,RA_NASC,RA_PIS,RA_I_PSIT,RA_I_ENVD,RA_I_SURIC, RA_SEXO, RA_CIC,R_E_C_N_O_ REC "
_cQry += "FROM " + RetSqlName("SRA") + " SRA "
_cQry += "WHERE RA_FILIAL = '" + xFilial("SRA") + "' "
_cQry += "  AND RA_CATFUNC IN ('M') "
_cQry += "  AND D_E_L_E_T_ = ' ' "
_cQry += "  AND RA_SITFOLH <> 'D' "
_cQry += "  AND RA_PIS > ' ' "
_cQry += " ORDER BY RA_FILIAL, RA_MAT "	


If select ("TRBSRA") > 0
	TRBSRA->(Dbclosearea())
Endif

dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBSRA" , .T., .F. )

dbSelectArea("TRBSRA")
Count to _ntot
TRBSRA->(dbGoTop())

If !TRBSRA->(Eof())
	While !TRBSRA->(Eof())
		IF valtype(oproc) = "O"
			oproc:cCaption := ("1/3 - Atualizando dados de colaboradores - " + strzero(_npos,9) + " de " + strzero(_ntot,9))
			ProcessMessages()
		ENDIF
		_npos++
		
		If !val(alltrim(TRBSRA->RA_PIS)) > 0
			TRBSRA->(Dbskip())
			Loop
		Endif
		
		//Verifica se existe cadastro do funcion�rio no Suricato
		_cQry := "select idcolab,situafas,dataafas,horaafas,numepis,numecpf from SURICATO.tbcolab WHERE  "
		_cQry += " codimatr = " + alltrim(STR(val(TRBSRA->RA_MAT))) + " AND CODIEMPR = " + ALLTRIM(STR(VAL(TRBSRA->RA_FILIAL)))

		If select ("TRBCOL") > 0
			dbselectarea("TRBCOL")
			TRBCOL->(Dbclosearea())
		Endif

		dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBCOL" , .T., .F. )
		dbSelectArea("TRBCOL")

		//Se n�o existir cria cadastro cria novo
		If TRBCOL->(Eof())
			FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01712"/*cMsgId*/, "MGPE01712 - 1/3 - Atualizando dados de colaboradores, incluindo pessoa para matricula " + TRBSRA->RA_FILIAL + "/" + TRBSRA->RA_MAT + "..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		
			//Inclui cadastro de pessoa
			_cQry := "insert into suricato.tbpessoa (nomepess) values ('" + ALLTRIM(TRBSRA->RA_NOME) +  "')"
			_nres := TCSqlExec(_cQry)
			
			Reclock("ZGV",.T.)
			ZGV->ZGV_FILIAL := TRBSRA->RA_FILIAL
			ZGV->ZGV_MAT    := TRBSRA->RA_MAT
			ZGV->ZGV_DATA   := DATE()
			ZGV->ZGV_HORA   := TIME()
			ZGV->ZGV_COMAND := _cQry
			ZGV->ZGV_RESULT := _nres
			ZGV->ZGV_COMENT := "1/3 - Atualizando dados de colaboradores, incluindo pessoa para matricula " + TRBSRA->RA_FILIAL + "/" + TRBSRA->RA_MAT
			ZGV->(Msunlock())					
			
			If _nres == 0 //Se incluiu cadastro de pessoa com sucesso
				_cQry := "select idpessoa, nomepess from suricato.tbpessoa where nomepess = '" + ALLTRIM(TRBSRA->RA_NOME) +  "' order by idpessoa desc"
				If select ("TRBPES") > 0
					dbselectarea("TRBPES")
					TRBPES->(Dbclosearea())
				Endif

				dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBPES" , .T., .F. )
				dbSelectArea("TRBPES")
				
				If !TRBPES->(Eof()) .AND. alltrim(TRBPES->nomepess) == alltrim(TRBSRA->RA_NOME) 
					FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01713"/*cMsgId*/, "MGPE01713 - 1/3 - Atualizando dados de colaboradores, incluindo funcion�rio para matricula " + TRBSRA->RA_FILIAL + "/" + TRBSRA->RA_MAT + "..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
					
					_cQry :=  "insert into suricato.tbcolab (idpessoa,codiempr,tipocola,codimatr,apelcola,dataadmi,sexocola,datanasc,numecpf,numepis) "
					_cQry +=  " values (" + alltrim(str(TRBPES->idpessoa)) 
					_cQry +=  " , " + alltrim(str(val(TRBSRA->RA_FILIAL))) 
					_cQry +=  " ,1  , " + alltrim(str(val(TRBSRA->RA_MAT))) 
					_cQry +=  " ,'" + alltrim(SUBSTR(TRBSRA->RA_NOME,1,10)) + "' "
					_cQry +=  " ,TO_DATE('" + alltrim(TRBSRA->RA_ADMISSA) + "','YYYYMMDD') "
					_cQry +=  " ,'" + ALLTRIM(TRBSRA->RA_SEXO) + "' "
					_cQry +=  " ,TO_DATE('" + alltrim(TRBSRA->RA_NASC) + "','YYYYMMDD') "
					_cQry +=  " ,'" + ALLTRIM(TRBSRA->RA_CIC) + "' "
					_cQry +=  " ," + alltrim(str(val(TRBSRA->RA_PIS))) + ")"
					
					_nres := TCSqlExec(_cQry)

					Reclock("ZGV",.T.)
					ZGV->ZGV_FILIAL := TRBSRA->RA_FILIAL
					ZGV->ZGV_MAT    := TRBSRA->RA_MAT
					ZGV->ZGV_DATA   := DATE()
					ZGV->ZGV_HORA   := TIME()
					ZGV->ZGV_COMAND := _cQry
					ZGV->ZGV_RESULT := _nres
					ZGV->ZGV_COMENT := "1/3 - Atualizando dados de colaboradores, incluindo funcionario para matricula " + TRBSRA->RA_FILIAL + "/" + TRBSRA->RA_MAT
					ZGV->(Msunlock())					
					
					If _nres == 0
						FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01714"/*cMsgId*/, "MGPE01714 - 1/3 -Atualizando dados de colaboradores, incluido com sucesso funcion�rio para matricula " + TRBSRA->RA_FILIAL + "/" + TRBSRA->RA_MAT + "..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
					Else
						FWLogMsg("WARN"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01715"/*cMsgId*/, "MGPE01715 - 1/3 - Atualizando dados de colaboradores, FALHA ao incluir funcion�rio para matricula " + TRBSRA->RA_FILIAL + "/" + TRBSRA->RA_MAT + "..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
					Endif
				Else
					FWLogMsg("WARN"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01716"/*cMsgId*/, "MGPE01716 - 1/3 - Atualizando dados de colaboradores, FALHA ao incluir pessoa para matricula " + TRBSRA->RA_FILIAL + "/" + TRBSRA->RA_MAT + "..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
				Endif
			Else
				FWLogMsg("WARN"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01717"/*cMsgId*/, "MGPE01717 - 1/3 - Atualizando dados de colaboradores, FALHA ao incluir pessoa para matricula " + TRBSRA->RA_FILIAL + "/" + TRBSRA->RA_MAT + "..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
			Endif
		
		 //Se j� existe cadastro verifica se precisa atualizar
		Elseif !(TRBCOL->NUMEPIS == val(TRBSRA->RA_PIS) ) .or. !(TRBCOL->NUMECPF == val(TRBSRA->RA_CIC) )
			_cQry := " UPDATE SURICATO.TBCOLAB SET NUMEPIS = " + ALLTRIM(TRBSRA->RA_PIS) + ", NUMECPF = " + ALLTRIM(TRBSRA->RA_CIC) 
			_cQry += " WHERE IDCOLAB = " + alltrim(STR(TRBCOL->IDCOLAB))
			_nres := TCSqlExec(_cQry)
			FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01718"/*cMsgId*/, "MGPE01718 - 1/3 - Atualizando dados de colaboradores, atualizando dados do colaborador - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

			Reclock("ZGV",.T.)
			ZGV->ZGV_FILIAL := TRBSRA->RA_FILIAL
			ZGV->ZGV_MAT    := TRBSRA->RA_MAT
			ZGV->ZGV_DATA   := DATE()
			ZGV->ZGV_HORA   := TIME()
			ZGV->ZGV_COMAND := _cQry
			ZGV->ZGV_RESULT := _nres
			ZGV->ZGV_COMENT := "1/3 - Atualizando dados de colaboradores, atualizando dados do colaborador - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))
			ZGV->(Msunlock())					
		Endif
				
		//verifica na tabela de colaboradores e se tiver verifica e atualiza tabela de acessos
		_cQry := "select idcolab,situafas,dataafas,horaafas,numepis from SURICATO.tbcolab WHERE  "
		_cQry += " codimatr = " + alltrim(STR(val(TRBSRA->RA_MAT))) + " AND CODIEMPR = " + ALLTRIM(STR(VAL(TRBSRA->RA_FILIAL)))

		If select ("TRBCOL") > 0
			TRBCOL->(Dbclosearea())
		Endif

		dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBCOL" , .T., .F. )

		dbSelectArea("TRBCOL")

		//se existe verifica se tem tabela de acesso
		If !TRBCOL->(Eof())
			_cQry := "select idcolab,veripermaces,codiperm,permacesferi,permacessaba,permacesdomi,permacesvisi,faixhoraaces,contantidupl, "
            _cQry += " colarecevisi,veriafas,autosaidcola,autohoraextr,colautilveic,grauconfbiom,colaretibene,datavaliaso,datatreisegu, "
            _cQry += " datapendplan,codiplan,contcredrefe,tempminialmo,tempminiperm,tolecontperm,contbiom,idcolabsubs, regiponto, gruprepid "
            _cQry += " from SURICATO.tbacesscolab WHERE idcolab =  " + alltrim(str(TRBCOL->IDCOLAB))

			If select ("TRBACE") > 0
				TRBACE->(Dbclosearea())
			Endif

			dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBACE" , .T., .F. )
			dbSelectArea("TRBACE")

			//se existe verifica se tem tabela de acesso
			If !TRBACE->(Eof())
				//Verifica se precisa atualizar campos
				If !( TRBACE->VERIPERMACES = 'S' .AND.;
					  TRBACE->AUTOSAIDCOLA = 'N' .AND.;
					  TRBACE->CODIPERM = 1 .AND.;
					  TRBACE->PERMACESFERI = 1 .AND.;
					  TRBACE->PERMACESSABA = 1 .AND.;
					  TRBACE->PERMACESDOMI = 1 .AND.;
					  TRBACE->PERMACESVISI = 1 .AND.;
					  TRBACE->FAIXHORAACES = 0 .AND.;
					  TRBACE->CONTANTIDUPL = 'S' .AND.;
					  TRBACE->COLARECEVISI = 'S' .AND.;
					  TRBACE->VERIAFAS = 'S' .AND.;
					  TRBACE->AUTOSAIDCOLA = 'N' .AND.;
					  TRBACE->AUTOHORAEXTR = 'N' .AND.;
					  TRBACE->COLAUTILVEIC = 'N' .AND.;
					  TRBACE->GRAUCONFBIO = 0 .AND.;
					  TRBACE->COLARETIBENE = 'S' .AND.;
					  TRBACE->DATAVALIASO = STOD("19001231") .AND.;
					  TRBACE->DATATREISEGU = STOD("19001231") .AND.;
					  TRBACE->DATAPENDPLAN = STOD("19001231") .AND.;
					  TRBACE->CODIPLAN = 0 .AND.; //  TRBACE->CONTCREDREFE = iif(cfilant $ '01,10',3,0) .AND.;  // iif(cfilant ='01',3,0)
					  TRBACE->TEMPMINIALMO = 0 .AND.;
					  TRBACE->TEMPMINIPERM = 0 .AND.;
					  TRBACE->TOLECONTPERM = 0 .AND.;
					  TRBACE->CONTBIOM = _nusabio .AND.;
					  TRBACE->GRUPREPID = _ngrprep.AND.;
					  TRBACE->REGIPONTO = 'S' .AND. ;
					  TRBACE->IDCOLABSUBS = 0 )
					  
					  _cQry := " update SURICATO.tbacesscolab set veripermaces = 'S' ,codiperm = 1,permacesferi = 1,permacessaba = 1,permacesdomi = 1,permacesvisi = 1,faixhoraaces = 0, "
					  _cQry += " contantidupl = 'S',colarecevisi = 'S',veriafas = 'S',autosaidcola = 'N',autohoraextr='N',colautilveic='N',grauconfbiom=0,colaretibene='S', " 
					  _cQry += " datavaliaso = TO_DATE('19001231','YYYYMMDD'),datatreisegu = TO_DATE('19001231','YYYYMMDD'),datapendplan = TO_DATE('19001231','YYYYMMDD'), "
					  //_cQry += " codiplan = 0 ,contcredrefe = " + iif(cfilant $ '01,10',"3","0") + ", tempminialmo = 0,tempminiperm = 0,tolecontperm = 0,contbiom = "   
					  _cQry += " codiplan = 0 , tempminialmo = 0,tempminiperm = 0,tolecontperm = 0,contbiom = "   
					  _cQry +=  alltrim(str(_nusabio)) + " ,idcolabsubs = 0, regiponto = 'S', gruprepid = " + alltrim(str(_ngrprep))
					  _cQry += " where idcolab =  " + alltrim(str(TRBCOL->IDCOLAB))
                
					  _nres := TCSqlExec(_cQry)
					  FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01719"/*cMsgId*/, "MGPE01719 - 1/3 - Atualizando dados de colaboradores, atualizando tabela de acesso do colaborador - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

					  Reclock("ZGV",.T.)
					  ZGV->ZGV_FILIAL := TRBSRA->RA_FILIAL
					  ZGV->ZGV_MAT    := TRBSRA->RA_MAT
					  ZGV->ZGV_DATA   := DATE()
					  ZGV->ZGV_HORA   := TIME()
					  ZGV->ZGV_COMAND := _cQry
					  ZGV->ZGV_RESULT := _nres
					  ZGV->ZGV_COMENT := "1/3 - Atualizando dados de colaboradores, atualizando tabela de acesso do colaborador - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))
					  ZGV->(Msunlock())		
				Endif
			Else
		
				_cQry := " insert into SURICATO.tbacesscolab (idcolab,veripermaces,codiperm,permacesferi,permacessaba,permacesdomi,permacesvisi,faixhoraaces,contantidupl, "
		        _cQry += " colarecevisi,veriafas,autosaidcola,autohoraextr,colautilveic,grauconfbiom,colaretibene,datavaliaso,datatreisegu, "
		        _cQry += " datapendplan,codiplan,contcredrefe,tempminialmo,tempminiperm,tolecontperm,contbiom,idcolabsubs,gruprepid,regiponto) "
		        _cQry += " values (" + alltrim(str(TRBCOL->IDCOLAB)) + ",'S',1, 1,1,1,1,0,'S', "
		        _cQry += " 'S','S','N','N','N',0,'S',TO_DATE('19001231','YYYYMMDD'),TO_DATE('19001231','YYYYMMDD'), "
		        _cQry += " TO_DATE('19001231','YYYYMMDD'),0," + iif(cfilant == '01',"3","0") + ",0,0,0," + alltrim(str(_nusabio)) + ",0," + alltrim(str(_ngrprep)) + ",'S') "
               
		        _nres := TCSqlExec(_cQry)
				FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01720"/*cMsgId*/, "MGPE01720 - 1/3 - Atualizando dados de colaboradores, incluindo tabela de acesso do colaborador - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
								
  			    Reclock("ZGV",.T.)
        		ZGV->ZGV_FILIAL := TRBSRA->RA_FILIAL
        		ZGV->ZGV_MAT    := TRBSRA->RA_MAT
        		ZGV->ZGV_DATA   := DATE()
        		ZGV->ZGV_HORA   := TIME()
        		ZGV->ZGV_COMAND := _cQry
        		ZGV->ZGV_RESULT := _nres
        		ZGV->ZGV_COMENT := "1/3 - Atualizando dados de colaboradores, incluindo tabela de acesso do colaborador - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))
        		ZGV->(Msunlock())		
   		   Endif
		
      		//verifica se campo STATATUACONT est� atualizado
      		_cQry := "select STATATUACONT from SURICATO.tbhistocrach CRACH  "
      		_cQry += " WHERE (SELECT SITUAFAS FROM SURICATO.TBCOLAB COL WHERE CRACH.IDCOLAB = COL.IDCOLAB ) = 1 AND STATATUACONT <> 1 AND CRACH.IDCOLAB = " + ALLTRIM(STR(TRBCOL->IDCOLAB))

      		If select ("TRBCRC") > 0
      			TRBCRC->(Dbclosearea())
  		    Endif

      		dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBCRC" , .T., .F. )
      		dbSelectArea("TRBCRC")

    		//se existe verifica se tem tabela de acesso
      		If !TRBCRC->(Eof())
     			//Garante que campo STATATUACONT est� atualizado
				FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01721"/*cMsgId*/, "MGPE01721 - 1/3 - Atualizando dados de colaboradores, ajustando campo STATATUACONT  - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
     			_cQry := " UPDATE suricato.TBHISTOCRACH CRACH SET STATATUACONT = 1 WHERE (SELECT SITUAFAS FROM suricato.TBCOLAB COL WHERE CRACH.IDCOLAB = COL.IDCOLAB ) = 1 "
     			_cQry += " AND STATATUACONT <> 1 AND CRACH.IDCOLAB = " + ALLTRIM(STR(TRBCOL->IDCOLAB))
     			_nres := TCSqlExec(_cQry)
      		Endif

			//Verifica se existe registro na TBGRUPOREPCOLAB para o colaborador
			_cQry := "select gruprepid, idcolab "
 		    _cQry += " from SURICATO.TBGRUPOREPCOLAB WHERE idcolab =  " + alltrim(str(TRBCOL->IDCOLAB))

			If select ("TRBREP") > 0
				TRBREP->(Dbclosearea())
			Endif

			dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBREP" , .T., .F. )
			dbSelectArea("TRBREP")

			//se existe verifica se tem grupo est� correto
			If !TRBREP->(Eof())
				If TRBREP->GRUPREPID != _ngrprep
					//Faz update
	  				_cQry := " update SURICATO.TBGRUPOREPCOLAB set gruprepid = " + alltrim(str(_ngrprep))
					_cQry += " where idcolab =  " + alltrim(str(TRBCOL->IDCOLAB))
                
					_nres := TCSqlExec(_cQry)
					FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01722"/*cMsgId*/, "MGPE01722 - 1/3 - Atualizando dados de colaboradores, atualizando tabela de grupo de rep do colaborador - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

					Reclock("ZGV",.T.)
					ZGV->ZGV_FILIAL := TRBSRA->RA_FILIAL
					ZGV->ZGV_MAT    := TRBSRA->RA_MAT
					ZGV->ZGV_DATA   := DATE()
					ZGV->ZGV_HORA   := TIME()
					ZGV->ZGV_COMAND := _cQry
					ZGV->ZGV_RESULT := _nres
					ZGV->ZGV_COMENT := "1/3 - Atualizando dados de colaboradores, atualizando tabela de grupo de rep do colaborador - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))
					ZGV->(Msunlock())		
				Endif
			Else //Se n�o existe inclui registro com grupo de rep
				_cQry := " insert into SURICATO.TBGRUPOREPCOLAB (idcolab,gruprepid) "
        		_cQry += " values (" + alltrim(str(TRBCOL->IDCOLAB)) + "," + alltrim(str(_ngrprep)) + ") "
               
        		_nres := TCSqlExec(_cQry)
        		FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01723"/*cMsgId*/, "MGPE01723 - 1/3 - Atualizando dados de colaboradores, incluindo tabela de grupo de rep do colaborador - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
								
        		Reclock("ZGV",.T.)
        		ZGV->ZGV_FILIAL := TRBSRA->RA_FILIAL
        		ZGV->ZGV_MAT    := TRBSRA->RA_MAT
        		ZGV->ZGV_DATA   := DATE()
        		ZGV->ZGV_HORA   := TIME()
        		ZGV->ZGV_COMAND := _cQry
        		ZGV->ZGV_RESULT := _nres
        		ZGV->ZGV_COMENT := "1/3 - Atualizando dados de colaboradores, incluindo tabela de grupo de rep do colaborador - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))
        		ZGV->(Msunlock())		
			Endif
		Endif
		TRBSRA->(dbSkip())
	EndDo
EndIf

TRBSRA->(dbCloseArea())
	
Return Nil

/*
===============================================================================================================================
Programa----------: MGPE0172
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 24/05/2017
Descri��o---------: Fun��o respons�vel pela atualiza��o de dados de crach�s
Parametros--------: oproc - objeto da barra de processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGPE0172(oproc)
Local _cQry		:= ""
Local _cCracha	:= space(30)
Local _npos := 1
Local _ntot := 0
Default oproc := nil

IF valtype(oproc) = "O"
	oproc:cCaption := ("2/3 - Atualizando dados de crachas, lendo dados...")
	ProcessMessages()
ENDIF

FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01724"/*cMsgId*/, "MGPE01724 - 2/3 - Atualizando dados de crachas, lendo dados..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

_cQry := "SELECT RA_MAT MAT, RA_I_CRACH CRACHA, 'SRA' TIPO, RA_PIS PIS,RA_FILIAL FILIAL, RA_CIC CPF "
_cQry += "FROM " + RetSqlName("SRA") + " SRA "
_cQry += "WHERE RA_FILIAL = '" + xFilial("SRA") + "' "
_cQry += "  AND RA_CATFUNC IN ('M')"
_cQry += "  AND RA_SITFOLH <> 'D'"
_cQry += "  AND RA_PIS > ' ' "
_cQry += "  AND D_E_L_E_T_ = ' ' "
_cQry += " UNION ALL "
_cQry += "SELECT PE_MAT MAT, PE_I_CRACH CRACHA, 'SPE' TIPO, 'PIS' PIS,PE_FILIAL FILIAL, ' ' CPF "
_cQry += "FROM " + RetSqlName("SPE") + " SPE "
_cQry += "WHERE PE_FILIAL = '" + xFilial("SPE") + "' "
_cQry += "  AND (PE_I_CRACH <> ' ' AND PE_I_CRACH NOT IN (	SELECT RA_I_CRACH "
_cQry += "													FROM " + RetSqlName("SRA") + " SRA "
_cQry += "    	            	                            WHERE RA_FILIAL = '" + xFilial("SRA") + "' "
_cQry += "        	            	                          AND RA_I_CRACH <> ' ' "
_cQry += "            	            	                      AND SRA.D_E_L_E_T_ = ' ')) "

If select ("TRBSRA") > 0
	TRBSRA->(Dbclosearea())
Endif

dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBSRA" , .T., .F. )

dbSelectArea("TRBSRA")
Count to _ntot
TRBSRA->(dbGoTop())

If !TRBSRA->(Eof())
	While !TRBSRA->(Eof())
		IF valtype(oproc) = "O"
			oproc:cCaption := ("2/3 - Atualizando dados de crachas - " + strzero(_npos,9) + " de " + strzero(_ntot,9))
			ProcessMessages()
		ENDIF
		_npos++

		//Verifica se existe o crach� na tabela de crachas
		_cCracha := StrTran(alltrim(TRBSRA->CRACHA),",","")
		_cCracha := StrTran(_cCracha,".","")
		_cCracha := alltrim(str(val(_cCracha)))
		
		If _cCracha == "0"
			_cCracha := alltrim(TRBSRA->CPF)
		Endif

		If !Empty(_cCracha) .and. val(_cCracha) > 0
			_cQry := " select * from suricato.tbcadascrach WHERE ICARD = " + _cCracha
			If select ("TRBCRH") > 0
				TRBCRH->(Dbclosearea())
			Endif

			dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBCRH" , .T., .F. )
			dbSelectArea("TRBCRH")

			//Se n�o existir cria cadastro cria novo
			If TRBCRH->(Eof())
				_cQry := "insert into suricato.tbcadascrach (icard,usofaixcrac,numecrac) values ('" + _cCracha +  "',1,'" + _cCracha +  "')"
				_nres := TCSqlExec(_cQry)
			
				Reclock("ZGV",.T.)
				ZGV->ZGV_FILIAL := TRBSRA->FILIAL
				ZGV->ZGV_MAT    := TRBSRA->MAT
				ZGV->ZGV_DATA   := DATE()
				ZGV->ZGV_HORA   := TIME()
				ZGV->ZGV_COMAND := _cQry
				ZGV->ZGV_RESULT := _nres
				ZGV->ZGV_COMENT := "2/3 - Atualizando dados de crachas, incluindo cracha " + _cCracha
				ZGV->(Msunlock())	
			
				FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01725"/*cMsgId*/, "MGPE01725 - 2/3 - Atualizando dados de crachas, incluindo cracha " + _cCracha/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
			Endif
		Endif
		
		//Verifica se o funcionario est� ativo
		_lativo  := .F.
		
		If alltrim(TRBSRA->TIPO) == "SRA"
			_cQry := "select idcolab,situafas,dataafas,horaafas from SURICATO.tbcolab WHERE NUMEPIS = " + alltrim(TRBSRA->PIS)
			_cQry += " and codimatr = " + alltrim(STR(val(TRBSRA->MAT))) + " AND CODIEMPR = " + ALLTRIM(STR(VAL(TRBSRA->FILIAL)))

			If select ("TRBCOL") > 0
				TRBCOL->(Dbclosearea())
			Endif

			dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBCOL" , .T., .F. )
			dbSelectArea("TRBCOL")

			If !TRBCOL->(Eof())
				If TRBCOL->SITUAFAS = 1 
					_lativo := .T.
				Endif
			Endif
		Endif

		//Se for registro da SRA com cracha vinculado e ativo confere e ajusta Suricato se necess�rio
		If alltrim(TRBSRA->TIPO) == "SRA" .AND. !Empty(_cCracha) .and. _lativo .and. val(_cCracha) > 0
			//Verifica se existe registro antigo com mesmo cracha e idcolab diferente, se tiver fecha datafim e stathist
			_cQry :=  " SELECT COUNT(*) CONTA FROM SURICATO.TBHISTOCRACH WHERE ICARD = " + _cCracha 
            _cQry +=  "  AND TIPOCRAC = 1 "
            _cQry +=  "  AND DATAINIC <= TO_DATE('" + dtos(date()) + "', 'YYYYMMDD') "
            _cQry +=  "  AND (DATAFINA >= TO_DATE('" + dtos(date()) + "', 'YYYYMMDD') OR DATAFINA = TO_DATE('19001231', 'YYYYMMDD')) "
            _cQry +=  "  AND IDCOLAB <> (SELECT IDCOLAB FROM suricato.TBCOLAB where codiempr = " + alltrim(str(val(xFilial("SRA")))) 
			_cQry +=  "                                                                and TIPOCOLA = TIPOCRAC " 
  			_cQry +=  "                                                                and CODIMATR = " + alltrim(str(val(TRBSRA->MAT))) + ") "
 
 			If select ("TRBCR1") > 0
				TRBCR1->(Dbclosearea())
			Endif

			dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBCR1" , .T., .F. )
			dbSelectArea("TRBCR1")

			//Se existir muda stathist para 2 e datafina para dia anterior
			If TRBCR1->CONTA > 0
				_cQry := "UPDATE suricato.tbhistocrach SET DATAFINA = TO_DATE('" + dtos(date()-1) + "', 'YYYYMMDD'), STATHIST = 2"
				_cQry += " WHERE ICARD = " + _cCracha 
				_cQry +=  "  AND TIPOCRAC = 1 "
				_cQry +=  "  AND DATAINIC <= TO_DATE('" + dtos(date()) + "', 'YYYYMMDD') "
				_cQry +=  "  AND (DATAFINA >= TO_DATE('" + dtos(date()) + "', 'YYYYMMDD') OR DATAFINA = TO_DATE('19001231', 'YYYYMMDD')) "
				_cQry +=  "  AND IDCOLAB <> (SELECT IDCOLAB FROM suricato.TBCOLAB where codiempr = " + alltrim(str(val(xFilial("SRA")))) 
				_cQry +="                                                                and CODIMATR = " + alltrim(str(val(TRBSRA->MAT))) +  " ) " 
							
				_nres := TCSqlExec(_cQry)
				
				FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01726"/*cMsgId*/, "MGPE01726 - 2/3 - Atualizando dados de crachas - Desativando cracha para funcionario - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

				Reclock("ZGV",.T.)
				ZGV->ZGV_FILIAL := TRBSRA->FILIAL
				ZGV->ZGV_MAT    := TRBSRA->MAT
				ZGV->ZGV_DATA   := DATE()
				ZGV->ZGV_HORA   := TIME()
				ZGV->ZGV_COMAND := _cQry
				ZGV->ZGV_RESULT := _nres
				ZGV->ZGV_COMENT := "2/3 - Atualizando dados de crachas - Desativando cracha para funcionario - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))
				ZGV->(Msunlock())		
			Endif
			
			//Verifica se existe registro antigo com mesmo idcolab e cracha diferente, se tiver fecha datafim e stathist
			_cQry :=  " SELECT COUNT(*) CONTA FROM SURICATO.TBHISTOCRACH WHERE idcolab = (SELECT IDCOLAB FROM suricato.TBCOLAB where codiempr = " 
			_cQry +=                                  alltrim(str(val(xFilial("SRA")))) + " and CODIMATR = " + alltrim(str(val(TRBSRA->MAT))) 
			_cQry +=  "                               and TIPOCOLA = TIPOCRAC ) " 
            _cQry +=  "  AND TIPOCRAC = 1 "
            _cQry +=  "  AND DATAINIC <= TO_DATE('" + dtos(date()) + "', 'YYYYMMDD') "
            _cQry +=  "  AND (DATAFINA >= TO_DATE('" + dtos(date()) + "', 'YYYYMMDD') OR DATAFINA = TO_DATE('19001231', 'YYYYMMDD')) "
            _cQry +=  "  AND ICARD <> " + _cCracha 
	
			If select ("TRBCR2") > 0
				TRBCR2->(Dbclosearea())
			Endif

			dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBCR2" , .T., .F. )
			dbSelectArea("TRBCR2")

			//Se existir muda stathist para 2 e datafina para dia anterior
			If TRBCR2->CONTA > 0
				_cQry := "UPDATE suricato.tbhistocrach SET DATAFINA = TO_DATE('" + dtos(date()-1) + "', 'YYYYMMDD'), STATHIST = 2"
				_cQry += " WHERE idcolab = (SELECT IDCOLAB FROM suricato.TBCOLAB where codiempr = " 
				_cQry +=                                  alltrim(str(val(xFilial("SRA")))) + " and CODIMATR = " + alltrim(str(val(TRBSRA->MAT))) + " ) " 
				_cQry +=  "  AND TIPOCRAC = 1 "
				_cQry +=  "  AND DATAINIC <= TO_DATE('" + dtos(date()) + "', 'YYYYMMDD') "
				_cQry +=  "  AND (DATAFINA >= TO_DATE('" + dtos(date()) + "', 'YYYYMMDD') OR DATAFINA = TO_DATE('19001231', 'YYYYMMDD')) "
				_cQry +=  "  AND ICARD <> " + _cCracha 	
				_nres := TCSqlExec(_cQry)
				
				If _nres < 0 //Erro de update, provavelmente duplicando chave unica, ent�o apaga o registro
					_cQry := "delete from suricato.tbhistocrach "
					_cQry += " WHERE idcolab = (SELECT IDCOLAB FROM suricato.TBCOLAB where codiempr = " 
					_cQry +=                                  alltrim(str(val(xFilial("SRA")))) + " and CODIMATR = " + alltrim(str(val(TRBSRA->MAT))) + " ) "  
					_cQry +=  "  AND TIPOCRAC = 1 "
					_cQry +=  "  AND DATAINIC <= TO_DATE('" + dtos(date()) + "', 'YYYYMMDD') "
					_cQry +=  "  AND (DATAFINA >= TO_DATE('" + dtos(date()) + "', 'YYYYMMDD') OR DATAFINA = TO_DATE('19001231', 'YYYYMMDD')) "
					_cQry +=  "  AND ICARD <> " + _cCracha 	
					_nres := TCSqlExec(_cQry)
				Endif
				
				FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01727"/*cMsgId*/, "MGPE01727 - 2/3 - Atualizando dados de crachas - Desativando cracha para funcionario - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

				Reclock("ZGV",.T.)
				ZGV->ZGV_FILIAL := TRBSRA->FILIAL
				ZGV->ZGV_MAT    := TRBSRA->MAT
				ZGV->ZGV_DATA   := DATE()
				ZGV->ZGV_HORA   := TIME()
				ZGV->ZGV_COMAND := _cQry
				ZGV->ZGV_RESULT := _nres
				ZGV->ZGV_COMENT := "2/3 - Atualizando dados de crachas - Desativando cracha para funcionario - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))
				ZGV->(Msunlock())
			Endif

			//Verifica se existe registro com idcolab e cracha, se n�o existir inclui, se existir verifica diferen�as e atualiza se necess�rio
			_cQry :=  " SELECT idcolab, DATAFINA, icard FROM SURICATO.TBHISTOCRACH WHERE idcolab = (SELECT IDCOLAB FROM suricato.TBCOLAB where codiempr = " 
			_cQry +=                                  alltrim(str(val(xFilial("SRA")))) + " and CODIMATR = " + alltrim(str(val(TRBSRA->MAT))) 
			_cQry +=  "                               and TIPOCOLA = TIPOCRAC ) "  
            _cQry +=  "  AND TIPOCRAC = 1 "
            _cQry +=  "  AND DATAINIC <= TO_DATE('" + dtos(date()) + "', 'YYYYMMDD') "
            _cQry +=  "  AND (DATAFINA >= TO_DATE('" + dtos(date()) + "', 'YYYYMMDD') OR DATAFINA = TO_DATE('19001231', 'YYYYMMDD')) "
            _cQry +=  "  AND ICARD = " + _cCracha 

 			If select ("TRBCR3") > 0
				TRBCR3->(Dbclosearea())
			Endif

			dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBCR3" , .T., .F. )
			dbSelectArea("TRBCR3")

			//Se n�o existir insere
			If TRBCR3->(Eof())
				_cminutos := alltrim(str((val(substr(time(),1,2))*60) + (val(substr(time(),4,2)))))

				_cQry := "insert into suricato.tbhistocrach (tipocrac,datainic,horainic,idcolab,numeviacrac,icard,datafina,horafina,stathist,statatuacont,codiusua) "
				_cQry += " values ( 1, TO_DATE('" + dtos(date()) + "', 'YYYYMMDD')," + _cminutos  +  ", (SELECT IDCOLAB FROM suricato.TBCOLAB where codiempr = " 
			    _cQry +=   alltrim(str(val(xFilial("SRA")))) + " and CODIMATR = " + alltrim(TRBSRA->MAT) + " ) "  + ",0," + _cCracha
			    _cQry += ",TO_DATE('19001231', 'YYYYMMDD'),0,1,1,0 )"
		
				_nres := TCSqlExec(_cQry)
				FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01728"/*cMsgId*/, "MGPE01728 - 2/3 - Atualizando dados de crachas - Incluindo cracha para funcionario - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

				Reclock("ZGV",.T.)
				ZGV->ZGV_FILIAL := TRBSRA->FILIAL
				ZGV->ZGV_MAT    := TRBSRA->MAT
				ZGV->ZGV_DATA   := DATE()
				ZGV->ZGV_HORA   := TIME()
				ZGV->ZGV_COMAND := _cQry
				ZGV->ZGV_RESULT := _nres
				ZGV->ZGV_COMENT := "2/3 - Atualizando dados de crachas - Incluindo cracha para funcionario - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))
				ZGV->(Msunlock())
			
			//Se existir com data limitada ou cracha errado muda para data final sem limite e para o cracha certo
			Elseif TRBCR3->DATAFINA != stod("19001231") .OR. ALLTRIM(STR(TRBCR3->ICARD)) != ALLTRIM(str(val(_cCracha)))
			  	_cQry := "UPDATE suricato.tbhistocrach SET DATAFINA = TO_DATE('19001231', 'YYYYMMDD'), STATHIST = 1, ICARD = " + _cCracha 
			  	_cQry += " WHERE IDCOLAB =  " + ALLTRIM(STR(TRBCR3->IDCOLAB))		
			  	_cQry +=  "  AND TIPOCRAC = 1 "
			  	_cQry +=  "  AND DATAINIC <= TO_DATE('" + dtos(date()) + "', 'YYYYMMDD') "
			  	_cQry +=  "  AND (DATAFINA >= TO_DATE('" + dtos(date()) + "', 'YYYYMMDD') OR DATAFINA = TO_DATE('19001231', 'YYYYMMDD')) "
			  	_cQry +=  "  AND ICARD = " + ALLTRIM(str(val(_cCracha)))
				
				_nres := TCSqlExec(_cQry)
				
				FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01729"/*cMsgId*/, "MGPE01729 - 2/3 - Atualizando dados de crachas - Atualizando cracha para funcionario - "  + ALLTRIM(STR(TRBCR3->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

				Reclock("ZGV",.T.)
				ZGV->ZGV_FILIAL := TRBSRA->FILIAL
				ZGV->ZGV_MAT    := TRBSRA->MAT
				ZGV->ZGV_DATA   := DATE()
				ZGV->ZGV_HORA   := TIME()
				ZGV->ZGV_COMAND := _cQry
				ZGV->ZGV_RESULT := _nres
				ZGV->ZGV_COMENT := "2/3 - Atualizando dados de crachas - Atualizando cracha para funcionario - "  + ALLTRIM(STR(TRBCR3->IDCOLAB))
				ZGV->(Msunlock())
			Endif
		Endif
		TRBSRA->(dbSkip())
	End
EndIf

TRBSRA->(dbCloseArea())

Return Nil

/*
===============================================================================================================================
Programa----------: MGPE0175
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 26/05/2017
Descri��o---------: Fun��o respons�vel pela atualiza��o de afastamentos no Suricato
Parametros--------: oproc - objeto de processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGPE0175(oproc)

Local _cQry		:= ""
Local _ntot := 0
Local _npos := 1

Default oproc := nil

FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01730"/*cMsgId*/, "MGPE01730 - 3/3 - Atualizando dados de afastamentos, lendo dados de funcion�rios..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

_cQry := "SELECT R_E_C_N_O_ AS RECNO "
_cQry += "FROM " + RetSqlName("SRA") + " SRA "
_cQry += "WHERE RA_FILIAL = '" + xFilial("SRA") + "' "
_cQry += "  AND RA_CATFUNC IN ('M','E') "
_cQry += "  AND D_E_L_E_T_ = ' ' "

If select ("TRBSRA") > 0
	TRBSRA->(Dbclosearea())
Endif

dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBSRA" , .T., .F. )

dbSelectArea("TRBSRA")
Count to _ntot
TRBSRA->(dbGoTop())

If !TRBSRA->(Eof())
	While !TRBSRA->(Eof())
		IF valtype(oproc) = "O"
			oproc:cCaption := ("3/3 - Atualizando dados de afastamentos - " + strzero(_npos,9) + " de " + strzero(_ntot,9))
			ProcessMessages()
		ENDIF
		_npos++
		
		SRA->(Dbgoto(TRBSRA->RECNO))
		If !(val(alltrim(SRA->RA_PIS))) > 0 //Nao tem pis valido
			TRBSRA->(Dbskip())
			Loop
		Endif
		
		//Verifica se existe cadastro do funcion�rio no Suricato
		_cQry := "select idcolab,situafas,dataafas,horaafas from SURICATO.tbcolab WHERE NUMEPIS = " + alltrim(SRA->RA_PIS)
		_cQry += " and codimatr = " + alltrim(STR(val(SRA->RA_MAT))) + " AND CODIEMPR = " + ALLTRIM(STR(VAL(SRA->RA_FILIAL)))

		If select ("TRBCOL") > 0
			TRBCOL->(Dbclosearea())
		Endif

		dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBCOL" , .T., .F. )
		dbSelectArea("TRBCOL")

		If !TRBCOL->(Eof())
			If SRA->RA_SITFOLH == "D"  //Bloqueia demitidos se existirem no suricato
				//Ajusta afastamentos fechando todos em aberto e mantendo/gravando/ajustando o de demiss�o se necess�rio
				_cQry := "select idcolab,dataafas,horaafas,dataterm,horaterm,situafas,stathist from SURICATO.tbafast where idcolab = " + alltrim(STR(TRBCOL->IDCOLAB))
				If select ("TRBAFA") > 0
					TRBAFA->(Dbclosearea())
				Endif

				dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBAFA" , .T., .F. )
				dbSelectArea("TRBAFA")
		
				_lafadem := .F.
		
				Do while  !TRBAFA->(Eof())
			
					//Registro de afastamento de demissao 
					If TRBAFA->SITUAFAS = 2  .and. !_lafadem
						If TRBAFA->DATAAFAS = SRA->RA_DEMISSA .AND. TRBAFA->HORAAFAS = 1 .AND. TRBAFA->STATHIST = 1;
									.AND. TRBAFA->DATATERM = STOD("19001231")
							_lafadem := .T. //Registro de afastametnto por demissao ok
						Else
							//Atualiza registro para ficar ok
							_cQry := " UPDATE SURICATO.TBAFAST SET DATAAFAS = TO_DATE('" + DTOS(SRA->RA_DEMISSA ) + "','YYYYMMDD'), "
							_cQry += " HORAAFAS = 1, "
							_cQry += " SITUAFAS = 2, "
							_cQry += " STATHIST = 1, "
							_cQry += " DATATERM = TO_DATE('19001231','YYYYMMDD'), "
							_cQry += " HORATERM = 1 "
							_cQry += " WHERE idcolab =  " + ALLTRIM(STR(TRBAFA->IDCOLAB)) 
							_cQry += " AND DATAAFAS = TO_DATE('" + ALLTRIM(DTOS(TRBAFA->DATAAFAS)) + "','YYYYMMDD') "
							_cQry += " AND HORAAFAS =  " + ALLTRIM(STR(TRBAFA->HORAAFAS))
							_cQry += " AND SITUAFAS =  " + ALLTRIM(STR(TRBAFA->SITUAFAS))
							_cQry += " AND STATHIST =  " + ALLTRIM(STR(TRBAFA->STATHIST))
							
							_nres := TCSqlExec(_cQry)
							
							_lafadem := .T. //Registro de afastamento por demissao ok
							FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01731"/*cMsgId*/, "MGPE01731 - 3/3 - Atualizando dados de afastamentos - Atualizando bloqueio de demitido - "  + ALLTRIM(STR(TRBAFA->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
							
							Reclock("ZGV",.T.)
							ZGV->ZGV_FILIAL := SRA->RA_FILIAL
							ZGV->ZGV_MAT    := SRA->RA_MAT
							ZGV->ZGV_DATA   := DATE()
							ZGV->ZGV_HORA   := TIME()
							ZGV->ZGV_COMAND := _cQry
							ZGV->ZGV_RESULT := _nres
							ZGV->ZGV_COMENT := "3/3 - Atualizando dados de afastamentos - Atualizando bloqueio de demitido - "  + ALLTRIM(STR(TRBAFA->IDCOLAB))
							ZGV->(Msunlock())
						Endif
												
					Elseif (TRBAFA->SITUAFAS = 4 .or. TRBAFA->SITUAFAS = 3)
						//Ajusta registros ativos e com data final em branco ou posterior a data demissa
						If (TRBAFA->STATHIST = 1 .AND. (TRBAFA->DATATERM >= SRA->RA_DEMISSA .OR. TRBAFA->DATATERM = STOD('19001231')) ) 
							_cQry := " UPDATE SURICATO.TBAFAST SET  "
							_cQry += " STATHIST = 2, "             		
							_cQry += " DATATERM = TO_DATE('" + DTOS(SRA->RA_DEMISSA-1) + "','YYYYMMDD') "
							_cQry += " WHERE idcolab =  " + ALLTRIM(STR(TRBAFA->IDCOLAB)) 
							_cQry += " AND DATAAFAS = TO_DATE('" + ALLTRIM(DTOS(TRBAFA->DATAAFAS)) + "','YYYYMMDD') "
							_cQry += " AND HORAAFAS =  " + ALLTRIM(STR(TRBAFA->HORAAFAS))
							_cQry += " AND SITUAFAS =  " + ALLTRIM(STR(TRBAFA->SITUAFAS))
							_cQry += " AND STATHIST =  " + ALLTRIM(STR(TRBAFA->STATHIST))
							
							_nres := TCSqlExec(_cQry)
							FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01732"/*cMsgId*/, "MGPE01732 - 3/3 - Atualizando dados de afastamentos - Limpando afastamentos de demitido - "  + ALLTRIM(STR(TRBAFA->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
							
							Reclock("ZGV",.T.)
							ZGV->ZGV_FILIAL := SRA->RA_FILIAL
							ZGV->ZGV_MAT    := SRA->RA_MAT
							ZGV->ZGV_DATA   := DATE()
							ZGV->ZGV_HORA   := TIME()
							ZGV->ZGV_COMAND := _cQry
							ZGV->ZGV_RESULT := _nres
							ZGV->ZGV_COMENT := "3/3 - Atualizando dados de afastamentos - Limpando afastamentos de demitido - "  + ALLTRIM(STR(TRBAFA->IDCOLAB))
							ZGV->(Msunlock())
						Endif							
					Endif
					TRBAFA->(Dbskip())
				Enddo
			
				If !_lafadem  //Se n�o achou registro de afastamento de demiss�o inclui registro
				
					//Finaliza qualquer afastamento em aberto
					_cQry := " DELETE FROM  SURICATO.TBAFAST "						
					_cQry += " WHERE idcolab =  " + ALLTRIM(STR(TRBCOL->IDCOLAB)) 
							
					_nres := TCSqlExec(_cQry)
				
					_cQry := " Insert into SURICATO.TBAFAST "
					_cQry += " (IDCOLAB, DATAAFAS, HORAAFAS, DATATERM, HORATERM, " 
					_cQry += " SITUAFAS, STATHIST) "
					_cQry += " Values "
					_cQry += " (" + alltrim(STR(TRBCOL->IDCOLAB)) +  ", TO_DATE('" + DTOS(SRA->RA_DEMISSA) + "', 'YYYYMMDD'), 1, TO_DATE('31/12/1900', 'DD/MM/YYYY'), 1, " 
					_cQry += " 2, 1) "
					
					_nres := TCSqlExec(_cQry)
					FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01733"/*cMsgId*/, "MGPE01733 - 3/3 - Atualizando dados de afastamentos - Incluindo bloqueio de demitido - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
					
					Reclock("ZGV",.T.)
					ZGV->ZGV_FILIAL := SRA->RA_FILIAL
					ZGV->ZGV_MAT    := SRA->RA_MAT
					ZGV->ZGV_DATA   := DATE()
					ZGV->ZGV_HORA   := TIME()
					ZGV->ZGV_COMAND := _cQry
					ZGV->ZGV_RESULT := _nres
					ZGV->ZGV_COMENT := "3/3 - Atualizando dados de afastamentos - Incluindo bloqueio de demitido - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))
					ZGV->(Msunlock())
				Endif
			
				//Verifica e atualiza se necess�rio a situa��o do colaborador
				If !(TRBCOL->SITUAFAS = 2 .AND. TRBCOL->DATAAFAS = SRA->RA_DEMISSA .AND. TRBCOL->HORAAFAS = 1)
					//Ajusta campos de afastamento do colaborador
					_cQry := " UPDATE suricato.TBCOLAB SET SITUAFAS = 2, " 
					_cQry += " DATAAFAS = TO_DATE('" + DTOS(SRA->RA_DEMISSA) + "', 'YYYYMMDD'), "
					_cQry += " HORAAFAS = 1 "
					_cQry += " WHERE IDCOLAB = " + alltrim(STR(TRBCOL->IDCOLAB))
					
					_nres := TCSqlExec(_cQry)
					FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01734"/*cMsgId*/, "MGPE01734 - 3/3 - Atualizando dados de afastamentos - Atualizando status de demitido - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
					
					Reclock("ZGV",.T.)
					ZGV->ZGV_FILIAL := SRA->RA_FILIAL
					ZGV->ZGV_MAT    := SRA->RA_MAT
					ZGV->ZGV_DATA   := DATE()
					ZGV->ZGV_HORA   := TIME()
					ZGV->ZGV_COMAND := _cQry
					ZGV->ZGV_RESULT := _nres
					ZGV->ZGV_COMENT := "3/3 - Atualizando dados de afastamentos - Atualizando status de demitido - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))
					ZGV->(Msunlock())
				Endif
			Else
				//Verifica se afastamento ainda/j� est� ativo
				_cQry := " select r8_dataini,r8_datafim  "
				_cQry += " FROM " + RetSqlName("SR8") + " SR8 "
				_cQry += " where d_e_l_e_t_ = ' ' and (r8_datafim >= '" + dtos(date()) + "' or r8_datafim = ' ') and r8_dataini <= '" + dtos(date()) + "'"
				_cQry += " AND R8_FILIAL = '" + SRA->RA_FILIAL + "' AND R8_MAT = '" + SRA->RA_MAT + "'"

				If select ("TRBSR8") > 0
					TRBSR8->(Dbclosearea())
				Endif

				dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBSR8" , .T., .F. )
				dbSelectArea("TRBSR8")
					
				If TRBSR8->(Eof())  //Desbloqueia se necess�rio quando ativos
					//Ajusta afastamentos fechando todos em aberto e mantendo/gravando/ajustando o de afastamento atual se necess�rio
					_cQry := "select idcolab,dataafas,horaafas,dataterm,horaterm,situafas,stathist from SURICATO.tbafast where idcolab = " + alltrim(STR(TRBCOL->IDCOLAB))
					_cQry += " and stathist = 1"

					If select ("TRBAFAL") > 0
						TRBAFAL->(Dbclosearea())
					Endif

					dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBAFAL" , .T., .F. )
					dbSelectArea("TRBAFAL")
	
					If TRBAFAL->(!Eof())
						//Finaliza qualquer afastamento em aberto
						_cQry := " DELETE FROM  SURICATO.TBAFAST "						
						_cQry += " WHERE idcolab =  " + ALLTRIM(STR(TRBCOL->IDCOLAB)) 
								
						_nres := TCSqlExec(_cQry)
						
						FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01735"/*cMsgId*/, "MGPE01735 - 3/3 - Atualizando dados de afastamentos - Atualizando afastamentos de ativo - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
						
						Reclock("ZGV",.T.)
						ZGV->ZGV_FILIAL := SRA->RA_FILIAL
						ZGV->ZGV_MAT    := SRA->RA_MAT
						ZGV->ZGV_DATA   := DATE()
						ZGV->ZGV_HORA   := TIME()
						ZGV->ZGV_COMAND := _cQry
						ZGV->ZGV_RESULT := _nres
						ZGV->ZGV_COMENT := "3/3 - Atualizando dados de afastamentos - Atualizando afastamentos de ativo - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))
						ZGV->(Msunlock())					
					Endif
	
					//Verifica e atualiza se necess�rio a situa��o do colaborador
					If !(TRBCOL->SITUAFAS = 1) .OR. DTOS(TRBCOL->DATAAFAS) >= '19000101' .OR. TRBCOL->horaafas > 0

						//Ajusta campos de afastamento do colaborador
						_cQry := " UPDATE suricato.TBCOLAB SET SITUAFAS = 1, DATAAFAS = '', HORAAFAS = 0 " 
						_cQry += " WHERE IDCOLAB = " + alltrim(STR(TRBCOL->IDCOLAB))
						
						_nres := TCSqlExec(_cQry)
						FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01736"/*cMsgId*/, "MGPE01736 - 3/3 - Atualizando dados de afastamentos - Atualizando status de ativo - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
						
						Reclock("ZGV",.T.)
						ZGV->ZGV_FILIAL := SRA->RA_FILIAL
						ZGV->ZGV_MAT    := SRA->RA_MAT
						ZGV->ZGV_DATA   := DATE()
						ZGV->ZGV_HORA   := TIME()
						ZGV->ZGV_COMAND := _cQry
						ZGV->ZGV_RESULT := _nres
						ZGV->ZGV_COMENT := "3/3 - Atualizando dados de afastamentos - Atualizando status de ativo - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))
						ZGV->(Msunlock())
					Endif
				Else
					//Ajusta afastamentos fechando todos em aberto e mantendo/gravando/ajustando o de afastamento atual se necess�rio
					_cQry := "select idcolab,dataafas,horaafas,dataterm,horaterm,situafas,stathist from SURICATO.tbafast where idcolab = " + alltrim(STR(TRBCOL->IDCOLAB))

					If select ("TRBAFA") > 0
						TRBAFA->(Dbclosearea())
					Endif

					dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBAFA" , .T., .F. )
					dbSelectArea("TRBAFA")

					If SRA->RA_SITFOLH = 'A'
						_cSIT := "4"
						_CHORAS := "1"
						nDias:=1
					Else
						_cSIT := "3"
						_CHORAS := "420" 
						IF SRA->RA_FILIAL = "01" 
							nDias:=2
						ELSE
							nDias:=1
						ENDIF
					Endif
					_lafaafa := .F.
			
					Do while  !TRBAFA->(Eof())
						//Registro de afastamento atual
						If (TRBAFA->SITUAFAS = 4 .or. TRBAFA->SITUAFAS = 3)  .and. !_lafaafa
							If TRBAFA->DATAAFAS = stod(TRBSR8->R8_DATAINI) .AND.;
								TRBAFA->HORAAFAS = iif(SRA->RA_SITFOLH='A',1,420) .AND.;
								TRBAFA->STATHIST = 1 .AND.;
								(TRBAFA->DATATERM = STOD("19001231") .OR. TRBAFA->DATATERM = stod(TRBSR8->R8_DATAFIM)+nDias)
								_lafaafa := .T. //Registro de afastametnto atual ok
							Endif
						Endif
						TRBAFA->(Dbskip())
					Enddo
			
					If !_lafaafa  //Se n�o achou registro de afastamento atual inclui registro
						//Finaliza qualquer afastamento em aberto
						_cQry := " DELETE FROM  SURICATO.TBAFAST "						
						_cQry += " WHERE idcolab =  " + ALLTRIM(STR(TRBCOL->IDCOLAB)) 
							
						_nres := TCSqlExec(_cQry)
				
						FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01737"/*cMsgId*/, "MGPE01737 - 3/3 - Atualizando dados de afastamentos - Incluindo afastamento de afastado - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
						
						_cQry := " Insert into SURICATO.TBAFAST "
						_cQry += " (IDCOLAB, DATAAFAS, HORAAFAS, DATATERM, HORATERM, " 
						_cQry += " SITUAFAS, STATHIST) "
						_cQry += " Values "
						_cQry += " (" + alltrim(STR(TRBCOL->IDCOLAB)) +  ", TO_DATE('" + ALLTRIM(TRBSR8->R8_DATAINI) + "', 'YYYYMMDD'), " +  _CHORAS 
					
						If stod(TRBSR8->R8_DATAFIM) >= DATE()
							_cQry += " , TO_DATE('" + dtos(stod(TRBSR8->R8_DATAFIM)+nDias) + "', 'YYYYMMDD'),  1,  " + _CSIT + ", 1) "
						Else
							_cQry += " , TO_DATE('31/12/1900', 'DD/MM/YYYY'),  1,  " + _CSIT + ", 1) "
						Endif
						
						_nres := TCSqlExec(_cQry)
						
						FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01738"/*cMsgId*/, "MGPE01738 - 3/3 - Atualizando dados de afastamentos - Disparando gatilhos do afastamento de afastado - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
						
						//Zera data final de afastamento para ativar gatilhos de travamento da catraca
						_cQry := " UPDATE suricato.TBCOLAB SET SITUAFAS = " + _cSIT + ", " 
						_cQry += " DATAAFAS = TO_DATE('" + ALLTRIM(TRBSR8->R8_DATAINI) + "', 'YYYYMMDD'), "
						_cQry += " HORAAFAS = " + _choras + " "
						_cQry += " WHERE IDCOLAB = " + alltrim(STR(TRBCOL->IDCOLAB))
					
						_nres := TCSqlExec(_cQry)
					
						Reclock("ZGV",.T.)
						ZGV->ZGV_FILIAL := SRA->RA_FILIAL
						ZGV->ZGV_MAT    := SRA->RA_MAT
						ZGV->ZGV_DATA   := DATE()
						ZGV->ZGV_HORA   := TIME()
						ZGV->ZGV_COMAND := _cQry
						ZGV->ZGV_RESULT := _nres
						ZGV->ZGV_COMENT := "3/3 - Atualizando dados de afastamentos - Incluindo afastamento de afastado - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))
						ZGV->(Msunlock())
					Endif
					
					If SRA->RA_SITFOLH = 'A'
						_cSIT := "4"
						_CHORAS := "1"
					Else
						_cSIT := "3"
						_CHORAS := "420"
					Endif
					
					//Verifica e atualiza se necess�rio a situa��o do colaborador
					If !(TRBCOL->SITUAFAS = VAL(_cSIT) .AND. TRBCOL->DATAAFAS = STOD(TRBSR8->R8_DATAINI) .AND. TRBCOL->HORAAFAS = val(_choras))
						//Ajusta campos de afastamento do colaborador
						_cQry := " UPDATE suricato.TBCOLAB SET SITUAFAS = " + _cSIT + ", " 
						_cQry += " DATAAFAS = TO_DATE('" + ALLTRIM(TRBSR8->R8_DATAINI) + "', 'YYYYMMDD'), "
						_cQry += " HORAAFAS = " + _choras + " "
						_cQry += " WHERE IDCOLAB = " + alltrim(STR(TRBCOL->IDCOLAB))
					
						_nres := TCSqlExec(_cQry)
						
						FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01739"/*cMsgId*/, "MGPE01739 - 3/3 - Atualizando dados de afastamentos - Atualizando situa��o de afastado - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
						
						Reclock("ZGV",.T.)
						ZGV->ZGV_FILIAL := SRA->RA_FILIAL
						ZGV->ZGV_MAT    := SRA->RA_MAT
						ZGV->ZGV_DATA   := DATE()
						ZGV->ZGV_HORA   := TIME()
						ZGV->ZGV_COMAND := _cQry
						ZGV->ZGV_RESULT := _nres
						ZGV->ZGV_COMENT := "3/3 - Atualizando dados de afastamentos - Atualizando situa��o de afastado - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))
						ZGV->(Msunlock())					
					Endif
				Endif						
			Endif
		Endif
		TRBSRA->(dbSkip())
	EndDo
EndIf

Return Nil

/*
===============================================================================================================================
Programa----------: MGPE017S
Autor-------------: Darcio Ribeiro Sp�rl
Data da Criacao---: 27/06/2017
Descri��o---------: Fun��o respons�vel por limpar o registro enviado ao suricato, caso o n�mero do crach� seja alterado
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGPE017S()
Local _lRet 	:= .T.
Local _aArea	:= GetArea()

RecLock("SRA", .F.)
	Replace SRA->RA_I_SURIC With " "
SRA->(MsUnLock())

RestArea(_aArea)
Return(_lRet)

/*
===============================================================================================================================
Programa----------: SchedDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 25/05/2017
Descri��o---------: Defini��o de Static Function SchedDef para o novo Schedule
Uso---------------: No novo Schedule existe uma forma para a defini��o dos Perguntes para o bot�o Par�metros, al�m do cadastro 
					das fun��es no SXD. Ao definir em sua rotina a static function SchedDef(), no cadastro da rotina no Agenda-
					mento do Schedule ser� verificado se existe esta static function e ir� execut�-la habilitando o bot�o Par�-
					metros com as informa��es do retorno da SchedDef(), deixando de verificar assim as informa��es na SXD. O 
					retorno da SchedDef dever� ser um array.
					V�lido para Function e User Function, lembrando que uma vez definido a SchedDef, ao chamar a rotina o ambi-
					ente j� est� inicializado.
					Uma vez definido a Static Function SchedDef(), a rotina deixa de ser uma execu��o como processo especial, 
					ou seja, n�o se deve cadastr�-la no Agendamento passando par�metros de linha. Ex: Funcao("A","B") ou 
					U_Funcao("A","B").
Parametros--------: aReturn[1] - Tipo: "P" - para Processo, "R" -  para Relat�rios
					aReturn[2] - Nome do Pergunte, caso nao use passar ParamDef
					aReturn[3] - Alias  (para Relat�rio)
					aReturn[4] - Array de ordem  (para Relat�rio)
					aReturn[5] - T�tulo (para Relat�rio)
Retorno-----------: aParam
===============================================================================================================================
*/
Static Function SchedDef()

Local aParam  := {}
Local aOrd := {}

aParam := { "P",;
            "PARAMDEFF",;
            "",;
            aOrd,;
            }

Return aParam

/*
===============================================================================================================================
Programa----------: MGPE0175
Autor-------------: Alex Wallauer
Data da Criacao---: 14/12/2017
Descri��o---------: Fun��o que bloqueia os cadastros de clientes dos funionarios demitidos
Parametros--------: oproc - objeto de processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGPE0177(oproc)

LOCAL _cQry,_nPos:=0
LOCAL _nDias:=U_ITGETMV("IT_DEMIDIAS",0)
LOCAL _cCodSA1:=""

_cQry := "SELECT SA1.R_E_C_N_O_ REC_SA1 "
_cQry += "FROM " + RetSqlName("SRA") + " SRA , "+ RetSqlName("SA1") + " SA1 "
_cQry += "WHERE SRA.RA_FILIAL = '" + xFilial("SRA") + "' "
_cQry += "  AND SRA.RA_CATFUNC = 'M' "
_cQry += "	AND SRA.RA_SITFOLH = 'D' "
_cQry += "	AND SRA.RA_DEMISSA >= '" + DtoS(dDataBase-_nDias) + "' "
_cQry += "  AND SRA.D_E_L_E_T_ = ' ' "
_cQry += "  AND SA1.A1_CGC = RA_CIC "
_cQry += "  AND SA1.A1_MSBLQL = '2' "
_cQry += "  AND SA1.D_E_L_E_T_ = ' ' "
_cQry += "  AND NOT EXISTS (SELECT 'Y' FROM " + RetSqlName("SRA") + " SRA2
_cQry += "  	            WHERE SRA2.D_E_L_E_T_ = ' ' AND SRA2.RA_CIC = SRA.RA_CIC AND  SRA2.RA_SITFOLH <> 'D' ) "

If select ("TRBSRA") > 0
	TRBSRA->(Dbclosearea())
Endif

dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBSRA" , .T., .F. )

dbSelectArea("TRBSRA")
Count to _ntot
TRBSRA->(dbGoTop())

DO While !TRBSRA->(Eof())
	_nPos++
	IF valtype(oproc) = "O"
		oproc:cCaption := ("Verificando Demitido - " + strzero(_npos,9) + " de " + strzero(_ntot,9))
		ProcessMessages()
	ENDIF
	
	SA1->(DBGOTO(TRBSRA->REC_SA1))
	SA1->(RECLOCK("SA1",.F.))
	SA1->A1_MSBLQL:='1'
	SA1->(MSUNLOCK())
	_cCodSA1+=ALLTRIM(SA1->A1_COD)+", "
		
	TRBSRA->(dbSkip())
ENDDO

TRBSRA->(dbCloseArea())
dbSelectArea("SRA")

IF valtype(oproc) = "O"
   _cCodSA1:=LEFT(_cCodSA1,LEN(_cCodSA1)-2)
   U_ITMSG(ALLTRIM(str(_npos,9))+" registros atualizados: "+_cCodSA1,"CONCLUIDO",,2)
ELSE
   FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01740"/*cMsgId*/, "MGPE01740 - "+ALLTRIM(str(_npos,9))+" registros de Demitido X clientes atualizados: "+_cCodSA1/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
ENDIF
Return Nil

/*
===============================================================================================================================
Programa----------: MGPE017W
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 12/09/2016
Descri��o---------: WebService de execu��o do workflow
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
WSSTRUCT U_MGPE017G //Solicita��o de execu��o do workflow
 
 WSDATA EXECUTA as STRING 
 
ENDWSSTRUCT


WSSERVICE U_MGPE017 DESCRIPTION "Exporta��o Suricato" NAMESPACE "http://10.3.0.57:4043/ws/U_MGPE017.apw"

	WSDATA U_EXECUTA AS U_MGPE017G
	WSDATA U_STATUS AS STRING
	
	WSMETHOD U_EXECWF DESCRIPTION "Workflow Pedidos x Carteiras"
 
ENDWSSERVICE 

WSMETHOD U_EXECWF WSRECEIVE U_EXECUTA WSSEND U_STATUS WSSERVICE U_MGPE017  

	startjob("U_MGPE017",getenvserver(),.F.)
	FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01741"/*cMsgId*/, "MGPE01741 - Iniciada  exporta��o Suricato"/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	::U_STATUS := "Iniciada exporta��o Suricato"

Return .T.

/*
===============================================================================================================================
Programa----------: MGPE017Y
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 12/09/2016
Descri��o---------: Chamada de workflow via webservice 
Parametros--------: Nenhum
Retorno-----------: Nenhum
*/
User Function MGPE017Y()

FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01742"/*cMsgId*/, "MGPE01742 - Abrindo o ambiente..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

RPCSetType(3)
RpcSetEnv( "01" , '01' ,,,"COM", "SCHEDULE_SURICATO" , {'ZP1','SRA'} )
Sleep( 5000 ) //Aguarda 5 segundos para subam as configura��es do ambiente.

FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01743"/*cMsgId*/, "MGPE01743 - Solicitando Webservice de exporta��o Suricato"/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

oWsdl := tWSDLManager():New() // Cria o objeto da WSDL.
oWsdl:nTimeout := 60          // Timeout de 10 segundos                                                               

oWsdl:ParseURL(u_itgetmv("ITWEBLNK","http://10.55.0.128:1026/ws/") + "U_MGPE017.apw?WSDL") // Manda para dentro do Objeto qual � o link do WSDL de integra��o Webservice. 
oWsdl:SetOperation("U_EXECWF") // Define qual opera��o ser� realizada.
				
//Monta XML
_cXML := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://10.3.0.55:4043/ws/U_MGPE017.apw">'
_cXML += '<soapenv:Header/><soapenv:Body><u:U_EXECWF><u:U_EXECUTA><u:EXECUTA>teste</u:EXECUTA></u:U_EXECUTA></u:U_EXECWF></soapenv:Body></soapenv:Envelope>'
	
// Envia para o servidor
_cOk := oWsdl:SendSoapMsg(_cXML) // Este comando pega o XML e envia para o servidor da RDC.  
            
Return _cOk

/*
===============================================================================================================================
Programa----------: MGPE17SA2
Autor-------------: Alex Wallauer
Data da Criacao---: 03/08/2018
Descri��o---------: Fonte criado para atualizar dados Suricato somente com o SA2.
Parametros--------: _lweb - indica se est� sendo chamado a partir do webservice
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGPE17SA2(_lweb)//chamado do shedule ou do wse service
Default _lweb := .F. 
RETURN U_MGPE017(_lweb,.T.)

/*
===============================================================================================================================
Programa----------: MGPE0171
Autor-------------: Alex Wallauer
Data da Criacao---: 03/08/2018
Descri��o---------: Fun��o respons�vel pela exporta��o dos dados de colaboradores com os dados dos motoristas ZL0
Parametros--------: oproc - objeto da barra de processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGPE017M(oproc,_cMotoristas)

Local _cQry		:= ""
Local _ntot := 0
Local _npos := 1
Local _cAlias:= GetNextAlias()
Local _cFils := U_ITGETMV("IT_FILSUR","01;10")

DEFAULT oproc := NIL
DEFAULT _cMotoristas:=""

_cFils := FormatIn(ALLTRIM(_cFils),";")

FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01744"/*cMsgId*/, "MGPE01744 - 1/1 -Atualizando dados de motoristas, lendo dados de motoristas..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

_cQry := "SELECT DISTINCT ZL0_CGC, MAX(R_E_C_N_O_) REC FROM " + RetSqlName("ZL0") + " ZL0 WHERE "
_cQry += " ZL0_ATIVO <> 'N' AND "
_cQry += " LENGTH(TRIM(ZL0_CGC)) = 11 AND  "
_cQry += " D_E_L_E_T_ = ' '  "
_cQry += " AND ZL0_FILIAL IN "+_cFils
IF !EMPTY(_cMotoristas)
   _cQry += " AND ZL0_FILIAL||ZL0_COD IN "+_cMotoristas
ELSEIF SuperGetMV("IT_AMBTEST",.F.,.T.)
   _cQry += " AND  ROWNUM <= 6 "//PARA TESTE TIRAR
ENDIF
_cQry += " GROUP BY ZL0_CGC "

DBUSEAREA( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , _cAlias , .T., .F. )

COUNT TO _ntot
(_cAlias)->(dbGoTop())

If !(_cAlias)->(Eof())
	DO While !(_cAlias)->(Eof())     
		ZL0->(DBGOTO( (_cAlias)->REC ))
		_cMatSuricato:="9"+ZL0->ZL0_COD+ZL0->ZL0_FILIAL
		IF valtype(oproc) = "O"
			oproc:cCaption := ("Atualizando dados de motoristas - " + STRZERO(_npos,9) + " de " + STRZERO(_ntot,9))
			ProcessMessages()
	   ENDIF
	   _npos++
		
		If !VAL(ALLTRIM(ZL0->ZL0_CGC)) > 0
			(_cAlias)->(DBSKIP())
			LOOP
		Endif

		//Verifica se existe cadastro TBPESSOA no Suricato ****************************************************************
	    _cQryS := "SELECT IDPESSOA , NOMEPESS FROM SURICATO.TBPESSOA WHERE NOMEPESS = '"+ALLTRIM(ZL0->ZL0_NOME)+"'
	    If SELECT("TRBPES") > 0 ; TRBPES->(Dbclosearea()) ; Endif
	    DBUSEAREA( .T. , "TOPCONN" , TcGenQry(,, _cQryS ) , "TRBPES" , .T., .F. )

	    If TRBPES->(Eof()) .AND. EMPTY(TRBPES->IDPESSOA)
			//Inclui cadastro de TBPESSOA
		   _cQry := "INSERT INTO SURICATO.TBPESSOA (NOMEPESS) VALUES ('" + ALLTRIM(ZL0->ZL0_NOME) +  "')"
		   _nres := TCSqlExec(_cQry)

		   ZGV->(Reclock("ZGV",.T.))
		   ZGV->ZGV_FILIAL := ZL0->ZL0_FILIAL
		   ZGV->ZGV_MAT    := _cMatSuricato
		   ZGV->ZGV_DATA   := DATE()
		   ZGV->ZGV_HORA   := TIME()
		   ZGV->ZGV_COMAND := _cQry
		   ZGV->ZGV_RESULT := _nres
		   ZGV->ZGV_COMENT := "Atualizando dados de motoristas, incluindo motorista " +ZGV->ZGV_FILIAL+ "/" + ZGV->ZGV_MAT
		   ZGV->(Msunlock())					
		   
			IF SELECT ("TRBPES") > 0 ; TRBPES->(DBCLOSEAREA()) ; ENDIF
			dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQryS ) , "TRBPES" , .T., .F. )//Executa de novo pq pode ter incluido
		ENDIF
        _cIDPESSOA:=ALLTRIM(STR(TRBPES->IDPESSOA))
		IF EMPTY(_cIDPESSOA) 
			FWLogMsg("WARN"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01745"/*cMsgId*/, "MGPE01745 - Atualizando dados de motoristas, FALHA ao incluir pessoa para MOTORISTA " + ZL0->ZL0_FILIAL + "/" + _cMatSuricato + "..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
			(_cAlias)->(DBSKIP())
			LOOP
		ENDIF
		_nres:=0
		//Verifica se existe cadastro TBPESSOA no Suricato ****************************************************************
		
		//Verifica se existe cadastro do TBCOLAB no Suricato ***************************************************************
		_cQryC := "SELECT IDCOLAB,CODIMATR FROM SURICATO.TBCOLAB WHERE  "
		_cQryC += " CODIMATR = " + ALLTRIM(STR(VAL( _cMatSuricato ))) + " AND CODIEMPR = "+ALLTRIM(STR(VAL(ZL0->ZL0_FILIAL)))
		IF SELECT("TRBCOL") > 0 ; TRBCOL->(DBCLOSEAREA()) ; ENDIF
		DBUSEAREA( .T. , "TOPCONN" , TcGenQry(,, _cQryC ) , "TRBCOL" , .T., .F. )

		//Se n�o existir inclui cadastro
		If TRBCOL->(Eof()) .AND. EMPTY(TRBCOL->CODIMATR) 
			FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01746"/*cMsgId*/, "MGPE01746 - Atualizando dados de motoristas, incluindo pessoa para matricula " + ZL0->ZL0_FILIAL + "/" + _cMatSuricato + "..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
  			If _nres == 0 //Se incluiu cadastro de pessoa com sucesso
				FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01747"/*cMsgId*/, "MGPE01747 - Atualizando dados de motoristas, incluindo funcion�rio para MOTORISTA " + ZL0->ZL0_FILIAL + "/" + _cMatSuricato + "..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	    		_cIDPESSOA:=ALLTRIM(STR(TRBPES->IDPESSOA))
						
				_cQry :=  " INSERT INTO SURICATO.TBCOLAB (IDPESSOA,CODIEMPR,TIPOCOLA,CODIMATR,APELCOLA,NUMECPF,DATAADMI)"
				_cQry +=  " VALUES (" + _cIDPESSOA                      //IDPESSOA
				_cQry +=  " ,"+ALLTRIM(STR(VAL(ZL0->ZL0_FILIAL)))       //CODIEMPR
				_cQry +=  " ,3 " //Parceiro                             //TIPOCOLA
				_cQry +=  " ," + _cMatSuricato                          //CODIMATR
				_cQry +=  " ,'"+ALLTRIM(SUBSTR(ZL0->ZL0_NOME,1,10))+"'" //APELCOLA
				_cQry +=  " ," + ALLTRIM(ZL0->ZL0_CGC)                  //NUMECPF
				_cQry +=  " ,TO_DATE('"+DTOS(dDataBase)+"','YYYYMMDD') "//DATAADM
  				_cQry +=  " )"
				
				_nres := TCSqlExec(_cQry)
					
				ZGV->(Reclock("ZGV",.T.))
				ZGV->ZGV_FILIAL := ZL0->ZL0_FILIAL
				ZGV->ZGV_MAT    := _cMatSuricato
				ZGV->ZGV_DATA   := DATE()
				ZGV->ZGV_HORA   := TIME()
				ZGV->ZGV_COMAND := _cQry
				ZGV->ZGV_RESULT := _nres
				ZGV->ZGV_COMENT := "Atualizando dados de motoristas, incluindo motorista " +ZGV->ZGV_FILIAL+ "/" + ZGV->ZGV_MAT
				ZGV->(Msunlock())										
					
				If _nres == 0
					FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01701"/*cMsgId*/, "MGPE01748 - Atualizando dados de motoristas, incluido com sucesso motorista para matricula " + ZL0->ZL0_FILIAL + "/" + _cMatSuricato + "..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
				Else
					FWLogMsg("WARN"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01749"/*cMsgId*/, "MGPE01749 - Atualizando dados de motoristas, FALHA ao incluir motorista para matricula " + ZL0->ZL0_FILIAL + "/" + _cMatSuricato + "..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
				Endif
				
  			Else
				FWLogMsg("WARN"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01750"/*cMsgId*/, "MGPE01750 - Atualizando dados de motoristas, FALHA ao incluir pessoa para matricula " + ZL0->ZL0_FILIAL + "/" + _cMatSuricato + "..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
  			Endif
  		
		//SE J� EXISTE CADASTRO VERIFICA SE PRECISA ATUALIZAR A TABELA  TBCOLAB
  		ELSEIF TRBCOL->CODIMATR = VAL( _cMatSuricato )
  	
			_cQry := " UPDATE SURICATO.TBCOLAB SET "
			_cQry += " APELCOLA = '"+ALLTRIM(SUBSTR(ZL0->ZL0_NOME,1,10))+"'" //APELCOLA
			_cQry += ",NUMECPF  = " +ALLTRIM(ZL0->ZL0_CGC)                   //NUMECPF
			_cQry += ",DATAADMI = TO_DATE('"+DTOS(dDataBase)+"','YYYYMMDD') "//DATAADM
			_cQry += ",IDPESSOA = " + _cIDPESSOA					 	     //IDPESSOA
			_cQry += " WHERE  CODIMATR = " + ALLTRIM(STR(VAL( _cMatSuricato ))) + " AND CODIEMPR = "+ALLTRIM(STR(VAL(ZL0->ZL0_FILIAL)))
   		
			_nres := TCSqlExec(_cQry)
			FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01751"/*cMsgId*/, "MGPE01751 - Atualizando dados de motoristas, atualizando dados do motorista - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
								
			ZGV->(Reclock("ZGV",.T.))
			ZGV->ZGV_FILIAL := ZL0->ZL0_FILIAL
			ZGV->ZGV_MAT    := _cMatSuricato
			ZGV->ZGV_DATA   := DATE()
			ZGV->ZGV_HORA   := TIME()
			ZGV->ZGV_COMAND := _cQry
			ZGV->ZGV_RESULT := _nres
			ZGV->ZGV_COMENT := "Atualizando dados de motoristas, atualizando dados do motorista - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))
			ZGV->(Msunlock())
  		Endif
		
		//Verifica se existe cadastro do TBCOLAB no Suricato ***************************************************************
	
		//verifica na tabela de colaboradores e se tiver verifica e atualiza tabela de acessos
		_cQry := "SELECT IDCOLAB,CODIMATR FROM SURICATO.TBCOLAB WHERE  "
		_cQry += " CODIMATR = " + alltrim(STR(val(_cMatSuricato))) + " AND CODIEMPR = "+ALLTRIM(STR(VAL(ZL0->ZL0_FILIAL)))
		IF SELECT ("TRBCOL") > 0 ; TRBCOL->(DBCLOSEAREA()) ; ENDIF
		DBUSEAREA( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBCOL" , .T., .F. )

		//se existe verifica se tem TABELA DE ACESSO *********************************************************
		If !TRBCOL->(Eof()) .AND. !EMPTY(TRBCOL->IDCOLAB)
		
			_cQry := "SELECT IDCOLAB,VERIPERMACES,CODIPERM,PERMACESFERI,PERMACESSABA,PERMACESDOMI,PERMACESVISI,FAIXHORAACES,CONTANTIDUPL, "
        	_cQry += " COLARECEVISI,VERIAFAS,AUTOSAIDCOLA,AUTOHORAEXTR,COLAUTILVEIC,GRAUCONFBIOM,COLARETIBENE,DATAVALIASO,DATATREISEGU, "
        	_cQry += " DATAPENDPLAN,CODIPLAN,CONTCREDREFE,TEMPMINIALMO,TEMPMINIPERM,TOLECONTPERM,CONTBIOM,IDCOLABSUBS "
        	_cQry += " FROM SURICATO.TBACESSCOLAB WHERE IDCOLAB =  " + ALLTRIM(STR(TRBCOL->IDCOLAB))
 					
			IF SELECT ("TRBACE") > 0 ; TRBACE->(DBCLOSEAREA()) ; ENDIF
			dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBACE" , .T., .F. )

			//se existe verifica se tem tabela de acesso
			If !TRBACE->(Eof()) .AND. !EMPTY(TRBACE->IDCOLAB)
		
				//Verifica se precisa atualizar campos
				If !( TRBACE->VERIPERMACES = 'S' .AND.;
			 			TRBACE->CODIPERM     = 1   .AND.;
			  			TRBACE->PERMACESFERI = 1   .AND.;
			  			TRBACE->PERMACESSABA = 1   .AND.;
			  			TRBACE->PERMACESDOMI = 1   .AND.;
			  			TRBACE->PERMACESVISI = 1   .AND.;
			  			TRBACE->FAIXHORAACES = 0   .AND.;
			  			TRBACE->CONTANTIDUPL = 'S' .AND.;
			  			TRBACE->COLARECEVISI = 'S' .AND.;
			  			TRBACE->VERIAFAS     = 'S' .AND.;
  			  			TRBACE->AUTOSAIDCOLA = 'N' .AND.;
			  			TRBACE->AUTOHORAEXTR = 'N' .AND.;
			  			TRBACE->COLAUTILVEIC = 'N' .AND.;
			  			TRBACE->GRAUCONFBIO  = 0   .AND.;
			  			TRBACE->COLARETIBENE = 'S' .AND.;
			  			TRBACE->DATAVALIASO  = STOD("19001231") .AND.;
			  			TRBACE->DATATREISEGU = STOD("19001231") .AND.;
			  			TRBACE->DATAPENDPLAN = STOD("19001231") .AND.;
			  			TRBACE->CODIPLAN     = 0 .AND.; // TRBACE->CONTCREDREFE = 0 .AND.;//Cedito para refetorio
			  			TRBACE->TEMPMINIALMO = 0 .AND.;
			  			TRBACE->TEMPMINIPERM = 0 .AND.;
			  			TRBACE->TOLECONTPERM = 0 .AND.;
			  			TRBACE->CONTBIOM     = 1 .AND.; 
			  			TRBACE->IDCOLABSUBS  = 0 )
					  
					_cQry := " UPDATE SURICATO.TBACESSCOLAB set veripermaces = 'S' ,codiperm = 1,permacesferi = 1,permacessaba = 1,permacesdomi = 1,permacesvisi = 1,faixhoraaces = 0, "
					_cQry += " contantidupl = 'S',colarecevisi = 'S',veriafas = 'S',autosaidcola = 'N',autohoraextr='N',colautilveic='N',grauconfbiom=0,colaretibene='S', " 
					_cQry += " datavaliaso = TO_DATE('19001231','YYYYMMDD'),datatreisegu = TO_DATE('19001231','YYYYMMDD'),datapendplan = TO_DATE('19001231','YYYYMMDD'), "
					//_cQry += " codiplan = 0 ,contcredrefe = 0, tempminialmo = 0,tempminiperm = 0,tolecontperm = 0,contbiom = 1,idcolabsubs = 0 "
					_cQry += " codiplan = 0 , tempminialmo = 0,tempminiperm = 0,tolecontperm = 0,contbiom = 1,idcolabsubs = 0 "
					_cQry += " where idcolab =  " + alltrim(str(TRBCOL->IDCOLAB))
               
					_nres := TCSqlExec(_cQry)
					FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01752"/*cMsgId*/, "MGPE01752 - Atualizando dados de motoristas, atualizando tabela de acesso do motorista - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
								
					Reclock("ZGV",.T.)
			  		ZGV->ZGV_FILIAL := ZL0->ZL0_FILIAL
		  			ZGV->ZGV_MAT    := _cMatSuricato
		  			ZGV->ZGV_DATA   := DATE()
		  			ZGV->ZGV_HORA   := TIME()
		  			ZGV->ZGV_COMAND := _cQry
		  			ZGV->ZGV_RESULT := _nres
		  			ZGV->ZGV_COMENT := "Atualizando dados de motorista, atualizando tabela de acesso do motorista - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))
		  			ZGV->(Msunlock())		
				Endif
			Else
				_cQry := " INSERT INTO SURICATO.TBACESSCOLAB (idcolab,veripermaces,codiperm,permacesferi,permacessaba,permacesdomi,permacesvisi,faixhoraaces,contantidupl, "
        		_cQry += " colarecevisi,veriafas,autosaidcola,autohoraextr,colautilveic,grauconfbiom,colaretibene,datavaliaso,datatreisegu, "
        		_cQry += " datapendplan,codiplan,contcredrefe,tempminialmo,tempminiperm,tolecontperm,contbiom,idcolabsubs) "
        		_cQry += " values (" + alltrim(str(TRBCOL->IDCOLAB)) + ",'S',1, 1,1,1,1,0,'S', "
        		_cQry += " 'S','S','N','N','N',0,'S',TO_DATE('19001231','YYYYMMDD'),TO_DATE('19001231','YYYYMMDD'), "
        		_cQry += " TO_DATE('19001231','YYYYMMDD'),0,0,0,0,0,1,0) "
                
        		_nres := TCSqlExec(_cQry)
        		FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MGPE017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MGPE01753"/*cMsgId*/, "MGPE01753 - Atualizando dados de motorista, incluindo tabela de acesso do motorista - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
								
        		Reclock("ZGV",.T.)
           		ZGV->ZGV_FILIAL := ZL0->ZL0_FILIAL
           		ZGV->ZGV_MAT    := _cMatSuricato
           		ZGV->ZGV_DATA   := DATE()
           		ZGV->ZGV_HORA   := TIME()
           		ZGV->ZGV_COMAND := _cQry
           		ZGV->ZGV_RESULT := _nres
           		ZGV->ZGV_COMENT := "Atualizando dados de motorista, incluindo tabela de acesso do motorista - "  + ALLTRIM(STR(TRBCOL->IDCOLAB))
           		ZGV->(Msunlock())		
   			Endif
		Endif  
		(_cAlias)->(dbSkip())
	ENDDO
EndIf

(_cAlias)->(dbCloseArea())
	
Return Nil

/*
===============================================================================================================================
Programa----------: MGPE0171
Autor-------------: Alex Wallauer
Data da Criacao---: 07/08/2018
Descri��o---------: F3 dos dados dos motoristas ZL0
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function MGPE17F3()

Local _lRet			:= .F.
Local _aDados		:= {}
Local _cMVRET		:= ""//Alltrim( ReadVar() )
Local _cTitAux		:= ''
Local _cParDef		:= ''
Local _nTamChv		:= 0
Local _nMaxSel		:= 0
LOCAL _cAlias       := GetNextAlias()
LOCAL _cRetorno     := ""
LOCAL _cQuery       := ""
Local _cFils        := U_ITGETMV("IT_FILSUR","01;10")
_cFils := FormatIn(ALLTRIM(_cFils),";")

_cQuery += " SELECT TRIM(ZL0_NOME) , R_E_C_N_O_ REC FROM "+RetSqlName('ZL0')+" ZL01 , ( "
_cQuery += " SELECT DISTINCT ZL0_CGC, MAX(R_E_C_N_O_) REC "
_cQuery += " FROM "+RetSqlName('ZL0')+" ZL0 "
_cQuery += " WHERE D_E_L_E_T_ = ' ' AND ZL0_ATIVO <> 'N' AND LENGTH(TRIM(ZL0_CGC)) = 11 "
_cQuery += " AND ZL0_FILIAL IN "+_cFils
_cQuery += " GROUP BY ZL0_CGC "
_cQuery += " ) ZL0AUX WHERE ZL01.R_E_C_N_O_ = ZL0AUX.REC ORDER BY TRIM(ZL0_NOME) "

If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TCGenQry(,,_cQuery) , _cAlias , .F. , .T. )
COUNT TO _nMaxSel
_nTamChv := LEN(ZL0->ZL0_FILIAL+ZL0->ZL0_COD)
_cMVRET  := SPACE(_nTamChv)
_cTitAux := "Motoristas"

DBSelectArea(_cAlias)
(_cAlias)->( DBGoTop() )
DO While (_cAlias)->( !Eof() )
    ZL0->(DBGOTO((_cAlias)->REC))
	_cParDef += AllTrim( ZL0->ZL0_FILIAL+ZL0->ZL0_COD )
	aAdd( _aDados , AllTrim( ZL0->ZL0_NOME )+" CPF: "+ALLTRIM(ZL0->ZL0_CGC) )
	(_cAlias)->( DBSkip() )
EndDo
(_cAlias)->( DBCloseArea() )  

If !Empty( _aDados )
	_lRet    := .T.
	_cRetorno:= MGPE017C( _nTamChv , _nMaxSel , _cMVRET , _cTitAux , _cParDef , _aDados )
EndIf

IF !EMPTY(_cRetorno)
   _cRetorno := FormatIn(ALLTRIM(_cRetorno),";")
ENDIF

Return _cRetorno

/*
===============================================================================================================================
Programa--------: MGPE017C
Autor-----------: Alexandre Villar
Data da Criacao-: 22/03/2015
Descri��o-------: Fun��o que monta a tela para sele��o de �tens via F3 de acordo com par�metros recebidos
Parametros------: _nTamChv - Tamanho da Chave dos registros
----------------: _nMaxSel - N�mero m�ximo de registros que podem ser selecionados ao mesmo tempo
----------------: _cMVRET  - Nome da vari�vel ou campo onde ser� gravado o retorno
----------------: _cTitAux - T�tulo que ser� exibido na janela de sele��o dos itens
----------------: _cParDef - String contendo os c�digos dos itens que ser�o listados
----------------: _aDados  - Array contendo a descri��o dos itens que ser�o listados
Retorno---------: _cRetAux - Lista de registros selecionados
===============================================================================================================================
*/
Static Function MGPE017C( _nTamChv , _nMaxSel , _cMVRET , _cTitAux , _cParDef , _aDados )
Local _cRetAux	:= _cMVRET
Local i

Private nTam       := _nTamChv //Tratamento para carregar variaveis da lista de opcoes
Private nMaxSelect := _nMaxSel //Define a quantidade m�xima de itens que podem ser selecionados ao mesmo tempo
Private aCat       := aClone( _aDados )
Private MvPar      := ""
Private cTitulo    := _cTitAux
Private MvParDef   := _cParDef       

//====================================================================================================
// Tratativa para carregar selecionados registros j� marcados anteriormente
//====================================================================================================
If Len( AllTrim( _cRetAux ) ) == 0
	MvPar		:= PadR( AllTrim( StrTran( _cRetAux , ";" , "" ) ) , Len(aCat) )
	_cRetAux	:= PadR( AllTrim( StrTran( _cRetAux , ";" , "" ) ) , Len(aCat) )
Else
	MvPar  := AllTrim( StrTran( _cRetAux , ";" , "/" ) )
EndIf

//====================================================================================================
// Fun��o que chama a tela de op��es e s� registra se usu�rio confirmar com "Ok"
//====================================================================================================
If F_Opcoes( @MvPar , cTitulo , aCat , MvParDef , 12 , 49 , .F. , nTam , nMaxSelect )
	_cRetAux := ""
	For i := 1 To Len(MvPar) Step nTam
		If !( SubStr( MvPar , i , 1 ) $ " |*" )
			_cRetAux += SubStr( MvPar , i , nTam ) +";" //Separa os registros selecionados com ';'
		EndIf
	Next i
	_cRetAux := SubStr( _cRetAux , 1 , Len( _cRetAux ) - 1 ) //Trata para tirar o ultimo caracter
EndIf     

Return( _cRetAux )
