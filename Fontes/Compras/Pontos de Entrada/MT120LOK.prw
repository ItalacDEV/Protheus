/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Jerry         | 10/06/2015 | Chamado 10532. Correcao na validacao do campo C7_I_DTFAT.    
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich  | 26/01/2015 | Chamado 23367. Força preenchimento do C7_I_DESCD.        
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 03/10/2019 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25.
-------------------------------------------------------------------------------------------------------------------------------
Jonathan      | 04/06/2020 | Chamado 33149. Inserido nova condição para atender validação do campos C7_PRECO.
-------------------------------------------------------------------------------------------------------------------------------
Jonathan      | 28/07/2020 | Chamado 33673. Nova validação para o campo C7_I_USOD quando aplicação = "S".
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 30/03/2023 | Chamado 43439. Posicionado no recno do sc7 - penultima COLUNA do acols (LEN(aCols[n])-1).
==================================================================================================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==================================================================================================================================================================================================================
Jerry    - Julio Paz     - 05/02/25 - 26/02/25 -  49465  - Validar a data de faturamento apenas para itens com saldo: (C7_QUANT-C7_QUJE) > 0. (MT120LOK002)
==================================================================================================================================================================================================================

*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"

#DEFINE ENTER	Chr(13)+Chr(10)
/*
===============================================================================================================================
Programa----------: MT120LOK
Autor-------------: Renato de Morcerf
Data da Criacao---: 03/02/2009
===============================================================================================================================
Descrição---------: Ponto de entrada na validação de LINHA dos pedidos de compras
===============================================================================================================================
Parametros--------: _lVldDif (.T./.F.): _nPerc:=IF(_lVldDif, U_ITGetMv("IT_PERCAVS",10),0)
===============================================================================================================================
Retorno-----------: _lRet (.T./.F.): define se pode confirmar a validação de linha dos pedidos de compras
===============================================================================================================================
*/
User Function MT120LOK(_lVldDif)
                                                                                         
Local _aArea		:= GetArea()
Local _nPa			:= 0
Local _cPl 			:= ""
Local _nPa2  		:= 0
Local _nPl2 		:= 0
Local _lRet 		:= .T.   
Local _nPosNomFo	:= 0
Local _nPosDtFat	:= 0
Local _nPosdescd	:= 0
Local _nDtLimFt		:= U_ItGetMv("IT_DTLIMFT"	,30		)	// Limite de dias para data de Faturamento
Local _dLimFt		:= Date() + _nDtLimFt					// Data limite maximo para data de Faturamento
Local _dLimAnt		:= Date() - _nDtLimFt					// Data limite minimo para data de Faturamento
Local _cQuery		:= ""
Local _cNwAlia		:= GetNextAlias()
Local _nPerc		:= IIF(_lVldDif, U_ITGetMv("IT_PERCAVS",10),0)
Local _nDif			:= 0
Local _nPosAP		:= 0

Default _lVldDif	:= .F.


IF cAplic == "S"
	_nPosAP := aScan( aHeader, {|x| Alltrim(x[2]) == "C7_I_USOD"})
	aCols[N][_nPosAp] := "N"
ENDIF

