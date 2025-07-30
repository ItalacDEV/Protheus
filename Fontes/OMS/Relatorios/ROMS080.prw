/*
====================================================================================================================================================================================================
                     ULTIMAS ATUALIZAÇÕES EFETUADAS
====================================================================================================================================================================================================
Analista  - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
====================================================================================================================================================================================================
Jerry     - Alex Walaluer - 25/09/23 - 03/10/24 - 48545   - Criacao desse relatorio: RELATORIOS DE EMISSÃO DE NFS DE DEVOLUÇÃO, ENTRADA E SAÍDA DE PALLETS.
Vanderlei - Alex Walaluer - 17/01/25 - 17/01/25 - 49630   - Ajuste na geração da planilha para não gerar o titulo, ordenacao e retirar os acentos.
====================================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'protheus.ch'
#INCLUDE "topconn.ch"
#include "msmgadd.ch"
#include "dbtree.ch"
#Include "RWMake.ch"
#INCLUDE "RPTDEF.CH"

/*
===============================================================================================================================
Programa--------: ROMS080 // U_ROMS080
Autor-----------: Alex Wallauer
Data da Criacao-: 25/09/2023
===============================================================================================================================
Descrição-------: Chamado 48545. RELATORIOS DE EMISSÃO DE NFS DE DEVOLUÇÃO, ENTRADA E SAÍDA DE PALLETS.
===============================================================================================================================
Parametros------: NENHUM
===============================================================================================================================
Retorno---------: NENHUM
===============================================================================================================================
*/
USER FUNCTION ROMS080()// U_ROMS080
 LOCAL nI As Numeric, _nX As Numeric // Variáveis de controle de loops
 LOCAL _aParAux:={} As Array // Array de parâmetros auxiliares
 LOCAL _aParRet:={} As Array // Array de parâmetros de retorno
 Local aAcesso := FWEmpLoad(.F.) As Array // Array de filiais de acesso
 LOCAL _cTitulo:="RELATORIOS DE EMISSÃO DE NFS DE DEVOLUÇÃO, ENTRADA E SAÍDA DE PALLETS - "+DTOC(DATE()) As Character // Título do relatório

 Private _aParOpc:={"1-Entrada","2-Saída","3-Devolução","4-Todos"} As Array // Opções de geração
 MV_PAR01:=SPACE(100)
 MV_PAR02:=DATE()
 MV_PAR03:=DATE()
 MV_PAR04:=4

 aAdd( _aParAux , { 1 , "Filiais"    , MV_PAR01, "@!", "",'SM0001',"" , 100 , .F. })
 AADD( _aParAux , { 1 , "Data de"    , MV_PAR02, "@D", "" , ""  , ""  , 060 , .T. })
 AADD( _aParAux , { 1 , "Data ate"   , MV_PAR03, "@D", "" , ""  , ""  , 060 , .T. })
 AADD( _aParAux , { 3 , "Geração"    , MV_PAR04, _aParOpc , 060 ,".T.",.T.  ,".T."})

 For nI := 1 To Len( _aParAux )
     aAdd( _aParRet , _aParAux[nI][03] )
 Next nI

 DO WHILE .T.

      IF !ParamBox( _aParAux , "Selecione os filtros" , _aParRet , {|| .T. } , , , , , , , .T. , .T. )
         EXIT
      EndIf

     IF !(MV_PAR03 >= MV_PAR02)
            U_ITMSG("Periodo da Data de Emissão INVALIDO",'Atenção!',"Tente novamente com outro periodo",1)
            LOOP
     ENDIF
      xVarAux := ALLTRIM(MV_PAR01)
      _cFilsAcesso := ""
      For _nX := 1 To LEN(aAcesso)
          _cFilsAcesso+=aAcesso[_nX][03]+", "
      Next _nX
      If EMPTY(xVarAux)
        //U_ITMSG("Com a filial em branco, somente as filiais que o usuario tem acesso serao selecionadas: "+_cFilsAcesso+" (MV_PAR01)",'Atenção!',,1)
            //MV_PAR01:=STRTRAN( _cFilsAcesso, ", ", ";")
      Else
           aDadAux := U_ITLinDel( xVarAux , ";" )
           SM0->(dbSetOrder(1))
           For nI := 1 To LEN(aDadAux)
              If !SM0->(dbSeek(cEmpAnt + aDadAux[nI]))
               U_ITMSG("Filial "+aDadAux[nI]+" informada não existe. (MV_PAR01)",'Atenção!',"Selecione no minimo uma Filial dessa lista: "+_cFilsAcesso,1)
                 LOOP
              EndIf
              If !aDadAux[nI] $ _cFilsAcesso
               U_ITMSG("Filial "+aDadAux[nI]+" informada o usuário não tem acesso.",'Atenção!',"Selecione no minimo uma Filial dessa lista: "+_cFilsAcesso,1)
                 LOOP
              EndIf
           Next nI
      EndIf
     IF VALTYPE(MV_PAR04) = "N"
        MV_PAR04:=STR(MV_PAR04,1)
     ENDIF

      Private cTime1Inicial:=TIME() As Character
      Private aCab    :={} As Array
      Private _aCabXML:={} As Array
      Private _aColXML:={} As Array
      Private _aDados :={} As Array
      // Alinhamento: 1-Left   ,2-Center,3-Right
      // Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
      //             Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
      //   (_aCabXML,{Titulo             ,1           ,1         ,.F.       })
      AADD(aCab   , "CNPJ ORIGEM")
      AADD(_aCabXML,{aCab[LEN(aCab)]     ,2           ,1         ,.F.})// 01

      AADD(aCab   , "GLID ORIGEM")
      AADD(_aCabXML,{aCab[LEN(aCab)]     ,2           ,1         ,.F.})// 02

      AADD(aCab   , "RAZAO SOCIAL ORIGEM")
      AADD(_aCabXML,{aCab[LEN(aCab)]     ,1           ,1         ,.F.})// 03

      AADD(aCab   , "CNPJ DESTINO")
      AADD(_aCabXML,{aCab[LEN(aCab)]     ,2           ,1         ,.F.})// 04

      AADD(aCab   , "GLID DESTINO")
      AADD(_aCabXML,{aCab[LEN(aCab)]     ,2           ,1         ,.F.,})// 05

      AADD(aCab   , "RAZAO SOCIAL DESTINO")
      AADD(_aCabXML,{aCab[LEN(aCab)]     ,1           ,1         ,.F.})// 06

      AADD(aCab   , "DATA EMISSAO" )     ;nPosData:=LEN(aCab)
      AADD(_aCabXML,{aCab[LEN(aCab)]     ,2           ,4         ,.F.})// 07

      AADD(aCab   , "NOTA FISCAL" )
      AADD(_aCabXML,{aCab[LEN(aCab)]     ,2           ,1         ,.F.})// 08

      AADD(aCab   , "PRODUTO")
      AADD(_aCabXML,{aCab[LEN(aCab)]     ,2           ,1         ,.F.})// 09

      AADD(aCab   , "QUANTIDADE")        ; nPosQtde:=LEN(aCab)
      AADD(_aCabXML,{aCab[LEN(aCab)]     ,3           ,2         ,.F.,"@E 9,999"})// 10

      AADD(aCab   , "MOVIMENTO")
      AADD(_aCabXML,{aCab[LEN(aCab)]     ,1           ,1         ,.F.})// 11

      FWMSGRUN(,{|_oProc|  ROMS80CP(_oProc)  }, "Selecionando dados - Hr. Ini. : "+cTime1Inicial,"Filtrando Dados..." )

      Private _cTitulo2:=_cTitulo+" - H. F. : "+TIME() As Character
      Private _cMsgTop:="Data de Emissão: "  +ALLTRIM(AllToChar(MV_PAR02))+" ate "+ALLTRIM(AllToChar(MV_PAR03))+"; Geracao: " +_aParOpc[VAL(MV_PAR04)]+"; Filiais: "+ALLTRIM(MV_PAR01)+" - Hr. Ini. : "+cTime1Inicial+" / H. F. : "+TIME() As Character

      DO WHILE LEN(_aDados) > 0

         _cMsgFil:=_cTitulo2+CRLF+;
                   "Filiais: "        +ALLTRIM(MV_PAR01)+CRLF+;
                   "Data de Emissão: "+ALLTRIM(AllToChar(MV_PAR02))+" ate "+ALLTRIM(AllToChar(MV_PAR03))+CRLF+;
                   "Geração: "        +_aParOpc[VAL(MV_PAR04)]

         _aSX1:=ROMS80Per()
         aBotoes:={}
         AADD(aBotoes,{"",{|| U_ITMsgLog(_cMsgFil, "FILTROS APLICADOS" )                                                   },"","Filtros Aplicados"    })

                          //      ,_aCols  ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab   , bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk,_aSX1,lComCab )
         U_ITListBox(_cTitulo2,aCab,_aDados, .T.    , 1    ,_cMsgTop ,          ,       ,         ,     ,        , aBotoes  , _aCabXML,         , _aColXML ,           ,         ,       ,         ,     ,.F.)

         IF !U_ITMSG("Confirma Sair ?",'Atenção!',_cTitulo2,3,2,2)
            LOOP
         ENDIF
         EXIT
    ENDDO

 ENDDO

