/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 22/06/2022 | Chamado 40525. Correcoes de erro quando executado por schedule.
Lucas Borges  | 24/09/2024 | Chamado 48465. Sanado problemas apresentados no Code Analysis
Lucas Borges  | 22/04/2025 | Chamado 50505. Alterada a picture do CNPJ para contemplar campo alfanumérico
=====================================================================================================================================================================================================================
Analista       - Programador     - Inicio     - Envio    - Chamado - Motivo de Alteração
=====================================================================================================================================================================================================================
Lucas          - Alex Wallauer   - 02/05/2025 - 06/05/25 - 50525   - Ajuste para remoção de diretório local C:\SMARTCLIENT\.
Andre          - Alex Wallauer   - 23/05/2025 - 23/05/25 - 50793   - CORREÇÃO DE ERROR.LOG: Invalid GetTempPath() client call in JOB. Tratamento para não chamar a função GetTempPath() quando for shedule
Andre          - Alex Wallauer   - 26/05/2025 - 26/05/25 - 50793   - CORREÇÃO DE ERROR.LOG:variable does not exist LTELA on MCOM017EM(MCOM017.PRW) 25/05/2025 10:28:49 line : 334
=====================================================================================================================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

/*
===============================================================================================================================
Programa----------: MCOM017
Autor-------------: Alex Wallauer.
Data da Criacao---: 15/03/2022
Descrição---------: Workflow que monitora os PC que já tem o xml e Pré-NF .Chamado 39415
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MCOM017()///U_MCOM017
Local nI         := 0
Local _aParRet   := {}
Local _aParAux   := {}
Local _bOK       := {|| .T. }
Local _lRet      := .F.
PRIVATE _lTela   := .T.

//Testa se esta sendo rodado do menu
If Select('SX3') == 0


   RPCSetType( 3 )					//Não consome licensa de uso

   RpcSetEnv('01','01',,,,GetEnvServer(),{ "SDS","SDT","SF1" })
   sleep( 1000 )					//Aguarda 5 segundos para que as jobs IPC subam.

   _lTela := .F.

	MV_PAR01 := U_ItGetMV( 'IT_DIASAEP' , 0 )
	MV_PAR02 := U_ItGetMV( 'IT_DTINIMO' , StoD('20200101') )
    MV_PAR03 := ""
	MV_PAR04 := "1"
    MV_PAR05 := ""
ELSE

	MV_PAR01 := U_ItGetMV( 'IT_DIASAEP' , 0 )
	MV_PAR02 := U_ItGetMV( 'IT_DTINIMO' , StoD('20210101') )
	MV_PAR03 := AllTrim(UsrRetMail(__cUserId))+SPACE(200)
    MV_PAR04 := "2-Nao"
    MV_PAR05 := SPACE(100)

   AADD( _aParAux , { 1 , "Dias após a emissão Pre-NF", MV_PAR01, "999"	, ""	, ""	, "" , 060 , .F. } )
   AADD( _aParAux , { 1 , "Emissão a partir de"	      , MV_PAR02, "@D"	, ""	, ""	, "" , 060 , .T. } )
   AADD( _aParAux , { 1 , "E-mail Destino"	          , MV_PAR03, "@E"	, ""	, ""	, "" , 100 , .F. } )
   AADD( _aParAux , { 2 , "Efetivar Alterações"       , MV_PAR04, {"1-Sim","2-Nao"}          , 060 ,".T.",.T.,".T."})
   AADD( _aParAux , { 1 , "Pedido"                    , MV_PAR05, "!@"	, ""	, ""	, "" , 060 , .F. } )

   For nI := 1 To Len( _aParAux )
	    aAdd( _aParRet , _aParAux[nI][03] )
   Next nI
                         //aParametros, cTitle                                , @aRet    ,[bOk], [ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ]
   If !ParamBox( _aParAux , "WK que monitora os PC que já tem o xml e Pré-NF" , @_aParRet, _bOK, /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
	   RETURN .F.
   EndIf

EndIf

_cTimeIni  := TIME()

If _lTela

	FWMSGRUN( ,{|oProc|  _lRet := MCOM017EM(oProc) } , "Hora Inicial: "+_cTimeIni+" Lendo PCs a partir de: "+DTOC(MV_PAR02))

Else
	//Atualização tabela SM2
   FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MCOM017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MCOM01701"/*cMsgId*/, "MCOM017 - INICIO DO PROCESSAMENTO - Hora Inicial: "+_cTimeIni /*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

	_lRet := MCOM017EM()

   FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MCOM017"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MCOM01702"/*cMsgId*/, "MCOM017 - FIM DO PROCESSAMENTO - Hora Final: "+TIME() /*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

   RpcClearEnv() //Libera o Ambiente

EndIf

Return _lRet


/*
===============================================================================================================================
Programa----------: MCOM017EM
Autor-------------: Alex Wallauer
Data da Criacao---: 15/03/2022
Descrição---------: Rotina de envio do email
Parametros--------: oProc = objeto da barra de processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MCOM017EM(oProc)
Local _aConfig	  := {}
Local _cEmlLog	  := ""
Local _cMsgEml	  := ""
Local _cGetLista := ""
Local _aCab      := {}
Local _aSizes    := {}
Local cGetCc	  := ""
Local cGetPara	  := ""
Local cGetAssun  := "Workflow de pedidos de compra que já tem o xml importado e pré-nota gerada (Quadro 1/2)"
Local cGetAssun2 := "Workflow de xml importado e pré-nota gerada sem Pedido (Quadro 2/2)"
Local _cTit      := "Monitoramento de Pedidos / Notas Fiscais"
Local _nCont     := 0
Local _aDados    := {}

If oProc <> Nil
	oProc:cCaption := ("Lendo a SELECT...")
	ProcessMessages()
EndIf

//QUADRO 01
//           01       02     03           04       05           06          07          08        09        10        11          12     13
_aSizes := {"01"    ,"04"  ,"13"        ,"09"    ,"02"        ,"04"       ,"01"       ,"01"     ,"01"     ,"17"     ,"13"       ,"17"  ,"17"}       //Essa coluna só sai no Anexo e no listbox
_aCab   := {"Filial","N.F.","Fornecedor","CNPJ"  ,"Dt.Emis.NF","Dt.Pre-NF","Dt.Vencto","Pedido" ,"Item PC","Produto","Chave NFE","CFOP","Observação","Chave ZZH"}

//QUADRO 02
//           01       02     03           04       05           06          07        08        09          10     11
_aSizeSP:= {"01"    ,"06"  ,"13"        ,"09"    ,"05"        ,"05"       ,"01"     ,"16"     ,"13"       ,"16"  ,"16"}
_aCabSP := {"Filial","N.F.","Fornecedor","CNPJ"  ,"Dt.Emis.NF","Dt.Pre-NF","Item NF","Produto","Chave NFE","CFOP","Observação"}


_aNFSemPed := {}
_aDados    := {}
_aDados    := MCOM017QRY(oProc)// **************** PROCESSAMENTO **********************************
_nTotal    := Len(_aDados) + Len(_aNFSemPed)

If _nTotal > 0
	If _lTela// **************** TELA **********************************
	   //AADD(_aCab,"Chave ZZH")
       _cMsgTop:="Par. 1: "+ALLTRIM(AllToChar(MV_PAR02))+"; Par. 2: "+ALLTRIM(AllToChar(MV_PAR04))+" -  H.I.: "+_cTimeIni+" H.F.: "+TIME()
       //QUADRO 01
       If Len(_aDados) > 0 .AND. !U_ITListBox( cGetAssun  , _aCab   , _aDados    , .T. , 1 , _cMsgTop)
	      RETURN .F.
	   ENDIF
       //QUADRO 02
       If Len(_aNFSemPed) > 0 .AND. !U_ITListBox( cGetAssun2 , _aCabSP , _aNFSemPed , .T. , 1 , _cMsgTop)
	      RETURN .F.
	   ENDIF
	ENDIF
ELSE
   If _lTela
      U_ITMSG("Não há dados para listar.","Envio do E-MAIL",,3)
	  RETURN .F.
   ENDIF
EndIf

//Logo Italac
_cMsgEml := '<html>'
_cMsgEml += '<head><title>'+_cTit+'</title></head>'
_cMsgEml += '<body>'
_cMsgEml += '<style type="text/css"><!--'
_cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
_cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
_cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
//_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:10px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
//_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:10px; V-align:middle; margin-right: 13px; margin-left: 15px; background-color: #FFFFFF; }'
_cMsgEml += '--></style>'
_cMsgEml += '<center>'
_cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="600" height="50"><br>'
_cMsgEml += '<br>'

//Celula Azul para Título
_cMsgEml += '<table class="bordasimples" width="800">'
_cMsgEml += '    <tr>'
_cMsgEml += '	     <td class="titulos"><center>'+_cTit+'</center></td>'
_cMsgEml += '	 </tr>'
_cMsgEml += '</table>'
_cMsgEml += '<br>'

//********************************  QUADRO 1 *************************************************************************
//             01       02     03           04       05           06          07          08        09        10        11          12     13
//_aSizes := {"01"    ,"06"  ,"15"        ,"10"    ,"06"        ,"06"       ,"01"       ,"01"     ,"01"     ,"22"     ,"14"       ,"14"  ,"20"}
//_aCab   := {"Filial","N.F.","Fornecedor","CNPJ"  ,"Dt.Emis.NF","Dt.Pre-NF","Dt.Vencto","Pedido" ,"Item PC","Produto","Chave NFE","CFOP","Observação"}

_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="3100">'
_cMsgEml += '    <tr>'
_cMsgEml += '		<td align="left" colspan="'+ALLTRIM(STR(LEN(_aSizes)))+'" class="grupos"><b>'+cGetAssun+'</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[01]+'%"><b>'+_aCab[01]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[02]+'%"><b>'+_aCab[02]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[03]+'%"><b>'+_aCab[03]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[04]+'%"><b>'+_aCab[04]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[05]+'%"><b>'+_aCab[05]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[06]+'%"><b>'+_aCab[06]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[07]+'%"><b>'+_aCab[07]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[08]+'%"><b>'+_aCab[08]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[09]+'%"><b>'+_aCab[09]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[10]+'%"><b>'+_aCab[10]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[11]+'%"><b>'+_aCab[11]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[12]+'%"><b>'+_aCab[12]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[13]+'%"><b>'+_aCab[13]+'</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    #LISTA#'
_cMsgEml += '</table>'

_cGetLista := ""
_nTot:=nConta:=0
_nTot:=LEN(_aDados)
_cTot:=ALLTRIM(STR(_nTot))

For _nCont := 1 To Len(_aDados)

	If oProc <> Nil
       nConta++
	   oProc:cCaption := ('1/2-Enviando Q1: '+ALLTRIM(STR(nConta))+" de "+_cTot )
	   ProcessMessages()
	EndIf

	_cGetLista += '    <tr>'
	_cGetLista += '      <td class="itens" align="center" width="'+_aSizes[01]+'%">'+ _aDados[_nCont][01] +'</td>'
	_cGetLista += '      <td class="itens" align="left"   width="'+_aSizes[02]+'%">'+ _aDados[_nCont][02] +'</td>'
	_cGetLista += '      <td class="itens" align="left"   width="'+_aSizes[03]+'%">'+ _aDados[_nCont][03] +'</td>'
	_cGetLista += '      <td class="itens" align="center" width="'+_aSizes[04]+'%">'+ _aDados[_nCont][04] +'</td>'
	_cGetLista += '      <td class="itens" align="center" width="'+_aSizes[05]+'%">'+ _aDados[_nCont][05] +'</td>'
	_cGetLista += '      <td class="itens" align="center" width="'+_aSizes[06]+'%">'+ _aDados[_nCont][06] +'</td>'
	_cGetLista += '      <td class="itens" align="center" width="'+_aSizes[07]+'%">'+ _aDados[_nCont][07] +'</td>'
	_cGetLista += '      <td class="itens" align="center" width="'+_aSizes[08]+'%">'+ _aDados[_nCont][08] +'</td>'
	_cGetLista += '      <td class="itens" align="center" width="'+_aSizes[09]+'%">'+ _aDados[_nCont][09] +'</td>'
	_cGetLista += '      <td class="itens" align="left"   width="'+_aSizes[10]+'%">'+ _aDados[_nCont][10] +'</td>'
	_cGetLista += '      <td class="itens" align="left"   width="'+_aSizes[11]+'%">'+ _aDados[_nCont][11] +'</td>'
	_cGetLista += '      <td class="itens" align="left"   width="'+_aSizes[12]+'%">'+ _aDados[_nCont][12] +'</td>'
	_cGetLista += '      <td class="itens" align="left"   width="'+_aSizes[13]+'%">'+ _aDados[_nCont][13] +'</td>'
	_cGetLista += '    </tr>'
Next

_cMsgEml := STRTRAN(_cMsgEml,"#LISTA#",_cGetLista)

//********************************  QUADRO 2 *************************************************************************
_cMsgEml += '<br>'
_cMsgEml += '<br>'
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="3100">'
_cMsgEml += '    <tr>'
_cMsgEml += '		<td align="left" colspan="'+ALLTRIM(STR(LEN(_aSizeSP)))+'" class="grupos"><b>'+cGetAssun2+'</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'

////           01       02     03           04       05           06          07        08        09          10     11
//_aSizeSP:= {"01"    ,"06"  ,"15"        ,"10"    ,"06"        ,"06"       ,"01"     ,"22"     ,"14"       ,"14"  ,"22"}
//_aCabSP := {"Filial","N.F.","Fornecedor","CNPJ"  ,"Dt.Emis.NF","Dt.Pre-NF","Item NF","Produto","Chave NFE","CFOP","Observação"}

_cMsgEml += '      <td class="itens" align="center" width="'+_aSizeSP[01]+'%"><b>'+_aCabSP[01]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizeSP[02]+'%"><b>'+_aCabSP[02]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizeSP[03]+'%"><b>'+_aCabSP[03]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizeSP[04]+'%"><b>'+_aCabSP[04]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizeSP[05]+'%"><b>'+_aCabSP[05]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizeSP[06]+'%"><b>'+_aCabSP[06]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizeSP[07]+'%"><b>'+_aCabSP[07]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizeSP[08]+'%"><b>'+_aCabSP[08]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizeSP[09]+'%"><b>'+_aCabSP[09]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizeSP[10]+'%"><b>'+_aCabSP[10]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizeSP[11]+'%"><b>'+_aCabSP[11]+'</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    #LISTA2#'
_cMsgEml += '</table>'

_cGetLista := ""
_nTot:=nConta:=0
_nTot:=LEN(_aNFSemPed)
_cTot:=ALLTRIM(STR(_nTot))
For _nCont := 1 To  Len(_aNFSemPed)
	If oProc <> Nil
       nConta++
	   oProc:cCaption := ('2/2-Enviando Q2: '+ALLTRIM(STR(nConta))+" de "+_cTot )
	   ProcessMessages()
	EndIf
	_cGetLista += '    <tr>'
	_cGetLista += '      <td class="itens" align="center" width="'+_aSizeSP[01]+'%">'+ _aNFSemPed[_nCont][01] +'</td>'
	_cGetLista += '      <td class="itens" align="left"   width="'+_aSizeSP[02]+'%">'+ _aNFSemPed[_nCont][02] +'</td>'
	_cGetLista += '      <td class="itens" align="left"   width="'+_aSizeSP[03]+'%">'+ _aNFSemPed[_nCont][03] +'</td>'
	_cGetLista += '      <td class="itens" align="center" width="'+_aSizeSP[04]+'%">'+ _aNFSemPed[_nCont][04] +'</td>'
	_cGetLista += '      <td class="itens" align="center" width="'+_aSizeSP[05]+'%">'+ _aNFSemPed[_nCont][05] +'</td>'
	_cGetLista += '      <td class="itens" align="center" width="'+_aSizeSP[06]+'%">'+ _aNFSemPed[_nCont][06] +'</td>'
	_cGetLista += '      <td class="itens" align="center" width="'+_aSizeSP[07]+'%">'+ _aNFSemPed[_nCont][07] +'</td>'
	_cGetLista += '      <td class="itens" align="left"   width="'+_aSizeSP[08]+'%">'+ _aNFSemPed[_nCont][08] +'</td>'
	_cGetLista += '      <td class="itens" align="left"   width="'+_aSizeSP[09]+'%">'+ _aNFSemPed[_nCont][09] +'</td>'
	_cGetLista += '      <td class="itens" align="left"   width="'+_aSizeSP[10]+'%">'+ _aNFSemPed[_nCont][10] +'</td>'
	_cGetLista += '      <td class="itens" align="left"   width="'+_aSizeSP[11]+'%">'+ _aNFSemPed[_nCont][11] +'</td>'
	_cGetLista += '    </tr>'
Next

_cMsgEml := STRTRAN(_cMsgEml,"#LISTA2#",_cGetLista)


_cMsgEml += '</center>'
_cMsgEml += '<br>'
_cMsgEml += '<br>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
_cMsgEml += '      <td class="itens" align="left" > ['+ GETENVSERVER() +'] / <b>Fonte:</b> [MCOM017]</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '</body>'
_cMsgEml += '</html>'

IF LEN(_aNFSemPed) = 0 .AND. LEN(_aDados) = 0
   lEnviaPlan:=.F.
ELSE
   lEnviaPlan:=.T.
ENDIF

IF lEnviaPlan

	If oProc <> Nil
       nConta++
	   oProc:cCaption := ('1 / 1 - Criando arquivo XML para anexar...')
	   ProcessMessages()
	EndIf

   _cPathSrv :="\data\Italac\WS\"
   IF _lTela
      _cPathLoc := GetTempPath()//só tela
   ELSE
      _cPathLoc := ""
   ENDIF
   _cArquivo :="XML_X_PCS_"+Dtos(Date())+"_"+StrTran(Time(),":","")+".xml"
   _cFileName:=_cPathSrv+_cArquivo

    _aCab1:={}
    For _nCont := 1 to len(_aCab)
    	// Alinhamento: 1-Left   ,2-Center,3-Right
    	// Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
    	//          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
    	IF _nCont = 5 .OR. _nCont = 6 .OR. _nCont = 7
      	   Aadd(_aCab1,{_aCab[_nCont]     ,2           ,4         ,.F.})
        ELSE
    	   Aadd(_aCab1,{_aCab[_nCont]     ,1           ,1         ,.F.})
    	ENDIF
    Next

////           01       02     03           04       05           06          07        08        09          10     11
//_aCabSP := {"Filial","N.F.","Fornecedor","CNPJ"  ,"Dt.Emis.NF","Dt.Pre-NF","Item NF","Produto","Chave NFE","CFOP","Observação"}
	_aCab2:={}
    For _nCont := 1 to len(_aCabSP)
    	// Alinhamento: 1-Left   ,2-Center,3-Right
    	// Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
    	//          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
    	IF _nCont = 5 .OR. _nCont = 6
      	   Aadd(_aCab2,{_aCabSP[_nCont]     ,2           ,4         ,.F.})
        ELSE
    	   Aadd(_aCab2,{_aCabSP[_nCont]     ,1           ,1         ,.F.})
    	ENDIF
    Next
    _aCabs:={}
	_aGerExel:={}

	AADD(_aCabs,{"XML Com Pedidos",_aCab1})
	AADD(_aGerExel,_aDados)

	IF LEN(_aNFSemPed) > 0
	   AADD(_aCabs,{"XML Sem Pedidos",_aCab2})
	   AADD(_aGerExel,_aNFSemPed)
	ENDIF
    SET DATE FORMAT TO "DD/MM/YYYY"
    //ITGEREXCEL(_cNomeArq,_cDiretorio,_cTitulo,_cNomePlan,_aCabecalho,_aDetalhe,_lLeTabTemp,_cAliasTab,_aCampos,_lScheduller,_lCriaPastas,_aPergunte,_lEnviaEmail)
    U_ITGEREXCEL(_cArquivo,_cPathSrv  ,_cTit   ,          ,_aCabs     ,_aGerExel,           ,          ,        , .T.        , .T.        ,          , .F.)
    SET DATE FORMAT TO "DD/MM/YY"

   cAttach:=_cFileName
   If _lTela
      If !__CopyFile( _cFileName , _cPathLoc+_cArquivo)
         U_ITMSG("Nao conseguiu copiar o arquivo DE "+_cFileName+" PARA "+_cPathLoc+_cArquivo,;
                'COPIA DE ARQUIVO',;
                "Email será enviado mesmo assim",3)
      ENDIF
   ENDIF
ELSE
   cAttach:=NIL
ENDIF

_cEmail:=""
IF !EMPTY(MV_PAR03)
   _cEmail:=AllTrim(MV_PAR03)+";"
ENDIF

DBSelectArea('ZZL')
IF ZZL->(FIELDPOS("ZZL_EMLWFM")) > 0
    ZZL->( Dbsetfilter({ | | ZZL->ZZL_EMLWFM="S" }, 'ZZL->ZZL_EMLWFM="S"') )
    ZZL->( Dbgotop() )
    DO WHILE .NOT. ZZL->( EOF() )
    	_cEmail += ALLTRIM( ZZL->ZZL_EMAIL ) + ";"
    	ZZL->( Dbskip() )
    ENDDO
    ZZL->(DBCLEARFILTER())
ENDIF
_cEmail:=substr(_cEmail,1,len(_cEmail)-1)
_aEmail:=StrTokArr(_cEmail,";")
For _nCont := 1 to Len(_aEmail)

	cGetPara := _aEmail[_nCont]
	cGetCC   := ""
	If oProc <> Nil
		oProc:cCaption := ("Enviando o e-mail...")
		ProcessMessages()
	EndIf

	_aConfig	  := U_ITCFGEML('')

	// Chama a função para envio do e-mail
	//ITEnvMail(cFrom       ,cEmailTo ,_cEmailCo,cEmailBcc,cAssunto ,cMensagem,cAttach,cAccount    ,cPassword   ,cServer     ,cPortCon    ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro)
	U_ITENVMAIL(_aConfig[01], cGetPara,   cGetCc,       "",cGetAssun, _cMsgEml,cAttach,_aConfig[01], _aConfig[02],_aConfig[03],_aConfig[04],_aConfig[05],_aConfig[06],_aConfig[07], @_cEmlLog )

    _lEnviouEmail := .F.

    IF _lTela
        bBloco:=NIL
    	_cBotao:=""
        IF FILE(_cPathLoc+_cArquivo)
           bBloco:={|| ShellExecute("open", _cArquivo, "", _cPathLoc , 1) }
   		   _cBotao:="Com anexo " + LOWER(ALLTRIM(_cfileName))+CHR(13)+CHR(10)+"Clique em detalhes para ver o anexo"
        ENDIF
        U_ITMSG(_cEmlLog+CHR(13)+CHR(10)+'Envio de E-mail P/ '+_aEmail[_nCont],;
                'Resultdo do Envio de E-mail ',;
                _cBotao,3,,,,,,bBloco)
    ENDIF

Next

If _lTela .AND. File(_cPathLoc+_cArquivo)
   Ferase(_cPathLoc+_cArquivo)
ENDIF

IF cAttach <> NIL .AND. File(cAttach)
   Ferase(cAttach)
Endif

Return .T.


/*
===============================================================================================================================
Programa----------: MCOM017QRY
Autor-------------: Alex Wallauer
Data da Criacao---: 15/03/2022
Descrição---------: Gera a lista de dados
Parametros--------: oProc
Retorno-----------: _cGetLista = Lista dos dados
===============================================================================================================================
*/
Static Function MCOM017QRY(oProc)
Local _cAlias   := '' , P
Local _aNFComPed:= {}
Local _aDados   := {}
Local _aPedidos :={}
_aNFSemPed:={}


