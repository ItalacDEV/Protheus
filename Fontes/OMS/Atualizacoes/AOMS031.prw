/*  
========================================================================================================================================================
                          ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
========================================================================================================================================================
    Autor    |    Data    |                                             Motivo                                           
--------------------------------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 14/09/2023 | Chamado 44503. Tratamento do Subsegmento.
========================================================================================================================================================
*/
//===========================================================================
//| Definições de Includes                                                  |
//===========================================================================
#include "protheus.ch"

/*
===============================================================================================================================
Programa----------: AOMS031
Autor-------------: Fabiano Dias 
Data da Criacao---: 08/02/2010 
===============================================================================================================================
Descrição---------: Cadastro de segmentos de clientes
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS031()

DBSELECTAREA("ZZ6")
ZZ6->(DBSETORDER(1))

Private cCadastro	:= "Cadastro de segmentos de Clientes"
Private aRotina	:= MenuDef()
mBrowse(,,,,"ZZ6" ,,,,,, U_AOMS031L(-1) ) 

Return


/*
===============================================================================================================================
Programa----------: AOMS031
Autor-------------: Alex Wallauer
Data da Criacao---: 14/09/2023 
===============================================================================================================================
Descrição---------: Cadastro de Subsegmentos de segmentos de clientes
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS31S()
Local cAuxCadastro:= cCadastro
Local aAuxRotina  := ACLONE( aRotina )

//Local aBotoes:={}
//AADD(aBotoes,{"segmentos","U_AOMS031B" ,0,2})

DBSELECTAREA("ZS6")
ZS6->(DBSETORDER(1))

//AxCadastro("ZS6","Cadastro de Grupo de Clientes","U_DelOk()",'U_AOMS31Val("OK")', aRotAdic, bPre, bOK, bTTS, bNoTTS,aAuto,nOpcAuto,aButtons,aACS,cTela,lMenudef)
//AxCadastro(  "ZS6","Cadastro de Grupo de Clientes",           ,'U_AOMS31Val("OK")', aBotoes ,     ,    ,     ,       ,     ,        , )

Private cCadastro	:= "Cadastro de SUBsegmentos de Segmentos"
Private aRotina:={{ "Pesquisar"              , "AxPesqui" 	 	, 0 , 1 } ,;
                  { "Visualizar"             , "AxVisual"      , 0 , 2 } ,;
                  { "Incluir"                , "U_AOMS31Inclui", 0 , 3 } ,;
                  { "Alterar"                , "AxAltera"      , 0 , 4 } ,;
                  { "Excluir"                , "AxDeleta"      , 0 , 5 } ,;
                  { "Lista de Subsegmentos"  , "U_AOMS031B"    , 0 , 2 } ,;
                  { "Legenda"	               , "U_AOMS031L(0)" , 0 , 0 }  }

mBrowse(,,,,"ZS6" ,,,,,, U_AOMS031L(-2) ) 

cCadastro:= cAuxCadastro
aRotina  := aAuxRotina
DBSELECTAREA("ZZ6")

Return
/*
===============================================================================================================================
Programa----------: AOMS31Inclui
Autor-------------: Alex Wallauer
Data da Criacao---: 14/09/2023
===============================================================================================================================
Descricao---------: Manutenção do ZS6
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================*/
User Function AOMS31Inclui(cAlias,nReg,nOpc)

IF nOpc = 3
   Return AxInclui(cAlias,nReg,nOpc,;
       /*aAcho>     */ ,;
       /*cFunc>     */ ,;
       /*aCpos>     */ ,;
       /*cTudoOk>   */ 'U_AOMS31Val("OK")',;
       /*lF3>       */ ,;
       /*cTransact> */ ,;//Antes 
       /*aButtons>  */ ,;
       /*aParam>    */ ,;
       /*aAuto>     */ ,;
       /*lVirtual>  */ ,;
       /*lMaximized>*/ )
ENDIF

Return .t.

/*
===============================================================================================================================
Programa----------: AOMS31Val
Autor-------------: Alex Wallauer
Data da Criacao---: 14/09/2023
===============================================================================================================================
Descrição---------: Validacao dos campos do cadastro de Subsegmentos
===============================================================================================================================
Parametros--------: _cCampo := Nome do campo ou botao
===============================================================================================================================
Retorno-----------: .T. ou .F.
===============================================================================================================================
*/  
User Function AOMS31Val(_cCampo)
Local _lRet := .T.  
DEFAULT _cCampo:=SUBSTR(READVAR(),4)
DbSelectArea("ZS6")