Return

/*
===============================================================================================================================
Programa--------: ROMS80CP
Autor-----------: Alex Wallauer
Data da Criacao-: 25/09/2023
===============================================================================================================================
Descrição-------: Ler os dados da Select e grava da array
===============================================================================================================================
Parametros------: _oProc
===============================================================================================================================
Retorno---------: _aDados
===============================================================================================================================*/
Static Function ROMS80CP(_oProc As Object) As Array
 Local _cQuery1:= "" As Char, L As Numeric
 Local _cQuery2:= "" As Char
 Local _cQuery3:= "" As Char
 Local _cAlias1:= GetNextAlias() As Char
 Local _cAlias2:= GetNextAlias() As Char
 Local _cAlias3:= GetNextAlias() As Char
 Local _nTot   := 0 As Numeric
 Local _nTot1  := 0 As Numeric
 Local _nTot2  := 0 As Numeric
 Local _nTot3  := 0 As Numeric

 cTimeINI:=TIME()

 IF MV_PAR04 $ "1,4" //--NOTAS DE ENTRADA (FORNECEDOR)
    _oProc:cCaption := ("Filtrando dados de ENTRADAS..." )
    ProcessMessages()
 
    //-- ENTRADAS
    _cQuery1+= " SELECT  " +CRLF
    _cQuery1+= "  SA2.A2_CGC     CNPJ_ORI , " +CRLF
    _cQuery1+= "  NVL((SELECT MAX (SA1FOR.A1_I_CCHEP)  " +CRLF
    _cQuery1+= "         FROM "+RetSqlName("SA1")+" SA1FOR  " +CRLF
    _cQuery1+= "        WHERE     SA1FOR.A1_FILIAL = ' '  " +CRLF
    _cQuery1+= "              AND SA1FOR.A1_CGC = SA2.A2_CGC  " +CRLF
    _cQuery1+= "              AND SA1FOR.A1_I_CCHEP <> ' '  " +CRLF
    _cQuery1+= "              AND SA1FOR.D_E_L_E_T_ = ' '),  " +CRLF
    _cQuery1+= "      ' ')        G_ORIGEM,  " +CRLF
    _cQuery1+= "  A2_NOME         NOME_ORI,  " +CRLF
    _cQuery1+= "  SM0.M0_CGC      CNPJ_DEST,  " +CRLF
    _cQuery1+= "  NVL((SELECT MAX (SA1SM0.A1_I_CCHEP)  " +CRLF
    _cQuery1+= "         FROM "+RetSqlName("SA1")+" SA1SM0  " +CRLF
    _cQuery1+= "        WHERE     SA1SM0.A1_FILIAL = ' '  " +CRLF
    _cQuery1+= "              AND SA1SM0.A1_CGC = SM0.M0_CGC  " +CRLF
    _cQuery1+= "              AND SA1SM0.A1_I_CCHEP <> ' '  " +CRLF
    _cQuery1+= "              AND SA1SM0.D_E_L_E_T_ = ' '),  " +CRLF
    _cQuery1+= "      ' ')        G_DESTINO, " +CRLF
    _cQuery1+= "  SM0.M0_NOMECOM  NOME_DEST, " +CRLF
    _cQuery1+= "  SD1.D1_DTDIGIT  EMISSAO  , " +CRLF
    _cQuery1+= "  SD1.D1_DOC      DOC      , " +CRLF
    _cQuery1+= "  SD1.D1_SERIE    SERIE    , " +CRLF
    _cQuery1+= "  SD1.D1_QUANT    QTIDADE  , " +CRLF
    _cQuery1+= "  'ENTRADA'       MOVIMENTO  " +CRLF
    _cQuery1+= "FROM "+RetSqlName("SD1")+" SD1 " +CRLF
    _cQuery1+= "     INNER JOIN "+RetSqlName("SA2")+" SA2 ON SA2.A2_FILIAL = ' ' AND SA2.A2_COD = SD1.D1_FORNECE AND SA2.A2_LOJA = SD1.D1_LOJA " +CRLF
    _cQuery1+= "     INNER JOIN "+RetSqlName("SM0")+" SM0 ON M0_CODFIL = D1_FILIAL " +CRLF
    _cQuery1+= "  WHERE SD1.D_E_L_E_T_ = ' '  " +CRLF
    _cQuery1+= "    AND SA2.D_E_L_E_T_ = ' '  " +CRLF
    _cQuery1+= "    AND SM0.D_E_L_E_T_ = ' '  " +CRLF
    _cQuery1+= "    AND SD1.D1_TIPO NOT IN ('B','D','C')   " +CRLF
    _cQuery1+= "    AND SD1.D1_COD = '08130000002' " +CRLF
    _cQuery1+= "    AND SD1.D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' " +CRLF
    _cQuery1+= "    AND SD1.D1_TES <> ' ' " +CRLF
    IF !EMPTY(MV_PAR01)
       _cQuery1+= "  AND SD1.D1_FILIAL IN " + FormatIn(ALLTRIM(MV_PAR01),";")+CRLF
    ENDIF
    _cQuery1+= "  ORDER BY MOVIMENTO, SD1.D1_EMISSAO , SD1.D1_DOC"
 
    //_cFileNome:="c:\smartclient\ROMS080_Q1_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+".TXT"
    //MemoWrite(LOWER(_cFileNome),_cQuery1)
 
    MPSysOpenQuery( _cQuery1 , _cAlias1)
    _nTot1:=0
    DbSelectArea(_cAlias1)
    COUNT TO _nTot1
    _nTot+=_nTot1

 ENDIF

 IF MV_PAR04 $ "2,4" //--NOTAS DE SAIDA
   _oProc:cCaption := ("Filtrando dados de SAIDAS..." )
   ProcessMessages()

   _cQuery2+= "  SELECT " +CRLF
   _cQuery2+= "         M0_CGC      CNPJ_ORI,   " +CRLF
   _cQuery2+= "         NVL ((SELECT MAX (SA1SM0.A1_I_CCHEP)   " +CRLF
   _cQuery2+= "                FROM "+RetSqlName("SA1")+" SA1SM0   " +CRLF
   _cQuery2+= "               WHERE     SA1SM0.A1_FILIAL = ' '   " +CRLF
   _cQuery2+= "                     AND SA1SM0.A1_CGC = M0_CGC   " +CRLF
   _cQuery2+= "                     AND SA1SM0.A1_I_CCHEP <> ' '   " +CRLF
   _cQuery2+= "                     AND SA1SM0.D_E_L_E_T_ = ' '),   " +CRLF
   _cQuery2+= "          ' ')    G_ORIGEM , " +CRLF
   _cQuery2+= "  SM0.M0_NOMECOM  NOME_ORI , " +CRLF
   _cQuery2+= "  SA1.A1_CGC      CNPJ_DEST, " +CRLF
   _cQuery2+= "  SA1.A1_I_CCHEP  G_DESTINO, " +CRLF
   _cQuery2+= "  SA1.A1_NOME     NOME_DEST, " +CRLF
   _cQuery2+= "  D2_EMISSAO      EMISSAO  , " +CRLF
   _cQuery2+= "  D2_DOC          DOC      , " +CRLF
   _cQuery2+= "  D2_SERIE        SERIE    , " +CRLF
   _cQuery2+= "  D2_QUANT        QTIDADE  , " +CRLF
   _cQuery2+= "  'SAIDA'         MOVIMENTO  " +CRLF
   _cQuery2+= "    FROM "+RetSqlName("SD2")+" SD2 " +CRLF
   _cQuery2+= "         INNER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_COD = SD2.D2_CLIENTE AND SA1.A1_LOJA = SD2.D2_LOJA   " +CRLF
   _cQuery2+= "         INNER JOIN "+RetSqlName("SM0")+" SM0 ON M0_CODFIL = D2_FILIAL   " +CRLF
   _cQuery2+= "  WHERE SD2.D_E_L_E_T_ = ' ' " +CRLF
   _cQuery2+= "    AND SA1.D_E_L_E_T_ = ' ' " +CRLF
   _cQuery2+= "    AND SM0.D_E_L_E_T_ = ' ' " +CRLF
   _cQuery2+= "    AND SD2.D2_COD = '08130000002' " +CRLF
   _cQuery2+= "    AND SD2.D2_EMISSAO BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' " +CRLF
   _cQuery2+= "    AND SD2.D2_TIPO NOT IN ('B', 'D')   " +CRLF
   IF !EMPTY(MV_PAR01)
      _cQuery2+= "  AND SD2.D2_FILIAL IN " + FormatIn(ALLTRIM(MV_PAR01),";") +CRLF
   ENDIF

   _cQuery2+= "  UNION ALL " +CRLF

   _cQuery2+= "  SELECT  "+CRLF
   _cQuery2+= "         M0_CGC      CNPJ_ORI,   " +CRLF
   _cQuery2+= "         NVL ((SELECT MAX (SA1SM0.A1_I_CCHEP)   " +CRLF
   _cQuery2+= "                FROM "+RetSqlName("SA1")+" SA1SM0   " +CRLF
   _cQuery2+= "               WHERE     SA1SM0.A1_FILIAL = ' '   " +CRLF
   _cQuery2+= "                     AND SA1SM0.A1_CGC = SM0.M0_CGC   " +CRLF
   _cQuery2+= "                     AND SA1SM0.A1_I_CCHEP <> ' '   " +CRLF
   _cQuery2+= "                     AND SA1SM0.D_E_L_E_T_ = ' '),   " +CRLF
   _cQuery2+= "             ' ')    G_ORIGEM , " +CRLF
   _cQuery2+= "         SM0.M0_NOMECOM NOME_ORI , " +CRLF
   _cQuery2+= "         SA2.A2_CGC     CNPJ_DEST, " +CRLF
   _cQuery2+= "         NVL (   " +CRLF
   _cQuery2+= "             (SELECT MAX (SA1FOR.A1_I_CCHEP)         " +CRLF
   _cQuery2+= "                FROM "+RetSqlName("SA1")+" SA1FOR    " +CRLF
   _cQuery2+= "               WHERE     SA1FOR.A1_FILIAL = ' '      " +CRLF
   _cQuery2+= "                     AND SA1FOR.A1_CGC = SA2.A2_CGC  " +CRLF
   _cQuery2+= "                     AND SA1FOR.A1_I_CCHEP <> ' '    " +CRLF
   _cQuery2+= "                     AND SA1FOR.D_E_L_E_T_ = ' '),   " +CRLF
   _cQuery2+= "             ' ')        G_DESTINO, " +CRLF
   _cQuery2+= "         SA2.A2_NOME     NOME_DEST, " +CRLF
   _cQuery2+= "         D2_EMISSAO      EMISSAO  , " +CRLF
   _cQuery2+= "         SD2.D2_DOC      DOC      , " +CRLF
   _cQuery2+= "         D2_SERIE        SERIE    , " +CRLF
   _cQuery2+= "         SD2.D2_QUANT    QTIDADE  , " +CRLF
   _cQuery2+= "         'SAIDA'         MOVIMENTO  " +CRLF
   _cQuery2+= "    FROM "+RetSqlName("SD2")+" SD2  " +CRLF
   _cQuery2+= "         INNER JOIN "+RetSqlName("SA2")+" SA2 ON SA2.A2_COD = SD2.D2_CLIENTE AND SA2.A2_LOJA = SD2.D2_LOJA   " +CRLF
   _cQuery2+= "         INNER JOIN "+RetSqlName("SM0")+" SM0 ON M0_CODFIL = D2_FILIAL   " +CRLF
   _cQuery2+= "   WHERE     SD2.D_E_L_E_T_ = ' '   " +CRLF
   _cQuery2+= "         AND SA2.D_E_L_E_T_ = ' '   " +CRLF
   _cQuery2+= "         AND SM0.D_E_L_E_T_ = ' '   " +CRLF
   _cQuery2+= "         AND SD2.D2_COD = '08130000002'   " +CRLF
   _cQuery2+= "         AND SD2.D2_EMISSAO BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' " +CRLF
   _cQuery2+= "         AND SD2.D2_TIPO IN ('B', 'D')   " +CRLF
   IF !EMPTY(MV_PAR01)
      _cQuery2+= "  AND SD2.D2_FILIAL IN " + FormatIn(ALLTRIM(MV_PAR01),";") +CRLF
   ENDIF
   _cQuery2+= "  ORDER BY MOVIMENTO, EMISSAO , DOC  "

   //_cFileNome:="c:\smartclient\ROMS080_Q2_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+".TXT"
   //MemoWrite(LOWER(_cFileNome),_cQuery3)

   MPSysOpenQuery( _cQuery2 , _cAlias2)
   _nTot2:=0
   DbSelectArea(_cAlias2)
   COUNT TO _nTot2
   _nTot+=_nTot2

 ENDIF

 IF MV_PAR04 $ "3,4" //NOTAS DE ENTRADA (DEVOLUÇÃO)
   _oProc:cCaption := ("Filtrando dados de DEVOLUCOES..." )
   ProcessMessages()

   _cQuery3+= "SELECT " +CRLF
   _cQuery3+= "  SA1.A1_CGC      CNPJ_ORI,  " +CRLF
   _cQuery3+= "  SA1.A1_I_CCHEP  G_ORIGEM,  " +CRLF
   _cQuery3+= "  SA1.A1_NOME     NOME_ORI,  " +CRLF
   _cQuery3+= "  SM0.M0_CGC      CNPJ_DEST, " +CRLF
   _cQuery3+= "  NVL ( " +CRLF
   _cQuery3+= "   (SELECT MAX (SA1SM0.A1_I_CCHEP) " +CRLF
   _cQuery3+= "      FROM "+RetSqlName("SA1")+" SA1SM0 " +CRLF
   _cQuery3+= "     WHERE     SA1SM0.A1_FILIAL = ' ' " +CRLF
   _cQuery3+= "           AND SA1SM0.A1_CGC = SM0.M0_CGC " +CRLF
   _cQuery3+= "           AND SA1SM0.A1_I_CCHEP <> ' ' " +CRLF
   _cQuery3+= "           AND SA1SM0.D_E_L_E_T_ = ' '), " +CRLF
   _cQuery3+= "   ' ')           G_DESTINO, " +CRLF
   _cQuery3+= "  SM0.M0_NOMECOM  NOME_DEST, " +CRLF
   _cQuery3+= "  D1_DTDIGIT      EMISSAO,   " +CRLF
   _cQuery3+= "  D1_DOC          DOC, " +CRLF
   _cQuery3+= "  D1_SERIE        SERIE, " +CRLF
   _cQuery3+= "  D1_QUANT        QTIDADE, " +CRLF
   _cQuery3+= "  'ENTRADA'     MOVIMENTO " +CRLF
   _cQuery3+= "  FROM "+RetSqlName("SD1")+" SD1   " +CRLF
   _cQuery3+= "       INNER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL = ' ' AND SA1.A1_COD = SD1.D1_FORNECE AND SA1.A1_LOJA = SD1.D1_LOJA  " +CRLF
   _cQuery3+= "       INNER JOIN "+RetSqlName("SM0")+" SM0 ON M0_CODFIL = D1_FILIAL  " +CRLF
   _cQuery3+= "  WHERE SD1.D_E_L_E_T_ = ' ' " +CRLF
   _cQuery3+= "    AND SA1.D_E_L_E_T_ = ' ' " +CRLF
   _cQuery3+= "    AND SM0.D_E_L_E_T_ = ' ' " +CRLF
   _cQuery3+= "    AND SD1.D1_TIPO IN ('B','D') " +CRLF
   _cQuery3+= "    AND SD1.D1_COD = '08130000002'" +CRLF
   _cQuery3+= "    AND SD1.D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' " +CRLF
   _cQuery3+= "    AND SD1.D1_TES <> ' ' " +CRLF
   IF !EMPTY(MV_PAR01)
      _cQuery3+= " AND SD1.D1_FILIAL IN " + FormatIn(ALLTRIM(MV_PAR01),";") +CRLF
   ENDIF
   _cQuery3+= "  ORDER BY MOVIMENTO, SD1.D1_DTDIGIT , SD1.D1_DOC "

   //_cFileNome:="c:\smartclient\ROMS080_Q3_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+".TXT"
   //MemoWrite(LOWER(_cFileNome),_cQuery3)

   MPSysOpenQuery( _cQuery3 , _cAlias3)
   _nTot3:=0
   DbSelectArea(_cAlias3)
   COUNT TO _nTot3
   _nTot+=_nTot3

 ENDIF

 _cTotGeral:=ALLTRIM(STR(_nTot))
 _nTam:=LEN(_cTotGeral)+1
 cTimeFIM:="Hora Incial: "+cTimeINI+" - Hora Final: "+TIME()+" da leitura dos dados"

 IF _nTot = 0
    U_ITMSG("Não tem DADOS para processamento com esses filtros.",cTimeFIM,"Altere os filtros.",3)
    RETURN .F.
 ENDIF

 IF !U_ITMSG("Serão processados "+_cTotGeral+' registros, Confirma ?',cTimeFIM,,3,2,3,,"CONFIRMA","VOLTAR")
    RETURN .F.
 ENDIF

 Private nConta:=0 As Numeric
 Private cTime1Inicial:=TIME() As Character

 IF MV_PAR04 $ "1,4" .AND. _nTot1 > 0
    ROMS80Grv(_cAlias1,_oProc,_cTotGeral+" - ENTRADAS")
 ENDIF
 IF MV_PAR04 $ "3,4" .AND. _nTot3 > 0
    ROMS80Grv(_cAlias3,_oProc,_cTotGeral+" - DEVOLUCOES")
 ENDIF
 IF MV_PAR04 $ "2,4" .AND. _nTot2 > 0
    ROMS80Grv(_cAlias2,_oProc,_cTotGeral+" - SAIDAS")
 ENDIF

 _oProc:cCaption := ("Acertos finais de campos...")
 ProcessMessages()

 _aColXML:=ACLONE(_aDados)//FORMATO PARA GERAR O EXCEL CORRETO EM INGLES COM PONTO

 FOR L := 1 TO LEN(_aDados)//AJUSTE PARA MOSTRA NA TELA DO U_ITListBox CORRETO
     _aDados[L,nPosData]:= DTOC(_aDados[L,nPosData])
     _aDados[L,nPosQtde]:= TRANSFORM(_aDados[L,nPosQtde],"@E 9,999")
 NEXT L

