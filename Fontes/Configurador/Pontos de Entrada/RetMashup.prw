/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Andr� Lisboa  |27/10/2016 | Tratativa para os campos DDD para quando o retorno for vazio - Chamado 17410
-------------------------------------------------------------------------------------------------------------------------------
Darcio		  |20/01/2017 | Foi inclu�do o tratamento para gravar a data de execu��o do mashup, mais os campos de retorno do
			  |			  | mashup. Chamado 17503
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#include "protheus.ch"
#include "TopConn.ch"
#include "RwMake.ch"    

/*
===============================================================================================================================
Programa----------: RetMashup
Autor-------------: Andre Lisboa
Data da Criacao---: 18/10/2016
===============================================================================================================================
Descri��o---------: Ponto de Entrada para tratar retorno dos Mashups
===============================================================================================================================
Parametros--------: ParamIXB
===============================================================================================================================
Retorno-----------: xRet
===============================================================================================================================
*/
User Function RetMashup()       

Local cAlias 	:= ParamIXB[1] 		// Alias da tabela
Local cMashup 	:= ParamIXB[2] 		// Nome do servi�o do Mashup
Local cCampo 	:= ParamIXB[4] 		// Campo de retorno
Local xConteudo := ParamIXB[5]      // Conte�do 
Local xRet	            


If cMashup == "ReceitaFederal.CNPJ"
	If alltrim(cAlias) == "SA1"
		If alltrim(cCampo) == "A1_TEL"
 			xRet	  := substr(xConteudo,5,10) //Telefone
			If !empty(xConteudo)
				M->A1_DDD := substr(xConteudo,2,2)  //DDD
			Endif	
		Endif
		If alltrim(cCampo) == "A1_I_SITRF"
			xRet	  := xConteudo //Situcao na RF
		Endif
		If alltrim(cCampo) == "A1_I_DTSRF"
			xRet	  := xConteudo //Data da consulta Situcao na RF
		Endif			
	Else
		If alltrim(cCampo) == "A2_TEL"
 			xRet	  := substr(xConteudo,5,10) //Telefone
			If !empty(xConteudo)
				M->A2_DDD := substr(xConteudo,2,2)  //DDD
			Endif	
		EndIf
		If alltrim(cCampo) == "A2_I_SITRF"
			xRet	  := xConteudo //Situcao na RF
		Endif
		If alltrim(cCampo) == "A2_I_DTSRF"
			xRet	  := xConteudo //Data da consulta Situcao na RF
		Endif
	Endif				    
Endif	
	
If cMashup == "Sintegra.ConsultaNacional"
	If alltrim(cAlias) == "SA1"
		If alltrim(cCampo) == "A1_INSCR"       //Inscri��o Estadual
			xRet := STRTRAN(xConteudo,".","")
		Endif	
	Else
		If alltrim(cCampo) == "A2_INSCR"       //Inscri��o Estadual
			xRet := STRTRAN(xConteudo,".","")
		Endif	
	Endif
Endif		

If Empty(AllTrim(xConteudo))
	&("M->" + AllTrim(cCampo)) := Space(TamSX3(AllTrim(cCampo))[1])
Else
	&("M->" + AllTrim(cCampo)) := xConteudo
EndIf

If cMashup == "ReceitaFederal.CNPJ"
	If Alias() == "SA1"
		M->A1_I_DTEXE	:= Date()
	ElseIf Alias() == "SA2"
		M->A2_I_DTEXE	:= Date()
	EndIf              
EndIf

Return xRet