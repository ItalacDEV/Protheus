/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 06/12/2018 | Chamado 27271. Nova valida��o da observa��o dos armazens 1=Fisicos e 2=Virtuais
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 15/04/2019 | Chamado 28685. Valida��o p/ n�o permitir fracionamento de UM que s�o inteiras.
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 19/09/2024 | Chamado 48569. Incluir a rotina de Desconto Tetra Pak nas exce��es para valida��o de acesso
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: MT260TOK
Autor-------------: Tiago Correa Castro
Data da Criacao---: 25/04/2009
===============================================================================================================================
Descri��o---------: Ponto de Entrada que valida movimento de transferencia modelo I	
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: L�gico validando o lan�amento 
===============================================================================================================================
*/ 
User Function MT260TOK

Local _aArea    := FWGetArea()
Local _aAreaZZL := ZZL->(FWGetArea())
Local _aAreaSB1 := SB1->(FWGetArea())
Local _aAreaSB2 := SB2->(FWGetArea())
Local _lRet		:=	.T.  
Local _nDifPrd	:= 0                                                             
Local _nDifCM	:= 0   
Local _nCMorig	:= 0    
Local _nCMdest	:= 0  
Local _aSldNeg	:= 0 
Local _nDif		:= 0
Local _lValidFrac1UM:= .T.
Local _cUmNoFra		:= U_ITGetMV("IT_UMNOFRAC","PC,UN")

