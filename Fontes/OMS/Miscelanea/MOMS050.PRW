/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
  Autor      |   Data   |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Jerry        | 05/01/23 | Chamado 42427. Retirado envio com Copia. 
Jerry        | 07/03/23 | Chamado 43214. Ajustar Retorno para quando existir um Reenvio pendente nao gravar aprovação. 
Jerry        | 10/04/23 | Chamado 43503. Ajustar para mostrar no HTML o Preço Net que constar no campo ZW_I_PRNET. 
Jerry        | 09/05/23 | Chamado 43585. Adicionar na Pag Principal informaçao de % de Leite Magro. 
Jerry        | 04/07/23 | Chamado 44382. Ajuste Gravação Data/Hora Aprov e no htm de pedido. 
Jerry        | 26/07/23 | Chamado 44382. Ajuste Gravação Motivo de Recusa e Data/Hora Aprov. Coord. 
Igor Melgaço | 22/11/23 | Chamado 44051. Ajuste para inclusão do campo Preço netto por Kg.
Alex Wallauer| 10/01/23 | Chamado 46034. Jerry. Ajuste p/ quando o coordenador e gerente são o mesmo já aprovar o gerente.
Alex Wallauer| 08/02/24 | Chamado 44782. Jerry. Ajustes para a nova opcao de tipo de entrega: O = Agendado pelo Op.Log.
Alex Wallauer| 28/02/24 | Chamado 46249. Vanderlei. Correção de ERROR.LOG. 
Igor Melgaço | 12/03/24 | Chamado 45575. Ajuste para conversão de texto do Assunto do email em padrao UTF8.
Alex Wallauer| 29/07/24 | Chamado 48024. Jerry. Retirado os IFs de testes para enviar e-mail para os sistema.
Igor Melgaço | 01/07/24 | Chamado 47184 - Ajuste para gravação do campo ZW_I_PRMP
Jerry        | 29/01/25 | Chamado 49752 - Ajuste regra para validar se Coordenador utilizar Portal Novo (A3_I_WF = 3)
Lucas Borges | 23/07/25 | Chamado 51340. Ajustar função para validação de ambiente de teste
Lucas Borges | 01/08/25 | Chamado 51453. Substituir função U_ITEncode por FWHttpEncode
================================================================================================================================================================================================
Analista      - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
================================================================================================================================================================================================
Jerry         - Julio Paz     - 08/04/25 - 11/04/25 - 49837   - Inclusão da nova Tag ITEMKITPORTAL e gravação nos campos ZW_KIT e C6_I_KIT. Alterar as validações para utilizar estes campos.
Lucas         - Alex Wallauer - 11/08/25 - 12/08/25 - 51742   - Retirada da gravação da TAG CRESPPED pq ela não existe nos htmls [\workflow\htm\libportal_prc.htm / libportal_bon.HTM].
================================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "rwmake.ch"
#include "ap5mail.ch"
#include "tbiconn.ch"
#include "protheus.ch"
#include "topconn.ch"
#DEFINE CRLF CHR(13)+CHR(10)

Static cEnvSrv	  := Upper(GetEnvServer())

