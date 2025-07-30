/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer| 27/07/2017 | Chamado 20901. Ajuste na fun��o ITVLPRTR.     
 Josu� Danich | 17/04/2018 | Chamado 24295. Valida��o de tabela de pre�os.                                
 Josu� Danich | 22/05/2019 | Chamado 28370. Ajustes de tabelas de pre�os.                    
 Alex Wallauer| 17/09/2019 | Chamado 30543. Ajuste para ignorar a funcao M520_Valida. 
 Lucas Borges | 15/10/2019 | Chamado 28346. Removidos os Warning na compila��o da release 12.1.25. 
 Jerry        | 17/08/2020 | Chamado 33729. Removido valida��o de pre�o. 
 Jerry        | 19/10/2020 | Chamado 34422. Ajuste para n�o validar quando Estorno de Nota por OC. 
 Jerry        | 01/02/2020 | Chamado 34860. Ajuste da chamada dos Par�metros ITALAC. 
 Julio Paz    | 19/04/2022 | Chamado 36404. Cria��o de Fun��es p/edi��o campo C6_I_PTBRU para produtos com controle de peso.
 Jerry        | 29/04/2022 | Chamado 38883. juste na Efetiva��o Automatica Pedido Portal retirando paradas em tela. 
 Alex Wallauer| 23/01/2024 | Chamado 46145. Jerry. Troca da fun��o de U_ITMSG() para U_MT_ITMSG().
=================================================================================================================================================================================================
Analista       - Programador   - Inicio   - Envio    - Chamado - Motivo da Altera��o
=================================================================================================================================================================================================
 Vanderlei     - Alex Wallauer - 10/04/25 -          - 49894   - Alterado para preencher o campo C6_I_PTBRU sempre com (SB1->B1_PESBRU * aCols[N,_nPosQtd1]).
=================================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.Ch" 
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*
===============================================================================================================================
Programa----------: AOMS027 
Autor-------------: Frederico O. C. Jr
Data da Criacao---: 22/07/2009  
===============================================================================================================================
Descri��o---------: Valida��o do campo C6_PRODUTO
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lret -> campo validado ou n�o
===============================================================================================================================
*/
User Function AOMS027()

Local _lReturn	:= .T.  
Local _nCont	:= 1 
Local _nPos, _cProd, _cCodProd  
Local _npreco    := 0  
Local _aArea     := getarea()
Local _cfildest  := ""
Local _cfilmed   := ""
Local _ndiamed   := 15
Local _nfatortra := 1.0476
Local _dinicial  := stod('20010101')
Local _dfinal    := stod('20010101')  
Local _cmens     := "" 
Local _cSvFilAnt := cFilAnt //Salva a Filial Anterior
Local _atabelas  := {}
Local _cOpPMedio := "" 
Local _lAoms112  := .F. 

//Se esta sendo chamado via AOMS112/MOMS050 (Central Pedido Portal / Efetiva��ao Automatica)
If IsInCallStack("U_AOMS112") .or. IsInCallStack("U_MOMS050")
	_lAoms112 := .T.
Endif
  
//-----------------------------------------------------------------------------
//Se for Exclus�o de Documento Troca nota n�o efetuar as valida��es abaixo
//-----------------------------------------------------------------------------

If  (FunName() $ "MATA140,MATA521B,MATA460B" .Or. _lAoms112  ) 
	Return .T.
EndIf 

//-----------------------------------------------------------------------------
//verifica se o produto n�o est� presente em outra linha j�, mesmo que deletado
//-----------------------------------------------------------------------------


if (FunName() == "MATA410" .and. M->C5_TIPO <> 'D' .And. POSICIONE("SB1",1,xFilial("SB1")+C6_PRODUTO,"B1_TIPO") == 'PA') 
	
	If LEN(aCols) > 1 //1o produto
		
		_cProd		:= AllTrim(aCols[n,aScan(aHeader,{|X| rTrim(Upper(X[2]))=="C6_DESCRI"})])
		
		_nPos		:= aScan(aHeader,{|X| rTrim(Upper(X[2]))=="C6_PRODUTO"})
		_cCodProd	:= M->C6_PRODUTO
		
		
		For _nCont := 1 to LEN(aCols)
			
			If _nCont <> n .and. _cCodProd == aCols[_nCont,_nPos]
				
				If !aCols[_nCont,len(acols[_nCont])]
	
					U_MT_ITMSG("Aten��o: O item: " + _cProd + " j� foi digitado...",,,1)
					Return .F.
	
				ElseIf _nCont <> n .And. !Empty(aCols[_nCont,aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Trim('C6_I_LIBPE')})]) .And. !aCols[n,len(aHeader)+1]
	
					Return .T.
	
				Else
	
					U_MT_ITMSG("Aten��o: O item: " + _cProd + " j� foi digitado, porem se encontra deletado. Favor reativar a linha...",,,1)
					Return .F.
	
				EndIf
		
			EndIf
			
		Next
		
	Endif

