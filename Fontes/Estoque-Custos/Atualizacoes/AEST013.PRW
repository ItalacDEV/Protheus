/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 17/01/2022 | Voltar as apcoes de incluir e Excluir conforme acesso do ZE0 - Chamado 38941
 Alex Wallauer    | 18/07/2022 | Nova opcao de inclusao em massa e correcoes - Chamado 40616
 Lucas Borges     | 23/07/2025 | Chamado 51340. Ajustar função para validação de ambiente de teste
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "PROTHEUS.CH"
#INCLUDE "rwmake.ch"

/*
===============================================================================================================================
Programa----------: AEST013
Autor-------------: Josue Danich
Data da Criacao---: 01/09/2016
===============================================================================================================================
Descricao---------: Browse para Eventos de custo gerencial, ZE0 - Chamado 15652
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
User Function AEST013()
Local cAlias		 :="ZE0"
Private cCadastro	 :="Eventos de custo Gerencial"
Private aRotina	 :={}   
Private _aItalac_F3:={}


bGrpCus:={||"SELECT ZL5_CODGRP, ZL5_DESGRP,ZL5_TPCUST, ZL5_DTPCUS FROM " + RetSqlName("ZL5") + " ZL5 "+;
            " WHERE ZL5_TPCUST = '"+M->ZE0_TPCUS+"' "+;
            "   AND ZL5_FILIAL = ' ' "+;
            "   AND D_E_L_E_T_ = ' ' "}
_bValGrv:={|cOri,_aDados|IF(cOri="D" .AND. LEN(_aDados)=0,(U_ITmsg("Não existem registros de grupos para a selecao acima para essa filial.",,,3),_cRetorno:=.F.,.F.),.T.) }

//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave            , _nCpoDesc              ,_bCondTab    ,                  _cTitAux, _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"M->ZE0_GRPCT",bGrpCus,{|Tab| ((Tab)->ZL5_CODGRP) }, {|Tab| ALLTRIM((Tab)->ZL5_DESGRP)+;
                                                                              " / Tipo Custo: "+AllTrim((Tab)->ZL5_TPCUST)+;
                                                                              " / "+AllTrim((Tab)->ZL5_DTPCUS) } , ,"Grupo Custo",          ,          ,    1     ,.F.        ,       ,_bValGrv } )

bGrpCus:={||"SELECT ZL6_FILIAL,ZL6_CODEVE,ZL6_DESEVE,ZL6_TPCUS,ZL6_DTPCUS,ZL6_GRPCUS,ZL6_DGRCUS FROM " + RetSqlName("ZL6") + " ZL6 "+;
            " WHERE ZL6_TPCUS  = '"+M->ZE0_TPCUS+"' "+;
            "   AND ZL6_GRPCUS = '"+M->ZE0_GRPCT+"' "+;
            "   AND ZL6_FILIAL = '"+cFilAnt+"' "+;
            "   AND D_E_L_E_T_ = ' ' "+;
            " GROUP BY ZL6_FILIAL,ZL6_CODEVE,ZL6_DESEVE,ZL6_TPCUS,ZL6_DTPCUS,ZL6_GRPCUS,ZL6_DGRCUS "+;
            " ORDER BY ZL6_CODEVE" }
_bValEnv:={|cOri,_aDados|IF(cOri="D" .AND. LEN(_aDados)=0,(U_ITmsg("Não existem registros de eventos para a selecao acima para essa filial.",,,3),_cRetorno:=.F.,.F.),.T.) }

//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave            , _nCpoDesc              ,_bCondTab    ,                  _cTitAux         , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"M->ZE0_EVCUS",bGrpCus,{|Tab| ((Tab)->ZL6_CODEVE) }, {|Tab| ALLTRIM((Tab)->ZL6_DESEVE)+;
                                                                              " / Tipo: "+AllTrim((Tab)->ZL6_TPCUS)+;
                                                                              " / "+AllTrim((Tab)->ZL6_DTPCUS)+;
                                                                              " / Grupo: "+(Tab)->ZL6_GRPCUS+;
		                                                                        " / "+AllTrim((Tab)->ZL6_DGRCUS) } , ,"Evento Custo",          ,          ,    1     ,.F.        ,       ,_bValEnv } )
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave            , _nCpoDesc              ,_bCondTab    ,              _cTitAux     , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})

bEventos:={||" SELECT ZL6_FILIAL,ZL6_SUBEVE,ZL6_DSUBEV,ZL6_CODEVE,ZL6_DESEVE,ZL6_TPCUS,ZL6_DTPCUS,ZL6_GRPCUS,ZL6_DGRCUS FROM " + RetSqlName("ZL6") + " ZL6 "+;
            " WHERE ZL6_TPCUS  = '"+M->ZE0_TPCUS+"' "+;
            "   AND ZL6_GRPCUS = '"+M->ZE0_GRPCT+"' "+;
            "   AND ZL6_CODEVE = '"+M->ZE0_EVCUS+"' "+;
            "   AND ZL6_FILIAL = '"+cFilAnt+"' "+;
            "   AND D_E_L_E_T_ = ' ' "+;
            " GROUP BY ZL6_FILIAL,ZL6_SUBEVE,ZL6_DSUBEV,ZL6_CODEVE,ZL6_DESEVE,ZL6_TPCUS,ZL6_DTPCUS,ZL6_GRPCUS,ZL6_DGRCUS "+;
            " ORDER BY ZL6_SUBEVE" }
	
_bValSub:={|cOri,_aDados|IF(cOri="D" .AND. LEN(_aDados)=0,(U_ITmsg("Não existem registros de sub-eventos para a selecao acima para essa filial.",,,3),_cRetorno:=.F.,.F.),.T.) }
AADD(_aItalac_F3,{"M->ZE0_SEVCT",bEventos,{|Tab| ((Tab)->ZL6_SUBEVE) }, {|Tab| ALLTRIM((Tab)->ZL6_DSUBEV)+;
                                                                              " / Tipo: "+AllTrim((Tab)->ZL6_TPCUS)+;
                                                                              " / "+AllTrim((Tab)->ZL6_DTPCUS)+;
                                                                              " / Grupo: "+(Tab)->ZL6_GRPCUS+;
		                                                                        " / "+AllTrim((Tab)->ZL6_DGRCUS)+;
                                                                              " / Evento: "+AllTrim((Tab)->ZL6_CODEVE)+;
                                                                              " / "+AllTrim((Tab)->ZL6_DESEVE) } , ,"Sub-Evento Custo",          ,          ,    1     ,.F.        ,       , _bValSub})
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave            , _nCpoDesc              ,_bCondTab    ,                   _cTitAux    , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})

AADD(aRotina,{"Pesquisar"	,"AxPesqui",0,1})
AADD(aRotina,{"Visualizar"	,"AxVisual",0,2})
IF U_ITVACESS( 'ZZL' , 3 , 'ZZL_FCUSTO' , "S" )
   AADD(aRotina,{"Incluir"	   ,"U_AEST13Manut",0,3})
ENDIF
AADD(aRotina,{"Alterar"		,"U_AEST13Manut",0,4})
IF U_ITVACESS( 'ZZL' , 3 , 'ZZL_FCUSTO' , "S" )
   AADD(aRotina,{"Excluir"    ,"U_AEST13Manut",0,5})
   AADD(aRotina,{"Importacao de dados","U_AEST13Manut",0,4})
ENDIF	
dbSelectArea(cAlias)
dbSetOrder(1)
mBrowse(6,1,22,75,cAlias)

Return Nil
/*
===============================================================================================================================
Programa----------: U_AEST13Manut
Autor-------------: Alex Wallauer
Data da Criacao---: 13/07/2017
===============================================================================================================================
Descricao---------: Manutenção do ZE0
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================*/
User Function AEST13Manut(cAlias,nReg,nOpc)

