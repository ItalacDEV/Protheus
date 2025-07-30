/*  
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS -                             
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 15/03/2023 | Chamado 43297. Criação do RELATORIO DE ULTIMA MOVIMENTACAO DE ESTOQUE - OBSOLESCÊNCIA
Lucas Borges  | 23/07/2025 | Chamado 51340. Ajustar função para validação de ambiente de teste
=============================================================================================================================== 
Analista       - Programador     - Inicio     - Envio    - Chamado - Motivo de Alteração
===============================================================================================================================
Lucas          - Alex Wallauer   - 02/05/2025 - 06/05/25 - 50525   - Ajuste para remoção de diretório local C:\SMARTCLIENT\.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'protheus.ch'
#INCLUDE "topconn.ch"
#include "msmgadd.ch"
#include "dbtree.ch"                  
#Include "RWMake.ch"

#DEFINE _ENTER CHR(13)+CHR(10)

/*
===============================================================================================================================
Programa--------: REST024 // U_REST024
Autor-----------: Alex Wallauer
Data da Criacao-: 15/03/2023
===============================================================================================================================
Descrição-------: Chamado 43297. RELATORIO DE ULTIMA MOVIMENTACAO DE ESTOQUE - OBSOLESCÊNCIA
===============================================================================================================================
Parametros------: NENHUM
===============================================================================================================================
Retorno---------: NENHUM
===============================================================================================================================
*/
USER FUNCTION REST024()// U_REST024
LOCAL nI
_cTitulo:="RELATORIO DE ULTIMA MOVIMENTACAO DE ESTOQUE - OBSOLESCÊNCIA"

MV_PAR01:=DATE()
MV_PAR02:=SPACE(50)
MV_PAR03:=SPACE(150)
MV_PAR04:="EM;PA;PP;MP;PI;IN;IM"+SPACE(50)

_aParAux:={}
_aParRet:={}

AADD( _aParAux , { 1 , "Data ate"             , MV_PAR01, "@D","" , ""	   , "" , 050 , .T. })
AADD( _aParAux , { 1 , "Filiais"              , MV_PAR02, "@!","" ,"LSTFIL", "" , 100 , .F. })
AADD( _aParAux , { 1 , "Grupo"                , MV_PAR03, "@!","" ,"SBMLIS", "" , 100 , .F. } ) 
AADD( _aParAux , { 1 , "Tipo"                 , MV_PAR04, "@!","" ,"TIPLIS", "" , 100 , .F. } ) 
      
For nI := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nI][03] )
Next 
   
DO WHILE .T.
  
      IF !ParamBox( _aParAux , "Selecione os filtros" , _aParRet , {|| .T. } , , , , , , , .T. , .T. )
         EXIT
      EndIf

      cTimeInicial:=TIME()
  	   _cTitulo+=" - "+DTOC(DATE())+" - H. I. : "+TIME()

      aCab:={}
      aCabXML:={}
      _aDadosRel:={}
         
  	   FWMSGRUN(,{|oproc|  _aDadosRel := REST24CP(oproc)  }, "Selecionando os Produtos...","Filtrando Produtos..." )
  	   
      IF LEN(_aDadosRel) > 0 
         
         _cTitulo2:=_cTitulo+" H. F. : "+TIME()
         _cMsgTop:="Data ate: "+ALLTRIM(AllToChar(MV_PAR01))+ "; Filiais: " +ALLTRIM(AllToChar(MV_PAR02))+"; Grupo: " +ALLTRIM(AllToChar(MV_PAR03))+"; Tipo: "+ALLTRIM(AllToChar(MV_PAR04))

         _cMsgFil:=_cTitulo2+_ENTER+;
                   "Data ate : "+ALLTRIM(AllToChar(MV_PAR01))+_ENTER+;
                   "Filiais : " +ALLTRIM(AllToChar(MV_PAR02))+_ENTER+;
                   "Grupo : "   +ALLTRIM(AllToChar(MV_PAR03))+_ENTER+;
                   "Tipo : "    +ALLTRIM(AllToChar(MV_PAR04))

         _aSX1:=REST24Per()
         aBotoes:={}
         AADD(aBotoes,{"",{|| U_ITMsgLog(_cMsgFil, "FILTROS APLICADOS" )},"","Filtros Aplicados"})
                          //      ,_aCols     ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab  , bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk,_aSX1 )
         U_ITListBox(_cTitulo2,aCab,_aDadosRel, .T.    , 1    ,_cMsgTop ,          ,       ,         ,     ,        , aBotoes  , aCabXML,         ,          ,           ,         ,       ,         ,_aSX1)
         LOOP      
      ELSE 
         LOOP
      ENDIF

      EXIT
  
  ENDDO


