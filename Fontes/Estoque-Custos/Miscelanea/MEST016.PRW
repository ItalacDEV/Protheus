/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer |15/02/2024| Chamado 46302. Andre. Criada a nova opcao de Origem (MV_PAR07): Estrutura e Consumo.
Lucas Borges  |08/10/2024| Chamado 48465. Retirada manipulação do SX1
Lucas Borges  |09/05/2025| Chamado 50617. Corrigir chamada estática no nome das tabelas do sistema
===============================================================================================================================
*/

#include "protheus.ch"  

/*
===============================================================================================================================
Programa----------: MEST016
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 27/09/2018
Descrição---------: Ajuste de Saldos de estoques para distribuicao dos custos nas OP's - CHAMADO 27301
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MEST016()

Local d_Fecha:= GetMv('MV_ULMES')
Local cPerg  :="MEST016"

Private _aItalac_F3:={}

DO While .T.

	If !Pergunte(cPerg,.T.)
		Return
	EndIf

   IF MV_PAR02 < d_Fecha
	  U_ITMSG('A data inicial deve ser maior que a data do ultimo fechamento: '+DTOC(d_Fecha), 'ATENÇÃO',,1)
	  LOOP
   ELSEIF MV_PAR02 > MV_PAR03
	  U_ITMSG('A data inicial deve ser menor que a data final','ATENÇÃO',,1)
	  LOOP
   ELSEIF EMPTY(MV_PAR04)
	  U_ITMSG('É obrigadotorio informar o codigo do produto','ATENÇÃO',,1)
	  LOOP
   ENDIF  

   _aOProd:={}
   _nTotOPs:=0
   _nTotPR0:=0
   _nTotRat:=0
   _nTotVlN:=0
   _cCustos:=""

   FWMSGRUN( ,{|oProc| MEST16Ler(oProc) } , "Aguarde...", "Lendo dados..."  )

   If Select("QRT") > 0
      DbSelectArea("QRT")
      DbCloseArea()
   EndIf

   IF LEN(_aOProd) = 0
      LOOP
   ENDIF
     
   _cMsgTop:="Totais das OPs, Litros: ;"
   _cMsgTop+="Valor Rateio por produto: "+ALLTRIM(TRANS(MV_PAR01,"@E 999,999,999,999,999,999.999"))+"; "
   _cMsgTop+=" C.C.(s): "+_cCustos

   EXIT	

EndDo

DO WHILE .T.

//User Function ITListBox( _cTitAux ,
   _lOK:=U_ITListBox( 'OPs Filtradas (MEST016): '+_cMsgTop ,;                                                                        // _aHeader , _aCols,_lMaxSiz,_nTipo ,_cMsgTop ,_lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons )
                     {'OP + CC','Data Emissao','Produto [PR0]','Qtde Apontada','Produto [RE1]','Qtde Consumida','Reteio','Valor Novo','Quantidade Empenho'},_aOProd,.T.     ,1      ,_cMsgTop ,         ,;
                     {       55,            55,             50,             50,             50,              50,      50,          50,                  50})//,, _bOK,_bCancel )
   IF _lOK 
   
      IF U_ITMSG("CONFIRMA A GRAVAÇÃO DOS VALORES ????",'Atenção!',,2,2,2)

         FWMSGRUN( ,{|oProc| _lOK:=MEST16Grv(oProc) } , "Aguarde...", "Gravando dados..."  )

         IF !_lOK
            LOOP
         ENDIF   
      ELSE   
         LOOP
      ENDIF   

   ENDIF  

   EXIT

ENDDO   

Return Nil

/*
===============================================================================================================================
Programa----------: MEST16Ler
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 27/09/2018
Descrição---------: Grava os dados da OP
Parametros--------: oProc
Retorno-----------: .T. ou .F.
===============================================================================================================================
*/
Static Function MEST16Grv(oProc)
LOCAL nCotaGRV:=0 , P
LOCAL _nConta:=0

_cTotOPs:=ALLTRIM(STR(LEN(_aOProd)))
_nTam:=LEN(_cTotOPs)+1

