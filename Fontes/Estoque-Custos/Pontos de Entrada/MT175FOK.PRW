/*
====================================================================================================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
       Autor          Data                                                 Motivo                                            
-------------------------------------------------------------------------------------------------------------------------------
André Lisboa	  05/01/2017  Ajustar os saldos para considerar somente 3 casas decimais - Chamado 18252				       
Lucas Borges F.	  22/02/2017  Incluída regra para realizar validações apenas se produto movimentar Seg UM - Chamado 18959	   
====================================================================================================================================================================================================
Analista  - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
====================================================================================================================================================================================================
Andre     - Alex Walaluer - 17/01/25 - 20/01/25 - 49616   - Ajuste para pegar as decimais do campo D7_SALDO
====================================================================================================================================================================================================
*/

#Include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: MT175FOK()
Autor-------------: Andre Lisboa
Data da Criacao---: 05/12/2016  
Descrição---------: Liberacao / Rejeicao do Material no CQ por linha.
Parametros--------: Nenhum
Retorno-----------: .T.
===============================================================================================================================
*/
User Function MT175FOK() as Logical

 Local _lRet    := .T. As Logical
 Local _nSaldo  := Acols[N][aScan(aHeader, {|x| AllTrim(x[2]) == "D7_SALDO"  })] As Numeric
 Local _nSaldo2 := Acols[N][aScan(aHeader, {|x| AllTrim(x[2]) == "D7_SALDO2" })] As Numeric
 Local _nQtsegum:= Acols[N][aScan(aHeader, {|x| AllTrim(x[2]) == "D7_QTSEGUM"})] As Numeric
 Local _cEstorn := Acols[N][aScan(aHeader, {|x| AllTrim(x[2]) == "D7_ESTORNO"})] As Character
 Local _cTipo   := Acols[N][aScan(aHeader, {|x| AllTrim(x[2]) == "D7_TIPO"   })] As Character
 Local _cMotRej := Acols[N][aScan(aHeader, {|x| AllTrim(x[2]) == "D7_MOTREJE"})] As Character
 Local _nNumseq := Acols[N][aScan(aHeader, {|x| AllTrim(x[2]) == "D7_NUMSEQ" })] As Numeric
 Local _nDec    := GetSX3Cache("D7_SALDO","X3_DECIMAL") As Numeric
 
 If !Empty(SB1->B1_SEGUM)
     If round(_nSaldo2,_nDec) > 0 .and. _nQtsegum = 0 .and. Empty(_cEstorn) .and. _cTipo <> 0
         _lRet := .F.                                                                                       	
         xmaghelpfis("Atenção!", "Não permitido! A quantidade informada na 2a.UM é zero.",;
                                "Favor informar a quantidade da 2a.UM.")
     Endif
     
     If round(_nsaldo,_nDec) = 0 .and. round(_nSaldo2,_nDec) <> 0
         _lRet := .F.                                                                                       	
         xmaghelpfis("Atenção!", "Não permitido! O saldo da quantidade da 2a.UM não zerou.",;
                                "Favor informar a quantidade da 2a.UM.")
     
     ElseIf round(_nSaldo,_nDec) <> 0 .and. round(_nSaldo2,_nDec) = 0
         _lRet := .F.                                                                                       	
         xmaghelpfis("Atenção!", "Não permitido! O saldo da quantidade da 2a.UM zerou, porém ainda existe saldo da 1a.UM.",;
                                "Favor verificar os lançamentos (Liberações e rejeições).")
     Endif
 EndIf
 
 If _cTipo == 2 .and. Empty(_cMotRej) .and. Empty(_nNumseq)
     _lRet := .F. 
     xmaghelpfis("Atenção!", "Não permitido! Quando o produto for REJEITADO é obrigatório o preenchimento do motivo da rejeição",;
                                "Favor verificar o conteúdo do campo 'Motivo da Rejeição'.")	
 Endif

Return _lRet
