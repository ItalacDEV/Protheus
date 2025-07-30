/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer |12/06/2024| Chamado 47557. André. Ajustado para aceitas 4 tamanhos de CC nos filtros e gerar Excel no e-mail.
Alex Wallauer |01/07/2024| Chamado 47557. André. Ajustes para gerar Excel analitico sempre no mensal no e-mail.
Lucas Borges  |13/10/2024| Chamado 48465. Retirada da função de conout
Lucas Borges  |23/07/2025| Chamado 51340. Ajustar função para validação de ambiente de teste
==============================================================================================================================
*/

#Include "FWPrintSetup.ch"
#Include "Protheus.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"

/*
==============================================================================================================================================================
Programa----------: REST013 / REST013M
Autor-------------: Alex Wallauer
Data da Criacao---: 14/02/2019
Descrição---------: WFW de auditoria de CC entre SA e atendimento de SA - Chamado 28093
Parametros--------: _lLSchedule - execeutado via Schedule ou via tela
                    _lLMensal - Mensal ou Semanal
Retorno-----------: Nenhum
==============================================================================================================================================================
*/
USER Function REST013M()// PARA CHAMAR O RELATORIO MEMSAL U_REST013M () NO SCHEDULE
RETURN U_REST013(.T.,.T.)

USER Function REST013(_lLSchedule,_lLMensal)//PARA CHAMAR OS RELATORIOS SEMANAIS U_REST013 () NO _lSchedule
LOCAL _cQuery:="" , _nI
LOCAL _cAliasZZL:= GetNextAlias()
    	
PRIVATE _lSchedule  := .T.
IF VALTYPE(_lLSchedule) = "L"
   _lSchedule:=_lLSchedule
ENDIF

PRIVATE _lMensal   := .F.
IF VALTYPE(_lLMensal) = "L"
   _lMensal:=_lLMensal
ENDIF

PRIVATE _cAssunto   :=""
PRIVATE _cDatas     :="Sem filtro de datas"
PRIVATE _cCentro    :=""
PRIVATE _cNomeFilial:=""
PRIVATE _cPathSrv   :="/spool/"//GETMV("MV_RELT",,"\spool\")
PRIVATE _cFileName  :=""//O nome é preenchido na funcao U_ROMS004(.T.) - Ex.: \SPOOL\REST013_20130214_165826.pdf
PRIVATE _aDadosTotal:={}
PRIVATE _aAnaliTotal:={}
PRIVATE _aEmail_CC  :={}
PRIVATE _aEmailCC   :={}
PRIVATE _aEmailGG   :={}
PRIVATE _cEmail     :=""
PRIVATE _cEnvPara   :=""
PRIVATE _cCentrosC  :=""//"0113001;0103001"//Testes 
PRIVATE _cFilial    :=""//Filial Gerente
PRIVATE _aResultado :={}
PRIVATE _cTitJanela :=""
PRIVATE _cFilsGerent:=""
PRIVATE _cAmbiente  :=GETENVSERVER()

IF _lSchedule .AND. SELECT("SX3") = 0
   FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "REST013"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "REST01301"/*cMsgId*/, "REST01301 - Iniciando..."/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
   RpcSetType(3)
   PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "EST" TABLES "ZZL","SD3","SD1","SCP","SB1","SA2"
ELSE
   
   _lSchedule:=.F.

   MV_PAR01:=(dDataBase)//-7
// MV_PAR02:=(dDataBase-1)
	MV_PAR02:=1
   _aOpc:={"1-MENSAL","2-SEMANAL"}
   _cTitulo:="Filtro dos dados de Centros de Custos"
        
	_aParAux:={}
   AADD( _aParAux , { 1 , "Data"             , MV_PAR01, "@D"  , "" ,"", ".T." , 070 , .T. } )
   //AADD( _aParAux , { 1 , "Data ate"       , MV_PAR02, "@D"  , "" ,"", ".T." , 070 , .T. } )
   AADD( _aParAux , { 3 , "Tipo de Relatório", MV_PAR02,_aOpc  , 60 , '' , .T. } )

   _aParRet:={}
   For _nI := 1 To Len( _aParAux )
       AADD( _aParRet , _aParAux[_nI][03] )
   Next 

   IF !ParamBox( _aParAux , _cTitulo, _aParRet , {|| .T. } , , , , , , , .T. , .T. )
       Return .T.
   EndIf

   IF VALTYPE(MV_PAR02) = "C"
      MV_PAR02:=VAL(MV_PAR02)
   ENDIF
   _lMensal:=(MV_PAR02=1)

ENDIF

_cQuery := " SELECT ZZL.R_E_C_N_O_ AS REG_ZZL "
_cQuery += " FROM  "+ RetSQLName("ZZL") +" ZZL "
_cQuery += " WHERE "+ RetSqlCond('ZZL')
_cQuery += " AND ZZL.ZZL_CC <>  ' ' AND ZZL_EMAIL <> ' ' "
_cQuery += " ORDER BY ZZL_NOME"

DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAliasZZL , .T. , .F. )

(_cAliasZZL)->( DBGoTop() )
DO While (_cAliasZZL)->(!Eof())
	ZZL->(DBGOTO((_cAliasZZL)->REG_ZZL))
   If !_lSchedule 
      _cFilial:=cFilAnt//Inicia com cFilAnt para não dar SKIP quando não entra em Nenhum IF abaixo
      IF LEFT(ALLTRIM(ZZL->ZZL_CC),1) = "C" .AND. !_lMensal //NO SEMANAL EU FILTRO SÓ OS COORDENADORES E PEGO TODOS OS GERENTES
         _cFilial:=SUBSTR(ALLTRIM(ZZL->ZZL_CC),3,2)//Filial do Coordenador
      ELSEIF LEFT(ALLTRIM(ZZL->ZZL_CC),1) = "G" .AND. _lMensal//NO MENSAL EU FILTRO SÓ OS GERENTES E PEGO TODOS OS COORDENADORES
         _cFilial:=ALLTRIM(SUBSTR(ALLTRIM(ZZL->ZZL_CC),3))//Filial do Gerente
      ENDIF
      IF !cFilAnt $ _cFilial 
	      (_cAliasZZL)->(DBSKIP())
         LOOP
      ENDIF
   ENDIF
   IF _lSchedule .OR. _lMensal .OR. LEFT(ALLTRIM(ZZL->ZZL_CC),1) <> "G" //Coodernadores 
	   AADD(_aEmail_CC,{ALLTRIM(ZZL->ZZL_EMAIL),ALLTRIM(ZZL->ZZL_CC),ALLTRIM(ZZL->ZZL_NOME),.T.} )
      AADD(_aEmailCC ,{.T.,ALLTRIM(ZZL->ZZL_NOME),ALLTRIM(ZZL->ZZL_CC),ALLTRIM(ZZL->ZZL_EMAIL)} )//LISTBOX
   ENDIF
   IF (!_lSchedule  .AND. _lMensal .AND. LEFT(ALLTRIM(ZZL->ZZL_CC),1) = "G") //GERENTES
	   AADD(_aEmailGG ,{.T.,ALLTRIM(ZZL->ZZL_NOME),ALLTRIM(ZZL->ZZL_CC),ALLTRIM(ZZL->ZZL_EMAIL)} )//LISTBOX
   ENDIF
	(_cAliasZZL)->(DBSKIP())
ENDDO

(_cAliasZZL)->(DBCLOSEAREA())

If !_lSchedule 
   IF  _lMensal
      _aEmailCC:=_aEmailGG
   ENDIF
   IF LEN(_aEmailCC )= 0
      U_ITMSG("Não tem "+IF(_lMensal,"Gerente","Coordenadores")+" no cadastrado de usuarios para a Filial Atual "+cFilAnt,"Atenção","",1)
      RETURN .F.
	ELSEIf U_ITListBox( 'Usuarios / e-mails cadastrados:' , {" ",'NOME' , 'CENTROS DE CUSTO' , 'E-MAIL' } , _aEmailCC , .T. , 2 , 'Selecione os Usuarios: ' )
      lMarcou:=.F.
      IF _lMensal//GERENTES
	   	For _nI := 1 To Len( _aEmailCC )
            IF (_nPos:=ASCAN(_aEmail_CC,{|G|G[1]+G[2]+G[3] == _aEmailCC[_nI,4]+_aEmailCC[_nI,3]+_aEmailCC[_nI,2] })) > 0
	   		   _aEmail_CC[_nPos,4]:=_aEmailCC[_nI,1]
               IF _aEmailCC[_nI,1]
                  _cFilsGerent+=ALLTRIM(SUBSTR(_aEmailCC[_nI,3],3))+";"//Só aqui preenche GERENTES VIA TELA
                  lMarcou:=.T.
               ENDIF
            ENDIF
	   	Next
      ELSE//COORDENADORES
	   	For _nI := 1 To Len( _aEmailCC )
            IF (_nPos:=ASCAN(_aEmail_CC,{|G|G[1]+G[2]+G[3] == _aEmailCC[_nI,4]+_aEmailCC[_nI,3]+_aEmailCC[_nI,2] })) > 0
	   		   _aEmail_CC[_nPos,4]:=_aEmailCC[_nI,1]
               IF _aEmailCC[_nI,1]
                  lMarcou:=.T.
               ENDIF
            ENDIF
	   	Next
      ENDIF
      IF !lMarcou
         U_ITMSG("Não tem "+IF(_lMensal,"Gerente","Coordenador")+" marcado.","Atenção","Marque pelo menos um.",1)
         RETURN .F.
      ENDIF
   ELSE
      RETURN .F.
	EndIf
ENDIF

If _lSchedule 
   _dData:=DATE()
ELSE
   _dData:=MV_PAR01//dDataBase
ENDIF   

