/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço  |19/09/2021| Chamado 41359. Correção de error.log.
Alex Wallauer |13/08/2024| Chamado 48002. Andre. Correção de error.log: variable does not exist _N2SALDO.
Lucas Borges  |08/10/2024| Chamado 48465. Retirada manipulação do SX1
===============================================================================================================================
*/
#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'
/*
===============================================================================================================================
Programa----------: REST015
Autor-------------: Alex Wallauer
Data da Criacao---: 29/04/2019
===============================================================================================================================
Descrição---------: Relatório de informações das liberações da qualidade
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function REST015()
STATIC _asAllusers := {}
PRIVATE _aAllusers := {}
PRIVATE _nPU := 0
IF LEN(_asAllusers) = 0
   _asAllusers := FWSFALLUSERS()
ENDIF   
_aAllusers := _asAllusers

_SelSB1:="(SELECT SB1.B1_I_DESCD FROM "+RETSQLNAME("SB1")+" SB1 WHERE D_E_L_E_T_ = ' ' AND SB1.B1_COD = SD7.D7_PRODUTO) DESCD "
_cSeleNSD7:="SELECT DISTINCT D7_NUMERO, D7_LIBERA, MIN(D7_DATA) D7DATA FROM "+RETSQLNAME("SD7")+" SD7 WHERE D_E_L_E_T_ = ' ' AND D7_FILIAL = '"+xFilial("SD7")+"' ORDER BY D7_NUMERO  GROUP BY  D7_NUMERO, D7_LIBERA " 
//_cSeleUSD7:="SELECT DISTINCT D7_USUARIO             FROM "+RETSQLNAME("SD7")+" SD7 WHERE D_E_L_E_T_ = ' ' AND D7_FILIAL = '"+xFilial("SD7")+"' ORDER BY D7_USUARIO " 
_cSelePSD7:="SELECT DISTINCT D7_PRODUTO,"+_SelSB1+" FROM "+RETSQLNAME("SD7")+" SD7 WHERE D_E_L_E_T_ = ' ' AND D7_FILIAL = '"+xFilial("SD7")+"' ORDER BY D7_PRODUTO " 

_aDadosTM:={}
AADD( _aDadosTM ,"0-Qtd. Original      ")
AADD( _aDadosTM ,"1-Liberado           ")
AADD( _aDadosTM ,"2-Rejeitado          ")
AADD( _aDadosTM ,"3-Devolucao Liberacao")
AADD( _aDadosTM ,"4-Devolucao Rejeicao ")
AADD( _aDadosTM ,"6-Est. Liberacao     ")
AADD( _aDadosTM ,"7-Est. Rejeicao      ")
AADD( _aDadosTM ,"8-Despesas Agregadas ")
AADD( _aDadosTM ,"9-Estorno Despesas   ")

//_bCol8:={|Tab| _cUser:=UPPER((Tab)->D7_USUARIO) , IF( (_nPU:=ASCAN(_aAllusers, {|A| UPPER(A[3]) == _cUser })) <> 0 ,_aAllusers[ _nPU,4],SPACE(40)) }
_bCol3:={|Tab| DTOC(STOD((Tab)->D7DATA))+" "+(Tab)->D7_LIBERA}
                                                                           
_aItalac_F3:={}//       1           2         3                      4                      5                6                         7         8          9         10         11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave               , _nCpoDesc              ,_bCondTab    , _cTitAux                , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR03" ,_cSeleNSD7,{|Tab| (Tab)->D7_NUMERO }, _bCol3                 ,             ,"Numero da Transferencia",          ,          ,100       ,.T.        ,       , } )
AADD(_aItalac_F3,{"MV_PAR05" ,_cSelePSD7,{|Tab| (Tab)->D7_PRODUTO}, {|Tab|(Tab)->DESCD}    ,             ,"Produtos"               ,          ,          ,30        ,.T.        ,       , } )
AADD(_aItalac_F3,{"MV_PAR07" ,"CYO"     ,                         ,                        ,             ,"Motivos de Rejeicao"} )

DO WHILE .T.
   If !Pergunte("REST015",.T.)
      return
   EndIf

    IF EMPTY(MV_PAR01) .OR. EMPTY(MV_PAR02) .OR. MV_PAR02 < MV_PAR01
       U_ITMSG("Datas invalidas ou não preenchidas",'Atenção!',"Preencha as 2 datas e a final maior ou igual a inicial",1)
       LOOP
    ENDIF

   cTimeInicial:=TIME()

   FWMSGRUN( ,{|oProc|  REST015R(oProc) } , "SD7 - Hora Inicial: "+cTimeInicial+", Aguarde...",  )

  ENDDO 

U_ITLOGACS( "REST015" )

Return


/*
===============================================================================================================================
Programa----------: REST015R
Autor-------------: Alex Wallauer
Data da Criacao---: 29/04/2019
===============================================================================================================================
Descrição---------: Função que imprime o relatório
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function REST015R(oProc)
Local cQry1		:= ""
LOCAL _cAlias  := GetNextAlias()
PRIVATE _aItens  := {}
PRIVATE _n1Origem:=0
PRIVATE _n2Origem:=0
PRIVATE _n1Liberados:=0
PRIVATE _n2Liberados:=0
PRIVATE _n1Rejetados:=0
PRIVATE _n2Rejetados:=0
PRIVATE _n1Saldo:=0
PRIVATE _n2Saldo:=0
PRIVATE _cMotRej := ""
PRIVATE _cObsItal := ""

   oProc:cCaption :=  "Selecionando Tranferencias, Aguarde... "
   ProcessMessages()

cQry1 := "SELECT  R_E_C_N_O_ RECSD7 "
cQry1 += "FROM " + RetSqlName("SD7") + " SD7  "
cQry1 += " WHERE SD7.D7_FILIAL = '"+xFilial("SD7")+" ' AND "
cQry1 += " D7_NUMERO IN (SELECT  D7_NUMERO "
cQry1 += "                 FROM  " + RetSqlName("SD7") + " SD7  "
cQry1 += "                 WHERE SD7.D7_FILIAL = '"+xFilial("SD7")+" ' "
cQry1 += "                       AND SD7.D_E_L_E_T_ = ' ' "
cQry1 += "                       AND D7_TIPO = 0 "
If MV_PAR04 = 1//'S'
   cQry1 += "                    AND D7_LIBERA = 'S' "
ELSEIf MV_PAR04 = 2//'N'
   cQry1 += "                    AND D7_LIBERA <> 'S' "
EndIf
IF !EMPTY(MV_PAR02)
   cQry1 += "                    AND D7_DATA BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "'"
ElseIf !EMPTY(MV_PAR01)
   cQry1 += "                    AND D7_DATA >= '" + DtoS(MV_PAR01) + "'"
ENDIF   
cQry1 += "            ) "

If !Empty(MV_PAR03)
	cQry1 += " AND D7_NUMERO IN "+FormatIn(ALLTRIM(MV_PAR03),";")
EndIf
	
If !Empty(MV_PAR05)
	cQry1 += " AND D7_PRODUTO IN "+FormatIn(ALLTRIM(MV_PAR05),";")
EndIf

If !Empty(MV_PAR07)
	cQry1 += " AND D7_MOTREJE IN "+FormatIn(ALLTRIM(MV_PAR07),";")
EndIf

cQry1 += " AND SD7.D_E_L_E_T_ = ' ' "
cQry1 += " ORDER BY D7_FILIAL, D7_NUMERO, D7_SEQ "

//crio o novo alias
MPSysOpenQuery( cQry1, _cAlias ) 

nTotal:=nConta:=0
dbSelectArea(_cAlias)
COUNT TO nTotal

IF nTotal = 0 
    U_ITMSG("Não há dados para essa seleção",'Atenção!',,1)
    (_cAlias)->(DBCloseArea())
    RETURN .F.
ENDIF

(_cAlias)->(dbGoTop())
SD7->(DBGOTO((_cAlias)->RECSD7))
_cNumero :=SD7->D7_NUMERO
_cProduto:=SD7->D7_PRODUTO
_cData:=SD7->D7_DATA
_aDados:={}
nTotal:=ALLTRIM(STR(nTotal))
nTam:=LEN(nTotal)+1
SCR->(DBSETORDER(1))

DO While !(_cAlias)->(Eof())

   SD7->(DBGOTO((_cAlias)->RECSD7))
   nConta++
   oProc:cCaption :=  "Lendo "+STRZERO(nConta,nTam)+" de "+nTotal +" - Lendo Pedido " +SD7->D7_NUMERO
   ProcessMessages()
   
   _aItens:={}
     IF MV_PAR06 = 2 // ANALITICO
	    _cTipo:=SPACE(22)
        IF (_nPU:=ASCAN(_aDadosTM,{|T| val(T) == SD7->D7_TIPO })) <> 0
           _cTipo:=_aDadosTM[_nPU]
        ENDIF
    	AADD(_aItens,SD7->D7_NUMERO)
		AADD(_aItens,ALLTRIM(SD7->D7_PRODUTO)+" - "+POSICIONE("SB1",1,xfilial("SB1")+SD7->D7_PRODUTO,"B1_I_DESCD") )
		AADD(_aItens,DTOC(SD7->D7_DATA))
		AADD(_aItens,_cTipo)
		AADD(_aItens,Transform(SD7->D7_QTDE   ,PesqPict("SD7","D7_QTDE")))
		AADD(_aItens,Transform(SD7->D7_SALDO  ,PesqPict("SD7","D7_SALDO")))
		AADD(_aItens,Transform(SD7->D7_QTSEGUM,PesqPict("SD7","D7_QTSEGUM")))
		AADD(_aItens,Transform(SD7->D7_SALDO2 ,PesqPict("SD7","D7_SALDO2")))
		AADD(_aItens,ALLTRIM(SD7->D7_USUARIO)+" - "+IF( (_nPU:=ASCAN(_aAllusers, {|A| UPPER(A[3]) == UPPER(ALLTRIM(SD7->D7_USUARIO))})) <> 0 ,_aAllusers[ _nPU,4],SPACE(40)))
		AADD(_aItens,ALLTRIM(SD7->D7_MOTREJE)+" - "+POSICIONE("CYO",1,xfilial("CYO")+SD7->D7_MOTREJE,"CYO_DSRF") )
      AADD(_aItens,SD7->D7_I_OBS)

        AADD(_aDados,ACLONE(_aItens))
   
     ELSEIF MV_PAR06 = 1 // SINTETICO

        IF _cNumero <> SD7->D7_NUMERO
		     REST15Sin()
           AADD(_aDados,ACLONE(_aItens))
           _cMotRej  := ""
           _cObsItal := ""
        ENDIF

         _cMotRej += Iif(!Empty(Alltrim(SD7->D7_MOTREJE)),(IiF(!Empty(_cMotRej),";","") + ALLTRIM(SD7->D7_MOTREJE)+" - "+ Alltrim(POSICIONE("CYO",1,xfilial("CYO")+SD7->D7_MOTREJE,"CYO_DSRF"))),"")
         _cObsItal += Iif(!Empty(Alltrim(SD7->D7_I_OBS)),(IiF(!Empty(_cObsItal),";","") + Alltrim(SD7->D7_I_OBS)),"")

        IF SD7->D7_TIPO = 0
           _n1Origem:=SD7->D7_SALDO
           _n2Origem:=SD7->D7_SALDO2
           _n1Saldo :=SD7->D7_SALDO
           _n2Saldo :=SD7->D7_SALDO2
        ELSEIF SD7->D7_TIPO = 1 //LIBERACAO
           _n1Saldo    -=SD7->D7_QTDE
           _n2Saldo    -=SD7->D7_QTSEGUM
           _n1Liberados+=SD7->D7_QTDE
           _n2Liberados+=SD7->D7_QTSEGUM
        ELSEIF SD7->D7_TIPO = 2//REJEIÇÃO
           _n1Saldo    -=SD7->D7_QTDE
           _n2Saldo    -=SD7->D7_QTSEGUM
           _n1Rejetados+=SD7->D7_QTDE
           _n2Rejetados+=SD7->D7_QTSEGUM
        ELSEIF SD7->D7_TIPO = 6//ESTONO DA LIBERAÇÃO
           _n1Saldo    +=SD7->D7_QTDE
           _n2Saldo    +=SD7->D7_QTSEGUM
           _n1Liberados-=SD7->D7_QTDE
           _n2Liberados-=SD7->D7_QTSEGUM
        ELSEIF SD7->D7_TIPO = 7//ESTORNO DA REJEIÇÃO
           _n1Saldo    +=SD7->D7_QTDE
           _n2Saldo    +=SD7->D7_QTSEGUM
           _n1Rejetados-=SD7->D7_QTDE
           _n2Rejetados-=SD7->D7_QTSEGUM
        ENDIF

     ENDIF

	 (_cAlias)->(dbSkip())
	
    ENDDO

IF LEN(_aDados) = 0 
    U_ITMSG("Não há dados para essa seleção",'Atenção!',,1)
    (_cAlias)->(DBCloseArea())
    RETURN .F.
ENDIF

IF !(_cAlias)->(Eof()) .AND. MV_PAR06 = 1 // SINTETICO
   _aItens:={}
   REST15Sin()
   AADD(_aDados,ACLONE(_aItens))
ELSEIF MV_PAR06 = 1 // SINTETICO
   REST15Sin()
   AADD(_aDados,ACLONE(_aItens))//adiciona o ultimo
ENDIF   

DO WHILE LEN(_aDados) > 0 
   _aTit:={}
   _aSiz:={}

   IF MV_PAR06 = 2 // ANALITICO
      AADD(_aTit,'Numero') 
      AADD(_aSiz,20)
      AADD(_aTit,'Produto')
      AADD(_aSiz,90)
      AADD(_aTit,'Data')
      AADD(_aSiz,25)
      AADD(_aTit,'Tipo')
      AADD(_aSiz,40)
      AADD(_aTit,'Quantidade 1 UM')
      AADD(_aSiz,55)
      AADD(_aTit,'Saldo 1 UM')
      AADD(_aSiz,55)
      AADD(_aTit,'Quantidade 2 UM')
      AADD(_aSiz,55)
      AADD(_aTit,'Saldo 2 UM')
      AADD(_aSiz,35)
      AADD(_aTit,'Usuario')
      AADD(_aSiz,200)
      AADD(_aTit,'Motivo da Rejeicao')
      AADD(_aSiz,200)
      AADD(_aTit,'Obs ITALAC')
      AADD(_aSiz,60)

   ELSEIF MV_PAR06 = 1 // SINTETICO

      AADD(_aTit,'Numero') 
      AADD(_aSiz,20)
      AADD(_aTit,'Produto')
      AADD(_aSiz,90)
      AADD(_aTit,'Data')
      AADD(_aSiz,25)
   
      AADD(_aTit,'Qtde Original 1 UM')
      AADD(_aSiz,55)
      AADD(_aTit,'Qtde Liberada 1 UM')
      AADD(_aSiz,55)
      AADD(_aTit,'Qtde Rejeitada 1 UM')
      AADD(_aSiz,55)
      AADD(_aTit,'Saldo 1 UM')
      AADD(_aSiz,35)

      AADD(_aTit,'Qtde Original 2 UM')
      AADD(_aSiz,55)
      AADD(_aTit,'Qtde Liberada 2 UM')
      AADD(_aSiz,55)
      AADD(_aTit,'Qtde Rejeitada 2 UM')
      AADD(_aSiz,55)
      AADD(_aTit,'Saldo 2 UM')
      AADD(_aSiz,35)

      AADD(_aTit,'Motivo da Rejeicao')
      AADD(_aSiz,200)
      AADD(_aTit,'Obs ITALAC')
      AADD(_aSiz,60) 
   ENDIF

   _cMsgTop:="Tranferencias encontrados - H.I.: "+cTimeInicial+" H.F.: "+TIME()

   _cTitulo:="Par. 1 : "+DTOC(MV_PAR01)+"; Par. 2 : "+DTOC(MV_PAR02)+"; Par. 3 : "+ALLTRIM(MV_PAR03)+"; Par. 4 : "+ALLTRIM(STR(MV_PAR04))+;
           "; Par. 5 : "+ALLTRIM(MV_PAR05)+"; Par. 6 : "+ALLTRIM(STR(MV_PAR06))
           
   bOk:={|| IF(U_ITMSG("Confirma Gerar EXCEL ?",'Atenção!',,2,2,2) , DlgToExcel( { { "ARRAY" , _cTitulo , _aTit , _aDados } } )  ,.F. )   }

   //                           , _aCols  ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons )
      U_ITListBox(_cTitulo,_aTit,_aDados  , .T.    , 3    ,_cMsgTop,          ,_aSiz   ,         , bOk ,        , )
                                                                                                  

   IF  !U_ITMSG("Confirma Sair ?",'Atenção!',,3,2,2)
       LOOP
   ENDIF

    EXIT

ENDDO

(_cAlias)->(DBCloseArea())

Return .T.

/*
===============================================================================================================================
Programa----------: REST15Sin
Autor-------------: Alex Wallauer
Data da Criacao---: 29/04/2019
===============================================================================================================================
Descrição---------: Função para GRava as somas dos vlaores do relatorio Sintetico
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function REST15Sin()

AADD(_aItens,_cNumero)
AADD(_aItens,ALLTRIM(_cProduto)+" - "+POSICIONE("SB1",1,xfilial("SB1")+_cProduto,"B1_I_DESCD") )
AADD(_aItens,DTOC(_cData))

AADD(_aItens,Transform(_n1Origem   ,PesqPict("SD7","D7_QTDE")))
AADD(_aItens,Transform(_n1Liberados,PesqPict("SD7","D7_QTDE")))
AADD(_aItens,Transform(_n1Rejetados,PesqPict("SD7","D7_QTDE")))
AADD(_aItens,Transform(_n1Saldo    ,PesqPict("SD7","D7_SALDO")))

AADD(_aItens,Transform(_n2Origem   ,PesqPict("SD7","D7_QTSEGUM")))
AADD(_aItens,Transform(_n2Liberados,PesqPict("SD7","D7_QTSEGUM")))
AADD(_aItens,Transform(_n2Rejetados,PesqPict("SD7","D7_QTSEGUM")))
AADD(_aItens,Transform(_n2Saldo    ,PesqPict("SD7","D7_SALDO2")))

AADD(_aItens,_cMotRej)
AADD(_aItens,_cObsItal)

_cNumero :=SD7->D7_NUMERO
_cProduto:=SD7->D7_PRODUTO
_cData   :=SD7->D7_DATA

_n1Origem:=0
_n1Liberados:=0
_n1Rejetados:=0
_n1Saldo:=0

_n2Origem:=0
_n2Liberados:=0
_n2Rejetados:=0
_n2Saldo:=0

RETURN .T.
