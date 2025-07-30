/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer |13/11/2020| Chamado 34667. Ajustes no controle de Transação p/ cada linha.
Alex Wallauer |10/01/2023| Chamado 42485. Alteracao no calculo do campo ZZH_VALOR.
Lucas Borges  |13/10/2024| Chamado 48465. Retirada da função de conout
================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include 'protheus.ch'
#include "topconn.ch"

/*
===============================================================================================================================
Programa--------: MCOM011
Autor-----------: Alex Wallauer
Data da Criacao-: 27/06/2019
Descrição-------: Rotina de reprocessamento de tabela ZZH a partir de pedidos de compra - Chamado 29776
Parametros------: NENHUM
Retorno---------: NENHUM
===============================================================================================================================
*/
USER FUNCTION MCOM011()
LOCAL cTimeInicial:=TIME()
Local _aParRet :={}
Local _aParAux :={} , nI 
Local _bOK     :={|| IF(MV_PAR02 >= MV_PAR01 .OR. MV_PAR02 > DATE(),.T.,(U_ITMSG("Periodo INVALIDO",'Atenção!',"Tente novamente com outro periodo ate a data de hoje",3),.F.) ) }


Private _lTela   := .T.	                 
Private aLog := {}
                                   	
//Testa se esta sendo rodado do menu
If	Select('SX3') == 0

	FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MCOM011"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MCOM01101"/*cMsgId*/, "MCOM01101 - Gerando ZZH..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

	RPCSetType( 3 )						//Não consome licensa de uso
	RpcSetEnv('01','01',,,,GetEnvServer(),{ "SC7","ZZH" })
	sleep( 5000 )						//Aguarda 5 segundos para que as jobs IPC subam.
	_lTela := .F.

    MV_PAR01:=CTOD("01/01/2000")
    MV_PAR02:=CTOD("31/12/2049")
    MV_PAR03:=2//Efetivar
    MV_PAR04:=2//Somente PC sem ZZH

ELSE

    MV_PAR01:=dDataBase
    MV_PAR02:=dDataBase
    MV_PAR03:=1
    MV_PAR04:=1

    AADD( _aParAux , { 1 , "Data de:"	, MV_PAR01, "@D"	, ""	, ""		, "" , 050 , .F. } )
    AADD( _aParAux , { 1 , "Data ate:"	, MV_PAR02, "@D"	, ""	, ""		, "" , 050 , .F. } )
    AADD( _aParAux , { 3 , "Tipo Processamento", MV_PAR03, {"Analise","Efetivar"}, 40, "", .T., .T. , .T. } )
    AADD( _aParAux , { 3 , "Somente PC sem ZZH", MV_PAR04, {"Sim","Nao"}         , 40, "", .T., .T. , .T. } )

    For nI := 1 To Len( _aParAux )
	    aAdd( _aParRet , _aParAux[nI][03] )
    Next nI

    IF !ParamBox( _aParAux , "Intervalo de Datas" , @_aParRet, _bOK )
		RETURN .F.
    EndIf

EndIf

cTimeInicial:=TIME()
_lEfetivar:=(MV_PAR03 = 2)
_lQqPC    :=(MV_PAR04 = 2)
lRet:=.T.
_nOK:=0
_nErro:=0

If _lTela
    FWMSGRUN( ,{|oProc|  lRet:=CORRZZHP(oProc) } , "Hora Inicial: "+cTimeInicial+" Lendo: "+DTOC(MV_PAR01)+", Ate "+DTOC(MV_PAR02) )
	IF !lRet
	   RETURN .T.
	ENDIF

    IF LEN(aLog) > 0
	   cTitulo:="Quantidade de Registros: "+ALLTRIM(STR(_nOK))+" OK / "+ALLTRIM(STR(_nErro))+" Ocorrencias / Hora Inicial: "+cTimeInicial+" - Hora Final: "+TIME()
	   U_ITListBox( 'Log de Atualizacao da ZZH (MCOM011)' ,;
	                     {'','Filial','Pedido','Item','Condicao','Data','Valor','Prop.','Observacao'},aLog,.T.,4,cTitulo,,;
	                     {15,      25,      35,   40,         25,   35 ,     55,     20,     150} )
    ELSE
	   U_ITMSG("Nao foi encontrado dados para essa selecao","Atencao!",,1)
    ENDIF

