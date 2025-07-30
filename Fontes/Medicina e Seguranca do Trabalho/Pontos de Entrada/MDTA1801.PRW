/*
=========================================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO                             
=========================================================================================================================================================
Analista         - Programador    - Inicio     - Envio      - Chamado - Motivo da Alteração
---------------------------------------------------------------------------------------------------------------------------------------------------------
Alexandro       - Igor Melgaço    - 02/05/2025 - 06/05/2025 - 50525   - Ajuste para remoção de diretório local C:\SMARTCLIENT\.
=========================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include 'protheus.ch'
#include "topconn.ch"
#DEFINE ENTER CHR(13)+CHR(10)


/*
===============================================================================================================================
Programa--------: MDTA1801
Autor-----------: Alex Wallauer
Data da Criacao-: 27/10/2021
===============================================================================================================================
Descrição-------: P.E. do menudef do MDTA180.PRX - rograma de Cadastro dos riscos - CHAMADO 37981
===============================================================================================================================
Parametros------: NENHUM
===============================================================================================================================
Retorno---------: NENHUM
===============================================================================================================================
*/
USER FUNCTION MDTA1801()
LOCAL aRot:={}
aAdd( aRot , { "Carga de EPIs" , "U_MDT180Carga" , 0 , 4 } ) 

RETURN aRot
/*
===============================================================================================================================
Programa--------: U_MDT180Ca
Autor-----------: Alex Wallauer
Data da Criacao-: 27/10/2021
===============================================================================================================================
Descrição-------: P.E. do menudef do MDTA180.PRX - rograma de Cadastro dos riscos - CHAMADO 
===============================================================================================================================
Parametros------: NENHUM
===============================================================================================================================
Retorno---------: NENHUM
===============================================================================================================================
*/
USER FUNCTION MDT180Ca()//U_MDT180Ca
Local _aParRet :={} , nI 
Local _aParAux :={} 
Local _bOK     :={||.T. }

Private _cAlias1	:= GetNextAlias()


MV_PAR01:="1-Sim"
MV_PAR02:=SPACE(100)

AADD( _aParAux , { 2 , "Carga" , MV_PAR01, {"1-Risco Posicionado","2-Todos os Riscos"}   , 090 ,".T.",.T. } )
AADD( _aParAux , { 1 , "Filial", MV_PAR02, "@!"  , ""  ,"LSTFIL", "" , 100 , .F. } ) 

For nI := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nI][03] )
Next nI

DO WHILE .T.

   IF !ParamBox( _aParAux , "Digite o tipo da Carga Desejada" , @_aParRet, _bOK )
       EXIT
   EndIf
   
   cTimeInicial:=TIME()
   MV_PAR01:=ALLTRIM(MV_PAR01)
   _cLogQry:=""
   aLog := {}
   aGrava := {}
   lRet :=.T.
   SA2->(Dbsetorder(1))//
   _cTot:=""   
   FWMSGRUN( ,{|oProc|  lRet:=GeraLog(oProc) } , "Hora Inicial: "+cTimeInicial+" - Carga: "+MV_PAR01 )
    IF !lRet
       LOOP
    ENDIF
   //nHandle := FCreate("c:\smartclient\MDTA1801_"+STRTRAN(ALLTRIM(MV_PAR01),";","_")+"_"+STRTRAN(TIME(),":","_")+".TXT")
   //FWrite(nHandle, _cLogQry)
   //FClose(nHandle)
   
   IF LEN(aLog) > 0
      
      aTitCol:={}
      AADD(aTitCol,"")
      AADD(aTitCol,"TNX_FILIAL")
      AADD(aTitCol,"TNX_NUNRIS")
      AADD(aTitCol,"TNX_EPI ")
      AADD(aTitCol,"TNX_AGENTE")

      cTit1:="Log (MDTA1801) Carga: "+MV_PAR01+" / Gravados: "+_cTot
      cTit2:="Filial: "+MV_PAR01+" / Gravados: "+_cTot
      _lOK:=.F.
      bOk:=NIL//{|_oDlg| IF(_lOK:= U_ITMSG("Confirma Carga dos dados ?",'Atenção!',,2,2,2) ,_oDlg:End(), ) }
      DO WHILE .T.

         aBotoes:=NIL//{}                                           
         //AADD( aBotoes , { "" , {|| AVISO("ATENCAO",oLbxAux:aArray[oLbxAux:nAt][ nPosCarta],{"Fechar"},3) }	, "" , "Ver Carta"} )

      //                          , _aCols,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons )
         U_ITListBox(cTit1,aTitCol,aLog   ,.T.     ,4     ,cTit2   ,          ,        ,         , bOk ,        , aBotoes   )
   
         EXIT
  
      ENDDO
   
   ELSE
   
      U_ITMSG(" Nao foi encontrado dados para Filial: "+IF(!EMPTY(MV_PAR01),MV_PAR01,"Todas"),"Atencao!",,3)
   
   ENDIF

ENDDO

If Select(_cAlias1) > 0
   dbSelectArea(_cAlias1)
   (_cAlias1)->( dbCloseArea() )
