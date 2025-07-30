/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
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
Descrição-------:  Ponto de entrada executado apos a filtro dos titulos que farao parte do arquivo CNAB enviado ao banco.
                   no final do progrma FINA150.PRX. Chamado 40354.
===============================================================================================================================
Parametros------: nQtdTotTit - Numero de titulos que farao parte do arquivo CNAB    
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function F150QTDT()

	If nQtdTotTit == 0       
	
			xmaghelpfis("INFORMAÇÃO","Não foi gerado o arquivo CNAB de envio ao banco, pois nenhum titulo se enquadrou nos parâmetros informados pelo usuário.",;
						"Favor checar os parâmetros informados para a geracao do arquivo CNAB.")
	
	ELSEIF (GetRemoteType() == 5) //Valida se o ambiente é SmartClientHtml
         
		 IF File(ALLTRIM(MV_PAR04))
      
           // U_ITMSG("Gerou o aquivo: "+ALLTRIM(MV_PAR04),'Atenção!',,2) // OK
      
            IF CpyS2TW(ALLTRIM(MV_PAR04),.T. ) = 0 //Indica se, falso (.F.), o arquivo será apenas copiado ou se, verdadeiro (.T.), será copiado e enviado para o browser
      
                //U_ITMSG("Conseguiu Copiar o aquivo: "+ALLTRIM(MV_PAR04),'Atenção!',,2) // OK
            else
                U_ITMSG("Não conseguiu Copiar o aquivo: "+ALLTRIM(MV_PAR04),'Atenção!',,3) // OK
       
             ENDIF
         
         ELSE
      
            U_ITMSG("Não gerou "+ALLTRIM(MV_PAR04),'Atenção!',,3) // OK
      
         ENDIF

	EndIf

Return .T.
