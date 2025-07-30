/*
=====================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
=====================================================================================================================================
	Autor	    |	Data	|										Motivo																 
=====================================================================================================================================
Alex Wallauer  | 08/04/2019 | Chamado 28685. Validação p/ não permitir fracionamento p/ PAs onde a 1a UM for UN. 
Alex Wallauer  | 11/09/2019 | Chamado 30551. correção de error.log de variavel não é numerica. 
Lucas Borges   | 03/10/2019 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25. 
Alex Wallauer  | 22/10/2019 | Chamado 30921. Tratamento para o campo NOVO CLAIM.  
Alex Wallauer  | 16/12/2019 | Chamado 31462. Novas Validadoçoes para os campos custumizados.  
Alex Wallauer  | 20/07/2020 | Chamado 36102. Ajuste na validação da 2 UM para validar quando for Copia.  
Jonathan       | 28/07/2020 | Chamado 33673. Nova validação para o campo C7_I_USOD quando aplicação = "S". 
Alex Wallauer  | 21/03/2022 | Chamado 38650. Validacao para o usuario de leite só incluir item = MP. 
Igor Melgaço   | 12/07/2022 | Chamado 40620. Validação dos campos de projeto e Subinvestimento.
Igor Melgaço   | 13/07/2022 | Chamado 40620. Correção de validação somente qdo a aplicação for investimento. 
Alex Wallauer  | 21/10/2022 | Chamado 41652. Permitir fracionar produtos <> "PA" quando o campo ZZL_PEFROU for = "S". 
Igor Melgaço   | 13/07/2022 | Chamado 43230. Ajuste para inclusão de parametro para comparação com B1_TIPO 
Alex Wallauer  | 20/03/2023 | Chamado 43320. Nova validacao do campo data de faturamento (C7_I_DTFAT).
Alex Wallauer  | 15/07/2024 | Chamado 47732. Nova validacao do campo condicao de pagamento (cCondicao).
========================================================================================================================================================================
Analista       - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
========================================================================================================================================================================
André Carvalho - Alex Wallauer - 14/10/24 - 25/10/24 - 48836   - Nova validação não permitir informar aliquota de ICMS e IPI para produtos do B1_TIPO = "SV".
André Carvalho - Alex Wallauer - 28/10/24 - 28/10/24 - 48836   - Retirada de uma validação inconcistente.
André Carvalho - Igor Melgaço  - 25/11/24 - 17/02/25 - 49104   - Ajustes para envio de email na alteração da previsão do pedido de compra
André Carvalho - Alex Wallauer - 03/07/25 -          - 50990   - Validacao do campo C7_PICM contra AIB_I_PICM. 
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
Descrição---------: Rotina responsavel pelas validações dos campos que estão no cabeçalho do pedido de compras.
					Localização: Function A120TudOk() responsável pela validação de todos os itens da GetDados do Pedido de 
					Compras / Autorização de Entrega.
					Em que Ponto: O ponto se encontra no final da função e é disparado após a confirmação dos itens da getdados 
					e antes do rodapé da dialog do PC, deve ser utilizado para validações especificas do usuario onde será 
					controlada pelo retorno do ponto de entrada oqual se for .F. o processo será interrompido e se .T. será validado.
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

//Força atualização de campos C7_I_DESCD

For _ni := 1 to len(acols)

	aCols[_ni,_nPosdescd] := posicione("SB1",1,xFilial("SB1")+ALLTRIM(acols[_ni,_nPa]),"B1_I_DESCD")
	
Next


If Empty(cAplic)
	aProbl := {}
	aAdd(aProbl, "O campo Aplicação deve ser informado.")

	aSoluc := {}
	aAdd(aSoluc, "Favor informar uma Aplicação válida.")

	aMensagem := {"Aplicação Obrigatória", aProbl, aSoluc}

	U_ITMsHTML(aMensagem)

	lRet := .F.
EndIf

If cAplic == "I" .And. Empty(cCInve)
	aProbl := {}
	aAdd(aProbl, "O campo Investimento deve ser informado.")

	aSoluc := {}
	aAdd(aSoluc, "Para Aplicação do tipo Investimento, o campo Código do Investimento deve ser preenchido.")

	aMensagem := {"Investimento Obrigatório", aProbl, aSoluc}

	U_ITMsHTML(aMensagem)

	lRet := .F.
EndIf

If Empty(cTpFrete)
	aProbl := {}
	aAdd(aProbl, "O campo Tipo de Frete deve ser informado.")

	aSoluc := {}
	aAdd(aSoluc, "Favor preencher o campo de Tipo de Frete na Pasta Frete/Despesas.")

	aMensagem := {"Tipo de Frete Obrigatório", aProbl, aSoluc}

	U_ITMsHTML(aMensagem)

	lRet := .F.
EndIf

If Empty(cUrgen)
	aProbl := {}
	aAdd(aProbl, "O campo Urgência deve ser informado.")

	aSoluc := {}
	aAdd(aSoluc, "Favor informar uma opção válida.")

	aMensagem := {"Urgência Obrigatória", aProbl, aSoluc}

	U_ITMsHTML(aMensagem)

	lRet := .F.
EndIf

If Empty(cCompD)
	aProbl := {}
	aAdd(aProbl, "O campo Compra Direta deve ser informado.")

	aSoluc := {}
	aAdd(aSoluc, "Favor informar uma opção válida.")

	aMensagem := {"Compra Direta Obrigatório", aProbl, aSoluc}

	U_ITMsHTML(aMensagem)

	lRet := .F.

ELSE

   IF cCompD = "S" .AND. cUrgen <> "S"
      U_ITMSG("Campo urgente dever esta igual a SIM quando for compra direta igual a SIM",'Atenção!',,1)
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
	If !aCols[nX][Len(aHeader)+1]//NÃO DELETADOS
       
       IF !EMPTY(aCols[nX][nPosObs])
          aCols[nX][nPosObs]:=LimpaString(aCols[nX][nPosObs])
       ENDIF		
       
	   //**************** AIA ****************************//       
	   IF EMPTY(aCols[nX][_nPosTabPre])
		  _lValTabPreco:=.F.
	   ELSEIF AIA->(DbSeek(xFilial("AIA")+CA120FORN+CA120LOJ+aCols[nX][_nPosTabPre])) 
          
		  IF SUBSTR(cTpFrete,1,1) <> AIA->AIA_I_TPFR
             AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "Tipo de Frete do PC : "+cTpFrete+", difere do Tipo de Frete: "+RetTipoFrete(AIA->AIA_I_TPFR)+" + da Tabela de Preços: "+aCols[nX][_nPosTabPre] , "Redigite o Item para recarregar o Tipo de Frete da tabela de preços." })
			 _lDifTabPreco:=.T.
		  ELSEIF U_ACOM36Cond(.F.)//Se alterou a condição de pagamanto/Tipo de Frete  do gatilho do produto(ACOM036.PRW)
		     _lMenTabPreco:=.T.
		  ENDIF	

	      IF cCondicao <> AIA->AIA_CONDPG 
             AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "Condição de Pagamento  do PC : "+cCondicao+", difere da Cond. Pagtp.: "+AIA->AIA_CONDPG+" + da Tabela de Preços: "+aCols[nX][_nPosTabPre] , "Redigite o Item para recarregar a condicao de Pagamento da tabela de preços." })
			 _lDifTabPreco:=.T.
		  ELSEIF U_ACOM36Cond(.F.)//Se alterou a condição de pagamanto/Tipo de Frete do gatilho do produto(ACOM036.PRW)
		     _lMenTabPreco:=.T.
		  ENDIF	
          
		  IF !(AIA->AIA_DATDE <= DATE() .AND.  AIA->AIA_DATATE >= DATE() .AND. AIA->AIA_I_SITW = "A")// NÃO TIVER DENTRO DA VIGENCIA E APROVADA
             AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "Tabela de Preços: "+aCols[nX][_nPosTabPre]+" do item invalida: Vigencia de "+AIA->AIA_DATDE+" ate "+AIA->AIA_DATATE+", Status: "+AIA->AIA_I_SITW, "Redigite o Item para recarregar uma tabela de preços valida." })
			 lRet := .F.
          ENDIF
		                      //AIB_FILIAL+AIB_CODFOR+AIB_LOJFOR+AIB_CODTAB+AIB_CODPRO
		  IF AIB->(DbSeek(AIA->(AIA_FILIAL+AIA_CODFOR+AIA_LOJFOR+AIA_CODTAB+AllTrim(aCols[nX,_nPa]))))   
             IF aCols[nX][_nPosPreco] <> AIB->AIB_PRCCOM   
                AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "Preço do item invalido: O preço diverge da tabela de preços que esta com "+ALLTRIM(Transform(AIB->AIB_PRCCOM, PesqPict("AIB","AIB_PRCCOM"))), "Redigite o Item para recarregar o preço da tabela de preços: "+AIA->AIA_CODTAB })
			    lRet := .F.
             ENDIF
             IF aCols[nX][_nPosC7PICM] <> AIB->AIB_I_PICM
                AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "Aliquota de ICMS do item invalido: a aliquota diverge da tabela de preços que esta com "+ALLTRIM(Transform(AIB->AIB_I_PICM, PesqPict("AIB","AIB_I_PICM")))+"%", "Redigite o Item para recarregar a aliquota da tabela de preços: "+AIA->AIA_CODTAB })
                lRet := .F.
             ENDIF
          ENDIF
	   ELSE//IF AIA->(DbSeek(xFilial("AIA")+CA120FORN+CA120LOJ+aCols[nX][_nPosTabPre])) 
          AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "Não existe a Tabela de preço "+aCols[nX][_nPosTabPre]+" correspondente ao fornecedor digitado.", "Redigite os Itens para recarregar a tabela de preços correspondente ao fornecedor digitado."})
	      lRet := .F.
	   ENDIF
	   //**************** AIA ****************************//       
	   
	   //***************** C7_NUMSC *********************//       
	   If !Empty(aCols[nX][nPosNsc])//C7_NUMSC
			For nI := 1 To Len(aCols)
				If !aCols[nI][Len(aHeader)+1]
					If !Empty(aCols[nI][nPosNsc])//C7_NUMSC
						//Valida Aplicação
						If aCols[nI][nPosApl] <> aCols[nX][nPosApl]
		                    AADD(aProblList,{ aCols[nI,_nC7ITEM] , aCols[nI,_nPa] , "Foram selecionadas Solicitações com Aplicações divergentes." , "Somente serão aceitas Solicitações com o mesmo tipo de Aplicação." })
							lRet := .F.
						EndIf
						//Valida Investimento
						If aCols[nI][nPosInv] <> aCols[nX][nPosInv]
		                    AADD(aProblList,{ aCols[nI,_nC7ITEM] , aCols[nI,_nPa]  , "Foram selecionadas Solicitações com Investimentos divergentes." , "Somente serão aceitas Solicitações com o mesmo tipo de Investimento." })
							lRet := .F.
						EndIf
						//Valida Urgência
						If aCols[nI][nPosUrg] <> aCols[nX][nPosUrg]
		                    AADD(aProblList,{ aCols[nI,_nC7ITEM] , aCols[nI,_nPa]  , "Foram selecionadas Solicitações com Urgências divergentes." , "Somente serão aceitas Solicitações com a mesma Urgência." })
							lRet := .F.
						EndIf

						//Valida CLAIM
						If aCols[nI][nPosCLA] <> aCols[nX][nPosCLA]
		                    AADD(aProblList,{ aCols[nI,_nC7ITEM] , aCols[nI,_nPa]  , "Foram selecionadas Solicitações com CLAIM divergentes." , "Somente serão aceitas Solicitações com a mesmo CLAIM." })
							lRet := .F.
						EndIf
					EndIf
				EndIf
			Next nI

			If !Empty(aCols[nX][nPosCLA]) .And. aCols[nX][nPosCLA] <> cClaim
                AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "CLAIM selecionada no cabeçalho, diverge da Aplicação do Item." , "Somente serão aceitas Solicitações com o mesmo tipo de CLAIM." })
				lRet := .F.
			EndIf

			If !Empty(aCols[nX][nPosApl]) .And. aCols[nX][nPosApl] <> cAplic
                AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "A Aplicação selecionada no cabeçalho, diverge da Aplicação do Item." , "Somente serão aceitas Solicitações com o mesmo tipo de Aplicação." })
				lRet := .F.
			EndIf
			If !Empty(aCols[nX][nPosInv]) .And. aCols[nX][nPosInv] <> cCInve
                AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "O Investimento informado no cabeçalho, diverge do Investimento do Item." ,  "Somente serão aceitas Solicitações com o mesmo tipo de Investimento." })
				lRet := .F.
			EndIf
			If !Empty(aCols[nX][nPosUrg]) .And. aCols[nX][nPosUrg] <> cUrgen
                AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "A Urgência informada no cabeçalho, diverge da Urgência do Item." , "Somente serão aceitas Solicitações com a mesma Urgência." })
				lRet := .F.
			EndIf
			
			If lRet .AND. !Empty(aCols[nX][_nPosNomFo])
			   aCols[nX,_nPosNomFo]:= AllTrim(POSICIONE("SA2",1,XFILIAL("SA2") + cA120Forn + cA120Loj,"SA2->A2_NOME") )  
			EndIf
		EndIf//!Empty(aCols[nX][nPosNsc]) - C7_NUMSC
	   //***************** C7_NUMSC *********************//       

		SBZ->(dbSeek(xFilial("SBZ")+AllTrim(aCols[nX,_nPa])))
		If  SBZ->BZ_I_VLDTP = "S" .AND. EMPTY(aCols[nX][_nPosTabPre])
            AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] , "Produto sem tabela de preços preenchida.", "Para esse produto é obrigatorio ter tabela de preço." })
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
   U_ITMSG("Não é permitido fracionar a quantidade da 1a. ou 2a. UM de produto onde a UM for "+_cUM_NO_Fracionada+". Clique em mais detalhes",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
   		   "Validação Fracionado","Favor informar apenas quantidades inteiras onde a UM for "+_cUM_NO_Fracionada+".",1     ,       ,        ,         ,     ,     ,;
   		   {|| Aviso("Validação Fracionado",_cProds,{"Fechar"}) } )
   lRet:=.F.
