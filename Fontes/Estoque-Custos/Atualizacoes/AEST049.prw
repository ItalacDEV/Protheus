 /*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                            
------------------------------------------------------------------------------------------------------------------------------- 
 Alex Wallauer    | 10/12/2022 | Chamado 42171. NOVO BOT�O DE IMPORTA��O DE SB2
 Lucas Borges     | 21/03/2025 | Chamado 50221. Removida func�es desnecess�rias
===============================================================================================================================
*/
#INCLUDE 'PROTHEUS.CH'

/*
===============================================================================================================================
Programa----------: AEST049
Autor-------------: Alex Wallauer
Data da Criacao---: 11/08/2022   
Descri��o---------: Cadastro Produto X CC X Convers�o, CHAMADO 40988 
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AEST049()

Local cVldAlt := "U_AEST49Val()" // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
Local aBotoes := {}

dbSelectArea("PBZ")
dbSetOrder(1)

AxCadastro("PBZ","Cadastro de Produto x Centro Custo X Convers�o",cVldExc     ,cVldAlt  ,aBotoes)

Return

/*
===============================================================================================================================
Programa----------: AEST49Val
Autor-------------: Alex Wallauer
Data da Criacao---: 11/08/2022   
Descri��o---------: VALIDACO DO CADASTRO PRODUTO X CC X CONVERSAO, CHAMADO 40988
Parametros--------: Nenhum
Retorno-----------: .T. ou .F.
===============================================================================================================================
*/  
User Function AEST49Val()

IF Inclui 
   If PBZ->(DBSEEK(xFilial("PBZ")+M->PBZ_CODIGO+M->PBZ_CUSTO))
      FWAlertWarning("Chave Produto + CC j� cadastrada","AEST04901")
   	  Return .F.
   EndIf
ENDIF

RETURN .T.
