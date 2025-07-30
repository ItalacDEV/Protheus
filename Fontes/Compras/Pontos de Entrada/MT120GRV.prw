/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Darcio		  | 09/10/2015 | Foi refeita a grava��o do campo aplica��o, pois este campo foi alterado, foram inclu�das as
              |            | grava��es dos campos Investimento, Urgente e Compra Direta. Chamado 12158.
-------------------------------------------------------------------------------------------------------------------------------
Josu� P.      | 26/11/2015 | Tratamento de atualiza��o da tabela ZZH transferido para PE MT120FIM - Chamado 12651
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 03/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 22/10/2019 | Tratamento para o campo NOVO CLAIM. Chamado 30921 
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#define DS_MODALFRAME   128 

/*
===============================================================================================================================
Programa----------: MT120GRV
Autor-------------: Frederico O. C. Jr
Data da Criacao---: 15/04/2009
===============================================================================================================================
Descri��o---------: Ponto de entrada antes da gravacao do pedido de compra
					Localiza��o: Function A120Pedido - Rotina de Inclus�o, Altera��o, Exclus�o e Consulta dos Pedidos de Compras 
					e Autoriza��es de Entrega.Finalidade...: O  ponto de entrada MT120GRV utilizado para continuar ou n�o a 
					Inclus�o, altera��o ou exclus�o do Pedido de Compra ou Autoriza��o de Entrega.
===============================================================================================================================
Parametros--------: ParamIxb[1] -> C -> N�mero do pedido
					ParamIxb[2] -> A -> Controla a inclus�o
					ParamIxb[3] -> A -> Controla a altera��o
					ParamIxb[4] -> A -> Controla a exclus�o
===============================================================================================================================
Retorno-----------: lRet -> L -> .T. Continuar a inclus�o, altera��o ou exclus�o .F. N�o continuar a inclus�o, altera��o ou exclus�o
===============================================================================================================================
*/
User Function MT120GRV

Local _aArea	:= GetArea()
Local _cCodigo	:= Space(6)
Local _cLoja	:= Space(4)
Local _cNome	:= Space(40)
Local _cFrete	:= Space(1)
Local _aItens	:= {"Entregar na Transportadora","Solicitar Coleta pela Transportadora"}

Private oDlg
Private cSel	:= "Entregar na Transportadora"   
 
