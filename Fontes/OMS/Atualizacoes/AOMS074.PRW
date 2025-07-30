/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 18/07/2024 | Chamado 47924. Jerry. Correção na gravação do DA3 para fazer com Begin / End Transaction.
Alex Wallauer | 22/07/2024 | Chamado 47942. Vanderlei. Ajustes na gravacao das Previsões de entrega via ocorrecia. Parte 1.
Lucas Borges  | 22/04/2025 | Chamado 50505. Alterada a picture do CNPJ para contemplar campo alfanumérico
Lucas Borges  | 23/07/2025 | Chamado 51340. Ajustar função para validação de ambiente de teste
===============================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==================================================================================================================================================================================================================
Jerry    - Alex Wallauer - 16/08/24 - 15/10/24 -  47942  - Colocada a gravacao das Previsões de entrega (U_AOMS3DTSF2) da ocorrecia da Parte 2.
Bremmer  - Alex Wallauer - 09/10/24 - 15/10/24 -  48795  - Tratamento para o novo parâmetro IT_NAGEND: TP Entrega = C5_I_AGEND $ P=Aguardando Agenda; R=Reagendar; N=Reagendar com Multa.
Bremmer  - Igor Melgaço  - 29/10/24 - 08/11/24 -  48795  - Tratamento para produtos com arredondamento na terceira casa decimal.
Bremmer  - Alex Wallauer - 08/11/24 - 08/11/24 -  49080  - Ajustes do Tratamento do parâmetro IT_NAGEND: TP Entrega = C5_I_AGEND $ P=Aguardando Agenda; R=Reagendar; N=Reagendar com Multa.
Jerry    - Alex Wallauer - 11/11/24 - 12/11/24 -  49116  - Ajustes do Tratamento para produtos com arredondamento na terceira casa decimal.
Jerry    - Alex Wallauer - 28/11/24 - 20/03/25 -  49126  - Retirado o controle da variavel _lObsSF2 da gravacao do campo ZF5_MOTCUS que foi para o AOMS003.
Vanderlei- Julio Paz     - 10/01/25 - 20/03/25 -  49551  - Ajustar a rotina de criação de cargas no Protheus para gravar o novo campos DAK_I_TMS para informar se a carga foi criada no RDC ou TMS MULTI EMBARCADOR.
Jerry    - Julio Paz     - 04/02/25 - 20/03/25 -  49611  - Inclusão de nova validação para não permitir a data da Ocorrência maior que a data atual.
Jerry    - Alex Wallauer - 10/02/25 - 20/03/25 -  49042  - Ajustes para trartar notas ficais de Transferencia de troca nota. 
Jerry    - Julio Paz     - 20/03/25 - 20/03/25 -  49611  - Alterar a rotina de integração de alteração de pedido de vendas, para produto Queijo na 3 unidade de medida. Se a quantidade de peças estiver zerada, recalcular as quantidades de peças.
Vanderlei- Alex Wallauer - 20/03/25 - 24/03/25 -  50197  - Novo tratamento para cortes e desmembramentos de pedidos - BLOQUEAR: M->C5_I_BLSLD = "S"
Vanderlei- Alex Wallauer - 26/03/25 - 28/03/25 -  49611  - Ajuste na validaçao da data da ocorrencia para não permitir data maior que a data atual para diferente de tipo = "F".
Vanderlei- Alex Wallauer - 07/05/25 - 08/05/25 -  50639  - Correção no calculo da data de previsão de entrega no cliente que era alterada indevidamente na ocorrência integrada do RDC.
Vanderlei- Alex Wallauer - 25/03/24 - 24/07/25 -  49894  - Acerto das somatorias dos campos de peso bruto: C6_I_PTBRU / C5_I_PESBR / C5_PBRUTO / DAI_PESO / DAK_PESO.
Vanderlei- Alex Wallauer - 25/03/24 - 24/07/25 -  51508  - Gravação do C5_DESCONT NA FUNÇÃO U_ALTERAP.
Vanderlei- Alex Wallauer - 25/03/24 - 24/07/25 -  49894  - Acerto das somatorias dos campos de peso bruto: C6_I_PTBRU / C5_I_PESBR / C5_PBRUTO / DAI_PESO / DAK_PESO para carga sem Palete
==================================================================================================================================================================================================================
*/

#include "APWEBSRV.CH"
#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"

#Define LINK_WEBSERVICE "http://10.3.0.57:4043/ws/U_AOMS074.apw" // Ambiente de Testes
#Define TP_GERA_PALET   "1,3,5,6" //"1-Pallet Chep","3-Pallet PBR","5-Pallet Chep Retorno","6-Pallet PBR Retorno"

// "http://10.3.0.55:1026/ws/U_AOMS074.apw" // Ambiente de Produção 
// "http://10.3.0.57:4003/ws/U_AOMS074.apw" // Ambiente de Homologação
// "http://10.3.0.57:4043/ws/U_AOMS074.apw" // Ambiente de Testes

/*
===============================================================================================================================
Programa----------: AOMS074
Autor-------------: Julio de Paula Paz
Data da Criacao---: 12/09/2016
Descrição---------: WebService de recepção de arquivos XML na integração do modulo OMS da Italac com o sistema RDC.
Parametros--------: Nenhum 
Retorno-----------: Nenhum 
===============================================================================================================================
*/
WSSTRUCT U_AOMS074T  //Inclusão de transportador

	WSDATA CGC as STRING
	WSDATA NOME as STRING
	WSDATA ENDERE as STRING
	WSDATA BAIRRO as STRING
	WSDATA IBGECLI as STRING
	WSDATA CEP as STRING
	WSDATA NOMER as STRING
	WSDATA COMPLE as STRING OPTIONAL
	WSDATA EMAIL as STRING OPTIONAL
	WSDATA INSEST as STRING OPTIONAL
	WSDATA TPOPES as STRING
	WSDATA DDFONE as STRING
	WSDATA TELEFONE as STRING

ENDWSSTRUCT

WSSTRUCT U_AOMS074V //Inclusão de veiculo

	WSDATA TIPO as STRING
	WSDATA DESC as STRING
	WSDATA PLACA1 as STRING
	WSDATA MUNICI1 as STRING
	WSDATA PLACA2 as STRING OPTIONAL
	WSDATA MUNICI2 as STRING OPTIONAL
	WSDATA PLACA3 as STRING OPTIONAL
	WSDATA MUNICI3 as STRING OPTIONAL
	WSDATA PLACA4 as STRING OPTIONAL
	WSDATA MUNICI4 as STRING OPTIONAL
	WSDATA ESTADO as STRING
	WSDATA NOMEM as STRING
	WSDATA CPFM as STRING
	WSDATA CNPJT as STRING
	WSDATA ENDERECOM as STRING
	WSDATA BAIRROM as STRING
	WSDATA MUNICIPIOM as STRING
	WSDATA ESTADOM as STRING
	WSDATA CEPM as STRING OPTIONAL
	WSDATA TELEFONEM as STRING OPTIONAL
	WSDATA CNHM as STRING OPTIONAL
	WSDATA EMICNH as STRING //DATE
	WSDATA VALCNH as STRING //DATE
	WSDATA CATCNH as STRING
	WSDATA PAIM as STRING
	WSDATA MAEM as STRING
	WSDATA RGM as STRING
	WSDATA TELRECM as STRING
	WSDATA RENAVAN1 as STRING
ENDWSSTRUCT

WSSTRUCT U_AOMS0741 //Detalhes de Inclusão de carga

	WSDATA CODIGO as STRING
	WSDATA ITEM as INTEGER
	WSDATA PEDIDO as STRING
	WSDATA TPCARG as STRING
	WSDATA CNPJOP as STRING
	WSDATA CNPJRE as STRING
	WSDATA QTDPALLET as INTEGER
	WSDATA SEQUENCIA as INTEGER
	WSDATA OBSCPA    as STRING
	WSDATA OBSPVE    as STRING
	WSDATA OBSNFE    as STRING
	WSDATA DTPREV    as STRING
	WSDATA FRETE     as FLOAT OPTIONAL

ENDWSSTRUCT

WSSTRUCT U_AOMS074C //Inclusão de carga

	WSDATA CNPJEM   as STRING
	WSDATA CODIGO   as STRING
	WSDATA PLACA1   as STRING OPTIONAL
	WSDATA PLACA2   as STRING OPTIONAL
	WSDATA PLACA3   as STRING OPTIONAL
	WSDATA PLACA4   as STRING OPTIONAL
	WSDATA CPFM     as STRING OPTIONAL
	WSDATA PESOB    as FLOAT
	WSDATA PESOL    as FLOAT
	WSDATA VALOR    as FLOAT
	WSDATA FRETE    as FLOAT OPTIONAL
	WSDATA DATAE    as STRING // DATE
	WSDATA DATAC    as STRING // DATE
	WSDATA CNPJTRA  as STRING
	WSDATA TIPO     as STRING OPTIONAL
	WSDATA PRECARGA as STRING
	WSDATA PEDAGIO  as FLOAT  OPTIONAL
	WSDATA OBSERV1  as STRING OPTIONAL
	WSDATA OBSERV2  as STRING OPTIONAL
	WSDATA USUCAD   as INTEGER OPTIONAL
	WSDATA RECNUM   as INTEGER
	WSDATA CODFIL   as STRING
	WSDATA ITENS    as ARRAY OF U_AOMS0741

ENDWSSTRUCT

WSSTRUCT U_AOMS074E //Estorno de carga

	WSDATA CNPJEM as STRING
	WSDATA CODIGO as STRING

ENDWSSTRUCT

WSSTRUCT U_AOMS0742 //Itens da Liberação de pgt de CTE

	WSDATA CTE as STRING

ENDWSSTRUCT

WSSTRUCT U_AOMS074L //Liberação de pgt de CTE

	WSDATA CNPJTRA as STRING
	WSDATA FATURA as STRING
	WSDATA VALOR as FLOAT
	WSDATA DATAP as STRING
	WSDATA ITENS as ARRAY OF U_AOMS0742

ENDWSSTRUCT

WSSTRUCT U_AOMS0743 //Itens de Alteração de pedido

	WSDATA ITEM as INTEGER
	WSDATA CODIGO as STRING
	WSDATA QTDEPR as FLOAT
	WSDATA UNMED as STRING
	WSDATA NATOPE as INTEGER
	WSDATA PESOUN as FLOAT
	WSDATA VOLUME as FLOAT
	WSDATA VLRPRO as FLOAT
	WSDATA QTDEPA as INTEGER
	WSDATA CUBADO as FLOAT
	WSDATA PESOBR as FLOAT
	WSDATA EXCLUI as STRING
	WSDATA CODARM as STRING
	WSDATA DESMEM as STRING
	WSDATA CODORI as STRING OPTIONAL
	WSDATA QTDPEC as FLOAT OPTIONAL
ENDWSSTRUCT

WSSTRUCT U_AOMS074A //Alteração de pedido

	WSDATA CNPJEM as STRING
	WSDATA PEDIDO as STRING
	WSDATA STATUS as STRING
	WSDATA PEDID2 as STRING
	WSDATA CNPJFA as STRING
	WSDATA BAIRRO as STRING
	WSDATA ENDERE as STRING
	WSDATA NUMERO as STRING
	WSDATA COMEND as STRING
	WSDATA IBGEFA as STRING
	WSDATA CNPJDE as STRING
	WSDATA ENDENT as STRING
	WSDATA CEPENT as STRING
	WSDATA BAIENT as STRING
	WSDATA NUMENT as STRING
	WSDATA IBGEENT as STRING
	WSDATA DTEMIS as STRING //DATE
	WSDATA DTPREV as STRING //DATE
	WSDATA DTAGEN as STRING //DATE
	WSDATA CAPROD as STRING
	WSDATA TIPEDI as STRING
	WSDATA CNPJTR as STRING
	WSDATA ENDTRA as STRING
	WSDATA CEPTRA as STRING
	WSDATA BAIRTR as STRING
	WSDATA NRTRAN as STRING
	WSDATA IBGETR as STRING
	WSDATA REPRES as STRING
	WSDATA COORDE as STRING
	WSDATA ASSIST as STRING
	WSDATA PESOPE as FLOAT
	WSDATA VLRPED as FLOAT
	WSDATA QTDEPA as INTEGER
	WSDATA VOLUME as FLOAT
	WSDATA USUALT as INTEGER
	WSDATA TIPOPA as STRING
	WSDATA COCHEP as STRING
	WSDATA OBSCPA as STRING OPTIONAL
	WSDATA OBSPVE as STRING OPTIONAL
	WSDATA OBSNFE as STRING OPTIONAL
	WSDATA ITENS as ARRAY OF U_AOMS0743


ENDWSSTRUCT


WSSTRUCT U_AOMS074O //Inclusão de ocorrência

	WSDATA CNPJEM as STRING
	WSDATA NOTA as STRING
	WSDATA SERIE as STRING
	WSDATA CODIGO as STRING
	WSDATA OCORR as STRING
	WSDATA DATAO as STRING
	WSDATA HORA as STRING
	WSDATA OBSERV as STRING OPTIONAL
	WSDATA DATAC as STRING OPTIONAL
	WSDATA HORAC as STRING OPTIONAL
	WSDATA DATAI as STRING OPTIONAL
	WSDATA HORAI as STRING OPTIONAL
	WSDATA DATAT as STRING OPTIONAL
	WSDATA HORAT as STRING OPTIONAL
	WSDATA DATAS as STRING OPTIONAL
	WSDATA HORAS as STRING OPTIONAL
	WSDATA CNPJDEV as STRING OPTIONAL
	WSDATA NOTADEV as STRING OPTIONAL
	WSDATA SERIEDEV as STRING OPTIONAL
	WSDATA VALOR as FLOAT OPTIONAL

ENDWSSTRUCT

WSSTRUCT U_AOMS074F //Liberação fiscal de CTE

	WSDATA CHAVECTE as STRING
	WSDATA STATUSCTE as STRING
	WSDATA MOTIVOCTE as STRING OPTIONAL

ENDWSSTRUCT

WSSTRUCT U_AOMS074G //Solicitação de liberação de bloqueio de pedido de vendas

	WSDATA CNPJEM as STRING
	WSDATA PEDIDO as STRING
	WSDATA RESEVA as INTEGER OPTIONAL
	WSDATA USUALT as INTEGER OPTIONAL

ENDWSSTRUCT

WSSTRUCT U_AOMS074H //Integração de Vale Pedágio

	WSDATA CNPJEM   as STRING
	WSDATA NRVIAG   as INTEGER
	WSDATA NRSOLI   as STRING
	WSDATA CODUSU   as INTEGER
	WSDATA PLACA1   as STRING
	WSDATA SOLUCAO  as INTEGER
	WSDATA PEDAGIO  as FLOAT
	WSDATA DTCOMPRA as DATE
	WSDATA HRCOMPRA as STRING
	WSDATA NRCOMPRA as STRING
	WSDATA ACAO     as INTEGER

ENDWSSTRUCT


WSSERVICE U_AOMS074 DESCRIPTION "WebService Integracao: RDC ---> Italac" NAMESPACE LINK_WEBSERVICE //"http://10.3.0.57:4043/ws/U_AOMS074.apw"

	WSDATA U_TRANSP AS U_AOMS074T
	WSDATA U_VEICUL AS U_AOMS074V
	WSDATA U_CARGA  AS U_AOMS074C
	WSDATA U_ESTORN AS U_AOMS074E
	WSDATA U_LIBERA AS U_AOMS074L
	WSDATA U_ALTERA AS U_AOMS074A
	WSDATA U_OCORRE AS U_AOMS074O
	WSDATA U_FISCAL AS U_AOMS074F
	WSDATA U_LIBERP AS U_AOMS074G
	WSDATA U_VALEPED AS U_AOMS074H
	WSDATA U_STATUS AS STRING

	WSMETHOD U_INCLUIT DESCRIPTION "Inclusao de transportador RDC ---> Italac"
	WSMETHOD U_INCLUIV DESCRIPTION "Inclusao de veiculo RDC ---> Italac"
	WSMETHOD U_INCLUIC DESCRIPTION "Inclusao de carga RDC ---> Italac"
	WSMETHOD U_ESTORNC DESCRIPTION "Estorno de carga RDC ---> Italac"
	WSMETHOD U_LIBERAC DESCRIPTION "Libera pgt CTE RDC ---> Italac"
	WSMETHOD U_ALTERAP DESCRIPTION "Altera pedido RDC ---> Italac"
	WSMETHOD U_INCLUIO DESCRIPTION "Inclusao de ocorrencia de frete RDC ---> Italac"
	WSMETHOD U_LIBERAF DESCRIPTION "Lib Fiscal de CTE RDC ---> Italac"
	WSMETHOD U_LIBERAP DESCRIPTION "Sol Lib PV Bloqueado RDC ---> Italac"
	WSMETHOD U_INTVLPED DESCRIPTION "Integração Vale Pedagio RDC ---> Italac"

ENDWSSERVICE

WSMETHOD U_LIBERAP WSRECEIVE U_LIBERP WSSEND U_STATUS WSSERVICE U_AOMS074
	Local _lRet := .T.
	Local _nI
	Local _cMsg
	Local _cSituacao
	Local _cfilial := '01'
	Local _nTamCodUser
	Local _cMsgOk := ""
	Local _cReserva

	Private _cEmailZZL, _cCodUsuario

	Begin Sequence

		//=====================================================================
		// Limpa o ambiente, liberando a licença e fechando as conexões
		//=====================================================================
		RpcClearEnv()
		RpcSetType(2)

		//===========================================================================================
		// Preparando o ambiente com a filial da carga recebida
		//===========================================================================================
		//PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01';
			//        TABLES "SA7","SB1","SB2","SB5","SB8","SBJ","SB9","SBE","SBF","SC0","SD5","SBK","SD7","SDC","SF4","SGA","SM2","SDA","SDB","SBM","ADA","SA2","DAK","DAI","DA4","ZFU","ZFV","SC9","SA1","SC5","SC6", "SA1" ,"ZP1","SX6","SX1","SX2","SX3","SM0", "SIX" ;
			//        MODULO 'OMS'
		RpcSetEnv("01", "01",,,,, {"SA7","SB1","SB2","SB5","SB8","SBJ","SB9","SBE","SBF","SC0","SD5","SBK","SD7","SDC","SF4","SGA","SM2","SDA","SDB","SBM","ADA","SA2","DAK","DAI","DA4","ZFU","ZFV","SC9","SA1","SC5","SC6", "SA1" ,"ZP1","SX6","SX1","SX2","SX3","SM0", "SIX"})

		cFilAnt := _cfilial

		//===================================================================================
		// Valida o CNPJ do Embarcador enviado pela RDC e Prepara as variáveis de Ambiente.
		//===================================================================================
		_aFilial := FwLoadSM0()
		_cMsg := ""
		_cMsgOk := ""
		_nTamCGC    := TAMSX3("A2_CGC")[1]

		If Empty(U_LIBERP:CNPJEM) .Or. Ascan(_aFilial,{|x| x[18] = Padr(U_LIBERP:CNPJEM,_nTamCGC," ")}) == 0
			_cMsg += " CNPJ Embarcador não preenchido, ou não está cadastrado. "
			Break
		Else
			_nI := Ascan(_aFilial,{|x| x[18] = Padr(U_LIBERP:CNPJEM,_nTamCGC," ")})
			_cFilial := _aFilial[_nI,5]
		EndIf

		//===========================================================================================
		// Preparando o ambiente com a filial da liberação recebida
		//===========================================================================================
		cFilAnt := _cFilial
		SM0->(dbSeek(xFilial('SM0')+_cFilial))

		//Verifica se pedido existe
		SC5->(Dbsetorder(01))
		If !SC5->(Dbseek(cfilant + alltrim(U_LIBERP:PEDIDO)))
			_cMsg := " Pedido de vendas não localizado: " + ALLTRIM(U_LIBERP:PEDIDO)
			Break
		EndIf

		//Verifica se pedido pode ser bloqueado
		If !SC5->(MsRLock(SC5->(RECNO())))
			_cMsg := "No momento este Pedido de Vendas está sendo utilizado por outro usuário e não pode ser manipulado. Tente integrar novamente mais tarde: " + ALLTRIM(U_LIBERP:PEDIDO)
			Break
		Endif

		//Verifica se cliente pode ser bloqueado
		SA1->(Dbsetorder(1))
		If !(SA1->(Dbseek("  " + SC5->C5_CLIENTE+SC5->C5_LOJACLI)))
			_cMsg := " Cliente do pedido de vendas não localizado: " + SC5->C5_CLIENTE+"/"+SC5->C5_LOJACLI
			Break
		Endif

		//Verifica se cliente pode ser bloqueado
		If !SA1->(MsRLock(SA1->(RECNO())))
			_cMsg := "No momento Cliente deste Pedido de Vendas está sendo utilizado por outro usuário e não pode ser manipulado. Tente integrar novamente mais tarde: "  + SC5->C5_CLIENTE+"/"+SC5->C5_LOJACLI
			Break
		Endif

		//Verifica se pedido não foi faturado já
		If !Empty(SC5->C5_NOTA)
			_cMsg := " Pedido de vendas já faturado ou eliminado por residuo: " + ALLTRIM(U_LIBERP:PEDIDO) + " - Nota: " + alltrim(SC5->C5_NOTA)
			Break
		EndIf

		If posicione("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_MSBLQL") == '1'

			_cMsg := " Cliente do pedido bloqueado no cadastro "+AllTrim(SC5->C5_CLIENTE+"/"+SC5->C5_LOJACLI)+"."
			Break

		Endif

		//Verifica se os itens do pedido podem ser bloqueados
		SC6->(Dbsetorder(1))
		SC6->(Dbgotop())
		SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))

		Do while SC6->C6_NUM == SC5->C5_NUM .AND. SC5->C5_FILIAL == SC6->C6_FILIAL


			If !SC6->(MsRLock(SC6->(RECNO())))

				_cMsg := "Item do pedido em uso: "+AllTrim(SC6->C6_FILIAL+"/"+SC6->C6_PRODUTO+"/"+SC6->C6_LOCAL)+"."
				Break

			Else

				If  U_ITGETMV( 'IT_LOCKPD' , .F. )

					SC6->(MSUNLOCKALL())
					SC6->(Msunlock())

				Endif

			Endif


			SB2->(Dbsetorder(1))
			SB2->(Dbseek(SC6->C6_FILIAL+SC6->C6_PRODUTO+SC6->C6_LOCAL))

			If !SB2->(MsRLock(SB2->(RECNO())))

				_cMsg := "Produto em uso: "+AllTrim(SC6->C6_FILIAL+"/"+SC6->C6_PRODUTO+"/"+SC6->C6_LOCAL)+"."
				Break

			Else

				If  U_ITGETMV( 'IT_LOCKPD' , .F. )

					SB2->(MSUNLOCKALL())
					SB2->(Msunlock())

				Endif

			Endif

			SC6->(DbSkip())

		Enddo

		// Verifica se o usuário que Liberou o Pedido de Vendas está cadastrado, no cadastro de usuários Italac.
		_nTamCodUser := TAMSX3("ZZL_RDCUSR")[1]
		_cCodUsuario := Posicione("ZZL",5,xfilial("ZZL")+AllTrim(Str(U_LIBERP:USUALT,_nTamCodUser)),"ZZL_CODUSU") // ZZL_FILIAL+ZZL_RDCUSR
		_cEmailZZL   := Posicione("ZZL",5,xfilial("ZZL")+AllTrim(Str(U_LIBERP:USUALT,_nTamCodUser)),"ZZL_EMAIL")  // ZZL_FILIAL+ZZL_RDCUSR

		If Empty(_cCodUsuario)
			_cMsg := " Usuário não cadastrado no Cadastro de Usuários Italac. "
			Break
		EndIf
		__cUserId := _cCodUsuario // Carrega a variável do Workflow __cUserId com o código do solicitante da integração.

		//============================================================================
		// U_LIBERP:RESEVA == 2 // 2 - Solicita Desfazer Reserva
		// Libera o estoque reservado para o pedido de vendas.
		//============================================================================
		If U_LIBERP:RESEVA == 2
			If U_AOMS074R()
				_cMsgOk := " Solicitação para desfazer a reserva de estoque realizada com sucesso. "
			Else
				_cMsg := " Não foi possível desfazer a reserva de estoques. "
			EndIf
		Else // U_LIBERP:RESEVA == 1
			//============================================================================
			// U_LIBERP:RESEVA == 1 // 1 - Solicita Reservar Estoque
			// Libera o pedido de vendas reservando estoque.
			//============================================================================
			//verifica se pedido já não está em situação liberada.
			If (SC5->C5_I_BLOQ <> 'B' .And. SC5->C5_I_BLOQ <> 'R' .AND. SC5->C5_I_BLPRC <> 'B' .And. SC5->C5_I_BLPRC <> 'R' .And. SC5->C5_I_BLCRE <> 'B' .and. SC5->C5_I_BLCRE <> 'R')

				//Verifica se já tem liberação de estoque e tenta refazer se não tiver ou tiver bloqueio
				_areto := AOMS074J()

				IF SC5->C5_I_BLCRE == 'B' //Bloqueou estoque na liberação do pedido
					_cMsg := ""
					Break
				Endif

				If _areto[1]

					_cMsg := " Liberação realizada com sucesso: " + ALLTRIM(U_LIBERP:PEDIDO)
					Break
				Else

					_cMsg := " Pedido de vendas tem bloqueio de estoque: " + ALLTRIM(U_LIBERP:PEDIDO) + " - " + _areto[2]
					Break
				Endif

			Endif
		EndIf



	End Sequence

	_cstatus := U_STPEDIDO()
	_cstexte := U_STPEDIDO(1)

	_cReserva := ""
	SC9->(DbSetOrder(1))
	If ! SC9->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))
		_cReserva := "1" // Não tem reserva de estoque = Verde => Sem Reserva
	Else
		If U_Verest()
			_cReserva := "2" // Conseguiu reservar estoque = Amarelo => Reservado
		Else
			_cReserva := "3" // Não há estoque disponível  = Azul => Bloqueio de estoque
		EndIf
	EndIf

	If U_LIBERP:RESEVA == 2
		If ! Empty(_cMsgOk)
			::U_STATUS := "SUCESSO:FALSE;SITUACAO:" + _cstatus +";RESERVA:"+_cReserva+";"+AllTrim(_cMsgOk) + "("  + ALLTRIM(U_LIBERP:PEDIDO) + ") - " + _cstexte
			_cSituacao := "E"
		Else
			::U_STATUS := "SUCESSO:FALSE;SITUACAO:" + _cstatus +";RESERVA:"+_cReserva+";"+AllTrim(_cMsg)
			_cSituacao := "R"
		EndIf
	Else

		_cSituacao := "P"
		If Empty(_cMsg)

			::U_STATUS := "SUCESSO:FALSE;" + _cstatus +";RESERVA:"+_cReserva + "; Solicitação de liberação registrada aguardando resposta! ("  + ALLTRIM(U_LIBERP:PEDIDO) + ") - " + _cstexte
			_cSituacao := "P"

			//===================================================================================
			//Dispara Workflow de solicitação de liberação crédito/preço do pedido
			//===================================================================================
			SC5->(Dbsetorder(1))
			If SC5->(Dbseek(_cFilial + alltrim(U_LIBERP:PEDIDO)))
				
				U_MOMS030W(ALLTRIM(U_LIBERP:PEDIDO))
				::U_STATUS := "SUCESSO:TRUE;" + _cstatus +";RESERVA:"+_cReserva + "; Solicitação de liberação registrada aguardando resposta! ("  + ALLTRIM(U_LIBERP:PEDIDO) + ") - " + _cstexte
				_cSituacao := "P"
			Else
				::U_STATUS := "SUCESSO:FALSE;" + _cstatus +";RESERVA:"+_cReserva+ "; Falha no envio de solicitação de liberação! ("  + ALLTRIM(U_LIBERP:PEDIDO) + ") - " + _cstexte
				_cSituacao := "E"
			Endif

		Elseif _cMsg == " Liberação realizada com sucesso: " + ALLTRIM(U_LIBERP:PEDIDO)

			::U_STATUS := "SUCESSO:FALSE;SITUACAO:" + _cstatus + ";RESERVA:"+_cReserva + ";"+AllTrim(_cMsg) + "("  + ALLTRIM(U_LIBERP:PEDIDO) + ") - " + _cstexte


			_cSituacao := "E"

		Else
			::U_STATUS := "SUCESSO:FALSE;SITUACAO:" + _cstatus + ";RESERVA:"+_cReserva + ";"+AllTrim(_cMsg)
			_cSituacao := "R"
		EndIf
	EndIf

	ZGB->(Dbsetorder(1))
	If _cSituacao == "E" .AND. ZGB->(Dbseek("  "+SC5->C5_NUM)) //Se for encerramento da solicitação encerra todas as solicitações pendentes do PV

		Do while ZGB->ZGB_NUM == SC5->C5_NUM

			If ZGB->ZGB_SITUAC == "P"

				ZGB->(RecLock("ZGB",.F.))
				ZGB->ZGB_SITUAC  := _cSituacao
				ZGB->(MsUnlock())

			Endif

			ZGB->(Dbskip())

		Enddo

	Endif

//Grava movimentação atual
	ZGB->(RecLock("ZGB",.T.))
	ZGB->ZGB_DTENT   := SC5->C5_I_DTENT
	ZGB->ZGB_SITUAC  := _cSituacao
	ZGB->ZGB_NUM     := SC5->C5_NUM
	ZGB->ZGB_USUARI  := _cCodUsuario // "Web"
	ZGB->ZGB_DATAAL  := Date()
	ZGB->ZGB_HORASA  := TIME()
	ZGB->ZGB_STATUS  := _cstatus
	ZGB->ZGB_RETORN  := ::U_STATUS
	ZGB->(MsUnlock())

//Atualiza status do pedido na c5
	SC5->(Dbsetorder(1))
	If SC5->(DbSeek(_cFilial+U_LIBERP:PEDIDO))

		SC5->(RecLock("SC5",.F.))
		SC5->C5_I_STATU := U_STPEDIDO() //Função de análise do pedido de vendas no xfunoms
		SC5->(MsUnlock())

	Endif



//Garante que vai liberar lock de todos os cabeçalhos e todos os itens
	SC5->(Dbsetorder(1))
	If SC5->(DbSeek(_cFilial+U_LIBERP:PEDIDO))

		SC5->(Msunlock())
		SC5->(Msunlockall())

		SA1->(Dbsetorder(1))
		If SA1->(Dbseek(xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))

			SA1->(Msunlock())
			SA1->(Msunlockall())

		Endif

		SC6->(Dbsetorder(1))
		If SC6->(Dbseek(_cFilial+U_LIBERP:PEDIDO))

			Do while SC6->C6_FILIAL == SC5->C5_FILIAL .AND. SC6->C6_NUM == SC5->C5_NUM

				SC6->(Msunlock())
				SC6->(Msunlockall())

				SB2->(Dbsetorder(1))
				If SB2->(Dbseek(SC6->C6_FILIAL+SC6->C6_PRODUTO+SC6->C6_LOCAL))

					SB2->(Msunlock())
					SB2->(Msunlockall())

				Endif

				SC6->(Dbskip())

			Enddo

		Endif

	Endif


Return _lRet


WSMETHOD U_INCLUIT WSRECEIVE U_TRANSP WSSEND U_STATUS WSSERVICE U_AOMS074
	Local _lRet := .T.
	Local _nTamCGC := TamSX3("A2_CGC")[1]
	Local _aUF, _cEstado, _nI
	Local _lAprovado := .T.
	Local _cClassificacao := {{"P","Produtor"},{"F","Fornecedor"},{"V","Vendedor"},{"T","Transportador"},{"L","Laticinio"},{"A","Transp.Autonomos"},{"G","Transp.Leite Granel"},{"C","Transp.Leite Cru"}}
	Local _cCodEmpWS := U_ITGETMV( 'IT_EMPWEBSE' , '000001' )
    

	Begin Sequence
		//================================================================================
		// Monta array dos estados
		//================================================================================
		_aUF := {}
		Aadd(_aUF,{"RO","11"})
		Aadd(_aUF,{"AC","12"})
		Aadd(_aUF,{"AM","13"})
		Aadd(_aUF,{"RR","14"})
		Aadd(_aUF,{"PA","15"})
		Aadd(_aUF,{"AP","16"})
		Aadd(_aUF,{"TO","17"})
		Aadd(_aUF,{"MA","21"})
		Aadd(_aUF,{"PI","22"})
		Aadd(_aUF,{"CE","23"})
		Aadd(_aUF,{"RN","24"})
		Aadd(_aUF,{"PB","25"})
		Aadd(_aUF,{"PE","26"})
		Aadd(_aUF,{"AL","27"})
		Aadd(_aUF,{"MG","31"})
		Aadd(_aUF,{"ES","32"})
		Aadd(_aUF,{"RJ","33"})
		Aadd(_aUF,{"SP","35"})
		Aadd(_aUF,{"PR","41"})
		Aadd(_aUF,{"SC","42"})
		Aadd(_aUF,{"RS","43"})
		Aadd(_aUF,{"MS","50"})
		Aadd(_aUF,{"MT","51"})
		Aadd(_aUF,{"GO","52"})
		Aadd(_aUF,{"DF","53"})
		Aadd(_aUF,{"SE","28"})
		Aadd(_aUF,{"BA","29"})
		Aadd(_aUF,{"EX","99"})

		_cEstado := ""
		_nI := Ascan(_aUF,{|x| x[2] == SubStr(U_TRANSP:IBGECLI,1,2)})
		If _nI > 0
			_cEstado := _aUF[_nI,1]
		EndIf

		//================================================================================
		// Validações Iniciais             // Validar apenas os Tipos T/A/G/C - os demais tipos devem ser ignorados.
		//================================================================================
		SA2->(DbSetOrder(3)) // A2_FILIAL+A2_CGC
		If ! SA2->(DbSeek(xFilial("SA2")+Padr(U_TRANSP:CGC,_nTamCGC," ")))
			//_lAterar := .T.
			//If SA2->A2_I_CLASS <> "T"
			_nI := Ascan(_cClassificacao,{|x| x[1]==SA2->A2_I_CLASS})

			_lAprovado := .F.
			::U_STATUS := "SUCESSO:FALSE; Problemas na integração Transportador. CNPJ " + U_TRANSP:CGC+" não está cadastrado no Protheus."//+_cClassificacao[_nI,2]+"."
		EndIf

		If _lAprovado
			If Empty(_cEstado)
				_lAprovado := .F.
				::U_STATUS := "SUCESSO:FALSE; Problemas na integração Transportador. CNPJ " + U_TRANSP:CGC+". Estado informado no codigo IBGECLIENT não existe."
			EndIf
		EndIf

		If _lAprovado
			CC2->(DbSetOrder(1))
			If ! CC2->(DbSeek(xFilial("CC2")+_cEstado+SubStr(U_TRANSP:IBGECLI,3,5)))
				_lAprovado := .F.
				::U_STATUS := "SUCESSO:FALSE; Problemas na integração Transportador. CNPJ " + U_TRANSP:CGC+". Codigo IBGECLIENT não existe."
			EndIf
		EndIf

		If _lAprovado
			If ! AllTrim(U_TRANSP:TPOPES) $ "F/J"    // Tipo de pessoa. F=Fisica / J=Jurídica
				_lAprovado := .F.
				::U_STATUS := "SUCESSO:FALSE; Problemas na integração Transportador. CNPJ " + U_TRANSP:CGC+". Tipo de Pessoa Física/Jurídica inválido."
			EndIf
		EndIf

		//================================================================================
		// Grava dados da transportadora no cadastro de fornecedores
		//================================================================================
		If _lAprovado

			::U_STATUS := "SUCESSO:TRUE; Alteração de transportador via RDC realizada com sucesso. CNPJ: " + U_TRANSP:CGC

		EndIf

	End Sequence

//================================================================================
// Grava dados da transportadora na tabela de muro para conferência
//================================================================================ 
	ZFP->(Reclock("ZFP",.T.))
	ZFP->ZFP_FILIAL	:= xFilial("ZFP")          // Filial do Sistema
	ZFP->ZFP_DATA	:= Date()                  // Data de Emissão
	ZFP->ZFP_HORA   := Time()
	ZFP->ZFP_CGC   	:= U_TRANSP:CGC            // CNPJ do Transportador
	ZFP->ZFP_NOME  	:= U_TRANSP:NOME           // Nome
	ZFP->ZFP_ENDERE	:= U_TRANSP:ENDERE         // Endereço
	ZFP->ZFP_BAIRRO	:= U_TRANSP:BAIRRO         // Bairro
	ZFP->ZFP_IBGECL	:= U_TRANSP:IBGECLI        // Municipio (Código IBGE)
	ZFP->ZFP_CEP   	:= U_TRANSP:CEP            // CEP
	ZFP->ZFP_NOMER	:= U_TRANSP:NOMER          // Nome Fantasia
	ZFP->ZFP_COMPLE	:= U_TRANSP:COMPLE         // Complemento Endereço
	ZFP->ZFP_EMAIL	:= U_TRANSP:EMAIL          // Email
	ZFP->ZFP_INSEST	:= U_TRANSP:INSEST         // Numero da inscricao estadual
	ZFP->ZFP_TPOPES	:= U_TRANSP:TPOPES         // Tipo de pessoa.
	ZFP->ZFP_DDFONE	:= U_TRANSP:DDFONE         // DD Fone
	ZFP->ZFP_NFONE	:= U_TRANSP:TELEFONE       // Telefone
	ZFP->ZFP_USUARI	:= __CUSERID               // Codigo do Usuário
	ZFP->ZFP_DATAAL	:= Date()                  // Data de Alteração
	ZFP->ZFP_SITUAC	:= If(_lAprovado, "P","R") // Situação do Registro
	ZFP->ZFP_CODEMP	:= _cCodEmpWS              // Codigo Empresa WebServer
	ZFP->ZFP_RETORN	:= ::U_STATUS              // Retorno Integracao Italac-RDC
	ZFP->(MsUnLock())

Return _lRet

WSMETHOD U_INCLUIV WSRECEIVE U_VEICUL WSSEND U_STATUS WSSERVICE U_AOMS074

	Local _lRet := .T.

	Local _nTamPlaca := TAMSX3("DA3_PLACA")[1]
	Local _lAlterar
	Local _nTamCPF  := TAMSX3("DA4_CGC")[1]
	Local _nTamCNPJ := TAMSX3("A2_CGC")[1]
	Local _cCnpj
	Local _nTamForn  := TAMSX3("A2_COD")[1]
	Local _nTamLojaF := TAMSX3("A2_LOJA")[1]
	Local _nTamNReduz := TAMSX3("DA4_NREDUZ")[1]
	Local _cCodEmpWS := U_ITGETMV( 'IT_EMPWEBSE' , '000001' )
	Local _cMsg, _cMsgOk
	Local _cQry
	Local _cCod_T, _cLoja_T
	Local _aPlaca := {}
	Local _cPlaca2, _cPlaca3 , _cPlaca4

	Local _lTemTransp

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.
	lMsHelpAuto := .F.

	Begin Sequence

		::U_STATUS := ""
		_cMsg      := ""
		_cMsgOk    := ""

		//===========================================================================
		// Gravação do cadastro de  motorisata
		//==========================================================================
		M->DA4_FILIAL  := xFilial("DA4")
		M->DA4_COD     := GETSXENUM("DA4","DA4_COD")
		M->DA4_BAIRRO  := U_VEICUL:BAIRROM    // Bairro Motorista
		M->DA4_MUNCNH  := U_VEICUL:CATCNH     // Categoria CNH do motorista
		M->DA4_CEP     := U_VEICUL:CEPM       // CEP do Motorista
		M->DA4_NUMCNH  := U_VEICUL:CNHM       // CNH do motorista
		_cCnpj         := Padr(U_VEICUL:CNPJT,_nTamCNPJ," ")      // CNPJ Transportadora
		M->DA4_CGC     := Padr(U_VEICUL:CPFM ,_nTamCPF," ")      // CPF do motorista
		M->DA4_DTECNH  := CTOD(U_VEICUL:EMICNH)     // Emissão da CNH
		M->DA4_END     := U_VEICUL:ENDERECOM  // Endereco Motorista
		M->DA4_EST     := U_VEICUL:ESTADOM    // Estado do Motorista
		M->DA4_MAE     := U_VEICUL:MAEM       // Mãe do Motorista
		M->DA4_MUN     := U_VEICUL:MUNICIPIOM // Municipio Motorista
		M->DA4_NOME    := U_VEICUL:NOMEM      // Nome do motorista
		M->DA4_NREDUZ  := SubStr(U_VEICUL:NOMEM,1,_nTamNReduz)      // Nome do motorista
		M->DA4_PAI     := U_VEICUL:PAIM       // Pai do Motorista
		M->DA4_RG      := U_VEICUL:RGM        // RG do Motorista
		M->DA4_TEL     := U_VEICUL:TELEFONEM  // Telefone do Motorista
		M->DA4_TELREC  := U_VEICUL:TELRECM    // Telefone recado Motorista
		M->DA4_DTVCNH  := If(Empty(U_VEICUL:VALCNH),CTOD("  /  /  "),CTOD(U_VEICUL:VALCNH))     // Validade da CNH

		SA2->(DbSetOrder(3)) //A2_FILIAL+A2_CGC
		M->DA4_FORNEC := ""
		M->DA4_LOJA    := ""
		_cCod_T  := ""
		_cLoja_T := ""
		_lTemTransp := .F.
		If SA2->(DbSeek(xFilial("SA2")+_cCnpj))
			Do while ! SA2->(Eof()) .And. SA2->(A2_FILIAL+A2_CGC) == xFilial("SA2")+_cCnpj
				If SA2->A2_I_CLASS $ "T/A"

					M->DA4_FORNEC := PadR(SA2->A2_COD,_nTamForn," ")
					M->DA4_LOJA   := PadR(SA2->A2_LOJA,_nTamLojaF," ")
					If SA2->A2_I_CLASS == "T"
						_cCod_T  := PadR(SA2->A2_COD,_nTamForn," ")
						_cLoja_T := PadR(SA2->A2_LOJA,_nTamLojaF," ")
					EndIf
					_lTemTransp := .T.
				EndIf
				SA2->(DbSkip())
			EndDo
		EndIf

		If !_lTemTransp // Não há transportadora cadastrada
			_cMsg := "Não há transportadora cadastrada para o motorista: " + U_VEICUL:NOMEM
			RollbackSx8() //Libera código de motorista que foi pedido
			Break
		EndIf

		//=====================================================================
		// Há transportadora cadastrada. Então atualiza cadastro de motoristas.
		//=====================================================================
		If !Empty(_cCod_T)
			M->DA4_FORNEC := _cCod_T
			M->DA4_LOJA   := _cLoja_T
		EndIf

		_cQry := " SELECT DA4.R_E_C_N_O_ AS NRECNO FROM " + RetSqlName("DA4") + " DA4 "
		_cQry += " WHERE DA4.D_E_L_E_T_ = '  '  AND DA4_CGC = '" + M->DA4_CGC + "' AND DA4_FORNEC = '"+M->DA4_FORNEC+"' AND DA4_LOJA = '"+M->DA4_LOJA+"' "

		If Select("QRYDA4") > 0
			QRYDA4->(DbCloseArea())
		EndIf

		_cQry := ChangeQuery(_cQry)
		DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry), "QRYDA4", .F., .T.)

		_lAlterar := .F.
		If ! QRYDA4->(Eof()) .And. !QRYDA4->(Bof())
			_lAlterar := .T.

			DA4->(DbGoTo(QRYDA4->NRECNO))
			M->DA4_COD := DA4->DA4_COD   // Na alteração, atualiza variavel de memoria como o código do Motorista para gravação no veículo.
			RollbackSx8() //Libera código de motorista que foi pedido
		EndIf

		If _lAlterar
			Do While ! QRYDA4->(Eof())
				DA4->(DbGoTo(QRYDA4->NRECNO))

				DA4->(RecLock("DA4",.F.))
				DA4->DA4_BAIRRO :=  M->DA4_BAIRRO      // Bairro Motorista
				DA4->DA4_MUNCNH :=  M->DA4_MUNCNH      // CNH do motorista
				DA4->DA4_EST    :=  M->DA4_EST         // Estado do Motorista
				DA4->DA4_CEP    :=  M->DA4_CEP         // CEP do Motorista
				DA4->DA4_NUMCNH :=  M->DA4_NUMCNH      // CNH do motorista
				DA4->DA4_LOJA   :=  M->DA4_LOJA        // Loja Fornecedor
				DA4->DA4_FORNEC :=  M->DA4_FORNEC      // Fornecedor
				DA4->DA4_LOJA   :=  M->DA4_LOJA        // Loja Fornecedor
				DA4->DA4_CGC    :=  M->DA4_CGC         // CPF do motorista
				DA4->DA4_DTECNH :=  M->DA4_DTECNH      // Emissão da CNH
				DA4->DA4_END    :=  M->DA4_END         // Endereco Motorista
				DA4->DA4_MAE    :=  M->DA4_MAE         // Mãe do Motorista
				DA4->DA4_MUN    :=  M->DA4_MUN         // Municipio Motorista
				DA4->DA4_NOME   :=  M->DA4_NOME        // Nome do motorista
				DA4->DA4_NREDUZ :=  M->DA4_NREDUZ      // Nome do motorista
				DA4->DA4_PAI    :=  M->DA4_PAI         // Pai do Motorista
				DA4->DA4_RG     :=  M->DA4_RG          // RG do Motorista
				DA4->DA4_TEL    :=  M->DA4_TEL         // Telefone do Motorista
				DA4->DA4_TELREC :=  M->DA4_TELREC      // Telefone recado Motorista
				DA4->DA4_DTVCNH :=  M->DA4_DTVCNH      // Validade da CNH
				DA4->(MsUnlock())

				QRYDA4->(DbSkip())
			EndDo
		EndIf

		If Select("QRYDA4") > 0
			QRYDA4->(DbCloseArea())
		EndIf

		If ! _lAlterar
			//===================================================================
			// Verifica se o código do motorista já existe na tabela DA4.
			// Se existir gera um novo código.
			//===================================================================
			DA4->(DbSetOrder(1)) // DA4_FILIAL+DA4_COD
			If DA4->(DbSeek(xFilial("DA4")+M->DA4_COD))
				_cQry := " SELECT Max(DA4.DA4_COD) AS CODMOTOR FROM " + RetSqlName("DA4") + " DA4 "
				_cQry += " WHERE DA4.D_E_L_E_T_ = '  '  "

				If Select("QRYDA4") > 0
					QRYDA4->(DbCloseArea())
				EndIf

				_cQry := ChangeQuery(_cQry)
				DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry), "QRYDA4", .F., .T.)

				If ! QRYDA4->(Eof()) .And. !QRYDA4->(Bof())
					M->DA4_COD := StrZero(Val(QRYDA4->CODMOTOR) + 1,6)
				EndIf

				If Select("QRYDA4") > 0
					QRYDA4->(DbCloseArea())
				EndIf

			EndIf

			//===================================================================
			// Faz a inclusão do novo motorista.
			//===================================================================
			DA4->(RecLock("DA4",.T.))
			DA4->DA4_FILIAL  := M->DA4_FILIAL
			DA4->DA4_COD     := M->DA4_COD
			DA4->DA4_BAIRRO :=  M->DA4_BAIRRO      // Bairro Motorista
			DA4->DA4_MUNCNH :=  M->DA4_MUNCNH      // CNH do motorista
			DA4->DA4_EST    :=  M->DA4_EST         // Estado do Motorista
			DA4->DA4_CEP    :=  M->DA4_CEP         // CEP do Motorista
			DA4->DA4_NUMCNH :=  M->DA4_NUMCNH      // CNH do motorista
			DA4->DA4_LOJA   :=  M->DA4_LOJA        // Loja Fornecedor
			DA4->DA4_FORNEC :=  M->DA4_FORNEC      // Fornecedor
			DA4->DA4_LOJA   :=  M->DA4_LOJA        // Loja Fornecedor
			DA4->DA4_CGC    :=  M->DA4_CGC         // CPF do motorista
			DA4->DA4_DTECNH :=  M->DA4_DTECNH      // Emissão da CNH
			DA4->DA4_END    :=  M->DA4_END         // Endereco Motorista
			DA4->DA4_MAE    :=  M->DA4_MAE         // Mãe do Motorista
			DA4->DA4_MUN    :=  M->DA4_MUN         // Municipio Motorista
			DA4->DA4_NOME   :=  M->DA4_NOME        // Nome do motorista
			DA4->DA4_NREDUZ :=  M->DA4_NREDUZ      // Nome do motorista
			DA4->DA4_PAI    :=  M->DA4_PAI         // Pai do Motorista
			DA4->DA4_RG     :=  M->DA4_RG          // RG do Motorista
			DA4->DA4_TEL    :=  M->DA4_TEL         // Telefone do Motorista
			DA4->DA4_TELREC :=  M->DA4_TELREC      // Telefone recado Motorista
			DA4->DA4_DTVCNH :=  M->DA4_DTVCNH      // Validade da CNH
			DA4->(MsUnlock())
			ConfirmSx8() //Confirma novo código de motorista
		EndIf

		If _lAlterar
			//::U_STATUS := ::U_STATUS + " / Alteração do motorista via RDC realizada com sucesso: " + U_VEICUL:NOMEM
			_cMsgOk := _cMsgOk +  " Alteração do motorista via RDC realizada com sucesso: " + U_VEICUL:NOMEM
		Else
			//::U_STATUS := ::U_STATUS + " / Inclusão de motorista via RDC realizada com sucesso: " + U_VEICUL:NOMEM
			_cMsgOk := _cMsgOk + " / Inclusão de motorista via RDC realizada com sucesso: " + U_VEICUL:NOMEM
		EndIf

		_ctipov := AllTrim(U_VEICUL:TIPO)
		_nqtd := 0

		//===========================================================================
		// Se recebeu 3 ou mais placas força tipo de veiculo para rodo ou bi trem
		//==========================================================================
		If !empty(U_VEICUL:PLACA1)
			_nqtd++
		Endif
		If !empty(U_VEICUL:PLACA2)
			_nqtd++
		Endif
		If !empty(U_VEICUL:PLACA3)
			_nqtd++
		Endif
		If !empty(U_VEICUL:PLACA4)
			_nqtd++
		Endif

		If _nqtd == 3   //3 placas é bi trem
			_ctipov := "3"
		Endif

		If _nqtd == 4   //4 placas é bi trem
			_ctipov := "5"
		Endif

		//===========================================================================
		// Coloca em ordem crescente as placas dos veiculos
		//==========================================================================
		If _ctipov == "3" .Or. _ctipov == "5"
			_aPlaca := {}
			Aadd(_aPlaca,{"PLACA2",If(Empty(U_VEICUL:PLACA2),"ZZZZZZZZ_(VAZIO)",U_VEICUL:PLACA2)})
			Aadd(_aPlaca,{"PLACA3",If(Empty(U_VEICUL:PLACA3),"ZZZZZZZZ_(VAZIO)",U_VEICUL:PLACA3)})
			Aadd(_aPlaca,{"PLACA4",If(Empty(U_VEICUL:PLACA4),"ZZZZZZZZ_(VAZIO)",U_VEICUL:PLACA4)})
			ASort(_aPlaca, , , {|x,y| x[2] < y[2]})

			_cPlaca2 := If(_aPlaca[1,2] == "ZZZZZZZZ_(VAZIO)"," ",_aPlaca[1,2])
			_cPlaca3 := If(_aPlaca[2,2] == "ZZZZZZZZ_(VAZIO)"," ",_aPlaca[2,2])
			_cPlaca4 := If(_aPlaca[3,2] == "ZZZZZZZZ_(VAZIO)"," ",_aPlaca[3,2])

			_cPlaca2 := PadR(_cPlaca2 , _nTamPlaca," ")
			_cPlaca3 := PadR(_cPlaca3 , _nTamPlaca," ")
			_cPlaca4 := PadR(_cPlaca4 , _nTamPlaca," ")
		Else
			_cPlaca2 := PadR(U_VEICUL:PLACA2,_nTamPlaca," ")  // Placa do Veiculo
			_cPlaca3 := PadR(U_VEICUL:PLACA3,_nTamPlaca," ")  // Placa do Veiculo
			_cPlaca4 := PadR(U_VEICUL:PLACA4,_nTamPlaca," ")  // Placa do Veiculo
		EndIf

		//===========================================================================
		// Gravação do cadastro de Veículos
		//==========================================================================
		M->DA3_FILIAL := xFilial("DA3")
		M->DA3_DESC   := U_VEICUL:DESC        // Descrição do veiculo
		M->DA3_ESTPLA := U_VEICUL:ESTADO      // Estado da placa
		M->DA3_I_MUCV := ""                   // Municipio da placa
		M->DA3_MUNPLA := ""                   // Municipio da placa
		M->DA3_I_MUVG := ""                   // Municipio da placa
		M->DA3_I_MUV3 := ""                   // Municipio da placa
		M->DA3_PLACA  := ""                     // Placa do Veiculo
		M->DA3_I_PLCV := ""                     // Placa do Veiculo
		M->DA3_I_PLVG := ""                     // Placa do Veiculo
		M->DA3_I_PLV3 := ""                     // Placa do Veiculo
		M->DA3_I_TPVC := _ctipov // Tipo do veiculo
		M->DA3_RENAVA := U_VEICUL:RENAVAN1      // Renavan 1
		M->DA3_I_UFVG := U_VEICUL:ESTADO        // UF Vagão
		M->DA3_I_PLCV := PadR(U_VEICUL:PLACA1,_nTamPlaca," ")  // Placa do Veiculo
		M->DA3_PLACA  := _cPlaca2 // PadR(U_VEICUL:PLACA2,_nTamPlaca," ")  // Placa do Veiculo
		M->DA3_I_PLVG := _cPlaca3 // PadR(U_VEICUL:PLACA3,_nTamPlaca," ")  // Placa do Veiculo
		M->DA3_I_PLV3 := _cPlaca4 // PadR(U_VEICUL:PLACA4,_nTamPlaca," ")  // Placa do Veiculo
		M->DA3_I_UFCV := U_VEICUL:ESTADO      // Estado da placa
		M->DA3_I_UFVG := U_VEICUL:ESTADO
		M->DA3_I_UFV3 := U_VEICUL:ESTADO

		M->DA3_I_MUCV := U_VEICUL:MUNICI1     // Municipio da placa
		M->DA3_MUNPLA := U_VEICUL:MUNICI2     // Municipio da placa
		M->DA3_I_MUVG := U_VEICUL:MUNICI3     // Municipio da placa
		M->DA3_I_MUV3 := U_VEICUL:MUNICI4     // Municipio da placa
		M->DA3_I_UFV3 := U_VEICUL:ESTADO

		_lAlterar := .F.

		If M->DA3_I_TPVC == "1" // CARRETA
			M->DA3_I_PLCV := PadR(U_VEICUL:PLACA1,_nTamPlaca," ")   // Placa Cavalo
			M->DA3_PLACA  := PadR(U_VEICUL:PLACA2,_nTamPlaca," ")   // Placa Vagão
			M->DA3_I_UFCV := U_VEICUL:ESTADO      // Estado da placa

			M->DA3_I_MUCV := U_VEICUL:MUNICI1     // Municipio da placa
			M->DA3_MUNPLA := U_VEICUL:MUNICI2     // Municipio da placa

			M->DA3_I_PLVG := Space(_nTamPlaca)  // Placa do Veiculo
			M->DA3_I_PLV3 := Space(_nTamPlaca)  // Placa do Veiculo

		ElseIf M->DA3_I_TPVC == "2" .Or. M->DA3_I_TPVC == "4" // CAMINHAO ou UTILITARIO
			M->DA3_PLACA  := PadR(U_VEICUL:PLACA1,_nTamPlaca," ")
			M->DA3_MUNPLA := U_VEICUL:MUNICI1
			M->DA3_I_MUCV := ""
			M->DA3_I_PLCV := Space(_nTamPlaca)  // Placa do Veiculo
			M->DA3_I_PLVG := Space(_nTamPlaca)  // Placa do Veiculo
			M->DA3_I_PLV3 := Space(_nTamPlaca)  // Placa do Veiculo

		ElseIf M->DA3_I_TPVC == "3" // BI-TREM
			M->DA3_I_PLCV := PadR(U_VEICUL:PLACA1,_nTamPlaca," ")  // Placa do Veiculo
			M->DA3_PLACA  := _cPlaca2 // PadR(U_VEICUL:PLACA2,_nTamPlaca," ")  // Placa do Veiculo
			M->DA3_I_PLVG := _cPlaca3 // PadR(U_VEICUL:PLACA3,_nTamPlaca," ")  // Placa do Veiculo
			M->DA3_I_UFCV := U_VEICUL:ESTADO      // Estado da placa
			M->DA3_I_UFVG := U_VEICUL:ESTADO
			M->DA3_I_PLV3 := Space(_nTamPlaca)  // Placa do Veiculo

			M->DA3_I_MUCV := U_VEICUL:MUNICI1     // Municipio da placa
			M->DA3_MUNPLA := U_VEICUL:MUNICI2     // Municipio da placa
			M->DA3_I_MUVG := U_VEICUL:MUNICI3     // Municipio da placa

		ElseIf M->DA3_I_TPVC == "5" // RODO-TREM

			M->DA3_I_PLCV := PadR(U_VEICUL:PLACA1,_nTamPlaca," ")  // Placa do Veiculo
			M->DA3_PLACA  := _cPlaca2 // PadR(U_VEICUL:PLACA2,_nTamPlaca," ")  // Placa do Veiculo
			M->DA3_I_PLVG := _cPlaca3 // PadR(U_VEICUL:PLACA3,_nTamPlaca," ")  // Placa do Veiculo
			M->DA3_I_PLV3 := _cPlaca4 // PadR(U_VEICUL:PLACA4,_nTamPlaca," ")  // Placa do Veiculo
			M->DA3_I_UFCV := U_VEICUL:ESTADO      // Estado da placa
			M->DA3_I_UFVG := U_VEICUL:ESTADO
			M->DA3_I_UFV3 := U_VEICUL:ESTADO

			M->DA3_I_MUCV := U_VEICUL:MUNICI1     // Municipio da placa
			M->DA3_MUNPLA := U_VEICUL:MUNICI2     // Municipio da placa
			M->DA3_I_MUVG := U_VEICUL:MUNICI3     // Municipio da placa
			M->DA3_I_MUV3 := U_VEICUL:MUNICI4     // Municipio da placa
			M->DA3_I_UFV3 := U_VEICUL:ESTADO

		EndIf

		If M->DA3_I_TPVC == "1" // CARRETA
			If Empty(M->DA3_I_PLCV)
				_cMsg += " Foi informado o tipo de veículo Carreta, mas a placa do cavalo não está preenchida. "
			EndIf

			If Empty(M->DA3_PLACA)
				_cMsg += " Foi informado o tipo de veículo Carreta, mas a placa do semi-reboque não está preenchida. "
			EndIf

		ElseIf M->DA3_I_TPVC == "2" .Or. M->DA3_I_TPVC == "4" // CAMINHAO ou UTILITARIO
			If Empty(M->DA3_PLACA  )
				_cMsg += " Foi informado o tipo de veículo Caminhão ou Utilitário, mas a placa não foi informada. "
			EndIf

		ElseIf M->DA3_I_TPVC == "3" // BI-TREM
			If Empty(M->DA3_I_PLCV)
				_cMsg += " Foi informado o tipo de veículo Bi-Trem, mas a placa do cavalo não foi informada. "
			EndIf

			If Empty(M->DA3_PLACA)
				_cMsg += " Foi informado o tipo de veículo Bi-Trem, mas a placa do ultimo vagão não foi informado. "
			EndIf

			If Empty(M->DA3_I_PLVG)
				_cMsg += " Foi informado o tipo de veículo Bi-Trem, mas a placa do vagão do meio não foi informada. "
			EndIf

		ElseIf M->DA3_I_TPVC == "5" // RODO-TREM
			If Empty(M->DA3_I_PLCV)
				_cMsg += " Foi informado o tipo de veículo Rodo-Trem, mas a placa do cavalo não foi informada. "
			EndIf

			If Empty(M->DA3_PLACA)
				_cMsg += " Foi informado o tipo de veículo Rodo-Trem, mas a placa do ultimo vagão não foi informada. "
			EndIf

			If Empty(M->DA3_I_PLVG)
				_cMsg += " Foi informado o tipo de veículo Rodo-Trem, mas a placa do primeiro vagão do meio ou dolly não foi informada. "
			EndIf

		EndIf

		If !Empty(_cMsg)
			Break
		EndIf

		DA3->(DbOrderNickName("MOTORIVEIC"))
		_lAlterar := .F.
		If DA3->(DbSeek(xFilial("DA3")+M->DA4_COD+M->DA3_PLACA+M->DA3_I_PLCV+M->DA3_I_PLVG+M->DA3_I_PLV3))
			_lAlterar := .T.
		EndIf
   BEGIN TRANSACTION
		If _lAlterar
			DA3->(RecLock("DA3",.F.))
		Else
			M->DA3_COD      := U_AOMS018(M->DA3_I_TPVC)
			DA3->(RecLock("DA3",.T.))
			DA3->DA3_ATIVO  := "1"
			DA3->DA3_FILIAL := M->DA3_FILIAL  // Filial do Sistema
			DA3->DA3_COD    := M->DA3_COD
		EndIf
		DA3->DA3_MOTORI := M->DA4_COD     // Motorista
		DA3->DA3_I_TPVC := M->DA3_I_TPVC  // Tipo do veiculo
		DA3->DA3_DESC   := M->DA3_DESC    // Descrição do veiculo
		DA3->DA3_ESTPLA := M->DA3_ESTPLA  // Estado da placa
		DA3->DA3_MUNPLA := M->DA3_MUNPLA  // Municipio da placa
		DA3->DA3_PLACA  := M->DA3_PLACA   // Placa do Veiculo
		DA3->DA3_RENAVA := M->DA3_RENAVA  // Renavan
		DA3->DA3_I_MUCV := M->DA3_I_MUCV  // Municipio da placa

		DA3->DA3_I_PLCV := M->DA3_I_PLCV  // Placa do Veiculo
		DA3->DA3_I_UFCV := M->DA3_I_UFCV  // UF Cavalo
		DA3->DA3_I_MUV3 := M->DA3_I_MUV3  // Municipio da placa
		DA3->DA3_I_PLV3 := M->DA3_I_PLV3  // Placa do Veiculo
		DA3->DA3_I_UFV3 := M->DA3_I_UFV3  // UF Vagão 3

		DA3->DA3_I_PLVG := M->DA3_I_PLVG  // Placa do Veiculo
		DA3->DA3_I_MUVG := M->DA3_I_MUVG  // Municipio da placa
		DA3->DA3_I_UFVG := M->DA3_I_UFVG  // UF Vagão

		DA3->(MsUnlock())
   END TRANSACTION

		If _lAlterar
			_cMsgOk := _cMsgOk + "/ Alteração de Veiculo via RDC realizada com sucesso: " + U_VEICUL:PLACA1
		Else
			_cMsgOk := _cMsgOk + "/ Inclusão de Veiculo via RDC realizada com sucesso: " + U_VEICUL:PLACA1
		EndIf

	End Sequence

	If Empty(_cMsg)
		::U_STATUS := "SUCESSO:TRUE; "+AllTrim(_cMsgOk) // "Tudo OK na filial " + cfilant
	Else
		::U_STATUS := "SUCESSO:FALSE; "+AllTrim(_cMsg) // _cMsg
	EndIf

//===========================================================================================
// Gravação das tabela de muro do cadastro de veículos e motoristas para posterior consulta
//===========================================================================================
	ZFN->(RecLock("ZFN",.T.))
	ZFN->ZFN_FILIAL := xFilial("ZFN")	  // Filial do Sistema
	ZFN->ZFN_DATA   := Date()              // Data de Emissão
	ZFN->ZFN_HORA   := Time()
	ZFN->ZFN_TIPO   := U_VEICUL:TIPO       // Tipo do veiculo
	ZFN->ZFN_DESC   := U_VEICUL:DESC       // Descrição do veiculo
	ZFN->ZFN_PLACA1 := U_VEICUL:PLACA1	  // Placa do Veiculo 1
	ZFN->ZFN_MUNIC1 := U_VEICUL:MUNICI1	  // Municipio da placa 1
	ZFN->ZFN_PLACA2 := U_VEICUL:PLACA2     // Placa do Veiculo 2
	ZFN->ZFN_MUNIC2 := U_VEICUL:MUNICI2    // Municipio da placa 2
	ZFN->ZFN_PLACA3 := U_VEICUL:PLACA3     // Placa do Veiculo 3
	ZFN->ZFN_MUNIC3 := U_VEICUL:MUNICI3    // Municipio da placa 3
	ZFN->ZFN_PLACA4 := U_VEICUL:PLACA4     // Placa do Veiculo 4
	ZFN->ZFN_MUNIC4 := U_VEICUL:MUNICI4	  // Municipio da placa 4
	ZFN->ZFN_ESTADO := U_VEICUL:ESTADO     // Estado da placa
	ZFN->ZFN_NOMEM  := U_VEICUL:NOMEM      // Nome do motorista
	ZFN->ZFN_CPFM   := U_VEICUL:CPFM       // CPF do motorista
	ZFN->ZFN_CNPJT  := U_VEICUL:CNPJT      // CNPJ Transportadora
	ZFN->ZFN_ENDERM := U_VEICUL:ENDERECOM  // Endereco Motorista
	ZFN->ZFN_BAIRRM := U_VEICUL:BAIRROM    // Bairro Motorista
	ZFN->ZFN_MUNICM := U_VEICUL:MUNICIPIOM // Municipio Motorista
	ZFN->ZFN_ESTADM := U_VEICUL:ESTADOM    // Estado do Motorista
	ZFN->ZFN_CEPM   := U_VEICUL:CEPM       // CEP do Motorista
	ZFN->ZFN_TELEFM := U_VEICUL:TELEFONEM  // Telefone do Motorista
	ZFN->ZFN_CNHM   := U_VEICUL:CNHM       // CNH do motorista
	ZFN->ZFN_EMICNH := CTOD(U_VEICUL:EMICNH)     // Emissão da CNH
	ZFN->ZFN_VALCNH := If(Empty(U_VEICUL:VALCNH),CTOD("  /  /  "),CTOD(U_VEICUL:VALCNH)) // Validade da CNH
	ZFN->ZFN_CATCNH := U_VEICUL:CATCNH     // Categoria CNH
	ZFN->ZFN_PAIM   := U_VEICUL:PAIM       // Pai do Motorista
	ZFN->ZFN_MAEM   := U_VEICUL:MAEM       // Mãe do Motorista
	ZFN->ZFN_RGM    := U_VEICUL:RGM        // RG do Motorista
	ZFN->ZFN_TELREM := U_VEICUL:TELRECM    // Telefone recado Motorista
	ZFN->ZFN_USUARI := __CUSERID           // Codigo do Usuário
	ZFN->ZFN_DATAAL :=  Date()	          // Data de Alteração
	ZFN->ZFN_SITUAC := "P"                 // Situação do Registro
	ZFN->ZFN_CODEMP := _cCodEmpWS	      // Codigo Empresa WebServer
	ZFN->ZFN_RETORN := ::U_STATUS	      // Retorno Integracao Italac-RDC
	ZFN->(MsUnlock())

Return _lRet

WSMETHOD U_INCLUIC WSRECEIVE U_CARGA WSSEND U_STATUS WSSERVICE U_AOMS074
	Local _lRet := .T.
	Local _nTamPedido
	Local _nTamCGC
	Local _nTamPlaca
	Local _cMsg, _nI, _nJ
	Local _aFilial
	Local _cFilial:="01", _nQtdLib, _cCodigo:=""
	Local _lMV_PESOCAR:=.F.
	Local _cPedido, _nCapacVolum, _aQtdClientes
	Local _cCodEmpWS
	Local _apedidos := {}
	Local _lAteracao
	Local _cMsgOk
	Local _aAprovacao, _lAprov, _cTextoRet
	Local _cFilHabilit
	Local _cCodTransp, _cLojaTransp
	Local _cCodUsuario, _nTamCodUser
	Local _nRegAtu, _cTipoPeso
	Local _lAchouCGC
	Local _CpfMotorista, _lAchouTransp, _cCodMotorista, _cCodVeiculo
	Local _nTamCod
	Local _cPlacaCV, _cPlaca, _cPlacaVG, _cPlacaVG3
	Local _nTamTipoVeic, _cTipoVeic
	Local _cChavePesq, _aJaProces, _cPedidos
	Local _cTextoCred
	Local _cTempoIni, _cTempoFin, _nTempoTot, _cTextoTempo
	Local _aRetPallet
	Local _aPlaca := {} , P
	Local _cPlaca2, _cPlaca3 , _cPlaca4
	Local _cCodOperL, _cLojaOperL
	Local _cCodOpT,_cLojaOpT, _cCodOpA,_cLojaOpA, _cCodOpF,_cLojaOpF
	Local _aItensPallet:={}
	Local _nValMaxFrete, _nValMaxPedagio
	Local _aPedXml, _cPedXml, _aCargasAtu,_cMsgRDC
	Local _cCodCarga, _lPedOk, _cPedGerador , _nnh
    Local _cIT_NAGEND := ALLTRIM(SuperGetMV("IT_NAGEND",.F., "P;R;N"))//P=Aguardando Agenda; R=Reagendar;  N=Reagendar com Multa

	Private _lWebservice
	Private _cMsgEfetiva
	Private _cMailUsrCarga
	Private _lEnviaEmail := .F.
	Private __cUserID
	_lWebservice := .T.

//Inicializa strings para evitar errorlogs
	_cCodMotorista := "                    "
	_cPlaca := "                    "
	_cPlacaCV := "                    "
	_cPlacaVG := "                    "
	_cPlacaVG3 := "                    "
	_cTipoVeic := "                    "
	_cMsgRDC := ""

	_lPedOk     := .F.
	_aCargasAtu := {}

	Begin Sequence
		//===============================================
		// Registra o tempo inicial de criação da carga.
		//===============================================
		_cTempoIni := Time()

		//=====================================================================
		// Limpa o ambiente, liberando a licença e fechando as conexões
		//=====================================================================
		RpcClearEnv()
		RpcSetType(2)

		//===========================================================================================
		// Preparando o ambiente com a filial da carga recebida
		//===========================================================================================
		//PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01'; //_cfilial; //USER 'Administrador' PASSWORD '' ;
			//        TABLES "SA7","SB1","SB2","SB5","SB8","SBJ","SB9","SBE","SBF","SC0","SD5","SBK","SD7","SDC","SF4","SGA","SM2","SDA","SDB","SBM","ADA","SA2","DAK","DAI","DA4","ZFU","ZFV","SC9","SA1","SC5","SC6","ZP1","SX6","SX1","SX2","SX3","SM0", "SIX" ;
			//        MODULO 'OMS'
		RpcSetEnv("01", "01",,,,, {"SA7","SB1","SB2","SB5","SB8","SBJ","SB9","SBE","SBF","SC0","SD5","SBK","SD7","SDC","SF4","SGA","SM2","SDA","SDB","SBM","ADA","SA2","DAK","DAI","DA4","ZFU","ZFV","SC9","SA1","SC5","SC6","ZP1","SX6","SX1","SX2","SX3","SM0", "SIX"})

		_aFilial:= FwLoadSM0()
		_cMsg   := ""
		_cMsgOk := ""
		_nTamCGC:= TAMSX3("A2_CGC")[1]

		//===================================================================================
		// Semaforo para controle de integrações. Não permitir a inclusão em duplicidade de
		// cargas.
		//===================================================================================
		If !LockByName("U_INCLUIC"+AllTrim(U_CARGA:CODIGO) ,.F.,.F.,.T.)
			_cMsg += " A integração desta carga já está em processamento. Aguarde! "
			Break
		EndIf

		_nTamCodUser := TAMSX3("ZZL_RDCUSR")[1]
		_cCodUsuario := Posicione("ZZL",5,xfilial("ZZL")+AllTrim(Str(U_CARGA:USUCAD,_nTamCodUser)),"ZZL_CODUSU") // ZZL_FILIAL+ZZL_RDCUSR
		If Empty(_cCodUsuario)
			_cMsg := " Usuário não cadastrado no Cadastro de Usuários Italac. "
			disarmtransaction()
			Break
		EndIf
		__cUserId := _cCodUsuario // Carrega a variável do Workflow __cUserId com o código do solicitante da integração.


		//===================================================================================
		// Valida o CNPJ do Embarcador enviado pela RDC e Prepara as variáveis de Ambiente.
		//===================================================================================
		If Empty(U_CARGA:CNPJEM) .Or. Ascan(_aFilial,{|x| x[18] = Padr(U_CARGA:CNPJEM,_nTamCGC," ")}) == 0
			_cMsg += " CNPJ Embarcador não preenchido, ou não está cadastrado. "
		Else
			_nI := Ascan(_aFilial,{|x| x[18] = Padr(U_CARGA:CNPJEM,_nTamCGC," ")})
			_cFilial := _aFilial[_nI,5]
		EndIf

		_cCodEmpWS:= U_ITGETMV( 'IT_EMPWEBSE' , '000001' )

		//================================================================================
		// Define se a filial de processamento está habilitada para a integração
		// Webservice, Italac x RDC.
		//================================================================================
		_cFilHabilit := U_ITGETMV( 'IT_FILINTWS' , '' ) // Filiais habilitadas na integracao Webservice Italac x RDC.

		If !_cFilial $ _cFilHabilit // Filiais habilitadas na integracao Webservice Italac x RDC.
			_cMsg += " O CNPJ: " + U_CARGA:CNPJEM + ", Filial: " + _cFilial + ", não está habilitada para integração Webservice Italac x RDC. "
		EndIf

		SM0->(DBSETORDER(1))

		If !SM0->(DBSEEK("01"+_cFilial))
			_cMsg += " Filial: " + _cFilial + " não encotrada no SM0."
		EndIf

		If ! Empty(_cMsg)
			::U_STATUS := _cMsg
			disarmtransaction()
			Break
		EndIf
		cFilAnt := _cFilial

		//===========================================================================================
		//Reinicializando váriaveis que dependem do ambiente
		//===========================================================================================
		_nTamPedido := TAMSX3("C5_NUM")[1]
		_nTamCGC    := TAMSX3("A2_CGC")[1]
		_cTipoPeso  := GetMv('MV_PESOCAR')
		_nTamCod    := TAMSX3("DAK_I_CARG")[1]
		_nTamTipoVeic:= TAMSX3("DA3_I_TPVC")[1]

		_lMV_PESOCAR := .F.
		If AllTrim(_cTipoPeso) == "L"
			_lMV_PESOCAR := .T.
		EndIf

		SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM
		SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		DA4->(DbSetOrder(3)) // DA4_FILIAL+DA4_CGC  // CPF MOTORISTA
		SA2->(DbSetOrder(3)) // A2_FILIAL+A2_CGC
		DAK->(DbSetOrder(1))
		DAI->(DbSetOrder(4)) // DAI_FILIAL+DAI_PEDIDO+DAI_COD+DAI_SEQCAR
		SC9->(DbSetOrder(1)) // C9_FILIAL + C9_PEDIDO

		_nTamPlaca  := TAMSX3("DA3_PLACA")[1]

		//==============================================================================================================================
		// Se os registros das tabelas DAK e DAI já foram criados, mas ocorreu erro na
		// integração com o RDC e a integração foi reenviada.
		// Armazena dados no array _aCargasAtu para atualizar os dados da tabela DAK e DAI com os novos RECNOS RDC e o novo numero de
		// Viagem e finaliza a integração.
		//                 //    Renco DAK       Recno DAI          DAK_I_RECR                        DAK_I_CARG
		// Aadd(_aCargasAtu, {DAK->(Recno()), DAI->(Recno()), AllTrim(Str(U_CARGA:RECNUM,10)), Padr(U_CARGA:CODIGO,_nTamCod," ")})
		//==============================================================================================================================
		_aPedXml := {}
		_cCodCarga := ""
		_aCargasAtu := {}
		For _nI := 1 to Len( U_CARGA:ITENS)
			//==================================================================================
			// Verifica se este pedido já existe lançado para alguma Carga.
			//==================================================================================
			Aadd(_aPedXml,alltrim(U_CARGA:ITENS[_nI]:PEDIDO))

			DAI->(Dbsetorder(4))  // DAI_FILIAL+DAI_PEDIDO+DAI_COD+DAI_SEQCAR
			If DAI->(DbSeek(_cFilial+PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," ")))
				If Empty(_cCodCarga)
					_cCodCarga := DAI->DAI_COD
				EndIf
				DAK->(Dbsetorder(1))
				If DAK->(DbSeek(DAI->DAI_FILIAL+DAI->DAI_COD))
					If SC9->(DbSeek(_cFilial+PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," ")))
						//                    Renco DAK       Recno DAI          DAK_I_RECR                        DAK_I_CARG
						Aadd(_aCargasAtu, {DAK->(Recno()), DAI->(Recno()), AllTrim(Str(U_CARGA:RECNUM,10)), Padr(U_CARGA:CODIGO,_nTamCod," ")})
					EndIf
				EndIf
			EndIf
		Next

		If Len(_aCargasAtu) > 0
			//==================================================================================
			// Verifica se os pedidos de vendas do XML são exatamente os mesmos da tabela DAI.
			//==================================================================================
			_nI := 0
			_lPedOk  := .T.
			_nRegAtu := _aCargasAtu[1,1]

			DAI->(DbSetOrder(1)) // DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN+DAI_PEDIDO
			DAI->(DbSeek(_cFilial+_cCodCarga))
			Do While ! DAI->(Eof()) .And. DAI->(DAI_FILIAL+DAI_COD) == _cFilial+_cCodCarga
				_nI += 1

				_nJ := Ascan(_aPedXml, DAI->DAI_PEDIDO)

				_cPedGerador := Posicione('SC5',1,_cFilial+DAI->DAI_PEDIDO,"C5_I_PEDGE") // Indica se o pedido de vendas é
				//um Pedido Gerador ou um Pedido de Pallet.

				If _nJ == 0 .And. _cPedGerador = 'S'
					_lPedOk := .F.
					Exit
				EndIf

				DAI->(DbSKip())
			EndDo

			If ! _lPedOk
				_cMsg += " Os pedidos de vendas informados já estão em outra carga. "
				Break
			EndIf

			_aPedXml := {} // Limpa o conteúdo da variável para ser reutilizada.

			//==================================================================================
			// Valida se os pedidos de pallet estão corretos.
			//==================================================================================
			_aItensPallet := {}

			If AllTrim(U_CARGA:PRECARGA) == "N" // Não é uma précarga.
				For _nI := 1 to Len( U_CARGA:ITENS)

					//"1-Pallet Chep , "2-Estivada , "3-Pallet PBR , "4-Pallet Descartavel , "5-Pallet Chep Retorno", "6-Pallet PBR Retorno , 7-OUTROS
					If (AllTrim(U_CARGA:ITENS[_nI]:TPCARG) $ TP_GERA_PALET .AND. U_CARGA:ITENS[_nI]:QTDPALLET # 0) .OR. (Len(AllTrim(U_CARGA:CNPJTRA)) < 14)

						If SC5->(DbSeek(_cFilial+PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," ")))

							_aRetPallet := U_AOMS074Z(U_CARGA:ITENS[_nI]:TPCARG)  // {_lRet,_cProduto, "Cliente: "+_cCliPed +"- Loja: "+_cLjCliPed }
							If AllTrim(U_CARGA:ITENS[_nI]:TPCARG) $ "5,6"//"5-Pallet Chep Retorno","6-Pallet PBR Retorno"
								//Verifica se transportador que será gerado o pallet está bloqueado
								_cCodTransp  := ""
								_cLojaTransp := ""
								_lAchouTransp := .F.
								SA2->(Dbsetorder(3))
								SA2->(DbSeek(xFilial("SA2")+Padr(U_CARGA:CNPJTRA,_nTamCGC," ")))
								Do While ! SA2->(Eof()) .And. SA2->(A2_FILIAL+A2_CGC) == xFilial("SA2")+Padr(U_CARGA:CNPJTRA,_nTamCGC," ")
									If SA2->A2_I_CLASS $ "T/A"  .AND. SA2->A2_MSBLQL != '1'
										_lAchouTransp := .T.
									EndIf
									SA2->(DbSkip())
								EndDo

								If ! _lachouTransp
									_cMsg += " O cliente para o transportador da carga não é válido! (" + Padr(U_CARGA:CNPJTRA,_nTamCGC," ") + ") "
								EndIf
							EndIf

							If ! _aRetPallet[1]
								If U_Itgetmv("IT_VLTES74", .F.)
									_cMsg += " A TES configurada para o pallet de código: "+_aRetPallet[2]+", para o cliente: "+_aRetPallet[3]+", é inválida. "
								EndIf
							Else
								_cLocal:=Posicione('SC6',1,_cFilial+SC5->C5_NUM,"C6_LOCAL")//SC5 já esta prosicionado
								If _cLocal != '36'
									_cLocal:=Posicione('SBZ',1,_cFilial+_aRetPallet[2],"BZ_LOCPAD")
								EndIf

								If AsCan(_aItensPallet, _cFilial+padr(_aRetPallet[2],15)+_cLocal ) = 0
									Aadd(_aItensPallet, _cFilial+padr(_aRetPallet[2],15)+_cLocal )
								EndIf

								If !(AOMS74Travou( {} , _aItensPallet , @_cMsgEfetiva ))

									_cMsg := _cMsgEfetiva
									MsUnLockAll()
									DisarmTransaction()
									Break

								EndIf

							EndIf

							If ! Empty(_cMsg)
								Disarmtransaction()
								Break
							EndIf

						EndIf
					EndIf
				Next

				If Len(_aItensPallet) > 0

					DAK->(DbGoto(_nRegAtu))

					If !(AOMS74Travou( {} , _aItensPallet , @_cMsgEfetiva ))

						_cMsg := _cMsgEfetiva
						MsUnLockAll()
						DisarmTransaction()
						Break

					EndIf

					//Inicia Watchdog da inclusão de carga e inclusão/liberação do pedido de pallet
					PutGlbValue("INCLUIC"+AllTrim(U_CARGA:CODIGO)+ALLTRIM(STR(ThreadID())),"Alterando")
					lret := startjob("U_AOMS074W",getenvserver(),.F.,U_ITGETMV( 'IT_WEBTO' , 50 ),ThreadID(),"INCLUIC"+AllTrim(U_CARGA:CODIGO)+ALLTRIM(STR(ThreadID())),_cfilial + "/" + AllTrim(U_CARGA:CODIGO))


					_ccoddak := DAK->DAK_COD

					DAK->(RecLock("DAK", .F.))
					DAK->DAK_I_PREC := "1"
					DAK->(MsUnLock())

					U_OM20MNUP(,,,.T.)

					//Reposiciona DAK para ver se geração de pallet não causou problemas na leitura
					//Acontece quando não tem saldo de pallets e dá problema na liberação do pedido gerado
					DAK->(DbGoto(_nRegAtu))

					//Finaliza watchdog de inclusão de carga
					PutGlbValue("INCLUIC"+AllTrim(U_CARGA:CODIGO)+ALLTRIM(STR(ThreadID())),"Completado")


					If !(DAK->DAK_COD == _ccoddak)
						_cMsg := "Falha na geração de pallets, verifique o saldo de pallets"
						MsUnLockAll()
						DisarmTransaction()
						Break

					EndIf
				EndIf
			EndIf

			Break
		EndIf

		//==================================================================================
		// Valida dados da carga criada.
		//==================================================================================
		DAK->(DBOrderNickname("CODFIL_RDC")) // DAK->(Dbsetorder(8)) // DAK->(Dbsetorder(7))
		If Empty(U_CARGA:CODIGO)
			_cMsg += " Código de carga RDC não preenchido. "
		ElseIf DAK->(DbSeek(_cFilial+U_ITKEY(U_CARGA:CODFIL, "DAK_I_FRDC")+U_ITKEY(U_CARGA:CODIGO, "DAK_I_CARG"))) // DbSeek(_cFilial+U_CARGA:CODIGO)

			_lAteracao:= .T.
			_cCodigo  := DAK->DAK_COD

			If AllTrim(U_CARGA:PRECARGA) == "N" // Não é uma précarga.
				If DAK->DAK_I_PREC == "2"
					If !Empty(DAK->DAK_I_RECR)
						If Alltrim(DAK->DAK_I_RECR) == AllTrim(Str(U_CARGA:RECNUM,10))
							_cMsgOk := " Efetivação de carga RDC: "+AllTrim(DAK->DAK_I_CARG)+", integrada com sucesso! "
							_cMsgRDC := " Numero de Carga Protheus: NRSOLI=" + DAK->DAK_COD
							Break
						Else
							_cMsg += " Este codigo de carga "+AllTrim(DAK->DAK_I_CARG)+" / "+Alltrim(DAK->DAK_I_RECR)+" , já foi efetivado e não pode ser efetivado novamente. "
						EndIf
					Else
						_cMsg += " Este codigo de carga "+AllTrim(DAK->DAK_I_CARG)+" / "+Alltrim(DAK->DAK_I_RECR)+" , já foi efetivado e não pode ser efetivado novamente. "
					EndIf
				EndIf
			Else
				If !Empty(DAK->DAK_I_RECR)
					If Alltrim(DAK->DAK_I_RECR) == AllTrim(Str(U_CARGA:RECNUM,10))
						_cMsgOk := " Carga RDC: "+AllTrim(DAK->DAK_I_CARG)+", integrada com sucesso! "
						_cMsgRDC := " Numero de Carga Protheus: NRSOLI=" + DAK->DAK_COD
						disarmtransaction()
						Break
					Else
						_cMsg += " Esta précarga já existe. "
					EndIf
				Else
					_cMsg += " Esta précarga já existe. "
				EndIf
			EndIf

		EndIf
 
		//===========================================================================================
		// Valida valores de frete e de pedágio.
		//===========================================================================================
		_nValMaxFrete   := U_ItGetMv("IT_MAXFRETE", 100000)
		_nValMaxPedagio := U_ItGetMv("IT_MAXPEDAG", 100000)

		If U_CARGA:FRETE > _nValMaxFrete
			_cMsg += " O valor de frete informado para esta carga, supera o limite máximo definido no parâmetro IT_MAXFRETE. "
		EndIf

		If U_CARGA:PEDAGIO > _nValMaxPedagio
			_cMsg += " O valor de pedágio informado para esta carga, supera o limite máximo definido no parâmetro IT_MAXPEDAG. "
		EndIf

		//===========================================================================================
		// Valida se pedidos podem ser lockados, util para definir se já não está rodando o processo
		//===========================================================================================
		_aPedXml := {}
		_cPedXml := ""

		_aItensPallet:={}
		For _nI := 1 to Len( U_CARGA:ITENS)

			SC5->(Dbsetorder(1))
			If !SC5->(DbSeek(_cFilial+PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," ")))

				_cMsg += " O pedido  " + U_CARGA:ITENS[_nI]:PEDIDO + " não pode ser localizado."

			Elseif !SC5->(MsRLock(SC5->(RECNO())))

				_cMsg += " No momento este Pedido de Vendas está sendo utilizado por outro usuário e não pode ser manipulado. Vefifique se já não há cargas para ele e tente integrar novamente mais tarde: " + U_CARGA:ITENS[_nI]:PEDIDO

			ElseIf !EMPTY(SC5->C5_NOTA)

				_cMsg += " Pedido não disponível para geração da carga/viagem RDC Nr: " + AllTrim(U_CARGA:CODIGO) + "! Pedido de vendas: "+ AllTrim(U_CARGA:ITENS[_nI]:PEDIDO) +" já faturado! "

			Elseif posicione("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_MSBLQL") == '1'

				_cMsg += "Cliente do pedido bloqueado no cadastro "+AllTrim(SC5->C5_CLIENTE+"/"+SC5->C5_LOJACLI)+"." + " Pedido de vendas: "+ AllTrim(U_CARGA:ITENS[_nI]:PEDIDO)

			ElseIf  SC5->C5_TIPO = 'N' .AND. SC5->C5_I_AGEND $  _cIT_NAGEND //P=Aguardando Agenda; R=Reagendar; N=Reagendar 

			    _cMsg += " Não é possível montar carga com o pedido "+AllTrim(SC5->C5_NUM)+" por causa do Tipo Entrega = "+SC5->C5_I_AGEND+"."

			ElseIf SC5->C5_I_BLSLD = 'S'

			    _cMsg += " Não é possível montar carga com o pedido "+AllTrim(SC5->C5_NUM)+" por causa do Bloqueio de carregamento por saldo ["+SC5->C5_I_BLSLD +"]."

			Endif

			//==================================================================================
			// Verifica se este pedido já existe lançado para alguma Carga.
			//==================================================================================
			DAI->(Dbsetorder(4))
			If DAI->(DbSeek(_cFilial+PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," ")))
				DAK->(Dbsetorder(1))
				If DAK->(DbSeek(DAI->DAI_FILIAL+DAI->DAI_COD))
					If DAK->DAK_I_CARG <> Padr(U_CARGA:CODIGO,_nTamCod," ")
						_cMsg += " Já existe o numero de pedido: " + AllTrim(U_CARGA:ITENS[_nI]:PEDIDO) + ", lançado na filial: " + _cFilial + ", para carga/viagem: " + AllTrim(DAK->DAK_I_CARG) + "."
					EndIf
				EndIf
			EndIf

			//==================================================================================
			// Incluir aqui validações referentes aos pedidos de pallets.
			//==================================================================================
			//"1-Pallet Chep , "2-Estivada , "3-Pallet PBR , "4-Pallet Descartavel , "5-Pallet Chep Retorno", "6-Pallet PBR Retorno , 7-OUTROS
			IF (AllTrim(U_CARGA:ITENS[_nI]:TPCARG) $ TP_GERA_PALET .AND. U_CARGA:ITENS[_nI]:QTDPALLET # 0) .OR. (Len(AllTrim(U_CARGA:CNPJTRA)) < 14)

				_aRetPallet := U_AOMS074Z(U_CARGA:ITENS[_nI]:TPCARG)  // {_lRet,_cProduto, "Cliente: "+_cCliPed +"- Loja: "+_cLjCliPed }

				If AllTrim(U_CARGA:ITENS[_nI]:TPCARG) $ "5,6"//"5-Pallet Chep Retorno","6-Pallet PBR Retorno"

					//Verifica se transportador que será gerado o pallet está bloqueado
					_cCodTransp  := ""
					_cLojaTransp := ""
					_lAchouTransp := .F.
					SA2->(Dbsetorder(3))
					SA2->(DbSeek(xFilial("SA2")+Padr(U_CARGA:CNPJTRA,_nTamCGC," ")))
					Do While ! SA2->(Eof()) .And. SA2->(A2_FILIAL+A2_CGC) == xFilial("SA2")+Padr(U_CARGA:CNPJTRA,_nTamCGC," ")
						If SA2->A2_I_CLASS $ "T/A"  .AND. SA2->A2_MSBLQL != '1'

							_lAchouTransp := .T.

						EndIf
						SA2->(DbSkip())
					EndDo

					If ! _lachouTransp

						_cMsg += " O cliente para o transportador da carga não é válido! (" + Padr(U_CARGA:CNPJTRA,_nTamCGC," ") + ") "

					Endif

				Endif

				If ! _aRetPallet[1] .and. empty(_cMsg)

					If u_itgetmv("IT_VLTES74", .F.)
						_cMsg += " A TES configurada para o pallet de código: "+_aRetPallet[2]+", para o cliente: "+_aRetPallet[3]+", é inválida. "
					Endif

				ELSE

					_cLocal:=Posicione('SC6',1,SC5->C5_FILIAL+SC5->C5_NUM,"C6_LOCAL")//SC5 já esta prosicionado
					If _cLocal != '36'
						_cLocal:=Posicione('SBZ',1,SC5->C5_FILIAL+_aRetPallet[2],"BZ_LOCPAD")
					Endif

					IF ASCAN(_aItensPallet, SC5->C5_FILIAL+padr(_aRetPallet[2],15)+_cLocal ) = 0
						AADD(_aItensPallet, SC5->C5_FILIAL+padr(_aRetPallet[2],15)+_cLocal )
					ENDIF

				EndIf

			EndIf

			//============================================================================================
			// Verifica se existe numeros de pedidos em duplicidade no XML.
			//============================================================================================
			_nJ := Ascan(_aPedXml, PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," "))
			If _nJ > 0
				_cPedXml += PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," ") + "/"
			Else
				Aadd(_aPedXml, PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," "))
			EndIf
		Next

		//============================================================================================
		// Verifica se existe numeros de pedidos em duplicidade no XML.
		//============================================================================================
		If ! Empty(_cPedXml)
			_cMsg += " Numero de pedidos de vendas em duplicidade no XML: [" + _cPedXml + "]."
		EndIf

		//===================================================================================
		// Valida se os dados enviados pela RDC estão corretos.
		//===================================================================================
		If AllTrim(U_CARGA:PRECARGA) == "N" // Não é uma précarga.
			If Empty(U_CARGA:TIPO)
				_cMsg += " O tipo de transporte deve ser preenchido. "
				_ccargatp := AllTrim(U_CARGA:TIPO)
			Else
				_ccargatp := AllTrim(U_CARGA:TIPO)
			EndIf
		EndIf

		_nqtd := 0

		//===========================================================================
		// Se recebeu 3 ou mais placas força tipo de veiculo para rodo ou bi trem
		//==========================================================================
		If !empty(alltrim(U_CARGA:PLACA1))
			_nqtd++
		Endif
		If !empty(alltrim(U_CARGA:PLACA2))
			_nqtd++
		Endif
		If !empty(alltrim(U_CARGA:PLACA3))
			_nqtd++
		Endif
		If !empty(alltrim(U_CARGA:PLACA4))
			_nqtd++
		Endif

		If _nqtd == 3   //3 placas é bi trem
			_ccargatp := "3"
		Endif

		If _nqtd == 4   //4 placas é bi trem
			_ccargatp := "5"
		Endif


		_cPlacaCV  := Space(_nTamPlaca)
		_cPlaca    := Space(_nTamPlaca)
		_cPlacaVG  := Space(_nTamPlaca)
		_cPlacaVG3 := Space(_nTamPlaca)

		//===========================================================================
		// Coloca em ordem crescente as placas dos veiculos
		//==========================================================================
		If _ccargatp == "3" .Or. _ccargatp == "5"
			_aPlaca := {}
			Aadd(_aPlaca,{"PLACA2",If(Empty(U_CARGA:PLACA2),"ZZZZZZZZ_(VAZIO)",U_CARGA:PLACA2)})
			Aadd(_aPlaca,{"PLACA3",If(Empty(U_CARGA:PLACA3),"ZZZZZZZZ_(VAZIO)",U_CARGA:PLACA3)})
			Aadd(_aPlaca,{"PLACA4",If(Empty(U_CARGA:PLACA4),"ZZZZZZZZ_(VAZIO)",U_CARGA:PLACA4)})
			ASort(_aPlaca, , , {|x,y| x[2] < y[2]})

			_cPlaca2 := If(_aPlaca[1,2] == "ZZZZZZZZ_(VAZIO)"," ",_aPlaca[1,2])
			_cPlaca3 := If(_aPlaca[2,2] == "ZZZZZZZZ_(VAZIO)"," ",_aPlaca[2,2])
			_cPlaca4 := If(_aPlaca[3,2] == "ZZZZZZZZ_(VAZIO)"," ",_aPlaca[3,2])

			_cPlaca2 := PadR(_cPlaca2 , _nTamPlaca," ")
			_cPlaca3 := PadR(_cPlaca3 , _nTamPlaca," ")
			_cPlaca4 := PadR(_cPlaca4 , _nTamPlaca," ")
		Else
			_cPlaca2 := PadR(U_CARGA:PLACA2,_nTamPlaca," ")  // Placa do Veiculo
			_cPlaca3 := PadR(U_CARGA:PLACA3,_nTamPlaca," ")  // Placa do Veiculo
			_cPlaca4 := PadR(U_CARGA:PLACA4,_nTamPlaca," ")  // Placa do Veiculo
		EndIf

		If !Empty(U_CARGA:TIPO) .And. ! (_ccargatp $ "12345" )
			_cMsg += " Tipo de transporte inválido. "
		ElseIf !Empty(U_CARGA:TIPO)

			If _ccargatp == "1" // CARRETA
				_cPlacaCV := PadR(U_CARGA:PLACA1,_nTamPlaca," ")   // Placa Cavalo
				_cPlaca   := PadR(U_CARGA:PLACA2,_nTamPlaca," ")   // Placa Vagão

				If Empty(_cPlacaCV)
					_cMsg += " Foi informado o tipo de veículo Carreta, mas a placa do cavalo não está preenchida. "
				EndIf

				If Empty(_cPlaca)
					_cMsg += " Foi informado o tipo de veículo Carreta, mas a placa do semi-reboque não está preenchida. "
				EndIf

			ElseIf _ccargatp == "2" .Or. _ccargatp == "4" // CAMINHAO ou UTILITARIO
				_cPlaca  := PadR(U_CARGA:PLACA1,_nTamPlaca," ")

				If Empty(_cPlaca)
					_cMsg += " Foi informado o tipo de veículo Caminhão ou Utilitário, mas a placa não foi informada. "
				EndIf

			ElseIf _ccargatp == "3" // BI-TREM
				_cPlacaCV := PadR(U_CARGA:PLACA1,_nTamPlaca," ")  // Placa do Veiculo
				_cPlaca   := _cPlaca2 // PadR(U_CARGA:PLACA2,_nTamPlaca," ")  // Placa do Veiculo
				_cPlacaVG := _cPlaca3 // PadR(U_CARGA:PLACA3,_nTamPlaca," ")  // Placa do Veiculo

				If Empty(_cPlacaCV)
					_cMsg += " Foi informado o tipo de veículo Bi-Trem, mas a placa do cavalo não foi informada. "
				EndIf

				If Empty(_cPlaca)
					_cMsg += " Foi informado o tipo de veículo Bi-Trem, mas a placa do ultimo vagão não foi informado. "
				EndIf

				If Empty(_cPlacaVG)
					_cMsg += " Foi informado o tipo de veículo Bi-Trem, mas a placa do vagão do meio não foi informada. "
				EndIf

			ElseIf _ccargatp == "5" // RODO-TREM
				_cPlacaCV  := PadR(U_CARGA:PLACA1,_nTamPlaca," ")  // Placa do Veiculo
				_cPlaca    := _cPlaca2 // PadR(U_CARGA:PLACA2,_nTamPlaca," ")  // Placa do Veiculo
				_cPlacaVG  := _cPlaca3 // PadR(U_CARGA:PLACA3,_nTamPlaca," ")  // Placa do Veiculo
				_cPlacaVG3 := _cPlaca4 // PadR(U_CARGA:PLACA4,_nTamPlaca," ")  // Placa do Veiculo

				If Empty(_cPlacaCV)
					_cMsg += " Foi informado o tipo de veículo Rodo-Trem, mas a placa do cavalo não foi informada. "
				EndIf

				If Empty(_cPlaca)
					_cMsg += " Foi informado o tipo de veículo Rodo-Trem, mas a placa do ultimo vagão não foi informada. "
				EndIf

				If Empty(_cPlacaVG)
					_cMsg += " Foi informado o tipo de veículo Rodo-Trem, mas a placa do primeiro vagão do meio ou dolly não foi informada. "
				EndIf
			EndIf
			DA3->(DbOrderNickName("TIPOMOTVEI")) //DA3_FILIAL+DA3_I_TPVC+DA3_MOTORI+DA3_PLACA+DA3_I_PLCV+DA3_I_PLVG+DA3_I_PLV3
		EndIf
		If Empty(U_CARGA:RECNUM)
			_cMsg += " Numero de controle Recno RDC não preenchido. "
		EndIf

		_lAteracao := .F.


		If Empty(U_CARGA:PESOB)
			_cMsg += " Peso bruto mercadoria não preenchido. "
		EndIf

		If Empty(U_CARGA:PESOL)
			_cMsg += " Peso liquido mercadoria não preenchido.  "
		EndIf

		If Empty(U_CARGA:VALOR)
			_cMsg += " Valor da carga não preechido. "
		EndIf

		If Empty(U_CARGA:DATAE)
			_cMsg += " Data de emissão da carga não preenchido. "
		EndIf

		_cCodTransp  := "" // SA2->A2_COD
		_cLojaTransp := "" // SA2->A2_LOJA

		If AllTrim(U_CARGA:PRECARGA) == "N" // Não é uma précarga.
			If Empty(U_CARGA:CNPJTRA)
				_cMsg += " O CNPJ da transportadora deve ser preenchido. "
			EndIf
		EndIf

		_cAuto:=""
		_cCond:=""
		_cCodTransp  := ""
		_cLojaTransp := ""
		_lAchouTransp := .F.
		SA2->(Dbsetorder(3))
		SA2->(DbSeek(xFilial("SA2")+Padr(U_CARGA:CNPJTRA,_nTamCGC," ")))
		Do While ! SA2->(Eof()) .And. SA2->(A2_FILIAL+A2_CGC) == xFilial("SA2")+Padr(U_CARGA:CNPJTRA,_nTamCGC," ")
			If SA2->A2_I_CLASS $ "T/A"
				_cCodTransp  := SA2->A2_COD
				_cLojaTransp := SA2->A2_LOJA

				_cAuto       := SA2->A2_I_AUT
				_cCond       := SA2->A2_COND
				If SA2->A2_I_CLASS == "T"
					_cCodTransp  := SA2->A2_COD
					_cLojaTransp := SA2->A2_LOJA
					_cAuto       := SA2->A2_I_AUT
					_cCond       := SA2->A2_COND
				EndIf

				_lAchouTransp := .T.
			EndIf
			SA2->(DbSkip())
		EndDo

		If ! _lAchouTransp
			_cMsg += " O CNPJ/CPF da transportadora/Autonomo não está cadastrado: "+Padr(U_CARGA:CNPJTRA,_nTamCGC," ")
		ELSEIF Len(AllTrim(U_CARGA:CNPJTRA)) < 14//CPF
			IF EMPTY(_cAuto) .OR. EMPTY(_cCond)
				_cMsg += " O Cod. Autonomo ou a Cond. Pag. não preenchido no cadastrado de Forn.: "+_cCodTransp+_cLojaTransp
			ENDIF
		EndIf

		_CpfMotorista := ""
		_cCodVeiculo   := ""
		DA4->(Dbsetorder(3))
		If AllTrim(U_CARGA:PRECARGA) == "N" // Não é uma précarga.
			If Empty(U_CARGA:CPFM)
				_cMsg += " O CPF do motorista precisa ser preenchido. "
			ElseIf ! DA4->(DbSeek(xFilial("DA4")+Padr(U_CARGA:CPFM,_nTamCGC," ")))
				_cMsg += " O CPF do motorista não está cadastrado.  "
			Else
				_CpfMotorista := Padr(U_CARGA:CPFM,_nTamCGC," ")
			EndIf
		EndIf

		//=========================================================================================
		// Localizar o código do motorista pelo CPF + Codigo da Transportadora.
		//=========================================================================================
		_acodmot := {}
		If ! Empty(_cCodTransp) .And. ! Empty(_CpfMotorista)
			_lAchouTransp := .F.
			Do While ! DA4->(Eof()) .And. DA4->(DA4_FILIAL+DA4_CGC) == xFilial("DA4")+Padr(U_CARGA:CPFM,_nTamCGC," ")
				If DA4->DA4_FORNEC == _cCodTransp .And. DA4->DA4_LOJA == _cLojaTransp
					_lAchouTransp := .T.
					aadd(_acodmot,DA4->DA4_COD)
				EndIf
				DA4->(DbSkip())
			EndDo
			If ! _lAchouTransp
				_cMsg += " Não foi localizado nenhum registro para o CPF de motorista vinculado ao código da transportadora: "+_cCodTransp+_cLojaTransp+", no cadastro de motoristas."
			EndIf
		EndIf

		//=========================================================================================
		//Se for pallet retorno valida se o transportador existe no cadastro de clientes
		//=========================================================================================
		For _ni := 1 to Len(U_CARGA:ITENS)
			If AllTrim(U_CARGA:ITENS[_nI]:TPCARG) == '5' .or. AllTrim(U_CARGA:ITENS[_nI]:TPCARG) == '6'
				//=================================================================================================
				// Valida se o transportador está cadastrado no cadastro de clintes. chamado 24363.
				//=================================================================================================
				SA1->(Dbsetorder(3))
				If ! (SA1->(Dbseek(xFilial("SA1")+U_ITKEY(U_CARGA:CNPJTRA,"A1_CGC"))))
					_cMsg += " Carga contém pallet retorno e o transportador de CNPJ " + Padr(U_CARGA:CNPJTRA,_nTamCGC," ") + " não foi encontrado no cadastro de clientes!"
				EndIf
			Endif
		Next

		//=========================================================================================
		// Localizar Tipo de Veículo +  Código do Motorista + Placa do Veículo
		//=========================================================================================
		_lAchouMotorista := .F.
		_cTipoVeic := Padr(_ccargatp,_nTamTipoVeic," ")

		DA3->(Dbsetorder(9))

		_nnh := 1

		For _nnh := 1 to len(_acodmot)

			If _ccargatp == "1" // CARRETA
				If DA3->(DbSeek(xFilial("DA3")+_cTipoVeic+_acodmot[_nnh]+_cPlaca+_cPlacaCV))
					_lAchouMotorista := .T.
					_cCodVeiculo := DA3->DA3_COD
					_cCodMotorista := _acodmot[_nnh]
					exit
				EndIf
			ElseIf _ccargatp == "2" .Or. _ccargatp == "4" // CAMINHAO ou UTILITARIO
				If DA3->(DbSeek(xFilial("DA3")+_cTipoVeic+_acodmot[_nnh]+_cPlaca))
					_lAchouMotorista := .T.
					_cCodVeiculo := DA3->DA3_COD
					_cCodMotorista := _acodmot[_nnh]
					exit
				EndIf

			ElseIf _ccargatp == "3" // BI-TREM
				If DA3->(DbSeek(xFilial("DA3")+_cTipoVeic+_acodmot[_nnh]+_cPlaca+_cPlacaCV+_cPlacaVG))
					_lAchouMotorista := .T.
					_cCodVeiculo := DA3->DA3_COD
					_cCodMotorista := _acodmot[_nnh]
					exit
				EndIf
			ElseIf _ccargatp == "5" // RODO-TREM
				If DA3->(DbSeek(xFilial("DA3")+_cTipoVeic+_acodmot[_nnh]+_cPlaca+_cPlacaCV+_cPlacaVG+_cPlacaVG3))
					_lAchouMotorista := .T.
					_cCodVeiculo := DA3->DA3_COD
					_cCodMotorista := _acodmot[_nnh]
					exit
				EndIf

			EndIf

		Next

		If ! _lAchouMotorista
			_cMsg += " Não foi localizado veiculo vinculado ao motorista informado: Tipo: "+_cTipoVeic+" - Motorista: " + _cCodMotorista
			_cMsg += " - Placa 01: "+_cPlaca+" - Placa 02: "+_cPlacaCV+" - Placa 03: "+_cPlacaVG+" - Placa 04: "+_cPlacaVG3
		EndIf

		SC5->(Dbsetorder(1))

		For _nI := 1 to Len( U_CARGA:ITENS)
			If Empty(U_CARGA:ITENS[_nI]:CODIGO)
				_cMsg += " Código de carga do item não preenchido. Item: "+If(!Empty(U_CARGA:ITENS[_nI]:ITEM),Str(U_CARGA:ITENS[_nI]:ITEM,5),"")+" "
			ElseIf AllTrim(U_CARGA:CODIGO) <> AllTrim(U_CARGA:ITENS[_nI]:CODIGO)
				_cMsg += " Código de carga do item difere do código de carga da capa. Item: "+If(!Empty(U_CARGA:ITENS[_nI]:ITEM),Str(U_CARGA:ITENS[_nI]:ITEM,5),"")+" "
			EndIf

			If Empty(U_CARGA:ITENS[_nI]:ITEM)
				_cMsg += " Item de carga não preenchido. "
			EndIf

			If Empty(U_CARGA:ITENS[_nI]:PEDIDO)
				_cMsg += " Numero de pedido de vendas não preenchido. Item: "+If(!Empty(U_CARGA:ITENS[_nI]:ITEM),Str(U_CARGA:ITENS[_nI]:ITEM,5),"")+" "
			ElseIf ! SC5->(DbSeek(_cFilial+PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," ")))
				_cMsg += " Numero de pedido de vendas não cadastrado. Item: "+If(!Empty(U_CARGA:ITENS[_nI]:ITEM),Str(U_CARGA:ITENS[_nI]:ITEM,5),"")+" "
			EndIf
			//"1-Pallet Chep , "2-Estivada , "3-Pallet PBR , "4-Pallet Descartavel , "5-Pallet Chep Retorno", "6-Pallet PBR Retorno , 7-OUTROS
			If Empty(U_CARGA:ITENS[_nI]:TPCARG) .Or. ! (AllTrim(U_CARGA:ITENS[_nI]:TPCARG) $ "1234567")
				_cMsg += " Tipo de carga não preenchido ou inválido. Item: "+If(!Empty(U_CARGA:ITENS[_nI]:ITEM),Str(U_CARGA:ITENS[_nI]:ITEM,5),"")+" "
			EndIf

			If !Empty(U_CARGA:ITENS[_nI]:CNPJOP)

				SA2->(Dbsetorder(3))
				SA2->(DbSeek(xFilial("SA2")+Padr(U_CARGA:ITENS[_nI]:CNPJOP,_nTamCGC," ")))

				_lAchouCGC := .F.

				Do While ! SA2->(Eof()) .And. SA2->(A2_FILIAL+A2_CGC) == xFilial("SA2")+Padr(U_CARGA:ITENS[_nI]:CNPJOP,_nTamCGC," ")
					If SA2->A2_I_CLASS $ "T/A/F"  // SA2->A2_I_CLASS == "T"
						_lAchouCGC := .T.
						Exit
					EndIf
					SA2->(DbSkip())
				EndDo

				If ! _lAchouCGC
					_cMsg += " Operador logistico não cadastrado no Protheus. Item: " +If(!Empty(U_CARGA:ITENS[_nI]:ITEM),Str(U_CARGA:ITENS[_nI]:ITEM,5),"")+" "
				EndIf
			EndIf

			SA2->(Dbsetorder(3))
			If !Empty(U_CARGA:ITENS[_nI]:CNPJRE) .And. ! SA2->(DbSeek(xFilial("SA2")+Padr(U_CARGA:ITENS[_nI]:CNPJRE,_nTamCGC," ")))
				_cMsg += " Transportador de redespacho não cadastrado no Protheus. Item: " +If(!Empty(U_CARGA:ITENS[_nI]:ITEM),Str(U_CARGA:ITENS[_nI]:ITEM,5),"")+" "
			EndIf

		Next

		//==================================================================================
		// Verifica pedido bonificação bloqueado e PV vinculados
		//==================================================================================
		aP1Vinculados:={}
		aP2Vinculados:={}

		SC5->(Dbsetorder(1))
		For _nI := 1 To Len(U_CARGA:ITENS)

			If SC5->(DbSeek(_cFilial+PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," ")))

				If SC5->C5_I_OPER = '10' .AND. (SC5->C5_I_BLOQ == "B" .OR. SC5->C5_I_BLOQ == "R")

					_cMsg += "Pedido de bonificação sem liberação - " + SC5->C5_NUM + " "
				Endif

				AADD(aP1Vinculados,SC5->C5_NUM)
				IF !EMPTY(SC5->C5_I_PEVIN)
					AADD(aP2Vinculados,{SC5->C5_NUM,SC5->C5_I_PEVIN})
				ENDIF

			EndIf

		Next

		cFaltaPVinculado:=""
		FOR P := 1 TO LEN(aP2Vinculados)
			IF ASCAN(aP1Vinculados, aP2Vinculados[P,2]) = 0
				cFaltaPVinculado+=" PV "+aP2Vinculados[P,1]+" na carga sem o PV Vinculado "+aP2Vinculados[P,2]+", "
			ENDIF
		NEXT

		IF !EMPTY(cFaltaPVinculado)
			cFaltaPVinculado:=LEFT(cFaltaPVinculado,LEN(cFaltaPVinculado)-2)
			_cMsg += cFaltaPVinculado
		ENDIF

		If ! Empty(_cMsg)
			::U_STATUS := _cMsg
			disarmtransaction()
			Break
		EndIf

		//===================================================================================
		// Realiza a liberação dos pedidos de vendas se passar no teste de crédito e estoque
		//===================================================================================
		If ! _lAteracao
			_cChavePesq := ""
			_aJaProces  := {}
			_cPedidos := ""

			//========================================================================================
			// Este trecho valida apenas o crédito dos pedidos de vendas através da função AOMS074S()
			//========================================================================================
			_cTextoCred := ""
			SC5->(Dbsetorder(1))
			For _nI := 1 To Len(U_CARGA:ITENS)
				If SC5->(DbSeek(_cFilial+PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," "))) .and. SC6->(DbSeek(_cFilial+PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," ")))
					_aAprovacao := AOMS074S()     // Verifica as aprovações de credito.
					_lAprov     := _aAprovacao[1] // True = Credito aprovado / False = Credito reejeitadao
					_cTextoRet  := _aAprovacao[2] // Mensagem de retorno.
					If ! _lAprov
						_cTextoCred += _cTextoRet + " ### " // " Erro na liberação de crédito do Pedido de Vendas: "+AllTrim(SC5->C5_NUM)

						SC5->(RecLock("SC5",.F.))
						SC5->C5_I_BLCRE	:= "B"
						SC5->C5_I_DTAVA := DATE()
						SC5->C5_I_HRAVA := TIME()
						SC5->C5_I_USRAV := cusername
						SC5->C5_I_MOTBL := _cTextoRet
						SC5->(MsUnLock())
					EndIf
				EndIf
			Next

			Begin Transaction

				SC6->(Dbsetorder(1))
				SC5->(Dbsetorder(1))
				SC9->(Dbsetorder(1))
				SA1->(Dbsetorder(1))
				SC5->(Dbsetorder(1))
				SB2->(Dbsetorder(1))
				For _nI := 1 To Len(U_CARGA:ITENS)
					// Monta valor total do pedido
					ntotped := 0

					SC6->(Dbsetorder(1))
					If SC6->(DbSeek(_cFilial+PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," ")))
						Do while SC6->C6_FILIAL + SC6->C6_NUM == cFilial+PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," ")
							ntotped += SC6->C6_VALOR
							SC6->( Dbskip())
						Enddo
					EndIf

					SC5->(Dbsetorder(1))
					If SC5->(DbSeek(_cFilial+PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," "))) .and. SC6->(DbSeek(_cFilial+PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," ")))
						_aAprovacao := AOMS074S()     // Verifica as aprovações de credito.
						_lAprov     := _aAprovacao[1] // True = Credito aprovado / False = Credito reejeitadao
						_cTextoRet  := _aAprovacao[2] // Mensagem de retorno.
						_cChavePesq := ""
						_aJaProces  := {}

						//========================================================================================
						// Se a função AOMS074S() retornar verdadeiro, este trecho realiza várias validação.
						// valida crédito, estoque, etc. Utilizando outros métodos.
						//========================================================================================
						If Reclock("SC5",.F.) .and. _lAprov // AOMS074S()
							SC6->(Dbsetorder(1))
							SC6->(DbSeek(_cFilial+PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," ")))
							Do While !(SC6->(Eof())) .And. SC6->(C6_FILIAL+C6_NUM) == _cFilial+PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," ")
								_cChavePesq := SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM  // Para evitar que o mesmo item de pedido seja processado mais de uma vez
								If Ascan(_aJaProces,_cChavePesq) == 0
									Aadd(_aJaProces,_cChavePesq)
								Else
									SC6->(DbSkip())
									Loop
								EndIf

								SC9->(Dbsetorder(1))
								If !(SC9->(DbSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))) .OR. !EMPTY(SC9->C9_BLEST)  // verifica estoque se não tem liberação válida ainda
									//Verifica se pode gravar registros do C6, A1 e B2
									_lflock := .F.

									if !SC6->(MsRLock(SC6->(RECNO())))
										_cmsg += "No momento este Pedido de Vendas está sendo utilizado por outro usuário e não pode ser manipulado. Tente integrar novamente mais tarde: " + SC6->C6_NUM + "/" + SC6->C6_ITEM
										_lflock := .T.
									Endif

									SA1->(Dbsetorder(1))
									SA1->(Dbseek(xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))

									SB2->(Dbsetorder(1))
									SB2->(Dbseek(SC6->C6_FILIAL+SC6->C6_PRODUTO+SC6->C6_LOCAL))

									if ! _lflock .and. !SB2->(MsRLock(SB2->(RECNO())))
										_cmsg += "No momento este estoque está sendo utilizado por outro usuário e não pode ser manipulado. Tente integrar novamente mais tarde: " + SB2->B2_COD + "/" + SB2->B2_LOCAL
										_lflock := .T.
									Endif

									If _lflock .and. !Empty(_cMsg)  //Break exclusivo para falha de lock dos itens
										disarmtransaction()
										::U_STATUS := "<SUCESSO>FALSE</SUCESSO>" + _cMsg
										Break
									EndIf

									SC9->(Dbsetorder(1))
									If (SC9->(DbSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))) .AND. !EMPTY(SC9->C9_BLEST)
										SC9->(A460Estorna()) //Se já tem sc9 com bloqueio de estoque estorna a liberação
									Endif

									_nQtdLib := MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN)//LIBERA PEDIDO

									//Analise da liberação de estoque
									_lestoque := .F.

									SC9->(Dbsetorder(1))
									If SC9->(DbSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))
										If SC9->C9_QTDLIB <> SC6->C6_QTDVEN
											_cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". A quantidade liberada diverge da quantidade do item: " + SC6->C6_ITEM + " - Produto: " +;
												SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
										ElseIf !Empty(SC9->C9_BLEST)
											_nQtdEst := 0
											If SB2->(DbSeek(SC6->C6_FILIAL+SC6->C6_PRODUTO+SC6->C6_LOCAL))
												_nQtdEst := (SB2->B2_QATU - SB2->B2_QEMP - SB2->B2_QEMPN - SB2->B2_RESERVA - SB2->B2_QACLASS)
											EndIf

											_lBloqEst   := .T.
											_cTextoMsg := " Erro na liberação do Estoque do PV: "+AllTrim(SC6->C6_NUM)+". Item: " + SC6->C6_ITEM + " - " +;
												AllTrim(SC6->C6_PRODUTO) + ". Qtd PV: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+" "+SC6->C6_UM+". Armazém: " + SC6->C6_LOCAL +;
												". Qtd Estoque: " + AllTrim(Str(_nQtdEst,18,5)) + " " + SC6->C6_UM

											If !(_cTextoMsg $ _cMsg)
												_cMsg += _cTextoMsg
											EndIf
										ElseIf !Empty(SC9->C9_BLCRED)
											_cPedidos += " Nr.Pedido V.: " + AllTrim(SC6->C6_NUM) + " - Item: " + SC6->C6_ITEM + " - Produto: "+AllTrim(SC6->C6_PRODUTO) + " - Qtd: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+". ### "
										ElseIf !Empty(SC9->C9_CARGA)
											_cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". Bloqueio de carga para o item: " + SC6->C6_ITEM + " - Produto: " +;
												SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
										ElseIf !Empty(SC9->C9_NFISCAL)
											_cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". Bloqueio de nota fiscal para o item: " + SC6->C6_ITEM + " - Produto: " +;
												SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
										Else
											_lestoque := .T.
										Endif
									Else
										_cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". Não foi gerado registro de liberação " + SC6->C6_ITEM + " - Produto: " +;
											SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
									Endif

									If _lestoque
										aadd(_apedidos,SC6->C6_NUM)
										MsUnLockAll()
										Reclock("SC5",.F.)
										SC5->C5_LIBEROK := "S"
										MsUnLockAll()
									EndIf

								ElseIf SC9->(DbSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))

									If SC9->C9_QTDLIB <> SC6->C6_QTDVEN
										_cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". A quantidade liberada diverge da quantidade do item: " + SC6->C6_ITEM + " - Produto: " +;
											SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
									ElseIf !Empty(SC9->C9_BLEST)

										_cTextoMsg := " Erro na liberação do Estoque do PV: "+AllTrim(SC6->C6_NUM)+". Item: " + SC6->C6_ITEM + " - " +;
											AllTrim(SC6->C6_PRODUTO) + ". Qtd PV: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+" "+SC6->C6_UM+". Armazém: " + SC6->C6_LOCAL +;
											". Qtd Estoque: " + AllTrim(Str(_nQtdEst,18,5)) + " " + SC6->C6_UM
										_lBloqEst   := .T.
										If !(_cTextoMsg $ _cMsg)
											_cMsg += _cTextoMsg
										EndIf

									ElseIf !Empty(SC9->C9_BLCRED)
										_cPedidos += " Nr.Pedido V.: " + AllTrim(SC6->C6_NUM) + " - Item: " + SC6->C6_ITEM + " - Produto: "+AllTrim(SC6->C6_PRODUTO) + " - Qtd: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+". ### "
									ElseIf !Empty(SC9->C9_CARGA)
										_cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". Bloqueio de carga para o item: " + SC6->C6_ITEM + " - Produto: " +;
											SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
									ElseIf !Empty(SC9->C9_NFISCAL)
										_cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". Bloqueio de nota fiscal para o item: " + SC6->C6_ITEM + " - Produto: " +;
											SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
									Else
										aadd(_apedidos,SC6->C6_NUM)
										MsUnLockAll()
										Reclock("SC5",.F.)
										SC5->C5_LIBEROK := "S"
										MsUnLockAll()
									EndIf
								Else
									_cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". Não foi gerado registro de liberação " + SC6->C6_ITEM + " - Produto: " +;
									SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
								EndIf

								SC6->(DbSkip())
							EndDo

							If ! Empty(_cPedidos) .And. ! _cPedidos $ _cMsg
								_cMsg += " Erro na liberação do Pedido de Vendas. Bloqueio por Crédito: " + _cPedidos
							EndIf

							If !Empty(_cMsg)
								Disarmtransaction()
								MsUnLockAll()
								Exit
							EndIf
						Else
							//========================================================================================
							// Se a função AOMS074S() retornar falso na validação do crédito, volta toda a transação
							// das tabelas e retorna a(s) mensagem(ns) de rejeição.
							//========================================================================================

							_cMsg += _cTextoCred

							MsUnLockAll()
							Disarmtransaction()

							Exit

						EndIf

						If ! Empty(_cMsg)
							MsUnLockAll()
							DisarmTransaction()
							Exit
						EndIf
					Else
						_cMsg += " Erro em localizar o Pedido de Vendas: "+AllTrim(SC5->C5_NUM)
						Exit
					EndIf

					MsUnLockAll()
				Next
			End Transaction
		EndIf

		SC5->(Dbsetorder(1))
		For _nI := 1 To Len(U_CARGA:ITENS)
			If SC5->(DbSeek(_cFilial+PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," "))) .and. SC6->(DbSeek(_cFilial+PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," ")))
				U_ENVSITPV()
			EndIf
		Next

		If ! Empty(_cMsg)
			::U_STATUS := "<SUCESSO>FALSE</SUCESSO>" + _cMsg
			disarmtransaction()
			Break
		EndIf

		DA4->(DbSetOrder(3)) // DA4_FILIAL+DA4_CGC  // CPF MOTORISTA
		SA2->(DbSetOrder(3)) // A2_FILIAL+A2_CGC
		DAK->(DbOrderNickName("CODCAR_RDC"))

		//===================================================================================
		// Apos todas as validações estarem corretas, realiza a criação das cargas.
		// Gravação da Capa da Carga.
		//===================================================================================

		//Inicia Watchdog da inclusão de carga e inclusão/liberação do pedido de pallet
		PutGlbValue("INCLUIC"+AllTrim(U_CARGA:CODIGO)+ALLTRIM(STR(ThreadID())),"Alterando")
		lret := startjob("U_AOMS074W",getenvserver(),.F.,U_ITGETMV( 'IT_WEBTO' , 50 ),ThreadID(),"INCLUIC"+AllTrim(U_CARGA:CODIGO)+ALLTRIM(STR(ThreadID())),_cfilial + "/" + AllTrim(U_CARGA:CODIGO))

		//===================================================================================
		// Cria as cargas e grava os dados das tabelas DAK e DAI normalmente.
		//===================================================================================
		Begin Transaction
			If !_lAteracao
				_cCodigo := U_AOMS089(.F.,"DAK","DAK_COD",.F.)
				DAK->(Reclock("DAK",.T.))
				DAK->DAK_FILIAL := _cFilial // Filial do Embarcador
				DAK->DAK_COD    := _cCodigo // GetSx8Num("DAK","DAK_COD")
				DAK->DAK_SEQCAR := "01"     // sempre 01
				DAK->DAK_ROTEIR := ""       // sempre vazio
				DAK->DAK_FEZNF  := "2"              // sempre 2
				DAK->DAK_DATA   := Date()           // Date()
				DAK->DAK_HORA   := Time()           // Time()
				DAK->DAK_JUNTOU := "MANUAL"         // sempre MANUAL
				DAK->DAK_ACECAR := "2"              // sempre 2
				DAK->DAK_ACEVAS := "2"              // sempre 2
				DAK->DAK_ACEFIN := "2"              // sempre 2
				DAK->DAK_AJUDA1 := ""               // sempre vazio
				DAK->DAK_AJUDA2 := ""               // sempre vazio
				DAK->DAK_AJUDA3 := ""               // sempre vazio
				DAK->DAK_DTACCA := CTOD("  /  /  ") // sempre vazio
				DAK->DAK_OK     := ""               // sempre vazio
				DAK->DAK_FLGUNI := "2"              // sempre 2
				DAK->DAK_DATENT := CTOD("  /  /  ") // sempre vazio
				DAK->DAK_BLWMS  := ""               // sempre vazio
				DAK->DAK_BLQCAR := ""               // sempre vazio
				DAK->DAK_HRSTAR := "08:00"          // sempre 08:00
				DAK->DAK_I_FRET := 0                // sempre 0
				DAK->DAK_ROTEIR := '999999'
				DAK->DAK_I_REDP := ""               // sempre vazio
				DAK->DAK_I_RELO := ""               // sempre vazio
				DAK->DAK_I_OPER := ""               // sempre vazio
				DAK->DAK_I_OPLO := ""               // sempre vazio
				DAK->DAK_I_OBS  := "Importado via RDC. Numero Carga RDC: " + U_CARGA:CODIGO // "Importado via RDC " + número da carga do RDC
				DAK->DAK_I_VRPE := 0                // Sempre 0
				DAK->DAK_I_CARG := U_CARGA:CODIGO   // Número da carga do RDC
				DAK->DAK_I_FRDC := U_CARGA:CODFIL   // Codigo de filial do RDC.
			Else
				DAK->(Reclock("DAK",.F.))
				_cCodigo := DAK->DAK_COD
			EndIf

			If AllTrim(U_CARGA:PRECARGA) == "N" // Não é uma précarga.
				DAK->DAK_I_PREC := "1" // Para que seja possível efetivar a carga sem précarga, é necessário iniciar a carga como précarga e depois de rodar a rotina de efetivação da carga, definimos DAK->DAK_I_PREC := "2" para dizer que é uma Carga.
			Else
				DAK->DAK_I_PREC := "1"
			EndIf

			If _lAchouMotorista //! Empty(U_CARGA:PLACA1)

				DAK->DAK_CAMINH := _cCodVeiculo // DA3->DA3_COD // DA3_COD para  DA3_PLACA igual placa do xml
				DAK->DAK_MOTORI := _cCodMotorista // DA4->DA4_COD // DA4_COD para DA4_CGC igual ao cpf do motorista do xml

			EndIf
            
			//DAK->DAK_PESO   := If(_lMV_PESOCAR,U_CARGA:PESOL,U_CARGA:PESOB)   //Foi para depois da gravação do DAI
			DAK->DAK_VALOR  := U_CARGA:VALOR    // VALOR // soma de c6_valor
			DAK->DAK_I_FRET := U_CARGA:FRETE    // VALOR DO FRETE.
			DAK->DAK_I_TPFR := If(Len(AllTrim(U_CARGA:CNPJTRA))< 14,"1","2")  // 1="Autonomo";2="PJ-Transportadora" (escolhe se cpf no transportador é 1, se é cgc no transportador é 2)
			DAK->DAK_IDENT  := ""               // sempre vazio
			DAK->DAK_TRANSP := _cCodTransp // SA2->A2_COD      // SA2->A2_COD que tenha a2_cgc  igual a cnpj de transportadora do xml
			DAK->DAK_I_VRPE := U_CARGA:PEDAGIO

			_cMailUsrCarga := Posicione("ZZL",5,xfilial("ZZL")+AllTrim(Str(U_CARGA:USUCAD,_nTamCodUser)),"ZZL_EMAIL") // E-mail do usuário que criou a carga utilizado na rotina de envio de e-mail da carga.
			If Empty(_cMailUsrCarga)
				_cMailUsrCarga := ""
			EndIf

			DAK->DAK_I_RECR := AllTrim(Str(U_CARGA:RECNUM,10)) // Grava o Recno RDC na Tabela DAK

			DAK->DAK_USERGA := U_RetLgiLga(_cCodUsuario) // _cid - id de usuário do Protheus
			DAK->DAK_USERGI := U_RetLgiLga(_cCodUsuario) // _cid - id de usuário do Protheus
			DAK->DAK_I_OBS  := U_CARGA:OBSERV2  // U_CARGA:OBSERV1  // Solicitação do Vanderlei. O RDC está invertendo a ordem de envio das observações. Observação 1 na Observação 2 e vice-versa.
			DAK->DAK_I_OBS2 := U_CARGA:OBSERV1  // U_CARGA:OBSERV2  // Solicitação do Vanderlei. O RDC está invertendo a ordem de envio das observações. Observação 1 na Observação 2 e vice-versa.

			//===================================================================================
			// Gravação dos Itens da Carga.
			//===================================================================================
			_nTotPeso     := 0
			_nCapacVolum  := 0
			_aQtdClientes := {}
			_lTemPallet   := .F.

			DAI->(DbSetOrder(4)) // DAI_FILIAL+DAI_PEDIDO+DAI_COD+DAI_SEQCAR
			SC5->(Dbsetorder(1))

			For _nI := 1 To Len(U_CARGA:ITENS)

				_cPedido := PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," ")

				If !(SC5->(DbSeek(_cFilial + _cPedido))) // Posiciona no numero de pedido da SC5

					_cMsg := "Falha ao gravar itens da carga " + _cFilial + _cPedido
					MsUnLockAll()
					DisarmTransaction()
					Break

				Endif

				If !_lAteracao
					DAI->(RecLock("DAI",.T.))
					DAI->DAI_FILIAL := _cFilial             // Filial do Embarcador
					DAI->DAI_COD    := _cCodigo             // DAK->DAK_COD
					DAI->DAI_SEQCAR := "01"                 // sempre 01
					DAI->DAI_PEDIDO := _cPedido             // U_CARGA:ITENS[_nI]:PEDIDO // pedido indicado no xml
					DAI->DAI_CLIENT := SC5->C5_CLIENTE      // c5_cliente
					DAI->DAI_LOJA   := SC5->C5_LOJACLI      // c5_loja
					DAI->DAI_VENDED := ""                   // sempre vazio
					DAI->DAI_CAPVOL := 0          // sempre 0
					DAI->DAI_PERCUR := "999999"   // sempre 999999
					DAI->DAI_ROTA   := "999999"   // sempre 999999
					DAI->DAI_ROTEIR := "999999"   // sempre 999999
					DAI->DAI_SEQROT := ""         // sempre vazio
					DAI->DAI_NFISCA := ""         // sempre vazio
					DAI->DAI_SERIE  := ""         // sempre vazio
					DAI->DAI_DATA   := Date()     // date()
					DAI->DAI_HORA   := Time()     // Time()
					DAI->DAI_CARORI := "CARGA"    // sempre CARGA
					DAI->DAI_REMITO := ""         // sempre vazio
					DAI->DAI_SERREM := ""         // sempre vazio
					DAI->DAI_DTCHEG := Date()     // date()
					DAI->DAI_CHEGAD := "08:00"    // sempre 08:00
					DAI->DAI_TMSERV := "0000:00"  // sempre 0000:00
					DAI->DAI_DTSAID := Date()     // date()
					DAI->DAI_I_FRET := 0          // sempre 0
					DAI->DAI_VALFRE := 0          // sempre 0
					DAI->DAI_FREAUT := 0          // sempre 0
					DAI->DAI_I_REDP := "2"     // A2_COD cujo a2_cgc igual a campo de redespacho
					DAI->DAI_I_TRED := ""
					DAI->DAI_I_LTRE := ""
					DAI->DAI_I_OPER := "2"     // A2_COD cujo a2_cgc igual a campo deoperador logistico
					DAI->DAI_I_OPLO := ""
					DAI->DAI_I_LOPL := ""
				Else
					DAI->(DbSeek(_cFilial+PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," ")))
					DAI->(RecLock("DAI",.F.))
				EndIf

                _nPesoBrut:=0// #DAI_PESO
                SC6->( DbSeek( DAI->DAI_FILIAL + DAI->DAI_PEDIDO ) )
                DO While SC6->( !EOF() ) .AND. SC6->C6_FILIAL+SC6->C6_NUM == DAI->DAI_FILIAL+DAI->DAI_PEDIDO
          
                   //==================================================================================
                   // SEMPRE ACERTA O PESO BRUTO DE ACORDO COM O DO CADASTRO DO SB1 PQ ENTRE O PEDIDO E A CARGA PODE TER HAVIDO ALTERACAO
                   //==================================================================================
                   IF POSICIONE( "SB1" , 1 , xFilial("SB1") + SC6->C6_PRODUTO , "B1_I_PCCX" )  > 0  .AND.  SC6->C6_I_PTBRU > 0 //EXCETO SE FOR PESO VARIADO
                      _nPesoItem := SC6->C6_I_PTBRU
                   Else
                      _nPesoItem := SB1->B1_PESBRU * SC6->C6_QTDVEN //Peso do Item
                      SC6->(RecLock("SC6",.F.))
                      SC6->C6_I_PTBRU:=_nPesoItem 
                      SC6->(MsUnlock())
                   EndIf
                   _nPesoBrut += _nPesoItem
                   SC6->( DBSkip() )
                ENDDO
          
                SC5->(RecLock("SC5",.F.))
                SC5->C5_I_PESBR:= _nPesoBrut
                SC5->C5_PBRUTO := _nPesoBrut
                SC5->(MsUnlock())

				DAI->DAI_PESO   :=  SC5->C5_I_PESBR // c5_pesol ou c5_pesob de acordo com parâmetro DAK_PESO
                _nTotPeso+=DAI->DAI_PESO // #DAI_PESO

				//==========================================================================================
				// Grava dados do transportador de redespacho
				// Embutido workaround para quando vier igual o cnpj de op logistico e redespacho considerar
				// como operador logistico
				//==========================================================================================
				If !(Empty(U_CARGA:ITENS[_nI]:CNPJRE)) // .and. (U_CARGA:ITENS[_nI]:CNPJRE != U_CARGA:ITENS[_nI]:CNPJOP)

					SA2->(Dbsetorder(3))
					SA2->(DbSeek(xFilial("SA2")+Padr(U_CARGA:ITENS[_nI]:CNPJRE,_nTamCGC," ")))
					DAI->DAI_I_REDP := "1"     // A2_COD cujo a2_cgc igual a campo de redespacho
					DAI->DAI_I_TRED := SA2->A2_COD
					DAI->DAI_I_LTRE := SA2->A2_LOJA


					DAK->DAK_I_REDP := SA2->A2_COD // Grava na capa os dados do redespacho
					DAK->DAK_I_RELO := SA2->A2_LOJA

				Else

					DAI->DAI_I_REDP := "2"
					DAI->DAI_I_TRED := ""
					DAI->DAI_I_LTRE := ""

				Endif

				//==========================================================================================
				// Grava dados do operador logistico.
				//==========================================================================================
				If ! Empty(U_CARGA:ITENS[_nI]:CNPJOP)
					SA2->(Dbsetorder(3)) // A2_FILIAL+A2_CGC
					SA2->(DbSeek(xFilial("SA2")+Padr(U_CARGA:ITENS[_nI]:CNPJOP,_nTamCGC," ")))

					//===========================================================================
					// O código do operador logístico deve seguir a classificação descrita no
					// SA2. Primeiro o tipo T, Segundo o Tipo A, Terceiro o Tipo C.
					// Caso nenhum dos tipos sejam localizados, obter o primeiro código e loja.
					//===========================================================================
					_cCodOperL  := SA2->A2_COD
					_cLojaOperL := SA2->A2_LOJA

					_cCodOpT  := ""
					_cLojaOpT := ""
					_cCodOpA  := ""
					_cLojaOpA := ""
					_cCodOpF  := ""
					_cLojaOpF := ""

					Do While ! SA2->(Eof()) .And. SA2->(A2_FILIAL+A2_CGC) == xFilial("SA2")+Padr(U_CARGA:ITENS[_nI]:CNPJOP,_nTamCGC," ")
						If SA2->A2_I_CLASS == "T" .And. Empty(_cCodOpT)
							_cCodOpT  := SA2->A2_COD
							_cLojaOpT := SA2->A2_LOJA
						EndIf

						If SA2->A2_I_CLASS == "A" .And. Empty(_cCodOpA)
							_cCodOpA  := SA2->A2_COD
							_cLojaOpA := SA2->A2_LOJA
						EndIf

						If SA2->A2_I_CLASS == "F" .And. Empty(_cCodOpF)
							_cCodOpF  := SA2->A2_COD
							_cLojaOpF := SA2->A2_LOJA
						EndIf

						SA2->(DbSkip())
					EndDo

					If ! Empty(_cCodOpT)
						_cCodOperL  := _cCodOpT
						_cLojaOperL := _cLojaOpT
					ElseIf ! Empty(_cCodOpA)
						_cCodOperL  := _cCodOpA
						_cLojaOperL := _cLojaOpA
					ElseIf ! Empty(_cCodOpF)
						_cCodOperL  := _cCodOpF
						_cLojaOperL := _cLojaOpF
					EndIf

					DAI->DAI_I_OPER := "1"     // A2_COD cujo a2_cgc igual a campo deoperador logistico
					DAI->DAI_I_OPLO := _cCodOperL  // SA2->A2_COD
					DAI->DAI_I_LOPL := _cLojaOperL // SA2->A2_LOJA

					DAK->DAK_I_OPER := _cCodOperL  // SA2->A2_COD // Grava na capa os dados do operador logistico.
					DAK->DAK_I_OPLO := _cLojaOperL // SA2->A2_LOJA

				EndIf


				DAI->DAI_I_TIPC := AllTrim(U_CARGA:ITENS[_nI]:TPCARG) // 1 = "Paletizada" / 2 = "Batida"
				DAI->DAI_I_QTPA := U_CARGA:ITENS[_nI]:QTDPALLET// quantidade de pallets indicada no xml
				IF DAI->DAI_I_TIPC  $ TP_GERA_PALET .AND. DAI->DAI_I_QTPA # 0
					_lTemPallet:=.T.
				ENDIF
				_nCapacVolum    += DAI->DAI_CAPVOL // Somatória da capacidade volumétrica do item.

				_cChave  := DAI->( DAI_CLIENT + DAI_LOJA )
				IF DAI->DAI_I_OPER="1" .AND. !EMPTY(DAI->DAI_I_OPLO)
					_cChave  := DAI->DAI_I_OPLO+DAI->DAI_I_LOPL
				EndIF
				IF DAI->DAI_I_REDP="1" .AND. !EMPTY(DAI->DAI_I_TRED)
					_cChave  := DAI->DAI_I_TRED+DAI->DAI_I_LTRE
				EndIF
				IF !EMPTY(_cChave) .AND. AsCan(_aQtdClientes,_cChave) = 0
					Aadd(_aQtdClientes,_cChave)// Contagem de clientes diferentes nos itens da carga.
				ENDIF

				DAI->DAI_SEQUEN := StrZero(U_CARGA:ITENS[_nI]:SEQUENCIA,6)

				DAI->(MsUnLock())

				SC9->(Dbsetorder(1))
				If SC9->(Dbseek(DAI->DAI_FILIAL+DAI->DAI_PEDIDO))


					Do while DAI->DAI_FILIAL == SC9->C9_FILIAL .AND. DAI->DAI_PEDIDO == SC9->C9_PEDIDO

						If Reclock("SC9",.F.)

							SC9->C9_CARGA := DAK->DAK_COD
							SC9->C9_SEQCAR := '01'
							SC9->C9_SEQENT := DAI->DAI_SEQUEN

						Else

							_cMsg := "Falha ao reservar pedido " + DAI->DAI_PEDIDO
							MsUnLockAll()
							DisarmTransaction()
							Break

						EndIf

						SC9->(Dbskip())

					Enddo

				Else

					_cMsg := "Falha ao reservar pedido " + DAI->DAI_PEDIDO
					MsUnLockAll()
					DisarmTransaction()
					Break

				EndIf

			Next

			//===================================================================================
			// Continuação capa Gravação dos Capa da Carga.
			//===================================================================================
            DAK->DAK_PESO   := _nTotPeso//Somatoria do #DAI_PESO
			DAK->DAK_CAPVOL := _nCapacVolum       // soma de dai_capvol
			DAK->DAK_PTOENT := Len(_aQtdClientes) // contagem de clientes diferentes, dai_client+cai_loja
            DAK->DAK_I_TMS  := "R" // Indica que a carga foi criada pelo sistema RDC 
            DAK->DAK_I_LEMB := SC5->C5_I_LOCEM // Local de Embarque

			DAK->(MsUnLock())

			_nRegAtu := DAK->(Recno())

			//===================================================================================
			// Realiza a efetivação da carga no Protheus.
			//===================================================================================
			_cMsgEfetiva := ""
			_lEnviaEmail := .F.
			If AllTrim(U_CARGA:PRECARGA) == "N" // Não é uma précarga.  // If _lAteracao

				IF _lTemPallet .OR. DAK->DAK_I_TPFR == "1"//Se tem pallet ou se é autonomo

					If LEN(_aItensPallet) > 0 .AND.  !(AOMS74Travou( {} , _aItensPallet , @_cMsgEfetiva ))

						 
						_cMsg := _cMsgEfetiva
						MsUnLockAll()
						DisarmTransaction()
						Break

					ENDIF

					_ccoddak := DAK->DAK_COD

					U_OM20MNUP(,,,.T.)//Refaz todos os rateios e somatorias

					//Reposiciona DAK para ver se geração de pallet não causou problemas na leitura
					//Acontece quando não tem saldo de pallets e dá problema na liberação do pedido gerado
					DAK->(DbGoto(_nRegAtu))

					If !(DAK->DAK_COD == _ccoddak)

						_cMsg := "Falha na geração de pallets, verifique o saldo de pallets"
						MsUnLockAll()
						DisarmTransaction()
						Break

					Endif

				ELSE
				    DAK->(DbGoto(_nRegAtu))    
					U_CargaRatVlrs(DAK->DAK_COD)//FUNÇÃO DO OM200FIM.PRW para refazer o Reteio do FRETE 1o PERCURSO e PEDAGIO no DAI / FRETE 2o PERCURSO NÃO é RATEIO É SOMATORIA DOS ITENS DA CARGA (PEDIDOS)
					
					_lEnviaEmail := .T.
					IF ZFU->(FIELDPOS("ZFU_ENMAIL")) = 0
						U_OM200Email(.F.,Nil,.T.,.T.,.T.)//_lEstorno,_aCargas,_lEnviaDireto,_lScheduller,_lMarcaEnvio
					ENDIF
				ENDIF

				If !Empty(_cMsgEfetiva)
					_lEnviaEmail := .F.
					_cMsg := _cMsgEfetiva
					MsUnLockAll()
					DisarmTransaction()
					Break
				ELSE
					_lEnviaEmail := .T.
				EndIf

			Else

			    DAK->(DbGoto(_nRegAtu))
			    U_CargaRatVlrs(DAK->DAK_COD)//FUNÇÃO DO OM200FIM.PRW para refazer o Reteio do FRETE 1o PERCURSO e PEDAGIO no DAI / FRETE 2o PERCURSO NÃO é RATEIO É SOMATORIA DOS ITENS DA CARGA (PEDIDOS)

				//Envia ordem de carga da pré carga
				_lEnviaEmail := .T.
				IF ZFU->(FIELDPOS("ZFU_ENMAIL")) = 0
					U_OM200Email(.F.,Nil,.T.,.T.,.T.)//_lEstorno,_aCargas,_lEnviaDireto,_lScheduller,_lMarcaEnvio
				ENDIF
			EndIf

			DAK->(DbGoto(_nRegAtu))
			If AllTrim(U_CARGA:PRECARGA) == "N" // Não é uma précarga.
				DAK->(RecLock("DAK",.F.))
				DAK->DAK_I_PREC := "2"
				DAK->DAK_USERGA := U_RetLgiLga(_cCodUsuario) // _cid - id de usuário do Protheus
				DAK->DAK_USERGI := U_RetLgiLga(_cCodUsuario) // _cid - id de usuário do Protheus
				DAK->(MsUnLock())
			EndIf

			If AllTrim(U_CARGA:PRECARGA) == "N" // Não é uma précarga.

				_cMsgOk := " Carga RDC: "+AllTrim(U_CARGA:CODIGO)+", integrada com sucesso! "
				_cMsgRDC := " Numero de Carga Protheus: NRSOLI=" + _cCodigo

				ConfirmSX8()

				DAK->(RecLock("DAK",.F.))
				DAK->DAK_USERGA := U_RetLgiLga(_cCodUsuario) // _cid - id de usuário do Protheus
				DAK->DAK_USERGI := U_RetLgiLga(_cCodUsuario) // _cid - id de usuário do Protheus
				DAK->(MsUnLock())

			Else

				_cMsgOk := " Efetivação de carga RDC: "+AllTrim(U_CARGA:CODIGO)+", integrada com sucesso! "
				_cMsgRDC := " Numero de Carga Protheus: NRSOLI=" + _cCodigo

				DAK->(RecLock("DAK",.F.))
				DAK->DAK_USERGA := U_RetLgiLga(_cCodUsuario) // _cid - id de usuário do Protheus
				DAK->DAK_USERGI := U_RetLgiLga(_cCodUsuario) // _cid - id de usuário do Protheus
				DAK->(MsUnLock())

			EndIf

			//===========================================================================
			// Atualiza tabela SC5.
			//===========================================================================
			If Empty(_cMsg) // Integração com sucesso.

				_nTamPedido := TAMSX3("C5_NUM")[1]

				For _nI := 1 To Len(U_CARGA:ITENS)
					_cPedido := PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," ")
					SC5->(Dbsetorder(1))
					If (SC5->(DbSeek(_cFilial + _cPedido))) // Posiciona no numero de pedido da SC5
						_ddataant := SC5->C5_I_DTENT
						_aLogSC5 := U_ITIniLog( 'SC5')
						SC5->(RecLock("SC5",.F.))
						SC5->C5_I_OBCOP := U_CARGA:ITENS[_nI]:OBSCPA  // Observação da condição de pagamento
						SC5->C5_I_OBPED := U_CARGA:ITENS[_nI]:OBSPVE  // Observação do Pedido de Vendas
						SC5->C5_MENNOTA := U_CARGA:ITENS[_nI]:OBSNFE  // Observação da Nota Fiscal
						SC5->C5_I_DTENT := CTOD(U_CARGA:ITENS[_nI]:DTPREV) // Data de Previsão de Entrega
						SC5->C5_FECENT  := CTOD(U_CARGA:ITENS[_nI]:DTPREV) // Data de Previsão de Entrega
						SC5->(MsUnlock())

						//Grava monitor de pedido de vendas
						If SC5->C5_I_DTENT != _ddataant
							_cJUSCOD := "007"//Alterado Data de Entrega
							_cCOMENT := "Data de entrega modificada de " + dtoc(_ddataant) + " para " + dtoc(SC5->C5_I_DTENT) + "  via inclusão de carga RDC."
							_cENCERR := ""
							__cUserID := _cCodUsuario
							U_GrvMonitor(,,_cJUSCOD,_cCOMENT,_cENCERR,_ddataant,SC5->C5_I_DTENT,_ddataant)

						Endif
                        
						//Grava log de alteração de tabela
						U_ITGrvLog( _aLogSC5 , "SC5" , 1 , SC5->( C5_FILIAL + C5_NUM ) ,"A" , _cCodUsuario , date() , time() )
						_cmotivs := "  " //Zera variável pública de motivo de corte para não repetir uso por engano

					EndIf
				Next
			EndIf

		End Transaction

	End Sequence

//==============================================================================================================================                 
// Se os registros das tabelas DAK e DAI já foram criados, mas ocorreu erro na 
// integração com o RDC e a integração foi reenviada.
// Atualiza os dados da tabela DAK e DAI com os novos RECNOS RDC e o novo numero de
// Viagem e finaliza a integração.
//                 //    Renco DAK       Recno DAI          DAK_I_RECR                        DAK_I_CARG
// Aadd(_aCargasAtu, {DAK->(Recno()), DAI->(Recno()), AllTrim(Str(U_CARGA:RECNUM,10)), Padr(U_CARGA:CODIGO,_nTamCod," ")})
//==============================================================================================================================                 
	If Len(_aCargasAtu) > 0  .And. _lPedOk .and. Empty(_cMsg)
		Begin Transaction
			DAK->(DbGoTo(_aCargasAtu[1,1]))
			DAK->(Reclock("DAK",.F.))
			DAK->DAK_I_RECR := AllTrim(Str(U_CARGA:RECNUM,10))
			DAK->DAK_I_CARG := U_CARGA:CODIGO
			DAK->(MsUnLock())
		End Transaction

		_cMsgOk := " Efetivação de carga RDC: "+AllTrim(U_CARGA:CODIGO)+", integrada com sucesso! "
		_cMsgRDC := " Numero de Carga Protheus: NRSOLI=" + DAK->DAK_COD

	EndIf

//Finaliza watchdog de inclusão de carga
	PutGlbValue("INCLUIC"+AllTrim(U_CARGA:CODIGO)+ALLTRIM(STR(ThreadID())),"Completado")

//===========================================================================
// Remove o semaforo da integração de cargas, que impede a integração em
// duplicidade de cargas.
//===========================================================================
	UnLockByName("U_INCLUIC"+AllTrim(U_CARGA:CODIGO),.F.,.F.,.T.)

//===========================================================================
// Retorna sucesso ou erro na integração.
//===========================================================================
	If Empty(_cMsg)
		//===============================================================
		// Calcula o tempo total gasto no processamento.
		//===============================================================
		_cTempoFin := Time()
		_nTempoTot := ELAPTIME( _cTempoIni, _cTempoFin )
		_cTextoTempo := " [Tempo de Processamento: "+AllTrim(_nTempoTot)+" Segundos] "

		//===============================================================
		// Retorna a mensagem de sucesso.
		//===============================================================
		::U_STATUS := "SUCESSO:TRUE; " + AllTrim(_cMsgOk) + _cTextoTempo +_cmsgRDC  // "Tudo OK na filial " + cfilant
		//u_itconout("[AOMS074] -" + _cMsgOk + _cTextoTempo  +_cmsgRDC  + " - " + DTOC(DATE()) + " - " + TIME())
	Else
		//u_itconout(" Erro: "+AllTrim(_cMsg)+" - "+DTOC(DATE())+" - "+TIME())
		//Se pedido não estava liberado antes desse processo estorna a liberação do mesmo
		_nI := 1

		//garante que desarmou a transação
		disarmtransaction()

		//===============================================================
		// Calcula o tempo total gasto no processamento.
		//===============================================================
		_cTempoFin := Time()
		_nTempoTot := ELAPTIME( _cTempoIni, _cTempoFin )
		_cTextoTempo := " [Tempo de Processamento: "+AllTrim(_nTempoTot)+" Segundos] "

		::U_STATUS := "SUCESSO:FALSE; " + AllTrim(_cMsg) + _cTextoTempo // _cMsg

	EndIf

// Grava log de comuinicação
	Begin Transaction
		ZFU->(RecLock("ZFU",.T.))
		ZFU->ZFU_FILIAL  := _cFilial                              // Filial do Sistema
		ZFU->ZFU_CODEMP  := _cCodEmpWS	                         // Codigo Empresa WebServer
		ZFU->ZFU_DATA	  := Date()                                // Data de Emissão
		ZFU->ZFU_HORA    := Time()                                // Hora de inclusão na tabela de muro
		ZFU->ZFU_USUARI  := __CUSERID                             // Codigo do Usuário
		ZFU->ZFU_DATAAL  := Date()                                // Data de Alteração
		ZFU->ZFU_SITUAC  := "P"                                   // Situação do Registro
		ZFU->ZFU_ENSTUS  := "S"                                   // Marcou para enviar Status
		ZFU->ZFU_CNPJEM  := U_CARGA:CNPJEM                        // CNPJ do Embarcador
		ZFU->ZFU_CODIGO  := U_CARGA:CODIGO                        // Codigo da Carga no RDC
		ZFU->ZFU_I_FRDC  := U_CARGA:CODFIL                        // Codigo da Filial RDC
		ZFU->ZFU_PLACAC  := U_CARGA:PLACA1                        // Placa do caminhão
		ZFU->ZFU_PLACA2  := U_CARGA:PLACA2                        // Placa do Veiculo 2
		ZFU->ZFU_PLACA3  := U_CARGA:PLACA3                        // Placa do Veiculo 3
		ZFU->ZFU_PLACA4  := U_CARGA:PLACA4                        // Placa do Veiculo 4
		ZFU->ZFU_CPFMOT  := U_CARGA:CPFM	                         // CPF do motorista
		ZFU->ZFU_PESOBR  := U_CARGA:PESOB                         // Peso bruto
		ZFU->ZFU_PESOLQ  := U_CARGA:PESOL                         // Peso liquido
		ZFU->ZFU_VALCAR  := U_CARGA:VALOR                         // Valor
		ZFU->ZFU_DTEMIS  := CTOD(U_CARGA:DATAE)                   // Data de emissão da Carga
		ZFU->ZFU_DTCARR  := CTOD(U_CARGA:DATAC)                   // Data de carregamento
		ZFU->ZFU_CNPJTR  := U_CARGA:CNPJTRA	                      // CNPJ da Transportadora
		ZFU->ZFU_TIPO    := U_CARGA:TIPO	                         // Tipo do veiculo
		ZFU->ZFU_FRETE   := U_CARGA:FRETE                         // Valor do Frete
		ZFU->ZFU_VLRPDG  := U_CARGA:PEDAGIO                       // Valor do Pedagio
		ZFU->ZFU_RDCUSR  := AllTrim(Str(U_CARGA:USUCAD,6))        // Codigo do Usuário da Alteração
		ZFU->ZFU_OBS1    := U_CARGA:OBSERV1                       // Observação 1
		ZFU->ZFU_OBS2    := U_CARGA:OBSERV2                       // Observação 2
		ZFU->ZFU_PRECAR  := U_CARGA:PRECARGA                      // Precarga? S/N
		ZFU->ZFU_REGCAP  := StrZero(ZFU->(Recno()),10)            // Numero Registro Tab.Capa
		ZFU->ZFU_CODIGO  := U_CARGA:CODIGO                        // Codigo da Carga no RDC
		ZFU->ZFU_RECRDC  := AllTrim(Str(U_CARGA:RECNUM,10))       // Grava o Recno RDC na Tabela de muro.
		ZFU->ZFU_RETORN  := AllTrim(Self:U_STATUS)+" [U_INCLUIC]"  // Retorno Integracao Italac-RDC

		If "SUCESSO:TRUE" $ Upper(AllTrim(Self:U_STATUS))
			If Empty(_cCodigo)
				_cCodigo := DAK->DAK_COD
			EndIf
			If AllTrim(U_CARGA:PRECARGA) == "N" .And. Empty(_cMsgEfetiva)
				ZFU->ZFU_ENMAIL := "S"      // Marcou para enviar E-MAIL
			EndIf
			ZFU->ZFU_NCARGA := _cCodigo // Numero da cara no Protheus
		Else
			ZFU->ZFU_NCARGA := " "
		EndIf

		IF _lEnviaEmail
			ZFU->ZFU_ENMAIL := "S" // Marcou para enviar E-MAIL
		ENDIF

		ZFU->(MsUnLock())

		For _nI := 1 To Len(U_CARGA:ITENS)
			ZFV->(RecLock("ZFV",.T.))
			ZFV->ZFV_FILIAL := _cFilial                     // Filial do Sistema
			ZFV->ZFV_DATA   := Date()                       // Data de Emissão
			ZFV->ZFV_HORA   := Time()                       // Hora de inclusão na tabela de muro
			ZFV->ZFV_CODIGO := U_CARGA:ITENS[_nI]:CODIGO    // Identificador da carga
			ZFV->ZFV_ITEM   := AllTrim(Str(U_CARGA:ITENS[_nI]:ITEM,5)) // Item da carga
			ZFV->ZFV_PEDIDO := U_CARGA:ITENS[_nI]:PEDIDO    // Pedido
			ZFV->ZFV_TPCARG := U_CARGA:ITENS[_nI]:TPCARG    // Tipo da carga
			ZFV->ZFV_CNPJOP := U_CARGA:ITENS[_nI]:CNPJOP    // CNPJ Operador logistico
			ZFV->ZFV_CNPJRE := U_CARGA:ITENS[_nI]:CNPJRE    // CNPJ Transportadora de redespacho
			ZFV->ZFV_QTDPLT := U_CARGA:ITENS[_nI]:QTDPALLET // Quantidade de Pallets
			ZFV->ZFV_USUARI := __CUSERID                    // Codigo do Usuário
			ZFV->ZFV_DATAAL := Date()	                   // Data de Alteração
			ZFV->ZFV_SITUAC := "P"                          // Situação do Registro
			ZFV->ZFV_CODEMP := _cCodEmpWS                   // Codigo Empresa WebServer
			ZFV->ZFV_RETORN := AllTrim(Self:U_STATUS)       // Retorno Integracao Italac-RDC
			ZFV->ZFV_REGCAP := StrZero(ZFU->(Recno()),10)   // Numero Registro Tab.Capa
			ZFV->(MsUnLock())
		Next

	End Transaction


//Garante que vai liberar lock de todos os cabeçalhos e todos os itens
	SC5->(Dbsetorder(1))
	For _nI := 1 to Len( U_CARGA:ITENS)

		If SC5->(DbSeek(_cFilial+U_CARGA:ITENS[_nI]:PEDIDO))

			SC5->(Msunlock())
			SC5->(Msunlockall())

			SA1->(Dbsetorder(1))
			If SA1->(Dbseek(xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))

				SA1->(Msunlock())
				SA1->(Msunlockall())

			Endif

			SC6->(Dbsetorder(1))
			If SC6->(Dbseek(_cFilial+U_CARGA:ITENS[_nI]:PEDIDO))

				Do while SC6->C6_FILIAL == SC5->C5_FILIAL .AND. SC6->C6_NUM == SC5->C5_NUM

					SC6->(Msunlock())
					SC6->(Msunlockall())

					SB2->(Dbsetorder(1))
					If SB2->(Dbseek(SC6->C6_FILIAL+SC6->C6_PRODUTO+SC6->C6_LOCAL))

						SB2->(Msunlock())
						SB2->(Msunlockall())

					Endif

					SC6->(Dbskip())

				Enddo

			Endif

		Endif

	Next

	If LEN(_aItensPallet) > 0
		AOMS74Travou( {} , _aItensPallet , "" , .T. )
	ENDIF


	//u_itconout(" *************\\\ Final da integração Italac x RDC."+" - "+DTOC(DATE())+" - "+TIME()+" ///********************************")

Return _lRet


WSMETHOD U_ESTORNC WSRECEIVE U_ESTORN WSSEND U_STATUS WSSERVICE U_AOMS074
	Local _lRet := .T.
	Local _nTamCGC
	Local _aOrd
	Local _cMsg, _nI, _cMsgOk
	Local _aFilial := FwLoadSM0()
	Local _cFilial, _cCodigo:=""
	Local _cCodEmpWS
	Local _aprods := {}

	Private _cMsgEstorno := ""

	Begin Sequence
		//u_itconout(" Incio integração Italac x RDC."+" - "+DTOC(DATE())+" - "+TIME())

		//===========================================================================================
		//Inicializando váriaveis que dependem do ambiente
		//===========================================================================================
		_nTamCGC    := TAMSX3("A2_CGC")[1]
		_aOrd := SaveOrd({"DA3","DA4","SC5","SC6","SA2","DAK","DAI","SC9"})
		_cCodEmpWS := U_ITGETMV( 'IT_EMPWEBSE' , '000001' )

		//===================================================================================
		// Valida o CNPJ do Embarcador enviado pela RDC e Prepara as variáveis de Ambiente.
		//===================================================================================
		_cMsg := ""

		If Empty(U_ESTORN:CNPJEM) .Or. Ascan(_aFilial,{|x| x[18] = Padr(U_ESTORN:CNPJEM,_nTamCGC," ")}) == 0
			_cMsg += " CNPJ Embarcador não preenchido, ou não está cadastrado. "
		Else
			_nI := Ascan(_aFilial,{|x| x[18] = Padr(U_ESTORN:CNPJEM,_nTamCGC," ")})
			_cFilial := _aFilial[_nI,5]
		EndIf

		If ! Empty(_cMsg)
			Break
		EndIf

		//=====================================================================
		// Limpa o ambiente, liberando a licença e fechando as conexões
		//=====================================================================
		RpcClearEnv()
		RpcSetType(2)
		//================================================================U_ESTORNC===========================
		// Preparando o ambiente com a filial da carga recebida
		//===========================================================================================
		//PREPARE ENVIRONMENT EMPRESA '01' FILIAL _cfilial; //USER 'Administrador' PASSWORD '' ;
			//        TABLES "SA7","SB1","SB2","SB5","SB8","SBJ","SB9","SBE","SBF","SC0","SD5","SBK","SD7","SDC","SF4","SGA","SM2","SDA","SDB","SBM","ADA","SA2","DAK","DAI","DA4","ZFU","ZFV","SC9","SA1","SC5","SC6","ZP1","SX6","SX1","SX2","SX3","SM0", "SIX" ;
			//        MODULO 'OMS'
		RpcSetEnv("01", "01",,,,, {"SA7","SB1","SB2","SB5","SB8","SBJ","SB9","SBE","SBF","SC0","SD5","SBK","SD7","SDC","SF4","SGA","SM2","SDA","SDB","SBM","ADA","SA2","DAK","DAI","DA4","ZFU","ZFV","SC9","SA1","SC5","SC6","ZP1","SX6","SX1","SX2","SX3","SM0", "SIX"})

		cFilAnt := _cfilial

		//===========================================================================================
		//Reinicializando váriaveis que dependem do ambiente
		//===========================================================================================
		_nTamCGC    := TAMSX3("A2_CGC")[1]
		DAK->(DbSetOrder(1)) // DAK_FILIAL+DAK_COD+DAK_SEQCAR

		//u_itconout(" Estorno de Carga via RDC: " + U_ESTORN:CODIGO+" - "+DTOC(DATE())+" - "+TIME())


		//===================================================================================
		// Valida se os dados enviados pela RDC estão corretos.
		//===================================================================================
		DAK->(Dbsetorder(1))
		If Empty(U_ESTORN:CODIGO)
			_cMsg += " Código de carga RDC não preenchido. "
		ElseIf ! DAK->(DbSeek(_cFilial+U_ESTORN:CODIGO))

			//Verifica se existe carga apagada
			_cQry := " SELECT DAK_COD,DAK_I_CARG "
			_cQry += " FROM "+RetSqlName("DAK")+" DAK "
			_cQry += " WHERE DAK_FILIAL = '"+ _cFilial + "' AND DAK_COD = '" + U_ESTORN:CODIGO + "'"

			If Select("TMPDEL") > 0
				TMPDEL->(DbCloseArea())
			EndIf

			_cQry := ChangeQuery(_cQry)
			DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry), "TMPDEL", .F., .T.)

			If (TMPDEL->(Eof()))

				_cMsg += " Não foi localizada nenhuma carga para ser Estornada. "

			Else

				_cCodigo:= TMPDEL->DAK_COD
				_cMsgOk := "Estorno da carga codigo RDC: "+AllTrim(TMPDEL->DAK_I_CARG)+" / Codigo de carga Italac: "+AllTrim(U_ESTORN:CODIGO)+", realizado com sucesso."
				Break

			Endif


		ELSEif AOMS074D() //Valida se a carga já tem faturamento

			_cMsg += "Viagem já foi faturada, realize o estorno do faturamento no Protheus antes de excluir a viagem RDC: "+AllTrim(DAK->DAK_I_CARG)+" / Codigo de carga Italac: "+AllTrim(DAK->DAK_COD)

		Else

			_cCodigo:=DAK->DAK_COD

//    _cusern:= AllTrim(FWLeUserlg("DAK->DAK_USERGI"))  // Carrega a variável  com o username do criador da carga.
			_cusern := SubStr(Embaralha(DAK->DAK_USERGI,1),3,6)
			//PswOrder(2)
			//PswSeek(_cusern,.T.)
			//aUsuario  :=PswRet()
			_cMailUsrCarga := U_UCFG001(3,_cusern)//Alltrim(aUsuario[1,14])  //envia email do criador da carga para o om200fim

		EndIf

		If ! Empty(_cMsg)
			Break
		EndIf

		_cMsgOk := "Estorno da carga codigo RDC: "+AllTrim(DAK->DAK_I_CARG)+" / Codigo de carga Italac: "+AllTrim(DAK->DAK_COD)+", realizado com sucesso."

		_cMsgEstorno := ""

		_ltravou := .T.
		_cCodigo:=DAK->DAK_COD

		BEGIN TRANSACTION

			//Registra produtos e armazens envolvidos na carga

			SC6->(Dbsetorder(1)) //C6_FILIAL+C6_NUM
			DAI->(Dbsetorder(1)) //DAI_FILIAL+DAI_COD
			SB2->(Dbsetorder(1)) //B2_FILIAL+B2_COD+B2_LOCAL

			If DAI->(Dbseek(_cfilial+_cCodigo))

				Do while _cfilial == DAI->DAI_FILIAL .AND. _cCodigo == DAI->DAI_COD

					If SC6->(Dbseek(DAI->DAI_FILIAL+DAI->DAI_PEDIDO))

						Do while _ltravou .and. SC6->C6_FILIAL == DAI->DAI_FILIAL .AND. SC6->C6_NUM == DAI->DAI_PEDIDO

							_ni := ascan(_aprods,{|AUX| AUX[1] == SC6->C6_PRODUTO .AND. AUX[2] == SC6->C6_LOCAL })

							If _ni == 0

								SB2->(Dbsetorder(1)) //B2_FILIAL+B2_COD+B2_LOCAL

								If SB2->(Dbseek(SC6->C6_FILIAL+SC6->C6_PRODUTO+SC6->C6_LOCAL)) .AND. !SB2->(MsRLock(SB2->(RECNO())))

									//u_itconout(" Produto em uso: "+AllTrim(SC6->C6_FILIAL+"/"+SC6->C6_PRODUTO+"/"+SC6->C6_LOCAL)+"."+" - "+DTOC(DATE())+" - "+TIME())
									_cMsgEstorno :=  "Produto em uso: "+AllTrim(SC6->C6_FILIAL+"/"+SC6->C6_PRODUTO+"/"+SC6->C6_LOCAL)+"."
									_ltravou := .F.

								Endif

								aadd(_aprods,{SC6->C6_PRODUTO,SC6->C6_LOCAL})

							Endif

							SC6->(Dbskip())

						Enddo

					Endif

					DAI->(Dbskip())

				Enddo

			Endif

			If _ltravou

				U_OM20MNUE("DAK",DAK->(Recno()),5,.T.) // Esta rotina realiza o estorno da carga.

			Endif

			_cMsg := _cMsgEstorno

			If _ltravou

				//Atualiza B2_RESERVA se necessário para cada produto/armazém
				For _ni := 1 to len(_aprods)


					_cQry := " SELECT sum(c9_qtdlib) SOMA "
					_cQry += " FROM "+RetSqlName("SC9")+" SC9 "
					_cQry += " WHERE SC9.D_E_L_E_T_ = '  '  AND  c9_filial = '" + _cfilial + "' and c9_local = '" + alltrim(_aprods[_ni][2]) + "' and c9_produto = '"+alltrim(_aprods[_ni][1])+"'"
					_cQry += " AND c9_blest = '  ' and c9_nfiscal = '         ' "

					If Select("ITQRSC9") > 0
						Dbselectarea("ITQRSC9")
						ITQRSC9->(DbCloseArea())
					EndIf

					_cQry := ChangeQuery(_cQry)
					DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry), "ITQRSC9", .F., .T.)

					SB2->(Dbsetorder(1)) //B2_FILIAL+B2_COD+B2_LOCAL
					If ITQRSC9->(!Eof()) .AND. SB2->(Dbseek(_cfilial+_aprods[_ni][1]+_aprods[_ni][2]))

						If SB2->B2_RESERVA != ITQRSC9->SOMA

							Reclock("SB2",.F.)
							SB2->B2_RESERVA := ITQRSC9->SOMA
							SB2->(Msunlock())

						Endif

					Endif

					If Select("ITQRSC9") > 0
						Dbselectarea("ITQRSC9")
						ITQRSC9->(DbCloseArea())
					EndIf


				Next

			Endif

		END TRANSACTION

	End Sequence

	If Empty(_cMsg)
		//u_itconout(" Retornando sucesso para o RDC - " + AllTrim(_cMsgOk) )
		::U_STATUS := "SUCESSO:TRUE; "+AllTrim(_cMsgOk)
	Else
		//u_itconout(" Retornando falha para o RDC - " + AllTrim(_cMsg) )
		::U_STATUS := "SUCESSO:FALSE; "+AllTrim(_cMsg)
	EndIf

// Grava log de comuinicação
	ZFU->(RecLock("ZFU",.T.))
	ZFU->ZFU_FILIAL	:= _cFilial          // Filial do Sistema
	ZFU->ZFU_DATA	:= Date()            // Data de Emissão
	ZFU->ZFU_HORA   := Time()            // Hora de inclusão na tabela de muro.
	ZFU->ZFU_CNPJEM	:= U_ESTORN:CNPJEM   // CNPJ do Embarcador
	ZFU->ZFU_CODIGO	:= U_ESTORN:CODIGO   // Codigo da Carga no RDC
	ZFU->ZFU_USUARI := __CUSERID         // Codigo do Usuário
	ZFU->ZFU_DATAAL := Date()            // Data de Alteração
	ZFU->ZFU_SITUAC := "P"               // Situação do Registro
	ZFU->ZFU_CODEMP := _cCodEmpWS	     // Codigo Empresa WebServer
	ZFU->ZFU_RETORN := AllTrim(::U_STATUS)+" [U_ESTORNC]" // Retorno Integracao Italac-RDC
	ZFU->ZFU_REGCAP := StrZero(ZFU->(Recno()),10) // Numero Registro Tab.Capa
	ZFU->ZFU_NCARGA := _cCodigo
	ZFU->(MsUnLock())

Return _lRet

WSMETHOD U_LIBERAC WSRECEIVE U_LIBERA WSSEND U_STATUS WSSERVICE U_AOMS074
	Local _lRet := .T.
	Local _nI
	Local _nTamChave := TamSX3('ZG0_CHAVE')[1]
	Local _aRegsCTE := {}, _cFilial
	Local _cMsg, _cMsgOk, _cMsgJaLiber
	Local _cCodEmpWS := U_ITGETMV( 'IT_EMPWEBSE' , '000001' )
	Local _cSerie, _cLoja, _cForn
	Local _cSituacao
	Local _cnatureza := ""
	Local _cfatura2 := "" , nAux
	Private lAutoErrNoFile, __aErrAuto
	lAutoErrNoFile := .T.
	__aErrAuto := ""

	Begin Sequence

		//u_itconout(" Liberacao de pagamento de CTE via RDC: " + Transform(U_LIBERA:CNPJTRA,"@R! NN.NNN.NNN/NNNN-99")+ " - Fatura: "+PADL(alltrim(U_LIBERA:FATURA),9,"0")+" - "+DTOC(DATE())+" - "+TIME())
		_cMsg   := ""
		_cMsgOk := ""
		_cMsgJaLiber := ""
		_cSerie := ""
		_cLoja  := ""
		_cForn  := ""
		_cfatura := PADL(alltrim(U_LIBERA:FATURA),9,"0")
		_cfilial := ""
		_cForndest := ""
		_clojadest := ""

		//u_itconout("Abrindo ambiente")
		//=====================================================================
		// Limpa o ambiente, liberando a licença e fechando as conexões
		//=====================================================================
		RpcClearEnv()
		RpcSetType(2)
		//===========================================================================================
		// Preparando o ambiente com a filial da carga recebida
		//===========================================================================================
		//PREPARE ENVIRONMENT EMPRESA '01' FILIAL "01";
			//        TABLES "SA7","SB1","SB2","SE2","SA1","SA2","SB5","SB8","SBJ","SB9","SBE","SBF","SC0","SD5","SBK","SD7","SDC","SF4","SGA","SM2","SDA","SDB","SBM","ADA","DA4","ZFU","ZFV","SC9","SC5","SC6";
			//        MODULO 'FIN'
		RpcSetEnv("01", "01",,,,, {"SA7","SB1","SB2","SE2","SA1","SA2","SB5","SB8","SBJ","SB9","SBE","SBF","SC0","SD5","SBK","SD7","SDC","SF4","SGA","SM2","SDA","SDB","SBM","ADA","DA4","ZFU","ZFV","SC9","SC5","SC6"})

		//u_itconout("Iniciando liberação")

		//Define fornecedor no qual será gerada a fatura
		SA2->(Dbsetorder(3))
		If SA2->(Dbseek(xfilial("SA2")+alltrim(U_LIBERA:CNPJTRA)))

			Do while ALLTRIM(SA2->A2_CGC) == ALLTRIM(U_LIBERA:CNPJTRA)

				If substr(alltrim(SA2->A2_COD),1,1) == "T" .AND. SA2->A2_MSBLQL <> '1'

					_cForndest := SA2->A2_COD
					_clojadest := SA2->A2_LOJA
					Exit

				Endif

				If substr(alltrim(SA2->A2_COD),1,1) == "F" .AND. SA2->A2_MSBLQL <> '1'

					_cForndest := SA2->A2_COD
					_clojadest := SA2->A2_LOJA

				Endif

				If empty(_cForndest) .AND. SA2->A2_MSBLQL <> '1'

					_cForndest := SA2->A2_COD
					_clojadest := SA2->A2_LOJA

				Endif

				SA2->(Dbskip())

			Enddo

		Else

			_cMsg := " Não foi possível localizar fornecedor para o Cnpj " + ALLTRIM(U_LIBERA:CNPJTRA)
			Break

		Endif

		If empty(_cForndest)

			_cMsg := " Não foi possível localizar fornecedor para o Cnpj " + ALLTRIM(U_LIBERA:CNPJTRA)
			Break

		Endif

		//Carrega itens da SF1

		For _nI := 1 To Len(U_LIBERA:ITENS)

			_cChave := PadR(U_LIBERA:ITENS[_nI]:CTE,_nTamChave," ")
	      //		U_itconout("Validando CTE " + strzero(_ni,4) + " - chave " + _cchave)

			_cquery := "SELECT F1_FILIAL,F1_DOC, R_E_C_N_O_ REC FROM " + retsqlname("SF1")
			_cquery +=  " F1 WHERE D_E_L_E_T_ = '  '  AND F1_CHVNFE = '"
			_cquery += ALLTRIM(_cChave) + "'"

			If select("QRYSF1") > 0

				QRYSF1->(Dblosearea())

			Endif

			dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery),"QRYSF1", .F., .T.)

			If QRYSF1->(!Eof())

				If empty(_cfilial)
					_cfilial := QRYSF1->F1_FILIAL
					cfilant := _cfilial
				Else
					If _cfilial != QRYSF1->F1_FILIAL
						//u_itconout("Item " + strzero(_ni,6) + " para CTE " + QRYSF1->F1_FILIAL + "/" + QRYSF1->F1_DOC + " com filial divergente!")
						_cmsg += "Item " + strzero(_ni,6) + " para CTE " + QRYSF1->F1_FILIAL + "/" + QRYSF1->F1_DOC + " com filial divergente!"
					Endif
				Endif
				//u_itconout("Localizado CTE item " + strzero(_ni,6) + " para CTE " + _cfilial + "/" + QRYSF1->F1_DOC)
				AADD(_aregsCTE,{_cfilial,_cChave,QRYSF1->REC,0 })

			Else

				_cMsg += " Não foi encontrado nota fiscal para a chave de CTE: "+ _cChave+ " / Fatura:" + _CFATURA + " / CNPJ: "+ Transform(U_LIBERA:CNPJTRA,"@R! NN.NNN.NNN/NNNN-99")

			Endif

			QRYSF1->(Dbclosearea())

		Next

		If !empty(_cMsg)
			Break
		Endif

		If Empty(_aRegsCTE)
			_cMsg := " Nenhuma chave de CTE foi informada para a fatura: " + _CFATURA + " / CNPJ: "+ Transform(U_LIBERA:CNPJTRA,"@R! NN.NNN.NNN/NNNN-99")
			Break
		EndIf

		BEGIN TRANSACTION

			_aTit := {}
			_cmsg2 := ""
			_ntotal := 0
			_ntitsfat := 0
			_nnj := 1
			_dini := date()
			_dfini := stod("20010101")
			_cfatura3 := ""

			For _nI := 1 To Len(_aRegsCTE)

				_cFilial := _aRegsCTE[_nI,1]
				_cChave  := _aRegsCTE[_nI,2]

				SE2->(DbSetOrder(6)) // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
				SF1->(DbSetOrder(8)) // F1_FILIAL+F1_CHVNFE  // IGUAL A CHAVE DO CTE

				//U_itconout("Validando nota fiscal do item " + strzero(_ni,4))

				//Valida registro do documento de entrada do CTE
				If ! SF1->(DbSeek(xFilial("SF1")+_cChave))
					_cMsg := " Não foi encontrado nota fiscal para a chave de CTE: "+ _cChave+ " / Fatura:" + U_LIBERA:FATURA + " / CNPJ: "+ Transform(U_LIBERA:CNPJTRA,"@R! NN.NNN.NNN/NNNN-99")
					Disarmtransaction()
					Break
				EndIf

				_cSerie := SF1->F1_SERIE

				If  alltrim(_cForndest)  != alltrim(SF1->F1_FORNECE)
					_cMsg := "Documento de entrada com fornecedor divergente para chave de CTE: "+ _cChave+ "."
					Disarmtransaction()
					Break
				EndIf

				//U_itconout("Validando título financeiro do item " + strzero(_ni,4))

				If ! SE2->(DbSeek(xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC))
					_cMsg := " Não foi encontrado título financeiro para a chave de CTE: "+ _cchave +  " / Fatura:" + U_LIBERA:FATURA + " / CNPJ: "+ Transform(U_LIBERA:CNPJTRA,"@R! NN.NNN.NNN/NNNN-99")
					Disarmtransaction()
					Break
				Else
					_aRegsCTE[_nI,4] := SE2->(Recno())
				EndIf

				If !EMPTY(SE2->E2_FATURA) .and. !EMPTY(_CFATURA3) .AND. (ALLTRIM(SE2->E2_FATURA) != ALLTRIM(_cfatura3))

					_cMsg := " Título/serie: " +SE2->E2_NUM+" / "+SE2->E2_PREFIXO+", chave CTE: "+ _cChave + ", "+" / CNPJ: "+ Transform(U_LIBERA:CNPJTRA,"@R! NN.NNN.NNN/NNNN-99") + ", já pertence a Fatura  " + SE2->E2_FATURA + "."
					Disarmtransaction()
					Break

				ElseIF !EMPTY(SE2->E2_FATURA) .AND. (ALLTRIM(SE2->E2_FATURA) == ALLTRIM(_cfatura3) .OR. EMPTY(_CFATURA3))

					_cfatura3 := SE2->E2_FATURA
					_ntitsfat++

				EndIf


				Do While ! SE2->(Eof()) .And. SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM == xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC

					_cnatureza := SE2->E2_NATUREZ
					_ccond := SF1->F1_COND

					If SE2->E2_EMISSAO < _dini

						_dini := SE2->E2_EMISSAO

					Endif

					If SE2->E2_EMISSAO > _dfini

						_dfini := SE2->E2_EMISSAO

					Endif

					//U_itconout("Liberando título do item " + strzero(_nnj,4))
					_ntotal += SE2->E2_VALOR
					_nnj++

					If SE2->E2_SALDO == 0 .OR. !EMPTY(SE2->E2_BAIXA)
						_cMsg2 := " Título/serie: " +SE2->E2_NUM+" / "+SE2->E2_PREFIXO+", chave CTE: "+ _cChave + ", "+" / CNPJ: "+ Transform(U_LIBERA:CNPJTRA,"@R! NN.NNN.NNN/NNNN-99") + ", já possui baixa."
					Endif

					If Empty(SE2->E2_BAIXA ) .And. Empty(SE2->E2_DATALIB)
						SE2->(RecLock("SE2",.F.))
						SE2->E2_DATALIB := Date()
						SE2->E2_USUALIB := "Admin-RDC"
						If SE2->(FieldPos("E2_STATLIB")) > 0
							SE2->E2_STATLIB := "03"  // Movimento liberado pelo usuário
						EndIf
						If SE2->(FieldPos("E2_CODAPRO")) > 0
							SE2->E2_CODAPRO := IIF(FindFunction("Fa006User"), Fa006User( "000000", .F., 2 ), "" )
						Endif
						SE2->(MsUnlock())
						_cMsgOk += " Título/serie: " +SE2->E2_NUM+" / "+SE2->E2_PREFIXO+", chave CTE: "+ _cChave + ", "+" / CNPJ: "+ Transform(U_LIBERA:CNPJTRA,"@R! NN.NNN.NNN/NNNN-99") + ", liberado com sucesso. "
					EndIf

					aadd(_aTit,{ SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA , SE2->E2_TIPO, .f.,SE2->E2_FORNECE,SE2->E2_LOJA})

					SE2->(DbSkip())
				EndDo
			Next

			//Valida valor da fatura contra total de valor dos canhotos e total de valor dos títulos
			If U_LIBERA:VALOR != _ntotal

				_cMsg := "Valor da fatura diverge do valor total dos títulos! (" + transform(_ntotal,"@E 999,999,999.99") + ")"
				Disarmtransaction()
				Break

			endif

			//Se já tem fatura pronta retorna com sucesso
			If _ntitsfat == len(_aRegsCTE) .and. empty(_cMsg) .and. !empty(_cfatura3)

				//U_ITCONOUT("Validando fatura pré existente...")

				//Verifica se a fatura préexistente é idêntica ao que veio no xml

				_cquery := "SELECT E2_FILIAL,E2_NUM,E2_VALOR, R_E_C_N_O_ REC FROM " + retsqlname("SE2")
				_cquery += " E2 WHERE D_E_L_E_T_ = '  '  AND E2_FILIAL = '" + cfilant + "' AND E2_FATURA = '" + _cfatura3 + "'"
				_cquery += " AND E2_FORNECE = '" + _cForndest + "' AND E2_LOJA = '" + _clojadest + "' "
				_cquery += " AND E2_TIPOFAT = 'FT' AND E2_FATPREF = 'MAN'"

				If select("QRYSE2") > 0

					QRYSE2->(Dblosearea())

				Endif

				dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery),"QRYSE2", .F., .T.)

				_lfalha := .F.
				_nvalor := 0

				Do while QRYSE2->(!Eof())

					//AADD(_aregsCTE,{_cfilial,_cChave,F1_RECNO,SE2_RECNO})
					If ascan(_aregsCTE,{|x| x[4] == QRYSE2->REC}) == 0

						_lfalha := .T.
						Exit

					Else

						_nvalor += QRYSE2->E2_VALOR

					Endif

					QRYSE2->(Dbskip())

				Enddo

				If _lfalha

					_cMsg := "Já existe fatura com um ou mais dos títulos selecionados -> " + cfilant + "/" + _cfatura3
					Disarmtransaction()
					Break

				Endif

				If _nvalor != U_LIBERA:VALOR

					_cMsg := "Valor da fatura diverge do valor total dos títulos! (" + transform(_nvalor,"@E 999,999,999.99") + ")"
					Disarmtransaction()
					Break

				Endif

				_cmsgok := " - Fatura " + _cfatura3 + " gerada no Protheus a partir da fatura RDC de no. " + U_LIBERA:FATURA
				_cfatura2 := _cfatura3
				Disarmtransaction()
				Break

			Elseif !empty(_cmsg2)

				_cMsg += _cmsg2
				Disarmtransaction()
				Break

			Endif

			//Se não teve erros cria a fatura
			If empty(_cMsg)

				aArray:={}

				Private lMsErroAuto := .F.

				aArray := {  "MAN",;
					"FT",;
					"   ",; //Em branco para seguir sequência de fatura do Protheus
				_cnatureza,;
					_dini,;
					_dfini,;
					_cForndest,;
					"    ",;   //Loja em branco para trazer todos os títulos do fornecedor
				_cforndest,;
					_clojadest,;
					_ccond,;
					01,;
					_aTit , , }

				_cfatura2 := soma1(GetMV( 'MV_NUMFATP' ,, '0' ))

				//U_itconout("Criando fatura " + _cfatura2 + "...")

				MsExecAuto( { |x,y| FINA290(x,y)},3,aArray,)

				If lMsErroAuto

					//Pegando log do ExecAuto
					cLogTxt := ""
					aLogAuto := GetAutoGRLog()

					//Percorrendo o Log
					For nAux:=1 To Len(aLogAuto)
						cLogTxt += aLogAuto[nAux] + Chr(13)+Chr(10)
					Next

					_cMsg := "Erro ao gerar a Fatura no Protheus - " +  cLogTxt
					//U_itconout("Erro ao gerar a Fatura no Protheus - " +  cLogTxt)
					Disarmtransaction()
					Break

				Else

					SE2->( DBSetOrder(1) )
					If SE2->( DBSeek( cfilant + "MAN" + _cfatura2  + '01' + "FT " + _cforndest + _clojadest ) )

						_CANO := SUBSTR(ALLTRIM(U_LIBERA:DATAP),7,4)
						_CMES := SUBSTR(ALLTRIM(U_LIBERA:DATAP),4,2)
						_CDIA := SUBSTR(ALLTRIM(U_LIBERA:DATAP),1,2)
						_ddatap := stod(_cano+_cmes+_cdia)

						If _ddatap < date()

							_ddatap := date()

						Endif

						SE2->( RecLock('SE2',.F.) )
						SE2->E2_VENCTO	:= _ddatap
						SE2->E2_VENCORI	:= _ddatap
						SE2->E2_VENCREA	:= DataValida( _ddatap  )
						SE2->E2_HIST := "Criada de fatura RDC de no. " + U_LIBERA:FATURA
						SE2->( MsUnlock() )

					Else

						_cMsg := "Erro ao gerar a Fatura no Protheus - não foi localizado o novo título."
						//U_itconout("Erro ao gerar a Fatura no Protheus - não foi localizado o novo título." )

					Endif

					_cmsgok += " - Fatura " + _cfatura2 + " gerada no Protheus para a fatura " + _cfatura + " do RDC."
					//U_ITCONOUT("Fatura " + _cfatura2 + " gerada no Protheus para a fatura " + _cfatura + " do RDC.")

				Endif

			Endif

		END TRANSACTION

	END SEQUENCE

	_cSituacao := "P"
	If Empty(_cMsg)
		::U_STATUS := "SUCESSO:TRUE; "+AllTrim(_cMsgOk) + If(Empty(_cMsgJaLiber),""," - ") + AllTrim(_cMsgJaLiber) // "Tudo OK na filial " + cfilant
		_cSituacao := "P"
	Else
		::U_STATUS := "SUCESSO:FALSE; "+AllTrim(_cMsg) // _cMsg
		_cSituacao := "R"
	EndIf

	_CANO := SUBSTR(ALLTRIM(U_LIBERA:DATAP),7,4)
	_CMES := SUBSTR(ALLTRIM(U_LIBERA:DATAP),4,2)
	_CDIA := SUBSTR(ALLTRIM(U_LIBERA:DATAP),1,2)
	_ddatap := stod(_cano+_cmes+_cdia)

	If _ddatap < date()

		_ddatap := date()

	Endif

	ZG7->(RecLock("ZG7",.T.))
	ZG7->ZG7_FILIAL := If(Empty(_aRegsCTE),xFilial("ZG7"),_cFilial)
	ZG7->ZG7_DATA   := Date()
	ZG7->ZG7_HORA   := Time() // hora de inclusão na tabela de muro.
	ZG7->ZG7_CNPJTR := U_LIBERA:CNPJTRA
	ZG7->ZG7_FATURA := U_LIBERA:FATURA
	ZG7->ZG7_VALOR  := U_LIBERA:VALOR
	ZG7->ZG7_DATAP  := _ddatap
	ZG7->ZG7_SERIE  := _cSerie
	ZG7->ZG7_FORNEC := _cLojadest
	ZG7->ZG7_LOJAFO := _cForndest
	ZG7->ZG7_USUARI := "000000" // Administrador
	ZG7->ZG7_A00001 :=  _cfatura2
	ZG7->ZG7_DATAAL := Date()
	ZG7->ZG7_SITUAC := _cSituacao
	ZG7->ZG7_CODEMP := _cCodEmpWS
	ZG7->ZG7_RETORN := ::U_STATUS
	ZG7->ZG7_REGCAP := ZG7->(Recno())
	ZG7->(MsUnlock())

	For _nI := 1 To Len(U_LIBERA:ITENS)
		ZG8->(RecLock("ZG8",.T.))
		ZG8->ZG8_FILIAL := If(Empty(_aRegsCTE),xFilial("ZG8"),_cFilial)
		ZG8->ZG8_DATA := Date()
		ZG8->ZG8_HORA := Time() // Hora de inclusão na tabela de muro.
		ZG8->ZG8_CNPJTR := U_LIBERA:CNPJTRA
		ZG8->ZG8_FATURA := U_LIBERA:FATURA
		ZG8->ZG8_CHVCTE := U_LIBERA:ITENS[_nI]:CTE
		ZG8->ZG8_USUARI := "000000" // Administrador
		ZG8->ZG8_DATAAL := Date()
		ZG8->ZG8_SITUAC := _cSituacao
		ZG8->ZG8_CODEMP := _cCodEmpWS
		ZG8->ZG8_RETORN := ::U_STATUS
		ZG8->ZG8_A00001 :=  _cfatura2
		ZG8->ZG8_REGCAP := ZG7->(Recno())
		ZG8->(MsUnlock())
	Next

Return _lRet

WSMETHOD U_ALTERAP WSRECEIVE U_ALTERA WSSEND U_STATUS WSSERVICE U_AOMS074

	Local _lRet := .T., _aRet
	Local _aFiliais := FWLoadSM0(), _nI
	Local _cFilial
	Local _aOrd := SaveOrd({"SC5","SC6"})
	Local _aCabPV, _aItemPV,_aItensPV
	Local _nTamFilial := TAMSX3("C5_FILIAL")[1]
	Local _nTamPedido := TAMSX3("C5_NUM")[1]
	Local _nTamItem   := TAMSX3("C6_ITEM")[1]
	Local _cChaveCapa, _cChaveItem
	Local _cUM, _c2UM, _nQtd, _n2Qtd
	Local _cMsgErro
	Local _cCodProd
	Local _nTamCodUser
	Local _cCodUsuario, _cNomeArqLog
	Local _cMsg, _cFator, _cTipoOper
    //Local _cPrd3Um := U_ITGETMV( "IT_PRD3UM" , "  ")	// Produtos a validar pela 3ª unidade de medida
	Local _ltemlib := .F.
	Local _nTotPesBr
	Local _cCrtl3Um := "N" // Produtos a validar quantidade fracionada na terceira unidade de medida.
    Local _cProd3Dec := SuperGetMV("IT_0743DEC",.F., "00060034701")

	Private aHeader,aCols,_cAOMS074,_cAOMS074Vld
	Private _cCodTab := Space(3)

	aHeader := {}
	aCols := {}
	_cAOMS074 := "U_ALTERAP" // Variável de controle para indicar a origem da chamada de funções.
	_cAOMS074Vld := ""

	Begin Sequence

		//U_ITCONOUT(" Iniciando alteração do pedido: "+AllTrim(U_ALTERA:PEDIDO)+"."+" - "+DTOC(DATE())+" - "+TIME())

		BEGIN TRANSACTION

			_cFilial := ""
			_nI := Ascan(_aFiliais,{|x| x[18] == AllTrim(U_ALTERA:CNPJEM)}) // CNPJ EMBARCADOR PEDIDO DE VENDAS
			If _nI == 0
				//u_itconout(" CNPJ informado no pedido de vendas não localizado no cadastro de filiais: " + U_ALTERA:CNPJEM+"."+" - "+DTOC(DATE())+" - "+TIME())
				::U_STATUS := "SUCESSO:FALSE; CNPJ informado no pedido de vendas não localizado no cadastro de filiais: " + U_ALTERA:CNPJEM+"."
				Disarmtransaction()
				Break
			EndIf

			_cFilial := _aFiliais[_nI,5]

			//===========================================================================================
			// Preparando o ambiente com a filial da carga recebida
			//===========================================================================================
			RpcClearEnv()
			RpcSetType(2)

			//PREPARE ENVIRONMENT EMPRESA '01' FILIAL _cfilial; //USER 'Administrador' PASSWORD '' ;
				//        TABLES "SA7","SB1","SB2","SB5","SB8","SBJ","SB9","SBE","SBF","SC0","SD5","SBK","SD7","SDC","SF4","SGA","SM2","SDA","SDB","SBM","ADA","SA2","DAK","DAI","DA4","ZFU","ZFV","SC9","SA1","SC5","SC6", "SA1" ,"ZP1","SX6","SX1","SX2","SX3","SM0", "SIX" ;
				//        MODULO 'OMS'
			RpcSetEnv("01", _cFilial,,,,, {"SA7","SB1","SB2","SB5","SB8","SBJ","SB9","SBE","SBF","SC0","SD5","SBK","SD7","SDC","SF4","SGA","SM2","SDA","SDB","SBM","ADA","SA2","DAK","DAI","DA4","ZFU","ZFV","SC9","SA1","SC5","SC6", "SA1" ,"ZP1","SX6","SX1","SX2","SX3","SM0", "SIX"})

			cFilAnt := _cfilial

			SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM
			SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
			SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD
			DA1->(DbSetOrder(1)) // DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM

			_cChaveCapa := Padr(_cFilial,_nTamFilial," ")+Padr(U_ALTERA:PEDIDO,_nTamPedido," ")

			//Prepara dados de usuário
			_nTamCodUser := TAMSX3("ZZL_RDCUSR")[1]
			_cCodUsuario := Posicione("ZZL",5,xfilial("ZZL")+AllTrim(Str(U_ALTERA:USUALT,_nTamCodUser)),"ZZL_CODUSU")// ZZL_FILIAL+ZZL_RDCUSR
			If Empty(_cCodUsuario)
				//u_itconout(" Usuário [" + AllTrim(Str(U_ALTERA:USUALT,_nTamCodUser)) + "] não cadastrado!"+" - "+DTOC(DATE())+" - "+TIME())
				::U_STATUS := "SUCESSO:FALSE; Usuário [" + AllTrim(Str(U_ALTERA:USUALT,_nTamCodUser)) + "] não cadastrado!"
				Disarmtransaction()
				Break
			EndIf
			__cUserId := _cCodUsuario // Carrega a variável do Workflow __cUserId com o código do solicitante da integração.

			//=============================================================================
			//Valida se o pedido existe
			//=============================================================================
			_lTemOPTriang:=.F.

			SC5->(Dbsetorder(1))
			If ! SC5->(DbSeek(_cChaveCapa))
				//u_itconout(" Pedido de Vendas não localizado: "+AllTrim(U_ALTERA:PEDIDO)+"."+" - "+DTOC(DATE())+" - "+TIME())
				::U_STATUS := "SUCESSO:FALSE; Pedido de Vendas não localizado: "+AllTrim(U_ALTERA:PEDIDO)+"."
				Disarmtransaction()
				Break
			Else

				_lTemOPTriang:= SC5->C5_I_OPER == '05' // .OR. SC5->C5_I_OPER == '42' 

				//=============================================================================
				//Tenta realizar lock de todos os registros por _ni segundos
				//=============================================================================
				_cMsgT:=""
				If !(AOMS74Travou( , , @_cMsgT ))

					::U_STATUS := _cMsgT

					Disarmtransaction()
					Break

				Endif


			EndIf

			//=============================================================================
			//Valida cliente bloqueado
			//=============================================================================
			If posicione("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_MSBLQL") == '1'

				//u_itconout(" Cliente do pedido bloqueado no cadastro "+AllTrim(SC5->C5_CLIENTE+"/"+SC5->C5_LOJACLI)+"."+" - "+DTOC(DATE())+" - "+TIME())
				::U_STATUS := "SUCESSO:FALSE; : Cliente do pedido bloqueado no cadastro "+AllTrim(SC5->C5_CLIENTE+"/"+SC5->C5_LOJACLI)+"."
				Disarmtransaction()
				Break

			Endif


			//=============================================================================
			//Valida se é pedido que pode alterar
			//=============================================================================
			If !EMPTY(SC5->C5_NOTA)
				//u_itconout(" Pedido não disponível para alteração RDC! Não foi enviado ou está faturado: "+AllTrim(U_ALTERA:PEDIDO)+"."+" - "+DTOC(DATE())+" - "+TIME())
				::U_STATUS := "SUCESSO:FALSE; Pedido não disponível para alteração RDC! Não foi enviado ou está faturado: "+AllTrim(U_ALTERA:PEDIDO)+"."
				Disarmtransaction()
				Break
			EndIf

			//u_itconout(" Validando crédito do pedido: "+AllTrim(U_ALTERA:PEDIDO)+"."+" - "+DTOC(DATE())+" - "+TIME())

			//=============================================================================
			//Valida crédito
			//=============================================================================
			If  SC5->C5_TIPO = 'N'

				_nTotPV:=0
				_lValCredito:=.T.

				SC6->(Dbsetorder(1))
				SC6->(Dbgotop())
				SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))
				_cchep := alltrim(GetMV("IT_CCHEP"))

				Do while SC6->C6_NUM == SC5->C5_NUM .AND. SC5->C5_FILIAL == SC6->C6_FILIAL

					_nTotPV += SC6->C6_VALOR

					If SC6->C6_PRODUTO == _cchep .OR. SC6->C6_CF $ '5910/6910/5911/6911'//NÃO VALIDA CRÉDITO PARA PALLET CHEP E PARA BONIFICAÇÃO
						_lValCredito:=.F.
						EXIT
					ENDIF

					If posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC") != 'S' //NÃO VALIDA CRÉDITO PARA PEDIDO SEM DUPLICATA
						_lValCredito:=.F.
						EXIT
					Endif

					If posicione("ZAY",1,xfilial("ZAY")+ SC6->C6_CF ,"ZAY_TPOPER") != 'V' //NÃO VALIDA CRÉDITO PARA PEDIDO COM CFOP QUE NÃO SEJA DE VENDA
						_lValCredito:=.F.
						EXIT
					Endif

					SC6->(DbSkip())

				Enddo

				IF _lValCredito

					_aRetCre := U_ValidaCredito( _nTotPV , SC5->C5_CLIENTE , SC5->C5_LOJACLI , .T. , , , , SC5->C5_MOEDA,,SC5->C5_NUM)
					_cBlqCred:=_aRetCre[1]

					Reclock("SC5",.F.)

					If _aRetCre[2] = "B"//Se bloqueou

						If SC5->C5_I_BLCRE == "R"

							lBlq2			:= .T.
							SC5->C5_I_BLCRE	:= "R"
							SC5->C5_I_DTAVA := DATE()
							SC5->C5_I_HRAVA := TIME()
							SC5->C5_I_USRAV := cusername
							SC5->C5_I_MOTBL := _cBlqCred


						Else

							lBlq2			:= .T.
							SC5->C5_I_BLCRE	:= "B"
							SC5->C5_I_DTAVA := DATE()
							SC5->C5_I_HRAVA := TIME()
							SC5->C5_I_USRAV := cusername
							SC5->C5_I_MOTBL := _cBlqCred

						Endif

					EndIf

					SC5->C5_I_MOTBL := _cBlqCred//Sempre grava a descrição
					SC5->(Msunlock())

				ENDIF

			ENDIF


			//=====================================================================
			//Analisa se teve alteração de código de produto
			//=====================================================================
			_nposc5 := SC5->(Recno())
			SC6->(DbSetOrder(1))

			For _nI := 1 To Len(U_ALTERA:ITENS)

				If SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM+STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2)))

					If !(alltrim(SC6->C6_PRODUTO) ==  SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11))


						//u_itconout(" Validando regra de condição de pagamento para alteração de produto  - [" + STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2) +" - Do produto " + alltrim(SC6->C6_PRODUTO) + " para o produto " + SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11) + "] - "+DTOC(DATE())+" - "+TIME())

						_ccondori := u_IT_conpg(alltrim(SC5->C5_CLIENT),alltrim(SC5->C5_LOJAENT),alltrim(SC6->C6_PRODUTO))
						SC5->(Dbgoto(_nposc5))
						_ccondnew := u_IT_conpg(alltrim(SC5->C5_CLIENT),alltrim(SC5->C5_LOJAENT),SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11))
						SC5->(Dbgoto(_nposc5))

						If  _ccondori != _ccondnew

							//u_itconout(" Conflito de condição de pagamento para alteração de produto  - [" + STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2) +" - Do produto " + alltrim(SC6->C6_PRODUTO) + " para o produto " + SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11) + "] - "+DTOC(DATE())+" - "+TIME())
							//u_itconout(" Alteração não será executada!")

							::U_STATUS := "SUCESSO:FALSE; : Conflito de condição de pagamento para alteração de produto  - [" + STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2) +" - Do produto " + alltrim(SC6->C6_PRODUTO) + " para o produto " + SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11) + "]."
							Disarmtransaction()
							Break

						Endif


						//u_itconout(" Validando regra de comissão para alteração de produto  - [" + STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2) +" - Do produto " + alltrim(SC6->C6_PRODUTO) + " para o produto " + SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11) + "] - "+DTOC(DATE())+" - "+TIME())


						//Prepara aheader e acols
						aheader := {}
						acols := {}
						Private n
						n := 1

						aadd(aheader,{"","C6_PRODUTO"})
						aadd(aheader,{"","C6_COMIS1"})
						aadd(aheader,{"","C6_COMIS2"})
						aadd(aheader,{"","C6_COMIS3"})
						aadd(aheader,{"","C6_COMIS4"})
						aadd(aheader,{"","C6_TES"})
						aadd(aheader,{"","C6_I_LIBPR"})
						aadd(aheader,{"","C6_CF"})
						aadd(aheader,{"","C6_I_VLIBPR"})

						aadd(acols,{SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11),SC6->C6_COMIS1,SC6->C6_COMIS2,SC6->C6_COMIS3,SC6->C6_COMIS4,SC6->C6_TES,SC6->C6_I_LIBPR,SC6->C6_CF,SC6->C6_I_VLIBPR,.F.})

						//atualiza acols com comissão do novo produto
						U_AOMS013(.T.,SC5->C5_VEND1, SC5->C5_CLIENTE, SC5->C5_LOJACLI)
						SC5->(Dbgoto(_nposc5))

						If  SC6->C6_COMIS1 != acols[1][2] .OR. SC6->C6_COMIS2 != acols[1][2] .OR. SC6->C6_COMIS3 != acols[1][2] .OR. SC6->C6_COMIS4 != acols[1][2]

							//u_itconout(" Conflito de regra de comissão para alteração de produto  - [" + STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2) +" - Do produto " + alltrim(SC6->C6_PRODUTO) + " para o produto " + SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11) + "] - "+DTOC(DATE())+" - "+TIME())
							//u_itconout(" Alteração não será executada!")

							::U_STATUS := "SUCESSO:FALSE; : Conflito de regra de comissão e/ou desconto contratual para alteração de produto  - [" + STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2) +" - Do produto " + alltrim(SC6->C6_PRODUTO) + " para o produto " + SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11) + "]."
							Disarmtransaction()
							Break

						Endif

						//Validação de regra de comissão e desconto contratual
						If  !(U_AOMS049(SC5->C5_VEND1, .F., SC5->C5_CLIENTE, SC5->C5_LOJACLI))

							//u_itconout(" Conflito de regra de comissão e/ou desconto contratual para alteração de produto  - [" + STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2) +" - Do produto " + alltrim(SC6->C6_PRODUTO) + " para o produto " + SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11) + "] - "+DTOC(DATE())+" - "+TIME())
							//u_itconout(" Alteração não será executada!")

							::U_STATUS := "SUCESSO:FALSE; : Conflito de regra de comissão e/ou desconto contratual para alteração de produto  - [" + STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2) +" - Do produto " + alltrim(SC6->C6_PRODUTO) + " para o produto " + SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11) + "]."
							Disarmtransaction()
							Break

						Endif

						SC5->(Dbgoto(_nposc5))

						//u_itconout(" Validando preço para alteração de produto  - [" + STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2) +" - Do produto " + alltrim(SC6->C6_PRODUTO) + " para o produto " + SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11) + "] - "+DTOC(DATE())+" - "+TIME())

						If SC5->C5_I_TRCNF = "S" .and. !EMPTY(SC5->C5_I_FLFNC) .AND. SC5->C5_I_FLFNC != SC5->C5_FILIAL

							_CFILPRO := SC5->C5_I_FLFNC

						Else

							_CFILPRO := SC5->C5_FILIAL

						Endif

						If  U_BLQPRC(SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11),SC6->C6_PRCVEN,IF(SC5->C5_I_TRCNF="S",SC5->C5_I_FILFT,SC5->C5_FILIAL),.F.,SC5->C5_I_TAB,.T.)

							//u_itconout(" Conflito de preço para alteração de produto  - [" + STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2) +" - Do produto " + alltrim(SC6->C6_PRODUTO) + " para o produto " + SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11) + "] - "+DTOC(DATE())+" - "+TIME())
							//u_itconout(" Alteração não será executada!")

							::U_STATUS := "SUCESSO:FALSE; : Conflito de preço para alteração de produto  - [" + STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2) +" - Do produto " + alltrim(SC6->C6_PRODUTO) + " para o produto " + SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11) + "]."
							Disarmtransaction()
							Break

						Endif


						SC5->(Dbgoto(_nposc5))



						_npsc6 := SC6->(Recno())
						SC6->(Dbsetorder(1))
						SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))

						Do while SC6->C6_FILIAL == SC5->C5_FILIAL .AND. SC6->C6_NUM == SC5->C5_NUM

							If alltrim(SC6->C6_PRODUTO) == SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11)

								//u_itconout(" Alteração de produto para produto já existente no pedido  - [" + STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2) +" - Do produto " + alltrim(SC6->C6_PRODUTO) + " para o produto " + SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11) + "] - "+DTOC(DATE())+" - "+TIME())
								//u_itconout(" Alteração não será executada!")

								::U_STATUS := "SUCESSO:FALSE; : Alteração de produto para produto já existente no pedido  - [" + STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2) +" - Do produto " + alltrim(SC6->C6_PRODUTO) + " para o produto " + SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11) + "]."
								Disarmtransaction()
								Break

							Endif

							SC6->(Dbskip())

						Enddo

						SC6->(Dbgoto(_npsc6))
						SC5->(Dbgoto(_nposc5))

						//u_itconout(" Validando regra de alteração de produto  - [" + STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2) +" - Do produto " + alltrim(SC6->C6_PRODUTO) + " para o produto " + SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11) + "] - "+DTOC(DATE())+" - "+TIME())

						If ALLTRIM(posicione("SB1",1,xfilial("SB1")+alltrim(SC6->C6_PRODUTO),"B1_CODBAR")) != ALLTRIM(posicione("SB1",1,xfilial("SB1")+SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11),"B1_CODBAR"))

							//u_itconout(" Alteração de produto para produto de tipo diferente!  - [" + STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2) +" - Do produto " + alltrim(SC6->C6_PRODUTO) + " para o produto " + SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11) + "] - "+DTOC(DATE())+" - "+TIME())
							//u_itconout(" Alteração não será executada!")

							::U_STATUS := "SUCESSO:FALSE; : Alteração de produto para produto de tipo diferente!  - [" + STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2) +" - Do produto " + alltrim(SC6->C6_PRODUTO) + " para o produto " + SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11) + "]."
							Disarmtransaction()
							Break

						Endif

						//u_itconout(" Realizando alteração de produto  - [" + STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2) +" - Do produto " + alltrim(SC6->C6_PRODUTO) + " para o produto " + SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11) + "] - "+DTOC(DATE())+" - "+TIME())

						SC9->(Dbsetorder(1))
						If (SC9->(DbSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM)))
							SC9->(A460Estorna()) //Se já tem sc9  estorna a liberação
						Endif

						Reclock("SC6",.F.)
						SC6->C6_PRODUTO :=  SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11)
						SC6->C6_DESCRI := POSICIONE("SB1",1,xfilial("SB1")+SC6->C6_PRODUTO,"B1_DESC")
						SC6->(Msunlock())

					Endif

				Else

					//u_itconout(" Item do pedido não localizado - [" + STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2) +"] - "+DTOC(DATE())+" - "+TIME())
					::U_STATUS := "SUCESSO:FALSE; Item do pedido não localizado - [" + STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2) +"] ."
					Disarmtransaction()
					Break

				Endif



			Next



			//=====================================================================
			// Este trecho trata a alteração de pedidos de vendas.
			//=====================================================================

			_aCabPV  :={}
			_aItemPV :={}
			_aItensPV:={}

			Aadd( _aCabPV, { "C5_FILIAL"	   ,SC5->C5_FILIAL  , Nil})//filial
			Aadd( _aCabPV, { "C5_NUM"       ,SC5->C5_NUM	    , Nil})
			Aadd( _aCabPV, { "C5_TIPO"	   ,SC5->C5_TIPO    , Nil})//Tipo de pedido
			Aadd( _aCabPV, { "C5_I_OPER"	   ,SC5->C5_I_OPER  , Nil})//Tipo da operacao
			Aadd( _aCabPV, { "C5_CLIENTE"   ,SC5->C5_CLIENTE , NiL})//Codigo do cliente
			Aadd( _aCabPV, { "C5_CLIENT"    ,SC5->C5_CLIENT	, Nil})
			Aadd( _aCabPV, { "C5_LOJAENT"   ,SC5->C5_LOJAENT , NiL})//Loja para entrada
			Aadd( _aCabPV, { "C5_LOJACLI"   ,SC5->C5_LOJACLI , NiL})//Loja do cliente
			Aadd( _aCabPV, { "C5_EMISSAO"   ,SC5->C5_EMISSAO , NiL})//Data de emissao
			Aadd( _aCabPV, { "C5_TRANSP"    ,SC5->C5_TRANSP	, Nil})
			Aadd( _aCabPV, { "C5_CONDPAG"   ,SC5->C5_CONDPAG , NiL})//Codigo da condicao de pagamanto*
			Aadd( _aCabPV, { "C5_VEND1"     ,SC5->C5_VEND1	, Nil})
			Aadd( _aCabPV, { "C5_MOEDA"	  ,SC5->C5_MOEDA   , Nil})//Moeda
			Aadd( _aCabPV, { "C5_MENPAD"    ,SC5->C5_MENPAD	, Nil})
			Aadd( _aCabPV, { "C5_LIBEROK"   ,SC5->C5_LIBEROK , NiL})//Liberacao Total
			Aadd( _aCabPV, { "C5_TIPLIB"    ,SC5->C5_TIPLIB  , Nil})//Tipo de Liberacao
			Aadd( _aCabPV, { "C5_TIPOCLI"   ,SC5->C5_TIPOCLI , NiL})//Tipo do Cliente
			Aadd( _aCabPV, { "C5_I_NPALE"   ,SC5->C5_I_NPALE , NiL})//Numero que originou a pedido de palete
			Aadd( _aCabPV, { "C5_I_PEDPA"   ,SC5->C5_I_PEDPA , NiL})//Pedido Refere a um pedido de Pallet
			Aadd( _aCabPV, { "C5_I_DTENT"   ,CTOD(U_ALTERA:DTPREV) , Nil}) //Dt de Entrega // SC5->C5_I_DTENT
			Aadd( _aCabPV, { "C5_FECENT"    ,CTOD(U_ALTERA:DTPREV) , Nil}) //Dt de Entrega // SC5->C5_I_DTENT
			Aadd( _aCabPV, { "C5_I_TRCNF"   ,SC5->C5_I_TRCNF , Nil})
			Aadd( _aCabPV, { "C5_I_BLPRC"   ,SC5->C5_I_BLPRC , Nil})
			Aadd( _aCabPV, { "C5_I_BLCRE"   ,SC5->C5_I_BLCRE , Nil})
			Aadd( _aCabPV, { "C5_I_FILFT"   ,SC5->C5_I_FILFT , Nil})
			Aadd( _aCabPV, { "C5_I_FLFNC"   ,SC5->C5_I_FLFNC , Nil})
			Aadd( _aCabPV, { "C5_I_BLCRE"   ,SC5->C5_I_BLCRE , Nil})
			Aadd( _aCabPV, { "C5_USERLGA"   ,u_retlgilga(_cCodUsuario)    , Nil})
			Aadd( _aCabPV, { "C5_I_TIPCA"   ,U_ALTERA:TIPOPA , Nil})
			Aadd( _aCabPV, { "C5_I_AGEND"   ,SC5->C5_I_AGEND , Nil})
			Aadd( _aCabPV, { "C5_I_OBCOP"   ,U_AOMS074X(U_ALTERA:OBSCPA) , Nil})
			Aadd( _aCabPV, { "C5_MENNOTA"   ,U_AOMS074X(U_ALTERA:OBSNFE) , Nil})
			Aadd( _aCabPV, { "C5_I_OBPED"   ,U_AOMS074X(U_ALTERA:OBSPVE) , Nil})
			Aadd( _aCabPV, { "C5_TPFRETE"   ,SC5->C5_TPFRETE , Nil})
			Aadd( _aCabPV, { "C5_I_TAB"     ,SC5->C5_I_TAB  , Nil})
			Aadd( _aCabPV, { "C5_DESCONT"   ,SC5->C5_DESCONT , Nil})

			_cCodTab := SC5->C5_I_TAB

			_ltemlib := .T.
			_cProdPe := U_ITGETMV( "IT_PRODPE" , "  ")	// Produtos permitidos que não validam quantidades fracinadas
			_cLocval := U_ITGETMV( "IT_LOCFRA" , "  ")	// Armazéns que não valida quantidade fracionada

			_lValidFrac1UM:=.T.
			If ZZL->(FIELDPOS("ZZL_PEFRPA")) = 0 .OR.;
					Posicione("ZZL",5,xfilial("ZZL")+AllTrim(Str(U_ALTERA:USUALT,_nTamCodUser)),"ZZL_PEFRPA") == "S"
				_lValidFrac1UM:=.F.
			EndIf

			_nTotPesBr := 0

			For _nI := 1 To Len(U_ALTERA:ITENS)

				//Analisa se item está com liberação válida
				SC9->(Dbsetorder(1))
				If !( SC9->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM+STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2))) .AND. SC9->C9_BLEST = '  ')

					_ltemlib := .F.

				Endif

				_cCodProd := SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11)

				SB1->(Dbsetorder(1))
				If ! SB1->(DbSeek(xFilial("SB1")+_cCodProd ))
					//u_itconout(" Código de Produto não cadastrado: "+AllTrim(_cCodProd)+"."+" - "+DTOC(DATE())+" - "+TIME())
					::U_STATUS := "SUCESSO:FALSE; Código de Produto não cadastrado: "+AllTrim(_cCodProd)+"."
					Break
				ElseIf SB1->B1_MSBLQL == "1" // Bloqueado
					//u_itconout(" Código de Produto bloqueado: "+AllTrim(_cCodProd)+"."+" - "+DTOC(DATE())+" - "+TIME())
					::U_STATUS := "SUCESSO:FALSE; Código de Produto bloqueado: "+AllTrim(_cCodProd)+"."
					Break
				EndIf

				If AllTrim(Upper(U_ALTERA:ITENS[_nI]:EXCLUI)) == "S"
					_cDeleta := "S"
				Else
					_cDeleta := "N"
				EndIf

				//======================================================================
				// Conversão de unidades de medida (RDC).
				// U_ALTERA:ITENS[_nI]:UNMED = 1 => Unidade
				// U_ALTERA:ITENS[_nI]:UNMED = 2 => Caixa
				//======================================================================

				If AllTrim(U_ALTERA:ITENS[_nI]:UNMED) == "1" // CX    //Verificação para produtos normais
					_cUM   := SB1->B1_UM
					_c2UM  := SB1->B1_SEGUM
					If SB1->B1_TIPCONV == "M"
						_nQtd  := U_ALTERA:ITENS[_nI]:QTDEPR / SB1->B1_CONV
						_cFator := AllTrim(Str(SB1->B1_CONV,18,6))
						_cTipoOper := " Multiplicação. "
					Else
						_nQtd  := U_ALTERA:ITENS[_nI]:QTDEPR * SB1->B1_CONV
						_cFator := AllTrim(Str(SB1->B1_CONV,18,6))
						_cTipoOper := " Divisão. "
					EndIf
					
					_n2Qtd := U_ALTERA:ITENS[_nI]:QTDEPR

				ElseIf AllTrim(U_ALTERA:ITENS[_nI]:UNMED) == "2" // Unidade
					_cUM   := SB1->B1_UM
					_c2UM  := SB1->B1_SEGUM
					_nQtd  := U_ALTERA:ITENS[_nI]:QTDEPR
					If SB1->B1_TIPCONV == "M"
						_n2Qtd := U_ALTERA:ITENS[_nI]:QTDEPR * SB1->B1_CONV
						_cFator := AllTrim(Str(SB1->B1_CONV,18,6))
						_cTipoOper := " Multiplicação. "
					Else
						_n2Qtd := U_ALTERA:ITENS[_nI]:QTDEPR / SB1->B1_CONV
						_cFator := AllTrim(Str(SB1->B1_CONV,18,6))
						_cTipoOper := " Divisão. "
					EndIf

				ElseIf AllTrim(U_ALTERA:ITENS[_nI]:UNMED) == "3"
					_cUM   := SB1->B1_UM
					_c2UM  := SB1->B1_SEGUM
					_nQtd  := U_ALTERA:ITENS[_nI]:QTDEPR
					_n2Qtd := U_ALTERA:ITENS[_nI]:QTDPEC
					_cFator := AllTrim(Str(SB1->B1_CONV,18,6))
					_cTipoOper := " Controle de Peças. "
					//=====================================================================================
					// Calcular a quantidade de peças se a tag U_ALTERA:ITENS[_nI]:QTDPEC estiver vazia. 
					//=====================================================================================
                    If U_ALTERA:ITENS[_nI]:QTDPEC == 0 
                       If SB1->B1_CONV == 0  .And. SB1->B1_I_QQUEI == 'S' .And. SB1->B1_I_FATCO > 0
                          If SB1->B1_TIPCONV == "M"
						     _n2Qtd := U_ALTERA:ITENS[_nI]:QTDEPR * SB1->B1_I_FATCO 
					      Else
						     _n2Qtd := U_ALTERA:ITENS[_nI]:QTDEPR / SB1->B1_I_FATCO
					      EndIf
					   EndIf 
					EndIf 
				EndIf

				_cMsg := ""

				//Valida se está salvando segunda unidade de medida com B1_CONV zerado
				If SB1->B1_CONV == 0 .and. _n2Qtd > 0 .And. AllTrim(U_ALTERA:ITENS[_nI]:UNMED) <> "3"
					_cMsg += "1-O produto informado: " + _cCodProd + " - " + AllTrim(SB1->B1_DESC) + " - Item: " + strzero(U_ALTERA:ITENS[_nI]:ITEM,3) + " não pode ser vendido usando segunda unidade de medida pois não tem fator de conversão cadastrado."
				Endif

				//==============================================================
				// Validar aqui as quantidade fracionadas 3 unidade de medida.
				//==============================================================
				_cCrtl3Um := POSICIONE("SBZ",1,SC5->C5_FILIAL+_cCodProd,"BZ_I_PR3UM")
				If _cCrtl3Um == "S"
				    _nQtd:= Round(_nQtd, 2)
                    If !Alltrim(SB1->B1_COD) $ _cProd3Dec
					   If Mod(_nQtd , SB1->B1_I_QT3UM) <> 0
					    	_cMsg += "2-O produto informado: " + _cCodProd + " - " + AllTrim(SB1->B1_DESC) + " - Item: " + strzero(U_ALTERA:ITENS[_nI]:ITEM,3) + " não pode ser vendido com quantidade fracionada. Verificar a Terceira Unidade de Medida [" + SB1->B1_I_3UM + "], pois não poderá haver quantidades fracionadas."
					   EndIf
                    EndIf
				Else
					If !(AllTrim(_cCodProd) $ _cProdPe) .and. !(AllTrim(U_ALTERA:ITENS[_nI]:CODARM) $ _cLocval)//Verifica se deve validar quantidade fracionada
						If _n2Qtd - noround(_n2Qtd,0) <> 0
							_cMsg += "3-O produto informado: " + _cCodProd + " - " + AllTrim(SB1->B1_DESC) + " - Item: " + strzero(U_ALTERA:ITENS[_nI]:ITEM,3) + " não pode ser vendido com quantidade fracionada. Verificar a Segunda Unidade de Medida pois não poderá haver quantidades fracionadas."
						EndIf
						If _nQtd - noround(_nQtd,0) <> 0
							_cMsg += "4-O produto informado: " + _cCodProd + " - " + AllTrim(SB1->B1_DESC) + " - Item: " + strzero(U_ALTERA:ITENS[_nI]:ITEM,3) + " não pode ser vendido com quantidade fracionada. Verificar a Primeira Unidade de Medida pois não poderá haver quantidades fracionadas."
						EndIf
					EndIf
				EndIf

				//u_itconout("Dados Produto: "+AllTrim(_cCodProd)+"/"+SB1->B1_TIPO+"/"+SB1->B1_UM+"/"+AllTrim(Str(_nQtd,18,5))+"/"+AllTrim(Str(U_ALTERA:USUALT,_nTamCodUser)) )

				IF _lValidFrac1UM .AND. SB1->B1_TIPO == "PA" .AND. SB1->B1_UM == "UN"
					If _nQtd - noround(_nQtd,0) <> 0
						_cMsg += "5-O produto informado: " + _cCodProd + " - " + AllTrim(SB1->B1_DESC) + " - Item: " + strzero(U_ALTERA:ITENS[_nI]:ITEM,3) + " não pode ser vendido com quantidade fracionada. Verificar a Primeira Unidade de Medida pois não poderá haver quantidades fracionadas."
					EndIf
				ENDIF

				If ! Empty(_cMsg)
					If AllTrim(U_ALTERA:ITENS[_nI]:UNMED) == "1"
						_cMsg += "Recebido como Segunda unidade de medida"
					Else
						_cMsg += "Recebido como Primeira unidade de medida"
					Endif
					_cMsg += " - yQuantidade primeira unidade de medida: " + AllTrim(Str(Round(_nQtd, 3),18,6)) + " " + _cUM
					_cMsg += " - Quantidade segunda unidade de medida: " + AllTrim(Str(_n2Qtd,18,6)) + " " + _c2UM

					If _cCrtl3Um == "S"
						_cMsg += " - Produto usa Terceira unidade de medida: " + AllTrim(SB1->B1_I_3UM)
						_cMsg += " - Quantidade terceira unidade de medida: " + AllTrim(Str((_nQtd / SB1->B1_I_QT3UM),18,6)) + " " + _cUM
					Endif

					_cMsg += " - Fator de Conversão: " + _cFator
					_cMsg += " - Tipo de Conversão: " + _cTipoOper
					::U_STATUS := "SUCESSO:FALSE; " + _cMsg
					Disarmtransaction()
					Break
				EndIf

				_cChaveItem := Padr(_cFilial,_nTamFilial," ")+Padr(U_ALTERA:PEDIDO,_nTamPedido," ")+StrZero(U_ALTERA:ITENS[_nI]:ITEM,_nTamItem)
				SC6->(Dbsetorder(1))
				If SC6->(DbSeek(_cChaveItem))

					If ! SC6->(DbSeek(_cChaveItem))
						_cMsg += " Item não localizado para a Filial: '"+Padr(_cFilial,_nTamFilial," ")+"', Pedido de Vendas: '"+Alltrim(U_ALTERA:PEDIDO)+"', Item: '"+StrZero(U_ALTERA:ITENS[_nI]:ITEM,2)+"'. "
						::U_STATUS := "SUCESSO:FALSE; " + _cMsg
						Disarmtransaction()
						Break
					EndIf

					If AllTrim(_cCodProd) <> AllTrim(SC6->C6_PRODUTO)
						_cMsg += "Código de Produto: '"+AllTrim(U_ALTERA:ITENS[_nI]:CODIGO)+"' não localizado para a Filial: '"+Padr(_cFilial,_nTamFilial," ")+"', Pedido de Vendas: '"+Alltrim(U_ALTERA:PEDIDO)+"', Item: '"+StrZero(U_ALTERA:ITENS[_nI]:ITEM,2)+"'. "
						::U_STATUS := "SUCESSO:FALSE; " + _cMsg
						Disarmtransaction()
						Break
					EndIf

					_aItemPV:={}

					//Analisa se é alteração ou desmembramento, se for desmembramento não mexe aqui na quantidade
					If U_ALTERA:ITENS[_nI]:DESMEM == "S"

						If _lTemOPTriang
							_cMsg += "Filial: '"+Padr(_cFilial,_nTamFilial," ")+"', Pedido de Vendas: '"+Alltrim(U_ALTERA:PEDIDO)
							_cMsg += "' nao pode ser desmembrado pois possui PV Vinculado ou Op Triangular. "
							::U_STATUS := "SUCESSO:FALSE; " + _cMsg
							Disarmtransaction()
							Break
						EndIf

						_n2Qtd := SC6->C6_UNSVEN
						_nQtd := SC6->C6_QTDVEN
						_nqpallets := SC6->C6_I_QPALT
						_cmotivs:="98"//para gravar o motivo 98 no ITGrvLog()
					Else
						_nqpallets := U_ALTERA:ITENS[_nI]:QTDEPA
					Endif

					AAdd( _aItemPV , { "LINPOS"     ,"C6_ITEM", SC6->C6_ITEM }) //  Informa a posição do item
					AAdd( _aItemPV , { "AUTDELETA"  ,_cDeleta        , Nil }) // Informa se o item será ou não excluído.
					AAdd( _aItemPV , { "C6_FILIAL"  ,SC6->C6_FILIAL  , Nil }) // FILIAL
					AAdd( _aItemPV , { "C6_NUM"     ,SC6->C6_NUM     , Nil }) // Num. Pedido
					AAdd( _aItemPV , { "C6_ITEM"    ,SC6->C6_ITEM    , Nil }) // Numero do Item no Pedido
					AAdd( _aItemPV , { "C6_PRODUTO" ,SC6->C6_PRODUTO , Nil }) // Codigo do Produto
					AAdd( _aItemPV , { "C6_QTDVEN"  ,_nQtd           , Nil }) // Quantidade Vendida
					AAdd( _aItemPV , { "C6_UNSVEN"  ,_n2Qtd          , Nil }) // Quantidade Vendida 2 un
					AAdd( _aItemPV , { "C6_PRCVEN"  ,SC6->C6_PRCVEN  , Nil }) // Preco Unitario Liquido
					AAdd( _aItemPV , { "C6_PRUNIT"  ,SC6->C6_PRUNIT  , Nil }) // Preco Unitario Liquido
					AAdd( _aItemPV , { "C6_ENTREG"  ,SC6->C6_ENTREG  , Nil }) // Data da Entrega
					AAdd( _aItemPV , { "C6_LOJA"    ,SC6->C6_LOJA	  , Nil })
					AAdd( _aItemPV , { "C6_SUGENTR" ,SC6->C6_SUGENTR , Nil }) // Data da Entrega
					AAdd( _aItemPV , { "C6_VALOR"   ,round((SC6->C6_PRCVEN * _nQtd),2), Nil }) // valor total do item // SC6->C6_VALOR
					AAdd( _aItemPV , { "C6_UM"      ,SC6->C6_UM      , Nil }) // Unidade de Medida Primar.
					AAdd( _aItemPV , { "C6_LOCAL"   ,AllTrim(U_ALTERA:ITENS[_nI]:CODARM), Nil }) // Almoxarifado

					//Se armazém mudou vai gatilhar sozinho a tes e cf
					If (alltrim(SC6->C6_LOCAL) == AllTrim(U_ALTERA:ITENS[_nI]:CODARM))
						AAdd( _aItemPV , { "C6_TES"     ,SC6->C6_TES     , Nil })
						AAdd( _aItemPV , { "C6_CF"      ,SC6->C6_CF	  , Nil })
					Endif

					AAdd( _aItemPV , { "C6_DESCRI"  ,SC6->C6_DESCRI  , Nil }) // Descricao
					AAdd( _aItemPV , { "C6_QTDLIB"  ,SC6->C6_QTDLIB  , Nil }) // Quantidade Liberada
					AAdd( _aItemPV , { "C6_PEDCLI"  ,SC6->C6_PEDCLI  , Nil })
					AAdd( _aItemPV , { "C6_I_BLPRC" ,SC6->C6_I_BLPRC , Nil })
					AAdd( _aItemPV , { "C6_I_VLIBP" ,SC6->C6_I_VLIBP , Nil }) // Preco Liberado
					AAdd( _aItemPV , { "C6_I_QPALT" ,_nqpallets      , Nil }) // Quantidade de Pallets

					AAdd( _aItemPV , { "C6_I_PTBRU" ,U_ALTERA:ITENS[_nI]:PESOBR , Nil })

					_nTotPesBr += U_ALTERA:ITENS[_nI]:PESOBR

					AAdd( _aItensPV ,_aItemPV )
				EndIf
			Next

			Aadd( _aCabPV, { "C5_PBRUTO"    ,_nTotPesBr  , Nil})
			Aadd( _aCabPV, { "C5_I_PESBR"   ,_nTotPesBr  , Nil})

			//Para executar o execauto precisa estar com C5_I_ENVRD = "N"

			Reclock("SC5",.F.)
			SC5->C5_I_ENVRD := "N"
			SC5->(Msunlock())

			//u_itconout(" Realizando alteração do pedido: "+AllTrim(U_ALTERA:PEDIDO)+"."+" - ENTROU NO MSExecAuto()")

			lMsErroAuto:=.F.

			//Inicializa controle de timeout do execauto em paralelo
			PutGlbValue("ALTERAP"+ALLTRIM(SC5->C5_NUM),"Alterando")
			lret := startjob("U_AOMS074U",getenvserver(),.F.,U_ITGETMV( 'IT_WEBTO' , 50 ),ThreadID(),"ALTERAP"+ALLTRIM(SC5->C5_NUM),ALLTRIM(SC5->C5_NUM))

			MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPV , _aItensPV , 4 )

			PutGlbValue("ALTERAP"+ALLTRIM(SC5->C5_NUM),"Completado")

			Reclock("SC5",.F.)
			SC5->C5_I_ENVRD := "S"
			SC5->(Msunlock())

			If lMsErroAuto
				_cNomeArqLog := "Pedido_"+AllTrim(U_ALTERA:PEDIDO)+"_"+DTos(Date())+"_"+StrTran(Time(),":","_")+".log"
				_cMsgErro := MostraErro("\system\", _cNomeArqLog)
				//u_itconout(" Erro na alteração do pedido de vendas: "+AllTrim(U_ALTERA:PEDIDO)+". "+_cMsgErro+" - SAIU NO MSExecAuto()")
				::U_STATUS := "SUCESSO:FALSE; Erro na alteração do pedido de vendas: "+AllTrim(U_ALTERA:PEDIDO)+". "+_cMsgErro
				DisarmTransaction()
				Break
			Else
				//u_itconout(" Alteração de pedidos de vendas realizada com sucesso: "+AllTrim(U_ALTERA:PEDIDO)+"."+" - SAIU NO MSExecAuto()")
				::U_STATUS := "SUCESSO:TRUE; Alteração de pedidos de vendas realizada com sucesso:"+AllTrim(U_ALTERA:PEDIDO)+"."
				//u_itconout(" Integra para o sistema RDC a situação do Pedido de Vendas alterado: "+AllTrim(SC5->C5_NUM)+".")
				U_ENVSITPV()
			EndIf

			//=====================================================================
			// Este trecho trata o desmembramento de pedidos de vendas.
			//=====================================================================
			_aItemPV := {}
			_ldesmem := .F.

			For _nI := 1 To Len(U_ALTERA:ITENS)

				If AllTrim(Upper(U_ALTERA:ITENS[_nI]:EXCLUI)) == "S"

					Loop

				Endif

				_cCodProd := SubStr(U_ALTERA:ITENS[_nI]:CODIGO,1,11)

				SB1->(Dbsetorder(1))
				SB1->(Dbgotop())
				SB1->(DbSeek(xFilial("SB1")+_cCodProd ))

				//======================================================================
				// Conversão de unidades de medida (RDC).
				// U_ALTERA:ITENS[_nI]:UNMED = 1 => Unidade
				// U_ALTERA:ITENS[_nI]:UNMED = 2 => Caixa
				// U_ALTERA:ITENS[_nI]:UNMED = 3 => Quilos
				//======================================================================


				If AllTrim(U_ALTERA:ITENS[_nI]:UNMED) == "1" // CX    //Verificação para produtos normais

					_cUM   := SB1->B1_UM
					_c2UM  := SB1->B1_SEGUM
					If SB1->B1_TIPCONV == "M"
						_nQtd  := U_ALTERA:ITENS[_nI]:QTDEPR / SB1->B1_CONV
						_cFator := AllTrim(Str(SB1->B1_CONV,18,6))
						_cTipoOper := " Multiplicação. "
					Else
						_nQtd  := U_ALTERA:ITENS[_nI]:QTDEPR * SB1->B1_CONV
						_cFator := AllTrim(Str(SB1->B1_CONV,18,6))
						_cTipoOper := " Divisão. "
					EndIf
					_n2Qtd := U_ALTERA:ITENS[_nI]:QTDEPR

				ElseIf AllTrim(U_ALTERA:ITENS[_nI]:UNMED) == "2"
					_cUM   := SB1->B1_UM
					_c2UM  := SB1->B1_SEGUM
					_nQtd  := U_ALTERA:ITENS[_nI]:QTDEPR
					If SB1->B1_TIPCONV == "M"
						_n2Qtd := U_ALTERA:ITENS[_nI]:QTDEPR * SB1->B1_CONV
						_cFator := AllTrim(Str(SB1->B1_CONV,18,6))
						_cTipoOper := " Multiplicação. "
					Else
						_n2Qtd := U_ALTERA:ITENS[_nI]:QTDEPR / SB1->B1_CONV
						_cFator := AllTrim(Str(SB1->B1_CONV,18,6))
						_cTipoOper := " Divisão. "
					EndIf

				ElseIf AllTrim(U_ALTERA:ITENS[_nI]:UNMED) == "3"
					_cUM   := SB1->B1_UM
					_c2UM  := SB1->B1_SEGUM
					_nQtd  := U_ALTERA:ITENS[_nI]:QTDEPR
					_n2Qtd := U_ALTERA:ITENS[_nI]:QTDPEC
					_cFator := AllTrim(Str(SB1->B1_CONV,18,6))
					_cTipoOper := " Controle de Peças. "
					//=====================================================================================
					// Calcular a quantidade de peças se a tag U_ALTERA:ITENS[_nI]:QTDPEC estiver vazia. 
					//=====================================================================================
                    If U_ALTERA:ITENS[_nI]:QTDPEC == 0 
                       If SB1->B1_CONV == 0  .And. SB1->B1_I_QQUEI == 'S' .And. SB1->B1_I_FATCO > 0
                          If SB1->B1_TIPCONV == "M"
						     _n2Qtd := U_ALTERA:ITENS[_nI]:QTDEPR * SB1->B1_I_FATCO 
					      Else
						     _n2Qtd := U_ALTERA:ITENS[_nI]:QTDEPR / SB1->B1_I_FATCO
					      EndIf
					   EndIf 
					EndIf 
				EndIf

				_cMsg := ""

				_cProdPe		:= U_ITGETMV( "IT_PRODPE" , "  ")	// Produtos permitidos que não validam quantidades fracinadas
				_cLocval		:= U_ITGETMV( "IT_LOCFRA" , "  ")	// Armazéns que não valida quantidade fracionada

				//==============================================================
				// Validar aqui as quantidade fracionadas 3 unidade de medida.
				//==============================================================
				_cCrtl3Um := POSICIONE("SBZ",1,SC5->C5_FILIAL+_cCodProd,"BZ_I_PR3UM")

				//u_itconout(" Posicione do SBZ PARA TRATAR BZ_I_PR3UM: "+AllTrim(SC5->C5_NUM)+" PROD " + _cCodProd + " " + _cCrtl3Um)
				
                _nQtd := Round( _nQtd, 2 ) 


				If _cCrtl3Um == "S"

                    If !Alltrim(SB1->B1_COD) $ _cProd3Dec					
					   If Mod(_nQtd , SB1->B1_I_QT3UM) <> 0
					   	  _cMsg += "6-O produto informado: " + _cCodProd + " - " + AllTrim(SB1->B1_DESC) + " - Item: " + strzero(U_ALTERA:ITENS[_nI]:ITEM,3) + " não pode ser vendido com quantidade fracionada. Verificar a Terceira Unidade de Medida [" + SB1->B1_I_3UM + "], pois não poderá haver quantidades fracionadas."
					   EndIf
					EndIf
				Else
					If !(AllTrim(_cCodProd) $ _cProdPe) .and. !(AllTrim(U_ALTERA:ITENS[_nI]:CODARM) $ _cLocval)//Verifica se deve validar quantidade fracionada
						If _n2Qtd - noround(_n2Qtd,0) <> 0
							_cMsg += "7-O produto informado: " + _cCodProd + " - " + AllTrim(SB1->B1_DESC) + " - Item: " + strzero(U_ALTERA:ITENS[_nI]:ITEM,3) + " não pode ser vendido com quantidade fracionada. Verificar a Segunda Unidade de Medida pois não poderá haver quantidades fracionadas."
						EndIf

						If _nQtd - noround(_nQtd,0) <> 0
							_cMsg += "8-O produto informado: " + _cCodProd + " - " + AllTrim(SB1->B1_DESC) + " - Item: " + strzero(U_ALTERA:ITENS[_nI]:ITEM,3) + " não pode ser vendido com quantidade fracionada. Verificar a Primeira Unidade de Medida pois não poderá haver quantidades fracionadas."
						EndIf
					Endif
				Endif

				cQuery := " SELECT R_E_C_N_O_ REC FROM " + Retsqlname("SC6") + " C6 "
				cQuery += " WHERE C6_FILIAL = '"+SC5->C5_FILIAL+"' "
				cQuery += " AND D_E_L_E_T_ = ' ' "
				cQuery += " AND C6_NUM = '"+SC5->C5_NUM+"' "
				cQuery += " AND C6_ITEM = '"+STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2)+"' "
				cQuery += " AND C6_PRODUTO = '"+substr(AllTrim(U_ALTERA:ITENS[_nI]:CODIGO),1,11)+"' "

				If select("SC6T") > 0
					SC6T->(DbCloseArea())
				EndIf

				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SC6T", .F., .T.)


				If !SC6T->(Eof())

					SC6->(Dbgoto(SC6T->REC))
					If _nQtd > SC6->C6_QTDVEN 
						_cMsg += "Quantidade da 1UM do produto: '"+AllTrim(U_ALTERA:ITENS[_nI]:CODIGO)+"' recebida (" + transform(_nQtd,"@E 999,999,999.9999")+"  maior que a quantidade atual! (" + transform(SC6->C6_QTDVEN,"@E 999,999,999.9999") + "), Pedido de Vendas: '"+Alltrim(U_ALTERA:PEDIDO)+"', Item: '"+StrZero(U_ALTERA:ITENS[_nI]:ITEM,2)+"'. "
						::U_STATUS := "SUCESSO:FALSE; " + _cMsg
						Disarmtransaction()
						Break
					EndIf

					If  _n2Qtd > SC6->C6_UNSVEN
						_cMsg += "Quantidade da 2UM do produto: '"+AllTrim(U_ALTERA:ITENS[_nI]:CODIGO)+"' recebida (" + transform(_n2Qtd,"@E 999,999,999.9999")+"  maior que a quantidade atual! (" + transform(SC6->C6_UNSVEN,"@E 999,999,999.9999") + "), Pedido de Vendas: '"+Alltrim(U_ALTERA:PEDIDO)+"', Item: '"+StrZero(U_ALTERA:ITENS[_nI]:ITEM,2)+"'. "
						::U_STATUS := "SUCESSO:FALSE; " + _cMsg
						Disarmtransaction()
						Break
					EndIf

				Else //Se não achar o SC6

					_cMsg += "Produto: '"+AllTrim(U_ALTERA:ITENS[_nI]:CODIGO)+"' não localizado no pedido! , Pedido de Vendas: '"+Alltrim(U_ALTERA:PEDIDO)+"', Item: '"+StrZero(U_ALTERA:ITENS[_nI]:ITEM,2)+"'. "
					::U_STATUS := "SUCESSO:FALSE; " + _cMsg
					Disarmtransaction()
					Break

				Endif

				SC6T->(DbCloseArea())

				If ! Empty(_cMsg)

					If AllTrim(U_ALTERA:ITENS[_nI]:UNMED) == "1"

						_cMsg += "Recebido como Segunda unidade de medida"

					Else

						_cMsg += "Recebido como Primeira unidade de medida"

					Endif

					_cMsg += " - Quantidade primeira unidade de medida: " + AllTrim(Str(Round(_nQtd, 2),18,6)) + " " + _cUM
					_cMsg += " - Quantidade segunda unidade de medida: " + AllTrim(Str(_n2Qtd,18,6)) + " " + _c2UM

					If _cCrtl3Um == "S"

						_cMsg += " - Produto usa Terceira unidade de medida: " + AllTrim(SB1->B1_I_3UM)
						_cMsg += " - Quantidade terceira unidade de medida:  " + AllTrim(Str((   _nQtd     / SB1->B1_I_QT3UM),18,6)) + " " + _cUM

					Endif

					_cMsg += " - Fator de Conversão: " + _cFator
					_cMsg += " - Tipo de Conversão: " + _cTipoOper
					::U_STATUS := "SUCESSO:FALSE; " + _cMsg
					Disarmtransaction()
					Break
				EndIf

				//Analisa se é desmembramento, se não for, inclui com a quantidade atual do item para não mexer

				If U_ALTERA:ITENS[_nI]:DESMEM == "S"

					Aadd(_aItemPV,{STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2), _nQtd})
					_ldesmem := .T.

				Else

					Aadd(_aItemPV,{STRZERO(U_ALTERA:ITENS[_nI]:ITEM,2), SC6->C6_QTDVEN})

				Endif

			Next

			If _ldesmem

				//u_itconout(" Realizando desmembramento do pedido: "+AllTrim(U_ALTERA:PEDIDO)+"."+" - "+DTOC(DATE())+" - "+TIME())

				//Para executar o execauto precisa estar com C5_I_ENVRD = "N"

				Reclock("SC5",.F.)
				SC5->C5_I_ENVRD := "N"
				SC5->(Msunlock())
				_npedori := SC5->(Recno())

				//Inicializa controle de timeout do execauto em paralelo
				_cNome := "ALTERAPD"+ALLTRIM(SC5->C5_NUM)
				PutGlbValue(_cNome,"Alterando")
				lret := startjob("U_AOMS074U",getenvserver(),.F.,U_ITGETMV( 'IT_WEBTD' , 90 ),ThreadID(),_cNome,ALLTRIM(SC5->C5_NUM))

				_aRet := U_AOMS098(_cFilial,U_ALTERA:PEDIDO,_aItemPV, _cCodUsuario ) //Função que realiza desmembramento de pedido de vendas


				PutGlbValue(_cNome,"Completado")


				_npednovo := SC5->(Recno())

				SC5->(Dbgoto(_npedori))

				Reclock("SC5",.F.)
				SC5->C5_I_ENVRD := "S"
				SC5->(Msunlock())

				SC5->(Dbgoto(_npednovo))

				If _aRet[1] // Sucesso no desmembramento do pedido de vendas.
					//Atualiza pedido desmembrado para C5_I_ENVRD = 'R' com data retroativa para que o schedule crie a tabela de muro e mande para o RDC
					SC5->(Dbsetorder(1))
					If SC5->(Dbseek(_cFilial+AllTrim(_aRet[2])))

						Reclock("SC5", .F.)
						SC5->C5_I_ENVRD := "R"
						SC5->C5_I_DTRET := DATE() - 1
						SC5->C5_I_HRRET := TIME()
						SC5->(Msunlock())

						//u_itconout("  Pedido de vendas original: "+AllTrim(U_ALTERA:PEDIDO)+". Novo Pedido de vendas: "+AllTrim(_aRet[2])+". "+_aRet[3]+" - "+DTOC(DATE())+" - "+TIME())
						::U_STATUS := "SUCESSO:TRUE; Pedido de vendas original: "+AllTrim(U_ALTERA:PEDIDO) + ". Novo Pedido de vendas: " + AllTrim(_aRet[2])+". "+_aRet[3]

					Else

						//u_itconout(" Não foi possível marcar novo pedido de vendas para integração com RDC -  Pedido de vendas original: "+AllTrim(U_ALTERA:PEDIDO)+". Novo Pedido de vendas: "+AllTrim(_aRet[2])+". "+_aRet[3]+" - "+DTOC(DATE())+" - "+TIME())
						::U_STATUS := "SUCESSO:False; - Não foi possível marcar novo pedido de vendas para integração com RDC - Pedido de vendas original: "+AllTrim(U_ALTERA:PEDIDO) + ". Novo Pedido de vendas: " + AllTrim(_aRet[2])+". "+_aRet[3]

					Endif

				Else // Falha o Desmembramento do pedido de vendas.

					//u_itconout(" Falha na geração de pedido desemembrado do pedido de vendas numero: "+AllTrim(U_ALTERA:PEDIDO) + ". " + _aRet[3]+" - "+DTOC(DATE())+" - "+TIME())
					::U_STATUS := "SUCESSO:FALSE; Falha na geração de pedido desemembrado do pedido de vendas numero: "+AllTrim(U_ALTERA:PEDIDO) + ". " + _aRet[3]
					Disarmtransaction()
					Break

				EndIf

			Endif

		END TRANSACTION

	End Sequence


	If _ltemlib

		//u_itconout(" Refazendo liberação de estoque do pedido de vendas numero: "+AllTrim(U_ALTERA:PEDIDO) + ". "+" - "+DTOC(DATE())+" - "+TIME())

		SC6->(Dbsetorder(1))
		If SC6->(Dbseek(_cfilial+AllTrim(U_ALTERA:PEDIDO)))

			Do while SC6->C6_FILIAL == _cfilial .and. ALLTRIM(SC6->C6_NUM) == AllTrim(U_ALTERA:PEDIDO)

				SC9->(Dbsetorder(1))
				If !( SC9->(Dbseek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM) ) )

					_nQtdLib := MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN)//LIBERA PEDIDO

				Endif

				SC6->(Dbskip())

			Enddo

			U_ENVSITPV()

		Endif

	Endif

//===================================================================== 
//Desfaz todos os locks de cabeçalho
//===================================================================== 
	SC5->(Msunlock())
	SC5->(Msunlockall())
	SA1->(Msunlock())
	SA1->(Msunlockall())

	RestOrd(_aOrd)

//Garante que vai liberar lock de todos os cabeçalhos e todos os itens
	SC5->(Dbsetorder(1))

	If SC5->(DbSeek(_cFilial+PadR(U_ALTERA:PEDIDO,_nTamPedido," ")))

		SC5->(Msunlock())
		SC5->(Msunlockall())

		ZFQ->(Dbsetorder(3))
		If ZFQ->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))

			Do while ZFQ->ZFQ_FILIAL == SC5->C5_FILIAL .AND. ZFQ->ZFQ_PEDIDO == SC5->C5_NUM

				ZFQ->(MSUNLOCKALL())
				ZFQ->(Msunlock())

				ZFQ->(Dbskip())

			Enddo

		Endif

		ZFR->(Dbsetorder(3))
		If ZFR->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))

			Do while ZFR->ZFR_FILIAL == SC5->C5_FILIAL .AND. ZFR->ZFR_NUMPED == SC5->C5_NUM

				ZFR->(MSUNLOCKALL())
				ZFR->(Msunlock())

				ZFR->(Dbskip())

			Enddo

		Endif


		SA1->(Dbsetorder(1))
		If SA1->(Dbseek(xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))

			SA1->(Msunlock())
			SA1->(Msunlockall())

		Endif

		SC6->(Dbsetorder(1))
		If SC6->(Dbseek(_cFilial+PadR(U_ALTERA:PEDIDO,_nTamPedido," ")))

			Do while SC6->C6_FILIAL == SC5->C5_FILIAL .AND. SC6->C6_NUM == SC5->C5_NUM

				SC6->(Msunlock())
				SC6->(Msunlockall())

				SB2->(Dbsetorder(1))
				If SB2->(Dbseek(SC6->C6_FILIAL+SC6->C6_PRODUTO+SC6->C6_LOCAL))

					SB2->(Msunlock())
					SB2->(Msunlockall())

				Endif

				SC6->(Dbskip())

			Enddo

		Endif

	Endif

	//U_ITCONOUT(" FIM da alteração do pedido: "+AllTrim(U_ALTERA:PEDIDO))

Return _lRet

WSMETHOD U_INCLUIO WSRECEIVE U_OCORRE WSSEND U_STATUS WSSERVICE U_AOMS074
	Local _lRet := .T.
	Local _aOrd := SaveOrd({"SF2","ZF5","ZFC"})
	Local _aFiliais, _nI // _aFiliais := FWLoadSM0()
	Local _nTamDocOc, _nTamSerOc, _nTamCodigo, _nTamFilial
	Local _cFilialEmp, _cChaveSF2, _cChaveZF5
	Local _cret, _cret3, _cret4//_cret2,
	Local _lAlterZF5
	Local _cCodEmpWS := U_ITGETMV( 'IT_EMPWEBSE' , '000001' )
	Local _cFinOcoFt := U_ITGETMV( 'IT_FINOCFRE' , '001' ) // Codigo de Ocorrencia enviado RDC, que encerra a ocorrência de frete.
	Local _lAprovado := .T.
	Local _cTipoOcor, _cCodOcorr, _cSeqOcorr, _cSeqZF5
	Local _cStatusOc := "000001"  // Status de encerramento da ocorrência de frete.
    Local _cDtTran//, _lObsSF2 := .F.

	Begin Sequence
		//=====================================================================
		// Limpa o ambiente, liberando a licença e fechando as conexões
		//=====================================================================
		RpcClearEnv()
		RpcSetType(2)

		//===========================================================================================
		// Preparando o ambiente com a filial da carga recebida
		//===========================================================================================
		//PREPARE ENVIRONMENT EMPRESA '01' FILIAL "01";
			//        TABLES "SF2","ZF5","SB1","ZFC","ZFO","SA2","SB5","SC5","SC6","SA1";
			//        MODULO 'OMS'
		RpcSetEnv("01", "01",,,,, {"SF2","ZF5","SB1","ZFC","ZFO","SA2","SB5","SC5","SC6","SA1"})

		_aFiliais := FWLoadSM0()
		::U_STATUS := ""
		_cTipoOcor := ""

		_nTamDocOc  := TAMSX3("F2_DOC")[1]
		_nTamSerOc  := TAMSX3("F2_SERIE")[1]
		_nTamCodigo := TAMSX3("ZF5_CODIGO")[1]
		_nTamFilial := TAMSX3("ZF5_FILIAL")[1]
		_cSeqOcorr  := Right("0000000"+AllTrim(U_OCORRE:CODIGO),_nTamCodigo)//#SEQUENCIAL DO RDC

		_nI := Ascan(_aFiliais,{|x| x[18] == AllTrim(U_OCORRE:CNPJEM)}) // CNPJ DA FILIAL
		If _nI == 0
			::U_STATUS := "SUCESSO:FALSE; CNPJ: "+AllTrim(U_OCORRE:CNPJEM)+" informado para filial não existe. Nota fiscal: " + U_OCORRE:NOTA+"-"+U_OCORRE:SERIE+"."
			_lAprovado := .F.
			Break
		EndIf
		_cFilialEmp := _aFiliais[_nI,5]

		//=====================================================================
		// Limpa o ambiente, liberando a licença e fechando as conexões
		//=====================================================================
		RpcClearEnv()
		RpcSetType(2)

		//===========================================================================================
		// Preparando o ambiente com a filial da carga recebida
		//===========================================================================================
		//PREPARE ENVIRONMENT EMPRESA '01' FILIAL _cFilialEmp;
			//        TABLES "SF2","ZF5","SB1","ZFC","ZFO","SA2","SB5","SC5","SC6","SA1";
			//        MODULO 'OMS'
		RpcSetEnv("01", "01",,,,, {"SF2","ZF5","SB1","ZFC","ZFO","SA2","SB5","SC5","SC6","SA1"})

		_cChaveSF2 := PadR(_cFilialEmp,_nTamFilial," ")+StrZero(Val(AllTrim(U_OCORRE:NOTA)),_nTamDocOc)+PadR(U_OCORRE:SERIE,_nTamSerOc," ")
		_cMostCSF2 := _cFilialEmp+" "+StrZero(Val(AllTrim(U_OCORRE:NOTA)),_nTamDocOc)+"-"+ALLTRIM(U_OCORRE:SERIE)
		_cChaveZF5 := PadR(_cFilialEmp,_nTamFilial," ")+StrZero(Val(AllTrim(U_OCORRE:NOTA)),_nTamDocOc)+PadR(U_OCORRE:SERIE,_nTamSerOc," ")+_cSeqOcorr

		_cSeqZF5 := U_AOMS074Y(PadR(_cFilialEmp,_nTamFilial," "),StrZero(Val(AllTrim(U_OCORRE:NOTA)),_nTamDocOc),PadR(U_OCORRE:SERIE,_nTamSerOc," "))
		_cSeqZF5 := StrZero(Val(AllTrim(_cSeqZF5)) + 1, 6)  //#SEQUENCIAL DO PROTHEUS

		SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		If !SF2->(DbSeek(_cChaveSF2))
			::U_STATUS := "SUCESSO:FALSE; Erro na Inclusao da ocorrencia de frete via RDC. Nota Fiscal nao localizada: " + _cMostCSF2+"."
			_lAprovado := .F.
			Break
		EndIf

        //QUANDO RECEBER A OCORRÊNCIA E A NFE FOR DE TRANSFERÊNCIA, REFERENTE A TROCA NOTA, ALTERAR OS DADOS PARA NFE DE FATURAMENTO
        IF (POSICIONE("SC5",,SF2->F2_FILIAL+SF2->F2_DOC,"C5_I_TRCNF","IT_NOTA") = "S") .AND. SC5->C5_I_OPER = "20"
           _cSeekPV   := SC5->C5_I_FILFT+SC5->C5_I_PDFT
           _cNotaFat  := POSICIONE("SC5",1,_cSeekPV,"C5_NOTA")//POSICIONADO NO SC5 DA NOTA DE FATURAMENTO
           _cChaveSF2 := SC5->C5_FILIAL+_cNotaFat+SC5->C5_SERIE
		   _cFilialEmp:= SC5->C5_FILIAL
		   _cMostCSF2 := "NF Fat.: "+SC5->C5_FILIAL+" "+_cNotaFat+"-"+ALLTRIM(SC5->C5_SERIE)
		   _cChaveZF5 := _cChaveSF2+_cSeqOcorr
	   	   _cSeqZF5   := U_AOMS074Y(_cFilialEmp,_cNotaFat,SC5->C5_SERIE)
		   _cSeqZF5   := StrZero(Val(AllTrim(_cSeqZF5)) + 1, 6)  //#SEQUENCIAL DO PROTHEUS
		EndIf

		cFilAnt := _cFilialEmp
		SM0->(dbSeek(xFilial('SM0')+_cFilialEmp))

		If !SF2->(DbSeek(_cChaveSF2))
		   ::U_STATUS := "SUCESSO:FALSE; Erro na Inclusao da ocorrencia de frete via RDC. Nota Fiscal de Faturamento nao localizada: " + _cMostCSF2+"."
		   _lAprovado := .F.
		   Break
		EndIf

        //==================================================================================
		// Verifica se esta ocorrência já existe na tabela ZF5. Não é permitido Alterações.
		//==================================================================================
        _lAlterZF5 := .F.//NÃO USA
		ZF5->(DbSetOrder(5)) // ZF5_FILIAL+ZF5_DOCOC+ZF5_SEROC+ZF5_CODRDC // procura ocorecia do RDC
		If ZF5->(DbSeek(_cChaveZF5))
			//====================================================================================================
			// Já existe registro cadastrado para esta ocorrência. Bloqueia alteração.
			//====================================================================================================
			::U_STATUS := "SUCESSO:FALSE; Erro na Alteracao da ocorrencia de frete via RDC. Alterações não permitidas: " + _cMostCSF2+"."
			_lAprovado := .F.
			Break
		EndIf


        //===========================================================
        // Verifica se o código da ocorrência existe no Protheus. 
        // Se não existir, inclui a nova ocorrencia na tabale ZFC.
        //===========================================================
        ZFC->(DbSetOrder(1))
        _cTipoOcor := ""
        _cCodOcorr := Right("0000000"+AllTrim(U_OCORRE:OCORR),6)
        _cDtTran   :=" "  
        _cTipoCusto:=" "

        If ZFC->(DbSeek(xFilial("ZFC")+_cCodOcorr))    
           _cDtTran    := ZFC->ZFC_DTTRAN 
           _cTipoCusto := ZFC->ZFC_CUSTO
        EndIf

        //===========================================================
        // Valida a data da Ocorrência de frete.
        //===========================================================
        If !Empty(U_OCORRE:DATAO) .And. CTod(U_OCORRE:DATAO) > Date() .And. !_cDtTran $ "A,B,C,D,E,F" 
           ::U_STATUS := "SUCESSO:FALSE; A data da ocorrência de frete "+U_OCORRE:DATAO +", não pode ser maior que a data atual: " + DTOC(DATE()) + "."
           _lAprovado := .F.
           Break
        EndIf 
        
		If !Empty(U_OCORRE:DATAO) .And. CTod(U_OCORRE:DATAO) <  SF2->F2_EMISSAO .And. !_cDtTran $ "A,B,C,D,E,F"
           ::U_STATUS := "SUCESSO:FALSE; A data da ocorrência de frete "+U_OCORRE:DATAO +", não pode ser menor que a data emissão da NF: " + DTOC(SF2->F2_EMISSAO) + "."
           _lAprovado := .F.
           Break
        EndIf 

        If !ZFC->(DbSeek(xFilial("ZFC")+_cCodOcorr))    
           ZFC->(RecLock("ZFC",.T.))
           ZFC->ZFC_CODIGO := _cCodOcorr // Right("0000000"+AllTrim(U_OCORRE:OCORR),6)
           ZFC->ZFC_DESC   := "Novo Codigo de Tipo de Ocorrência de Frete."
           ZFC->(MsUnlock())
           _cTipoOcor := " Novo Codigo de Tipo de Ocorrência de Frete. Verifique o cadastro. [" + _cCodOcorr + "]."
        EndIf

        //****************************************************************************************************************************************************
        // TRECHO DA GRAVACAO DAS DATAS: FOI TUDO PARA A FUNÇÃO U_AOMS3DTSF2("AOMS074",_aREcZF5)//FUNÇÃO ESTA NO AOMS003.PRW
        //****************************************************************************************************************************************************

		//====================================================================================================
		// Ainda não existe registro cadastrado para esta ocorrência. Realiza apenas uma Inclusão.
		//====================================================================================================
		ZF5->(RecLock("ZF5",.T.))

		If Right("0000000"+AllTrim(U_OCORRE:OCORR),6) $ _cFinOcoFt // Se ocorrência de frete estiver no parâmetro com os códigos que encerram a ocorrência.
			_cStatusOc := "000001"  // Status de encerramento da ocorrência de frete.
		Else
			_cStatusOc := "000006"  // Pendente.
		EndIf

		//====================================================================================================
		// Este trecho de atribuição de dados serve tanto para inclusão, como para alteração.
		//====================================================================================================
		ZF5->ZF5_FILIAL := _cFilialEmp
		ZF5->ZF5_DOCOC  := SF2->F2_DOC   //StrZero(Val(AllTrim(U_OCORRE:NOTA)),_nTamDocOc) // U_OCORRE:NOTA // Numero da nota fiscal
		ZF5->ZF5_SEROC  := SF2->F2_SERIE //U_OCORRE:SERIE   // Serie da nota fiscal
		ZF5->ZF5_CODIGO := _cSeqZF5      //#SEQUENCIAL DO PROTHEUS
		ZF5->ZF5_CODRDC := _cSeqOcorr    //#SEQUENCIAL DO RDC
		ZF5->ZF5_STATUS := _cStatusOc    // '000006'
		ZF5->ZF5_TIPOO  := Right("0000000"+AllTrim(U_OCORRE:OCORR),6)
		ZF5->ZF5_STATC  := "P"
		ZF5->ZF5_MOTIVO := POSICIONE("ZFC",1,xfilial("ZFC")+ZF5->ZF5_TIPOO,"ZFC->ZFC_DESC")
		
		//If ! _lObsSF2
		//   ZF5->ZF5_MOTCUS := "Datas: Entrega Cliente/Operador Logístico não atualizadas, na nota fiscal. " + AllTrim(U_OCORRE:OBSERV) // Motivo Ocorr // Tabela("ZW",U_OCORRE:OBSERV,.F.)
		//Else 
		   ZF5->ZF5_MOTCUS := AllTrim(U_OCORRE:OBSERV) // Motivo Ocorr // Tabela("ZW",U_OCORRE:OBSERV,.F.)
		//EndIf 

		ZF5->ZF5_DATAC  := CTOD(U_OCORRE:DATAC)
		ZF5->ZF5_HORAC  := U_OCORRE:HORAC
		ZF5->ZF5_DTFIN  := CTOD(U_OCORRE:DATAT)
		ZF5->ZF5_HRFIN  := U_OCORRE:HORAT
		ZF5->ZF5_DATAS  := CTOD(U_OCORRE:DATAS)
		ZF5->ZF5_HORAS  := U_OCORRE:HORAS
		ZF5->ZF5_DTOCOR := CTOD(U_OCORRE:DATAO)
 /*
      //If U_OCORRE:CNPJEM == U_OCORRE:CNPJDEV    // Se for igual ao campo CNPJEM a italac está emitindo preencher o campo ZF5_ORIDEV com I senao preencher com C
      //   ZF5->ZF5_ORIDEV := "I"
      //Else
      //   ZF5->ZF5_ORIDEV := "C"
      //EndIf
*/
		ZF5->ZF5_ORIDEV := ""

		If empty(U_OCORRE:CNPJDEV)
			ZF5->ZF5_DEVOL := 'N'
		Else
			ZF5->ZF5_DEVOL := 'S'
		Endif

		ZF5->ZF5_DOCDEV := "" // U_OCORRE:NOTADEV
		ZF5->ZF5_SERDEV := "" // U_OCORRE:SERIEDEV
		ZF5->ZF5_NDEBIT := "N"
		ZF5->ZF5_GERDEV := "N"

		ZF5->ZF5_CUSTO  := U_OCORRE:VALOR

		If ZF5->ZF5_CUSTO > 0
		   ZF5->ZF5_TIPOC := _cTipoCusto //"R" , Troquei pq se tiver diferente do cadastro ele valida na alteracao.
		Endif

		If _lAlterZF5//NÃO ENTRA MAIS AQUI
			ZF5->(MsUnlock())
			::U_STATUS := "SUCESSO:TRUE; Alteracao de Ocorrencia de Frete via RDC realizada com sucesso: " + _cMostCSF2+"."
			Break // Encerra a alteração e vai para a primeira linha após o comando End Sequence
		EndIf

		DAK->(DbSetOrder(1)) // DAK_FILIAL+DAK_COD+DAK_SEQCAR
		DAI->(DbSetOrder(4)) // DAI_FILIAL+DAI_PEDIDO+DAI_COD+DAI_SEQCAR

		//====================================================================================================
		// Este trecho de atribuição de dados serve apenas para inclusão de dados. Lê os dados da nota fiscal,
		// tabela SF2 e grava na tabela ZF5.
		//====================================================================================================
		ZF5->ZF5_FILIAL := _cFilialEmp
		ZF5->ZF5_DOCOC	:= SF2->F2_DOC
		ZF5->ZF5_SEROC  := SF2->F2_SERIE
		ZF5->ZF5_CARGA  := SF2->F2_CARGA
		ZF5->ZF5_SEQCAR := SF2->F2_SEQCAR
		ZF5->ZF5_DTINI  := DATE()
		ZF5->ZF5_HRINI  := TIME()

		ZF5->ZF5_DATAE  := Posicione("SC5",1,_cFilialEmp+SF2->F2_I_PEDID,"C5_I_DTENT")

		If DAI->(MsSeek(_cFilialEmp+SF2->F2_I_PEDID))

			DAK->(MsSeek(_cFilialEmp+DAI->DAI_COD))

			//If ! Empty(SF2->F2_CARGA)
			//   ZF5->ZF5_MOTORI := Posicione("DAK",1,xFilial("ZF5")+SF2->F2_CARGA,"DAK_MOTORI")
			//EndIf
			ZF5->ZF5_MOTORI := DAK->DAK_MOTORI

			If ! Empty(SF2->F2_CARGA)
				//_cret := Substr(alltrim(POSICIONE("DA4",1,XFILIAL("DA4")+POSICIONE("DAK",1,XFILIAL("ZF5")+ALLTRIM(SF2->F2_CARGA),"DAK_MOTORI") ,"DA4_NOME")),1,30)
				_cret := Substr(alltrim(POSICIONE("DA4",1,XFILIAL("DA4")+DAK->DAK_MOTORI,"DA4_NOME")),1,30)

				//_cret3 := ALLTRIM(POSICIONE("DA4",1,XFILIAL("DA4")+POSICIONE("DAK",1,XFILIAL("ZF5")+ALLTRIM(SF2->F2_CARGA),"DAK_MOTORI") ,"DA4_TEL"))
				_cret3 := ALLTRIM(POSICIONE("DA4",1,XFILIAL("DA4")+DAK->DAK_MOTORI ,"DA4_TEL"))

				If Val(_cret3) > 0
					If Len(_cret3) == 11
						_cret += " - " + Transform(Val(_cret3),"@R (99) 99999-9999")
					ElseIf len(_cret3) == 10
						_cret += " - " + Transform(Val(_cret3),"@R (99) 9999-9999")
					EndIf
				EndIf
				ZF5->ZF5_DMOTOR := _cret

				//ZF5->ZF5_VEICUL := Posicione("DAK",1,xFilial("ZF5")+AllTrim(SF2->F2_CARGA),"DAK_CAMINH")
				ZF5->ZF5_VEICUL := DAK->DAK_CAMINH

				//_cret3 := Posicione("DAK",1,xFilial("ZF5")+SF2->F2_CARGA,"DAK_CAMINH")
				//ZF5->ZF5_DVEICU := Posicione("DA3",1,xFilial("DA3")+alltrim(_cret3),"DA3_DESC")
				ZF5->ZF5_DVEICU := Posicione("DA3",1,xFilial("DA3")+DAK->DAK_CAMINH,"DA3_DESC")

				//_cret3 := Posicione("DAK",1,xFilial("ZF5")+AllTrim(SF2->F2_CARGA),"DAK_CAMINH")
				//ZF5->ZF5_PLACA := Posicione("DA3",1,xFilial("DA3")+AllTrim(_cret3),"DA3_PLACA")
				ZF5->ZF5_PLACA := Posicione("DA3",1,xFilial("DA3")+DAK->DAK_CAMINH,"DA3_PLACA")

				ZF5->ZF5_DTCAR := DAK->DAK_DATA  // Posicione("DAK",1,xFilial("ZF5")+AllTrim(SF2->F2_CARGA),"DAK_DATA")
				ZF5->ZF5_PESO  := DAK->DAK_PESO  // Posicione("DAK",1,xFilial("ZF5")+SF2->F2_CARGA,"DAK_PESO")
			EndIf
		EndIf

		If ! Empty(SF2->F2_VEND1)
			ZF5->ZF5_REPRES := SF2->F2_VEND1

			_cret := Substr(alltrim(POSICIONE("SA3",1,XFILIAL("SA3")+SF2->F2_VEND1,"A3_NOME")),1,30)
			_cret3 := ALLTRIM(POSICIONE("SA3",1,XFILIAL("SA3")+SF2->F2_VEND1,"A3_TEL"))
			_cret4 := ALLTRIM(POSICIONE("SA3",1,XFILIAL("SA3")+SF2->F2_VEND1,"A3_DDDTEL"))

			If Val(_cret3) > 0
				If Len(_cret3) == 9
					_cret += " - (" + _cret4 + ") " + Transform(Val(_cret3),"@R  99999-9999")
				ElseIf Len(_cret3) == 8
					_cret += " - (" + _cret4 + ") " + Transform(Val(_cret3),"@R  9999-9999")
				EndIf
			EndIf

			ZF5->ZF5_NREPRE := _cret
		EndIf

		If ! Empty(SF2->F2_VEND2)
			ZF5->ZF5_COORD := SF2->F2_VEND2

			_cret := Substr(Alltrim(Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND2,"A3_NOME")),1,30)
			_cret3 := Alltrim(Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND2,"A3_TEL"))
			_cret4 := Alltrim(Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND2,"A3_DDDTEL"))

			If Val(_cret3) > 0
				If Len(_cret3) == 9
					_cret += " - (" + _cret4 + ") " + Transform(Val(_cret3),"@R  99999-9999")
				ElseIf Len(_cret3) == 8
					_cret += " - (" + _cret4 + ") " + Transform(Val(_cret3),"@R  9999-9999")
				EndIf
			EndIf
			ZF5->ZF5_NCOOR := _cret
		EndIf

		If ! Empty(SF2->F2_CLIENTE)
			ZF5->ZF5_CLIENT := SF2->F2_CLIENTE

			If ! Empty(SF2->F2_LOJA)
				ZF5->ZF5_LOJA := SF2->F2_LOJA
			EndIf

			_cret := Substr(Alltrim(Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NREDUZ")),1,30)
			_cret3 := AllTrim(Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_TEL"))
			_cret4 := AllTrim(Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_DDD"))

			If Len(AllTrim(_cret3)) > 0 //Val(_cret3) > 0
				If Len(_cret3) == 9
					_cret += " - (" + _cret4 + ") " + Transform(Val(_cret3),"@R  99999-9999")
				ElseIf Len(_cret3) == 8
					_cret += " - (" + _cret4 + ") " + Transform(Val(_cret3),"@R  9999-9999")
				EndIf
			EndIf

			ZF5->ZF5_NCLIEN := _cret
		EndIf

		If ! Empty(SF2->F2_EST)
			ZF5->ZF5_UF := SF2->F2_EST
		EndIf

		If ! Empty(SF2->F2_CLIENTE)
			ZF5->ZF5_CIDADE := Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_MUN")
		EndIf

        If Empty(SF2->F2_CARGA) //SE TIVER CARGA PEGA DA CARGA SENÃO DO SF2
	       ZF5->ZF5_TRANSP := SF2->F2_I_CTRA
	       ZF5->ZF5_LJTRAN := SF2->F2_I_LTRA
	       ZF5->ZF5_NTRANS := SF2->F2_I_NTRAN
        Else
	       DA4->(Dbsetorder(1))         
           IF DA4->(Dbseek(xFilial("DA4")+DAK->DAK_MOTORI))  
              ZF5->ZF5_TRANSP := DA4->DA4_FORNEC
              ZF5->ZF5_LJTRAN := DA4->DA4_LOJA
              ZF5->ZF5_NTRANS := Posicione("SA2",1,xFilial("SA2")+DA4->DA4_FORNEC+DA4->DA4_LOJA,"A2_NOME")
		   ENDIF
        EndIf

		If ! Empty(SF2->F2_PBRUTO)
			ZF5->ZF5_PESON := SF2->F2_PBRUTO
		EndIf

		If ! Empty(SF2->F2_VOLUME1)
			_cret := AllTrim(Transform(SF2->F2_VOLUME1,"@E 999,999"))
			_cret += "  " + AllTrim(SF2->F2_ESPECI1)
			ZF5->ZF5_VOLUM := _cret
		EndIf

		If ! Empty(SF2->F2_CARGA)
			_cret3 := Posicione("DAK",1,xFilial("ZF5")+SF2->F2_CARGA,"DAK_CAMINH")
			ZF5->ZF5_TIPOV := Posicione("DA3",1,xFilial("DA3")+Alltrim(_cret3),"DA3_I_TPVC")
		EndIf

		If ! Empty(SF2->F2_I_FRET)
			ZF5->ZF5_VLRFRE := SF2->F2_I_FRET
		EndIf

		If ! Empty(SF2->F2_I_PEDID)
			ZF5->ZF5_PEDIDO := 	SF2->F2_I_PEDID
		EndIf

		SC5->(DbSetOrder(1))
		SC5->(DbSeek(SF2->F2_FILIAL+SF2->F2_I_PEDID))
		ZF5->ZF5_AGENDA:= AllTrim(SC5->C5_MENNOTA)
		ZF5->ZF5_RPCOM := SubStr(Embaralha(SC5->C5_USERLGI,1),3,6)
		ZF5->ZF5_NRPCO := FWLeUserlg("SC5->C5_USERLGI")
        
		IF _cDtTran $ "A,B,C,D,E,F" .And. (ZF5->ZF5_DTOCOR < SF2->F2_EMISSAO .OR. (ZF5->ZF5_DTOCOR > DATE() .And. _cDtTran <> "F"))
           ZF5->ZF5_ESTONO:="S"
        EndIf

		ZF5->(MsUnlock())//**************** FIM DA GRACAO NO ZF5010 *****************************

        _nRecZF5:=ZF5->(RECNO())
        _nRecSF2:=SF2->(RECNO())
		_aREcZF5:={}
		ZF5->(dbSetOrder(1))
		If ZF5->(dbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE))
		   DO WHILE ZF5->(!EOF()) .AND. SF2->F2_FILIAL == ZF5->ZF5_FILIAL;
		                          .AND. SF2->F2_DOC    == ZF5->ZF5_DOCOC;
		   					      .AND. SF2->F2_SERIE  == ZF5->ZF5_SEROC
              AADD(_aREcZF5,ZF5->(RECNO()) )
              ZF5->(DBSKIP())
           ENDDO  
		EndIf

        IF LEN(_aREcZF5) > 0
           U_AOMS3DTSF2("AOMS074",_aREcZF5)//FUNÇÃO CHAMADA NO AOMS003/72 TB E ESTA NO AOMS003.PRW
           SF2->(DBGOTO(_nRecSF2))
		ELSE
           SF2->(DBGOTO(_nRecSF2))
		ENDIF
        ZF5->(DBGOTO(_nRecZF5))

		::U_STATUS := "SUCESSO:TRUE; Inclusao de Ocorrencia de Frete via RDC realizada com sucesso: " +_cMostCSF2+"."// U_OCORRE:NOTA+"-"+U_OCORRE:SERIE

		//====================================================================================================
		// Envia e-mail da integração de ocorrencias de frete.
		//====================================================================================================
		//U_AOMS074M() // Mater o envio de e-mails desativado por enquanto.
/*
//-----------------------------------------------------
	    ZFC->(DbSetOrder(1))
	    _cTipoOcor := ""

	    _cCodOcorr := Right("0000000"+AllTrim(U_OCORRE:OCORR),6)

        _cDtTran := "N"  

        If ! ZFC->(DbSeek(xFilial("ZFC")+_cCodOcorr))    
           ZFC->(RecLock("ZFC",.T.))
           ZFC->ZFC_CODIGO := _cCodOcorr // Right("0000000"+AllTrim(U_OCORRE:OCORR),6)
           ZFC->ZFC_DESC   := "Novo Codigo de Tipo de Ocorrência de Frete."
           ZFC->(MsUnlock())
   
           _cTipoOcor := " Novo Codigo de Tipo de Ocorrência de Frete. Verifique o cadastro. [" + _cCodOcorr + "]."
        Else 
           _cDtTran := ZFC->ZFC_DTTRAN  
        EndIf

        //If _cDtTran == "S"  
        If _cDtTran <> "N"  .And. _cDtTran <> " "  
           SF2->(RecLock("SF2",.F.))
   
           If _cDtTran ==  'C' .And. Empty(SF2->F2_I_DENCL)
              // SF2->F2_I_DTRAN := ZF5->ZF5_DTOCOR // _dDtOcorr
	          SF2->F2_I_DENCL := ZF5->ZF5_DTOCOR
           ElseIf _cDtTran ==  'O' .And. Empty(SF2->F2_I_DENOL) 
              SF2->F2_I_DENOL := ZF5->ZF5_DTOCOR 
           EndIf 
	   
           SF2->(MsUnLock())
        EndIf 
//-----------------------------------------------------------------
*/
    End Sequence

	ZFO->(RecLock("ZFO",.T.))
	ZFO->ZFO_FILIAL  := _cFilialEmp // xFilial("ZFO")           //	Filial do Sistema
	ZFO->ZFO_DATA	 := Date()                   //	Data de Emissão
	ZFO->ZFO_HORA    := Time()  // grava a hora de inclusão na tabela de muro.
	ZFO->ZFO_CNPJEM  := U_OCORRE:CNPJEM          //	CNPJ do Embarcador
	ZFO->ZFO_NOTA	 := StrZero(Val(AllTrim(U_OCORRE:NOTA)),_nTamDocOc) // U_OCORRE:NOTA            //	Número da Nota Fiscal
	ZFO->ZFO_SERIE	 := U_OCORRE:SERIE           //	Série da Nota Fiscal
	ZFO->ZFO_CODIGO  := _cSeqZF5 //U_OCORRE:CODIG// Codigo da Ocorrência Sequencial Protheus
	ZFO->ZFO_CODRDC  := U_OCORRE:CODIGO          // Codigo da Ocorrência RDC
	ZFO->ZFO_OCORR	 := U_OCORRE:OCORR           //	Tipo de Ocorrência na entrega
	ZFO->ZFO_DATAO	 := CTOD(U_OCORRE:DATAO)     //	Data da ocorrência
	ZFO->ZFO_HORAO	 := U_OCORRE:HORA            //	Hora da ocorrência
	ZFO->ZFO_OBSDEV  := U_OCORRE:OBSERV          //	Código de observação de ocorrência na entrada
	ZFO->ZFO_DESOBS  := SubStr(U_OCORRE:OBSERV,1,50) // Descrição da Observação. // Tabela("ZW",U_OCORRE:OBSERV,.F.)
	ZFO->ZFO_DATAC	 := CTOD(U_OCORRE:DATAC)     //	Data de chegada no destino da NF
	ZFO->ZFO_HORAC 	 := U_OCORRE:HORAC           //	Hora de chegada no destino da NF
	ZFO->ZFO_DATAI   := CTOD(U_OCORRE:DATAI)     //	Data do inicio do descarregamento no destino
	ZFO->ZFO_HORAI 	 := U_OCORRE:HORAI           //	Hora de inicio do descarregamento no destino
	ZFO->ZFO_DATAT   := CTOD(U_OCORRE:DATAT)     //	Data de termino do descarregamento no destino
	ZFO->ZFO_HORAT	 := U_OCORRE:HORAT           //	Hora do termino do descarregamento no destino
	ZFO->ZFO_DATAS	 := CTOD(U_OCORRE:DATAS)     //	Data da saida do destino da nf
	ZFO->ZFO_HORAS	 := U_OCORRE:HORAS           //	Hora de saida do destino da nf
	ZFO->ZFO_CNPJDE	 := U_OCORRE:CNPJDEV         //	CNPJ do emissor da nota de devolução
	ZFO->ZFO_NOTADE	 := U_OCORRE:NOTADEV         //	Número da nota de devolução
	ZFO->ZFO_SERIED	 := U_OCORRE:SERIEDEV        //	Série da nota de devolução
	ZFO->ZFO_VALOR	 := U_OCORRE:VALOR           //	Valor da ocorrência
	ZFO->ZFO_USUARI	 := __CUSERID                //	Codigo do Usuário
	ZFO->ZFO_DATAAL	 := Date()                   //	Data de Alteração
	ZFO->ZFO_SITUAC	 := If(!_lAprovado,"R","P")  //	Situação do Registro
	ZFO->ZFO_CODEMP	 := _cCodEmpWS               //	Codigo Empresa WebServer
	ZFO->ZFO_RETORN	 := ::U_STATUS +_cTipoOcor   //	Retorno Integracao Italac-RDC
	ZFO->(MsUnLock())

	RestOrd(_aOrd)

Return _lRet

WSMETHOD U_LIBERAF WSRECEIVE U_FISCAL WSSEND U_STATUS WSSERVICE U_AOMS074
	Local _lRet := .T.
	Local _nTamChave := TamSX3('ZG0_CHAVE')[1]
	Local _cChave
	Local _cQry, _cMsg
	Local _lrej := .F.

	Begin Sequence
		_cChave := PadR(U_FISCAL:CHAVECTE,_nTamChave," ")
		_cQry := " SELECT ZG0.R_E_C_N_O_ AS NRECNO "
		_cQry += " FROM "+RetSqlName("ZG0")+" ZG0 "
		_cQry += " WHERE ZG0.D_E_L_E_T_ = '  '  AND ZG0_CHAVE = '"+_cChave+"' "
		_cQry += " AND (ZG0_SITUAC = 'E' OR ZG0_SITUAC = 'R' OR ZG0_SITUAC = 'A') "

		If Select("QRYZG0") > 0
			QRYZG0->(DbCloseArea())
		EndIf

		_cQry := ChangeQuery(_cQry)
		DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry), "QRYZG0", .F., .T.)

		_cMsg := ""

		If QRYZG0->(Eof()) .Or. QRYZG0->(Bof())
			_cMsg := " Não foi possível localizar no Protheus, a Chave de CTE: " + U_FISCAL:CHAVECTE
			Break
		EndIf

		ZG0->(DbGoTo(QRYZG0->NRECNO))

		If AllTrim(U_FISCAL:STATUSCTE) == "1" // 1=Aceito;2=Rejeitado
			ZG0->(RecLock("ZG0",.F.))
			ZG0->ZG0_HORA    := Time()  // Hora de gravação na tabela de muro.
			ZG0->ZG0_FLUXO   := "3"
			ZG0->ZG0_SITUAC  := "A" // "E" = Indica que foi enviado para a RDC e aguarda XML de Retorno. // "P" = Houve rejeição e este registro ficará como histórico. Um novo registro será criado. // "A" = Aceito.
			ZG0->ZG0_USUARI  := __CUSERID
			ZG0->ZG0_DATAAL  := Date()
			ZG0->ZG0_RETORN  := "XML CTE Liberação Fiscal Aceito. Integração realizada com sucesso." // grava o resultado da integração na tabela ZFQ,dizendo que deu certo ou não.
			ZG0->(MsUnlock())
		Else // 2=Rejeitado
			_lrej := .T.
			_cMsg := " Integração XML CTE Liberação Fiscal Rejeitado: " + AllTrim(U_FISCAL:MOTIVOCTE)
			ZG0->(RecLock("ZG0",.F.))
			ZG0->ZG0_HORA    := Time()  // Hora de gravação na tabela de muro.
			ZG0->ZG0_FLUXO   := "3"
			ZG0->ZG0_SITUAC  := "R" // "E" = Indica que foi enviado para a RDC e aguarda XML de Retorno. // "P" = Houve rejeição e este registro ficará como histórico. Um novo registro será criado. // "A" = Aceito.
			ZG0->ZG0_USUARI  := __CUSERID
			ZG0->ZG0_DATAAL  := Date()
			ZG0->ZG0_RETORN  := _cMsg // grava o resultado da integração na tabela ZFQ,dizendo que deu certo ou não.
			ZG0->(MsUnlock())

			//----------------------------------------------------------
			// Enviar e-mail avisando a rejeição.
			//----------------------------------------------------------
			_cAssunto := ZG0->ZG0_FILIAL + "-" + AllTrim( Posicione('SM0',1,cEmpAnt+ZG0->ZG0_FILIAL,'M0_FILIAL') ) + " XML de Liberação Fiscal CTE de Chave: "+ZG0->ZG0_CHAVE + " - REJEITADO NA LIBERAÇÃO FISCAL PELO RDC - "+ZG0->ZG0_TRACTE

			_cNomeFilial:= ZG0->ZG0_FILIAL + "-" + AllTrim( Posicione('SM0',1,cEmpAnt+ZG0->ZG0_FILIAL,'M0_FILIAL') )

			_aDadosCTE := {}
			Aadd(_aDadosCTE,ZG0->ZG0_EMICTE)  // DATA EMISSAO CTE
			Aadd(_aDadosCTE,ZG0->ZG0_NUMCTE)  // NUMERO CTE
			Aadd(_aDadosCTE,ZG0->ZG0_SERCTE)  // SERIE CTE
			Aadd(_aDadosCTE,ZG0->ZG0_TRACTE)  // TRANSPORTADORA CTE
			Aadd(_aDadosCTE,ZG0->ZG0_CGCCTE)  // CNPJ TRANSP. CTE
			Aadd(_aDadosCTE,_cNomeFilial)     // Cod.Filial - Nome Filial

			U_AOMS091E(ZG0->ZG0_FILIAL,ZG0->ZG0_CHAVE ,_aDadosCTE,_cAssunto,"Dados recebidos do RDC",.T.)
		EndIf

	End Sequence

	If Select("QRYZG0") > 0
		QRYZG0->(DbCloseArea())
	EndIf

	If !(Empty(_cMsg) .OR. _lrej)
		::U_STATUS := "SUCESSO:FALSE; " + _cMsg
	Elseif _lrej
		::U_STATUS := "SUCESSO:TRUE; Integração da liberação fiscal do CTE realizado com sucesso. "
	Else
		::U_STATUS := "SUCESSO:TRUE; Integração da liberação fiscal do CTE realizado com sucesso. "
	EndIf


Return _lRet



/*
===============================================================================================================================
Programa----------: AOMS074P
Autor-------------: Julio de Paula Paz
Data da Criacao---: 26/09/2016
Descrição---------: Valida a digitação das placas dos veículos para ver se a mesma não foi informada em outro campo.
Parametros--------: _cPlaca = Placa do veículo a ser validadada.
                    _nCampo = Ordem do campo que  chamaou a validação.
Retorno-----------: Vazio se Já existir a placa digitada em outro campo, ou placa informada como parâmetro caso seja única
                    para o campo informado.
===============================================================================================================================
*/
User Function AOMS074P(_cPlaca,_nCampo)
	Local _aArea 	:= GetArea()
	Local _cQuery	:= ""
	Local _lRet		:= .F.
	Local _cVeiculo	:= ""

	Begin Sequence
		_cQuery := "SELECT DA3_PLACA as PLACA, DA3_COD"
		_cQuery += " FROM " + RetSqlName("DA3")
		_cQuery += " WHERE D_E_L_E_T_ = ' ' AND DA3_PLACA = '" + _cPlaca + "'"

		_cQuery += " UNION ALL"

		_cQuery += " SELECT DA3_I_PLCV as PLACA, DA3_COD"
		_cQuery += " FROM " + RetSqlName("DA3")
		_cQuery += " WHERE D_E_L_E_T_ = ' ' AND DA3_I_PLCV = '" + _cPlaca + "'"

		_cQuery += " UNION ALL"

		_cQuery += " SELECT DA3_I_PLVG as PLACA, DA3_COD"
		_cQuery += " FROM " + RetSqlName("DA3")
		_cQuery += " WHERE D_E_L_E_T_ = ' ' AND DA3_I_PLVG = '" + _cPlaca + "'"

		_cQuery += " UNION ALL"

		_cQuery += " SELECT DA3_I_PLV3 as PLACA, DA3_COD"
		_cQuery += " FROM " + RetSqlName("DA3")
		_cQuery += " WHERE D_E_L_E_T_ = ' ' AND DA3_I_PLV3 = '" + _cPlaca + "'"

		dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQuery), "TEMP", .T., .F. )
		DbSelectArea("TEMP")

		If ( !Eof() )
			_lRet		:= .T.
			_cVeiculo	:= TEMP->DA3_COD
		EndIF

		DbCloseArea()

		If ((_nCampo == 1) .and. (!_lRet))     // digitando DA3_PLACA
			If ((_cPlaca == M->DA3_I_PLCV) .or. (_cPlaca == M->DA3_I_PLVG))
				_cPlaca	:= Space(8)
				_lRet	:= .T.
			EndIf
		ElseIf ((_nCampo == 2) .and. (!_lRet)) // digitando DA3_I_PLCV
			If ((_cPlaca == M->DA3_PLACA) .or. (_cPlaca == M->DA3_I_PLVG))
				_cPlaca := Space(8)
				_lRet	:= .T.
			EndIf
		ElseIf ((_nCampo == 3) .and. (!_lRet)) // digitando DA3_I_PLVG
			If ((_cPlaca == M->DA3_PLACA) .or. (_cPlaca == M->DA3_I_PLCV))
				_cPlaca := Space(8)
				_lRet	:= .T.
			EndIf
		ElseIf ((_nCampo == 4) .and. (!_lRet)) // digitando DA3_I_PLV3
			If (_cPlaca == M->DA3_PLACA) .or. (_cPlaca == M->DA3_I_PLCV) .or. (_cPlaca == M->DA3_I_PLVG)
				_cPlaca := Space(8)
				_lRet	:= .T.
			EndIf
		EndIf

		If (_lRet)
			_cPlaca := Space(8)
		EndIf

	End Sequence

	RestArea(_aArea)

Return _cPlaca

/*
===============================================================================================================================
Programa--------: AOMS074S
Autor-----------: Josué Danich Prestes
Data da Criacao-: 18/02/2014
Descrição-------: Valida Limite de Crédito do Cliente para gravação da carga
Parametros------: cNumPed - Número do pedido de venda do portal
----------------: cFilAux - Filial do pedido de venda
Retorno---------: lRet    - Informa o resultado da validação
===============================================================================================================================
*/
Static Function AOMS074S( cNumPed , cFilAux, Altera )

	Local aAreaSC5	:= GetArea("SC5")
	Local aAreaSC6	:= GetArea("SC6")
	Local aAreaSA1	:= GetArea("SA1")
	Local _ntotped 	:= 0

	Local _lret := .T.   // "Outros"
	Local _nTotPV:=0
	Local _lValCredito:=.T.
	Local _cTextoRet := "Aprovado em avalição de crédito"


	Default cNumPed	:= SC5->C5_NUM //Número do Pedido Posicionado
	DEfault cFilAux	:= SC5->C5_FILIAL //Filial do Pedido Posicionado

	Default altera := .T.

	Begin Sequence

		SC6->(Dbsetorder(1))
		SC5->(Dbsetorder(1))

		SC6->(DbGotop())
		SC5->(DbGotop())

		If !(SC6->(Dbseek(cFilAux+cNumPed))) .OR. !(SC5->(Dbseek(cFilAux+cNumPed)))

			_lret      := .F.
			_cTextoRet := "Filial : " + cFilAux + " / Pedido: " + cNumPed + ". Não Localizado. "
			Break

		Else

			_cchep := alltrim(GetMV("IT_CCHEP"))
			Do While SC6->C6_FILIAL == cFilAux .AND. SC6->C6_NUM == cNumPed


				_nTotPV += SC6->C6_VALOR

				If alltrim(SC6->C6_PRODUTO) == _cchep .OR. AllTrim(SC6->C6_CF) $ '5910/6910/5911/6911'//NÃO VALIDA CRÉDITO PARA PALLET CHEP E PARA BONIFICAÇÃO
					_lValCredito:=.F.
					EXIT
				ENDIF

				If posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC") != 'S' //NÃO VALIDA CRÉDITO PARA PEDIDO SEM DUPLICATA
					_lValCredito:=.F.
					EXIT
				Endif

				If posicione("ZAY",1,xfilial("ZAY")+ AllTrim(SC6->C6_CF) ,"ZAY_TPOPER") != 'V' //NÃO VALIDA CRÉDITO PARA PEDIDO COM CFOP QUE NÃO SEJA DE VENDA
					_lValCredito:=.F.
					EXIT
				Endif

				_ntotped += (SC6->C6_QTDVEN * SC6->C6_PRCVEN)

				SC6->(DbSkip())

			EndDo

		Endif

		IF _lValCredito

			_aRetCre := U_ValidaCredito( _nTotPV , SC5->C5_CLIENTE , SC5->C5_LOJACLI , Altera , , , , SC5->C5_MOEDA,,SC5->C5_NUM)//AWF-11/01/2017
			_cBlqCred:=_aRetCre[1]

			If _aRetCre[2] = "B"//Se bloqueou

				_lret      := .F.
				_cTextoRet := "Pedido de vendas " + alltrim(SC5->C5_NUM) + " bloqueado por crédito, " + _cBlqCred
				Break
			EndIf

		Else

			_lret := .T.
			_cTextoRet := "Pedido não passa por avaliação de crédito"

		Endif


	End Sequence

	SC5->(RestArea(aAreaSC5))
	SC6->(RestArea(aAreaSC6))
	SA1->(RestArea(aAreaSA1))

Return( {_lret,_cTextoRet} )

/*
===============================================================================================================================
Função------------: AOMS074M
Autor-------------: Julio de Paula Paz
Data da Criacao---: 29/03/2017
Descrição---------: Função de Envio de Email da integração da ocorrencias de frete.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS074M()
	Local _cEmail	   //:= AllTrim(U_ITGETMV("IT_EMAILCTE",""))
//Local _cEmailCC    := "" // AllTrim(U_ITGETMV("IT_MAILCCTE","")) 
	Local _aConfig	   := U_ITCFGEML('')
	Local _cMsgEml	   := ''
//Local _cData       := DtoC( DATE() )
	Local _cNomeFilial := ""
//Local _cMailUser   := ""  
	Local _cEmailTransp, _cEmailAComerc, _cEmailVend, _cEmailLogist, _cCodUser//, _aRetUser
	Local _cAssunto, _cTipoOcorrenc

// SC5,SF2,ZF5 = POSICIONADO NO REGISTRO

	Begin Sequence
		// Dados do Motorista
		_cDadosMotorista := ""
		DA4->(DbSetOrder(1)) // DA4_FILIAL+DA4_COD
		If DA4->(DbSeek(xFilial("DA4")+SF2->F2_I_MOTOR))
			// Codigo do motorista
			_cDadosMotorista := AllTrim(DA4->DA4_NOME) +" - Celular: " + AllTrim(DA4->DA4_TEL) + " - Tel.Recados: " + AllTrim(DA4->DA4_TELREC) + " - Tel.: " + AllTrim(DA4->DA4_I_TEL2)
		EndIf

		// Carrega os dados do Cliente
		_cDadosCliente := ""
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))
			_cDadosCliente := Transform(SA1->A1_CGC,"@R! NN.NNN.NNN/NNNN-99") + " - " + AllTrim(SA1->A1_NOME) + " - " + AllTrim(SA1->A1_MUN) + " - " + AllTrim(SA1->A1_EST)
		EndIf

		//========================================================
		// Carrega em variáveis os e-mails de envio.
		//========================================================
		// E-mail do transportador
		_cEmailTransp := ""
		_cDadosTransp := ""

		SA2->(DbSetOrder(1))
		If SA2->(DbSeek(xFilial("SA2")+SF2->F2_I_CTRA+SF2->F2_I_LTRA))
			_cEmailTransp := SA2->A2_EMAIL // Posicione("SA2",1,xFilial("SA2")+SF2->(F2_I_CTRA+F2_I_LTRA),"A2_EMAIL")  //  F2_I_CTRA  = SA2.A2_COD  AND SF2.F2_I_LTRA  = SA2.A2_LOJA
			_cDadosTransp := Transform(SA2->A2_CGC,"@R! NN.NNN.NNN/NNNN-99") + " - " + AllTrim(SA2->A2_NOME) + " - (" + AllTrim(SA2->A2_DDD) + ") " +  Transform(SA2->A2_TEL,"@R 99999-9999")
		EndIf

		// E-mail do assistente comercial
		_cEmailAComerc := "" // ZF5 - Usuário que insiriu o pedido no sistema. ZF5_RPCOM / ZF5_NRPCO / SubStr(Embaralha(SC5->C5_USERLGI,1),3,6)
		_cCodUser := SubStr(Embaralha(SC5->C5_USERLGI,1),3,6)
//   PswOrder(1)
		//If PswSeek(_cCodUser,.T.)
//      _aRetUser := PSWRET(1)        
		_cEmailAComerc := U_UCFG001(3,_cCodUser)//_aRetUser[1][14] // Email do Usuario
		// EndIf

		// E-mail do representante comercial
		_cDadosVendedor := "" // Carrega dados do Vendedor
		_cEmailVend := ""    // TABELA SA3 // Vendedor - ZF5_REPRES = Codigo do Representante/ZF5_NREPRE=Nome e telefone do representante / SF2->F2_VEND1
		SA3->(DbSetOrder(1)) // A3_FILIAL+A3_COD
		If SA3->(DbSeek(xFilial("SA3")+SF2->F2_VEND1))
			_cDadosVendedor := SA3->A3_NOME

			// E-mail do representante comercial
			_cEmailVend := SA3->A3_EMAIL //Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND1,"A3_EMAIL")
		EndIf

		// E-mail do responsável logistico
		_cEmailLogist := ""  // "Parâmento, zf5 responsável logistico. ZF5_RPLOGI / ZF5_NRPLO
		_cCodUser := AllTrim(U_ITGETMV( 'IT_RESPLOG' , ''))

		If !Empty(_cCodUser)
//    PswOrder(1)
			//    If PswSeek(_cCodUser,.T.)
			//     _aRetUser := PSWRET(1)
			_cEmailLogist := U_UCFG001(3,_cCodUser)//_aRetUser[1][14] // Email do Usuario
			//EndIf
		EndIf

		_cAssunto := ZF5->ZF5_FILIAL + "-" + AllTrim( Posicione('SM0',1,cEmpAnt+ZF5->ZF5_FILIAL,'M0_FILIAL') ) + " - Inclusão de ocorrência de frete através de integração com o sistema RDC. "

		_cNomeFilial := ZF5->ZF5_FILIAL + "-" + AllTrim( Posicione('SM0',1,cEmpAnt+ZF5->ZF5_FILIAL,'M0_FILIAL') )

		_cEmail := ""

		// E-mail do transportador
		If ! Empty(_cEmailTransp)
			_cEmail += AllTrim(_cEmailTransp) + "; "
		EndIf

		// E-mail do assistente comercial
		If ! Empty(_cEmailAComerc)
			_cEmail += AllTrim(_cEmailAComerc) + "; "
		EndIf

		// E-mail do responsável logistico
		If ! Empty(_cEmailLogist)
			_cEmail += AllTrim(_cEmailLogist) + "; "
		EndIf

		// E-mail do representante comercial
		If ! Empty(_cEmailVend)
			_cEmail += AllTrim(_cEmailVend)
		EndIf

		If Empty( _cEmail )
			//u_itconout(" Nenhum e-mail de envio foi informado.")
			Break
		Else
			_cMsgEml := '<html>'
			_cMsgEml += '<head><title>Integração de Ocorrências de Frete enviadas do Sistema RDC para o Protheus</title></head>'
			_cMsgEml += '<body>'
			_cMsgEml += '<style type="text/css"><!--'
			_cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
			_cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
			_cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
			_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
			_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
			_cMsgEml += '--></style>'
			_cMsgEml += '<center>'
			_cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="600" height="50"><br>'
			_cMsgEml += '<table class="bordasimples" width="600">'
			_cMsgEml += '    <tr>'
			_cMsgEml += '	     <td class="titulos"><center>'+"Inclusão de Ocorrências de Frete enviado pelo sistema RDC "+'</center></td>'
			_cMsgEml += '	 </tr>'
			_cMsgEml += '</table>'
			_cMsgEml += '<br>'
			_cMsgEml += '<table class="bordasimples" width="600">'
			_cMsgEml += '    <tr>'
			_cMsgEml += '      <td align="center" colspan="2" class="grupos">Nota Fiscal - Serie: <b>'+ AllTrim(ZF5->ZF5_DOCOC) +"-"+ Alltrim(ZF5->ZF5_SEROC) +'</b></td>'
			_cMsgEml += '    </tr>'

			_cMsgEml += '    <tr>'
			_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Enviado por </b></td>'
			_cMsgEml += '      <td class="itens" >'+"Integração de Ocorrências de Frete Sistema RDC <--->Italac"+'</td>'
			_cMsgEml += '    </tr>'

			_cMsgEml += '    <tr>'
			_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Cliente</b></td>'
			_cMsgEml += '      <td class="itens" >'+ _cDadosCliente +'</td>'
			_cMsgEml += '    </tr>'

			_cMsgEml += '    <tr>'
			_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Vendedor</b></td>'
			_cMsgEml += '      <td class="itens" >'+ _cDadosVendedor +'</td>'
			_cMsgEml += '    </tr>'

			_cMsgEml += '    <tr>'
			_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Transportador</b></td>'
			_cMsgEml += '      <td class="itens" >'+ _cDadosTransp +'</td>'
			_cMsgEml += '    </tr>'

			_cMsgEml += '    <tr>'
			_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Motorista </b></td>'
			_cMsgEml += '      <td class="itens" >'+ _cDadosMotorista +'</td>'
			_cMsgEml += '    </tr>'

			_cMsgEml += '    <tr>'
			_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Sequencia Ocorrência</b></td>'
			_cMsgEml += '      <td class="itens" >'+ ZF5->ZF5_CODIGO +'</td>'
			_cMsgEml += '    </tr>'

			_cTipoOcorrenc := AllTrim(ZF5->ZF5_TIPOO) + " - " + AllTrim( Posicione('ZFC',1,xFilial("ZFC")+ZF5->ZF5_TIPOO,'ZFC_DESC') )

			_cMsgEml += '    <tr>'
			_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Tipo de Ocorrencia</b></td>'
			_cMsgEml += '      <td class="itens" >'+ _cTipoOcorrenc  +'</td>'
			_cMsgEml += '    </tr>'

			_cMsgEml += '    <tr>'
			_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Motivo da Ocorrencia</b></td>'
			_cMsgEml += '      <td class="itens" >'+ ZF5->ZF5_MOTIVO +'</td>'
			_cMsgEml += '    </tr>'
			_cMsgEml += '    <tr>'
			_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Data daOcorrencia</b></td>'
			_cMsgEml += '      <td class="itens" >'+ Dtoc(ZF5->ZF5_DTINI)  +'</td>'
			_cMsgEml += '    </tr>'

			_cMsgEml += '    <tr>'
			_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Hora da Ocorrencia</b></td>'
			_cMsgEml += '      <td class="itens" >'+ ZF5->ZF5_HRINI  +'</td>'
			_cMsgEml += '    </tr>'


			_cMsgEml += '	<tr>'
			_cMsgEml += '      <td class="titulos" align="center" colspan="2"><font color="red"><u>Esta é uma mensagem automática. Por favor não a responda!</u></font></td>'
			_cMsgEml += '    </tr>'
			_cMsgEml += '</table>'

			_cMsgEml += '<br>'

			_cMsgEml += '</center>'

			If !SuperGetMV("IT_AMBTEST",.F.,.T.)
				_cMsgEml += '    <tr>'
				_cMsgEml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
				_cMsgEml += '      <td class="itens" align="left" > ['+ GetEnvServer() +'] </td>'
				_cMsgEml += '    </tr>'
			EndIf

			_cMsgEml += '</body>'
			_cMsgEml += '</html>'
			_cEmlLog := ''

			// U_ITENVMAIL(cFrom      ,cEmailTo ,cEmailCo  ,cEmailBcc,cAssunto ,cMensagem,cAttach   ,cAccount    ,cPassword   ,cServer      ,cPortCon    ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro)
			U_ITENVMAIL( _aConfig[01] , _cEmail ,/*_cMailUser*/, /*_cEmailCC*/ ,_cAssunto, _cMsgEml,          ,_aConfig[01],_aConfig[02], _aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

		EndIf

	End Sequence

Return .T.

/*
===============================================================================================================================
Função------------: AOMS074J
Autor-------------: Josué Danich Prestes
Data da Criacao---: 31/05/2017
Descrição---------: Função de análise de estoque do pedido de vendas
Parametros--------: Nenhum
Retorno-----------: array com primeira posição lógica se estoque está ok e liberado e segunda posição string com descrição de
					problemas de estoque se existirem
===============================================================================================================================
*/
Static Function AOMS074J

	Local _aret := {}
	Local _lret := .T.
	Local _cmsg := "Pedido com estoque liberado"



	_lret := .T.
	_cmsg := ""

	// Monta valor total do pedido
	ntotped := 0

	SC6->(Dbsetorder(1))
	If SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))

		Do while SC6->C6_FILIAL + SC6->C6_NUM == SC5->C5_FILIAL+SC5->C5_NUM

			If !SC6->(MsRLock(SC6->(RECNO())))

				return {.F.,"No momento o item deste Pedido de Vendas está sendo utilizado por outro usuário e não pode ser manipulado. "}

			Endif

			SB2->(Dbsetorder(1))
			If !(SB2->(Dbseek(SC6->C6_FILIAL + SC6->C6_PRODUTO +SC6->C6_LOCAL))) .OR. !SB2->(MsRLock(SB2->(RECNO())))

				SC6->(MSUNLOCKALL())
				SC6->(Msunlock())
				return {.F.,"No momento o estoque deste pedido de vendas está sendo utilizado por outro usuário e não pode ser manipulado. "}

			Endif

			ntotped += SC6->C6_VALOR

			SC6->( Dbskip())
		Enddo

	EndIf


	SC6->(Dbsetorder(1))
	If  SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))

		_aAprovacao := AOMS074S()     // Verifica as aprovações de credito.
		_lAprov     := _aAprovacao[1] // True = Credito aprovado / False = Credito reejeitadao
		_cTextoRet  := _aAprovacao[2] // Mensagem de retorno.

		If Reclock("SC5",.F.) .and. _lAprov // AOMS074S()

			//Verifica se existem liberaçoes de estoque válidas para todos os itens
			SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))
			_ltemlibe := .T.


			//u_itconout(" Verificando liberações atuais do pedido: "+SC6->C6_FILIAL+"-"+SC6->C6_NUM+"-"+SC6->C6_ITEM+" - "+DTOC(DATE())+" - "+TIME())

			Do While !(SC6->(Eof())) .And. SC6->(C6_FILIAL+C6_NUM) == SC5->C5_FILIAL+SC5->C5_NUM

				SC9->(Dbsetorder(1))
				If !(SC9->(DbSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))) .OR. !EMPTY(SC9->C9_BLEST)  // verifica estoque se não tem liberação válida ainda

					_ltemlibe := .F.

				Endif

				SC6->(Dbskip())

			Enddo

			If _ltemlibe
				_cMsg += " Pedido de Vendas Já Liberado. "
			EndIf

			BEGIN TRANSACTION

				SC6->(Dbsetorder(1))
				SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))

				Do While !(SC6->(Eof())) .And. SC6->(C6_FILIAL+C6_NUM) == SC5->C5_FILIAL+SC5->C5_NUM

					SC9->(Dbsetorder(1))
					If !(SC9->(DbSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))) .OR. !EMPTY(SC9->C9_BLEST)  // verifica estoque se não tem liberação válida ainda

						If (SC9->(DbSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))) .AND. !EMPTY(SC9->C9_BLEST)

							//u_itconout(" Estornando liberações para o pedido: "+SC6->C6_FILIAL+"-"+SC6->C6_NUM+"-"+SC6->C6_ITEM+" - "+DTOC(DATE())+" - "+TIME())

							SC9->(A460Estorna()) //Se já tem sc9 com bloqueio de estoque estorna a liberação

						Endif

						//u_itconout(" Liberando pedido: "+SC6->C6_FILIAL+"-"+SC6->C6_NUM+"-"+SC6->C6_ITEM+" - "+DTOC(DATE())+" - "+TIME())

						_lbloqueia := .T.

						If !SC6->(MsRLock(SC6->(RECNO())))
							//u_itconout(" No momento este item de Pedido de Vendas está sendo utilizado por outro usuário e não pode ser manipulado. Tente integrar novamente mais tarde: " + SC6->C6_FILIAL+"-"+SC6->C6_NUM+"-"+SC6->C6_ITEM+" - "+DTOC(DATE())+" - "+TIME())
							_cMsg += "No momento este item de Pedido de Vendas está sendo utilizado por outro usuário e não pode ser manipulado. Tente integrar novamente mais tarde: " + SC6->C6_FILIAL+"-"+SC6->C6_NUM+"-"+SC6->C6_ITEM
							_lbloqueia := .F.

						Endif

						SB2->(Dbsetorder(1))

						If !(SB2->(Dbseek(SC6->C6_FILIAL + SC6->C6_PRODUTO +SC6->C6_LOCAL))) .OR. !SB2->(MsRLock(SB2->(RECNO())))

							SC6->(MSUNLOCKALL())
							SC6->(Msunlock())

							//u_itconout(" No momento o estoque deste item de pedido de vendas está sendo utilizado por outro usuário e não pode ser manipulado. Tente integrar novamente mais tarde: " + SC6->C6_FILIAL+"-"+SC6->C6_NUM+"-"+SC6->C6_ITEM+" - "+DTOC(DATE())+" - "+TIME())
							_cMsg += "No momento o estoque deste item de pedido de vendas está sendo utilizado por outro usuário e não pode ser manipulado. Tente integrar novamente mais tarde: " + SC6->C6_FILIAL+"-"+SC6->C6_NUM+"-"+SC6->C6_ITEM
							_lbloqueia := .F.

						Endif

						If _lbloqueia

							_nQtdLib := MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN)//LIBERA PEDIDO
							//u_itconout(" Pedido Liberado: "+SC6->C6_FILIAL+"-"+SC6->C6_NUM+"-"+SC6->C6_ITEM+" - "+DTOC(DATE())+" - "+TIME())

						Else

							Disarmtransaction()

						Endif

					Endif

					//Analise da liberação de estoque
					_lestoque := .F.

					SC9->(Dbsetorder(1))
					If SC9->(DbSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))

						If SC9->C9_QTDLIB <> SC6->C6_QTDVEN
							_cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". A quantidade liberada diverge da quantidade do item: " + SC6->C6_ITEM + " - Produto: " +;
								SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
						ElseIf !Empty(SC9->C9_BLEST)
							_cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". Bloqueio de estoque para o item: " + SC6->C6_ITEM + " - Produto: " +;
								SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
						ElseIf !Empty(SC9->C9_BLCRED)
							_cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". Bloqueio de crédito para o item: " + SC6->C6_ITEM + " - Produto: " +;
								SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
						ElseIf !Empty(SC9->C9_CARGA)
							_cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". Bloqueio de carga para o item: " + SC6->C6_ITEM + " - Produto: " +;
								SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
						ElseIf !Empty(SC9->C9_NFISCAL)
							_cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". Bloqueio de nota fiscal para o item: " + SC6->C6_ITEM + " - Produto: " +;
								SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
						Else
							_lestoque := .T.

						Endif

					Else

						_cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". Liberação não gerada para: " + SC6->C6_ITEM + " - Produto: " +;
							SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."

					Endif

					If !(_lestoque)

						_cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". Não foi possível liberar as quantidades do Item: " + SC6->C6_ITEM + " - Produto: " +;
							SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
					Endif

					MsUnLockAll()

					If _lestoque

						Reclock("SC5",.F.)
						SC5->C5_LIBEROK := "S"

					Endif

					SC6->(MSUNLOCKALL())
					SC6->(Msunlock())
					SB2->(MSUNLOCKALL())
					SB2->(Msunlock())
					SC5->(MSUNLOCKALL())
					SC5->(Msunlock())

					If .not. _lestoque

						_lret := .F.

					Endif

					SC6->(Dbskip())

				Enddo

			END TRANSACTION

			SC6->(MSUNLOCKALL())
			SC6->(Msunlock())
			SB2->(MSUNLOCKALL())
			SB2->(Msunlock())
			SC5->(MSUNLOCKALL())
			SC5->(Msunlock())

		Elseif !_lAprov //Não passou na análise de crédito

			_cMsg +=  " -  Falha liberação de crédito do Pedido de Vendas: " + AllTrim(SC5->C5_NUM)
			MsUnLockAll()

			SC5->(RecLock("SC5",.F.))
			SC5->C5_I_BLCRE	:= "B"
			SC5->C5_I_DTAVA := DATE()
			SC5->C5_I_HRAVA := TIME()
			SC5->C5_I_USRAV := cusername
			SC5->C5_I_MOTBL := _cTextoRet
			SC6->(MSUNLOCKALL())
			SC6->(Msunlock())
			SB2->(MSUNLOCKALL())
			SB2->(Msunlock())
			SC5->(MSUNLOCKALL())
			SC5->(Msunlock())

			_lret := .F.

		Endif

	Endif

//Garante que todos os registros são liberados
	SC6->(Dbsetorder(1))
	If SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))


		Do while SC6->C6_FILIAL + SC6->C6_NUM == SC5->C5_FILIAL+SC5->C5_NUM

			SC6->(MSUNLOCKALL())

			SC6->(Dbskip())

		Enddo

	Endif


	SB2->(MSUNLOCKALL())
	SB2->(Msunlock())
	SC5->(MSUNLOCKALL())
	SC5->(Msunlock())

	_aret := {_lret,_cmsg}

Return _aret

/*
===============================================================================================================================
Função------------: AOMS074R
Autor-------------: Julio de Paula Paz
Data da Criacao---: 19/06/2017
Descrição---------: Estorna o bloqueio de estoque para o item de pedido de vendas/pedido.

Parametros--------: Nenhum
Retorno-----------: True or False
===============================================================================================================================
*/
User Function AOMS074R()
	Local _lRet := .T.
	Local _aSC5 := SC5->(GetArea())
	Local _aSC6 := SC6->(GetArea())
	Local _aSB2 := SB2->(GetArea())
	Local _aSA1 := SA1->(GetArea())
	Local _cped := SC5->C5_NUM
	Local _cfilial := SC5->C5_FILIAL

	BEGIN TRANSACTION

//Realiza desliberaçãoes
		SC6->(Dbsetorder(1))
		SC6->(DbSeek(_cfilial+_cped))

		Do While !(SC6->(Eof())) .And. SC6->(C6_FILIAL+C6_NUM) == _cfilial+_cped

			SC9->(Dbsetorder(1))

			If (SC9->(DbSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM)))

				//u_itconout(" Estornando liberações para o pedido: "+SC6->C6_FILIAL+"-"+SC6->C6_NUM+"-"+SC6->C6_ITEM+" - "+DTOC(DATE())+" - "+TIME())
				SC9->(_lRet:=A460Estorna())

			EndIf

			SC6->(Dbskip())

		EndDo

//Verifica se estorno foi bem sucedido
		SC6->(Dbsetorder(1))
		SC6->(DbSeek(_cfilial+_cped))

		Do While !(SC6->(Eof())) .And. SC6->(C6_FILIAL+C6_NUM) == _cfilial+_cped

			SC9->(Dbsetorder(1))

			If (SC9->(DbSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM)))

				//u_itconout(" Localizada liberação não estornada para o pedido: "+SC6->C6_FILIAL+"-"+SC6->C6_NUM+"-"+SC6->C6_ITEM+" - "+DTOC(DATE())+" - "+TIME())
				_lret := .F.

			EndIf

			SC6->(Dbskip())

		EndDo

//Se deu certo marca pedido como sem liberações
		If _lret

			Reclock("SC5",.F.)
			SC5->C5_LIBEROK := " "

		Else

			Disarmtransaction()

		Endif

		SC5->(MSUNLOCKALL())
		SC5->(Msunlock())
		SC6->(MSUNLOCKALL())
		SC6->(Msunlock())
		SB2->(MSUNLOCKALL())
		SB2->(Msunlock())
		SC5->(MSUNLOCKALL())
		SC5->(Msunlock())
		SA1->(MSUNLOCKALL())
		SA1->(Msunlock())


	END TRANSACTION

	RestArea(_aSC5)
	RestArea(_aSC6)
	RestArea(_aSB2)
	RestArea(_aSA1)

Return _lRet

/*
===============================================================================================================================
Função------------: AOMS074D
Autor-------------: Josué Danich Prestes
Data da Criacao---: 16/08/2017
Descrição---------: Verifica se algum item da carga já foi faturado
Parametros--------: Nenhum
Retorno-----------: Lógico, .T. se algum item já foi faturado.
===============================================================================================================================
*/
Static function AOMS074D()
	Local _lret := .F.

	DAI->(Dbsetorder(1))
	SC9->(Dbsetorder(1))

	If DAI->(Dbseek(DAK->DAK_FILIAL+DAK->DAK_COD))

		Do while DAK->DAK_FILIAL == DAI->DAI_FILIAL .AND. DAK->DAK_COD == DAI->DAI_COD

			If SC9->(Dbseek(DAI->DAI_FILIAL+DAI->DAI_PEDIDO))

				Do while SC9->C9_FILIAL == DAI->DAI_FILIAL .AND. SC9->C9_PEDIDO == DAI->DAI_PEDIDO

					If !Empty(SC9->C9_NFISCAL)

						_lret := .T.

					Endif

					SC9->(Dbskip())

				Enddo

			Endif

			DAI->(Dbskip())

		Enddo

	Endif

Return _lret

/*
===============================================================================================================================
Programa----------: AOMS074U
Autor-------------: Josué Danich Prestes
Data da Criacao---: 29/11/2017
Descrição---------: Rotina WatchDog dos execautos do ALTERAP
Parametros--------: _ntime - segundos até timeout
					_nThread - thread a ser acompanhada
					pubvar - variável pública de flag de situação da thread monitorada
					_cpedido - pedido da alteração sendo monitorada
Retorno-----------: Nenhum
===============================================================================================================================
*/
user function AOMS074U(_ntime,_nThread,pubvar,_cpedido)

	Local _tini := seconds()
	Local _dini := date()

	Do  while  date() == _dini

		//u_itconout("Acompanhando execauto do ALTERAP do pedido " + _cpedido + " na Thread " + strzero(_nThread,6)  + " por " + strzero((seconds() - _tini),3) + " segundos...")

		If GetGlbValue(pubvar) != "Alterando"

			//u_itconout("Alteração completada no pedido " + _cpedido + " pela thread " + strzero(_nThread,6) +  " - Encerrando monitor")
			Return

		Endif

		_amonitor := GetUserInfoArray()

		_ni := Ascan(_amonitor,{|aVal| aVal[3] == _nThread})

		If  _ni > 0

			If (seconds() - _tini) >= _ntime

				//u_itconout("Derrubando ALTERAP na Thread " +strzero(_amonitor[_ni][3],6) + " por timeout, pedido " + _cpedido )

				KillUser( _amonitor[_ni][1], _amonitor[_ni][2], _amonitor[_ni][3], _amonitor[_ni][4] )

			Endif

		Else

			//u_itconout("Não achou Thread de origem para o ALTERAP do pedido " + _cpedido + ", finalizando monitor")

			Return

		Endif

		sleep(1000)

	Enddo

Return

/*
===============================================================================================================================
Programa----------: AOMS074W
Autor-------------: Josué Danich Prestes
Data da Criacao---: 29/11/2017
Descrição---------: Rotina WatchDog dos execautos do INCLUIC
Parametros--------:  _ntime - segundos até timeout
					_nThread - thread a ser acompanhada
					pubvar - variável pública de flag de situação da thread monitorada
					_ccarga - pedido da alteração sendo monitorada
Retorno-----------: Nenhum
===============================================================================================================================
*/
user function AOMS074W(_ntime,_nThread,pubvar,_ccarga)

	Local _tini := seconds()
	Local _dini := date()

	Do  while  date() == _dini

		//u_itconout("Acompanhando execauto do INCLUIC da carga " + _ccarga + " na Thread " + strzero(_nThread,6)  + " por " + strzero((seconds() - _tini),3) + " segundos...")

		If GetGlbValue(pubvar) != "Alterando"

			//u_itconout("Inclusão de carga " + _ccarga + " completada pela thread " + strzero(_nThread,6) +  " - Encerrando monitor")
			Return

		Endif

		_amonitor := GetUserInfoArray()

		_ni := Ascan(_amonitor,{|aVal| aVal[3] == _nThread})

		If  _ni > 0

			If (seconds() - _tini) >= _ntime

				u_itconout("Derrubando Thread " +strzero(_amonitor[_ni][3],6) + " do INCLUIC da carga " + _ccarga + " por timeout" )
				UnLockByName(pubvar,.F.,.F.,.T.)

				KillUser( _amonitor[_ni][1], _amonitor[_ni][2], _amonitor[_ni][3], _amonitor[_ni][4] )

			Endif

		Else

			//u_itconout("Não achou Thread de origem do INCLUIC da carga " + _ccarga + ", finalizando monitor")
			UnLockByName(pubvar,.F.,.F.,.T.)

			Return

		Endif

		sleep(1000)

	Enddo

Return

/*
===============================================================================================================================
Programa----------: AOMS074X
Autor-------------: Julio de Paula Paz
Data da Criacao---: 09/01/2018
Descrição---------: Remover caracteres especiais dos campos passados como parâmetro.
Parametros--------: _cCampo = Campo do tipo texto a ter os caracteres especiais removidos.
Retorno-----------: _cRet = Texto que teve os caracteres especiais removidos.
===============================================================================================================================
*/
User Function AOMS074X(_cCampo)
	Local _cRet
	Local _nI
	Local _cTexto := _cCampo
	Local _cCaracter
	Local _nPosic, _nJ
	Local _nTamTexto
	Local _cNovoTexto
	Local _cCharEspecial := U_ITGETMV( 'IT_CHARESPE' , ',.;:-@!?' )

	Begin Sequence
		_cTexto := _cTexto + Space(Len(_cCampo))

		For _nI := 0 To 255
			If (_nI < 40 .Or. _nI >123) .And. _nI <> 32
				_cCaracter := Char(_nI)
				If !(_cCaracter $ _cCharEspecial)
					If ! Empty(_cCaracter)
						_nJ := Asc(_cCaracter)
						If (_nJ < 40 .Or. _nJ >123) .And. _nJ <> 32
							_nPosic := At(_cCaracter,_cTexto)
							If _nPosic > 0
								_cTexto := STUFF(_cTexto, _nPosic, 1 , " ")
								If _nPosic > _nI
									_nI := _nPosic
									If _nI > 0
										_nI -= 1
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		Next

		_nTamTexto := Len(_cTexto)

		_cTexto := _cTexto + Space(_nTamTexto * 2)
		_cNovoTexto := ""

		For _nI := 1 To _nTamTexto
			_cCaracter := SubStr(_cCampo,_nI,1)

			//If _cCaracter == " " .Or. (Asc(_cCaracter) > 46 .And. Asc(_cCaracter) < 124 )
			If _cCaracter == " " .Or. (Asc(_cCaracter) > 47 .And. Asc(_cCaracter) < 58 ) ;
					.Or. (Asc(_cCaracter) > 64 .And. Asc(_cCaracter) < 91 ) ;
					.Or. (Asc(_cCaracter) > 96 .And. Asc(_cCaracter) < 123 ) ;
					.Or. (_cCaracter $ _cCharEspecial)

				_cNovoTexto += _cCaracter
			Else
				_cNovoTexto += " " // Os caracteres especiais são substituidos por epaços.
			EndIf
		Next

	End Sequence

	_cRet := _cNovoTexto

Return _cRet

/*
===============================================================================================================================
Programa----------: AOMS074Z
Autor-------------: Julio de Paula Paz
Data da Criacao---: 22/08/2018
Descrição---------: Valida se a TES para o pedido de Pallet é válida.
Parametros--------: _cTipoCarga = Código do tipo de carga.
Retorno-----------: .T. / .F. 
===============================================================================================================================
*/
User Function AOMS074Z(_cTipoCarga)
	Local _lRet := .T.
	Local _aRet := {.T.,"",""}
	Local _nRegSC5 := SC5->(Recno())
	Local _nRegSC6 := SC6->(Recno())
	Local _cSuframa, _cEstCli, _cCliPed, _cLjCliPed
	Local _TipoC := "C" // 1-Pallet Chep
	Local _cArmSB1, _cArmSBZ, _cArmazem

	Begin Sequence
		_cCliPed   := SC5->C5_CLIENTE
		_cLjCliPed := SC5->C5_LOJACLI

		If SC5->C5_TIPO == "B"
			SA2->(DbSetOrder(1))
			SA2->(DbSeek(xFilial("SA2")+_cCliPed + _cLjCliPed))

			_cSuframa:= ""
			_cEstCli := SA2->A2_EST

		Else
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial("SA1")+_cCliPed + _cLjCliPed))

			_cSuframa:= SA1->A1_SUFRAMA
			_cEstCli := SA1->A1_EST

		EndIf

		If !EMPTY(_cSuframa)//O campo de Suframa não é "sim" ou "nao" é um código
			_cSuframa:= "S"
		Else
			_cSuframa:= "N"
		EndIf

		_cEstFil  := SM0->M0_ESTCOB
		_cCliPed  := SC5->C5_CLIENTE
		_cLjCliPed:= SC5->C5_LOJACLI

		If _cTipoCarga $ "3,6"//"3-Pallet PBR","6-Pallet PBR Retorno"
			_TipoC:="P"
		EndIf

		//====================================================================================================
		// Verifica o Tipo de Pallet e recupera o código do Produto referente
		//====================================================================================================
		If _TipoC == "C"
			_cProduto := GetMV( "IT_CCHEP" )
		ElseIf _TipoC == "P"
			_cProduto := GetMV( "IT_PPBR" )
		EndIf

		//Define se é cliente chep
		_clichep := "N"
		SA1->(Dbsetorder(1))
		If SA1->( DBSeek( xFilial("SA1") + ( _cCliPed + _cLjCliPed ) ) )

			IF LEN(ALLTRIM(SA1->A1_I_CCHEP)) == 10
				_clichep := "S"
			ENDIF

		EndIf

		//Define tipo de  de operação

		If _TipoC == "C" //Pallet Chep

			If _cCliPed == '000001'

				If _clichep == "S"
					cTpOper	:= AllTrim( U_ITGETMV( 'IT_CHEPITLS' ) )
				Else
					cTpOper	:= AllTrim( U_ITGETMV( 'IT_CHEPITLN' ) )
				EndIf

			Else

				If _clichep == "S"
					cTpOper	:= AllTrim( U_ITGETMV( 'IT_CHEPCLIS' ) )
				Else
					cTpOper	:= AllTrim( U_ITGETMV( 'IT_CHEPCLIN' ) )
				EndIf

			EndIf

		Elseif _TipoC == "P" //Pallet PBR

			If _cCliPed == '000001'

				cTpOper	:= AllTrim( U_ITGETMV( 'IT_PBRITLP','51' ) )

			Else

				cTpOper	:= AllTrim( U_ITGETMV( 'IT_PBRCLIP','51' ) )

			Endif

		Endif

		_cArmSB1 := Posicione('SB1',1,xFilial("SB1")+U_ITKEY(_cProduto,"B1_COD"),'B1_LOCPAD')

		_cArmSBZ := Posicione('SBZ',1,SC5->C5_FILIAL+U_ITKEY(_cProduto,"B1_COD"),'BZ_LOCPAD')

		_cArmazem := If(Empty(_cArmSBZ), _cArmSB1 , _cArmSBZ )

		_cTES:= u_selectTES(U_ITKEY(_cProduto,"B1_COD"),_cSuframa,_cEstCli,_cEstFil,_cCliPed,_cLjCliPed,cTpOper,_cArmazem,SC5->C5_TIPO)

		If Empty(_cTES)
			_lRet := .F.
		EndIf

		_aRet := {_lRet,_cProduto, "Cliente: "+_cCliPed +"- Loja: "+_cLjCliPed }

	End Sequence

	Sc5->(DbGoTo (_nRegSC5))
	Sc6->(DbGoTo (_nRegSC6))

Return _aRet

/*
===============================================================================================================================
Programa----------: AOMS74Travou()
Autor-------------: Alex Wallauer
Data da Criacao---: 09/10/2018
Descrição---------: Loca os registro de tabelas previamente, Tenta realizar lock de todos os registros por _ni segundos
Parametros--------: aTabelas: Lista tabelas p/ travar, aItens: itens do Pallet, _cErro: Mensagens erro, _lUnLock: Destrava
Retorno-----------: _ltravou: .T. / .F. 
===============================================================================================================================
*/
Static Function AOMS74Travou(aTabelas,aItensPallet,_cErro,_lUnLock)
	LOCAL _lIT_LOCKPD:= U_ITGETMV( 'IT_LOCKPD' , .F. )
	LOCAL _tini      := SECONDS()
	LOCAL _dini      := DATE()
	LOCAL _ltravou   := .F.   , I

	DEFAULT aTabelas    :={"ZFQ","ZFR","SC5","SC6","SA1","SB2"}
	DEFAULT aItensPallet:={}
	DEFAULT _cErro      :=""
	DEFAULT _lUnLock    :=.F.

	DO WHILE !(_ltravou) .and. (seconds() - _tini) < 10 .and. date() == _dini

		_ltravou := .T.
		//U_ITCONOUT("Tentativas de Travamento de registros: "+ALLTRIM(STR( (seconds()-_tini)+1 )) )

		IF LEN(aItensPallet) >  0

			FOR I := 1 TO LEN(aItensPallet)

				SB2->(Dbsetorder(1))
				IF SB2->(Dbseek(aItensPallet[I]))

					If !_lUnLock

						If !SB2->(MsRLock(SB2->(RECNO())))

							//u_itconout("Pallet - Produto Pallet em uso: "+AllTrim(aItensPallet[I])+".")
							_cErro := "Produto Pallet em uso: "+AllTrim(aItensPallet[I])+"."
							_ltravou := .F.

						Else

							//U_ITCONOUT("Pallet - Travado o Produto do Pallet: "+AllTrim(aItensPallet[I])+".")

						Endif

					Else

						SB2->(MSUNLOCKALL())
						SB2->(Msunlock())
						//U_ITCONOUT("Pallet - Destravado o Produto do Pallet: "+AllTrim(aItensPallet[I])+".")

					Endif

				Else

					//u_itconout("Pallet - Produto Pallet não localizado: "+AllTrim(aItensPallet[I])+".")
					_cErro := "Produto Pallet não localizado: "+AllTrim(aItensPallet[I])+"."
					_ltravou := .F.

				Endif

			NEXT

		Endif

		IF ASCAN(aTabelas,"ZFQ") <>  0

			ZFQ->(Dbsetorder(3))
			If ZFQ->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))

				Do while ZFQ->ZFQ_FILIAL == SC5->C5_FILIAL .AND. ZFQ->ZFQ_PEDIDO == SC5->C5_NUM  .AND. ZFQ->(!EOF())

					If ! ZFQ->(MsRLock(ZFQ->(RECNO())))

						u_itconout(" Muro de Pedido de Vendas em uso: "+AllTrim(U_ALTERA:PEDIDO)+"."+" - "+DTOC(DATE())+" - "+TIME())
						_cErro := "SUCESSO:FALSE; Muro Pedido de Vendas em uso: "+AllTrim(U_ALTERA:PEDIDO)+"."
						_ltravou := .F.

					Else

						If  _lIT_LOCKPD

							ZFQ->(MSUNLOCKALL())
							ZFQ->(Msunlock())

						Endif

					Endif

					ZFQ->(Dbskip())

				Enddo

			Endif

		Endif

		IF ASCAN(aTabelas,"ZFR") <>  0

			ZFR->(Dbsetorder(3))
			If ZFR->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))

				Do while ZFR->ZFR_FILIAL == SC5->C5_FILIAL .AND. ZFR->ZFR_NUMPED == SC5->C5_NUM  .AND. ZFR->(!EOF())

					If !ZFR->(MsRLock(ZFR->(RECNO())))

						//u_itconout(" Muro de Pedido de Vendas em uso: "+AllTrim(U_ALTERA:PEDIDO)+"."+" - "+DTOC(DATE())+" - "+TIME())
						_cErro := "SUCESSO:FALSE; Muro Pedido de Vendas em uso: "+AllTrim(U_ALTERA:PEDIDO)+"."
						_ltravou := .F.

					Else

						If  _lIT_LOCKPD

							ZFR->(MSUNLOCKALL())
							ZFR->(Msunlock())

						Endif

					Endif

					ZFR->(Dbskip())

				Enddo

			Endif


		Endif

		IF ASCAN(aTabelas,"SC5") <>  0

			If !SC5->(MsRLock(SC5->(RECNO())))

				//u_itconout(" Pedido de Vendas em uso: "+AllTrim(U_ALTERA:PEDIDO)+"."+" - "+DTOC(DATE())+" - "+TIME())
				_cErro := "SUCESSO:FALSE; Pedido de Vendas em uso: "+AllTrim(U_ALTERA:PEDIDO)+"."
				_ltravou := .F.

			Else

				If  _lIT_LOCKPD

					SC5->(MSUNLOCKALL())
					SC5->(Msunlock())
					Reclock("SC5",.F.)

				Endif

			Endif

		Endif

		IF ASCAN(aTabelas,"SA1") <>  0

			SA1->(Dbsetorder(1))
			SA1->(Dbseek(SA1->(xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)))
			If  !SA1->(MsRLock(SA1->(RECNO())))

				//u_itconout(" Cliente em uso: "+AllTrim(SC5->C5_CLIENTE + "/" + SC5->C5_LOJACLI)+"."+" - "+DTOC(DATE())+" - "+TIME())
				_cErro := "SUCESSO:FALSE; Cliente em uso: "+AllTrim(SC5->C5_CLIENTE + "/" + SC5->C5_LOJACLI)+"."
				_ltravou := .F.

			Else

				If  _lIT_LOCKPD

					SA1->(MSUNLOCKALL())
					SA1->(Msunlock())
					Reclock("SA1",.F.)

				Endif

			Endif

		Endif

		IF ASCAN(aTabelas,"SC6") <>  0 .OR. ASCAN(aTabelas,"SB2") <>  0

			SC6->(Dbsetorder(1))
			SC6->(Dbgotop())
			SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))

			Do while SC6->C6_NUM == SC5->C5_NUM .AND. SC5->C5_FILIAL == SC6->C6_FILIAL .AND. SC6->(!EOF())


				IF ASCAN(aTabelas,"SC6") <>  0
					If !SC6->(MsRLock(SC6->(RECNO())))

						//u_itconout(" Item do pedido em uso: "+AllTrim(SC6->C6_FILIAL+"/"+SC6->C6_PRODUTO+"/"+SC6->C6_LOCAL)+"."+" - "+DTOC(DATE())+" - "+TIME())
						_cErro := "SUCESSO:FALSE; Item do pedido em uso: "+AllTrim(SC6->C6_FILIAL+"/"+SC6->C6_PRODUTO+"/"+SC6->C6_LOCAL)+"."
						_ltravou := .F.

					Else

						If  _lIT_LOCKPD

							SC6->(MSUNLOCKALL())
							SC6->(Msunlock())

						Endif

					Endif
				Endif

				IF ASCAN(aTabelas,"SB2") <>  0

					SB2->(Dbsetorder(1))
					SB2->(Dbseek(SC6->C6_FILIAL+SC6->C6_PRODUTO+SC6->C6_LOCAL))

					If !SB2->(MsRLock(SB2->(RECNO())))

						//u_itconout("Produto em uso: "+AllTrim(SC6->C6_FILIAL+"/"+SC6->C6_PRODUTO+"/"+SC6->C6_LOCAL)+"."+" - "+DTOC(DATE())+" - "+TIME())
						_cErro := "SUCESSO:FALSE; Produto em uso: "+AllTrim(SC6->C6_FILIAL+"/"+SC6->C6_PRODUTO+"/"+SC6->C6_LOCAL)+"."
						_ltravou := .F.

					Else

						If  _lIT_LOCKPD

							SB2->(MSUNLOCKALL())
							SB2->(Msunlock())

						Endif

					Endif
				Endif

				SC6->(DbSkip())

			Enddo

		Endif

		Sleep(100) //Segura o processamento para testar no máximo 10 vezes por segundo os travamentos

	Enddo

Return _ltravou

/*
===============================================================================================================================
Programa----------: AOMS74v()
Autor-------------: Julio de Paula PAz
Data da Criacao---: 04/07/2019
Descrição---------: Função de validação das condições de pagamento. É uma versão customizada da validação padrão.
              
      Validação Padrão:
      -----------------
      Campo:     C5_CONDPAG
      Validação: ExistCpo("SE4").And.A410AcrFin().And.MaVldTabPrc(M->C5_I_TAB,M->C5_CONDPAG,,M->C5_EMISSAO) .And. A410Recalc()                  

Parametros--------: Nenhum
Retorno-----------: _lRet .T. / .F. 
===============================================================================================================================
*/
User Function AOMS074v()
	Local _lRet := .T.
	Local _lValid := .T.

	Begin Sequence
		_lValid := ExistCpo("SE4")

		If ! _lValid
			_lRet := .F.
		EndIf

		_lValid := A410AcrFin()

		If ! _lValid
			_lRet := .F.
		EndIf

		If IsInCallStack("U_ALTERAP")
			M->C5_I_TAB := _cCodTab
		EndIf

		_lValid := MaVldTabPrc(M->C5_I_TAB,M->C5_CONDPAG,,M->C5_EMISSAO)

		If ! _lValid
			_lRet := .F.
		EndIf

		_lValid := A410Recalc()

		If ! _lValid
			_lRet := .F.
		EndIf

	End Sequence

Return _lRet

//=================================================================================
// WebService de Integração Vale Pedágio.
//=================================================================================
WSMETHOD U_INTVLPED WSRECEIVE U_VALEPED WSSEND U_STATUS WSSERVICE U_AOMS074
	Local _lRet := .T.
	Local _nI
	Local _cMsg := ""
	Local _cfilial := '01'
	Local _aFilial
	Local _cFilVlPed

	Begin Sequence

		//U_ItConOut("Integração Vale Pedágio RDC: "+U_VALEPED:PLACA1+" - "+DTOC(DATE())+" - "+TIME())

		//=====================================================================
		// Limpa o ambiente, liberando a licença e fechando as conexões
		//=====================================================================
		RpcClearEnv()
		RpcSetType(2)

		//===========================================================================================
		// Preparando o ambiente com a filial da carga recebida
		//===========================================================================================
		//u_itconout("Preparando ambiente. Integração Vale Pedágio RDC.")

		//PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01';
			//        TABLES "SA7","SB1","SB2","SB5","SB8","SBJ","SB9","SBE","SBF","SC0","SD5","SBK","SD7","SDC","SF4","SGA","SM2","SDA","SDB","SBM","ADA","SA2","DAK","DAI","DA4","ZFU","ZFV","SC9","SA1","SC5","SC6", "SA1" ,"ZP1","SX6","SX1","SX2","SX3","SM0", "SIX" ;
			//        MODULO 'OMS'
		RpcSetEnv("01", "01",,,,, {"SA7","SB1","SB2","SB5","SB8","SBJ","SB9","SBE","SBF","SC0","SD5","SBK","SD7","SDC","SF4","SGA","SM2","SDA","SDB","SBM","ADA","SA2","DAK","DAI","DA4","ZFU","ZFV","SC9","SA1","SC5","SC6", "SA1" ,"ZP1","SX6","SX1","SX2","SX3","SM0", "SIX"})

		cFilAnt := _cfilial

		_cFilVlPed := U_ITGETMV( 'IT_FILVLPD' , "")

		//===========================================================================================
		// Valida CNPJ Embarcador/Fabrica.
		//===========================================================================================
		_aFilial := FwLoadSM0()

		If Empty(U_VALEPED:CNPJEM) .Or. Ascan(_aFilial,{|x| x[18] = U_ITKEY(U_VALEPED:CNPJEM, "A2_CGC")}) == 0
			//u_itconout("CNPJ Embarcador não preenchido, ou não está cadastrado. ")
			_cMsg += " CNPJ Embarcador não preenchido, ou não está cadastrado. "
			Break
		Else
			_nI := Ascan(_aFilial,{|x| x[18] = U_ITKEY(U_VALEPED:CNPJEM, "A2_CGC")})
			_cFilial := _aFilial[_nI,5]
		EndIf

		If ! Empty(_cMsg)
			Break
		EndIf

		If ! (_cFilial $ _cFilVlPed)
			_cMsg += " O CNPJ Embarcador informado não faz parte das unidades que validam vale pedágio nas cargas. "
			Break
		EndIf

		//=====================================================================
		// Limpa o ambiente, liberando a licença e fechando as conexões
		//=====================================================================
		RpcClearEnv()
		RpcSetType(2)

		//===========================================================================================
		// Preparando o ambiente com a filial da carga recebida
		//===========================================================================================
		//PREPARE ENVIRONMENT EMPRESA '01' FILIAL _cfilial; //USER 'Administrador' PASSWORD '' ;
			//        TABLES "SA7","SB1","SB2","SB5","SB8","SBJ","SB9","SBE","SBF","SC0","SD5","SBK","SD7","SDC","SF4","SGA","SM2","SDA","SDB","SBM","ADA","SA2","DAK","DAI","DA4","ZFU","ZFV","SC9","SA1","SC5","SC6", "SA1" ,"ZP1","SX6","SX1","SX2","SX3","SM0", "SIX" ;
			//        MODULO 'OMS'
		RpcSetEnv("01", "01",,,,, {"SA7","SB1","SB2","SB5","SB8","SBJ","SB9","SBE","SBF","SC0","SD5","SBK","SD7","SDC","SF4","SGA","SM2","SDA","SDB","SBM","ADA","SA2","DAK","DAI","DA4","ZFU","ZFV","SC9","SA1","SC5","SC6", "SA1" ,"ZP1","SX6","SX1","SX2","SX3","SM0", "SIX"})

		cFilAnt := _cfilial

		//===========================================================================================
		// Processando a integração Vale Pedagio.
		//===========================================================================================
		DAK->(DbSetOrder(1)) // DAK_FILIAL+DAK_COD+DAK_SEQCAR

		// U_ITKEY(_cDado, Campo_SX3)

		//U_ItConOut(" Integração Vale Pedágio via RDC, Carga: " + U_VALEPED:NRSOLI+" - "+DTOC(DATE())+" - "+TIME())

		//===================================================================================
		// Valida se os dados enviados pela RDC estão corretos.
		//===================================================================================
		DAK->(Dbsetorder(1))
		If Empty(U_VALEPED:NRSOLI)
			_cMsg += " Código de carga RDC não preenchido. "
		ElseIf ! DAK->(DbSeek(_cFilial+U_ITKEY(U_VALEPED:NRSOLI, "DAK_COD")))
			_cMsg += " Código de carga RDC não localizada. "
		EndIf



		DA3->(DbSetOrder(3)) // DA3_FILIAL+DA3_PLACA
		If ! DA3->(MsSeek(xFilial("DA3")+U_ITKEY(U_VALEPED:PLACA1, "DA3_PLACA")))
			DA3->(DbSetOrder(6)) //  DA3_FILIAL+DA3_I_PLCV
			If ! DA3->(MsSeek(xFilial("DA3")+U_ITKEY(U_VALEPED:PLACA1, "DA3_PLACA")))
				_cMsg += " Placa de veículo não localizada no Protheus. "
			EndIf
		EndIf

		If Empty(U_VALEPED:DTCOMPRA)            // Data da compra do vale pedágio
			_cMsg += " Data da compra do vale pedágio não preenchida. "
		EndIf

		If Empty(U_VALEPED:HRCOMPRA)            // Hora da compra do vale pedágio
			_cMsg += " Hora da compra do vale pedágio não preenchida. "
		EndIf

		If Empty(U_VALEPED:NRCOMPRA)            // Número do recibo do vale pedágio
			_cMsg += " Número do recibo do vale pedágio não preenchido. "
		EndIf

		If Empty(U_VALEPED:CODUSU)              // Usuário que relizou a compra do vale pedágio
			_cMsg += " Usuário que relizou a compra do vale pedágio não preenchido. "
		EndIf

		If ! Empty(_cMsg)
			Break
		EndIf

		If U_VALEPED:ACAO == 1 // 1 = Compra de Vale Pedagio // 2 = Cancelamento de Vale Pedagio
			If DAK->DAK_FEZNF == "1" // Sim // 2=Não
				_cMsg += " Carga já faturada. "
			Else
				DAK->(RecLock("DAK",.F.))
				DAK->DAK_I_DCVP  := U_VALEPED:DTCOMPRA            // Data da compra do vale pedágio
				DAK->DAK_I_HCVP  := U_VALEPED:HRCOMPRA            // Hora da compra do vale pedágio
				DAK->DAK_I_NRVP  := U_VALEPED:NRCOMPRA            // Número do recibo do vale pedágio
				DAK->DAK_I_USVP  := StrZero(U_VALEPED:CODUSU, 10) // Usuário que relizou a compra do vale pedágio
				DAK->(MsUnlock())
			EndIf
		Else
			If DAK->DAK_FEZNF == "1" // Sim // 2=Não
				_cMsg += " Carga já faturada. "
			Else
				DAK->(RecLock("DAK",.F.))
				DAK->DAK_I_DCVP  := CTOD("  /  /  ")       // Data da compra do vale pedágio
				DAK->DAK_I_HCVP  := ""                     // Hora da compra do vale pedágio
				DAK->DAK_I_NRVP  := ""                     // Número do recibo do vale pedágio
				DAK->DAK_I_USVP  := ""                     // Usuário que relizou a compra do vale pedágio
				DAK->(MsUnlock())
			EndIf
		EndIf

	End Sequence

// WSDATA CNPJEM   as STRING 
// WSDATA NRVIAG   as INTEGER 
// WSDATA NRSOLI   as STRING 
// WSDATA CODUSU   as INTEGER 
// WSDATA PLACA1   as STRING
// WSDATA PEDAGIO  as FLOAT
// WSDATA DTCOMPRA as DATE
// WSDATA HRCOMPRA as STRING
// WSDATA NRCOMPRA as STRING
// WSDATA ACAO     as INTEGER

//===========================================================================================
// Retorna resposta para o WebService.
//===========================================================================================
	If Empty(_cMsg)
		::U_STATUS := "SUCESSO:TRUE; Integração vale pedagio Protheus x RDC realizado com sucesso. "
	Else
		::U_STATUS := "SUCESSO:FALSE; " + _cMsg
	EndIf

//===========================================================================================
// Grava tabela de muro com os dados Recebidos do WebService.
//===========================================================================================
	ZBJ->(RecLock("ZBJ",.T.))
	ZBJ->ZBJ_FILIAL := xFilial("ZBJ")
	ZBJ->ZBJ_CNPJEM := U_VALEPED:CNPJEM
	ZBJ->ZBJ_NRVIAG := U_VALEPED:NRVIAG
	ZBJ->ZBJ_NRCARG := U_VALEPED:NRSOLI
	ZBJ->ZBJ_PLACA1 := U_VALEPED:PLACA1
	ZBJ->ZBJ_VLPEDA := U_VALEPED:PEDAGIO
	ZBJ->ZBJ_DTCOMP := U_VALEPED:DTCOMPRA
	ZBJ->ZBJ_HRCOMP := U_VALEPED:HRCOMPRA
	ZBJ->ZBJ_NRRECB := U_VALEPED:NRCOMPRA
	ZBJ->ZBJ_SOLUC  := U_VALEPED:SOLUCAO
	ZBJ->ZBJ_ACAOIT := U_VALEPED:ACAO
	ZBJ->ZBJ_CODUSR := U_VALEPED:CODUSU
	ZBJ->ZBJ_DTINTE := Date()
	ZBJ->ZBJ_HRINTE := Time()
	ZBJ->ZBJ_RETORN := ::U_STATUS

	If Empty(_cMsg)
		ZBJ->ZBJ_SITUAC := "R"
	Else
		ZBJ->ZBJ_SITUAC := "P"
	EndIf

	ZBJ->(MsUnLock())

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS74Y()
Autor-------------: Julio de Paula PAz
Data da Criacao---: 08/06/2022
Descrição---------: Retorna a ultima sequencia da ocorrência de Frete para a nota fiscal.
Parametros--------: _cFilial    = Filial da ocorrencia
                    _cDocumento = Numero da Nota Fiscal
                    _cSerie     = Serie da Nota Fiscal
Retorno-----------: _cRet = Sequencia do ZF5
===============================================================================================================================
*/
User Function AOMS074Y(_cFilial,_cDocumento,_cSerie)
	Local _nRegAtu
	Local _cRet := "000000"
	Local _cSeq

	Begin Sequence
		_nRegAtu := ZF5->(Recno())
		_cSeq    := "000000"

		ZF5->(DbSetOrder(4)) // ZF5_FILIAL+ZF5_DOCOC+ZF5_SEROC+ZF5_CODIGO
		ZF5->(MsSeek(_cFilial +_cDocumento + _cSerie))
		Do While ! ZF5->(Eof()) .And. ZF5->(ZF5_FILIAL+ZF5_DOCOC+ZF5_SEROC) == _cFilial +_cDocumento + _cSerie
			If ZF5->ZF5_CODIGO > _cSeq
				_cSeq := ZF5->ZF5_CODIGO
			EndIf

			ZF5->(DbSkip())
		EndDo

		_cRet := _cSeq

	End Sequence

	ZF5->(DbGoto(_nRegAtu))

Return _cRet
