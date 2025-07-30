/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
Autor         |    Data    |                              Motivo                     
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 23/03/2018 | Chamado 19409. Validação do custo medio. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 27/03/2018 | Chamado 24305. Retirada a linha de teste e trocado de GetMv() para U_ItGetMv(). 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 17/04/2018 | Chamado 24535. Ajustes da Validacao do Custo Medio, movida para o rdmake MT250TOK.PRW. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 05/11/2019 | Chamado 30988. Validação p/ não permitir a qtde em 2a UM caso não controle. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 11/11/2019 | Chamado 31146. Ajsute na Validação p/ não permitir a qtde em 2a UM caso não controle. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 14/11/2019 | Chamado 31146. Novo parametro IT_NAOVLDPC p/ não permitir a qtde em 2a UM caso não controle. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 18/01/2023 | Chamado 42590. Novo validacao para armazens do almoxarifado (00, 02). 
===============================================================================================================================*/


/*
===============================================================================================================================
Programa----------: MT250SAL
Autor-------------: Lucas Crevilari
Data da Criacao---: 08/10/2014
===============================================================================================================================
Descrição---------: Manipula os valores de saldos dos produtos a serem requisitados pelo apontamento
===============================================================================================================================
Parametros--------: aSaldos	- Saldos dos produtos a serem requisitados.
Exemplos de conteudo do aSaldos:
AADD(aSaldo,{SC2->C2_PRODUTO,SC2->C2_LOCAL,SaldoMov(Nil,.F.,Nil,Nil,Nil,Nil,Nil,dEmissao)+nQuant,SaldoMov(Nil,.F.,Nil,Nil,Nil,Nil,Nil,dEmissao)+nQuant,SaldoMov(Nil,.F.,Nil,Nil,Nil,Nil,Nil,dEmissao)+nQuant,"N",NIL,NIL})
AADD(aSaldo,{SC2->C2_PRODUTO,SC2->C2_LOCAL,nQuantDig,nQuantDig,nQuantDig,"N",NIL,NIL})
AADD(aSaldo,{aArraySD4[i,w,3],aArraySD4[i,w,4],SaldoMov(Nil,.F.,Nil,Nil,Nil,Nil,Nil,dEmissao),0,0,"S",aArraySD4[i,w,9],aArraySD4[i,w,10]})
AADD(aSaldo,{aArraySD4[i,w,3],aArraySD4[i,w,4],SaldoMov(Nil,.F.,Nil,cParTerc==1,Nil,Nil,Nil,dEmissao) - nQuantBxSD4 - nQtdUsada,0,0,"S",aArraySD4[i,w,9],aArraySD4[i,w,10]})
AADD(aSaldo,{aArraySD4[i,w,3],aArraySD4[i,w,4],0,0,nSaldo-nQuantBxSD4,"S",,aArraySD4[i,w,9],aArraySD4[i,w,10]})
AADD(aSaldo,{aArraySD4[i,w,3],aArraySD4[i,w,4],0,nSaldo - nQuantBxSD4,0,"S",,aArraySD4[i,w,9],aArraySD4[i,w,10]})
===============================================================================================================================
Retorno-----------: aRet 	- Array com os novos saldos a serem considerados pelo programa.
===============================================================================================================================
*/
STATIC _nTotalIt := 0
STATIC _aMostaIt := {}
STATIC aLogErro	 := {}  
STATIC _aProdAlmo:= {}  

User Function MT250SAL()            
                         			
Local aSaldos    := ParamIxb[1]	//Informações do usuário.      
Local dEmissao   := M->D3_EMISSAO //Obtém a data de emissão do mov que está sendo estornado
Local cNumOp	 := M->D3_OP
Local aSldNeg	 := {}
Local aSldNeg2	 := {}  
Local aSldNeg3	 := {}  
Local lErro	 	 := .F.
Local cItens	 := ""
Local nQtdD4	 := 0 
Local nDif		 := 0
Local nQtdD3	 := M->D3_QUANT
Local nQtd		 := 0      
Local cPT		 := M->D3_PARCTOT
Local nQtdC2 	 := SC2->C2_QUANT
Local nQtdQje 	 := SC2->C2_QUJE
Local nQtdC2T 	 := 0 , x , y
Local _aCusUnIt  := _nCustoIt := 0

_nTotalIt := 0
_aMostaIt := {}
aLogErro  := {}
_aProdAlmo:= {}  

