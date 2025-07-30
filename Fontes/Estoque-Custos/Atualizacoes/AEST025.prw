/*/
�������������������������������������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������������������������������������ͻ��
���Programa  � AEST025  � Autor � Fabiano Dias da Silva � Data da Criacao  � 11/02/2011                						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Descricao � Rotina utilizada no item modo de edicao dos campos: D1_NFORI,D1_SERIORI,D1_ITEMORI para possibilitar somente	���
���          � aos usuarios cadastrados no parametro IT_NFDUSU efetuar a alteracao dos campos citados acima.				���
���������������������������������������������������������������������������������������������������������������������������͹��
���Uso       � Para evitar problemas com notas amarradas incorretamente.				   							 		���
���          � 																												���
���          � 															                               						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Parametros� Nenhum 													                               						���
���			 �														                                   						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Retorno   � Nenhum													                               						���
���			 �	  																											���
���			 �														                                   						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Usuario   �															                             						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Setor     � Estoque                                          	                                 						���
���������������������������������������������������������������������������������������������������������������������������͹��
���            						ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL                   						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Autor     � Data     � Motivo da Alteracao  				               �Usuario(Filial+Matricula+Nome)    �Setor        ���
���������������������������������������������������������������������������������������������������������������������������Ĺ��
��� Talita   � 19/07/13 �Alterado a valida��o que era feita pelo parametro � 92-000300-TALITAT				  � TI			���
���          �          �IT_NFDUSU para que seja feito pelo campo 		   �                                  � 			���
���          �          �ZZL_NFDUSU da rotina de gest�o de usuario. 	   �                                  � 			���
���          �          �Chamado: 3804                   				   �                                  � 			���
���������������������������������������������������������������������������������������������������������������������������Ĺ��
��� Erich    � 16/09/13 �alterado para verificar outros tipos de notas e   � 92-000309-ERICHM                 � TI          ���
��� Buttner  �          �para contemplar os pedidos de vendas              �                                  �             ���
���          �          �CHAMADO 4224                                      �                                  �             ���
���������������������������������������������������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������������������������������������
/*/

User Function AEST025()   

Local _lRet:= .F.
Local cUser:=""  
Local cTip:= If (FunName() == 'MATA410', M->C5_TIPO, cTipo) // ACRESCENTADO POR ERICH BUTTNER DIA 13/09/13 - VERIFICAR QUAL A FUN��O ESTA CHAMANDO A VALIDA��O E GRAVAR O TIPO NA VARIAVEL cTipo

If cTip == "D"	//"At� o momento n�o � poss�vel bloquear os complementos, pois n�o foi poss�vel separar os complementos de compra/venda dos de 
					//devolu��o de compras/vendas. Para os complementos de devolu��o de compra/venda, o fornecedor � cadastrado como cliente e 
					//vice-versa, fazendo com que a rotina para buscar a nota de origem n�o consiga localizar a informa��o, sendo necess�rio inform�-la 
					//manualmente."
			cUser := U_UCFG001(1) 
	
	DbSelectArea("ZZL")  // Altera��o - Talita - 19/07/13 - Alterado a valida��o que era feita pelo parametro IT_NFDUSU para que seja feito pelo campo ZZL_NFDUSU da rotina de gest�o de usuario. Chamado: 3804
	DbSetOrder(1)
	DbSeek(xFilial("ZZL")+cUser)
	  	//If U_UCFG001(1) $ GETMV("IT_NFDUSU") 
	If ZZL->ZZL_NFDUSU == 'S'
		_lRet:= .T.    	
	EndIf  
	
Else      	
	_lRet:= .T.
EndIf

Return _lRet