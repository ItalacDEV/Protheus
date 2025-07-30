/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |07/05/2025| Chamado 50617. Corrigir chamada estática no nome das tabelas do sistema
Lucas Borges  |24/07/2025| Chamado 51340. Ajustar função para validação de ambiente de teste
===============================================================================================================================
 Analista     - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
======================================================================================================================================================================================================
 Andre        - Alex Wallauer - 16/04/25 - 23/04/25 - 50140   - Validacao de uma viagem filha esta em uma viagem de outra mãe. Esta em 2 mãe (julieta).
 Lucas        - Alex Wallauer - 02/05/25 - 06/05/25 - 50525   - Ajuste para remoção de diretório local C:\SMARTCLIENT\.
=====================================================================================================================================================================================================
*/

#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'XMLXFUN.ch'
#Include 'FileIO.ch'
#include "APWEBSRV.CH"  
#include "TBICODE.CH"

/*
===============================================================================================================================
Programa----------: MGLT002
Autor-------------: Alexandre Villar
Data da Criacao---: 12/11/2015
Descrição---------: Rotina de busca dos dados dos atendimentos no SmartQuestion
Parametros--------: _cDtIni   - Data inicial
                    _cDtFim   - Data final
                    _lLocShedule - Não mostra barra de progresso 
                    _oProcess - Objeto da regua 
                    _lEnd     - Variavel do botao cancela 
Retorno-----------: .T. se integrou .F. se nao integrou nada
===============================================================================================================================
*/
User Function MGLT002( _dDtini, _dDtfim, _lLocShedule, _oProcess, _lEnd )//Chamar no Schedule assim U_MGLT002()

Local _aXml			:= {}
Local _aDadAtd		:= {}
Local _oXml			:= Nil
Local _lExecInt	:= .F.
Local _nI			:= 0,_nMi,_nHr,_nAsc,_nXml,T,S,nHr,_nF,_nLog,F
Local _nX			:= 0
Local _nFoM       := 0 //Filha de outra mãe 
Local _nKm			:= 0
Local _cKmOri     := ""
Local _nPesIni		:= 0
Local _nPesFim		:= 0
Local _nMedVaz		:= 0
Local _cHrIni		:= ''
Local _cHrFim		:= ''
Local _cURL	  		:= ''
Local _cRecusa	    := ''
Local _cMotivo      := ''
Local _cErro		:= ''
Local _cWarning		:= ''
Local _lDescarte	:= .F.
Local cAliasWK      := "TRB_ZLJ"
Local aSemSX3       := {}
Local _dDtMV_ULMES  := ""
Private _aHdrOut	:= {	'POST https://italac.smartquestion.com.br/ws/WsSmartQuestionV9 HTTP/1.1'				,;//Ambiente de Produção
							'Accept-Encoding: gzip,deflate'																		,;
							'Content-Type: text/xml;charset=UTF-8'																,;
							'SOAPAction: ""'																					,;
							'Host: italac.smartquestion.com.br'																	,;
							'Connection: Keep-Alive'																			,;
							'User-Agent: Mozilla/4.0 (compatible; Protheus 7.00.111010P-20120120; ADVPL WSDL Client 1.111215)'	 }


Default _lLocShedule:= .T. 
Private _lShedule:= _lLocShedule

If !_lShedule

   _oProcess:SetRegua1(0)
   _oProcess:IncRegua1("Baixando dados do smartquestion...")
   _lValData:=.F.
   _cZLJ_UINTSQ := ALLTRIM(UsrFullName(__cUserID))

Else

    _cTimeInicial :=TIME()
    _cFiltroFilial:=""
    
    U_ITConOut("Iniciando ambiente do SCHEDULE_WF_SMARTQUESTION...")

	RPCSetType(2) // RPCSetType(3)
	RpcSetEnv( "01" , "01" ,,,"ESP2", "SCHEDULE_WF_SMARTQUESTION" , {'ZLJ','SA2','ZL2','ZLT','ZLS'} )
	Sleep( 5000 ) //Aguarda 5 segundos para subam as configurações do ambiente.

    _cTransI := _cTransF := Space(LEN(ZLJ->ZLJ_CODPAT))
    _cTraLoI := _cTraLoF := Space(LEN(ZLJ->ZLJ_LOJPAT))
    _cSetorI := _cSetorF := Space(LEN(ZLJ->ZLJ_SETOR ))
    _cLinhaI := _cLinhaF := Space(LEN(ZLJ->ZLJ_LINROT))
    cUsuario := SPACE(06)+"Administrador  "
    cUsername:= "Schedule"
    _cZLJ_UINTSQ := "SCHEDULE"//"AGENDADO / AUTOMATICO"
    _dDtini  := DATE()
    _dDtfim  := DATE()
    _lEnd    := .F.
    _cHoraI  := ""
    _cHoraF  := ""
    _lValData:=.T.
EndIf

Private _aLog  := {}
Private cMarca :=GetMark()
Private aCampos:=ARRAY( ZLJ->(Fcount()) )
Private _lIDESENV:=SuperGetMV("IT_AMBTEST",.F.,.T.)

AADD(aSemSX3,{"WK_DATA"   ,"D",08,0})
AADD(aSemSX3,{"WK_HORA"   ,"C",08,0})
AADD(aSemSX3,{"ZLJ_FILIAL","C",02,0})
AADD(aSemSX3,{"WKREC_ZLJ" ,"N",10,0})
AADD(aSemSX3,{"WK_MARCA"  ,"C",02,0})

AADD(aSemSX3,{"ZLJ_TIPPRO","C",1,0})
AADD(aSemSX3,{"ZLJ_SETOR","C",6,0})
AADD(aSemSX3,{"ZLJ_LINROT","C",6,0})
AADD(aSemSX3,{"ZLJ_LINHSQ","C",6,0})
AADD(aSemSX3,{"ZLJ_VIAGEM","C",10,0})
AADD(aSemSX3,{"ZLJ_NUMERO","C",10,0})
AADD(aSemSX3,{"ZLJ_NSETOR","C",10,0})
AADD(aSemSX3,{"ZLJ_NLINRO","C",10,0})
AADD(aSemSX3,{"ZLJ_CODPAT","C",6,0})
AADD(aSemSX3,{"ZLJ_LOJPAT","C",4,0})
AADD(aSemSX3,{"ZLJ_NOMPAT","C",15,0})
AADD(aSemSX3,{"ZLJ_TIPVIS","C",1,0})
AADD(aSemSX3,{"ZLJ_DTIVIA","D",8,0})
AADD(aSemSX3,{"ZLJ_DTFVIA","D",8,0})
AADD(aSemSX3,{"ZLJ_DTCRIA","D",8,0})
AADD(aSemSX3,{"ZLJ_STATUS","C",1,0})
AADD(aSemSX3,{"ZLJ_DESCAR","L",1,0})
AADD(aSemSX3,{"ZLJ_VOLUME","N",9,2})
AADD(aSemSX3,{"ZLJ_CODTRN","C",6,0})
AADD(aSemSX3,{"ZLJ_LOJTRN","C",4,0})
AADD(aSemSX3,{"ZLJ_DTRAN","C",100,0})
AADD(aSemSX3,{"ZLJ_KMDVIA","N",18,0})
AADD(aSemSX3,{"ZLJ_TEMPER","N",18,8})
AADD(aSemSX3,{"ZLJ_PLACA","C",7,0})
AADD(aSemSX3,{"ZLJ_VOLREA","N",18,0})
AADD(aSemSX3,{"ZLJ_VOLCOL","N",18,0})
AADD(aSemSX3,{"ZLJ_HRIVIA","C",8,0})
AADD(aSemSX3,{"ZLJ_HRFVIA","C",8,0})
AADD(aSemSX3,{"ZLJ_MOTIVO","C",250,0})
AADD(aSemSX3,{"ZLJ_LITRAG","N",18,0})
AADD(aSemSX3,{"ZLJ_DMOTOR","C",100,0})
AADD(aSemSX3,{"ZLJ_PSIVIA","N",18,0})
AADD(aSemSX3,{"ZLJ_PSFVIA","N",18,0})
AADD(aSemSX3,{"ZLJ_VEICUL","C",6,0})
AADD(aSemSX3,{"ZLJ_MOTORI","C",6,0})
AADD(aSemSX3,{"ZLJ_AMOSTR","C",9,0})
AADD(aSemSX3,{"ZLJ_ALIZAR","C",1,0})
AADD(aSemSX3,{"ZLJ_BOCA","C",3,0})
AADD(aSemSX3,{"ZLJ_REGZLX","N",9,0})
AADD(aSemSX3,{"ZLJ_HRCRIA","C",8,0})
AADD(aSemSX3,{"ZLJ_DTINI","D",8,0})
AADD(aSemSX3,{"ZLJ_HRINI","C",8,0})
AADD(aSemSX3,{"ZLJ_REGUA","N",9,2})
AADD(aSemSX3,{"ZLJ_DTFIM","D",8,0})
AADD(aSemSX3,{"ZLJ_HRFIM","C",8,0})
AADD(aSemSX3,{"ZLJ_UEFET","C",50,0})
AADD(aSemSX3,{"ZLJ_DIFER","N",18,0})
AADD(aSemSX3,{"ZLJ_DEFET","D",8,0})
AADD(aSemSX3,{"ZLJ_HREFET","C",20,0})
AADD(aSemSX3,{"ZLJ_USRSMQ","C",6,0})
AADD(aSemSX3,{"ZLJ_LOGINS","C",40,0})
AADD(aSemSX3,{"ZLJ_DIFER2","N",9,0})
AADD(aSemSX3,{"ZLJ_VOLCOO","N",18,0})
AADD(aSemSX3,{"ZLJ_UINTSQ","C",50,0})
AADD(aSemSX3,{"ZLJ_DINTSQ","D",8,0})
AADD(aSemSX3,{"ZLJ_HINTSQ","C",8,0})
AADD(aSemSX3,{"ZLJ_VFILHA","C",10,0})
AADD(aSemSX3,{"ZLJ_VFILHS","C",250,0})
AADD(aSemSX3,{"ZLJ_KM_SQO","C",20,0})


_otemp := FWTemporaryTable():New( cAliasWK, aSemSX3 )
_otemp:AddIndex( "01", {"WK_DATA","WK_HORA","ZLJ_FILIAL","ZLJ_VIAGEM","ZLJ_NUMERO","ZLJ_SETOR","ZLJ_LINROT"} )
_otemp:AddIndex( "02", {"ZLJ_FILIAL","ZLJ_VIAGEM","ZLJ_NUMERO","ZLJ_SETOR","ZLJ_LINROT"})

_otemp:Create()


//====================================================================================================
// Leitura inicial dos parâmetros
//====================================================================================================
_cURL		:= SuperGetMV("LT_WSS_URL",.F.,"italac.smartquestion.com.br")//italac.smartquestion.com.br/ws/WsSmartQuestionV9?wsdl
_cWS		:= SuperGetMV("LT_WSS_END",.F.,"italac.smartquestion.com.br/ws/WsSmartQuestionV14NoMtom?wsdl")//http://italac.smartquestion.com.br/ws/WsSmartQuestionV13?wsdl
_lExecInt	:= SuperGetMV("LT_INT_SMQ",.F.,.T.)//http://italac.smartquestion.com.br/ws/WsSmartQuestionV14?wsdl
_cMetodo	:= 'GET_ATENDIM'
_lVersaoNew := "14" $ _cWS

//====================================================================================================
// Monta a estrutura de dados do arquivo
//====================================================================================================
_cXmlAux1 := U_GLTSQXML( 1 , _cMetodo )//AQUI ABRE AS TAGs DO XML
_cXmlAux2 := '<carregarAtendimentos>true</carregarAtendimentos>'	+CRLF
_cXmlAux2 += '<apenasConcluidos>false</apenasConcluidos>'			+CRLF
_cXmlAux2 += '<listaStatus>CONFERIDO</listaStatus>'					+CRLF
_cXmlAux2 += '<listaCodigoTipoVisita>COLETA</listaCodigoTipoVisita>'+CRLF
_cXmlAux2 += '<listaCodigoTipoVisita>REC</listaCodigoTipoVisita>'   +CRLF

//====================================================================================================
// Define filtros de data/hora de acordo com a parametrização do sistema
//====================================================================================================
_cHoraLeu:=""
_nDias  := 0
_aXmlDia:= {} 
_cDiasT := _dDtfim-_dDtini+1
If !_lShedule
   _oProcess:SetRegua1(_cDiasT)
EndIf
_cDiasT := ALLTRIM(STR(_cDiasT,10))

aHoras:={}
_nHoraIni:=VAL(TIME())//Pega ate os : (2 pontos)
_nHoraIni:=If(_nHoraIni>2,_nHoraIni-1,0)
_nHorafim:=VAL(TIME())//Pega ate os : (2 pontos)
If !Empty(_cHoraI) 
   _nHoraIni:=VAL(_cHoraI)
EndIf
If !Empty(_cHoraF) 
   _nHorafim:=VAL(_cHoraF)
EndIf

For _nHr := _nHoraIni to _nHorafim

    _cHr := STRZERO(_nHr,2)

    For _nMi := 0 to 5

       _cMi := STRZERO(_nMi,1)

       AADD(aHoras,{"T"+_cHr+":"+_cMi+"0:00","T"+_cHr+":"+_cMi+"1:00"})// EM 01 E 01 MINUTOS
       AADD(aHoras,{"T"+_cHr+":"+_cMi+"1:00","T"+_cHr+":"+_cMi+"2:00"})// EM 01 E 01 MINUTOS
       AADD(aHoras,{"T"+_cHr+":"+_cMi+"2:00","T"+_cHr+":"+_cMi+"3:00"})// EM 01 E 01 MINUTOS
       AADD(aHoras,{"T"+_cHr+":"+_cMi+"3:00","T"+_cHr+":"+_cMi+"4:00"})// EM 01 E 01 MINUTOS
       AADD(aHoras,{"T"+_cHr+":"+_cMi+"4:00","T"+_cHr+":"+_cMi+"5:00"})// EM 01 E 01 MINUTOS
       AADD(aHoras,{"T"+_cHr+":"+_cMi+"5:00","T"+_cHr+":"+_cMi+"6:00"})// EM 01 E 01 MINUTOS
       AADD(aHoras,{"T"+_cHr+":"+_cMi+"6:00","T"+_cHr+":"+_cMi+"7:00"})// EM 01 E 01 MINUTOS
       AADD(aHoras,{"T"+_cHr+":"+_cMi+"7:00","T"+_cHr+":"+_cMi+"8:00"})// EM 01 E 01 MINUTOS
       AADD(aHoras,{"T"+_cHr+":"+_cMi+"8:00","T"+_cHr+":"+_cMi+"9:00"})// EM 01 E 01 MINUTOS
       AADD(aHoras,{"T"+_cHr+":"+_cMi+"9:00","T"+_cHr+":"+_cMi+"9:59"})// EM 01 E 01 MINUTOS
       
    Next   

Next
_cViagIgoradas:=""
//_bSetor := { || .T. }
_cFilter:="Todos"
U_ITConOut("1-Lendo de "+DTOC(_dDtini)+" ate "+DTOC(_dDtfim)+" das "+STR(_nHoraIni,2)+" ate "+STR(_nHorafim,2))

