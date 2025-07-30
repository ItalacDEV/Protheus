/*
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
   Autor      |    Data    |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 23/02/2023 | Chamado 43076. Ajustes no Cadastro de Assistente Adm Comercial responsável.
Alex Wallauer | 20/03/2023 | Chamado 42203. Ajustes no Cadastro de Gerente Filiais de Troca NF X Itens.
=============================================================================================================================== 

=========================================================================================================================================================
Analista         - Programador       - Inicio     - Envio      - Chamado - Motivo da Alteração
---------------------------------------------------------------------------------------------------------------------------------------------------------
Jerry Santiago   -  Igor Melgaço     - 05/09/2024 - 27/09/2024 - 48088   - Ajustes para validações de registros na inclusão e alteração.
=========================================================================================================================================================

*/
#INCLUDE 'PROTHEUS.CH'
/*
===============================================================================================================================
Programa----------: AOMS134
Autor-------------: Alex Wallauer
Data da Criacao---: 02/01/2023
===============================================================================================================================
Descrição---------: Rotina de manutenção do cadastro de Gerente X Filiais de Troca NF X Itens. Chamado 42203.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum 
===============================================================================================================================
*/  
User Function AOMS134()
Local aSM0 := FwLoadSM0() , nFilial
PRIVATE _cTitulo := "Cadastro de Gerente X Filiais de Troca NF X Itens."

_aDadosF := {}
_aDadosC := {}

 _cFilSalva:= cFilAnt
For nFilial := 1 To Len(aSM0)
   cFilAnt  := LEFT(aSM0[nFilial][SM0_CODFIL],2)
   If Alltrim(U_ITGETMV( "IT_PRONF" , "N")) == "S" 
  	   AADD(_aDadosC, cFilAnt+"-"+aSM0[nFilial][SM0_NOMRED] )
   ENDIF
   If Alltrim(U_ITGETMV( "IT_FATNF" , "N")) == "S" 
  	   AADD(_aDadosF, cFilAnt+"-"+aSM0[nFilial][SM0_NOMRED] )
   ENDIF	
Next 
cFilAnt := _cFilSalva

_aItalac_F3:={}//       1            2         3            4        5        6                         7         8          9             10        11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1   ,_cTabel,_nCpoChave, _nCpoDesc,_bCondTab, _cTitAux                , _nTamChv, _aDados , _nMaxSel    , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"M->ZPE_FILCAR",       ,          ,          ,         ,"Filiais de Carregamento",2        ,_aDadosC ,Len(_aDadosC)  })
AADD(_aItalac_F3,{"M->ZPE_FILFAT",       ,          ,          ,         ,"Filiais de Faturamento" ,2        ,_aDadosF ,Len(_aDadosF)  })
AADD(_aItalac_F3,{"M->ZPE_OPERAC","ZB4"  ,          ,          ,         ,"Tipo de Operacao"       ,2} )

DBSELECTAREA( "ZPE" )
Private cCadastro	:= _cTitulo
Private aRotina	:= MenuDef()
mBrowse(,,,,"ZPE" ,,,,,, U_AOMS134L() ) 

Return Nil       

/*
===============================================================================================================================
Programa----------: AOMS134L
Autor-------------: Alex Wallauer
Data da Criacao---: 02/01/2023
===============================================================================================================================
Descrição---------: Definição da legenda da tela principal - Bloqueio de Regras
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS134L( nReg )

Local uRetorno	:= .T.
Local aLegenda  := 	{ 	{ "BR_VERDE"  	, "Desbloqueio"	} ,;
                        { "BR_VERMELHO"	, "Bloqueio"	}  }

//===========================================================================
// Chamada direta da funcao, via menu Recno eh passado
//===========================================================================
If	nReg == Nil

	uRetorno := {}
	
	Aadd( uRetorno , { 'ZPE->ZPE_MSBLQL <> "1" '	, aLegenda[1][1] } )//BR_VERDE
	Aadd( uRetorno , { 'ZPE->ZPE_MSBLQL == "1" '	, aLegenda[2][1] } )//BR_VERMELHO

Else
	BrwLegenda(cCadastro, "Legenda",aLegenda)
EndIf

Return( uRetorno )
/*
===============================================================================================================================
Programa----------: AOMS134V
Autor-------------: Alex Wallauer
Data da Criacao---: 02/01/2023
===============================================================================================================================
Descrição---------: Validacao dos campos dos cadastros DO ZPE (AOMS134) , ZPF (AOMS135)  E ZPG (AOMS136)
===============================================================================================================================
Parametros--------: _cCampo := Nome do campo ou botao
===============================================================================================================================
Retorno-----------: .T. ou .F.
===============================================================================================================================
*/  
User Function AOMS134V(_cCampo)

