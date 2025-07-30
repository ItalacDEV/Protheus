/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 05/03/2017 | Foi aterada a validacao da TES para quando o campo C5_I_OPER não preenchido - Chamado 16784
Josué Danich  | 11/07/2018 | Incluida validação de operações não permitidas na inclusão manual - Chamado 25063
Lucas Borges  | 14/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
Julio Paz     | 10/12/2020 | Criação de função para preencher o novo campo custo net, através de gatilho de campo.Chamado 34751
Igor Melgaço  | 08/12/2022 | Novo tratamento para Pedidos de Operacao Triangular. Chamado 41604 
============================================================================================================================================================
Analista         - Programador     - Inicio     - Envio    - Chamado - Motivo da Alteração
------------------------------------------------------------------------------------------------------------------------------------------------------------
Andre Carvalho   - Igor Melgaço    - 11/06/25   - 11/07/25 - 50716   - Ajustes para busca de preço do produto na tabela Z09, para pedidos de transferência entre filiais
============================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================                                
#DEFINE _ENTER CHR(13)+CHR(10) 
#INCLUDE "RwMake.ch"

/*/
===============================================================================================================================
Programa       : AOMS058   
Autor          : Fabiano Dias           
Data da Criacao: 22/08/2011 
===============================================================================================================================
Descricao : Rotina de acionamento de gatilhos em pedidos de vendas e validações auxiliares do MT410TOK            
===============================================================================================================================
Parametros: _nOpcao = 1 - Indica que o gatilho esta sendo executado pelo campo C6_PRODUTO, ou seja na linha posicionada. 
            _nOpcao = 2 - Funcao chamada dentro da validacao do campo C5_CLIENTE, para todos os itens acols.    	
            _nOpcao = 3 - Funcao chamada de dentro do ponto de entrada MT410TOK
            _nOpcao = 4 - Funcao chamada de dentro do ponto de entrada MT410TOK
===============================================================================================================================
Retorno   : Nenhum						  							                               						
===============================================================================================================================
/*/

User Function AOMS058(_nOpcao)

Local _nPosProd  := aScan(aHeader,{|W| Upper(AllTrim(W[2])) == "C6_PRODUTO" })
Local _nPosTES   := aScan(aHeader,{|W| Upper(AllTrim(W[2])) == "C6_TES"     })
Local _nPosLoc   := aScan(aHeader,{|W| Upper(AllTrim(W[2])) == "C6_LOCAL"    })              
Local _nPCFO     := aScan(aHeader,{|W| Upper(AllTrim(W[2])) == "C6_CF"	 })
Local L			:= 0
Local _aDadosCfo:= {}
Local K			:= 0
Local _cTES     := ""      
Local _lTES     := .F.
Local _cSuframa := ""
Local _cEstCli  := "" 

Local _cEstFil  := SM0->M0_ESTCOB
Local _cCliPed  := M->C5_CLIENTE
Local _cLjCliPed:= M->C5_LOJACLI 
Local _cTpOper  := M->C5_I_OPER
Local _cRetorno := "" //Variavel criada para retornar um conteudo para o gatilho que a chamou 
Local _backupN  := ""     
Local aRotBack,cCadBack

//Grava log de execução
u_itlogacs()
                       
//==========================================================================
//Salva a posicao da linha posicionada no acols antes de executar a rotina.
//==========================================================================
If Type( "N" ) == "N"
	_backupN := n
EndIf     

//===========================================================
// Caso exista, faz uma copia do aRotina                    
//===========================================================
If Type( "aRotina" ) == "A"
	aRotBack := AClone( aRotina )
EndIf

//===========================================================
// Caso exista, faz uma copia do cCadastro                  
//===========================================================
If Type( "cCadastro" ) == "C"
	cCadBack := cCadastro
EndIf
  
//=================¿
//  Salva a area. 
//=================Ù

