/*
=====================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
=====================================================================================================================================
 Autor        |   Data   |                              Motivo                      										 
=====================================================================================================================================
 Josué Danich | 15/01/16 | Chamado 13803. Incluida validação de campo NNR_TPFB.                                  
 Josué Danich | 21/06/17 | Chamado 20359. Incluida validação de campo D3_I_TPTRS.                                
 Alex Wallauer| 04/07/17 | Chamado 20655. Controlar permissões através da tabela ZZL.         
 Josué Danich | 30/05/18 | Chamado 23086. Exceção de validação quando executando via AGLT003/MT103FIM.    
 Alex Wallauer| 06/12/18 | Chamado 27271. Nova validação da observação dos armazens 1=Fisicos e 2=Virtuais. 
 Alex Walaluer| 14/02/20 | Chamado 31089. Ajuste para desviar a função isincallstack("U_AOMS116S"). 
 Alex Walaluer| 22/02/20 | Chamado 39845. Correção do nome da variável errada na linha 188. 
 Julio Paz    | 19/06/23 | Chamado 43825. Criação de campo/ajuste fonte p/exibir descr. do campo Tipo de Movimentação.
 André Lisboa | 12/03/24 | Chamado 46558. Alteração na gravação do motivo transf/descri. transf.
 Julio Paz    | 16/05/24 | Chamado 46558. Desenvolvimento de Melhorias na rotina de transferência de produtos.
 Alex Walaluer| 20/06/24 | Chamado 47625. Correção do erro.log: array out of bounds na linha 303. 
Lucas Borges  | 13/10/24 | Chamado 48465. Retirada da função de conout
=====================================================================================================================================
==============================================================================================================================================================
Analista     - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
André Lisboa - Alex Wallauer - 12/09/24 -          - 48509   - Ajuste na validação do campo D3_I_DESTI e criação da do D3_I_SETOR.
==============================================================================================================================================================
*/

//Includes e definições da rotina

#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"

/*
===============================================================================================================================
Programa--------: MA261LIN
Autor-----------: Renato de Morcerf 
Data da Criacao-: 03/02/2009
Descrição-------: Ponto de Entrada que valida lancamento de transferencia modelo II
Parametros------: Nenhum
Retorno---------: Lógico permitindo ou não a confirmção da linha
===============================================================================================================================
*/
User Function MA261LIN()

Local	_aArea	:=	GetArea()
Local 	_nPa  	:=	aScan( aHeader, { |x| Alltrim(x[2])== "D3_COD" } )
Local 	_npl  	:= 	acols[n,_nPa]
Local 	_nPa2 	:= 	aScan( aHeader, { |x| Alltrim(x[2])== "D3_QTSEGUM" } )
Local 	_npl2 	:= 	acols[n,_nPa2]
Local _lRet 	:= 	.T.  
Local A
Local _nposori	:= aScan( aHeader, { |x| Alltrim(x[1])== "Armazem Orig." } )
Local _nposdes	:= aScan( aHeader, { |x| Alltrim(x[1])== "Armazem Destino" } )
Local _ntptrs  // := aScan(aHeader,{|x| AllTrim(x[1]) == "Tipo TRS"	})
Local _cArmBloq := ALLTRIM(U_ITGETMV( 'IT_BLOQARMA','34'))
Local _nD3_I_OBS:= Ascan(aHeader,{|x| x[2] = 'D3_I_OBS'  })
Local _nDsctptrs := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_DSCTM"})
Local _cFilVld34 := U_ITGETMV( 'IT_FILVLD34','')

If ! xFilial("SD3") $ _cFilVld34 // Este campo não deve estar disponível para filiais de validação do armazém 34 (Descarte).
   _ntptrs   := aScan(aHeader,{|x| AllTrim(x[1]) == "Tipo TRS"	}) 
EndIf 

//Verifica se está sendo executado automaticamente a partir do mt103fim
If isincallstack("U_MT103FIM") .OR. isincallstack("U_AGLT003G") .OR. isincallstack("U_AOMS116S")

	Return _lret
	
Endif


Begin Sequence

//====================================================================================
// Não permite armazém de origem 34
//====================================================================================
If acols[n][_nposori]  $ _cArmBloq//'34'
   
   u_itmsg("Não é permitida transferência com origem do estoque [ "+_cArmBloq+" ]","Estoque ["+_cArmBloq+"]", "Utilizar outro armazém de origem!!",1)
   _lret := .F.
   Break
Endif

