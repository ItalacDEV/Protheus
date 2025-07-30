/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO                             
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Jerry        | 27/06/2023 | Chamado 43761. Adicionado novas Colunas.
 Alex Wallauer| 15/09/2023 | Chamado 44503. Tratamento para as novas colunas de Subsegmento.
==============================================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
Alex     - Igor Melgaço  - 02/05/25 - 06/05/25 -  50525  - Ajuste para remoção de diretório local C:\SMARTCLIENT\.
==============================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include 'protheus.ch'
#include "topconn.ch"
#DEFINE ENTER CHR(13)+CHR(10)


/*
===============================================================================================================================
Programa--------: ROMS065
Autor-----------: Alex Wallauer
Data da Criacao-: 28/10/2021
===============================================================================================================================
Descrição-------: Lista clientes por Gerente / Vendedor - CHAMADO 38081
===============================================================================================================================
Parametros------: NENHUM
===============================================================================================================================
Retorno---------: NENHUM
===============================================================================================================================
*/

USER FUNCTION ROMS065()//U_ROMS065
Local _aParRet :={} , nI 
Local _aParAux :={} 
Local _bOK     :={||.T. }

Private _cAlias1	:= GetNextAlias()
_aItalac_F3:={}
//_cSelectSB1:="SELECT DISTINCT A1_COD, A1_NOME, A1_MSBLQL FROM "+RETSQLNAME("SB1")+" SB1 WHERE "+IF(MV_PAR07="1","A1_MSBLQL <> '1'", "A1_MSBLQL = '1'" )+" AND D_E_L_E_T_ <> '*' ORDER BY A1_COD " 
_bSelectSA1:={|| "SELECT DISTINCT A1_COD, A1_NOME, A1_MSBLQL FROM "+RETSQLNAME("SA1")+" SA1 WHERE "+IF(MV_PAR07="2","A1_MSBLQL = '1'", "A1_MSBLQL <> '1'" )+" AND D_E_L_E_T_ <> '*' ORDER BY A1_COD "  }
_bCondSA1  :={|| IF(MV_PAR07="2",(A1_MSBLQL = "1"),(A1_MSBLQL <> "1")) }
//AADD(_aItalac_F3,{"MV_PAR01","SA1",SA1->(FIELDPOS("A1_COD")),{|| SA1->A1_LOJA+"-"+SA1->A1_NOME } ,_bCondSA1 ,"Clientes",,,} )
AADD(_aItalac_F3,{"MV_PAR01",_bSelectSA1,{|Tab| ALLTRIM((Tab)->A1_COD) }, {|Tab| "["+(Tab)->A1_MSBLQL+"] "+(Tab)->A1_NOME } ,_bCondSA1 ,"Clientes",,,,.F.        ,       , } )

//AD(_aItalac_F3,{"1CPO_PO1",_cTab,_nCpoChave               , _nCpoDesc                          ,_bCondTab , _cTitAux      , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
_bCondTab:={|| SA3->A3_I_TIPV = 'V' }//
AADD(_aItalac_F3,{"MV_PAR04","SA3",SA3->(FIELDPOS("A3_COD")), SA3->(FIELDPOS("A3_NOME"))  ,_bCondTab ,"Representantes",,,} )

MV_PAR01:=SPACE(350)
MV_PAR02:=SPACE(250)
MV_PAR03:=SPACE(250)
MV_PAR04:=SPACE(250)
MV_PAR05:=SPACE(150)
MV_PAR06:=DATE()
MV_PAR07:="1-Sim"

AADD( _aParAux , { 1 , "Clientes"        , MV_PAR01, "@!"  , ""    , "F3ITLC"    , "" , 100 , .F. } )
AADD( _aParAux , { 1 , "Gerentes"        , MV_PAR02, "@!"  , ""    , "LSTGER"    , "" , 100 , .F. } )//SA3.A3_I_TIPV = 'G'
AADD( _aParAux , { 1 , "Coordenadores"   , MV_PAR03, "@!"  , ""    , "LSTSUP"    , "" , 100 , .F. } )//SA3.A3_I_TIPV = 'C'
AADD( _aParAux , { 1 , "Representantes"  , MV_PAR04, "@!"  , ""    , "F3ITLC"    , "" , 100 , .F. } )//SA3.A3_I_TIPV = 'V'
AADD( _aParAux , { 1 , "UFs"             , MV_PAR05, "@!"  , ""    , "LSTEST"    , "" , 100 , .F. } )
AADD( _aParAux , { 1 , "Data Emiss PV/NF", MV_PAR06, "@D"	 , ""	   , ""		       , "" , 050 , .T. } )
AADD( _aParAux , { 2 , "Situacao"        , MV_PAR07, {"1-ATIVO","2-BLOQUEADO","3-AMBOS"}, 090 ,".T.",.T. } )

