/*
=====================================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
=====================================================================================================================================
	Autor	    |	Data	|										Motivo																 
=====================================================================================================================================
Alex Wallauer  | 08/04/2019 | Chamado 28685. Valida��o p/ n�o permitir fracionamento p/ PAs onde a 1a UM for UN. 
Alex Wallauer  | 11/09/2019 | Chamado 30551. corre��o de error.log de variavel n�o � numerica. 
Lucas Borges   | 03/10/2019 | Chamado 28346. Removidos os Warning na compila��o da release 12.1.25. 
Alex Wallauer  | 22/10/2019 | Chamado 30921. Tratamento para o campo NOVO CLAIM.  
Alex Wallauer  | 16/12/2019 | Chamado 31462. Novas Validado�oes para os campos custumizados.  
Alex Wallauer  | 20/07/2020 | Chamado 36102. Ajuste na valida��o da 2 UM para validar quando for Copia.  
Jonathan       | 28/07/2020 | Chamado 33673. Nova valida��o para o campo C7_I_USOD quando aplica��o = "S". 
Alex Wallauer  | 21/03/2022 | Chamado 38650. Validacao para o usuario de leite s� incluir item = MP. 
Igor Melga�o   | 12/07/2022 | Chamado 40620. Valida��o dos campos de projeto e Subinvestimento.
Igor Melga�o   | 13/07/2022 | Chamado 40620. Corre��o de valida��o somente qdo a aplica��o for investimento. 
Alex Wallauer  | 21/10/2022 | Chamado 41652. Permitir fracionar produtos <> "PA" quando o campo ZZL_PEFROU for = "S". 
Igor Melga�o   | 13/07/2022 | Chamado 43230. Ajuste para inclus�o de parametro para compara��o com B1_TIPO 
Alex Wallauer  | 20/03/2023 | Chamado 43320. Nova validacao do campo data de faturamento (C7_I_DTFAT).
Alex Wallauer  | 15/07/2024 | Chamado 47732. Nova validacao do campo condicao de pagamento (cCondicao).
========================================================================================================================================================================
Analista       - Programador   - Inicio   - Envio    - Chamado - Motivo da Altera��o
========================================================================================================================================================================
Andr� Carvalho - Alex Wallauer - 14/10/24 - 25/10/24 - 48836   - Nova valida��o n�o permitir informar aliquota de ICMS e IPI para produtos do B1_TIPO = "SV".
Andr� Carvalho - Alex Wallauer - 28/10/24 - 28/10/24 - 48836   - Retirada de uma valida��o inconcistente.
Andr� Carvalho - Igor Melga�o  - 25/11/24 - 17/02/25 - 49104   - Ajustes para envio de email na altera��o da previs�o do pedido de compra
Andr� Carvalho - Alex Wallauer - 03/07/25 -          - 50990   - Validacao do campo C7_PICM contra AIB_I_PICM. 
========================================================================================================================================================================
*/
#include "rwmake.ch"
#include "protheus.ch"

/*
===============================================================================================================================
Programa----------: MT120OK
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 07/10/2015
===============================================================================================================================
Descri��o---------: Rotina responsavel pelas valida��es dos campos que est�o no cabe�alho do pedido de compras.
					Localiza��o: Function A120TudOk() respons�vel pela valida��o de todos os itens da GetDados do Pedido de 
					Compras / Autoriza��o de Entrega.
					Em que Ponto: O ponto se encontra no final da fun��o e � disparado ap�s a confirma��o dos itens da getdados 
					e antes do rodap� da dialog do PC, deve ser utilizado para valida��es especificas do usuario onde ser� 
					controlada pelo retorno do ponto de entrada oqual se for .F. o processo ser� interrompido e se .T. ser� validado.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: lRet -> Se .T. linha validada segue o processo, Se .F. interrompe o processo
===============================================================================================================================
*/
User Function MT120OK()

