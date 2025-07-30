/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Igor Melga�o  |01/07/2024| Chamado 47184. Jerry. Ajustes para grava��o do campo C6_I_PRMIN
Igor Melga�o  |25/07/2024| Chamado 47204. Jerry. Ajustes para corre��o de error log qdo na transf. multipla de pedido nao tem sele��o de nenhum.
Lucas Borges  |08/10/2024| Chamado 48465. Retirada manipula��o do SX1
==============================================================================================================================================================
Analista    - Programador   - Inicio   - Envio    - Chamado - Motivo da Altera��o
==============================================================================================================================================================
Vanderlei   - Alex Wallauer - 21/03/25 - 24/03/25 - 50197   - Novo tratamento para cortes e desmembramentos de pedidos - GRAVAR: M->C5_I_BLSLD
Vanderlei   - Igor Melga�o  - 06/06/25 - 10/06/25 - 45229   - Ajuste do par�metro p/determinar se a integra��o WebS.ser� TMS Multiembarcador ou RDC
Andre       - Igor Melga�o  - 11/06/25 - 11/07/25 - 50716   - Ajustes para busca de pre�o do produto na tabela Z09, para pedidos de transfer�ncia entre filiais
==============================================================================================================================================================
*/   
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
#Include "TopConn.ch"
#Include "vkey.ch"
 
#DEFINE _ENTER CHR(13)+CHR(10)
#DEFINE _MAX_NR_PEDIDOS 100  // Numero m�ximo de pedidos que podem ser transferidos.