Local _lRet := .T.   , F
DEFAULT _cCampo:=SUBSTR(READVAR(),4)

Begin Sequence


///////////////////    ZPE  //////////////////////////////////  Cadastro de Gerente x Coordenador x Vendedor x Filiais de Troca NF.
   IF _cCampo == "ZPE_GERCOD" 
      
      IF !EMPTY(M->ZPE_GERCOD) .AND. (_lRet:=ExistCpo("SA3",M->ZPE_GERCOD))
         IF SA3->(DbSeek(xFilial("SA3")+M->ZPE_GERCOD)) .AND. SA3->A3_I_TIPV <> 'G'
            U_ITMSG("Esse codigo não e de Gerente.",'Atencao!',;
		   	        "Digite um codigo cujo tipo é G ",1)         
            _lRet := .F.
         ENDIF
      ENDIF

   ELSEIF _cCampo == "ZPE_ADQUIR" 

      IF !EMPTY(M->ZPE_ADQUIR) 
         _lRet:=ExistCpo("SA1",M->ZPE_ADQUIR)
      ELSE
         M->ZPE_ADQLOJ:=SPACE(LEN(ZPE->ZPE_ADQUIR))
         M->ZPE_ADQDES:=SPACE(LEN(SA1->A1_NREDUZ))
      ENDIF

   ELSEIF _cCampo == "ZPE_ADQLOJ" 

      IF !EMPTY(M->ZPE_ADQUIR) 
         _lRet:=ExistCpo("SA1",M->ZPE_ADQUIR+M->ZPE_ADQLOJ)
      ENDIF

   ElseIf _cCampo == "OKZPE"

         If !Obrigatorio(aGets,aTela)
            RETURN .F.
         ENDIF
         IF Inclui
            DbSelectArea("ZPE")
            //ZPE_FILIAL+ZPE_GERCOD+ZPE_ESTADO+ZPE_OPERAC+ZPE_ADQUIR+ZPE_ADQLOJ+ZPE_FILCAR+ZPE_FILFAT => CHAVE UNICA
            _lRet :=ExistChav("ZPE",M->ZPE_FILIAL+M->ZPE_GERCOD+M->ZPE_ESTADO+M->ZPE_OPERAC+M->ZPE_ADQUIR+M->ZPE_ADQLOJ+M->ZPE_FILCAR+M->ZPE_FILFAT,3)
         ENDIF

   ElseIf _cCampo == "ZPE_FILCAR" //FILIAL DE CARREGAMENTO

         _aFilial := STRTOKARR(ALLTRIM(M->ZPE_FILCAR), ';')

         _cFilSalva:= cFilAnt
         FOR F := 1 TO LEN(_aFilial)
             cFilAnt   := _aFilial[F]
             If Alltrim(U_ITGETMV( "IT_PRONF" , "N")) == "N" //Testa a Filial atual se pode ser troca nota
	             U_ITMSG("Filial: "+cFilAnt+" não é troca nota de carregamento. ",'Atencao!',;
			    		       "Verifique o Parametro: IT_PRONF",1)
                _lRet := .F.
             ENDIF
         NEXT
         cFilAnt := _cFilSalva

   ElseIf _cCampo == "ZPE_FILFAT" 

         _aFilial := STRTOKARR(ALLTRIM(M->ZPE_FILFAT), ';')

         _cFilSalva:= cFilAnt
         FOR F := 1 TO LEN(_aFilial)
             cFilAnt   := _aFilial[F]
             If Alltrim(U_ITGETMV( "IT_FATNF" , "N")) == "N" //Testa a filial de Faturamento
	             U_ITMSG("Filial: "+cFilAnt+" não é troca nota de Faturamento. ",'Atencao!',;
					        "Verifique o Parametro: IT_FATNF",1)
                _lRet := .F.
             ENDIF
         NEXT
         cFilAnt := _cFilSalva

