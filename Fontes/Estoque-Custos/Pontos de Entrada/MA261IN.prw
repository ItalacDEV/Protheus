/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 28/06/2017 | Gravação do campo D3_I_TPTRS - Chamado 20622
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 01/09/2017 | Realização de correções na inicialização do array aCols para campos customizados. Chamado 21268.  
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich  | 14/11/2017 | Correção do posicionamento do SD3 - Chamado 22462        
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 19/06/2023 | Criação de campo/ajuste fonte p/exibir descrição do campo Tipo de Movimentação.Chamado 43825 
-------------------------------------------------------------------------------------------------------------------------------  
André Lisboa  | 12/03/2024 | Chamado 46558 - Alteração na exibição campos motivo transf/descr transf/ incluido campo setor.
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 16/05/2024 | Chamado 46558 - Desenvolvimento de Melhorias na rotina de transferência de produtos.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: MA261IN
Autor-------------: Talita Teixeira
Data da Criacao---: 06/06/2013 
===============================================================================================================================
Descrição---------: Ponto de entrada responsavel em atribuir valores ao aCols para campos customizados. Está dentor de um 
                    While sobre os resgistros da tabela SD3.	
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
User Function MA261IN( )
Local _cPosCampo 	:= aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='D3_I_OBS'})
Local _ntptrs   // 	:= aScan(aHeader, {|x| Alltrim(Upper(x[2]))=="D3_I_TPTRS"})
Local _nPosNumSeq	:= aScan(aHeader, {|x| Alltrim(Upper(x[2]))=="D3_NUMSEQ"})
Local _aareasd3 	:= SD3->(GetArea())
Local _nDsctptrs  // := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_DSCTM"})
Local _nSetor		:= aScan(aHeader, {|x| Alltrim(Upper(x[2]))=="D3_I_SETOR"})
Local _nDesti		:= aScan(aHeader, {|x| Alltrim(Upper(x[2]))=="D3_I_DESTI"})
Local _cDadoCBox 
Local _nMotTrRef  := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_MOTTR"})
Local _nDscMTrRf  := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_DSCMT"})
Local _cFilVld34  := U_ITGETMV( 'IT_FILVLD34','')

If ! xFilial("SD3") $ _cFilVld34 
   _ntptrs     := aScan(aHeader, {|x| Alltrim(Upper(x[2]))=="D3_I_TPTRS"}) // Este campo não deve ser considerado quando as validações do Armazém 34 (Descarte) estiver habilitada.
   _nDsctptrs  := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_DSCTM"})
EndIf 

If !Inclui		

	SD3->(dbSeek( _cSeek := xFilial('SD3')+cDocumento,.F.))

	Do While !SD3->(Eof()) .And. _cSeek == SD3->D3_FILIAL+SD3->D3_DOC
	
	    If SD3->D3_NUMSEQ == aCols[Len(aCols),_nPosNumSeq] .AND. SD3->D3_CF == 'RE4' 
	    
	    	aCols[Len(aCols),_cPosCampo]:= SD3->D3_I_OBS

			If ! xFilial("SD3") $ _cFilVld34 
	    	   aCols[Len(aCols),_ntptrs]   := SD3->D3_I_TPTRS
			EndIf 

            If xFilial("SD3") $ _cFilVld34 
			   aCols[Len(aCols),_nSetor]   := SD3->D3_I_SETOR
			   aCols[Len(aCols),_nDesti]   := SD3->D3_I_DESTI
               //-------------
               aCols[Len(aCols),_nMotTrRef] := SD3->D3_I_MOTTR
			   aCols[Len(aCols),_nDscMTrRf] := SD3->D3_I_DSCMT
			EndIf 

            //-------------
            If ! xFilial("SD3") $ _cFilVld34 
               If ! Empty(SD3->D3_I_TPTRS)
			      _cDadoCBox := X3CBoxDesc("D3_I_TPTRS",SD3->D3_I_TPTRS)
                  aCols[Len(aCols),_nDsctptrs] := POSICIONE("SF5",1,xFilial("SF5")+U_ITKEY(_cDadoCBox,"F5_CODIGO"),"F5_TEXTO")
			   Else 
                  aCols[Len(aCols),_nDsctptrs] := ""
			   EndIf 
               
			   If ! Empty(SD3->D3_I_TPTRS)
			      //_cDadoCBox := X3CBoxDesc("D3_I_TPTRS",SD3->D3_I_TPTRS)
                 aCols[Len(aCols),_nDsctptrs] := POSICIONE("CYO",1,xFilial("CYO")+aCols[Len(aCols),_ntptrs],"CYO_DSRF")
			   Else 
                  aCols[Len(aCols),_nDsctptrs] := ""
			   EndIf 
            EndIf

	    	Exit
	    	
	    Endif
		
		SD3->(Dbskip())
		
	Enddo
   
EndIf

SD3->(Restarea(_aareasd3))

Return Nil
