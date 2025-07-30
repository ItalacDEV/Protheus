/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 09/10/2018 | Gravação de campo C5_I_DTNEC - Chamado 25790                                              
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 11/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 21/10/2019 | Corrigido error.log. Chamado 30948
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges      | 23/07/2025 | Chamado 51340. Trocado e-mail padrão para sistema@italac.com.br
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include	"Protheus.Ch"
#INCLUDE 	"TopConn.ch"

/*
===============================================================================================================================
Programa----------: MOMS032
Autor-------------: Alex Wallauer
Data da Criacao---: 23/09/2016
===============================================================================================================================
Descrição---------: Schedule para verificar bloqueio de credito dos Pedidos de Venda - Chamado 17025
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function MOMS032()//U_MOMS032

Local aTables    := {"SC5","SC6","SC9","SA1","SF4","ZAY"}    
PRIVATE _lShedule:= .F. 
                        
If Select("SX3") <= 0
	_lShedule:= .T.
EndIf   
            
If _lShedule

	 //Mensagem que ficara armazenada no arquivo totvsconsole.log para posterior monitoramento 
    u_itconout("[MOMS032] - Inicio da Analise do Bloqueio de Credito dos Pedidos de Vendas data: " + Dtoc(DATE()) + ' - ' + Time())

	//Nao consome licensas
	RPCSetType(3)
	
	//seta o ambiente com a empresa 01 filial 01   	 
	RpcSetEnv("01","01",,,,/*"XML_WALlMART"*/,aTables)     
    cUsername:="Schedule [MOMS032]"
    MOMS032E(.T.)

ELSE

   cCadastro:="Analise Bloqueio de Credito dos Pedidos de Vendas"

   aRotina := {{ OemToAnsi("Pesquisar")     ,"AxPesqui"	      ,0,1,0,.F.},;
			   { OemToAnsi("Visualizar")    ,'AxVisual'       ,0,2,0,NIL},;
			   { OemToAnsi("Analisar Atual"),'U_MOMS032E(.F.)',0,2,0,NIL},;
			   { OemToAnsi("Analisar Todos"),'U_MOMS032E(.T.)',0,2,0,NIL}}

   _aCorLegen:={}
   aAdd(_aCorLegen,{  "C5_I_BLCRE <> 'B' .AND. C5_LIBEROK <> 'S' .AND. C5_NOTA = ' ' .AND.  (C5_I_PEDPA <> 'S' .OR. C5_I_PEDGE = 'S') .AND. C5_TIPO = 'N'" ,'ENABLE'  })			
   aAdd(_aCorLegen,{"!(C5_I_BLCRE <> 'B' .AND. C5_LIBEROK <> 'S' .AND. C5_NOTA = ' ' .AND.  (C5_I_PEDPA <> 'S' .OR. C5_I_PEDGE = 'S') .AND. C5_TIPO = 'N')",'DISABLE'})

   mBrowse(,,,,"SC5",,,,,,_aCorLegen)//Menu do OMS

EndIf

RETURN .F.