FOR P := 1 TO LEN(_aOProd)

   _nConta++
   oProc:cCaption := "2/2-Gravando OP: "+SD3->D3_OP+" - "+STR(_nConta,_nTam)+" de "+_cTotOPs
   ProcessMessages()

   IF _aOProd[P,10] = 0
      LOOP
   ENDIF
   SD3->(DBGOTO( _aOProd[P,10] ))
   SD3->(RECLOCK("SD3",.F.))
   SD3->D3_I_QTORI:= SD3->D3_QUANT
   SD3->D3_QUANT  := _aOProd[P,12]
   SD3->(MSUNLOCK())  
   nCotaGRV++

   IF _aOProd[P,11] = 0
      LOOP
   ENDIF
   SD4->(DBGOTO( _aOProd[P,11] ))
   SD4->(RECLOCK("SD4",.F.))
   SD4->D4_I_QTORI:=SD4->D4_QTDEORI
   SD4->D4_QTDEORI:= _aOProd[P,12]
   SD4->(MSUNLOCK())  

NEXT

U_ITMSG(ALLTRIM(STR(nCotaGRV))+" Resgistros atualizados com sucesso",'FINAL',_cMsgTop,2)

RETURN .T.

/*
===============================================================================================================================
Programa----------: MEST16Ler
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 27/09/2018
Descrição---------: Ler os dados da OP
Parametros--------: oProc
Retorno-----------: .T. ou .F.
===============================================================================================================================
*/
Static Function MEST16Ler(oProc)
LOCAL nCountRec , P , _nVlrDif

LOCAL _cPicT3:=AVSX3("D3_QUANT",6)
LOCAL _cPicT4:=AVSX3("D4_QTDEORI",6)
LOCAL _cPicTR:="@E 999,999,999,999,999,999.999"
LOCAL _cCodFiltro:=""//"08000000051"
LOCAL _Query := ""  , E
_cCustos:="Todos"

IF MV_PAR07 = 1 //ESTRUTURA

   _Query += "        SELECT D3_CC FROM "+RETSQLNAME("SD3")+" SD3 "
   _QUERY += "                 WHERE SD3.D_E_L_E_T_ = ' ' AND D3_FILIAL = '"+xFilial("SD3")+"' " 
   _QUERY += "                   AND SD3.D3_CF = 'PR0' AND D3_ESTORNO <> 'S' "
   _Query += "                AND SD3.D3_COD = '"+ALLTRIM(MV_PAR04)+"'"
   IF EMPTY(MV_PAR03)
      _Query += "                AND  SD3.D3_EMISSAO >= '"+DTOS(MV_PAR02)+"' " 
   ELSE
      _Query += "                AND  SD3.D3_EMISSAO BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' " 
   ENDIF
   _Query += " GROUP BY D3_CC "
   _Query := ChangeQuery(_Query)

   If Select("QRT") > 0
      QRT->(DbCloseArea())
   EndIf
   oProc:cCaption := "Lendo OPs Pai, Aguarde..."
   ProcessMessages()
   
   MPSysOpenQuery( _Query, "QRT" ) 
   
   QRT->(DBGOTOP())
   
   _cCustos:=""
   DO WHILE QRT->(!EOF())
   
      IF !QRT->D3_CC $ _cCustos
         _cCustos+=QRT->D3_CC+";"
      ENDIF   
      QRT->(DBSKIP())
   	
   ENDDO
   
   IF EMPTY(_cCustos)
      U_ITMSG("Não foram encontrados dados para essa seleção",'ATENÇÃO',"Selecione outros dados no filtro e tene novamente",1)
      RETURN .F.
   ENDIF
   
   _cCustos:=LEFT(_cCustos,LEN(_cCustos)-1)
   
   If Select("QRT") > 0
      QRT->(DbCloseArea())
   EndIf
   
   SB1->(DBSETORDER(1))