/*   
===============================================================================================================================
Programa----------: AOMS032
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 13/04/2010
===============================================================================================================================
Descri��o---------: Funcao utilizada para realizar a transferencias entre filiais dos pedidos de venda.
===============================================================================================================================
Parametros--------: _cTipoTransf = "P" = Pedido de venda Posicionado.
                                 = "V" = Varios pedidos de vendas.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS032(_cTipoTransf)

	Local _cSelectZZM := NIL

	Private nRadMenu1 := 1
	Private cMarca   := GetMark()

    Private _aTrocaNf	:= {"Sim","N�o"}
	Private _aMsgVld    := {}
	Private _aItalac_F3 := {}
	Private _cFilDestino := Space(2)
	Private _cFilTran    := Space(2)
	Private _cTrocaNf := _aTrocaNf[2] // "Nao" 
	Private _cOper25  := "  "
	Private _cLocal   := "  "
	Private _cFilFatur := Space(2) 
	Private _cFilCarreg := Space(2) 
	//Private _cFilOpera  := U_ITGETMV( "IT_FILOPER","90;93")
	//Private _cFilLocal  := U_ITGETMV( "IT_FILLOCL","90;93")
	Private _cFilDifer  := U_ITGETMV( "IT_FILDIFE","90;93")
	Private _cOperTran  := U_ITGETMV( "IT_OPTRANF","42")
	Private _oOper25, _oLocal

    Private _cFilOrigI := U_ITGETMV( "IT_FILORGI","90;93")           // Filiais de Origens Iguais     
    Private _cFilDDesI := U_ITGETMV( "IT_FILDSTI","01;10;23;20;40;") // Filiais de Destino Iguais     
	Private _cFilOrigD := U_ITGETMV( "IT_FILORGD","90;93")           // Filiais de Origens Diferentes 
    Private _cFilDDesD := U_ITGETMV( "IT_FILDSTD","90;93")           // Filiais de Destino Diferentes 
	Private _cFilLogA  := U_ITGETMV( "IT_FILLOGA","90")              // Filial logada A 
	Private _cFilLogB  := U_ITGETMV( "IT_FILLOGB","93")              // Filial logada B 
	Private _cOperacA  := U_ITGETMV( "IT_OPRTRNA","01")              // Opera��o de Transfer�ncia A 
	Private _cOperacB  := U_ITGETMV( "IT_OPRTRNB","26")              // Opera��o de Transfer�ncia B 
    Private _cFilDeFat := U_ITGETMV( "IT_FILFATU","90")              // Filiais de Furamento        
	Private _cOperacC  := U_ITGETMV( "IT_OPERTRC","25")              // Opera��o de Transfer�ncia C
	Private aCols     := {}
	Private aHeader   := {}
    Private _oTrocaNf, _oFilFatur

	Begin Sequence
		_cSelectZZM := " SELECT ZZM_CODIGO, ZZM_DESCRI FROM " + RETSQLNAME("ZZM") + " WHERE D_E_L_E_T_ = ' ' AND ZZM_CODIGO <> '" + xFilial('SC5') + "' "
		_cSelectZZM += " ORDER BY ZZM_CODIGO "

		//AD(_aItalac_F3,{"MV_PAR15"    ,_cTabela   ,_nCpoChave                , _nCpoDesc               ,_bCondTab , _cTitAux         , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
		AADD(_aItalac_F3,{"MV_PAR15"    ,_cSelectZZM,{|Tab| (Tab)->ZZM_CODIGO} ,{|Tab|(Tab)->ZZM_DESCRI} ,          ,"Lista de Filiais", 2        ,          , 1   } )
		AADD(_aItalac_F3,{"_cFilDestino",_cSelectZZM,{|Tab| (Tab)->ZZM_CODIGO} ,{|Tab|(Tab)->ZZM_DESCRI} ,          ,"Lista de Filiais", 2        ,          , 1   } )

		//================================================================================
		// Verifica se o usuario possui alguma filial de transferencia cadastrada
		//================================================================================
		DBSelectArea("ZZL")
		ZZL->( DBSetOrder(3) )
		IF ZZL->( DBSeek( xFilial("ZZL") + RetCodUsr() ) )
			
			If Empty( ZZL->ZZL_FILTRA )
				U_ITmsg("O usuario n�o possui acesso � nenhuma filial de transfer�ncia de pedido de venda cadastrada."	,;
					"Aten��o!"																						,;
					"Favor informar a equipe de TI/ERP comunicando o problema, para verificar o cadastro no CFG.",1)
				Break
			EndIf
		Else
			U_ITmsg("O usuario n�o foi encontrado no cadastro de acessos do M�dulo Configurador Italac.",;
				"Aten��o!"																,;
				"Favor informar a equipe de TI/ERP comunicando o problema, para verificar o cadastro no CFG.",1)
			Break
		EndIf

		If _cTipoTransf = "P"
			If ! U_AOMS032B()
				Break
			EndIf

			nRadMenu1 := 1
		Else
			nRadMenu1 := 2
		EndIf

		AOMS032INI()

	End Sequence

Return()

/*
===============================================================================================================================
Programa----------: AOMS032INI
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 13/04/2010
===============================================================================================================================
Descri��o---------: Funcao que controla o processamento da transfer�ncia
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS032INI()
	Local _lRet := .T.
	Local _lExibeTela := .T.
	Local _cGrupoP	:= ''
	Local aTabnZ	:= {}

	Private cMarkado	:= GetMark()
	Private lInverte	:= .F.

	Private cPerg		:= 'AOMS032'

	Private cIndTRB1	:= 'TRBT_NUM'
	Private cIndTRB2	:= 'TRBT_CODCL+TRBT_LOJCL'
	Private cIndTRB3	:= 'TRBT_DESCL'
	Private cIndTRB4	:= 'TRBT_DESCR'

	Private aCampos		:= {}

	Begin Sequence
		//================================================================================
		// Op��o de Transferencia de Varios Pedidos
		//================================================================================
		If nRadMenu1 == 2

			_lExibeTela :=  .F.

			//================================================================================
			// Tela de Parametros
			//================================================================================
			Do While .T.
				If !Pergunte( cPerg , .T. )
					_lRet := .F.
					Break
				EndIf 

				If Empty(MV_PAR15)
					U_ITmsg("N�o foi informado a filial de destino na tela de par�metros iniciais.","Aten��o","Para prosseguir com a transfer�ncia de Pedidos de Vendas, deve-se informar uma filial de destino na tela de par�metros iniciais.",1)
					Loop
				EndIf

				If AllTrim(MV_PAR15) == xFilial("SC5")
					U_ITmsg("A filial de destino n�o pode ser igual a filial de origem.","Aten��o","Informe uma filial de destino diferente da filial de origem.",1)
					Loop
				EndIf

				If MV_PAR16 == 2 .And. Empty(MV_PAR17)
					U_ITmsg("Op��o troca nota selecionada. A filial de faturamento deve ser preenchida.","Aten��o",,1)
					Loop
				EndIf

				If Empty(MV_PAR18) 
				   U_ITmsg("O preenchimento da opera��o do pedido de vendas � obrigat�rio.","Aten��o",,1)
				   Loop
				EndIf
              
			    _cFilDestino := AllTrim(MV_PAR15)
				_cOper25 := MV_PAR18
				_cLocal  := MV_PAR19
                _cOper25    := MV_PAR18
				_cLocal     := MV_PAR19 
                _cTrocaNf   := _aTrocaNf[2] // "Nao"
                _cFilFatur  := "  "
				_cFilCarreg := "  "

                If MV_PAR16 == 2 // Sim = op��o troca nota selecionda  
					_cTrocaNf := _aTrocaNf[1] // "Sim"
					_cFilFatur := MV_PAR17
					_cFilCarreg := MV_PAR15
				EndIf

				If ! U_AOMS032Y("TROCA_NOTA", _cTrocaNf, "L")   
                   Loop 
                EndIf  

                If (_cTrocaNf == _aTrocaNf[1]) .And. ! U_AOMS032Y("FILIAL_FATURAMENTO", _cFilFatur, "L") 
                   Loop 
                EndIf  

                If ! U_AOMS032Y('OPERACAO', _cOper25, "L")  
                   Loop 
                EndIf  

                If ! U_AOMS032Y("LOCAL", _cLocal , "L")   
                   Loop 
                EndIf  

				Exit
			EndDo
			//================================================================================
			// Posicionado 
			//================================================================================
		Else
			//Valida��o do Tratamento da Opera��o Triangular
			If !Empty(SC5->C5_LIBEROK) .Or. !Empty(SC5->C5_NOTA) .Or. !Empty(SC5->C5_BLQ) 

				U_ITmsg("Este pedido de venda n�o pode ser transferido para outra Filial."													,;
					"ATEN��O",;
					"Favor selecionar um pedido de venda que esteja com o status verde (Em aberto) "	+; //"ou que n�o seja Pedido de Venda / Remessa da Opera��o Triangular , "	+; 
					"ou selecione o modo de transferencia de v�rios pedidos.",1)
				_lRet := .F.
				Break

			EndIf

			If !EMPTY(SC5->C5_I_PDFT) .OR. !EMPTY(SC5->C5_I_PDPR)

				U_ITmsg("Este pedido de TROCA NOTA n�o pode ser transferido, pois j� foram gerados os Pedidos de Carregamento / Faturamento.",;
					"Aten��o! (AOMS032)"																						,;
					"Favor selecionar um pedido de venda que esteja com o status verde (Em aberto) e que n�o seja um pedido de TROCA NOTA que tenha Pedidos Gerados.",1)

				_lRet := .F.
				Break

			EndIf

			If !EMPTY(SC5->C5_I_PEVIN)

				U_ITmsg("Este pedido possui um pedido vinculado: "+SC5->C5_I_PEVIN,;
					"Aten��o!"																						,;
					'Para transferir esse pedido use a opcao "V�rios Pedidos" e selecione o Pedido Atual e o Pedido Vinculado para transferir os dois juntos.',1)

				_lRet := .F.
				Break

			EndIf


			//Valida se o retorno da u_ittabprc corresponde a regra 3 Chamado: 33393
			_cGrupoP := Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_GRUPO")
			          //ittabprc(_c5filgct     ,_c5filft      ,_cvend3      ,_cvend2      ,_cvend       ,_ccliente      ,_clojacli      ,_lusanovo,_cTab        ,_cVend4      , _cRede         , _cGrupoPrd ,_cTipoOper)
			aTabnZ := u_ittabprc(SC5->C5_FILIAL,SC5->C5_FILIAL,SC5->C5_VEND3,SC5->C5_VEND2,SC5->C5_VEND1,SC5->C5_CLIENTE,SC5->C5_LOJACLI,.T.      ,SC5->C5_I_TAB,SC5->C5_VEND4,SC5->C5_I_GRPVE , _cGrupoP   ,SC5->C5_I_OPER )
			IF aTabnZ[3] == "Regra de Filial de Faturamento " + SC5->C5_I_FILFT + ", gerente " + SC5->C5_VEND3 + " e coordenador " + SC5->C5_VEND2
				U_ITMSG("Este pedido possui Fator Comercial.",;
					"Falha!"							,;
					"Pedido com Fator Comercial n�o pode ser transferido. Inclua um novo pedido na filial de destino.",1)
				_lRet := .F.
				Break
			ENDIF

		EndIf

		AOMS032PRC(_lExibeTela)

	End Sequence

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS032PRC
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 13/04/2010
===============================================================================================================================
Descri��o---------: Fun��o que processa os pedidos de venda
===============================================================================================================================
Parametros--------: _lExibeTela - .T. = Exibem mensagens e perguntas.
                                  .F. = N�o exibe mensagens e perguntas.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS032PRC(_lExibeTela)
Local _nControle := 0
Local _lRet      := .T.
//Local _lWsTms := U_ITGETMV( 'IT_WEBSTMS' , .F.) // Indica se rotina de integra��o WebService � TMS Multi-Embarcador ou RDC.

Private aCampos  := {}

Default _lExibeTela := .T.

Begin Sequence

//================================================================================
// Cria o arquivo Temporario para insercao dos dados selecionados.
//================================================================================
		FWMSGRUN( , {|| _nControle := AOMS032ARQ() }, "Aguarde!" , 'Lendo Dados dos pedidos...' )

		DBSelectArea("TRBT")
		TRBT->(DbGotop())

		If TRBT->(Eof())
			_nControle := 1
		Endif

		If _nControle == 1
			If nRadMenu1 == 1 .And. SC5->C5_I_ENVRD == 'S'//Atual
				If U_ITMSG("Este pedido j� foi integrado para o sistema TMS, deseja realmente Transferir o pedido? ","Aten��o",,3,2,2)
				   If !u_IT_TMS(SC5->C5_I_LOCEM) //! _lWsTms
					  FWMSGRUN( ,{|P| _lRet := U_AOMS094E(P)} , 'Aguarde!' , 'Enviando para o RDC o cancelamento do Pedido...')
				   Else
				      FWMSGRUN( ,{|P| _lRet := U_AOMS140E(P,.T.)} , 'Aguarde!' , 'Enviando para o TMS Multi-Embarcador o cancelamento do Pedido...')
				   EndIf 
				ENDIF
				IF !_lRet
					U_ITMSG("O pedido selecionado j� teve seu envio para o TMS e n�o pode ser Transferido."                        					,;
						"Aten��o!"																						,;
						"Solicite o retorno do pedido para o Protheus.",1)
				EndIf
			ElseIf nRadMenu1 == 2 .And. TRBT->(Eof()) //Varios 
				_lret := .F.
				U_ITmsg("Nao foram encontrados pedidos para realizar a transfer�ncia entre Filiais."					,;
					"Aten��o!"																						,;
					"Favor verificar os par�metros informados e se possue(m) pedido(s) de venda em aberto(status verde) "+;
					"para a filial corrente. Pedidos de PALLET CHEP n�o podem ser transferidos diretamente.",1)
			EndIf
		EndIf

		IF !_lRet
			Break
		EndIf

		AOMS032TRS()//Fun��o que monta a tela para processar as transfer�ncias

	End Sequence

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS032TRS
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 13/04/2010
===============================================================================================================================
Descri��o---------: Fun��o que monta a tela para processar as transfer�ncias
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS032TRS()

	Local oPanel		:= Nil
	Local oDlg1			:= Nil
	Local oQtda			:= Nil
	Local nHeight		:= 0
	Local nWidth		:= 0
	Local aSize			:= {}
	Local aBotoes		:= {}
	Local aCoors		:= {}

	Private nOpca		:= 0

	Private cFiltro		:= "%"
	Private _aCabecPV	:= {}
	Private _aItensPV	:= {}
	Private _aCabcPVEx	:= {}
	Private _aItenPVEx	:= {}
	Private _aAreaCabec	:= {}

	Private _cFilPed	:= ""
	Private _cNumPed	:= ""
	Private nSaveSX8	:= ""
	Private _cFilAtual	:= ""

	Private oMark		:= Nil
	Private oBrowse		:= Nil
	Private oFilTran	:= Nil
	Private oFilFatur   := Nil
	Private nQtdTit		:= 0

//================================================================================
// Variaveis padroes do sistema para compatibilizacao da funcao FA070Tit()
//================================================================================
	Private oFontLbl	:= Nil
	Private cOld		:= cCadastro
	Private lValidou	:= .F.

	DEFINE FONT oFontLbl NAME "Arial" SIZE 6, 15 BOLD

	Begin Sequence

		If nRadMenu1 == 1 //Pedido posicionado

			nOpca := 1

		Else

			_cFilTran   := AllTrim(MV_PAR15)
			
			If MV_PAR16 == 2
			   _cTrocaNf := _aTrocaNf[1] // AllTrim(MV_PAR16) 
			Else 
			   _cTrocaNf := _aTrocaNf[2] 
			EndIf 

			_cFilFatur := AllTrim(MV_PAR17) 
			_cOper25    := AllTrim(MV_PAR18)
			_cLocal     := AllTrim(MV_PAR19)

			//================================================================================
			// Botoes da tela.
			//================================================================================
			Aadd( aBotoes , { "PESQUISA" , {|| AOMS032PSQ(oMark,"TRBT") }	, "Pesquisar..."         , "Pesquisar"		} )
			Aadd( aBotoes , { "S4WB005N" , {|| AOMS032PPV()           }		, "Visualizar Pedido..." , "Visualiza ped"			} )

			//================================================================================
			// Faz o calculo automatico de dimensoes de objetos
			//================================================================================
			aSize := MSADVSIZE()

			//================================================================================
			// Cria a tela para selecao dos pedidos
			//================================================================================
			DEFINE MSDIALOG oDlg1 TITLE OemToAnsi("TRANSFERENCIA DE PEDIDO(S) DE VENDA ENTRE FILIAIS") From 0,0 To aSize[6],aSize[5] OF oMainWnd PIXEL

			oPanel       := TPanel():New(30,0,'',oDlg1,, .T., .T.,, ,315,20,.T.,.T. )

			@0.8,00.8 Say OemToAnsi("Quantidade:")						OF oPanel
			@0.8,0005 Say oQtda		VAR nQtdTit		Picture "@E 99999"	OF oPanel SIZE 60,8

			@0.8,0012 Say OemToAnsi("Filial de Destino:")				OF oPanel  // @0.8,0021
			@0.8,0017 Say oFilTran	VAR _cFilTran	Picture "@!"		OF oPanel SIZE 50,8 // @0.8,0026

			@0.8,0024 Say OemToAnsi("Troca Nota:")		     		    OF oPanel  // @0.8,0041 
			@0.8,0029 Say oFilTran	VAR iif(MV_PAR16 == 2,"Sim","Nao") Picture "@!"	OF oPanel SIZE 50,8	 // @0.8,0046 

   			@0.8,0036 Say OemToAnsi("Filial Faturamento:")		     	OF oPanel  // @0.8,0041 
			@0.8,0042 Say oFilFatur	VAR _cFilFatur Picture "@!"	        OF oPanel SIZE 50,8	 // @0.8,0046 

			@0.8,0046 Say OemToAnsi("Opera��o:")				OF oPanel  
			@0.8,0050 Say oFilTran VAR _cOper25 Picture "@!" 	OF oPanel SIZE 50,8 		

			@0.8,0056 Say OemToAnsi("Local/Armaz�m:")			OF oPanel 
			@0.8,0062 Say oFilTran	VAR _cLocal Picture "@!"	OF oPanel SIZE 50,8	

 			If FlatMode()
				aCoors	:= GetScreenRes()
				nHeight	:= aCoors[2]
				nWidth	:= aCoors[1]
			Else
				nHeight	:= 143
				nWidth	:= 315
			Endif

			DBSelectArea("TRBT")
			TRBT->(DbGotop())

			oMark					:= MsSelect():New( "TRBT" , "TRBT_OK" , "" , aCampos , @lInverte , @cMarkado , { 35 , 1 , nHeight , nWidth } )
			oMark:bMark				:= {|| AOMS032INV( cMarkado , lInverte , oQtda ) }
			oMark:oBrowse:bAllMark	:= {|| AOMS032ALL( cMarkado , oQtda ) }

			AOMS032ALL( cMarkado , oQtda )

			oDlg1:lMaximized:=.T.

			ACTIVATE MSDIALOG oDlg1 ON INIT ( EnchoiceBar(oDlg1,{|| IIF(U_AOMS032VLD(nQtdTit),(nOpca := 1,oDlg1:End()),) },{|| nOpca := 2,oDlg1:End()},,aBotoes),;
				oPanel:Align:=CONTROL_ALIGN_TOP , oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT , oMark:oBrowse:Refresh())

		Endif

		IF nOpca = 1
			FWMSGRUN( , {|oproc| U_AOMS032EXE(oproc) }, "Aguarde!" , 'Processando transfer�ncia entre filiais...' )
		ENDIF

	End Sequence 

Return()

/*
===============================================================================================================================
Programa----------: AOMS032EXE
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 13/04/2010
===============================================================================================================================
Descri��o---------: Fun��o que processa as transfer�ncias
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function AOMS032EXE(oproc)

   Local _aArea		:= GetArea()
   Local _DtEnt		:= ""
   Local _cmottrans	:= space(150)
   Local _onDlg 		:= nil
   Local _nresp 		:= 0
   Local _lOK_RDC      := .T.
   Local _cCodLocaliz
   Local _nI := 0 , nCount
   Local _alog := {}
   Local _cNumPalet	:= "" //Armazena o numero do pedido de PALLET gerado pelo pedido a ser transferido
   Local _lGerPalet	:= "" //Armazena se o pedido de venda a ser transferido gerou um pedido de PALLET
   Local _cCondPag     := ""
   Local _ndias 		:= 0
   Local _cCmpTrcNf, _cCmpFilFt, _cCmpFilCar
   Local _cOperAlt      := ""
   //Local _cItapetininga := U_ITGETMV( "IT_OPERITA","25")
   Local _cMV_PAR15	 := MV_PAR15
   Local _nMV_PAR16	 := MV_PAR16
   Local _aDadosSC5     := {}
   Local _aDadosSC6     := {}
   Local _aLogSC6       := {}
   //Local _lWsTms := U_ITGETMV( 'IT_WEBSTMS' , .F.) // Indica se rotina de integra��o WebService � TMS Multi-Embarcador ou RDC. 
   Local _lContinua := .F.
   Local _nPos := 0
   Local _cOper := ""
   Local _cErro := ""
   Local i := 0
   Local aColsBkp := {}
   Local aHeaderBkp := {}
   Local aLinha := {}
   Local aLinhaExc := {}

   Private lMsErroAuto	:= .F.
   Private lAutoErrNoFile := .T.
   Private lMsHelpAuto	:= .T.
   Private _cAOMS074 := ""

   Private _cCodVend1, _cCodVend2, _cCodVend3, _cCodVend4, _cCodVend5
   Private _cNomVend1, _cNomVend2, _cNomVend3, _cNomVend4, _cNomVend5

   //	IF isincallstack("U_AOMS109") // Chamado 44388 - Remover rotina do fonte AOMS109.
   //		_cTrocaNf := "Nao"
   //	EndIf

	If nOpca == 1

		DBSelectArea("TRBT")
		TRBT->( DBGoTop() )
		_cnumped := ""

		//================================================================================
		// Armazena todos os pedidos selecionados pelo usuario
		//================================================================================
		While TRBT->(!EOF())
			//================================================================================
			// Somente pedidos selecionados pelo usuario
			//================================================================================
			If IsMark( "TRBT_OK" , cMarkado ) .or. nRadMenu1 == 1
				_nI += 1

				If _nI > _MAX_NR_PEDIDOS
					Exit
				EndIf

				//================================================================================
				// A filial dos pedidos eh sempre a mesma
				//================================================================================
				_cFilPed	:= TRBT_FILIA
				_cNumPed	+= If(!Empty(_cNumPed),",","") + "'" + TRBT_NUM + "'"

			EndIf

			TRBT->( DBSkip() )
		EndDo

		//================================================================================
		// Fecha a area de uso do arquivo temporario no Protheus.
		//================================================================================
		TRBT->( DBCloseArea() )

		//================================================================================
		// Verifica se ja existe um arquivo com mesmo nome, se sim deleta
		//================================================================================
		If Select("QRYCABEC") <> 0
			QRYCABEC->( DBCloseArea() )
		EndIf

      If Empty(Alltrim(_cNumPed))
         _cNumPed := "''"
      EndIf
		//================================================================================
		// Filtro para selecao dos dados do pedido de venda
		//================================================================================
		cFiltro += " AND C5_FILIAL = '"+ _cFilPed +"' "
		cFiltro += " AND C5_NUM    IN (" + _cNumPed + ") "
		cFiltro += "%"

		//================================================================================
		// Query para selecao dos dados do cabecalho do pedido de venda
		//================================================================================
		BeginSql alias "QRYCABEC"
	
	   	SELECT
				C5_TIPO,C5_CLIENTE,C5_LOJACLI,C5_CLIENT,C5_LOJAENT,
				C5_TIPOCLI,
				C5_CONDPAG,
				C5_VEND1,
				C5_EMISSAO,
				C5_TPFRETE,
				C5_VOLUME1,
				C5_ESPECI1,
				C5_NUM,
				C5_FILIAL,
				C5_TPCARGA,
				C5_TRANSP,
				C5_MENPAD,
				C5_MOEDA,
				C5_MENNOTA,
				C5_VEND2,
				C5_VEND3,
				C5_I_CDUSU,
				C5_I_HREMI,
				C5_DESCONT,
				C5_PDESCAB,
				C5_PARC1,
				C5_DATA1,
				C5_PARC2,
				C5_DATA2,
				C5_PARC3,
				C5_DATA3,
				C5_PARC4,
				C5_DATA4,
				C5_FRETE,
				C5_PESOL,
				C5_PBRUTO,
				C5_I_NRZAZ,
				C5_I_HOREN,
				C5_I_SENHA,
				C5_I_OBCOP,
				C5_I_OBPED,
				C5_I_BLOQ,
				C5_I_MTBON,
				C5_I_DLIBE,
				C5_I_HLIBE,
				C5_I_STAWF,
				C5_I_PEDGE,
				C5_I_NPALE,
				C5_I_DTENT,
				C5_I_OPER,
				C5_I_BLPRC,
				C5_I_IDPED,
				C5_I_MOTLB,
				C5_I_VLIBB,
				C5_I_QLIBB,
				C5_I_LLIBB,
				C5_I_CLILB,
				C5_I_ULIBB,
				C5_I_MOTBL,
				C5_I_DTLIC,
				C5_I_BLCRE,
				C5_I_LIBCV,
				C5_I_LIBL,
				C5_I_LIBCT,
				C5_I_LIBCD,
				C5_I_LIBCA,
				C5_I_TRCNF,
				C5_I_FILFT,
				C5_I_EVENT,
				C5_I_PEVIN,
				C5_I_ENVRD,
				C5_I_LIBC,
				C5_I_FLFNC,
				C5_I_PSORI,
				C5_I_HORP,  C5_I_AGEND, C5_I_OBSAV,
    			C5_I_ENVRD, C5_I_PODES, C5_I_EVENT, 
				C5_I_DTRET, C5_I_HRRET, C5_I_STATU,  
				C5_I_PEVIN, C5_I_CPMAN, C5_I_ORTBP,
				C5_I_DTNEC, C5_I_PVREF, C5_I_QTPA, 
				C5_I_BLOG, C5_I_ENVML, C5_I_CLITN, 
				C5_I_LOJTN, C5_CLIREM, C5_LOJAREM, C5_I_TPVEN, 
				C5_I_PEDDW, C5_I_EXPOP, C5_I_PEDOP, C5_I_TAB,
				C5_I_BLPRC, C5_I_DTLIP,C5_I_HLIBP,C5_I_VLIBP,C5_I_QLIBP,C5_I_CLILP,
				C5_I_LLIBP, C5_I_MOTLP, C5_I_ULIBP, C5_I_MLIBP, C5_I_PLIBP,
				C5_I_CLIEN, C5_I_LOJEN, C5_I_PVREM, C5_I_TIPCA , C5_I_EST , C5_I_BLSLD
		FROM	%table:SC5% C5
		WHERE	C5.D_E_L_E_T_ = ' '
				%exp:cFiltro%
		
		EndSql

		DBSelectArea("QRYCABEC")
		QRYCABEC->( DBGoTop() )

		_nnk := 0
		Do while QRYCABEC->(!Eof())
			_nnk++
			QRYCABEC->(Dbskip())
		Enddo
 
		QRYCABEC->(Dbgotop())
 
		//================================================================================
		// Percorre os pedidos selecionados e monta o cabecalho e itens do pedido de venda
		//================================================================================
		_nresp := 0
		_natu := 0
		_lok := .T. 
		_alog := {}


		//================================================================================
		//L� motivo da transfer�ncia _cmottrans
		//================================================================================
		Do While _nResp = 0

			If _nnk == 1
				_ctit := "Motivo da transferencia do pedido " + alltrim(QRYCABEC->C5_NUM) + " :"
			Else
				_ctit := "Motivo para transferencia dos pedidos selecionados:"
			Endif

			DEFINE MSDIALOG _onDlg TITLE _ctit FROM 000,000 TO 140,600  PIXEL

			@ 011,011 MSGet _cmottrans PIXEL 	SIZE 220,010 of  _onDlg
			@ 040,230 BUTTON "&Ok"					SIZE 030,014 PIXEL ACTION  { || _nresp := 1, _onDlg:End() }
			@ 040,261 BUTTON "&Cancelar"			SIZE 030,014 PIXEL ACTION  { || _nresp := 0, _onDlg:End() }

			ACTIVATE MSDIALOG _onDlg CENTER

			If _nResp = 0
				If u_itmsg("Cancela processamento?","Aten��o",,2,2,2)
					_nResp := 1
				Else
					_nResp := 0
				EndIf
				_lContinua := .F.
			Else
				If Empty(_cMottrans)
					U_ITmsg("Preenchimento do motivo � obrigat�rio!","Aten��o","Preencha o campo motivo",1)
					_lContinua := .F.
					_nResp := 0
				Else
					_lContinua := .T.
					_nResp := 1
				EndIf
			EndIf

		EndDo

		If _lContinua
			While QRYCABEC->( !Eof() )
            _nPos := aScan(_aMsgVld,{|x| x[2] == QRYCABEC->C5_NUM})
            If _nPos = 0
   				BEGIN SEQUENCE
   				
   					_natu++

   					//==============================================================================================
   					// Bloco de verifica��o de amarra��o com a programa��o de entrega e ajustes de exclus�o
   					//==============================================================================================

   					Dbselectarea("SC5")
   					SC5->( Dbsetorder(1) )
   					SC5->( Dbseek( QRYCABEC->C5_FILIAL + QRYCABEC->C5_NUM) )

   					If !(u_veriprog())
   						Break
   						//QRYCABEC->( Dbskip() )
   						//Loop
   					Endif

   					_aDadosSC5 := {}
   					Aadd( _aDadosSC5 , { 'C5_FILIAL'	, SC5->C5_FILIAL	    , ''		} )
   					Aadd( _aDadosSC5 , { 'C5_NUM'	    , SC5->C5_NUM		    , ''		} )
   					Aadd( _aDadosSC5 , { 'C5_I_TRCNF'	, SC5->C5_I_TRCNF		, ''		} )
   					Aadd( _aDadosSC5 , { 'C5_I_FILFT'	, SC5->C5_I_FILFT		, ''		} )					
   					Aadd( _aDadosSC5 , { 'C5_I_OPER'    , SC5->C5_I_OPER		, ''		} )
   					Aadd( _aDadosSC5 , { 'C5_I_FLFNC'   , SC5->C5_I_FLFNC		, ''		} )

   					_cFilPed	:= QRYCABEC->C5_FILIAL
   					_cNumPed	:= QRYCABEC->C5_NUM

   					_lGerPalet	:= QRYCABEC->C5_I_PEDGE //Armazena se o pedido de venda a ser transferido gerou um pedido de PALLET
   					_cNumPalet	:= QRYCABEC->C5_I_NPALE //Armazena o numero do pedido de PALLET gerado pelo pedido a ser transferido
   		
   					//If ! (_cFilTran $ _cFilOpera .And. ! QRYCABEC->C5_I_OPER $ _cOperTran) // S� habilitar quando Filial destino = 90 ou 93 e Opera��o atual for diferente de 42-Triangular
   							//   _cOper25 := QRYCABEC->C5_I_OPER  
   					//EndIf 
   					If ! Empty(_cOper25)
   						_cOperTran := _cOper25
   					Else
   						_cOperTran := QRYCABEC->C5_I_OPER 	
   					EndIf 	

					   aColsBkp := (aClone(aCols)) 
					   aHeaderBkp := (aClone(aHeader))

   					//============================================================================
   					//Testa e acerta data de entrega do pedido
   					//============================================================================
   					aheader := {}
   					acols := {}
   					aadd(aheader,{1,"C6_ITEM"})
   					aadd(aheader,{2,"C6_PRODUTO"})
   					aadd(aheader,{3,"C6_LOCAL"})

   					SC6->(Dbsetorder(1))
   					SC6->(Dbseek(QRYCABEC->C5_FILIAL+QRYCABEC->C5_NUM))

   					Do while SC6->(!EOF()) .AND. QRYCABEC->C5_FILIAL == SC6->C6_FILIAL .AND. QRYCABEC->C5_NUM == SC6->C6_NUM
   						aadd(acols,{SC6->C6_ITEM,SC6->C6_PRODUTO,SC6->C6_LOCAL})
   						SC6->(Dbskip())
   					Enddo

   					//Se for entrega imediata atualiza data de entrega
   					//Para agendados e aguardando agenda mant�m a mesma data de entrega

   					If  QRYCABEC->C5_I_AGEND $ "I/O"

   						if stod(QRYCABEC->C5_I_DTENT) < date()
   							_ddat := date()
   						Else
   							_ddat := stod(QRYCABEC->C5_I_DTENT)
   						Endif

   						If !(U_OMSVLDENT(_ddat,QRYCABEC->C5_CLIENTE,QRYCABEC->C5_LOJACLI,SubStr(_cFilTran,1,2),QRYCABEC->C5_NUM,0,.F.))
   							_ndias := U_OMSVLDENT(_ddat,QRYCABEC->C5_CLIENTE,QRYCABEC->C5_LOJACLI,SubStr(_cFilTran,1,2),QRYCABEC->C5_NUM,1,.F.)
   							_DtEnt := DATE() + _ndias + 1
   						Else
   							_DtEnt		:=  STOD(QRYCABEC->C5_I_DTENT)
   						Endif

   					Else

   						_DtEnt		:=  STOD(QRYCABEC->C5_I_DTENT)

   					Endif

   					//================================================================================
   					// Zera Variaveis de controle
   					//================================================================================
   					_aCabecPV	:= {}
   					_aItensPV	:= {}
   					_aCabcPVEx	:= {}
   					_aItenPVEx	:= {}
   					_lblqprc := .F.
						
                  If _cOperTran $ U_ITGETMV( 'IT_OPMEDIO' , "20|22" )

                     For i := 1 to Len(aColsBkp)

                        SA1->(Dbsetorder(1))
                        SA1->(Dbseek(xfilial("SA1") + QRYCABEC->C5_CLIENTE + QRYCABEC->C5_LOJACLI))

                        _cfilg := cfilant
                        cfilant := SubStr(_cFilTran,1,2)
                        SM0->( DBSetOrder(1))
                        SM0->( DBSeek( SubStr( cNumEmp , 1 , 2 ) + cFilAnt ) )
                           
                        _cOperAlt    := _cOper25

                        cfilant := _cfilg
                        SM0->( DBSetOrder(1))
                        SM0->( DBSeek( SubStr( cNumEmp , 1 , 2 ) + cFilAnt ) )

                        IF Empty(_cLocal) .Or. (! U_ITKEY(_cFilTran, "C6_FILIAL") $ _cFilDifer .And. ! U_ITKEY(_cOper25, "C5_I_OPER") $ _cOperTran) // Filias destino diferente de 90/93 e Opera��o diferente de 42-Triangular, no destino buscar o armaz�m padr�o conforme produto na filial (BZ_LOCPAD).
                        	_cCodLocaliz := Posicione("SBZ",1,cfilant+aColsBkp[i,aScan(aHeaderBkp,{|x| AllTrim(x[2]) == "C6_PRODUTO"})],"BZ_LOCPAD")  // BZ_FILIAL+BZ_COD // Ordem 01
                        ELSE
                        	_cCodLocaliz := 	_cLocal	
                        ENDIF

                        aLinha := {}

                        AADD(aLinha,{ "C6_FILIAL"  , SubStr(_cFilTran,1,2),Nil})
                        AOMOS32X(@aLinha,"C6_ITEM",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_PRODUTO",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_QTDVEN",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_UNSVEN",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_UM",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_PRCVEN",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_VALOR",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_PEDCLI",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_QTDLIB",aColsBkp,aHeaderBkp,i)
                        AADD(aLinha,{ "C6_ENTREG"  , _DtEnt ,Nil})
                        AOMOS32X(@aLinha,"C6_I_QESP",aColsBkp,aHeaderBkp,i)
                        If !Empty(_cCodLocaliz)
                           AADD(aLinha,{ "C6_LOCAL"   , _cCodLocaliz		,Nil})
                        Else
                           AOMOS32X(@aLinha,"C6_LOCAL",aColsBkp,aHeaderBkp,i)
                        EndIf
                        AOMOS32X(@aLinha,"C6_PRUNIT",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_TES",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_LIBPR",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_PLIBB",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_LLIBB",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_CLILB",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_VLIBB",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_QLIBB",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_DLIBB",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_MOTLB",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_LIBPC",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_LIBPE",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_DLIBP",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_PLIBP",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_ULIBP",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_VLIBP",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_MOTLP",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_QTLIP",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_CLILP",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_CLILB",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_LLIBP",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_DESM1",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_DESM2",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_PTBRU",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_DEVFN",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_DEVLJ",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_DEVDO",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_DEVSE",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_DEVIT",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_DTCRI",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_TBAPP",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_DTAPP",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_HRAPP",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_USAPP",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_VLAPP",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_MTAPP",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_COMIS1",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_COMIS2",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_COMIS3",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_COMIS4",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_COMIS5",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_BLPRC",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_VLTAB",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_PRMIN",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_FXPES",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_PRNET",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_ITDW",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinha,"C6_I_PDESC",aColsBkp,aHeaderBkp,i)

                        aAdd( _aItensPV , aLinha ) 

                        aLinhaExc := {}

                        AADD(aLinhaExc,{ "C6_FILIAL"  , SubStr(_cFilTran,1,2),Nil})
                        AOMOS32X(@aLinhaExc,"C6_ITEM",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinhaExc,"C6_PRODUTO",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinhaExc,"C6_QTDVEN",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinhaExc,"C6_UM",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinhaExc,"C6_PRCVEN",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinhaExc,"C6_VALOR",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinhaExc,"C6_PEDCLI",aColsBkp,aHeaderBkp,i)
                        AOMOS32X(@aLinhaExc,"C6_QTDLIB",aColsBkp,aHeaderBkp,i)
                        If !Empty(_cCodLocaliz)
                     	   AADD(aLinhaExc,{ "C6_LOCAL"   , _cCodLocaliz		,Nil})
                        Else
                           AOMOS32X(@aLinhaExc,"C6_LOCAL",aColsBkp,aHeaderBkp,i)
                        EndIf
                     	AADD(aLinhaExc,{ "C6_NUM"     , _cNumPed				,Nil})

                        aAdd( _aItenPVEx , aLinhaExc )

                        //==================================================
                        // L� os dados da SC6 para grava��o de Log.
                        //==================================================
                        Aadd( _aDadosSC6 , { 'C6_LOCAL'	, iif(empty(_cCodLocaliz),aColsBkp[i,aScan(aHeaderBkp,{|x| AllTrim(x[2]) == "C6_LOCAL"})] ,_cCodLocaliz) , ''		, aColsBkp[i,aScan(aHeaderBkp,{|x| AllTrim(x[2]) == "C6_ITEM"})]} )  
                        //--------------------------------------------------

                     Next
                  Else

                  		//================================================================================
                  		// Verifica se ja existe um arquivo com mesmo nome, se sim deleta.
                  		//================================================================================
                  		If Select("QRYITENS") <> 0
                  			QRYITENS->( DBCloseArea() )
                  		EndIf

                  		//================================================================================
                  		// Filtro para selecao dos dados do pedido de venda
                  		//================================================================================
                  		cFiltro   := "% "
                  		cFiltro   += " AND C6_FILIAL = '"+ _cFilPed +"' AND C6_NUM  = '"+ _cNumPed +"' "
                  		cFiltro   += " %"

                  		//================================================================================
                  		// Query para selecao dos itens do pedido de venda
                  		//================================================================================
                  		BeginSql alias "QRYITENS"

                  			SELECT  C6_ITEM,C6_PRODUTO,C6_QTDVEN,C6_PRCVEN,C6_LOCAL,C6_UM,
                  						C6_VALOR,C6_TES,C6_PEDCLI,C6_QTDLIB,C6_ENTREG,C6_FILIAL,
                  						C6_CF,C6_PRUNIT,C6_UNSVEN,C6_I_QESP,C6_I_LIBPR,C6_I_BLPRC,
                  						C6_I_PLIBB,C6_I_LLIBB,C6_I_VLIBB,C6_I_QLIBB,C6_I_DLIBB,
                  						C6_I_MOTLB,C6_I_LIBPC,
                  					C6_I_DLIBP, C6_I_LIBPE, C6_I_PLIBP, C6_I_ULIBP, C6_I_VLIBP, C6_I_MOTLP, C6_I_QTLIP, 
                  					C6_I_CLILP, C6_I_CLILB, C6_I_LLIBP, C6_I_DESM1, C6_I_DESM2, C6_I_PTBRU, 
                  					C6_I_DEVFN, C6_I_DEVLJ, C6_I_DEVDO, C6_I_DEVSE, C6_I_DEVIT, C6_I_DTCRI, 
                  					C6_I_TBAPP, C6_I_DTAPP, C6_I_HRAPP, C6_I_USAPP, C6_I_VLAPP, C6_I_MTAPP, C6_I_ITDW,
                  					C6_COMIS1,C6_COMIS2,C6_COMIS3,C6_COMIS4,C6_COMIS5, C6_I_FXPES, C6_I_PRNET, C6_I_VLTAB, C6_I_PDESC, C6_CLASFIS, C6_I_PRMIN
                  			FROM	%table:SC6% C6
                  			WHERE	D_E_L_E_T_ = ' '
                  					%exp:cFiltro%

                  		EndSql

                  		DBSelectArea("QRYITENS")
                  		QRYITENS->( DBGoTop() )

                  		//Conta itens
                  		_nnt := 0
                  		While QRYITENS->( !Eof() )
                  			_nnt++
                  			QRYITENS->( Dbskip() )
                  		Enddo

                             _aDadosSC6 := {} 

                  		QRYITENS->( DBGoTop() )

                  		While QRYITENS->( !Eof() )

                  			SA1->(Dbsetorder(1))
                  			SA1->(Dbseek(xfilial("SA1") + QRYCABEC->C5_CLIENTE + QRYCABEC->C5_LOJACLI))

                  			_cfilg := cfilant
                  			cfilant := SubStr(_cFilTran,1,2)
                  			SM0->( DBSetOrder(1))
                  			SM0->( DBSeek( SubStr( cNumEmp , 1 , 2 ) + cFilAnt ) )
                                 
                  			IF Empty(_cLocal) .Or. (! U_ITKEY(_cFilTran, "C6_FILIAL") $ _cFilDifer .And. ! U_ITKEY(_cOper25, "C5_I_OPER") $ _cOperTran) // Filias destino diferente de 90/93 e Opera��o diferente de 42-Triangular, no destino buscar o armaz�m padr�o conforme produto na filial (BZ_LOCPAD).
                  				_cCodLocaliz := Posicione("SBZ",1,cfilant+QRYITENS->C6_PRODUTO,"BZ_LOCPAD")  // BZ_FILIAL+BZ_COD // Ordem 01
                  			ELSE
                  				_cCodLocaliz := 	_cLocal	
                  			ENDIF
                  			
                  			_cOperAlt    := _cOper25

                  			cfilant := _cfilg
                  			SM0->( DBSetOrder(1))
                  			SM0->( DBSeek( SubStr( cNumEmp , 1 , 2 ) + cFilAnt ) )

                  			aAdd( _aItensPV , {	{ "C6_FILIAL"  , SubStr(_cFilTran,1,2),Nil},;
                  				{ "C6_ITEM"    , QRYITENS->C6_ITEM    ,Nil},;
                  				{ "C6_PRODUTO" , QRYITENS->C6_PRODUTO ,Nil},;
                  				{ "C6_QTDVEN"  , QRYITENS->C6_QTDVEN  ,Nil},;
                  				{ "C6_UNSVEN"  , QRYITENS->C6_UNSVEN  ,Nil},;
                  				{ "C6_UM"      , QRYITENS->C6_UM      ,nil},;
                  				{ "C6_PRCVEN"  , QRYITENS->C6_PRCVEN  ,Nil},;
                  				{ "C6_VALOR"   , QRYITENS->C6_VALOR   ,Nil},;
                  				{ "C6_PEDCLI"  , QRYITENS->C6_PEDCLI  ,Nil},;
                  				{ "C6_QTDLIB"  , QRYITENS->C6_QTDLIB  ,Nil},;
                  				{ "C6_ENTREG"  , _DtEnt ,Nil},;
                  				{ "C6_I_QESP"  , QRYITENS->C6_I_QESP  ,Nil},;
                  				{ "C6_LOCAL"   , iif(empty(_cCodLocaliz),QRYITENS->C6_LOCAL,_cCodLocaliz)		,nil},;
                  				{ "C6_PRUNIT"  , QRYITENS->C6_PRUNIT  ,nil},;
                  				{ "C6_I_LIBPR" , QRYITENS->C6_I_LIBPR ,nil},;
                  				{ "C6_I_PLIBB" , QRYITENS->C6_I_PLIBB ,nil},;
                  				{ "C6_I_LLIBB" , QRYITENS->C6_I_LIBPR ,nil},;
                  				{ "C6_I_CLILB" , QRYITENS->C6_I_LLIBB ,nil},;
                  				{ "C6_I_VLIBB" , QRYITENS->C6_I_VLIBB ,nil},;
                  				{ "C6_I_QLIBB" , QRYITENS->C6_I_QLIBB ,nil},;
                  				{ "C6_I_DLIBB" , stod(QRYITENS->C6_I_DLIBB) ,nil},;
                  				{ "C6_I_MOTLB" , QRYITENS->C6_I_MOTLB ,nil},;
                  				{ "C6_I_LIBPC" , QRYITENS->C6_I_LIBPC ,nil},;
                  				{ "C6_I_LIBPE" , QRYITENS->C6_I_LIBPE ,nil},;
                  				{ "C6_I_DLIBP" , QRYITENS->C6_I_DLIBP ,nil},;
                  				{ "C6_I_PLIBP" , QRYITENS->C6_I_PLIBP ,nil},;
                  				{ "C6_I_ULIBP" , QRYITENS->C6_I_ULIBP ,nil},;
                  				{ "C6_I_VLIBP" , QRYITENS->C6_I_VLIBP ,nil},;
                  				{ "C6_I_MOTLP" , QRYITENS->C6_I_MOTLP ,nil},;
                  				{ "C6_I_QTLIP" , QRYITENS->C6_I_QTLIP ,nil},;
                  				{ "C6_I_CLILP" , QRYITENS->C6_I_CLILP ,nil},;
                  				{ "C6_I_CLILB" , QRYITENS->C6_I_CLILB ,nil},;
                  				{ "C6_I_LLIBP" , QRYITENS->C6_I_LLIBP ,nil},;
                  				{ "C6_I_DESM1" , QRYITENS->C6_I_DESM1 ,nil},;
                  				{ "C6_I_DESM2" , QRYITENS->C6_I_DESM2 ,nil},;
                  				{ "C6_I_PTBRU" , QRYITENS->C6_I_PTBRU ,nil},;
                  				{ "C6_I_DEVFN" , QRYITENS->C6_I_DEVFN ,nil},;
                  				{ "C6_I_DEVLJ" , QRYITENS->C6_I_DEVLJ ,nil},;
                  				{ "C6_I_DEVDO" , QRYITENS->C6_I_DEVDO ,nil},;
                  				{ "C6_I_DEVSE" , QRYITENS->C6_I_DEVSE ,nil},;
                  				{ "C6_I_DEVIT" , QRYITENS->C6_I_DEVIT ,nil},;
                  				{ "C6_I_DTCRI" , QRYITENS->C6_I_DTCRI ,nil},;
                  				{ "C6_I_TBAPP" , QRYITENS->C6_I_TBAPP ,nil},;
                  				{ "C6_I_DTAPP" , QRYITENS->C6_I_DTAPP ,nil},;
                  				{ "C6_I_HRAPP" , QRYITENS->C6_I_HRAPP ,nil},;
                  				{ "C6_I_USAPP" , QRYITENS->C6_I_USAPP ,nil},;
                  				{ "C6_I_VLAPP" , QRYITENS->C6_I_VLAPP ,nil},;
                  				{ "C6_I_MTAPP" , QRYITENS->C6_I_MTAPP ,nil},;
                  				{ "C6_COMIS1"  , QRYITENS->C6_COMIS1  ,nil},;
                  				{ "C6_COMIS2"  , QRYITENS->C6_COMIS2  ,nil},;
                  				{ "C6_COMIS3"  , QRYITENS->C6_COMIS3  ,nil},;
                  				{ "C6_COMIS4"  , QRYITENS->C6_COMIS4  ,nil},;
                  				{ "C6_COMIS5"  , QRYITENS->C6_COMIS5  ,nil},;
                  				{ "C6_I_BLPRC" , QRYITENS->C6_I_BLPRC ,nil},;
                  				{ "C6_I_VLTAB" , QRYITENS->C6_I_VLTAB ,nil},;
                                  { "C6_I_PRMIN" , QRYITENS->C6_I_PRMIN ,nil},;
                  				{ "C6_I_FXPES" , QRYITENS->C6_I_FXPES ,nil},;							
                  				{ "C6_I_PRNET" , QRYITENS->C6_I_PRNET ,nil},;							
                  				{ "C6_I_ITDW"  , QRYITENS->C6_I_ITDW  ,nil},;	
                  				{ "C6_I_PDESC" , QRYITENS->C6_I_PDESC ,nil}})

                  			aAdd( _aItenPVEx , {	{ "C6_FILIAL"  , QRYITENS->C6_FILIAL	,Nil},;
                  				{ "C6_ITEM"    , QRYITENS->C6_ITEM		,Nil},;
                  				{ "C6_PRODUTO" , QRYITENS->C6_PRODUTO	,Nil},;
                  				{ "C6_QTDVEN"  , QRYITENS->C6_QTDVEN	,Nil},;
                  				{ "C6_UM"      , QRYITENS->C6_UM		,Nil},;
                  				{ "C6_PRCVEN"  , QRYITENS->C6_PRCVEN	,Nil},;
                  				{ "C6_VALOR"   , QRYITENS->C6_VALOR		,Nil},;
                  				{ "C6_PEDCLI"  , QRYITENS->C6_PEDCLI	,Nil},;
                  				{ "C6_QTDLIB"  , QRYITENS->C6_QTDLIB	,Nil},;
                  				{ "C6_LOCAL"   , iif(empty(_cCodLocaliz),QRYITENS->C6_LOCAL,_cCodLocaliz)		,Nil},;
                  				{ "C6_NUM"     , _cNumPed				,Nil}})

                  				//==================================================
                  				// L� os dados da SC6 para grava��o de Log.
                  				//==================================================
                  				Aadd( _aDadosSC6 , { 'C6_LOCAL'	, QRYITENS->C6_LOCAL , ''		, QRYITENS->C6_ITEM} )  
                  				//--------------------------------------------------

                  			QRYITENS->( DBSkip() )
                  		EndDo

                  		QRYITENS->( DBCloseArea() )

                  EndIf

   					//================================================================================
   					// Prepara arrays de cabe�alhos dos pedidos para o Destino
   					//================================================================================
   					_cCodVend1 := ""
   					_cCodVend2 := ""
   					_cCodVend3 := ""
   					_cCodVend4 := ""
   					_cCodVend5 := ""
   					_cNomVend1 := ""
   					_cNomVend2 := ""
   					_cNomVend3 := ""
   					//_cNomVend4 := ""
   					//_cNomVend5 := ""

   					//================================================================================
   					// Quando Troca Nota a Filial de Carregamento tem que ser a Filial destino 
   					//================================================================================
   					If Empty(_cTrocaNf)   
   						_cCmpTrcNf := QRYCABEC->C5_I_TRCNF
   					Else 
   						If _cTrocaNf == _aTrocaNf[1] // Sim
   							_cCmpTrcNf :=  "S"
   						Else
   							_cCmpTrcNf :=  "N"
   						EndIf 	
   					EndIf 
   					
   					If Empty(_cFilFatur)
   						_cCmpFilFt := QRYCABEC->C5_I_FILFT
   					Else  
   						_cCmpFilFt := _cFilFatur
   					EndIf 

   					/*
   					If QRYCABEC->C5_I_TRCNF  == "S"
   						_cCmpFilCar := SubStr(_cFilTran,1,2)
   					Else 
   						_cCmpFilCar := "" 
   					End 
   					*/
   					If ! Empty(_cTrocaNf) .And. _cTrocaNf == _aTrocaNf[1] // Sim
   						_cCmpFilCar := SubStr(_cFilTran,1,2) 
   					Else 
   						_cCmpFilCar :=  QRYCABEC->C5_I_FLFNC
   					EndIf 

   					_aCabecPV	:= {	{ "C5_FILIAL"  , SubStr(_cFilTran,1,2)      	,Nil},;
   						{ "C5_NUM"     , QRYCABEC->C5_NUM           	,Nil},;
   						{ "C5_TIPO"    , QRYCABEC->C5_TIPO				,Nil},;
   						{ "C5_I_OPER"  , _cOperAlt          			,Nil},;  
   						{ "C5_CLIENTE" , QRYCABEC->C5_CLIENTE			,Nil},;
   						{ "C5_LOJACLI" , QRYCABEC->C5_LOJACLI 			,Nil},;
   						{ "C5_CLIENT " , QRYCABEC->C5_CLIENT  			,Nil},; // Codigo do cliente
   						{ "C5_LOJAENT" , QRYCABEC->C5_LOJAENT 			,Nil},; // Loja para entrada
   						{ "C5_TRANSP"  , QRYCABEC->C5_TRANSP  			,nil},;
   						{ "C5_TIPOCLI" , QRYCABEC->C5_TIPOCLI 			,Nil},;
   						{ "C5_I_OBCOP" , QRYCABEC->C5_I_OBCOP 			,Nil},;
   						{ "C5_I_OBPED" , QRYCABEC->C5_I_OBPED 			,Nil},;
   						{ "C5_VEND1"   , QRYCABEC->C5_VEND1   			,Nil},;
   						{ "C5_VEND2"   , QRYCABEC->C5_VEND2   			,Nil},;
   						{ "C5_VEND3"   , QRYCABEC->C5_VEND3   			,Nil},;
   						{ "C5_I_HOREN" , QRYCABEC->C5_I_HOREN   		,Nil},;
   						{ "C5_I_SENHA" , QRYCABEC->C5_I_SENHA   		,Nil},;
   						{ "C5_MOEDA"   , QRYCABEC->C5_MOEDA		    	,Nil},;
   						{ "C5_EMISSAO" , StoD(QRYCABEC->C5_EMISSAO) 	,Nil},;
   						{ "C5_I_HREMI" , QRYCABEC->C5_I_HREMI			,Nil},;
   						{ "C5_PARC1"   , QRYCABEC->C5_PARC1     	  	,Nil},;
   						{ "C5_DATA1"   , StoD(QRYCABEC->C5_DATA1)   	,Nil},;
   						{ "C5_PARC2"   , QRYCABEC->C5_PARC2				,Nil},;
   						{ "C5_DATA2"   , StoD(QRYCABEC->C5_DATA2)		,Nil},;
   						{ "C5_PARC3"   , QRYCABEC->C5_PARC3				,Nil},;
   						{ "C5_DATA3"   , StoD(QRYCABEC->C5_DATA3)   	,Nil},;
   						{ "C5_PARC4"   , QRYCABEC->C5_PARC4				,Nil},;
   						{ "C5_DATA4"   , StoD(QRYCABEC->C5_DATA4)   	,Nil},;
   						{ "C5_TPFRETE" , QRYCABEC->C5_TPFRETE 			,Nil},;
   						{ "C5_FRETE"   , QRYCABEC->C5_FRETE 			,Nil},;
   						{ "C5_PESOL"   , QRYCABEC->C5_PESOL 			,Nil},;
   						{ "C5_PBRUTO"  , QRYCABEC->C5_PBRUTO 			,Nil},;
   						{ "C5_VOLUME1" , QRYCABEC->C5_VOLUME1 			,Nil},;
   						{ "C5_ESPECI1" , QRYCABEC->C5_ESPECI1 			,Nil},;
   						{ "C5_MENNOTA" , QRYCABEC->C5_MENNOTA			,nil},;
   						{ "C5_MENPAD"  , QRYCABEC->C5_MENPAD			,nil},;
   						{ "C5_DESCONT" , QRYCABEC->C5_DESCONT			,nil},;
   						{ "C5_PDESCAB" , QRYCABEC->C5_PDESCAB			,nil},;
   						{ "C5_TPCARGA" , QRYCABEC->C5_TPCARGA 			,Nil},;
   						{ "C5_I_CDUSU" , QRYCABEC->C5_I_CDUSU 			,Nil},;
   						{ "C5_I_NRZAZ" , QRYCABEC->C5_I_NRZAZ 			,Nil},;
   						{ "C5_I_FILTR" , cFilAnt						,Nil},;
   						{ "C5_I_BLOQ"  , QRYCABEC->C5_I_BLOQ			,Nil},;
   						{ "C5_I_MTBON" , QRYCABEC->C5_I_MTBON			,Nil},;
   						{ "C5_I_HLIBE" , QRYCABEC->C5_I_HLIBE			,Nil},;
   						{ "C5_I_DLIBE" , StoD(QRYCABEC->C5_I_DLIBE) 	,Nil},;
   						{ "C5_I_STAWF" , QRYCABEC->C5_I_STAWF 			,Nil},;
   						{ "C5_I_DTENT" , _DtEnt 	,Nil},;
   						{ "C5_I_BLPRC" , QRYCABEC->C5_I_BLPRC 		   	,Nil},; //{ "C5_I_BLPRC" , iif(_lblqprc,"B","") 		   	,Nil},;
   						{ "C5_I_FILOR" , QRYCABEC->C5_FILIAL			,Nil},; //Filial de origem do pedido
   						{ "C5_I_PEDOR" , QRYCABEC->C5_NUM				,Nil},; //Pedido de origem
   						{ "C5_I_DTRAN" , dDataBase						,Nil},; //Data de transfer�ncia
   						{ "C5_I_UTRAN" , CUSERNAME						,Nil},; //Usu�rio que transferiu
   						{ "C5_I_MTRAN" , _cmottrans						,Nil},; //Motivo de transfer�ncia
   						{ "C5_I_MOTLB" , QRYCABEC->C5_I_MOTLB			,Nil},;
   						{ "C5_I_DTLIC" , stod(QRYCABEC->C5_I_DTLIC)		,Nil},;
   						{ "C5_I_BLCRE" , QRYCABEC->C5_I_BLCRE			,Nil},;
   						{ "C5_I_LIBCV" , QRYCABEC->C5_I_LIBCV			,Nil},;
   						{ "C5_I_LIBL"  , STOD(QRYCABEC->C5_I_LIBL)		,Nil},;
   						{ "C5_I_VLIBB" , QRYCABEC->C5_I_VLIBB			,Nil},;
   						{ "C5_I_LIBCT" , QRYCABEC->C5_I_LIBCT			,Nil},;
   						{ "C5_I_LIBCD" , stod(QRYCABEC->C5_I_LIBCD)		,Nil},;
   						{ "C5_I_LIBCA" , QRYCABEC->C5_I_LIBCA			,Nil},;
   						{ "C5_I_LIBC"  , QRYCABEC->C5_I_LIBC			,Nil},;
   						{ "C5_I_QLIBB" , QRYCABEC->C5_I_QLIBB			,Nil},;
   						{ "C5_I_LLIBB" , QRYCABEC->C5_I_LLIBB			,Nil},;
   						{ "C5_I_CLILB" , QRYCABEC->C5_I_CLILB			,Nil},;
   						{ "C5_I_ULIBB" , QRYCABEC->C5_I_ULIBB			,Nil},;
   						{ "C5_I_TRCNF" , _cCmpTrcNf         		    ,Nil},;  // _cCmpTrcNf   // QRYCABEC->C5_I_TRCNF 
   						{ "C5_I_FILFT" , _cCmpFilFt         		    ,Nil},;  // _cCmpFilFt  // QRYCABEC->C5_I_FILFT 
   						{ "C5_I_FLFNC" , _cCmpFilCar 		            ,Nil},;  // _cCmpFilCar  -- C5_I_FLFNC  //	{ "C5_I_PEVIN" , QRYCABEC->C5_I_PEVIN			,Nil},;
   						{ "C5_I_MOTBL" , QRYCABEC->C5_I_MOTBL			,Nil},;
   						{ "C5_I_AGEND" , QRYCABEC->C5_I_AGEND   		,Nil},;
   						{ "C5_I_ENVRD" , "N"                			,Nil},;
   						{ "C5_I_EVENT" , QRYCABEC->C5_I_EVENT   		,Nil},;
   						{ "C5_CONDPAG" , QRYCABEC->C5_CONDPAG 			,Nil},;
   						{ "C5_I_HORP"  , QRYCABEC->C5_I_HORP			,Nil},;
   						{ "C5_I_OBSAV" , QRYCABEC->C5_I_OBSAV			,Nil},;
   						{ "C5_I_PODES" , QRYCABEC->C5_I_PODES			,Nil},;
   						{ "C5_I_EVENT" , QRYCABEC->C5_I_EVENT			,Nil},;
   						{ "C5_I_DTRET" , stod(QRYCABEC->C5_I_DTRET)		,Nil},;
   						{ "C5_I_HRRET" , QRYCABEC->C5_I_HRRET			,Nil},;
   						{ "C5_I_STATU" , QRYCABEC->C5_I_STATU			,Nil},; 
   						{ "C5_I_PEVIN" , QRYCABEC->C5_I_PEVIN			,Nil},;
   						{ "C5_I_CPMAN" , QRYCABEC->C5_I_CPMAN			,Nil},;
   						{ "C5_I_ORTBP" , QRYCABEC->C5_I_ORTBP			,Nil},;
   						{ "C5_I_DTNEC" ,  stod(QRYCABEC->C5_I_DTNEC)	,Nil},;
   						{ "C5_I_PVREF" , QRYCABEC->C5_I_PVREF			,Nil},;
   						{ "C5_I_QTPA"  , QRYCABEC->C5_I_QTPA			,Nil},;
   						{ "C5_I_BLOG"  , QRYCABEC->C5_I_BLOG			,Nil},;
   						{ "C5_I_ENVML" , QRYCABEC->C5_I_ENVML			,Nil},;
   						{ "C5_I_CLITN" , QRYCABEC->C5_I_CLITN			,Nil},;
   						{ "C5_I_LOJTN" , QRYCABEC->C5_I_LOJTN			,Nil},;
   						{ "C5_CLIREM"  , QRYCABEC->C5_CLIREM			,Nil},;
   						{ "C5_LOJAREM" , QRYCABEC->C5_LOJAREM			,Nil},;
   						{ "C5_I_TPVEN" , QRYCABEC->C5_I_TPVEN			,Nil},;
   						{ "C5_I_PEDDW" , QRYCABEC->C5_I_PEDDW			,Nil},;
   						{ "C5_I_EXPOP" , QRYCABEC->C5_I_EXPOP			,Nil},;
   						{ "C5_I_PEDOP" , QRYCABEC->C5_I_PEDOP			,Nil},;
   						{ "C5_I_TAB"   , QRYCABEC->C5_I_TAB 			,Nil},;
   						{ "C5_I_PSORI" , QRYCABEC->C5_I_PSORI 			,Nil},;
   						{ "C5_I_BLPRC", QRYCABEC->C5_I_BLPRC ,Nil},;
   						{ "C5_I_DTLIP", stod(QRYCABEC->C5_I_DTLIP) ,Nil},;
   						{ "C5_I_HLIBP", QRYCABEC->C5_I_HLIBP ,Nil},;
   						{ "C5_I_VLIBP", QRYCABEC->C5_I_VLIBP ,Nil},;
   						{ "C5_I_QLIBP", QRYCABEC->C5_I_QLIBP ,Nil},;
   						{ "C5_I_CLILP", QRYCABEC->C5_I_CLILP ,Nil},;
   						{ "C5_I_LLIBP", QRYCABEC->C5_I_LLIBP ,Nil},;
   						{ "C5_I_MOTLP", QRYCABEC->C5_I_MOTLP ,Nil},;
   						{ "C5_I_ULIBP", QRYCABEC->C5_I_ULIBP ,Nil},;
   						{ "C5_I_MLIBP", QRYCABEC->C5_I_MLIBP ,Nil},;
   						{ "C5_I_PLIBP", stod(QRYCABEC->C5_I_PLIBP) ,Nil},;
   						{ "C5_I_IDPED", QRYCABEC->C5_I_IDPED ,Nil},;
   						{ "C5_I_CLIEN", QRYCABEC->C5_I_CLIEN ,Nil},; 
   						{ "C5_I_LOJEN", QRYCABEC->C5_I_LOJEN ,Nil},;
   						{ "C5_I_EST"  , QRYCABEC->C5_I_EST   ,Nil},;
   						{ "C5_I_BLSLD", QRYCABEC->C5_I_BLSLD ,Nil},;
   						{ "C5_I_TIPCA", QRYCABEC->C5_I_TIPCA ,Nil}} 
   						
   					SC5->( DBSetOrder(1) )
   					IF SC5->(DBSEEK( SubStr(_cFilTran,1,2)+QRYCABEC->C5_NUM ))
   						ADEL(_aCabecPV,2)
   						ASIZE(_aCabecPV, LEN(_aCabecPV)-1 )
   					ENDIF

   					_aCabcPVEx := {		{ "C5_FILIAL"  , QRYCABEC->C5_FILIAL   	        ,Nil},;
   						{ "C5_NUM"     , QRYCABEC->C5_NUM            	,Nil},;
   						{ "C5_TIPO"    , QRYCABEC->C5_TIPO    			,Nil},;
   						{ "C5_CLIENTE" , QRYCABEC->C5_CLIENTE 			,Nil},;
   						{ "C5_LOJACLI" , QRYCABEC->C5_LOJACLI 			,Nil},;
   						{ "C5_CLIENT " , QRYCABEC->C5_CLIENT  			,Nil},; // Codigo do cliente
   						{ "C5_LOJAENT" , QRYCABEC->C5_LOJAENT 			,Nil},; // Loja para entrada
   						{ "C5_TIPOCLI" , QRYCABEC->C5_TIPOCLI 			,Nil},;
   						{ "C5_CONDPAG" , QRYCABEC->C5_CONDPAG 			,Nil},;
   						{ "C5_VEND1"   , QRYCABEC->C5_VEND1   			,Nil},;
   						{ "C5_EMISSAO" , StoD(QRYCABEC->C5_EMISSAO) 	,Nil},;
   						{ "C5_TPFRETE" , QRYCABEC->C5_TPFRETE 			,Nil},;
   						{ "C5_VOLUME1" , QRYCABEC->C5_VOLUME1 			,Nil},;
   						{ "C5_ESPECI1" , QRYCABEC->C5_ESPECI1 			,Nil},;
   						{ "C5_TPCARGA" , QRYCABEC->C5_TPCARGA 			,Nil},;
   						{ "C5_I_AGEND" , QRYCABEC->C5_I_AGEND 			,Nil},;
   						{ "C5_I_ENVRD" , "N"                			,Nil},;
   						{ "C5_I_IDPED" , QRYCABEC->C5_I_IDPED			,Nil} }

   					_aAreaCabec := QRYCABEC->( GetArea() )

   					//================================================================================
   					// Guarda o numero do pedido de vendas original.
   					//================================================================================
   					_cCondPag := QRYCABEC->C5_CONDPAG

   					//================================================================================
   					// Efetua a transferencia entre filiais do Pedido de venda ou seja inclusao
   					//================================================================================
   					//================================================================================
   					// Salva filial corrente antes de processar a transferencia entre filiais
   					//================================================================================
   					_cFilAtual := cFilAnt

   					DBSelectArea("SC5")
   					SC5->( DBSetOrder(1) )


   					BEGIN TRANSACTION
   						//=======================================================================================================
   						// Caso outro usuario exclua, libere, fature ou bloqueie o Pedido de Venda posteriormente ao usuario ter
   						// clicado no botao ok da exclusao
   						//========================================================================================================
   						If SC5->( DBSeek( xFilial("SC5") + _cNumPed ) ) .and. EMPTY(SC5->C5_LIBEROK) .AND. EMPTY(SC5->C5_NOTA) .AND. EMPTY(SC5->C5_BLQ)
                        _cOper := SC5->C5_I_OPER
   							//Para que a exclusao no siga auto seja executada em modo exclusivo e nao esteja locado por outro usuario o pedido de venda ocrrente
   							SC5->(RecLock("SC5"),.F.)

   							_lOK_RDC := .T.

   							IF SC5->C5_I_ENVRD = "S"
   								If !u_IT_TMS(SC5->C5_I_LOCEM) //! _lWsTms
   									FWMSGRUN( ,{|P| _lOK_RDC:=U_AOMS094E(P,.F.)} , 'Aguarde!' , 'Enviando para o RDC o cancelamento do Pedido ';
   										+ SC5->C5_NUM + ", " + STRZERO(_natu,4) + " de " + strzero(_nnk,4) )
   								Else
   									FWMSGRUN( ,{|P| _lOK_RDC:=U_AOMS140E(P,.F.)} , 'Aguarde!' , 'Enviando para o TMS Multi-Embarcador o cancelamento do Pedido...';
   										+ SC5->C5_NUM + ", " + STRZERO(_natu,4) + " de " + strzero(_nnk,4) ) 
   								EndIf 
   							ENDIF

   							If _lOK_RDC

   								//Efetua a exclusao do Pedido de venda que foi efetuada a importacao para a filial de destino

   								oproc:cCaption := ("Excluindo pedido de origem " + SC5->C5_NUM + ", " + STRZERO(_natu,4) + " de " + strzero(_nnk,4))
   								ProcessMessages()
                           
	                           If nRadMenu1 != 1
	      								_cAOMS074Vld:=""
	      								_cAOMS074 := "AOMS032"	 //N�o mostra mensagens do mata410
	                           Else
	                              _cAOMS074Vld := Nil
	      								_cAOMS074    := Nil
	                           EndIf
	                           
	                           MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabcPVEx , _aItenPVEx , 5 )

   							ENDIF

   							SC5->( MSUnlock() )

   							MV_PAR15 := _cMV_PAR15 
   							MV_PAR16 := _nMV_PAR16

   							//================================================================================
   							// Exclus�o do pedido de remessa.  
   							//================================================================================
   							If ! lMsErroAuto .And. _lOK_RDC .And. ! Empty(QRYCABEC->C5_I_PVREM)
   								lMsErroAuto := U_AOMS032R(QRYCABEC->C5_FILIAL, QRYCABEC->C5_I_PVREM,oproc) 
   							EndIf 

   							If lMsErroAuto .OR. !_lOK_RDC

   								DisarmTransaction()
   								If lMsErroAuto
   									_cErro := ""//(MostraErro())
   									aErroAuto := GetAutoGRLog()

                              For nCount := 1 To Len(aErroAuto)
                                 _cErro += aErroAuto[nCount] + CHR(13)+CHR(10)
                              Next 

                              IF !EMPTY(_cErro)
                                 If Type("_cAOMS074Vld") = "C"
                                    _cErro := _cAOMS074Vld+" ["+_cErro+"]"
                                 Else
                                    _cErro := " ["+_cErro+"]"
                                 EndIf
                              ENDIF

                              _cErro := Subs(_cErro,1,2000)

   									//bBloco := {|| U_ITMsgLog(_cAOMS074Vld+CHR(13)+CHR(10)+_cErro, "_cAOMS074Vld + MostraErro()") }
   									//U_ITMSG("Ocorreu erro na transfer�ncia do pedido " + SC5->C5_NUM + ", o processamento foi abortado!","Aten��o","Verifique a mensagem(ns) de erro [Mais Detalhes] e tente novamente: ",1,,,,,,bBloco)
   								ELSE
   									If !u_IT_TMS(SC5->C5_I_LOCEM) //! _lWsTms
   									   _cErro := "Ocorreu um Erro ao Retornar o Pedido do Sistema RDC. Ocorreu erro na transfer�ncia do pedido " + SC5->C5_NUM + ", o processamento foi abortado"
   										//U_ITMSG("Ocorreu um Erro ao Retornar o Pedido do Sistema RDC","Aten��o","Ocorreu erro na transfer�ncia do pedido " + SC5->C5_NUM + ", o processamento foi abortado!",1)
   									Else 
   									   _cErro := "Ocorreu um Erro ao Retornar o Pedido do Sistema TMS-Multi-Embarcador. Ocorreu erro na transfer�ncia do pedido " + SC5->C5_NUM + ", o processamento foi abortado!"
   										//U_ITMSG("Ocorreu um Erro ao Retornar o Pedido do Sistema TMS-Multi-Embarcador.","Aten��o","Ocorreu erro na transfer�ncia do pedido " + SC5->C5_NUM + ", o processamento foi abortado!",1)
   									EndIf 
   								ENDIF

   								_lok := .F.

   								//================================================================================
   								// Restaura a Filial antes da transferencia
   								//================================================================================
   								cFilAnt := _cFilAtual

   								SM0->( DBSetOrder(1) ) // forca o indice na ordem certa
   								SM0->( DBSeek( SUBS( cNumEmp , 1 , 2 ) + cFilAnt ) )

   								aadd(_alog,{.F.,_cNumPed,_cOper,Iif(_lOK_RDC,"Erro no Processamento do ExecAuto da Tranferencia ","N�o validada tranferencia pelo Multi-Embarcador"),_cErro})

   								Break

   							Else
   											

   								//================================================================================
   								//Encerra tabela de muro do RDC do pedido excluido
   								//================================================================================
   								ZFQ->(Dbsetorder(3))
   								ZFQ->(Dbgotop())

   								If ZFQ->(Dbseek(xFilial("SC5")+_cNumPed))

   									Do while ZFQ->ZFQ_FILIAL == xFilial("SC5") .AND. ZFQ->ZFQ_PEDIDO == _cNumPed

   										IF ZFQ->ZFQ_SITUAC == 'N'
   						
   											Reclock("ZFQ",.F.)									
   											ZFQ->ZFQ_SITUAC := 'P'
   											ZFQ->(Msunlock())

   										Endif

   										ZFQ->(DbSkip())

   									Enddo

   								Endif

   								ZFR->(Dbsetorder(3))
   								ZFR->(Dbgotop())

   								If ZFR->(Dbseek(xFilial("SC5")+_cNumPed))

   									Do while ZFR->ZFR_FILIAL == xFilial("SC5") .AND. ZFR->ZFR_NUMPED == _cNumPed

   										If ZFR->ZFR_SITUAC == 'N'

   											Reclock("ZFR",.F.)
   											ZFR->(DbDelete())
   											ZFR->(Msunlock())

   										Endif

   										ZFR->(DbSkip())

   									Enddo

   								Endif


   								//================================================================================
   								// Posiciona na Filial de Transferencia
   								//================================================================================
   								cFilAnt := SubStr(_cFilTran,1,2)

   								SM0->( DBSetOrder(1))
   								SM0->( DBSeek( SubStr( cNumEmp , 1 , 2 ) + cFilAnt ) )

   								//================================================================================
   								// Variavel que controla numeracao
   								//================================================================================
   								nSaveSX8 := GetSx8Len()

   								//================================================================================
   								// Salva o PV vinculado
   								//================================================================================
   								_cSalvaPVV:=""  
   								IF (_nPos:=ASCAN(_aCabecPV,{|C|C[1]=="C5_I_PEVIN"})) # 0 //{"C5_I_PEVIN" , QRYCABEC->C5_I_PEVIN			,Nil} }
   									_cSalvaPVV:=_aCabecPV[_nPos,2]
   									_aCabecPV[_nPos,2]:=""//Limpa o campo para n�o validar no ExistCpo('SC5')
   								ENDIF

   								//================================================================================
   								// siga auto de inclusao de pedido de venda
   								//================================================================================
   								oproc:cCaption := ("Incluindo pedido na nova filial, "  + SC5->C5_NUM + ", " + STRZERO(_natu,4) + " de " + strzero(_nnk,4))
   								ProcessMessages()

                           If nRadMenu1 != 1 
      								_cAOMS074Vld:=""
      								_cAOMS074 := "AOMS032"	 //N�o mostra mensagens do mata410
                           Else
                              _cAOMS074Vld := Nil
      								_cAOMS074 := Nil
                           EndIf

                           lMsErroAuto := .F.

   								MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabecPV , _aItensPV , 3 )

   								MV_PAR15 := _cMV_PAR15 
   								//MV_PAR16 := _nMV_PAR16 

   								If lMsErroAuto

   									If ( __lSx8 )
   										RollBackSx8()
   									EndIf

   									_cErro := "" //MostraErro()
   									aErroAuto := GetAutoGRLog()

                              For nCount := 1 To Len(aErroAuto)
                                 _cErro += aErroAuto[nCount] + CHR(13)+CHR(10)
                              Next 
   									
                              IF !EMPTY(_cErro)
                                 If Type("_cAOMS074Vld") = "C"
   									      _cErro := _cAOMS074Vld+" ["+_cErro+"]"
                                 Else
                                    _cErro := "["+_cErro+"]"
                                 EndIf
   									ENDIF

                        		_cErro := Subs(_cErro,1,2000)

   									DisarmTransaction()
   									//bBloco:={||  U_ITMsgLog(_cAOMS074Vld+CHR(13)+CHR(10)+_cErro, "_cAOMS074Vld + MostraErro()") }
   									//U_ITMSG("Ocorreu erro na transfer�ncia do pedido " + SC5->C5_NUM + ", o processamento foi abortado!","Aten��o","Verifique a mensagem(ns) de erro [Mais Detalhes] e tente novamente: ",1,,,,,,bBloco)
   									_lok := .F.

   									//================================================================================
   									// Restaura a Filial antes da transferencia
   									//================================================================================
   									cFilAnt := _cFilAtual

   									SM0->( DBSetOrder(1) ) // forca o indice na ordem certa
   									SM0->( DBSeek( SUBS( cNumEmp , 1 , 2 ) + cFilAnt ) )

   									aadd(_alog,{.F.,SC5->C5_NUM,SC5->C5_I_OPER,"Erro na inclus�o do pedido na nova filial, p�s exclus�o do pedido na filial de origem.",_cErro})

   									Break

   								Else

   									If __lSX8

   										While ( GetSX8Len() > nSaveSX8 )
   											ConfirmSX8()
   										EndDo

   									EndIf

   									IF !EMPTY(_cSalvaPVV)
   										SC5->(RecLock("SC5"),.F.)
   										SC5->C5_I_PEVIN:=_cSalvaPVV   
   										SC5->( MSUnlock() )
   									ENDIF

   									SC5->( Reclock( "SC5", .F. ) )
   									//SC5->C5_I_ORTBP := _ntab  //recno de regra da tabela de pre�os definida // Removido por solicita��o do analista respons�vel.
   									//=========================================================================================
   									// A condi��o de pagamento do pedido original de ser mantida na transfer�ncia de filial.
   									//=========================================================================================
   									SC5->C5_CONDPAG := _cCondPag
   									SC5->( Msunlock())

   									//================================================================================
   									// Indica o pedido criado
   									//================================================================================
   									If nRadMenu1 == 1

   										U_ITmsg("Pedido criado com sucesso na filial " + cFilAnt + " com n�mero: " + alltrim(SC5->C5_NUM) + ".","Informa��o",,2)

   									Else

   										aadd(_alog, {.T.,SC5->C5_NUM,SC5->C5_I_OPER, "Pedido criado com sucesso na filial " + cFilAnt + " com n�mero: " + alltrim(SC5->C5_NUM) + ".",""})

   									Endif

   									//================================================================================
   									// Grava log de atualiza��o
   									//================================================================================
   									SC6->(DbSetOrder(1))

   									For _nI := 1 To Len(_aDadosSC6)
   										If SC6->(MsSeek(SC5->( C5_FILIAL + C5_NUM) + U_ItKey(_aDadosSC6[_nI,4],"C6_ITEM")))
   											_aDadosSC6[_nI,3] := &("SC6->" + _aDadosSC6[_nI,1])  
   										EndIf  
   									Next  

   									For _nI := 1 To Len(_aDadosSC5)
   										_aDadosSC5[_nI,3] := &("SC5->" + _aDadosSC5[_nI,1])
   									Next 

   									U_ITGrvLog( _aDadosSC5 , "SC5" , 1 , SC5->( C5_FILIAL + C5_NUM ) , "T" , __CUSERID , Date() , Time() ) 

   									For _nI := 1 To Len(_aDadosSC6)
   										_aLogSC6 := {}
   										Aadd(_aLogSC6, {_aDadosSC6[_nI,1],_aDadosSC6[_nI,2],_aDadosSC6[_nI,3]})

   										U_ITGrvLog( _aLogSC6 , "SC6" , 1 , SC5->( C5_FILIAL + C5_NUM )+_aDadosSC6[_nI,4] , "T" , __CUSERID , Date() , Time() )
   									Next 

   									U_GrvMonitor(SC5->C5_FILIAL,SC5->C5_NUM,"Transfer�ncia de PV","Transfer�ncia de PV","T",SC5->C5_I_DTENT,SC5->C5_I_DTENT,SC5->C5_I_DTENT)  

   									//================================================================================
   									// Restaura a Filial antes da transferencia
   									//================================================================================
   									cFilAnt := _cFilAtual

   									SM0->( DBSetOrder(1) ) // forca o indice na ordem certa
   									SM0->( DBSeek( SUBS( cNumEmp , 1 , 2 ) + cFilAnt ) )

   								EndIf

   							EndIf

   						Else

   							//Registra problema com pedido
   							If !SC5->( DBSeek( xFilial("SC5") + _cNumPed ) )
   								If nRadMenu1 == 1
   									U_ITMSG( "Pedido " + _cNumPed + " foi excluido antes do processamento","Aten��o",,1)
   								Else
   									aadd(_alog,{.F.,_cNumPed,"","Pedido " + _cNumPed + " foi excluido antes do processamento",""})
   								Endif
   							elseIf !EMPTY(SC5->C5_LIBEROK)
   								If nRadMenu1 == 1
   									U_ITMSG( "Pedido " + _cNumPed + " foi liberado antes do processamento","Aten��o",,1)
   								Else
   									aadd(_alog,{.F.,SC5->C5_NUM,SC5->C5_I_OPER,"Pedido " + _cNumPed + " foi liberado antes do processamento",""})
   								Endif
   							elseIf !EMPTY(SC5->C5_NOTA)
   								If nRadMenu1 == 1
   									U_ITMSG( "Pedido " + _cNumPed + " foi faturado antes do processamento","Aten��o",,1)
   								Else
   									aadd(_alog,{.F.,SC5->C5_NUM,SC5->C5_I_OPER,"Pedido " + _cNumPed + " foi faturado antes do processamento",""})
   								Endif
   							elseIf !EMPTY(SC5->C5_BLQ)
   								If nRadMenu1 == 1
   									U_ITMSG( "Pedido " + _cNumPed + " foi bloqueado antes do processamento","Aten��o",,1)
   								Else
   									aadd(_alog,{.F.,SC5->C5_NUM,SC5->C5_I_OPER,"Pedido " + _cNumPed + " foi bloqueado antes do processamento",""})
   								Endif
   							Endif

   						EndIf

   						RestArea(_aAreaCabec)

   					End Transaction

   				END SEQUENCE
            Else
               AADD(_alog,_aMsgVld[_nPos] )
            EndIf
            
				QRYCABEC->( DBSkip() )

			EndDo

			If nRadMenu1 != 1 .and. len(_alog) > 0 //.and. _lok

				U_ITListBox('Resultados da transfer�ncia de pedidos de vendas',;
					{"","Pedido" , "Opera��o", "Erro" , "Descri��o"} , _alog , .T. , 4,;
					"Abaixo segue a lista de resultados na transfer�ncia de Pedidos de Vendas: " )
			ElseIf nRadMenu1 = 1 .and. !Empty(Alltrim(_cErro))
            // ITmsg(_cMens                                         ,_ctitu   ,_csolu,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes                           ,_cMaisDetalhes,_lRetXNil)
				u_itmsg("Processamento n�o gravou nenhuma transfer�ncia","Aten��o",      ,1     ,       ,        ,         ,     ,     ,{||  U_ITMsgLog(_cErro, "ATENCAO",1,.F.)},              ,)

			Endif
		EndIf
		
		QRYCABEC->( DBCloseArea() )

	Else

		//================================================================================
		// Fecha a area de uso do arquivo temporario no Protheus.
		//================================================================================
		TRBT->( DBCloseArea() )

	EndIf