Local aArea       := GetArea() As Array
Local lRet        := .T. As Logic
Local _lRet2      := .T. As Logic
Local aMensagem   := {} As Array
Local aProbl      := {} As Array
Local aSoluc      := {} As Array
Local aProblList  := {} As Array
Local nX          := 0 As Numeric
Local nI          := 0 As Numeric
Local x           := 0 As Numeric
Local nPosCLA     := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_I_CLAIM"}) As Numeric
Local nPosApl     := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_I_APLIC"}) As Numeric
Local nPosInv     := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_I_CDINV"}) As Numeric
Local nPosUrg     := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_I_URGEN"}) As Numeric
Local nPosNsc     := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_NUMSC"}) As Numeric
Local nPosISC     := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_ITEMSC"}) As Numeric
Local nPosDTPRF   := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_DATPRF"}) As Numeric
Local nPosObs     := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_OBS"}) As Numeric
Local _nPosNomFo  := aScan(aHeader, {|x| Alltrim(x[2]) == "C7_I_NFORN"}) As Numeric
Local _nC7QUANT   := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_QUANT"}) As Numeric
Local _nC7SEGUM   := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_QTSEGUM"}) As Numeric
Local _nC7ITEM    := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_ITEM"}) As Numeric
Local _nPa        := aScan(aHeader, {|x| Alltrim(x[2]) == "C7_PRODUTO"}) As Numeric
Local _nPosdescd  := aScan(aHeader, {|x| Alltrim(x[2]) == "C7_I_DESCD"}) As Numeric
Local _nPosUsod   := aScan(aHeader, {|x| Alltrim(x[2]) == "C7_I_USOD"}) As Numeric
Local _nPosCDINV  := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_I_CDINV"}) As Numeric
Local _nPosDSINV  := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_I_DSINV"}) As Numeric
Local _nPosSUBIN  := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_I_SUBIN"}) As Numeric
Local _nPosSUIND  := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_I_SUIND"}) As Numeric
Local _nPosDtFat  := aScan(aHeader, {|x| Alltrim(x[2]) == "C7_I_DTFAT"}) As Numeric
Local _nPosTabPre := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_CODTAB"}) As Numeric
Local _nPosPreco  := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_PRECO"}) As Numeric
Local _nSegu      := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_SEGUM"}) As Numeric
Local _nPosC7PICM := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_PICM"}) As Numeric
Local _nPosC7IPI  := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_IPI"}) As Numeric
Local _nPosItem   := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_ITEM"}) As Numeric
Local _nPosQtd    := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_QUANT"}) As Numeric
Local _ni         := 0 As Numeric
Local _cProds     := "" As Character
Local _cGrpLeite  := U_ItGetMV("IT_GRPFLEIT","000008,000009,000010,000011") As Character
Local _cPCGERAL   := U_ItGetMV("IT_PCGERAL"," ") As Character
Local _cUM_NO_Fracionada := SUPERGETMV("IT_UMNOFRAC",.F.,"PC,UN") As Character
Local _lValidFrac1UM := .T. As Logic
Local _cTipos     := U_ItGetMV("IT_TPPRDPC","MP,PP,PI" ) As Character
Local _cIT_PRDSVOK := SUPERGETMV("IT_PRDSVOK",.F.,"") As Character
Local _aAreaSc7   := {} As Array
Local aDifItens   := {} As Array

//For�a atualiza��o de campos C7_I_DESCD

For _ni := 1 to len(acols)

	aCols[_ni,_nPosdescd] := posicione("SB1",1,xFilial("SB1")+ALLTRIM(acols[_ni,_nPa]),"B1_I_DESCD")
	
Next


If Empty(cAplic)
	aProbl := {}
	aAdd(aProbl, "O campo Aplica��o deve ser informado.")

	aSoluc := {}
	aAdd(aSoluc, "Favor informar uma Aplica��o v�lida.")

	aMensagem := {"Aplica��o Obrigat�ria", aProbl, aSoluc}

	U_ITMsHTML(aMensagem)

	lRet := .F.
EndIf

If cAplic == "I" .And. Empty(cCInve)
	aProbl := {}
	aAdd(aProbl, "O campo Investimento deve ser informado.")

	aSoluc := {}
	aAdd(aSoluc, "Para Aplica��o do tipo Investimento, o campo C�digo do Investimento deve ser preenchido.")

	aMensagem := {"Investimento Obrigat�rio", aProbl, aSoluc}

	U_ITMsHTML(aMensagem)

	lRet := .F.
EndIf

If Empty(cTpFrete)
	aProbl := {}
	aAdd(aProbl, "O campo Tipo de Frete deve ser informado.")

	aSoluc := {}
	aAdd(aSoluc, "Favor preencher o campo de Tipo de Frete na Pasta Frete/Despesas.")

	aMensagem := {"Tipo de Frete Obrigat�rio", aProbl, aSoluc}

	U_ITMsHTML(aMensagem)

	lRet := .F.
