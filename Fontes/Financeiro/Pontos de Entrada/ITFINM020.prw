/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 25/03/2022 | Migra��o das informa��es financeiras para as tabelas FKs no Leite. Chamado 39465
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 08/10/2023 | Corrigida a grava��o das informa��es do Mix. Chamado 45186
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#Include "Protheus.ch"
#Include 'FWMVCDEF.ch'
/*
===============================================================================================================================
Programa----------: FINM020
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 27/12/2021
===============================================================================================================================
Descri��o---------: ponto de entrada MVC executado na baixa/cancelamento do Contas a Pagar
===============================================================================================================================
Parametros--------: ParamIXB -> C -> Nome da fun��o que esta sendo executada. Ex. FINM
===============================================================================================================================
Retorno-----------: lRet -> L -> .T. = Continua executando a rotina/ .F. = Nao executa a rotina.
===============================================================================================================================
*/
User Function FINM020

Local _aParam	:= PARAMIXB
Local _lRet		:= .T.
Local _oObj		:= Nil
Local _cIdPonto	:= ''
Local _cIdModel	:= ''
Local _oModelBxP:= ''
Local _cCamposE5:= ''
Local _cCampOrig:=''
Local _nPos		:=0
If _aParam <> NIL
	_oObj := _aParam[1]
	_cIdPonto := _aParam[2]
	_cIdModel := _aParam[3]
	
	If _cIdPonto == "MODELPOS" //Chamada na valida��o total do modelo.
	ElseIf _cIdPonto == "FORMPOS"//Chamada na valida��o total do formul�rio.
		If _cIdModel == 'FK2DETAIL' .And. _oObj:GetOperation() == 3 .And. (FWIsInCallStack("U_MGLT009") .Or.FWIsInCallStack("U_MGLT011") .Or. FWIsInCallStack("FINXSE5")) 
			_oObj:SetValue("FK2_L_MIX", ZLE->ZLE_COD)
			_oObj:SetValue("FK2_L_SETO", ZL2->ZL2_COD)
			If FWIsInCallStack("U_MGLT009")
				_oObj:SetValue("FK2_L_LINR", ZL3->ZL3_COD)
			EndIf
			_oModelBxP := _oObj:GetModel()

			//Grava dados da linha principal do movimento na baixa
			_cCamposE5 := AllTrim(_oModelBxP:GetValue('MASTER','E5_CAMPOS'))
			If !Empty(_cCamposE5)
				_cCamposE5 := Left(_cCamposE5,Len(_cCamposE5)-1)
				_cCamposE5 += ",{ 'E5_L_MIX', ZLE->ZLE_COD}"
				If FWIsInCallStack("U_MGLT009")
                	_cCamposE5 += ",{ 'E5_L_LINR', ZL3->ZL3_COD}"
				EndIf
				_cCamposE5 += ",{ 'E5_L_SETO', ZL2->ZL2_COD}}"
			Else
				_cCamposE5 := "{{ 'E5_L_MIX',ZLE->ZLE_COD }"
                If FWIsInCallStack("U_MGLT009")
					_cCamposE5 += ",{ 'E5_L_LINR', ZL3->ZL3_COD}"
				EndIf
				_cCamposE5 += ",{ 'E5_L_SETO', ZL2->ZL2_COD}}"
			EndIf

			//Caso existam registros auxiliares na baixa (juros/multa/acr�scimos), os campos a serem gravados devem ser passados 
			//antes do pipe(|) para a grava��o correta no registro principal
			_cCampOrig:=_cCamposE5 //-- Armazena conte�do original
			_nPos := At("|",_cCamposE5)//-- Localiza o separador do registro da baixa
			If _nPos > 0
				//-- Adiciona os campos customizados no registro da baixa
				_cCamposE5:= Substr(_cCamposE5,1,_nPos-2)//-- Pega o conte�do do registro da baixa (1 posi��o para tirar o | e outra para o })
				_cCamposE5 += ",{ 'E5_L_MIX', ZLE->ZLE_COD}"
				If FWIsInCallStack("U_MGLT009")
                	_cCamposE5 += ",{ 'E5_L_LINR', ZL3->ZL3_COD}"
				EndIf
				_cCamposE5 += ",{ 'E5_L_SETO', ZL2->ZL2_COD}}"
				//-- Aglutina os demais registros 	
				_cCamposE5 += Substr(_cCampOrig,_nPos,Len(_cCampOrig))
			EndIf
			_oModelBxP:SetValue( "MASTER","E5_CAMPOS",_cCamposE5 ) // Informando o atributo "E5_CAMPOS"
		EndIf
	ElseIf _cIdPonto == "FORMLINEPRE"//Chamada na pr� valida��o da linha do formul�rio
	ElseIf _cIdPonto == "FORMLINEPOS"//Chamada na valida��o da linha do formul�rio
	ElseIf _cIdPonto == "MODELCOMMITTTS"//Chamada ap�s a grava��o total do modelo e dentro da transa��o.
	ElseIf _cIdPonto == "MODELCOMMITNTTS"//Chamada ap�s a grava��o total do modelo e fora da transa��o.
	ElseIf _cIdPonto == "FORMCOMMITTTSPRE"//Chamada ap�s a grava��o da tabela do formul�rio.
	ElseIf _cIdPonto == "FORMCOMMITTTSPOS"//Chamada ap�s a grava��o da tabela do formul�rio.
	ElseIf _cIdPonto == "MODELCANCEL"
	ElseIf _cIdPonto == "BUTTONBAR"
	EndIf
EndIf

Return _lRet