//IF MV_PAR07 = 1 //ESTRUTURA

   _cTeste:=" PAI "+CHR(13)+CHR(10)
   nEstru := 0
   aEstrutura:={}
   _aCodFiltro:={}
   aEstrProd:=Estrut(AVKEY(MV_PAR04,"G1_COD"),1) 
   FOR P := 1 TO LEN(aEstrProd)
       _cTeste += ARRTOKSTR(aEstrProd[P])
       SB1->(DBSEEK(xFILIAL()+aEstrProd[P,3]))
       IF aEstrProd[P,1] = 1 .AND. SB1->B1_TIPO $ "'PP','PI','MP','PA'" .AND. SB1->B1_GRUPO $ "'0003','0002','0006','0800','0814'"
          _cCodFiltro+=aEstrProd[P,3]+";"
          AADD(_aCodFiltro,aEstrProd[P,3])
          _cTeste += "; X "
       ENDIF
       _cTeste += CHR(13)+CHR(10)
   NEXT
   
   _aCodNivel:={}
   FOR E := 1 TO LEN(_aCodFiltro)
   	_cCodAux:=_aCodFiltro[E]
   	nEstru := 0
   	aEstrutura:={}
   	aEstrProd:=Estrut(AVKEY(_cCodAux,"G1_COD"),1)
   	_cTeste+=" FILHO 1 "+CHR(13)+CHR(10)
   	_cCodNivel:=""
   	FOR P := 1 TO LEN(aEstrProd)
   		_cTeste+=ARRTOKSTR(aEstrProd[P])
   		SB1->(DBSEEK(xFILIAL()+aEstrProd[P,3]))
   		IF aEstrProd[P,1] = 1 .AND. SB1->B1_TIPO $ "'PP','PI','MP'" .AND. SB1->B1_GRUPO $ "'0003','0002','0006','0800','0814'"
   			_cCodFiltro+=aEstrProd[P,3]+";"
   			AADD(_aCodNivel,aEstrProd[P,3])
   			_cTeste += "; X "
   		ENDIF
   		_cTeste += CHR(13)+CHR(10)
   	NEXT
   NEXT
   
   FOR E := 1 TO LEN(_aCodNivel)
   	_cCodNivel:=_aCodNivel[E]
   	nEstru := 0
   	aEstrutura:={}
   	aEstrProd:=Estrut(AVKEY(_cCodNivel,"G1_COD"),1)
   	_cTeste+=" FILHO 2 "+CRLF
   	_cCodNivel:=""
   	FOR P := 1 TO LEN(aEstrProd)
   		_cTeste+=ARRTOKSTR(aEstrProd[P])
   		SB1->(DBSEEK(xFILIAL()+aEstrProd[P,3]))
   		IF aEstrProd[P,1] = 1 .AND. SB1->B1_TIPO $ "'PP','PI','MP'" .AND. SB1->B1_GRUPO $ "'0003','0002','0006','0800','0814'"
   			_cCodFiltro+=aEstrProd[P,3]+";"
   			_cTeste += "; X "
   		ENDIF
   		_cTeste += CRLF
   	NEXT
   NEXT
   
   _cTeste:=STRTRAN(_cTeste,"|",";")
   
   _Query := ""
   _QUERY += "         SELECT D3_EMISSAO, D3_OP, D3_COD, D3_I_QTORI, D3_QUANT, R_E_C_N_O_ REC_SD3 FROM "+RETSQLNAME("SD3")+" SD3 "
   _QUERY += "                WHERE  SD3.D_E_L_E_T_ = ' ' AND D3_FILIAL = '"+xFilial("SD3")+"' " 
   _QUERY += "                  AND (SD3.D3_CF = 'RE1'  "//CONSUMIDO
   _QUERY += "                    OR SD3.D3_CF = 'PR0') "//PRODUZIDO
   _QUERY += "                  AND  SD3.D3_ESTORNO <> 'S' AND SD3.D3_I_ORIGE <> 'MATA685' "
   _Query += "                  AND  SD3.D3_COD IN "+FormatIn(_cCodFiltro,";")
   _Query += "                  AND  SD3.D3_CC  IN "+FormatIn(_cCustos,";")
   IF !EMPTY(MV_PAR05)
      _Query += "               AND  SD3.D3_OP  IN "+FormatIn(ALLTRIM(MV_PAR05),";")
   ENDIF
   IF EMPTY(MV_PAR03)
      _Query += "               AND  SD3.D3_EMISSAO >= '"+DTOS(MV_PAR02)+"' " 
   ELSE
      _Query += "               AND  SD3.D3_EMISSAO BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' " 
   ENDIF
   
   _QUERY += " ORDER BY D3_EMISSAO , D3_OP , D3_COD "