//================================================================================
// Restaura a area
//================================================================================
	RestArea( _aArea )

Return()

/*
===============================================================================================================================
Programa----------: AOMS032PSQ
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 13/04/2010
===============================================================================================================================
Descri��o---------: Funcao para pesquisa no arquivo temporario.
===============================================================================================================================
Parametros--------: oMark  - Objeto de dados
------------------: cAlias - Alias tempor�rio
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS032PSQ( oMark , cAlias )

	Local oGet1		:= Nil
	Local oDlg		:= Nil
	Local cGet1		:= Space(40)
	Local cComboBx1	:= ""
	Local aComboBx1	:= { "Pedido" , "Cliente+Loja" , "Descricao Cliente" , "Descricao Rede" }
	Local nOpca		:= 0
	Local nI		:= 0

	DEFINE MSDIALOG oDlg TITLE "Pesquisar" FROM 178,181 TO 259,697 PIXEL

	@004,003 ComboBox	cComboBx1	Items aComboBx1 Size 213,010 OF oDlg PIXEL
	@020,003 MsGet		oGet1		Var cGet1		Size 212,009 OF oDlg PIXEL COLOR CLR_BLACK Picture "@!"

	DEFINE SBUTTON FROM 004,227 TYPE 1 ENABLE ACTION ( nOpca := 1 , oDlg:End() ) OF oDlg
	DEFINE SBUTTON FROM 021,227 TYPE 2 ENABLE ACTION ( nOpca := 0 , oDlg:End() ) OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpca == 1

		For nI := 1 To Len(aComboBx1)

			If cComboBx1 == aComboBx1[nI]

				DBSelectArea("TRBT")
				TRBT->( DBSetOrder(nI) )

				MsSeek( cGet1 , .T. )

				oMark:oBrowse:Refresh( .T. )

			EndIf

		Next nI

	EndIf

Return()

/*
===============================================================================================================================
Programa----------: AOMS032INV
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 13/04/2010
===============================================================================================================================
Descri��o---------: Rotina para inverter a marcacao do registro posicionado.
===============================================================================================================================
Parametros--------: oMark  - Objeto de dados
------------------: cAlias - Alias tempor�rio
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS032INV( cMarca , lInverte , oQtda )

	Local lMarcado := IsMark( "TRBT_OK" , cMarca , lInverte )

	If lMarcado
		nQtdTit++
	Else
		nQtdTit--
	EndIf

    oQtda:Refresh()

Return()

/*
===============================================================================================================================
Programa----------: AOMS032ALL
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 13/04/2010
===============================================================================================================================
Descri��o---------: Rotina para inverter a marcacao de todos os registros.
===============================================================================================================================
Parametros--------: oMark  - Objeto de dados
------------------: cAlias - Alias tempor�rio
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS032ALL( cMarca , oQtda )

	Local nReg     := TRBT->( Recno() )
	Local lMarcado := .F.

	DBSelectArea("TRBT")
	TRBT->( DBGoTop() )

	While TRBT->( !Eof() )

		lMarcado := IsMark( "TRBT_OK" , cMarca , lInverte )

		If lMarcado .Or. lInverte

			TRBT->( RecLock( "TRBT" , .F. ) )
			TRBT->TRBT_OK := Space(2)
			TRBT->( MsUnLock() )
            
			nQtdTit--			

		Else

			TRBT->( RecLock( "TRBT" , .F. ) )
			TRBT->TRBT_OK := cMarca
			TRBT->( MsUnLock() )

			nQtdTit++
		
		EndIf

		nQtdTit := IIf( nQtdTit < 0 , 0 , nQtdTit )

		TRBT->( DBSkip() )
	EndDo

	TRBT->( DBGoto(nReg) )

	oQtda:Refresh()
	oMark:oBrowse:Refresh(.T.)

Return()

/*
===============================================================================================================================
Programa----------: AOMS032ARQ
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 13/04/2010
===============================================================================================================================
Descri��o---------: Rotina para cria��o do arquivo tempor�rio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS032ARQ()

	Local aEstru		:= {}
	Local cFiltro		:= "%"

	Local _lRetEmail	:= .T.
	Local _lRetVend 	:= .T.
	Local _nNumReg		:= 0
	Local _cMsgEmail	:= ""
	Local _cMsgVend		:= ""

//================================================================================
// Armazena no array aEstru a estrutura dos campos da tabela.
//================================================================================
	AADD( aEstru , { "TRBT_OK"		, 'C' , 02 , 0 } )
	AADD( aEstru , { "TRBT_FILIA"	, 'C' , 02 , 0 } )
	AADD( aEstru , { "TRBT_NUM"	, 'C' , 06 , 0 } )
	AADD( aEstru , { "TRBT_DTEMI"	, 'D' , 08 , 0 } )
	AADD( aEstru , { "TRBT_CODCL"	, 'C' , 06 , 0 } )
	AADD( aEstru , { "TRBT_LOJCL"	, 'C' , 04 , 0 } )
	AADD( aEstru , { "TRBT_DESCL"	, 'C' , 30 , 0 } )
	AADD( aEstru , { "TRBT_CODRE"	, 'C' , 06 , 0 } )
	AADD( aEstru , { "TRBT_DESCR"	, 'C' , 20 , 0 } )
	AADD( aEstru , { "TRBT_CODVE"	, 'C' , 06 , 0 } )
	AADD( aEstru , { "TRBT_DESVE"	, 'C' , 25 , 0 } )
	AADD( aEstru , { "TRBT_VALOR"	, 'N' , 14 , 2 } )
	AADD( aEstru , { "TRBT_FILCR"	, 'C' , 02 , 0 } )//AWF- Filial de Carregamento
	AADD( aEstru , { "TRBT_FILFT"	, 'C' , 02 , 0 } )//AWF- Filial de Faturamento
	AADD( aEstru , { "TRBT_AGEND"	, 'C' , 01 , 0 } )
	AADD( aEstru , { "C5_I_PEVIN"	, 'C' , LEN(SC5->C5_I_PEVIN),0})//AWF- PV Vinculado
	AADD( aEstru , { "C5_I_ENVRD"	, 'C' , LEN(SC5->C5_I_ENVRD),0})//AWF- PV RDC
	AADD( aEstru , { "C5_I_PVREM"	, 'C' , 06 , 0 } )  // PV Remessa - Opera��o Triangular
	AADD( aEstru , { "C5_I_TRCNF" , "C" , 03 , 0 } ) 
   AADD( aEstru , { "C5_I_OPER"  , "C" , LEN(SC5->C5_I_OPER) , 0 } )


//================================================================================
// Armazena no array aCampos o nome, picture e descricao dos campos
//================================================================================
	AADD( aCampos , { "TRBT_OK"		, "" , " "					, " "										} )
	AADD( aCampos , { "TRBT_FILIA"	, "" , "Filial"				, PesqPict( "SC5" , "C5_FILIAL"	 )			} )
	AADD( aCampos , { "TRBT_NUM"	, "" , "Pedido"				, PesqPict( "SC5" , "C5_NUM"	 )	 		} )
	AADD( aCampos , { "C5_I_TRCNF"	, "" , "PV Troca NF?"		, "@!"	                            		} )
	AADD( aCampos , { "TRBT_DTEMI"	, "" , "Data Emissao"		, PesqPict( "SC5" , "C5_EMISSAO" )	  		} )
	AADD( aCampos , { "TRBT_CODCL"	, "" , "Cliente"			, PesqPict( "SC5" , "C5_CLIENTE" )	  		} )
	AADD( aCampos , { "TRBT_LOJCL"	, "" , "Loja"				, PesqPict( "SC5" , "C5_LOJACLI" )	  		} )
	AADD( aCampos , { "TRBT_DESCL"	, "" , "Descricao Cliente"	, PesqPict( "SC5" , "C5_I_NOME"  )	  		} )
	AADD( aCampos , { "TRBT_CODRE"	, "" , "Rede"				, PesqPict( "SC5" , "C5_I_GRPVE" )	  		} )
	AADD( aCampos , { "TRBT_DESCR"	, "" , "Descricao Rede"		, PesqPict( "SC5" , "C5_I_NOMRD" )	  		} )
	AADD( aCampos , { "TRBT_CODVE"	, "" , "Vendedor"			, PesqPict( "SC5" , "C5_VEND1"   )	  		} )
	AADD( aCampos , { "TRBT_DESVE"	, "" , "Descricao Vendedor"	, PesqPict( "SC5" , "C5_I_V1NOM" )	  		} )
	AADD( aCampos , { "TRBT_VALOR"	, "" , "Valor da Venda"		, PesqPict( "SF2" , "F2_VALBRUT" , 14 , 2 )	} )
	AADD( aCampos , { "TRBT_FILCR"	, "" , "Filial Carregamento", "@!"	} )//AWF - Filial de Carregamento
	AADD( aCampos , { "TRBT_FILFT"	, "" , "Filial Faturamento" , "@!"	} )//AWF - Filial de Faturamento]
	AADD( aCampos , { "TRBT_AGEND"  , "" , "Tipo de Entrega"    , "@!"	} )
	AADD( aCampos , { {||IF(TRBT->C5_I_ENVRD="S","Sim","N�o")},"","Envio TMS?",""} )//AWF - PV RDC
	AADD( aCampos , { "C5_I_PEVIN"	, "" , "PV Vinculado"       , "@!"	} )//AWF - PV Vinculado
	AADD( aCampos , { "C5_I_PVREM"	, "" , "PV Remessa"         , "@!"	} ) // PV Remessa Opera��o Triangular 

//================================================================================
// Verifica se ja existe um arquivo com mesmo nome, se sim deleta.
//================================================================================
	If Select("TRBT") > 0
		TRBT->( DBCloseArea() )
	EndIf

//================================================================================
// Permite o uso do arquivo criado dentro do protheus.
//================================================================================
	_otemp := FWTemporaryTable():New( "TRBT", aEstru )

	_otemp:AddIndex( "01", {"TRBT_NUM"} )
	_otemp:AddIndex( "02", {"TRBT_CODCL","TRBT_LOJCL"} )
	_otemp:AddIndex( "03", {"TRBT_DESCL"} )
	_otemp:AddIndex( "04", {"TRBT_DESCR"} )
	_otemp:AddIndex( "05", {"C5_I_PVREM"} )

	_otemp:Create()

//================================================================================
// Filtra Filiais
//================================================================================
	If !Empty( xFilial("SC5") )
		cFiltro += " AND C5.C5_FILIAL	= '"+ xFilial("SC5") +"' "
	EndIf

	If !Empty( xFilial("SC6") )
		cFiltro += " AND C6.C6_FILIAL	= '"+ xFilial("SC6") +"' "
	EndIf

	If !Empty( xFilial("SA1") )
		cFiltro += " AND A1.A1_FILIAL	= '"+ xFilial("SA1") +"' "
	endIf

	If !Empty( xFilial("SA3") )
		cFiltro += " AND SA3.A3_FILIAL	= '"+ xFilial("SA3") +"' "
	EndIf

//================================================================================		      	
// Transferir pedido posicionado
//================================================================================
	If nRadMenu1 == 1

		cFiltro += " AND C5.C5_FILIAL	= '"+ SC5->C5_FILIAL +"' "
		cFiltro += " AND C5.C5_NUM		= '"+ SC5->C5_NUM    +"' "
        
//================================================================================
// Op��o de Transferencia de Varios Pedidos
//================================================================================
	Else

		//================================================================================
		// Emissao de - Ate
		//================================================================================
		If !Empty( MV_PAR01 ) .And. !Empty( MV_PAR02 )
			cFiltro += " AND C5.C5_EMISSAO	BETWEEN '"+ dtos(MV_PAR01)	+"' AND '"+ dtos(MV_PAR02)	+"' "
		EndIf

		//================================================================================
		// Data Entrega De - Ate
		//================================================================================
		If !Empty( MV_PAR03 ) .And. !Empty( MV_PAR04 )
			cFiltro += " AND C6.C6_ENTREG	BETWEEN '"+ dtos(MV_PAR03)	+"' AND '"+ dtos(MV_PAR04)	+"' "
		EndIf

		//================================================================================
		// Cliente De - Ate
		//================================================================================
		If !Empty( MV_PAR05 ) .And. !Empty( MV_PAR07 )
			cFiltro += " AND C5.C5_CLIENTE	BETWEEN '"+ MV_PAR05		+"' AND '"+ MV_PAR07		+"' "
		EndIf

		//================================================================================
		// Loja De - Ate
		//================================================================================
		If !Empty( MV_PAR06 ) .And. !Empty( MV_PAR08 )
			cFiltro += " AND C5.C5_LOJACLI	BETWEEN '"+ MV_PAR06		+"' AND '"+ MV_PAR08		+"' "
		EndIf

		//================================================================================
		// Rede
		//================================================================================
		If !Empty( MV_PAR09 )
			cFiltro += " AND C5.C5_I_GRPVE	IN "+ FormatIn( MV_PAR09 , ";" )
		EndIf

		//================================================================================
		// Estado
		//================================================================================
		If !Empty( MV_PAR10 )
			cFiltro  += " AND A1.A1_EST		IN "+ FormatIn( MV_PAR10 , ";" )
		EndIf

		//================================================================================
		// Municipio
		//================================================================================
		If !Empty( MV_PAR11 )
			cFiltro  += " AND A1.A1_COD_MUN	IN "+ FormatIn( MV_PAR11 , ";" )
		EndIf

		//================================================================================
		// Filtra Supervisor
		//================================================================================
		If !Empty( MV_PAR12 )
			cFiltro += " AND A3.A3_SUPER	IN "+ FormatIn( MV_PAR12 , ";" )
		EndIf

		//================================================================================
		// Filtra Vendedor
		//================================================================================
		If !Empty( MV_PAR13 )
			cFiltro += " AND A3.A3_COD		IN "+ FormatIn( MV_PAR13 , ";" )
		EndIf

		//================================================================================
		// Filtra Produto
		//================================================================================
		If !Empty( MV_PAR14 )
			cFiltro += " AND C6.C6_PRODUTO	IN "+ FormatIn( MV_PAR14 , ";" )
		EndIf

        //================================================================================
		// Filtro por Armaz�m.
		//================================================================================
		If !Empty( MV_PAR20 )
			cFiltro += " AND C6.C6_LOCAL IN "+ FormatIn( MV_PAR20 , ";" )
		EndIf

	EndIf

//Valida bloqueio logistico
//Verifica permiss�o de ajuste de bloqueio log�stico
	ZZL->(Dbsetorder(3))
	If !(ZZL->(Dbseek(xFilial("ZZL") + RetCodUsr()))) .OR. ZZL->ZZL_PVLOG != "S"

		cFiltro += " AND C5.C5_I_BLOG <> 'S' "

	Endif

	cFiltro += " %"

//================================================================================
// Verifica se ja existe um arquivo com mesmo nome, se sim deleta.
//================================================================================
	If Select("QRYPED") > 0
		QRYPED->( DBCloseArea() )
	EndIf

//================================================================================
// Query para selecao dos dados DOS PEDIDOS
//================================================================================
	BeginSql alias "QRYPED"

	SELECT		C5.C5_FILIAL	, C5.C5_NUM		, C5.C5_CLIENTE	, C5.C5_LOJACLI		, A1.A1_NOME	,
				C5.C5_I_GRPVE	, C5.C5_I_NOMRD	, C5.C5_VEND1	, A3.A3_NOME		, C5.C5_EMISSAO	,
				C5.C5_I_PEDGE	, C5.C5_I_NPALE	, A1.A1_EMAIL	, SUM(C6.C6_VALOR) 	VALOR,
				C5.C5_I_FILFT	, C5.C5_I_FLFNC , C5_I_AGEND    , C5_I_PEVIN        , C5_I_ENVRD , C5_I_PVREM, C5_I_TRCNF, C5_I_OPER  
	
	FROM		%table:SC5% C5
	
	JOIN		%table:SC6% C6  ON C5.C5_FILIAL  = C6.C6_FILIAL AND C5.C5_NUM     = C6.C6_NUM
	JOIN		%table:SA1% A1  ON C5.C5_CLIENTE = A1.A1_COD    AND C5.C5_LOJACLI = A1.A1_LOJA
	JOIN		%table:SA3% A3  ON C5.C5_VEND1   = A3.A3_COD
	
	WHERE			C5.D_E_L_E_T_ = ' '
				AND C6.D_E_L_E_T_ = ' '
				AND A1.D_E_L_E_T_ = ' '
				AND A3.D_E_L_E_T_ = ' '
				AND C6.C6_PRODUTO <> '08130000002'
				AND C5.C5_LIBEROK = ' '
				AND C5.C5_NOTA    = ' '
				AND C5.C5_BLQ     = ' '
				AND (C5_I_PDFT = ' ' AND C5_I_PDPR = ' ')//ignora Troca Nota GERADAS AWF
				%exp:cFiltro%
	
	GROUP BY	C5.C5_FILIAL,C5.C5_NUM,C5.C5_CLIENTE,C5.C5_LOJACLI,A1.A1_NOME,C5.C5_I_GRPVE,C5.C5_I_NOMRD,C5.C5_VEND1,A3.A3_NOME,C5.C5_EMISSAO,C5.C5_I_PEDGE,C5.C5_I_NPALE,A1.A1_EMAIL,C5.C5_I_FILFT,C5.C5_I_FLFNC, C5_I_AGEND, C5_I_PEVIN, C5_I_ENVRD, C5_I_PVREM, C5_I_TRCNF , C5_I_OPER
	ORDER BY	C5_FILIAL,C5_NUM
	
	EndSql

	DBSelectArea("QRYPED")
	QRYPED->( DBGoTop() )

//================================================================================
// 1 - Indica que nao foram encontrados dados
// 0 - Indica que foram encontrados dados
//================================================================================
	_nRet := 1

	While QRYPED->(!EOF())

		_nRet := 0

		//================================================================================
		// Verifica se o e-mail fornecido no cadastro do cliente esta com um formato
		// valido ou vazio, pois caso encontre algum problema o pedido de venda nao sera
		// incluido para transferencia.
		//================================================================================
		_lRetEmail := U_EEmail( AllTrim( QRYPED->A1_EMAIL ) )

		//================================================================================
		// Armazena o numero dos pedidos que foram encontrado problema no cadastro
		//================================================================================
		If !_lRetEmail
			_cMsgEmail += "," + QRYPED->C5_NUM
		EndIf

		//================================================================================
		// Valida se o vendedor nao esta bloqueado no cadastro de vendedor.
		//================================================================================
		_lRetVend := AOMS032VEN( QRYPED->C5_VEND1 )

		//================================================================================
		// Armazena o numero dos pedidos que foram encontrado problema no cadastro
		//================================================================================
		If !_lRetVend
			_cMsgVend += ","+ QRYPED->C5_NUM
		EndIf

		_lRetPrg := .T.


		//================================================================================
		// Caso nao tenha encontrado problema no e-mail nem no cadastro do vendedor
		// continua com a insercao dos pedidos que podem realizar a transferencia.
		//================================================================================
		If _lRetEmail .And. _lRetVend  .And. _lRetPrg

			//================================================================================
			// Verifica se o pedido de venda corrente gerou um pedido de pallet, e se este
			// pedido de pallet nao esta liberado, caso esteja o pedido que originou este
			// pedido de pallet nao fara parte dos pedidos liberados para  realizar a
			// transferencia, uma vez que o pedido de pallet nao podera ser excluido pois esta
			// liberado e isso nao � tratado pelo siga auto - .T. Pedido nao esta liberado
			//================================================================================
			If AOMS032VPP( QRYPED->C5_I_NPALE , QRYPED->C5_I_PEDGE )

				//================================================================================
				// Armazena o numero de registros encontrados.
				//================================================================================
				_nNumReg++

				DBSelectArea("TRBT")
				TRBT->( RecLock( "TRBT" , .T. ) )

				TRBT->TRBT_FILIA  := QRYPED->C5_FILIAL
				TRBT->TRBT_NUM    := QRYPED->C5_NUM
				TRBT->TRBT_DTEMI  := STOD(QRYPED->C5_EMISSAO)
				TRBT->TRBT_CODCL  := QRYPED->C5_CLIENTE
				TRBT->TRBT_LOJCL  := QRYPED->C5_LOJACLI
				TRBT->TRBT_DESCL  := QRYPED->A1_NOME
				TRBT->TRBT_CODRE  := QRYPED->C5_I_GRPVE
				TRBT->TRBT_DESCR  := QRYPED->C5_I_NOMRD
				TRBT->TRBT_CODVE  := QRYPED->C5_VEND1
				TRBT->TRBT_DESVE  := QRYPED->A3_NOME
				TRBT->TRBT_VALOR  := QRYPED->VALOR
				TRBT->TRBT_FILCR  := QRYPED->C5_I_FLFNC//Filial de Carregamento
				TRBT->TRBT_FILFT  := QRYPED->C5_I_FILFT//Filial de Faturamento
				TRBT->TRBT_AGEND  := QRYPED->C5_I_AGEND
				TRBT->C5_I_PEVIN  := QRYPED->C5_I_PEVIN//PV Vinculado
				TRBT->C5_I_ENVRD  := QRYPED->C5_I_ENVRD//PV RDC
				TRBT->C5_I_PVREM  := QRYPED->C5_I_PVREM // PV Remessa
				TRBT->TRBT_OK     := cMarca
				TRBT->C5_I_TRCNF  := If(QRYPED->C5_I_TRCNF == "S","SIM","NAO")
            TRBT->C5_I_OPER   := QRYPED->C5_I_OPER

				TRBT->( MsUnlock("TRBT") )

			EndIf

		EndIf

		QRYPED->( DBSkip() )
	EndDo

	QRYPED->( DBCloseArea() )
    
	//================================================================================
	// Adiciona pedidos de remessa a tabela tempor�ria.
	//================================================================================

//================================================================================
// Verifica se foi encontrado algum e-mail com problema no cadastro do cliente 
// para emitir uma mensagem informando ao usuario.
//================================================================================
	If !Empty( _cMsgEmail )

		U_ITmsg("O(s) pedido(s) informado(s) abaixo encontra(m)-se com o cadastro do e-mail vazio ou com o formato inv�lido, "+;
			"Pedido(s) de venda que se encontra(m) com problema: "+_ENTER + SubStr( _cMsgEmail , 2 )			  ,;
			"Informa��o"																						  ,;
			"Favor alterar o cadastro do cliente antes de realizar esta opera��o.",3)

	EndIf

	If !Empty( _cMsgVend )

		U_ITmsg("O(s) pedido(s) informado(s) abaixo encontra(m)-se com o cadastro do vendedor bloqueado ou nao foi encontrado "	+;
			"o cadastro do vendedor, Pedido(s) de venda que se encontra(m) com problema: "+_ENTER + SubStr( _cMsgVend , 2 ),;
			"Informa��o"																					   ,;
			"Favor alterar o cadastro do vendedor antes de realizar esta opera��o.",3)
	EndIf


//================================================================================
// Nao foram encontrados pedidos de venda para realizar a  transferencia
//================================================================================
	If _nNumReg == 0
		_nRet := 1
	EndIf

Return( _nRet )

/*
===============================================================================================================================
Programa----------: AOMS032PPV
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 13/04/2010
===============================================================================================================================
Descri��o---------: Fun��o para Pesquisar Pedidos de Vendas
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS032PPV()

	DBSelectArea("SC5")
	SC5->( DBSetOrder(1) )
	If SC5->( DBSeek( TRBT->( TRBT_FILIA + TRBT_NUM ) ) )
		A410Visual( "SC5" , SC5->( RECNO() ) , 1 )
	EndIf

Return()

/*
===============================================================================================================================
Programa----------: AOMS032VLD
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 13/04/2010
===============================================================================================================================
Descri��o---------: Verifica a sele��o dos pedidos e a informa��o referente � filial de transfer�ncia
===============================================================================================================================
Parametros--------: nQtdTit   - Quantidade de T�tulos Selecionados
------------------: _cFilTran - Filial de Destino
===============================================================================================================================
Retorno-----------: _lRet     - Define se os dados foram validados com sucesso
===============================================================================================================================
*/
User Function AOMS032VLD( nQtdTit )

	Local _lRet		:= .T.
	Local _aArea	:= GetArea()
	Local oproc     := nil