DO While _dDtini <=  _dDtfim

   If !_lShedule
      _nDias++
      _oProcess:IncRegua1("1-SQ V"+If(_lVersaoNew,"14","9")+" Lendo dia: "+DTOC(_dDtini)+" - "+ALLTRIM(STR(_nDias,10))+" de "+_cDiasT+" dias..." )
      _oProcess:SetRegua2(LEN(aHoras))
   EndIf
  
   For nHr:= 1 TO LEN(aHoras)
       If !_lShedule
          _cMenaux:=STRTRAN("Lendo Hora "+aHoras[nHr,1]+" de "+aHoras[nHr,2]+", Dados Lidos: "+AllTrim(STR(Len(_aXmlDia))),"T","" )
          _oProcess:IncRegua2(_cMenaux)
       EndIf

       If !MGLT002BuscaSQ(_dDtini,_dDtfim,aHoras[nHr,1],aHoras[nHr,2],_lShedule)
          Exit
       EndIf

       If _lEnd//houve cancelamento do processo
          Exit
       EndIf
   Next

   If _lEnd//houve cancelamento do processo			
      MsgInfo("Processamento Cancelado pelo usuario com Sucesso.","MGLT00201")
      If(SELECT(cAliasWK) # 0,_otemp:delete(),)
      Return .F.	
   EndIf	      	

   _dDtini++

EndDo

_nRecusado:=0
_nConta:=0
SM0->(DBSetOrder(1))
SA2->(DBSetOrder(1))
ZL0->(DBSetOrder(1))

_nXml := 1
_aXmlReboque := {}
_aTemRecepcao:= {}
_aTaNoMixAtual:={}
IF !_lIDESENV
   _cNomeLog:="\data\tmp\mglt002_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+"_erro.xml"
Else
   _cNomeLog:=ALLTRIM(GetTempPath())+"mglt002_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+"_erro.xml"
Endif
If !_lShedule
    _oProcess:SetRegua1(Len(_aXmlDia))
EndIf
U_ITConOut("2-Lendo "+ALLTRIM(STR(LEN(_aXmlDia)))+" registros... ")

For _nXml := 1 TO LEN(_aXmlDia)

    If _lEnd			//houve cancelamento do processo			
       MsgInfo("Processamento Cancelado pelo usuario com Sucesso.","MGLT00202")
       If(SELECT(cAliasWK) # 0,_otemp:delete(),)
       // ------------------------------------------------------------------------------------------ //
       // Limpa o Objeto: _oXML Conforme orientado pelo Framework
       // ------------------------------------------------------------------------------------------ //
       _oXML:=Nil
       DelClassIntf()
       Return .F.	
    EndIf	      	

    _cDataLendo:=DTOC(_aXmlDia[_nXml,1])

    If !_lShedule
       _oProcess:IncRegua1("2-Lendo Dia - Hora: "+_cDataLendo+" - "+_aXmlDia[_nXml,5] )
    ElseIf _lIDESENV
    	U_ITConOut("2-Lendo Dia - Hora: "+_cDataLendo+" - "+_aXmlDia[_nXml,5])
    EndIf
    
    _cErro:=""
    _aXml := {}
    _lErroXmlParser:=.F.

    // ------------------------------------------------------------------------------------------ //
    // Limpa o Objeto: _oXML Conforme orientado pelo Framework, se faz necessário a utilização    //
    // do DesClassIntf para que o Objeto realmente seje limpo.                                    //
    // Caso contrário, em situações onde existir um grande numero de XMLS Parseados, ocorrera a   //
    // mensagem: XML dynamic Nodes Overflow                                                       //
    // Antes de executar o comando: DesClassIntf, coloque o objeto como NIL                       //
    // ------------------------------------------------------------------------------------------ //
    _oXML:=Nil
    If LEN(_aXmlReboque) = 0
       DelClassIntf()
    EndIf   
// ------------------------------------------------------------------------------------------ //

   _oXml := MGLT2XmlParser(_aXmlDia[_nXml,2] , "_" , @_cErro , @_cWarning , '1/3-Erro ao ler o XML do PERIODO: '+_aXmlDia[_nXml,3]+" ate "+_aXmlDia[_nXml,4] )

   If !_lErroXmlParser .AND. (!Empty(_cErro) .OR. ValType(_oXml) = 'U')//Tratamento de caracter extendido

      _aXmlDia[_nXml,2] := MGLT002C(_aXmlDia[_nXml,2])//Tira caracter extendido que dá erro de UTF
      _oXml := MGLT2XmlParser(_aXmlDia[_nXml,2] , "_" , @_cErro , @_cWarning , '2/3-Erro ao ler o XML do PERIODO: '+_aXmlDia[_nXml,3]+" ate "+_aXmlDia[_nXml,4])

   EndIf

    If !_lErroXmlParser .AND. (!Empty(_cErro) .OR. ValType(_oXml) = 'U')//Tira a observaçõe pq elas são abertas para digitar qq coisa
 
       _nAscI:=1
       nConta:=0
       DO While _nAscI > 0
          
          _nAscI:=AT("<observacao>" , _aXmlDia[_nXml,2] ) 
          If _nAscI > 0
             _nAscF:=AT("</observacao>", _aXmlDia[_nXml,2] ) 
             If _nAscF > 0
                _nDel:=(_nAscF-_nAscI)+LEN("</observacao>")//Tamanho do conteudo mais "<observacao></observacao>"
                _aXmlDia[_nXml,2] := STUFF(_aXmlDia[_nXml,2],_nAscI, _nDel ,"" )
             EndIf
          EndIf
          nConta++
          If nConta > 1000//Para previnir loop infinito
             Exit
          EndIf

       EndDo
 
 	   _oXml := MGLT2XmlParser(_aXmlDia[_nXml,2] , "_" , @_cErro , @_cWarning , '3/3-Erro ao ler o XML do PERIODO: '+_aXmlDia[_nXml,3]+" ate "+_aXmlDia[_nXml,4])

    EndIf   

    If !Empty(_cErro) .OR. ValType(_oXml) = 'U'//Se mesmo com os tramentos acima não dá certo dá mensagem

        If ValType(_oXml) = 'U'
          _cErro:=ALLTRIM(_cErro)+" ] [ Sem retorno (NIL)"
       EndIf
       
       _cPosAsc:=""       
       _cLetAsc:=""       
       For _nAsc := 1 TO LEN(_aXmlDia[_nXml,2])
           _cLetra:=ALLTRIM(SUBSTR(_aXmlDia[_nXml,2] ,_nAsc , 1))
           If !Empty(_cLetra) .AND. ASC(_cLetra) < 34 .OR. ASC(_cLetra) > 125
              If Empty(_cLetAsc)//Para pegar só a primeira posição
                 _cPosAsc:=ALLTRIM(STR(_nAsc))
              EndIf
              _cLetAsc+=_cLetra
           EndIf
       Next

       MemoWrite(_cNomeLog,_aXmlDia[_nXml,2])

       PRIVATE _cProcura:=_aXmlDia[_nXml,2]
       _cConteudo:=""
       _nAscI:=1
       nConta:=0
       DO While _nAscI > 0
          _nAscI:=AT("<numero>" , _cProcura ) 
          If _nAscI > 0
             _nAscF:=AT("</numero>", _cProcura ) 
             If _nAscF > 0
                _nDel:=(_nAscF-_nAscI)+LEN("</numero>")//Tamanho do conteudo mais "<numero></numero>"
                _cConteudo+=SUBSTR(_cProcura,(_nAscI+LEN("<numero>")),(_nDel-LEN("<numero></numero>")))+" / "
                _cProcura := STUFF(_cProcura,_nAscI, _nDel ,"" )
             EndIf
          EndIf
          nConta++
          If nConta > 1000//Para previnir loop infinito
             Exit
          EndIf
       EndDo
       _cConteudo:="Viagen(s): "+SUBSTR(_cConteudo,1,LEN(_cConteudo)-3)

       _cErro:='Erro ao ler o XML do PERIODO: '+_aXmlDia[_nXml,3]+" ate "+_aXmlDia[_nXml,4]+" - "+_cConteudo+" - Erro: [ "+ALLTRIM(_cErro)+" ]. "
       _cSolucao:="POR FAVOR ENTRE EM CONTATO COM A  AREA DE TI COM O PRINT DESSA MESAGEM. "
       _cSolucao+=" Procure a posição "+ALLTRIM(_cPosAsc)+" no arq. "+_cNomeLog+" gravado para ver os caracteres especiais: ("+_cLetAsc+")"
       
       If !_lShedule
		  
		  MsgStop(_cErro+_cSolucao,"MGLT00203")
          
          If !MsgYesNo('Somente o Periodo: '+_aXmlDia[_nXml,3]+" até "+_aXmlDia[_nXml,4]+" não será processado. "+CRLF+"Deseja continuar processamento os outros periodos?","MGLT00204")
             If(SELECT(cAliasWK) # 0,_otemp:delete(),)
       // ------------------------------------------------------------------------------------------ //
       // Limpa o Objeto: _oXML Conforme orientado pelo Framework
       // ------------------------------------------------------------------------------------------ //
             _oXML:=Nil
             DelClassIntf()
             Return .F.	
          EndIf	      	
          Loop//Loop na hora minuto

	   Else

	      U_ITConOut( _cErro + CRLF + _cSolucao )
	      MGLT002EML( _cErro + CRLF + _cSolucao )

	   EndIf

	   Loop//Loop na hora minuto

	EndIf

	If ValType( XmlChildEx( _oXml:_SOAP_BODY,"_NS2_GETEXECUCAODIATRABALHOCRIADOOUMODIFICADORESPONSE" ) ) <> 'U'
	   If ValType( XmlChildEx( _oXml:_SOAP_BODY:_NS2_GETEXECUCAODIATRABALHOCRIADOOUMODIFICADORESPONSE , "_RETURN" ) ) <> 'U'
	   	_aXml := _oXml:_SOAP_BODY:_NS2_GETEXECUCAODIATRABALHOCRIADOOUMODIFICADORESPONSE:_RETURN
	   EndIf
	EndIf
	
	If ValType(_aXml) == 'O'
		_aXml := { _aXml }
	ElseIf ValType(_aXml) <> 'A'
      MemoWrite(_cNomeLog,_aXmlDia[_nXml,2])
      _aXml :={}
   EndIf
	
	If Len(_aXml) = 0
	   Loop//Loop na hora minuto
	EndIf

    If !_lShedule
       _oProcess:SetRegua2(Len(_aXml))
    EndIf

	For _nI := 1 To Len(_aXml)
		
        _cFilial :="  "
        _cRotaMae:="  "
        If ValType( XmlChildEX(_aXml[_nI] , "_CICLOVISITA" ) ) = 'O'
 		   _cFilial := SubStr( AllTrim( _aXml[_nI]:_CICLOVISITA:_CODIGO:TEXT ) , 1 , 2 )
 		   _cRotaMae:= AllTrim( _aXml[_nI]:_CICLOVISITA:_CODIGO:TEXT )
 	    EndIf

        _cVIAGEM := Space(Len(ZLJ->ZLJ_VIAGEM))
        If ValType( XmlChildEX(_aXml[_nI] , "_NUMERO" ) ) = 'O'
           _cVIAGEM := StrZero( Val( _aXml[_nI]:_NUMERO:TEXT ) , Len(ZLJ->ZLJ_VIAGEM) )
           _cVIAGEM := "S"+SUBSTR(_cVIAGEM,2)
        EndIf

        _cHoraLeu:=_aXmlDia[_nXml,5]
        If ValType( XmlChildEX(_aXml[_nI] , "_DATAHORAULTIMAMODIFICACAO" ) ) = 'O'
           _cHoraLeu:=SubStr( _aXml[_nI]:_DATAHORAULTIMAMODIFICACAO:TEXT , 12 , 8 )
        EndIf
        
        If !_lShedule
           _oProcess:IncRegua2("2-Lendo Filial / Viagem: "+_cFilial+" / "+_cVIAGEM )
        ElseIf _lIDESENV
        	U_ITConOut("2-Lendo Filial / Viagem: "+_cFilial+" / "+_cVIAGEM)
        EndIf
		
		If Empty(_cFilial)
		 
         MGLT002LogGrv(.F.,'Viagem recusada: Filial nao preenchida',.T.)
		   Loop//Na Viagem
		
		Else
			
			DBSelectArea('SM0')
			If SM0->( !DBSeek( cEmpAnt + _cFilial ) )

               MGLT002LogGrv(.F.,'Viagem recusada: Filial nao existe: '+cEmpAnt + _cFilial,.T.)
			   Loop//Na Viagem

			EndIf
			
		EndIf

        If !Empty(_cFiltroFilial) .AND. !(_cFilial $ _cFiltroFilial)
		   Loop//Na Viagem
		EndIf
        
		//====================================================================================================
		// Verifica tabela temporária dos dados de recepções
		//====================================================================================================
		    _aDadAtd:= {}
		    _nKm	:= 0
          _cKmOri:=""
			_nPesIni:= 0
			_nPesFim:= 0
			_nMedVaz:= 0
			_dDtIni	:= StoD('')
			_dDtFim	:= StoD('')
			_cHrIni	:= ''
			_cHrFim	:= ''
			_lDescarte := .F.
			_dDtEstoque:= StoD('')
			_cHrEstoque:= ''
			
			If ValType( XmlChildEx( _aXml[_nI] , "_LISTAATENDIMENTO" ) ) == 'A' //listaAtendimento
			
				_aDadAtd := _aXml[_nI]:_LISTAATENDIMENTO
			
			ElseIf ValType( XmlChildEx( _aXml[_nI] , "_LISTAATENDIMENTO" ) ) == 'O' //listaAtendimento com um só atendimento
				
				_aDadAtd := {_aXml[_nI]:_LISTAATENDIMENTO}
			
			EndIf			
			
			If !Empty( _aDadAtd )//Lista de Atendimentos
				
////////////////////////// FILTRO DOS ATENDIMENTOS ////////////////////////////////////////////////////////////////////////////// 
  		      _lAchouMoto:=.F.
		      _cMotorista:=SPACE(Len(ZLJ->ZLJ_MOTORI))
		      _cMotFilial:="  "
				_cCodtransp:=""
				_cLojtransp:=""
		      If ValType( XmlChildEx( _aDadAtd[1]:_USUARIO , "_CODIGO") ) <> 'U'//Só tem um motorista para todos os atendimentos
				
		         _cMotorista:= AllTrim( _aDadAtd[1]:_USUARIO:_CODIGO:TEXT) 
               _cMotFilial:= Substr(Alltrim(_cMotorista),LEN(alltrim(_cMotorista))-1,2) 
		         _cMotorista:= Substr(Alltrim(_cMotorista),1,LEN(alltrim(_cMotorista))-2)
		         If ZL0->( DBSeek( _cFilial + _cMotorista ) )
				      _cCodtransp:= ZL0->ZL0_FRETIS
				      _cLojtransp:= ZL0->ZL0_FRETLJ
  		            _lAchouMoto:= .T.
                  If !Empty(_cTransI+_cTraLoI) .AND. _cCodtransp+_cLojtransp < _cTransI+_cTraLoI 
                     LOOP//Na Viagem
			         EndIf
                  If !Empty(_cTransF+_cTraLoF) .AND. _cCodtransp+_cLojtransp > _cTransF+_cTraLoF
                     LOOP//Na Viagem
			         EndIf
						
		         EndIf
				
	         EndIf
////////////////////////// FILTRO DOS ATENDIMENTOS ////////////////////////////////////////////////////////////////////////////// 

//\\\\\\\\\\\\//////////// VALIDACAO E FILTRO DOS ATENDIMENTOS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\//////////////////////////////////////////////// 
			   _cMotivo:=""
			   _cRecusa:=""
            _cAviso :=""
            _nTotLeite:=0
            _lLoopViagem:=.F.
			   _lPodeMarcar:=.T.
            _dDtMV_ULMES:= STOD( POSICIONE("SX6",1,_cFilial+"MV_ULMES","X6_CONTEUD") )//Atencao usa a variavel _cFilial por isso executa aqui
            _cListaLinRotas:=""//acumula -> _cLINROT

				If ValType( XmlChildEx( _aXml[_nI] , "_DATAHORAINICIODIA"	) ) <> 'U'
					_dDtIni:= StoD( StrTran( SubStr( _aXml[_nI]:_DATAHORAINICIODIA:TEXT , 1 , 10 ) , '-' , '' ) )//data de coleta do ZLD: ZLJ_DTIVIA --> ZLD->ZLD_DTCOLE / ZLW->ZLW_DTCOLE
				EndIf

				For _nX := 1 To Len( _aDadAtd )//*********************************** VALIDACAO E FILTRO DOS ATENDIMENTOS

               If ValType( XmlChildEx( _aDadAtd[_nX]:_PONTOATENDIMENTO , "_CODIGO"	) ) <> 'U'     
                  _cCODPAT:=SubStr( _aDadAtd[_nX]:_PONTOATENDIMENTO:_CODIGO:TEXT , 1 , 6 )
                  _cLOJPAT:=SubStr( _aDadAtd[_nX]:_PONTOATENDIMENTO:_CODIGO:TEXT , 7 , 4 )
               Else
                  _cCODPAT := Space(6)
                  _cLOJPAT := Space(4)
               EndIf

               _cTipoLeite:="X"
               If Upper( AllTrim( _aDadAtd[_nX]:_TIPOVISITA:_CODIGO:TEXT ) ) == "REC"
					   _cLINROT:=_cRotaMae
					Else
                  // SO IGNORA QUANDO NÃO É REBOQUE 
                  lVolumeZeroLOOP:=.T.
                  MGLT2ListaResposta(.F.,_aDadAtd,_nX)
                  If lVolumeZeroLOOP//Volume do produtor zerado ignora linha
                     LOOP
                  EndIf

					   If Empty(_cCODPAT) .OR. !SA2->(DBSEEK(Xfilial("SA2")+_cCODPAT+_cLOJPAT)) .OR. (SA2->A2_MSBLQL == '1' .Or. SA2->A2_L_ATIVO == 'N')
					      _cRecusa += "[1 ou mais Produtores irregular] "
			            _lPodeMarcar:=.F.
   					   Exit					
   					EndIf
                  _cTipoLeite:=SA2->A2_L_TIPPR
					   _cLINROT   :=SA2->A2_L_LI_RO// LINHA / ROTA
					EndIf
					_cSetor	:=POSICIONE("ZL3",1,_cFilial + _cLINROT ,"ZL3_SETOR")
					_cSetorKM:=POSICIONE("ZL3",1,_cFilial + _cRotaMae,"ZL3_SETOR")					

					If !Empty(_cSetor)//Tem que trazer os setores em branco senao ele traz só os setores preenchidos de uma viagem e aceita 
					   If !Empty(_cSetorI) .AND. _cSetor < _cSetorI  
			              _lLoopViagem:=.T.
					      Exit
					   EndIf
					   If !Empty(_cSetorF) .AND. _cSetor > _cSetorF
			              _lLoopViagem:=.T.
					      Exit
					   EndIf
					EndIf

					If !Empty(_cLINROT)//Tem que trazer as linhas em branco senao ele traz só as linhas preenchidas de uma viagem e aceita 
					   If !Empty(_cLinhaI) .AND. _cLINROT < _cLinhaI 
			            _lLoopViagem:=.T.
					      Exit
					   EndIf
					   If !Empty(_cLinhaF) .AND. _cLINROT > _cLinhaF
			            _lLoopViagem:=.T.
					      Exit
					   EndIf
					EndIf

               //Data de entrada no estoque: ZLJ_DTCRIA --> D3_EMISSAO / ZLW_DTLANC
               If Empty(_dDtEstoque)//Pega a primeira data de estoque e replica para todas as linhas
                  _dDtEstoque:= STOD( StrTran( SubStr( _aDadAtd[_nX]:_DATACRIACAO:TEXT , 1 , 10 ) , '-' , '' ) )
                  _cHrEstoque:= SUBSTR( _aDadAtd[_nX]:_DATACRIACAO:TEXT , 12 , 8 )
               EndIf 
				   
               IF LEN(ALLTRIM(_aDadAtd[_nX]:_NUMEROATENDIMENTO:TEXT)) > LEN(ZLJ->ZLJ_NUMERO)
				      _cRecusa += "[Codigo de atendimento invalido: "+_aDadAtd[_nX]:_NUMEROATENDIMENTO:TEXT+"] "
                  _lPodeMarcar:=.F.
				      Exit
               ENDIF

				   If _cTipoLeite <> "C" .AND. _dDtEstoque <= _dDtMV_ULMES //Se a data da coleta For antes da data do fechemento do estoque recusa
				      _cRecusa += "[Data de entrada de estoque menor/igual que a data do fechamento do estoque: "+DTOC(_dDtMV_ULMES)+"] "
			         _lPodeMarcar:=.F.
				      Exit
               EndIf 

               //Data de coleta do ZLD: ZLJ_DTIVIA --> ZLD->ZLD_DTCOLE / ZLW->ZLW_DTCOLE
					If Empty(_dDtIni) .OR. _dDtIni > DATE()
					   _cRecusa += "[Data da coleta maior que a de hoje: "+DTOC(_dDtIni)+"] "
			         _lPodeMarcar:=.F.
					   Exit
  					ElseIf _cTipoLeite <> "C" .AND. .NOT. MGLT002I( _dDtIni )
					   _cRecusa += "[Data da coleta fora de um periodo de MIX aberto: "+DTOC(_dDtIni)+"] "
			         _lPodeMarcar:=.F.
 					   Exit					
               EndIf 

					If Empty(_cSetorKM)//No proximo For ele identifica quais atendiemntos estao sem setor
					   _cRecusa += "[1 ou mais atendimentos sem Setor do KM] "
			         _lPodeMarcar:=.F.
					   Exit
               EndIf 
                    
					If Empty(_cSETOR)//No proximo For ele identifica quais atendiemntos estao sem setor
					   _cRecusa += "[1 ou mais atendimentos sem Setor] "
			         _lPodeMarcar:=.F.
					   Exit
					ElseIf _cTipoLeite <> "C" .AND. MGLT002R( _dDtIni , _cSETOR )
					   _cRecusa += "[1 ou mais Setores irregular] "
			         _lPodeMarcar:=.F.
 					   Exit					
               EndIf 

					If Empty(_cLINROT)//No proximo For ele identifica quais atendiemntos estao sem linha/rota
					   _cRecusa += "[1 ou mais atendimentos sem linha/rota] "
			         _lPodeMarcar:=.F.
					   Exit
					ElseIf !_cFilial == LEFT(_cLINROT,2)
					   _cRecusa += "[1 ou mais linha/rota irregular] "
			         _lPodeMarcar:=.F.
 					   Exit					
               EndIf 

               _cMemAux := MGLT2ListaResposta(.F.,_aDadAtd,_nX)
			      If !Empty(_cMemAux)
					   _cRecusa += "[1 ou mais atendimentos com Lista de Respostas invalida] "
			         _lPodeMarcar:=.F.
					   Exit
               EndIf 
               //******************************************************
               //NOVA VALIDAÇÕES DOS ATENDIMENTOS INSIRA AQUI
               //******************************************************

               IF !_cLINROT $ _cListaLinRotas
                  _cListaLinRotas+=_cLINROT+"/"//acumula -> _cLINROT
               ENDIF

				Next _nX//*********************************** For _nX := 1 To Len( _aDadAtd ) // VALIDACAO E FILTRO DOS ATENDIMENTOS
				
				If _lLoopViagem
				   LOOP //Na Viagem
				EndIf
///////////\\\\\\\\\\\\\\\ VALIDACAO E FILTRO DOS ATENDIMENTOS /////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
                
             _cViagemMae:=""
                
			    If ValType( XmlChildEx( _aXml[_nI] , "_CUSTOMFIELD" ) ) == 'A'
					
					For _nX := 1 To Len( _aXml[_nI]:_CUSTOMFIELD )
					
						If ValType( XmlChildEx( _aXml[_nI]:_CUSTOMFIELD[_nX] , "_CODIGO" ) ) <> 'U'  
						
							If _aXml[_nI]:_CUSTOMFIELD[_nX]:_CODIGO:TEXT == "PESO_INICIAL"
									
								_nPesIni := Val( _aXml[_nI]:_CUSTOMFIELD[_nX]:_VALORNUMERICO:TEXT )
								
							EndIf
							
						EndIf  
						
						If ValType( XmlChildEx( _aXml[_nI]:_CUSTOMFIELD[_nX] , "_CODIGO" ) ) <> 'U'  
						
							If _aXml[_nI]:_CUSTOMFIELD[_nX]:_CODIGO:TEXT == "PESO_FINAL"
									
								_nPesFim := Val( _aXml[_nI]:_CUSTOMFIELD[_nX]:_VALORNUMERICO:TEXT )
								
							EndIf
							
						EndIf
						
						If ValType( XmlChildEx( _aXml[_nI]:_CUSTOMFIELD[_nX] , "_CODIGO" ) ) <> 'U'  
						
							If _aXml[_nI]:_CUSTOMFIELD[_nX]:_CODIGO:TEXT == "MEDIDOR_VAZAO"
									
								_nMedVaz := Val( _aXml[_nI]:_CUSTOMFIELD[_nX]:_VALORNUMERICO:TEXT )
								
							EndIf
							
						EndIf
						
						If ValType( XmlChildEx( _aXml[_nI]:_CUSTOMFIELD[_nX] , "_CODIGO" ) ) <> 'U'  
						
							If _aXml[_nI]:_CUSTOMFIELD[_nX]:_CODIGO:TEXT == "DESCARTE"
									
								_lDescarte :=  IIF(_aXml[_nI]:_CUSTOMFIELD[_nX]:_VALORBOLEANO:TEXT == 'false', .F., .T.) 
								
							EndIf
							
						EndIf			

						If ValType( XmlChildEx( _aXml[_nI]:_CUSTOMFIELD[_nX] , "_CODIGO" ) ) <> 'U'  
						
							If _aXml[_nI]:_CUSTOMFIELD[_nX]:_CODIGO:TEXT == "CODIGO_MATRIZ"
								IF Val(_aXml[_nI]:_CUSTOMFIELD[_nX]:_VALORTEXTO:TEXT  ) <> 0
						       _cViagemMae := StrZero( Val(_aXml[_nI]:_CUSTOMFIELD[_nX]:_VALORTEXTO:TEXT  ), Len(ZLJ->ZLJ_VIAGEM) )
                         _cViagemMae := "S"+SUBSTR(_cViagemMae,2)
								ENDIF
							EndIf
							
						EndIf			
				
						
					Next _nX

				ElseIf ValType( XmlChildEx( _aXml[_nI] , "_CUSTOMFIELD" ) ) <> 'U'

					If ValType( XmlChildEx( _aXml[_nI]:_CUSTOMFIELD , "_CODIGO" ) ) <> 'U'  
						
						If _aXml[_nI]:_CUSTOMFIELD:_CODIGO:TEXT == "CODIGO_MATRIZ"
							IF Val(_aXml[_nI]:_CUSTOMFIELD:_VALORTEXTO:TEXT ) <> 0
						       _cViagemMae := StrZero( Val(_aXml[_nI]:_CUSTOMFIELD:_VALORTEXTO:TEXT ), Len(ZLJ->ZLJ_VIAGEM) )
                         _cViagemMae := "S"+SUBSTR(_cViagemMae,2)
							ENDIF	
						EndIf
							
					EndIf			
				
				EndIf
				
				If _cViagemMae == _cVIAGEM
               _cViagemMae:=""
				EndIf
				
				If ValType( XmlChildEx( _aXml[_nI] , "_DATAHORAINICIODIA"	) ) <> 'U'
					_dDtIni := StoD( StrTran( SubStr( _aXml[_nI]:_DATAHORAINICIODIA:TEXT , 1 , 10 ) , '-' , '' ) )
					_cHrIni := SubStr( _aXml[_nI]:_DATAHORAINICIODIA:TEXT , 12 , 08 )
				EndIf
				
				If ValType( XmlChildEx( _aXml[_nI] , "_DATAHORAFIMDIA"		) ) <> 'U'
					_dDtFim := StoD( StrTran( SubStr( _aXml[_nI]:_DATAHORAFIMDIA:TEXT , 1 , 10 ) , '-' , '' ) )
					_cHrFim := SubStr( _aXml[_nI]:_DATAHORAFIMDIA:TEXT , 12 , 08 )
				EndIf
				
				_nKm:=0
            _cKmOri:=""
				If ValType( XmlChildEx( _aXml[_nI] , "_DISTANCIASHAPEKM"	) ) <> 'U'
               _cKmOri:=_aXml[_nI]:_DISTANCIASHAPEKM:TEXT
					_nKm   := Round( Val( _cKmOri ) , 0 )
				EndIf


            _cViaFilhas:=""
				For _nX := 1 To Len( _aDadAtd )//*********************** PRE-PROCESSAMWTO PARA JULIETAS

					If Upper( AllTrim( _aDadAtd[_nX]:_TIPOVISITA:_CODIGO:TEXT ) ) == "REC"
					
			           If ValType( XmlChildEx( _aDadAtd[_nX]:_LISTARESPOSTA , "_LISTACAMPORESPOSTA" ) ) == 'A'
                        For _nF := 1 TO LEN(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA)
							      If Upper( AllTrim( _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nF]:_CAMPOFORMULARIO:_CODIGO:TEXT ) ) == 'REC1'
                              If ValType( XmlChildEx( _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nF] , "_VALORRESPOSTATEXTO" ) ) # 'U'
                                 _cVFilha := StrZero( Val( _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nF]:_VALORRESPOSTATEXTO:TEXT ) , Len(ZLJ->ZLJ_VIAGEM) )
                                 _cVFilha := "S"+SUBSTR(_cVFilha,2)							  
                                 _cViaFilhas+=_cVFilha+"-"
                              EndIf
                           EndIf
                        Next
			           ElseIf ValType( XmlChildEx( _aDadAtd[_nX]:_LISTARESPOSTA , "_LISTACAMPORESPOSTA" ) ) == 'O'
						      If Upper( AllTrim( _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA:_CAMPOFORMULARIO:_CODIGO:TEXT ) ) == 'REC1'
                           If ValType( XmlChildEx( _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA , "_VALORRESPOSTATEXTO" ) ) # 'U'
                              _cVFilha := StrZero( Val( _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA:_VALORRESPOSTATEXTO:TEXT ) , Len(ZLJ->ZLJ_VIAGEM) )
                              _cVFilha := "S"+SUBSTR(_cVFilha,2)
                              _cViaFilhas+=_cVFilha+"-"
                            EndIf
                        EndIf
					   EndIf
					   
					EndIf

            Next //Len( _aDadAtd )//*********************** PRE-PROCESSAMWTO PARA JULIETAS

            _cViaFilhas:=LEFT(_cViaFilhas, LEN(_cViaFilhas)-1 )//Se tiver Filhas indica que é a Viagem Mãe