EndIf

If Empty(cUrgen)
	aProbl := {}
	aAdd(aProbl, "O campo Urg�ncia deve ser informado.")

	aSoluc := {}
	aAdd(aSoluc, "Favor informar uma op��o v�lida.")

	aMensagem := {"Urg�ncia Obrigat�ria", aProbl, aSoluc}

	U_ITMsHTML(aMensagem)

	lRet := .F.
EndIf

If Empty(cCompD)
	aProbl := {}
	aAdd(aProbl, "O campo Compra Direta deve ser informado.")

	aSoluc := {}
	aAdd(aSoluc, "Favor informar uma op��o v�lida.")

	aMensagem := {"Compra Direta Obrigat�rio", aProbl, aSoluc}

	U_ITMsHTML(aMensagem)

	lRet := .F.

ELSE

   IF cCompD = "S" .AND. cUrgen <> "S"
      U_ITMSG("Campo urgente dever esta igual a SIM quando for compra direta igual a SIM",'Aten��o!',,1)
	  lRet := .F.
   ENDIF

EndIf

IF !EMPTY(cContato)
   cContato:=LimpaString(cContato)
   IF EMPTY(cContato)
      cContato:="."
   ENDIF
ENDIF

ZZL->( DBSetOrder(3) )
If ZZL->( DBSeek( xFilial("ZZL") + RetCodUsr() ) )
   If ZZL->ZZL_PEFRPA == "S"  .OR. ZZL->ZZL_PEFROU == "S"
	  _lValidFrac1UM:=.F.
   EndIf
EndIf
ZZL->(DBSETORDER(1))
AIA->(DBSETORDER(1))//AIA_FILIAL+AIA_CODFOR+AIA_LOJFOR+AIA_CODTAB
AIB->(DBSETORDER(2))//AIB_FILIAL+AIB_CODFOR+AIB_LOJFOR+AIB_CODTAB+AIB_CODPRO
SBZ->(DBSETORDER(1))//BZ_FILIAL+BZ_COD

