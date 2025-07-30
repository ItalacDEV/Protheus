/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alexandre V.  | 20/07/2015 | Atualiza��o das rotinas conforme chamado 10978
-------------------------------------------------------------------------------------------------------------------------------
Alexandre V.  | 28/08/2015 | Ajuste para n�o bloquear o estorno da classifica��o de documentos. Chamados 11497/11578
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 22/04/2019 | Criada exce��o para n�o gerar Recep��o de Leite de Terceiros. Chamado 28895
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: A140EXC
Autor-------------: Alexandre Villar
Data da Criacao---: 24/02/2014
===============================================================================================================================
Descri��o---------: Valida��o da exclus�o dos documentos de entrada
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function A140EXC()

Local _lRet		:= .T.
Local _lProdLt	:= .F.
Local _lExtZLX	:= .F.
Local _cCFOP	:= SuperGetMV("LT_CFEXCL3",.F.,"1925/2925")

If SF1->F1_TIPO == "N"

	DBSelectArea("SD1")
	SD1->( DBSetOrder(1) )
	If SD1->( DBSeek( xFilial("SD1") + SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA ) ) )
		
		If Empty( SD1->D1_NFORI ) .And. Empty( SD1->D1_SERIORI )
		
			While SD1->( !EOF() ) .AND. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) .And. !AllTrim(SD1->D1_CF) $ _cCFOP
				
				DBSelectArea('ZA7')
				ZA7->( DBSetOrder(2) )
				If ZA7->( DBSeek( xFilial('ZA7') + Alltrim(SD1->D1_COD) ) )
					DBSelectArea("ZLX")
					ZLX->( DBSetOrder(2) )
					If ZLX->( DBSeek( xFilial("ZLX") + SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA ) ) )
						If ZLX->ZLX_STATUS == '1' .And. Empty( ZLX->ZLX_CODANA )
							ZLX->( RecLock( "ZLX" , .F. ) )
							ZLX->( DBDelete() )
							ZLX->( MsUnLock() )
						Else
							MsgStop("N�o � permitido excluir Documentos que est�o vinculados � uma Recep��o de Leite de Terceiros no m�dulo Gest�o do Leite!","A140EXC01")
						    _lRet := .F.
						EndIF
						_lExtZLX := .T.
					EndIF
					_lProdLt := .T.
				EndIf
			
				SD1->( DBSkip() )
			EndDo
		
		EndIf
	
	EndIf
	
	If _lRet .And. _lProdLt .And. !_lExtZLX
		MsgStop("O Documento atual cont�m produto(s) referente(s) � Recep��o de Leite por�m n�o foram encontrados dados da Recep��o no m�dulo Gest�o do Leite! "+;
					"� recomend�vel verificar se ficaram registros em aberto na Gest�o do Leite para o documento atual que foi exclu�do.","A140EXC02")
	EndIf
	
EndIf

Return( _lRet )