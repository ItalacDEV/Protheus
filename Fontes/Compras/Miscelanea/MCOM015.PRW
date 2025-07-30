/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor         |    Data    |                              Motivo                      										 
 Jonathan      | 28/09/2020 | Chamado 34262. Remoção de bugs apontados pelo Totvs CodeAnalysis. 
 Alex Walaluer | 11/05/2020 | Chamado 31089. Verifica os arrays vazias para não dar error.log. 
 Alex Walaluer | 31/04/2022 | Chamado 39639. Correção do envio de e-mail que estava apresentando tela via schedule. 
 Julio Paz     | 28/11/2022 | Chamado 41942. Ajustar relatório para demonstrar valores consolidados e por filial. 
 Alex Wallauer | 28/12/2022 | Chamado 41942. Ajustar relatório para demonstrar valores consolidados e por filial. 
 Lucas Borges  | 13/10/2024 | Chamado 48465. Retirada da função de conout
 ==============================================================================================================================
==============================================================================================================================================================
Analista - Programador  - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
Andre    - Igor Melgaço - 12/09/24 - 25/09/24 - 48311   - Alterar relatório para FwMsPrinter e gerar excel e pdf para envio de e-mail.
==============================================================================================================================================================

*/

#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE "RPTDEF.CH"  
#Include "TopConn.ch"
#Include "FWPrintSetup.ch"
 
//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
 
//Cores
#Define COR_CINZA   RGB(180, 180, 180)
#Define COR_PRETO   RGB(000, 000, 000)
 
//Colunas
#Define COL_FILIAL   0015
#Define COL_NOME     0040
#Define COL_PRODUTO  0140
#Define COL_QTDSOL   0290
#Define COL_QTDENT   0330
#Define COL_SALDO    0374 