IF _lMensal//***************************************  MEMSAL  ***************************************
	If MONTH( _dData ) > 1//DE FEV A DEZ
		MV_PAR01 := STOD(ALLTRIM(STR(YEAR( _dData ))) + STRZERO(( MONTH(_dData)-1),2)+"01")    //INICIO DO MES ANTERIOR
		MV_PAR02 := STOD(ALLTRIM(STR(YEAR( _dData ))) + STRZERO(( MONTH(_dData)  ),2)+"01") - 1//FINAL SO MES ANTERIOR
	Else//SE JANEIRO
		MV_PAR01 := STOD(ALLTRIM(STR( YEAR(_dData)-1 )) + "1201")//INICIO DO MES ANTERIOR
		MV_PAR02 := STOD(ALLTRIM(STR( YEAR(_dData)-1 )) + "1231")//FINAL SO MES ANTERIOR
	Endif
    If _lSchedule 
       REST013Datas()//ENVIA MENSAL DO MES ANTERIOR
    ELSE   
       FWMSGRUN(,{|oProc| REST013Datas(oProc) },'Datas de '+DTOC(MV_PAR01)+" ate "+DTOC(MV_PAR02) ,'Lendo dados Mensais...')//ENVIA MENSAL DO MES ANTERIOR
    ENDIF   
ELSE//***************************************  SEMANAL  ***************************************
   MV_PAR01:=(_dData-7)
   MV_PAR02:=(_dData-1)
   IF DAY(MV_PAR02) < 7 //Se antes do setimo dia do mes atual 

      MV_PAR02:=STOD(ALLTRIM(STR(YEAR( _dData ))) + STRZERO(( MONTH(_dData) ),2)+"01")-1//DE MV_PAR01 ATE O ULTIMO DIA DO MES ANTERIOR
      If _lSchedule 
         REST013Datas()//CHAMA ANTES AQUI PARA QUEBRA DOS MESES - ENVIA PARTE FINAL DO MES ANTERIOR 
      ELSE
         FWMSGRUN(,{|oProc| REST013Datas(oProc) },'Datas de '+DTOC(MV_PAR01)+" ate "+DTOC(MV_PAR02) ,'Lendo dados Semanais...')
      ENDIF   

      MV_PAR01:=STOD(ALLTRIM(STR(YEAR( _dData ))) + STRZERO(( MONTH(_dData) ),2)+"01")
      MV_PAR02:=(_dData-1)////ENVIA PARTE INICIAL DO MES ATUAL - DO DIA PRIMEIRO ATE MV_PAR02

   ENDIF 
   If _lSchedule 
      REST013Datas()//ENVIA PARTE INICIAL DO MES ATUAL SE DAY(MV_PAR02) < 7 SENÃO OS ULTIMOS 7 DIAS 
   ELSE
      FWMSGRUN(,{|oProc| REST013Datas(oProc) },'Datas de '+DTOC(MV_PAR01)+" ate "+DTOC(MV_PAR02) ,'Lendo dados Semanais...')
   ENDIF   
ENDIF

IF _lSchedule
   RESET ENVIRONMENT
ELSEIF LEN(_aResultado) > 0
   U_ITListBox( 'Resultado dos envios' , { "Filial",'Processamento' , 'Registros' ,"E-MAIL ", "Centros de custo","Observações" } , _aResultado , .T. , 1 , )
ELSEIF !_lSchedule
   U_ITMSG("Nao tem dados para o Periodo de "+DTOC(MV_PAR01)+" ate "+DTOC(MV_PAR02),"Atenção",,1)
ENDIF

RETURN .T.
/*
==============================================================================================================================================================
Programa----------: REST013Datas()
Autor-------------: Alex Wallauer
Data da Criacao---: 14/02/2019
Descrição---------: WFW de auditoria de CC entre SA e atendimento de SA
Parametros--------: oProc
Retorno-----------: Nenhum
==============================================================================================================================================================
*/
Static Function REST013Datas(oProc)
LOCAL E
LOCAL lRet:=.T.
PRIVATE lHtml := (GetRemoteType() == 5) //Valida se o ambiente é SmartClientHtml

cMensagem:=""
_aControle:={}//SÓ zerar aqui essa array

FOR E := 1 TO LEN(_aEmail_CC)//LER COORDENADORES

    IF !_aEmail_CC[E,4] .OR. LEFT(_aEmail_CC[E,2],1) <> "C" //Coodernadores
       LOOP
    ENDIF
    _cEmail    :=LOWER(_aEmail_CC[E,1])
    _cCentrosC :=SUBSTR(_aEmail_CC[E,2],3)//Centros de Csuto
    _cFilial   :=SUBSTR(_aEmail_CC[E,2],3,2)//Filial principal do Titulo
    _cEnvPara  :=_aEmail_CC[E,3]
    
    //If !_lSchedule .AND. _lMensal .AND. _cFilial <> cFilAnt
    //   LOOP
    //ENDIF

    IF VALTYPE(oProc) = "O"
       oProc:cCaption := _cTitJanela := ("REST11-Coord.: "+_cFilial+" / "+_aEmail_CC[E,3])
       ProcessMessages()
    ENDIF

    _aCabExcel:={}
    _aGerExcel:={}
    //1 - Relatório para responsáveis por Centro de custo com as baixas de almoxarifado e serviços contratados para o seu CC;
    IF REST013Rel("REST011") .AND. !_lMensal//Enviar detalhado os produtos baixados no CC (usar como referencia o relatório REST011)
       lRet:=REST013Email( {|| REST013Rel("REST011") } )
    ENDIF   

    IF VALTYPE(oProc) = "O"
       oProc:cCaption := _cTitJanela := ("RCOM09-Coord.: "+_cFilial+" / "+_aEmail_CC[E,3])
       ProcessMessages()
    ENDIF
    _cEmail:=LOWER(_aEmail_CC[E,1])//Recarrega pq é alterado quando por tela

    _aCabExcel:={}
    _aGerExcel:={}
    IF REST013Rel("RCOM009").AND. !_lMensal//Enviar separado das informações acima os dados dos serviços contratados, filtrando o cfop 1933/2933 (referencia relatório RCOM009)
       lRet:=REST013Email( {|| REST013Rel("RCOM009") } )
    ENDIF   

    IF !lRet .AND. !_lMensal
       EXIT
    ENDIF
NEXT

lRet:=.F.
FOR E := 1 TO LEN(_aEmail_CC)//LER GERENTES

    IF !_aEmail_CC[E,4] .OR. LEFT(_aEmail_CC[E,2],1) <> "G" //Gerentes
       LOOP
    ENDIF
    
    _cEmail  :=LOWER(_aEmail_CC[E,1])
    _cFilial :=ALLTRIM(SUBSTR(_aEmail_CC[E,2],3))//Filial do Titulo e do Gerente Pode ser varias
    _cEnvPara:=_aEmail_CC[E,3]
    
    If !_lSchedule .AND. _lMensal .AND. !cFilAnt $ _cFilial 
       LOOP
    ENDIF

    IF VALTYPE(oProc) = "O"
       oProc:cCaption := _cTitJanela := ("Gerente: "+_cFilial+" / "+_cEnvPara)
       ProcessMessages()
    ENDIF

    _aCabExcel:={}
    _aGerExcel:={}
    //2 - Relatório para o gerente geral da fábrica com os totais dos CC enviados acima
    IF REST013Rel("TOTAL")
       lRet:=REST013Email( {|| REST013Rel("TOTAL") } )//Sempre retorna .T. para saber que pelos menos enviou 1
    ENDIF   
    IF !lRet
       EXIT
    ENDIF
NEXT    

IF !_lSchedule .AND. _lMensal .AND. !lRet
   AADD(_aResultado,{cFilAnt,"MENSAL",TRANSF(0,"@E 999,999"),"Filial sem Gerente ou Coordenador no cadastrado usuarios.","","Periodo de "+DTOC(MV_PAR01)+" ate "+DTOC(MV_PAR02)})
ENDIF

IF _lSchedule 
   FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "REST013"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "REST01302"/*cMsgId*/, "REST01302 - "+cMensagem/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
ENDIF

RETURN lRet
/*
==============================================================================================================================================================
Programa----------: REST013Rel
Autor-------------: Alex Wallauer
Data da Criacao---: 14/02/2019
Descrição---------: WFW de auditoria de CC entre SA e atendimento de SA
Parametros--------: _nTipo: tipo do relatorio
Retorno-----------: Nenhum
==============================================================================================================================================================
*/
Static Function REST013Rel(cTipo)
LOCAL T , C ,  _nni
PRIVATE _cAlias   := GetNextAlias()
PRIVATE _cTipo    := cTipo
PRIVATE _nPagAux  := 0 //Conta Pagina
PRIVATE aDados    := {}//1                2                3        4         5 (Aplicao Direta)          6                   7               8    9
PRIVATE aTit1     := {"Nr.S.A."    ,"Produto"        ,"Descricao","Data"     ,"AD"               ,"         Entregue","    Custo Total" ,"Usr SA","OBS"}//9 cols
PRIVATE aTit1Excel:= {"Nr.S.A."    ,"Produto"        ,"Descricao","Data"     ,"AD"               ,"         Entregue","    Custo Total" ,"Usr SA","OBS","Filial + CC","Descricao CC"}//11 cols
PRIVATE aTit2     := {"Fornecedor" ,"     Quantidade","Documento","Dt. Dig." ," Valor Unitario"  ,"     Valor Total" ,"Descricao"       }//7 cols
PRIVATE aTit2Excel:= {"Fornecedor" ,"     Quantidade","Documento","Dt. Dig." ," Valor Unitario"  ,"     Valor Total" ,"Descricao"       ,"Filial + CC","Descricao CC"}//9 cols
PRIVATE aTit3     := {"Fil Cod. CC"  ,"Descricao CC"   ,"Custo Total"}//3 cols
IF SuperGetMV("IT_AMBTEST",.F.,.T.) .AND. _lMensal
   aTit3Excel:= {"Filail","CC","Descricao CC"   ,"Custo Total","SELECT","Somou"}//6 cols
