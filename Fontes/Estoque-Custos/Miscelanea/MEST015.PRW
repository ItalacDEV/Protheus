/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |08/10/2024| Chamado 48465. Retirada manipulação do SX1
Lucas Borges  |07/05/2025| Chamado 50617. Corrigir chamada estática no nome das tabelas do sistema
=============================================================================================================================== 
Analista       - Programador     - Inicio     - Envio    - Chamado - Motivo de Alteração
===============================================================================================================================
Lucas          - Alex Wallauer   - 02/05/2025 - 06/05/25 - 50525   - Ajuste para remoção de diretório local C:\SMARTCLIENT\.
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: MEST015
Autor-------------: Alex Wallauer
Data da Criacao---: 17/04/2018
Descrição---------: Rotina para ajustar saldo restante na segunda UM, devido a arredondamento das casas decimais. Chamado 24536
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MEST015()

Local _bProcess    := {|oSelf| IF(U_MEST15Val(), MEST015PRC(oSelf) , .F. ) }
Local _cFunction   := "MEST015"
Local _cTitle      := "Acerto do Estoque do Almoxarifado"
Local _cDescri	   := "Rotina que realiza o acerto do estoque de saldo restante na Segunda Uunidade de Medida, devido a arredondamento das casas decimais."

Private	_cPerg     := "MEST015"

TNewProcess():New( _cFunction, _cTitle, _bProcess, _cDescri, _cPerg,,,,,,.T.)

Return()