PRIVATE _aDadosAnterior := {}

IF nOpc = 3
//    Return AxInclui(cAlias,nReg,nOpc;;;;;,"U_AEST13Log('I')")
      Return AxInclui(cAlias,nReg,nOpc,;
       /*aAcho>     */ ,;
       /*cFunc>     */ ,;
       /*aCpos>     */ ,;
       /*cTudoOk>   */ 'U_AEST13Val(M->ZE0_DATARQ)',;
       /*lF3>       */ ,;
       /*cTransact> */ "U_AEST13Log('I')",;//Antes 
       /*aButtons>  */ ,;
       /*aParam>    */ ,;
       /*aAuto>     */ ,;
       /*lVirtual>  */ ,;
       /*lMaximized>*/ )

ELSEIF nOpc = 4
   IF U_AEST13Val(ZE0->ZE0_DATARQ)
      Return  AxAltera(cAlias,nReg,nOpc,,,,,,"U_AEST13Log('A')","U_AEST13Log('GUARDA')")
   ENDIF
ELSEIF nOpc = 5
   IF U_AEST13Val(ZE0->ZE0_DATARQ)
      Return  AxDeleta(cAlias,nReg,nOpc,"U_AEST13Log('E')")
   ENDIF
ELSEIF nOpc = 6
   FWMSGRUN( ,{|oproc| AEST13Imp(oproc) } ,"Processando..." ,"Iniciando o processamento..." )
ENDIF

Return .t.

/*
===============================================================================================================================
Programa----------: AEST13Log()
Autor-------------: Alex Wallauer
Data da Criacao---: 13/07/2017
===============================================================================================================================
Descricao---------: Grava o log ZE0
===============================================================================================================================
Parametros--------: cTipo: I ou A ou E
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/
User Function AEST13Log(cTipo)
LOCAL I,_aDadAlt:={}
LOCAL _lTemDiferente:=.F.

IF cTipo == 'GUARDA'//Executado antes da tela do alterar para guardar os dados anterior

   aAdd( _aDadosAnterior ,  ZE0->ZE0_QTDE    )
   aAdd( _aDadosAnterior ,  ZE0->ZE0_VALOR   )
   aAdd( _aDadosAnterior ,  ZE0->ZE0_VLRLT   )
   aAdd( _aDadosAnterior ,  ZE0->ZE0_VDOLAR  )
   aAdd( _aDadosAnterior ,  ZE0->ZE0_LITRAG  )
   aAdd( _aDadosAnterior ,  ZE0->ZE0_LITRA2  )//Array _aDadAlt tem que ter o mesmo numero de linhas que a array _aDadosAnterior
   RETURN .T.

ELSE//IF cTipo $ "I,E"

   aAdd( _aDadAlt , { "ZE0_QTDE"   ,ZE0->ZE0_QTDE   ,M->ZE0_QTDE   ,00,.F.} )
   aAdd( _aDadAlt , { "ZE0_VALOR"  ,ZE0->ZE0_VALOR  ,M->ZE0_VALOR  ,00,.F.} )
   aAdd( _aDadAlt , { "ZE0_VLRLT"  ,ZE0->ZE0_VLRLT  ,M->ZE0_VLRLT  ,00,.F.} )
   aAdd( _aDadAlt , { "ZE0_VDOLAR" ,ZE0->ZE0_VDOLAR ,M->ZE0_VDOLAR ,00,.F.} )
   aAdd( _aDadAlt , { "ZE0_LITRAG" ,ZE0->ZE0_LITRAG ,M->ZE0_LITRAG ,00,.F.} )
   aAdd( _aDadAlt , { "ZE0_LITRA2" ,ZE0->ZE0_LITRA2 ,M->ZE0_LITRA2 ,00,.F.} )//Array _aDadAlt tem que ter o mesmo numero de linhas que a array _aDadosAnterior

ENDIF

IF cTipo = "I"
   cTipo:="Inclusão"
   FOR I := 1 TO LEN(_aDadAlt)
       _aDadAlt[I,2]:=_aDadAlt[I,4]//Limpa a origem
       _aDadAlt[I,5]:=.T.
   NEXT
   _lTemDiferente:=.T.
ELSEIF cTipo = "A"
   cTipo:="Alteração"
   FOR I := 1 TO LEN(_aDadAlt)//Array _aDadAlt tem que ter o mesmo numero de linhas que a array _aDadosAnterior
       IF (_aDadAlt[I,2] # _aDadosAnterior[I])//Verifica se os dados estao diferentes
          _lTemDiferente:=.T.
          _aDadAlt[I,5]:=.T.
       ENDIF
       _aDadAlt[I,2]:=_aDadosAnterior[I]//Grava o valor anterior pq nesse momento os dados do arquivo já esta = ao da memoria
   NEXT
ELSEIF cTipo = "E"
   cTipo:="Exclusão"
    _lTemDiferente:=.T.
   FOR I := 1 TO LEN(_aDadAlt)
       _aDadAlt[I,3]:=_aDadAlt[I,4]//Limpa o destino
       _aDadAlt[I,5]:=.T.
   NEXT
ENDIF

IF _lTemDiferente
   // Grava o LOG
   U_ITGrvLog( _aDadAlt , 'ZE0' , 1 , ZE0->( ZE0_FILIAL+ZE0_DATARQ+ZE0_GRPCT+ZE0_TPCUS+ZE0_EVCUS+ZE0_SEVCT ) , cTipo , RetCodUsr() )
   // Envia WF
   AEST13WF(_aDadAlt,cTipo,{})
ENDIF

RETURN .T.


/*
===============================================================================================================================
Programa----------: F3ZL5Filtro()
Autor-------------: Alex Wallauer
Data da Criacao---: 18/01/2022
===============================================================================================================================
Descricao---------: Filtro do F4 do ZL5
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T. ou .F.
===============================================================================================================================*/
USER Function F3ZL5Filtro()//U_F3ZL5Filtro()