//================================================================================
// Verifica se o usurio selecionou pedidos de vendas e informou a filial
//================================================================================
	If nQtdTit == 0
		//             Pedido , Opera��o, Erro                                    , Descri��o
		Aadd(_aMsgVld,{.F. , "", "  "   , ""      , "NENHUM PEDIDO DE VENDAS FOI SELECIONADO PARA A REALIZA��O DA TRANSFER�NCIA.","Para dar andamento na transfer�ncia de pedidos, deve-se selecionar pelo menos um pedido de vendas."})

		_lRet := .F.

	EndIf

	If _lRet
		fwmsgrun( ,{|oproc| _lRet := AOMS032TES(_cFilTran,oproc,.F.) } , "Aguarde validando TES INTELIGENTE...", "Aguarde validando TES INTELIGENTE..." ) // AOMS032TES(_cFilTran,oproc,.F.) 

		fwmsgrun( ,{|oproc| _lRet := AOMS032N(_cFilTran,oproc, .F.) } , "Aguarde validando data de entrega...", "Aguarde validando data de entrega..." )
	EndIf

//================================================================================
// Restaura a Area
//================================================================================
	RestArea( _aArea )

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AOMS032VPP
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 13/04/2010
===============================================================================================================================
Descri��o---------: Funcao utilizada para verificar se o Pedido de Pallet ja sofreu liberacao, pois diante disso o seu pedido
------------------: gerador nao sera disponibilizado para a transferencia, uma vez que este pedido de pallet nao podera ser
------------------: excluido da sua filial de origem, e o siga auto nao trata esta questao.
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _lRet - Define se o pedido de Pallet pode ser transferio (sem libera��o)
===============================================================================================================================
*/

