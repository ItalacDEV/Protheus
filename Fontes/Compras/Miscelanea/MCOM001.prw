/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Igor Melga�o  |14/07/2022| Chamado 40685 - Valida��o do tipo do documento nas querys da tabela SCR, campo CR_TIPO = 'PC'
Alex Wallauer |08/02/2023| Chamado 42719. Acrescentada a opcao NF no campo C7_I_URGEN : S(SIM), N(NAO) F(NF).
Lucas Borges  |13/10/2024| Chamado 48465. Retirada da fun��o de conout
Lucas Borges  |23/07/2025| Chamado 51340. Trocado e-mail padr�o para sistema@italac.com.br
===============================================================================================================================
*/
#Include "rwmake.ch"
#Include "tbiconn.ch"
#Include "protheus.ch"
#Include "topconn.ch"
#DEFINE ENTER ""//CHR(13)+CHR(10)

/*
===============================================================================================================================
Programa----------: MCOM01GR()
Autor-------------: Alex Wallauer
Data da Criacao---: 15/02/2018
Descri��o---------: Rotina responsavel pelo envio do relat�rio de Pedidos Liberados da semna por e-mail 
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MCOM01GR()

U_MCOM001(.T.)

RETURN

/*
===============================================================================================================================
Programa----------: MCOM001
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 29/02/2016
Descri��o---------: Rotina responsavel pelo envio do relat�rio de Pedidos Liberados do dia anterior por e-mail 
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MCOM001(lPorGrupo)

Local _aTables	:= {"SCR","SC7","ZZL"}
Local cPerg		:= "MCOM001"
Local oproc      
DEFAULT lPorGrupo := .F.

IF VALTYPE(lPorGrupo) <> "L"//Caso venha uma array 
   _lPorGrupo := .F.
ELSE   
   _lPorGrupo := lPorGrupo
ENDIF

//Private _cHostWF	:= ""
Private _dDtIni		:= ""
Private lAmbiente	:= .F.
Private _lCriaAmb	:= .F.

//=============================================================
// Verifica a necessidade de criar um ambiente, caso nao esteja
// criado anteriormente um ambiente, pois ocorrera erro
//=============================================================
If Select("SX3") <= 0
	_lCriaAmb:= .T.
EndIf

If _lCriaAmb

	//=====================
	// Nao consome licensas
	//=====================
	RPCSetType(3)

	//===========================================
	// Seta o ambiente com a empresa 01 filial 01
	//===========================================
	RpcSetEnv("01","01",,,,"SCHEDULE_PC_LIBERADOS",_aTables)

    IF _lPorGrupo
       MV_PAR01:=DATE()-7
       MV_PAR02:=DATE() 
    ELSE
       MV_PAR01:=DATE()-1
       MV_PAR02:=DATE()-1
    ENDIF
	//========================================================================================
	// Mensagem que ficara armazenada no arquivo totvsconsole.log para posterior monitoramento
	//======================================================================================== 
	FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "SCHEDULE"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MCOM00101"/*cMsgId*/, "MCOM00101 - Gerando envio da Lista de Pedidos Aprovados na data: " + Dtoc(MV_PAR01) + " ate "+Dtoc(MV_PAR02)+" por e-mail."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
    
Else
	lAmbiente := .T.
EndIf

Private _cGrupos    := ALLTRIM(U_ITGetMV( "IT_MC01GRC" , "000090" ))
Private _cEmailDir  := ALLTRIM(U_ITGetMV( "IT_MCO1EMD" , "sistema@italac.com.br" ))
Private _cTitGrupo  := ""
IF _lPorGrupo
   _cTitGrupo :=" - GESTAO GERENCIA"
ENDIF   


If lAmbiente
	If !Pergunte(cPerg,.T.)
	     return
	EndIf
EndIf

//Executa relat�rio
If lAmbiente

	fwmsgrun(,{|oproc| MCOM001P(oproc)},"Aguarde...","Processando relat�rio...")

Else

	FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "SCHEDULE"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MCOM00102"/*cMsgId*/, "MCOM00102 - Iniciando relat�rio de pedidos liberados..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	MCOM001P(oproc)
	FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "SCHEDULE"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MCOM00103"/*cMsgId*/, "MCOM00103 - Relat�rio de pedidos liberados executado com sucesso."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

Endif

Return


