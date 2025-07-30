/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 29/12/2020 | Inclu�dos os tratamentos para todas as filiais. Chamado 34986
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 03/05/2022 | Ajuste na grava��o do Tipo de Opera��o. Chamado 39985
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 22/05/2022 | Ajuste na grava��o do Tipo de Opera��o. Chamado 40178
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa--------: COMCOLF4
Autor-----------: Lucas Borges Ferreira
Data da Criacao-: 03/06/2020
===============================================================================================================================
Descri��o-------: Permite alterar e validar a TES utilizada no monitor do totvs colabora��o
				 LOCALIZA��O: No monitor Totvs Colabora��o
===============================================================================================================================
Parametros--------: ParamIxb[01] -> C -> Fornecedor
                    ParamIxb[02] -> C -> Loja
                    ParamIxb[03] -> C -> Produto
                    ParamIxb[04] -> C -> TES
===============================================================================================================================
Retorno---------: cTes -> C -> TES
===============================================================================================================================
*/
User Function COMCOLF4

Local _cTes     := PARAMIXB[4]
Local _nEntSai  := 1 //Documento de 1-Entrada / 2-Saida
Local _cTpOper  := ''//C�digo da TES Inteligente
Local _cClieFor := PARAMIXB[1]//Codigo do Cliente ou Fornecedor
Local _cLoja    := PARAMIXB[2]//Codigo da Loja do Cli/Forn 
Local _cTipoCF  := IIf(SDS->DS_TIPO $ 'B/D','C','F') //Tipo Cliente / Fornecedor
Local _cProduto := PARAMIXB[3]//Codigo do produto
Local _cCampo   := ''//Campo que contem a TES
Local _cTipoCli := ''//Tipo Cliente (F=Cons.Final;L=Prod.Rural;R=Revendedor;S=Solidario;X=Exportacao/Importacao)
Local _cEstOrig := ''//Estado de Origem do documento
Local _cOrigem  := ''//

//CT-e n�o tem CFOP, logo, a regra deve ser explicida.
If AllTrim(SDS->DS_ESPECI) == 'CTE' //Opera��es com CT-e
    If SDS->DS_UFORITR == SDS->DS_UFDESTR//SDS->DS_EST == SM0->M0_ESTENT
        _cTpOper := '10'
    Else
        _cTpOper := '11'
    EndIf
//ElseIf SDS->DS_FORNEC == "F00001" //Opera��es com NF-e de transfer�ncia de produto acabado(troca de notas) e leite
    //_cTpOper := '03'
//ElseIf SubStr(SDS->DS_FORNEC,1,1) $ "L" //Opera��es com NF-e de compra de Leite
    //_cTpOper := '01'
EndIf
//Demais documentos consigo buscar o tipo de opera��o pelo CFOP
If Empty(_cTpOper)
    _cTpOper := ColConDHJ(SDT->DT_CODCFOP)
EndIf
//O MaTesInt � executado logo antes de chamar o PE, por�m ele nem sempre ter� o Tipo de Opera��o para fazera busca correta.
//Infelizmente � necess�rio chamar a fun��o de novo, mesmo prejudicando a performance. No COMXCOL ela s� � executada se n�o localizar
//uma TES, seja no pedido, na devolu��o ou na SDT. J� aqui eu sempre executo ela e ignoro o conte�do anterior, conforme definido pela
//Luciane e Samir. O que prevalece � a TES inteligente e n�o o que o usu�rio informar.
If !Empty(_cTpOper)
    _cTes:= MaTesInt(_nEntSai,_cTpOper,_cClieFor,_cLoja,_cTipoCF,_cProduto,_cCampo,_cTipoCli,_cEstOrig,_cOrigem)
EndIf

Return _cTes
