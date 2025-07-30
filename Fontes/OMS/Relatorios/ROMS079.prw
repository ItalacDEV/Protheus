/*  
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS -                             
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 22/11/2023 | Chamado 45641. Troca do diretorio de geracao do PDF e delecao apos o envio do e-mail.
Alex Wallauer | 06/02/2024 | Chamado 45595. Andre/Jerry. Novos filtros de Filial e armazens e Ajustes.
=============================================================================================================================== 
Analista       - Programador     - Inicio     - Envio    - Chamado - Motivo de Alteração 
===============================================================================================================================
Lucas          - Alex Wallauer   - 02/05/25 - 06/05/25 - 50525   - Ajuste para remoção de diretório local C:\SMARTCLIENT\.
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
#INCLUDE "RPTDEF.CH"

#DEFINE _ENTER CHR(13)+CHR(10)

/*
===============================================================================================================================
Programa--------: ROMS079 // U_ROMS079
Autor-----------: Alex Wallauer
Data da Criacao-: 18/09/2023
===============================================================================================================================
Descrição-------: Chamado 44779 - Jerry. Relatórios de Ordem de Carga Consolidado. 
===============================================================================================================================
Parametros------: NENHUM
===============================================================================================================================
Retorno---------: NENHUM
===============================================================================================================================
*/
USER FUNCTION ROMS079()// U_ROMS079
LOCAL nI , _nX
LOCAL _aParAux:={}
LOCAL _aParRet:={}
Local aAcesso := FWEmpLoad(.F.)
LOCAL _cTitulo:="Relatorio de Ordens de Carga Consolidadas"

_aParOpc:={"1-Sim","2-Nao","3-Ambas"}
MV_PAR01:=DATE()
MV_PAR02:=DATE()
MV_PAR03:=3
MV_PAR04:=3
MV_PAR05:=SPACE(100)
MV_PAR06:=SPACE(100)

AADD( _aParAux , { 1 , "Data da Carga de"               , MV_PAR01, "@D", "" , ""  , ""  , 060 , .T. })
AADD( _aParAux , { 1 , "Data da Carga ate"              , MV_PAR02, "@D", "" , ""  , ""  , 060 , .T. })
AADD( _aParAux , { 3 , "Cargas Faturadas"               , MV_PAR03, _aParOpc , 060 ,".T.",.T.  ,".T."}) 
AADD( _aParAux , { 3 , "Lista Ordem de Carga já listada", MV_PAR04, _aParOpc , 060 ,".T.",.T.  ,".T."}) 
aAdd( _aParAux , { 1 , "Filiais"                        , MV_PAR05, "@!", "",'SM0001',"" , 100 , .F. })
aAdd( _aParAux , { 1 , "Armazens"                       , MV_PAR06, "@!", "",'NNRARM',"" , 100 , .F. })
      
For nI := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nI][03] )
Next 
   
DO WHILE .T.
  
      IF !ParamBox( _aParAux , "Selecione os filtros" , _aParRet , {|| .T. } , , , , , , , .T. , .T. )
         EXIT
      EndIf

      IF !(MV_PAR02 >= MV_PAR01)
  	      U_ITMSG("Periodo da Data de Carga INVALIDO",'Atenção!',"Tente novamente com outro periodo",1)
  	      LOOP
   	  ENDIF
	  xVarAux := ALLTRIM(MV_PAR05)
	  _cFilsAcesso := ""
	  For _nX := 1 To LEN(aAcesso)
	  	_cFilsAcesso+=aAcesso[_nX][03]+", "
	  Next
	  If EMPTY(xVarAux)
         U_ITMSG("Com a filial em branco, somente as filiais que o usuario tem acesso serao selecionadas: "+_cFilsAcesso+" (MV_PAR05)",'Atenção!',,1)
	  	 MV_PAR05:=STRTRAN( _cFilsAcesso, ", ", ";")
	  Else
	  	 aDadAux := U_ITLinDel( xVarAux , ";" )
	  	 SM0->(dbSetOrder(1))
	  	 For nI := 1 To LEN(aDadAux)
	  		If !SM0->(dbSeek(cEmpAnt + aDadAux[nI]))
               U_ITMSG("Filial "+aDadAux[nI]+" informada não existe. (MV_PAR05)",'Atenção!',"Selecione no minimo uma Filial dessa lista: "+_cFilsAcesso,1)
	  		   LOOP
	  		EndIf	  		
	  		If !aDadAux[nI] $ _cFilsAcesso
               U_ITMSG("Filial "+aDadAux[nI]+" informada o usuário não tem acesso.",'Atenção!',"Selecione no minimo uma Filial dessa lista: "+_cFilsAcesso,1)
	  		   LOOP
	  		EndIf
	  	 Next
	  EndIf
      IF VALTYPE(MV_PAR03) = "N"
         MV_PAR03:=STR(MV_PAR03,1)
      ENDIF
      IF VALTYPE(MV_PAR04) = "N"
         MV_PAR04:=STR(MV_PAR04,1)
      ENDIF
      
      cTimeInicial:=TIME()
      _cTitulo :="Relatorio de Ordens de Carga Consolidadas - "+DTOC(DATE())
      _cTitProd:="Relatorio de Produtos Consolidados - "+DTOC(DATE())

      aCab        :={}
      _aCabXML    :={}
      _aCabImp    :={}
      _aColXML    :={}
      _aDadosCarga:={}
      _aCargas    :={}

      _aCabItem   :={}
      _aCabItemImp:={}
      _aCabItemXML:={}
      _aColItemXML:={}
      _aDadosItem :={}

      nPosQt1m:=0
      nPosQt2m:=0
      nPosPBru:=0
	  nPosQPal:=0
      nPosPtos:=0
      nPosFil :=0
      nPosCar :=0
  	   FWMSGRUN(,{|oproc|  ROMS79CP(oproc)  }, "Selecionando Cargas - Hr. Ini. : "+cTimeInicial,"Filtrando Cargas..." )
  	   
      _cTitulo2:=_cTitulo+" H. F. : "+TIME()
      _cMsgTop:="Data da Carga: "  +ALLTRIM(AllToChar(MV_PAR01))+" ate "+ALLTRIM(AllToChar(MV_PAR02))+"; Cargas Faturadas: " +_aParOpc[VAL(MV_PAR03)]+"; Lista Ordem de Carga já listada: "+_aParOpc[VAL(MV_PAR04)]+" - Hr. Ini. : "+cTimeInicial+" / H. F. : "+TIME()

      DO WHILE LEN(_aDadosCarga) > 0 
         
         _cMsgFil:=_cTitulo2+_ENTER+;
                   "Data da Carga: "                  +ALLTRIM(AllToChar(MV_PAR01))+" ate "+ALLTRIM(AllToChar(MV_PAR02))+_ENTER+;
                   "Cargas Faturadas: "               +_aParOpc[VAL(MV_PAR03)]+_ENTER+;
                   "Lista Ordem de Carga já listada: "+_aParOpc[VAL(MV_PAR04)]

         _aSX1:=ROMS79Per()
         aBotoes:={}
         AADD(aBotoes,{"",{|| FWMSGRUN(,{|oProc|  RCOM079M(oProc)  },"Preprando Tela...","Para enviar e-mail com PDF...")  },"","Enviar e-mail com PDF"})
         AADD(aBotoes,{"",{|| U_ITListBox(_cTitProd,_aCabItem,_aDadosItem,.T.,1,_cMsgTop,,,,,,,_aCabItemXML,,_aColItemXML) },"","Produtos Consolidados"})
         AADD(aBotoes,{"",{|| U_ITMsgLog(_cMsgFil, "FILTROS APLICADOS" )                                                   },"","Filtros Aplicados"    })
 
                          //      ,_aCols       ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab   , bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk,_aSX1 )
         U_ITListBox(_cTitulo2,aCab,_aDadosCarga, .T.    , 2    ,_cMsgTop ,          ,       ,         ,     ,        , aBotoes  , _aCabXML,         , _aColXML ,           ,         ,       ,         ,_aSX1)
	
	     IF !U_ITMSG("Confirma Sair ?",'Atenção!',_cTitulo2,3,2,2)
		    LOOP
		 ENDIF
         EXIT
    ENDDO

