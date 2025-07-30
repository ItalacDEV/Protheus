/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
      Autor   |    Data  |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich  | 12/11/15 | Chamado 12743. Inclusão de validação de saldo de perdas na data da perda. 
 ------------------------------------------------------------------------------------------------------------------------------
André Lisboa  | 20/09/17 | Chamado 21477. Inclusão de validação para não permitir apontar com qtde zerada. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 21/02/24 | Chamado 46236. André. Novas validações de campos dos produtos.
-------------------------------------------------------------------------------------------------------------------------------
André Lisboa  | 13/03/24 | Chamado 46587. Incluida permissão de informar produto destino com OP aberta para varredura.
-------------------------------------------------------------------------------------------------------------------------------
André Lisboa  | 13/03/24 | Chamado 46870. VAlidações de informações do lote para produtos com rastreabilidade.
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE "PROTHEUS.CH"   
#DEFINE CRLF CHR(13)+CHR(10)
#define MB_OK 0

/*
===============================================================================================================================
Programa----------: MT685TOK
Autor-------------: Carlos Cleber A.Silva
Data da Criacao---: 08/01/2014
===============================================================================================================================
Descrição---------: Ponto de entrada para validar gravação de apontamento de perdas - Chamado 5018
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lRet := .T. Prossegue com apontamento de Perdas
                  		     .F. Nao Prossegue com apontamento de Perdas 	   
===============================================================================================================================
*/
User Function MT685TOK()  

Local _lRet     	:= .T.
Local _dDtServ  	:= dDataBase
Local _dDtAtual 	:= DATE()  
Local _nDtPos   	:= aScan(aHeader,{|X| Upper(Alltrim(X[2]))=="BC_DATA"}) 
Local _nPrdPos		:= aScan(aHeader,{|X| Upper(Alltrim(X[2]))=="BC_PRODUTO"}) 
Local _nQtdPos		:= aScan(aHeader,{|X| Upper(Alltrim(X[2]))=="BC_QUANT"}) 
Local _nLocPos  	:= aScan(aHeader,{|X| Upper(Alltrim(X[2]))=="BC_LOCORIG"})   
Local _dDtPer   	:= aCols[N][_nDtPos]
Local _ni		 	:= 1
Local _asaldos 		:= {}
Local _nquant  		:= 0
Local _asaldos2 	:= {}
Local _nquant2  	:= 0
Local _cPrdSuc		:= GETMV( "IT_PRDSUCA" )
//Local _aprob	 	:= {}
//Local _aprob2		:= {}
//Local _aprob3		:= {}
Local _lInc 		:= PARAMIXB[1]
PRIVATE _aLog :={}

