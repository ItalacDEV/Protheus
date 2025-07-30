/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço  |12/03/2024| Chamado 45575 - Ajuste para conversão de texto do Assunto do email em padrao UTF8.
Lucas Borges  |09/10/2024| Chamado 48465. Retirada da função de conout
Lucas Borges  |23/07/2025| Chamado 51340. Ajustar função para validação de ambiente de teste
=====================================================================================================================================
*/ 

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE "Protheus.ch"
#Include "TopConn.ch" 

#DEFINE _ENTER CHR(13)+CHR(10)

/*
===============================================================================================================================
Programa----------: MOMS058
Autor-------------: Julio de Paula Paz
Data da Criacao---: 31/03/2021
Descrição---------: Verifica e bloqueia o vendedores que não faturam a 90 dias (definido em parâmetro), e envia e-mail com 
                    a lista dos vendedores bloqueados para a equipe que trata comissão. Chamado 35963.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS058(_lLScheduler)
Local lWFHTML		:= .T.
Local _cQry, _cPeriodo, _nDias, E
Local _nTotRegs, _aDados := {}
DEFAULT _lLScheduler:= FWGetRunSchedule()

Private _cHostWF	 := ""
Private _dDtIni	 := ""
Private cLogo		 := ""
Private _lScheduler:= _lLScheduler
Private _lAmbTeste := !_lScheduler .AND. SuperGetMV("IT_AMBTEST",.F.,.T.)

Begin Sequence

   _nDias      := U_ItGetMv("IT_DIASNAOF",90)
   _cPeriodo   := Dtos(Date()- _nDias)
   _cHostWF    := U_ItGetMv("IT_WFHOSTS","http://wfteste.italac.com.br:4034/") 
   cLogo	      := _cHostWF + "htm/logo_novo.jpg"
   _cMV_WFMLBOX:= AllTrim(GetMV('MV_WFMLBOX'))
   lWFHTML	   := GetMv("MV_WFHTML")

   PutMV("MV_WFHTML",.T.)

   _cQry := " SELECT SA3.R_E_C_N_O_ AS NRRECNO "
   _cQry += " FROM " + RetSqlName("SA3") + " SA3 "
   _cQry += " WHERE SA3.D_E_L_E_T_ = ' ' "
   _cQry += "  AND A3_I_VBROK <> 'C' "
   _cQry += "  AND A3_I_TIPV = 'V' "
   _cQry += "  AND A3_MSBLQL <> '1' " // 1=Inativo;2=Ativo
   _cQry += "  AND A3_I_DTINI < '" + _cPeriodo + "' "
   _cQry += "  AND NOT EXISTS (SELECT F2_VEND1 FROM " + RetSqlName("SF2") + " SF2  "
   _cQry += "                  WHERE SF2.D_E_L_E_T_ = ' ' "
   _cQry += "                  AND F2_EMISSAO >= '" + _cPeriodo + "' "
   _cQry += "                  AND F2_TIPO = 'N' "
   _cQry += "                  AND SF2.F2_VEND1 = SA3.A3_COD ) "  
   _cQry += "  AND NOT EXISTS (SELECT C5_VEND1 FROM " + RetSqlName("SC5") + " SC5  "
   _cQry += "                  WHERE SC5.D_E_L_E_T_ = ' ' "
   _cQry += "                  AND C5_EMISSAO  >= '" + _cPeriodo + "' "
   _cQry += "                  AND C5_TIPO = 'N' "
   _cQry += "                  AND SC5.C5_VEND1 = SA3.A3_COD ) "  

  
   If Select("TRBSA3") <> 0
	  TRBSA3->(DBCloseArea())
   EndIf

   DbUseArea(.T., "TOPCONN", TcGenQry(,,_cQry), "TRBSA3", .T., .F.)
   


   Count To _nTotRegs

   If _nTotRegs == 0
      IF !_lScheduler
         U_ITMSG("Nao há registros",'Atenção!',,3)
      ENDIF
      Break
   EndIf

   TRBSA3->(DbGoTop())
   _aDadosMarca:={}
   Do While !TRBSA3->(Eof())
      
      SA3->(DBGOTO(TRBSA3->NRRECNO))
      _cDtUltPV:= ""
      _cDtUltimoFat := U_MOMS058U(SA3->A3_COD)

      _cA3_I_SUPE:=SA3->A3_I_SUPE
      _cA3_SUPER :=SA3->A3_SUPER 
      _cA3_GEREN :=SA3->A3_GEREN 

      _aVends:={}
      AADD(_aVends,SA3->A3_COD+" - "+SA3->A3_NOME)    //01
      AADD(_aVends,_cDtUltimoFat)                     //02
      AADD(_aVends,_cDtUltPV)                         //03
      AADD(_aVends,SA3->A3_I_DTINI)                   //04
      AADD(_aVends,_cA3_I_SUPE+" - "+ALLTRIM( POSICIONE('SA3',1,xFilial('SA3')+_cA3_I_SUPE,'A3_NOME') )) //05
      AADD(_aVends,_cA3_SUPER +" - "+ALLTRIM( POSICIONE('SA3',1,xFilial('SA3')+_cA3_SUPER ,'A3_NOME') )) //06
      AADD(_aVends,_cA3_GEREN +" - "+ALLTRIM( POSICIONE('SA3',1,xFilial('SA3')+_cA3_GEREN ,'A3_NOME') )) //07
      AADD(_aVends,ALLTRIM( POSICIONE('SA3',1,xFilial('SA3')+_cA3_I_SUPE,'A3_EMAIL') )) //08
      AADD(_aVends,ALLTRIM( POSICIONE('SA3',1,xFilial('SA3')+_cA3_SUPER ,'A3_EMAIL') )) //09
      AADD(_aVends,ALLTRIM( POSICIONE('SA3',1,xFilial('SA3')+_cA3_GEREN ,'A3_EMAIL') )) //10
      SA3->(DBGOTO(TRBSA3->NRRECNO))//reposiciona no SA3 do vendedor
      AADD(_aVends,SA3->A3_FORNECE+" - "+SA3->A3_LOJA+" - "+ALLTRIM( POSICIONE('SA2',1,xFilial('SA2')+SA3->A3_FORNECE+SA3->A3_LOJA,'A2_NREDUZ') )) //11
      AADD(_aVends,TRBSA3->NRRECNO)                   //12

      Aadd(_aDados,_aVends)
      _aVends2:=ACLONE(_aVends)
      ASIZE(_aVends2,LEN(_aVends2)+1)
      AINS(_aVends2,1)
      _aVends2[1]:=.F.
      Aadd(_aDadosMarca,_aVends2)
	
	   TRBSA3->(dbSkip())
   EndDo

   If Len(_aDados) > 0
      
      ASORT(_aDados, , , { | x,y | x[1] < y[1] } )

      If _lAmbTeste
         ASORT(_aDadosMarca, , , { | x,y | x[2] < y[2] } )

         aCab:={}
		   AADD(aCab,"")//01
		   AADD(aCab,"Vendedor")//02
		   AADD(aCab,"Ultimo Faturamento")//03
		   AADD(aCab,"Ultimo PV")//04
		   AADD(aCab,"Data de Inicio")//05
		   AADD(aCab,"Supervisor")//06
		   AADD(aCab,"Coordenador")//07
		   AADD(aCab,"Gerente")//08
		   AADD(aCab,"E-Mail Supervisor")//09
		   AADD(aCab,"E-Mail Coordenador")//10
		   AADD(aCab,"E-Mail Gerente")//11
		   AADD(aCab,"Fornecedor correspondente")//12
		   AADD(aCab,"No. Registro")//13
         
         _cTitulo:='WORKFLOW VENDEDORES BLOQUEADOS POR FICAREM MAIS DE 90 DIAS SEM FATURAR.'
         _cMsgTop:="Os vendedores a seguir foram bloqueados automaticamente pelo sistema,por ficarem mais de 90 dias sem faturar.""
                                 //, _aCols,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons )
         IF !U_ITListBox(_cTitulo,aCab,_aDadosMarca, .T.    , 2    ,_cMsgTop,          ,        ,         ,     ,        , )
            RETURN .F.
         ENDIF
      ENDIF

//******** E-MAILS DO PARAMETRO: IT_DEPCOMIS *****************************************************************

      U_MOMS058E(_aDados, , ,"Parametro: IT_DEPCOMIS")//TODOS

      // E-mails dos SUPERVISORES **************************************************************************
      ASORT(_aDados     , , , { | x,y | x[5] < y[5] } )
      ASORT(_aDadosMarca, , , { | x,y | x[6] < y[6] } )

      _aDadosAux:={}
      _cCodSA3:=_aDados[1,5]//Codigo
      _cEmaSA3:=_aDados[1,8]//E-mail
      FOR E := 1 TO LEN(_aDados)

         If _lAmbTeste .AND. !_aDadosMarca[E,1]//_aDadosMarca e _aDadosEnv TEM AS MESMAS QTDES DE REGISTROS SEMPRE
            LOOP
         ENDIF

         IF _cCodSA3 <> _aDados[E,5] 
            
            IF !EMPTY(_cEmaSA3) .AND. LEN(_aDadosAux) > 0
               U_MOMS058E(_aDadosAux,_cEmaSA3,.T.,"Supervisor: "+_cCodSA3)
            ENDIF
            _aDadosAux:={}
            _cCodSA3:=_aDados[E,5]
            _cEmaSA3:=_aDados[E,8]
         ENDIF

         AADD(_aDadosAux, ACLONE(_aDados[E]) )

      NEXT
      IF !EMPTY(_cEmaSA3)  .AND. LEN(_aDadosAux) > 0
          U_MOMS058E(_aDadosAux,_cEmaSA3,.T.,"Supervisor: "+_cCodSA3)
      ENDIF

//******** E-MAAILS DOS COORDENADORES ******************************************************************************
      ASORT(_aDados     , , , { | x,y | x[6] < y[6] } )
      ASORT(_aDadosMarca, , , { | x,y | x[7] < y[7] } )

      _aDadosAux:={}
      _cCodSA3:=_aDados[1,6]//Codigo
      _cEmaSA3:=_aDados[1,9]//E-mail
      FOR E := 1 TO LEN(_aDados)
         
         If _lAmbTeste .AND. !_aDadosMarca[E,1]//_aDadosMarca e _aDadosEnv TEM AS MESMAS QTDES DE REGISTROS SEMPRE
            LOOP
         ENDIF

         IF _cCodSA3 <> _aDados[E,6] 
            
            IF !EMPTY(_cEmaSA3) .AND. LEN(_aDadosAux) > 0
               U_MOMS058E(_aDadosAux,_cEmaSA3,.T.,"Coordenador: "+_cCodSA3)
            ENDIF
            _aDadosAux:={}
            _cCodSA3:=_aDados[E,6]
            _cEmaSA3:=_aDados[E,9]
         ENDIF

         AADD(_aDadosAux, ACLONE(_aDados[E]) )

      NEXT
      IF !EMPTY(_cEmaSA3) .AND. LEN(_aDadosAux) > 0
          U_MOMS058E(_aDadosAux,_cEmaSA3,.T.,"Coordenador: "+_cCodSA3)
      ENDIF

//******** E-MAILS DOS GERENTES *******************************************************************************
      ASORT(_aDados     , , , { | x,y | x[7] < y[7] } )
      ASORT(_aDadosMarca, , , { | x,y | x[8] < y[8] } )

      _aDadosAux:={}
      _cCodSA3:=_aDados[1,07]//Codigo
      _cEmaSA3:=_aDados[1,10]//E-mail
      FOR E := 1 TO LEN(_aDados)
         
         If _lAmbTeste .AND. !_aDadosMarca[E,1]//_aDadosMarca e _aDadosEnv TEM AS MESMAS QTDES DE REGISTROS SEMPRE
            LOOP
         ENDIF

         IF _cCodSA3 <> _aDados[E,7] 
            
            IF !EMPTY(_cEmaSA3) .AND. LEN(_aDadosAux) > 0
               U_MOMS058E(_aDadosAux,_cEmaSA3,.T.,"Gerente: "+_cCodSA3)
            ENDIF
            _aDadosAux:={}
            _cCodSA3:=_aDados[E,07]
            _cEmaSA3:=_aDados[E,10]
         ENDIF

         AADD(_aDadosAux, ACLONE(_aDados[E]) )

      NEXT
      IF !EMPTY(_cEmaSA3) .AND. LEN(_aDadosAux) > 0
          U_MOMS058E(_aDadosAux,_cEmaSA3,.T.,"Gerente: "+_cCodSA3)
      ENDIF

   ELSEIF !_lScheduler
      U_ITMSG("Nao há registros",'Atenção!',,3)
   EndIf  	 
	
End Sequence 

If Select("TRBSA3") <> 0
   TRBSA3->(DBCloseArea())
EndIf

Return .T.

/*
===============================================================================================================================
Programa----------: MOMS058E
Autor-------------: Julio de Paula Paz
Data da Criacao---: 01/04/2021
Descrição---------: Rotina de envio de e-mail via Workflow para equipe de comissões.
Parametros--------: _aDadosEnv , _cMailDpCom
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS058E(_aDadosEnv,_cMailDpCom,_lSuperiores,_cSuperior)
Local _nI 
Local _cEmailOriginal:=""
DEFAULT _cMailDpCom := U_ItGetMv("IT_DEPCOMIS","") 
DEFAULT _lSuperiores:=.F.

IF EMPTY(_aDadosEnv)
   RETURN .F.
ENDIF
If _lAmbTeste
   _cEmailOriginal:=_cMailDpCom+" / "+_cSuperior
ENDIF


Begin Sequence
   //====================================
   // Codigo do processo cadastrado no CFG
   //====================================
   _cCodProce := "PEDIDO"
      
   //======================================================================
   // Inicialize a classe TWFProcess e assinale a variável objeto oProcess:
   //======================================================================
   _oProcess := TWFProcess():New(_cCodProce,"WORKFLOW VENDEDORES BLOQUEADOS POR FICAREM MAIS DE 90 DIAS SEM FATURAR.")

	
	_cMailID	:= _oProcess:fProcessId
	_cTaskID	:= _oProcess:fTaskID

	chtmlfile	:= _cMailID + ".htm"
	cMailTo		:= "mailto:" + Alltrim(Posicione("WF7", 1, XFilial("WF7") + AllTrim(GetMV('MV_WFMLBOX')), "WF7_ENDERE"))
	chtmltexto	:= wfloadfile("\workflow\emp01\" + chtmlfile )//Carrega o arquivo 
	chtmltexto	:= strtran( chtmltexto, cmailto, "WFHTTPRET.APL" )//Procura e troca a string
	wfsavefile("\workflow\emp"+cEmpAnt+"\" + chtmlfile, chtmltexto)//Grava o arquivo de volta

   _oProcess:NewTask("LINK", "\workflow\htm\VENDEDOR_SEM_FAT.HTM")//"\Workflow\htm\sc_aprovador.htm"
		
	_nBloqueados:=0
	_nBloqVend:=0
   SA2->(DBSETORDER(1))
   IF TYPE("__cUserID") <> "C"
      __cUserID:="Schedure"
   ENDIF
   For _nI := 1 To Len(_aDadosEnv)
 
       //========================================================
       // Bloquear Vendedor
       //========================================================
       If !_lAmbTeste .OR. (_lSuperiores .OR. _aDadosMarca[_nI,1])//_aDadosMarca e _aDadosEnv TEM AS MESMAS QTDES DE REGISTROS quando não é _lSuperiores
          SA3->(DbGoTo(_aDadosEnv[_nI, LEN(_aDadosEnv[_nI])]))  
          IF SA3->A3_MSBLQL <> "1"
             SA3->(RecLock("SA3",.F.))
             SA3->A3_MSBLQL := "1"
             SA3->(MsUnLock())
             _aDadosSA:={}   
             aAdd(_aDadosSA,{ "A3_MSBLQL" , SA3->A3_MSBLQL })       
             U_ITGrvLog( _aDadosSA, "SA3" , 1 , xFilial("SA3") + SA3->A3_COD , "A" , __cUserID, DATE() , TIME() )           
          ENDIF
          _nBloqueados++
			 _aDadosEnv[_nI,1]:=_aDadosEnv[_nI,1]+" (B)"

          IF !EMPTY(SA3->A3_FORNECE) .AND. LEFT(SA3->A3_FORNECE,1) = "V" .AND. SA2->(DBSEEK(xFilial("SA2")+SA3->A3_FORNECE+SA3->A3_LOJA))
             IF SA2->A2_MSBLQL <> "1"
                SA2->(RecLock("SA2",.F.))
                SA2->A2_MSBLQL := "1"
                SA2->(MsUnLock())
                _aDadosSA:={}   
                aAdd(_aDadosSA,{ "A2_MSBLQL" , SA2->A2_MSBLQL })       
                U_ITGrvLog( _aDadosSA, "SA2" , 1 , xFilial("SA2") + SA2->A2_COD + SA2->A2_LOJA, "A" , __cUserID, DATE() , TIME() )
             ENDIF
             _nBloqVend++
			    _aDadosEnv[_nI,1]:=_aDadosEnv[_nI,1]+" (B)"
          ENDIF
       ENDIF

       //========================================================
       // Atualizar HTML para envio do Workflow.
       //========================================================
		 aAdd( _oProcess:oHtml:ValByName("itens.VENDEDOR")	   , _aDadosEnv[_nI,1] )
		 aAdd( _oProcess:oHtml:ValByName("itens.ULTIMOFAT")   , _aDadosEnv[_nI,2] )	
		 aAdd( _oProcess:oHtml:ValByName("itens.ULTIMOPV")    , _aDadosEnv[_nI,3] )	
       aAdd( _oProcess:oHtml:ValByName("itens.DTINICIO")	   , _aDadosEnv[_nI,4] )		 
		 aAdd( _oProcess:oHtml:ValByName("itens.SUPERVISOR")	, _aDadosEnv[_nI,5] )
		 aAdd( _oProcess:oHtml:ValByName("itens.COORDENADOR")	, _aDadosEnv[_nI,6] )
		 aAdd( _oProcess:oHtml:ValByName("itens.GERENTE")	   , _aDadosEnv[_nI,7] )
   
   Next 

   IF _lSuperiores
      _cSubtitulo:="O(s) vendedore(s) abaixo pelo qual você é responsável foram bloqueados por<br>ficarem mais de 90 dias sem realizar um faturamento."
   ELSE
      _cSubtitulo:="O(s) vendedore(s) a seguir foram bloqueados automaticamente pelo sistema,<br>por ficarem mais de 90 dias sem faturar."
   ENDIF
   IF !EMPTY(_cEmailOriginal)
      _cSubtitulo+="<br> E-mail original: "+_cEmailOriginal
   ENDIF

   _oProcess:oHtml:ValByName("SUBTITULO", _cSubtitulo)
   _oProcess:oHtml:ValByName("Ambiente" ,GetEnvServer()+" / "+_cSuperior)
	_oProcess:oHtml:ValByName("cLogo"	 ,cLogo		   )

  // RastreiaWF(_cMailID + '.' + _cTaskID , _oProcess:fProcCode, "1001", "Lista de Pedidos de Vendas do Portal Pendente Aprovação", "")

	_cAssunto := "Vendedores bloqueados por não faturarem em um determinado período"
      
   _cEmail:= _cMailDpCom 

    FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MOMS058"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MOMS05801"/*cMsgId*/, "MOMS05801 - E-mail: "+_cAssunto+" para: " + _cEmail/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	//====================================================
	// Informamos o destinatário do email contendo o link.  
	//====================================================
	_oProcess:cTo := _cEmail   //02 - lista de PC's por Aprovador
	
	//===============================
	// Informamos o assunto do email.  
	//===============================
	_oProcess:cSubject	:= U_ITEncode(_cAssunto)

	_cMailID	:= _oProcess:fProcessId
	_cTaskID	:= _oProcess:fTaskID
	//RastreiaWF(_cMailID + '.' + _cTaskID , _oProcess:fProcCode, "1004", "Vendedores bloqueados por não faturarem em um determinado período", "")

	//=======================================================
	// Iniciamos a tarefa e enviamos o email ao destinatário.
	//=======================================================
	_oProcess:Start()