ELSE
   aTit3Excel:= {"Filail","CC","Descricao CC"   ,"Custo Total"}//4 cols
ENDIF
PRIVATE _nTotal   := 0
PRIVATE _nPosTotal:= 0//Posicao da coluna de total
PRIVATE _nPosQbra := 0//Posicao da coluna de QUEBRA
PRIVATE _cPicTotal:= "@E 999,999,999.99"
PRIVATE _lRetrato := .F.
PRIVATE _c7CCSintet:= ""
PRIVATE _c6CCSintet:= ""
PRIVATE _c5CCSintet:= ""

IF _cTipo = "REST011"
   _aCabExcel:={}
   For _nni := 1 to len(aTit1Excel)
    	// Alinhamento: 1-Left   ,2-Center,3-Right
    	// Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
    	//            Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
    	IF _nni = 6
      	Aadd(_aCabExcel,{aTit1Excel[_nni]  ,3           ,2         ,.F.})//Entregue
    	ELSEIF _nni = 7
      	Aadd(_aCabExcel,{aTit1Excel[_nni]  ,3           ,3         ,.F.})//Custo Total
    	ELSEIF _nni = 4 
      	Aadd(_aCabExcel,{aTit1Excel[_nni]  ,2           ,4         ,.F.})//DATA
      ELSE
    	   Aadd(_aCabExcel,{aTit1Excel[_nni]  ,1           ,1         ,.F.})//CARACTER
    	ENDIF
   Next

   MV_PAR07:=""
   _aCC:=StrToKarr(_cCentrosC,";")
   FOR C := 1 TO LEN(_aCC)
       IF !EMPTY(_aCC[C])
          IF LEN(_aCC[C]) > 7
             MV_PAR07+=_aCC[C]+";"//LISTA DE FILIA+CC DO ZZL->ZZL_CC
          ELSEIF LEN(_aCC[C]) = 7
             _c7CCSintet+=_aCC[C]+";"//LISTA DE FILIA+CC DO ZZL->ZZL_CC - SINTETICO
          ELSEIF LEN(_aCC[C]) = 6
             _c6CCSintet+=_aCC[C]+";"//LISTA DE FILIA+CC DO ZZL->ZZL_CC - SINTETICO
          ELSEIF LEN(_aCC[C]) = 5
             _c5CCSintet+=_aCC[C]+";"//LISTA DE FILIA+CC DO ZZL->ZZL_CC - SINTETICO
          ENDIF   
       ENDIF   
   NEXT

   _cCentro   :=MV_PAR07+_c7CCSintet+_c6CCSintet+_c5CCSintet
   _cCentro   :=LEFT(_cCentro,LEN(_cCentro)-1)
   _c5CCSintet:=LEFT(_c5CCSintet,LEN(_c5CCSintet)-1)
   _c6CCSintet:=LEFT(_c6CCSintet,LEN(_c6CCSintet)-1)
   _c7CCSintet:=LEFT(_c7CCSintet,LEN(_c7CCSintet)-1)
   MV_PAR07   :=LEFT(MV_PAR07,LEN(MV_PAR07)-1)

ELSEIF _cTipo = "RCOM009"
   _aCabExcel:={}
   For _nni := 1 to len(aTit2Excel)
    	// Alinhamento: 1-Left   ,2-Center,3-Right
    	// Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
    	//            Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
    	IF _nni = 2
      	Aadd(_aCabExcel,{aTit2Excel[_nni]  ,3           ,2         ,.F.})//Quantidade
    	ELSEIF _nni = 5 .and. _nni = 6
      	Aadd(_aCabExcel,{aTit2Excel[_nni]  ,3           ,3         ,.F.})//Custo Total
    	ELSEIF _nni = 4 
      	Aadd(_aCabExcel,{aTit2Excel[_nni]  ,2           ,4         ,.F.})//DATA
      ELSE
    	   Aadd(_aCabExcel,{aTit2Excel[_nni]  ,1           ,1         ,.F.})//CARACTER
    	ENDIF
   Next

   MV_PAR03:="1000"
   MV_PAR04:="1000"
   MV_PAR07:=MV_PAR01
   MV_PAR08:=MV_PAR02
   MV_PAR17:="1933;2933"
   MV_PAR18:=""
   _aCC:=StrToKarr(_cCentrosC,";")
   FOR C := 1 TO LEN(_aCC)
       IF !EMPTY(_aCC[C])
          IF LEN(_aCC[C]) > 7
             MV_PAR18+=_aCC[C]+";"//LISTA DE FILIA+CC DO ZZL->ZZL_CC
          ELSEIF LEN(_aCC[C]) = 7
             _c7CCSintet+=_aCC[C]+";"//LISTA DE FILIA+CC DO ZZL->ZZL_CC - SINTETICO
          ELSEIF LEN(_aCC[C]) = 6
             _c6CCSintet+=_aCC[C]+";"//LISTA DE FILIA+CC DO ZZL->ZZL_CC - SINTETICO
          ELSEIF LEN(_aCC[C]) = 5
             _c5CCSintet+=_aCC[C]+";"//LISTA DE FILIA+CC DO ZZL->ZZL_CC - SINTETICO
          ENDIF   
       ENDIF   
   NEXT
   _cCentro   :=MV_PAR18+_c7CCSintet+_c6CCSintet+_c5CCSintet
   _cCentro   :=LEFT(_cCentro,LEN(_cCentro)-1)
   _c5CCSintet:=LEFT(_c5CCSintet,LEN(_c5CCSintet)-1)
   _c6CCSintet:=LEFT(_c6CCSintet,LEN(_c6CCSintet)-1)
   _c7CCSintet:=LEFT(_c7CCSintet,LEN(_c7CCSintet)-1)
   MV_PAR18   :=LEFT(MV_PAR18,LEN(MV_PAR18)-1)

ELSEIF _cTipo = "TOTAL"

   _aCabExcel:={}
   For _nni := 1 to len(aTit3Excel)
    	// Alinhamento: 1-Left   ,2-Center,3-Right
    	// Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
    	//            Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
    	IF _nni = 4 .OR. _nni = 6
      	Aadd(_aCabExcel,{aTit3Excel[_nni]  ,3           ,3         ,.F.})//MONETARIO
      ELSE
    	   Aadd(_aCabExcel,{aTit3Excel[_nni]  ,1           ,1         ,.F.})//CARACTER
    	ENDIF
   Next
  aDados:={}
  _cCentro:=""
  _aGerExcel:={}
  _aDadosTotal:=ASORT(_aDadosTotal,,,{|x,y| x[4] > y[4] })
  FOR T := 1 TO LEN(_aDadosTotal)
      IF LEFT(_aDadosTotal[T,1],2) $ _cFilial
         AADD(aDados    , {LEFT(_aDadosTotal[T,1],2)+" "+SUBSTR(_aDadosTotal[T,1],3),_aDadosTotal[T,2],_aDadosTotal[T,3]} )
         AADD(_aGerExcel, {LEFT(_aDadosTotal[T,1],2),SUBSTR(_aDadosTotal[T,1],3),_aDadosTotal[T,2],_aDadosTotal[T,4]} )
         _cCentro+=_aDadosTotal[T,1]+";"//SUBSTR(_aDadosTotal[T,1],3)+" / "
         _nTotal+=_aDadosTotal[T,4]
      ENDIF    
  NEXT 
  _cCentro  :=LEFT(_cCentro,LEN(_cCentro)-1)
  _lRetrato :=.T.
  _nPosTotal:=3//Posicao da coluna de total
  nTotal    :=LEN(aDados)
  cMensagem +=_cTipo+": "+ALLTRIM(STR(nTotal))+" Registros lidos - Email Para "+_cEmail+" - CC: "+_cCentro+CHR(13)+CHR(10)
  AADD(_aResultado,{_cFilial,"MENSAL",TRANSF(nTotal,"@E 999,999"),_cEmail,_cCentro,"Periodo de "+DTOC(MV_PAR01)+" ate "+DTOC(MV_PAR02)})
  _cCentro  +=";CCQtde: "+ALLTRIM(STR(nTotal))

  IF nTotal = 0
     RETURN .F.
  ENDIF

ENDIF

//SÓ ENTRA AQUI QUANDO _cTipo = "REST011" OU _cTipo = "RCOM009"
If _lSchedule .AND. LEN(aDados) = 0//Preenche aDados acima no _cTipo = "TOTAL"
//SEM TELA 
   REST013Select()

   IF Select(_cAlias) = 0
      RETURN .F.
   ENDIF
   (_cAlias)->( DBGoTop() )
   nTotal:=0
   COUNT TO nTotal

   cMensagem+=_cTipo+": "+ALLTRIM(STR(nTotal))+" Registros lidos - Email para "+_cEmail+CHR(13)+CHR(10)

   IF nTotal = 0
      (_cAlias)->(DBCLOSEAREA())
      RETURN .F.
   ENDIF

   REST013Ler()
   IF _lMensal
      aDados:={}//Zera pq já preenchei o _aDadosTotal e não precisa gerar os relatorios "REST011" e "RCOM009" no mensal
   ENDIF   

//SÓ ENTRA AQUI QUANDO _cTipo = "REST011" OU _cTipo = "RCOM009"
ELSEIf LEN(aDados) = 0//Preenche aDados acima quando no _cTipo = "TOTAL"
//COM TELA 

//   LjMsgRun( "SELECT: Lendo Dados: "+_cTipo , _cTitJanela , {|| REST013Select() } )
   REST013Select() 

   IF Select(_cAlias) = 0
      RETURN .F.
   ENDIF
   (_cAlias)->( DBGoTop() )
   nTotal:=0
   COUNT TO nTotal

   IF nTotal = 0
      (_cAlias)->(DBCLOSEAREA())
      RETURN .F.
   ENDIF

