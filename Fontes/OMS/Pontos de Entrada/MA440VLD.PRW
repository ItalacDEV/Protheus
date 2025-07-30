/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 05/01/2017 | Ajustes da Unificação - Dead Lock - Chamado 18300
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 30/01/2017 | Ajustes da Unificação - Dead Lock - Chamado 18606
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 10/01/2017 | Ajustes da Unificação - Unificar validação de crédito - Chamado 18333                        
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 26/05/2017 | Incluido envio de int status RDC - Chamado 17025
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 19/06/2018 | Alteração para o TRATAMENTO DE OPERCAO TRIANGULAR - Chamado 25254
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 17/09/2019 | Ajuste para ignorar a funcao M520_Valida. Chamado 30543
-------------------------------------------------------------------------------------------------------------------------------
 Jonathan         | 04/05/2020 | Alterar chamada "MsgBox" para "U_ITMSG". Chamado 32763
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 01/02/2021 | Remoção de bugs apontados pelo Totvs CodeAnalysis. Chamado: 34262
------------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 16/12/2022 | Novo tratamento para Pedidos de Operacao Triangular. Chamado 41604 
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RwMake.ch"
/*
=========================================================================================================================================================
Programa----------: MA440VLD()
Autor-------------: Alex Wallauer
Data da Criacao---: 05/01/2017
=========================================================================================================================================================
Descrição---------: PE na Function A440TudOk() do programa Mata440.PRX
=========================================================================================================================================================
Parametros--------: Nenhum
=========================================================================================================================================================
Observação--------: 
=========================================================================================================================================================
*/
*====================================================*
USER FUNCTION MA440VLD()//lRet := ExecBlock("MA440VLD",.F.,.F.)
*====================================================*
LOCAL _lTravadoPorAlguem:= .F.
LOCAL _aItensLock:={}
Local _aSC5   := GetArea("SC5") 
Local _aSC6   := GetArea("SC6") 
Local _aSC9   := GetArea("SC9") 
Local _aSF4   := GetArea("SF4") 
Local _cBlqCred:=""
Local _lvalida := .T.
Local _nTotal := 0  , _nI 
Local _cChep  := Alltrim(GetMV("IT_CCHEP"))

SC6->( Dbsetorder(1))
SC6->( Dbseek(SC5->C5_FILIAL+SC5->C5_NUM) )

Do while SC6->(!EOF()) .and. SC6->C6_FILIAL == SC5->C5_FILIAL .and. SC6->C6_NUM == SC5->C5_NUM

   If alltrim(SC6->C6_PRODUTO) == _cChep .OR. AllTrim(SC6->C6_CF) $ '5910/6910/5911/6911'
   
      //NÃO VALIDA CRÉDITO PARA PALLET CHEP E PARA BONIFICAÇÃO
      _lvalida := .F.
      
    Endif
    
    If SC5->C5_TIPO != 'N' .OR. posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC") != 'S' 
   
      //NÃO VALIDA CRÉDITO PARA PEDIDO SEM DUPLICATA OU PARA PEDIDO QUE NÃO SEJA PEDIDO NORMAL
      _lvalida := .F.
      
    Endif
    
    If posicione("ZAY",1,xfilial("ZAY")+SC6->C6_CF,"ZAY_TPOPER") != 'V' 
   
      //NÃO VALIDA CRÉDITO PARA PEDIDO COM CFOP QUE NÃO SEJA DE VENDA
      _lvalida := .F.
      
    Endif

   AADD(_aItensLock,{SC6->C6_PRODUTO,SC6->C6_LOCAL})
   _nTotal += SC6->C6_VALOR
   
   SC6->( Dbskip() )
	
Enddo

//================================================================================
//***********   TRATAMENTO DE OPERCAO TRIANGULAR  ********************************
//================================================================================
IF !FunName() $ "MATA521B" .AND. !(ISINCALLSTACK("M520_VALID"))//Rotina de exclusao dos documentos de saida por carga
	_lDiferente:=.F.
	_nRecAtual := SC5->(RECNO())
	_nInicio   := 1
	If SC5->C5_I_OPTRI = "R" .AND. !EMPTY( SC5->C5_I_PVFAT ) .OR.; //Alterações do PV de Remessa no PV de Faturamento
	   SC5->C5_I_OPTRI = "F" .AND. !EMPTY( SC5->C5_I_PVREM )       //Alterações do PV de Faturamento no PV de Remessa
		
		IF SC5->C5_I_OPTRI="R"//PV de Remessa
			_cPedido :=SC5->C5_I_PVFAT
			_cTesxto1:="PV de Faturamento"
			_cTesxto2:="PV de Remessa"
            _cCliEnt :=SC5->C5_CLIENTE+SC5->C5_LOJACLI//Cliente do PV de Remessa
		ELSE//PV de Faturamento
			_cPedido :=SC5->C5_I_PVREM
			_cTesxto1:="PV de Remessa"
			_cTesxto2:="PV de Faturamento"
            _cCliente:=SC5->C5_I_CLIEN+SC5->C5_I_LOJEN//Cliente do PV de Remessa
		ENDIF
		_aLogItens:={}
		SC5->(DBSETORDER(1))
		IF SC5->(DBSEEK(xFilial()+_cPedido))//Posiciona no outro Pedido
