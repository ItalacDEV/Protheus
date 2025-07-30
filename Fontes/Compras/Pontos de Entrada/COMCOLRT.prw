/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 13/10/2023 | Inclu�da chamada da rotina MCOM020. Chamado 45321
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 16/11/2023 | Inclu�da chamada da rotina MCOM021. Chamado 45591
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 16/05/2024 | Inclu�da chamada da rotina MCOM023D. Chamado 47282
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'Protheus.ch' 

/*
===============================================================================================================================
Programa----------: COMCOLRT
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 24/03/2017
===============================================================================================================================
Descri��o---------: Ponto de entrada para inclus�o de novos itens no menu aRotina
===============================================================================================================================
Parametros--------: aRotina
===============================================================================================================================
Retorno-----------: aRotina
===============================================================================================================================
*/
User Function COMCOLRT
Local aRotina := ParamIxb[1]
//============================================================
// Parametros do array a Rotina:                         
//                                                       
// 1. Nome a aparecer no cabecalho                       
// 2. Nome da Rotina associada                           
// 3. Reservado                                          
// 4. Tipo de Transacao a ser efetuada:                  
//      1 - Pesquisa e Posiciona em um Banco de Dados    
//      2 - Simplesmente Mostra os Campos                
//      3 - Inclui registros no Bancos de Dados          
//      4 - Altera o registro corrente                   
//      5 - Remove o registro corrente do Banco de Dados 
// 5. Nivel de acesso                                    
// 6. Habilita Menu Funcional                            
//============================================================

	aAdd(aRotina,{"Exc/Reproc"			,"U_MCOM005()",0,4,0,nil})
	aAdd(aRotina,{"Manut XML"			,"U_MCOM006()",0,1,0,nil})
	aAdd(aRotina,{"Manut XML Schedule"	,"U_MCOM007()",0,1,0,nil})
	aAdd(aRotina,{"Inf. Mix Leite"		,"U_MCOM008()",0,4,0,nil})
	aAdd(aRotina,{"Reprocessa CT-e"		,"U_MCOM012()",0,4,0,nil})
	aAdd(aRotina,{"Ajusta XMLs"			,"U_MCOM019()",0,1,0,nil})
	aAdd(aRotina,{"Carrega XMLs"		,"U_MCOM020()",0,1,0,nil})
	aAdd(aRotina,{"Exporta XMLs"		,"U_MCOM021()",0,1,0,nil})
	aAdd(aRotina,{"Danfe/Dacte"			,"U_MCOM023D()",0,4,0,nil})
	
Return (aRotina)
