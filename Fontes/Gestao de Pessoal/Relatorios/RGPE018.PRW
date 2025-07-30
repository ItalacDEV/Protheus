/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |16/09/2019| Chamado 28346. Retirado uso não permitido de API e Loop.
Alex Wallauer |24/02/2021| Chamado 28346. Retirado uso não permitido de API e Loop.
Lucas Borges  |09/10/2024| Chamado 48465. Retirada manipulação do SX1
===============================================================================================================================
*/
#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'
/*
===============================================================================================================================
Programa----------: RGPE018
Autor-------------: Alex Wallauer
Data da Criacao---: 06/05/2019
Descrição---------: Relatório de histórico de funções do funcionario - Chamado 27521
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGPE018()

_cSelePSRA:="SELECT RA_MAT, RA_NOME FROM "+RETSQLNAME("SRA")+" SRA WHERE D_E_L_E_T_ = ' ' AND RA_SITFOLH <> 'D' ORDER BY RA_NOME " 
                                                                           
_aItalac_F3:={}//       1           2         3                      4                      5                6                         7         8          9         10         11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave               , _nCpoDesc              ,_bCondTab    , _cTitAux                , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR02" ,_cSelePSRA,{|Tab| (Tab)->RA_MAT}, {|Tab|(Tab)->RA_NOME}    ,             ,"Funcionarios"             ,          ,          ,99        ,.F.        ,       , } )

If Pergunte("RGPE018",.T.) .And. !Empty(MV_PAR03) .And. !Empty(MV_PAR04)
	cTimeInicial:=TIME()
	FWMSGRUN( ,{|oProc|  RGPE018R(oProc) } , "Processando - Hora Inicial: "+cTimeInicial+", Aguarde...",  )
EndIf
U_ITLOGACS( "RGPE018" )

Return

/*
===============================================================================================================================
Programa----------: RGPE018R
Autor-------------: Alex Wallauer
Data da Criacao---: 06/05/2019
Descrição---------: Função que imprime o relatório
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RGPE018R(oProc)
Local cQry1 := ""  , _nPos
LOCAL _cAlias:= GetNextAlias()
LOCAL _lLerTudo:=.F.
IF LEFT(MV_PAR02,1) = "*"
   _lLerTudo:=.T.
   MV_PAR02:=SUBSTR(MV_PAR02,2)
ENDIF

oProc:cCaption :=  "Selecionando Cargos, Aguarde... "
ProcessMessages()

_aDados:={}

IF MV_PAR05 <> 2 

   cQry1 := "SELECT  R_E_C_N_O_ RECSR7 "
   cQry1 += "FROM " + RetSqlName("SR7") + " SR7  "
   cQry1 += " WHERE "
   cQry1 += " R7_FILIAL||R7_MAT IN (SELECT  R7_FILIAL||R7_MAT  "
   cQry1 += "                 FROM  " + RetSqlName("SR7") + " SR7  "
   cQry1 += "                 WHERE SR7.D_E_L_E_T_ = ' ' "
   If !Empty(MV_PAR01)
   	cQry1 += " AND R7_FILIAL IN "+FormatIn(ALLTRIM(MV_PAR01),";")
   EndIf
   IF !EMPTY(MV_PAR04)
      cQry1 += "              AND R7_DATA BETWEEN '" + DtoS(MV_PAR03) + "' AND '" + DtoS(MV_PAR04) + "'"
   ElseIf !EMPTY(MV_PAR03)
      cQry1 += "              AND R7_DATA >= '" + DtoS(MV_PAR03) + "'"
   ENDIF   
   cQry1 += "           ) "
   If !Empty(MV_PAR02)
   	cQry1 += " AND R7_MAT IN "+FormatIn(ALLTRIM(MV_PAR02),";")
   EndIf
   
   cQry1 += " AND SR7.D_E_L_E_T_ = ' ' "
   cQry1 += " ORDER BY R7_FILIAL, R7_MAT, R7_DATA "
   
   //crio o novo alias
   MPSysOpenQuery( cQry1, _cAlias ) 
   
   nTotal:=nConta:=0
   dbSelectArea(_cAlias)
   COUNT TO nTotal
   (_cAlias)->(dbGoTop())
   
   nTotal:=ALLTRIM(STR(nTotal))
   nTam:=LEN(nTotal)+1
   SRA->(DBSETORDER(1))
   SR7->(DBSETORDER(1))
   SR3->(DBSETORDER(2))
   
   DO While !(_cAlias)->(Eof())
      
      SR7->(DBGOTO((_cAlias)->RECSR7))
      nConta++
      oProc:cCaption :=  "Lendo Cargos - "+STRZERO(nConta,nTam)+" de "+nTotal +" - Matricula: " +SR7->R7_MAT
      ProcessMessages()
   
      SRA->(DBSEEK(SR7->R7_FILIAL+SR7->R7_MAT)) 
      IF SRA->RA_SITFOLH = 'D'  
         (_cAlias)->(dbSkip())
         LOOP
      ENDIF
   
      _aItens:={}
       IF (_nPos:=ASCAN(_aDados,{ |D| D[1] == SR7->R7_FILIAL .AND. D[2] == SR7->R7_MAT })) = 0 .OR. _lLerTudo
          AADD(_aItens,SR7->R7_FILIAL)//1
          AADD(_aItens,SR7->R7_MAT)   //2
          AADD(_aItens,ALLTRIM(SRA->RA_NOMECMP))//3
          AADD(_aItens,ALLTRIM(SRA->RA_CC)+" - "+ALLTRIM(POSICIONE("CTT",1,xfilial("CTT")+SRA->RA_CC,"CTT_DESC01")))//4
          AADD(_aItens,DTOC(SR7->R7_DATA))      //5
          AADD(_aItens,"")//Função anterior     //6
          AADD(_aItens,ALLTRIM(SR7->R7_DESCFUN))//7
          cTipo:=""
          cSal:=""
          IF SR3->(DBSEEK(SR7->R7_FILIAL+SR7->R7_MAT)) 
             DO WHILE SR3->(!EOF()) .AND. SR7->R7_FILIAL+SR7->R7_MAT == SR3->R3_FILIAL+SR3->R3_MAT
                cTipo:=ALLTRIM(SR3->R3_TIPO)+" - "+AllTrim(Posicione("SX5",1,xFilial("SX5")+"41"+SR3->R3_TIPO,"X5_DESCRI"))//8
                cSal :="R$ "+TRANS(SR3->R3_VALOR,"@E 999,999,999,999.99")//9  //salario atual 
                SR3->(DBSKIP()) 
             ENDDO          
          ENDIF
          AADD(_aItens,cTipo)                //8
          AADD(_aItens,cSal)                 //9
          AADD(_aItens,"CARGO")              //10
          
          AADD(_aDados,ACLONE(_aItens))
       Else
          _aDados[_nPos,4]:=ALLTRIM(SRA->RA_CC)+" - "+ALLTRIM(POSICIONE("CTT",1,xfilial("CTT")+SRA->RA_CC,"CTT_DESC01"))
          _aDados[_nPos,5]:=DTOC(SR7->R7_DATA)
          _aDados[_nPos,6]:=_aDados[_nPos,7]//Função anterior 
          _aDados[_nPos,7]:=ALLTRIM(SR7->R7_DESCFUN)//Função atual 
       ENDIF      
   
      (_cAlias)->(dbSkip())
   	
   ENDDO
   
   IF !_lLerTudo
      _aDadosAux:=ACLONE(_aDados)
      _aDados:={}
      FOR _nPos :=  1 TO LEN(_aDadosAux)
          IF EMPTY(_aDadosAux[_nPos,6]) .OR. EMPTY(_aDadosAux[_nPos,7]) .OR. ALLTRIM(_aDadosAux[_nPos,6]) = ALLTRIM(_aDadosAux[_nPos,7])
             LOOP
          ENDIF
          AADD(_aDados,_aDadosAux[_nPos])
      NEXT
   ENDIF
ENDIF

IF LEN(_aDados) > 0 
   _aTit:={}
   AADD(_aTit,"Filial") 
   AADD(_aTit,"Matricula" )
   AADD(_aTit,"Nome")
   AADD(_aTit,"Centro de custo" ) 
   AADD(_aTit,"Data de alteracao")
   AADD(_aTit,"Funcao de " )
   AADD(_aTit,"Funcao para")
   AADD(_aTit,"Tipo de Aumento")
   AADD(_aTit,"Salario")
   AADD(_aTit,"Tipor Rel")
ENDIF
//****************************  SALARIO  *************************************************
IF MV_PAR05 <> 1
   oProc:cCaption :=  "Selecionando Salario, Aguarde... "
   ProcessMessages()
   
   cQry1 := "SELECT  R_E_C_N_O_ RECSR3 "
   cQry1 += "FROM " + RetSqlName("SR3") + " SR3  "
   cQry1 += " WHERE "
   cQry1 += " R3_FILIAL||R3_MAT IN (SELECT  R3_FILIAL||R3_MAT  "
   cQry1 += "                 FROM  " + RetSqlName("SR3") + " SR3  "
   cQry1 += "                 WHERE SR3.D_E_L_E_T_ = ' ' "
   If !Empty(MV_PAR01)
   	cQry1 += " AND R3_FILIAL IN "+FormatIn(ALLTRIM(MV_PAR01),";")
   EndIf
   IF !EMPTY(MV_PAR04)
      cQry1 += "              AND R3_DATA BETWEEN '" + DtoS(MV_PAR03) + "' AND '" + DtoS(MV_PAR04) + "'"
   ElseIf !EMPTY(MV_PAR03)
      cQry1 += "              AND R3_DATA >= '" + DtoS(MV_PAR03) + "'"
   ENDIF   
   cQry1 += "           ) "
   If !Empty(MV_PAR02)
   	cQry1 += " AND R3_MAT IN "+FormatIn(ALLTRIM(MV_PAR02),";")
   EndIf
   
   cQry1 += " AND SR3.D_E_L_E_T_ = ' ' "
   cQry1 += " ORDER BY R3_FILIAL, R3_MAT, R3_DATA "
   
   //crio o novo alias
   MPSysOpenQuery( cQry1, _cAlias ) 
   
   nTotal:=nConta:=0
   dbSelectArea(_cAlias)
   COUNT TO nTotal
   (_cAlias)->(dbGoTop())
   
   IF LEN(_aDados) = 0 //Se não tem dados de função
      _aTit:={}
      AADD(_aTit,"Filial") 
      AADD(_aTit,"Matricula" )
      AADD(_aTit,"Nome")
      AADD(_aTit,"Tipo Aumento" ) 
      AADD(_aTit,"Data de alteracao")
      AADD(_aTit,"Salario de " )
      AADD(_aTit,"Salario para")
      AADD(_aTit,"")
      AADD(_aTit,"")
      AADD(_aTit,"Tipor Rel")
   ELSEIF nTotal > 0
      _aItens:={} ; lDel:=.T.
      AADD(_aItens,"Filial") 
      AADD(_aItens,"Matricula" )
      AADD(_aItens,"Nome")
      AADD(_aItens,"Tipo Aumento" ) 
      AADD(_aItens,"Data de alteracao")
      AADD(_aItens,"Salario de " )
      AADD(_aItens,"Salario para")
      AADD(_aItens,"")
      AADD(_aItens,"")
      AADD(_aItens,"Tipor Rel")
      AADD(_aDados,ACLONE(_aItens))
   ENDIF
   
   nTotal:=ALLTRIM(STR(nTotal))
   nTam:=LEN(nTotal)+1
   SRA->(DBSETORDER(1))
   SR3->(DBSETORDER(1))
   nConta:=0
   DO While !(_cAlias)->(Eof())
      
      SR3->(DBGOTO((_cAlias)->RECSR3))
      SRA->(DBSEEK(SR3->R3_FILIAL+SR3->R3_MAT)) 
      IF SRA->RA_SITFOLH = 'D'  
         (_cAlias)->(dbSkip())
         LOOP
      ENDIF
      nConta++
      oProc:cCaption :=  "Lendo Salario - "+STRZERO(nConta,nTam)+" de "+nTotal +" - Matricula: " +SR3->R3_MAT
      ProcessMessages()
   
      _aItens:={}
       IF (_nPos:=ASCAN(_aDados,{ |D| D[1] == SR3->R3_FILIAL .AND. D[2] == SR3->R3_MAT .AND. D[10] == "SALARIO"})) = 0 .OR. _lLerTudo
          AADD(_aItens,SR3->R3_FILIAL)//1
          AADD(_aItens,SR3->R3_MAT)   //2
          AADD(_aItens,ALLTRIM(SRA->RA_NOMECMP))//3
          AADD(_aItens,ALLTRIM(SR3->R3_TIPO)+" - "+AllTrim(Posicione("SX5",1,xFilial("SX5")+"41"+SR3->R3_TIPO,"X5_DESCRI")))//4
          AADD(_aItens,DTOC(SR3->R3_DATA))      //5
          AADD(_aItens,"")                      //6  //salario anterior 
          AADD(_aItens,"R$ "+TRANS(SR3->R3_VALOR,"@E 999,999,999,999.99"))  //7  //salario atual 
          AADD(_aItens,"")               //8
          AADD(_aItens,"")               //9
          AADD(_aItens,"SALARIO")        //10
          lDel:=.F.
          AADD(_aDados,ACLONE(_aItens))
       Else
          _aDados[_nPos,4]:=ALLTRIM(SR3->R3_TIPO)+" - "+AllTrim(Posicione("SX5",1,xFilial("SX5")+"41"+SR3->R3_TIPO,"X5_DESCRI"))//4
          _aDados[_nPos,5]:=DTOC(SR3->R3_DATA)    //5 
          _aDados[_nPos,6]:=_aDados[_nPos,7]      //6  //salario anterior 
          _aDados[_nPos,7]:="R$ "+TRANS(SR3->R3_VALOR,"@E 999,999,999,999.99")//7  //salario atual 
       ENDIF      
   
      (_cAlias)->(dbSkip())
   	
   ENDDO
   
   IF !_lLerTudo
      _aDadosAux:=ACLONE(_aDados)
      _aDados:={}
      FOR _nPos :=  1 TO LEN(_aDadosAux)
          IF EMPTY(_aDadosAux[_nPos,6]) .OR. EMPTY(_aDadosAux[_nPos,7]) .OR. ALLTRIM(_aDadosAux[_nPos,6]) = ALLTRIM(_aDadosAux[_nPos,7])
             LOOP
          ENDIF
          IF lDel .AND._aDadosAux[_nPos,1] = "Filial"
             LOOP
          ENDIF
          AADD(_aDados,_aDadosAux[_nPos])
      NEXT
   ENDIF

ENDIF

IF LEN(_aDados) = 0 .OR. nConta = 0
    U_ITMSG("Não há dados para essa seleção",'Atenção!',,3)
ENDIF

DO WHILE LEN(_aDados) > 0 

   _aSiz:={}
   AADD(_aSiz,30)
   AADD(_aSiz,30)
   AADD(_aSiz,90)
   AADD(_aSiz,90)
   AADD(_aSiz,30)
   AADD(_aSiz,90)
   AADD(_aSiz,20)
   
   _cTitulo := "RELATORIO DE HISTORICO DE FUNCOES / SALARIO DOS FUNCIONARIOS " 
   
   _cMsgTop:="Informacoes encontradas - H.I.: "+cTimeInicial+" H.F.: "+TIME()

   _cTitulo:="Par. 1 : "+ALLTRIM(MV_PAR01)+"; Par. 2 : "+ALLTRIM(MV_PAR02)+"; Par. 3 : "+DTOC(MV_PAR03)+"; Par. 4 : "+DTOC(MV_PAR04)
           
           
   bOk:={|| IF(U_ITMSG("Confirma Gerar EXCEL ?",'Atenção!',,2,2,2) , DlgToExcel( { { "ARRAY" , _cTitulo , _aTit , _aDados } } )  ,.F. )   }

   //                           , _aCols  ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons )
      U_ITListBox(_cTitulo,_aTit,_aDados  , .T.    , 3    ,_cMsgTop,          ,_aSiz   ,         , bOk ,        , )
                                                                                                  

   IF  !U_ITMSG("Confirma Sair ?",'Atenção!',,3,2,2)
       LOOP
   ENDIF

    EXIT

ENDDO

Return