///////////////////    ZPF  ////////////////////////////////// Cadastro de Produto x Filiais de Faturamento.
   
   //ElseIf _cCampo == "ZPF_PROCOD"
//
   //      IF (_lRet :=ExistCpo("SB1",M->ZPF_PROCOD)) .AND. Inclui //Tem que existir no SB1
   //          _lRet :=ExistChav("ZPF",M->ZPF_PROCOD)//Não pode existir no ZPF
   //      ENDIF

///////////////////    ZPG  //////////////////////////////////  Cadastro de Assistente x Gerente x Coord x Sup. x Vend.
   ELSEIf _cCampo == "ZPG_ASSCOD" 

      ZZL->(DbSetOrder(1))
      IF !EMPTY(M->ZPG_ASSCOD) .AND. !ZZL->(DbSeek(xFilial("ZZL")+M->ZPG_ASSCOD))   
         U_ITMSG("Essa Filial + Matricula não esta cadastrada (ZZL).",'Atencao!',;
			        "Digite uma Filial + Matricula cadastrada (ZZL).",1)         
         _lRet := .F.
      ENDIF

   ELSEIf _cCampo == "ZPG_REDCOD" 

      ACY->(DbSetOrder(1))
      IF !EMPTY(M->ZPG_REDCOD) .AND. !ACY->(DbSeek(xFilial("ACY")+M->ZPG_REDCOD))   
         U_ITMSG("Esse codigo de Rede não esta cadastrado (ACY).",'Atencao!',;
			        "Digite um codigo de Rede cadastrado (ACY).",1)         
         _lRet := .F.
      ENDIF

   ELSEIf _cCampo == "ZPG_VENCOD" 

      IF !EMPTY(M->ZPG_VENCOD) .AND. (_lRet :=ExistCpo("SA3",M->ZPG_VENCOD))
         IF SA3->(DbSeek(xFilial("SA3")+M->ZPG_VENCOD)) .AND. SA3->A3_I_TIPV <> 'V'
            U_ITMSG("Esse codigo não e de Vendedor: "+M->ZPG_VENCOD,'Atencao!',;
		   	        'Digite um codigo cujo tipo é "V" ',1)         
            _lRet := .F.
         ENDIF
      ENDIF

   ElseIf _cCampo == "ZPG_SUPCOD"
      IF !EMPTY(M->ZPG_SUPCOD) .AND. (_lRet :=ExistCpo("SA3",M->ZPG_SUPCOD))
         IF SA3->(DbSeek(xFilial("SA3")+M->ZPG_SUPCOD)) .AND. SA3->A3_I_TIPV <> 'S'
            U_ITMSG("Esse codigo não e de Supervisor: "+M->ZPG_SUPCOD,'Atencao!',;
			           'Digite um codigo cujo tipo é "S" ',1)         
            _lRet := .F.
         ENDIF
      ENDIF

   ElseIf _cCampo == "ZPG_COOCOD"
      IF !EMPTY(M->ZPG_COOCOD) .AND. (_lRet :=ExistCpo("SA3",M->ZPG_COOCOD))
         IF SA3->(DbSeek(xFilial("SA3")+M->ZPG_COOCOD)) .AND. SA3->A3_I_TIPV <> 'C'
            U_ITMSG("Esse codigo não e de Coordenador: "+M->ZPG_COOCOD,'Atencao!',;
			           'Digite um codigo cujo tipo é "C" ',1)         
            _lRet := .F.
         ENDIF
      ENDIF

   ElseIf _cCampo == "ZPG_GERCOD" 
      
      IF !EMPTY(M->ZPG_GERCOD) .AND. (_lRet:=ExistCpo("SA3",M->ZPG_GERCOD)) 
         IF SA3->(DbSeek(xFilial("SA3")+M->ZPG_GERCOD)) .AND. SA3->A3_I_TIPV <> 'G'
            U_ITMSG("Esse codigo não e de Gerente: "+M->ZPG_GERCOD,'Atencao!',;
			           'Digite um codigo cujo tipo é "G" ',1)         
            _lRet := .F.
         ENDIF
      ENDIF

      IF _lRet .AND. Inclui //ZPG_FILIAL+ZPG_REDCOD+ZPG_VENCOD+ZPG_SUPCOD+ZPG_COOCOD+ZPG_GERCOD+ZPG_ASSCOD
         _lRet :=ExistChav("ZPG",M->ZPG_REDCOD+M->ZPG_VENCOD+M->ZPG_SUPCOD+M->ZPG_COOCOD+M->ZPG_GERCOD+M->ZPG_ASSCOD,7)
      ENDIF

   EndIf
   
