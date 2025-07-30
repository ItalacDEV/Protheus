#INCLUDE "RWMAKE.CH"

#DEFINE _ENTER CHR(13)+CHR(10)

/*/
�������������������������������������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������������������������������������ͻ��
���Programa  � FA070CA4 � Autor � Fabiano Dias da Silva � Data da Criacao  � 15/03/2011                						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Descricao � O ponto de entrada FA070CA4 sera executado apos confirmacao do cancelamento da baixa do contas a receber,    ���
���          � para diante disso efetuar o cancelamento do debito gerado na comissao da baixa.         						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Uso       � 																										        ���
���������������������������������������������������������������������������������������������������������������������������͹��
���Parametros� 															                               						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Retorno   � 																  							                    ���
���������������������������������������������������������������������������������������������������������������������������͹��
���Usuario   �                                                                                          					���
���������������������������������������������������������������������������������������������������������������������������͹��
���Setor     � OMS                                                                                				   			���
���������������������������������������������������������������������������������������������������������������������������͹��
���            			          	ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL                   						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Autor     � Data     � Motivo da Alteracao  				               �Usuario(Filial+Matricula+Nome)    �Setor        ���
���������������������������������������������������������������������������������������������������������������������������ĺ��
���          �          �                    							   �                                  �   	        ���
���������������������������������������������������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������������������������������������
/*/

User Function FA070CA4

Local _lRet     := .T.  
Local _cNumero  := SE1->E1_NUM
Local _cSerie   := IIF(SE1->E1_PREFIXO <> 'MAN',SE1->E1_PREFIXO,Space(3)) 
Local _cParcela := SE1->E1_PARCELA
Local _cTipo    := SE1->E1_TIPO
Local _cCliente := SE1->E1_CLIENTE
Local _cLoja    := SE1->E1_LOJA
Local _cSeq     := SE5->E5_SEQ  
Local _cMotBaixa:= SE5->E5_MOTBX   
    
Local _cAlias  := ""
Local _cFiltro := "%"
Local _aArea   := {}
Local _aAlias  := {}  

Local _aMes    :={"Janeiro","Fevereiro","Mar�o","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}

//����������������Ŀ
//�  Salva a area. �
//������������������
CtrlArea(1,@_aArea,@_aAlias,{"SE1","SE5","SE3","SEF"})

/*
//�����������������������������������������������������������������Ŀ
//�Verifica se o motivo da baixa foi igual a NOR, pois diante disso �
//�os titulos com baixa igual a NOR passaram por uma avaliacao      �
//�para constatar se a comissao ja foi fechada.                     �
//�������������������������������������������������������������������
*/   
If _cMotBaixa == 'NOR' 

	_cAlias:= GetNextAlias() 
		    
	/*
	//������������������������Ŀ
	//�Define filtros da query.�
	//��������������������������
	*/                         
	_cFiltro += " AND E3_FILIAL = '"  + xFilial("SE3") + "'"
	_cFiltro += " AND E3_NUM = '"     + _cNumero       + "'"
	_cFiltro += " AND E3_SERIE = '"   + _cSerie        + "'"
	_cFiltro += " AND E3_PARCELA = '" + _cParcela      + "'"
	_cFiltro += " AND E3_TIPO = '"    + _cTipo         + "'"
	_cFiltro += " AND E3_CODCLI = '"  + _cCliente      + "'"
	_cFiltro += " AND E3_LOJA = '"    + _cLoja         + "'"
	_cFiltro += " AND E3_SEQ = '"     + _cSeq          + "'"
	_cFiltro += " AND E3_I_FECH = 'S'"
	_cFiltro += " AND E3_I_ORIGE <> 'MT100AGR'" //Esta clausula foi solicitada a sua inclusao por Tiago Correa no dia 13/06/11
	_cFiltro += "%"
	
	/*
	//��������������������������������������������������������Ŀ
	//�Verifica se a comissao encontra-se com o status fechada.�
	//����������������������������������������������������������
	*/  
	BeginSql alias _cAlias	
		SELECT
	      E3_EMISSAO
		FROM
		      %table:SE3%
		WHERE
		      D_E_L_E_T_ = ' '
		      %exp:_cFiltro%				
	EndSql   
	
	dbSelectArea(_cAlias)
	(_cAlias)->(dbGotop())
	              	
	/*
	//��������������������������������������������������������������������Ŀ
	//�A baixa que esta sendo feito o cancelamento ou exclusao nao         �
	//�podera ser excluida pois a baixa encontra-se com a comissao fechada.�
	//����������������������������������������������������������������������
	*/
	If (_cAlias)->(!Eof())
	
		_lRet:= .F.	  
		
		xMagHelpFis("INFORMA��O",;
		            "N�o poder� ser realizado o cancelamento ou exclus�o da baixa do t�tulo! Pois: Essa baixa gerou comiss�o no m�s de " +;
		             _aMes[Val(SubStr((_cAlias)->E3_EMISSAO,5,2))] + " de " + SubStr((_cAlias)->E3_EMISSAO,1,4)+ " onde j� foi paga a comiss�o ao Vendedor.",;
		            "Pois o t�tulo com os dados especificados abaixo encontra-se com a comiss�o fechada. " + _ENTER  +;
		            'T�tulo: ' + _cNumero + ' - '  + 'Parcela: ' + _cParcela + ' - ' +;
		            'Prefixo: '+ _cSerie  + _ENTER  + 'Cliente: ' + _cCliente + ' - ' + 'Loja: ' + _cLoja  + _ENTER  +;
		            'Sequencia da baixa: '+ _cSeq )	 
	EndIf     
	
	
	/*
	//������������������������������������������������������������������Ŀ
	//�Verifica se podera ser realizada a exclusao da comissao de debito �
	//�gerada por uma baixa, o padrao do sistem nao trata esta questao.  �
	//��������������������������������������������������������������������
	*/  
  	If _lRet .And. _cTipo == 'NCC'         
  
		dbSelectArea("SE3")					 
		SE3->(dbOrderNickName("IT_COMISSA"))//E3_FILIAL+E3_NUM+E3_SERIE+E3_PARCELA+E3_TIPO+E3_CODCLI+E3_LOJA+E3_SEQ                                                                                           
		If SE3->(dbSeek(xFilial("SE3") + _cNumero + _cSerie + _cParcela + _cTipo + _cCliente + _cLoja + _cSeq))
		     
			While SE3->(!Eof()) .And.;
			      SE3->E3_FILIAL == xFilial("SE3") .And. SE3->E3_NUM == _cNumero .And. SE3->E3_SERIE == _cSerie .And. SE3->E3_PARCELA == _cParcela .And.;
			      SE3->E3_TIPO == _cTipo .And. SE3->E3_CODCLI == _cCliente .And. SE3->E3_LOJA == _cLoja .And. SE3->E3_SEQ == _cSeq
			        	      
					/*
					//�������������������������������������������������������������������������Ŀ
					//�Verifica se o debito da comissao foi gerado a partir da baixa de uma NCC.�
					//���������������������������������������������������������������������������
					*/
					If AllTrim(SE3->E3_I_ORIGE) == 'SACI008'
					
						RecLock("SE3",.F.) 
						
							dbDelete()
									
						SE3->(MsUnlock())     
					
					EndIf
			      	
			SE3->(dbSkip())
			EndDo      		
		EndIf   	
	EndIf          

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