// AADD(_aResultado,{_cFilial,"SEMANAL ["+_cTipo+"]",TRANSF(nTotal,"@E 999,999"),_cEmail,_cCentrosC,"Periodo de "+DTOC(MV_PAR01)+" ate "+DTOC(MV_PAR02)})
   AADD(_aResultado,{_cFilial,"SEMANAL ["+_cTipo+"]",       nTotal              ,_cEmail,_cCentrosC,"Periodo de "+DTOC(MV_PAR01)+" ate "+DTOC(MV_PAR02)})
   
   FwMsgRun( ,{|oProc|  REST013Ler(oProc) } , "Aguarde!" , "Acumulando Dados: "+_cTipo+TRANSF(nTotal,"@E 999,999")  )

   IF _lMensal
      aDados:={}//Zera pq já preenchei o _aDadosTotal e não precisa gerar os relatorios "REST011" e "RCOM009" no mensal
   ENDIF   

ENDIF

If LEN(aDados) > 0

    _cFileName:=UPPER(REST013NameFile())
    If _lSchedule 
       //_cPathSrv:="/spool/"//GETMV("MV_RELT",,"\spool\")
       //FWMsPrinter(): New (< cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF], [ nQtdCopy] )
	   _oPrint := FWMsPrinter():New(_cFileName, IMP_PDF   , .T.               , _cPathSrv       , .T.             ,            ,                ,            , .T. )
    ELSE
      //IF lHtml
      //   _cPathSrv:=GETMV("MV_RELT",,"\spool\")
      //ELSE
      //   _cPathSrv:="c:\smartclient\"
      //ENDIF
       //FWMsPrinter(): New (< cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF], [ nQtdCopy] )
	   _oPrint := FWMsPrinter():New(_cFileName, IMP_PDF   , .T.               , _cPathSrv       , .T.             ,            ,                ,)
	   IF UPPER(_oPrint:cPathPDF) == "C:\" .OR. EMPTY(_oPrint:cPathPDF)
          _oPrint:cPathPDF := _cPathSrv
	   ENDIF
    ENDIF
    //=====================================
    // Configura modo Paisagem de Impressao
    _oPrint:SetResolution(78)
    IF _lRetrato
       _oPrint:SetPortrait()
    ELSE   
       _oPrint:SetLandscape()
    ENDIF   

    //=============================
    // Define impressao em papel A4
    _oPrint:SetPaperSize(DMPAPER_A4)
    _oPrint:SetMargin(0,0,0,0)	// nEsquerda, nSuperior, nDireita, nInferior

    //=========================================================
    // Se enviar por e-mail nao abre o arquivo apos a impressao
    If _lSchedule //Aqui é sempre Exporta PDF via e-mail

//**** Configuracoes para via WF de Carga **********************************************************************************
       _oPrint:SetViewPDF(.F.)
       _oPrint:cPathPDF := _cPathSrv	// Caso seja utilizada impressão em IMP_PDF
//**** Configuracoes para via WF  **********************************************************************************


	   //====================================================================================================
	   // Chama a impressão
       REST013CMP( @_oPrint ) 
	   //====================================================================================================
       _oPrint:lViewPDF := .F.
       _oPrint:Preview()
       SLEEP(2000)//dá um tempinho para criar o arquivo
       FreeObj(_oPrint)
       _cFileName:=_cPathSrv+_cFileName      
       _adatfile := directory(_cFilename)
       If file(_cFilename)
	      _adatfile := directory(_cFilename)
	      _ntamanho := _adatfile[1][2]
	   Else
	      _ntamanho := 0
	   Endif
       
    ELSE

	   //====================================================================================================
	   // Chama a impressão
       LjMsgRun( "Criando Layout: "+_cTipo , _cTitJanela , {|| REST013CMP( @_oPrint ) } )
	   //====================================================================================================
       
       //IF _lEnviaEmail .OR. .T.//U_ITMSG("Confirma envio do e-mail para "+_cEmail+" ?",_cTipo,"Periodo de "+DTOC(MV_PAR01)+" ate "+DTOC(MV_PAR02),3,2,2)
          _cPathSrv:=_oPrint:cPathPDF
          _oPrint:lViewPDF := .F.
  	      //_lEnviaEmail:=.T.
	   //ENDIF    
       
       LjMsgRun( "Gerando PDF: "+_cPathSrv+_cFilename , _cTitJanela , {|| _oPrint:Preview() } )//Visualiza antes de imprimir

       FreeObj(_oPrint)
       _cFileName:=_cPathSrv+_cFileName      
       _adatfile := directory(_cFilename)
       If file(_cFilename)
	      _adatfile := directory(_cFilename)
	      _ntamanho := _adatfile[1][2]
	   Else
	      _ntamanho := 0
	   Endif

    ENDIF

ELSEIF !_lMensal

    If !_lSchedule 
       AADD(_aResultado,{_cFilial,"SEMANAL ["+_cTipo+"]",TRANSF(0,"@E 999,999"),_cEmail,_cCentrosC,"Periodo de "+DTOC(MV_PAR01)+" ate "+DTOC(MV_PAR02)})
    ENDIF
    
    Return .F.

EndIf

