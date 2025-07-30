/*
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
   Autor      |    Data    |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 23/02/2023 | Chamado 43076. Ajustes no Cadastro de Assistente Adm Comercial respons�vel.
Alex Wallauer | 22/03/2023 | Chamado 42203.  Troca da funcao de AOM134Inclui para AOM135Inclui
=============================================================================================================================== 

=========================================================================================================================================================
Analista         - Programador       - Inicio     - Envio      - Chamado - Motivo da Altera��o
---------------------------------------------------------------------------------------------------------------------------------------------------------
Jerry Santiago   -  Igor Melga�o     - 05/09/2024 - 27/09/2024 - 48088   - Ajustes para valida��es de registros na inclus�o e altera��o.
=========================================================================================================================================================
*/
#INCLUDE 'PROTHEUS.CH'

/*
===============================================================================================================================
Programa----------: AOMS135
Autor-------------: Alex Wallauer
Data da Criacao---: 13/01/2023
===============================================================================================================================
Descri��o---------: Rotina de manuten��o do Cadastro de Assistente Adm Comercial Respons�vel Chamado 42054.
===============================================================================================================================
Parametros--------: Nenhum 
===============================================================================================================================
Retorno-----------: Nenhum 
===============================================================================================================================
*/  
User Function AOMS135()
Local _cTitulo := "Cadastro de Assistente Adm Comercial Respons�vel"
Local _aDadosR:={}

ACY->( DBSETORDER(1) )
ACY->( DBGOTOP() )
DO WHILE ACY->(!EOF()) 
	AADD( _aDadosR , ACY->ACY_GRPVEN+"-"+ALLTRIM( ACY->ACY_DESCRI ) )
   ACY->( DBSkip() )
ENDDO

_cSelecZZL:="SELECT  ZZL_MATRIC , ZZL_NOME FROM "+RETSQLNAME("ZZL")+" ZZL WHERE D_E_L_E_T_ <> '*' AND ZZL_PEDPOR  = 'S' ORDER BY ZZL_MATRIC " 

_aItalac_F3:={}
//  (_aItalac_F3,{"1CPO_CAMPO1"  ,_cTabela  ,_nCpoChave                , _nCpoDesc              ,_bCondTab, _cTitAux     , _nTamChv           , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"M->ZPG_ASSCOD",_cSelecZZL,{|Tab| (Tab)->ZZL_MATRIC }, {|Tab| (Tab)->ZZL_NOME},         ,"Assistentes" ,LEN(ZPG->ZPG_ASSCOD),          , 1        } )

//AD(_aItalac_F3,{"1CPO_CAMPO1   ,_cTabel,_nCpoChave, _nCpoDesc,_bCondTab, _cTitAux , _nTamChv           , _aDados , _nMaxSel, _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"M->ZPG_REDCOD",       ,          ,          ,         ,"Redes"   ,LEN(ACY->ACY_GRPVEN),_aDadosR ,1        })

//AxCadastro("ZPG",_cTitulo, "U_DelOk()", "U_COK()"            , aRotAdic, bPre, bOK, bTTS, bNoTTS,aAuto,nOpcAuto,aButtons,aACS,cTela)
//AxCadastro("ZPG",_cTitulo,            , "U_AOMS135V('OKZPG')",         ,     ,    , )

Private cCadastro	:= _cTitulo
Private aRotina	:= MenuDef()
mBrowse(,,,,"ZPG")

Return Nil       

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Alex Wallauer
Data da Criacao---: 23/02/2023
===============================================================================================================================
Descri��o---------: Utilizacao de Menu Funcional
===============================================================================================================================
Parametros--------: aRotina
					1. Nome a aparecer no cabecalho
					2. Nome da Rotina associada
					3. Reservado
					4. Tipo de Transa��o a ser efetuada:
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

Local aRotina:={{ "Pesquisar"	, "AxPesqui" 	  , 0 , 1 } ,;
				{ "Visualizar"	, "AxVisual" 	  , 0 , 2 } ,;
				{ "Incluir"		, "U_AOM135Inclui", 0 , 3 } ,;
				{ "Alterar"		, "U_AOM135Altera" 	  , 0 , 4 } ,;
				{ "Excluir"		, "AxDeleta"	  , 0 , 5 }  }


