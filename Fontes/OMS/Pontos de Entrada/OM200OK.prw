/*
================================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
================================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
--------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 12/07/2018 | Incluir valida��es, bloquear carga de pedidos vendas bloqueados e sem libera��o. Chamado 25479.  
-------------------------------------------------------------------------------------------------------------------------------- 
 Josu� Danich     | 04/09/2018 | Ajuste e posi��o de array no paramixb - Chamado 26152 
--------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 11/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
 -------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 01/02/2021 | Remo��o de bugs apontados pelo Totvs CodeAnalysis. Chamado: 34262
================================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

/*
===============================================================================================================================
Programa--------: OM200OK
Autor-----------: Fabiano Dias
Data da Criacao-: 16/06/2010                			
===============================================================================================================================
Descricao-------: Ponto de Entrada executado antes da conclusao da montagem da carga quando o usuario clica no botao ok
					Possibilita efetuar validacoes antes da efetivacao da montagem da carga
===============================================================================================================================
Parametros------: Nenhum  
===============================================================================================================================
Retorno---------: Nenhum  
===============================================================================================================================
*/
User Function OM200OK()

Local _nPosCarga := PARAMIXB[3]
Local _aDadoCarg := PARAMIXB[2][_nPosCarga]
Local _lRet      := .T.
Local _lPreCarga := .F.
Local _aPedidos  := PARAMIXB[01]
Local _aSC5		 := GetArea("SC5") 
Local _alog 	 := {}
Local oproc      := nil

//====================================================================================
//Verifica vers�o do OMSA200 pois mudou a posi��o do array do paramixb a partir 
// do fontes depois de 06/08/2018 sem documenta��o no TDN
//====================================================================================
Local aTipo := {}
Local aArquivo := {}
Local aLinha := {}
Local aData := {}
Local aHora := {}
Local _npos := 12 //posi��o antiga do codigo do motorista
Local _npos2 := 9 //posi��o antiga do codigo do caminhao

GetFuncArray( "OMSA200", aTipo, aArquivo, aLinha, aData, aHora )

If AARQUIVO[1] == "OMSA200.PRW" .AND. ADATA[1] > STOD("20180805")

	_npos := 13 //posicao nova do codigo do motorista
	_npos2 := 10 //posicao nova do codigo do caminhao
	
Endif

//====================================================================================
//Verifica se o veiculo ou motorista foram informados na opcao veiculo da carga  
//====================================================================================

If Empty(_aDadoCarg[_npos2]) .Or. Empty(_aDadoCarg[_npos])
	        
   IF !u_itmsg("Voce esta fazendo uma Pre-Carga?","Atencao",,2,2,2)	
	   u_itmsg("Favor informar um veiculo antes de concluir a montagem da carga.","Aten��o! (OM200OK)",;
				     "Bot�o disponivel na montagem da carga em Associar veiculo",1)         
				     
	   _lRet:= .F.
   ELSE
       _lPreCarga:= .T.
   ENDIF
	
EndIf 

//=================================================================
// Valida se existe pedidos de vendas com bloqueio de cr�dito e 
// de estoque.
//=================================================================
If _lRet
   _lRet := OM200VLD(_aPedidos)
EndIf

//=================================================================
// Analisa cr�dito dos pedidos selecionados
//=================================================================
If _lRet
	_aRetorno:={.T.,{}}//A variavel do retorno da func�o verpeds() tem que se PRIVATE
	FWMSGRUN(,{|oproc| _aRetorno := verpeds(_aPedidos, oproc) }, "Aguarde", "OM200OK - Analisando cr�dito dos pedidos...")
	_lRet:=_aRetorno[1]
	_aLog:=_aRetorno[2]

	If !_lRet .AND. LEN(_aLog) > 0
	
		U_ITListBox( 'Rela��o de Pedidos que n�o podem montar carga: (OM200OK)' ,;
		             {"Pedido","Cod Cli","Nome do Cliente","Resultado da Analise"} , _aLog , .F. , 1 , 'Resultado da An�lise dos pedidos: ',,;
		             {      30,       30,               80,                   200} )

	ENDIF

