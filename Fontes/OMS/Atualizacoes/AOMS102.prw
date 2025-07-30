/*
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
       Autor      |    Data    |                              Motivo                                                          |
-------------------------------------------------------------------------------------------------------------------------------
=============================================================================================================================== 
*/
#Include 'Protheus.ch'
/*
===============================================================================================================================
Programa----------: AOMS102
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 20/04/2017
===============================================================================================================================
Descrição---------: Rotina de manutenção no cadastro de Regras de Bloqueio de Geração de PV - Chamado: 19585
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/  
User Function AOMS102()

aRotina := {{ OemToAnsi("Pesquisar")  , "AxPesqui"   , 0 , 1 },; 
            { OemToAnsi("Visualizar") , 'AxVisual'   , 0 , 2 },; 
            { OemToAnsi("Incluir")    , 'U_AOMS102I' , 0 , 3 },; 
            { OemToAnsi("Alterar")    , 'U_AOMS102A' , 0 , 4 },; 
            { OemToAnsi("Excluir")    , 'AxDeleta'   , 0 , 5 } } 

cCadastro := OemToAnsi( "Cadastro de Regras de Bloqueio de Geração de PV" )

MBrowse( ,,,, "ZBP" )

Return .T.

/*
===============================================================================================================================
Programa----------: AOMS102I
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 20/04/2017
===============================================================================================================================
Descrição---------: Chama AxInclui()  com a validação "U_AOMS102V()"
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: AxInclui()
===============================================================================================================================
*/  
User Function AOMS102I(cAlias,nReg,nOpc) 
RETURN AxInclui(cAlias,nReg,nOpc,,,,"U_AOMS102V()")

/*
===============================================================================================================================
Programa----------: AOMS102C
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 20/04/2017
===============================================================================================================================
Descrição---------: Chama AxAltera() com a validação "U_AOMS102V()"
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: AxAltera()
===============================================================================================================================
*/  
User Function AOMS102A(cAlias,nReg,nOpc) 
RETURN AxAltera(cAlias,nReg,nOpc,,,,,"U_AOMS102V()")

/*
===============================================================================================================================
Programa----------: AOMS102V
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 20/04/2017
===============================================================================================================================
Descrição---------: Validar a digitação dos dados no Cadastro
===============================================================================================================================
Parametros--------: NIL
===============================================================================================================================
Retorno-----------: True ou False
===============================================================================================================================
*/  
User Function AOMS102V()
Local _lRet := .T.   
Local _cChaveAtual:= ZBP->ZBP_FILIAL+ZBP->ZBP_OPERAC+ZBP->ZBP_ESTADO+ZBP->ZBP_CODMUN+ZBP->ZBP_TIPCLI+ZBP->ZBP_CLIENT+ZBP->ZBP_CLILOJ+ZBP->ZBP_GRUPO+ZBP->ZBP_NCM+ZBP->ZBP_PRODUT
Local _nRecAtual  := ZBP->(RECNO())

IF EMPTY(M->ZBP_OPERAC+M->ZBP_ESTADO+M->ZBP_CODMUN+M->ZBP_TIPCLI+M->ZBP_CLIENT+M->ZBP_GRUPO+M->ZBP_NCM+M->ZBP_PRODUT )
   xmaghelpfis('Atenção! (AOMS102-'+ALLTRIM(STR(ProcLine()))+')',"Regra de bloqueio não preenchida.","Preencha pelo um dos Campos: Estado, Municipio, Tipo do Cliente, Código do Cliente, Grupo, NCM ou Produto.")
   RETURN .F.
ENDIF   

ZBP->(DBSETORDER(1))
IF Inclui .OR. _cChaveAtual # xFilial()+M->ZBP_OPERAC+M->ZBP_ESTADO+M->ZBP_CODMUN+M->ZBP_TIPCLI+M->ZBP_CLIENT+M->ZBP_CLILOJ+M->ZBP_GRUPO+M->ZBP_NCM+M->ZBP_PRODUT//Esse teste é por causa da alteração para não acha ele mesmo caso o usuario não tenha alterado nada
   IF ZBP->(DBSEEK( xFilial()+M->ZBP_OPERAC+M->ZBP_ESTADO+M->ZBP_CODMUN+M->ZBP_TIPCLI+M->ZBP_CLIENT+M->ZBP_CLILOJ+M->ZBP_GRUPO+M->ZBP_NCM+M->ZBP_PRODUT ))
      xmaghelpfis('Atenção! (AOMS102-'+ALLTRIM(STR(ProcLine()))+')',"Regra de bloqueio já cadastrada.","Preencha ou apague mais um campo para diferenciar da regra atual.")
      ZBP->(DBGOTO(_nRecAtual))//Por causa da alteração
      RETURN .F.
   ENDIF   
ENDIF   
ZBP->(DBGOTO(_nRecAtual))//Por causa da alteração

