/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |07/05/2025| Chamado 50617. Corrigir chamada estática no nome das tabelas do sistema
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: RCOM021
Autor-------------: Alex Wallauer
Data da Criacao---: 26/12/2022
Descricao---------: Relação de Questionamentos - CHAMADO 42202 
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RCOM021()
Local _aParRet :={}
Local _aParAux :={}  , nI
Local _bOK     :={|| IF( MV_PAR01 < MV_PAR02  ,.T.,(U_ITMSG("Datas invalidas!",'Atencao',"Digite a data inicial menor ou igual a data fianl", 3),.F.) ) }

MV_PAR01:=CTOD("")
MV_PAR02:=CTOD("")
MV_PAR03:="1"
_aTipos:={"1-PC","2-SC"}
AADD( _aParAux , { 1 , "Data Inicial"  , MV_PAR01, "@D"  , ""  ,"", "" , 060 , .T. } ) 
AADD( _aParAux , { 1 , "Data Final"    , MV_PAR02, "@D"  , ""  ,"", "" , 060 , .T. } ) 
AADD( _aParAux , { 2 , "Tipos"         , MV_PAR03,_aTipos, 060   ,".T.",.T. ,".T."}) 


For nI := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nI][03] )
Next nI
          //aParametros, cTitle                       , @aRet    ,[bOk], [ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ] 