ENDDO

Return .T.

/*
===============================================================================================================================
Programa--------: ROMS79CP
Autor-----------: Alex Wallauer
Data da Criacao-: 18/09/2023
===============================================================================================================================
Descrição-------: Ler os dados da Select e grava da array
===============================================================================================================================
Parametros------: oProc 
===============================================================================================================================
Retorno---------: _aDadosCarga
===============================================================================================================================*/
Static Function ROMS79CP(oproc)
Local _cQuery    := "" , L
Local _cAlias    := GetNextAlias()
Local _cPicPeso  := PesqPict("DAK","DAK_PESO")
Local _cPicValor := PesqPict("DAK","DAK_VALOR")

aCab    :={}
_aCabXML:={}
_aCabImp:={}

IF oproc <> NIL
   oproc:cCaption := ("Filtrando dados ..." )
   ProcessMessages() 
ENDIF

// Alinhamento: 1-Left   ,2-Center,3-Right
// Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
//             Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
//   (_aCabXML,{Titulo             ,1           ,1         ,.F.       })
AADD(aCab   , "") 
AADD(_aCabXML,{""                  ,2           ,1         ,.F.})// 01

AADD(aCab   , "")
AADD(_aCabXML,{"Enviado"           ,2           ,1         ,.F.})// 02

AADD(aCab   , "Filial")            ; nPosFil:=LEN(aCab)
AADD(_aCabXML,{aCab[LEN(aCab)]     ,2           ,1         ,.F.})// 03
AADD(_aCabImp,"Fil")

AADD(aCab   , "Carga")             ; nPosCar:=LEN(aCab)
AADD(_aCabXML,{aCab[LEN(aCab)]     ,2           ,1         ,.F.})// 04
AADD(_aCabImp,aCab[LEN(aCab)])

AADD(aCab   , "Peso")              ; nPosPeso:=LEN(aCab)
AADD(_aCabXML,{aCab[LEN(aCab)]     ,3           ,2         ,.F.,_cPicPeso})// 05
AADD(_aCabImp,aCab[LEN(aCab)])

AADD(aCab   , "Veículo")
AADD(_aCabXML,{aCab[LEN(aCab)]     ,1           ,1         ,.F.})// 06
AADD(_aCabImp,aCab[LEN(aCab)])

AADD(aCab   , "Desc. Veículo")
AADD(_aCabXML,{aCab[LEN(aCab)]     ,1           ,1         ,.F.})// 07
AADD(_aCabImp,aCab[LEN(aCab)])

AADD(aCab   , "Cod.Motorista")
AADD(_aCabXML,{aCab[LEN(aCab)]     ,1           ,1         ,.F.})// 08
AADD(_aCabImp,aCab[LEN(aCab)])

AADD(aCab   , "Nome Motorista")
AADD(_aCabXML,{aCab[LEN(aCab)]     ,1           ,1         ,.F.})// 09
AADD(_aCabImp,"Motorista"    )

AADD(aCab   , "Ptos de Entrega")   ; nPosPEnt:=LEN(aCab)
AADD(_aCabXML,{aCab[LEN(aCab)]     ,3           ,2         ,.F.,"@E 9,999"})// 10
AADD(_aCabImp,"Ptos.Ent"     )

AADD(aCab   , "Valor Carga")       ; nPosVlor:=LEN(aCab)
AADD(_aCabXML,{aCab[LEN(aCab)]     ,3           ,3         ,.F.,_cPicValor})// 11
AADD(_aCabImp,aCab[LEN(aCab)])

AADD(aCab   , "Pre-Carga?")
AADD(_aCabXML,{aCab[LEN(aCab)]      ,2           ,1         ,.F.})// 12
AADD(_aCabImp,"Pre Carga"     )

AADD(aCab   , "Data")              ;nPosData:=LEN(aCab) 
AADD(_aCabXML,{aCab[LEN(aCab)]     ,2           ,4         ,.F.})// 13
AADD(_aCabImp,aCab[LEN(aCab)])

AADD(aCab   , "Hora")
AADD(_aCabXML,{aCab[LEN(aCab)]     ,2           ,1         ,.F.})// 14
AADD(_aCabImp,aCab[LEN(aCab)])

AADD(aCab   , "Qtd Envio")         ; nPosQEnv:=LEN(aCab)
AADD(_aCabXML,{aCab[LEN(aCab)]     ,3           ,2         ,.F.,"@E 9,999"})//15
AADD(_aCabImp,"Envio"        )

_aCabItem   :={}
_aCabItemXML:={}
_aCabItemImp:={}

AADD(_aCabItem   , "Cod. Produto - Amz") 
AADD(_aCabItemXML,{_aCabItem[LEN(_aCabItem)]     ,2           ,1         ,.F.})                          // 01
AADD(_aCabItemImp,"Produto - Amz")

AADD(_aCabItem   , "Descricao do Produto")
AADD(_aCabItemXML,{_aCabItem[LEN(_aCabItem)]     ,1           ,1         ,.F.})                          // 02
AADD(_aCabItemImp,_aCabItem[LEN(_aCabItem)])

AADD(_aCabItem   , "Qt Liberada 1a UM")          ; nPosQt1m:=LEN(_aCabItem) 
AADD(_aCabItemXML,{_aCabItem[LEN(_aCabItem)]     ,3           ,2         ,.F.,"@E 999,999,999,999.999" })// 03
AADD(_aCabItemImp,"Qt.Lib.1UM"             )

AADD(_aCabItem   , "Unidade")       
AADD(_aCabItemXML,{_aCabItem[LEN(_aCabItem)]     ,2           ,1         ,.F.})                          // 04
AADD(_aCabItemImp,"1a UM"                    )

AADD(_aCabItem   , "Qt Liberada 2a UM")          ; nPosQt2m:=LEN(_aCabItem) 
AADD(_aCabItemXML,{_aCabItem[LEN(_aCabItem)]     ,3           ,2         ,.F.,"@E 999,999,999,999.999" })// 05
AADD(_aCabItemImp,"Qt.Lib.2UM"             )

AADD(_aCabItem   , "Seg Um")
AADD(_aCabItemXML,{_aCabItem[LEN(_aCabItem)]     ,2           ,1         ,.F.})                          // 06
AADD(_aCabItemImp,"2a UM"                    )

AADD(_aCabItem   , "Peso Bruto Total")           ; nPosPBru:=LEN(_aCabItem) 
AADD(_aCabItemXML,{_aCabItem[LEN(_aCabItem)]     ,3           ,2         ,.F.,"@E 999,999,999,999.9999"})// 07
AADD(_aCabItemImp,"Peso Bruto Tot"         )

AADD(_aCabItem   , "Qtd Pallet")                 ; nPosQPal:=LEN(_aCabItem) 
AADD(_aCabItemXML,{_aCabItem[LEN(_aCabItem)]     ,1           ,1         ,.F.})                          // 08
AADD(_aCabItemImp,_aCabItem[LEN(_aCabItem)])

AADD(_aCabItem   , "Valor Total Prod.")          ; nPosPtos:=LEN(_aCabItem)
AADD(_aCabItemXML,{_aCabItem[LEN(_aCabItem)]     ,3           ,3         ,.F.,"@E 999,999,999,999.99"  })// 09
AADD(_aCabItemImp,"Vlr. Total Prod."         )


_cQuery += "  SELECT DAK.R_E_C_N_O_ REC_DAK FROM DAK010 DAK "
_cQuery += "     WHERE DAK.D_E_L_E_T_ = ' ' "

IF !EMPTY(MV_PAR01)
   _cQuery += "  AND DAK_DATA >= '" + DTOS(MV_PAR01)+"' "
ENDIF
IF !EMPTY(MV_PAR02)
   _cQuery += "  AND DAK_DATA <= '" + DTOS(MV_PAR02)+"' "
ENDIF
IF LEFT(MV_PAR03,1) $ "1,2"
   _cQuery += "  AND DAK_FEZNF = '" + LEFT(MV_PAR03,1)+"' "
ENDIF
IF LEFT(MV_PAR04,1) = "1" //Já Enviado
   _cQuery += "  AND DAK_I_ENV <> 0 "