End Sequence

If !_lScheduler
   U_ITMSG("E-mail enviado para: "+_cEmail,"Envio do E-MAIL","Vendedores Bloqueados: "+CValToChar(_nBloqueados)+_ENTER+"Fornecedores Bloqueados: "+CValToChar(_nBloqVend),2)
ENDIF

Return .T.

/*
===============================================================================================================================
Programa----------: MOMS058
Autor-------------: Julio de Paula Paz
Data da Criacao---: 31/03/2021
Descrição---------: Verifica e bloqueia o vendedores que não faturam a 90 dias, e envia e-mail com a lista dos vendedores
                    bloqueados para a equipe que trata comissão.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS058S()
Local _aTables		:= {"SA3","SF2","SC5"}

Private _cHostWF	:= ""
Private _dDtIni		:= ""
Private cLogo		:= ""

Begin Sequence
   FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MOMS058"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MOMS05802"/*cMsgId*/, "MOMS05802 - Inicio Workflow Vendedores Bloqueados por não Faturarem em um Período."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
   
   //====================
   //Nao consome licensas
   //====================
   RPCSetType(3)

   //==========================================
   //seta o ambiente com a empresa 01 filial 01
   //==========================================   	 
   RpcSetEnv("01","01",,,,"SCHEDULE_WF_VEND_BLOQUEADOS",_aTables)

   //====================================================================
   //Roda a rotina principal de bloqueio de vendedores e envio de e-mail
   //====================================================================
   U_MOMS058(.T.) 

 	//============================================================
	//Limpa o ambiente, liberando a licença e fechando as conexoes
	//============================================================
	RpcClearEnv()  
	
   FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MOMS058"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MOMS05803"/*cMsgId*/, "MOMS05803 - Fim Workflow Vendedores Bloqueados por não Faturarem em um Período."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
   
