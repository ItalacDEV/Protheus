/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer |19/11/2021| Chamado 38244. Incluido 2 paramentros novos de Inicio Ferias de até.
Alex Wallauer |03/02/2022| Chamado 38743. Ajuste no filtro dos 2 paramentros novos de Inicio Ferias de até.
Lucas Borges  |09/10/2024| Chamado 48465. Retirada manipulação do SX1
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"
#Define ENTER Chr(13)+Chr(10)

/*
===============================================================================================================================
Programa----------: RGPE016
Autor-------------: Josué Danich Prestes
Data da Criacao---: 25/06/2018
Descrição---------: Relatório de programação de ferias via email - Chamado 25178
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGPE016()

Local _alog := {}  , _nzi

If !(isincallstack("MDIEXECUTE") .or. isincallstack("SIGAADV"))

	//===========================================================================
	//| Prepara o ambiente pra processamento do JOB                             |
	//===========================================================================
	
	RpcClearEnv()
	RpcSetType(2)
		
	If !RPCSETENV( '01' , '01' )
		Return()
	EndIf
	
	Pergunte('RGPE016',.F.)

Else

	//Faz pergunte
	IF !Pergunte('RGPE016',.T.)
   
  		U_ITMSG("Relatório cancelado!","Atenção",,1)
		RETURN .F.
		
	ENDIF


Endif

_aheader := ;
{"Filial",;				//01
"Cent Custo",;			//03
"Setor",;				//02
"Matricula",;			//04
"Nome",;				//05
"Cargo",;				//06
"Munícipio",;			//07
"Estado",;				//08
"Dt. Ini. Per. Aquis",;	//09
"Dt. Fim. Per. Aquis",;	//10
"Dt Limite Maximo.",;	//11
;
"1o.Dt Inicio Ferias",;	//12
"1o.Dt Final Ferias",;	//13
"1o.Dias Ferias",;		//14
"1o.Dias Abono",;		//15
;
"2o.Dt Inicio Ferias",;	//16
"2o.Dt Final Ferias",;	//17
"2o.Dias Ferias",;		//18
"2o.Dias Abono",;		//19
;
"3o.Dt Inicio Ferias",;	//20
"3o.Dt Final Ferias",;	//21
"3o.Dias Ferias",;		//22
"3o.Dias Abono",;		//23
;
"Dias Vencidos",;		//24
"Dias Prop/Saldo",;		//25
"Tipo",;				//26
"Fim Gozo",;			//27
"Situacao do Func.",;   //29
"Dt Afastamento"}       //30

//Log de utilização
U_ITLOGACS()

PRIVATE _cTitulo:='Programação de Férias Filtros: Data: ' + DTOC(MV_PAR01)+" - Dias: "+STR(MV_PAR02,3)

IF !EMPTY(MV_PAR12) .OR. !EMPTY(MV_PAR13)
   _cTitulo+=" - Inicio Ferias de "+DTOC(MV_PAR12)+" ate "+DTOC(MV_PAR13)
ENDIF

If (isincallstack("MDIEXECUTE") .or. isincallstack("SIGAADV"))


	fwmsgrun(,{ |_oProc| _alog := RGPE016D(_oProc) },"Processando relatório...","Aguarde...")

	If len(_alog) > 0
	
		U_ITListBox( _cTitulo ,_aheader , _alog , .T. , 1 , _cTitulo )
		 			
	Else
	
		u_itmsg("Não foram localizados registros para esse filtro","Atenção",,2)
		_lenvia := .F.
		
	Endif
	
Else

	_cfiliais := u_itgetmv("ITFERFIL","92")
	_afils := strtokarr(_cfiliais,",")

	For _nzi := 1 to len(_afils)

		MV_PAR01 := DATE()+45
		MV_PAR02 := 31
		MV_PAR03 := '000000'
		MV_PAR04 := 'ZZZZZZ'
		MV_PAR05 := ' A*F*'
		MV_PAR06 := '***************'
		MV_PAR07 := _afils[_nzi]
		MV_PAR08 := 1
		MV_PAR09 := " "
		MV_PAR10 := " "

		_alog := RGPE016D()
		
		If len(_alog) > 0
			_cfil := cfilant
			cfilant := _afils[_nzi]
			RGPE016E(_alog,_aheader)
			cfilant := _cfil					
		Endif
				
	Next


Endif


Return 

/*
===============================================================================================================================
Programa----------: RGPE016E
Autor-------------: Josué Danich Prestes
Data da Criacao---: 25/06/2018
===============================================================================================================================
Descrição---------: Envia email do relatório
===============================================================================================================================
Parametros--------: _alog - Dados do relatório
					_aheader - cabeçalho do relatório
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static function RGPE016E(_alog,_aheader)

Local _aConfig	:= U_ITCFGEML('')
Local _cEmail	:= U_ITGETMV( 'IT_WFPRFR' , 'sistema@italac.com.br' )
Local _carquivo := "\temp\RGPE016.csv"  , _ni , _nc

erase(_carquivo)

U_RGPE016G( 'Relatório de programação de férias - ' + dtoc(date())  , _aHeader , _alog, 'RGPE016')
	

	_cMsgEml := '<html>'
	_cMsgEml += '<head><title></title>Relatório de programação de férias - ' + dtoc(date()) + '</head>'
	_cMsgEml += '<body>'
	_cMsgEml += '<style type="text/css"><!--'
	_cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
	_cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
	_cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
	_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
	_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
	_cMsgEml += 'td.aceito	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #00CC00; }'
	_cMsgEml += 'td.recusa  { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FF0000; }'
	_cMsgEml += '--></style>'
	_cMsgEml += '<center>'
	_cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="700" height="50"><br>'
	_cMsgEml += '<table class="bordasimples" width="700">'
	_cMsgEml += '    <tr>'
	_cMsgEml += '	<td class="titulos"><center>Relatório de programação de férias - ' + dtoc(date()) + '</center></td>'
	_cMsgEml += '	</tr>'
	_cMsgEml += '</table>'
	_cMsgEml += '<br>'
	_cMsgEml += '<table class="bordasimples" width="700">'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td align="center" colspan="2" class="grupos">Log Processamento</b></td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Data:</b></td>'
	_cMsgEml += '      <td class="itens" align="left" >'+ dtoc(date()) +'</td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Hora:</b></td>'
	_cMsgEml += '      <td class="itens" align="left" >'+ time() +'</td>'
	_cMsgEml += '    </tr>'
	
	_cMsgEml += '	<tr>'
	_cMsgEml += '      <td class="titulos" align="center" colspan="2"><font color="red">Esta é uma mensagem automática. Por favor não responder!</font></td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '</table>'
	

	_cMsgEml += '<br>'
	_cMsgEml += '<table class="bordasimples" width="1200">'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td align="center" colspan="18" class="grupos">Programação de férias</b></td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '    <tr>'	
	
	_cMsgEml += '      <td class="itens" align="center" width="10%"><b>Filial</b></td>'

	For _ni := 2 to len(_aheader)
	    _cMsgEml += '      <td class="itens" align="left" width="10%"><b>' + ( _aheader[_ni] ) + '</b></td>'
    Next

	_cMsgEml += '    </tr>'
	_cMsgEml += '</center>'
	
	For _ni := 1 to len(_alog)

		_cMsgEml += '    <tr>'

	    For _nc := 1 to LEN( _alog[_ni] )
	        IF _alog[_ni][_nc] <> "___  / ___ / ___"
		        _cMsgEml += '   <td class="itens" align="left" >' + ( _alog[_ni][_nc] ) + '</td>'        
		    ELSE
		        _cMsgEml += '   <td class="itens" align="left" ></td>'        
		    ENDIF		        
	    Next

		_cMsgEml += '    </tr>'

	Next

	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td class="itens" align="center">     </td>'
	_cMsgEml += '      <td class="itens" align="left" >      </td>'
	_cMsgEml += '    </tr>'

	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
	_cMsgEml += '      <td class="itens" align="left" > ['+ GetEnvServer() +'] </td>'
	_cMsgEml += '    </tr>'
	
	_cMsgEml += '</body>'
	_cMsgEml += '</html>'

_cEmlLog := ''

_cAssunto := "Programação de férias - Filial " + cfilant + " - " + dtoc(date())
_cEmlLog := ""

If !(isincallstack("MDIEXECUTE") .or. isincallstack("SIGAADV"))
	
		U_ITENVMAIL( _aConfig[01] , _cEmail ,        ,         ,_cAssunto, _cMsgEml ,_carquivo;
			,_aConfig[01],_aConfig[02], _aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )
	
Else

		fwmsgrun(,{ || U_ITENVMAIL( _aConfig[01] , _cEmail ,        ,         ,_cAssunto, _cMsgEml ,_carquivo;
	         ,_aConfig[01],_aConfig[02], _aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )},"Aguarde...","Enviando email...")


		U_ITMSG("Enviado arquivo "+_carquivo+" para "+_cEmail+CHR(13)+CHR(10)+_cEmlLog,"Atenção",,1)
	         
Endif

Return

/*
===============================================================================================================================
Programa----------: RGPE016D
Autor-------------: Josué Danich Prestes
Data da Criacao---: 25/06/2018
Descrição---------: Montar dados do relatório     
Parametros--------: Nenhum
Retorno-----------: _alog - Array com dados de relatório
===============================================================================================================================
*/
Static Function RGPE016D(_oProc)