ELSEIF LEFT(MV_PAR04,1) = "2"//Não Enviado
   _cQuery += "  AND DAK_I_ENV = 0 "
ENDIF
IF !EMPTY(MV_PAR05)
   _cQuery += "  AND DAK_FILIAL IN " + FormatIn(ALLTRIM(MV_PAR05), ";") + " " 
ENDIF
If !Empty( MV_PAR06 )// Filtra Armazens
   _cQuery += "AND EXISTS (SELECT 'Y' FROM " +RETSQLNAME("SC9")+" C9 WHERE C9.D_E_L_E_T_ = ' ' AND C9.C9_FILIAL = DAK.DAK_FILIAL AND C9.C9_CARGA = DAK.DAK_COD "
   _cQuery += "AND C9.C9_LOCAL IN "+ FormatIn( ALLTRIM(MV_PAR06) , ";" ) + " )" 	
EndIf

_cQuery += " ORDER BY DAK_COD "
cTimeINI:=TIME()
 DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )
   
_nTot:=nConta:=0
COUNT TO _nTot
_cTotGeral:=ALLTRIM(STR(_nTot))
cTimeFIM:="Hora Incial: "+cTimeINI+" - Hora Final: "+TIME()+" da leitura dos dados"
(_cAlias)->(DbGoTop())
IF (_cAlias)->(EOF())
   U_ITMSG("Não tem Acordos para processamento com esses filtros.",cTimeFIM,"Altere os filtros.",3) 
   RETURN {}
ENDIF
      
IF !U_ITMSG("Serão processados "+_cTotGeral+' registros, Confirma ?',cTimeFIM,,3,2,3,,"CONFIRMA","VOLTAR")
   RETURN {}
ENDIF

DAK->( DBSetOrder(1) )
DAI->( DBSetOrder(1) )
SC9->( DBSetOrder(1) )
SB1->( DBSetOrder(1) )
SC6->( DbSetOrder(1) )
      
_aDadosCarga:={}
DO WHILE (_cAlias)->(!EOF()) //**********************************  WHILE  ******************************************************
            
   nConta++
   oproc:cCaption := ("Lendo "+STRZERO(nConta,5) +" de "+ _cTotGeral )
   ProcessMessages()

   DAK->(DBGOTO((_cAlias)->REC_DAK))
   _aPedCarga := {}
   
   AADD(_aPedCarga ,.T.)//01 
   
   IF DAK->DAK_I_ENV > 0 //Já Enviado
      AADD(_aPedCarga ,.F.)//02 
   ELSE//Não Enviado
      AADD(_aPedCarga ,.T.)//02 
   ENDIF

   AADD(_aPedCarga ,DAK->DAK_FILIAL )                                                         //03
   AADD(_aPedCarga ,DAK->DAK_COD    )                                                         //04           
   AADD(_aPedCarga ,DAK->DAK_PESO   )                                                         //05           
   AADD(_aPedCarga ,DAK->DAK_CAMINH )                                                         //06           
   AADD(_aPedCarga ,Posicione("DA3",1,xFilial("DA3")+DAK->DAK_CAMINH,"DA3_DESC") )            //07 - DA3 É compartilhada
   AADD(_aPedCarga ,DAK->DAK_MOTORI )                                                         //08           
   AADD(_aPedCarga ,ALLTRIM(POSICIONE("DA4",1,XFILIAL("DA4")+DAK->DAK_MOTORI,"DA4_NOME"))  )  //09 - DA4 É compartilhada
   AADD(_aPedCarga ,DAK->DAK_PTOENT )                                                         //10           
   AADD(_aPedCarga ,DAK->DAK_VALOR  )                                                         //11           
   AADD(_aPedCarga ,IF(DAK->DAK_I_PREC="1","Sim","Não") )                                     //12                               
   AADD(_aPedCarga ,DAK->DAK_DATA   )                                                         //13         
   AADD(_aPedCarga ,DAK->DAK_HORA   )                                                         //14         
   AADD(_aPedCarga ,DAK->DAK_I_ENV  )                                                         //15

   AADD(_aDadosCarga , _aPedCarga )

	//====================================================================================================
	// Compondo os dados do produto
	//====================================================================================================
   If DAI->( DBSeek( DAK->DAK_FILIAL + DAK->DAK_COD ) )
	
	  DO While DAI->( !EOF() ) .And. DAI->( DAI_FILIAL + DAI_COD ) == DAK->DAK_FILIAL + DAK->DAK_COD
		
			If SC6->( DBSeek( DAI->DAI_FILIAL + DAI->DAI_PEDIDO ) )
			
			   DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == DAI->DAI_FILIAL+DAI->DAI_PEDIDO

				  IF !EMPTY(MV_PAR06) .AND. !SC6->C6_LOCAL $ ALLTRIM(MV_PAR06)   
				     SC6->( DbSkip() )
					 LOOP
				  ENDIF
				  SB1->( DBSeek( xFilial("SB1")  + SC6->C6_PRODUTO ) )
				  SC9->( DBSeek( SC6->C6_FILIAL + SC6->C6_NUM + SC6->C6_ITEM ) )

                  _cDescItem:=SB1->B1_DESC

				   If (nPos := Ascan( _aDadosItem , { |x| x[1] == ALLTRIM(SC6->C6_PRODUTOS)+"-"+SC6->C6_LOCAL } ) ) == 0
                      
					  _aProds:={}
                      AADD(_aProds , ALLTRIM(SC6->C6_PRODUTOS)+"-"+SC6->C6_LOCAL)//01
                      AADD(_aProds , _cDescItem                          )//02
                      AADD(_aProds , SC9->C9_QTDLIB                      )//03
                      AADD(_aProds , SB1->B1_UM                          )//04
                      AADD(_aProds , SC9->C9_QTDLIB2                     )//05
                      AADD(_aProds , SB1->B1_SEGUM                       )//06
                      AADD(_aProds , ( SB1->B1_PESBRU * SC9->C9_QTDLIB ) )//07
                      AADD(_aProds , " "                                 )//08
                      AADD(_aProds , ( SC9->C9_QTDLIB * SC9->C9_PRCVEN ) )//09
                      
					  AADD(_aDadosItem , _aProds )
				   Else
					  _aDadosItem[nPos][nPosQt1m] += SC9->C9_QTDLIB                  //03   
					  _aDadosItem[nPos][nPosQt2m] += SC9->C9_QTDLIB2                 //05 
					  _aDadosItem[nPos][nPosPBru] +=(SB1->B1_PESBRU * SC9->C9_QTDLIB)//07
					  _aDadosItem[nPos][nPosPtos] +=(SC9->C9_QTDLIB * SC9->C9_PRCVEN)//09			
				   EndIf
				   SC6->( DbSkip() )

				Enddo
		
			EndIf
			DAI->( DBSkip() )
		EndDo
	EndIf

   (_cAlias)->(dbSkip())
      
ENDDO

oproc:cCaption := ("Acertos finais...")

(_cAlias)->(DbCloseArea())

_aColXML:=ACLONE(_aDadosCarga)//FORMATO PARA GERAR O EXCEL CORRETO EM INGLES COM PONTO
FOR L := 1 TO LEN(_aColXML)    //AJUSTE PARA GERAR O EXCEL CORRETO
    _aColXML[L,1]:=" "//IF(_aColXML[L,1],"X"," ") Retirei pq senão vai ter que ficar repricando sempre o _aColXML
    _aColXML[L,2]:=IF(_aColXML[L,2],"NAO","SIM")
NEXT

FOR L := 1 TO LEN(_aDadosCarga)//AJUSTE PARA MOSTRA NA TELA DO U_ITListBox CORRETO
    _aDadosCarga[L,nPosPeso]:= TRANSFORM(_aDadosCarga[L,nPosPeso],_cPicPeso )// DAK->DAK_PESO 
    _aDadosCarga[L,nPosPEnt]:= TRANSFORM(_aDadosCarga[L,nPosPEnt],"@E 9,999")// DAK->DAK_PTOENT
    _aDadosCarga[L,nPosVlor]:= TRANSFORM(_aDadosCarga[L,nPosVlor],_cPicValor)// DAK->DAK_VALOR
    _aDadosCarga[L,nPosQEnv]:= TRANSFORM(_aDadosCarga[L,nPosQEnv],"@E 9,999")// DAK->DAK_I_ENV
    _aDadosCarga[L,nPosData]:= DTOC(_aDadosCarga[L,nPosData]                )// DAK->DAK_DATA	