/////////////////////\/\/\/\/\/ VALIDACAO DA VIAGEM \/\/\/\/\/\/\/\/////////////////////////////////////////////////////////////////////// 

            If Empty(_cViaFilhas) .AND. _lPodeMarcar .AND. _nTotLeite = 0//Só verifica o leite = zero se deu tudo OK na VALIDACAO DOS ATENDIMENTOS pq só assim leu todos os atendimentos
				   _cRecusa += "[Volume do leite dos atendimentos zerado] "
		         _lPodeMarcar:=.F.
            EndIf

				If Empty(_cViagemMae) .AND. _nPesIni < _nPesFim//Quando é Julieta vale os valores da Mãe //Peso Cheio For menos que peso vazio pois devem ter didigtado ao contrario
				   _cRecusa += "[Volume Negativo: P.Cheio: "+ALLTRIM(TRANSF(_nPesIni,"@E 999,999,999"))+" - P.Vazio: "+ALLTRIM(TRANSF(_nPesFim,"@E 999,999,999"))+"] "
		         _lPodeMarcar:=.F.
            ElseIf Empty(_cViagemMae) .AND. (_nPesIni -_nPesFim) = 0 .AND. _nMedVaz = 0 //Quando é Julieta vale os valores da Mãe //Se esse valores vierem zerados não tem como dar entrada no estoque                                                                                            
				   _cRecusa += "[Peso Cheio - Peso Vazio e Medidor de Vazão zerados] "
		         _lPodeMarcar:=.F.
            ElseIf Empty(_cViagemMae) .AND. (_nPesIni -_nPesFim) # 0 .AND. _nMedVaz # 0 //Quando é Julieta vale os valores da Mãe //Se esse valores vierem zerados não tem como dar entrada no estoque                                                                                            
				   _cRecusa += "[Peso Cheio - Peso Vazio e Medidor de Vazão: todos preenchidos]"
		          _lPodeMarcar:=.F.
            EndIf
					
				If !_lAchouMoto 
				   _cRecusa += '[Codigo "'+_cFilial+' '+_cMotorista+' '+_cMotFilial+'" não existe no cadastro de motoristas (ZL0)] '
		         _lPodeMarcar:=.F.
            ELSEIf !ZL0->( DBSeek( _cFilial + _cMotorista ) ) .OR. ZL0->ZL0_ATIVO == 'N' 
				    _cRecusa += "[Motorista : "+_cMotorista +' '+ _cFilial+" nao cadastrado ou inativo (Ativo = "+ZL0->ZL0_ATIVO+") (ZL0)] "
			       _lPodeMarcar:=.F.
				ElseIf !(_cMotFilial == _cFilial)
				   _cRecusa += "[Filial do Atendimento "+_cFilial+" difere da Filial do Motorista "+_cMotFilial+"] "
		         _lPodeMarcar:=.F.
				EndIf			

				If Empty(_cCodtransp) .OR. !SA2->(DBSEEK(Xfilial("SA2")+_cCodtransp+_cLojtransp)) .OR. (SA2->A2_MSBLQL == '1' .Or. SA2->A2_L_ATIVO == 'N')
				   _cRecusa += "[Transportador: "+_cCodtransp +' '+ _cLojtransp+" nao cadastrado, bloqueado ("+SA2->A2_MSBLQL+") ou inativo (Ativo = "+SA2->A2_L_ATIVO+") (SA2)] "
			      _lPodeMarcar:=.F.
            EndIf

            //Verifica se placa está no cadastro de motoristas 
            _cPlacaS   :=""
            _cPlacaC   :=SPACE(Len(ZLJ->ZLJ_PLACA))
  				If ValType( XmlChildEx( _aXml[_nI] , "_VEICULOPRIMARIO"	) ) <> 'U'
        		   If ValType( XmlChildEx( _aXml[_nI]:_VEICULOPRIMARIO , "_PLACA" ) ) <> 'U'
		            _cPlacaS:= LEFT(StrTran( AllTrim( _aXml[_nI]:_VEICULOPRIMARIO:_PLACA:TEXT ) , '-' , '' ),7)//Peguei o 7 primeiro pq estava vindo com caracter especial no final
         	   	_cPlacaC:= SubStr( _cPlacaS, 1 , 3 ) +'-'+ SubStr( _cPlacaS, 4 )
        	      EndIf
        	   EndIf

            _cPlacaRS   :=SPACE(Len(ZL1->ZL1_PLCREB))//PLACA REBOQUE
            _cPlacaRC   :=SPACE(Len(ZL1->ZL1_PLCREB))//PLACA REBOQUE
  				If ValType( XmlChildEx( _aXml[_nI] , "_VEICULOREBOQUE"	) ) <> 'U'
        		   If ValType( XmlChildEx( _aXml[_nI]:_VEICULOREBOQUE , "_PLACA" ) ) <> 'U'
		            _cPlacaRS:= LEFT(StrTran( AllTrim( _aXml[_nI]:_VEICULOREBOQUE:_PLACA:TEXT ) , '-' , '' ),7)//Peguei o 7 primeiro pq estava vindo com caracter especial no final
         	   	_cPlacaRC:= SubStr( _cPlacaS, 1 , 3 ) +'-'+ SubStr( _cPlacaS, 4 )
        	      EndIf
        	   EndIf

             _cVeiculo:=""
  		        _lAchouPlaca:=.F.
  		        ZL1->( DBSetOrder(2))
				If _lAchouMoto .AND. ZL1->( DBSeek( _cFilial + _cPlacaS ) )
			       DO While ZL1->(!EOF()) .AND. _cFilial + _cPlacaS == ZL1->ZL1_FILIAL + ZL1->ZL1_PLACA
				      If ZL1->ZL1_MOTORI == _cMotorista .AND. _cPlacaRS == ZL1->ZL1_PLCREB  
                     _cVeiculo   :=ZL1->ZL1_COD
				         _lAchouPlaca:=.T.
				         Exit
				      EndIf
				      ZL1->(DBSKIP())
				   EndDo
				EndIf   
				
				If !_lAchouPlaca   
				   _cRecusa += '[Placas "' +_cFilial+' '+ _cPlacaC + " / "+_cPlacaRS + '" + Motorista "'+_cMotorista+' '+_cMotFilial+'" não encontrado (ZL1) ] '
		         _lPodeMarcar:=.F.				
            ELSE
               If !Empty(_cVeiculo)  .AND. ZL1->ZL1_MSBLQL == '1' 
				      _cRecusa += '[Placas "' +_cFilial+' '+ _cPlacaC + " / "+_cPlacaRS + '" + Motorista "'+_cMotorista+' '+_cMotFilial+'"  bloqueado ('+ZL1->ZL1_MSBLQL+") (ZL1) ] "
			         _lPodeMarcar:=.F.
               ENDIF
				EndIf			

				If Empty(_dDtFim) 
				   If _lValData
				      _cRecusa += '[Viagem sem Data Final de Fechamento] '
		            _lPodeMarcar:=.F.				
		         Else
				      _cAviso += '[Viagem sem Data Final de Fechamento] '
		         EndIf
				EndIf
            IF !_cRotaMae $ _cListaLinRotas
		          _cAviso += '[Linha Rota do SQ ('+_cRotaMae+') não esta em nenhum atendimento dessa viagem ('+_cListaLinRotas+')] '
            ENDIF
            //******************************************************
            //NOVA VALIDAÇÕES / AVISOS DA VIAGEM INSERIRA AQUI
            //******************************************************
		      
            _lViagemAceita:=.F.
		      _cFilhaMae:=""
  		      ZLJ->( DBSetOrder(6) )//ZLJ_FILIAL+ZLJ_VIAGEM+ZLJ_VFILHA
  		      _cFilhaMae:=If(!Empty(_cViaFilhas),"Julieta",SPACE(LEN(ZLJ->ZLJ_VFILHA)))
  		       
  		      _lconcorr := .F.
  		      _ctread := ""
  		       
  		      ZLK->(DBSetOrder(1))//Vamos controlar por filial agora 
  		      If ZLK->(Dbseek(_cFilial ))//+ If(!Empty(_cViagemMae), _cViagemMae+_cVIAGEM , _cVIAGEM+_cFilhaMae )
  		        
  		        	If !ZLK->(MsRLock(ZLK->(RECNO())))
  		        	
  		        		_lconcorr := .T.
  		        		_ctread := ZLK->ZLK_THREAD
  		        		_cuser  := ALLTRIM(ZLK->ZLK_USUSAR)
  		        		
  		        	Else
  		        	
  		        		ZLK->(Reclock("ZLK",.F.))
       	         ZLK->ZLK_VIAGEM := _cFilial+"-"+DTOC(DATE())+"-"+TIME()// + If(!Empty(_cViagemMae), _cViagemMae+_cVIAGEM , _cVIAGEM+SPACE(LEN(ZLJ->ZLJ_VFILHA))) 
  		        		ZLK->ZLK_THREAD := strzero(ThreadID(),6)
  		        		ZLK->ZLK_USUSAR := _cZLJ_UINTSQ
  		        		ZLK->(Msunlock())
  		        		ZLK->(Reclock("ZLK",.F.))
  		        		
  		        	EndIf
  		        	
  		      Else
  		        
  		        	 ZLK->(Reclock("ZLK",.T.))
                ZLK->ZLK_FILIAL := _cFilial    
  		        	 ZLK->ZLK_VIAGEM := _cFilial+"-"+DTOC(DATE())+"-"+TIME()//+ If(!Empty(_cViagemMae), _cViagemMae+_cVIAGEM , _cVIAGEM+_cFilhaMae )
  		        	 ZLK->ZLK_THREAD := strzero(ThreadID(),6)
  		        	 ZLK->ZLK_USUSAR := _cZLJ_UINTSQ
  		        	 ZLK->(Msunlock())
  		        	 ZLK->(Reclock("ZLK",.F.))
  		        	
  		      EndIf
  		        
  		        If _lconcorr
  		        
                 _lPodeMarcar:=.F.
                 _cAviso += "Viagem sendo integrada pela thread [" + _ctread + "] do usuário [" + _cuser + "]"
		        
  		        //Tem que procurar a Mae com a filha em brnaco senão ele acha a as linhas da filhas já integradas
		        ElseIf ZLJ->( DBSeek( _cFilial + If(!Empty(_cViagemMae), _cViagemMae+_cVIAGEM , _cVIAGEM+_cFilhaMae ) ) )

                  If(_nKm < 0,_nKm := 0,)//Zerei antes por que se tiver zerado tb no protheus, nao precisa atualizar
   
				      If _nKm = ZLJ->ZLJ_KMDVIA
			             _lPodeMarcar:=.F.
                      _cAviso += "Viagem Integrada Anteriormente: [KM = Protheus: "+ALLTRIM(TRANSF(ZLJ->ZLJ_KMDVIA,"@E 999,999,999"))+"] "
			         ElseIf !ZLJ->ZLJ_STATUS $ "R,E"//Codigo de segurança para não integrar nada das recusadas e efetivadas
		                _lPodeMarcar:=.T.//Se PENDENTE pode aceitar a viagem já integrada
		                _lViagemAceita:=.T.//Variavel para as validações dos atendimentos não barrar a viagem
                      _cAviso += "Viagem Integrada Anteriormente: [KM # Protheus: "+ALLTRIM(TRANSF(ZLJ->ZLJ_KMDVIA,"@E 999,999,999"))+"] "			       
                  EndIf
                  If ZLJ->ZLJ_STATUS == "R"
			            _lPodeMarcar:=.F.
		               _lViagemAceita:=.F.
                     _cAviso += "[Viagem Recusada no Protheus]
                  ELSEIf ZLJ->ZLJ_STATUS == "E"
			            _lPodeMarcar:=.F.
		               _lViagemAceita:=.F.
                     _cAviso += "[Viagem Eftivada no Protheus]
                  EndIf			    
			    Else
			    
				   If _nKm < 0
				      _cAviso += "KM Negativa: [Km Rastreado: "+ALLTRIM(TRANSF(_nKm,"@E 999,999,999"))+"] "
               EndIf
                   
			    EndIf

				If _nKm < 0
            	_nKm := 0  
            EndIf
/////////////\/\/\/\/\/\/\/\/\//\/\/\ VALIDACAO DA VIAGEM /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\////////////////////////////////////////////// 

//////////////////////////////////////////////////////////// INICIO DO For DA GRAVACAO NO TRB //////////////////////////////////////////////////////////////

				For _nX := 1 To Len( _aDadAtd )

               If !Upper( AllTrim( _aDadAtd[_nX]:_TIPOVISITA:_CODIGO:TEXT ) ) == "REC"  
                  // SÓ IGNORA QUANDO NÃO É REBOQUE 
                  lVolumeZeroLOOP:=.T.
                  MGLT2ListaResposta(.F.,_aDadAtd,_nX)
                  If lVolumeZeroLOOP//Volume do produtor zerado ignora linha
                     LOOP//_cAviso += "[Atendimento com Volume zerado]"
                  EndIf
               EndIf
				
					//Grava tabela temporária
					TRB_ZLJ->(DBAPPEND())
					TRB_ZLJ->WK_DATA    := CTOD(_cDataLendo)
					TRB_ZLJ->WK_HORA    := SubStr( _aXml[_nI]:_DATAHORAULTIMAMODIFICACAO:TEXT , 12 , 8 )
					TRB_ZLJ->ZLJ_FILIAL	:= _cFilial
					If !Empty(_cViagemMae) 
 					   If alltrim(_cViagemMae) == "S000000000"
 					   
 			   			TRB_ZLJ->ZLJ_VIAGEM := _cVIAGEM
 					   Else
 					   
 					   	TRB_ZLJ->ZLJ_VIAGEM := _cViagemMae
 					   	TRB_ZLJ->ZLJ_VFILHA := _cVIAGEM
 					   	
 					   EndIf
 				    Else
 					   TRB_ZLJ->ZLJ_VIAGEM := _cVIAGEM
 				    EndIf
					TRB_ZLJ->ZLJ_NUMERO	:= StrZero( Val( _aDadAtd[_nX]:_NUMEROATENDIMENTO:TEXT ) , LEN(TRB_ZLJ->ZLJ_NUMERO) )//Atendimento
					TRB_ZLJ->ZLJ_DTCRIA	:= _dDtEstoque//StoD( StrTran( SubStr( _aDadAtd[_nX]:_DATACRIACAO:TEXT , 1 , 10 ) , '-' , '' ) )//onde grava a data entrada no estoque: ZLJ_DTCRIA --> D3_EMISSAO / ZLW_DTLANC
					TRB_ZLJ->ZLJ_HRCRIA	:= _cHrEstoque//SubStr( _aDadAtd[_nX]:_DATACRIACAO:TEXT , 12 , 8 )
					TRB_ZLJ->ZLJ_DTINI	:= StoD( StrTran( SubStr( _aDadAtd[_nX]:_DATAINICIO:TEXT , 1 , 10 ) , '-' , '' ) )
					TRB_ZLJ->ZLJ_HRINI	:= SubStr( _aDadAtd[_nX]:_DATAINICIO:TEXT , 12 , 8 )
					TRB_ZLJ->ZLJ_DTFIM	:= StoD( StrTran( SubStr( _aDadAtd[_nX]:_DATAFIM:TEXT , 1 , 10 ) , '-' , '' ) )
					TRB_ZLJ->ZLJ_HRFIM	:= SubStr( _aDadAtd[_nX]:_DATAFIM:TEXT , 12 , 8 )
					TRB_ZLJ->ZLJ_TIPVIS	:= IIF( Upper( AllTrim( _aDadAtd[_nX]:_TIPOVISITA:_CODIGO:TEXT ) ) == 'COLETA' , 'C' , 'N' )
					TRB_ZLJ->ZLJ_USRSMQ	:= IIF( ValType( XmlChildEx( _aDadAtd[_nX]:_USUARIO , "_CODIGO") ) <> 'U', AllTrim( _aDadAtd[_nX]:_USUARIO:_CODIGO:TEXT), '' )
					TRB_ZLJ->ZLJ_LOGINS	:= IIF( ValType( XmlChildEx( _aDadAtd[_nX]:_USUARIO , "_LOGIN" ) ) <> 'U', AllTrim( _aDadAtd[_nX]:_USUARIO:_LOGIN:TEXT ), '' )
					TRB_ZLJ->ZLJ_STATUS	:= "P"
					TRB_ZLJ->ZLJ_DTIVIA	:= _dDtIni//data de coleta do ZLD: ZLJ_DTIVIA --> ZLD->ZLD_DTCOLE / ZLW->ZLW_DTCOLE
					TRB_ZLJ->ZLJ_HRIVIA	:= _cHrIni
					TRB_ZLJ->ZLJ_DTFVIA	:= _dDtFim
					TRB_ZLJ->ZLJ_HRFVIA	:= _cHrFim
					TRB_ZLJ->ZLJ_PSIVIA	:= _nPesIni
					TRB_ZLJ->ZLJ_PSFVIA	:= _nPesFim
					TRB_ZLJ->ZLJ_LITRAG	:= _nMedVaz

               If ValType( XmlChildEx( _aDadAtd[_nX]:_PONTOATENDIMENTO , "_CODIGO"	) ) <> 'U'     
					   _cCodPat :=SubStr( _aDadAtd[_nX]:_PONTOATENDIMENTO:_CODIGO:TEXT , 1 , 6 )
					   _cLojPat :=SubStr( _aDadAtd[_nX]:_PONTOATENDIMENTO:_CODIGO:TEXT , 7 , 4 )
               Else
                  _cCODPAT := Space(6)
                  _cLOJPAT := Space(4)
               EndIf
					_cMemAux   :=""

               If Upper( AllTrim( _aDadAtd[_nX]:_TIPOVISITA:_CODIGO:TEXT ) ) == "REC"  

					   _cLinhaRota:=_cRotaMae
					   TRB_ZLJ->ZLJ_VFILHA := "Julieta"
					   TRB_ZLJ->ZLJ_VFILHS := _cViaFilhas
					   TRB_ZLJ->ZLJ_TIPPRO := "F"

					Else
					   
					   TRB_ZLJ->ZLJ_CODPAT := _cCodPat
					   TRB_ZLJ->ZLJ_LOJPAT := _cLojPat
					   If Empty(_cCODPAT) .OR. !SA2->(DBSEEK(Xfilial("SA2")+_cCodPat+_cLojPat)) .OR. (SA2->A2_MSBLQL == '1' .Or. SA2->A2_L_ATIVO == 'N')
					      _cMemAux:=" [Produtor: "+_cCodPat+' '+_cLojPat+" nao cadastrado, bloqueado ("+SA2->A2_MSBLQL+") ou inativo (Ativo = "+SA2->A2_L_ATIVO+")] "
			            _lPodeMarcar:=_lViagemAceita
					   EndIf
				    
				       TRB_ZLJ->ZLJ_NOMPAT := SA2->A2_NOME   
				       TRB_ZLJ->ZLJ_TIPPRO := SA2->A2_L_TIPPR
					   _cLinhaRota:=SA2->A2_L_LI_RO

					   If Empty(TRB_ZLJ->ZLJ_TIPPRO) .OR. TRB_ZLJ->ZLJ_TIPPRO = "A"//No ZLJ o atravessador tem que ficar com tipo "P" por causa da quebra na efetivacao
					      TRB_ZLJ->ZLJ_TIPPRO:= "P"
					   EndIf	

					EndIf
					
					_cSetor:=POSICIONE("ZL3",1,_cFilial+_cLinhaRota,"ZL3_SETOR")
					
			      TRB_ZLJ->ZLJ_KMDVIA:= _nKm
               TRB_ZLJ->ZLJ_KM_SQO:= _cKmOri  
					TRB_ZLJ->ZLJ_LINROT:=_cLinhaRota
					TRB_ZLJ->ZLJ_LINHSQ:=_cRotaMae
					If Empty(TRB_ZLJ->ZLJ_LINROT)
					   _cMemAux+=" [Linha/Rota nao encontrada Chave: "+xFilial("SA2")+" "+_cCodPat+" "+_cLojPat+"] "
					   _lPodeMarcar:=_lViagemAceita
					ElseIf !_cFilial == LEFT(TRB_ZLJ->ZLJ_LINROT,2)
					   _cMemAux+=" [Linha/Rota nao pertence a filial dessa viagem] "
					   _lPodeMarcar:=_lViagemAceita
               EndIf 

					_cSetorKM:=POSICIONE("ZL3",1,_cFilial + _cRotaMae,"ZL3_SETOR")					
					If !Empty(TRB_ZLJ->ZLJ_LINHSQ) .AND. Empty(_cSetorKM)
					   _cMemAux+=" [Setor do KM nao encontrado Chave: "+_cFilial+" "+_cLinhaRota+"] "
					   _lPodeMarcar:=_lViagemAceita
               EndIf 

					TRB_ZLJ->ZLJ_SETOR :=_cSetor
					If !Empty(TRB_ZLJ->ZLJ_LINROT) .AND. Empty(TRB_ZLJ->ZLJ_SETOR)
					   _cMemAux+=" [Setor nao encontrado Chave: "+_cFilial+" "+_cLinhaRota+"] "
					   _lPodeMarcar:=_lViagemAceita
     	 			ElseIf TRB_ZLJ->ZLJ_TIPPRO <> "C" .AND. MGLT002R( _dDtIni , _cSETOR )
					   _cMemAux += "[Setor: "+_cSETOR+" possui lançamento de algum evento na data ["+DTOC(_dDtIni)+"] "
					   _lPodeMarcar:=_lViagemAceita
					EndIf

					TRB_ZLJ->ZLJ_DESCAR:= _lDescarte                                                  
				    TRB_ZLJ->ZLJ_PLACA:= _cPlacaS//Grava placa aqui pq tem uma coluna na tela para mostrar

					If _lAchouPlaca .AND. _lAchouMoto
					   TRB_ZLJ->ZLJ_MOTORI:= _cMotorista//Esse campo virou real pois vem do SQ
					   TRB_ZLJ->ZLJ_VEICUL:= _cVeiculo
					   TRB_ZLJ->ZLJ_CODTRN:= _cCodtransp
					   TRB_ZLJ->ZLJ_LOJTRN:= _cLojtransp
					   TRB_ZLJ->ZLJ_DTRAN := POSICIONE("SA2",1,XFILIAL("SA2")+_cCodtransp+_cLojtransp,"A2_NOME")
					EndIf

                    _cMemAux += MGLT2ListaResposta(.T.,_aDadAtd,_nX)
                
                    If _lPodeMarcar
                       _cMotivo := "Atendimento OK"
                       If !Empty(_cAviso+_cRecusa)
                          _cMotivo += ": "+_cAviso+_cRecusa
                       EndIf
                    Else
                       _cMotivo := "Viagem Recusada"
                       If !Empty(_cRecusa+_cAviso)
                          _cMotivo += ": "+_cRecusa+_cAviso
                       EndIf
                    EndIf

                    MGLT002LogGrv(_lPodeMarcar,_cMotivo+_cMemAux,.F.)
                    _cMotivo :=""
					
				Next _nX
//////////////////////////////    FIM DA GRAVACAO NO TRB /////////////////////////////////////////////////////

			Else//Empty( _aDadAtd )//Lista de Atendimentos

	            AADD(_aXmlReboque, _aXml[_nI] )//Tratamento de Reboque
	            
			EndIf//If !Empty( _aDadAtd )//Lista de Atendimentos
			
	Next _nI
	
Next _nXml//LEN(_aXmlDia)

//*\\//*\\//*\\//***********************************************************************************\\//*\\//*\\//
///*********************************////  TRATAMENTO DO REBOQUE ///**********************************////
_aXml:=ACLONE(_aXmlReboque)

If !_lShedule
   _oProcess:SetRegua2(Len(_aXml))
EndIf
U_ITConOut("2-Lendo Reboques "+ALLTRIM(STR(LEN(_aXml)))+" registros... ")