IF _cCampo == "ZS6_CODSEG"
   IF !EMPTY(M->ZS6_CODSEG) 
      _lRet:=ExistCpo("ZZ6",M->ZS6_CODSEG)
      IF _lRet
         M->ZS6_DESEUG:=Posicione("ZZ6",1,xFilial("ZZ6") + M->ZS6_CODSEG, "ZZ6_DESCRO")
         M->ZS6_CODSUB:=M->ZS6_CODSEG+"001"
         nConta:=1
         DO WHILE ZS6->(DBSEEK(xfilial()+M->ZS6_CODSEG+M->ZS6_CODSUB))
            nConta++
            M->ZS6_CODSUB:=M->ZS6_CODSEG+STRZERO(nConta,3)
         ENDDO
      ENDIF
   ELSE
      M->ZS6_DESEUG:=SPACE(LEN(ZS6->ZS6_DESEUG))
   ENDIF

ElseIf _cCampo == "OK"
   If !Obrigatorio(aGets,aTela)
      RETURN .F.
   ENDIF
   IF Inclui            
      _lRet :=ExistChav("ZS6",M->ZS6_CODSEG+M->ZS6_CODSUB)
   ENDIF

ElseIf _cCampo == "ZX_SUB_COD"//CHAMADO DO X3_VALID DO ZX_SUB_COD

   IF !EMPTY(M->ZX_SUB_COD) 
      _lRet:=ExistCpo("ZS6",M->ZX_GRCLI+M->ZX_SUB_COD)
      IF _lRet
         M->ZX_SUB_DES:=POSICIONE("ZS6",1,XFILIAL()+M->ZX_GRCLI+M->ZX_SUB_COD,"ZS6_DESCRI")
      ENDIF
   ELSE
      M->ZX_SUB_DES:=SPACE(LEN(ZS6->ZS6_DESCRI))
   ENDIF

ElseIf _cCampo == "A1_I_SUBCO"//CHAMADO DO X3_VALID DO A1_I_SUBCO

   IF !EMPTY(M->A1_I_SUBCO) 
      _lRet:=ExistCpo("ZS6",M->A1_I_GRCLI+M->A1_I_SUBCO)
      IF _lRet
         M->A1_I_SUBDE:=POSICIONE("ZS6",1,XFILIAL()+M->A1_I_GRCLI+M->A1_I_SUBCO,"ZS6_DESCRI")
      ENDIF
   ELSE
      M->A1_I_SUBDE:=SPACE(LEN(ZS6->ZS6_DESCRI))
   ENDIF

EndIf
   
Return _lRet
/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Alex Wallauer
Data da Criacao---: 23/02/2023
===============================================================================================================================
Descrição---------: Utilizacao de Menu Funcional
===============================================================================================================================
Parametros--------: aRotina
					1. Nome a aparecer no cabecalho
					2. Nome da Rotina associada
					3. Reservado
					4. Tipo de Transa‡„o a ser efetuada:
						1 - Pesquisa e Posiciona em um Banco de Dados
						2 - Simplesmente Mostra os Campos
						3 - Inclui registros no Bancos de Dados
						4 - Altera o registro corrente
						5 - Remove o registro corrente do Banco de Dados
					5. Nivel de acesso
					6. Habilita Menu Funcional
===============================================================================================================================
Retorno-----------: Array com opcoes da rotina
===============================================================================================================================
*/
Static Function MenuDef()
Local aRotina:={{ "Pesquisar"          , "AxPesqui"      , 0 , 1 } ,;
                { "Visualizar"         , "AxVisual"      , 0 , 2 } ,;
                { "Inclui Subsegmentos", "U_AOMS31S"     , 0 , 2 } ,;
                { "Incluir"            , "AxInclui"      , 0 , 3 } ,;
                { "Alterar"            , "AxAltera"      , 0 , 4 } ,;
                { "Excluir"            , "AxDeleta"      , 0 , 5 } ,;
                { "Legenda"	         , "U_AOMS031L(0)" , 0 , 0 }  }
Return( aRotina )


