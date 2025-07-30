/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 27/08/2019 | Revis�o do fonte. Chamado 30387
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'Protheus.ch' 

/*
===============================================================================================================================
Programa----------: MGPE006
Autor-------------: Heder Jos�
Data da Criacao---: 21/06/2017
===============================================================================================================================
Descri��o---------: Rotina desenvolvida para possibilitar a gera��o de arquivo .txt com informa��es do funcion�rio para cadastro
					no sistema do Banco do Brasil
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGPE006

Local _cPerg		:= "MGPE006"
Local _oSelf		:= nil

//============================================
//Cria interface principal
//============================================
tNewProcess():New(	_cPerg								,; // Fun��o inicial
					"Gera arquivo Banco do Brasil"		,; // Descri��o da Rotina
					{|_oSelf| MGPE06P(_oSelf) }			,; // Fun��o do processamento
					"Rotina para gerar informa��es cadastrais de funcio�rios para importa��o no " +;
					" sistema do Banco do Brasil" ,; // Descri��o da Funcionalidade
					_cPerg								,; // Configura��o dos Par�metros
					{}									,; // Op��es adicionais para o painel lateral
					.F.									,; // Define cria��o do Painel auxiliar
					0									,; // Tamanho do Painel Auxiliar
					''									,; // Descri��o do Painel Auxiliar
					.T.									,; // Se .T. exibe o painel de execu��o. Se falso, apenas executa a fun��o sem exibir a r�gua de processamento.
					.T.									 ) // Op��o para cria��o de apenas uma r�gua de processamento

Return

/*
===============================================================================================================================
Programa----------: MGPE06P
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 27/08/2019
===============================================================================================================================
Descri��o---------: Realiza o processamento da rotina.
===============================================================================================================================
Parametros--------: _oSelf
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MGPE06P(_oSelf)

Local _nHdlLog	:= 0
Local _cAlias	:= GetNextAlias()
Local _cFiltro	:= "%"
Local _nCountRec:= 0
Local _nI		:= 1

_nHdlLog := FCreate(MV_PAR02)

If _nHdlLog == -1
	MsgStop("Erro ao criar aqruivo. A rotina n�o ser� executada!", "MGPE00601")
	Return
EndIf
_oSelf:SaveLog("Iniciando a rotina. Par�metros: "+AllTrim(MV_PAR01)+"-"+AllTrim(MV_PAR02)+"-"+DToC(MV_PAR03)+"-"+DToC(MV_PAR04))
_oSelf:SetRegua1(2)
_oSelf:IncRegua1("Buscando Funcion�rios...")

//Filtra Matr�culas
If !Empty(MV_PAR01)
	_cFiltro += " AND RA.RA_MAT IN " + FormatIn(AllTrim(MV_PAR01),";")
EndIf
_cFiltro += "%"

BeginSql alias _cAlias
	SELECT RA_NOME, RA_CIC, SUBSTR(RA_BCDEPSA, 1, 3) BANCO, SUBSTR(RA_BCDEPSA, 4, 5) AGENCIA,
	       RA_CTDEPSA, RA_ENDEREC, RA_MUNICIP, RA_CEP, RA_ESTADO
	  FROM %Table:SRA%
	 WHERE D_E_L_E_T_ = ' '
	   AND SUBSTR(RA_BCDEPSA, 1, 3) <> '   '
	   AND RA_FILIAL = %xFilial:SRA%
	   AND RA_ADMISSA BETWEEN %exp:MV_PAR03% AND %exp:MV_PAR04%
	   AND RA_CATFUNC IN ('M', 'E')
	 ORDER BY RA_MAT
EndSql

Count To _nCountRec
(_cAlias)->( DbGotop() )
_oSelf:SetRegua1(_nCountRec)

//====================================================================================================
// Processa registros encontrados
//====================================================================================================
If _nCountRec > 0
	Do While (_cAlias)->(!Eof())
		_oSelf:IncRegua1("Gravando registros...["+ StrZero(_nI,6) +"] de ["+ StrZero(_nCountRec,6) +"]" ) 
		_cLin := PADR((_cAlias)->RA_NOME			,30," ")
		_cLin += "1" //Tipo de Incricao 1=CPF 2=CNPJ 3=PASEP
		_cLin += PADL(AllTrim((_cAlias)->RA_CIC)	,14,"0")
		_cLin += PADL(AllTrim((_cAlias)->BANCO)		,03,"0")
		_cLin += PADL(AllTrim((_cAlias)->AGENCIA)	,05,"0")
		_cLin += PADL(AllTrim((_cAlias)->RA_CTDEPSA),12,"0")
		_cLin += PADR((_cAlias)->RA_ENDEREC			,30," ")
		_cLin += PADR((_cAlias)->RA_MUNICIP			,20," ")
		_cLin += PADL(AllTrim((_cAlias)->RA_CEP)	,08,"0")
		_cLin += PADR((_cAlias)->RA_ESTADO			,02," ")
		_cLin +=  CHR(13)+CHR(10)
		_nI ++
//		FWrite(nHdl,_cLin,Len(_cLin))
		//Grava linha no arquivo
		FWrite( _nHdlLog , _cLin)

		(_cAlias)->( DBSkip() )
	EndDo
	(_cAlias)->( DBCloseArea() )

Else
	MsgAlert("N�o foram encontrados registros para processar com os filtros informados! Verifique os par�metros digitados.","MGLT00502")
	Return()
EndIf

FClose( _nHdlLog )

Return