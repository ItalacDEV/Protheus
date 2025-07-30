/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor       |   Data   |                              Motivo
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz    | 27/11/20 | Chamado 34791. Corrigir a Exibi��o de Mensagens do Operador Logistico e Redespacho no Danfe.
Julio Paz    | 30/11/20 | Chamado 32839. Inclus�o condi��o FindFunction("U_GRVPOLFLEX") para o
Lucas Borges | 23/04/21 | Chamado 36219. Refeito mensagens da nota e ajustes na gera��o do ICMS-ST anticipado.
Jerry        | 19/08/21 | Chamado 37503. Gravar o Campo de Veiculo Padr�o.
Jerry        | 29/11/21 | Chamado 38454. Corre��o nos crit�rios para Gravar o Status no PV e o Monitor do PV.
Alex Wallauer| 17/03/22 | Chamado 37645. Validacao para obrigar a informar os dados do Ve�culo/Motorista/Placa .
Alex Wallauer| 28/03/22 | Chamado 39450. Tratamento para buscar o campo A2_I_MOTOR para os pedidos Broker.
Alex Wallauer| 31/03/22 | Chamado 37645. Altera��o da Validacao p/ obrigar a informar dados do Ve�culo/Motorista/Placa .
Alex Wallauer| 08/04/22 | Chamado 39671. Grava��o dos dados do cliente de Remessa do SE1 .
Julio Paz    | 05/05/22 | Chamado 36404. Corre��es no c�lculo do peso bruto do item da nota para pesos vari�veis.
Alex Wallauer| 13/06/22 | Chamado 40456. Tratamento para o Novo Campo de Exceto Produto (ZZQ_PRODUT).
Igor Melga�o | 28/04/23 | Chamado 43489. Grava a data do Oper. Log. o Transit time Cadastrado.
Alex Wallauer| 09/05/23 | Chamado 43489. Ajustes na Gravacao a data do Oper. Log. o Transit time Cadastrado.
Alex Wallauer| 30/05/23 | Chamado 43489. Ajustes na Gravacao a data do Oper. Log. o Transit time Cadastrado.
Alex Wallauer| 01/06/23 | Chamado 44021. Corre��o na grava��o dos campos E1_I_CLIEN / E1_I_LOJEN.
Igor Melgaco | 29/06/23 | Chamado 44332. Ajustes para grava��o de campos de Transit time
Julio Paz    | 11/09/23 | Chamado 44679. Inclus�o de rotina para inclus�o de prazos a mais para opera��es triangulares.
Alex Wallauer| 23/01/24 | Chamado 46190. Vanderlei solicitou retirar a chamada do EmailFrete() dia 23/01/2024 AS 17:16.
Alex Wallauer| 01/02/24 | Chamado 46026. Jerry. Ajustes no calculo das datas Prev. Entrega Oper.Log e Prev. Entrega Cliente.
Antonio Neves| 16/02/24 | Chamado 46310. Adicionar o Valor do Ipi no Calculo do ICMS-ST para a gera��o do Tit. SE2/SE1
Antonio Neves| 20/03/24 | Chamado 46726. Adicionar o Valor do Ipi no Calculo do T�tulo de Desconto.
Julio Paz    | 02/04/24 | Chamado 29917. Jerry. Ajustar gera��o da NF p/gravar tipo frete do PV e NF com "R", p/frota veic=1
Alex Wallauer| 01/02/24 | Chamado 46480. Calcular e Gravar cpos novos: F2/D2_I_VLPED,F2/D2_I_VLSEG,F2/D2_I_VLCHE,F2/D2_I_FREOL.
Alex Wallauer| 31/05/24 | Chamado 47403. Jerry. Ajustes no calculo do campo da Previs�o de entrega no cliente F2_I_PENCL.
Alex Wallauer| 22/07/24 | Chamado 47942. Vanderlei. Ajustes na gravacao das Previs�es de entrega via ocorrecia.
Lucas Borges | 31/07/24 | Chamado 48058. Inclu�da fun��o para gravar movimento interno referente ao desconto Tetra Pak.
Lucas Borges | 01/08/24 | Chamado 48062. Retornada fun��o MsgSaida para o Local original.
Lucas Borges | 06/09/24 | Chamado 48316. Inclu�do par�metro para tratar CFOP.
===============================================================================================================================================================================================
Analista    - Programador   - Inicio   - Envio    - Chamado - Motivo da Altera��o
===============================================================================================================================================================================================
Vanderlei   - Alex Wallauer - 14/08/24 - 15/10/24 - 48138   - Tratamento do Local de Embarque (ZG5_LOCEMB) no cadastro de Transit Time.
Vanderlei   - Alex Wallauer - 16/08/24 - 15/10/24 - 47942   - Ajustes na gravacao das Previs�es de entrega via ocorrecia. Parte 2.
Jerrry      - Alex Wallauer - 01/10/24 - 15/10/24 - 48636   - Criado o campo ZEL_DIAUTI para definir se conta o S�bado para entrega ou n�o
Vanderlei   - Alex Wallauer - 27/08/24 - 28/08/24 - 46599   - Ajuste das datas de _dZF5DTOCOR > _dF2EMISSAO para _dZF5DTOCOR >= _dF2EMISSAO
Jerry       - Alex Wallauer - 03/02/25 - 03/02/25 - 49795   - Chamar os �ndices customizados da tabela SC5 com DBOrderNickName().
Jerry       - Alex Wallauer - 19/12/24 - 20/03/25 - 49126   - Novos ajustes na grava��o das datas do SF2 na fun��o U_AOMS3DTSF2 ().
Antonio     - Igor Melga�o  - 20/01/25 - 20/03/25 - 49170   - Ajustes para altera��o de titulos.
Antonio     - Igor Melga�o  - 27/02/25 - 20/03/25 - 49170   - Ajustes para altera��o de titulos.
Jerry       - Alex Wallauer - 24/03/24 - 24/03/25 - 49126   - Novos ajustes na grava��o das datas do SF2 na fun��o U_AOMS3DTSF2 ().
Vanderlei   - Alex Wallauer - 11/03/25 - 23/07/25 - 49894   - Novos rateios de peso bruto por itens de nota fiscal. Campo DAI_I_FROL
Vanderlei   - Alex Wallauer - 16/05/25 - 23/07/25 - 50687   - Ajuste no calculo das datas de previs�o para usar os peso na defini��o de cargas Fechada ou Fracionada.
Vanderlei   - Alex Wallauer - 24/07/25 - 24/07/25 - 49894   - Corre��o de Error.log: Update error - lock required - File: DAI010 
Vanderlei   - Alex Wallauer - 24/07/25 - 24/07/25 - 49894   - Corre��o de Error.log: variable does not exist _NVLRTOTFRET on MSGSAIDA(M460FIM.PRW) 24/07/2025 11:56:28 line : 1657
Vanderlei   - Alex Wallauer - 24/07/25 - 24/07/25 - 49894   - Corre��o de Error.log: variable does not exist _NVLRPEDAGIO on VALDADOS(M460FIM.PRW) 24/07/2025 16:56:57 line : 5021
Vanderlei   - Alex Wallauer - 25/07/25 - 25/07/25 - 49894   - Corre��o de Error.log: variable does not exist _COPPED on MSGSAIDA(M460FIM.PRW) 24/07/2025 19:36:53 line : 1712
===============================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
//====================================================================================================
#Include "Protheus.ch"
#Include "Ap5Mail.ch"

STATIC _AcertoPedagio:={}
STATIC _AcertoFreteOL:={}

/*
===============================================================================================================================
Programa.........: M460FIM
Autor............: TIAGO CORREA CASTRO
Data da Criacao..: 14/08/2008
Descricao........: Ponto de Entrada logo ap�s a grava��o dos dados da nota fiscal e fora da transa��o
Parametros.......: Nenhum
Retorno..........: Nenhum
===============================================================================================================================
*/
User Function M460FIM( _cNFDelete As Character )
	Local _aArea        := GetArea() As Array
	Local _cAlias       := GetNextAlias() As Character
	Local _cliente      := SF2->F2_CLIENTE As Character
	Local _loja         := SF2->F2_LOJA As Character
	Local _docx         := SF2->F2_DOC As Character
	Local _serie        := SF2->F2_SERIE As Character
	Local _cCarga       := SF2->F2_CARGA As Character
	Local _cTipoNf      := SF2->F2_TIPO As Character
	Local _cFilCli      := "" As Character
	Local cRede         := Space(6) As Character
	Local cQuery        := "" As Character
	Local _nPesoTotC    := 0 As Numeric
	Local _nPesoSoPallet:= 0 As Numeric
	Local _nVlrTotFret  := 0 As Numeric
	Local _nVlrPedagio  := 0 As Numeric
	Local _cljtr		 := "" As Character
	Local _cMotorDAK    := "" As Character
	Local _cCaminDAK    := "" As Character
	Local _cQuery		 := "" As Character
	Local _aDadosDAK    := {"","","",""} As Array
	Local _aSC5         := GetArea("SC5") As Array
	Local _aSC6         := GetArea("SC6") As Array
	Local _aSA1         := GetArea("SA1") As Array
	Local _aSA2         := GetArea("SA2") As Array
	Local _aSB1         := GetArea("SB1") As Array
	Local _aSD2         := GetArea("SD2") As Array
	Local _aSC9         := GetArea("SC9") As Array
	Local _aSD3         := GetArea("SD3") As Array
	Local _nNrRecno     := 0 As Numeric
	Local _cDAIRed      := "" As Character
	Local _lEmailFrete  := .F. As Logical
	Local _cOperTriangular:= Alltrim(SuperGetMV( "IT_OPERTRI",.F.,"05")) As Character // Tipos de opera��es da opera��o trigular // ANTONIO.RAMOS SOMENTE 05 , SEM 42
	Local _cOperFat       := LEFT(_cOperTriangular,2) As Character //faturamento de um pedido de venda
	Local _lGrvCliRemessa := .F. As Logical
	Local _cRemCliente    := "" As Character
	Local _cRemLojacli    := "" As Character
	Local _cTesteGrvCliRemessa := "" As Character
	Local _cCliProrT  := SuperGetMV( "IT_CLIPROT",.F.,"001242") As Character
	Local _cOperCliT  := "" As Character
	Local _nDdAdd     := 0 As Numeric
	Local _nDia       := 0 As Numeric
	Local _dDtVencT   := CTOD("") As Date
	Local _cDtVencT   := "" As Character
	Local _cClProRem  := "" As Character
	Local _cClProFat  := "" As Character
	Local _cCliSave   := SuperGetMV( "IT_CLISAVE",.F.,"") As Character//"013008"
	Local _cMesVencto := "" As Character
	Local _cDtVencto  := "" As Character
	Local _dDtVencto  := "" As Date

	//Desativa as teclas pq sen�o d� error.log ao apertar
	SetKey(VK_F4,)
	SetKey(VK_F5,)
	SetKey(VK_F9,)
	SetKey(VK_F10,)
	SetKey(VK_F12,)
	//====================================================================================================
	//Atualiza campos do SF2 e grava desconto contratual na SE1
	//====================================================================================================
	U_ContrSF2SE1()

	//====================================================================================================
	// Verifica se o documento � uma nota de devolucao, para que seja possivel atualizar a natureza na SE2
	//====================================================================================================
	If AllTrim(_cTipoNf) == 'D'
		AtualizNat( _docx , _serie , _cliente , _loja )
	EndIf

	//====================================================================================================
	// Grava dados de transportador e frete
	//====================================================================================================
	If !Empty( SF2->F2_CARGA )

		_cQuery := " SELECT DAK_I_FRET, DAK_PESO , DAK_MOTORI, DAK_CAMINH, DAK_I_REDP, DAK_I_RELO, DAK_I_OPER, DAK_I_OPLO,DAK_I_LJTR, DAK_I_VRPE "
		_cQuery += " FROM "+ RetSqlName("DAK") +" DAK "
		_cQuery += " WHERE DAK.DAK_FILIAL	= '"+ XFILIAL("DAK") +"' AND DAK_COD = '"+ SF2->F2_CARGA +"' "
		_cQuery += " AND	DAK.D_E_L_E_T_	= ' ' "

		MPSysOpenQuery( _cQuery , _cAlias)

		(_cAlias)->( DBGoTop() )

		//====================================================================================================
		// Armazena o peso total da carga para as cargas pedidos somente de PALLET
		//====================================================================================================
		_nPesoSoPallet	:= (_cAlias)->DAK_PESO // Quando a carga tem apenas PALLET o peso total � o mesmo do peso de pallet

		//====================================================================================================
		// Efetua somatorio total da carga DESCONSIDERANDO o peso dos pedidos de PALLET
		//====================================================================================================
		_nPesoTotC  := Cal2PesCarg( SF2->F2_CARGA , 1 )//Efetua o somatorio do Peso DA CARGA sem os PALLET
		_nVlrTotFret:= (_cAlias)->DAK_I_FRET
		_nVlrPedagio:= (_cAlias)->DAK_I_VRPE
		_cMotorDAK  := (_cAlias)->DAK_MOTORI
		_cCaminDAK  := (_cAlias)->DAK_CAMINH

		_cDAIRed := posicione("DAI",4,SF2->F2_FILIAL+SC5->C5_NUM+SF2->F2_CARGA,"DAI_I_TRED")
		_cljtr := (_cAlias)->DAK_I_LJTR  //Campo opcional que pode for�ar a escolha de uma loja de transpotador para a carga

		_credesp := IIf(empty(DAI->DAI_I_TRED),IIF(DAI->DAI_I_REDP != '2', (_cAlias)->DAK_I_REDP,""),DAI->DAI_I_TRED)
		_clojred := IIf(empty(DAI->DAI_I_TRED),IIF(DAI->DAI_I_REDP != '2', (_cAlias)->DAK_I_RELO,""),DAI->DAI_I_LTRE)

		_credesp := IIF(DAI->DAI_I_REDP=='2',"",_credesp)
		_clojred := IIF(DAI->DAI_I_REDP=='2',"",_clojred)

		_copera := IIf(empty(DAI->DAI_I_OPLO),IIF(DAI->DAI_I_OPER != '2', (_cAlias)->DAK_I_OPER,""),DAI->DAI_I_OPLO)
		_clojop := IIf(empty(DAI->DAI_I_OPLO),IIF(DAI->DAI_I_OPER != '2', (_cAlias)->DAK_I_OPLO,""),DAI->DAI_I_LOPL)

		_copera := IIF(DAI->DAI_I_OPER=='2',"",_copera)
		_clojop := IIF(DAI->DAI_I_OPER=='2',"",_clojop)

		_aDadosDAK := { _credesp,_clojred, _copera, _clojop }

		(_cAlias)->( DbCloseArea() )

		//====================================================================================================
		// Grava o nome da Transportadora e a placa - Dados da Carga
		//====================================================================================================
		grvDadosCg( _cMotorDAK , _cCaminDAK ,_aDadosDAK, , _cljtr )

		//====================================================================================================
		// Corre��o de problema encontrado na estorno de uma carga na tabela DAI
		//====================================================================================================
		If _nVlrTotFret > 0 .OR. _nVlrPedagio > 0
			refazFrDAI( SF2->F2_CARGA , _nVlrTotFret , _nPesoSoPallet , _nVlrPedagio)//Acerta o frete do 1o percurso do DAK_I_FRET para o DAI_I_FRET
		EndIf
	Else

		grvDadosCg(_cMotorDAK,_cCaminDAK,_aDadosDAK,"N") //Fun��o que grava dados de transportador e frete para pedidos com carga

	EndIf

	_cTesteGrvCliRemessa+="FILIAL : "+SF2->F2_FILIAL+CRLF
	_nNrRecno := PosicSC5(SF2->F2_DOC , SF2->F2_SERIE , SF2->F2_FILIAL)  // Retorna o numero do recno da tabela SC5 correspontentes a nota fiscal, serie e filial passados como par�metros.
	_cTesteGrvCliRemessa+="NOTA : "+SF2->F2_DOC+" - "+SF2->F2_SERIE+CRLF

	If _nNrRecno > 0
		SC5->(DbGoTo(_nNrRecno))  // Posiciona a tabela SC5 no registro relacionado a Nota Fiscal, Serie e Filial correspondentes da tabela SF2.

		_cTesteGrvCliRemessa+="Pedido : "+SC5->C5_NUM+CRLF

		//===========================================================
		// Obtem o tipo de frota de veiculo da carga.
		//===========================================================
		_cTpFroVei := ""
		If ! Empty(SF2->F2_VEICUL1)
			_cTpFroVei :=  Posicione( 'DA3' , 1 , xFilial('DA3')+SF2->F2_VEICUL1 , 'DA3_FROVEI' ) // 1=DA3_FILIAL+DA3_COD
		EndIf
		//-----------------------------------------------------------

		SF2->( RecLock( "SF2" , .F. ) )

		//====================================================================================================
		// Grava Informacao DO Local DE EMBARQUE
		//====================================================================================================

		SF2->F2_I_LOCEM := SC5->C5_I_LOCEM

		//====================================================================================================
		// Grava Informacao para saber se NF eh sedex
		//====================================================================================================

		SF2->F2_I_NFSED := SC5->C5_I_NFSED
		SF2->F2_I_NFREF := SC5->C5_I_NFREF

		//====================================================================================================
		// Grava Serie NF Referencia
		//====================================================================================================

		SF2->F2_I_SERNF := SC5->C5_I_SERNF

		//====================================================================================================
		// Grava Pedido NF Referencia
		//====================================================================================================

		SF2->F2_I_PEDID := SC5->C5_NUM
		//=================================================================================
		// Para frota de ve�culo pr�pria, atualizar pedido vendas com tipo de frete = "R"
		//=================================================================================
		If ! Empty(_cTpFroVei) .And. _cTpFroVei == "1" // Frota pr�pria
			SF2->F2_TPFRETE := "R" // R=POR CONTA REMETENTE
		EndIf

		SF2->( MsUnLock() )

		//Grava status do pedido para RDC e portal do cliente
		SC5->(RecLock("SC5",.F.))
		SC5->C5_I_STATU := "02"
		//=================================================================================
		// Para frota de ve�culo pr�pria, atualizar pedido vendas com tipo de frete = "R"
		//=================================================================================
		If ! Empty(_cTpFroVei) .And. _cTpFroVei == "1" // Frota pr�pria
			SC5->C5_TPFRETE := "R" // R=POR CONTA REMETENTE
		EndIf

		SC5->( MsUnlock() )

		// Grava monitor de pedidos de vendas para opera��es monitoradas

		If !(SC5->C5_I_OPER $ AllTrim(U_ITGETMV( 'IT_MPVOP' , '50/51/02')))

			_lEmailFrete := .T.
			_cJUSCOD:= "008"//FATURADO
			_cCOMENT:= "Faturamento via nota " + alltrim(SF2->F2_FILIAL) + " - " + ALLTRIM(SF2->F2_DOC) + "/" + ALLTRIM(SF2->F2_SERIE)
			U_GrvMonitor(,,_cJUSCOD,_cCOMENT,"N",SC5->C5_I_DTNEC,DATE(),SC5->C5_I_DTENT)
		EndIf

		SC5->(DbGoTo(_nNrRecno))  // Posiciona a tabela SC5 no registro relacionado a Nota Fiscal, Serie e Filial correspondentes da tabela SF2.
		_lGrvCliRemessa:=(SC5->C5_I_OPER = _cOperFat)//05
		IF _lGrvCliRemessa
			If SC5->(Dbseek(SC5->C5_FILIAL+SC5->C5_I_PVREM))//  ************* POSICIONA NO PV DE REMESSA
				_cRemCliente:=SC5->C5_CLIENTE
				_cRemLojacli:=SC5->C5_LOJACLI
			EndIf
			SC5->(DbGoTo(_nNrRecno))  // Posiciona a tabela SC5 no registro relacionado a Nota Fiscal, Serie e Filial correspondentes da tabela SF2.
		EndIf
		_cTesteGrvCliRemessa+="SC5->C5_I_OPER = "+SC5->C5_I_OPER+CRLF
		_cTesteGrvCliRemessa+="_lGrvCliRemessa = "+IF(_lGrvCliRemessa, ".T." , ".F." )+CRLF
		_cTesteGrvCliRemessa+="_cRemCliente = "+_cRemCliente+CRLF
		_cTesteGrvCliRemessa+="_cRemLojacli = "+_cRemLojacli+CRLF

	EndIf


	If SF2->F2_TIPO <> "D" .AND. SF2->F2_TIPO <> "B"

		SA1->( DBSetOrder(1) )
		If SA1->( DBSeek( xFilial("SA1") + _cliente + _loja ) )

			_cFilCli	:=	SA1->A1_I_FILOR
			cRede		:=	SA1->A1_GRPVEN
			cEstado		:=	SA1->A1_EST

		EndIf

		cQuery := " UPDATE "+RetSqlName("SE1")+" SET "
		cQuery += " 	E1_I_CARGA	= '"+ _cCarga	+ "', "
		cQuery += " 	E1_I_GPRVE	= '"+ cRede		+ "', "
		cQuery += " 	E1_I_EST	= '"+ cEstado	+ "' "
		cQuery += " WHERE "
		cQuery += " 	E1_FILIAL	= '"+ XFILIAL("SE1")	+"' "
		cQuery += " AND E1_CLIENTE	= '"+ _cliente			+"' "
		cQuery += " AND E1_LOJA		= '"+ _loja				+"' "
		cQuery += " AND E1_NUM		= '"+ _docx				+"' "
		cQuery += " AND E1_PREFIXO	= '"+ _serie			+"' "
		cQuery += " AND D_E_L_E_T_	= ' ' "

		_nRet:=TcSqlExec( cQuery )

		//================================================================================
		// Rotina para acerto da data de vencto real do titulo
		// Tamb�m prepara o campo de data de vencimento do portal
		//Tamb�m ajusta campo personalizado de carteira para clientes dos grupos 23/24
		//================================================================================
		SE1->( DBSetOrder(2) )
		SE1->( DBSeek( xFilial("SE1") + _cliente + _loja + _serie + _docx ) )

		While ( SE1->E1_FILIAL + SE1->E1_CLIENTE + SE1->E1_LOJA + SE1->E1_PREFIXO + SE1->E1_NUM  == ( xFilial("SE1") + _cliente + _loja + _serie + _docx ) )

			SE1->( RecLock( "SE1" , .F. ) )
			SE1->E1_VENCREA := dtvenc(_cliente, _loja, SE1->E1_VENCREA)
			SE1->E1_I_VCPOR := datavalida(SE1->E1_VENCTO)
			_cTesteGrvCliRemessa+="_lGrvCliRemessa = "+IF(_lGrvCliRemessa, ".T." , ".F." )+CRLF
			_cTesteGrvCliRemessa+="_cRemCliente = "+_cRemCliente+CRLF
			_cTesteGrvCliRemessa+="_cRemLojacli = "+_cRemLojacli+CRLF
			IF _lGrvCliRemessa
				SE1->E1_I_CLIEN :=_cRemCliente//SC5->C5_I_CLIEN
				SE1->E1_I_LOJEN :=_cRemLojacli//SC5->C5_I_LOJEN
				//SE1->E1_I_NOMEN :=RETFIELD("SA2",1,XFILIAL("SA2")+SE1->E1_I_CLIEN+SE1->E1_I_LOJEN,"A2_NOME")
			EndIf
			_cTesteGrvCliRemessa+="SE1->E1_I_CLIEN = "+SE1->E1_I_CLIEN+CRLF
			_cTesteGrvCliRemessa+="SE1->E1_I_LOJEN = "+SC5->C5_I_LOJEN+CRLF

			If SA1->A1_I_GRCLI == '23' .or. SA1->A1_I_GRCLIp == '24'

				SE1->E1_I_CART := '12'

			EndIf

			SE1->( MsUnLock() )

			SE1->( DBSkip() )
		EndDo

	EndIf

	IF U_ITGETMV("IT_GLOGDTNF",.F.)
		_cFileNome:="\data\logs_generico\m460fim_grv_se1_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+".txt"
		_cTesteGrvCliRemessa+=CRLF+"AMBIENTE:;"+ALLTRIM(GETENVSERVER())
		MemoWrite(_cFileNome,_cTesteGrvCliRemessa)
	EndIf

	PRIVATE _cMenFre1:=""
	PRIVATE _cMenFre2:=""
	PRIVATE _cMenFre3:=""

	//================================================================================
	//Grava Peso Total bruto do item na SD2
	//================================================================================
	PRIVATE _lTemArmazem52:=.F.//USADO DENTRO DA FUN��O GRAVAPESO ()
	GravaPeso(.T.)//GRAVA OS CAMPOS D2_I_PTBRU / F2_PBRUTO  para usar nos rateios de peso bruto por itens de nota fiscal.

	If !Empty( SF2->F2_CARGA )

		ZZ2->( DbSetOrder(2) )  // ZZ2_FILIAL+ZZ2_CARGA
		If ZZ2->( DBSeek( xFilial("ZZ2") + SF2->F2_CARGA ) )

			//================================================================================
			//| Chama fun��o para gera��o da tabela ZZ3 (Itens - RPA de Autonomos)           |
			//================================================================================
			GeraZZ3( _cNFDelete , _nPesoTotC , _nPesoSoPallet )

		EndIf

		//================================================================================
		//| Se possuir valor de Frete e a Carga possuir peso total maior que zero        |
		//================================================================================
		If DAI->DAI_I_FRET > 0 .And. _nPesoSoPallet > 0

			GravaFrete(DAI->DAI_I_FRET,_nPesoTotC,_nPesoSoPallet) // Rateia o frete do 1o percurso (DAK_I_FRET) entre os itens da nota fiscal

		Else

			_cMenFre1:="Valor do Frete ou Peso Total zerados, nao serao gravadas as informacoes do frete!"
			_cMenFre2:="Valor Total do Frete informado: "+ALLTRIM(Transform( _nVlrTotFret	, '@E 999,999,999.99'))
			_cMenFre3:="Valor Peso Total informado: "+ALLTRIM(Transform( _nPesoSoPallet	, '@E 999,999,999.99'))

		EndIf
        //** CALCULOS COM CARGA **
		//           _lGrava,_lCalcSeguro, _nPesoTotC,_nPesoSoPallet , _nTotPedagio,_nVlrCHEPTot ,_nVlrFretOL,_nPesTotOL
		U_GrvRatVlrs( .T.   , .T.        , _nPesoTotC,_nPesoSoPallet )

	EndIf

	MsgSaida()

	//================================================================================
	// Gera T�tulos a Pagar e Receber referente ao ICMS-ST
	//================================================================================
	If SF2->F2_TIPO == "N"
		GRVICMST()
	EndIf

	//================================================================================
	//Faz o reprocessamento do CDA 1298
	//================================================================================
	If U_ItGetMV("IT_CDA1298",.F.)
		U_MFIS004N()
	EndIf

	//==============================================================================
	//Garante que o SC9 da nota emitida est� com campo c9_ok vazio
	//==============================================================================
	SC9->(Dbsetorder(6)) //C9_FILIAL+C9_SERIENF+C9_NFISCAL
	If SC9->(Dbseek(SF2->F2_FILIAL+SF2->F2_SERIE+SF2->F2_DOC))

		Do while SC9->C9_FILIAL == SF2->F2_FILIAL .AND. SC9->C9_SERIENF == SF2->F2_SERIE .AND. SC9->C9_NFISCAL == SF2->F2_DOC

			If !Empty(Alltrim(SC9->C9_OK))
				Reclock("SC9",.F.)
				SC9->C9_OK := ""
				SC9->(Msunlock())
			EndIf
			SC9->(Dbskip())
		Enddo

	EndIf

	//===============================================================================
	//Grava campos referentes ao Transit time
	//===============================================================================
	If SF2->F2_TIPO == "N"
		GrvTransiTime(.T.)//Grava as datas calculadas
	EndIf
	//================================================================================

	//================================================================================
	// Envia e-mail caso n�o tenha sido gerado o valor de frete para uma carga
	//If _lEmailFrete .And. SF2->F2_TIPO == "N" // VANDERLEI MANDOU RETIRAR DIA 23/01/2024 AS 17:16
	//EmailFrete( _cCarga , _docx , _serie )
	//EndIf

	//================================================================================
	// Faz a prorroga��o de t�tulos em casos de Opera��es Triangular. Chamado 44679.
	//================================================================================
	_cOperCliT := POSICIONE("SC5",1,xFilial("SC5")+SF2->F2_I_PEDID,"C5_I_OPER")

	_nDdAdd := POSICIONE("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_I_ADDIA")
	//ADICIONADO 19/09/23 ANTONIO.RAMOS
	_cPedRem := POSICIONE("SC5",1,xFilial("SC5")+SF2->F2_I_PEDID,"C5_I_PVREM")
	_cCliRem := POSICIONE("SC5",1,xFilial("SC5")+_cPedRem,"C5_CLIENTE")

	_cClProFat := U_ITGETMV( "IT_CLPROFA","014124") // = PLAYVENDER
	_cClProRem := U_ITGETMV( "IT_CLIPRRM","001709") // = CASAS GUANABARA

	If _cOperCliT $ _cOperTriangular .And. _nDdAdd > 0

		SE1->(DbSetOrder(2)) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

		_cCliProrT := SubStr(_cCliProrT,1,6)

		SE1->(MsSeek(SF2->F2_FILIAL+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DOC))

		Do While SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM == ;
				SF2->F2_FILIAL+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DOC

			If SF2->F2_CLIENTE <> _cCliProrT // 001242 - BARCELOS & CIA LTDA.
				// ADICIONADO 19/09/2023 ANTONIO.RAMOS
				//If _cCliRem == "001709" /* CASAS GUANABARA*/ .And. SF2->F2_CLIENTE == "014124" //PLAYVENDER
				If _cCliRem == _cClProRem .And. SF2->F2_CLIENTE == _cClProFat //_cClProRem = "001709" = CASAS GUANABARA //  _cClProFat = "014124" = PLAYVENDER
					_nDdAdd := 0
				EndIf

				SE1->(RecLock("SE1",.F.))
				// ADICIONADO EM 18/09/2023 ANTONIO.RAMOS
				SE1->E1_VENCREA := dtvenc(SF2->F2_CLIENTE, SF2->F2_LOJA, (SE1->E1_VENCTO)+_nDdAdd)
				SE1->E1_VENCTO := SE1->E1_VENCTO + _nDdAdd
				SE1->(MsUnLock())
			Else
				//Para este Cliente/Adquirente s�o datas fixas
				_nDia     := Day(DataValida(SE1->E1_VENCREA + _nDdAdd))
				_dDtVencT := DataValida(SE1->E1_VENCREA + _nDdAdd)

				If _nDia == 1
					// SE1->E1_VENCREA := //Mant�m o dia 1
					// _dDtVencT
					_cDtVencT := "01/" + StrZero(Month(_dDtVencT),2) + "/" + StrZero(Year(_dDtVencT),4)
					_dDtVencT := Ctod(_cDtVencT)

				ElseIf _nDia > 1 .And. _nDia <= 7
					//SE1->E1_VENCREA := //Dia do Vencimento 7
					_cDtVencT := "07/" + StrZero(Month(_dDtVencT),2) + "/" + StrZero(Year(_dDtVencT),4)
					_dDtVencT := Ctod(_cDtVencT)

				ElseIf _nDia > 7 .And. _nDia <= 15
					// SE1->E1_VENCREA := //Dia do Vencimento 15
					_cDtVencT := "15/" + StrZero(Month(_dDtVencT),2) + "/" + StrZero(Year(_dDtVencT),4)
					_dDtVencT := Ctod(_cDtVencT)

				ElseIf _nDia > 15 .And. _nDia <= 22
					// SE1->E1_VENCREA := //Dia do Vencimento 22
					_cDtVencT := "22/" + StrZero(Month(_dDtVencT),2) + "/" + StrZero(Year(_dDtVencT),4)
					_dDtVencT := Ctod(_cDtVencT)

				ElseIf _nDia > 22 .And. _nDia <= 27
					//SE1->E1_VENCREA := //Dia Do Vencimento 27
					_cDtVencT := "27/" + StrZero(Month(_dDtVencT),2) + "/" + StrZero(Year(_dDtVencT),4)
					_dDtVencT := Ctod(_cDtVencT)
				Else
					//SE1->E1_VENCREA := //Dia do Vencimento 01 do m�s seguinte
					_dDtVencT := _dDtVencT + 10 // Para mudar para o m�s seguinte.
					_cDtVencT := "01/" + StrZero(Month(_dDtVencT),2) + "/" + StrZero(Year(_dDtVencT),4)
					_dDtVencT := Ctod(_cDtVencT)
				EndIf
				//RETIRADO EM 18/09/2023 ANTONIO.RAMOS
				//_dDtVencT := DataValida(_dDtVencT)

				SE1->(RecLock("SE1",.F.))
				//ADICIONADO EM 18/09/2023 ANTONIO.RAMOS
				SE1->E1_VENCTO := _dDtVencT
				//RETIRADO EM 18/09/2023 ANTONIO.RAMOS
				// _dDtVencT := DataValida(_dDtVencT)
				//_dDtVencT := dtvenc(_dDtVencT)

				SE1->E1_VENCREA := dtvenc(SF2->F2_CLIENTE, SF2->F2_LOJA, _dDtVencT)
				SE1->(MsUnLock())
			EndIf

			SE1->(DbSkip())
		EndDo
	EndIf

	///Igor Melga�o  - 20/01/25 - Chamado:  49170   - Ajustes para altera��o de titulos.
	If !EMPTY(_cCliSave) .AND. SF2->F2_CLIENTE == _cCliSave

		SE1->(DbSetOrder(2)) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

		SE1->(MsSeek(SF2->F2_FILIAL+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DOC))

		Do While SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM == ;
				SF2->F2_FILIAL+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DOC .AND. !SE1->(Eof())

			If Day(SE1->E1_VENCREA) >= 6 .And. Day(SE1->E1_VENCREA) <= 15 //�Vencimentos 06 a 15 - pagamento dia 10.
				_cDtVencto := "10/" + StrZero(Month(SE1->E1_VENCREA),2) + "/" + StrZero(Year(SE1->E1_VENCREA),4)
				_dDtVencto := Ctod(_cDtVencto)
			ElseIf Day(SE1->E1_VENCREA) > 16 .And. Day(SE1->E1_VENCREA) <= 25 //�Vencimentos 16 a 25 - pagamento dia 20
				_cDtVencto := "20/" + StrZero(Month(SE1->E1_VENCREA),2) + "/" + StrZero(Year(SE1->E1_VENCREA),4)
				_dDtVencto := Ctod(_cDtVencto)
			Else //�Vencimentos de 26 a 05 - pagamento dia 30
				If Day(SE1->E1_VENCREA) >= 26 .AND. Day(SE1->E1_VENCREA) <=31
					_cMesVencto := StrZero(Month(SE1->E1_VENCREA),2)
				Else
					_cMesVencto := StrZero(Month(SE1->E1_VENCREA)-1,2)
				EndIf

				_cDtVencto := Iif(_cMesVencto == "02","28/","30/") + _cMesVencto + "/" + StrZero(Year(SE1->E1_VENCREA),4)
				_dDtVencto := Ctod(_cDtVencto)
			EndIf

			SE1->(RecLock("SE1",.F.))
			SE1->E1_VENCTO := _dDtVencto
			SE1->E1_VENCREA := DataValida(_dDtVencto)
			SE1->(MsUnLock())

			SE1->(DbSkip())
		EndDo
	EndIf
	///Igor Melga�o  - 20/01/25 - Chamado:  49170   - Ajustes para altera��o de titulos.

	If SF2->F2_CLIENTE == 'F00004' .And. SF2->F2_TIPO == "D"
		DescTetraS()
	EndIf

	//==========================================================================
	//Restaura Integridade do Sistema.
	//==========================================================================
	Restarea(_aSD2)
	Restarea(_aSA1)
	Restarea(_aSA2)
	Restarea(_aSC5)
	Restarea(_aSC6)
	Restarea(_aSB1)
	Restarea(_aSC9)
	Restarea(_aSD3)
	RestArea(_aArea)