NEXT

FOR L := 1 TO LEN(_aDadosItem)//CALCULA A QDE DE Pallets 00 21 00 19 90 1
    IF SB1->( DBSeek( xFilial("SB1") + LEFT(_aDadosItem[L,1],11) ) )
	   _aDadosItem[L,nPosQPal]:= REST79SPal(_aDadosItem[L,nPosQt1m],_aDadosItem[L,nPosQt2m],SB1->B1_SEGUM,SB1->B1_TIPO)
	ENDIF
NEXT

_aColItemXML:=ACLONE(_aDadosItem)//FORMATO PARA GERAR O EXCEL CORRETO EM INGLES COM PONTO

FOR L := 1 TO LEN(_aDadosItem)//AJUSTE PARA MOSTRA NA TELA DO U_ITListBox CORRETO
    _aDadosItem[L,nPosQt1m]:= TRANSFORM(_aDadosItem[L,nPosQt1m],"@E 999,999,999,999.999" )// SC9->C9_QTDLIB   
    _aDadosItem[L,nPosQt2m]:= TRANSFORM(_aDadosItem[L,nPosQt2m],"@E 999,999,999,999.999" )// SC9->C9_QTDLIB2  
    _aDadosItem[L,nPosPBru]:= TRANSFORM(_aDadosItem[L,nPosPBru],"@E 999,999,999,999.9999")// SB1->B1_PESBRU * SC9->C9_QTDLIB
    _aDadosItem[L,nPosPtos]:= TRANSFORM(_aDadosItem[L,nPosPtos],"@E 999,999,999,999.99"  )// SC9->C9_QTDLIB * SC9->C9_PRCVEN 
NEXT

ASORT(_aDadosItem,,,{|x,y|x[2]<y[2]})

RETURN 
/*
===============================================================================================================================
Programa--------: ROMS79Per
Autor-----------: Alex Wallauer
Data da Criacao-: 18/09/2023
===============================================================================================================================
Descrição-------: Parâmetros do relatório
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _aPergunte
===============================================================================================================================
*/               
Static Function ROMS79Per()
Local _aDadosPegunte := {}
Local _aPergunte := {}
Local nI
Local _cTexto

Aadd(_aDadosPegunte,{"01", "Data da Carga de"               , "MV_PAR01"})
Aadd(_aDadosPegunte,{"02", "Data da Carga ate"              , "MV_PAR02"})   
Aadd(_aDadosPegunte,{"03", "Cargas Faturadas"               , "MV_PAR03"})
Aadd(_aDadosPegunte,{"04", "Lista Ordem de Carga já listada", "MV_PAR04"})   
Aadd(_aDadosPegunte,{"05", "Filiais selecionadas"           , "MV_PAR05"})   
Aadd(_aDadosPegunte,{"06", "Armazens selecionados"          , "MV_PAR06"})   

For nI := 1 To Len(_aDadosPegunte)          
    _cTexto := ""
	 
    If _aDadosPegunte[nI,3] == "MV_PAR03" .OR. _aDadosPegunte[nI,3] == "MV_PAR04"
	   If AllToChar(MV_PAR14) ==  "1"
	      _cTexto := "Sim"
	   ElseIf AllToChar(MV_PAR14) == "2"
	      _cTexto := "Não"
	   Else
	      _cTexto := "Ambas"
	   EndIf

    Else
       _cTexto := &(_aDadosPegunte[nI,3])
       If ValType(_cTexto) == "D"
          _cTexto := DTOC(_cTexto)
       EndIf   
    EndIf	

    AADD(_aPergunte,{"Pergunta " + _aDadosPegunte[nI,1] + ':',_aDadosPegunte[nI,2],_cTexto })

Next
Return _aPergunte

