/*
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
   Autor     |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 14/08/24 | Chamado 48138. Vanderlei. Corre��o ortografica da palarva Embarque na variavel cCadastro.
-------------------------------------------------------------------------------------------------------------------------------
Igor Melga�o | 29/08/24 | Chamado 48362. Vanderlei. Reestrutura��o dos c�digos do cadastro de locais de embarque.
=============================================================================================================================== 
*/
#INCLUDE 'PROTHEUS.CH'

/*
===============================================================================================================================
Programa----------: AOMS136
Autor-------------: Alex Wallauer
Data da Criacao---: 22/05/2023
===============================================================================================================================
Descri��o---------: Rotina de manuten��o do Cadastro de local de Embarque . Chamado 43864.
===============================================================================================================================
Parametros--------: Nenhum 
===============================================================================================================================
Retorno-----------: Nenhum 
===============================================================================================================================
*/  
User Function AOMS136()
Private aTela[0][0],aGets[0]
Private cCadastro	:= "Cadastro de local de Embarque"
Private aRotina	:= MenuDef()

mBrowse(,,,,"ZEL")

Return Nil       

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Alex Wallauer
Data da Criacao---: 22/05/2023
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

Local aRotina:={{ "Pesquisar" , "AxPesqui"      , 0 , 1 } ,;
                { "Visualizar", "AxVisual"      , 0 , 2 } ,;
                { "Incluir"   , "U_AOM136Inclui", 0 , 3 } ,;
                { "Alterar"   , "AxAltera"      , 0 , 4 } ,;
                { "Excluir"   , "AxDeleta"      , 0 , 5 }  }


Return( aRotina )
/*
===============================================================================================================================
Programa----------: U_AOM136Inclui
Autor-------------: Alex Wallauer
Data da Criacao---: 22/05/2023
===============================================================================================================================
Descricao---------: Manuten��o do ZE0
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================*/
User Function AOM136Inclui(cAlias,nReg,nOpc)