/*
===============================================================================================================================
Programa----------: MOMS050 / U_MOMS050
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 13/03/2020
===============================================================================================================================
Descrição---------: Rotina responsavel pelo envio de workflow de liberação de preço Pedido de Vendas.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS050()
	Local _lWFHTML		:= .T.
	Local _aPedidos     := {} //RECNO DOS PEDIDOS BLOQUEADOS
	Local _aAprov       := {} //LISTA DE EMAIL DOS COORDENADORES
	Local _nX           := 0
	Local _nZ           := 0
	Local aTables       := {"SZW","SA3","ZGT","SB1","SF4","ZAY","DA1","SC6"}
	Local _cLinkG       := ""
	Local _cCoord       := ""
	Local _cGerente     := ""
	Local _cCoordWF     := "1"  //1-Envia WF / 2-Não Envia WF
	Local _cAprovador   := ""
	Local _lSimplNac    := .F.
	Local _nPesoBrut    := 0
	Local _aBlqprc      := {}
	Local _lPrcErr      := .F.
	Local _lEfetiva     := .F.
	Local _nPrecoIt		:= 0
	Local _nPrecoMin    := 0

	//Local _nFaixa       := 0
	Private _cHostWF	:= ""
	Private _cAprPreco  := ""
	Private _cEmaisEnv	:= ""
	Private _LExecSelect:= .T.
	Private _oDlg
	Private _cGetSol    := "Preço fora da tabela"

	IF Select ("SX3") == 0
		RPCSetType(3)
		RpcSetEnv("01","01" ,,,, "SCHEDULE_WF_PORTAL", aTables )
		sleep( 5000 )

		_lEfetiva := U_ITGETMV( "IT_EFETV112",.T.)

		If _lEfetiva
  			U_SOMS112S(.F.) //Efetivação Automática
		EndIF

 	    MOMS050REC() // Recusar pedido com mais de 24 horas sem Liberação ou sem Aprovação

		_aPedidos := RetBloq("N") //Pego todos os recnos dos pedidos a processar
 
		IF LEN(_aPedidos) >= 1
			FOR _nX := 1 TO LEN(_aPedidos)
			    _nPrecoIt  := 0
                _nPrecoMin := 0
				SZW->(DBGOTO(_aPedidos[_nX]))
				SA1->(Dbsetorder(1))
				SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))
				If SA1->A1_SIMPNAC == "1"
					_lSimplNac := .T. // O cliente é optante do Simples Nacional
				Else
					_lSimplNac := .F. // O cliente não é Optante do Simples Nacional
				EndIf

				_cCoord     := POSICIONE("SA3",1,xFilial("SA3")+SZW->ZW_VEND1,"A3_SUPER")
				_cGerente   := SA3->A3_GEREN
				_cCoordWF   := POSICIONE("SA3",1,xFilial("SA3")+_cCoord,"A3_I_WF")

				_nPesoBrut  := MOMS050PESO(SZW->ZW_FILIAL,SZW->ZW_IDPED)

				If SZW->ZW_TIPO == "10" .Or. ! Empty(SZW->ZW_KIT)  
				   _lPrcErr := .F.
				Else
				   _aBlqprc := U_BLQPRC(SZW->ZW_PRODUTO,SZW->ZW_PRCVEN,SZW->ZW_FILIAL,  .F. ,SZW->ZW_TABELA,    .T.,      .T.,          0,           ,         ,SA1->A1_EST,         ,SZW->ZW_TPVENDA,_lSimplNac,_nPesoBrut,SZW->ZW_I_FXPES)
				   _lPrcErr := _aBlqprc[1]
				   _nPrecoIt:= _aBlqprc[4]
                   _nPrecoMin := _aBlqprc[5]
				EndIf
				//_nFaixa  := _aBlqprc[2]
				//---------------------------------------------------
				// _cCoordWF = 1 - Pedido Nao precisa Liberar no Portal pelo Coordenador
				// _cCoordWF = 2 - Pedido Precisa da Liberação no Portal pelo Coordenador
				//---------------------------------------------------			
 
 				If _cCoordWF == "1" .And. SZW->ZW_STATUS = "A" .And. EMPTY(SZW->ZW_ENVWF)

					IF _lPrcErr
						SZW->(RECLOCK("SZW",.F.))
						SZW->ZW_BLOPRC  := "B"
						SZW->ZW_STATUS  := "P" //tem q ser P
						SZW->ZW_DATAAPR := DATE()
						SZW->ZW_HORAAPR := TIME()
						SZW->ZW_NIVELWF := "E"  //E-Enviado WF
						SZW->ZW_ENVWF   := "C"
						SZW->ZW_IMPRIME := '1'
						SZW->ZW_PRUNIT  := _nPrecoIt
		                  If SZW->ZW_I_PRMP  = 0
		                     SZW->ZW_I_PRMP  := _nPrecoMin
		                  EndIf
						SZW->(MsUnLock())
						_cAprovador:= _cCoord
					ELSE
						SZW->(RECLOCK("SZW",.F.))
						SZW->ZW_BLOPRC := " "
						SZW->ZW_STATUS := "L"
						SZW->ZW_DATAAPR := DATE()
						SZW->ZW_HORAAPR := TIME()
						SZW->ZW_NIVELWF := "P"  //P-Processado
						SZW->ZW_ENVWF := "C"
						SZW->ZW_IMPRIME := '1'
						SZW->ZW_PRUNIT  := _nPrecoIt
		                  If SZW->ZW_I_PRMP  = 0
		                     SZW->ZW_I_PRMP  := _nPrecoMin
		                  EndIf
						SZW->(MsUnLock())
					ENDIF
				ElseIf ( _cCoordWF == "2" .OR.  _cCoordWF == "3" )  //1o Liberado pelo Coord. no Portal antigo
					If SZW->ZW_STATUS == "A" .And. Empty(SZW->ZW_ENVWF)
						SZW->(RECLOCK("SZW",.F.))
						SZW->ZW_NIVELWF := "P"  //P-Processado
						SZW->ZW_ENVWF   := "C"
						If _cCoordWF == "3"
							SZW->ZW_STATUS := "L"		
						EndIf
						SZW->(MsUnLock()) 
					ELSEIF SZW->ZW_STATUS == "L" .And. SZW->ZW_ENVWF <> "G"
						IF _lPrcErr
							SZW->(RECLOCK("SZW",.F.))
							SZW->ZW_STATUS  := "P"
							SZW->ZW_BLOPRC  := "B"
							SZW->ZW_DATAAPR := DATE()
							SZW->ZW_HORAAPR := TIME()
							SZW->ZW_NIVELWF := "E"  //E-Enviado WF
							SZW->ZW_ENVWF   := "G"
							SZW->ZW_IMPRIME := '1'
							SZW->ZW_PRUNIT  := _nPrecoIt												
		                     If SZW->ZW_I_PRMP  = 0
		                        SZW->ZW_I_PRMP  := _nPrecoMin
		                     EndIf		
							SZW->(MsUnLock())
							_cAprovador:= _cGerente
						ELSE
							SZW->(RECLOCK("SZW",.F.))
							SZW->ZW_BLOPRC  := " "
							SZW->ZW_STATUS  := "L"
							SZW->ZW_DATAAPR := DATE()
							SZW->ZW_HORAAPR := TIME()
							SZW->ZW_NIVELWF := "P"  //P-Processado
							SZW->ZW_ENVWF   := "G"
							SZW->ZW_IMPRIME := '1'
							SZW->ZW_PRUNIT  := _nPrecoIt												
		                     If SZW->ZW_I_PRMP  = 0
		                        SZW->ZW_I_PRMP  := _nPrecoMin
		                     EndIf 
						SZW->(MsUnLock())
						ENDIF
					ENDIF
				Endif

				IF (nPos:=aScan(_aAprov, {|x| x[5] == SZW->ZW_IDPED })) == 0 .AND. SZW->ZW_BLOPRC == "B"
					Aadd(_aAprov, { SZW->ZW_FILIAL                                   ,;
						SZW->ZW_VEND1                                                ,;
						SZW->ZW_ENVWF  ,;
						POSICIONE("SA3",1, xFilial("SA3")+_cAprovador, "A3_EMAIL") ,; //Quando for testar, comente o posicione e coloque o e-mail fixo.
					SZW->ZW_IDPED                                                ,;
						_aPedidos[_nX]                                               ,;
						_cAprovador,;
						SZW->ZW_TIPO})
				ENDIF
			NEXT _nX

			_cHostWF 	:= U_ItGetMv("IT_WFHOSTS","http://wfteste.italac.com.br:4043/")
			_lWFHTML	:= GetMv("MV_WFHTML")

			PutMV("MV_WFHTML",.T.)
			DbSelectArea("SZW")
			SZW->(DBSETORDER(1))

			FOR _nZ := 1 TO LEN(_aAprov)
				SZW->(dbSeek(_aAprov[_nZ][1]+_aAprov[_nZ][5]))

				If _aAprov[_nZ][8] == "10"
					_cLinkG := U_MOMS050B(_aAprov[_nZ][1],_aAprov[_nZ][2], _aAprov[_nZ][3],_aAprov[_nZ][4], _aAprov[_nZ][5], _aAprov[_nZ][6]," ",_aAprov[_nZ][7]    ) //Envia e-mail para aprovação de preço
				Else
					_cLinkG := U_MOMS050O(_aAprov[_nZ][1],_aAprov[_nZ][2], _aAprov[_nZ][3],_aAprov[_nZ][4], _aAprov[_nZ][5], _aAprov[_nZ][6]," ",_aAprov[_nZ][7]    ) //Envia e-mail para aprovação de preço
				EndIf

				AtuSzw(_aAprov[_nZ][1],_aAprov[_nZ][5],_aAprov[_nZ][3], _cLinkG, "B") //Atualização de informações referente o envio de e-mail para aprovação.

				//GrVLZGT(_aAprov[_nZ][1],_aAprov[_nZ][2], Date(), "E", "C", _cLinkG,_aAprov[_nZ][5]) // Gravo logo de envio para o coordenador

			NEXT _nZ
		ENDIF

		//inicio BONIFICACAO
		_aPedidos :=  {}
		_aPedidos := RetBloq('B') //Busca todos os recnos dos pedidos de Bonificação a processar

		IF LEN(_aPedidos) >= 1
			FOR _nX := 1 TO LEN(_aPedidos)
				SZW->(DBGOTO(_aPedidos[_nX]))
				SA1->(Dbsetorder(1))
				SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))

				_cCoord     := POSICIONE("SA3",1,xFilial("SA3")+SZW->ZW_VEND1,"A3_SUPER")
				_cGerente   := SA3->A3_GEREN
				_cCoordWF   := POSICIONE("SA3",1,xFilial("SA3")+_cCoord,"A3_I_WF")

				If _cCoordWF == "1" .And. SZW->ZW_BLOQ = " " .And. EMPTY(SZW->ZW_ENVWF)

						SZW->(RECLOCK("SZW",.F.))
						SZW->ZW_BLOQ    := "B" //Bloqueio Bonificação
						SZW->ZW_DATAAPR := DATE()
						SZW->ZW_HORAAPR := TIME()
						SZW->ZW_NIVELWF := "E"  //E-Enviado WF
						SZW->ZW_ENVWF   := "C"
						SZW->ZW_IMPRIME := '1'
						SZW->(MsUnLock())
						_cAprovador:= _cCoord

				ElseIf ( _cCoordWF == "2" .OR.  _cCoordWF == "3" )  .And. SZW->ZW_BLOQ == " " .And. SZW->ZW_ENVWF <> "G" //1o Liberado pelo Coord. no Portal antigo
 
						SZW->(RECLOCK("SZW",.F.))
						SZW->ZW_BLOQ    := "B" //Bloqueio Bonificação
						SZW->ZW_DATAAPR := DATE()
						SZW->ZW_HORAAPR := TIME()
						SZW->ZW_NIVELWF := "E"  //E-Enviado WF
						SZW->ZW_ENVWF   := "G"
						SZW->ZW_IMPRIME := '1'
						If _cCoordWF == "3"
							SZW->ZW_STATUS := "L"		
						EndIf
						SZW->(MsUnLock())
						_cAprovador:= _cGerente
				Endif

				IF (nPos:=aScan(_aAprov, {|x| x[5] == SZW->ZW_IDPED })) == 0 .AND. SZW->ZW_BLOQ == "B"
					Aadd(_aAprov, { SZW->ZW_FILIAL                                   ,;
						SZW->ZW_VEND1                                                ,;
						SZW->ZW_ENVWF  ,;
						POSICIONE("SA3",1, xFilial("SA3")+_cAprovador, "A3_EMAIL") ,; //Quando for testar, comente o posicione e coloque o e-mail fixo.
					SZW->ZW_IDPED                                                ,;
						_aPedidos[_nX]                                               ,;
						_cAprovador,;
						SZW->ZW_TIPO})
				ENDIF
			NEXT _nX

			_cHostWF 	:= U_ItGetMv("IT_WFHOSTS","http://wfteste.italac.com.br:4043/")
			_lWFHTML	:= GetMv("MV_WFHTML")

			PutMV("MV_WFHTML",.T.)
			DbSelectArea("SZW")
			SZW->(DBSETORDER(1))

			FOR _nZ := 1 TO LEN(_aAprov)
				SZW->(dbSeek(_aAprov[_nZ][1]+_aAprov[_nZ][5]))

			 
				_cLinkG := U_MOMS050B(_aAprov[_nZ][1],_aAprov[_nZ][2], _aAprov[_nZ][3],_aAprov[_nZ][4], _aAprov[_nZ][5], _aAprov[_nZ][6]," ",_aAprov[_nZ][7]    ) //Envia e-mail para aprovação de preço

				AtuSzw(_aAprov[_nZ][1],_aAprov[_nZ][5],_aAprov[_nZ][3], _cLinkG, "B") //Atualização de informações referente o envio de e-mail para aprovação.

			NEXT _nZ
		ENDIF

		//Fim Bonificacao
		RPCClearEnv()
	ENDIF

Return 

/*
===============================================================================================================================
Programa----------: MOMS050R
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 13/03/2020
===============================================================================================================================
Descrição---------: Rotina responsável pela execução do retorno do workflow
===============================================================================================================================
Parametros--------: _oProcess - Processo inicializado do workflow
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS050R( _oProcess )

	Local _cFilial		:= SubStr(_oProcess:oHtml:RetByName("cFilPV"),1,2)
	Local _cNumPV		:= _oProcess:oHtml:RetByName("cNumPV")
	Local _cOpcao		:= IF("APROVAR" $ UPPER(_oProcess:oHtml:RetByName("OPCAO")), "APROVADO", "REJEITADO")//na variavel vem escrito "APROVAR (Aguarde...)"
	Local _cCodSol		:= _oProcess:oHtml:RetByName("cCodSol")
	Local _cObsAprov	:= AllTrim(SubStr(UPPER(_oProcess:oHtml:RetByName("CR_OBS")),1,100))
	Local _cArqHtm		:= SubStr(_oProcess:oHtml:RetByName("WFMAILID"),3,Len(_oProcess:oHtml:RetByName("WFMAILID")))
	Local _cTipRet		:= ALLTRIM(_oProcess:oHtml:RetByName("CTIPOPER"))
	Local _cHtmlMode	:= "\Workflow\htm\pv_concluido.htm"
	Local _cCodApr		:= _oProcess:oHtml:RetByName("cCodApr")
	Local _cCliente		:= ""
	Local _lSoAprovador :=.F.
	Local _aAvaliacao   :={}
	Local _aMail        :={}
	Local _cEmailGeren  := ""
	Local _cEmailAprov  := ""
	Local _cNomeAprov   := ""
	Local _cTipv        := ""
	Local _cGeren       := ""
	Local _nRec
	Local _cLink        := ""
	Local _cObs         := _cObsAprov
	Local aTables       := {"SZW","SA3","ZGT","SB1","SF4","ZAY","DA1","SC6","SX2","SX3","SX6","WFA"}

	RPCSetType(3)
	RpcSetEnv("01","01" ,,,, "SCHEDULE_WF_APROVACAO_BLPRE", aTables )
	sleep( 5000 )

	dbSelectArea("SA3")
	dbSetOrder(1)
	dbSeek(xFilial("SA3") + _cCodApr )

	_cTipv       := SA3->A3_I_TIPV
	_cEmailAprov := SA3->A3_EMAIL
	_cNomeAprov  := SA3->A3_NOME
	_cCPF        := AllTrim(SA3->A3_CGC)
	_cGeren      := SA3->A3_GEREN
	_cCPFGeren   := AllTrim(POSICIONE("SA3",1,xFilial("SA3")+_cGeren,"A3_CGC"))
	_lMesmoAprov :=(_cCPF == _cCPFGeren)//O coordenador e gerente são a mesma pessoa
	
	dbSeek(xFilial("SA3") + _cCodApr )//REPOSICIONA no aprovador por causa do POSICIONE

	Aadd(_aMail, _cEmailAprov )
	Aadd(_aMail, POSICIONE("SA3",1, xFilial("SA3")+_cCodSol, "A3_EMAIL"))

	dbSelectArea("SZW")
	dbSetOrder(1)
	dbSeek(_cFilial+_cNumPV)

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1") + SZW->ZW_CLIENTE + SZW->ZW_LOJACLI)
	_cCliente := SZW->ZW_CLIENTE + "/" + SZW->ZW_LOJACLI + " - " + AllTrim(SA1->A1_NOME) + " - " + AllTrim(SA1->A1_NREDUZ)

	_lSoAprovador:=.F.
	_aAvaliacao:={}

	If _cTipRet == "BONIFICACAO" .And. !EMPTY(Alltrim(SZW->ZW_I_HTML))

   		u_itconout("Retorno da Bonificação Pedido " + _cFilial + " " +  _cNumPV + " " + _cOpcao )
		If SZW->ZW_BLOQ  = "L" .OR. SZW->ZW_BLOQ = "R"

			IF SZW->ZW_BLOQ  = "L"
				_cOpcao:= "APROVADO"
				AADD(_aAvaliacao,{SZW->ZW_DTLIB,ZW->ZW_HLIBP  ,"Ja foi Aprovado"})
			ELSE
				_cOpcao:= "REJEITADO"
				AADD(_aAvaliacao,{SZW->ZW_DTLIB  ,"-----","Ja foi Rejeitado"})
			ENDIF
			_cObs:=SZW->ZW_MOTLP
			_lSoAprovador:=.T.
 
		EndIf

		SZW->(dbSeek(_cFilial+_cNumPV))
		_nRec := SZW->(RECNO())
		If  SZW->ZW_IDPED == _cNumPV .AND. SZW->ZW_FILIAL == _cFilial
			If _cOpcao == "APROVADO"

				DO WHILE SZW->(!EOF()) .AND. SZW->ZW_IDPED == _cNumPV .AND. SZW->ZW_FILIAL == _cFilial

					IF _cTipv == "G"
						RecLock("SZW",.F.)
						SZW->ZW_MLIBPRC     := _cCodApr
						SZW->ZW_BLOQ        := "L"
						SZW->ZW_ULIBP       := _cNomeAprov
						SZW->ZW_MOTLP       := "Aprovado pelo código: " + _cCodApr
						SZW->ZW_STATUS      := "L"
						SZW->ZW_IMPRIME     := '1'
						SZW->ZW_I_OBS       := _cObs
						SZW->ZW_I_HLIBG     := TIME()  // Hora Gerente
						SZW->ZW_I_DLIBG     := DATE()  // Data Gerente
						SZW->( MsUnlock() )
						SZW->(DBSKIP())
					ELSEIF _cTipv == "C"
						RecLock("SZW",.F.)
						SZW->ZW_MLIBPRC     := _cCodApr
						SZW->ZW_BLOQ        := "B"
						SZW->ZW_HLIBP       := TIME()  // Hora Coordenador
						SZW->ZW_DLIBP       := DATE()  // Data Coordenador
						SZW->ZW_ULIBP       := _cNomeAprov
						SZW->ZW_MOTLP       := "Submetido aprovação para o gerente."
						SZW->ZW_ENVWF       := 'G'
						SZW->ZW_IMPRIME     := '1'
						SZW->ZW_I_OBS       := _cObs
						SZW->ZW_I_DLIBG     :=  ctod(" / / ")
						SZW->ZW_I_HLIBG     := ""
						SZW->( MsUnlock() )
						SZW->(DBSKIP())
					ENDIF
				ENDDO
				//Verfica se deve ser submetido o envio de e-mail de aprovação para o gerente.
				IF _cTipv == "C"
					_cEmailGeren := POSICIONE("SA3",1,xFilial("SA3")+_cGeren,"A3_EMAIL")
					_cLink := U_MOMS050O(_cFilial,_cCodSol,"G",_cEmailGeren,_cNumPV,_nRec, _cObsAprov,_cGeren, _cTipv, _cObs) //Retorno - prepara o HTML para aprovacao do GERENTE
					AtuSzw(_cFilial,_cNumPV,"G", _cLink, "B")
					//GrVLZGT(_cFilial, _cGeren, Date(), "E", "G", _cLink,_cNumPV)
					//GrVLZGT(_cFilial, _cCodApr, Date(), "R", _cTipv, "",_cNumPV) //Grava log da aprovação do gerente
				ENDIF

			Else //Rejeitado
				DO WHILE SZW->(!EOF()) .AND. SZW->ZW_IDPED == _cNumPV .AND. SZW->ZW_FILIAL == _cFilial
					RecLock("SZW",.F.)
					SZW->ZW_MLIBPRC     := _cCodApr
					SZW->ZW_BLOQ        := "R"
					IF _cTipv == "C"
						SZW->ZW_HLIBP       := TIME()
						SZW->ZW_DLIBP       := DATE()
						SZW->ZW_I_DLIBG     := ctod(" / / ")
						SZW->ZW_I_HLIBG     := ""
					else
						SZW->ZW_I_DLIBG     := DATE()
						SZW->ZW_I_HLIBG     := TIME()
					End
					SZW->ZW_ULIBP       := _cNomeAprov
					SZW->ZW_MOTLP       := "Rejeitado pelo código: " + _cCodApr
					SZW->ZW_STATUS      := "R"
					SZW->ZW_IMPRIME     := '1'
					SZW->ZW_I_OBS       := _cObs
					SZW->ZW_MOTREC      := _cObsAprov

					SZW->(DBSKIP())
				ENDDO
				AtuSzw(_cFilial,_cNumPV,_cTipv, _cLink, "R") //Atualiza Pedido Rejeitado
				//GrVLZGT(_cFilial, _cCodApr, Date(), "R", _cTipv, "",_cNumPV)
				SZW->( MsUnlock() )
			EndIf
		EndIf
 
	Else

		If _cTipRet == "PRECO" .AND. (SZW->ZW_BLOPRC  = "L" .OR. SZW->ZW_BLOPRC = "R") .And. !EMPTY(Alltrim(SZW->ZW_I_HTML))

			IF SZW->ZW_BLOPRC  = "L"
				_cOpcao:= "APROVADO"
				AADD(_aAvaliacao,{SZW->ZW_DTLIB,SZW->ZW_HLIBP  ,"Ja foi Aprovado"})
			ELSE
				_cOpcao:= "REJEITADO"
				AADD(_aAvaliacao,{SZW->ZW_DTLIB  ,"-----","Ja foi Rejeitado"})
			ENDIF
			_cObs:=SZW->ZW_MOTLP
			_lSoAprovador:=.T.

		EndIf

		If _cTipRet == "PRECO" 

			SZW->(dbSeek(_cFilial+_cNumPV))
			_nRec := SZW->(RECNO())
			If  SZW->ZW_IDPED == _cNumPV .AND. SZW->ZW_FILIAL == _cFilial .And. !EMPTY(Alltrim(SZW->ZW_I_HTML))
				If _cOpcao == "APROVADO"

					DO WHILE SZW->(!EOF()) .AND. SZW->ZW_IDPED == _cNumPV .AND. SZW->ZW_FILIAL == _cFilial
						IF _cTipv == "G"
							RecLock("SZW",.F.)
							SZW->ZW_MLIBPRC     := _cCodApr
							SZW->ZW_BLOPRC      := "L"
							SZW->ZW_ULIBP       := _cNomeAprov
							SZW->ZW_MOTLP       := "Aprovado pelo código: " + _cCodApr
							SZW->ZW_STATUS      := "L"
							SZW->ZW_IMPRIME     := '1'
							SZW->ZW_I_OBS       := _cObs
							SZW->ZW_I_HLIBG     := TIME()
							SZW->ZW_I_DLIBG     := DATE()
							SZW->( MsUnlock() )
							SZW->(DBSKIP())
						ELSEIF _cTipv == "C"
							RecLock("SZW",.F.)
							SZW->ZW_MLIBPRC     := _cCodApr
							SZW->ZW_BLOPRC      := "B"
							SZW->ZW_HLIBP       := TIME()
							SZW->ZW_DLIBP       := DATE()
							SZW->ZW_ULIBP       := _cNomeAprov
							SZW->ZW_MOTLP       := "Submetido aprovação para o gerente."
							SZW->ZW_ENVWF       := 'G'
							SZW->ZW_IMPRIME     := '1'
							SZW->ZW_I_OBS       := _cObs
							SZW->ZW_I_HLIBG     := ""
							SZW->ZW_I_DLIBG     := ctod(" / / ")
						    IF _lMesmoAprov
							   SZW->ZW_BLOPRC   := "L"
							   SZW->ZW_MOTLP    := "Aprovado pelo código: " + _cCodApr+" Coord+Gerente"
							   SZW->ZW_STATUS   := "L"
							   SZW->ZW_IMPRIME  := '1'
							   SZW->ZW_I_OBS    := _cObs
                               SZW->ZW_I_HLIBG  := TIME() // Hora Gerente
                               SZW->ZW_I_DLIBG  := DATE() // Data Gerente
						    ENDIF
							SZW->( MsUnlock() )
							SZW->(DBSKIP())
						ENDIF
					ENDDO
					//Verfica se deve ser submetido o envio de e-mail de aprovação para o gerente.
					IF _cTipv == "C" .AND. !_lMesmoAprov
						_cEmailGeren := POSICIONE("SA3",1,xFilial("SA3")+_cGeren,"A3_EMAIL")
						_cLink := U_MOMS050O(_cFilial,_cCodSol,"G",_cEmailGeren,_cNumPV,_nRec, _cObsAprov,_cGeren, _cTipv,_cObs)
						AtuSzw(_cFilial,_cNumPV,"G", _cLink, "B")
						//GrVLZGT(_cFilial, _cGeren, Date(), "E", "G", _cLink,_cNumPV)
						//GrVLZGT(_cFilial, _cCodApr, Date(), "R", _cTipv, "",_cNumPV) //Grava log da aprovação do gerente
					ENDIF

				Else //Rejeitado
					DO WHILE SZW->(!EOF()) .AND. SZW->ZW_IDPED == _cNumPV .AND. SZW->ZW_FILIAL == _cFilial
						RecLock("SZW",.F.)
						SZW->ZW_MLIBPRC     := _cCodApr
						SZW->ZW_BLOPRC      := "R"
						IF _cTipv == "C"
							SZW->ZW_HLIBP       := TIME()
							SZW->ZW_DLIBP       := DATE()
							SZW->ZW_I_DLIBG     := ctod(" / / ")
							SZW->ZW_I_HLIBG     := ""
						else
							SZW->ZW_I_DLIBG     := DATE()
							SZW->ZW_I_HLIBG     := TIME()
						End
						SZW->ZW_ULIBP       := _cNomeAprov
						SZW->ZW_MOTLP       := "Rejeitado pelo código: " + _cCodApr
						SZW->ZW_STATUS      := "Q"
						SZW->ZW_IMPRIME     := '1'
						SZW->ZW_I_OBS       := _cObs
						SZW->ZW_MOTREC      := _cObsAprov
						SZW->(DBSKIP())
					ENDDO
					AtuSzw(_cFilial,_cNumPV,_cTipv, _cLink, "R") //Atualiza Pedido Rejeitado
					//GrVLZGT(_cFilial, _cCodApr, Date(), "R", _cTipv, "",_cNumPV)
					SZW->( MsUnlock() )
				EndIf
			EndIf
		EndIf
	EndIf

//==================================================
//Finalize a tarefa anterior para não ficar pendente
//==================================================
	_oProcess:Finish()

//========================================================================================
//Faz a cópia do arquivo de aprovação para .old, e cria o arquivo de processo já concluído
//========================================================================================

    u_itconout("Cópia do htm  " + _cFilial + " " +  _cNumPV + " Arquivo " + _cArqHtm )

	If File("\workflow\emp01\" + _cArqHtm + ".htm")
		If __CopyFile("\workflow\emp01\" + _cArqHtm + ".htm", "\workflow\emp01\" + _cArqHtm + ".old")
			If __CopyFile(_cHtmlMode, "\workflow\emp01\" + _cArqHtm + ".htm")
				u_itconout("Cópia de arquivo de conclusão efetuada com sucesso.")
			Else
				u_itconout("Problema na cópia de arquivo de conclusão.")
			EndIf
		Else
			u_itconout("Não foi possível renomear o arquivo " + _cArqHtm + ".htm.")
		EndIf
	EndIf

	u_itconout("Fimd da Cópia do htm  " + _cFilial + " " +  _cNumPV + " Arquivo " + _cArqHtm )

Return

/*
===============================================================================================================================
Programa----------: MOMS050CPF
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 17/03/2020
===============================================================================================================================
Descrição---------: Função criada para formatar CPF/CNPJ
===============================================================================================================================
Parametros--------: cCPFCNPJ	- Texto a ser quebrado
===============================================================================================================================
Retorno-----------: cCampFormat	- Retorna o campo formatado conforme CPF/CNPJ
===============================================================================================================================
*/
Static Function MOMS050CPF(_cCPFCNPJ)
	Local _cCampFormat := ""	//Armazena o CPF ou CNPJ formatado

	If Len(AllTrim(_cCPFCNPJ)) == 11			//CPF
		_cCampFormat:=SubStr(_cCPFCNPJ,1,3) + "." + SubStr(_cCPFCNPJ,4,3) + "." + SubStr(_cCPFCNPJ,7,3) + "-" + SubStr(_cCPFCNPJ,10,2)
	Else									//CNPJ
		_cCampFormat:=Substr(_cCPFCNPJ,1,2)+"."+Substr(_cCPFCNPJ,3,3)+"."+Substr(_cCPFCNPJ,6,3)+"/"+Substr(_cCPFCNPJ,9,4)+"-"+ Substr(_cCPFCNPJ,13,2)
	EndIf

Return(_cCampFormat)

/*
===============================================================================================================================
Programa----------: MOMS050VSC
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 17/03/2020
===============================================================================================================================
Descrição---------: Recupera saldo atual em aberto do Cliente.
===============================================================================================================================
Parametros--------: cCodCli := codigo do cliente. 
===============================================================================================================================
Retorno-----------: nValUso := valor em aberto do cliente.  
===============================================================================================================================
*/

Static Function MOMS050VSC( _cCodCli )

	Local _cAlias	:= GetNextAlias()
	Local _cQuery	:= ""
	Local _nValUso	:= 0

	Default _cCodCli	:= ""

//-- Verifica o saldo atual em aberto do Cliente --//
	_cQuery := " SELECT "
	_cQuery += "     SUM( SE1.E1_SALDO + SE1.E1_SDACRES - SE1.E1_SDDECRE ) AS VALUSO "
	_cQuery += " FROM "+ RetSqlName("SE1") +" SE1 "
	_cQuery += " WHERE "
	_cQuery += "     SE1.E1_CLIENTE	= '"+ _cCodCli +"' "
	_cQuery += " AND SE1.D_E_L_E_T_	= ' ' "
	_cQuery += " AND SE1.E1_TIPO		NOT IN ('RA','NCC') "
	_cQuery += " AND SE1.E1_SALDO + SE1.E1_SDACRES - SE1.E1_SDDECRE > 0 "

	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )

	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	If (_cAlias)->(!Eof()) .And. (_cAlias)->VALUSO > 0
		_nValUso := (_cAlias)->VALUSO
	EndIf

	(_cAlias)->( DBCloseArea() )

Return(_nValUso)