Local _alog		:= {}
Local _cAliasSRA
Local _cQuery := ""
Local _ntot := 0

IF VALTYPE(_oProc) = "O"
   _oProc:cCaption := ("Lendo dados dos funcionarios ")
   ProcessMessages()
ENDIF   
 
//Faz query filtrando o SRA
_cQuery := " SELECT" 
_cQuery += "    R_E_C_N_O_  REC"
_cQuery += " FROM "+ RetSqlName("SRA") +" SRA "
_cQuery += " WHERE "
_cQuery += "     SRA.D_E_L_E_T_  = ' ' "        


If !Empty(MV_PAR03) .AND. !Empty(MV_PAR04)

	_cQuery += " AND SRA.RA_MAT >= '" + ALLTRIM(MV_PAR03) + "' AND SRA.RA_MAT <= '" + ALLTRIM(MV_PAR04) + "' "

   _cTitulo+=' - Matriculas de ' + ALLTRIM(MV_PAR03)+" ate "+ALLTRIM(MV_PAR04)

Endif

_csitfol := RGPE016F(MV_PAR05)

If !Empty(_csitfol)

	_cQuery += " AND SRA.RA_SITFOLH IN " + _csitfol

   _cTitulo+=' - Situacoes: ' + ALLTRIM(_csitfol)
	
