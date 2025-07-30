/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data    |                              Motivo                      										 
------------------------------------------------------------------------------------------------------------------------------- 
Alex Wallauer     | 06/06/2022 | Novo tratamento para a execucao via SmartClientHtml - Chamado 40354
===============================================================================================================================
*/


/*
===============================================================================================================================
Programa--------: F150QTDT
Autor-----------: Fabiano Dias
Data da Criacao-: 09/07/2010 
===============================================================================================================================
Descri��o-------:  Ponto de entrada executado apos a filtro dos titulos que farao parte do arquivo CNAB enviado ao banco.
                   no final do progrma FINA150.PRX. Chamado 40354.
===============================================================================================================================
Parametros------: nQtdTotTit - Numero de titulos que farao parte do arquivo CNAB    
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function F150QTDT()

	If nQtdTotTit == 0       
	
			xmaghelpfis("INFORMA��O","N�o foi gerado o arquivo CNAB de envio ao banco, pois nenhum titulo se enquadrou nos par�metros informados pelo usu�rio.",;
						"Favor checar os par�metros informados para a geracao do arquivo CNAB.")
	
	ELSEIF (GetRemoteType() == 5) //Valida se o ambiente � SmartClientHtml
         
		 IF File(ALLTRIM(MV_PAR04))
      
           // U_ITMSG("Gerou o aquivo: "+ALLTRIM(MV_PAR04),'Aten��o!',,2) // OK
      
            IF CpyS2TW(ALLTRIM(MV_PAR04),.T. ) = 0 //Indica se, falso (.F.), o arquivo ser� apenas copiado ou se, verdadeiro (.T.), ser� copiado e enviado para o browser
      
                //U_ITMSG("Conseguiu Copiar o aquivo: "+ALLTRIM(MV_PAR04),'Aten��o!',,2) // OK
            else
                U_ITMSG("N�o conseguiu Copiar o aquivo: "+ALLTRIM(MV_PAR04),'Aten��o!',,3) // OK
       
             ENDIF
         
         ELSE
      
            U_ITMSG("N�o gerou "+ALLTRIM(MV_PAR04),'Aten��o!',,3) // OK
      
         ENDIF

	EndIf

Return .T.