SA1->(DBSETORDER(1))
//Estado -> Municipio -> Tipo de Cliente 
IF !EMPTY(M->ZBP_CLIENT) .AND. !EMPTY(M->ZBP_CLILOJ) .AND.  SA1->(DBSEEK( xFilial("SA1")+M->ZBP_CLIENT+M->ZBP_CLILOJ ))
 
   _cEstado   :=SA1->A1_EST
   _cMunicipio:=SA1->A1_COD_MUN
   _cTpCliente:=SA1->A1_TIPO

   IF !EMPTY(M->ZBP_ESTADO) .AND. M->ZBP_ESTADO # _cEstado
      xmaghelpfis('Atenção! (AOMS102-'+ALLTRIM(STR(ProcLine()))+')',"Estado difere do cadastro do cliente: "+_cEstado,"Apague o campo do estado ou do cliente + loja")
      RETURN .F.
   ENDIF

   IF !EMPTY(M->ZBP_CODMUN) .AND. M->ZBP_CODMUN # _cMunicipio 
      xmaghelpfis('Atenção! (AOMS102-'+ALLTRIM(STR(ProcLine()))+')',"Municipio difere do cadastro do cliente: "+_cMunicipio,"Apague o campo do Municipio ou do cliente + loja")
      RETURN .F.
   ENDIF

   CC2->(DBSETORDER(1))
   IF !EMPTY(M->ZBP_ESTADO) .AND. !EMPTY(M->ZBP_CODMUN) .AND. !CC2->(DBSEEK( xFilial("CC2")+M->ZBP_ESTADO+M->ZBP_CODMUN ))
      xmaghelpfis('Atenção! (AOMS102-'+ALLTRIM(STR(ProcLine()))+')',"Municipio não pertence a esse estado.","Apague o campo do Municipio ou estado")
      RETURN .F.
   ENDIF

   IF !EMPTY(M->ZBP_TIPCLI) .AND. M->ZBP_TIPCLI # _cTpCliente
      xmaghelpfis('Atenção! (AOMS102-'+ALLTRIM(STR(ProcLine()))+')',"Tipo do cliente difere do cadastro do cliente: "+_cTpCliente,"Apague o campo do Tipo do cliente ou do cliente + loja")
      RETURN .F.
   ENDIF
ELSEIF EMPTY(M->ZBP_CLIENT) .AND. !EMPTY(M->ZBP_CLILOJ)

   xmaghelpfis('Atenção! (AOMS102-'+ALLTRIM(STR(ProcLine()))+')',"Loja do cliente preenchida sem o codigo do cliente.","Apague a loja do cliente.")
   RETURN .F.

ENDIF

SB1->(DBSETORDER(1))
//Grupo de Produto -> NCM
IF !EMPTY(M->ZBP_PRODUT) .AND. SB1->(DBSEEK( xFilial("SB1")+M->ZBP_PRODUT ))

   _cGrupo:=SB1->B1_GRUPO
   _cNCM  :=SB1->B1_POSIPI

   IF !EMPTY(M->ZBP_GRUPO) .AND. M->ZBP_GRUPO # _cGrupo
      xmaghelpfis('Atenção! (AOMS102-'+ALLTRIM(STR(ProcLine()))+')',"Grupo difere do cadastro do produto: "+_cGrupo,"Apague o campo do grupo ou do produto")
      RETURN .F.
   ENDIF

   IF !EMPTY(M->ZBP_NCM)   .AND. M->ZBP_NCM   # _cNCM
      xmaghelpfis('Atenção! (AOMS102-'+ALLTRIM(STR(ProcLine()))+')',"NCM difere do cadastro do produto: "+_cNCM,"Apague o campo do NCM ou do produto")
      RETURN .F.
   ENDIF

ENDIF

IF !EMPTY(M->ZBP_ESTADO) .AND. !EMPTY(M->ZBP_CODMUN) .AND. !ExistCpo("CC2",M->ZBP_ESTADO+M->ZBP_CODMUN)
   RETURN .F.
ENDIF

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS102G
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 20/04/2017
===============================================================================================================================
Descrição---------: Gatilhos chamados do campo X3_VLDUSER
===============================================================================================================================
Parametros--------: NIL
===============================================================================================================================
Retorno-----------: True ou False
===============================================================================================================================
*/  
User Function AOMS102G(nCampo)//U_AOMS102G()

IF nCampo = 1
   
   IF EMPTY(M->ZBP_ESTADO) .AND. !EMPTY(M->ZBP_CODMUN)
      xmaghelpfis('Atenção! (AOMS102-'+ALLTRIM(STR(ProcLine()))+')',"Estado não preenchido.","Para preencher o municipio dever ser preencher o estado.")
      RETURN .F.
   ENDIF
   IF !EMPTY(M->ZBP_ESTADO) .AND. !EMPTY(M->ZBP_CODMUN) .AND. ExistCpo("CC2",M->ZBP_ESTADO+M->ZBP_CODMUN)
      M->ZBP_DESMUN:=POSICIONE("CC2",1,XFILIAL("CC2")+M->ZBP_ESTADO+M->ZBP_CODMUN,"CC2_MUN")
   ELSE
      M->ZBP_DESMUN:=" "
   ENDIF

ELSEIF nCampo = 2

   M->ZBP_DESCLI:=POSICIONE("SA1",1,XFILIAL("SA1")+M->ZBP_CLIENT+ALLTRIM(M->ZBP_CLILOJ),"A1_NREDUZ")

ELSEIF nCampo = 3

   M->ZBP_DESGRU:=POSICIONE("SBM",1,XFILIAL("SBM")+M->ZBP_GRUPO,"BM_DESC")

ELSEIF nCampo = 4

   M->ZBP_DESPRO:=POSICIONE("SB1",1,XFILIAL("SB1")+M->ZBP_PRODUT,"B1_DESC")

ENDIF

RETURN .T.
