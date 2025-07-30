/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 25/09/2017 | Volta do código de segurança para não zerar o numero do PV - Chamado 21574
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 20/12/2018 | Universalização da rotina - Chamado 27443 
===============================================================================================================================
*/
#include "Protheus.ch"
/*
===============================================================================================================================
Programa----------: AOMS089
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/12/2016
===============================================================================================================================
Descrição---------: Rotina de segurança para atualizar hardlock  - Chamado 18103
===============================================================================================================================
Parametros--------: _lauto - Rodando de schedule?
					_alias - alias
					_campo - campo
					_lshow - mostra mensagens
					_cfilial - filial do numerador
===============================================================================================================================
Retorno-----------: _cNum -> próximo número de pedido de vendas
===============================================================================================================================
*/
STATIC _lAtuSC5 := .F.
STATIC _cNumSC5 := ""
*===========================================================================*
User Function AOMS089(_lauto,_alias,_campo,_lshow,_cfilial)
*===========================================================================*
Local _cQuery := ""
Local _aArea  := GetArea()
Private _cNum := ""
Default _alias := "SC5"
Default _campo := "C5_NUM"
Default _lshow := .T.
Default _cfilial := "99"

IF VALTYPE(_lauto) <> "L"
   _lauto := .T.
ENDIF

If _lauto

   U_ITConout("******* \\\\\///// Inicio da Verificação do Numerador do "+ _alias + " Via Schedule: "+TIME()+" \\\\\/////*******")

  //Monta ambiente
  RPCSetType(3)
  RpcSetEnv( "01" , "01" ,,,"OMS", "AOMS089" , {_alias} )
  Sleep( 5000 ) //Aguarda 5 segundos para subam as configurações do ambiente.
  If _cfilial == "99"
  	_cfilial := "01"
  Endif

Else

	_cfilial := cfilant

Endif

_cQuery := " SELECT max(" + _campo + ") MAXIMO FROM "+RetSqlName(_alias) +" WHERE D_E_L_E_T_ <> '*' "

If _alias != "SC5"

	_cQuery += " AND " + _alias + "_FILIAL = '" + _cfilial + "'"
	
Endif
	
DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , "STT" , .T. , .F. )
	
DBSelectArea("STT")

If !STT->(Eof())

   _lAtuSC5:= .T.
   _cNumSC5:= ALLTRIM(STT->MAXIMO)
   
   If _alias == "SC5"
   	_cNum   := GetSXENum(_alias,_campo,"  \DATA\"+RETSQLNAME("SC5"),24)//GetSXENum(_cAlias,_cCpo)
   Else
    _cNum   := GetSXENum(_alias,_campo)
   Endif 

   IF LEN(ALLTRIM(_cNum)) = LEN(ALLTRIM(STT->MAXIMO))
	  If _lauto .or. !_lshow
	     AOMS089T(_lauto,_alias,_campo,_lshow)
	  Else
	     Processa( {|| AOMS089T(_lauto,_alias,_campo,_lshow)}, "Aguarde...","Atualizando hardlock...",.T.)
	  Endif
   ELSE
      U_ITMSG("Numerador do Hardlock esta com o tamanho diferente do campo: " + _campo,"Tamanho do numerador",;
              "Tamanhos: "+STR(LEN(ALLTRIM(_cNum)),1)+" # "+STR(LEN(ALLTRIM(STT->MAXIMO)),1)+". Entrar em contato com area de TI.",1)
   Endif
	
Endif

STT->(Dbclosearea())	

RestArea(_aArea)

Return _cNum

/*
===============================================================================================================================
Programa----------: AOMS089P
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/12/2016
===============================================================================================================================
Descrição---------: Roda atualização de hardlock - Chamado
===============================================================================================================================
Parametros--------: _lauto - Se está rodando em schedule
					_alias - alias
					_campo - campo
					_lshow - se mostra mensagens
===============================================================================================================================
Retorno-----------: nenhum
===============================================================================================================================
*/
Static Function AOMS089T(_lauto,_alias,_campo,_lshow)

Local _nquant := val(ALLTRIM(STT->MAXIMO)) - val(ALLTRIM(_cNum))

If !_lauto .and. _lshow

  Procregua(_nquant)

Endif

U_ITConout("****** //// Inicio da Atualização do Numerador do " + _alias + ": "+TIME()+"  \\\\******")
U_ITConout("****** \\\\ Atualizando Hardlock - Registro Inicial: " + ALLTRIM(_cNum) + " de " + ALLTRIM(STT->MAXIMO)+" ////******")

Do while ALLTRIM(_cNum) <= ALLTRIM(STT->MAXIMO)
	
	If !_lauto .and. _lshow
	  incproc("Atualizando Hardlock - Registro: " + ALLTRIM(_cNum) + " de " + ALLTRIM(STT->MAXIMO))
	Endif

   Confirmsx8(.F.)
   If _alias == "SC5"
   	_cNum   := GetSXENum(_alias,_campo,"  \DATA\"+RETSQLNAME("SC5"),24)//GetSXENum(_cAlias,_cCpo)
   Else
    _cNum   := GetSXENum(_alias,_campo)
   Endif 

		
Enddo

U_ITConout("****** //// Atualizando Hardlock - Registro Final: " + ALLTRIM(_cNum) + " de " + ALLTRIM(STT->MAXIMO)+"   \\\\******")
U_ITConout("****** \\\\ Final da Atualização do Numerador do " + _alias + ": "+TIME()+"   ////******")

_lAtuSC5 := .F.

Return 