_aareaSC5 := SC5->(GetArea())
_aareaSC6 := SC6->(GetArea())
_aareaSC9 := SC9->(GetArea())
_aareaSM0 := SM0->(GetArea())
_aareaSX2 := SX2->(GetArea())
_aareaSX3 := SX3->(GetArea())
_aareaSX7 := SX7->(GetArea())
_aareaSA1 := SA1->(GetArea())
_aareaSB1 := SB1->(GetArea())
_aareaSB2 := SB2->(GetArea())
_aareaSE4 := SE4->(GetArea())
                
//===============================================================
//Condicao abaixo para checar um retorno que deve ser fornecido 
//para o gatilho para chamar esta funcao.                       
//===============================================================
_cRetorno:= .T.

If _nopcao == 2 //Valida operações não permitidas para inclusão manual

	If M->C5_I_OPER $ u_itgetmv("ITOPERBLQ","05") .and. (Inclui .or. Altera) .and. !l410auto
	
		U_ITMSG('Operação ' + M->C5_I_OPER + ' não permitida para inclusão manual',"Atenção",,1)
		Return .F.
		
	Endif

Endif

If _nOpcao == 1//Indica que o gatilho esta sendo executado pelo campo C6_PRODUTO, ou seja na linha posicionada. 
	
	_cRetorno:= aCols[n,_nPosProd] 
		               		
ElseIF cFilAnt = "91" .AND. !Empty(M->C5_CLIENTE) .AND. (_nOpcao = 2 .OR. _nOpcao = 4)//AWF - Foi incluída novas validacoes para o Desconto PIS e COFINS Vendas Manaus. Chamado: 16998
                                                       //_nOpcao = 2 - Funcao chamada dentro da validacao do campo C5_CLIENTE
                                                       //_nOpcao = 4 - Funcao chamada de dentro do ponto de entrada MT410TOK
    _lMV_DESZFPC:=GetMv("MV_DESZFPC")
    _cEstado    :=POSICIONE("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_EST")
    _cMunicipio :=POSICIONE("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_COD_MUN")
    
    lCalc:=(POSICIONE("CC2",1,xFilial("CC2")+_cEstado+_cMunicipio,"CC2_I_CALC") = "1")

    _lTem_Item :=.F.
    _lITodosSim:=.T.
    _lITodosNao:=.T.
    FOR L := 1 TO LEN(aCols)
	    IF aTail(aCols[L])//aCols[L,len(aHeader)+1] // Se Linha Deletada
	       LOOP
	    ENDIF
	    _cCodItem:= aCols[L,_nPosProd] 
	    IF EMPTY(_cCodItem)
	       LOOP
	    ENDIF
        _lTem_Item:=.T.
	    _lSim:=(POSICIONE("SB1",1,xFilial("SB1")+_cCodItem,'B1_I_CALC') = "1")
	    IF _lSim
           _lITodosNao:=.F.
	    ELSE
           _lITodosSim:=.F.
	    ENDIF
    NEXT

    lITemDiferente:=.F.
    IF !_lITodosSim .AND. !_lITodosNao//Se os 2 tiver Falso é que tem item diferente
       lITemDiferente:=.T.
    ENDIF

    IF lCalc .and. lITemDiferente//Se nao tiver itens não vai entrar nunca aqui//OK 
    
       U_MT_ITMSG("Conteudo Atual: "+IF(_lMV_DESZFPC,"Habilitado","Desabilitado")+_ENTER+;
              "O pedido contém produtos com dois grupos de Desconto Suframa diferentes: ICMS e ICMS + PIS COFINS, é necessário que: "+_ENTER+;
              "Informe somente um grupo de desconto, caso necessário faça dois pedidos separados, um só com desconto ICMS e outros com os dois descontos",;
              'Atenção! Ped.:'+M->C5_NUM,,1)

       IF _nOpcao = 4//Quando for _nOpcao = 2 nao retorna falso Só avisa
          _cRetorno:= .F.
       ENDIF
    
    ELSEIF _lMV_DESZFPC .AND. !lCalc//Entra aqui indenpendente de ter itens ou nao //OK

       u_itmsg("Conteudo Atual: "+IF(_lMV_DESZFPC,"Habilitado","Desabilitado")+_ENTER+;
              "O municipio do cliente pertence a uma área da Zona Franca de Manaus, é necessário que o desconto do PIS e COFINS seja desabilitado na"+_ENTER+;
              "Rotina 'Desconto P/C ZF'",;
              'Atenção! Ped.:'+M->C5_NUM,,1)
       
       IF _nOpcao = 4//Quando for _nOpcao = 2 nao retorna falso Só avisa
          _cRetorno:= .F.
       ENDIF

    ELSEIF !_lTem_Item //Se nao tiver itens nao valida os proximos IFs ainda, só no OK final //OK

    ELSEIF !_lMV_DESZFPC .AND. lCalc .and. _lITodosNao //OK

       u_itmsg("Conteudo Atual: "+IF(_lMV_DESZFPC,"Habilitado","Desabilitado")+_ENTER+;
              "O municipio do cliente pertence a uma área de livre comércio, é necessário que o desconto do PIS e COFINS seja habilitado na "+_ENTER+;
              "Rotina 'Desconto P/C ZF'",;
              'Atenção! Ped.:'+M->C5_NUM,,1)

       IF _nOpcao = 4//Quando for _nOpcao = 2 nao retorna falso Só avisa
          _cRetorno:= .F.
       ENDIF

    ELSEIF _lMV_DESZFPC .AND. lCalc .and. _lITodosSim //OK

       u_itmsg("Conteudo Atual: "+IF(_lMV_DESZFPC,"Habilitado","Desabilitado")+_ENTER+;
              "O(s) produto(s) informado(s) no pedido só podem ser comercializados com o desconto de ICMS Suframa, é necessário que o desconto do PIS e COFINS seja desabilitado na "+;
              "Rotina 'Desconto P/C ZF'",;
              'Atenção! Ped.:'+M->C5_NUM,,1)

       IF _nOpcao = 4//Quando for _nOpcao = 2 nao retorna falso Só avisa
          _cRetorno:= .F.
       ENDIF

    ENDIF
    
