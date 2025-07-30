/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: MCOM013
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 05/05/2020
===============================================================================================================================
Descri��o---------: Fun��o para replicar informa��o de linha para todos os produtores que possuem o Produtor corrente como dono
					de tanque. Chamado 32851
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MCOM013

Local _oModel	:= Nil
Local _cAlias	:= GetNextAlias()
Local _nSaveRec	:= SA2->(RECNO())
Local _cLinha	:= SA2->A2_L_LI_RO
Local _lRet		:= .T.
Local _nCountRec:= 0

If SA2->A2_I_CLASS == 'P'
	BeginSQL alias _cAlias
		SELECT R_E_C_N_O_ RECNO 
		FROM %Table:SA2%
		WHERE D_E_L_E_T_ = ' '
		AND A2_FILIAL = %xFilial:SA2%
		AND A2_L_TANQ = %exp:SA2->A2_COD%
		AND A2_L_TANLJ = %exp:SA2->A2_LOJA%
		AND A2_L_LI_RO <> %exp:SA2->A2_L_LI_RO%
	EndSQL
	Count To _nCountRec
	(_cAlias)->( DbGotop() )
	
	If MsgYesNo("Ser�o alterados "+AllTrim(Str(_nCountRec))+" produtores. Deseja replicar a linha "+_cLinha+" para todos?","MCOM01301")
		BeginTran()

			While !(_cAlias)->(EOF()) .And. _lRet
				SA2->(DBGoto((_cAlias)->RECNO))
				_oModel := FwLoadModel ("MATA020")
				_oModel:SetOperation(4)
				_oModel:Activate()
				_oModel:SetValue("SA2MASTER","A2_L_LI_RO",_cLinha )
				
				If _oModel:VldData()
					_oModel:CommitData()
				Else
				    AutoGrLog("Id do formul�rio de origem:"  + ' [' + AllToChar(_oModel:GetErrorMessage()[01]) + ']')
					AutoGrLog("Id do campo de origem: "      + ' [' + AllToChar(_oModel:GetErrorMessage()[02]) + ']')
					AutoGrLog("Id do formul�rio de erro: "   + ' [' + AllToChar(_oModel:GetErrorMessage()[03]) + ']')
					AutoGrLog("Id do campo de erro: "        + ' [' + AllToChar(_oModel:GetErrorMessage()[04]) + ']')
					AutoGrLog("Id do erro: "                 + ' [' + AllToChar(_oModel:GetErrorMessage()[05]) + ']')
					AutoGrLog("Mensagem do erro: "           + ' [' + AllToChar(_oModel:GetErrorMessage()[06]) + ']')
					AutoGrLog("Mensagem da solu��o: "        + ' [' + AllToChar(_oModel:GetErrorMessage()[07]) + ']')
					AutoGrLog("Valor atribu�do: "            + ' [' + AllToChar(_oModel:GetErrorMessage()[08]) + ']')
					AutoGrLog("Valor anterior: "             + ' [' + AllToChar(_oModel:GetErrorMessage()[09]) + ']')
					MostraErro()
					_lRet := .F.
				EndIf
				
				_oModel:DeActivate()

				(_cAlias)->(DBSkip())
			EndDo
		If !_lRet
			DisarmTransaction()
			MsgStop("Erros impediram a atualiza��o. Acione a TI!","MCOM01302")
		Else
			EndTran()
			MsgInfo("Produtores alterados com sucesso!","MCOM01303")
		EndIf
	EndIf
	SA2->(DBGoto(_nSaveRec))
Else
	MsgStop("Essa fun��o � exclusiva para Produtores!","MCOM01304")
EndIf

Return