RETURN .T.
/*
===============================================================================================================================
Programa--------: ROMS80Grv
Autor-----------: Alex Wallauer
Data da Criacao-: 25/09/2023
Descrição-------: Gravação dos dados coletado na array _aDados
Parametros------: _cAlias,_oProc,_cTotGeral
Retorno---------: .T.
===============================================================================================================================
*/
Static Function ROMS80Grv(_cAlias As Char,_oProc As Object,_cTotGeral As Char) As Logical
 LOCAL _aDadosLinha := {} As Array
  (_cAlias)->(DbGoTop())

 DO WHILE (_cAlias)->(!EOF()) //**********************************  WHILE  ******************************************************

    nConta++
    _oProc:cCaption := ("Lendo "+STRZERO(nConta,_nTam) +" de "+ _cTotGeral )
    ProcessMessages()

    _aDadosLinha := {}

    AADD(_aDadosLinha ,(_cAlias)->CNPJ_ORI  )               // 01
    AADD(_aDadosLinha ,(_cAlias)->G_ORIGEM  )               // 02
    AADD(_aDadosLinha ,(_cAlias)->NOME_ORI  )               // 03
    AADD(_aDadosLinha ,(_cAlias)->CNPJ_DEST )               // 04
    AADD(_aDadosLinha ,(_cAlias)->G_DESTINO )               // 05
    AADD(_aDadosLinha ,(_cAlias)->NOME_DEST )               // 06
    AADD(_aDadosLinha ,STOD((_cAlias)->EMISSAO))            // 07
    AADD(_aDadosLinha ,(_cAlias)->DOC)                      // 08
    AADD(_aDadosLinha ,'PALETE' )                           // 09
    AADD(_aDadosLinha ,(_cAlias)->QTIDADE  )                // 10
    AADD(_aDadosLinha ,(_cAlias)->MOVIMENTO)                // 11

    AADD(_aDados , _aDadosLinha )

    (_cAlias)->(dbSkip())

 ENDDO

 (_cAlias)->(DbCloseArea())