_cAlias := GetNextAlias()

_cQuery:=" SELECT SDS.R_E_C_N_O_ NRRECDS ,SDT.R_E_C_N_O_ NRRECDT, SF1.R_E_C_N_O_ NRRECF1  "
_cQuery+="  FROM "+RETSQLNAME('SDS') +" SDS,"+RETSQLNAME('SDT')+" SDT,"+RETSQLNAME('SF1')+" SF1"
_cQuery+="   WHERE SDS.D_E_L_E_T_  = ' ' AND SDT.D_E_L_E_T_  = ' ' AND SF1.D_E_L_E_T_  = ' '"
_cQuery+="     AND SDS.DS_TIPO     = 'N' "
_cQuery+="     AND SDS.DS_STATUS   = 'P' "
_cQuery+="     AND SDS.DS_DATAPRE <> ' ' "
_cQuery+="     AND SDS.DS_DATAPRE <= '"+DTOS(DATE()-MV_PAR01)+"'"
_cQuery+="     AND SDS.DS_DATAPRE >= '"+DTOS(MV_PAR02)+"'"
_cQuery+="     AND SDT.DT_FILIAL  = SDS.DS_FILIAL "
_cQuery+="     AND SDT.DT_FORNEC  = SDS.DS_FORNEC "
_cQuery+="     AND SDT.DT_LOJA    = SDS.DS_LOJA "
_cQuery+="     AND SDT.DT_DOC     = SDS.DS_DOC "
_cQuery+="     AND SDT.DT_SERIE   = SDS.DS_SERIE "
_cQuery+="     AND SDT.DT_CNPJ    = SDS.DS_CNPJ "
IF !EMPTY(MV_PAR05)
   _cQuery+="     AND SDT.DT_PEDIDO  IN "+FormatIn(ALLTRIM(MV_PAR05),";")
