/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                            
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 28/07/20 | Nova mensagem de bloqueio de usuario. Chamado 33355
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 01/10/21 | Ajuste para não permitir executar p/ as filiais inclusas no parâmetro IT_FILIWFSA. Chamado 37893
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 06/12/21 | Nova Validacao de acesso como o campo ZZL_PEFROU . Chamado 38533
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#include 'protheus.ch'
#include 'parmtype.ch'

/*
===============================================================================================================================
Programa----------: AEST016
Autor-------------: André Lisboa
Data da Criacao---: 11/09/2017
===============================================================================================================================
Descricao---------: Chamado menu: Validar permissão de acesso a rotina de liberação de SAs conforme cadastro na tabela ZZL 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

user function AEST016()

Local _lRet  := .T.
Local _lFunc := .T.
Local cFils  := ALLTRIM(U_ItGetMv("IT_FILIWFSA","01;40"))

IF cFilAnt $  cFils .AND.  ! U_ITVACESS( 'ZZL' , 3 , 'ZZL_PEFROU' , 'S' )
	U_ITMSG("Rotina desativada para as Filiais [ "+cFils+" ]","AVISO","Aprovar via e-mail do Workflow ou atraves da Rotina: Estoque/Custos -> Atualizacoes -> Liberacao de Dctos",1)
	RETURN .F.
ENDIF

DbSelectArea("ZZL")
DbSetOrder(3)
If !DbSeek(xFilial("ZZL")+__cUserID)
	_lRet := .F.
	_lFunc := .F.
	U_ITMSG("Usuário não cadastrado","Erro","Favor abrir chamado solicitado cadastro",1)
Else
	If ZZL->ZZL_LIBSAS <> "S" .or. Empty(ZZL->ZZL_GRPAPR)
		_lRet := .F.
		_lFunc := .F.
		U_ITMSG("Usuário não cadastrado como Aprovador","Erro","Favor abrir chamado solicitado cadastro vinculando a um grupo de aprovação",1)
	Endif
Endif	

If _lFunc
	MATA107()
Endif
	
return
