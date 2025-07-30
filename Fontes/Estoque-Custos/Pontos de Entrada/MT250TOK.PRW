/*
===============================================================================================================================
                                            ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
Autor         |    Data    |                              Motivo                       
-------------------------------------------------------------------------------------------------------------------------------
Andre Lisboa  | 02/10/2014 | Retirada trava para apontamentos maiores quando tipo diferente de "PA"
-------------------------------------------------------------------------------------------------------------------------------
Andre Lisboa  | 10/11/2016 | Chamado 17597. Incluida a validação de segunda unidade de medida. 			                      
-------------------------------------------------------------------------------------------------------------------------------
Alex Walaluer | 17/04/2018 | Chamado 24535. Ajustes a Validacao do Custo Medio, movida do rdmake MT250SAL.PRW. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 16/04/2019 | Chamado 28685. Validação p/ não permitir fracionamento de UM que são inteiras. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 05/11/2019 | Chamado 30988. Validação p/ não permitir a qtde em 2a UM caso não controle. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 11/11/2019 | Chamado 31146. Ajsute na Validação p/ não permitir a qtde em 2a UM caso não controle. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 14/11/2019 | Chamado 31146. Novo parametro IT_NAOVLDPC p/ não permitir a qtde em 2a UM caso não controle. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 18/01/2023 | Chamado 42590. Novo validacao para armazens do almoxarifado (00, 02). 
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"
#DEFINE CRLF CHR(13)+CHR(10)

/*
===============================================================================================================================
Programa----------: MT250TOK
Autor-------------: Carlos Cleber A.Silva
Data da Criacao---: 03/12/2013
===============================================================================================================================
Descrição---------: Este pe permite validar algo digitado dependendo da necessidade do usuário, ele valida a tela toda
------------------  http://tdn.totvs.com.br/display/public/mp/MT250TOK+-+Valida+valor+digitado+ou+tela+toda
===============================================================================================================================
Uso---------------: Impedir de criar producao com o centro de custo em branco forcando a informar o centro de custo        	 	
------------------  Chamado 4356
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T. = Permite confirmar lancamento
------------------: .F. = Nao Permite confirmar lancamento 
===============================================================================================================================*/
User Function MT250TOK()  

Local lRet     := .T. 
Local dDtServ  := dDataBase
Local dDtAtual := DATE() 
Local dDtEms   := (M->D3_EMISSAO)
Local nQuantOP := Posicione("SC2",1,xFilial("SC2")+M->D3_OP,"C2_QUANT")
Local nQuantPr := (M->D3_QUANT)
Local nQtdeSeg := (M->D3_QTSEGUM)	
Local nResult  := 0 ,Y
Local nQtFator := Posicione("SB1",1,xFilial("SB1")+M->D3_COD,"B1_CONV")
Local _lValidFrac1UM:=.T.
Local nQtde1UN:=M->D3_QUANT
Local nQtde2UN:=M->D3_QTSEGUM

	//Verifica se o centro de custo esta em branco        ³
	If  Empty(M->D3_CC)  
	
		lRet := .F. 
		
		U_ITMSG("O centro de custo,não pode ficar em branco!","PROBLEMA CENTRO DE CUSTO",;
		        "O centro de custo é obrigatório, para concluir a operação favor informar corretamente atentando a FILIAL e PRODUTO!",1) 
		
	EndIf
	
	//Verifica se a Data Base eh maior que a data atual   
	If dDtServ > dDtAtual .Or. dDtEms > dDtServ  
	
    	lRet := .F. 
	
		U_ITMSG("Para incluir Produção a 'Data de emissão' não pode ser maior que a 'Data atual do servidor ou Data base do sistema'. Não é permitido criar Produção com data futura! ","PROBLEMA DATA BASE",;
		        +CRLF+"Data Atual(SO): "+DTOC(dDtAtual)+" "+CRLF+"Data Base(Sistema): "+DTOC(dDtServ)+" "+CRLF+"Data Emissão: "+DTOC(dDtEms),; 
		        "Conferir a 'Data Base do sistema' e ajustar a 'Data de emissão' se necessário.",1)
		
    EndIf
    
	//Verifica a qtde na 2aUM dos produtos	           
 	If nQtdeSeg == 0 .and. !empty(nQtFator)
 		lRet := .F.
		
		U_ITMSG("Quantidade na 2a. UM zerada para produto que controla conversão para a 2a. UM","PROBLEMA 2A.UM",;
		        "Favor verificar o apontamento ou o cadastro do produto.",1 )

	Endif	

	//Verifica a qtde na 2aUM dos produtos	           
 	If nQtdeSeg <> 0 .and. EMPTY(nQtFator) .AND. !ALLTRIM(M->D3_COD) $ U_ItGetMv("IT_NAOVLDPC"," ")//!LEFT(M->D3_COD,4)=="0006" 
 		lRet := .F.
		
		U_ITMSG("Quantidade na 2a. UM preenchida para produto que não controla conversão para a 2a. UM","PROBLEMA 2A.UM",;
		        "Favor verificar o apontamento ou o cadastro do produto.",1 )

	Endif	
    

	// Verifica se a quantidade apontada é maior que a quantidade da OP   
	//André - 07/04/2014
  
   	nResult		:= nQuantPr - nQuantOP
	nTotal 		:= (nResult/nQuantOP)*100
	nPctPrd 	:= GETMV("IT_PCTPRD" ,, "" )
