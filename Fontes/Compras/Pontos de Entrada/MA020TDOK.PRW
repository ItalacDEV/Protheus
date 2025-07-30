/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 18/09/2020 | Chamado 34103. Travar as transportadoras do cadastro de Fornecedores como Averbação = Sim. 
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melgaço | 30/05/2022 | Chamado 40048. Validação de caracteres inválidos. 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer| 17/01/2023 | Chamado 42562. Nova validação do campo novo A2_I_LJTRN. 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 04/09/2023 | Chamado 44731. Alterar rotina para permitir alterar o campo Averba carga(A2_I_AVERB) sempre.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#Include "protheus.ch"

/*
===============================================================================================================================
Programa----------: MA020TDOK
Autor-------------: Julio de Paula Paz
Data da Criacao---: 18/09/2020
===============================================================================================================================
Descrição---------: Ponto de Entrada que Valida a inclusão e alteração do cadastro de Fornecedores.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lRet = .T. = Validação Ok.
                          = .F. = Erros na validação.
===============================================================================================================================
*/
User Function MA020TDOK()

Local _lRet       := .T.
//Local _oModel     := FWModelActive()
//Local _nOperation := _oModel:GetOperation()

Begin Sequence

   //If M->A2_I_CLASS == "T" .And. (_nOperation == 3 .Or. _nOperation == 4)
   //   _oModel:LoadValue( 'SA2MASTER', 'A2_I_AVERB', '1' )
   //EndIf 

   If Altera .Or. Inclui
      
      _nSalvaRec:=SA2->(RECNO())
      If _lRet .AND. SA2->(FIELDPOS("A2_I_LJTRN")) <> 0 .AND. M->A2_I_LJTRN = "S" .AND. SA2->(DBSEEK(xFilial()+M->A2_COD))
         DO WHILE SA2->(!EOF()) .AND. xFilial("SA2")+M->A2_COD = SA2->A2_FILIAL+SA2->A2_COD
            IF SA2->A2_MSBLQL = '1'       .OR.;//Ignora o bloqueados
               SA2->A2_LOJA == M->A2_LOJA .OR.;//Ignora a mesma loja na alteracao
               SA2->A2_EST <> M->A2_EST        //Ignora UF diferente
               SA2->(DBSKIP())
               LOOP
            ENDIF
            IF SA2->A2_I_LJTRN = "S"
		         U_ItMsg( 'Já existe outro CNPJ marcado para troca nota nesta UF, loja: '+ SA2->A2_LOJA,"Atenção",;
		                  "Desmarque a loja "+ SA2->A2_LOJA+ " antes de habilitar este CNPJ",1,,,.T.)
               _lRet := .F.
               EXIT
            ENDIF      
            SA2->(DBSKIP())
         ENDDO
      EndIf
      SA2->(DBGOTO(_nSalvaRec))

      If _lRet .And. !Empty(Alltrim(M->A2_NOME))
         _lRet := U_CRMA980VCP(M->A2_NOME   ,"A2_NOME")
      EndIf

      If _lRet .And. !Empty(Alltrim(M->A2_NREDUZ))
         _lRet := U_CRMA980VCP(M->A2_NREDUZ   ,"A2_NREDUZ")
      EndIf

      If _lRet .And. !Empty(Alltrim(M->A2_END))
         _lRet := U_CRMA980VCP(M->A2_END   ,"A2_END")
      EndIf

      If _lRet .And. !Empty(Alltrim(M->A2_BAIRRO))
         _lRet := U_CRMA980VCP(M->A2_BAIRRO   ,"A2_BAIRRO")
      EndIf

      If _lRet .And. !Empty(Alltrim(M->A2_COMPLEM))
         _lRet := U_CRMA980VCP(M->A2_COMPLEM   ,"A2_COMPLEM")
      EndIf

      If _lRet .And. !Empty(Alltrim(M->A2_ENDCOMP))
         _lRet := U_CRMA980VCP(M->A2_ENDCOMP   ,"A2_ENDCOMP")
      EndIf

      If _lRet .And. !Empty(Alltrim(M->cA2_CONTATO))
         _lRet := U_CRMA980VCP(M->cA2_CONTATO   ,"cA2_CONTATO")
      EndIf

   EndIf

End Sequence

Return _lRet
