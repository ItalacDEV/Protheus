#include "Protheus.ch"

#DEFINE _ENTER CHR(13)+CHR(10)

/*
�������������������������������������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������������������������������������ͻ��
���Programa  �F450CAES  � Autor � Fabiano Dias da Silva � Data da Criacao  � 20/04/2011                						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Descricao �Ponto de entrada utilizada para verificar no momento de um cancelamento ou estorno de uma compensacao em      ���
���			 �carteira se os titulos a receber geraram comissao e esta se encontra com o status fechada, para que desta		���
���			 �forma seja inviabilizado este estorno ou cancelamento.												    	���
���������������������������������������������������������������������������������������������������������������������������͹��
���Uso       � 																						                        ���
���          �                                                                                       						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Parametros�                                                                                       						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Retorno   � 0 - Nao podera ser realizada a exclusao ou estorno da compensacao entre carteiras.                           ���
���			 � 1 - Gravar o Cancelamento/Estorno														                    ���
���������������������������������������������������������������������������������������������������������������������������͹��
���Usuario   �                                                                                          					���
���������������������������������������������������������������������������������������������������������������������������͹��
���Setor     � Financeiro                                                                               					���
���������������������������������������������������������������������������������������������������������������������������͹��
���            			          	ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL                   						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Autor     � Data     � Motivo da Alteracao  				               �Usuario(Filial+Matricula+Nome)    �Setor        ���
���������������������������������������������������������������������������������������������������������������������������ĺ��
���----------�----------�--------------------------------------------------�----------------------------------�-------------���
���������������������������������������������������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������������������������������������
*/ 

User Function F450CAES()     
                                
Local _aArea    := GetArea()    

Local _cAliasSE5:= ""
Local _cAliasSE3:= ""

Local _cTitComis:= ""

Local _cNumComp := PARAMIXB[1]//Numero da Compensacao
Local _nRetorno := PARAMIXB[2]//0 - Nao podera ser realizada a exclusao ou estorno da compensacao entre carteiras

If _nRetorno <> 0
	/*
	//���������������������������������������������������������������Ŀ
	//�Verifica os dados dos titulos a receber na tabela SE5 de acordo�
	//�com a compensacao informada para cancelamento ou estorno       �
	//�����������������������������������������������������������������
	*/  
	_cAliasSE5:= GetNextAlias()   
	
	querys(1,_cAliasSE5,_cNumComp,"","","","","","")
	
	dbSelectArea(_cAliasSE5)
	(_cAliasSE5)->(dbGotop())	                          	
	/*
	//��������������������������������������������������������Ŀ
	//�Percorre todos os titulos que compoem a compensacao para�
	//�verificar o status da comissao.                         �
	//����������������������������������������������������������
	*/
	While (_cAliasSE5)->(!Eof())      
	
		_cAliasSE3:= GetNextAlias()
	    
		querys(2,_cAliasSE3,"",(_cAliasSE5)->E5_NUMERO,(_cAliasSE5)->E5_PARCELA,;
		      (_cAliasSE5)->E5_PREFIXO,(_cAliasSE5)->E5_TIPO,(_cAliasSE5)->E5_CLIFOR,(_cAliasSE5)->E5_LOJA)    
		      
		dbSelectArea(_cAliasSE3)		      
		(_cAliasSE3)->(dbGoTop())		                           		
		/*
		//�����������������������������������������������������������������������Ŀ
		//�Nao podera ser realizado o estorno ou cancelamento da compensacao      �
		//�entre carteiras uma vez que a comissao gerarada a partir da compensacao�
		//�ja se encontra com o status fechada.                                   �
		//�������������������������������������������������������������������������
		*/
		If (_cAliasSE3)->NUMREG > 0
		
			_cTitComis += _ENTER + '[Filial]:'   + xFilial("SE5") +;
			                       ' [Prefixo]:' + AllTrim((_cAliasSE5)->E5_PREFIXO) +;
			                       ' [Tipo]:'    + AllTrim((_cAliasSE5)->E5_TIPO) +;
			                       ' [Titulo]:'  + (_cAliasSE5)->E5_NUMERO +;
			                       ' [Parcela]:' + (_cAliasSE5)->E5_PARCELA		
		EndIf    		                            		
		/*
		//�����������������������������������������������������������������Ŀ
		//�Finaliza a area criada anteriormente para consulta das comissoes.�
		//�������������������������������������������������������������������
		*/
		dbSelectArea(_cAliasSE3)		      
		(_cAliasSE3)->(dbCloseArea())
	     
	(_cAliasSE5)->(dbSkip()) 
	EndDo	        	
	/*
	//���������������������������������������������������������������Ŀ
	//�Finaliza a area criada anteriormente para consulta dos dados do�
	//�titulo a receber referente a compensacao informada.            �
	//�����������������������������������������������������������������
	*/
	dbSelectArea(_cAliasSE5)
	(_cAliasSE5)->(dbCloseArea()) 
	
	If Len(AllTrim(_cTitComis)) > 0           

		xMagHelpFis("INFORMA��O",;
		            "O(s) titulo(s) listado(s) abaixo possui(em) comiss�o gerada e esta se encontra com o status fechada, desta forma n�o ser� poss�vel realizar o cancelamento ou estorno da compensa��o entre carteiras.",;
		            "Titulos que se encontram com problema:" + _ENTER + _cTitComis)   
		            
		_nRetorno := 0   
			Else
            	_nRetorno := 1 
	EndIf