IF IsInCallStack("U_AEST013")
   RETURN (M->ZE0_TPCUS = ZL5->ZL5_TPCUST)
ELSE
   RETURN (M->ZL6_TPCUS = ZL5->ZL5_TPCUST)
ENDIF
RETURN .T.

/*
===============================================================================================================================
Programa----------: AEST13Val()
Autor-------------: Alex Wallauer
Data da Criacao---: 18/07/2022
===============================================================================================================================
Descricao---------: Data : ZE0_DATARQ
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T. ou .F.
===============================================================================================================================*/
USER Function AEST13Val(cData)//U_AEST13Val(M-ZE0_DATARQ)
LOCAL _cDatAtual:=U_ITGETMV( "IT_ULMES" ,"012001") 
LOCAL _cDataZE0 :=SUBSTR(cData,3,4)+SUBSTR(cData ,1,2)//ZE0->ZE0_DATARQ
_cDatAtual:=SUBSTR(_cDatAtual,3,4)+SUBSTR(_cDatAtual,1,2)

IF _cDataZE0 <= _cDatAtual 
   _cDatAtual:=SUBSTR(_cDatAtual,5,2)+"/"+SUBSTR(_cDatAtual,1,4)
   U_ITmsg("Não é permitido alterar registros menor ou igual ao mes / ano: "+_cDatAtual,,,3)
   RETURN .F.
ENDIF
RETURN .T.

/*
===============================================================================================================================
Programa----------: AEST13Imp()
Autor-------------: Alex Wallauer
Data da Criacao---: 18/07/2022
===============================================================================================================================
Descricao---------: importa daodos do CSV PARA ZE0
===============================================================================================================================
Parametros--------: cTipo: I ou A ou E
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/
STATIC Function AEST13Imp(oproc)

Local _aParAux	:= {}
Local _aParRet	:= {}
LOCAL nI ,_lOK := .F.
Private oMarkBRW	:= Nil
Private cAliasAux	:= GetNextAlias()
Private _nTotReg	:= 0

MV_PAR01 := SPACE(200)
 
aAdd( _aParAux ,{ 1 ,"Selecione arquivo:"		,MV_PAR01,"@!"		,""	,"DIR"		,"" ,100 ,.T. } ) 	

For nI := 1 To Len( _aParAux )
	aAdd( _aParRet ,_aParAux[nI][03] )
Next nI

          //aParametros,cTitle                                   ,@aRet    ,[bOk]  ,[ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ] 
IF !ParamBox( _aParAux ,"Selecione o Arquivo .CSV para Importar" ,@_aParRet,       ,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
	Return .T.
EndIf

cTimeInicial:=TIME()

oproc:cCaption := ("Abrindo arquivo...")
ProcessMessages()

IF (upper(right(alltrim(MV_PAR01),4))) == ".CSV" 

	_carq := ALLTRIM(MV_PAR01)

	If FT_FUSE(_carq) == -1
	
		u_itmsg("1-Falha ao abrir o arquivo: "+_carq,"Erro",,1)
		
		Return .F.
		
	Endif 
	          
  	FT_FGOTOP() //POSICIONA NO TOPO DO ARQUIVO
  	_cDados := FT_FREADLN()

  	If UPPER(alltrim(_cDados)) == UPPER("ZE0_TPCUS;ZE0_GRPCT;ZE0_EVCUS;ZE0_SEVCT;ZE0_QTDE;ZE0_VALOR;ZE0_DATARQ;ZE0_VLRLT;ZE0_VDOLAR;ZE0_LITRAG;ZE0_LITRA2")///********************
	   _lOK := .T. 
  	Endif

	//Fecha arquivo e prepara parâmetro com arquivo convertido
	FT_FUSE()

ELSE

	U_ITMSG("O arquivo informado: "+Alltrim(MV_PAR01)+" não tem extenção [ .CSV ] ",;
            "Arquivo inválido",;
		    "Favor informar uma arquivo no formato [ .CSV ].")
	Return .F.

EndIf


If _lOK 

	If FT_FUSE(_carq) == -1
		
		u_itmsg("Falha ao abrir o arquivo: "+_carq,"Erro",,1)
		Return .F.

	EndIf
	
	FT_FGOTOP() //POSICIONA NO TOPO DO ARQUIVO
	
	_nReg:= FT_FLASTREC()

	ProcRegua(_nReg)
	
	FT_FGOTOP() //POSICIONA NO TOPO DO ARQUIVO
	
	If _nReg == 0 //O arquivo informado nao possui nenhuma linha de dados
		
		U_ITMSG("O arquivo informado para relizar a importação não possui dados.",;
                "Arquivo inválido",;
				"Favor verificar se o arquivo informado esta no formato correto.")
		Return .F.
	
	EndIf

	_aDados := AEST13LER(oproc,_nReg) //Faz leitura dos dados

	If len(_aDados) <= 0

		u_itmsg( "Não foram encontrados registros válidos no arquivo!" ,"Atenção!",,1 )
		Return .F.
	
	EndIf

Else

	U_ITMSG("O arquivo "+_carq+" informado para relizar a importação não tem o layout padrão.",;
            "Arquivo com formato inválido",;
			"O CSV deve ter as colunas [ ZE0_TPCUS;ZE0_GRPCT;ZE0_EVCUS;ZE0_SEVCT;ZE0_QTDE;ZE0_VALOR;ZE0_DATARQ;ZE0_VLRLT;ZE0_VDOLAR;ZE0_LITRAG;ZE0_LITRA2 ] e o mesmo deve ser salvo "+;
		    "no Excel no formato [ CSV (separado por virgulas) ] ",1)
		Return .F.
	
Endif


DO WHILE LEN(_aDados) > 0 
   lGravar:=.F.
   _aCab:={}
   _aSizes:={}

   AADD(_aCab,"" ) 
   AADD(_aSizes,10)
   AADD(_aCab,Getsx3cache("ZE0_FILIAL","X3_TITULO") )//02 
   AADD(_aSizes,20)
   AADD(_aCab,Getsx3cache("ZE0_TPCUS" ,"X3_TITULO") )//03 
   AADD(_aSizes,35)
   AADD(_aCab,Getsx3cache("ZE0_GRPCT" ,"X3_TITULO") )//04 
   AADD(_aSizes,35)
   AADD(_aCab,Getsx3cache("ZE0_EVCUS" ,"X3_TITULO") )//05 
   AADD(_aSizes,35)
   AADD(_aCab,Getsx3cache("ZE0_SEVCT" ,"X3_TITULO") )//06 
   AADD(_aSizes,35)
   AADD(_aCab,Getsx3cache("ZE0_QTDE"  ,"X3_TITULO") )//07
   AADD(_aSizes,35)
   AADD(_aCab,Getsx3cache("ZE0_VALOR" ,"X3_TITULO") )//08
   AADD(_aSizes,35)
   AADD(_aCab,Getsx3cache("ZE0_DATARQ","X3_TITULO") )//09
   AADD(_aSizes,35)
   AADD(_aCab,Getsx3cache("ZE0_VLRLT" ,"X3_TITULO") )//10
   AADD(_aSizes,35)
   AADD(_aCab,Getsx3cache("ZE0_VDOLAR","X3_TITULO") )//11 
   AADD(_aSizes,35)
   AADD(_aCab,Getsx3cache("ZE0_LITRAG","X3_TITULO") )//12 
   AADD(_aSizes,35)
   AADD(_aCab,Getsx3cache("ZE0_LITRA2","X3_TITULO") )//13 
   AADD(_aSizes,35)
   AADD(_aCab,'Observacao')//14
   AADD(_aSizes,150)

   _cMsgTop:="Pedidos encontrados - H.I.: "+cTimeInicial+" H.F.: "+TIME()

   _cTitulo:="Importacao de dados do Csuto Gerencial"

   bOk:={|oDlg| IF(U_ITMSG("Confirma Gravacao ?",'Atenção!',,3,2,2) ,(lGravar:=.T., oDlg:End() ) , )   }

   //                        , _aCols  ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons )
   U_ITListBox(_cTitulo,_aCab,_aDados  , .T.    , 4    ,_cMsgTop,          ,_aSizes   ,         , bOk ,        , )
                                                                                                  
   IF lGravar
      AEST13GRV(oproc,_nReg)
   ELSEIF  !U_ITMSG("Confirma Sair ?",'Atenção!',,3,2,2)
       LOOP
   ENDIF

   EXIT

ENDDO

Return .F.

/*
===============================================================================================================================
Programa----------: AEST13LER
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 180/07/2022
===============================================================================================================================
Descrição---------: Faz a leitura de dados
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: _aDados - array com dados carregados do arquivo
===============================================================================================================================
*/

