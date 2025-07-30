/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Josu� Prestes | 28/12/2015 | Chamado 13068. Inclu�dos novos campos de residuo no ajuste de c�pia. 
-------------------------------------------------------------------------------------------------------------------------------
Josu� Prestes | 30/06/2017 | Chamado 20635. Testa se o sc1 est� em eof antes de fazer reclock. 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 03/10/2019 | Chamado 28346. Removidos os Warning na compila��o da release 12.1.25. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 22/10/2019 | Chamado 30921. Tratamento para o campo NOVO CLAIM. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 20/02/2024 | Chamado 46303. Andre. Corre��o da limpeza dos Campos da indica��o do Comprador.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"

/*
===============================================================================================================================
Programa----------: MT110GRV
Autor-------------: Tiago Correa Castro
Data da Criacao---: 01/08/2008
===============================================================================================================================
Descri��o---------: Ponto de Entrada apos a gravacao de cada item do SC1
					Localiza��o: Function A110GRAVA - Fun��o da Solicita��o de Compras responsavel pela grava��o das SCs.
					Em que Ponto: No laco de grava��o dos itens da SC na fun��o A110GRAVA, executado ap�s gravar o item da SC, 
					a cada item gravado da SC o ponto � executado.
===============================================================================================================================
Parametros--------: PARAMIXB -> L -> Caso PARAMIXB == .T.(C�pia da solicita��o de compras est� ativa), se .F.(C�pia n�o est� ativa)
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MT110GRV

Local _aArea 		:= GetArea()
Local _lCopia		:= ParamIXB[1]

If Altera .and. !(SC1->(EOF()))

	SC1->( RecLock( 'SC1' , .F. ) )
        SC1->C1_I_CLAIM     := cClaim//CLAIM
		SC1->C1_I_APROV		:= ''
		SC1->C1_I_DTAPR		:= STOD('')
		SC1->C1_I_HRAPR		:= ''
		SC1->C1_I_CDSOL		:= __cUserID 
		SC1->C1_I_DTINC		:= DATE()		
		SC1->C1_I_HRINC		:= TIME()		
		SC1->C1_I_APLIC		:= cAplic
		SC1->C1_CC			:= cCCust
		SC1->C1_I_URGEN		:= cUrgen
		SC1->C1_I_CODAP		:= cAprov
		SC1->C1_I_CDINV		:= cCInve
		SC1->C1_APROV		:= "B"
		SC1->C1_I_SITWF		:= "1"
		SC1->C1_I_OBSSC		:= cObsSC
        //Campos da indica��o do Comprador
		SC1->C1_CODCOMP		:= ""
		SC1->C1_GRUPCOM		:= ""
		SC1->C1_I_DTRET		:= STOD('')
		SC1->C1_I_INDIC     := ""
		SC1->C1_I_INDDT     := STOD('')
		SC1->C1_I_INDHR     := ""
	SC1->( MsUnLock() )

ElseIf Inclui

	SC1->( RecLock( 'SC1', .F. ) )
        SC1->C1_I_CLAIM     := cClaim//CLAIM
		SC1->C1_I_APROV		:= cAprov
		SC1->C1_I_DTAPR		:= STOD('')
		SC1->C1_I_HRAPR		:= ''
		SC1->C1_I_APLIC		:= cAplic
		SC1->C1_CC			:= cCCust
		SC1->C1_I_URGEN		:= cUrgen
		SC1->C1_I_CODAP		:= cAprov
		SC1->C1_I_CDINV		:= cCInve
		SC1->C1_I_CDSOL 	:= __cUserID
		SC1->C1_APROV		:= "B"
		SC1->C1_I_SITWF		:= "1"
		SC1->C1_I_OBSSC		:= cObsSC
        //Campos da indica��o do Comprador
		SC1->C1_CODCOMP		:= ""
		SC1->C1_GRUPCOM		:= ""
		SC1->C1_I_DTRET		:= STOD('')
		SC1->C1_I_INDIC     := ""
		SC1->C1_I_INDDT     := STOD('')
		SC1->C1_I_INDHR     := ""
    SC1->( MsUnLock() )
	
ElseIF _lCopia .and. !(SC1->(EOF()))

	SC1->( RecLock( 'SC1', .F. ) )
        SC1->C1_I_CLAIM     := cClaim//CLAIM
		SC1->C1_I_APROV		:= cAprov
		SC1->C1_I_APLIC		:= cAplic
		SC1->C1_CC			:= cCCust
		SC1->C1_I_URGEN		:= cUrgen
		SC1->C1_I_CODAP		:= cAprov
		SC1->C1_I_CDINV		:= cCInve
		SC1->C1_I_CDSOL 	:= __cUserID
		SC1->C1_APROV		:= "B"
		SC1->C1_I_SITWF		:= "1"
		SC1->C1_I_OBSSC		:= cObsSC
		SC1->C1_I_HTM		:= Space(TamSX3("C1_I_HTM")[1])
		SC1->C1_I_WFID		:= Space(TamSX3("C1_I_WFID")[1])
		SC1->C1_I_OBSAP		:= Space(TamSX3("C1_I_OBSAP")[1])
		SC1->C1_I_DTAPR		:= STOD('')
		SC1->C1_I_HRAPR		:= Space(TamSX3("C1_I_HRAPR")[1])
		SC1->C1_I_USREL 	:= '' 
		SC1->C1_I_DTELR 	:= STOD('')
		SC1->C1_I_HRELR		:= ''
		SC1->C1_I_DTINC		:= date()
		SC1->C1_I_HRINC		:= time()
        //Campos da indica��o do Comprador
		SC1->C1_CODCOMP		:= ""
		SC1->C1_GRUPCOM		:= ""
		SC1->C1_I_DTRET		:= STOD('')
		SC1->C1_I_INDIC     := ""
		SC1->C1_I_INDDT     := STOD('')
		SC1->C1_I_INDHR     := ""
	SC1->( MsUnLock() )

EndIf

RestArea(_aArea)

Return
