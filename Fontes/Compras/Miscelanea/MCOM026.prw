/*
==============================================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
==============================================================================================================================================================
Analista       - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
Andre Carvalho - Alex Wallauer - 05/03/25 - 28/03/25 - 49970   - Inclusao dos campo de % de ICMS e Valor do ICMS na tabela de preços.
Andre Carvalho - Alex Wallauer - 17/03/25 - 28/03/25 - 49970   - Inclusao do campo Observacao da Tabela / AIA_I_OBS.
Andre Carvalho - Alex Wallauer - 02/04/25 - 03/03/25 - 50355   - Colocado um email com copia baseado no parametro IT_IDCWFTP do SX6.
==============================================================================================================================================================
*/
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
/*
===============================================================================================================================
Programa----------: MCOM026
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2024
Descrição---------: CHAMADO 47732. Rotina de Envio de Workflow de Tabela de Preços de Fornecedores de Compras. Andre. 
                    **CHAMAR COMA010 NO FORMULA PARA TESTAR ESSE FONTE**
Parametros--------: lReEnvio = .T. : Reenvia
Retorno-----------: .T.
===============================================================================================================================
*/
User Function MCOM026(cOpcao As Char) As Logical // **CHAMAR COMA010 NO FORMULA PARA TESTAR ESSE FONTE**

 If cOpcao = "REENVIA"
    IF AIA->AIA_I_SITW = "A" .AND. (DTOS(AIA->AIA_DATATE) >= DTOS(DATE()) .OR. EMPTY(DTOS(AIA->AIA_DATATE)))
       U_ITMSG("Tabela Aprovada não pode ser Reenviada.","Atenção",,1)
       RETURN .F.
    ELSEIf Empty( AIA->AIA_I_DTDE ) .OR. Empty( AIA->AIA_I_DATE ) .OR. ( AIA->AIA_I_DTDE > AIA->AIA_I_DATE ) .OR. AIA->AIA_I_DATE < DATE()
       U_ITMSG("Datas de aprovacao invalidas","Atenção",'Preencha as 2 datas com "Dt.Apr.Final" maior que a "Dt.Apr.Inici" e maior ou igual a hoje.',1)
       RETURN .F.
    ENDIF
 ELSEIF cOpcao = "DESATIVA"
    
    IF AIA->AIA_I_SITW = "A" .AND. (DTOS(AIA->AIA_DATATE) >= DTOS(DATE()) .OR. EMPTY(DTOS(AIA->AIA_DATATE)))
       IF  U_ITMSG("CONFIRMA DESATIVAR A TABELA POSICIONADA ?",'Atenção!',,3,2,2)
           AIA->(RecLock("AIA",.F.))
           AIA->AIA_DATDE :=DATE()-2
           AIA->AIA_DATATE:=DATE()-1
           AIA->AIA_I_SITW:="N"
           AIA->AIA_I_APRO:="Tabela desativada por "+Capital(RTrim(UsrFullName(__cUserId)))+" no dia "+DTOC(DATE())+' as '+TIME()
           AIA->(MSUNLOCK())    		   
           U_ITMSG("Tabela "+AIA->AIA_CODTAB+" desativada com sucesso.","Atenção",,2)
       ENDIF
    ELSE//'N=Não Enviado";E=Enviado;Q=QUESTIONADO;A=APROVADO;R-REJEITADO'
       U_ITMSG("Tabela "+AIA->AIA_CODTAB+"-"+ALLTRIM(AIA->AIA_DESCRI)+" / "+ALLTRIM(Posicione("SA2",1,xFilial("SA2")+AIA->AIA_CODFOR+AIA->AIA_LOJFOR,"A2_NOME") )+", não esta aprovada.","Atenção","Somente tabelas aprovadas e ativas podem ser inativada",1)
    ENDIF
    
    RETURN .T.
 ENDIF
 
 If cOpcao == "ENVIA" .OR. U_ITMSG("CONFIRMA O REENVIO ?",'Atenção!',,3,2,2)
    _nReAIA:=IF(cOpcao == "REENVIA",AIA->(RECNO()),0)
    FWMSGRUN(,{||  U_MCOM026E(_nReAIA) },'Enviando Aprovação...','Lendo dados...')
 ENDIF