Endif

//--------------------------------------------------------------------
//Validacao da tabela de preco de NOTAS FISCAIS de transferencia chamdo 2068 
//Ajustada de acordo com chamado 11064 para que em caso de filial destino que usa m�dia de pre�o
//ao inv�s de tabela de pre�o aceite o pre�o 
//-------------------------------------------------------------------
dbselectarea("Z09")
Z09->( dbsetorder(2) )

If (posicione("SB1",1,xfilial("SB1")+alltrim(M->C6_PRODUTO),"B1_TIPO") == 'PA' ;
	.OR. posicione("SB1",1,xfilial("SB1")+alltrim(M->C6_PRODUTO),"B1_GRUPO") == '0813') .AND. ;
	Z09->(DbSeek(XFilial("Z09")+M->C5_I_OPER) )   
	
	_cOpPMedio := U_ITGETMV( 'IT_OPMEDIO' , "22" ) //Operacao do que busca o preco medio do SB2

	//verifica se cliente tem campo filial origem v�lido
	dbselectarea("SA1")
	SA1->( dbsetorder(1) )
	 
	if SA1->( dbseek(xfilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI) )
	  
		if !(alltrim(SA1->A1_I_FILOR) >= '01' .and. alltrim(SA1->A1_I_FILOR) <= 'ZZ')
		
				U_MT_ITMSG( "Cliente n�o � filial v�lida para receber transfer�ncia","Alerta",;
				"Favor solicitar apoio ao Departamento Fiscal/Comercial.",1)
				Return .F.
  		
  		Endif
  		
  	Endif
  		
  	_cfildest  := alltrim(posicione("SA1",1,xfilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"SA1->A1_I_FILOR")) //filial destino do cliente selecionado
	_cfilmed   := U_ITGETMV("IT_FILMEDT","") //filiais que usam m�dia de pre�o   
	_ndiamed   := U_ITGETMV("IT_DIASTRA",15)  //dias corridos para fazer a m�dia de pre�o
	_nfatortra := 0 //fator a ser aplicado a m�dia de pre�o
	_cProduto  := alltrim(M->C6_PRODUTO)

 	//muda para filial destino para pegar o par�metro
	cFilAnt := _cfildest

	_nfatortra := U_ITGETMV("IT_FATORTRA",1.0476) //fator a ser aplicado a m�dia de pre�o
	
	//volta a filial local
	cFilAnt := _cSvFilAnt

	//Se filial destino pertence ao IT_FILMEDTRA usa m�dia de pre�o
	if alltrim(_cfildest) $ _cfilmed .and. !M->C5_I_OPER $ _cOpPMedio

		//calcula faixa de an�lise de m�dia de vendas
    	//ultimo dia de venda desde que n�o seja o dia atual (que n�o est� completo) menos a quantidade de dias do IT_DIASTRA
       _adatas := U_AOMS002C(_cfildest,_cproduto,_ndiamed)
       _dinicial := _adatas[1]
       _dfinal   := _adatas[2]     	  
	  
	    //calcula m�dia de preco de vendas
	    _npreco := U_AOMS002M(_dinicial,_dfinal,_cfildest,_cproduto,_nfatortra)
	   
  	else  

  		//marca flag para executa c�lculo por tabela de pre�o de transfer�ncia
  		_cmens     := "tabela"
 
	endif

	if len(_cmens) > 1.and. !M->C5_I_OPER $ _cOpPMedio

		
		_atabelas := _npreco := U_AOMS002P(AllTrim(M->C6_PRODUTO),xfilial("SC5"),_cfildest,AllTrim(M->C5_I_OPER)) 
   		_npreco := _atabelas[1]
   	
		If _npreco == 0 
		  
    		//N�o tem tabela de pre�o de transfer�ncia para o produto
    		U_MT_ITMSG("Para o tipo de opera��o "+AllTrim(M->C5_I_OPER)+", o produto "+AllTrim(M->C6_PRODUTO)+" e Fil.Dest. "+_cfildest+", n�o est� cadastrado na Tabela de Pre�o de Transfer�ncia (Z09).",;
    		"Valida��o de pre�o de transfer�ncia",;
			"Favor solicitar apoio ao Departamento Comercial.",1)
			
			Return .F.
   
  		Endif

    elseif M->C5_I_OPER $ _cOpPMedio

        _lReturn:=u_ITVLPRTR(M->C5_I_OPER,M->C6_PRODUTO,0,1)
        
  	Endif

