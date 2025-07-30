#include "protheus.ch"
#include "rwmake.ch"
/*/
�������������������������������������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������������������������������������ͻ��
���Programa  � AOMS008  � Autor � Frederico O. C. Jr    � Data da Criacao  � 01/08/2008                						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Descricao �   Validacao Generico de Gatilho no SA1 (Cad. Cliente) - Referente a campo de Municipio e CEP 				���
���          � 															                               						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Uso       �   No preenchimento dos campos de Cod. Municipio e CEP, tem-se gatilhos que validam a replicacao destas 		���
���          � informacoes para os campos Cod. Municipio de Cobranca e CEP de cobranca.										���
���          � 															                               						���
���          � 	1 - Gatilho A1_COD_MUN	- 001								                               					���
���          � 	2 - Gatilho A1_CEP		- 003													                       		���
���          � 	3 - Gatilho A1_END		- 001													                       		���
���          � 	4 - Gatilho A1_BAIRRO	- 001													                       		���
���          � 															                               						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Parametros� 1 - Tratamento gatilho A1_COD_MUN						                               						���
���			 � 2 - Tratamento gatilho A1_CEP						                                   						���
���			 � 3 - Tratamento gatilho A1_END						                                   						���
���			 � 4 - Tratamento gatilho A1_BAIRRO						                                   						���
���			 �														                                   						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Retorno   � 1 - A1_MUN (Atualiza internamente A1_I_CMUNC e A1_MUNC)	                               						���
���			 � 2 - A1_CEPC											                                   						���
���			 � 3 - A1_ENDCOB										                                   						���
���			 � 4 - A1_BAIRROC										                                   						���
���			 �														                                   						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Usuario   �															                             						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Setor     � OMS			                                                                          						���
���������������������������������������������������������������������������������������������������������������������������͹��
���            						ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL                   						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Autor     � Data     � Motivo da Alteracao  				               �Usuario(Filial+Matricula+Nome)    �Setor        ���
���������������������������������������������������������������������������������������������������������������������������Ĺ��
���          �          �                    							   �                                  � 			���
���������������������������������������������������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������������������������������������
/*/ 
User Function AOMS008(nVal)

	Local aArea 	:= GetArea()
	Local cRet	:= ""
	
	if (nVal == 1)

		cRet := Posicione("CC2", 1, xFilial("CC2")+M->A1_EST+M->A1_COD_MUN, "CC2_MUN")
	
		if ( empty(M->A1_I_CMUNC) )
			M->A1_I_CMUNC	:= Posicione("CC2", 1, xFilial("CC2")+M->A1_ESTC+M->A1_COD_MUN, "CC2_CODMUN")
			M->A1_MUNC		:= Posicione("CC2", 1, xFilial("CC2")+M->A1_ESTC+M->A1_I_CMUNC, "CC2_MUN")
		endif

	elseif (nVal == 2)

		if ( empty(M->A1_CEPC) )
			cRet := Posicione("ZA5",3,xFilial("ZA5")+M->A1_ESTC+M->A1_CEP,"ZA5_CEP")
		else
			cRet := M->A1_CEPC
		endif

	elseif (nVal == 3)

		if ( empty(M->A1_ENDCOB) )
			if ( (M->A1_EST == M->A1_ESTC) .AND. (M->A1_COD_MUN == M->A1_I_CMUNC) )
				cRet := M->A1_END
			else
				cRet := M->A1_ENDCOB
			endif
		else
			cRet := M->A1_ENDCOB
		endif

	elseif (nVal == 4)

		if ( empty(M->A1_BAIRROC) )
			if ( (M->A1_EST == M->A1_ESTC) .AND. (M->A1_COD_MUN == M->A1_I_CMUNC) )
				cRet := M->A1_BAIRRO
			else
				cRet := M->A1_BAIRROC
			endif
		else
			cRet := M->A1_BAIRROC
		endif

	endif

	RestArea(aArea)

return cRet