//	cPrdPerm	:= GETMV("IT_PRDPERM")
//  cTipo		:= Posicione("SB1",1,xFilial("SB1")+M->D3_COD,"B1_TIPO")
	
	If nResult > 0
	
		If nTotal > nPctPrd .and. !Empty(M->D3_CC)  //Trim(M->D3_COD) $ cPrdPerm//cTipo <> "PA" .and.
			
			
			//"Apontamento de produção com quantidade acima da quantidade original da OP!")
			If ! MsgYesNo("Apontamento de produção com acima da quantidade informada na OP! ("+Transform(Round(nTotal,2),"E@ 99.99")+"%"+")"+ ", Confirma ? ") // " +Transform(nPctPrd,"E@ 99.99")+ "
			   lRet := .F.
			Else
			   If !Empty(M->D3_CC)
			      Motivo()
			      lRet := .T.
			   Endif   
			EndIf
		//Else	
	   //    lRet := .F.
	   //    xMagHelpFis("MT250TOK - PRODUÇÃO NÃO PERMITIDA",;
	   //    "Não permitido apontamento de produção com quantidade acima da quantidade da OP para este produto ",;
		//   "Verique a quantidade apontada.")
	    Endif
	EndIf	

IF U_ItGetMv("IT_VLDCUS",.T.) .AND. !MTVusto() 
   lRet := .F.
ENDIF

IF lRet
   aLogErro:= U_MTnTotalIt()[3] //Função dentro da USER FUNCTION MT250SAL()
   IF LEN(aLogErro) > 0
      lRet := .F.

     aBotoes:={}
	 AADD( aBotoes , { "" , {|| AVISO("ATENCAO",oLbxAux:aArray[oLbxAux:nAt][ 3 ],{"Fechar"},3) }	, "" , "Ver Erro"		  } )

	//    ITListBox(_cTitAux               , _aHeader , _aCols    , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons )
      U_ITListBox( 'Relação dos Produtos com Problemas' ,;
	             {"Codigo","Produto","Erro"} , aLogErro , .T. , 1 , "Verifique o saldo dos Empenhos",,;
	             {      35,      090,   200} ,/*_nCampo*/ ,/*bOk*/,/*bCancel*/, aBotoes)
   ENDIF
ENDIF

SB1->(DBSETORDER(1))
SB1->(dbSeek(xFilial("SB1") + M->D3_COD ))

