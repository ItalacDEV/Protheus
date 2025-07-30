/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
===============================================================================================================================
    Autor      |    Data    |                                             Motivo                                            
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 17/07/2023 | Chamado 44281. Ajuste de tamanho na selecao do F3 dos produtos.
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melga�o  | 24/07/2023 | Chamado 44281. Ajuste para grava��o de log e janela de multipla altera��o de pre�o.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"

Static oBmpVerde    := LoadBitmap( GetResources(), "BR_VERDE")
Static oBmpVermelho := LoadBitmap( GetResources(), "BR_VERMELHO")

/* 
===============================================================================================================================
Programa----------: MOMS067
Autor-------------: Igor Melga�o
Data da Criacao---: 28/06/2022
===============================================================================================================================
Descricao---------: Rotina nova para Ativa��o, Inativa��o e altera��o de vig�ncia de Tabela de pre�o - Chamado 40336 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS067()
Local _aParRet := {}
Local _aParAux := {} , nI
Local _bOK     := {|| Iif(Subs(MV_PAR01,1,1) $  "346",Iif(Empty(Alltrim(MV_PAR02)),(MsgAlert("Preencha o Produto!", "Aten��o"),.F.),.T.),.T.)  } //IF(MV_PAR02 >= MV_PAR01,.T.,(U_ITMSG("Periodo INVALIDO",'Aten��o!',"Tente novamente com outro periodo",3),.F.) ) }

MV_PAR01 := Space(100)
MV_PAR02 := Space(1500)

_cSelectSB1 := "SELECT B1_COD , B1_TIPO, B1_DESC FROM "+RETSQLNAME("SB1")+" SB1 WHERE D_E_L_E_T_ <> '*' AND B1_MSBLQL <> '1'  AND B1_TIPO = 'PA' ORDER BY B1_COD "
_aItalac_F3 := {} //       1           2         3                      4                      5               6                    7         8          9         10         11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela ,_nCpoChave              , _nCpoDesc              ,_bCondTab    , _cTitAux         , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR02" ,_cSelectSB1,{|Tab|(Tab)->B1_COD},{|Tab|(Tab)->B1_TIPO+" "+(Tab)->B1_DESC}, ,"Produtos"        ,          ,          ,100       ,.F.        ,       , } )
_cValCC := ' Iif(Subs(MV_PAR01,1,1) <>  "1" .AND. Subs(MV_PAR01,1,1) <>  "2" .AND. Subs(MV_PAR01,1,1) <>  "5",.T.,(MV_PAR02 := Space(1500),.F.)) '

AADD( _aParAux , { 2 , "Altera��o", MV_PAR01, {"1 - Ativar Tabela","2 - Desativar Tabela","3 - Ativar Produto","4 - Desativar Produto","5 - Alterar Vigencia","6 - Alterar Preco"}, 100 ,'.T.',.T.,".T."}) 
AADD( _aParAux , { 1 , "Produtos" , MV_PAR02, "@!"   , ""  ,"F3ITLC", _cValCC , 100 , .F. } ) 


For nI := 1 To Len( _aParAux )
	aAdd( _aParRet , _aParAux[nI][03] )
Next nI

If !ParamBox( _aParAux , "Alteracao de Tabela de preco de Produtos" , @_aParRet, _bOK )
   Return
EndIf

FWMSGRUN(,{|oproc|  MOMS067Proc(oproc) },'Aguarde processamento...','Lendo dados...')

Return

/*
===============================================================================================================================
Programa----------: MOMS067Proc
Autor-------------: Igor Melga�o
Data da Criacao---: 30/06/22
===============================================================================================================================
Descricao---------: Processa a leitura e altera��o da tabela de pre�o
===============================================================================================================================
Parametros--------: oproc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function MOMS067Proc(oproc)
Local _lRet    := .F.
Local _cQry		:= ""
Local _ntot    := 0
Local _npos    := 1
Local _cAlias  := GetNextAlias()
Local _nOpca   := 1
Local _oSaySol
Local _oGetSol
Local _cGetSol := Ctod("")
Local _oDlg
Local _oSBtOk
Local _oSBtCan

DEFAULT oproc  := NIL

oproc:cCaption := ("Lendo Tabelas de Pre�o...")
ProcessMessages()

If Subs(MV_PAR01,1,1) == "3" .Or. Subs(MV_PAR01,1,1) == "4" 

   _cQry := "SELECT DA0_FILIAL, DA0_CODTAB, DA0_DESCRI, DA0_DATDE, DA0_HORADE, DA0_DATATE, DA0_HORATE, DA1_ATIVO, DA1_DATVIG, DA1_CODPRO, DA1_I_MIX, DA0.R_E_C_N_O_ RECNODA0, DA1.R_E_C_N_O_ RECNODA1, DA1_I_PRF1, DA1_I_PMF1, DA1_I_PRF2, DA1_I_PMF2, DA1_I_PRF3, DA1_I_PMF3  "
   _cQry += " FROM " + RetSqlName("DA0") + " DA0 JOIN " + RetSqlName("DA1") + " DA1 ON DA0.DA0_FILIAL = DA1.DA1_FILIAL AND DA0.DA0_CODTAB = DA1.DA1_CODTAB  "
   _cQry += " WHERE DA0.D_E_L_E_T_ = ' ' "
   _cQry += "   AND DA1.D_E_L_E_T_ = ' ' "
   _cQry += "   AND DA0.DA0_FILIAL = '"+xFilial("DA0")+"' "

   If !Empty(Alltrim(MV_PAR02))
      _cQry += "   AND DA1_CODPRO IN " + FormatIn(MV_PAR02,";")  // PRODUTO 
   EndIf

   If Subs(MV_PAR01,1,1) == "3"
      _cQry += "   AND DA1.DA1_ATIVO <> '1' "
   ElseIf Subs(MV_PAR01,1,1) == "4"
      _cQry += "   AND DA1.DA1_ATIVO = '1' "
   EndIf

   _cQry += "   AND DA0.DA0_ATIVO = '1' "

   _cQry += " ORDER BY DA1.DA1_CODPRO, DA0.DA0_FILIAL, DA0.DA0_CODTAB "

Else

   _cQry := "SELECT DA0_FILIAL, DA0_CODTAB, DA0_DESCRI, DA0_DATDE, DA0_HORADE, DA0_DATATE, DA0_HORATE, DA0_ATIVO, DA0.R_E_C_N_O_ RECNODA0 "
   
   If !Empty(Alltrim(MV_PAR02))
      _cQry += " FROM " + RetSqlName("DA0") + " DA0 JOIN " + RetSqlName("DA1") + " DA1 ON DA0.DA0_FILIAL = DA1.DA1_FILIAL AND DA0.DA0_CODTAB = DA1.DA1_CODTAB AND DA1.D_E_L_E_T_ = ' ' "
   Else
      _cQry += " FROM " + RetSqlName("DA0") + " DA0 "
   EndIf

   _cQry += " WHERE DA0.D_E_L_E_T_ = ' ' "
   _cQry += "   AND DA0.DA0_FILIAL = '" + xFilial("DA0") + "' "

   If Subs(MV_PAR01,1,1) == "1"
      _cQry += "   AND DA0.DA0_ATIVO <> '1' "
   ElseIf Subs(MV_PAR01,1,1) == "2" .OR. Subs(MV_PAR01,1,1) == "6" .OR. Subs(MV_PAR01,1,1) == "5"
      _cQry += "   AND DA0.DA0_ATIVO = '1' "
   EndIf

   If !Empty(Alltrim(MV_PAR02))
      _cQry += "   AND DA1_CODPRO IN " + FormatIn(MV_PAR02,";")  // PRODUTO 
   EndIf

   If !Empty(Alltrim(MV_PAR02))
      _cQry += " GROUP BY DA0_FILIAL, DA0_CODTAB, DA0_DESCRI, DA0_DATDE, DA0_HORADE, DA0_DATATE, DA0_HORATE, DA0_ATIVO, DA0.R_E_C_N_O_ "
   EndIf

   _cQry += " ORDER BY DA0.DA0_CODTAB "

EndIf

DBUSEAREA( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , _cAlias , .T., .F. )

COUNT TO _ntot

_aDados := {}

(_cAlias)->(dbGoTop())

DO WHILE !(_cAlias)->(EOF())
	
   oproc:cCaption := ("Lendo Registro " + STRZERO(_npos,9) + " de " + STRZERO(_ntot,9))
   ProcessMessages()
   _npos++
   
   If Subs(MV_PAR01,1,1) == "3" .Or. Subs(MV_PAR01,1,1) == "4" 

      AADD(_aDados,{ .F.,;
            (_cAlias)->DA0_CODTAB,;
            (_cAlias)->DA0_DESCRI,;
            DTOC(STOD((_cAlias)->DA0_DATDE)),;
            (_cAlias)->DA0_HORADE,;
            DTOC(STOD((_cAlias)->DA0_DATATE)),;
            (_cAlias)->DA0_HORATE,;
            (_cAlias)->DA1_CODPRO,;
            Alltrim(Posicione("SB1",1,xFilial("SB1")+(_cAlias)->DA1_CODPRO,"B1_DESC")),;
            If((_cAlias)->DA1_ATIVO='1',"1-Sim","2-Nao"),;
            (_cAlias)->DA1_I_MIX,;
            DTOC(STOD((_cAlias)->DA1_DATVIG)),;
            (_cAlias)->DA1_I_PRF1,;
            (_cAlias)->DA1_I_PMF1,;
            (_cAlias)->DA1_I_PRF2,;
            (_cAlias)->DA1_I_PMF2,;
            (_cAlias)->DA1_I_PRF3,;
            (_cAlias)->DA1_I_PMF3,;
            (_cAlias)->RECNODA1,;
            (_cAlias)->RECNODA0 })

   Else

      AADD(_aDados,{ .F.,;
            (_cAlias)->DA0_CODTAB,;
            (_cAlias)->DA0_DESCRI,;
            DTOC(STOD((_cAlias)->DA0_DATDE)),;
            (_cAlias)->DA0_HORADE,;
            DTOC(STOD((_cAlias)->DA0_DATATE)),;
            (_cAlias)->DA0_HORATE,;
            If((_cAlias)->DA0_ATIVO='1',"1-Sim","2-Nao"),;
            (_cAlias)->RECNODA0 })

   EndIf

   (_cAlias)->(DBSKIP())
   
ENDDO

IF LEN(_aDados) = 0
   U_ITMSG("N�o foram encontrados dados para esses produtos ",'Aten��o!',"Tente novamente com outros produtos",3)
   _lLoop:=.T.
   RETURN .T.
ENDIF

_lLoop   := .F.

If Subs(MV_PAR01,1,1) == "3" .Or. Subs(MV_PAR01,1,1) == "4" 
   _aCabec  := {'','C�digo da Tabela','Descricao','De','Hora de','Ate','Hora Ate','Codigo do Produto','Descri��o','Ativo','Mix','Data da Vigencia','Pr Faixa 1','Pr Min Fx 1','Pr Faixa 2','Pr Min Fx 2','Pr Faixa 3','Pr Min Fx 3','Recno','Recno'}
   _aTam    := {10,40,70,30,30,30,30,50,60,40,40,50,40,40,40,40,40,40,40,40}
Else
   _aCabec  := {'','C�digo da Tabela','Descricao','De','Hora de','Ate','Hora Ate','Ativo','Recno'}
   _aTam    := {10,40,150,30,30,30,30,50,60}
EndIf

_cMsgTop := "Selecione para "+ Subs(MV_PAR01,4,Len(MV_PAR01)-3)
_lRet    := U_ITListBox( MV_PAR01 ,; //          , _aCols   ,_lMaxSiz,_nTipo,_cMsgTop , _lSelUnc ,
                        _aCabec , _aDados , .T.    , 2    , _cMsgTop ,          ,;
                        _aTam, 2       )

If _lRet

   If Subs(MV_PAR01,1,1) = "6" 
      MOMS067M(_aDados)
   Else

      If Subs(MV_PAR01,1,1) = "5"

         DEFINE MSDIALOG _oDlg TITLE "Altera��o de Vigencia " FROM 000, 000  TO 090, 500 COLORS 0, 16777215 PIXEL

         @ 005, 004 SAY _oSaySol PROMPT "Data da Vigencia:" SIZE 055, 007 OF _oDlg COLORS 0, 16777215 PIXEL
         @ 017, 003 MSGET _oGetSol VAR _cGetSol SIZE 70, 010 OF _oDlg PICTURE "@!" COLORS 0, 16777215 PIXEL

         DEFINE SBUTTON _oSBtOk  FROM 031, 185 TYPE 01 OF _oDlg ENABLE ACTION (_nOpca := 1, _oDlg:End())
         DEFINE SBUTTON _oSBtCan FROM 031, 216 TYPE 02 OF _oDlg ENABLE ACTION (_nOpca := 2, _oDlg:End())

         ACTIVATE MSDIALOG _oDlg CENTERED

         If _nOpca = 1
            oproc:cCaption := ("Gravando dados...")
            ProcessMessages()
            MOMS067GRV(_cGetSol)
         Endif

      Else
         oproc:cCaption := ("Gravando dados...")
         ProcessMessages()
         MOMS067GRV()
      EndIf

   EndIf
EndIf

Return .T.



/*
===============================================================================================================================
Programa----------: MOMS067L
Autor-------------: Igor Melga�o
Data da Criacao---: 30/06/22
===============================================================================================================================
Descricao---------: Registra o log de altera��o
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function MOMS067GRV(_cGetSol)
Local i := 0

   For i := 1 To Len(_aDados)
      If _aDados[i][1]

         Begin Transaction

            If Subs(MV_PAR01,1,1) == "1" .OR. Subs(MV_PAR01,1,1) == "2" .OR. Subs(MV_PAR01,1,1) == "5"
               
               DbSelectArea("DA0")
               DbGoTo(_aDados[i][9])

               If Subs(MV_PAR01,1,1) == "5"
                  //Grava log
                  MOMS067GL(,DA0->(Recno()),"A")
               EndIf

               DA0->(Reclock("DA0",.F.))
               If Subs(MV_PAR01,1,1) == "5"
                  DA0->DA0_DATATE := _cGetSol
               Else
                  DA0->DA0_ATIVO := Subs(MV_PAR01,1,1)
               EndIf
               DA0->(Msunlock())

               If Subs(MV_PAR01,1,1) <> "5"
                  DbSelectArea("DA1")
                  DbSetOrder(1)
                  If Dbseek(xFilial("DA1")+DA0->DA0_CODTAB)
                     Do While DA0->DA0_FILIAL+DA0->DA0_CODTAB == DA1->DA1_FILIAL+DA1->DA1_CODTAB .AND. DA1->(!EOF())
                        
                        //Grava log
                        MOMS067GL(DA1->(Recno()),DA0->(Recno()),"A")

                        DA1->(Reclock("DA1",.F.))
                        DA1->DA1_ATIVO := Subs(MV_PAR01,1,1)
                        DA1->(Msunlock())

                        DA1->(DBSkip())
                     EndDo
                  EndIf
               EndIf
            Else
               //Grava log
               MOMS067GL(_aDados[i][Iif(Subs(MV_PAR01,1,1) == "6",18,19)],_aDados[i][19],"A")

               DbSelectArea("DA1")
               DbGoTo(_aDados[i][Iif(Subs(MV_PAR01,1,1) == "6",18,19)])
               DA1->(Reclock("DA1",.F.))
               DA1->DA1_ATIVO := Iif(Subs(MV_PAR01,1,1)=="3","1","2")
               DA1->(Msunlock())

            EndIf

         End Transaction

      EndIf
   Next
RETURN .T.

/*
===============================================================================================================================
Programa----------: MOMS067K
Autor-------------: Igor Melga�o
Data da Criacao---: 30/06/22
===============================================================================================================================
Descricao---------: Processa a altera��o de pre�o na tabela DA1
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function MOMS067K(_aDados)
Local oDlg
Local _cTitulo		:= "Altera��o de Tabelas de Pre�o"
Local _aObjects 	:= {}
Local _aPosObj		:= {}
Local _aSize		:= MsAdvSize()
Local _aInfo		:= { _aSize[1] , _aSize[2] , _aSize[3] , _aSize[4] , 3 , 3 }
Local aaCampos  	 := {"PF1","PF2","PF3","PMF1","PMF2","PMF3"} //Vari�vel contendo o campo edit�vel no Grid

Private oLista                    //Declarando o objeto do browser
Private aCabecalho := {}         //Variavel que montar� o aHeader do grid
Private aColsEx 	 := {}         //Vari�vel que receber� os dados

AADD( _aObjects , { 100 , 055 , .T. , .F. , .T. })
AADD( _aObjects , { 100 , 100 , .T. , .T.       })
AADD( _aObjects , { 100 , 002 , .T. , .F.       })

_aPosObj := MsObjSize( _aInfo , _aObjects )

DEFINE MSDIALOG oDlg TITLE _cTitulo OF oMainWnd PIXEL FROM _aSize[7],0 TO _aSize[6],_aSize[5]
	
   oPanel := TPanel():New(0,0,'',oDlg,,.F.,.F.,,,300,0,.T.,.T. )

   //Chamar a fun��o que cria a estrutura do aHeader
   MOMS067CB()
   
   //Carregar os itens que ir�o compor o conteudo do grid
   MOMS067CAR(_aDados)

   //Monta o browser com inclus�o, remo��o e atualiza��o
   oGet := MsNewGetDados():New(_aPosObj[2,1]+80,_aPosObj[2,2],_aPosObj[2,3]-10,_aPosObj[2,4], GD_UPDATE /*nOpc*/  , "AllwaysTrue" , "AllwaysTrue"  , "AllwaysTrue", aACampos,0    , 999       , "AllwaysTrue", ""     ,"AllwaysTrue", oDlg        , aCabecalho, aColsEx)


   nTotCodRec := Len(aColsEx)

	//================================================================================
	// RODAPE DA TELA
	//================================================================================
   oPanelRoda := TPanel():New(_aPosObj[2,3],0,'',oDlg,, .F., .F.,,,300,20,.F.,.F. )
	@ 4,005 SAY		"Total de Tabelas Selecionadas:"  Pixel of oPanelRoda
   @ 2,090 MSGET	oTotCodRec var nTotCodRec Picture "@E 999,999.99"  WHEN .F. Pixel of oPanelRoda
	
	aButtons := IIf( Type("aButtons") == "U" , {} , aButtons )
   AAdd(aButtons,{"Altera��o Multipla",{||(MOMS067N(oGet:aCols),oGet:Refresh())},"Altera��o Multipla","Altera��o Multipla"})

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| lConfirmou := MOMS067J(oGet:aCols) ,If(lConfirmou,oDlg:End(),)},{||oDlg:End()},,aButtons),;
	                                oPanel:Align:=CONTROL_ALIGN_TOP,oPanelRoda:Align:=CONTROL_ALIGN_BOTTOM,;
	                                oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT,oGet:oBrowse:Refresh())
	