EndIf 

IF _nOpcao = 4//Funcao chamada de dentro do ponto de entrada MT410TOK
   Return _cRetorno
ENDIF


//====================================================================
//Somente sera realizada uma consulta no banco para verificar uma TES
//quando os campos: C5_I_OPER, C5_CLIENTE e C5_LOJACLI estiverem     
//preenchidos e somente para pedidos do tipo normal.                 
//====================================================================
//Para o M->C5_TIPO = 'B' o _cTpOper vai estar em branco e o M->C5_TIPO = 'N' vai esta preenchido
//If ( !EMPTY(_cTpOper) .OR. (M->C5_TIPO = 'B' .AND. _lExistCpo) ) .AND. !EMPTY(_cCliPed) .AND. !EMPTY(_cLjCliPed) .AND. M->C5_TIPO $ 'N,B'          	
If !EMPTY(_cTpOper) .AND. !EMPTY(_cCliPed) .AND. !EMPTY(_cLjCliPed) .AND. M->C5_TIPO $ 'N,B'

	dbSelectArea(IF( M->C5_TIPO = 'B' , "SA2","SA1" ))
	dbSetOrder(1)
	If MsSeek(xFilial() + _cCliPed + _cLjCliPed)					  				

       IF M->C5_TIPO = 'B'//Fornecedor
		  _cSuframa:= ""
		  _cEstCli := SA2->A2_EST
       ELSE
		  _cSuframa:= SA1->A1_SUFRAMA
		  _cEstCli := SA1->A1_EST
       ENDIF
		
		//====================================
		//Veirifica se o cliente tem suframa.
		//====================================
		If !EMPTY(_cSuframa)//O campo de Suframa não é "sim" ou "nao" é um código
			_cSuframa:= "S"
		Else  
			_cSuframa:= "N"
		EndIf 
		
		//=========================================================
		//Gatilho executado no campo C6_PRODUTO, ou seja, na linha
		//que o usuario esteja posicionado no momento.            
		//=========================================================
		If _nOpcao == 1	         
					          			         		
			//=======================================
			//Verifica se a linha nao esta deletada.
			//=======================================
			If !aTail(aCols[n])
			
				_cTES:= u_selectTES(aCols[n,_nPosProd],_cSuframa,_cEstCli,_cEstFil,_cCliPed,_cLjCliPed,_cTpOper,aCols[n,_nPosLoc],M->C5_TIPO)
				                			
				//======================================
				//Passa a TES selecionada para o aCols.
				//======================================
				aCols[n,_nPosTES]:= _cTES  
				                                                  				
				//===========================================================================================================================
				//Limpa a CFOP para caso ja tenha gerado um numero de CFOP e depois passe um produto que nao foi encontrado TES inteligente.
				//===========================================================================================================================
				aCols[n,_nPCFO] := Space(TamSX3("C6_CF     ")[1]) 
				
				//=========================================================================
				//Posiciona os registros                                                  
				//=========================================================================
				dbSelectArea(IIF(M->C5_TIPO$"DB","SA2","SA1"))
				dbSetOrder(1)
				If MsSeek(xFilial() + _cCliPed + _cLjCliPed)					  				
				
					dbSelectArea("SF4") 
					SF4->(dbSetOrder(1))
					If SF4->(dbSeek(xFilial("SF4") + _cTES))     
					
						Aadd(_aDadosCfo,{"OPERNF","S"})
					 	Aadd(_aDadosCfo,{"TPCLIFOR",M->C5_TIPOCLI})					
					 	Aadd(_aDadosCfo,{"UFDEST",Iif(M->C5_TIPO $ "DB",SA2->A2_EST,SA1->A1_EST)})
					 	Aadd(_aDadosCfo,{"INSCR" ,If(M->C5_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)})
					 	
						aCols[n,_nPCFO] := MaFisCfo(,SF4->F4_CF,_aDadosCfo)
					
					EndIf    
				
				EndIf
												            								                            
				//==========================================================================
				//Para executar os gatilhos via ADVPL proceda com a seguinte sintaxe abaixo
				//==========================================================================
				//==============================================================================================================================
				//A funcao runtrigger executa todos os gatilhos para determinado campo                                                         
				//o n sera a posicao atual na getdados, pode ser a variavel N ou um endereço de for/next dependendo da sua necessidade			
				//para executar gatilhos na enchoice vc troca o parametro 2 para 1 e nao passa posicao de Acols                                
				//==============================================================================================================================
				If ExistTrigger('C6_TES    ')  
				   RunTrigger(2,n,nil,,'C6_TES    ')  
				EndIf		   														
								 												                         				
				//==============================================
				//Caso nao tenha econtrado uma TES inteligente.
				//==============================================
				If _cTES == Space(03) .AND. !IsInCallStack('MSEXECAUTO')
				
					u_itmsg(	"Não existe nenhuma regra de TES Inteligente cadastrada para: "+CHR(13)+CHR(10)+;
								"Filial / Estado / Operacao: "+cFilAnt+" / "+_cEstFil+" / "+_cTpOper+CHR(13)+CHR(10)+;
								"Cliente / Loja / Est. / Suframa: "+_cCliPed+" / "+_cLjCliPed+" / "+_cEstCli+" / "+_cSuframa+CHR(13)+CHR(10)+;
								"Produto / Armazem: "+AllTrim(aCols[n,_nPosProd])+" / "+aCols[n,_nPosLoc],'Atenção! Ped.:'+M->C5_NUM,;
								"Comunicar Departamento Fiscal de tal ocorrência para que seja efetuado o cadastro da TES Inteligente (Customizado) liberando assim a digitação do pedido.",1)
				EndIf 
			
			EndIf
			
			//========================================================================
			//Gatilho executado no campo C5_CLIENTE ou no botao OK do pedido         
			//de venda que percorrera todo o acols para checar os produtos fornecidos
			//no pedido de venda para constatar se existe TES Inteligente.           
			//========================================================================
		Else                           
			
				For k:=1 to Len(aCols)			      
					//=======================================
					//Verifica se a linha nao esta deletada.
					//=======================================
					If !aTail(aCols[k])	.And. Len(AllTrim(aCols[k,_nPosProd])) > 0
					  
						_cTES:= u_selectTES(aCols[k,_nPosProd],_cSuframa,_cEstCli,_cEstFil,_cCliPed,_cLjCliPed,_cTpOper,aCols[k,_nPosLoc],M->C5_TIPO)
						
						//======================================
						//Passa a TES selecionada para o aCols.
						//======================================
						aCols[k,_nPosTES]:= _cTES   
				
						//===========================================================================================================================
						//Limpa a CFOP para caso ja tenha gerado um numero de CFOP e depois passe um produto que nao foi encontrado TES inteligente.
						//===========================================================================================================================
						aCols[k,_nPCFO] := Space(TamSX3("C6_CF     ")[1]) 
						
						//=========================================================================
						//Posiciona os registros                                                  
						//=========================================================================
						dbSelectArea(IIF(M->C5_TIPO$"DB","SA2","SA1"))
						dbSetOrder(1)
						If MsSeek(xFilial() + _cCliPed + _cLjCliPed)							  				
						
							dbSelectArea("SF4") 
							SF4->(dbSetOrder(1))
							If SF4->(dbSeek(xFilial("SF4") + _cTES))     
							
								Aadd(_aDadosCfo,{"OPERNF","S"})
							 	Aadd(_aDadosCfo,{"TPCLIFOR",M->C5_TIPOCLI})					
							 	Aadd(_aDadosCfo,{"UFDEST",Iif(M->C5_TIPO $ "DB",SA2->A2_EST,SA1->A1_EST)})
							 	Aadd(_aDadosCfo,{"INSCR" ,If(M->C5_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)}) 
							 	
							 	t := n
							 	n := k //Reposiciona o n para que a mafiscfo ajuste o acols correto
								aCols[k,_nPCFO] := MaFisCfo(,SF4->F4_CF,_aDadosCfo)
								n := t  
							
							EndIf      
						
						EndIf
						
						//==========================================================================
						//Para executar os gatilhos via ADVPL proceda com a seguinte sintaxe abaixo
						//==========================================================================
						//==============================================================================================================================
						//A funcao runtrigger executa todos os gatilhos para determinado campo                                                         
						//o n sera a posicao atual na getdados, pode ser a variavel N ou um endereço de for/next dependendo da sua necessidade			
						//para executar gatilhos na enchoice vc troca o parametro 2 para 1 e nao passa posicao de Acols                                
						//==============================================================================================================================
						t := n
						n := k //Reposiciona o n para que a mafiscfo ajuste o acols correto
											
						If ExistTrigger('C6_TES    ')  
						   RunTrigger(2,k,nil,,'C6_TES    ')  
						EndIf	
						
						n := t 			
												
						//==============================================
						//Caso nao tenha econtrado uma TES inteligente.
						//==============================================
						If _cTES == Space(03) 
						     
							_lTES:= .T.          
							     							
							//=====================================================
							//Opcao chamada de dentro do ponto de entrada MT410TOK
							//=====================================================
							If _nOpcao == 3
								_cRetorno:= .F.
							EndIf
						
						EndIf
					
					EndIf
				
				Next k	
		EndIf          

	EndIf

	//==================================================================
	//Caso nao tenha encontrado uma regra de TES inteligente para quando
	//percorrer todo o acols.                                           
	//==================================================================
	If _lTES .And. _nOpcao == 2  .and. !l410Auto
	
		u_itmsg("Existe(m) produto(s) sem uma regra de TES INTELIGENTE cadastrada, este(s) produto(s) encontra(m)-se com a TES em branco.",'Atenção! (AOMS058) Ped.:'+M->C5_NUM,;
					"Favor solicitar ao responsável pelo cadastramento das regras de TES INTELIGENTE para efetuar a inserção dos itens que se encontram com a TES em branco.",1)       
	
	EndIf   	
	        	
	//=================================================
	//Funcao para realiazar a atualizacao da GETDADOS.
	//=================================================
	If !l410Auto
		GetdRefresh()   
	EndIf
	                 			
