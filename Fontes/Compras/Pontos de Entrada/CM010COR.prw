/*
====================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
====================================================================================================================================
 Autor        |    Data    |                               Motivo                        										 
------------------------------------------------------------------------------------------------------------------------------------
====================================================================================================================================
*/  

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

/*
===============================================================================================================================
Programa----------: CM010COR
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 29/07/2024
===============================================================================================================================
Descrição---------: PE para criar legenda do Cadastro de tabela de preço dentro da 
                    função CM010COR()/COMA010.PRX. Andre. Chamado: 47732
===============================================================================================================================
Parametros--------: ParamIXB[1]
===============================================================================================================================
Retorno-----------: aCoreNew
===============================================================================================================================
*/
User Function CM010COR()
//LOCAL aCores:=ParamIXB[1]
LOCAL aCoreNew:={} //, C

AADD(aCoreNew,{"AIA_I_SITW $ 'E,Q'","BR_AZUL"})//Tem que ser em primeiro lugar DA LSITA DE CORES
//FOR C := 1 TO LEN(aCores)
//    Aadd(aCoreNew,aCores[C])
//NEXT

// MUDAMOS O PADRÃO QUE USAVA " DDATABASE "
//AADD(aCores,{ "DTOS(AIA_DATATE) <  DTOS(DDATABASE) .AND. !EMPTY(DTOS(AIA_DATATE))" ,"DISABLE"}) //INATIVA
//AADD(aCores,{"(DTOS(AIA_DATATE) >= DTOS(DDATABASE) .OR.   EMPTY(DTOS(AIA_DATATE)))","ENABLE"})  //ATIVA

//PARA USAR " DATE() "
AADD(aCoreNew,{ "DTOS(AIA_DATATE) <  DTOS(DATE()) .AND. !EMPTY(DTOS(AIA_DATATE))" ,"DISABLE"}) //INATIVA
AADD(aCoreNew,{"(DTOS(AIA_DATATE) >= DTOS(DATE()) .OR.   EMPTY(DTOS(AIA_DATATE)))","ENABLE"})  //ATIVA

RETURN aCoreNew
