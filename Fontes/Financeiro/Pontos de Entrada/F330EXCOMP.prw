/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Talita 	 	  | 25/03/2013 | Incluida valida��o para os casos do usuario n�o selecionar nenhum t�tulo. Chamado 2952
-------------------------------------------------------------------------------------------------------------------------------
Erich    	  | 06/09/2013 | Incluida valida��o na sequencia da baixa de titulos de compensa��o de comiss�o. Chamado 4173
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 09/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"
#DEFINE _ENTER CHR(13)+CHR(10)    

/*
===============================================================================================================================
Programa----------: F330EXCOMP
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 08/04/2011
===============================================================================================================================
Descri��o---------: Ponto de Entrada utilizado para validar a exclusao ou estorno de uma compensacao para que seja verificado
					se foi gerada comissao para os titulos que compoem a baixa e se esta encontra-se com o status fechada.
					O ponto de entrada F330EXCOMP efetua valida��es adicionais na exclus�o/estorno da compensa��o de Contas a 
					receber. Este ponto de entrada identifica atrav�s do terceiro par�metro em qual opera��o est� sendo realizada 
					(5=Estorno e 4=Exclus�o).
===============================================================================================================================
Parametros--------: Array contendo na sua estrura dois arrays (aTitulos, aRegistros e nOpcao). O array aTitulos corresponde aos 
					t�tulos marcados para estorno/exclus�o da compensa��o, enquanto o aRegistros armazena o recno de cada 
					registro na tabela SE5 com rela��o � compensa��o.E a vari�vel nOpcao cont�m o n�mero referente a opera��o 
					que est� sendo executada (5=Estorno e 4=Exclus�o).Cada array cont�m a seguinte estrutura:
					ParamIxb:[01] - aTitulos[02] - aRegistros
					aTitulos:[01] - Prefixo[02] - N�mero[03] - Parcela[04] - Tipo[05] - Loja[06] - Data[07] - Documento 
							(Pref.+Num.+Parc.+Tipo) compensado[08] - Sequ�ncia (E5_SEQ)[09] - Valor l�quido[10] - 
							Valor compensado[11] - L�gico (true)[12] - FilialaRegistros:[01] - Recno do registro na tabela SE5
===============================================================================================================================
Retorno-----------: Retorno da valida��o quando efetuado o estorno/exclus�o da compensa��o. Caso o retorno seja verdadeiro, 
					a opera��o de exclus�o/estorno ser� efetivada. Caso seja falso, a opera��o � abortada e os registros 
					permanecem �ntegros.
===============================================================================================================================
*/
User Function F330EXCOMP()

Local _aTitulos  := PARAMIXB[1]
Local _aRegistros:= PARAMIXB[2] //Armazena os R_E_C_N_O_ dos titulos que foram baixados para realizar a compensacao
Local _aTitSE3   := {} //Armazena os dados dos titulos que serao utilizados para checar se foi gerada comissao e este se encontra fechada
Local _cRecnoSE5 := "" 
Local _cAliasSE5 := GetNextAlias() 
Local _cAliasSE3 := ""
Local _cFilial   := xFilial("SE1")  
Local _cPrefixo	
Local _cDoc	
Local _cParcela
Local _cTipo
Local x			:= 0
Local _cTitComis := ""    
Local _lRet      := .T.

If LEN(_aTitulos) > 0  //25/03/2013 - Talita - Incluida a valida��o para que retorne mensagem de informa��o para quando n�o for selecionado nenhum titulo. Conforme chamado: 2952
	_cPrefixo  := _aTitulos[1][1]
	_cDoc	   := _aTitulos[1][2]
	_cParcela  := _aTitulos[1][3]
	_cTipo     := _aTitulos[1][4]
	_cSeq		:= _aTitulos[1][8]  // INCLUSO POR ERICH BUTTNER DIA 06/09/13 - VERIFICAR SEQUENCIA DAS BAIXAS DOS TITULOS

Else

	xMagHelpFis("F330EXCOMP001",;
	            "N�o foram selecionados t�tulos para exclus�o",;
	            "Para excluir a compensa��o � necessario selecionar ao menos um t�tulo")   
	            
	_lRet := .F.
                        

Return _lRet     

EndIf

aAdd(_aTitSE3,{_cFilial,_cPrefixo,_cDoc,_cParcela,_cTipo,_cSeq})// ADICIONADO POR ERICH BUTTNER DIA 06/09/13 - CAMPO DE SEQUENCIA DAS BAIXAS DE TITULOS//aAdd(_aTitSE3,{_cFilial,_cPrefixo,_cDoc,_cParcela,_cTipo}) 
     
For x:=1 To Len(_aRegistros)
	_cRecnoSE5 += ";" + AllTrim(Str(_aRegistros[x])) 
Next x 

_cRecnoSE5:= SubStr(_cRecnoSE5,2,Len(_cRecnoSE5)) 
     