For _nI := 1 TO LEN(_aXml)

   _cFilial :="  "
   _cRotaReb:="  "
   If _aXml[_nI] = NIL
      LOOP
   EndIf
   If ValType( XmlChildEX(_aXml[_nI] , "_CICLOVISITA" ) ) = 'O'
      _cFilial := SubStr( AllTrim( _aXml[_nI]:_CICLOVISITA:_CODIGO:TEXT ) , 1 , 2 )
      _cRotaReb:= AllTrim( _aXml[_nI]:_CICLOVISITA:_CODIGO:TEXT )
   EndIf

   _cVIAGEM := Space(Len(ZLJ->ZLJ_VIAGEM))
   If ValType( XmlChildEX(_aXml[_nI] , "_NUMERO" ) ) = 'O'
      _cVIAGEM := StrZero( Val( _aXml[_nI]:_NUMERO:TEXT ) , Len(ZLJ->ZLJ_VIAGEM) )
      _cVIAGEM := "S"+SUBSTR(_cVIAGEM,2)
   EndIf
   
   _cHoraLeu:=""
   If ValType( XmlChildEX(_aXml[_nI] , "_DATAHORAULTIMAMODIFICACAO" ) ) = 'O'
      _cHoraLeu:=SubStr( _aXml[_nI]:_DATAHORAULTIMAMODIFICACAO:TEXT , 12 , 8 )
   EndIf

   If !_lShedule
      _oProcess:IncRegua2("Lendo Filial / Viagem: "+_cFilial+" / "+_cVIAGEM )
   EndIf

   If Empty(_cFilial)
      MGLT002LogGrv(.F.,'Viagem recusada: Filial nao preenchida',.T.)
      Loop
   Else

      DBSelectArea('SM0')
      If SM0->( !DBSeek( cEmpAnt + _cFilial ) )
         MGLT002LogGrv(.F.,'Viagem recusada: Filial nao existe: '+cEmpAnt + _cFilial,.T.)
         Loop
      EndIf

   EndIf

   _lAchouMoto:=.F.
   _cMotorista:=SPACE(Len(ZLJ->ZLJ_MOTORI))
   _cMotFilial:="  "
   _cCodtransp:=""
   _cLojtransp:=""
   If ValType( XmlChildEx( _aXml[_nI]:_USUARIO , "_CODIGO") ) <> 'U'//Só tem um motorista para todos os atendimentos
      _cMotorista:= AllTrim( _aXml[_nI]:_USUARIO:_CODIGO:TEXT)
      _cMotFilial:= Substr(Alltrim(_cMotorista),LEN(alltrim(_cMotorista))-1,2)
      _cMotorista:= Substr(Alltrim(_cMotorista),1,LEN(alltrim(_cMotorista))-2)

      If ZL0->( DBSeek( _cFilial + _cMotorista ) )
        _cCodtransp:= ZL0->ZL0_FRETIS
        _cLojtransp:= ZL0->ZL0_FRETLJ
        _lAchouMoto:= .T.

        If !Empty(_cTransI+_cTraLoI) .AND. _cCodtransp+_cLojtransp < _cTransI+_cTraLoI
            LOOP//Na Viagem
        EndIf

        If !Empty(_cTransF+_cTraLoF) .AND. _cCodtransp+_cLojtransp > _cTransF+_cTraLoF
            LOOP//Na Viagem
        EndIf

        EndIf

   EndIf
   ////////////////////////// FILTRO DOS ATENDIMENTOS //////////////////////////////////////////////////////////////////////////////

   ////////////////////////// VALIDACAO E FILTRO //////////////////////////////////////////////////////////////////////////////
   _cMotivo:=""
   _cRecusa:=""
   _cAviso :=""
   _lLoopViagem:=.F.
   _lPodeMarcar:=.T.

   _cLINROT:=_cRotaReb
   _cSetor	:=POSICIONE("ZL3",1,_cFilial + _cLINROT,"ZL3_SETOR")

   If !Empty(_cSetor)//Tem que trazer os setores em branco senao ele traz só os setores preenchidos de uma viagem e aceita
      If !Empty(_cSetorI) .AND. _cSetor < _cSetorI
         _lLoopViagem:=.T.
         LOOP
      EndIf
      If !Empty(_cSetorF) .AND. _cSetor > _cSetorF
         _lLoopViagem:=.T.
         LOOP
      EndIf
   EndIf

   If !Empty(_cLINROT)//Tem que trazer as linhas em branco senao ele traz só as linhas preenchidas de uma viagem e aceita
      If !Empty(_cLinhaI) .AND. _cLINROT < _cLinhaI
         _lLoopViagem:=.T.
         LOOP
      EndIf
      If !Empty(_cLinhaF) .AND. _cLINROT > _cLinhaF
         _lLoopViagem:=.T.
         LOOP
      EndIf
   EndIf

   If Empty(_cSETOR)//No proximo For ele identifica quais atendiemntos estao sem setor
      _lPodeMarcar:=.F.
   EndIf

   If _lLoopViagem
      LOOP //Na Viagem
   EndIf
   ////////////////////////// VALIDACAO E FILTRO //////////////////////////////////////////////////////////////////////////////

   _cViagemMae:=""

   If ValType( XmlChildEx( _aXml[_nI] , "_CUSTOMFIELD" ) ) == 'A'

      For _nX := 1 To Len( _aXml[_nI]:_CUSTOMFIELD )

          If ValType( XmlChildEx( _aXml[_nI]:_CUSTOMFIELD[_nX] , "_CODIGO" ) ) <> 'U'

             If _aXml[_nI]:_CUSTOMFIELD[_nX]:_CODIGO:TEXT == "PESO_INICIAL"

                _nPesIni := Val( _aXml[_nI]:_CUSTOMFIELD[_nX]:_VALORNUMERICO:TEXT )

             EndIf

          EndIf

          If ValType( XmlChildEx( _aXml[_nI]:_CUSTOMFIELD[_nX] , "_CODIGO" ) ) <> 'U'

             If _aXml[_nI]:_CUSTOMFIELD[_nX]:_CODIGO:TEXT == "PESO_FINAL"

                _nPesFim := Val( _aXml[_nI]:_CUSTOMFIELD[_nX]:_VALORNUMERICO:TEXT )

             EndIf

          EndIf

          If ValType( XmlChildEx( _aXml[_nI]:_CUSTOMFIELD[_nX] , "_CODIGO" ) ) <> 'U'

             If _aXml[_nI]:_CUSTOMFIELD[_nX]:_CODIGO:TEXT == "MEDIDOR_VAZAO"

                _nMedVaz := Val( _aXml[_nI]:_CUSTOMFIELD[_nX]:_VALORNUMERICO:TEXT )

             EndIf

          EndIf

          If ValType( XmlChildEx( _aXml[_nI]:_CUSTOMFIELD[_nX] , "_CODIGO" ) ) <> 'U'

          	  If _aXml[_nI]:_CUSTOMFIELD[_nX]:_CODIGO:TEXT == "DESCARTE"

                 _lDescarte :=  IIF(_aXml[_nI]:_CUSTOMFIELD[_nX]:_VALORBOLEANO:TEXT == 'false', .F., .T.)

             EndIf

          EndIf

          If ValType( XmlChildEx( _aXml[_nI]:_CUSTOMFIELD[_nX] , "_CODIGO" ) ) <> 'U'

             If _aXml[_nI]:_CUSTOMFIELD[_nX]:_CODIGO:TEXT == "CODIGO_MATRIZ"
                IF Val(_aXml[_nI]:_CUSTOMFIELD[_nX]:_VALORTEXTO:TEXT  ) <> 0
                   _cViagemMae := StrZero( Val(_aXml[_nI]:_CUSTOMFIELD[_nX]:_VALORTEXTO:TEXT  ), Len(ZLJ->ZLJ_VIAGEM) )
                   _cViagemMae := "S"+SUBSTR(_cViagemMae,2)
                ENDIF
             EndIf

          EndIf

      Next _nX

   ElseIf ValType( XmlChildEx( _aXml[_nI] , "_CUSTOMFIELD" ) ) <> 'U'

       If ValType( XmlChildEx( _aXml[_nI]:_CUSTOMFIELD , "_CODIGO" ) ) <> 'U'

          If _aXml[_nI]:_CUSTOMFIELD:_CODIGO:TEXT == "CODIGO_MATRIZ"
             IF Val(_aXml[_nI]:_CUSTOMFIELD:_VALORTEXTO:TEXT ) <> 0
                _cViagemMae := StrZero( Val(_aXml[_nI]:_CUSTOMFIELD:_VALORTEXTO:TEXT ), Len(ZLJ->ZLJ_VIAGEM) )
                _cViagemMae := "S"+SUBSTR(_cViagemMae,2)
             ENDIF
          EndIf

       EndIf

   EndIf

   If Empty(_cViagemMae)
      MGLT002LogGrv(.F.,'Viagem recusada: [ Viagem Sem Atendimentos cadastrados] ',.T.)
      LOOP
   EndIf

   If ValType( XmlChildEx( _aXml[_nI] , "_DATAHORAINICIODIA"	) ) <> 'U'
      _dDtIni := StoD( StrTran( SubStr( _aXml[_nI]:_DATAHORAINICIODIA:TEXT , 1 , 10 ) , '-' , '' ) )
      _cHrIni := SubStr( _aXml[_nI]:_DATAHORAINICIODIA:TEXT , 12 , 08 )
   EndIf

   If ValType( XmlChildEx( _aXml[_nI] , "_DATAHORAFIMDIA"		) ) <> 'U'
      _dDtFim := StoD( StrTran( SubStr( _aXml[_nI]:_DATAHORAFIMDIA:TEXT , 1 , 10 ) , '-' , '' ) )
      _cHrFim := SubStr( _aXml[_nI]:_DATAHORAFIMDIA:TEXT , 12 , 08 )
   EndIf

   _nKm:=0
   If ValType( XmlChildEx( _aXml[_nI] , "_DISTANCIASHAPEKM"	) ) <> 'U'
      _nKm := Round( Val( _aXml[_nI]:_DISTANCIASHAPEKM:TEXT ) , 0 )
   EndIf

   /////////////////////\/\/\/\/\/ VALIDACAO DA VIAGEM \/\/\/\/\/\/\/\///////////////////////////////////////////////////////////////////////
   If Empty(_cViagemMae) .AND. _nPesIni < _nPesFim//Quando é Julieta vale os valores da Mãe //Peso Cheio For menos que peso vazio pois devem ter didigtado ao contrario
	  _cRecusa += "[Volume Negativo: P.Cheio: "+ALLTRIM(TRANSF(_nPesIni,"@E 999,999,999"))+" - P.Vazio: "+ALLTRIM(TRANSF(_nPesFim,"@E 999,999,999"))+"] "
	  _lPodeMarcar:=.F.
   ElseIf Empty(_cViagemMae) .AND. (_nPesIni -_nPesFim) = 0 .AND. _nMedVaz = 0 //Quando é Julieta vale os valores da Mãe //Se esse valores vierem zerados não tem como dar entrada no estoque                                                                                            
      _cRecusa += "[Peso Cheio - Peso Vazio e Medidor de Vazão zerados] "
	  _lPodeMarcar:=.F.
   ElseIf Empty(_cViagemMae) .AND. (_nPesIni -_nPesFim) # 0 .AND. _nMedVaz # 0 //Quando é Julieta vale os valores da Mãe //Se esse valores vierem zerados não tem como dar entrada no estoque                                                                                            
      _cRecusa += "[Peso Cheio - Peso Vazio e Medidor de Vazão: todos preenchidos]"
	  _lPodeMarcar:=.F.
   EndIf

   If !_lAchouMoto
      _cRecusa += '[Codigo "'+_cFilial+' '+_cMotorista+' '+_cMotFilial+'" não existe no cadastro de motoristas] '
      _lPodeMarcar:=.F.
      _lAchouMoto:=.F.
   ElseIf !(_cMotFilial == _cFilial)
      _cRecusa += "[Filial do Reboque "+_cFilial+" difere da Filial do Motorista "+_cMotFilial+"] "
      _lPodeMarcar:=.F.
      _lAchouMoto:=.F.//Já que vai rejeitar nao precisa fazer o While do ZL1
   EndIf

   If Empty(_cCodtransp) .OR. !SA2->(DBSEEK(Xfilial("SA2")+_cCodtransp+_cLojtransp)) .OR. (SA2->A2_MSBLQL == '1' .Or. SA2->A2_L_ATIVO == 'N')
      _cRecusa += "[Transportador: "+_cCodtransp +' '+ _cLojtransp+" nao cadastrado, bloqueado ("+SA2->A2_MSBLQL+") ou inativo (Ativo = "+SA2->A2_L_ATIVO+")] "
      _lPodeMarcar:=.F.
   EndIf

   //Verifica se placa está no cadastro de motoristas
   _cPlacaS:=""
   _cPlacaC:=SPACE(Len(ZLJ->ZLJ_PLACA))
	If ValType( XmlChildEx( _aXml[_nI] , "_VEICULOPRIMARIO"	) ) <> 'U'
      If ValType( XmlChildEx( _aXml[_nI]:_VEICULOPRIMARIO , "_PLACA" ) ) <> 'U'
         _cPlacaS:= LEFT(StrTran( AllTrim( _aXml[_nI]:_VEICULOPRIMARIO:_PLACA:TEXT ) , '-' , '' ),7)//Peguei o 7 primeiro pq estava vindo com caracter especial no final
         _cPlacaC:= SubStr( _cPlacaS, 1 , 3 ) +'-'+ SubStr( _cPlacaS, 4 )
      EndIf
   EndIf

   _cPlacaRS   :=SPACE(Len(ZL1->ZL1_PLCREB))//PLACA REBOQUE
   _cPlacaRC   :=SPACE(Len(ZL1->ZL1_PLCREB))//PLACA REBOQUE
	If ValType( XmlChildEx( _aXml[_nI] , "_VEICULOREBOQUE"	) ) <> 'U'
      If ValType( XmlChildEx( _aXml[_nI]:_VEICULOPRIMARIO , "_PLACA" ) ) <> 'U'
	      _cPlacaRS:= LEFT(StrTran( AllTrim( _aXml[_nI]:_VEICULOPRIMARIO:_PLACA:TEXT ) , '-' , '' ),7)//Peguei o 7 primeiro pq estava vindo com caracter especial no final
      	_cPlacaRC:= SubStr( _cPlacaS, 1 , 3 ) +'-'+ SubStr( _cPlacaS, 4 )
      EndIf
   EndIf


   _cVeiculo:=""
   _lAchouPlaca:=.F.
   ZL1->( DBSetOrder(2))
   If _lAchouMoto .AND. ZL1->( DBSeek( _cFilial + _cPlacaS ) )
      DO While ZL1->(!EOF()) .AND. _cFilial + _cPlacaS == ZL1->ZL1_FILIAL + ZL1->ZL1_PLACA
         If ZL1->ZL1_MOTORI == _cMotorista .AND. _cPlacaRS == ZL1->ZL1_PLCREB 
            _cVeiculo   :=ZL1->ZL1_COD
            _lAchouPlaca:=.T.
            Exit
         EndIf
         ZL1->(DBSKIP())
      EndDo
   EndIf

   If !_lAchouPlaca
      _cRecusa += '[Placas "' +_cFilial+' '+ _cPlacaC + " / "+_cPlacaRS + '" + Motorista "'+_cMotorista+' '+_cMotFilial+'" não encontrado] '
      _lPodeMarcar:=.F.
   EndIf

   _lViagemAceita:=.F.

   If ZLJ->(FIELDPOS("ZLJ_VFILHA")) # 0
      ZLJ->( DBSetOrder(6) )//ZLJ_FILIAL+ZLJ_VIAGEM+ZLJ_VFILHA
   Else
      ZLJ->( DBSetOrder(2) )
   EndIf
   
   _lconcorr := .F.
   _ctread := ""
  		        
   ZLK->(DBSetOrder(1))
   If ZLK->(Dbseek(_cFilial)) //+ If(!Empty(_cViagemMae), _cViagemMae+_cVIAGEM , _cVIAGEM+SPACE(LEN(ZLJ->ZLJ_VFILHA)))
  		        
       	If !ZLK->(MsRLock(ZLK->(RECNO())))
  		        	
       		_lconcorr := .T.
      		_ctread := ZLK->ZLK_THREAD
            _cuser  := ALLTRIM(ZLK->ZLK_USUSAR)
  		        		
       	Else
  		        	
       		ZLK->(Reclock("ZLK",.F.))
       	   ZLK->ZLK_VIAGEM := _cFilial+"-"+DTOC(DATE())+"-"+TIME()// + If(!Empty(_cViagemMae), _cViagemMae+_cVIAGEM , _cVIAGEM+SPACE(LEN(ZLJ->ZLJ_VFILHA))) 
       		ZLK->ZLK_THREAD := strzero(ThreadID(),6)
       		ZLK->ZLK_USUSAR := _cZLJ_UINTSQ
  		   	ZLK->(Msunlock())
  		   	ZLK->(Reclock("ZLK",.F.))
  		        		
       	EndIf
  		        	
   Else
  		        
       	ZLK->(Reclock("ZLK",.T.))
         ZLK->ZLK_FILIAL := _cFilial
       	ZLK->ZLK_VIAGEM := _cFilial+"-"+DTOC(DATE())+"-"+TIME()// + If(!Empty(_cViagemMae), _cViagemMae+_cVIAGEM , _cVIAGEM+SPACE(LEN(ZLJ->ZLJ_VFILHA))) 
       	ZLK->ZLK_THREAD := strzero(ThreadID(),6)
       	ZLK->ZLK_USUSAR := _cZLJ_UINTSQ
       	ZLK->(ZLK->(Msunlock()))
       	ZLK->(Reclock("ZLK",.F.))
  		        	
   EndIf
  		        
   If _lconcorr
  		        
       _lPodeMarcar:=.F.
       _cAviso += "Viagem sendo integrada pela thread [" + _ctread + "] do usuário [" + _cuser + "]"
                                                                             //Tem que procurar a Mae com a filha em brnaco senão ele acha a as linhas da filhas já integradas
   ElseIf ZLJ->( DBSeek( _cFilial + If(!Empty(_cViagemMae), _cViagemMae+_cVIAGEM , _cVIAGEM+SPACE(LEN(ZLJ->ZLJ_VFILHA)) ) ) )               

      If(_nKm < 0,_nKm := 0,)//Zerei antes por que se tiver zerado tb no protheus, nao precisa atualizar

      If _nKm = ZLJ->ZLJ_KMDVIA
         _lPodeMarcar:=.F.
         _cAviso += "Viagem Integrada Anteriormente: [KM = Protheus: "+ALLTRIM(TRANSF(ZLJ->ZLJ_KMDVIA,"@E 999,999,999"))+"] "
      Else
         _lPodeMarcar:=.T.//Se já tiver recusas pode aceitar a viagem já integrada
         _lViagemAceita:=.T.//Variavel para a validacao do setor nao rejeitar essa viagem
         _cAviso += "Viagem Integrada Anteriormente: [KM # Protheus: "+ALLTRIM(TRANSF(ZLJ->ZLJ_KMDVIA,"@E 999,999,999"))+"] "
      EndIf

   Else

      If _nKm < 0
         _cAviso += "KM Negativa: [Km Rastreado: "+ALLTRIM(TRANSF(_nKm,"@E 999,999,999"))+" ] "
      EndIf

   EndIf

   If _nKm < 0
      _nKm := 0
   EndIf
   /////////////\/\/\/\/\/\/\/\/\//\/\/\ VALIDACAO DA VIAGEM /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\//////////////////////////////////////////////

   //////////////////////////////////////////////////////////// INICIO DO For DA GRAVACAO NO TRB //////////////////////////////////////////////////////////////

   //Grava tabela temporária
   TRB_ZLJ->(DBAPPEND())
   TRB_ZLJ->WK_DATA   := CTOD(_cDataLendo)
   TRB_ZLJ->WK_HORA   := SubStr( _aXml[_nI]:_DATAHORAULTIMAMODIFICACAO:TEXT , 12 , 8 )
   TRB_ZLJ->ZLJ_FILIAL:= _cFilial
   If !Empty(_cViagemMae) .AND. ZLJ->(FIELDPOS("ZLJ_VFILHA")) # 0
      TRB_ZLJ->ZLJ_VIAGEM := _cViagemMae
      TRB_ZLJ->ZLJ_VFILHA := _cVIAGEM
   Else
      TRB_ZLJ->ZLJ_VIAGEM := _cVIAGEM
   EndIf

   TRB_ZLJ->ZLJ_DTCRIA	:= _dDtIni//onde grava a data entrada no estoque: ZLJ_DTCRIA --> D3_EMISSAO / ZLW_DTLANC
   TRB_ZLJ->ZLJ_HRCRIA	:= _cHrIni
   TRB_ZLJ->ZLJ_DTINI	:= _dDtIni
   TRB_ZLJ->ZLJ_HRINI	:= _cHrIni
   TRB_ZLJ->ZLJ_DTFIM	:= _dDtFim
   TRB_ZLJ->ZLJ_HRFIM	:= _cHrFim
   TRB_ZLJ->ZLJ_TIPVIS	:= 'C'
   TRB_ZLJ->ZLJ_USRSMQ	:= IIF( ValType( XmlChildEx( _aXml[_nI]:_USUARIO , "_CODIGO") ) <> 'U', AllTrim( _aXml[_nI]:_USUARIO:_CODIGO:TEXT), '' )
   TRB_ZLJ->ZLJ_LOGINS	:= IIF( ValType( XmlChildEx( _aXml[_nI]:_USUARIO , "_LOGIN" ) ) <> 'U', AllTrim( _aXml[_nI]:_USUARIO:_LOGIN:TEXT ), '' )
   TRB_ZLJ->ZLJ_STATUS	:= "P"
   TRB_ZLJ->ZLJ_DTIVIA	:= _dDtIni//data de coleta do ZLD: ZLJ_DTIVIA --> ZLD->ZLD_DTCOLE / ZLW->ZLW_DTCOLE
   TRB_ZLJ->ZLJ_HRIVIA	:= _cHrIni
   TRB_ZLJ->ZLJ_DTFVIA	:= _dDtFim
   TRB_ZLJ->ZLJ_HRFVIA	:= _cHrFim
   TRB_ZLJ->ZLJ_PSIVIA	:= _nPesIni
   TRB_ZLJ->ZLJ_PSFVIA	:= _nPesFim
   TRB_ZLJ->ZLJ_LITRAG	:= _nMedVaz

   _cMemAux   :=""

   _cLinhaRota:=_cRotaReb

   TRB_ZLJ->ZLJ_TIPPRO := "R"

   _cSetor:=POSICIONE("ZL3",1,_cFilial+_cLinhaRota,"ZL3_SETOR")

   TRB_ZLJ->ZLJ_KMDVIA:= _nKm
   TRB_ZLJ->ZLJ_LINROT:=_cLinhaRota
   If Empty(TRB_ZLJ->ZLJ_LINROT)
      _cMemAux+=" [Linha/Rota nao encontrada Chave: "+xFilial("SA2")+_cCodPat+_cLojPat+"] "
      _lPodeMarcar:=_lViagemAceita
   EndIf

   TRB_ZLJ->ZLJ_SETOR :=_cSetor
   If !Empty(TRB_ZLJ->ZLJ_LINROT) .AND. Empty(TRB_ZLJ->ZLJ_SETOR)
      _cMemAux+=" [Setor nao encontrado Chave: "+_cFilial+' '+_cLinhaRota+"] "
      _lPodeMarcar:=_lViagemAceita
   ElseIf MGLT002R( _dDtIni , _cSETOR )
      _cMemAux += "[Setor: "+_cSETOR+" possui lançamento de algum evento na data ["+DTOC(_dDtIni)+"] "
      _lPodeMarcar:=_lViagemAceita
   EndIf

   TRB_ZLJ->ZLJ_DESCAR:= _lDescarte
   TRB_ZLJ->ZLJ_PLACA := _cPlacaS//Grava placa aqui pq tem uma coluna na tela para mostrar

   If _lAchouPlaca .AND. _lAchouMoto
      TRB_ZLJ->ZLJ_MOTORI:= _cMotorista//Esse campo virou real pois vem do SQ
      TRB_ZLJ->ZLJ_VEICUL:= _cVeiculo
      TRB_ZLJ->ZLJ_CODTRN:= _cCodtransp
      TRB_ZLJ->ZLJ_LOJTRN:= _cLojtransp
      TRB_ZLJ->ZLJ_DTRAN := POSICIONE("SA2",1,XFILIAL("SA2")+_cCodtransp+_cLojtransp,"A2_NOME")
   EndIf
   If _lPodeMarcar
      _cMotivo := "Atendimento OK"
      If !Empty(_cAviso+_cRecusa)
         _cMotivo += ": "+_cAviso+_cRecusa
      EndIf
   Else
      _cMotivo := "Viagem Recusada"
      If !Empty(_cRecusa+_cAviso)
         _cMotivo += ": "+_cRecusa+_cAviso
      EndIf
   EndIf

   MGLT002LogGrv(_lPodeMarcar,_cMotivo+_cMemAux,.F.)
   _cMotivo :=""
   ////////////////////////////// FIM DA GRAVACAO NO TRB /////////////////////////////////////////////////////
Next _nI
///*********************************////  TRATAMENTO DO REBOQUE \\\\*********************************////
//\\*//\\*//\\***********************************************************************************//\\*//\\*//\\

//*\\//*\\//*\\//***********************************************************************************\\//*\\//*\\//
///*********************************////  VALIDACAO DO ESTOQUE E JULIETAS ///**********************************////
If !_lShedule
   _oProcess:SetRegua1(TRB_ZLJ->(Lastrec()))
   _oProcess:SetRegua2(TRB_ZLJ->(Lastrec()))
EndIf
U_ITConOut("3-Lendo Julietas e Estoque: "+ALLTRIM(STR(TRB_ZLJ->(Lastrec())))+" Registros... ")

_aMaes_e_Filhas := {}
_aViagens := {}
_aRecViagens := {}
TRB_ZLJ->(DBGOTOP())
DO While TRB_ZLJ->(!EOF())
	
   If !_lShedule
	  _oProcess:IncRegua1("3-Lendo Estoque Viagem: "+TRB_ZLJ->ZLJ_VIAGEM)
	  _oProcess:IncRegua2("3-Lendo Julietas Viagem: "+TRB_ZLJ->ZLJ_VIAGEM)
   ElseIf _lIDESENV
   	  U_ITConOut("3-Lendo Julietas Viagem: "+TRB_ZLJ->ZLJ_VIAGEM)
   EndIf

   If Empty(TRB_ZLJ->WK_MARCA) .OR. TRB_ZLJ->ZLJ_STATUS # 'P'//Só faz em cima dos que estao OK
      TRB_ZLJ->(DBSKIP())
      LOOP
   EndIf

   If !Empty(TRB_ZLJ->ZLJ_VFILHS)//é Mãe

      If (nMae:=ASCAN(_aMaes_e_Filhas,{|M| M[1] == TRB_ZLJ->ZLJ_VIAGEM .AND.  M[4] == TRB_ZLJ->ZLJ_FILIAL })) = 0
         AADD(_aMaes_e_Filhas, { TRB_ZLJ->ZLJ_VIAGEM , ALLTRIM(TRB_ZLJ->ZLJ_VFILHS) , "" , TRB_ZLJ->ZLJ_FILIAL } )//Filhas que esta na lista da Mae
      Else
         _aMaes_e_Filhas[nMae,2]:=ALLTRIM(TRB_ZLJ->ZLJ_VFILHS)//Atualiza pq a Mãe pode esta depois da filha na ordem de leitura
      EndIf

   ElseIf !Empty(TRB_ZLJ->ZLJ_VFILHA)//É Filha

      If (nMae:=ASCAN(_aMaes_e_Filhas,{|M| M[1] == TRB_ZLJ->ZLJ_VIAGEM  .AND.  M[4] == TRB_ZLJ->ZLJ_FILIAL })) = 0
         AADD(_aMaes_e_Filhas, { TRB_ZLJ->ZLJ_VIAGEM , "" , TRB_ZLJ->ZLJ_VFILHA+"-" , TRB_ZLJ->ZLJ_FILIAL } )//pode encontrar uma filha antes da mãe na ordem de leitura
      ElseIf !TRB_ZLJ->ZLJ_VFILHA $ _aMaes_e_Filhas[nMae,3]//Para não repetir para cada atendimento
         _aMaes_e_Filhas[nMae,3]+=TRB_ZLJ->ZLJ_VFILHA+"-"//Lista das Filhas encontradas
      EndIf

   EndIf
		
   MGLT2AcumulaEstoque("TRB_ZLJ")
		
   TRB_ZLJ->(DBSKIP())
	
EndDo
If !_lShedule
   _oProcess:SetRegua1( LEN(_aViagens) )
   _oProcess:SetRegua2( LEN(_aMaes_e_Filhas) )
EndIf
U_ITConOut("4-Validando Estoque Viagem "+ALLTRIM(STR(LEN(_aViagens)))+" Registros... ")

