/*
=====================================================================================================================================
        						 ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
=====================================================================================================================================
   Autor       |	Data	     |										Motivo																
-------------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 11/10/2018 | Ajuste na validação do estoque negativo - Chamado 26614
-------------------------------------------------------------------------------------------------------------------------------------
 Josué Danich  | 28/03/2019 | Correção de leitura de aheader dinâmico - Chamado 28765
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 15/04/2019 | Validação p/ não permitir fracionamento de UM que são inteiras. Chamado 28685
=====================================================================================================================================
*/
#Include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: MT175ATU
Autor-------------: Andre Lisboa
Data da Criacao---: 23/03/2017 
===============================================================================================================================
Descrição---------: Ponto de entrada para validar Liberação/Rejeição do Material no CQ
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T. ou .F.
===============================================================================================================================
*/
User Function MT175ATU()
Local lRetorno 	:= .T.
Local aSalveArea:= SD7->(GetArea())
Local cProdut	:= SD7->D7_PRODUTO//SB2->B2_COD#
Local nCMAtu	:= 0//SB2->B2_CM1
Local aCMLib	:= U_VldCust(alltrim(cProdut), aCols[1,aScan(aHeader, {|x| AllTrim(x[2]) == "D7_LOCDEST"})], dDataBase)
Local nCMLib	:= aCMLib[1]
Local nDifCM	:= GETMV("IT_DIFCM",,15)
Local nDifCM2	:= GETMV("IT_DIFCM2",,10)
Local nDifCus	:= 0 , I
Local _cNum     := SD7->D7_NUMERO
Local _cLoca1   := SD7->D7_LOCAL
Local _nQtde , _dData , _cLocal ,  _cSeq
Local _lRet1:= .T.
Local _lRet2:= .T.
Local _lValidFrac1UM:=.T.


ZZL->( DBSetOrder(3) )
If ZZL->( DBSeek( xFilial("ZZL") + RetCodUsr() ) )
   If ZZL->(FIELDPOS("ZZL_PEFRPA")) = 0 .OR. ZZL->ZZL_PEFRPA == "S"
	  _lValidFrac1UM:=.F.
   EndIf
EndIf
ZZL->( DBSetOrder(1) )
SB1->( DBSETORDER(1) )
SB1->(dbSeek(xFilial("SB1") + cProdut ))
SB2->( DBSETORDER(1) )

FOR I := 1 TO LEN(aCols)
	
	IF !EMPTY(aCols[I][aScan(aHeader, {|x| AllTrim(x[2]) == "D7_REC_WT"})] )
		LOOP
	ENDIF
	
	If _lValidFrac1UM .AND. SB1->B1_TIPO == "PA"
		If SB1->B1_UM == "UN"
			_nQtde := aCols[I][aScan(aHeader, {|x| AllTrim(x[2]) == "D7_QTDE"})]
			If _nQtde <> Int(_nQtde)
				_lRet1:= .F.
			EndIf
		EndIf
		
		IF  SB1->B1_SEGUM = "PC" .AND. LEFT(cProdut,4)=="0006"
			_nQtSeg:= aCols[I][aScan(aHeader, {|x| AllTrim(x[2]) == "D7_QTSEGUM"})]
			IF _nQtSeg <> Int(_nQtSeg)
				_lRet2:= .F.
			ENDIF
		ENDIF
	ENDIF

   _cLocal:= aCols[I][aScan(aHeader, {|x| AllTrim(x[2]) == "D7_LOCDEST"})]
   IF !SB2->(DBSEEK(xFilial()+cProdut+_cLocal))
      LOOP
   ENDIF
   nCMAtu:= SB2->B2_CM1   

	If nCMLib > 0
		nDifCus:= (nCMAtu - nCMLib) / nCMLib
		If nDifCus < 0 
			nDifCus := (nDifCus * (-1))
		Endif 
		nDifCus := nDifCus * 100
	
		If nDifCus >= nDifCM2 .and. nDifCus < nDifCM //Diferenca entre 51% e 70%
			If !U_ITMSG("Diferença entre valor de Custo Medio de Origem ["+aCols[1,aScan(aHeader, {|x| AllTrim(x[2]) == "D7_LOCDEST"})]+;
                           "] e Destino ["+_cLocal+"] é "+TRANSFORM(nDifCus, "@E 999.9999")+"%.","ATENÇÃO!","DESEJA PROSSEGUIR?",3,2,2)
		   	   lRetorno := .F.		
			Endif
	 	Elseif nDifCus >= nDifCM //Diferenca maior que 70%
			U_ITMSG("Transferência não permitida! Diferença entre valor de Custo Medio de Origem ["+aCols[1,aScan(aHeader, {|x| AllTrim(x[2]) == "D7_LOCDEST"})]+;
                              "] e Destino ["+_cLocal+"] é "+TRANSFORM(nDifCus, "@E 999.9999")+"%",;
	                "Atenção!",;
					"Favor analisar o Kardex! Se necessário, entre em contato com o Depto. de TI.",1)
			lRetorno := .F.	
	 	Endif
	Endif