//Seleciona os dados dos titulos que compoem a baixa por compensacao no titulo indicado acima
querys(1,_cAliasSE5,_cRecnoSE5)

dbSelectArea(_cAliasSE5)  
(_cAliasSE5)->(dbGotop())

While (_cAliasSE5)->(!Eof()) 

	aAdd(_aTitSE3,{;
				       (_cAliasSE5)->E5_FILORIG,;              //Filial de Origem do titulo
				       SubStr((_cAliasSE5)->E5_DOCUMEN,1,3) ,;//Prefixo do titulo
				       SubStr((_cAliasSE5)->E5_DOCUMEN,4,9) ,;//Numero do titulo
				       SubStr((_cAliasSE5)->E5_DOCUMEN,13,2),;//Parcela do titulo
				       SubStr((_cAliasSE5)->E5_DOCUMEN,15,3),; //Tipo do Titulo
				       _cSeq;
					  })

(_cAliasSE5)->(dbSkip())
EndDo            

dbSelectArea(_cAliasSE5)  
(_cAliasSE5)->(dbCloseArea())

//================================================================
//Query para verificar se foi gerada comissao para algum titulo
//que compoem a compensacao e se esta comissao encontra-se
//com o status fechada
//================================================================
For x:=1 To Len(_aTitSE3) 

	  _cAliasSE3:= GetNextAlias()	

	  querys(2,_cAliasSE3,"",_aTitSE3[x,1],_aTitSE3[x,2],_aTitSE3[x,3],_aTitSE3[x,4],_aTitSE3[x,5],_aTitSE3[x,6])// ADICIONADO POR ERICH BUTTNER DIA 06/09/13 - CAMPO DE SEQUENCIA DAS BAIXAS DE TITULOS//querys(2,_cAliasSE3,"",_aTitSE3[x,1],_aTitSE3[x,2],_aTitSE3[x,3],_aTitSE3[x,4],_aTitSE3[x,5])
	  
	  dbSelectArea(_cAliasSE3)
	  (_cAliasSE3)->(dbGotop())
	  
	  If (_cAliasSE3)->NUMREG > 1
	  
        	_cTitComis += _ENTER + '[Filial]:' + _aTitSE3[x,1] + ' [Prefixo]:' + AllTrim(_aTitSE3[x,2]) + ' [Tipo]:' + AllTrim(_aTitSE3[x,5]) + ' [Titulo]:' + _aTitSE3[x,3] + ' [Parcela]:' + _aTitSE3[x,4]
	  
	  EndIf       
	  
	  dbSelectArea(_cAliasSE3)
	  (_cAliasSE3)->(dbCloseArea())

Next x 

If Len(AllTrim(_cTitComis)) > 0           

	xMagHelpFis("F330EXCOMP002",;
	            "O(s) titulo(s) listado(s) abaixo possui(em) comiss�o gerada e esta se encontra com o status fechada, desta forma n�o ser� poss�vel realizar a exclus�o ou estorno da compensa��o.",;
	            "Titulos que se encontram com problema:" + _ENTER + _cTitComis)   
	            
	_lRet := .F.
            
EndIf            

Return _lRet       

/*
===============================================================================================================================
Programa----------: querys
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 08/04/2011
===============================================================================================================================
Descri��o---------: Funcao utilizada para gerar as querys do fonte F330EXCOMP
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function querys(_nOpcao,_cAlias,_cRecnoSE5,_cFilial,_cPrefixo,_cDoc,_cParcela,_cTipo, _cSeq)  

Local _cFiltro:= "%"

	Do Case
		//Query utilizada para verificar os dados dos titulos que compoem a compensacao.
		Case _nOpcao == 1    
		    _cFiltro += " AND R_E_C_N_O_ IN " + FormatIn(_cRecnoSE5,";")
		    _cFiltro += "%"
		
			BeginSql alias _cAlias 
				SELECT E5_FILORIG, E5_DOCUMEN
				  FROM %Table:SE5%
				 WHERE D_E_L_E_T_ = ' '
				   %exp:_cFiltro%
			EndSql		      				            			
		//Query para verifica se foi gerada comissao para o titulo corrente e se esta encontra-se com o status fechada
		Case _nOpcao == 2 	
			BeginSql alias _cAlias			
				SELECT COUNT(1) NUMREG
				  FROM %Table:SE3%
				 WHERE D_E_L_E_T_ = ' '
				   AND E3_I_FECH = 'S'
				   AND E3_FILIAL = %exp:_cFilial%
				   AND E3_PREFIXO = %exp:_cPrefixo%
				   AND E3_TIPO = %exp:_cTipo%
				   AND E3_NUM = %exp:_cDoc%
				   AND E3_PARCELA = %exp:_cParcela%
				   AND E3_SEQ = %exp:_cSeq%
			EndSql
	
	EndCase

Return