Return .T.

/*
===============================================================================================================================
Programa--------: REST24CP
Autor-----------: Alex Wallauer
Data da Criacao-: 15/03/2023
===============================================================================================================================
Descrição-------: Ler os dados da Select e grava da array
===============================================================================================================================
Parametros------: oProc 
===============================================================================================================================
Retorno---------: _aDadosRel
===============================================================================================================================*/
Static Function REST24CP(oproc)
Local _cQuery     := "" //, _nni , nPos , P , Z2
Local _cAlias2    := GetNextAlias()

aCab:={}
aCabXML:={}

IF oproc <> NIL
   oproc:cCaption := ("Filtrando dados ..." )
   ProcessMessages() 
ENDIF

	// Alinhamento: 1-Left   ,2-Center,3-Right
	// Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
	//         Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
	//         Titulo             ,1           ,1         ,.F.       })
   AADD(aCab   , "Descricao"     )
   AADD(aCabXML,{"Descricao"     ,1           ,1         ,.F.       })
   AADD(aCab   , "Codigo"        )
   AADD(aCabXML,{"Codigo"        ,2           ,1         ,.F.       })
   AADD(aCab   , "Grupo"         )
   AADD(aCabXML,{"Grupo"         ,2           ,1         ,.F.       })
   AADD(aCab    ,"Tipo"          )
   AADD(aCabXML,{"Tipo"          ,2           ,1         ,.F.       }) 
   AADD(aCab    ,"Bloquedo?"     )
   AADD(aCabXML,{"Bloquedo?"     ,2           ,1         ,.F.       }) 
   AADD(aCab    ,"Ultima Saida"  )
   AADD(aCabXML,{"Ultima Saida"  ,2           ,4         ,.F.       }) 
   AADD(aCab    ,"Ultima Entrada")
   AADD(aCabXML,{"Ultima Entrada",2           ,4         ,.F.       }) 
   AADD(aCab    ,"Ultima Interno")
   AADD(aCabXML,{"Ultima Interno",2           ,4         ,.F.       }) 
   AADD(aCab    ,"Ultima Data"   )
   AADD(aCabXML,{"Ultima Data"   ,2           ,4         ,.F.       }) 
   AADD(aCab    ,"Endereço"      )
   AADD(aCabXML,{"Endereço"      ,1           ,1         ,.F.       }) 

