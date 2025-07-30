/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Antonio Neves | 14/08/23   | Alteração incorreto do leiaute de envio do CNAB causou a necessidade de o retorno procurar o IDCNAB
						   | pelo número do Título. Somente Casos do Bradesco e para Ocorrência 06 - Baixa
-------------------------------------------------------------------------------------------------------------------------------
Antonio Neves | 05/12/23   | Chamado 45779 - Readequação do leiatute de retonno para atender a impressão do número do título
 							na posição correta. A Customização visa atender todos os títulos já enviados.
							Posições atuais no leiaute de envio e o campo adequado
							038-062 EXECBLOCK("IDENTIT",.F.,.F.) --->>>  (SE1->E1_IDCNAB)                
							111-120 SE1->E1_IDCNAB --->>> (SE1->E1_NUM)      
							Posições corretas no arquivo de retorno
							117-126 --->> 038-062
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#Include "Protheus.ch"
#INCLUDE 'TOPCONN.CH'

//-------------------------------------------------------------------------------
/*/{Protheus.doc} F200VAR
Manipular as informações (variáveis) no retorno do Cnab a Receber (FINA200). 
 
@PARAMIXB aDados[1] = Número do Título    | Variavel de origem: cNumTit
          aDados[2] = Data da Baixa       | Variavel de origem: dBaixa
          aDados[3] = Tipo do Título      | Variavel de origem: cTipo
          aDados[4] = Nosso Número        | Variavel de origem: cNsNum (NUMBCO)
          aDados[5] = Valor da Despesa    | Variavel de origem: nDespes
          aDados[6] = Valor do Desconto   | Variavel de origem: nDescont
          aDados[7] = Valor do Abatimento | Variavel de origem: nAbatim
          aDados[8] = Valor Recebido      | Variavel de origem: nValRec
          aDados[9] = Juros               | Variavel de origem: nJuros
          aDados[10] = Multa              | Variavel de origem: nMulta
          aDados[11] = Outras Despesas    | Variavel de origem: nOutrDesp
          aDados[12] = Valor do Credito   | Variavel de origem: nValCc
          aDados[13] = Data do Credito    | Variavel de origem: dDataCred
          aDados[14] = Ocorrência         | Variavel de origem: cOcorr
          aDados[15] = Motivo do banco    | Variavel de origem: cMotBan
          aDados[16] = Linha Inteira      | Variavel de origem: xBuffer
          aDados[17] = Data de Vencimento | Variavel de origem: dDtVc
 
/*/
//-------------------------------------------------------------------------------

User Function F200VAR()

	Local aDados        := PARAMIXB
	Local aAreaSE1      := SE1->(GetArea())

	//Local _cIdCnab      := SUBSTR(Paramixb[1][16],117,10)
	Local _cIdCnab      := SUBSTR(Paramixb[1][16],38,10)

    Local _cNumBco      := SUBSTR(PARAMIXB[1][16],73,10)
	Local _cOcorren     := PARAMIXB[1][14]
	Local _cQryID
    Local _cNumTit      := SUBSTR(Paramixb[1][16],49,9)
    Local _cNumPar      := IIF(SUBSTR(Paramixb[1][16],58,2)=="00"," ",SUBSTR(Paramixb[1][16],58,2))

	//MSGALERT("TESTE",'F200VAR')


	dbSelectArea("SE1")
	SE1->( dbSetOrder(16) ) // E1_Filial + E1_IDCNAB

	If cBanco == "237" /*BRADESCO*/ .AND. AllTrim(_cOcorren) == "06" //BAIXA

		If !SE1->(dbSeek(xFilial("SE1")+_cIdCnab))

			_cQryID := " SELECT E1_IDCNAB IDCNAB FROM "+RetSqlName("SE1")+" SE1 "
			_cQryID += " WHERE E1_NUM='"+_cNumTit+"' AND E1_PARCELA='"+_cNumPar+"' AND "
			_cQryID += " E1_FILIAL='"+xFilial("SE1")+"' AND D_E_L_E_T_ =' ' "
			_cQryID += " AND E1_PORTADO='237' AND E1_IDCNAB<>' ' "
            _cQryID += " AND RTRIM(E1_NUMBCO) LIKE '%"+_cNumBco+"' "

			If Select("IDTIT") <> 0
				DbSelectArea("IDTIT")
				DbCloseArea()
			EndIf

			TCQUERY _cQryID NEW ALIAS "IDTIT"

			dbSelectArea("IDTIT")
			IDTIT->(dbGoTop())
            If !IDTIT->(EOF())

                aDados[1][1] := _cIdCnab := cNumTit := IDTIT->IDCNAB

            EndIf
		EndIf
	EndIf
	RestArea(aAreaSE1)

Return(aDados)