/*
===============================================================================================================================
Programa----------: MOMS032E
Autor-------------: Alex Wallauer
Data da Criacao---: 23/09/2016
===============================================================================================================================
Descrição---------: Rotina para analisar o credito dos pedido de venda
===============================================================================================================================
Parametros--------: lTodos: .T. analisa todos senao só o atual
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS032E(lTodos)
Local oproc


fwmsgrun(,{|oproc| MOMS032E(lTodos,oproc) },"Aguarde...","Analisando Pedidos...")

RETURN .T.

/*
===============================================================================================================================
Programa----------: MOMS032E
Autor-------------: Alex Wallauer
Data da Criacao---: 23/09/2016
===============================================================================================================================
Descrição---------: Processamento principal do schedule
===============================================================================================================================
Parametros--------: lTodos: .T. analisa todos senao só o atual
					oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function MOMS032E(lTodos,oproc)

Local cAlias  :=GetNextAlias()  
Local lEfetiva:=.T.
LOCAL _cCarga :=""
LOCAL _lGrvLog:=.F.
LOCAL _nConta :=0
LOCAL cQuery  :="SELECT SC5.R_E_C_N_O_ REC_SC5 "
Local _nLog		:= 0

Default oproc := nil

Private ntot := 0

_cTimeInicial :=TIME()
If !_lShedule 
   oproc:cCaption := ("Etapa 1 de 3 - Filtrando pedidos...")
   ProcessMessages()
Endif

cQuery += " FROM " + RETSQLNAME("SC5") +  " SC5 "
cQuery += " WHERE D_E_L_E_T_ = ' ' AND C5_NOTA = ' ' AND  (C5_I_PEDPA <> 'S' OR C5_I_PEDGE = 'S') "
cQuery += " AND C5_TIPO = 'N' "

IF !lTodos

   cQuery += " AND C5_FILIAL = '"+SC5->C5_FILIAL+"' AND C5_NUM = '"+SC5->C5_NUM+"' "

ENDIF

cQuery += " ORDER BY C5_FILIAL,C5_NUM


cQuery := ChangeQuery(cQuery)

If Select(cAlias) >0

   (cAlias)->( dbCloseArea() )

Endif

TCQUERY cQuery New Alias (cAlias)

DbSelectArea(cAlias)
count to nTot

(cAlias)->( dbGoTop() )

If !_lShedule 
  
   IF nTot = 0

      u_itmsg("Não existe Pedido(s) com o criterio da selecao! ","Atenção","Refaça a seleção...",1)
      RETURN .F.

   ELSE

      IF (nRet:=Aviso("Analise de Credito","Quantidade de Pedido(s): "+ALLTRIM(STR(nTot))+CHR(13)+CHR(10)+"Confirma Analise de Credito?",{'OK/Consulta','OK/Efetiva','Sair'},2 )) = 3
         (cAlias)->(dbCloseArea())
         dbSelectArea("SC5")
         RETURN .F.
      Endif

      _cTimeInicial :=TIME()

      lEfetiva := (nRet = 2)

   ENDIF

Endif


(cAlias)->(DbGotop())

PRIVATE _cCodChep:= alltrim(GetMV("IT_CCHEP"))
PRIVATE _nTotPed := 0
PRIVATE _aLog    :={}

_cTotal:=ALLTRIM(STRzero(nTot,6))

SC5->( DBSetOrder(1) )
SC9->( DbSetOrder(1) )

DO While (cAlias)->(!Eof())
	
   SC5->(DBGOTO((cAlias)->REC_SC5))
	
   _nConta++
   If !_lShedule 
      oproc:cCaption := "Lendo Filial/PV: "+SC5->C5_FILIAL+"/"+SC5->C5_NUM+" - "+ALLTRIM(STRzero(_nConta,6))+"/"+_cTotal
      ProcessMessages()
   Endif
   
   //Atualiza campo C5_I_DTNEC
   	aheader := {}
    acols := {}
    aadd(aheader,{1,"C6_ITEM"})
    aadd(aheader,{2,"C6_PRODUTO"})
    aadd(aheader,{3,"C6_LOCAL"})

   	SC6->(Dbsetorder(1))
   	SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))
	
   	Do while SC6->(!EOF()) .AND. SC5->C5_FILIAL == SC6->C6_FILIAL .AND. SC5->C5_NUM == SC6->C6_NUM
   		aadd(acols,{SC6->C6_ITEM,SC6->C6_PRODUTO,SC6->C6_LOCAL})
   		SC6->(Dbskip())
   	Enddo
   	
   	_dtnec := SC5->C5_I_DTENT - (U_OMSVLDENT(SC5->C5_I_DTENT,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_I_FILFT,SC5->C5_NUM,1))
   
   	If _dtnec != SC5->C5_I_DTENT  
   		Reclock("SC5",.F.)
   		SC5->C5_I_DTNEC := _dtnec 
   		SC5->(Msunlock())
   	Endif

   IF SC5->C5_I_BLCRE = "R"
	  (cAlias)->(dbSkip())
      LOOP
   ENDIF

   IF !MOMS032V( SC5->C5_FILIAL+SC5->C5_NUM ) //Verifica se pedido sofre avaliação de crédito
	   (cAlias)->(dbSkip())
       LOOP
   ENDIF
	
   _cCarga   :=""
   _lLiberado:=.T.
   _cCliente :=SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" / "+Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NREDUZ") //SC5->C5_CLIENTE+" - "+SC5->C5_LOJACLI+" - "+

   _cCarga:="Não / Não"
   IF SC9->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
      _cCarga:="Sim / "+IF(SC5->C5_I_ENVRD="S","Sim","Não")
      IF !EMPTY(SC9->C9_CARGA)
         _cCarga+=" / "+SC9->C9_CARGA // se Tem CARGA
      ENDIF
   ENDIF         

   _aRetCre  := U_ValidaCredito( _nTotPed )//Validação de crédito unificada
   _lLimpaLCC:= .F.//Limpa Liberação Completa de Crédito

   IF _aRetCre[1] == "Bloqueado por liberação completa de crédito expirada"
      _aRetCre  := U_ValidaCredito( _nTotPed,,,, {|| .F. } )//Validação de crédito sem olhar liberação completa de crédito expirada
      _lLimpaLCC:= .T.//Limpa Liberação Completa de Crédito
   ENDIF

   _cBlqCred:=_aRetCre[1]
   IF LEN(_aRetCre) > 3
      _cBlqCred:= _aRetCre[4]// Complemento da descricoes da avaliação de credito
   ENDIF

   If _aRetCre[2] = "B"//Se bloqueou

      _lGrvLog:=.F.
      IF SC5->C5_I_BLCRE != "B" //  manda tudo que bloqueou .AND. (_cCarga # "Não / Não" .OR. SC5->C5_I_ENVRD = "S")
         _lGrvLog:=.T.//Gerar WK e-mail
      ENDIF

      _lLimpaLCC:=.F.//Não Limpa Liberação Completa de Crédito pq já vai limpar abaixo
      _lLiberado:=.F.

      IF lEfetiva
         SC5->(RecLock("SC5",.F.))
         SC5->C5_I_BLCRE := "B"
	     SC5->C5_I_DTAVA := DATE()
	     SC5->C5_I_HRAVA := TIME()
	     SC5->C5_I_USRAV := cUsername
	     SC5->C5_I_MOTBL := _aRetCre[1]
	     SC5->C5_I_LIBCA := ""
	     SC5->C5_I_LIBCT := ""
	     SC5->C5_I_LIBC  := 0       //LIB COMP
	     SC5->C5_I_LIBL  := CTOD("")//LIB COMP
	     SC5->C5_I_LIBCV := 0       //LIB COMP
	     SC5->C5_I_LIBCD := CTOD("")
	     SC5->C5_I_DTLIC := CTOD("")
	     SC5->(MsUnlock())
      ENDIF

      IF _lGrvLog .OR. !_lShedule 
   	     aAdd( _aLog ,{_lLiberado,SC5->C5_FILIAL,SC5->C5_NUM+"- "+DTOC(SC5->C5_EMISSAO),_cCarga,_cCliente,_cBlqCred,U_STPEDIDO(1),SC5->C5_I_ENVRD} )
   	  ENDIF
      
   Elseif SC5->C5_I_BLCRE != "L"
   
      IF lEfetiva
         SC5->(RecLock("SC5",.F.))
	     SC5->C5_I_BLCRE := " "
	     SC5->C5_I_DTAVA := DATE()
	     SC5->C5_I_HRAVA := TIME()
	     SC5->C5_I_USRAV := cUsername
	     SC5->C5_I_MOTBL := _aRetCre[1]
   	     SC5->(MsUnlock())
      ENDIF

      IF !_lShedule 
         aAdd( _aLog ,{_lLiberado,SC5->C5_FILIAL,SC5->C5_NUM+"- "+DTOC(SC5->C5_EMISSAO),_cCarga,_cCliente,_cBlqCred,U_STPEDIDO(1),SC5->C5_I_ENVRD} )
      ENDIF
      
   ENDIF

   IF _lLimpaLCC .AND. lEfetiva//Limpa os campos se passar na liberção sem olhar a Liberação Completa de Crédito expirada
      SC5->(RecLock("SC5",.F.))
      SC5->C5_I_LIBC  := 0       //LIB COMP
	  SC5->C5_I_LIBL  := CTOD("")//LIB COMP
	  SC5->C5_I_LIBCV := 0       //LIB COMP
   	  SC5->(MsUnlock())
   ENDIF
   
   U_ENVSITPV() //Envia interface de atualização do status do pedido para o RDC e atualiza campo C5_I_STATU

   (cAlias)->(dbSkip())
	
EndDo
		
(cAlias)->(dbCloseArea())
dbSelectArea("SC5")

If _lShedule

   if LEN(_aLog) > 0 .and. lEfetiva
      _aFilLog:={}
      FOR _nLog := 1 TO LEN(_aLog)
          IF ASCAN(_aFilLog,_aLog[_nLog,2])=0
             AADD(_aFilLog,_aLog[_nLog,2])
          ENDIF
      NEXT
    
      //Grava filial original
      _cfilial := cfilant
    
      FOR _nLog := 1 TO LEN(_aFilLog)//Tem que fazer um array de filial 
          cFilAnt  :=_aFilLog[_nLog]
          MOM032EML("Filial lida: "+cFilAnt+" - "+AllTrim( Posicione('SM0',1,cEmpAnt+cFilAnt,'M0_FILIAL') )+CHR(13)+CHR(10)+;
                     'Hora Inicial: '+_cTimeInicial+CHR(13)+CHR(10)+;
                     'Hora Final: '+TIME()+CHR(13)+CHR(10),_aLog, .F. , .T. )
      NEXT
      
      //Retorna filial original
      cfilant := _cfilial
      _cfilial := Posicione('SM0',1,cEmpAnt+cFilAnt,'M0_FILIAL')
   
   ENDIF
   
   u_itconout("[MOMS032] - Termino da Analise de Bloqueio de Credito dos Pedidos de Vendas data: " + Dtoc(DATE()) + ' - ' + Time())

   RpcClearEnv() //Limpa o ambiente, liberando a licença e fechando as conexões

ELSE
    
    IF LEN(_aLog) > 0
       _aButtons:={}
       aAdd( _aButtons , { "Envia Email"	, {|| MOM032EML("",_aLog,.T.,.F.)  }, "Envia Email do Log","Envia Email"} )

       _cSubTit:="Quantidade de Pedidos Analisados: "+ALLTRIM(STR(LEN(_aLog)))+" - "+;
                 'Hora Inicial: '+_cTimeInicial+' / Hora Final: '+TIME()

	   U_ITListBox( 'Log de Analise de Credito de Pedidos de Venda' ,;
	              {" ","Filial","Pedido","Liberado / RDC / Carga","Cliente","Resultado da Analise","Status do pedido"},_aLog,.T.,4,_cSubTit,,;
	              { 10,      30,      35,                      80,      200,                 200,500},,,, _aButtons )

    ELSE

       u_itmsg("Nenhuma Pedidos de Venda alterado.","Atenção",1)

    ENDIF

EndIf

Return .T.

/*
===============================================================================================================================
Programa----------: MOMS032V
Autor-------------: Alex Wallauer
Data da Criacao---: 23/09/2016
===============================================================================================================================
Descrição---------: Verifica se pedido de vendas passa por validação de crédito
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS032V(cChave)

LOCAL _lValCredito:=.T.

_nTotPed := 0

SC6->( DBSetOrder(1) )

IF SC6->(DBSEEK( cChave  ))
   
   DO WHILE SC6->(!EOF()) .AND. cChave == SC6->C6_FILIAL+SC6->C6_NUM
	
	  //Caso encontre uma das duas CFOP citadas abaixo o pedido |
	  //de venda corrente sera considerado do tipo bonificacao. |
	  If alltrim(SC6->C6_PRODUTO) == _cCodChep .OR. AllTrim(SC6->C6_CF) $ '5910/6910/5911/6911'
         _lValCredito:=.F.
         EXIT
	  EndIf

      If Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC") != 'S' //NÃO VALIDA CRÉDITO PARA PEDIDO SEM DUPLICATA
         _lValCredito:=.F.
         EXIT
      Endif
    
      If Posicione("ZAY",1,xfilial("ZAY")+ SC6->C6_CF,"ZAY_TPOPER") != 'V' //NÃO VALIDA CRÉDITO PARA PEDIDO COM CFOP QUE NÃO SEJA DE VENDA
         _lValCredito:=.F.
         EXIT
      Endif
   
	  //Efetua o somatorio dos itens do pedido 
	  _nTotPed += SC6->C6_VALOR

      SC6->(dbSkip())

   EndDo
	
ELSE

   _lValCredito:=.F.

ENDIF

Return( _lValCredito )


/*
===============================================================================================================================
Programa----------: MOM032EML
Autor-------------: Alex Wallauer
Data da Criacao---: 17/04/2017
===============================================================================================================================
Descrição---------: Rotina para enviar e-mail de notificação quando houver uma falha de integração
===============================================================================================================================
Parametros--------: _cObs: Observacoes
                    _aLog: Lista de logs
                    _lProcessa: .T. com Tela
===============================================================================================================================
*/
Static Function MOM032EML( _cObs,_aLog,_lProcessa,_lFiltra )