End Sequence

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
Local aRotina:={{ "Pesquisar"	, "AxPesqui" 		, 0 , 1 } ,;//1
					 { "Visualizar", "U_AOM134Manut" , 0 , 2 } ,;//2
					 { "Incluir"	, "U_AOM134Manut" , 0 , 3 } ,;//3
					 { "Alterar"	, "U_AOM134Manut"	, 0 , 4 } ,;//4
					 { "Excluir"	, "U_AOM134Manut" , 0 , 5 } ,;//5
					 { "Copiar"		, "U_AOM134Manut" , 0 , 3 } ,;//6
                { "Legenda"	, "U_AOMS134L"    , 0 , 0 }  }//7
Return( aRotina )

/*
===============================================================================================================================
Programa----------: AOM134Manut
Autor-------------: Alex Wallauer
Data da Criacao---: 23/02/2023
===============================================================================================================================
Descricao---------: MANUTENCAO dos cadastros do ZPE (AOMS134) , ZPF (AOMS135)
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: .T.
======================================================================= ========================================================*/
User Function AOM134Manut(cAlias,nReg,_nOpc)
Local aPosObj   := {}  , nInc
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Local aButtons  := {}
Local aCpos	    := NIL
Local aAcho     := NIL
Local cSeek     := ""
Local cWhile    := ""
Local bCond     := {|| .T. } // Se bCond .T. executa bAction1, senao executa bAction2
Local bAction1  := {|| .T. } // Retornar .T. para considerar o registro e .F. para desconsiderar
Local bAction2  := {|| .F. } // Retornar .T. para considerar o registro e .F. para desconsiderar
Local aYesFields:= {"ZPF_PROCOD","ZPF_GRUPO","ZPF_DESCRI","ZPF_MSBLQL"} //Lista todos os campos para o grid de inclusão

Private aTela[0][0],aGets[0]

//Cria variaveis M->????? da Enchoice
//RegToMemory( "ZPE", (_nOpc=3) )
For nInc := 1 To ZPE->(FCount())
    IF _nOpc = 3
       M->&(ZPE->(FieldName(nInc))) := CriaVar(ZPE->(FieldName(nInc)))
    ELSE
       M->&(ZPE->(FieldName(nInc))) := ZPE->(FieldGet(nInc))
    ENDIF
Next 

//Cria aHeader e aCols da GetDados
aHeader := {}
aCols   := {}

DbSelectArea("ZPF")//ITENS
IF _nOpc = 3 
 //FillGetDados(  nOpc ,cAlias>, nOrder,cSeekKey,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty, aHeaderAux, aColsAux, bAfterCols, bBeforeCols,bAfterHeader, cAliasQry, bCriaVar, lUserFields, aYesUsado] )
	FillGetDados( _nOpc , "ZPF" , 1     ,        ,          ,        ,         ,aYesFields,.T.     ,      ,         ,.T.   ,,,,,, )