/*
===============================================================================================================================
Programa----------: MCOM001P
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 29/02/2016
Descri��o---------: Processamento do relat�rio
Parametros--------: oproc - objeto da barra de processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MCOM001P(oproc)

Local _cQryR03		:= "" , A
Local _cQryR04		:= ""
Local _cHtml03		:= ""
Local _cHtml04		:= ""
Local _cQryR3		:= ""
Local _cQryR4		:= ""
Local _cQryZZL		:= ""
//Local cLogo			:= ""
Local cEmail		:= ""
//Local _cAssunto		:= ""
//Local _cCodProce	:= ""
//Local _cHtmlMode	:= ""
Local lWFHTML		:= .T.
Local _cHtml		:= ""
Local _aConfig		:= {}
Local _cEmlLog		:= ""
Local lEmail		:= .F.
Local nTotal		:= 0
Local nCount		:= 0
Local dDataLib		:= Ctod("//")
Local cHrApr		:= ""
Local cObs			:= ""
Local cUsuario		:= ""
Local cStatus		:= ""
Local cCmpDi		:= ""
Local cUrgen		:= ""
Local cFornece		:= ""
Local cLoja			:= ""
Local cNreduz		:= ""
Local dDatPrf		:= Ctod("//")
Local _cFilial		:= ""
Local cNumPc		:= ""
Local lImprime		:= .F.
Local lLibera		:= .T.
Local lRejeita		:= .T.

//================================
//Guardo valor padr�o do par�metro
//================================
lWFHTML	:= GetMv("MV_WFHTML")

//=========================================================
//Altero o valor do par�metro para enviar o modelo em anexo
//=========================================================
PutMV("MV_WFHTML",.F.)

_aConfig  := U_ITCFGEML('')
_dDtIni	  := DtoS(U_ItGetMv("IT_WFPCINI","20150101"))
cGetAssun := "Relat�rio Pedidos Liberados / Rejeitados no Per�odo de " + DtoC(MV_PAR01) + " at� " + DtoC(MV_PAR02)+_cTitGrupo

_cHtml += '<html>'
_cHtml += '<head>'
_cHtml += '<title>Pedidos Liberados/Rejeitados</title>'
_cHtml += '</head>'
_cHtml += '<style type="text/css"><!--'
_cHtml += 'table.bordasimples { border-collapse: collapse; }'
_cHtml += 'table.bordasimples tr td { border:1px solid #777777; }'
_cHtml += 'td.grupos	{ font-family:VERDANA; font-size:20px; V-align:middle; background-color: #C6E2FF; color:#000080; }'
_cHtml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #EEDD82; }'
_cHtml += 'td.texto	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; }'
_cHtml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #DDDDDD; }'
_cHtml += 'td.totais	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #7f99b2; color:#FFFFFF; }'
_cHtml += '--></style>'
 
_cHtml += '<body bgcolor="#FFFFFF">'
_cHtml += '<center>'

If lAmbiente

	oproc:cCaption := ("1/3 - Carregando libera��es...")
	ProcessMessages()
	
Endif


//===========================================
//Query que lista os PC's que foram liberados
//===========================================
_cQryR03 := "SELECT CR_FILIAL, CR_NUM, MAX(CR_NIVEL) CR_NIVEL " 
_cQryR03 += "FROM " + RetSqlName("SCR") + " SCR "
_cQryR03 += "WHERE CR_STATUS = '03' "
_cQryR03 += "  AND CR_TIPO = 'PC' "
//If lAmbiente
	_cQryR03 += "  AND CR_DATALIB BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "
//Else
//	_cQryR03 += "  AND CR_DATALIB = '" + DtoS(Date()-1) + "' "
//EndIf    
IF _lPorGrupo
  _cQryR03 += "  AND CR_GRUPO IN " + FormatIn(_cGrupos,";")
EndIf    

_cQryR03 += " AND CR_NIVEL = (SELECT MAX(CR_NIVEL) FROM " + RetSqlName("SCR") + " SCR2 "+ " WHERE SCR2.D_E_L_E_T_ = ' ' AND SCR2.CR_TIPO = 'PC'  AND SCR2.CR_FILIAL = SCR.CR_FILIAL AND SCR2.CR_NUM = SCR.CR_NUM) "

_cQryR03 += "  AND D_E_L_E_T_ = ' ' "
_cQryR03 += "GROUP BY CR_FILIAL, CR_NUM "
_cQryR03 += "ORDER BY CR_FILIAL, CR_NUM "

FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "SCHEDULE"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MCOM00104"/*cMsgId*/, "MCOM00104 - SELECT 1: "+_cQryR03/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQryR03 ) , "TRBR03" , .T., .F. )