Local _aConfig	:= U_ITCFGEML('')
Local _cMsgEml	:= ''
Local _cEmail	:= SuperGetMV('IT_VALCRED',.F.,'sistema@italac.com.br' )
Local _cData	:= Dtoc(DATE())
Local _cHoraT   := _cTimeInicial
Local _cAssunto := 'Workflow - Validação de Credito'
Local _nI		:= 0
DEFAULT _lFiltra:= .F.
DEFAULT _lProcessa:=.F.

IF _lProcessa
   ProcRegua(0)
   PswOrder(1)
   PswSeek(__CUSERID,.T.)
   aUsuario:=PswRet()	
   _cEmail :=Alltrim(aUsuario[1,14])
   IF EMPTY(_cEmail)
	  Aviso("Sem e-mail cadastrado","Usuário sem e-mail no cadastro",{"OK"} , 1 )
      RETURN .F.
   ENDIF
ELSE
   IF EMPTY(_cEmail)
	  u_itconout('[MOMS032] - Sem e-mail cadastrado, verifique o parametro "IT_VALCRED" com a area de TI')
      RETURN .F.
   ENDIF
  _cAssunto += " - Processamento agendado (Schedule) - Filial : "+cFilAnt+" - "+AllTrim( Posicione('SM0',1,cEmpAnt+cFilAnt,'M0_FILIAL') )
