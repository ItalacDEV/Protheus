/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data    |                              Motivo                      										 
------------------------------------------------------------------------------------------------------------------------------- 
===============================================================================================================================
*/


/*
===============================================================================================================================
Programa--------: F420CRP
Autor-----------: Alex Wallauer
Data da Criacao-: 06/06/2022 
===============================================================================================================================
Descrição-------: Ponto de entrada no final do progrma FINA420.PRX - Geracao do Arquivo SisPag, Chamado 40354
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
USER FUNCTION F420CRP()
    
IF (GetRemoteType() == 5) //Valida se o ambiente é SmartClientHtml

   IF File(ALLTRIM(MV_PAR04))
      //U_ITMSG("Gerou o aquivo: "+ALLTRIM(MV_PAR04),'Atenção!',,2) // OK
      IF CpyS2TW(ALLTRIM(MV_PAR04),.T. ) = 0 //Indica se, falso (.F.), o arquivo será apenas copiado ou se, verdadeiro (.T.), será copiado e enviado para o browser
         // U_ITMSG("Conseguiu Copiar o aquivo: "+ALLTRIM(MV_PAR04),'Atenção!',,2) // OK
      ELSE
          U_ITMSG("Não conseguiu Copiar o aquivo: "+ALLTRIM(MV_PAR04),'Atenção!',,3) // OK 
      ENDIF
   
   ELSE
      U_ITMSG("Não gerou "+ALLTRIM(MV_PAR04),'Atenção!',,3) // OK
   ENDIF

ENDIF

RETURN .T.