Static function AEST13LER(oproc,_nReg)

Local _nCont 	 := 0
Local _cdados	 := ""
Local _alinha	 := {}
Local _aDados 	 := {}
//LOCAL _cDatAtual:=U_ITGETMV( "IT_ULMES" ,"012001") 

ZL6->(DBSETORDER(6))// ZL6_FILIAL    +ZL6_TPCUS  +ZL6_GRPCUS +ZL6_CODEVE +ZL6_SUBEVE
ZE0->(DBSETORDER(6))// ZE0_FILIAL+ZE0_DATARQ +ZE0_TPCUS  +ZE0_GRPCT   +ZE0_EVCUS+ZE0_SEVCT

FT_FGOTOP() //POSICIONA NO TOPO DO ARQUIVO
FT_FSKIP()
_aChaveRepetida:={}
DO While !FT_FEOF()  //FACA ENQUANTO NAO FOR FIM DE ARQUIVO
	
	_nCont++ 
	oproc:cCaption := ( "Lendo linha " + strzero(_nCont,6) + " de " + strzero(_nreg,6) + "." )
	ProcessMessages()
			
	_cDados := (cFilant+";"+FT_FREADLN())
	_aLinha := StrTokArr(_cDados,";")
	
	//Verifica se é final de arquivo
	If alltrim(_cdados) = ';;;;;' .and. _nCont > 4
		Exit
	Endif 	
	
	//Verifica se é linha válida
	If LEN(_aLinha) < 12	
		FT_FSKIP()
		Loop		
	Endif
   
    _cErro:=""
	
  	 IF !SM0->(DBSEEK( cEmpAnt + _aLinha[01] ) )
       _cErro:="[Filial nao existe: "+_cFilial+"] "
    ENDIF

     // ZL6_FILIAL    +ZL6_TPCUS  +ZL6_GRPCUS +ZL6_CODEVE +ZL6_SUBEVE

    _aLinha[02]:=STRZERO(VAL(_aLinha[02]),LEN(ZL6->ZL6_TPCUS ))
    _aLinha[03]:=STRZERO(VAL(_aLinha[03]),LEN(ZL6->ZL6_GRPCUS))
    _aLinha[04]:=STRZERO(VAL(_aLinha[04]),LEN(ZL6->ZL6_CODEVE))
    _aLinha[05]:=STRZERO(VAL(_aLinha[05]),LEN(ZL6->ZL6_SUBEVE))

    _aLinha[06]:=STRTRAN(_aLinha[06],".","")//Tira o seprador de milhar brasileiro
    _aLinha[07]:=STRTRAN(_aLinha[07],".","")//Tira o seprador de milhar brasileiro
    _aLinha[09]:=STRTRAN(_aLinha[09],".","")//Tira o seprador de milhar brasileiro
    _aLinha[10]:=STRTRAN(_aLinha[10],".","")//Tira o seprador de milhar brasileiro
    _aLinha[11]:=STRTRAN(_aLinha[11],".","")//Tira o seprador de milhar brasileiro
    _aLinha[12]:=STRTRAN(_aLinha[12],".","")//Tira o seprador de milhar brasileiro

    _aLinha[06]:=STRTRAN(_aLinha[06],",",".")//Troca os separadores de decimal brasileiro para o ingles
    _aLinha[07]:=STRTRAN(_aLinha[07],",",".")//Troca os separadores de decimal brasileiro para o ingles
    _aLinha[09]:=STRTRAN(_aLinha[09],",",".")//Troca os separadores de decimal brasileiro para o ingles
    _aLinha[10]:=STRTRAN(_aLinha[10],",",".")//Troca os separadores de decimal brasileiro para o ingles
    _aLinha[11]:=STRTRAN(_aLinha[11],",",".")//Troca os separadores de decimal brasileiro para o ingles
    _aLinha[12]:=STRTRAN(_aLinha[12],",",".")//Troca os separadores de decimal brasileiro para o ingles

    _aLinha[08]:=ALLTRIM(_aLinha[08])
    IF LEN(_aLinha[08]) < 6
       _aLinha[08]:="0"+_aLinha[08]
    ENDIF

    IF VAL(LEFT(_aLinha[08],2))   < 0     .OR.   VAL(LEFT(_aLinha[08],2))   > 12 .OR.;
     VAL(SUBSTR(_aLinha[08],3,4)) < 2000  .OR. VAL(SUBSTR(_aLinha[08],3,4)) > 3000
       _cErro+="[Data arq. invalida:  "+_aLinha[08]+"] "
    ENDIF

    //IF _aLinha[08] <= _cDatAtual 
    //   _cErro+="[Não é permitido data "+_aLinha[08]+" menor ou igual ao mes / ano: "+_cDatAtual+"] "
    //ENDIF

           // ZL6_FILIAL    +ZL6_TPCUS  +ZL6_GRPCUS +ZL6_CODEVE +ZL6_SUBEVE
    _cChave1:=XFILIAL("ZL6")+_aLinha[02]+_aLinha[03]+_aLinha[04]+_aLinha[05]
    _cChave2:=XFILIAL("ZL6")+" "+_aLinha[02]+" "+_aLinha[03]+" "+_aLinha[04]+" "+_aLinha[05]
    
    IF !ZL6->(DBSEEK( _cChave1 ))
       _cErro+="[Chave invalida : "+_cChave2+"] "
    ENDIF

            //ZE0_FILIAL +ZE0_DATARQ +ZE0_TPCUS  +ZE0_GRPCT   +ZE0_EVCUS +ZE0_SEVCT
    _cChave1:=_aLinha[01]+_aLinha[08]+_aLinha[02]+_aLinha[03]+_aLinha[04]+_aLinha[05]
    _cChave2:=_aLinha[01]+" "+_aLinha[08]+" "+_aLinha[02]+" "+_aLinha[03]+" "+_aLinha[04]+" "+_aLinha[05]

	If ZE0->( Dbseek( _cChave1 ) ) //ZE0_FILIAL+ZE0_DATARQ +ZE0_TPCUS  +ZE0_GRPCT   +ZE0_EVCUS+ZE0_SEVCT
       _cErro+="[Chave já existe : "+_cChave2+"] "
   ELSE
      IF AScan(_aChaveRepetida,_cChave1) = 0
         AADD(_aChaveRepetida,_cChave1)
      ELSE
         _cErro+="[Chave repetida nesse arquivo : "+_cChave2+"] "
      ENDIF   
   ENDIF

    /*IF VAL(_aLinha[06]) < 0
       _cErro+="[Quantidade (ZE0_QTDE) invalida : "+_aLinha[06]+"] "
    ENDIF
    IF VAL(_aLinha[07]) < 0
       _cErro+="[Valor (ZE0_VALOR) invalida : "+_aLinha[07]+"] "
    ENDIF
    IF VAL(_aLinha[09]) < 0
       _cErro+="[Valor por litro (ZE0_VLRLT) invalida : "+_aLinha[09]+"] "
    ENDIF
    IF VAL(_aLinha[10]) < 0
       _cErro+="[Valor Dolar (ZE0_VDOLAR) invalida : "+_aLinha[10]+"] "
    ENDIF*/
    IF VAL(_aLinha[11]) < 0
       _cErro+="[Litragem (ZE0_LITRAG) invalida : "+_aLinha[11]+"] "
    ENDIF
    IF VAL(_aLinha[12]) < 0
       _cErro+="[Litragem 2 (ZE0_LITRA2) invalida : "+_aLinha[12]+"] "
    ENDIF

	 aItem:={}
	   
   AADD(aItem,EMPTY(_cErro))// 01
   AADD(aItem,_aLinha[01])  // 02 - ZE0_FILIAL
   AADD(aItem,_aLinha[02])  // 03 - ZE0_TPCUS
   AADD(aItem,_aLinha[03])  // 04 - ZE0_GRPCT
   AADD(aItem,_aLinha[04])  // 05 - ZE0_EVCUS
   AADD(aItem,_aLinha[05])  // 06 - ZE0_SEVCT
   AADD(aItem,_aLinha[06])  // 07 - ZE0_QTDE
   AADD(aItem,_aLinha[07])  // 08 - ZE0_VALOR
   AADD(aItem,_aLinha[08])  // 09 - ZE0_DATARQ
   AADD(aItem,_aLinha[09])  // 10 - ZE0_VLRLT
   AADD(aItem,_aLinha[10])  // 11 - ZE0_VDOLAR
   AADD(aItem,_aLinha[11])  // 12 - ZE0_LITRAG
   AADD(aItem,_aLinha[12])  // 13 - ZE0_LITRA2
   AADD(aItem,_cErro)       // 14
   AADD(_aDados,aItem)	
	
	FT_FSKIP()
	