ENDIF
_cQuery+="     AND SF1.F1_FILIAL  = SDS.DS_FILIAL "
_cQuery+="     AND SF1.F1_FORNECE = SDS.DS_FORNEC "
_cQuery+="     AND SF1.F1_LOJA    = SDS.DS_LOJA "
_cQuery+="     AND SF1.F1_DOC     = SDS.DS_DOC "
_cQuery+="     AND SF1.F1_SERIE   = SDS.DS_SERIE "
_cQuery+="     AND SF1.F1_STATUS  = ' ' "
_cQuery+="   ORDER BY SDT.DT_FILIAL, SDS.DS_DOC, SDS.DS_SERIE,  SDT.DT_PEDIDO, SDT.DT_ITEMPC"

MPSysOpenQuery( _cQuery,_cAlias )

DbSelectArea(_cAlias)
_nTot:=nConta:=0
COUNT TO _nTot
_cTot:=ALLTRIM(STR(_nTot))

SC7->(DbSetOrder(1))
(_cAlias)->(DBGoTop())
If !(_cAlias)->(EOF())
	Do While !(_cAlias)->(EOF())

	If oProc <> Nil
       nConta++
	   oProc:cCaption := ('1/3-Gravando SC7: '+ALLTRIM(STR(nConta))+" de "+_cTot )
	   ProcessMessages()
	EndIf

    SDS->(DBGOTO((_cAlias)->NRRECDS))
    SDT->(DBGOTO((_cAlias)->NRRECDT))
    SF1->(DBGOTO((_cAlias)->NRRECF1))
	IF !EMPTY(SDT->DT_PEDIDO)
	    IF SC7->(DbSeek(SDT->(DT_FILIAL+DT_PEDIDO+DT_ITEMPC)))
		   IF SC7->C7_ENCER = 'E' .OR. SC7->C7_RESIDUO = 'S'
		      (_cAlias)->(DBSkip())
			  LOOP
		   ENDIF
	       IF SC7->C7_I_DTFAT <> SF1->F1_EMISSAO
	          _cMen:="DT faturamento do PC alterado de "+DTOC(SC7->C7_I_DTFAT)+" para "+DTOC(SF1->F1_EMISSAO)+" / NF disponivel para classificar desde "+DTOC(SDS->DS_DATAPRE)

	          IF MV_PAR04 = "1"
			     SC7->(RECLOCK("SC7",.F.))
		         SC7->C7_I_DTFAT:=SF1->F1_EMISSAO
		         SC7->(MSUNLOCK())
			  ENDIF

	       ELSE
	          _cMen:="NF disponivel p/ classificar desde "+DTOC(SDS->DS_DATAPRE)+" / Dt.fat.: "+DTOC(SC7->C7_I_DTFAT)
	       ENDIF
	       IF ASCAN(_aPedidos,{|P|P[1]=SDT->(DT_FILIAL+DT_PEDIDO)}) = 0
	          AADD(_aPedidos,{SDT->(DT_FILIAL+DT_PEDIDO),""})
	       ENDIF
	    ENDIF