Return .T.
/*
==============================================================================================================================================================
Programa----------: REST013Ler()
Autor-------------: Alex Wallauer
Data da Criacao---: 14/02/2019
Descrição---------: Ler SELECTs e grava e arrays
Parametros--------: Nenhum
Retorno-----------: Nenhum
==============================================================================================================================================================
*/
Static Function REST013Ler(oProc)
LOCAL _nConta:=0 , nTam:=82 , nTamB1 := 80
DBSelectArea(_cAlias)
(_cAlias)->( DBGoTop() )
DO While (_cAlias)->(!Eof())

   _nConta++
   IF VALTYPE(oProc) = "O"
       oProc:cCaption := ("Lendo: "+ STRZERO(_nConta,6) + " de " + strzero(nTotal,6))
       ProcessMessages()
   ENDIF
   
   IF _cTipo = "REST011"
    
      cObs1:=LEFT(   (_cAlias)->D3_I_OBS ,nTam)
      cObs2:=SUBSTR( (_cAlias)->D3_I_OBS ,nTam+1,nTam )
      cObs3:=SUBSTR( (_cAlias)->D3_I_OBS ,nTam+nTam+1 )
		
		aItem:={}//{"Nr.S.A."   ,"Produto"        ,"Descricao","Data"     ,"AD"(Aplicao Direta)  ,"         Entregue","    Custo Total" ,"Usr SA","OBS"}
   	AADD(aItem,(_cAlias)->D3_NUMSA)                                            //01
		AADD(aItem,(_cAlias)->CP_PRODUTO)                                          //02
		AADD(aItem,LEFT((_cAlias)->CP_DESCRI,32))                                  //03
		AADD(aItem,DTOC(STOD((_cAlias)->D3_EMISSAO)))                              //04
		_nPosData:=LEN(aItem)
		AADD(aItem,IF((_cAlias)->D3_I_ORIGE="MATA103"," S"," N"))                  //05
		AADD(aItem,TRANSF((_cAlias)->D3_QUANT, _cPicTotal))                        //06
		_nPosQtde:=LEN(aItem)
		AADD(aItem,TRANSF((_cAlias)->D3_CUSTO1,_cPicTotal))                        //07
		_nPosTotal:=LEN(aItem)//Posicao da coluna de total    
		AADD(aItem,(_cAlias)->CP_SOLICIT)                                          //08
		AADD(aItem,cObs1)                                                          //09
      _nPosOBS:=LEN(aItem)  //Posicao da coluna Descricao
		AADD(aItem,(_cAlias)->D3_FILIAL+(_cAlias)->D3_CC)                          //10
		_nPosQbra :=LEN(aItem)//Posicao da Quebra DE FIL + CC
		AADD(aItem,Posicione("CTT",1,xFilial("CTT")+(_cAlias)->D3_CC,"CTT_DESC01"))//11
		AADD(aItem,(_cAlias)->D3_CUSTO1)                                           //12

		_nTotal+=(_cAlias)->D3_CUSTO1

		AADD(aDados,aItem)
      aItemE:=ACLONE(aItem)
      ASIZE(aItemE,(_nPosQbra+1)) //POE PARA O Tamanho do Cabeçalho  do Excel
		AADD(_aGerExcel,aItemE)
      _aGerExcel[LEN(_aGerExcel),_nPosData ]:=STOD((_cAlias)->D3_EMISSAO)
      _aGerExcel[LEN(_aGerExcel),_nPosQtde ]:=(_cAlias)->D3_QUANT
      _aGerExcel[LEN(_aGerExcel),_nPosTotal]:=(_cAlias)->D3_CUSTO1
      _aGerExcel[LEN(_aGerExcel),_nPosOBS  ]:=(_cAlias)->D3_I_OBS
      _aGerExcel[LEN(_aGerExcel),_nPosQbra ]:=(_cAlias)->D3_FILIAL+" "+(_cAlias)->D3_CC
    
		IF !EMPTY(cObs2)
		   aItem:={}//{"Nr.S.A.","Produto Descricao","Data","AD","Entregue Bx","Custo Total","Usr SA","OBS"}
   		AADD(aItem,"")
   		AADD(aItem,"")
   		AADD(aItem,"")
   		AADD(aItem,"")
   		AADD(aItem,"")
   		AADD(aItem,"")
   		AADD(aItem,"")
   		AADD(aItem,"")
		   AADD(aItem,cObs2)
		   AADD(aItem,(_cAlias)->D3_FILIAL+(_cAlias)->D3_CC)                          //10
		   AADD(aItem,Posicione("CTT",1,xFilial("CTT")+(_cAlias)->D3_CC,"CTT_DESC01"))//11
   		AADD(aItem,0)
		   AADD(aDados,aItem)
		ENDIF
		IF !EMPTY(cObs3)
		   aItem:={}//{"Nr.S.A.","Produto Descricao","Data","AD","Entregue Bx","Custo Total","Usr SA","OBS"}
   		AADD(aItem,"")
   		AADD(aItem,"")
   		AADD(aItem,"")
   		AADD(aItem,"")
   		AADD(aItem,"")
   		AADD(aItem,"")
   		AADD(aItem,"")
   		AADD(aItem,"")
		   AADD(aItem,cObs3)
		   AADD(aItem,(_cAlias)->D3_FILIAL+(_cAlias)->D3_CC)                          //10
		   AADD(aItem,Posicione("CTT",1,xFilial("CTT")+(_cAlias)->D3_CC,"CTT_DESC01"))//11
   		AADD(aItem,0)
		   AADD(aDados,aItem)
		ENDIF
		
	   AADD(_aAnaliTotal , { (_cAlias)->D3_FILIAL , (_cAlias)->D3_CC , _cEmail , (_cAlias)->D3_CUSTO1 , "REST011", 0 } )

		IF (nPos:=ASCAN(_aDadosTotal,{ |T| T[1] == (_cAlias)->D3_FILIAL+(_cAlias)->D3_CC } ) ) = 0 
		   AADD( _aDadosTotal , {(_cAlias)->D3_FILIAL+(_cAlias)->D3_CC , Posicione("CTT",1,xFilial("CTT")+(_cAlias)->D3_CC,"CTT_DESC01") , TRANSF((_cAlias)->D3_CUSTO1,_cPicTotal) , (_cAlias)->D3_CUSTO1} )
         AADD(  _aControle  , (_cAlias)->D3_FILIAL+(_cAlias)->D3_CC+_cEmail )
         _aAnaliTotal[LEN(_aAnaliTotal),6]:=(_cAlias)->D3_CUSTO1
		ELSEIF ASCAN(_aControle ,(_cAlias)->D3_FILIAL+(_cAlias)->D3_CC+_cEmail) <> 0
         _aDadosTotal[nPos,4]+=(_cAlias)->D3_CUSTO1
         _aDadosTotal[nPos,3]:=TRANSF(_aDadosTotal[nPos,4],_cPicTotal)
         _aAnaliTotal[LEN(_aAnaliTotal),6]:=(_cAlias)->D3_CUSTO1
		ENDIF    
		
	ELSEIF _cTipo = "RCOM009"
		
      cObs1:=LEFT(   (_cAlias)->B1_DESC ,nTamB1)
      cObs2:=SUBSTR( (_cAlias)->B1_DESC ,nTamB1+1 )

		aItem:={}//{"Fornecedor","Quantidade","Documento","Dt.Dig.","Vlr. Unit.","Valor","Descricao"}
		AADD(aItem,(_cAlias)->RAZAO)                                                 //01
		AADD(aItem,TRANSF((_cAlias)->D1_QUANT,_cPicTotal))                           //02
		_nPosQtde:=LEN(aItem)
		AADD(aItem,(_cAlias)->D1_DOC)                                                //03
		AADD(aItem,DTOC(STOD((_cAlias)->D1_DTDIGIT)))                                //04
		_nPosData:=LEN(aItem)
		AADD(aItem,TRANSF((_cAlias)->D1_VUNIT,_cPicTotal))                           //05
		_nPosUNIT:=LEN(aItem)
		AADD(aItem,TRANSF((_cAlias)->D1_TOTAL,_cPicTotal))                           //06
		_nPosTotal:=LEN(aItem)//Posicao da coluna de total
		AADD(aItem,cObs1)                                                            //07
      _nPosOBS:=LEN(aItem)  //Posicao da coluna Descricao
		AADD(aItem,(_cAlias)->D1_FILIAL+(_cAlias)->D1_CC)                            //08
		_nPosQbra :=LEN(aItem)//Posicao da Quebra DE FIL + CC
		AADD(aItem,Posicione("CTT",1,xFilial("CTT")+(_cAlias)->D1_CC,"CTT_DESC01"))  //09
		AADD(aItem,(_cAlias)->D1_TOTAL)							                          //10

		_nTotal+=(_cAlias)->D1_TOTAL
		
		AADD(aDados,aItem)
      aItemE:=ACLONE(aItem)
      ASIZE(aItemE,(_nPosQbra+1)) //POE PARA O Tamanho do Cabeçalho do Excel
		AADD(_aGerExcel,aItemE)
      _aGerExcel[LEN(_aGerExcel),_nPosQtde ]:=(_cAlias)->D1_QUANT
      _aGerExcel[LEN(_aGerExcel),_nPosData ]:=STOD((_cAlias)->D1_DTDIGIT)
      _aGerExcel[LEN(_aGerExcel),_nPosUNIT ]:=(_cAlias)->D1_VUNIT
      _aGerExcel[LEN(_aGerExcel),_nPosTotal]:=(_cAlias)->D1_TOTAL
      _aGerExcel[LEN(_aGerExcel),_nPosOBS  ]:=(_cAlias)->B1_DESC
      _aGerExcel[LEN(_aGerExcel),_nPosQbra ]:=(_cAlias)->D1_FILIAL+" "+(_cAlias)->D1_CC

		IF !EMPTY(cObs2)
		   aItem:={}//{"Fornecedor","Quantidade","Documento","Dt.Dig.","Vlr. Unit.","Valor","Descricao"}
   		AADD(aItem,"")
   		AADD(aItem,"")
   		AADD(aItem,"")
   		AADD(aItem,"")
   		AADD(aItem,"")
   		AADD(aItem,"")
		   AADD(aItem,cObs2)
		   AADD(aItem,(_cAlias)->D1_FILIAL+(_cAlias)->D1_CC)                            //08
		   AADD(aItem,Posicione("CTT",1,xFilial("CTT")+(_cAlias)->D1_CC,"CTT_DESC01"))  //09
		   AADD(aItem,0) 							                                            //10
		   AADD(aDados,aItem)
		ENDIF

	   AADD(_aAnaliTotal , { (_cAlias)->D1_FILIAL , (_cAlias)->D1_CC, _cEmail  , (_cAlias)->D1_TOTAL , "RCOM009" , 0} )

		IF (nPos:=ASCAN(_aDadosTotal,{ |T| T[1] == (_cAlias)->D1_FILIAL+(_cAlias)->D1_CC } ) ) = 0 
		   AADD( _aDadosTotal , {(_cAlias)->D1_FILIAL+(_cAlias)->D1_CC , Posicione("CTT",1,xFilial("CTT")+(_cAlias)->D1_CC,"CTT_DESC01") , TRANSF((_cAlias)->D1_TOTAL,_cPicTotal) , (_cAlias)->D1_TOTAL} )
         AADD(  _aControle , (_cAlias)->D1_FILIAL+(_cAlias)->D1_CC+_cEmail )
         _aAnaliTotal[LEN(_aAnaliTotal),6]:=(_cAlias)->D1_TOTAL
		ELSEIF ASCAN(_aControle , (_cAlias)->D1_FILIAL+(_cAlias)->D1_CC+_cEmail) <> 0
         _aDadosTotal[nPos,4]+=(_cAlias)->D1_TOTAL
         _aDadosTotal[nPos,3]:=TRANSF(_aDadosTotal[nPos,4],_cPicTotal)
         _aAnaliTotal[LEN(_aAnaliTotal),6]:=(_cAlias)->D1_TOTAL
		ENDIF    
		
	ENDIF
	
	(_cAlias)->( DBSkip() )
EndDo
		
(_cAlias)->( DBCloseArea() )

RETURN .T.
/*
===============================================================================================================================
Programa----------: REST013CMP
Autor-------------: Alexandre Villar
Data da Criacao---: 03/12/2014
Descrição---------: Função para imprimir os dados
Parametros--------: _oPrint := Objeto de impressão do relatório
------------------: _nLinha := Controle de posicionamento de linhas
Retorno-----------: Nenhum
===============================================================================================================================*/
Static Function REST013CMP( _oPrint )

Local _aResumo	:= {}
Local L , C
Local _nColIni	:= 0100
Local _nLinha   := 0
Local _nTotFOR  := 0
//Configuracoes para "Exporta para PDF" / Envio via e-mail
Local _oFont14 	 := TFont():New( "Arial"	 ,, 14,,.T.)
Local _oFontCour := TFont():New('Courier new',, 12,,.F.)
Local _oFont1Cour:= TFont():New('Courier new',, 12,,.T.)
PRIVATE _nColMax	:= 3280 //ULTIMA COLUNA
PRIVATE _nColFimPDH := _nColMax-940//Pagina,Data e hora
//Configuracoes para "Exporta para PDF" / Envio via e-mail
PRIVATE _nLinMax	:= 2180 //LINHA MAXIMA PARA QUEBRA
PRIVATE _aPosicao:= {}//Preenchida na REST013Sub()

If !_lSchedule .AND. !(_oPrint:CPRINTER == "PDF")// _oPrint:CPRINTER == "PDF" quer dizer Exporta PDF via seleção na Tela
   //**** Configuracoes para "Envia para Spool de impressao **********************************************************************************
   _nColMax	   := 3230//ULTIMA COLUNA
   _nColFimPDH := _nColMax-900//Pagina,Data e hora
   //**** Configuracoes para "Envia para Spool de impressao **********************************************************************************
ENDIF
IF _lRetrato
   _nColMax	   := 2530//ULTIMA COLUNA
   _nColFimPDH := _nColMax-940//Pagina,Data e hora
   _nLinMax	   := 3100//LINHA MAXIMA PARA QUEBRA
ENDIF

_oPrint:StartPage()
	
REST013CAB( @_oPrint , @_nLinha  , _nColIni )
REST013Sub(_nColIni,_oPrint,@_nLinha,_oFont14)

_aResumo := aDados

IF _cTipo <> "TOTAL"//QUEBRA DE TOTOAL POR CC
   _cSalvaCC:=_aResumo[1,_nPosQbra]
   _nTotalQBG:=0
   _nTotFOR:=_nPosQbra-1
ELSE
   _nTotFOR:=LEN(_aResumo[1])
ENDIF   

