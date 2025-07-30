/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
    Autor    |   Data   |                                             Motivo                                            
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich | 29/03/17 | Chamado 19514. Melhoria no filtro de précarga.
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 21/01/19 | Chamado 28114. Novo Filtro da Carga de Pedidos Triangulares. 
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich | 03/06/19 | Chamado 29486. Ajuste de filtro de pedidos triangulares por errorlog. 
------------------------------------------------------------------------------------------------------------------------------- 
Julio Paz    | 25/03/22 | Chamado 39566. Desenvolvimento de uma nova integração para receber informações de Vale pedágio.
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 25/05/23 | Chamado 43893. Ajustes no filtro para o Pedido 05 aparecer sempre.
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 11/06/24 | Chamado 47499. Jerry. Correção do filtro de pedidos triangulares que não estava filtrando. 
==============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

/*
===============================================================================================================================
Programa----------: M460QRY
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 23/04/2010 
===============================================================================================================================
Descrição---------: Ponto de Entrada para filtrar os dados antes da montagem MARKBROWSE no faturamento de documentos
					(Modificações nesse PE devem ser replicadas no M460FIL)
===============================================================================================================================
Parametros--------: paramixb -[1] - filtro sql já montado pelo padrão
===============================================================================================================================
Retorno-----------: _cquery- filtro a ser aplicado via filbrowse em SQL
===============================================================================================================================
*/

User Function M460QRY()     

Local _cQuery:=  ParamIXB[1]
Local _cFilVlPed := U_ITGETMV( 'IT_FILVLPD' , "")

//Faturamento por Pedido
If Upper(AllTrim(FUNNAME())) == 'MATA460A'  

  	U_M460CargaTriangular(@_cQuery,"")
	_cQuery+= " AND SC9.C9_CARGA = ' ' AND EXISTS (SELECT 'Y' FROM " + Retsqlname("SC5") +;
	                                                " SC5T WHERE SC5T.D_E_L_E_T_ <> '*'  AND SC5T.C5_FILIAL = SC9.C9_FILIAL AND SC5T.C5_NUM = SC9.C9_PEDIDO AND (C5_I_TRCNF <> 'S' OR C5_I_OPER = '05'))"  
    
//Faturamento por Carga
Else

	_cQuery+= " AND SC9.C9_CARGA <> ' ' AND  (SELECT DAKT.DAK_I_PREC FROM " + Retsqlname("DAK") + " DAKT WHERE DAKT.D_E_L_E_T_ <> '*'  AND DAKT.DAK_FILIAL = SC9.C9_FILIAL AND DAKT.DAK_COD = SC9.C9_CARGA) <> '1'"    

	If xFilial("DAK") $ _cFilVlPed // A filial faz parte da rotina de Vale pedagiro.
       
	   _cQuery += " AND  (SELECT DAKY.DAK_I_NRVP FROM " + Retsqlname("DAK") + " DAKY WHERE DAKY.D_E_L_E_T_ <> '*' AND DAKY.DAK_FILIAL = SC9.C9_FILIAL AND DAKY.DAK_COD = SC9.C9_CARGA) <> ' ' "    

	EndIf 

EndIf


Return _cQuery    


/*
===============================================================================================================================
Programa----------: M460CargaTriangular(_cQuery,_cFiltro)     
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 23/04/2010 
===============================================================================================================================
Descrição---------: Função para buscar os pedidos triangular da carga inidicada no MV_PAR19
===============================================================================================================================
Parametros--------: _cQuery: do filtro do SQL / _cFiltro: do filtro ADPL
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/
User Function  M460CargaTriangular(_cQuery,_cFiltro)      

LOCAL _cCargaRemessa  := MV_PAR19//DOC CHAMADO 28114 - parametro custumizado no pergunte padrão
LOCAL _cOperTriangular:= ""
LOCAL _cOperFat       := ""
LOCAL _cOperRemessa   := ""
LOCAL _cSPedidosVendas:= ""//SQL
LOCAL _cAPedidosVendas:= ""//ADVPL

//O type não pode ser usado em variavel local tem que ser direto na vairavel private
IF TYPE("MV_PAR19") == "C" .and. !EMPTY(_cCargaRemessa) //Testa tipo pois passa após o ínicio do faturamento com mv_par alterado
	
	_cOperTriangular:= ALLTRIM(U_ITGETMV( "IT_OPERTRI","05,42"))// Tipos de operações da operação trigular
	_cOperFat       := LEFT(_cOperTriangular,2) //05
	_cOperRemessa   := RIGHT(_cOperTriangular,2)//42
	SC5->(DbSetOrder(1))
	DBSELECTAREA("DAI")
	DAI->(DBSETORDER(1)) //DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN+DAI_PEDIDO
	IF DAI->(dbSeek(xFilial("DAI")+_cCargaRemessa))
		
		DO WHILE DAI->(!EOF()) .AND. ;
			     DAI->DAI_FILIAL = xFilial("DAI") .AND. DAI->DAI_COD = _cCargaRemessa
			
			If SC5->(DBSEEK(xFilial("SC9")+DAI->DAI_PEDIDO)) .AND. SC5->C5_I_OPER = _cOperRemessa //42
				_cPedVenda:=SC5->C5_I_PVFAT
				If SC5->(DBSEEK(xFilial("SC9")+_cPedVenda)) .AND. SC5->C5_I_OPER = _cOperFat//05
					_cSPedidosVendas+="'"+SC5->C5_NUM+"',"
					_cAPedidosVendas+=SC5->C5_NUM+"/"
				ENDIF
			ENDIF
			
			DAI->(dbSkip())
		ENDDO
		
	ENDIF
	IF !EMPTY(_cSPedidosVendas)  .AND. !EMPTY(_cAPedidosVendas)

        //MSSQL
		_cSPedidosVendas:=LEFT(_cSPedidosVendas,LEN(_cSPedidosVendas)-1)
		_cQuery += " AND SC9.C9_PEDIDO IN ("+_cSPedidosVendas+")"

        //ADVPL
		_cAPedidosVendas:=LEFT(_cAPedidosVendas,LEN(_cAPedidosVendas)-1)
		_cFiltro+=" C9_PEDIDO $ '"+_cAPedidosVendas+"' .AND. "

	ELSEIF !EMPTY(_cQuery)
		U_ITMSG("Carga "+_cCargaRemessa+" não possui Pedidos de Remessa",'Atenção!',"Selecione uma carga que possua Pedidos de Remessa",1)
		RETURN .F.
	ENDIF
ENDIF

RETURN .T.
