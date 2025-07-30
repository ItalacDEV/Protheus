/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           |
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges      | 05/04/2021 | Alterada regra das naturezas. Chamado 36141
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges      | 03/05/2022 | Tratamento para buscar natureza do Cadastro de TES Inteligente. Chamado 39985
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: MT103NTZ
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 29/12/2020
===============================================================================================================================
Descri��o---------: Este Ponto de Entrada tem por objetivo selecionar a natureza no Documento de Entrada. Ele � chamado em quase
                    todos os pontos do MATA103: ao clicar na aba duplicadas, no browse, ao editar c�lulas. N�o � chamado quando 
                    a origem � o TOTVS Colabora��o.
===============================================================================================================================
Parametros--------: ParamIxb[1] -> A -> Natureza
===============================================================================================================================
Retorno-----------: cNatureza -> C -> Natureza
===============================================================================================================================
*/
User Function MT103NTZ()

Local _cNatOri  := ParamIxb[1]
Local _cNature  := Space(Len(ParamIxb[1]))
Local _nI		:= 0
Local _nEntSai  := 1 //Documento de 1-Entrada / 2-Saida
Local _cTpOper  := ' '//C�digo da TES Inteligente
Local _cTipoCF  := IIf(cTipo $ 'B/D','C','F') //Tipo Cliente / Fornecedor
Local _cProduto := ""//Codigo do produto
Local _cCampo   := ''//Campo que contem a TES
Local _cTipoCli := ''//Tipo Cliente (F=Cons.Final;L=Prod.Rural;R=Revendedor;S=Solidario;X=Exportacao/Importacao)
Local _cEstOrig := ''//Estado de Origem do documento
Local _cOrigem  := ''//

If !IsInCallStack("U_MGLT009") .And. (;//N�o executa no fechamento do leite
    !(FWIsInCallStack("NFEEMISSAO") .Or. FWIsInCallStack("EDITCELL") .Or. FWIsInCallStack("NFECABOK") .Or. FWIsInCallStack("NFEVLDREF")) .Or.;//n�o executar em qualquer dessas situa��es: click no browse - Edita/clica c�lula - valida cabe�alho - Digita natureza
    (!FWIsInCallStack("NFECABOK") .And. FWIsInCallStack("SAFEEVAL"))) //Executa no clique do Salvar, na segunda, de tr�s chamadas. Na primeira e �ltima o NFECABOK est� na pilha.

    If cTipo == "D"
        _cNature := SuperGetMV("IT_DEVNATU",.F.,"410001")
    //N�o achei forma melhor de evitar que passe nesse trecho ao informar o vencimento.
    //Ele usa o mesmo aCols para os dados da duplicata
    ElseIf Len(aHeader) > 100 .And. Empty(_cNature)
        For _nI := 1 To Len( aCols )
            _cProduto := AllTrim(aCols[_nI][aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'D1_COD'})])
            _cTpOper  := AllTrim(aCols[_nI][aScan(aHeader,{|x| Upper(AllTrim(x[2])) == 'D1_OPER'})])
            
            If !Empty(_cTpOper)
                _cNature:= U_MaNatInt(_nEntSai,_cTpOper,cA100For,cLoja,_cTipoCF,_cProduto,_cCampo,_cTipoCli,_cEstOrig,_cOrigem)
            EndIf
            If !Empty(_cNature)
                Exit
            EndIf
        Next _nI
    EndIf
    //S� pergunto se deseja manter a natureza informada manualmente se for na confirma��o do documento
    If !l103Auto .And. !Empty(_cNature) .And. !Empty(_cNatOri) .And. AllTrim(_cNatOri) <> AllTrim(_cNature);
        .And. FWIsInCallStack("SAFEEVAL") .And.;
        MsgYesNo("A natureza identificada no cadastro de TES Inteligente '"+AllTrim(_cNature)+"' est� diferente da informada no documento '"+AllTrim(_cNatOri)+"'. "+;
                    "Deseja manter a Natureza informada no documento?","MT103NTZ01")
       _cNature := _cNatOri
    EndIf
EndIf
If Empty(_cNature)// Preenche com o conte�do recebido/digitado no campo quando nenhuma regra preenche o conte�do. Usado para manter o conte�do sem altera��o
    _cNature := _cNatOri
EndIf

Return (_cNature)
