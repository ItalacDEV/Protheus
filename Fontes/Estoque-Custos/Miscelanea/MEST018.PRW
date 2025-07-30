/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer |05/04/2021| Chamado 36135. Acerto da query quando só tem descontos
Lucas Borges  |07/05/2025| Chamado 50617. Corrigir chamada estática no nome das tabelas do sistema
===============================================================================================================================
Analista       - Programador     - Inicio     - Envio    - Chamado - Motivo de Alteração
===============================================================================================================================
Lucas          - Alex Wallauer   - 02/05/2025 - 06/05/25 - 50525   - Ajuste para remoção de diretório local C:\SMARTCLIENT\.
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa--------: MEST018
Autor-----------: Alex Wallauer
Data da Criacao-: 03/07/2019
Descrição-------: Log de mão de obra - Chamado 29718
Parametros------: NENHUM
Retorno---------: NENHUM
===============================================================================================================================
*/
USER FUNCTION MEST018()
LOCAL cTimeInicial:=TIME()
Local _aParRet :={}
Local _aParAux :={} , _nip , W , nI
Local _bOK     :={|| IF(MV_PAR02 >= MV_PAR01 .OR. MV_PAR02 > DATE(),.T.,(U_ITMSG("Periodo INVALIDO",'Atenção!',"Tente novamente com outro periodo ate a data de hoje",3),.F.) ) }

Private aLog := {}
Private _cFecham	:= ""
                                   	
MV_PAR01:=dDataBase
MV_PAR02:=dDataBase
MV_PAR03:=SPACE(200)
MV_PAR04:=SPACE(200)
MV_PAR05:=SPACE(200)
AADD( _aParAux , { 1 , "Data de"	      , MV_PAR01, "@D"	, ""	, ""		, "" , 050 , .F. } )
AADD( _aParAux , { 1 , "Data ate"         , MV_PAR02, "@D"	, ""	, ""		, "" , 050 , .F. } )
AADD( _aParAux , { 1 , "Filial"           , MV_PAR03, "@!"  , ""  ,"LSTFIL", "" , 100 , .F. } ) 
AADD( _aParAux , { 1 , "Conciderar CCs"   , MV_PAR04, "@!"  , ""  ,"LSTCT2", "" , 100 , .F. } ) 
AADD( _aParAux , { 1 , "Desconciderar CCs", MV_PAR05, "@!"  , ""  ,"LSTCT2", "" , 100 , .F. } ) 
For nI := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nI][03] )
Next nI

IF !ParamBox( _aParAux , "Intervalo de Datas e Filial" , @_aParRet, _bOK )
    RETURN .F.
EndIf

cTimeInicial:=TIME()
lRet:=.T.

_aFiliais:=STRTOKARR(ALLTRIM(MV_PAR03),';')
_cLogQry:=""

//=================================================================================================		
//Buscar data do ultimo fechamento  
//=================================================================================================
	_cQuery1 := " SELECT MAX(RD_DATARQ) AS ULTF FROM " + RETSQLNAME("SRD") + " SRD "
	_cQuery1 += " WHERE SRD.D_E_L_E_T_ = ' ' "
	_cQuery1 += " AND RD_FILIAL = '" + xFilial("SRD") + "'"
	_cQuery1 += " AND RD_ROTEIR = 'FOL' "
   _cquery1 := ChangeQuery(_cquery1)
   MPSysOpenQuery(_cquery1,"SRDU")

   If !(SRDU->( Eof() ))
   	  _cFecham := SRDU->ULTF
   Endif		
   
   SRDU->( DbClosearea() )

FOR _nip := 1 TO LEN(_aFiliais)

    PRIVATE _cFER:=_cEFE:=_c13S:=_cE13:=_cDC:=_cSMT:=_cEST:=_nInss:=_nAct:=_nFgts:=_nTerc:=""

	FOR W := 1 TO 3
        FWMSGRUN( ,{|oProc|  lRet:=GeraLog(oProc,_aFiliais[_nip],W,MV_PAR01,MV_PAR02) } , "Hora Inicial: "+cTimeInicial+" - Filial: "+_aFiliais[_nip]+" - "+STRZERO(_nip,2)+" de "+STRZERO(LEN(_aFiliais),2) )
    Next 

Next 
 
IF LEN(aLog) > 0
   
   aTitCol:={}
   AADD(aTitCol,"FILIAL")
   AADD(aTitCol,"TIPO VERBA")
   AADD(aTitCol,"VALOR INSS")
   AADD(aTitCol,"VALOR ACT")
   AADD(aTitCol,"RAT TERCEIROS")
   AADD(aTitCol,"FGTS     ")
   AADD(aTitCol,"FERIAS   ")
   AADD(aTitCol,"VALOR 13o")
   AADD(aTitCol,"FOLHA    ")
   AADD(aTitCol,"PROVENTOS")
   AADD(aTitCol,"DESCONTOS")
   AADD(aTitCol,"VALOR ESTAGIO")
   AADD(aTitCol,"MULTA S/ DEMISSAO")
   AADD(aTitCol,"VALOR SM")
   AADD(aTitCol,"VALOR DC")
   AADD(aTitCol,"VALOR ACD INSS")
   AADD(aTitCol,"VALOR SMT")
   aSize:=NIL
   cTit1:="Log de Mao de Obra (MEST018) Filiais: "+ALLTRIM(MV_PAR03)+" / Datas de "+DTOC(MV_PAR01)+" ate "+DTOC(MV_PAR02)+" / Quantidade de Registros: "+ALLTRIM(STR(LEN(aLog))) 
   cTit2:="Filiais: "+ALLTRIM(MV_PAR03)+" / Hr Ini: "+cTimeInicial+" Hr final "+TIME()+" / Quantidade de Registros: "+ALLTRIM(STR(LEN(aLog))) 
   U_ITListBox(cTit1,aTitCol,aLog,.T.,1,cTit2,,aSize )

ELSE

   U_ITMSG("Nao foi encontrado dados para essa selecao","Atencao!",,1)

ENDIF

Return lRet

