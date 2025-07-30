/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                            
 ===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"

/*
===============================================================================================================================
Programa----------: MOMS056
Autor-------------: Alex Wallauer
Data da Criacao---: 05/08/2020
===============================================================================================================================
Descricao---------: Agenda dos Vendedores - CHAMADO 33805
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS056()

Local _aParRet :={}
Local _aParAux :={} , nI
Local _bOK     :={|| IF(MV_PAR02 >= MV_PAR01,.T.,(U_ITMSG("Periodo INVALIDO",'Atenção!',"Tente novamente com outro periodo",3),.F.) ) }


MV_PAR01:=dDataBase
MV_PAR02:=dDataBase
MV_PAR03:=dDataBase

AADD( _aParAux , { 1 , "Data de:"	, MV_PAR01, "@D"	, ""	, ""		, "" , 050 , .F. } )
AADD( _aParAux , { 1 , "Data ate:"	, MV_PAR02, "@D"	, ""	, ""		, "" , 050 , .F. } )

For nI := 1 To Len( _aParAux )
	aAdd( _aParRet , _aParAux[nI][03] )
Next nI

DO WHILE .T.

   _lLoop:=.F.
//            aParametros,cTitle                  ,aRet     ,bOk ,aButtons,lCentered,nPosX,nPosY,oDlgWizard,cLoad,lCanSave,lUserSave
    IF !ParamBox( _aParAux , "Intervalo de Datas" ,@_aParRet,_bOK,        ,         ,     ,     ,          ,     ,.T.     ,.T. )//Intervalo de Datas e Filial
	   EXIT
    EndIf

    FWMSGRUN(,{|oproc|  MOMS056Proc(oproc) },'Aguarde processamento...','Lendo dados...')
   
    IF _lLoop//Se A função MOMS056Proc() devolver .F. ou usuario abortar ou processsar normalmente dá o loop para aparecer a tela novamente senão sai fora 
       LOOP
    ENDIF

    EXIT//Botão cancela 

ENDDO

Return

/*
===============================================================================================================================
Programa----------: MOMS056Proc
Autor-------------: Alex Wallauer
Data da Criacao---: 05/08/2020
===============================================================================================================================
Descricao---------: le os dados para o Monitor do TAF
===============================================================================================================================
Parametros--------: oproc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function MOMS056Proc(oproc)
Local _cQry		:= ""
Local _ntot := 0
Local _npos := 1
Local _cAlias:= GetNextAlias()
DEFAULT oproc := NIL

oproc:cCaption := ("Lendo dados...")
ProcessMessages()

_cQry := "SELECT A1_COD, A1_LOJA, A1_NOME , A1_I_SEMAN, A1_I_FREQ "
_cQry += " FROM " + RetSqlName("SA1") 
_cQry += " WHERE  D_E_L_E_T_  = ' '  "//???? AND  A1_MSBLQL <> '1'
_cQry += "   AND  A1_I_SEMAN <> ' ' AND  A1_I_FREQ <> ' ' "
_cQry += " ORDER BY A1_COD,A1_LOJA "

DBUSEAREA( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , _cAlias , .T., .F. )

COUNT TO _ntot

_aClientes:={}

(_cAlias)->(dbGoTop())

DO WHILE !(_cAlias)->(EOF())
	
   oproc:cCaption := ("Lendo dados " + CVALTOCHAR(_npos) + " de " + CVALTOCHAR(_ntot))
   ProcessMessages()
   _npos++

   AADD(_aClientes,{.T.,(_cAlias)->A1_COD  ,;//2
                        (_cAlias)->A1_LOJA ,;//3
                        (_cAlias)->A1_NOME ,;//4
                     (_cAlias)->A1_I_SEMAN ,;//5
                      (_cAlias)->A1_I_FREQ })//6
   //6
   (_cAlias)->(DBSKIP())//6
   //6
ENDDO

IF LEN(_aClientes) = 0
   U_ITMSG("Não foram encontrados Clientes configurados ",'Atenção!',"Tente novamente com outro periodo",3)
   _lLoop:=.T.
   RETURN .T.
ENDIF

DO WHILE  .T.

   _lLoop:=.F.
   _lRet:=.F.

   _lRet  :=U_ITListBox( 'Lista de Clientes'                    ,;//           , _aCols     ,_lMaxSiz,_nTipo,_cMsgTop , _lSelUnc ,
                         {" ",'Codigo','Cliente','Dia da Semena','Frequencia'} , _aClientes , .T.    , 2    ,         ,          ,;
                         { 5 ,     30,  100     ,           100 },        )
                                                      // _aSizes , _nCampo , bOk , bCancel )
   IF !_lRet
      _lLoop:=.T.
      EXIT
   ENDIF

   FWMSGRUN(,{|oproc|  MOMS056Agenda(oproc,MV_PAR01,MV_PAR02) },'Aguarde processamento...','Lendo dados...')

   IF _lLoop
      LOOP
   ENDIF

   EXIT//Botão cancela 
   
ENDDO


RETURN .T.


/*
===============================================================================================================================
Programa----------: MOMS056Agenda
Autor-------------: Alex Wallauer
Data da Criacao---: 05/08/2020
===============================================================================================================================
Descricao---------: Gera a Agenda
===============================================================================================================================
Parametros--------: oproc,MV_PAR01,MV_PAR02
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function MOMS056Agenda(oproc,MV_PAR01,MV_PAR02)
Local C , _lInv:=.T.
Local oOkV:=LoadBitmap( GetResources() , "BR_VERDE"    )
Local oOkA:=LoadBitmap( GetResources() , "BR_AMARELO"  )
Local _aDias:={"DOMINGO","SEGUNDA","TERCA","QUARTA","QUINTA","SEXTA","SABADO"}
Local _cAlias2:= GetNextAlias()


oproc:cCaption := ("Lendo dados dos Clientes...")
ProcessMessages()

_dData:=MV_PAR01
_aAgenda:={}
_ntot:=DateDiffDay(_dData,MV_PAR02)
_nConta:=0
DO WHILE _dData <= MV_PAR02

   _nConta++
   oproc:cCaption := ("Lendo Data: "+DTOC(_dData)+"-"+ CVALTOCHAR(_nConta) + " de " + CVALTOCHAR(_ntot))
   ProcessMessages()
/*
   IF !(DAY(_dData) = 1 .AND. Month(_dData) = 1) .AND. !(DAY(_dData) = 31 .AND. Month(_dData) = 12) 
      _dData:=_dData+1
      LOOP
   ENDIF*/

   _nDiaSem     := DOW(_dData)      //1 A 7
   _d1oDiaMes   := FirstDate(_dData)//Primeiro dia do mes da data
   _nNumSemAno  := VAL(RetSem(_dData))    // 1 A 52 ou 53 //Numero da semana da _dData
   _lPar        := ((_nNumSemAno % 2) = 0 )  //Semana par ou impar
   _lBissexto   := (( Year(_dData) % 4) = 0 )//Ano Bissexto
   _nSemMes     := 0
   
   _cQry := "SELECT TO_CHAR(TO_DATE("+DTOS(_dData)+",'YYYYMMDD'),'W') NSEMMES FROM DUAL" //SEMANA DO MES

   DBUSEAREA( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , _cAlias2 , .T., .F. )

   IF !(_cAlias2)->(EOF())
      _nSemMes:=VAL((_cAlias2)->NSEMMES)//Retorna o numero da semana do mes
   ENDIF
   (_cAlias2)->(DBCLOSEAREA())

   _cDes:=""//_aDias[_nDiaSem]
   _cDes+="NSD: "+STRZERO(_nNumSemAno,2)
   _cDes+=" - NSM: "+CVALTOCHAR(_nSemMes)+IF(_nSemMes=1," [M1]",IF(_nSemMes=2," [M2]",IF(_nSemMes=3," [M3]",IF(_nSemMes=4," [M4]"," [M5]"))))
   _cDes+=" - "+IF(_nNumSemAno = 53,"PAR+IMPAR",IF(_lPar,"[QI] PAR","[QP] IMPAR"))
   _cDes+=IF(_lBissexto," - [ANO BISSEXTO]","")
   //linha de dados do dia
   AADD(_aAgenda, { IF(_lInv,oOkV,oOkA),;//1
                                 _dData,;//2
                       _aDias[_nDiaSem],;//3
                                    "" ,;//4
                                 _cDes ,;//5
                                   .F. })//6

   FOR C := 1 TO LEN(_aClientes) 
       IF !_aClientes[C,1]
          LOOP
       ENDIF
       
       lFreq:=.F.
       lADD :=.F.
       _nPos:=6//A1_I_FREQ
       IF _aClientes[C,_nPos] ="SE"
          lFreq:=.T.
       ELSEIF _nNumSemAno = 53 .AND. (_aClientes[C,_nPos] ="QI" .OR. _aClientes[C,_nPos] ="QP")
          lFreq:=.T.
       ELSEIF _aClientes[C,_nPos] ="QI" .AND. !_lPar
          lFreq:=.T.
       ELSEIF _aClientes[C,_nPos] ="QP" .AND. _lPar
          lFreq:=.T.
       ELSEIF _aClientes[C,_nPos] ="M1" .AND. _nSemMes = 1
          lFreq:=.T.
       ELSEIF _aClientes[C,_nPos] ="M2" .AND. _nSemMes = 2
          lFreq:=.T.
       ELSEIF _aClientes[C,_nPos] ="M3" .AND. _nSemMes = 3
          lFreq:=.T.
       ELSEIF _aClientes[C,_nPos] ="M4" .AND. _nSemMes = 4
          lFreq:=.T.
       ENDIF
       _nPos:=5//A1_I_SEMAN
       IF _nDiaSem = 1 .AND. _aClientes[C,_nPos] ="DOM"
          lADD:=lFreq
       ELSEIF _nDiaSem = 2 .AND. _aClientes[C,_nPos] ="SEG"
          lADD:=lFreq
       ELSEIF _nDiaSem = 3 .AND. _aClientes[C,_nPos] ="TER"
          lADD:=lFreq
       ELSEIF _nDiaSem = 4 .AND. _aClientes[C,_nPos] ="QUA"
          lADD:=lFreq
       ELSEIF _nDiaSem = 5 .AND. _aClientes[C,_nPos] ="QUI"
          lADD:=lFreq
       ELSEIF _nDiaSem = 6 .AND. _aClientes[C,_nPos] ="SEX"
          lADD:=lFreq
       ELSEIF _nDiaSem = 7 .AND. _aClientes[C,_nPos] ="SAB"
          lADD:=lFreq
       ENDIF

       IF lADD
          AADD(_aAgenda, { IF(_lInv,oOkV,oOkA)                                             ,;//1
                                        _dData                                             ,;//2
                               _aClientes[C,2]                                             ,;//3
                               _aClientes[C,3]                                             ,;//4
                               _aClientes[C,5]+" - "+_aClientes[C,6]+" - "+_aClientes[C,4] ,;//5
                                          .T.                                              })//6
       ENDIF
       
   NEXT
   
   _lInv:=!_lInv
   _dData:=_dData+1
   
