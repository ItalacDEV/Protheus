/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Jerry Santiago| 26/08/2015 | Nova tratativa da valida��o do Aprovador da SC atrav�s do ID o Usu�rio logado
              |            | Retirado a busca do usu�rio Aprovador pela fun��o U_UCFG001(1)
-------------------------------------------------------------------------------------------------------------------------------
Darcio Ribeiro| 14/10/2015 | Inclu�do tratamento, onde o sistema validar� se a SC est� no status Aprovado ou Rejeitado,
              |            | caso esteja, o sistema n�o permitir� nenhum tipo de altera��o. Chamado: 12293
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 03/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"
            
/*
===============================================================================================================================
Programa----------: MT110BLO
Autor-------------: Tiago Correa Castro
Data da Criacao---: 31/07/2008
===============================================================================================================================
Descri��o---------: Ponto de Entrada para validacao da Aprovacao da Solicitacao de Compra    
					Localiza��o: Function A110APROV - Fun��o da Solicita��o de Compras responsavel pela aprova��o das SCs.
					Em que Ponto: Ap�s a montagem da dialog de aprova��o da Solicita��o de compras. � acionado quando o usuario
					clica nos bot�es Solicita��o Aprovada, Rejeita ou Bloqueada, deve ser utilizado para continuar estas a��es 
					retorno .T.' ou interromper  'retorno .F.' , ap�s clicar os bot�es.
===============================================================================================================================
Parametros--------: PARAMIXB -> A -> Paramixb[1] = 1 = Aprovar; 2 = Rejeitar; 3 = Bloquear
===============================================================================================================================
Retorno-----------: lContinua -> L -> .T. = Continua o processo / .F. = Interrompe o processo
===============================================================================================================================
*/
User Function MT110BLO

Local	_aArea	:=	GetArea()
Local 	_lRet	:=	.T. 
Local  _cUsu	:= __cUserId
Local aMensagem	:= {}
Local aProbl	:= {}
Local aSoluc	:= {}
Local lContinua	:= .T.
                   
If SC1->C1_APROV <> 'B'
	lContinua	:= .F.
	_lRet		:= .F.
	
	aProbl := {}
	aAdd(aProbl, "Esta solicita��o n�o pode ser alterada.")
	
	aSoluc := {}
	aAdd(aSoluc, "Solicita��es com status Rejeitada ou Aprovada, n�o podem ser alteradas.")
	
	aMensagem := {"A��o N�o Permitida", aProbl, aSoluc}

	U_ITMsHTML(aMensagem)
EndIf

If lContinua
	//================================================================================
	//| Verifica se o usu�rio Logado � o Aprovador da SC posicionada                 |
	//================================================================================ 
	If  SC1->C1_I_CODAP <> _cUsu 
		DBSelectArea("ZZ7")
		ZZ7->(DBSetOrder(1))
		If ZZ7->(DBSeek(xFilial("ZZ7") + SC1->C1_I_CODAP))
			If _cUsu == ZZ7->ZZ7_APRSUB
				If DDATABASE < ZZ7->ZZ7_DTSUBI .Or. DDATABASE > ZZ7->ZZ7_DTSUBF
					_lRet := .F.
	
					aProbl := {}
					aAdd(aProbl, "Usu�rio logado est� fora da vig�ncia no cadastro de Aprovadores.")
	
					aSoluc := {}
					aAdd(aSoluc, "Favor verificar o cadastro de Aprovadores.")
	
					aMensagem := {"Aprovador Inv�lido", aProbl, aSoluc}
	
					U_ITMsHTML(aMensagem)
				EndIf
			Else
				_lRet := .F.
	
				aProbl := {}
				aAdd(aProbl, "Usu�rio logado n�o possui permiss�o para aprovar esta solicita��o.")
	
				aSoluc := {}
				aAdd(aSoluc, "Favor verificar o cadastro de Aprovadores.")
	
				aMensagem := {"Aprovador Inv�lido", aProbl, aSoluc}
	
				U_ITMsHTML(aMensagem)
			EndIf
		Else
			_lRet := .F. 
	
			aProbl := {}
			aAdd(aProbl, "Usu�rio logado n�o existe no cadastro de Aprovadores.")
	
			aSoluc := {}
			aAdd(aSoluc, "Favor verificar o cadastro de Aprovadores.")
	
			aMensagem := {"Aprovador Inv�lido", aProbl, aSoluc}
	
			U_ITMsHTML(aMensagem)
		EndIf
	EndIf
EndIf

RestArea(_aArea)
Return (_lRet)