Return()

/*
===============================================================================================================================
Programa----------: GeraZZ3
Autor-------------: Tiago Correa
Data da Criacao---: 29/01/2009
Descri��o---------: Fun��o para a grava��o dos dados na Tabela ZZ3 e gerar t�tulo no Financeiro
Parametros--------: _cNFDelete , _nPesoTotC , _nPesoSoPallet
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function GeraZZ3( _cNFDelete , _nPesoTotC , _nPesoSoPallet )

	Local _aArea 		:= GetArea()
	Local _aDadImp		:= {}
	Local _aDadRet		:= {}
	Local _nPesoCarga	:= 0
	Local _nValFret 	:= 0
	Local _nDesconto   := 0
	Local _cRecibo 	:= ""
	Local _cCarga 		:= SF2->F2_CARGA
	Local _cANaturez 	:= GetMv("IT_NATRPA")
	Local _cNomeFor 	:= ""
	Local _cCodFor 	:= ""
	Local _cLojaFor 	:= ""
	Local aVetor 		:= {}
	Local _aParc		:= {}
	Local _cNatIRRF    := StrTran( GetMv("MV_IRF") , '"' , '' )
	Local _cFornIRRF   := PADR( GetMv("MV_UNIAO") , 6 )
	Local _cVctoIRRF   := GetMv( "MV_VENCIRF" )
	Local _dVctoIRRF   := StoD("")
	Local _cParcela    := "01"
	Local _cChave      := " "
	Local _nPedagio    := 0
	Local nModAnt      := nModulo
	Local cModAnt      := cModulo  , I

	Private lMsErroAuto := 	.F.

	IF !Empty( _cCarga )

		ZZ2->( DbSetOrder(2) ) // ZZ2_FILIAL+ZZ2_CARGA
		IF ZZ2->( Dbseek( xFilial("ZZ2") + _cCarga ) )

			//Verificar a Atualiza��o dos valores da ZZ2 para SEST, INSS e IRRF
			If ZZ2->ZZ2_SEST == 0 .And. ZZ2->ZZ2_INSS == 0 .And. ZZ2->ZZ2_IRRF == 0

				_aDadImp := {	ZZ2->ZZ2_AUTONO	,; //01
				(ZZ2->ZZ2_TOTAL-ZZ2->ZZ2_VRPEDA),; //02
				ZZ2->ZZ2_COND	,; //03
				'F'				,; //04
				2				 } //05

				_aDadRet := U_ITCALIMP( _aDadImp )

				If !Empty( _aDadRet )

					ZZ2->( RecLock( 'ZZ2' , .F. ) )

					ZZ2->ZZ2_SEST  	:= _aDadRet[01]
					ZZ2->ZZ2_INSS  	:= _aDadRet[02]
					ZZ2->ZZ2_IRRF	:= _aDadRet[03]

					ZZ2->( MsUnlock() )

				EndIf

			EndIf

			_nValFret 	:= ZZ2->ZZ2_TOTAL
			_cRecibo 	:= ZZ2->ZZ2_RECIBO
			_nDesconto := ZZ2->( ZZ2_PAMVLR + ZZ2_SEST + ZZ2_INSS ) //+ZZ2->ZZ2_IRRF
			_aParc 	:= Condicao( ZZ2->ZZ2_TOTAL , ZZ2->ZZ2_COND ,, dDataBase )
			_nPedagio 	:= ZZ2->ZZ2_VRPEDA

			//================================================================================
			//| Pesquisa os dados do Fornecedor na amarracao da logistica, caso nao encontre |
			//| pesquisa na amarracao de autonomo avulso criada                              |
			//================================================================================
			SA2->( DBOrderNickName("IT_AUTONOM") )
			If SA2->( DBSeek( xFilial("SA2") + ZZ2->ZZ2_AUTONO ) )

				_cCodFor	:=	ALLTRIM(SA2->A2_COD)
				_cLojaFor 	:= 	SA2->A2_LOJA
				_cNomeFor 	:= 	SA2->A2_NOME

			Else

				SA2->( DBOrderNickName("IT_AUTAVUL") )
				If SA2->( DBSeek( xFilial("SA2") + ZZ2->ZZ2_AUTONO ) )

					_cCodFor	:=	ALLTRIM(SA2->A2_COD)
					_cLojaFor 	:= 	SA2->A2_LOJA
					_cNomeFor 	:= 	SA2->A2_NOME

				EndIf

			EndIf

			_nPesoCarga := Posicione("DAK",1,xFilial("SF2")+_cCarga,"DAK_PESO")

			//================================================================================
			//| Grava registro ZZ3(itens no recibo de autonomo)                              |
			//================================================================================
			If !Empty( _cNFDelete )

				_nPesoCarga -= SF2->F2_PBRUTO

				SF2->( DBSetOrder(5) ) //F2_FILIAL+F2_CARGA+F2_SEQCAR+F2_SERIE+F2_DOC+F2_CLIENTE+F2_LOJA
				SF2->( DBSeek( xFilial("SF2") + _cCarga ) )

				While SF2->( !EOF() ) .And. SF2->( F2_FILIAL + F2_CARGA ) == xFilial("SF2") + _cCarga

					If !( _cNFDelete == SF2->F2_DOC )

						GravaZZ3(	_cRecibo		,;
							_cCarga			,;
							SF2->F2_DOC		,;
							SF2->F2_SERIE	,;
							SF2->F2_PBRUTO	,;
							_nValFret		,;
							_nPesoCarga		,;
							_nValFret		,;
							SF2->F2_EST		,;
							SF2->F2_EMISSAO	,;
							SF2->F2_I_PEDID	,;
							_nPesoTotC		,;
							_nPesoSoPallet  ,;
							_nPedagio       )

					EndIf

					SF2->( DBSkip() )
				EndDo

			Else

				GravaZZ3(	_cRecibo		,;
					_cCarga			,;
					SF2->F2_DOC		,;
					SF2->F2_SERIE	,;
					SF2->F2_PBRUTO	,;
					_nValFret		,;
					_nPesoCarga		,;
					_nValFret		,;
					SF2->F2_EST		,;
					SF2->F2_EMISSAO	,;
					SF2->F2_I_PEDID	,;
					_nPesoTotC		,;
					_nPesoSoPallet  ,;
					_nPedagio       )

			EndIf

			//================================================================================
			//| Gravando titulo no financeiro ref. ao valor do frete                         |
			//================================================================================
			If Len(_aParc) > 1

				//================================================================================
				//| Verifica se o t�tulo j� existe                                               |
				//================================================================================
				SE2->( DBSetOrder(1) ) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
				If !SE2->( DbSeek( xFilial("SE2") + "AUT" + ZZ2->ZZ2_RECIBO + "01" + "RPA" ) )

					For I := 1 To Len(_aParc)

						lMsErroAuto := .F.

						If I == 1

							aVetor  := {	{ "E2_PREFIXO"	, "AUT"						, Nil },;
								{ "E2_NUM"		, _cRecibo					, Nil },;
								{ "E2_PARCELA"	, STRZERO(I,2)				, Nil },;
								{ "E2_TIPO"		, "RPA"						, Nil },;
								{ "E2_NATUREZ"	, _cANaturez				, Nil },;
								{ "E2_FORNECE"	, _cCodFor					, Nil },;
								{ "E2_LOJA"		, _cLojaFor					, Nil },;
								{ "E2_EMISSAO"	, dDataBase					, Nil },;
								{ "E2_VENCTO"	, _aParc[I,1]				, Nil },;
								{ "E2_VENCREA"	, DataValida(_aParc[I,1])	, Nil },;
								{ "E2_VALOR"	, _aParc[I,2]				, Nil },;
								{ "E2_ORIGEM"	, "GERAZZ3"					, Nil } }

						Else

							//================================================================================
							//| Se for �ltima parcela desconta valor do seguro e impostos                    | -- Modificacao feita por Jeane
							//================================================================================
							aVetor  := {	{ "E2_PREFIXO"	, "AUT"																	, Nil },;
								{ "E2_NUM"		, _cRecibo																, Nil },;
								{ "E2_PARCELA"	, STRZERO(I,2)															, Nil },;
								{ "E2_TIPO"		, "RPA"																	, Nil },;
								{ "E2_NATUREZ"	, _cANaturez															, Nil },;
								{ "E2_FORNECE"	, _cCodFor																, Nil },;
								{ "E2_LOJA"		, _cLojaFor																, Nil },;
								{ "E2_EMISSAO"	, dDataBase																, Nil },;
								{ "E2_VENCTO"	, _aParc[I,1]			 												, Nil },;
								{ "E2_VENCREA"	, DataValida(_aParc[I,1])												, Nil },;
								{ "E2_VALOR"	, IIf( Len(_aParc) == I , _aParc[I,2] - _nDesconto , _aParc[I,2] )		, Nil },;
								{ "E2_IRRF"		, 0.00																	, Nil },; //Deve passar zerado para o ExecAuto e corrigir depois [Chamado-7155]
								{ "E2_VRETIRF"	, IIf( Len(_aParc) == I , ZZ2->ZZ2_IRRF , 0 )					   		, Nil },;
								{ "E2_PARCIR"	, IIf( Len(_aParc) == I .and. ZZ2->ZZ2_IRRF > 0 , _cParcela , "  " )	, Nil },;
								{ "E2_ORIGEM"	, "GERAZZ3"																, Nil } }

						EndIf

						//================================================================================
						//| Altera o modulo para Financeiro, senao o SigaAuto nao executa                |
						//================================================================================
						nModulo := 6
						cModulo := "FIN"

						//================================================================================
						//| Chama o ExecAuto para inclus�o do T�tulo                                     |
						//================================================================================
						MSExecAuto( {|x,y,z| Fina050(x,y,z) } , aVetor ,, 3 )

						If lMsErroAuto
							Mostraerro()
						EndIf

						//================================================================================
						// Inicio Altera��o - Incluida validacao para que seja
						// gravado o valor correto do titulo para os casos de IRF maior que 0 e menor que
						// 10 conforme chamado: 4841
						//================================================================================
						// Altera��o da tratativa para que seja atualizado o valor do IR que n�o pode ser
						// enviado pelo ExecAuto - [Chamado-7155]
						//================================================================================
						If Len(_aParc) == I .And. ZZ2->ZZ2_IRRF > 0.00

							SE2->( DbSetOrder(1) ) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
							If SE2->( DbSeek( xFilial("SE2") + "AUT" + _cRecibo + STRZERO(I,2) ) )

								SE2->( Reclock( "SE2" , .F. ) )

								_nValSE2		:= SE2->E2_VALOR

								SE2->E2_VALOR	:= _nValSE2 - ZZ2->ZZ2_IRRF
								SE2->E2_SALDO	:= _nValSE2 - ZZ2->ZZ2_IRRF
								SE2->E2_VLCRUZ	:= _nValSE2 - ZZ2->ZZ2_IRRF
								SE2->E2_IRRF	:= ZZ2->ZZ2_IRRF

								SE2->( MsUnlock() )

							EndIf

						EndIf

						//================================================================================
						//| Restaura o modulo em uso                                                     |
						//================================================================================
						nModulo := nModAnt
						cModulo := cModAnt

					Next I

				EndIf

			Else

				SE2->( DbSetOrder(1) ) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
				If !DbSeek(xFilial("SE2")+"AUT"+ZZ2->ZZ2_RECIBO+"  "+"RPA")

					//================================================================================
					// Modificacao feita por Jeane
					// Parcela unica: desconta valor do seguro e impostos
					//================================================================================
					For I := 1 to Len(_aParc)

						lMsErroAuto	:= .F.
						aVetor		:= {	{ "E2_PREFIXO"	, "AUT"											, Nil },;
							{ "E2_NUM"		, _cRecibo										, Nil },;
							{ "E2_PARCELA"	, "  "											, Nil },;
							{ "E2_TIPO"		, "RPA"											, Nil },;
							{ "E2_NATUREZ"	, _cANaturez									, Nil },;
							{ "E2_FORNECE"	, _cCodFor										, Nil },;
							{ "E2_LOJA"		, _cLojaFor										, Nil },;
							{ "E2_EMISSAO"	, dDataBase										, Nil },;
							{ "E2_VENCTO"	, _aParc[I,1]									, Nil },;
							{ "E2_VENCREA"	, DataValida(_aParc[I,1])						, Nil },;
							{ "E2_VALOR"	, _aParc[I,2] - _nDesconto						, Nil },;
							{ "E2_IRRF"		, 0.00				  							, Nil },; //Deve passar zerado para o ExecAuto e corrigir depois [Chamado-7155]
						{ "E2_VRETIRF"	, ZZ2->ZZ2_IRRF						 			, Nil },;
							{ "E2_PARCIR"	, IIf( ZZ2->ZZ2_IRRF > 0 , _cParcela , "  " )	, Nil },;
							{ "E2_ORIGEM"	, "GERAZZ3"										, Nil } }

						//================================================================================
						//| Altera o modulo para Financeiro, senao o SigaAuto nao executa.               |
						//================================================================================
						nModulo := 6
						cModulo := "FIN"

						MSExecAuto( {|x,y,z| Fina050( x , y , z ) } , aVetor ,, 3 )

						If lMsErroAuto
							Mostraerro()
						EndIf

						//================================================================================
						// Inicio Altera��o - Incluida validacao para que seja
						// gravado o valor correto do titulo para os casos de IRF maior que 0 e menor que
						// 10 conforme chamado: 4841
						//================================================================================
						// Altera��o da tratativa para que seja atualizado o valor do IR que n�o pode ser
						// enviado pelo ExecAuto - [Chamado-7155]
						//================================================================================
						If Len(_aParc) == I .And. ZZ2->ZZ2_IRRF > 0.00

							SE2->(DbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
							SE2->(DbSeek(xFilial("SE2")+"AUT"+_cRecibo+"  "))

							SE2->(Reclock ("SE2", .F.))
							SE2->E2_VALOR	:= ZZ2->ZZ2_TOTAL - ZZ2->ZZ2_SEST - ZZ2->ZZ2_INSS - ZZ2->ZZ2_IRRF - ZZ2->ZZ2_PAMVLR
							SE2->E2_SALDO	:= ZZ2->ZZ2_TOTAL - ZZ2->ZZ2_SEST - ZZ2->ZZ2_INSS - ZZ2->ZZ2_IRRF - ZZ2->ZZ2_PAMVLR
							SE2->E2_VLCRUZ	:= ZZ2->ZZ2_TOTAL - ZZ2->ZZ2_SEST - ZZ2->ZZ2_INSS - ZZ2->ZZ2_IRRF - ZZ2->ZZ2_PAMVLR
							SE2->E2_IRRF	:= ZZ2->ZZ2_IRRF
							SE2->(MsUnlock())

						EndIf

						//================================================================================
						//| Restaura o modulo em uso.                                                    |
						//================================================================================
						nModulo := nModAnt
						cModulo := cModAnt

					Next I

				EndIf

			EndIf

			//================================================================================
			//| Gera titulo TX p/ IRRF -- Modificado por Jeane                               |
			//================================================================================
			If ZZ2->ZZ2_IRRF > 0

				If _cVctoIRRF == "E"

					//================================================================================
					//| Gera o Vencimento para o m�s seguinte � dDataBase                            |
					//================================================================================
					_dVctoIRRF := MonthSum( CtoD( "20/"+ StrZero( Month( dDatabase ) , 2 ) +"/"+ StrZero( Year( dDatabase ) , 4 ) ) , 1 )

				ElseIf _cVctoIRRF == "V"

					_dVctoIRRF := CtoD( "20/"+ StrZero( Month( _aParc[len(_aParc),1] ) , 2 ) +"/"+ StrZero( year( _aParc[len(_aParc),1] ) , 4 ) )

				EndIf

				SA2->( DBSetOrder(1) ) // A2_FILIAL+A2_AUTONOM
				SA2->( DBSeek( xFilial("SA2") + _cFornIRRF ) )

				_cChave := "AUT"+ _cRecibo + IIf( Len(_aParc) > 1 , StrZero( Len(_aParc) , 2 ) , "  " ) +"RPA"+ _cCodFor + _cLojaFor

				SE2->( DBSetOrder(1) ) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
				If !SE2->( DBSeek( xFilial("SE2") + "AUT" + ZZ2->ZZ2_RECIBO + _cParcela + "TX " + SubStr( _cFornIRRF , 1 , 6 ) ) )

					lMsErroAuto	:= .F.

					aVetor		:= {	{ "E2_PREFIXO"	, "AUT"							, Nil },;
						{ "E2_NUM"		, _cRecibo						, Nil },;
						{ "E2_PARCELA"	, _cParcela						, Nil },;
						{ "E2_TIPO"		, "TX "							, Nil },;
						{ "E2_NATUREZ"	, _cNatIRRF						, Nil },;
						{ "E2_FORNECE"	, SubStr( _cFornIRRF , 1 , 6 )  , Nil },;
						{ "E2_LOJA"		, "00  "						, Nil },;
						{ "E2_EMISSAO"	, dDataBase						, Nil },;
						{ "E2_VENCTO"	, _dVctoIRRF					, Nil },;
						{ "E2_VENCREA"	, DataValida(_dVctoIRRF)		, Nil },;
						{ "E2_VALOR"	, ZZ2->ZZ2_IRRF					, Nil },;
						{ "E2_TITPAI"	, _cChave						, Nil },;
						{ "E2_ORIGEM"	, "GERAZZ3"						, Nil } }

					//================================================================================
					//| Altera o modulo para Financeiro, senao o SigaAuto nao executa.               |
					//================================================================================
					nModulo := 6
					cModulo := "FIN"

					MSExecAuto( {|x,y,z| Fina050( x , y , z ) } , aVetor ,, 3 )

					If lMsErroAuto
						Mostraerro()
					EndIf

					//================================================================================
					//| Restaura o modulo em uso.                                                    |
					//================================================================================
					nModulo := nModAnt
					cModulo := cModAnt

				EndIf

			EndIf

		EndIf

	EndIf

	RestArea(_aArea)

Return()

/*
===============================================================================================================================
Programa----------: GravaZZ3
Autor-------------: Tiago Correa
Data da Criacao---: 29/01/2009
Descri��o---------: Fun��o para a grava��o dos dados na Tabela ZZ3
Parametros--------: _cRecibo , _cCarga , _cDoc , _cSerie , _nPeso , _nValFret , _nPesoCarga , _nBaseIcm , _nEst , _cData , _cPedido , _nPesoTotC , _nPesoSoPallet , _nPedagio
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function GravaZZ3( _cRecibo , _cCarga , _cDoc , _cSerie , _nPeso , _nValFret , _nPesoCarga , _nBaseIcm , _nEst , _cData , _cPedido , _nPesoTotC , _nPesoSoPallet , _nPedagio )

	//================================================================================
	//| Se a carga montada tem produtos que n�o s�o do grupo de Unitizadores (PALLET)|
	//================================================================================
	If _nPesoTotC > 0

		If Cal2PesCarg( _cPedido , 2 ) > 0//Efetua o somatorio do Peso do Pedido

			ZZ3->( DBSetOrder(1) )
			ZZ3->( RecLock( "ZZ3" , .T. ) )

			ZZ3->ZZ3_FILIAL := xFilial("ZZ3")
			ZZ3->ZZ3_RECIBO := _cRecibo
			ZZ3->ZZ3_CARGA  := _cCarga
			ZZ3->ZZ3_DOC    := _cDoc
			ZZ3->ZZ3_SERIE  := _cSerie
			ZZ3->ZZ3_PESO   := _nPeso
			ZZ3->ZZ3_VLRFRT := ( _nValFret / _nPesoTotC ) * _nPeso
			ZZ3->ZZ3_BSICMS := _nBaseIcm
			ZZ3->ZZ3_DATA   := _cData
			ZZ3->ZZ3_EST  	 := _nEst
			ZZ3->ZZ3_VRPEDA := ( _nPedagio / _nPesoTotC ) * _nPeso

			ZZ3->( MsUnLock() )

		EndIf

		//================================================================================
		//| Carga montada somente com produtos de PALLET                                 |
		//================================================================================
	Else

		ZZ3->( DBSetOrder(1) )
		ZZ3->( RecLock( "ZZ3" , .T. ) )

		ZZ3->ZZ3_FILIAL:= xFilial("ZZ3")
		ZZ3->ZZ3_RECIBO:= _cRecibo
		ZZ3->ZZ3_CARGA := _cCarga
		ZZ3->ZZ3_DOC   := _cDoc
		ZZ3->ZZ3_SERIE := _cSerie
		ZZ3->ZZ3_PESO 	:= _nPeso
		ZZ3->ZZ3_VLRFRT:= ( _nValFret / _nPesoSoPallet ) * _nPeso
		ZZ3->ZZ3_BSICMS:= _nBaseIcm
		ZZ3->ZZ3_DATA  := _cData
		ZZ3->ZZ3_EST   := _nEst
		ZZ3->ZZ3_VRPEDA:= ( _nPedagio / _nPesoSoPallet ) * _nPeso

		ZZ3->( MsUnLock() )

	EndIf

Return()
/*
===============================================================================================================================
Programa----------: NotaRatVlrs
Autor-------------: Alex Wallauer
Data da Criacao---: 04/04/20225
Descri��o---------: Refaz o Rateio do valor do FRETE 1o PERCURSO / Chamada do programa MOMS010.PRW
Parametros--------: _nVlrFretNF As Numeric,  _nPeso As Numeric
Retorno-----------: GravaFrete ( _nVlrFretNF/SF2->F2_I_FRET , _nPesoTotC ,  _nPesoSoPallet )
===============================================================================================================================
*/
User Function NotaRatVlrs(_nVlrFretNF As Numeric,  _nPeso As Numeric)

	IF _nVlrFretNF <= 0 .OR. _nPeso <= 0
		Return .F.
	Endif

	IF !EMPTY(SF2->F2_CARGA)
		_nPesoTotC    := Cal2PesCarg( SF2->F2_CARGA , 1 )//Efetua o somatorio do Peso DA CARGA sem os PALLET
		_nPesoSoPallet:= _nPeso // Quando a carga tem apenas PALLET o peso total � o mesmo do peso de pallet
	Else
		_nPesoTotC    := _nPeso
		_nPesoSoPallet:= 0
	Endif

Return  GravaFrete( _nVlrFretNF , _nPesoTotC , _nPesoSoPallet )

