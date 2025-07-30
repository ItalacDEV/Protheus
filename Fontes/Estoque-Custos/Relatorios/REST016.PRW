/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |08/10/2024| Chamado 48465. Retirada manipulação do SX1
===============================================================================================================================
*/
#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'
/*
===============================================================================================================================
Programa----------: REST016
Autor-------------: Alex Wallauer
Data da Criacao---: 30/04/2019
===============================================================================================================================
Descrição---------: Relatório de Listagem de OPs ITALAC
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function REST016()

_SelSB1:="(SELECT SB1.B1_I_DESCD FROM "+RETSQLNAME("SB1")+" SB1 WHERE D_E_L_E_T_ = ' ' AND SB1.B1_COD = SC2.C2_PRODUTO) DESCD "
_cSelePSC2:="SELECT DISTINCT C2_PRODUTO,"+_SelSB1+" FROM "+RETSQLNAME("SC2")+" SC2 WHERE D_E_L_E_T_ = ' ' AND C2_FILIAL = '"+xFilial("SC2")+"' ORDER BY C2_PRODUTO " 
                                                                           
_aItalac_F3:={}//       1           2         3                      4                      5                6                         7         8          9         10         11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave               , _nCpoDesc              ,_bCondTab    , _cTitAux                , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR05" ,_cSelePSC2,{|Tab| (Tab)->C2_PRODUTO}, {|Tab|(Tab)->DESCD}    ,             ,"Produtos"               ,          ,          ,30        ,.T.        ,       , } )

DO WHILE .T.
   If !Pergunte("REST016",.T.)
      return
   EndIf

    IF EMPTY(MV_PAR01) .OR. EMPTY(MV_PAR02) .OR. MV_PAR02 < MV_PAR01
       U_ITMSG("Datas invalidas ou não preenchidas",'Atenção!',"Preencha as 2 datas e a final maior ou igual a inicial",1)
       LOOP
    ENDIF

   cTimeInicial:=TIME()

   FWMSGRUN( ,{|oProc|  REST016R(oProc) } , "SC2 - Hora Inicial: "+cTimeInicial+", Aguarde...",  )

  ENDDO 

U_ITLOGACS( "REST016" )

Return


/*
===============================================================================================================================
Programa----------: REST016R
Autor-------------: Alex Wallauer
Data da Criacao---: 30/04/2019
===============================================================================================================================
Descrição---------: Função que imprime o relatório
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function REST016R(oProc)
Local cQry1		:= "" , P
LOCAL _cAlias  := GetNextAlias()

   oProc:cCaption :=  "Selecionando OP's, Aguarde... "
   ProcessMessages()

cQry1 := "SELECT  R_E_C_N_O_ RECSC2 "
cQry1 += "FROM " + RetSqlName("SC2") + " SC2  "
cQry1 += " WHERE SC2.C2_FILIAL = '"+xFilial("SC2")+" ' "


IF !EMPTY(MV_PAR02)
   cQry1 += "AND C2_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "'"
ElseIf !EMPTY(MV_PAR01)
   cQry1 += "AND C2_EMISSAO >= '" + DtoS(MV_PAR01) + "'"
ENDIF   

If !Empty(MV_PAR03)
	cQry1 += " AND C2_CC IN "+FormatIn(ALLTRIM(MV_PAR03),";")
EndIf

If MV_PAR04 = 1//'S' Encerradas: C2_DATRF <> ' '
   cQry1 += " AND C2_DATRF <> ' ' "
ELSEIf MV_PAR04 = 2//'N' ABERTAS : C2_DATRF = ' '
   cQry1 += " AND C2_DATRF = ' ' "
EndIf
	
If !Empty(MV_PAR05)
	cQry1 += " AND C2_PRODUTO IN "+FormatIn(ALLTRIM(MV_PAR05),";")
EndIf

cQry1 += " AND SC2.D_E_L_E_T_ = ' ' "
cQry1 += " ORDER BY C2_FILIAL, C2_NUM , C2_ITEM , C2_SEQUEN , C2_PRODUTO "

//crio o novo alias
MPSysOpenQuery( cQry1, _cAlias ) 

nTotal:=nConta:=0
dbSelectArea(_cAlias)
COUNT TO nTotal
(_cAlias)->(dbGoTop())
SC2->(DBGOTO((_cAlias)->RECSC2))
_aDados:={}
nTotal:=ALLTRIM(STR(nTotal))
nTam:=LEN(nTotal)+1
SCR->(DBSETORDER(1))

_aProd:={}
_aUM:={}

DO While !(_cAlias)->(Eof())

   SC2->(DBGOTO((_cAlias)->RECSC2))
   nConta++
   oProc:cCaption :=  "Lendo "+STRZERO(nConta,nTam)+" de "+nTotal +" - Lendo OP " +SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)
   ProcessMessages()
   
   _aItens:={}
   AADD(_aItens,SC2->(C2_NUM+C2_ITEM+C2_SEQUEN))
   AADD(_aItens,ALLTRIM(SC2->C2_PRODUTO)+" - "+POSICIONE("SB1",1,xfilial("SB1")+SC2->C2_PRODUTO,"B1_I_DESCD") )
   AADD(_aItens,ALLTRIM(SC2->C2_CC)+" - "+POSICIONE("CTT",1,xfilial("CTT")+SC2->C2_CC,"CTT_DESC01"))
   AADD(_aItens,Transform(SC2->C2_QUANT   ,PESQPICT("SC2","C2_QUANT")))
   AADD(_aItens,SC2->C2_UM)
   AADD(_aItens,DTOC(SC2->C2_EMISSAO))
   AADD(_aItens,Transform(SC2->C2_QUJE  ,PesqPict("SC2","C2_QUJE")))
   AADD(_aItens,Transform(SC2->C2_QUANT -SC2->C2_QUJE,PesqPict("SC2","C2_QUJE")))
        
   AADD(_aDados,ACLONE(_aItens))

   IF (_nPos:=ASCAN(_aProd,{|P| P[1] == SC2->C2_PRODUTO })) = 0
      AADD(_aProd,{SC2->C2_PRODUTO,SC2->C2_QUANT} )
   ELSE
      _aProd[_nPos,2]+=SC2->C2_QUANT
   ENDIF
   IF (_nPos:=ASCAN(_aUM,{|P| P[1] == SC2->C2_UM })) = 0
      AADD(_aUM,{SC2->C2_UM,SC2->C2_QUANT} )
   ELSE
      _aUM[_nPos,2]+=SC2->C2_QUANT
   ENDIF

   (_cAlias)->(dbSkip())
	
ENDDO

FOR P := 1 TO LEN(_aProd)
   _aItens:={}
   AADD(_aItens,"")
   AADD(_aItens,ALLTRIM(_aProd[P,1])+" - "+POSICIONE("SB1",1,xfilial("SB1")+_aProd[P,1],"B1_I_DESCD") )
   AADD(_aItens,"Total do Produto")
   AADD(_aItens,Transform(_aProd[P,2]   ,"@E 9999,999,999,999.999"))
   AADD(_aItens,"")
   AADD(_aItens,"")
   AADD(_aItens,"")
   AADD(_aItens,"")
   AADD(_aDados,ACLONE(_aItens))
NEXT
FOR P := 1 TO LEN(_aUM)
   _aItens:={}
   AADD(_aItens,"")
   AADD(_aItens,ALLTRIM(_aUM[P,1])+" - "+POSICIONE("SAH",1,xfilial("SAH")+_aUM[P,1],"AH_DESCPO") )
   AADD(_aItens,"Total da Unidade")
   AADD(_aItens,Transform(_aUM[P,2]   ,"@E 9999,999,999,999.999"))
   AADD(_aItens,"")
   AADD(_aItens,"")
   AADD(_aItens,"")
   AADD(_aItens,"")
   AADD(_aDados,ACLONE(_aItens))
NEXT

IF LEN(_aDados) = 0 
    U_ITMSG("Não há dados para essa seleção",'Atenção!',,3)
ENDIF

DO WHILE LEN(_aDados) > 0 
   _aTit:={}
   _aSiz:={}

//C2_NUM+C2_ITEM+C2_SEQUEN (NUMERO OP), C2_PRODUTO, C2_I_DESC, C2_CC, C2_QUANT, C2_UM, C2_EMISSAO, C2_QUJE (QTDE APONTADA), C2_QUANT -C2_QUJE (SALDO)

      AADD(_aTit,'Numero OP') 
      AADD(_aSiz,20)
      AADD(_aTit,'Produto')
      AADD(_aSiz,70)
      AADD(_aTit,'Centro de Custo')
      AADD(_aSiz,90)
      AADD(_aTit,'Quantidade')
      AADD(_aSiz,55)
      AADD(_aTit,'UM')
      AADD(_aSiz,20)
      AADD(_aTit,'Data')
      AADD(_aSiz,50)
      AADD(_aTit,'Qtde Apontada')
      AADD(_aSiz,45)
      AADD(_aTit,'Saldo')
      AADD(_aSiz,45)


   _cMsgTop:="OPs encontrados - H.I.: "+cTimeInicial+" H.F.: "+TIME()

   _cTitulo:="Par. 1 : "+DTOC(MV_PAR01)+"; Par. 2 : "+DTOC(MV_PAR02)+"; Par. 3 : "+ALLTRIM(MV_PAR03)+"; Par. 4 : "+ALLTRIM(STR(MV_PAR04))+;
           "; Par. 5 : "+ALLTRIM(MV_PAR05)
           
   bOk:={|| IF(U_ITMSG("Confirma Gerar EXCEL ?",'Atenção!',,2,2,2) , DlgToExcel( { { "ARRAY" , _cTitulo , _aTit , _aDados } } )  ,.F. )   }

   //                           , _aCols  ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons )
      U_ITListBox(_cTitulo,_aTit,_aDados  , .T.    , 3    ,_cMsgTop,          ,_aSiz   ,         , bOk ,        , )
                                                                                                  

   IF  !U_ITMSG("Confirma Sair ?",'Atenção!',,3,2,2)
       LOOP
   ENDIF

    EXIT

ENDDO

Return
