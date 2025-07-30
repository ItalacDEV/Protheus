/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Analista     - Programador  - Inicio   - Envio    - Chamado - Motivo da Altera��o
======================================================================================================================================================
Ant�nio       - Julio Paz    - 07/03/25 - 10/04/25 - 48312   - Validar a transmiss�o de nota fiscal de devolu��o de remessa em opera��es triangular.
======================================================================================================================================================
*/

// Definicoes de Includes e Defines da Rotina.
#include "Protheus.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "PARMTYPE.CH"
/*
===============================================================================================================================
Fun��o-------------: FISVALTRANS()
Autor--------------: Julio de Paula Paz
Data da Criacao----: 07/03/2025
Descri��o----------: Ponto de entrada chamado na valida��o da transmiss�o da nota fiscal de entrada e sa�da para o NFE Sefaz.
Parametros---------: ParamIxb = Array com os numeros da nota fiscal.
Retorno------------: _lRet = .T. = Valida��o Ok.
                           = .F. = Inconsistencia na valida��o.
===============================================================================================================================
*/
User Function FISVALTRANS()
Local _lRet := .T.        //          1                2           3        4        5      6    7    8    
Local _aParam := ParamIxb //{{{"0" = NFE Entrada , Data_Emiss�o, Serie, Numero NF,Cliente, Loja ,{},Chave_NFE},;
                          //  {"1" = NFE Saida   , Data_Emiss�o, Serie, Numero NF,Cliente, Loja ,{},Chave_NFE},;
                          //  {"0"               , Data_Emiss�o, Serie, Numero NF,Cliente, Loja ,{},Chave_NFE},;
                          //  {"0"               , Data_Emiss�o, Serie, Numero NF,Cliente, Loja ,{},Chave_NFE}}}
Local _nI
Local _nJ 
Local _aNotas := {}
Local _aOrd := SaveOrd({"SF2","SC5","SF1","SD1"}) 
Local _cNfOrig
Local _cSerieOri
Local _cFornece
Local _cLoja 

Begin Sequence
      
   SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM

   //=======================================================================
   // Faz as valida��es das notas fiscais de opera��o triangular: 42 e 05.
   // N�o permite a transmiss�o de notas fiscais de devolu��o de remessa,
   // opera��o 42 sem que as notas fiscais de opera��o 05 sejam estornadas.
   //=======================================================================
   For _nI := 1 To Len(_aParam)
       _aNotas := AClone(_aParam[_nI])
       
       For _nJ := 1 To Len(_aNotas)
           If _aNotas[_nJ,1 ] == "0"  // NFE de Entrada. 
              //===============================================================================
              // Posiciona a nota fiscal de entrada.
              //=============================================================================== 
              SD1->(DbSetOrder(1)) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
                         // D1_FILIAL    + D1_DOC        +D1_SERIE       +D1_FORNECE     +D1_LOJA
              SD1->(MsSeek(xFilial("SD1")+_aNotas[_nJ,4 ]+_aNotas[_nJ,3 ]+_aNotas[_nJ,5 ]+_aNotas[_nJ,6 ]))        
              _cNfOrig   := ""
              _cSerieOri := ""
              _cFornece  := ""
              _cLoja    := ""

              Do While ! SD1->(Eof()) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == xFilial("SD1")+_aNotas[_nJ,4 ]+_aNotas[_nJ,3 ]+_aNotas[_nJ,5 ]+_aNotas[_nJ,6 ]
                 If ! Empty(SD1->D1_NFORI)
                    _cNfOrig   := SD1->D1_NFORI
                    _cSerieOri := SD1->D1_SERIORI
                    _cFornece  := SD1->D1_FORNECE
                    _cLoja    := SD1->D1_LOJA
                 EndIf 

                 SD1->(DbSkip())
              EndDo 
              If ! Empty(_cNfOrig)
                 //====================================================================
                 // Busca a nota fiscal de origem na tabela SF2.
                 //====================================================================
                 SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO 

                 If SF2->(MsSeek(xFilial("SF2") + _cNfOrig + _cSerieOri + _cFornece + _cLoja)) 
                    //===============================================================
                    // Busca o Pedido de Vendas da Nota Fiscal de Devolu��es.
                    //===============================================================
                    If SC5->(MsSeek(SF2->F2_FILIAL+SF2->F2_I_PEDID))
                       If SC5->C5_I_OPER == "42" // Nota Fiscal de Entrada do Pedido de Vendas de Remessa.
                          If ! Empty(SC5->C5_I_PVFAT)
                             SF2->(DbSetOrder(20)) // F2_FILIAL+F2_I_PEDID  
                             //=================================================
                             // Busca a nota fiscal de faturamento
                             //=================================================
                             If SF2->(MsSeek(SC5->C5_FILIAL+SC5->C5_I_PVFAT))
                                //============================================================================
                                // Verifica se a nota fiscal de faturamento possui nota fiscal de devolu��o.
                                //============================================================================ 
                                SD1->(DbSetOrder(19)) // D1_FILIAL+D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA
                                If ! SD1->(MsSeek(SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
                                   U_ItMsg("Esta � uma nota fiscal de devolu��o de opera��o triangular de remessa (42). "+ CRLF +;
                                           "Nota: "+ AllTrim(SF2->F2_DOC) + ", Serie: "  + AllTrim(SF2->F2_SERIE) + ". " + CRLF +;
                                           "Existe uma nota fiscal de faturamento de opera��o triangular (05) que ainda n�o foi devolvida.",;
                                           "Aten��o",;
                                           "Favor comunicar � �rea respons�vel para realizar a devolu��o da outra opera��o.",2)
                                   //_lRet := .F.
                                   //Break
                                EndIf 
                             EndIf 
                          EndIf 
                       EndIf 
                    EndIf 
                 EndIf  
              EndIf 
           EndIf 

       Next _nJ

   Next _nI

End Sequence

//=======================================================================
// Volta a ordem dos indices e a posi��o dos ponteiros de registro.
//=======================================================================
RestOrd(_aOrd,.T.)

Return _lRet