Endif 

_ccatfunc := RGPE016F( AllTrim(MV_PAR06)  )

If !Empty(_ccatfunc)

	_cQuery += " AND SRA.RA_CATFUNC IN " + _ccatfunc

   _cTitulo+=' - Categorias: ' + ALLTRIM(_ccatfunc)
	
Endif 

If !Empty(MV_PAR07)

	_cQuery += " AND SRA.RA_FILIAL IN " + FormatIn( AllTrim(MV_PAR07) , ';' )

   _cTitulo+=' - Filiais: ' + ALLTRIM(MV_PAR07)
	
Endif 

If !Empty(MV_PAR09)

	_cQuery += " AND SRA.RA_I_SETOR IN " + FormatIn( AllTrim(MV_PAR09) , ';' )

   _cTitulo+=' - Setores: ' + ALLTRIM(MV_PAR09)
	
Endif 

If !Empty(MV_PAR11) 

	_cQuery += " AND SRA.RA_CC >= '" + MV_PAR10 + "' AND SRA.RA_CC <= '" + MV_PAR11 + "'"

   _cTitulo+=' - Centros de custos de: ' + ALLTRIM(MV_PAR10)+' ate ' + ALLTRIM(MV_PAR11)
	
Endif 

_cQuery += " ORDER BY RA_FILIAL,RA_MAT"

