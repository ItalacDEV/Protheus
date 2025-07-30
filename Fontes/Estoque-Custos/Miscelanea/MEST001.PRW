/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |07/05/2025| Chamado 50617. Corrigir chamada estática no nome das tabelas do sistema
===============================================================================================================================
Analista       - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
================================================================================================================================================================================================
Andre          - Alex Wallauer - 14/10/24 - 14/10/24 - 48840   - Ajustes dos titulos e mensagens.
Lucas          - Alex Wallauer - 02/05/25 - 06/05/25 - 50525   - Ajuste para remoção de diretório local C:\SMARTCLIENT\.
================================================================================================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa--------: MEST001
Autor-----------: Alex Wallauer
Data da Criacao-: 23/09/2021
Descrição-------: Rotina para verificar e ajustar problemas nos saldos empenhados das SAs- Chamado 37834
Parametros------: NENHUM
Retorno---------: NENHUM
===============================================================================================================================
*/
USER FUNCTION MEST001()
Local _aParRet :={} , nI
Local _aParAux :={} 
Local _bOK     :={||.T. }

Private _cAlias1	:= GetNextAlias()

_cSelectSB1:="SELECT B1_COD , B1_TIPO, B1_DESC FROM "+RETSQLNAME("SB1")+" SB1 WHERE D_E_L_E_T_ = ' ' AND B1_MSBLQL <> '1' ORDER BY B1_COD "
_aItalac_F3:={}//       1           2         3                      4                      5               6                    7         8          9         10         11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela ,_nCpoChave              , _nCpoDesc              ,_bCondTab    , _cTitAux         , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR01" ,_cSelectSB1,{|Tab|(Tab)->B1_COD},{|Tab|(Tab)->B1_TIPO+" "+(Tab)->B1_DESC}, ,"Produtos"        ,          ,          , 1        ,.F.        ,       , } )

MV_PAR01:=SPACE(20)
AADD( _aParAux , { 1 , "Produto"	      , MV_PAR01, "@!"	, ""	, "F3ITLC"  , "" , 060 , .F. } )
For nI := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nI][03] )
Next nI

DO WHILE .T.

   IF !ParamBox( _aParAux , "Digite o produto com Problema" , @_aParRet, _bOK )
       EXIT
   EndIf
   
   cTimeInicial:=TIME()
   MV_PAR01:=ALLTRIM(MV_PAR01)
   _cLogQry:=""
   aLog := {}
   lRet :=.T.
   SB2->(Dbsetorder(1))//B2_FILIAL+B2_COD+B2_LOCAL
   
   FWMSGRUN( ,{|oProc|  lRet:=GeraLog(oProc) } , "Hora Inicial: "+cTimeInicial+" - Produto: "+MV_PAR01 )
    
   IF LEN(aLog) > 0
      
      aTitCol:={}
      AADD(aTitCol,"TABELA")
      AADD(aTitCol,"PRODUTO")
      AADD(aTitCol,"D3_NUMSA ")
      AADD(aTitCol,"D3_ITEMSA") 
      AADD(aTitCol,"D3_QUANT")
      AADD(aTitCol,"CQ_QUANT") 
      AADD(aTitCol,"CQ_NUM ")   
      AADD(aTitCol,"CQ_ITEM")
      AADD(aTitCol,"CQ_NUMREQ")
      AADD(aTitCol,"D3_NUMSEQ")
      AADD(aTitCol,"D3_EMISSAO")
      AADD(aTitCol,"D3_ESTORNO")
      AADD(aTitCol,"D3_LOCAL")
      AADD(aTitCol,"D3_TM")
      AADD(aTitCol,"REC_SD3")
      AADD(aTitCol,"REC_SCQ")
      
      cTit1:="Log (MEST001) Produto: "+IF(!EMPTY(MV_PAR01),MV_PAR01,"Todos com problema na base")
      cTit2:="Produto: "+IF(!EMPTY(MV_PAR01),MV_PAR01,"Todos com problema na base")+" / Hr Ini: "+cTimeInicial+" Hr final "+TIME()+" / Clique em Confirmar para gravar o CQ_NUMREQ e B2_QEMPSA! "
      _lOK:=.F.
      bOk:={|_oDlg| IF(_lOK:= U_ITMSG("Confirma Gravar os dados ?",'Atenção!',,2,2,2) ,_oDlg:End(), ) }
   
    //                             , _aCols,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons )
      U_ITListBox(cTit1,aTitCol,aLog   ,.T.     ,1     ,cTit2    ,         ,        ,         , bOk )
      
      IF _lOK//Grava os dados
         _lOK:=.F.
        (_cAlias1)->(DBGOTOP())
        DO WHILE !(_cAlias1)->(EOF())

           SD3->(Dbgoto((_cAlias1)->REC_SD3))
           SCQ->(Dbgoto((_cAlias1)->REC_SCQ))
           
  	        IF SB2->(Dbseek(SD3->D3_FILIAL+SD3->D3_COD+SD3->D3_LOCAL)) .AND. SB2->B2_QEMPSA >= SD3->D3_QUANT
              SB2->(RecLock( "SB2" , .F. )) 
              SB2->B2_QEMPSA:=(SB2->B2_QEMPSA-SD3->D3_QUANT)
              SB2->(MsUnlock()) 
              _lOK:=.T.
           ELSE
              (_cAlias1)->(Dbskip())
              LOOP   
           ENDIF

           SCQ->(RecLock( "SCQ" , .F. )) 
           SCQ->CQ_NUMREQ:=SD3->D3_NUMSEQ
           SCQ->(MsUnlock()) 

           (_cAlias1)->(Dbskip())
	
        Enddo
         IF _lOK
            U_ITMSG("Dados gravados com SUCESSO para o PRODUTO: "+MV_PAR01,"Atencao!",,2)
         ELSE
            U_ITMSG("NAO Gravou para o PRODUTO: "+MV_PAR01,"Atencao!",,3)
         ENDIF
         
         EXIT   
      ENDIF
   
   ELSE
   
      U_ITMSG("Nao foi encontrado dados para esse PRODUTO: "+MV_PAR01,"Atencao!",,3)
   
   ENDIF