ZZL->(DbSetOrder(3))
If ZZL->(DbSeek(xFilial("ZZL")+RetCodUsr()))
	If ZZL->ZZL_AUTSIM <> 'S' .And. !FWIsInCallStack("DESCTETRAE") .And. !FWIsInCallStack("DESCTETRAE") //N�o validar quando for estorno de NF-e da Tetra Pak
    	FWAlertWarning("Usu�rio sem permiss�o para realizar transfer�ncia simples. N�o ser� poss�vel realizar a transfer�ncia. Entre em contato com o suporte do TI.", "MT260TOK01")
    	_lRet := .F.
	ElseIf !(cLocOrig $ ZZL->ZZL_ARMAZE)
    	FWAlertWarning("Usu�rio sem permiss�o para utilizar este armazem de origem. N�o ser� poss�vel realizar o estorno da transfer�ncia simples. Armazens permitidos ao usu�rio: '"+;
						AllTrim(ZZL->ZZL_ARMAZE)+"'. Entre em contato com o suporte do TI.","MT260TOK02")
      	_lRet := .F.
    ElseIf !(cLocDest $ ZZL->ZZL_ARMAZE)
       	FWAlertWarning("Usu�rio sem permiss�o para utilizar este armazem de destino. N�o ser� poss�vel realizar a transfer�ncia simples. Armazens permitidos ao usu�rio: '"+;
         				AllTrim(ZZL->ZZL_ARMAZE)+"'. Entre em contato com o suporte do TI.","MT260TOK03")
         _lRet := .F.
	ElseIf Substr(cCodOrig,1,4) == "0006" .And. nQuant260D == 0
		 FWAlertWarning("Para esse produto e obrigat�rio o preenchimento da segunda unidade de medida (Pe�as).","MT260TOK04")
		 _lRet := .F.
	ElseIf SuperGetMV("IT_BLQMOV",.F., "") .And. Demis260 > DATE()
	  FWAlertWarning("Movimento com data maior que a data atual, os movimentos com data maior que a data atual est�o bloqueados. Entre em contato com o suporte do TI.","MT260TOK05")
	  _lRet := .F.
	ElseIf cLocOrig == '34' .or. cLocDest == '34'
   		FWAlertWarning("N�o � permitida transfer�ncia simples usando armaz�m 34. Utilize a rotina de transfer�ncia multipla","MT260TOK06")
		_lRet := .F.	
	Else
		NNR->(DBSetOrder(1))
		NNR->(DBSeek(xFilial("NNR")+cLocOrig))
		_cTipoOrigem := NNR->NNR_I_TPFV
		NNR->(DBSeek(xFilial("NNR")+cLocDest))
		_cTipoDestino := NNR->NNR_I_TPFV
		//Virtual               //Fisico
		If _cTipoOrigem <> _cTipoDestino 
			FWAlertWarning("N�o � permitido tranferir produtos entre armazem virtual "+cLocOrig+" e armazem fisico "+cLocDest+" nessa rotina. "+;
					"Utilize a rotina tranferencia multipla para prencher o campo de observa��o","MT260TOK07")
			_lRet := .F.
		EndIf

		If cCodOrig <> cCodDest
			If AllTrim(cCodOrig) $ (U_ITGetMV("ITLTGRN",'08000000062')+U_ITGetMV("ITLTMP",'08000000034')+U_ITGetMV("ITCRGRN",'08000000063;08000000064')+U_ITGetMV("ITCRMP",'08000000007'));
				.And. AllTrim(cCodDest) $ (U_ITGetMV("ITLTGRN",'08000000062')+U_ITGetMV("ITLTMP",'08000000034')+U_ITGetMV("ITCRGRN",'08000000063;08000000064')+U_ITGetMV("ITCRMP",'08000000007'))
				If AllTrim(cLocOrig) == "03" .And. AllTrim(cLocDest) == "03"
					_lRet := .T.
				Else
					FWAlertWarning("Para a transfer�ncia entre esses produtos favor utilizar somente o armaz�m 03 para origem e destino!","MT260TOK08")
					_lRet := .F.
				EndIf
			Else
				FWAlertWarning("A opera��o n�o pode ser conclu�da com produtos de origem e destino divergentes!","MT260TOK09")
				_lRet := .F.
			EndIf
		EndIf
		//Verifica saldo do produto. Chamado 7816
		If _lRet
			_aSldNeg := U_VldEstRetrNeg(cCodOrig, cLocOrig, nQuant260, Demis260)	
			If Len(_aSldNeg) > 0
				_nDif := _aSldNeg[2] - nQuant260
				FWAlertWarning("Quantidade requisitada � maior que o saldo no dia "+DtoC(_aSldNeg[1])	+" para o produto: "+CHR(13)+CHR(10)+Alltrim(cCodOrig)+"-"+cLocOrig+". Diferenca: ";
						+AllTrim(TRANSFORM(_nDif, "@E 999,999,999,999.99")), "Saldo Insuficiente. Verifique o saldo no Kardex.","MT260TOK10")
				_lRet := .F.
			EndIf
		EndIf
		//=====================================================
		//Verificacao do CM origem e Destino                  |
		//=====================================================
		If _lRet
			_nDifCM 	:= SuperGetMV("IT_DIFCM",.F., 0) //Percentual minimo de diferenca de CM para bloquear processo. (71%)
			_nDifCM2	:= SuperGetMV("IT_DIFCM2",.F., 0) //Percentual minimo de diferenca de CM para exibir mensagem se continua ou nao. (51%)
			_nCMorig 	:= Posicione("SB2",1,xFilial("SB2")+cCodOrig+cLocOrig,"B2_CM1")//SEEK NO PRODUTO DE DESTINO

			SB2->(DBSeek(xFilial("SB2")+cCodDest+cLocDest))//Produto de destino
			_nCMdest := SB2->B2_CM1
			
			If _nCMdest > 0 .AND. !(SB2->B2_QATU == 0 .And. SB2->B2_VATU1 == 0)//Produto de Destino
				_nDifPrd := (_nCMdest - _nCMorig) / _nCMorig
				If _nDifPrd < 0 
					_nDifPrd := (_nDifPrd * (-1))
				Endif 
				_nDifPrd := _nDifPrd * 100
			
				If _nDifPrd >= _nDifCM2 .and. _nDifPrd < _nDifCM //Diferenca entre 51% e 70%
					If !FWAlertYesNo("ATEN��O! Diferen�a entre valor de Custo Medio de Origem e Destino � "+TRANSFORM(_nDifPrd, "@E 999.9999")+"%. Deseja prosseguir?","MT260TOK11")
					_lRet := .F.		
					Endif
				Elseif _nDifPrd >= _nDifCM //Diferenca maior que 70%
					FWAlertWarning("Transfer�ncia n�o permitida! Diferen�a entre valor de Custo Medio de Origem e Destino � "+TRANSFORM(_nDifPrd, "@E 999.9999")+"%"+;
								"Favor analisar o Kardex! Se necess�rio, entre em contato com o Depto. de TI.","MT260TOK12")
					_lRet := .F.	
				Endif
			Endif   
		Endif
	
		IF _lRet
			If ZZL->ZZL_PEFRPA == "S"
				_lValidFrac1UM:=.F.
			EndIf
			
			SB1->(DBSetOrder(1))
			IF _lValidFrac1UM .And. SB1->(DBSeek(xFilial("SB1") + cCodOrig))
				IF (SB1->B1_UM $ _cUmNoFra .And. nQuant260 <> Int(nQuant260))
					FWAlertWarning("N�o � permitido fracionar a quantidade da 1a. UM de produto onde a Unid. Medida for "+_cUmNoFra+". "+;
							"Favor informar apenas quantidades inteiras na Primeira Unidade de Medida.","MT260TOK13")
					_lRet := .F.
				ENDIF
				IF (SB1->B1_SEGUM $ _cUmNoFra .And. nQuant260D <> Int(nQuant260D))
					FWAlertWarning("N�o � permitido fracionar a quantidade da 2a. UM de produto onde a Unid. Medida for "+_cUmNoFra+". "+;
							"Favor informar apenas quantidades inteiras na Segunda Unidade de Medida.","MT260TOK14")
					_lRet := .F.
				ENDIF
			ENDIF
		EndIf
	EndIf
Else
   FWAlertWarning("Usu�rio sem cadastro na ZZL. Entre em contato com o suporte do TI.","MT260TOK15")
   _lRet := .F.
EndIf

SB2->(FwRestArea(_aAreaSB2))
SB1->(FwRestArea(_aAreaSB1))
ZZL->(FwRestArea(_aAreaZZL))
FwRestArea(_aArea)

Return _lRet
