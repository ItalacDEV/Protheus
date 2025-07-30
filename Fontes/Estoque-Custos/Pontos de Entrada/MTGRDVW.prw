/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas C.	  | 01/09/2014 | Chamado 7276. Inclu�do "Estoque Seguran�a/M�nimo" campo BZ_ESTSEG.
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 11/09/2024 | Chamado 48465. Removendo warning de compila��o.
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 16/09/2024 | Chamado 48547. Corrgido o nome da vari�vel.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: MTGRDVW
Autor-------------: Talita Teixeira
Data da Criacao---: 13/03/2013
===============================================================================================================================
Descri��o---------: Incluido na rotina de consulta  de estoque (F4) a informa��o referente a localiza��o do produto de acordo
					com o campo BZ_I_LOCAL.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T. = Permite confirmar lancamento - .F. = Nao Permite confirmar lancamento
===============================================================================================================================
*/
User Function MTGRDVW()

Local oDlg := nil
Local _cLoc := ""
Local _nEstSeg := 0

DbSelectArea("SBZ")
SBZ->(DbSetorder(1))
SBZ->(DbSeek(xFilial("SBZ")+SB1->B1_COD))
	
_cLoc:= SBZ->BZ_I_LOCAL
_nEstSeg := SBZ->BZ_ESTSEG

@ 225,007 SAY "Localiza��o" of oDlg PIXEL
@ 224,075 MsGet _cLoc Picture PesqPict("SBZ","BZ_I_LOCAL") of oDlg PIXEL SIZE 070,009 When .F.  

@ 240,007 SAY "Est. Seguran�a/M�nimo" of oDlg PIXEL
@ 239,075 MsGet _nEstSeg Picture PesqPict("SBZ","BZ_ESTSEG") of oDlg PIXEL SIZE 070,009 When .F.  
																																					
SBZ->(DbCloseArea())

Return