/*
===============================================================================================================================
Programa--------: RCOM079M
Autor-----------: Alex Wallauer
Data da Criacao-: 18/09/2023
===============================================================================================================================
Descrição-------: Função responsável por exibir a janela para a digitação dos endereços de email e Observação
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function RCOM079M(oProc)
Local oAnexo
Local oAssunto
Local oButCan
Local oButEnv
Local oCc
Local oGetAnx
Local oGetAssun
Local oGetCc
Local oGetPara
Local oMens
Local oPara

Local _aConfig	:= U_ITCFGEML('')
Local _cEmlLog	:= ""
Local _cObs		:= Space(200)
Local nOpcA		:= 2 , R

Local cGetAssun := "Lista de Ordens de Carga Consolidadas da Filial "+cFilAnt+" - "+ALLTRIM( Posicione('SM0',1,"01"+cFilAnt,'M0_FILIAL') )+" - "+dtoc(DATE())+" - "+TIME()+Space(300)
Local cFileName	:= "ROMS079_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+".PDF"
Local cGetPara	:= UsrRetMail(__cUserId)+Space(300)
Local cGetCc	:= Space(300)

PRIVATE cPathSrv:= GETMV("MV_RELT",,"\SPOOL\")

ROMS079B(cPathSrv,cFileName) // GERA O PDF ****************************************

cGetAnx := cPathSrv+cFileName///spool
_cPathLocal:=GetTempPath()

If File(cGetAnx) 
	//Copia arquivo da spool para estação local
	IF !CpyS2T(cGetAnx,_cPathLocal)
		U_ITMSG("Não foi possivel copiar o arquivo "+cGetAnx+" para "+_cPathLocal,'Atenção!',"Feche o arquivo "+cGetAnx+", caso aberto,e tente novamente",1)
		_cPathLocal:=""
	ELSE
        _cOrigem2:=StrTran( cGetAnx, cPathSrv, _cPathLocal ) 
	ENDIF
ELSE
    U_ITMSG("Não foi possivel localizar o arquivo "+cGetAnx,'Atenção!',"Tente novamente.",1)
EndIf


Private oDlgMail

DEFINE MSDIALOG oDlgMail TITLE "E-Mail" FROM 000, 000  TO 415, 584   PIXEL

	@ 005, 006 SAY oPara PROMPT "Para:" SIZE 015, 007 OF oDlgMail   PIXEL
	@ 005, 030 MSGET oGetPara VAR cGetPara SIZE 256, 010 OF oDlgMail PICTURE "@!"    PIXEL

	@ 021, 006 SAY oCc PROMPT "Cc:" SIZE 015, 007 OF oDlgMail   PIXEL
	@ 021, 030 MSGET oGetCc VAR cGetCc SIZE 256, 010 OF oDlgMail PICTURE "@!"    PIXEL

	@ 037, 006 SAY oAssunto PROMPT "Assunto:" SIZE 022, 007 OF oDlgMail   PIXEL
	@ 037, 030 MSGET oGetAssun VAR cGetAssun SIZE 256, 010 OF oDlgMail PICTURE "@!"    PIXEL

	@ 053, 006 SAY oAnexo PROMPT "Anexo:" SIZE 019, 007 OF oDlgMail   PIXEL
	@ 053, 030 MSGET oGetAnx VAR cGetAnx SIZE 256, 010 OF oDlgMail PICTURE "@!"    READONLY PIXEL

	@ 069, 006 SAY oMens PROMPT "Observacao:" SIZE 030, 007 OF oDlgMail   PIXEL
	_oScrAux	:= TSimpleEditor():New( 080 , 006 , oDlgMail , 285 , 105 ,,,,, .T. )
	
	_oScrAux:Load( _cObs )
	IF !EMPTY(_cPathLocal)
       @ 189, 156 BUTTON oButEnv PROMPT "&Visualizar"	SIZE 037, 012 OF oDlgMail ACTION ( ShellExecute("open", _cOrigem2, "", _cPathLocal, 1) ) PIXEL
	ENDIF
	@ 189, 201 BUTTON oButEnv PROMPT "&Enviar"		SIZE 037, 012 OF oDlgMail ACTION ( nOpcA := 1 , _cObs := _oScrAux:RetText() , oDlgMail:End() ) PIXEL
	@ 189, 245 BUTTON oButCan PROMPT "&Cancelar"	SIZE 037, 012 OF oDlgMail ACTION ( nOpcA := 2 , oDlgMail:End() ) PIXEL

ACTIVATE MSDIALOG oDlgMail CENTERED

If nOpcA == 1
   _cFiltros:="Periodo de "+ALLTRIM(AllToChar(MV_PAR01))+" ate "+ALLTRIM(AllToChar(MV_PAR02))+_ENTER
   _cFiltros+="Cargas Faturadas? "+SUBSTR(_aParOpc[VAL(MV_PAR03)],3)+_ENTER
   _cFiltros+="Ordens de Cargas já listadas? "+SUBSTR(_aParOpc[VAL(MV_PAR04)],3)+_ENTER
   _cFiltros+="Armazens? "+ALLTRIM(MV_PAR06)+_ENTER

    _cMsgEml := '<html>'
    _cMsgEml += '<head><title>'+cGetAssun+'</title></head>'
    _cMsgEml += '<body>'
    _cMsgEml += '<style type="text/css"><!--'
    _cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
    _cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
    _cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
    _cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
    _cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
    _cMsgEml += '--></style>'
    _cMsgEml += '<center>'
    _cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="600" height="50"><br>'
    _cMsgEml += '<table class="bordasimples" width="600">'
    _cMsgEml += '    <tr>'
    _cMsgEml += '	     <td class="titulos"><center>LISTA DE ORDEMS DE CARGA CONSOLIDADAS</center></td>'
    _cMsgEml += '	 </tr>'
    _cMsgEml += '</table>'
    _cMsgEml += '<br>'
    _cMsgEml += '<table class="bordasimples" width="600">'
    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td align="center" colspan="2" class="grupos">Dados do Envio</b></td>'
    _cMsgEml += '    </tr>'
    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="center" width="30%"><b>Enviado por: </b></td>'
    _cMsgEml += '      <td class="itens" >'+ UsrFullName(__cUserID) +'</td>'
    _cMsgEml += '    </tr>'
    _cMsgEml += '    <tr>'
	IF LEN(ALLTRIM(MV_PAR05)) = 2 
       _cMsgEml += ' <td class="itens" align="center" width="30%"><b>Filial: </b></td>'
       _cMsgEml += ' <td class="itens" >'+ ALLTRIM(MV_PAR05)+" - "+ALLTRIM( Posicione('SM0',1,"01"+ALLTRIM(MV_PAR05),'M0_FILIAL') ) +'</td>'
    ELSE
       _cMsgEml += ' <td class="itens" align="center" width="30%"><b>Filiais: </b></td>'
       _cMsgEml += ' <td class="itens" >'+ ALLTRIM(MV_PAR05) +'</td>'
	ENDIF
    _cMsgEml += '    </tr>'
    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="center" width="30%"><b>Filtros:</b></td>'
    _cMsgEml += '      <td class="itens" >'+ _cFiltros +'</td>'
    _cMsgEml += '    </tr>'
    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="center" width="30%"><b>Observações:</b></td>'
    _cMsgEml += '      <td class="itens" >'+ _cObs +'</td>'
    _cMsgEml += '    </tr>'
    _cMsgEml += '</table>'
    _cMsgEml += '</center>'
    _cMsgEml += '<br>'
    _cMsgEml += '<br>'
    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
    _cMsgEml += '      <td class="itens" align="left" > ['+ GETENVSERVER() +'] / <b>Fonte:</b> [ROMS079]</td>'
    _cMsgEml += '    </tr>'
    _cMsgEml += '</body>'
    _cMsgEml += '</html>'

	//cGetPara:=STRTRAN( cGetPara, ";", "," )
	//cGetCc  :=STRTRAN( cGetCc  , ";", "," )

	U_ITENVMAIL( Lower(ALLTRIM(UsrRetMail(RetCodUsr()))), cGetPara, cGetCc, "", cGetAssun, _cMsgEml, cGetAnx, _aConfig[01], _aConfig[02], _aConfig[03], _aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

	If !Empty( _cEmlLog )
       IF "SUCESSO" $ UPPER(_cEmlLog)
           FOR R := 1 TO LEN(_aCargas)
			   IF DAK->(DBSEEK(_aCargas[R])) 
                  DAK->( RECLOCK("DAK",.F.) )           
                  DAK->DAK_I_ENV++
                  DAK->( MSUNLOCK() )
			   ENDIF
           NEXT
       ENDIF
    ENDIF
	
	U_ITMSG( _cEmlLog+_ENTER+"E-mail para: "+ALLTRIM(cGetPara)+_ENTER+"CC: "+cGetCc , 'Término do processamento!' , ,3 )

    IF cGetAnx # nil .AND. FILE(cGetAnx)
       FErase(cGetAnx)
       U_ITCONOUT("Arquivo "+cGetAnx+" apagado com sucesso")
    ENDIF    
    
	IF cGetAnx # nil
	   cGetAnx:=STRTRAN( UPPER(cGetAnx), ".PDF", ".REL")
	   IF FILE(cGetAnx)
          FErase(cGetAnx)
	   ENDIF
    ENDIF    

ENDIF

Return()

/*
===============================================================================================================================
Programa--------: ROMS079B
Autor-----------: Alex Wallauer
Data da Criacao-: 18/09/2023
===============================================================================================================================
Descrição-------: Ler os dados do listbox
===============================================================================================================================
Parametros------: cLocal,cFileName
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/  
Static Function ROMS079B(cLocal,cFileName)

       //FWMsPrinter():New(cFilePrintert,nDevice],lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF], [ nQtdCopy] )
oPrint:= FwMsPrinter():New(cFileName    , IMP_PDF, .T.            , cLocal          , .T.          )//, .T.        ,  NIL           , NIL        , NIL       , NIL         , NIL    , .F.        , NIL         )
oPrint:SetLandScape()    // Fixa a Impressao em Retrato //oPrint:SetPortrait()
oPrint:cPathPDF := cLocal
oPrint:SetViewPDF(.F.)

Processa( {|| ROMS079C() }, "Aguarde...", "Montando PDF...",.F.)

LjMsgRun( "Gerando a PDF: +"+cLocal+cFileName, "Aguarde..." , {|| oPrint:Preview() } )//Visualiza antes de imprimir

Return .T.
/*
===============================================================================================================================
Programa--------: ROMS079C
Autor-----------: Alex Wallauer
Data da Criacao-: 18/09/2023
===============================================================================================================================
Descrição-------: Geração dos dados em PDF
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/ 
Static Function ROMS079C()

Local  ni , L , _nTamDes := 50
PRIVATE _nLinhaIni := 70
PRIVATE _nLinha    := _nLinhaIni 
PRIVATE _nLinMax   := 2400
PRIVATE _nColIni   := 10

//COLUNAS DOS PRODUTOS
PRIVATE _nColI02:=_nColIni+225//Descricao do Produto
PRIVATE _nColI03:=_nColI02+800//Qt 1a
PRIVATE _nColI04:=_nColI03+365//1 UM
PRIVATE _nColI05:=_nColI04+100//Qt 2a
PRIVATE _nColI06:=_nColI05+365//2 UM
PRIVATE _nColI07:=_nColI06+120//Peso Bruto Tot
PRIVATE _nColI08:=_nColI07+335//Qtd Pal
PRIVATE _nColI09:=_nColI08+435//Vlr. Tot. Prod

//COLUNAS DAS CARGAS
PRIVATE _nColCar:=_nColIni+55 //Carga
PRIVATE _nColC02:=_nColCar+160//Peso
PRIVATE _nColC03:=_nColC02+220//Veiculo
PRIVATE _nColC04:=_nColC03+165//Desc. Vei.
PRIVATE _nColC05:=_nColC04+440//Cod. Motorista
PRIVATE _nColC06:=_nColC05+235//Motorista
PRIVATE _nColC07:=_nColC06+700//Ptos 
PRIVATE _nColC08:=_nColC07+200//Valor 
PRIVATE _nColC09:=_nColC08+295//Pre Carga
PRIVATE _nColC10:=_nColC09+145//Data
PRIVATE _nColC11:=_nColC10+150//Hora
PRIVATE _nColC12:=_nColC11+145//Envio

//Configuracoes para "Exporta para PDF" / Envio via e-mail
Private _nColMax	:= 3280
Private _nColFimPDH := _nColMax-1150
//                                  Fonte          Tamanho   Negrito
PRIVATE _oFont18	:= TFont():New( "Arial"     ,, 28      ,, .T.)
Private _oFontIT    := TFont():New('Courier new',, 12      ,, .F.)
//Configuracoes para "Exporta para PDF" / Envio via e-mail

PROCREGUA(LEN(_aDadosCarga))
INCPROC("Contando Marcados de " + STRZERO(LEN(_aDadosCarga),6))
nConta:=0
FOR NI := 1 TO LEN(_aDadosCarga)
    IF !_aDadosCarga[NI][01] 
	   LOOP
	ENDIF
    //INCPROC("Contando Marcados: " + STRZERO(NI,5) + " de " + STRZERO(LEN(_aDadosCarga),6))
    nConta++
NEXT
INCPROC("Contando Marcados: " + STRZERO(nConta,5) + " de " + STRZERO(LEN(_aDadosCarga),6))

_aDadosAuxItem:=ACLONE(_aDadosItem)

IF nConta < LEN(_aDadosCarga)//SE NÃO ESTÃO TODOS MARCADOS RECALCULA OS ITENS PARA SÓ OS MARCADOS

    PROCREGUA(LEN(_aDadosCarga))
    
    _aDadosItem:={}
    FOR NI := 1 TO LEN(_aDadosCarga)
    
    	INCPROC("Recalculando Marcados: " + STRZERO(NI,5) + " de " + STRZERO(LEN(_aDadosCarga),6))
        IF !_aDadosCarga[NI][01] 
    	   LOOP
    	ENDIF
        
        IF DAK->(DBSEEK(_aDadosCarga[NI][nPosFil]+_aDadosCarga[NI][nPosCar]))
    	   REST79ReLe()
    	ENDIF
    
    NEXT
    FOR L := 1 TO LEN(_aDadosItem)//CALCULA A QDE DE Pallets
        IF SB1->( DBSeek( xFilial("SB1") + _aDadosItem[L,1] ) )
    	   _aDadosItem[L,nPosQPal]:= REST79SPal(_aDadosItem[L,nPosQt1m],_aDadosItem[L,nPosQt2m],SB1->B1_SEGUM,SB1->B1_TIPO)
    	ENDIF
    NEXT
    FOR L := 1 TO LEN(_aDadosItem)//AJUSTE PARA MOSTRAR NO RELATORIO CORRETO
        _aDadosItem[L,nPosQt1m]:= TRANSFORM(_aDadosItem[L,nPosQt1m],"@E 999,999,999,999.999" )//SC9->C9_QTDLIB   
        _aDadosItem[L,nPosQt2m]:= TRANSFORM(_aDadosItem[L,nPosQt2m],"@E 999,999,999,999.999" )//SC9->C9_QTDLIB2  
        _aDadosItem[L,nPosPBru]:= TRANSFORM(_aDadosItem[L,nPosPBru],"@E 999,999,999,999.9999")//SB1->B1_PESBRU * SC9->C9_QTDLIB
        _aDadosItem[L,nPosPtos]:= TRANSFORM(_aDadosItem[L,nPosPtos],"@E 999,999,999,999.99"  )//SC9->C9_QTDLIB * SC9->C9_PRCVEN 
    NEXT

    ASORT(_aDadosItem,,,{|x,y|x[2] < y[2]})

ENDIF//SE NÃO ESTÃO TODOS MARCADOS RECALCULA PARA SÓ OS MARCADOS

_nPagAux:=0
REST079CAB()
REST79Sub("PRODUTOS")

PROCREGUA(LEN(_aDadosItem))

FOR NI := 1 TO  LEN(_aDadosItem)
	
	incproc("Imprimindo PRODUTO: " + STRZERO(NI,5) + " de " + STRZERO(LEN(_aDadosItem),5))

	If _nLinha >= _nLinMax
	   oPrint:EndPage()
	   REST079CAB()
       REST79Sub("PRODUTOS")
    EndIf
	
	oPrint:Say( _nLinha , _nColIni , _aDadosItem[NI][01], _oFontIT )
	oPrint:Say( _nLinha  ,_nColI02 , MEMOLINE(_aDadosItem[NI][02],_nTamDes,1), _oFontIT )
	oPrint:Say( _nLinha , _nColI03 , _aDadosItem[NI][03], _oFontIT )
	oPrint:Say( _nLinha , _nColI04 , _aDadosItem[NI][04], _oFontIT )
	oPrint:Say( _nLinha , _nColI05 , _aDadosItem[NI][05], _oFontIT )
	oPrint:Say( _nLinha , _nColI06 , _aDadosItem[NI][06], _oFontIT )
  	oPrint:Say( _nLinha , _nColI07 , _aDadosItem[NI][07], _oFontIT )
	oPrint:Say( _nLinha , _nColI08 , _aDadosItem[NI][08], _oFontIT )
	oPrint:Say( _nLinha , _nColI09 , _aDadosItem[NI][09], _oFontIT )
	_nLinha += 050
    if !EMPTY(MEMOLINE(_aDadosItem[NI][02],_nTamDes,2))
	   oPrint:Say( _nLinha  ,_nColI02 , MEMOLINE(_aDadosItem[NI][02],_nTamDes,2), _oFontIT )
	   _nLinha += 050
	ENDIF

NEXT

PROCREGUA(LEN(_aDadosCarga))

REST079CAB(.T.)
REST79Sub("CARGA")

_aCargas:={}
FOR NI := 1 TO LEN(_aDadosCarga)

	INCPROC("Imprimindo CARGA: " + STRZERO(NI,5) + " de " + STRZERO(LEN(_aDadosCarga),6))
    IF !_aDadosCarga[NI][01] 
	   LOOP
	ENDIF
    
	AADD(_aCargas,_aDadosCarga[NI][nPosFil]+_aDadosCarga[NI][nPosCar])

	If _nLinha >= _nLinMax
	   oPrint:EndPage()
	   REST079CAB(.T.)
       REST79Sub("CARGA")
    EndIf

	oPrint:Say( _nLinha , _nColIni , _aDadosCarga[NI][nPosFil], _oFontIT )//Filial
	oPrint:Say( _nLinha , _nColCar , _aDadosCarga[NI][nPosCar], _oFontIT )//Carga
	oPrint:Say( _nLinha  ,_nColC02 , _aDadosCarga[NI][05], _oFontIT )//Peso
	oPrint:Say( _nLinha , _nColC03 , _aDadosCarga[NI][06], _oFontIT )//Veiculo
	oPrint:Say( _nLinha , _nColC04 , _aDadosCarga[NI][07], _oFontIT )//Desc. Vei.
  	oPrint:Say( _nLinha , _nColC05 , _aDadosCarga[NI][08], _oFontIT )//Motorista
	oPrint:Say( _nLinha , _nColC06 , _aDadosCarga[NI][09], _oFontIT )//Descri Moto
  	oPrint:Say( _nLinha , _nColC07 , _aDadosCarga[NI][10], _oFontIT )//Ptos *
	oPrint:Say( _nLinha , _nColC08 , _aDadosCarga[NI][11], _oFontIT )//Valor 
	oPrint:Say( _nLinha , _nColC09 , _aDadosCarga[NI][12], _oFontIT )//Pre Carga
	oPrint:Say( _nLinha , _nColC10 , _aDadosCarga[NI][13], _oFontIT )//Data
	oPrint:Say( _nLinha , _nColC11 , _aDadosCarga[NI][14], _oFontIT )//Hora
    oPrint:Say( _nLinha , _nColC12 , _aDadosCarga[NI][15], _oFontIT )//Envio
	_nLinha += 050

NEXT

oPrint:EndPage()                // Finaliza a Pagina de Impressao

_aDadosItem:=ACLONE(_aDadosAuxItem)

Return .F. //NAO SAIR 

/*
===============================================================================================================================
Programa--------: REST079CAB
Autor-----------: Alex Wallauer
Data da Criacao-: 18/09/2023
===============================================================================================================================
Descrição-------: Função para construir o cabeçalho da página
===============================================================================================================================
Parametros------: _lTit2 := .F. ou .T.
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/

Static Function REST079CAB(_lTit2)
Local _nAjusteCb:= 0
Local _oFont10	:= TFont():New( "Arial" ,, 14 ,,.F. )
Local nColTot	:= oPrint:nPageWidth /// oPrint:nFactorHor //Largura da página em cm dividido pelo fator horizontal, retorna tamanho da página em pixels
Local nMeio     := int(nColTot / 3)+55
Local nLargura  := 800
Local nAltura   := 100
DEFAULT _lTit2  := .F.

oPrint:StartPage()              // Inicializa a Pagina de Impressao

_nLinha := _nLinhaIni
_nPagAux++

oPrint:Line( _nLinha		, _nColIni , _nLinha		, _nColMax )
_nlinha += 050

IF _lTit2
   _nSomaCol:=0950//1235
   oPrint:Say( _nLinha+35 , _nColIni +_nSomaCol - _nAjusteCb, "RESUMO DAS ORDENS DE CARGA" , _oFont18 )
ELSE
   _nSomaCol:=0990//1235
   oPrint:Say( _nLinha+35 , _nColIni +_nSomaCol - _nAjusteCb, "LISTAGEM ORDEM DE CARGA" , _oFont18 )
ENDIF

nColTot	:= oPrint:nPageWidth /// oPrint:nFactorHor //Largura da página em cm dividido pelo fator horizontal, retorna tamanho da página em pixels
nMeio    := int(nColTot / 3)+55
nLargura := 800
nAltura  := 100

IF LEN(ALLTRIM(MV_PAR05)) = 2 
   oPrint:SayAlign(_nLinha+055, nMeio, 'FILIAL: '+ ALLTRIM(MV_PAR05) +' - '+ ALLTRIM(FWFilialName(cEmpAnt,ALLTRIM(MV_PAR05),1))  , _oFont10,nLargura,nAltura,,2)
ELSE
   oPrint:SayAlign(_nLinha+055, nMeio, 'FILIAIS: '+ ALLTRIM(MV_PAR05) , _oFont10,nLargura,nAltura,,2)
ENDIF
_nLinPDH:=40

oPrint:Say( _nLinha,_nColIni, "Periodo de "+ALLTRIM(AllToChar(MV_PAR01))+" ate "+ALLTRIM(AllToChar(MV_PAR02)) , _oFont10 )
oPrint:SayAlign( _nLinha-_nLinPDH,_nColFimPDH, 'Página: '+ StrZero(_nPagAux,3)	, _oFont10 ,900,100,, 1 )
_nLinha += 050

oPrint:Say( _nLinha,_nColIni, "Cargas Faturadas? "+SUBSTR(_aParOpc[VAL(MV_PAR03)],3) , _oFont10 )
oPrint:SayAlign( _nLinha-_nLinPDH,_nColFimPDH, 'Data: '+ DtoC( Date() )	    , _oFont10 ,900,100,, 1 )
_nLinha += 050

oPrint:Say( _nLinha,_nColIni, "Ordens de Cargas já listadas? "+SUBSTR(_aParOpc[VAL(MV_PAR04)],3) , _oFont10 )
oPrint:SayAlign( _nLinha-_nLinPDH,_nColFimPDH, 'Hora: '+ Time(), _oFont10 ,900,100,, 1 )
_nLinha += 025

oPrint:Line( _nLinha , _nColIni , _nLinha, _nColMax )
_nLinha += 040

Return()

/*
===============================================================================================================================
Programa--------: REST79Sub()
Autor-----------: Alex Wallauer
Data da Criacao-: 18/09/2023
===============================================================================================================================
Descrição-------: Imprimie os cabecalho  das colulas dos pedidos
===============================================================================================================================
Parametros------: _cTipo: "PRODUTOS" "CARGA"
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function REST79Sub(_cTipo)

LOCAL aTitulo:={_aCabItemImp,_aCabImp} , R 
LOCAL nTipo :=1

_aPosicao:={}

IF _cTipo = "PRODUTOS"	
    
	nTipo:=1
	AADD(_aPosicao,_nColIni)      //Produto
	AADD(_aPosicao,_nColI02)      //Descricao do Produto
	AADD(_aPosicao,_nColI03+130)  //Qt 1a
	AADD(_aPosicao,_nColI04-25)   //1 UM
	AADD(_aPosicao,_nColI05+130)  //Qt 2a
	AADD(_aPosicao,_nColI06-25)   //2 UM
	AADD(_aPosicao,_nColI07+091)  //Pso.Bruto Tot
	AADD(_aPosicao,_nColI08)      //Qtd Pal
	AADD(_aPosicao,_nColI09+035)  //Vr Total

ELSEIF _cTipo = "CARGA"
    
	nTipo:=2
	AADD(_aPosicao,_nColIni)     // Filial
	AADD(_aPosicao,_nColCar)     // Carga
	AADD(_aPosicao,_nColC02+115) // Peso
	AADD(_aPosicao,_nColC03)     // Veiculo
	AADD(_aPosicao,_nColC04)     // Desc. Vei.
    AADD(_aPosicao,_nColC05-45)  // Cod. Motorista
	AADD(_aPosicao,_nColC06)     // Motorista
	AADD(_aPosicao,_nColC07)     // Ptos.Ent
	AADD(_aPosicao,_nColC08+28)  // Valor Carga
	AADD(_aPosicao,_nColC09-45)  // Pre Carga
	AADD(_aPosicao,_nColC10+15)  // Data
	AADD(_aPosicao,_nColC11+15)  // Hora
	AADD(_aPosicao,_nColC12+25)  // Envio

ENDIF

FOR R := 1 TO LEN(aTitulo[nTipo]) //Os titulos que determinam quantas colunas serão impressao
    oPrint:Say( _nLinha,_aPosicao[R],aTitulo[nTipo,R],_oFontIT )
NEXT
_nLinha += 030

oPrint:Line( _nLinha , _nColIni , _nLinha, _nColMax )
_nLinha += 050
		
Return .t.


/*
===============================================================================================================================
Programa--------: REST79SPal()
Autor-----------: Alex Wallauer
Data da Criacao-: 18/09/2023
===============================================================================================================================
Descrição-------: Imprimie os cabecalho  das colulas dos pedidos
===============================================================================================================================
Parametros------: nQtde1,nQtde2
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function REST79SPal(nQtde1,nQtde2,cSegUM,cTipo)

LOCAL _nQtPallet:= 0
LOCAL _nQtSobra := 0
LOCAL _nQtNoPl	 := 0
LOCAL _cUMPal	 := ''

//================================================================================
// Cálculo da quantidade de Pallets
//================================================================================
If SB1->B1_I_UMPAL == '1'
	_nQtPallet	:= Int( nQtde1 / SB1->B1_I_CXPAL )
ElseIf SB1->B1_I_UMPAL == '2'
	If ALLTRIM(cSegUM) == "PC" .And. ALLTRIM(cTipo) == "PA" //Tratamento para o QUEIJO
	   _nQtPallet	:= Int(  nQtde2  / SB1->B1_I_CXPAL )
   ELSE
	   _nQtPallet	:= Int( ROMS79CNV( nQtde1 , 1 , 2 ) / SB1->B1_I_CXPAL )
	ENDIF
ElseIf SB1->B1_I_UMPAL == '3'
	_nQtPallet	:= Int( ROMS79CNV( nQtde1 , 1 , 3 ) / SB1->B1_I_CXPAL )
Else
	_nQtPallet	:= 0
	_nQtSobra	:= 0
	_cUMPal		:= ''
EndIf

_nQtNoPl := ( _nQtPallet * SB1->B1_I_CXPAL )
//================================================================================
// Dados para impressão da sobra com relação aos Pallets completos
//================================================================================
If SB1->B1_I_QTOC3 == '1'
	If SB1->B1_I_UMPAL == '2'
		_nQtNoPl := ROMS79CNV( _nQtNoPl , 2 , 1 )
	ElseIf SB1->B1_I_UMPAL == '3'
		_nQtNoPl := ROMS79CNV( _nQtNoPl , 3 , 1 )
	EndIf
	_nQtSobra	:= nQtde1 - _nQtNoPl
	_cUMPal		:= SB1->B1_UM
ElseIf SB1->B1_I_QTOC3 == '2'
	If SB1->B1_I_UMPAL == '1'
		_nQtNoPl := ROMS79CNV( _nQtNoPl , 1 , 2 )
	ElseIf SB1->B1_I_UMPAL == '3'
		_nQtNoPl := ROMS79CNV( _nQtNoPl , 3 , 2 )
	EndIf
	_nQtSobra	:= ROMS79CNV( nQtde1 , 1 , 2 ) - _nQtNoPl
	_cUMPal		:= SB1->B1_SEGUM
ElseIf SB1->B1_I_QTOC3 == '3'
	If SB1->B1_I_UMPAL == '1'
	   _nQtNoPl := ROMS79CNV( _nQtNoPl , 1 , 3 )
	   _nQtSobra:= ROMS79CNV( nQtde1 , 1 , 3 ) - _nQtNoPl
	ElseIf SB1->B1_I_UMPAL == '2'
	   _nQtNoPl := ROMS79CNV( _nQtNoPl , 2 , 3 )//CONVERTE PARA CAIXAS
	   _nQtSobra:= ROMS79CNV( nQtde2 , 2 , 3 ) - _nQtNoPl
	EndIf
	_cUMPal		:= SB1->B1_I_3UM
Else
	_nQtPallet	:= 0
	_nQtSobra	:= 0
	_cUMPal		:= ''
EndIf
		
_cInfPal := ''
If !Empty( _cUMPal )
	If _nQtPallet > 0
		_cInfPal := cValToChar( _nQtPallet ) + ' Pallet' + IIf( _nQtPallet > 1 , 's' , '' ) + IIf( _nQtSobra > 0 , '+' , '' )
	EndIf
	If _nQtSobra > 0
		_cInfPal += cValToChar( _nQtSobra ) +' '+ _cUMPal
	EndIf
EndIf

RETURN _cInfPal

/*
===============================================================================================================================
Programa--------: ROMS79CNV
Autor-----------: Alex Wallauer
Data da Criacao-: 18/09/2023
===============================================================================================================================
Descrição-------: Função para conversão entre unidades de medida - COPIA DA ROMS004CNV
===============================================================================================================================
Parametros------: _nQtdAux , _nUMOri , _nUMDes
===============================================================================================================================
Retorno---------: _nRet
===============================================================================================================================
*/
Static Function ROMS79CNV( _nQtdAux , _nUMOri , _nUMDes )