ELSE//MV_PAR07 - CONSUMO

   _QUERY := ""
   _QUERY += " SELECT D3_EMISSAO, D3_OP, D3_COD, D3_I_QTORI, D3_QUANT, R_E_C_N_O_ REC_SD3 FROM "+RETSQLNAME("SD3")+" SD3 "
   _QUERY += "                WHERE SD3.D_E_L_E_T_ = ' ' AND D3_FILIAL = '"+xFilial("SD3")+"' " 
   _QUERY += "                  AND SD3.D3_CF = 'RE1'
   _QUERY += "                  AND SD3.D3_TIPO IN ('MP','PP','PI','PA')
   _QUERY += "                  AND SD3.D3_GRUPO IN ('0003','0002','0006','0800','0814')
   _QUERY += "                  AND SD3.D3_ESTORNO <> 'S' AND SD3.D3_I_ORIGE <> 'MATA685' "
   IF !EMPTY((MV_PAR08))
      _Query += "               AND SD3.D3_COD IN "+FormatIn(ALLTRIM(MV_PAR08),";")
   ENDIF
   IF !EMPTY(MV_PAR05)
      _Query += "               AND SD3.D3_OP  IN "+FormatIn(ALLTRIM(MV_PAR05),";")
   ELSE
      _Query += "               AND SD3.D3_OP  IN (SELECT D3_OP FROM " + RetSqlName("SD3") + " WHERE D_E_L_E_T_ = ' '  "
      _Query += "                                     AND  D3_ESTORNO <> 'S' AND D3_CF = 'PR0' AND D3_COD = '"+ALLTRIM(MV_PAR04)+"' ) "
      IF EMPTY(MV_PAR03)
         _Query += "                                  AND  SD3.D3_EMISSAO >= '"+DTOS(MV_PAR02)+"' " 
      ELSE
         _Query += "                                  AND  SD3.D3_EMISSAO BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' " 
      ENDIF
   ENDIF
   _QUERY += " ORDER BY D3_EMISSAO , D3_OP , D3_COD "

Endif

oProc:cCaption := "Lendo OPs Filhas, Aguarde..."
ProcessMessages()

_Query := ChangeQuery(_Query)
MPSysOpenQuery( _Query, "QRT" ) 

DbSelectArea("QRT")
COUNT TO nCountRec //Contabiliza o numero de registros encontrados pela query
		
If nCountRec = 0

   U_ITMSG("Não tem registros para esses filtros: Cods: "+_cCodFiltro+", CC: "+_cCustos,'Atenção!',"Seleciones outros filtros e tente novamente",1)
   RETURN .F.

ENDIF

_aDados:={}
QRT->(DBGOTOP())
DO WHILE QRT->(!EOF())

   IF !EMPTY(QRT->D3_I_QTORI)
	   AADD(_aDados, { QRT->D3_OP,DTOC(STOD(QRT->D3_EMISSAO)),QRT->D3_COD } )
   ENDIF   

	QRT->(DBSKIP())
	
ENDDO

                                       // _aHeader , _aCols,_lMaxSiz,_nTipo ,_cMsgTop ,_lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons )
IF LEN(_aDados) > 0
   bBloco:={||U_ITListBox( 'OPs já rateadas (MEST016) ',;
                     {'OP','Data Emissao','Produto'},_aDados,.F.     ,1      ,         ,         ,;
                     { 50,            55,        50})  }//,, _bOK,_bCancel )
   IF !U_ITMSG("Existem OPs que já foram rateadas",'Atenção!',"Deseja continuar mesmo assim? ",3,2,2,,,,bBloco)
      RETURN .F.
   ENDIF