ELSE
   cSeek  := xFilial("ZPF")+ZPE->ZPE_CODIGO//SEEK COM O CAMPO DA CAPA
   cWhile := "ZPF_FILIAL+ZPF_CODIGO"//WHILE COM OS CAMPOS DOS ITENS
   FillGetDados( _nOpc ,"ZPF",1,cSeek,{|| &cWhile },{{bCond,bAction1,bAction2}},/*aNoFields*/,aYesFields,.T.,/*cQuery*/,/*bMontCols*/,/*Inclui*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bBeforeCols*/)
ENDIF

IF _nOpc = 6//COPIA
   _nOpc = 3
ENDIF

IF _nOpc = 3  .OR. _nOpc = 4
   AADD(aButtons,{,{|| FWMSGRUN( ,{|| U_AMO134Bot("PRO")                     },"Pesquisando..","Aguarde..." ) },"","Inclui PRODUTOS"  })
   AADD(aButtons,{,{|| FWMSGRUN( ,{|| U_AMO134Bot("GRU")                     },"Pesquisando..","Aguarde..." ) },"","Inclui GRUPOS"    })
   AADD(aButtons,{,{|| FWMSGRUN( ,{|| U_AMO134Bot("PES",oGetD,1,"Produto ",1)},"Pesquisando..","Aguarde..." ) },"","PESQUISAR Produto"})
   AADD(aButtons,{,{|| FWMSGRUN( ,{|| U_AMO134Bot("PES",oGetD,2,"Grupo "  ,2)},"Pesquisando..","Aguarde..." ) },"","PESQUISAR Grupo"  })
ENDIF

aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 200, 200, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)
DO WHILE .T.

   _lGrava:=.F.
   DEFINE MSDIALOG oDlg1 TITLE cCadastro From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
   
     DbSelectArea("ZPE")
     EnChoice("ZPE", nReg, _nOpc, , , , aAcho,aPosObj[1], aCpos, 3, , , , , , .F.)
     
     DbSelectArea("ZPF")
     //       MsGetDados():New(05          , 05         , 145        , 195        ,  4  , "U_LINHAOK"   , "U_TUDOOK"    , "+A1_COD",.T., {"A1_NOME"},   , .F., 200      , "U_FIELDOK"   , "U_SUPERDEL", , "U_DELOK", oDlg)
     oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],_nOpc,"AllWaysTrue()","AllWaysTrue()",          ,.T., Nil        ,   ,    ,99999)
   
   ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| _lGrava:=.T.,IF(U_AOMS134V("OKZPE"),oDlg1:End(),_lGrava:=.F.) },{|| oDlg1:End(),_lGrava:=.F. },,aButtons)
   
   IF _lGrava .AND. _nOpc <> 2
      FWMSGRUN( ,{|oProc| _lGrava:=AMO134Grv(_nOpc,oProc) },"Gravando..","Aguarde..." )   
      IF !_lGrava
         LOOP
      ENDIF
   ElseIf _nOpc == 3 .or. _nOpc == 6
   	RollBackSX8()
   ENDIF
   EXIT
ENDDO

RETURN .T.

/*
===============================================================================================================================
Programa----------: AMO134Grv
Autor-------------: Alex Wallauer
Data da Criacao---: 23/02/2023
===============================================================================================================================
Descricao---------: Funcoes dos botoes 
===============================================================================================================================
Parametros--------: _nOpc,oProc
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================*/
STATIC Function AMO134Grv(_nOpc,oProc)
LOCAL  Z ; lRetorno:=.T.
LOCAL nConta:=0
LOCAL _cTot:=ALLTRIM(STR(Len(aCols)))

ZPE->(DBSETORDER(1))//ZPE_FILIAL+ZPE_CODIGO
ZPF->(DBSETORDER(1))//ZPF_FILIAL+ZPF_CODIGO+ZPF_PROCOD+ZPF_GRUPO

BEGIN SEQUENCE
BEGIN TRANSACTION 