EndIf

If _nOpcao == 2
	U_AOMS058X(_cTpOper,M->C5_FILIAL)
EndIf

//====================================================
//restaura a posicao de n antes de executar a rotina.
//====================================================
If ValType( _backupN ) == "N"
	n := _backupN
EndIf	
   
//===================================================================
// Restaura o aRotina                                               
//===================================================================
If ValType( aRotBack ) == "A"
	aRotina := AClone( aRotBack )
EndIf

//===========================================================
// Caso exista, faz uma copia do cCadastro                  
//===========================================================
If Type( "cCadBack" ) == "C"
	cCadastro := cCadBack
EndIf

//===================
// Restaura a area. 
//===================
SC5->(Restarea(_aareaSC5))
SC6->(Restarea(_aareaSC6))
SC9->(Restarea(_aareaSC9))
SM0->(Restarea(_aareaSM0))
SX2->(Restarea(_aareaSX2))
SX3->(Restarea(_aareaSX3))
SX7->(Restarea(_aareaSX7))
SA1->(Restarea(_aareaSA1))
SB1->(Restarea(_aareaSB1))
SB2->(Restarea(_aareaSB2))
SE4->(Restarea(_aareaSE4))

Return _cRetorno
 
/*/
===============================================================================================================================
Função.........: AOMS058X   
Autor..........: Igor Melgaço
Data da Criacao: 17/06/2025
===============================================================================================================================
Descricao......: Busca o preço do produto na tabela Z09, para pedidos de transferência entre filiais e cópia de pedido.
===============================================================================================================================
Parametros: _cTipoOper,_cFilOrig
===============================================================================================================================
Retorno   : Nenhum						  							                               						
===============================================================================================================================
/*/
 