ENDIF

QRT->(DBGOTOP())
_aOProd:={}
_nTotVlN:=_nTotOPs:=_nConta:=0
_cTotOPs:=ALLTRIM(STR(nCountRec))
_nTam:=LEN(_cTotOPs)+1
_aTotProds:={}

SD4->(DBSETORDER(2))

DO WHILE QRT->(!EOF())
	
	SD3->(DBGOTO( QRT->REC_SD3 ))
	
	_nConta++
	oProc:cCaption := "1/2-Lendo OP: "+SD3->D3_OP+" - "+STR(_nConta,_nTam)+" de "+_cTotOPs
	ProcessMessages()

	//*********************************   PRODUTO PAI  ****************************
	IF SD3->D3_CF = "PR0"
		
			nQtdeSD4:=0
			nRecSD4 :=0
		                //OP + CC                           ,Data                 ,           ,Qtde Apontada   ,Prod Filho ,Qtde Consumida              ,Rateio          ,Valor Novo      ,Qtde Emepnho           ,REC SD3      ,REC SD4 ,Valor para gravar
		                //01                                ,02                   ,03         ,04              ,05         ,06                          ,07              ,08              ,09                     ,10           ,11      ,12
		AADD(_aOProd, { ALLTRIM(SD3->D3_OP)+" - "+SD3->D3_CC,DTOC(SD3->D3_EMISSAO),SD3->D3_COD,TRANS(SD3->D3_QUANT,_cPicT3),""         ,TRANS(0,_cPicT3),TRANS(0,_cPicTR),TRANS(0,_cPicTR),TRANS(nQtdeSD4,_cPicT4), QRT->REC_SD3, nRecSD4,0 } )
		_nTotPR0+=SD3->D3_QUANT
		
	ELSEIF SD3->D3_CF = "RE1"
		
		//*********************************   PRODUTO FILHO  ****************************
		IF SD4->(DBSEEK(SD3->D3_FILIAL+SD3->D3_OP+SD3->D3_COD+SD3->D3_LOCAL))
			nQtdeSD4:=SD4->D4_QTDEORI
			nRecSD4 :=SD4->(RECNO())
		ELSE
			nQtdeSD4:=0
			nRecSD4 :=0
		ENDIF
		                //OP + CC                           ,Data                 ,  ,Qtde Apontada   ,Prod Filho ,Qtde Consumida              ,Rateio          ,Valor Novo      ,Qtde Emepnho           ,REC SD3      ,REC SD4 ,Valor para gravar
		                //01                                ,02                   ,03,04              ,05         ,06                          ,07              ,08              ,09                     ,10           ,11      ,12
		AADD(_aOProd, { ALLTRIM(SD3->D3_OP)+" - "+SD3->D3_CC,DTOC(SD3->D3_EMISSAO),"",TRANS(0,_cPicT3),SD3->D3_COD,TRANS(SD3->D3_QUANT,_cPicT3),TRANS(0,_cPicTR),TRANS(0,_cPicTR),TRANS(nQtdeSD4,_cPicT4), QRT->REC_SD3, nRecSD4,0                } )
		_nTotOPs+=SD3->D3_QUANT
		
	ENDIF
	
	IF (nPos:=ASCAN(_aTotProds, {|P| P[1] == SD3->D3_COD+SD3->D3_CF})) = 0
                        //1-CODIGO               ,2-QUATANTIDADE .3- MAIOR,4-POSICAO,5-SOMA RATEIO,6-SOMA QTDE NOVA
		AADD(_aTotProds,{ SD3->D3_COD+SD3->D3_CF , SD3->D3_QUANT ,   0    ,    0    ,     0       ,   0            })
	ELSE
		_aTotProds[nPos,2]+=SD3->D3_QUANT
	ENDIF
	
	QRT->(DBSKIP())
	
ENDDO

_nTotVlN:=_nTotRat:=_nConta:=0
_cTotOPs:=ALLTRIM(STR(LEN(_aOProd)))
_nPosMaior:=0
MV_PAR06:=MV_PAR06