Return( aRotina )
/*
===============================================================================================================================
Programa----------: U_AOM135Inclui
Autor-------------: Alex Wallauer
Data da Criacao---: 23/02/2023
===============================================================================================================================
Descricao---------: Manuten��o do ZE0
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================*/
User Function AOM135Inclui(cAlias,nReg,nOpc)

IF nOpc = 3
   Return AxInclui(cAlias,nReg,nOpc,;
       /*aAcho>     */ ,;
       /*cFunc>     */ ,;
       /*aCpos>     */ ,;
       /*cTudoOk>   */ "U_AOMS135V()",;
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
Programa----------: BuscaAssistente
Autor-------------: Alex Wallauer
Data da Criacao---: 23/02/2023
===============================================================================================================================
Descri��o---------: Busca o/a Assistente do Pedido no Cadastro de Assistente Adm Comercial Respons�vel.
===============================================================================================================================
Parametros--------: _cRede - C�digo da Rede        (SA1->A1_GRPVEN)
------------------: _cVend - C�digo do Vendedor    (SC5->C5_VEND1)
------------------: _cSupe - C�digo do Supervisor  (SC5->C5_VEND4)
------------------: _cCoor - C�digo do Coordenador (SC5->C5_VEND2)
------------------: _cGere - C�digo do Gerente     (SC5->C5_VEND3)
===============================================================================================================================
Retorno-----------: Nenhum 
===============================================================================================================================
*/  
User Function BuscaAssistente(_cRede,_cVend,_cSupe,_cCoor,_cGere)
LOCAL _aOrdBusca  :={} , A
LOCAL _aAssistente:={"",""}
LOCAL _cRedB:=SPACE(LEN(ZPG->ZPG_REDCOD))
LOCAL _cVenB:=SPACE(LEN(ZPG->ZPG_VENCOD))
LOCAL _cSupB:=SPACE(LEN(ZPG->ZPG_SUPCOD))
LOCAL _cCooB:=SPACE(LEN(ZPG->ZPG_COOCOD))
LOCAL _cGerB:=SPACE(LEN(ZPG->ZPG_GERCOD))
//Busca com REDE
AADD(_aOrdBusca,_cRede+_cVend+_cSupe+_cCoor+_cGere)// ORDEM 01
AADD(_aOrdBusca,_cRede+_cVenB+_cSupe+_cCoor+_cGere)// ORDEM 02
AADD(_aOrdBusca,_cRede+_cVenB+_cSupB+_cCoor+_cGere)// ORDEM 03
AADD(_aOrdBusca,_cRede+_cVenB+_cSupB+_cCooB+_cGere)// ORDEM 04
AADD(_aOrdBusca,_cRede+_cVenB+_cSupB+_cCooB+_cGerB)// ORDEM 05
//Busca sem REDE
AADD(_aOrdBusca,_cRedB+_cVend+_cSupe+_cCoor+_cGere)// ORDEM 06
AADD(_aOrdBusca,_cRedB+_cVenB+_cSupe+_cCoor+_cGere)// ORDEM 07
AADD(_aOrdBusca,_cRedB+_cVenB+_cSupB+_cCoor+_cGere)// ORDEM 08
AADD(_aOrdBusca,_cRedB+_cVenB+_cSupB+_cCooB+_cGere)// ORDEM 09 

ZPG->(DBSETORDER(8))//ZPG_FILIAL+ZPG_REDCOD+ZPG_VENCOD+ZPG_SUPCOD+ZPG_COOCOD+ZPG_GERCOD+ZPG_ASSCOD
FOR A := 1 TO LEN(_aOrdBusca)
   IF ZPG->(DBSEEK( xFilial()+_aOrdBusca[A]+"2" )) 
       _aAssistente[1] := ZPG->ZPG_ASSCOD
       _aAssistente[2] := ZPG->ZPG_ASSNOM//POSICIONE('ZZL',1,xFilial('ZZL')+ZPG->ZPG_ASSCOD,'ZZL_NOME') 
       EXIT
   ENDIF
NEXT
ZPG->(DBSETORDER(1))

RETURN _aAssistente


/*
===============================================================================================================================
Programa----------: U_AOM135Inclui
Autor-------------: Alex Wallauer
Data da Criacao---: 23/02/2023
===============================================================================================================================
Descricao---------: Manuten��o do ZE0
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================*/
User Function AOM135Altera(cAlias,nReg,nOpc)

IF nOpc = 4

          //AxAltera(cAlias,nReg,nOpc,/*aAcho*/,/*aCpos*/,/*nColMens*/,/*cMensagem*/,/*cTudoOk*/,/*cTransact*/,/*cFunc*/,/*aButtons*/,/*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/)
   Return AxAltera(cAlias,nReg,nOpc,         ,         ,            ,             ,"U_AOMS135V()",,)

ENDIF

Return .t.


/*
===============================================================================================================================
Programa----------: AOM135V
Autor-------------: Igor Melga�o
Data da Criacao---: 27/09/2024
===============================================================================================================================
Descricao---------: Valida��o no OK final da rotina
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================*/
User Function AOMS135V()
Local aAreaZPG := {}
Local nRecnoZPG := 0
Local _lRet := .T.

Begin Sequence

   If (Inclui .OR. Altera)
   
      IF EMPTY(M->ZPG_REDCOD+M->ZPG_VENCOD+M->ZPG_SUPCOD+M->ZPG_COOCOD+M->ZPG_GERCOD)
         U_ITMSG("N�o � possivel gravar somente o Assistente.",'Atencao!',;
		           'Preencha pelo menos mais um campo chave para o pedido poder encontrar o Assistente.',1)         
         _lRet := .F.
      ENDIF

      IF _lRet

         aAreaZPG := Getarea("ZPG")
         nRecnoZPG := Iif(Inclui,0,ZPG->(Recno()))
         
         //Verifico se h� registro na chave 
         Dbselectarea("ZPG")
         Dbsetorder(7)
         If Dbseek(xFilial("ZPG")+M->ZPG_REDCOD+M->ZPG_VENCOD+M->ZPG_SUPCOD+M->ZPG_COOCOD+M->ZPG_GERCOD+M->ZPG_ASSCOD) 
            If Inclui .OR. ZPG->(Recno()) <> nRecnoZPG
               If Inclui 
                  _lRet := .F.
               ElseIf Altera
                  If ZPG->(Recno()) <> nRecnoZPG
                     _lRet := .F.
                  EndIf  
               EndIf
               If !_lRet
                  U_ITMSG("N�o � possivel concluir a opera��o pois h� outro registro ativo para chave digitada (Rede + Vendedor + Supervisor + Coordenador + Gerente + Assistente)!",'Atencao!',;
                     'Preencha uma chave diferente para concluir a opera��o.',1)     
               EndIf
            EndIf
         EndIf

         If _lRet .AND. M->ZPG_MSBLQL == "2"
            //Verifico se h� registro ativo para estrutura sem o Assistente pois s� pode haver um
            Dbselectarea("ZPG")
            Dbsetorder(8)
            If Dbseek(xFilial("ZPG")+M->ZPG_REDCOD+M->ZPG_VENCOD+M->ZPG_SUPCOD+M->ZPG_COOCOD+M->ZPG_GERCOD+"2") 
               If Inclui 
                  _lRet := .F.
               ElseIf Altera
                  If ZPG->(Recno()) <> nRecnoZPG
                     _lRet := .F.
                  EndIf  
               EndIf

               If !_lRet
                  U_ITMSG("N�o � possivel concluir a opera��o pois h� outro registro ativo para chave digitada (Rede + Vendedor + Supervisor + Coordenador + Gerente)!",'Atencao!',;
                     'Bloqueie o registro ativo dessa chave anteriormente e inclua ou preencha uma chave diferente para concluir a opera��o.',1)         
               EndIf

            EndIf
         EndIf
         RestArea(aAreaZPG)
      ENDIF

   EndIf
   
End Sequence

Return _lRet