IF lRet
	
	ZZL->( DBSetOrder(3) )
	If ZZL->( DBSeek( xFilial("ZZL") + RetCodUsr() ) )
		If ZZL->(FIELDPOS("ZZL_PEFRPA")) = 0 .OR. ZZL->ZZL_PEFRPA == "S"
			_lValidFrac1UM:=.F.
		EndIf
	EndIf
	ZZL->( DBSetOrder(1) )
	
	IF _lValidFrac1UM .AND. SB1->B1_TIPO == "PA"
		IF (SB1->B1_UM == "UN" .AND. M->D3_QUANT <> Int(M->D3_QUANT))
			U_ITMSG("Não é permitido fracionar a quantidade da 1a. UM de produto onde a Unid. Medida for UN.",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
		            "Validação Fracionado",;
			        "Favor informar apenas quantidades inteiras na Primeira Unidade de Medida. Valor digitado: "+ALLTRIM(STR(Int(M->D3_QUANT),22)),1)
			
			lRet := .F.
		ENDIF
		IF ( SB1->B1_SEGUM = "PC" .AND. ALLTRIM(M->D3_COD) $ U_ItGetMv("IT_NAOVLDPC"," ") .AND. M->D3_QTSEGUM <> Int(M->D3_QTSEGUM) )//LEFT(M->D3_COD,4)=="0006"
			U_ITMSG("Não é permitido fracionar a quantidade da 2a. UM para produtos onde a Unid. Medida for PC.",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
			        "Validação Fracionado",;
			        "Favor informar apenas quantidades inteiras na Segunda Unidade de Medida. Valor digitado: "+ALLTRIM(STR(Int(M->D3_QTSEGUM),22)),1)
			lRet := .F.
		ENDIF
	ENDIF                                                                                    	
	
EndIf


If lRet .AND. nQtde1UN # 0 .AND. ALLTRIM(M->D3_COD) $ U_ItGetMv("IT_NAOVLDPC"," ")//LEFT(M->D3_COD,4)=="0006" 
	
	nFtMin   := SB1->B1_I_FTMIN
	nFtMax   := SB1->B1_I_FTMAX
	c1UM     := SB1->B1_UM
	c2UM     := SB1->B1_SEGUM
	nVlrPeca := nQtde1UN / nQtde2UN
	
	If nFtMin > 0 .AND. nFtMax > 0 .AND. (nVlrPeca < nFtMin .OR. nVlrPeca > nFtMax) //Fora dos limites: menor que o Minimo ou maior que o Maximo
		
		cItens := "Conversão: "
		cItens += CVALTOCHAR( nQtde1UN ) +" "+c1UM+" / "
		cItens += CVALTOCHAR( nQtde2UN ) +" "+c2UM+" = "
		cItens += CVALTOCHAR( nVlrPeca ) +" "+c1UM+" / "+c2UM+CHR(13)+CHR(10)
		cItens += "Fatores do Cadastro do Produto:"+CHR(13)+CHR(10)
		cItens += "Fator Minimo: "+CVALTOCHAR( nFtMin )+" "+c1UM+" / "+c2UM+CHR(13)+CHR(10)
		cItens += "Fator Maximo: "+CVALTOCHAR( nFtMax )+" "+c1UM+" / "+c2UM

        bBloco:={||  AVISO("ATENCAO","Verifique as quantidades informadas para esse produto:"+ CHR(13) + CHR(10) + cItens,{"Fechar"},3) }

		U_ITMSG("Quantidades informadas (Quantidade/Qtd. 2a UM) para produto "+AllTrim(SB1->B1_DESC)+" não correspondem aos limites de fator de conversão.",;
		        "Validação fator conversão",;
		        "Verifique as quantidades informadas para esse produto: Clique em mais detalhes",1,,,,,,bBloco )
		
		lRet := .F.
		
	Endif
Endif