FOR P := 1 TO LEN(_aOProd)

   SD3->(DBGOTO( _aOProd[P,10] ))

   _nConta++
   oProc:cCaption := "2/2-Calculando OP: "+SD3->D3_OP+" - "+STR(_nConta,_nTam)+" de "+_cTotOPs
   ProcessMessages()

	IF (nPos:=ASCAN(_aTotProds, {|P| P[1] == SD3->D3_COD+SD3->D3_CF })) <> 0
      _nRateio    := ROUND(MV_PAR01*(SD3->D3_QUANT/_aTotProds[nPos,2]),3)

      _aTotProds[nPos,5]+= _nRateio//SOMATORIA RATEIO 

      IF _nRateio > _aTotProds[nPos,3]
        _aTotProds[nPos,3]:=_nRateio
        _aTotProds[nPos,4]:=P
      ENDIF   

      IF MV_PAR06 = 1//1-Acrescimo,2-Abatimento
         _nRateio:=(_nRateio*-1)
      ENDIF

      _aTotProds[nPos,6]+= (SD3->D3_QUANT+_nRateio)//SOMATORIA VALOR NOVO
      _aOProd[P,07]:= TRANS(_nRateio,_cPicT3)//Rateio
      _aOProd[P,08]:= TRANS(SD3->D3_QUANT+_nRateio,_cPicT3)//Valor Novo
      _aOProd[P,12]:= SD3->D3_QUANT+_nRateio//Valor para grava na tabela na integra
   ENDIF   

NEXT

FOR P := 1 TO LEN(_aTotProds)
	
	IF (MV_PAR01 - _aTotProds[P,5] <> 0)
		
		_nVlrDif:=(MV_PAR01 - _aTotProds[P,5])//_nTotRat
		_nPosMaior:=_aTotProds[P,4]
		
		_aTotProds[P,5]+= _nVlrDif//SOMA RATEIO

        IF MV_PAR06 = 1//1-Acrescimo,2-Abatimento
           _nVlrDif:=(_nVlrDif*-1)
         ENDIF
		_aTotProds[P,6]+= _nVlrDif//SOMA QTDE NOVA
		_aOProd[_nPosMaior,07]:= TRANS( VAL( StrTran(StrTran(_aOProd[_nPosMaior,7],".",""),",",".") )+_nVlrDif ,_cPicT3)//Rateio
		_aOProd[_nPosMaior,08]:= TRANS( VAL( StrTran(StrTran(_aOProd[_nPosMaior,8],".",""),",",".") )+_nVlrDif ,_cPicT3)//Valor Novo
		_aOProd[_nPosMaior,12]:= _aOProd[_nPosMaior,12]+_nVlrDif//Valor para grava na tabela na integra
		
	ENDIF
	
	//                //1-CODIGO               ,2-QUATANTIDADE .3- MAIOR,4-POSICAO,5-SOMA RATEIO,6-SOMA QTDE NOVA
	//AADD(_aTotProds,{ SD3->D3_COD+SD3->D3_CF , SD3->D3_QUANT ,   0    ,    0    ,     0       ,   0            })
	
	AADD(_aOProd, {"---------------------","---------------------","---------------------","","","","","","",0,0,0} )

	_cQtde:=ALLTRIM(TRANS(_aTotProds[P,2],"@E 999,999,999,999,999,999.999"))
	AADD(_aOProd, {"Total Produto:" ,_aTotProds[P,1],_cQtde,"","","","","","",0,0,0} )
	
	_cQtde:=ALLTRIM(TRANS(_aTotProds[P,5],"@E 999,999,999,999,999,999.999"))
	AADD(_aOProd, {"Total Rateio:"  ,_aTotProds[P,1],_cQtde,"","","","","","",0,0,0} )
	
	_cQtde:=ALLTRIM(TRANS(_aTotProds[P,6],"@E 999,999,999,999,999,999.999"))
	AADD(_aOProd, {"Total Qtd Novo:",_aTotProds[P,1],_cQtde,"","","","","","",0,0,0} )

NEXT
                                                                 '
Return .T.