Endif
 
Restarea(_aArea)

Return _lReturn
 
/* 
===============================================================================================================================
Programa----------: AOMS027W 
Autor-------------: Julio de Paula Paz
Data da Criacao---: 19/04/2022
===============================================================================================================================
Descri��o---------: Habilita e desabilita a edi��o do campo C6_I_PTBRU. Quando o produto possuir peso vari�vel a edi��o pode
                    ser realizada. Caso contr�rio, o Peso n�o poder� ser alterado.
===============================================================================================================================
Parametros--------: _cCampo = Do Whem que chamou a rotina.
===============================================================================================================================
Retorno-----------: _lret -> campo validado ou n�o
===============================================================================================================================
*/
User Function AOMS027W(_cCampo)
Local _lRet := .F.
Local _nPosPrd, _nPosPBTI 

Begin Sequence 
   
   If _cCampo =="C6_I_PTBRU"
      _nPosPrd	:= Ascan(aHeader,{|X| AllTrim(Upper(X[2]))=="C6_PRODUTO"})
      _nPosPBTI := Ascan(aHeader,{|x| Alltrim(Upper(x[2]))=="C6_I_PTBRU"})  

	  SB1->(DbSetOrder(1))
	  SB1->(DbSeek(xfilial("SB1")+aCols[N,_nPosPrd]))
	  If SB1->B1_I_PCCX > 0 // Possui peso vari�vel. Habilita a edi��o.
         _lRet := .T.
	  EndIf 

   EndIf 

End Sequence 

Return _lRet 

/*
===============================================================================================================================
Programa----------: AOMS027G 
Autor-------------: Julio de Paula Paz
Data da Criacao---: 19/04/2022
===============================================================================================================================
Descri��o---------: Trigger de preenchimento do campo C6_I_PTBRU, quando as quantidades na primeira e segunda unidade de 
                    medida forem alterados e o produto possuir o peso vari�vel.
===============================================================================================================================
Parametros--------: _cCampo = Do Whem que chamou a rotina.
===============================================================================================================================
Retorno-----------: _nRet   = Valor a ser retornado para o campo C6_I_PTBRU.
===============================================================================================================================
*/
User Function AOMS027G(_cCampo)
Local _nRet := 0
Local _nPosPrd, _nPosPBTI 

Begin Sequence 
   
   If _cCampo == "C6_QTDVEN" .Or. _cCampo == "C6_UNSVEN" 
      _nPosPrd	:= Ascan(aHeader,{|X| AllTrim(Upper(X[2]))=="C6_PRODUTO"})
      _nPosPBTI := Ascan(aHeader,{|x| Alltrim(Upper(x[2]))=="C6_I_PTBRU"}) 
	  _nPosQtd1 := Ascan(aHeader,{|x| Alltrim(Upper(x[2]))=="C6_QTDVEN" }) 

	  SB1->(DbSetOrder(1))
	  SB1->(DbSeek(xfilial("SB1")+aCols[N,_nPosPrd]))
	  If SB1->B1_I_PCCX > 0 // Possui peso vari�vel. Habilita a edi��o.
         _nRet := (SB1->B1_PESBRU * aCols[N,_nPosQtd1])
	  Else 
         _nRet := (SB1->B1_PESBRU * aCols[N,_nPosQtd1]) // Agora preenche o campo C6_I_PTBRU sempre.
	  EndIf 

   EndIf 
   
End Sequence 

Return _nRet   
