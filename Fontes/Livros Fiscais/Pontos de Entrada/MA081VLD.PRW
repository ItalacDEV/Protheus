/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           |
-------------------------------------------------------------------------------------------------------------------------------
===============================================================================================================================
*/


/*
===============================================================================================================================
Programa--------: MA081VLD()
Autor-----------: ALEX WALLAUER
Data da Criacao-: 01/02/2019
===============================================================================================================================
Descrição-------: P.E. para validacao dos dados da TES  - chamado 27890
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: .T. OU .F.
===============================================================================================================================*/
USER FUNCTION MA081VLD()

// Quando F4_DUPLIC = 'N' .and. M->F4_UPRC = 'S'  ===========>  "Para TES que NÂO geram financeiro o campo atualiza preço de compra deveria estar também como "NÃO", deseja de continuar? "
	If M->F4_TIPO = 'E' .AND. M->F4_DUPLIC = 'N' .AND. M->F4_UPRC = 'S' .AND. !U_ITMSG('Para TES que NÂO geram financeiro o campo atualiza preço de compra deveria estar também como "NÃO", deseja de continuar ?','Atenção!',,3,2,2)
	   RETURN .F.
	ENDIF

// Quando F4_DUPLIC = 'S' .and. M->F4_UPRC = 'N'  ===========>  "Para TES que GERAM financeiro o campo atualiza preço de compra deveria estar com preenchido com "SIM", deseja de continuar?"
	If M->F4_TIPO = 'E' .AND. M->F4_DUPLIC = 'S' .AND. M->F4_UPRC = 'N' .AND. !U_ITMSG('Para TES que GERAM financeiro o campo atualiza preço de compra deveria estar com preenchido com "SIM", deseja de continuar?','Atenção!',,3,2,2)
	   RETURN .F.
	ENDIF

//TES de saida (F4_TIPO = 'S') realizar a validação somente se F4_UPRC = 'S', caso esteja apresentar a seguinte mensagem: "Para TES de saida o campo atualiza preço deveria estar preenchido como "NAO", deseja continuar?"
	If M->F4_TIPO = 'S' .AND. M->F4_UPRC = 'S' .AND. !U_ITMSG('Para TES de saida o campo atualiza preço deveria estar preenchido como "NAO", deseja de continuar?','Atenção!',,3,2,2)
	   RETURN .F.
	ENDIF

RETURN .T.
