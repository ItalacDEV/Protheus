/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 14/12/2017 | Retirada apresentação de tela de log para webservice - Chamado 22888         
 Josué Danich     | 12/09/2018 | Separação de tela de log para depois da transação - Chamado 26257             
 Lucas Borges     | 11/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===================================================================================================================================================================
Analista         - Programador     - Inicio     - Envio    - Chamado - Motivo da Alteração
===================================================================================================================================================================
Vanderlei Alves  - Alex Wallauer   - 09/06/25   - 10/06/25 - 45229   - Tratamento para validar FWIsInCallStack("U_AOMS085B") junto com FWISINCALLSTACK("U_ALTERAP")
===================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.Ch"
#INCLUDE "RwMake.ch"

/*
===============================================================================================================================
Programa----------: M440SC9I
Autor-------------: Josué Danich Prestes
Data da Criacao---: 15/02/2016
===============================================================================================================================
Descrição---------: PE na Liberação do Pedidos de Vendas
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User function M440SC9I()

Local _aSC5			:= GetArea("SC5") 
Local _aSC6			:= GetArea("SC6") 
Local _aSC9			:= GetArea("SC9") 
Local _lvalida		:= .T.

SC5->( Dbsetorder(1))
SC5->( Dbseek(SC9->C9_FILIAL+SC9->C9_PEDIDO) )

If _lvalida .and. (SC5->C5_I_BLCRE == 'L' .or. SC5->C5_I_BLCRE == " ")//Se teve liberação ou passou na avaliação de crédito na  garante que não tem bloqueio de crédito 

   SC6->( Dbsetorder(1))
   SC6->( Dbseek(SC5->C5_FILIAL+SC5->C5_NUM) )

	//Garante que vai gravar o c5_liberok
	SC5->(RecLock("SC5",.F.))
   	SC5->C5_LIBEROK := "S"
   	SC5->(MsUnlock())

	SC6->( Dbsetorder(1))
	SC6->( Dbseek(SC5->C5_FILIAL+SC5->C5_NUM) )


	If !(empty(SC9->C9_BLCRED))
				
		  SC9->(RecLock("SC9",.F.))
    
		  SC9->C9_BLCRED := " "
   
		  SC9->(MsUnlock("SC9"))
   		
		  //Faz análise e liberação de estoque pois o padrão não analisa estoque se o crédito está bloqueado
		  //Posiciona SC6 pois a função A440VerSb2 depende do SC6 posicionado para analisar o estoque
		  SC6->(DbSetorder(1))
   				   				
		  If SC6->(DbSeek(SC9->C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM)) .AND. A440VerSB2(SC9->C9_QTDLIB)
   				
			  If !(empty(SC9->C9_BLEST))
					  
			    SC6->(RecLock("SC6",.F.))
			    SC9->(RecLock("SC9",.F.))
    
			    MaAvalSC9("SC9",5,{{ "","","","",SC9->C9_QTDLIB,SC9->C9_QTDLIB2,Ctod(""),"","","",SC9->C9_LOCAL}})
			    SC9->C9_BLEST := ""
   
		        SC9->(MsUnlock())
		        SC6->(MsUnlock())
   				        
		      Endif
   	
   					
		  Endif	
   	
	Endif

Endif	

If  !FWISINCALLSTACK("U_ALTERAP") .and. !FWISINCALLSTACK("U_INCLUIC") .and. !FWISINCALLSTACK("U_AOMS085B") 
 	U_ENVSITPV() //Envia interface de situação do pedido para o RDC se for pedido RDC e grava campo de situação do pedido XFUNOMS
EndIf

Restarea(_aSC5)	
Restarea(_aSC6)	
Restarea(_aSC9)	
						
Return
