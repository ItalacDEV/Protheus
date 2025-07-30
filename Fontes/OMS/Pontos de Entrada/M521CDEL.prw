/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Alexandre Villar | 07/11/2014 | Remo��o do Controle de Expedi��o criado na implanta��o e n�o efetivado. Chamado 6863
-------------------------------------------------------------------------------------------------------------------------------
 Alexandre Villar | 13/08/2015 | Ajuste nas mensagems para facilitar o endentimento com rela��o aos t�tulos/documentos que n�o
                  |            | passarem nas valida��es. Chamado 11352
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 11/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Rwmake.ch"
#include "Protheus.ch"

/*
===============================================================================================================================
Programa--------: M521CDEL
Autor-----------: Tiago Correa Castro
Data da Criacao-: 09/02/2009
===============================================================================================================================
Descri��o-------: Ponto de Entrada na validacao da exclusao da nota de Saida. Valida se o titulo a Pagar do Autonomo ja foi 
					baixado nao permitindo assim a exclusao do Faturamento
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function M521CDEL()

Local lRet		:= .T.
Local _aInfHlp	:= {}
Local aArea		:= GetArea()
Local cCarga	:= SF2->F2_CARGA
Local dDtEmis	:= SF2->F2_EMISSAO     
   
//================================================================================
//| Verifica se a dataBase � valida para realizar a exclusao do documento        |
//================================================================================
If dDataBase < dDtEmis

	//================================================================================
	//| Cadastra o Help e Exibe                                                      |
	//================================================================================
	_aInfHlp := {}
	//                  |....:....|....:....|....:....|....:....|	  |....:....|....:....|....:....|....:....|	  |....:....|....:....|....:....|....:....|
	aAdd( _aInfHlp	, { 'N�o � permitido estornar um documento '	, 'em data anterior � data de emiss�o. A '	, 'emiss�o do registro �:' + DtoC(dDtEmis)	} )
	aAdd( _aInfHlp	, { 'Para excluir o documento atual deve '		, 'ser utilizada a (database) posterior � '	, 'data de emiss�o.'						} )
	
	U_ITCADHLP( _aInfHlp , "M521CD1" )
	
	Return( .F. )

EndIf

//================================================================================
//| Salvando Integridade do Sistema.                                             |
//================================================================================
dbSelectArea("SF2")
_nOrdSF2 := IndexOrd()
_nRecSF2 := Recno()

dbSelectArea("SD2")
_nOrdSD2 := IndexOrd()
_nRecSD2 := Recno()

//================================================================================
//| Tratativas exclusivas para o estorno de documentos de faturamento de carga   |
//================================================================================
If !Empty(cCarga)

	//================================================================================
	//| Verifica a chamada da fun��o                                                 |
	//================================================================================
	If Upper( AllTrim( FunName() ) ) == "MATA521B"
	
		DBSelectArea("ZZ2")
		ZZ2->( DBSetORder(2) ) // ZZ2_FILIAL+ZZ2_CARGA
		If ZZ2->( DBSeek( xFilial("ZZ2") + cCarga ) ) //Transporte realizado por Autonomo
		
			DBSelectArea("SE2")
			SE2->( DBSetOrder(1) ) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			If SE2->( DBSeek( xFilial("SE2") + "AUT" + ZZ2->ZZ2_RECIBO ) )
				
				While SE2->( !Eof() ) .and. SE2->( E2_FILIAL + E2_PREFIXO + E2_NUM ) == xFilial("SE2") + "AUT" + ZZ2->ZZ2_RECIBO .And. AllTrim(SE2->E2_ORIGEM) == "GERAZZ3"
					
					//====================================================================================================
					// Verifica se houveram movimenta��es no t�tulo financeiro
					//====================================================================================================
					If SE2->E2_TIPO == "RPA" .and. SE2->E2_SALDO <> SE2->E2_VALOR
		
						MessageBox(	'O T�tulo ['+ SE2->( E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO ) +'] possui baixas/movimenta��es e n�o pode ser exclu�do! '	+;
									'� necess�rio solicitar o estorno de todos os movimentos do t�tulo para prosseguir com o processo!' , 'Aten��o!' , 48 )
						

						lRet := .F.
						
					EndIf
					
				SE2->( DBSkip() )
				EndDo
			
			EndIf
			
		EndIf
		
	Else
		
		//================================================================================
		//| Cadastra o Help e Exibe                                                      |
		//================================================================================
		_aInfHlp := {}
		//                  |....:....|....:....|....:....|....:....|	   |....:....|....:....|....:....|....:....|	  |....:....|....:....|....:....|....:....|
		aAdd( _aInfHlp	, { 'N�o � permitido estornar um documento '	, 'gerado por Carga atrav�s da rotina atual!'	, ' Carga: ['+ cCarga +']'					} )
		aAdd( _aInfHlp	, { 'Para estorno desse documento deve ser '	, 'utilizada a rotina de Exclus�o por Carga.'	, ''										} )
		
		U_ITCADHLP( _aInfHlp , "M521CD3" )
		
		lRet := .F.
		
	EndIf
	
EndIf

dbSelectArea("SD2")
dbSetOrder(_nOrdSD2)
dbGoto(_nRecSD2)

dbSelectArea("SF2")
dbSetOrder(_nOrdSF2)
dbGoto(_nRecSF2)

RestArea(aArea)

Return( lRet )