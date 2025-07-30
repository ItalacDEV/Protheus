	/*
===============================================================================================================================
                                   ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
     Autor     |    Data    |                              Motivo                                                                 
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich  | 09/10/2015 | Chamado 11509. Incluida validação de campos de investimento. 
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich  | 28/10/2015 | Chamado 12551. Melhoria de  validação de campos de investimento. 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 11/06/2018 | Chamado 29598. Ajustes na validação acrescentou .AND. _cUsr <> "0". 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 06/11/2019 | Chamado 28346. Revisão de fonte para novo appserver.   		
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 21/01/2022 | Chamado 38985. Correção de error.log :variable does not exist CUSR.  
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 21/03/2023 | Chamado 43275. Nova validacao para quando o centro de custo estiver em branco. 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 19/01/2024 | Chamado 46095. Ajuste na validação do centro de custo ser válido com campo de investimento.
============================================================================================================================================================================================================
Analista         - Programador       - Inicio     - Envio      - Chamado - Motivo da Alteração
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Bremmer Souza    - Julio Paz         - 10/10/2024 - 21/10/2024 -  48697  - Validar a data de emissão da Solicitação ao Armazém, para não ser superior a data do dia da inclusão ou Alteração do cadastro.
============================================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#include "totvs.ch"
#define MB_ICONEXCLAMATION        48

/*
===============================================================================================================================
Programa----------: MTA105OK
Autor-------------: Xavier
Data da Criacao---: 13-04-2015
===============================================================================================================================
Descrição---------: Ponto de entrada na validação do OK da solicitação ao armazem.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
*/
User Function MTA105OK

Local _aArea 	:= GetArea()
Local _lRet 	:= .T.
//Local _lLibSa := {}
Local _cUsr	:= ""
Local _cSol 	:=  ""
Local _nni 	:= 0
Local _cmens	:= ""
Local _cCC		:= ""
Local _cINVES := ""
Local _cLOCIN := ""
Local _lexcep := .F. , N
Local _cloca  := U_ITGETMV( "IT_MOTINV" , "15" )

If ALTERA
	
	_cUsr := Posicione("ZZL",4,XFilial("ZZL")+UsrRetName(__CUSERID),"ZZL_GRPAPR")
	_cSol := Posicione("ZZL",4,XFilial("ZZL")+SCP->CP_SOLICIT,"ZZL_GRPAPR")
	
	If (_cUsr # _cSol) .And. _lRet .AND. _cUsr <> "0"
	
		_lRet := .F.
		_cmens += "Operação invalida ! Usuário não pertence ao departamento do solicitante."
		
	EndIf
	
EndIf

_nni    := n
lDif    :=.F.
cCentroC:=""

For n := 1 to len(acols)

	_lexcep := .F.

	If !(acols[n][len(aheader)+1])
	
		//lê campos
		_cCC 	:= acols[n][ascan(aHeader , {|X| UPPER( Alltrim( X[2] ) ) == "CP_CC"     } )]
		_cINVES	:= acols[n][ascan(aHeader , {|X| UPPER( Alltrim( X[2] ) ) == "CP_I_INVES"     } )]
		_cLOCIN	:= acols[n][ascan(aHeader , {|X| UPPER( Alltrim( X[2] ) ) == "CP_I_LOCIN"     } )]
		_cMOTIN	:= acols[n][ascan(aHeader , {|X| UPPER( Alltrim( X[2] ) ) == "CP_I_MOTIV"     } )]

        IF EMPTY(cCentroC)
           cCentroC+=" [ "+_cCC+" ]"
        ENDIF

        IF !_cCC $ cCentroC
           cCentroC+=" [ "+_cCC+" ]"
           lDif:=.T.
        ENDIF

		//verifica se é exceção de validação
		If 	ALLTRIM(_cMOTIN) $ ALLTRIM(_cloca) 
	  
		  _lexcep := .T.
	  
		Endif
		

		//Verifica se campo de centro de custo é válido com campo de investimento
		if substr(alltrim(_cCC),1,5) $ alltrim(u_vldcc()) .and. _cINVES <> "S" .and. !(empty( _cCC )) .and. !(_lexcep) .and. !FWIsInCallStack( "MDTA695" )

				_cmens += "Item " + strzero(n,4) + " - Para Centro de custo da filial é preciso que seja solicitação de investimento." + CRLF + CRLF
				_lret := .F.

		Endif

		//Verifica se campo de centro de custo é válido com campo de investimento
		if !(substr(alltrim(_cCC),1,5) $ alltrim(u_vldcc())) .and. _cINVES = "S"  .and. !(_lexcep)

				_cmens += "Item " + strzero(n,4) + " - Para investimento é preciso campo de centro de custo válido." + CRLF + CRLF
				_lret := .F.
	
		Endif

		//Verifica se campo investimento não está como S se o campo local de investimento estiver preenchido
		if  _cINVES <> "S" .And. !(empty( _cLOCIN )) 

				_cmens += "Item " + strzero(n,4) + " - Para ter local de investimento é preciso ser solicitação de investimento." + CRLF + CRLF
				_lret := .F.
	
		Endif

		//Verifica se campo local de investimento está preenchido se campo investimento está preenchido
		if  _cINVES = "S"  .And. (empty( _cLOCIN )) 

			_cmens += "Item " + strzero(n,4) + " - Para solicitação de investimento é obrigatório local de investimento." + CRLF + CRLF
			_lret := .F.
	
		Endif

		//Se local de investimento está preenchido garante que a descrição de investimento está preenchida
		if  _cINVES = "S"	.And. !(empty( _cLOCIN )) 
 
 			acols[n][ascan(aHeader , {|X| UPPER( Alltrim( X[2] ) ) == "CP_I_DESIN"     } )] := 	posicione("ZZI",1,xfilial("ZZI")+_cLOCIN,"ZZI_DESINV")
 		
 		Endif

	Endif
	
Next

n := _nni


//============================================
//Mostra lista de itens com problema
//============================================
If !(_lRet) .and. !(empty(_cmens))
	MessageBox( 'Problemas nos itens abaixo: ' + CRLF + CRLF + _cmens + CRLF + CRLF+;
					'Caso necessário solicite a manutenção à um usuário com acesso ou, se necessário, solicite o acesso à área de TI/ERP.' , 'Atenção!' , 48 )
	
Endif

If _lRet .AND. lDif 
   U_ITMSG("Centro de custos distintos: "+cCentroC,;
           "ATENCAO",;
           "Altere os centros de custo da SA mantendo um unico centro de custo para todos os itens.",1)
   _lRet := .F.
ENDIF

//================================================================= 
// Valida a data de emissão da Solicitação ao Armazém para 
// não ser maior que a data do dia da inclusão/alteração.
//=================================================================
If _lRet .And. DA105DATA > Date()
    U_ITMSG("A data de emissão da Solicitação ao Armazém não pode ser superior a data de hoje. ",;
           "Atenção",;
           "Informe uma data de emissão igual ou inferior a data de hoje.",1)
   _lRet := .F.
EndIf 

RestArea(_aArea)

Return _lRet
