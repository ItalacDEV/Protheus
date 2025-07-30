/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 11/03/2019 | Alterado layout de importa��o. Chamado 28400
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 06/11/2023 | Descontinuado o layout do TrackMaker e inclu�do do SmartQuestion. Chamado 45424
===============================================================================================================================
*/

//===========================================================================
//| Defini��es de Includes                                                  |
//===========================================================================
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

/*
===============================================================================================================================
Programa----------: MGLT006
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 10/12/2018
===============================================================================================================================
Descri��o---------: Rotina para importa��o de coordenadas geogr�ficas para o cadastro de produtores
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGLT006()

Private _cPerg		:= "MGLT006"
Private _oSelf		:= nil

//============================================
//Cria interface principal
//============================================
tNewProcess():New(	_cPerg											,; // Fun��o inicial
					"Atualiza Coord. Geogr�ficas Produteres"		,; // Descri��o da Rotina
					{|_oSelf| MGLT006P(_oSelf) }					,; // Fun��o do processamento
					"Rotina para efetuar a atualiza��o das coordenadas geogr�ficas " +;
					"nos cadastros dos produtores rurais." ,; // Descri��o da Funcionalidade
					_cPerg											,; // Configura��o dos Par�metros
					{}												,; // Op��es adicionais para o painel lateral
					.F.												,; // Define cria��o do Painel auxiliar
					0												,; // Tamanho do Painel Auxiliar
					''												,; // Descri��o do Painel Auxiliar
					.F.												,; // Se .T. exibe o painel de execu��o. Se falso, apenas executa a fun��o sem exibir a r�gua de processamento.
                    .T.                                              ) // Se .T. cria apenas uma regua de processamento.

Return

/*
===============================================================================================================================
Programa----------: MGLT006P
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 10/12/2018
===============================================================================================================================
Descri��o---------: Realiza o processamento da rotina.
===============================================================================================================================
Parametros--------: _oSelf
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MGLT006P(_oSelf)

Local _cFilSMQT	:= SuperGetMV("LT_FILPROD", .F. ,"01,02,04,06,09,0A,0B,40,10,11,20,23,24,25") //filiais com integra��o com o SmartQuestion
Local _nHandle	:= 0
Local _aDados	:= {}
Local _cEOL 	:= CHR(13) + CHR(10)
Local _nBuffer	:= 100
Local _nFilePos	:= 0
Local _nPos		:= 0
Local _cLine	:= "" 
Local _cBuffer	:=''
Local _nTamArq	:= 0
Local _nProc	:= 0
Local _nSQ		:= 0
Local _nX		:= 0
Local _nLidos	:= 0

//Abre arquivo de texto
If (_nHandle := FOpen(MV_PAR01)) >= 0
    _oSelf:SetRegua1(1)
	_oSelf:IncRegua1("Abrindo arquivo...")
	_nTamArq:= FSeek(_nHandle, 0, 2) //Posiciona no fim do arquivo para pegar o tamanho
    _nFilePos:= FSeek(_nHandle, 0, 0) // Posiciona no in�cio do arquivo, no primeiro caracter
	_oSelf:SetRegua1(_nTamArq)

	DBSelectArea("SA2")
	SA2->( DBSetOrder(1) )

	While !(_nFilePos < 0 .Or. _nFilePos >= _nTamArq)
	    _cBuffer	:= SPACE(_nBuffer) //Aloca Buffer
		FRead(_nHandle, _cBuffer, _nBuffer) //L� os primeiros 100 caracteres do arquivo
		_nPos	:= AT(_cEOL, _cBuffer) // Procura o primeiro final de linha
		For _nX:= 1 To _nPos
			_oSelf:IncRegua1()
		Next _nX
		
	    If _nPos == 0
			MsgStop("Arquivo inconsist�nte. Favor acionar o �rea de TI.","MGLT00601")
			Return()
		EndIf	    	
	    // Leitura dos campos e grava��o dos dados na tabela
	    _cLine := Substr(_cBuffer, 0, _nPos)
		_aDados:= StrTokArr(_cLine,';')

		If SA2->( DBSeek( xFilial("SA2") + _aDados[1]))
			_nProc++
			SA2->( RecLock( "SA2" , .F. ) )
			SA2->A2_L_LATIT	:= NoRound(Val(StrTran(_aDados[2],",",".")),GetSx3Cache("A2_L_LONGI","X3_DECIMAL"))
			SA2->A2_L_LONGI	:= NoRound(Val(StrTran(_aDados[3],",",".")),GetSx3Cache("A2_L_LATIT","X3_DECIMAL"))
  			If SubStr( SA2->A2_L_LI_RO,1,2) $ _cFilSMQT
				_nSQ++
				SA2->A2_L_SMQST := 'P'
			EndIf
			SA2->( MsUnLock() )
		EndIf
		_nLidos+=_nPos+1 //Salvo at� qual posi��o do arquivo j� foi lido desde a primeira posi��o
		_nFilePos:=FSeek(_nHandle, _nLidos,0) //Posiciono na pr�xima linha a partir do in�cio do arquivo
	EndDo
    
	If _nProc == 0
		MsgStop("Nenhum produtor foi atualizado.","MGLT00602")
	Else
		MsgInfo("Foram atualizados "+AllTrim(Str(_nProc))+" produtores com sucesso e "+AllTrim(Str(_nSQ))+" marcado(s) para envio para o SmartQuestion!","MGLT00603")
	EndIf

	// Fecha arquivo	
    fClose(_nHandle)
Else
	MsgAlert("O arquivo est� vazio ou � inv�lido para an�lise! Verifique o arquivo e tente novamente.","MGLT00604")
EndIF

Return