ENDIF

_cMsgEml := '<html>'
_cMsgEml += '<head><title>Validação de Credito</title></head>'
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
_cMsgEml += '	<td class="titulos"><center>Log de Processamento</center></td>'
_cMsgEml += '	</tr>'
_cMsgEml += '</table>'
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="700">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="2" class="grupos">Analise de Credito de Pedidos de Venda</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Data:</b></td>'
_cMsgEml += '      <td class="itens" align="left" >'+ _cData +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Hora:</b></td>'
_cMsgEml += '      <td class="itens" align="left" >'+ _cHoraT +'</td>'
_cMsgEml += '    </tr>'

   _cObs+="#OBS#"
   _cMsgEml += '    <tr>'
   _cMsgEml += '      <td class="itens" align="center" width="20%"><b>Observação:</b></td>'
   _cMsgEml += '      <td class="itens" align="left" >'+ AllTrim( _cObs ) +'</td>'
   _cMsgEml += '    </tr>'

_cMsgEml += '	<tr>'
_cMsgEml += '      <td class="titulos" align="center" colspan="2"><font color="red">Esta é uma mensagem automática. Por favor não responder!</font></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '</table>'

If _aLog # NIL .AND. !Empty(_aLog)  .AND. Len( _aLog ) > 0
	
	_cMsgEml += '<br>'
	_cMsgEml += '<table class="bordasimples" width="1200">'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td align="center" colspan="5" class="grupos">PEDIDOS DE VENDA</b></td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td class="itens" align="center" width="1%"><b>  </b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="17%"><b>Filial-Pedido-Emissão</b></td>'
	_cMsgEml += '      <td class="itens" align="left" width="12%"><b>Liberado/RDC/Carga</b></td>'
	_cMsgEml += '      <td class="itens" align="left" width="28%"><b>Codigo / Loja / Cliente</b></td>'
	_cMsgEml += '      <td class="itens" align="left" width="44%"><b>Resultado da Analise</b></td>'
	_cMsgEml += '    </tr>'

	
	IF _lProcessa
		ProcRegua(Len( _aLog ))
	ENDIF

	_nBloquedos:=0
    _nLiberados:=0
    _nConta    :=0

	For _nI := 1 To Len( _aLog )

	    IF _lProcessa
		   IncProc()
	    ENDIF

	    IF _lFiltra .AND. _aLog[_nI][02] # cFilAnt
		   LOOP
	    ENDIF

		_cMsgEml += '    <tr>'
		IF !_aLog[_nI][1] //= "X"
			_cMsgEml += '      <td class="recusa" align="center" width="1%"><b>B</b></td>'
		ELSE
			_cMsgEml += '      <td class="aceito" align="center" width="1%"><b>L</b></td>'
		ENDIF

		_cMsgEml += '      <td class="itens" align="center" width="17%">'+ _aLog[_nI][02]+" -"+_aLog[_nI][03]+'</td>'
		_cMsgEml += '      <td class="itens" align="left" width="12%">'  + _aLog[_nI][04]+'</td>'
		_cMsgEml += '      <td class="itens" align="left" width="28%">'  + _aLog[_nI][05]+'</td>'
		_cMsgEml += '      <td class="itens" align="left" width="44%">'  + _aLog[_nI][06]+'</td>'
		_cMsgEml += '    </tr>'
        
		IF !_aLog[_nI][01]
		   _nBloquedos++
		ELSE
           _nLiberados++
        ENDIF
        _nConta++
		
	Next _nI
	
	_cMsgEml += '</table>'
	
