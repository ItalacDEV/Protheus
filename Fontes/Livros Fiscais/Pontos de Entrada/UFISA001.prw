/*
===========================================================================================================================================================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===========================================================================================================================================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Altera��o
===========================================================================================================================================================================================================================================================

===========================================================================================================================================================================================================================================================
*/
#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'

/*
===========================================================================================================================================================================================================================================================
Programa----------: MODEL_ABA
Autor-------------: Igor melga�o
Data da Criacao---: 24/07/2025
Descri��o---------: Pontos de entradas do FISA001 Chamado:51556
Parametros--------: Nenhum
Retorno-----------: Nenhum
===========================================================================================================================================================================================================================================================
*/
USER FUNCTION MODEL_ABA()
   Local aParam := PARAMIXB

   If aParam <> NIL
      //oObj    := aParam[1]
      cIdPonto  := aParam[2]
      //cIdModel:= aParam[3]
      //lIsGrid := (Len(aParam) > 3)

      If     cIdPonto == "MODELPOS" //"Chamada na valida��o total do modelo."
      ElseIf cIdPonto == "FORMPOS" //"Chamada na valida��o total do formul�rio."
      ElseIf cIdPonto == "FORMLINEPRE"//Chamada na pr� valida��o da linha do formul�rio
      ElseIf cIdPonto == "FORMLINEPOS"//Chamada na valida��o da linha do formul�rio
      ElseIf cIdPonto == "MODELCOMMITTTS"//Chamada ap�s a grava��o total do modelo e dentro da transa��o.
      ElseIf cIdPonto == "MODELCOMMITNTTS"//Chamada ap�s a grava��o total do modelo e fora da transa��o.
      ElseIf cIdPonto == "FORMCOMMITTTSPRE"//Chamada ap�s a grava��o da tabela do formul�rio.
      ElseIf cIdPonto == "FORMCOMMITTTSPOS"//Chamada ap�s a grava��o da tabela do formul�rio.
      ElseIf cIdPonto == "MODELCANCEL"
      ElseIf cIdPonto == "BUTTONBAR"
         aRet := {}
         aAdd( aRet ,{"Relat�rio de Confer�ncia EFD" , 'Relat�rio de Confer�ncia EFD' , {|| FSA001REL() } , "Relat�rio de Confer�ncia EFD" } )
         RETURN aRet
      EndIf

   EndIf

RETURN .T.