Static Function AOMS032VPP( _cNumPedPa , _cGerPede )

	Local _lRet		:= .T.
	Local _aArea	:= GetArea()

//================================================================================
// Verifica se esse Pedido gerou outro Pedido de Pallet
//================================================================================
	If !Empty(_cNumPedPa)

		//================================================================================
		// Verifica se o Pedido a ser validado � o pedido gerador do Pedido de Pallet
		//================================================================================
		If _cGerPede == "S"

			DBSelectArea("SC5")
			SC5->( DBSetOrder(1) )
			If SC5->( DBSeek( xFilial("SC5") + _cNumPedPa ) )

				//================================================================================
				// Que dizer que o Pedido de Pallet gerado ja sofreu libera��o
				//================================================================================
				If !Empty(SC5->C5_LIBEROK)
					_lRet := .F.
				EndIf

			EndIf

		EndIf

	EndIf

	RestArea( _aArea )

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AOMS032VEN
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 13/04/2010
===============================================================================================================================
Descri��o---------: Funcao utilizada para verificar se o vendedor nao se encontra bloqueado no cadastro de vendedor.
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _lRet - Define se o Vendedor est� liberado para uso
===============================================================================================================================
*/

Static Function AOMS032VEN(_cVendedor)

	Local _lRet		:= .T.
	Local _aArea	:= GetArea()

	dbSelectArea("SA3")
	SA3->(dbSetOrder(1))
	If SA3->(dbSeek(xFilial("SA3") + _cVendedor))

		//================================================================================
		// Indica que o vendedor esta bloqueado e n�o sera possivel realizar a operacao
		//================================================================================
		_lRet := ( SA3->A3_MSBLQL <> '1' )