Local _nRet	:= 0

Do Case

	Case _nUMDes == 1
		
		//================================================================================
		// Conversão da Segunda UM para a Primeira
		//================================================================================
		If _nUMOri == 2
			
			If SB1->B1_TIPCONV == 'D'
				_nRet := _nQtdAux * SB1->B1_CONV
			ElseIf SB1->B1_TIPCONV == 'M'
				_nRet := _nQtdAux / SB1->B1_CONV
			EndIf
		
		//================================================================================
		// Conversão da Terceira UM para a Primeira
		//================================================================================
		ElseIf _nUMOri == 3
			
			_nRet := _nQtdAux * SB1->B1_I_QT3UM
			
		EndIf
		
	Case _nUMDes == 2
	    
		//================================================================================
		// Conversão da Primeira UM para a Segunda
		//================================================================================
		If _nUMOri == 1
			
			If SB1->B1_TIPCONV == 'D'
				_nRet := _nQtdAux / SB1->B1_CONV
			ElseIf SB1->B1_TIPCONV == 'M'
				_nRet := _nQtdAux * SB1->B1_CONV
			EndIf
		
		//================================================================================
		// Conversão da Terceira UM para a Segunda
		//================================================================================	
		ElseIf _nUMOri == 3
			
			_Ret := _nQtdAux * SB1->B1_I_QT3UM
			
			If SB1->B1_TIPCONV == 'D'
				_nRet := _nRet / SB1->B1_CONV
			ElseIf SB1->B1_TIPCONV == 'M'
				_nRet := _nRet * SB1->B1_CONV
			EndIf
			
		EndIf
	
	Case _nUMDes == 3
    
		//================================================================================
		// Conversão da PRIMEIRA UM PARA A TERCEIRA
		//================================================================================
		If _nUMOri == 1
			
			_nRet := _nQtdAux / SB1->B1_I_QT3UM
		
		//================================================================================
		// Conversão da SEGUNDA UM PARA A TERCEIRA
		//================================================================================	
		ElseIf _nUMOri == 2
			
			if SB1->B1_CONV > 0 
			   If SB1->B1_TIPCONV == 'D'
			   	  _nRet := _nQtdAux * SB1->B1_CONV
			   ElseIf SB1->B1_TIPCONV == 'M'
			   	  _nRet := _nQtdAux / SB1->B1_CONV
			   EndIf
			ELSE//SÓ PARA O QUEIJO
			   _nRet := _nQtdAux
			ENDIF			
			
			_nRet := _nRet / SB1->B1_I_QT3UM
			
		EndIf