_cAliasSRA	:= GetNextAlias()   	
If Select(_cAliasSRA) > 0
	(_cAliasSRA)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAliasSRA , .T. , .F. )

COUNT TO _ntot  
_cTot:=ALLTRIM(STR(_ntot))
_nTam:=LEN(_cTot)+1

_nConta := 0
(_cAliasSRA)->(DBGOTOP())
_cAliasSRF	:= GetNextAlias()   	

Do while !(_cAliasSRA)->(Eof())

	SRA->(Dbgoto((_cAliasSRA)->REC))
	
    IF VALTYPE(_oProc) = "O"
       _nConta++
       _oProc:cCaption := ("Lendo funcionario " + SRA->RA_FILIAL + '/' + SRA->RA_MAT+" : "+STR(_nConta,_nTam)+" de "+_cTot )
       ProcessMessages()
    ENDIF   

	//Faz query filtrando o SRF
	_cQuery := " SELECT" 
	_cQuery += "    R_E_C_N_O_  REC"
	_cQuery += " FROM "+ RetSqlName("SRF") +" SRF "
	_cQuery += " WHERE "
	_cQuery += "     SRF.D_E_L_E_T_  = ' ' "
	_cQuery += " AND SRF.RF_FILIAL = '" + ALLTRIM(SRA->RA_FILIAL) + "' "
	_cQuery += " AND SRF.RF_MAT = '" + ALLTRIM(SRA->RA_MAT) + "' " 
    if !EMPTY(MV_PAR01)
	   _cQuery += " AND SRF.RF_DATAFIM <= '" + DTOS(MV_PAR01) + "' "
	ENDIF   
	_cQuery += " AND SRF.RF_STATUS = '1' "//só os ativos 
	_cQuery += " AND SRF.RF_DATABAS <= " + DTOS(DATE())
	_cQuery += " ORDER BY SRF.RF_DATABAS "
	      
	If Select(_cAliasSRF) > 0
		(_cAliasSRF)->( DBCloseArea() )
	EndIf
 
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAliasSRF , .T. , .F. )
	
	Do while !(_cAliasSRF)->(Eof())
	
		SRF->(Dbgoto((_cAliasSRF)->REC))

		_ddtbase 	:= iif(SRF->RF_DATABAS>SRA->RA_ADMISSA,SRF->RF_DATABAS,SRA->RA_ADMISSA)
	
        _cDtFimGozo := STOD("")
		_ddtiniciof := STOD("")
		_ddtfinalf  := STOD("")
		_ndiasFer   := 0 
		_ndiasAbon  := 0

		_d2dtiniciof:= STOD("")
		_d2dtfinalf := STOD("")
		_n2diasFer  := 0
		_n2diasAbon := 0

		_d3dtiniciof:= STOD("")
		_d3dtfinalf := STOD("")
		_n3diasFer  := 0
		_n3diasAbon := 0

		_ndiasprog := 0

		If  !EMPTY(SRF->RF_DFEPRO1) .OR. !EMPTY(SRF->RF_DATINI2) .OR. !EMPTY(SRF->RF_DATINI3)
	
			_ddtiniciof := SRF->RF_DATAINI
			_ddtfinalf 	:= SRF->RF_DATAINI+(SRF->RF_DFEPRO1-1)
			_ndiasFer   := SRF->RF_DFEPRO1
			_ndiasAbon  := SRF->RF_DABPRO1

			_ndiasprog  += SRF->RF_DFEPRO1 + SRF->RF_DABPRO1

			_d2dtiniciof := SRF->RF_DATINI2
			IF !EMPTY(SRF->RF_DATINI2)
			   _d2dtfinalf  := SRF->RF_DATINI2+(SRF->RF_DFEPRO2-1)
			ENDIF   
			_n2diasFer   := SRF->RF_DFEPRO2
			_n2diasAbon  := SRF->RF_DABPRO2

			_ndiasprog   += SRF->RF_DFEPRO2 + SRF->RF_DABPRO2

			_d3dtiniciof:= SRF->RF_DATINI3
			IF !EMPTY(SRF->RF_DATINI3)
			   _d3dtfinalf := SRF->RF_DATINI3+(SRF->RF_DFEPRO3-1)
			ENDIF   
			_n3diasFer  := SRF->RF_DFEPRO3
			_n3diasAbon := SRF->RF_DABPRO3

			_ndiasprog  += SRF->RF_DFEPRO3 + SRF->RF_DABPRO3

		Elseif !EMPTY(SRF->RF_DFERANT) 

			_ndiasprog  += SRF->RF_DFERANT
		
		Endif
	
        _nLimite   := 730-(IF(MV_PAR02<31,31,MV_PAR02)) //699
		_cperINI   := DTOC(SRF->RF_DATABAS) 
		_cperFIM   := DTOC(SRF->RF_DATAFIM)
		_cDtLimMax := DTOC(SRF->RF_DATABAS+_nLimite) 
		_ndiasvenc := SRF->RF_DFERVAT
		
		//Montagem de campo proporcional/Saldo conforme tipo de registro
		If SRF->RF_DFERVAT > 0
			_ndiasprop  := SRF->RF_DFERVAT - _ndiasprog
		Else
			_ndiasprop  := SRF->RF_DFERAAT - _ndiasprog
		Endif
	
		_ctipo := IF(SRF->RF_DFERVAT>0,"Vencida","Proporcional")
		_cSitu := "Ativo"// (A =Afastado, Vazio = Ativo, D = Demitido, T = Transferido)
		IF SRA->RA_SITFOLH="A"
		   _cSitu := "Afastado
		ELSEIF SRA->RA_SITFOLH="D"
		   _cSitu := "Demitido"
		ELSEIF SRA->RA_SITFOLH="T"
		   _cSitu := "Transferido"
		ENDIF
        
		_lLoop:=.F.
        IF !EMPTY(MV_PAR12) .OR. !EMPTY(MV_PAR13)
		   
		    _lLoop:=.T.
            IF !EMPTY(MV_PAR12) 
               IF     !EMPTY(_ddtiniciof ) .AND. _ddtiniciof  >= MV_PAR12  .AND. (EMPTY(MV_PAR13) .OR.  _ddtiniciof  <= MV_PAR13 )
			      _lLoop:=.F.
			   ELSEIF !EMPTY(_d2dtiniciof) .AND. _d2dtiniciof >= MV_PAR12  .AND. (EMPTY(MV_PAR13) .OR.  _d2dtiniciof <= MV_PAR13 )
			      _lLoop:=.F.
			   ELSEIF !EMPTY(_d3dtiniciof) .AND. _d3dtiniciof >= MV_PAR12  .AND. (EMPTY(MV_PAR13) .OR.  _d3dtiniciof <= MV_PAR13 )
			      _lLoop:=.F.
			   ENDIF
			ELSEIF !EMPTY(MV_PAR13)
               IF     !EMPTY(_ddtiniciof ) .AND. _ddtiniciof  <= MV_PAR13 
			      _lLoop:=.F.
			   ELSEIF !EMPTY(_d2dtiniciof) .AND. _d2dtiniciof <= MV_PAR13 
			      _lLoop:=.F.
			   ELSEIF !EMPTY(_d3dtiniciof) .AND. _d3dtiniciof <= MV_PAR13 
			      _lLoop:=.F.
			   ENDIF
			ENDIF
           
        ENDIF

        IF _lLoop
		   (_cAliasSRF)->(Dbskip())
		   LOOP
        ENDIF

		If MV_PAR08 == 3 .or. (MV_PAR08 == 1 .AND. _ctipo == "Vencida") .or. (MV_PAR08 == 2 .AND. _ctipo == "Proporcional");
			.OR. (!(isincallstack("MDIEXECUTE") .or. isincallstack("SIGAADV")) .AND.  _ndiasprop > 22) //Alerta prestes a vencer no schedule

            _cDtFimGozo    := BuscaGozo(SRA->RA_FILIAL+SRA->RA_MAT)
			_cDtAfastamento:= BuscaDtAfas(SRA->RA_FILIAL,SRA->RA_MAT)
		
			aadd(_alog,{SRA->RA_FILIAL,;   													//01 *
				fDesc("CTT",SRA->RA_CC,"CTT_DESC01",,SRA->RA_FILIAL) ,;						//02
				POSICIONE("ZAK",1,xfilial("ZAK")+SRA->RA_I_SETOR,"ZAK_DESCRI"),;			//03
				SRA->RA_MAT,;																//04
				IF(!EMPTY(SRA->RA_NSOCIAL),SRA->RA_NSOCIAL,SRA->RA_NOME) ,;																//05 *
				FDESC("SQ3",SRA->RA_CARGO,"Q3_DESCSUM",,SRA->RA_FILIAL),;					//06
				alltrim(SRA->RA_MUNICIP),;													//07			
				SRA->RA_ESTADO,;															//08
				_cperINI,;																	//09 *
				_cperFIM,;																	//10
				_cDtLimMax,;															    //11
                ;
				DTOC(_ddtiniciof),;	        												//12
				DTOC(_ddtfinalf ),;		    												//13
                STRZERO(_ndiasFer ,4,1),;											        //14 
                STRZERO(_ndiasAbon,4,1),;													//15 
				;
				DTOC(_d2dtiniciof),;	    												//16
				DTOC(_d2dtfinalf ),;														//17
                STRZERO(_n2diasFer ,4,1),;											        //18 
                STRZERO(_n2diasAbon,4,1),;													//19 
				;
				DTOC(_d3dtiniciof),;	    												//20
				DTOC(_d3dtfinalf ),;														//21
                STRZERO(_n3diasFer ,4,1),;											        //22 
                STRZERO(_n3diasAbon,4,1),;													//23 
				;
				Strzero(_ndiasvenc,4,1),;													//24
				Strzero(_ndiasprop,4,1),;													//25
				_ctipo,;																	//26
				_cDtFimGozo,;																//27 
				_cSitu,;																	//29
				_cDtAfastamento})															//30  

		Endif

		(_cAliasSRF)->(Dbskip())
	
	Enddo

	(_cAliasSRA)->(Dbskip())
	
