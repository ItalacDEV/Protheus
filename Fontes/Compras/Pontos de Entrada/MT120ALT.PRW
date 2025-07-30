/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
       Autor    |    Data    |                                             Motivo                                            
-------------------------------------------------------------------------------------------------------------------------------
 Talita Teixeira| 05/03/2014 | Chamado 5603. Incluida validação para que se permita a copia de pedidos finalizados. 
-------------------------------------------------------------------------------------------------------------------------------
 Darcio Sporl   | 02/12/2015 | Chamado 11831 e 11737. Liberação Gestor de Compras e informar o grupo para liberação. 																		   
-------------------------------------------------------------------------------------------------------------------------------
 Darcio Sporl   | 21/01/2016 | Chamado 13800. Foi efetuada a correção para liberação dos pedidos para alteração. 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer  | 22/10/2018 | Chamado 26721. Criada tela para selecionar a Moeda. 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer  | 01/11/2019 | Chamado 30987. Validação de existe a taxa na copia tb. 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer  | 18/12/2023 | Chamado 45875. Nova validação para pedidos bloqueados e Rejeitados pelo Worflow de Compras
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz      | 13/05/2024 | Chamado 47221. Ajustar Rotina de Compras para tabalhar com a nova moeda Libras Esterlinas. 
===============================================================================================================================
*/
#include "Protheus.ch"
#include "TopConn.ch"
/*
===============================================================================================================================
Programa--------: MT120ALT
Autor-----------: Talita Teixeira
Data da Criacao-: 20/02/2014
===============================================================================================================================
Descrição-------: P.E. que valida antes das telas de manutenção do Pedido de compra. (MATA120)
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
STATIC nAviso

User Function MT120ALT(_cRetorno) 
Local aArea		:= GetArea()
Local lExecuta 	:= .T. 
Local cPedido	:= SC7->C7_NUM
Local nContador	:= 0   
Local _cMensagem:= ""
DEFAULT _cRetorno:="PADRAO"

IF _cRetorno = "RETORNA_OPCAO_AVISO" 
   Return nAviso
ENDIF

If Paramixb[1] == 4 .And. !IsInCallStack('A120COPIA') //ProcName(3) <> 'A120COPIA'  //05/03/14 - Talita Teixeira - Incluida validação para que se permita a copia de pedidos finalizados, sendo assim o bloqueio só acontecerá na alteração do pedido. Chamado: 5603 
	   
	DbSelectArea("SC7")
	DbSetOrder(1)//Filial+Numero+Item+Sequencia 
	SC7->(DbGotop())
	DbSeek (xFilial("SC7")+cPedido) 
		
	While (!EOF()) .And. cPedido == SC7->C7_NUM
		If SC7->C7_QUANT <> (SC7->C7_QUJE + SC7->C7_QTDACLA) .And. SC7->C7_RESIDUO <> "S"
			nContador++ 
		EndIf
		SC7->(Dbskip())
	EndDo 
	   
	If nContador == 0
		U_ITMSG("Não é permitida a alteração de pedido finalizado.",,,3)
		lExecuta:= .F.
	EndIf    
	DbSeek(xFilial("SC7")+cPedido)
    _cMensagem:=""
    IF lExecuta .AND. SCR->(DBSEEK(xfilial("SCR")+"PC"+ALLTRIM(cPedido) ))
       DO WHILE SCR->(!EOF()) .AND. xfilial("SCR")+"PC"+ALLTRIM(cPedido) == SCR->CR_FILIAL+SCR->CR_TIPO+ALLTRIM(SCR->CR_NUM)
          IF SCR->CR_STATUS = "04"
             _cMensagem:="Bloqueado pelo Worflow de Compras. (Bloqueado por "+ALLTRIM(POSICIONE("SAK",1,xfilial("SAK")+SCR->CR_APROV,"AK_NOME"))+" ("+SCR->CR_GRUPO+")"
	    	 EXIT
          ENDIF
          IF SCR->CR_STATUS = "06"
             _cMensagem:="Rejeitado pelo Worflow de Compras. (Rejeitado por "+ALLTRIM(POSICIONE("SAK",1,xfilial("SAK")+SCR->CR_APROV,"AK_NOME"))+" ("+SCR->CR_GRUPO+")"
	    	 EXIT
          ENDIF
          SCR->(DBSKIP()) 
       ENDDO
	   IF !EMPTY(_cMensagem)
          U_ITMSG("Não é permitida a alteração de Pedido "+_cMensagem,"Atenção","Procure o Gestor de compras.",1)
          lExecuta:= .F.
	   ENDIF
	ENDIF

ELSEIf Paramixb[1] == 3 .OR. IsInCallStack('A120COPIA') //ProcName(3) <> 'A120COPIA'//INCLUSAO E COPIA DE PC     

    //nAviso:=AVISO("MOEDAS","Qual será a moeda do Pedido de Compras?",{"REAL","DOLAR","EURO","IENE","FECHAR"},3)
    nAviso:=AVISO("MOEDAS","Qual será a moeda do Pedido de Compras?",{"REAL","DOLAR","EURO","GBP","FECHAR"},3)
    //nAviso:=AVISO("MOEDAS","Qual será a moeda do Pedido de Compras?",{"REAL","DOLAR","EURO","LIBRAS","FECHAR"},3)
    
    IF nAviso = 5
       lExecuta:= .F.
    EndIf  	  

    nAviso:=IF(nAviso>2,(nAviso+1),nAviso)
    
    IF nAviso <> 1 .AND. (!SM2->(DBSEEK(DTOS(dDataBase))) .OR.  SM2->(FIELDGET( FIELDPOS( "M2_MOEDA"+STR(nAviso,1) ) ))  = 0)
	    U_ITMSG('Taxa da moeda selecionada não casdastrada na data do sistema: '+DTOc(dDataBase),"ATENÇÃO",;
		   	    'Cadastre a taxa da moeda selecionada para data do sistema.',3)    
       lExecuta:= .F.
    ENDIF
    
EndIf  	  

RestArea(aArea)

Return (lExecuta) 
