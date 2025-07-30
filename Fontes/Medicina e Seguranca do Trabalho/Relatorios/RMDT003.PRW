/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer |13/11/2019| Chamado 31179. Novo parametro MV_PAR18 - "Situacoes a Imp. ?" . 
Julio Paz     |05/09/2023| Chamado 44811. Inclusão das colunas UF e Cidade do Atestado (TNY_I_UF/TNY_I_MUNI). 
Lucas Borges  |09/10/2024| Chamado 48465. Retirada manipulação do SX1
===============================================================================================================================

=========================================================================================================================================================
Analista         - Programador       - Inicio     - Envio      - Chamado - Motivo da Alteração
---------------------------------------------------------------------------------------------------------------------------------------------------------
Bruno dos Reis   -  Igor Melgaço     - 20/01/2025 - 30/01/2025 - 48829   - Inclusão de campos no relatório.
=========================================================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: RMDT003
Autor-------------: Josué Danich Prestes
Data da Criacao---: 20/07/2017
Descrição---------: Relatório de Gestão dos Atestados - Chamado 19050
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RMDT003()    

Private nXATEST := 0 //Variavel de controle utilizada na impressão tReport

If !Pergunte("RMDT003",.T.)   
	Return Nil  
Endif  

Private oFont12	 := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)		      
Private oFont14B  := TFont():New("Arial",10,10,,.F.,,,,.F.,.F.)
Private oFont16B  := TFont():New("Arial",12,12,,.F.,,,,.F.,.F.)
Private oFont12T  := TFont():New("Times New Roman",10,10,,.F.,,,,.T.,.F.)
Private oFont12I  := TFont():New("Times New Roman",10,10,,.T.,,.t.,,.T.,.F.)

//-- Interface de impressao
oReport := RMDT003I()
oReport:lDisableOrientation := .T.//trava o modo de impressão como paisagem
oReport:SetLandscape() //Modo paisagem
oReport:HideParamPage() // Retira pagina de Parâmetros da impressão.
oReport:nLeftMargin := 3 // Margem do lado esquerdo
oReport:PrintDialog()   

Return                     
                     