dbSelectArea("TRBR03")
TRBR03->(dbGoTop())

If TRBR03->(Eof())
	lLibera := .F.
Else

	While !TRBR03->(Eof())
	
		nCount := 0
		nTotal := 0

        If lAmbiente
        	oproc:cCaption := ("1/3 - Lendo PV: "+TRBR03->CR_FILIAL +"-"+TRBR03->CR_NUM)
        	ProcessMessages()
        Endif
	
		//=============================================================
		//Posiciono no pedido para fazer a somat�ria do total do pedido
		//=============================================================
		dbSelectArea("SC7")
		dbSetOrder(1)
		If dbSeek( TRBR03->CR_FILIAL + SubStr(TRBR03->CR_NUM,1,6) )
	
			While !SC7->(Eof()) .And. SC7->C7_FILIAL == TRBR03->CR_FILIAL .And. SC7->C7_NUM == SubStr(TRBR03->CR_NUM,1,6)
				If SC7->C7_CONAPRO == "L"
					lImprime	:= .T.
					lEmail		:= .T.
					nCount++
					If nCount == 1
						//======================================================================================
						//Query que lista apenas o �ltimo n�vel de aprova��o, para impress�o dos dados no e-mail
						//======================================================================================
						_cQryR3 := "SELECT R_E_C_N_O_ AS REC "
						_cQryR3 += "FROM " + RetSqlName("SCR") + " "
						_cQryR3 += "WHERE CR_FILIAL = '" + TRBR03->CR_FILIAL + "' "
						_cQryR3 += "  AND CR_TIPO = 'PC' "
						_cQryR3 += "  AND SUBSTR(CR_NUM,1,6) = '" + SubStr(TRBR03->CR_NUM,1,6) + "' "
						_cQryR3 += "  AND CR_NIVEL = '" + TRBR03->CR_NIVEL + "' "
						_cQryR3 += "  AND D_E_L_E_T_ = ' ' "
		
						dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQryR3 ) , "TRBR3" , .T., .F. )
		
						dbSelectArea("TRBR3")
						TRBR3->(dbGoTop())
		
						SCR->(Dbgoto(TRBR3->REC))
		
						dDataLib	:= DTOS(SCR->CR_DATALIB)
						cHrApr		:= SCR->CR_I_HRAPR
						cObs		:= ALLTRIM(SCR->CR_OBS)
                    	IF !_lPorGrupo
						   cObs		+= " ("+SCR->CR_GRUPO+")"
						ENDIF
						cUsuario	:= SCR->CR_USER
						cStatus		:= "Aprovado"
						If SC7->C7_I_CMPDI == "S"
							cCmpDi	:= "Sim"
						Else
							cCmpDi	:= "N�o"
						EndIf
						If SC7->C7_I_URGEN == "S"
							cUrgen	:= "Sim"
						ELSEIf SC7->C7_I_URGEN == "F"
							cUrgen	:= "NF"
						Else
							cUrgen	:= "N�o"
						EndIf
						_cFilial	:= SC7->C7_FILIAL + " - " + AllTrim(FWFilialName(cEmpAnt, SC7->C7_FILIAL))
						cNumPc		:= SC7->C7_NUM
						cFornece	:= SC7->C7_FORNECE
						cLoja		:= SC7->C7_LOJA
						cNreduz		:= Posicione("SA2",1,xFilial("SA2") + cFornece + cLoja, "A2_NREDUZ")
						dDatPrf		:= SC7->C7_DATPRF
		
						dbSelectArea("TRBR3")
						TRBR3->(dbCloseArea())
					EndIf
					nTotal += SC7->C7_TOTAL
				EndIf
				SC7->(dbSkip())
			End
	
			If lImprime
				_cHtml03 += '	<tr>'+ENTER
				_cHtml03 += '		<td valign="top" height="23" class="itens">' + _cFilial + '</td>'
				_cHtml03 += '		<td valign="top" height="23" class="itens">' + cNumPc + '</td>'
				_cHtml03 += '		<td valign="top" height="23" class="itens">' + AllTrim(cNreduz) + '</td>'
				_cHtml03 += '		<td align="right" valign="top" height="23" class="itens">' + Transform(nTotal, PesqPict("SC7","C7_TOTAL")) + '</td>'
				_cHtml03 += '		<td valign="top" height="23" class="itens"><center>' + cCmpDi + '</center></td>'
				_cHtml03 += '		<td valign="top" height="23" class="itens"><center>' + cUrgen + '</center></td>'
				_cHtml03 += '		<td valign="top" height="23" class="itens">' + AllTrim(cObs) + '</td>'
				IF !_lPorGrupo
				   _cHtml03 += '	<td valign="top" height="23" class="itens">' + SubStr(AllTrim(UsrRetName(cUsuario)),1,Len(AllTrim(UsrRetName(cUsuario)))-1) + '</td>'
				ENDIF   
				_cHtml03 += '		<td valign="top" height="23" class="itens"><center>' + DtoC(StoD(dDataLib)) + " - " + cHrApr + '</center></td>'+ENTER
				_cHtml03 += '		<td valign="top" height="23" class="itens"><center>' + DtoC(dDatPrf) + '</center></td>'+ENTER