Endif

	
IF _lRet

   _cCaminDAK := _aDadoCarg[_npos2]
   _cMotorDAK := _aDadoCarg[_npos]
   _lRet:=U_OM200Tela(.F.,_lPreCarga)

Endif

Restarea(_aSC5)	

Return IF(_lRet,NIL,.F.)//nao pode retornar um valor logico se for .T. pq ele mata a validacao padrao se for .F. //Return _lRet


/*/
===============================================================================================================================
Programa--------: Verpeds
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 30/05/2017                			
===============================================================================================================================
Descricao-------: Verifica cr�dito dos pedidos selecionados
===============================================================================================================================
Parametros------: _aPedidos - Array com pedidos selecionados
				  oproc - objeto de processamento
===============================================================================================================================
Retorno---------: _lRet - Se passaram ou n�o na an�lise de cr�dito 
===============================================================================================================================
/*/
Static Function Verpeds(_aPedidos, oproc)

Local _lRet := .T.
Local _ni   := 1
Local _alog := {}
Local _cChep:= Alltrim(GetMV("IT_CCHEP"))

SA1->(Dbsetorder(1))
SC5->(Dbsetorder(1))
SC6->(Dbsetorder(1))

FOR _ni := 1 TO len(_aPedidos)

	oproc:ccaption := ("OM200OK - Analisando Pedido: "+_aPedidos[_ni][5])
    ProcessMessages()

	//Valida cr�dito do pedido
		If SC5->(Dbseek(_aPedidos[_ni][12]+_aPedidos[_ni][5]))

           IF SA1->( DBSeek( xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI ) ) .AND. SA1->A1_MSBLQL == '1'
		   	  AADD(_aLog,{SC5->C5_NUM,SC5->C5_CLIENTE,POSICIONE("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"),"Cliente Bloqueado"})
              LOOP
           ENDIF

		   If  SC5->C5_TIPO = 'N' 

		   		_nTotPV:=0
		   		_lValCredito:=.T.
   
		   		SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))

		   		DO WHILE SC6->C6_NUM == SC5->C5_NUM .AND. SC5->C5_FILIAL == SC6->C6_FILIAL .AND. SC6->(!EOF())
	   
		   			_nTotPV += SC6->C6_VALOR

		   			If SC6->C6_PRODUTO == _cChep .OR. SC6->C6_CF $ '5910/6910/5911/6911'//N�O VALIDA CR�DITO PARA PALLET CHEP E PARA BONIFICA��O
		   				_lValCredito:=.F.
		   				EXIT
		   			ENDIF

		   			If posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC") != 'S' //N�O VALIDA CR�DITO PARA PEDIDO SEM DUPLICATA
		   				_lValCredito:=.F.
		   				EXIT
		   			Endif
    
		   			If posicione("ZAY",1,xfilial("ZAY")+ SC6->C6_CF ,"ZAY_TPOPER") != 'V' //N�O VALIDA CR�DITO PARA PEDIDO COM CFOP QUE N�O SEJA DE VENDA
		   				_lValCredito:=.F.
		   				EXIT
		   			Endif
      
		   			SC6->(DbSkip())
  
		   		Enddo

		   		IF _lValCredito

		   			_aRetCre := U_ValidaCredito( _nTotPV , SC5->C5_CLIENTE , SC5->C5_LOJACLI , .T. , , , , SC5->C5_MOEDA,,SC5->C5_NUM)
		   			_cBlqCred:=_aRetCre[1]
		   			aadd(_alog,{SC5->C5_NUM,SC5->C5_CLIENTE,POSICIONE("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"),_Aretcre[1]})
        	
		   			SC5->(Reclock("SC5",.F.))
	
		   				If _aRetCre[2] = "B"//Se bloqueou
		   						   				
		   					If SC5->C5_I_BLCRE == "R"
  			   		
		   						_lBlq2			:= .F.
		   						SC5->C5_I_BLCRE	:= "R"
		   						SC5->C5_I_DTAVA := DATE()
		   						SC5->C5_I_HRAVA := TIME()
		   						SC5->C5_I_USRAV := cusername
		   						SC5->C5_I_MOTBL := _cBlqCred
							
						
		   					Else
						
		   						_lBlq2			:= .F.
		   						SC5->C5_I_BLCRE	:= "B"
		   						SC5->C5_I_DTAVA := DATE()
		   						SC5->C5_I_HRAVA := TIME()
		   						SC5->C5_I_USRAV := cusername
		   						SC5->C5_I_MOTBL := _cBlqCred
								
		   					Endif
		   					
		   					_lRet := .F.  
	
		   				EndIf

		   				SC5->C5_I_MOTBL := _cBlqCred//Sempre grava a descri��o
		   				SC5->(Msunlock())
  
		   		Else
		   		
		   			AADD(_alog,{SC5->C5_NUM,SC5->C5_CLIENTE,POSICIONE("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"),"N�o necessita de avalia��o de cr�dito"})
		   		
		   		ENDIF
		   		
		   		U_ENVSITPV() //Envia interface de situa��o do pedido para o RDC
  
		   ELSE

   			  AADD(_alog,{SC5->C5_NUM,SC5->C5_CLIENTE,POSICIONE("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"),"N�o necessita de avalia��o de cr�dito"})

		   ENDIF

		 Endif
		 