Enddo
	
Return _aDados

/*
===============================================================================================================================
Programa----------: AEST13GRV
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 18/07/2022
===============================================================================================================================
Descrição---------: Faz a leitura de dados
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: _aDados - array com dados carregados do arquivo
===============================================================================================================================
*/
Static function AEST13GRV(oproc,_nReg)
LOCAL _ni:=0 ; _nCont:=0
LOCAL _aTotias:={0,0,0}
LOCAL _cTotais:=""

ZE0->(DBSETORDER(6))// ZE0_FILIAL+ZE0_DATARQ +ZE0_TPCUS  +ZE0_GRPCT   +ZE0_EVCUS+ZE0_SEVCT

//ZL6->(DBSETORDER(6))// ZL6_FILIAL+ZL6_TPCUS+ZL6_GRPCUS+ZL6_CODEVE+ZL6_SUBEVE

FOR _ni := 1 TO LEN(_aDados)

	_nCont++ 
	oproc:cCaption := ( "Lendo linha " + strzero(_nCont,6) + " de " + strzero(_nreg,6) + "." )
	ProcessMessages()
   IF !_aDados[_ni][1]
      _aTotias[1]++
      LOOP
   ENDIF
    _cChave:=_aDados[_ni,02]+_aDados[_ni,09]+_aDados[_ni,02]+_aDados[_ni,03]+_aDados[_ni,04]+_aDados[_ni,05]
            //ZE0_FILIAL+ZE0_DATARQ +ZE0_TPCUS  +ZE0_GRPCT   +ZE0_EVCUS+ZE0_SEVCT