For L := 1 to Len(_aResumo)
		
	If _nLinha >= _nLinMax
		
		_oPrint:Line( _nLinha , _nColIni , _nLinha , _nColMax )
		
		_oPrint:EndPage()
		_oPrint:StartPage()
		
		REST013CAB( @_oPrint , @_nLinha  , _nColIni)
    	REST013Sub(_nColIni,_oPrint,@_nLinha,_oFont14)
		
	EndIf

	IF _cTipo <> "TOTAL"
		IF _cSalvaCC <> _aResumo[L,_nPosQbra]//QUEBRA DE TOTOAL POR CC
	        _nLinha -= 025
			_oPrint:Line( _nLinha , _nColIni , _nLinha , _nColMax )
			_nLinha += 040
			_oPrint:Say( _nLinha,_aPosicao[1],"TOTAL "+SUBSTR(_aResumo[L-1,_nPosQbra],1,2)+"-"+SUBSTR(_aResumo[L-1,_nPosQbra],3)+"-"+_aResumo[L-1,_nPosQbra+1],_oFont1Cour )
			_oPrint:Say( _nLinha,_aPosicao[_nPosTotal],TRANSF(_nTotalQBG,_cPicTotal),_oFont1Cour )
			_nTotalQBG:=0
			_cSalvaCC :=_aResumo[L,_nPosQbra]
			_nTotalQBG+=_aResumo[L,_nPosQbra+2]
	        _nLinha += 080
		ELSE
			_nTotalQBG+=_aResumo[L,_nPosQbra+2]
		ENDIF
	ENDIF

    FOR C := 1 TO _nTotFOR

        _oPrint:Say( _nLinha,_aPosicao[C],_aResumo[L,C],_oFontCour )
	         
    NEXT C
	_nLinha += 050

Next L

IF _cTipo <> "TOTAL"
	_oPrint:Line( _nLinha , _nColIni , _nLinha , _nColMax )
	_nLinha += 050
	_oPrint:Say( _nLinha,_aPosicao[1],"TOTAL "+SUBSTR(_aResumo[L-1,_nPosQbra],1,2)+"-"+SUBSTR(_aResumo[L-1,_nPosQbra],3)+"-"+_aResumo[L-1,_nPosQbra+1],_oFont1Cour )
	_oPrint:Say( _nLinha,_aPosicao[_nPosTotal],TRANSF(_nTotalQBG,_cPicTotal),_oFont1Cour )
	_nLinha += 050
ENDIF

_oPrint:Line( _nLinha , _nColIni , _nLinha , _nColMax )
_nLinha += 050
_oPrint:Say( _nLinha,_aPosicao[1],"TOTAL GERAL",_oFont1Cour )
_oPrint:Say( _nLinha,_aPosicao[_nPosTotal],TRANSF(_nTotal,_cPicTotal),_oFont1Cour )

Return()
/*
===============================================================================================================================
Programa----------: REST013CAB
Autor-------------: Alexandre Villar
Data da Criacao---: 24/02/2014
Descrição---------: Função para construir o cabeçalho da página
Parametros--------: _oPrint := Objeto de impressão do relatório
------------------: _nLinha := Controle de posicionamento de linhas
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function REST013CAB( _oPrint , _nLinha , _nColIni )
Local _oFont10	:= TFont():New( "Arial" ,, 14 ,,.T. )
Local _oFont18	:= TFont():New( "Arial" ,, 28 ,,.T. )

_nLinha := 50
_nPagAux++

_oPrint:Line( _nLinha, _nColIni , _nLinha, _nColMax )
_nlinha += 015

_oPrint:SayBitmap( _nLinha-8, _nColIni + 020 , 'lgrl01.bmp' , 300 , 130 ) // Imagem tem que estar abaixo do RootPath

IF _cTipo = "REST011"
   _nSomaCol1:=0865
   _nSomaCol2:=0//1200
   _nSomaCol3:=0//1080
   _cAssunto :="Relação produtos consumidos no CC"
ELSEIF _cTipo = "RCOM009"
   _nSomaCol1:=0800
   _nSomaCol2:=0//1200
   _nSomaCol3:=0//1080
   _cAssunto :="Relação de serviços contratados no CC"
ELSEIF _cTipo = "TOTAL"
   _nSomaCol1:=0820
   _nSomaCol2:=0//0950
   _nSomaCol3:=0//0810
   _cAssunto :="Relação gastos por CC "
ENDIF

_cNomeFilial:='Filial: '+ _cFilial +' - '+ AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , "01" + _cFilial, 1, "" ))
_oPrint:Say( _nLinha+60 ,(_nColIni+_nSomaCol1), _cAssunto   , _oFont18 )
_oPrint:Say( _nLinha+135,(_nColIni+_nSomaCol2), _cNomeFilial, _oFont10 )

_oPrint:SayAlign( _nLinha,_nColFimPDH, 'Página: '+ StrZero(_nPagAux,3)	, _oFont10 ,900,100,, 1 )
_nLinha += 060

_oPrint:SayAlign( _nLinha,_nColFimPDH, 'Data: '+ DtoC( Date() )	    , _oFont10 ,900,100,, 1 )
_nLinha += 055

_oPrint:SayAlign( _nLinha,_nColFimPDH, 'Hora: '+ Time()			    , _oFont10 ,900,100,, 1 )
_nLinha += 060

_cDts:="Periodo: "+_cDatas
IF _lMensal
   _cDts+= " - MENSAL"
ELSE
   _cDts+= " - SEMANAL"
ENDIF   
_oPrint:Say( _nLinha,(_nColIni+_nSomaCol3), _cDts , _oFont10 )
_nLinha += 015

_oPrint:Line( _nLinha , _nColIni , _nLinha, _nColMax )
_nLinha += 040

Return()
/*
===============================================================================================================================
Programa----------: REST013Sub()
Autor-------------: Alex Wallauer
Data da Criacao---: 24/06/2014
Descrição---------: Imprimie os cabecalho  das colulas dos pedidos
Parametros--------: 
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function REST013Sub(_nColIni,_oPrint,_nLinha,_oFont14)
LOCAL aTitulo:={aTit1,aTit2,aTit3} , R 
LOCAL nTipo:=1
_aPosicao:={}

//IF  _lSchedule .OR. _oPrint:CPRINTER == "PDF"//_oPrint:CPRINTER == "PDF" quer dizer Exporta PDF via tela

IF _cTipo = "REST011"
//aTit1:={"Nr.S.A.","Produto","Descricao","Data","Entregue","Custo Total","Usr SA","OBS"}
	_nCol002:= _nColIni + 0140 //Produto
	_nCol003:= _nCol002 + 0200 //Descricao       
	_nCol004:= _nCol003 + 0550 //Data            
	_nCol00A:= _nCol004 + 0170 //APLICACAO DIRETA - ENTROU DEPOIS
	_nCol005:= _nCol004 + 0240 //Entregue        
	_nCol006:= _nCol005 + 0260 //Custo Total     
	_nCol007:= _nCol006 + 0250 //Usr SA
	_nCol008:= _nCol007 + 0190 //OBS
	
	AADD(_aPosicao,_nColIni)//Nr.S.A.
	AADD(_aPosicao,_nCol002)
	AADD(_aPosicao,_nCol003)
	AADD(_aPosicao,_nCol004)
	AADD(_aPosicao,_nCol00A)
	AADD(_aPosicao,_nCol005)
	AADD(_aPosicao,_nCol006)
	AADD(_aPosicao,_nCol007)
	AADD(_aPosicao,_nCol008)
	
ELSEIF _cTipo = "RCOM009"
//aTit2:={"Fornec","Rz.Social","Qtd.","Documento","Dt.Dig.","Vlr. Unit.","Valor","Descricao"}
	nTipo:=2
	_nCol002:= _nColIni + 0665
	_nCol003:= _nCol002 + 0250
	_nCol004:= _nCol003 + 0225
	_nCol005:= _nCol004 + 0215
	_nCol006:= _nCol005 + 0250
	_nCol007:= _nCol006 + 0250
	
	AADD(_aPosicao,_nColIni)
	AADD(_aPosicao,_nCol002)
	AADD(_aPosicao,_nCol003)
	AADD(_aPosicao,_nCol004)
	AADD(_aPosicao,_nCol005)
	AADD(_aPosicao,_nCol006)
	AADD(_aPosicao,_nCol007)
	
ELSEIF _cTipo = "TOTAL"
//aTit3:={"Fil Cod. CC","Centro de Custo","Custo Total"}	
	nTipo:=3
	_nCol002:= _nColIni + 0300
	_nCol003:= _nCol002 + 0800
	AADD(_aPosicao,_nColIni)
	AADD(_aPosicao,_nCol002)
	AADD(_aPosicao,_nCol003)
	
ENDIF
//ENDIF

FOR R := 1 TO LEN(aTitulo[nTipo]) //Os titulos que determinam quantas colunas serão impressao

    _oPrint:Say( _nLinha,_aPosicao[R],aTitulo[nTipo,R],_oFont14 )

NEXT

_nLinha += 050
		
Return .t.
/*
===============================================================================================================================
Programa----------: REST013NameFile()
Autor-------------: Alex Wallauer
Data da Criacao---: 24/06/2014
Descrição---------: Gera o nome do arquivo com date() e time()
Parametros--------: Ccarga - numero da carga que será usado como parte do nome do arquivo
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function REST013NameFile()
Local	cFileName	:=	Nil
Local	cAux		:=	Nil

cFileName:="REST013_"
cFileName+=DTOS( Date() ) + "_"

cAux:=Time()
cAux:=StrTran( cAux , ":" , "" )

cFileName:=cFileName+cAux+".pdf"

Return cFileName

/*
==============================================================================================================================================================
Programa----------: REST013Select
Autor-------------: Alex Wallauer
Data da Criacao---: 14/02/2019
Descrição---------: Selects dos relatorios 
Parametros--------: Nenhum
Retorno-----------: Nenhum
==============================================================================================================================================================
*/
Static Function REST013Select()
LOCAL _cFiltro := "" 