Enddo

ASORT(_aLog,,,{|X,Y| ( X[1]+X[5]+DTOS(CTOD(X[9])) ) < ( Y[1]+Y[5]+DTOS(CTOD(Y[9])) ) })//ORDEM DE FILIAL + NOME + Dt. Ini. Per. Aquis

_cTot:=ALLTRIM(STR(LEN(_alog)))

Return _alog

/*
===============================================================================================================================
Programa----------: RGPE016F
Autor-------------: Josué Danich Prestes
Data da Criacao---: 25/06/2018
Descrição---------: Formata campo de situação 
Parametros--------: String a formatar
Retorno-----------: String formatado
===============================================================================================================================
*/
Static Function RGPE016F(_cDados)

Local _cStrFormt:= ""  , x

For x:=1 To Len(_cDados)
	
	If SubStr(_cDados,x,1) != "*" 
	
		If empty(_cStrFormt)
		
			_cStrFormt+= "("
			
		Endif
		
		_cStrFormt+= "'" + SubStr(_cDados,x,1) + "',"
		
	Endif
	
Next x

If !empty(_cStrFormt)
	_cStrFormt:= SubStr(_cStrFormt,1,Len(_cStrFormt) - 1) + ")"
Endif

Return _cStrFormt

/*
===============================================================================================================================
Programa----------: RGPE016G
Autor-------------: Josué Danich /prestes
Data da Criacao---: 10/07/2018
Descrição---------: Função para gerar arquivo CSV a partir de um Array
Parametros--------: _cTitArq  - Título do arquivo
------------------: _aHeader  - Cabeçalho do arquivo
------------------: _aCols    - Dados do arquivo
Retorno-----------: Nenhum
===============================================================================================================================
 */
