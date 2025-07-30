/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     |31/07/2017| Chamado 20777. Virada de versão da P11 para a versão P12. Ajustes no fonte para a versão P12. 
Julio Paz     |05/09/2017| Alterar a rotina de gravação da alteração de serviços para replicar os dados gravados na tabela
              |          | SC7 para a tabela SC1.
Lucas Borges  |09/10/2024| Chamado 48465. Retirada manipulação do SX1
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina. 
//====================================================================================================
#INCLUDE "PROTHEUS.CH"
/*
===============================================================================================================================
Programa----------: ACOM018
Autor-------------: Josué Danich Prestes
Data da Criacao---: 12/07/2016
Descrição---------: Altera produto tipo serviço do pedido de compras
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM018()
Local _aOrd := SaveOrd({"SC1"})

//Valida se pedido de compra não está eliminado por residuo
If SC7->C7_RESIDUO == 'S'

	messagebox("Pedido eliminado por residuo!", "Alerta", 48)
	Return
	
Endif

//Valida se pedido já teve entrega
If SC7->C7_QUJE > 0 .OR. SC7->C7_QTDACLA > 0

	messagebox("Pedido já teve entregas realizadas!", "Alerta", 48)
	Return
	
Endif


//Valida se produto posicionado é serviço
If posicione("SB1",1,xfilial("SB1")+SC7->C7_PRODUTO,"B1_GRUPO") != '1000'

	messagebox("Produto não é tipo serviço!", "Alerta", 48)
	
Else
	
	If Pergunte("ACOM018",.T.)

		If posicione("SB1",1,xfilial("SB1")+Alltrim(MV_PAR01),"B1_GRUPO") != '1000'
		
			Messagebox("Produto escolhido não é tipo serviço!", "Alerta", 48)
			
		Else
            //==============================================================================================
            // Atualizando a tabela SC7
            //==============================================================================================
			Reclock("SC7",.F.)
			SC7->C7_PRODUTO := Alltrim(MV_PAR01)
			SC7->C7_DESCRI	:= SB1->B1_DESC
			SC7->C7_I_DESCD	:= SB1->B1_I_DESCD
			SC7->( Msunlock() )
			
			//==============================================================================================
            // Atualizando a tabela SC1
            //==============================================================================================
            SC1->(DbSetOrder(1)) // C1_FILIAL+C1_NUM+C1_ITEM 
            If SC1->(DBSeek(SC7->(C7_FILIAL+C7_NUMSC+C7_ITEMSC)))
               SC1->(Reclock("SC1",.F.))
			   SC1->C1_PRODUTO := Alltrim(MV_PAR01)
			   SC1->C1_DESCRI  := SB1->B1_DESC			   
			   SC1->( Msunlock() )
            EndIf
            			
			Messagebox("Produto atualizado com sucesso!", "Alerta", 64)
			
		Endif
		
		//===========================================================================
       // Grava log de acesso a rotina de alteração de serviço do pedido de compras. 
       //=========================================================================== 
       U_ITLOGACS('ACOM018')
		
		
	Endif

EndIf

RestOrd(_aOrd)

Return