_lValTabPreco:=.T.
_lDifTabPreco:=.F.
_lMenTabPreco:=.F.
For nX := 1 To Len(aCols)
	If !aCols[nX][Len(aHeader)+1]//N�O DELETADOS
       
       IF !EMPTY(aCols[nX][nPosObs])
          aCols[nX][nPosObs]:=LimpaString(aCols[nX][nPosObs])
       ENDIF		
       
	   //**************** AIA ****************************//       
	   IF EMPTY(aCols[nX][_nPosTabPre])
		  _lValTabPreco:=.F.
	   ELSEIF AIA->(DbSeek(xFilial("AIA")+CA120FORN+CA120LOJ+aCols[nX][_nPosTabPre])) 
          
		  IF SUBSTR(cTpFrete,1,1) <> AIA->AIA_I_TPFR
             AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "Tipo de Frete do PC : "+cTpFrete+", difere do Tipo de Frete: "+RetTipoFrete(AIA->AIA_I_TPFR)+" + da Tabela de Pre�os: "+aCols[nX][_nPosTabPre] , "Redigite o Item para recarregar o Tipo de Frete da tabela de pre�os." })
			 _lDifTabPreco:=.T.
		  ELSEIF U_ACOM36Cond(.F.)//Se alterou a condi��o de pagamanto/Tipo de Frete  do gatilho do produto(ACOM036.PRW)
		     _lMenTabPreco:=.T.
		  ENDIF	

	      IF cCondicao <> AIA->AIA_CONDPG 
             AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "Condi��o de Pagamento  do PC : "+cCondicao+", difere da Cond. Pagtp.: "+AIA->AIA_CONDPG+" + da Tabela de Pre�os: "+aCols[nX][_nPosTabPre] , "Redigite o Item para recarregar a condicao de Pagamento da tabela de pre�os." })
			 _lDifTabPreco:=.T.
		  ELSEIF U_ACOM36Cond(.F.)//Se alterou a condi��o de pagamanto/Tipo de Frete do gatilho do produto(ACOM036.PRW)
		     _lMenTabPreco:=.T.
		  ENDIF	
          
		  IF !(AIA->AIA_DATDE <= DATE() .AND.  AIA->AIA_DATATE >= DATE() .AND. AIA->AIA_I_SITW = "A")// N�O TIVER DENTRO DA VIGENCIA E APROVADA
             AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "Tabela de Pre�os: "+aCols[nX][_nPosTabPre]+" do item invalida: Vigencia de "+AIA->AIA_DATDE+" ate "+AIA->AIA_DATATE+", Status: "+AIA->AIA_I_SITW, "Redigite o Item para recarregar uma tabela de pre�os valida." })
			 lRet := .F.
          ENDIF
		                      //AIB_FILIAL+AIB_CODFOR+AIB_LOJFOR+AIB_CODTAB+AIB_CODPRO
		  IF AIB->(DbSeek(AIA->(AIA_FILIAL+AIA_CODFOR+AIA_LOJFOR+AIA_CODTAB+AllTrim(aCols[nX,_nPa]))))   
             IF aCols[nX][_nPosPreco] <> AIB->AIB_PRCCOM   
                AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "Pre�o do item invalido: O pre�o diverge da tabela de pre�os que esta com "+ALLTRIM(Transform(AIB->AIB_PRCCOM, PesqPict("AIB","AIB_PRCCOM"))), "Redigite o Item para recarregar o pre�o da tabela de pre�os: "+AIA->AIA_CODTAB })
			    lRet := .F.
             ENDIF
             IF aCols[nX][_nPosC7PICM] <> AIB->AIB_I_PICM
                AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "Aliquota de ICMS do item invalido: a aliquota diverge da tabela de pre�os que esta com "+ALLTRIM(Transform(AIB->AIB_I_PICM, PesqPict("AIB","AIB_I_PICM")))+"%", "Redigite o Item para recarregar a aliquota da tabela de pre�os: "+AIA->AIA_CODTAB })
                lRet := .F.
             ENDIF
          ENDIF
	   ELSE//IF AIA->(DbSeek(xFilial("AIA")+CA120FORN+CA120LOJ+aCols[nX][_nPosTabPre])) 
          AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "N�o existe a Tabela de pre�o "+aCols[nX][_nPosTabPre]+" correspondente ao fornecedor digitado.", "Redigite os Itens para recarregar a tabela de pre�os correspondente ao fornecedor digitado."})
	      lRet := .F.
	   ENDIF
	   //**************** AIA ****************************//       
	   
	   //***************** C7_NUMSC *********************//       
	   If !Empty(aCols[nX][nPosNsc])//C7_NUMSC
			For nI := 1 To Len(aCols)
				If !aCols[nI][Len(aHeader)+1]
					If !Empty(aCols[nI][nPosNsc])//C7_NUMSC
						//Valida Aplica��o
						If aCols[nI][nPosApl] <> aCols[nX][nPosApl]
		                    AADD(aProblList,{ aCols[nI,_nC7ITEM] , aCols[nI,_nPa] , "Foram selecionadas Solicita��es com Aplica��es divergentes." , "Somente ser�o aceitas Solicita��es com o mesmo tipo de Aplica��o." })
							lRet := .F.
						EndIf
						//Valida Investimento
						If aCols[nI][nPosInv] <> aCols[nX][nPosInv]
		                    AADD(aProblList,{ aCols[nI,_nC7ITEM] , aCols[nI,_nPa]  , "Foram selecionadas Solicita��es com Investimentos divergentes." , "Somente ser�o aceitas Solicita��es com o mesmo tipo de Investimento." })
							lRet := .F.
						EndIf
						//Valida Urg�ncia
						If aCols[nI][nPosUrg] <> aCols[nX][nPosUrg]
		                    AADD(aProblList,{ aCols[nI,_nC7ITEM] , aCols[nI,_nPa]  , "Foram selecionadas Solicita��es com Urg�ncias divergentes." , "Somente ser�o aceitas Solicita��es com a mesma Urg�ncia." })
							lRet := .F.
						EndIf

						//Valida CLAIM
						If aCols[nI][nPosCLA] <> aCols[nX][nPosCLA]
		                    AADD(aProblList,{ aCols[nI,_nC7ITEM] , aCols[nI,_nPa]  , "Foram selecionadas Solicita��es com CLAIM divergentes." , "Somente ser�o aceitas Solicita��es com a mesmo CLAIM." })
							lRet := .F.
						EndIf
					EndIf
				EndIf
			Next nI

			If !Empty(aCols[nX][nPosCLA]) .And. aCols[nX][nPosCLA] <> cClaim
                AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "CLAIM selecionada no cabe�alho, diverge da Aplica��o do Item." , "Somente ser�o aceitas Solicita��es com o mesmo tipo de CLAIM." })
				lRet := .F.
			EndIf

			If !Empty(aCols[nX][nPosApl]) .And. aCols[nX][nPosApl] <> cAplic
                AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "A Aplica��o selecionada no cabe�alho, diverge da Aplica��o do Item." , "Somente ser�o aceitas Solicita��es com o mesmo tipo de Aplica��o." })
				lRet := .F.
			EndIf
			If !Empty(aCols[nX][nPosInv]) .And. aCols[nX][nPosInv] <> cCInve
                AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "O Investimento informado no cabe�alho, diverge do Investimento do Item." ,  "Somente ser�o aceitas Solicita��es com o mesmo tipo de Investimento." })
				lRet := .F.
			EndIf
			If !Empty(aCols[nX][nPosUrg]) .And. aCols[nX][nPosUrg] <> cUrgen
                AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "A Urg�ncia informada no cabe�alho, diverge da Urg�ncia do Item." , "Somente ser�o aceitas Solicita��es com a mesma Urg�ncia." })
				lRet := .F.
			EndIf
			
			If lRet .AND. !Empty(aCols[nX][_nPosNomFo])
			   aCols[nX,_nPosNomFo]:= AllTrim(POSICIONE("SA2",1,XFILIAL("SA2") + cA120Forn + cA120Loj,"SA2->A2_NOME") )  
			EndIf
		EndIf//!Empty(aCols[nX][nPosNsc]) - C7_NUMSC
	   //***************** C7_NUMSC *********************//       

		SBZ->(dbSeek(xFilial("SBZ")+AllTrim(aCols[nX,_nPa])))
		If  SBZ->BZ_I_VLDTP = "S" .AND. EMPTY(aCols[nX][_nPosTabPre])
            AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "Produto sem tabela de pre�os preenchida.", "Para esse produto � obrigatorio ter tabela de pre�o." })
			lRet := .F.
		ENDIF

		IF _lValidFrac1UM

		    SB1->(DBSEEK(xFilial("SB1") + AllTrim(aCols[nX,_nPa])))
			If  SB1->B1_UM $ _cUM_NO_Fracionada
				If aCols[nX,_nC7QUANT] <> Int(aCols[nX,_nC7QUANT])
					_lRet2 := .F.
					_cProds+="Item: " + aCols[nX,_nC7ITEM]+" Prod.: " + AllTrim(aCols[nX,_nPa])+" - 1aUM: "+SB1->B1_UM+" - 2aUM: "+SB1->B1_SEGUM + CHR(13)+CHR(10)
				EndIf
			EndIf

			If  SB1->B1_SEGUM $ _cUM_NO_Fracionada
				If aCols[nX,_nC7SEGUM] <> Int(aCols[nX,_nC7SEGUM])
					_lRet2 := .F.
					_cProds+="Item: " + aCols[nX,_nC7ITEM] +" Prod.: " + AllTrim(aCols[nX,_nPa])+" - 1aUM: "+SB1->B1_UM+" - 2aUM: "+SB1->B1_SEGUM + CHR(13)+CHR(10)
				EndIf
			EndIf

		EndIf

		If Altera
			_aAreaSC7 := SC7->(GetArea())
			SC7->( DBSetOrder(1) )
			If SC7->( DBSeek( xFilial("SC7") + SC7->C7_NUM + aCols[nX,_nC7ITEM] ) )
				If aCols[nX,nPosDTPRF] <> SC7->C7_DATPRF .OR. aCols[nX,_nPosQtd] <> SC7->C7_QUANT
					SC1->( DBSetOrder(1) )
					If SC1->( DBSeek( xFilial("SC1") + aCols[nX,nPosNsc] + aCols[nX,nPosIsc] ) )
						If SC1->C1_DATPRF <> aCols[nX,nPosDTPRF] .AND. aCols[nX,nPosDTPRF] <> SC7->C7_DATPRF
							AADD(aDifItens,{"DATA",aCols[nX,_nPosItem],SC1->C1_QTDORIG,SC1->C1_DATPRF,SC7->C7_DATPRF})
						EndIf
						If SC1->C1_QTDORIG <> aCols[nX,_nPosQtd] .AND. aCols[nX,_nPosQtd] <> SC7->C7_QUANT
							AADD(aDifItens,{"QTD",aCols[nX,_nPosItem],SC1->C1_QTDORIG,SC1->C1_DATPRF,SC7->C7_QUANT})
						EndIf
					EndIf
				EndIf
			EndIf
			RestArea(_aAreaSC7)
		ElseIf Inclui
			SC1->( DBSetOrder(1) )
			If SC1->( DBSeek( xFilial("SC1") + aCols[nX,nPosNsc] + aCols[nX,nPosIsc] ) )
				If SC1->C1_DATPRF <> aCols[nX,nPosDTPRF]
					AADD(aDifItens,{"DATA",aCols[nX,_nPosItem],SC1->C1_QTDORIG,SC1->C1_DATPRF,CTOD("")})
				EndIf
				If SC1->C1_QTDORIG <> aCols[nX,_nPosQtd]
					AADD(aDifItens,{"QTD",aCols[nX,_nPosItem],SC1->C1_QTDORIG,SC1->C1_DATPRF,0})
				EndIf
			EndIf
		Else
			aDifItens := {} 
		EndIf
      
	EndIf//!aCols[nX][Len(aHeader)+1] - DELETADOS