//================================================================================
// Caso n�o encontre o cadastro do vendedor informado retorna falso
//================================================================================
	Else

		_lRet := .F.

	EndIf

	RestArea( _aArea )

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AOMS032N
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 13/04/2010
===============================================================================================================================
Descri��o---------: Valida��o de data de entrega dos pedidos selecionados
===============================================================================================================================
Parametros--------: _cFilDest   - Filial de Destino
					oproc - objeto da barra de processamento
					_lExibeTela = .T. = Exibe tela e mensagens de confirma��o.
					              .F. = Apenas valida e n�o exibe tela e mensagens de confirma��o. 
===============================================================================================================================
Retorno-----------: _lRet - .T. - valida��o das datas de entrega
===============================================================================================================================
*/

Static Function AOMS032N( _cFilDest, oproc, _lExibeTela)
	Local _cNumPed		:= ""
	Local _lRet			:= .T.
	Local _cAliasPed	:= ""
	Local _cPedFats     := ""
	Local _nContaPV     := 0
	Local aPSeleionados := {}
	Local aPVinculados  := {}
	Local _cNomeCli, _cTipoEntrega:=""
	Local _nRecnoSC5    := SC5->(Recno())
	Local _aOrd         := SaveOrd({"SC5","SC6","SA1"})
	Local _nI := 0

	Private _lsubs      := .F.
	Private _aCbAOMS32 := {} , _aItAOMS32 := {}

	Default _lExibeTela := .T.

//================================================================================
// Verifica todos os pedidos de venda que foram selecionados para a transferencia
//================================================================================
	DbSelectArea("TRBT")

	oproc:cCaption := ( "Processando itens de pedidos na fase 1/3, aguarde....")
	ProcessMessages()

	TRBT->( DBGoTop() )

	_nnl := 0

	Do while TRBT->(!Eof())

		_nnl++
		TRBT->(Dbskip())

	Enddo

	TRBT->( DBGoTop() )
	_nni := 0

//================================================================================
// Armazena todos os pedidos selecionados pelo usuario
//================================================================================
	DO While TRBT->(!EOF())

		//================================================================================
		// Somente pedidos selecionados pelo usuario
		//================================================================================
		_nni++
		oproc:cCaption := ( "Processando itens de pedidos na fase 2/3, , item " + strzero(_nni,4) + " de " + strzero(_nnl,4) + "....")
		ProcessMessages()

		If IsMark( "TRBT_OK" , cMarkado )
			_nI += 1

			If _nI > _MAX_NR_PEDIDOS
				Exit
			EndIf

			_cNumPed += "'"+ TRBT->TRBT_NUM +"',"
			_nContaPV++
			IF !EMPTY(TRBT->TRBT_FILFT) .AND. _cFilDest = TRBT->TRBT_FILFT
				_cPedFats+="'"+ TRBT->TRBT_NUM +"',"
			ENDIF

			AADD(aPSeleionados,TRBT->TRBT_NUM)
			IF !EMPTY(TRBT->C5_I_PEVIN) // PV Vinculado
				AADD(aPVinculados,{TRBT->TRBT_NUM,TRBT->C5_I_PEVIN})
			ENDIF
		EndIf

		TRBT->( DBSkip() )

	EndDo

//================================================================================
// Query para selecionar os dados para verificacao dos pedidos de venda 
//================================================================================
	_cAliasPed := GetNextAlias()

	AOMS032Q( 1 , _cAliasPed , _cNumPed , "" , "" , "" , "" )

	DBSelectArea( _cAliasPed )
	(_cAliasPed)->( DBGotop() )
	COUNT TO _nNumReg

	ProcRegua( _nNumReg )

	DBSelectArea( _cAliasPed )
	(_cAliasPed)->( DBGotop() )

	_aLog:={}
	SA1->(dbSetOrder(1))
	SC5->(DbSetOrder(1))

	_nnl := 0
	Do while (_cAliasPed)->(!Eof())
		_nnl++
		(_cAliasPed)->(Dbskip())
	Enddo

	(_cAliasPed)->( DBGotop() )

	_nni := 0

	While (_cAliasPed)->( !Eof() )

		_nni++
		oproc:cCaption := ( "Processando itens de pedidos na fase 3/3, , item " + strzero(_nni,4) + " de " + strzero(_nnl,4) + "....")
		ProcessMessages()

		//===============================================================
		// Valida��es sobre o Pedido de Vendas SC5.
		//===============================================================
		_cNomeCli := Posicione("SA1",1,xFilial("SA1")+(_cAliasPed)->A1_COD + (_cAliasPed)->A1_LOJA ,"A1_NREDUZ")

		_cTipoEntrega := (_cAliasPed)->C5_I_AGEND+" - "+U_TipoEntrega((_cAliasPed)->C5_I_AGEND)

		SC5->(DbSeek(xFilial("SC5")+(_cAliasPed)->C6_NUM))

		If !Empty(SC5->C5_LIBEROK) .Or. !Empty(SC5->C5_NOTA) .Or. !Empty(SC5->C5_BLQ) // .OR.  SC5->C5_I_OPTRI =="R" // SC5->C5_I_OPTRI $ "F,R" 
			//             Pedido                , Opera��o              , Erro                                                                           , Descri��o
			Aadd(_aMsgVld,{.F. ,  (_cAliasPed)->C6_NUM ,(_cAliasPed)->C5_I_OPER, "A SITUA��O OU TIPO DE PEDIDOS DE VENDAS SELECIONADO N�O PERMITE TRANSFER�NCIA.", "Favor selecionar um pedido de venda"+;
				" que esteja com o status verde (Em aberto) ou que n�o seja Pedido de Venda / Remessa da Opera��o Triangular , ou selecione o modo de transferencia de v�rios pedidos."})
			_lRet := .F.

		EndIf

		If !EMPTY(SC5->C5_I_PDFT) .OR. !EMPTY(SC5->C5_I_PDPR)
			//             Pedido                , Opera��o              , Erro                                                                                                            , Descri��o
			Aadd(_aMsgVld,{.F. , (_cAliasPed)->C6_NUM ,(_cAliasPed)->C5_I_OPER, "ESTE PEDIDO DE TROCA NOTA N�O PODE SER TRANSFERIDO, POIS J� FORAM GERADOS PEDIDOS DE CARREGAMENTO / FATURAMENTO.",;
				"Favor selecionar um pedido de venda que esteja com o status verde (Em aberto) e que n�o seja um pedido de TROCA NOTA que tenha Pedidos Gerados."})
			_lRet := .F.
		EndIf

		If !EMPTY(SC5->C5_I_PEVIN)  .And. ! SC5->C5_I_PEVIN $ _cNumPed
			//             Pedido                , Opera��o              , Erro                                                                  , Descri��o
			Aadd(_aMsgVld,{.F. , (_cAliasPed)->C6_NUM ,(_cAliasPed)->C5_I_OPER, "ESTE PEDIDO DE VENDAS POSSUI UM PEDIDO VINCULADO: " + SC5->C5_I_PEVIN , "Para transferir esse pedido selecione o Pedido Atual e o Pedido Vinculado para transferir os dois juntos."})
			_lRet := .F.
		EndIf

		//===============================================================
		// Demais Valida��es sobre o Pedido de Vendas Capa e Itens.
		//===============================================================
		aheader := {}
		acols := {}
		aadd(aheader,{1,"C6_ITEM"})
		aadd(aheader,{2,"C6_PRODUTO"})
		aadd(aheader,{3,"C6_LOCAL"})

		SC6->(Dbsetorder(1))
		SC6->(Dbseek(xfilial("SC5")+(_cAliasPed)->C6_NUM))

		Do while SC6->(!EOF()) .AND. xfilial("SC5") == SC6->C6_FILIAL .AND. (_cAliasPed)->C6_NUM == SC6->C6_NUM
			aadd(acols,{SC6->C6_ITEM,SC6->C6_PRODUTO,SC6->C6_LOCAL})
			SC6->(Dbskip())
		Enddo

		(_cAliasPed)->( DBSkip() )

	EndDo

//================================================================================
// Finaliza a area criada para selecao dos dados dos pedidos de venda
//================================================================================
	(_cAliasPed)->( DBCloseArea() )

//================================================================================
// Foram encontrados pedidos de venda com problema na regra de TES INTELIGENTE.
//================================================================================
	If LEN(_aLog) > 0 .And. _lExibeTela

		_lRet := 	U_ITListBox( 'Lista de Pedidos com problemas de condi��o de pagamento',;
			{'','Filial','Pedido','Opera��o','Cliente','Tipo entrega','Data de entrega do pedido','Data de entrega m�nima, SER� APLICADA AOS PEDIDOS NA TRANSFER�NCIA COM TIPO DE ENTREGA IMEDIATA!'} , _aLog , .T. , 1 ,;
			"Abaixo segue a rela��o de pedidos que se encontram com divergencia: " )

		_lret := .F.

	EndIf

	RestOrd(_aOrd)
	SC5->(DbGoTo(_nRecnoSC5))

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AOMS032Q
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 13/04/2010
===============================================================================================================================
Descri��o---------: Funcao utilizada para realizar as consultas no banco de dados deste fonte.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function AOMS032Q( _nOpcao , _cAlias , _cNumPed , _cTpOper , _cProdut , _cSufram , _cFilDest , _cEstCli , _cEstFil )

	Local _cFiltro	:= "%"
	Local _cSelect	:= "%"
	Local _cTipTES	:= ""

	Do Case

		//====================================================================================================
		// Query para selecionar os dados para verificacao dos pedidos de venda que foram selecionados para
		// transferencia para constatar se os mesmos possuem regra de TES INTELIGENTE cadastrada na filial de
		// destino.
		//====================================================================================================
	Case _nOpcao == 1

		_cFiltro += " AND C5.C5_FILIAL	= '"+ xFilial("SC5") +"' "
		_cFiltro += " AND C6.C6_FILIAL	= '"+ xFilial("SC6") +"' "
		_cFiltro += " AND C6.C6_NUM		IN ("+ SubStr( _cNumPed , 1 , Len(_cNumPed) - 1 ) +") "
		_cFiltro += " %"

		BeginSql alias _cAlias
		
			SELECT	A1.A1_COD,A1.A1_LOJA,A1.A1_EST,A1.A1_SUFRAMA,C6.C6_NUM,C6.C6_PRODUTO,C5.C5_I_OPER, C6.C6_LOCAL,C5_I_DTENT,C5_I_AGEND
			FROM	%table:SC5% C5
			JOIN	%table:SC6% C6 ON C5.C5_FILIAL = C6.C6_FILIAL	AND C5.C5_NUM  = C6.C6_NUM
			JOIN	%table:SA1% A1 ON A1.A1_COD    = C5.C5_CLIENTE	AND A1.A1_LOJA = C5.C5_LOJACLI
			WHERE	C5.D_E_L_E_T_ = ' ' AND C6.D_E_L_E_T_ = ' ' AND A1.D_E_L_E_T_ = ' ' AND C5.C5_TIPO = 'N' %exp:_cFiltro%
			
		EndSql

		//====================================================================================================
		// Seleciona os registros que se enquadram nos primeiros requisitos de avaliacao para checagem da TES
		// Inteligente.
		//====================================================================================================
	Case _nOpcao == 2

		//====================================================================================================
		// Venda para dentro do estado, seleciona a TES interna.
		//====================================================================================================
		If _cEstCli == _cEstFil

			_cSelect += " ZZP_TSIN "
			_cTipTES := " ZZP_TSIN "

			//====================================================================================================
			// Venda para fora do estado, seleciona TES Externa.
			//====================================================================================================
		Else

			_cSelect += " ZZP_TSOUT "
			_cTipTES := " ZZP_TSOUT "

		EndIf

		_cSelect += " %"

		_cFiltro += " AND ZZP_FILIAL = '"+ _cFilDest	+"' "
		_cFiltro += " AND ZZP_TIPO   = '"+ _cTpOper		+"' "
		_cFiltro += " AND ZZP_PRODUT = '"+ _cProdut		+"' "
		_cFiltro += " AND ZZP_CLIZN  = '"+ _cSufram		+"' "
		_cFiltro += " AND ZZP_ESTADO IN ( '"+ _cEstCli	+"' , '  ' ) "	// FILTRA SOMENTE O ESTADO DO CLIENTE OU O ESTADO COMO VAZIO POIS PODE NAO HAVER UMA REGRA PARA O ESTADO DO CLIENTE CADASTRADA NA TES INTELIGENTE, OU PODE SER UMA VENDA INTERNA PARA O MESMO ESTADO
		_cFiltro += " AND "+ _cTipTES +" <> '   ' "						// TIPO DA TES DIFERENTE DE VAZIO, OU SEJA, TEM QUE TER SIDO FORNECIDA UMA TES NO CADASTRO DE TES INTELIGENTE
		_cFiltro += " %"

		BeginSql alias _cAlias
		
			SELECT		ZZP_CLIENT , ZZP_LOJA , ZZP_ESTADO , %Exp:_cSelect% TES
			FROM		%table:ZZP%
			WHERE		D_E_L_E_T_ = ' ' %Exp:_cFiltro%
			ORDER BY	ZZP_ESTADO DESC
			
		EndSql

		//====================================================================================================
		// Query para selecionar os dados do cabecalho do pedido de venda do PALLET para exclusao.
		//====================================================================================================
	Case _nOpcao == 3

		//====================================================================================================
		// Filtro para selecao dos dados do pedido de venda
		//====================================================================================================
		_cFiltro += " AND C5_FILIAL = '"+ xFilial("SC5") +"' AND C5_NUM = '"+ _cNumPed +"' "
		_cFiltro += " %"

		//====================================================================================================
		// Query para selecao dos dados do cabecalho do pedido de venda
		//====================================================================================================
		BeginSql alias _cAlias
		 
		   	SELECT	C5_CLIENTE	, C5_LOJACLI	, C5_CLIENT		, C5_LOJAENT	, C5_TIPOCLI	, C5_CONDPAG	, C5_TIPO	,
					C5_VEND1	, C5_EMISSAO	, C5_TPFRETE	, C5_VOLUME1	, C5_ESPECI1	, C5_NUM		, C5_FILIAL	, C5_TPCARGA
			FROM	%table:SC5% C5
			WHERE	D_E_L_E_T_ = ' ' %exp:_cFiltro%
			
		EndSql

		//====================================================================================================
		// Query para selecionar os itens do pedido de venda do pedido de PALLET a ser excluido.
		//====================================================================================================
	Case _nOpcao == 4

		//====================================================================================================
		// Filtro para selecao dos dados do pedido de venda
		//====================================================================================================
		_cFiltro   += " AND C6_FILIAL = '"+ xFilial("SC6") +"' AND C6_NUM  = '"+ _cNumPed +"' "
		_cFiltro   += " %"

		//====================================================================================================
		// Query para selecao dos itens do pedido de venda
		//====================================================================================================
		BeginSql alias _cAlias
		
		   	SELECT	C6_ITEM		, C6_PRODUTO	, C6_QTDVEN	, C6_PRCVEN	, C6_LOCAL	, C6_UM		,
					C6_VALOR	, C6_TES		, C6_PEDCLI	, C6_QTDLIB	, C6_ENTREG	, C6_FILIAL	,
					C6_CF		, C6_PRUNIT		, C6_UNSVEN	, C6_NUM
			FROM	%table:SC6% C6
			WHERE	D_E_L_E_T_ = ' ' %exp:_cFiltro%
			
		EndSql

	EndCase

Return()

/*
===============================================================================================================================
Programa----------: AOMS032TES
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 13/04/2010
===============================================================================================================================
Descri��o---------: Funcao utilizada para validar se existe regra de TES INTELIGENTE para todos os pedidos selecionados pelo
------------------: usuario para a filial de destino da transferencia.
===============================================================================================================================
Parametros--------: _cFilDest   - Filial de Destino
					oproc - objeto da barra de processamento
					_lExibeTela = .T. = Exibe tela e mensagens de confirma��o.
					              .F. = Apenas valida e n�o exibe tela e mensagens de confirma��o.
===============================================================================================================================
Retorno-----------: _lRet - .T. - Nao encontrou problema nos pedidos de venda com relacao a TES INTELIGENTE.
===============================================================================================================================
*/