RETURN .T.


/*
===============================================================================================================================
Programa----------: MOMS067CB
Autor-------------: Igor Melga�o
Data da Criacao---: 30/06/22
===============================================================================================================================
Descricao---------: Cria o Cabe�alho para o Browse de sele��o
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS067CB()
   /*
    Aadd(aCabecalho, {;
                  "Filial",;	//X3Titulo()
                  "FILIAL",; 	//X3_CAMPO
                  "@!",;		   //X3_PICTURE
                  2,;			   //X3_TAMANHO
                  0,;			   //X3_DECIMAL
                  "",;  			//X3_VALID
                  "",;			   //X3_USADO
                  "C",;			   //X3_TIPO
                  "",;			   //X3_F3
                  "R",;			   //X3_CONTEXT
                  "",;			   //X3_CBOX
                  "",;			   //X3_RELACAO
                  ".T."})			//X3_WHEN
   */
   Aadd(aCabecalho, {;
               "",;	//X3Titulo()
               " ",; 	//X3_CAMPO
               "@BMP",;		   //X3_PICTURE
               5,;			   //X3_TAMANHO
               0,;			   //X3_DECIMAL
               "",;  			//X3_VALID
               "",;			   //X3_USADO
               "C",;			   //X3_TIPO
               "",;			   //X3_F3
               "R",;			   //X3_CONTEXT
               "",;			   //X3_CBOX
               "",;			   //X3_RELACAO
               ".T."})			//X3_WHEN    

   Aadd(aCabecalho, {;
               "Ativo?",;	//X3Titulo()
               "ATIVO",; 	//X3_CAMPO
               "",;		   //X3_PICTURE
               5,;			   //X3_TAMANHO
               0,;			   //X3_DECIMAL
               "",;  			//X3_VALID
               "",;			   //X3_USADO
               "C",;			   //X3_TIPO
               "",;			   //X3_F3
               "R",;			   //X3_CONTEXT
               "",;			   //X3_CBOX
               "",;			   //X3_RELACAO
               ".T."})			//X3_WHEN      

   Aadd(aCabecalho, {;
               "Tabela",;	//X3Titulo()
               "TABELA",; 	//X3_CAMPO
               "@!",;		   //X3_PICTURE
               5,;			   //X3_TAMANHO
               0,;			   //X3_DECIMAL
               "",;  			//X3_VALID
               "",;			   //X3_USADO
               "C",;			   //X3_TIPO
               "",;			   //X3_F3
               "R",;			   //X3_CONTEXT
               "",;			   //X3_CBOX
               "",;			   //X3_RELACAO
               ".T."})			//X3_WHEN       
   
   Aadd(aCabecalho, {;
               "Descricao",;	//X3Titulo()
               "DESC",; 	//X3_CAMPO
               "@!",;		   //X3_PICTURE
               30,;			   //X3_TAMANHO
               0,;			   //X3_DECIMAL
               "",;  			//X3_VALID
               "",;			   //X3_USADO
               "C",;			   //X3_TIPO
               "",;			   //X3_F3
               "R",;			   //X3_CONTEXT
               "",;			   //X3_CBOX
               "",;			   //X3_RELACAO
               ".T."})			//X3_WHEN

   Aadd(aCabecalho, {;
               "Produto",;	   //X3Titulo()
               "PRODUTO",; 	//X3_CAMPO
               "@!",;		   //X3_PICTURE
               15,;			   //X3_TAMANHO
               0,;			   //X3_DECIMAL
               "",;  			//X3_VALID
               "",;			   //X3_USADO
               "C",;			   //X3_TIPO
               "",;			   //X3_F3
               "R",;			   //X3_CONTEXT
               "",;			   //X3_CBOX
               "",;			   //X3_RELACAO
               ".T."})			//X3_WHEN

   Aadd(aCabecalho, {;
               "Desc.",;	   //X3Titulo()
               "DESCPRO",; 	//X3_CAMPO
               "@!",;		   //X3_PICTURE
               50,;			   //X3_TAMANHO
               0,;			   //X3_DECIMAL
               "",;  			//X3_VALID
               "",;			   //X3_USADO
               "C",;			   //X3_TIPO
               "",;			   //X3_F3
               "R",;			   //X3_CONTEXT
               "",;			   //X3_CBOX
               "",;			   //X3_RELACAO
               ".T."})			//X3_WHEN

   Aadd(aCabecalho, {;
               "Mix",;	   //X3Titulo()
               "MIX",; 	//X3_CAMPO
               "@!",;		   //X3_PICTURE
               10,;			   //X3_TAMANHO
               0,;			   //X3_DECIMAL
               "",;  			//X3_VALID
               "",;			   //X3_USADO
               "C",;			   //X3_TIPO
               "",;			   //X3_F3
               "R",;			   //X3_CONTEXT
               "",;			   //X3_CBOX
               "",;			   //X3_RELACAO
               ".T."})			//X3_WHEN

   Aadd(aCabecalho, {;
               "Pr Faixa 1",;	   //X3Titulo()
               "PF1",; 	//X3_CAMPO
               "@E 999,999.99",;		   //X3_PICTURE
               12,;			   //X3_TAMANHO
               3,;			   //X3_DECIMAL
               "",;  			//X3_VALID
               "",;			   //X3_USADO
               "N",;			   //X3_TIPO
               "",;			   //X3_F3
               "R",;			   //X3_CONTEXT
               "",;			   //X3_CBOX
               "",;			   //X3_RELACAO
               ".T."})			//X3_WHEN

   Aadd(aCabecalho, {;
               "Pr Min Fx 1",;	   //X3Titulo()
               "PMF1",; 	//X3_CAMPO
               "@E 999,999.99",;		   //X3_PICTURE
               12,;			   //X3_TAMANHO
               3,;			   //X3_DECIMAL
               "",;  			//X3_VALID
               "",;			   //X3_USADO
               "N",;			   //X3_TIPO
               "",;			   //X3_F3
               "R",;			   //X3_CONTEXT
               "",;			   //X3_CBOX
               "",;			   //X3_RELACAO
               ".T."})			//X3_WHEN


   Aadd(aCabecalho, {;
               "Pr Faixa 2",;	   //X3Titulo()
               "PF2",; 	//X3_CAMPO
               "@E 999,999.99",;		   //X3_PICTURE
               12,;			   //X3_TAMANHO
               3,;			   //X3_DECIMAL
               "",;  			//X3_VALID
               "",;			   //X3_USADO
               "N",;			   //X3_TIPO
               "",;			   //X3_F3
               "R",;			   //X3_CONTEXT
               "",;			   //X3_CBOX
               "",;			   //X3_RELACAO
               ".T."})			//X3_WHEN

   Aadd(aCabecalho, {;
               "Pr Min Fx 2",;	   //X3Titulo()
               "PMF2",; 	//X3_CAMPO
               "@E 999,999.99",;		   //X3_PICTURE
               12,;			   //X3_TAMANHO
               3,;			   //X3_DECIMAL
               "",;  			//X3_VALID
               "",;			   //X3_USADO
               "N",;			   //X3_TIPO
               "",;			   //X3_F3
               "R",;			   //X3_CONTEXT
               "",;			   //X3_CBOX
               "",;			   //X3_RELACAO
               ".T."})			//X3_WHEN

   Aadd(aCabecalho, {;
               "Pr Faixa 3",;	   //X3Titulo()
               "PF3",; 	//X3_CAMPO
               "@E 999,999.99",;		   //X3_PICTURE
               12,;			   //X3_TAMANHO
               3,;			   //X3_DECIMAL
               "",;  			//X3_VALID
               "",;			   //X3_USADO
               "N",;			   //X3_TIPO
               "",;			   //X3_F3
               "R",;			   //X3_CONTEXT
               "",;			   //X3_CBOX
               "",;			   //X3_RELACAO
               ".T."})			//X3_WHEN

   Aadd(aCabecalho, {;
                  "Pr Min Fx 3",;	   //X3Titulo()
                  "PMF3",; 	//X3_CAMPO
                  "@E 999,999.99",;		   //X3_PICTURE
                  12,;			   //X3_TAMANHO
                  3,;			   //X3_DECIMAL
                  "",;  			//X3_VALID
                  "",;			   //X3_USADO
                  "N",;			   //X3_TIPO
                  "",;			   //X3_F3
                  "R",;			   //X3_CONTEXT
                  "",;			   //X3_CBOX
                  "",;			   //X3_RELACAO
                  ".T."})			//X3_WHEN