Next nX

If _lValidFrac1UM .AND. !_lRet2
   U_ITMSG("N�o � permitido fracionar a quantidade da 1a. ou 2a. UM de produto onde a UM for "+_cUM_NO_Fracionada+". Clique em mais detalhes",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
   		   "Valida��o Fracionado","Favor informar apenas quantidades inteiras onde a UM for "+_cUM_NO_Fracionada+".",1     ,       ,        ,         ,     ,     ,;
   		   {|| Aviso("Valida��o Fracionado",_cProds,{"Fechar"}) } )
   lRet:=.F.
ENDIF

IF _lValTabPreco .AND. _lDifTabPreco//Se tem que validar e tem condi��es diferentes n�o deixa grava o Pedido
   lRet:=.F.
ENDIF

SY1->(dbSetOrder(3))//Y1_USER
For X := 1 to len(aCols)

	If aCols[X][Len(aHeader)+1]//DELETADOS
	   LOOP
	ENDIF

	_cSegu	    := acols[x][_nSegu]
	_cproduto	:= acols[x][_nPa]
	_nquant		:= acols[x][_nC7SEGUM]	//M->C7_QTSEGUM
	_cGrupo     := POSICIONE("SB1",1,xFilial("SB1")+alltrim(_cproduto),"B1_GRUPO")
	_nConv      := SB1->B1_CONV

    IF !Empty(aCols[X,_nPosC7PICM]) .AND. SB1->B1_TIPO = "SV" .AND. !ALLTRIM(SB1->B1_COD) $ _cIT_PRDSVOK
        AADD(aProblList,{ aCols[X,_nC7ITEM] , aCols[X,_nPa] , "Aliquota de ICMS n�o pode ser preenchida para o produto de tipo 'SV'", "Zere Aliquota de ICMS desse produto."})
		lRet := .F.
	EndIf
    IF !Empty(aCols[X,_nPosC7IPI]) .AND. SB1->B1_TIPO = "SV" .AND. !ALLTRIM(SB1->B1_COD) $ _cIT_PRDSVOK
        AADD(aProblList,{ aCols[X,_nC7ITEM] , aCols[X,_nPa] , "Aliquota de IPI n�o pode ser preenchida para o produto de tipo 'SV'", "Zere Aliquota de IPI desse produto."})
		lRet := .F.
	EndIf

    IF !SB1->B1_TIPO $ _cTipos
	   SY1->(dbSeek(xFilial("SY1") + ALLTRIM(__cUserID)))
	   IF !SY1->Y1_COD $ _cPCGERAL .AND. SY1->Y1_GRUPCOM $ _cGrpLeite
          AADD(aProblList,{ aCols[X,_nC7ITEM] , aCols[X,_nPa] ,'Comprador habilitado somente para comprar tipos de produto "'+_cTipos+'"','Remova os produto com tipo diferente de "'+_cTipos+'" da lista.'})
		  lRet := .F.
	   ENDIF
    ELSE//IF SB1->B1_TIPO $ "MP,PP,PI" 
	   SY1->(dbSeek(xFilial("SY1") + ALLTRIM(__cUserID)))
	   IF !SY1->Y1_COD $ _cPCGERAL .AND. !SY1->Y1_GRUPCOM $ _cGrpLeite
          AADD(aProblList,{ aCols[X,_nC7ITEM] , aCols[X,_nPa] ,'Comprador n�o habilitado para comprar tipos de produto "'+_cTipos+'"','Remova os produto com tipo igual a "'+_cTipos+'" da lista.'})
		  lRet := .F.
	   ENDIF
	ENDIF

	If Empty(aCols[X,_nPosDtFat]) .AND. !SY1->Y1_GRUPCOM $ _cGrpLeite
       AADD(aProblList,{ aCols[X,_nC7ITEM] , aCols[X,_nPa] ,'Data de fataturamento n�o preenchida.','Preencha a data de Faturamento desse item e dos outros.'})
	   lRet := .F.
	ENDIF

	If (!EMPTY(_cSegu) .OR. _nquant > 0) .AND. _nConv == 0 .AND. !(alltrim(_cGrupo) $ alltrim(U_ITGETMV("IT_GRP2U", "0006")))
        AADD(aProblList,{ aCols[X,_nC7ITEM] , aCols[X,_nPa] ,"Item n�o tem fator de convers�o cadastrado.","Imposs�vel usar segunda unidade medida."})
		lRet := .F.
	EndIf

	If (EMPTY(_cSegu) .OR. _nquant = 0) .AND. _nConv <> 0 
        AADD(aProblList,{ aCols[X,_nC7ITEM] , aCols[X,_nPa] ,"Item tem fator de convers�o cadastrado.","Obrigatorio usar segunda unidade medida."})
		lRet := .F.
	EndIf

	If  aCols[X][_nPosUsod] <> "S" .AND. cCompD = "S" .AND. cAplic != "S"
        AADD(aProblList,{ aCols[X,_nC7ITEM] , aCols[X,_nPa] , "Campo Ap Direta do Item dever esta igual a SIM quando for compra direta igual a SIM." , "Somente ser�o aceitas Solicita��es com Ap Direta igual a SIM." })
		lRet := .F.
	EndIf