/*
===============================================================================================================================
Programa----------: RMDT003M
Autor-------------: Josué Danich Prestes
Data da Criacao---: 20/07/2017
Descrição---------: Chamada do  Relatorio  
Parametros--------: oprint - objeto de impressão
                    i - retorno da impressão
                    lin - linha do relatório
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function U_RMDT003M(oPrint,i,lin)

U_RMDT003R(oPrint,@i,@lin,1)
oPrint:Preview()  			

Return

/*
===============================================================================================================================
Programa----------: RMDT003R
Autor-------------: Josué Danich Prestes
Data da Criacao---: 20/07/2017
Descrição---------: Montagem do Relatorio 
Parametros--------: oprint - objeto de impressão
                    i - retorno da impressão
                    lin - linha do relatório
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RMDT003R(oPrint,i,l,g)

LOCAL x,z
LOCAL t := 1
LOCAL cCliente := ""  
Local cSMCOD := If(FindFunction("FWGrpCompany"),FWGrpCompany(),SM0->M0_CODIGO)
Local cSMFIL := If(FindFunction("FWCodFil"),FWCodFil(),ALLTRIM(SM0->M0_CODFIL))
Local nInd := 0
Local nLinhasMemo := 0
Local LinA := 0
Local LinN := 0

//Registro de log de uso
U_ITLOGACS()

If lSigaMdtps
             
	ASORT(aAtestado,,,{|x,y| x[1]+x[2]+x[5] < y[1]+y[2]+y[5] })	
	
	While t <= Len(aAtestado)			
		
		oPrint:StartPage() 	
			
		oPrint:Cmtr2Pix(130,080)//linha,coluna
		oPrint:Cmtr2Pix(500,150)//largura,altura
		oPrint:SayBitmap(130,080,"LGRL"+cSMCOD+cSMFIL+".BMP" ,500,130 )//objeto,constante,linha,coluna,caminho,
	
		oPrint:Say(  130	, 860 	, "PROGRAMA DE CONTROLE MEDICO DE SAUDE OCUPACIONAL" 			, oFont12I ) 
		oPrint:Line( 200	, 840 	, 200 				, 3220     )                                        
		oPrint:Say(  220	, 860 	, "COMUNICACAO  INTERNA  DE  ATESTADOS  POR  FALTA  AO  TRABALHO" 			, oFont12I ) 
		oPrint:Line( 110	, 2560 , 280 				, 2560     ) 
		oPrint:Say(  140	, 2580 , "Unidade:" 			, oFont14B ) //
		oPrint:Say(  140	, 2790 , SM0->M0_NOME 	, oFont14B ) 
		oPrint:Say(  220	, 2580 , "Data:" 			, oFont14B ) //
		oPrint:Say(  220	, 2726 , DtoC( Date() )	, oFont14B )   
			
		oPrint:Line( 280 , 080 , 280 , 3220 ) 
		oPrint:Line( 281 , 080 , 281 , 3220 )
		oPrint:Line( 282 , 080 , 282 , 3220 )        
			
		oPrint:Say( 295 , 150  , "R. G." 			, oFont12T )	
		oPrint:Say( 295 , 350  , "MATRICULA" 		, oFont12T )	   
		oPrint:Say( 295 , 760  , "NOME" 			, oFont12T )	
		oPrint:Say( 295 , 1110 , "SETOR" 			, oFont12T )
		oPrint:Say( 295 , 1600 , "CID" 				, oFont12T )	
		oPrint:Say( 295 , 1700 , "PERIODO DE AFAST.", oFont12T )	
		oPrint:Say( 295 , 2000 , "DIAS PERD." 		, oFont12T )	
		oPrint:Say( 295 , 2230 , "HORAS PERD." 		, oFont12T )	
		oPrint:Say( 295 , 2490 , "OBSERVACOES" 		, oFont12T )	 
			
		oPrint:Line( 350 , 080 , 350 , 3220 ) //horizontal  
			 
		oPrint:Line( 285 , 310  , 2239 , 310  ) //vertical  
		oPrint:Line( 285 , 565  , 2239 , 565  ) //vertical
		oPrint:Line( 285 , 1055 , 2239 , 1055 ) //vertical 
		oPrint:Line( 285 , 1520 , 2239 , 1520 ) //vertical   
		oPrint:Line( 285 , 1990 , 2239 , 1990 ) //vertical    
		oPrint:Line( 285 , 2210 , 2239 , 2250 ) //vertical 
		oPrint:Line( 285 , 2470 , 2239 , 2470 ) //vertical     
		  
		// rodape 
		oPrint:Line( 2239 , 080 , 2239 , 3220 ) //horizontal 
		oPrint:Line( 2240 , 080 , 2240 , 3220 ) //horizontal
		
		oPrint:Say( 2288 , 800 , "____/____/____   " + Replicate("_",26) , oFont16B )
		oPrint:Say( 2288 , 1950 , "____/____/____   " + Replicate("_",35) , oFont16B )
		
		oPrint:Say( 2340 , 1340 , "MEDICO" ,oFont12 ) //
		oPrint:Say( 2340 , 2480 , "RESPONSÁVEL DE SAÚDE" ,oFont12 ) 
		  
		oPrint:Line( 2388 , 080 , 2388 , 3220 ) //horizontal
		oPrint:Line( 2389 , 080 , 2389 , 3220 ) //horizontal  
		oPrint:Line( 2390 , 080 , 2390 , 3220 ) //horizontal 
			
		lin := 420
		cCliente := aAtestado[t,1]+aAtestado[t,2]
			
		For x := g To Len( aAtestado )
		
			LinA:= 0 //Zera varial de linha
			
			If cCliente <> aAtestado[x,1]+aAtestado[x,2]
				exit
			Endif
			
			oPrint:Say( lin-60 , 090  ,Transform( aAtestado[ x , 3 ] , "@R 9.999.999/9" ) , oFont12 ) //RG
			oPrint:Say( Lin-60 , 380  ,Transform( aAtestado[ x , 4 ] , "@R 999999" ) , oFont12 ) //Matrícula
				
			//Quebra nome do Funcionário
			nLinhasMemo := MLCOUNT(Alltrim( aAtestado[ x , 3 ]),20)//Utilização do quebra linha
			For nInd := 1 to nLinhasMemo
				oPrint:Say( Lin-60 , 590 ,MemoLine( aAtestado[ x , 3 ] , 20, nInd ) , oFont12 ) //Nome Funcionário
				If nInd <> nLinhasMemo
					Lin += 40
					LinN += 40  
				EndIf
			Next nInd 
			
			If nLinhasMemo > 1 //Caso a quebra de linhas seja maior que 1
				Lin -= LinN //Retira valor adicionado pela quebra
			Endif
			
			nLinhasMemo := MLCOUNT(Alltrim( aAtestado[ x , 9 ]),20)//Quebra linha
			For nInd := 1 to nLinhasMemo
				oPrint:Say( Lin-60 , 1070 ,MemoLine( aAtestado[ x , 9 ] , 20, nInd ) , oFont12 ) //Centro de Custo
				If nInd <> nLinhasMemo
					lin += 40
					LinA += 40
				EndIf
			Next nInd
			
			If nLinhasMemo > 1 //Caso a quebra de linhas seja maior que 1
				Lin -= LinA //Retira valor adicionado pela quebra
			Endif
			
			oPrint:Say( Lin-60 , 1560 ,DtoC( aAtestado[ x , 6 ] ) + " a " + DtoC( aAtestado[ x , 7 ] ) , oFont12 ) //Data de afastamento
			oPrint:Say( Lin-60 , 2060 ,Transform( aAtestado[ x , 10 ] , "@R 99999" ) , oFont12 ) //Dias Perdidos
			oPrint:Say( Lin-60 , 2280 ,Transform( aAtestado[ x , 11 ] , "99:99" )  , oFont12 ) //Horas Perdidas
			
			nLinhasMemo := MLCOUNT(Alltrim(aAtestado[ x , 8 ]),28)//Quebra linha
			For nInd := 1 to nLinhasMemo
				oPrint:Say( Lin-60 , 2490 , (MemoLine( aAtestado[ x , 8 ] , 30 , nInd )) , oFont12 )//Observação
				If nInd <> nLinhasMemo
					lin += 40
				EndIf
			Next nInd
			
	    	If Lin < (Lin + If( LinA > LinN , LinA , LinN ) ) //Caso a linha posicionada seja menor que a utilizada no centro de custo.
	    		Lin += If( LinA > LinN , LinA , LinN )
	    	Endif
			
			If Lin < 2109
				oPrint:Line( lin , 080 , lin , 3220 ) //horizontal
			EndIf
			
			If Lin > 2109
				I++
				oPrint:EndPage() 
				If U_RMDT003R(oPrint,@i,@lin,x)
					Return .t.
				EndIf
				Lin := 100
			EndIf
			Lin += 70
		Next x
		
		t := x
		
		If Len( aAtestado ) > 25
			yLinhas := Round((( 2119-Lin )/70),0)+2
		Else
			yLinhas := Lin
		EndIf
		
		For z := 1 to yLinhas
			if lin > 2200
				Exit
			EndIf
			oPrint:Line(lin,080,lin,3220) //horizontal
				
			Lin += 70
		Next z
			
		oPrint:EndPage() 		
		lin := 100	
			
	End
	
Else

	oPrint:StartPage() 	
		
	oPrint:Cmtr2Pix(  130 , 080 ) //linha,coluna
	oPrint:Cmtr2Pix(  500 , 150 ) //largura,altura
	oPrint:SayBitmap( 130 , 080 , "LGRL" + cSMCOD + cSMFIL + ".BMP" , 500 , 130 )//objeto,constante,linha,coluna,caminho,
		                                                     
	oPrint:Say(  130	, 860 	, "PROGRAMA DE CONTROLE MEDICO DE SAUDE OCUPACIONAL" 			, oFont12I ) 
	oPrint:Line( 200	, 840 	, 200 				, 3220     )                                        
	oPrint:Say(  220	, 860 	, "COMUNICACAO  INTERNA  DE  ATESTADOS  POR  FALTA  AO  TRABALHO" 			, oFont12I ) 
	oPrint:Line( 110	, 2560 , 280 				, 2560     ) 
	oPrint:Say(  140	, 2580 , "Unidade:" 			, oFont14B ) 
	oPrint:Say(  140	, 2790 , SM0->M0_NOME 	, oFont14B ) 
	oPrint:Say(  220	, 2580 , "Data:" 			, oFont14B ) 
	oPrint:Say(  220	, 2726 , DtoC( Date() )	, oFont14B )   
		
	oPrint:Line( 280 , 080 , 280 , 3220 ) 
	oPrint:Line( 281 , 080 , 281 , 3220 )
	oPrint:Line( 282 , 080 , 282 , 3220 )        
		
	oPrint:Say( 295 , 150  , "R. G."             , oFont12T )	 
	oPrint:Say( 295 , 330  , "MATRICULA"         , oFont12T )	   
	oPrint:Say( 295 , 760  , "NOME"              , oFont12T )	
	oPrint:Say( 295 , 1110 , "SETOR"             , oFont12T )	
	oPrint:Say( 295 , 1600 , "CID" 				, oFont12T )	
	oPrint:Say( 295 , 1700 , "PERIODO DE AFAST.", oFont12T )	
	oPrint:Say( 295 , 2000 , "DIAS PERD."        , oFont12T )	
	oPrint:Say( 295 , 2230 , "HORAS PERD."       , oFont12T )	
	oPrint:Say( 295 , 2490 , "OBSERVACOES"       , oFont12T )	 
		
	oPrint:Line( 350 , 080 , 350 , 3220 ) //horizontal   
		    
	oPrint:Line( 285 , 310  , 2239 , 310  ) //vertical  
	oPrint:Line( 285 , 565  , 2239 , 565  ) //vertical
	oPrint:Line( 285 , 1055 , 2239 , 1055 ) //vertical  
	oPrint:Line( 285 , 1520 , 2239 , 1520 ) //vertical 
	oPrint:Line( 285 , 1990 , 2239 , 1990 ) //vertical    
	oPrint:Line( 285 , 2210 , 2239 , 2210 ) //vertical 
	oPrint:Line( 285 , 2470 , 2239 , 2470 ) //vertical   
	  
	// rodape 
	oPrint:Line( 2239 , 080 , 2239 , 3220 ) //horizontal 
	oPrint:Line( 2240 , 080 , 2240 , 3220 ) //horizontal
	
	oPrint:Say( 2288 , 800 , "____/____/____   " + Replicate("_",26) , oFont16B )
	oPrint:Say( 2288 , 1950 , "____/____/____   " + Replicate("_",35) , oFont16B )
	
	oPrint:Say( 2340 , 1340 , "MEDICO" ,oFont12) 
	oPrint:Say( 2340 , 2480 , "RESPONSÁVEL DE SAÚDE" ,oFont12 ) 
	  
	oPrint:Line( 2388 , 080 , 2388 , 3220 ) //horizontal
	oPrint:Line( 2389 , 080 , 2389 , 3220 ) //horizontal   
	oPrint:Line( 2390 , 080 , 2390 , 3220 ) //horizontal 
	   
	lin := 420    
	For x := g To Len( aAtestado ) 
		
		LinA:= 0 //Zera varial de linha
		LinN:= 0 //Zera varial de linha
		
		oPrint:Say( lin-60 , 090  ,Transform( aAtestado[ x , 1 ] , "@R 9.999.999/9" ) , oFont12 ) //RG	   
		oPrint:Say( Lin-60 , 380  ,Transform( aAtestado[ x , 2 ] , "@R 999999" ) , oFont12 ) //Matrícula
		
		//Quebra nome do Funcionário
		nLinhasMemo := MLCOUNT(Alltrim( aAtestado[ x , 3 ]),20)//Utilização do quebra linha
		For nInd := 1 to nLinhasMemo
			oPrint:Say( Lin-60 , 590 ,MemoLine( aAtestado[ x , 3 ] , 20, nInd ) , oFont12 ) //Nome Funcionário
			If nInd <> nLinhasMemo
				Lin += 40
				LinN += 40  
			EndIf
		Next nInd 
		
		If nLinhasMemo > 1 //Caso a quebra de linhas seja maior que 1
			Lin -= LinN //Retira valor adicionado pela quebra
		Endif
		
		//Quebra Centro de Custo
		nLinhasMemo := MLCOUNT(Alltrim( aAtestado[ x , 7 ]),20)//Utilização do quebra linha
		For nInd := 1 to nLinhasMemo
			oPrint:Say( Lin-60 , 1070 ,MemoLine( aAtestado[ x , 7 ] , 20, nInd ) , oFont12 ) //Centro de Custo
			If nInd <> nLinhasMemo
				Lin += 40
				LinA += 40  
			EndIf
		Next nInd   
		
		If nLinhasMemo > 1 //Caso a quebra de linhas seja maior que 1
			Lin -= LinA //Retira valor adicionado pela quebra
		Endif
		
		oPrint:Say( Lin-60 , 1560 ,DtoC( aAtestado[ x , 4 ] ) + " a " + DtoC( aAtestado[ x , 5 ] ) , oFont12 ) //Data de afastamento
		oPrint:Say( Lin-60 , 2060 ,Transform( aAtestado[ x , 8 ] , "@R 99999" ) , oFont12 ) //Dias Perdidos
		oPrint:Say( Lin-60 , 2280 ,Transform( aAtestado[ x , 9 ] , "99:99" )  , oFont12 ) //Horas Perdidas
		
		nLinhasMemo := MLCOUNT(Alltrim(aAtestado[ x , 6 ]),28)//Quebra linha
		For nInd := 1 to nLinhasMemo
			oPrint:Say( Lin-60 , 2490 , (MemoLine( aAtestado[ x , 6 ] , 30 , nInd )) , oFont12 )//Observação
			If nInd <> nLinhasMemo
				lin += 40
			EndIf
		Next nInd
    	  
    	If Lin < (Lin + If( LinA > LinN , LinA , LinN ) ) //Caso a linha posicionada seja menor que a utilizada no centro de custo.
    		Lin += If( LinA > LinN , LinA , LinN )
    	Endif
		
		If Lin < 2109 
			oPrint:Line( lin , 080 , lin , 3220 ) //horizontal
		EndIf
		
		If Lin > 2109   
			I++  
			oPrint:EndPage()    
			If U_RMDT003R(oPrint,@i,@lin,x) 
				Return .t.
			EndIf	
			Lin := 100
		EndIf	  
		Lin += 70		
	Next x	
	
	If Len( aAtestado ) > 25
		yLinhas := Round((( 2119-Lin )/70),0)+2
	Else
		yLinhas := Lin	
	EndIf
	
	For z := 1 to yLinhas
		if lin > 2200
			Exit
		EndIf	
		oPrint:Line(lin,080,lin,3220) //horizontal
		
		Lin += 70
	Next z
		
	oPrint:EndPage() 		
	lin := 100

Endif

Return .t.
 
 /*
===============================================================================================================================
Programa----------: RMDT003D
Autor-------------: Josué Danich Prestes
Data da Criacao---: 20/07/2017
Descrição---------: Busca de Dados para Impressao. 
Parametros--------: oprint - objeto de impressão
                    i - retorno da impressão
                    lin - linha do relatório
Retorno-----------: aatestado - array com dados para impressão
===============================================================================================================================
*/
User Function RMDT003D(oReport)
                       