//==========================================================================================
//Valida saldos de produtos consumidos pela perda na data de apontamento
//==========================================================================================
If _lRet .and. _lInc

    //==========================================================================================
    //Valida database contra date()
    //==========================================================================================
    If _dDtServ > _dDtAtual .Or. _dDtPer > _dDtServ  		
    	_lRet := .F. 	
    	_cMensagem := "Para incluir Apontamento de Perda a 'Data de emissão' não pode ser maior que a 'Data atual do servidor ou Data base do sistema. "
    	_cMensagem += "Não é permitido criar Apontamento de Perda com data futura! "
    	_cMensagem += "Conferir a 'Data Base do sistema' e ajustar a 'Data de emissão' se necessário. "
    	cSolucao := "Data Atual (SO): "+DTOC(_dDtAtual)+" "+CRLF+"Data Base (Sistema): "+DTOC(_dDtServ)+" "+CRLF+"Data Emissão: "+DTOC(_dDtPer)
    	//MessageBox(_cMensagem, "MT685TOK - PROBLEMA DATA BASE", MB_OK)
    	U_ITMSG(_cMensagem,'Atenção!',cSolucao,1) // CANCEL
    EndIf


   _lOPAberta:=.T.
   IF XFILIAL("SC2")+CORDEMP <> SC2->C2_FILIAL+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
      SC2->(DBSETORDER(1))//SC2->C2_FILIAL+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
      IF SC2->(DBSEEK(XFILIAL("SC2")+CORDEMP)) 
         _lOPAberta:=EMPTY(SC2->C2_DATRF)
      ENDIF
   ELSE
      _lOPAberta:=EMPTY(SC2->C2_DATRF)
   ENDIF
   
   lUsaRastr := ALLTRIM(SuperGetMv( "MV_RASTRO"  , .F. , ""  )) = "S"
   SB1->(DBSETORDER(1))
   _cPerg2um:="NAO_TEM_QUEIJO"
   _cProdQue:=""

   For _ni := 1 to len(acols)

		If !acols[_ni][Len(aHeader)+1] //se não é linha deletada
		    
            cCodProd:= GDFIELDGET("BC_PRODUTO",_ni)
			cLinha  := STRZERO(_ni,2)
			cSolucao:=""

		    If acols[_ni][_nQtdPos] == 0
		    	//aadd( _aprob2, { alltrim(acols[_ni][_nPrdPos]), STRZERO(_ni,2) } )
				cProb:="É obrigatório que o produto tenha uma quantidade maior que 0 (zero)!"
				cSolucao:="A quantidade deve ser informada, maior que zero."				
				GRVLog(cCodProd,cLinha,cProb,cSolucao)
		    Endif			

		    IF EMPTY(GDFIELDGET("BC_I_NPROD",_ni))
		    	//AADD( _aprob3, { GDFIELDGET("BC_PRODUTO",_ni) , STRZERO(_ni,2) } )
				cProb:="É obrigatório que o produto tenha a descricao preenchida!"
				cSolucao:="Edite o codigo do produto e tecle ENTER para gatilhar a descricao do mesmo."
				GRVLog(cCodProd,cLinha,cProb,cSolucao)
		    Endif			
		    
		    IF EMPTY(GDFIELDGET("BC_MOTIVO",_ni))
		    	//AADD( _aprob3, { GDFIELDGET("BC_PRODUTO",_ni) , STRZERO(_ni,2) } )
				cProb:="É obrigatório que o produto tenha o motivo preenchido!"
				cSolucao:="O motivo deve ser informado."
				GRVLog(cCodProd,cLinha,cProb,cSolucao)
		    Endif			

		    IF GDFIELDGET("BC_LOCORIG",_ni) = "34"
				cProb:="Armazem de origem não pode ser igual a 34 !"
				cSolucao:="Escolha um armazem de origem diferente de 34."
				GRVLog(cCodProd,cLinha,cProb,cSolucao)
		    Endif			

			SB1->( DBSeek( xFilial("SB1") + cCodProd ) ) 
            nQTSEGUM:=GDFIELDGET("BC_QTSEGUM",_ni)    
            nQTDDES2:=GDFIELDGET("BC_QTDDES2",_ni)    

			//VALIDACAO DOS QUEIJOS
			IF SubStr(cCodProd,1,4) = "0006" .AND. SB1->B1_CONV = 0 .AND. SB1->B1_I_SFCON = "1"
			   
			    IF EMPTY(nQTSEGUM) .AND. EMPTY(nQTDDES2)
                   IF _cPerg2um = "NAO_TEM_QUEIJO"
				      _cPerg2um:="SO_TEM_QUEIJO_OK"//SÓ ATIVA A PERGUNTA SE TIVER UMA LINHA COM OS 2 EM BRANCO
				   ENDIF
				   _cProdQue+=" ["+cCodProd+"("+cLinha+")]"
			    ELSEIF !EMPTY(nQTSEGUM) .OR. !EMPTY(nQTDDES2)
				   nQUANT  :=GDFIELDGET("BC_QUANT"  ,_ni)  
                   nQTDDEST:=GDFIELDGET("BC_QTDDEST",_ni)
  				   _nFtMin := SB1->B1_I_FTMIN
				   _nFtMax := SB1->B1_I_FTMAX
				   cProb:=""
				   
				   _nVlrPeca := nQUANT / nQTSEGUM
					If _nVlrPeca < _nFtMin .Or. _nVlrPeca > _nFtMax //Fora dos limites: menor que o Minimo ou maior que o Maximo
						cProb:="Quantidade Origem da 2 UM fora da faixa - "+ cValToChar( nQUANT ) +" / "+ cValToChar( nQTSEGUM ) +" = "+ cValToChar( _nVlrPeca ) + CRLF
					EndIf
				   
				   _nVlrPeca := nQTDDEST / nQTDDES2
					If _nVlrPeca < _nFtMin .Or. _nVlrPeca > _nFtMax //Fora dos limites: menor que o Minimo ou maior que o Maximo
						cProb:="Quantidade Destino da 2 UM fora da faixa - "+ cValToChar( nQTDDEST ) +" / "+ cValToChar( nQTDDES2 ) +" = "+ cValToChar( _nVlrPeca ) + CRLF
					EndIf

                    IF !EMPTY(cProb)
				       _cPerg2um:="TEM_QUEIJO_COM_PROBLEMA"
				       cSolucao:="Digite uma quantidade dentro da faixa de conversao entre "+cValToChar( _nFtMin )+" e "+cValToChar( _nFtMax )+" ."
				       GRVLog(cCodProd,cLinha,cProb,cSolucao)
					ENDIF
			    ENDIF
			
			ELSEIF SB1->B1_CONV = 0 .AND. (!EMPTY(nQTSEGUM) .OR. !EMPTY(nQTDDES2))

		    	cProb:="Produto não tem conversão de unidade de medida!"
		    	cSolucao:="Os campos de segunda unidade devem ser zerados."
		    	GRVLog(cCodProd,cLinha,cProb,cSolucao)

			//VALIDAÇÃO PRODUTOS COM CONTROLE DE LOTES
			ELSEIF lUsaRastr .AND. SB1->B1_RASTRO = 'L'  .AND. EMPTY(TRIM(GDFIELDGET("BC_LOTECTL",_ni)))
				cProb:="Produto com controle de lotes ativado"
		    	cSolucao:="Informar o campo Lote."
		    	GRVLog(cCodProd,cLinha,cProb,cSolucao)



			ENDIF

            IF _lOPAberta // OP ABERTA
		        If (!TRIM(GDFIELDGET("BC_CODDEST",_ni)) == TRIM(_cPrdSuc))
					IF  (!EMPTY(GDFIELDGET("BC_LOCAL",_ni)) .OR. !EMPTY(GDFIELDGET("BC_CODDEST",_ni)))
			    		cProb:="Para OP aberta não pode preencher os campos de Local e Produto de destino!"
			    		cSolucao:="Limpe os campos de Local e Produto de destino."
			    		GRVLog(cCodProd,cLinha,cProb,cSolucao)
		        	Endif
				Elseif EMPTY(GDFIELDGET("BC_LOCAL",_ni))
					cProb:="Quando produto destino preenchido, obrigatório preencher o armazém destino"
			    	cSolucao:="Informe o armazém destino."
			    	GRVLog(cCodProd,cLinha,cProb,cSolucao)	
				Endif			
			ELSE// OP ENCERRADA
		        IF GDFIELDGET("BC_LOCAL",_ni) <> "34"
			    	cProb:="Para OP encerrada o Armazem de destino deve ser igual a 34 !"
			    	cSolucao:="Selecione o armazem de destino igual a 34."
			    	GRVLog(cCodProd,cLinha,cProb,cSolucao)
		        
				//lote origem e destino deverão ser iguais
				
				ElseIf 	TRIM(GDFIELDGET("BC_LOTECTL",_ni)) <> TRIM(GDFIELDGET("BC_LOTDEST",_ni))
					cProb:="Lotes origem e destino divergentes"
			    	cSolucao:="Favor informar o mesmo lote origem e destino."
			    	GRVLog(cCodProd,cLinha,cProb,cSolucao)
				

				Elseif GDFIELDGET("BC_QUANT"  ,_ni)  <> GDFIELDGET("BC_QTDDEST",_ni)
					cProb:="Quantidade origem e destino divergentes"
			    	cSolucao:="Favor verificar as quatidades de perda e destino informadas, elas devem ser iguais."
			    	GRVLog(cCodProd,cLinha,cProb,cSolucao)
				Endif	

									
			ENDIF
			If 	TRIM(GDFIELDGET("BC_CODDEST",_ni)) == TRIM(_cPrdSuc)
				If !U_ITMSG('Produto destino "Resíduo lácteo"','Atenção!','Gravar dados para destino "Resíduo lácteo"?',3,2,2,,"GRAVAR","VOLTAR")
					_lRet:=.F.
				Endif	
			Endif




			//calcula saldo final do produto na data
			_aSaldos:=	CalcEst(padr(alltrim(acols[_ni][_nPrdPos]),15),alltrim(acols[_ni][_nLocPos]), acols[_ni][_nDtPos]+1)
			_nQuant	:= _aSaldos[1]
			
			//calcula saldo final do produto na data atual do servidor
			_aSaldos2:=	CalcEst(padr(alltrim(acols[_ni][_nPrdPos]),15),alltrim(acols[_ni][_nLocPos]), date() + 1)
			_nQuant2 := _aSaldos2[1]

			cProb:="É obrigatório que o produto tenha saldo no dia da perda e no dia atual!"
			cSolucao:=""

			If _nquant < acols[_ni][_nQtdPos]
			
				//aadd(_aprob,{ alltrim(acols[_ni][_nPrdPos]),;//01
				//              acols[_ni][_nQtdPos],;         //02
				//				_nquant,;                      //03
				//				alltrim(acols[_ni][_nLocPos]),;//04
				//				acols[_ni][_nDtPos]+1 } )      //05

			    cSolucao := "Esse produto no armazém " + alltrim(acols[_ni][_nLocPos]) + " possui saldo de " + ALLTRIM(TRANSFORM(_nquant,"@E 999,999,999.99"))
			    cSolucao += " em " + dtoc(acols[_ni][_nDtPos]) + " com perda de " + ALLTRIM(TRANSFORM(acols[_ni][_nQtdPos],"@E 999,999,999.99"))
				GRVLog(cCodProd,cLinha,cProb,cSolucao)
				
			Endif
			
			If _nquant2 < acols[_ni][_nQtdPos] .and. date() <> acols[_ni][_nDtPos] 
			
				//aadd(_aprob,{ alltrim(acols[_ni][_nPrdPos]),;//01
				//              acols[_ni][_nQtdPos],;         //02
				//				_nquant2,;                     //03
				//				alltrim(acols[_ni][_nLocPos]),;//04
				//				DATE() + 1 } )                 //05

			    cSolucao := "Esse produto no armazém " + alltrim(acols[_ni][_nLocPos]) + " possui saldo de " + ALLTRIM(TRANSFORM(_nquant2,"@E 999,999,999.99"))
			    cSolucao += " em " + DTOC(DATE()) + " com perda de " + ALLTRIM(TRANSFORM(acols[_ni][_nQtdPos],"@E 999,999,999.99"))
				GRVLog(cCodProd,cLinha,cProb,cSolucao)

			Endif
			
		Endif
		
	Next
	
	//If len(_aprob2) > 0	
	//	_cMensagem := "Foram encontrados problemas nas quantidades informadas de perdas! "
	//	_cMensagem += "Apontamento não será completado, é obrigatório que o produto tenha uma quantidade maior que 0 (zero):"+CRLF
	//	cSolucao:=""
   	//	for _ni = 1 to len(_aprob2)
	//		cSolucao += "A qtde do prod. "+_aprob2[_ni][1] + " deve ser informada"+CRLF  
	//	next
	//	//MessageBox(_cMensagem, "MT685TOK - PROBLEMA NA QUANTIDADE DOS PRODUTOS", MB_OK)
	//    U_ITMSG(_cMensagem,'Atenção!',cSolucao,1) // CANCEL
	//	_lRet := .F.		
	//Endif

	//If len(_aprob3) > 0	
	//	_cMensagem := "Foram encontrados problemas nos motivos informadas de perdas! "
	//	_cMensagem += "Apontamento não será completado, é obrigatório que o produto tenha o motivo preenchido:"+CRLF
	//	cSolucao:=""
   	//	for _ni = 1 to len(_aprob3)
	//		cSolucao += "O motido do prod. "+_aprob3[_ni][1] + " deve ser informado"+CRLF  
	//	next
	//	//MessageBox(_cMensagem, "MT685TOK - PROBLEMA NA QUANTIDADE DOS PRODUTOS", MB_OK)
	//    U_ITMSG(_cMensagem,'Atenção!',cSolucao,1) // CANCEL
	//	_lRet := .F.		
	//Endif

	//If len(_aprob) > 0	
	//	_cMensagem += "Foram encontrados problemas com os saldos de produtos! "
	//	_cMensagem += "Apontamento não será completado, é obrigatório que o produto tenha saldo no dia da perda e no dia atual: "
	//	cSolucao:=""
   	//	for _ni = 1 to len(_aprob)  
	//		cSolucao += _aprob[_ni][1] + " no armazém " + _aprob[_ni][4] + " possui saldo de " + ALLTRIM(TRANSFORM(_aprob[_ni][3],"@E 999,999,999.99"))+CRLF   
	//		cSolucao += " em " + dtoc(_aprob[_ni][5]-1) + " com perda de " + ALLTRIM(TRANSFORM(_aprob[_ni][2],"@E 999,999,999.99"))+CRLF    		
	//	next	
	//	//MessageBox(_cMensagem, "MT685TOK - PROBLEMA NO SALDO DOS PRODUTOS", MB_OK)
	//    U_ITMSG(_cMensagem,'Atenção!',cSolucao,1) // CANCEL		 
	//	_lRet := .F.		
	//Endif	

    IF LEN(_aLog) > 0
        _aTit:={"Produto","Linha","Problema","Solucao"}
    	_cTitulo:="LOG DE PROBLEMAS ENCONTRADOS NOS PRODUTOS:"
    	_cMsgTop:= "APONTAMENTO NÃO SERÁ CONCLUIDO!"
    	_lRet:=.F.
       //                           ,_aCols ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _aBbuttons )
          U_ITListBox(_cTitulo,_aTit,_aLog  , .T.    , 3    ,_cMsgTop,          ,        ,         ,     ,        ,            )
    
    ELSEIF _lRet
    
       IF _cPerg2um = "SO_TEM_QUEIJO_OK"
    	  
    	  _cMensagem:="Esse(s) produto(s):"+_cProdQue+" não esta(ao) com a 2um preenchida!"
    	  cSolucao:="DESEJA GRAVAR MESMO ASSIM ?"
    	  IF !U_ITMSG(_cMensagem,'Atenção!',cSolucao,3,2,3,,"GRAVAR","VOLTAR")
    	     _lRet:=.F.
    	  ENDIF
       
       ENDIF
    
    ENDIF

Endif

Return(_lRet)

/*
===============================================================================================================================
Programa----------: GRVLog
Autor-------------: Alex Wallauer
Data da Criacao---: 21/02/2024
===============================================================================================================================
Descrição---------: Grava o log com 4 colunas
===============================================================================================================================
Parametros--------: CodPod,Linha,Prob,Solucao
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function GRVLog(CodPod,Linha,Prob,Solucao)
LOCAL _aItens:={}

AADD(_aItens,CodPod)
AADD(_aItens,Linha)
AADD(_aItens,Prob)
AADD(_aItens,Solucao)

AADD(_aLog,_aItens)

RETURN