_cQuery += "  SELECT P.DESCR DESCR    ,"
_cQuery += "         P.COD   COD      ,"
_cQuery += "         P.GRP   GRUPO    ,"
_cQuery += "         P.TIPO  TIPO     ,"
_cQuery += "         P.BLQ   BLQ      ,"
_cQuery += "         P.ULD2  ULT_SAI  ,"
_cQuery += "         P.ULD1  ULT_ENTR ,"
_cQuery += "         P.ULD3  ULT_INTER,"
_cQuery += "         P.ENDER ENDER     "
_cQuery += "  FROM   "
_cQuery += "  (SELECT B1.B1_DESC   DESCR,   "
_cQuery += "          B1.B1_COD    COD,   "
_cQuery += "          B1.B1_GRUPO  GRP,   "
_cQuery += "          B1.B1_TIPO   TIPO,   "
_cQuery += "          B1.B1_MSBLQL BLQ,   "
_cQuery += "    "
_cQuery += "  (SELECT MAX(D2.D2_EMISSAO) FROM   SD2010 D2   "
_cQuery += "    WHERE D2.D2_COD = B1.B1_COD   "
_cQuery += "      AND D2.D_E_L_E_T_ = ' '  "
_cQuery += IF( !Empty( MV_PAR01 ) , " AND D2.D2_EMISSAO <=  '"+ DTOS( MV_PAR01 )+"' "	, "" ) 
_cQuery += IF( !Empty( MV_PAR02 ) , " AND D2.D2_FILIAL IN "+ FormatIn( Alltrim( MV_PAR02 ) , ';' )	, "" ) 
_cQuery += "      AND D2_CLIENTE <> '000001'  "
_cQuery += "      AND (SELECT F4_ESTOQUE FROM  SF4010 F4   "
_cQuery += "            WHERE F4.D_E_L_E_T_ = ' '   "
//_cQuery += IF( !Empty( MV_PAR02 ) , " AND F4.F4_FILIAL IN "+ FormatIn( Alltrim( MV_PAR02 ) , ';' )	, "" ) 
_cQuery += "              AND F4_ESTOQUE = 'S'   "
_cQuery += "              AND F4.F4_CODIGO = D2.D2_TES    "
_cQuery += "              AND F4.F4_FILIAL = D2.D2_FILIAL "
_cQuery += "              AND ROWNUM = 1) = 'S' ) ULD2,   "
_cQuery += "    "
_cQuery += "  (SELECT MAX(D1.D1_DTDIGIT) FROM   SD1010 D1   "
_cQuery += "    WHERE D1.D1_COD = B1.B1_COD   "
_cQuery += "      AND D1.D_E_L_E_T_ = ' ' "
_cQuery += IF( !Empty( MV_PAR01 ) , " AND D1.D1_DTDIGIT <=  '"+ DTOS( MV_PAR01 )+"' "	, "" ) 
_cQuery += IF( !Empty( MV_PAR02 ) , " AND D1.D1_FILIAL IN "+ FormatIn( Alltrim( MV_PAR02 ) , ';' )	, "" ) 
_cQuery += "      AND D1_FORNECE <> 'F00001'  "
_cQuery += "      AND (SELECT F4_ESTOQUE FROM  SF4010 F4   "
_cQuery += "            WHERE F4.D_E_L_E_T_ = ' '   "
//_cQuery += IF( !Empty( MV_PAR02 ) , " AND F4.F4_FILIAL IN "+ FormatIn( Alltrim( MV_PAR02 ) , ';' )	, "" ) 
_cQuery += "              AND F4_ESTOQUE = 'S'   "
_cQuery += "              AND F4.F4_CODIGO = D1.D1_TES   "
_cQuery += "              AND F4.F4_FILIAL = D1.D1_FILIAL "
_cQuery += "              AND ROWNUM = 1) = 'S' ) ULD1,   "
_cQuery += "      "
_cQuery += "  (SELECT MAX(D3.D3_EMISSAO) FROM   SD3010 D3  "
_cQuery += "    WHERE D3.D3_COD = B1.B1_COD   "
_cQuery += "      AND D3.D_E_L_E_T_ = ' '      "
_cQuery += IF( !Empty( MV_PAR01 ) , " AND D3.D3_EMISSAO <=  '"+ DTOS( MV_PAR01 )+"' "	, "" ) 
_cQuery += IF( !Empty( MV_PAR02 ) , " AND D3.D3_FILIAL IN "+ FormatIn( Alltrim( MV_PAR02 ) , ';' )	, "" ) 
_cQuery += "      AND D3_CF NOT IN ('RE4','DE4')  "
_cQuery += "      AND NOT (D3_TM IN ('497','498','997','998'))   "
_cQuery += "      AND NOT ( SUBSTR(D3_DOC,1,6) = 'INVENT')   "
_cQuery += "      AND D3_ESTORNO <> 'S' ) ULD3,   "
_cQuery += "    "
_cQuery += "  (SELECT BZ_I_LOCAL FROM   SBZ010 BZ   "
_cQuery += "    WHERE BZ.BZ_COD = B1.B1_COD   "
_cQuery += IF( !Empty( MV_PAR02 ) , " AND BZ.BZ_FILIAL IN "+ FormatIn( Alltrim( MV_PAR02 ) , ';' )	, "" ) 
_cQuery += "      AND BZ.D_E_L_E_T_ = ' '   "
_cQuery += "      AND ROWNUM = 1 ) ENDER   "
_cQuery += "    "
_cQuery += "  FROM   SB1010 B1   "
_cQuery += "  WHERE B1.D_E_L_E_T_ = ' '      "
_cQuery += "    AND B1_FILIAL = '  '  "
//_cQuery += "    AND B1.B1_TIPO IN ('EM','PA','PP','MP','PI','IN','IM')  "
_cQuery += IF( !Empty( MV_PAR03 ) , " AND B1.B1_GRUPO IN "+ FormatIn( Alltrim( MV_PAR03 ) , ';' )	, "" ) 
_cQuery += IF( !Empty( MV_PAR04 ) , " AND B1.B1_TIPO  IN "+ FormatIn( Alltrim( MV_PAR04 ) , ';' )	, "" ) 
_cQuery += "    ORDER BY B1.B1_DESC ) P  "
_cQuery += "    "
_cQuery += "  WHERE P.ULD1||P.ULD2||P.ULD3 IS NOT NULL  "


