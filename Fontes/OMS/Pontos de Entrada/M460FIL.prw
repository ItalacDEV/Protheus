/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
      Autor    |    Data    |                                             Motivo                                            
-------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich  | 16/01/2017 | Chamado 18839. Incluido filtro de troca nota para nota por pedido.                             
-------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich  | 28/03/2017 | Chamado 19489. Incluido filtro de precarga.                                                    
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 21/01/2019 | Chamado 28114. Novo Filtro da Carga de Pedidos Triangulares/U_M460CargaTriangular().  
 ------------------------------------------------------------------------------------------------------------------------------- 
 Julio Paz     | 25/03/2022 | Chamado 39566. Desenvolvimento de uma nova integra��o para receber informa��es de Vale ped�gio.  
 -------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 25/05/2023 | Chamado 43893. Ajustes no filtro para o Pedido 05 aparecer sempre.
 ===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

/*
===============================================================================================================================
Programa----------: M460FIL 
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 23/04/2010 
===============================================================================================================================
Descri��o---------: Ponto de Entrada para filtrar os dados antes da montagem MARKBROWSE no faturamento de documentos
					(Modifica��es nesse PE devem ser replicadas no M460QRY)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _cfiltro - filtro a ser aplicado via filbrowse em advpl
===============================================================================================================================
*/

User Function M460FIL()
   
Local _cFiltro:= ""
//Local _npos := SC5->(Recno())
_cFilVlPed := U_ITGETMV( 'IT_FILVLPD' , "")

//Faturamento por Pedido
If Upper(AllTrim(FUNNAME())) == 'MATA460A'  
	
  	U_M460CargaTriangular("",@_cFiltro)//Essa fun��o esta no M460QRY.PRW
	_cFiltro+= " C9_CARGA == '      ' .AND. ( POSICIONE('SC5',1,C9_FILIAL+C9_PEDIDO,'C5_I_TRCNF') <> 'S' .OR. POSICIONE('SC5',1,C9_FILIAL+C9_PEDIDO,'C5_I_OPER') = '05' ) "
	    
//Faturamento por Carga
else
		
	_cFiltro+= " C9_CARGA != '      ' .AND. DAK_I_PREC != '1' " 

    If xFilial("DAK") $  _cFilVlPed // Rotina possui controle de vale ped�gio.
       _cFiltro+= " .And. DAK_I_NRVP <> ' ' "
	EndIf 

EndIf

Return _cFiltro