User Function RGPE016G( _cTitAux , _aHeader , _aCols , _cNameFile )

Local _nHdlArq	:= 0
Local _nI		:= 0
Local _nX		:= 0
Local _cPthArq	:= '\temp'
Local _cPthDes	:= ''
Local _cNomArq	:= IF(_cNameFile = NIL,'PROTHEUS_'+ StrTran( Time() , ':' , '' ) + DtoS( Date() ) + RetCodUsr() +'.csv', _cNameFile +'.csv' )
Local _cArqTmp	:= _cPthArq +'\'+ _cNomArq
Local _cBuffer	:= ''

//==========================================
//Grava log de utilização da rotina
//==========================================
U_ITLOGACS()


If !Empty( _aHeader ) .And. !Empty( _aCols )

	If !ExistDir( _cPthArq )
		If MakeDir( _cPthArq ) <> 0
			u_itmsg( 'Não foi possível criar o diretório temporário para o arquivo, informe a área de TI/ERP!', "Alerta",,1  )
			Return .F.
		EndIf
	EndIf
	
	_nHdlArq := FCreate( _cArqTmp ,,, .F. )
	
	If _nHdlArq < 0
		u_itmsg(  'Não foi possível criar o arquivo no diretório temporário, informe a área de TI/ERP!' , "Alerta",,1 )
		Return .F.
	EndIf
	
	If !Empty( _cTitAux )
		FWrite( _nHdlArq , AllTrim( _cTitAux ) + ENTER )
	EndIf
	
	_cBuffer := ''
	
	For _nI := 1 To Len( _aHeader )
		_cBuffer += _aHeader[_nI] + ';'
	Next _nI
	
	FWrite( _nHdlArq , AllTrim( _cBuffer ) + ENTER )
	
	For _nI := 1 To Len( _aCols )
		
		_cBuffer := ''
		
		For _nX := 1 To Len( _aCols[_nI] )
			
			Do Case
				
				Case ValType( _aCols[_nI][_nX] ) == 'C'	; _cBuffer += _aCols[_nI][_nX]							+ ';'
				Case ValType( _aCols[_nI][_nX] ) == 'N'	; _cBuffer += cValToChar( _aCols[_nI][_nX] )			+ ';'
				Case ValType( _aCols[_nI][_nX] ) == 'L'	; _cBuffer += IIF( _aCols[_nI][_nX] , '.T.' , '.F.' )	+ ';'
				Case ValType( _aCols[_nI][_nX] ) == 'D'	; _cBuffer += DtoC( _aCols[_nI][_nX] )					+ ';'
				OtherWise								; _cBuffer += ';'
				
			EndCase
					
		Next _nX
		
		FWrite( _nHdlArq , AllTrim( _cBuffer ) + ENTER )
		
	Next _nI
	
	FClose( _nHdlArq )

    IF _cNameFile # NIL
       RETURN .T.
    ENDIF
	
	If File( _cArqTmp )
		
		_cPthDes := U_ITSELDIR()
		LjMsgRun( 'Copiando o arquivo...' , 'Aguarde!' , {|| CpyS2T( _cArqTmp , _cPthDes , .T. ) } )
		FErase( _cArqTmp )
		
	Else
		u_itmsg(  'Falha no processamento do arquivo, informe a área de TI/ERP!' , "Atenção",,1 )
        Return .F.
	EndIf
	