If (_nOpc = 3 .OR. _nOpc = 4 .OR. _nOpc = 6) // Inclusão ou Alteracao ou Copia


  For Z := 1 To Len(aCols)
      
      nConta++
	   oProc:cCaption := ("Gravando linha: "+STRZERO(nConta,5) +" de "+ _cTot )

		If !aTail( aCols[Z] )//NÃO DELETADOS
			    
         IF !EMPTY(aCols[Z][1]+aCols[Z][2]) 
         
            IF !ZPF->(DBSEEK(xFilial("ZPF")+M->ZPE_CODIGO+aCols[Z][1]+aCols[Z][2] ))//INCLUIDOS
	            ZPF->(RecLock("ZPF",.T.))
               ZPF->ZPF_FILIAL:=xFilial("ZPF")
               ZPF->ZPF_CODIGO:=M->ZPE_CODIGO
               ZPF->ZPF_PROCOD:=aCols[Z][1]
               ZPF->ZPF_GRUPO :=aCols[Z][2]
               ZPF->ZPF_DESCRI:=aCols[Z][3]
               ZPF->ZPF_MSBLQL:=aCols[Z][4]
            ELSE//ALTERADOS
	            ZPF->(RecLock("ZPF",.F.))
               ZPF->ZPF_MSBLQL:=aCols[Z][4]
            ENDIF
			   ZPF->(MsUnLock())
         
         ENDIF
		
      ELSE // DELETADOS
         
         IF ZPF->(DBSEEK(xFilial("ZPF")+M->ZPE_CODIGO+aCols[Z][1]+aCols[Z][2] ))
	         ZPF->(RecLock( "ZPF" , .F. ) )
            ZPF->(DBDELETE())
			   ZPF->(MsUnLock())
         ENDIF

		EndIf

	Next Z

   IF !ZPF->(DBSEEK(xFilial("ZPF")+ M->ZPE_CODIGO ))
       DisarmTransaction()
       lRetorno:=.F.
       U_ITMSG("A regra esta sem itens ou grupos.",'Atenção!',"Cadastre pelo meno um item ou grupo.",3) 
       BREAK
   ENDIF

   IF ZPE->(DBSEEK(xFilial("ZPE")+M->ZPE_CODIGO))
	   ZPE->( RecLock( "ZPE" , .F. ) )
   ELSE
	   ZPE->( RecLock( "ZPE" , .T. ) )
      ZPE->ZPE_FILIAL  := xFilial("ZPE")
   ENDIF
   AVREPLACE("M","ZPE")
   ZPE->( MsUnlock() )
	
	If _nOpc = 3
		ConfirmSx8()
	EndIf


ElseIf (_nOpc == 5 ) // Exclusão
	
	For Z := 1 To Len(aCols)

      nConta++
	   oProc:cCaption := ("Excluindo linha: "+STRZERO(nConta,5) +" de "+ _cTot )
	
      IF ZPF->(DBSEEK(xFilial("ZPF")+ZPE->ZPE_CODIGO+aCols[Z][1]+aCols[Z][2] ))
	      ZPF->(RecLock( "ZPF" , .F. ) )
         ZPF->(DBDELETE())
      ENDIF

	Next

   //IF ZPE->(DBSEEK(xFilial("ZPE")+ZPE->ZPE_CODIGO))
	   ZPE->(RecLock("ZPE" , .F. ) )
      ZPE->(DBDELETE())
   //ENDIF

Endif

END TRANSACTION
END SEQUENCE

RETURN lRetorno

/*
===============================================================================================================================
Programa----------: AMO134Bot
Autor-------------: Alex Wallauer
Data da Criacao---: 23/02/2023
===============================================================================================================================
Descricao---------: Funcoes dos botoes 
===============================================================================================================================
Parametros--------: _cBotao,oMsMGet,nCol,cTit,_nMaxSel
===============================================================================================================================
Retorno-----------: .T.
======================================================================= ========================================================*/
User Function AMO134Bot(_cBotao,oMsMGet,nCol,cTit,_nMaxSel)
Local _oGet1		:= Nil
Local _oDlg			:= Nil
Local _cGet1		:= Space(15)
Local _nOpca		:= 0
Local nPos			:= 0
Local _lAchou		:= .F.
LOCAL P , _cSelect , _cTitAux
STATIC _cCodigo:=""
STATIC _cProds :=SPACE(500)
STATIC _cGrupos:=SPACE(500)