Local aAtestado := {}
Local lAfast1 := .F. //Veriavel que determina a impressão do afastamento 1
Local lAfast2 := .F. //Veriavel que determina a impressão do afastamento 2
Local lAfast3 := .F. //Veriavel que determina a impressão do afastamento 3
Local cHoraIni := "00:00" 
Local cHoraFim := "00:00"
Local aHoras := {}

	DbSelectArea("TNY")
	IF(oReport<>NIL,oReport:SetMeter(LASTREC()),)
	
	TNY->(DbSetOrder(1))
	TNY->(DbSeek(xFilial("TNY")+mv_par01,.t.))
	
	Do While !Eof() .and. xFilial("TNY") == TNY->TNY_FILIAL .and. TNY->TNY_NUMFIC <= mv_par02	

        IF(oReport<>NIL,oReport:IncMeter(),)
        IF(oReport<>NIL,oReport:SetMsgPrint("Lendo Ficha: "+TNY->TNY_NUMFIC),)
		
		If TNY->TNY_CID < mv_par05 .or. TNY->TNY_CID > mv_par06
			DbSelectArea("TNY")		
			DbSkip()
			Loop
		EndIf
		
		//Validação de data de consulta
		If !empty(MV_PAR14) .AND. !empty(MV_PAR15)
			If (TNY->TNY_DTCONS < mv_par14 .OR. TNY->TNY_DTCONS > MV_PAR15)
				DbSelectArea("TNY")		
				DbSkip()    
				Loop
			EndIf       
		Endif
		
		If Mv_par11 == 1
			If (TNY->TNY_DTINIC < mv_par03 .AND. TNY->TNY_DTFIM < MV_PAR03) .or. (TNY->TNY_DTINIC > mv_par04 .AND. TNY->TNY_DTFIM > MV_PAR04)
				DbSelectArea("TNY")		
				DbSkip()    
				Loop
			EndIf       
		Else   

			If (TNY->TNY_DTSAID >= Mv_par03 .And. TNY->TNY_DTSAID <= Mv_par04) .Or. (TNY->TNY_DTALTA >= Mv_par03 .And. TNY->TNY_DTALTA <= mv_par04)//Verifica se  data do 1º afastamento esta dentro dos parametros
				lAfast1:=.T.
			Endif
			If (TNY->TNY_DTSAI2 >= Mv_par03 .And. TNY->TNY_DTSAI2 <= Mv_par04) .Or. (TNY->TNY_DTALT2 >= Mv_par03 .And. TNY->TNY_DTALT2 <= mv_par04)//Verifica se  data do 2º afastamento esta dentro dos parametros
				lAfast2:=.T.
			Endif
			If (TNY->TNY_DTSAI3 >= Mv_par03 .And. TNY->TNY_DTSAI3 <= Mv_par04) .Or. (TNY->TNY_DTALT3 >= Mv_par03 .And. TNY->TNY_DTALT3 <= mv_par04)//Verifica se  data do 3º afastamento esta dentro dos parametros
				lAfast3:=.T.
			Endif 
			If !lAfast1 .And. !lAfast2 .And. !lAfast3//Caso as 3 datas estiverem fora dos parametros pula registro
				DbSelectArea("TNY")		
				DbSkip()       
				Loop
			Endif
		Endif   
		
		Dbselectarea("ZGE")
		ZGE->(DbSetOrder(1))
		DbSelectArea("TM0")  
		TM0->(DbSetOrder(1))
		If TM0->(DbSeek(xFilial("TM0")+TNY->TNY_NUMFIC))
			DbSelectArea("SRA")
			SRA->(DbSetOrder(1))
			If SRA->(DbSeek(xFilial("SRA")+TM0->TM0_MAT))

			   IF MV_PAR17 = 1 .AND. dDataBase >= SRA->RA_VCTEXP2	
				  TNY->(DbSkip())
				  Loop
			   ENDIF  

			   IF !EMPTY(MV_PAR18) .AND. !SRA->RA_SITFOLH $ MV_PAR18
				  TNY->(DbSkip())
				  Loop
			   ENDIF  			   

				If ( SRA->RA_CC >= MV_PAR07 .And. SRA->RA_CC <= MV_PAR08 );  //Centro de custo
				 		.And. ( SRA->RA_CODFUNC >= MV_PAR09 .And. SRA->RA_CODFUNC <= MV_PAR10 ); //Função
				 		.And. ( SRA->RA_I_SETOR >= MV_PAR12 .AND. SRA->RA_I_SETOR <= MV_PAR13 ) //Setor

						If mv_par11 == 1//Verifica se considerará a data do Atestado ou do Afastamento
							
							//Força data e hora inicial no ínicio do relatório mesmo que atestado comece no período anterior
							If TNY->TNY_DTINIC < MV_PAR03
								_DDTINIC := MV_PAR03
								cHoraIni:= "00:00"
							Else
								_DDTINIC := TNY->TNY_DTINIC
								cHoraIni:= TNY->TNY_HRINIC
							Endif
							
							//Força data e hora final no fim do relatório mesmo que atestado comece no período anterior
							If TNY->TNY_DTFIM > MV_PAR04
								_DDFIM := MV_PAR04
								cHoraFim:= "23:59"
							Else
								_DDFIM := TNY->TNY_DTFIM
								cHoraFim:= If( Empty( TNY->TNY_HRFIM ) , "00:00" , TNY->TNY_HRFIM )
							Endif
	
							aHoras:= RMDT003H( _DDTINIC , _DDFIM , cHoraIni , cHoraFim )
							Aadd( aAtestado,{SRA->RA_RG,;      																					//01
							                 SRA->RA_MAT,;     																					//02
							                 SRA->RA_NOME,;    																					//03
							                 _DDTINIC,;        																					//04
							                 _DDFIM,;          																					//05
							                 TNY->TNY_OBSERV,; 																					//06
							                 NGSEEK("ZAK",SRA->RA_I_SETOR,1,"ZAK_DESCRI"),;														//07
							                 aHoras[3],;																						//08
							                 If( aHoras[ 2 ] == "  :  "  , "00:00" , aHoras[ 2 ] ),;											//09
							                 IIF(TNY->TNY_I_GEST == "1","S","N"),;                  											//10
							                 TNY->TNY_I_ETIO + ' - ' + POSICIONE("ZGE",1,xfilial("ZGE")+TNY->TNY_I_ETIO,"ZGE_DESC"),;			//11
							                 X3CBoxDesc("TNY_I_TURN",TNY->TNY_I_TURN),;															//12
							                 X3CBoxDesc("TNY_I_TPDC",TNY->TNY_I_TPDC),;															//13
							                 DTOC(TNY->TNY_DTCONS),;   																			//14
							                 DTOC(SRA->RA_ADMISSA),;                                                                            //15
											 TNY->TNY_I_UF,;                                                                                    //16 
											 TNY->TNY_I_MUNI,;																					//17
											 TNY->TNY_GRPCID,;																					//18
											 TNY->TNY_CID,;																						//19
											 TNY->TNY_EMITEN,;																					//20	
											 Posicione("TNP",1,xfilial("TNP")+TNY->TNY_EMITEN,"TNP_NOME");						 				//21
											 } )		                                                                            
						Else     
							If lAfast1 
						
						  		//Força data e hora inicial no ínicio do relatório mesmo que afatamento comece no período anterior
							  	If TNY->TNY_DTSAID < MV_PAR03
									_DDTINIC := MV_PAR03
								Else
									_DDTINIC := TNY->TNY_DTSAID
								Endif
							
								//Força data e hora final no fim do relatório mesmo que afastamento comece no período anterior
								If TNY->TNY_DTALTA > MV_PAR04
									_DDFIM := MV_PAR04
								Else
									_DDFIM := TNY->TNY_DTALTA
								Endif
							  
								aHoras:= RMDT003H( _DDTINIC , _DDFIM , cHoraIni , cHoraFim )  
								
								Aadd( aAtestado,{	SRA->RA_RG,;																				//01
													SRA->RA_MAT,;																				//02
													SRA->RA_NOME,;																				//03
													_DDTINIC,;																					//04
													_DDFIM,;																					//05
													TNY->TNY_OBSERV,;																			//06
													NGSEEK("ZAK",SRA->RA_I_SETOR,1,"ZAK_DESCRI"),;												//07
													aHoras[3]+1,;																				//08
													If( aHoras[ 2 ] == "  :  " , "00:00" , aHoras[ 2 ] ),;										//09
													IIF(TNY->TNY_I_GEST == "1","S","N"),;														//10
													TNY->TNY_I_ETIO + ' - ' + POSICIONE("ZGE",1,xfilial("XGE")+TNY->TNY_I_ETIO,"ZGE_DESC"),;	//11
													X3CBoxDesc("TNY_I_TURN",TNY->TNY_I_TURN),;													//12
													X3CBoxDesc("TNY_I_TPDC",TNY->TNY_I_TPDC),;													//13
							                        DTOC(TNY->TNY_DTCONS),;   																	//14
							                        DTOC(SRA->RA_ADMISSA),;                                                                     //15
													TNY->TNY_I_UF,;                                                                             //16 
													TNY->TNY_I_MUNI,;
													TNY->TNY_GRPCID,;
													TNY->TNY_CID,;
													TNY->TNY_EMITEN,;																					//20	
											 		Posicione("TNP",1,xfilial("TNP")+TNY->TNY_EMITEN,"TNP_NOME");						 				//21
													} )		                                                                    

							Endif   
							
							If (!Empty(TNY->TNY_DTSAI2) .Or. !Empty(TNY->TNY_DTALT2)) .And. lAfast2//Verifica se existe um segundo afastamento  
							
						  		//Força data e hora inicial no ínicio do relatório mesmo que afatamento comece no período anterior
							  	If TNY->TNY_DTSAI2 < MV_PAR03
									_DDTINIC := MV_PAR03
								Else
									_DDTINIC := TNY->TNY_DTSAI2
								Endif
							
								//Força data e hora final no fim do relatório mesmo que afastamento comece no período anterior
								If TNY->TNY_DTALT2 > MV_PAR04
									_DDFIM := MV_PAR04 
								Else
									_DDFIM := TNY->TNY_DTALT2
								Endif
							  
								aHoras:= RMDT003H( _DDTINIC , _DDFIM , cHoraIni , cHoraFim ) 
								Aadd( aAtestado,{	SRA->RA_RG,;																													//01
													SRA->RA_MAT,;																													//02
													SRA->RA_NOME,;																													//03
													_DDTINIC,;																														//04
													_DDFIM,;																														//05
													TNY->TNY_OBSERV,;																												//06
													NGSEEK("ZAK",SRA->RA_I_SETOR,1,"ZAK_DESCRI"),;																					//07
													aHoras[3]+1,;																													//08
													If( aHoras[ 2 ] == "  :  " , "00:00" , aHoras[ 2 ] ),;																			//09
													IIF(TNY->TNY_I_GEST == "1","S","N"),;																							//10
													TNY->TNY_I_ETIO + ' - ' + POSICIONE("ZGE",1,xfilial("ZGE")+TNY->TNY_I_ETIO,"ZGE_DESC"),;										//11
													X3CBoxDesc("TNY_I_TURN",TNY->TNY_I_TURN),;																						//12
													X3CBoxDesc("TNY_I_TPDC",TNY->TNY_I_TPDC),;																						//13
							                        DTOC(TNY->TNY_DTCONS),;   																	                                    //14
							                        DTOC(SRA->RA_ADMISSA),;                                                                                                         //15
													TNY->TNY_I_UF,;                                                                                                                 //16 
													TNY->TNY_I_MUNI,;
													TNY->TNY_GRPCID,;
													TNY->TNY_CID,;
													TNY->TNY_EMITEN,;																					//20	
											 		Posicione("TNP",1,xfilial("TNP")+TNY->TNY_EMITEN,"TNP_NOME");						 				//21
													} )				                                                                                                        

							Endif
							If (!Empty(TNY->TNY_DTSAI3) .Or. !Empty(TNY->TNY_DTALT3)) .And. lAfast3//Verifica se existe um terceiro afastamento  
							
						  		//Força data e hora inicial no ínicio do relatório mesmo que afatamento comece no período anterior
							  	If TNY->TNY_DTSAI3 < MV_PAR03
									_DDTINIC := MV_PAR03
								Else
									_DDTINIC := TNY->TNY_DTSAI3
								Endif
							
								//Força data e hora final no fim do relatório mesmo que afastamento comece no período anterior
								If TNY->TNY_DTALT3 > MV_PAR04
									_DDFIM := MV_PAR04 
								Else
									_DDFIM := TNY->TNY_DTALT3
								Endif
	
								aHoras:= RMDT003H( _DDTINIC , _DDFIM , cHoraIni , cHoraFim )   
							
								Aadd( aAtestado,{	SRA->RA_RG,;																				//01
													SRA->RA_MAT,;																				//02
													SRA->RA_NOME,;																				//03
													_DDTINIC,;																					//04
													_DDFIM,;																					//05
													TNY->TNY_OBSERV,;																			//06
													NGSEEK("ZAK",SRA->RA_I_SETOR,1,"ZAK_DESCRI"),;												//07
													aHoras[3]+1,;																				//08
													If( aHoras[ 2 ] == "  :  " , "00:00" , aHoras[ 2 ] ),;										//09
													IIF(TNY->TNY_I_GEST == "1","S","N"),;														//10
													TNY->TNY_I_ETIO + ' - ' + POSICIONE("ZGE",1,xfilial("ZGE")+TNY->TNY_I_ETIO,"ZGE_DESC"),;	//11
													X3CBoxDesc("TNY_I_TURN",TNY->TNY_I_TURN),;													//12
													X3CBoxDesc("TNY_I_TPDC",TNY->TNY_I_TPDC),;													//13
							                        DTOC(TNY->TNY_DTCONS),;   																	//14
							                        DTOC(SRA->RA_ADMISSA),;		                                                                //15
													TNY->TNY_I_UF,;                                                                             //16 
													TNY->TNY_I_MUNI,;
													TNY->TNY_GRPCID,;
													TNY->TNY_CID,;
													TNY->TNY_EMITEN,;																					//20	
											 		Posicione("TNP",1,xfilial("TNP")+TNY->TNY_EMITEN,"TNP_NOME");						 				//21
													} )		                                                                 
							
							Endif
						Endif  
				EndIf	      
			EndIf
		EndIf		
		
		//Devolve valor inicial as variáveis. 
		lAfast1 := .F.
		lAfast2 := .F.
		lAfast3 := .F.     

		TNY->(DbSkip())
	EndDo	


