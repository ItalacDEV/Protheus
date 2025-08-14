/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 25/09/2017 | Volta do código de segurança para não zerar o numero do PV - Chamado 21574
 Josué Danich     | 20/12/2018 | Universalização da rotina - Chamado 27443 
======================================================================================================================================================================================================
 Analista    - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
======================================================================================================================================================================================================
Jerry        - Alex WALLAUER - 30/01/25 - 05/08/25 - 37652   - Ajuste para poder melhorar a mensagem de processamento.
Jerry        - Igor Melgaço  - 07/08/25 - 07/08/25 - 51690   - Ajuste para correção de Error.log ao tentar criar a area STT.
======================================================================================================================================================================================================
*/
#include "Protheus.ch"

STATIC _lAtuSC5 := .F.
STATIC _cNumSC5 := ""

/*
===============================================================================================================================
Programa----------: AOMS089
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/12/2016
Descrição---------: Rotina de segurança para atualizar hardlock  - Chamado 18103
Parametros--------: _lauto - Rodando de schedule?
                    _alias - alias
                    _campo - campo
                    _lshow - mostra mensagens
                    _cfilial - filial do numerador
Retorno-----------: _cNum -> próximo número de pedido de vendas
===============================================================================================================================
*/
User Function AOMS089(_lauto As Logical, _alias As Character, _campo As Character, _lshow As Logical, _cfilial As Character) As Character
 Local _cQuery  := "" As Character
 Local _aArea   := GetArea() As Array
 Local _cAlias  := GetNextAlias() As Character

 Private _cNum  := "" As Character

 Default _alias := "SC5"
 Default _campo := "C5_NUM"
 Default _lshow := .T.
 Default _cfilial := "99"
 
 IF VALTYPE(_lauto) <> "L"
    _lauto := .T.
 ENDIF
 
 If _lauto
 
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
    
 MPSysOpenQuery( _cQuery , _cAlias )

 DBSelectArea(_cAlias)
 (_cAlias)->( DBGoTop() )
 
 If !(_cAlias)->(Eof())
 
    _lAtuSC5:= .T.
    _cNumSC5:= ALLTRIM((_cAlias)->MAXIMO)
    
    If _alias == "SC5"
       _cNum   := GetSXENum(_alias,_campo,"  \DATA\"+RETSQLNAME("SC5"),24)//GetSXENum(_cAlias,_cCpo)
    Else
       _cNum   := GetSXENum(_alias,_campo)
    Endif 
 
    IF LEN(ALLTRIM(_cNum)) = LEN(ALLTRIM((_cAlias)->MAXIMO))
      If _lauto .or. !_lshow
         AOMS089T(_lauto,_alias,_cAlias,_campo,_lshow)
      Else
         FwMsgRun( , {|oProc|  AOMS089T(.F.,_alias,_cAlias,_campo,.T.,oProc) }, , "Atualizando hardlock do "+_campo,"Atualizando hardlock do "+_campo) 
      Endif
    ELSE
       U_ITMSG("Numerador do Hardlock esta com o tamanho diferente do campo: " + _campo,"Tamanho do numerador",;
               "Tamanhos: "+STR(LEN(ALLTRIM(_cNum)),1)+" # "+STR(LEN(ALLTRIM((_cAlias)->MAXIMO)),1)+". Entrar em contato com area de TI.",1)
    Endif
    
 Endif
 
 (_cAlias)->(Dbclosearea())	
 
 RestArea(_aArea)

Return _cNum

/*
===============================================================================================================================
Programa----------: AOMS089P
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/12/2016
Descrição---------: Roda atualização de hardlock - Chamado
Parametros--------: _lauto - Se está rodando em schedule
                    _alias - alias
                    _campo - campo
                    _lshow - se mostra mensagens
                    oProc  - mensagens
Retorno-----------: nenhum
===============================================================================================================================
*/
Static Function AOMS089T(_lauto As Logical, _alias As Character,_cAlias As Character, _campo As Character, _lshow As Logical, oProc As Object)

 Do while ALLTRIM(_cNum) <= ALLTRIM((_cAlias)->MAXIMO)
 
    If !_lauto .and. _lshow
      oProc:cCaption:=("Atualizando Hardlock, Codigo: de " + ALLTRIM(_cNum) + " ate " + ALLTRIM((_cAlias)->MAXIMO))
      ProcessMessages()
    Endif
 
    Confirmsx8(.F.)
    If _alias == "SC5"
       _cNum:= GetSXENum(_alias,_campo,"  \DATA\"+RETSQLNAME("SC5"),24)//GetSXENum(_cAlias,_cCpo)
    Else
       _cNum:= GetSXENum(_alias,_campo)
    Endif 
 Enddo
 
 _lAtuSC5 := .F.

Return 