IF nOpc = 3
   Return AxInclui(cAlias,nReg,nOpc,;
       /*aAcho>     */ ,;
       /*cFunc>     */ ,;
       /*aCpos>     */ ,;
       /*cTudoOk>   */ "U_AOMS136V('OK"+cAlias+"')",;
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
Programa----------: AOMS136V
Autor-------------: Alex Wallauer
Data da Criacao---: 02/01/2023
===============================================================================================================================
Descri��o---------: Validacao dos campos dos cadastros DO ZEL
===============================================================================================================================
Parametros--------: _cCampo := Nome do campo ou botao
===============================================================================================================================
Retorno-----------: .T. ou .F.
===============================================================================================================================
*/  
User Function AOMS136V(_cCampo)

Local _lRet := .T.  // , F
DEFAULT _cCampo:=SUBSTR(READVAR(),4)

DbSelectArea("ZEL")

   IF _cCampo == "ZEL_CODIGO" 
      
      IF LEN(ALLTRIM(M->ZEL_CODIGO)) < 4 //.OR. (_lRet:=ExistChav("ZEL",M->ZEL_CODIGO,1))
         IF LEN(ALLTRIM(M->ZEL_CODIGO)) < 4
            U_ITMSG("Codigo do local de Embarque INVALIDO.",'Atencao!',;
		   	        "Digite um codigo com 4 caracteres afanumericos.",1)         
            _lRet := .F.
         ENDIF
      ENDIF

   ELSEIF _cCampo == "ZEL_DESCRI" 
      
      IF EMPTY(M->ZEL_DESCRI) .OR. (_lRet:=ExistChav("ZEL",M->ZEL_DESCRI,2))
         IF EMPTY(M->ZEL_DESCRI) 
            U_ITMSG("Descricao do local de Embarque � obrigatorio.",'Atencao!',;
		   	        "Digite um codigo que n�o exista no cadastro.",1)         
            _lRet := .F.
         ENDIF
      ENDIF

   ELSEIF _cCampo == "ZEL_FILFIS" 

      IF !EMPTY(M->ZEL_FILFIS) 
         _lRet:=ExistCpo("SM0",cEmpAnt+M->ZEL_FILFIS,1)
      ENDIF

   ELSEIF _cCampo == "ZEL_LOCAL" 

      IF !EMPTY(M->ZEL_LOCAL) 
         _lRet:=ExistCpo("NNR",M->ZEL_LOCAL)
      ENDIF

   ELSEIF _cCampo == "ZEL_OPERAD" 

      IF !EMPTY(M->ZEL_OPERAD) 
         _lRet:=ExistCpo("SA2",M->ZEL_OPERAD)
      ELSE
         M->ZEL_LOJAOP:=SPACE(LEN(ZEL->ZEL_LOJAOP))
         M->ZEL_NOMEOP:=SPACE(LEN(SA2->A2_NREDUZ))
      ENDIF

   ELSEIF _cCampo == "ZEL_LOJAOP" 

      IF !EMPTY(M->ZEL_OPERAD) 
         _lRet:=ExistCpo("SA2",M->ZEL_OPERAD+M->ZEL_LOJAOP)
      ENDIF

   ELSEIF _cCampo == "ZEL_CAPALE" 
         _lRet:=Positivo(M->ZEL_CAPALE)
   ELSEIF _cCampo == "ZEL_CAPKG" 
         _lRet:=Positivo(M->ZEL_CAPKG)
   ElseIf _cCampo == "OKZEL"

         If !Obrigatorio(aGets,aTela)
            RETURN .F.
         ENDIF
         IF Inclui                   //ZEL_FILIAL+ZEL_FILFIS+ZEL_LOCAL+ZEL_OPERAD+ZEL_LOJAOP
            _lRet :=ExistChav("ZEL",M->ZEL_FILIAL+M->ZEL_FILFIS+M->ZEL_LOCAL+M->ZEL_OPERAD+M->ZEL_LOJAOP,3)
         ENDIF

   EndIf
   
Return _lRet

/*
===============================================================================================================================
Programa----------: U_BuscaLocalEmbarque
Autor-------------: Alex Wallauer
Data da Criacao---: 22/05/2023
===============================================================================================================================
Descri��o---------: Busca o Local do Embarque do Pedido no Cadastro de Local do Embarque .
===============================================================================================================================
Parametros--------: _cFilAtual - C�digo da Filial Fiscal (cFilAnt)
------------------: _cLocal    - C�digo do Armazem       (_cLocal1oItem)
------------------: _cVend1    - C�digo do Vendedor      (M->C5_VEND1)
===============================================================================================================================
Retorno-----------: Local de Embarque 
===============================================================================================================================
*/  
User Function BuscaLocalEmbarque(_cFilAtual,_cLocal,_cVend1)

Local _cFilial    := xFilial("ZEL")
Local _lAchou     := .F.
Local _cCodLocEmb := SPACE(LEN(ZEL->ZEL_CODIGO))

DEFAULT _cFilAtual:= cFilAnt
DEFAULT _cLocal   := SPACE(LEN(ZEL->ZEL_LOCAL))
DEFAULT _cVend1   := SPACE(LEN(SC5->C5_VEND1))

ZEL->(DBSETORDER(3))//ZZEL_FILIAL+ZEL_FILFIS+ZEL_LOCAL+ZEL_OPERAD+ZEL_LOJAOP
IF _cFilAtual = "20"
   IF _cVend1 = "001622" .AND. _cLocal $ "50/52"
	   _cRegraZEL := "2) Buscou por Filial Fiscal = 20, Armazem = "+_cLocal
	   _cCodLocEmb:= "RS50"
      _lAchou:=.T.
   ENDIF
ELSEIF _cFilAtual = "40"
   IF _cLocal $ "50/52"
	   _cRegraZEL := "3) Buscou por Filial Fiscal = 40, Armazem = "+_cLocal
	   _cCodLocEmb:= "MG50"
      _lAchou:=.T.
   ENDIF
ELSEIF _cFilAtual $ "90/93"
   IF ZEL->(Dbseek(_cFilial+_cFilAtual+_cLocal+SPACE(LEN(ZEL->(ZEL_OPERAD+ZEL_LOJAOP)))))
   	_cRegraZEL := "4) Buscou por Filial Fiscal = "+_cFilAtual+", Armazem = "+_cLocal
   	_cCodLocEmb:= ZEL->ZEL_CODIGO 
      _lAchou:=.T.
   EndIf 
ENDIF
IF !_lAchou .AND. ZEL->(Dbseek(_cFilial+_cFilAtual+SPACE(LEN(ZEL->(ZEL_LOCAL+ZEL_OPERAD+ZEL_LOJAOP)))))
	_cRegraZEL := "1) Buscou por Filial Fiscal = "+_cFilAtual
	_cCodLocEmb:= ZEL->ZEL_CODIGO 
EndIf 
ZEL->(DBSETORDER(1))

RETURN _cCodLocEmb