ENDIF

IF _lValTabPreco .AND. _lDifTabPreco//Se tem que validar e tem condições diferentes não deixa grava o Pedido
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
        AADD(aProblList,{ aCols[X,_nC7ITEM] , aCols[X,_nPa] , "Aliquota de ICMS não pode ser preenchida para o produto de tipo 'SV'", "Zere Aliquota de ICMS desse produto."})
		lRet := .F.
	EndIf
    IF !Empty(aCols[X,_nPosC7IPI]) .AND. SB1->B1_TIPO = "SV" .AND. !ALLTRIM(SB1->B1_COD) $ _cIT_PRDSVOK
        AADD(aProblList,{ aCols[X,_nC7ITEM] , aCols[X,_nPa] , "Aliquota de IPI não pode ser preenchida para o produto de tipo 'SV'", "Zere Aliquota de IPI desse produto."})
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
          AADD(aProblList,{ aCols[X,_nC7ITEM] , aCols[X,_nPa] ,'Comprador não habilitado para comprar tipos de produto "'+_cTipos+'"','Remova os produto com tipo igual a "'+_cTipos+'" da lista.'})
		  lRet := .F.
	   ENDIF
	ENDIF

	If Empty(aCols[X,_nPosDtFat]) .AND. !SY1->Y1_GRUPCOM $ _cGrpLeite
       AADD(aProblList,{ aCols[X,_nC7ITEM] , aCols[X,_nPa] ,'Data de fataturamento não preenchida.','Preencha a data de Faturamento desse item e dos outros.'})
	   lRet := .F.
	ENDIF

	If (!EMPTY(_cSegu) .OR. _nquant > 0) .AND. _nConv == 0 .AND. !(alltrim(_cGrupo) $ alltrim(U_ITGETMV("IT_GRP2U", "0006")))
        AADD(aProblList,{ aCols[X,_nC7ITEM] , aCols[X,_nPa] ,"Item não tem fator de conversão cadastrado.","Impossível usar segunda unidade medida."})
		lRet := .F.
	EndIf

	If (EMPTY(_cSegu) .OR. _nquant = 0) .AND. _nConv <> 0 
        AADD(aProblList,{ aCols[X,_nC7ITEM] , aCols[X,_nPa] ,"Item tem fator de conversão cadastrado.","Obrigatorio usar segunda unidade medida."})
		lRet := .F.
	EndIf

	If  aCols[X][_nPosUsod] <> "S" .AND. cCompD = "S" .AND. cAplic != "S"
        AADD(aProblList,{ aCols[X,_nC7ITEM] , aCols[X,_nPa] , "Campo Ap Direta do Item dever esta igual a SIM quando for compra direta igual a SIM." , "Somente serão aceitas Solicitações com Ap Direta igual a SIM." })
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
				AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] ,'Campo de Subinvestimento não Preenchido!',''})
				lRet := .F.
			EndIf
		Else
			ZZI->(DBSETORDER(1))//ZZI_FILIAL+ZZI_INVPAI+ZZI_TIPO
			If ZZI->(DBSEEK(xFilial("ZZI")+aCols[nX,_nPosSUBIN ]))
				If ZZI->ZZI_INVPAI <> cCInve
					AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] ,'Campo de Subinvestimento da linha '+Alltrim(Str(nX))+' não corresponde ao projeto!','Mofifique o campo selecionando um os dos itens da consulta.'})
					lRet := .F.
				Else
					If ZZI->ZZI_TIPO == "2"
						ZZI->(DBSETORDER(3))//ZZI_FILIAL+ZZI_INVPAI+ZZI_TIPO
						If ZZI->(DBSEEK(xFilial("ZZI")+cCInve+"3"))
							AADD(aProblList,{ aCols[nX,_nC7ITEM] , aCols[nX,_nPa] ,'No Campo de Subinvestimento da linha '+Alltrim(Str(nX))+' é obrigatório um Investimento de nivel 3 !','Mofifique o campo selecionando um Investimento de nivel 3 da consulta.'})
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
	U_ITListBox( 'Relação de Itens com problemas', {'Item','Produto','Problema',"Solucao"} , aProblList , .T.    , 1    ,        ,          ,;
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
Descrição-------: Tira os caracteres "estranos"
===============================================================================================================================
Parametros------: cString: String
===============================================================================================================================
Retorno---------: cString: String
===============================================================================================================================
*/
*--------------------------------------------------------------------------------------------*
Static Function LimpaString(cString)
*--------------------------------------------------------------------------------------------*
   cString:=StrTran(cString,'¨'," ")
   cString:=StrTran(cString,'?'," ")
   cString:=StrTran(cString,'^'," ")
   cString:=StrTran(cString,'~'," ")
   cString:=StrTran(cString,'"'," ")
   cString:=StrTran(cString,"’"," ")
   cString:=StrTran(cString,"´"," ")
   cString:=StrTran(cString,"'"," ")
   cString:=StrTran(cString,"`"," ")
   cString:=StrTran(cString,"–"," ")
   cString:=StrTran(cString,"!"," ")

   cString:=StrTran(cString,"Ã?","E")
   cString:=StrTran(cString,"Ã^","E")
   cString:=StrTran(cString,"á","a")
   cString:=StrTran(cString,"Á","A")
   cString:=StrTran(cString,"à","a")
   cString:=StrTran(cString,"À","A")
   cString:=StrTran(cString,"ã","a")
   cString:=StrTran(cString,"Ã","A")
   cString:=StrTran(cString,"â","a")
   cString:=StrTran(cString,"Â","A")
   cString:=StrTran(cString,"ä","a")
   cString:=StrTran(cString,"Ä","A")
   cString:=StrTran(cString,"é","e")
   cString:=StrTran(cString,"É","E")
   cString:=StrTran(cString,"ë","e")
   cString:=StrTran(cString,"Ë","E")
   cString:=StrTran(cString,"ê","e")
   cString:=StrTran(cString,"Ê","E")
   cString:=StrTran(cString,"í","i")
   cString:=StrTran(cString,"Í","I")
   cString:=StrTran(cString,"ï","i")
   cString:=StrTran(cString,"Ï","I")
   cString:=StrTran(cString,"î","i")
   cString:=StrTran(cString,"Î","I")
   cString:=StrTran(cString,"ý","y")
   cString:=StrTran(cString,"Ý","y")
   cString:=StrTran(cString,"ÿ","y")
   cString:=StrTran(cString,"ó","o")
   cString:=StrTran(cString,"Ó","O")
   cString:=StrTran(cString,"õ","o")
   cString:=StrTran(cString,"Õ","O")
   cString:=StrTran(cString,"ö","o")
   cString:=StrTran(cString,"Ö","O")
   cString:=StrTran(cString,"ô","o")
   cString:=StrTran(cString,"Ô","O")
   cString:=StrTran(cString,"ò","o")
   cString:=StrTran(cString,"Ò","O")
   cString:=StrTran(cString,"ú","u")
   cString:=StrTran(cString,"Ú","U")
   cString:=StrTran(cString,"ù","u")
   cString:=StrTran(cString,"Ù","U")
   cString:=StrTran(cString,"ü","u")
   cString:=StrTran(cString,"Ü","U")
   cString:=StrTran(cString,"ç","c")
   cString:=StrTran(cString,"Ç","C")
   cString:=StrTran(cString,"º","o")
   cString:=StrTran(cString,"°","o")
   cString:=StrTran(cString,"ª","a")
   cString:=StrTran(cString,"ñ","n")
   cString:=StrTran(cString,"Ñ","N")
   cString:=StrTran(cString,"²","2")
   cString:=StrTran(cString,"³","3")
   cString:=StrTran(cString,"§","S")
   cString:=StrTran(cString,"±","+")
   cString:=StrTran(cString,"­","-")
   cString:=StrTran(cString,"o","o")
   cString:=StrTran(cString,"µ","u")
   cString:=StrTran(cString,"¼","1/4")
   cString:=StrTran(cString,"½","1/2")
   cString:=StrTran(cString,"¾","3/4")
   cString:=StrTran(cString,"&","e") 
   cString:=StrTran(cString,";",",")
   cString:=StrTran(cString,"¡","i")
   cString:=StrTran(cString,"©","c.")
   cString:=StrTran(cString,"®","r.")
   cString:=StrTran(cString,"£","L")
   cString:=StrTran(cString,"‡","t")
   cString:=StrTran(cString,"ƒ","f")
   cString:=StrTran(cString,"×","x")
Return cString