For _nI := 1 to len(_aViagens)
	
	If !_lShedule
		_oProcess:IncRegua1("4-Validando Estoque Viagem: "+_aViagens[_ni][1])
	ElseIf _lIDESENV
		U_ITConOut("4-Validando Estoque Viagem: "+_aViagens[_ni][1])
	EndIf
	
	If _aViagens[_ni][08]//Se For descarte
		LOOP
	EndIf

    If !_aViagens[_ni][10]//Se nao Tem Leite Proprio
       LOOP
    EndIf
	
	// Volume do veiculo - o total da cooperativa  = Volume do leite proprio com a diferença
	nTotBom := _aViagens[_ni][9] - _aViagens[_ni][3]
	
	If nTotBom <= 0
		
       If POSICIONE("ZA7",1,_aViagens[_ni][07]+"001","ZA7_DENPAD") <= 0
          _cMotivo:="Viagem Recusada: [Densidade cadastrada na filial "+_aViagens[_ni][07]+" Inválida, volume: "+ALLTRIM(TRANSF(nTotBom,"@E 999,999,999"))+" L]"
       Else
          _cMotivo:="Viagem Recusada: [Volume de Entrada de Estoque Inválido: "+ALLTRIM(TRANSF(nTotBom,"@E 999,999,999"))+" L]"
       EndIf

       If (_nPos:=Ascan(_aRecViagens,{|aVal| aVal[1] == _aViagens[_ni][1] .AND. aVal[2] == _aViagens[_ni][7] })) # 0

           _aRecTRB:=_aRecViagens[_nPos,3]

           For T := 1 TO LEN(_aRecTRB)

               TRB_ZLJ->(DBGOTO(_aRecTRB[T]))
               
               MGLT002LogGrv(.F.,_cMotivo,.F.)
               _nConta--//Desconta pq já foi aceito no primeiro For

           Next
       
       Else//Previnir Algum erro lógico

           TRB_ZLJ->(DBGOTO(_aViagens[_ni][14]))
           MGLT002LogGrv(.F.,_cMotivo,.F.)
           _nConta--//Desconta pq já foi aceito no primeiro For
       
	   EndIf
		
	EndIf
	
Next _nI

U_ITConOut("4-Validando Julietas Viagem: "+ALLTRIM(STR(LEN(_aMaes_e_Filhas)))+" Registros... ")

For _nI := 1 to len(_aMaes_e_Filhas)
	
	If !_lShedule
		_oProcess:IncRegua2("4-Validando Julietas Viagem: "+_aViagens[_ni][1])
	ElseIf _lIDESENV
		U_ITConOut("4-Validando Julietas Viagem: "+_aViagens[_ni][1])
	EndIf
    
    _lJulietaOK:=.T.
         //Se tem filhas                e    não tem a lista da mãe
    If !Empty(_aMaes_e_Filhas[_nI,3]) .AND. Empty(_aMaes_e_Filhas[_nI,2])
       _cMotivo:="Viagem Recusada: [Viagem Mãe não Integrada/Aceita no mesmo periodo]"
       _lJulietaOK:=.F.
    EndIf

    _aFilhasMae := STRTOKARR(_aMaes_e_Filhas[_nI,2],"-")//Lista das filhas da mãe ATUAL
    _cFilhasNaoIntegradas:=""
    _cFilhasdeOutraMae:=""
    ZLJ->( DbOrderNickName("FILHADAMAE") )// 7 - ZLJ_FILIAL+ZLJ_VFILHA+ZLJ_VIAGEM
    For F := 1 TO LEN(_aFilhasMae)//LENDO CADA FILHA
        
        //********* Verifica Filha da mae não encontrada na integração atual ********* 
        If !_aFilhasMae[F] $ _aMaes_e_Filhas[_nI,3]
           _cFilhasNaoIntegradas+=_aFilhasMae[F]+", "
        ENDIF
        
        //********* Verifica Filha da mãe já cadastrada para outra mãe ********* 
        For _nFoM := 1 to len(_aMaes_e_Filhas)//Ver se cada filha não está em outra viagem mãe na integração atual
            If !(_aMaes_e_Filhas[_nI,1] == _aMaes_e_Filhas[_nFoM,1])//Igora a mãe atual e ve as outraS mães
               If _aFilhasMae[F] $ _aMaes_e_Filhas[_nFoM,3]//Filha em outra mãe
                  _cFilhasdeOutraMae+="F: "+_aFilhasMae[F]+"/M: "+_aMaes_e_Filhas[_nFoM,1]+", "
               Endif
            Endif
        Next _nFoM
        
        ///*********  Ver se cada filha não está em outra viagem mãe já integrada /********* 
                                   //ZLJ_FILIAL + ZLJ_VFILHA      
        IF ZLJ->(DBSEEK( _aMaes_e_Filhas[_nI,4] + _aFilhasMae[F] ))//ZLJ_FILIAL+ZLJ_VFILHA+ZLJ_VIAGEM
           DO WHILE ZLJ->(!EOF()) .AND.  _aMaes_e_Filhas[_nI,4] + _aFilhasMae[F] == ZLJ->ZLJ_FILIAL+ZLJ->ZLJ_VFILHA
              IF _aMaes_e_Filhas[_nI,1] <> ZLJ->ZLJ_VIAGEM .AND. !ZLJ->ZLJ_VIAGEM $ _cFilhasdeOutraMae// Ve se a mae da filha atual é diferente de uma já cadastrada e se ela já não tá na lista atual (_cFilhasdeOutraMae)
                 _cFilhasdeOutraMae+="*F: "+_aFilhasMae[F]+"/*M: "+ZLJ->ZLJ_VIAGEM+", "
              ENDIF
              ZLJ->(DBSKIP())
           ENDDO
        Endif

    Next F
    _cFilhasNaoIntegradas:=LEFT(_cFilhasNaoIntegradas,LEN(_cFilhasNaoIntegradas)-2)
    _cFilhasdeOutraMae   :=LEFT(_cFilhasdeOutraMae   ,LEN(_cFilhasdeOutraMae   )-2)

    If !Empty(_cFilhasdeOutraMae) .AND. !Empty(_cFilhasNaoIntegradas)
       _cMotivo:="Viagem Recusada: [Viagen(s) Filha(s) em outra Mae: "+_cFilhasdeOutraMae+"] [Viagen(s) Filha(s) não Integradas/Aceitas: "+_cFilhasNaoIntegradas+" no mesmo periodo]"
       _lJulietaOK:=.F.
    ElseIf !Empty(_cFilhasdeOutraMae)
       _cMotivo:="Viagem Recusada: [Viagen(s) Filha(s) em outra Mae: "+_cFilhasdeOutraMae+"]"
       _lJulietaOK:=.F.
    ElseIf !Empty(_cFilhasNaoIntegradas)
       _cMotivo:="Viagem Recusada: [Viagen(s) Filha(s) não Integradas/Aceitas: "+_cFilhasNaoIntegradas+" no mesmo periodo]"
       _lJulietaOK:=.F.
    EndIf

    If !_lJulietaOK
    
       If (_nPos:=Ascan(_aRecViagens,{|aVal| aVal[1] == _aMaes_e_Filhas[_ni][1] .AND. aVal[2] == _aMaes_e_Filhas[_ni][4] })) # 0

           _aRecTRB:=_aRecViagens[_nPos,3]

           For T := 1 TO LEN(_aRecTRB)

               TRB_ZLJ->(DBGOTO(_aRecTRB[T]))
               
               MGLT002LogGrv(.F.,_cMotivo,.F.)
               _nConta--//Desconta pq já foi aceito no primeiro For

           Next T
       
       Else//Previnir Algum erro lógico

           TRB_ZLJ->(DBGOTO(_aViagens[_ni][14]))
           MGLT002LogGrv(.F.,_cMotivo,.F.)
           _nConta--//Desconta pq já foi aceito no primeiro For
       
	   EndIf
       
    EndIf
		
Next _nI

If _nConta <= 0//Previnir Algum erro lógico
   _nConta:=0
EndIf
///*****************************////  VALIDACAO DO ESTOQUE E JULIETAS ///**********************************////
//\\*//\\*//\\***********************************************************************************//\\*//\\*//\\

_nTimeOutSQ:=SuperGetMV("LT_WEBSQTO",.F.,90)

_lRetorno:=.T.
BEGIN SEQUENCE

   If TRB_ZLJ->(EOF()) .AND. TRB_ZLJ->(BOF())
      ZLK->(Msunlock())
      ZLK->(MsunlockAll())//Destrava todas as filiais travadas
      If !_lShedule
      	 MsgAlert("Não foram encontrados registros para processar! Selecione outros filtros","MGLT00205")
      Else
         MGLT002EML('1-Não foram encontrados registros para processar' )
      EndIf
      U_ITConOut('1-Não foram encontrados registros para processar!')
      _lRetorno:=.F.
      BREAK
   EndIf

   If !Empty(_cViagIgoradas)
      _cViagIgoradas :="Viagens Ignoradas por Setor: "+LEFT(_cViagIgoradas,LEN(_cViagIgoradas)-1)
   EndIf
   _cFilSetor     :="Setores Lidos: "+STRTRAN( STRTRAN(_cFilter,"_cSetor == ","") ," .OR. ",",")
   _cSQTimeInicial:=_cTimeInicial
   _cSQTimeFinal  :=TIME()

   If !_lShedule .AND. !MGLT002Tela()
      _lRetorno:=.F.
      BREAK
   EndIf

   _cThreadID:=TIME()//ThreadID()

    If !_lShedule
       _oProcess:SetRegua1(TRB_ZLJ->(Lastrec()))
       _oProcess:SetRegua2(TRB_ZLJ->(Lastrec()))
       _cTimeInicial:=TIME()
    EndIf
    U_ITConOut("5-Calculando Estoque Viagem: "+ALLTRIM(STR(TRB_ZLJ->(Lastrec())))+" Registros... ")

    _nRecusado:=0
    _nConta   :=0
    _aLog     :={}
    _aViagens := {}

    ZLJ->( DBSetOrder(1))//ZLJ_FILIAL+ZLJ_NUMERO
    TRB_ZLJ->(DBGOTOP())
    DO While TRB_ZLJ->(!EOF())
       
       If !_lShedule
          _oProcess:IncRegua1("5-Calculando Estoque Viagem: "+TRB_ZLJ->ZLJ_VIAGEM)
          _oProcess:IncRegua2(STR(_nConta,6)+" Atendimentos Lidos...")
       EndIf
       
       If !Empty(TRB_ZLJ->WK_MARCA) .AND. TRB_ZLJ->ZLJ_STATUS = 'P' 
          
          //Codigo de segurança para não integrar nada das reusadas e Efetivadas
          ZLJ->( DBSetOrder(5))//ZLJ_FILIAL+ZLJ_VIAGEM+ZLJ_TIPPRO+ZLJ_VFILHA+ZLJ_SETOR+ZLJ_LINROT
          If ZLJ->( DBSeek( TRB_ZLJ->ZLJ_FILIAL + TRB_ZLJ->ZLJ_VIAGEM )) .AND. ZLJ->ZLJ_STATUS $ "R,E"
             TRB_ZLJ->(DBSKIP())
             LOOP
          EndIf
          //Codigo de segurança para não integrar nada das reusadas

          If !Empty(TRB_ZLJ->ZLJ_NUMERO)//Atendimento
             ZLJ->( DBSetOrder(1))//ZLJ_FILIAL+ZLJ_NUMERO
             _lAchouZLJ:=ZLJ->( DBSeek( TRB_ZLJ->ZLJ_FILIAL + TRB_ZLJ->ZLJ_NUMERO ) )//Se acha o atendimento atualiza o KM
          Else//Reboque nao tem atendimento
             _lAchouZLJ:=ZLJ->( DBSeek( TRB_ZLJ->ZLJ_FILIAL + TRB_ZLJ->ZLJ_VIAGEM + TRB_ZLJ->ZLJ_TIPPRO + TRB_ZLJ->ZLJ_VFILHA ) )
          EndIf   

          _nConta++
          MGLT2AcumulaEstoque("TRB_ZLJ")               
		  
       Else
          
          If !Empty(TRB_ZLJ->WK_DATA)//Nao conta os appendes extras incluidos no TRB antes da tela de selecao
             _nRecusado++
          EndIf
          If _lShedule
             aAdd( _aLog , {DTOC(TRB_ZLJ->WK_DATA)+" "+ALLTRIM(TRB_ZLJ->WK_HORA),TRB_ZLJ->ZLJ_FILIAL,TRB_ZLJ->ZLJ_VIAGEM,TRB_ZLJ->ZLJ_NUMERO,TRB_ZLJ->ZLJ_SETOR,TRB_ZLJ->ZLJ_LINROT+"/"+TRB_ZLJ->ZLJ_LINHSQ,ALLTRIM(TRANSF(TRB_ZLJ->ZLJ_KMDVIA,"@E 999,999,999")), TRB_ZLJ->ZLJ_MOTIVO,"X",DTOC(TRB_ZLJ->ZLJ_DTCRIA)} )
          EndIf

       EndIf
       
       TRB_ZLJ->(DBSKIP())
    
    EndDo

    If !_lShedule
       _oProcess:SetRegua1( (TRB_ZLJ->(Lastrec()) + LEN(_aViagens)) )
       _oProcess:SetRegua2( (TRB_ZLJ->(Lastrec()) + LEN(_aViagens)) )
       _cTimeInicial:=TIME()
    EndIf
    U_ITConOut("6-Gravando Entrada no Estoque..."+ALLTRIM(STR(LEN(_aViagens)))+" Registros... ")
    _nConta   :=0
    ZLJ->( DBSetOrder(1))//ZLJ_FILIAL+ZLJ_NUMERO
    TRB_ZLJ->( DBSetOrder(2))//ZLJ_FILIAL+ZLJ_VIAGEM

	_cFilold := cFilAnt//Salva a filial atual
	_nEstoque:= 0
    ZLK->(DBSetOrder(1))

	For _nI := 1 to len(_aViagens)

     // Codigo de segurança para não duplicar
  		If ZLK->(Dbseek(_aViagens[_ni][7] ))
  		
  			If !ZLK->(MsRLock(ZLK->(RECNO())))
            LOOP  		        		
  			Else
  			
 			   ZLK->(Reclock("ZLK",.F.))
            ZLK->ZLK_VIAGEM := _aViagens[_ni][7]+"-"+DTOC(DATE())+"-"+TIME()
  			   ZLK->ZLK_THREAD := strzero(ThreadID(),6)
  			   ZLK->ZLK_USUSAR := _cZLJ_UINTSQ
  			   ZLK->(Msunlock())
  			   ZLK->(Reclock("ZLK",.F.))
  				
  			EndIf
  			
  		Else
  		
  			ZLK->(Reclock("ZLK",.T.))
         ZLK->ZLK_FILIAL := _aViagens[_ni][7]
  			ZLK->ZLK_VIAGEM := _aViagens[_ni][7]+"-"+DTOC(DATE())+"-"+TIME()
  			ZLK->ZLK_THREAD := strzero(ThreadID(),6)
  			ZLK->ZLK_USUSAR := _cZLJ_UINTSQ
  			ZLK->(Msunlock())
  			ZLK->(Reclock("ZLK",.F.))
  			
  		EndIf
     // Codigo de segurança para não duplicar

     BEGIN TRANSACTION
     BEGIN SEQUENCE

        _cChave:=_aViagens[_ni][7]+_aViagens[_ni][1]

        If !MGLT2GrvZLJ(_oProcess,_cChave,_lShedule)
           BREAK
        EndIf

        If _aViagens[_ni][08]//Se For descarte
           U_ITConOut("1-Não precisou gravar o estoque dessa Viagem: "+_cChave)
           BREAK
        EndIf

        If !_aViagens[_ni][10]//Se nao Tem Leite Proprio
           aAdd( _aLog , {DTOC(_aViagens[_ni][6]), _aViagens[_ni][7], _aViagens[_ni][1] ,"Entrada do Estoque","","","", 'Não foi gravado o estoque dessa viagem por nao ter leite proprio',"X",DTOC(_aViagens[_ni][13]) } )
           U_ITConOut("2-Não precisou gravar o estoque dessa Viagem: "+_cChave)
           BREAK
        EndIf

        If !_lShedule
           _oProcess:IncRegua1("6-Gravando Entrada no Estoque...")
           _oProcess:IncRegua2("...Viagem: "+_aViagens[_ni][1])
        EndIf

        // Volume do veiculo - o total da cooperativa  = Volume do leite proprio com a diferença
		nTotBom:=_aViagens[_ni][9]-_aViagens[_ni][3] 

		If nTotBom > 0//Variaval USADA DENTRO DA FUNCAO U_AGLT003G
			    
         _aSetores :=_aViagens[_ni][11]
         _nCustoEst:=0
         If LEN(_aSetores) > 1
            For S := 1 to LEN(_aSetores)                       
			   // Total do setor dividido pelo total dos setores multiplicado pela diferenca = Total do setor com a diferenca
               _aSetores[S,2]:= _aSetores[S][3] / _aViagens[_ni][12] * nTotBom
               _nVlrMix      := POSICIONE("ZL2",1,XFILIAL("ZL2")+_aSetores[S,1],"ZL2_ULTMIX")
               _nCustoEst    += (_nVlrMix * _aSetores[S,2])                          
	        Next                    
         EndIf			
			
			 _cErroSche := ""               //Variavel preenchida na funcao U_AGLT003G com o mensagem de erro
			 _cErro2Sche:= "Inicio da Entrada: "+DTOC(DATE())+"-"+TIME()
			 cFilAnt    := _aViagens[_ni][7]//Filial da Viagem para dar entrada de estoque na filial certa
		    cSetor     := _aViagens[_ni][2]//Variavel usada dentro da funcao U_AGLT003G()  // ZLJ_SETOR onde grava D3_L_SETOR
		    dDtColeta  := _aViagens[_ni][4]//Variavel usada dentro da funcao U_AGLT003G()  // onde grava a data entrada no estoque: ZLJ_DTCRIA --> D3_EMISSAO / ZLW_DTLANC

 ////////////////////////////////////////////// GRAVANDO ENTRADA NO ESTOQUE ////////////////////////////////////////////////////////////////////////////////////////
          _lVerificado:=.F.
          If _nTimeOutSQ <> 0 .AND. !_lShedule// VIA JOB
             U_ITConOut("Gravando Entrada no Estoque Via JOB Viagem: "+_cChave)
             _lRet := MGLT2GerEstoque(_nTimeOutSQ,_cChave,_aViagens[_ni][1],_nCustoEst,_oProcess,_aViagens[_ni])//Inicializa controle de timeout do execauto em paralelo
          Else// VIA NORMAL
             U_ITConOut("Gravando Entrada no Estoque Via U_AGLT003G() direto Viagem: "+_cChave)
             _lRet := U_AGLT003G( _aViagens[_ni][1] , 3 , .T. , _nCustoEst ) //Grava movimento de estoque igual a rotina da recepção manual            
          EndIf
 ////////////////////////////////////////////// GRAVANDO ENTRADA NO ESTOQUE ////////////////////////////////////////////////////////////////////////////////////////
            
			 If .NOT._lRet
			
  				Disarmtransaction()
                
			   _cErro2Sche+= " / Final da Entrada: "+DTOC(DATE())+"-"+TIME()
				aAdd( _aLog , {DTOC(_aViagens[_ni][6]), _aViagens[_ni][7], _aViagens[_ni][1] ,"MensagemA Estoque:","","","", 'NAO FOI POSSIVEL GRAVAR O ESTOQUE DESSA VIAGEM ERRO ABAIXO',"EX",DTOC(_aViagens[_ni][13]) } )
				aAdd( _aLog , {DTOC(_aViagens[_ni][6]), _aViagens[_ni][7], _aViagens[_ni][1] ,"MensagemB Estoque:","","","", 'Erro: ['+_cErroSche+']'                                    ,"EX",DTOC(_aViagens[_ni][13]) } )
            IF _lVerificado
				   aAdd( _aLog , {DTOC(_aViagens[_ni][6]), _aViagens[_ni][7], _aViagens[_ni][1] ,"Nao Gravou Estoque:","" ,"",""              ,"Confirmado apos verificacao via consulta","EX",DTOC(_aViagens[_ni][13]) } )
            ENDIF
				aAdd( _aLog , {DTOC(_aViagens[_ni][6]), _aViagens[_ni][7], _aViagens[_ni][1] ,"Tempo Entrada:"    ,"","","", _cErro2Sche                                                 ,"EX",DTOC(_aViagens[_ni][13]) } )

                _cErroSche:="Não foi possível gravar a entrada de estoque da Viagem: "+_aViagens[_ni][1]+CRLF+;
	                        'Erro: ['+_cErroSche+']'
	                        //'Todas as gravacoes de todas as viagens foram canceladas'
             If _lShedule
                MGLT002EML(_cErroSche)
 			    EndIf
		       U_ITConOut(_cErroSche)
				
			Else
                    
 			   _nEstoque++
            cMOTIVO:='Entrada de estoque registrada com SUCESSO por '+_cZLJ_UINTSQ
			   _cErro2Sche+= " / Final da Entrada: "+DTOC(DATE())+"-"+TIME()
				aAdd( _aLog , {DTOC(_aViagens[_ni][6]), _aViagens[_ni][7], _aViagens[_ni][1] ,"Entrada Estoque:",ALLTRIM(TRANSF(nTotBom,"@E 999,999,999"))+" L","","", cMOTIVO    ,"EOK",DTOC(_aViagens[_ni][13]) } )
            IF _lVerificado
				   aAdd( _aLog , {DTOC(_aViagens[_ni][6]), _aViagens[_ni][7], _aViagens[_ni][1] ,"Entrada Estoque:","" ,"",""         , "Confirmada apos verificacao via consulta","_OK",DTOC(_aViagens[_ni][13]) } )
            ENDIF
				aAdd( _aLog , {DTOC(_aViagens[_ni][6]), _aViagens[_ni][7], _aViagens[_ni][1] ,"Tempo Entrada:"  ,""                                            ,"","", _cErro2Sche,"_OK",DTOC(_aViagens[_ni][13]) } )


			EndIf		
		
        Else

  			Disarmtransaction()

         _cErroSche :='Volume de Entrada Inválido: '+ALLTRIM(TRANSF(nTotBom,"@E 999,999,999"))+" L"
		   _cErro2Sche+= " / Final da Entrada: "+DTOC(DATE())+"-"+TIME()
				
			aAdd( _aLog , {DTOC(_aViagens[_ni][6]), _aViagens[_ni][7], _aViagens[_ni][1] ,"Mensagem1 Estoque:","","","",'Não foi possível gravar o estoque dessa viagem erro abaixo',"EX",DTOC(_aViagens[_ni][13]) } )
			aAdd( _aLog , {DTOC(_aViagens[_ni][6]), _aViagens[_ni][7], _aViagens[_ni][1] ,"Mensagem2 Estoque:","","","",'Erro: ['+_cErroSche+']'                                    ,"EX",DTOC(_aViagens[_ni][13]) } )
			aAdd( _aLog , {DTOC(_aViagens[_ni][6]), _aViagens[_ni][7], _aViagens[_ni][1] ,"Tempo Entrada:"    ,"","","",_cErro2Sche                                                 ,"EX",DTOC(_aViagens[_ni][13]) } )

         _cErroSche:="Não foi possível gravar a entrada de estoque da Viagem: "+_aViagens[_ni][1]+CRLF+;
	                  'Erro: ['+_cErroSche+']'
         If _lShedule
            MGLT002EML(_cErroSche)
 			EndIf
		   U_ITConOut(_cErroSche)

		EndIf
    
      END SEQUENCE
      END TRANSACTION
		
	Next _nI
	
	cFilAnt:=_cFilold//Volta a filial atual
    TRB_ZLJ->( DBSetOrder(1))

    ZLK->(Msunlock())
    ZLK->(MsunlockAll())//Destrava todas as filiais travadas

  If Empty( _aLog )
     If !_lShedule
	    MsgAlert("Não foram encontrados registros para processar! Selecione outros filtros","MGLT00206")
     Else
        MGLT002EML( '2-Não foram encontrados registros para processar' )
     EndIf
     U_ITConOut( '2-Não foram encontrados registros para processar!')
     _lRetorno:=.F.
  Else

     _aLog := aSort(_aLog,,,{|x,y| DTOS(CTOD(x[1]))+x[2]+x[3]+x[4]+x[5] < DTOS(CTOD(y[1]))+y[2]+y[3]+y[4]+y[5] })//Ordena por Data + Filial + Viagem + Atendimento + Setor 

     If !_lShedule

		aAdd( _aLog , {DTOC(DATE()), "" , "Obs. 01" , "" , "" , "" , ALLTRIM(STR(_nRecusado,10)), 'Atendimentos Recusados/não selecionados',"OK","" } )
		aAdd( _aLog , {DTOC(DATE()), "" , "Obs. 02" , "" , "" , "" , ALLTRIM(STR(_nConta   ,10)), 'Atendimentos Gravados',"OK"                  ,"" } )
		aAdd( _aLog , {DTOC(DATE()), "" , "Obs. 03" , "" , "" , "" , ALLTRIM(STR(_nEstoque ,10)), 'Entradas em Estoque'  ,"OK"                  ,"" } )
		aAdd( _aLog , {DTOC(DATE()), "" , "Obs. 04" , "" , "" , "" , ""                         , 'SQ Hora Inicial: '+_cSQTimeInicial,"OK"      ,"" } )
		aAdd( _aLog , {DTOC(DATE()), "" , "Obs. 05" , "" , "" , "" , ""                         , 'SQ Hora Final: '+_cSQTimeFinal    ,"OK"      ,"" } )
		aAdd( _aLog , {DTOC(DATE()), "" , "Obs. 06" , "" , "" , "" , ""                         , 'Hora Inicial: '+_cTimeInicial     ,"OK"      ,"" } )
		aAdd( _aLog , {DTOC(DATE()), "" , "Obs. 07" , "" , "" , "" , ""                         , 'Hora Final: '+TIME(),"OK"                    ,"" } )
		aAdd( _aLog , {DTOC(DATE()), "" , "Obs. 08" , "" , "" , "" , ""                         , _cFilSetor           ,"OK"                    ,"" } )

		//Carrega novo array de log sem o campo de ok
		_ni := 1
		_atlog := {}
		
		For _ni := 1 to len(_alog)

			aadd(_atlog,{_alog[_ni][01],;//'Data Lib'
			             _alog[_ni][10],;//'Data Estoque'//onde grava a data entrada no estoque: ZLJ_DTCRIA --> D3_EMISSAO / ZLW_DTLANC
			             _alog[_ni][02],;//'Filial'
			             _alog[_ni][03],;//'Viagem'
			             _alog[_ni][04],;//'Atendimento'
			             _alog[_ni][05],;//'Setor'
			             _alog[_ni][06],;//'Linha'
			             _alog[_ni][07],;//'Km SQ'
			             _alog[_ni][08]})//'Observação'
		Next

      _cObs:="Filiais lidas: "+_cFiltroFilial+CRLF+;
             _cFilSetor+CRLF+;
             'Hora Inicial: '+_cTimeInicial+CRLF+;
             'Hora Final: '+TIME()+CRLF      
      aButtons:={}//                              _cObs,_aLog,_lProcessa,_lFiltra , _cEmail , _lTela  
      bWorkflow    :={|| Processa( {|| MGLT002EML(_cObs,_aLog,.T.       ,.F.      ,         , .T.)}) }
      AADD(aButtons,{"BUDGET"  ,bWorkflow  ,"E-mail Workflow TI"     ,"E-mail Workflow TI"})


        //ITListBox(                 _cTitAux                                                                      , _aHeader                                                             
        U_ITListBox( 'MGLT00207 - Log de Processamento - Integração SmartQuestion - Atendimentos' ,;                    //   , _aCols,_lMaxSiz,_nTipo,_cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons , _aCab , bDblClk , _aColXML , bCondMarca )
                    {'Data Lib','Dt Estoque','Filial','Viagem','Atendimento','Setor','Linha','Km SQ','Observação'} , _atlog  , .T.   , 1      ,      ,         ,;
                    {        40,          40,      40,      40,           55,     40,     40,     40,         200} ,/*_nCampo*/ , /*bOk*/ , /*bCancel*/ ,aButtons )

     Else//Schedule 

        U_ITConOut("Log de Processamento - Integração SmartQuestion  - "+DTOC(DATE())+" - "+TIME()+" - [ "+ALLTRIM(STR(_nConta,10))+" Atendimentos Gravados ]")
        
        _aFilLog:={}
        For _nLog := 1 TO LEN(_aLog)
            If ASCAN(_aFilLog,_aLog[_nLog,2])=0
               AADD(_aFilLog,_aLog[_nLog,2])
            EndIf
        Next
        For _nLog := 1 TO LEN(_aFilLog)//Tem que fazer um array de filial pq o _aLog nao esta por ordem de filial, esta por data

            cFilAnt  :=_aFilLog[_nLog]

            MGLT002EML("Filial lida: "+cFilAnt+" - "+AllTrim( Posicione('SM0',1,cEmpAnt+cFilAnt,'M0_FILIAL') )+CRLF+;
                       _cFilSetor+CRLF+;
                       'Hora Inicial: '+_cTimeInicial+CRLF+;
                       'Hora Final: '+TIME()+CRLF,_aLog, .F. , .T. )
        Next
        
        U_ITConOut("Log de Processamento - Integração SmartQuestion  - "+DTOC(DATE())+" - "+TIME()+" - [ Envio de E-mail's finalizados ]")
         
     EndIf

  EndIf