//_aCab   := {"Filial","N.F.","Fornecedor","CNPJ"  ,"Dt.Emis.NF","Dt.Pre-NF","Dt.Vencto","Pedido" ,"Item","Produto","Chave NFE","Observação"}
		AADD(_aNFComPed,{SDT->DT_FILIAL,;                 //01
					SDT->DT_DOC+"/"+SDT->DT_SERIE,;  //02
					SDT->DT_FORNEC+"/"+SDT->DT_LOJA+"-"+Alltrim(POSICIONE("SA2",1,xFilial("SA2")+SDT->DT_FORNEC+SDT->DT_LOJA,"A2_NREDUZ")),;//03
					TRANSF(SDT->DT_CNPJ,"@R! NN.NNN.NNN/NNNN-99") ,;//04
					DTOC((SDS->DS_EMISSA)) ,;        //05
					DTOC((SDS->DS_DATAPRE)),;        //06
					"",;                             //07
					Alltrim(SDT->DT_PEDIDO),;        //08
					Alltrim(SDT->DT_ITEMPC),;        //09
					Alltrim(SDT->DT_COD)+"-"+Alltrim(Posicione("SB1",1,Xfilial("SB1")+SDT->DT_COD,"B1_DESC")),;//10
					SF1->F1_CHVNFE,;//11
					SDT->DT_CODCFOP+"-"-fDesc("SX5","13"+SDT->DT_CODCFOP,"X5_DESCRI"),;
					_cMen,SDT->(DT_FILIAL+AVKEY(SDT->DT_PEDIDO,"ZZH_PEDIDO")+DT_ITEMPC)})//12,13

	ELSE
      _cMen:="NF sem pedido de compra vinculado / Dt.NF.Emis.: "+DTOC(SF1->F1_EMISSAO)