IF lRet
   _aProdAlmo:= U_MTnTotalIt()[4] //Função dentro da USER FUNCTION MT250SAL()
   IF LEN(_aProdAlmo) > 0    
      cItens:=""
      cItensB:=""
	  _cSpcC:=13
	  _cSpcT:=15
	  For y := 1 To Len(_aProdAlmo)
	      IF EMPTY(_aProdAlmo[y,2])
             cItensB+=ALLTRIM(_aProdAlmo[y,1])+", "
	  	  ELSE
   	  	     cItens +=ALLTRIM(_aProdAlmo[y,1])+SPACE(_cSpcT)+_aProdAlmo[y,2]+CHR(13)+CHR(10)
	  	  ENDIF
	  Next

      IF !EMPTY(cItensB)
	     U_ITMSG("Existem produtos sem armazem, preencha-os na tela de ajuste de empenhos.","Atenção","Produtos: "+cItensB,1)
  
         RETURN .F.
  
	  ENDIF

      bBloco:={||  AVISO("ATENCAO","  PRODUTO"+SPACE(_cSpcC)+"ARMAZEM"+CHR(13)+CHR(10)+cItens,{"Fechar"},3) }
  
	  IF !(lRet:=U_ITMSG("Armazéns a serem consumidos não estão no pulmão de fábrica, deseja prosseguir o consumo do armazéns do almoxarifado?",;
	                     "Atenção","Clique em mais detalhes para ver os produtos",3,2,2,,,,bBloco))
  
	  	U_ITMSG("Altere os empenhos dos produtos para o armazém pulmão",;
	  	        "Atenção","Clique em mais detalhes para ver os produtos",1,,,,,,bBloco)
  
	  ENDIF
   ENDIF
ENDIF

Return(lRet)

/*
===============================================================================================================================
Programa----------: Motivo()
Autor-------------: 
Data da Criacao---: 
===============================================================================================================================
Descrição---------: 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function Motivo()
   Local  oTELA01
   Local  cMotivo := SC2->C2_I_MOTIV
   Local  lRet := .T.         
   Local  oMotivo
   Local  cNumOP := M->D3_OP

         ////////////
         //MONTA TELA
         ////////////  
         
         DEFINE MSDIALOG oTELA01 TITLE "Motivo de Ganho de produção/Produção a maior " FROM 000, 000  TO 200, 400 Of oTELA01 Pixel
               
               @ 001,004 SAY "Motivo: "
               @ 006,004 GET oMotivo Var cMotivo MEMO Size C(336),C(033) When .T. of oTELA01 PIXEL
               @ 056,067 BUTTON "&Confirma" SIZE 030,13 Pixel ACTION (GrvMotiv(cMotivo,cNumOP),oTELA01:End())
               @ 056,107 BUTTON "&Cancela"  SIZE 030,13 Pixel ACTION (lRet:=.F.,oTELA01:End())
               
         ACTIVATE MSDIALOG oTELA01 CENTERED        

Return
 	
/*
===============================================================================================================================
Programa----------: GrvMotiv(cMotivo,cNumOP)
Autor-------------: 
Data da Criacao---: 
===============================================================================================================================
Descrição---------: 
===============================================================================================================================
Parametros--------: cMotivo,cNumOP
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function GrvMotiv(cMotivo,cNumOP)

	DbSelectArea("SC2")
	DbSetOrder(1)
	DbSeek(xFilial("SC2")+cNumOP)
	
	RecLock("SC2",.F.)
	SC2->C2_I_MOTIV := cMotivo   
	MsUnlock()

Return   


/*
===============================================================================================================================
Programa----------: MTVusto()
Autor-------------: Alex Wallauer
Data da Criacao---: 19/12/2017
===============================================================================================================================
Descrição---------: Validação do custo medio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T. ou .F.
===============================================================================================================================
*/
STATIC Function MTVusto()
                         			
Local _nTotalIt:= U_MTnTotalIt()[1] //Função dentro da USER FUNCTION MT250SAL()
Local _aMostaIt:= U_MTnTotalIt()[2] //Função dentro da USER FUNCTION MT250SAL()
Local nCMAtu   := _nTotalIt / M->D3_QUANT//Custo medio de Produção
Local aCMLib   := U_VldCust(M->D3_COD, M->D3_LOCAL, ddatabase)
Local nCMLib   := aCMLib[1]//percentual liberado de diferença
Local nDifCM   := U_ItGetMv("IT_DIFCMP",15)
Local nDifCM2  := U_ItGetMv("IT_DIFCMP2",50)
Local lRetorno := .T.

