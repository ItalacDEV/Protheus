/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 12/08/2022 | Corrigido filtro para produtores que emitem a pr�pria nota. Chamado 40932
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 16/08/2022 | Corrigida query para n�o considerar pre-notas. Chamado 41037
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 24/08/2022 | Retirado caracter inserido pelo notebook defeituoso. Chamado 41130
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'Protheus.ch' 

/*
===============================================================================================================================
Programa----------: MCTB001
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 21/06/2017
===============================================================================================================================
Descri��o---------: Rotina para Contabilizar Fechamento do Leite. Criada rotina para contabilizar os descontos dos produtores 
					de leite apurados na rotina de fechamento. Os cr�ditos geram itens nas notas fiscais, sendo assim, j� s�o 
					contabilizados pelo Compras.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MCTB001

Local _oSelf		:= nil
Local _cPerg		:= "MCTB001"

//============================================
//Cria interface principal
//============================================
tNewProcess():New(	"MCTB001"									,; // Fun��o inicial
					"Contabiliza��o Fechamento do Leite"		,; // Descri��o da Rotina
					{|_oSelf| MCTB01P(_oSelf, _cPerg) }			,; // Fun��o do processamento
					"Rotina para gera��o da Contabiliza��o do Fechamento do Leite",; // Descri��o da Funcionalidade
					_cPerg										,; // Configura��o dos Par�metros
					{}											,; // Op��es adicionais para o painel lateral
					.F.											,; // Define cria��o do Painel auxiliar
					0											,; // Tamanho do Painel Auxiliar
					''											,; // Descri��o do Painel Auxiliar
					.T.											,; // Se .T. exibe o painel de execu��o. Se falso, apenas executa a fun��o sem exibir a r�gua de processamento.
					.F.									 		) // Op��o para cria��o de apenas uma r�gua de processamento

Return

/*
===============================================================================================================================
Programa----------: MCTB001P
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 08/06/2017
===============================================================================================================================
Descri��o---------: Processa registros
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MCTB01P(_oSelf, _cPerg)

Local _cAlias	:= "CTBALT"//GetNextAlias()
Local _aArea 	:= GetArea()
Local _cArquivo := " "
Local _cLote  	:= AvKey(AllTrim(MV_PAR05),"CT2_LOTE")
Local _nTotal   := 0 
Local _dData	:= MV_PAR04
Local _lDigita  := (MV_PAR01==1)
Local _lAglut	:= (MV_PAR02==1)
Local _cOnLine	:= "N"
Local _cPadrao  := "Z02" //C�digo do Lan�amento Padr�o que ser� utilizado nessa rotina
Local _nHdlPrv, _nX	:= 0 
Local _aSelFil	:= {}
Local _cFilAnt	:= cFilAnt //Salva filial corrente
Local _aFlagCTB := {}
Local _lUsaFlag := GetNewPar("MV_CTBFLAG",.F.)
Local _cThread	:= CValToChar(ThreadID())

_oSelf:SetRegua1(1)
_oSelf:IncRegua1("Buscando registros...")

//Chama fun��o que permitir� a sele��o das filiais
If MV_PAR06 == 1
	_aSelFil := AdmGetFil(.F.,.F.,"ZLF")
	If Empty(_aSelFil)
		Aadd(_aSelFil,cFilAnt)
	Endif
Else
	Aadd(_aSelFil,cFilAnt)
Endif

_oSelf:SaveLog("Thread:"+_cThread+" Iniciando a rotina. Par�metros: "+CValToChar(MV_PAR01)+"-"+CValToChar(MV_PAR02)+"-"+DToC(MV_PAR03)+"-"+DToC(MV_PAR04)+"-"+MV_PAR05+"-"+AsString(_aSelFil))
_oSelf:SetRegua1(Len(_aSelFil))

For _nX:=1 to Len(_aSelFil)

	cFilAnt := _aSelFil[_nX]
	_oSelf:SaveLog("Iniciando filial "+ _aSelFil[_nX])
	_oSelf:IncRegua1("Processando Filial: "+cFilAnt)
	
	//Este fun��o cria o cabe�alho da contabiliza��o
	_nHdlPrv:= HeadProva(_cLote,_cPerg,Alltrim(cUserName),@_cArquivo) 
	
	If _nHdlPrv <= 0
	     Help(" ",,1,"A100NOPRV")
	     ProcLogAtu(_cPerg,"A100NOPRV",Ap5GetHelp("A100NOPRV"))
	     Return
	EndIf 
	//Necess�ria a segunda query para pegar as notas dos produtores que emitem a pr�pria nota. Al�m de serem v�rias notas por mix, elas se referem � todos
	//os setore e linha, logo, n�o � poss�vel fazer a refer�ncia 1x1. Ainda n�o encontrei uma forma de pegar corretamente os casos onde esse tipo de produtor
	//for fechado apenas no m�s seguinte. A nota emitida � para o mesmo c�digo mas a loja pode ser diferente por isso n�o deve ser amarrada.
	//Visto que a nota emitida pelo produtor n�o tem data para ser emitida, n�o ser� feito um filtro de data, pegando todo o passado e n�o ficando nada sem contabilizar.
	BeginSQL Alias _cAlias
		SELECT ZLF.ZLF_FILIAL, ZLF.ZLF_A2COD, ZLF.ZLF_A2LOJA, ZLF.ZLF_SETOR, ZLF.ZLF_LINROT, ZLF.ZLF_DEBCRE, ZLF.ZLF_EVENTO,
				ZLF.ZLF_DTFIM, ZLF.ZLF_L_SEEK, SA2.A2_CONTA, ZL8.ZL8_CONTA, ZLF.R_E_C_N_O_,
				'NF ' || SF1.F1_DOC || ' ' || ZLF.ZLF_A2COD || ' ' || SA2.A2_NOME HISTORICO, ZLF.ZLF_TOTAL
			FROM %Table:ZLF% ZLF, %Table:ZL8% ZL8, %Table:SA2% SA2, %Table:SF1% SF1
		WHERE ZLF.D_E_L_E_T_ = ' '
			AND ZL8.D_E_L_E_T_ = ' '
			AND SA2.D_E_L_E_T_ = ' '
			AND SF1.D_E_L_E_T_ = ' '
			AND ZLF.ZLF_FILIAL = %xFilial:ZLF%
			AND ZLF.ZLF_FILIAL = ZL8.ZL8_FILIAL
			AND ZLF.ZLF_FILIAL = SF1.F1_FILIAL
			AND ZLF.ZLF_EVENTO = ZL8.ZL8_COD
			AND ZLF.ZLF_A2COD = SA2.A2_COD
			AND ZLF.ZLF_A2LOJA = SA2.A2_LOJA
			AND ZLF.ZLF_A2COD = SF1.F1_FORNECE
			AND ZLF.ZLF_A2LOJA = SF1.F1_LOJA
			AND ZLF.ZLF_CODZLE = SF1.F1_L_MIX
			AND ZLF.ZLF_SETOR = SF1.F1_L_SETOR
			AND ZLF.ZLF_LINROT = SF1.F1_L_LINHA
			AND SF1.F1_DTDIGIT BETWEEN %exp:DToS(MV_PAR03)% AND %exp:DToS(MV_PAR04)%
			AND ZLF.ZLF_A2COD LIKE 'P%'
			AND ZLF.ZLF_DEBCRE = 'D'
			AND ZLF.ZLF_TOTAL > 0
			AND ZLF.ZLF_LA <> 'S'
			AND ZLF.ZLF_STATUS = 'F'
			AND ZL8.ZL8_COD NOT IN ('000013','000016','000019')
		UNION
		SELECT ZLF.ZLF_FILIAL, ZLF.ZLF_A2COD, ZLF.ZLF_A2LOJA, ZLF.ZLF_SETOR, ZLF.ZLF_LINROT, ZLF.ZLF_DEBCRE, ZLF.ZLF_EVENTO,
				ZLF.ZLF_DTFIM, ZLF.ZLF_L_SEEK, SA2.A2_CONTA, ZL8.ZL8_CONTA, ZLF.R_E_C_N_O_,
				'NF DIVERSAS' /*|| SF1.F1_DOC */ ||' ' || ZLF.ZLF_A2COD || ' ' || SA2.A2_NOME HISTORICO, ZLF.ZLF_TOTAL
			FROM %Table:ZLF% ZLF, %Table:ZL8% ZL8, %Table:SA2% SA2, %Table:SF1% SF1
		WHERE ZLF.D_E_L_E_T_ = ' '
			AND ZL8.D_E_L_E_T_ = ' '
			AND SA2.D_E_L_E_T_ = ' '
			AND SF1.D_E_L_E_T_ = ' '
			AND ZLF.ZLF_FILIAL = %xFilial:ZLF%
			AND ZLF.ZLF_FILIAL = ZL8.ZL8_FILIAL
			AND ZLF.ZLF_FILIAL = SF1.F1_FILIAL
			AND ZLF.ZLF_EVENTO = ZL8.ZL8_COD
			AND ZLF.ZLF_A2COD = SA2.A2_COD
			AND ZLF.ZLF_A2LOJA = SA2.A2_LOJA
			AND ZLF.ZLF_A2COD = SF1.F1_FORNECE
			AND ZLF.ZLF_CODZLE = SF1.F1_L_MIX
			AND ZLF.ZLF_A2COD LIKE 'P%'
			AND ZLF.ZLF_DEBCRE = 'D'
			AND ZLF.ZLF_TOTAL > 0
			AND ZLF.ZLF_LA <> 'S'
			AND ZLF.ZLF_STATUS = 'F'
			AND SA2.A2_L_NFPRO = 'S'
			AND SF1.F1_STATUS = 'A'
			AND ZL8.ZL8_COD NOT IN ('000013','000016','000019')
			AND SF1.F1_FORMUL <> 'S'
			GROUP BY ZLF.ZLF_FILIAL, ZLF.ZLF_A2COD, ZLF.ZLF_A2LOJA, ZLF.ZLF_SETOR, ZLF.ZLF_LINROT, ZLF.ZLF_DEBCRE, ZLF.ZLF_EVENTO,
				ZLF.ZLF_DTFIM, ZLF.ZLF_L_SEEK, SA2.A2_CONTA, ZL8.ZL8_CONTA, ZLF.R_E_C_N_O_, ZLF.ZLF_TOTAL, SA2.A2_NOME
		ORDER BY ZLF_FILIAL, ZLF_SETOR, ZLF_A2COD
	EndSQL
	
	While (_cAlias)->( !Eof() )
		If VerPadrao(_cPadrao)

			If _lUsaFlag
				aAdd(_aFlagCTB,{"ZLF_LA","S","ZLF",(_cAlias)->R_E_C_N_O_,0,0,0})
			EndIf
			
		     //gera linha da contabiliza��o de acordo com as regras do LP passado
	     	_nTotal += DetProva(_nHdlPrv,_cPadrao,_cPerg,_cLote,,,,,,,,@_aFlagCTB,{"ZLF",(_cAlias)->R_E_C_N_O_}) 
			
			//Atualiza Flag de Lan�amento Cont�bil
			If _lUsaFlag
				aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
			Else 
				DbSelectArea("ZLF")
				ZLF->(DbGoTo((_cAlias)->R_E_C_N_O_))
				ZLF->(RecLock("ZLF", .F.))
				REPLACE ZLF_LA With "S"
				ZLF->(MsUnLock())
				ZLF->(DbCloseArea())
			EndIf
			
	     EndIf
	     (_cAlias)->( DBSkip() )
	EndDo 
	
	If _nTotal > 0
		//Esta fun��o ir� cria a finaliza��o da contabiliza��o.
		RodaProva(_nHdlPrv,_nTotal)
		// Envia para Lancamento Contabil. Essa e a funcao do quadro dos lancamentos.
		cA100Incl(_cArquivo,_nHdlPrv,3,_cLote,_lDigita,_lAglut,_cOnLine,_dData,,@_aFlagCTB)
	EndIf

	(_cAlias)->(DbClosearea())
	_oSelf:SaveLog("Thread:"+_cThread+" T�rmino filial "+ _aSelFil[_nX])
Next _nX

cFilAnt := _cFilAnt //Restaura filial
_oSelf:SaveLog("Thread:"+_cThread+" T�rmino normal")
RestArea(_aArea)
Return