/*
	If ZE0->( Dbseek( _cChave ) ) //ZE0_FILIAL+ZE0_DATARQ +ZE0_TPCUS  +ZE0_GRPCT   +ZE0_EVCUS+ZE0_SEVCT
	
		//Achou registro so atualiza quantidade e valor
		ZE0->(RecLock("ZE0",.F.))
		ZE0->ZE0_QTDE	:= VAL(_aDados[_ni][07])
		ZE0->ZE0_VALOR	:= VAL(_aDados[_ni][08])
		ZE0->ZE0_VLRLT	:= VAL(_aDados[_ni][10])
		ZE0->ZE0_VDOLAR:= VAL(_aDados[_ni][11])
		ZE0->ZE0_LITRAG:= VAL(_aDados[_ni][12])
		ZE0->ZE0_LITRA2:= VAL(_aDados[_ni][13])
      _aTotias[2]++

	Else*/
	
		//Nao achou registro cria um novo
		ZE0->(RecLock("ZE0",.T.))
		
		ZE0->ZE0_FILIAL:=	_aDados[_ni][02]	
      ZE0->ZE0_TPCUS	:=	_aDados[_ni][03]
      ZE0->ZE0_DTPCT	:=	ALLTRIM(POSICIONE("ZL4",1,XFILIAL("ZL4")+ZE0->ZE0_TPCUS,"ZL4_DESCR"))
      _aDados[_ni][03]:=ZE0->ZE0_DTPCT // Para o E-mail
      ZE0->ZE0_GRPCT	:=	_aDados[_ni][04]
		ZE0->ZE0_DGRPCT:=	ALLTRIM(POSICIONE("ZL5",3,XFILIAL("ZL5")+ZE0->ZE0_TPCUS+ZE0->ZE0_GRPCT,"ZL5_DESGRP"))
      _aDados[_ni][04]:=ZE0->ZE0_DGRPCT // Para o E-mail
		ZE0->ZE0_EVCUS	:=	_aDados[_ni][05]
		ZE0->ZE0_DEVCT	:=	ALLTRIM(POSICIONE("ZL6",6,XFILIAL("ZL6")+ZE0->ZE0_TPCUS+ZE0->ZE0_GRPCT+ZE0->ZE0_EVCUS,"ZL6_DESEVE"))
      _aDados[_ni][05]:=ZE0->ZE0_DEVCT // Para o E-mail
		ZE0->ZE0_SEVCT	:=	_aDados[_ni][06]
		ZE0->ZE0_DSECT	:=	ALLTRIM(POSICIONE("ZL6",6,XFILIAL("ZL6")+ZE0->ZE0_TPCUS+ZE0->ZE0_GRPCT+ZE0->ZE0_EVCUS+ZE0->ZE0_SEVCT,"ZL6_DSUBEV"))
      _aDados[_ni][06]:=ZE0->ZE0_DSECT // Para o E-mail
      ZE0->ZE0_QTDE	:= VAL(_aDados[_ni][07])
		ZE0->ZE0_VALOR	:= VAL(_aDados[_ni][08])
		ZE0->ZE0_DATARQ:= _aDados[_ni][09]
		ZE0->ZE0_VLRLT	:= VAL(_aDados[_ni][10])
		ZE0->ZE0_VDOLAR:= VAL(_aDados[_ni][11])
		ZE0->ZE0_LITRAG:= VAL(_aDados[_ni][12])
		ZE0->ZE0_LITRA2:= VAL(_aDados[_ni][13])
      _aTotias[3]++

//	Endif
   ZE0->(MsUnlock())

NEXT

AEST13WF({},"Importação de dados",_aDados,oproc)

_cTotais+=ALLTRIM(STR(_aTotias[1]))+" Registos Rejeitados"+CHR(13)+CHR(10)
//_cTotais+=ALLTRIM(STR(_aTotias[2]))+" Registos Alterados"+CHR(13)+CHR(10)
_cTotais+=ALLTRIM(STR(_aTotias[3]))+" Registos Incluidos"

U_ITMSG("DADOS PROCESSADOS COM SUCESSO",'Atenção!',_cTotais,IF(_aTotias[3]>0,2,3))

ZL6->(DBSETORDER(1))
ZE0->(DBSETORDER(1))

RETURN .T.

/*
===============================================================================================================================
Programa----------: AEST13WF()
Autor-------------: Alex Wallauer
Data da Criacao---: 13/07/2017
===============================================================================================================================
Descricao---------: Work do Log
===============================================================================================================================
Parametros--------: _aDadAlt,cTipo,_aDados
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================*/
Static Function AEST13WF(_aDadAlt,cTipo,_aDados,oproc)

Local _aConfig	:= U_ITCFGEML('')
Local _cHtml	:= '' , _nI , _nCont , _aSizes:={}
Local _cEmail	:= U_ITGETMV( 'IT_EMZE0LO' , 'sistema@italac.com.br' )
Local _cAssunto := 'Workflow - '+cTipo+' de Custo Gerencial'

