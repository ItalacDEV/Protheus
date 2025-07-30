/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 08/08/2017 | Ajustes para versão 12 - Chamado 20782
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 03/09/2019 | Alterado ITGETMV por SuperGetMV. Help 28346
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 16/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#Include 'Protheus.ch'  
#INCLUDE "TopConn.ch"

/*
===============================================================================================================================
Programa----------: AOMS093
Autor-------------: Alex Wallauer
Data da Criacao---: 16/02/2017
=========================================================================================================================================================
Descrição---------: Rotina para Ler os dados das Viagens do SQ e dados da NF e gravar na tabela ZG4
=========================================================================================================================================================
Parametros--------: Nenhum
=========================================================================================================================================================
*/  
User Function AOMS093()
Local _aCores     := {}
Private aRotina   := {}
Private cCadastro := "Integração das informações de Descarregamento (SmartQuesion)"
Private cNomArq   := ""
Private _cMarca   := ""
Private _nRecusado:=0
Private _nConta   :=0
PRIVATE _cTimeInicial:=TIME()


_lScheduler := ( Select("SX3") <= 0 )

IF !_lScheduler

   //Grava Log de execução da rotina
   U_ITLOGACS()

   Aadd(aRotina,{"Pesquisar"            ,"AxPesqui"   ,0,1})
   Aadd(aRotina,{"Visualizar"           ,"AxVisual"   ,0,2})
   Aadd(aRotina,{"Ler Dados SQ/NF"      ,"U_AOMS093I" ,0,3})   
   Aadd(aRotina,{"Legenda"              ,"U_AOMS093L" ,0,6})
   
   Aadd(_aCores,{"ZG4_SITUAC == 'N'" ,"BR_VERDE" })
   Aadd(_aCores,{"ZG4_SITUAC == 'P'" ,"BR_VERMELHO" })
   Aadd(_aCores,{"ZG4_SITUAC == 'R'" ,"BR_AMARELO" })
   Aadd(_aCores,{"ZFQ_SITUAC == 'O'" ,"BR_CANCEL" })

   DbSelectArea("ZG4")
   ZG4->(DbSetOrder(1)) 
   ZG4->(DbGoTop())

//  mBrowse(,,,,cAli>,<aFixe, <cCpo>, <nPar>, <cCorFun>, <nClickDef>, <aColors>, <cTopFun>, <cBotFun>, <nPar14>, <bInitBloc>, <lNoMnuFilter>, <lSeeAll>, <lChgAll>, <cExprFilTop>, <nInterval>, <uPar22>, <uPar23> )
    MBrowse(,,,,"ZG4",      ,       ,       ,          ,            , _aCores  ,          ,          ,         ,            ,               ,    .T.    )

ELSE
  
   AOMS093A()
  
ENDIF   

Return Nil    

/*
===============================================================================================================================
Programa----------: AOMS093L
Autor-------------: Alex Wallauer
Data da Criacao---: 16/02/2017
===============================================================================================================================
Descrição---------: Rotina de Exibição da Legenda do MBrowse.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
*/  
User Function AOMS093L       
Local _aLegenda := {}

   Aadd(_aLegenda,{"BR_VERDE"    ,"Não Processado" })
   Aadd(_aLegenda,{"BR_AMARELO"  ,"Rejeitada" })
   Aadd(_aLegenda,{"BR_VERMELHO" ,"Processado" })
   Aadd(_aLegenda,{"BR_CANCEL"   ,"Obsoleto" })   

   BrwLegenda(cCadastro, "Legenda", _aLegenda)

Return Nil   

/*
===============================================================================================================================
Função------------: AOMS093I
Autor-------------: Alex Wallauer
Data da Criacao---: 16/02/2017
===============================================================================================================================
Descrição---------: Rotina para Ler os dados das Viagens do SQ e gravar na tabela ZG4
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
*/  
User Function AOMS093I()

Local _cPerg   :="AGLT021"
PRIVATE _lVersaoNew:=.T.

DO WHILE .T.

   If !Pergunte(_cPerg)
      EXIT
   ENDIF

   _cFiltroFilial:= MV_PAR01
   _dDtini  := MV_PAR02
   _dDtfim  := MV_PAR03
   _cHoraI  := MV_PAR12
   _cHoraF  := MV_PAR13

   U_AOMS093T()//Cria TRB
   
   _lOK:=.F.
   _cTimeInicial:=TIME()

   oProcess:=MsNewProcess():New({|lEnd| _lOK:=U_AOMS93SQ(@oProcess, @lEnd) },'Hora Inicial: '+_cTimeInicial,"Atualizando dados...",.T.) 
   oProcess:Activate()

   IF !_lOK 
      LOOP
   ENDIF

   IF AOMS93Tela()

      cObs:=""
      _cTimeInicial:=TIME()
      
      Processa( {|| cObs:=U_AOMS093G() } , 'Aguarde!' , 'Gravando Dados do SQ...' )

      AVISO( "Gravação concluida com Sucesso: " , cObs , {"OK"} ,2 ) 

   ELSE

      EXIT//LOOP

   ENDIF
		
   EXIT

ENDDO