ZZL->(DbSetOrder(3))  
If ZZL->(DbSeek(xFilial("ZZL")+RetCodUsr()))
   _cTipo:=posicione("SB1",1,xfilial("SB1") + acols[n][_nPa], "B1_TIPO" )
   If _cTipo $ ZZL->ZZL_TIPROD

      _aArmBloq:= {acols[n][_nposori],acols[n][_nposdes]}
      FOR A := 1 TO LEN(_aArmBloq)
          If !(_aArmBloq[A] $ ZZL->ZZL_ARMAZE)
 	       	  U_ITMSG("Usuario não tem permissão para transferência do armazem [ "+acols[n][_nposori]+" ] para o [ "+acols[n][_nposdes]+" ]",;
 	       	  			"TRANSFERENCIA NÃO PERMITIDA",; 	       	              
		   			      "Utilizar armazéns permitidos para o usuario: ["+ALLTRIM(ZZL->ZZL_ARMAZE)+"]",1)
		      _lret := .F.
	          Break
	      Endif
	  NEXT
	   
   else
      
      U_ITMSG("Usuario não tem permissão para transferência de produto [ "+_cTipo+" ]","TRANSFERENCIA NÃO PERMITIDA",;       	          
		   		  "Utilizar tipos permitidos para o usuario: ["+ALLTRIM(ZZL->ZZL_TIPROD)+"]",1)
	  _lret := .F.
	  Break

   Endif
   
else
   
    U_ITMSG("Usuario sem cadastro de permissoes" ,"TRANSFERENCIA NÃO PERMITIDA","Favor entrar em contato com a area de TI!!",1)
    _lret := .F.
	Break
    
Endif


//====================================================================================
// Verifica segunda unidade de medida para produto tipo queijo
//====================================================================================
If substr(_npl,1,4) = "0006"

	If _npl2 = 0

		U_ITMSG("Para esse produto e obrigatorio o preenchimento da segunda unidade de medida (Peças).","Segunda Unidade de Medida Vazio",;
						"Favor preencher a segunda unidade de medida (Peças)!!",1)
		_lRet := .F.

	Endif

Endif

//====================================================================================
// Valida tipo de fabricação em armazém de destino e origem
//====================================================================================
If  _lret .and. !(posicione("NNR",1,xfilial("NNR") + alltrim(acols[n][_nposori]),"NNR_I_TPFB") $ "PTG"); 
			.and. !(posicione("NNR",1,xfilial("NNR") + alltrim(acols[n][_nposdes]),"NNR_I_TPFB") == "G")

	U_ITMSG("Armazém de origem não tem tipo de fabricação identificado e não pode ser usado para transferências.","Armazém origem inválido",;
						"Utilizar outro armazém ou corrigir o cadastro do armazém selecionado.",1)
	_lRet := .F.
		
Endif

If  _lret .and. !(posicione("NNR",1,xfilial("NNR") + alltrim(acols[n][_nposdes]),"NNR_I_TPFB") $ "PTG");
			.and. !(posicione("NNR",1,xfilial("NNR") + alltrim(acols[n][_nposori]),"NNR_I_TPFB") == "G") 

	U_ITMSG("Armazém de destino não tem tipo de fabricação identificado e não pode ser usado para transferências.","Armazém destino inválido",;
						"Utilizar outro armazém ou corrigir o cadastro do armazém selecionado.",1)
	_lRet := .F.
		
Endif

If  _lret .and. (posicione("NNR",1,xfilial("NNR") + alltrim(acols[n][_nposori]),"NNR_I_TPFB") == "P");
			.and. !(posicione("NNR",1,xfilial("NNR") + alltrim(acols[n][_nposdes]),"NNR_I_TPFB") $ "PG")

	U_ITMSG("Armazém de destino só pode ser do tipo de fabricação própria ou geral pois o armazém de origem é de fabricação própria.","Armazém destino inválido",;
						"Utilizar outro armazém ou corrigir o cadastro do armazém selecionado.",1)
	_lRet := .F.
		
Endif

If  _lret .and. (posicione("NNR",1,xfilial("NNR") + alltrim(acols[n][_nposori]),"NNR_I_TPFB") == "T");
			.and. !(posicione("NNR",1,xfilial("NNR") + alltrim(acols[n][_nposdes]),"NNR_I_TPFB") $ "TG")

	U_ITMSG("Armazém de destino só pode ser do tipo de fabricação terceiros ou geral pois o armazém de origem é de fabricação terceiros.","Armazém destino inválido",;
						"Utilizar outro armazém ou corrigir o cadastro do armazém selecionado.",1)
	_lRet := .F.
		
Endif

