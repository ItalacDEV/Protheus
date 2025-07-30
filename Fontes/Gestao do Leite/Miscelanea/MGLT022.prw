/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |21/07/2021| Chamado 37147. Tratamento para produtores familiares (A2_L_CLASS=L)
Lucas Borges  |10/22/2022| Chamado 41835. Inclu�do Nome do Atravessador e ajustado tamanho do campo Loja
Lucas Borges  |04/06/2025| Chamado 50915. Corrgida a exporta��o do arquivo usando ProtheusWeb
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: MGLT022
Autor-------------: Wodson Reis
Data da Criacao---: 18/12/2008
Descri��o---------: Rotina que possibilita a geracao de arquivo .txt para integrar o sistema microsiga com o Via Lactea
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGLT022

Local _cPerg := "MGLT022" As Character
Local _oSelf := Nil As Object

//Cria interface principal
tNewProcess():New(	_cPerg						,; // cFunction. Nome da fun��o que est� chamando o objeto
					"Integra��o Via L�ctea"		,; // cTitle. T�tulo da �rvore de op��es
					{|_oSelf| MGLT022P(_oSelf) },; // bProcess. Bloco de execu��o que ser� executado ao confirmar a tela
					"Este programa ir� gerar um arquivo TXT, para ser importado no programa Via L�ctea. "+;
					"O programa Via L�ctea � utilizado para a roteriza��o das coletas de Leite ",; // cDescription. Descri��o da rotina
					_cPerg						,; // cPerg. Nome do Pergunte (SX1) a ser utilizado na rotina
					{}							,; // aInfoCustom. Informa��es adicionais carregada na �rvore de op��es. Estrutura:[1] - Nome da op��o[2] - Bloco de execu��o[3] - Nome do bitmap[4] - Informa��es do painel auxiliar.
					.F.							,; // lPanelAux. Se .T. cria um novo painel auxiliar ao executar a rotina
					0							,; // nSizePanelAux. Tamanho do painel auxiliar, utilizado quando lPanelAux = .T.
					''							,; // cDescriAux. Descri��o a ser exibida no painel auxiliar
					.T.							,; // lViewExecute. Se .T. exibe o painel de execu��o. Se falso, apenas executa a fun��o sem exibir a r�gua de processamento
					.T.							,; // lOneMeter. Se .T. cria apenas uma r�gua de processamento
					.T.							)  // lSchedAuto. Se .T. habilita o bot�o de processamento em segundo plano (execu��o ocorre pelo Scheduler)

Return