Next 

For nX := 1 to len(aCols)
	If cCInve <> aCols[nX][_nPosCDINV]
		aCols[nX,_nPosCDINV ] := cCInve
		aCols[nX,_nPosDsInv ] := cDsInv
		aCols[nX,_nPosSUBIN ] := Space(Len(cCInve))
		aCols[nX,_nPosSUIND ] := Space(Len(cDsInv))
	EndIf
Next

If cAplic == "I"
	For nX := 1 to len(aCols)
		If aCols[nX][Len(aHeader)+1]//DELETADOS
			LOOP
		ENDIF
		If Empty(Alltrim(aCols[nX,_nPosSUBIN]))
			ZZI->(DBSETORDER(3))//ZZI_FILIAL+ZZI_INVPAI+ZZI_TIPO
			IF ZZI->(DBSEEK(xFilial("ZZI")+cCInve+"2"))
				AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] ,'Campo de Subinvestimento n�o Preenchido!',''})
				lRet := .F.
			EndIf
		Else
			ZZI->(DBSETORDER(1))//ZZI_FILIAL+ZZI_INVPAI+ZZI_TIPO
			If ZZI->(DBSEEK(xFilial("ZZI")+aCols[nX,_nPosSUBIN ]))
				If ZZI->ZZI_INVPAI <> cCInve
					AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] ,'Campo de Subinvestimento da linha '+Alltrim(Str(nX))+' n�o corresponde ao projeto!','Mofifique o campo selecionando um os dos itens da consulta.'})
					lRet := .F.
				Else
					If ZZI->ZZI_TIPO == "2"
						ZZI->(DBSETORDER(3))//ZZI_FILIAL+ZZI_INVPAI+ZZI_TIPO
						If ZZI->(DBSEEK(xFilial("ZZI")+cCInve+"3"))
							AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] ,'No Campo de Subinvestimento da linha '+Alltrim(Str(nX))+' � obrigat�rio um Investimento de nivel 3 !','Mofifique o campo selecionando um Investimento de nivel 3 da consulta.'})
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Next
EndIf