//_aCab   := {"Filial","N.F.","Fornecedor","CNPJ"  ,"Dt.Emis.NF","Dt.Pre-NF","Item","Produto","Chave NFE","Observação"}
		AADD(_aNFSemPed,;
		           {SDT->DT_FILIAL,;                 //01
					SDT->DT_DOC+"/"+SDT->DT_SERIE,;  //02
					SDT->DT_FORNEC+"/"+SDT->DT_LOJA+"-"+Alltrim(POSICIONE("SA2",1,xFilial("SA2")+SDT->DT_FORNEC+SDT->DT_LOJA,"A2_NREDUZ")),;//03
					TRANSF(SDT->DT_CNPJ,"@R! NN.NNN.NNN/NNNN-99") ,;//04
					DTOC((SDS->DS_EMISSA)) ,;        //05
					DTOC((SDS->DS_DATAPRE)),;        //06
					Alltrim(SDT->DT_ITEM),;          //07
					Alltrim(SDT->DT_COD)+"-"+Alltrim(Posicione("SB1",1,Xfilial("SB1")+SDT->DT_COD,"B1_DESC")),;//08
					SF1->F1_CHVNFE,;//09
					SDT->DT_CODCFOP+"-"-fDesc("SX5","13"+SDT->DT_CODCFOP,"X5_DESCRI"),;
					_cMen})//10

	ENDIF

	(_cAlias)->(DBSkip())

	EndDo