IF _cBotao = "PRO"

   _cSelect:="SELECT B1_COD , B1_DESC FROM "+RETSQLNAME("SB1")+" SB1 WHERE D_E_L_E_T_ <> '*' AND B1_MSBLQL <> '1' AND B1_TIPO = 'PA'  ORDER BY B1_COD "
   _cTitAux:="CADASTRO DE PRODUTOS (TIPO = PA)"
   IF _nMaxSel = 1
      _cProdsAux:=SPACE( LEN(SB1->B1_COD) )
   ELSE
      _cProdsAux:=_cProds+";"//_cProdsAux Somente para o READERVAR DA U_ITF3GEN() não dar erro
   ENDIF
   IF EMPTY(_cCodigo) .OR. _cCodigo <> M->ZPE_CODIGO
      _cCodigo:=M->ZPE_CODIGO
      _cProds :=SPACE(500)
   ENDIF
   //               1           2       3                        4                                      5       6         7                 8          9         10           11        12        13       14
   //   ITF3GEN(_cNomeSXB , _cTabela,_nCpoChave            , _nCpoDesc                            , _bCondTab,_cTitAux, _nTamChv       , _aDados , _nMaxSel , _lFilAtual , _cMVRET , _bValida , _oProc , _aParam )
   IF U_ITF3GEN('F3_GENER',_cSelect ,{|Tab| (Tab)->B1_COD },{|Tab| STRTRAN((Tab)->B1_DESC,"-","")},          ,_cTitAux,LEN(SB1->B1_COD),         , _nMaxSel ,.F.         ,"_cProdsAux",  )
      _cProds:=_cRetorno//Variavel _cRetorno é publica criada dentro da U_ITF3GEN()
      _aProds:= StrTokArr2(_cProds,";",.T.)
      IF LEN(aCols) = 1 .AND. EMPTY(aCols[1,1]+aCols[1,2])
         aCols:={}
      ENDIF
      FOR P := 1 TO LEN(_aProds) 
         IF (LEN(aCols) = 0 .OR. ASCAN(aCols, { |C| C[1] == _aProds[P] }) = 0) .AND. !EMPTY( _aProds[P] )
            //          ZPF_PROCOD,ZPF_GRUPO,ZPF_DESCRI                                                                      ,ZPF_MSBLQL,Alias,RECNO WT    ,Deletado?
			   AADD(aCols,{_aProds[P],SPACE(LEN(ZPF->ZPF_GRUPO)),ALLTRIM(POSICIONE('SB1',1,xFilial('SB1')+_aProds[P],'B1_DESC')),"2"       ,'ZPF',LEN(aCols)+1,.F.      })      
         ENDIF
      NEXT
   
   ENDIF