//				_cHtml03 += '		<td valign="top" height="23" class="itens">' + cStatus + '</td>'
				_cHtml03 += '	</tr>'+ENTER
				lImprime := .F.
			EndIf
	
		EndIf
	
		TRBR03->(dbSkip())
	End

	_cHtml += '<table width="100%" cellspacing="0" cellpadding="2" border="0">'+ENTER
	_cHtml += '	<tr>'+ENTER
	_cHtml += '		<td width="02%" class="grupos">'+ENTER
	_cHtml += '			<center><img src="http://www.italac.com.br/wp-content/themes/italac/assets/images/logo.svg" width="100px" height="030px"></center>'+ENTER
	_cHtml += '		</td>'
	_cHtml += '		<td width="98%" class="grupos"><center>Rela��o de Pedidos Liberados no Per�odo de ' + DtoC(MV_PAR01) + ' at� ' + DtoC(MV_PAR02) +_cTitGrupo+ '</center></td>'
	_cHtml += '	</tr>'+ENTER

	IF _lPorGrupo
		_cHtml += '</table>'+ENTER
		_cHtml += '<br>	'+ENTER		
		_cHtml += '<table width="40%" border="0" CellSpacing="2" CellPadding="0">'+ENTER
		_cHtml += '	<tr>'+ENTER
		_cHtml += '		<td align="center" height="15" class="totais">TABELA DE APROVADORES ('+_cGrupos+')</center></td>'+ENTER
		_cHtml += '	</tr>'+ENTER
		_cHtml += '</table>'+ENTER
		_cHtml += '<table width="40%" border="0" CellSpacing="2" CellPadding="0">'+ENTER
		_aProv:=MCOM01Grupo(_cGrupos)
		FOR A := 1 TO LEN(_aProv)
			_cHtml += '	<tr>'+ENTER
			_cHtml += '		<td valign="top" height="15" class="itens">' + _aProv[A,1] + '</td>'+ENTER
			_cHtml += '		<td valign="top" height="15" class="itens">' + _aProv[A,2] + '</td>'+ENTER
			_cHtml += '	</tr>'+ENTER
		NEXT
	    _cHtml += '</table>'+ENTER
		_cHtml += '<br>	'+ENTER		
    ELSE
	    _cHtml += '</table>'+ENTER
	ENDIF

	_cHtml += '<table width="100%" border="0" CellSpacing="2" CellPadding="0">'+ENTER
	_cHtml += '	<tr>'+ENTER
	_cHtml += '		<td align="center" height="23" class="totais">Filial</td>'+ENTER
	_cHtml += '		<td align="center" height="23" class="totais">Pedido</td>'+ENTER
	_cHtml += '		<td align="center" height="23" class="totais">Fornecedor</td>'+ENTER
	_cHtml += '		<td align="center" height="23" class="totais">Valor Pedido</td>'+ENTER
	_cHtml += '		<td align="center" height="23" class="totais">Compra<br>Direta</td>'+ENTER
	_cHtml += '		<td align="center" height="23" class="totais">Urgente</td>'+ENTER
	_cHtml += '		<td align="center" height="23" class="totais">Observa��o</td>'+ENTER
    IF !_lPorGrupo
	    _cHtml += '	<td align="center" height="23" class="totais">Aprovador</td>'+ENTER
    ENDIF
	_cHtml += '		<td align="center" height="23" class="totais">Data Libera��o</td>'+ENTER
	_cHtml += '		<td align="center" height="23" class="totais">Data Entrega</td>'+ENTER