EndIf


_nTot:=nConta:=0
_nTot:=LEN(_aPedidos)
_cTot:=ALLTRIM(STR(_nTot))

SC7->(DbSetOrder(1))
FOR P := 1 TO LEN(_aPedidos)
	If oProc <> Nil
       nConta++
	   oProc:cCaption := ("2/3-Atualizando ZZH: "+_aPedidos[P,1]+" / "+ALLTRIM(STR(nConta))+" de "+_cTot )
	   ProcessMessages()
	ENDIF
    IF MV_PAR04 = "1" .AND. SC7->(DbSeek(_aPedidos[P,1]))
	   U_ACOM008ZZH(ALLTRIM(SC7->C7_FILIAL), ALLTRIM(SC7->C7_NUM))
	ENDIF
NEXT
//********************************************************************

DbSelectArea(_cAlias)
_nTot:=nConta:=0
_nTot:=LEN(_aNFComPed)
_cTot:=ALLTRIM(STR(_nTot))
_aDados:={}
FOR P := 1 TO LEN(_aNFComPed)

	If oProc <> Nil
       nConta++
	   oProc:cCaption := ('3/3-Lendo ZZH: '+ALLTRIM(STR(nConta))+" de "+_cTot )
	   ProcessMessages()
	EndIf

    IF ZZH->( Dbseek(_aNFComPed[P,LEN(_aNFComPed[P])]) )
	   Do While ZZH-> (!EOF()) .AND. ZZH->ZZH_FILIAL+ZZH->ZZH_PEDIDO+ZZH->ZZH_ITEMPC == _aNFComPed[P,LEN(_aNFComPed[P])]
	      AADD(_aDados,ACLONE(_aNFComPed[P]))
		  _aDados[LEN(_aDados),7]:=DTOC(ZZH->ZZH_DATA)
		  ZZH->(DBSKIP())
	   ENDDO
	ELSE
       AADD(_aDados,_aNFComPed[P])
	ENDIF

NEXT

(_cAlias)->( DBCloseArea() )

Return _aDados