/*
		    IF SC5->C5_I_OPTRI="R"//PV de Remessa
               _cCliEnt :=SC5->C5_CLIENTE+SC5->C5_LOJACLI//Cliente do PV de Remessa
		    ELSE//PV de Faturamento
               _cCliente:=SC5->C5_I_CLIEN+SC5->C5_I_LOJEN//Cliente do PV de Remessa
		    ENDIF
			
			IF _cCliEnt <> _cCliente
			   _nInicio   := 2
			   _lDiferente:=.T.
			   _cMensagem:="Cliente da Remessa diferente do informado no Faturamento"
			   AADD(_aLogItens,{ .F. , "Cliente da Remessa: " , _cCliEnt ," ", _cCliente , " " ,_cMensagem,"" } )			
			ENDIF*/
			
			_nItem   := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "C6_ITEM"     } ) // Item
			_nPosCod := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "C6_PRODUTO"  } ) // Código do Produto
			_nPosQtd := aScan( aHeader , {|X| UPPER( Alltrim( X[2] ) ) == "C6_QTDVEN"   } ) // Quantidade na 1ª U.M.
			_nPosPrc := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "C6_PRCVEN"   } ) // Preço Unitário

			SC6->( DBSetOrder(2) )//C6_FILIAL+C6_PRODUTO+C6_NUM+C6_ITEM
			
			For _nI := 1 To Len(aCols)
				
				_cQtde:=""
				_cPrUn:=""
				_cMensagem:=""
				_lOK:=.F.
				If SC6->( DBSeek( xFilial() + aCols[_nI][_nPosCod] + _cPedido ) )
					
					_cQtde:=TRANS(SC6->C6_QTDVEN ,AVSX3('C6_QTDVEN',6))
					_cPrUn:=TRANS(SC6->C6_PRCVEN ,AVSX3('C6_PRCVEN',6))
					
					If SC6->C6_QTDVEN = aCols[_nI][_nPosQtd] .AND. ((SC6->C6_PRCVEN - aCols[_nI][_nPosPrc]) < 0.01 .And. (SC6->C6_PRCVEN - aCols[_nI][_nPosPrc]) > -0.01)
						_lOK:=.T.
					Else
						If SC6->C6_QTDVEN <> aCols[_nI][_nPosQtd]
							_cMensagem:="Quantidade diferente  "
						EndIf
						If SC6->C6_PRCVEN <> aCols[_nI][_nPosPrc]//(SC6->C6_PRCVEN - aCols[_nI][_nPosPrc]) > 0.01 .OR. (SC6->C6_PRCVEN - aCols[_nI][_nPosPrc]) < -0.01
							_cMensagem+="Preço diferente"
						EndIf
						_lDiferente:=.T.
					EndIf
				Else
					_cMensagem+="Item não encontrado no "+_cTesxto1
					_lDiferente:=.T.
				EndIf
				
				AADD(_aLogItens,{ _lOK , aCols[_nI][_nPosCod] , ;
				                  TRANS(aCols[_nI][_nPosQtd],AVSX3('C6_QTDVEN',6)),;
				                  TRANS(aCols[_nI][_nPosPrc],AVSX3('C6_PRCVEN',6)),_cQtde , _cPrUn ,_cMensagem,aCols[_nI][_nItem] } )
				
			NEXT
			
			SC6->( DBSetOrder(1) )//C6_FILIALC6_NUM
			
			If SC6->( DBSeek( xFilial() + _cPedido  ) )
				
				Do While SC6->( !EoF() ) .AND. SC6->( C6_FILIAL + C6_NUM ) == xFilial("SC6") + _cPedido
					
					If aScan(_aLogItens, {|L| L[2] == SC6->C6_PRODUTO }) = 0
						
						_lDiferente:=.T.
						
						AADD(_aLogItens,{ .F. , SC6->C6_PRODUTO ,"","",TRANS(SC6->C6_QTDVEN ,AVSX3('C6_QTDVEN',6)) ,;
						                                               TRANS(SC6->C6_PRCVEN ,AVSX3('C6_PRCVEN',6)) ,"Item nao encontrado no "+_cTesxto2,SC6->C6_ITEM } )
						
					EndIf
					
					SC6->( DBSkip() )
					
				EndDo
				
			EndIf
			
			If LEN(_aLogItens) > 0 .AND. _lDiferente
				
				FOR _nI := _nInicio TO LEN(_aLogItens)				
					_aLogItens[_nI,2] := _aLogItens[_nI,8]+" - "+Alltrim(_aLogItens[_nI,2])+" - "+Alltrim(Posicione("SB1",1,Xfilial("SB1")+_aLogItens[_nI,2],"B1_DESC"))
				NEXT
				
				_cProblema:="Ocorreram divergencias entre os itens do Pedido de Remessa e de Faturamento, para maiores detalhes veja a Coluna Observação."
				_cSolucao :="Para fechar a tela de Log clique no Botão FECHAR."
				_bOK:={|| xMagHelpFis("Atenção! (MT100TOK)",_cProblema,_cSolucao) , .F. }
				
				U_ITListBox( "Log de Itens do "+_cTesxto1+" X "+_cTesxto2+" (MA440VLD)" ,;
				            {" ","Item - Código e Descricao",'Qtde'+SUBSTR(_cTesxto2,6),'Pr. Unit'+SUBSTR(_cTesxto2,6),'Qtde'+SUBSTR(_cTesxto1,6),'Pr. Unit'+SUBSTR(_cTesxto1,6),'Observação'},_aLogItens,.T.,4,_cTesxto1+": "+_cPedido,,;
				            { 10,                         230,                        65,                            65,                        65,                            65,         100},, _bOK  , )
				
				RETURN .F.
				
			EndIf
			
			
			
		Endif
	Endif
	SC5->(DBGOTO(_nRecAtual))//Volta o POSICIONAMENTO do pedido de origem