EndIf

restArea(_aArea)

Return(_nRetorno)

/*
�������������������������������������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������������������������������������ͻ��
���Programa  �querys    � Autor � Fabiano Dias da Silva � Data da Criacao  � 20/04/2011                						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Descricao � Funcao utilizada para gerar as querys do fonte F450CAES.	 												    ���
���			 � 																										    	���
���������������������������������������������������������������������������������������������������������������������������͹��
���Uso       � 																						                        ���
���          �                                                                                       						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Parametros�                                                                                       						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Retorno   � 													  		                                                    ���
���			 �														                                   						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Usuario   �                                                                                          					���
���������������������������������������������������������������������������������������������������������������������������͹��
���Setor     � Financeiro                                                                               					���
���������������������������������������������������������������������������������������������������������������������������͹��
���            			          	ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL                   						���
���������������������������������������������������������������������������������������������������������������������������͹��
���Autor     � Data     � Motivo da Alteracao  				               �Usuario(Filial+Matricula+Nome)    �Setor        ���
���������������������������������������������������������������������������������������������������������������������������ĺ��
���----------�----------�--------------------------------------------------�----------------------------------�-------------���
���������������������������������������������������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������������������������������������
*/ 

Static Function querys(_nOpcao,_cAlias,_cNumComp,_cNumTit,_cParcela,_cPrefixo,_cTipo,_cCliente,_cLoja)  

Local _cFiltro:= "%"

	Do Case
	    /*
		//����������������������������������������������������������������Ŀ
		//�Query utilizada para verificar os dados dos titulos que compoem �
		//�a compensacao.                                                  �
		//������������������������������������������������������������������
		*/
		Case _nOpcao == 1    
		
		    _cFiltro += " AND E5_FILIAL =  '"  + xFilial("SE5") + "'"
		    _cFiltro += " AND E5_IDENTEE =  '" + _cNumComp      + "'"
		    _cFiltro += "%"
		   
			BeginSql alias _cAlias 
				SELECT
				      E5_NUMERO,E5_PARCELA,E5_PREFIXO,E5_TIPO,E5_CLIFOR,E5_LOJA
				FROM
				      %table:SE5%
				WHERE
				      D_E_L_E_T_ = ' '
				      AND E5_RECPAG = 'R'
				      AND E5_MOTBX = 'CEC'
				      AND E5_SITUACA <> 'C'
					  %exp:_cFiltro%
			EndSql
			     				            			
		/*
		//�����������������������������������������������������������������Ŀ
		//�Query para verifica se foi gerada comissao para o titulo corrente�
		//�e se esta encontra-se com o status fechada.                      �
		//�������������������������������������������������������������������
		*/
		Case _nOpcao == 2 	
		
			_cFiltro += " AND E3_FILIAL = '"  + xFilial("SE3") + "'"  
			_cFiltro += " AND E3_NUM = '"     + _cNumTit       + "'"
		    _cFiltro += " AND E3_PARCELA = '" + _cParcela      + "'"
			_cFiltro += " AND E3_PREFIXO = '" + _cPrefixo      + "'"
		    _cFiltro += " AND E3_TIPO = '"    + _cTipo         + "'"
		    _cFiltro += " AND E3_CODCLI = '"  + _cCliente      + "'"
		    _cFiltro += " AND E3_LOJA = '"    + _cLoja         + "'"
		    _cFiltro += "%"
		
			BeginSql alias _cAlias			
				SELECT
				      COUNT(*) NUMREG
				FROM
				      %table:SE3%
				WHERE
				      D_E_L_E_T_ = ' '
				      AND E3_I_FECH = 'S'
			          %exp:_cFiltro%
			EndSql
	
	EndCase

Return