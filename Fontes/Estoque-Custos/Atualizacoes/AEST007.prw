/*                                   ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
       Autor      |    Data    |                              Motivo                       
-------------------------------------------------------------------------------------------------------------------------------
 Alexandre Villar | 30/09/2014 | Atualiza��o da rotina retirando coment�rios e refer�ncias ao par�metro que n�o est� mais em 
                                 uso. Chamado 7248
-------------------------------------------------------------------------------------------------------------------------------
 Alexandre Villar | 06/10/2014 | Corre��o do nome da vari�vel de controle do ambiente para n�o dar erro durante a valida��o. 
                                 Chamado 7664
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 22/03/2018 | Ajustes no tratamento dos niveis para o grupo "0599". Chamado 24257
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "protheus.ch"
#include "topconn.ch"
/*
===============================================================================================================================
Programa----------: AEST007
Autor-------------: Frederico O. C. Jr
Data da Criacao---: 17/07/2008
===============================================================================================================================
Descri��o---------: Validacao do usuario para inclusao/alteracao de PA e EM e  
                    "Modo Edicao" no SX3 dos campos: B1_I_NIV2, B1_I_NIV3 e B1_I_NIV4
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: L�gico - define se o usu�rio tem ou n�o acesso � alterar o campo
===============================================================================================================================
*/
User Function AEST007()

Local _aArea 	:= GetArea()
Local _cUsuario	:= RetCodUsr()
Local _lRet		:= .F.

If !( M->B1_TIPO $ "PA/EM" )

	_lRet := .T.

ELSEIf  M->B1_TIPO = "EM" .AND. M->B1_GRUPO = "0599"

	ZZL->( DBSetOrder(3) )
	If ZZL->( DBSeek( xFilial("ZZL") + _cUsuario ) ) .AND. (ZZL->(FIELDPOS("ZZL_EMBGNR")) = 0 .OR. ZZL->ZZL_EMBGNR == 'S')//Se o usuario pode digitar itens genericos (sem precisara de niveis)
		_lRet := .F.
    ELSE//Se o usuario n�o pode digitar itens genericos (tem que digitar os niveis)
		_lRet := .T.
	EndIf

Else
	
	//================================================================================
	// Talita - 15/07/13 - Alterada a valida��o para altera��o dos produtos do tipo 
	// PA/EM que era feito pelo parametro IT_CADPA e agora ser� feita na tela de 
	// gest�o de usuarios campo ZZL_CADPA. Chamado:3747
	//================================================================================
	ZZL->( DBSetOrder(3) )
	If ZZL->( DBSeek( xFilial("ZZL") + _cUsuario ) ) .And. ZZL->ZZL_CADPA == 'S'
		_lRet := .T.
	EndIf
	
EndIf

RestArea(_aArea)

Return( _lRet )