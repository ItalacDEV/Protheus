/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich     | 22/01/2019 | Prote��o para gatilho n�o dar erro no Totvs colabora��o - Chamado 27791 
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 04/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges      | 03/09/2020 | Inclu�da grava��o da TES para gera��o de documentos classificados. Chamado 34024
=============================================================================================================================== 
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'
#INCLUDE "APWEBSRV.CH"

/*
===============================================================================================================================
Programa----------: MT103PN
Autor-------------: Julio de Paula Paz
Data da Criacao---: 09/12/2016
===============================================================================================================================
Descri��o---------: PE na nota fiscal de entrada, ap�s a monstagem do acols e antes da montagem da tela.
					Este ponto de entrada pertence � rotina de manuten��o de documentos de entrada, MATA103. 
					Localiza��o: � executada em A103NFISCAL, na inclus�o de um documento de entrada. Ela permite ao usu�rio 
					decidir se a inclus�o ser� executada ou n�o.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Retorno l�gico: .T. = a rotina segue normalmente, .F. = a rotina � cancelada.
===============================================================================================================================
*/  
User Function MT103PN

Local _lRet := .T.
Local _ng
 
Begin Sequence
   //Gatilha campos a partir do pedido ou     
   For _ng := 1 To Len(aCols)
     GATGERAL(_ng) //Chama rotina de gatilho de campos
   Next
End Sequence

Return _lRet

/*
===============================================================================================================================
Programa----------: GATCCPED
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 09/12/2016
===============================================================================================================================
Descri��o---------: Gatilho de centro de custo a partir do campo de produto/pedido da nota de entrada
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _cCC - centro de custo
===============================================================================================================================
*/  
User Function GATCCPED()

Local _nPosCC	:= 0
Local _cCC 		:= space(30)

If funname() == "MATA140" .OR. funname() == "MATA103" .OR. funname() == "COMXCOL"

	_nPosCC := aScan( aHeader , {|x| UPPER( Alltrim(x[2]) ) == "D1_CC" } )
	
	If n > 0
		_cCC := acols[n][_nPosCC]
		//Chama rotina de gatilho de campos
		_cCC := GATGERAL(n)
	EndIf

EndIf

Return _cCC

/*
===============================================================================================================================
Programa----------: GATGERAL
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 09/12/2016
===============================================================================================================================
Descri��o---------: Carga de gatilhos de campos no acols do mata103
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _cCC - centro de custo
===============================================================================================================================
*/  
Static Function GATGERAL(_ni)

Local _nPosTes, _nPosCC, _nPosPedido,_nPosItem, _nPosProd 
Local _cChaveSC7, _cCCusto, _cChaveSB1, _cChaveZFX
Local _aAreaSC7   := SC7->(GetArea())
Local _aAreaSB1   := SB1->(GetArea())
Private _cRet_TN := U_PosPedFaT(  cA100For+cLoja  ,  CNFISCAL+CSERIE  ) //Define se � pedido troca nota


SC7->(DbSetOrder(1)) // C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD    
ZFX->(DbSetOrder(1)) // ZFX_FILIAL+ZFX_PRODUT+ZFX_CCUSTO  
   
_nPosTes    := aScan( aHeader , {|x| UPPER( Alltrim(x[2]) ) == "D1_TES" } )
_nPosCC     := aScan( aHeader , {|x| UPPER( Alltrim(x[2]) ) == "D1_CC" } )
_nPosPedido := aScan( aHeader , {|x| UPPER( Alltrim(x[2]) ) == "D1_PEDIDO" } )
_nPosItem   := aScan( aHeader , {|x| UPPER( Alltrim(x[2]) ) == "D1_ITEMPC" } )
_nPosProd   := aScan( aHeader , {|x| UPPER( Alltrim(x[2]) ) == "D1_COD" } )
_nPosoPER   := aScan( aHeader , {|x| UPPER( Alltrim(x[2]) ) == "D1_OPER" } )
_nPosCLAS   := aScan( aHeader , {|x| UPPER( Alltrim(x[2]) ) == "D1_CLASFIS" } )
_nPosLOCA   := aScan( aHeader , {|x| UPPER( Alltrim(x[2]) ) == "D1_LOCAL" } )