Return aAtestado

 /*
===============================================================================================================================
Programa----------: RMDT003I
Autor-------------: Josué Danich Prestes
Data da Criacao---: 20/07/2017
Descrição---------: Busca de Dados para Impressao. 
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RMDT003I()

Local oReport
Local oSection1
Local oSection2
Local oSection3
Local oSection4
Local oSection5

Local aAtestado := {}

oReport := TReport():New("RMDT003",,"RMDT003",{|oReport| RMDT003Y(oReport,oSection1,oSection2,oSection3,oSection4,oSection5,aAtestado)})  

//Seção para impressão do título
oSection1 := TRSection():New(oReport,"Ocorrencias na Geracao da Programacao de Exames" ,{" "} )
oSection1:nLeftMargin := 3 
	
//Seção para impresão do relatório.
oSection2 := TRSection():New( oReport , "Ocorrencias na Geracao da Programacao de Exames" ,{" "} )//"Ocorrencias na Geracao da Programacao de Exames"

TRCell():New( oSection2 ,"ATESTADO_MAT"			, " "	, "MATRÍCULA"			,"@R 999999"		,10		,.T.	,{|| Transform( aAtestado[ nXATEST , 2 ] , "@R 999999" ) 								}) 
TRCell():New( oSection2 ,"ATESTADO_NOME"		, " " 	, "NOME"				,"@!"				,40		,.T.	,{|| SubStr( aAtestado[ nXATEST , 3 ] , 1 , 30 )										}) 
TRCell():New( oSection2 ,"DATA_ADMISSAO" 	    , " " 	, "DT ADMISSAO"         ,"@!"				,15		,.T.	,{|| aAtestado[nXATEST,15] 																})	
TRCell():New( oSection2 ,"ATESTADO_SETOR"		, " " 	, "SETOR"				,"@!"				,20		,.T.	,{|| SubStr( aAtestado[ nXATEST , 7 ] , 1 , 40 ) 										}) 

TRCell():New( oSection2 ,"MUNICIP_ATESTADO"		, " " 	, "MUNICÍPIO"	        ,"@!"				,20		,.T.	,{|| aAtestado[ nXATEST , 17 ]                   										})  
TRCell():New( oSection2 ,"UF_ATESTADO"		    , " " 	, "UF"			        ,"@!"				,2		,.T.	,{|| aAtestado[ nXATEST , 16 ] 	                                                     	})  

If MV_PAR16 == 1
	TRCell():New( oSection2 ,"ATESTADO_TURNO"   	, " " 	, "TURNO"			    ,"@!"				,15		,.T.	,{|| aAtestado[nXATEST,12] 															    }) 
	TRCell():New( oSection2 ,"ATESTADO_TIPODOC" 	, " " 	, "TP DOCUMENTO"        ,"@!"				,15		,.T.	,{|| aAtestado[nXATEST,13] 																})
Endif

TRCell():New( oSection2 ,"ATESTADO_CONSULTA" 	, " " 	, "DT CONSULTA"         ,"@!"				,15		,.T.	,{|| aAtestado[nXATEST,14] 																})	

TRCell():New( oSection2 ,"ATESTADO_DTAFAS"		, " " 	, "PERIODO DE AFAST."	,"@!"				,30		,.T.	,{|| DtoC( aAtestado[ nXATEST , 4 ] ) + " ATÉ " + DtoC( aAtestado[ nXATEST , 5 ] )		}) 
TRCell():New( oSection2 ,"ATESTADO_DTPER"		, " " 	, "DIAS PERD."			,"@R 9999"			,08		,.T.	,{|| Transform( aAtestado[ nXATEST , 8 ] , "@R 9999" )	 								}) 
TRCell():New( oSection2 ,"ATESTADO_HRPER"		, " " 	, "HORAS PERD."			,"99:99"			,11		,.T.	,{|| IIF(aAtestado[ nXATEST , 8 ]==0,Transform( aAtestado[ nXATEST , 9 ] , "99:99")," ") }) 


If MV_PAR16 == 1
	TRCell():New( oSection2 ,"ATESTADO_CID1"		, " " 	, "ETIOLOGIA"			,"@!"			    ,40		,.T.	,{|| aAtestado[ nXATEST , 11 ]  				 					}) 
Endif

TRCell():New( oSection2 ,"ATESTADO_GRUPOCID"		, " " 	, "GRUPO CID"				,"@!"				,10		,.T.	,{|| SubStr( aAtestado[ nXATEST , 18 ] , 1 , 20 ) 										}) 
TRCell():New( oSection2 ,"ATESTADO_CIDPRINC"		, " " 	, "CID PRINCIPAL"			,"@!"				,10		,.T.	,{|| SubStr( aAtestado[ nXATEST , 19 ] , 1 , 20 ) 										}) 
TRCell():New( oSection2 ,"ATESTADO_CODEMIT"			, " " 	, "COD EMIT ATEST/AUT"		,"@!"				,10		,.T.	,{|| SubStr( aAtestado[ nXATEST , 20 ] , 1 , 12 ) 										}) 
TRCell():New( oSection2 ,"ATESTADO_NOME"			, " " 	, "NOME"					,"@!"				,10		,.T.	,{|| SubStr( aAtestado[ nXATEST , 21 ] , 1 , 20 ) 										}) 

If  MV_PAR16 == 1 //Verifica se existe campo observação
	oSection3 := TRSection():New( oSection2 , "Ocorrencias na Geracao da Programacao de Exames" ,{" "} )
	TRCell():New( oSection3 ,"ATESTADO_OBSERV", " " , "OBSERVACOES"	,"@!",LEN(TNY->TNY_OBSERV),.T.,{|| aAtestado[ nXATEST , 6 ] }) 
	oSection3:nLeftMargin := 3 //Determina uma margem na lateral esquerda.
EndIf

	
oSection2:nLeftMargin := 1 //Determina uma margem na lateral esquerda.
	 
Pergunte( oReport:uParam , .F. )//Faz a chamada das perguntas.  
      
Return oReport  

 /*
===============================================================================================================================
Programa----------: RMDT003Y
Autor-------------: Josué Danich Prestes
Data da Criacao---: 20/07/2017
Descrição---------: Busca de Dados para Impressao. 
Parametros--------: oReport  - objeto de impressão
					oSection1  - objeto da seção de cabeçalho
					oSection2  - objeto da seção de dados
					oSection3 - objeto da seção de observacao
					oSection4  - objeto da seção de grupo de cid
					oSection5 - objeto da seção de cid
					aAtestado - array com dados de atestados
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function RMDT003Y( oReport,oSection1,oSection2,oSection3,oSection4,oSection5,aAtestado )	

Local nX := 0
Local nY := 0
Local _ntotpag := 0
Local _ntotpagt := 0
Local _ndias := 0
Local _nhoras := 0
Local _nminutos := 0
Local _ndiast := 0
Local _nhorast := 0
Local _nminutost := 0


DbSelectArea( "TNY" )  
//----------------------------------- 
//Preench8 array com valores.   
//-----------------------------------
aAtestado := U_RMDT003D(oReport)

//Organiza por ordem de setores + matricula + data

aAtestado := ASORT(aAtestado, , , { | x,y | x[7]+x[3]+x[2]+dtos(x[4]) > y[7]+y[3]+y[2]+dtos(y[4]) } )
   
If Len(aAtestado) >= 1//Verifica se existe algum atestado.
	
	oSection1:Init()  //Inicia section
	oReport:SkipLine(8)
	oReport:PrtCenter("PROGRAMA DE CONTROLE MEDICO DE SAUDE OCUPACIONAL")
	oReport:SkipLine()
	oReport:PrtCenter("COMUNICACAO  INTERNA  DE  ATESTADOS  POR  FALTA  AO  TRABALHO") 
	oReport:SkipLine(3)
	oSection1:Finish() //Fecha Section
		
	_csetul := aAtestado[ 1 , 7 ] 	
	_cfunul := aAtestado[ 1 , 3 ] 
	_nconful := 0
	_ndiasf := 0
	_nhorasf := 0
	_nminutosf := 0
	_nfuns := 0
	_nfunt := 0
	
	
	nx := 1	
	oReport:SetMeter(Len(aAtestado))
	
	Do while nX <= Len(aAtestado)//Percorre todos os registro para realizar a impressão
		
        oReport:IncMeter()
		nXATEST := nX
		_limprimiu := .F.
	
		If _csetul == aAtestado[ nX , 7 ] .and. _cfunul == aAtestado[ nX , 3 ] 
	
			oSection2:Init()  //Inicia Section
	
			oSection2:PrintLine()  //Imprime a linha  
			
			_limprimiu := .T.
			
			_ntotpag++
			_ndias := _ndias + iif(aAtestado[ nX , 8 ] > 0, aAtestado[ nX , 8 ],0)
			_nhoras := _nhoras + val(substr(Transform( aAtestado[ nX , 9 ] , "99:99"),1,2))
			_nminutos := _nminutos + val(substr(Transform( aAtestado[ nX , 9 ] , "99:99"),4,2))
				  
			If !Empty( aAtestado[ nX , 6 ] ) .AND. MV_PAR16 == 1 //Verifica se existe observação
				oSection3:Init()  //Inicia Section
				oSection3:PrintLine()  //Imprime a linha   
				oSection3:Finish() //Fecha Section
			Endif
		
		Endif
		
		//conta linhas ou Imprime total do funcionário
		If _cfunul == aAtestado[ nX , 3 ] .and. _limprimiu
		
			_nconful++
			_ndiasf := _ndiasf + iif(aAtestado[ nX , 8 ] > 0, aAtestado[ nX , 8 ],0)
			_nhorasf := _nhorasf + val(substr(Transform( aAtestado[ nX , 9 ] , "99:99"),1,2))
			_nminutosf := _nminutosf + val(substr(Transform( aAtestado[ nX , 9 ] , "99:99"),4,2))
			
		Else
		
			If _nconful > 1 //Se tem mais de uma linha do funcionário imprime os totais
			
			
					Do while _nminutosf > 59
			 		
						_nhorasf++
						_nminutosf := _nminutosf - 60
			 			
					Enddo
	
					oReport:SkipLine(1)
					oReport:PrtLeft("TOTAL DO FUNCIONARIO " + _cfunul + ":")					
					oReport:SkipLine(1)
					oReport:Prtleft(strzero(_nconful,4) + " OCORRENCIAS TOTALIZANDO " + strzero(_ndiasf,6) + " DIAS E " + strzero(_nhorasf,6) + "H:" + strzero(_nminutosf,2)+"H")
					oReport:SkipLine(1)
					oReport:SkipLine(1)
			
			Else
			
				oReport:SkipLine(1)
			
			Endif
			
			if _nconful > 0
				_nfuns++
				_nfunt++
			Endif
			
			_nconful := 0
			_cfunul := aAtestado[ nX , 3 ]
			_ndiasf := 0
			_nhorasf := 0
			_nminutosf := 0
			
			
		Endif
			
		//Verifica a quantidade de linhas impresas,após a impressão de todos os registros ou mudança de setor
		If ( nX =  Len(aAtestado) .or. _csetul != aAtestado[ nX , 7 ])  .And. oReport:Row() < 2100 //Verifica a quantidade de linhas impressa
				For nY := 1 To 50
					oReport:SkipLine()//Pula linha
					If oReport:Row() >= 2100 //Caso atinja ao valor máximo de linhas
						Exit
					Endif
				Next nY 
				
		Endif
		//Imprime rodapé de assinaturas.
		If oReport:Row() >= 2000 .Or. nX == Len(aAtestado)   
		
				If _csetul != aAtestado[ nX , 7 ] 
				
					//Faz totalizado do setor e incrementa totalizadores gerais
				
					Do while _nminutos > 59
						_nhoras++
						_nminutos := _nminutos - 60
					Enddo
			 	
					oReport:SkipLine(1)
					oReport:PrtLeft("TOTAL DO SETOR " + _csetul + ":")					
					oReport:SkipLine(1)
					oReport:PrtLeft(strzero(_nfuns,4) + " FUNCIONARIOS")	
					oReport:SkipLine(1)
					oReport:Prtleft(strzero(_ntotpag,4) + " OCORRENCIAS TOTALIZANDO " + strzero(_ndias,6) + " DIAS E " + strzero(_nhoras,6) + "H:" + strzero(_nminutos,2)+"H")
					_nfuns := 0
					_ndiast += _ndias
					_ndias := 0
					_nhorast += _nhoras
					_nhoras := 0
					_nminutost += _nminutos
					_nminutos := 0
					_ntotpagt += _ntotpag
					_ntotpag := 0
					
					_csetul := aAtestado[ nX , 7 ]  //Atualiza campo de ultimo setor impresso
		
			 	Endif
		
			 	If nX == Len(aAtestado) // Faz totalizador geral
			 	
			 	
			 				//Faz totalizado do setor e incrementa totalizadores gerais
				
					Do while _nminutos > 59
						_nhoras++
						_nminutos := _nminutos - 60
					Enddo
			 	
					oReport:SkipLine(1)
					oReport:PrtLeft("TOTAL DO SETOR " + _csetul + ":")					
					oReport:SkipLine(1)
					oReport:PrtLeft(strzero(_nfuns,4) + " FUNCIONARIOS")	
					oReport:SkipLine(1)
					oReport:Prtleft(strzero(_ntotpag,4) + " OCORRENCIAS TOTALIZANDO " + strzero(_ndias,6) + " DIAS E " + strzero(_nhoras,6) + "H:" + strzero(_nminutos,2)+"H")
					_nfuns := 0
					_ndiast += _ndias
					_ndias := 0
					_nhorast += _nhoras
					_nhoras := 0
					_nminutost += _nminutos
					_nminutos := 0
					_ntotpagt += _ntotpag
					_ntotpag := 0
			 	
			 		Do while _nminutost > 59
			 			_nhorast++
			 			_nminutost := _nminutost - 60
			 		Enddo
			 	
			 		oReport:SkipLine(1)
			 		oReport:PrtLeft("TOTAL GERAL:")
			 		oReport:SkipLine(1)
			 		oReport:PrtLeft(strzero(_nfunt,4) + " FUNCIONARIOS")	
					oReport:SkipLine(1)
			 		oReport:PrtLeft(strzero(_ntotpagt,4) + " OCORRENCIAS TOTALIZANDO " + strzero(_ndiast,6) + " DIAS E  " + strzero(_nhorast,6) + "H:" + strzero(_nminutost,2)+"M")
			 	
			 	Endif
			 	
			 	oReport:SkipLine(3)  
				oReport:PrtCenter( "               ___ / ___ / ___  _____________________________                                               ___ / ___ / ___  ______________________________   " )
				oReport:SkipLine()
				oReport:PrtCenter( "                                         MEDICO                                                                                   RESPONSÁVEL DE SAÚDE         " )
				oReport:EndPage(.T.)
				If oReport:Page() > 1 .And. nX <> Len(aAtestado) //Caso seja nova pagina.
					oSection1:Init()  
					oReport:SkipLine(8)
					oReport:PrtCenter("PROGRAMA DE CONTROLE MEDICO DE SAUDE OCUPACIONAL")
					oReport:SkipLine()
					oReport:PrtCenter("COMUNICACAO  INTERNA  DE  ATESTADOS  POR  FALTA  AO  TRABALHO")  
					oReport:SkipLine(3)
					oSection1:Finish()   
				Endif
		EndIf
		
		oSection2:Finish() 
	
		If _limprimiu  //Só avança registro se imprimu linha
			nx++
		Endif
	
	Enddo  
	
Else 
	u_itmsg( "Não existe atestado para realizar a impressão.",,,1 )
	Return .F.
Endif

Return 

 /*
===============================================================================================================================
Programa----------: RMDT003H
Autor-------------: Josué Danich Prestes
Data da Criacao---: 04/08;/2017
Descrição---------: Converte tempo de trabalho perdido por atestado
Parametros--------:	ddtini - data de inicio do atestado
					ddtfim - data de final do atestado
					cHoraIni - hora inicio do atestado
					cHoraFim - hora final do atestado
Retorno-----------: array com total de dias e horas do atestado
===============================================================================================================================
*/
Static Function RMDT003H(ddtini , ddtfim , cHoraIni , cHoraFim)