IF _nTotalIt <= 0

   IF U_ITMSG("Apontamento não permitido, o custo total da produção esta "+IF(_nTotalIt=0,"zerado","menor que zero "+ALLTRIM(STR(_nTotalIt,15,2)))+"."+CHR(13)+CHR(10)+;
              "DESEJA  ANALISAR OS VALORES DOS PRODUTOS?","Atenção",;
	          "Favor analisar o Kardex! Se necessário, entre em contato com o Depto. de Custos.",1,2,2)
	       If LEN(_aMostaIt) > 0
	
		      U_ITListBox( 'Relação dos Produtos' ,;
		             {"Codigo","Produto","Quantidade","Valor","Total"} , _aMostaIt , .F. , 1 , 'Análise dos valores dos Produtos: ',,;
		             {      35,       40,          35,     35,     35} )
           ELSE
              U_ITMSG("Não foram encotrados produtos para analizar","Atenção","Favor analisar os Empenhos! Se necessário, entre em contato com o Depto. de Custos.",1)
	       ENDIF
    ENDIF

	lRetorno := .F.

ELSEIf nCMLib > 0
         //C M producao  //Custo medio atual
	nDifCus:= (nCMAtu - nCMLib) / nCMLib

	If nDifCus < 0
	   nDifCus := (nDifCus * (-1))
	Endif

	nDifCus := nDifCus * 100
	
	If nDifCus >= nDifCM .and. nDifCus <= nDifCM2 //Diferenca entre 15% e 30%

		If U_ITMSG("Diferença entre valor de Custo Medio da producao e custo atual é "+ALLTRIM(TRANSFORM(nDifCus, "@E 999,999,999.99999"))+"%.",;
		           "Atençao","DESEJA  ANALISAR OS VALORES DOS PRODUTOS?",3,2,2)
	       If LEN(_aMostaIt) > 0
		      U_ITListBox( 'Relação dos Produtos' ,;
		             {"Codigo","Produto","Quantidade","Valor","Total"} , _aMostaIt , .F. , 1 , 'Análise dos valores dos Produtos: ',,;
		             {      35,       40,          35,     35,     35} )
           ELSE
              U_ITMSG("Não foram encotrados produtos para analizar","Atenção","Favor analisar os Empenhos! Se necessário, entre em contato com o Depto. de Custos.",1)
			  lRetorno := .F.
	       ENDIF
		Endif

		If lRetorno .AND. !U_ITMSG("Diferença entre valor de Custo Medio da producao e custo atual é "+ALLTRIM(TRANSFORM(nDifCus, "@E 999,999,999.99999"))+"%.","Atençao","DESEJA CONFIRMAR O APONTAMENTO?",3,2,2)
			lRetorno := .F.
		Endif

	Elseif nDifCus >= nDifCM2 //Diferenca maior que 30%

		IF U_ITMSG("Produção não permitida! Diferença entre valor de Custo Medio da produção e o atual é "+ALLTRIM(TRANSFORM(nDifCus,"@E 999,999,999.9999"))+" %"+CHR(13)+CHR(10)+;
		           "Custo Unitário Atual: R$ "+ALLTRIM(TRANSFORM(nCMLib,"@E 999,999,999.99999"))+CHR(13)+CHR(10)+;
		           "Custo Unitário Produção: R$ "+ALLTRIM(TRANSFORM(nCMAtu,"@E 999,999,999.99999"))+CHR(13)+CHR(10)+;
		           "DESEJA  ANALISAR OS VALORES DOS PRODUTOS?",;
		           "Atenção",;
		           "Favor analisar o Kardex! Se necessário, entre em contato com o Depto. de Custos.",1,2,2)

	       If LEN(_aMostaIt) > 0
		      U_ITListBox( 'Relação dos Produtos' ,;
		             {"Codigo","Produto","Quantidade","Valor","Total"} , _aMostaIt , .F. , 1 , 'Análise dos valores dos Produtos: ',,;
		             {      35,       40,          35,     35,     35} )
           ELSE
              U_ITMSG("Não foram encotrados produtos para analizar","Atenção","Favor analisar os Empenhos! Se necessário, entre em contato com o Depto. de Custos.",1)
	       ENDIF

		ENDIF           

		lRetorno := .F.
	Endif
Endif

RETURN lRetorno