END SEQUENCE

If(SELECT(cAliasWK) # 0,_otemp:delete(),)

// ------------------------------------------------------------------------------------------ //
// Limpa o Objeto: _oXML Conforme orientado pelo Framework, se faz necessário a utilização //
// do DesClassIntf para que o Objeto realmente seje limpo.                                    //
// Caso contrário, em situações onde existir um grande numero de XMLS Parseados, ocorrera a   //
// mensagem: XML dynamic Nodes Overflow                                                       //
// Antes de executar o comando: DesClassIntf, coloque o objeto como NIL                       //
// ------------------------------------------------------------------------------------------ //
_oXML:=Nil
_aMaes_e_Filhas := _aViagens := _aRecViagens := _aLog := NIL
_aLog := _aXml:=_aXmlReboque := _aFilLog := aCampos := NIL
_aXmlDia:= aHoras:= _aXmlReboque := _aTemRecepcao:= _aTaNoMixAtual:= NIL 
DelClassIntf()

Return _lRetorno

/*
===============================================================================================================================
Programa--------: MGLT002Tela()
Autor-----------: Alex Walaluer
Data da Criacao-: 04/07/2016
Descrição-------: Tela de capa e detalhe
Parametros------: Nenhum
Retorno---------: .T.
===============================================================================================================================
*/
Static Function MGLT002Tela()

Local cAliasWK     :="TRB_ZLJ"
Local aBotoes      :={}
Local aTB_Campos   :={}
Local bMarcaTodos  :={|| MGLT002Marca(cMarca,.T.),oMark:oBrowse:Refresh() }
                                                //_cObs,_aLog,_lProcessa,_lFiltra , _cEmail , _lTela
Local bWorkflow    :={|| Processa( {|| MGLT002EML(cObs ,_aLog,.T.       ,.F.      ,         ,       )}) }
Local aCpoBrowse   :={"ZLJ_DTCRIA","ZLJ_DTIVIA","ZLJ_FILIAL","ZLJ_VIAGEM","ZLJ_TIPPRO","ZLJ_NUMERO","ZLJ_SETOR","ZLJ_LINROT","ZLJ_LINHSQ","ZLJ_PLACA","ZLJ_KMDVIA","ZLJ_MOTIVO","ZLJ_VOLUME","ZLJ_LITRAG","ZLJ_PSIVIA","ZLJ_PSFVIA","ZLJ_CODTRN","ZLJ_LOJTRN","ZLJ_DTRAN","ZLJ_CODPAT","ZLJ_LOJPAT","ZLJ_NOMPAT"}
Local aCoors	   := FWGetDialogSize(oMainWnd)
Local oDlg,oMark,cCampo,I
Local _cTitAux:="Resultado da Integração do SmartQuestion (MGLT002)"
Local aCab:={} ; _aCols:={}

PRIVATE _aCabXML:={}
PRIVATE _aColsXML:={}

AADD(aBotoes,{"RESPONSA",bMarcaTodos,"Marca/Desmarca Todos","Marca/Des Todos"})
AADD(aBotoes,{"BUDGET"  ,bWorkflow  ,"E-mail Workflow TI"     ,"E-mail Workflow TI"})
AADD(aBotoes,{"Exp. Excel"	 ,{|| DlgToExcel( { { "ARRAY" , _cTitAux , aCab , _aCols } } ) }, "Exportação de Dados para Excel"		, "Exp. Excel"		} )
AADD(aBotoes,{"Exp. Arquivo",{|| U_ITGERARQ( _cTitAux , aCab , _aCols ) }					, "Exportação de Dados para Arquivo"	, "Exp. Arquivo"	} )
AADD(aBotoes,{"Exp. XML"	 ,{|| FWMSGRUN( ,{|| U_ITGEREXCEL(,,_cTitAux,,_aCabXML,_aColsXML)} , "Aguarde!" , "Gerando XML..." ) }, "", "Exportação para XML"  	   } )

DBSELECTAREA(cAliasWK)

AADD(aTB_Campos,{"WK_MARCA",,"",})
AADD(aTB_Campos,{"WK_DATA" ,,"Data Lib",})
AADD(aTB_Campos,{"WK_HORA" ,,"Hora Lib",})

For I := 1 TO LEN(aCpoBrowse)
    cCampo:=ALLTRIM(aCpoBrowse[I])
    AADD(aTB_Campos,{cCampo,,AVSX3(cCampo,5),AVSX3(cCampo,6)})
    If cCampo = "ZLJ_KMDVIA"
       aTB_Campos[Len(aTB_Campos),3]:="Km SmartQuestion "
       aTB_Campos[Len(aTB_Campos),4]:="@E 999,999,999,999"
    EndIf
    If cCampo = "ZLJ_DTCRIA"//onde grava a data entrada no estoque: ZLJ_DTCRIA --> D3_EMISSAO / ZLW_DTLANC
       aTB_Campos[Len(aTB_Campos),3]:="Dt Estoque"
    EndIf
    If cCampo = "ZLJ_DTIVIA"//data de coleta do ZLD: ZLJ_DTIVIA --> ZLD->ZLD_DTCOLE / ZLW->ZLW_DTCOLE
       aTB_Campos[Len(aTB_Campos),3]:="Dt Coleta"
    EndIf
    If cCampo = "ZLJ_VIAGEM" .AND. ZLJ->(FIELDPOS("ZLJ_VFILHA")) # 0
       AADD(aTB_Campos,{"ZLJ_VFILHA",,"Viagem Filha",})
    EndIf
    If cCampo = "ZLJ_MOTIVO"
       aTB_Campos[Len(aTB_Campos),3]:="Observações"
    EndIf
    If cCampo = "ZLJ_TIPPRO"
       aTB_Campos[Len(aTB_Campos),1]:={|| U_MGLTTipoProd("TRB_ZLJ")   }
    EndIf
Next
If ZLJ->(FIELDPOS("ZLJ_VFILHS")) # 0
   AADD(aTB_Campos,{"ZLJ_VFILHS",,"Viagem Filhas da Julieta",})
EndIf
AADD(aTB_Campos,{"ZLJ_KM_SQO",,"KM SQ Original",})

TRB_ZLJ->(DBAPPEND())
TRB_ZLJ->ZLJ_MOTIVO:= ALLTRIM(STR(_nRecusado,10))+' Atendimentos Recusados'
TRB_ZLJ->ZLJ_DTCRIA:= DATE()
TRB_ZLJ->ZLJ_STATUS:= "R"
TRB_ZLJ->(DBAPPEND())
TRB_ZLJ->ZLJ_MOTIVO := ALLTRIM(STR(_nConta   ,10))+' Atendimentos Aceitos'
TRB_ZLJ->ZLJ_DTCRIA:= DATE()
TRB_ZLJ->ZLJ_STATUS:= "R"
TRB_ZLJ->(DBAPPEND())
TRB_ZLJ->ZLJ_MOTIVO := 'Hora Inicial: '+_cTimeInicial
TRB_ZLJ->ZLJ_DTCRIA:= DATE()
TRB_ZLJ->ZLJ_STATUS:= "R"
TRB_ZLJ->(DBAPPEND())
TRB_ZLJ->ZLJ_MOTIVO := 'Hora Final: '+TIME()
TRB_ZLJ->ZLJ_DTCRIA:= DATE()
TRB_ZLJ->ZLJ_STATUS:= "R"
TRB_ZLJ->(DBAPPEND())
TRB_ZLJ->ZLJ_MOTIVO:= _cFilSetor
TRB_ZLJ->ZLJ_DTCRIA:= DATE()
TRB_ZLJ->ZLJ_STATUS:= "R"
If !Empty(_cViagIgoradas)
   TRB_ZLJ->(DBAPPEND())
   TRB_ZLJ->ZLJ_MOTIVO:= _cViagIgoradas
   TRB_ZLJ->ZLJ_DTCRIA:= DATE()
   TRB_ZLJ->ZLJ_STATUS:= "R"
EndIf

cObs:=ALLTRIM(STR(_nConta   ,10))+' Atendimentos Aceitos "OK" (verde)'+CRLF
cObs+=ALLTRIM(STR(_nRecusado,10))+' Atendimentos Recusados "X" (vermelho)'+CRLF
cObs+=_cFilSetor+CRLF
cObs+='SQ Hora Inicial: '+_cTimeInicial+CRLF
cObs+='SQ Hora Final: '+TIME()
//Botões de Exportar
AADD(aCab,"Status" )
For I := 2 TO LEN(aTB_Campos)
    AADD(aCab,ALLTRIM(aTB_Campos[ I,3 ]) )
Next
For i := 1 to LEN(aCab)
	// Alinhamento: 1-Left   ,2-Center,3-Right
	// Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
	//          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
	Aadd(_aCabXML,{aCab[i]     ,1           ,1         ,.F.})
Next

TRB_ZLJ->(DBGOTOP())
DO While TRB_ZLJ->(!EOF())

   _aColuna:={}
   AADD(_aColuna, TRB_ZLJ->ZLJ_STATUS )
   For I := 2 TO LEN(aTB_Campos)
       If VALTYPE(aTB_Campos[ I,1 ]) = "C"
          _xConteudo:="TRB_ZLJ->"+ALLTRIM(aTB_Campos[ I,1 ])
          _xConteudo:=&(_xConteudo)
          AADD(_aColuna,_xConteudo )
       Else
          _xConteudo:=EVAL(aTB_Campos[ I,1 ])
          AADD(_aColuna,_xConteudo )
       EndIf   
   Next
   AADD(_aCols, _aColuna )

   TRB_ZLJ->(DBSKIP())    
EndDo

_aColsXML:=ACLONE( _aCols )

//Botões de Exportar
DO While .T.
   nOpca:=0

   oMainWnd:ReadClientCoords()//So precisa declarar uma fez para o Programa todo
   DEFINE MSDIALOG oDlg TITLE "Seleção de Viagens: Versão WebSQ "+If(_lVersaoNew,"14","9") From aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] OF oMainWnd PIXEL

    (cAliasWK)->(DBGOTOP())
    oMark:=MSSELECT():New(cAliasWK,"WK_MARCA","ZLJ_STATUS = 'R'",aTB_Campos,.F.,@cMarca,{21,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})

  	oMark:bAval               := {|| MGLT002Marca(cMarca,.F.),oMark:oBrowse:Refresh() }
  	oMark:oBrowse:bAllMark    := bMarcaTodos
	oMark:oBrowse:lhasMark    := .T.
	oMark:oBrowse:lCanAllmark := .T.
	
   ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg, {|| (nOpca:=1,oDlg:End()) } , {|| (nOpca:=0,oDlg:End()) },,aBotoes) ,;
                                    oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT ,;
                                    oMark:oBrowse:Refresh() )
   If nOpca = 1
      (cAliasWK)->(DBGOTOP()) 
      nTotal:=0
      (cAliasWK)->( DBEVAL( {|| nTotal++ }, {|| !Empty((cAliasWK)->WK_MARCA) } , {|| .T.} ) )
      If nTotal = 0
	     MsgAlert("Não existem registros marcados. Marque pelo menos uma viagem válida para integrar!","MGLT00208")
         LOOP
      EndIf
	  If MsgYesNo("Confirma a Integração? Serão integrados "+ALLTRIM(STR(nTotal,10))+" atendimentos","MGLT00209")
         Exit
      Else
         LOOP
      EndIf
   ElseIf nOpca = 0
	  If MsgYesNo("Confirma o Cancelamento? Todos os dados lidos e processados seram perdidos","MGLT00210")
         Return .F.
      Else
         LOOP
      EndIf
   EndIf

   Exit

EndDo

Return .T.               
/*
===============================================================================================================================
Programa--------: MGLT002Marca()
Autor-----------: Alex Walaluer
Data da Criacao-: 04/07/2016
Descrição-------: Marca TRB
Parametros------: _cMarca: caracteres da marcacao da linha
                  _lTodos: se .T. marca todos se nao só a viagem atual 
Retorno---------: .F.
===============================================================================================================================
*/
Static Function MGLT002Marca(_cMarca,_lTodos)

Local _cMarcaAtual :=If(Empty(TRB_ZLJ->WK_MARCA),_cMarca,"  ")
Local _cViagemMarca:=TRB_ZLJ->ZLJ_VIAGEM
Local _nRegAtual   :=TRB_ZLJ->(RECNO())

If _lTodos
   nRet:=Aviso("MGLT00211 - Selecao de Viagens" , "Clique na opcao desejada para marcar ou desmarcar TODAS as viagens: ", {"Marcar","Desmarcar","Voltar"} ,1 ) 
   If nRet = 1
      _cMarcaAtual :=_cMarca
   ElseIf nRet = 2
      _cMarcaAtual :="  "
   EndIf
   bFor:={|| TRB_ZLJ->ZLJ_STATUS = 'P' } 
Else
   bFor:={|| TRB_ZLJ->ZLJ_STATUS = 'P' .AND. _cViagemMarca == TRB_ZLJ->ZLJ_VIAGEM  } 
EndIf

TRB_ZLJ->(DBGOTOP())
DO While TRB_ZLJ->(!EOF())
   If EVAL(bFor)    
      TRB_ZLJ->WK_MARCA:=_cMarcaAtual
   EndIf                            
   TRB_ZLJ->(DBSKIP())    
EndDo

TRB_ZLJ->(DBGOTO(_nRegAtual))

Return .F.
/*
===============================================================================================================================
Programa--------: MGLT002LogGrv()
Autor-----------: Alex Walaluer
Data da Criacao-: 04/07/2016
Descrição-------: Grava motivo TRB
Parametros------: _lPodeMarcar: .T. marca a linha 
                  _cMotivo    : observacao da linha , lAppend: .T. cria uma linha nova do TRB
Retorno---------: .T.
===============================================================================================================================
*/
Static Function MGLT002LogGrv(_lPodeMarcar,_cMotivo,lAppend)

If lAppend
   TRB_ZLJ->(DBAPPEND())
   TRB_ZLJ->WK_DATA   := CTOD(_cDataLendo)
   TRB_ZLJ->ZLJ_FILIAL:= _cFilial
   TRB_ZLJ->ZLJ_VIAGEM:= _cVIAGEM
   TRB_ZLJ->WK_HORA   := _cHoraLeu
EndIf

If _lPodeMarcar
	TRB_ZLJ->WK_MARCA  := cMarca
	TRB_ZLJ->ZLJ_STATUS:= "P"
    _nConta++
Else
	TRB_ZLJ->WK_MARCA  := ""
	TRB_ZLJ->ZLJ_STATUS:= "R"
    _nRecusado++
EndIf

TRB_ZLJ->ZLJ_MOTIVO := _cMotivo

aAdd( _aLog , {_cDataLendo+" "+_cHoraLeu,TRB_ZLJ->ZLJ_FILIAL,TRB_ZLJ->ZLJ_VIAGEM+" "+ALLTRIM(TRB_ZLJ->ZLJ_VFILHA),TRB_ZLJ->ZLJ_NUMERO,TRB_ZLJ->ZLJ_SETOR,TRB_ZLJ->ZLJ_LINROT+"/"+TRB_ZLJ->ZLJ_LINHSQ,ALLTRIM(TRANSF(TRB_ZLJ->ZLJ_KMDVIA,"@E 999,999,999")),TRB_ZLJ->ZLJ_MOTIVO,If(Empty(TRB_ZLJ->WK_MARCA),"X","OK"),DTOC(TRB_ZLJ->ZLJ_DTCRIA)} )

Return .T.

/*
===============================================================================================================================
Programa--------: MGLT002BuscaSQ()
Autor-----------: Alex Walaluer
Data da Criacao-: 11/07/2016
Descrição-------: Busca os dados do SQ por hora 
Parametros------: _dDtini    : Data inicial da busca
                  _dDtfim    : Data final da busca
                  _cHrInicial: hora inicial da busca
                  _cHrFinal  : hora final da busca
                  _lShedule  : se chamou do schedure
Retorno---------: .T.
===============================================================================================================================
*/
Static Function MGLT002BuscaSQ(_dDtini,_dDtfim,_cHrInicial,_cHrFinal,_lShedule)

Local _cXmlRet:= ''
Local _cErro  := ''
Local _cXml   := _cXmlAux1//AQUI ABRE AS TAGs DO XML
Local _lRet   := .T.
_cDtIni:= substr(dtos(_dDtini),1,4) + "-" + substr(dtos(_dDtini),5,2) + "-" + substr(dtos(_dDtini),7,2) + _cHrInicial//"T00:00:00"
_cDtFim:= substr(dtos(_dDtini),1,4) + "-" + substr(dtos(_dDtini),5,2) + "-" + substr(dtos(_dDtini),7,2) + _cHrFinal  //"T23:59:59"
_cXml  += '<dataInicio>'+_cDtIni +'</dataInicio>'+CRLF
_cXml  += '<dataFim>'   +_cDtFim +'</dataFim>'   +CRLF
_cXml  += _cXmlAux2
_cXml  += U_GLTSQXML( 2 , _cMetodo )//AQUI FECHA AS TAGs DO XML

If _lVersaoNew
   _cXml:= STRTRAN(_cXml,"v9","v14")//Usa versão nova
   _cXml:= STRTRAN(_cXml,"V9","V14")//Usa versão nova
EndIf

U_GLTSQENV( _cWS , _cXml , _aHdrOut , @_cErro , _cMetodo , @_cXmlRet )
   
If Empty(_cErro) .AND. !Empty(_cXmlRet)
   AADD(_aXmlDia,{_dDtini,_cXmlRet,_cDtIni,_cDtFim, SUBSTR(_cHrInicial,2,9) })
Else
   U_ITConOut( 'Erro ao ler o xml da data: '+_cdtini+" ate "+_cDtFim+" -> Erro: ["+_cErro+"]" )
   If !_lShedule
     If !Empty(_cXmlRet)
	    MGLT002EML( 'Erro ao ler o xml da data: '+_cDtIni+" ate "+_cDtFim+" -> Erro: ["+_cErro+"]" )
	    MsgStop("Erro ao ler o xml do dia: "+_cDtIni+" ate "+_cDtFim+" -> Erro: ["+_cErro+"]","MGL02012")
	 EndIf   
   Else
      If !Empty(_cXmlRet)
	     MGLT002EML( 'Erro ao ler o xml da data: '+_cdtini+" ate "+_cDtFim+" -> Erro: ["+_cErro+"]" )
	  EndIf
      _lRet :=.F.
   EndIf
EndIf

Return _lRet

/*
===============================================================================================================================
Programa----------: MGLT002EML
Autor-------------: Alex Wallauer
Data da Criacao---: 08/07/2016
Descrição---------: Rotina para enviar e-mail de notificação quando houver uma falha de integração
Parametros--------: _cObs: Observacoes
                    _aLog: Lista de logs
                    _lProcessa: .T. com Tela
Retorno-----------: .T.
===============================================================================================================================
*/
Static Function MGLT002EML( _cObs,_aLog,_lProcessa,_lFiltra , _cEmail , _lTela )

Local _aConfig	:= U_ITCFGEML('')
Local _cMsgEml	:= '',_nI , E
Local _cData	:= Dtoc(DATE())
Local _cHoraT   := _cTimeInicial
Local _cAssunto := 'Workflow - Integração com o SmartQuestion'
Local _aEmail := {}
Local _cAnexa := NIL 

DEFAULT _cEmail	:= SuperGetMV("LT_EML_SMQ",.F.,"sistema@italac.com.br")
DEFAULT _lFiltra:= .F.
DEFAULT _lProcessa:=.F.
DEFAULT _lTela:=.F.