/*
===============================================================================================================================
Programa----------: MEST015PRC
Autor-------------: Guilherme Diogo
Data da Criacao---: 23/10/2012
Descrição---------: Funcao responsavel por realizar a importacao dos dados.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MEST015PRC(oSelf)
  
Local _nRegSB1 := 0
Local _cQuery  := ""
Local _cTBSB1  := GetNextAlias()
Local _aCab    := {}
Local _aCab1   := {}
Local _aCab2   := {}
Local _aCabm3   := {}
Local _aSD3    := {}
Local _aSD31   := {}
Local _aSD32   := {}
Local _aToSD31   := {}
Local _aToSD32   := {}
Local _aToSD3    := {}
Local _aToSD3m3  := {}
Local _cCod    := ""
Local _cArmazDE:= MV_PAR01
Local _cArmazAte:=MV_PAR02
Local _cProdDE := MV_PAR03
Local _cProdAte:= MV_PAR04
Local _dDataAce:= MV_PAR06
Local _cObs    := "MOVIMENTO GERADO PELA ROTINA MEST015"
Local _nQatu   := 0
Local _nVatu1  := 0
Local _nCm1    := 0
Local _nValPos   := U_ItGetMv("IT_ACERVLR",1)
Local _lAcertaQQ1:= .F.
Local _nValNeg   := (_nValPos * -1)

Private lMsErroAuto := .F.
Private _aLog       := {} 
Private _aAnalise   := {} 
Private _cArmaz     := ""

Private _lEfetivar  := (MV_PAR07 = 1)

oSelf:SetRegua1( 2 )

MEST15LOG("","HORA DO INICIO DO PROCESSAMENTO","")
    
	_cQuery := " SELECT DISTINCT "
	_cQuery += "   B2.B2_COD     CODIGO, "
	_cQuery += "   B2.B2_LOCAL   ARMAZEM "
	_cQuery += " FROM "+RetSqlName("SB2")+" B2 "
    _cQuery += " WHERE "                    
	_cQuery += " B2.D_E_L_E_T_ = ' ' "
	_cQuery += " AND  B2.B2_FILIAL = '" + xFilial("SB2") + "'"
	IF _cArmazDE = _cArmazAte
	   _cQuery += IIf( !Empty( _cArmazDE ) , " AND B2.B2_LOCAL = '"+_cArmazDE+"' " 	, "" ) 
	ELSE	
	   _cQuery += IIf( !Empty( _cArmazDE ) , " AND B2.B2_LOCAL >= '"+_cArmazDE+"' " , "" ) 
	   _cQuery += IIf( !Empty( _cArmazAte ), " AND B2.B2_LOCAL <= '"+_cArmazAte+"' ", "" ) 
	ENDIF	
	IF _cProdDE = _cProdAte
	   _cQuery += IIf( !Empty( _cProdDE ) , " AND B2.B2_COD = '"+_cProdDE+"' " 	, "" ) 
	ELSE	
	   _cQuery += IIf( !Empty( _cProdDE ) , " AND B2.B2_COD >= '"+_cProdDE+"' " , "" ) 
	   _cQuery += IIf( !Empty( _cProdAte ), " AND B2.B2_COD <= '"+_cProdAte+"' ", "" ) 
	ENDIF
	_cQuery := ChangeQuery(_cQuery)

	
	If Select(_cTBSB1) > 0 
	 	(_cTBSB1)->( DBCloseArea() )
	EndIf
	
	oSelf:IncRegua1( "Lendo SB2..." )
	MPSysOpenQuery(_cQuery,_cTBSB1)

	oSelf:IncRegua1( "Contando SB2..." )
	
	dbSelectArea(_cTBSB1)
	COUNT TO _nRegSB1
		
	oSelf:SaveLog( "INICIO - ZERA 2UM SB2" )
    MEST15LOG("","REGISTROS ENCONTRADOS NO SB2: "+ALLTRIM(STR(_nRegSB1)),"")
	oSelf:SaveLog( "REGISTROS ENCONTRADOS: "+ALLTRIM(STR(_nRegSB1)) )
	
	If _nRegSB1 > 0
	
		oSelf:SetRegua1( _nRegSB1 )
        _cQuery := "SELECT MAX(D3_DOC) AS MAXD3DOC "
        _cQuery += " FROM " + RetSqlName("SD3") + " D3"
        _cQuery += " WHERE D3.D_E_L_E_T_ = ' ' "
        _cQuery += " AND D3.D3_FILIAL = '" + xFilial("SD3") + "'"
        _cQuery += " AND SUBSTR( D3.D3_DOC , 1 , 1 ) IN ('0','1','2','3','4','5','6','7','8','9') "
        _cD3_DOC:= ""
        _nConta := 200
        _nCont  := 0
        _cTotal := ALLTRIM(STR(_nRegSB1))
		IF MV_PAR08 = 1
		   _cEntrada:="497"
		   _cSaida  :="997"
		ELSE
		   _cEntrada:="498"
		   _cSaida  :="998"	
		ENDIF


		(_cTBSB1)->( DBGotop() )
		
		DO While (_cTBSB1)->( !Eof() )
		
			_cCod	:= (_cTBSB1)->CODIGO
			_cArmaz := (_cTBSB1)->ARMAZEM
		    _cStatus:= ""
			_cConv  := 0
			_nCont++
			IF (_nCont/10) = INT(_nCont/10)
			   oSelf:IncRegua1( "PRODUTO: "+ AllTrim(_cCod)+" / "+ALLTRIM(STR(_nCont))+" de "+_cTotal )
			ENDIF   
			
			SB1->( DBSetOrder(1) )
			SB2->( DBSetOrder(1) )
			If SB2->( DBSeek( xFilial("SB2") + _cCod + _cArmaz ) ) .AND. SB1->( DBSeek( xFilial("SB1") + _cCod ) )
			
		       aSaldos := CalcEst( _cCod , _cArmaz , _dDataAce + 1 ) //obtém o saldo final em estoque na data informada
			   _nQatu  := aSaldos[01]//SB2->B2_QATU
			   _nCm1   := aSaldos[08]//SB2->B2_CM1 
  			   _nVatu1 := ROUND(1*_nCm1,4)//SB2->B2_VATU1
			   _nQatu2N:= aSaldos[07]//Qtde 2 unidade ZERAR
			   _nValM1 := aSaldos[02]//Valor na moeda 1 * ACERTAR
			   _nValM2 := aSaldos[03]//Valor na moeda 2 ZERAR
			   _nValM3 := aSaldos[04]//Valor na moeda 3 * ACERTAR
			   _nValM4 := aSaldos[05]//Valor na moeda 4 ZERAR
			   _nValM5 := aSaldos[06]//Valor na moeda 5 ZERAR
			   _lAcertaQQ1:=EMPTY(SB1->B1_SEGUM)

               IF ( (_nQatu <> 0 .AND. !_lAcertaQQ1) .OR. (_nQatu2N = 0 .AND. _nValM1 = 0 .AND. _nValM3 = 0)) .AND. (_nValM2 = 0 .AND. _nValM4 = 0 .AND. _nValM5 = 0)
                  MEST15LOG(_cCod,"NAO PODE/PRECISA DE ACERTO: "+ALLTRIM(STR(_nQatu  ))+" de 1a UM / "+;
                                                                 ALLTRIM(STR(_nQatu2N))+" de 2a UM / Valor da Moeda 1 ("+;
                                                                 ALLTRIM(STR(_nValM1 ))+") / Valor da Moeda 2 ("+;
                                                                 ALLTRIM(STR(_nValM2 ))+") / Valor da Moeda 3 ("+;
                                                                 ALLTRIM(STR(_nValM3 ))+") / Valor da Moeda 4 ("+;
                                                                 ALLTRIM(STR(_nValM4 ))+") / Valor da Moeda 5 ("+;
                                                                 ALLTRIM(STR(_nValM5 ))+") / "+IF(_lAcertaQQ1,"Sem 2o UM","com 2o UM") , "" )
                  (_cTBSB1)->( DBSKIP() )
                  LOOP
               ENDIF

               IF _nConta >= 200 .AND. _lEfetivar
				   _cQuery := ChangeQuery(_cQuery)
					MPSysOpenQuery(_cQuery,"SD3T")
                  IF SD3T->( !Eof() )
                     _cD3_DOC:=SOMA1(SD3T->MAXD3DOC)
                  ENDIF
	              SD3T->( DBCloseArea() )
                  _nConta:=0
                  MEST15LOG("","Numero do Documento Gerado: "+_cD3_DOC,"")
               ENDIF		    

		    
// **********************************************************   ACERTA QTDE 2 UM  **************************************************************
				If _nQatu2N > 0 .AND. (_nQatu = 0 .OR. _lAcertaQQ1)
					
                    MEST15LOG(_cCod,"Com 2a UM Positiva","")
                    _aCab1 := {}
					_aSD31 := {}

                    _aCab2 := {}
					_aSD32 := {}
					

					SD3->( DBSetOrder(3) )

						_aCab1 := {	{ "D3_FILIAL"	, xFilial("SD3")	, Nil },;
									{ "D3_TM"		, _cEntrada		    , NIL },;//ENTRADA
									{ "D3_DOC"		, _cD3_DOC			, NIL },;
									{ "D3_EMISSAO"	, _dDataAce			, NIL } }
                     IF MV_PAR08 = 1
  						_aSD31 := {	{ "D3_COD"		, _cCod				, NIL },;
									{ "D3_LOCAL"	, _cArmaz			, NIL },;
									{ "D3_QUANT"	, 1					, NIL },;
									{ "D3_CUSTO1"	, _nVatu1			, NIL },;
									{ "D3_CUSTO3"	, _nVatu1			, NIL },; 
									{ "D3_QTSEGUM"	, 0      			, NIL },;//ZERAR
									{ "D3_I_OBS"    , _cObs				, NIL } }
                     ELSE 						
						_aSD31 := {	{ "D3_COD"		, _cCod				, NIL },;
									{ "D3_LOCAL"	, _cArmaz			, NIL },;
									{ "D3_QUANT"	, 1					, NIL },;
									{ "D3_QTSEGUM"	, 0      			, NIL },;//ZERAR
									{ "D3_I_OBS"    , _cObs				, NIL } }
                     ENDIF   
						_aCab2 := {	{ "D3_FILIAL"	, xFilial("SD3")	, Nil },;
									{ "D3_TM"		, _cSaida		    , NIL },;//SAIDA
									{ "D3_DOC"		, _cD3_DOC			, NIL },;
									{ "D3_EMISSAO"	, _dDataAce			, NIL } }

                     IF MV_PAR08 = 1
						_aSD32 := {	{ "D3_COD"		, _cCod				, NIL },;
									{ "D3_LOCAL"	, _cArmaz			, NIL },;
									{ "D3_QUANT"	, 1					, NIL },;//TIRAR
									{ "D3_CUSTO1"	, _nVatu1			, NIL },;
									{ "D3_CUSTO3"	, _nVatu1			, NIL },; 
									{ "D3_QTSEGUM"	, _nQatu2N			, NIL },;
									{ "D3_I_OBS"    , _cObs				, NIL } }
                     ELSE
						_aSD32 := {	{ "D3_COD"		, _cCod				, NIL },;
									{ "D3_LOCAL"	, _cArmaz			, NIL },;
									{ "D3_QUANT"	, 1					, NIL },;//TIRAR
									{ "D3_QTSEGUM"	, _nQatu2N			, NIL },;
									{ "D3_I_OBS"    , _cObs				, NIL } }
                     ENDIF

                        AADD(_aToSD31,_aSD31)
                        AADD(_aToSD32,_aSD32)

						BEGIN TRANSACTION

   			                MEST15SB1(.F.,_cCod,_aLog)
						
							lMsErroAuto := .F.
							
							IF _lEfetivar

                               MSExecAuto( {|x,y,z| mata241(x,y,z) } , _aCab1 , _aToSD31 , 3 ) //Inclusao
							
							ENDIF
							   
							
							If lMsErroAuto
								
						       _cErro:=""
						       If MV_PAR05 == 2
							      MOSTRAERRO()
						       ELSE
						          _cErro:=" ["+MostraErro(Upper(GetSrvProfString("STARTPATH","")),"MEST015.LOG")+"]"			
						       EndIf
								
								oSelf:SaveLog(	"QP-ERRO AO PROCESSAR O PRODUTO " + AllTrim(_cCod)+_cErro )
                                MEST15LOG(_cCod,"QP-ERRO AO PROCESSAR MSExecAuto 1/2",_cErro)
								DisarmTransaction()

                            ELSE

                                MEST15LOG(_cCod,"Entrou 0 de 2a UM","")

							    lMsErroAuto := .F.
  							    
  							    IF _lEfetivar

							       MSExecAuto( {|x,y,z| mata241(x,y,z) } , _aCab2 , _aToSD32 , 3 ) //Inclusao

							    ENDIF   
							
							    If lMsErroAuto
								
						           _cErro:=""
						           If MV_PAR05 == 2
							          MOSTRAERRO()
						           ELSE
						              _cErro:=" ["+MostraErro(Upper(GetSrvProfString("STARTPATH","")),"MEST015.LOG")+"]"			
						           EndIf
								
								    oSelf:SaveLog(	"QP-ERRO AO PROCESSAR O PRODUTO " + AllTrim(_cCod)+_cErro )
                                    MEST15LOG(_cCod,"QP-ERRO AO PROCESSAR MSExecAuto 2/2",_cErro)
								    DisarmTransaction()
                                ELSE
                                     MEST15LOG(_cCod,"Saiu "+ALLTRIM(STR(_nQatu2N))+" de 2a UM","")
                                    _nConta++
						    	EndIf
					    	
					    	EndIf

   			                MEST15SB1(.T.,_cCod,_aLog)
						
						END TRANSACTION
					
				ElseIf _nQatu2N < 0 .AND. (_nQatu = 0 .OR. _lAcertaQQ1)
					    
                        MEST15LOG(_cCod,"Com 2a UM Negativa","")
						_aCab1 := {}
                        _aSD31 := {}

                        _aCab2 := {}
						_aSD32 := {}
						_nQtdeNew:=(_nQatu2N*-1)
							 
						SD3->( DBSetOrder(3) )

                        _aCab1 := {	{ "D3_FILIAL"	, xFilial("SD3")	, Nil },;
									{ "D3_TM"		, _cEntrada			, NIL },;//ENTRADA
									{ "D3_DOC"		, _cD3_DOC			, NIL },;
									{ "D3_EMISSAO"	, _dDataAce			, NIL } }

                     IF MV_PAR08 = 1
						_aSD31 := {	{ "D3_COD"		, _cCod				, NIL },;
									{ "D3_LOCAL"	, _cArmaz			, NIL },;
									{ "D3_QUANT"	, 1					, NIL },;
									{ "D3_CUSTO1"	, _nVatu1			, NIL },;
									{ "D3_CUSTO3"	, _nVatu1			, NIL },; 
									{ "D3_QTSEGUM"	, _nQtdeNew     	, NIL },;
									{ "D3_I_OBS"    , _cObs				, NIL } }
					 ELSE
						_aSD31 := {	{ "D3_COD"		, _cCod				, NIL },;
									{ "D3_LOCAL"	, _cArmaz			, NIL },;
									{ "D3_QUANT"	, 1					, NIL },;
									{ "D3_QTSEGUM"	, _nQtdeNew     	, NIL },;
									{ "D3_I_OBS"    , _cObs				, NIL } }
					 ENDIF
						

						_aCab2 := {	{ "D3_FILIAL"	, xFilial("SD3")	, Nil },;
									{ "D3_TM"		, _cSaida			, NIL },;//SAIDA
									{ "D3_DOC"		, _cD3_DOC			, NIL },;
									{ "D3_EMISSAO"	, _dDataAce			, NIL } }

                     IF MV_PAR08 = 1
						_aSD32 := {	{ "D3_COD"		, _cCod				, NIL },;
									{ "D3_EMISSAO"	, _dDataAce			, NIL },;
									{ "D3_LOCAL"	, _cArmaz			, NIL },;
									{ "D3_QUANT"	, 1					, NIL },;
									{ "D3_CUSTO1"	, _nVatu1			, NIL },;
									{ "D3_CUSTO3"	, _nVatu1			, NIL },; 
									{ "D3_QTSEGUM"	, 0   				, NIL },;
									{ "D3_I_OBS"    , _cObs				, NIL } }
					 ELSE
						_aSD32 := {	{ "D3_COD"		, _cCod				, NIL },;
									{ "D3_EMISSAO"	, _dDataAce			, NIL },;
									{ "D3_LOCAL"	, _cArmaz			, NIL },;
									{ "D3_QUANT"	, 1					, NIL },;
									{ "D3_QTSEGUM"	, 0   				, NIL },;
									{ "D3_I_OBS"    , _cObs				, NIL } }
					 ENDIF
						
                        AADD(_aToSD31,_aSD31)
                        AADD(_aToSD32,_aSD32)

						BEGIN TRANSACTION
						
   			                MEST15SB1(.F.,_cCod,_aLog)

							lMsErroAuto := .F.
							IF _lEfetivar

                               MSExecAuto( {|x,y,z| mata241(x,y,z) } , _aCab1 , _aToSD31 , 3 ) //Inclusao
							   
							ENDIF   
							
							If lMsErroAuto
						       _cErro:=""
						       If MV_PAR05 == 2
							      MOSTRAERRO()
						       ELSE
						          _cErro:=" ["+MostraErro(Upper(GetSrvProfString("STARTPATH","")),"MEST015.LOG")+"]"			
						       EndIf
								
								oSelf:SaveLog(	"QN-ERRO AO PROCESSAR O PRODUTO " + AllTrim(_cCod)+_cErro )
                                MEST15LOG(_cCod,"QN-ERRO AO PROCESSAR MSExecAuto 1/2",_cErro)
								DisarmTransaction()
								
                            ELSE
							
                               MEST15LOG(_cCod,"Entrou "+ALLTRIM(STR(_nQatu2N))+" de 2a UM","")

							   IF _lEfetivar

                                  MSExecAuto( {|x,y,z| mata241(x,y,z) } , _aCab2 , _aToSD32 , 3 ) //Inclusao
							      
							   ENDIF   
							
								If lMsErroAuto
						       	   _cErro:=""
						       	   If MV_PAR05 == 2
							   	      MOSTRAERRO()
						       	   ELSE
						              _cErro:=" ["+MostraErro(Upper(GetSrvProfString("STARTPATH","")),"MEST015.LOG")+"]"			
						           EndIf
								
								   oSelf:SaveLog("QN-ERRO AO PROCESSAR O PRODUTO " + AllTrim(_cCod)+_cErro )
                                   MEST15LOG(_cCod,"QN-ERRO AO PROCESSAR MSExecAuto 2/2",_cErro)

								   DisarmTransaction()
								
                                 ELSE
                                   MEST15LOG(_cCod,"Saiu 0 de 2a UM","")
                                   _nConta++
  							     EndIf
							
							EndIf

   			                MEST15SB1(.T.,_cCod,_aLog)
						
						END TRANSACTION
				ELSE

                   MEST15LOG(_cCod,"Com quantidade zerada na 2a UM","")

                ENDIF
// **********************************************************   ACERTA QTDE 2 UM  **************************************************************

// **********************************************************   ACERTA VALORES 1 E 2 **************************************************************
				IF (_nValM1 <> 0 .OR. _nValM3 <> 0)  .AND. _nQatu = 0 .AND. MV_PAR08 = 1
                     //_nValM1 := aSaldos[02]//Valor na moeda 1 * ACERTAR
			         //_nValM3 := aSaldos[04]//Valor na moeda 3 * ACERTAR

					 _aSD3   := {}
					 _aSD3m3 := {}
					 _cTM1 := ""
					 _cTM2 := ""
					 SD3->( DBSetOrder(3) )
                     
                     IF (_nValM1 < 0 .AND. _nValM3 <= 0) .AND. (_nValM1 < _nValPos .AND. _nValM1 > _nValNeg)//Dentro do limite
                         


                        MEST15LOG(_cCod,"Com Valores Moedas 1 e 3 Negativos dentro do limite + "+ALLTRIM(STR(_nValNeg)),"")

					    _nValM1 := _nValM1 * -1
					    _nValM3 := _nValM3 * -1
                        _cTM1   := _cEntrada//ENTRADA

                        _aCab:= {   { "D3_FILIAL", xFilial("SD3")	    , Nil },;
									{ "D3_TM"		, _cEntrada			, NIL },; //ENTRADA
									{ "D3_DOC"		, _cD3_DOC			, NIL },;
									{ "D3_EMISSAO"	, _dDataAce			, NIL } }                                      

						_aSD3 := {	{ "D3_COD"		, _cCod				, NIL },;
									{ "D3_LOCAL"	, _cArmaz			, NIL },;
									{ "D3_CUSTO1"	, _nValM1			, NIL },;
									{ "D3_CUSTO3"	, _nValM3			, NIL },; 
									{ "D3_I_OBS"    , _cObs				, NIL } } 
									
						AADD(_aToSD3,_aSD3)
                        
					 ELSEIF (_nValM1 > 0 .AND. _nValM3 >= 0)  .AND.  (_nValM1 < _nValPos .AND. _nValM1 > _nValNeg)//Dentro do limite

                        MEST15LOG(_cCod,"Com Valores Moedas 1 e 3 Positivos  dentro do limite + "+ALLTRIM(STR(_nValNeg)),"")

                        _cTM1   := _cSaida//SAIDA

                        _aCab:= {   { "D3_FILIAL", xFilial("SD3")	    , Nil },;
									{ "D3_TM"		, _cSaida			, NIL },; //SAIDA
									{ "D3_DOC"		, _cD3_DOC			, NIL },;
									{ "D3_EMISSAO"	, _dDataAce			, NIL } }

						_aSD3 := {	{ "D3_COD"		, _cCod				, NIL },;
									{ "D3_LOCAL"	, _cArmaz			, NIL },;
									{ "D3_CUSTO1"	, _nValM1			, NIL },;
									{ "D3_CUSTO3"	, _nValM3			, NIL },; 
									{ "D3_I_OBS"    , _cObs				, NIL } }
                       
                       AADD(_aToSD3,_aSD3)
					 ELSE
                        //Só iguala a M3
		                IF _nValM1 <> _nValM3 .AND. (_nValM1 = 0 .OR. (_nValM1 >= _nValPos .AND. _nValM1 <= _nValNeg))//Diferente e (Zerado M1 ou Fora do limite)

                           MEST15LOG(_cCod,"Valor da Moeda 1 ("+ALLTRIM(STR(_nValM1))+") fora do limite de acerto ( + "+ALLTRIM(STR(_nValNeg))+")","")
                           MEST15LOG(_cCod,"Valor da Moeda 1 ("+ALLTRIM(STR(_nValM1))+") diferente da Moeda 3 ("+ALLTRIM(STR(_nValM3))+")","")
                              
                           IF _nValM3 > _nValM1//MAIOR
                              _nValM3:=(_nValM3-_nValM1)
                              _cTM1  :=_cSaida//SAIDA
                              _cTM2  :=_cEntrada//ENTRADA

                           ELSEIF _nValM3 < _nValM1//MENOR
                              _nValM3:=(_nValM1-_nValM3)
                              _cTM1  :=_cEntrada//ENTRADA
                              _cTM2  :=_cSaida//SAIDA
                           ENDIF
                           _nValM1:=0.1//Só iguala a M3

                           MEST15LOG(_cCod,"Lançamentos 1 / 2 : "+_cTM1+" / "+_cTM2+" - Valor de Acerto: ("+ALLTRIM(STR(_nValM3))+")","")
					      
                           _aCab:= { { "D3_FILIAL", xFilial("SD3")	    , Nil },;
									{ "D3_TM"		, _cTM1				, NIL },;
									{ "D3_DOC"		, _cD3_DOC			, NIL },;
									{ "D3_EMISSAO"	, _dDataAce			, NIL } }
						   
                           _aSD3:= {{ "D3_COD"		, _cCod				, NIL },;
									{ "D3_LOCAL"	, _cArmaz			, NIL },;
									{ "D3_CUSTO1"	, _nValM1  			, NIL },;
									{ "D3_CUSTO3"	, _nValM3			, NIL },; 
									{ "D3_I_OBS"    , _cObs				, NIL } }

                           _aCabm3:= { { "D3_FILIAL", xFilial("SD3")	    , Nil },;
									{ "D3_TM"		, _cTM2				, NIL },;
									{ "D3_DOC"		, _cD3_DOC			, NIL },;
									{ "D3_EMISSAO"	, _dDataAce			, NIL } }

						   _aSD3m3:={{ "D3_COD"		, _cCod				, NIL },;
									{ "D3_LOCAL"	, _cArmaz			, NIL },;
									{ "D3_CUSTO1"	, _nValM1  			, NIL },;
									{ "D3_I_OBS"    , _cObs				, NIL } }

		                   AADD(_aToSD3,_aSD3)
                           AADD(_aToSD3m3,_aSD3m3)
                        //zera as moedas 1 e 3 
		                ELSEIF _nValM1 <> _nValM3 .AND.  (_nValM1 < _nValPos .AND. _nValM1 > _nValNeg)//Dentro do limite e um positivo e outro negatico

                           MEST15LOG(_cCod,"Valor da Moeda 1 ("+ALLTRIM(STR(_nValM1))+") dentro do limite de acerto ( + "+ALLTRIM(STR(_nValNeg))+")","")
                           MEST15LOG(_cCod,"Valor da Moeda 1 ("+ALLTRIM(STR(_nValM1))+") diferente da Moeda 3 ("+ALLTRIM(STR(_nValM3))+")","")
                              
                           IF _nValM3 > 0 .AND. _nValM1 < 0
                              _cTM1  :=_cSaida//SAIDA
                              _cTM2  :=_cEntrada//ENTRADA

                           ELSEIF _nValM3 < 0 .AND. _nValM1 > 0
                              _cTM1  :=_cEntrada//ENTRADA
                              _cTM2  :=_cSaida//SAIDA
                           ENDIF

                           IF !EMPTY(_cTM1)
                              MEST15LOG(_cCod,"Lançamentos 1 / 2 : "+_cTM1+" / "+_cTM2+" - Valores da Moeda 1 / 3 ("+ALLTRIM(STR(_nValM1))+") / ("+ALLTRIM(STR(_nValM3))+")","")

						      _aCab:= { { "D3_FILIAL", xFilial("SD3")	    , Nil },;
    									{ "D3_TM"		, _cTM1				, NIL },;
    									{ "D3_DOC"		, _cD3_DOC			, NIL },;
    									{ "D3_EMISSAO"	, _dDataAce			, NIL } }

						      _aSD3:= { { "D3_COD"		, _cCod				, NIL },;
    									{ "D3_LOCAL"	, _cArmaz			, NIL },;
    									{ "D3_CUSTO1"	, 1        			, NIL },;
    									{ "D3_CUSTO3"	, _nValM3			, NIL },; 
    									{ "D3_I_OBS"    , _cObs				, NIL } }

						      _aCabm3:={{ "D3_FILIAL"   , xFilial("SD3")	, Nil },;
    									{ "D3_TM"		, _cTM2				, NIL },;
    									{ "D3_DOC"		, _cD3_DOC			, NIL },;
    									{ "D3_EMISSAO"	, _dDataAce			, NIL } }

						      _aSD3m3:={{ "D3_COD"		, _cCod				, NIL },;
    									{ "D3_LOCAL"	, _cArmaz			, NIL },;
    									{ "D3_CUSTO1"	, _nValM1+1			, NIL },;
    									{ "D3_I_OBS"    , _cObs				, NIL } }
                                
                                AADD(_aToSD3,_aSD3)
                                AADD(_aToSD3m3,_aSD3m3)

		                   ENDIF
		                ELSE//Fora do limite e iguais 

                           MEST15LOG(_cCod,"Valores da Moeda 1 / 3 ("+ALLTRIM(STR(_nValM1))+") / ("+ALLTRIM(STR(_nValM3))+") divergentes ou fora do limite de acerto ( + "+ALLTRIM(STR(_nValNeg))+")","")

                        ENDIF   
	                 
	                 ENDIF	
					
					 IF !EMPTY(_aSD3)
					    
					     BEGIN TRANSACTION

   			                MEST15SB1(.F.,_cCod,_aLog)
						
							lMsErroAuto := .F.
							IF _lEfetivar
  							   
  							   MSExecAuto( {|x,y,z| mata241(x,y,z) } , _aCab , _aToSD3 , 3 ) //Inclusao
							      
  							ENDIF   
							
							If lMsErroAuto
								
						       _cErro:=""
						       If MV_PAR05 == 2
							      MOSTRAERRO()
						       ELSE
						          _cErro:=" ["+MostraErro(Upper(GetSrvProfString("STARTPATH","")),"MEST015.LOG")+"]"			
						       EndIf
								
								oSelf:SaveLog(	"M_1_3-ERRO AO PROCESSAR O PRODUTO " + AllTrim(_cCod)+_cErro )
                                MEST15LOG(_cCod,"M_1_3-ERRO AO PROCESSAR MSExecAuto 1/2",_cErro)
								DisarmTransaction()

                            ELSE

                                IF _cTM1 = _cEntrada
					               MEST15LOG(_cCod,"Entrou Valores Moedas 1 e 3 : ("+ALLTRIM(STR(_nValM1))+") / ("+ALLTRIM(STR(_nValM3))+")","")
                                ELSE
					               MEST15LOG(_cCod,"Saiu Valores Moedas 1 e 3 : ("+ALLTRIM(STR(_nValM1))+") / ("+ALLTRIM(STR(_nValM3))+")","")
				                ENDIF   
                            
                                IF LEN(_aSD3m3) > 0
							
								    lMsErroAuto := .F.

							        IF _lEfetivar

                                       MSExecAuto( {|x,y,z| mata241(x,y,z) } , _aCabm3 , _aToSD3m3 , 3 ) //Inclusao
								       
								    ENDIF   
								
								    If lMsErroAuto
									
							           _cErro:=""
							           If MV_PAR05 == 2
								          MOSTRAERRO()
							           ELSE
							              _cErro:=" ["+MostraErro(Upper(GetSrvProfString("STARTPATH","")),"MEST015.LOG")+"]"			
							           EndIf
									
									   oSelf:SaveLog("M_1_3-ERRO AO PROCESSAR O PRODUTO " + AllTrim(_cCod)+_cErro )
	                                   MEST15LOG(_cCod,"M_1_3-ERRO AO PROCESSAR MSExecAuto 2/2",_cErro)
								 	   DisarmTransaction()
	
	                                ELSE
	
	                                   IF _cTM2 = _cEntrada
						                  MEST15LOG(_cCod,"Entrou Valores Moedas 1 e 3 : "+ALLTRIM(STR(_nValM1))+" / "+ALLTRIM(STR(_nValM3)),"")
	                                   ELSE
						                  MEST15LOG(_cCod,"Saiu Valores Moedas 1 e 3 : "+ALLTRIM(STR(_nValM1))+" / "+ALLTRIM(STR(_nValM3)),"")
					                   ENDIF
						    	
						    	    EndIf
						    	    
					     	    EndIf
					    	
					    	EndIf

   			                MEST15SB1(.T.,_cCod,_aLog)
						
						 END TRANSACTION
					
					ENDIF	 

				ELSE

				    MEST15LOG(_cCod,"Com Valores Moedas 1 e 3 ZERADOS","")

				ENDIF
// **********************************************************   ACERTA VALORES 1 E 2 **************************************************************

// **********************************************************   ACERTA VALORES 2, 4 e 5 **************************************************************
				IF _nValM2 <> 0 .OR. _nValM4 <> 0 .OR. _nValM5 <> 0  .AND. MV_PAR08 = 1

					 _aSD3 := {}
					 _aSD32:= {}
					 SD3->( DBSetOrder(3) )
                     
                     IF _nValM2 <= 0 .AND. _nValM4 <= 0  .AND. _nValM5 <= 0  

					    MEST15LOG(_cCod,"Valores Moedas 2, 4 e 5 Negativos","")

					    _nValM2 := _nValM2 * -1
					    _nValM4 := _nValM4 * -1
					    _nValM5 := _nValM5 * -1

						_aCab := {	{ "D3_FILIAL"	, xFilial("SD3")	, Nil },;
									{ "D3_TM"		, _cEntrada			, NIL },;//ENTRADA
									{ "D3_DOC"		, _cD3_DOC			, NIL },;
									{ "D3_EMISSAO"	, _dDataAce			, NIL } }

						_aSD3 := {	{ "D3_COD"		, _cCod				, NIL },;
									{ "D3_LOCAL"	, _cArmaz			, NIL },;
									{ "D3_CUSTO1"	, 1      			, NIL },;
									{ "D3_CUSTO2"	, _nValM2			, NIL },;
									{ "D3_CUSTO4"	, _nValM4			, NIL },; 
									{ "D3_CUSTO5"	, _nValM5			, NIL },; 
									{ "D3_I_OBS"    , _cObs				, NIL } }

                        _aCab2 := {	{ "D3_FILIAL"	, xFilial("SD3")	, Nil },;
									{ "D3_TM"		, _cSaida			, NIL },;//SAIDA
									{ "D3_DOC"		, _cD3_DOC			, NIL },;
									{ "D3_EMISSAO"	, _dDataAce			, NIL } }

						_aSD32:= {	{ "D3_COD"		, _cCod				, NIL },;
									{ "D3_LOCAL"	, _cArmaz			, NIL },;
									{ "D3_CUSTO1"	, 1      			, NIL },;
									{ "D3_I_OBS"    , _cObs				, NIL } }
                         
                         AADD(_aToSD3,_aSD3)
                         AADD(_aToSD32,_aSD32)
						
					 ELSEIF _nValM2 >= 0 .AND. _nValM4 >= 0   .AND. _nValM5 >= 0  

					    MEST15LOG(_cCod,"Valores Moedas 2, 4 e 5 Positivos","")

						_aCab := {	{ "D3_FILIAL"	, xFilial("SD3")	, Nil },;
									{ "D3_TM"		, _cSaida			, NIL },;//SAIDA
									{ "D3_DOC"		, _cD3_DOC			, NIL },;
									{ "D3_EMISSAO"	, _dDataAce			, NIL } }

						_aSD3 := {  { "D3_COD"		, _cCod				, NIL },;
									{ "D3_LOCAL"	, _cArmaz			, NIL },;
									{ "D3_CUSTO1"	, 1      			, NIL },;
									{ "D3_CUSTO2"	, _nValM2			, NIL },;
									{ "D3_CUSTO4"	, _nValM4			, NIL },; 
									{ "D3_CUSTO5"	, _nValM5			, NIL },; 
									{ "D3_I_OBS"    , _cObs				, NIL } }
						
                        _aCab2 := {	{ "D3_FILIAL"	, xFilial("SD3")	, Nil },;
									{ "D3_TM"		, _cEntrada			, NIL },;//ENTRADA
									{ "D3_DOC"		, _cD3_DOC			, NIL },;
									{ "D3_EMISSAO"	, _dDataAce			, NIL } }

						_aSD32 := {	{ "D3_COD"		, _cCod				, NIL },;
									{ "D3_LOCAL"	, _cArmaz			, NIL },;
									{ "D3_CUSTO1"	, 1      			, NIL },;
									{ "D3_I_OBS"    , _cObs				, NIL } }

                         AADD(_aToSD3,_aSD3)
                         AADD(_aToSD32,_aSD32)
					 ELSE
		             
					    MEST15LOG(_cCod,"Valores Moedas 2, 4 e 5 divergentes: "+ALLTRIM(STR(_nValM2))+" / "+ALLTRIM(STR(_nValM4))+" / "+ALLTRIM(STR(_nValM5)),"")
	                 
	                 ENDIF	

					 IF !EMPTY(_aSD3)

					     BEGIN TRANSACTION

   			                MEST15SB1(.F.,_cCod,_aLog)
						
							lMsErroAuto := .F.
							IF _lEfetivar

							   MSExecAuto( {|x,y,z| mata241(x,y,z) } , _aCab , _aToSD3 , 3 ) //Inclusao

							ENDIF   
							
							If lMsErroAuto
								
						       _cErro:=""
						       If MV_PAR05 == 2
							      MOSTRAERRO()
						       ELSE
						          _cErro:=" ["+MostraErro(Upper(GetSrvProfString("STARTPATH","")),"MEST015.LOG")+"]"			
						       EndIf
								
								oSelf:SaveLog(	"M_2_4_5-ERRO AO PROCESSAR O PRODUTO " + AllTrim(_cCod)+_cErro )
							    MEST15LOG(_cCod,"M_2_4_5-ERRO AO PROCESSAR MSExecAuto 1/2",_cErro)

								DisarmTransaction()

                            ELSE

                                IF _nValM2 < 0 
							       MEST15LOG(_cCod,"Entrou Valores Moedas 2, 4 e 5 : "+ALLTRIM(STR(_nValM2))+" / "+ALLTRIM(STR(_nValM4))+" / "+ALLTRIM(STR(_nValM5)),"")
                                ELSE
							       MEST15LOG(_cCod,"Saiu Valores Moedas 2, 4 e 5 : "+ALLTRIM(STR(_nValM2))+" / "+ALLTRIM(STR(_nValM4))+" / "+ALLTRIM(STR(_nValM5)),"")
				                ENDIF   

							    IF _lEfetivar
							       
                                   MSExecAuto( {|x,y,z| mata241(x,y,z) } , _aCab2 , _aToSD32 , 3 ) //Inclusao
							
				                ENDIF   

								If lMsErroAuto
						       	   _cErro:=""
						       	   If MV_PAR05 == 2
							   	      MOSTRAERRO()
						       	   ELSE
						              _cErro:=" ["+MostraErro(Upper(GetSrvProfString("STARTPATH","")),"MEST015.LOG")+"]"			
						           EndIf
								
								   oSelf:SaveLog("M_2_4_5-ERRO AO PROCESSAR O PRODUTO " + AllTrim(_cCod)+_cErro )
								   MEST15LOG(_cCod,"M_2_4_5-ERRO AO PROCESSAR MSExecAuto 2/2",_cErro)

								   DisarmTransaction()
								
                                ELSE 
                                
                                   IF _nValM2 < 0 
							          MEST15LOG(_cCod,"Saiu Valores Moeda 1 : 1 Real","")
                                   ELSE
							          MEST15LOG(_cCod,"Entrou Valores Moeda 1 : 1 Real","")
				                   ENDIF   
                                   _nConta++
  							   
  							    EndIf

					    	
					    	EndIf

   			                MEST15SB1(.T.,_cCod,_aLog)
						
						 END TRANSACTION
					ENDIF	 
				ELSE

		           MEST15LOG(_cCod,"Com Valores Moedas 2, 4 e 5 ZERADOS OK","")

				ENDIF
// **********************************************************   ACERTA VALORES 2 4 5 **************************************************************

			ENDIF
			
   			(_cTBSB1)->( DBSkip() )
   		
   		EndDo
   		
   		(_cTBSB1)->( DBCloseArea() )
   	
    ELSE

	    MEST15LOG(_cCod,"NAO FORAM ENCONTRADO REGISTROS PARA ESSA SELECAO","")
    
    EndIf
    
oSelf:SaveLog(	"FINAL - ZERA 2UM SB2" ) 
MEST15LOG("","HORA DO FIM DO PROCESSAMENTO","")

Processa( {|| MEST015C(_aLog) } , "Gravando dados no arquivo..." )

//Regristra log de acesso
U_ITLOGACS('MEST015')

Return .T.

/*
===============================================================================================================================
Programa----------: MEST015C
Autor-------------: Guilherme Diogo
Data da Criacao---: 23/10/2012
Descrição---------: Rotina que permite gravar o LOG referente ao processamento
Parametros--------: _aLog - registro de eventos a ser salvo
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MEST015C(_aLog)

Local _nHdl	:= 0
Local _nI	:= 0
Local _cNomeLog:= 'MEST015_'+(DTOS(DATE())+"_"+STRTRAN(Time(),":",""))+".csv" 
Local _cFileLog:= "\temp\"+_cNomeLog

_nHdl := FCreate(_cFileLog)

If _nHdl == -1
     MsgAlert( "O arquivo de nome "+_cFileLog+" nao pode ser criado!" , "Atencao!" )
     Return()
EndIf

FWrite( _nHdl , "HORA;FILIAL;ARMAZEM;CODIGO;PROCESSAMENTO;PRODUTO;lMsErroAuto = .T." + CHR(13) + CHR(10) )//PRIMEIRA LINHA DO CSV

ProcRegua( Len(_aLog) )

For _nI := 1 To Len(_aLog)
		
	IncProc()

	FWrite( _nHdl ,_aLog[_nI] + CHR(13) + CHR(10) )
	
	If FError() # 0
   		MsgAlert ( "ERRO AO GRAVAR NO ARQUIVO: "+ str( FError() ) )
   		Exit
	EndIf
	
Next _nI

FClose(_nHdl)

cDirDest := ""

IF EMPTY(cDirDest)
   cDirDest:=GetTempPath()
ENDIF

LjMsgRun( 'Copiando arquivo de Log...' , 'Aguarde!' , {|| CpyS2T( _cFileLog , cDirDest ) } )

IF _lEfetivar
	
   IF FILE(cDirDest+_cNomeLog)
		
		ShellExecute("open", cDirDest+_cNomeLog, "" , "", 0)
		
   ENDIF
	
   U_ITMSG( UPPER("Arquivo de LOG: "+_cFileLog+" gerado com sucesso!"),"FINAL",,2 )

ELSE
  IF LEN(_aAnalise) = 0
      AADD(_aAnalise , {"" ,"Não foram encontrados Produtos para Correção para essa Seleção", "" ,"" })
  ENDIF    

  U_ITListBox( 'Analise dos ajustes do saldo restante na Segunda UM' ,;                    //     , _aCols   ,_lMaxSiz,_nTipo,_cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel )
             {'Codigo','Descrição do Produto','Processamento','Armazem'} , _aAnalise, .T.    , 1    ,         ,          ,;
             {      50,                   160,            160,       45} )

ENDIF   


Return()

/*
===============================================================================================================================
Programa----------: MEST15Val
Autor-------------: Alex Walaluer
Data da Criacao---: 26/04/2018
Descrição---------: Valida data
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER Function MEST15Val()
IF MV_PAR06 > DATE() .OR. EMPTY(MV_PAR06)
   U_ITMSG("Data deve ser preenchida e menor ou igual que a data de Hoje.","ATENCAO",,1)
   RETURN .F.
ENDIF
RETURN .T.

/*
===============================================================================================================================
Programa----------: MEST15SB1
Autor-------------: Alex Walaluer
Data da Criacao---: 18/04/2018
Descrição---------: Trata SB1
Parametros--------: lVolta = .T. Volta os valores ; _cCod: codigo do item
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function MEST15SB1(lVolta,_cCod,_aLog)

SB1->( DBSetOrder(1) )
If SB1->( DBSeek( xFilial("SB1") + _cCod ) ) .AND. _lEfetivar
	IF lVolta

		SB1->( Reclock( "SB1" , .F. ) )
		SB1->B1_MSBLQL:= _cStatus
		SB1->B1_CONV  := _cConv
		SB1->( MsUnlock() )

	ELSE
		
		//Guarda do valores
		_cStatus:= SB1->B1_MSBLQL
		_cConv  := SB1->B1_CONV
		//Guarda do valores

		SB1->( Reclock( "SB1" , .F. ) )
		SB1->B1_MSBLQL:= "2"
		SB1->B1_CONV  := 0
		SB1->( MsUnlock() )
		
	EndIf
EndIf
	
RETURN .T.

/*
===============================================================================================================================
Programa----------: MEST15LOG
Autor-------------: Alex Walaluer
Data da Criacao---: 19/04/2018
Descrição---------: Grava LOG
Parametros--------: 
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function MEST15LOG(_cCod,_cMem,_cErro)
DEFAULT _cErro := ""

IF EMPTY(_cCod)
   AADD( _aLog ,TIME()+";'"+xFilial("SB2")+";            ; "+_cCod+";"+_cMem+";                                                              ;"+STRTRAN(_cErro,CHR(13)+CHR(10)," ") )
ELSE
   AADD( _aLog ,TIME()+";'"+xFilial("SB2")+";'"+_cArmaz+";'"+_cCod+";"+_cMem+";"+ALLTRIM(Posicione("SB1",1,xFilial("SB1")+_cCod,"B1_DESC"))+";"+STRTRAN(_cErro,CHR(13)+CHR(10)," ") )
ENDIF

IF !_lEfetivar
   IF EMPTY(_cCod)
   ELSEIF "Saiu " $ _cMem .OR. "Entrou " $ _cMem
      _cMem:=STRTRAN(_cMem,"Entrou","Entrara")
      _cMem:=STRTRAN(_cMem,"Saiu","Saira")
      AADD(_aAnalise , {_cCod , Posicione("SB1",1,xFilial("SB1")+_cCod,"B1_DESC") , _cMem , _cArmaz  })
   ENDIF
ENDIF

RETURN 