RETURN .T.
/*
===============================================================================================================================
Programa----------: MCOM026E
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2024
Descrição---------: Rotina de Envio de Workflow de Tabela de Preços de Fornecedores de Compras. Andre. CHAMADO 
Parametros--------: _nReAIA = recno do AIA / _cPergPai = PERGUNTA PAI / _cIDUserSol = Solicitante da pergunta
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MCOM026E(_nReAIA As Numeric,_cPergPai As Character,_cIDUserSol As Character)
 Local lWFHTML := .T. As Logical 
 Local R As Numeric
 Local _aIDAprovasores := "" As Character
 Local _cEmails :="" As Character
 
 Private _cHostWF  := "" As Character
 Private _lCriaAmb := .F. As Logical  
 
 DEFAULT _nReAIA    := 0
 DEFAULT _cPergPai  := ""
 
 DBSELECTAREA("SX6")
 lWFHTML	:= GetMv("MV_WFHTML")//.T.
 PutMV("MV_WFHTML",.T.)
 
 DBSELECTAREA("ZP1")
 _cHostWF:= U_ItGetMv("IT_WFHOSTS","http://protheusteste.italac.com.br:11726/workflow/")

 U_ITWF1WF2Put("APRVTP","Workflow de Tabela de Preços de Fornecedores de Compras" )//Grava WF1 a primeira vez se não existir 
 
 _aIDAprovasores := ALLTRIM(SuperGetMv("IT_IDWFTP",.F.,"000218"))+";"
 _aIDAprovasores := U_ITTXTARRAY(_aIDAprovasores,";",0)
 
 aLog:={}
 _cEmails:=""
 FOR R := 1 TO LEN(_aIDAprovasores)
     If !Empty(_aIDAprovasores[R])
        _cEmails+="["+ALLTRIM(Lower(UsrRetMail(_aIDAprovasores[R])))+"] " //VAI PEGAR O E-MAIL DO APROVADOR 
        MCOM026S(_aIDAprovasores[R],_nReAIA,_cPergPai,_cIDUserSol) //Rotina responsável por montar o formulário de aprovação e o envio do link gerado.
     EndIf
 NEXT        
 
 PutMV("MV_WFHTML",lWFHTML)
 
 IF LEN(aLog) > 0
    U_ITMSG("WF de Aprovação de Tabela de Preços ENVIADO COM SUCESSO",'Atenção!',"Email's: "+_cEmails,2)
 ELSE
    U_ITMSG("Não tem WF de Aprovação de Tabela de Preços para enviar",'Atenção!',,1)
 ENDIF

Return

/*
===============================================================================================================================
Programa----------: MCOM026S
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2024
Descrição---------: Rotina responsável por montar o formulário de aprovação e o envio do link gerado.
Parametros--------: _cIDAproc - id do aprovador / _nReAIA = recno do AIA / _cPergPai = PERGUNTA PAI / _cIDUserSol = Solicitante da pergunta
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MCOM026S(_cIDAproc As Character,_nReAIA As Numeric,_cPergPai As Character,_cIDUserSol As Character) As Logical
 Local cEmail	  := "" As Character
 Local _cAmbiente:= UPPER(GETENVSERVER()) As Character
 Local _cFilial  := xFilial("AIA") As Character
 
 DEFAULT _cIDUserSol := RETCODUSR()//PRIMEIRA VEZ QUE EXECUTA É O O USUARIO LOGADO O SOLICITANTE 
 
 u_itconout("/////////////////   INICIO DO MCOM026S   /////////////////////////////////////////////////////////////////////////////////")
 
 IF _nReAIA = 0
    AIA->(DBSETORDER(1))//AIA->(AIA_FILIAL+AIA_CODFOR+AIA_LOJFOR)
    IF AIA->(DBSEEK(xFilial("AIA")+M->AIA_CODFOR+M->AIA_LOJFOR+M->AIA_CODTAB))//VEM DA INCLUSAO E DA Alteracao
       _nReAIA:=AIA->(RECNO())
    ENDIF
 ELSE
    AIA->(DBGOTO(_nReAIA))//VEM QUANDO TEM QUESTIONAMENTO(S) / REENVIO
 ENDIF
 
 // Assunto da mensagem
 _cAssunto := "Aprovação da Tabela de Preços - Filial " + _cFilial + " - " + AllTrim(FWFilialName(cEmpAnt,_cFilial,1)) + " / Tabela: " + AIA->AIA_CODTAB
 
 _oProcess := TWFProcess():New("APRVTP",_cAssunto)
 _oProcess:NewTask("Aprovacao_TB", "\workflow\htm\tp_aprovador.htm")  
 
 AIA->(DBGOTO(_nReAIA))
 
 cForn    := AIA->AIA_CODFOR+" "+AIA->AIA_LOJFOR+" - "+ALLTRIM(Posicione("SA2",1,xFilial("SA2")+AIA->AIA_CODFOR+AIA->AIA_LOJFOR,"A2_NOME")+" ("+SA2->A2_EST+")" )
 cFilTP   := _cFilial + " - " + AllTrim(FWFilialName(cEmpAnt, _cFilial, 1 ))
 cNumTP   := AIA->AIA_CODTAB+ " - "+AIA->AIA_DESCRI
 cVigencia:= "DE "+DTOC(AIA->AIA_I_DTDE)+" ATE "+DTOC(AIA->AIA_I_DATE)
 cSolic   := UPPER(ALLTRIM(UsrFullName( _cIDUserSol )))
 dDtEmi   := DTOC(DATE()) +" - "+ TIME()
 cAprNom  := UPPER(ALLTRIM(UsrFullName(_cIDAproc)))
 cEmail   := ALLTRIM(UsrRetMail(_cIDAproc)) //VAI PEGAR O E-MAIL DO APROVADOR
 cTipoFrete:=AIA->AIA_I_TPFR
 If AIA->AIA_I_TPFR == "C"
    cTipoFrete := "CIF"
 ElseIf AIA->AIA_I_TPFR == "F"
    cTipoFrete := "FOB"
 ElseIf AIA->AIA_I_TPFR == "T"
    cTipoFrete := "TERCEIROS"
 ElseIf AIA->AIA_I_TPFR == "S"
    cTipoFrete := "SEM FRETE"
 EndIf
 cCondPagto:=AIA->AIA_CONDPG+"-"+AllTrim(Posicione("SE4",1,xFilial("SE4") + AIA->AIA_CONDPG ,"E4_DESCRI"))
 
 //Variaveis que serão guardados no TP_APROVADOR.HTM para serem usadas nod proximo retornos
 _oProcess:oHtml:ValByName("cChaveTAP" ,AIA->AIA_CODFOR+AIA->AIA_LOJFOR+AIA->AIA_CODTAB)//NAO TEM  FILIAL MESMO
 _oProcess:oHtml:ValByName("cIDUserSol",_cIDUserSol )
 _oProcess:oHtml:ValByName("cIDUserApr",_cIDAproc )
 
 //TP_APROVADOR.HTM - OK - CHAMADO DO BOTÃO DO E-MAIL DO TP_LINK
 _oProcess:oHtml:ValByName("Fornecedor" , cForn)
 _oProcess:oHtml:ValByName("Filial"     , cFilTP)
 _oProcess:oHtml:ValByName("NumTP"      , cNumTP)
 _oProcess:oHtml:ValByName("Vigencia"   , cVigencia)
 _oProcess:oHtml:ValByName("Solicitante", cSolic)
 _oProcess:oHtml:ValByName("DtEmissao"  , dDtEmi)
 _oProcess:oHtml:ValByName("Aprovador"  , cAprNom)
 _oProcess:oHtml:ValByName("TipoFrete"  , cTipoFrete)
 _oProcess:oHtml:ValByName("CondPagto"  , cCondPagto)
 
 //IF !EMPTY(_cPergPai) // PARA BUSCAR OS QUESTIONAMENTOS ANTERIORES E CARREGAR A VARIAVEL _cPergPai NO REENVIO
    _cQuest:=M026Quest(_cFilial,AIA->AIA_CODFOR+AIA->AIA_LOJFOR+AIA->AIA_CODTAB,"TP",@_cPergPai)
    If !Empty(_cQuest)
         _oProcess:oHtml:ValByName("cQuest",_cQuest )
    Else
         _oProcess:oHtml:ValByName("cQuest","" )
    EndIf
 //EndIf
 
 _oProcess:oHtml:ValByName("cPergPai"  ,_cPergPai)
 _oProcess:oHtml:ValByName("A_RODAP"  , _cAmbiente)
 
 AIB->(DBSETORDER(1))//AIB_FILIAL+AIB_CODFOR+AIB_LOJFOR+AIB_CODTAB+AIB_ITEM
 AIB->(DBSEEK(AIA->AIA_FILIAL+AIA->AIA_CODFOR+AIA->AIA_LOJFOR+AIA->AIA_CODTAB)) 
 cDescMoeda:= "MV_MOEDA"+AllTrim(Str(AIB->AIB_MOEDA))
 cDescMoeda:= SuperGetMv(cDescMoeda)
 _oProcess:oHtml:ValByName("DescMoeda"  , cDescMoeda)
 
 _cAIA_cObs:=ALLTRIM(AIA->AIA_I_OBS)
 _oProcess:oHtml:ValByName("AIA_cObs"   , _cAIA_cObs)
 
 DO While !AIB->(Eof()) .AND. AIB->AIB_FILIAL == AIA->AIA_FILIAL .AND.;
                              AIB->AIB_CODTAB == AIA->AIA_CODTAB .AND.;
              AIB->AIB_CODFOR+AIB->AIB_LOJFOR == AIA->AIA_CODFOR+AIA->AIA_LOJFOR
 
    cSimbMoeda:= "MV_SIMB"+AllTrim(Str(AIB->AIB_MOEDA))
    cSimbMoeda:= SuperGetMv(cSimbMoeda)
 
    AADD(_oProcess:oHtml:ValByName("Itens.Item"   ),AIB->AIB_ITEM)
    AADD(_oProcess:oHtml:ValByName("Itens.Produto"),AIB->AIB_CODPRO + " - " + Posicione("SB1",1,xFilial("SB1")+AIB->AIB_CODPRO,"B1_DESC"))
    AADD(_oProcess:oHtml:ValByName("Itens.Valor"  ),cSimbMoeda+" "+Transform(AIB->AIB_PRCCOM, PesqPict("AIB","AIB_PRCCOM")))
    AADD(_oProcess:oHtml:ValByName("Itens.PICMS"  ),Transform(AIB->AIB_I_PICM, PesqPict("AIB","AIB_I_PICM"))+" %")
    AADD(_oProcess:oHtml:ValByName("Itens.VICMS"  ),cSimbMoeda+" "+Transform(AIB->AIB_I_VICM, PesqPict("AIB","AIB_I_VICM")))
    
    AIB->(dbSkip())
 ENDDO
 
 //================================
 // resposta ao retornar ao Workflow:
 //================================
 _oProcess:bReturn := "U_MCOM026R"
    
 _cMailID := _oProcess:Start("\workflow\emp01")//GRAVA O HTML
    
 If File("\workflow\emp01\" + _cMailID + ".htm")
    u_itconout("Arquivo " + "\workflow\emp01\" + _cMailID + ".htm" + " criado com sucesso.")
 EndIf 
    
 // Assunto da mensagem
 _cAssunto := "Aprovação de Tabela de preços Filial " + cFilTP + " / Tabela: " + AIA->AIA_CODTAB
 
 _oProcess  := TWFProcess():New("APRVTP",_cAssunto)
 // Criamos o link para o arquivo que foi gerado na tarefa anterior acima.  
 _oProcess:NewTask("LINK", "\workflow\htm\tp_link.htm")
 
 chtmlfile  := _cMailID + ".htm"
 cMailTo    := "mailto:" + Alltrim(Posicione("WF7", 1, XFilial("WF7") + AllTrim(GetMV('MV_WFMLBOX')), "WF7_ENDERE"))
 chtmltexto := wfloadfile("\workflow\emp01\" + chtmlfile )
 chtmltexto := strtran( chtmltexto, cmailto, "WFHTTPRET.APL" )
 wfsavefile("\workflow\emp"+cEmpAnt+"\" + chtmlfile, chtmltexto) // grava novamente com as alteracoes necessarias.
 cLink := _cHostWF + "emp01/" + _cMailID + ".htm"
 
 //=================================================================
 //CORPO DO E-MAIL - TP_LINK.HTM - OK - CORPO DO E-MAIL
 //=================================================================
 _oProcess:oHtml:ValByName("AprNom"	  , cAprNom)
 
 _oProcess:oHtml:ValByName("A_EMAIL"   , + " CLIQUE AQUI para avaliar a Tabela de Preços: " + cNumTP )//BOTÃO 
 _oProcess:oHtml:ValByName("A_LINK"    , cLink)
  _oProcess:oHtml:ValByName("A_SOLIC"  , cSolic)
 _oProcess:oHtml:ValByName("Filial"	   , cFilTP	)
 _oProcess:oHtml:ValByName("NumTP"     , cNumTP)
 _oProcess:oHtml:ValByName("Vigencia"  , cVigencia)
 _oProcess:oHtml:ValByName("Fornecedor", cForn)
 _oProcess:oHtml:ValByName("TipoFrete" , cTipoFrete)
 _oProcess:oHtml:ValByName("CondPagto" , cCondPagto)
 _oProcess:oHtml:ValByName("DescMoeda" , cDescMoeda)
 _oProcess:oHtml:ValByName("AIA_cObs"  , _cAIA_cObs)
 
  //Dados dos questionamentos no corpo do E-MAIL do TP_LINK.HTM
 If !Empty(_cQuest)
    _oProcess:oHtml:ValByName("cQuest",_cQuest )
 Else
    _oProcess:oHtml:ValByName("cQuest","" )
 EndIf

 _oProcess:oHtml:ValByName("A_RODAP"	  , _cAmbiente)
 
 // Informamos o destinatário (Aprovador) do email contendo o link.  
 _oProcess:cTo := Lower(cEmail)
  
 // Informamos o assunto do email.  
 _oProcess:cSubject	:= U_ITEncode(_cAssunto)
 
 U_ITWF1WF2Put("APRVTP",,"WFTP01","ENVIADO/AGUARDANDO APROVACAO" )//Grava WF2 a primeira vez se não existir  'N=Não Enviado;E=Enviado/Aguardando Aprovação;Q=Questionado;A=Aprovado;R-Rejeitado'
  //          cStatusCode, cDescription, cUserName, uShape
 _oProcess:Track("WFTP01",_cAssunto    ,cSolic)
 
 // Iniciamos a tarefa e enviamos o email ao destinatário.
 _oProcess:Start() //ENVIA O E-MAIL
 _oProcess:Finish()	
 u_itconout("Email enviado para: [" + (_oProcess:cTo) + "]")
 
 //=============================================================
 //Atualiza o sistema com as informações do SITWF e IDHTML
 _cItens:=""
 
 AIA->(DBGOTO(_nReAIA))
 AIA->(RecLock("AIA",.F.))
 AIA->AIA_I_SITW:="E"//Enviado - //'N=Não Enviado";E=Enviado;Q=QUESTIONADO;A=APROVADO;R-REJEITADO'
 AIA->AIA_I_APRO:="Enviado para Aprovacao por "+Capital(RTrim(UsrFullName(__cUserId)))+" no dia "+DTOC(DATE())+' as '+TIME()
 AIA->AIA_I_HTMW:=cLink//GRAVA O ARQUIVO PARA USAR Ex.:http://protheusteste.italac.com.br:11726/workflow/emp01/00a35663017e878088bb.htm
 AIA->(MSUNLOCK())    		
 
 AADD(aLog,{AIB->AIB_FILIAL,cNumTP,cSolic,cAprNom,cEmail,"Enviado [ "+AIA->AIA_I_SITW+" ]"}) 
 
 u_itconout("/////////////////   FINAL DO MCOM026S   /////////////////////////////////////////////////////////////////////////////////")

Return .T.
/*
===============================================================================================================================
Programa----------: MCOM026R
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2024
Descrição---------: Rotina responsável pela execução do retorno do workflow QUANDO APERTA APROVAR OU REJEITAR ou QUESTIONAR
Parametros--------: _oProcess - Processo inicializado do workflow
Retorno-----------: Nenhum
===============================================================================================================================
*/
//RETORNO DE TODOS OS BOTÕES DO TP_APROVADOR.HTM 
//QUANDO APERTA APROVAR ou REJEITAR ou QUESTIONAR
User Function MCOM026R( _oProcess As Object )
 Local _cAprova      := _oProcess:oHtml:RetByName("APROVACAO") As Character
 Local _cArqHtm      := _oProcess:oHtml:RetByName("WFMAILID") As Character
 Local _cAprNom      := _oProcess:oHtml:RetByName("Aprovador") As Character
 Local _cNumTP       := _oProcess:oHtml:RetByName("NumTP") As Character
 Local _cFilName     := _oProcess:oHtml:RetByName("Filial") As Character
 Local _cChaveTAP    := _oProcess:oHtml:RetByName("cChaveTAP") As Character
 Local _cPergPai     := _oProcess:oHtml:RetByName("cPergPai") As Character
 Local _cFilial      := LEFT(_cFilName,2) As Character
 Local _sDtLiber     := DTOC(DATE()) As Character
 Local _cHrLiber     := SUBSTR(TIME(),1,5) As Character
 Local _cVlrCampo    := "" As Character
 Local _cAmbiente    := UPPER(GETENVSERVER()) As Character
 Local _cHtmConcluido:= "\workflow\htm\tp_concluida.htm" As Character
 
 _cAprova:= UPPER(_cAprova)
 
 u_itconout("/////////////////   INICIO DO MCOM026R  _cAprova: "+_cAprova+" /////////////////////////////////////////////////////////////////////////////////")
 
 _cArqHtm:= SUBSTR(_cArqHtm,3,Len(_cArqHtm))//RETIRA O WF DO INICIO
 _cAprNom:= UPPER(ALLTRIM(_cAprNom))
 _cNumTP := UPPER(ALLTRIM(_cNumTP))
 
 //DADOS PARA GRAVA NO TP_CONCLUIDA.HTM
 If "APROVAR" $ _cAprova //== "S"   
    _cAprova  :="A"
    _cVlrCampo:= "da APROVACAO"
    _cObsConc := "A Tabela de Preços "+_cNumTP+" já foi APROVADA por "+_cAprNom+" na Data: "+_sDtLiber+", Hora: "+_cHrLiber
 ElseIf "REJEITAR" $ _cAprova //== "N"   
    _cAprova:="R"
    _cVlrCampo:= "da REJEICAO"		
    _cObsConc := "A Tabela de Preços "+_cNumTP+" já foi REJEITADA por "+_cAprNom+" na Data: "+_sDtLiber+", Hora: "+_cHrLiber+". "
    _cObsConc += "Entre em contato com o aprovador que rejeitou para maiores informações"
 Else             //QUESTIONAR
    _cAprova:="Q"
    _cVlrCampo:= "do QUESTIONAMENTO"		
    _cObsConc := "A Tabela de Preços "+_cNumTP+" já foi QUESTIONADA por "+_cAprNom+" na Data: "+_sDtLiber+", Hora: "+_cHrLiber+". "
    _cObsConc += "Entre em contato com o aprovador que questionou para maiores informações"
 EndIf
 
 AIA->(DBSETORDER(1))//AIA->(AIA_FILIAL+AIA_CODFOR+AIA_LOJFOR)
 _nReAIA:=0
 
 IF AIA->(DbSeek(_cFilial+_cChaveTAP))
    _nReAIA:=AIA->(RECNO())
    IF AIA->AIA_I_SITW $ "A,R,Q"//'N=Não Enviado";E=Enviado;Q=QUESTIONADO;A=APROVADO;R-REJEITADO'
       _cAprova :="ERRO"
       _cObsConc:= "A Tabela de Preços "+_cNumTP+" já foi "+ALLTRIM(AIA->AIA_I_APRO)
    ENDIF
 ELSE
    _cAprova :="ERRO"
    _cObsConc:= "A Tabela de preços: "+_cFilial+_cChaveTAP+" não foi encontrada no cadastro (AIA)."
 ENDIF
 
 //ATUALIZAÇÃO DO REGISTRO DA AIA
 If _cAprova == "A"
    AIA->(DBGOTO(_nReAIA))
    _dSalvaDtDe:= AIA->AIA_I_DTDE // DT DE NOVA
    _dSalvDtAte:= AIA->AIA_I_DATE // DT ATE NOVA
    _cChaveTAP := AIA->(AIA_CODFOR+AIA_LOJFOR)
    AIB->(DBSETORDER(1))//AIB_FILIAL+AIB_CODFOR+AIB_LOJFOR+AIB_CODTAB+AIB_ITEM
    AIB->(DBSEEK(AIA->AIA_FILIAL+AIA->AIA_CODFOR+AIA->AIA_LOJFOR+AIA->AIA_CODTAB)) 
    nSalvMoeda := AIB->AIB_MOEDA
    //PRIMEIRO DESATIVA TODAS AS OUTRAS TABELAS ATIVAS DO FORNECEDOR DA TABELA APROVADA
    If AIA->(DbSeek(_cFilial+_cChaveTAP)) 
       DO WHILE AIA->(!EOF()) .AND. _cFilial+_cChaveTAP == AIA->(AIA_FILIAL+AIA_CODFOR+AIA_LOJFOR)
 
          AIB->(DBSEEK(AIA->AIA_FILIAL+AIA->AIA_CODFOR+AIA->AIA_LOJFOR+AIA->AIA_CODTAB)) //PARA PEGAR A MOEDA
          
          IF AIA->AIA_I_SITW = "A" .AND. AIB->AIB_MOEDA = nSalvMoeda//TABELA APROVADA ANTERIORMENTE 
             
             _cResult1:=IF( (_dSalvaDtDe  < AIA->AIA_DATDE  .AND.  _dSalvDtAte < AIA->AIA_DATATE .AND. _dSalvDtAte >= AIA->AIA_DATDE  ), "VERDADEIRO" , "FALSO" ) 
             _cResult2:=IF( (AIA->AIA_DATDE <  _dSalvaDtDe  .AND.  AIA->AIA_DATATE < _dSalvDtAte .AND. _dSalvaDtDe <= AIA->AIA_DATATE ), "VERDADEIRO" , "FALSO" ) 
             _cResult3:=IF( (AIA->AIA_DATDE =  _dSalvaDtDe  .AND.  AIA->AIA_DATATE = _dSalvDtAte                                      ), "VERDADEIRO" , "FALSO" ) 
             _cResult4:=IF( (AIA->AIA_DATDE >= _dSalvaDtDe  .AND.  AIA->AIA_DATATE <= _dSalvDtAte                                     ), "VERDADEIRO" , "FALSO" ) 
             _cResult5:=IF( (AIA->AIA_DATDE <= _dSalvaDtDe  .AND.  AIA->AIA_DATATE >= _dSalvDtAte                                     ), "VERDADEIRO" , "FALSO" ) 
 
             IF (_dSalvaDtDe < AIA->AIA_DATDE  .AND.  _dSalvDtAte < AIA->AIA_DATATE .AND. _dSalvDtAte >= AIA->AIA_DATDE  ) .OR.; //INTERCALADAS A NOVA APROVAÇÃO ANTES
                (AIA->AIA_DATDE  < _dSalvaDtDe  .AND.  AIA->AIA_DATATE  < _dSalvDtAte .AND. _dSalvaDtDe <= AIA->AIA_DATATE ) .OR.; //INTERCALADAS A NOVA APROVAÇÃO DEPOIS
                (AIA->AIA_DATDE  = _dSalvaDtDe  .AND.  AIA->AIA_DATATE  = _dSalvDtAte                                      ) .OR.; //A NOVA APROVAÇÃO IGUAL
                (AIA->AIA_DATDE >= _dSalvaDtDe  .AND.  AIA->AIA_DATATE <= _dSalvDtAte                                      ) .OR.; //A NOVA APROVAÇÃO DENTRO
                (AIA->AIA_DATDE <= _dSalvaDtDe  .AND.  AIA->AIA_DATATE >= _dSalvDtAte                                      )       //A NOVA APROVAÇÃO FORA
            
                U_ITCONOUT(" **INATIVOU** TABELA / FORNECEDOR: "+AIA->AIA_CODTAB+" / "+_cChaveTAP)
            
                AIA->(RecLock("AIA",.F.))
                AIA->AIA_DATDE :=DATE()-2
                AIA->AIA_DATATE:=DATE()-1
                AIA->(MSUNLOCK())    		
              ENDIF
          ENDIF
         AIA->(DBSKIP())
       ENDDO
    ENDIF
    //SEGUNDO ATIVA A TABELA DO FORNECEDOR APROVADA
    AIA->(DBGOTO(_nReAIA))
    AIA->(RECLOCK("AIA",.F.))
    AIA->AIA_DATDE  :=AIA->AIA_I_DTDE 
    AIA->AIA_DATATE :=AIA->AIA_I_DATE
    AIA->AIA_I_APRO := "APROVADA por "+_cAprNom+" no dia "+DTOC(DATE())+' as '+TIME()
 ELSEIF _cAprova == "R"
    AIA->(RECLOCK("AIA",.F.))
    AIA->AIA_DATDE :=DATE()-2
    AIA->AIA_DATATE:=DATE()-1
    AIA->AIA_I_APRO := "REJEITADA por "+_cAprNom+" no dia "+DTOC(DATE())+' as '+TIME()
 ELSEIF _cAprova == "Q"
    AIA->(RECLOCK("AIA",.F.))
    AIA->AIA_I_APRO := "QUESTIONADA por "+_cAprNom+" no dia "+DTOC(DATE())+' as '+TIME()
 ENDIF
 
 If !(_cAprova == "ERRO")// STATUS MUDO AQUI
    AIA->AIA_I_SITW :=_cAprova//'N=Não Enviado";E=Enviado;Q=QUESTIONADO;A=APROVADO;R-REJEITADO'
    AIA->(MSUNLOCK())    		
 ENDIF
 
 //Finalize a tarefa anterior para não ficar pendente
 _oProcess:Finish()
 
 If _cAprova == "ERRO"
    _cObsConc:= "Houve um problema na hora "+_cVlrCampo+":<br>"+_cObsConc+"<br>"
    chtmlfile  := "\workflow\emp01\" + _cArqHtm + ".Erro"
    MemoWrite(chtmlfile,_cObsConc)
    If File(chtmlfile)
       u_itconout('WF-Arq do Erro.........: ' + chtmlfile ) 
    ELSE
       u_itconout('Nao tem WF-Arq do Erro.: ' + chtmlfile ) 
    ENDIF
    u_itconout('Obs do WF-Arq do Erro..: ' + _cObsConc ) 
 
 ELSEIf _cAprova = "Q"
 
    MCOM26Q(_oProcess,_cObsConc,_nReAIA,_cPergPai)//RETORNO QUE ENVIA E-MAIL PARA O SOLICITANTE RESPONDER O QUESTIONAMENTO
 
 ELSE
 
    MCOM026A(_oProcess,_cObsConc,_nReAIA)//ENVIA O E-MAIL PARA O SOLICITANTE - APROVADO OU REJEITADO
 
 EndIf
 
 //Faz a cópia do arquivo de aprovação para .old, e cria o arquivo de processo já concluído
 //         Origem        ,Destino
 IF MEST26Copy(_cHtmConcluido,_cArqHtm,@_cObsConc)
    //Alterando o conteudo do \workflow\htm\tp_concluida.htm 
    chtmlfile  := "\workflow\emp01\" + _cArqHtm + ".htm"
    chtmltexto := wfloadfile( chtmlfile )
    chtmltexto := strtran( chtmltexto, "!A_MSG!"  , _cObsConc)
    chtmltexto := strtran( chtmltexto, "!A_RODAP!", _cAmbiente)
    WFSAVEFILE( chtmlfile , chtmltexto)
 Else
   chtmlfile:= "\workflow\emp01\" + _cArqHtm + ".Erro"
   MemoWrite(chtmlfile,_cObsConc)
 Endif

 u_itconout("/////////////////   FINAL DO MCOM026R  _cAprova: "+_cAprova+" /////////////////////////////////////////////////////////////////////////////////")