Else
	//Atualização tabela SM2
	FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MCOM011"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MCOM01102"/*cMsgId*/, "MCOM01102 - INICIO DO PROCESSAMENTO - ZZH..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	
    lRet:=CORRZZHP()
	
	FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "MCOM011"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "MCOM01103"/*cMsgId*/, "MCOM01103 - FIM DO PROCESSAMENTO - ZZH - Hora Inicial: "+cTimeInicial/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	
    RpcClearEnv()		   				//Libera o Ambiente

EndIf

Return lRet

/*
===============================================================================================================================
Programa----------: CORRZZHP
Autor-------------: Alex Walauer Ferreira
Data da Criacao---: 27/06/2018
Descrição---------: Rotina de reprocessamento da ZZH
Parametros--------: oproc - objeto da barra de processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function CORRZZHP(OPROC)
Local _nTot := 0
Local _nConta := 0 , _nI
Local _aDadVenc := {}
Default oproc := nil

IF oproc <> nil
   oproc:cCaption := ("Lendo pedidos...")
   ProcessMessages()
ENDIF

_cQry := " SELECT SC7.R_E_C_N_O_ AS NRECNO FROM " + RetSqlName("SC7") + " SC7 "   
_cQry += " WHERE SC7.D_E_L_E_T_ = ' ' "
IF !EMPTY(MV_PAR01)
   _cQry += " AND C7_EMISSAO >= '"+DTOS(MV_PAR01)+"' "
ENDIF
IF !EMPTY(MV_PAR02)
   _cQry += " AND C7_EMISSAO <= '"+DTOS(MV_PAR02)+"' "
ENDIF
_cQry += " AND C7_QUJE <> C7_QUANT "
_cQry += " AND C7_I_DTFAT <> ' ' "
//_cQry += " AND C7_COND NOT IN ('001','969','979','99X','99Y','99Z')    "
IF !_lQqPC//Somente PC sem ZZH
   _cQry += " AND C7_RESIDUO <> 'S' "
   _cQry += " AND NOT EXISTS (SELECT 'Y' FROM " + RetSqlName("ZZH") + " ZZH WHERE ZZH.D_E_L_E_T_ = ' ' AND ZZH_FILIAL = C7_FILIAL AND ZZH_PEDIDO = C7_NUM AND ZZH_ITEMPC = C7_ITEM ) "
ENDIF   
_cQry += " ORDER BY  C7_FILIAL , C7_NUM "

 If Select("SC7T") > 0
    SC7T->(DbCloseArea())
EndIf
           
 _cQry := ChangeQuery(_cQry) 
DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry), "SC7T", .F., .T.)   

COUNT TO _nTot

IF oproc <> nil .and. _nTot > 0
   IF !U_ITMSG("Serão processado "+ALLTRIM(STR(_nTot))+" itens. Continua?",'Atenção!',,3,2,2)
       RETURN .F.
   ENDIF
ENDIF

SC7T->(Dbgotop())                           
ZZH->( DBSetOrder(1) )

//BEGIN TRANSACTION       
Do while !(SC7T->(Eof()))

	SC7->(Dbgoto(SC7T->NRECNO))
	_cPC:=AVKEY(SC7->C7_NUM,"ZZH_PEDIDO")
   	_nConta++
    IF oproc <> nil
	   oproc:cCaption := ("Gerando ZZH pedido: "+ SC7->C7_FILIAL + "/" + SC7->C7_NUM+" - "+ STRZERO(_nConta,6) + " de " + STRZERO(_nTot,6)) 
	   ProcessMessages()
    ENDIF
	//         QQ PC   e  EFETIVAR   
    IF _lQqPC //.AND. _lEfetivar
   	   If ZZH->( DBSeek(SC7->C7_FILIAL + _cPC + SC7->C7_ITEM ) )
  	      BEGIN TRANSACTION
       	  Do While ZZH->ZZH_FILIAL+ZZH->ZZH_PEDIDO == SC7->C7_FILIAL+_cPC .and. ZZH->ZZH_ITEMPC == SC7->C7_ITEM

    	    IF _lEfetivar
		       AADD(aLog,{.F.,SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_ITEM,SC7->C7_COND,ZZH->ZZH_DATA,ZZH->ZZH_VALOR,ZZH->ZZH_PRORP,'Excluido'})
     		   ZZH->(RecLock("ZZH",.F.))
       		   ZZH->(DBDelete())
			ELSE   
		       AADD(aLog,{.F.,SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_ITEM,SC7->C7_COND,ZZH->ZZH_DATA,ZZH->ZZH_VALOR,ZZH->ZZH_PRORP,'Sera Excluido'})
			ENDIF	  
            //_nErro++
       		ZZH->(DbSkip())
          Enddo   
  	      END TRANSACTION
   	 	Endif	
	ENDIF
	
	//  SE QQ PC
	IF _lQqPC .AND. SC7->C7_RESIDUO = 'S'
	   SC7T->(DBSKIP())
	   LOOP	   
	ENDIF
    
	  //  QQ PC E    ANALISAR
    If (_lQqPC .AND. !_lEfetivar) .OR. !ZZH->( Dbseek(SC7->C7_FILIAL + _cPC+ SC7->C7_ITEM) )  
       
		_nTOTAL   := ( ( ( (SC7->C7_PRECO * SC7->C7_QUANT )+SC7->C7_VALIPI+SC7->C7_DESPESA) - SC7->C7_VLDESC ) / SC7->C7_QUANT ) * ( SC7->C7_QUANT - SC7->C7_QUJE )
		_aCond	  := Condicao( _nTOTAL , SC7->C7_COND , 0 , SC7->C7_I_DTFAT )
		_ligual   := .T.
		_aDadVenc := {}
        
		IF Len( _aCond ) = 0
		   AADD(aLog,{.F.,SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_ITEM,SC7->C7_COND,"",ZZH->ZZH_VALOR,0,'Condicao sem parcelas'})
		   _nErro++
        ENDIF
		//Arruma datas, proporcionalidade e monta matriz de vencimentos
		For _nI := 1 To Len( _aCond )
	
			_dDtVenc   := DataValida( _aCond[_nI][01] ) //só dias úteis
			_nContarorp:= Round( _aCond[_nI][2]/_nTOTAL , 2 )  //indica proporcionalidade da parcela
 	    
			//se é primeira passagem grava a primeira proporção para comparar com as seeguintes
    		if _nI == 1
 	      
        		_ccondi := _nContarorp
 	      
	 		else
 	    
	     		if _ccondi != _nContarorp  //compara para ver se tem proporção diferente da primeira
 	      
	        		_ligual := .F.
 	        
	     		endif
 	      
			endif  
			
			aAdd( _aDadVenc , { _dDtVenc , Round( _aCond[_nI][2] , 2 ), _nContarorp, SC7->C7_ITEM } )
    
		Next _nI
      
    	//verifica se _nContarorp é igual para todas as parcelas
    	// se for deixa zerado para o BI calcular o valor com menor margemd e erro por arredondamento
    	if _ligual
        
    		For _nI := 1 To Len( _aDadVenc )
        
     		    _aDadVenc[_nI][3] := 0'
        
    		Next _nI
        
    	endif

    	For _nI := 1 To Len( _aDadVenc ) 

    	    IF _lEfetivar .AND. _aDadVenc[_ni][2] <> 0
			   BEGIN TRANSACTION
    	    	     ZZH->(RecLock( "ZZH" , .T. ) )
    	    	     ZZH->ZZH_FILIAL := SC7->C7_FILIAL
    	    	     ZZH->ZZH_PEDIDO := SC7->C7_NUM
    	    	     ZZH->ZZH_DATA   := _aDadVenc[_ni][1]
    	    	     ZZH->ZZH_PRORP  := _aDadVenc[_ni][3]  
    	    	     ZZH->ZZH_ITEMPC := _aDadVenc[_ni][4]
    	    	     ZZH->ZZH_VALOR  := _aDadVenc[_ni][2]
    	    	     ZZH->(MsUnlock())
			   END TRANSACTION
			   AADD(aLog,{.T.,SC7->C7_FILIAL,SC7->C7_NUM,_aDadVenc[_ni][4],SC7->C7_COND,_aDadVenc[_ni][1],_aDadVenc[_ni][2],_aDadVenc[_ni][3] ,'Gravado'})
            ELSE
    	        IF _aDadVenc[_ni][2] <> 0
			       AADD(aLog,{.T.,SC7->C7_FILIAL,SC7->C7_NUM,_aDadVenc[_ni][4],SC7->C7_COND,_aDadVenc[_ni][1],_aDadVenc[_ni][2],_aDadVenc[_ni][3] ,'Analisado OK'})
				ELSE   
			       AADD(aLog,{.F.,SC7->C7_FILIAL,SC7->C7_NUM,_aDadVenc[_ni][4],SC7->C7_COND,_aDadVenc[_ni][1],_aDadVenc[_ni][2],_aDadVenc[_ni][3] ,'Valor ZERADO'})
		           _nErro++
				ENDIF
			ENDIF 
			
			_nOK++
    	Next 
    
  	Endif
    
	SC7T->(Dbskip())
	
Enddo
//END TRANSACTION       
Return .T.