cTimeINI:=TIME()
DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias2 , .T. , .F. )

_nTot:=nConta:=0
COUNT TO _nTot
_cTotGeral:=ALLTRIM(STR(_nTot))

cTimeFIM:="Hora Incial: "+cTimeINI+" - Hora Final: "+TIME()+" da leitura dos dados"
(_cAlias2)->(DbGoTop())

IF _nTot = 0
   U_ITMSG("Não tem registros para processamento com esses filtros.",cTimeFIM,"Altere os filtros.",3) 
   RETURN {}
ENDIF
   
IF !U_ITMSG("Serão processados "+_cTotGeral+' registros, Confirma ?',cTimeFIM,,3,2,3,,"CONFIRMA","VOLTAR")
   RETURN {}
ENDIF
   
_aDadosRel:={}
DO WHILE (_cAlias2)->(!EOF()) //**********************************  WHILE  ******************************************************
            
         IF oproc <> NIL
            nConta++
            oproc:cCaption := ("Lendo "+STRZERO(nConta,5) +" de "+ _cTotGeral )
            ProcessMessages()
         ENDIF
         
         _dUltData:=STOD((_cAlias2)->ULT_SAI)
         _cUltData:=DTOC(_dUltData)+" (S)"
         
         IF _dUltData < STOD((_cAlias2)->ULT_ENTR)
            _dUltData:= STOD((_cAlias2)->ULT_ENTR)
            _cUltData:= DTOC(_dUltData)+" (E)"
         ENDIF
         IF _dUltData < STOD((_cAlias2)->ULT_INTER)
            _dUltData:= STOD((_cAlias2)->ULT_INTER)
            _cUltData:= DTOC(_dUltData)+" (I)"
         ENDIF
         
         _aProd := {}
         AADD(_aProd ,ALLTRIM((_cAlias2)->DESCR))
         AADD(_aProd ,(_cAlias2)->COD)
         AADD(_aProd ,(_cAlias2)->GRUPO)
         AADD(_aProd ,(_cAlias2)->TIPO)
         AADD(_aProd ,IF((_cAlias2)->BLQ="1","SIM","NAO") )
         AADD(_aProd ,STOD((_cAlias2)->ULT_SAI))
         AADD(_aProd ,STOD((_cAlias2)->ULT_ENTR))
         AADD(_aProd ,STOD((_cAlias2)->ULT_INTER))
         AADD(_aProd ,_cUltData)
         AADD(_aProd ,(_cAlias2)->ENDER)

         AADD(_aDadosRel , _aProd  )
               
         (_cAlias2)->(dbSkip())
      
ENDDO

(_cAlias2)->(DbCloseArea())

RETURN _aDadosRel

/*
===============================================================================================================================
Programa--------: REST24Per
Autor-----------: Alex Wallauer
Data da Criacao-: 15/03/2023
===============================================================================================================================
Descrição-------: Parâmetros do relatório
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _aPergunte
===============================================================================================================================
*/               
Static Function REST24Per()
Local _aDadosPegunte := {}
Local _aPergunte := {}
Local _nI
Local _cTexto

