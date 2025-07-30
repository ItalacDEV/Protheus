/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Talita        | 28/01/2013 | Incluida validação para que o sistema não permita alterações das solicitações que já foram   
              |            | aprovadas.                                                                                   
-------------------------------------------------------------------------------------------------------------------------------
Talita        | 25/03/2013 | Incluído restauração da área que não estava sendo restaurada e com isso estava ocasionando   
              |            | erro conforme chamado 2962.                                                                  
-------------------------------------------------------------------------------------------------------------------------------
Darcio Ribeiro| 09/09/2015 | Incluído tratamento, onde o sistema valida se o usuário logado está cadastrado na tabela de  
              |            | Solicitantes/Aprovadores. Chamado 10999                                                      
-------------------------------------------------------------------------------------------------------------------------------
Darcio Ribeiro| 05/10/2015 | Incluído tratamento, onde o sistema valida se há comprador informado na solicitação, caso    
              |            | haja, o sistema não deixa o registro ser alterado. Chamado 10999                             
-------------------------------------------------------------------------------------------------------------------------------
Darcio Ribeiro| 14/10/2015 | Foi criada a validação, para quando a SC estiver aprovada ou rejeitada, o sistema não deixará
              |            | a SC ser excluída. Chamado 12293                                                             
-------------------------------------------------------------------------------------------------------------------------------
Darcio Ribeiro| 30/11/2015 | Foi criada uma verificação, para caso o usuário tenha selecionado a opção de cópia, o sistema
              |            | não irá fazer as validações normais. Chamado: 12945 / 12910                                  
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 19/10/2017 | Inclusão de validação na rotina de cópia de solicitação de compras, para não permitir a cópia de
              |            | solicitação de compras por usuários que não estejam cadastrados como aprovadores/solicitantes
              |            | e com situação igual a normal. Chamado: 22048.
-------------------------------------------------------------------------------------------------------------------------------
Jonathan      | 04/05/2020 | Alterar chamada "MsgBox" para "U_ITMSG". Chamado 32763
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 27/09/2022 | Ajustar mensagens nas validações das solicitação de compras. Chamado 41388.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"
#Include "RwMake.ch"

/*
===============================================================================================================================
Programa----------: MT110VLD
Autor-------------: Guilherme D. Gesualdo
Data da Criacao---: 15/08/2012
===============================================================================================================================
Descrição---------: Ponto de Entrada para verificar a linha posicionada na Solicitacao de Compra antes da selecao da acao.
                    Bloqueio de alteracao de solicitacao de compra efetuada por outro usuario.    
                    ------------------------------------------------------------------------------------------------------
                    ExecBlock: MT110VLD                   
                    Ponto: Verifica o registro posicionado antes das operacoes.
                    Parametros Enviados: Retorno Logico .T. ou .F.             
                    Observacoes: Bloqueia a alteracao da solicitacao por outro usuario
                    Retorno Esperado: .T. ou .F. 
                    ------------------------------------------------------------------------------------------------------
                    Ponto de entrada chamado na cópia da solicitação de compras quando a variável lCopia == .T.
                    Realiza uma Pré-Validação permitindo ou não a cópia da solicitação de compras.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Retorno Logico (.T. ou .F.) permitindo ou nao a alteracao.
===============================================================================================================================
*/

User Function MT110VLD()

Local ExpN1		:= Paramixb[1]
Local ExpL1		:= .T.   //Validações do ClienteReturn ExpL1
Local _aArea	:=	GetArea()
Local _cUsuAlt	:= 	__cUserID
Local _cSolic	:= SC1->C1_I_CDSOL 
Local cPedido	:= SC1->C1_NUM
Local nRecAtu	:= SC1->(Recno())
Local aMensagem	:= {}
Local aProbl	:= {}
Local aSoluc	:= {}
Local lContinua	:= .T.

PRIVATE NCONTT	:= 0

