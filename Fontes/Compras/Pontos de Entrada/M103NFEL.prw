/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 16/05/2022 | Preencher com zeros � esquerda assim como no n�mero do documento. Chamado 40106
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: M103NFEL
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 19/08/2021
===============================================================================================================================
Descrição---------: Ponto de Entrada utilizado para inserir informa��es nas abas "Nota Fiscal Eletr�nica", "Informa��es DANFE"
					e "Informa��es Adicionais" no momento da inclus�o e da classifica��o da nota, para que as informa��es fiquem
					vis�veis no momento da digita��o da nota. Chamado 37521
===============================================================================================================================
Parametros--------: ParamIxb[1][1] -> C -> Identifica��o do campo que est� sendo validado.
					ParamIxb[1][2] -> C -> C�digo da UF digitada no campo F1_EST
					ParamIxb[1][3] -> A -> Array com o conte�do dos campos da aba Nota Fiscal Eletr�nica
					ParamIxb[3][1] -> C -> F1_NFELETR
					ParamIxb[3][2] -> C -> F1_CODNFE
					ParamIxb[3][3] -> D -> F1_EMINFE
					ParamIxb[3][4] -> C -> F1_HORNFE
					ParamIxb[3][5] -> N -> F1_CREDNFE
					ParamIxb[3][6] -> C -> F1_NUMRPS
					ParamIxb[3][7] -> C -> F1_MENNOTA
					ParamIxb[3][8] -> C -> F1_MENPAD
					ParamIxb[1][4] -> A -> Array com o conte�do dos campos da aba Informa��es DANFE
					ParamIxb[1][5] -> A -> Array com o conte�do dos campos da aba Informa��es Adicionais
===============================================================================================================================
Retorno-----------: Array multidimensional, contendo os arrays recebidos como par�metro 3, 4 e 5 contendo as informa��es 
					inseridas pelo ponto de entrada.
===============================================================================================================================
*/
User Function M103NFEL

Local _aNfEletr := Paramixb[3]
Local _aDanfe 	:= Paramixb[4]
Local _aInfAdic := Paramixb[5]

If AllTrim(cEspecie) == "NFDS"
	_aNfEletr[1] := StrZero( Val( cNFiscal ) , TamSX3('F1_DOC')[01] )
	_aNfEletr[3] := dDEmissao
EndIf
Return {_aNfEletr,_aDanfe,_aInfAdic}