Else

	u_itmsg(  'Não foi possível verificar os dados para a geração do arquivo, não é possível criar um arquivo em branco!' ,  "Atenção",,1 )
    Return .F.
	
EndIf

Return .T.

/*
===============================================================================================================================
Programa----------: BuscaGozo()
Autor-------------: Alex Wallauer
Data da Criacao---: 21/01/2019
Descrição---------: Busca a data da ultima ferias gozada
Parametros--------: Matricula
Retorno-----------: data da ultima ferias gozada
===============================================================================================================================
*/
Static Function BuscaGozo(cMat) 
LOCAL _cDtFimGozo:=""

SR8->(DbSetOrder(2))  // R8_FILIAL+R8_MAT+R8_SEQ
SR8->(DbSeek(cMat))
Do While ! SR8->(Eof()) .And. SR8->R8_FILIAL+SR8->R8_MAT == cMat

	If SR8->R8_TIPOAFA = "001"
       _cDtFimGozo:=DTOC(SR8->R8_DATAFIM)
	Endif
	
	SR8->(DbSkip())
EndDo
//Não mostra as data menores que 60 dias 
IF CTOD(_cDtFimGozo) <= (DATE()-60) 
   _cDtFimGozo:=""
ENDIF
RETURN _cDtFimGozo