//==============================================================================
//Verifica se foi utilizada a opção de cópia, se sim, desconsidera as validações
//==============================================================================
If !lCopia 
	If ExpN1 == 6
		If SC1->C1_APROV <> 'B'
			lContinua	:= .F.
			ExpL1		:= .F.
			
			aProbl := {}
			aAdd(aProbl, "Esta solicitação não pode ser excluída.")
			
			aSoluc := {}
			aAdd(aSoluc, "Solicitações com status Rejeitada ou Aprovada, não podem ser excluídas.")
			
			aMensagem := {"Ação Não Permitida", aProbl, aSoluc}
		
			U_ITMsHTML(aMensagem)
		EndIf
	EndIf
	
	If lContinua
		//=====================================================================================================================
		// Valida se o usuário corrente existe na tabela de cadastro de solicitante e aprovadores, e se este não está bloqueado
		//=====================================================================================================================
		dbSelectArea("ZZ7")
		dbSetOrder(1)
		If !dbSeek(xFilial("ZZ7") + _cUsuAlt)
			ExpL1 := .F.
			//U_ITMSG("Solicitar ao Depto. de compras que realize o cadastro do solicitante/aprovador para usuário citado: " + __cUserID + " - " + AllTrim(UsrFullName(__cUserID)),"ATENCAO","O usuário logado não está cadastrado como Solicitante ou Aprovador, usuario: " + __cUserID + " - " + AllTrim(UsrFullName(__cUserID)),1)
			U_ITMSG("O usuário logado não está cadastrado como Solicitante ou Aprovador, usuario: " + __cUserID + " - " + AllTrim(UsrFullName(__cUserID)),"ATENCAO", "Solicitar ao Depto. de compras que realize o cadastro do solicitante/aprovador para usuário citado: " + __cUserID + " - " + AllTrim(UsrFullName(__cUserID)),1)
		Else
			If ZZ7->ZZ7_STATUS == "B"
				ExpL1 := .F.
				//U_ITMSG("Solicitar ao Depto. de compras que desbloqueie o usuário citado no cadastro de solicitantes/aprovadores: " + __cUserID + " - " + AllTrim(UsrFullName(__cUserID)),"ATENCAO","O usuário logado está Bloqueado no cadastrado de Solicitante / Aprovador, usuario: " + __cUserID + " - " + AllTrim(UsrFullName(__cUserID)),1)
				U_ITMSG("O usuário logado está Bloqueado no cadastrado de Solicitante / Aprovador, usuario: " + __cUserID + " - " + AllTrim(UsrFullName(__cUserID)),"ATENCAO", "Solicitar ao Depto. de compras que desbloqueie o usuário citado no cadastro de solicitantes/aprovadores: " + __cUserID + " - " + AllTrim(UsrFullName(__cUserID)),1)
			EndIf
		EndIf
		
		If ExpN1 = 4 .And. ExpL1 //ALTERACAO
		   	If _cSolic <> _cUsuAlt 
			 	ExpL1 := .F. 
		   	   	RestArea(_aArea)
		   		U_ITMSG("Solicitacao nao podera ser alterada, pois a mesma foi incluida pelo usuario: "+SC1->C1_I_CDSOL + " - "+AllTrim(UsrFullName(SC1->C1_I_CDSOL)),"ATENCAO","Solicitacao nao podera ser alterada, pois a mesma foi incluida pelo usuario: "+SC1->C1_I_CDSOL + " - "+AllTrim(UsrFullName(SC1->C1_I_CDSOL)),1)
		   	EndIf        
		   	
			If _cSolic = _cUsuAlt // 29/01/13 - Inicio da validação para bloquear a alteração dos pedidos que tenham sidos liberados.
		   	   
				DBSELECTAREA("SC1") 
		   	 	DBSETORDER (1)	   
		   	 	DBSEEK (XFILIAL("SC1")+SC1->C1_NUM)
		   	 	
				While SC1->(!EOF()) .And. SC1->C1_NUM = cPedido
					If SC1->C1_QUJE==0.And.(SC1->C1_COTACAO==Space(Len(SC1->C1_COTACAO)).Or.SC1->C1_COTACAO=="IMPORT").And. SC1->C1_APROV="B" 
						SC1->( DBSKIP()) 
					Else  
						SC1->( DBSKIP())
						NCONTT:=NCONTT+1  	
					EndIf  
				EndDo
		      
				IF NCONTT >=1
					ExpL1 := .F.
					U_ITMSG("Esse pedido não pode ser alterado pois possui itens liberado.","ATENCAO","Esse pedido não pode ser alterado pois possui itens liberado.",1)
				ELSE
					ExpL1 := .T.
				Endif 
			EndIf   //Fim da validação
		EndIf
		
		dbSelectArea("SC1")
		dbGoTo(nRecAtu)
		
		If !Empty(SC1->C1_CODCOMP) .And. ExpN1 == 4 .And. ExpL1
			ExpL1 := .F.
			U_ITMSG("Solicitação não poderá ser alterada, pois a mesma já possui comprador indicado.","ATENCAO","Solicitação não poderá ser alterada, pois a mesma já possui comprador indicado.",1)
		EndIf
	EndIf
Else
   //=========================================================================
   // Quando for uma cópia, valida se o usuário está cadastrado no cadastro 
   // de solicitantes.
   //=========================================================================   
   ZZ7->(DbSetOrder(1)) // ZZ7_FILIAL+ZZ7_CODUSR                                                                                                                                           
   If ! ZZ7->(DbSeek(xFilial("ZZ7")+AllTrim(__cUserId)))
      U_ItMsg("Para copiar uma solicitação de compras, você deve estar cadastrado no cadastro de Aprovadores/Solicitantes.","Atenção", ,1) 
      ExpL1 := .F.
   ElseIf AllTrim(ZZ7->ZZ7_STATUS) <> "N"
      U_ItMsg("Para copiar uma solicitação de compras, você deve estar cadastrado no cadastro de Aprovadores/Solicitantes e deve estar com situação igual a normal.","Atenção", ,1) 
      ExpL1 := .F.
   EndIf
EndIf

RestArea(_aArea) // 25/03/2013 - Talita - Incluido restauração da área que não estava sendo restaurada e com isso estava ocasionando erro conforme chamado 2962.
             
Return(ExpL1)