/*
===============================================================================================================================
Programa----------: GravaFrete
Autor-------------: Tiago Correa
Data da Criacao---: 08/02/2009
Descri��o---------: Faz o Rateio do valor do FRETE 1o PERCURSO / Chamada do programa MOMS010.PRW tbm chamado por M460FIM.PRW
                    Grava o valor do frete na tabela SF2 e SD2
Parametros--------: _nVlrFretNF (DAI_I_FRET) , _nPesoTotC , _nPesoSoPallet
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function GravaFrete( _nVlrFretNF AS Numeric, _nPesoTotC AS Numeric, _nPesoSoPallet AS Numeric)
	Local _cDoc        := SF2->F2_DOC     As Char
	Local _cSerie      := SF2->F2_SERIE   As Char
	Local _cCliente    := SF2->F2_CLIENTE As Char
	Local _cLoja       := SF2->F2_LOJA    As Char
	Local _nPesoNota   := SF2->F2_PBRUTO  As Char
	Local nMaiorVlr    := 0 AS Numeric
	Local nMaiorRec    := 0 AS Numeric
	Local nVlrSomaFrete:= 0 AS Numeric
	Default _nVlrFretNF:= DAI->DAI_I_FRET

	//Se a carga possuir pedidos de PALLET e de outros produtos acabados as  notas de PALLET nao terao valor de FRETE rateado

	If _nPesoTotC > 0
		If Empty(SF2->F2_CARGA) .OR. Cal2PesCarg( SF2->F2_I_PEDID , 2 ) > 0//Efetua o somatorio do Peso do Pedido que n�o � de pallet
			//Gravacao do Valor Frete por nota
			SF2->( RecLock( "SF2" , .F. ) )
			SF2->F2_I_FRET := _nVlrFretNF
			SF2->( MsUnlock() )
			SD2->( DBSetOrder(3) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			If SD2->( DBSeek( xfilial("SD2") + _cDoc + _cSerie + _cCliente + _cLoja ) )
				While SD2->(!Eof()) .and. SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA ) == xFilial("SD2") + _cDoc + _cSerie + _cCliente + _cLoja
					IF SD2->D2_I_PTBRU > 0
						_nPesoItem := SD2->D2_I_PTBRU
					Else
						_nPesoItem := ( POSICIONE( "SB1" , 1 , xFilial("SB1") + SD2->D2_COD , "B1_PESBRU" ) * SD2->D2_QUANT )
					EndIF
					//================================================================================
					//| Gravacao do Valor Frete por item da Nota                                     |
					//================================================================================
					SD2->( RecLock( "SD2" , .F. ) )
					SD2->D2_I_FRET := ( ( _nVlrFretNF / _nPesoNota ) * _nPesoItem )
					SD2->( MsUnlock() )
					nVlrSomaFrete+=SD2->D2_I_FRET
					IF SD2->D2_I_FRET > nMaiorVlr
						nMaiorVlr:=SD2->D2_I_FRET
						nMaiorRec:=SD2->(RecNo())
					ENDIF
					SD2->( DBSkip() )
				EndDo
			EndIf
		EndIf
		//================================================================================
		// QUANDO SOMENTE PEDIDOS DE PALLET COMP�EM A CARGA
		//================================================================================
	ElseIF _nPesoSoPallet > 0
		//================================================================================
		//| Gravacao do Valor do Frete por nota                                          |
		//================================================================================
		SF2->( RecLock( "SF2" , .F. ) )
		SF2->F2_I_FRET := _nVlrFretNF
		SF2->( MsUnlock() )
		SD2->( DBSetOrder(3) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		If SD2->( DBSeek( xfilial("SD2") + _cDoc + _cSerie + _cCliente + _cLoja ) )
			While SD2->(!Eof()) .and. SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA ) == xfilial("SD2") + _cDoc + _cSerie + _cCliente + _cLoja
				//_nPesoItem := ( POSICIONE( "SB1" , 1 , xFilial("SB1") + SD2->D2_COD , "B1_PESBRU" ) * SD2->D2_QUANT )
				//================================================================================
				//| Gravacao do Valor Frete por item da Nota                                     |
				//================================================================================
				SD2->( RecLock( "SD2" , .F. ) )
				SD2->D2_I_FRET := ( ( _nVlrFretNF / _nPesoNota ) * SD2->D2_I_PTBRU )
				SD2->( MsUnlock() )
				nVlrSomaFrete+=SD2->D2_I_FRET
				IF SD2->D2_I_FRET > nMaiorVlr
					nMaiorVlr:=SD2->D2_I_FRET
					nMaiorRec:=SD2->(RecNo())
				ENDIF
				SD2->( DBSkip() )
			EndDo
		EndIf
	EndIf
	//================================================================================
	// Acertos de diferen�as de frete
	//================================================================================
	If _nPesoTotC > 0 .OR. _nPesoSoPallet > 0
		If nMaiorRec > 0  .And. (_nVlrFretNF > 0 .AND. nVlrSomaFrete > 0 .AND. nVlrSomaFrete <> _nVlrFretNF)
			SD2->( Dbgoto(nMaiorRec))
			SD2->( RecLock( "SD2" , .F. ) )
			If nVlrSomaFrete <> _nVlrFretNF
				SD2->D2_I_FRET:= SD2->D2_I_FRET + (_nVlrFretNF - nVlrSomaFrete )
			EndIf
			SD2->( MsUnlock() )
		EndIf
	ENDIF

Return .T.

/*
===============================================================================================================================
Programa----------: MsgSaida
Autor-------------: Abrahao Santos
Data da Criacao---: 20/07/2009
Descri��o---------: Grava Mensagens da NF
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MsgSaida()

	Local _cAlias		:= ""
	Local cMens1		:= ""
	Local cMens2		:= ""
	Local cMensAlt1	:= ""
	Local cMensAlt2	:= ""
	Local _lNovaMsg	:= .F.
	Local _lNovaMsg2	:= .F.
	Local oMemo01		:= Nil
	Local oMemo02		:= Nil
	Local oFont1		:= Nil
	Local oFont2		:= Nil
	Local _aMsg		:= {}
	Local _aMsg2		:= {}
	Local _nI   		:= 0
	Local lTemRedp     := .F.
	Local _cMsgTriangular:= U_ItGetMv("IT_MSGTRIAN"," ")
	Local _nRecSC5      := 0
	Local _nRecSF2      := 0
	Local _nRecOT       := 0
	Local _cPedRemessa  := ""
	Local _cPedFaturam  := ""
	Local _nMenRemessa  := ""
	Local _nMenFat      := ""
	Local _lTemMensagem := .F.
	Local _lEditaTransp := .T.
	Local _lEditaMens   := .T.
	Local _oDescMotor	:= NIL
	Local _cDescMotor   := Space(60)
	Local _oDescVeic	:= NIL
	Local _cDescVeic    := Space(30)
	Local _oMotorista	:= NIL
	Local _cMotorista   := Space(06)
	Local _oPlaca		:= NIL
	Local _cPlaca       := Space(08)
	Local _oVeiculo	    := NIL
	Local _cVeiculo     := Space(08)
	Local _cOperPVBr, _cVendBrok

	_cAlias:= GetNextAlias()
	BeginSql alias _cAlias
    SELECT M4_CODIGO, M4_I_COND1, M4_I_TPMSG, M4_I_MSG
       FROM %Table:SM4%
         WHERE D_E_L_E_T_ = ' '
           AND M4_FILIAL  = %xFilial:SM4%
           AND M4_MSBLQL  <> '1'
           AND M4_I_TPNOT = 'S'
           AND M4_I_CLIFO IN(%Exp:SF2->F2_CLIENTE% , ' ')
           AND %exp:dDataBase% BETWEEN M4_I_DTINI AND M4_I_DTFIM
	EndSql

	SD2->( DBSetOrder(3) )
	SD2->( DBSeek( SF2->( F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA ) ) )
	While SD2->(!Eof()) .And. SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA ) == SF2->( F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )
		(_cAlias)->(DBGoTop())
		While (_cAlias)->( !Eof() )
			If &((_cAlias)->M4_I_COND1)
				If (_cAlias)->M4_I_TPMSG == 'F'
					cMens2 := IIf(Empty(cMens2),&(AllTrim((_cAlias)->M4_I_MSG)),IIf(AllTrim((_cAlias)->M4_I_MSG) $ AllTrim(cMens2),cMens2,&(AllTrim((_cAlias)->M4_I_MSG))))
				Else
					cMens1 := IIf(Empty(cMens1),&(AllTrim((_cAlias)->M4_I_MSG)),IIf(AllTrim((_cAlias)->M4_I_MSG) $ AllTrim(cMens1),cMens1,&(AllTrim((_cAlias)->M4_I_MSG))))
				EndIf

				If Len(_aMsg) > 0
					_lNovaMsg := .T.
					For _nI := 1 To Len(_aMsg)
						If ( AllTrim( _aMsg[_nI][01] ) $ AllTrim(cMens1) )
							_lNovaMsg := .F.
							Exit
						EndIf
					Next _nI

					If _lNovaMsg
						aAdd( _aMsg , { cMens1 , (_cAlias)->M4_I_TPMSG , (_cAlias)->M4_CODIGO } )
					EndIf
				Else
					aAdd( _aMsg , { cMens1 , (_cAlias)->M4_I_TPMSG , (_cAlias)->M4_CODIGO } )
				EndIf

				If Len(_aMsg2) > 0
					_lNovaMsg2 := .T.
					For _nI := 1 To Len(_aMsg2)
						If ( AllTrim(_aMsg2[_nI][01]) $ AllTrim(cMens2) )
							_lNovaMsg2 := .F.
							Exit
						EndIf
					Next _nI

					If _lNovaMsg2
						aAdd( _aMsg2 , { cMens2 , (_cAlias)->M4_I_TPMSG , (_cAlias)->M4_CODIGO } )
					EndIf
				Else
					aAdd( _aMsg2 , { cMens2 , (_cAlias)->M4_I_TPMSG , (_cAlias)->M4_CODIGO } )
				EndIf
			EndIf

			(_cAlias)->( DBSkip() )
		EndDo
		SD2->( DBSkip() )
	EndDo

	//================================================================================
	// Ordena as mensagem pelo tipo Fiscal e pelo c�digo da mensagem cadastrada
	//================================================================================
	_aMsg	:= aSort( _aMsg		,,, {|x, y| x[2] + x[3] < y[2] + y[3] } )
	_aMsg2	:= aSort( _aMsg2	,,, {|x, y| x[2] + x[3] < y[2] + y[3] } )

	cMens1	:= ""
	cMens2	:= ""

	For _nI := 1 To Len(_aMsg)
		cMens1 += _aMsg[_nI][01]
	Next _nI

	For _nI := 1 To Len(_aMsg2)
		cMens2 += _aMsg2[_nI][01]
	Next _nI

	//================================================================================
	//Obtem Mensagens do Pedido
	//================================================================================
	If !Empty(SC5->C5_MENNOTA)
		cMens1 += AllTrim(SC5->C5_MENNOTA) + CRLF
	EndIf

	//============================================================================================================
	// Inclui mensagem de v�nculo com pedido de carregamento
	//============================================================================================================
	If SC5->C5_I_FILFT == SC5->C5_FILIAL .and. SC5->C5_I_TRCNF == "S"
		//=======================================================================================================
		// Grava campos de agendamento como mensagem para nota no ANTIGO PEDIDO de Faturamento transferido
		//=======================================================================================================
		cMens1 += "  -  Ped. Carr. " + SC5->C5_I_FLFNC + "/ " + SC5->C5_I_PDPR
		cMens1 += "  -  Not. Carr. " + SC5->C5_I_FLFNC + "/ " + posicione("SC9",1,SC5->C5_I_FLFNC+SC5->C5_I_PDPR,"C9_NFISCAL")
		cMens1 += "  -  Carg. Carr. " + SC5->C5_I_FLFNC + "/ " + posicione("SC9",1,SC5->C5_I_FLFNC+SC5->C5_I_PDPR,"C9_CARGA")
	EndIf

	If SC5->C5_I_FLFNC == SC5->C5_FILIAL .And. SC5->C5_I_TRCNF == "S"
		//=======================================================================================================
		// Grava campos de agendamento como mensagem para nota no NOVO PEDIDO de Carregamento
		//=======================================================================================================
		cMens1 += " - Ped. Fat. " + SC5->C5_I_FILFT + "/" + SC5->C5_I_PDFT + CRLF
	EndIf

	If !Empty(SC5->C5_I_TIPCA)
		cMens1	+=" Tipo Carga: "+If(SC5->C5_I_TIPCA="1","Paletizada","Batida")
	EndIf
	If !Empty(SC5->C5_I_HOREN)
		cMens1+=" Hora Entrega: "+AllTrim(SC5->C5_I_HOREN)
	EndIf
	If !Empty(SC5->C5_I_CHAPA)
		cMens1	+=" Qtd. Chapa: "+AllTrim(SC5->C5_I_CHAPA)
	EndIf
	If !Empty(SC5->C5_I_SENHA)
		cMens1	+=" Senha Pedido: "+AllTrim(SC5->C5_I_SENHA)
	EndIf
	If !Empty(SC5->C5_I_DOCA)
		cMens1	+=" Doca: "+AllTrim(SC5->C5_I_DOCA)
	EndIf

	If !Empty(SF2->F2_CARGA)

		DAI->( DBSetOrder(4) ) // DAI_FILIAL+DAI_PEDIDO+DAI->DAI_COD+DAI_SEQCAR
		SA2->( DBSetOrder(1) ) // A2_FILIAL + A2_COD + A2_LOJA

		If DAI->(MsSeek( SF2->F2_FILIAL + SF2->F2_I_PEDID + SF2->F2_CARGA))
			lTemRedp:=.F.
			If DAI->DAI_I_REDP = "1" .And. !Empty(DAI->DAI_I_TRED)  //S� imprime mensagem se tiver apenas um escolhido
				If SA2->( MsSeek( xFilial("SA2") + DAI->DAI_I_TRED + DAI->DAI_I_LTRE ) ) //Transportador Redespacho para o pedido
					lTemRedp:=.T.
					cMens1+= " Transp. Redespacho:"
					cMens1+= " "+AllTrim( SA2->A2_NOME	)
					cMens1+= " CNPJ: "+TRANSF( SA2->A2_CGC,AVSX3("A2_CGC",6))
					cMens1+= " I.E.: "+ALLTRIM(TRANSF( SA2->A2_INSCR,AVSX3("A2_INSCR",6)))
					cMens1+= " End.: "+AllTrim( SA2->A2_END)
					cMens1+= " "+AllTrim( SA2->A2_MUN)
					cMens1+= " "+AllTrim( Upper( SA2->A2_EST ))
				EndIf
			EndIf

			If !lTemRedp
				If DAI->DAI_I_OPER = "1" .And. !Empty(DAI->DAI_I_OPLO)  //S� imprime mensagem se tiver apenas um escolhido
					If SA2->( MsSeek( xFilial("SA2") + DAI->DAI_I_OPLO + DAI->DAI_I_LOPL ) ) //Transportador Operador Log�stico para o pedido
						cMens1+= " Transp. Redespacho:"
						cMens1+= " "+AllTrim( SA2->A2_NOME	)
						cMens1+= " CNPJ: "+TRANSF( SA2->A2_CGC,AVSX3("A2_CGC",6))
						cMens1+= " I.E.: "+ALLTRIM(TRANSF( SA2->A2_INSCR,AVSX3("A2_INSCR",6)))
						cMens1+= " End.: "+AllTrim( SA2->A2_END)
						cMens1+= " "+AllTrim( SA2->A2_MUN)
						cMens1+= " "+AllTrim( Upper( SA2->A2_EST ))
					EndIf
				EndIf
			EndIf
		EndIf

		DAI->( DBSetOrder(1) )

	EndIf

	//================================================================================
	//Tratamento para opera��o Triangular
	//================================================================================
	_nRecSC5:= SC5->(RECNO())
	_nRecSF2:= SF2->(RECNO())
	_nRecOT := 0
	_cPedRemessa := ""
	_cPedFaturam := ""
	_nMenRemessa := ""
	_nMenFat     := ""
	_lTemMensagem:= .F.
	_lEditaTransp:= .T.
	_lEditaMens  := .T.

	BEGIN SEQUENCE// Essa l�gica � para sempre pegar os dados das duas notas (venda e remessa) na gera��o da nota

		If !SC5->C5_I_OPTRI $ "F,R"
			Break
		EndIf
		_cPedRemessa := SC5->C5_I_PVREM
		_cPedFaturam := SC5->C5_I_PVFAT
		SC5->(DBSetOrder(1))
		SF2->(DBOrderNickName("IT_I_PEDID"))
		//================================================================================
		//Nota Fiscal de Venda - In�cio
		//================================================================================
		If SC5->C5_I_OPTRI = "F" // Estou no PV de VENDA e vou buscar o de Remessa
			//Se estou na NF de venda, posiciono na remessa
			If !SC5->(DBSeek(xFilial()+_cPedRemessa)) .OR. !SF2->(DBSEEK(xFilial()+_cPedRemessa))
				_nMenRemessa:= _nMenFat:= "NOTA FISCAL DO PEDIDO DE REMESSA : "+_cPedRemessa+" PENDENTE, Apos gerar a Nota do Pedido de Remessa essa mensagem ser� preenchida automaticamente"
				_lEditaMens := .F.
				Break
			EndIf
			//Carrega os dados da Carga do Pedido de Remessa
			_nRecOT      := SF2->(RECNO())
			_lEditaTransp:= .F.//N�o edita quando for venda pq sempre vale os dados da carga do pedido de Remessa
			_cVeiculo    := SF2->F2_I_VEICU
			_cDescVeic   := Posicione("DA3",1,xFilial("DA3") + _cVeiculo,"DA3_DESC")
			_cPlaca      := SF2->F2_I_PLACA
			_cMotorista  := SF2->F2_I_MOTOR
			_cDescMotor  := Posicione("DA4",1,xFilial("DA4") + _cMotorista,"DA4_NOME")
		EndIf//Se n�o, J� estou na NF de Remessa
		//Pega os dados da Nota de Remessa para imprimir na de Venda
		_nMenFat  := "REFERENTE FATURAMENTO NOTA FISCAL DE REMESSA "+ALLTRIM(SF2->F2_DOC)+" SERIE "+ALLTRIM(SF2->F2_SERIE)+" EMITIDA EM "+DTOC(SF2->F2_EMISSAO)
		_nMenFat  += " PARA O CLIENTE "
		If SA1->( DBSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ) )
			_nMenFat+= AllTrim( SA1->A1_NOME	)
			_nMenFat+= " COM CNPJ "+Transf( SA1->A1_CGC,AVSX3("A1_CGC",6))
			_nMenFat+= " E IE "+AllTrim(Transf( SA1->A1_INSCR,AVSX3("A1_INSCR",6)))
			_nMenFat+= " LocalIZADO NO ENDERECO "+AllTrim(SA1->A1_END)
			_nMenFat+= " BAIRRO "+AllTrim(SA1->A1_BAIRRO)
			_nMenFat+= " NA CIDADE "+AllTrim(SA1->A1_MUN)+" / "+AllTrim(Upper(SA1->A1_EST))
			_nMenFat+= " CEP "+AllTrim(SA1->A1_CEP) + " "
		EndIf

		_nMenFat+= _cMsgTriangular

		//================================================================================
		//Nota Fiscal de Venda - Fim
		//================================================================================

		SC5->( DBGoTo( _nRecSC5 ))//Volta para a nota atual onde estava para saber o tipo atual
		SF2->( DBGoTo( _nRecSF2 ))

		//================================================================================
		//Nota Fiscal de Remessa - In�cio
		//================================================================================
		If SC5->C5_I_OPTRI = "R" //Se o tipo atual for o PV de Remessa, busca a NF de Venda
			//Se achou na de Remessa, posiciono na de venda
			If !SC5->(DBSeek(xFilial()+_cPedFaturam)) .OR. !SF2->(DBSeek(xFilial()+_cPedFaturam))
				_nMenRemessa:= _nMenFat:= "NOTA FISCAL DO PEDIDO DE VENDA : "+_cPedFaturam+" PENDENTE, Apos gerar a Nota do Pedido de Venda essa mensagem ser� preenchida automaticamente"
				_lEditaMens := .F.
				Break
			EndIf
			_nRecOT:=SF2->(RECNO())
		EndIf
		//Pega os dados da Nota de Venda para imprimir na de Remessa
		_nMenRemessa  := "REFERENTE FATURAMENTO DA NOTA FISCAL DE VENDA "+AllTrim(SF2->F2_DOC)+" SERIE "+AllTrim(SF2->F2_SERIE)+" EMITIDA EM "+DToC(SF2->F2_EMISSAO)
		_nMenRemessa  += " PARA O CLIENTE "
		If SA1->( DBSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ) )
			_nMenRemessa+= AllTrim( SA1->A1_NOME	)
			_nMenRemessa+= " COM CNPJ "+Transf( SA1->A1_CGC,AVSX3("A1_CGC",6))
			_nMenRemessa+= " E IE "+AllTrim(Transf( SA1->A1_INSCR,AVSX3("A1_INSCR",6)))
			_nMenRemessa+= " LocalIZADO NO ENDERECO "+AllTrim(SA1->A1_END)
			_nMenRemessa+= " BAIRRO "+AllTrim(SA1->A1_BAIRRO)
			_nMenRemessa+= " NA CIDADE "+AllTrim(SA1->A1_MUN)+" / "+AllTrim(Upper(SA1->A1_EST))
			_nMenRemessa+= " CEP "+AllTrim(SA1->A1_CEP)
		EndIf
		//================================================================================
		//Nota Fiscal de Remessa - Fim
		//================================================================================
		_lTemMensagem:=.T.

	End SEQUENCE

	//Volto para onde estava
	SF2->(DBSetOrder(1))
	SC5->( DBGoTo( _nRecSC5 ))
	SF2->( DBGoTo( _nRecSF2 ))

	//================================================================================
	// Verifica se o Pedido de Vendas � Broker.
	//================================================================================
	_lPVBroker := .F.
	_lTelPVBro := .T.
	_cOperPVBr := U_ItGetMV("IT_OPEPVBR","XX")//12 // O Default � xx para n�o precisar criar o parametro em todas as filiais
	_cVendBrok := U_ItGetMV("IT_VENPVBR","001622")
	If SC5->C5_I_OPER $ _cOperPVBr  .And. SC5->C5_VEND1 $ _cVendBrok .And. SC5->C5_TIPO == "N"//.And. SC5->C5_FILIAL $ _cFilPVBro
		_lPVBroker := .T.
		SA3->( DBSetOrder(1) )
		SA3->( DBSeek( xFilial() + SC5->C5_VEND1 ) )//052983
		SA2->( DBSetOrder(1) )
		SA2->( DBSeek( xFilial() + SA3->A3_FORNECE+SA3->A3_LOJA ) )
		_cMotorista:= SA2->A2_I_MOTOR
		_lTelPVBro := U_ItGetMV("IT_TELPVBR",.F.)
		IF EMPTY(SA2->A2_I_MOTOR)
			_lTelPVBro:=.T.//Mostra a tela para o usuario informar o motorista
		EndIf
	EndIf
	_nVlrTotFret:=0
    _nVlrPedagio:=0
	_nVlrFretOL :=0
	_cOpPed     := SPACE(LEN(SF2->F2_I_OPER))//VariveL private para o F3 customizado funcionar.
	_cOpLja     := SPACE(LEN(SF2->F2_I_OPLO))//VariveL private para o F3 customizado funcionar.

	//================================================================================
	//Tratamento da Opera��o triangular
	//================================================================================
	If SC5->C5_I_OPER <> "02" .And. _lTelPVBro//! _lPVBroker // Diferente de vendas funcion�iros e Diferente de Pedido de Vendas Broker.

		DEFINE FONT oFont1 NAME "Tahoma" BOLD
		DEFINE FONT oFont2 NAME "Tahoma"

		DO WHILE .T.

			If Empty(_cMenFre1)
				_nLinDLG:=340
				_nLinBtn:=155
			Else
				_nLinDLG:=420
				_nLinBtn:=188
			EndIf

			DEFINE MSDIALOG oDlg TITLE "Mensagem da Nota Fiscal" FROM 000,000 TO _nLinDLG,500 PIXEL

			oTPanel1 := TPanel():New( 0 , 0 , "" , oDlg , NIL , .T. , .F. , NIL , NIL , 600 , 200 , .T. , .F. )

			@005,010 SAY "Mensagem NF"				 			               OF oTPanel1 Pixel FONT oFont1
			@020,010 SAY "NF/Serie....: "+ SF2->F2_DOC +"/"+ SF2->F2_SERIE	   OF oTPanel1 Pixel FONT oFont2
			@020,100 SAY "Emissao.....: "+ DToC(SF2->F2_EMISSAO)	           OF oTPanel1 Pixel FONT oFont2
			@020,160 SAY "Tipo: Saida"		                                   OF oTPanel1 Pixel FONT oFont2
			@030,010 SAY "Pedido......: "+ SC5->C5_NUM			               OF oTPanel1 Pixel FONT oFont2
			IF !EMPTY(SF2->F2_CARGA)
				@030,100 SAY "Carga.......: "+ SF2->F2_CARGA			           OF oTPanel1 Pixel FONT oFont2
			ENDIF
			@040,010 SAY SF2->F2_CLIENTE +"-"+ SF2->F2_LOJA +"-"+ SA1->A1_NOME OF oTPanel1 Pixel FONT oFont2
			If !Empty(_cPedRemessa)
				@ 030,160 SAY "Pedido de Remessa: "+_cPedRemessa               OF oTPanel1 Pixel FONT oFont2
			ElseIf !Empty(_cPedFaturam)
				@ 030,160 SAY "Pedido de Venda: " + _cPedFaturam               OF oTPanel1 Pixel FONT oFont2
			EndIf
			_nFimFolder:= 100
			oTFolder1 := TFolder():New( 050 , 005 , TRANSPVLD(_nMenRemessa,_nMenFat) ,, oTPanel1 ,,,, .T. ,, 240 , _nFimFolder )

			@005,005 Get oMemo01 var cMens1 MEMO Size 230,060 WHEN .T. OF oTFolder1:aDialogs[1] PIXEL
			@005,005 Get oMemo02 var cMens2 MEMO Size 230,060 WHEN .T. OF oTFolder1:aDialogs[2] PIXEL

			_nFoder:=2

			_bOK:={|| .T.}//INICIA SEMPRE SEM VALIDACAO

			nVlrTotFret:=0
			If Empty(SF2->F2_CARGA)// ************ SE N�O TEM CARAGA****************************************** ******************

				PRIVATE _AITALAC_F3:={}
				_cOpPed     := SPACE(LEN(SF2->F2_I_OPER))//VariveL private para o F3 customizado funcionar.
				_cOpLja     := SPACE(LEN(SF2->F2_I_OPLO))//VariveL private para o F3 customizado funcionar.
				_nVlrTotFret:= 0
				_nVlrPedagio:= 0
				_nVlrFretOL := 0
				SC5->( DBGoTo( _nRecSC5 ))
				_BSelectZ31:={|| "SELECT DISTINCT Z31_FORNEC, Z31_LOJA, Z31_NOMEFO, Z31_UF, A2_CGC FROM " + RETSQLNAME("Z31")+" Z31, " + RETSQLNAME("SA2") + " SA2  WHERE"+;
					" Z31_UF  = '"+SC5->C5_I_EST+"' AND "+;
					" Z31.D_E_L_E_T_ <> '*' AND SA2.D_E_L_E_T_ <> '*' AND Z31_FORNEC = A2_COD AND Z31_LOJA = A2_LOJA ORDER BY Z31_FORNEC, Z31_LOJA " }

				//AD(_aItalac_F3,{"_CAMPO1" ,_cTabela    ,_nCpoChave                                , _nCpoDesc                                             ,_bCondTab, _cTitAux                     , _nTamChv                         , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
				AADD(_aItalac_F3,{"_cOpPed" ,_BSelectZ31 ,{|Tab| (Tab)->Z31_FORNEC+(Tab)->Z31_LOJA }, {|Tab| (Tab)->A2_CGC+" "+ALLTRIM((Tab)->Z31_NOMEFO) } ,         ,"Operadores com Transit Time" ,LEN(Z31->Z31_FORNEC+Z31->Z31_LOJA),          ,1        ,.F.        ,       , } )

				_nFoder:=3
				IF !_lPVBroker .AND. _lEditaTransp .AND. SC5->C5_FILIAL = "90" .AND. SC5->C5_TIPO= "N" .AND. SC5->C5_TPFRETE = "C" .AND. _lTemArmazem52
					_bOK:={|| VAL_CMP(_cVeiculo,_cPlaca,_cMotorista) }
				EndIf

				nLin :=05
				nCol1:=01
				nCol2:=35
				nCol3:=nCol2+75
				nCol4:=nCol3+60
				_nPula:=13
				_nAltura:=9
				@ nLin  ,nCol1 SAY   "Veiculo:"		                                              OF oTFolder1:aDialogs[_nFoder] PIXEL
				@ nLin-2,nCol2 MSGET _oVeiculo  VAR _cVeiculo	               SIZE 046, _nAltura OF oTFolder1:aDialogs[_nFoder] PIXEL F3 "DA3" VALID (IIF(!EMPTY(_cVeiculo),IIF(EXISTCPO("DA3",_cVeiculo,1),buscaDA3(_cVeiculo,@_cDescVeic,@_cPlaca,@_cMotorista,@_cDescMotor),_oVeiculo:SETFOCUS()),Eval({|| _cDescVeic:="",_cPlaca:="",.T.}))) WHEN _lEditaTransp
				@ nLin-2,086   MSGET _oDescVeic VAR _cDescVeic	               SIZE 150, _nAltura OF oTFolder1:aDialogs[_nFoder] PIXEL
				nLin+=_nPula
				@ nLin  ,nCol1 SAY	"Placa:"                                                      OF oTFolder1:aDialogs[_nFoder] PIXEL
				@ nLin-2,nCol2 GET	_oPlaca	      VAR _cPlaca                  SIZE 046,_nAltura  OF oTFolder1:aDialogs[_nFoder] PIXEL PICTURE GetSx3Cache("F2_I_PLACA","X3_PICTURE") WHEN _lEditaTransp
				nLin+=_nPula
				@ nLin  ,nCol1 SAY	"Motorista:"                                                  OF oTFolder1:aDialogs[_nFoder] PIXEL
				@ nLin-2,nCol2 MSGET _oMotorista VAR	_cMotorista	F3 "DA4"       SIZE 046, _nAltura OF oTFolder1:aDialogs[_nFoder] PIXEL VALID (IIF(!EMPTY(_cMotorista),IIF(EXISTCPO("DA4",_cMotorista,1),_cDescMotor:=POSICIONE("DA4",1,XFILIAL("DA4") + _cMotorista,"DA4_NOME"),_oMotorista:SETFOCUS()),Eval({|| _cDescMotor:="",.T.}))) WHEN _lEditaTransp
				@ nLin-2,086   MSGET _oDescMotor VAR	_cDescMotor	               SIZE 150, _nAltura OF oTFolder1:aDialogs[_nFoder] PIXEL
				nLin+=_nPula
				@ nLin  ,nCol1 SAY	"Valor Pedagio: "                                             OF oTFolder1:aDialogs[_nFoder] PIXEL
				@ nLin-2,nCol2+8 GET	_oVlrPedag    VAR _nVlrPedagio             SIZE 060,_nAltura  OF oTFolder1:aDialogs[_nFoder] PIXEL VALID ValDados("PEDAGIO") PICTURE GetSx3Cache("F2_I_VLPED","X3_PICTURE")
				@ nLin  ,nCol3 SAY	"Vlr Frete 1o Percurso:"	                                  OF oTFolder1:aDialogs[_nFoder] PIXEL
				@ nLin-2,nCol4 GET	_oVlrFre1     VAR _nVlrTotFret             SIZE 060,_nAltura  OF oTFolder1:aDialogs[_nFoder] PIXEL VALID ValDados("FRETE1") PICTURE GetSx3Cache("F2_I_FRET","X3_PICTURE")
				nLin+=_nPula
				@ nLin  ,nCol1 SAY	"Oper. Logistico:"                                            OF oTFolder1:aDialogs[_nFoder] PIXEL
				@ nLin-2,nCol2+08 MSGET _oOperLog   VAR _cOpPed    F3 "F3ITLC" SIZE 025, _nAltura  OF oTFolder1:aDialogs[_nFoder] PIXEL VALID ValDados("OPERADOR")
				@ nLin-2,nCol2+45 MSGET _oOperLoja  VAR _cOpLja                SIZE 020, _nAltura  OF oTFolder1:aDialogs[_nFoder] PIXEL VALID ValDados("OPERADOR")
				//nLin+=_nPula
				@ nLin  ,nCol3 SAY	"Vlr Frete 2o Percurso:"                                      OF oTFolder1:aDialogs[_nFoder] PIXEL
				@ nLin-2,nCol4 GET	_oVlrFre2     VAR _nVlrFretOL              SIZE 060,_nAltura  OF oTFolder1:aDialogs[_nFoder] PIXEL VALID ValDados("FRETE2") PICTURE GetSx3Cache("F2_I_FREOL","X3_PICTURE") WHEN !Empty(_cOpPed)
				_oDescVeic:Disable()
				_oPlaca:Disable()
				_oDescMotor:Disable()
			EndIf

			If !Empty(_nMenRemessa) .OR. !Empty(_nMenFat)//Tratamento da Opera��o Triangular
				_nFodM1:=_nFoder+1
				@005,005 Get _nMenRemessa MEMO Size 230,060 OF oTFolder1:aDialogs[_nFodM1] PIXEL WHEN _lEditaMens
				_nFodM2:=_nFoder+2
				@005,005 Get _nMenFat     MEMO Size 230,060 OF oTFolder1:aDialogs[_nFodM2] PIXEL WHEN _lEditaMens
			EndIf

			If !Empty(_cMenFre1)
				_nFimFolder+=55
				@_nFimFolder,010 SAY _cMenFre1	Pixel FONT oFont1 Of oTPanel1
				_nFimFolder+=10
				@_nFimFolder,010 SAY _cMenFre2	Pixel FONT oFont1 Of oTPanel1
				_nFimFolder+=10
				@_nFimFolder,010 SAY _cMenFre3	Pixel FONT oFont1 Of oTPanel1
			EndIf

			TButton():New( _nLinBtn , 090 , ' Confirma ', oTPanel1 , {|| IF(EVAL(_bOK),oDlg:END(),) }	, 70 , 12 ,,,, .T. )

			ACTIVATE MSDIALOG oDlg Centered

			IF !EVAL(_bOK)
				Loop
			EndIf
			EXIT
		ENDDO

	EndIf

	If Empty(SF2->F2_CARGA)
		If _nVlrTotFret > 0
			GravaFrete(_nVlrTotFret,SF2->F2_PBRUTO,0) // Rateia o frete do 1o percurso
		EndIf
		If (_nVlrPedagio+_nVlrFretOL) > 0
            //** CALCULOS SEM CARGA **
			//            _lGrava,_lCalcSeguro, _nPesoTotC    ,_nPesoSoPallet , _nTotPedagio,_nVlrCHEPTot ,_nVlrFretOL,_nPesTotOL
			U_GrvRatVlrs( .T.    , .F.        , SF2->F2_PBRUTO,0              , _nVlrPedagio,             ,_nVlrFretOL,SF2->F2_PBRUTO) // Rateia o frete do 2o percurso e pedagio
		EndIf
	EndIf
	//===========================================================================
	//Realizado ajuste para gravar a mensagem corretamente nos campos
	//"F2_I_MENSA"/"F2_MENFI" --
	//===========================================================================
	IF SubStr( cMens1 , Len(cMens1) , 1 ) <> ";"
		cMens1 += ";"
	EndIf

	IF SubStr( cMens2 , Len(cMens2) , 1 ) <> ";"
		cMens2 += ";"
	EndIf

	cMensAlt1 := ESPMSGNF( cMens1 )
	cMensAlt2 := ESPMSGNF( cMens2 )
	//================================================================================
	//Tratativa da Mensagem para impress�o correta das linhas na NF
	//================================================================================
	SF2->( RecLock( "SF2" , .F. ) )

	SF2->F2_I_MENSA := StrTran( cMensAlt1 , CRLF , "" )
	SF2->F2_I_MENFI := StrTran( cMensAlt2 , CRLF , "" )
	If Empty(SF2->F2_CARGA)
		//==================================================================================
		//Incluida valida��o para verificar a carga para  que  n�o grave o conteudo em
		//branco da placa que j�  foi  gravado  anteriormente asinforma��es  . Chamado: 3700
		//==================================================================================
		DA4->( DbSetOrder(1) )
		DA4->( DbSeek( xFilial("DA4") + _cMotorista) )
		SA2->( DBSetOrder(1) )
		SA2->( DBSeek( xFilial("SA2") + DA4->( DA4_FORNEC + DA4_LOJA ) ) )

		SF2->F2_I_VEICU:= _cVeiculo
		SF2->F2_I_PLACA:= _cPlaca
		SF2->F2_I_MOTOR:= _cMotorista
		SF2->F2_I_NTRAN:= SA2->A2_NOME
		SF2->F2_I_NMOT := DA4->DA4_NOME
		SF2->F2_I_CTRA := DA4->DA4_FORNEC
		SF2->F2_I_LTRA := DA4->DA4_LOJA
		SF2->F2_VEICUL1:= _cVeiculo
		SF2->F2_I_VLPED:= _nVlrPedagio
		SF2->F2_I_FRET := _nVlrTotFret//1o percurso
		SF2->F2_I_OPER := _cOpPed
		SF2->F2_I_OPLO := _cOpLja
		SF2->F2_I_FREOL:= _nVlrFretOL //2o percurso
	EndIf

	If _lTemMensagem .AND. _nRecOT # 0

		_nMenRemessa:= ESPMSGNF( _nMenRemessa )
		_nMenFat    := ESPMSGNF( _nMenFat )

		If SC5->C5_I_OPTRI = "R"
			SF2->F2_I_MENOT := StrTran( _nMenRemessa , CRLF , "" )
			SF2->( MSUNLOCK() )//Fecha SF2 atual

			SF2->(DBGOTO(_nRecOT))
			SF2->( RecLock( "SF2" , .F. ) )//Abre o do _nRecOT
			SF2->F2_I_MENOT := StrTran( _nMenFat , CRLF , "" )
			SF2->F2_I_VEICU := _cVeiculo  //Regrava os dados da carga da Remessa
			SF2->F2_I_PLACA := _cPlaca    //Regrava os dados da carga da Remessa
			SF2->F2_I_MOTOR := _cMotorista//Regrava os dados da carga da Remessa

		ElseIf SC5->C5_I_OPTRI = "F"
			SF2->F2_I_MENOT := StrTran( _nMenFat , CRLF , "" )
			SF2->( MSUNLOCK() )//Fecha SF2 atual

			SF2->(DBGOTO(_nRecOT))
			SF2->( RecLock( "SF2" , .F. ) )//Abre o do _nRecOT
			SF2->F2_I_MENOT := StrTran( _nMenRemessa , CRLF , "" )
			SF2->F2_I_VEICU := _cVeiculo  //Regrava os dados da carga da Remessa
			SF2->F2_I_PLACA := _cPlaca    //Regrava os dados da carga da Remessa
			SF2->F2_I_MOTOR := _cMotorista//Regrava os dados da carga da Remessa
		EndIf
	EndIf

	SF2->( MSUnLock() )//Fecha do atual ou do _nRecOT
	//Volto o Recno depois do msunlock pq se teve mensagem tenho que fechar o MsUnlock() do _nRecOT
	//Se n�o teve mensagem vai fechar o MsUnlock() do recno atual mesmo do SF2
	SF2->( DBGoTo( _nRecSF2 ))

	//Cadastra os complementos de notas fiscais de entrada e de saida com as informacoes necessarias ao Sped.
	//N�o � poss�vel usar o SF2460I uma vez que usa informa��es que s� ser�o inclu�das nesse PE, que � posterior e fora da transa��o.
	Processa( {|| U_ICompFis("S",SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TPFRETE,cMens2) }, "Aguarde...", "Incluindo Complementos Fiscais...",.F.)

Return()

/*
===============================================================================================================================
Programa----------: contrSF2SE1
Autor-------------: Fabiano Dias
Data da Criacao---: 03/12/2009
Descri��o---------: Ponto de Entrada durante a grava��o da SF2 - Cabe�alho da NF
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function contrSF2SE1()
	Local _aArea		:= GetArea()
	Local _aAreaSF2    := GetArea("SF2")
	Local _aContrat  	:= {}
	Local _cAlias		:= GetNextAlias()
	Local _cQuery    	:= ""
	Local _nNumParc
	Local _cNumDoc  	:= SF2->F2_DOC		//Numero da nota fiscal
	Local _cNumPref  	:= SF2->F2_SERIE	//Serie da nota fiscal
	Local _cNumCli   	:= SF2->F2_CLIENTE	//Cliente
	Local _cNumLoj   	:= SF2->F2_LOJA		//Loja
	Local _cFilSF2   	:= SF2->F2_FILIAL	//Filial de Faturamento
	Local _nValorParc	:= 0	//Valor da parcela para cada titulo, menos o ultimo
	Local _nVlrParUlt	:= 0	//Armazena o valor da ultima parcela, isto para evitar que na dizima no montante final dar parcelas de diferenca de centavo
	Local _lContrato	:=.F.
	Local _nTotVlDInt	:= 0	//Variavel que armazena o valor total do desconto integral
	Local _nTotVlDPar	:= 0	//Variavel que armazena o valor total do desconto parcial
	Local _nDescFinan	:= 0	//Variavel que armazena o valor total do desconto gerado no financeiro
	Local _cNumContra	:= ""	//Armazena o numero do contrato
	Local _ntotal		:= 0
	Local _cusast		:= "N"
	//===========================================================================
	//01 - Valor do desconto INTEGRAL
	//02 - Se o contrato esta aprovado pelo depto financeiro
	//03 - Se o contrato esta com a data de vigencia em vigor
	//04 - Numero do contrato para emitir na msg ao usuario [nao utilizado mais]
	//05 - Valor do desconto PARCIAL
	//06 - Tipo do abatimento do desconto contratual por item do contrato
	//===========================================================================
	Local _aDados   := { 0 , .T. , .T. , "" , 0 , "" }

	//=============================================================================
	//Verifica se os dados do contrato estao com a data de vigencia ativa, se  ele
	//nao esta bloqueado e se ele esta aprovado pelo financeiro caso as  condicoes
	//acima estejam atendidas, os dados do pedido sao armazenados na SF2, e retona
	//o tipo do abatimento
	//=============================================================================
	//O codigo abaixo faz parte da alteracao que nao englobara mais  o  pedido  de
	//venda e sim somente SF2 e SD2. Percorre a SD2
	//=============================================================================
	SD2->( DBSetOrder(3) )
	If SD2->( DBSeek( _cFilSF2 + _cNumDoc + _cNumPref + _cNumCli + _cNumLoj ) )

		While SD2->(!Eof()) .And. SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA ) == _cFilSF2 + _cNumDoc + _cNumPref + _cNumCli + _cNumLoj

			//================================================================================
			//| Se Gerar financeiro executa a busca por dados do desconto contratual         |
			//================================================================================
			If ( Posicione( "SF4" , 1 , SD2->D2_FILIAL + SD2->D2_TES , "F4_DUPLIC" ) == 'S' )

				_aDados := U_veriContrato( SD2->D2_CLIENTE , SD2->D2_LOJA , SD2->D2_COD ) //Verifica se existe calculo para o desconto

				//carrega dados padr�o
				_ntotal := SD2->D2_TOTAL
				_cusast := "N"
				_cusaicms := "N"
				_cusapis := "N"
				_cusacofins := "N"
				_cusaipi	:= "N" //Chamado 46726


				//Posiciona ZAZ
				ZAZ->(Dbsetorder(1))

				If ZAZ->(Dbseek(xfilial("ZAZ")+_aDados[4]))

					_ntotal := SD2->D2_TOTAL

					//================================================================================
					//| Verifica se considera ST como base do desconto                               |
					//================================================================================
					If ZAZ->ZAZ_STBAS = "S"

						_ntotal := _ntotal + SD2->D2_ICMSRET
						_cusast := "S"

					EndIf


					//================================================================================
					//| Verifica se considera IPI como base do desconto - Chamado 46726              |
					//================================================================================
					If ZAZ->ZAZ_IPIBAS = "S"

						_ntotal := _ntotal + SD2->D2_VALIPI
						_cusaipi := "S"

					EndIf




					//================================================================================
					//| Verifica se considera ICMS como base do desconto                               |
					//================================================================================
					If ZAZ->ZAZ_ICMBAS = "N"

						_ntotal := _ntotal - SD2->D2_VALICM
						_cusaicms := "S"

					EndIf

					//================================================================================
					//| Verifica se considera PIS como base do desconto                               |
					//================================================================================
					If ZAZ->ZAZ_PISBAS = "N"

						_ntotal := _ntotal - SD2->D2_VALIMP6
						_cusapis := "S"

					EndIf

					//================================================================================
					//| Verifica se considera PIS como base do desconto                               |
					//================================================================================
					If ZAZ->ZAZ_COFBAS = "N"

						_ntotal := _ntotal - SD2->D2_VALIMP5
						_cusacofins := "S"

					EndIf


				EndIf

				//================================================================================
				//| Verifica o desconto integral                                                 |
				//================================================================================
				If _aDados[1] > 0

					//================================================================================
					//| Se estiver aprovado pelo financeiro e com data de vigencia ativa             |
					//================================================================================
					If _aDados[2] .And. _aDados[3]

						//================================================================================
						//| Atualiza a Tabela SD2                                                        |
						//================================================================================

						SD2->( RecLock( "SD2" , .F. ) )

						SD2->D2_I_PRCDC	:= _aDados[1]						//Percentual de desconto - GUILHERME - 07/11/2012
						SD2->D2_I_VLRDC	:= _ntotal * ( _aDados[1] / 100 )	//Valor do desconto integral
						SD2->D2_I_VLPAR	:= _ntotal * ( _aDados[5] / 100 )	//Valor do desconto parcial
						SD2->D2_I_TPABA	:= _aDados[6]						//Armazena o tipo do abatimento por item

						SD2->( MsUnLock() )

						//================================================================================
						//| Efetua somat�rio do valor a gerar no financeiro - abatimento integral        |
						//================================================================================
						If _aDados[6] == 'I'

							_nDescFinan += SD2->D2_I_VLRDC//_ntotal * ( _aDados[1] / 100 )

							//================================================================================
							//| Efetua somat�rio do valor a gerar no financeiro - abatimento parcial         |
							//================================================================================
						ElseIf _aDados[6] == 'P'

							_nDescFinan += SD2->D2_I_VLPAR//_ntotal * ( _aDados[5] / 100 )

						EndIf

						_nTotVlDInt	+= SD2->D2_I_VLRDC//_ntotal * ( _aDados[1] / 100 )			//Efetua o somatorio do desconto integral
						_nTotVlDPar	+= SD2->D2_I_VLPAR//_ntotal * ( _aDados[5] / 100 )			//Efetua o somatorio do desconto parcial
						_cNumContra	:= _aDados[4]									//Armazena o numero do contrato corrente

						_lContrato	:= .T. //Seta variavel como verdadeira indicando que exite contrato para a nota fiscal e serie correntes, para posterior atualizacao da tabela SF2

					EndIf

				EndIf

			EndIf

			SD2->( DBSkip() )
		EndDo

		//================================================================================
		//| Caso encontre um contrato com desconto armazena os dados na SF2              |
		//================================================================================
		If _lContrato

			RestArea( _aAreaSF2 )

			SF2->( RecLock( "SF2" , .F. ) )

			SF2->F2_I_NRZAZ	:= _cNumContra	// Numero do contrato
			SF2->F2_I_VLRDC	:= _nTotVlDInt	// Valor do desconto integral
			SF2->F2_I_VLPAR	:= _nTotVlDPar	// Valor do desconto parcial
			SF2->F2_I_DCUST	:= _cusast		// Usa ST como base para desconto
			SF2->F2_I_DCUIC	:= _cusaicms	// Usa icms como base para desconto
			SF2->F2_I_DCUPI	:= _cusapis		// Usa pis como base para desconto
			SF2->F2_I_DCUCO	:= _cusacofins	// Usa cofins como base para desconto
			SF2->F2_I_DCIPI := _cusaipi			//usa ipi como base para desconto  - Chamado 46726

			SF2->( MsUnLock() )

		EndIf

	EndIf

	_aContrat := u_vldContrato( _cNumContra )

	//=============================================================================
	//| Valida se possui contrato
	//=============================================================================
	If _aContrat[1]

		//================================================================================
		//| So gera financeiro para o tipo de abatimento integral ou parcial             |
		//================================================================================
		If _nDescFinan > 0

			//================================================================================
			//| Verifica o numero de parcelas geradas na SE1, para que seja possivel dividir |
			//| proporcionalmento o desconto entre as parcelas                               |
			//================================================================================
			_cAliasSE1:= GetNextAlias()
			_cQuery := " SELECT R_E_C_N_O_ REC_SE1 "
			_cQuery += " FROM "+ RetSqlName("SE1")
			_cQuery += " WHERE "
			_cQuery += " 		D_E_L_E_T_ 	= ' ' "
			_cQuery += " AND	E1_FILIAL	= '"+ _cFilSF2	+"' "
			_cQuery += " AND	E1_NUM		= '"+ _cNumDoc	+"' "
			_cQuery += " AND	E1_PREFIXO	= '"+ _cNumPref	+"' "
			_cQuery += " AND	E1_CLIENTE	= '"+ _cNumCli	+"' "
			_cQuery += " AND	E1_LOJA		= '"+ _cNumLoj	+"' "
			_cQuery += " AND	E1_TIPO		= 'NF' "

			MPSysOpenQuery( _cQuery , _cAliasSE1)

			_nParc:=0
			DBSelectArea(_cAliasSE1)
			COUNT TO _nParc

			If _nParc > 0

				_cQuery := " SELECT "
				_cQuery += " 	MAX(E1_PARCELA) AS MAXPAR "
				_cQuery += " FROM "+ RetSqlName("SE1")
				_cQuery += " WHERE "
				_cQuery += " 		D_E_L_E_T_ 	= ' ' "
				_cQuery += " AND	E1_FILIAL	= '"+ _cFilSF2	+"' "
				_cQuery += " AND	E1_NUM		= '"+ _cNumDoc	+"' "
				_cQuery += " AND	E1_PREFIXO	= '"+ _cNumPref	+"' "
				_cQuery += " AND	E1_CLIENTE	= '"+ _cNumCli	+"' "
				_cQuery += " AND	E1_LOJA		= '"+ _cNumLoj	+"' "
				_cQuery += " AND	E1_TIPO		= 'NF' "

				MPSysOpenQuery( _cQuery , _cAlias)

				(_cAlias)->( DBGoTop() )

				//================================================================================
				//| Verifica se existe mais de uma parcela                                       |
				//================================================================================
				If Empty( (_cAlias)->MAXPAR )
					_nNumParc := 1
				Else
					_nNumParc := Val( (_cAlias)->MAXPAR )
				EndIf

				(_cAlias)->( DBCloseArea() )

				_nValorParc	:= Round( ( _nDescFinan / _nNumParc ) , 2 )
				_nVlrParUlt	:= ( _nDescFinan - ( _nValorParc * ( _nNumParc - 1 ) ) )

				//================================================================================
				//| Atualiza os valores nas parcelas dos titulos na SE1                          |
				//================================================================================
				SE1->( DBSetOrder(2) ) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

				(_cAliasSE1)->(DBGOTOP())
				DO While (_cAliasSE1)->(!Eof())

					SE1->(DBGOTO( (_cAliasSE1)->REC_SE1 ))

					//================================================================================
					//| Verifica se � a �ltima parcela                                               |
					//================================================================================
					If !Empty( SE1->E1_PARCELA ) .And. Val( SE1->E1_PARCELA ) < _nNumParc

						SE1->( RecLock( "SE1" , .F. ) )
						SE1->E1_I_DESCO	:= _nValorParc
						SE1->E1_I_NRZAZ	:= _cNumContra
						SE1->( MsUnlock() )

						U_GeraNcc()  //chamada para a fun��o respons�vel por gerar a ncc

					Else

						SE1->( RecLock( "SE1" , .F. ) )
						SE1->E1_I_DESCO	:= _nVlrParUlt
						SE1->E1_I_NRZAZ	:= _cNumContra
						SE1->( MsUnlock() )

						U_GeraNcc()  //chamada para a fun��o respons�vel por gerar a ncc

					EndIf

					(_cAliasSE1)->( DBSkip() )

				EndDo

			Else

				U_ITMSG('Houve uma falha para gerar o desconto contratual. Chave: Filial: '+_cFilSF2+", Cod. Cliente: "+_cNumCli+", Loja Cli: "+_cNumLoj+", Pref: "+_cNumPref+", Doc: "+_cNumDoc+", Tipo: NF","Aten��o",;
					'Verificar com o setor de TI/ERP quanto � esse problema, registre um "Print" desta mensagem para facilitar o atendimento!',3)

			EndIf//If _nParc > 0

		EndIf//_nDescFinan > 0

	EndIf//If _aContrat[1]

	RestArea( _aArea )

Return()

/*
===============================================================================================================================
Programa----------: grvDadosCg
Autor-------------: Fabiano Dias
Data da Criacao---: 30/03/2010
Descri��o---------: Funcao utilizada para armazenar na SF2 dados da carga
Parametros--------: _cMotorDAK - c�digo de motorista da carga
                    _cCaminDAK - c�digo de veiculo da carga
                    _aDadosDAK - array com dados de op logistico e redespacho
                    _cCarg - Se tem carga atralada
                    _cljtr  - Valor para for�ar loja do transportador
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function grvDadosCg( _cMotorDAK , _cCaminDAK,_aDadosDAK, _cCarg, _cljtr )

	Local _cQuery		:= ""
	Local _cAlias		:= GetNextAlias()
	Local _cPlacaTra	:= ""
	Local _cNomeTran	:= ""
	Local _aArea		:= GetArea()
	Local _cNomeTransp	:= "" // Incluida grava��o no campo  F2_I_NTRAN para gravar o nome da transportadora e no campo F2_I_NMOT gravar o nome do motorista. Chamado: 3700
	Local _cVeiculo     := ""
	Local _cMotor		:= ""
	Local _NomeMot		:= ""
	Local _cChep		:= "N"
	Local _cCChep		:= ""
	Default _cCarg		:= "S"
	Default _cMotorDAK	:= ""
	Default _cCaminDAK	:= ""
	Default _aDadosDAK	:= {}
	Default _cljtr     := ""

	If _cCarg == "S"
		_cQuery := " SELECT DA3_PLACA "
		_cQuery += " FROM " + RetSqlName("DA3")
		_cQuery += " WHERE "
		_cQuery += " 		D_E_L_E_T_	= ' ' "
		_cQuery += " AND	DA3_COD		= '"+ _cCaminDAK		+"' "
		If !Empty( xFilial("DA3") )
			_cQuery += " AND	DA3_FILIAL	= '"+ XFILIAL("DA3")	+"' "
		EndIf
		MPSysOpenQuery( _cQuery , _cAlias)
		(_cAlias)->( DBGoTop() )
		If (_cAlias)->(!Eof())
			_cPlacaTra	:= (_cAlias)->DA3_PLACA
			_cVeiculo	:= _cCaminDAK
		EndIf
		(_cAlias)->( DbCloseArea() )
		_cQuery := " SELECT DA4_NOME "
		_cQuery += " FROM " + RetSqlName("DA4")
		_cQuery += " WHERE "
		_cQuery += " 		D_E_L_E_T_	= ' ' "
		_cQuery += " AND	DA4_COD		= '"+ _cMotorDAK		+"' "
		If !Empty( xFilial("DA4") )
			_cQuery += " AND	DA4_FILIAL	= '"+ XFILIAL("DA4")	+"' "
		EndIf
		MPSysOpenQuery( _cQuery , _cAlias)
		(_cAlias)->( DBGoTop() )
		IF (_cAlias)->(!Eof())
			_cNomeTran := (_cAlias)->DA4_NOME
		EndIF
		(_cAlias)->( DBCloseArea() )
		//Incluida grava��o no campo  F2_I_NTRAN para gravar o nome da transportadora e no campo F2_I_NMOT gravar o nome do motorista. Chamado: 3700
		DA4->( DBSetOrder(1) )
		If DA4->( DBSeek( xFilial("DA4") + _cMotorDAK ) )
			SA2->( DBSetOrder(1) )
			//Se tiver alternativa de for�ar loja do transportador e n�o existir na SA2 utiliza o valor do DA4 mesmo
			If !( !empty(_cljtr) .and.  SA2->( DBSeek( xFilial("SA2") + DA4->DA4_FORNEC  + _cljtr  ) ) )
				_cljtr := DA4->DA4_LOJA
			Endif
			If SA2->( DBSeek( xFilial("SA2") + DA4->DA4_FORNEC + _cljtr ) )
				_cNomeTransp	:= SA2->A2_NOME
				_cMotor			:= _cMotorDAK
				_NomeMot		:= DA4->DA4_NOME
			EndIf
		EndIf
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA))
			_cCChep := SA1->A1_I_CCHEP
			If SA1->A1_I_CHEP == "C"
				_cChep := "S"
			EndIf
		EndIf
		SF2->( RecLock( "SF2" , .F. ) )
		SF2->F2_I_PLACA := _cPlacaTra
		SF2->F2_I_NTRAN := _cNomeTransp
		SF2->F2_I_NMOT  := _NomeMot
		SF2->F2_I_VEICU := _cVeiculo
		SF2->F2_I_MOTOR := _cMotor
		SF2->F2_I_CTRA  := DA4->DA4_FORNEC
		SF2->F2_I_LTRA  := _cljtr
		SF2->F2_I_REDP  := _aDadosDAK[1]
		SF2->F2_I_RELO  := _aDadosDAK[2]
		SF2->F2_I_OPER  := _aDadosDAK[3]
		SF2->F2_I_OPLO  := _aDadosDAK[4]
		SF2->F2_I_CLICH := _cChep			//Grava informa��o do cliente no momento da nota se � chep ou n�o
		SF2->F2_I_CCHEP := _cCChep			//Grava o c�digo do CHEP atual do cliente
		SF2->F2_VEICUL1 := _cVeiculo
		SF2->( MsUnLock() )
	Else
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA))
			_cCChep := SA1->A1_I_CCHEP
			If SA1->A1_I_CHEP == "C"
				_cChep := "S"
			EndIf
		EndIf
		SF2->( RecLock( "SF2" , .F. ) )
		SF2->F2_I_CLICH := _cChep		//Grava informa��o do cliente no momento da nota se � chep ou n�o
		SF2->F2_I_CCHEP := _cCChep		//Grava o c�digo do CHEP atual do cliente
		SF2->( MsUnLock() )
	EndIf
	RestArea( _aArea )

Return()

/*
===============================================================================================================================
Programa----------: buscaDA3
Autor-------------: Fabiano Dias
Data da Criacao---: 22/04/2010
Descri��o---------: Busca dados para a tela de Pedidos Avulsos atrav�s do F3
Parametros--------: _cVeiculo,@_cDescVeic,@_cPlaca,@_cMotorista,@_cDescMotor
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function buscaDA3(_cVeiculo,_cDescVeic,_cPlaca,_cMotorista,_cDescMotor)

	DA3->( DBSetOrder(1) )
	If DA3->( DBSeek( xFilial("DA3") + _cVeiculo ) )
		_cDescVeic	:= AllTrim(DA3->DA3_DESC)
		_cPlaca	:= DA3->DA3_PLACA
		If !Empty(DA3->DA3_MOTORI)
			DA4->( DBSetOrder(1) )
			If DA4->( DBSeek( xFilial("DA4") + DA3->DA3_MOTORI ) )
				_cMotorista:= DA4->DA4_COD
				_cDescMotor:= AllTrim(DA4->DA4_NOME)
			EndIf
		EndIf
	EndIf

Return()


/*
===============================================================================================================================
Programa----------: atualizNat
Autor-------------: Fabiano Dias
Data da Criacao---: 20/08/2010
Descri��o---------: Funcao utilizada para armazenar na SE2 o codigo de natureza para as notas de devolu��o
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function atualizNat( _cDocument , _cserie , _cFornec , _cLojaForn )

	Local _aArea	:= GetArea()
	SE2->( DBSetOrder(6) )
	If SE2->( DBSeek( xFilial("SE2") + _cFornec + _cLojaForn + _cserie + _cDocument ) )
		SE2->( RecLock( "SE2" , .F. ) )
		SE2->E2_NATUREZ := "420001"
		SE2->( MsUnlock() )
	EndIf
	RestArea( _aArea )

Return()

/*
===============================================================================================================================
Programa----------: refazFrDAI
Autor-------------: Fabiano Dias
Data da Criacao---: 02/11/2010
Descri��o---------: Fun��o utilizada para refazer o valor do frete na DAI quando houver carga e tiver valor de frete
Parametros--------: _cCodCarga AS String, _nVlrFrete As Numeric, _nPesoDAK As Numeric, _nVlrPedagio AS Numeric
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function refazFrDAI( _cCodCarga AS String, _nVlrFrete As Numeric, _nPesoDAK As Numeric, _nVlrPedagio AS Numeric)

	Local _cQuery		 := "" As String
	Local _cAliasDAI	 := "" As String
	Local _nPesoTot 	 := 0 As Numeric
	Local _nPesoSoPallet:= 0 As Numeric
	Local _aArea        := GetArea() As Array
	Local nMaiorVlr     := 0 AS Numeric
	Local nMaiorRec     := 0 AS Numeric
	Local nVlrSomaPedag := 0 AS Numeric
	Local nVlrSomaFrete := 0 AS Numeric
	Local lTemDAI_I_VRPE:= DAI->(FIELDPOS("DAI_I_VRPE")) > 0 As Logical

	IF _nVlrFrete = 0 .And. _nVlrPedagio = 0
		Return()
	EndIf

	_cAliasDAI:= GetNextAlias()
	_cQuery := " SELECT COALESCE(SUM(DAI_I_FRET),0) VLRFRT "
	IF lTemDAI_I_VRPE
		_cQuery += "  ,  COALESCE(SUM(DAI_I_VRPE),0) VRPEDAGIO "
	Endif
	_cQuery += " FROM "+ RetSqlName("DAI") +" DAI "
	_cQuery += " WHERE "
	_cQuery += " 		D_E_L_E_T_	= ' ' "
	_cQuery += " AND	DAI_FILIAL	= '"+ xFilial("DAI")	+"' "
	_cQuery += " AND	DAI_COD		= '"+ _cCodCarga		+"' "
	MPSysOpenQuery( _cQuery , _cAliasDAI)
	//=============================================================================
	//Houve a exclusao do documento de uma carga com a opcao  retornar  pedido  de
	//venda apto a faturar deste forma a carga eh mantida, mas neste caso as linhas
	//da tabela DAI sao deletadas e recriadas com o valor  do  frete  zerado  para
	//tanto eh feito o novo rateamento desta carga
	//=============================================================================
	If ((_cAliasDAI)->VLRFRT = 0 .And. _nVlrFrete > 0 ) .Or. (lTemDAI_I_VRPE .and. (_cAliasDAI)->VRPEDAGIO = 0 .And. _nVlrPedagio > 0)

		_nPesoTot:= Cal2PesCarg(_cCodCarga,1)//Efetua o somatorio do Peso DA CARGA sem os PALLET
		//=================================================================
		//Somente tinha pedidos com os produtos PALLET na montagem de carga
		//=================================================================
		If _nPesoTot = 0
			_nPesoSoPallet	:=	_nPesoDAK
		EndIf
		//============================================================================
		//Gravacao dao Valor Rateado por item da  Carga  desconsiderando  o  grupo  de
		//Produtos Unitizadores
		//============================================================================
		DAI->( DBSetOrder(1) )//DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN+DAI_PEDIDO
		If DAI->( DBSeek(xFILIAL("DAI") + _cCodCarga ) )
			Do While DAI->(!Eof()) .And. DAI->DAI_COD == _cCodCarga .And. DAI->DAI_FILIAL == xFILIAL("DAI")

				_nPesoPV:=0
				If _nPesoTot > 0
					_nPesoPV:=Cal2PesCarg(DAI->DAI_PEDIDO,2)//Efetua o somatorio do Peso do PEDIDO sem os PALLET
				EndIf
				DAI->( RecLock( "DAI" , .F. ) )
				//============================================================================
				//Caso a carga possua Produtos acabados mais pedidos de PALLET sera rateado  o
				//frete somente por Pedidos que nao sejam de PALLET
				//============================================================================
				If _nVlrFrete > 0
					If _nPesoTot > 0
						If _nPesoPV > 0//Efetua o somatorio do Peso do Pedido
							DAI->DAI_I_FRET := ( ( _nVlrFrete / _nPesoTot) * DAI->DAI_PESO )
						EndIf
						//=========================================================
						//Caso a montagem de carga somene possua pedidos de PALLET
						//=========================================================
					Else
						DAI->DAI_I_FRET	:=	((_nVlrFrete /	_nPesoSoPallet)	*	DAI->DAI_PESO)
					EndIf
					nVlrSomaFrete+=DAI->DAI_I_FRET
				EndIf
				If lTemDAI_I_VRPE .AND. _nVlrPedagio > 0
					If _nPesoTot > 0
						If _nPesoPV > 0//Efetua o somatorio do Peso do Pedido
							DAI->DAI_I_VRPE := ( ( _nVlrPedagio / _nPesoTot) * DAI->DAI_PESO )
						EndIf
						//=========================================================
						//Caso a montagem de carga somene possua pedidos de PALLET
						//=========================================================
					Else
						DAI->DAI_I_VRPE	:=	((_nVlrPedagio /	_nPesoSoPallet)	*	DAI->DAI_PESO)
					EndIf
					nVlrSomaPedag+=DAI->DAI_I_VRPE
				EndIf

				IF DAI->DAI_PESO > nMaiorVlr
					nMaiorVlr:=DAI->DAI_PESO
					nMaiorRec:=DAI->(RecNo())
				ENDIF

				DAI->( MsUnlock() )
				DAI->( DBSkip() )
			EndDo
		EndIf
		//================================================================================
		// Acertos de diferen�as de frete e pedagio
		//================================================================================
		If nMaiorRec > 0  .And. ((_nVlrFrete > 0 .AND. nVlrSomaFrete <> _nVlrFrete) .Or. (_nVlrPedagio > 0 .AND. nVlrSomaPedag <> _nVlrPedagio))
			DAI->( Dbgoto(nMaiorRec))
			DAI->( RecLock( "DAI" , .F. ) )
			If _nVlrFrete > 0 .AND. nVlrSomaFrete <> _nVlrFrete
				DAI->DAI_I_FRET:= DAI->DAI_I_FRET + (_nVlrFrete - nVlrSomaFrete )
			EndIf
			If lTemDAI_I_VRPE .AND. _nVlrPedagio > 0 .AND. nVlrSomaPedag <> _nVlrPedagio
				DAI->DAI_I_VRPE:= DAI->DAI_I_VRPE + (_nVlrPedagio - nVlrSomaPedag )
			EndIf
			DAI->( MsUnlock() )
		EndIf
	EndIf
	(_cAliasDAI)->( DBCloseArea() )
	RestArea( _aArea )

Return()

/*
===============================================================================================================================
Programa----------: GRVICMST
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 10/11/2011
Descri��o---------: Funcao utilizada para gerar titulos no Contas a Receber e a Pagar referente ao ICMS-ST nas vendas para MG
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function GRVICMST()

	Local _aArea	:= GetArea()
	Local _lCalc	:= .F.
	Local _nValTit	:= 0

	//SF2
	Local _cDoc		:= SF2->F2_DOC
	Local _cSerie	:= SF2->F2_SERIE
	Local _cCliente := SF2->F2_CLIENTE
	Local _cLoja	:= SF2->F2_LOJA
	Local _cPedido	:= SF2->F2_I_PEDID
	Local _cVendf2	:= SF2->F2_VEND1

	//SD2
	Local _nBasIcm  := 0
	Local _nAliIcm  := 0
	Local _nValIpi	:= 0 //IPI NA BASE DE ICMS-ST

	//ZZQ
	Local _nMva     := 0
	Local _nGrozac  := 0
	Local _nAlqInt	:= 0
	Local _cAjuMVA	:= '1'

	Local _cHist	:= "ICMS-ST REF NF " +SF2->F2_DOC
	Local _dVencR	:= Stod('')
	Local _cNATSTCP := AllTrim(SuperGetMV("IT_NATSTCP",.F.,""))
	Local _cNATSTCR := AllTrim(SuperGetMV("IT_NATSTCR",.F.,""))
	Local _cFORST 	:= AllTrim(SuperGetMV("IT_STFORN",.F.,""))
	Local _nEstIcm  := Val(Substr(AllTrim(SuperGetMV("MV_ESTICM",.F.,"")),(Rat(SF2->F2_EST,AllTrim(SuperGetMV("MV_ESTICM",.F.,""))) + 2),2)) // Verifica qual eh a Aliquota de ICMS para o estado
	Local _nAliSt   := 0

	Local nModAnt  	:= nModulo
	Local cModAnt  	:= cModulo

	Local _aSE1Inc 	:= {}
	Local _aSE2Inc 	:= {}

	Private lMsErroAuto := 	.F.

	//====================================================================
	//Avalia pr�-requisitos para gera��o dos t�tulos ST -
	//Filial deve estar contida no par�metro IT_STFIL e estado no IT_STEST
	//====================================================================
	If SuperGetMV("IT_STFIL",.F.,.F.) .AND. SF2->F2_EST $ SuperGetMV("IT_STEST",.F.,"")

		SA1->(DBSetOrder(1))//A1_FILIAL+A1_COD+A1_LOJA
		SC5->(DbSetOrder(3))//C5_FILIAL+C5_CLIENTE+C5_LOJACLI+C5_NUM
		SD2->(DbSetOrder(3))//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		SB1->(DBSetOrder(1))
		ZZQ->(DBSetOrder(1))
		SBZ->(DBSetOrder(1))
		//================================================================================
		// Regime especial ST deve estar como "N" e Cliente deve ser Juridico
		//================================================================================
		If SA1->( DBSeek( xfilial("SA1") + _cCliente + _cLoja ) ) .And. SA1->A1_I_STESP == "N" .AND. SA1->A1_PESSOA == "J"

			If SC5->(DbSeek(xfilial("SC5")+_cCliente+_cLoja+_cPedido)) .And. SC5->C5_I_OPER $ SuperGetMV("IT_STTOP",.F.,"")

				If SD2->(DbSeek(xfilial("SD2")+_cDoc+_cSerie+_cCliente+_cLoja))
					While SD2->(!Eof()) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA ) == xFilial("SD2") + _cDoc + _cSerie + _cCliente + _cLoja
						_lCalc := .F.
						If SD2->D2_TP == "PA"

							_nBasIcm:= SD2->D2_BASEICM
							_nAliIcm:= SD2->D2_PICM
							_nValIpi:= SD2->D2_VALIPI // IPI NA BASE ICMS-ST
							_nMva	:= 0
							_nGrozac:= 0
							_cAjuMVA:= '1'

							If SB1->(DBSeek(xFilial("SB1")+SD2->D2_COD))

								//================================================================================
								//Regra espec�fica CLIENTE+LOJA+NCM+Exce��o
								//================================================================================
								If ZZQ->(DBSeek(xFilial("ZZQ")+SD2->(D2_CLIENTE+D2_LOJA)+SB1->B1_POSIPI+SB1->B1_EX_NCM)) .AND. !ALLTRIM(SD2->D2_COD) $ ZZQ->ZZQ_PRODUT

									_nMva	:= ZZQ->ZZQ_MVA
									_nGrozac:= ZZQ->ZZQ_GROZAC
									_nAlqInt:= ZZQ->ZZQ_ALQINT
									_cAjuMVA:= ZZQ->ZZQ_AJUMVA
									_lCalc	:= .T.
									//================================================================================
									//Regra espec�fica CLIENTE+"TODAS AS LOJAS"+NCM+Exce��o
									//================================================================================
								ElseIf ZZQ->(DBSeek(xFilial("ZZQ")+SD2->D2_CLIENTE+Space(4)+SB1->B1_POSIPI+SB1->B1_EX_NCM)) .AND. !ALLTRIM(SD2->D2_COD) $ ZZQ->ZZQ_PRODUT

									_nMva	:= ZZQ->ZZQ_MVA
									_nGrozac:= ZZQ->ZZQ_GROZAC
									_nAlqInt:= ZZQ->ZZQ_ALQINT
									_cAjuMVA:= ZZQ->ZZQ_AJUMVA
									_lCalc	:= .T.
									//================================================================================
									//Regra Geral
									//================================================================================
								ElseIf ZZQ->(DBSeek(xFilial("ZZQ")+Space(6)+Space(4)+SB1->B1_POSIPI+SB1->B1_EX_NCM)) .AND. !ALLTRIM(SD2->D2_COD) $ ZZQ->ZZQ_PRODUT

									_nMva		:= ZZQ->ZZQ_MVA
									_nGrozac	:= ZZQ->ZZQ_GROZAC
									_nAlqInt	:= ZZQ->ZZQ_ALQINT
									_cAjuMVA	:= ZZQ->ZZQ_AJUMVA
									_lCalc		:= .T.
								EndIf

								_nAliSt := _nEstIcm

								If SBZ->(DBSeek(xFilial("SBZ")+SB1->B1_COD)) .And. SBZ->BZ_I_STEXC > 0
									_nAliSt := SBZ->BZ_I_STEXC
								EndIf

								If _lCalc

									//==========================================================================================================================
									//| F�rmula para c�lculo:                                                                                                  |
									//| (((Base ICMS * MVA sem ajustes para Leites ou MVA ajustado para demais produtos)* Al�quota interna de MG, que � 18% ou |
									//| a exce��o que for informada no indicador do produto)-(Base ICMS*Grosa)                                                 |
									//| Para o MVA que precisa ser ajustado, segue a f�rmula:                                                                  |
									//| (((1+(MVA Original/100))*(1-(Al�quota Interestadual/100)))/(1-(Al�quota interna de MG/100))))                          |
									//==========================================================================================================================
                                 /*
                                 _nValTit += IIf(_cAjuMVA=='1',;
                                 ((_nBasIcm*(((1+(_nMva/100))*(1-(_nAliIcm/100)))/(1-(_nAliST/100))))*(_nAliST/100)),;//C�lculo com MVA Ajustado
                                 (_nBasIcm*((1+(_nMva/100)))*(_nAliST/100)));//C�lculo sem o MVA ajustado
                                 -(_nBasIcm*(IIf(!Empty( _nAlqInt ) .And. _nAlqInt > 0,_nAlqInt,_nGrozac)/100))*/
                                 _nValTit += IIf(_cAjuMVA=='1',;
                                             (((_nBasIcm+_nValIpi)*(((1+(_nMva/100))*(1-(_nAliIcm/100)))/(1-(_nAliST/100))))*(_nAliST/100)),;//C�lculo com MVA Ajustado
                                             ((_nBasIcm+_nValIpi)*((1+(_nMva/100)))*(_nAliST/100)));//C�lculo sem o MVA ajustado
                                             -((_nBasIcm)*(IIf(!Empty( _nAlqInt ) .And. _nAlqInt > 0,_nAlqInt,_nGrozac)/100))
                                 //IPI NA BASE DE ICMS-ST
                             EndIf
                         EndIf
                     EndIf
                     SD2->(DBSkip())
                 Enddo
             EndIf
         EndIf
     EndIf

 EndIf

 //=======================================================================
 //Se houver valor de ICMS-ST, gera os titulos no Contas a Pagar e Receber
 //=======================================================================
 If _nValTit > 0

     //==============================================
     //Insere T�tulo a Pagar em nome da Sefaz de MG.
     //==============================================
     SE2->(DBSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
     If !SE2->(DBSeek(xFilial("SE2")+_cSerie+_cDoc+Space(GetSX3Cache("E2_PARCELA","X3_TAMANHO"))+"ICM"+_cCliente+_cLoja))

         lMsErroAuto := .f.

         _aSE2Inc  := {	{ "E2_PREFIXO"	, _cSerie				, Nil } ,;
                         { "E2_NUM"		, _cDoc					, Nil } ,;
                         { "E2_TIPO"		, "ICM"					, Nil } ,;
                         { "E2_NATUREZ"	, _cNATSTCP				, Nil } ,;
                         { "E2_FORNECE"	, SUBSTR(_cFORST,1,6)	, Nil } ,;
                         { "E2_LOJA"		, SUBSTR(_cFORST,7,4)	, Nil } ,;
                         { "E2_EMISSAO"	, dDataBase				, Nil } ,;
                         { "E2_VENCTO"	, dDataBase				, Nil } ,;
                         { "E2_VENCREA"	, DataValida(dDataBase)	, Nil } ,;
                         { "E2_VALOR"	, _nValTit				, Nil } ,;
                         { "E2_HIST"		, _cHist				, Nil } ,;
                         { "E2_ORIGEM"	, "GRVICMST"			, Nil }  }

         //===============================================================
         //Altera o modulo para Financeiro, senao o SigaAuto nao executa.
         //===============================================================
         nModulo	:= 6
         cModulo	:= "FIN"

         DBSelectArea("SE2")

         MSExecAuto( {|x,y,z| Fina050( x , y , z ) } , _aSE2Inc ,, 3 )

         If lMsErroAuto
             Mostraerro()
         EndIf

         //=========================================================================
         //Restaura o modulo em uso.
         //=========================================================================
         nModulo := nModAnt
         cModulo := cModAnt

     Else
         MsgAlert("N�o foram gerados os t�tulos de ICMS-ST no Financeiro! Favor verificar com o setor de TI/ERP,dados do T�tulo: Prefixo["+_cSerie+"], Tipo[ICM], N�mero["+_cDoc+"]","M460FIM001")
     EndIf

     //================================================================================
     //Insere T�tulo a Receber em nome do Cliente
     //================================================================================
     SE1->(DBSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
     If !SE1->(DBSeek(xFilial("SE1")+_cSerie+_cDoc+Space(GetSX3Cache("E1_PARCELA","X3_TAMANHO"))+"ICM"))
         If DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+_cDoc)
             _dVencR	:= dtvenc(_ccliente, _cloja, SE1->E1_VENCTO)
         Else
             alDt	:= Condicao( _nValTit , SF2->F2_COND , 0 , dDataBase , 0 )
             _dVencR	:= dtvenc(_ccliente, _cloja, alDt[1][1] )
         EndIf

         _aSE1Inc	:= {{ "E1_PREFIXO"	, _cSerie					, Nil },;
                         { "E1_NUM"		, _cDoc						, Nil },;
                         { "E1_PARCELA"	, Space(GetSX3Cache("E1_PARCELA","X3_TAMANHO")), Nil },;
                         { "E1_TIPO"	, "ICM"						, Nil },;
                         { "E1_NATUREZ"	, _cNATSTCR					, Nil },;
                         { "E1_CLIENTE"	, _cCliente					, Nil },;
                         { "E1_LOJA"	, _cLoja					, Nil },;
                         { "E1_EMISSAO"	, dDataBase					, Nil },;
                         { "E1_VENCTO"	, _dVencR					, Nil },;
                         { "E1_VENCREA"	, _dVencR 					, Nil },;
                         { "E1_I_VCPOR"	, DataValida(_dVencR)		, Nil },;
                         { "E1_VALOR"	, _nValTit					, Nil },;
                         { "E1_HIST"	, _cHist					, Nil },;
                         { "E1_VEND1"	, _cVendf2					, Nil },;
                         { "E1_ORIGEM"	, "GRVICMST"				, Nil } }

         lMsErroAuto	:= .F.

         //================================================================================
         //Altera o modulo para Financeiro, senao o SigaAuto nao executa
         //================================================================================
         nModulo := 6
         cModulo := "FIN"

         DbSelectArea("SE1")
         MSExecAuto( {|x,y,z| Fina040( x , y , z ) } , _aSE1Inc,3 )

         If lMsErroAuto
             Mostraerro()
         EndIf

         //=========================
         //Restaura o modulo em uso.
         //=========================
         nModulo	:= nModAnt
         cModulo	:= cModAnt
     Else
         MsgAlert("N�o foram gerados os t�tulos de ICMS-ST no Financeiro! Favor verificar com o setor de TI/ERP, dados do T�tulo: Prefixo["+_cSerie+"], Tipo[ICM], N�mero["+_cDoc+"]")
     EndIf

 EndIf

 RestArea( _aArea )

Return()

/*
===============================================================================================================================
Programa----------: GeraNcc
Autor-------------: Talita Teixeira
Data da Criacao---: 05/02/2013
Descri��o---------: Fun��o respons�vel por gerar ncc referentes ao descontos
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function GeraNcc()

	Local _cNaturez:= GetMv("IT_NATDCT",,"")
	Local _nValor	:= SE1->E1_I_DESCO
	Local _cNome 	:= SE1->E1_NOMCLI
	Local _cPrefixo:= SE1->E1_PREFIXO
	Local _cNumer	:= SE1->E1_NUM
	Local _cParcel	:= SE1->E1_PARCELA
	Local _dVencRea:= SE1->E1_VENCREA

	PRIVATE lMsErroAuto := .F.

	SF2->( DBSetOrder(1) )
	If SF2->( DbSeek( xFilial("SF2") + SE1->( E1_NUM + E1_PREFIXO ) ) )

		_dVencRea := dtvenc(SF2->F2_CLIENTE, SF2->F2_LOJA, SE1->E1_VENCTO)

		aArray   := {{ "E1_PREFIXO"   , "DCT"                     , NIL },;
			{ "E1_NUM"       , SE1->E1_NUM               , NIL },;
			{ "E1_PARCELA"   , SE1->E1_PARCELA           , NIL },;
			{ "E1_TIPO"      , "NCC"                     , NIL },;
			{ "E1_NATUREZ"   , _cNaturez                 , NIL },;
			{ "E1_CLIENTE"   , SF2->F2_CLIENTE           , NIL },;
			{ "E1_LOJA"      , SF2->F2_LOJA              , NIL },;
			{ "E1_NOMCLI"    , _cNome                    , NIL },;
			{ "E1_EMISSAO"   , dDataBase                 , NIL },;
			{ "E1_VENCTO"    , SE1->E1_VENCTO            , NIL },;
			{ "E1_VENCREA"   , _dVencRea                 , NIL },;
			{ "E1_I_VCPOR"   , datavalida(SE1->E1_VENCTO), Nil },;
			{ "E1_VALOR"     , _nValor                   , NIL } }

		MsExecAuto( {|x,y| FINA040( x , y ) } , aArray , 3 )  // 3 - Inclusao, 4 - Altera��o, 5 - Exclus�o

		If lMsErroAuto
			MostraErro()
		EndIf

		SE1->( DBSetOrder(1) )
		SE1->( DBSeek( xFilial("SE1") + _cPrefixo + _cNumer + _cParcel ) )

	EndIf

Return()

/*
===============================================================================================================================
Programa----------: VLDTRANSP
Autor-------------: Erich Buttner
Data da Criacao---: 21/02/2013
Descri��o---------: Cria��o de Aba de Transpote quando o Formulario Proprio igual a "SIM"
Parametros--------: _nMenRemessa
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function TRANSPVLD(_nMenRemessa,_nMenFat)

	Private aAbas := {}
	If Empty( SF2->F2_CARGA )
		aAbas := { 'Mensg. Cliente' , 'Mensg. Fisco' , 'Transportes' }
	Else
		aAbas := { 'Mensg. Cliente' , 'Mensg. Fisco' }
	EndIf
	IF !EMPTY(_nMenRemessa) .OR. !EMPTY(_nMenFat)//***********   TRATAMENTO DA OPERCAO TRIANGULAR
		AADD(aAbas,"Mens. Remessa")
		AADD(aAbas,"Mens. Fatur.")
	ENDIF

Return( aAbas )

/*
===============================================================================================================================
Programa----------: ESPMSGNF
Autor-------------: Alexandre Villar
Data da Criacao---: 21/02/2014
Descri��o---------: Ajuste da Mensagem para quebra de linha com ";" e respeitando o limite de espaco da DANFE
Parametros--------: cMsgAux	:= Mensagem a ser configurada.
Retorno-----------: cRet	:= Mensagem formatada.
===============================================================================================================================
*/

Static Function ESPMSGNF( cMsgAux )
	Local cRet		:= ""
	Local cMsgTmp	:= ""
	Local cCharSep	:= " /\|-=.;[]()'"+'"'
	Local nI		:= 0
	Local nX		:= 0
	Local nVolta	:= 0
	Local nPosIni	:= 1
	Local nAux		:= 0
	Default cMsgAux	:= ""
	For nX := 1 To Len(cMsgAux)
		nI++
		If ( nX == Len(cMsgAux) ) .Or. ( SubStr(cMsgAux,nX,1) == ";" )
			If !Empty( SubStr( cMsgAux , nPosIni ) )
				If ( SubStr(cMsgAux,nX,1) $ cCharSep ) .Or. ( SubStr(cMsgAux,nX+1,1) $ cCharSep ) .Or. nX == Len(cMsgAux)
					nAux	:= IIf( nPosIni > 1 , nPosIni , 0 )
					cMsgTmp := AllTrim( SubStr( cMsgAux , nPosIni , nX - nAux ) )
					If SubStr(cMsgTmp,Len(cMsgTmp),1) == ";"
						cMsgTmp := SubStr(cMsgTmp,1,Len(cMsgTmp)-1)
					EndIf
				Else
					nVolta	:= 0
					While !( SubStr( cMsgAux , nX-nVolta , 1 ) $ cCharSep )
						nVolta++
					EndDo
					cMsgTmp	:= AllTrim( SubStr( cMsgAux , nPosIni , Len(cMsgAux) - nVolta ) )
					nX		-= nVolta
				EndIf
				//===========================================================================
				//| Tratativa para n�o dar estouro de linha - Chamado 5893                  |
				//===========================================================================
				cRet	+= FwNoAccent(cMsgTmp) +";"+ CRLF
				cMsgTmp	:= ""
			EndIf
			nPosIni	:= nX+1
			nI		:= 0
		EndIf
	Next nX

Return( cRet )


/*
===============================================================================================================================
Programa----------: dtvenc
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 25/02/2016
Descri��o---------: Funcao para retornar data real de vencimento
Parametros--------: _ccliente - Cliente do t�tulo
                        _cloja - Loja do t�tulo
                        _dvenc - vencimento original do t�tulo
Retorno-----------: data de vencimento real
Setor-------------: Log�stica
===============================================================================================================================
*/

Static function dtvenc(_ccliente, _cloja, _dvenc)

	SA1->( DBSetOrder(1) )
	If SA1->( DBSeek( xFilial("SA1") + _ccliente + _cloja ) ) .and. !empty(alltrim(SA1->A1_GRPVEN))
		ACY->( DbSetOrder(1) )
		If ACY->( DbSeek( xFilial("ACY") + SA1->A1_GRPVEN) )
			IF alltrim(ACY->ACY_I_DTFC) != "0"
				_dvenc :=  DataValida( Datavalida(_dvenc) + 1 , .T. )
			Else
				_dvenc := 	DataValida( _dvenc , .T. )
			Endif
		Endif
	Endif

Return _dVenc


/*
===============================================================================================================================
Programa----------: PosicSC5
Autor-------------: Julio de Paula Paz
Data da Criacao---: 11/04/2018
Descri��o---------: Posicionar o registro da tabela SC5 no registro correto, de acordo com os campos: F2_DOC,F2_SERIE
                    F2_FILIAL.
Parametros--------: _cNrNota = Numero da nota fiscal
                    _cSerie  = Serie da nota
                    _cCodFil = Codigo da filial
Retorno-----------: _nRet = Retorna o numero do recno da tabela SC5.
===============================================================================================================================
*/
Static function PosicSC5(_cNrNota,_cSerie,_cCodFil)
	Local _nRet := 0
	Local _aOrd := SaveOrd({"SC5"})
	Local _nRegAtu := SC5->(Recno())
	Begin Sequence
		SC5->(DbOrderNickName("IT_NOTA")) // C5_FILIAL+C5_NOTA+C5_LIBEROK+C5_BLQ+C5_I_BLPRC+C5_I_BLOQ // L = ordem 21C5_PBRUTO
		SC5->(DbSeek(U_ITKEY(_cCodFil,"C5_FILIAL")+U_ITKEY(_cNrNota,"C5_NOTA")))
		Do While ! SC5->(Eof()) .And. SC5->(C5_FILIAL+SC5->C5_NOTA) == U_ITKEY(_cCodFil,"C5_FILIAL")+U_ITKEY(_cNrNota,"C5_NOTA")
			If SC5->C5_SERIE == U_ITKEY(_cSerie,"C5_SERIE")
				_nRet := SC5->(Recno())
			EndIf
			SC5->(DbSkip())
		EndDo
	End Sequence
	RestOrd(_aOrd)
	SC5->(DbGoTo(_nRegAtu))

Return _nRet

/*
===============================================================================================================================
Programa----------: GravaPeso
Autor-------------: Alex Wallauer
Data da Criacao---: 15/10/2018
Descri��o---------: Processa a grava��o dos pesos do itens da NF F2_PBRUTO / D2_I_PTBRU
Parametros--------: lAcerta As Logical , _nGravados As Numeric
Retorno-----------: .T.
===============================================================================================================================
*/
Static Function GravaPeso(lAcertaPeso As Logical , _nGravados As Numeric) As Logical
	Local _nPesoTot := 0 As Numeric
	DEFAULT _nGravados:=0//Parametro passado com @_nGravados
	_lTemArmazem52:=.F.//PRIVATE ANTES DA FUN��O
	SD2->( DBSetOrder(3) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	If SD2->( DBSeek( SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
		SC6->( Dbsetorder(1))//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		_nValor:=0
		DO While SD2->(!Eof()) .and. SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA ) == SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA
			IF SD2->D2_Local = "52"
				_lTemArmazem52:=.T.
			ENDIF
			IF !EMPTY(SD2->D2_QUANT) 
				//==================================================================================
				// SEMPRE PEGA O PESO BRUTO DO CAMPO C6_I_PTBRU DO PEDIDO PQ ENTRE A CARGA E A GERA��O DA NF PODE TER HAVIDO ALTERACAO NO SB1 E CARGA DO PESO BRUTO
				//==================================================================================
				_nPesoItem:=0
				IF SC6->(DBSEEK(SD2->D2_FILIAL+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD)) .AND. SC6->C6_I_PTBRU > 0//EXCETO SE O CAMPO C6_I_PTBRU DO PEDIDO FOR ZERO
				   _nPesoItem := SC6->C6_I_PTBRU
				ElseIf SB1->(DBSeek(xFilial("SB1")+SD2->D2_COD))
				   _nPesoItem := SB1->B1_PESBRU * SD2->D2_QUANT//Peso do Item
				EndIf
				IF _nPesoItem > 0 .AND. SD2->( RecLock( "SD2",.F.,,.T.))
					SD2->D2_I_PTBRU := _nPesoItem
					SD2->( MsUnlock() )
					_nGravados++
				ENDIF
			ENDIF
			_nPesoTot+=SD2->D2_I_PTBRU
			SD2->( DBSkip() )
		EndDo
	EndIf
	IF lAcertaPeso//Peso Total
		SF2->(Reclock("SF2",.F.))
		SF2->F2_PBRUTO := _nPesoTot//Acerta o peso agora sempre, para usar nos rateios de peso bruto por itens de nota fiscal.
		SF2->(Msunlock())
	Endif
Return .T.

/*
===============================================================================================================================
Programa----------: CPBT_SF2()
Autor-------------: Alex Wallauer
Data da Criacao---: 15/10/2018
Descri��o---------: Carga Peso Bruto Total _ SF2
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER Function CPBT_SF2()
	Local cTimeInicial:=TIME()
	Local _cPerg:="FILTRA_NF"

	IF !PERGUNTE(_cPerg , .T. )
		RETURN .F.
	ENDIF

	PRIVATE _nGravados:=0

	FWMSGRUN( ,{|oProc|  CPBT_SF2(oProc,cTimeInicial) }  , "SD2 - Hora Inicial: "+cTimeInicial , "Aguarde...",  )

Return .T.

/*
===============================================================================================================================
Programa----------: CPBT_SF2()
Autor-------------: Alex Wallauer
Data da Criacao---: 15/10/2018
Descri��o---------: Carga Peso Bruto Total _ SF2
Parametros--------: oProc,cTimeInicial
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function CPBT_SF2(oProc,cTimeInicial)
	Local nConta :=0
	Local xTotal :=0
	Local nTam   :=0
	Local _cAlias:= GetNextAlias()
	Local cQuery := " SELECT SF2.R_E_C_N_O_ RECSF FROM "+ RetSqlName("SF2")+" SF2 WHERE "
	oProc:cCaption :=  "Filtrando SF2, Aguarde..."
	ProcessMessages()
	cQuery += " SF2.D_E_L_E_T_	= ' ' "
	IF !EMPTY(MV_PAR01)
		cQuery += " AND	SF2.F2_FILIAL IN "+ FormatIn(MV_PAR01,";")
	ENDIF
	IF !EMPTY(MV_PAR03)
		cQuery += " AND SF2.F2_EMISSAO BETWEEN '"+ DTOS(MV_PAR02) +"' AND '"+ DTOS(MV_PAR03) +"' "
	ELSEIF !EMPTY(MV_PAR02)
		cQuery += " AND SF2.F2_EMISSAO = '"+ DTOS(MV_PAR02)+"' "
	ENDIF
	IF !EMPTY(MV_PAR04)
		cQuery += " AND	SF2.F2_TIPO IN "+ FormatIn(MV_PAR04,";")
	ENDIF
	MPSysOpenQuery( cQuery , _cAlias)
	DBSelectArea(_cAlias)
	COUNT TO  xTotal
	(_cAlias)->( DBGOTOP() )
	IF xTotal > 30000
		xTotal:=ALLTRIM(STR(xTotal))
		IF !U_ITMSG("Ser�o processado "+xTotal+" registros, CONFIRMA?","Aten��o",,3,2,2)
			RETURN .F.
		ENDIF
		cTimeInicial:=TIME()
	ELSE
		xTotal:=ALLTRIM(STR(xTotal))
	ENDIF
	(_cAlias)->( DBGOTOP() )
	nTam:=LEN(xTotal)+1
	DO While (_cAlias)->(!Eof())
		nConta++
		SF2->(DBGOTO( (_cAlias)->RECSF ) )
		oProc:cCaption :=  "Lendo "+STR(nConta,nTam)+" de "+xTotal +" Lendo NF: "+SF2->F2_FILIAL+" "+SF2->F2_DOC+" PB Gravados: "+ALLTRIM(STR(_nGravados))
		ProcessMessages()
		GravaPeso(.T.,@_nGravados)
		(_cAlias)->( DBSkip() )
	EndDo
	_nGravados:=ALLTRIM(STR(_nGravados))
	U_ITMSG("Carga (SD2) do Peso Bruto completada com sucesso "+_nGravados+" registros gravados.","Aten��o","Hora inicio "+cTimeInicial+" - Hora fim "+TIME()+" Parametros: ["+ALLTRIM(MV_PAR01)+"] ["+DTOC(MV_PAR02)+"] ["+DTOC(MV_PAR03)+"] ["+ALLTRIM(MV_PAR04)+"]",2)

Return .T.

/*
===============================================================================================================================
Programa----------: VAL_CMP()
Autor-------------: Alex Wallauer
Data da Criacao---: 17/03/2022
Descri��o---------: Obriga a informar os dados do Ve�culo/Motorista/Placa
Parametros--------: _cVeiculo,_cPlaca,_cMotorista
Retorno-----------: .T. ou .F.
===============================================================================================================================
*/
STATIC Function VAL_CMP(_cVeiculo,_cPlaca,_cMotorista)
	Local _cMen:=""
	IF EMPTY(_cVeiculo)
		_cMen+="[ Veiculo ] "
	ENDIF
	IF EMPTY(_cPlaca)
		_cMen+="[ Placa ] "
	ENDIF
	IF EMPTY(_cMotorista)
		_cMen+="[ Motorista ] "
	ENDIF
	IF !EMPTY(_cMen)
		U_ITMSG("O(s) Campo(s) "+_cMen+"deve(m) ser preenchido(s).","Aten��o"," Preencha o(s) campo(s) "+_cMen+" para continuar.",1)
		RETURN .F.
	ENDIF
Return .T.

/*
===============================================================================================================================
Programa----------: GrvTransiTime #GrvTransiTime()
Autor-------------: Alex Wallauer
Data da Criacao---: 10/05/2023
Descri��o---------: Grava campos referentes ao Transit time
Parametros--------: _lGrava , _nPesoTotC: peso total da carga sem pallets ou do pedido 
Retorno-----------: .T.
===============================================================================================================================
*/
Static Function GrvTransiTime(_lGrava)
	Local cCodOL      := ""
	Local cLojaOP     := ""
	Local cCodCli     := ""
	Local cLojaCli    := ""
	Local _cFilCarreg := ""
	Local _cEstado    := ""
	Local _dDataMRef  := CTOD("")
	Local _dDtPENCO   := CTOD("")
	Local _dDataPENOL := CTOD("")
	Local lBuscaItalacCliente:=.F.// DESTINO DA ITALAC PARA O CLIENTE
	Local _cOperTriangular:= ALLTRIM(U_ITGETMV( "IT_OPERTRI","05,42"))// Tipos de opera��es da opera��o trigular
	Local _cOperRemessa := RIGHT(_cOperTriangular,2)//42
	Local _cOperFat  := LEFT(_cOperTriangular,2)//05
	Local _lTriangu  := .F.
	Local _nRegSF2   := SF2->(RECNO()) //GUARDA POSI��O ORIGINAL DA SF2
	Local _nRegSC5   := 0
	Local _cPedAux   := ""
	Local _cPedOri   := SF2->F2_I_PEDID
	Local _dDtRPENOL := CTOD("")
	Local _dDtRPENCO := CTOD("")
	Local _dDtRPENCL := CTOD("")
	Local _cRedp     := SF2->F2_I_REDP
	Local _cRelo     := SF2->F2_I_RELO
	Local _cOper     := SF2->F2_I_OPER
	Local _cOplo     := SF2->F2_I_OPLO

	SF2->(DBSetOrder(1))
	SC5->(DBSetOrder(1))
	SC5->(DbSeek(xfilial("SC5")+SF2->F2_I_PEDID))
	_nRegSC5:= SC5->(RECNO()) //GUARDA POSI��O ORIGINAL DA SC5

	IF SC5->C5_I_OPER = _cOperFat//05 FATURAMENTO
		_cPedAux:=SC5->C5_FILIAL+" "+SC5->C5_I_PVREM
		If SC5->(Dbseek(SC5->C5_FILIAL+SC5->C5_I_PVREM))//  ************* POSICIONA NO PV DE REMESSA
			IF SF2->(Dbseek(SC5->C5_FILIAL+SC5->C5_NOTA+SC5->C5_SERIE))//  ************* POSICIONA NA NOTA NO PV DE REMESSA
				_cPedAux+=" / "+SF2->F2_DOC+ " "+SF2->F2_SERIE
				_lTriangu:=.T.
				_dDtRPENOL := SF2->F2_I_PENOL// Previs�o de entrega no operador log�stico
				_dDtRPENCO := SF2->F2_I_PENCO// Previs�o de entrega no cliente (original)
				_dDtRPENCL := SF2->F2_I_PENCL// Previs�o de entrega no cliente
				_nDiasZG5  := SF2->F2_I_TT1TR// Transit Time 1o Trecho
				_nDiasZ31  := SF2->F2_I_TT2TR// Transit Time 2o Trecho
				_cRedp     := SF2->F2_I_REDP
				_cRelo     := SF2->F2_I_RELO
				_cOper     := SF2->F2_I_OPER
				_cOplo     := SF2->F2_I_OPLO

				IF _lGrava
					SF2->(Dbgoto(_nRegSF2))// VOLTA PARA A NOTA DO 05 FATURAMENTO
					SF2->(Reclock("SF2",.F.))
					SF2->F2_I_PENOL := _dDtRPENOL // Previs�o de entrega no operador log�stico
					SF2->F2_I_PENCO := _dDtRPENCO // Previs�o de entrega no cliente (original)
					SF2->F2_I_PENCL := _dDtRPENCL // Previs�o de entrega no cliente
					SF2->F2_I_TT1TR := _nDiasZG5  // Transit Time 1o Trecho
					SF2->F2_I_TT2TR := _nDiasZ31  // Transit Time 2o Trecho
					SF2->F2_I_REDP  := _cRedp
					SF2->F2_I_RELO  := _cRelo
					SF2->F2_I_OPER  := _cOper
					SF2->F2_I_OPLO  := _cOplo
					SF2->(Msunlock())
					// ******************************************** RETORNA AQUI **********************************************************************
					RETURN .T.
					// ******************************************** RETORNA AQUI **********************************************************************
				EndIf
			EndIf
		EndIf
	ELSEIF SC5->C5_I_OPER = _cOperRemessa //42
		_cPedAux:=SC5->C5_FILIAL+" "+SC5->C5_I_PVFAT
	EndIf

	cCodCli    := SF2->F2_CLIENTE
	cLojaCli   := SF2->F2_LOJA
	_cFilCarreg:= SC5->C5_FILIAL

	IF SC5->C5_I_TRCNF == "S"
		If !Empty(SC5->C5_I_FLFNC) //SE PEDIDO DE FATURAMENTO
			_cFilCarreg := SC5->C5_I_FLFNC
			_cPedAux:=SC5->C5_I_FLFNC+" "+SC5->C5_I_PDPR
		EndIf

		If SC5->C5_I_FLFNC == SC5->C5_FILIAL //SE PEDIDO DE CARREGAMENTO
			_cPedAux:=SC5->C5_I_FILFT+" "+SC5->C5_I_PDFT
			IF  SC5->(DBSeek(SC5->C5_I_FILFT+SC5->C5_I_PDFT))// SEEK no PEDIDO de FATURAMENTO
				cCodCli := SC5->C5_CLIENTE
				cLojaCli:= SC5->C5_LOJACLI
			EndIf
		EndIf
	EndIf

	SA1->(DBSetOrder(1))
	SA1->(Dbseek(xFilial("SA1") + cCodCli + cLojaCli))
	_cEstado    := SA1->A1_EST
	_cCodMunic  := SA1->A1_COD_MUN
	_dDataMRef  := _dDiasCorridos := _dDtEmissao := SF2->F2_EMISSAO
	_nDiasZ31   := 0//TRECHO 1
	_nDiasZG5   := 0//TRECHO 2
	_cRegraZ31  := "N�o Chamou"
	_cRegraZG5  := "N�o Chamou"
	lBuscaItalacCliente:=.F.// DESTINO DA ITALAC PARA O CLIENTE

	IF !_lGrava//Para quando chama da Simulacao de Testes
		PRIVATE _cMeso31Reg :=""
		PRIVATE _cMicro31Reg:=""
		PRIVATE _cMesoG5Reg :=""
		PRIVATE _cMicroG5Reg:=""
		PRIVATE _nDiasZG5   :=0
		PRIVATE _cEstadoOP  :=""
		PRIVATE _cCodMunOP  :=""
	EndIf

	DAI->(Dbsetorder(3))
	If EmptY(SF2->F2_I_OPER) .OR. !Empty(SF2->F2_I_REDP)//DAI->(Dbseek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE))//SE TEM CARGA

		IF !EMPTY(SF2->F2_I_OPER)
			cCodOL :=SF2->F2_I_OPER//DAI->DAI_I_OPLO
			cLojaOP:=SF2->F2_I_OPLO//DAI->DAI_I_LOPL
		ELSE
			cCodOL :=SF2->F2_I_REDP//DAI->DAI_I_TRED
			cLojaOP:=SF2->F2_I_RELO//DAI->DAI_I_LTRE
		EndIf

		If !Empty(cCodOL)
			//***********************************************************************************
			//SE ALTERAR A LOGICA AQUI ALTERAR Na #CalcTransiTime() do AOMS003 TAMBEM
			//***********************************************************************************

			//************************* DESTINO: DA ITALAC PARA OPERADOR LOGISTICO *************************
			SA2->(DBSetOrder(1))
			SA2->(Dbseek(xFilial("SA2") + cCodOL + cLojaOP))
			_cEstadoOP := SA2->A2_EST
			_cCodMunOP := SA2->A2_COD_MUN
			//_cFilCarreg,_cCod ,_cLoja ,_cOperPedV    ,_cTipoVenda    ,_cEstado  ,_cCodMunic,@_dDataRef ,_nDiasZG5 ,_cLocalEmb
			U_BuscaZG5(_cFilCarreg,cCodOL,cLojaOP,SC5->C5_I_OPER,SC5->C5_I_TPVEN,_cEstadoOP,_cCodMunOP,@_dDataMRef,@_nDiasZG5,SF2->F2_I_LOCEM)// DESTINO: DA ITALAC PARA OPERADOR LOGISTICO
			IF EMPTY(_dDataMRef)
				_dDataMRef:=DATE()
			EndIf
			_dDataPENOL:= U_IT_DTVALIDA(_dDataMRef,,.T.)//Se a data calculada da entrega cair em um domingo ou em um feriado nacional, a data deve ser o pr�ximo dia �til.

			//************************* DESTINO: OPERADOR LOGISTICO PARA O CLIETE *************************
			_dDtPENCO  := _dDataMRef := _dDataPENOL
			//cCodOL,cLojaOP,cCodCli,cLojaCli,_dDataRef//A data n�o via como referencia (@) pq vai ser calculada depois
			U_BuscaZ31(cCodOL,cLojaOP,cCodCli,cLojaCli,_dDataMRef,@_nDiasZ31)//DESTINO: DO OPERADOR LOGISTICO PARA O CLIENTE
			_dDiasCorridos:=_dDataMRef+_nDiasZ31//#DIAS CORRIDOS
			_dDtPENCO:= U_IT_DTVALIDA(_dDataMRef,_nDiasZ31)//Data calculada da entrega deve contar s� dia util: n�o conta sabado, domingo e feriado nacional
		Else// SE NAO TEM OPERADOR LOGISTICO
			lBuscaItalacCliente:=.T.// DESTINO DA ITALAC PARA O CLIENTE
		EndIf

	Else//SE NAO TEM operarador log�stico
		lBuscaItalacCliente:=.T.// DESTINO DA ITALAC PARA O CLIENTE
	EndIf

	//***********************************************************************************
	//SE ALTERAR A LOGICA AQUI ALTERAR Na #CalcTransiTime() do AOMS003 TAMBEM
	//***********************************************************************************
	//************************* DESTINO DA ITALAC PARA O CLIENTE *************************
	SC5->(Dbgoto(_nRegSC5))
	SF2->(Dbgoto(_nRegSF2))

	_nPesoTot:= SF2->F2_PBRUTO//FORA DO if PQ PRECISO dessa variavel fora do IF tambem

	IF lBuscaItalacCliente

		IF !EMPTY(SC5->C5_I_AGRUP)
			_cQuery:=" SELECT SUM(C5_I_PESBR) C5_I_PESBR FROM "+ RETSQLNAME("SC5") + " WHERE C5_FILIAL = '"+ xFilial('SC5')+"' AND D_E_L_E_T_ = ' ' "
			_cQuery+=" AND C5_I_AGRUP = '"+SC5->C5_I_AGRUP+"' "
			_cAliasGru:= GetNextAlias()
			MPSysOpenQuery( _cQuery , _cAliasGru)
			IF (_cAliasGru)->C5_I_PESBR > 0
				_nPesoTot:= (_cAliasGru)->C5_I_PESBR
			EndIF
			(_cAliasGru)->(DBCloseArea())
		ElseIF !EMPTY(SC5->C5_I_PEVIN)
			_aSalvaAreaSC5:=SC5->(FwGetArea())//Salva recno e ordem
			_cPedVinc:=SC5->C5_I_PEVIN
			SC5->(Dbsetorder(14))//C5_NUM+C5_TIPO+C5_I_BLCRE
			IF SC5->(DbSeek(_cPedVinc))//POSICIONA NO PEDIDO VINCULADO sem a filail pq pode estar em outra filial quando pediodos de troca NF
				_nPesoTot+=SC5->C5_I_PESBR
			EndIF
			SC5->(FwRestArea(_aSalvaAreaSC5))
		EndIF

		_dDtMRefSalva:=_dDataMRef
		_nPesCarg:= SuperGetMV("IT_PESFOUV",.F.,4000) //esse parametrp � numerico

		IF _nPesoTot < _nPesCarg // **** FRACIONADA ****  Calcular * APENAS DIAS UTEIS *
			//_cFilCarreg,_cCod  ,_cLoja  ,_cOperPedV   ,_cTipoVenda     ,_cEstado,_cCodMunic,         _dDataRef//A data n�o via como referencia (@) pq vai ser calculada depois apenas com dias Uteis
			U_BuscaZG5(_cFilCarreg,cCodCli,cLojaCli,SC5->C5_I_OPER,SC5->C5_I_TPVEN,_cEstado,_cCodMunic,_dDataMRef,@_nDiasZG5,SF2->F2_I_LOCEM)// DESTINO: DA ITALAC PARA O CLIENTE
			_dDiasCorridos:=_dDtMRefSalva+_nDiasZG5 //#DIAS CORRIDOS
			IF EMPTY(_dDataMRef)
				_dDataMRef:=DATE()
			EndIf
			_dDtPENCO:= U_IT_DTVALIDA(_dDataMRef,_nDiasZG5)//Data calculada da entrega deve contar S� DIA UTIL: n�o conta sabado, domingo e feriado nacional

		ELSE// **** FECHADA **** Calcular * DIAS CORRIDOS *
			//_cFilCarreg,_cCod  ,_cLoja  ,_cOperPedV   ,_cTipoVenda     ,_cEstado,_cCodMunic,@_dDataRef
			U_BuscaZG5(_cFilCarreg,cCodCli,cLojaCli,SC5->C5_I_OPER,SC5->C5_I_TPVEN,_cEstado,_cCodMunic,@_dDataMRef,@_nDiasZG5,SF2->F2_I_LOCEM)// DESTINO: DA ITALAC PARA O CLIENTE
			_dDiasCorridos:=_dDtMRefSalva+_nDiasZG5 //#DIAS CORRIDOS
			IF EMPTY(_dDataMRef)
				_dDataMRef:=DATE()
			EndIf
			_dDtPENCO:= U_IT_DTVALIDA(_dDataMRef)//Se a data calculada da entrega cair em um sabado, domingo e feriado nacional, a data deve ser o PR�XIMO DIA �TIL.
		EndIf

	EndIf

	IF SC5->C5_I_DTENT >= _dDiasCorridos .AND. (SC5->C5_I_AGEND == "M" .or. SC5->C5_I_AGEND == "A")
		_dDtPENCO := SC5->C5_I_DTENT // Previs�o de entrega no cliente
	EndIf

	IF _lGrava
		SF2->(Reclock("SF2",.F.))
		SF2->F2_I_PENOL := _dDataPENOL // Previs�o de entrega no operador log�stico
		SF2->F2_I_PENCL := _dDtPENCO   // Previs�o de entrega no cliente
		SF2->F2_I_PENCO := _dDtPENCO   // Previs�o de entrega no cliente (original)
		SF2->F2_I_TT1TR := _nDiasZG5   // Transit Time 1o Trecho
		SF2->F2_I_TT2TR := _nDiasZ31   // Transit Time 1o Trecho
		SF2->(Msunlock())
		//**F2_I_PENOL - Previs�o de entrega no operador log�stico
		//**F2_I_PENCO - Previs�o de entrega no cliente (original)
		//**F2_I_PENCL - Previs�o de entrega no cliente
		//**F2_I_TT1TR - Transit Time 1o Trecho
		//**F2_I_TT2TR - Transit Time 2o Trecho
		//--F2_I_DCHOL - Data de chegada no operador log�stico
		//--F2_I_DENOL - Data de entrega no operador log�stico
		//--F2_I_DCHCL - Data de chegada no cliente
		//--F2_I_DENCL - Data de entrega no cliente

		IF U_ITGETMV("IT_GLOGDTNF",.F.)
			_cLOG:="F2_FILIAL          ;F2_DOC          ;F2_I_PEDID         ;C5_FILIAL          ;C5_NUM         ;C5_I_AGEND         ;C5_I_DTENT               ;_dDtPENCO          ;F2_I_PENCL               ;F2_I_PENOL               ;F2_I_TT1TR                     ;F2_I_TT2TR                     ;C5_I_OPER          ;C5_TIPO         ;Cod.Op.Log ;Loja Op.Log.;Regra do ZG5  ;Regra do Z31"+CRLF
			_cLOG+="'"+SF2->F2_FILIAL+";'"+SF2->F2_DOC+";"+SF2->F2_I_PEDID+";'"+SC5->C5_FILIAL+";"+SC5->C5_NUM+";"+SC5->C5_I_AGEND+";"+DTOC(SC5->C5_I_DTENT)+";"+DTOC(_dDtPENCO)+";"+DTOC(SF2->F2_I_PENCL)+";"+DTOC(SF2->F2_I_PENOL)+";"+cValToChar(SF2->F2_I_TT1TR)+";"+cValToChar(SF2->F2_I_TT2TR)+";'"+SC5->C5_I_OPER+";"+SC5->C5_TIPO+";'"+cCodOL+";'"+cLojaOP+";"+_cRegraZG5+";"+_cRegraZ31+CRLF
			_cLOG+=CRLF+"AMBIENTE:;"+ALLTRIM(GETENVSERVER())
			_cFileNome:="\data\logs_generico\m460fim_grv_dt_"+SF2->F2_FILIAL+"_"+ALLTRIM(SF2->F2_DOC)+"_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+".csv"
			MemoWrite(_cFileNome,_cLOG)
		EndIf

	ELSE
		_cPedAtual:=SC5->C5_FILIAL+" "+SC5->C5_NUM
		SC5->(Dbgoto(_nRegSC5))
		SF2->(Dbgoto(_nRegSF2))

		_aItem:={}
		AADD(_aItem,!EMPTY(_dDtPENCO) .OR. !EMPTY(_dDataPENOL))
		AADD(_aItem,SF2->F2_FILIAL)
		AADD(_aItem,_cFilCarreg)
		AADD(_aItem,_cPedOri + " / "+_cPedAtual)
		AADD(_aItem,IF(SC5->C5_I_OPER $ "05,42","Triangular ("+SC5->C5_I_OPER+") Ped.: "+_cPedAux,IF(SC5->C5_I_TRCNF="S","Troca NF SIM, Ped.: "+_cPedAux,"Troca NF NAO")))
		AADD(_aItem,SF2->F2_DOC)
		AADD(_aItem,SF2->F2_SERIE)
		AADD(_aItem,SC5->C5_I_OPER)
		AADD(_aItem,SC5->C5_I_TPVEN)
		AADD(_aItem,cCodOL )
		AADD(_aItem,cLojaOP)
		AADD(_aItem,_cEstadoOP)
		AADD(_aItem,_cCodMunOP)
		AADD(_aItem,_cMeso31Reg)
		AADD(_aItem,_cMicro31Reg)
		AADD(_aItem,cCodCli)
		AADD(_aItem,cLojaCli)
		AADD(_aItem,_cEstado)
		AADD(_aItem,_cCodMunic)
		AADD(_aItem,_cMesoG5Reg)
		AADD(_aItem,_cMicroG5Reg)
		AADD(_aItem,_cRegraZG5)
		AADD(_aItem,_cRegraZ31)
		AADD(_aItem,_dDtEmissao)//SF2->F2_EMISSAO
		AADD(_aItem,_nDiasZG5 )
		AADD(_aItem,_dDataPENOL )
		AADD(_aItem,_nDiasZ31)
		AADD(_aItem,SC5->C5_I_AGEND)
		AADD(_aItem,SC5->C5_I_DTENT)
		AADD(_aItem,_dDtPENCO )
		IF SC5->C5_I_DTENT > _dDtPENCO .AND. (SC5->C5_I_AGEND == "M" .or. SC5->C5_I_AGEND == "A")
			AADD(_aItem,SC5->C5_I_DTENT)
		ELSE
			AADD(_aItem,_dDtPENCO )// Previs�o de entrega no cliente
		EndIf
		AADD(_aItem,SF2->F2_I_DCHCL) // Data de chegada no cliente
		AADD(_aItem,SF2->F2_I_DENCL) // Data de entrega no cliente
		AADD(_aItem,SF2->F2_I_DENOL) // Data de entrega no operador log�stico
		AADD(_aItem,SF2->F2_I_DTRC ) // Entr.no Cliente (Dt.Canhoto)

		AADD(_aItem,SF2->F2_I_PENOL) // Previs�o de entrega no operador log�stico
		AADD(_aItem,SF2->F2_I_PENCO) // Previs�o de entrega no cliente (original)
		AADD(_aItem,SF2->F2_I_PENCL) // Previs�o de entrega no cliente
		AADD(_aItem,SF2->F2_I_TT1TR) // Transit Time 1o Trecho
		AADD(_aItem,SF2->F2_I_TT2TR) // Transit Time 2o Trecho
		AADD(_aItem,_nPesoTot) // Peso Bruto Total da Nota Fiscal

		_cOcorrencia :=""//Preenche na fun��o LerZF5 ()
		_cOcorDepois :=""//Preenche na fun��o LerZF5 ()
		_dDtLTipoA   := CTOD("")
		_dTADtPENCO  := CTOD("")
		_dTADtTTUCOP := CTOD("")
		_dTADtTTEOPC := CTOD("")
		_dDtLTipoB   := CTOD("")
		_dTBDtTTEOPC := CTOD("")
		_dDtLTipoC   := CTOD("")
		_dTCDtTTEOPC := CTOD("")
		_dDtLTipoD   := CTOD("")
		_dDtLTipoE   := CTOD("")
		_dDtLTipoF   := CTOD("")
		IF LerZF5( SF2->(F2_FILIAL+F2_DOC+F2_SERIE) , .F. )
			AADD(_aItem,"Tem ocorrecias: "+_cOcorrencia)
			AADD(_aItem,"Ocorrecias Alt.: "+_cOcorDepois)
			AADD(_aItem,_dDtLTipoA)
			AADD(_aItem,_dTADtPENCO)
			AADD(_aItem,_dTADtTTUCOP)
			AADD(_aItem,_dTADtTTEOPC)
			AADD(_aItem,_dDtLTipoB)
			AADD(_aItem,_dTBDtTTEOPC)
			AADD(_aItem,_dDtLTipoC)
			AADD(_aItem,_dTCDtTTEOPC)
			AADD(_aItem,_dDtLTipoD)
			AADD(_aItem,_dDtLTipoE)
			AADD(_aItem,_dDtLTipoF)
		ELSE
			AADD(_aItem,"N�O tem ocorrecias")
			AADD(_aItem,"N�O tem ocorrecias")
			AADD(_aItem,_dDtLTipoA)
			AADD(_aItem,_dTADtPENCO)
			AADD(_aItem,_dTADtTTUCOP)
			AADD(_aItem,_dTADtTTEOPC)
			AADD(_aItem,_dDtLTipoB)
			AADD(_aItem,_dTBDtTTEOPC)
			AADD(_aItem,_dDtLTipoC)
			AADD(_aItem,_dTCDtTTEOPC)
			AADD(_aItem,_dDtLTipoD)
			AADD(_aItem,_dDtLTipoE)
			AADD(_aItem,_dDtLTipoF)
		EndIf

		AADD(_aItem,SF2->(RECNO()))

		RETURN _aItem

	EndIf//IF _lGrava
RETURN .T.

/*
===============================================================================================================================
Programa----------: BuscaZ31()
Autor-------------: Alex Wallauer
Data da Criacao---: 09/05/2023
Descri��o---------: Tratamento o Transit Time do OPERADOR LOGISTICO para o CLIENTE
Parametros--------: cCodOL,cLojaOP,cCodCli,cLojaCli,@dDataRef,@nDiasUteis
Retorno-----------: .T. ou .F.
===============================================================================================================================
*/
User Function BuscaZ31(cCodOL,cLojaOP,cCodCli,cLojaCli,dDataRef,nDiasUteis)
	Local _lAchou     := .F.
	Local _cCodMunic  := ""
	Local _cEstado    := ""
	Local _cFilial    := xFilial("Z31")
	DEFAULT nDiasUteis:=0

	SA1->(DBSetOrder(1))
	SA1->(Dbseek(xFilial("SA1") + cCodCli + cLojaCli))

	_cEstado    := SA1->A1_EST
	_cCodMunic  := SA1->A1_COD_MUN

	//Privates usadas depois da chamada da fun��o
	_cMeso31Reg := Posicione("CC2",1,xFilial("CC2")+SA1->A1_EST+SA1->A1_COD_MUN,"CC2_I_MESO")
	_cMicro31Reg:= Posicione("CC2",1,xFilial("CC2")+SA1->A1_EST+SA1->A1_COD_MUN,"CC2_I_MICR")
	_cRegraZ31  := "Nao encontrou"

	Z31->(DbSetOrder(1))
	If     Z31->(Dbseek(_cFilial+cCodOL+cLojaOP+_cEstado+_cMeso31Reg+_cMicro31Reg+_cCodMunic))//OK
		_cRegraZ31:= "1) Buscou por (Operador + Estado + Meso + Micro + Munic�pio)"
		_lAchou := .T.
	ElseIf Z31->(Dbseek(_cFilial+cCodOL+cLojaOP+_cEstado+_cMeso31Reg+_cMicro31Reg+SPACE(LEN(Z31->Z31_CODMUN))))
		_cRegraZ31:= "2) Buscou por (Operador + Estado + Meso + Micro)"
		_lAchou := .T.
	ElseIf Z31->(Dbseek(_cFilial+cCodOL+cLojaOP+_cEstado+_cMeso31Reg+SPACE(LEN(Z31->Z31_MICRO))+SPACE(LEN(Z31->Z31_CODMUN))))
		_cRegraZ31:= "3) Buscou por (Operador + Estado + Meso)"
		_lAchou := .T.
	ElseIf Z31->(Dbseek(_cFilial+cCodOL+cLojaOP+_cEstado+SPACE(LEN(Z31->Z31_MESO))+SPACE(LEN(Z31->Z31_MICRO))+SPACE(LEN(Z31->Z31_CODMUN))))
		_cRegraZ31:= "4) Buscou por (Operador + Estado)"
		_lAchou := .T.
	Else
		_lAchou := .F.
	EndIf

	If _lAchou
		nDiasUteis:= Z31->Z31_TTIME
		dDataRef  := dDataRef + nDiasUteis
	Else
		//dDataRef  := CTOD("")
		nDiasUteis:= 0
	EndIf

Return _lAchou

/*
===============================================================================================================================
Programa----------: BuscaZG5()
Autor-------------: Alex Wallauer
Data da Criacao---: 09/05/2023
Descri��o---------: Tratamento o Transit Time da ITALAC para o OPERADOR LOGISTICO OU da ITALAC para o CLIENTE
Parametros--------: _cFilCarreg,_cCod,_cLoja,_cOperPedV,_cTipoVenda,_cEstado,_cCodMunic,@_dDataRef,@_nDiasZG5,_cLocalEmb
Retorno-----------: .T. ou .F.
===============================================================================================================================
*/
User Function BuscaZG5(_cFilCarreg,_cCod,_cLoja,_cOperPedV,_cTipoVenda,_cEstado,_cCodMunic,_dDataRef,_nDiasZG5,_cLocalEmb)
	Local _lAchouZG5 := .F.
	//DEFAULT _cLocalEmb:= ""
	//Privates usadas depois da chamada da fun��o
	_cMesoG5Reg := Posicione("CC2",1,xFilial("CC2")+_cEstado+_cCodMunic,"CC2_I_MESO")
	_cMicroG5Reg:= Posicione("CC2",1,xFilial("CC2")+_cEstado+_cCodMunic,"CC2_I_MICR")
	_cRegraZG5  := "Nao encontrou"
	_nDiasZG5   := 0

	IF _cLocalEmb = NIL
		// FILIAL + FILIAL_ORIGEM + ESTADO + OPERACAO + MUNICIPIO + MESO_REGIAO + MICRO_REGIAO
		ZG5->(DbSetOrder(4)) // ZG5_FILIAL+ZG5_FILORI+ZG5_UF+ZG5_OPER+ZG5_CODMUN+ZG5_MESO+ZG5_MICRO
		If ZG5->(MsSeek(xFilial("ZG5")+_cFilCarreg+_cEstado+_cOperPedV+_cCodMunic+U_ITKEY(" ","ZG5_MESO")+U_ITKEY(" ","ZG5_MICRO")))
			_cRegraZG5:= "1) Buscou por (Filial Carregamento + Estado + Opera��o + Munic�pio)"
			_lAchouZG5 := .T.
		ElseIf ZG5->(MsSeek(xFilial("ZG5")+_cFilCarreg+_cEstado+_cOperPedV+U_ITKEY(" ","ZG5_CODMUN")+_cMesoG5Reg+_cMicroG5Reg))
			_cRegraZG5:= "2) Buscou por (Filial Carregamento + Estado + Opera��o + Mesorregi�o + Microrregi�o)"
			_lAchouZG5 := .T.
		ElseIf ZG5->(MsSeek(xFilial("ZG5")+_cFilCarreg+_cEstado+_cOperPedV+U_ITKEY(" ","ZG5_CODMUN")+_cMesoG5Reg+U_ITKEY(" ","ZG5_MICRO")))
			_cRegraZG5:= "3) Buscou por (Filial Carregamento + Estado + Opera��o + Mesorregi�o)"
			_lAchouZG5 := .T.
		ElseIf ZG5->(MsSeek(xFilial("ZG5")+_cFilCarreg+_cEstado+_cOperPedV+U_ITKEY(" ","ZG5_CODMUN")+U_ITKEY(" ","ZG5_MESO")+U_ITKEY(" ","ZG5_MICRO")))
			_cRegraZG5:= "4) Buscou por (Filial Carregamento + Estado + Opera��o)"
			_lAchouZG5 := .T.
		ElseIf ZG5->(MsSeek(xFilial("ZG5")+_cFilCarreg+_cEstado+U_ITKEY(" ","ZG5_OPER")+_cCodMunic+U_ITKEY(" ","ZG5_MESO")+U_ITKEY(" ","ZG5_MICRO")))
			_cRegraZG5:= "5) Buscou por (Filial Carregamento + Estado + Munic�pio)"
			_lAchouZG5 := .T.
		ElseIf ZG5->(MsSeek(xFilial("ZG5")+_cFilCarreg+_cEstado+U_ITKEY(" ","ZG5_OPER")+U_ITKEY(" ","ZG5_CODMUN")+_cMesoG5Reg+_cMicroG5Reg))
			_cRegraZG5:= "6) Buscou por (Filial Carregamento + Estado + Mesorregi�o + Microrregi�o)"
			_lAchouZG5 := .T.
		ElseIf ZG5->(MsSeek(xFilial("ZG5")+_cFilCarreg+_cEstado+U_ITKEY(" ","ZG5_OPER")+U_ITKEY(" ","ZG5_CODMUN")+_cMesoG5Reg+U_ITKEY(" ","ZG5_MICRO")))
			_cRegraZG5:= "7) Buscou por (Filial Carregamento + Estado + Mesorregi�o)"
			_lAchouZG5 := .T.
		ElseIf ZG5->(MsSeek(xFilial("ZG5")+_cFilCarreg+_cEstado+U_ITKEY(" ","ZG5_OPER")+U_ITKEY(" ","ZG5_CODMUN")+U_ITKEY(" ","ZG5_MESO")+U_ITKEY(" ","ZG5_MICRO")))
			_cRegraZG5:= "8) Buscou por (Filial Carregamento + Estado)"
			_lAchouZG5 := .T.
		ELSE
			_cRegra := "N�o achou Filial Carregamento/Estado/Opera��o/Municipio/Mesorregiao/Microrregiao:"+_cFilCarreg+"/"+_cEstado+"/"+_cOperPedV+"/"+_cCodMunic+"/"+_cMesoG5Reg+"/"+_cMicroG5Reg
		EndIf
	ELSEIF !EMPTY(_cLocalEmb)
		// FILIAL + Local DE EMBARQUE + ESTADO + MUNICIPIO + MESO_REGIAO + MICRO_REGIAO
		ZG5->(DbSetOrder(5)) // ZG5_FILIAL+ZG5_LOCEMB+ZG5_UF+ZG5_CODMUN+ZG5_MESO+ZG5_MICRO
		If ZG5->(MsSeek(xFilial("ZG5")+_cLocalEmb+_cEstado+_cCodMunic+U_ITKEY(" ","ZG5_MESO")+U_ITKEY(" ","ZG5_MICRO")))
			_cRegraZG5:= "1) Buscou por (Local de embarque + Estado + Munic�pio)"
			_lAchouZG5 := .T.
		ElseIf ZG5->(MsSeek(xFilial("ZG5")+_cLocalEmb+_cEstado+U_ITKEY(" ","ZG5_CODMUN")+_cMesoG5Reg+_cMicroG5Reg))
			_cRegraZG5:= "2) Buscou por (Local de embarque + Estado + Mesorregi�o + Microrregi�o)"
			_lAchouZG5 := .T.
		ElseIf ZG5->(MsSeek(xFilial("ZG5")+_cLocalEmb+_cEstado+U_ITKEY(" ","ZG5_CODMUN")+_cMesoG5Reg+U_ITKEY(" ","ZG5_MICRO")))
			_cRegraZG5:= "3) Buscou por (Local de embarque + Estado + Mesorregi�o)"
			_lAchouZG5 := .T.
		ElseIf ZG5->(MsSeek(xFilial("ZG5")+_cLocalEmb+_cEstado+U_ITKEY(" ","ZG5_CODMUN")+U_ITKEY(" ","ZG5_MESO")+U_ITKEY(" ","ZG5_MICRO")))
			_cRegraZG5:= "4) Buscou por (Local de embarque + Estado )"
			_lAchouZG5 := .T.
		ELSE
			_cRegra := "N�o achou Local de Embarque/Estado/Municipio/Mesorregiao/Microrregiao:"+_cLocalEmb+"/"+_cEstado+"/"+_cCodMunic+"/"+_cMesoG5Reg+"/"+_cMicroG5Reg
		EndIf
	ENDIF

	If _lAchouZG5
		_nDiasZG5 := ZG5->ZG5_DIASV
		_dDataRef := (_dDataRef +_nDiasZG5)
	Else
		_nDiasZG5 := 0
	EndIf

RETURN _lAchouZG5
/*
===============================================================================================================================
Programa----------: IT_DTVALIDA ()
Autor-------------: Igor Melga�o
Data da Criacao---: 09/05/2023
Descri��o---------: Calcula a Data Valida de acordo com os par�metros informados.
Parametros--------: dDataRef as date ,nDiasUteis as numeric,_lPodeSab as logical,lSoma as logical,lConsFerEs as logical,_cFil_SP3 as char
Retorno-----------: dDataRef
===============================================================================================================================
*/
USER FUNCTION IT_DTVALIDA(dDataRef as date ,nDiasUteis as numeric,_lPodeSab as logical,lSoma as logical,lConsFerEs as logical,_cFil_SP3 as char)
	Local nIncrement  := 0 As numeric
	Local _nDiasUtil  := 0 As numeric
	DEFAULT _lPodeSab := .F. //Se pode considerar s�bado para entrega
	DEFAULT lSoma     := .T.
	DEFAULT lConsFerEs:= .F.
	DEFAULT nDiasUteis:= 0
	DEFAULT _cFil_SP3 := xFilial("SP3")
	STATIC aFeriados  := {} As Array //Feriados Nacionais
	If LEN(aFeriados) = 0
		SP3->(dbSetOrder(1))
		SP3->(dbGoTop())
		Do While SP3->(!EOF())
			If SP3->P3_I_TPFER = "N" //S� nacional
				If ASCAN(aFeriados,DTOS(SP3->P3_DATA) ) = 0
					AADD(aFeriados,DTOS(SP3->P3_DATA) )
				EndIf
			ElseIF lConsFerEs
				If _cFil_SP3 == SP3->P3_FILIAL //.AND. ASCAN(aFeriados, DTOS(SP3->P3_DATA) ) = 0
					AADD(aFeriados, DTOS(SP3->P3_DATA) )
				EndIf
			EndIf
			SP3->(dbSkip())
		EndDo
	EndIf
	If lSoma
		nIncrement := 1
	Else
		nIncrement := -1
	EndIf
	IF nDiasUteis = 0//DIAS CORRIDOS, OLHA A DATA DE FINAL E PULA PARA O PROXIMO DIA UTIL
		If !_lPodeSab .And. Dow(dDataRef) == 7  .and. nIncrement > 0//Se for s�bado
			dDataRef := dDataRef + nIncrement + 1
		elseIf Dow(dDataRef) == 1 //Se for domingo
			dDataRef := dDataRef + nIncrement
		EndIf
		Do While ASCAN(aFeriados, DTOS(dDataRef)  ) <> 0
			dDataRef := dDataRef + nIncrement
			If !_lPodeSab .And. Dow(dDataRef) == 7 .and. nIncrement > 0//Se for s�bado
				dDataRef := dDataRef + nIncrement + 1
			elseIf Dow(dDataRef) = 1 //Se for domingo
				dDataRef := dDataRef + nIncrement
			EndIf
		EndDo
	ELSE//S� CONTA DIAS UTEIS E QUE N�O CAIA EM FERIADO, S�BADO OU DOMINGO
		_nDiasUtil:= 0
		Do while _nDiasUtil < nDiasUteis//DIAS UTEIS
			dDataRef := dDataRef + nIncrement
			If ASCAN(aFeriados, DTOS(dDataRef)  ) <> 0 .OR. Dow(dDataRef) = 7  .OR. Dow(dDataRef) = 1//Se for Feriando ou S�bado ou Domingo n�o conta dia util
				LOOP
			EndIf
			_nDiasUtil++
		ENDDO
	EndIf

Return dDataRef
/*
===============================================================================================================================
Programa----------: TestesNF ()
Autor-------------: Alex Wallauer
Data da Criacao---: 10/05/2023
Descri��o---------: Valida custumiza��es NOVAS #TESTARNF #TESTENF #TESTANF #TestesNF
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER FUNCTION TestesNF()// U_TestesNF
	Local _aParRet :={}
	Local _aParAux :={} , nI
	PRIVATE _AITALAC_F3:={}
	_BSelectSF2:={|| "SELECT DISTINCT F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO FROM "+RETSQLNAME("SF2")+" SF2 WHERE"+;
		" F2_FILIAL  IN "+FormatIn(ALLTRIM(MV_PAR01),";")+" AND "+;
		" F2_TIPO = 'N' AND "+;
		IF(!EMPTY(MV_PAR02)," F2_EMISSAO >= '"+DTOS(MV_PAR02) + "' AND","")+;
			IF(!EMPTY(MV_PAR03)," F2_EMISSAO <= '"+DTOS(MV_PAR03) + "' AND","")+;
				" D_E_L_E_T_ <> '*' ORDER BY F2_FILIAL , F2_EMISSAO , F2_DOC, F2_SERIE " }
			AADD(_aItalac_F3,{"MV_PAR04",_BSelectSF2,{|Tab| (Tab)->F2_DOC }, {|Tab| (Tab)->F2_FILIAL+" "+ALLTRIM((Tab)->F2_SERIE)+" "+(Tab)->F2_CLIENTE+" "+(Tab)->F2_LOJA+" "+DTOC(STOD((Tab)->F2_EMISSAO)) } , ,"NOTAS",,,,.F.        ,       ,{|L,D| U_ROM66VAL(L,D) } } )
			_aOpcoes:={"1-Calc.Ped/Seg/CHEP",;
				"2-Datas Previstas  ",;
				"3-Acerta Campos    "}
			MV_PAR01:=SPACE(100)
			MV_PAR02:=CTOD("")
			MV_PAR03:=CTOD("")
			MV_PAR04:=SPACE(200)
			MV_PAR05:=SPACE(200)
			MV_PAR06:=SPACE(200)
			MV_PAR07:=VAL(_aOpcoes[1])
			AADD( _aParAux , { 1 , "Filiais"            , MV_PAR01, "@!"    , ""    ,"LSTFIL"  , "" , 100 , .F. } )
			AADD( _aParAux , { 1 , "Data de"	        , MV_PAR02, "@D"	, ""	, ""	   , "" , 050 , .T. } )
			AADD( _aParAux , { 1 , "Data ate"	        , MV_PAR03, "@D"	, ""	, ""	   , "" , 050 , .T. } )
			AADD( _aParAux , { 1 , "Selecione as Notas:", MV_PAR04, "@!"	, ""    , "F3ITLC" , "" , 100 , .F. } )
			AADD( _aParAux , { 1 , "Tipo Operacao"      , MV_PAR05, "@!"	, ""    , "ZB4"    , "" , 100 , .F. } )
			AADD( _aParAux , { 1 , "Selecione as Cargas", MV_PAR06, "@!"	, ""    , "DAK"    , "" , 100 , .F. } )
			AADD( _aParAux , { 3 , "Selecione o Teste"  , MV_PAR07, _aOpcoes                        , 100 , "",.T.,.T.,.T.} )
			For nI := 1 To Len( _aParAux )
				aAdd( _aParRet , _aParAux[nI][03] )
			Next nI
			DO WHILE .T.
				//aParametros, cTitle                 , @aRet    ,[bOk], [ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ]
				IF !ParamBox( _aParAux , "Digite o filtro das notas:" , @_aParRet,     , /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
					Return .T.
				EndIf
				IF VALTYPE(MV_PAR07) = "N"
					MV_PAR07:=STR(MV_PAR07,1)
				EndIf
				_aItensNF:={}
				_cHoraIni:=TIME()
				_aColXML := {}
				PRIVATE _nPosProd   := 0 //PREENCHE DENTRO DA FUNCAO MontaLista ()
				PRIVATE _nPosPedNF  := 0 //PREENCHE DENTRO DA FUNCAO MontaLista ()
				PRIVATE _nPosItemPed:= 0 //PREENCHE DENTRO DA FUNCAO MontaLista ()
				PRIVATE nPosNFFret  := 0 //PREENCHE DENTRO DA FUNCAO MontaLista ()
				PRIVATE nPosITFret  := 0 //PREENCHE DENTRO DA FUNCAO MontaLista ()
				_lRet:=.T.
				FWMSGRUN( ,{|oproc| _lRet:=LerNotas(oproc) } ,"Hora Inicial: "+_cHoraIni+", Aguarde!",'Lendo Notas...'  )
				IF LEN(_aItensNF) > 0
					_nTipoLisBox:=4
					aTitCol:={}
					IF MV_PAR07 = "1"//1-Calc.Ped/Seg/CHEP
						aTitCol:={}
						_aCabXML:={}
						// Alinhamento: 1-Left   ,2-Center,3-Right
						// Formata��o.: 1-General,2-Number,3-Monet�rio,4-DateTime
						//             Titulo das Colunas ,Alinhamento ,Formata��o, Totaliza?
						//   (_aCabXML,{Titulo                 ,1           ,1         ,.F.       })
						AADD(aTitCol,"")
						AADD(_aCabXML,{"S� Pallet?"            ,2           ,1         ,.F.})//01
						AADD(aTitCol,"Filial")
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,2           ,1         ,.F.})//02
						AADD(aTitCol,"Carga")
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,2           ,1         ,.F.})//03
						AADD(aTitCol,"Filial RDC")
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,2           ,1         ,.F.})//04
						AADD(aTitCol,"Carga RDC")
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,2           ,1         ,.F.})//05
						AADD(aTitCol,"Nota Fiscal")
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,2           ,1         ,.F.})//06
						AADD(aTitCol,"Serie")
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,2           ,1         ,.F.})//07
						AADD(aTitCol,"Tipo")
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,2           ,1         ,.F.})//08
						AADD(aTitCol,"Dt Emiss. NF")
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,2           ,1         ,.F.})//09
						AADD(aTitCol,"Produto")              ; nPospProd:=LEN(aTitCol)
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,2           ,1         ,.F.})//10
						AADD(aTitCol,"Peso Bruto Unit")      ; nPosPeBrUn:=LEN(aTitCol)
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,3           ,2         ,.F.})//11
						AADD(aTitCol,"Vlr Pedagio Tot / NF") ; nPosVlPTot:=LEN(aTitCol)
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,3           ,3         ,.F.})//12
						AADD(aTitCol,"Peso Tot Carga / NF")  ; nPosPeToCa:=LEN(aTitCol)
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,3           ,2         ,.F.})//13
						AADD(aTitCol,"Peso Tot NF / Item")   ; nPosPeToNF:=LEN(aTitCol)
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,3           ,2         ,.F.})//14
						AADD(aTitCol,"Vlr Pedagio NF / Item"); nPosVlPeNF:=LEN(aTitCol)
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,3           ,3         ,.F.})//15
						AADD(aTitCol,"Vlr Bruto NF / Item")  ;nPosVlBrNF:=LEN(aTitCol)
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,3           ,3         ,.F.})//16
						AADD(aTitCol,"% Seguro")             ;nPosPercen:=LEN(aTitCol)
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,3           ,2         ,.F.})//17
						AADD(aTitCol,"Vlr Seguro NF / Item") ;nPosVlSeNF:=LEN(aTitCol)
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,3           ,3         ,.F.})//18
						AADD(aTitCol,"Vlr Frete OL Tot / NF 2") ; nPosVlFrNF:=LEN(aTitCol)
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,3           ,3         ,.F.})//19
						AADD(aTitCol,"Vlr Frete NF / Item 2")   ; nPosVlFrIt:=LEN(aTitCol)
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,3           ,3         ,.F.})//20
						AADD(aTitCol,"Operador")
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,2           ,1         ,.F.})//21
						AADD(aTitCol,"Redespacho")
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,2           ,1         ,.F.})//21
						AADD(aTitCol,"Vlr Frete NF / Item 1")   ; nPosVl1FrI:=LEN(aTitCol)
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,3           ,3         ,.F.})//20
						AADD(aTitCol,"Chave ZGX")
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,1           ,1         ,.F.})//21
						AADD(aTitCol,"Recno SF2/SD2")
						AADD(_aCabXML,{aTitCol[LEN(aTitCol)]   ,2           ,1         ,.F.})//22 // N�o mudar de possicao , colocar campos novos antes dessa coluna
						cTit1      :="VALORES CALCULADAS PARA GRAVAR NAS NOTAS: "+DTOC(DATE())+" HI: "+_cHoraIni+" HF: "+TIME()
						_cPictPeso := "9999"+PesqPict("DAK","DAK_PESO")
						_cPictValor:= "9999"+PesqPict("SD2","D2_TOTAL")+"999"
						_aColXML:=ACLONE(_aItensNF)   //FORMATO CORRETO PARA GERAR O EXCEL EM INGLES COM PONTO PARA DECIMAIS
						FOR nI := 1 TO LEN(_aItensNF) //AJUSTE PARA MOSTRAR NA TELA DO U_ITListBox() CORRETA
							_aColXML[nI,1]:= IF(_aColXML[nI,1],"NAO","SIM")
							_aItensNF[nI,nPosPeBrUn]:= TRANSFORM(_aItensNF[nI,nPosPeBrUn],_cPictPeso)
							_aItensNF[nI,nPosVlPTot]:= TRANSFORM(_aItensNF[nI,nPosVlPTot],_cPictValor)
							_aItensNF[nI,nPosPeToCa]:= TRANSFORM(_aItensNF[nI,nPosPeToCa],_cPictPeso)
							_aItensNF[nI,nPosPeToNF]:= TRANSFORM(_aItensNF[nI,nPosPeToNF],_cPictPeso)
							_aItensNF[nI,nPosVlPeNF]:= TRANSFORM(_aItensNF[nI,nPosVlPeNF],_cPictValor)
							_aItensNF[nI,nPosVlBrNF]:= TRANSFORM(_aItensNF[nI,nPosVlBrNF],_cPictValor)
							_aItensNF[nI,nPosPercen]:= TRANSFORM(_aItensNF[nI,nPosPercen],_cPictValor)
							_aItensNF[nI,nPosVlSeNF]:= TRANSFORM(_aItensNF[nI,nPosVlSeNF],_cPictValor)
							_aItensNF[nI,nPosVlFrNF]:= TRANSFORM(_aItensNF[nI,nPosVlFrNF],_cPictValor)
							_aItensNF[nI,nPosVl1FrI]:= TRANSFORM(_aItensNF[nI,nPosVl1FrI],_cPictValor)
							_aItensNF[nI,nPosVlFrIt]:= TRANSFORM(_aItensNF[nI,nPosVlFrIt],_cPictValor)
						NEXT nI
					ELSEIF MV_PAR07 = "2"//2-Datas Previstas
						_aCabXML:=NIL
						_aColXML:=NIL
						AADD(aTitCol,"")
						AADD(aTitCol,"Filial Posicionada")
						AADD(aTitCol,"Filial Carr.")
						AADD(aTitCol,"Ped. SF2 / Ped. Posicionado")
						AADD(aTitCol,"Tipo / Pedido")
						AADD(aTitCol,"Nota Fiscal")
						AADD(aTitCol,"Serie")
						AADD(aTitCol,"Tipo Oper.")
						AADD(aTitCol,"Tipo Venda")
						AADD(aTitCol,"Cod. Oper. log.")
						AADD(aTitCol,"Loja Oper. log.")
						AADD(aTitCol,"UF Oper. log.")
						AADD(aTitCol,"Mun. Oper. log.")
						AADD(aTitCol,"Meso Reg. (Z31)")
						AADD(aTitCol,"Micro Reg. (Z31)")
						AADD(aTitCol,"Cliente")
						AADD(aTitCol,"Loja")
						AADD(aTitCol,"UF Cliente")
						AADD(aTitCol,"Mun. Cliente")
						AADD(aTitCol,"Meso Reg (ZG5)")
						AADD(aTitCol,"Micro Reg. (ZG5) ")
						AADD(aTitCol,"Regra (ZG5)")
						AADD(aTitCol,"Regra (Z31)")
						AADD(aTitCol,"F2_EMISSAO - Dt Emiss. NF")
						AADD(aTitCol,"* F2_I_TT1TR - Dias (ZG5)")                                ; _nPosDZG5:=LEN(aTitCol)
						AADD(aTitCol,"* F2_I_PENOL - Data Previs�o entrega operador log�stico")  ; _nPosDtOL:=LEN(aTitCol)
						AADD(aTitCol,"* F2_I_TT2TR - Dias Uteis (Z31) ")                         ; _nPosDZ31:=LEN(aTitCol)
						AADD(aTitCol,"Peso Bruto Total") // Peso Bruto Total da Nota Fiscal  _nPesoTot
						AADD(aTitCol,"C5_I_AGEND")                                               ; _nPosC5I_AGEND:=LEN(aTitCol)
						AADD(aTitCol,"C5_I_DTENT - Data Previs�o entrega no cliente do PV")      ; _nPosC5_I_DTENT:=LEN(aTitCol)
						AADD(aTitCol,"F2_I_PENCL - Data Previs�o entrega no cliente calculada")  ; _nPosDtCliente:=LEN(aTitCol)
						AADD(aTitCol,"* Data que vai gravar no F2_I_PENCL")
						AADD(aTitCol,"F2_I_DCHCL - Data Chegada no Cliente")
						AADD(aTitCol,"F2_I_DENCL - Data Entrega no Cliente")
						AADD(aTitCol,"F2_I_DENOL - Data Entrega no Operador Log�stico")
						AADD(aTitCol,"F2_I_DTRC  - Entr.no Cliente (Dt.Canhoto")
						AADD(aTitCol,"F2_I_PENOL")
						AADD(aTitCol,"F2_I_PENCO")
						AADD(aTitCol,"F2_I_PENCL")
						AADD(aTitCol,"F2_I_TT1TR")
						AADD(aTitCol,"F2_I_TT2TR")
						AADD(aTitCol,"Ocorrecias da ZF5 - ANTES")
						AADD(aTitCol,"Ocorrecias da ZF5 - DEPOIS")
						AADD(aTitCol,"Tipo A - Dt. Ocorrecia ")//_dDtLTipoA)
						AADD(aTitCol,"Tipo A - Dt. F2_I_PENCO")//_dTADtPENCO
						AADD(aTitCol,"Tipo A - Dt. F2_I_PENOL")//_dTADtTTUCOP)
						AADD(aTitCol,"Tipo A - Dt. F2_I_PENCL")//_dTADtTTEOPC)
						AADD(aTitCol,"Tipo B - Dt. Ocorrecia ")//_dDtLTipoB)
						AADD(aTitCol,"Tipo B - Dt. F2_I_PENCL")//_dTBDtTTEOPC)
						AADD(aTitCol,"Tipo C - Dt. Ocorrecia ")//_dDtLTipoC)
						AADD(aTitCol,"Tipo C - Dt. F2_I_PENCL")//_dTCDtTTEOPC)
						AADD(aTitCol,"Tipo D - Dt. Ocorrecia F2_I_DCHCL")//_dDtLTipoD)
						AADD(aTitCol,"Tipo E - Dt. Ocorrecia F2_I_DENCL")//_dDtLTipoE)
						AADD(aTitCol,"Tipo F - Dt. Ocorrecia F2_I_PENCL")//_dDtLTipoF)
						AADD(aTitCol,"Recno DO SF2")
						cTit1:="DATAS PREVISTAS CALCULADAS PARA GRAVAR NAS NOTAS: "+DTOC(DATE())+" HI: "+_cHoraIni+" HF: "+TIME()
					ELSEIF MV_PAR07 = "3"//3-Acertos de campos
						AADD(aTitCol,"Marcado"   )//01
						AADD(aTitCol,"Diferente" )//02
						AADD(aTitCol,"F2_FILIAL ")//03
						AADD(aTitCol,"C5_FILIAL ")//04
						AADD(aTitCol,"F2_DOC    ")//05
						AADD(aTitCol,"F2_SERIE  ")//06
						AADD(aTitCol,"F2_I_PEDID")//07
						AADD(aTitCol,"C5_NUM    ")//08
						AADD(aTitCol,"F2_I_LOCEM")//09
						AADD(aTitCol,"C5_I_LOCEM")//10
						AADD(aTitCol,"F2_I_NFSED")//11
						AADD(aTitCol,"C5_I_NFSED")//12
						AADD(aTitCol,"F2_I_NFREF")//13
						AADD(aTitCol,"C5_I_NFREF")//14
						AADD(aTitCol,"F2_I_SERNF")//15
						AADD(aTitCol,"C5_I_SERNF")//16
						AADD(aTitCol,"F2_TPFRETE")//17
						AADD(aTitCol,"C5_TPFRETE")//18
						AADD(aTitCol,"C5_I_OPER ")//19
						AADD(aTitCol,"C5_I_STATU")//21
						AADD(aTitCol,"OBS"       )//22
						AADD(aTitCol,"Recno SF2" )//23
						cTit1:="CAMPOS N�O GRAVADOS PARA GRAVAR NAS NOTAS: "+DTOC(DATE())+" HI: "+_cHoraIni+" HF: "+TIME()
						_nTipoLisBox:=2
						_aCabXML:=NIL
						_aColXML:=ACLONE(_aItensNF)
						FOR nI := 1 TO LEN(_aItensNF) //AJUSTE PARA MOSTRAR NA TELA DO U_ITListBox() CORRETA
							_aColXML[nI,1]:= IF(_aColXML[nI,1],"SIM","NAO")
							_aColXML[nI,2]:= IF(_aColXML[nI,2],"NAO","SIM")
						NEXT nI
					EndIf
					cTit2:=cTit1
					DO WHILE .T.
						//      ITListBox(_cTitAux , _aHeader , _aCols    , _lMaxSiz ,  nTipo     , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab  ,bDblClk , _aColXML , bCondMarca,_bLegenda)
						lRet:=U_ITLISTBOX(cTit1    , aTitCol  , _aItensNF , .T.      ,_nTipoLisBox, cTit2    ,          ,         ,         ,     ,        ,          ,_aCabXML,        , _aColXML )//
						IF lRet .AND. !U_ITMSG( "CONFIMA GRAVACAO DO DADOS?",'ATENCAO!',,3,2,2)
							LOOP
						EndIf
						IF lRet
							_cHoraIni:=TIME()
							FWMSGRUN( ,{|oproc| GravaNotas(oproc) } ,'Aguarde!','Gravando Notas...'  )
							cTit1:="RESULTADO DAS GRAVA��ES: "+DTOC(DATE())+" HI: "+_cHoraIni+" HF: "+TIME()
							//      ITListBox(_cTitAux , _aHeader , _aCols    , _lMaxSiz ,  nTipo     , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab  ,bDblClk , _aColXML , bCondMarca,_bLegenda)
							lRet:=U_ITLISTBOX(cTit1    , aTitCol  , _aItensNF , .T.      ,_nTipoLisBox, cTit2    ,          ,         ,         ,     ,        ,          ,_aCabXML,        , _aColXML )//
						EndIf
						EXIT
					ENDDO
				ELSE
					IF !_lRet
						U_ITMSG("N�o h� dados para esses filtros.","Aten��o","Digite outros filtros",3)
					EndIf
					Loop
				EndIf
			ENDDO
			RETURN
/*
===============================================================================================================================
Programa----------: LerNotas()
Autor-------------: Alex Wallauer
Data da Criacao---: 10/05/2023
Descri��o---------: Valida custumiza��es NOVAS
Parametros--------: oproc
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC FUNCTION LerNotas(oproc)

	Local _cAlias := GetNextAlias()
	Local _nConta :=0 , I
	Local _cQrySF2:= " SELECT R_E_C_N_O_  RECSF2 "
	Local _nQtdReg As Numeric

	_cQrySF2 += " FROM " + RetSqlName("SF2") + " SF2 "
	_cQrySF2 += " WHERE SF2.D_E_L_E_T_ = ' ' "
	IF !EMPTY(MV_PAR01)
		_cQrySF2 += " AND F2_FILIAL IN " +FormatIn(ALLTRIM(MV_PAR01),";")
	ENDIF
	_cQrySF2 += " AND F2_TIPO = 'N' "
	IF !EMPTY(MV_PAR04)
		_cQrySF2 += " AND F2_DOC IN " +FormatIn(ALLTRIM(MV_PAR04),";")
	ENDIF
	IF !EMPTY(MV_PAR06)
		_cQrySF2 += " AND F2_CARGA IN " +FormatIn(ALLTRIM(MV_PAR06),";")
	ENDIF
	IF MV_PAR07 = "1"//1-Calc.Ped/Seg/CHEP
		_cQrySF2 += " AND EXISTS (SELECT 'Y' FROM " +RetSqlName("DAK")+ " DAK "
		_cQrySF2 += "                    WHERE DAK.D_E_L_E_T_ <> '*' AND SF2.F2_FILIAL = DAK.DAK_FILIAL AND SF2.F2_CARGA = DAK.DAK_COD "
		IF !EMPTY(MV_PAR02)
			_cQrySF2 += " AND DAK_DATA >= '"+Dtos(MV_PAR02) + "' "
		ENDIF
		IF !EMPTY(MV_PAR03)
			_cQrySF2 += " AND DAK_DATA <= '"+Dtos(MV_PAR03) + "' "
		ENDIF
		_cQrySF2 += " ) "
	ELSEIF MV_PAR07 $ "2,3"
		IF !EMPTY(MV_PAR02)
			_cQrySF2 += " AND F2_EMISSAO >= '"+Dtos(MV_PAR02) + "' "
		ENDIF
		IF !EMPTY(MV_PAR03)
			_cQrySF2 += " AND F2_EMISSAO <= '"+Dtos(MV_PAR03) + "' "
		ENDIF
	ENDIF

	IF !EMPTY(MV_PAR05)
		_cQrySF2 += " AND EXISTS (SELECT 'Y' FROM " +RetSqlName("SC5")+ " C5 "
		_cQrySF2 += "                    WHERE C5.D_E_L_E_T_ <> '*' AND SF2.F2_FILIAL = C5.C5_FILIAL AND SF2.F2_I_PEDID = C5.C5_NUM "
		_cQrySF2 += "                                               AND C5.C5_I_OPER IN "+ FormatIn( MV_PAR05 , ";" ) + " )"
	ENDIF

	_cQrySF2 += " ORDER BY F2_FILIAL, F2_CARGA , F2_DOC , F2_SERIE "

	MPSysOpenQuery( _cQrySF2 , _cAlias)
	_nQtdReg:=0

	DBSelectArea(_cAlias)
	COUNT TO _nQtdReg

	(_cAlias)->(DBGOTOP())

	_cTotal:=ALLTRIM(STR(_nQtdReg))
	nTam:=LEN(_cTotal)

	IF EMPTY( _nQtdReg )
		//U_ITMSG("Nao tem dados para consultar com os filtros selecionados","Aten��o","Verifique / altere o filtros selecionados",3)
		RETURN .F.
	ELSEIF !U_ITMSG( "Ser�o processados "+_cTotal+" registros. Deseja Continuar?",'ATENCAO!',,3,2,2)
		RETURN .F.
	ENDIF

	SC6->(DBSETORDER(2))
	SF2->(DBSETORDER(1))
	SB1->(DBSETORDER(1))
	_aItensNF:= {}
	_cFilSalva:=cFilAnt

	DO While ! (_cAlias)->(EOF())

		SF2->(DBGOTO((_cAlias)->RECSF2))
		_nConta++
		oProc:cCaption := "Lendo NF: "+SF2->F2_DOC+" - "+(STRZERO(_nConta,nTam))+" / "+_cTotal
		PROCESSMESSAGES()

		cFilAnt:=SF2->F2_FILIAL

		IF MV_PAR07 = "1"//1-Calc.Ped/Seg/CHEP
			// Calcula o campos referentes a PEDAGIO / SEGURO / CHEP
			_aItensNFAux:=U_GrvRatVlrs(.F.)//S� le os valores calculadas
			FOR I := 1 TO LEN(_aItensNFAux)
				AADD(_aItensNF,_aItensNFAux[I])
			NEXT I
		ELSEIF MV_PAR07 = "2"//2-Datas Previstas
			// Calcula o campos referentes ao Transit time
			_aItem:=GrvTransiTime(.F.)//S� le as datas calculadas
			AADD(_aItensNF,_aItem)
		ELSEIF MV_PAR07 = "3"//3-Acertos de campos
			_aItem:=AcertaSF2(.F.)//VE QUAIS NOTAS EST�O DIFERENTES
			IF LEN(_aItem) > 0
				AADD(_aItensNF,_aItem)
			ENDIF
		ENDIF
		(_cAlias)->(DbSkip())
	EndDo

	//IF MV_PAR07 = "1"
	//   oProc:cCaption := "Acertando os Totais das Notas - "+(STRZERO(_nConta,nTam))+" / "+_cTotal
	//   PROCESSMESSAGES()
	//   U_M460Acertos(.F.)
	//ENDIF

	cFilAnt:=_cFilSalva

	(_cAlias)->( DBCloseArea() )

RETURN .T.
/*
===============================================================================================================================
Programa----------: AcertaSF2()
Autor-------------: Alex Wallauer
Data da Criacao---: 03/02/2025
Descri��o---------: S� le so campos
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC FUNCTION AcertaSF2(lGrava,G)
	Local _aItem := {} As Array

	_nNrRecno := PosicSC5(SF2->F2_DOC , SF2->F2_SERIE , SF2->F2_FILIAL)  // Retorna o numero do recno da tabela SC5 correspontentes a nota fiscal, serie e filial passados como par�metros.

	If _nNrRecno > 0

		SC5->(DbGoTo(_nNrRecno))  // Posiciona a tabela SC5 no registro relacionado a Nota Fiscal, Serie e Filial correspondentes da tabela SF2.

		If lGrava

			SF2->( RecLock( "SF2" , .F. ) )
			IF (EMPTY(SF2->F2_I_LOCEM) .OR. SF2->F2_I_LOCEM <> SC5->C5_I_LOCEM) .AND. !EMPTY(SC5->C5_I_LOCEM)
				SF2->F2_I_LOCEM := SC5->C5_I_LOCEM
			ENDIF
			IF EMPTY(SF2->F2_I_NFSED)
				SF2->F2_I_NFSED := SC5->C5_I_NFSED
			ENDIF
			IF EMPTY(SF2->F2_I_NFREF)
				SF2->F2_I_NFREF := SC5->C5_I_NFREF
			ENDIF
			IF EMPTY(SF2->F2_I_SERNF)
				SF2->F2_I_SERNF := SC5->C5_I_SERNF
			ENDIF
			IF EMPTY(SF2->F2_I_PEDID)
				SF2->F2_I_PEDID := SC5->C5_NUM
			ENDIF
			_cTpFroVei := ""
			IF SF2->F2_TPFRETE <> "R" .OR. SC5->C5_TPFRETE <> 'R'
				If !Empty(SF2->F2_VEICUL1)
					_cTpFroVei :=  Posicione( 'DA3' , 1 , xFilial('DA3')+SF2->F2_VEICUL1 , 'DA3_FROVEI' ) // 1=DA3_FILIAL+DA3_COD
				EndIf
			ENDIF
			IF SF2->F2_TPFRETE <> "R"
				If !Empty(_cTpFroVei) .And. _cTpFroVei == "1" // Frota pr�pria
					SF2->F2_TPFRETE := "R" // R=POR CONTA REMETENTE
				EndIf
			ENDIF
			SF2->( MsUnLock() )

			//GRAVA STATUS DO PEDIDO PARA RDC E PORTAL DO CLIENTE
			SC5->(RecLock("SC5",.F.))
			IF SC5->C5_I_STATU <> "02"
				SC5->C5_I_STATU := "02"
			ENDIF
			IF SC5->C5_TPFRETE <> 'R'
				If !Empty(_cTpFroVei) .And. _cTpFroVei == "1" // Frota pr�pria
					SC5->C5_TPFRETE := "R" // R=POR CONTA REMETENTE
				EndIf
			EndIf
			SC5->( MsUnlock() )

			// Grava monitor de pedidos de vendas para opera��es monitoradas
			If !(SC5->C5_I_OPER $ _cIT_MPVOP)
				_cJUSCOD:= "008"//FATURADO
				_cCOMENT:= "Faturamento via nota " + alltrim(SF2->F2_FILIAL) + " - " + ALLTRIM(SF2->F2_DOC) + "/" + ALLTRIM(SF2->F2_SERIE)+"."
				//_cFilial,_cNum,_cJUSCOD,_cCOMENT,_cLENCMON,_dDTNECE       ,_dDTFAT,_dDTFOLD       , _cObserv      , _cVinculoTb, _dDtSugAgen ,_lRestArea
				U_GrvMonitor(,  ,_cJUSCOD,_cCOMENT,"N"      ,SC5->C5_I_DTNEC,DATE() ,SC5->C5_I_DTENT,"Acerto do SF2",            ,             ,.F.	   )
				IF ZY3->ZY3_NUMPV = SC5->C5_NUM .AND. ZY3->ZY3_FILFT = SC5->C5_FILIAL
					_aItensNF[G, (LEN(_aItensNF[G])-1) ] := "Gravou no ZY3"
					ZY3->(RECLOCK("ZY3",.F.))
					ZY3->ZY3_CODUSR := SubStr( Embaralha( SF2->F2_USERLGI, 1 ), 3, 6 )
					ZY3->ZY3_NOMUSR := AllTrim(UsrFullName(ALLTRIM(ZY3->ZY3_CODUSR)))
					IF !EMPTY(SF2->F2_CARGA)
						ZY3->ZY3_ORIGEM := "MATA460B"
					ELSE
						ZY3->ZY3_ORIGEM := "MATA460A"
					ENDIF
					ZY3->(MsUnLock())
				Endif
			Endif

			IF !EMPTY(SF2->F2_I_LOCEM)
				GrvTransiTime(.T.)//Grava como se fosse chamada do final da gravacao do fatuamento da nota
				_aItensNF[G, (LEN(_aItensNF[G])-1) ] := _aItensNF[G, (LEN(_aItensNF[G])-1) ] + " Acertou Datas"
			ENDIF

		Else
			_lDiferente:=.F.
			IF SF2->F2_I_LOCEM <> SC5->C5_I_LOCEM
				_lDiferente:=.T.
			ENDIF
			IF SF2->F2_I_NFSED <> SC5->C5_I_NFSED
				_lDiferente:=.T.
			ENDIF
			IF SF2->F2_I_NFREF <> SC5->C5_I_NFREF
				_lDiferente:=.T.
			ENDIF
			IF SF2->F2_I_SERNF <> SC5->C5_I_SERNF
				_lDiferente:=.T.
			ENDIF
			IF SF2->F2_I_PEDID <> SC5->C5_NUM
				_lDiferente:=.T.
			ENDIF
			IF SC5->C5_I_STATU <> "02"
				_lDiferente:=.T.
			ENDIF
			_cTpFroVei := ""
			IF SF2->F2_TPFRETE <> "R" .OR. SC5->C5_TPFRETE <> 'R'
				If !Empty(SF2->F2_VEICUL1)
					_cTpFroVei :=  Posicione( 'DA3' , 1 , xFilial('DA3')+SF2->F2_VEICUL1 , 'DA3_FROVEI' ) // 1=DA3_FILIAL+DA3_COD
				EndIf
			ENDIF
			IF SF2->F2_TPFRETE <> "R"
				If !Empty(_cTpFroVei) .And. _cTpFroVei == "1" // Frota pr�pria
					_lDiferente:=.T.
				EndIf
			ENDIF
			IF SC5->C5_TPFRETE <> 'R'
				If !Empty(_cTpFroVei) .And. _cTpFroVei == "1" // Frota pr�pria
					_lDiferente:=.T.
				EndIf
			EndIf
			IF !_lDiferente
				Return _aItem
			ENDIF
			_aItem:={}
			AADD(_aItem, _lDiferente   )//01
			AADD(_aItem, !_lDiferente  )//02
			AADD(_aItem,SF2->F2_FILIAL )//03
			AADD(_aItem,SC5->C5_FILIAL )//04
			AADD(_aItem,SF2->F2_DOC    )//05
			AADD(_aItem,SF2->F2_SERIE  )//06
			AADD(_aItem,SF2->F2_I_PEDID)//07
			AADD(_aItem,SC5->C5_NUM    )//08
			AADD(_aItem,SF2->F2_I_LOCEM)//09
			AADD(_aItem,SC5->C5_I_LOCEM)//10
			AADD(_aItem,SF2->F2_I_NFSED)//11
			AADD(_aItem,SC5->C5_I_NFSED)//12
			AADD(_aItem,SF2->F2_I_NFREF)//13
			AADD(_aItem,SC5->C5_I_NFREF)//14
			AADD(_aItem,SF2->F2_I_SERNF)//15
			AADD(_aItem,SC5->C5_I_SERNF)//16
			AADD(_aItem,SF2->F2_TPFRETE)//17
			AADD(_aItem,SC5->C5_TPFRETE)//18
			AADD(_aItem,SC5->C5_I_OPER )//19
			AADD(_aItem,SC5->C5_I_STATU)//21
			AADD(_aItem,"")//22
			AADD(_aItem,SF2->(RECNO()) )//23
		EndIf
	EndIf

Return _aItem

/*
===============================================================================================================================
Programa----------: GravaNotas()
Autor-------------: Alex Wallauer
Data da Criacao---: 10/05/2023
Descri��o---------: Valida custumiza��es NOVAS
Parametros--------: oproc
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC FUNCTION GravaNotas(oproc)
	Local _nQtdReg := LEN(_aItensNF) , G
	Local _lGravaComFuncao:=.T.
	_lLerZF5:=.F.

	IF MV_PAR07 = "2"//
		_lGravaComFuncao:=.T.//U_ITMSG("Gravar via funcao GRVTRANSITIME() ( mais lento ) ou o Calculo da Tela ( mais rapido )","OPCOES DE GRAVACAO","",2,2,4,,"GRVTRANSITIME","TELA")
		_lLerZF5        :=.T.//U_ITMSG("Ler e aplicar as Datas lan�adas nas ocorrecias de frete  (ZF5)?"                      ,"OPCOES DE GRAVACAO","",2,2,4,,"LER E APLICAR","N�O LER")
	ELSEIF MV_PAR07 = "1"//
		_nQtdReg:=0
		FOR G := 1 TO LEN(_aItensNF)
			IF _aItensNF[G,LEN(_aItensNF[G]) ] > 0//ULTIMA COLUNA SEMPRE O RECNO DO SF2
				_nQtdReg++
			ENDIF
		NEXT G
	ELSEIF MV_PAR07 = "3"//
		_nQtdReg:=0
		FOR G := 1 TO LEN(_aItensNF)
			IF _aItensNF[G,LEN(_aItensNF[G]) ] > 0//ULTIMA COLUNA SEMPRE O RECNO DO SF2
				_nQtdReg++
			ENDIF
		NEXT
	ENDIF

	Private _cIT_MPVOP:=AllTrim(U_ITGETMV( 'IT_MPVOP' , '50/51/02')) As Character

	_cTotal:=ALLTRIM(STR(_nQtdReg))
	IF EMPTY( _nQtdReg )
		U_ITMSG("Nao tem dados para consultar com os filtros selecionados","Aten��o","Verifique / altere o filtros selecionados",3)
		RETURN .F.
	ENDIF
	_cFilSalva:=cFilAnt
	_nConta:=0
	_nCorre:=0
	_aNFAux:={}
	FOR G := 1 TO _nQtdReg

		nRecSF2:=_aItensNF[G,LEN(_aItensNF[G]) ]//ULTIMA COLUNA SEMPRE O RECNO
		IF MV_PAR07 = "1"//1-Calc.Ped/Seg/CHEP
			IF nRecSF2 > 0 .AND. _aItensNF[G,_nPosProd] = "CAPA NF:"
				SF2->(DBGOTO( nRecSF2 ))
			ELSE
				LOOP // ************************* LOOP *****************************************************************************************
			EndIf
		ELSEIF MV_PAR07 = "2"//2-Datas Previstas
			IF nRecSF2 > 0
				SF2->(DBGOTO( nRecSF2 ))
			ELSE
				LOOP // ************************* LOOP *****************************************************************************************
			EndIf
		ELSEIF MV_PAR07 = "3"//3-Acertos de campos
			IF nRecSF2 > 0
				SF2->(DBGOTO( nRecSF2 ))
			ELSE
				LOOP // ************************* LOOP *****************************************************************************************
			EndIf
			_nConta++
			IF _aItensNF[G, 1 ]
				_nCorre++
				AcertaSF2(.T.,G)//ACERTA OS CAMPOS N�O preenchidos
				oProc:cCaption := "Acertou NF: "+SF2->F2_DOC+" - "+ALLTRIM(STR(_nConta))+" / "+_cTotal+", Corregidos..."+ALLTRIM(STR(_nCorre))
				PROCESSMESSAGES()
				AADD(_aNFAux,ACLONE(_aItensNF[G]))
			EndIf
			LOOP // ************************* LOOP *****************************************************************************************
		EndIf
		cFilAnt:=SF2->F2_FILIAL
		IF _lGravaComFuncao//SIMULA GRAVACAO DA NOTA VIA FUN��O PADR�O
			IF MV_PAR07 = "1" .AND. nRecSF2 > 0//1-CALC.PED/SEG/CHEP
				_nConta++
				oProc:cCaption := "Gravando NF: "+SF2->F2_DOC+" - "+ALLTRIM(STR(_nConta))+" gravadas..."
				PROCESSMESSAGES()
				//_lGrava,_lCalcSeguro, _nPesoTotC,_nPesoSoPallet , _nTotPedagio,_nVlrCHEPTot ,_nVlrFretOL,_nPesTotOL
				U_GrvRatVlrs( .T.   , .T.        )
			ELSEIF MV_PAR07 = "2"//2-DATAS PREVISTAS
				_nConta++
				oProc:cCaption := "Gravando NF: "+SF2->F2_DOC+" - "+ALLTRIM(STR(_nConta))+" / "+_cTotal+" gravadas..."
				PROCESSMESSAGES()
				GrvTransiTime(.T.)//Grava como se fosse chamada do final da gravacao do fatuamento da nota
				//***********************************************************************************************
				IF _lLerZF5
					oProc:cCaption := "Gravando Datas ZF5 da NF: "+SF2->F2_DOC+" - "+ALLTRIM(STR(_nConta))+" / "+_cTotal+" gravadas..."
					PROCESSMESSAGES()
					LerZF5( SF2->(F2_FILIAL+F2_DOC+F2_SERIE) , .T. )//// LER E GRAVA AS DATAA DA OCORRECIAS
				ENDIF
				//***********************************************************************************************
			EndIf
			LOOP ///  *************  LOOP  **************
		EndIf
		// S� GRAVA CAMPOS REFERENTES AO TRANSIT TIME PARA ACERTO QUANDO N�O � _lGravaComFuncao
		//_dDataPENOL:=_aItensNF[G , _nPosDtOL     ]
		//_dDtPENCO  :=_aItensNF[G , _nPosDtCliente]
		//_nDiasZG5  :=_aItensNF[G , _nPosDZG5     ]
		//_nDiasZ31  :=_aItensNF[G , _nPosDZ31     ]
		//_C5_I_DTENT:=_aItensNF[G ,_nPosC5_I_DTENT]
		//_C5_I_AGEND:=_aItensNF[G ,_nPosC5I_AGEND]
		//IF !EMPTY(_dDataPENOL) .OR. !EMPTY(_dDtPENCO)
		//	SF2->(Reclock("SF2",.F.))
		//	SF2->F2_I_PENOL := _dDataPENOL // Previs�o de entrega no operador log�stico
		//	IF _C5_I_DTENT > _dDtPENCO .AND. (_C5_I_AGEND == "M" .or. _C5_I_AGEND== "A")//
		//		SF2->F2_I_PENCL:= _C5_I_DTENT // Previs�o de entrega no cliente
		//	ELSE
		//		SF2->F2_I_PENCL:= _dDtPENCO // Previs�o de entrega no cliente
		//	EndIf
		//	SF2->F2_I_TT1TR := _nDiasZG5
		//	SF2->F2_I_TT2TR := _nDiasZ31
		//	SF2->(Msunlock())
		//    //***********************************************************************************************
		//    IF _lLerZF5
		//       oProc:cCaption := "Gravando Datas ZF5 da NF: "+SF2->F2_DOC+" - "+ALLTRIM(STR(_nConta))+" / "+_cTotal+" gravadas..."
		//       PROCESSMESSAGES()
		//       LerZF5( SF2->(F2_FILIAL+F2_DOC+F2_SERIE) , .T. )//// LER E GRAVA AS DATAA DA OCORRECIAS
		//    ENDIF
		//	//***********************************************************************************************
		//	_nConta++
		//EndIf
		//oProc:cCaption := "Gravou NF: "+SF2->F2_DOC+" - "+ALLTRIM(STR(_nConta))+" / "+_cTotal+" gravadas..."
		//PROCESSMESSAGES()
	NEXT G
	IF MV_PAR07 = "3"//3-Acertos de campos
		_nConta  := _nCorre
		_aItensNF:= ACLONE(_aNFAux)
	EndIf
	cFilAnt:=_cFilSalva
	oProc:cCaption := ALLTRIM(STR(_nConta))+" Notas gravadas..."
	PROCESSMESSAGES()
	U_ITMSG("Foram gravada(s) "+ALLTRIM(STR(_nConta))+" nota(s).","PROCESSAMENTO CONCLUIDO COM SUCESSO","",2)

RETURN .t.
/*
===============================================================================================================================
Programa----------: GrvRatVlrs
Autor-------------: Alex Wallauer
Data da Criacao---: 29/02/2024
Descri��o---------: Processa a grava��o do valor do PEDAGIO / SEGURO / CHEP
Parametros--------:  _lGrava ,_lCalcSeguro  , _nPesoTotC , _nPesoSoPallet , _nTotPedagio , _nVlrCHEPTot , _nVlrFretOL, _nPesTotOL
Retorno-----------: .T.
===============================================================================================================================
*/
User Function GrvRatVlrs( _lGrava As Logical, _lCalcSeguro As Logical,  _nPesoTotC As Numeric, _nPesoSoPallet As Numeric, _nTotPedagio As Numeric, _nVlrCHEPTot As Numeric, _nVlrFretOL As Numeric, _nPesTotOL As Numeric)
	Local _aArea         :=FwGetArea() As Array
	Local _aAreaDAI      :=DAI->(FwGetArea()) As Array
	Local _aAreaSD2      :=SD2->(FwGetArea()) As Array
	Local _cDoc          := SF2->F2_DOC As Char
	Local _cSerie        := SF2->F2_SERIE As Char
	Local _cCliente      := SF2->F2_CLIENTE As Char
	Local _cLoja         := SF2->F2_LOJA As Char
	Local _nPesoNota     := SF2->F2_PBRUTO As Numeric
	Local lTemSF2Ped     := SF2->(FIELDPOS("F2_I_VLPED")) > 0 .AND. DAK->(FIELDPOS("DAK_I_VRPE")) > 0 As Logical
	Local lTemSD2Ped     := SD2->(FIELDPOS("D2_I_VLPED")) > 0 .AND. DAI->(FIELDPOS("DAI_I_VRPE")) > 0 As Logical
	Local lTemFREOL      := U_ITGETMV("IT_TEMFREOL",.T.) As Logical
	Local lTemSF2FREOL   := SF2->(FIELDPOS("F2_I_FREOL")) > 0 .AND. DAK->(FIELDPOS("DAK_I_FROL")) > 0 As Logical
	Local lTemSD2FREOL   := SD2->(FIELDPOS("D2_I_FREOL")) > 0 .AND. DAI->(FIELDPOS("DAI_I_FROL")) > 0 As Logical
	Local _nPercSeguro   := U_ITGETMV("IT_PERCSEG",0.13) As Numeric //Padr�o � 0.13% criar o parametro tipo numerico
	Local _nVlrPedagNF   := 0 As Numeric
	Local _nVlrFret2NF   := 0 As Numeric
	Local _nPSeguro      := 0 As Numeric
	Local nRecSD2        := 0 As Numeric
	Local nMaiorVlr      := 0 As Numeric
	Local nLinSD2        := 0 As Numeric
	Local nVlrPedagNFSoma:= 0 As Numeric
	Local _nRecDAI       := 0 As Numeric
	Private _cFilRDC     := "" As Char//Variaveis usadas na fun��o MontaLista ()
	Private _cCargaRDC   := "" As Char//Variaveis usadas na fun��o MontaLista ()
	DEFAULT _nTotPedagio := 0
	DEFAULT _nVlrFretOL  := 0
	IF !EMPTY(SF2->F2_CARGA) .And. (_nTotPedagio <= 0 .Or. _nVlrFretOL <= 0 )
		DAK->(Dbsetorder(1))
		If _nTotPedagio <= 0 .AND. DAK->(Dbseek(SF2->F2_FILIAL+SF2->F2_CARGA))//SE TEM CARGA
			_cFilRDC  := DAK->DAK_I_FRDC
			_cCargaRDC:= DAK->DAK_I_CARG
			DEFAULT _nPesoSoPallet := DAK->DAK_PESO // Quando s� tem pallet na carga
			IF lTemSF2Ped
				_nTotPedagio:=DAK->DAK_I_VRPE// Pedagio da CAPA para fazer o acerto
			EndIf
		EndIf
		DAI->(Dbsetorder(3))
		If _nVlrFretOL <= 0 .AND. DAI->(Dbseek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE))//SE TEM CARGA
			_nRecDAI:=DAI->(Recno())
			IF lTemSD2FREOL
				_nVlrFretOL :=DAI->DAI_I_FROL// Frete 2o percurso / Sempre o total do pedido
			EndIf
		EndIf
	Else//Quando n�o tem carga
		_nVlrPedagNF:=_nTotPedagio//quando n�o tem carga, o valor do ped�gio recebido � o mesmo da nota
	EndIf

	// ******************************
	DEFAULT _nPesoSoPallet:= 0
	DEFAULT _nVlrCHEPTot  := 0
	DEFAULT _lCalcSeguro  := .T.
	DEFAULT _nPesoTotC    := Cal2PesCarg( SF2->F2_CARGA , 1 )//EFETUA O SOMATORIO DO PESO DA CARGA SEM OS PALLET
	//DEFAULT _nPesTotOL    := IF(lTemFREOL,Cal2PesCarg( SF2->F2_CARGA,3),0)//EFETUA O SOMATORIO DO PESO DA CARGA S� DOS OPERADORES LOGISTICOS
	// ******************************

	////////// **************************** RATEIO DO PEDAGIO 1/2 **************************** //////////////////////////////////////////////////////////
	_aListNF    := {} //PREENCHE DENTRO DA FUNCAO MontaLista ()
	nPosGrvSeg  := 00 //PREENCHE DENTRO DA FUNCAO MontaLista ()
	_lSoPallets :=.F.
	_lGravaFrete:=.F.
	//SE A CARGA POSSUIR PEDIDOS DE PALLET E DE OUTROS PRODUTOS ACABADOS AS NOTAS DE PALLET NAO TERAO VALOR RATEADO
	If _nTotPedagio > 0 .AND. _nPesoTotC > 0 .AND. (lTemSF2Ped  .OR. lTemSD2Ped)//SEM PALETT

		IF _nRecDAI > 0 .And. lTemSD2Ped
			_nVlrPedagNF := 0
			DAI->(DbGoTo(_nRecDAI))
			If !EMPTY(DAI->DAI_I_VRPE)
				_nVlrPedagNF:=DAI->DAI_I_VRPE//PEGA O PEDAGIO DO PEDIDO/DAI
			EndIf
		EndIf

		// *********************************************************************************************************************
		If _nVlrPedagNF> 0 .And. Cal2PesCarg( SF2->F2_I_PEDID , 2 ) > 0 //VERIFICA SE O PEDIDO TEM ITENS VALIDOS
			// *********************************************************************************************************************

			SD2->( DBSetOrder(3) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			If lTemSD2Ped .AND. SD2->( DBSeek( xfilial("SD2") + _cDoc + _cSerie + _cCliente + _cLoja ) )
				DO While SD2->(!Eof()) .and. SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA ) == xFilial("SD2") + _cDoc + _cSerie + _cCliente + _cLoja
					_nVlrItemPedag := Round(( ( _nVlrPedagNF / _nPesoNota ) * SD2->D2_I_PTBRU) , 2)
					IF _lGrava
						SD2->( RECLOCK( "SD2" , .F. ) )
						SD2->D2_I_VLPED := _nVlrItemPedag
						SD2->( MSUNLOCK() )
						nVlrPedagNFSoma += SD2->D2_I_VLPED
					ELSE
						nVlrPedagNFSoma += _nVlrItemPedag
						MontaLista(_nVlrPedagNF ,_nPesoNota,SD2->D2_I_PTBRU,_nVlrItemPedag,_nPesoItem,SD2->D2_COD)
					EndIf
					IF _nVlrItemPedag > nMaiorVlr
						nMaiorVlr:= _nVlrItemPedag
						nRecSD2  := SD2->(RECNO())
						IF !_lGrava
							nLinSD2:= LEN(_aListNF)
						EndIf
					EndIf
					SD2->( DBSKIP() )
				EndDo
			EndIf
		ELSE
			IF !_lGrava
				SD2->( DBSetOrder(3) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				If lTemSD2Ped .AND. SD2->( DBSeek( xfilial("SD2") + _cDoc + _cSerie + _cCliente + _cLoja ) )
					MontaLista(0 ,_nPesoNota,0,0,0,"PALLET: "+SD2->D2_COD)
				EndIf
			EndIf
		EndIf

		////////// **************************** RATEIO DO PEDAGIO 2/2 **************************** //////////////////////////////////////////////////////
		//QUANDO SOMENTE PEDIDOS DE PALLET COMP�EM A CARGA                             |
	ELSEIF _nTotPedagio > 0 .AND.  (lTemSF2Ped  .OR. lTemSD2Ped)//DAI_I_VRPE / DAK_I_VRPE
		_lSoPallets:=.T.
		IF _nRecDAI > 0 .And. lTemSD2Ped
			_nVlrPedagNF := 0
			DAI->(DbGoTo(_nRecDAI))
			If !EMPTY(DAI->DAI_I_VRPE)
				_nVlrPedagNF:=DAI->DAI_I_VRPE
			EndIf
		EndIf
		SD2->( DBSetOrder(3) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		If _nVlrPedagNF > 0 .AND. SD2->( DBSeek( xfilial("SD2") + _cDoc + _cSerie + _cCliente + _cLoja ) )
			DO While SD2->(!Eof()) .and. SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA ) == xfilial("SD2") + _cDoc + _cSerie + _cCliente + _cLoja
				//_nPesoItem   := POSICIONE( "SB1" , 1 , xFilial("SB1") + SD2->D2_COD , "B1_PESBRU" )
				//_nPesoTotItem:= ( _nPesoItem * SD2->D2_QUANT )
				_nVlrItemPedag := Round(( ( _nVlrPedagNF / _nPesoNota ) * SD2->D2_I_PTBRU),2)
				IF _lGrava
					SD2->( RecLock( "SD2" , .F. ) )
					SD2->D2_I_VLPED := _nVlrItemPedag
					nVlrPedagNFSoma += SD2->D2_I_VLPED
					SD2->( MsUnlock() )
				ELSE
					nVlrPedagNFSoma += _nVlrItemPedag
					MontaLista(_nVlrPedagNF ,_nPesoNota,_nPesoTotItem,_nVlrItemPedag,_nPesoItem,"PALLET: "+SD2->D2_COD)
				EndIf
				IF _nVlrItemPedag > nMaiorVlr
					nMaiorVlr:= _nVlrItemPedag
					nRecSD2  := SD2->(RECNO())
					IF !_lGrava
						nLinSD2:= LEN(_aListNF)
					EndIf
				EndIf
				SD2->( DBSkip() )
			EndDo
		EndIf

	EndIf

	IF lTemSF2Ped .AND. _nVlrPedagNF > 0 .AND. nVlrPedagNFSoma > 0
		IF nVlrPedagNFSoma > 0 .AND. nVlrPedagNFSoma <> _nVlrPedagNF
			_nDif:=(nVlrPedagNFSoma-_nVlrPedagNF)
			IF _lGrava
				SD2->(DBGOTO(nRecSD2))
				SD2->( RECLOCK( "SD2" , .F. ) )
				SD2->D2_I_VLPED := (SD2->D2_I_VLPED - _nDif)
				SD2->( MSUNLOCK() )
			ELSE
				_aListNF[nLinSD2,_nPosItemPed]:=(_aListNF[nLinSD2,_nPosItemPed] - _nDif)
			EndIf
		EndIf
		IF _lGrava
			SF2->( RecLock( "SF2" , .F. ) )
			SF2->F2_I_VLPED := _nVlrPedagNF
			SF2->( MsUnlock() )
		EndIf
	EndIf

	////////// **************************** RATEIO DO FRETE DO OPERADOR 2o percurso **************************** //////////////////////////////////////////////////////////
	nPosGrvFret:= 0 //PREENCHE DENTRO DA FUNCAO MontaLista ()
	//Se a carga possuir pedidos de PALLET e de outros produtos acabados as notas de PALLET nao terao valor rateado
	If lTemFREOL  .AND. _nVlrFretOL > 0  .AND. (lTemSF2FREOL  .OR. lTemSD2FREOL)  //SEM PALETT

		// *****************************************************************************************************
		//VERIFICA SE O PEDIDO TEM ITENS VALIDOS E DE OPERADOR  e //DAK_I_FROL / DAI_I_FROL CAMPO NOVO
		If _nVlrFretOL > 0 //Cal2PesCarg( SF2->F2_I_PEDID , 4 ) > 0
			// *****************************************************************************************************

			nVlrFreteNFSoma:=0
			_nVlrFret2NF := _nVlrFretOL //Esse valor sempre � o total da nota / pedido
			SD2->( DBSetOrder(3) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			If lTemSD2Ped .AND. SD2->( DBSeek( xfilial("SD2") + _cDoc + _cSerie + _cCliente + _cLoja ) )
				DO While SD2->(!Eof()) .and. SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA ) == xFilial("SD2") + _cDoc + _cSerie + _cCliente + _cLoja
					nVlrItemFrete := Round( ( ( _nVlrFret2NF / _nPesoNota ) * SD2->D2_I_PTBRU) ,2)
					IF _lGrava
						IF lTemSD2FREOL
							SD2->( RECLOCK( "SD2" , .F. ) )
							SD2->D2_I_FREOL := nVlrItemFrete
							SD2->( MSUNLOCK() )
							nVlrFreteNFSoma += SD2->D2_I_FREOL
						EndIf
					ELSE
						nVlrFreteNFSoma += nVlrItemFrete
						_lGravaFrete:=.T.
						MontaLista( 0           ,_nPesoNota    ,_nPesoTotItem,0           ,_nPesoItem,SD2->D2_COD,               ,          ,         ,                                                           ,_nVlrFret2NF,nVlrItemFrete)
					EndIf
					IF nVlrItemFrete > nMaiorVlr
						nMaiorVlr:= nVlrItemFrete
						nRecSD2  := SD2->(RECNO())
						IF !_lGrava
							nLinSD2:= LEN(_aListNF)
						EndIf
					EndIf
					SD2->( DBSKIP() )
				EndDo
			EndIf
		ELSE
			IF !_lGrava
				SD2->( DBSetOrder(3) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				If lTemSD2Ped .AND. SD2->( DBSeek( xfilial("SD2") + _cDoc + _cSerie + _cCliente + _cLoja ) )
					MontaLista(0 ,_nPesoNota,0,0,0,"PALLET: "+SD2->D2_COD)
				EndIf
			EndIf
		EndIf
        //** ACERTO DO FRETE 2o PERCURSO **//
		IF _nVlrFret2NF > 0 .AND. nVlrFreteNFSoma > 0
			IF nVlrFreteNFSoma > 0 .AND. nVlrFreteNFSoma <> _nVlrFret2NF
				_nDif:=(nVlrFreteNFSoma-_nVlrFret2NF)
				IF _lGrava
					IF lTemSD2FREOL
						SD2->(DBGOTO(nRecSD2))
						SD2->( RECLOCK( "SD2" , .F. ) )
						SD2->D2_I_FREOL := (SD2->D2_I_FREOL - _nDif)
						SD2->( MSUNLOCK() )
					EndIf
				ELSE
					_aListNF[nLinSD2,nPosITFret]:=(_aListNF[nLinSD2,nPosITFret] - _nDif)
				EndIf
			EndIf
			IF _lGrava .AND. lTemSF2FREOL
				SF2->( RecLock( "SF2" , .F. ) )
				SF2->F2_I_FREOL := _nVlrFret2NF
				SF2->( MsUnlock() )
			EndIf
		EndIf
	EndIf

	////////// **************************** CALCULO DO SEGURO ************************************** ////////////////////////////////////////////////////////
	IF  _lCalcSeguro .AND. SC5->C5_I_OPER <> "05" .AND. !(SC5->C5_I_TRCNF == "S" .AND. SC5->C5_I_OPER <> "20")

		nRecSD2      :=0
		nMaiorVlr    :=0
		nLinSD2      :=0
		nVlrSomaSeguro:=0
		SD2->( DBSetOrder(3) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		If SD2->( DBSeek( xfilial("SD2") + _cDoc + _cSerie + _cCliente + _cLoja ) )

			IF VALTYPE(_nPercSeguro) <> "N" .OR. EMPTY(_nPercSeguro)
				_nPercSeguro:=0.13/100
			ELSE
				_nPercSeguro:=(_nPercSeguro/100)
			EndIf

			_nPerTransp := Posicione('ZGX',1,xFilial("ZGX")+SF2->F2_FILIAL+SF2->F2_I_CTRA+SF2->F2_I_LTRA,'ZGX_PERSEG')
			If ! Empty(_nPerTransp)
				_nPSeguro := (_nPerTransp/100)
			Else
				_nPSeguro := _nPercSeguro
			EndIf

			_nVlrSegNF := (_nPSeguro * SF2->F2_VALBRUT)
			_cGrpUnit  :=GetMV( "IT_GRPUNIT",,"0813")

			DO While SD2->(!Eof()) .and. SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA ) == xfilial("SD2") + _cDoc + _cSerie + _cCliente + _cLoja
				_nVlrSegItem :=  Round( (_nPSeguro * SD2->D2_VALBRUT) , 2)
				IF _lGrava
					SD2->( RecLock( "SD2" , .F. ) )
					SD2->D2_I_VLSEG:= _nVlrSegItem
					nVlrSomaSeguro += SD2->D2_I_VLSEG
					SD2->( MsUnlock() )
				ELSE
					_lCHEP := POSICIONE( "SB1" , 1 , xFilial("SB1") + SD2->D2_COD , "B1_GRUPO" )	$  _cGrpUnit  //GRUPOS UNITIZADORES
					nVlrSomaSeguro += _nVlrSegItem
					MontaLista(,,,,,IF(_lCHEP,"CHEP: ","")+SD2->D2_COD,SD2->D2_VALBRUT,_nVlrSegItem,_nPSeguro,"")
				EndIf
				IF _nVlrSegItem > nMaiorVlr
					nMaiorVlr:= _nVlrSegItem
					IF _lGrava
						nRecSD2:= SD2->( RECNO() )
					ELSE
						nLinSD2:= LEN(_aListNF)
					EndIf
				EndIf
				SD2->( DBSkip() )
			EndDo
            
			_nVlrSegNF:=nVlrSomaSeguro//Por enquanto o valor do seguro da capa � o mesmo da soma dos itens
			
			IF nVlrSomaSeguro > 0 .AND. nVlrSomaSeguro <> _nVlrSegNF
				_nDif:=(nVlrSomaSeguro-_nVlrSegNF)
				IF _lGrava
					SD2->(DBGOTO(nRecSD2))
					SD2->( RECLOCK( "SD2" , .F. ) )
					SD2->D2_I_VLSEG := (SD2->D2_I_VLSEG - _nDif)
					SD2->( MSUNLOCK() )
				ELSE
					_aListNF[nLinSD2,nPosGrvSeg]:=(_aListNF[nLinSD2,nPosGrvSeg] - _nDif)
				EndIf
			EndIf
			IF _lGrava
				SF2->( RecLock( "SF2" , .F. ) )
				SF2->F2_I_VLSEG := _nVlrSegNF
				SF2->( MsUnlock() )
			EndIf

		EndIf

	EndIf

	IF _lCalcSeguro .AND. !_lGrava
		MontaLista(_nTotPedagio,_nPesoSoPallet,_nPesoNota,_nVlrPedagNF,0,"CAPA NF:",SF2->F2_VALBRUT,_nVlrSegNF,_nPSeguro,xFilial("ZGX")+SF2->F2_FILIAL+SF2->F2_I_CTRA+SF2->F2_I_LTRA,_nVlrFretOL,_nVlrFret2NF)
	EndIf

	FwRestArea(_aAreaDAI)
	FwRestArea(_aAreaSD2)
	FwRestArea(_aArea   )

Return _aListNF //PREENCHE DENTRO DA FUNCAO MontaLista ()

/*
==================================================================================================================================
Programa--------: M460Acertos
Autor-----------: Alex Wallauer
Data da Criacao-: 11/03/2024
Descri��o-------: FUNCAO USADA NO P.E. M460NOTA.PRW
Parametros------: lGrava
Retorno---------: .T.
==================================================================================================================================*/
USER FUNCTION M460Acertos(lGrava As Logical)
 Local P            :=0 As Numeric
 Local _cCarga      :="" As Char
 Local nMaiorVlr    :=0 As Numeric
 Local nLinha       :=0 As Numeric
 Local nVlrSomaPedag:=0 As Numeric
 Local nVlrSomaFrete:=0 As Numeric
 Local lTemFREOL    := .F. As Logical

 if LEN(_AcertoPedagio) = 0 .AND. LEN(_AcertoFreteOL) = 0
    RETURN .T.
 EndIf

 lTemFREOL:= U_ITGETMV("IT_TEMFREOL",.F.)

 FOR P := 1 TO LEN(_AcertoPedagio)

    IF EMPTY(_cCarga)
       _cCarga:=_AcertoPedagio[P,1]
    EndIf

     IF _AcertoPedagio[P,1] = _cCarga
        nVlrSomaPedag+=_AcertoPedagio[P,3]
        IF _AcertoPedagio[P,3] > nMaiorVlr
           nMaiorVlr:= _AcertoPedagio[P,3]
           nLinha   := P
        EndIf
     ELSE
       IF nVlrSomaPedag <> _AcertoPedagio[nLinha,2]

          _nDif:=(nVlrSomaPedag-_AcertoPedagio[nLinha,2])

          IF lGrava
             SD2->(DBGOTO(_AcertoPedagio[nLinha,5]))
             SD2->( RECLOCK( "SD2" , .F. ) )
             SD2->D2_I_VLPED := (SD2->D2_I_VLPED - _nDif)
             SD2->( MSUNLOCK() )
          ELSE
             IF (nPos:=ASCAN(_aItensNF, {|N| N[LEN(N)] = _AcertoPedagio[nLinha,5] .AND. N[_nPosProd] <> "CAPA NF:" })) <> 0
                _aItensNF[nPos,_nPosProd   ]:=ALLTRIM(_aItensNF[nPos,_nPosProd])+" (A)"
                _aItensNF[nPos,_nPosPedNF  ]:=(_aItensNF[nPos,_nPosPedNF  ] - _nDif)
                _aItensNF[nPos,_nPosItemPed]:=(_aItensNF[nPos,_nPosItemPed] - _nDif)
             EndIf
          EndIf
       EndIf
       _cCarga  :=_AcertoPedagio[P,1]
       _nVlrNF  :=0
       nMaiorVlr:=0
       nVlrSomaPedag:=0
       nVlrSomaPedag:=_AcertoPedagio[P,3]
       IF _AcertoPedagio[P,3] > nMaiorVlr
          nMaiorVlr:= _AcertoPedagio[P,3]
          nLinha   := P
       EndIf
     EndIf

 NEXT P

 IF nLinha > 0 .AND. nVlrSomaPedag <> _AcertoPedagio[nLinha,2]
    _nDif:=(nVlrSomaPedag-_AcertoPedagio[nLinha,2])

    IF lGrava
       SD2->(DBGOTO(_AcertoPedagio[nLinha,5]))
       SD2->( RECLOCK( "SD2" , .F. ) )
       SD2->D2_I_VLPED := (SD2->D2_I_VLPED - _nDif)
       SD2->( MSUNLOCK() )
    ELSE
       IF (nPos:=ASCAN(_aItensNF, {|N| N[LEN(N)] = _AcertoPedagio[nLinha,5] .AND. N[_nPosProd] <> "CAPA NF:" })) <> 0
          _aItensNF[nPos,_nPosProd   ]:=ALLTRIM(_aItensNF[nPos,_nPosProd])+" (A)"
          _aItensNF[nPos,_nPosPedNF  ]:=(_aItensNF[nPos,_nPosPedNF  ] - _nDif)
          _aItensNF[nPos,_nPosItemPed]:=(_aItensNF[nPos,_nPosItemPed] - _nDif)
       EndIf
    EndIf
 EndIf

 IF lTemFREOL
    _cCarga  :=""
    nMaiorVlr:=0
    nLinha   :=0

    FOR P := 1 TO LEN(_AcertoFreteOL)

       IF EMPTY(_cCarga)
          _cCarga:=_AcertoFreteOL[P,1]
       EndIf

        IF _AcertoFreteOL[P,1] = _cCarga
           nVlrSomaFrete+=_AcertoFreteOL[P,3]
           IF _AcertoFreteOL[P,3] > nMaiorVlr
              nMaiorVlr:= _AcertoFreteOL[P,3]
              nLinha   := P
           EndIf
        ELSE
          IF nVlrSomaFrete <> _AcertoFreteOL[nLinha,2]

             _nDif:=(nVlrSomaFrete-_AcertoFreteOL[nLinha,2])

             IF lGrava
                IF lTemSD2FREOL
                   SD2->(DBGOTO(_AcertoFreteOL[nLinha,5]))
                   SD2->( RECLOCK( "SD2" , .F. ) )
                   SD2->D2_I_FREOL := (SD2->D2_I_FREOL - _nDif)
                   SD2->( MSUNLOCK() )
                EndIf
             ELSE
                IF (nPos:=ASCAN(_aItensNF, {|N| N[LEN(N)] = _AcertoFreteOL[nLinha,5] .AND. N[_nPosProd] <> "CAPA NF:" })) <> 0
                   _aItensNF[nPos,_nPosProd ]:=ALLTRIM(_aItensNF[nPos,_nPosProd])+" (A)"
                   _aItensNF[nPos,nPosNFFret]:=(_aItensNF[nPos,nPosNFFret] - _nDif)
                   _aItensNF[nPos,nPosITFret]:=(_aItensNF[nPos,nPosITFret] - _nDif)
                EndIf
             EndIf
          EndIf
          _cCarga  :=_AcertoFreteOL[P,1]
          _nVlrNF  :=0
          nMaiorVlr:=0
          nVlrSomaFrete:=0
          nVlrSomaFrete:=_AcertoFreteOL[P,3]
          IF _AcertoFreteOL[P,3] > nMaiorVlr
             nMaiorVlr:= _AcertoFreteOL[P,3]
             nLinha   := P
          EndIf
        EndIf

    NEXT P

    IF nLinha > 0 .AND. nVlrSomaFrete <> _AcertoFreteOL[nLinha,2]
       _nDif:=(nVlrSomaFrete-_AcertoFreteOL[nLinha,2])

       IF lGrava .AND. lTemSF2FREOL
          SD2->(DBGOTO(_AcertoFreteOL[nLinha,5]))
          SD2->( RECLOCK( "SD2" , .F. ) )
          SD2->D2_I_FREOL := (SD2->D2_I_FREOL - _nDif)
          SD2->( MSUNLOCK() )
        ELSE
          IF (nPos:=ASCAN(_aItensNF, {|N| N[LEN(N)] = _AcertoFreteOL[nLinha,5] .AND. N[_nPosProd] <> "CAPA NF:" })) <> 0
             _aItensNF[nPos,_nPosProd ]:=ALLTRIM(_aItensNF[nPos,_nPosProd])+" (A)"
             _aItensNF[nPos,nPosNFFret]:=(_aItensNF[nPos,nPosNFFret] - _nDif)
             _aItensNF[nPos,nPosITFret]:=(_aItensNF[nPos,nPosITFret] - _nDif)
          EndIf
       EndIf
    EndIf
 EndIf

 IF lGrava
   _AcertoPedagio:={}
   _AcertoFreteOL:={}
 EndIf

RETURN .T.
/*
===============================================================================================================================
Programa----------: MontaLista ()
Autor-------------: Alex Wallauer
Data da Criacao---: 29/02/2024
Descri��o---------: Processa a grava��o do valor do PEDAGIO / SEGURO / CHEP
Parametros--------: _nVlrPedagNF ,_nPesoNota,_nPesoTotItem,_nVlrItemPedag,_nPesoItem,_cProd,_nVlrBruto,_nVlrSeguro,_nPSeguro,cChavZGX,_nVlrFret2NF,nVlrItemFrete
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MontaLista(_nVlrPedagNF ,_nPesoNota,_nPesoTotItem,_nVlrItemPedag,_nPesoItem,_cProd,_nVlrBruto,_nVlrSeguro,_nPSeguro,cChavZGX,_nVlrFret2NF,nVlrItemFrete)

	Local _aItem:={}

	AADD(_aItem,!_lSoPallets)
	AADD(_aItem,SF2->F2_FILIAL)
	AADD(_aItem,SF2->F2_CARGA)
	AADD(_aItem,_cFilRDC  )
	AADD(_aItem,_cCargaRDC)
	AADD(_aItem,SF2->F2_DOC)
	AADD(_aItem,SF2->F2_SERIE)
	AADD(_aItem,SF2->F2_TIPO)
	AADD(_aItem,SF2->F2_EMISSAO)
	AADD(_aItem,_cProd);       ; _nPosProd :=LEN(_aItem)
	AADD(_aItem,_nPesoItem)
	AADD(_aItem,_nVlrPedagNF)  ; _nPosPedNF:=LEN(_aItem)
	AADD(_aItem,_nPesoNota)
	AADD(_aItem,_nPesoTotItem)
	AADD(_aItem,_nVlrItemPedag); _nPosItemPed:=LEN(_aItem)
	AADD(_aItem,_nVlrBruto)
	AADD(_aItem,_nPSeguro)
	AADD(_aItem,_nVlrSeguro)   ; nPosGrvSeg:=LEN(_aItem)
	AADD(_aItem,_nVlrFret2NF)  ; nPosNFFret:=LEN(_aItem)
	AADD(_aItem,nVlrItemFrete) ; nPosITFret:=LEN(_aItem)
	AADD(_aItem,SF2->F2_I_OPER)
	AADD(_aItem,SF2->F2_I_REDP)
	IF _cProd == "CAPA NF:"
		AADD(_aItem,SF2->F2_I_FRET)
	ELSEIF _lGravaFrete
		AADD(_aItem,SD2->D2_I_FRET)
		_lGravaFrete:=.F.
	ELSE
		AADD(_aItem,0)
	ENDIF
	AADD(_aItem,cChavZGX)

	IF _cProd == "CAPA NF:"
		AADD(_aItem,SF2->(RECNO()))// N�o mudar de possicao , colocar campos novos antes dessa coluna
	ELSE
		AADD(_aItem,SD2->(RECNO()))// N�o mudar de possicao , colocar campos novos antes dessa coluna
	ENDIF

	AADD(_aListNF,_aItem)

RETURN

/*
===============================================================================================================================
Programa----------: Cal2PesCarg
Autor-------------: Alex Wallauer
Data da Criacao---: 19/03/2014
Descri��o---------: Funcao que soma o peso total da carga desconsiderando Produtos Unitizadores do Pallet
Parametros--------: _cCodigo - C�digo da Carga/Pedido
------------------: _nTipo	 - 1 = Peso Total da Carga / 2 = Peso Total do Pedido / 3 e 4 - Operador Logistico
Retorno-----------: _nPesoTot- Peso total calculado
===============================================================================================================================
*/
STATIC Function Cal2PesCarg( _cCodigo , _nTipo )
	Local _oAliasPes:= GetNextAlias()
	Local _cQuery	 := ""
	Local _cGrpUnit := GetMV( "IT_GRPUNIT" ,, "0813" )
	Local _nPesoTot := 0
	Local _aArea	 := GetArea()
	IF EMPTY(SF2->F2_CARGA)
		RETURN 1 // Devolve um valor diferente de zero para continuar o processamento
	ENDIF
	//N�o coloquei o DAI_PESO pq � a somatorioa dos itens do pedido
	_cQuery += " SELECT SUM(PESOTOTAL) PESTOTAL FROM ( SELECT "
	_cQuery += " CASE WHEN  SC6.C6_I_PTBRU > 0  "
	_cQuery += "      THEN  SC6.C6_I_PTBRU "
	_cQuery += "      ELSE  COALESCE( ( SB1.B1_PESBRU * SC6.C6_QTDVEN ) , 0 ) END PESOTOTAL  "
	_cQuery += " FROM " + RetSqlName("DAI") + " DAI "
	_cQuery += " JOIN " + RetSqlName("SC6") + " SC6 ON DAI.DAI_PEDIDO = SC6.C6_NUM AND DAI.DAI_FILIAL = SC6.C6_FILIAL "
	_cQuery += " JOIN " + RetSqlName("SB1") + " SB1 ON SC6.C6_PRODUTO = SB1.B1_COD "
	_cQuery += " WHERE "
	_cQuery += " 		DAI.D_E_L_E_T_	= ' ' "
	_cQuery += " AND	SC6.D_E_L_E_T_	= ' ' "
	_cQuery += " AND	SB1.D_E_L_E_T_	= ' ' "
	_cQuery += " AND	SB1.B1_GRUPO NOT IN "+ FormatIn( _cGrpUnit , ";" ) //EXCLUI GRUPOS UNITIZADORES SEMPRE
	_cQuery += " AND	DAI.DAI_FILIAL	= '" + XFILIAL("DAI") + "' "
	_cQuery += " AND	SC6.C6_FILIAL	= '" + XFILIAL("SC6") + "' "
	If _nTipo == 3 .OR. _nTipo == 4//Efetua o somatorio do peso total s� dos pedidos com operador logistico
		_cQuery += " AND	(DAI_I_OPLO <> ' ' OR DAI_I_TRED	<> ' ') "
	ENDIF
	If _nTipo == 1 .OR. _nTipo == 3//Efetua o somatorio do peso total da Carga
		_cQuery += " AND	DAI.DAI_COD		= '"+ _cCodigo +"' "
	ElseIf _nTipo == 2 .OR. _nTipo == 4 //Efetua o somatorio do Peso do Pedido
		_cQuery += " AND	SC6.C6_NUM		= '" + _cCodigo + "'"
	EndIf
	_cQuery += " ) "//Fechamento DA SUB-QUERY
	MPSysOpenQuery( _cQuery , _oAliasPes)
	If (_oAliasPes)->(!Eof())
		_nPesoTot := (_oAliasPes)->PESTOTAL
	EndIf
	(_oAliasPes)->( DBCloseArea() )
	RestArea( _aArea )

Return( _nPesoTot )

/*
===============================================================================================================================
Programa----------: LerZF5
Autor-------------: Alex Wallauer
Data da Criacao---: 12/07/2024
Descri��o---------: Funcao que serve para atualizar o sf2 de acordo com as ocorrecias
Parametros--------: _cChaveSF2 = ZF5_FILIAL+ZF5_DOCOC+ZF5_SEROC, lGrava
Retorno-----------: .T. ou .F.
===============================================================================================================================
*/
STATIC Function LerZF5( _cChaveSF2 , lGrava )
	Local _lRet    As Logical
	Local _nRecSF2 As Numeric
	Local _aREcZF5 As Array

	_nRecSF2    := SF2->(RECNO())
	_aREcZF5    := {}
	_lRet       := .F.
	//Variaveis Privates inicalizadas antes dessa fun��o e preenchidas na fun��o U_AOMS3DTSF2 ()
	_dTADtPENCO :=""
	_dTADtTTUCOP:=""
	_dTADtTTEOPC:=""
	_dTBDtTTEOPC:=""
	_dTCDtTTEOPC:=""
	_cOcorrencia:=""
	_cOcorDepois:=""
	_dDtLTipoA  := CTOD("")
	_dDtLTipoB  := CTOD("")
	_dDtLTipoC  := CTOD("")
	_dDtLTipoD  := CTOD("")
	_dDtLTipoE  := CTOD("")
	_dDtLTipoF  := CTOD("")

	ZF5->(dbSetOrder(1))
	If ZF5->(dbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE))

		DO WHILE ZF5->(!EOF()) .AND. SF2->F2_FILIAL == ZF5->ZF5_FILIAL;
				.AND. SF2->F2_DOC    == ZF5->ZF5_DOCOC;
				.AND. SF2->F2_SERIE  == ZF5->ZF5_SEROC
			_cDtTran    := Posicione("ZFC",1,xFilial("ZFC")+ZF5->ZF5_TIPOO,"ZFC_DTTRAN") // 1 = ZFC_FILIAL+ZFC_CODIGO
			_cOcorrencia+="{ [Atu: "+ZF5->ZF5_DTATUA+"] "
			_cOcorrencia+="[Tipo: "+_cDtTran+"] "
			_cOcorrencia+="[Data: "+DTOC(ZF5->ZF5_DTOCOR)+"] "
			//_cOcorrencia+="[Sts: "+ZF5->ZF5_STATUS+"] "
			_cOcorrencia+="[Est: "+ZF5->ZF5_ESTONO+"]} "
			AADD(_aREcZF5,ZF5->(RECNO()) )
			ZF5->(DBSKIP())
		ENDDO

	ElseIF lGrava

		SC5->(DBSetOrder(1))
		SC5->(DbSeek(xfilial("SC5")+SF2->F2_I_PEDID))
		IF SC5->C5_I_OPER <> "05" .AND. !(SC5->C5_I_TRCNF == "S" .AND. SC5->C5_I_OPER = "20")//05 FATURAMENTO // 20 CARREGAMENTO da Troca NF
			SF2->(Reclock("SF2",.F.))
			SF2->F2_I_DCHOL := CTOD("") // Data de chegada no operador log�stico
			SF2->F2_I_DENOL := CTOD("") // Data de entrega no operador log�stico  EDI // pode ser editado.
			SF2->F2_I_DCHCL := CTOD("") // Data de chegada no cliente
			SF2->F2_I_DENCL := CTOD("") // Data de entrega no cliente
			SF2->(Msunlock())
		EndIf
		U_ReplDatasTransTime( SF2->(RECNO()) ,.T.)

	EndIf

	IF LEN(_aREcZF5) > 0
		_lRet :=.T.
		_cOcorrencia:="("+(STRZERO(LEN(_aREcZF5),2))+")=> "+_cOcorrencia
		IF lGrava
			U_AOMS3DTSF2("M460FIM_GRAVA",_aREcZF5,,.T.)//FUN��O CHAMADA NO AOMS074/72 TB E ESTA NO AOMS003.PRW
		ELSE
			U_AOMS3DTSF2("M460FIM_LER"  ,_aREcZF5)//FUN��O CHAMADA NO AOMS074/72 TB E ESTA NO AOMS003.PRW
		ENDIF
		_cOcorDepois:=""
		ZF5->(dbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE))
		DO WHILE ZF5->(!EOF()) .AND. SF2->F2_FILIAL == ZF5->ZF5_FILIAL;
				.AND. SF2->F2_DOC    == ZF5->ZF5_DOCOC;
				.AND. SF2->F2_SERIE  == ZF5->ZF5_SEROC
			_cDtTran    := Posicione("ZFC",1,xFilial("ZFC")+ZF5->ZF5_TIPOO,"ZFC_DTTRAN") // 1 = ZFC_FILIAL+ZFC_CODIGO
			_cOcorDepois+="{ [Atu: "+ZF5->ZF5_DTATUA+"] "
			_cOcorDepois+="[Tipo: "+_cDtTran+"] "
			_cOcorDepois+="[Data: "+DTOC(ZF5->ZF5_DTOCOR)+"] "
			//_cOcorDepois+="[Sts: "+ZF5->ZF5_STATUS+"] "
			_cOcorDepois+="[Est: "+ZF5->ZF5_ESTONO+"]} "
			AADD(_aREcZF5,ZF5->(RECNO()) )
			ZF5->(DBSKIP())
		ENDDO
		SF2->(DBGOTO(_nRecSF2))
	ENDIF

RETURN _lRet

/*
===============================================================================================================================
Programa----------: DescTetraS
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 31/07/2024
Descri��o---------: Gera movimento interno para retornar o valor do desconto TetraPak do produto
Parametros--------: nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function DescTetraS()

	Local _aCab	:= {}
	Local _aItem 	:= {}
	Local _aTotItem:= {}
	Local _cTM		:= SuperGetMV("IT_TMTETRE",.F.,"495")
	Local _cAlias	:= GetNextAlias()
	Local _cCFOPS	:= "% AND D2_CF IN "+ FormatIn( AllTrim(SuperGetMV("IT_CFTETRS",.F.,"6201/5201")),'/') + "%"

	Private lMsErroAuto := .F.
	_aCab := {{"D3_TM" ,_cTM , NIL},;
		{"D3_EMISSAO" ,ddatabase, NIL}}

	BeginSql alias _cAlias
     SELECT D2_COD, D2_ITEM, D2_Local, D2_CONTA, D2_NUMLOTE, D2_LOTECTL, D2_DTVALID, D2_POTENCI,
     D2_CUSTO1*(ZM5_AVD+ZM5_QSR+ZM5_SDESN+ZM5_LAD+ZM5_APD+ZM5_CTD)/100 VALOR
     FROM %Table:SD2% SD2, %Table:ZM5% ZM5, %Table:SD1% SD1
     WHERE SD2.D_E_L_E_T_ = ' '
     AND SD1.D_E_L_E_T_ = ' '
     AND ZM5.D_E_L_E_T_ = ' '
     AND D1_FILIAL = D2_FILIAL
     AND D1_DOC = D2_NFORI
     AND D1_SERIE = D2_SERIORI
     AND D1_ITEM = D2_ITEMORI
     AND D1_FORNECE = D2_CLIENTE
     AND D1_LOJA = D2_LOJA
     AND ZM5_FILIAL = %XFilial:ZM5%
     %exp:_cCFOPS%
     AND D2_COD = ZM5_PRODUT
     AND D2_FILIAL = %XFilial:SD2%
     AND D2_DOC = %exp:SF2->F2_DOC%
     AND D2_SERIE = %exp:SF2->F2_SERIE%
     AND D1_EMISSAO BETWEEN ZM5_DTINI AND ZM5_DTFIM
 ORDER BY D2_ITEM
	EndSql

	While !(_cAlias)->(EOF())
		If (_cAlias)->VALOR > 0
			//N�o informar dados do lote
			//AJUDA:A240QLZERO - N�o � permitida a digita��o do Lote/Sublote quando a quantidade for zero.
			_aItem := {{"D3_COD",		(_cAlias)->D2_COD	, NIL },;
				{"D3_Local",	(_cAlias)->D2_Local	, NIL },;
				{"D3_CONTA",	(_cAlias)->D2_CONTA	, NIL },;
				{"D3_CUSTO1",	(_cAlias)->VALOR	, NIL },;
				{"D3_CHAVEF2",	SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)+(_cAlias)->(D2_COD+D2_ITEM), nil },;
				{"D3_I_ORIGE",	"DESCTETRAS", nil } }
			aadd(_aTotItem,_aItem)
		EndIf
		(_cAlias)->(DBSkip())
	EndDo

	If Len(_aTotItem ) > 0
		MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab,_aTotItem,3)

		If lMsErroAuto
			FWAlertError("Erro ao gerar movimento interno referente ao desconto Tetra Pak. Exclua o documento faturado.","M460FIM01")
			Mostraerro()
		EndIf
	EndIf
	(_cAlias)->(DBCloseArea())

Return


/*
===============================================================================================================================
Programa----------: ValDados
Autor-------------: Alex Wallauer
Data da Criacao---: 14/06/2016
Descri��o---------: Funcao pra validar o Transportadora de redespacho e Operador Logistico
Parametros--------: cChamada: origem
Retorno-----------: _lRet - Verdadeiro se os valores informados estiverem consistentes
===============================================================================================================================
*/
Static Function ValDados(cChamada)

	IF cChamada == "OPERADOR"//ARRUMO A VARIAVEIS DA TELA PQ O F3 devolve codigo+loja na _cOpPed
		IF LEN(ALLTRIM(_cOpPed)) > LEN(DAK->DAK_I_OPER)
			_cOpLja:=ALLTRIM(SUBSTR(_cOpPed, LEN(DAK->DAK_I_OPER)+1, 4 ))
		ENDIF
		_cOpPed:=LEFT(_cOpPed,LEN(DAK->DAK_I_OPER))
		IF EMPTY(_cOpPed)
			_cOpPed:=Space(LEN(DAK->DAK_I_OPER))
			_cOpLja:=Space(LEN(DAK->DAK_I_OPLO))
			_nVlrFretOL:=0
		ELSEIf SA2->(DBSEEK(xFilial()+(_cOpPed+_cOpLja)))
			If SA2->A2_I_CLASS # "T"  .OR. SA2->A2_MSBLQL # "2"
				u_itmsg( "C�digo invalido","Valida��o operador",'C�digo: '+_cOpPed+' n�o � do tipo operador ('+SA2->A2_I_CLASSL+') ou esta bloqueado ('+SA2->A2_MSBLQL+")",1)
				RETURN .F.
			EndIf
		ELSE
			u_itmsg( "C�digo invalido","Valida��o operador", "Codigo: "+_cOpPed+" do operador nao cadastrado",1)
			RETURN .F.
		EndIf

	ElseIF cChamada == "FRETE1"
		IF !Positivo(_nVlrTotFret)
			Return .F.
		ENDIF
		If _nVlrTotFret > SF2->F2_VALMERC
			u_itmsg( "Valor do Frete 1o Percurso deve ser menor que o valor da mercadoria da Nota: "+ALLTRIM(TRANSFORM(SF2->F2_VALMERC,"@E 999,999,999.99")),"Valida��o do Frete 1o Percurso",,1)
			RETURN .F.
		EndIf
	ElseIF cChamada == "FRETE2"
		IF !Positivo(_nVlrFretOL)
			Return .F.
		ENDIF
		If _nVlrFretOL > SF2->F2_VALMERC
			u_itmsg( "Valor do Frete 2o Percurso deve ser menor que o valor da mercadoria da Nota: "+ALLTRIM(TRANSFORM(SF2->F2_VALMERC,"@E 999,999,999.99")),"Valida��o do Frete 2o Percurso",,1)
			RETURN .F.
		EndIf
	ElseIF cChamada == "PEDAGIO"
		IF !Positivo(_nVlrPedagio)
			Return .F.
		ENDIF
		If _nVlrPedagio > SF2->F2_VALMERC
			u_itmsg( "Valor do Pedagio deve ser menor que o valor da mercadoria da Nota: "+ALLTRIM(TRANSFORM(SF2->F2_VALMERC,"@E 999,999,999.99")),"Valida��o do Pedagio",,1)
			RETURN .F.
		EndIf
	ENDIF

RETURN .T.
