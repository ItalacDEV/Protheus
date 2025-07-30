/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Walauer  |11/04/2020| Chamado 39745. Correção da Inversão dos campos dos filtros MV_PAR04 e MV_PAR05 
Alex Walauer  |11/04/2023| Chamado 42499. Foi adicionado 2 novos filtros: "Situacao do Aprov." e "Lista Bloque./Rejeit."
Lucas Borges  |08/10/2024| Chamado 48465. Retirada manipulação do SX1
===============================================================================================================================
*/
#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'
/*
===============================================================================================================================
Programa----------: RCOM014
Autor-------------: Alex Wallauer
Data da Criacao---: 25/04/2019
===============================================================================================================================
Descrição---------: Relatório de pedidos de compra pendentes de aprovação
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RCOM014()

_cSelecSC7:="SELECT DISTINCT C7_NUM   , C7_EMISSAO FROM "+RETSQLNAME("SC7")+" SC7 WHERE C7_ENCER <> 'E' AND C7_RESIDUO <> 'S' AND D_E_L_E_T_ = ' ' AND C7_FILIAL = '"+xFilial("SC7")+"' ORDER BY C7_NUM " 
_cSelecSAL:="SELECT DISTINCT AL_COD   , AL_DESC   FROM "+RETSQLNAME("SAL")+" SAL WHERE D_E_L_E_T_ = ' ' ORDER BY AL_COD " 
_cSelecSAJ:="SELECT DISTINCT AJ_GRCOM             FROM "+RETSQLNAME("SAJ")+" SAJ WHERE D_E_L_E_T_ = ' ' ORDER BY AJ_GRCOM " 

_aItalac_F3:={}//       1           2         3                      4                      5          6                      7         8          9         10         11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave            , _nCpoDesc              ,_bCondTab    , _cTitAux           , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR03" ,_cSelecSC7,{|Tab| (Tab)->C7_NUM }, {|Tab|DTOC(STOD((Tab)->C7_EMISSAO))},,"Pedidos"           ,          ,          ,60        ,.T.        ,       , } )
AADD(_aItalac_F3,{"MV_PAR04" ,_cSelecSAL,{|Tab| (Tab)->AL_COD }, {|Tab|(Tab)->AL_DESC}  ,             ,"Grupo Aprovadores" ,          ,          ,          ,.T.        ,       , } )
AADD(_aItalac_F3,{"MV_PAR05" ,"SAK"     ,2                     ,4                       ,             ,"Aprovadores"} )
AADD(_aItalac_F3,{"MV_PAR06" ,_cSelecSAJ,{|Tab|(Tab)->AJ_GRCOM}, {|Tab|(Tab)->AJ_GRCOM} ,             ,"Grupo Compradores" ,          ,          ,          ,.T.        ,       , } )
AADD(_aItalac_F3,{"MV_PAR07" ,"SY1"     ,                      ,                        ,             ,"Compradores"} )

If !Pergunte("RCOM014",.T.)
   return
EndIf

U_ITLOGACS( "RCOM014" )

cTimeInicial:=TIME()

FWMSGRUN( ,{|oProc|  RCOM014R(oProc) } , "SC7 - Hora Inicial: "+cTimeInicial+", Aguarde...",  )

Return


/*
===============================================================================================================================
Programa----------: RCOM014R
Autor-------------: Alex Wallauer
Data da Criacao---: 25/04/2019
===============================================================================================================================
Descrição---------: Função que imprime o relatório
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RCOM014R(oProc)
Local cQry1		:= ""
LOCAL _cAlias  := GetNextAlias()

   oProc:cCaption :=  "Selelecionado Pedidos, Aguarde... "
   ProcessMessages()

cQry1 := "SELECT  C7_NUM, "
cQry1 += "        C7_EMISSAO, "
cQry1 += "        C7_PRODUTO, "
cQry1 += "        C7_QUANT, "
cQry1 += "        C7_PRECO, "
cQry1 += "        C7_DATPRF , "
cQry1 += "        C7_COMPRA ,"
cQry1 += "        C7_GRUPCOM, "
cQry1 += "        C7_TOTAL, "
cQry1 += "        R_E_C_N_O_ RECSC7 "
cQry1 += "FROM " + RetSqlName("SC7") + " SC7  "
cQry1 += " WHERE SC7.C7_FILIAL = '"+xFilial("SC7")+" ' "

IF !EMPTY(MV_PAR02)
   cQry1 += " AND C7_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "
ElseIf !EMPTY(MV_PAR01)
   cQry1 += " AND C7_EMISSAO >= '" + DtoS(MV_PAR01) + "' "
ENDIF   

cQry1 +=  " AND  SC7.C7_FILIAL||SC7.C7_NUM IN "
cQry1 +=  "  (SELECT CR_FILIAL||CR_NUM FROM " + RetSqlName("SCR") + " SCR 
cQry1 +=  "    WHERE CR_FILIAL = SC7.C7_FILIAL AND CR_NUM = SC7.C7_NUM  AND SCR.D_E_L_E_T_ = ' '  AND SCR.CR_DATALIB = ' ' "

If !Empty(MV_PAR04)
	cQry1 += " AND CR_GRUPO IN "+FormatIn(ALLTRIM(MV_PAR04),";")
EndIf
If !Empty(MV_PAR05)
	cQry1 += " AND CR_APROV IN "+FormatIn(ALLTRIM(MV_PAR05),";")
EndIf
cQry1 +=  "  )"

//Filtra grupo de compras
If !Empty(MV_PAR03)
	cQry1 += " AND C7_NUM IN "+FormatIn(ALLTRIM(MV_PAR03),";")
EndIf
	
//Filtra grupo de compras
If !Empty(MV_PAR06)
	cQry1 += " AND C7_GRUPCOM IN "+FormatIn(ALLTRIM(MV_PAR06),";")
EndIf

//Filtra comprador
If !Empty(MV_PAR07)
	cQry1 += " AND C7_COMPRA  IN "+FormatIn(ALLTRIM(MV_PAR07),";")
EndIf

cQry1 += "  AND SC7.D_E_L_E_T_ = ' ' AND C7_RESIDUO <> 'S' "
cQry1 += "ORDER BY C7_FILIAL, C7_NUM, C7_EMISSAO "

//crio o novo alias
MPSysOpenQuery( cQry1, _cAlias ) 

nTotal:=nConta:=0
dbSelectArea(_cAlias)
COUNT TO nTotal
(_cAlias)->(dbGoTop())
_aDados:={}
nTotal:=ALLTRIM(STR(nTotal))
nTam:=LEN(nTotal)+1
SCR->(DBSETORDER(1))

DO While !(_cAlias)->(Eof())

   nConta++
   oProc:cCaption :=  "Lendo "+STRZERO(nConta,nTam)+" de "+nTotal +" - Lendo Pedido " +(_cAlias)->C7_NUM
   ProcessMessages()   
   _dDtUltLib:=STOD((_cAlias)->C7_EMISSAO)
   _cObs:=""
   SCR->(DBSEEK(xfilial("SCR")+"PC"+ALLTRIM((_cAlias)->C7_NUM)))
   _cAprov:=SCR->CR_APROV
   _cGrupo:=SCR->CR_GRUPO
   _lLoop:=.F.
   DO WHILE SCR->(!EOF()) .AND. xfilial("SCR")+"PC"+ALLTRIM((_cAlias)->C7_NUM) == SCR->CR_FILIAL+SCR->CR_TIPO+ALLTRIM(SCR->CR_NUM)
      IF EMPTY(SCR->CR_DATALIB)//ULTIMO Pendente
         IF MV_PAR08 = 1 
            IF !SCR->CR_APROV $ ALLTRIM(MV_PAR05)
               _lLoop:=.T.
               EXIT
            ENDIF
         ENDIF
         _cAprov:=SCR->CR_APROV  
         _cGrupo:=SCR->CR_GRUPO
         EXIT
      Else
          IF SCR->CR_STATUS = "04"
             IF MV_PAR09 = 2 
                _lLoop:=.T.
                EXIT
             ENDIF
             _cObs:="Bloqueado por "+ALLTRIM(POSICIONE("SAK",1,xfilial("SAK")+SCR->CR_APROV,"AK_NOME"))+" ("+SCR->CR_GRUPO+")"
          ENDIF
          IF SCR->CR_STATUS = "06"
             IF MV_PAR09 = 2 
                _lLoop:=.T.
                EXIT
             ENDIF
             _cObs:="Rejeitado por "+ALLTRIM(POSICIONE("SAK",1,xfilial("SAK")+SCR->CR_APROV,"AK_NOME"))+" ("+SCR->CR_GRUPO+")"
          ENDIF
         _dDtUltLib:=SCR->CR_DATALIB
      ENDIF 
      _cAprov:=SCR->CR_APROV
      _cGrupo:=SCR->CR_GRUPO
      SCR->(DBSKIP()) 
   ENDDO
   
   IF _lLoop
	   (_cAlias)->(DBSKIP())
      LOOP
   ENDIF

   _aItens:={}
	AADD(_aItens,(_cAlias)->C7_NUM)
	AADD(_aItens,STOD((_cAlias)->C7_EMISSAO))
	AADD(_aItens,ALLTRIM((_cAlias)->C7_PRODUTO)+" - "+POSICIONE("SB1",1,xfilial("SB1")+(_cAlias)->C7_PRODUTO,"B1_DESC") )
	AADD(_aItens,Transform((_cAlias)->C7_QUANT,PesqPict("SC7","C7_QUANT")))
	AADD(_aItens,Transform((_cAlias)->C7_TOTAL,PesqPict("SC7","C7_TOTAL")))
	AADD(_aItens,STOD((_cAlias)->C7_DATPRF))
	AADD(_aItens,_cAprov+" - "+ALLTRIM(POSICIONE("SAK",1,xfilial("SAK")+_cAprov,"AK_NOME"))+" ("+SCR->CR_GRUPO+")" )
	AADD(_aItens,_dDtUltLib)
	AADD(_aItens,ALLTRIM(STR( ( DATE()-STOD((_cAlias)->C7_EMISSAO) )  ) ))  
	AADD(_aItens,(_cAlias)->C7_COMPRA +" - "+ALLTRIM(POSICIONE("SY1",1,xfilial("SY1")+(_cAlias)->C7_COMPRA,"Y1_NOME"))+" ("+(_cAlias)->C7_GRUPCOM+")" )
	AADD(_aItens,_cObs)
	AADD(_aItens,(_cAlias)->RECSC7)

   AADD(_aDados,_aItens)
	(_cAlias)->(dbSkip())
ENDDO

IF LEN(_aDados) = 0 
    U_ITMSG("Não há dados para essa seleção",'Atenção!',,3)
ENDIF

DO WHILE LEN(_aDados) > 0 
   _aTit:={}
   _aSiz:={}

   AADD(_aTit,'Pedido') 
   AADD(_aSiz,20)
   AADD(_aTit,'Emissao')
   AADD(_aSiz,25)
   AADD(_aTit,'Produto')
   AADD(_aSiz,100)
   AADD(_aTit,'Quantidade')
   AADD(_aSiz,35)
   AADD(_aTit,'Valor')
   AADD(_aSiz,30)
   AADD(_aTit,'Entrega')
   AADD(_aSiz,20)
   AADD(_aTit,'Aprovador Pendente')
   AADD(_aSiz,150)
   AADD(_aTit,'Pendente desde')
   AADD(_aSiz,50)
   AADD(_aTit,'Dias Pendente')
   AADD(_aSiz,50)
   AADD(_aTit,'Comprador')
   AADD(_aSiz,150)
   AADD(_aTit,'Obeservacao')
   AADD(_aSiz,200)
   AADD(_aTit,'Registro')
   _nCampo:=LEN(_aTit)
   AADD(_aSiz,20)

   _cMsgTop:="Pedidos encontrados - H.I.: "+cTimeInicial+" H.F.: "+TIME()

   _cTitulo:="Par. 1 : "+DTOC(MV_PAR01)+"; Par. 2 : "+DTOC(MV_PAR02)+"; Par. 3 : "+ALLTRIM(MV_PAR03)+"; Par. 4 : "+ALLTRIM(MV_PAR04)+;
           "; Par. 5 : "+ALLTRIM(MV_PAR05)+"; Par. 6 : "+ALLTRIM(MV_PAR06)+"; Par. 7 : "+ALLTRIM(MV_PAR07)
   _aBbuttons:={}
	AADD(_aBbuttons,{"",{|| U_RCOM014AP()},"","Consulta Aprovadores"}) 
	AADD(_aBbuttons,{"",{|| U_RCOM014V() },"","Visualizar Pedido de Compras"}) 
   
   
   bOk:={|| IF(U_ITMSG("Confirma Gerar EXCEL ?",'Atenção!',,2,2,2) , DlgToExcel( { { "ARRAY" , _cTitulo , _aTit , _aDados } } )  ,.F. )   }

   //                           , _aCols  ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _aBbuttons )
      U_ITListBox(_cTitulo,_aTit,_aDados  , .T.    , 3    ,_cMsgTop,          ,_aSiz   ,         , bOk ,        , _aBbuttons )
                                                                                                  

   IF  !U_ITMSG("Confirma Sair ?",'Atenção!',,3,2,2)
       LOOP
   ENDIF

    EXIT

ENDDO

Return

/*
===============================================================================================================================
Programa----------: RCOM014AP
Autor-------------: Alex Wallauer
Data da Criacao---: 11/01/2023
===============================================================================================================================
Descrição---------: Consulta Aprovadores
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER Function RCOM014AP()
LOCAL _nRec:=oLbxAux:aArray[oLbxAux:nAt][_nCampo]

IF _nRec > 0
   SC7->(DBGOTO(_nRec))
   aRotina := {{"XX","XX",0,2,0,NIL}}
   a120Posic("SC7",SC7->(RECNO()),1,IF(SC7->C7_TIPO == 1,'PC','AE'),.F.,.F.)
ENDIF

RETURN .T.

/*
===============================================================================================================================
Programa----------: RCOM014V
Autor-------------: Alex Wallauer
Data da Criacao---: 11/01/2023
===============================================================================================================================
Descrição---------: Função utilizada para visualizar Pedido de Compras A120Pedido()
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RCOM014V()
Local aArea	
LOCAL _nRec:=oLbxAux:aArray[oLbxAux:nAt][_nCampo]

IF _nRec > 0

   aArea:= GetArea()

   SC7->(DBGOTO(_nRec))
   l120Auto	:= .F.
   cCadastro:= "Pedido de Compras"
   nTipoPed	:= 1
   Inclui   :=.F.
   Altera   :=.F.
   aRotina  := {{"XX","XX",0,2,0,NIL}}

   A120Pedido("SC7",SC7->(Recno()),1)

   RestArea(aArea)

ENDIF

Return