/*
===============================================================================================================================
Programa----------: MGLT022P
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 02/07/2019
Descri��o---------: Realiza o processamento da rotina.
Parametros--------: _oSelf
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MGLT022P(_oSelf As Object)

Local _cCampo		:= "%" As Character
Local _cTabela		:= "%" As Character
Local _cFiltro		:= "%" As Character
Local _cGroup		:= "%" As Character
Local _cAlias		:= GetNextAlias() As Character
Local _nCountRec	:= 0 As Numeric
Local _cAux			:= IIf( MV_PAR07 == 1 , "ZLD" , "ZLW" ) As Character
Local _nVolLeite	:= 0 As Numeric
Local _nMediaDia	:= 0 As Numeric
Local _nQtd			:= 0 As Numeric
Local _cBuffer		:= '' As Character
Local _aSelFil		:= {} As Array
Local _aUsrTanq		:= {} As Array
Local _oFile		:= Nil As Object
Local _cDrive		:= '' As Character
Local _cDir			:= '' As Character
Local _cNome		:= '' As Character
Local _cExt			:= '' As Character

SplitPath(AllTrim(MV_PAR03), @_cDrive, @_cDir, @_cNome, @_cExt )
_oFile:= FWFileWriter():New(__RelDir+_cNome+_cExt)

//Chama fun��o que permitir� a sele��o das filiais
If MV_PAR06 == 1
	If Empty(_aSelFil)
		_aSelFil := AdmGetFil(.F.,.F.,_cAux)
	Endif
Else
	Aadd(_aSelFil,cFilAnt)
EndIf

If !_oFile:Create()
	MsgStop("Erro ao criar aqruivo. A rotina n�o ser� executada!", "MGLT02201")
	Return
EndIf

_oSelf:SetRegua1(2)
_oSelf:IncRegua1("Buscando produtores...")

// Monta filtro de acordo com a tabela de origem
_cCampo += ", "+ _cAux +"_FILIAL FILIAL, SUM( "+ _cAux +"_QTDBOM ) VOLLEITE %"
_cTabela += RetSqlName(_cAux) +" "+ _cAux + " %"
_cFiltro += " AND "+ _cAux +".D_E_L_E_T_ = ' '"
_cFiltro += " AND "+ _cAux +"_DTCOLE BETWEEN '"+ DTOS(MV_PAR01) +"' AND '"+ DTOS(MV_PAR02) +"' "

_cFiltro += " AND "+ _cAux +"_FILIAL "+ GetRngFil( _aSelFil, _cAux, .T.,)
//Se preencheu os setores, j� fiz a valida��o de acesso no SX1
//Se n�o preencheu e n�o tem acesso a todos, filtra de forma que n�o retorme registros
If !Empty(MV_PAR04) .Or. Empty(MV_PAR04) .And. Posicione("ZLU",1,xFilial("ZLU")+RetCodUsr(),"ZLU_SETALL") <> 'S'
	_cFiltro += " AND "+ _cAux +"_SETOR IN "+ FormatIn( AllTrim(MV_PAR04) , ';' )
EndIf

//Verifica se foi fornecido o filtro de linha
If !Empty(MV_PAR05)
	_cFiltro += " AND "+ _cAux +"_LINROT IN " + FormatIn(MV_PAR05,";")
EndIf

_cFiltro += " AND "+ _cAux +"_RETIRO = SA2.A2_COD"
_cFiltro += " AND "+ _cAux +"_RETILJ = SA2.A2_LOJA"
_cGroup += + _cAux +"_FILIAL, %"

_cFiltro += "%"
// SQL para verificar os produtores dos Setores que movimentaram entrada de leite no periodo
BeginSQL Alias _cAlias
	SELECT SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SA2.A2_L_FREQU, SA2.A2_L_CAPTQ, SA2.A2_L_SIGSI, SA2.A2_L_CLASS, A2_L_NATRA %exp:_cCampo%
	  FROM %Table:SA2% SA2, %exp:_cTabela%
	 WHERE SA2.D_E_L_E_T_ = ' '
	   AND SA2.A2_FILIAL = %xFilial:SA2%
	   AND SA2.A2_L_TANQ || SA2.A2_L_TANLJ = SA2.A2_COD || SA2.A2_LOJA
	   AND SA2.A2_L_CLASS IN ('I','C','F')
	   %exp:_cFiltro%
	 GROUP BY %exp:_cGroup% SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SA2.A2_L_FREQU, SA2.A2_L_CAPTQ, SA2.A2_L_SIGSI, SA2.A2_L_CLASS, A2_L_NATRA
	 ORDER BY SA2.A2_COD
EndSQL

Count To _nCountRec
(_cAlias)->( DbGotop() )
_oSelf:SetRegua1(_nCountRec)
_oSelf:IncRegua1("Gerando arquivo...")

If _nCountRec > 0
	Do While (_cAlias)->(!Eof())
		_nQtd++
		_oSelf:IncRegua1("Gerando arquivo...["+ StrZero(_nQtd,6) +"] de ["+ StrZero(_nCountRec,6) +"]" ) 
		//Inicializa o array responsavel por armazenar os dados dos usuarios do tanque
		_aUsrTanq	:= {}
		
		//Seleciona os produtores que fazem uso do tanque do produtor dono do tanque
		//corrente, e o volume total de leite total deles no periodo informado
		_nVolLeite	:= UserTanque(_cAlias, _aUsrTanq)
		
		//Calcula media diaria do Tanque do Produtor
		_nMediaDia	:= ( ((_cAlias)->VOLLEITE + _nVolLeite) / (MV_PAR02 - MV_PAR01 + 1) )
			
		//Armazena os dados do Produtor dono do Tanque
		_cBuffer += SubStr( (_cAlias)->A2_COD	, 2 , 5 )	+";" //Codigo do Produtor
		_cBuffer += SubStr( (_cAlias)->A2_LOJA	, 2 , 3 )	+"-" //Loja do Produtor
		_cBuffer += Lower( (_cAlias)->A2_L_CLASS )			+";" //Classifica��o do Tanque
		_cBuffer += AllTrim( TransForm( _nMediaDia , "@E 999999" ) ) +'-'+ AllTrim( TransForm( (_cAlias)->A2_L_CAPTQ , "@E 999999" ) ) +";" //Volume de Leite + capacidade do Tanque
		_cBuffer += (_cAlias)->A2_L_FREQU					+";" //Frequencia de Coleta
		_cBuffer += AllTrim((_cAlias)->A2_NOME)				+" / "+AllTrim((_cAlias)->A2_L_NATRA)+";"+ AllTrim( (_cAlias)->A2_L_SIGSI )+CRLF
			
		(_cAlias)->( DBSkip() )
	EndDo
	(_cAlias)->( DBCloseArea() )
	
	//Grava linha no arquivo
	_oFile:Write(_cBuffer)

Else
	MsgAlert("N�o foram encontrados registros para processar com os filtros informados! Verifique os par�metros digitados.","MGLT02202")
	Return()
EndIf
_oFile:Close()
If GetRemoteType() == 5 //SmartClient HTML sem WebAgent
	CpyS2TW(__RelDir+_cNome+_cExt)  // Copia o arquivo para o Browse de navega��o Web do usu�rio
Else	
	CpyS2T(__RelDir+_cNome+_cExt,_cDrive+_cDir)
EndIf
_oFile:Erase()
_oFile:= Nil

Return

/*
===============================================================================================================================
Programa----------: UserTanque
Autor-------------: Fabiano Dias
Data da Criacao---: 24/08/2010
Descri��o---------: Processa a consulta e seleciona os produtores que fazem uso do tanque
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function UserTanque(_cAlias As Character, _aUsrTanq As Array)

Local _cAliasSA2	:= GetNextAlias()
Local _nVolLeite 	:= 0
Local _nTotVolLe	:= 0

BeginSql alias _cAliasSA2
	SELECT SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME
	  FROM %table:SA2% SA2
	 WHERE SA2.D_E_L_E_T_ = ' '
	   AND SA2.A2_L_TANQ = %exp:(_cAlias)->A2_COD%
	   AND SA2.A2_L_TANLJ = %exp:(_cAlias)->A2_LOJA%
	   AND SA2.A2_COD || A2_LOJA != %exp:(_cAlias)->(A2_COD+A2_LOJA)%
	EndSql
While (_cAliasSA2)->( !Eof() )
	_nVolLeite := U_VolLeite( (_cAlias)->FILIAL , MV_PAR01 , MV_PAR02 , "" , "" , (_cAliasSA2)->A2_COD , (_cAliasSA2)->A2_LOJA , "" , MV_PAR07 )
	
	//Considerada na importacao usuarios de tanque que tiveram movimentacao
	If _nVolLeite > 0
		_nTotVolLe += _nVolLeite
		aAdd( _aUsrTanq , { (_cAliasSA2)->A2_COD , (_cAliasSA2)->A2_LOJA , (_cAliasSA2)->A2_NOME } )
	EndIf
	
	(_cAliasSA2)->(DBSkip())
EndDo

(_cAliasSA2)->(DBCloseArea())

Return(_nTotVolLe)