/*
===============================================================================================================================
Programa----------: U_MCOM015
Autor-------------: Igor Melgaço
Data da Criacao---: 12/09/24
Descrição---------: Relatório_de_NFs_de_entrada_X_Entregas_SOBASICO. - Chamado: 33599
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MCOM015()
   Local aArea  := GetArea()
   Local ni := 0
   Local _aTabelas         := {'ZP1'}

   Private _dDate          := Date()
   Private _cDate          := Year2Str(_dDate) + Month2Str(_dDate)
   Private _lSchedule := .F.
     
   _lSchedule  := Select('SX3') == 0

   If _lSchedule
      RPCSetType(3)
      RpcSetEnv( "01" , "01" ,,,, "SCHEDULE_Pedidos_de_compra_X_Entregas - SOBASICO" , _aTabelas)
      sleep( 5000 )
      FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MCOM015"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MCOM01501"/*cMsgId*/, "MCOM01501 - Gerando relatório: " + Dtoc(_dDate) + " - " + Time()/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
      FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MCOM015"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MCOM01502"/*cMsgId*/, "MCOM01502 - Executando no ambiente " + Upper( GetEnvServer() )/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
      MCOM0015A()
   Else
      _aParAux :={} 
      _aParRet :={} 
      _bOK     :={|| IF(MV_PAR02 >= MV_PAR01,.T.,(U_ITMSG("Periodo INVALIDO",'Atenção!',"Tente novamente com outro periodo",3),.F.) ) }

      MV_PAR01 := dDataBase
      MV_PAR02 := dDataBase

      AADD( _aParAux , { 1 , "Data de"	        , MV_PAR01, "@D"	, ""	, ""		, "" , 050 , .T. } )
      AADD( _aParAux , { 1 , "Data ate"	     , MV_PAR02, "@D"	, ""	, ""		, "" , 050 , .T. } )

      For nI := 1 To Len( _aParAux )
         aAdd( _aParRet , _aParAux[nI][03] )
      Next nI

      //aParametros, cTitle                          , @aRet   ,[bOk]  , [ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ] 
      IF !ParamBox( _aParAux , "Selecione os filtros" , @_aParRet,  _bOK , /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
         RETURN .F.
      Else
         Processa({|| MCOM0015A()}, "Processando...")
      EndIf
   EndIf

   RestArea(aArea)
Return
 
/*
===============================================================================================================================
Programa----------: MCOM0015A
Autor-------------: Igor Melgaço
Data da Criacao---: 12/09/24
Descrição---------: Processamento do Relatório
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MCOM0015A()
   Local _cAlias     := GetNextAlias()
   Local _aConfig	   := U_ITCFGEML('')
   Local _aEmails    := {}
   Local _cFileName  := ""
   Local _aCabExcel  := {}
   Local _nY         := 0
   Local _cMsgEml    := ""
   Local _cEmlLog    := ""
   Local cCaminho    := ""
   Local cArquivo    := ""
   Local nAtual      := 0
   Local nTotal      := 0

   //Variáveis para disparo de e-Mail
   Local _cAssunto  := ""
   Local _cQuery    := ""
   Local _cEmail    := ""

   Local cFilialAnt := ""
   Local _aInfo     := {}
   Local nQtdSegUn  := 0
   Local nQtdEnt    := 0
   Local nSaldo     := 0
   Local nTQtdSegUn := 0
   Local nTQtdEnt   := 0
   Local nTSaldo    := 0
   Local bBloco     := {||}
   Local cListaEmail := ""
   Local _cEmailPA  := ""
   //Linhas e colunas
   Private nLinAtu   := 000
   Private nTamLin   := 010
   Private nLinFin   := 820
   Private nColIni   := 010
   Private nColFin   := 550
   Private nColMeio  := (nColFin-nColIni)/2
   Private nPagAtu   := 1

   //Objeto de Impressão
   Private oPrint

   //Variáveis auxiliares
   Private dDataGer  := Date()
   Private cHoraGer  := Time()

   //Fontes
   Private cNomeFont := "Arial"
   Private oFontDet  := TFont():New(cNomeFont, 9, -10, .T., .F., 5, .T., 5, .T., .F.)
   Private oFontDetN := TFont():New(cNomeFont, 9, -10, .T., .T., 5, .T., 5, .T., .F.)
   Private oFontRod  := TFont():New(cNomeFont, 9, -08, .T., .F., 5, .T., 5, .T., .F.)
   Private oFontTit  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)

   cArquivo  := "sobasico_sint_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-')

   cCaminho  := ALLTRIM(GETMV("MV_RELT",,"\SPOOL\"))
           //FWMsPrinter():New(< cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF], [ nQtdCopy] )
   oPrint := FWMSPrinter():New(cArquivo         , IMP_PDF   , .F.               , cCaminho        , .T.             ,             ,                ,            , .T.       ,             ,        , .F.        )

   //Setando os atributos necessários do relatório
   oPrint:SetResolution(72)
   oPrint:SetPortrait()
   oPrint:SetPaperSize(DMPAPER_A4)
   oPrint:SetMargin(60, 60, 60, 60)
   oPrint:SetViewPDF(.F.)
   oPrint:cPathPDF := cCaminho	

   //Montando a consulta
   _cQUery += "SELECT "
   _cQUery += "    C7_FILIAL, "
   _cQUery += "    C7_NUM, "
   _cQUery += "    x5_descri x5descri, "
   _cQUery += "    C7_PRODUTO, "
   _cQUery += "    SUM(c7_qtsegum) c7_qtsegum, "
   _cQUery += "    SUM(C7_QUJE)/B1_CONV C7_QUJE, "
   _cQUery += "    SUM(c7_qtsegum)- SUM(C7_QUJE)/B1_CONV SALDO "
   _cQUery += "FROM "
   _cQUery += "    "+RetSqlName("SC7")+" c7 "
   _cQUery += "    JOIN "+RetSqlName("SB1")+" b1 ON b1_cod = c7_produto "
   _cQUery += "    JOIN "+RetSqlName("SX5")+" x5 ON b1_i_bigrp = x5_chave "
   _cQUery += "WHERE "
   _cQUery += "    C7.d_e_l_e_t_ = ' ' "
   _cQUery += "    AND X5.d_e_l_e_t_ = ' ' "
   _cQUery += "    AND B1.d_e_l_e_t_ = ' ' "
   _cQUery += "    AND X5_tabela = 'ZA' "
   IF !_lSchedule
      _cQuery += " AND C7_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
   ELSE
      _cQuery += " AND C7_EMISSAO BETWEEN '"+_cDate+"01"+"' AND '"+_cDate+STRZERO(Last_Day(_dDate),2)+"' "
   ENDIF
   _cQUery += "    AND c7_fornece = 'F02270' "
   _cQUery += "GROUP BY "
   _cQUery += "    c7_filial, "
   _cQUery += "    c7_num, "
   _cQUery += "    x5_descri, "
   _cQUery += "    C7_PRODUTO, "
   _cQUery += "    B1_CONV "
   _cQUery += "ORDER BY "
   _cQUery += "    c7_filial, x5_descri "  

   DBUseArea( .T. , "TOPCONN" , TCGenQry(,,_cQuery) , _cAlias , .F. , .T. )

   //Conta o total de registros, seta o tamanho da régua, e volta pro topo
   Count To nTotal
   ProcRegua(nTotal)
   (_cAlias)->(DbGoTop())
   cFilialAnt := (_cAlias)->C7_FILIAL

    //Imprime o cabeçalho
   MCOM0015C()
   nAtual:=1 

   Do While (_cAlias)->(!EOF())
      If (nLinAtu + nTamLin) > nLinFin
         MCOM0015R()
         MCOM0015C()
      EndIf

      If !_lSchedule
         IncProc("Imprimindo Filial " + (_cAlias)->C7_FILIAL + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")
      EndIf

      //Imprimindo a linha atual
      oPrint:SayAlign(nLinAtu, COL_FILIAL , (_cAlias)->C7_FILIAL, oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
      oPrint:SayAlign(nLinAtu, COL_NOME   , Subs(FWFilialName(,(_cAlias)->C7_FILIAL),1,30),  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
      oPrint:SayAlign(nLinAtu, COL_PRODUTO, (_cAlias)->X5DESCRI,  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
      oPrint:SayAlign(nLinAtu, COL_QTDSOL-200 , TransForm((_cAlias)->C7_QTSEGUM,"@E 999,999,999.999"),  oFontDet, COL_QTDSOL, nTamLin, COR_PRETO, PAD_RIGHT, 0)
      oPrint:SayAlign(nLinAtu, COL_QTDENT-200 , TransForm((_cAlias)->C7_QUJE,"@E 999,999,999.999")   ,  oFontDet, COL_QTDENT, nTamLin, COR_PRETO, PAD_RIGHT, 0)
      oPrint:SayAlign(nLinAtu, COL_SALDO-200  , TransForm((_cAlias)->SALDO,"@E 999,999,999.999")     ,  oFontDet, COL_SALDO, nTamLin, COR_PRETO, PAD_RIGHT, 0)

      nLinAtu    += nTamLin

      nQtdSegUn += (_cAlias)->C7_QTSEGUM
      nQtdEnt   += (_cAlias)->C7_QUJE
      nSaldo    += (_cAlias)->SALDO

      nTQtdSegUn += (_cAlias)->C7_QTSEGUM
      nTQtdEnt   += (_cAlias)->C7_QUJE
      nTSaldo    += (_cAlias)->SALDO

      cFilialAnt := (_cAlias)->C7_FILIAL

      Aadd(_aInfo, {(_cAlias)->C7_FILIAL,;                // 1
                   FWFilialName(,(_cAlias)->C7_FILIAL),; // 2
                   AllTrim((_cAlias)->X5DESCRI),;        // 3
                   (_cAlias)->C7_QTSEGUM,;               // 4
                   (_cAlias)->C7_QUJE,;                  // 5
                   (_cAlias)->SALDO;                     // 6
                   })  

      (_cAlias)->(DbSkip())

      nAtual++

      //Imprimindo os Totais por Filial
      If cFilialAnt <> (_cAlias)->C7_FILIAL .OR. (_cAlias)->(EOF())

         //Se a linha atual mais o espaço que será utilizado forem maior que a linha final, imprime rodapé e cabeçalho
         If (nLinAtu + nTamLin + nTamLin) > nLinFin
            MCOM0015R()
            MCOM0015C()
         EndIf

         oPrint:SayAlign(nLinAtu, COL_FILIAL, "Total por Filial",  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
         nLinAtu += nTamLin
         oPrint:Line( nLinAtu , nColIni , nLinAtu , nColFin )
         
         oPrint:SayAlign(nLinAtu, COL_FILIAL , Space(Len((_cAlias)->C7_FILIAL)), oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
         oPrint:SayAlign(nLinAtu, COL_NOME   , Space(30),  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
         oPrint:SayAlign(nLinAtu, COL_PRODUTO, Space(Len((_cAlias)->X5DESCRI)),  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
         oPrint:SayAlign(nLinAtu, COL_QTDSOL-200 , TransForm(nQtdSegUn,"@E 999,999,999.999"),  oFontDet, COL_QTDSOL, nTamLin, COR_PRETO, PAD_RIGHT, 0)
         oPrint:SayAlign(nLinAtu, COL_QTDENT-200 , TransForm(nQtdEnt,"@E 999,999,999.999"),  oFontDet, COL_QTDENT, nTamLin, COR_PRETO, PAD_RIGHT, 0)
         oPrint:SayAlign(nLinAtu, COL_SALDO-200  , TransForm(nSaldo  ,"@E 999,999,999.999"),  oFontDet, COL_SALDO, nTamLin, COR_PRETO, PAD_RIGHT, 0)
         nLinAtu += nTamLin
         nLinAtu += nTamLin

         nQtdSegUn := 0
         nQtdEnt   := 0
         nSaldo    := 0
      EndIf

   EndDo

   //Se a linha atual mais o espaço que será utilizado forem maior que a linha final, imprime rodapé e cabeçalho
   If (nLinAtu + nTamLin + nTamLin) > nLinFin
      MCOM0015R()
      MCOM0015C()
   EndIf

   //Imprime o Total geral
   nLinAtu += nTamLin
   nLinAtu += nTamLin
   oPrint:SayAlign(nLinAtu, COL_FILIAL, "Total Geral",  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
   nLinAtu += nTamLin
   oPrint:Line( nLinAtu , nColIni , nLinAtu , nColFin )
   
   oPrint:SayAlign(nLinAtu, COL_FILIAL , Space(Len((_cAlias)->C7_FILIAL)), oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
   oPrint:SayAlign(nLinAtu, COL_NOME   , Space(30),  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
   oPrint:SayAlign(nLinAtu, COL_PRODUTO, Space(Len((_cAlias)->X5DESCRI)),  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
   oPrint:SayAlign(nLinAtu, COL_QTDSOL-200 , TransForm(nTQtdSegUn,"@E 999,999,999.999"),  oFontDet, COL_QTDSOL, nTamLin, COR_PRETO, PAD_RIGHT, 0)
   oPrint:SayAlign(nLinAtu, COL_QTDENT-200 , TransForm(nTQtdEnt,"@E 999,999,999.999"),  oFontDet, COL_QTDENT, nTamLin, COR_PRETO, PAD_RIGHT, 0)
   oPrint:SayAlign(nLinAtu, COL_SALDO-200  , TransForm(nTSaldo  ,"@E 999,999,999.999"),  oFontDet, COL_SALDO, nTamLin, COR_PRETO, PAD_RIGHT, 0)
   nLinAtu += nTamLin
   nLinAtu += nTamLin

   MCOM0015R()

   (_cAlias)->(DbCloseArea())

   oPrint:Preview() // GERA PDF AQUI

   cListaEmail := U_ITGETMV("IT_EMAILM14", "")
   _aEmails := StrTokArr(cListaEmail,";")

   _cFile1    := cCaminho + cArquivo + ".pdf"
   _cFile2    := cCaminho + cArquivo + ".xlsx"
   _cArqExcel := cArquivo + ".xlsx"
   _cTitulo   := "Relatório_de_NFs_de_entrada_X_Entregas_SOBASICO" 

      // Array com o cabeçalho das colunas do relatório. 
      // Alinhamento( 1-Left,2-Center,3-Right )
      // Formatação( 1-General,2-Number,3-Monetário,4-DateTime )
      //                  Titulo das Colunas ,Alinhamento ,Formatação, Totaliza? 
      Aadd(_aCabExcel,{"Filial"                 ,1           ,1         ,.F.})     
      Aadd(_aCabExcel,{"Nome Filial"            ,1           ,1         ,.F.})    
      Aadd(_aCabExcel,{"Produto"                ,1           ,1         ,.F.})  
      Aadd(_aCabExcel,{"Qtde Solicitada"        ,3           ,2         ,.F.})    
      Aadd(_aCabExcel,{"Qtde Entregue"          ,3           ,2         ,.F.})    
      Aadd(_aCabExcel,{"Saldo Pendente"         ,3           ,2         ,.F.})    

      //ITGEREXCEL(_cNomeArq,_cDiretorio,_cTitulo ,_cNomePlan,_aCabecalho,_aDetalhe,_lLeTabTemp,_cAliasTab,_aCampos,_lScheduller,_lCriaPastas,_aPergunte,_lEnviaEmail,_lXLSX)
      U_ITGEREXCEL(_cArqExcel,cCaminho  ,_cTitulo ,          ,_aCabExcel ,_aInfo   ,           ,          ,        , .T.        ,            ,          , .F.        ,.T.)

      If File(_cFile1) .OR. File(_cFile2)
         
         If File(_cFile1)
            _cFileName := _cFile1+";"
         ENDIF
         If File(_cFile2)
            _cFileName += _cFile2
         ENDIF
         
         _cAssunto  := "Relatório de NFs de entrada X Entregas SOBASICO"
         
         If !_lSchedule

            cListaEmail:=STRTRAN(cListaEmail,";",CHR(13)+CHR(10))
            cListaEmail:=STRTRAN(cListaEmail,",",CHR(13)+CHR(10))
            bBloco:={||  U_ITMsgLog(cListaEmail, "E-MAILs",1,.F.) }

            _cEmailPA:=Lower(AllTrim(UsrRetMail(__cUserId)))
            
            IF U_ITMSG("Deseja enviar o relatório somente para "+_cEmailPA+", ou enviar para todos os envolvidos (visualize em mais detalhes).",'Atenção!',,3,2,4,,"USUARIO","TODOS",bBloco)
               _aEmails := {_cEmailPA}
            ENDIF

         EndIf

         For _nY := 1 TO Len(_aEmails)
            _cEmlLog   := ""
            _cEmail    := _aEmails[_nY]
            _cMsgEml   := MCOM0015H(_cEmail,_cDate,_dDate)
         
            //U_ITENVMAIL(cFrom        ,cEmailTo       ,cEmailCo  ,cEmailBcc,_cAssunto ,_cMsgEml ,cAttach   ,cAccount    ,cPassword   ,cServer      ,cPortCon    ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro)
            U_ITENVMAIL( _aConfig[01]  , _cEmail       ,          ,         ,_cAssunto ,_cMsgEml,_cFileName,_aConfig[01],_aConfig[02], _aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )
         
            FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MCOM015"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MCOM01503"/*cMsgId*/, "MCOM01503 - " + _cEmlLog + Dtoc(_dDate) + ' - ' + Time()/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
         Next
      Else
         If !_lSchedule
   		   U_ITMSG("Problema na geração dos arquivos para envio do e-mail.",;
   		        "Atenção",;
   		        "Comunique o Administrador do Sistema!",3, , , .T.)
         Else
            FWLogMsg("ERROR"/*cSeverity*/, /*cTransactionId*/, "MCOM015"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MCOM01504"/*cMsgId*/, "MCOM01504 - Problema na geração dos arquivos para envio do e-mail."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
         EndIf
      EndIf

Return
 
/*
===============================================================================================================================
Programa----------: MCOM0015C
Autor-------------: Igor Melgaço
Data da Criacao---: 12/09/24
Descrição---------: Imprime o Cabeçalho do Relatório
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MCOM0015C()
   Local _cAssunto := ""
   Local nLinCab   := 030

   //Iniciando Página
   oPrint:StartPage()

   _cAssunto := "Pedidos de Compras x Entregas - SOBASICO
   _cProg    := "SIGA/MCOM015/v.12"
   _cGrupo   := Alltrim(FWGrpName())
   _cFilial  := Alltrim(FWFilialName(,cFilAnt))

   MCOM015CAB(oPrint,_cAssunto,@nLinCab,nTamLin,nColIni,nColFin,@nPagAtu,_cProg,_cGrupo,_cFilial)

   //Cabeçalho das colunas
   nLinCab += nTamLin
   oPrint:SayAlign(nLinCab, COL_FILIAL  , "Filial"         , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
   oPrint:SayAlign(nLinCab, COL_NOME    , "Nome Filial"    , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
   oPrint:SayAlign(nLinCab, COL_PRODUTO , "Produto"        , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
   oPrint:SayAlign(nLinCab, COL_QTDSOL-200  , "Qtde Solicitada", oFontDetN, COL_QTDSOL, nTamLin, COR_PRETO, PAD_RIGHT, 0)
   oPrint:SayAlign(nLinCab, COL_QTDENT-200  , "Qtde Entregue"  , oFontDetN, COL_QTDENT, nTamLin, COR_PRETO, PAD_RIGHT, 0)
   oPrint:SayAlign(nLinCab, COL_SALDO -200  , "Saldo Pendente" , oFontDetN, COL_SALDO, nTamLin, COR_PRETO, PAD_RIGHT, 0)

   nLinCab += nTamLin
   oPrint:Line( nLinCab, nColIni , nLinCab, nColFin )

   //Atualizando a linha inicial do relatório
   nLinAtu := nLinCab + 3
Return
 
/*
===============================================================================================================================
Programa----------: MCOM0015R
Autor-------------: Igor Melgaço
Data da Criacao---: 12/09/24
Descrição---------: Imprime o Radapé do Relatório
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MCOM0015R()
    Local nLinRod   := nLinFin + nTamLin
    Local cTextoDir := ''
    
    //Linha Separatória
    oPrint:Line(nLinRod, nColIni, nLinRod, nColFin, COR_PRETO)
    nLinRod += 3
     
    //Dados Direita
    cTextoDir := "Hora " + Time()
     
    //Imprimindo os textos
    //oPrint:SayAlign(nLinRod, nColIni,    cTextoEsq, oFontRod, 200, 05, COR_CINZA, PAD_LEFT,  0)
    oPrint:SayAlign(nLinRod, 0374-200, cTextoDir, oFontRod, 0374, 05, COR_PRETO, PAD_RIGHT, 0)
     
    //Finalizando a página e somando mais um
    oPrint:EndPage()
    nPagAtu++
Return



/*
===============================================================================================================================
Programa----------: MCOM014H
Autor-------------: Igor Melgaço
Data da Criacao---: 12/09/24
Descrição---------: Gera o html do corpo do e-mail
Parametros--------: 
Retorno-----------: _cMsgEml
===============================================================================================================================
*/
Static Function MCOM0015H(cEmail,cDate,dDate)
    Local _cMsgEml := ""
    Local cTit := "Pedidos de compra X Entregas - SOBASICO"
    Local cPer := ""

    _cMsgEml := '<html>'
    _cMsgEml += '<head><title>'+cTit+" - "+cEmail+'</title></head>'
    _cMsgEml += '<body>'
    _cMsgEml += '<style type="text/css"><!--'
    _cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
    _cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
    _cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
    _cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
    _cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
    _cMsgEml += '--></style>'
    _cMsgEml += '<center>'
    _cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="700" height="50"><br>'
    _cMsgEml += '<table class="bordasimples" width="700">'
    _cMsgEml += '    <tr>'
    _cMsgEml += '	     <td class="titulos"><center>'+cTit+'</center></td>'
    _cMsgEml += '	 </tr>'
    _cMsgEml += '</table>'
    _cMsgEml += '<br>'
    _cMsgEml += '<table class="bordasimples" width="700">'
    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td align="center" colspan="2" class="grupos">Dados do Relatório</b></td>'
    _cMsgEml += '    </tr>'

    cPer := "18"
    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="left" width="'+cPer+'%"><b>Descricao:</b></td>'
    _cMsgEml += '      <td class="itens" >'+ cTit +'</td>' 
    _cMsgEml += '    </tr>'

    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="left" width="'+cPer+'%"><b>Data Inicio:</b></td>'
    _cMsgEml += '      <td class="itens" >'+AllToChar(StoD(cDate+"01"))+'</td>'
    _cMsgEml += '    </tr>'

    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="left" width="'+cPer+'%"><b>Data Fim:</b></td>'
    _cMsgEml += '      <td class="itens" >'+AllToChar(DTOC(dDate))+'</td>'
    _cMsgEml += '    </tr>'

    _cMsgEml += '</table>'
    _cMsgEml += '</center>'
    _cMsgEml += '<br>'
    _cMsgEml += '<br>'
    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="left" ><b>Ambiente:</b></td>'
    _cMsgEml += '      <td class="itens" align="left" > ['+ GETENVSERVER() +'] / <b>Fonte:</b> [MCOM0015]</td>'
    _cMsgEml += '    </tr>'
    _cMsgEml += '</body>'
    _cMsgEml += '</html>'

Return _cMsgEml


/*
===============================================================================================================================
Programa----------: MCOM015CAB
Autor-------------: Igor Melgaço
Data da Criacao---: 12/09/24
Descrição---------: Imprime a barrasuperior do cabeçalho
Parametros--------: 
Retorno-----------: 
===============================================================================================================================
*/
Static Function MCOM015CAB(oPrint,_cAssunto,nLinha,nTamLinha,nColIni,nColFin,nPag,cProg,_cGrupo,_cFilial)
Local _oFont10	:= TFont():New( "Arial" ,, 8 ,,.T. )

nLinha := 50
oPrint:Line( nLinha, nColIni , nLinha, nColFin )
nLinha += 2
nLinhaFinal := nLinha +30
//oPrint:SayBitmap( nLinha-8, nColIni + 020 , 'lgrl01.bmp' , 300 , 130 ) // Imagem tem que estar abaixo do RootPath
oPrint:SayBitMap(nLinha,nColIni,'lgrl01.bmp',40,8)
oPrint:SayAlign(nLinha,nColFin-40, 'Página: '+ StrZero(nPag,3)	, _oFont10 ,nColFin,nTamLin, COR_PRETO, PAD_LEFT, 0)

nLinha += nTamLinha

oPrint:SayAlign(nLinha,nColIni   ,cProg , _oFont10, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
oPrint:SayAlign(nLinha,nColIni, _cAssunto	, _oFont10 ,nColFin,nTamLin, COR_PRETO, PAD_CENTER, 0)
oPrint:SayAlign(nLinha,nColFin-64, 'Data Ref.: '+ Dtoc(dDataBase)	, _oFont10 ,nColFin,nTamLin, COR_PRETO, PAD_LEFT, 0)

nLinha += nTamLinha

oPrint:SayAlign(nLinha,nColIni   ,"Grupo de Empresa: "+_cGrupo+"/"+_cFilial , _oFont10, 0300, nTamLin, COR_PRETO, PAD_LEFT, 0)
oPrint:SayAlign(nLinha,nColFin-64, 'Emissão.: '+ Dtoc(Date())	, _oFont10 ,nColFin,nTamLin, COR_PRETO, PAD_LEFT, 0)

nLinha := nLinhaFinal
oPrint:Line( nLinhaFinal, nColIni , nLinhaFinal, nColFin )

Return()
