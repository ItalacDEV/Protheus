/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor    |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer  | 23/01/2018 | Chamado 23332. Recebimento da data de Entrega.
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer  | 30/01/2018 | Chamado 23296. Tratamento do Status Recepcionado.
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich   | 10/09/2018 | Chamado 26230. Inclusão de campos de tipo de operação e tipo de PV.
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich   | 08/10/2018 | Chamado 26571. Mudança de flag de pallet para S/N.  
 ------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer  | 26/05/2022 | Chamado 39375. Informado uma Data de Canhoto gravar o Status = a "Aprovado" e Dt de Entrega. 
=============================================================================================================================== 
*/
#include 'rwmake.ch' 
#include "APWEBSRV.CH"
#Include 'Protheus.ch'  
#INCLUDE "TBICONN.CH"   



/*
===============================================================================================================================
Programa----------: AOMS105
Autor-------------: Josué Danich Prestes
Data da Criacao---: 12/09/2016
===============================================================================================================================
Descrição---------: WebService integração com sistema Estec - Chamado 22908
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS105(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)

Local cHTML        := ''
Local _dDataEnt    := CTOD("")
Local _dAuxDataEnt := CTOD("")
Local _nHifem      := 0


//=====================================================================
// Limpa o ambiente, liberando a licença e fechando as conexões
//=====================================================================
RpcClearEnv() 

//===========================================================================================
// Preparando o ambiente com a filial da carga recebida
//===========================================================================================
PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01'; 
       TABLES "ZGJ","SF2","SA1","SA2","SA4";
       MODULO 'OMS'


Begin Sequence

IF LEN(__aProcParms) > 3 .AND. !EMPTY(__aProcParms[4,2]) 
   _dAuxDataEnt := __aProcParms[4,2]
   _nHifem      := RAT("-",_dAuxDataEnt)
   //Ex.: 2018-11-2 --> (2) --> 2/11/2018 --> 02/11/02]  //Ex.: 2018-1-23 --> (1) --> 23/1/2018 --> 23/01/23]
   _dAuxDataEnt := SUBSTR(_dAuxDataEnt,_nHifem+1) +"/"+ SUBSTR(_dAuxDataEnt,6,(_nHifem-6)) +"/"+ LEFT(_dAuxDataEnt,4)
   _dDataEnt    := CTOD(_dAuxDataEnt)
   U_ITCONOUT("Data de Entrega recebida: "+__aProcParms[4,2]+" -> "+_dAuxDataEnt+" -> "+DTOC(_dDataEnt))
ENDIF

//Verifica se já tem registro no muro
//Se não tem adiciona e retorna status aguardando
Dbselectarea("ZGJ")
ZGJ->(Dbsetorder(1))

If !(ZGJ->(Dbseek(alltrim(__aProcParms[1,2])+alltrim(__aProcParms[2,2])+alltrim(__aProcParms[3,2]))))

	//Verifica se existe a nota na SF2
	If !(SF2->(Dbseek(alltrim(__aProcParms[1,2])+alltrim(__aProcParms[2,2])+alltrim(__aProcParms[3,2]))))
	
		cHTML := '{"status": "Reprovado", '
		cHTML += '"entrega": "N/C", '
		cHTML += '"observacao": "Nota nao localizada no Protheus", '
		cHTML += '"cnpjcli": "N/C", '
		cHTML += '"razaosoc": "N/C", '
		cHTML += '"fantasia": "N/C", '
		cHTML += '"cidade": "N/C", '
		cHTML += '"estado": "N/C", '
		cHTML += '"pedido": "N/C", '
		cHTML += '"carga": "N/C", '
		cHTML += '"transportador": "N/C"}'
		u_itconout("Reprovada digitalizacao do canhoto da nota "+ alltrim(__aProcParms[1,2]) + "/" +  alltrim(__aProcParms[2,2]) + " - " +  DTOC(_dDataEnt) + " - " +  "Nota nao localizada no Protheus")
		
		Break
	
	Endif
	
	Reclock("ZGJ",.T.)
	ZGJ->ZGJ_FILIAL:= Alltrim(__aProcParms[1,2])
	ZGJ->ZGJ_NOTA  := Alltrim(__aProcParms[2,2])
	ZGJ->ZGJ_SERIE := Alltrim(__aProcParms[3,2])
  	ZGJ->ZGJ_DTENT := _dDataEnt
	IF !EMPTY(_dDataEnt) //CHAMADO 39375. Quando informado uma Data de Canhoto e existir tabela de Controle de Digitalização de Canhoto (ZGJ) gravar o status da digitalização igual a "Aprovado" e Data de Entrega 
	   ZGJ->ZGJ_STATUS := "Aprovado"
	ELSE
	   ZGJ->ZGJ_STATUS := "Aguardando Conf"
	ENDIF
	ZGJ->ZGJ_DATAI := DATE()
	ZGJ->ZGJ_HORAI := TIME()
    IF ZGJ->(FIELDPOS("ZGJ_USERI")) # 0
	   ZGJ->ZGJ_USERI := "Integrado da Estec"
	ENDIF
	ZGJ->(Msunlock())
	
	cHTML := '{"status": "Aguardando Conf", '
	cHTML += '"entrega": "N/C", '
	cHTML += '"observacao": "N/C", '
	AOMS105R(@cHTML)
	
	U_ITCONOUT("[I] Digitalizado canhoto da nota "+ alltrim(__aProcParms[1,2]) + "/" +  alltrim(__aProcParms[2,2]) + " - " +  DTOC(_dDataEnt) )
	Break

//Se tem verifica se já foi confirmado e retorna status
Else

	IF !SF2->(Dbseek(alltrim(__aProcParms[1,2])+alltrim(__aProcParms[2,2])+alltrim(__aProcParms[3,2])))
	    ZGJ->(RECLOCK("ZGJ",.F.))
	    ZGJ->ZGJ_OBS:= "Nota nao encontrada: "+alltrim(__aProcParms[1,2])+" / "+alltrim(__aProcParms[2,2])+" / "+alltrim(__aProcParms[3,2])
		ZGJ->(MSUNLOCK())
	ENDIF

	If alltrim(ZGJ->ZGJ_STATUS) == "Aguardando Conf"
	
		cHTML := '{"status": "Aguardando Conf", '
		cHTML += '"entrega": "N/C", '
		cHTML += '"observacao": "N/C", '
	    AOMS105R(@cHTML)

		u_itconout("[A] Digitalizado canhoto da nota "+ alltrim(__aProcParms[1,2]) + "/" +  alltrim(__aProcParms[2,2]) + " - " +  DTOC(_dDataEnt))
		Break
				
	Elseif alltrim(ZGJ->ZGJ_STATUS) == "Aprovado"
	
		cHTML := '{"status": "Aprovado", '
		cHTML += '"entrega": "' + dtoc(ZGJ->ZGJ_DTENT) + '", '
		cHTML += '"observacao": "N/C", '
	    AOMS105R(@cHTML)
		
		u_itconout("Aprovada digitalizacao do canhoto da nota "+ alltrim(__aProcParms[1,2]) + "/" +  alltrim(__aProcParms[2,2]) + " - " +  DTOC(ZGJ->ZGJ_DTENT)+ " - " +  alltrim(ZGJ->ZGJ_OBS))
		Break
		
	Elseif alltrim(ZGJ->ZGJ_STATUS) == "Reprovado"
	
		cHTML := '{"status": "Reprovado", '
		cHTML += '"entrega": "N/C", '
		cHTML += '"observacao": "' + alltrim(ZGJ->ZGJ_OBS) + '", '
	    AOMS105R(@cHTML)
		
		u_itconout("Reprovada digitalizacao do canhoto da nota "+ alltrim(__aProcParms[1,2]) + "/" +  alltrim(__aProcParms[2,2])+ " - " +  DTOC(_dDataEnt)  + " - " +  alltrim(ZGJ->ZGJ_OBS))
		
		//Apaga registro para se vier nova digitalização fazer nova análise
		ZGJ->(RECLOCK("ZGJ",.F.))
		ZGJ->(DBDELETE())
		ZGJ->(MSUNLOCK())

		Break

	Elseif ALLTRIM(ZGJ->ZGJ_STATUS) == "Recepcionado"
	
		cHTML := '{"status": "Aguardando Conf", '
		cHTML += '"entrega": "N/C", '
		cHTML += '"observacao": "N/C", '
	    AOMS105R(@cHTML)
		
		U_ITCONOUT("Status Recepcionado alterado p/ Aguardando Conf. Digitalizado canhoto da nota "+ alltrim(__aProcParms[1,2]) + "/" +  alltrim(__aProcParms[2,2])+ " - " +  DTOC(_dDataEnt)  + " - " +  alltrim(ZGJ->ZGJ_OBS))
		
		//Apaga registro para se vier nova digitalização fazer nova análise
		ZGJ->(RECLOCK("ZGJ",.F.))
	    ZGJ->ZGJ_STATUS:= "Aguardando Conf"
		ZGJ->(MSUNLOCK())

		Break

	Endif

Endif

End Sequence

Return(cHTML)

/*
===============================================================================================================================
Programa----------: AOMS105R
Autor-------------: Alex Wallauer
Data da Criacao---: 23/01/2018
===============================================================================================================================
Descrição---------: Grava Resposta
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS105R(cHTML)
		
	SA1->(DBSETORDER(1))
    SA1->(DBSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
    SC5->(Dbsetorder(1))
    SC5->(Dbseek(SF2->F2_FILIAL+SF2->F2_I_PEDID))
    SC6->(Dbsetorder(1))
    SC6->(Dbseek(SF2->F2_FILIAL+SF2->F2_I_PEDID))
    
    If alltrim(SC6->C6_PRODUTO) == alltrim(GetMV("IT_CCHEP"))
    
    	_cPallet := "S"
    	
    Else
    
    	_cPallet := "N"
    	
    Endif

	cHTML += '"cnpjcli": "'       + ALLTRIM(SA1->A1_CGC) + '", '
	cHTML += '"razaosoc": "'      + SA1->A1_COD + '/' + SA1->A1_LOJA + ' - ' + Alltrim(SA1->A1_NOME) + '", '
	cHTML += '"fantasia": "'      + ALLTRIM(SA1->A1_NREDUZ) + '", '
	cHTML += '"cidade": "'        + ALLTRIM(SA1->A1_MUN) + '", '
	cHTML += '"estado": "'        + ALLTRIM(SA1->A1_EST) + '", '
	cHTML += '"pedido": "'        + ALLTRIM(SF2->F2_I_PEDID) + '", '
	cHTML += '"carga": "'         + ALLTRIM(SF2->F2_CARGA) + '", '
	cHTML += '"transportador": "' + ALLTRIM(SF2->F2_I_NTRAN) + '", '
	cHTML += '"oper_ped": "'      + ALLTRIM(SC5->C5_I_OPER) + '", '
	cHTML += '"pallet": "'        + _cpallet + '" '
	cHTML += '}'

RETURN .T.
