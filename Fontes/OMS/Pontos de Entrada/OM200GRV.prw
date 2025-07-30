#INCLUDE "Protheus.Ch"
#INCLUDE "RwMake.ch"
#INCLUDE "TopConn.CH"
/*/
�������������������������������������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������������������������������������ͻ��
���Programa  � OM200GRV � Autor � Wodson Reis Silva     � Data da Criacao  � 03/08/2009                						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Descricao � Ponto de Entrada apos a gravacao dos campos principais do arquivo de pedidos na montagem de carga, que       ���
���          � permite ao usuario gravar seus campos especificos.                                                           ���
���          � Os campos especificos devem ser incluidos no array no ponto de entrada DL200TRB.                             ���
���		     �					 												                                            ���
���		     � Caso seja necessario adicionar mais campos a serem apresentados no Grid, proceda da seguinte forma:          ���
���		     � 1 - Campo do SC5, basta informa-lo no parametro IT_CMPCARG.                                                  ���
���		     � 2 - Campo de outra tabela, por exemplo SC6, informe o campo no parametro para que nao seja necessario editar ���
���		     �     os pontos de entrada DL200BRW e DL200TRB.                                                                ���
���		     �     Em seguida, no P.E OMS200GRV faca um If no Laco para desconsiderar algum campo que se inicie             ���
���		     �                                                                                                              ���
���		     �                                                                                                              ���
���������������������������������������������������������������������������������������������������������������������������͹��
���Uso       � Gravacao e apresentacao de campos de usuario na Grid da tela de Montagem de Carga.	                        ���
���		     �					 												                                            ���
���������������������������������������������������������������������������������������������������������������������������͹��
���Parametros� Alias da tabela para atualizacao.                                                       						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Retorno   � Nenhum.                                                           	                                        ���
���������������������������������������������������������������������������������������������������������������������������͹��
���Usuario   �                                                                                          					���
���������������������������������������������������������������������������������������������������������������������������͹��
���Setor     � Logistica                                                                               						���
���������������������������������������������������������������������������������������������������������������������������͹��
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
       Autor      |    Data    |                              Motivo                                                          |
------------------:------------:----------------------------------------------------------------------------------------------:
 Alex Wallauer    | 26/12/2016 | Ajustes da Unifica��o - Pre-Carga - Chamado 18245                                            |
===============================================================================================================================
/*/
User Function OM200GRV()

Local aArea    := GetArea()
Local aAreaPED := TRBPED->(GetArea())
Local aAreaSC5 := SC5->(GetArea())
Local aCpos    := {} //{"C5_I_EST  ","C5_I_CMUN ","C5_I_GRPVE","C5_I_OBPED","C5_VEND1  ","C5_VEND2  ","A1_NATUREZ","C6_I_QPALT","C6_PEDCLI ","C6_ENTREG "}
Local nX       := 0

IF TRBPED->(EOF()) .AND. TRBPED->(BOF())
   Return 
ENDIF
//��������������������������������������������������������������������������������������������������Ŀ
//�Arrays de controle dos campos que deverao ser mostrados no Grid da rotina de Montagem de Carga.   �
//����������������������������������������������������������������������������������������������������
aCpos := ALLTRIM(GetMv("IT_CMPCARG"))
aCpos := If(Empty(aCpos),{},&aCpos)

//���������������������������������������������������������������������Ŀ
//�Gravacao automatica dos campos informados no parametro IT_CMPCARG.   �
//�����������������������������������������������������������������������
RecLock("TRBPED",.F.)
For nX := 1 To Len(aCpos)
	//��������������������������������������������������������������������������������������������Ŀ
	//� Verifica se o campo vem da tabela SC5, caso contrario a gravacao tem que ser fora do laco. �
	//����������������������������������������������������������������������������������������������
	If Substr(aCpos[nX],1,2) == "C5"
		//������������������������������������������������������������Ŀ
		//� Tratamento para que o nome do campo nao exceda 10 digitos. �
		//� Caso exceda, trunca a ultima posicao.                      �
		//��������������������������������������������������������������
		If Len("PED"+Substr(aCpos[nX],3,Len(ALLTRIM(aCpos[nX]))-2)) > 10
			TRBPED->&("PED"+Substr(aCpos[nX],3,7)) := SC5->&("C5"+Substr(aCpos[nX],3,Len(ALLTRIM(aCpos[nX]))-2))
		Else
			TRBPED->&("PED"+Substr(aCpos[nX],3,Len(ALLTRIM(aCpos[nX]))-2)) := SC5->&("C5"+Substr(aCpos[nX],3,Len(ALLTRIM(aCpos[nX]))-2))
		EndIf
	Else
		//�����������������������������������������������������������������������������������������Ŀ
		//� Coloque aqui a gravacao dos campos que nao sao do SC5.                                  �
		//� Obs:                                                                                    �
		//�      O nome do campo no arquivo de trabalho nao pode exceder 10 caracteres,             �
		//�      logo o mesmo sera truncado nas ultimas posicoes para evitar erro, por exemplo:     �
		//�      - O campo C6_PRODUTO, ficaria no arquivo de trabalho PED_PRODUT.                   �
		//�      - O campo C6_I_QPALT, ficaria no arquivo de trabalho PED_I_QPAL.                   �
		//�                                                                                         �
		//� Dica:                                                                                   �
		//�      Cuidado para algum campo que tenha mais de 10 digitos, nao truncar e ficar com     �
		//�      nome igual ao de outro, por exemplo C6_QTDEMP ficaria PED_QTDEMP e o C6_QTDEMP2    �
		//�      tambem ficaria PED_QTDEMP. Nesse caso vc nao pode informar o campo no parametro    �
		//�      IT_CMPCARG, tera que editar os P.E DL200BRW,DL200TRB e OM200GRV manualmente.       �
		//�������������������������������������������������������������������������������������������
		/*
		TRBPED->PED_ENTREG := SC6->C6_ENTREG
		TRBPED->PED_PEDCLI := SC6->C6_PEDCLI
		TRBPED->PED_I_QPAL := SC6->C6_I_QPALT
		TRBPED->PED_NATURE := SA1->A1_NATUREZ
		*/
	EndIf
Next nX
MsUnlock()

RestArea(aArea)
RestArea(aAreaSC5)
RestArea(aAreaPED)

Return