IF !lRet .AND. LEN(aProblList) > 0

   //                                                                                      , _aCols     ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons )
	U_ITListBox( 'Rela��o de Itens com problemas', {'Item','Produto','Problema',"Solucao"} , aProblList , .T.    , 1    ,        ,          ,;
	                                               {10,   ,100      ,200       ,200      }  )
ELSEIF _lMenTabPreco
    U_ACOM36Cond(.T.)//volta a variavel _lAlterou para .F. do gatilho do produto (ACOM036.PRW)
ENDIF

U_MT120VA(aDifItens)

RestArea(aArea)
Return(lRet)


/*
===============================================================================================================================
Programa--------: ConverteXML()
Autor-----------: Alex Walaluer
Data da Criacao-: 20/10/2017
===============================================================================================================================
Descri��o-------: Tira os caracteres "estranos"
===============================================================================================================================
Parametros------: cString: String
===============================================================================================================================
Retorno---------: cString: String
===============================================================================================================================
*/
*--------------------------------------------------------------------------------------------*
Static Function LimpaString(cString)
*--------------------------------------------------------------------------------------------*
   cString:=StrTran(cString,'�'," ")
   cString:=StrTran(cString,'?'," ")
   cString:=StrTran(cString,'^'," ")
   cString:=StrTran(cString,'~'," ")
   cString:=StrTran(cString,'"'," ")
   cString:=StrTran(cString,"�"," ")
   cString:=StrTran(cString,"�"," ")
   cString:=StrTran(cString,"'"," ")
   cString:=StrTran(cString,"`"," ")
   cString:=StrTran(cString,"�"," ")
   cString:=StrTran(cString,"!"," ")

   cString:=StrTran(cString,"�?","E")
   cString:=StrTran(cString,"�^","E")
   cString:=StrTran(cString,"�","a")
   cString:=StrTran(cString,"�","A")
   cString:=StrTran(cString,"�","a")
   cString:=StrTran(cString,"�","A")
   cString:=StrTran(cString,"�","a")
   cString:=StrTran(cString,"�","A")
   cString:=StrTran(cString,"�","a")
   cString:=StrTran(cString,"�","A")
   cString:=StrTran(cString,"�","a")
   cString:=StrTran(cString,"�","A")
   cString:=StrTran(cString,"�","e")
   cString:=StrTran(cString,"�","E")
   cString:=StrTran(cString,"�","e")
   cString:=StrTran(cString,"�","E")
   cString:=StrTran(cString,"�","e")
   cString:=StrTran(cString,"�","E")
   cString:=StrTran(cString,"�","i")
   cString:=StrTran(cString,"�","I")
   cString:=StrTran(cString,"�","i")
   cString:=StrTran(cString,"�","I")
   cString:=StrTran(cString,"�","i")
   cString:=StrTran(cString,"�","I")
   cString:=StrTran(cString,"�","y")
   cString:=StrTran(cString,"�","y")
   cString:=StrTran(cString,"�","y")
   cString:=StrTran(cString,"�","o")
   cString:=StrTran(cString,"�","O")
   cString:=StrTran(cString,"�","o")
   cString:=StrTran(cString,"�","O")
   cString:=StrTran(cString,"�","o")
   cString:=StrTran(cString,"�","O")
   cString:=StrTran(cString,"�","o")
   cString:=StrTran(cString,"�","O")
   cString:=StrTran(cString,"�","o")
   cString:=StrTran(cString,"�","O")
   cString:=StrTran(cString,"�","u")
   cString:=StrTran(cString,"�","U")
   cString:=StrTran(cString,"�","u")
   cString:=StrTran(cString,"�","U")
   cString:=StrTran(cString,"�","u")
   cString:=StrTran(cString,"�","U")
   cString:=StrTran(cString,"�","c")
   cString:=StrTran(cString,"�","C")
   cString:=StrTran(cString,"�","o")
   cString:=StrTran(cString,"�","o")
   cString:=StrTran(cString,"�","a")
   cString:=StrTran(cString,"�","n")
   cString:=StrTran(cString,"�","N")
   cString:=StrTran(cString,"�","2")
   cString:=StrTran(cString,"�","3")
   cString:=StrTran(cString,"�","S")
   cString:=StrTran(cString,"�","+")
   cString:=StrTran(cString,"�","-")
   cString:=StrTran(cString,"o","o")
   cString:=StrTran(cString,"�","u")
   cString:=StrTran(cString,"�","1/4")
   cString:=StrTran(cString,"�","1/2")
   cString:=StrTran(cString,"�","3/4")
   cString:=StrTran(cString,"&","e") 
   cString:=StrTran(cString,";",",")
   cString:=StrTran(cString,"�","i")
   cString:=StrTran(cString,"�","c.")
   cString:=StrTran(cString,"�","r.")
   cString:=StrTran(cString,"�","L")
   cString:=StrTran(cString,"�","t")
   cString:=StrTran(cString,"�","f")
   cString:=StrTran(cString,"�","x")
Return cString