EndIf
_cObsT:=""
IF _nLiberados # 0
   _cObsT:=ALLTRIM(STR(_nLiberados,10))+' Pedidos Liberados "L" (verde) '+CHR(13)+CHR(10)
ENDIF
IF _nBloquedos # 0
   _cObsT+=ALLTRIM(STR(_nBloquedos,10))+' Pedidos Bloqueados "B" (vermelho) '+CHR(13)+CHR(10)
ENDIF
_cMsgEml:=STRTRAN(_cMsgEml,"#OBS#",_cObsT)  

_cMsgEml += '</center>'

   _cMsgEml += '    <tr>'
   _cMsgEml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
   _cMsgEml += '      <td class="itens" align="left" > ['+ GetEnvServer() +'] </td>'
   _cMsgEml += '    </tr>'

_cMsgEml += '</body>'
_cMsgEml += '</html>'

_cEmlLog := ''
//    ITEnvMail(cFrom     ,cEmailTo ,cEmailCo,cEmailBcc,cAssunto ,cMensagem,cAttach   ,cAccount    ,cPassword   ,cServer      ,cPortCon    ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro)
U_ITENVMAIL( _aConfig[01] , _cEmail ,        ,         ,_cAssunto, _cMsgEml ,         ,_aConfig[01],_aConfig[02], _aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

IF !Empty( _cEmlLog )

   IF _lProcessa
      MessageBox( _cEmlLog+CHR(13)+CHR(10)+" E-mails: "+_cEmail , 'Envio do WF por e-mail' , 64 )
   ELSE
      u_itconout("[MOMS032] - "+_cEmlLog+CHR(13)+CHR(10)+" E-mails: "+_cEmail)
   ENDIF

ELSE

   IF _lProcessa
      u_itmsg("Enviado E-mails: "+_cEmail+", "+ALLTRIM(STR(_nConta,10))+" Pedidos Processados ]", "Analise de Credito dos Pedidos de Vendas  - "+TIME() ,,1 )
   ELSE
      u_itconout("[MOMS032] - Analise de Credito dos Pedidos de Vendas  - "+TIME()+" - [ Enviando E-mail para Filial: "+cFilAnt+", "+ALLTRIM(STR(_nConta,10))+" Pedidos Processados ]")
   ENDIF

EndIF

Return .T.