IF _cTipo = "REST011"
	
	If !Empty(dtos(MV_PAR02))
	   _cFiltro += " D3_EMISSAO >= '" + DTOS(MV_PAR01) + "' AND "
	   _cFiltro += " D3_EMISSAO <= '" + DTOS(MV_PAR02) + "' AND "
       _cDatas  := " De "+DTOC(MV_PAR01)+" ate "+DTOC(MV_PAR02)
	Endif

	If !Empty(MV_PAR07) .OR. !Empty(_c7CCSintet) .OR. !Empty(_c6CCSintet) .OR. !Empty(_c5CCSintet)
	   _cFiltro += " ( "
   ENDIF

	If !Empty(MV_PAR07) 
		_cFiltro += " D3_FILIAL||D3_CC  IN "+FormatIn(MV_PAR07,";")
   ENDIF

   If !Empty(_c7CCSintet)
	   If !Empty(MV_PAR07) 
         _cFiltro += " OR "
      ENDIF   

		_cFiltro += " SUBSTR(D3_FILIAL||D3_CC,1,7) IN "+FormatIn(_c7CCSintet,";")
	   
	Endif

   If !Empty(_c6CCSintet)
	   If !Empty(MV_PAR07) .OR. !Empty(_c7CCSintet)
         _cFiltro += " OR "
      ENDIF   

		_cFiltro += " SUBSTR(D3_FILIAL||D3_CC,1,6) IN "+FormatIn(_c6CCSintet,";")
	   
	Endif

   If !Empty(_c5CCSintet)
	   If !Empty(MV_PAR07) .OR. !Empty(_c7CCSintet) .OR. !Empty(_c6CCSintet)
         _cFiltro += " OR "
      ENDIF   

		_cFiltro += " SUBSTR(D3_FILIAL||D3_CC,1,5) IN "+FormatIn(_c5CCSintet,";")
	   
	Endif

	If !Empty(MV_PAR07) .OR. !Empty(_c7CCSintet) .OR. !Empty(_c6CCSintet) .OR. !Empty(_c5CCSintet)
	   _cFiltro += " ) AND "
   ENDIF

	IF !_lSchedule .AND. !EMPTY(_cFilsGerent)
		_cFiltro += " D3_FILIAL IN "+FormatIn(_cFilsGerent,";")+" AND "
	Endif

	_cQuery:=" SELECT  D3_FILIAL,D3_NUMSA,CP_PRODUTO,CP_DESCRI,CP_SOLICIT,D3_QUANT,D3_CUSTO1,D3_EMISSAO,D3_I_OBS,D3_CC,D3_I_ORIGE "
	_cQuery+="  FROM "+RetSQLName('SD3')+" SD3 "
	_cQuery+="  JOIN "+RetSQLName('SCP')+" SCP ON D3_FILIAL = CP_FILIAL AND D3_NUMSA = CP_NUM AND D3_ITEMSA = CP_ITEM "
	_cQuery+="   WHERE "+_cFiltro
	_cQuery+="    SD3.D3_ESTORNO <> 'S' AND "
	_cQuery+="    SCP.D_E_L_E_T_ = ' '  AND "
	_cQuery+="    SD3.D_E_L_E_T_ = ' '  "
//	_cQuery+="   ORDER BY D3_CC, D3_EMISSAO"
	_cQuery+=" UNION ALL "

	_cQuery+=" SELECT  D3_FILIAL,D3_NUMSA,D3_COD,    B1_DESC,  D3_USUARIO,D3_QUANT,D3_CUSTO1,D3_EMISSAO,D3_I_OBS,D3_CC,D3_I_ORIGE "
	_cQuery+="  FROM "+RetSQLName('SD3')+" SD3 "
	_cQuery+="  JOIN "+RetSQLName('SB1')+" SB1 ON D3_COD = B1_COD "
	_cQuery+="   WHERE "+_cFiltro
	_cQuery+="    SD3.D3_ESTORNO <> 'S' AND "
	_cQuery+="    SD3.D3_NUMSA    = ' ' AND "
	_cQuery+="    SB1.D_E_L_E_T_  = ' ' AND "
	_cQuery+="    SD3.D_E_L_E_T_  = ' '     "
	_cQuery+="   ORDER BY D3_CC, D3_EMISSAO"

    DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )
	
ELSEIF _cTipo = "RCOM009"
	
	If !EMPTY(MV_PAR04)
	   _cFiltro  += " SD1.D1_GRUPO >= '" + MV_PAR03 + "' AND "
	   _cFiltro  += " SD1.D1_GRUPO <= '" + MV_PAR04 + "' AND "
	ENDIF

	If !EMPTY(DTOS(MV_PAR08))
	   _cFiltro += " SD1.D1_DTDIGIT >= '" + DTOS(MV_PAR07) + "' AND "
	   _cFiltro += " SD1.D1_DTDIGIT <= '" + DTOS(MV_PAR08) + "' AND "
       _cDatas  := " De "+DTOC(MV_PAR07)+" ate "+DTOC(MV_PAR08)
	Endif

	//busca CFOPS
	MV_PAR17 := ALLTRIM(MV_PAR17)
	If !EMPTY(MV_PAR17)
		_cFiltro  += "  SD1.D1_CF IN " + FormatIn(MV_PAR17,";")+" AND "//1933;2933
	Endif

   If !Empty(MV_PAR18) .OR. !Empty(_c7CCSintet) .OR. !Empty(_c6CCSintet).OR. !Empty(_c5CCSintet)
	   _cFiltro += " ( "
   ENDIF

	If !Empty(MV_PAR18) 

		_cFiltro += " D1_FILIAL||D1_CC  IN "+FormatIn(MV_PAR18,";")
   
   ENDIF

   If !Empty(_c7CCSintet)

	   If !Empty(MV_PAR18) 
         _cFiltro += " OR "
      ENDIF   

		_cFiltro += " SUBSTR(D1_FILIAL||D1_CC,1,7) IN "+FormatIn(_c7CCSintet,";")
	   
	Endif

   If !Empty(_c6CCSintet)

	   If !Empty(MV_PAR18) .OR. !Empty(_c7CCSintet)
         _cFiltro += " OR "
      ENDIF   

		_cFiltro += " SUBSTR(D1_FILIAL||D1_CC,1,6) IN "+FormatIn(_c6CCSintet,";")
	   
	Endif

   If !Empty(_c5CCSintet)

	   If !Empty(MV_PAR18) .OR. !Empty(_c7CCSintet) .OR. !Empty(_c6CCSintet)
         _cFiltro += " OR "
      ENDIF   

		_cFiltro += " SUBSTR(D1_FILIAL||D1_CC,1,5) IN "+FormatIn(_c5CCSintet,";")
	   
	Endif

   If !Empty(MV_PAR18) .OR. !Empty(_c7CCSintet) .OR. !Empty(_c6CCSintet).OR. !Empty(_c5CCSintet)
	   _cFiltro += " ) AND "
   ENDIF

	IF !_lSchedule .AND. !EMPTY(_cFilsGerent)
		_cFiltro  += " D1_FILIAL IN "+FormatIn(_cFilsGerent,";")+" AND "
	Endif
	
	_cQuery:=" SELECT D1_FILIAL, D1_DOC, D1_FORNECE, D1_DTDIGIT, D1_QUANT, D1_VUNIT, D1_TOTAL, B1_DESC, A2_NOME RAZAO , D1_CC "
	_cQuery+=" FROM "+RetSQLName('SD1')+" SD1, "
	_cQuery+="      "+RetSQLName('SB1')+" SB1, "
	_cQuery+="      "+RetSQLName('SA2')+" SA2  "
	_cQuery+=" WHERE"+_cFiltro
	_cQuery+="      SB1.B1_COD      =  SD1.D1_COD     AND "
	_cQuery+="      SA2.A2_COD      =  SD1.D1_FORNECE AND "
	_cQuery+="      SA2.A2_LOJA     =  SD1.D1_LOJA    AND "
	_cQuery+="      SD1.D1_TES     <>  ' '            AND "  
	_cQuery+="      SA2.D_E_L_E_T_ = ' ' AND "
	_cQuery+="      SD1.D_E_L_E_T_ = ' ' AND "
	_cQuery+="      SB1.D_E_L_E_T_ = ' ' "
	_cQuery+="   ORDER BY D1_CC, D1_DTDIGIT, D1_DOC "
		
    DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )	
ENDIF

RETURN .T.

/*
==============================================================================================================================================================
Programa----------: REST013Email
Autor-------------: Alex Wallauer
Data da Criacao---: 14/02/2019
Descrição---------: Envia os e-mails
Parametros--------: bExecuta
Retorno-----------: Nenhum
==============================================================================================================================================================
*/
Static Function REST013Email(bExecuta)
LOCAL _cEmlLog := "" , C
Local _aConfig := U_ITCFGEML('')
Local _cMsgEml := ""
Local _cEnvPor := ""  
Local _ntamanho:= _ni:=0
Local _lAutSalv:= _lSchedule
Local cEmailCo := ""
//Local _cOrigem :=""
PRIVATE _cArqExcel:=STRTRAN(UPPER(_cFileName),".PDF",".XLSX")
PRIVATE _cArqAnali:=STRTRAN(UPPER(_cFileName),".PDF","")+"Ana.XLSX"