_cHtml += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN""http://www.w3.org/TR/html4/loose.dtd">'
_cHtml += '<html>'
_cHtml += '<head>'
_cHtml += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"><title>Untitled Document</title>'
_cHtml += '<style type="text/css"><!--'
_cHtml += 'body,td,th { font-family: Arial, Helvetica, sans-serif; font-size: 12px;}.negrito { font-family: Arial, Helvetica, sans-serif; font-size: 12px; font-weight: bold; color: #003366;}.negrito2 { font-family: Arial, Helvetica, sans-serif; font-size: 15px; font-weight: bold; color: #003366;}.texto1 { font-family: Arial, Helvetica, sans-serif; font-size: 11px; color: #666666;}.texto2 { font-family: Arial, Helvetica, sans-serif; font-size: 9px; color: #666666;}'
_cHtml += 'table.bordasimples { border-collapse: collapse; }'
_cHtml += 'table.bordasimples tr td { border:1px solid #777777; }'

//_cHtml += 'td.titulos { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
//_cHtml += 'td.grupos { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
//_cHtml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'

_cHtml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
_cHtml += 'td.grupos	{ font-family:VERDANA; font-size:11px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
_cHtml += 'td.itens	{ font-family:VERDANA; font-size:10px; V-align:middle; margin-right: 13px; margin-left: 15px; background-color: #FFFFFF; }'

_cHtml += '--></style>'
_cHtml += '</head>'
_cHtml += '<body>'
_cHtml += '<p class=MsoNormal>'
//_cHtml += '<img src="http://www.italac.com.br/wp-content/themes/italac/assets/images/logo.svg" >'//alt="" width="171" height="63">
_cHtml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="600" height="50"><br>'
_cHtml += '<br>'

_cTitulo := cTipo+" de Custo Gerencial"
_cHtml += '<table width="996" height="39"> <tr> <td align="center"><span class="negrito2" align="center">'+_cTitulo+'</span><br>'
_cHtml += '<br> </td> </tr> </table>'
_cHtml += '<p><span class="negrito">Prezados, </span>'

If !Empty(_aDadAlt)

_cTexto2 := cTipo

_cTexto2 += " na competencia  "+TRANS(ZE0_DATARQ,"@R 99/9999")+" da Filial / Tipo / Grupo / Evento / Subevento: </span>[ "+ZE0->(ZE0_FILIAL+" / "+ZE0_TPCUS+"-"+AllTrim(ZE0_DTPCT)+" / "+ZE0_GRPCT+"-"+AllTrim(ZE0_DGRPCT)+" / "+ZE0_EVCUS+"-"+AllTrim(ZE0_DEVCT)+" / "+ZE0_SEVCT+"-"+AllTrim(ZE0_DSECT))+" ]"

_cHtml += '<br><span class="negrito">'+_cTexto2+'</span><span class="texto1"></span></br></p>'

_cHtml += '<br>'
_cHtml += '<br>'
_cHtml += '<p><span class="negrito">Usuário que realizou a '+cTipo+': </span>'+Alltrim(RetCodUsr())+" - "+Alltrim(UsrFullName(RetCodUsr()))
_cHtml += '<br><span class="negrito">Data da '+cTipo+': </span>'+dtoc(dDataBase)+" as "+TIME()+'</p>'
_cHtml += '<table width="500" border="0" cellpadding="0" cellspacing="8"> <tr> <td width="167"><P class=MsoNormal> <span class="texto2" align="center"></span></p></body></html>'
	
	_cHtml += '<br>'
	_cHtml += '<table class="bordasimples" width="500">'
	_cHtml += '    <tr>'
	_cHtml += '      <td class="itens" align="left" width="30%"><b>Campo</b></td>'
	_cHtml += '      <td class="itens" align="right" width="35%"><b>Conteudo Anterior</b></td>'
	_cHtml += '      <td class="itens" align="right" width="35%"><b>Conteudo Atual</b></td>'
	_cHtml += '    </tr>'
	For _nI := 1 To Len( _aDadAlt )		
	    IF _aDadAlt[_nI,5]
	       _cPicture:=PesqPict("ZE0",_aDadAlt[_nI][01])
		   _cHtml += '    <tr>'
		   _cHtml += '      <td class="itens" align="left" width="30%">'+ AVSX3(_aDadAlt[_nI][01],5)+'</td>'
		   _cHtml += '      <td class="itens" align="right" width="35%">'+ Transform(_aDadAlt[_nI][02],_cPicture)+'</td>'
		   _cHtml += '      <td class="itens" align="right" width="35%">'+ Transform(_aDadAlt[_nI][03],_cPicture)+'</td>'
		   _cHtml += '    </tr>'
		ENDIF
	Next _nI
	_cHtml += '</table>'
	
ELSEIF !Empty(_aDados)