ENDDO

If Select(_cAlias1) > 0
   (_cAlias1)->( dbCloseArea() )
EndIf

Return .T.

/*
===============================================================================================================================
Programa----------: GeraLog
Autor-------------: Alex Wallauer
Data da Criacao---: 23/09/2021
Descrição---------: Geração do Log de mão de obra 
Parametros--------: oproc - objeto da barra de processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function GeraLog(OPROC)
Local _cQry:=""

IF oproc <> nil
   oproc:cCaption := "Lendo SCQ/SD3... "
   ProcessMessages()
ENDIF

_cQry+= "SELECT D3_FILIAL, D3_NUMSA, D3_ITEMSA, D3_COD, D3_QUANT, CQ_QUANT, CQ_NUM, CQ_PRODUTO, CQ_ITEM, CQ_NUMREQ, D3_EMISSAO, D3_ESTORNO, D3_TM, D3_NUMSEQ, D3_LOCAL, D3.R_E_C_N_O_ REC_SD3 , CQ.R_E_C_N_O_ REC_SCQ "
_cQry+= "FROM "+RETSQLNAME("SD3")+" D3 "
_cQry+= "JOIN "+RETSQLNAME("SCQ")+" CQ ON D3_FILIAL = CQ_FILIAL AND D3_NUMSA = CQ_NUM AND D3_ITEMSA = CQ_ITEM "
_cQry+= "WHERE D3.D_E_L_E_T_ = ' ' " 
_cQry+= "AND CQ.D_E_L_E_T_ = ' ' "
_cQry+=" AND D3_FILIAL = '"+cFilAnt+"' "
_cQry+= "AND D3_ESTORNO <> 'S' "
_cQry+= "AND CQ_NUMREQ = ' ' "
IF !EMPTY(MV_PAR01)
   _cQry+= "AND CQ_PRODUTO = '"+MV_PAR01+"' "
ENDIF
_cQry+= "ORDER BY D3_FILIAL, D3_NUMSA, D3_ITEMSA "

_cLogQry:=_cQry+CRLF

If Select(_cAlias1) > 0
   (_cAlias1)->( dbCloseArea() )
EndIf

_cQry := ChangeQuery(_cQry)
MPSysOpenQuery(_cQry,_cAlias1)

(_cAlias1)->(Dbgotop())                           

DO WHILE !((_cAlias1)->(EOF()))

   IF oproc <> nil
	  oproc:cCaption := "Listando SCQ/SD3... "
	  ProcessMessages()
   ENDIF


   aLogAux:={}
   AADD(aLogAux,"SQC/SD3")
   AADD(aLogAux,ALLTRIM((_cAlias1)->D3_COD)+" - "+ALLTRIM(POSICIONE("SB1",1,xfilial("SB1")+(_cAlias1)->D3_COD,"B1_DESC")) ) 
   AADD(aLogAux,(_cAlias1)->D3_NUMSA  )
   AADD(aLogAux,(_cAlias1)->D3_ITEMSA ) 
   AADD(aLogAux,TRANS((_cAlias1)->D3_QUANT,"@E 99,999,999,999.999")  )
   AADD(aLogAux,TRANS((_cAlias1)->CQ_QUANT,"@E 99,999,999,999.999")  ) 
   AADD(aLogAux,(_cAlias1)->CQ_NUM    )   
   AADD(aLogAux,(_cAlias1)->CQ_ITEM   )
   AADD(aLogAux,(_cAlias1)->CQ_NUMREQ )
   AADD(aLogAux,(_cAlias1)->D3_NUMSEQ )
   AADD(aLogAux,DTOC(STOD((_cAlias1)->D3_EMISSAO)))
   AADD(aLogAux,(_cAlias1)->D3_ESTORNO)
   AADD(aLogAux,(_cAlias1)->D3_LOCAL)
   AADD(aLogAux,(_cAlias1)->D3_TM)
   AADD(aLogAux,(_cAlias1)->REC_SD3)
   AADD(aLogAux,(_cAlias1)->REC_SCQ)

   AADD(aLog,aLogAux)

  	SB2->(Dbseek((_cAlias1)->D3_FILIAL+(_cAlias1)->D3_COD+(_cAlias1)->D3_LOCAL))

   aLogAux:={}
   AADD(aLogAux,"SB2")
   AADD(aLogAux,ALLTRIM(SB2->B2_COD)+" - "+ALLTRIM(POSICIONE("SB1",1,xfilial("SB1")+SB2->B2_COD,"B1_DESC")) ) 
   AADD(aLogAux,'' )
   AADD(aLogAux,"B2_QEMPSA: ") 
   AADD(aLogAux,TRANS(SB2->B2_QEMPSA,"@E 99,999,999,999.999")  )
   AADD(aLogAux,""  ) 
   AADD(aLogAux,"")   
   AADD(aLogAux,"")
   AADD(aLogAux,"")
   AADD(aLogAux,"")
   AADD(aLogAux,"")
   AADD(aLogAux,"")
   AADD(aLogAux,SB2->B2_LOCAL)
   AADD(aLogAux,"Recno SB2:")
   AADD(aLogAux,SB2->(RECNO() ))
   AADD(aLogAux,0)

   AADD(aLog,aLogAux)

   (_cAlias1)->(Dbskip())
	
Enddo

Return .T.