/*
===============================================================================================================================
Função------------: BuscaDtAfas
Autor-------------: Alex Wallauer
Data da Criacao---: 24/06/2020
Descrição---------: Retornar a ultima data de afastamento do funcionário.
Parametros--------: _cFilial    = Filial do funcionário
                    _cMatricula = Código de matricula
Retorno-----------: _DataAfast  = Data de afastamento do funcionário.
===============================================================================================================================
*/
Static function BuscaDtAfas(_cFilial, _cMatricula)
Local _dRet := Ctod("  /  /  ")
Local _cQry, _cAlias
Local _aSaveArea := GetArea()

Begin Sequence
   _cQry := " SELECT R8_DATAINI FROM "+RetSqlName("SR8")+ " SR8 "
   _cQry += " WHERE SR8.R8_FILIAL = '" + _cFilial + "' AND SR8.D_E_L_E_T_ = ' ' "
   _cQry += " AND SR8.R8_MAT = '" + _cMatricula + "' "
   _cQry += " AND SR8.R8_TIPOAFA <> '001' "
   _cQry += " AND SR8.R8_DATAINI <= '"+Dtos(Date())+"' "
   _cQry += " AND (SR8.R8_DATAFIM = '        ' OR SR8.R8_DATAFIM >= '"+Dtos(Date())+"' ) "
   
   _cAlias := GetNextAlias()
		
   If Select(_cAlias) > 0
	  (_cAlias)->( DBCloseArea() )
   EndIf
		
   DBUseArea( .T. , "TOPCONN" , TCGenQry(,,_cQry) , _cAlias , .F. , .T. )
   TcSetField(_cAlias,"R8_DATAINI","D",8,0)
		
   (_cAlias)->( DBGoTop() )
   
   Do While (_cAlias)->( !Eof() )
	  If ! Empty((_cAlias)->R8_DATAINI)
	     If Dtos(_dRet) < Dtos((_cAlias)->R8_DATAINI)
	        _dRet := (_cAlias)->R8_DATAINI
	     EndIf
	  EndIf
			
      (_cAlias)->( DBSkip() )
   EndDo
		
   (_cAlias)->( DBCloseArea() )

End Sequence

RestArea(_aSaveArea)

Return _dRet
