/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           |
-------------------------------------------------------------------------------------------------------------------------------
 Alexandre Villar | 28/08/2015 | Ajuste para n�o bloquear o estorno da classifica��o de documentos. Chamados 11497/11578      |
------------------:------------:----------------------------------------------------------------------------------------------:
Lucas B. Ferreira | 06/06/2017 | Ajustada valida��o para n�o executar o PE no fechamento do Leite - Chamado 14511			  |
===============================================================================================================================
*/

#Include "RwMake.ch"

/*
===============================================================================================================================
Programa--------: SF1100E
Autor-----------: Alexandre Villar
Data da Criacao-: 26/11/2014
===============================================================================================================================
Descri��o-------: Ponto de entrada ap�s a exclus�o da nota fiscal
===============================================================================================================================
Uso-------------: Italac
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
Setor-----------: TI
===============================================================================================================================
*/

User Function SD1100E()

Local _aArea	:= GetArea()
Local _cStatus	:= ''
Local _lRLeite	:= !AllTrim( Upper( FUNNAME() ) ) $"U_MGLT009/MGLT010"

If _lRLeite
	DBSelectArea('ZLX')
	ZLX->( DBSetOrder(2) )
	If ZLX->( DBSeek( xFilial('ZLX') + SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA ) ) )
	
		If FunName() == "MATA103" .Or. ( FunName() == "MATA140" .And. SF1->F1_STATUS <> 'A' )
			
			If ZLX->ZLX_STATUS == '1' .And. Empty( ZLX->ZLX_CODANA )
				
				ZLX->( RecLock( 'ZLX' , .F. ) )
				ZLX->( DBDelete() )
				ZLX->( MsUnLock() )
				
			Else
				
				IF ZLX->ZLX_STATUS <> '1'
					_cStatus := IIF( !Empty( ZLX->ZLX_CODANA ) , IIF( ZLX->ZLX_STATUS == '2' , 'CLASSIFICADO' , 'FECHADO' ) , 'PENDENTE' )
				Else
					_cStatus := 'vinculado � uma an�lise de qualidade'
				EndIf
				
				MessageBox(	'Existe registro de Recep��o de Leite de Terceiros relacionado ao Documento de Entrada exclu�do! ' +;
							'A rotina n�o pode excluir esse registro pois o mesmo encontra-se '+ _cStatus +'.' , 'Aten��o!' , 16 )
				
			EndIf
		
		Else
		
			ZLX->( RecLock( 'ZLX' , .F. ) )
			ZLX->ZLX_VLRNF	:= 0
			ZLX->ZLX_ICMSNF	:= 0
			ZLX->( MsUnLock() )
			
		EndIf
	
	EndIf
EndIf
RestArea( _aArea )

Return()