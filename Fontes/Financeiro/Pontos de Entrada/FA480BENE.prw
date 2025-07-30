/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges | 09/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "protheus.ch"

/*
===============================================================================================================================
Programa----------: FA480BENE
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 20/10/2010
===============================================================================================================================
Descrição---------: Altera descrição do beneficiario na impressao do cheque
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: cBenef -> C -> Deverá retornar o nome do Beneficiário/Favorecido.
===============================================================================================================================
*/
User Function FA480BENE()

Local _cBenef   := ''    
Local _aArea    := GetArea()      
Local _cQuery   := ""
Local nCountRec := 0
Local _cAliasSEF:= GetNextAlias()  

//Se for numeracao automatica na impressao do cheque
If MV_PAR06 == 1                     
	DBSelectArea("SA2")  
	SA2->(dbSetOrder(1))
	If SA2->(DBSeek( xFilial("SA2") + SEF->EF_FORNECE + SEF->EF_LOJA ))
		//Verifique se o cheque eh referente a um produtor
		If SubStr(SA2->A2_COD,1,1) == 'P'   
			If AllTrim(cBenef) == AllTrim(SA2->A2_NOME)  		                                							                                                
				//Maximo de 40 caracteres para a descricao do beneficiario
				_cBenef := AllTrim(SubStr(SA2->A2_NOME,1,25)) + "(" + SA2->A2_COD + "-" + SA2->A2_L_LI_RO + ")" 									
			Else
				_cBenef:= cBenef
			EndIf
		Else
         	If AllTrim(cBenef) == AllTrim(SA2->A2_NOME)   
				_cBenef := AllTrim(SubStr(SA2->A2_NOME,1,32)) + "(" + SA2->A2_COD + ")"   
			Else
				_cBenef:= cBenef
			EndIf
		EndIf 
	EndIf     
//Se for numeracao automatica na impressao do cheque.
Else		
	//Se for baixado o titulo atraves da baixa manual
	If AllTrim(SEF->EF_ORIGEM) == 'FINA080'      
		_cQuery := "SELECT"  
		_cQuery += " EF_FORNECE,EF_LOJA "
		_cQuery += "FROM " + RetSqlName("SEF") + " EF "  
		_cQuery += "WHERE"  
		_cQuery += " EF.D_E_L_E_T_ = ' '"
		_cQuery += " AND EF.EF_FILIAL = '"   + xFilial("SEF")  +  "'"
		_cQuery += " AND EF.EF_BANCO = '"    + SEF->EF_BANCO   +  "'" 
		_cQuery += " AND EF.EF_AGENCIA = '"  + SEF->EF_AGENCIA +  "'" 
		_cQuery += " AND EF.EF_CONTA = '"    + SEF->EF_CONTA   +  "'" 
		_cQuery += " AND EF.EF_NUM = '"      + SEF->EF_NUM     +  "'" 
		_cQuery += " AND EF.EF_IMPRESS = 'A'" 				
				        	  
		If Select(_cAliasSEF) > 0
			(_cAliasSEF)->(dbCloseArea())
		EndIf                                                     
					
		dbUseArea( .T., "TOPCONN",TcGenQry(,,_cQuery),_cAliasSEF,.T.,.T.)
		COUNT TO nCountRec //Contabiliza o numero de registros encontrados pela query
					
		dbSelectArea(_cAliasSEF)   
		(_cAliasSEF)->(dbGotop())
					
		If nCountRec > 0  
					
			DBSelectArea("SA2")  
			SA2->(DBSetOrder(1))
			If SA2->(DBSeek( xFilial("SA2") + (_cAliasSEF)->EF_FORNECE + (_cAliasSEF)->EF_LOJA ))
				//Verifique se o cheque eh referente a um produtor
				If SubStr(SA2->A2_COD,1,1) == 'P'   
					If AllTrim(cBenef) == AllTrim(SA2->A2_NOME)  		                                							                                                
						//Maximo de 40 caracteres para a descricao do beneficiario
						_cBenef := AllTrim(SubStr(SA2->A2_NOME,1,25)) + "(" + SA2->A2_COD + "-" + SA2->A2_L_LI_RO + ")" 									
					Else
						_cBenef:= cBenef
					EndIf
				Else
		         	If AllTrim(cBenef) == AllTrim(SA2->A2_NOME)   
						_cBenef := AllTrim(SubStr(SA2->A2_NOME,1,32)) + "(" + SA2->A2_COD + ")"   
					Else
						_cBenef:= cBenef
					EndIf
				EndIf 
			EndIf
		EndIf				
		(_cAliasSEF)->(dbCloseArea())     
	EndIf
EndIf       	
//==============================================================
//cBenef - Variavel que armazena por padrao o beneficiario que
//sera impresso no cheque, caso nenhuma condicao seja atendida
//a variavel sera setada com este conteudo.
//==============================================================
If Len(AllTrim(_cBenef)) == 0
	_cBenef:= cBenef
EndIf

restArea(_aArea)

Return _cBenef