End Sequence 

Return

/*
===============================================================================================================================
Programa----------: MOMS058U
Autor-------------: Julio de Paula Paz
Data da Criacao---: 31/03/2021
Descrição---------: Retorna a ultima data de faturamento do vendedor passado por parâmetro.
Parametros--------: _cCodVend = Código do vendedor
Retorno-----------: _cDtUltimoFat = Ultima data de faturamento
===============================================================================================================================
*/
User Function MOMS058U(_cCodVend)
Local _cRet := ""
Local _cQry 

Begin Sequence

   _cQry := " SELECT MAX(F2_EMISSAO) AS DTMAX"
   _cQry += " FROM " + RetSqlName("SF2") + " SF2 "
   _cQry += " WHERE SF2.D_E_L_E_T_ = ' ' "
   _cQry += "  AND F2_TIPO = 'N' "
   _cQry += "  AND F2_VEND1 = '" + _cCodVend + "' "
   
   If Select("TRBSF2") <> 0
	  TRBSF2->(DBCloseArea())
   EndIf

   DbUseArea(.T., "TOPCONN", TcGenQry(,,_cQry), "TRBSF2", .T., .F.)
   
   TCSetField( 'TRBSF2', "DTMAX","D",8)
   
   If TRBSF2->(Eof()) .And. TRBSF2->(Bof())
      Break
   EndIf 

   _cRet := Dtoc(TRBSF2->DTMAX)
   
End Sequence

If Select("TRBSF2") <> 0
	TRBSF2->(DBCloseArea())
EndIf

Begin Sequence
  
     _cQry := " SELECT MAX(C5_EMISSAO) AS DTMAX"
     _cQry += " FROM " + RetSqlName("SC5") + " SC5 "
     _cQry += " WHERE SC5.D_E_L_E_T_ = ' ' "
     _cQry += "  AND C5_TIPO = 'N' "
     _cQry += "  AND C5_VEND1 = '" + _cCodVend + "' "
     
     If Select("TRBSC5") <> 0
  	     TRBSC5->(DBCloseArea())
     EndIf
  
     DbUseArea(.T., "TOPCONN", TcGenQry(,,_cQry), "TRBSC5", .T., .F.)
     
     TCSetField( 'TRBSC5', "DTMAX","D",8)
     
     If TRBSC5->(Eof()) .And. TRBSC5->(Bof())
        Break
     EndIf 
  
     _cDtUltPV := Dtoc(TRBSC5->DTMAX)
     
End Sequence

If Select("TRBSC5") <> 0
	TRBSC5->(DBCloseArea())
EndIf

Return _cRet