For x := 1 To Len(aSaldos)
	
	nQtdD4 	:= Posicione("SD4",2,xFilial("SD4")+cNumOp+aSaldos[x,1]+aSaldos[x,2],"D4_QUANT") //Verifica a quantidade na tabela SD4
	nQtdC2T := nQtdC2 - nQtdQje //Verificar saldo restante na OP
	nQtdeSeg:= SD4->D4_QTSEGUM
	nQtFator:= Posicione("SB1",1,xFilial("SB1")+aSaldos[x,1],"B1_CONV")//JÁ DEIXA O SB1 POSICIONADO
	
	If !lErro
		If (nQtdeSeg == 0 .and. !empty(nQtFator))

			AADD(aLogErro,{aSaldos[x,1],SB1->B1_DESC,"Quantidade na 2a. UM zerada para produto que controla conversão para a 2a. UM" })

		ELSEIf (nQtdeSeg <> 0 .and. EMPTY(nQtFator)) .AND. !ALLTRIM(aSaldos[x,1]) $ U_ItGetMv("IT_NAOVLDPC"," ")//!LEFT(aSaldos[x,1],4)=="0006"

			AADD(aLogErro,{aSaldos[x,1],SB1->B1_DESC,"Quantidade na 2a. UM preenchida para produtos que não controla conversão para a 2a. UM"})
			
		ELSEIf ALLTRIM(aSaldos[x,1]) $ U_ItGetMv("IT_NAOVLDPC"," ")//LEFT(aSaldos[x,1],4)=="0006"
			
			nFtMin   := SB1->B1_I_FTMIN
			nFtMax   := SB1->B1_I_FTMAX
			c1UM     := SB1->B1_UM
			c2UM     := SB1->B1_SEGUM
			nVlrPeca := nQtdD4 / nQtdeSeg
			
			If nFtMin > 0 .AND. nFtMax > 0 .AND. (nVlrPeca < nFtMin .OR. nVlrPeca > nFtMax) //Fora dos limites: menor que o Minimo ou maior que o Maximo

				cItens := "Quantidades informadas (Qte/Qtd. 2a UM) para produto não correspondem aos limites de fator de Conversão: "
				cItens += CVALTOCHAR( nQtdD4 ) +" "+c1UM+" / "
				cItens += CVALTOCHAR( nQtdeSeg ) +" "+c2UM+" = "
				cItens += CVALTOCHAR( nVlrPeca ) +" "+c1UM+" / "+c2UM+CHR(13)+CHR(10)
				cItens += "Fatores do Cadastro do Produto:"+CHR(13)+CHR(10)
				cItens += "Fator Minimo: "+CVALTOCHAR( nFtMin )+" "+c1UM+" / "+c2UM+CHR(13)+CHR(10)
				cItens += "Fator Maximo: "+CVALTOCHAR( nFtMax )+" "+c1UM+" / "+c2UM
			    
			    AADD(aLogErro,{aSaldos[x,1],SB1->B1_DESC,cItens})
				
			Endif
		Endif
	Endif

    If cPT == "T"
    	nQtd := nQtdD4
    Else
    	nQtd := (nQtdD3 * nQtdD4) / nQtdC2T
    Endif	

    If !lErro
       _aCusUnIt:=U_VldCust(aSaldos[x,1], aSaldos[x,2], ddatabase)
       _nCustoIt:=(_aCusUnIt[1]*nQtd)
       _nTotalIt+=_nCustoIt
       AADD(_aMostaIt,{aSaldos[x,1],ALLTRIM(Posicione("SB1",1,xFilial("SB1")+aSaldos[x,1],"B1_DESC")),TRANSFORM(nQtd,"@E 999,999,999.9999"),TRANSFORM(_aCusUnIt[1],"@E 999,999,999,999.99"),TRANSFORM(_nCustoIt,"@E 999,999,999,999.99")})
    ENDIF

    aSldNeg := U_VldEstRetrNeg(aSaldos[x,1], aSaldos[x,2], nQtd, dEmissao) //Varre os saldos de cada dia atá a data de hoje buscando por saldo insuficiente
	If Len(aSldNeg) > 0 
	   nDif := aSldNeg[2] - nQtd
	   AADD(aSldNeg2,{aSaldos[x,1],aSaldos[x,2],nDif,aSaldos[x,4],aSaldos[x,5],aSaldos[x,6],aSaldos[x,7],aSaldos[x,8]}) //Array que será retornado
	   AADD(aSldNeg3,{aSaldos[x,1],aSaldos[x,2],nDif,aSaldos[x,4],aSaldos[x,5],aSaldos[x,6],aSaldos[x,7],aSaldos[x,8],dtoc(aSldNeg[1])}) //Array c/ data para exibir a msg de erro
	   lErro := .T.
	EndIf
	IF EMPTY(aSaldos[x,2]) .OR. aSaldos[x,2] $ "00/02"
	   AADD(_aProdAlmo,{aSaldos[x,1],aSaldos[x,2]})
	ENDIF

Next x

AADD(_aMostaIt,{"","","Toral","Geral:",TRANSFORM(_nTotalIt,"@E 999,999,999,999.99")})

If lErro

	For y := 1 To Len(aSldNeg3)
   		cItens += ALLTRIM(aSldNeg3[y,9])+SPACE(3)+ALLTRIM(aSldNeg3[y,1])+"-"+aSldNeg3[y,2]+SPACE(5)+ALLTRIM(TRANSFORM(aSldNeg3[y,3], "@E 999,999,999,999.99"))+CHR(13)+CHR(10)
	Next
  
    bBloco:={||  AVISO("ATENCAO","DIA"+SPACE(13)+"PRODUTO"+SPACE(16)+"DIFERENCA"+CHR(13)+CHR(10)+cItens,{"Fechar"},3) }

	U_ITMSG("Saldo Insuficiente! Quantidade requisitada é maior que o saldo no dia para o(s) produto(s) "+CHR(13)+CHR(10);
			+"Clique em mais detalhes","Atenção",;
			"Verifique o saldo dos Empenhos.",1,,,,,,bBloco)

	Return (aSldNeg2)

Endif

Return (aSaldos)

/*
===============================================================================================================================
Programa----------: MTnTotalIt()
Autor-------------: Alex Wallauer
Data da Criacao---: 17/04/2018
===============================================================================================================================
Descrição---------: Retorna a STATIC _nTotalIt
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _nTotalIt
===============================================================================================================================
*/
USER Function MTnTotalIt()//Usada na USER FUNCTION MT250TOK()  
//          1          2        3        4
RETURN {_nTotalIt,_aMostaIt,aLogErro,_aProdAlmo}