If _lRet
	IF NNR->(FIELDPOS("NNR_I_TPFV")) <> 0
		NNR->(DBSETORDER(1))
		NNR->(DBSEEK(xFilial()+acols[n][_nposori]))
		_cTipoOrigem :=NNR->NNR_I_TPFV
		NNR->(DBSEEK(xFilial()+acols[n][_nposdes]))
		_cTipoDestino:=NNR->NNR_I_TPFV
		If _cTipoOrigem <> _cTipoDestino .AND. LEN(ALLTRIM(acols[n,_nD3_I_OBS])) < 10//"1=Fisico;2=Virtual"
			U_ITMSG("Para transferir produtos entre armazens virtuais e armazens fisicos nessa rotina,"+;
			        " o campo de observação deve ser preenchido detalhando o motivo da transferência nessa linha ",;
			        "ATENÇÃO",;
			         "Preencha a observação da linha com uma descrição minima de 10 caracteres",1)
			_lRet := .F.
		EndIf
	EndIf
EndIf

//====================================================================================
// Garante que tipo de movimento trs vai em branco se armazem destino não for 34
//====================================================================================
If ! xFilial("SD3") $ _cFilVld34 // Este campo não deve estar disponível para filiais de validação do armazém 34 (Descarte).
   If acols[n][_nposdes] != '34'
      If _ntptrs > 0   
         acols[n][_ntptrs] := " "
      EndIf 

      If _nDsctptrs > 0
         acols[n][_nDsctptrs] := " "
      EndIf
   Endif
EndIf 

End Sequence

IF TYPE("lMsErroAuto") = "L" .AND. !_lRet .AND. !lMsErroAuto//Só altera o conteudo do lMsErroAuto se ele tiver Falso e o retorno for falso
   lMsErroAuto:=!_lRet//Só Joga verdadeiro de for o caso
ENDIF

RestArea(_aArea)

Return _lRet

/*
===============================================================================================================================
Programa--------: MT261VLD
Autor-----------: Julio de Paula Paz 
Data da Criacao-: 22/05/2023
Descrição-------: Função de Validações da Tela de Transferência de Estoques.
Parametros------: _cCampo = Campo que chamou a validação.
                  _nLinha = Linha do aCols
Retorno---------: _lRet = .T. = Validação Ok.
                          .F. = Inconsistência na Validação.
===============================================================================================================================
*/
User Function MT261VLD(_cCampo,_nLinha)
Local _lRet := .T.
Local _ntptrs, _nDsctptrs
Local _cDadoCBox 
Local _nPosOrig, _nPosDest
Local _cCampoFoco, _xConteudo
Local _nPosLoteD 
Local _nMotTrRef, _nDscMTrRf 
Local _cFilVld34 := U_ITGETMV( 'IT_FILVLD34','')

Default _nLinha := Len(aCols)