ELSEIF _cBotao = "GRU"

   _cSelect:="SELECT BM_GRUPO , BM_DESC FROM "+RETSQLNAME("SBM")+" SBM WHERE D_E_L_E_T_ <> '*' ORDER BY BM_GRUPO "
   IF _nMaxSel = 1
      _cGrupsAux:=SPACE( LEN(SBM->BM_GRUPO) )
   ELSE
      _cGrupsAux:=_cGrupos+";"//_cGrupsAux Somente para o READVAR DA U_ITF3GEN() não dar erro
   ENDIF
   _cTitAux:="CADASTRO DE GRUPOS DE PRODUTOS"
   IF EMPTY(_cCodigo) .AND. _cCodigo <> M->ZPE_CODIGO
      _cCodigo:=M->ZPE_CODIGO
      _cGrupos:=SPACE(500)
   ENDIF
   //               1           2         3                         4                                      5       6         7                    8          9         10           11           12        13       14
   //   ITF3GEN(_cNomeSXB , _cTabela  ,_nCpoChave              , _nCpoDesc                            , _bCondTab,_cTitAux, _nTamChv         , _aDados , _nMaxSel , _lFilAtual , _cMVRET    , _bValida , _oProc , _aParam )
   IF U_ITF3GEN('F3_GENER',_cSelect   ,{|Tab| (Tab)->BM_GRUPO },{|Tab| STRTRAN((Tab)->BM_DESC,"-","")},          ,_cTitAux,LEN(SBM->BM_GRUPO),         , _nMaxSel ,.F.         ,"_cGrupsAux",  )
      _cGrupos:=_cRetorno//Variavel _cRetorno é pulica criada dentro da U_ITF3GEN
      _aGrupos:= StrTokArr2(_cGrupos,";",.T.)
      IF LEN(aCols) = 1 .AND. EMPTY(aCols[1,1]+aCols[1,2])
         aCols:={}
      ENDIF
      FOR P := 1 TO LEN(_aGrupos) 
         IF (LEN(aCols) = 0 .OR. ASCAN(aCols, { |C| C[2] == _aGrupos[P] }) = 0) .AND. !EMPTY( _aGrupos[P] )
            //          ZPF_PROCOD                 ,ZPF_GRUPO  ,ZPF_DESCRI                                                      ,ZPF_MSBLQL,Alias,RECNO WT    ,Deletado?
			   AADD(aCols,{SPACE(LEN(ZPF->ZPF_PROCOD)),_aGrupos[P],ALLTRIM(POSICIONE('SBM',1,xFilial('SBM')+_aGrupos[P],'BM_DESC')),"2"       ,'ZPF',LEN(aCols)+1,.F.      })      
         ENDIF
      NEXT
   
   ENDIF

ELSEIF _cBotao = "PES"

   IF LEN(aCols) = 1 .AND. EMPTY(aCols[1,1]+aCols[1,2])
      RETURN .F.
   ENDIF

   IF oMsMGet <> NIL
      N:=oMsMGet:oBrowse:nAt
      C:=oMsMGet:oBrowse:nColPos
      aColsAux:=aCols//oMsMGet:oBrowse:aArray
   ELSE
      RETURN .F.
   ENDIF
   
   DEFINE MSDIALOG _oDlg TITLE "Pesquisar" FROM 178,181 TO 259,697 PIXEL 
   
	@003,030 Button "Consulta "+cTit	Size 070,012 PIXEL OF _oDlg Action(FWMSGRUN( ,{|| _cGet1:=U_AMO134Bot(IF(nCol=1,"PRO","GRU"),,,,1 )},"Pesquisando..","Aguarde..." ))

   @005,003 SAY cTit+" :" Size 213,010 PIXEL OF _oDlg
   @020,003 MsGet _oGet1 Var _cGet1				Size 212,009 PIXEL OF _oDlg COLOR CLR_BLACK Picture "@!" //F3 IF(nCol=1,"","")
   
   DEFINE SBUTTON FROM 004,227 TYPE 1 ENABLE ACTION ( _nOpca := 1 , _oDlg:End() ) OF _oDlg
   DEFINE SBUTTON FROM 021,227 TYPE 2 ENABLE ACTION ( _nOpca := 0 , _oDlg:End() ) OF _oDlg
   
   ACTIVATE MSDIALOG _oDlg CENTERED
   
   If _nOpca == 1
   
      _cGet1 := ALLTRIM( _cGet1 )
   	  
   	If (nPos := ASCAN(aColsAux,{|P| ALLTRIM(P[nCol]) == _cGet1 }) ) <> 0 
   	   oMsMGet:oBrowse:nAt:= N :=nPos//oMsMGet:oBrowse:Goposition()//oMsMGet:Goto(ngo)
   	   _lAchou:= .T.
   	EndIf	  	
   				
   ELSE
      RETURN .F.
   EndIf
   
   If _lAchou
      oMsMGet:Refresh()
      //oMsMGet:SetFocus()
      U_ITMSG(cTit+_cGet1+" esta no Recno WT: "+ALLTRIM(STR(aColsAux[nPos,LEN(aColsAux[1])-1])),'Atenção!',,2) 
   ELSE
      U_ITMSG("Numero não encontrado nesta lista.",'Atenção!',"Tente outro codigo",3) 
   EndIf

   RETURN .T.

ENDIF

RETURN _cRetorno