User Function AOMS058X(_cTipoOper,_cFilOrig)
Local _cOpTransf := U_ITGETMV( 'IT_OPMEDIO' , "20|22" )
Local _nPosProd  := aScan(aHeader,{|W| Upper(AllTrim(W[2])) == "C6_PRODUTO" })
Local _nPosPreco := aScan(aHeader,{|W| Upper(AllTrim(W[2])) == "C6_PRCVEN"} ) 
Local _nPosPRUN  := aScan(aHeader,{|x| AllTrim(Upper(x[2]) ) == "C6_PRUNIT"} ) 
Local _cAliasZ09 := ""
Local _cFilDest  := ""
Local _cQry      := ""
Local _dData	 := CTOD("") 
Local bValPrcVen  := AVSX3('C6_PRCVEN',7) 
Local k := 0
Local t := 0
Local L := 0
Local _lContinua := .F. 
Local __ReadVarB := ""

If FWIsInCallStack("U_AOMS032")
	_lContinua := .T.
ElseIf Inclui
	_lContinua := .T.
EndIf 

If _lContinua .And. _cTipoOper $ _cOpTransf .AND. !Empty(M->C5_CLIENTE)

	_cFilDest := Alltrim(Posicione("SA1",1,xfilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"SA1->A1_I_FILOR")) //filial destino do cliente selecionado
	_dData := dDataBase

	For k := 1 To Len(aCols)
		 
		 For L := 1 To SC6->(FCount())
		    M->&(SC6->(FieldName(L))) := SC6->(FieldGet(L))
		 Next
		
 		_cAliasZ09 := GetNextAlias()
		
        _cQry := "SELECT Z09_PRECO, Z09_DESVIO, Z09.R_E_C_N_O_ AS RECNO"
        _cQry += "	FROM " + RetSqlName("Z09")+" Z09 "
        _cQry += "	WHERE Z09_CODOPE = '"+_cTipoOper+"' "
        _cQry += "	  AND Z09_CODPRO = '"+aCols[k][_nPosProd]+"' "
        _cQry += "	  AND Z09_INIVIG <= '"+DTOS(_dData)+"' "  
        _cQry += "	  AND Z09_FIMVIG >= '"+DTOS(_dData)+"' "
        _cQry += "	  AND ( Z09_FILORI = ' ' OR Z09_FILORI = '"+_cFilOrig+"' ) "
        _cQry += "	  AND ( Z09_FILDES = ' ' OR  Z09_FILDES = '"+_cFilDest+"' ) " 
        _cQry += "	  AND Z09.D_E_L_E_T_ = ' ' "
        _cQry += "	ORDER BY Z09_FILORI DESC, Z09_FILDES DESC "

        _cQry := ChangeQuery(_cQry)

        MPSysOpenQuery( _cQry,_cAliasZ09 )

        If (_cAliasZ09)->( !EOF() ) //Se achou prepara para validação
			__ReadVarB := ""
			t := n
			n := k //Reposiciona o n para que a mafiscfo ajuste o acols correto

			M->C6_PRCVEN := (_cAliasZ09)->Z09_PRECO
	        aCols[k,_nPosPreco] := M->C6_PRCVEN

            M->C6_PRUNIT:= M->C6_PRCVEN
	        aCols[n,_nPosPRUN]:=M->C6_PRUNIT

			If Type("__ReadVar") == "C"
			   __ReadVarB := __ReadVar
			Endif

			__ReadVar :="C6_PRCVEN"

			EVAL(bValPrcVen)

			If ExistTrigger('C6_PRCVEN')  
			   RunTrigger(2,n,nil,,'C6_PRCVEN')  
			EndIf
			
			__ReadVar := __ReadVarB

			n := t 	
        EndIf

		(_cAliasZ09)->( DbClosearea() )

	Next
	//=================================================
	//Funcao para realiazar a atualizacao da GETDADOS.
	//=================================================
	If Type( "l410Auto" ) == "L" 
		If !l410Auto
			GetdRefresh()   
		EndIf
	Else
		GetdRefresh()
	EndIf 
