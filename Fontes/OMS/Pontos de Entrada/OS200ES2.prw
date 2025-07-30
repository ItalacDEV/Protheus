/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 10/02/2017 | Inclus�o de rotina para grava��o de dados nas tabelas de muro para integra��o de exclus�o
                  |            | de carga Italac x RDC. Chamado 16681
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 10/05/2017 | Desativa��o da rotina de grava��o das tabelas de muro com os dados de estorno de cargas
                  |            | realizados manualmente, na integra��o com o RDC. Chamado 16681
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 11/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "RWMAKE.ch"

/*
===============================================================================================================================
Programa----------: OS200ES2
Autor-------------: Tiago Correa Castro
Data da Criacao---: 28/01/2009
===============================================================================================================================
Descri��o---------: Ponto de Entrada executado no final do estorno da Montagem da Carga
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function OS200ES2()

Local aArea      := GetArea()
Local cCarga     := DAK->DAK_COD  
Local _cTpCarga  := DAK->DAK_I_TPFR

_lUsuConfirmou   :=.T.//Variavel PRIVATE usada no rdmake OM200MNU.PRW para saber se o usuario confirmou o estorno - Projeto de unifica��o de pedidos de TN

//================================================================================
// Gravar neste ponto os dados da tabela de muro para estorno de carga na
// Integra��o Webserce Italac x RDC.
//================================================================================      

//================================================================================
// Deleta registros relacionados ao frete.
//================================================================================      
DBSelectArea("ZZ2") 	// Posicionando no cabecalho do recibo
ZZ2->( DBSetORder(2) )	// ZZ2_FILIAL+ZZ2_CARGA
If ZZ2->( DBSeek( xFilial("ZZ2") + cCarga ) )

	//================================================================================
	// Deletando cabecalho do recibo
	//================================================================================
	ZZ2->( RecLock( "ZZ2" , .F. ) )
	ZZ2->( DBDelete() )
	ZZ2->( MsUnLock() )
	
	//================================================================================
	// Posiciona Itens do recibo
	//================================================================================
	DBSelectArea("ZZ3")
	ZZ3->( DBSetOrder(1) ) //ZZ3_FILIAL+ZZ3_RECIBO+ZZ3_CARGA+ZZ3_DOC+ZZ3_SERIE
	If ZZ3->( DBSeek( xFilial("ZZ3") + ZZ2->ZZ2_RECIBO + cCarga ) )
	
		//================================================================================
		// Deletando itens do recibo
		//================================================================================
		While ZZ3->( !Eof() ) .And. ZZ3->( ZZ3_FILIAL + ZZ3_RECIBO + ZZ3_CARGA ) == xFilial("ZZ3") + ZZ2->( ZZ2_RECIBO + ZZ2_CARGA )
		
			ZZ3->( RecLock( "ZZ3" , .F. ) )
			ZZ3->( DBDelete() )
			ZZ3->( MsUnlock() )
			
		ZZ3->( DBSkip() )
		EndDo
		
	EndIf
                                
Else                        

	//================================================================================
	// Se for Igual a Autonomos o tipo da carga
	//================================================================================
	If  _cTpCarga == '1'
		
		//================================================================================
		// CASO NAO ENCONTRE UM CARGA PARA SER ESTORNADA
		//================================================================================
		xmaghelpfis(	"Aten��o!"																		,;
						"N�o foi poss�vel identificar o recibo da carga: "+ cCarga +" NA TABELA ZZ2"	,;
						"Informar a ocorr�ncia para a �rea de TI/ERP."									 )
		
   	EndIf
   	
EndIf

RestArea(aArea)

Return()