ENDDO

IF LEN(_aAgenda) = 0
   U_ITMSG("Não foram encontrados dados para esse perido ",'Atenção!',"Tente novamente com outro periodo",3)
   _lLoop:=.T.
   RETURN .T.
ENDIF

_cMsgTop:='Agenda dos Vendedores'
DO WHILE  .T.

   _lRet:=U_ITListBox( _cMsgTop           ,;// , _aCols  ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,
               {" ",'DATA','CODIGO',"LOJA",'CLIENTE'} , _aAgenda, .T.    , 1    ,       ,          ,;
               {10 ,    30,   40   ,    20, 150     }, 1       ,     ,        , )
                                // _aSizes , _nCampo , bOk , bCancel, _abuttons )

   IF _lRet .AND. U_ITMSG("Confirma GRAVAR ?",'Atenção!',,3,2,2)

      FWMSGRUN(,{|oproc| MOMS056Grava(oproc) },'Aguarde processamento...','Grava dados...')

      _lLoop:=.T.
   ELSE
      _lLoop:=.F.
   ENDIF

   EXIT

ENDDO

Private cCadastro	:= "AGENDA DOS VENDEDORES"
Private aRotina	:= {}                

AADD(aRotina,{"Pesquisar"	,"AxPesqui",0,1})
AADD(aRotina,{"Visualizar"	,"AxVisual",0,2})
AADD(aRotina,{"Incluir"		,"AxInclui",0,3})
AADD(aRotina,{"Alterar"		,"AxAltera",0,4})
AADD(aRotina,{"Excluir"		,"AxDeleta",0,5})
	