EndIf

Return 

/*/
===============================================================================================================================
Função.........: AOMS058N   
Autor..........: Julio de Paula Paz
Data da Criacao: 10/12/2020
===============================================================================================================================
Descricao......: Retorna o custo net do item de pedido de vendas.
===============================================================================================================================
Parametros: _cCampo = Campo que disparou o gatilho de cálculo do custo net.
===============================================================================================================================
Retorno   : Nenhum						  							                               						
===============================================================================================================================
/*/
 
User Function AOMS058N(_cCampo)
Local _nRet := 0
Local _nPosPrcVen 
Local _nPosPDesc  
Local _nPosPrNet  
Local _nCustoNet  := 0
 
Begin Sequence
   
   If ! (FunName() == "MATA410")
      Break
   EndIf 
   
   _nPosPrcVen := aScan(aHeader,{|W| Upper(AllTrim(W[2])) == "C6_PRCVEN"})
   _nPosPDesc  := aScan(aHeader,{|W| Upper(AllTrim(W[2])) == "C6_I_PDESC"})
   _nPosPrNet  := aScan(aHeader,{|W| Upper(AllTrim(W[2])) == "C6_I_PRNET"})              

   If AllTrim(_cCampo) == "C6_PRCVEN"
      _nRet := aCols[N,_nPosPrcVen]
   ElseIf AllTrim(_cCampo) == "C6_I_PDESC"
      _nRet := aCols[N,_nPosPDesc] 	  
   EndIf 
   
   _nCustoNet  := aCols[N,_nPosPrcVen] - ((aCols[N,_nPosPrcVen] * aCols[N,_nPosPDesc]) / 100) 

   aCols[N,_nPosPrNet] := _nCustoNet

End Sequence

Return _nRet