EndIf

Return .T.

/*
===============================================================================================================================
Programa----------: GeraLog
Autor-------------: Alex Wallauer
Data da Criacao---: 15/10/2021
===============================================================================================================================
Descrição---------: Geração do Log de mão de obra 
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function GeraLog(OPROC)
Local _cQry:=""
Local _cAlias2	:= GetNextAlias()

IF oproc <> nil
   oproc:cCaption := "Lendo TN0... "
   ProcessMessages()
ENDIF

_cQry+= "SELECT R_E_C_N_O_ REC_TN0  "
_cQry+= "FROM "+RETSQLNAME("TN0")+"  "
_cQry+= "WHERE D_E_L_E_T_ <> '*' " 
IF MV_PAR01= "1"
   _cQry+= " AND TN0_FILIAL = '"+TN0->TN0_FILIAL+"' "
   _cQry+= " AND TN0_NUMRIS = '"+TN0->TN0_NUMRIS+"' "
ELSEIF !EMPTY(MV_PAR02)
   _cQry+= " AND TN0_FILIAL IN "+ FormatIn(MV_PAR02,";")
ENDIF
_cQry+= "ORDER BY TN0_FILIAL, TN0_NUMRIS "

_cLogQry:=_cQry+ENTER+ENTER

If Select(_cAlias1) > 0
   dbSelectArea(_cAlias1)
   (_cAlias1)->( dbCloseArea() )
EndIf

DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry), _cAlias1, .F., .T.)   
(_cAlias1)->(Dbgotop())                           

COUNT TO _nTot

_cQry1:= "SELECT R_E_C_N_O_ REC_TNF  "
_cQry1:= "SELECT DISTINCT TNF_FILIAL, TNF_CODEPI "
_cQry1+= "FROM "+RETSQLNAME("TNF")+"  "
_cQry1+= "WHERE D_E_L_E_T_ <> '*' " 
_cQry1+= " AND TNF_DTDEVO = ' ' "
_cQry3:= " ORDER BY TNF_FILIAL, TNF_CODEPI "

_cTot:=ALLTRIM(STR(_nTot))
_nTam:=LEN(_cTot)+1
nConta:=0
nGravados:=0
(_cAlias1)->(Dbgotop())     
TNX->(DBSETORDER(1))                     
DO WHILE !((_cAlias1)->(EOF()))

   nConta++
   IF oproc <> nil
	  oproc:cCaption := "Lendo TN0: "+ALLTRIM(STR(nConta,_nTam)) +" de "+ _cTot
	  ProcessMessages()
   ENDIF

   TN0->(Dbgoto((_cAlias1)->REC_TN0))

   _cQry2:= " AND TNF_FILIAL = '"+TN0->TN0_FILIAL+"' "
   _cQry2+= " AND TNF_CODFUN = '"+TN0->TN0_CODFUN+"' "

   _cLogQry+=_cQry1+_cQry2+_cQry3+ENTER+ENTER

   DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry1+_cQry2+_cQry3), _cAlias2, .F., .T.)   

   IF MV_PAR01= "1"
      _nTot2:=0
      COUNT TO _nTot2
      _cTot:=ALLTRIM(STR(_nTot2))
      _nTam:=LEN(_cTot)+1
      nConta:=0
   ENDIF
   (_cAlias2)->(Dbgotop())                           

   DO WHILE !((_cAlias2)->(EOF()))

      IF MV_PAR01= "1"
         nConta++
         IF oproc <> nil
	        oproc:cCaption := "Lendo TNF: "+ALLTRIM(STR(nConta,_nTam)) +" de "+ _cTot
	        ProcessMessages()
         ENDIF
      ENDIF
      //TNF->(Dbgoto((_cAlias2)->REC_TNF))
      IF !TNX->(DBSEEK(TN0->TN0_FILIAL+TN0->TN0_NUMRIS+(_cAlias2)->TNF_CODEPI))
          TNX->(RecLock("TNX",.T.))
          TNX->TNX_FILIAL:=TN0->TN0_FILIAL
          TNX->TNX_NUMRIS:=TN0->TN0_NUMRIS
          TNX->TNX_EPI   :=(_cAlias2)->TNF_CODEPI
          TNX->TNX_AGENTE:=TN0->TN0_AGENTE
          TNX->(MsUnLock())
          lGRAVOU:=.T.
          nGravados++
      ELSE
          lGRAVOU:=.F.
      ENDIF

      aLogAux:={}
      AADD(aLogAux,lGRAVOU          )
      AADD(aLogAux,TNX->TNX_FILIAL  )
      AADD(aLogAux,TNX->TNX_NUMRIS  )
      AADD(aLogAux,TNX->TNX_EPI     )
      AADD(aLogAux,TNX->TNX_AGENTE  )
      AADD(aLog,aLogAux)
    
      (_cAlias2)->(Dbskip())
   	
   Enddo
   (_cAlias2)->(dbCloseArea())                           

   (_cAlias1)->(Dbskip())
	
Enddo
_cTot:=ALLTRIM(STR(nGravados))
Return .T.