If _lProcessa
   ProcRegua(0)
   IncProc("Gerando anexo...")
   PswOrder(1)
   PswSeek(__cUserID,.T.)
   aUsuario:=PswRet()	
   _cEmail :=Alltrim(aUsuario[1,14])+";sistema@italac.com.br"
   IF TYPE("_aCabXML") = "A" .AND. TYPE("_aColsXML") = "A" .AND. LEN(_aColsXML) > 0
      IncProc("Gerando anexo...")
      _cDiretorio:=_cNomeArq:=NIL
                 //_cNomeArq ,_cDiretorio ,_cTitulo ,_cNomePlan,_aCabecalho,_aDetalhe,_lLeTabTemp,_cAliasTab,_aCampos,_lScheduller,_lCriaPastas,_aPergunte,_lEnviaEmail
      U_ITGEREXCEL(@_cNomeArq,@_cDiretorio,_cAssunto,          ,_aCabXML   ,_aColsXML,           ,          ,        ,.T.)
      _cAnexa:=_cDiretorio+_cNomeArq
	   If FILE(_cAnexa)
	      _cDestino:=ALLTRIM(GETMV("MV_RELT",,"\SPOOL\"))
	      if CPYT2S(_cAnexa,_cDestino,.F.) // Terminal To Server
	         _cAnexa  :=_cDestino+_cNomeArq
         ENDIF
	   ENDIF

      IncProc("Gerado anexo: "+_cAnexa)
   ENDIF
Else
   If Empty(_cEmail)
	  U_ITConOut('Sem e-mail cadastrado, verifique o parametro "LT_EML_SMQ" com a area de TI')
      Return .F.
   EndIf
  _cAssunto += ' - Processamento agendado (Schedule)'
EndIf

_cMsgEml := '<html>'
_cMsgEml += '<head><title>Integração SmartQuestion</title></head>'
_cMsgEml += '<body>'
_cMsgEml += '<style type="text/css"><!--'
_cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
_cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
_cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
_cMsgEml += 'td.aceito	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #00CC00; }'
_cMsgEml += 'td.recusa  { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FF0000; }'
_cMsgEml += 'td.estoque { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #870000; }'
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
_cMsgEml += '      <td align="center" colspan="2" class="grupos">Integração SmartQuestion</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Data:</b></td>'
_cMsgEml += '      <td class="itens" align="left" >'+ _cData +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Hora:</b></td>'
_cMsgEml += '      <td class="itens" align="left" >'+ _cHoraT +'</td>'
_cMsgEml += '    </tr>'
If !Empty(_cObs)
   If _lFiltra
      _cObs+="#OBS#"
   EndIf
   _cMsgEml += '    <tr>'
   _cMsgEml += '      <td class="itens" align="center" width="20%"><b>Observação:</b></td>'
   _cMsgEml += '      <td class="itens" align="left" >'+ AllTrim( _cObs ) +'</td>'
   _cMsgEml += '    </tr>'
EndIf
_cMsgEml += '	<tr>'
_cMsgEml += '      <td class="titulos" align="center" colspan="2"><font color="red">Esta é uma mensagem automática. Por favor não responder!</font></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '</table>'

If _aLog # NIL .AND. !Empty(_aLog)  .AND. Len( _aLog ) > 0
	
	_aLog := aSort(_aLog,,,{|x,y| DTOS(CTOD(x[1]))+x[2]+x[3]+x[4]+x[5] < DTOS(CTOD(y[1]))+y[2]+y[3]+y[4]+y[5] })//Ordena por Data + Filial + Viagem + Atendimento + Setor
	
	_cMsgEml += '<br>'
	_cMsgEml += '<table class="bordasimples" width="1200">'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td align="center" colspan="'+ALLTRIM(STR(Len( _aLog[1])))+'" class="grupos">ATENDIMENTOS</b></td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '    <tr>'
	//" " 'Data Rec','Data Conf','Filial','Viagem','Atendimento','Setor','Linha',Km SQ,'Observação'
	_cMsgEml += '      <td class="itens" align="center" width="1%"><b>  </b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="7%"><b>Dt Lib</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="7%"><b>Dt Estoque</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="5%"><b>Filial</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="8%"><b>Viagem</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="10%"><b>Atendimento</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="8%"><b>Setor</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="8%"><b>Linha</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="8%"><b>Km SQ</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="45%"><b>Observação</b></td>'
	_cMsgEml += '    </tr>'
	
	If _lProcessa
		ProcRegua(Len( _aLog ))
	EndIf

    If _lFiltra
       _nRecusado:=0
       _nConta   :=0
       _nEstoque :=0
    EndIf

	For _nI := 1 To Len( _aLog )
	    If _lProcessa
		   IncProc("Lendo dados...")
	    EndIf

	    If _lFiltra .AND. _aLog[_nI][02] # cFilAnt
		   LOOP
	    EndIf

		_cMsgEml += '    <tr>'
		If _aLog[_nI][09] = "X"
			_cMsgEml += '      <td class="recusa" align="center" width="1%"><b>X</b></td>'
		ELSEIf _aLog[_nI][09] = "EX"
			_cMsgEml += '      <td class="estoque" align="center" width="1%"><b>X</b></td>'
		Else
			_cMsgEml += '      <td class="aceito" align="center" width="1%"><b>OK</b></td>'
		EndIf
		_cMsgEml += '      <td class="itens" align="center" width="7%">' + _aLog[_nI][01]+'</td>'
		If LEN(_aLog[_nI]) > 9
		   _cMsgEml += '      <td class="itens" align="center" width="7%">'+_aLog[_nI][10]+'</td>'
        Else
		   _cMsgEml += '      <td class="itens" align="center" width="7%"> </td>'
		EndIf
		_cMsgEml += '      <td class="itens" align="center" width="5%">' + _aLog[_nI][02]+'</td>'
		_cMsgEml += '      <td class="itens" align="center" width="8%">' + _aLog[_nI][03]+'</td>'
		_cMsgEml += '      <td class="itens" align="center" width="10%">'+ _aLog[_nI][04]+'</td>'
		_cMsgEml += '      <td class="itens" align="center" width="8%">' + _aLog[_nI][05]+'</td>'
		_cMsgEml += '      <td class="itens" align="center" width="8%">' + _aLog[_nI][06]+'</td>'
		_cMsgEml += '      <td class="itens" align="center" width="8%">' + _aLog[_nI][07]+'</td>'
		_cMsgEml += '      <td class="itens" align="left"   width="45%">'+ ALLTRIM(_aLog[_nI][08])+'</td>'
		_cMsgEml += '    </tr>'
        
        If _lFiltra
		   If _aLog[_nI][09] == "X"
			  _nRecusado++
		   ElseIf _aLog[_nI][09] == "OK"
              _nConta++
		   ElseIf _aLog[_nI][09] == "EOK"
              _nEstoque++
           EndIf
        EndIf
		
	Next _nI
	
	_cMsgEml += '</table>'
	
EndIf

If _lFiltra .OR. _lTela
   _cObsT:=ALLTRIM(STR(_nRecusado,10))+' Atendimentos Recusados "X" (vermelho) '+CRLF
   _cObsT+=ALLTRIM(STR(_nConta   ,10))+' Atendimentos Gravados "OK" (verde) '   +CRLF
   _cObsT+=ALLTRIM(STR(_nEstoque ,10))+' Entradas em Estoque "OK" (verde)'      +CRLF
   _cMsgEml:=STRTRAN(_cMsgEml,"#OBS#",_cObsT)

   U_ITConOut("Log de Processamento - Integração SmartQuestion  - "+TIME()+" - [ Enviando E-mail para Filial: "+cFilAnt+", "+ALLTRIM(STR(_nConta,10))+" Atendimentos Gravados ]")

EndIf

_cMsgEml += '</center>'

   _cMsgEml += '    <tr>'
   _cMsgEml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
   _cMsgEml += '      <td class="itens" align="left" > ['+ GetEnvServer() +'] </td>'
   _cMsgEml += '    </tr>'

_cMsgEml += '</body>'
_cMsgEml += '</html>'
_cEmlLog := ''

_aEmail := STRTOKARR(_cEmail,",")// Lista de email

For E := 1 TO LEN(_aEmail)
    
    _cEmail:=_aEmail[E]
    U_ITConOut('Enviando E-mail(s) para: '+_cEmail)

    //    ITEnvMail(cFrom     ,cEmailTo ,cEmailCo,cEmailBcc,cAssunto ,cMensagem,cAttach,cAccount    ,cPassword   ,cServer      ,cPortCon    ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro)
    U_ITENVMAIL( _aConfig[01] , _cEmail ,        ,         ,_cAssunto, _cMsgEml,_cAnexa,_aConfig[01],_aConfig[02], _aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

    If !Empty( _cEmlLog )
       If _lProcessa
          MsgInfo( _cEmlLog+CRLF+" E-mails: "+_cEmail +CRLF+IF(_cAnexa<>NIL," Anexo: "+_cAnexa,""), "MGLT00213 - Envio do WF por e-mail")
       Else
          U_ITConOut(_cEmlLog+CRLF+" E-mails: "+_cEmail)
       EndIf
    EndIf

Next E

Return .T.

/*
===============================================================================================================================
Programa--------: MGLTTipoProd()
Autor-----------: Alex Walaluer
Data da Criacao-: 26/01/2017
Descrição-------: Devolve o tipo do produtor
Parametros------: cAlias: Tabela
Retorno---------: Descrição do TIPO DO PRODUTOR
===============================================================================================================================
*/
User Function MGLTTipoProd(cAlias)//Usado do rdmake AGLT021.PRW tb

Local cTipo:="               "

If (cAlias)->ZLJ_TIPPRO == 'C'
   cTipo:='Cooperativa'
ElseIf (cAlias)->ZLJ_TIPPRO == 'F'
   cTipo:='Reboque'
ElseIf (cAlias)->ZLJ_TIPPRO == 'R'
   cTipo:='Reboque (Filha)'
ElseIf (cAlias)->ZLJ_TIPPRO == 'A' .OR. POSICIONE("SA2",1,Xfilial("SA2")+(cAlias)->ZLJ_CODPAT+(cAlias)->ZLJ_LOJPAT,"A2_L_TIPPR") = "A" 
   cTipo:='Atravessador'
ElseIf (cAlias)->ZLJ_TIPPRO == 'P'
   cTipo:='Leite Proprio'
EndIf

Return cTipo

/*
===============================================================================================================================
Programa--------: MGLT2ListaResposta()
Autor-----------: Alex Walaluer
Data da Criacao-: 26/01/2017
Descrição-------: Analisa a TAG da lista de repostas
Parametros------: _lGrava: Gravar ,_aDadAtd: Array de dados , _nX: numerador
Retorno---------: Mensagem de erro
===============================================================================================================================
*/
Static Function MGLT2ListaResposta(_lGrava,_aDadAtd,_nX)

Local _cMemAux:="",_nZ

If ValType( XmlChildEx( _aDadAtd[_nX]:_LISTARESPOSTA,"_LISTACAMPORESPOSTA") ) = 'A'
	
	For _nZ := 1 To Len( _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA )
		
		Do Case

			Case Upper( AllTrim( _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_CAMPOFORMULARIO:_CODIGO:TEXT ) ) == 'VOLUME'
				If ValType( XmlChildEx(      _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ],"_VALORRESPOSTANUMERICO") ) <> 'U'
					
					If Val(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_VALORRESPOSTANUMERICO:TEXT ) > 100000
						
					   _cMemAux += " Valor volume invalido: " + alltrim(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_VALORRESPOSTANUMERICO:TEXT)
					   
					   If _lGrava
					      TRB_ZLJ->ZLJ_VOLUME:= 0
					   EndIf
						
					Else
						
					   If _lGrava
					      TRB_ZLJ->ZLJ_VOLUME:=Val(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_VALORRESPOSTANUMERICO:TEXT )
					   ElseIf !lVolumeZeroLOOP
						  _nTotLeite+=Val(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_VALORRESPOSTANUMERICO:TEXT )
					   EndIf

					   If Val(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_VALORRESPOSTANUMERICO:TEXT ) <> 0
  					      lVolumeZeroLOOP:=.F.
					   EndIf
						
					EndIf
					
				EndIf
				
			Case Upper( AllTrim( _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_CAMPOFORMULARIO:_CODIGO:TEXT ) ) == 'TEMPERATURA'
				
				If ValType( XmlChildEx(     _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ],"_VALORRESPOSTANUMERICO") ) <> 'U'
					
					If Val(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_VALORRESPOSTANUMERICO:TEXT ) > 1000
						
					    _cMemAux += " Valor temperatura invalido: " + alltrim(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_VALORRESPOSTANUMERICO:TEXT)
					    If _lGrava
						   TRB_ZLJ->ZLJ_TEMPER:= 0
						EndIf
												
					Else
						
					    If _lGrava
  						   TRB_ZLJ->ZLJ_TEMPER:=Val(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_VALORRESPOSTANUMERICO:TEXT )
						EndIf
						
					EndIf
					
				EndIf
				
			Case Upper( AllTrim( _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_CAMPOFORMULARIO:_CODIGO:TEXT ) ) == 'REGUA'

				If ValType( XmlChildEx(    _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ],"_VALORRESPOSTANUMERICO") ) <> 'U'
					
					If Val(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_VALORRESPOSTANUMERICO:TEXT ) < 0 .OR.;
						Val(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_VALORRESPOSTANUMERICO:TEXT ) > 10000
						
					    _cMemAux += " Valor Regua invalido: " + alltrim(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_VALORRESPOSTANUMERICO:TEXT)
					    If _lGrava
						   TRB_ZLJ->ZLJ_REGUA:= 0
						EndIf
					
					Else
						
					    If _lGrava
						   TRB_ZLJ->ZLJ_REGUA:=Val(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_VALORRESPOSTANUMERICO:TEXT )
						EndIf
						
					EndIf
					
				EndIf
				
			Case _lGrava .AND. Upper( AllTrim( _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_CAMPOFORMULARIO:_CODIGO:TEXT ) ) == 'ALIZAROL'

				If ValType( XmlChildEx(         _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ],"_VALORRESPOSTAENUMERACAO") ) <> 'U'
					TRB_ZLJ->ZLJ_ALIZAR:=AllTrim(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_VALORRESPOSTAENUMERACAO:_CODIGO:TEXT )
				EndIf
				
			Case _lGrava .AND. Upper( AllTrim( _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_CAMPOFORMULARIO:_CODIGO:TEXT ) ) == 'BOCA'

				If ValType( XmlChildEx(       _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ],"_VALORRESPOSTAENUMERACAO") ) <> 'U'
					TRB_ZLJ->ZLJ_BOCA:=AllTrim(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_VALORRESPOSTAENUMERACAO:TEXT )
				EndIf
				
			Case _lGrava .AND. Upper( AllTrim( _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_CAMPOFORMULARIO:_CODIGO:TEXT ) ) == 'AMOSTRA'

				If ValType( XmlChildEx(         _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ],"_VALORRESPOSTATEXTO") ) <> 'U'
					TRB_ZLJ->ZLJ_AMOSTR:=AllTrim(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA[_nZ]:_VALORRESPOSTATEXTO:TEXT )
				EndIf
				
		EndCase
		
	Next _nZ

ElseIf Upper( AllTrim( _aDadAtd[_nX]:_TIPOVISITA:_CODIGO:TEXT ) ) # "REC"

    _lTemLista:=.F.
	If ValType( XmlChildEx( _aDadAtd[_nX]:_LISTARESPOSTA , "_LISTACAMPORESPOSTA" ) ) == 'O'
	   If Upper( AllTrim( _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA:_CAMPOFORMULARIO:_CODIGO:TEXT ) ) == 'VOLUME'
		  If ValType( XmlChildEx(      _aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA,"_VALORRESPOSTANUMERICO") ) <> 'U'

			 _lTemLista:=.T.
			 
			 If Val(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA:_VALORRESPOSTANUMERICO:TEXT ) > 100000
						
			    _cMemAux += " Valor volume invalido: " + alltrim(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA:_VALORRESPOSTANUMERICO:TEXT)
					   
				If _lGrava
				   TRB_ZLJ->ZLJ_VOLUME:= 0
				EndIf
						
			 Else
						
				If _lGrava
				   TRB_ZLJ->ZLJ_VOLUME:=Val(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA:_VALORRESPOSTANUMERICO:TEXT )
				ElseIf !lVolumeZeroLOOP
				   _nTotLeite+=Val(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA:_VALORRESPOSTANUMERICO:TEXT )
				EndIf						
			    
			    If Val(_aDadAtd[_nX]:_LISTARESPOSTA:_LISTACAMPORESPOSTA:_VALORRESPOSTANUMERICO:TEXT ) <> 0
		           lVolumeZeroLOOP:=.F.
				EndIf
			 
			 EndIf					
			 
		  EndIf
       EndIf
   EndIf

   If !_lTemLista
      _cMemAux+=" [Atendimento sem lista de resposta] "
   EndIf

EndIf

Return _cMemAux

/*
===============================================================================================================================
Programa--------: MGLT2AcumulaEstoque()
Autor-----------: Alex Walaluer
Data da Criacao-: 26/01/2017
Descrição-------: Atualiza array com volumes por viagem e por setor para estoque
Parametros------: cAlias : Alias usado na função U_AGLT021V(); Iniciar Array _aViagens:={}
Retorno---------: .T.
===============================================================================================================================
*/
Static Function MGLT2AcumulaEstoque(cAlias)//"TRB_ZLJ"

Local _nPos:=0

If cAlias # NIL
   If (_nPos:=Ascan(_aRecViagens,{|aVal| aVal[1] == TRB_ZLJ->ZLJ_VIAGEM .AND. aVal[2] == TRB_ZLJ->ZLJ_FILIAL})) == 0
      AADD(_aRecViagens,{TRB_ZLJ->ZLJ_VIAGEM,;//01
	                     TRB_ZLJ->ZLJ_FILIAL,;//02
	                    {TRB_ZLJ->(Recno())}})//03 Recnos
                       
   Else
      AADD( _aRecViagens[_nPos,3] , TRB_ZLJ->(Recno()) )
   EndIf
EndIf

If (_nPos:=Ascan(_aViagens,{|aVal| aVal[1] == TRB_ZLJ->ZLJ_VIAGEM .AND. aVal[7] == TRB_ZLJ->ZLJ_FILIAL})) == 0
	aadd(_aViagens,{TRB_ZLJ->ZLJ_VIAGEM,;//01 //VIAGEM **
	                TRB_ZLJ->ZLJ_SETOR ,;//02
	                0                  ,;//03 //Total Cooperativa *
	                TRB_ZLJ->ZLJ_DTCRIA,;//04 //onde grava a data entrada no estoque: ZLJ_DTCRIA --> D3_EMISSAO / ZLW_DTLANC
	                TRB_ZLJ->ZLJ_NUMERO,;//05
	                TRB_ZLJ->WK_DATA   ,;//06
	                TRB_ZLJ->ZLJ_FILIAL,;//07 //FILIAL **
	                TRB_ZLJ->ZLJ_DESCAR,;//08 //Descarte
                   U_AGLT021V(1,cAlias),;//09 //Volume do Veiculo * -->  If (_cAlias)->ZLJ_LITRAG > 0  , (_cAlias)->ZLJ_LITRAG , ((_cAlias)->ZLJ_PSIVIA - (_cAlias)->ZLJ_PSFVIA) / POSICIONE("ZA7",1,(_cAlias)->ZLJ_FILIAL+"001","ZA7_DENPAD") )
	                .F.                ,;//10 //Nao Tem Leite Proprio
	                {}                 ,;//11 //Lista de Setores
	                0                  ,;//12 //Total Leite Proprio
	                TRB_ZLJ->ZLJ_DTCRIA,;//13 //Data criação da viagem no smartquestion //onde grava a data entrada no estoque: ZLJ_DTCRIA --> D3_EMISSAO / ZLW_DTLANC
	                TRB_ZLJ->(Recno()) })//14 //Recno do TRB_ZLJ
	_nPos:=LEN(_aViagens)
EndIf

If TRB_ZLJ->ZLJ_TIPPRO = 'F'//Recebimento: quando é julieta vale os totais desse atendimento de Recebimento
	
	_aViagens[_nPos][09]:=U_AGLT021V(1,cAlias)//Atualiza o total do veiculo com a linha de atendimento do recebimento  -->  If (_cAlias)->ZLJ_LITRAG > 0  , (_cAlias)->ZLJ_LITRAG , ((_cAlias)->ZLJ_PSIVIA - (_cAlias)->ZLJ_PSFVIA) / POSICIONE("ZA7",1,(_cAlias)->ZLJ_FILIAL+"001","ZA7_DENPAD") )
	_aViagens[_nPos][08]:=TRB_ZLJ->ZLJ_DESCAR //Atualiza com a linha de atendimento do recebimento
	
ElseIf TRB_ZLJ->ZLJ_TIPPRO = 'C'//Cooperativa
	
	_aViagens[_nPos][3] += TRB_ZLJ->ZLJ_VOLUME//Total Cooperativa
	
ElseIf TRB_ZLJ->ZLJ_TIPPRO = 'P'//Leite Proprio
	
	_aViagens[_nPos][10]:=.T.//Tem Leite Proprio
	_aViagens[_nPos][12]+= TRB_ZLJ->ZLJ_VOLUME//Total Leite Proprio
	
	If (_nPoSet:=Ascan(_aViagens[_nPos][11],{|aVal| aVal[1] == TRB_ZLJ->ZLJ_SETOR})) == 0
		AADD(_aViagens[_nPos][11], {TRB_ZLJ->ZLJ_SETOR,0,TRB_ZLJ->ZLJ_VOLUME})
	Else
		_aViagens[_nPos][11][_nPoSet][3] += TRB_ZLJ->ZLJ_VOLUME//Total do leite proprio por setor
	EndIf
	
EndIf
		     
Return 

/*
===============================================================================================================================
Programa--------: MGLT002C()
Autor-----------: Alex Walaluer
Data da Criacao-: 13/04/2017
Descrição-------: Tira os caracteres "estranos"
Parametros------: cRetornoXML: String
Retorno---------: cRetornoXML: String
===============================================================================================================================
*/
Static Function MGLT002C(cRetornoXML)//AWF - 13/04/2017 - Tira os caracteres "estranos"

cRetornoXML:=StrTran(cRetornoXML,"Ã?","E")
cRetornoXML:=StrTran(cRetornoXML,"Ã^","E")
cRetornoXML:=StrTran(cRetornoXML,"^","")
cRetornoXML:=StrTran(cRetornoXML,"á","a")
cRetornoXML:=StrTran(cRetornoXML,"Á","A")
cRetornoXML:=StrTran(cRetornoXML,"à","a")
cRetornoXML:=StrTran(cRetornoXML,"À","A")
cRetornoXML:=StrTran(cRetornoXML,"ã","a")
cRetornoXML:=StrTran(cRetornoXML,"Ã","A")
cRetornoXML:=StrTran(cRetornoXML,"â","a")
cRetornoXML:=StrTran(cRetornoXML,"Â","A")
cRetornoXML:=StrTran(cRetornoXML,"ä","a")
cRetornoXML:=StrTran(cRetornoXML,"Ä","A")
cRetornoXML:=StrTran(cRetornoXML,"é","e")
cRetornoXML:=StrTran(cRetornoXML,"É","E")
cRetornoXML:=StrTran(cRetornoXML,"ë","e")
cRetornoXML:=StrTran(cRetornoXML,"Ë","E")
cRetornoXML:=StrTran(cRetornoXML,"ê","e")
cRetornoXML:=StrTran(cRetornoXML,"Ê","E")
cRetornoXML:=StrTran(cRetornoXML,"í","i")
cRetornoXML:=StrTran(cRetornoXML,"Í","I")
cRetornoXML:=StrTran(cRetornoXML,"ï","i")
cRetornoXML:=StrTran(cRetornoXML,"Ï","I")
cRetornoXML:=StrTran(cRetornoXML,"î","i")
cRetornoXML:=StrTran(cRetornoXML,"Î","I")
cRetornoXML:=StrTran(cRetornoXML,"ý","y")
cRetornoXML:=StrTran(cRetornoXML,"Ý","y")
cRetornoXML:=StrTran(cRetornoXML,"ÿ","y")
cRetornoXML:=StrTran(cRetornoXML,"ó","o")
cRetornoXML:=StrTran(cRetornoXML,"Ó","O")
cRetornoXML:=StrTran(cRetornoXML,"õ","o")
cRetornoXML:=StrTran(cRetornoXML,"Õ","O")
cRetornoXML:=StrTran(cRetornoXML,"ö","o")
cRetornoXML:=StrTran(cRetornoXML,"Ö","O")
cRetornoXML:=StrTran(cRetornoXML,"ô","o")
cRetornoXML:=StrTran(cRetornoXML,"Ô","O")
cRetornoXML:=StrTran(cRetornoXML,"ò","o")
cRetornoXML:=StrTran(cRetornoXML,"Ò","O")
cRetornoXML:=StrTran(cRetornoXML,"ú","u")
cRetornoXML:=StrTran(cRetornoXML,"Ú","U")
cRetornoXML:=StrTran(cRetornoXML,"ù","u")
cRetornoXML:=StrTran(cRetornoXML,"Ù","U")
cRetornoXML:=StrTran(cRetornoXML,"ü","u")
cRetornoXML:=StrTran(cRetornoXML,"Ü","U")
cRetornoXML:=StrTran(cRetornoXML,"ç","c")
cRetornoXML:=StrTran(cRetornoXML,"Ç","C")
cRetornoXML:=StrTran(cRetornoXML,"º","o")
cRetornoXML:=StrTran(cRetornoXML,"°","o")
cRetornoXML:=StrTran(cRetornoXML,"ª","a")
cRetornoXML:=StrTran(cRetornoXML,"ñ","n")
cRetornoXML:=StrTran(cRetornoXML,"Ñ","N")
cRetornoXML:=StrTran(cRetornoXML,"²","2")
cRetornoXML:=StrTran(cRetornoXML,"³","3")
cRetornoXML:=StrTran(cRetornoXML,"’","'")
cRetornoXML:=StrTran(cRetornoXML,"§","S")
cRetornoXML:=StrTran(cRetornoXML,"±","+")
cRetornoXML:=StrTran(cRetornoXML,"­","-")
cRetornoXML:=StrTran(cRetornoXML,"´","'")
cRetornoXML:=StrTran(cRetornoXML,"o","o")
cRetornoXML:=StrTran(cRetornoXML,"µ","u")
cRetornoXML:=StrTran(cRetornoXML,"¼","1/4")
cRetornoXML:=StrTran(cRetornoXML,"½","1/2")
cRetornoXML:=StrTran(cRetornoXML,"¾","3/4")
cRetornoXML:=StrTran(cRetornoXML,"&","e") 
cRetornoXML:=StrTran(cRetornoXML,";",",")
cRetornoXML:=StrTran(cRetornoXML,"¡","i")
cRetornoXML:=StrTran(cRetornoXML,"©","c.")
cRetornoXML:=StrTran(cRetornoXML,"®","r.")
cRetornoXML:=StrTran(cRetornoXML,"£","L")
cRetornoXML:=StrTran(cRetornoXML,"‡","t")
cRetornoXML:=StrTran(cRetornoXML,"ƒ","f")
cRetornoXML:=StrTran(cRetornoXML,"–","-")
cRetornoXML:=StrTran(cRetornoXML,"!","")
cRetornoXML:=StrTran(cRetornoXML,"×","x")
cRetornoXML:=StrTran(cRetornoXML,"¥","")
cRetornoXML:=StrTran(cRetornoXML,"¤","")