NEXT

SD7->( DBSETORDER(1) )
_aLancs:={}


FOR I := 1 TO LEN(aCols)

   _cSeq  := aCols[I][aScan(aHeader, {|x| AllTrim(x[2]) == "D7_SEQ"})]   

   IF EMPTY(aCols[I][aScan(aHeader, {|x| AllTrim(x[2]) == "D7_ESTORNO"})] ) .OR.;
      (SD7->(DBSEEK(xFilial()+_cNum+cProdut+_cLoca1+_cSeq)) .AND. !EMPTY(SD7->D7_ESTORNO))
      LOOP
   ENDIF

   _dData := aCols[I][aScan(aHeader, {|x| AllTrim(x[2]) == "D7_DATA"})]
   _cLocal:= aCols[I][aScan(aHeader, {|x| AllTrim(x[2]) == "D7_LOCDEST"})]
   _nQtde := aCols[I][aScan(aHeader, {|x| AllTrim(x[2]) == "D7_QTDE"})]

   IF (nPos:=ASCAN(_aLancs,{|D| D[1] == _dData .AND. D[2] == _cLocal })) = 0
      AADD(_aLancs,{_dData,_cLocal,_nQtde})
   ELSE   
      _aLancs[nPos,3]+=_nQtde
   ENDIF
   
NEXT

If _lValidFrac1UM
	IF !_lRet1
		U_ITMSG("Não é permitido fracionar a quantidade da 1a. UM de produto onde a Unid. Medida for UN.",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
		        "Validação Fracionado",;
		        "Favor informar apenas quantidades inteiras na Primeira Unidade de Medida.",1)		
		lRetorno := .F.
	ENDIF
	IF !_lRet2
		U_ITMSG("Não é permitido fracionar a quantidade da 2a. UM de produto do grupo 0006 onde a Unid. Medida for PC.",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
		        "Validação Fracionado",;
		        "Favor informar apenas quantidades inteiras na Segunda Unidade de Medida.",1)		
		lRetorno := .F.
	ENDIF
ENDIF

FOR I := 1 TO LEN(_aLancs)

   _dData := _aLancs[I,1]
   _cLocal:= _aLancs[I,2]
   _nQtde := _aLancs[I,3]

   aSldNeg := U_VldEstRetrNeg(SD7->D7_PRODUTO,_cLocal,_nQtde,_dData)

   If Len(aSldNeg) > 0
      lRetorno := .F.
	  U_ITMSG("Não permitido, o saldo SOMADO estornado deixará o produto com saldo negativo: "+SD7->D7_PRODUTO+_cLocal+;
               " na data " +DTOC(aSldNeg[1]), "Atenção!",;
   		      "Verificar o saldo através do kardex do produto",1)
   Endif

NEXT

RestArea(aSalveArea)

Return lRetorno