/*
===============================================================================================================================
Programa----------: MOMS050VT2
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 17/03/2020
===============================================================================================================================
Descrição---------: Recupera valor total do pedido de vendas. 
===============================================================================================================================
Parametros--------: cCodCli := codigo do cliente. 
===============================================================================================================================
Retorno-----------: nValUso := valor em aberto do cliente.  
===============================================================================================================================
*/
Static Function MOMS050VT2( _cNumPed , _cFilAux , _cCodCli , _nOpc )
	Local _aArea	:= GetArea()
	Local _cAlias	:= GetNextAlias()
	Local _cQuery	:= ""
	Local _nValPed	:= 0

	Default _cNumPed	:= ""
	Default _cFilAux	:= ""
	Default _cCodCli	:= ""
	Default _nOpc		:= 0

//================================
//Verifica o valor total do pedido
//================================
	_cQuery := " SELECT "
	_cQuery += "     SUM(SZW.ZW_QTDVEN * SZW.ZW_PRCVEN) AS VALPED "
	_cQuery += " FROM "+ RetSqlName("SZW") +" SZW "
	_cQuery += " WHERE D_E_L_E_T_ = ' ' "
	_cQuery += " AND    SZW.ZW_IDPED = '" + _cNumPed + "' "
	_cQuery += " AND	SZW.ZW_FILIAL = '" + _cFilAux + "' "

	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )

	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	If (_cAlias)->(!Eof()) .And. (_cAlias)->VALPED > 0
		_nValPed := (_cAlias)->VALPED
	EndIf

	(_cAlias)->( DBCloseArea() )

	RestArea(_aArea)

Return(_nValPed)

/*
===============================================================================================================================
Programa----------: MOMS50ML
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 17/03/2020
===============================================================================================================================
Descrição---------: Função criada para enviar e-mail ao Aprovador e ao Solicitante com o status do pedido de vendas
===============================================================================================================================
Parametros--------: _cFilial	- Filial do Pedido de Vendas
------------------: _cNumPV		- Número do Pedido de Vendas
------------------: _cOpcao		- Status de Aprovação/Rejeição
------------------: _cObs		- Observação da Aprovação/Rejeição
------------------: _cCodApr	- Código do Aprovador
------------------: _cCodSol	- Código do Solicitante
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS50ML(_cFilial, _cNumPV, _cOpcao, _cObs, _cCodApr, _cCodSol, _cTipo, _cCliente, _lSoAprovador, _aAvaliacao, cMailZY0)
	Local _cHostWF 	:= U_ItGetMv("IT_WFHOSTS","http://wfteste.italac.com.br:4034/")
	Local _cLogo	:= _cHostWF + "htm/logo_novo.jpg"
	Local _chtmfile	:= ""
	Local oProc	:= Nil
	Local _cNomeAprovador    := ""
	Local _cEmailAprovador   := ""
	Local _cEmailSolicitante := ""

	If _cTipo == "PRECO"

		_chtmfile	:= _cHostWF + "htm/pvprec_retorno.htm"
		//====================================
		//Codigo do processo cadastrado no CFG
		//====================================
		_cCodProce := "PRCPORTAL"

		//====================
		// Assunto da mensagem
		//====================

		_cAssunto := "Retorno da Solicitação da Liberação Preço Pedido Portal,  CNPJ " + _cCliente + " - " + _cFilial + " - " + AllTrim(FWFilialName(cEmpAnt, _cFilial,1)) + ' - PV ' + _cNumPV + ' - ' + '"' + _cOpcao + '"'

		//======================================================================
		// Inicialize a classe TWFProcess e assinale a variável objeto oProcess:
		//======================================================================
		oProc := TWFProcess():New(_cCodProce,"Liberação Preço P.Portal - Retorno")

		//=================================================================
		// Criamos o link para o arquivo que foi gerado na tarefa anterior.
		//=================================================================

		oProc:NewTask("SendMail", "/workflow/htm/pvprec_retorno.htm")

	EndIf

	_cNomeAprovador   := POSICIONE("SA3",1,xFilial("SA3")+_cCodApr,"A3_NOME")
	_cEmailAprovador  := POSICIONE("SA3",1,xFilial("SA3")+_cCodApr,"A3_EMAIL")
	_cTipoAprovador   := POSICIONE("SA3",1,xFilial("SA3")+_cCodApr,"A3_I_TIPV")
	_cEmailSolicitante:= POSICIONE("SA3",1,xFilial("SA3")+_cCodSol,"A3_EMAIL")

//=====================================
// Populo as variáveis do template html
//=====================================
	oProc:oHtml:ValByName("cLogo"		, _cLogo)
	oProc:oHtml:ValByName("A_FILIAL"	, _cFilial + " - " + AllTrim(FWFilialName(cEmpAnt,_cFilial,1)))
	oProc:oHtml:ValByName("A_CLIENTE"	, _cCliente)
	oProc:oHtml:ValByName("A_PEDVEN"	, _cNumPV)
	oProc:oHtml:ValByName("A_STATUS"	, _cOpcao)
	oProc:oHtml:ValByName("A_OBSERV"	, AllTrim(_cObs))
	IF _lSoAprovador//Quando já foi re/aprovado por outro aprovador
		oProc:oHtml:ValByName("A_TESTE01", "***JÁ FOI EXECUTADO POR OUTRO APROVADOR***")
		oProc:oHtml:ValByName("A_DATA"	, _aAvaliacao[1,1])
		oProc:oHtml:ValByName("A_HORA"	, _aAvaliacao[1,2])
		oProc:oHtml:ValByName("A_APROV"	, _aAvaliacao[1,3])
	ELSE
		oProc:oHtml:ValByName("A_TESTE01", "Foi efetivado")
		oProc:oHtml:ValByName("A_DATA"	, DtoC(Date()))
		oProc:oHtml:ValByName("A_HORA"	, Time())
		oProc:oHtml:ValByName("A_APROV"	, Alltrim(_cNomeAprovador))
	ENDIF

//================================================================
// Informamos o destinatário (aprovador) do email contendo o link.  
//================================================================
	_cEmailAprovador := Alltrim(_cEmailAprovador)  
	oProc:cTo    := _cEmailAprovador 
	IF !_lSoAprovador .And. _cTipoAprovador = "G" //Quando já foi re/aprovado por outro aprovador
		oProc:cCc := AllTrim(_cEmailSolicitante)  
	ENDIF
//===============================
// Informamos o assunto do email.  
//===============================

	oProc:cSubject	:= FWHttpEncode(_cAssunto)

//===============================================
// Informamos o arquivo a ser atachado no e-mail.
//===============================================
//_oProcess:AttachFile(cConsulta)

	_cMailID	:= oProc:fProcessId
	_cTaskID	:= oProc:fTaskID

//=======================================================
// Iniciamos a tarefa e enviamos o email ao destinatário.
//=======================================================
	oProc:Start()

Return

/*
===============================================================================================================================
Programa----------: MOMS050O
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 13/03/2020
===============================================================================================================================
Descrição---------: Rotina responsável por montar o formulário de aprovação e o envio do link gerado. (Liberação Preço)
===============================================================================================================================
Parametros--------: _cFil: filial SZW
                    _RECNO: RECNO SZW
===============================================================================================================================
Retorno-----------: _cLink - Link gerado com o html de aprovação do pedido.
===============================================================================================================================
*/
User Function MOMS050O(_cFil,_cCodVen, _cTipoApr, _cMailApr,_cNumPV,_RECNO, _cObsAprov,_cCodApr,_cTipv,_cObs)
	Static _nValAtraso	:= 0
	Static _nValPed     := 0
	Local _aArea		:= GetArea()
	Local _aAreaSZW		:= SZW->(GetArea())
	Local _cHostWF  	:= U_ItGetMv("IT_WFHOSTS","http://wfteste.italac.com.br:4043/")
	Local _cLogo		:= _cHostWF + "htm/logo_novo.jpg"
	Local _nMCusto		:= 0
	Local _cCodiApr		:= ""
	Local _cNomeApr		:= ""
	Local _cFilApr		:= ""
	Local _cFilial		:= _cFil
	Local _nMCustoCli	:= 0
	Local _nLimCred		:= 0
	Local _nSalPed 		:= 0
	Local _nSalPedL		:= 0
	Local _nSalDupM		:= 0
	Local _nLcFin		:= 0
	Local _nSalFinM		:= 0
	Local _nSalDup		:= 0
	Local _nSalFin		:= 0
	Local _nMoeda		:= 0
	Local _cQryDA1		:= ""
	Local _aVlrDesc		:= {}
	Local _nRecnoSZW    := _RECNO
	Local _lExecSelect  := .T.
	Local _cGetSol      := "Preço fora da tabela"
	Local _cTipo        := POSICIONE("SA3",1,xFilial("SA3")+_cCodApr,"A3_I_TIPV")
	Local _cTpcarg      := "F"
	Local _cCalcSuframa := "NÃO"
	Local _cCodCoord    := ""
	Local _cCodGeren    := ""
	Local _cTipoAg      := ""
	Local _cEnvio       := "ENVIO"
	Local _nCalcPesoBruto := 0
	Local _nPesBruTotItem := 0
    Local _cDesctab       := ""
    Local _nPesoFaixa     := 0
	lOCAL _cEmailAdd	  := ""

	IF IsInCallStack("U_MOMS050R") .OR. IsInCallStack("REENVAPR")//QUANDO APERTA OS BOTOES NO HTML
		_lExecSelect := .T.
	ENDIF

	If IsInCallStack("U_MOMS050R") .OR. IsInCallStack("REENVAPR")//QUANDO APERTA OS BOTOES NO HTML
		_cEnvio :="REENVIO"
	Else
		_cEnvio :="ENVIO"
	EndIf

	_cCodiApr	:= _cCodApr
	_cNomeApr	:= POSICIONE("SA3",1, xFilial("SA3")+_cCodApr, "A3_NOME")
	_cTipo		:= SA3->A3_I_TIPV
	_cEmailAdd  := SA3->A3_I_EMWF
	_cFilApr	:= _cFil

	//Codigo do processo cadastrado no CFG
	_cCodProce := "LIBPVPRC"

	// Arquivo html template utilizado para montagem da aprovação
	_cHtmlMode := "\Workflow\htm\libportal_prc.htm"

	// Inicialize a classe TWFProcess e assinale a variável objeto oProcess:
	_oProcess := TWFProcess():New(_cCodProce,"Liberação de Preço Pedido de Vendas")

	SZW->(DbGoTo(_RECNO)) // Ao rodar o comando TWFProcess():New, a tabela SZW estava sendo desposicionada. Esta instrução reposiciona a tabela SZW.

	_oProcess:NewTask("Liberacao_PVP", _cHtmlMode)

	//======================================
	//Dados do cabeçalho do pedido de vendas
	//======================================
	_oProcess:oHtml:ValByName("cLogo", _cLogo)

	//====================
	//Dados do Solicitante
	//====================
	_oProcess:oHtml:ValByName("cCodSol"			, _cCodVen)
	_oProcess:oHtml:ValByName("cNomSol"			, AllTrim(POSICIONE("SA3",1, xFilial("SA3")+_cCodVen, "A3_NOME")))
	_oProcess:oHtml:ValByName("cMaiSol"			, SA3->A3_EMAIL)
	_oProcess:oHtml:ValByName("cFilSol"			, _cFil + ' - ' + AllTrim(FWFilialName(cEmpAnt,_cFil,1)))
	_oProcess:oHtml:ValByName("cNumPVSol"		, AllTrim(_cNumPV))
	_oProcess:oHtml:ValByName("cDtAtu"			, DtoC(Date()) + " - " + Time())
	_oProcess:oHtml:ValByName("cTipo"           , IIF(_cTipo == "C","Coordenador", "Gerente"))

	_oProcess:oHtml:ValByName("cTipOper"		, "PRECO"			)

	_oProcess:oHtml:ValByName("cCodApr"			, _cCodiApr			)
	_oProcess:oHtml:ValByName("cNomApr"			, AllTrim(_cNomeApr))

	_oProcess:oHtml:ValByName("cCodRep"			, _cCodVen      			)
	_oProcess:oHtml:ValByName("cNomRep"			, AllTrim(POSICIONE("SA3",1,xFilial("SA3")+_cCodVen, "A3_NOME"))   	)

	_cCodCoord := POSICIONE("SA3",1, xFilial("SA3")+_cCodVen, "A3_SUPER")
	_oProcess:oHtml:ValByName("cCodCoo"			, _cCodCoord  				)
	_oProcess:oHtml:ValByName("cNomCoo"			, AllTrim(POSICIONE("SA3",1,xFilial("SA3")+_cCodCoord, "A3_NOME"))	)

	_cCodGeren := POSICIONE("SA3",1, xFilial("SA3")+_cCodVen, "A3_GEREN")

	_oProcess:oHtml:ValByName("cCodGer"			, _cCodGeren        			)
	_oProcess:oHtml:ValByName("cNomGer"			, AllTrim(POSICIONE("SA3",1, xFilial("SA3")+_cCodGeren,"A3_NOME"))	)

	//===============
	//Dados do Pedido
	//===============
	_oProcess:oHtml:ValByName("cNumPV"			, _cNumPV		)
	DbSelectArea("SZW")
	SZW->(DBGOTO(_nRecnoSZW))

	_oProcess:oHtml:ValByName("cTipoPV"			, POSICIONE("ZB4",1,xFilial("ZB4")+SZW->ZW_TIPO, "ZB4_DESCRI")				)


	_oProcess:oHtml:ValByName("cFilPV"			, _cFil + " - " + AllTrim(FWFilialName(cEmpAnt,_cFil,1)))
	_oProcess:oHtml:ValByName("cEmisPV"			, DtoC(SZW->ZW_EMISSAO)	                            	)

	If SZW->ZW_FILPRO != '0 ' .and. !empty(SZW->ZW_FILPRO) .and. SZW->ZW_FILPRO != SZW->ZW_FILIAL

		_cfilpro := SZW->ZW_FILPRO

		_oProcess:oHtml:ValByName("ctrocanf"		, "SIM"	)
		_oProcess:oHtml:ValByName("cFilCarregamento"	, _cfilpro + " - " + AllTrim(FWFilialName(cEmpAnt,_cfilpro,1)))

	Else
		_oProcess:oHtml:ValByName("ctrocanf"		, "NÃO"	)
		_oProcess:oHtml:ValByName("cFilCarregamento"	, " " )
	Endif

	_ctab := SZW->ZW_TABELA
	_cDesctab := POSICIONE("DA0",1,xFilial("DA0")+SZW->ZW_TABELA,'DA0_DESCRI')

	_oProcess:oHtml:ValByName("cTabPrc"		, _ctab	)
	_oProcess:oHtml:ValByName("cDecPrc"		, Alltrim(_cDesctab))

	_oProcess:oHtml:ValByName("nFaixa"		, SZW->ZW_I_FXPES)

	If SZW->ZW_I_FXPES == 3
		_nPesoFaixa := DA0->DA0_I_PES3
	ElseIf SZW->ZW_I_FXPES == 2
		_nPesoFaixa := DA0->DA0_I_PES2
	else
		_nPesoFaixa := DA0->DA0_I_PES1
	ENDIF

	_oProcess:oHtml:ValByName("nPesoFaixa"		, _nPesoFaixa)

	dbSelectArea("SE4")
	dbSetOrder(1)
	dbSeek(xFilial("SE4") + SZW->ZW_CONDPAG)
	_oProcess:oHtml:ValByName("cCondPG"			, SE4->E4_CODIGO + " - " + SE4->E4_DESCRI	)

//================
//Dados do Cliente
//================

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1") + SZW->ZW_CLIENTE + SZW->ZW_LOJACLI)

// Assunto da mensagem
	IF _cTipo == "C"
		_cAssunto := "Sol.Coord. para Lib.Preço, Pedido " + Alltrim(_cNumPV) + " CNPJ " + MOMS050CPF(SA1->A1_CGC) + " " + Alltrim(A1_NOME) + " - " + _cFilApr + " " + AllTrim(FWFilialName(cEmpAnt,_cFilApr,1))  + " --> " + _cEnvio
	ELSE
		_cAssunto := "Sol.Gerente para Lib.Preço, Pedido " + Alltrim(_cNumPV) + " CNPJ " + MOMS050CPF(SA1->A1_CGC) + " " + Alltrim(A1_NOME) + " - " + _cFilApr + " " + AllTrim(FWFilialName(cEmpAnt,_cFilApr,1))  + " --> " + _cEnvio
	ENDIF

	dbSelectArea("SE4")
	dbSetOrder(1)
	dbSeek(xFilial("SE4") + SA1->A1_COND)
	_oProcess:oHtml:ValByName("cCondPgPad"		, SE4->E4_CODIGO + " - " + SE4->E4_DESCRI	)

	If SA1->A1_CALCSUF = "I"
		_cCalculSuframa:= "ICMS"
	ElseIf SA1->A1_CALCSUF = "S"
		_cCalculSuframa:= "SIM"
	Else
		_cCalculSuframa:= "NÃO"
	EndIf
	_oProcess:oHtml:ValByName("cNomCli"			, SA1->A1_NOME				)
	_oProcess:oHtml:ValByName("cNomRed"			, SA1->A1_NREDUZ			)
	_oProcess:oHtml:ValByName("cCodCli"			, SA1->A1_COD				)
	_oProcess:oHtml:ValByName("cLojCli"			, SA1->A1_LOJA				)
	_oProcess:oHtml:ValByName("cCnpjCli"		, MOMS050CPF(SA1->A1_CGC)	)
	_oProcess:oHtml:ValByName("cGrpVen"			, SA1->A1_GRPVEN + " - " + Posicione("ACY",1,xFilial("ACY") + SA1->A1_GRPVEN, "ACY_DESCRI")				)
	_oProcess:oHtml:ValByName("cContatCli"		, SA1->A1_CONTATO			)
	_oProcess:oHtml:ValByName("cFoneCli"		, SA1->A1_TEL				)
	_oProcess:oHtml:ValByName("cEmailCli"		, SA1->A1_EMAIL				)
	_oProcess:oHtml:ValByName("cCidCli"			, SA1->A1_MUN				)
	_oProcess:oHtml:ValByName("cEstCli"			, SA1->A1_EST				)
	_oProcess:oHtml:ValByName("cEndCli"			, SA1->A1_END				)
	_oProcess:oHtml:ValByName("cAnaCre"			, SA1->A1_I_ACRED			)
	_oProcess:oHtml:ValByName("cSuframa"		, _cCalcSuframa  			)