Return


/*
===============================================================================================================================
Programa----------: MCOM026A
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2024
Descrição---------: Função criada aviso ao Solicitante para enviar e-mail de APROVACAO OU REJEIÇÃO
Parametros--------: _oProcess  - Processo inicializado do workflow
                    _cObsConc  - Resultaldo da APROVACAO / REJEICAO / QUESTINAMENTO
                    _nReAIA    - Registro do AIA
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MCOM026A(_oProcess As Object,_cObsConc As Character,_nReAIA As Numeric)//RETORNO DOS BOTÕES DE APROVACAO OU REJEICAO DO TP_APROVADOR.HTM
 Local _cFilName  := _oProcess:oHtml:RetByName("Filial") As Character
 Local _cForn     := _oProcess:oHtml:RetByName("Fornecedor") As Character    
 Local _cVigencia := _oProcess:oHtml:RetByName("Vigencia") As Character    
 Local _cNumTP    := _oProcess:oHtml:RetByName("NumTP") As Character    
 Local _cIDUserSol:= _oProcess:oHtml:RetByName("cIDUserSol") As Character
 Local _cAprNom   := _oProcess:oHtml:RetByName("Aprovador") As Character
 Local _cSolic    := _oProcess:oHtml:RetByName("Solicitante") As Character
 Local cTipoFrete := _oProcess:oHtml:RetByName("TipoFrete") As Character
 Local cCondPagto := _oProcess:oHtml:RetByName("CondPagto") As Character
 Local cDescMoeda := _oProcess:oHtml:RetByName("DescMoeda") As Character
 Local _cAIA_cObs := _oProcess:oHtml:RetByName("AIA_cObs") As Character
 Local _cChaveTAP := _oProcess:oHtml:RetByName("cChaveTAP") As Character
 Local _cPergPai  := _oProcess:oHtml:RetByName("cPergPai") As Character
 Local _cFilial   := LEFT(_cFilName,2) As Character
 Local _cObs      := AllTrim(_oProcess:oHtml:RetByName("TP_OBS")) As Character
 Local _cAprova   := UPPER(_oProcess:oHtml:RetByName("APROVACAO")) As Character
 Local _cHrLiber  := SUBSTR(TIME(),1,5) As Character
 Local _cAmbiente := UPPER(GETENVSERVER()) As Character
 Local _cEmail    := "" As Character
 Local _cAssunto  := "Retorno do WF da Aprovação da Tabela de Preços. Filial " + _cFilName + " / Tabela: " + UPPER(ALLTRIM(_cNumTP)) As Character
 Local _cAviso    := "" As Character
 Local _cAvisObs  := "" As Character
 Local I          := "" As Numeric
 
 _cAprNom:= UPPER(ALLTRIM(_cAprNom))
 _cNumTP := UPPER(ALLTRIM(_cNumTP))
 
 u_itconout("/////////////////   INCIO DA MCOM026A   /////////////////////////////////////////////////////////////////////////////////")
 
 _oProcess := TWFProcess():New("APRVTP",_cAssunto)
 _oProcess:NewTask("Aprovacao_TB", "\workflow\htm\tp_solicitante.htm")
 
 _cEmail := Lower(AllTrim(UsrRetMail(_cIDUserSol)))
 
 If "APROVAR" $ _cAprova //== "S" 
    _cAviso  := "APROVADA"
    _cAvisObs:= "Observ. da Aprovação"
    _cAvisoC := "<font color= #00FF00  style='font-size: 12px; font-weight: bold;'>"+_cAviso+"</font>"//VERDE
    //_cAvisoC := '<span style="color: #00FF00; background-color: #000000; font-size: 12px; font-weight: bold;">'+_cAviso+'</span>'
    _cAssunto+=" - "+_cAviso
 
    U_ITWF1WF2Put("APRVTP",,"WFTP02","APROVADO" )//Grava WF2 a primeira vez se não existir  'N=Não Enviado;E=Enviado/Aguardando Aprovação;Q=Questionado;A=Aprovado;R-Rejeitado'
    _oProcess:Track("WFTP02",_cAssunto,_cAprNom)
 
 ElseIf "REJEITAR" $ _cAprova //== "N"   
    _cAviso  := "REJEITADA"
    _cAvisObs:= "Observ. da Rejeição"
    _cAvisoC := "<font color= #FF0000  style='font-size: 12px; font-weight: bold;'>"+_cAviso+"</font>"//VERMELHO
    //_cAvisoC := '<span style="color: #FF0000; background-color: #000000; font-size: 12px; font-weight: bold;">'+_cAviso+'</span>'
    _cAssunto+=" - "+_cAviso
   
    U_ITWF1WF2Put("APRVTP",,"WFTP03","REJEITADO" )//Grava WF2 a primeira vez se não existir  'N=Não Enviado;E=Enviado/Aguardando Aprovação;Q=Questionado;A=Aprovado;R-Rejeitado'
    _oProcess:Track("WFTP03",_cAssunto,_cAprNom)
 
 EndIf
 
 //=================================================================
 //CORPO DO E-MAIL - TP_SOLICITANTE .HTM - OK - CORPO DO E-MAIL
 //=================================================================
 //APROVADO OU REJEITADO
 _oProcess:oHtml:ValByName("A_SOLIC"   , _cSolic)
 _oProcess:oHtml:ValByName("Aprovacao" , _cAvisoC)
 
 _oProcess:oHtml:ValByName("AprNom"	  , _cAprNom    )
 _oProcess:oHtml:ValByName("A_Data"	  , DTOC(DATE()))
 _oProcess:oHtml:ValByName("A_Hora"	  , _cHrLiber   )
 _oProcess:oHtml:ValByName("Filial"	  , _cFilName   )
 _oProcess:oHtml:ValByName("NumTP" 	  , _cNumTP	    )
 _oProcess:oHtml:ValByName("Vigencia"  , _cVigencia )
 _oProcess:oHtml:ValByName("Fornecedor", _cForn     )
 _oProcess:oHtml:ValByName("TipoFrete" , cTipoFrete )
 _oProcess:oHtml:ValByName("CondPagto" , cCondPagto )
 _oProcess:oHtml:ValByName("DescMoeda" , cDescMoeda )
 _oProcess:oHtml:ValByName("AIA_cObs"  , _cAIA_cObs )
 _oProcess:oHtml:ValByName("cTextocObs", _cAvisObs  )
 _oProcess:oHtml:ValByName("cObs"      , _cObs      )
 
 //BUSCA OS QUESTIONAMENTOS ANTERIORES
 _cQuest:=M026Quest(_cFilial, AllTrim(_cChaveTAP),"TP",_cPergPai)
  //Dados dos questionamentos no corpo do E-MAIL do TP_SOLICITANTE.HTM
 If !Empty(_cQuest)
    _oProcess:oHtml:ValByName("cQuest",_cQuest )
 Else
    _oProcess:oHtml:ValByName("cQuest","" )
 EndIf

 _oProcess:oHtml:ValByName("A_RODAP"	, 	_cAmbiente	)
 
 // Informamos o destinatário (Solicitante) do email contendo o link.  
 _oProcess:cTo := (_cEmail)
 
 _xIDCopia := ALLTRIM(SuperGetMv("IT_IDCWFTP",.F.,"000865"))+";"
 _xIDCopia := U_ITTXTARRAY(_xIDCopia,";",0)
 _cIDCopia := ""
 FOR I := 1 TO LEN(_xIDCopia)
     If !Empty(_xIDCopia[I]) .And. !Lower(Alltrim(UsrRetMail(_xIDCopia[I]))) $ _cEmail
        _cIDCopia += Lower(Alltrim(UsrRetMail(_xIDCopia[I])))+";"
     EndIf
 Next I
 _cIDCopia:=SUBSTR(_cIDCopia,1,LEN(_cIDCopia)-1)
 IF !Empty(_cIDCopia)
    _oProcess:cCC:= (_cIDCopia)
 EndIf
 
 //===============================
 // Informamos o assunto do email.  
 //===============================
 _oProcess:cSubject	:= U_ITEncode(_cAssunto)
  
 //=======================================================
 // Iniciamos a tarefa e enviamos o email ao destinatário.
 //=======================================================
 _oProcess:Start() //ENVIA O E-MAIL
 _oProcess:Finish()
 
 u_itconout("/////////////////   FIM DA MCOM026A - Email enviado para: " + Lower(AllTrim(_cEmail)) +"  /////////////////////////////////////////////////////////////////////////////////")

Return

/*
===============================================================================================================================
Programa----------: MEST26Copy ()
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2024
Descrição---------: Faz a cópia do arquivo de aprovação para .old, e cria o arquivo de processo já concluído
Parametros--------: _cHtmConcluido,_cArqHtm,_cObsConc
Retorno-----------: nMedia
===============================================================================================================================*/
STATIC FUNCTION MEST26Copy(_cHtmConcluido As Char,_cArqHtm As Char, _cObsConc As Char) As Logical
 Local _lRet := .F. As Logical
 IF UPPER("\workflow\emp01\" + _cArqHtm + ".htm") == UPPER(_cHtmConcluido)
    u_itconout("Origem e destino iguais: DE "+_cHtmConcluido+" PARA \workflow\emp01\" + _cArqHtm + ".htm.")
    RETURN .T.
 ENDIF
 
 If File("\workflow\emp01\" + _cArqHtm + ".htm")
    If __CopyFile("\workflow\emp01\" + _cArqHtm + ".htm", "\workflow\emp01\" + _cArqHtm + ".old")
                   //_cArqDest                             ,_cArqOri
       If MCOM026CP("\workflow\emp01\" + _cArqHtm + ".htm",_cHtmConcluido) //Recria _cArqHtm com conteudo do modelo _cHtmConcluido
          u_itconout("Cópia do arquivo DE "+_cHtmConcluido+" PARA \workflow\emp01\" + _cArqHtm + ".htm de conclusão efetuada com sucesso.")
          _lRet := .T.
       Else
          _cObsConc:=("Problema na cópia de arquivo DE "+_cHtmConcluido+" PARA \workflow\emp01\" + _cArqHtm + ".htm")
       EndIf
    Else
       _cObsConc:=("Não foi possível renomear o arquivo " + _cArqHtm + ".htm.")
    EndIf
 else
    _cObsConc:=("Arquivo não encontrado \workflow\emp01\" + _cArqHtm + ".htm")
 EndIf
  
 u_itconout("MEST26Copy / _cObsConc: "+_cObsConc)

RETURN _lRet

/*
===============================================================================================================================
Programa----------: MCOM026CP
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2024
Descrição---------: Recria arquivo com conteúdo de outro arquivo
Parametros--------: _cArqDest - Arquivo onde vai gravar o conteudo
                    _cArqOri - Arquivo com conteúdo a ser utilizado
Retorno-----------: _lret - lógico indicando se completou o processo
===============================================================================================================================
*/
Static Function MCOM026CP(_cArqDest As Char,_cArqOri As Char) As Logical

 Local _lret := .T. As Logical
 Local _cconteudo := MemoRead( _cArqOri) As Char
 
 If empty(_cconteudo)
    _lret := .F.
 Endif
 If _lret .and. FERASE(_cArqDest)==0 
 
    _nHandle := FCREATE(_cArqDest)
    If _nHandle > 0
       FCLOSE(_nHandle)
       _lret := memowrite(_cArqDest,_cconteudo)
    Else
       _lret := .F.
    Endif
 Else
    _lret := .F.
 Endif 
   
Return _lret


/*
===============================================================================================================================
Programa----------: MCOM26Q
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2024
Descrição---------: Função criada para QUESTIONAMENTO ao Solicitante, para enviar e-mail de QUESTINAMENTO
Parametros--------: _oProcess /_cObsConc / _nReAIA / _cPergPai
Retorno-----------: Nenhum
===============================================================================================================================
*///RETORNO DO BOTÃO QUESTIONAR DO TP_APROVADOR.HTM
Static Function MCOM26Q(_oProcess As Object,_cObsConc As Character,_nReAIA As Numeric,_cPergPai As Character)
 Local _cForn     := _oProcess:oHtml:RetByName("Fornecedor") As Character    
 Local _cVigencia := _oProcess:oHtml:RetByName("Vigencia") As Character    
 Local _cNumTP    := _oProcess:oHtml:RetByName("NumTP") As Character    
 Local _cSolic    := _oProcess:oHtml:RetByName("Solicitante") As Character
 Local _dDtEmi    := _oProcess:oHtml:RetByName("DtEmissao") As Date
 Local _cAprNom   := _oProcess:oHtml:RetByName("Aprovador") As Character
 Local _cChaveTAP := _oProcess:oHtml:RetByName("cChaveTAP") As Character
 Local _cIDUserSol:= _oProcess:oHtml:RetByName("cIDUserSol") As Character
 Local _cIDUserApr:= _oProcess:oHtml:RetByName("cIDUserApr") As Character
 Local _cFilName  := _oProcess:oHtml:RetByName("Filial") As Character
 Local cTipoFrete := _oProcess:oHtml:RetByName("TipoFrete") As Character
 Local cCondPagto := _oProcess:oHtml:RetByName("CondPagto") As Character
 Local cDescMoeda := _oProcess:oHtml:RetByName("DescMoeda") As Character
 Local _cAIA_cObs := _oProcess:oHtml:RetByName("AIA_cObs") As Character
 Local _cObs      := AllTrim(_oProcess:oHtml:RetByName("TP_OBS")) As Character
 Local _cFilial   := LEFT(_cFilName,2) As Character
 Local _cHrLiber  := SubStr(Time(),1,5) As Character
 Local _cHostWF   := U_ItGetMv("IT_WFHOSTS","http://wfteste.italac.com.br:4034/") As Character
 Local _cEmail    := "" As Character
 Local _cAmbiente := UPPER(GETENVSERVER()) As Character
 Local _cAssunto  := "QUESTIONAMENTO da Aprovação Tabela de Preços, Filial " + _cFilName + " / Tabela: " + UPPER(ALLTRIM(_cNumTP)) As Character
 //Local I        := "" As Numeric
 
 
 _cAprNom:= UPPER(ALLTRIM(_cAprNom))
 _cNumTP := UPPER(ALLTRIM(_cNumTP))
 
 u_itconout("/////////////////   INCIO DA MCOM26Q   /////////////////////////////////////////////////////////////////////////////////")
 //===================================================================================================================================================================
 //INICIA A CRIACAO DO HTM DO BOTAO DO CORPO DO E-MAIL TP_SOLICITANTE_Q.htm
 //======================================================================
 _oProcess := TWFProcess():New("APRVTP",_cAssunto)
 _oProcess:NewTask("Aprovacao_TB", "\workflow\htm\tp_solicitante_q.htm")
 
 _cEmail := UsrRetMail(_cIDUserSol)
 
 //_cAviso := "QUESTIONADA"
 _cAvisoC:= "<font color= #0000FF  style='font-size: 12px; font-weight: bold;'>QUESTIONADA</font>"		// AZUL
 
 DBSELECTAREA("ZY2")
 _cNumQ := GetSxeNum("ZY2","ZY2_CODIGO")
 
 If Empty(_cPergPai)
    _cPergPai := _cNumQ//VARIAVEL É PRENCHIDA AQUI A PRIMEIRA VEZ DE CADA RODADA DE PERGUNTAS
 EndIf
 
 Reclock("ZY2", .T.)
 ZY2->ZY2_FILIAL := xFilial("ZY2")
 ZY2->ZY2_CODIGO := _cNumQ
 ZY2->ZY2_PEDIDO := _cChaveTAP
 ZY2->ZY2_FILPED := _cFilial
 ZY2->ZY2_NIVEL	 := "U"
 ZY2->ZY2_DATAM	 := Date()
 ZY2->ZY2_HORAM	 := TIME()
 ZY2->ZY2_WFID	 := _oProcess:fProcessId
 ZY2->ZY2_MENSAG := _cObs
 ZY2->ZY2_TIPO   := "P"
 ZY2->ZY2_USER   := _cIDUserApr//APROVADOR
 ZY2->ZY2_PAI    := _cPergPai
 ZY2->ZY2_ORIGEM := "TP"
 ZY2->( MsUnlock() )
 ConfirmSX8()
 
 //Variaveis que serão guardados no TP_SOLICITANTE_Q.HTM para serem usadas na funcao U_M026RET ()
 _oProcess:oHtml:ValByName("cChaveTAP" ,_cChaveTAP)
 _oProcess:oHtml:ValByName("cIDUserSol",_cIDUserSol)
 _oProcess:oHtml:ValByName("cPergPai"  ,_cPergPai)
 
 //_oProcess:oHtml:ValByName("A_SOLIC"	 , _cSolic     ) Não tem mais esses campos no TP_SOLICITANTE_Q.HTM por enquanto
 //_oProcess:oHtml:ValByName("Aprovacao" , _cAvisoC    )
 //_oProcess:oHtml:ValByName("AprNom"	 , _cAprNom    )
 //_oProcess:oHtml:ValByName("A_Data"	 , DTOC(DATE()))
 //_oProcess:oHtml:ValByName("A_Hora"	 , _cHrLiber   )
 
 _oProcess:oHtml:ValByName("Fornecedor" , _cForn)
 _oProcess:oHtml:ValByName("Filial"	    , _cFilName)
 _oProcess:oHtml:ValByName("NumTP"	    , _cNumTP)
 _oProcess:oHtml:ValByName("Vigencia"   , _cVigencia)
 _oProcess:oHtml:ValByName("Solicitante", _cSolic)
 _oProcess:oHtml:ValByName("DtEmissao"  , _dDtEmi)
 _oProcess:oHtml:ValByName("TipoFrete"  , cTipoFrete)
 _oProcess:oHtml:ValByName("CondPagto"  , cCondPagto)
 _oProcess:oHtml:ValByName("Aprovador"  , _cAprNom)
 _oProcess:oHtml:ValByName("DescMoeda"  , cDescMoeda)
 _oProcess:oHtml:ValByName("AIA_cObs"   , _cAIA_cObs)
 
 AIA->(DBGOTO(_nReAIA))
 
 AIB->(DBSETORDER(1))//AIB_FILIAL+AIB_CODFOR+AIB_LOJFOR+AIB_CODTAB+AIB_ITEM
 AIB->(DBSEEK(AIA->AIA_FILIAL+AIA->AIA_CODFOR+AIA->AIA_LOJFOR+AIA->AIA_CODTAB)) 
 
 DO While !AIB->(Eof()) .AND. AIB->AIB_FILIAL == AIA->AIA_FILIAL .AND.;
                              AIB->AIB_CODTAB == AIA->AIA_CODTAB .AND.;
              AIB->AIB_CODFOR+AIB->AIB_LOJFOR == AIA->AIA_CODFOR+AIA->AIA_LOJFOR
 
    cSimbMoeda:= "MV_SIMB"+AllTrim(Str(AIB->AIB_MOEDA))
    cSimbMoeda:= SuperGetMv(cSimbMoeda)
 
    AADD(_oProcess:oHtml:ValByName("Itens.Item"   ),AIB->AIB_ITEM)
    AADD(_oProcess:oHtml:ValByName("Itens.Produto"),AIB->AIB_CODPRO + " - " + Posicione("SB1",1,xFilial("SB1")+AIB->AIB_CODPRO,"B1_DESC"))
    AADD(_oProcess:oHtml:ValByName("Itens.Valor"  ),cSimbMoeda+" "+Transform(AIB->AIB_PRCCOM, PesqPict("AIB","AIB_PRCCOM")))
    AADD(_oProcess:oHtml:ValByName("Itens.PICMS"  ),Transform(AIB->AIB_I_PICM, PesqPict("AIB","AIB_I_PICM"))+" %")
    AADD(_oProcess:oHtml:ValByName("Itens.VICMS"  ),cSimbMoeda+" "+Transform(AIB->AIB_I_VICM, PesqPict("AIB","AIB_I_VICM")))
    
    AIB->(dbSkip())
 ENDDO
 
 //BUSCA OS QUESTIONAMENTOS ANTERIORES
 _cQuest:=M026Quest(_cFilial, AllTrim(_cChaveTAP),"TP",_cPergPai)
 If !Empty(_cQuest)
    _oProcess:oHtml:ValByName("cQuest",_cQuest )
 Else
    _oProcess:oHtml:ValByName("cQuest","" )
 EndIf
 
 _oProcess:oHtml:ValByName("A_RODAP",_cAmbiente)
 
 // Informe o nome da função de retorno a ser executada quando a mensagem de
 // respostas retornar ao Workflow:
 _oProcess:bReturn := "U_M026RET"//BOTÃO "RESPONDER" DO TP_SOLICITANTE_Q.HTM
 
 _cMailID := _oProcess:Start("\workflow\emp01")
 cLink := _cMailID
 If !File("\workflow\emp01\" + _cMailID + ".htm")
    u_itconout("01 - Arquivo TP_SOLICITANTE_Q:  \workflow\emp01\" + _cMailID + ".htm nao encontrado.")
 EndIf 
 
 //===================================================================================================================================================================
 //INICIA A CRIACAO DO HTM DO CORPO DO E-MAIL TP_LINK_Q.HTM
 //======================================================================
 _oProcess := TWFProcess():New("APRVTP",_cAssunto)
 // Criamos o link para o arquivo que foi gerado na tarefa anterior acima.  
 _oProcess:NewTask("LINK", "\workflow\htm\tp_link_q.htm")//CORPO DO EMAIL
 
 _cMV_WFMLBOX:= AllTrim(GetMV('MV_WFMLBOX'))
 chtmlfile := cLink + ".htm"
 cMailTo   := "mailto:" + Alltrim(Posicione("WF7", 1, XFilial("WF7") + _cMV_WFMLBOX, "WF7_ENDERE"))
 chtmltexto:= wfloadfile("\workflow\emp01\" + chtmlfile )//Carrega o arquivo 
 chtmltexto:= strtran( chtmltexto, cmailto, "WFHTTPRET.APL" )//Procura e troca a string
 wfsavefile("\workflow\emp"+cEmpAnt+"\" + chtmlfile, chtmltexto)//Grava o arquivo de volta
 cLink := _cHostWF + "emp01/" + cLink + ".htm"
 
 _oProcess:oHtml:ValByName("A_SOLIC"   , _cSolic)
 _oProcess:oHtml:ValByName("Aprovacao" , _cAvisoC)
 
 _oProcess:oHtml:ValByName("AprNom"	   , _cAprNom    )
 _oProcess:oHtml:ValByName("A_Data"	   , DTOC(DATE()))
 _oProcess:oHtml:ValByName("A_Hora"    , _cHrLiber   )
 _oProcess:oHtml:ValByName("Filial"    , _cFilName   )
 _oProcess:oHtml:ValByName("NumTP"     , _cNumTP     )
 _oProcess:oHtml:ValByName("Vigencia"  , _cVigencia  )
 _oProcess:oHtml:ValByName("Fornecedor", _cForn      )
 _oProcess:oHtml:ValByName("TipoFrete" , cTipoFrete  )
 _oProcess:oHtml:ValByName("CondPagto" , cCondPagto  )
 _oProcess:oHtml:ValByName("DescMoeda" , cDescMoeda  )
 _oProcess:oHtml:ValByName("AIA_cObs"  , _cAIA_cObs  )
 
 //Dados dos questionamentos
 If !Empty(_cQuest)
    _oProcess:oHtml:ValByName("cQuest",_cQuest )
 Else
    _oProcess:oHtml:ValByName("cQuest","" )
 EndIf
 
 _oProcess:oHtml:ValByName("A_LINK", cLink)//clique no corpo do email para chamar a TP_SOLICITANTE_Q.htm - BOTÃO "CLIQUE AQUI PARA RESPONDER O QUESTIONAMENTO"
 
 _oProcess:oHtml:ValByName("A_RODAP",_cAmbiente)
 
 // Informamos o destinatário (Solicitante) do email contendo o link.  
 _oProcess:cTo := Lower(_cEmail)
 
 //Caso precise enviar cópia no questionamento, descomentar abaixo
 //_xIDCopia := ALLTRIM(SuperGetMv("IT_IDCWFTP",,"000865"))+";"
 //_xIDCopia := U_ITTXTARRAY(_xIDCopia,";",0)
 //_cIDCopia := ""
 //FOR I := 1 TO LEN(_xIDCopia)
 //    If !Empty(_xIDCopia[I]) .And. !Lower(Alltrim(UsrRetMail(_xIDCopia[I]))) $ _cEmail
 //        _cIDCopia += Lower(Alltrim(UsrRetMail(_xIDCopia[I])))+";"
 //    EndIf
 //Next I
 //_cIDCopia:=SUBSTR(_cIDCopia,1,LEN(_cIDCopia)-1)
 //IF !Empty(_cIDCopia)
 //   _oProcess:cCC:= (_cIDCopia)
 //EndIf
 
 // Informamos o assunto do email.  
 _oProcess:cSubject	:= U_ITEncode(_cAssunto)
 
 U_ITWF1WF2Put("APRVTP",,"WFTP04","PERGUNTA DO QUESTIONAMENTO")//Grava WF2 a primeira vez se não existir  'N=Não Enviado;E=Enviado/Aguardando Aprovação;Q=Questionado;A=Aprovado;R-Rejeitado'
  //          cStatusCode, cDescription     , cUserName, uShape
 _oProcess:Track("WFTP04",_cAssunto,_cAprNom)
 
 //=======================================================
 // Iniciamos a tarefa e enviamos o email ao destinatário.
 //=======================================================
 _oProcess:Start() //ENVIA O E-MAIL
 _oProcess:Finish()
 
 u_itconout("/////////////////   FINAL DA MCOM26Q  - Email enviado para: " + Lower(Alltrim(_cEmail)) + " /////////////////////////////////////////////////////////////////////////////////")

Return


/*
===============================================================================================================================
Programa----------: M026RET
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2024
Descrição---------: Função criada para montar o retorno da chamada no botão "RESPONDER" DO TP_SOLICITANTE_Q.HTM
Parametros--------: _oProcess - Objeto do Processo de Questionamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
//Variaveis  guardados no TP_SOLICITANTE_Q.HTM 
//Para serem usadas aqui na funcao "U_M026RET" () DO botão RESPONDER DO TP_SOLICITANTE_Q.HTM
User Function M026RET(_oProcess As Object)
 Local _cFilName     := _oProcess:oHtml:RetByName("Filial") As Character
 Local _cNumTP	     := _oProcess:oHtml:RetByName("NumTP") As Character
 Local _cAprNom      := _oProcess:oHtml:RetByName("AprNom") As Character
 Local _cChaveTAP    := _oProcess:oHtml:RetByName("cChaveTAP") As Character
 Local _cIDUserSol   := _oProcess:oHtml:RetByName("cIDUserSol") As Character
 Local _cArqHtm	     := _oProcess:oHtml:RetByName("WFMAILID") As Character
 Local _cPergPai     := _oProcess:oHtml:RetByName("cPergPai") As Character
 Local _cObs         := ALLTRIM(_oProcess:oHtml:RetByName("TP_OBS")) As Character
 Local _cFilial      := LEFT(_cFilName,2) As Character
 Local _cAssunto     := "Retorno do QUESTIONAMENTO da Aprovação Tabela de Preços / Filial " + _cFilName + " / Tabela: " + UPPER(ALLTRIM(_cNumTP)) As Character
 Local _cHtmConcluido:= "\workflow\htm\tp_concluida.htm" As Character
 Local _cAmbiente    := UPPER(GETENVSERVER()) As Character
 
 _cArqHtm:= SUBSTR(_cArqHtm,3,Len(_cArqHtm))
 _cAprNom:= UPPER(ALLTRIM(_cAprNom))
 _cNumTP := UPPER(ALLTRIM(_cNumTP))
 _cObs   := ALLTRIM(_cObs)
 
 u_itconout("/////////////////   INCIO DA M026RET   /////////////////////////////////////////////////////////////////////////////////")
 
 U_ITWF1WF2Put("APRVTP",,"WFTP05","RESPOSTA DO QUESTIONAMENTO")//Grava WF2 a primeira vez se não existir  'N=Não Enviado;E=Enviado/Aguardando Aprovação;Q=Questionado;A=Aprovado;R-Rejeitado'
 //           cStatusCode, cDescription,cUserName, uShape
 _oProcess:Track("WFTP05",_cAssunto    ,_cAprNom)
 //Finalize a tarefa anterior para não ficar pendente
 _oProcess:Finish()
 
 DBSELECTAREA("ZY2")
 _cNumQ := GetSxeNum("ZY2","ZY2_CODIGO")
 If Empty(_cPergPai)
    _cPergPai := _cNumQ//VARIAVEL É PRENCHIDA AQUI A PRIMEIRA VEZ DE CADA RODADA DE PERGUNTAS
 EndIf
 ZY2->( Reclock("ZY2", .T.) )
 ZY2->ZY2_FILIAL := xFilial("ZY2")
 ZY2->ZY2_CODIGO := _cNumQ
 ZY2->ZY2_PEDIDO := _cChaveTAP
 ZY2->ZY2_FILPED := _cFilial
 ZY2->ZY2_NIVEL	 := "U"
 ZY2->ZY2_DATAM	 := Date()
 ZY2->ZY2_HORAM	 := TIME()
 ZY2->ZY2_WFID	 := _oProcess:fProcessId
 ZY2->ZY2_MENSAG := _cObs
 ZY2->ZY2_TIPO	 := "R"
 ZY2->ZY2_USER   := _cIDUserSol//SOLICITANTE
 ZY2->ZY2_PAI	 := _cPergPai
 ZY2->ZY2_ORIGEM := "TP"
 ZY2->( MsUnlock() )
 ConfirmSX8()
 
 AIA->(DBSETORDER(1))//AIA->(AIA_FILIAL+AIA_CODFOR+AIA_LOJFOR)
 _cAprova:=AIA->AIA_I_SITW
 IF AIA->(DbSeek(_cFilial+_cChaveTAP))
    IF AIA->AIA_I_SITW = "A" //'N=Não Enviado";E=Enviado;Q=QUESTIONADO;A=APROVADO;R-REJEITADO'
       _cObsConc:="O Processo do Aprovação de Tabela de Preços já foi APROVADO, sendo assim, sua resposta não será enviada!"
       _cAprova:="ERRO"
    ELSEIF AIA->AIA_I_SITW = "R"
       _cObsConc:="O Processo do Aprovação de Tabela de Preços já foi REPROVADO, sendo assim, sua resposta não será enviada!"
       _cAprova:="ERRO"
    ELSEIF AIA->AIA_I_SITW = "E"
       _cObsConc:="O Processo do Aprovação de Tabela de Preços já foi RESPONDIDO, sendo assim, sua resposta não será enviada!"
       _cAprova:="ERRO"
    ENDIF
 ELSE
    _cAprova:="ERRO"
    _cObsConc:= "Tabela de preços: "+_cFilial+_cChaveTAP+" não foi encontrada no cadastro (AIA), sendo assim, sua resposta não será enviada!"
 ENDIF
 
 IF !(_cAprova == "ERRO")//IF AIA->AIA_I_SITW = "Q" // RESPOSTA DO SOLICITANTE DO QUESTINAMENTO FEITO PELO APROVADOR
    _cObsConc:="O Processo do Aprovação de Tabela de Preços já foi RESPONDIDO!"//Para gravar no \workflow\htm\tp_concluida.htm abaixo
 Else //IF _cAprova == "ERRO"
    //Alterando o conteudo do WFPE007.PRW - LINK DE CLIQUE DO BOTOES DO HTML
    _cObsConc:= "Houve um problema na hora do QUESTIONAMENTO:<br>"+_cObsConc+"<br>"
    chtmlfile  := "\workflow\emp01\" + _cArqHtm + ".Erro"
    MemoWrite(chtmlfile,_cObsConc)
    If File(chtmlfile)
       u_itconout('WF-Arq do Erro.........: ' + chtmlfile ) 
    ELSE
       u_itconout('Nao tem WF-Arq do Erro.: ' + chtmlfile ) 
    ENDIF
    u_itconout('Obs do WF-Arq do Erro..: ' + _cObsConc ) 
 EndIf
 
 //FAZ A CÓPIA DO ARQUIVO DE APROVAÇÃO PARA .OLD, E CRIA O ARQUIVO DE PROCESSO JÁ CONCLUÍDO
 //         Origem        ,Destino
 IF MEST26Copy(_cHtmConcluido,_cArqHtm,@_cObsConc)
    //Alterando o conteudo do \workflow\htm\tp_concluida.htm - LINK DE CLIQUE DO E-MAIL 
    chtmlfile  := "\workflow\emp01\" + _cArqHtm + ".htm"
    chtmltexto := wfloadfile( chtmlfile )
    chtmltexto := strtran( chtmltexto, "!A_MSG!"  , _cObsConc)
    chtmltexto := strtran( chtmltexto, "!A_RODAP!", _cAmbiente)
    WFSAVEFILE( chtmlfile , chtmltexto)
 Else
    _cAprova := "ERRO"
    chtmlfile:= "\workflow\emp01\" + _cArqHtm + ".Erro"
    MemoWrite(chtmlfile,_cObsConc)
 Endif
 
 // ENVIO DA RESPOSTA DO SOLICITANTE DO QUESTINAMENTO FEITO PELO APROVADOR
 IF !(_cAprova == "ERRO")//IF AIA->AIA_I_SITW = "Q" 
    //CHAMADO O ENVIO DE NOVO AQUI PARA COMEÇAR TUDO DE NOVO PQ NÃO TEM SCHEDULE / GRAVA AIA->AIA_I_SITW := "E"
    U_MCOM026E(AIA->(RECNO()),_cPergPai,_cIDUserSol)
 ENDIF
 
 u_itconout("/////////////////   FINAL DA M026RET - _cAprova: "+_cAprova+"  /////////////////////////////////////////////////////////////////////////////////")

Return

/*
===============================================================================================================================
Programa----------: M026Quest
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2024
Descrição---------: Função criada para montar os questionamentos
Parametros--------: _cFilAIA, _cChaveAIA, _cOrigem, _cPergPai
Retorno-----------: _cRet - Retorna a tabela HTML com os questionamentos
===============================================================================================================================
*/
STATIC Function M026Quest(_cFilAIA As Character, _cChaveAIA As Character, _cOrigem As Character, _cPergPai As Character) As Character
 Local _cRet   := "" As Character
 Local _cQryZY2:= "" As Character
 Local _cNomUsr:= "" As Character
 Local _cAlias := GetNextAlias() As Character
 
 _cQryZY2 := "SELECT R_E_C_N_O_ ZY2_RECNO "
 _cQryZY2 += "FROM " + RetSqlName("ZY2") + " "
 _cQryZY2 += "WHERE ZY2_FILPED = '" + _cFilAIA + "' "
 _cQryZY2 += "  AND ZY2_PEDIDO = '" + _cChaveAIA + "' "
 _cQryZY2 += "  AND ZY2_ORIGEM = '" + _cOrigem + "' "
 IF !EMPTY(_cPergPai)
    _cQryZY2 += "  AND ZY2_PAI    = '" + _cPergPai + "' "
 ENDIF
 _cQryZY2 += "  AND D_E_L_E_T_ = ' ' "
 _cQryZY2 += "ORDER BY ZY2_DATAM , ZY2_HORAM "
 
 MPSysOpenQuery( _cQryZY2 , _cAlias )
 
 (_cAlias)->(dbGoTop())
 
 If !(_cAlias)->(Eof())
 
    _cRet := "<table width='100%' class='bordasimples' cellpadding='0' cellspacing='0'> "
    _cRet += "	<tr width='100%'> "
    _cRet += "		<td align='center' BGCOLOR=#7f99b2 colspan='2'><font color= #F2FBEF  style='font-size: 16px; font-weight: bold;'>Questionamentos</font></td> "
    _cRet += "	</tr> "
 
    DO WHILE !(_cAlias)->(Eof())
 
       ZY2->(dbGoTo((_cAlias)->ZY2_RECNO))
       IF EMPTY(ZY2->ZY2_MENSAG)//Não dá para usar esse campo na SELECT: dá o erro : 932 - ORA-00932: inconsistent datatypes: expected - got BLOB
          (_cAlias)->(dbSkip())   
          LOOP
       ENDIF
       _cNomUsr := UPPER(ALLTRIM(UsrFullName( ZY2->ZY2_USER )))
       _cNomUsr := SUBSTR(_cNomUsr, 1, At(" ", _cNomUsr)-1)
       _cPergPai:=ZY2->ZY2_PAI//Quando a variavel _cPergPai vir em branco carrega a variavel _cPergPai com que que achar - REENVIO POR EXEMPLO
 
       _cRet += "	<tr> "
       If ZY2->ZY2_TIPO == "E"             //AZUL                      //VERMELHO
          _cRet += "		<td width='25%' BGCOLOR=#4169E1><font color= #FF0000  style='font-size: 16px; font-weight: bold;'>Mensagem de Erro na Rejeicao:</font></td> "
       ELSEIf ZY2->ZY2_TIPO == "P"         //AZUL                      //AMARELO
          _cRet += "		<td width='25%' BGCOLOR=#4169E1><font color= #FFFF00  style='font-size: 16px; font-weight: bold;'>Pergunta de " + _cNomUsr + ":</font></td> "
       Else                                //AZUL                      //BRANCO
          _cRet += "		<td width='25%' BGCOLOR=#4169E1><font color= #F2FBEF  style='font-size: 16px; font-weight: bold;'>Resposta de " + _cNomUsr + ":</font></td> "
       EndIf
       _cRet += "		<td width='75%'>(" + DtoC(ZY2->ZY2_DATAM) + " - " + ZY2->ZY2_HORAM + ") " + AllTrim(ZY2->ZY2_MENSAG) + "</td> "
       _cRet += "	</tr> "
 
       (_cAlias)->(dbSkip())
    ENDDO
 
    _cRet += "</table> "
    _cRet += "<br> "
 
 EndIf
 
 (_cAlias)->(dbCloseArea())

Return(_cRet)

/*
===============================================================================================================================
Programa----------: M026Num
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2024
Descrição---------: Função de numeracao do codigo da tabela de preços por filial + Fornecedor + Loja 
Parametros--------: _lLimpa = .F. : Gatilho dos campos AIA_CODFOR (3) / AIA_LOJFOR (2)
                    _lLimpa = .T. : X3_VALID dos campos AIA_CODFOR / AIA_LOJFOR
                    _lValidUser = .T. : X3_VLDUSER dos campos AIA_CODFOR / AIA_LOJFOR
Retorno-----------: M->AIA_CODTAB
===============================================================================================================================
*/
USER Function M026Num(_lLimpa As Logical, _lValidUser As Logical) As Char
 LOCAL aAreaAux := FwGetArea() As Array
 LOCAL cAliasAux:= "" As Character
 LOCAL _cNum    := "" As Character
 LOCAL cQuery   := "" As Character
 LOCAL _cEstado := "" As Character
 LOCAL C        := 00 As Numeric

 Default _lValidUser := .F.
 
 //Chamado do X3_VLDUSER do AIA_LOJFOR e AIA_CODFOR e AIB_I_PICM
 IF _lValidUser
    IF !EMPTY(M->AIA_CODFOR) .AND. !EMPTY(M->AIA_LOJFOR)
       _cEstado := POSICIONE("SA2",1,xFilial("SA2")+M->AIA_CODFOR+M->AIA_LOJFOR,"A2_EST")
       nPosPrec := aScan(aHeader,{|x| AllTrim(x[2]) == "AIB_PRCCOM"})
       nPosPICM := aScan(aHeader,{|x| AllTrim(x[2]) == "AIB_I_PICM"})
       nPosVICM := aScan(aHeader,{|x| AllTrim(x[2]) == "AIB_I_VICM"})
       IF !EMPTY(_cEstado) .AND. nPosPICM > 0  .AND. nPosVICM > 0 
          _cCampo:= ReadVar()
          IF _cCampo == "M->AIB_PRCCOM"
             IF EMPTY(aCols[N][nPosPICM])
                aCols[N][nPosPICM] := U_BuscaPICMS(_cEstado)
             EndIF
             aCols[N][nPosVICM] := M->AIB_PRCCOM * aCols[N][nPosPICM] / 100
          ElseIF _cCampo == "M->AIB_I_PICM"
             aCols[N][nPosVICM] := aCols[N][nPosPrec] * M->AIB_I_PICM / 100
          Else
             aCols:=oGetDad:aCols//oGetDad: Objeto do gride criado private no Programa da totvs COMA010.PRX
             For C := 1 TO Len(aCols) 
                 If aCols[C][nPosPrec] > 0 
                    aCols[C][nPosPICM] := U_BuscaPICMS(_cEstado)
                    aCols[C][nPosVICM] := aCols[C][nPosPrec] * aCols[C][nPosPICM] / 100
                 Endif
             Next C
             oGetDad:aCols:=aCols//oGetDad: Objeto do gride criado private no Programa da totvs COMA010.PRX
             oGetDad:oBrowse:Refresh()
             oGetDad:Refresh()
          EndIf
       EndIF
    ENDIF
    FwRestArea(aAreaAux)
    RETURN .T.
 ENDIF
 
 //Chamado do X3_VALID do AIA_LOJFOR e AIA_CODFOR
 IF _lLimpa
    M->AIA_CODTAB:=SPACE(LEN(AIA->AIA_CODTAB))
    FwRestArea(aAreaAux)
    RETURN .T.
 ENDIF
 
 //Chamado dos Gatilho dos campos AIA_CODFOR (3) e AIA_LOJFOR (2)
 cQuery := "SELECT MAX(AIA.AIA_CODTAB) AIA_CODTAB " 
 cQuery += "  FROM " + RetSqlName( "AIA" ) + " AIA "
 cQuery += " WHERE AIA.AIA_FILIAL = '" + xFilial( 'AIA' ) + "'"
 cQuery += "   AND AIA.AIA_CODFOR = '"+M->AIA_CODFOR+"' "
 cQuery += "   AND AIA.AIA_LOJFOR = '"+M->AIA_LOJFOR+"' "
 cQuery += "   AND AIA.D_E_L_E_T_ = ' '"
 
 cAliasAux:= GetNextAlias()
          
 MPSysOpenQuery( cQuery , cAliasAux)

 _cNum:=STRZERO(1,LEN(AIA->AIA_CODTAB))

 IF Select( cAliasAux ) > 0
    If !Empty( (cAliasAux)->AIA_CODTAB )
       _cNum := Soma1( (cAliasAux)->AIA_CODTAB )
    Endif
    DbSelectArea(cAliasAux)
    DbCloseArea()
 Endif
 
 M->AIA_CODTAB:=_cNum

FwRestArea(aAreaAux)
 
RETURN M->AIA_CODTAB

/*
===============================================================================================================================
/*
===============================================================================================================================
Programa----------: BuscaPICMS
Autor-------------: Alex Wallauer
Data da Criacao---: 05/03/2025
Descrição---------: Função para obter a alíquota de ICMS de acordo com a UF
Parametros--------: _cUF = Código da Unidade Federativa (UF)
Retorno-----------: Alíquota de ICMS como numérico
===============================================================================================================================
*/
USER Function BuscaPICMS(_cUF As Char) As Numeric
 Local _nAliqICMS := 0 As Numeric
 Local _cMV_ESTICM:= SuperGetMv("MV_ESTICM") As Char
 Local nPos := 1 As Numeric
 Local cUF As Char
 
 IF (nPos := AT(_cUF,_cMV_ESTICM)) > 0
    cUF := SubStr(_cMV_ESTICM, nPos, 2)
    nPos += 2
    If SubStr(_cMV_ESTICM, nPos + 2, 1) == "."
       _nAliqICMS:= Val( SubStr(_cMV_ESTICM, nPos, 5) )
    Else
       _nAliqICMS:= Val( SubStr(_cMV_ESTICM, nPos, 2) )
    EndIf
 EndIf
Return _nAliqICMS