Begin Sequence 
      
   If _cCampo == "D3_I_TPTRS" 
      _ntptrs     := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_TPTRS"})
      _nDsctptrs  := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_DSCTM"})
     
	  If ! Empty(M->D3_I_TPTRS) 
	     _cDadoCBox := X3CBoxDesc("D3_I_TPTRS",M->D3_I_TPTRS)
		 aCols[N,_nDsctptrs] := POSICIONE("SF5",1,xFilial("SF5")+U_ITKEY(_cDadoCBox,"F5_CODIGO"),"F5_TEXTO")
		 M->D3_I_DSCTM := aCols[N,_nDsctptrs]
      Else 
		 aCols[N,_nDsctptrs] := ""
		 M->D3_I_DSCTM := ""
	  EndIf  
   
   ElseIf _cCampo == "D3_I_MOTTR" .And. xFilial("SD3") $ _cFilVld34
      
      _nMotTrRef  := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_MOTTR"})
      _nDscMTrRf  := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_DSCMT"})
     
	  If ! Empty(M->D3_I_MOTTR) 
	     aCols[N,_nDscMTrRf] := POSICIONE("CYO",1,xFilial("CYO")+M->D3_I_MOTTR,"CYO_DSRF")
		 M->D3_I_DSCMT := aCols[N,_nDscMTrRf]

         ZCF->(DbSetOrder(3)) 
	     If ! ZCF->(MsSeek(xFilial("ZCF")+M->D3_I_MOTTR))
            U_ITMSG("O Código do Motivo de Transferência Refugo informado não existe.","Atenção",,1) 
            _lRet :=.F.
            Break     
	     EndIf 

         _nPosOrig  := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_SETOR"})      
         aCols[_nLinha,_nPosOrig] := ZCF->ZCF_ORIGDE

      Else 
		 aCols[N,_nDscMTrRf] := SPACE(LEN(SD3->D3_I_DSCMT))
		 M->D3_I_DSCMT := SPACE(LEN(SD3->D3_I_DSCMT))
  
         _nPosOrig  := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_SETOR"})     
         aCols[_nLinha,_nPosOrig] := SPACE(LEN(SD3->D3_I_SETOR))

	  EndIf  

   ElseIf _cCampo == "D3_LOTECTL" 
   
      _cCampoFoco := ReadVar()
	  _xConteudo := &(ReadVar())

	  //====================================================================================== 
	  // Existem duas variáveis M->D3_LOTECTL (Origem) e M->D3_LOTECTL (Destino) no Acols. 
	  // A posição atual de M->D3_LOTECTL (Origem) é: NNEWCOL = 12.
	  // A posição atual de M->D3_LOTECTL (Destino) é: NNEWCOL= 20.
	  // O If abaixo é para sabermos se está sendo digitado no lote de origem ou de destino
      //====================================================================================== 
	  If NNEWCOL < 15 
         _nPosLoteD	:= aScan( aHeader, { |x| Alltrim(x[1])== "Lote Destino" } )         
		 IF _nPosLoteD > 0 
            aCols[N,_nPosLoteD] := _xConteudo
		 ENDIF
	  EndIf 

   ElseIf _cCampo == "D3_I_SETOR" .And. xFilial("SD3") $ _cFilVld34//U_MT261VLD("D3_I_SETOR")

      ZCF->(DbSetOrder(2)) 
	  If !Empty(M->D3_I_SETOR) .AND.  !ZCF->(MsSeek(xFilial("ZCF")+M->D3_I_SETOR))
         //U_ItMsg("O preenchimento do campo destino é obrigatório quando o armazém de destino for 34.","Atenção", ,1) 
		 U_ItMsg("Favor preencher campo do Origem Trf. da transferência para o armazém 34 com um codigo válido.","Atenção",;
		         "Verificar preenchimento do campo 'Origem Trf.' (D3_I_SETOR)" ,1)

		 _lRet := .F. 
	  EndIf 
      ZCF->(DbSetOrder(1)) 

   ElseIf _cCampo == "D3_I_DESTI" .And. xFilial("SD3") $ _cFilVld34
      //- Não permitir gravar a transferência sem que seja preenchido o campo destino ; D3_I_DESTI = Destinacao    
      _nPosDest  := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_DESTI"})  // M->D3_I_DESTI 
	  IF _nPosDest > 0
	     _cDestino:= aCols[_nLinha,_nPosDest]      
	  ENDIF
      _cCodDest:= U_ITGETMV( "IT_DESTTRA", "000062;000063")
      ZCF->(DbSetOrder(2)) 
	  If Empty(M->D3_I_DESTI) .OR. !ZCF->(MsSeek(xFilial("ZCF")+M->D3_I_DESTI)) .OR. !ZCF->ZCF_CODIGO $ _cCodDest
		 U_ItMsg("Favor preencher campo do destino da transferência. Obrigatório preenchimento para transferências para o armazém 34 com um codigo válido.","Atenção",;
		         "Verificar preenchimento do campo 'Destino' (D3_I_DESTI), tem que pertencer aos codigos: "+_cCodDest,1)

		 _lRet := .F. 
	  EndIf 
      ZCF->(DbSetOrder(1)) 

   ElseIf _cCampo == "A261TOK"
      
      If ! xFilial("SD3") $ _cFilVld34 // Este campo não deve estar disponível para filiais de validação do armazém 34 (Descarte).
         _ntptrs     := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_TPTRS"})
         _nDsctptrs  := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_DSCTM"})
      
	     M->D3_I_TPTRS := aCols[_nLinha,_ntptrs] 
	  
	     If ! Empty(M->D3_I_TPTRS) 
	        _cDadoCBox := X3CBoxDesc("D3_I_TPTRS",M->D3_I_TPTRS)
            aCols[_nLinha,_nDsctptrs] := POSICIONE("SF5",1,xFilial("SF5")+U_ITKEY(_cDadoCBox,"F5_CODIGO"),"F5_TEXTO")
		    M->D3_I_DSCTM := aCols[Len(aCols),_nDsctptrs]
         Else 
            aCols[_nLinha,_nDsctptrs] := ""
		    M->D3_I_DSCTM := ""
	     EndIf  
	  EndIf 

      If xFilial("SD3") $ _cFilVld34 // Este campo não deve estar disponível para filiais de validação do armazém 34 (Descarte).
         _nMotTrRef  := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_MOTTR"})
         _nDscMTrRf  := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_DSCMT"})

	     If ! Empty(M->D3_I_MOTTR)  
	        aCols[_nLinha,_nDscMTrRf] := POSICIONE("CYO",1,xFilial("CYO")+M->D3_I_MOTTR,"CYO_DSRF")
		    M->D3_I_DSCMT := aCols[Len(aCols),_nDsctptrs]
         Else 
            aCols[_nLinha,_nDscMTrRf] := ""
		    M->D3_I_DSCMT := ""
	     EndIf  
	  EndIf 
	  
   EndIf 

End Sequence 

Return _lRet 