//========================
//Informarções Financeiras
//========================
	DBSelectArea("SA1")
	SA1->( DBSetOrder(1) )
	SA1->( DBSeek( xFilial("SA1") + SZW->ZW_CLIENTE ) )

	While SA1->(!Eof()) .And. SA1->A1_COD == SZW->ZW_CLIENTE

		_nMCustoCli	:= IIf( SA1->A1_MOEDALC > 0 , SA1->A1_MOEDALC	, Val(SuperGetMv("MV_MCUSTO")) )
		_nLimCred	+= xMoeda( SA1->A1_LC							, _nMCustoCli , _nMCusto , Date() )
		_nSalPed 	+= xMoeda( SA1->A1_SALPED + SA1->A1_SALPEDB		, _nMCustoCli , _nMCusto , Date() )
		_nSalPedL	+= xMoeda( SA1->A1_SALPEDL						, _nMCustoCli , _nMCusto , Date() )
		_nSalDupM	+= xMoeda( SA1->A1_SALDUPM						, _nMCustoCli , _nMCusto , Date() )
		_nLcFin		+= xMoeda( SA1->A1_LCFIN						, _nMCustoCli , _nMCusto , Date() )
		_nSalFinM	+= xMoeda( SA1->A1_SALFINM						, _nMCustoCli , _nMCusto , Date() )
		_nSalDup	+= SA1->A1_SALDUP
		_nSalFin	+= SA1->A1_SALFIN

		SA1->( DBSkip() )
	EndDo

	DBSelectArea("SA1")
	SA1->( DBSetOrder(1) )
	SA1->( DBSeek( xFilial("SA1") + SZW->ZW_CLIENTE + SZW->ZW_LOJACLI) )

	_nMCusto 	:= IIf( SA1->A1_MOEDALC > 0 , SA1->A1_MOEDALC , VAL( SuperGetMv("MV_MCUSTO") ) )
	_nMoeda		:= 1
	IF _lExecSelect
		_nValAtraso:= MOMS050VSC( SZW->ZW_CLIENTE + SZW->ZW_LOJACLI )
		_nValPed   := MOMS050VT2( SZW->ZW_IDPED , _cFil , 1 )
	ENDIF

	_oProcess:oHtml:ValByName("nLimCrd"			, TRansform(_nLimCred,PesqPict("SA1","A1_LC",17,1)))
	_oProcess:oHtml:ValByName("nTitAber"		, TRansform(_nSalDup,PesqPict("SA1","A1_SALDUP",17,1)))
	_oProcess:oHtml:ValByName("nTitVenc"		, TRansform(_nSalPedL,PesqPict("SA1","A1_SALPEDL",17,1)))
	_oProcess:oHtml:ValByName("nSLimCrd"		, TRansform(_nLimCred-_nSaldupM-_nSalPedL,PesqPict("SA1","A1_SALDUP",17,1)))
	_oProcess:oHtml:ValByName("nPedAtu"			, TRansform(_nValPed ,PesqPict("SA1","A1_SALDUP",17,1)))
	_oProcess:oHtml:ValByName("nSalNFat"		, TRansform(_nSalPed ,PesqPict("SA1","A1_SALPED",17,1)))
	_oProcess:oHtml:ValByName("nLimCChe"		, TRansform(_nLcFin ,PesqPict("SA1","A1_LCFIN",17,1)))
	_oProcess:oHtml:ValByName("nSldChq"			, TRansform(_nSalFin ,PesqPict("SA1","A1_SALDUP",17,1)))
	_oProcess:oHtml:ValByName("nTitProt"		, STR(SA1->A1_TITPROT,3))
	_oProcess:oHtml:ValByName("nChqDev"			, STR(SA1->A1_CHQDEVO,3))
	_oProcess:oHtml:ValByName("nMComp"			, Transform(SA1->A1_MCOMPRA ,PesqPict("SA1","A1_MCOMPRA",17,_nMCusto)))
	_oProcess:oHtml:ValByName("nMDuplic"		, Transform(SA1->A1_MAIDUPL ,PesqPict("SA1","A1_MAIDUPL",17,_nMCusto)))
	_oProcess:oHtml:ValByName("nMAtras"			, Transform(SA1->A1_METR ,PesqPict("SA1","A1_METR",7)))
	_oProcess:oHtml:ValByName("cVenLCr"			, DtoC(SA1->A1_VENCLC))
	_oProcess:oHtml:ValByName("cDtLiLib"		, DtoC(StoD("")))
	_oProcess:oHtml:ValByName("nAtraAtu"		, TRansform(_nValAtraso ,PesqPict("SA1","A1_SALDUP",17,1)))