//	_cHtml += '		<td align="center" height="23" class="totais">Status</td>'
	_cHtml += '	</tr>'+ENTER

	_cHtml03 += '	</table>'
	_cHtml03 += '	<br><br><br>'
	
	_cHtml += _cHtml03

EndIf

If lAmbiente

	oproc:cCaption := ("2/3 - Carregando rejei��es...")
	ProcessMessages()
	
Endif


//============================================
//Query que lista os PC's que foram Rejeitados
//============================================
_cQryR04 := "SELECT CR_FILIAL, CR_NUM, MAX(CR_NIVEL) CR_NIVEL " 
_cQryR04 += "FROM " + RetSqlName("SCR") + " SCR "
_cQryR04 += "WHERE CR_STATUS = '04' "
_cQryR03 += "  AND CR_TIPO = 'PC' "
//If lAmbiente
	_cQryR04 += "  AND CR_DATALIB BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "
//Else
//	_cQryR04 += "  AND CR_DATALIB = '" + DtoS(Date()-1) + "' "
//EndIf
IF _lPorGrupo
   _cQryR04 += "  AND CR_GRUPO IN " + FormatIn(_cGrupos,";")
EndIf    
_cQryR04 += " AND CR_NIVEL = (SELECT MAX(CR_NIVEL) FROM " + RetSqlName("SCR") + " SCR2 "+ " WHERE SCR2.D_E_L_E_T_ = ' ' AND SCR2.CR_TIPO = 'PC' AND SCR2.CR_FILIAL = SCR.CR_FILIAL AND SCR2.CR_NUM = SCR.CR_NUM) "
_cQryR04 += "  AND D_E_L_E_T_ = ' ' "
_cQryR04 += "GROUP BY CR_FILIAL, CR_NUM "
_cQryR04 += "ORDER BY CR_FILIAL, CR_NUM "

FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "SCHEDULE"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MCOM00105"/*cMsgId*/, "MCOM00105 - SELECT 2: "+_cQryR04/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQryR04 ) , "TRBR04" , .T., .F. )

dbSelectArea("TRBR04")
TRBR04->(dbGoTop())

If TRBR04->(Eof())
	lRejeita := .F.