If (inclui .or. (altera .and. aCols[1,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_CDTRA"})] == space(6)) )
	
	DEFINE MSDIALOG oDlg TITLE "Transportadora do Pedido de Compra" FROM C(249),C(313) TO C(390),C(680) PIXEL Style DS_MODALFRAME 
	oDlg:LESCCLOSE := .F. 
		
		@ C(010),C(007) Say "Codigo:"							   						   		Size C(020),C(008) PIXEL OF oDlg
		@ C(008),C(030) MsGet _cCodigo	F3 "SA2_03";
			Valid ((substr(_cCodigo,1,1) == "T" .AND. existCpo("SA2",_cCodigo)) .OR. (_cCodigo == space(6) .AND. _cLoja == space(4)) );
			When {|| _cNome := Posicione("SA2",1,xFilial("SA2")+_cCodigo,"SA2->A2_NOME") }		Size C(042),C(009) PIXEL OF oDlg

		@ C(010),C(092) Say "Loja:"								   			   			   		Size C(013),C(008) PIXEL OF oDlg
		@ C(008),C(105) MsGet _cLoja;	
			Valid ((substr(_cCodigo,1,1) == "T" .AND. existCpo("SA2",_cCodigo+_cLoja)) .OR. (_cCodigo == space(6) .AND. _cLoja == space(4)) );
			When {|| _cNome := Posicione("SA2",1,xFilial("SA2")+_cCodigo+_cLoja,"SA2->A2_NOME") }	Size C(022),C(009) PIXEL OF oDlg

		@ C(025),C(007) Say "Raz�o Social:"									   			   		Size C(035),C(008) PIXEL OF oDlg
		@ C(023),C(042) MsGet _cNome 					WHEN .F.			   			 		Size C(134),C(009) PIXEL OF oDlg

		@ C(040),C(007) Say "Obs. Frete:"									   			   		Size C(035),C(008) PIXEL OF oDlg
		@ C(038),C(042) Combobox cSel 					ITEMS _aItens 							SIZE C(134),C(009) PIXEL OF oDlg

		@ C(055),C(105) BMPBUTTON Type 1 ACTION GrvTrans(_cCodigo,_cLoja,cSel)
		@ C(055),C(050) BMPBUTTON TYPE 2 ACTION GrvAplic2(_cCodigo,_cLoja,cSel)
		
	ACTIVATE MSDIALOG oDlg CENTERED       
Else
    GrvAplic(_cCodigo,_cLoja,_cFrete) 
EndIf

RestArea(_aArea)
	
Return(.T.)

/* 
===============================================================================================================================
Programa----------: C
Autor-------------: Frederico O. C. Jr
Data da Criacao---: 04/04/2009
===============================================================================================================================
Descri��o---------: Funcao para o posicionamento de tela	
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function C(nTam)                                                         

Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     

If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
	nTam *= 0.8                                                                
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
	nTam *= 1                                                                  
Else	// Resolucao 1024x768 e acima                                           
	nTam *= 1.28                                                               
EndIf                                                                         
                                                                                
Return Int(nTam)

/*
===============================================================================================================================
Programa----------: GrvTrans
Autor-------------: Frederico O. C. Jr
Data da Criacao---: 04/04/2009
===============================================================================================================================
Descri��o---------: Funcao para gravar transportadora em todas as linhas do pedido de compra       
===============================================================================================================================
Parametros--------: Codigo e Loja do Transportador
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function GrvTrans(_cCodigo,_cLoja,_cFrete)

Local n := 0
	
For n :=1 To Len(acols)
	aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_CDTRA"})]	:= _cCodigo
	aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_LJTRA"})]	:= _cLoja
	aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_NMTRA"})]	:= Posicione("SA2",1,xFilial("SA2")+_cCodigo+_cLoja,"SA2->A2_NOME")

	If _cFrete == "Entregar na Transportadora"
		aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_TPFRT"})]	:= "1"
	Else
		aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_TPFRT"})]	:= "2"
	EndIf  

	If (Empty(aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_CLAIM"})]) .Or. Empty(SC7->C7_NUMSC))//CLAIN
		aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_CLAIM"})]	:= cClaim
	EndIf

	If (Empty(aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_APLIC"})]) .Or. Empty(SC7->C7_NUMSC))
		aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_APLIC"})]	:= cAplic
	EndIf
	If (Empty(aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_CDINV"})]) .Or. Empty(SC7->C7_NUMSC))
		aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_CDINV"})]	:= cCInve
	EndIf
	If (Empty(aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_DSINV"})]) .Or. Empty(SC7->C7_NUMSC))
		aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_DSINV"})]	:= cDsInv
	EndIf
	If (Empty(aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_URGEN"})]) .Or. Empty(SC7->C7_NUMSC))
		aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_URGEN"})]	:= cUrgen
	EndIf
	aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_CMPDI"})]	:= cCompD
Next

close(odlg)
	
Return 

/*
===============================================================================================================================
Programa----------: GrvAplic
Autor-------------: Talita Teixeira 
Data da Criacao---: 05/02/2013 
===============================================================================================================================
Descri��o---------: Funcao para gravar aplica��o em todas as linhas do pedido de compra     
===============================================================================================================================
Parametros--------: Codigo e Loja do Transportador  		
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function GrvAplic(_cCodigo,_cLoja,_cFrete) 

Local n			:= 0 
Default _cCodigo:= Space(6)
Default _cLoja	:= Space(4)
Default _cFrete	:= Space(1)

For n :=1 to len(acols)

	If (Empty(aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_CLAIM"})]) .Or. Empty(SC7->C7_NUMSC))//CLAIN
		aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_CLAIM"})]	:= cClaim
	EndIf

	If (Empty(aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_APLIC"})]) .Or. Empty(SC7->C7_NUMSC))
		aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_APLIC"})]	:= cAplic
	EndIf
	If (Empty(aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_CDINV"})]) .Or. Empty(SC7->C7_NUMSC))
		aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_CDINV"})]	:= cCInve
	EndIf
	If (Empty(aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_DSINV"})]) .Or. Empty(SC7->C7_NUMSC))
		aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_DSINV"})]	:= cDsInv
	EndIf
	If (Empty(aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_URGEN"})]) .Or. Empty(SC7->C7_NUMSC))
		aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_URGEN"})]	:= cUrgen
	EndIf
	aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_CMPDI"})]	:= cCompD
Next

Return

/*
===============================================================================================================================
Programa----------: GrvAplic
Autor-------------: Talita Teixeira 
Data da Criacao---: 05/02/2013  
===============================================================================================================================
Descri��o---------: Funcao para gravar aplica��o em todas as linhas do pedido de compra     
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function GrvAplic2(_cCodigo,_cLoja,_cFrete) 

Local n := 0 
	
For n :=1 To Len(acols)

	If (Empty(aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_CLAIM"})]) .Or. Empty(SC7->C7_NUMSC))//CLAIN
		aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_CLAIM"})]	:= cClaim
	EndIf

	If (Empty(aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_APLIC"})]) .Or. Empty(SC7->C7_NUMSC))
		aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_APLIC"})]	:= cAplic
	EndIf
	If (Empty(aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_CDINV"})]) .Or. Empty(SC7->C7_NUMSC))
		aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_CDINV"})]	:= cCInve
	EndIf
	If (Empty(aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_DSINV"})]) .Or. Empty(SC7->C7_NUMSC))
		aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_DSINV"})]	:= cDsInv
	EndIf
	If (Empty(aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_URGEN"})]) .Or. Empty(SC7->C7_NUMSC))
		aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_URGEN"})]	:= cUrgen
	EndIf
	aCols[n,aScan(aHeader,{|x| rTrim(Upper(x[2])) == "C7_I_CMPDI"})]	:= cCompD
Next
 
close(odlg)

Return