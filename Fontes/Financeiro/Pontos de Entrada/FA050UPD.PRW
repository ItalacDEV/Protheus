/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 01/08/2019 | Nova validacao da origem do AOMS114 - Chamado 29372                                 
Jerry         | 05/12/2019 | Quando origem da Alteração do Tit. C.Pagar for a função MFIN003 não bloquear - Chamado 31390
================================================================================================================================================================================================
Analista      - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
================================================================================================================================================================================================
Jerry         - Alex Wallauer - 22/01/25 - 05/02/25 -  49663  - Acerto dos tratamentos de FUNNAME() e lMsErroAuto.
================================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================


/*
===============================================================================================================================
Programa--------: FA050UPD
Autor-----------: Josué Danich Prestes
Data da Criacao-: 21/12/2018
Descrição-------: PE Validação de inclusão/alteração/exclusão título a pagar - Chamado 27268
Parametros------: Nenhum
Retorno---------: _lRet - .T. - Permite a execução da rotina / _lRet - .F. - Bloqueia a execução da rotina
===============================================================================================================================
*/
User Function FA050UPD()

 Local _lRet := .T. As Logical
                        
 If !FWIsInCallStack("U_MFIN003")//FUNNAME() != "MFIN003"
 
    If SE2->E2_PREFIXO == "NDT" .AND. !FWIsInCallStack("U_AOMS003")//FUNNAME() != "AOMS003"
    
    	U_ITMSG("Essa Nota de débito de transportador só pode ser modificada a partir da rotina de Ocorrências de Frete [AOMS003]","Atenção",,1)
    	_lRet := .F.
    	
    Endif
    
    If _lRet .AND. SE2->E2_ORIGEM = "AOMS114" .AND. !FWIsInCallStack("U_AOMS114")
    
    	U_ITMSG("Essa Nota de débito do transportador só pode ser modificada a partir da rotina de Central de Seguros [AOMS114]","Atenção",,1)
    	_lRet := .F.
    	
    Endif
    
    If _lRet .AND. SE2->E2_ORIGEM = "AOMS115" .AND. !FWIsInCallStack("U_AOMS115")
    
    	U_ITMSG("Essa Fatua do transportador só pode ser modificada a partir da rotina de Central de Geracao de Faturas [AOMS115]","Atenção",,1)
    	_lRet := .F.
    	
    Endif
 EndIf
 
 IF TYPE("lMsErroAuto") = "L" .AND. !_lRet .AND. !lMsErroAuto//Só altera o conteudo do lMsErroAuto se ele tiver Falso e o retorno for falso
    lMsErroAuto:=.T.//Só Joga verdadeiro de for o caso
 ENDIF

Return _lRet