ENDIF
//================================================================================
//***********   TRATAMENTO DE OPERCAO TRIANGULAR  ********************************
//================================================================================

// Reavaliação de Credito
IF _lvalida .and. !FunName() $ "MATA521B" .AND. !(ISINCALLSTACK("M520_VALID"))//Rotina de exclusao dos documentos de saida por carga

   IF SC5->C5_I_BLCRE = "B" 
		U_ITMSG("Avaliação de crédito do pedido não foi aprovada - "	+;
  	         "O pedido não pode ser liberado pois esta bloqueado para avaliação - ",;
  	         "Atenção!", "(MA440VLD) Ped.: "+SC5->C5_NUM,1)
    	RETURN .F.
   ENDIF   

   _aRetCre := U_ValidaCredito( _nTotal )//AWF-11/01/2017
   _cBlqCred:=_aRetCre[1]

   If _cBlqCred != "Liberação completa de crédito" .and. _cBlqCred != "Liberado por risco A" .and. _cBlqCred != "Aprovado em análise de crédito"

      SC5->(RecLock("SC5",.F.))
	  SC5->C5_I_BLCRE := "B"
	  SC5->C5_I_DTAVA := DATE()
	  SC5->C5_I_HRAVA := TIME()
	  SC5->C5_I_USRAV := cUsername
	  SC5->C5_I_MOTBL := _cBlqCred

	  SC5->C5_I_LIBCA := ""
	  SC5->C5_I_LIBC  := 0
	  SC5->C5_I_LIBCT := ""
	  SC5->C5_I_LIBL  := CTOD("")
	  SC5->C5_I_LIBCV := 0
	  SC5->C5_I_LIBCD := CTOD("")
	  SC5->C5_I_DTLIC := CTOD("")

   	  SC5->(MsUnlock())

	  U_ITMSG("Avaliação de crédito do pedido não foi aprovada - "+CHR(13)+CHR(10)+;
			"O pedido não pode ser liberado e será marcado como bloqueado para posterior avaliação - "+CHR(13)+CHR(10)+;
			"[ "+_cBlqCred+" ]",;
			"Atenção!", "(MA440VLD) Ped.: "+SC5->C5_NUM,3)


  	 U_ENVSITPV() //Envia interface de situação do pedido para o RDC

      Restarea(_aSC5)	
      Restarea(_aSC6)	
      Restarea(_aSC9)	
      Restarea(_aSF4)	
      RETURN .F.
   
   Elseif SC5->C5_I_BLCRE != "L"
   
      SC5->(RecLock("SC5",.F.))
	  SC5->C5_I_BLCRE := " "
	  SC5->C5_I_DTAVA := DATE()
	  SC5->C5_I_HRAVA := TIME()
	  SC5->C5_I_USRAV := cUsername
	  SC5->C5_I_MOTBL := _cBlqCred
   	  SC5->(MsUnlock())
   
   ENDIF

EndIf

SC6->( DBSeek( xFilial("SC6") + SC5->C5_NUM ) )

_lTravadoPorAlguem := U_LockPed(SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_FILIAL,_aItensLock) //Função no italacxfun que faz o lock completo previnindo deadlock

Restarea(_aSC5)	
Restarea(_aSC6)	
Restarea(_aSC9)	
Restarea(_aSF4)	
RETURN !_lTravadoPorAlguem
