/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 23/07/2021 | Implementado tratamento para o vencimento das devolu��es. Chamado 37255
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 02/08/2021 | Corrigida a valida��o para o PE n�o ser chamado indevidamente. Chamado 37339
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 29/08/2024 | Retirada a valida��o do l103Auto. Chamado 48274
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: MTCOLSE2
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 29/12/2020
===============================================================================================================================
Descri��o---------: Ponto de entrada para manipular os dados do aCols de t�tulos a pagar
===============================================================================================================================
Parametros--------: PARAMIXB[1] -> A -> aCols das duplicatas
					PARAMIXB[2] -> N -> 0 - Visualiza��o do documento / 1 - Inclus�o ou Classifica��o do documento
===============================================================================================================================
Retorno-----------: aColsE2 -> A -> aCols manipulado pelo usu�rio.
===============================================================================================================================
*/
User Function MTCOLSE2

Local _aArea    := GetArea()
Local _aAreaSDS := SDS->(GetArea())
Local _aColsE2  := PARAMIXB[1] //aCols de duplicatas
Local _nOpc     := PARAMIXB[2] //0-Tela de visualiza��o / 1-Inclus�o ou Classifica��o
Local _cXML     := ""
Local _oXML     := Nil
Local _cError	:= ''
Local _cWarning	:= ''
Local _lRet     := .F.

//lRefresh e FWIsInCallStack("NFEEMISSAO") -> evita que a rotina seja executada ap�s o usu�rio realizar o ajuste e confirmar a inclus�o, sobreponto um poss�vel ajuste no vencimento
If _nOpc == 1 .And. cFormul == "N" .And. cTipo == "D" .And. l103GAuto .And. lRefresh .And. !FWIsInCallStack("NFEEMISSAO")
    DBSelectArea('CKO')
	CKO->( DBSetOrder(1) )
    SDS->( DBSetOrder(2) )
    If SDS->( DBSeek(xFilial("SDS")+aNFeDanfe[13] ) )
        CKO->( DBSeek( SDS->DS_ARQUIVO ) )
        _cXML := AllTrim( CKO->( CKO_XMLRET ) )
        //====================================================================================================
        // Processa se conseguir ler os dados do arquivo XML
        //====================================================================================================
        If !Empty( _cXML )
            _cXML := SubStr( _cXML , At( '<' , _cXML ) )
            //====================================================================================================
            // Inicializa o objeto do XML
            //====================================================================================================
            _oXML := XmlParser( _cXML , "_" , @_cError , @_cWarning )
            If !Empty(_oXml) .And. ValType(_oXml)=="O"
                If ValType(XmlChildEx(_oXml,"_NFEPROC")) == "O"
                    If ValType(XmlChildEx(_oXML:_NFeProc:_NFe:_InfNfe,"_COBR")) != "U"
                        If ValType(XmlChildEx(_oXML:_NFeProc:_NFe:_InfNfe:_cobr,"_DUP")) != "U"
                            _dVencto := StoD(StrTran(AllTrim(IIf(ValType(XmlChildEx(_oXML:_NFeProc:_NFe:_InfNfe:_cobr,"_DUP"))=="O",_oXML:_NFeProc:_NFe:_InfNfe:_cobr:_dup:_dVenc:Text,_oXML:_NFeProc:_NFe:_InfNfe:_cobr:_dup[1]:_dVenc:Text)),"-",""))
                            If _dVencto < dDataBase
                                _aColsE2[1][2] := dDataBase//Se j� est� vencida, usa a data atual
                                _lRet := .T.
                            Else
                                _aColsE2[1][2] :=_dVencto//Se n�o est� vencida, usa o vencimento informado
                                _lRet := .T.
                            EndIf
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf
    If !_lRet
        _aColsE2[1][2] := LastDay(MonthSum( dDatabase,1),1)//Primeiro dia �til do m�s subsequente ao lan�amento
    EndIf
    _oXML := Nil
    DelClassIntF()
EndIf

RestArea(_aAreaSDS)
RestArea(_aArea)

Return (_aColsE2)