Return

/*
===============================================================================================================================
Programa----------: MOMS067CAR
Autor-------------: Igor Melga�o
Data da Criacao---: 30/06/22
===============================================================================================================================
Descricao---------: Carrega os dados para o Browse 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS067CAR(_aDados)
Local i := 0
Local oBmp

   For i := 1 To Len(_aDados)
         oBmp := Iif(Subs(_aDados[i][10],1,1) == "2",oBmpVermelho,oBmpVerde)
         Aadd(aColsEx,{ oBmp,;
                        _aDados[i][10],; //2 - Aiivo (Sim/Nao)
                        _aDados[i][02],; //3 - Tabela
                        _aDados[i][03],; //4 - Descri��o
                        _aDados[i][08],; //5 - Produto
                        _aDados[i][09],; //6 - Descri��o
                        _aDados[i][11],; //7 - Mix
                        _aDados[i][13],; //8 - Pr Faixa 1
                        _aDados[i][14],; //9 - Pr Min Fx 1
                        _aDados[i][15],; //10 - Pr Faixa 2
                        _aDados[i][16],; //11 - Pr Min Fx 2
                        _aDados[i][17],; //12 - Pr Faixa 3
                        _aDados[i][18],; //13 - Pr Min Fx 3
                        _aDados[i][19],; //14 - 
                        _aDados[i][20],; //15 - 
                        .F.})


   Next

   //Setar array do aCols do Objeto.
   //oGet:SetArray(aColsEx,.T.)
   
   //Atualizo as informa��es no grid
   //oGet:oBrowse:Refresh()
Return

/*
===============================================================================================================================
Programa----------: MOMS067J
Autor-------------: Igor Melga�o
Data da Criacao---: 30/06/22
===============================================================================================================================
Descricao---------: Registra o log de altera��o
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS067J(aColsEx)
Local i := 0

Begin Transaction

   For i := 1 To Len(aColsEx)
      //Grava log
      MOMS067GL(aColsEx[i,14],aColsEx[i,15],"A")

      DbSelectArea("DA1")
      DbGoTo(aColsEx[i,14])
      DA1->(Reclock("DA1",.F.))
      DA1->DA1_I_PRF1 := aColsEx[i,08]
      DA1->DA1_I_PMF1 := aColsEx[i,09]
      DA1->DA1_I_PRF2 := aColsEx[i,10]
      DA1->DA1_I_PMF2 := aColsEx[i,11]
      DA1->DA1_I_PRF3 := aColsEx[i,12]
      DA1->DA1_I_PMF3 := aColsEx[i,13]
      DA1->(Msunlock())

   Next

End Transaction 

Return .T.


/*
===============================================================================================================================
Programa----------: MOMS067M
Autor-------------: Igor Melga�o
Data da Criacao---: 30/06/22
===============================================================================================================================
Descricao---------: Processa a leitura e altera��o da tabela de pre�o
===============================================================================================================================
Parametros--------: oproc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function MOMS067M(_aDados)
Local _cQry		:= ""
Local _ntot    := 0
Local _npos    := 1
Local _cAlias  := GetNextAlias()
Local _cDados  := ""
Local _aDadosPd := {}
Local i := 0

DEFAULT oproc  := NIL


//oproc:cCaption := ("Lendo Tabelas de Pre�o...")
//ProcessMessages()

For i:=1 To len(_aDados)
   If _aDados[i][1]
      _cDados += Iif(Empty(_cDados),"",";")+_aDados[i][2]
   EndIf
Next

_cQry := "SELECT DA0_FILIAL, DA0_CODTAB, DA0_DESCRI, DA0_DATDE, DA0_HORADE, DA0_DATATE, DA0_HORATE, DA1_ATIVO, DA1_DATVIG, DA1_CODPRO, DA1_I_MIX, DA0.R_E_C_N_O_ RECNODA0, DA1.R_E_C_N_O_ RECNODA1, DA1_I_PRF1, DA1_I_PMF1, DA1_I_PRF2, DA1_I_PMF2, DA1_I_PRF3, DA1_I_PMF3  "
_cQry += " FROM " + RetSqlName("DA0") + " DA0 JOIN " + RetSqlName("DA1") + " DA1 ON DA0.DA0_FILIAL = DA1.DA1_FILIAL AND DA0.DA0_CODTAB = DA1.DA1_CODTAB  "
_cQry += " WHERE DA0.D_E_L_E_T_ = ' ' "
_cQry += "   AND DA1.D_E_L_E_T_ = ' ' "
_cQry += "   AND DA0.DA0_FILIAL = '"+xFilial("DA0")+"' "

If !Empty(Alltrim(MV_PAR02))
   _cQry += "   AND DA1_CODPRO IN " + FormatIn(MV_PAR02,";")  // PRODUTO 
EndIf

_cQry += "   AND DA0_CODTAB IN " + FormatIn(_cDados,";")  // PRODUTO 

_cQry += " ORDER BY DA1.DA1_CODPRO, DA0.DA0_FILIAL, DA0.DA0_CODTAB "


 
DBUSEAREA( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , _cAlias , .T., .F. )

COUNT TO _ntot

_aDados := {}

(_cAlias)->(dbGoTop())

DO WHILE !(_cAlias)->(EOF())
	
   //oproc:cCaption := ("Lendo Tabela " + STRZERO(_npos,9) + " de " + STRZERO(_ntot,9))
   //ProcessMessages()
   _npos++
   

      AADD(_aDadosPd,{ .T.,;
            (_cAlias)->DA0_CODTAB,;
            (_cAlias)->DA0_DESCRI,;
            DTOC(STOD((_cAlias)->DA0_DATDE)),;
            (_cAlias)->DA0_HORADE,;
            DTOC(STOD((_cAlias)->DA0_DATATE)),;
            (_cAlias)->DA0_HORATE,;
            (_cAlias)->DA1_CODPRO,;
            Alltrim(Posicione("SB1",1,xFilial("SB1")+(_cAlias)->DA1_CODPRO,"B1_DESC")),;
            If((_cAlias)->DA1_ATIVO='1',"1-Sim","2-Nao"),;
            (_cAlias)->DA1_I_MIX,;
            DTOC(STOD((_cAlias)->DA1_DATVIG)),;
            (_cAlias)->DA1_I_PRF1,;//13
            (_cAlias)->DA1_I_PMF1,;
            (_cAlias)->DA1_I_PRF2,;
            (_cAlias)->DA1_I_PMF2,;
            (_cAlias)->DA1_I_PRF3,;
            (_cAlias)->DA1_I_PMF3,;
            (_cAlias)->RECNODA1,;
            (_cAlias)->RECNODA0 }) //20

   (_cAlias)->(DBSKIP())
   
ENDDO

IF LEN(_aDadosPd) = 0
   U_ITMSG("N�o foram encontrados dados para esses produtos ",'Aten��o!',"Tente novamente com outros produtos",3)
   _lLoop:=.T.
   RETURN .T.
Else

   MOMS067K(_aDadosPd)

EndIf

Return .T.



/*
===============================================================================================================================
Programa----------: MOMS067N
Autor-------------: Igor Melga�o
Data da Criacao---: 30/06/22
===============================================================================================================================
Descricao---------: Processa a altera��o Multipla
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function MOMS067N(_aDados)
Local oDlg 
Local oPrFaixa1,oPrFaixa2,oPrFaixa3
Local oPrMinF1,oPrMinF2,oPrMinF3
Local _cTitulo	 := "Altera��o M�ltipla de Tabelas de Pre�o selecionada"
Local nPrFaixa1 := 0
Local nPrFaixa2 := 0
Local nPrFaixa3 := 0
Local nPrMinF1  := 0
Local nPrMinF2  := 0
Local nPrMinF3  := 0
Local _ni       := 0
Local _lSave    := .F.
Local _cPicture := PesqPict("DA1","DA1_I_PRF1"	) //"@E 999,999,999,999.99"

DEFINE DIALOG oDlg TITLE _cTitulo FROM 1,0 TO 280,330 Pixel
	
	@ 004,010 SAY		"Pr Faixa 1"  Size 70,8 Pixel of oDlg
   @ 014,010 MSGET	oPrFaixa1 Var nPrFaixa1 Size 70,8 Picture _cPicture WHEN .T. Pixel of oDlg

	@ 004,090 SAY		"Pr Min Faixa 1"  Size 70,8 Pixel of oDlg
   @ 014,090 MSGET	oPrMinF1 Var nPrMinF1 Size 70,8 Picture _cPicture  WHEN .T. Pixel of oDlg

	@ 040,010 SAY		"Pr Faixa 2"  Size 70,8 Pixel of oDlg
   @ 050,010 MSGET	oPrFaixa2 Var nPrFaixa2 Size 70,8 Picture _cPicture  WHEN .T. Pixel of oDlg

	@ 040,090 SAY		"Pr Min Faixa 2"  Size 70,8 Pixel of oDlg
   @ 050,090 MSGET	oPrMinF2 Var nPrMinF2 Size 70,8 Picture _cPicture  WHEN .T. Pixel of oDlg

	@ 076,010 SAY		"Pr Faixa 3"  Size 70,8 Pixel of oDlg
   @ 086,010 MSGET	oPrFaixa3 Var nPrFaixa3 Size 70,8 Picture _cPicture  WHEN .T. Pixel of oDlg
     
	@ 076,090 SAY		"Pr Min Faixa 3"  Size 70,8 Pixel of oDlg
   @ 086,090 MSGET	oPrMinF3 Var nPrMinF3 Size 70,8 Picture _cPicture  WHEN .T. Pixel of oDlg

   @ 115,030 BUTTON "Confirma" SIZE 050, 015 PIXEL OF oDlg ACTION (_lSave:=.T.,oDlg:End()) 
   @ 115,090 BUTTON "Cancela"  SIZE 050, 015 PIXEL OF oDlg ACTION (_lSave:=.F.,oDlg:End()) 

Activate Dialog oDlg Centered  

If _lSave
   For _ni := 1 To Len(_aDados)
      If nPrFaixa1 <> 0
         _aDados[_ni][08] := nPrFaixa1
      EndIf
      If nPrMinF1 <> 0
         _aDados[_ni][09] := nPrMinF1
      EndIf
      If nPrFaixa2 <> 0
         _aDados[_ni][10] := nPrFaixa2
      EndIf
      If nPrMinF2 <> 0
         _aDados[_ni][11] := nPrMinF2
      EndIf
      If nPrFaixa3 <> 0
         _aDados[_ni][12] := nPrFaixa3
      EndIf
      If nPrMinF3 <> 0
         _aDados[_ni][13] := nPrMinF3
      EndIf
   Next
EndIf

RETURN .T.



/*
===============================================================================================================================
Programa----------: MOMS067GL
Autor-------------: Igor Melga�o
Data da Criacao---: 30/06/22
===============================================================================================================================
Descricao---------: Processa a altera��o Multipla
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function MOMS067GL(nRecnoDA1,nRecnoDA0,cOper)
Default nRecnoDA1 := 0
Default nRecnoDA0 := 0
Default cOper     := "A"

If nRecnoDA1 > 0
   DbSelectArea("DA1")
   DbGoTo(nRecnoDA1)
EndIf

If nRecnoDA0 > 0
   DbSelectArea("DA0")
   DbGoTo(nRecnoDA0)
EndIf

//===================================================================
// Grava log de altera��o.
//===================================================================
ZGS->(Reclock("ZGS",.T.))
ZGS->ZGS_FILIAL   := xFilial("ZGS")
ZGS->ZGS_DATA     := date()
ZGS->ZGS_HORA     := time()
ZGS->ZGS_USER     := cusername
ZGS->ZGS_MODULO   := funname()	
ZGS->ZGS_STATUS   := cOper

If nRecnoDA0 > 0
   ZGS->ZGS_CODTAB   := DA0->DA0_CODTAB
   ZGS->ZGS_DATDE 	:= DA0->DA0_DATDE
   ZGS->ZGS_HORADE	:= DA0->DA0_HORADE
   ZGS->ZGS_DATATE	:= DA0->DA0_DATATE
   ZGS->ZGS_HORATE	:= DA0->DA0_HORATE
   ZGS->ZGS_CONDPG	:= DA0->DA0_CONDPG
   ZGS->ZGS_TPHORA	:= DA0->DA0_TPHORA
   ZGS->ZGS_ATIVO 	:= DA0->DA0_ATIVO
   ZGS->ZGS_ODATDE   := DA0->DA0_DATDE
   ZGS->ZGS_OHORAD   := DA0->DA0_HORADE
   ZGS->ZGS_ODATAT   := DA0->DA0_DATATE
   ZGS->ZGS_OHORAT   := DA0->DA0_HORATE
   ZGS->ZGS_OCONDP   := DA0->DA0_CONDPG
   ZGS->ZGS_OTPHOR   := DA0->DA0_TPHORA
   ZGS->ZGS_OATIVO   := DA0->DA0_ATIVO
EndIf

If nRecnoDA1 > 0
   ZGS->ZGS_CODTAB   := DA1->DA1_CODTAB
   ZGS->ZGS_ITEM     := DA1->DA1_ITEM
   ZGS->ZGS_CODPRO	:= DA1->DA1_CODPRO
   ZGS->ZGS_GRUPO 	:= DA1->DA1_GRUPO
   ZGS->ZGS_PRCVEN	:= DA1->DA1_PRCVEN
   ZGS->ZGS_I_PRCA	:= DA1->DA1_I_PRCA
   ZGS->ZGS_PRCMAX	:= DA1->DA1_PRCMAX
   ZGS->ZGS_I_PRMP	:= DA1->DA1_I_PRMP
   ZGS->ZGS_I_PTBN	:= DA1->DA1_I_PTBN
   ZGS->ZGS_I_VIGI	:= DA1->DA1_I_VIGI
   ZGS->ZGS_I_VIGF	:= DA1->DA1_I_VIGF
   ZGS->ZGS_OCODPR   := DA1->DA1_CODPRO 
   ZGS->ZGS_OGRUPO   := DA1->DA1_GRUPO
   ZGS->ZGS_OPRCVE   := DA1->DA1_PRCVEN
   ZGS->ZGS_I_OPRC   := DA1->DA1_I_PRCA
   ZGS->ZGS_OPRCMA   := DA1->DA1_PRCMAX
   ZGS->ZGS_I_OPRM   := DA1->DA1_I_PRMP
   ZGS->ZGS_I_OPTB   := DA1->DA1_I_PTBN
   ZGS->ZGS_I_OVII   := DA1->DA1_I_VIGI
   ZGS->ZGS_I_OVIF   := DA1->DA1_I_VIGF
   ZGS->ZGS_PRF1     := DA1->DA1_I_PRF1 // "Pr Faixa 1"
   ZGS->ZGS_PMF1     := DA1->DA1_I_PMF1 // "Pr min Fx 1"
   ZGS->ZGS_PRF2     := DA1->DA1_I_PRF2 // "Pr Faixa 2"
   ZGS->ZGS_PMF2     := DA1->DA1_I_PMF2 // "Pr min Fx 2"
   ZGS->ZGS_PRF3     := DA1->DA1_I_PRF3 // "Pr Faixa 3"
   ZGS->ZGS_PMF3     := DA1->DA1_I_PMF3 // "Pr min Fx 3"
EndIf

ZGS->(Msunlock())

Return .T.
