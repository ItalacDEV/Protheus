/*
===============================================================================================================================
                          ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
     Autor    |    Data  |                              Motivo                                                          
===============================================================================================================================
 Julio Paz    | 30/03/20 | Chamado 32094. No desmembramento de Pedidos vendas, manter as datas do pedido vendas original.
 Jonathan     | 23/10/20 | Chamado 34310. Novos campos sendo gravados no pedido desmembrado.
 Julio Paz    | 21/01/21 | Chamado 35183. Inclusão de tratamento para comissões do novo Gerente Nacional.   
 Julio Paz    | 13/09/21 | Chamado 37713. Alterar rotina desmembramento p/gravar conteúdo de novos campos do Pedido origem.
 Julio Paz    | 21/09/21 | Chamado 31101. Alterar rotina p/considerar fator conversão Italac quando fator padrão for zero.
 Julio Paz    | 02/02/23 | Chamado 42330. Corrigir a Rotina Desmembramento PV/integração RDC para gravar o campo C6_ITEMPC. 
 Julio Paz    | 13/03/23 | Chamado 43219. Permitir desmembramento de Pedidos de Vendas operação Triangular (Tipo oper.42).  
 Alex Wallauer| 22/08/23 | Chamado 44799. Ajuste da função ITMSG de erro para receber um texto do botão "Mais Detalhes".
 Alex Wallauer| 04/06/24 | Chamado 47445. Se o Pedido original for C5_TPFRETE = R gravar o novo Pedido com o tipo = C-"CIF".
 Jerry        | 26/06/24 | Chamado 47655. Jerry. Correção error log do campo C5_I_OPTRI
 Igor Melgaço | 01/07/24 | Chamado 47184. Jerry. Ajustes para gravação do campo C6_I_PRMIN
==============================================================================================================================================================
Analista    - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
Vanderlei   - Alex Wallauer - 19/03/25 - 21/03/25 - 50197   - Novo tratamento para cortes e desmembramentos de pedidos.
Vanderlei   - Alex Wallauer - 24/03/25 - 24/03/25 - 50197   - Novo tratamento para cortes e desmembramentos de pedidos.
Jerry       - Alex Wallauer - 01/04/25 - 02/04/25 - 50335   - Ajustes do tratamento para cortes e desmembramentos de pedidos.
Vanderlei   - Alex Wallauer - 06/06/25 - 10/06/25 - 45229   - Ajustes do tratamento do retorno das mensagens.
Vanderlei   - Alex Wallauer - 09/06/25 - 10/06/25 - 45229   - Tratamento para validar FWIsInCallStack("U_AOMS085B") junto com FWISINCALLSTACK("U_ALTERAP").
==============================================================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#Include 'Protheus.ch'
/*
===============================================================================================================================
Programa----------: AOMS098
Autor-------------: Julio de Paula Paz
Data da Criacao---: 12/04/2017
===============================================================================================================================
Descrição---------: Rotina de gravação dos dados de  Desmembramento de Pedidos de Vendas. - Chamado 16681
===============================================================================================================================
Parametros--------: _cFilial = Código da Filial
                    _cPedido = Numero do Pedido de Vendas
                    _aItensPedido = Array de duas colunas, podendo ter nLinhas, contendo: {Numero_do_Item, quantidade_do_item}
                    _ccodusuario - Código do usuário a ser gravado no C5_USRLGA
===============================================================================================================================
Retorno-----------: Array com três posições contendo: {_lSucesso, _numero_novo_pedido,_cMensagem_Retorno}
                    _lSucesso = Variável do tipo lógico, indica se hove ou não sucesso no desmembramento do pedido de vendas.
                    _numero_novo_pedido = numero do novo pedido de vendas.
                    _cMensagem_Retorno = Mensagem retornada tanto no sucesso como na falha do desmembramento do pedido de vendas.
===============================================================================================================================
*/  
User Function AOMS098(_cFilial,_cPedido,_aItensPedido,_ccodusuario)

Local _aCabPV, _aItemPV, _aItensPV 
Local _aCabPVNovo, _aItemPVNovo, _aItensPVNovo 
Local _aRet
Local _aOrd:= SaveOrd({"SC5","SC6"})
Local _nRegSC5, _nRegSC6
Local _cMsg, _lSucesso, _cNumPed
Local _cItem
Local _nTamItem   := TAMSX3("C6_ITEM")[1]   
Local _nI, _nQtd, _nQtd_A, _nQtd_B
Local _cPedidoNovo
Local _cNovoNum
Local _nPosVLIBB, _nPosQLIBB, _nVLIBB, _nQLIBB, _nVLIBBNovo, _nQLIBBNovo
Local _nFatConv
Local _nPesoMinimo := SuperGetMV("IT_PEBLSLD",.F.,3000)

 IF VALTYPE(_nPesoMinimo) <> "N"
   _nPesoMinimo:=3000
 EndIF
//==========================================
//Grava log de utilização da rotina
//==========================================
//U_ITLOGACS()

Default _ccodusuario := retcodusr()