Static Function AOMS032TES( _cFilDest, oproc, _lExibeTela)
	Local _aArea		:= NIL
	Local _cNumPed		:= ""
	Local _cSuframa		:= ""
	Local _cEstFil		:= ""
	Local _lRet			:= .T.
	Local _cAliasPed	:= ""
	Local _lTES			:= .T.
	Local _cPedFats     := ""
	Local _nContaPV     := 0
	Local aPSeleionados := {}
	Local aPVinculados  := {},P
	Local cPVinculados  := ""
	Local cFaltaPVincula:= ""
	Local _cNomeCli, _cTipoEntrega:=""
	Local _cOperAlt      := ""
	//Local _cItapetininga := U_ITGETMV( "IT_OPERITA","25")

	Default _lExibeTela := .T.

	Begin Sequence
		//================================================================================
		// Verifica todos os pedidos de venda que foram selecionados para a transferencia
		//================================================================================
		DbSelectArea("TRBT")

		oproc:cCaption := ( "Processando itens de pedidos na fase 1/3, aguarde....")
		ProcessMessages()

		TRBT->( DBGoTop() )

		_nnl := 0

		Do while TRBT->(!Eof())

			_nnl++
			TRBT->(Dbskip())

		Enddo

		TRBT->( DBGoTop() )
		_nni := 0

		//================================================================================
		// Armazena todos os pedidos selecionados pelo usuario
		//================================================================================
		DO While TRBT->(!EOF())

			//================================================================================
			// Somente pedidos selecionados pelo usuario
			//================================================================================
			_nni++
			oproc:cCaption := ( "Processando itens de  pedidos na fase 2/3, item " + strzero(_nni,4) + " de " + strzero(_nnl,4) + "....")
			ProcessMessages()

			If IsMark( "TRBT_OK" , cMarkado ) //.or. (isincallstack("U_AOMS109") .AND. !EMPTY(TRBT->TRBT_OK) ) // DA TELA DE CENTRAL DE PVS // Chamado 44388 - Remover rotina do fonte AOMS109.
				_cNumPed += "'"+ TRBT->TRBT_NUM +"',"
				_nContaPV++

				AADD(aPSeleionados,TRBT->TRBT_NUM)
				IF !EMPTY(TRBT->C5_I_PEVIN) // PV Vinculado
					AADD(aPVinculados,{TRBT->TRBT_NUM,TRBT->C5_I_PEVIN,TRBT->C5_I_OPER})
				ENDIF
			EndIf

			TRBT->( DBSkip() )

		EndDo

		IF _nContaPV > 100
			If _lExibeTela
				U_ITmsg("Foram selecionados "+ALLTRIM(STR(_nContaPV))+". O limite maximo de sele��o de pedidos � 100.",;
					"Aten��o!",;
					"Selecione apenas ate 100 pedidos",1)
			Else
				//             Pedido , Opera��o, Erro                                    , Descri��o
				Aadd(_aMsgVld,{.F. , "  "   , ""      , "EXCEDEU NUMERO DE PEDIDOS SELECIONADOS","Foram selecionados "+ALLTRIM(STR(_nContaPV))+". O limite maximo de sele��o de pedidos � 100."})
			EndIf

			_lRet := .F.

			Break
		ENDIF

		IF !EMPTY(_cPedFats)

			_cPedFats := LEFT( _cPedFats, Len(_cPedFats)-1 )

			If _lExibeTela
				U_ITmsg("O(s) seguinte(s) Pedido(s) de TROCA NOTA estao com a filial de Faturamento igual a Filial selecionada: "+_cFilDest+_ENTER+_cPedFats,;
					"Aten��o!",;
					"Favor desmarcar esse(s) pedido(s) ou altere o campo Troca Nota dele(s) para 'N�o' ou altere a filial de faturamento dele(s) para diferente de: "+_cFilDest,1)
			EndIf

			//                    Pedido , Opera��o, Erro                                                 , Descri��o
			Aadd(_aMsgVld,{.F. ,  "  "   , ""      , "TROCA NOTA-FILIAL DE DESTINO IGUAL FILIAL DE ORIGEM","O(s) seguinte(s) Pedido(s) de TROCA NOTA estao com a filial de Faturamento igual a Filial selecionada: "+_cFilDest+" - "+_cPedFats})

			_lRet := .F.

			Break
		ENDIF

		IF !EMPTY(aPVinculados)

			FOR P := 1 TO LEN(aPVinculados)
				IF ASCAN(aPSeleionados, aPVinculados[P,2]) = 0
					cFaltaPVincula+=" PV "+aPVinculados[P,1]+" selecionado sem o PV Vinculado "+aPVinculados[P,2]+_ENTER
					cPVinculados+=aPVinculados[P,2] +", "

               Aadd(_aMsgVld,{.F. ,aPVinculados[P,1], aPVinculados[P,3], " PV "+aPVinculados[P,1]+" selecionado sem o PV Vinculado "+aPVinculados[P,2], " Retire o vinculo em altera��o de Pedido ou selecione o PV vinculado "+aPVinculados[P,2] +" faltante para transferir juntamente."})

				ENDIF
			NEXT

			IF !EMPTY(cFaltaPVincula)
				cPVinculados:="[ "+LEFT(cPVinculados,LEN(cPVinculados)-2)+" ]"

				If _lExibeTela
					U_ITMSG(cFaltaPVincula,"Aten��o","Retire o vinculo em altera��o de Pedido ou selecione os PV vinculados "+cPVinculados+" faltantes para transferir juntamente.",1)
				EndIf

				//                  Pedido , Opera��o, Erro                                    , Descri��o
				//Aadd(_aMsgVld,{.F. ,"  "   , ""      , "PV VINCULADO TRANSFERIDO SEPARADAMENTE", cFaltaPVincula +" Retire o vinculo em altera��o de Pedido ou selecione os PV vinculados "+cPVinculados+" faltantes para transferir juntamente."})

				_lRet := .F.

				Break
			ENDIF

		ENDIF

		//================================================================================
		// Query para selecionar os dados para verificacao dos pedidos de venda que foram
		// selecionados para transferencia para constatar se os mesmos possuem regra de
		// TES INTELIGENTE cadastrada na filial de destino.
		//================================================================================
		_cAliasPed := GetNextAlias()

		AOMS032Q( 1 , _cAliasPed , _cNumPed , "" , "" , "" , "" )

		DBSelectArea( _cAliasPed )
		(_cAliasPed)->( DBGotop() )
		COUNT TO _nNumReg

		ProcRegua( _nNumReg )

		DBSelectArea( _cAliasPed )
		(_cAliasPed)->( DBGotop() )

		_aLog:={}
		SA1->(dbSetOrder(1))

		_nnl := 0
		Do while (_cAliasPed)->(!Eof())
			_nnl++
			(_cAliasPed)->(Dbskip())
		Enddo

		(_cAliasPed)->( DBGotop() )

		_nni := 0

		While (_cAliasPed)->( !Eof() )

			_nni++
			oproc:cCaption := ( "Processando itens de pedidos na fase 3/3, item " + strzero(_nni,4) + " de " + strzero(_nnl,4) + "....")
			ProcessMessages()


			//================================================================================
			// Verifica se o cliente corrente possui suframa.
			//================================================================================
			If !Empty( (_cAliasPed)->A1_SUFRAMA )
				_cSuframa := "S"
			Else
				_cSuframa := "N"
			EndIf

			//====================================================================================================
			// Verifica o Estado da Filial de destino
			//====================================================================================================
			_aArea := GetArea('SM0')

			DBSelectArea('SM0')
			SM0->( DBSetOrder(1) )
			If SM0->( DBSeek( '01' + SubStr(_cFilDest,1,2) ) )
				_cEstFil := SM0->M0_ESTCOB
			EndIf

			RestArea( _aArea )

			//====================================================================================================
			// Verifica a configura��o de TES Inteligente para a transfer�ncia atual
			//====================================================================================================
			_cfilg := cfilant
			cfilant := SubStr(_cFilDest,1,2)
			SM0->( DBSetOrder(1))
			SM0->( DBSeek( SubStr( cNumEmp , 1 , 2 ) + cFilAnt ) )
            
			_cCodLocaliz := _cLocal
			_cOperAlt    := _cOper25

			//Busca nova TES
			_cTes:= ""
 			_cTes := U_SELECTTES((_cAliasPed)->C6_PRODUTO ,_cSuframa, (_cAliasPed)->A1_EST, _cEstFil, (_cAliasPed)->A1_COD, (_cAliasPed)->A1_LOJA, _cOperAlt,_cCodLocaliz)
	  
			cfilant := _cfilg
			SM0->( DBSetOrder(1))
			SM0->( DBSeek( SubStr( cNumEmp , 1 , 2 ) + cFilAnt ) )

			_lTES := !Empty(_cTes)

			//================================================================================
			// Nao encontrou um regra de TES INTELIGENTE cadastrada desta forma sera
			// armazenado o numero do pedido de venda para posterior impressao ao usuario.
			//================================================================================
			If !_lTES
				SA1->(dbSeek( xFilial("SA1") + (_cAliasPed)->A1_COD+(_cAliasPed)->A1_LOJA ))
				_cSuframa:=IF(!EMPTY(SA1->A1_SUFRAMA),"S","N")
				_cCpoSN  :=IF(SA1->A1_SIMPNAC="1"    ,"S","N")
				_cCpoCI  :=IF(SA1->A1_CONTRIB="2"    ,"N","S")

				_cNomeCli := Posicione("SA1",1,xFilial("SA1")+(_cAliasPed)->A1_COD + (_cAliasPed)->A1_LOJA ,"A1_NREDUZ")

                _cTipoEntrega:=(_cAliasPed)->C5_I_AGEND+" - "+U_TipoEntrega((_cAliasPed)->C5_I_AGEND)

				aAdd( _aLog , {.F. , (_cAliasPed)->C6_NUM ,_cOperAlt ,(_cAliasPed)->A1_COD+" "+(_cAliasPed)->A1_LOJA+" - "+SA1->A1_NREDUZ,_cEstFil+" => "+(_cAliasPed)->A1_EST ,_cSuframa+" / "+_cCpoSN+" / "+_cCpoCI, (_cAliasPed)->C6_LOCAL,Alltrim((_cAliasPed)->C6_PRODUTO)+" - "+Posicione("SB1",1,Xfilial("SB1")+(_cAliasPed)->C6_PRODUTO,"B1_DESC") })

				//             Pedido              , Opera��o              , Erro                                    , Descri��o
				Aadd(_aMsgVld,{.F. ,  (_cAliasPed)->C6_NUM,_cOperAlt, "PRODUTOS SEM TES INTELIGENTE VINCULADA","Cliente: " + (_cAliasPed)->A1_COD + " - Loja: " + (_cAliasPed)->A1_LOJA + " - Nome: " + ALLTRIM(_cNomeCli)+" - Tipo de Entrega: " + _cTipoEntrega })
				_lRet := .F.
			EndIf

			(_cAliasPed)->( DBSkip() )

		EndDo

		//================================================================================
		// Finaliza a area criada para selecao dos dados dos pedidos de venda
		//================================================================================
		(_cAliasPed)->( DBCloseArea() )

		//================================================================================
		// Foram encontrados pedidos de venda com problema na regra de TES INTELIGENTE.
		//================================================================================
		If LEN(_aLog) > 0 .And. _lExibeTela

			_lRet := .F.

		EndIf

	End Sequence

Return( _lRet )

/*
===============================================================================================================================
Programa----------: AOMS032B
Autor-------------: Julio de Paula Paz
Data da Criacao---: 11/04/2019
===============================================================================================================================
Descri��o---------: Rotina de Transfer�ncia de Pedidos de Vendas para registro posicionado na tabela SC5.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS032B()

	Local _cAlias 	  := "SC5"
	Local _nReg 	  := SC5->(RECNO())
	Local _nOpc		  := 6
	Local _aPosObj    := {}
	Local _aObjects   := {}
	Local _aSize      := {}
	Local _aPosGet    := {}
	Local _aCpos1     := {}
	Local _aCpos2     := {}
	Local _aInfo      := {}
	Local _lQuery     := .F.
	Local _lFreeze    := (SuperGetMv("MV_PEDFREZ",.F.,0) <> 0)
	Local _nOpcA      := 0
	Local _nLinGet    := 0
	Local _nColFreeze := SuperGetMv("MV_PEDFREZ",.F.,0)
	Local _cQuery     := ""
	Local _oDlg
	Local _oSay1
	Local _oSay2
	Local _oSay3
	Local _oSay4


	Local _bCond     := {|| .T. }
	Local _bAction1  := {|| .T. }
	Local _bAction2  := {|| .T. }
	Local _cSeek     := ""
	Local _aNoFields := {"C6_NUM","C6_QTDEMP","C6_QTDENT"}		// Campos que nao devem entrar no aHeader e aCols
	Local _bWhile    := {|| }
	Local _nNumDec   := TamSX3("C6_VALOR")[2]
	//Local _aTrocaNf	:= {"Sim","N�o"}
	Private _oGetD
	
	
	Private aTELA[0][0]
	Private aGETS[0]

	//Valida bloqueio logistico
	//Verifica permiss�o de ajuste de bloqueio log�stico
	If SC5->C5_I_BLOG == "S"

		ZZL->(Dbsetorder(3))
		If !(ZZL->(Dbseek(xFilial("ZZL") + RetCodUsr()))) .OR. ZZL->ZZL_PVLOG != "S"

			u_itmsg("Usu�rio sem permiss�o para Transferir Pedido em Planejamento Log�stico. Por favor entrar em contato com �rea de Log�stica","Aten��o",,1)

			Return

		Endif

	Endif

//=============================================================================
// Inicializa desta forma para criar uma nova instancia de variaveis private 
//=============================================================================
	RegToMemory( "SC5", .F., .F. )

//=============================================================================
//Montagem do aCols                                                          
//=============================================================================
	_lQuery  := .T.
	_cQuery := "SELECT SC6.*,SC6.R_E_C_N_O_ SC6RECNO "
	_cQuery += "FROM "+RetSqlName("SC6")+" SC6 "
	_cQuery += "WHERE SC6.C6_FILIAL='"+xFilial("SC6")+"' AND "
	_cQuery += "SC6.C6_NUM='"+SC5->C5_NUM+"' AND "
	_cQuery += "SC6.D_E_L_E_T_ = ' ' "
	_cQuery += "ORDER BY "+SqlOrder(SC6->(IndexKey()))

	_cSeek  := xFilial("SC6")+SC5->C5_NUM
	_bWhile := {|| C6_FILIAL+C6_NUM }

//=========================================================
// Montagem do aHeader e aCols                           
//=========================================================

//==============================================================================================================
//FillGetDados( _nOpcx, _cAlias, nOrder, cSeekKey, bSeekWhile, uSeekFor, _aNoFields, aYesFields, lOnlyYes,       
//				  _cQuery, bMountFile, lInclui )                                                                
//_nOpcx			- Opcao (inclusao, exclusao, etc).                                                         
//_cAlias		- Alias da tabela referente aos itens                                                          
//nOrder		- Ordem do SINDEX                                                                              
//cSeekKey		- Chave de pesquisa                                                                            
//bSeekWhile	- Loop na tabela _cAlias                                                                        
//uSeekFor		- Valida cada registro da tabela _cAlias (retornar .T. para considerar e .F. para desconsiderar 
//				  o registro)                                                                                  
//_aNoFields	- Array com nome dos campos que serao excluidos na montagem do aHeader                         
//aYesFields	- Array com nome dos campos que serao incluidos na montagem do aHeader                         
//lOnlyYes		- Flag indicando se considera somente os campos declarados no aYesFields + campos do usuario   
//_cQuery		- Query para filtro da tabela _cAlias (se for TOP e _cQuery estiver preenchido, desconsidera     
//	           parametros cSeekKey e bSeekWhiele)                                                              
//bMountFile	- Preenchimento do aCols pelo usuario (aHeader e aCols ja estarao criados)                     
//lInclui		- Se inclusao passar .T. para qua aCols seja incializada com 1 linha em branco                 
//aHeaderAux	-                                                                                              
//aColsAux		-                                                                                              
//bAfterCols	- Bloco executado apos inclusao de cada linha no aCols                                         
//bBeforeCols	- Bloco executado antes da inclusao de cada linha no aCols                                     
//bAfterHeader -                                                                                              
//_cAliasQry	- Alias para a Query                                                                           
//==============================================================================================================
	FillGetDados(4,"SC6",1,_cSeek,_bWhile,{{_bCond,_bAction1,_bAction2}},_aNoFields,/*aYesFields*/,/*lOnlyYes*/,_cQuery,/*bMontCols*/,Inclui,/*aHeaderAux*/,/*aColsAux*/,,/*bBeforeCols*/,/*bAfterHeader*/,"SC6")

//=============================================================================
//Calculo das dimensoes da Janela                                            
//=============================================================================
	_aSize    := MsAdvSize()
	_aObjects := {}
	AAdd( _aObjects, { 100, 100, .T., .T. } )
	AAdd( _aObjects, { 100, 100, .T., .T. } )
	AAdd( _aObjects, { 100, 015, .T., .F. } )

	_aInfo   := { _aSize[ 1 ],_aSize[ 2 ],_aSize[ 3 ],_aSize[ 4 ],03,03 }
	_aPosObj := MsObjSize( _aInfo, _aObjects )
	_aPosGet := MsObjGetPos(_aSize[3]-_aSize[1],315,{{003,157,189,236,268}})

	_aPosObj[1,1] := _aPosObj[1,1] + 15

    _cOper25 := SC5->C5_I_OPER // Sugerir a Opera��o j� informada no pedido de vendas. Chamado 44388.
	
	DEFINE MSDIALOG _oDlg TITLE cCadastro From _aSize[7],0 to _aSize[6],_aSize[5] of oMainWnd PIXEL

	_nLinGet :=  _aPosObj[1,1] - 14
	@ _nLinGet,10  Say   "Filial de Destino: " Size 60,09  OF _oDlg PIXEL
	@ _nLinGet,60  MsGet _cFilDestino Size 40,09 F3 "F3ITLC" Valid(U_AOMS032Y("FILIAL_DESTINO", _cFilDestino,"P")) OF _oDlg PIXEL

    If SC5->C5_I_TRCNF == "N"
       _cTrocaNf := _aTrocaNf[2]
	Else
	   _cTrocaNf := _aTrocaNf[1] 
	EndIf 

	@ _nLinGet,110  Say   "Troca Nota: " Size 60,09  OF _oDlg PIXEL 
	@ _nLinGet,150 ComboBox	_oTrocaNf VAR _cTrocaNf	Valid(U_AOMS032Y("TROCA_NOTA", _cTrocaNf,"P")) Items _aTrocaNf Size 30, 10 OF _oDlg PIXEL 

	@ _nLinGet,190  Say   "Filial de Faturamento: " Size 60,09  OF _oDlg PIXEL 
	@ _nLinGet,250  MsGet _oFilFatur Var _cFilFatur Size 40,09 F3 "LSTCAR" Valid (Vazio() .Or. (ExistCpo("ZZM",_cFilFatur) .And. U_AOMS032Y("FILIAL_FATURAMENTO", _cFilFatur,"P")))  OF _oDlg PIXEL 
    
	If SC5->C5_I_TRCNF == "N"
       _cTrocaNf := _aTrocaNf[2]
	   _cFilFatur := Space(2)
	   _oTrocaNf:Disable()
	   _oFilFatur:Disable()	   
	Else
	   _cTrocaNf := _aTrocaNf[1]
	   _oTrocaNf:Enable()
	   _oFilFatur:Enable()
	EndIf

	@ _nLinGet,300 Say  "Opera��o: " Size 60,09  OF _oDlg PIXEL 
	@ _nLinGet,330 MsGet _oOper25 Var _cOper25 Picture "@!" F3 "ZB4" Valid(U_AOMS032Y("OPERACAO", _cOper25,"P")) Size 30, 10 OF _oDlg PIXEL  // ExistCpo("ZB4",_cOper25) 
	
	If _cOper25 $ _cOperTran  // U_ITGETMV( "IT_OPTRANF","42")
	   _oOper25:Disable()
	Else
	   _oOper25:Enable()	
	EndIf 

    @ _nLinGet,370 Say  "Local/Armaz�m: " Size 60,09  OF _oDlg PIXEL 
	@ _nLinGet,420 MsGet _oLocal Var _cLocal  Picture "@!" F3 "NNR"	Valid(U_AOMS032Y("LOCAL", _cLocal,"P")) Size 30, 10 OF _oDlg PIXEL  // ExistCpo("NNR",_cLocal) 
    _oLocal:Disable()

	EnChoice( _cAlias, _nReg, _nOpc,     ,        ,      ,     , _aPosObj[1], _aCpos1, 3 )

	_oGetD   :=  MsGetDados():New(_aPosObj[2,1],_aPosObj[2,2],_aPosObj[2,3],_aPosObj[2,4],_nOpc,,,"",,_aCpos2,_nColFreeze,,,,,,,,_lFreeze)

	_nLinGet := _aPosObj[3,1]

	@ _nLinGet,_aPosGet[1,1] SAY _oSay1 VAR Space(40)               	SIZE 120,09 PICTURE "@!"	OF _oDlg PIXEL
	@ _nLinGet,_aPosGet[1,2] SAY "Total :"                         	SIZE 020,09 OF _oDlg	PIXEL
	@ _nLinGet,_aPosGet[1,3] SAY _oSay2 VAR 0 PICTURE TM(0,16,_nNumDec) SIZE 040,09 OF _oDlg PIXEL
	@ _nLinGet,_aPosGet[1,4] SAY "Desc./Acres.:"                         	SIZE 020,09 OF _oDlg PIXEL
	@ _nLinGet,_aPosGet[1,5] SAY _oSay3 VAR 0 PICTURE TM(0,16,_nNumDec) SIZE 040,09 OF _oDlg PIXEL
	@ _nLinGet + 10,_aPosGet[1,4] SAY OemToAnsi("=")               	SIZE 020,09 OF _oDlg PIXEL
	@ _nLinGet + 10,_aPosGet[1,5] SAY _oSay4 VAR 0                  	SIZE 040,09 PICTURE TM(0,16,_nNumDec) OF _oDlg PIXEL
	_oDlg:Cargo	:= {|c1,n2,n3,n4|  _oSay1:SetText(c1),;
		_oSay2:SetText(n2),;
		_oSay3:SetText(n3),;
		_oSay4:SetText(n4) }
	Ma410Rodap(_oGetD) 
 
    _oTrocaNf:Refresh()
    _oFilFatur:Refresh()
    _oOper25:Refresh()
    _oLocal:Refresh()

	ACTIVATE MSDIALOG _oDlg ON INIT EnchoiceBar(_oDlg,{||_nOpca:=1,if(U_AOMS032C(_cFilDestino),_oDlg:End(),_nOpca := 0)},{||(_nOpca := 0,_oDlg:End())})

	If _nOpca == 1  
		_cFilTran := _cFilDestino
		_lRet := .T. 
	Else
		_lRet := .F.
	EndIf

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS032C
Autor-------------: Julio de Paula Paz
Data da Criacao---: 11/04/2019
===============================================================================================================================
Descri��o---------: Valida se a filial foi preenchida quando a transfer�ncia de pedidos for para pedidos de vendas 
                    posicionado.
===============================================================================================================================
Parametros--------: _cFilialValidar = Codigo da filial a ser validado.
===============================================================================================================================
Retorno-----------: _lRet = .T. = Valida��o Ok.
                          = .F, = Falha na valida��o.
===============================================================================================================================
*/
User Function AOMS032C(_cFilialValidar)
	Local _lRet := .T.

	Begin Sequence
		If Empty(_cFilialValidar)
			U_ITmsg("N�o foi informado nenhuma filial de destino para transfere�ncia de pedidos de vendas.","Atenc�ao",;
				"Para transfer�ncia de pedidos de vendas � obrigat�rio informar a filial de destino." ,1)
			_lRet := .F.
			Break
		EndIf

		ZZM->(DbSetOrder(1)) // ZZM_FILIAL+ZZM_CODIGO
		If ! ZZM->(DbSeek(xFilial("ZZM") + U_ITKEY(_cFilialValidar, "ZZM_CODIGO")))
			U_ITmsg("O c�digo de filial de destino que foi informado n�o existe.","Aten��o!","Informe um c�digo de filial v�lido.",1)
			_lRet := .F.
			Break
		EndIf

		If AllTrim(_cFilialValidar) == xFilial("SC5")
			U_ITmsg("Para transfer�ncia de pedidos a filial de destino n�o pode ser igual a filial de origem.","Atenc�ao",;
				"Informe uma filial de destino diferente da filial de origem." ,1)
			_lRet := .F.
			Break
		EndIf

	End Sequence

Return _lRet


/*
===============================================================================================================================
Programa----------: AOMS032R
Autor-------------: Julio de Paula Paz
Data da Criacao---: 01/11/2021
===============================================================================================================================
Descri��o---------: Adiciona os pedidos de remessa vinculados aos pedidos, a tabela tempor�ria.
===============================================================================================================================
Parametros--------: _cFilPVRem = Filial Pedido Remessa.
                    _cNumPVRem = Numero Pedido de Remessa.
===============================================================================================================================
Retorno-----------: _lRet == .T. = Erro Execauto ou Erro desbloqueio RDC.
                          == .F. Nenhum erro ocorreu, execauto e desbloqueio RDC.
===============================================================================================================================
*/
User Function AOMS032R(_cFilPVRem,_cNumPVRem,oproc)
Local _lRet := .F.
Local _cFiltroC5 := "%", _cFiltroC6 := "%"
Local _lOKRDC
Local _aCabPVRem, _aDetPVRem
//Local _lWsTms := U_ITGETMV( 'IT_WEBSTMS' , .F.) // Indica se rotina de integra��o WebService � TMS Multi-Embarcador ou RDC.