For nI := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nI][03] )
Next nI

DO WHILE .T.

             //aParametros, cTitle                                , @aRet    ,[bOk], [ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ] 
   IF !ParamBox( _aParAux , "Lista clientes por gerente/vendedor" , @_aParRet, _bOK, /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
       EXIT
   EndIf
   
   cTimeInicial:=TIME()
   MV_PAR01:=ALLTRIM(MV_PAR01)
   MV_PAR02:=ALLTRIM(MV_PAR02)
   MV_PAR03:=ALLTRIM(MV_PAR03)
   MV_PAR04:=ALLTRIM(MV_PAR04)
   MV_PAR05:=ALLTRIM(MV_PAR05)
   _cLogQry:=""
   aLog := {}
   aGrava := {}
   lRet :=.T.
   SA2->(Dbsetorder(1))//
   _cTot:=""   
   FWMSGRUN( ,{|oProc|  lRet:=GeraDados(oProc) } , "Hora Inicial: "+cTimeInicial+" - Clientes: "+IF(EMPTY(MV_PAR01),"Todos",MV_PAR01) )
    IF !lRet
       LOOP
    ENDIF
   
   IF LEN(aLog) > 0
      
      aTitCol:={}
      AADD(aTitCol,"CODGER"  )          
      AADD(aTitCol,"GERENTE" )          
      AADD(aTitCol,"COORD" )           
      AADD(aTitCol,"COORDENADOR")   
      AADD(aTitCol,"COD SUP."  )       
      AADD(aTitCol,"SUPERVISOR")       

      AADD(aTitCol,"TIPO REP 1"  )     
      AADD(aTitCol,"CODREP 1"  )     
      AADD(aTitCol,"REPRESENTANTE 1")     
      AADD(aTitCol,"NOME REPRESENTANTE 1")
      AADD(aTitCol,"REGRA COMISSAO 1")

      AADD(aTitCol,"TIPO REP 2"  )     
      AADD(aTitCol,"CODREP 2"  )        
      AADD(aTitCol,"REPRESENTANTE 2")   
      AADD(aTitCol,"NOME REPRESENTANTE 2")      
      AADD(aTitCol,"REGRA COMISSAO 2")      

      AADD(aTitCol,"COD" )              
      AADD(aTitCol,"LOJA")              
      AADD(aTitCol,"PESSOA"  )          
      AADD(aTitCol,"CNPJ"  )            
      AADD(aTitCol,"REDE"  )            
      AADD(aTitCol,"NOME DA REDE")      
      AADD(aTitCol,"RAZAO SOCIAL" )     
      AADD(aTitCol,"NOME REDUZIDO" )    
      AADD(aTitCol,"CIDADE"   )         
      AADD(aTitCol,"UF"  )              
      AADD(aTitCol,"CEP"  )             
      AADD(aTitCol,"ENDERECO"    )      
      AADD(aTitCol,"REGIAO DE VENDA"  ) 
      AADD(aTitCol,"REGIONAL"  )       
      AADD(aTitCol,"DDD"  )             
      AADD(aTitCol,"TELEFONE")          
      AADD(aTitCol,"COD SEG."  )        
      AADD(aTitCol,"SEGMENTO"  )  

      AADD(aTitCol,"COD SUBSEG."  )        
      AADD(aTitCol,"SUBSEGMENTO"  )  

      AADD(aTitCol,"DT 1A COMP" )       
      AADD(aTitCol,"DT ULT COMP"  )     
      AADD(aTitCol,"DT ULT AVALIACAO" ) 
      AADD(aTitCol,"DT INCLUSAO" )  
      AADD(aTitCol,"DT_ULT_NOTA")   

      AADD(aTitCol,"SITUACAO")          
      AADD(aTitCol,"CONTRIBUINTE"  )    
      AADD(aTitCol,"OPT SIMP NAC" )     
      AADD(aTitCol,"COND PAGTO"  )        
      AADD(aTitCol,"DESCRICAO COND PAGTO")      
      AADD(aTitCol,"INC. ESTADUAL ")
      AADD(aTitCol,"E-MAIL XML    ")
      AADD(aTitCol,"E-MAIL CONTATO")
      AADD(aTitCol,"SUFRAMA       ")
      AADD(aTitCol,"RISCO         ")
      AADD(aTitCol,"LIMITE CREDITO")   
      AADD(aTitCol,"CODIGO CHEP   ")
      AADD(aTitCol,"TOT NF DO CLIENTE")
      AADD(aTitCol,"TOT NF DA REDE")      

      cTit1:="Lista clientes por gerente/vendedor (ROMS065) "
      cTit2:="Param 1: "+MV_PAR01+"/ Param 2: "+MV_PAR02+"/ Param 3: "+MV_PAR03+"/ Param 4: "+MV_PAR04+"/ Param 6: "+AllToChar(MV_PAR06)+"/ Param 7: "+MV_PAR07

      //                          , _aCols,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons )
      U_ITListBox(cTit1,aTitCol,aLog   ,.T.     ,1     ,cTit2   ,          ,        ,         ,     ,        ,           )
   
   ELSE
   
      U_ITMSG(" Nao foi encontrado dados para esses filtros","Atencao!",,3)
   
   ENDIF

ENDDO

If Select(_cAlias1) > 0
   dbSelectArea(_cAlias1)
   (_cAlias1)->( dbCloseArea() )
EndIf

Return .T.

/*
===============================================================================================================================
Programa----------: GeraDados
Autor-------------: Alex Wallauer
Data da Criacao---: 15/10/2021
===============================================================================================================================
Descrição---------: Geração de Dados dos Clientes 
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function GeraDados(OPROC)
Local _cQry:=""
cPict:=PesqPict("SA1","A1_LC")

IF oproc <> nil
   oproc:cCaption := "Lendo Dados... "
   ProcessMessages()
ENDIF

_cQry+= " SELECT  "
_cQry+= " GEREN.A3_COD   CODGER,"   //CODGER                    
_cQry+= " GEREN.A3_NOME  GERENTE, " //GERENTE                    
_cQry+= " COORD.A3_COD   COORD,"    //COORD   
_cQry+= " COORD.A3_NOME  COORDENA,"  //COORDENA  

_cQry+= " SUPER.A3_COD   CODSUPER,"    //COORD   
_cQry+= " SUPER.A3_NOME  SUPER,"  //COORDENA  

_cQry+= " VEND.A3_I_TIPV TIPO,CASE "+ENTER
_cQry+= "    WHEN VEND.A3_TIPO = 'E' THEN 'EXTERNO' "+ENTER
_cQry+= " WHEN VEND.A3_TIPO = 'I' THEN 'INTERNO' "+ENTER
_cQry+= "     ELSE 'PARCEIRO' "+ENTER
_cQry+= " END TIPO1  , "+ENTER

_cQry+= " VEND.A3_COD    CODREP_1,"  //CODREP_1                     
_cQry+= " VEND.A3_NOME   REPRESEN,"  //REPRESEN  
_cQry+= " VEND.A3_I_NOMEF NOMEREP1,"//"NOME_REPRESENTANTE" 

_cQry+= " VEND2.A3_COD   CODREP_2,"  //CODREP_2                    
_cQry+= " VEND2.A3_NOME  REPRESE2,"  //REPRESE2"  
_cQry+= " VEND2.A3_I_NOMEF NOMEREP2,"//"NOME_REPRESENTANTE"                        

_cQry+= " VEND2.A3_I_TIPV TIPO,CASE "+ENTER
_cQry+= "    WHEN VEND2.A3_TIPO = 'E' THEN 'EXTERNO' "+ENTER
_cQry+= " WHEN VEND2.A3_TIPO = 'I' THEN 'INTERNO' "+ENTER
_cQry+= "     ELSE 'PARCEIRO' "+ENTER
_cQry+= " END TIPO2  , "+ENTER
_cQry+= " SX5.X5_DESCRI REGIONAL, "+ENTER 


_cQry+= " SA1.R_E_C_N_O_ REC_SA1,"+ENTER

//---------- Para ultimo Pedido de Venda
_cQry+= " (SELECT MAX (C5_EMISSAO  )  FROM "+RetSqlName("SC5")+" SC5 WHERE SC5.D_E_L_E_T_ = ' ' "+ENTER
_cQry+= " AND C5_CLIENT = A1_COD AND C5_LOJACLI = A1_LOJA "+ENTER
_cQry+= " AND C5_I_OPER IN ('01','05','42','12','15','18','24') ) DT_ULT_PV, "+ENTER
   
//---------- Para ultima nota fiscal emitida
_cQry+= " (SELECT MAX (F2_EMISSAO) FROM "+RETSQLNAME("SF2")+" SF2 WHERE SF2.F2_CLIENTE = SA1.A1_COD AND SF2.F2_LOJA = SA1.A1_LOJA AND SF2.d_e_l_e_t_ = ' ' AND SF2.F2_TIPO = 'N') DT_ULT_NF, " +ENTER

//----------- QUERY TOTAL DE NOTAS EMITIDAS PARA O CLIENTE
_cQry += "     (SELECT COUNT(*) FROM " + RETSQLNAME("SF2") + " SF2 " + "WHERE SF2.F2_CLIENTE = SA1.A1_COD AND SF2.F2_LOJA = SA1.A1_LOJA AND SF2.d_e_l_e_t_ = ' ' AND SF2.F2_TIPO = 'N') NFS_CLIENTE , "

//----------- QUERY TOTAL DE NOTAS EMITIDAS PARA A REDE
_cQry += "     (  CASE WHEN SA1.A1_GRPVEN  = '999999' THEN 0 "
_cQry += "             ELSE (SELECT COUNT(*) FROM " + RETSQLNAME("SF2")+ " SF2, " + RETSQLNAME("SA10") +" REDE "
_cQry += "                   where SF2.d_e_l_e_t_ = ' ' AND SF2.F2_TIPO = 'N'  AND REDE.A1_COD = SF2.F2_CLIENTE AND REDE.A1_LOJA = SF2.F2_LOJA  AND "
_cQry += "             REDE.A1_GRPVEN = SA1.A1_GRPVEN  )   
_cQry += "                END ) NFS_REDE, "

_cQry += " CASE " +ENTER
_cQry += " WHEN VEND.A3_I_REGCO = 'N' THEN 'SEM COMISSÃO' "+ENTER
_cQry += " WHEN VEND.A3_I_REGCO = 'N' THEN 'SEM COMISSÃO' "+ENTER
_cQry += " WHEN VEND.A3_I_REGCO = 'C' THEN 'CLT + COMISSÃO'"+ENTER
_cQry += " WHEN VEND.A3_I_REGCO = 'D' THEN 'DIFERENCIADA'"+ENTER
_cQry += " WHEN VEND.A3_I_REGCO = 'P' THEN 'FIXO - COMISSÃO'"+ENTER
_cQry += " WHEN VEND.A3_I_REGCO = 'F' THEN 'APENAS FIXO SEM COMISSÃO'"+ENTER
_cQry += " WHEN VEND.A3_I_REGCO = 'V' THEN 'PADRAO VAREJO'"+ENTER
_cQry += " ELSE 'PARCEIRO' "+ENTER
_cQry += " END REGRA1, "+ENTER
_cQry += " CASE " +ENTER
_cQry += " WHEN VEND2.A3_I_REGCO = 'N' THEN 'SEM COMISSÃO' "+ENTER
_cQry += " WHEN VEND2.A3_I_REGCO = 'N' THEN 'SEM COMISSÃO' "+ENTER
_cQry += " WHEN VEND2.A3_I_REGCO = 'C' THEN 'CLT + COMISSÃO'"+ENTER
_cQry += " WHEN VEND2.A3_I_REGCO = 'D' THEN 'DIFERENCIADA'"+ENTER
_cQry += " WHEN VEND2.A3_I_REGCO = 'P' THEN 'FIXO - COMISSÃO'"+ENTER
_cQry += " WHEN VEND2.A3_I_REGCO = 'F' THEN 'APENAS FIXO SEM COMISSÃO'"+ENTER
_cQry += " WHEN VEND2.A3_I_REGCO = 'V' THEN 'PADRAO VAREJO'"+ENTER
_cQry += " ELSE 'PARCEIRO' "+ENTER
_cQry += " END REGRA2 "+ENTER 
 
_cQry+= " FROM  "+ENTER
_cQry +=  RetSqlName("SA1")+" SA1,  "+ENTER
_cQry +=  RetSqlName("SA3")+" VEND, "+ENTER
_cQry +=  RetSqlName("SA3")+" VEND2,  "+ENTER
_cQry +=  RetSqlName("SA3")+" COORD,  "+ENTER
_cQry +=  RetSqlName("SA3")+" GEREN, " +ENTER
_cQry +=  RetSqlName("SA3")+" SUPER, " +ENTER
_cQry +=  RetSqlName("ZAM")+" ZAM, " +ENTER
_cQry +=  RetSqlName("SX5")+" SX5 " +ENTER
_cQry+= " WHERE SA1.D_E_L_E_T_ = ' ' "+ENTER
_cQry+= " AND A1_CLIFUN <> '1'"+ENTER
_cQry+= " AND VEND.A3_COD = A1_VEND"+ENTER
_cQry+= " AND VEND.D_E_L_E_T_ = ' '"+ENTER
_cQry+= " AND VEND2.A3_COD  (+) = A1_I_VEND2"+ENTER
_cQry+= " AND VEND2.D_E_L_E_T_  (+) = ' ' "+ENTER
_cQry+= " AND GEREN.A3_COD =VEND.A3_GEREN"+ENTER
_cQry+= " AND GEREN.D_E_L_E_T_ = ' '"+ENTER
_cQry+= " AND COORD.A3_COD = VEND.A3_SUPER"+ENTER
_cQry+= " AND COORD.D_E_L_E_T_ = ' '"+ENTER
_cQry+= " AND SUPER.A3_COD     (+)= VEND.A3_I_SUPE"+ENTER 
_cQry+= " AND SUPER.D_E_L_E_T_ (+)= ' ' "+ENTER
 
_cQry+= " AND ZAM.D_E_L_E_T_  (+) <> '*' "+ENTER
_cQry+= " AND ZAM.ZAM_GERCOD  (+) =  VEND.A3_GEREN "+ENTER
_cQry+= " AND ZAM.ZAM_COOCOD  (+) =  VEND.A3_SUPER "+ENTER
_cQry+= " AND SX5.D_E_L_E_T_  (+) <> '*' "+ENTER
_cQry+= " AND SX5.X5_TABELA   (+) = 'ZC' "+ENTER
_cQry+= " AND SX5.X5_CHAVE    (+) = ZAM.ZAM_REGCOD "+ENTER

  


IF !EMPTY(MV_PAR01)
   _cQry+= " AND A1_COD IN "+FormatIn(ALLTRIM(MV_PAR01),";")+ENTER
ENDIF
IF !EMPTY(MV_PAR02)
   _cQry+= " AND GEREN.A3_COD IN "+FormatIn(ALLTRIM(MV_PAR02),";")+ENTER
ENDIF
IF !EMPTY(MV_PAR03)
   _cQry+= " AND COORD.A3_COD IN "+FormatIn(ALLTRIM(MV_PAR03),";")+ENTER
ENDIF
IF !EMPTY(MV_PAR04)
   _cQry+= " AND VEND.A3_COD IN "+FormatIn(ALLTRIM(MV_PAR04),";")+ENTER
ENDIF
IF !EMPTY(MV_PAR05)
   _cQry+= " AND A1_EST IN "+FormatIn(ALLTRIM(MV_PAR05),";")+ENTER
ENDIF
IF MV_PAR07 = "1"//ATIVO
   _cQry+= " AND A1_MSBLQL <> '1'"+ENTER
ELSEIF MV_PAR07 = "2"//BLOQUEADO
   _cQry+= " AND A1_MSBLQL = '1'"+ENTER
ENDIF
_cQry+= " ORDER BY GEREN.A3_NOME , COORD.A3_NOME , VEND.A3_NOME , A1_NOME "

//nHandle := FCreate("c:\smartclient\ROMS065_"+STRTRAN(TIME(),":","_")+".TXT")
//FWrite(nHandle, _cQry)
//FClose(nHandle)

If Select(_cAlias1) > 0
   dbSelectArea(_cAlias1)
   (_cAlias1)->( dbCloseArea() )
EndIf

DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry), _cAlias1, .F., .T.)   
(_cAlias1)->(Dbgotop())                           

COUNT TO _nTot

_cTot:=ALLTRIM(STR(_nTot))
_nTam:=LEN(_cTot)+1
nConta:=0
(_cAlias1)->(Dbgotop())     
TNX->(DBSETORDER(1))                     
DO WHILE !((_cAlias1)->(EOF()))

   nConta++
   IF oproc <> nil
	  oproc:cCaption := "Lendo Dados: "+ALLTRIM(STR(nConta,_nTam)) +" de "+ _cTot
	  ProcessMessages()
   ENDIF

   SA1->(DBGOTO( (_cAlias1)->REC_SA1) )

   aLogAux:={}
   AADD(aLogAux,(_cAlias1)->CODGER  )
   AADD(aLogAux,(_cAlias1)->GERENTE )

   AADD(aLogAux,(_cAlias1)->COORD   )
   AADD(aLogAux,(_cAlias1)->COORDENA)


   AADD(aLogAux,(_cAlias1)->CODSUPER   )
   AADD(aLogAux,(_cAlias1)->SUPER)


   AADD(aLogAux,(_cAlias1)->TIPO1)
   AADD(aLogAux,(_cAlias1)->CODREP_1)
   AADD(aLogAux,(_cAlias1)->REPRESEN)
   AADD(aLogAux,(_cAlias1)->NOMEREP1)
   AADD(aLogAux,(_cAlias1)->REGRA1)   
   
   AADD(aLogAux,(_cAlias1)->TIPO2)
   AADD(aLogAux,(_cAlias1)->CODREP_2)
   AADD(aLogAux,(_cAlias1)->REPRESE2)
   AADD(aLogAux,(_cAlias1)->NOMEREP2) 
   AADD(aLogAux,(_cAlias1)->REGRA2)
 
   AADD(aLogAux,SA1->A1_COD   )   
   AADD(aLogAux,SA1->A1_LOJA )    
   AADD(aLogAux,SA1->A1_PESSOA )  
   AADD(aLogAux,SA1->A1_CGC  )     
   AADD(aLogAux,SA1->A1_GRPVEN )  
   AADD(aLogAux,Posicione("ACY",1,xFilial("ACY") + SA1->A1_GRPVEN, "ACY_DESCRI") )
   AADD(aLogAux,SA1->A1_NOME  )   
   AADD(aLogAux,SA1->A1_NREDUZ )  
   AADD(aLogAux,SA1->A1_MUN   )    
   AADD(aLogAux,SA1->A1_EST )      
   AADD(aLogAux,SA1->A1_CEP  )    
   AADD(aLogAux,SA1->A1_END  )    
   AADD(aLogAux,SA1->A1_I_REGIA  )
   AADD(aLogAux,(_cAlias1)->REGIONAL )
   AADD(aLogAux,SA1->A1_DDD  )    
   AADD(aLogAux,SA1->A1_TEL )     
   AADD(aLogAux,SA1->A1_I_GRCLI )
   AADD(aLogAux,Posicione("ZZ6",1,xFilial("ZZ6") + SA1->A1_I_GRCLI, "ZZ6_DESCRO")  ) 
   AADD(aLogAux,SA1->A1_I_SUBCO )
   AADD(aLogAux,POSICIONE("ZS6",1,XFILIAL()+SA1->A1_I_GRCLI+SA1->A1_I_SUBCO,"ZS6_DESCRI")  ) 

   AADD(aLogAux,DTOC(SA1->A1_PRICOM  ))  
   AADD(aLogAux,DTOC(STOD((_cAlias1)->DT_ULT_PV)) )  
   AADD(aLogAux,DTOC(SA1->A1_I_DTREA ))  
   AADD(aLogAux,DTOC(SA1->A1_I_DTCAD )) 
   AADD(aLogAux,DTOC(STOD((_cAlias1)->DT_ULT_NF)) )      

   AADD(aLogAux,IF(SA1->A1_MSBLQL ="1","Bloqueado","Ativo") )  
   AADD(aLogAux,IF(SA1->A1_CONTRIB="1","Sim","Nao") )  
   AADD(aLogAux,IF(SA1->A1_SIMPNAC="1","Sim","Nao") )  


   AADD(aLogAux,SA1->A1_COND ) 
   AADD(aLogAux,Posicione("SE4",1,xFilial("SE4") + SA1->A1_COND, "E4_DESCRI")  ) 
   AADD(aLogAux,SA1->A1_INSCR)  
   AADD(aLogAux,SA1->A1_EMAIL)  
   AADD(aLogAux,SA1->A1_I_EMAIL)
   AADD(aLogAux,SA1->A1_SUFRAMA)
   AADD(aLogAux,SA1->A1_RISCO)  
   AADD(aLogAux,TRansform(SA1->A1_LC,cPict))     
   AADD(aLogAux,SA1->A1_I_CCHEP)
   AADD(aLogAux,(_cAlias1)->NFS_CLIENTE)
   AADD(aLogAux,(_cAlias1)->NFS_REDE) 

   AADD(aLog,aLogAux)
   (_cAlias1)->(Dbskip())
	
Enddo

Return .T.
