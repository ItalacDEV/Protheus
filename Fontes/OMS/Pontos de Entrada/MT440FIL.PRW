/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 07/03/2017 | Ajustes da Validação de crédito - Chamado 19169
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 10/04/2017 | Incluido filtros por pedidos de funcionários - Chamado 19537
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 11/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 01/02/2021 | Remoção de bugs apontados pelo Totvs CodeAnalysis. Chamado: 34262
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RwMake.ch"
STATIC aLog:={}

/*
=========================================================================================================================================================
Programa----------: MT440FIL
Autor-------------: Alex Wallauer
Data da Criacao---: 07/03/2017
=========================================================================================================================================================
Descrição---------: PE na Function a440Proces() do programa Mata440.PRX
===============================================================================================================================
Uso---------------: Liberacao de Pedidos de Vendas Automatica 
=========================================================================================================================================================
Parametros--------: Nenhum
=========================================================================================================================================================
Observação--------: 
=========================================================================================================================================================
*/
USER FUNCTION MT440FIL()

Local _cBlqCred:=""
Local _lvalida := .T.
Local _nTotal := 0
Local _cFiltro:=""
Local _cFiltroF:="(.F.)"
Local _cChep   := Alltrim(GetMV("IT_CCHEP"))

_aSC5:= GetArea("SC5") 

SC5->( Dbsetorder(1))
SC5->( Dbseek(SC6->C6_FILIAL+SC6->C6_NUM) )//Posiciona na capa

IncProc("Lendo PV: "+SC6->C6_FILIAL+" - "+SC6->C6_NUM)

//====================================================================================================
// Filtros de pedidos de funcionários
//====================================================================================================
If MV_PAR11 == 1

   IF SC5->C5_I_OPER == "02" .And. SC5->C5_TIPO == "N" //.And. Upper(AllTrim(SC5->C5_I_OBPED)) == "PEDIDO AUTOMÁTICO - AOMS070"
      _cFiltro := ""
   ELSE
      Restarea(_aSC5)	
      RETURN _cFiltroF
   ENDIF

EndIf

IF (_nPos:= ASCAN(aLog , {|L| L[3] == SC6->C6_NUM })) # 0
   IF aLog[_nPos,1]//.T.
      RETURN _cFiltro
   ELSE//.F.
      RETURN _cFiltroF
   ENDIF
ENDIF

_nREC_SC6:= SC6->(RecNo()) 
_aSC6    := GetArea("SC6") 
_aSC9    := GetArea("SC9") 
_aSF4    := GetArea("SF4") 

SC6->( Dbsetorder(1))
SC6->( Dbseek(SC5->C5_FILIAL+SC5->C5_NUM) )//Reposiciona o SC6 no primeiro item do PV

Do while SC6->(!EOF()) .and. SC6->C6_FILIAL == SC5->C5_FILIAL .and. SC6->C6_NUM == SC5->C5_NUM

   If alltrim(SC6->C6_PRODUTO) == _cChep .OR. AllTrim(SC6->C6_CF) $ '5910/6910/5911/6911'
   
      //NÃO VALIDA CRÉDITO PARA PALLET CHEP E PARA BONIFICAÇÃO
      _lvalida := .F.
      
    Endif
    
    If SC5->C5_TIPO != 'N' .OR. posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC") != 'S' 
   
      //NÃO VALIDA CRÉDITO PARA PEDIDO SEM DUPLICATA OU PARA PEDIDO QUE NÃO SEJA PEDIDO NORMAL
      _lvalida := .F.
      
    Endif
    
    If posicione("ZAY",1,xfilial("ZAY")+SC6->C6_CF,"ZAY_TPOPER") != 'V' 
   
      //NÃO VALIDA CRÉDITO PARA PEDIDO COM CFOP QUE NÃO SEJA DE VENDA
      _lvalida := .F.
      
    Endif

    IF !_lvalida
       EXIT
    ENDIF   

   _nTotal += SC6->C6_VALOR
   
   SC6->( Dbskip() )
	
Enddo

//AWF-30/11/2016 - Reavaliação de Credito
IF _lvalida .AND. SC5->C5_I_BLCRE = "B" 
   cMensagem:="O pedido não pode ser liberado pois esta bloqueado para avaliação"
   AADD(aLog,{ .F. , SC5->C5_FILIAL , SC5->C5_NUM , "Não" , cMensagem })
   _cFiltro := _cFiltroF
ENDIF   

IF _lvalida .AND. EMPTY(_cFiltro)

//********************** VALIDACAO NOVA DE CREDITO UNIFICADA ***************************************************//		
   _aRetCre := U_ValidaCredito( _nTotal )//AWF-11/01/2017
   _cBlqCred:=_aRetCre[1]
//********************** VALIDACAO NOVA DE CREDITO UNIFICADA ***************************************************//		

   If _cBlqCred != "Liberação completa de crédito" .and. _cBlqCred != "Liberado por risco A" .and. _cBlqCred != "Aprovado em análise de crédito"

      SC5->(RecLock("SC5",.F.))
	  SC5->C5_I_BLCRE := "B"
	  SC5->C5_I_DTAVA := DATE()
	  SC5->C5_I_HRAVA := TIME()
	  SC5->C5_I_USRAV := cUsername
	  SC5->C5_I_MOTBL := _cBlqCred

	  SC5->C5_I_LIBCA := ""
	  SC5->C5_I_LIBC  := 0
	  SC5->C5_I_LIBCT := ""
	  SC5->C5_I_LIBL  := CTOD("")
	  SC5->C5_I_LIBCV := 0
	  SC5->C5_I_LIBCD := CTOD("")
	  SC5->C5_I_DTLIC := CTOD("")

   	  SC5->(MsUnlock())
  
      cMensagem:="O pedido não pode ser liberado e será bloqueado para posterior avaliação [ "+_cBlqCred+" ]"
      
      AADD(aLog,{ .F.  , SC5->C5_FILIAL , SC5->C5_NUM , "Não" , cMensagem })

      _cFiltro := _cFiltroF
   
   Elseif SC5->C5_I_BLCRE != "L"
   
      SC5->(RecLock("SC5",.F.))
	  SC5->C5_I_BLCRE := " "
	  SC5->C5_I_DTAVA := DATE()
	  SC5->C5_I_HRAVA := TIME()
	  SC5->C5_I_USRAV := cUsername
	  SC5->C5_I_MOTBL := _cBlqCred
   	  SC5->(MsUnlock())
   
   ENDIF

EndIf
//AWF-30/11/2016 - Reavaliação de Credito

IF EMPTY(_cFiltro)

   AADD(aLog,{ .T. , SC5->C5_FILIAL , SC5->C5_NUM ," ", "Pedido Liberado" })

ENDIF 

Restarea(_aSC5)	
Restarea(_aSC6)	
Restarea(_aSC9)	
Restarea(_aSF4)	

SC6->(DBGOTO(_nREC_SC6)) 

RETURN _cFiltro

*====================================================*
USER FUNCTION MT440LOG(lLimpa)
*====================================================*
IF lLimpa
   aLog:={}
ENDIF

RETURN aLog