NEXT

Return {_lRet,_aLog}

/*/
===============================================================================================================================
Programa--------: OM200VLD
Autor-----------: Julio de PAula Paz
Data da Criacao-: 12/07/2018
===============================================================================================================================
Descricao-------: Verifica se existe pedidos de vendas com bloqueio de credito e de estoque.
===============================================================================================================================
Parametros------: _aPedidos = Array com os dados dos pedidos de vendas.
===============================================================================================================================
Retorno---------: _lRet = .T./ .F. 
===============================================================================================================================
/*/
Static Function OM200VLD(_aPedCarga)
Local _lRet := .T.
Local _aOrd := SaveOrd({"SC9"})
Local _nI, _aDadosVld := {}
Local _cMsg

Begin Sequence
   //SC5->(Dbseek(_aPedidos[_ni][12]+_aPedidos[_ni][5])) // ordem 1
   // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO+C9_BLEST+C9_BLCRED                                                                                             
   SC9->(DbSetOrder(1))
   
   For _nI := 1 To Len(_aPedCarga)
       _cMsg := ""
       If SC9->(DbSeek(_aPedCarga[_nI][12]+_aPedCargas[_nI][5]))  
          Do While ! SC9->(Eof()) .And. SC9->(C9_FILIAL+C9_PEDIDO) == _aPedCarga[_nI][12]+_aPedCargas[_nI][5] 
             If !Empty(SC9->C9_BLEST)
                _cMsg += " Pedido de vendas com bloqueio de estoque. Item: " + SC9->C9_ITEM + ". "  
             EndIf
          
             If !Empty(sc9->C9_BLCRED )
                _cMsg += " Pedido de vendas com bloqueio de cr�dito. Item: " + SC9->C9_ITEM + ". "
             EndIf
          
             If ! Empty(_cMsg)
                Aadd(_aDadosVld,{_aPedCarga[_nI][12], _aPedCarga[_nI][5], _cMsg})          
                _lRet := .F.
                _cMsg := ""
             EndIf
             
             SC9->(DbSkip())
          EndDo
       Else
          Aadd(_aDadosVld,{_aPedCarga[_nI][12],_aPedCarga[_nI][5], "Pedido de Vendas sem libera��o."})
          _lRet := .F.
       EndIf
   Next
   
   If ! _lRet
   
      U_ITListBox( 'Rela��o de Pedidos que n�o podem montar carga: (OM200VLD)' ,;
		             {"Filial","Pedido de Vendas","Mensagem"} , _aDadosVld , .F. , 1 , 'Resultado da An�lise dos pedidos: ',,;
		             {      30,       30,               80,                   200} )
   
   EndIf

End Sequence

RestOrd(_aOrd)

Return _lRet