RETURN .T.
/*
===============================================================================================================================
Programa--------: ROMS80Per
Autor-----------: Alex Wallauer
Data da Criacao-: 25/09/2023
Descrição-------: Parâmetros do relatório
Parametros------: Nenhum
Retorno---------: _aPergunte
===============================================================================================================================
*/
Static Function ROMS80Per() As Array
 Local _aDadosPegunte := {} As Array
 Local _aPergunte := {} As Array
 Local nI As Numeric
 Local _cTexto As Char

 Aadd(_aDadosPegunte,{"05", "Filiais selecionadas","MV_PAR01"})
 Aadd(_aDadosPegunte,{"01", "Data de Emissão de"  ,"MV_PAR02"})
 Aadd(_aDadosPegunte,{"02", "Data de Emissão ate" ,"MV_PAR03"})
 Aadd(_aDadosPegunte,{"03", "Geração"             ,"MV_PAR04"})

 For nI := 1 To Len(_aDadosPegunte)
    _cTexto := ""

    If _aDadosPegunte[nI,3] == "MV_PAR04"
       If AllToChar(MV_PAR04) ==  "1"
          _cTexto := "Saída"
       ElseIf AllToChar(MV_PAR04) == "2"
          _cTexto := "Entrada"
       ElseIf AllToChar(MV_PAR04) == "3"
          _cTexto := "Devolução"
       Else
          _cTexto := "Todos"
       EndIf

    Else
       _cTexto := &(_aDadosPegunte[nI,3])
       If ValType(_cTexto) == "D"
          _cTexto := DTOC(_cTexto)
       EndIf
    EndIf

    AADD(_aPergunte,{"Pergunta " + _aDadosPegunte[nI,1] + ':',_aDadosPegunte[nI,2],_cTexto })

 Next nI

Return _aPergunte