Else

	While !TRBR04->(Eof())
	
		lEmail := .T.
	
		nCount := 0
		nTotal := 0
        If lAmbiente
        	oproc:cCaption := ("2/3 - Lendo PV: "+TRBR04->CR_FILIAL +"-"+TRBR04->CR_NUM)
        	ProcessMessages()
        Endif
	
		//=============================================================
		//Posiciono no pedido para fazer a somat�ria do total do pedido
		//=============================================================
		dbSelectArea("SC7")
		dbSetOrder(1)
		If dbSeek( TRBR04->CR_FILIAL + SubStr(TRBR04->CR_NUM,1,6) )
	
			While !SC7->(Eof()) .And. SC7->C7_FILIAL == TRBR04->CR_FILIAL .And. SC7->C7_NUM == SubStr(TRBR04->CR_NUM,1,6)
				nCount++
				If nCount == 1
					//======================================================================================
					//Query que lista apenas o �ltimo n�vel de aprova��o, para impress�o dos dados no e-mail
					//======================================================================================
					_cQryR4 := "SELECT R_E_C_N_O_ AS REC "
					_cQryR4 += "FROM " + RetSqlName("SCR") + " "
					_cQryR4 += "WHERE CR_FILIAL = '" + TRBR04->CR_FILIAL + "' "
					_cQryR4 += "  AND CR_TIPO = 'PC' "
					_cQryR4 += "  AND SUBSTR(CR_NUM,1,6) = '" + SubStr(TRBR04->CR_NUM,1,6) + "' "
					_cQryR4 += "  AND CR_NIVEL = '" + TRBR04->CR_NIVEL + "' "
					_cQryR4 += "  AND D_E_L_E_T_ = ' ' "
		
					dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQryR4 ) , "TRBR4" , .T., .F. )
		
					dbSelectArea("TRBR4")
					TRBR4->(dbGoTop())
					
					SCR->(Dbgoto(TRBR4->REC))
		
					dDataLib	:= DTOS(SCR->CR_DATALIB)
					cHrApr		:= SCR->CR_I_HRAPR
					cObs		:= ALLTRIM(SC7->C7_I_OBSAP)
                   	IF !_lPorGrupo
					   cObs		+= " ("+SCR->CR_GRUPO+")"
					ENDIF
					cUsuario	:= SCR->CR_USER
					cStatus		:= "Rejeitado"
					If SC7->C7_I_CMPDI == "S"
						cCmpDi	:= "Sim"
					Else
						cCmpDi	:= "N�o"
					EndIf
					If SC7->C7_I_URGEN == "S"
						cUrgen	:= "Sim"
					ELSEIf SC7->C7_I_URGEN == "F"
						cUrgen	:= "NF"
					Else
						cUrgen	:= "N�o"
					EndIf
					_cFilial	:= SC7->C7_FILIAL + " - " + AllTrim(FWFilialName(cEmpAnt, SC7->C7_FILIAL))
					cNumPc		:= SC7->C7_NUM
					cFornece	:= SC7->C7_FORNECE
					cLoja		:= SC7->C7_LOJA
					cNreduz		:= Posicione("SA2",1,xFilial("SA2") + cFornece + cLoja, "A2_NREDUZ")
					dDatPrf		:= SC7->C7_DATPRF
		
					dbSelectArea("TRBR4")
					TRBR4->(dbCloseArea())
		
				EndIf
				nTotal += SC7->C7_TOTAL
				SC7->(dbSkip())
			End
	
			_cHtml04 += '	<tr>'
			_cHtml04 += '		<td valign="top" height="23" class="itens">' + _cFilial + '</td>'
			_cHtml04 += '		<td valign="top" height="23" class="itens">' + cNumPc + '</td>'
			_cHtml04 += '		<td valign="top" height="23" class="itens">' + AllTrim(cNreduz) + '</td>'
			_cHtml04 += '		<td align="right" valign="top" height="23" class="itens">' + Transform(nTotal, PesqPict("SC7","C7_TOTAL")) + '</td>'
			_cHtml04 += '		<td valign="top" height="23" class="itens"><center>' + cCmpDi + '</center></td>'
			_cHtml04 += '		<td valign="top" height="23" class="itens"><center>' + cUrgen + '</center></td>'
			_cHtml04 += '		<td valign="top" height="23" class="itens">' + AllTrim(cObs) + '</td>'
			_cHtml04 += '		<td valign="top" height="23" class="itens">' + SubStr(AllTrim(UsrRetName(cUsuario)),1,Len(AllTrim(UsrRetName(cUsuario)))-1) + '</td>'
			_cHtml04 += '		<td valign="top" height="23" class="itens"><center>' + DtoC(StoD(dDataLib)) + " - " + cHrApr + '</center></td>'
//			_cHtml04 += '		<td valign="top" height="23" class="itens"><center>' + DtoC(dDatPrf) + '</center></td>'
//			_cHtml04 += '		<td valign="top" height="23" class="itens">' + cStatus + '</td>'
			_cHtml04 += '	</tr>'
	
		EndIf
	
		TRBR04->(dbSkip())
	End
	
	_cHtml += '<table width="100%" cellspacing="0" cellpadding="2" border="0">'
	_cHtml += '	<tr>'
	_cHtml += '		<td width="02%" class="grupos">'
	_cHtml += '			<center><img src="http://www.italac.com.br/wp-content/themes/italac/assets/images/logo.svg" width="100px" height="030px"></center>'
	_cHtml += '		</td>'
	_cHtml += '		<td width="98%" class="grupos"><center>Rela��o de Pedidos Rejeitados no Per�odo de ' + DtoC(MV_PAR01) + ' at� ' + DtoC(MV_PAR02) +_cTitGrupo+ '</center></td>'
	_cHtml += '	</tr>'
	_cHtml += '</table>'
	
	_cHtml += '<table width="100%" border="0" CellSpacing="2" CellPadding="0">'
	_cHtml += '	<tr>'
	_cHtml += '		<td align="center" height="23" class="totais">Filial</td>'
	_cHtml += '		<td align="center" height="23" class="totais">Pedido</td>'
	_cHtml += '		<td align="center" height="23" class="totais">Fornecedor</td>'
	_cHtml += '		<td align="center" height="23" class="totais">Valor Pedido</td>'
	_cHtml += '		<td align="center" height="23" class="totais">Compra<br>Direta</td>'
	_cHtml += '		<td align="center" height="23" class="totais">Urgente</td>'
	_cHtml += '		<td align="center" height="23" class="totais">Observa��o</td>'
	_cHtml += '		<td align="center" height="23" class="totais">Aprovador</td>'
	_cHtml += '		<td align="center" height="23" class="totais">Data Rejei��o</td>'