dbSelectArea("ZAG")
dbSetOrder(1)
mBrowse(,,,,"ZAG")

RETURN .T.

/*
===============================================================================================================================
Programa----------: MOMS056Agenda
Autor-------------: Alex Wallauer
Data da Criacao---: 05/08/2020
===============================================================================================================================
Descricao---------: Gera a Agenda
===============================================================================================================================
Parametros--------: oproc,MV_PAR01,MV_PAR02
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function MOMS056Grava(oproc)
LOCAL Z
LOCAL _ntot:=LEN(_aAgenda)

dbSelectArea("ZAG")
dbSetOrder(1)

FOR Z := 1 TO LEN(_aAgenda)
  
   oproc:cCaption := ("Lendo Data: "+DTOC(_dData)+"-"+ CVALTOCHAR(Z) + " de " + CVALTOCHAR(_ntot))
   ProcessMessages()

    IF !_aAgenda[Z,6]
       LOOP
    ENDIF
    IF ZAG->(DBSEEK(xFilial("ZAG")+DTOS(_aAgenda[Z,2])+_aAgenda[Z,3]+_aAgenda[Z,4]))
       ZAG->(RECLOCK("ZAG",.F.))
    ELSE
       ZAG->(RECLOCK("ZAG",.T.))
    ENDIF
    ZAG->ZAG_FILIAL:=xFilial("ZAG")
    ZAG->ZAG_DATA  :=_aAgenda[Z,2]
    ZAG->ZAG_CLIENT:=_aAgenda[Z,3]
    ZAG->ZAG_LOJA  :=_aAgenda[Z,4]
    ZAG->(MSUNLOCK())
    
NEXT

RETURN .T.