Return cRetornoXML

/*
===============================================================================================================================
Programa----------: MGLT002R
Autor-------------: Alex Wallauer
Data da Criacao---: 26/06/2017
Descrição---------: Verifica se Ticket nao pode ser modificado por ja possuir lançamento de algum evento.
Parametros--------: dData: Data da Coleta , cSetor: Setor , cCodProd: Codigo do Produtor , cLjProd: Loja do Produtor
Retorno-----------: .T. : Se tem eventos , .F. : Se não tem eventos
===============================================================================================================================
*/
Static Function MGLT002R( dData , cSetor) //cCodProd , cLjProd )

Local cAliasZLF	:= ''
Local lRet		:= .F.
Local _cFiltro	:= ''
Local aArea	    := ''

If Empty(dData) .OR. Empty(cSetor)//Empty(cCodProd) .OR. Empty(cLjProd) 
   Return .T.//Devolvo como se tivesse recepcao para barrar na integração
EndIf

If (nPos:=ASCAN(_aTemRecepcao,{ |X| X[1] == DTOC(dData)+cSetor })) # 0//cCodProd+cLjProd
   Return (_aTemRecepcao[nPos,2])//Controle para NÃO executar mais de uma vez o SELECT no ZL8 para a mesma chave
EndIf

aArea	 := GetArea() 
cAliasZLF:= GetNextAlias()

_cFiltro += "% "
_cFiltro += "     ZLF.D_E_L_E_T_ = ' ' "
_cFiltro += " AND ZL8.D_E_L_E_T_ = ' ' "
_cFiltro += " AND ZL8.ZL8_COMPGT <> 'S' "
_cFiltro += " AND ZL8.ZL8_ADICOM <> 'S' "
_cFiltro += " AND '"+ dToS(dData) +"' >= ZLF_DTINI "
_cFiltro += " AND '"+ dToS(dData) +"' <= ZLF_DTFIM "
_cFiltro += " AND ZLF_SETOR  = '"+ cSetor	+"' "
_cFiltro += " AND ZLF_DTCALC >= ZLF_DTFIM "
_cFiltro += " %"
		
BeginSql alias cAliasZLF
	SELECT	COUNT(ZLF_CODZLE) TOT_EVE
			FROM	%Table:ZLF% ZLF
			JOIN	%Table:ZL8% ZL8 ON ZLF.ZLF_FILIAL = ZL8.ZL8_FILIAL AND ZLF.ZLF_EVENTO = ZL8.ZL8_COD
			WHERE	%Exp:_cFiltro%
EndSql
		
If (cAliasZLF)->TOT_EVE > 0
   lRet := .T.			
EndIf

AADD(_aTemRecepcao,{DTOC(dData)+cSetor,lRet})//cCodProd+cLjProd
		
(cAliasZLF)->( DBCloseArea() )
RestArea(aArea)

Return( lRet )

/*
===============================================================================================================================
Programa----------: MGLT002I
Autor-------------: Alex Wallauer
Data da Criacao---: 18/08/2017
Descrição---------: Verifica se a Data esta dentro periodo de um MIX aberto
Parametros--------: dData: Data da Coleta 
Retorno-----------: .T. : Se tá dentro ; .F. : Se tá fora
===============================================================================================================================
*/
Static Function MGLT002I( dData )

Local cAliasZLE	:= ''
Local lRet		:= .F.
Local _cFiltro	:= ''
Local aArea	    := ''

If Empty(dData) 
   Return .T.//Devolvo como se tivesse dentro  para barrar na integração
EndIf

If (nPos:=ASCAN(_aTaNoMixAtual,{ |X| X[1] == DTOC(dData) })) # 0
   Return (_aTaNoMixAtual[nPos,2])//Controle para NÃO executar mais de uma vez o SELECT 
EndIf

aArea	 := GetArea() 
cAliasZLE:= GetNextAlias()

_cFiltro += "% "
_cFiltro += " ZLE.D_E_L_E_T_ = ' ' AND ZLE_STATUS = 'A' "
_cFiltro += " AND '"+ dToS(dData) +"' >= ZLE_DTINI "
_cFiltro += " AND '"+ dToS(dData) +"' <= ZLE_DTFIM "
_cFiltro += " %"
		
BeginSql alias cAliasZLE
	SELECT	COUNT(*) MIX_ATUAL
			FROM	%Table:ZLE% ZLE
			WHERE	%Exp:_cFiltro%
EndSql
		
If (cAliasZLE)->MIX_ATUAL > 0
   lRet := .T.			
EndIf

AADD(_aTaNoMixAtual,{DTOC(dData),lRet})
		
(cAliasZLE)->( DBCloseArea() )
RestArea(aArea)

Return( lRet )

/*
===============================================================================================================================
Programa----------: MGLT002W
Autor-------------: Josué Danich Prestes
Data da Criacao---: 05/07/2018
Descrição---------: Chamada da execução via webservice
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
WSSTRUCT U_MGLT002G //Solicitação de execução do workflow
 
 WSDATA EXECUTA as STRING 
 
ENDWSSTRUCT


WSSERVICE U_MGLT002 DESCRIPTION "Schedule Smartquestion" NAMESPACE "http://10.7.0.57:4043/ws/U_MGLT002.apw"

	WSDATA U_EXECUTA AS U_MGLT002G
	WSDATA U_STATUS AS STRING
	
	WSMETHOD U_EXECWF DESCRIPTION "Schedule Smartquestion"
 
ENDWSSERVICE 

WSMETHOD U_EXECWF WSRECEIVE U_EXECUTA WSSEND U_STATUS WSSERVICE U_MGLT002  

	startjob("U_MGLT002",getenvserver(),.F.)
	U_ITConOut("Iniciado Schedule Smartquestion")
	::U_STATUS := "Iniciado Schedule Smartquestion"

Return .T.

/*
===============================================================================================================================
Programa----------: MGLT002Y
Autor-------------: Josué Danich Prestes
Data da Criacao---: 12/09/2016
Descrição---------: Chamada de workflow via webservice 
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGLT002Y()

Local _cURL := SuperGetMV("IT_WSURL",.F.,"http://localhost:1026")

  U_ITConOut("Solicitando Webservice de leitura Smartquestion")

   oWsdl := tWSDLManager():New() // Cria o objeto da WSDL.
   oWsdl:nTimeout := 60          // Timeout de 10 segundos                                                               
   
   oWsdl:ParseURL(_cURL+"/ws/U_MGLT002.apw?WSDL") // Manda para dentro do Objeto qual é o link do WSDL de integração Webservice. 
   oWsdl:SetOperation("U_EXECWF") // Define qual operação será realizada.
                       
      //Monta XML
      _cXML := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="'+Substr(_cURL,1,At(':',_cURL,At(':',_cURL,1)+1)-1)+':4043/ws/U_MGLT002.apw">'
      _cXML += '<soapenv:Header/><soapenv:Body><u:U_EXECWF><u:U_EXECUTA><u:EXECUTA>teste</u:EXECUTA></u:U_EXECUTA></u:U_EXECWF></soapenv:Body></soapenv:Envelope>'
  		    
      // Envia para o servidor
      _cOk := oWsdl:SendSoapMsg(_cXML) // Este comando pega o XML e envia para o servidor da RDC.  
            
Return _cOk

/*
===============================================================================================================================
Programa--------: MGLT2GrvZLJ()
Autor-----------: Alex Walaluer
Data da Criacao-: 10/09/2018
Descrição-------: Grava viagem no ZLJ
Parametros------: _oProcess,cChave,_lShedule
Retorno---------: .T.
===============================================================================================================================
*/
Static Function MGLT2GrvZLJ(_oProcess,cChave,_lShedule)

Local _lGravouNew := .F.

If TRB_ZLJ->(DBSEEK(cChave))

    Do While TRB_ZLJ->(!EOF()) .AND. cChave == TRB_ZLJ->ZLJ_FILIAL+TRB_ZLJ->ZLJ_VIAGEM
       
       If !_lShedule
          _oProcess:IncRegua1("6-Gravando Viagem: "+TRB_ZLJ->ZLJ_VIAGEM)
          _oProcess:IncRegua2(STR(_nConta,6)+" Atendimentos Gravados...")
       ElseIf _lIDESENV
           U_ITConOut("6-Gravando Viagem: "+TRB_ZLJ->ZLJ_VIAGEM)
       EndIf
       
       If !Empty(TRB_ZLJ->WK_MARCA) .AND. TRB_ZLJ->ZLJ_STATUS = 'P' 
          
          //Codigo de segurança para não integrar nada das reusadas e Efetivadas
          ZLJ->( DBSetOrder(5))//ZLJ_FILIAL+ZLJ_VIAGEM+ZLJ_TIPPRO+ZLJ_VFILHA+ZLJ_SETOR+ZLJ_LINROT
          If ZLJ->( DBSeek( TRB_ZLJ->ZLJ_FILIAL + TRB_ZLJ->ZLJ_VIAGEM )) .AND. ZLJ->ZLJ_STATUS $ "R,E"
             TRB_ZLJ->(DBSKIP())
             LOOP
          EndIf
          //Codigo de segurança para não integrar nada das reusadas

          If !Empty(TRB_ZLJ->ZLJ_NUMERO)//Atendimento
             ZLJ->( DBSetOrder(1))//ZLJ_FILIAL+ZLJ_NUMERO
             _lAchouZLJ:=ZLJ->( DBSeek( TRB_ZLJ->ZLJ_FILIAL + TRB_ZLJ->ZLJ_NUMERO ) )//Se acha o atendimento atualiza o KM
          Else//Reboque nao tem atendimento
             //ZLJ->( DBSetOrder(5))//ZLJ_FILIAL+ZLJ_VIAGEM+ZLJ_TIPPRO+ZLJ_VFILHA+ZLJ_SETOR+ZLJ_LINROT
             _lAchouZLJ:=ZLJ->( DBSeek( TRB_ZLJ->ZLJ_FILIAL + TRB_ZLJ->ZLJ_VIAGEM + TRB_ZLJ->ZLJ_TIPPRO + TRB_ZLJ->ZLJ_VFILHA ) )
          EndIf   

		  If _lAchouZLJ

             If ZLJ->(RecLock( 'ZLJ' , .F.,.F.,.T.))
                ZLJ->ZLJ_KMDVIA := TRB_ZLJ->ZLJ_KMDVIA
		          ZLJ->( MsUnlock() )
                cMOTIVO := 'KM atualizada com sucesso por '+_cZLJ_UINTSQ+" /Incluido primeiro por "+ALLTRIM(ZLJ->ZLJ_UINTSQ)
             EndIf

		  Else

             ZLJ->(RecLock( 'ZLJ' , .T. ))
             AVREPLACE("TRB_ZLJ","ZLJ")
             ZLJ->ZLJ_FILIAL := TRB_ZLJ->ZLJ_FILIAL
       	    ZLJ->ZLJ_UINTSQ := _cZLJ_UINTSQ
             ZLJ->ZLJ_HINTSQ := TIME()
             ZLJ->ZLJ_DINTSQ := DATE()
		       ZLJ->( MsUnlock() )
             cMOTIVO := 'Atendimento incluido com sucesso por '+_cZLJ_UINTSQ
             _lGravouNew := .T.
             
		  EndIf
        IF !EMPTY(TRB_ZLJ->ZLJ_CODPAT)
           cMOTIVO := cMOTIVO + " /Produtor: "+TRB_ZLJ->ZLJ_CODPAT+"-"+TRB_ZLJ->ZLJ_LOJPAT
           TRB_ZLJ->WKREC_ZLJ:=ZLJ->(RECNO())
        EndIF
		  
          _nConta++
		  aAdd( _aLog , {DTOC(TRB_ZLJ->WK_DATA)+" "+ALLTRIM(TRB_ZLJ->WK_HORA),TRB_ZLJ->ZLJ_FILIAL,TRB_ZLJ->ZLJ_VIAGEM+" "+ALLTRIM(TRB_ZLJ->ZLJ_VFILHA),TRB_ZLJ->ZLJ_NUMERO,TRB_ZLJ->ZLJ_SETOR,TRB_ZLJ->ZLJ_LINROT+"/"+TRB_ZLJ->ZLJ_LINHSQ,ALLTRIM(TRANSF(TRB_ZLJ->ZLJ_KMDVIA,"@E 999,999,999")), cMOTIVO,"OK",DTOC(TRB_ZLJ->ZLJ_DTCRIA)} )
		    
       EndIf
       
       TRB_ZLJ->(DBSKIP())
    
    EndDo

EndIf

Return _lGravouNew

/*
===============================================================================================================================
Programa--------: MGLT2XmlParser
Autor-----------: ALEX WALLAUER
Data da Criacao-: 11/09/2018
Descrição-------: Trata error.log no XML
Parametros------: _cXML, _cCarac ,_cErro,_cWarning
Retorno---------: Objeto
===============================================================================================================================
*/
Static Function MGLT2XmlParser(_cXML, _cCarac ,_cErro,_cWarning, _cMen)

Local bError := ErrorBlock({|oError|  U_MGLT2Erro(oError:ErrorStack, _cMen,_cXML,@_cErro) })
Local _oXml:=NIL

BEGIN SEQUENCE
   If _lIDESENV
      MemoWrite(_cNomeLog,_cXML)
   EndIf   

   _oXml := XmlParser(_cXML , _cCarac , @_cErro , @_cWarning )
RECOVER
END SEQUENCE
ErrorBlock(bError)

If _lErroXmlParser
   _cXML:=StrTran(_cXML,">","&gt;")
   _cXML:=StrTran(_cXML,"<","&lt;")
   MGLT002EML(_cMen+" - Erro no tratamento dos dados do SQ [XmlParser] -  ERRO: [ "+_cErro+" ] - XML: [ "+_cXML+" ]" , ,,, "sistema@italac.com.br")
   _oXml:=NIL 
   DelClassIntf()
EndIf

Return  _oXml
/*
===============================================================================================================================
Programa--------: MGLT2Erro
Autor-----------: ALEX WALLAUER
Data da Criacao-: 11/09/2018
Descrição-------: Trata error.log no XML
Parametros------: cErro, _cMen,_cXML,_cErro
Retorno---------: .T.
===============================================================================================================================
*/
User Function MGLT2Erro(cErro, _cMen,_cXML,_cErro)

If _lShedule
   U_ITConOut( _cMen+" [XmlParser], Erro: [ "+cErro+" ]")
Else
  _bMaisDetalhes:={||  AVISO("Erro e Pilha de chamadas","ERRO: "+cErro,{"Fechar"},3) }
   U_ITMSG(UPPER(_cMen)+" [XmlParser]","MGLT00214",;
           "POR FAVOR ENTRE EM CONTATO COM A  AREA DE TI COM O PRINT DESSA MESAGEM CLICANCO EM MAIS DETALHES",3,,,,,,_bMaisDetalhes)
EndIf  

_lErroXmlParser:=.T.
_cErro:=cErro

Return .T.
/*
===============================================================================================================================
Programa--------: MGLT2GerEstoque
Autor-----------: ALEX WALLAUER
Data da Criacao-: 11/09/2018
Descrição-------: Tratamento de JOB
Parametros------: _nTime,_cChave,_cViagem,_nCustoEst,_oProcess,_aViagens
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function MGLT2GerEstoque(_nTime,_cChave,_cViagem,_nCustoEst,_oProcess,_aViagens)

Local _PubVar:= "GERA_ESTOQUE"+ALLTRIM(_cChave)
Local _PubTID:= "THREAD_ESTOQUE"+ALLTRIM(_cChave)
Local _tini,_dini,I

If !_lShedule
   _oProcess:SetRegua2( _nTime )
EndIf   

U_ITConOut(" _PubVar "+_PubVar+" _PubTID "+_PubTID+ " TIME: "+ STRZERO(_nTime,3))		

PutGlbValue(_PubVar,"Alterando")
PutGlbValue(_PubTID,"0")
_lRet := .T.
StartJob("U_MGLT2JOB",GETENVSERVER(),.F.,_PubVar,_cViagem,_nCustoEst,_PubTID,_aViagens,_cChave,cUsername)

_tini   := SECONDS()
_dini   := DATE()
_nThread:= VAL(GetGlbValue(_PubTID))

U_ITConOut(" _PubVar "+GetGlbValue(_PubVar)+" _nThread: "+ STRZERO(_nThread,6))		

For I := 1 TO 150
    If _nThread = 0
       _nThread:= VAL(GetGlbValue(_PubTID))
       U_ITConOut("Tentativa:"+ALLTRIM(STR(I))+" _PubVar "+GetGlbValue(_PubVar)+" _nThread: "+STRZERO(_nThread,6))		
    Else
       Exit
    EndIf
    SLEEP(10)
Next

Do  While  DATE() == _dini

     U_ITConOut("Acompanhando execauto do Estoque da Viagem " + _cChave + " na Thread " + STRZERO(_nThread,6)  + " por " + STRZERO((SECONDS() - _tini),3) + " segundos...")

    If !_lShedule
       _oProcess:IncRegua2("Viagem " + _cChave + " Aguarde: " + ALLTRIM(STR((SECONDS() - _tini),3)) + " segundos")
  	EndIf   

	If GetGlbValue(_PubVar) != "Alterando"
	   Exit	
	EndIf
	
	_aMonitor := GetUserInfoArray() 
	
	_Ni := Ascan(_aMonitor,{|aVal| aVal[3] = _nThread})
	
	If  _Ni > 0 .AND. _nThread <> 0
	
		If (SECONDS() - _tini) >= _nTime
		
		   U_ITConOut("Derrubando Estoque na Thread " +strzero(_amonitor[_ni][3],6) + " por timeout de "+STR(_nTime,3)+", Viagem " + _cChave + ", DERRUBANDO MGLT2JOB" )

         If !_lShedule
               _oProcess:IncRegua2("Derrubando Estoque na Thread " +strzero(_amonitor[_ni][3],6) + " por timeout de "+STR(_nTime,3)+", Viagem " + _cChave + ", DERRUBANDO MGLT2JOB" )
  			EndIf   
	
			KillUser( _amonitor[_ni][1], _amonitor[_ni][2], _amonitor[_ni][3], _amonitor[_ni][4] )		

         _cErroSche:= "1-A gravacaode estoque  dessa viagem foi cancelada por timeout, tente novamente"
            
         _lRet:=.F.
		   Exit
		    
		EndIf
		
	Else
	
	   U_ITConOut("Não achou Thread de origem para o Estoque da Viagem " + _cChave + ", DERRUBANDO MGLT2JOB")
       
       If !_lShedule
          _oProcess:IncRegua2("Não achou Thread de origem para o Estoque da Viagem " + _cChave + ", DERRUBANDO MGLT2JOB")
  	   EndIf   

       _cErroSche:= "2-A gravacao de estoque dessa viagem foi cancelada por nao achar a Thread " + CValToChar(_nThread) +", tente novamente"
       _lRet:=.F.
	   Exit
		
	EndIf	

   SLEEP(1000)
	
EndDo

IF !_lRet
   SLEEP(10000)
ENDIF

If GetGlbValue(_PubVar) != "Alterando"
	
   If GetGlbValue(_PubVar) == "Completado"
      _cErroSche:= "COMPLETADO"
      _lRet:=.T.
   Else
      _cErroSche:= GetGlbValue(_PubVar)
      _lRet:=.F.
   EndIf

   U_ITConOut("1-Execauto do Estoque ["+_cErroSche+"] na Viagem " + _cChave + " pela thread " + STRZERO(_nThread,6) +  " - Encerrando monitor normalmente")
		
EndIf

IF !_lRet
   _cFilial := _aViagens[7]//Filial da Viagem para dar entrada de estoque na filial certa
   _lVerificado:=.T.
   SLEEP(10000)
   IF MGLT2ValEst( _cViagem , _cFilial  )
      _lRet:=.T.
   ENDIF
ENDIF

Return _lRet

/*
===============================================================================================================================
Programa--------: MGLT2JOB
Autor-----------: ALEX WALLAUER
Data da Criacao-: 14/09/2018
Descrição-------: Tratamento de JOB
Parametros------: _PubVar,_cViagem,_nCustoEst,_PubTID,_aViagens,_cUsername
Retorno---------: .T. ou .F.
===============================================================================================================================
*/
User Function MGLT2JOB(_PubVar,_cViagem,_nCustoEst,_PubTID,_aViagens,_cChave,_cUsername)

Local _lRet := .T.
Local bError := ErrorBlock({|oError|  _cErroSche:=ALLTRIM(oError:ErrorStack) })
DEFAULT _cUsername:= "Schedule"

Private _cErroSche:= ""

BEGIN SEQUENCE

U_ITConOut("1-Iniciando ambiente no WATCHDOG, Viagem: "+_cChave+" - Usuario: "+_cUsername)

PutGlbValue(_PubTID,STRZERO(ThreadID(),6))//PRIMEIRO COMANDO

nTotBom   := _aViagens[9]-_aViagens[3] // Volume do veiculo - o total da cooperativa  = Volume do leite proprio com a diferença
cFilAnt   := _aViagens[7]//Filial da Viagem para dar entrada de estoque na filial certa
cSetor    := _aViagens[2]//Variavel usada dentro da funcao U_AGLT003G()  // ZLJ_SETOR onde grava D3_L_SETOR
dDtColeta := _aViagens[4]//Variavel usada dentro da funcao U_AGLT003G()  // onde grava a data entrada no estoque: ZLJ_DTCRIA --> D3_EMISSAO / ZLW_DTLANC

RPCSetType(2) // RPCSetType(3)
RpcSetEnv( "01" , cFilAnt ,,,"ESP2", "JOB_WF_ESTOQUE" , {'ZLJ','SA2','ZL2','ZLT','ZLS'} )

U_ITConOut("2-Iniciado ambiente no WATCHDOG, Viagem: "+_cChave)

cUsuario := SPACE(06)+"Administrador  "
cUsername:= _cUsername

_lRet:=U_AGLT003G(_cViagem , 3 , .T. , _nCustoEst ) //Grava movimento de estoque igual a rotina da recepção manual

RECOVER
_lRet	:= .F. 
END SEQUENCE 
ErrorBlock(bError)

If _lRet
   PutGlbValue(_PubVar,"Completado")
Else
   PutGlbValue(_PubVar,"ERRO: "+_cErroSche)
EndIf

U_ITConOut("3-Resultado da execução do WATCHDOG: Viagem: "+_cChave+", "+GetGlbValue(_PubVar))

Return _lRet

/*
===============================================================================================================================
Programa----------: MGLT2ValEst
Autor-------------: Alex Wallauer Ferreria
Data da Criacao---: 02/10/2020
Descrição---------: Funcao usada verificar se existe um movimento interno relativo a entrada
Parametros--------: ccod - ticket do movimento / _cFilial - Filial atual
Retorno-----------: _lret - se existe ou não o movimento
===============================================================================================================================
*/
Static Function MGLT2ValEst( cCod , _cFilial )

Local _lRet		:= .F.
Local _cAlias	:= GetNextAlias()

BeginSql alias _cAlias
	SELECT COUNT(1) QTD_D3
	FROM %Table:SD3%
	WHERE D_E_L_E_T_ = ' '
   AND D3_FILIAL  =  %exp:_cFilial% 
	AND D3_ESTORNO <> 'S'
	AND D3_L_ORIG  = %exp:cCod%
EndSql

_lRet := ( (_cAlias)->QTD_D3 > 0 )

(_cAlias)->( DBCloseArea() )
DBSELECTAREA("ZLJ")
Return(_lRet)