EndCase

Return( Round(_nRet,2) )


/*
===============================================================================================================================
Programa--------: REST79ReLe()
Autor-----------: Alex Wallauer
Data da Criacao-: 18/09/2023
===============================================================================================================================
Descrição-------: Compondo os dados do produto MARCADOS
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
STATIC FUNCTION REST79ReLe()
If DAI->( DBSeek( xFilial("DAI") + DAK->DAK_COD ) )
	
	DO While DAI->( !EOF() ) .And. DAI->( DAI_FILIAL + DAI_COD ) == xFilial("DAI") + DAK->DAK_COD
	
		//====================================================================================================
		// Compondo os dados do produto
		//====================================================================================================
		If SC6->( DBSeek( xFilial("SC6") + DAI->DAI_PEDIDO ) )
		
		   DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == xFilial("SC6") + DAI->DAI_PEDIDO
			    
			  SB1->( DBSeek( xFilial("SB1") + SC6->C6_PRODUTO ) )
			  SC9->( DBSeek( xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM ) )

                _cDescItem:=ALLTRIM(SB1->B1_DESC)

			   If (nPos := Ascan( _aDadosItem , { |x| x[1] == ALLTRIM(SC6->C6_PRODUTOS)+"-"+SC6->C6_LOCAL } ) ) == 0
                    
				  _aProds:={}
                    AADD(_aProds , ALLTRIM(SC6->C6_PRODUTOS)+"-"+SC6->C6_LOCAL)//01
                    AADD(_aProds , _cDescItem                          )//02
                    AADD(_aProds , SC9->C9_QTDLIB                      )//03
                    AADD(_aProds , SB1->B1_UM                          )//04
                    AADD(_aProds , SC9->C9_QTDLIB2                     )//05
                    AADD(_aProds , SB1->B1_SEGUM                       )//06
                    AADD(_aProds , ( SB1->B1_PESBRU * SC9->C9_QTDLIB ) )//07
                    AADD(_aProds , " "                                 )//08
                    AADD(_aProds , ( SC9->C9_QTDLIB * SC9->C9_PRCVEN ) )//09
                    
				  AADD(_aDadosItem , _aProds )
			   Else
				  _aDadosItem[nPos][nPosQt1m] += SC9->C9_QTDLIB
				  _aDadosItem[nPos][nPosQt2m] += SC9->C9_QTDLIB2
				  _aDadosItem[nPos][nPosPBru] +=(SB1->B1_PESBRU * SC9->C9_QTDLIB)
				  _aDadosItem[nPos][nPosPtos] +=(SC9->C9_QTDLIB * SC9->C9_PRCVEN)			
			   EndIf
			   SC6->( DbSkip() )

			Enddo
	
		EndIf
		DAI->( DBSkip() )
	EndDo
EndIf

RETURN