Local _ahoras := {}

If ddtini == ddtfim

	//Mesmo dia
	_ndias := 0
	_cdias := alltrim(STR(_ndias))
	
	_nmini := val(substr(choraini,4,2)) + (val(substr(choraini,1,2)) * 60 )
	_nminf := val(substr(chorafim,4,2)) + (val(substr(chorafim,1,2)) * 60 )
	
	_nhoras := 0
	_nminutos := _nminf - _nmini
	
	Do while _nminutos > 59
		_nminutos := _nminutos - 60
		_nhoras := _nhoras + 1
	Enddo
	
	If TNY->TNY_I_DIAS == 1
		_choras := "  :  "
		_ndias := 1
		_cdias := "1"
	Else
		_choras := strzero(_nhoras,2) + ":" + strzero(_nminutos,2)
	Endif

Else

	//dias diferentes
	_ndias := iif((ddtfim - ddtini + 1) > 0,(ddtfim - ddtini + 1),0)
	_cdias := alltrim(STR(_ndias))
	
	_choras := "  :  "

Endif

//Ajuste para dia de final de período
If ddtini == ddtfim .and. _choras == "23:59" .and. ddtfim == MV_PAR04
  _ndias := 1
  _choras := "  :  "
  _cdias := alltrim(STR(_ndias))
Endif

//Ajuste para dia de inicio de período
If ddtini == ddtfim .and. _choras == "23:59" .and. ddtini == MV_PAR03
  _ndias := 1
  _choras := "  :  "
  _cdias := alltrim(STR(_ndias))
Endif

_ahoras := { .T., _choras, _ndias, _cdias}

Return _ahoras