Aadd(_aDadosPegunte,{"01", "Data ate : ", "MV_PAR01"})       
Aadd(_aDadosPegunte,{"02", "Filiais : " , "MV_PAR02"})           
Aadd(_aDadosPegunte,{"03", "Grupo : "   , "MV_PAR03"})
Aadd(_aDadosPegunte,{"04", "Tipo : "    , "MV_PAR04"})           

For _nI := 1 To Len(_aDadosPegunte)          

    _cTexto := &(_aDadosPegunte[_nI,3])
    If ValType(_cTexto) == "D"
       _cTexto := DTOC(_cTexto)
    EndIf   

    AADD(_aPergunte,{"Pergunta " + _aDadosPegunte[_nI,1] + ':',_aDadosPegunte[_nI,2],_cTexto })

Next


Return _aPergunte

/*

  SELECT P.DESCR DESCR    ,         P.COD   COD      ,         P.GRP   GRUPO    ,         P.TIPO  TIPO     ,         P.BLQ   BLQ      ,         
  P.ULD2  ULT_SAI  ,         P.ULD1  ULT_ENTR ,         P.ULD3  ULT_INTER,         P.ENDER ENDER       FROM     
  (SELECT B1.B1_DESC   DESCR,             B1.B1_COD    COD,             B1.B1_GRUPO  GRP,             B1.B1_TIPO   TIPO,             
  B1.B1_MSBLQL BLQ,         (SELECT MAX(D2.D2_EMISSAO) FROM  SIGA.SD2010 D2       
  WHERE D2.D2_COD = B1.B1_COD         AND D2.D_E_L_E_T_ = ' '   AND D2.D2_EMISSAO <=  '20230316'       AND D2_CLIENTE <> '000001'        AND 
  (SELECT F4_ESTOQUE FROM SIGA.SF4010 F4               WHERE F4.D_E_L_E_T_ = ' '                 AND F4_ESTOQUE = 'S'                 
  AND F4.F4_CODIGO = D2.D2_TES                  AND F4.F4_FILIAL = D2.D2_FILIAL               AND ROWNUM = 1) = 'S' ) ULD2,        
   (SELECT MAX(D1.D1_DTDIGIT) FROM  SIGA.SD1010 D1       WHERE D1.D1_COD = B1.B1_COD         AND D1.D_E_L_E_T_ = ' '  
   AND D1.D1_DTDIGIT <=  '20230316'       AND D1_FORNECE <> 'F00001'        AND (SELECT F4_ESTOQUE FROM SIGA.SF4010 F4              
    WHERE F4.D_E_L_E_T_ = ' '                 AND F4_ESTOQUE = 'S'                 AND F4.F4_CODIGO = D1.D1_TES                
     AND F4.F4_FILIAL = D1.D1_FILIAL               AND ROWNUM = 1) = 'S' ) ULD1,           (SELECT MAX(D3.D3_EMISSAO) 
     FROM  SIGA.SD3010 D3      WHERE D3.D3_COD = B1.B1_COD         AND D3.D_E_L_E_T_ = ' '       AND D3.D3_EMISSAO <=  '20230316'       
     AND D3_CF NOT IN ('RE4','DE4')        AND NOT (D3_TM IN ('497','498','997','998'))         AND NOT ( SUBSTR(D3_DOC,1,6) = 'INVENT')         
     AND D3_ESTORNO <> 'S' ) ULD3,         (SELECT BZ_I_LOCAL FROM  SIGA.SBZ010 BZ       WHERE BZ.BZ_COD = B1.B1_COD         AND BZ.D_E_L_E_T_ = ' '         
     AND ROWNUM = 1 ) ENDER         FROM  SIGA.SB1010 B1     WHERE B1.D_E_L_E_T_ = ' '          AND B1_FILIAL = '  '  
      AND B1.B1_TIPO  IN ('EM','PA','PP','MP','PI','IN','IM')    ORDER BY B1.B1_DESC ) P        WHERE P.ULD1||P.ULD2||P.ULD3 IS NOT NULL  