Begin Sequence
   //================================================================================
   // Query de sele��o do pedido de vendas de remessa.
   //================================================================================
   _cFiltroC5 += " AND C5_FILIAL = '"+ _cFilPVRem +"' "
   _cFiltroC5 += " AND C5_NUM  = '" + _cNumPVRem + "' "
   _cFiltroC5 += "%"
	
   BeginSql alias "QRYSC5R"
		
	  SELECT  SC5.R_E_C_N_O_ NRRECNO
	  FROM	%table:SC5% SC5
	  WHERE	SC5.D_E_L_E_T_ = ' ' %exp:_cFiltroC5%
	
   EndSql

   QRYSC5R->( DBGoTop() )
   If QRYSC5R->NRRECNO == 0 
      _lRet := .T.
	  Break
   EndIf 

   SC5->(DBGoTo(QRYSC5R->NRRECNO))
   
   _cCodVend1 := SC5->C5_VEND1
   _cCodVend2 := SC5->C5_VEND2
   _cCodVend3 := SC5->C5_VEND3
   _cCodVend4 := SC5->C5_VEND4
   _cCodVend5 := SC5->C5_VEND5
   _cNomVend1 := SC5->C5_I_V1NOM
   _cNomVend2 := SC5->C5_I_V2NOM
   _cNomVend3 := SC5->C5_I_V3NOM

   SC5->(RecLock("SC5"),.F.)
   
   _aCabPVRem := {		{ "C5_FILIAL"  , SC5->C5_FILIAL   	        ,Nil},;
						{ "C5_NUM"     , SC5->C5_NUM            	,Nil},;
						{ "C5_TIPO"    , SC5->C5_TIPO    			,Nil},;
						{ "C5_CLIENTE" , SC5->C5_CLIENTE 			,Nil},;
						{ "C5_LOJACLI" , SC5->C5_LOJACLI 			,Nil},;
						{ "C5_CLIENT " , SC5->C5_CLIENT  			,Nil},; // Codigo do cliente
						{ "C5_LOJAENT" , SC5->C5_LOJAENT 			,Nil},; // Loja para entrada
						{ "C5_TIPOCLI" , SC5->C5_TIPOCLI 			,Nil},;
						{ "C5_CONDPAG" , SC5->C5_CONDPAG 			,Nil},;
						{ "C5_VEND1"   , SC5->C5_VEND1   			,Nil},;
						{ "C5_EMISSAO" , SC5->C5_EMISSAO        	,Nil},;
						{ "C5_TPFRETE" , SC5->C5_TPFRETE 			,Nil},;
						{ "C5_VOLUME1" , SC5->C5_VOLUME1 			,Nil},;
						{ "C5_ESPECI1" , SC5->C5_ESPECI1 			,Nil},;
						{ "C5_TPCARGA" , SC5->C5_TPCARGA 			,Nil},;
						{ "C5_I_AGEND" , SC5->C5_I_AGEND 			,Nil},;
						{ "C5_I_ENVRD" , "N"               			,Nil},;
						{ "C5_I_IDPED" , SC5->C5_I_IDPED			,Nil} }

   //================================================================================
   // Query de sele��o do pedido de vendas de remessa.
   //================================================================================
   _cFiltroC6 += " AND C6_FILIAL = '"+ _cFilPVRem +"' "
   _cFiltroC6 += " AND C6_NUM  = '" + _cNumPVRem + "' "
   _cFiltroC6 += "%"
	
   BeginSql alias "QRYSC6R"
		
	  SELECT C6_FILIAL,
			 C6_ITEM,
			 C6_PRODUTO,
			 C6_QTDVEN,
			 C6_UM,
			 C6_PRCVEN,
			 C6_VALOR,
			 C6_PEDCLI,
			 C6_QTDLIB,
			 C6_LOCAL,
			 C6_NUM
	  FROM	%table:SC6% SC6
	  WHERE	SC6.D_E_L_E_T_ = ' ' %exp:_cFiltroC6%
	
   EndSql

   _aDetPVRem := {}
   QRYSC6R->( DBGoTop() )

   Do While ! QRYSC6R->(Eof())
 
      aAdd( _aDetPVRem , {	{ "C6_FILIAL"  , QRYSC6R->C6_FILIAL	 ,Nil},;
							{ "C6_ITEM"    , QRYSC6R->C6_ITEM	 ,Nil},;
							{ "C6_PRODUTO" , QRYSC6R->C6_PRODUTO ,Nil},;
							{ "C6_QTDVEN"  , QRYSC6R->C6_QTDVEN	 ,Nil},;
							{ "C6_UM"      , QRYSC6R->C6_UM		 ,Nil},;
							{ "C6_PRCVEN"  , QRYSC6R->C6_PRCVEN	 ,Nil},;
							{ "C6_VALOR"   , QRYSC6R->C6_VALOR	 ,Nil},;
							{ "C6_PEDCLI"  , QRYSC6R->C6_PEDCLI	 ,Nil},;
							{ "C6_QTDLIB"  , QRYSC6R->C6_QTDLIB	 ,Nil},;
							{ "C6_LOCAL"   , QRYSC6R->C6_LOCAL	 ,Nil},;
							{ "C6_NUM"     , QRYSC6R->C6_NUM	 ,Nil}})
      QRYSC6R->(DbSkip())
   EndDo
   
   _lOKRDC := .T.
   If SC5->C5_I_ENVRD = "S"
      If !u_IT_TMS(SC5->C5_I_LOCEM) //! _lWsTms
	     FWMSGRUN( ,{|P| _lOKRDC:=U_AOMS094E(P,.F.)} , 'Aguarde!' , 'Enviando para o RDC o cancelamento do Pedido ' + SC5->C5_NUM  )
	  Else 
         FWMSGRUN( ,{|P| _lOKRDC:=U_AOMS140E(P,.T.)} , 'Aguarde!' , 'Enviando para o TMS Multi-Embarcador o cancelamento do Pedido ' + SC5->C5_NUM  )
	  EndIf 
   EndIf

   If _lOKRDC
	  oproc:cCaption := ("Excluindo pedido de remessa... " + SC5->C5_NUM )
      ProcessMessages()
      
	  lMsErroAuto	:= .F.
	  MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPVRem , _aDetPVRem , 5 )
   Else 
      
	  _lRet := .T.

   EndIf

   If lMsErroAuto
      _lRet := .T. 
   EndIf 

   SC5->( MSUnlock() )

   //================================================================================
   // Encerra tabela de muro do RDC do pedido excluido
   //================================================================================
   ZFQ->(Dbsetorder(3))
   ZFQ->(Dbgotop())

   If ZFQ->(MsSeek(_cFilPVRem + _cNumPVRem))

      Do While ZFQ->ZFQ_FILIAL == _cFilPVRem .AND. ZFQ->ZFQ_PEDIDO == _cNumPVRem
         If ZFQ->ZFQ_SITUAC == 'N'
			ZFQ->(Reclock("ZFQ",.F.))									
			ZFQ->ZFQ_SITUAC := 'P'
 		    ZFQ->(Msunlock())
		 EndIf

		 ZFQ->(DbSkip())

	  Enddo

   EndIf

   ZFR->(Dbsetorder(3))
   ZFR->(Dbgotop())

   If ZFR->(MsSeek(_cFilPVRem + _cNumPVRem))
      Do while ZFR->ZFR_FILIAL == _cFilPVRem .AND. ZFR->ZFR_NUMPED == _cNumPVRem

         If ZFR->ZFR_SITUAC == 'N'
			ZFR->(Reclock("ZFR",.F.))
            ZFR->(DbDelete())
            ZFR->(Msunlock())
         EndIf
		 
		 ZFR->(DbSkip())

      Enddo
   EndIf

End Sequence

If Select("QRYSC5R") <> 0
   QRYSC5R->( DBCloseArea() )
EndIf

If Select("QRYSC6R") <> 0
   QRYSC6R->( DBCloseArea() )
EndIf

Return _lRet 

/*
===============================================================================================================================
Programa----------: AOMS032Y
Autor-------------: Julio de Paula Paz
Data da Criacao---: 14/07/2022
===============================================================================================================================
Descri��o---------: Valida Preenchimento da Opera��o e do Armaz�m conforme regras estabelecidas.
===============================================================================================================================
Parametros--------: _cCampo    = Campo que chamou a valida��o.
                    _cValorDig = Conte�do digitado. 
					_cChamadaV = Chamada da Valida��o = P = Posicionado o Pedido de Vendas / L = Lotes de pedidos selecionados 
===============================================================================================================================
Retorno-----------: _lRet = .T. = Valida��o Ok.
                          = .F. = Falha na valida��o.
===============================================================================================================================
*/
User Function AOMS032Y(_cCampo, _cValorDig, _cChamadaV)
Local _lRet := .T.
Local _aFilial := {} 
Local _nI 
Local _cFilLogad := xFilial("SC5")

Default _cChamadaV := "P"

Begin Sequence 

   If _cCampo == "FILIAL_DESTINO"
      _aFilial := FwLoadSM0()

      If Empty(_cValorDig)
         U_ITmsg("A filial de destino n�o foi preenchida. O seu preenchimento � obrigat�rio.","Aten��o",,1)
	     _lRet := .F.
	     Break
      EndIf 

      _nI := Ascan(_aFilial,{|x| x[05] = U_ITKEY(_cValorDig, "C5_FILIAL")})
      If _nI == 0
         U_ITmsg("A filial de destino informada n�o existe.","Aten��o",,1)
	     _lRet := .F.
	     Break
      EndIf 

	  If _cFilLogad == _cValorDig
         U_ITmsg("A filial de destino n�o pode ser igual a filial de origem do pedido de vendas.","Aten��o",,1)
	     _lRet := .F.
	     Break
	  EndIf 

      If _cFilLogad $ _cFilOrigI // Grupo de filiais para aplica��o das regras
         If _cChamadaV == "P" // Chamada da fun��o, pedido de vendas posicionado.
	        If _cFilLogad == _cFilLogA // Filial logada igual a 90
               _oTrocaNf:Enable()
               _oFilFatur:Enable()
			   _oTrocaNf:Setfocus()
		    EndIf 

            If _cFilLogad == _cFilLogB // Filial logada igual a 93
               _oTrocaNf:Enable()
               _oFilFatur:Enable()
			   _oTrocaNf:Setfocus()
		    EndIf 
		 EndIf 
      Else  // Regras para as filiais diferentes de 90 e 93
         If _cValorDig $ _cFilOrigI  // Se destino for "90/93"
		    If _cChamadaV == "P" // Chamada da fun��o, pedido de vendas posicionado.
               If SC5->C5_I_TRCNF == "S" 
			      _oTrocaNf:Disable()
                  _oFilFatur:Disable()
			   Else 
			      _oTrocaNf:Enable()
                  _oFilFatur:Enable()
			      _oTrocaNf:Setfocus()
			   EndIf 
			EndIf

            If SC5->C5_I_TRCNF == "S" 
			   _cFilFatur := Space(2)
	           _cTrocaNf  := _aTrocaNf[2] // "Nao"
   		    Else 
			   _cFilFatur := Space(2)
	           _cTrocaNf  := _aTrocaNf[2] // "Nao"
			EndIf 
 
            If _cChamadaV == "P" // Chamada da fun��o, pedido de vendas posicionado.
               If _cFilDestino == _cFilLogA // Filial de destino igual a 90
                  _oLocal:Enable()
			   Else 
			      _oLocal:Disable()
               EndIf 
			EndIf 

			_cLocal := Space(2)
		 Else 
		    If _cChamadaV == "P" // Chamada da fun��o, pedido de vendas posicionado.
		       If SC5->C5_I_TRCNF == "S" // Upper(_cValorDig) == "SIM" .And.
			      _oTrocaNf:Disable()
                  _oFilFatur:Disable()
			   Else 
			      _oTrocaNf:Enable()
                  _oFilFatur:Enable()
			      _oTrocaNf:Setfocus()
			   EndIf 
			EndIf 

            If _cChamadaV == "P" // Chamada da fun��o, pedido de vendas posicionado.
               If _cFilDestino == _cFilLogA // Filial de destino igual a 90
                  _oLocal:Enable()
			   Else 
			      _oLocal:Disable()
               EndIf 
			EndIf 

            _cLocal := Space(2)

		 EndIf

	  EndIf 
   EndIf    
 
   If _cCampo == "TROCA_NOTA"
      If _cFilLogad $ _cFilOrigI // Grupo de filiais para aplica��o das regras

         If Upper(_cValorDig) == "SIM"
            If ! (_cFilFatur $ _cFilDeFat) .And. _cFilLogad == _cFilLogB // Filial logada igual a 93
			   _cFilFatur := _cFilDeFat
	           _lRet := .T.
	           Break
	        ElseIf _cFilLogad == _cFilLogA 
			   _cFilFatur := _cFilDeFat
	           _lRet := .T. 
	           Break
		    EndIf 
         Else 
	        _cFilFatur := Space(2)
			If _cChamadaV == "P" // Chamada da fun��o, pedido de vendas posicionado.
               _oFilFatur:Disable()
			EndIf 
	     EndIf 

       Else // Regras para as filiais diferentes de 90 e 93.

          If _cChamadaV == "P" // Chamada da fun��o, pedido de vendas posicionado.
             If SC5->C5_I_TRCNF == "N"
                _oTrocaNf:Enable()
                _oFilFatur:Enable()

                If _cFilDestino $ _cFilLogA // Filial de destino igual a 90
                   _oTrocaNf:Disable()
                   _oFilFatur:Disable()
			    Else 
			       _oFilFatur:Enable()
			    EndIf 	

				If _cFilDestino $ _cFilLogA // Filial de destino igual a 90
                   _cFilFatur := Space(2)
	               _cTrocaNf  := _aTrocaNf[2] // "Nao"
			    Else 
			       _cFilFatur := Space(2)
	            EndIf 		 
             EndIf
          EndIf 

		  If _cChamadaV <> "P" // "L" = Transfer�ncia em Lotes de v�rios Pedidos de Vendas.
             If _cFilDestino $ _cFilLogA // Filial de destino igual a 90
                _cFilFatur := Space(2)
	            _cTrocaNf  := _aTrocaNf[2] // "Nao"
			 Else 
			   _cFilFatur := Space(2)
	         EndIf 		 
         EndIf
	  EndIf	 
   EndIf 

   If _cCampo == "FILIAL_FATURAMENTO"
      If _cFilLogad $ _cFilOrigI // Grupo de filiais para aplica��o das regras // Filiais de origem 90/93.
         If ! (_cFilFatur $ _cFilDeFat) .And. _cFilLogad == _cFilLogB // Filial logada igual a 93
            U_ITmsg("A filial de faturamento n�o pode ser diferente da(s) filial(is): " + _cFilDeFat ,"Aten��o",,1)
	        _lRet := .F.
	        Break
	     ElseIf _cFilFatur <> _cFilDeFat
            U_ITmsg("A filial de faturamento n�o pode ser diferente da filial: " + _cFilDeFat +"." ,"Aten��o", ,1) 
	        _lRet := .F.
	        Break
	     EndIf 
	  Else // Regras para as filiais de origem diferentes de 90 e 93.
         If ! Empty(_cFilFatur) .And. Upper(_cTrocaNf) == "NAO"
            U_ITmsg("N�o � permitido informar filial de faturamento para troca nota igual a n�o.","Aten��o",  ,1)
	        _cFilFatur := Space(2)
	        _lRet := .F.
	        Break
		 EndIf 
	  EndIf  
   
   ElseIf _cCampo == "OPERACAO"
      If _cChamadaV == "P" // "L" = Transfer�ncia em Lotes de v�rios Pedidos de Vendas.
	     If SC5->C5_I_OPER $ _cOperTran .And. !(_cOper25 $ _cOperTran)  // U_ITGETMV( "IT_OPTRANF","42")
            U_ITmsg("N�o � permitido alterar a opera��o de pedidos de vendas de opera��o triangular.","Aten��o",,1)   
            _lRet := .F.
		    Break 
	     EndIf 
      EndIf 
	  
      If Empty(_cValorDig) 
         U_ITmsg("O preenchimento do c�digo da opera��o � obrigat�rio.","Aten��o",,1)   
         _lRet := .F.
		 Break 
	  EndIf 

	  If _cFilLogad $ _cFilOrigI // Grupo de filiais para aplica��o das regras // Filiais de origem 90/93.

         If _cFilDestino == _cFilLogA .And. ! (_cValorDig $ _cOperacA .Or. _cValorDig $ _cOperacC) // Filial logada igual a 90
            U_ITmsg("Para esta filial de destino, s� � permitido informar as opera��es: " + AllTrim(_cOperacA) + "/"+Alltrim(_cOperacC)+"." ,"Aten��o",,1)   
            _lRet := .F.
		    Break 
         EndIf 

         //ExistCpo("ZB4",_cOper25)
	     ZB4->(DbSetOrder(1)) // ZB4_FILIAL+ZB4_COD
         If ! ZB4->(MsSeek(xFilial("ZB4")+_cValorDig))
            U_ITmsg("C�digo de Opera��o n�o localizado no cadastro de opera��es.","Aten��o",,1)
		    _lRet := .F.
	     EndIf 

         If _cFilLogad == _cFilLogA // Filial logada igual a 90
	        If _cFilLogad $ _cFilDDesI //:= U_ITGETMV( "IT_FILDSTI","01;10;23;20;40;") // Filiais de Destino Iguais
			   U_ITmsg("Para esta filial de destino, s� � permitido opera��o: " + AllTrim(_cOperacA)+"." ,"Aten��o",,1)   
               _cOper25 := _cOperacA  // U_ITGETMV( "IT_OPERTRA","01")               // Opera��o de Transfer�ncia A 
            EndIf 

		    // Se filial de destino for 93 permitir opera��o 26  criar par�metro.
		    If _cFilDestino $ _cFilLogB // U_ITGETMV( "IT_FILLOGB","93") // Filial logada B 
               If !(_cOper25 $ _cOperacA) .And. !(_cOper25 $ _cOperacB)  // U_ITGETMV( "IT_OPERTRB","26") 
                  U_ITmsg("Para esta filial de destino, s� � permitido opera��o: " + AllTrim(_cOperacA)+ " ou " +AllTrim(_cOperacB) +"." ,"Aten��o",,1)   
                  _lRet := .F.
		          Break 
			   EndIf 
		    EndIf 

	     ElseIf _cFilLogad == _cFilLogB // U_ITGETMV( "IT_FILLOGB","93") // Filial logada B 
            If _cFilLogad $ _cFilDDesI //:= U_ITGETMV( "IT_FILDSTI","01;10;23;20;40;") // Filiais de Destino Iguais
		       U_ITmsg("Para esta filial de destino, s� � permitido opera��o: " + AllTrim(_cOperacA)+"." ,"Aten��o",,1)   
               _cOper25 := _cOperacA  // U_ITGETMV( "IT_OPERTRA","01")               // Opera��o de Transfer�ncia A 
            EndIf 
	     EndIf 
      Else // Filiais de origem diferentes de 90/93.
         If _cFilDestino == _cFilLogA // Filial de destino igual a 90
            If !(_cOper25 $ _cOperacA) .And. !(_cOper25 $ _cOperacC) // U_ITGETMV( "IT_OPERTRA","01") 
			   U_ITmsg("Para esta filial de destino: "+ _cFilDestino + ", deve-se informar as opera��es: " +_cOperacA+ " ou " + _cOperacC + ".","Aten��o",,1)   
               _lRet := .F.
		       Break 
			Else 
			   If _cChamadaV == "P" // Chamada da fun��o, pedido de vendas posicionado.
			      _oLocal:Enable()
			   EndIf 
            EndIf 
		 Else 
		    _cLocal := Space(2)
			If _cChamadaV == "P" // Chamada da fun��o, pedido de vendas posicionado.
               _oLocal:Disable() 
			EndIf 
		 EndIf 
  
      EndIf 

   ElseIf _cCampo == "LOCAL"  // ajustar aqui quando c�digo de armaz�m for multiplos.

      If _cFilDestino == _cFilLogA // Filial de destino igual a 90  
         If Empty(_cValorDig) .And. _cOper25 $ _cOperacC 
            U_ITmsg("O preenchimento do armaz�m � obrigat�rio para esta filial de destino.","Aten��o",,1)   
            _lRet := .F.
		    Break 
	     EndIf  
	
	     //ExistCpo("NNR",_cLocal)
		 If ! Empty(_cValorDig) 
	        NNR->(DbSetOrder(1)) // NNR_FILIAL+NNR_CODIGO 
	        If ! NNR->(MsSeek(xFilial("NNR")+_cValorDig))
               U_ITmsg("C�digo de armaz�m n�o localizado no cadastro de armaz�ns.","Aten��o",,1)   
               _lRet := .F.
            EndIf
		 EndIf 

      EndIf 

   EndIf 

   If _cCampo == "OPERACAO" .OR. _cCampo == "FILIAL_DESTINO"

		U_AOMS058X(_cOper25,_cFilDestino)

   EndIf

End Sequece

If _cChamadaV == "P" // Chamada da fun��o, pedido de vendas posicionado.
   _oTrocaNf:Refresh()
   _oFilFatur:Refresh()
   _oOper25:Refresh()
   _oLocal:Refresh()
EndIf 

Return _lRet


/*
===============================================================================================================================
Programa----------: AOMOS32X
Autor-------------: Igor Melga�o
Data da Criacao---: 24/06/2025
===============================================================================================================================
Descri��o---------: Verifica se existe o Campo no Acols e inclui no Array para execu��o do ExecAuto 
===============================================================================================================================
Parametros--------: aLinha,cCampo,aColsBkp,aHeaderBkp,i
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/
Static Function AOMOS32X(aLinha,cCampo,aColsBkp,aHeaderBkp,i)
Local nPos := 0

nPos := aScan(aHeaderBkp,{|x| AllTrim(x[2]) == cCampo})
If nPos > 0
   AADD(aLinha,{ cCampo    , aColsBkp[i,nPos]    ,Nil})
EndIf

Return