//	_cHtml += '		<td align="center" height="23" class="totais">Data Entrega</td>'
//	_cHtml += '		<td align="center" height="23" class="totais">Status</td>'
	
	_cHtml04 += '</table>'

	_cHtml04 += '<br><br><br>'

	_cHtml += _cHtml04

EndIf

_cHtml += '<table>'
_cHtml += '<tr>'
_cHtml += '	<td class="grupos" align="center" colspan="8"><a href="http://www.italac.com.br/">http://www.italac.com.br/</a></td>'
_cHtml += '</tr>'
_cHtml += '<tr>'
_cHtml += '	<td class="grupos" align="center" colspan="8"><font color="red"><u>Esta � uma mensagem autom�tica. Por favor n�o a responda!</u></font></td>'
_cHtml += '</tr>'
_cHtml += '</table>'

_cHtml += '</center>'
_cHtml += '</body>'
_cHtml += '</html>
_cHtml += '<br><br>'
_cHtml += '<br>Ambiente: '+GetEnvServer()+'<br>'

dbSelectArea("TRBR04")
TRBR04->(dbCloseArea())

dbSelectArea("TRBR03")
TRBR03->(dbCloseArea())

If lAmbiente

	oproc:cCaption := ("3/3 - Enviando emails...")
	ProcessMessages()
	
Endif


If lAmbiente
	If !lLibera .And. !lRejeita
		u_itmsg('N�o existe nenhum PC Aprovado/Rejeitado no per�odo selecionado.','Aten��o',,1)
	Else
		If lEmail
			
			IF _lPorGrupo
				
				cEmail :=_cEmailDir
				
			ELSE
				
				_cQryZZL := "SELECT ZZL_CODUSU, ZZL_USER, ZZL_NOME, ZZL_EMAIL "
				_cQryZZL += "FROM " + RetSqlName("ZZL") + " "
				_cQryZZL += "WHERE ZZL_ADMPC = 'S' "
				_cQryZZL += "  AND D_E_L_E_T_ = ' ' "
				
				dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQryZZL ) , "TRBZZL" , .T., .F. )
				
				dbSelectArea("TRBZZL")
				TRBZZL->(dbGoTop())
				
				While !TRBZZL->(Eof())
					cEmail += AllTrim(Lower(TRBZZL->ZZL_EMAIL)) + ","
					TRBZZL->(dbSkip())
				End
				
				cEmail := _cEmailDir//SubStr(cEmail,1,Len(cEmail)-1)
				
				dbSelectArea("TRBZZL")
				TRBZZL->(dbCloseArea())
				
			ENDIF
            //Para teste
            //_cdir :="c:\smartclient\"
  		    //nHandle := FCreate(_cdir+"RELACAO_PC.HTM")
  		    //FWrite(nHandle, _cHtml )
  		    //FClose(nHandle)
			
			//====================================
			// Chama a fun��o para envio do e-mail
			//====================================
			U_ITENVMAIL( "", cEmail, "", cEmail, cGetAssun, _cHtml, "", _aConfig[01], _aConfig[02], _aConfig[03], _aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )
		EndIf
	EndIf