IF(SELECT("TRB_ZG4") # 0,TRB_ZG4->(E_EraseArq(cNomArq)),)

RETURN .T.
/*
===============================================================================================================================
Função------------: AOMS093T
Autor-------------: Alex Wallauer
Data da Criacao---: 16/02/2017
===============================================================================================================================
Descrição-------: Cria tabela temporária.
===============================================================================================================================
Parametros------: Nenhum                                                                                                       
===============================================================================================================================
*/
User Function AOMS093T()
Local _aStrucZG4

_cMarca  := GetMark() 

   //================================================================================
   // Verifica se ja existe um arquivo com mesmo nome, se sim fecha.
   //================================================================================
   If Select("TRB_ZG4") > 0
      TRB_ZG4->( DBCloseArea() )
   EndIf
   DBSELECTAREA("ZG4")
   //================================================================================
   // Cria as estruturas das tabelas temporárias
   //================================================================================
   _aStrucZG4 := ZG4->(DbStruct())
   Aadd(_aStrucZG4,{"WK_STATUS", "C", 1 ,0})
   Aadd(_aStrucZG4,{"WK_MARCA" , "C", 2 ,0})
   Aadd(_aStrucZG4,{"WKRECNO"  , "N", 10,0})
   Aadd(_aStrucZG4,{"WK_MOTIVO", "C",200,0})
   Aadd(_aStrucZG4,{"WK_DTFINAL","D",  8,0})
   Aadd(_aStrucZG4,{"WK_HRFINAL","C", 10,0})
	
   cNomArq:=E_CriaTrab(,_aStrucZG4,"TRB_ZG4",,.F.)

   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   IndRegua( "TRB_ZG4" , cNomArq	, "Dtos(ZG4_DATA)+ZG4_HORA" ,,, 'Criando Indice'	) 
   
Return Nil


/*
===============================================================================================================================
Função------------: AOMS093A
Autor-------------: Alex Wallauer
Data da Criacao---: 16/02/2017
===============================================================================================================================
Descrição-------: Função para rodar a rotina de integração de forma agendada (Scheduller).
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum                  
===============================================================================================================================
*/
STATIC Function AOMS093A()

   //================================================================================
   // Abre ambiente
   //================================================================================
    u_itconout("AOMS093 - Log de Processamento - INICIO   - Integração SQ / NF -> RDC (ZG4) - "+DTOC(DATE())+" - "+TIME())
	RPCSetType(3)
	RpcSetEnv( "01" , "01" ,,,"ESP2", "SCHEDULE_WF_SOLICITACAO" , {'ZG4','SA2','DA3','DA4','ZLJ','ZL1'} )
	Sleep( 5000 ) //Aguarda 5 segundos para subam as configurações do ambiente.

   //================================================================================
   // Cria Tabela Temporaria
   //================================================================================
   U_AOMS093T()
   
   //================================================================================
   // Lê os dados do SQ e da NOTAS
   //================================================================================
   u_itconout("AOMS093 - Log de Processamento - LENDO    - Integração SQ / NF -> RDC (ZG4) - "+DTOC(DATE())+" - "+TIME())
   U_AOMS93SQ()

   //================================================================================
   // Grava os dados 
   //================================================================================
   u_itconout("AOMS093 - Log de Processamento - GRAVANDO  - Integração SQ / NF -> RDC (ZG4) - "+DTOC(DATE())+" - "+TIME())
   cObs:=U_AOMS093G()
   
   u_itconout(cObs)
   u_itconout("AOMS093 - Log de Processamento - CONCLUIDO - Integração SQ / NF -> RDC (ZG4) - "+DTOC(DATE())+" - "+TIME())

   IF(SELECT("TRB_ZG4") # 0,TRB_ZG4->(E_EraseArq(cNomArq)),)

   //Grava Log de execução da rotina
   U_ITLOGACS()

Return Nil
/*
===============================================================================================================================
Função------------: AOMS93SQ
Autor-------------: Alex Wallauer
Data da Criacao---: 16/02/2017
===============================================================================================================================
Descrição-------: Função para busca os dados do SQ
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum                  
=============================================================================================================================== 
*/
User Function AOMS93SQ( _oProcess, _lEnd )

Local _cWarning	 := '',_nMi,_nHr,nHr,_nI,_nXml,_nX
Local _cCodEmpWS := U_ITGETMV( 'IT_EMPWEBSE' , '000001' )  
Local _lRetorno  := .T.

PRIVATE _aHdrOut	:= {'POST https://italac.smartquestion.com.br/ws/WsSmartQuestionV9 HTTP/1.1'				,;//Ambiente de Produção
						'Accept-Encoding: gzip,deflate'																		,;
						'Content-Type: text/xml;charset=UTF-8'																,;
						'SOAPAction: ""'																					,;
						'Host: italac.smartquestion.com.br'																	,;
						'Connection: Keep-Alive'																			,;
						'User-Agent: Mozilla/4.0 (compatible; Protheus 7.00.111010P-20120120; ADVPL WSDL Client 1.111215)'	 }
If !_lScheduler

   _oProcess:SetRegua1(0)
   _oProcess:IncRegua1("Baixando dados do smartquestion...")

Else

    _cTimeInicial := TIME()
    _cFiltroFilial:= U_ITGETMV( 'IT_FILINTWS' , '01' )

    cUSUARIO := SPACE(06)+"Administrador  "
    cUsername:= "Schedure"
    _dDtini  := DATE()
    _dDtfim  := DATE()
    _lEnd    := .F.
    _cHoraI  := ""
    _cHoraF  := ""

EndIf

//====================================================================================================
// Leitura inicial dos parâmetros
//====================================================================================================
_cURL		:= SuperGetMV("LT_WSS_URL",.F.,"italac.smartquestion.com.br")
_cWS		:= SuperGetMV("LT_WSS_END",.F.,"italac.smartquestion.com.br/ws/WsSmartQuestionV14NoMtom?wsdl")
_lExecInt	:= SuperGetMV("LT_INT_SMQ",.F.,.T.)
_cMetodo	:= 'GET_ATENDIM'
_lVersaoNew := "14" $ _cWS

//====================================================================================================
// Monta a estrutura de dados do arquivo
//====================================================================================================
_cXmlAux1 := U_GLTSQXML( 1 , _cMetodo )
_cXmlAux2 := '<carregarAtendimentos>false</carregarAtendimentos>'	+CRLF
_cXmlAux2 += '<apenasConcluidos>false</apenasConcluidos>'			+CRLF

//====================================================================================================
// Define filtros de data/hora de acordo com a parametrização do sistema
//====================================================================================================
_cHoraLeu:=""
_nDias  := 0
_aXmlDia:= {} 
_cDiasT := _dDtfim-_dDtini+1
If !_lScheduler
   _oProcess:SetRegua1(_cDiasT)
ENDIF
_cDiasT := ALLTRIM(STR(_cDiasT,10))

aHoras:={}
_nHoraIni:=0
_nHorafim:=23
IF !EMPTY(_cHoraI) 
   _nHoraIni:=VAL(_cHoraI)
ENDIF
IF !EMPTY(_cHoraF) 
   _nHorafim:=VAL(_cHoraF)
ENDIF

FOR _nHr := _nHoraIni to _nHorafim

    _cHr := STRZERO(_nHr,2)

    FOR _nMi := 0 to 5

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

    NEXT   

NEXT

DO WHILE _dDtini <=  _dDtfim

   If !_lScheduler
      _nDias++
      _oProcess:IncRegua1("Lendo SQ v"+IF(_lVersaoNew,"14","9")+" dia: "+DTOC(_dDtini)+" - "+ALLTRIM(STR(_nDias,10))+" de "+_cDiasT+" dias..." )
      _oProcess:SetRegua2(LEN(aHoras))
   ENDIF
   
   FOR nHr:= 1 TO LEN(aHoras)
       If !_lScheduler
          _oProcess:IncRegua2("Lendo Hora "+aHoras[nHr,1]+" de "+aHoras[nHr,2]+" ..." )
       ENDIF

       AOMS93BuscaSQ(_dDtini,_dDtfim,aHoras[nHr,1],aHoras[nHr,2])

       If _lEnd//houve cancelamento do processo
          Exit
       Endif
   NEXT

   If _lEnd//houve cancelamento do processo			
      MessageBox("Processamento Cancelado pelo usuario com Sucesso.","Atenção",16)
      RETURN .F.	
   EndIf	      	

   _dDtini++

ENDDO

_aUF := {} 
aadd(_aUF,{"RO","11"});   aadd(_aUF,{"AC","12"});   aadd(_aUF,{"AM","13"});   aadd(_aUF,{"RR","14"});   aadd(_aUF,{"PA","15"});   aadd(_aUF,{"AP","16"})
aadd(_aUF,{"TO","17"});   aadd(_aUF,{"MA","21"});   aadd(_aUF,{"PI","22"});   aadd(_aUF,{"CE","23"});   aadd(_aUF,{"RN","24"});   aadd(_aUF,{"PB","25"})
aadd(_aUF,{"PE","26"});   aadd(_aUF,{"AL","27"});   aadd(_aUF,{"MG","31"});   aadd(_aUF,{"ES","32"});   aadd(_aUF,{"RJ","33"});   aadd(_aUF,{"SP","35"})
aadd(_aUF,{"PR","41"});   aadd(_aUF,{"SC","42"});   aadd(_aUF,{"RS","43"});   aadd(_aUF,{"MS","50"});   aadd(_aUF,{"MT","51"});   aadd(_aUF,{"GO","52"})
aadd(_aUF,{"DF","53"});   aadd(_aUF,{"SE","28"});   aadd(_aUF,{"BA","29"});   aadd(_aUF,{"EX","99"})

If !_lScheduler
   _oProcess:SetRegua1(LEN(_aXmlDia))
ENDIF

_nRecusado:=0
_nConta:=0
SM0->(DBSetOrder(1))
SA2->(DBSETORDER(1))
ZL0->(DBSetOrder(1))

FOR _nXml := 1 TO LEN(_aXmlDia)

   If _lEnd			//houve cancelamento do processo			
      MessageBox("Processamento Cancelado pelo usuario com Sucesso.","Atenção",16)
      RETURN .F.	
   EndIf	      	

   _cDataLendo:=DTOC(_aXmlDia[_nXml,1])

   If !_lScheduler
      _oProcess:IncRegua1("Processando dia: "+_cDataLendo )
   ENDIF
    
   _cErro:=""
   _aXml := {}

   //Tira caracter extendido que dá erro de UTF
//   _aXmlDia[_nXml,2] := strtran(_aXmlDia[_nXml,2],"º")
//   _aXmlDia[_nXml,2] := strtran(_aXmlDia[_nXml,2],"ñ")
   _oXml := XmlParser(_aXmlDia[_nXml,2] , "_" , @_cErro , @_cWarning )

    If !Empty(_cErro) .OR. ValType(_oXml) = 'U'//Tratamento de caracter extendido
       _aXmlDia[_nXml,2] := ConverteXML(_aXmlDia[_nXml,2])//Tira caracter extendido que dá erro de UTF
	   _oXml := XmlParser(_aXmlDia[_nXml,2] , "_" , @_cErro , @_cWarning )
    ENDIF

    If !Empty(_cErro) .OR. ValType(_oXml) = 'U'//Tira a observaçõe pq elas são abertas para digitar qq coisa
 
       _nAscI:=1
       DO WHILE _nAscI > 0
          
          _nAscI:=AT("<observacao>" , _aXmlDia[_nXml,2] ) 
          IF _nAscI > 0
             _nAscF:=AT("</observacao>", _aXmlDia[_nXml,2] ) 
             IF _nAscF > 0
                _nDel:=(_nAscF-_nAscI)+LEN("</observacao>")

		        IF MSGYESNO( "Deletar? "+SUBSTR(_aXmlDia[_nXml,2],_nAscI,_nDel) , 'Atenção! (MGLT002.PRW)')
                   _aXmlDia[_nXml,2] := STUFF(_aXmlDia[_nXml,2],_nAscI, _nDel ,"" )
                ENDIF
             ENDIF
          ENDIF
       
       ENDDO
 
 	   _oXml := XmlParser(_aXmlDia[_nXml,2] , "_" , @_cErro , @_cWarning )

    ENDIF   

   If !Empty(_cErro) .OR. ValType(_oXml) = 'U'
       IF ValType(_oXml) = 'U'
          _cErro+=" Sem retorno (NIL)"
       ENDIF
       _cErro:='Erro ao executar o XmlParser do xml no '+Chr(13)+Chr(10)+' periodo: '+_aXmlDia[_nXml,3]+" ate "+_aXmlDia[_nXml,4]+Chr(13)+Chr(10)+" Erro: ["+ALLTRIM(_cErro)+"]."
       IF !_lScheduler
	      IF !MSGNOYES(_cErro+Chr(13)+Chr(10)+"Deseja Continuar ?", 'Atenção!' , 48 )	      	      
	         EXIT 
	      ENDIF
	   ELSE
	      u_itconout( _cErro )
	   EndIf
	   Loop
   ENDIF

   If ValType( XmlChildEx( _oXml:_SOAP_BODY:_NS2_GETEXECUCAODIATRABALHOCRIADOOUMODIFICADORESPONSE , "_RETURN" ) ) <> 'U'
	  _aXml := _oXml:_SOAP_BODY:_NS2_GETEXECUCAODIATRABALHOCRIADOOUMODIFICADORESPONSE:_RETURN
   EndIF
	
   If ValType(_aXml) == 'O'
 	  _aXml := { _aXml }
   EndIf

   If !_lScheduler
      _oProcess:SetRegua2(Len(_aXml))
   ENDIF

   For _nI := 1 To Len(_aXml)

      _cFilial :="  "
      _cRotaReb:="  "
      If ValType( XmlChildEX(_aXml[_nI] , "_CICLOVISITA" ) ) = 'O'
         _cFilial := SubStr( AllTrim( _aXml[_nI]:_CICLOVISITA:_CODIGO:TEXT ) , 1 , 2 )
         _cRotaReb:= AllTrim( _aXml[_nI]:_CICLOVISITA:_CODIGO:TEXT )
      ENDIF

      _cVIAGEM := Space(Len(ZLJ->ZLJ_VIAGEM))
      If ValType( XmlChildEX(_aXml[_nI] , "_NUMERO" ) ) = 'O'
         _cVIAGEM := StrZero( Val( _aXml[_nI]:_NUMERO:TEXT ) , Len(ZLJ->ZLJ_VIAGEM) )
         _cVIAGEM := "S"+SUBSTR(_cVIAGEM,2)
      ENDIF

      _cDataLendo:=_aXmlDia[_nXml,1]
      _cHoraLeu:=""
      If ValType( XmlChildEX(_aXml[_nI] , "_DATAHORAULTIMAMODIFICACAO" ) ) = 'O'
         _cHoraLeu:=SubStr( _aXml[_nI]:_DATAHORAULTIMAMODIFICACAO:TEXT , 12 , 8 )
      ENDIF

      If !_lScheduler
         _oProcess:IncRegua2("Lendo Filial / Viagem: "+_cFilial+" / "+_cVIAGEM )
      ENDIF

      /////////////\/\/\/\/\/\/\/\/\//\/\/ VALIDACAO DA VIAGEM \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\//////////////////////////////////////////////

      If Empty(_cFilial)

         //AOMS93LogGrv(.F.,'Viagem recusada: Filial nao preenchida',.T.)
         Loop//Na Viagem

      Else

         If SM0->( !DBSeek( cEmpAnt + _cFilial ) )
            //AOMS93LogGrv(.F.,'Viagem recusada: Filial nao existe: '+_cFilial,.T.)
            Loop//Na Viagem
         EndIf

      EndIf

      IF !EMPTY(_cFiltroFilial) .AND. !(_cFilial $ _cFiltroFilial)
          Loop//Na Viagem
      EndIf

      _lAchouMoto:=.F.
      _cMotorista:=SPACE(Len(ZLJ->ZLJ_MOTORI))
      _cMotFilial:="  "
      _cCodtransp:=""
      _cLojtransp:=""
      _cCpfMotorista:=""

      If ValType( XmlChildEx( _aXml[_nI]:_USUARIO , "_CODIGO") ) <> 'U'//Só tem um motorista para todos os atendimentos
         _cMotorista:= AllTrim( _aXml[_nI]:_USUARIO:_CODIGO:TEXT)
         _cMotFilial:= Substr(Alltrim(_cMotorista),LEN(alltrim(_cMotorista))-1,2)
         _cMotorista:= Substr(Alltrim(_cMotorista),1,LEN(alltrim(_cMotorista))-2)

         If ZL0->( DBSeek( _cFilial + _cMotorista ) )
           _cCodtransp   := ZL0->ZL0_FRETIS
           _cLojtransp   := ZL0->ZL0_FRETLJ
           _cCpfMotorista:= ZL0->ZL0_CGC
           _lAchouMoto   := .T.

         EndIf

      EndIf

      _cMotivo:=""
      _cRecusa:=""
      _cAviso :=""
      _lPodeMarcar:=.T.

      _cViagemMae:=""
      If ValType( XmlChildEx( _aXml[_nI] , "_CUSTOMFIELD" ) ) == 'A'

         For _nX := 1 To Len( _aXml[_nI]:_CUSTOMFIELD )

             If ValType( XmlChildEx( _aXml[_nI]:_CUSTOMFIELD[_nX] , "_CODIGO" ) ) <> 'U'

                If _aXml[_nI]:_CUSTOMFIELD[_nX]:_CODIGO:TEXT == "CODIGO_MATRIZ"

                   _cViagemMae := StrZero( Val(_aXml[_nI]:_CUSTOMFIELD[_nX]:_VALORTEXTO:TEXT  ), Len(ZLJ->ZLJ_VIAGEM) )
                   _cViagemMae := "S"+SUBSTR(_cViagemMae,2)

                Endif

             Endif

         Next _nX

      ELSEIf ValType( XmlChildEx( _aXml[_nI] , "_CUSTOMFIELD" ) ) <> 'U'

          If ValType( XmlChildEx( _aXml[_nI]:_CUSTOMFIELD , "_CODIGO" ) ) <> 'U'

             If _aXml[_nI]:_CUSTOMFIELD:_CODIGO:TEXT == "CODIGO_MATRIZ"

                _cViagemMae := StrZero( Val(_aXml[_nI]:_CUSTOMFIELD:_VALORTEXTO:TEXT ), Len(ZLJ->ZLJ_VIAGEM) )
                _cViagemMae := "S"+SUBSTR(_cViagemMae,2)

             Endif

          Endif

      EndIf

      If !_lAchouMoto
         _cRecusa += '[Codigo "'+_cFilial+' '+_cMotorista+' '+_cMotFilial+'" não existe no cadastro de motoristas] '
         _lPodeMarcar:=.F.
         _lAchouMoto:=.F.
      ELSEIF !(_cMotFilial == _cFilial)
         _cRecusa += "[Filial da Viagem "+_cFilial+" difere da Filial do Motorista "+_cMotFilial+"] "
         _lPodeMarcar:=.F.
         _lAchouMoto:=.F.//Já que vai rejeitar nao precisa fazer o WHILE do ZL1
      EndIf
      SA2->(DBSETORDER(1))
      IF !SA2->(DBSEEK(Xfilial("SA2")+_cCodtransp+_cLojtransp))
         _cRecusa += "[Transportador: "+_cCodtransp +' '+ _cLojtransp+" nao cadastrado] "
         _lPodeMarcar:=.F.
      ENDIF

      //Verifica se placa está no cadastro de motoristas
      _cPlacaS:=""
      _cPlacaC:=SPACE(Len(ZG4->ZG4_CODCAV))
      If ValType( XmlChildEx( _aXml[_nI]:_VEICULOPRIMARIO , "_PLACA" ) ) <> 'U'
         _cPlacaS:= StrTran( AllTrim( _aXml[_nI]:_VEICULOPRIMARIO:_PLACA:TEXT ) , '-' , '' )
         _cPlacaC:= SubStr( _cPlacaS, 1 , 3 ) +'-'+ SubStr( _cPlacaS, 4 )
      EndIf

      _cVeiculo:=""
      _lAchouPlaca:=.F.
      ZL1->( DBSetorder(2))
      If _lAchouMoto .AND. ZL1->( DBSeek( _cFilial + _cPlacaS ) )
         DO WHILE ZL1->(!EOF()) .AND. _cFilial + _cPlacaS == ZL1->ZL1_FILIAL + ZL1->ZL1_PLACA
            IF ZL1->ZL1_MOTORI == _cMotorista
               _cVeiculo   :=ZL1->ZL1_COD
               _lAchouPlaca:=.T.
               EXIT
            ENDIF
            ZL1->(DBSKIP())
         ENDDO
      ENDIF

      _cPlaca      := _cPlacaS
      _cPlacaVagao := "9999999"

      IF !_lAchouPlaca

         _cRecusa += '[Placa "' +_cFilial+' '+ _cPlacaC + '" + Motorista "'+_cMotorista+' '+_cMotFilial+'" não encontrado] '
         _lPodeMarcar:=.F.

      EndIf

      _cCnpjTransp   := ""
      _cCodMunOri    := ""
      _cEstado       := ""
      _cCGC_Fil      := ""

      If _lAchouMoto
         _cCnpjTransp  := Posicione("SA2",1,xFilial("SA2")+_cCodtransp+_cLojtransp,"A2_CGC")
         _cCGC_Fil     := Posicione("SM0",1,cEmpAnt+_cFilial,"M0_CGC")
         _cCodMunOri   := Posicione("SA2",3,xFilial("SA2")+_cCGC_Fil,"A2_COD_MUN")
         _cEstado      := Posicione("SM0",1,cEmpAnt+_cFilial,"M0_ESTENT")
         _nPos         := aScan(_aUF,{|x| x[1] == _cEstado})
         IF _nPos # 0
            _cCodMunOri := _aUF[_nPos][02] + _cCodMunOri
         ENDIF
      ENDIF

      IF EMPTY(_cCpfMotorista) .OR. EMPTY(_cCnpjTransp) .OR. EMPTY(_cCodMunOri) .OR. EMPTY(_cEstado)
         IF EMPTY(_cCpfMotorista)
            _cRecusa += '[CPF do Motorista "'+_cMotorista+' '+_cFilial+'" não encontrado] '
         ENDIF
         IF EMPTY(_cCnpjTransp)
            _cRecusa += '[CNPJ da Transportadora "'+_cCodtransp +' '+ _cLojtransp+'" não encontrado] '
         ENDIF
         IF EMPTY(_cCGC_Fil)
            _cRecusa += '[CGC da filial "'+_cFilial+'" não encontrado] '
         ENDIF
         IF EMPTY(_cEstado)
            _cRecusa += '[Estado da filial "'+_cFilial+'" não encontrado] '
         ENDIF
         IF EMPTY(_cCodMunOri)
            _cRecusa += '[Cod. do Municipio "'+_cCGC_Fil+'" não encontrado] '
         ENDIF
         _lPodeMarcar:=.F.
      ENDIF

//    _lViagemAceita:=.F.

      IF ZLJ->(FIELDPOS("ZLJ_VFILHA")) # 0
         ZLJ->( DBSetOrder(6) )//ZLJ_FILIAL+ZLJ_VIAGEM+ZLJ_VFILHA
      ELSE
         ZLJ->( DBSetOrder(2) )
      ENDIF
                                                                                  //Tem que procurar a Mae com a filha em brnaco senão ele acha a as linhas da filhas já integradas
      If ZLJ->( DBSeek( _cFilial + IF(!EMPTY(_cViagemMae), _cViagemMae+_cVIAGEM , _cVIAGEM+SPACE(LEN(ZLJ->ZLJ_VIAGEM)) ) ) )
         _lPodeMarcar:=.F.
         _cRecusa := "[Viagem Integrada / Conferida (ZLJ)] "
      ENDIF

      _cVIAGEM := "9"+SUBSTR(_cVIAGEM,2)
      ZG4->( DBSetOrder(3) )//ZG4_FILIAL+ZG4_NRORDE+ZG4_SITUAC
      If ZG4->( DBSeek( _cFilial + _cVIAGEM ) )
         _lPodeMarcar:=.F.
         _cRecusa := "[Viagem já enviada para o RDC (ZG4)] "
      ENDIF

      If !EMPTY(_cViagemMae)
         _lPodeMarcar:=.F.
         _cRecusa := "[Viagem é uma filha da: "+_cViagemMae+" ] "
      ENDIF

      /////////////\/\/\/\/\/\/\/\/\//\/\/\ VALIDACAO DA VIAGEM /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\//////////////////////////////////////////////

	  If ValType( XmlChildEx( _aXml[_nI] , "_DATAHORAFIMDIA") ) <> 'U'
		 _dDtFim := StoD( StrTran( SubStr( _aXml[_nI]:_DATAHORAFIMDIA:TEXT , 1 , 10 ) , '-' , '' ) )
		 _cHrFim := SubStr( _aXml[_nI]:_DATAHORAFIMDIA:TEXT , 12 , 08 )
	  EndIf

      //////////////////////////////////////////////////////////// INICIO DO FOR DA GRAVACAO NO TRB //////////////////////////////////////////////////////////////

      //Grava tabela temporária  NÃO GRAVA AS FILHAS
      TRB_ZG4->(DBAPPEND())
      TRB_ZG4->ZG4_FILIAL	:= _cFilial
      TRB_ZG4->ZG4_DATA     := _cDataLendo
      TRB_ZG4->ZG4_HORA     := _cHoraLeu
      TRB_ZG4->ZG4_CNPJFA	:= _cCGC_Fil     // C	14	Fabrica
      TRB_ZG4->ZG4_NRORDE	:= _cVIAGEM        // C	12	Ordem de Carregamento		//DAK->DAK_COD
      TRB_ZG4->ZG4_CODCAV	:= _cPlaca 	       // DAK_CAMINH // C	7	Placa
      TRB_ZG4->ZG4_CODCAR	:= _cPlacaVagao    // DAK_CAMINH // C	7	Semi-Reboque	"9999999"
      TRB_ZG4->ZG4_CODMOT	:= _cCpfMotorista  // DAK_MOTORI // C	6	Motorista
      TRB_ZG4->ZG4_CODFRT	:= _cCnpjTransp    // C	14	Transportadora		// DAK->DAK_TRANSP este é um campo padrão não utilizado na Italac, Pegar transportadora no cadastro de motorista.
      TRB_ZG4->ZG4_CDMUOR   := _cCodMunOri     // Codigo IBGE Municipio de Origem
      TRB_ZG4->ZG4_CDMUDE   := _cCodMunOri     // Codigo IBGE Municipio de Destino
      TRB_ZG4->ZG4_TPOPER	:= "11"            // C	4	Tipo de Operação		10=Operacao de Carregamento;11=Operacao de Descarregamento
      TRB_ZG4->ZG4_SITOPE	:= "2"             // C	1	Situação da Operação	2=Inclusao;5=Exclusao
      TRB_ZG4->ZG4_USUARI	:= __CUSERID       // C	6	Codigo do Usuário
      TRB_ZG4->ZG4_SITUAC	:= "N" 	           // C	1	Situação do Registro	“N”
      TRB_ZG4->ZG4_CODEMP	:= _cCodEmpWS      // C	6	Codigo Empresa WebServer
      TRB_ZG4->WK_DTFINAL   := _dDtFim
      TRB_ZG4->WK_HRFINAL	:= _cHrFim

      IF _lPodeMarcar
         _cMotivo := "Atendimento OK"
         IF !EMPTY(_cRecusa)
            _cMotivo += ": "+_cRecusa
         ENDIF
      ELSE
         _cMotivo := "Viagem Recusada"
         IF !EMPTY(_cRecusa)
            _cMotivo += ": "+_cRecusa
         ENDIF
      ENDIF

     AOMS93LogGrv(_lPodeMarcar,_cMotivo,.F.)

     ////////////////////////////// FIM DA GRAVACAO NO TRB /////////////////////////////////////////////////////
  Next _nI

NEXT _nXml//LEN(_aXmlDia)

If _lScheduler .OR. Pergunte("AGLT021")

   U_AOMS93NF( _oProcess, _lEnd )//Le os dados das notas

ENDIF

IF TRB_ZG4->(EOF()) .AND. TRB_ZG4->(BOF())

   IF !_lScheduler
   	  MessageBox( 'Não foram encontrados registros para processar!' , 'Atenção!' , 48 )
   ELSE
      u_itconout('AOMS093 - Não foram encontrados registros no SQ para processar!')
   ENDIF
   _lRetorno:=.F.

ENDIF

Return _lRetorno

/*
===============================================================================================================================
Função------------: AOMS93NF
Autor-------------: Alex Wallauer
Data da Criacao---: 16/02/2017
===============================================================================================================================
Descrição-------: Função para busca os dados do SQ
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum                  
=============================================================================================================================== 
*/
User Function AOMS93NF( _oProcess, _lEnd )

Local _cCodEmpWS := U_ITGETMV( 'IT_EMPWEBSE' , '000001' )  
LOCAL cAliasNF := GetNextAlias()
LOCAL _nTot:=0

If !_lScheduler

   _cFiltroFilial:= MV_PAR01
   _dDtini       := MV_PAR02

   _oProcess:SetRegua1(0)
   _oProcess:IncRegua1("Lendo dados das notas...")
   _oProcess:SetRegua2(0)
   _oProcess:IncRegua2("Lendo dados das notas...")

Else

   _cFiltroFilial:= U_ITGETMV( 'IT_FILINTWS' , '01' )

   cUSUARIO := SPACE(06)+"Administrador  "
   cUsername:= "Schedure"
   _dDtini  := (DATE()-2)
   _lEnd    := .F.

EndIf


//====================================================================================================
// Define filtros de data/hora de acordo com a parametrização do sistema
//====================================================================================================
_cFiltroFilial:=IF(RIGHT(ALLTRIM(_cFiltroFilial),1)=";", LEFT( ALLTRIM(_cFiltroFilial) , LEN(ALLTRIM(_cFiltroFilial))-1 ) ,ALLTRIM(_cFiltroFilial))
_FiltFil:= FormatIn( _cFiltroFilial , ';' )
_dDtini := DTOS(_dDtini)

//SELECT NOTA
//A query para alimentar a integração das transferências com o RDC deve ser alguma coisa próxima disto. A parte "chumbada" com filia "01' da ZZM tem que ser substituídas pelo parâmetro que foi criado.
cQuery:=""
cQuery+=" SELECT SF2.R_E_C_N_O_ SF2_REC, "
cQuery+="               (SELECT ZZM.ZZM_CODIGO"
cQuery+="                  FROM "+ RetSqlName("ZZM") +" ZZM "
cQuery+="                     WHERE ZZM.ZZM_CGC = SA1.A1_CGC "
cQuery+="                       AND ZZM.ZZM_CODIGO IN "+_FiltFil
cQuery+="                       AND ZZM.D_E_L_E_T_ = ' ') FILIAL"
cQuery+="    FROM "+ RetSqlName("SF2") +" SF2 , "+ RetSqlName("SA1") +" SA1 "
cQuery+="      WHERE SF2.F2_EMISSAO >= '"+_dDtini+"'"
cQuery+="        AND SF2.F2_CLIENTE = '000001' "
cQuery+="        AND SF2.F2_TIPO = 'N' "
cQuery+="        AND SF2.F2_I_PLACA <> ' ' "
cQuery+="        AND SF2.F2_CARGA = ' ' "
cQuery+="        AND SF2.F2_I_NFSED <> 'S' "
cQuery+="        AND SF2.D_E_L_E_T_ = ' ' "
cQuery+="        AND SA1.A1_FILIAL = ' ' "
cQuery+="        AND SA1.A1_COD = SF2.F2_CLIENTE "
cQuery+="        AND SA1.A1_LOJA = SF2.F2_LOJA "
cQuery+="        AND SA1.D_E_L_E_T_ = ' ' " 
cQuery+="        AND EXISTS
cQuery+="               (SELECT ZZM.ZZM_CODIGO"
cQuery+="                  FROM "+ RetSqlName("ZZM") +" ZZM "
cQuery+="                     WHERE ZZM.ZZM_CGC = SA1.A1_CGC "
cQuery+="                       AND ZZM.ZZM_CODIGO IN "+_FiltFil
cQuery+="                       AND ZZM.D_E_L_E_T_ = ' ') "
cQuery+="  UNION ALL "
cQuery+="  SELECT SF2.R_E_C_N_O_ SF2_REC, "
cQuery+="               (SELECT ZZM.ZZM_CODIGO"
cQuery+="                  FROM "+ RetSqlName("ZZM") +" ZZM "
cQuery+="                     WHERE ZZM.ZZM_CGC = SA2.A2_CGC "
cQuery+="                       AND ZZM.ZZM_CODIGO IN "+_FiltFil
cQuery+="                       AND ZZM.D_E_L_E_T_ = ' ') FILIAL"
cQuery+="    FROM "+ RetSqlName("SF2") +" SF2 , "+ RetSqlName("SA2") +" SA2 "
cQuery+="      WHERE SF2.F2_EMISSAO >= '"+_dDtini+"'"
cQuery+="        AND SF2.F2_CLIENTE = 'F00001' "
cQuery+="        AND SF2.F2_TIPO IN ('B', 'D') "
cQuery+="        AND SF2.F2_I_PLACA <> ' '     "
cQuery+="        AND SF2.F2_CARGA = ' '        "
cQuery+="        AND SF2.F2_I_NFSED <> 'S'     "
cQuery+="        AND SF2.D_E_L_E_T_ = ' '      "
cQuery+="        AND SA2.A2_FILIAL = ' '   "
cQuery+="        AND SA2.A2_COD = SF2.F2_CLIENTE"
cQuery+="        AND SA2.A2_LOJA = SF2.F2_LOJA"
cQuery+="        AND SA2.D_E_L_E_T_ = ' '     "
cQuery+="        AND EXISTS                   "
cQuery+="               (SELECT ZZM.ZZM_CODIGO"
cQuery+="                  FROM "+ RetSqlName("ZZM") +" ZZM "
cQuery+="                     WHERE ZZM.ZZM_CGC = SA2.A2_CGC "
cQuery+="                       AND ZZM.ZZM_CODIGO IN "+_FiltFil
cQuery+="                       AND ZZM.D_E_L_E_T_ = ' ') "

If Select(cAliasNF) > 0
	(cAliasNF)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasNF , .T. , .F. )

If !_lScheduler
   DBSELECTAREA(cAliasNF)
   COUNT TO _nTot
   _oProcess:SetRegua1(_nTot)
   _oProcess:SetRegua2(_nTot)
ENDIF

_aUF := {} 
aadd(_aUF,{"RO","11"});   aadd(_aUF,{"AC","12"});   aadd(_aUF,{"AM","13"});   aadd(_aUF,{"RR","14"});   aadd(_aUF,{"PA","15"});   aadd(_aUF,{"AP","16"})
aadd(_aUF,{"TO","17"});   aadd(_aUF,{"MA","21"});   aadd(_aUF,{"PI","22"});   aadd(_aUF,{"CE","23"});   aadd(_aUF,{"RN","24"});   aadd(_aUF,{"PB","25"})
aadd(_aUF,{"PE","26"});   aadd(_aUF,{"AL","27"});   aadd(_aUF,{"MG","31"});   aadd(_aUF,{"ES","32"});   aadd(_aUF,{"RJ","33"});   aadd(_aUF,{"SP","35"})
aadd(_aUF,{"PR","41"});   aadd(_aUF,{"SC","42"});   aadd(_aUF,{"RS","43"});   aadd(_aUF,{"MS","50"});   aadd(_aUF,{"MT","51"});   aadd(_aUF,{"GO","52"})
aadd(_aUF,{"DF","53"});   aadd(_aUF,{"SE","28"});   aadd(_aUF,{"BA","29"});   aadd(_aUF,{"EX","99"})

SM0->(DBSetOrder(1))
SA2->(DBSETORDER(1))
ZL0->(DBSetOrder(1))

(cAliasNF)->(DBGOTOP())

DO WHILE (cAliasNF)->(!EOF())

   If _lEnd			//houve cancelamento do processo			
      MessageBox("Processamento Cancelado pelo usuario com Sucesso.","Atenção",16)
      RETURN .F.	
   EndIf 
   
   SF2->(DBGOTO((cAliasNF)->SF2_REC ))

   _cFilial   :=(cAliasNF)->FILIAL//Filial da portaria
   _cDataLendo:=SF2->F2_EMISSAO
   _cHoraLeu  :=TIME()

   If !_lScheduler
      _oProcess:IncRegua1("Lendo Filial / Data: "+_cFilial+" / "+DTOC(_cDataLendo) )
      _oProcess:IncRegua2("Lendo Filial / Nota: "+SF2->F2_FILIAL+" / "+SF2->F2_DOC )
   ENDIF

   /////////////\/\/\/\/\/\/\/\/\//\/\/ VALIDACAO \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\//////////////////////////////////////////////
      IF !EMPTY(_cFiltroFilial) .AND. !(_cFilial $ _cFiltroFilial)
          (cAliasNF)->(DBSKIP())
          Loop
      EndIf

      _cMotivo      := ""
      _cRecusa      := ""
      _cAviso       := ""
      _lPodeMarcar  := .T.
      _lAchouMoto   := .F.
      _cCodtransp   := ""
      _cLojtransp   := ""
      _cCpfMotorista:= ""
      _cMotorista   := SF2->F2_I_MOTOR
      _cPlaca       := SF2->F2_I_PLACA
      _cCodtransp   := SF2->F2_I_CTRA
      _cLojtransp   := SF2->F2_I_LTRA
      _cPlacaC      := SubStr( _cPlaca, 1 , 3 ) +'-'+ SubStr( _cPlaca, 4 )
      _cPlacaVagao  := "9999999"

      DA4->(DbSetOrder(1)) // DA4_FILIAL+DA4_COD
      If DA4->(DbSeek(xFilial("DA4")+_cMotorista))
         _cCpfMotorista:= DA4->DA4_CGC     
         _lAchouMoto   := .T.
      EndIf              

      If !_lAchouMoto
         _cRecusa += '[Codigo "'+_cMotorista+'" não existe no cadastro de motoristas (F2_I_MOTOR)] '
         _lPodeMarcar:=.F.
         _lAchouMoto:=.F.
      EndIf

      SA2->(DBSETORDER(1))
      IF !SA2->(DBSEEK(xFilial("SA2")+_cCodtransp+_cLojtransp))
         _cRecusa += "[Transportador: "+_cCodtransp +' '+ _cLojtransp+" nao cadastrado (F2_I_CTRA)] "
         _lPodeMarcar:=.F.
      ENDIF
		
      //Verifica se placa está no cadastro de motoristas
      IF EMPTY(_cPlaca)
         _cRecusa += '[Placa não preenchida (F2_I_PLACA)] '
         _lPodeMarcar:=.F.
      EndIf

      _cCnpjTransp   := ""
      _cCodMunOri    := ""
      _cEstado       := ""
      _cCGC_Fil      := ""

      If _lAchouMoto
         _cCnpjTransp  := Posicione("SA2",1,xFilial("SA2")+_cCodtransp+_cLojtransp,"A2_CGC")
         _cCGC_Fil     := Posicione("SM0",1,cEmpAnt+_cFilial,"M0_CGC")
         _cCodMunOri   := Posicione("SA2",3,xFilial("SA2")+_cCGC_Fil,"A2_COD_MUN")
         _cEstado      := Posicione("SM0",1,cEmpAnt+_cFilial,"M0_ESTENT")
         _nPos         := aScan(_aUF,{|x| x[1] == _cEstado})
         IF _nPos # 0
            _cCodMunOri := _aUF[_nPos][02] + _cCodMunOri
         ENDIF
      ENDIF

      IF EMPTY(_cCpfMotorista) .OR. EMPTY(_cCnpjTransp) .OR. EMPTY(_cCodMunOri) .OR. EMPTY(_cEstado)
         IF EMPTY(_cCpfMotorista)
            _cRecusa += '[CPF do Motorista "'+_cMotorista+'" não encontrado] '
         ENDIF
         IF EMPTY(_cCnpjTransp)
            _cRecusa += '[CNPJ da Transportadora "'+_cCodtransp +' '+ _cLojtransp+'" não encontrado] '
         ENDIF
         IF EMPTY(_cCGC_Fil)
            _cRecusa += '[CGC da filial "'+_cFilial+'" não encontrado] '
         ENDIF
         IF EMPTY(_cEstado)
            _cRecusa += '[Estado da filial "'+_cFilial+'" não encontrado] '
         ENDIF
         IF EMPTY(_cCodMunOri)
            _cRecusa += '[Cod. do Municipio "'+_cCGC_Fil+'" não encontrado] '
         ENDIF
         _lPodeMarcar:=.F.
      ENDIF

      ZG4->( DBSetOrder(3) )//ZG4_FILIAL+ZG4_NRORDE+ZG4_SITUAC
      If ZG4->( DBSeek( (cAliasNF)->FILIAL + SF2->F2_FILIAL+ALLTRIM(SF2->F2_DOC) ) )
         _lPodeMarcar:=.F.
         _cRecusa += "[Nota já enviada para o RDC (ZG4)] "
      ENDIF

      If (cAliasNF)->FILIAL = SF2->F2_FILIAL
         _lPodeMarcar:=.F.
         _cRecusa += "[Filial da Nota é a mesma do Cliente: "+SF2->F2_FILIAL+"] "
      ENDIF
      /////////////\/\/\/\/\/\/\/\/\//\/\/\ VALIDACAO /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\//////////////////////////////////////////////

      //////////////////////////////////////////////////////////// INICIO DO FOR DA GRAVACAO NO TRB //////////////////////////////////////////////////////////////

      //Grava tabela temporária
      TRB_ZG4->(DBAPPEND())
      TRB_ZG4->ZG4_FILIAL	:= (cAliasNF)->FILIAL
      TRB_ZG4->ZG4_DATA     := _cDataLendo
      TRB_ZG4->ZG4_HORA     := _cHoraLeu
      TRB_ZG4->ZG4_CNPJFA	:= _cCGC_Fil     // C	14	Fabrica
      TRB_ZG4->ZG4_NRORDE	:= SF2->F2_FILIAL+ALLTRIM(SF2->F2_DOC)
      TRB_ZG4->ZG4_CODCAV	:= _cPlaca 	       // DAK_CAMINH // C	7	Placa
      TRB_ZG4->ZG4_CODCAR	:= _cPlacaVagao    // DAK_CAMINH // C	7	Semi-Reboque	"9999999"
      TRB_ZG4->ZG4_CODMOT	:= _cCpfMotorista  // DAK_MOTORI // C	6	Motorista
      TRB_ZG4->ZG4_CODFRT	:= _cCnpjTransp    // C	14	Transportadora		// DAK->DAK_TRANSP este é um campo padrão não utilizado na Italac, Pegar transportadora no cadastro de motorista.
      TRB_ZG4->ZG4_CDMUOR   := _cCodMunOri     // Codigo IBGE Municipio de Origem
      TRB_ZG4->ZG4_CDMUDE   := _cCodMunOri     // Codigo IBGE Municipio de Destino
      TRB_ZG4->ZG4_TPOPER	:= "11"            // C	4	Tipo de Operação		10=Operacao de Carregamento;11=Operacao de Descarregamento
      TRB_ZG4->ZG4_SITOPE	:= "2"             // C	1	Situação da Operação	2=Inclusao;5=Exclusao
      TRB_ZG4->ZG4_USUARI	:= __CUSERID       // C	6	Codigo do Usuário
      TRB_ZG4->ZG4_SITUAC	:= "N" 	           // C	1	Situação do Registro	“N”
      TRB_ZG4->ZG4_CODEMP	:= _cCodEmpWS      // C	6	Codigo Empresa WebServer

      IF _lPodeMarcar
         _cMotivo := "Atendimento OK"
         IF !EMPTY(_cRecusa)
            _cMotivo += ": "+_cRecusa
         ENDIF
      ELSE
         _cMotivo := "Viagem Recusada"
         IF !EMPTY(_cRecusa)
            _cMotivo += ": "+_cRecusa
         ENDIF
      ENDIF

      AOMS93LogGrv(_lPodeMarcar,_cMotivo,.F.)

     (cAliasNF)->(DBSKIP())

     ////////////////////////////// FIM DA GRAVACAO NO TRB /////////////////////////////////////////////////////

ENDDO //(cAliasNF)->(!EOF())

If Select(cAliasNF) > 0
	(cAliasNF)->( DBCloseArea() )
EndIf

Return .T.

/*
===============================================================================================================================
Programa--------: AOMS93BuscaSQ()
Autor-----------: Alex Walaluer
Data da Criacao-: 11/07/2016
===============================================================================================================================
Descrição-------: Busca os dados do SQ por hora 
===============================================================================================================================
Parametros------: _dDtini    : Data inicial da busca
                  _dDtfim    : Data final da busca
                  _cHrInicial: hora inicial da busca
                  _cHrFinal  : hora final da busca
===============================================================================================================================
Retorno---------: .T.
===============================================================================================================================
*/
STATIC FUNCTION AOMS93BuscaSQ(_dDtini,_dDtfim,_cHrInicial,_cHrFinal)

Local _cXmlRet:= ''
Local _cErro  := ''
Local _cXml   := _cXmlAux1
_cDtIni:= substr(dtos(_dDtini),1,4) + "-" + substr(dtos(_dDtini),5,2) + "-" + substr(dtos(_dDtini),7,2) + _cHrInicial//"T00:00:00"
_cDtFim:= substr(dtos(_dDtini),1,4) + "-" + substr(dtos(_dDtini),5,2) + "-" + substr(dtos(_dDtini),7,2) + _cHrFinal  //"T23:59:59"
_cXml  += '<dataInicio>'+_cDtIni +'</dataInicio>'+CRLF
_cXml  += '<dataFim>'   +_cDtFim +'</dataFim>'   +CRLF
_cXml  += _cXmlAux2
_cXml  += U_GLTSQXML( 2 , _cMetodo )

IF _lVersaoNew
   _cXml:= STRTRAN(_cXml,"v9","v14")//Usa versão nova
   _cXml:= STRTRAN(_cXml,"V9","V14")//Usa versão nova
ENDIF

U_GLTSQENV( _cWS , _cXml , _aHdrOut , @_cErro , _cMetodo , @_cXmlRet )
   
If Empty(_cErro)
   AADD(_aXmlDia,{_dDtini,_cXmlRet,_cDtIni,_cDtFim, SUBSTR(_cHrInicial,2,9) })
ELSE
   IF !_lScheduler
	  MessageBox('Erro ao ler o xml do dia: '+_cDtIni+" ate "+_cDtFim+" -> Erro: ["+_cErro+"]" , 'Atenção!' , 48 )
   ELSE
	  u_itconout( 'AOMS093 - Erro ao ler o xml da data: '+_cdtini+" ate "+_cDtFim+" -> Erro: ["+_cErro+"]" )
   Endif
ENDIF

Return .T.

/*
===============================================================================================================================
Programa--------: AOMS93LogGrv()
Autor-----------: Alex Walaluer
Data da Criacao-: 04/07/2016
===============================================================================================================================
Descrição-------: Grava motivo TRB
===============================================================================================================================
Parametros------: _lPodeMarcar: .T. marca a linha 
                  _cMotivo    : observacao da linha , lAppend: .T. cria uma linha nova do TRB
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
STATIC FUNCTION AOMS93LogGrv(_lPodeMarcar,_cMotivo,lAppend)

IF lAppend
   TRB_ZG4->(DBAPPEND())
   TRB_ZG4->ZG4_DATA  := _cDataLendo
   TRB_ZG4->ZG4_HORA  := _cHoraLeu
   TRB_ZG4->ZG4_FILIAL:= _cFilial
   TRB_ZG4->ZG4_NRORDE:= _cVIAGEM 
ENDIF

IF _lPodeMarcar
	TRB_ZG4->WK_MARCA  := _cMarca
	TRB_ZG4->WK_STATUS:= "P"
    _nConta++
ELSE
	TRB_ZG4->WK_MARCA  := ""
	TRB_ZG4->WK_STATUS:= "R"
    _nRecusado++
ENDIF

TRB_ZG4->WK_MOTIVO := _cMotivo

RETURN .T.

/*
===============================================================================================================================
Programa----------: AjustaSX1
Autor-------------: AOMS93Tela
Data da Criacao---: 21/07/2015
===============================================================================================================================
Descrição---------: 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC FUNCTION AOMS93Tela()

Local cAliasWK     :="TRB_ZG4"
Local aBotoes      :={}
Local aTB_Campos   :={}
Local bMarcaTodos  :={|| U_AOMS093M("T"),oMark:oBrowse:Refresh() }
Local aCpoBrowse   :={"ZG4_FILIAL","ZG4_DATA","ZG4_HORA","ZG4_CNPJFA","ZG4_NRORDE","ZG4_CODCAV","ZG4_CODCAR","ZG4_CODMOT","ZG4_CODFRT","ZG4_CDMUOR","ZG4_CDMUDE","ZG4_TPOPER"}
Local aCoors	   := FWGetDialogSize(oMainWnd)
Local oDlg,cCampo,I
Local _cTitAux:="Resultado da Integração do SmartQuestion (AOMS093)"
Local aCab:={};_aCols:={}

AADD(aBotoes,{"RESPONSA",bMarcaTodos,"Marca/Desmarca Todos","Marca/Des Todos"})
AADD(aBotoes,{"Exp. Excel"	, {|| DlgToExcel( { { "ARRAY" , _cTitAux , aCab , _aCols } } ) }, "Exportação de Dados para Excel"		, "Exp. Excel"		} )
AADD(aBotoes,{"Exp. Arquivo", {|| U_ITGERARQ( _cTitAux , aCab , _aCols ) }					, "Exportação de Dados para Arquivo"	, "Exp. Arquivo"	} )

DBSELECTAREA(cAliasWK)

AADD(aTB_Campos,{"WK_MARCA",,"",})

FOR I := 1 TO LEN(aCpoBrowse)
    cCampo:=ALLTRIM(aCpoBrowse[I])
    AADD(aTB_Campos,{cCampo,,AVSX3(cCampo,5),AVSX3(cCampo,6)})
NEXT

Aadd(aTB_Campos, { "WK_MOTIVO",,"Observações",})

TRB_ZG4->(DBAPPEND())
TRB_ZG4->WK_MOTIVO:= ALLTRIM(STR(_nRecusado,10))+' Viagens Recusados'
TRB_ZG4->WK_STATUS:= "R"
TRB_ZG4->(DBAPPEND())
TRB_ZG4->WK_MOTIVO := ALLTRIM(STR(_nConta   ,10))+' Viagens Aceitos'
TRB_ZG4->WK_STATUS:= "R"
TRB_ZG4->(DBAPPEND())
TRB_ZG4->WK_MOTIVO := 'Hora Inicial: '+_cTimeInicial
TRB_ZG4->WK_STATUS:= "R"
TRB_ZG4->(DBAPPEND())
TRB_ZG4->WK_MOTIVO := 'Hora Final: '+TIME()
TRB_ZG4->WK_STATUS:= "R"

//Botões de Exportar *****************************
AADD(aCab,"Status" )
FOR I := 2 TO LEN(aTB_Campos)
    AADD(aCab,ALLTRIM(aTB_Campos[ I,3 ]) )
NEXT

TRB_ZG4->(DBGOTOP())
DO WHILE TRB_ZG4->(!EOF())

   _aColuna:={}
   AADD(_aColuna, TRB_ZG4->WK_STATUS )
   FOR I := 2 TO LEN(aTB_Campos)
       IF VALTYPE(aTB_Campos[ I,1 ]) = "C"
          _xConteudo:="TRB_ZG4->"+ALLTRIM(aTB_Campos[ I,1 ])
          _xConteudo:=&(_xConteudo)
          AADD(_aColuna,_xConteudo )
       ELSE
          _xConteudo:=EVAL(aTB_Campos[ I,1 ])
          AADD(_aColuna,_xConteudo )
       ENDIF   
   NEXT
   AADD(_aCols, _aColuna )

   TRB_ZG4->(DBSKIP())    
ENDDO
//Botões de Exportar *****************************

DO WHILE .T.
   nOpca:=0

   oMainWnd:ReadClientCoords()//So precisa declarar uma fez para o Programa todo
   DEFINE MSDIALOG oDlg TITLE "Seleção de NF/Viagens: Versão WebSQ "+IF(_lVersaoNew,"14","9") From aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] OF oMainWnd PIXEL
    (cAliasWK)->(DBSETORDER(1))
    (cAliasWK)->(DBGOTOP())
    oMark:=MSSELECT():New(cAliasWK,"WK_MARCA","WK_STATUS = 'R'",aTB_Campos,.F.,@_cMarca,{21,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})

  	oMark:bAval               := {|| U_AOMS093M("P"),oMark:oBrowse:Refresh() }
  	oMark:oBrowse:bAllMark    := bMarcaTodos
	oMark:oBrowse:lhasMark    := .T.
	oMark:oBrowse:lCanAllmark := .T.
	
   ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg, {|| (nOpca:=1,oDlg:End()) } , {|| (nOpca:=0,oDlg:End()) },,aBotoes) ,;
                                    oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT ,;
                                    oMark:oBrowse:Refresh() )
   IF nOpca = 1
      (cAliasWK)->(DBGOTOP()) 
      nTotal:=0
      (cAliasWK)->( DBEVAL( {|| nTotal++ }, {|| !EMPTY((cAliasWK)->WK_MARCA) } , {|| .T.} ) )
      IF nTotal = 0
         MessageBox("Não existem registros marcados, marque pelo menos uma viagem válida para integrar!","Atenção",16)
         LOOP
      ENDIF
      IF AVISO( "Confirma a INTEGRAÇÃO?" , "Serão integradas "+ALLTRIM(STR(nTotal,10))+" viagens", {"CONFIRMA","Voltar"} ,2 ) = 1
         EXIT
      ELSE
         LOOP
      ENDIF
   ELSEIF nOpca = 0 
      IF AVISO( "Confirma o CANCELAMENTO?" , "Todos os dados lidos e processados seram perdidos: ", {"Confirma","VOLTAR"} ,2 ) = 1
         RETURN .F.
      ELSE
         LOOP
      ENDIF
   ENDIF

   EXIT

ENDDO

RETURN .T.               
/*
===============================================================================================================================
Função------------: AOMS093M
Autor-------------: Alex Wallauer
Data da Criacao---: 16/02/2017
===============================================================================================================================
Descrição-------: Função para marcar e desmarcar
===============================================================================================================================
Parametros------: _cTipoMarca = "T" = Marca e desmarca todos os registros.
                  _cTipoMarca = "P" = Marca e desmarca apena o registro posisionado.                                           
===============================================================================================================================
*/
User Function AOMS093M(_cTipoMarca)

Local _cSimboloMarca := Space(2)
Local _nRegAtu := TRB_ZG4->(Recno()) 

Begin Sequence          

   If Empty(TRB_ZG4->WK_MARCA )
      _cSimboloMarca := _cMarca
   Else
      _cSimboloMarca := Space(2)
   EndIf   
      
   If _cTipoMarca == "P"
      TRB_ZG4->(RecLock("TRB_ZG4",.F.))
      TRB_ZG4->WK_MARCA := _cSimboloMarca 
      TRB_ZG4->(MsUnlock())
   Else
      TRB_ZG4->(DbGoTop())
      Do While ! TRB_ZG4->(Eof())
         TRB_ZG4->(RecLock("TRB_ZG4",.F.))
         TRB_ZG4->WK_MARCA := _cSimboloMarca 
         TRB_ZG4->(MsUnlock()) 
         
         TRB_ZG4->(DbSkip())
      EndDo
   
   EndIf
           
End Sequence

TRB_ZG4->(DbGoTo(_nRegAtu)) 
oMark:oBrowse:Refresh()

Return Nil
/*
===============================================================================================================================
Função------------: AOMS084D
Autor-------------: Alex Wallauer
Data da Criacao---: 16/02/2017
===============================================================================================================================
Descrição---------: Grava a tabela ZG4
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/
User Function AOMS093G()
LOCAL _nConta:=0
LOCAL cObs:=""

If !_lScheduler
   ProcRegua(TRB_ZG4->(LASTREC()))
ENDIF

TRB_ZG4->(DBGOTOP())

Begin Transaction

   Do While ! TRB_ZG4->(Eof())

      If ! _lScheduler
         IncProc("Gravando registros...")
      EndIf
      IF EMPTY(TRB_ZG4->WK_MARCA) .OR. TRB_ZG4->WK_STATUS = "R"
         TRB_ZG4->(DbSkip())
         LOOP
      ENDIF
      ZG4->(RecLock("ZG4",.T.))
      AVREPLACE("TRB_ZG4","ZG4")
      ZG4->ZG4_FILIAL:=TRB_ZG4->ZG4_FILIAL
      ZG4->(MsUnlock())

      _nConta++
      
      TRB_ZG4->(DbSkip())
   EndDo
   TRB_ZG4->(DbGoTop())

End Transaction

cObs+='Hora Inicial: '+_cTimeInicial+CHR(13)+CHR(10)
cObs+=ALLTRIM(STR(_nConta,10))+' Registros Gravadas (ZG4)'+CHR(13)+CHR(10)
cObs+=ALLTRIM(STR(_nRecusado,10))+' Registros Recusados (ZG4)'+CHR(13)+CHR(10)
cObs+='Hora Final: '+TIME()

Return cObs


/*
===============================================================================================================================
Programa--------: ConverteXML()
Autor-----------: Alex Walaluer
Data da Criacao-: 13/04/2017
===============================================================================================================================
Descrição-------: Tira os caracteres "estranos"
===============================================================================================================================
Parametros------: cRetornoXML: String
===============================================================================================================================
Retorno---------: cRetornoXML: String
===============================================================================================================================
*/
Static Function ConverteXML(cRetornoXML)//AWF - 13/04/2017 - Tira os caracteres "estranos"

   cRetornoXML:=StrTran(cRetornoXML,"Ã?","E")
   cRetornoXML:=StrTran(cRetornoXML,"Ã^","E")
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
   cRetornoXML:=StrTran(cRetornoXML,"!"," ")
   cRetornoXML:=StrTran(cRetornoXML,"×","x")
Return cRetornoXML