_cHtml += '<br>'
_cHtml += '<p><span class="negrito">Usuário que realizou a '+cTipo+': </span>'+Alltrim(RetCodUsr())+" - "+Alltrim(UsrFullName(RetCodUsr()))
_cHtml += '<br><span class="negrito">Data da '+cTipo+': </span>'+dtoc(dDataBase)+" as "+TIME()+'</p>'
_cHtml += '<table width="500" border="0" cellpadding="0" cellspacing="8"> <tr> <td width="167"><P class=MsoNormal> <span class="texto2" align="center"></span></p></body></html>'
_cHtml += '<br>'

   cGetAssun:="Dados importados: "

   For _nCont := 1 To Len(_aCab)
       _aCab[_nCont] := STRTRAN( ALLTRIM(_aCab[_nCont]) , " ", "_")
   NEXT

   _aSizes:={000,1,15,14,14,14,6,6,6,6,6,6,6}

   _cHtml += '<br>'
   _cHtml += '<table class="bordasimples" width="3100">'
   _cHtml += '    <tr>'
   _cHtml += '		<td align="left" colspan="'+ALLTRIM(STR(LEN(_aSizes)-1))+'" class="grupos"><b>'+cGetAssun+'</b></td>'
   _cHtml += '    </tr>'
   _cHtml += '    <tr>'
   _cHtml += '      <td class="itens" align="center" width="'+ALLTRIM(STRZERO(_aSizes[02],3))+'%"><b>'+_aCab[02]+'</b></td>'
   _cHtml += '      <td class="itens" align="center" width="'+ALLTRIM(STRZERO(_aSizes[03],3))+'%"><b>'+_aCab[03]+'</b></td>'
   _cHtml += '      <td class="itens" align="center" width="'+ALLTRIM(STRZERO(_aSizes[04],3))+'%"><b>'+_aCab[04]+'</b></td>'
   _cHtml += '      <td class="itens" align="center" width="'+ALLTRIM(STRZERO(_aSizes[05],3))+'%"><b>'+_aCab[05]+'</b></td>'
   _cHtml += '      <td class="itens" align="center" width="'+ALLTRIM(STRZERO(_aSizes[06],3))+'%"><b>'+_aCab[06]+'</b></td>'
   _cHtml += '      <td class="itens" align="center" width="'+ALLTRIM(STRZERO(_aSizes[07],3))+'%"><b>'+_aCab[07]+'</b></td>'
   _cHtml += '      <td class="itens" align="center" width="'+ALLTRIM(STRZERO(_aSizes[08],3))+'%"><b>'+_aCab[08]+'</b></td>'
   _cHtml += '      <td class="itens" align="center" width="'+ALLTRIM(STRZERO(_aSizes[09],3))+'%"><b>'+_aCab[09]+'</b></td>'
   _cHtml += '      <td class="itens" align="center" width="'+ALLTRIM(STRZERO(_aSizes[10],3))+'%"><b>'+_aCab[10]+'</b></td>'
   _cHtml += '      <td class="itens" align="center" width="'+ALLTRIM(STRZERO(_aSizes[11],3))+'%"><b>'+_aCab[11]+'</b></td>'
   _cHtml += '      <td class="itens" align="center" width="'+ALLTRIM(STRZERO(_aSizes[12],3))+'%"><b>'+_aCab[12]+'</b></td>'
   _cHtml += '      <td class="itens" align="center" width="'+ALLTRIM(STRZERO(_aSizes[13],3))+'%"><b>'+_aCab[13]+'</b></td>'
   _cHtml += '    </tr>'
   _cHtml += '    #LISTA#'
   _cHtml += '</table>'
   
   _cGetLista := ""
   _nTot:=nConta:=0
   _nTot:=LEN(_aDados)
   _cTot:=ALLTRIM(STR(_nTot))

   For _nCont := 1 To Len(_aDados)
   
   	If oProc <> Nil
          nConta++
   	   oProc:cCaption := ('Montando e-mail: '+ALLTRIM(STR(nConta))+" de "+_cTot )
   	   ProcessMessages()
   	EndIf
   
   	IF !_aDados[_nCont][01]
   	   LOOP
   	ENDIF
   
   	_cGetLista += '    <tr>'
   	_cGetLista += '      <td class="itens" align="center" width="'+ALLTRIM(STRZERO(_aSizes[02],3))+'%">'+ _aDados[_nCont][02] +'</td>' 
   	_cGetLista += '      <td class="itens" align="left"   width="'+ALLTRIM(STRZERO(_aSizes[03],3))+'%">'+ _aDados[_nCont][03] +'</td>' 
   	_cGetLista += '      <td class="itens" align="left"   width="'+ALLTRIM(STRZERO(_aSizes[04],3))+'%">'+ _aDados[_nCont][04] +'</td>'
   	_cGetLista += '      <td class="itens" align="left"   width="'+ALLTRIM(STRZERO(_aSizes[05],3))+'%">'+ _aDados[_nCont][05] +'</td>'
   	_cGetLista += '      <td class="itens" align="left"   width="'+ALLTRIM(STRZERO(_aSizes[06],3))+'%">'+ _aDados[_nCont][06] +'</td>'
   	_cGetLista += '      <td class="itens" align="right"  width="'+ALLTRIM(STRZERO(_aSizes[07],3))+'%">'+ TRANS(VAL(_aDados[_nCont][07]),"@E 999,999,999,999.9999") +'</td>'
   	_cGetLista += '      <td class="itens" align="right"  width="'+ALLTRIM(STRZERO(_aSizes[08],3))+'%">'+ TRANS(VAL(_aDados[_nCont][08]),"@E 999,999,999,999.9999") +'</td>' 
   	_cGetLista += '      <td class="itens" align="right"  width="'+ALLTRIM(STRZERO(_aSizes[09],3))+'%">'+ TRANS(    _aDados[_nCont][09] ,"@R 99/9999 ") +'</td>' 
   	_cGetLista += '      <td class="itens" align="right"  width="'+ALLTRIM(STRZERO(_aSizes[10],3))+'%">'+ TRANS(VAL(_aDados[_nCont][10]),"@E 999,999,999,999.99999999") +'</td>' 
   	_cGetLista += '      <td class="itens" align="right"  width="'+ALLTRIM(STRZERO(_aSizes[11],3))+'%">'+ TRANS(VAL(_aDados[_nCont][11]),"@E 999,999,999,999.99999999") +'</td>' 
   	_cGetLista += '      <td class="itens" align="right"  width="'+ALLTRIM(STRZERO(_aSizes[12],3))+'%">'+ TRANS(VAL(_aDados[_nCont][12]),"@E 999,999,999,999.99") +'</td>' 
   	_cGetLista += '      <td class="itens" align="right"  width="'+ALLTRIM(STRZERO(_aSizes[13],3))+'%">'+ TRANS(VAL(_aDados[_nCont][13]),"@E 999,999,999,999.99") +'</td>' 
   	_cGetLista += '    </tr>'			
   Next
   
   _cHtml := STRTRAN(_cHtml,"#LISTA#",_cGetLista)

EndIf


_cHtml += '</center>'
_cHtml += '<br>'
_cHtml += '<br>'
_cHtml += '    <tr>'
_cHtml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
_cHtml += '      <td class="itens" align="left" > ['+ GETENVSERVER() +'] / <b>Fonte:</b> [AEST013]</td>'
_cHtml += '    </tr>'
_cHtml += '</body>'
_cHtml += '</html>'

_cEmlLog := ''
//    ITEnvMail(cFrom     ,cEmailTo ,cEmailCo,cEmailBcc,cAssunto ,cMensagem,cAttach   ,cAccount    ,cPassword   ,cServer      ,cPortCon    ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro)
U_ITENVMAIL( _aConfig[01] , _cEmail ,        ,         ,_cAssunto, _cHtml  ,         ,_aConfig[01],_aConfig[02], _aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

IF !Empty( _cEmlLog )
    MessageBox( _cEmlLog+CHR(13)+CHR(10)+" E-mails: "+_cEmail , 'Envio do WF por e-mail' , 64 )
EndIF


Return .T.