Else
	If !lLibera .And. !lRejeita
		_cHtml := '<html>'
		_cHtml += '<head>'
		_cHtml += '<title>Pedidos Liberados/Rejeitados</title>'
		_cHtml += '</head>'
		_cHtml += '<style type="text/css"><!--'
		_cHtml += 'table.bordasimples { border-collapse: collapse; }'
		_cHtml += 'table.bordasimples tr td { border:1px solid #777777; }'
		_cHtml += 'td.grupos	{ font-family:VERDANA; font-size:20px; V-align:middle; background-color: #C6E2FF; color:#000080; }'
		_cHtml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #EEDD82; }'
		_cHtml += 'td.texto	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; }'
		_cHtml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #DDDDDD; }'
		_cHtml += 'td.totais	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #7f99b2; color:#FFFFFF; }'
		_cHtml += '--></style>'
		 
		_cHtml += '<body bgcolor="#FFFFFF">'
		_cHtml += '<center>'

		_cHtml += '<table>'
		_cHtml += '<tr>'
		_cHtml += '	<td class="grupos" align="center" colspan="8"><a href="http://www.italac.com.br/">http://www.italac.com.br/</a></td>'
		_cHtml += '</tr>'
		_cHtml += '<tr>'
		_cHtml += '	<td class="grupos" align="center" colspan="8"><font color="red"><u>Esta � uma mensagem autom�tica. Por favor n�o a responda!</u></font></td>'
		_cHtml += '</tr>'
		_cHtml += '</table>'
		
		_cHtml += '</center>'
		_cHtml += '</body>'
		_cHtml += '</html>

		cGetAssun	:= "N�o existe PC Liberado / Rejeitado no per�odo de " + DtoC(MV_PAR01) + ' at� ' + DtoC(MV_PAR02)+_cTitGrupo
	EndIf

	IF _lPorGrupo
		
		cEmail :=_cEmailDir
		
	ELSE
		
		_cQryZZL := "SELECT ZZL_CODUSU, ZZL_USER, ZZL_NOME, ZZL_EMAIL "
		_cQryZZL += "FROM " + RetSqlName("ZZL") + " "
		_cQryZZL += "WHERE ZZL_ADMPC = 'S' "
		_cQryZZL += "  AND D_E_L_E_T_ = ' ' "
		
		dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQryZZL ) , "TRBZZL" , .T., .F. )
		
		dbSelectArea("TRBZZL")
		TRBZZL->(dbGoTop())
		
		DO While !TRBZZL->(Eof())
			cEmail += AllTrim(Lower(TRBZZL->ZZL_EMAIL)) + ","
			TRBZZL->(dbSkip())
		End
		
		cEmail := _cEmailDir//SubStr(cEmail,1,Len(cEmail)-1)
		
		dbSelectArea("TRBZZL")
		TRBZZL->(dbCloseArea())
		
	ENDIF
        //Para testes
        //_cdir :="c:\smartclient\"
  		//nHandle := FCreate(_cdir+"RELACAO_PC_LR.HTM")
  		//FWrite(nHandle, _cHtml )
  		//FClose(nHandle)
			
	//====================================
	// Chama a fun��o para envio do e-mail
	//====================================
	U_ITENVMAIL( "", cEmail, "", cEmail, cGetAssun, _cHtml, "", _aConfig[01], _aConfig[02], _aConfig[03], _aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )
EndIf
        
//=====================================
//Volto par�metro para seu valor padr�o
//=====================================
PutMV("MV_WFHTML",.T.)

If !Empty( _cEmlLog ) .And. !_lCriaAmb
	u_itmsg( _cEmlLog + " " + cEmail, 'T�rmino do processamento!' , ,2 )
Else
	FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "SCHEDULE"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MCOM00106"/*cMsgId*/, "MCOM00106 - T�rmino do processamento de e-mail de Pedidos Liberados: - " + _cEmlLog/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
EndIf

If _lCriaAmb

	//=============================================================
	// Limpa o ambiente, liberando a licen�a e fechando as conexoes
	//=============================================================
	RpcClearEnv()

	FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "SCHEDULE"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MCOM00107"/*cMsgId*/, "MCOM00107 - Termino do envio da lista de libera��o dos pedidos de compras da data: " + Dtoc(MV_PAR01) + " ate "+Dtoc(MV_PAR02) + " para os e-mails " + cEmail/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

EndIf

Return

/*
===============================================================================================================================
Programa----------: MCOM01Grupo
Autor-------------: ALEX WALLAUER
Data da Criacao---: 30/01/2019
Descri��o---------: Fun��o RETORNA OS APROVADORES do grupo de aprovadores
Parametros--------: Grupos
Retorno-----------: _aProv
===============================================================================================================================
*/
Static Function MCOM01Grupo(cGetGrpA)

LOCAL aGrupos:=StrToKarr(ALLTRIM(cGetGrpA), ";" ) , A
LOCAL _aProv:={}
Local _bUserN := {|x| UsrFullName(x)}

SAL->(Dbsetorder(1))
FOR A := 1 TO LEN(aGrupos)
	If SAL->(Dbseek(xfilial("SAL")+aGrupos[A]))
		Do while !(SAL->(Eof())) .and. ALLTRIM(aGrupos[A]) == SAL->AL_COD
			AADD(_aProv,{SAL->AL_NIVEL,AllTrim(Eval(_bUserN,SAL->AL_USER))})
			SAL->(Dbskip())
		Enddo
	Endif
NEXT
RETURN _aProv