/*
===============================================================================================================================
Programa----------: AOMS031L
Autor-------------: Alex Wallauer
Data da Criacao---: 14/09/2023
===============================================================================================================================
Descrição---------: Definição da legenda da tela principal - Bloqueio de segmentos
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS031L( nReg )

Local uRetorno	:= .T.
Local aLegenda := 	{ 	{ "BR_VERDE"  	, "Desbloqueio"	} ,;
                        { "BR_VERMELHO"	, "Bloqueio"	}  }

//===========================================================================
// Chamada direta da funcao, via menu Recno eh passado
//===========================================================================
If	nReg = -1

	uRetorno := {}
	
	Aadd( uRetorno , { 'ZZ6->ZZ6_MSBLQL <> "1" '	, aLegenda[1][1] } )//BR_VERDE
	Aadd( uRetorno , { 'ZZ6->ZZ6_MSBLQL == "1" '	, aLegenda[2][1] } )//BR_VERMELHO

ELSEIF nReg = -2

	uRetorno := {}
	
	Aadd( uRetorno , { 'ZS6->ZS6_MSBLQL <> "1" '	, aLegenda[1][1] } )//BR_VERDE
	Aadd( uRetorno , { 'ZS6->ZS6_MSBLQL == "1" '	, aLegenda[2][1] } )//BR_VERMELHO

Else
	BrwLegenda(cCadastro, "Legenda",aLegenda)
EndIf

Return( uRetorno )

/*
===============================================================================================================================
Programa----------: AOMS031B
Autor-------------: Alex Wallauer
Data da Criacao---: 14/09/2023
===============================================================================================================================
Descrição---------: Lista consilidada de segmentos
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS031B(cAlias,nReg,nOpc)
LOCAL _cCodsegmento:=""
LOCAL _cDescsegmento:=""
LOCAL _aSubs:={} , _aSubsAux:={}

IF cAlias = "ZZ6"
   _cCodsegmento:=ZZ6->ZZ6_CODIGO
   _cDescsegmento:=ALLTRIM(ZZ6->ZZ6_DESCRO)
ELSEIF cAlias = "ZS6"
   _cCodsegmento:=ZS6->ZS6_CODSEG
   _cDescsegmento:=ALLTRIM(Posicione("ZZ6",1,xFilial("ZZ6")+ZS6->ZS6_CODSEG,"ZZ6_DESCRO"))
ENDIF

ZS6->(DBSEEK(xfilial()+_cCodsegmento))

DO WHILE !ZS6->(EOF()) .AND. _cCodsegmento == ZS6->ZS6_CODSEG
   
   _aSubsAux:={}
   AADD(_aSubsAux,ZS6->ZS6_CODSUB)
   AADD(_aSubsAux,ZS6->ZS6_DESCRI)
   AADD(_aSubs,_aSubsAux)
   ZS6->(Dbskip())
   	
Enddo

IF LEN(_aSubs) > 0
   
   aTitCol:={}
   AADD(aTitCol,"Codigo")
   AADD(aTitCol,"Descricao do Subsegmento")
  
   aSize:=NIL
   cTit1:="LISTA DOS SUBSEGMENTOS DO SEGMENTO: "+_cCodsegmento+" - "+_cDescsegmento
   cTit2:=cTit1
   //ITListBox(_cTitAux,_aHeader,_aCols,_lMaxSiz,_nTipo,_cMsgTop , _lSelUnc , _aSizes              , _nCampo ) 
   U_ITListBox(cTit1   ,aTitCol ,_aSubs  ,.F.    ,1      ,cTit2    ,          ,)

ELSE

   U_ITMSG("Esse segmento "+_cCodsegmento+" - "+_cDescsegmento+" não tem Subsegmentos","Atencao!",,1)

ENDIF

Return

/*
===============================================================================================================================
Programa----------: AOMS31Filtro()
Autor-------------: Alex Wallauer
Data da Criacao---: 14/09/2023
===============================================================================================================================
Descrição---------: Filtro do F3 do ZL6_G 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS31Filtro()
IF FUNNAME() = "MATA030"
   RETURN ZS6->ZS6_MSBLQL <> "1" .AND. ZS6->ZS6_CODSEG = M->A1_I_GRCLI
ELSEIF FUNNAME() = "AOMS014"
   RETURN ZS6->ZS6_MSBLQL <> "1" .AND. ZS6->ZS6_CODSEG = M->ZX_GRCLI
ENDIF

RETURN  .T.
