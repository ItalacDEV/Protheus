/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor    |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 ==============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

/*
===============================================================================================================================
Programa----------: M410AGRV
Autor-------------: Alex Wallauer Ferreira
Solicitante-------: Andre Carvalho
Data da Criacao---: 14/07/2023
===============================================================================================================================
Descri��o---------: Chamado 44097. P. E. antes de opera��es de Inclus�o/Exclus�o/C�pia/Altera��o no Pedido de Vendas.
------------------: Executa da Fun��o A410Grava() dentro do programa MATN410.PRW 
===============================================================================================================================
Parametros--------: PARAMIXB[1] = indica a opera��o: 1 - inclus�o / 2 - altera��o / 3 - exclus�o	
===============================================================================================================================
Retorno-----------: .T. => O programa n�o faz nada com o retorno.
===============================================================================================================================
*/
User Function M410AGRV()
Local _nOpc:= PARAMIXB[1]  // indica a opera��o: 1 - inclus�o / 2 - altera��o / 3 - exclus�o	
Local _nX
Local _nColPr,_nColCF,_nColCS,_nColOC,_nColOF
Local _cITFLNT2104,_cITGPNT2104,_cITCFNT2104,_cITCSNT2104

If  _nOpc == 3// SE � EXCLUSAO N�O FAZ NADA
   RETURN .T.
EndIf

_nColPr:=aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_PRODUTO' } ) 
_nColCF:=aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_CF'      } ) 
_nColCS:=aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_CLASFIS' } ) 
_nColOC:=aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_OBSFCMP' } ) 
_nColOF:=aScan( aHeader , {|x| AllTrim( Upper(x[2]) ) == 'C6_OBSFISC' } ) 

_cITFLNT2104:= U_ITGETMV("ITFLNT2104","93/95/96/97/98")//Par�metro para controlar filiais: ITFLNT2104;
_cITGPNT2104:= U_ITGETMV("ITGPNT2104","0001/0003/0004/0005/0008/0018/0019/0022")//Par�metro para definir grupo de produtos: ITGPNT2104;
_cITCFNT2104:= U_ITGETMV("ITCFNT2104","5403")          //Par�metro para definir CFOPs: ITCFNT2104;
_cITCSNT2104:= U_ITGETMV("ITCSNT2104","010")           //Par�metro para definir CSTs: ITCSNT2104;

// // Criar em ponto de entrada na grava��o dos pedidos de venda (MATA410) para quando:
// // - filiais --> 93, 95, 96, 97 e 98
// // - grupo de produtos --> 0001/0003/0004/0005/0008/0018/0019/0022
// // - C6_CF(CFOP) e c6_ (CST) --> 5403, 10
// // Gravar os campos com os seguintes conte�dos:
// // - C6_OBSFCMP --> "cBenef"
// // - C6_OBSFISC --> "PR830001"

IF xFilial("SC5") $ _cITFLNT2104
   For _nX := 1 To Len( aCols )
       IF LEFT(aCols[_nX,_nColPr],4) $ _cITGPNT2104 .AND.;
	      ALLTRIM(aCols[_nX,_nColCF]) $ _cITCFNT2104 .AND. ALLTRIM(aCols[_nX,_nColCS]) $ _cITCSNT2104
   
          aCols[_nX,_nColOC] := "cBenef"
          aCols[_nX,_nColOF] := "PR830001"
       ENDIF
   NEXT
ENDIF

Return( .T. )

