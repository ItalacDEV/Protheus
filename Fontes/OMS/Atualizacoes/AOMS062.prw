#INCLUDE "RWMAKE.CH"
#INCLUDE "TopConn.ch"
//#INCLUDE "vKey.ch"

/*/
�������������������������������������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������������������������������������ͻ��
���Programa  � AOMS062  � Autor � Erich Buttner			� Data da Criacao  � 12/03/2013                						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Descricao �  Valida��o de Bloqueio de Vendedor					   		                          						���
���          � 															                               						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Uso       � Valida��o de Bloqueio de Vendedor 																	  		���
���������������������������������������������������������������������������������������������������������������������������͹��
���Parametros� Nenhum						   							                               						���
���			 �														                                   						���
���			 �														                                   						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Retorno   � Nenhum                                   				                               						���
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

User Function AOMS062(cVend,cBlq)

Local _lRet := .T.
Local _aArea    := {}   
Local _aAlias   := {}


//����������������Ŀ
//�  Salva a area. �
//������������������
CtrlArea(1,@_aArea,@_aAlias,{"SA3"})

cQuery := " SELECT COUNT(*) NUMCLI FROM SA1010
cQuery += " WHERE (A1_VEND = '"+cVend+"' "
cQuery += " OR A1_I_VEND2 = '"+cVend+"')
cQuery += " AND D_E_L_E_T_ = ' '


cQuery := ChangeQuery(cQuery)

//�������������������������������Ŀ
//� Fecha Alias se estiver em Uso �
//���������������������������������
If Select("TRB") >0
	dbSelectArea("TRB")
	dbCloseArea()
Endif

TCQUERY cQuery New Alias "TRB"
dbSelectArea("TRB")

dbGoTop()

If TRB->NUMCLI > 0 .AND. cBlq == "1" 
		xmaghelpfis("Informa��o",;
					"O vendedor: " + cVend + '-' + SA3->A3_NOME + " Tem "+TRANSFORM(TRB->NUMCLI, "@E 9999")+" Clientes Amarrados a ele. " ,;
		           	"Favor alterar os clientes para outro vendedor antes de realizar o bloqueio. ")
		_lRet:= .F.  
EndIf

//������������������Ŀ
//� Restaura a area. �
//��������������������
CtrlArea(2,_aArea,_aAlias)

Return _lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CtrlArea � Autor � Microsiga          � Data �  00/00/00   ���
�������������������������������������������������������������������������͹��
���Descricao � Static Function auxiliar no GetArea e ResArea retornando   ���
���          � o ponteiro nos Aliases descritos na chamada da Funcao.     ���
���          � Exemplo:                                                   ���
���          � Local _aArea  := {} // Array que contera o GetArea         ���
���          � Local _aAlias := {} // Array que contera o                 ���
���          �                     // Alias(), IndexOrd(), Recno()        ���
���          �                                                            ���
���          � // Chama a Funcao como GetArea                             ���
���          � P_CtrlArea(1,@_aArea,@_aAlias,{"SL1","SL2","SL4"})         ���
���          �                                                            ���
���          � // Chama a Funcao como RestArea                            ���
���          � P_CtrlArea(2,_aArea,_aAlias)                               ���
�������������������������������������������������������������������������͹��
���Parametros� nTipo   = 1=GetArea / 2=RestArea                           ���
���          � _aArea  = Array passado por referencia que contera GetArea ���
���          � _aAlias = Array passado por referencia que contera         ���
���          �           {Alias(), IndexOrd(), Recno()}                   ���
���          � _aArqs  = Array com Aliases que se deseja Salvar o GetArea ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CtrlArea(_nTipo,_aArea,_aAlias,_aArqs)

Local _nN := 0

// Tipo 1 = GetArea()
If _nTipo == 1
	_aArea := GetArea()
	For _nN := 1 To Len(_aArqs)
		DbSelectArea(_aArqs[_nN])
		AAdd(_aAlias,{ _aArqs[_nN], IndexOrd(), Recno() })
	Next
	// Tipo 2 = RestArea()
Else
	For _nN := 1 To Len(_aAlias)
		DbSelectArea(_aAlias[_nN,1])
		DbSetOrder(_aAlias[_nN,2])
		DbGoto(_aAlias[_nN,3])
	Next
	RestArea(_aArea)
Endif

Return