IF !ParamBox( _aParAux , "Relação de Questionamentos" , @_aParRet, _bOK, /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
    RETURN .F.
EndIf

U_ITLOGACS( "RCOM021" )

SET DATE FORMAT TO "DD/MM/YYYY"

cTimeInicial:=TIME()

FWMSGRUN( ,{|oProc|   RCOM021R(oProc) } , "Hora Inicial: "+cTimeInicial+", Aguarde...",  )

SET DATE FORMAT TO "DD/MM/YY"

Return


/*
===============================================================================================================================
Programa----------: RCOM021R
Autor-------------: Alex Wallauer
Data da Criacao---: 26/12/2022
Descriçâo---------: Selecao de dados
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function  RCOM021R(oProc)
Local cQry1		:= ""
LOCAL _cAlias  := GetNextAlias()

oProc:cCaption :=  "Selelecionado Dados, Aguarde... "
ProcessMessages()

_lTodos := (Posicione("ZZL",4,XFilial("ZZL")+UsrRetName(__CUSERID),"ZZL_GCOM") = "S") .AND. ZZL->ZZL_CC <> ' '

cQry1 += " SELECT R_E_C_N_O_ RECZY2 "
cQry1 += " FROM  " + RetSqlName("ZY2") + " A "
cQry1 += " WHERE A.ZY2_FILPED = '"+cFilAnt+"' "
IF !EMPTY(MV_PAR01)
   cQry1 += " AND A.ZY2_DATAM >= "+DTOS(MV_PAR01)
ENDIF
IF !EMPTY(MV_PAR02)
   cQry1 += " AND A.ZY2_DATAM <= "+DTOS(MV_PAR02)
ENDIF
IF MV_PAR03 = "1"//PC
   cQry1 += " AND A.ZY2_ORIGEM  <> 'SC' "
ELSEIF MV_PAR03 = "2"//SC
   cQry1 += " AND A.ZY2_ORIGEM  = 'SC' "
ENDIF
cQry1 += " AND A.D_E_L_E_T_ = ' ' "

IF !_lTodos
   cQry1 += " AND ZY2_PEDIDO IN (SELECT DISTINCT B.ZY2_PEDIDO FROM " + RetSqlName("ZY2") + " B   "
   cQry1 += "                         WHERE B.ZY2_FILPED  =  A.ZY2_FILPED "
   cQry1 += "                           AND B.ZY2_PEDIDO  =  A.ZY2_PEDIDO "
   cQry1 += "                           AND B.ZY2_USER  = '"+__cUserId+"' "
   cQry1 += "                           AND B.D_E_L_E_T_ = ' ' ) "
ENDIF


cQry1 += " ORDER BY ZY2_FILPED, ZY2_PEDIDO, ZY2_DATAM, ZY2_HORAM
cQry1 := ChangeQuery(cQry1)

MPSysOpenQuery( cQry1, _cAlias )

nTotal:=nConta:=0
dbSelectArea(_cAlias)
COUNT TO nTotal
(_cAlias)->(dbGoTop())
_aDados:={}
nTotal:=ALLTRIM(STR(nTotal))
nTam:=LEN(nTotal)

DO While !(_cAlias)->(Eof())

   nConta++
   oProc:cCaption :=  "Lendo "+STRZERO(nConta,nTam)+" de "+nTotal
   ProcessMessages()
   ZY2->(DBGOTO( (_cAlias)->RECZY2 ))

   _aItens:={}
   AADD(_aItens,ZY2->ZY2_FILPED) 
   AADD(_aItens,ZY2->ZY2_PEDIDO) 
   AADD(_aItens,UsrFullName(ZY2->ZY2_USER) ) //RCOM021FullNome( ZY2->ZY2_USER,oProc) ) 
   AADD(_aItens,ZY2->ZY2_TIPO  ) 
   AADD(_aItens,ZY2->ZY2_MENSAG) 
   AADD(_aItens,DTOC(  ZY2->ZY2_DATAM )) 
   AADD(_aItens,ZY2->ZY2_HORAM ) 
   AADD(_aDados,_aItens)
	
   (_cAlias)->(dbSkip())

ENDDO

IF LEN(_aDados) = 0 
    U_ITMSG("Nao ha dados para essa selecao",'Atenção!',,3)
ENDIF

DO WHILE LEN(_aDados) > 0 
   _aTit:={}
   _aSiz:={}

   AADD(_aTit,'Filial') 
   AADD(_aSiz,15)
   AADD(_aTit,'Pedido')
   AADD(_aSiz,15)
   AADD(_aTit,'Usuario')
   AADD(_aSiz,50)
   AADD(_aTit,'Tipo')
   AADD(_aSiz,15)
   AADD(_aTit,'Mensagem')
   AADD(_aSiz,150)
   AADD(_aTit,'Data')
   AADD(_aSiz,15)
   AADD(_aTit,'Hora')
   AADD(_aSiz,15)

   _cTitulo:="Relação de Questionamentos"

   _cMsgTop:="Questionamentos encontradas - H.I.: "+cTimeInicial+" H.F.: "+TIME()+" Par. 1 : "+AllToChar(MV_PAR01)+"; Par. 2 : "+AllToChar(MV_PAR02)+"; Par. 3 : "+AllToChar(MV_PAR03)
   
   bOk:=NIL//{|| IF(U_ITMSG("Confirma Gerar EXCEL ?",'Atencao!',,2,2,2) , DlgToExcel( { { "ARRAY" , _cTitulo , _aTit , _aDados } } )  ,.F. )   }

   //                        , _aCols  ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons )
   U_ITListBox(_cTitulo,_aTit,_aDados  , .T.    , 3    ,_cMsgTop,          ,_aSiz   ,         , bOk ,        , )
                                                                                                  

   IF  !U_ITMSG("Confirma Sair ?",'Atenção!',"Os dados serão perdidos",3,2,2)
       LOOP
   ENDIF

    EXIT

ENDDO

Return

/*
===============================================================================================================================
Programa----------: RCOM021FullNome()
Autor-------------: Alex Wallauer
Data da Criacao---: 26/12/2022
Descrição---------: RETORNA o nome complerto do usuario
Parametros--------: _cCodUser
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function RCOM021FullNome(_cCodUser,oProc)

Local nPos:=0
STATIC _aAllusers := {}
DEFAULT lPrimeiroNome := .F.
IF LEN(_aAllusers) = 0
   oProc:cCaption :=  "Lendo Usuarios..."
   ProcessMessages()
   _aAllusers := FWSFALLUSERS()
ENDIF   

IF (nPos:=ASCAN(_aAllusers, { |A| ALLTRIM(A[2]) == ALLTRIM(_cCodUser) })) <> 0
   RETURN _aAllusers[nPos][4]
ENDIF

Return ""