IF !_lVldDif
	_nPa      := aScan( aHeader, { |x| Alltrim(x[2])== "C7_PRODUTO" } )  
	_nPosNomFo:= aScan( aHeader, { |x| Alltrim(x[2])== "C7_I_NFORN" } ) 
	_nPosDtFat:= aScan( aHeader, { |x| Alltrim(x[2])== "C7_I_DTFAT" } ) 
	_cPl 	:= 	acols[n,_nPa]
		
	If aCols[n][Len(aHeader)+1] == .F. //Linha nao Deletada
		If Substr(_cPl,1,4) = "0006"
			_nPa2  :=  aScan( aHeader, { |x| Alltrim(x[2])== "C7_QTSEGUM" } )
			_nPl2 := acols[n,_nPa2]
			If _nPl2 = 0
				u_itmsg("Segunda Unidade de Medida Vazio, Para esse produto e obrigatorio o preenchimento da segunda unidade de medida (Peças) ", "MT120LOK001",; 
							"Favor preencher a segunda unidade de medida (Peças)!!",1 )
				_lRet := .F.
			EndIf
		EndIf
	EndIf
			
	//=========================================================================
	//Caso nao encontre nenhum problema na validacao acima         
	//eh inserida a descricao do fornecedor fornecido no pedido de 
	//compra.                                                      
	//=========================================================================
	
	If _lRet

		_nPosDtFat         := ASCAN( aHeader, { |x| Alltrim(x[2])== "C7_I_DTFAT" } )
		_nPosdescd         := ASCAN( aHeader, { |x| Alltrim(x[2])== "C7_I_DESCD" } )
		aCols[n,_nPosNomFo]:= ALLTRIM(POSICIONE("SA2",1,XFILIAL("SA2") + CA120FORN + CA120LOJ,"SA2->A2_NOME") )  
		aCols[n,_nPosdescd]:= POSICIONE("SB1",1,xFilial("SB1")+ALLTRIM(acols[n,_nPa]),"B1_I_DESCD")                                                                       
          
		If !Empty(aCols[n,_nPosDtFat])

			If Altera .AND. aCols[n, LEN(aCols[n])-1  ] > 0 //RECNO DO SC7 

	           SC7->(DBGOTO(aCols[n, LEN(aCols[n])-1  ]))//POSICIONA NO RECNO DO SC7 - PENULTIMA COLUNA DO ACOLS (LEN(aCols[n])-1)
		
				If _lRet 							   
					If (SC7->C7_QUJE >= SC7->C7_QUANT) .AND. SC7->C7_I_DTFAT <> acols[n,_nPosDtFat]
						Help(" ",1,"A120ALTPC")
						aCols[n,_nPosDtFat]:= SC7->C7_I_DTFAT
						_lRet := .F.
					EndIf
			
					If SC7->C7_RESIDUO == "S" .AND. SC7->C7_I_DTFAT <> acols[n,_nPosDtFat]
						Help(" ",1,"A120RESID")
						aCols[n,_nPosDtFat]:= SC7->C7_I_DTFAT
						_lRet := .F.
					EndIf
					If (SC7->C7_QTDACLA + SC7->C7_QUJE) > SC7->C7_QUANT .AND. SC7->C7_I_DTFAT <> acols[n,_nPosDtFat]
						Help(" ",1,"A120ALT")
						aCols[n,_nPosDtFat]:= SC7->C7_I_DTFAT
						_lRet := .F.
					EndIf				
				EndIf
			EndIf
			
			If _lRet .And. Inclui
    		   If aCols[n,_nPosDtFat] > _dLimFt .Or. aCols[n,_nPosDtFat] < _dLimAnt
				  u_itmsg("Data de Faturamento Informada Invalida! (" + DtoC(aCols[n,_nPosDtFat]) + ").", "MT120LOK002",; 
				          "Favor informar uma data maior ou igual a: " + DtoC(_dLimAnt) + " ou menor ou igual a " + DtoC(_dLimFt) + ".",1 )
				  
				  _lRet := .F.
			   EndIf
    		EndIf
			
            If _lRet .And. Altera .AND. aCols[n, LEN(aCols[n])-1  ] > 0 //RECNO DO SC7 

	           SC7->(DBGOTO(aCols[n, LEN(aCols[n])-1  ]))//POSICIONA NO RECNO DO SC7 - PENULTIMA COLUNA DO ACOLS (LEN(aCols[n])-1)
		
			   If (SC7->C7_QUANT - SC7->C7_QUJE) > 0 
      		      If aCols[n,_nPosDtFat] > _dLimFt .Or. aCols[n,_nPosDtFat] < _dLimAnt
				     u_itmsg("Data de Faturamento Informada Invalida! (" + DtoC(aCols[n,_nPosDtFat]) + ").", "MT120LOK003",; 
				          "Favor informar uma data maior ou igual a: " + DtoC(_dLimAnt) + " ou menor ou igual a " + DtoC(_dLimFt) + ".",1 )
				  
				     _lRet := .F.
			      EndIf
    		   EndIf
            EndIf 
		EndIf	 
	EndIf
			
	RestArea(_aArea)
ELSE
	_cQuery += "SELECT C7_PRODUTO, C7_NUM, C7_QUANT, C7_PRECO, C7_EMISSAO, C7_FORNECE, C7_LOJA FROM " + RetSqlName("SC7") + " C7 "
	_cQuery += " WHERE D_E_L_E_T_ <> '*' "
	_cQuery += " AND C7_PRODUTO = '" + AllTrim(aCols[n][2]) + "' "
	_cQuery += " AND C7_FILIAL = '" + cFilant +  "' "
	_cQuery += " AND R_E_C_N_O_ = (SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName("SC7") + " WHERE D_E_L_E_T_ <> '*' AND C7_FILIAL = '" +cFilAnt+ "' "
	_cQuery += " AND C7_PRODUTO = '" + AllTrim(aCols[n][2]) + "') "

	DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cNwAlia , .T. , .F. )

	_nDif := ROUND(((aCols[n][7]/(_cNwAlia)->C7_PRECO)-1)*100,2) 

	IF _nDif >= _nPerc .OR. _nDif <= (_nPerc * -1)
		U_ITMSG("Atenção! O último preço de compra para este produto teve uma variação de " + cValToChar(_nDif) + "% "+ENTER+;
				"Data da última compra: " +CVALTOCHAR(DAY(STOD((_cNwAlia)->C7_EMISSAO)))+"/"+STRZERO(MONTH(STOD((_cNwAlia)->C7_EMISSAO)),2)+ "/" + CVALTOCHAR(Year(STOD((_cNwAlia)->C7_EMISSAO))) +ENTER+;
				"Último valor praticado: R$ " +cValToChar((_cNwAlia)->C7_PRECO)+ENTER+;
				"PC - "+ (_cNwAlia)->C7_NUM + ENTER+;
				POSICIONE("SA2",1,xFilial("SA2")+Alltrim((_cNwAlia)->C7_FORNECE)+Alltrim((_cNwAlia)->C7_LOJA), "A2_NOME"), "Atenção!",,3)
	ENDIF

ENDIF

Return _lRet
