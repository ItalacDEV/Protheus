/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges      | 15/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"  
#INCLUDE "RwMake.ch"              

/*
===============================================================================================================================
Programa--------: AOMS040
Autor-----------: Fabiano Dias
Data da Criacao-: 21/06/2010
===============================================================================================================================
Descrição-------: Funcao utilizada para identificar se determinado cliente e loja possui acordo comercial
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AOMS040(cCodclient,cLojacli) 

Local cQuery   := ""
Local cAliasSC5:= GetNextAlias()    
Local nreg     := 0    
Local lRetorno := .F.         
Local lcontrato:= .F.
Local aGetArea := GetArea()

//Verifica se o codigo e a loja do cliente foram informados
If Len(AllTrim(cCodclient)) > 0 .And. Len(AllTrim(cLojacli)) > 0

	cQuery := "SELECT ZAZ_COD,ZAZ_LOJA,ZAZ_STATUS,ZAZ_DTFIM" 
	cQuery += " FROM " + RetSqlName("ZAZ")
	cQuery += " WHERE D_E_L_E_T_  <> '*'  AND ZAZ_FILIAL = '" + xFILIAL("ZAZ") + "'"
	cQuery += " AND ZAZ_CLIENT = '" + cCodclient + "'"    
	cQuery += " AND ZAZ_MSBLQL = '2'"    
	
	If Select(cAliasSC5) > 0
		dbSelectArea(cAliasSC5)
		(cAliasSC5)->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC5,.T.,.T.) 
	Count to nreg
	//Contabiliza o numero de registros encontrados pela query
	
	dbSelectArea(cAliasSC5)
	(cAliasSC5)->(dbGoTop()) 
	
	//Se encontrar um contrato nao bloqueado para um cliente sem considerar a loja, caso ela tenha sido especificada no contrato
	//If !Empty(TMP10->ZAZ_COD)  
	If nreg > 0   
	
		While (cAliasSC5)->(!Eof())
		                    
			If !Empty((cAliasSC5)->ZAZ_LOJA)
			//Verifica se a loja informada no contrato e a mesma loja informada no pedido
				If (cAliasSC5)->ZAZ_LOJA == cLojacli     
						           
						           //Possui contrato especifico para este cliente e loja
						           lcontrato:= .T.
						                  					            	
									//verifica se o contrato encontra-se vigente
									If (cAliasSC5)->ZAZ_DTFIM >= DtoS(date())
											//Se o contrato estiver ativo
											IF (cAliasSC5)->ZAZ_STATUS == 'S' 
								              
													//Possui contrato especifico para este cliente e loja
						    						lRetorno:=.T.    
	
					                         EndIf   				                            
				        	        EndIf
				   exit     	        
		        EndIf
		     EndIf   
		
		    (cAliasSC5)->(dbSkip())  
	EndDo                
	
	//Quando nao encontrar um contrato que tenha cliente + loja, ele vai buscar um mais generico somente por cliente
	If !lcontrato        
	
	dbSelectArea(cAliasSC5)
	(cAliasSC5)->(dbGoTop()) 
	
	
		While (cAliasSC5)->(!Eof()) 
		
			If Empty((cAliasSC5)->ZAZ_LOJA)                                                        
			        
					//possui contrato para o cliente sem loja especificada no contrato
					lcontrato:=.T.
					           			
									//verifica se o contrato encontra-se vigente
									If (cAliasSC5)->ZAZ_DTFIM >= DtoS(date())
											//Se o contrato estiver ativo
											IF (cAliasSC5)->ZAZ_STATUS == 'S' 
												lRetorno:= .T.
					   					    EndIf   			                            
				        	        EndIf
				    exit    	        
			EndIf
			
		(cAliasSC5)->(dbSkip())
		EndDo      
		
	dbSelectArea(cAliasSC5)
	(cAliasSC5)->(dbCloseArea())	                      
		
	EndIf                 
	EndIf

		If  !lcontrato 
			//Se o cliente informado no pedido de vendas nao possuir um contrato(ou que este esteja bloqueado)procura pela rede
	         lRetorno:= verContRede(cCodclient,cLojacli) 
		
		EndIf     
	             
	EndIf                                                                                                                
	
	RestArea(aGetArea)             	

Return lRetorno                  

               
//Verifica se o cliente e loja possui contrato de acordo comercial para a rede
Static Function verContRede(cCodclient,cLojacli)

Local cQuery    := ""
Local cRede	    := "" 
Local cAliasSA1 := GetNextAlias()
Local cAliasZAZ := GetNextAlias()
Local nreg      := 0
Local nreg2     := 0                       
Local lRetorno  := .F.
//Array que armazenara os seguintes valores nas seguinte posicoes
//1 - se possui contrato
//2 - numero do contrato
//3 - o estado do cliente(MG,SP,RO)
//4 - se o contrato esta aprovada
//5 - se o contrato esta com a data de vigencia valida       
//6 - Numero do contrato

cQuery := "SELECT A1_GRPVEN" 
cQuery += " FROM " + RetSqlName("SA1")
cQuery += " WHERE D_E_L_E_T_  <> '*'  AND A1_FILIAL = '" + xFILIAL("SA1") + "'"
cQuery += " AND A1_COD = '"  + cCodclient + "'"
cQuery += " AND A1_LOJA = '" + cLojacli   + "'"
cQuery += " AND A1_GRPVEN IS NOT NULL"

If Select(cAliasSA1) > 0
	dbSelectArea(cAliasSA1)
	(cAliasSA1)->(dbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSA1,.T.,.T.)
Count to nreg //Contabiliza o numero de registros encontrados pela query


dbSelectArea(cAliasSA1)
(cAliasSA1)->(dbGoTop())

//Caso o cliente tenha um grupo de vendas(Rede) especificado no seu cadastro
If nreg > 0 
                                           
	//Armazena grupo de vendas e estado para liberar TMP11
	cRede:=(cAliasSA1)->A1_GRPVEN         
	
	dbSelectArea(cAliasSA1)
	(cAliasSA1)->(dbCloseArea())

	//Pesquisa na tabela de desconto contratual se existe contrato para a rede do cliente especificado no pedido de vendas
	cQuery := "SELECT ZAZ_COD,ZAZ_DTFIM,ZAZ_STATUS" 
	cQuery += " FROM " + RetSqlName("ZAZ")
	cQuery += " WHERE D_E_L_E_T_  <> '*'  AND ZAZ_FILIAL = '" + xFILIAL("ZAZ") + "'"
	cQuery += " AND ZAZ_GRPVEN = '" + cRede + "'"
	cQuery += " AND ZAZ_MSBLQL = '2'"//Caso ele nao esteja bloqueado
	
		If Select(cAliasZAZ) > 0
			dbSelectArea(cAliasZAZ)
			(cAliasZAZ)->(dbCloseArea())
		EndIf
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZAZ,.T.,.T.)
	Count to nreg2 //Contabiliza o numero de registros encontrados pela query

	dbSelectArea(cAliasZAZ)
	(cAliasZAZ)->(dbGoTop())
		
	//Se encontrar um contrato para um cliente sem considerar a loja, caso ela tenha sido especificada no contrato
	If nreg2 > 0
		//Se o contrato estiver com a data de vigencia em vigor
		If (cAliasZAZ)->ZAZ_DTFIM >= DtoS(date())
			//Se o contrato estiver ativo
			IF (cAliasZAZ)->ZAZ_STATUS == 'S'
		 		lRetorno:= .T.
			EndIf
			
		EndIf
		
	EndIf			    

	dbSelectArea(cAliasZAZ)
	(cAliasZAZ)->(dbCloseArea())         

EndIf                                

Return lRetorno