Begin Sequence          
   _nRegSC5 := SC5->(Recno())
   _nRegSC6 := SC6->(Recno())    
   _cMsg := ""
   _lSucesso := .T.
   _cNumPed := ""

   SC5->(DbSetOrder(1))
   If ! SC5->(DbSeek(_cFilial+_cPedido,))
      _cMsg := "Filial + Pedido de vendas não localizado. "
      _lSucesso := .F.
      _cNumPed := ""
      _aRet := {_lSucesso,_cNumPed,_cMsg}
      Break
   EndIf
   
   SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO                                                                                                                             
   
   For _nI := 1 To Len(_aItensPedido)
       _cItem := StrZero(val(_aItensPedido[_nI,1]) , _nTamItem)
       If ! SC6->(DbSeek(_cFilial+_cPedido+_cItem))
          _cMsg := "Item de Pedido de vendas não localizado. Filial: "+_cFilial+"/ Pedido: "+_cPedido+"/ Item: "+_cItem
          _lSucesso := .F.
          _cNumPed := ""
          _aRet := {_lSucesso,_cNumPed,_cMsg}
          Break
       EndIf
   Next
   
   _aCabPV  :={}
   _aItemPV :={}
   _aItensPV:={}
   IF FindFunction("U_AOMS089")
      _cNovoNum:=U_AOMS089(.F.)//Aqui nessa função já tem U_ITConout´s
   ELSE
      //U_ITConout('****** ////  Usou GetSXENum("SC5","C5_NUM","  \DATA\"+RETSQLNAME("SC5"),24) '+TIME()+"  \\\\******")
      _cNovoNum:=GetSXENum("SC5","C5_NUM","  \DATA\"+RETSQLNAME("SC5"),24)
   ENDIF
                    
   Aadd( _aCabPV, { "C5_FILIAL"	   ,SC5->C5_FILIAL  , Nil})// 01 //filial
   Aadd( _aCabPV, { "C5_NUM"        ,SC5->C5_NUM	  , Nil})// 02 
   Aadd( _aCabPV, { "C5_TIPO"	      ,SC5->C5_TIPO    , Nil})// 03 //Tipo de pedido
   Aadd( _aCabPV, { "C5_I_OPER"	   ,SC5->C5_I_OPER  , Nil})// 04 //Tipo da operacao
   Aadd( _aCabPV, { "C5_CLIENTE"    ,SC5->C5_CLIENTE , NiL})// 05 //Codigo do cliente
   Aadd( _aCabPV, { "C5_CLIENT"     ,SC5->C5_CLIENT  , Nil})// 06 
   Aadd( _aCabPV, { "C5_LOJAENT"    ,SC5->C5_LOJAENT , NiL})// 07 //Loja para entrada
   Aadd( _aCabPV, { "C5_LOJACLI"    ,SC5->C5_LOJACLI , NiL})// 08 //Loja do cliente
   Aadd( _aCabPV, { "C5_EMISSAO"    ,SC5->C5_EMISSAO , NiL})// 09 //Data de emissao
   Aadd( _aCabPV, { "C5_TRANSP"     ,SC5->C5_TRANSP  , Nil})// 10 
   Aadd( _aCabPV, { "C5_CONDPAG"    ,SC5->C5_CONDPAG , NiL})// 11 //Codigo da condicao de pagamanto*
   Aadd( _aCabPV, { "C5_VEND1"      ,SC5->C5_VEND1	  , Nil})// 12
   Aadd( _aCabPV, { "C5_MOEDA"      ,SC5->C5_MOEDA   , Nil})// 13 //Moeda
   Aadd( _aCabPV, { "C5_MENPAD"     ,SC5->C5_MENPAD  , Nil})// 14 
   Aadd( _aCabPV, { "C5_LIBEROK"    ,SC5->C5_LIBEROK , NiL})// 15 //Liberacao Total
   Aadd( _aCabPV, { "C5_TIPLIB"     ,SC5->C5_TIPLIB  , Nil})// 16 //Tipo de Liberacao
   Aadd( _aCabPV, { "C5_TIPOCLI"    ,SC5->C5_TIPOCLI , NiL})// 17 //Tipo do Cliente
   Aadd( _aCabPV, { "C5_I_NPALE"    ,SC5->C5_I_NPALE , NiL})// 18 //Numero que originou a pedido de palete
   Aadd( _aCabPV, { "C5_I_PEDPA"    ,SC5->C5_I_PEDPA , NiL})// 19 //Pedido Refere a um pedido de Pallet
   Aadd( _aCabPV, { "C5_I_DTENT"    ,SC5->C5_I_DTENT , Nil})// 20 //Dt de Entrega // SC5->C5_I_DTENT
   Aadd( _aCabPV, { "C5_I_TRCNF"    ,SC5->C5_I_TRCNF , Nil})// 21
   Aadd( _aCabPV, { "C5_I_OBCOP" 	,SC5->C5_I_OBCOP , Nil})// 22
   Aadd( _aCabPV, { "C5_I_OBPED" 	,SC5->C5_I_OBPED , Nil})// 23
   Aadd( _aCabPV, { "C5_I_BLPRC"    ,SC5->C5_I_BLPRC , Nil})// 24
   Aadd( _aCabPV, { "C5_I_BLCRE"    ,SC5->C5_I_BLCRE , Nil})// 25
   Aadd( _aCabPV, { "C5_I_FILFT"    ,SC5->C5_I_FILFT , Nil})// 26
   Aadd( _aCabPV, { "C5_I_FLFNC"    ,SC5->C5_I_FLFNC , Nil})// 27
   Aadd( _aCabPV, { "C5_I_BLCRE"    ,SC5->C5_I_BLCRE , Nil})// 28
   Aadd( _aCabPV, { "C5_I_TIPCA"    ,SC5->C5_I_TIPCA , Nil})// 29
   Aadd( _aCabPV, { "C5_MENNOTA"    ,SC5->C5_MENNOTA , Nil})// 30
   Aadd( _aCabPV, { "C5_MENPAD"     ,SC5->C5_MENPAD  , Nil})// 31
   Aadd( _aCabPV, { "C5_I_PODES"    ,SC5->C5_NUM     , Nil}) ; nPosPODES:=LEN(_aCabPV) // 32
   Aadd( _aCabPV, { "C5_I_BLPRC"    ,SC5->C5_I_BLPRC , Nil})// 33
   Aadd( _aCabPV, { "C5_I_DTLIB"    ,SC5->C5_I_DTLIB , Nil})// 34
   Aadd( _aCabPV, { "C5_I_IDPED"    ,SC5->C5_I_IDPED , Nil})// 35
   Aadd( _aCabPV, { "C5_ORIGEM "    ,SC5->C5_ORIGEM  , Nil})// 36
   Aadd( _aCabPV, { "C5_I_DTAIM"    ,SC5->C5_I_DTAIM , Nil})// 37
   Aadd( _aCabPV, { "C5_I_HORAI"    ,SC5->C5_I_HORAI , Nil})// 38
   Aadd( _aCabPV, { "C5_I_DATAA"    ,SC5->C5_I_DATAA , Nil})// 39
   Aadd( _aCabPV, { "C5_I_HORAA"    ,SC5->C5_I_HORAA , Nil})// 40
   Aadd( _aCabPV, { "C5_I_DTLIP"    ,SC5->C5_I_DTLIP , Nil})// 41
   Aadd( _aCabPV, { "C5_I_MLIBP"    ,SC5->C5_I_MLIBP , Nil})// 42
   Aadd( _aCabPV, { "C5_I_DTAVA"    ,SC5->C5_I_DTAVA , Nil})// 43
   Aadd( _aCabPV, { "C5_I_HRAVA"    ,SC5->C5_I_HRAVA , Nil})// 44
   Aadd( _aCabPV, { "C5_I_USRAV"    ,SC5->C5_I_USRAV , Nil})// 45
   Aadd( _aCabPV, { "C5_I_LIBCA"    ,SC5->C5_I_LIBCA , Nil})// 46
   Aadd( _aCabPV, { "C5_I_LIBCT"    ,SC5->C5_I_LIBCT , Nil})// 47
   Aadd( _aCabPV, { "C5_I_LIBL "    ,SC5->C5_I_LIBL  , Nil})// 48
   Aadd( _aCabPV, { "C5_I_LIBCV"    ,SC5->C5_I_LIBCV , Nil})// 49
   Aadd( _aCabPV, { "C5_I_LIBCD"    ,SC5->C5_I_LIBCD , Nil})// 50
   Aadd( _aCabPV, { "C5_I_BLCRE"    ,SC5->C5_I_BLCRE , Nil})// 51
   Aadd( _aCabPV, { "C5_I_MOTBL"    ,SC5->C5_I_MOTBL , Nil})// 52
   Aadd( _aCabPV, { "C5_I_DTLIC"    ,SC5->C5_I_DTLIC , Nil})// 53
   Aadd( _aCabPV, { "C5_I_PLIBP"    ,SC5->C5_I_PLIBP , Nil})// 54
   Aadd( _aCabPV, { "C5_I_ULIBP"    ,SC5->C5_I_ULIBP , Nil})// 55
   Aadd( _aCabPV, { "C5_I_VLIBP"    ,SC5->C5_I_VLIBP , Nil})// 56
   Aadd( _aCabPV, { "C5_I_MOTLP"    ,SC5->C5_I_MOTLP , Nil})// 57
   Aadd( _aCabPV, { "C5_I_MOTLB"    ,SC5->C5_I_MOTLB , Nil})// 58
   Aadd( _aCabPV, { "C5_I_QLIBP"    ,SC5->C5_I_QLIBP , Nil})// 59
   Aadd( _aCabPV, { "C5_I_VLIBB"    ,SC5->C5_I_VLIBB , Nil})// 60
   Aadd( _aCabPV, { "C5_I_QLIBB"    ,SC5->C5_I_QLIBB , Nil})// 61
   Aadd( _aCabPV, { "C5_I_CLILP"    ,SC5->C5_I_CLILP , Nil})// 62
   Aadd( _aCabPV, { "C5_I_CLILB"    ,SC5->C5_I_CLILB , Nil})// 63
   Aadd( _aCabPV, { "C5_I_LLIBB"    ,SC5->C5_I_LLIBB , Nil})// 64
   Aadd( _aCabPV, { "C5_I_ULIBB"    ,SC5->C5_I_ULIBB , Nil})// 65
   Aadd( _aCabPV, { "C5_I_LLIBP"    ,SC5->C5_I_LLIBP , Nil})// 66
   Aadd( _aCabPV, { "C5_I_HLIBP"    ,SC5->C5_I_HLIBP , Nil})// 67
   Aadd( _aCabPV, { "C5_I_FILOR"    ,SC5->C5_I_FILOR , Nil})// 68
   Aadd( _aCabPV, { "C5_I_PEDOR"   , IIF(EMPTY(SC5->C5_I_PEDOR),SC5->C5_NUM, SC5->C5_I_PEDOR), Nil})//69
   Aadd( _aCabPV, { "C5_I_DTRAN"    ,SC5->C5_I_DTRAN, Nil})
   Aadd( _aCabPV, { "C5_I_UTRAN"    ,SC5->C5_I_UTRAN, Nil})
   Aadd( _aCabPV, { "C5_I_MTRAN"    ,SC5->C5_I_MTRAN, Nil})
   Aadd( _aCabPV, { "C5_I_HORP "    ,SC5->C5_I_HORP , Nil})
   Aadd( _aCabPV, { "C5_I_AGEND"    ,SC5->C5_I_AGEND, Nil}) ;  nPosAGEND:=LEN(_aCabPV)
   Aadd( _aCabPV, { "C5_I_CHPCL"    ,SC5->C5_I_CHPCL, Nil})
   Aadd( _aCabPV, { "C5_I_DOCA "    ,SC5->C5_I_DOCA , Nil})
   Aadd( _aCabPV, { "C5_I_TRCNF"    ,SC5->C5_I_TRCNF, Nil})
   Aadd( _aCabPV, { "C5_I_FLFNC"    ,SC5->C5_I_FLFNC, Nil})
   Aadd( _aCabPV, { "C5_I_OBSAV"    ,SC5->C5_I_OBSAV, Nil})
   Aadd( _aCabPV, { "C5_I_FILFT"    ,SC5->C5_I_FILFT, Nil})
   Aadd( _aCabPV, { "C5_I_PDFT "    ,SC5->C5_I_PDFT , Nil})
   Aadd( _aCabPV, { "C5_I_PDPR "    ,SC5->C5_I_PDPR , Nil})  
   Aadd( _aCabPV, { "C5_TPFRETE"    ,IF(SC5->C5_TPFRETE="R","C",SC5->C5_TPFRETE), Nil})
   Aadd( _aCabPV, { "C5_I_PSORI"    ,SC5->C5_I_PSORI , Nil})

   Aadd( _aCabPV, { "C5_I_TAB"     ,SC5->C5_I_TAB   , Nil})
   Aadd( _aCabPV, { "C5_I_PEDDW"   ,SC5->C5_I_PEDDW , Nil})
   Aadd( _aCabPV, { "C5_I_TPVEN"   ,SC5->C5_I_TPVEN , Nil})
   Aadd( _aCabPV, { "C5_VEND2"     ,SC5->C5_VEND2	 , Nil})
   Aadd( _aCabPV, { "C5_VEND3"     ,SC5->C5_VEND3	 , Nil})
   Aadd( _aCabPV, { "C5_VEND4"     ,SC5->C5_VEND4	 , Nil})
   Aadd( _aCabPV, { "C5_VEND5"     ,SC5->C5_VEND5	 , Nil})
   
   Aadd( _aCabPV, { "C5_I_SENHA"   ,SC5->C5_I_SENHA , Nil})
   Aadd( _aCabPV, { "C5_I_NRZAZ"   ,SC5->C5_I_NRZAZ , Nil})
   Aadd( _aCabPV, { "C5_I_LIBC"    ,SC5->C5_I_LIBC	 , Nil})

// ----------------------------------------------------------------
   Aadd( _aCabPV, { "C5_I_OPTRI"   ,SC5->C5_I_OPTRI  , Nil}) // Tipo PV na operacao trian
   Aadd( _aCabPV, { "C5_I_PVREM"   ,SC5->C5_I_PVREM  , Nil}) // Pedido de Remessa        
   Aadd( _aCabPV, { "C5_I_PVFAT"   ,SC5->C5_I_PVFAT  , Nil}) // Pedido de FAturamento    
   Aadd( _aCabPV, { "C5_I_CLIEN"   ,SC5->C5_I_CLIEN  , Nil}) // Cli Remessa 
   Aadd( _aCabPV, { "C5_I_LOJEN"   ,SC5->C5_I_LOJEN  , Nil}) // Loj Remessa 
   If SC5->(FIELDPOS("C5_I_BLSLD")) > 0 
      Aadd( _aCabPV, { "C5_I_BLSLD",SC5->C5_I_BLSLD  , Nil}) // Bloq. de carregamentro p/ Saldo
   Endif
   nPosBLSLD:=LEN(_aCabPV)
//-----------------------------------------------------------------

   _aCabPVNovo := AClone(_aCabPV)
   
   //==============================================================================
   // Complementa os dados da capa do novo pedido de vendas.
   //==============================================================================
   Aadd( _aCabPVNovo, { "C5_I_BLOQ"    ,SC5->C5_I_BLOQ  , Nil})
   Aadd( _aCabPVNovo, { "C5_I_MTBON"   ,SC5->C5_I_MTBON , Nil})
   Aadd( _aCabPVNovo, { "C5_I_DLIBE"   ,SC5->C5_I_DLIBE , Nil})
   Aadd( _aCabPVNovo, { "C5_I_HLIBE"   ,SC5->C5_I_HLIBE , Nil})
   Aadd( _aCabPVNovo, { "C5_I_STAWF"   ,SC5->C5_I_STAWF , Nil})

   //==============================================================================
   // Calcula e grava os arrays dos itens.
   //==============================================================================
   _aItemPVNovo := {}
   _aItensPVNovo := {}
   
   _nvalori := 0
   _nvalnovo := 0
   _nlibpnovo := 0
   _nlibpori := 0
	_cAOMS074Vld:=""//Pega as mensagens de erro do MT410TOK.PRW
   
   // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO     
   SC6->(Dbsetorder(1))                                                                                                                        
   SC6->(DbSeek(_cFilial+_cPedido))
   Do While ! SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == _cFilial+_cPedido
 
       _lRemoveItem := .T.  
      _nQtd_A := SC6->C6_QTDVEN
      _nQtd_B := SC6->C6_QTDVEN
      
      _nI := Ascan(_aItensPedido,{|x| x[1] == SC6->C6_ITEM}) 
      If _nI > 0
         _nQtd := SC6->C6_QTDVEN - _aItensPedido[_nI,2]
         _nQtd_A := 0
         _nQtd_B := 0
         
         If _aItensPedido[_nI,2] > 0
             _lRemoveItem := .F.
            _nQtd_A := _aItensPedido[_nI,2]
            _nQtd_B := _nQtd
         ElseIf _aItensPedido[_nI,2] <= 0
            _lRemoveItem := .T.            
            _nQtd_A := 0
            _nQtd_B := SC6->C6_QTDVEN
         EndIf
      EndIf

      SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO ))

      _nFatConv := SB1->B1_CONV 

      If SB1->B1_CONV == 0      
         _nFatConv := SB1->B1_I_FATCO
      EndIf 
      
      If SB1->B1_TIPCONV == "M"
         _n2Qtd_A := _nQtd_A * _nFatConv // SB1->B1_CONV 
         _n2Qtd_B := _nQtd_B * _nFatConv // SB1->B1_CONV 
      Else
         _n2Qtd_A := _nQtd_A / _nFatConv // SB1->B1_CONV 
         _n2Qtd_B := _nQtd_B / _nFatConv // SB1->B1_CONV 
      EndIf
      
      If ! _lRemoveItem .And. _nI > 0
         _cDeleta := "N"
      Else
         _cDeleta := "S"
         _n2Qtd_A := SC6->C6_UNSVEN
         _nQtd_A := SC6->C6_QTDVEN 
         
      EndIf
            
      _aItemPV:={}
	  AAdd( _aItemPV , { "LINPOS"     ,"C6_ITEM", SC6->C6_ITEM }) //  Informa a posição do item
      AAdd( _aItemPV , { "AUTDELETA"  ,_cDeleta        , Nil }) // Informa se o item será ou não excluído.
	  AAdd( _aItemPV , { "C6_FILIAL"  ,SC6->C6_FILIAL  , Nil }) // FILIAL
	  AAdd( _aItemPV , { "C6_NUM"     ,SC6->C6_NUM     , Nil }) // Num. Pedido
	  AAdd( _aItemPV , { "C6_ITEM"    ,SC6->C6_ITEM    , Nil }) // Numero do Item no Pedido
	  AAdd( _aItemPV , { "C6_PRODUTO" ,SC6->C6_PRODUTO , Nil }) // Codigo do Produto
	  AAdd( _aItemPV , { "C6_UNSVEN"  ,_n2Qtd_A        , Nil }) // Quantidade Vendida 2 un
	  AAdd( _aItemPV , { "C6_QTDVEN"  ,_nQtd_A         , Nil }) // Quantidade Vendida
	  AAdd( _aItemPV , { "C6_PRCVEN"  ,SC6->C6_PRCVEN  , Nil }) // Preco Unitario Liquido
	  AAdd( _aItemPV , { "C6_PRUNIT"  ,SC6->C6_PRUNIT  , Nil }) // Preco Unitario Liquido
	  AAdd( _aItemPV , { "C6_ENTREG"  ,SC6->C6_ENTREG  , Nil }) // Data da Entrega
	  AAdd( _aItemPV , { "C6_LOJA"    ,SC6->C6_LOJA	   , Nil })
	  AAdd( _aItemPV , { "C6_SUGENTR" ,SC6->C6_SUGENTR , Nil }) // Data da Entrega
	  AAdd( _aItemPV , { "C6_VALOR"   ,round((SC6->C6_PRCVEN * _nQtd_A),2), Nil }) // valor total do item // SC6->C6_VALOR
	  AAdd( _aItemPV , { "C6_UM"      ,SC6->C6_UM      , Nil }) // Unidade de Medida Primar.
	  AAdd( _aItemPV , { "C6_TES"     ,SC6->C6_TES     , Nil })
	  AAdd( _aItemPV , { "C6_LOCAL"   ,SC6->C6_LOCAL   , Nil }) // Almoxarifado
	  AAdd( _aItemPV , { "C6_CF"      ,SC6->C6_CF	  , Nil })
	  AAdd( _aItemPV , { "C6_DESCRI"  ,SC6->C6_DESCRI  , Nil }) // Descricao
	  AAdd( _aItemPV , { "C6_QTDLIB"  ,SC6->C6_QTDLIB  , Nil }) // Quantidade Liberada
	  AAdd( _aItemPV , { "C6_PEDCLI"  ,SC6->C6_PEDCLI  , Nil })
	  AAdd( _aItemPV , { "C6_I_BLPRC" ,SC6->C6_I_BLPRC , Nil })
      AAdd( _aItemPV , { "C6_I_QPALT" ,ROUND((SC6->C6_I_QPALT/(_NQTD_A + _NQTD_B))*_nQtd_A,0), Nil }) // Quantidade de Pallets
      Aadd( _aItemPV,  { "C6_I_USER "    ,SC6->C6_I_USER , Nil})
      Aadd( _aItemPV,  { "C6_I_LIBPC"    ,SC6->C6_I_LIBPC, Nil})
      Aadd( _aItemPV,  { "C6_I_DLIBP"    ,SC6->C6_I_DLIBP, Nil})
      Aadd( _aItemPV,  { "C6_I_PLIBP"    ,SC6->C6_I_PLIBP, Nil})
      Aadd( _aItemPV,  { "C6_I_ULIBP"    ,SC6->C6_I_ULIBP, Nil})
      Aadd( _aItemPV,  { "C6_I_VLIBP"    ,SC6->C6_I_VLIBP, Nil})
      Aadd( _aItemPV,  { "C6_I_MOTLP"    ,SC6->C6_I_MOTLP, Nil})
      Aadd( _aItemPV,  { "C6_I_QTLIP"    ,_nQtd_A, Nil})
      Aadd( _aItemPV,  { "C6_I_CLILP"    ,SC6->C6_I_CLILP, Nil})
      Aadd( _aItemPV,  { "C6_I_CLILB"    ,SC6->C6_I_CLILB, Nil})
      Aadd( _aItemPV,  { "C6_I_VLIBB"    ,SC6->C6_I_VLIBB, Nil})
      Aadd( _aItemPV,  { "C6_I_QLIBB"    ,_nQtd_A, Nil})
      Aadd( _aItemPV,  { "C6_I_LLIBP"    ,SC6->C6_I_LLIBP, Nil})
      Aadd( _aItemPV,  { "C6_I_LLIBB"    ,SC6->C6_I_LLIBB, Nil})
      Aadd( _aItemPV,  { "C6_I_MOTLB"    ,SC6->C6_I_MOTLB, Nil})
      Aadd( _aItemPV,  { "C6_I_PLIBB"    ,SC6->C6_I_PLIBB, Nil})
      Aadd( _aItemPV,  { "C6_I_DLIBB"    ,SC6->C6_I_DLIBB, Nil})
      Aadd( _aItemPV,  { "C6_COMIS1"     ,SC6->C6_COMIS1, Nil})
      Aadd( _aItemPV,  { "C6_COMIS2"     ,SC6->C6_COMIS2, Nil})
      Aadd( _aItemPV,  { "C6_COMIS3"     ,SC6->C6_COMIS3, Nil})
      Aadd( _aItemPV,  { "C6_COMIS4"     ,SC6->C6_COMIS4, Nil})
      Aadd( _aItemPV,  { "C6_COMIS5"     ,SC6->C6_COMIS5, Nil})
      Aadd( _aItemPV,  { "C6_I_PDESC"    ,SC6->C6_I_PDESC, Nil})
      Aadd( _aItemPV,  { "C6_I_VLTAB"    ,SC6->C6_I_VLTAB, Nil})
      Aadd( _aItemPV,  { "C6_I_PRMIN"    ,SC6->C6_I_PRMIN, Nil})
      Aadd( _aItemPV,  { "C6_ITEMPC"     ,SC6->C6_ITEMPC, Nil})
      
      If _cDeleta != "S"
       
       	_nvalori += round((SC6->C6_PRCVEN * _nQtd_A),2)
       	_nlibpori += round((SC6->C6_I_VLIBP * _nQtd_A),2)
       
      Endif
          
      AAdd( _aItensPV ,_aItemPV )                      
      
      If  _nQtd_B > 0
         _aItemPVNovo:={}
	     AAdd( _aItemPVNovo , { "C6_FILIAL"  ,SC6->C6_FILIAL  , Nil }) // FILIAL
	     AAdd( _aItemPVNovo , { "C6_NUM"     ,_cNovoNum     , Nil }) // Num. Pedido
	     AAdd( _aItemPVNovo , { "C6_ITEM"    ,SC6->C6_ITEM    , Nil }) // Numero do Item no Pedido
	     AAdd( _aItemPVNovo , { "C6_PRODUTO" ,SC6->C6_PRODUTO , Nil }) // Codigo do Produto
	     AAdd( _aItemPVNovo , { "C6_UNSVEN"  ,_n2Qtd_B        , Nil }) // Quantidade Vendida 2 un
	     AAdd( _aItemPVNovo , { "C6_QTDVEN"  ,_nQtd_B         , Nil }) // Quantidade Vendida
	     AAdd( _aItemPVNovo , { "C6_PRCVEN"  ,SC6->C6_PRCVEN  , Nil }) // Preco Unitario Liquido
	     AAdd( _aItemPVNovo , { "C6_PRUNIT"  ,SC6->C6_PRUNIT  , Nil }) // Preco Unitario Liquido
	     AAdd( _aItemPVNovo , { "C6_ENTREG"  ,SC6->C6_ENTREG  , Nil }) // Data da Entrega
	     AAdd( _aItemPVNovo , { "C6_LOJA"    ,SC6->C6_LOJA	   , Nil })
	     AAdd( _aItemPVNovo , { "C6_SUGENTR" ,SC6->C6_SUGENTR , Nil }) // Data da Entrega
	     AAdd( _aItemPVNovo , { "C6_VALOR"   ,round((SC6->C6_PRCVEN * _nQtd_B),2), Nil }) // valor total do item // SC6->C6_VALOR
	     AAdd( _aItemPVNovo , { "C6_UM"      ,SC6->C6_UM      , Nil }) // Unidade de Medida Primar.
	     AAdd( _aItemPVNovo , { "C6_TES"     ,SC6->C6_TES     , Nil })
	     AAdd( _aItemPVNovo , { "C6_LOCAL"   ,SC6->C6_LOCAL   , Nil }) // Almoxarifado
	     AAdd( _aItemPVNovo , { "C6_CF"      ,SC6->C6_CF	  , Nil })
	     AAdd( _aItemPVNovo , { "C6_DESCRI"  ,SC6->C6_DESCRI  , Nil }) // Descricao
	     AAdd( _aItemPVNovo , { "C6_QTDLIB"  ,SC6->C6_QTDLIB  , Nil }) // Quantidade Liberada
	     AAdd( _aItemPVNovo , { "C6_PEDCLI"  ,SC6->C6_PEDCLI  , Nil })
	     AAdd( _aItemPVNovo , { "C6_I_BLPRC" ,SC6->C6_I_BLPRC , Nil })
	     AAdd( _aItemPVNovo , { "C6_I_QPALT" ,ROUND((SC6->C6_I_QPALT/(_NQTD_A + _NQTD_B))*_nQtd_B,0), Nil }) // Quantidade de Pallets
         Aadd( _aItemPVNovo,  { "C6_I_USER "    ,SC6->C6_I_USER , Nil})
         Aadd( _aItemPVNovo,  { "C6_I_LIBPC"    ,SC6->C6_I_LIBPC, Nil}) 
         Aadd( _aItemPVNovo,  { "C6_I_DLIBP"    ,SC6->C6_I_DLIBP, Nil})
         Aadd( _aItemPVNovo,  { "C6_I_PLIBP"    ,SC6->C6_I_PLIBP, Nil})
         Aadd( _aItemPVNovo,  { "C6_I_ULIBP"    ,SC6->C6_I_ULIBP, Nil})
         Aadd( _aItemPVNovo,  { "C6_I_VLIBP"    ,SC6->C6_I_VLIBP, Nil})
         Aadd( _aItemPVNovo,  { "C6_I_MOTLP"    ,SC6->C6_I_MOTLP, Nil})
         Aadd( _aItemPVNovo,  { "C6_I_QTLIP"    ,_nQtd_B, Nil})
         Aadd( _aItemPVNovo,  { "C6_I_CLILP"    ,SC6->C6_I_CLILP, Nil})
         Aadd( _aItemPVNovo,  { "C6_I_CLILB"    ,SC6->C6_I_CLILB, Nil})
         Aadd( _aItemPVNovo,  { "C6_I_VLIBB"    ,SC6->C6_I_VLIBB, Nil})
         Aadd( _aItemPVNovo,  { "C6_I_QLIBB"    ,(SC6->C6_I_QLIBB/(_NQTD_A + _NQTD_B))*_nQtd_B, Nil})
         Aadd( _aItemPVNovo,  { "C6_I_LLIBP"    ,SC6->C6_I_LLIBP, Nil})
         Aadd( _aItemPVNovo,  { "C6_I_LLIBB"    ,SC6->C6_I_LLIBB, Nil})
         Aadd( _aItemPVNovo,  { "C6_I_MOTLB"    ,SC6->C6_I_MOTLB, Nil})
         Aadd( _aItemPVNovo,  { "C6_I_PLIBB"    ,SC6->C6_I_PLIBB, Nil})
         Aadd( _aItemPVNovo,  { "C6_I_DLIBB"    ,SC6->C6_I_DLIBB, Nil})
         Aadd( _aItemPVNovo,  { "C6_COMIS1"     ,SC6->C6_COMIS1, Nil})
         Aadd( _aItemPVNovo,  { "C6_COMIS2"     ,SC6->C6_COMIS2, Nil})
         Aadd( _aItemPVNovo,  { "C6_COMIS3"     ,SC6->C6_COMIS3 , Nil})
         Aadd( _aItemPVNovo,  { "C6_COMIS4"     ,SC6->C6_COMIS4 , Nil})
         Aadd( _aItemPVNovo,  { "C6_COMIS5"     ,SC6->C6_COMIS5 , Nil})
         Aadd( _aItemPVNovo,  { "C6_DTFIMNT"    ,SC6->C6_DTFIMNT, Nil})  
         Aadd( _aItemPVNovo,  { "C6_DATCPL"     ,SC6->C6_DATCPL , Nil})   
         Aadd( _aItemPVNovo,  { "C6_DATAEMB"    ,SC6->C6_DATAEMB, Nil})   
         Aadd( _aItemPVNovo,  { "C6_I_PDESC"    ,SC6->C6_I_PDESC, Nil})
         Aadd( _aItemPVNovo,  { "C6_I_VLTAB"    ,SC6->C6_I_VLTAB, Nil})
         Aadd( _aItemPVNovo,  { "C6_I_PRMIN"    ,SC6->C6_I_PRMIN, Nil})
         Aadd( _aItemPVNovo,  { "C6_ITEMPC"     ,SC6->C6_ITEMPC,  Nil})
        
         _nvalnovo += round((SC6->C6_PRCVEN * _nQtd_B),2)
         _nlibpnovo += round((SC6->C6_I_VLIBP * _nQtd_B),2)
         
         AAdd( _aItensPVNovo ,_aItemPVNovo )                      
      EndIf
   
      SC6->(DbSkip())
   End Do

   //======================================================================
   //Se não tem itens para o pedido desmembrado encerra o processamento
   //======================================================================
   If len(_aitenspvnovo) == 0 .or. len(_aitenspv) == 0
 
         //u_itconout("Não há itens a desmembrar do pedido de vendas: "+AllTrim(_cPedido)+". "+" - "+DTOC(DATE())+" - "+TIME())               
         _cMsg := "SUCESSO:FALSE; Não há itens a desmembrar do pedido de vendas: "+AllTrim(_cPedido)+". "
         _lSucesso := .F.
         
         Break         
 
   Endif


   //======================================================================
   // Calcula a quantidade e o valor liberado de bonificação para os itens
   // do pedido de origem.
   //======================================================================
   _nPosVLIBB := Ascan(_aItensPV[1],{|x| x[1] == "C6_VALOR"}) 
   _nPosQLIBB := Ascan(_aItensPV[1],{|x| x[1] == "C6_QTDVEN"})
   _nVLIBB := 0
   _nQLIBB := 0                                                 
   
   For _nI := 1 To Len(_aItensPV)
       _nVLIBB += _aItensPV[_nI,_nPosVLIBB,2]
       _nQLIBB += _aItensPV[_nI,_nPosQLIBB,2]  
   Next

   //======================================================================
   // Calcula a quantidade e o valor liberado de bonificação para os itens
   // do novo pedido de vendas.
   //======================================================================
   _nPosVLIBB := Ascan(_aItensPVNovo[1],{|x| x[1] == "C6_VALOR"}) 
   _nPosQLIBB := Ascan(_aItensPVNovo[1],{|x| x[1] == "C6_QTDVEN"})
   _nVLIBBNovo := 0
   _nQLIBBNovo := 0                                                 
   
   For _nI := 1 To Len(_aItensPVNovo)
       _nVLIBBNovo += _aItensPVNovo[_nI,_nPosVLIBB,2]
       _nQLIBBNovo += _aItensPVNovo[_nI,_nPosQLIBB,2]  
   Next
   
   //======================================================================
   // Atualiza capa do pedido de vendas Original
   //======================================================================
   _nPosVLIBB := Ascan(_aCabPV,{|x| x[1] == "C5_I_VLIBB"}) 
   _nPosQLIBB := Ascan(_aCabPV,{|x| x[1] == "C5_I_QLIBB"})

   _aCabPV[_nPosVLIBB,2] := _nVLIBB 
   _aCabPV[_nPosQLIBB,2] := _nQLIBB
   
   //======================================================================
   // Atualiza capa do novo pedido de vendas.
   //======================================================================
   _nPosVLIBB := Ascan(_aCabPVNovo,{|x| x[1] == "C5_I_VLIBB"}) 
   _nPosQLIBB := Ascan(_aCabPVNovo,{|x| x[1] == "C5_I_QLIBB"})

   _aCabPVNovo[_nPosVLIBB,2] := _nVLIBBNovo 
   _aCabPVNovo[_nPosQLIBB,2] := _nQLIBBNovo
   
   //======================================================================                         
   _cPedido := SC5->C5_NUM
   
   _cPedidoNovo := ""
   
   //======================================================================
   // Grava alteração do pedido de vendas que foi desmembrado.
   //======================================================================
      _cMsg := ""
      _lSucesso := .T.
      _cNumPed := ""
      
      lMsErroAuto:=.F.
      _cMsgErro:=""

		_cAOMS074   :="AOMS098"//DesAtiva o _lMsgEmTela := .F. no MT410TOK.PRW
      
      _aCabPv[nPosPODES][2] := _cNovoNum //grava referência do pedido desmembrado
      _npedlibc := _aCabPv[49][2]
      _npedlibp := _aCabPv[56][2]
      _npedlibb := _aCabPv[59][2]
      _aCabPv[49][2] := ROUND(((_nvalori/(_nvalnovo+_nvalori)) * _aCabPv[49][2]),2) //proporção de credito liberado
      _aCabPv[59][2] := ROUND(((_nlibpori/(_nlibpnovo+_nlibpori)) * _aCabPv[59][2]),2) //proporção de preço liberado
      _aCabPv[60][2] := ROUND(((_nvalori/(_nvalnovo+_nvalori)) * _aCabPv[60][2]),2) //proporção de bonificação liberada
  
      MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPV , _aItensPV , 4 )//PEDIDO ATUAL - ALTERARCAO

      //u_itconout("Integra para o sistema RDC o status do pedido de vendas, Alterado pelo sistema RDC: " + AllTrim(SC5->C5_NUM)+".")
      U_ENVSITPV()
	  
      If lMsErroAuto            
         _cNomeArqLog := "Pedido_"+AllTrim(_cPedido)+"_"+DTos(Date())+"_"+StrTran(Time(),":","_")+".log" 
         IF FWIsInCallStack( 'U_AOMS099' )
            _cMsgErro := MostraErro()
         ELSE
            _cMsgErro := MostraErro("\data\logs_generico\", _cNomeArqLog)
         ENDIF
         //u_itconout("Erro no desmembramento do pedido de vendas: "+AllTrim(_cPedido)+". "+_cMsgErro)               
         _cMsg := "SUCESSO:FALSE; Erro no desmembramento do pedido de vendas: "+AllTrim(_cPedido)+". "+_cMsgErro  
         _lSucesso := .F.
         
         Break         
      Else           
         _cPedido := SC5->C5_NUM
         
         //Garante a correta gravação dos campos do cabeçalho
         Reclock("SC5",.F.)
         _ni := 1
         Do while _ni <= len(_aCabPV)
         
         	&("SC5->" + _aCabPV[_ni][1]) := _aCabPV[_ni][2]
         	
         	_ni++
         	
         Enddo
         
         SC5->C5_I_VLIBB := _nVLIBB
         SC5->C5_I_QLIBB := _nQLIBB 
         SC5->C5_USERLGA := u_retlgilga(_cCodUsuario)
         
         SC5->(Msunlock())
         
          //u_itconout("Desmembramento do pedido de vendas realizado com sucesso: "+AllTrim(_cPedido)+".")               
         _cMsg := "SUCESSO:TRUE; Desmembramento do pedido de vendas realizado com sucesso:"+AllTrim(_cPedido)+"."
      EndIf

      If len(_aItensPVNovo) < 1
      	 //u_itconout("Erro na inclusão do novo pedido de vendas, resultado do desmembramento. Não há itens selecionados para o novo pedido ")               
         _cMsg := "SUCESSO:FALSE; Erro na inclusão do novo pedido de vendas, resultado do desmembramento. Não há itens selecionados para o novo pedido "
         _lSucesso := .F.         
         Break
      Endif

      //======================================================================
      // Grava novo pedido de vendas com os dados restantes do desmembrado.
      //======================================================================
      lMsErroAuto:=.F.
      _aCabPv[02][2] := _cNovoNum //grava novo numero do pedido
      _aCabPv[32][2] := SC5->C5_NUM //grava referencia ao pedido gerador
      _aCabPv[49][2] := ROUND(((_nvalnovo/(_nvalnovo+_nvalori)) * _npedlibc),2) //proporção de credito liberado
      _aCabPv[59][2] := ROUND(((_nlibpnovo/(_nlibpnovo+_nlibpori)) * _npedlibp),2) //proporção de preço liberado
      _aCabPv[60][2] := ROUND(((_nvalnovo/(_nvalnovo+_nvalori)) * _npedlibb),2) //proporção de bonificação liberada

      MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPV , _aItensPVNovo , 3 )//PEDIDO NOVO - Inclusao
	
      If lMsErroAuto            
         _cNomeArqLog := "Pedido_"+AllTrim(_cPedido)+"_novo_"+DTos(Date())+"_"+StrTran(Time(),":","_")+".log"
         IF FWIsInCallStack( 'U_AOMS099' )
            _cMsgErro := MostraErro()
         ELSE
            _cMsgErro := MostraErro("\data\logs_generico\", _cNomeArqLog)
         ENDIF
         
        //u_itconout(_cMsgErro)
         _cMsg := "SUCESSO:FALSE; Erro ao Incluir PV novo: "+ALLTRIM(_cMsgErro)
         _lSucesso := .F.         
         Break         
      Else                               
         _cNumPed := SC5->C5_NUM   
         CONFIRMSX8()
         
         //Garante a correta gravação dos campos do cabeçalho
         Reclock("SC5",.F.)
         _ni := 1

         Do while _ni <= len(_aCabPV)
         	&("SC5->" + _aCabPV[_ni][1]) := _aCabPV[_ni][2]
         	_ni++
         Enddo

         If SC5->(FIELDPOS("C5_I_BLSLD")) > 0 
            IF FWISINCALLSTACK("U_ALTERAP") .and. FWIsInCallStack("U_AOMS085B") .And. SC5->C5_I_PESBR <=  _nPesoMinimo
               SC5->C5_I_BLSLD:="S"
            Else
               SC5->C5_I_BLSLD:="N"
            EndIf
         EndIf

         SC5->C5_I_VLIBB := _nVLIBBNovo
         SC5->C5_I_QLIBB := _nQLIBBNovo
         SC5->C5_USERLGA := u_retlgilga(_cCodUsuario)
         SC5->C5_USERLGI := u_retlgilga(_cCodUsuario)
         SC5->C5_I_CDUSU := Posicione("ZZL",3,xfilial("ZZL")+_cCodUsuario,"ZZL_MATRIC")
         SC5->(Msunlock())
         
         //u_itconout("Inclusão do novo pedido de vendas realizado com sucesso: "+AllTrim(_cNumPed)+".")               
         _cMsg := "SUCESSO:TRUE; Inclusão do novo pedido de vendas realizado com sucesso: "+AllTrim(_cNumPed)+"."
         
         //u_itconout("Integra para o sistema RDC o status do novo pedido de vendas, criado pelo sistema RDC: " + AllTrim(SC5->C5_NUM)+".")
         U_ENVSITPV()

      EndIf

End Sequence

If type("_cMsgErro") != "C"
   _cmsgerro := "  "
Endif

_aRet := {_lSucesso,;//01
          _cNumPed,;//02
          _cMsg,;//03
          LEFT(_cMsgErro,150),;//04
          _cAOMS074Vld,;//05
          _cMsgErro}//06

RestOrd(_aOrd)

Return _aRet