/*
===============================================================================================================================
Programa----------: GeraLog
Autor-------------: Alex Wallauer
Data da Criacao---: 03/07/2019
Descrição---------: Geração do Log de mão de obra 
Parametros--------: oproc - objeto da barra de processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function GeraLog(OPROC,_cFil,W,_dinicial,_dfinal)
Local _nTot := 0
Local _nConta := 0 
Local _cDIncial:=ALLTRIM(STR(YEAR(_dInicial)))+STRZERO(MONTH(_dInicial),2)
Local _cDFinal :=ALLTRIM(STR(YEAR(_dFinal))) +STRZERO(MONTH(_dFinal ),2)
Local _cYESINCC:=ALLTRIM(MV_PAR04)
Local _cNOTINCC:=ALLTRIM(MV_PAR05)

IF W = 1//SÓ FAZ UMA VEZ PARA CADA FILIAL

   IF oproc <> nil
      oproc:cCaption :="Lendo Filial: "+_cFil+" - "+STR(W,1)+" / 3 - Impostos" 
      ProcessMessages()
   ENDIF

   _cFER:=U_ITGetMV("IT_FERIAS","11.107")//"11.107" //FÉRIAS	           11,107% - [Fixo]   
   _c13S:=U_ITGetMV("IT_13SALA","08.330")//"8.33"   //13º SALARIO	        8,330% - [Fixo]
   _cFER:=IF(EMPTY(_cFER),"11.107",_cFER)//"11.107" //FÉRIAS	           11,107% - [Fixo]   
   _c13S:=IF(EMPTY(_c13S),"08.330",_c13S)//"8.33"   //13º SALARIO	        8,330% - [Fixo]

   //Busca Impostos - INSS, RAT(ACT), FGTS
   _cquery := " SELECT SUBSTR(RCC_CONTEU,2,7) AS INSS, SUBSTR(RCC_CONTEU,12,6) AS ACT, SUBSTR(RCC_CONTEU,26,6) AS FGTS
   _cquery += " FROM " + RETSQLNAME("RCC") + " RCC "
   _cquery += " WHERE RCC.D_E_L_E_T_ = ' ' "
   _cquery += " AND RCC_CODIGO = 'S037' "
   _cquery += " AND SUBSTR(RCC_CONTEU,1,1) = '1'"
   _cquery += " AND SUBSTR(RCC_FIL,1,2) = '" + _cFil + "'"
   _cquery += " AND RCC_CHAVE = '"+SUBSTR(DTOS(_dInicial),1,6)+"'"

   _cquery := ChangeQuery(_cquery)
   MPSysOpenQuery(_cquery,"SRXT")

   If !(SRXT->( Eof() ))		
	  _nInss 	:= ALLTRIM(SRXT->INSS)
	  _nAct	 	:= ALLTRIM(SRXT->ACT)
	  _nFgts	:= ALLTRIM(SRXT->FGTS) 
   Else
	  _nInss:= "0"
      _nAct	:= "0"
	  _nFgts:= "0"
   Endif

   SRXT->( DbClosearea() )
   
   //Busca Impostos - TERCEIROS
   _cquery := " SELECT SUBSTR(RCC_CONTEU,7,6) AS TERC "
   _cquery += " FROM " + RETSQLNAME("RCC") + " RCC "
   _cquery += " WHERE RCC.D_E_L_E_T_ = ' ' "
   _cquery += " AND RCC_CODIGO = 'S038' "
   _cquery += " AND SUBSTR(RCC_FIL,1,2) = '" + _cFil + "'"
   _cquery += " AND (SUBSTR(RCC_CHAVE,13,6) = '"+SUBSTR(DTOS(_dInicial),1,6)+"'"
   _cquery += "      OR  RCC_CHAVE = ' ') ORDER BY RCC_CHAVE DESC "
   _cquery := ChangeQuery(_cquery)
   MPSysOpenQuery( _cquery ,"SRXV" ) 
   
   SRXV->(DBGOTOP())

   If !(SRXV->( Eof() ))
	  _nTerc:= alltrim(SRXV->TERC)
   ENDIF
   IF EMPTY(_nTerc)
	  _nTerc:= "0"
   Endif		
   
   SRXV->( DbClosearea() )

   _cEFE:=(VAL(_nInss)+VAL(_nFgts)+VAL(_nTerc)+VAL(_nAct))*(VAL(_cFER))/100 //Encargos sob Férias	
   _cE13:=(VAL(_nInss)+VAL(_nFgts)+VAL(_nTerc)+VAL(_nAct))*(VAL(_c13S))/100 //Encargos sob 13º	

   _cDC :=VAL(_nInss)+VAL(_nFgts)+VAL(_nTerc)+VAL(_nAct) //VALOR_DC - 37,22
   _cDC :=STR(_cDC,7,3) //VALOR_DC - 37,22
 
   _cSMT:=VAL(_nInss)+VAL(_cFER) +_cEFE +VAL(_nFgts)+VAL(_nTerc)+VAL(_nAct)//VALOR_SMT - 52.46336
   _cSMT:=STR(_cSMT,7,3)//VALOR_SMT - 52.46336
   
   _cEST:=VAL(_cFER) +_cEFE
   _cEST:=STR(_cEST,7,3)

ENDIF

IF oproc <> nil
   oproc:cCaption := "Lendo Filial: "+_cFil+" - "+STR(W,1)+" / 3 - Valores"  
   ProcessMessages()
ENDIF

IF _cDIncial > _cFecham .OR. _cDFinal > _cFecham
	
	_cQry := " SELECT  TMP.INSS, TMP.ACT, TMP.RAT_TERC, TMP.FGTS, TMP.FERIAS, TMP.DECIMO_TER, TMP.FOLHA, TMP.PROVENTOS, TMP.DESCONTOS, "
	_cQry += "  DECODE(TMP.VALOR_ESTAG,NULL,0,TMP.VALOR_ESTAG)             VALOR_ESTA, "
	_cQry += "  DECODE(TMP.VALOR_MULTA_DEMIS,NULL,0,TMP.VALOR_MULTA_DEMIS) MULTA_DEMI, "
	_cQry += "  DECODE(TMP.VALOR_SM,NULL,0,TMP.VALOR_SM)                   VALOR_SM,   "
	_cQry += "  DECODE(TMP.VALOR_ACD_INSS,NULL,0,TMP.VALOR_ACD_INSS)       VALORACDIN, "
	_cQry += "  DECODE(TMP.VALOR_DC,NULL,0,TMP.VALOR_DC)                   VALOR_DC,   "
	_cQry += "  DECODE(TMP.VALOR_SMT,NULL,0,TMP.VALOR_SMT)                 VALOR_SMT   "
	_cQry += " FROM (  "
	_cQry += "  SELECT "
	
	_cQry += "   		((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * ("+_nInss+")/100) as INSS,"
	_cQry += "      	((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * ("+_nAct +")/100) as ACT,"
	_cQry += "    		((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * ("+_nTerc+")/100) as RAT_TERC,"
	_cQry += "    		((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * ("+_nFgts+")/100) as FGTS,"
	
	_cQry += "    		(((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) + "
	_cQry += "   	 	(((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) * ("+_nInss+")/100) + "
	_cQry += "    		(((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) * ("+_nAct +")/100) + " 
	_cQry += "   		(((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) * ("+_nTerc+")/100) + "
	_cQry += "    		(((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) *(("+_nFgts+")/100) )) as Ferias, "
	
	_cQry += "    		(((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * (("+_c13S+")/100) ) + "
	_cQry += "    		(((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * (("+_c13S+")/100) ) * ("+_nInss+")/100) + " 
	_cQry += "   		(((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * (("+_c13S+")/100) ) * ("+_nAct +")/100) + "
	_cQry += "   		(((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * (("+_c13S+")/100) ) * ("+_nTerc+")/100) + "
	_cQry += "   		(((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * (("+_c13S+")/100) ) * ("+_nFgts+")/100))  as DECIMO_TER, "
	
	_cQry += "    		(p.proventos - (case when d.devol > 1 then d.devol else 0 end)) as Folha, "
	_cQry += "           p.proventos as proventos, d.devol as descontos, "
	
	_cQry += "   (SELECT SUM(RC_VALOR) FROM " + RETSQLNAME("SRC") + " SRC WHERE SRC.D_E_L_E_T_ = ' '  "
	_cQry += "           AND RC_FILIAL = '"+_cFil+"' AND  RC_PERIODO >= '"+_cDIncial+"' AND  RC_PERIODO <= '"+_cDFinal+"'  "
    IF !EMPTY(_cYESINCC)
	   _cQry += "           AND RC_CC IN " + FormatIn(_cYESINCC,";")
	ENDIF
    IF !EMPTY(_cNOTINCC)
	   _cQry += "           AND RC_CC NOT IN " + FormatIn(_cNOTINCC,";")
	ENDIF
	_cQry += "           AND RC_PD IN ('727','831')) AS VALOR_MULTA_DEMIS,  "
	
	_cQry += "   (SELECT ((TM.VALOR*"+_nFgts+")/100) FROM "//8.00
	_cQry += "   (SELECT SUM(RC_VALOR) VALOR FROM " + RETSQLNAME("SRC") + " SRC WHERE SRC.D_E_L_E_T_ = ' '  "
	_cQry += "           AND RC_FILIAL = '"+_cFil+"' AND RC_PERIODO >= '"+_cDIncial+"' AND  RC_PERIODO <= '"+_cDFinal+"'  "
    IF !EMPTY(_cYESINCC)
	   _cQry += "           AND RC_CC IN " + FormatIn(_cYESINCC,";")
	ENDIF
    IF !EMPTY(_cNOTINCC)
	   _cQry += "           AND RC_CC NOT IN " + FormatIn(_cNOTINCC,";")
	ENDIF
	_cQry += "           AND RC_PD IN ('097')) TM ) AS VALOR_SM, "
	
	_cQry += "   (SELECT ((TM.VALOR*"+_nFgts+")/100) FROM "//8.00
	_cQry += "   (SELECT SUM(RC_VALOR) VALOR FROM " + RETSQLNAME("SRC") + " SRC WHERE SRC.D_E_L_E_T_ = ' '  "
	_cQry += "           AND RC_FILIAL = '"+_cFil+"' AND RC_PERIODO >= '"+_cDIncial+"' AND  RC_PERIODO <= '"+_cDFinal+"'  "
    IF !EMPTY(_cYESINCC)
	   _cQry += "           AND RC_CC IN " + FormatIn(_cYESINCC,";")
	ENDIF
    IF !EMPTY(_cNOTINCC)
	   _cQry += "           AND RC_CC NOT IN " + FormatIn(_cNOTINCC,";")
	ENDIF
	_cQry += "           AND RC_PD IN ('098')) TM ) AS VALOR_ACD_INSS, "
	
	
	_cQry += "   (SELECT ((TSM.VALOR*"+_cSMT+")/100) FROM "//52.46336
	_cQry += "   (SELECT SUM(RC_VALOR) VALOR FROM " + RETSQLNAME("SRC") + " SRC WHERE SRC.D_E_L_E_T_ = ' '  "
	_cQry += "           AND RC_FILIAL = '"+_cFil+"' AND RC_PERIODO >= '"+_cDIncial+"' AND  RC_PERIODO <= '"+_cDFinal+"' "
    IF !EMPTY(_cYESINCC)
	   _cQry += "           AND RC_CC IN " + FormatIn(_cYESINCC,";")
	ENDIF
    IF !EMPTY(_cNOTINCC)
	   _cQry += "           AND RC_CC NOT IN " + FormatIn(_cNOTINCC,";")
	ENDIF
	_cQry += "           AND RC_PD IN ('121','323','361')) TSM ) AS VALOR_SMT, "
	
	_cQry += "   (SELECT TDC.VALOR+((TDC.VALOR*"+_cDC+")/100) FROM "//37,22
	_cQry += "   (SELECT SUM(RC_VALOR) VALOR FROM " + RETSQLNAME("SRC") + " SRC WHERE SRC.D_E_L_E_T_ = ' '  "
	_cQry += "           AND RC_FILIAL = '"+_cFil+"' AND RC_PERIODO >= '"+_cDIncial+"' AND  RC_PERIODO <= '"+_cDFinal+"' "
    IF !EMPTY(_cYESINCC)
	   _cQry += "           AND RC_CC IN " + FormatIn(_cYESINCC,";")
	ENDIF
    IF !EMPTY(_cNOTINCC)
	   _cQry += "           AND RC_CC NOT IN " + FormatIn(_cNOTINCC,";")
	ENDIF
	_cQry += "           AND RC_PD IN ('200','356','205')) TDC ) AS VALOR_DC, "
	
	_cQry += "   (SELECT ((TE.VALOR*"+_cEST+")/100) FROM "//15.241
	_cQry += "   (SELECT SUM(RC_VALOR) VALOR FROM " + RETSQLNAME("SRC") + " SRC WHERE SRC.D_E_L_E_T_ = ' '  "
	_cQry += "           AND RC_FILIAL = '"+_cFil+"' AND RC_PERIODO >= '"+_cDIncial+"' AND  RC_PERIODO <= '"+_cDFinal+"' "
    IF !EMPTY(_cYESINCC)
	   _cQry += "           AND RC_CC IN " + FormatIn(_cYESINCC,";")
	ENDIF
    IF !EMPTY(_cNOTINCC)
	   _cQry += "           AND RC_CC NOT IN " + FormatIn(_cNOTINCC,";")
	ENDIF
	_cQry += "           AND RC_PD IN ('192','193')) TE ) AS VALOR_ESTAG "
	_cQry += "   from ( "

	_cQry += "   SELECT SUM(RC_VALOR) AS PROVENTOS, "
	_cQry += "   				 	RC_filial  "
	_cQry += "   		from " + retsqlname("SRC") + " SRC2  join " + retsqlname("SRV") + " SRV2 on rc_filial = rv_filial and rc_pd = rv_cod "
	_cQry += "     	 WHERE RC_FILIAL = '" + _cFil + "'"
	_cQry += "     	AND	sRC2.D_E_L_E_T_ = ' ' and srv2.D_E_L_E_T_ = ' ' "

	_cQry += "   	    AND (RV_I_CUSTG = '1' OR RC_PD = '106') " 
	
	IF W = 1//query com verbas com todos os impostos
		_cQry += " 	AND RV_INSS = 'S' AND RV_FGTS = 'S' "
	ELSEIF W = 2//query com verbas sem impostos
		_cQry += " 	AND RV_INSS = 'N' AND RV_FGTS = 'N' "
	ELSEIF W = 3//query com verbas FGTS
		_cQry += " 	AND RV_INSS = 'N' AND RV_FGTS = 'S' "
	ENDIF
    IF !EMPTY(_cYESINCC)
	   _cQry += "           AND RC_CC IN " + FormatIn(_cYESINCC,";")
	ENDIF
    IF !EMPTY(_cNOTINCC)
	   _cQry += "           AND RC_CC NOT IN " + FormatIn(_cNOTINCC,";")
	ENDIF
	_cQry += "   		group by RC_filial) p "
	_cQry += "   FULL OUTER join ( "
	_cQry += "   		select sum(RC_valor) as devol, "
	_cQry += "   				RC_filial "
	_cQry += "   		from " + retsqlname("SRC") + " SRC3 join " + retsqlname("SRV") + " SRV3 on rc_filial = rv_filial and rc_pd = rv_cod "
	_cQry += "    WHERE SRC3.D_E_L_E_T_ = ' '  AND SRV3.D_E_L_E_T_ = ' ' " 
	_cQry += "     	       AND RC_FILIAL = '" + _cFil + "'"

	_cQry += "     	 	   AND (RV_I_CUSTG = '2' OR RC_PD = '403') " 

	IF W = 1//query com verbas com todos os impostos
		_cQry += "     	 	   AND RV_INSS = 'S' AND RV_FGTS = 'S' " 
	ELSEIF W = 2//query com verbas sem impostos
		_cQry += " 	   AND RV_INSS = 'N' AND RV_FGTS = 'N' " 
	ELSEIF W = 3//query com verbas FGTS
		_cQry += " 	   AND RV_INSS = 'N' AND RV_FGTS = 'S' " 
	ENDIF
    IF !EMPTY(_cYESINCC)
	   _cQry += "           AND RC_CC IN " + FormatIn(_cYESINCC,";")
	ENDIF
    IF !EMPTY(_cNOTINCC)
	   _cQry += "           AND RC_CC NOT IN " + FormatIn(_cNOTINCC,";")
	ENDIF
	_cQry += "   		GROUP BY RC_FILIAL) D "
	_cQry += "   				ON P.RC_FILIAL = D.RC_FILIAL "
	_cQry += " ) TMP "
	

ELSE //****************************************************************************************************************************************
	
	_cQry := " SELECT  TMP.INSS, TMP.ACT, TMP.RAT_TERC, TMP.FGTS, TMP.FERIAS, TMP.DECIMO_TER, TMP.FOLHA, TMP.PROVENTOS, TMP.DESCONTOS, "
	_cQry += "  DECODE(TMP.VALOR_ESTAG,NULL,0,TMP.VALOR_ESTAG)             VALOR_ESTA, "
	_cQry += "  DECODE(TMP.VALOR_MULTA_DEMIS,NULL,0,TMP.VALOR_MULTA_DEMIS) MULTA_DEMI, "
	_cQry += "  DECODE(TMP.VALOR_SM,NULL,0,TMP.VALOR_SM)                   VALOR_SM,   "
	_cQry += "  DECODE(TMP.VALOR_ACD_INSS,NULL,0,TMP.VALOR_ACD_INSS)       VALORACDIN, "
	_cQry += "  DECODE(TMP.VALOR_DC,NULL,0,TMP.VALOR_DC)                   VALOR_DC,   "
	_cQry += "  DECODE(TMP.VALOR_SMT,NULL,0,TMP.VALOR_SMT)                 VALOR_SMT   "
	_cQry += " FROM (  "
	_cQry += "  SELECT "
	_cQry += " 		((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * ("+_nInss+")/100) as INSS,"
	_cQry += " 		((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * ("+_nAct +")/100) as ACT,"
	_cQry += " 		((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * ("+_nTerc+")/100) as RAT_TERC,"
	_cQry += " 		((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * ("+_nFgts+")/100) as FGTS,"
	
	_cQry += " 		(((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) + "
	_cQry += " 		(((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) * ("+_nInss+")/100) + "
	_cQry += " 		(((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) * ("+_nAct +")/100) + " 
	_cQry += " 		(((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) * ("+_nTerc+")/100) + "
	_cQry += " 		(((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * (("+_cFER+")/100) ) *(("+_nFgts+")/100) )) as Ferias, "
	
	_cQry += " 		(((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * (("+_c13S+")/100) ) + "
	_cQry += " 		(((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * (("+_c13S+")/100) ) * ("+_nInss+")/100) + " 
	_cQry += " 		(((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * (("+_c13S+")/100) ) * ("+_nAct +")/100) + "
	_cQry += " 		(((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * (("+_c13S+")/100) ) * ("+_nTerc+")/100) + "
	_cQry += " 		(((p.proventos - (case when d.devol > 1 then d.devol else 0 end)) * (("+_c13S+")/100) ) * ("+_nFgts+")/100))  as DECIMO_TER, "
	
	_cQry += "  		(p.proventos - (case when d.devol > 1 then d.devol else 0 end)) as Folha, "
	_cQry += "      p.proventos as proventos, d.devol as descontos, "
	
	_cQry += " (SELECT SUM(RD_VALOR) FROM " + RETSQLNAME("SRD") + " SRD WHERE SRD.D_E_L_E_T_ = ' '  "
	_cQry += "         AND RD_FILIAL = '"+_cFil+"' AND  RD_DATARQ >= '"+_cDIncial+"' AND  RD_DATARQ <= '"+_cDFinal+"' "
    IF !EMPTY(_cYESINCC)
	   _cQry += "           AND RD_CC IN " + FormatIn(_cYESINCC,";")
	ENDIF
    IF !EMPTY(_cNOTINCC)
	   _cQry += "           AND RD_CC NOT IN " + FormatIn(_cNOTINCC,";")
	ENDIF
	_cQry += "         AND RD_PD IN ('727','831')) AS VALOR_MULTA_DEMIS,  "
	
	_cQry += " (SELECT ((TM.VALOR*"+_nFgts+")/100) FROM  "//8.00
	_cQry += " (SELECT SUM(RD_VALOR) VALOR FROM " + RETSQLNAME("SRD") + " SRD WHERE SRD.D_E_L_E_T_ = ' '  "
	_cQry += "         AND RD_FILIAL = '"+_cFil+"' AND RD_DATARQ >= '"+_cDIncial+"' AND  RD_DATARQ <= '"+_cDFinal+"'  "
    IF !EMPTY(_cYESINCC)
	   _cQry += "           AND RD_CC IN " + FormatIn(_cYESINCC,";")
	ENDIF
    IF !EMPTY(_cNOTINCC)
	   _cQry += "           AND RD_CC NOT IN " + FormatIn(_cNOTINCC,";")
	ENDIF
	_cQry += "         AND RD_PD IN ('97')) TM ) AS VALOR_SM, "
	
	_cQry += " 	 (SELECT ((TM.VALOR*"+_nFgts+")/100) FROM "//8.00
	_cQry += " 	 (SELECT SUM(RD_VALOR) VALOR FROM " + RETSQLNAME("SRD") + " SRD WHERE SRD.D_E_L_E_T_ = ' '  "
	_cQry += " 	         AND RD_FILIAL = '"+_cFil+"' AND RD_DATARQ >= '"+_cDIncial+"' AND  RD_DATARQ <= '"+_cDFinal+"'  "
    IF !EMPTY(_cYESINCC)
	   _cQry += "           AND RD_CC IN " + FormatIn(_cYESINCC,";")
	ENDIF
    IF !EMPTY(_cNOTINCC)
	   _cQry += "           AND RD_CC NOT IN " + FormatIn(_cNOTINCC,";")
	ENDIF
	_cQry += " 	         AND RD_PD IN ('098')) TM ) AS VALOR_ACD_INSS, "
	
	_cQry += " (SELECT ((TSM.VALOR*"+_cSMT+")/100) FROM "// 49.036
	_cQry += " (SELECT SUM(RD_VALOR) VALOR FROM " + RETSQLNAME("SRD") + " SRD WHERE SRD.D_E_L_E_T_ = ' '  "
	_cQry += "         AND RD_FILIAL = '"+_cFil+"' AND RD_DATARQ >= '"+_cDIncial+"' AND  RD_DATARQ <= '"+_cDFinal+"' "
    IF !EMPTY(_cYESINCC)
	   _cQry += "           AND RD_CC IN " + FormatIn(_cYESINCC,";")
	ENDIF
    IF !EMPTY(_cNOTINCC)
	   _cQry += "           AND RD_CC NOT IN " + FormatIn(_cNOTINCC,";")
	ENDIF
	_cQry += "         AND RD_PD IN ('121','323','361')) TSM ) AS VALOR_SMT, "
	
	_cQry += " (SELECT TDC.VALOR+((TDC.VALOR*"+_cDC+")/100) FROM "// 37.925
	_cQry += " (SELECT SUM(RD_VALOR) VALOR FROM " + RETSQLNAME("SRD") + " SRD WHERE SRD.D_E_L_E_T_ = ' '  "
	_cQry += "         AND RD_FILIAL = '"+_cFil+"' AND RD_DATARQ >= '"+_cDIncial+"' AND  RD_DATARQ <= '"+_cDFinal+"' "
    IF !EMPTY(_cYESINCC)
	   _cQry += "           AND RD_CC IN " + FormatIn(_cYESINCC,";")
	ENDIF
    IF !EMPTY(_cNOTINCC)
	   _cQry += "           AND RD_CC NOT IN " + FormatIn(_cNOTINCC,";")
	ENDIF
	_cQry += "         AND RD_PD IN ('200','356','205')) TDC ) AS VALOR_DC, "
	
	_cQry += " (SELECT ((TE.VALOR*"+_cEST+")/100) FROM  "// 11.111
	_cQry += " (SELECT SUM(RD_VALOR) VALOR FROM " + RETSQLNAME("SRD") + " SRD WHERE SRD.D_E_L_E_T_ = ' '  "
	_cQry += "         AND RD_FILIAL = '"+_cFil+"' AND RD_DATARQ >= '"+_cDIncial+"' AND  RD_DATARQ <= '"+_cDFinal+"' "
    IF !EMPTY(_cYESINCC)
	   _cQry += "           AND RD_CC IN " + FormatIn(_cYESINCC,";")
	ENDIF
    IF !EMPTY(_cNOTINCC)
	   _cQry += "           AND RD_CC NOT IN " + FormatIn(_cNOTINCC,";")
	ENDIF
	_cQry += "         AND RD_PD IN ('192','193')) TE ) AS VALOR_ESTAG "
	_cQry += " from ( "
	_cQry += "   	select 	sum(RD_valor) as proventos, "
	_cQry += " 				 	RD_filial  "
	_cQry += " 		from " + RETSQLNAME("SRD") + " SRD2  JOIN "+RETSQLNAME("SRV")+" SRV2 on rd_filial = rv_filial and rd_pd = rv_cod "
	_cQry += " WHERE RD_FILIAL = '"+_cFil+"' "
	_cQry += " 		and	rd_datarq >= '"+_cDIncial+"' AND  RD_DATARQ <= '"+_cDFinal+"' and "
	_cQry += "   		sRD2.D_E_L_E_T_ = ' ' and srv2.D_E_L_E_T_ = ' ' "
	_cQry += " 		AND RV_I_CUSTG = '1'  "
	//_cQry += " 	AND RV_INSS = 'S' AND RV_FGTS = 'S' "
	IF W = 1//query com verbas com todos os impostos
		_cQry	+= " 	AND RV_INSS = 'S' AND RV_FGTS = 'S' "
	ELSEIF W = 2//query com verbas sem impostos
		_cQry	+= " 	AND RV_INSS = 'N' AND RV_FGTS = 'N' "
	ELSEIF W = 3//query com verbas FGTS
		_cQry	+= " 	AND RV_INSS = 'N' AND RV_FGTS = 'S' "
	ENDIF
    IF !EMPTY(_cYESINCC)
	   _cQry += "           AND RD_CC IN " + FormatIn(_cYESINCC,";")
	ENDIF
    IF !EMPTY(_cNOTINCC)
	   _cQry += "           AND RD_CC NOT IN " + FormatIn(_cNOTINCC,";")
	ENDIF
	_cQry += " 		GROUP BY RD_FILIAL) P "
	_cQry += " FULL OUTER JOIN ( "
	_cQry += " 		SELECT SUM(RD_VALOR) AS DEVOL, "
	_cQry += " 				RD_filial "
	_cQry += " 		FROM " + RETSQLNAME("SRD") + " SRD3 JOIN "+RETSQLNAME("SRV")+" SRV3 ON RD_FILIAL = RV_FILIAL AND RD_PD = RV_COD "
	_cQry += " 		WHERE 	SRD3.D_E_L_E_T_ = ' '  AND SRV3.D_E_L_E_T_ = ' ' AND  "
	_cQry += "  RD_FILIAL = '"+_cFil+"' "
	_cQry += " 	and rd_datarq >= '"+_cDIncial+"' and rd_datarq <= '"+_cDFinal+"' "
	_cQry += " 	AND RV_I_CUSTG = '2' "
	//_cQry += " 	AND RV_INSS = 'S' AND RV_FGTS = 'S' "
	IF W = 1//query com verbas com todos os impostos
		_cQry	+= " 	AND RV_INSS = 'S' AND RV_FGTS = 'S' "
	ELSEIF W = 2//query com verbas sem impostos
		_cQry	+= " 	AND RV_INSS = 'N' AND RV_FGTS = 'N' "
	ELSEIF W = 3//query com verbas FGTS
		_cQry	+= " 	AND RV_INSS = 'N' AND RV_FGTS = 'S' "
	ENDIF
    IF !EMPTY(_cYESINCC)
	   _cQry += "           AND RD_CC IN " + FormatIn(_cYESINCC,";")
	ENDIF
    IF !EMPTY(_cNOTINCC)
	   _cQry += "           AND RD_CC NOT IN " + FormatIn(_cNOTINCC,";")
	ENDIF
	_cQry += " 		GROUP BY RD_FILIAL) D ON P.RD_FILIAL = D.RD_FILIAL "
	_cQry += " ) TMP "

ENDIF

If Select("MAO") > 0
   MAO->(DbCloseArea())
EndIf

_cLogQry+="*** LENDO FILIAL: "+_cFil+" - QUERY: "+STR(W,1)+" / 3 **************************************************************** "+CRLF+CRLF
_cLogQry+=_cQry+CRLF+CRLF+CRLF

_cQry := ChangeQuery(_cQry)
MPSysOpenQuery(_cQry,"MAO")

DBSelectArea("MAO")
COUNT TO _nTot
_cTotReg:=ALLTRIM(STR( _nTot ))
	
MAO->(Dbgotop())                           

DO WHILE !(MAO->(EOF()))

   _nConta++
   IF oproc <> nil
	  oproc:cCaption := "Gerando Filial "+_cFil+" - "+ ALLTRIM(STR(_nConta)) + " de " + _cTotReg+" - Valores"
	  ProcessMessages()
   ENDIF
   aLogAux:={}
   AADD(aLogAux,_cFil)
   IF W	 = 1                                      // COM VERBAS COM TODOS OS IMPOSTOS
      AADD(aLogAux,"VERBAS COM TODOS OS IMPOSTOS")// RV_INSS = 'S' AND RV_FGTS = 'S' "  
   ELSEIF W	 = 2                                  // COM VERBAS SEM IMPOSTOS
      AADD(aLogAux,"VERBAS SEM IMPOSTOS")         // RV_INSS = 'N' AND RV_FGTS = 'N' "  
   ELSEIF W	 = 3                                  // COM VERBAS FGTS
      AADD(aLogAux,"COM VERBAS FGTS")             // RV_INSS = 'N' AND RV_FGTS = 'S' "  
   ENDIF
   
   AADD(aLogAux,TRANS(MAO->INSS      ,"@E 99,999,999,999.99"))
   AADD(aLogAux,TRANS(MAO->ACT       ,"@E 99,999,999,999.99"))
   AADD(aLogAux,TRANS(MAO->RAT_TERC  ,"@E 99,999,999,999.99"))
   AADD(aLogAux,TRANS(MAO->FGTS      ,"@E 99,999,999,999.99"))
   AADD(aLogAux,TRANS(MAO->FERIAS    ,"@E 99,999,999,999.99"))
   AADD(aLogAux,TRANS(MAO->DECIMO_TER,"@E 99,999,999,999.99"))
   AADD(aLogAux,TRANS(MAO->FOLHA     ,"@E 99,999,999,999.99"))
   AADD(aLogAux,TRANS(MAO->PROVENTOS ,"@E 99,999,999,999.99"))
   AADD(aLogAux,TRANS(MAO->DESCONTOS ,"@E 99,999,999,999.99"))
   AADD(aLogAux,TRANS(MAO->VALOR_ESTA,"@E 99,999,999,999.99"))
   AADD(aLogAux,TRANS(MAO->MULTA_DEMI,"@E 99,999,999,999.99"))
   AADD(aLogAux,TRANS(MAO->VALOR_SM  ,"@E 99,999,999,999.99"))
   AADD(aLogAux,TRANS(MAO->VALOR_DC  ,"@E 99,999,999,999.99"))
   AADD(aLogAux,TRANS(MAO->VALORACDIN,"@E 99,999,999,999.99"))
   AADD(aLogAux,TRANS(MAO->VALOR_SMT ,"@E 99,999,999,999.99"))

   AADD(aLog,aLogAux)
   
   MAO->(Dbskip())
	
Enddo

IF W = 3//SÓ FAZ UMA VEZ PARA CADA FILIAL

   IF oproc <> nil
      oproc:cCaption := "Lendo Filial: "+_cFil+" - "+STR(W,1)+" / 3 - Verbas"  
      ProcessMessages()
   ENDIF

   IF _cDIncial > _cFecham .OR. _cDFinal > _cFecham
      _cQry := "SELECT RC_PD VERBA, SUM(RC_VALOR) PROVENTOS, RV_INSS INSS, RV_FGTS FGTS, RV_DESC DESCICAO "
      _cQry += "       FROM "+RETSQLNAME("SRC")+" SRC2  "
      _cQry += "       JOIN "+RETSQLNAME("SRV")+" SRV2 ON RC_FILIAL = RV_FILIAL AND RC_PD = RV_COD "
      _cQry += "       WHERE RC_FILIAL = '"+_cFil+"' "
      _cQry += " 	      AND RC_PERIODO >= '"+_cDIncial+"' AND RC_PERIODO <= '"+_cDFinal+"' "
       IF !EMPTY(_cYESINCC)
   	   _cQry += "           AND RC_CC IN " + FormatIn(_cYESINCC,";")
   	ENDIF
      IF !EMPTY(_cNOTINCC)
   	  _cQry += "     AND RC_CC NOT IN " + FormatIn(_cNOTINCC,";")
      ENDIF
      _cQry += "         AND SRC2.D_E_L_E_T_ = ' ' AND SRV2.D_E_L_E_T_ = ' ' "
      _cQry += "       	 AND (RV_I_CUSTG = '1' OR RC_PD = '106') "
      _cQry += "GROUP BY RC_PD, RV_INSS, RV_FGTS, RV_DESC "
      _cQry += "ORDER BY RC_PD "
   ELSE
      _cQry := "SELECT RD_PD VERBA, SUM(RD_VALOR) PROVENTOS, RV_INSS INSS, RV_FGTS FGTS, RV_DESC DESCICAO "
      _cQry += "       FROM "+RETSQLNAME("SRD")+" SRD2  "
      _cQry += "       JOIN "+RETSQLNAME("SRV")+" SRV2 ON RD_FILIAL = RV_FILIAL AND RD_PD = RV_COD "
      _cQry += "       WHERE RD_FILIAL = '"+_cFil+"' "
      _cQry += " 	      AND RD_DATARQ >= '"+_cDIncial+"' AND RD_DATARQ <= '"+_cDFinal+"' "
       IF !EMPTY(_cYESINCC)
   	   _cQry += "           AND RD_CC IN " + FormatIn(_cYESINCC,";")
   	ENDIF
      IF !EMPTY(_cNOTINCC)
   	  _cQry += "     AND RD_CC NOT IN " + FormatIn(_cNOTINCC,";")
      ENDIF
      _cQry += "         AND SRD2.D_E_L_E_T_ = ' ' AND SRV2.D_E_L_E_T_ = ' ' "
      _cQry += "       	 AND RV_I_CUSTG = '1'  "
      _cQry += "GROUP BY RD_PD, RV_INSS, RV_FGTS, RV_DESC "
      _cQry += "ORDER BY RD_PD "
   ENDIF

   If Select("MAO") > 0
      MAO->(DbCloseArea())
   EndIf
   _cQry := ChangeQuery(_cQry)

   MPSysOpenQuery(_cQry,"MAO")

   _cLogQry+="*** LENDO FILIAL: "+_cFil+" Verbas 1 - QUERY: "+STR(W,1)+" / 3 **************************************************************** "+CRLF+CRLF
   _cLogQry+=_cQry+CRLF+CRLF+CRLF
   
   DBSelectArea("MAO")
   COUNT TO _nTot
   _cTotReg:=ALLTRIM(STR( _nTot ))
   	
   MAO->(Dbgotop())                           
   
   DO WHILE !(MAO->(EOF()))
   
      _nConta++
      IF oproc <> nil
   	  oproc:cCaption := "Gerando Filial "+_cFil+" - "+ ALLTRIM(STR(_nConta)) + " de " + _cTotReg+" - Verbas"
   	  ProcessMessages()
      ENDIF
      aLogAux:={}
      AADD(aLogAux,_cFil)
      AADD(aLogAux,MAO->VERBA+" - "+MAO->DESCICAO)  
      AADD(aLogAux,MAO->INSS)
      AADD(aLogAux,"")
      AADD(aLogAux,"")
      AADD(aLogAux,MAO->FGTS)
      AADD(aLogAux,"")
      AADD(aLogAux,"")
      AADD(aLogAux,"")
      AADD(aLogAux,TRANS(MAO->PROVENTOS ,"@E 99,999,999,999.99"))
      AADD(aLogAux,"")
      AADD(aLogAux,"")
      AADD(aLogAux,"")
      AADD(aLogAux,"")
      AADD(aLogAux,"")
      AADD(aLogAux,"")
      AADD(aLogAux,"")

      AADD(aLog,aLogAux)
      
      MAO->(Dbskip())
   	
   Enddo

   IF _cDIncial > _cFecham .OR. _cDFinal > _cFecham
      _cQry := "SELECT RC_PD VERBA, SUM(RC_VALOR) DESCONTOS, RV_INSS INSS, RV_FGTS FGTS, RV_DESC DESCICAO "
      _cQry += "       FROM "+RETSQLNAME("SRC")+" SRC2  "
      _cQry += "       JOIN "+RETSQLNAME("SRV")+" SRV2 ON RC_FILIAL = RV_FILIAL AND RC_PD = RV_COD "
      _cQry += "       WHERE RC_FILIAL = '"+_cFil+"' "
      _cQry += " 	      AND RC_PERIODO >= '"+_cDIncial+"' AND RC_PERIODO <= '"+_cDFinal+"' "
      _cQry += "         AND SRC2.D_E_L_E_T_ = ' ' AND SRV2.D_E_L_E_T_ = ' ' "
      _cQry += "         AND (RV_I_CUSTG = '2' OR RC_PD = '403') "
       IF !EMPTY(_cYESINCC)
   	   _cQry += "           AND RC_CC IN " + FormatIn(_cYESINCC,";")
   	ENDIF
      IF !EMPTY(_cNOTINCC)
         _cQry += "     AND RC_CC NOT IN " + FormatIn(_cNOTINCC,";")
      ENDIF
      _cQry += "GROUP BY RC_PD, RV_INSS, RV_FGTS, RV_DESC "
      _cQry += "ORDER BY RC_PD "
   ELSE
      _cQry := "SELECT RD_PD VERBA, SUM(RD_VALOR) DESCONTOS, RV_INSS INSS, RV_FGTS FGTS, RV_DESC DESCICAO "
      _cQry += "       FROM "+RETSQLNAME("SRD")+" SRD2  "
      _cQry += "       JOIN "+RETSQLNAME("SRV")+" SRV2 ON RD_FILIAL = RV_FILIAL AND RD_PD = RV_COD "
      _cQry += "       WHERE RD_FILIAL = '"+_cFil+"' "
      _cQry += " 	      AND RD_DATARQ >= '"+_cDIncial+"' AND RD_DATARQ <= '"+_cDFinal+"' "
      _cQry += "         AND SRD2.D_E_L_E_T_ = ' ' AND SRV2.D_E_L_E_T_ = ' ' "
      _cQry += "         AND RV_I_CUSTG = '2'  "
       IF !EMPTY(_cYESINCC)
   	   _cQry += "           AND RD_CC IN " + FormatIn(_cYESINCC,";")
   	ENDIF
      IF !EMPTY(_cNOTINCC)
   	  _cQry += "     AND RD_CC NOT IN " + FormatIn(_cNOTINCC,";")
      ENDIF
      _cQry += "GROUP BY RD_PD, RV_INSS, RV_FGTS, RV_DESC "
      _cQry += "ORDER BY RD_PD "
   ENDIF

   If Select("MAO") > 0
      MAO->(DbCloseArea())
   EndIf
   _cQry := ChangeQuery(_cQry)

   MPSysOpenQuery(_cQry,"MAO")

   _cLogQry+="*** LENDO FILIAL: "+_cFil+" Verbas 2 - QUERY: "+STR(W,1)+" / 3 **************************************************************** "+CRLF+CRLF
   _cLogQry+=_cQry+CRLF+CRLF+CRLF
   
   DBSelectArea("MAO")
   COUNT TO _nTot
   _cTotReg:=ALLTRIM(STR( _nTot ))
   	
   MAO->(Dbgotop())                           
   
   DO WHILE !(MAO->(EOF()))
   
      _nConta++
      IF oproc <> nil
   	  oproc:cCaption := "Gerando Filial "+_cFil+" - "+ ALLTRIM(STR(_nConta)) + " de " + _cTotReg+" - Verbas"
   	  ProcessMessages()
      ENDIF
      aLogAux:={}
      AADD(aLogAux,_cFil)
      AADD(aLogAux,MAO->VERBA+" - "+MAO->DESCICAO)  
      AADD(aLogAux,MAO->INSS)
      AADD(aLogAux,"")
      AADD(aLogAux,"")
      AADD(aLogAux,MAO->FGTS)
      AADD(aLogAux,"")
      AADD(aLogAux,"")
      AADD(aLogAux,"")
      AADD(aLogAux,"")
      AADD(aLogAux,TRANS(MAO->DESCONTOS ,"@E 99,999,999,999.99"))
      AADD(aLogAux,"")
      AADD(aLogAux,"")
      AADD(aLogAux,"")
      AADD(aLogAux,"")
      AADD(aLogAux,"")
      AADD(aLogAux,"")

      AADD(aLog,aLogAux)
      
      MAO->(Dbskip())
   	
   Enddo

ENDIF


Return .T.