BEGIN SEQUENCE
   _cCCusto := ""
   _cChaveSC7 := ""
   _cChaveSB1 := ""
   _cChaveZFX := ""

   If ! Empty(aCols[_nI,_nPosPedido])
      _cChaveSC7 := xFilial("SC7") + aCols[_nI,_nPosPedido] + aCols[_nI,_nPosItem]
   EndIf

   If ! Empty(aCols[_nI,_nPosProd])
      _cChaveSB1 := xFilial("SB1") + aCols[_nI,_nPosProd] 
      _cChaveZFX := xFilial("ZFX") + aCols[_nI,_nPosProd] 
   Else
      Break
   EndIf

   _cChaveFOR := xfilial("ZFX") + CA100FOR + CLOJA

   //==============================================================
   // Localiza centro de custo no item do Pedido de Compras     
   //==============================================================
   If !Empty(_cChaveSC7) .And. SC7->(DbSeek(_cChaveSC7)) .And. ! Empty(SC7->C7_CC)
      _cCCusto := SC7->C7_CC
   EndIf

   //==============================================================
   // Localiza centro de custo no Cadastro de Produtos.
   //==============================================================
   If Empty(_cCCusto) .And. !Empty(_cChaveSB1) .And. SB1->(DbSeek(_cChaveSB1))
      _cCCusto := SB1->B1_CC
   EndIf

   //==============================================================
   // Localiza centro de custo novo cadastro de amarra��o 
   // Filial x Produto x Centro de Custo
   //==============================================================   
   ZFX->(Dbsetorder(1))
   If Empty(_cCCusto) .And. !Empty(_cChaveZFX) .And. ZFX->(DbSeek(_cChaveZFX))    
      _cCCusto := ZFX->ZFX_CCUSTO
   EndIf

   //==============================================================
   // Localiza centro de custo novo cadastro de amarra��o 
   // Filial x Fornecedor x Centro de Custo
   //==============================================================     
   ZFX->(Dbsetorder(3))
   If Empty(_cCCusto) .And. !Empty(_cChaveFOR) .And. ZFX->(DbSeek(_cChaveFOR))
      _cCCusto := ZFX->ZFX_CCUSTO
   EndIf

   //==========================================================
   // Atualiza o centro de custo do item da nota de entrada.
   //==========================================================
   If ! Empty(_cCCusto) .And. Empty(aCols[_nI,_nPosCC])
      aCols[_nI,_nPosCC] := _cCCusto
   EndIf

   //==========================================================
   //Atualiza campos se for troca nota
   //==========================================================
   If _cRet_TN == "ACHOU_PF"
      n := _ni

      If SB1->B1_GRUPO == '0813' //� Pallet
         //Campo D1_TES, gatilhos e valida��es
         If _nPosTES > 0
            aCols[_nI,_nPosTES] := MaTesInt(1,'03',cA100For,cLoja,If(cTipo$"DB","C","F"),SB1->B1_COD,"D1_TES")  
            MaAvalTes("E",aCols[_nI,_nPosTES])
            MaFisRef("IT_TES","MT100",aCols[_nI,_nPosTES]) 
         EndIf
         //Campo D1_CLASFIS, gatilhos e valida��es
         If _nPosTES > 0
            aCols[_nI,_nPosCLAS] := Subs(SB1->B1_ORIGEM,1,1)+POSICIONE("SF4",1,xFilial()+SB1->B1_TE,'F4_SITTRIB')
            MAFISREF("IT_CLASFIS","MT100",aCols[_nI,_nPosCLAS]) 
         EndIf
         //Campo D1_CC, gatilhos e valida��es
       	If _nPosCC > 0 .And. Empty(aCols[_nI,_nPosCC])                                                                                       
            aCols[_nI,_nPosCC] := U_ITGETMV("ITCCTRCNP"," ")
         EndIf
         //Campo D1_OPER, gatilhos e valida��es
         If _nPosoPER > 0
            aCols[_nI,_nPosoPER] := '03'
            MTA103TROP(_nI)
         EndIf
         //Campo D1_LOCAL, gatilhos e valida��es                                                                        
         If _nPosLOCA > 0
            aCols[_nI,_nPosLOCA] := '40'
         EndIf
      Else //N�o � pallet
         //Campo D1_TES, gatilhos e valida��es
         If _nPosTES > 0
            aCols[_nI,_nPosTES] := MaTesInt(1,'03',cA100For,cLoja,If(cTipo$"DB","C","F"),SB1->B1_COD,"D1_TES")  
            MaAvalTes("E",aCols[_nI,_nPosTES])
            MaFisRef("IT_TES","MT100",aCols[_nI,_nPosTES])
         EndIf
         //Campo D1_CLASFIS, gatilhos e valida��es                                                             
       	If _nPosCLAS > 0
            aCols[_nI,_nPosCLAS] := Subs(SB1->B1_ORIGEM,1,1)+POSICIONE("SF4",1,xFilial()+SB1->B1_TE,'F4_SITTRIB')
            MAFISREF("IT_CLASFIS","MT100",aCols[_nI,_nPosCLAS]) 
         EndIf
         //Campo D1_CC, gatilhos e valida��es
         If _nPosCC > 0 .And. Empty(aCols[_nI,_nPosCC])                                                                                     
            aCols[_nI,_nPosCC] := U_ITGETMV("ITCCTRCNF","  ")
         EndIf
         //Campo D1_OPER, gatilhos e valida��es
         If _nPosoPER > 0
            aCols[_nI,_nPosoPER] := '03'
            MTA103TROP(_nI)
         EndIf
         //Campo D1_LOCAL, gatilhos e valida��es
         If _nPosLOCA > 0
            aCols[_nI,_nPosLOCA] := '40'
         EndIf
      EndIf
   EndIf

END SEQUENCE

RestArea(_aAreaSC7)
RestArea(_aAreaSB1)

Return aCols[_nI,_nPosCC]