//==================
//Posição do Cliente
//==================

	_oProcess:oHtml:ValByName("nLimCrl"			, TRansform(SA1->A1_LC,PesqPict("SA1","A1_LC",14,_nMCusto)))
	_oProcess:oHtml:ValByName("nSldHist"		, TRansform(SA1->A1_SALDUP,PesqPict("SA1","A1_SALDUP",14,1)))
	_oProcess:oHtml:ValByName("nLimcSec"		, TRansform(Round(Noround(xMoeda(SA1->A1_LCFIN,_nMcusto,1,dDatabase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_LCFIN",14,1)),TRansform(SA1->A1_LCFIN,PesqPict("SA1","A1_LCFIN",14,_nMcusto)))
	_oProcess:oHtml:ValByName("nSldLcSe"		, TRansform(SA1->A1_SALFIN,PesqPict("SA1","A1_SALFIN",14,1)))
	_oProcess:oHtml:ValByName("nMaiCom"			, TRansform(Round(Noround(xMoeda(SA1->A1_MCOMPRA, _nMcusto ,1, dDataBase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_MCOMPRA",14,1)),TRansform(SA1->A1_MCOMPRA,PesqPict("SA1","A1_MCOMPRA",14,_nMcusto)))
	_oProcess:oHtml:ValByName("nMaiSld"			, TRansform(Round(Noround(xMoeda(SA1->A1_MSALDO, _nMcusto ,1, dDataBase,MsDecimais(1)+1 ),2),MsDecimais(1)),PesqPict("SA1","A1_MSALDO",14,1)))
	_oProcess:oHtml:ValByName("cPriCom"			, DtoC(SA1->A1_PRICOM))
	_oProcess:oHtml:ValByName("cUltCom"			, DtoC(SA1->A1_ULTCOM))
	_oProcess:oHtml:ValByName("nMaiAtr"			, Transform(SA1->A1_MATR,PesqPict("SA1","A1_MATR",14)))
	_oProcess:oHtml:ValByName("nMedAtr"			, PADC(STR(SA1->A1_METR,7,2),22))
	_oProcess:oHtml:ValByName("cGrauRis"		, SA1->A1_RISCO)


//===============================
//Informações do Pedido de Vendas
//===============================
	If SZW->ZW_TPFRETE == "C"
		_oProcess:oHtml:ValByName("cFrete"			, "CIF"					)
	ElseIf SZW->ZW_TPFRETE == "F"
		_oProcess:oHtml:ValByName("cFrete"			, "FOB"					)
	ElseIf SZW->ZW_TPFRETE == "T"
		_oProcess:oHtml:ValByName("cFrete"			, "TERCEIROS"			)
	ElseIf SZW->ZW_TPFRETE == "S"
		_oProcess:oHtml:ValByName("cFrete"			, "Sem Frete"			)
	EndIf

	//If SZW->ZW_I_ AGEND == 'P'
	//	_cTipoAg		:= SZW->ZW_I_ AGEND+" - AGUARD AGENDA"
	//Elseif SZW->ZW_I_ AGEND == 'I'
	//	_cTipoAg		:= SZW->ZW_I_ AGEND+" - IMEDIATO"
	//ElseIf SZW->ZW_I_ AGEND == 'M'
	//	_cTipoAg		:= SZW->ZW_I_ AGEND+" - AGENDADA COM MULTA"
	//Else
	//	_cTipoAg		:= SZW->ZW_I_ AGEND+" - AGENDADA"
	//Endif
    _cTipoAg:=SZW->ZW_I_AGEND+" - "+U_TipoEntrega(SZW->ZW_I_AGEND)

	_oProcess:oHtml:ValByName("cTpCarga"		, Iif(SZW->ZW_TIPCAR == "1", SZW->ZW_TIPCAR + " - Paletizada", Iif(SZW->ZW_TIPCAR == "2", SZW->ZW_TIPCAR + " - Batida", "")))
	_oProcess:oHtml:ValByName("nQtdChap"		, SZW->ZW_CHAPA  			)
	_oProcess:oHtml:ValByName("cHrDescg"		, SZW->ZW_HORDES			)
	_oProcess:oHtml:ValByName("nCusCarg"		, "0"						)
	_oProcess:oHtml:ValByName("dDtEntrega"		, SZW->ZW_FECENT 			)
	_oProcess:oHtml:ValByName("cHrEntrega"		, SZW->ZW_HOREN  			)
	_oProcess:oHtml:ValByName("cSenhaEntr"		, SZW->ZW_SENHA    			)
	_oProcess:oHtml:ValByName("cTipoAgenda"		, _cTipoAg       			)
	_oProcess:oHtml:ValByName("cCarga"          , IIF(AllTrim(SZW->ZW_TPVENDA) == "F" .AND. SZW->ZW_TPVENDA != "", " F - Fechada", " V - Fracionada"))
	_oProcess:oHtml:ValByName("cEnvio"			, _cEnvio       			)
	_oProcess:oHtml:ValByName("cMensNF"			, SZW->ZW_MENNOTA			)
	_oProcess:oHtml:ValByName("cObsPed"			, SZW->ZW_OBSCOM 			)

	
	
	//=========================================================================
	// Dados de Aprovação quando Retorno é do Coordenador
	//=========================================================================

	_oProcess:oHtml:ValByName("nGetMagro"		, TRansform(SZW->ZW_I_LMAGR,PesqPict("SZW","ZW_I_LMAGR",14,1)))
	_oProcess:oHtml:ValByName("cGetObsCoord"	, _cObs )

	If _cTipv = 'C'
		_oProcess:oHtml:ValByName("cDataAprov"	, DtoC(SZW->ZW_DLIBP)	 	)
		_oProcess:oHtml:ValByName("cHoraAprov"	, SZW->ZW_HLIBP )
	else
		_oProcess:oHtml:ValByName("cDataAprov"	, DtoC(SZW->ZW_I_DLIBG) )
		_oProcess:oHtml:ValByName("cHoraAprov"	, SZW->ZW_I_HLIBG )
	EndIF

//=========================================
//Informações dos itens do Pedido de Vendas
//=========================================
	dbSelectArea("SZW")
	dbSetOrder(1)
	dbSeek(_cFil + _cNumPV)

	_nCalcPesoBruto := 0
	_nPesoBrut := MOMS050PESO(SZW->ZW_FILIAL,SZW->ZW_IDPED)

	dbSelectArea("SZW")
	dbSetOrder(1)
	dbSeek(_cFil + _cNumPV)
	SA1->(Dbsetorder(1))
	SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))
	If SA1->A1_SIMPNAC == "1"
		_lSimplNac := .T. // O cliente é optante do Simples Nacional
	Else
		_lSimplNac := .F. // O cliente não é Optante do Simples Nacional
	EndIf
	//_cCoord     := POSICIONE("SA3",1,xFilial("SA3")+SZW->ZW_VEND1,"A3_SUPER")
	//_cGerente   := POSICIONE("SA3",1,xFilial("SA3")+SZW->ZW_VEND1,"A3_GEREN")
	//_cCoordWF   := POSICIONE("SA3",1,xFilial("SA3")+_cCoord,"A3_I_WF")

	While !SZW->(Eof()) .And. SZW->ZW_FILIAL == _cFil .And. AllTrim(SZW->ZW_IDPED) == AllTrim(_cNumPV)

		aAdd( _oProcess:oHtml:ValByName("Itens.cItem" 			), SZW->ZW_ITEM																	)
		aAdd( _oProcess:oHtml:ValByName("Itens.cProdPV" 		), SZW->ZW_PRODUTO								 									)
		aAdd( _oProcess:oHtml:ValByName("Itens.cDescPV"			), AllTrim(POSICIONE("SB1",1,xFilial("SB1")+ZW_PRODUTO, "B1_DESC"))															)
		aAdd( _oProcess:oHtml:ValByName("Itens.cNumPCli"		), SZW->ZW_PEDCLI																	)
		aAdd( _oProcess:oHtml:ValByName("Itens.nPrcVen"			), Transform(SZW->ZW_PRCVEN, "@E 999,999,999.999")									)
		aAdd( _oProcess:oHtml:ValByName("Itens.nQuantPV"		), Transform(SZW->ZW_SEGQTD, PesqPict("SZW","ZW_SEGQTD"))							)
		aAdd( _oProcess:oHtml:ValByName("Itens.cUM"				), SZW->ZW_2UM    																		)
		aAdd( _oProcess:oHtml:ValByName("Itens.nTotalPV"	   	), Transform(SZW->ZW_PRCVEN*SZW->ZW_QTDVEN, PesqPict("SC6","C6_VALOR"))								)
		//aAdd( _oProcess:oHtml:ValByName("Itens.nDescont"		), Transform(SZW->ZW_VALDESC, PesqPict("SZW","ZW_VALDESC"))							)

		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xfilial("SB1")+ SZW->ZW_PRODUTO))

		//CALCULA O PESO BRUTO TOTAL DO PEDIDO DE VENDA
		_nPesBruTotItem:=(SB1->B1_PESBRU * SZW->ZW_QTDVEN)

		_nCalcPesoBruto += _nPesBruTotItem

		_ctab := SZW->ZW_TABELA

		_cQryDA1 := "SELECT DA1_PRCVEN, DA1_I_PRCA, DA1_I_PMFE, DA1_I_PMFR, DA1_I_PRFE, "
		_cQryDA1 += " DA1_I_PRF1,DA1_I_PMF1, DA1_I_PRF2, DA1_I_PMF2,DA1_I_PRF3, DA1_I_PMF3 "
		_cQryDA1 += "FROM " + RetSqlName("DA1") + " "
		_cQryDA1 += "WHERE DA1_FILIAL = '" + xFilial("DA1") + "' "
		_cQryDA1 += "  AND DA1_CODTAB = '" + _ctab + "' "
		_cQryDA1 += "  AND DA1_CODPRO = '" + SZW->ZW_PRODUTO + "' "
		_cQryDA1 += "  AND D_E_L_E_T_ = ' ' "

		If Select("TRBDA1") > 0
			TRBDA1->(DbCloseArea())
		EndIf
		dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQryDA1 ) , "TRBDA1" , .T., .F. )

		dbSelectArea("TRBDA1")
		TRBDA1->(dbGoTop())

		DO CASE
		CASE AllTrim(SZW->ZW_TPVENDA) == "F"
			_cTpCarg := "F"
		CASE AllTrim(SZW->ZW_TPVENDA) == "V"
			_cTpCarg := "V"
		ENDCASE
		/*
        If SZW->ZW_I_FXPES == 3
            _nPesoFaixa := DA0->DA0_I_PES3
        ElseIf SZW->ZW_I_FXPES == 2
            _nPesoFaixa := DA0->DA0_I_PES2
        else
            _nPesoFaixa := DA0->DA0_I_PES1        
        ENDIF*/

        If Empty(SZW->ZW_KIT)
           _aBlqprc := U_BLQPRC(SZW->ZW_PRODUTO,SZW->ZW_PRCVEN,SZW->ZW_FILIAL,  .F. ,SZW->ZW_TABELA,    .T.,      .T.,          0,           ,         ,SA1->A1_EST,         ,SZW->ZW_TPVENDA,_lSimplNac,_nPesoBrut,SZW->ZW_I_FXPES)

 		   _lPrcErr := _aBlqprc[1]
		   _nPrecoIt:= _aBlqprc[4]
		Else  
           _lPrcErr := .T.
		   _nPrecoIt:=  SZW->ZW_PRCVEN
        EndIf 

		If _cEnvio ="ENVIO"
            aAdd( _oProcess:oHtml:ValByName("Itens.nPrcMin"			), Transform(_nPrecoIt, PesqPict("DA1","DA1_I_PRF1")))//IIF(_cTpCarg == "F", TRBDA1->DA1_PRCVEN, TRBDA1->DA1_I_PRFE)
		else
			aAdd( _oProcess:oHtml:ValByName("Itens.nPrcMin"			), Transform(SZW->ZW_PRUNIT, PesqPict("DA1","DA1_I_PRF1"))					)
		EndIf

		_aVlrDesc	:= U_veriContrato( SZW->ZW_CLIENTE , SZW->ZW_LOJACLI , SZW->ZW_PRODUTO )
		aAdd( _oProcess:oHtml:ValByName("Itens.nPerCon"			), Transform(_aVlrDesc[1], PesqPict("SZW","ZW_I_PRCD"))		)
		aAdd( _oProcess:oHtml:ValByName("Itens.nPrcNet"			), Transform(SZW->ZW_I_PRNET, PesqPict("SZW","ZW_I_PRNET"))	)//Transform(SZW->ZW_PRCVEN - ( ( _aVlrDesc[1] * SZW->ZW_PRCVEN ) / 100 ), PesqPict("SC6","C6_VALOR")))
		aAdd( _oProcess:oHtml:ValByName("Itens.nPrcNetKG"		), Transform(SZW->ZW_I_PRNET / SB1->B1_PESO, PesqPict("SZW","ZW_I_PRNET"))	)

		If _lPrcErr
			aAdd( _oProcess:oHtml:ValByName("Itens.cCor"), "color=#FF0000" )//VERMELHO
		Else
			aAdd( _oProcess:oHtml:ValByName("Itens.cCor"), "color=#006400" )//VERDE
		Endif

		/*
		If _aVlrDesc[1] <> 0
			_nPrecoNet := (SZW->ZW_PRCVEN - ( ( _aVlrDesc[1] * SZW->ZW_PRCVEN ) / 100 ))
		Else
			_nPrecoNet := SZW->ZW_PRCVEN
		EndIF

		IF _cTpCarg == "F"
			If (_nPrecoNet < TRBDA1->DA1_PRCVEN .OR. _nPrecoNet > TRBDA1->DA1_I_PRCA)
				aAdd( _oProcess:oHtml:ValByName("Itens.cCor"), "color=#FF0000" )//VERMELHO
			Else
				aAdd( _oProcess:oHtml:ValByName("Itens.cCor"), "color=#006400" )//VERDE
			Endif
		else
			If (_nPrecoNet < TRBDA1->DA1_I_PRFE .OR. _nPrecoNet > TRBDA1->DA1_I_PRCA)
				aAdd( _oProcess:oHtml:ValByName("Itens.cCor"), "color=#FF0000" )//VERMELHO
			Else
				aAdd( _oProcess:oHtml:ValByName("Itens.cCor"), "color=#006400" )//VERDE
			Endif
		EndIf*/

		dbSelectArea("TRBDA1")
		TRBDA1->(dbCloseArea())

		SZW->(dbSkip())
	End

	_oProcess:oHtml:ValByName("nPesoBruto"		         , TRansform(_nCalcPesoBruto ,PesqPict("SA1","A1_SALDUP",17,1)))

	_oProcess:oHtml:ValByName("cGetSol"		, _cGetSol		)

//=========================================================================
// Informe o nome da função de retorno a ser executada quando a mensagem de
// respostas retornar ao Workflow:
//=========================================================================
	_oProcess:bReturn := "U_MOMS050R"

//========================================================================
// Após ter repassado todas as informacões necessárias para o Workflow,
// execute o método Start() para gerar todo o processo e enviar a mensagem
// ao destinatário.
//========================================================================
	_cMailID	:= _oProcess:Start("\workflow\emp01")
	_cLink		:= _cMailID

	If File("\workflow\emp01\" + _cMailID + ".htm")
		conout("Arquivo \workflow\emp01\" + _cMailID + ".htm criado com sucesso.")
	ELSE
		conout("Arquivo \workflow\emp01\" + _cMailID + ".htm não encotrado.")
	EndIf

//====================================
//Codigo do processo cadastrado no CFG
//==================================== 
	_cCodProce := "LIBPVPRC"

//======================================================================
// Inicialize a classe TWFProcess e assinale a variável objeto oProcess:
//======================================================================
	_oProcess := TWFProcess():New(_cCodProce,"Liberação PV Preço")

	SZW->(DbGoTo(_nRecnoSZW)) // Ao rodar o comando TWFProcess():New, a tabela SZW estava sendo desposicionada. Esta instrução reposiciona a tabela SZW.

//=================================================================
// Criamos o link para o arquivo que foi gerado na tarefa anterior.  
//=================================================================
	_oProcess:NewTask("LINK", "\workflow\htm\pvprecportal_link.htm")

	_chtmlfile	:= _cLink + ".htm"
	_cMailTo	:= "mailto:" + Alltrim(Posicione("WF7", 1, XFilial("WF7") + AllTrim(GetMV('MV_WFMLBOX')), "WF7_ENDERE"))
	_chtmltexto := wfloadfile("\workflow\emp01\" + _chtmlfile )
	_chtmltexto := strtran( _chtmltexto, _cmailto, "WFHTTPRET.APL" )
	wfsavefile("\workflow\emp"+cEmpAnt+"\" + _chtmlfile, _chtmltexto)
	_cLink := _cHostWF + "emp01/" + _cLink + ".htm"

//=====================================
// Populo as variáveis do template html
//=====================================
	_oProcess:oHtml:ValbyName("A_COORD"     , _cNomeApr)
	_oProcess:oHtml:ValByName("cLogo"		, _cLogo)
	_oProcess:oHtml:ValByName("A_FILIAL"	, _cFilial + " - " + FWFilialName(cEmpAnt,_cFilial,1))
	_oProcess:oHtml:ValByName("A_PEDVEN"	, _cNumPV)
	_oProcess:oHtml:ValByName("A_LINK"		, _cLink)
	_oProcess:oHtml:ValByName("A_NOMREP"	, _cCodVen + " - " + POSICIONE("SA3",1, xFilial("SA3")+_cCodVen, "A3_NOME"))
	_oProcess:oHtml:ValByName("A_CLIENTE"	, SA1->A1_COD + "/" + SA1->A1_LOJA + " - " + SA1->A1_NOME)
	_oProcess:oHtml:ValByName("A_LIMCRED"	, TRansform(SA1->A1_LC,PesqPict("SA1","A1_LC",17,1)))
	_oProcess:oHtml:ValByName("A_VLRPED"	, TRansform(_nValPed,PesqPict("SC6","C6_VALOR",17,1)))
	_oProcess:oHtml:ValByName("A_TITPRO"	, STR(SA1->A1_TITPROT,3))
	_oProcess:oHtml:ValByName("A_MCOMP"		, Transform(SA1->A1_MCOMPRA,PesqPict("SA1","A1_MCOMPRA",17,_nMCusto)))
	_oProcess:oHtml:ValByName("A_MDUPL"		, Transform(SA1->A1_MAIDUPL,PesqPict("SA1","A1_MAIDUPL",17,_nMCusto)))
	_oProcess:oHtml:ValByName("A_VLCRED"	, DtoC(SA1->A1_VENCLC))
	_oProcess:oHtml:ValByName("A_DTLIMLB"	, DtoC(StoD("")))
	_oProcess:oHtml:ValByName("A_PCOMP"		, DtoC(SA1->A1_PRICOM))
	_oProcess:oHtml:ValByName("A_UCOMP"		, DtoC(SA1->A1_ULTCOM))
	_oProcess:oHtml:ValByName("A_GRISC"		, SA1->A1_RISCO)
	_oProcess:oHtml:ValByName("cGetSol"		, _cGetSol)

//================================================================
// Informamos o destinatário (aprovador) do email contendo o link.  
//================================================================
    _cMailApr := Alltrim(_cMailApr)   

	If !EMPTY(Alltrim(_cEmailAdd)) 
		 _cMailApr += "," + _cEmailAdd
	EndIf

	_oProcess:cTo  :=  _cMailApr 
 	//===============================
    // Informamos o assunto do email.    
    //===============================  
 
	_oProcess:cSubject	:= FWHttpEncode(_cAssunto)

	_cMailID	:= _oProcess:fProcessId
	_cTaskID	:= _oProcess:fTaskID

//=======================================================
// Iniciamos a tarefa e enviamos o email ao destinatário.
//=======================================================
	_oProcess:Start()

	RestArea(_aArea)
	RestArea(_aAreaSZW)
Return _cLink

/*
===============================================================================================================================
Programa----------: RetBloq
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 13/03/2020
===============================================================================================================================
Descrição---------: Rotina para retornar pedidos bloqueados por preço.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _aPedidos
===============================================================================================================================
*/
Static Function RetBloq(_cOp)
	Local _aPedidos := {}
	Local _cQuery   := ""
	Local _dDtIni	:= DtoS(U_ItGetMv("IT_WFPINI",cTod("08/06/2020")))
	Local cAlias    := GetNextAlias()

	Default _cOp	:= "N"

	If _cOp <> "B"

		_cQuery := " SELECT SZW.R_E_C_N_O_,SZW.ZW_EMISSAO EMISSAO, SZW.ZW_IDPED PEDIDO, SZW.ZW_ITEM ITEM FROM " + RetSqlName("SZW") + " SZW  "
		_cQuery += " WHERE SZW.D_E_L_E_T_  = ' ' "
		_cQuery += " AND SZW.ZW_TIPO      <> '10' "		
		_cQuery += " AND SZW.ZW_STATUS     = 'A' "
		_cQuery += " AND SZW.ZW_EMISSAO   >= '" + _dDtIni + "' "
		_cQuery += " AND SZW.ZW_NUMPED     = ' ' "
		_cQuery += " AND SZW.ZW_ENVWF      = ' ' "
		_cQuery += " AND SZW.ZW_TPVENDA   <> ' ' "
		_cQuery += " AND SZW.ZW_BLOPRC     = ' ' "
		
		_cQuery += " UNION " 

		_cQuery += " SELECT SZW.R_E_C_N_O_,SZW.ZW_EMISSAO EMISSAO, SZW.ZW_IDPED PEDIDO, SZW.ZW_ITEM ITEM FROM " + RetSqlName("SZW") + " SZW  "		
		_cQuery += " WHERE SZW.D_E_L_E_T_  = ' ' "
		_cQuery += " AND SZW.ZW_TIPO      <> '10' "		
		_cQuery += " AND SZW.ZW_STATUS     = 'L' "
		_cQuery += " AND SZW.ZW_EMISSAO   >= '" + _dDtIni + "' "
		_cQuery += " AND SZW.ZW_NUMPED     = ' ' "
		_cQuery += " AND SZW.ZW_ENVWF     <> 'G' "
		_cQuery += " AND SZW.ZW_NIVELWF   <> 'E' "
		_cQuery += " AND SZW.ZW_TPVENDA   <> ' ' "
		_cQuery += " AND SZW.ZW_BLOPRC     = ' ' "
	    _cQuery += " ORDER BY EMISSAO, PEDIDO, ITEM   "

		DBUsearea(.T., "TOPCONN", TCGENQRY(,, _cQuery) , cAlias, .T., .F.)

		DbSelectArea(cAlias)

		DO WHILE (cAlias)->(!EOF())
			Aadd(_aPedidos, (cAlias)->R_E_C_N_O_)
			(cAlias)->(DBSKIP())
		ENDDO
	 
	ELSE   // Query de BONIFICAÇÃO
	
		_cQuery := " SELECT SZW.R_E_C_N_O_,SZW.ZW_EMISSAO EMISSAO, SZW.ZW_IDPED PEDIDO, SZW.ZW_ITEM ITEM FROM " + RetSqlName("SZW") + " SZW  "		
		_cQuery += " WHERE SZW.D_E_L_E_T_ = ' ' "
		_cQuery += " AND SZW.ZW_TIPO      = '10' "	
		_cQuery += " AND SZW.ZW_BLOQ      = ' ' "			
		_cQuery += " AND SZW.ZW_STATUS    = 'A' "
		_cQuery += " AND SZW.ZW_EMISSAO  >= '" + _dDtIni + "' "
		_cQuery += " AND SZW.ZW_NUMPED    = ' ' "
		_cQuery += " AND SZW.ZW_ENVWF     = ' ' "
		_cQuery += " AND SZW.ZW_TPVENDA  <> ' ' "
		_cQuery += " UNION "

		_cQuery += " SELECT SZW.R_E_C_N_O_,SZW.ZW_EMISSAO EMISSAO, SZW.ZW_IDPED PEDIDO, SZW.ZW_ITEM ITEM FROM " + RetSqlName("SZW") + " SZW  "
		_cQuery += " WHERE SZW.D_E_L_E_T_ = ' ' "
		_cQuery += " AND SZW.ZW_TIPO      = '10' "				
		_cQuery += " AND SZW.ZW_STATUS    = 'L' "
		_cQuery += " AND SZW.ZW_EMISSAO  >= '" + _dDtIni + "' "
		_cQuery += " AND SZW.ZW_NUMPED    = ' ' "
		_cQuery += " AND SZW.ZW_ENVWF    <> 'G' "
		_cQuery += " AND SZW.ZW_NIVELWF  <> 'E' "
		_cQuery += " AND SZW.ZW_TPVENDA  <> ' ' "
		_cQuery += " AND SZW.ZW_BLOQ      = ' ' "
		_cQuery += " ORDER BY EMISSAO, PEDIDO, ITEM   "

		DBUsearea(.T., "TOPCONN", TCGENQRY(,, _cQuery) , cAlias, .T., .F.)

		DbSelectArea(cAlias)

		DO WHILE (cAlias)->(!EOF())
			Aadd(_aPedidos, (cAlias)->R_E_C_N_O_)
			(cAlias)->(DBSKIP())
		ENDDO
 
	ENDIF

Return _aPedidos 

/*
===============================================================================================================================
Programa----------: AtuSzw
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 11/05/2020
===============================================================================================================================
Descrição---------: Rotina para atualização da SZW após envio do e-mail de aprovação.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/
Static Function AtuSzw(_cFilped,_cIdPed,_cTipoAprov, _cLinkG, _cSit)

	IF SZW->(dbSeek(_cFilped+_cIdPed))
		DO WHILE SZW->(!EOF() .AND. SZW->ZW_IDPED == _cIdPed .AND. SZW->ZW_FILIAL == _cFilped)
			RECLOCK("SZW", .F.)
			SZW->ZW_ENVWF   := _cTipoAprov
			SZW->ZW_DTENVIO := DATE()
			SZW->ZW_HRENVIO := LEFT(TIME(),5)
			SZW->ZW_I_HTML  := _cLinkG

			IF SZW->ZW_TIPO <> "10"
				If _cSit = "B"
					SZW->ZW_STATUS = 'P'
				elseIf _cSit = "R"
					SZW->ZW_STATUS = 'Q'
				EndIf
			else
								
			EndIf
			SZW->(MsUnLock())
			SZW->(DBSKIP())
		ENDDO
	ENDIF
RETURN

/*
===============================================================================================================================
Programa----------: GrVLZGT
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 11/05/2020
===============================================================================================================================
Descrição---------: Grava log de movimentação referente ao processo de aprovação via WF na tabela ZGT
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/
/*Static Function oldGrVLZGT(_cFilPed, _cAprov, _dDtOper, _cTpOper, _cTpApro, _cLink, _cIdped)

    DbSelectArea("ZGT")
    ZGT->(RECLOCK("ZGT",.T.))
        ZGT->ZGT_FILIAL := _cFilPed
        ZGT->ZGT_CDAPRV := _cAprov
        ZGT->ZGT_IDPED  := _cIdped
        ZGT->ZGT_DTOPER := _dDtOper
        ZGT->ZGT_TPOPER := _cTpOper
        ZGT->ZGT_TPAPRO := _cTpApro
        ZGT->ZGT_HTML   := _cLink
    ZGT->(MsUnlock())
    ZGT->(DbCloseArea())

RETURN */


/*
===============================================================================================================================
Programa----------: MOMS50RP
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 09/06/2020
===============================================================================================================================
Descrição---------: Verifica pêndendicas de aprovação de pedidos portal e notifica Coordenadores e Gerentes
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/

User Function MOMS50RP()
	Local cQuery            := ""
	Local _cCodProce        := ""
	Local _cNomeApr         := ""
	Local _cCodApr          := ""
	Local _cLogo		    := ""
	Local _cHostWF  	    := ""
	Local _cMailApr         := ""
	Local _cLink            := ""
	Local _cArq             := ""
	Local _cGetSol          := "Preço fora da tabela"
	Local _cHtmlMode	    := "\Workflow\htm\pv_concluido.htm"
	Local _cHtml    	    := "\Workflow\htm\pvprecportalavs_link.htm"
	Local cAlias            := GetNextAlias()
	Local aTables           := {"SZW","SA3"}
	Local nData
	Local _oProcess
	Local _cMailID
	Local _cTaskID

	RPCSetType(3)
	RpcSetEnv("01","01" ,,,, "SCHEDULE_WF_PENDENCIA_BLPRECO", aTables )
	sleep( 5000 )

	cQuery +=   " SELECT ZW_FILIAL, ZW_IDPED, ZW_ENVWF,"+;
		"ZW_DTENVIO, ZW_HRENVIO, A1_COD,A1_CGC , A1_LOJA,"+;
		"A1_NOME, A3_COD, A3_NOME,A1_LC,A1_TITPROT,A1_MCOMPRA,"+;
		"A1_MAIDUPL,A1_VENCLC,A1_PRICOM,A1_ULTCOM,A1_RISCO,"+;
		"A3_EMAIL, A3_SUPER FROM " + RetSqlName("SZW") + " ZW, " + RetSqlName("SA1") + " A1, " + RetSqlName("SA3") + " A3 "
	cQuery += " WHERE ZW.D_E_L_E_T_ = ' ' "
	cQuery += " AND ZW.ZW_ITEM = '1' "
	cQuery += " AND ZW_BLOPRC = 'B' "
	cQuery += " AND ZW_ENVWF <> ' ' "
	cQuery += " AND ZW_DTENVIO BETWEEN '"+ DtoS(Date()-3) + "' AND '" +DtoS(Date()-1)+"' "
	cQuery += " AND A1.D_E_L_E_T_ = ' ' "
	cQuery += " AND A3.D_E_L_E_T_ = ' ' "
	cQuery += " AND A1.A1_COD = ZW.ZW_CLIENTE "
	cQuery += " AND A1.A1_LOJA = ZW.ZW_LOJACLI "
	cQuery += " AND A3.A3_COD = ZW_VEND1 "

	DBUsearea(.T., "TOPCONN", TCGENQRY(,, cQuery) , cAlias, .T., .F.)

	SA3->(DbSetOrder(1))

	_cHostWF  := U_ItGetMv("IT_WFHOSTS","http://wfteste.italac.com.br:4043/")
	_cLogo    := _cHostWF + "htm/logo_novo.jpg"

	While (cAlias)->(!EOF())
		_cMailApr := ""
		nData := Date() - StoD((cAlias)->ZW_DTENVIO)
		_cLink := POSICIONE("SZW",1,(cAlias)->ZW_FILIAL+(cAlias)->ZW_IDPED, "ZW_I_HTML")
		Do Case
		Case nData == 1 //Alerta sobre pedido

			If (cAlias)->ZW_ENVWF == 'C'
				_cCodApr  := POSICIONE("SA3",1,xFilial("SA3")+(cAlias)->A3_COD,"A3_SUPER")
				_cNomeApr := POSICIONE("SA3",1,xFilial("SA3")+_cCodApr, "A3_NOME")
				_cMailApr := SA3->A3_EMAIL
				_cAssunto := "Solicitação ao Coordenador para Liberação de Preço,  CNPJ " + MOMS050CPF((cAlias)->A1_CGC) + " " + Alltrim((cAlias)->A1_NOME) + " - " + (cAlias)->ZW_FILIAL + " " + AllTrim(FWFilialName(cEmpAnt,(cAlias)->ZW_FILIAL,1)) + " - PV Número: " + (cAlias)->ZW_IDPED
			Else
				_cCodApr  := POSICIONE("SA3",1,xFilial("SA3")+(cAlias)->A3_COD,"A3_GEREN")
				_cNomeApr := POSICIONE("SA3",1,xFilial("SA3")+_cCodApr, "A3_NOME")
				_cMailApr := SA3->A3_EMAIL
				_cAssunto := "Solicitação ao Gerente de Vendas para Liberação de Preço, CNPJ " + MOMS050CPF((cAlias)->A1_CGC) + " " + Alltrim((cAlias)->A1_NOME) + " - " + (cAlias)->ZW_FILIAL + " " + AllTrim(FWFilialName(cEmpAnt,(cAlias)->ZW_FILIAL,1)) + " - PV Número: " + (cAlias)->ZW_IDPED
			EndIf

			//====================================
			//Codigo do processo cadastrado no CFG
			//====================================
			_cCodProce := "LIBPVPRC"

			_oProcess := TWFProcess():New(_cCodProce,"Liberação de Preço Pedido de Vendas")

			_oProcess:NewTask("Liberacao_PVP", _cHtml)
			//=====================================
			// Populo as variáveis do template html
			//=====================================
			_oProcess:oHtml:ValbyName("A_COORD"     , _cNomeApr)
			_oProcess:oHtml:ValByName("cLogo"		, _cLogo)
			_oProcess:oHtml:ValByName("A_FILIAL"	, (cAlias)->ZW_FILIAL + " - " + FWFilialName(cEmpAnt,(cAlias)->ZW_FILIAL,1))
			_oProcess:oHtml:ValByName("A_PEDVEN"	, (cAlias)->ZW_IDPED)
			_oProcess:oHtml:ValByName("A_LINK"		, _cLink)
			_oProcess:oHtml:ValByName("A_NOMREP"	, (cAlias)->A3_COD + " - " + (cAlias)->A3_NOME)
			_oProcess:oHtml:ValByName("A_CLIENTE"	, (cAlias)->A1_COD + "/" + (cAlias)->A1_LOJA + " - " + (cAlias)->A1_NOME)
			_oProcess:oHtml:ValByName("A_LIMCRED"	, TRansform((cAlias)->A1_LC,PesqPict("SA1","A1_LC",17,1)))
			_oProcess:oHtml:ValByName("A_TITPRO"	, STR((cAlias)->A1_TITPROT,3))
			_oProcess:oHtml:ValByName("A_VLCRED"	, DtoC(StoD((cAlias)->A1_VENCLC)))
			_oProcess:oHtml:ValByName("A_PCOMP"		, DtoC(StoD((cAlias)->A1_PRICOM)))
			_oProcess:oHtml:ValByName("A_UCOMP"		, DtoC(StoD((cAlias)->A1_ULTCOM)))
			_oProcess:oHtml:ValByName("A_GRISC"		, (cAlias)->A1_RISCO)
			_oProcess:oHtml:ValByName("cGetSol"		, _cGetSol)

			//================================================================
			// Informamos o destinatário (aprovador) do email contendo o link.
			//================================================================
			_oProcess:cTo  :=  _cMailApr  
			//===============================
			// Informamos o assunto do email. 
			//===============================
			_oProcess:cSubject	:= FWHttpEncode(_cAssunto) 

			_cMailID	:= _oProcess:fProcessId
			_cTaskID	:= _oProcess:fTaskID
			//=======================================================
			// Iniciamos a tarefa e enviamos o email ao destinatário.
			//=======================================================
			_oProcess:Start()

		Case nData > 1 //Rejeitar pedido

			If (cAlias)->ZW_ENVWF == 'C' .OR. EMPTY((cAlias)->ZW_ENVWF)
				_cCodApr := POSICIONE("SA3",1,xFilial("SA3")+(cAlias)->A3_COD,"A3_SUPER")
				_cTpApro := SA3->A3_I_TIPV
			ElseIf (cAlias)->ZW_ENVWF == 'G'
				_cCodApr := POSICIONE("SA3",1,xFilial("SA3")+(cAlias)->A3_COD,"A3_GEREN")
				cTpApro := SA3->A3_I_TIPV
			EndIf

			_cArq := Strtran(SubStr(_cLink,Rat("/",_cLink)+1),"/","\")

			//========================================================================================
			//Faz a cópia do arquivo de aprovação para .old, e cria o arquivo de processo já concluído
			//========================================================================================
			If File("\workflow\emp01\" + _cArq)
				If __CopyFile("\workflow\emp01\" + _cArq, "\workflow\emp01\" + _cArq + ".old")
					If __CopyFile(_cHtmlMode, "\workflow\emp01\" + _cArq)

						RecLock("SZW",.F.)
						SZW->ZW_MLIBPRC     := _cCodApr
						SZW->ZW_BLOPRC      := "R"
						SZW->ZW_HLIBP       := TIME()
						SZW->ZW_DLIBP       := DATE()
						SZW->ZW_ULIBP       := AllTrim(POSICIONE("SA3",1, xFilial("SA3")+_cCodApr, "A3_NOME"))
						SZW->ZW_MOTLP       := "PENDENTE APROVACAO COORDENADOR / GERENTE"
						SZW->ZW_STATUS      := "Q"
						SZW->ZW_IMPRIME     := '1'
						SZW->(MsUnlock())

						//GrVLZGT((cAlias)->ZW_FILIAL, _cCodApr, Date(), "R", _cTpApro, _cLink, (cAlias)->ZW_IDPED)
					Else
						conout("Problema na cópia de arquivo de conclusão.")
					EndIf
				Else
					conout("Não foi possível renomear o arquivo " + _cArq)
				EndIf
			EndIf
		EndCase
		(cAlias)->(DBSKIP())
	EndDo

	RPCClearEnv()
Return


/*
===============================================================================================================================
Programa----------: MOMS050PESO
Autor-------------: Jerry
Data da Criacao---: 30/09/2021
===============================================================================================================================
Descrição---------: Rotina para calcular o Peso Bruto para validar Preço por Faixa de Peso
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/
Static Function MOMS050PESO(_cFilped,_cIdPed)
	Local _nPesBruTot := 0
	Local _aAreaSZW		:= SZW->(GetArea())

	IF SZW->(dbSeek(_cFilped+_cIdPed))
		DO WHILE SZW->(!EOF()  .AND. SZW->ZW_FILIAL == _cFilped .AND. SZW->ZW_IDPED == _cIdPed )

			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xfilial("SB1")+ SZW->ZW_PRODUTO))

			_nPesBruTot:=(SB1->B1_PESBRU * SZW->ZW_QTDVEN)

			SZW->(DBSKIP())
		ENDDO
	ENDIF

	RestArea(_aAreaSZW)

RETURN _nPesBruTot



/*
===============================================================================================================================
Programa----------: MOMS050REC
Autor-------------: Jerry
Data da Criacao---: 03/03/2022
===============================================================================================================================
Descrição---------: Rotina para Recusar pedido com mais de 24 horas sem Liberação ou sem Aprovação
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function MOMS050REC()

	Local _cAliasSZW   := GetNextAlias()
	Local _nqtdHoras   := 0
	Local _nQtdRecusar := U_ItGetMv("IT_TMPRECUS",48) //Qtd de Dias para Recusar Pedido Portal
	Local _cCalendario := U_ItGetMv("IT_CALENREC","002") //Qtd de Dias para Recusar Pedido Portal
	Local _aPedRecusar := {} //Pedidos a Recusar
	Local _cMotivo	   := ""
	Local _nCont       := 0

	//===============================================================
	// Verifica se ja existe um arquivo com mesmo nome, se sim deleta.
	//===============================================================

	If Select(_cAliasSZW) <> 0

		(_cAliasSZW)->(dbCloseArea())

	EndIf

	BeginSql alias _cAliasSZW
   	SELECT 
		ZW_FILIAL, ZW_IDPED, ZW_EMISSAO, ZW_HORAINC, ZW_DATAAPR,ZW_HORAAPR , ZW_ENVWF, ZW_FECENT, ZW_STATUS , SA1.A1_NOME
		, VEND.A3_COD, VEND.A3_NOME
		, COOR.A3_COD, COOR.A3_NOME
		, GER.A3_COD,  GER.A3_NOME
		FROM %table:SZW% SZW
		LEFT JOIN %table:SA1% SA1  ON A1_COD = ZW_CLIENTE AND A1_LOJA = ZW_LOJACLI  
		LEFT JOIN %table:SA3% VEND ON VEND.A3_COD = ZW_VEND1 
		LEFT JOIN %table:SA3% COOR ON COOR.A3_COD = VEND.A3_SUPER 
		LEFT JOIN %table:SA3% GER  ON GER.A3_COD   = VEND.A3_GEREN
		WHERE SZW.%NotDel%
	    AND GER.%NotDel%
		AND COOR.%NotDel%
		AND VEND.%NotDel%
		AND SA1.%NotDel%
		AND zw_numped = ' ' 
		AND SZW.ZW_STATUS = 'A' 
		AND SZW.ZW_EMISSAO >= '20190101'
		AND SZW.ZW_NUMPED = ' ' 

		UNION 

		SELECT ZW_FILIAL, ZW_IDPED, ZW_EMISSAO, ZW_HORAINC, ZW_DATAAPR,ZW_HORAAPR , ZW_ENVWF, ZW_FECENT, ZW_STATUS, SA1.A1_NOME
		, VEND.A3_COD, VEND.A3_NOME
		, COOR.A3_COD, COOR.A3_NOME
		, GER.A3_COD,  GER.A3_NOME
		FROM %table:SZW% SZW
		LEFT JOIN %table:SA1% SA1  ON A1_COD       = ZW_CLIENTE AND A1_LOJA = ZW_LOJACLI  
		LEFT JOIN %table:SA3% VEND ON VEND.A3_COD  = ZW_VEND1 
		LEFT JOIN %table:SA3% COOR ON COOR.A3_COD  = VEND.A3_SUPER 
		LEFT JOIN %table:SA3% GER  ON GER.A3_COD   = VEND.A3_GEREN
		where SZW.%NotDel%
	    AND GER.%NotDel%
		AND COOR.%NotDel%
		AND VEND.%NotDel%
		AND SA1.%NotDel% 
		and zw_numped = ' ' 
		and zw_emissao >= '20210101'
		and zw_Status <>'R'
		and ZW_BLOPRC = 'B'
		AND SZW.ZW_NUMPED = ' ' 
		AND EXISTS (SELECT 'Y' FROM %table:SZW% szw2 where szw2.%NotDel% and szw2.zw_idped =szw.zw_idped and szw2.ZW_BLOPRC = 'B' ) 
		GROUP BY ZW_FILIAL, ZW_IDPED, ZW_EMISSAO, ZW_HORAINC, ZW_DATAAPR,ZW_HORAAPR , ZW_ENVWF, ZW_FECENT , ZW_STATUS ,SA1.A1_NOME , VEND.A3_COD, VEND.A3_NOME , COOR.A3_COD, COOR.A3_NOME , GER.A3_COD, GER.A3_NOME 
		ORDER BY ZW_ENVWF, ZW_STATUS,ZW_EMISSAO,ZW_IDPED, ZW_EMISSAO, ZW_HORAINC, ZW_DATAAPR,ZW_HORAAPR , ZW_FECENT
	EndSql

	dbSelectArea(_cAliasSZW)
	(_cAliasSZW)->(DbGoTop())

	DO While (_cAliasSZW)->(!EOF())
		dDtEmissao := Stod((_cAliasSZW)->ZW_EMISSAO)
		nHoraEmis  := (_cAliasSZW)->ZW_HORAINC
		dDtAprov   := Stod((_cAliasSZW)->ZW_DATAAPR)
		nHoraAprov := (_cAliasSZW)->ZW_HORAAPR
		cHoraAtual := SUBSTR(TIME(),1,5)

		If (_cAliasSZW)->ZW_STATUS = 'A'

			_nqtdHoras := NGCALENHORA(Stod((_cAliasSZW)->ZW_EMISSAO),(_cAliasSZW)->ZW_HORAINC,Date(),SUBSTR(TIME(),1,5),Alltrim(_cCalendario))
			_cMotivo := "Recusado por falta de Avaliação do Coordenador. Tempo em Espera: "

		ELSEIF (_cAliasSZW)->ZW_STATUS = "P"

			If Empty(Alltrim((_cAliasSZW)->ZW_DATAAPR))
				_nqtdHoras := NGCALENHORA(Stod((_cAliasSZW)->ZW_EMISSAO),(_cAliasSZW)->ZW_HORAINC,Date(),SUBSTR(TIME(),1,5),Alltrim(_cCalendario))
				_cMotivo := "Recusado por falta de Avaliação do Coordenador.  Tempo em Espera: "
			Else
				_nqtdHoras := NGCALENHORA(Stod((_cAliasSZW)->ZW_DATAAPR),(_cAliasSZW)->ZW_HORAAPR,Date(),SUBSTR(TIME(),1,5),Alltrim(_cCalendario))
				_cMotivo := "Recusado por falta de Avaliação do Gerente.  Tempo em Espera:"
			ENDIF

		ENDIF

		If _nqtdHoras >= _nQtdRecusar
			_cMotivo := _cMotivo + " " + U_MOMS50DT(_nqtdHoras) + " hh:mm "
			Aadd(_aPedRecusar, {(_cAliasSZW)->ZW_FILIAL,(_cAliasSZW)->ZW_IDPED,_cMotivo })
		EndIf
		(_cAliasSZW)->(DbSkip())

	EndDo

	DbSelectArea(_cAliasSZW)
	DbCloseArea()

	If LEN(_aPedRecusar) > 0

		DbSelectArea("SZW")
		SZW->(DBSETORDER(1))

		FOR _nCont := 1 TO LEN(_aPedRecusar)

			U_AOM112RC(_aPedRecusar[_nCont][1], _aPedRecusar[_nCont][2],_aPedRecusar[_nCont][3])

		NEXT _nCont

	EndIf

Return

/*
===============================================================================================================================
Programa----------: MOMS50DT
Autor-------------: Jerry
Data da Criacao---: 08/04/2022
===============================================================================================================================
Descrição---------: Rotina Calcular hora para recusar o pedido portal
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: cHora
===============================================================================================================================
*/

User Function MOMS50DT(nValor, cSepar)
	Local cHora := ""
	Local cMinutos := ""
	Default cSepar := ":"
	Default nValor := -1

	//Se for valores negativos, retorna a hora atual
	If nValor < 0
		cHora := SubStr(Time(), 1, 5)
		cHora := StrTran(cHora, ':', cSepar)

		//Senão, transforma o valor numérico
	Else
		cHora := Alltrim(Transform(nValor, "@E 999.99"))

		//Se o tamanho da hora for menor que 5, adiciona zeros a esquerda
		If Len(cHora) < 5
			cHora := Replicate('0', 5-Len(cHora)) + cHora
		EndIf

		//Fazendo tratamento para minutos
		cMinutos := SubStr(cHora, At(',', cHora)+1, 2)
		cMinutos := StrZero((Val(cMinutos)*60)/100, 2)

		//Atualiza a hora com os novos minutos
		cHora := SubStr(cHora, 1, At(',', cHora))+cMinutos

		//Atualizando o separador
		cHora := StrTran(cHora, ',', cSepar)
	EndIf

Return cHora

Static Function MOMS050ALT()

	Local _cAliasSC5   := GetNextAlias()
	Local _cStatus    := '01'
	Local _nConta     := 0

	//===============================================================
	// Verifica se ja existe um arquivo com mesmo nome, se sim deleta.
	//===============================================================

	If Select(_cAliasSC5) <> 0

		(_cAliasSC5)->(dbCloseArea())

	EndIf

	BeginSql alias _cAliasSC5
		
		SELECT SC5.r_e_c_n_o_ RECSC5, C5_EMISSAO, C5_I_ENVRD, C5_I_DTRET,C5_I_IDPED,C5_I_BLPRC ,C5_I_DTLIP,C5_I_HLIBP,C5_I_MOTLP,C5_I_ULIBP,C5_I_MLIBP,C5_I_PLIBP,C5_I_CDUSU, c5_nota, sc5.* 
		FROM siga.sc5010 SC5, SIGA.SZW010 SZWB
		WHERE SC5.d_e_l_e_t_ = ' '
		AND C5_EMISSAO >= '20220401'
		and C5_TIPO = 'N'
		and C5_I_ENVRD = 'S'
		AND C5_I_OPER IN ( '01','25','42','24','10','05')
		AND  SC5.C5_I_IDPED <> ' ' 
		AND SC5.C5_NOTA = ' '
		AND SZWB.ZW_FILIAL (+)= C5_FILIAL 
		AND SZWB.ZW_IDPED (+)= C5_I_IDPED 
		AND SZWB.ZW_ITEM (+)= 1
		ORDER BY SC5.C5_FILIAL, SC5.C5_NUM

	EndSql

	dbSelectArea(_cAliasSC5)
	(_cAliasSC5)->(DbGoTop())

	dbSelectArea("SC5")

	DO While (_cAliasSC5)->(!EOF())

		SC5->(DBGoTo((_cAliasSC5)->RECSC5))

		_cStatus := U_STPEDIDO() //Função de análise do pedido de vendas no xfunoms

		If Alltrim(_cStatus) != Alltrim(SC5->C5_I_STATU)
			_nConta++

			If SC5->C5_I_ENVRD == "S"

				U_ENVSITPV()   //Envia interface de alteração de situação do pedido atual

			Endif
		EndIf
		(_cAliasSC5)->(DbSkip())
	EndDo

Return


/*
===============================================================================================================================
Programa----------: MOMS050B
Autor-------------: Igor Melgaço
Data da Criacao---: 03/06/2022
===============================================================================================================================
Descrição---------: Rotina responsavel pelo envio de workflow de liberação de Bonificação.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS050B(_cFil,_cCodVen, _cTipoApr, _cMailApr,_cNumPV,_RECNO, _cObsAprov,_cCodApr,_cTipoOP)
	Static _nValAtraso	:= 0
	Static _nValPed     := 0
	Local _aArea		:= GetArea()
	Local _aAreaSZW		:= SZW->(GetArea())
	Local _cHostWF  	:= U_ItGetMv("IT_WFHOSTS","http://wfteste.italac.com.br:4043/")
	Local _cLogo		:= _cHostWF + "htm/logo_novo.jpg"
	Local _nMCusto		:= 0
	Local _cCodiApr		:= ""
	Local _cNomeApr		:= ""
	Local _cFilApr		:= ""
	Local _cFilial		:= _cFil
	Local _nMCustoCli	:= 0
	Local _nLimCred		:= 0
	Local _nSalPed 		:= 0
	Local _nSalPedL		:= 0
	Local _nSalDupM		:= 0
	Local _nLcFin		:= 0
	Local _nSalFinM		:= 0
	Local _nSalDup		:= 0
	Local _nSalFin		:= 0
	Local _nMoeda		:= 0
	Local _cQryDA1		:= ""
	Local _aVlrDesc		:= {}
	Local _nRecnoSZW    := _RECNO
	Local _lExecSelect  := .T.
	Local _cGetSolB     := "Bonificação"
	Local _cTipo        := POSICIONE("SA3",1,xFilial("SA3")+_cCodApr,"A3_I_TIPV")
	Local _cTpcarg      := "F"
	Local _cCalcSuframa := "NÃO"
	Local _cCodCoord    := ""
	Local _cCodGeren    := ""
	Local _cTipoAg      := ""
	Local _cEnvio       := "ENVIO"
	Local _nCalcPesoBruto := 0
	Local _nPesBruTotItem := 0
	//Local _cDesctab       := ""
	//Local _nPesoFaixa     := 0

	If IsInCallStack("U_MOMS050R") .OR. IsInCallStack("REENVAPR")//QUANDO APERTA OS BOTOES NO HTML
		_lExecSelect := .T.
	EndIf

	If IsInCallStack("U_MOMS050R") .OR. IsInCallStack("REENVAPR")//QUANDO APERTA OS BOTOES NO HTML
		_cEnvio :="REENVIO"
	Else
		_cEnvio :="ENVIO"
	EndIf

	_cCodiApr	:= _cCodApr
	_cNomeApr	:= POSICIONE("SA3",1, xFilial("SA3")+_cCodApr, "A3_NOME")
	_cFilApr	:= _cFil

	//Codigo do processo cadastrado no CFG
	_cCodProce := "LIBPVBON"

	// Arquivo html template utilizado para montagem da aprovação
	_cHtmlMode := "\Workflow\htm\libportal_bon.htm"

	// Inicialize a classe TWFProcess e assinale a variável objeto oProcess:
	_oProcess := TWFProcess():New(_cCodProce,"Liberação de Bonificação")

	SZW->(DbGoTo(_RECNO)) // Ao rodar o comando TWFProcess():New, a tabela SZW estava sendo desposicionada. Esta instrução reposiciona a tabela SZW.

	_oProcess:NewTask("Liberacao_BON", _cHtmlMode)

	//======================================
	//Dados do cabeçalho do pedido de vendas
	//======================================
	_oProcess:oHtml:ValByName("cLogo", _cLogo)

	//====================
	//Dados do Solicitante
	//====================
	_oProcess:oHtml:ValByName("cCodSol"			, _cCodVen)
	_oProcess:oHtml:ValByName("cNomSol"			, AllTrim(POSICIONE("SA3",1, xFilial("SA3")+_cCodVen, "A3_NOME")))
	_oProcess:oHtml:ValByName("cMaiSol"			, SA3->A3_EMAIL)
	_oProcess:oHtml:ValByName("cFilSol"			, _cFil + ' - ' + AllTrim(FWFilialName(cEmpAnt,_cFil,1)))
	_oProcess:oHtml:ValByName("cNumPVSol"		, AllTrim(_cNumPV))
	_oProcess:oHtml:ValByName("cDtAtu"			, DtoC(Date()) + " - " + Time())
	_oProcess:oHtml:ValByName("cTipo"           , IIF(_cTipo == "C","Coordenador", "Gerente"))
	
	_oProcess:oHtml:ValByName("cTipOper"		, "BONIFICACAO"			)

	_oProcess:oHtml:ValByName("cCodApr"			, _cCodiApr			)
	_oProcess:oHtml:ValByName("cNomApr"			, AllTrim(_cNomeApr))

	_oProcess:oHtml:ValByName("cCodRep"			, _cCodVen      			)
	_oProcess:oHtml:ValByName("cNomRep"			, AllTrim(POSICIONE("SA3",1,xFilial("SA3")+_cCodVen, "A3_NOME"))   	)

	_cCodCoord := POSICIONE("SA3",1, xFilial("SA3")+_cCodVen, "A3_SUPER")
	_oProcess:oHtml:ValByName("cCodCoo"			, _cCodCoord  				)
	_oProcess:oHtml:ValByName("cNomCoo"			, AllTrim(POSICIONE("SA3",1,xFilial("SA3")+_cCodCoord, "A3_NOME"))	)

	_cCodGeren := POSICIONE("SA3",1, xFilial("SA3")+_cCodVen, "A3_GEREN")

	_oProcess:oHtml:ValByName("cCodGer"			, _cCodGeren        			)
	_oProcess:oHtml:ValByName("cNomGer"			, AllTrim(POSICIONE("SA3",1, xFilial("SA3")+_cCodGeren,"A3_NOME"))	)

	//===============
	//Dados do Pedido
	//===============
	_oProcess:oHtml:ValByName("cNumPV"			, _cNumPV		)
	DbSelectArea("SZW")
	SZW->(DBGOTO(_nRecnoSZW))

	_oProcess:oHtml:ValByName("cTipoPV"			, POSICIONE("ZB4",1,xFilial("ZB4")+SZW->ZW_TIPO, "ZB4_DESCRI")				)


	_oProcess:oHtml:ValByName("cFilPV"			, _cFil + " - " + AllTrim(FWFilialName(cEmpAnt,_cFil,1)))
	_oProcess:oHtml:ValByName("cEmisPV"			, DtoC(SZW->ZW_EMISSAO)	                            	)

	//================
	//Dados do Cliente
	//================

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1") + SZW->ZW_CLIENTE + SZW->ZW_LOJACLI)

	// Assunto da mensagem
	IF _cTipo == "C"
		_cAssunto := "Sol.Coord. para Liberação de BONIFICAÇÃO, Pedido Portal " + Alltrim(_cNumPV) + " CNPJ " + MOMS050CPF(SA1->A1_CGC) + " " + Alltrim(A1_NOME) + " - " + _cFilApr + " " + AllTrim(FWFilialName(cEmpAnt,_cFilApr,1))  + " --> " + _cEnvio
	ELSE
		_cAssunto := "Sol.Gerente para Liberação de BONIFICAÇÃO, Pedido Portal " + Alltrim(_cNumPV) + " CNPJ " + MOMS050CPF(SA1->A1_CGC) + " " + Alltrim(A1_NOME) + " - " + _cFilApr + " " + AllTrim(FWFilialName(cEmpAnt,_cFilApr,1))  + " --> " + _cEnvio
	ENDIF

	dbSelectArea("SE4")
	dbSetOrder(1)
	dbSeek(xFilial("SE4") + SA1->A1_COND)
	_oProcess:oHtml:ValByName("cCondPgPad"		, SE4->E4_CODIGO + " - " + SE4->E4_DESCRI	)

	If SA1->A1_CALCSUF = "I"
		_cCalculSuframa:= "ICMS"
	ElseIf SA1->A1_CALCSUF = "S"
		_cCalculSuframa:= "SIM"
	Else
		_cCalculSuframa:= "NÃO"
	EndIf

	_oProcess:oHtml:ValByName("cNomCli"			, SA1->A1_NOME				)
	_oProcess:oHtml:ValByName("cNomRed"			, SA1->A1_NREDUZ			)
	_oProcess:oHtml:ValByName("cCodCli"			, SA1->A1_COD				)
	_oProcess:oHtml:ValByName("cLojCli"			, SA1->A1_LOJA				)
	_oProcess:oHtml:ValByName("cCnpjCli"		, MOMS050CPF(SA1->A1_CGC)	)
	_oProcess:oHtml:ValByName("cGrpVen"			, SA1->A1_GRPVEN + " - " + Posicione("ACY",1,xFilial("ACY") + SA1->A1_GRPVEN, "ACY_DESCRI")				)
	_oProcess:oHtml:ValByName("cContatCli"		, SA1->A1_CONTATO			)
	_oProcess:oHtml:ValByName("cFoneCli"		, SA1->A1_TEL				)
	_oProcess:oHtml:ValByName("cEmailCli"		, SA1->A1_EMAIL				)
	_oProcess:oHtml:ValByName("cCidCli"			, SA1->A1_MUN				)
	_oProcess:oHtml:ValByName("cEstCli"			, SA1->A1_EST				)
	_oProcess:oHtml:ValByName("cEndCli"			, SA1->A1_END				)
	_oProcess:oHtml:ValByName("cAnaCre"			, SA1->A1_I_ACRED			)
	_oProcess:oHtml:ValByName("cSuframa"		, _cCalcSuframa  			)

	//========================
	//Informarções Financeiras
	//========================
	DBSelectArea("SA1")
	SA1->( DBSetOrder(1) )
	SA1->( DBSeek( xFilial("SA1") + SZW->ZW_CLIENTE ) )

	While SA1->(!Eof()) .And. SA1->A1_COD == SZW->ZW_CLIENTE

		_nMCustoCli	:= IIf( SA1->A1_MOEDALC > 0 , SA1->A1_MOEDALC	, Val(SuperGetMv("MV_MCUSTO")) )
		_nLimCred	+= xMoeda( SA1->A1_LC							, _nMCustoCli , _nMCusto , Date() )
		_nSalPed 	+= xMoeda( SA1->A1_SALPED + SA1->A1_SALPEDB		, _nMCustoCli , _nMCusto , Date() )
		_nSalPedL	+= xMoeda( SA1->A1_SALPEDL						, _nMCustoCli , _nMCusto , Date() )
		_nSalDupM	+= xMoeda( SA1->A1_SALDUPM						, _nMCustoCli , _nMCusto , Date() )
		_nLcFin		+= xMoeda( SA1->A1_LCFIN						, _nMCustoCli , _nMCusto , Date() )
		_nSalFinM	+= xMoeda( SA1->A1_SALFINM						, _nMCustoCli , _nMCusto , Date() )
		_nSalDup	+= SA1->A1_SALDUP
		_nSalFin	+= SA1->A1_SALFIN

		SA1->( DBSkip() )
	EndDo

	DBSelectArea("SA1")
	SA1->( DBSetOrder(1) )
	SA1->( DBSeek( xFilial("SA1") + SZW->ZW_CLIENTE + SZW->ZW_LOJACLI) )

	_nMCusto 	:= IIf( SA1->A1_MOEDALC > 0 , SA1->A1_MOEDALC , VAL( SuperGetMv("MV_MCUSTO") ) )
	_nMoeda		:= 1
	IF _lExecSelect
		_nValAtraso:= MOMS050VSC( SZW->ZW_CLIENTE + SZW->ZW_LOJACLI )
		_nValPed   := MOMS050VT2( SZW->ZW_IDPED , _cFil , 1 )
	ENDIF

	_oProcess:oHtml:ValByName("nLimCrd"			, TRansform(_nLimCred,PesqPict("SA1","A1_LC",17,1)))
	_oProcess:oHtml:ValByName("nTitAber"		, TRansform(_nSalDup,PesqPict("SA1","A1_SALDUP",17,1)))
	_oProcess:oHtml:ValByName("nTitVenc"		, TRansform(_nSalPedL,PesqPict("SA1","A1_SALPEDL",17,1)))
	_oProcess:oHtml:ValByName("nSLimCrd"		, TRansform(_nLimCred-_nSaldupM-_nSalPedL,PesqPict("SA1","A1_SALDUP",17,1)))
	_oProcess:oHtml:ValByName("nPedAtu"			, TRansform(_nValPed ,PesqPict("SA1","A1_SALDUP",17,1)))
	_oProcess:oHtml:ValByName("nSalNFat"		, TRansform(_nSalPed ,PesqPict("SA1","A1_SALPED",17,1)))
	_oProcess:oHtml:ValByName("nLimCChe"		, TRansform(_nLcFin ,PesqPict("SA1","A1_LCFIN",17,1)))
	_oProcess:oHtml:ValByName("nSldChq"			, TRansform(_nSalFin ,PesqPict("SA1","A1_SALDUP",17,1)))
	_oProcess:oHtml:ValByName("nTitProt"		, STR(SA1->A1_TITPROT,3))
	_oProcess:oHtml:ValByName("nChqDev"			, STR(SA1->A1_CHQDEVO,3))
	_oProcess:oHtml:ValByName("nMComp"			, Transform(SA1->A1_MCOMPRA ,PesqPict("SA1","A1_MCOMPRA",17,_nMCusto)))
	_oProcess:oHtml:ValByName("nMDuplic"		, Transform(SA1->A1_MAIDUPL ,PesqPict("SA1","A1_MAIDUPL",17,_nMCusto)))
	_oProcess:oHtml:ValByName("nMAtras"			, Transform(SA1->A1_METR ,PesqPict("SA1","A1_METR",7)))
	_oProcess:oHtml:ValByName("cVenLCr"			, DtoC(SA1->A1_VENCLC))
	_oProcess:oHtml:ValByName("cDtLiLib"		, DtoC(StoD("")))
	_oProcess:oHtml:ValByName("nAtraAtu"		, TRansform(_nValAtraso ,PesqPict("SA1","A1_SALDUP",17,1)))

	//==================
	//Posição do Cliente
	//==================

	_oProcess:oHtml:ValByName("nLimCrl"			, TRansform(SA1->A1_LC,PesqPict("SA1","A1_LC",14,_nMCusto)))
	_oProcess:oHtml:ValByName("nSldHist"		, TRansform(SA1->A1_SALDUP,PesqPict("SA1","A1_SALDUP",14,1)))
	_oProcess:oHtml:ValByName("nLimcSec"		, TRansform(Round(Noround(xMoeda(SA1->A1_LCFIN,_nMcusto,1,dDatabase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_LCFIN",14,1)),TRansform(SA1->A1_LCFIN,PesqPict("SA1","A1_LCFIN",14,_nMcusto)))
	_oProcess:oHtml:ValByName("nSldLcSe"		, TRansform(SA1->A1_SALFIN,PesqPict("SA1","A1_SALFIN",14,1)))
	_oProcess:oHtml:ValByName("nMaiCom"			, TRansform(Round(Noround(xMoeda(SA1->A1_MCOMPRA, _nMcusto ,1, dDataBase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_MCOMPRA",14,1)),TRansform(SA1->A1_MCOMPRA,PesqPict("SA1","A1_MCOMPRA",14,_nMcusto)))
	_oProcess:oHtml:ValByName("nMaiSld"			, TRansform(Round(Noround(xMoeda(SA1->A1_MSALDO, _nMcusto ,1, dDataBase,MsDecimais(1)+1 ),2),MsDecimais(1)),PesqPict("SA1","A1_MSALDO",14,1)))
	_oProcess:oHtml:ValByName("cPriCom"			, DtoC(SA1->A1_PRICOM))
	_oProcess:oHtml:ValByName("cUltCom"			, DtoC(SA1->A1_ULTCOM))
	_oProcess:oHtml:ValByName("nMaiAtr"			, Transform(SA1->A1_MATR,PesqPict("SA1","A1_MATR",14)))
	_oProcess:oHtml:ValByName("nMedAtr"			, PADC(STR(SA1->A1_METR,7,2),22))
	_oProcess:oHtml:ValByName("cGrauRis"		, SA1->A1_RISCO)


	//===============================
	//Informações do Pedido de Vendas
	//===============================
	If SZW->ZW_TPFRETE == "C"
		_oProcess:oHtml:ValByName("cFrete"			, "CIF"					)
	ElseIf SZW->ZW_TPFRETE == "F"
		_oProcess:oHtml:ValByName("cFrete"			, "FOB"					)
	ElseIf SZW->ZW_TPFRETE == "T"
		_oProcess:oHtml:ValByName("cFrete"			, "TERCEIROS"			)
	ElseIf SZW->ZW_TPFRETE == "S"
		_oProcess:oHtml:ValByName("cFrete"			, "Sem Frete"			)
	EndIf

//	If SZW->ZW_I_ AGEND == 'P'
//		_cTipoAg		:= SZW->ZW_I_ AGEND+" - AGUARD AGENDA"
//	Elseif SZW->ZW_I_ AGEND == 'I'
//		_cTipoAg		:= SZW->ZW_I_ AGEND+" - IMEDIATO"
//	ElseIf SZW->ZW_I_ AGEND == 'M'
//		_cTipoAg		:= SZW->ZW_I_ AGEND+" - AGENDADA COM MULTA"
//	Else
//		_cTipoAg		:= SZW->ZW_I_ AGEND+" - AGENDADA"
//	Endif
	_cTipoAg:=SZW->ZW_I_AGEND+" - "+U_TipoEntrega(SZW->ZW_I_AGEND)

	_oProcess:oHtml:ValByName("cTpCarga"		, Iif(SZW->ZW_TIPCAR == "1", SZW->ZW_TIPCAR + " - Paletizada", Iif(SZW->ZW_TIPCAR == "2", SZW->ZW_TIPCAR + " - Batida", "")))
	_oProcess:oHtml:ValByName("nQtdChap"		, SZW->ZW_CHAPA  			)
	_oProcess:oHtml:ValByName("cHrDescg"		, SZW->ZW_HORDES			)
	_oProcess:oHtml:ValByName("nCusCarg"		, "0"						)
	_oProcess:oHtml:ValByName("dDtEntrega"		, SZW->ZW_FECENT 			)
	_oProcess:oHtml:ValByName("cHrEntrega"		, SZW->ZW_HOREN  			)
	_oProcess:oHtml:ValByName("cSenhaEntr"		, SZW->ZW_SENHA    			)
	_oProcess:oHtml:ValByName("cTipoAgenda"		, _cTipoAg       			)
	_oProcess:oHtml:ValByName("cCarga"          , IIF(AllTrim(SZW->ZW_TPVENDA) == "F" .AND. SZW->ZW_TPVENDA != "", " F - Fechada", " V - Fracionada"))
	_oProcess:oHtml:ValByName("cEnvio"			, _cEnvio       			)
	_oProcess:oHtml:ValByName("cMensNF"			, SZW->ZW_MENNOTA			)
	_oProcess:oHtml:ValByName("cObsPed"			, SZW->ZW_OBSCOM 			)

	//=========================================================================
	// Dados de Aprovação quando Retorno é do Coordenador
	//=========================================================================
	If SZW->ZW_ENVWF = 'C'
		_oProcess:oHtml:ValByName("cGetObsCoord", _cObsAprov	     	)
		_oProcess:oHtml:ValByName("cDataAprov"	, DtoC(Date())	)
		_oProcess:oHtml:ValByName("cHoraAprov"	, Time()		)
	Else
		_oProcess:oHtml:ValByName("cGetObsCoord", SZW->ZW_ULIBP )
		_oProcess:oHtml:ValByName("cDataAprov"	, SZW->ZW_HLIBP	)
		_oProcess:oHtml:ValByName("cHoraAprov"	, SZW->ZW_DLIBP   )
	EndIF

	//=========================================
	//Informações dos itens do Pedido de Vendas
	//=========================================
	dbSelectArea("SZW")
	dbSetOrder(1)
	dbSeek(_cFil + _cNumPV)

	_nCalcPesoBruto := 0
	_nPesoBrut := MOMS050PESO(SZW->ZW_FILIAL,SZW->ZW_IDPED)
	dbSelectArea("SZW")
	dbSetOrder(1)
	dbSeek(_cFil + _cNumPV)
	SA1->(Dbsetorder(1))
	SA1->(Dbseek(xfilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI))
	If SA1->A1_SIMPNAC == "1"
		_lSimplNac := .T. // O cliente é optante do Simples Nacional
	Else
		_lSimplNac := .F. // O cliente não é Optante do Simples Nacional
	EndIf
	//_cCoord     := POSICIONE("SA3",1,xFilial("SA3")+SZW->ZW_VEND1,"A3_SUPER")
	//_cGerente   := POSICIONE("SA3",1,xFilial("SA3")+SZW->ZW_VEND1,"A3_GEREN")
	//_cCoordWF   := POSICIONE("SA3",1,xFilial("SA3")+_cCoord,"A3_I_WF")

	While !SZW->(Eof()) .And. SZW->ZW_FILIAL == _cFil .And. AllTrim(SZW->ZW_IDPED) == AllTrim(_cNumPV)

		aAdd( _oProcess:oHtml:ValByName("Itens.cItem" 			), SZW->ZW_ITEM																		)
		aAdd( _oProcess:oHtml:ValByName("Itens.cProdPV" 		), SZW->ZW_PRODUTO								 									)
		aAdd( _oProcess:oHtml:ValByName("Itens.cDescPV"			), AllTrim(POSICIONE("SB1",1,xFilial("SB1")+ZW_PRODUTO, "B1_DESC"))					)
		aAdd( _oProcess:oHtml:ValByName("Itens.cNumPCli"		), SZW->ZW_PEDCLI																	)
		aAdd( _oProcess:oHtml:ValByName("Itens.nPrcVen"			), Transform(SZW->ZW_PRCVEN, "@E 999,999,999.999")									)
		aAdd( _oProcess:oHtml:ValByName("Itens.nQuantPV"		), Transform(SZW->ZW_SEGQTD, PesqPict("SZW","ZW_SEGQTD"))							)
		aAdd( _oProcess:oHtml:ValByName("Itens.cUM"				), SZW->ZW_2UM    																	)
		aAdd( _oProcess:oHtml:ValByName("Itens.nTotalPV"	   	), Transform(SZW->ZW_PRCVEN*SZW->ZW_QTDVEN, PesqPict("SC6","C6_VALOR"))				)
		//aAdd( _oProcess:oHtml:ValByName("Itens.nDescont"		), Transform(SZW->ZW_VALDESC, PesqPict("SZW","ZW_VALDESC"))							)

		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xfilial("SB1")+ SZW->ZW_PRODUTO))

		//CALCULA O PESO BRUTO TOTAL DO PEDIDO DE VENDA
		_nPesBruTotItem:=(SB1->B1_PESBRU * SZW->ZW_QTDVEN)

		_nCalcPesoBruto += _nPesBruTotItem

		_ctab := SZW->ZW_TABELA

		_cQryDA1 := "SELECT DA1_PRCVEN, DA1_I_PRCA, DA1_I_PMFE, DA1_I_PMFR, DA1_I_PRFE, "
		_cQryDA1 += " DA1_I_PRF1,DA1_I_PMF1, DA1_I_PRF2, DA1_I_PMF2,DA1_I_PRF3, DA1_I_PMF3 "
		_cQryDA1 += "FROM " + RetSqlName("DA1") + " "
		_cQryDA1 += "WHERE DA1_FILIAL = '" + xFilial("DA1") + "' "
		_cQryDA1 += "  AND DA1_CODTAB = '" + _ctab + "' "
		_cQryDA1 += "  AND DA1_CODPRO = '" + SZW->ZW_PRODUTO + "' "
		_cQryDA1 += "  AND D_E_L_E_T_ = ' ' "

		If Select("TRBDA1") > 0
			TRBDA1->(DbCloseArea())
		EndIf
		dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQryDA1 ) , "TRBDA1" , .T., .F. )

		dbSelectArea("TRBDA1")
		TRBDA1->(dbGoTop())

		DO CASE
		CASE AllTrim(SZW->ZW_TPVENDA) == "F"
			_cTpCarg := "F"
		CASE AllTrim(SZW->ZW_TPVENDA) == "V"
			_cTpCarg := "V"
		ENDCASE

		/*If SZW->ZW_I_FXPES == 3
            _nPesoFaixa := DA0->DA0_I_PES3
        ElseIf SZW->ZW_I_FXPES == 2
            _nPesoFaixa := DA0->DA0_I_PES2
        else
            _nPesoFaixa := DA0->DA0_I_PES1        
        ENDIF*/
		
		_aBlqprc := U_BLQPRC(SZW->ZW_PRODUTO,SZW->ZW_PRCVEN,SZW->ZW_FILIAL,  .F. ,SZW->ZW_TABELA,    .T.,      .T.,          0,           ,         ,SA1->A1_EST,         ,SZW->ZW_TPVENDA,_lSimplNac,_nPesoBrut,SZW->ZW_I_FXPES)
 		_lPrcErr := _aBlqprc[1]
		_nPrecoIt:= _aBlqprc[4]

		If _cEnvio ="ENVIO"
            aAdd( _oProcess:oHtml:ValByName("Itens.nPrcMin"			), Transform(_nPrecoIt, PesqPict("SC6","C6_VALOR")))//IIF(_cTpCarg == "F", TRBDA1->DA1_PRCVEN, TRBDA1->DA1_I_PRFE)
		Else
			aAdd( _oProcess:oHtml:ValByName("Itens.nPrcMin"			), Transform(SZW->ZW_PRUNIT, PesqPict("SC6","C6_VALOR"))					)
		EndIf

		_aVlrDesc	:= U_veriContrato( SZW->ZW_CLIENTE , SZW->ZW_LOJACLI , SZW->ZW_PRODUTO )
		aAdd( _oProcess:oHtml:ValByName("Itens.nPerCon"			), Transform(_aVlrDesc[1], PesqPict("SZW","ZW_I_PRCD"))					)
		aAdd( _oProcess:oHtml:ValByName("Itens.nPrcNet"			), Transform(SZW->ZW_I_PRNET, PesqPict("SZW","ZW_I_PRNET"))	) 
		aAdd( _oProcess:oHtml:ValByName("Itens.nPrcNetKG"		), Transform(SZW->ZW_I_PRNET / SB1->B1_PESO, PesqPict("SZW","ZW_I_PRNET"))	)
		
		If _lPrcErr
			aAdd( _oProcess:oHtml:ValByName("Itens.cCor"), "color=#FF0000" )//VERMELHO
		Else
			aAdd( _oProcess:oHtml:ValByName("Itens.cCor"), "color=#006400" )//VERDE
		EndIf

		/*
			If _aVlrDesc[1] <> 0
				_nPrecoNet := (SZW->ZW_PRCVEN - ( ( _aVlrDesc[1] * SZW->ZW_PRCVEN ) / 100 ))
			Else
				_nPrecoNet := SZW->ZW_PRCVEN
			EndIf

			IF _cTpCarg == "F"
				If (_nPrecoNet < TRBDA1->DA1_PRCVEN .OR. _nPrecoNet > TRBDA1->DA1_I_PRCA)
					aAdd( _oProcess:oHtml:ValByName("Itens.cCor"), "color=#FF0000" )//VERMELHO
				Else
					aAdd( _oProcess:oHtml:ValByName("Itens.cCor"), "color=#006400" )//VERDE
				EndIf
			else
				If (_nPrecoNet < TRBDA1->DA1_I_PRFE .OR. _nPrecoNet > TRBDA1->DA1_I_PRCA)
					aAdd( _oProcess:oHtml:ValByName("Itens.cCor"), "color=#FF0000" )//VERMELHO
				Else
					aAdd( _oProcess:oHtml:ValByName("Itens.cCor"), "color=#006400" )//VERDE
				EndIf
			EndIf
		*/

		dbSelectArea("TRBDA1")
		TRBDA1->(dbCloseArea())

		SZW->(dbSkip())
	End

	_oProcess:oHtml:ValByName("nPesoBruto"		         , TRansform(_nCalcPesoBruto ,PesqPict("SA1","A1_SALDUP",17,1)))

	_oProcess:oHtml:ValByName("cGetSol"		, _cGetSolB		)

	//=========================================================================
	// Informe o nome da função de retorno a ser executada quando a mensagem de
	// respostas retornar ao Workflow:
	//=========================================================================
	_oProcess:bReturn := "U_MOMS050R"

	//========================================================================
	// Após ter repassado todas as informacões necessárias para o Workflow,
	// execute o método Start() para gerar todo o processo e enviar a mensagem
	// ao destinatário.
	//========================================================================
	_cMailID	:= _oProcess:Start("\workflow\emp01")
	_cLink		:= _cMailID

	If File("\workflow\emp01\" + _cMailID + ".htm")
		conout("Arquivo \workflow\emp01\" + _cMailID + ".htm criado com sucesso.")
	ELSE
		conout("Arquivo \workflow\emp01\" + _cMailID + ".htm não encotrado.")
	EndIf

	//====================================
	//Codigo do processo cadastrado no CFG
	//====================================
	_cCodProce := "LIBPVPRC"

	//======================================================================
	// Inicialize a classe TWFProcess e assinale a variável objeto oProcess:
	//======================================================================
	_oProcess := TWFProcess():New(_cCodProce,"Liberação PV Bonificação")

	SZW->(DbGoTo(_nRecnoSZW)) // Ao rodar o comando TWFProcess():New, a tabela SZW estava sendo desposicionada. Esta instrução reposiciona a tabela SZW.

	//=================================================================
	// Criamos o link para o arquivo que foi gerado na tarefa anterior.
	//=================================================================
	_oProcess:NewTask("LINK", "\workflow\htm\pvbonportal_link.htm")

	_chtmlfile	:= _cLink + ".htm"
	_cMailTo	:= "mailto:" + Alltrim(Posicione("WF7", 1, XFilial("WF7") + AllTrim(GetMV('MV_WFMLBOX')), "WF7_ENDERE"))
	_chtmltexto := wfloadfile("\workflow\emp01\" + _chtmlfile )
	_chtmltexto := strtran( _chtmltexto, _cmailto, "WFHTTPRET.APL" )
	wfsavefile("\workflow\emp"+cEmpAnt+"\" + _chtmlfile, _chtmltexto)
	_cLink := _cHostWF + "emp01/" + _cLink + ".htm"

	//=====================================
	// Populo as variáveis do template html
	//=====================================
	_oProcess:oHtml:ValbyName("A_COORD"     , _cNomeApr)
	_oProcess:oHtml:ValByName("cLogo"		, _cLogo)
	_oProcess:oHtml:ValByName("A_FILIAL"	, _cFilial + " - " + FWFilialName(cEmpAnt,_cFilial,1))
	_oProcess:oHtml:ValByName("A_PEDVEN"	, _cNumPV)
	_oProcess:oHtml:ValByName("A_LINK"		, _cLink)
	_oProcess:oHtml:ValByName("A_NOMREP"	, _cCodVen + " - " + POSICIONE("SA3",1, xFilial("SA3")+_cCodVen, "A3_NOME"))
	_oProcess:oHtml:ValByName("A_CLIENTE"	, SA1->A1_COD + "/" + SA1->A1_LOJA + " - " + SA1->A1_NOME)
	_oProcess:oHtml:ValByName("A_LIMCRED"	, TRansform(SA1->A1_LC,PesqPict("SA1","A1_LC",17,1)))
	_oProcess:oHtml:ValByName("A_VLRPED"	, TRansform(_nValPed,PesqPict("SC6","C6_VALOR",17,1)))
	_oProcess:oHtml:ValByName("A_TITPRO"	, STR(SA1->A1_TITPROT,3))
	_oProcess:oHtml:ValByName("A_MCOMP"		, Transform(SA1->A1_MCOMPRA,PesqPict("SA1","A1_MCOMPRA",17,_nMCusto)))
	_oProcess:oHtml:ValByName("A_MDUPL"		, Transform(SA1->A1_MAIDUPL,PesqPict("SA1","A1_MAIDUPL",17,_nMCusto)))
	_oProcess:oHtml:ValByName("A_VLCRED"	, DtoC(SA1->A1_VENCLC))
	_oProcess:oHtml:ValByName("A_DTLIMLB"	, DtoC(StoD("")))
	_oProcess:oHtml:ValByName("A_PCOMP"		, DtoC(SA1->A1_PRICOM))
	_oProcess:oHtml:ValByName("A_UCOMP"		, DtoC(SA1->A1_ULTCOM))
	_oProcess:oHtml:ValByName("A_GRISC"		, SA1->A1_RISCO)
	_oProcess:oHtml:ValByName("cGetSol"		, _cGetSolB)
	_oProcess:oHtml:ValByName("A_RODAP"		, cEnvSrv)

	If SZW->ZW_ENVWF = 'C'
		_oProcess:oHtml:ValByName("cGetObsCoord"		, _cObsAprov)
	else
		_oProcess:oHtml:ValByName("cGetObsCoord"		, " " )
	End

	//================================================================
	// Informamos o destinatário (aprovador) do email contendo o link.
	//================================================================
	 
	_oProcess:cTo  := _cMailApr  
	//=============================== 
	// Informamos o assunto do email.
	//===============================
 
	_oProcess:cSubject	:= FWHttpEncode(_cAssunto)

	_cMailID	:= _oProcess:fProcessId
	_cTaskID	:= _oProcess:fTaskID

	//=======================================================
	// Iniciamos a tarefa e enviamos o email ao destinatário.
	//=======================================================
	_oProcess:Start()

	RestArea(_aArea)
	RestArea(_aAreaSZW)
Return _cLink