Do while _ni <= 5 .and. _ntamanho == 0//Verifica se gerou pdf com tamanho maior que zero, em caso de erro repete o relatório até 5 vezes
	_ntamanho := 0
	_adatfile := {}
	If FILE(_cFileName)
		_adatfile := directory(_cFileName)
		_ntamanho := _adatfile[1][2]
	Endif
    FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "REST013"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "REST01303"/*cMsgId*/, "REST01303 - Envio de E-mail do Arquivo: "+IF(FILE(_cFileName),"","NAO")+ " achou " + _cFilename + " com tamanho  " + TRANSF(_ntamanho,"@E 999,999")/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	If _ntamanho = 0
      FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "REST013"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "REST01304"/*cMsgId*/, "REST01304 - Tentativa "+STR(_ni+1,1)+" de Gerar "+_cAssunto/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
		ferase(_cFileName)
 	   _lSchedule:=.T.
      _aGerExcel:={}//ZERA PARA NÃO DUPLICAR CADA VEZ QUE PASSAR
		EVAL(bExecuta)
 	   _lSchedule:=_lAutSalv		
	Endif
	_ni++
Enddo

IF _lSchedule
   IF _lMensal
      _cEnvPor := "Mensal Automatico"
   ELSE
      _cEnvPor := "Semanal Automatico"
   ENDIF   
ELSE
   _cEnvPor := UsrFullName(__cUserID)
ENDIF
_cMsgEml := '<html>'
_cMsgEml += '<head><title>Montagem de Carga</title></head>'
_cMsgEml += '<body>'
_cMsgEml += '<style type="text/css"><!--'
_cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
_cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
_cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
_cMsgEml += '--></style>'
_cMsgEml += '<center>'
_cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="600" height="50"><br>'
_cMsgEml += '<table class="bordasimples" width="600">'
_cMsgEml += '    <tr>'
_cMsgEml += '	     <td class="titulos"><center>'+_cAssunto+'</center></td>'
_cMsgEml += '	 </tr>'
_cMsgEml += '</table>'
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="600">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="2" class="grupos">Esse relatorio contem as informações dos centros de custo abaixo</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" width="30%"><b>Periodo:</b></td>'//align="center"
_cMsgEml += '      <td class="itens" >'+ _cDatas +'</td>'
_cMsgEml += '    </tr>'

_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" width="30%"><b>Enviado de: </b></td>'//align="center"
_cMsgEml += '      <td class="itens" >'+ _cEnvPor +'</td>' 
_cMsgEml += '    </tr>'

_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" width="30%"><b>Enviado para: </b></td>'//align="center"
_cMsgEml += '      <td class="itens" >'+ _cEnvPara +'</td>' 
_cMsgEml += '    </tr>'

_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="center" width="30%"><b>Filial / C. Custo</b></td>'
_cMsgEml += '      <td class="grupos" align="center" ><b>Descrição</b></td>' 
_cMsgEml += '    </tr>'

_aCC:=StrToKarr(_cCentro,";")
FOR C := 1 TO LEN(_aCC)
	IF !EMPTY(_aCC[C])
		_cMsgEml += '    <tr>'
		_cMsgEml += '      <td class="itens" align="center" width="30%">'+ SUBSTR(_aCC[C],1,2)+" / "+SUBSTR(_aCC[C],3) +'</td>'
		_cMsgEml += '      <td class="itens" >'+ Posicione("CTT",1,xFilial("CTT")+SUBSTR(_aCC[C],3),"CTT_DESC01") +'</td>'
		_cMsgEml += '    </tr>'
	ENDIF
NEXT

_cMsgEml += '	<tr>'
_cMsgEml += '		<td class="grupos" align="center" colspan="2"><b>Para maiores informações acesse o arquivo anexo.</b></td>'
_cMsgEml += '	</tr>'
_cMsgEml += '	<tr>'
_cMsgEml += '      <td class="titulos" align="center" colspan="2"><font color="red"><u>Esta é uma mensagem automática. Por favor não a responda!</u></font></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '</table>'
_cMsgEml += '</body>'
_cMsgEml += '</html>'
_cMsgEml += '<br>'
_cMsgEml += '<br>'
IF _lSchedule 
   _cMsgEml += '<BR><b>Ambiente:</b> ['+ _cAmbiente +'] / <b>Fonte:</b> [REST013] Via Schedule</BR>'
Else
   _cMsgEml += '<BR><b>Ambiente:</b> ['+ _cAmbiente +'] / <b>Fonte:</b> [REST013] Via Tela</BR>'
ENDIF
_cAssunto+=" - "+_cDatas
IF _lMensal
   _cAssunto+= " - MENSAL"
   _aGerExcel:=ASORT(_aGerExcel,,,{|x,y| x[4] > y[4] })
ELSE
   _cAssunto+= " - SEMANAL"
ENDIF   

//TESTA DENTRO DA FUNÇÃO REST13GEREXCEL() SE A ARRAY _aGerExcel ESTA ZERADA
_cEmailAux:=_cEmail
IF !_lSchedule
   _cEmail :=ALLTRIM(LOWER(UsrRetMail(RetCodUsr())))//PRECISA PASSAR AQUI MESMO COM A ARRAY _aGerExcel ZERADA
   LjMsgRun( "Gerando Excel: "+_cArqExcel , _cTitJanela , {|| _cArqExcel:= REST13GerExcel(_cPathSrv,_cArqExcel,_aCabExcel,_aGerExcel) } )
   IF _lMensal
      LjMsgRun( "Gerando Excel: "+_cArqAnali , _cTitJanela , {|| _cArqAnali:= REST13GerExcel(_cPathSrv,_cArqAnali,_aCabExcel,_aAnaliTotal) } )
   ENDIF   
ELSE
   _cArqExcel:= REST13GerExcel(_cPathSrv,_cArqExcel,_aCabExcel,_aGerExcel)
   IF _lMensal
      _cArqAnali:= REST13GerExcel(_cPathSrv,_cArqAnali,_aCabExcel,_aAnaliTotal) 
   ENDIF
ENDIF   
IF _lMensal
   IF FILE(_cArqAnali)
      _cFileName:=_cFileName+";"+_cArqAnali
   ENDIF
ENDIF
//SE DENTRO DA FUNÇÃO REST13GEREXCEL() A ARRAY _aGerExcel CHEGAR ZERADA DEVOLVE A VARIAVEL _cArqExcel = ""
IF FILE(_cArqExcel)
   _cFileName:=_cFileName+";"+_cArqExcel
ENDIF

IF _lSchedule
   //U_ITENVMAIL(cFrom        ,cEmailTo ,cEmailCo  ,cEmailBcc,cAssunto ,_cMsgEml ,cAttach   ,cAccount    ,cPassword   ,cServer      ,cPortCon    ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro)
   U_ITENVMAIL( _aConfig[01] , _cEmail , cEmailCo  ,         ,_cAssunto, _cMsgEml,_cFileName,_aConfig[01],_aConfig[02], _aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )
ELSE
   LjMsgRun( "Enviando E-mail: "+_cEmail , _cTitJanela, {|| U_ITENVMAIL( _aConfig[01] , _cEmail , cEmailCo  ,         ,_cAssunto, _cMsgEml,_cFileName,_aConfig[01],_aConfig[02], _aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog ) } )
ENDIF

IF !Empty( _cEmlLog )

   cMensagem+=_cAssunto+" - "+_cEmlLog+ " - E-mail para: " + _cEmail+" - "+cEmailCo+" - Com anexo " + alltrim(_cfileName) + " - PDF com tamanho de " + TRANSF(_ntamanho,"@E 9,999,999")+CHR(13)+CHR(10)
   AADD(_aResultado,{_cFilial,"E-MAIL",TRANSF(LEN(_aGerExcel),"@E 999,999"),_cEmail,_cCentro,_cAssunto+": "+_cEmlLog+ " Com anexo " + alltrim(_cfileName) + ", PDF com tamanho de "+ALLTRIM(TRANSF(_ntamanho,"@E 9,999,999"))})
   
EndIF

IF _cFileName # nil .AND. FILE(_cFileName)
   FErase(_cFileName)
ENDIF
IF _cArqExcel # nil .AND. FILE(_cArqExcel)
   FErase(_cArqExcel)
ENDIF

RETURN .T.

/*
===============================================================================================================================
Programa----------: REST13GerExcel()
Autor-------------: Alex Wallauer
Data da Criacao---: 13/06/2024
Descrição---------: Gera Excel e envia por e-mail
Parametros--------: _cPathSrv,_cArquivo,_aCabExcel,_aGerExcel
Retorno-----------: _cPathSrv+_cArquivo+".xlsx"
===============================================================================================================================
*/
Static Function REST13GerExcel(_cPathSrv,_cArquivo,_aCabExcel,_aGerExcel)
LOCAL _cNomePlan:="SEMANAL"

IF LEN(_aCabExcel) = 0 .OR. LEN(_aGerExcel) = 0//TESTA AQUI SE TÁ ZERADO 
   RETURN ""
ENDIF

IF "MENSAL" $ _cAssunto
   _cNomePlan:="MENSAL"
ENDIF
IF UPPER(_cPathSrv) $ UPPER(_cArquivo)//Se o arquivo _cArquivo já tiver o diretorio
   _cPathSrv:=""
   _cArquivo:=SUBSTR(_cArquivo,2)//TIRA A PRIMEIRA BARRA PQ NA FUNÇÃO U_ITGEREXCEL()) COLOCA DE NOVO _cDiretorio+"\"+_cNomeArq
ENDIF
//ITGEREXCEL(_cNomeArq,_cDiretorio,_cTitulo ,_cNomePlan,_aCabecalho,_aDetalhe,_lLeTabTemp,_cAliasTab,_aCampos,_lScheduller,_lCriaPastas,_aPergunte,_lEnviaEmail,_lXLSX)
U_ITGEREXCEL(_cArquivo,_cPathSrv  ,_cAssunto,_cNomePlan,_aCabExcel ,_aGerExcel,           ,          ,        , .T.        ,            ,          , .T.        ,.T.)
IF EMPTY(_cPathSrv)
   _cPathSrv:="/"//COLOCA A BARRA DE VOLTA PQ TIROU ANTES 
ENDIF
IF FILE(_cPathSrv+_cArquivo) 
   RETURN (_cPathSrv+_cArquivo)
ENDIF

RETURN ""
