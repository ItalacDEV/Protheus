/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
    Autor    |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------

===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "parmtype.ch"
#INCLUDE "rwmake.ch" 
#INCLUDE "TOPCONN.CH"   
#Include 'fileio.ch'

#define CRLF		Chr(13) + Chr(10)

/*
===============================================================================================================================
Programa----------: GPEA370
Autor-------------: Igor Melga�o
Data da Criacao---: 14/02/2025
===============================================================================================================================
Descri��o---------: Ponto de entrada MVC Cadastro de Cargos - Chamado 49377
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: lRet 
===============================================================================================================================
*/
User Function GPEA370()
    Local _aParam As Array
    Local _lRet As Logical
    Local _cIdPonto As Character
    Local _cIdModel As Character
	Local _oModel As Object
    Local _oObj As Object
	Local _oModelSQ3 As Object
	Local _cQ3_DESCSUM As Character
    Local _cQ3_MEMO1 As Character
    Local _cQ3_MEMO2 As Character
    Local _cQ3_MEMO3 As Character
    Local _nOperation As Numeric

    _aParam     := PARAMIXB
    _lRet       := .T.
    _cIdPonto   := ""
    _cIdModel   := ""
    _oModel     := FWModelActive()
    _oObj       := Nil
    _oModelSQ3  := Nil
    _nOperation := 0

    If _aParam <> NIL
        _oObj     := _aParam[1]
        _cIdPonto := _aParam[2]
        _cIdModel := _aParam[3]

        If _cIdPonto == "MODELPOS" //"Chamada na valida��o total do modelo."

        ElseIf _cIdPonto == "FORMPOS" //"Chamada na valida��o total do formul�rio."
			
            _nOperation := _oModel:GetOperation()
            
            If _nOperation == MODEL_OPERATION_UPDATE .OR. _nOperation == MODEL_OPERATION_INSERT
                _oModelSQ3   := _oModel:GetModel('MODELGPEA370')

                _cQ3_DESCSUM := _oModelSQ3:GetValue("Q3_DESCSUM")

        		If _lRet .And. !Empty(_cQ3_DESCSUM)
        			_lRet := U_CRMA980VCP(@_cQ3_DESCSUM  ,"Q3_DESCSUM")
        			_oModelSQ3:LoadValue('Q3_DESCSUM',_cQ3_DESCSUM )
        		EndIf

                _cQ3_MEMO1 := _oModelSQ3:GetValue("Q3_MEMO1")

        		If _lRet .And. !Empty(_cQ3_MEMO1)
        			_lRet := U_CRMA980VCP(@_cQ3_MEMO1  ,"Q3_MEMO1")
        			_oModelSQ3:LoadValue('Q3_MEMO1',_cQ3_MEMO1 )
        		EndIf

                _cQ3_MEMO2 := _oModelSQ3:GetValue("Q3_MEMO2")

        		If _lRet .And. !Empty(_cQ3_MEMO2)
        			_lRet := U_CRMA980VCP(@_cQ3_MEMO2  ,"Q3_MEMO2")
        			_oModelSQ3:LoadValue('Q3_MEMO2',_cQ3_MEMO2 )
        		EndIf

                _cQ3_MEMO3 := _oModelSQ3:GetValue("Q3_MEMO3")

        		If _lRet .And. !Empty(_cQ3_MEMO3)
        			_lRet := U_CRMA980VCP(@_cQ3_MEMO3  ,"Q3_MEMO3")
        			_oModelSQ3:LoadValue('Q3_MEMO3',_cQ3_MEMO3 )
        		EndIf
            EndIf

        ElseIf _cIdPonto == "FORMLINEPRE" //"Chamada na pr� valida��o da linha do formul�rio. " 

        ElseIf _cIdPonto == "FORMLINEPOS" //"Chamada na valida��o da linha do formul�rio."

        ElseIf _cIdPonto == "MODELCOMMITTTS" //"Chamada ap�s a grava��o total do modelo e dentro da transa��o."
        
		ElseIf _cIdPonto == "MODELCOMMITNTTS" //"Chamada apos a gravacao total do modelo e fora da transacao."

        ElseIf _cIdPonto == "FORMCOMMITTTSPRE" //"Chamada ap�s a grava��o da tabela do formul�rio."

        ElseIf _cIdPonto == "FORMCOMMITTTSPOS" //"Chamada ap�s a grava��o da tabela do formul�rio."

        ElseIf _cIdPonto == "MODELCANCEL"

        ElseIf _cIdPonto == "BUTTONBAR"
            
        EndIf
    EndIf

Return _lRet
