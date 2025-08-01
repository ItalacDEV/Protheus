/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer |25/02/2021| Chamado 35745. Novo cadastro para o novo nivel 3 de investimento
Julio Paz     |25/11/2022| Chamado 41946. Alterar rotina de investimentos para replicar alteração de datas para subníveis
Lucas Borges  |09/05/2025| Chamado 50617. Corrigir chamada estática no nome das tabelas do sistema
Lucas Borges  |23/07/2025| Chamado 51340. Ajustar função para validação de ambiente de teste
===============================================================================================================================
*/


#Include 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: ACOM003
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 20/08/2015                                    .
Descrição---------: Cadastro de Centro de Investimento.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM003()

Local cAlias:= "ZZI"
Local aCores :=	{	{"ZZI_MSBLQL = '1'", 'BR_VERMELHO' },;
							{"ZZI_TIPO = ' '", 'BR_PRETO'	 },;
							{"ZZI_TIPO = '1'", 'BR_VERDE'	 },;
							{"ZZI_TIPO = '2'", 'BR_AZUL'},;
							{"ZZI_TIPO = '3'", 'BR_AMARELO' } }
Local _aParRet :={}
Local _aParAux :={} , nI 

PRIVATE _cTipoIni:=""

ZZL->(dbSetOrder(3)) //ZZL_FILIAL + ZZL_CODUSU
If ZZL->(dbSeek(xFilial("ZZL") + __cUserId))

   Private cCadastro := "Cadastro de Centro de Investimento"
   Private aRotina	:= {}                
   Private aSubRotina:= {}                
    
	AADD(aSubRotina,{"Incluir Nivel 1","U_ACOM003I",0,3})
   AADD(aSubRotina,{"Incluir Nivel 2","U_ACOM003I",0,3})
   AADD(aSubRotina,{"Incluir Nivel 3","U_ACOM003I",0,3})
    
   AADD(aRotina,{"Pesquisar" ,"AxPesqui"  ,0,1})
   AADD(aRotina,{"Visualizar","U_ACOM03V" ,0,2})
   AADD(aRotina,{"Incluir"	  ,aSubRotina  ,0,3})
   AADD(aRotina,{"Alterar"	  ,"U_ACOM003I",0,4})
   AADD(aRotina,{"Excluir"	  ,"U_ACOM003E(.F.)",0,5})
   AADD(aRotina,{"Legenda"	  ,"U_ACOM03L",0,5})

   _aOpcoes:={}
   AADD( _aOpcoes , "1–NIVEL 1")
   AADD( _aOpcoes , "2–NIVEL 2")
   AADD( _aOpcoes , "3–NIVEL 3")
   AADD( _aOpcoes , "4–SEM FILTRO") 
   MV_PAR01:=1 

   AADD( _aParAux , { 3 , "Filtrar", MV_PAR01, _aOpcoes, 50, "", .T., .T. , .T. } )

    For nI := 1 To Len( _aParAux )
	    aAdd( _aParRet , _aParAux[nI][03] )
    Next nI
    _cFiltro:=NIL
    IF !ParamBox( _aParAux , "FILTROS" , @_aParRet,,, .T. , , , , , .T. , .T. )
  		 RETURN .F.
    EndIf
    IF MV_PAR01 <> 4
       _cFiltro:=" ZZI_TIPO = '"+STR(MV_PAR01,1)+"' "
    ENDIF

   dbSelectArea(cAlias)
   dbSetOrder(1)
   mBrowse(,,,,cAlias,,,,,,aCores,,,,,,,,_cFiltro)

Else
	U_ITMSG("O usuário: " + cUserName + " não possui permissão para utilizar este cadastro.",;
		    "Usuário Inválido",;
		    "Verificar com a área de TI a possibilidade de habilitar o seu usuário.",3)
EndIf
Return(Nil)
/*
===============================================================================================================================
Programa----------: ACOM03L
Autor-------------: Alex Walaluer
Data da Criacao---: 30/03/2021                                    .
Descrição---------: Função utilizada para montar a legenda
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM03L()
aLegenda :=	{{"BR_VERDE"	, "NIVEL 1"	 },;
				 {"BR_AZUL"	   , "NIVEL 2"	 },;
				 {"BR_AMARELO"	, "NIVEL 3"	 },;
				 {"BR_VERMELHO", "BLOQUEADO"},;
				 {"BR_PRETO"	, "SEM NIVEL"} }

BrwLegenda("INVESTIMENTOS","Legenda",aLegenda)

return

/*
===============================================================================================================================
Programa----------: ACOM03V
Autor-------------: Alex Walaluer
Data da Criacao---: 01/03/2021                                    .
Descrição---------: Cadastro de Centro de Investimento.
Parametros--------: cAlias,nReg,nOpc
Retorno-----------: nOpc
===============================================================================================================================
*/
User Function ACOM03V(cAlias,nReg,nOpc)
Local _aBotoes:= {}
aAdd( _aBotoes, {'NOTE',{||U_ACOM03Wrkf("NIVEISV")},"VISUALIZA NIVEIS"})  

IF ZZI->ZZI_TIPO $ "1,2" 
   ACOM03Tela(cAlias,nReg,nOpc,_aBotoes)
   RETURN nOpc
ENDIF

PRIVATE _aDadosGrava:={}
AxVisual(cAlias,nreg,nOpc; //cAlias,nReg,nOpc,aAcho,nColMens,cMensagem,cFunc,aButtons,lMaximized,cTela,lPanelFin,oFather,oEnc01,lCriaBut,aDim,cStack,aCpos
  	   , /*<aAcho>*/;
	   , /*<nColMens> */;
	   , /*<cMensagem>*/;
	   , /*<cFunc>   */;
	   , /*<aButtons>*/_aBotoes)
RETURN nOpc

/*
===============================================================================================================================
Programa----------: ACOM003I
Autor-------------: Alex Walaluer
Data da Criacao---: 01/03/2021                                    .
Descrição---------: Cadastro de Centro de Investimento.
Parametros--------: cAlias,nReg,nOpc
Retorno-----------: nOpc
===============================================================================================================================
*/
User Function ACOM003I(cAlias,nReg,nOpc)
Local _aBotoes:=Nil
PRIVATE _aDadosGrava:={}

If nOpc = 1     //Incluir NIVEL 1
   _cTipoIni:="1"
ElseIf nOpc = 2 //Incluir NIVEL 2
   _cTipoIni:="2"
Elseif nOpc = 3 //Incluir NIVEL 3
   _cTipoIni:="3"
Elseif nOpc = 4 //Alterar

  IF ZZI->ZZI_TIPO $ "1,2" 
     _aBotoes:= {}
     aAdd( _aBotoes, {'NOTE'     ,{||U_ACOM03Wrkf("NIVEIS")},"Visualiza Niveis/Acerto"})  
     aAdd( _aBotoes, {'NOTE'     ,{||U_ACOM03Wrkf("BOTAO") },"Vincula Niveis Abaixo"  })  
  ENDIF

  IF ZZI->ZZI_TIPO $ "1,2" 
     ACOM03Tela(cAlias,nReg,nOpc,_aBotoes)
     RETURN nOpc
  ENDIF

  AxAltera(cAlias,nreg,nOpc; 
  	   , /*<aAcho>*/;
	   , /*<aCpos>*/;
	   , /*<nColMens> */;
	   , /*<cMensagem>*/;
	   , /*<cTudoOk>*/  'U_ACOM03Wrkf("VALGRV" )';//GRAVA // antes 
	   , /*<cTransact>*/'U_ACOM03Wrkf("GRVA")';//depois 
	   , /*<cFunc>   */;
	   , /*<aButtons>*/_aBotoes;
	   , /*<aParam>  */;
	   , /*<aAuto>*/;
	   , /*<lVirtual>*/;
	   , /*<lMaximized>*/)
   
   RETURN nOpc

Endif

IF _cTipoIni $ "1,2" 
   _aBotoes:= {}
   aAdd( _aBotoes, {'NOTE'     ,{||U_ACOM03Wrkf("BOTAO") },"Vincula Niveis Abaixo"  })  
ENDIF

AxInclui(cAlias,nreg,nOpc,;
       /*aAcho>     */ ,;
       /*cFunc>     */ ,;
       /*aCpos>     */ ,;
       /*cTudoOk>   */ 'U_ACOM03Wrkf("VALGRV" )',;
       /*lF3>       */ ,;
       /*cTransact> */ 'U_ACOM03Wrkf("GRVI")',;//Antes 
       /*aButtons>  */ _aBotoes,;
       /*aParam>    */ ,;
       /*aAuto>     */ ,;
       /*lVirtual>  */ ,;
       /*lMaximized>*/ )

// Grava log do Cadastro de Centro de Investimento.
U_ITLOGACS('ACOM003')

RETURN nOpc

/*
===============================================================================================================================
Programa----------: ACOM003E
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 20/08/2015                                    .
Descrição---------: Função criada para fazer a validação da exclusão do registro.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ACOM003E(_lSoValida)
Local _aArea	 := ZZI->(GetArea())
Local _cQry		 := ""
Local _cAlias	 := GetNextAlias()
Local _nRecAtual  := ZZI->(RECNO())
Local  cZZI_TIPO  := ZZI->ZZI_TIPO
Local  cZZI_CODINV:= ZZI->ZZI_CODINV
Local  _lRet := .T.

Begin Sequence

   _cLista:=ZZI->ZZI_CODINV+" ;"
   IF LEFT(cZZI_TIPO,1) = "1"
      ZZI->(DBSETORDER(3))//ZZI_FILIAL+ZZI_INVPAI
      IF ZZI->(DBSEEK(xFilial() + cZZI_CODINV ))
         DO WHILE ZZI->(!EOF()) .AND. xFilial("ZZI")+cZZI_CODINV == ZZI->ZZI_FILIAL+ZZI->ZZI_INVPAI
            _cLista+=ZZI->ZZI_CODINV+" ;"
            ZZI->(DBSKIP())
         ENDDO        
      ENDIF
   ELSEIF LEFT(cZZI_TIPO,1) = "2"
      ZZI->(DBSETORDER(4))//ZDA_FILIAL+ZZI_NIVEL2
      IF ZZI->(DBSEEK(xFilial() + cZZI_CODINV  ))
         DO WHILE ZZI->(!EOF()) .AND. xFilial("ZZI")+cZZI_CODINV  == ZZI->ZZI_FILIAL+ZZI->ZZI_NIVEL2
            _cLista+=ZZI->ZZI_CODINV+" ;"
            ZZI->(DBSKIP())
         ENDDO        
      ENDIF		
   ENDIF
   _cLista:=LEFT(_cLista,LEN(_cLista)-1)
   _cQry := "SELECT C1_NUM "
   _cQry += "FROM " + RetSqlName("SC1") + " "
   _cQry += "WHERE C1_FILIAL = '" + xFilial("SC1") + "' "
   _cQry += " AND (C1_I_CDINV IN " + FormatIn(_cLista,";")
   _cQry += "   OR C1_I_SUBIN IN " + FormatIn(_cLista,";")+")"
   _cQry += "  AND C1_RESIDUO = ' ' "
   _cQry += "  AND C1_PEDIDO  = ' ' "
   _cQry += "  AND D_E_L_E_T_ = ' ' "
   _cQry += "  ORDER BY C1_NUM"
   _cQry := ChangeQuery(_cQry)
   MPSysOpenQuery(_cQry,_cAlias)	
   	
   (_cAlias)->( dbGotop() )
   _cListaSC:=""
   DO WHILE (_cAlias)->( !Eof() )
      IF !(_cAlias)->C1_NUM $ _cListaSC
         _cListaSC+=(_cAlias)->C1_NUM+", "
      ENDIF
      (_cAlias)->( DBSKIP() )
   ENDDO
   _cListaSC:=LEFT(_cListaSC,LEN(_cListaSC)-2)
	If !EMPTY(_cListaSC)
      U_ITMSG("Exclusão não permitida Investimento já utilizado em Solicitacoes de Compras. ",;
              "Atenção",;
              "SC(s) :"+_cListaSC,3)
      _lRet := .F.
      ZZI->(DBGOTO(_nRecAtual))
	Else
      IF !EMPTY(_cLista)
         _cLista:="Niveis abaixos: "+_cLista
      ENDIF
      If !U_ITMSG("Confirma a exclusão deste investimento e seus sub-niveis? ","Atenção" ,_cLista,2, 2)
         _lRet := .F.
         ZZI->(DBGOTO(_nRecAtual))
         Break
      EndIf
      IF _lSoValida
         Break
      ENDIF
      IF LEFT(cZZI_TIPO,1) = "1"
         ZZI->(DBSETORDER(3))//ZZI_FILIAL+ZZI_INVPAI
         DO WHILE ZZI->(DBSEEK(xFilial() + cZZI_CODINV )) .AND. ZZI->(!EOF())//LIMPA OS NIVEIS 2 E 3
	         ZZI->(RecLock("ZZI", .F.))
	         ZZI->(dbDelete())
	         ZZI->(MsUnLock())
         ENDDO
      ELSEIF LEFT(cZZI_TIPO,1) = "2"
         ZZI->(DBSETORDER(4))//ZZI_FILIAL+ZZI_NIVEL2
         DO WHILE ZZI->(DBSEEK(xFilial() + cZZI_CODINV )) .AND. ZZI->(!EOF())//LIMPA OS NIVEIS 3
	         ZZI->(RecLock("ZZI", .F.))
	         ZZI->(dbDelete())
	         ZZI->(MsUnLock())
         ENDDO
      ENDIF
      ZZI->(DBGOTO(_nRecAtual))
	   ZZI->(RecLock("ZZI", .F.))
	   ZZI->(dbDelete())
	   ZZI->(MsUnLock())
	EndIf

End Sequence

If Select(_cAlias) > 0
   (_cAlias)->( dbCloseArea() )
EndIf

RestArea(_aArea)

Return _lRet

/*
===============================================================================================================================
Programa----------: ACOM003VLD
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 20/08/2015                                    .
Descrição---------: Função criada para fazer a validação da digitação das datas.
Parametros--------: Nenhum
Retorno-----------: Lógico - .T. dados válidas, .F. dados inválidos
===============================================================================================================================
*/
User Function ACOM003VLD()
Local _aArea	:= GetArea()
Local _lRet		:= .T.
Local _cCampo	:= ReadVar()

If 'ZZI_DTINIC' $ _cCampo
	If !(Empty(M->ZZI_DTFIM))
		If M->ZZI_DTINIC > M->ZZI_DTFIM

			_aInfHlp := {}
			//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
			aAdd( _aInfHlp , { "A data início não pode ser maior que a "	, "data final.                          "	} )
			aAdd( _aInfHlp , { "Favor selecionar uma data válida.      "	, ""                                        } )
				
			U_ITCADHLP( _aInfHlp , "ACOM00302", .F. )
			
			U_ITMSG("A data início não pode ser maior que a data final.",;
		            "Atenção",;
		            "Favor selecionar uma data válida.      ",3)

			_lRet := .F.
		EndIf
	EndIf
ElseIf 'ZZI_DTFIM' $ _cCampo
	If !(Empty(M->ZZI_DTINIC))
		If M->ZZI_DTFIM < M->ZZI_DTINIC

			_aInfHlp := {}
			//                 |....:....|....:....|....:....|....:....|      |....:....|....:....|....:....|....:....|
			aAdd( _aInfHlp , { "A data final não pode ser menor que a "	, "data inicio.                          "	} )
			aAdd( _aInfHlp , { "Favor selecionar uma data válida.      "	, ""                                    } )
				
			U_ITCADHLP( _aInfHlp , "ACOM00303", .F. )
			
			U_ITMSG("A data final não pode ser menor que a data inicio.",;
		            "Atenção",;
		            "Favor selecionar uma data válida.",3)

			_lRet := .F.
		EndIf
	EndIf
EndIf

RestArea(_aArea)
Return(_lRet)

/*
===============================================================================================================================
Programa----------: ACOM03Wrkf
Autor-------------: Alex Wallauer
Data da Criacao---: 03/01/2020
Descrição---------: Valida e Monta e envia email e Grava manual
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER FUNCTION ACOM03WRKF(_cChamada)
Local _aConfig	:= U_ITCFGEML('') , E , nInv //,nI
Local _cEmlLog	:= ""
Local _cMsgEml	:= ""
Local cGetPara	:= "sistema@italac.com.br"
Local cTit     := "INCLUSÃO DE INVESTIMENTO"
Local cGetAssun:= 'NOVO CADASTRO DE CENTRO DE INVESTIMENTO'
Local _lInclui := (_cChamada = "GRVI" )
LOCAL _nRecAtual:= ZZI->(RECNO())
Local _lAmbTeste := SuperGetMV("IT_AMBTEST",.F.,.T.)
IF _cChamada == "VALGRV" 

   ZZL->(DBSETORDER(3)) //ZZL_FILIAL + ZZL_CODUSU
   IF _lInclui .AND. !ZZL->(DBSEEK(xFilial("ZZL") + __cUserId)) //.OR. ZZL->ZZL_CADPRD = "S" 
   	U_ITMSG("O usuário: " + cUserName + " não possui permissão para executar esta ação neste cadastro.",;
   		     "Usuário Sem Acesso",;
   		     "Verificar com a área de TI a possibilidade de habilitar o seu usuário.",3,,,.T.)
   	RETURN .F.
   ENDIF

   IF M->ZZI_TIPO = "1" .AND. (!EMPTY(M->ZZI_INVPAI) .OR. !EMPTY(M->ZZI_NIVEL2))
      U_ITMSG("Campo Nivel 1 ou 2 Preenchidos",;
   	       "ATENÇÃO",;
   	       "Limpe os campos",3,,,.T.)
      RETURN .F.

   ENDIF

   RETURN .T.

ENDIF

IF _cChamada = "NIVEIS"//BOTAO Visualiza Niveis/Acerto

   IF M->ZZI_TIPO = "1" 
      _cSelectN2:="SELECT R_E_C_N_O_ RECN2 FROM "+RETSQLNAME("ZZI")+" ZZI "
      _cSelectN2+="WHERE  D_E_L_E_T_ = ' ' AND ZZI_FILIAL = '"+xFilial("ZZI")+"' 
      _cSelectN2+=" AND ZZI_TIPO = '2' "
      _cSelectN2+=" AND ZZI_INVPAI = '"+M->ZZI_CODINV+"' "
   
      _cSelectN3:="SELECT R_E_C_N_O_ RECN3 FROM "+RETSQLNAME("ZZI")+" ZZI "
      _cSelectN3+="WHERE  D_E_L_E_T_ = ' ' AND ZZI_FILIAL = '"+xFilial("ZZI")+"' 
      _cSelectN3+=" AND ZZI_TIPO = '3' "
      _cSelectN3+=" AND ZZI_INVPAI = '"+M->ZZI_CODINV+"' "
      _cSelectN3+=" AND ZZI_NIVEL2 = '"//+ZZI->ZZI_CODINV+"' "

   ELSE
      _cSelectN2:="SELECT R_E_C_N_O_ RECN2 FROM "+RETSQLNAME("ZZI")+" ZZI "
      _cSelectN2+="WHERE  D_E_L_E_T_ = ' ' AND ZZI_FILIAL = '"+xFilial("ZZI")+"' 
      _cSelectN2+=" AND ZZI_TIPO = '3' "
      _cSelectN2+=" AND ZZI_NIVEL2 = '"+M->ZZI_CODINV+"' "  

   ENDIF

   _cSelectN2 := ChangeQuery(_cSelectN2)
   MPSysOpenQuery(_cSelectN2,"TRBN2")
   
   TRBN2->(dbGoTop())

   _aDados:={}
   nTotN1GE:=0
   nTotN2GE:=0
   nTotN3GE:=0
   aLog:={}
   DO While !TRBN2->(Eof())

      ZZI->(DBGOTO(TRBN2->RECN2))
   
      IF M->ZZI_TIPO = "1" 
         AADD(aLog,{ZZI->ZZI_INVPAI , ZZI->ZZI_CODINV , SPACE(6), ZZI->ZZI_DESINV , "R$ "+ALLTRIM(Transform( ZZI->ZZI_VLRPRV ,"@E 999,999,999,999,999.99")),0, ZZI->ZZI_DTINIC,ZZI->ZZI_DTFIM })
         nTotN2GE:=ZZI->ZZI_VLRPRV 
         _nPosN2:=LEN(aLog)
      
         dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cSelectN3+ZZI->ZZI_CODINV+"' " ) , "TRBN3" , .T., .F. )
         TRBN3->(dbGoTop())
         nTotN3GE:=0
         DO While !TRBN3->(Eof())
   
            ZZI->(DBGOTO(TRBN3->RECN3))
            AADD(aLog,{ ZZI->ZZI_INVPAI , ZZI->ZZI_NIVEL2 , ZZI->ZZI_CODINV , ZZI->ZZI_DESINV , "R$ "+ALLTRIM(Transform( ZZI->ZZI_VLRPRV ,"@E 999,999,999,999,999.99")),0, ZZI->ZZI_DTINIC,ZZI->ZZI_DTFIM })
            nTotN3GE+=ZZI->ZZI_VLRPRV 
		      TRBN3->(DBSKIP())
   
         ENDDO
         TRBN3->(dbCloseArea())
         IF nTotN3GE <> 0
            aLog[_nPosN2,6]:="R$ "+ALLTRIM(Transform( nTotN3GE ,"@E 999,999,999,999,999.99"))
            nTotN1GE+=nTotN3GE
         ELSE
            nTotN1GE+=nTotN2GE
         ENDIF
      ELSE

         AADD(aLog,{ ZZI->ZZI_INVPAI , ZZI->ZZI_NIVEL2 , ZZI->ZZI_CODINV , ZZI->ZZI_DESINV , "R$ "+ALLTRIM(Transform( ZZI->ZZI_VLRPRV ,"@E 999,999,999,999,999.99")),0, ZZI->ZZI_DTINIC,ZZI->ZZI_DTFIM })
         nTotN1GE+=ZZI->ZZI_VLRPRV 

      ENDIF

      TRBN2->(DBSKIP())

   ENDDO
   TRBN2->(dbCloseArea())
   IF LEN(aLog) > 0

      IF M->ZZI_TIPO = "1" 
         AADD(aLog,{SPACE(6),"TOTAIS dos NIVEL 2", IF(M->ZZI_VLRPRV<>nTotN1GE,"DIFERENTE do NIVEL 1","IGUAL ao NIVEL 1") ,M->ZZI_DESINV ,;
                 "R$ "+ALLTRIM(Transform( M->ZZI_VLRPRV ,"@E 999,999,999,999,999.99")),;
                 "R$ "+ALLTRIM(Transform( nTotN1GE      ,"@E 999,999,999,999,999.99")) , M->ZZI_DTINIC,M->ZZI_DTFIM })
      ELSE
         AADD(aLog,{SPACE(6),"TOTAIS dos NIVEL 3", IF(M->ZZI_VLRPRV<>nTotN1GE,"DIFERENTE do NIVEL 2","IGUAL ao NIVEL 2") ,M->ZZI_DESINV ,;
                 "R$ "+ALLTRIM(Transform( M->ZZI_VLRPRV ,"@E 999,999,999,999,999.99")),;
                 "R$ "+ALLTRIM(Transform( nTotN1GE      ,"@E 999,999,999,999,999.99")) , M->ZZI_DTINIC,M->ZZI_DTFIM })
      ENDIF
      aCab:={}
      AADD(aCab,"Cod.Nivel 1 ")
      AADD(aCab,"Cod.Nivel 2 ")
      AADD(aCab,"Cod.Nivel 3 ")
      AADD(aCab,"Descricao do Nivel"  )
      AADD(aCab,"Valor Previsto"      )
      AADD(aCab,"Valor Previsto Total")
      AADD(aCab,"Dt Inicio")
      AADD(aCab,"Dt Fim"   )
      _cTitulo:='Lista de Investimentos por Nivel'
      _cMsgTop:=""
      IF _cChamada == "NIVEIS"//BOTAO Visualiza Niveis/acerta
         _cMsgTop:="Clique no botão OK para fazer o acerto caso necessario"
      ENDIF
                             //    , _aCols,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons )
      _lOK:=U_ITListBox(_cTitulo,aCab,aLog , .T.    , 1    ,_cMsgTop ,          ,        ,         ,     ,        , )
      IF _lOK
         M->ZZI_VLRPRV:=nTotN1GE
      EndIf
   ELSE
      U_ITMSG("Não foram encontrado niveis abaixo",'Atenção!',,3)
   ENDIF

   ZZI->(DBGOTO(_nRecAtual))
   
   RETURN .T.

ENDIF

IF (_cChamada = "BOTAO"  .OR. _cChamada $ "GRVA/GRVI")  .AND. LEFT(M->ZZI_TIPO,1) $ "1,2"  

   _lRet:=.F.
   IF _cChamada = "GRVI" 
      _lPergunta:=LEN(_aDadosGrava) = 0
   ELSEIF _cChamada = "GRVA" 
      IF LEFT(M->ZZI_TIPO,1) = "1"
         ZZI->(DBSETORDER(3))//ZZI_FILIAL+ZZI_INVPAI
         _lPergunta:=LEN(_aDadosGrava) = 0 .AND. !ZZI->(DBSEEK(xFilial() + M->ZZI_CODINV ))
      ELSE
         ZZI->(DBSETORDER(4))//ZZI_FILIAL+ZZI_NIVEL2
         _lPergunta:=LEN(_aDadosGrava) = 0 .AND. !ZZI->(DBSEEK(xFilial() + M->ZZI_CODINV ))
      ENDIF
   ENDIF

   IF _cChamada = "BOTAO" .OR.;
     (_lPergunta .AND. U_ITMSG("Deseja vincular niveis "+AllTrim(STR(VAL(M->ZZI_TIPO)+1))+" a esse investimento ?",'Atenção!',,2,2,2))

      _cSelect:="SELECT ZZI_CODINV , ZZI_DESINV FROM "+RETSQLNAME("ZZI")+" ZZI "
      _cSelect+="WHERE  D_E_L_E_T_ <> '*' AND ZZI_FILIAL = '"+xFilial("ZZI")+"' 
	  
      MV_PAR01:=""
	   IF LEFT(M->ZZI_TIPO,1) = "1"
	      _cSelect+=" AND ZZI_TIPO   = '2' "
	      _cSelect+=" AND ZZI_INVPAI = ' ' "//"+M->ZZI_INVPAI+"
	      _cSelect+=" AND ZZI_NIVEL2 = ' ' "         
         _cTitulo:='Lista de Investimentos do Nivel 2 e 3'
	   
      ELSEIF LEFT(M->ZZI_TIPO,1) = "2"
	      _cSelect+=" AND ZZI_TIPO   =  '3' "
	      _cSelect+=" AND ZZI_INVPAI =  ' ' "
	      _cSelect+=" AND ZZI_NIVEL2 =  ' ' "
         _cTitulo:='Lista de Investimentos do Nivel 3'

	   ENDIF

      _cSelect+=" ORDER BY ZZI_CODINV " 
      //                 1           2         3                                 4                    5          6          7         8          9         10         11        12
      //             _cNomeSXB , _cTabela ,_nCpoChave                , _nCpoDesc                , _bCondTab , _cTitAux, _nTamChv , _aDados , _nMaxSel , _lFilAtual , _cMVRET , _bValida , _oProc , _aParam
	   _lRet:=U_ITF3GEN(        ,_cSelect  ,{|Tab| (Tab)->ZZI_CODINV },{|Tab| (Tab)->ZZI_DESINV },           , _cTitulo,          ,         ,          , .T.        , "MV_PAR01")
      _lRet2:=.F.
   	aLog:={}
	   IF _lRet .AND. !EMPTY(MV_PAR01)
	   	_aDados := STRTOKARR(MV_PAR01, ';')
	   	FOR nInv := 1 TO LEN(_aDados)
            ZZI->(DBSETORDER(1))//ZDA_FILIAL+ZZI_CODINV
	         IF ZZI->(DBSEEK(xFilial() + _aDados[nInv] ))
               AADD(aLog,{.T.,.F.,ZZI->ZZI_CODINV , SPACE(6) , ZZI->ZZI_DESINV, "R$ "+ALLTRIM(Transform( ZZI->ZZI_VLRPRV ,"@E 999,999,999,999,999.99")), ZZI->ZZI_DTINIC, ZZI->ZZI_DTFIM })
	         ENDIF
            IF LEFT(M->ZZI_TIPO,1) = "1"
               ZZI->(DBSETORDER(4))//ZDA_FILIAL+M->ZZI_NIVEL2
               IF ZZI->(DBSEEK(xFilial() + _aDados[nInv] ))
                  DO WHILE ZZI->(!EOF()) .AND. xFilial("ZZI")+_aDados[nInv] == ZZI->ZZI_FILIAL+ZZI->ZZI_NIVEL2
                     AADD(aLog,{.T.,.T.,ZZI->ZZI_NIVEL2 , ZZI->ZZI_CODINV , ZZI->ZZI_DESINV, "R$ "+ALLTRIM(Transform( ZZI->ZZI_VLRPRV ,"@E 999,999,999,999,999.99")), ZZI->ZZI_DTINIC, ZZI->ZZI_DTFIM})
                     ZZI->(DBSKIP())
                  ENDDO        
               ENDIF		
            ENDIF		
         NEXT
	   	_lRet2:=.T.//LIGA LIGA PQ O TIPO = 2 NÃO TEM SEGUNDA TELA
         IF LEFT(M->ZZI_TIPO,1) = "1"
            IF LEN(aLog) > 0 
               aCab:={}
               AADD(aCab," ")
               AADD(aCab," ")
               AADD(aCab,"Cod.Nivel 2" )
               AADD(aCab,"Cod.Nivel 3" )
               AADD(aCab,"Descricao"   )
               AADD(aCab,"Valor Previsto")
               AADD(aCab,"Dt Inicio"   )
               AADD(aCab,"Dt Fim"      )
	            _cTitulo:='Lista de Investimentos Selecionados'
               bCondMarca:={|oLbxAux,nAt| oLbxAux:aArray[nAt][2] }
               _cMsgTop:="Clique em OK para confirmar a seleções dos niveis (Todos os niveis 3 serão selecinados)"//(Marque pelo menos 1 nivel 3 p/ cada nivel 2)"
                                           //  , _aCols,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca )
               _lRet2:=U_ITListBox(_cTitulo,aCab,aLog   , .T.    , 2    ,_cMsgTop,          ,        ,         ,     ,        ,          ,       ,         ,          , bCondMarca)
	         ELSEIF LEFT(M->ZZI_TIPO,1) = "1"
	            U_ITMSG("Não foram criados novos registros",'Atenção!',,3)
               _lRet2:=.F.
	         ENDIF
         ENDIF
	   ENDIF
      ZZI->(DBGOTO(_nRecAtual))
	   IF _lRet2
         _aDadosGrava:=ACLONE(aLog)
         IF _cChamada <> "BOTAO"
            ACOM03GRV(_cChamada)//Grava os niveis         
         ENDIF         
	   ENDIF

   ENDIF

ENDIF

IF LEN(_aDadosGrava) > 0 .AND. _cChamada $ "GRVA/GRVI" .AND. LEFT(M->ZZI_TIPO,1) $ "1,2"  
   ACOM03GRV(_cChamada)//Grava os niveis         
ENDIF         

IF _cChamada $ "GRVA/GRVI" .AND. LEFT(M->ZZI_TIPO,1) $ "1,2" //SÓ ALTERA E INCLUI DOS TIPOS 1 e 2 

   IF LEFT(M->ZZI_TIPO,1) = "1" 

      ZZI->(DBGOTO(_nRecAtual))
      IF _cChamada = "GRVI"//INCLUSAO TEM QUE TRAVAR
         ZZI->(RECLOCK("ZZI",.F.)) 
         ZZI->ZZI_CHAVE:= M->ZZI_CHAVE:= M->ZZI_CODINV//GRAVA AQUI NOS CASO QUE NÃO VINCULOU NADA NA INCLUSAO
         ZZI->(MSUNLOCK()) 
      ELSE
         ZZI->ZZI_CHAVE:= M->ZZI_CHAVE:= M->ZZI_CODINV//GRAVA AQUI NOS CASO QUE NÃO VINCULOU NADA NA ALTERECAO
      ENDIF
      
      IF M->ZZI_MSBLQL = "1"// SÓ REPASSA PARA OS DESMAIS SE FOR PARA BLOQUEAR , PQ SENÃO SOBREPOE OS BLOQUEADOS INDIVIDUAIS
         ZZI->(DBSETORDER(3))//ZZI_FILIAL+ZZI_INVPAI
         IF ZZI->(DBSEEK(xFilial() + M->ZZI_CODINV ))
            DO WHILE ZZI->(!EOF()) .AND. xFilial("ZZI")+M->ZZI_CODINV == ZZI->ZZI_FILIAL+ZZI->ZZI_INVPAI
               ZZI->(RECLOCK("ZZI",.F.)) 
               ZZI->ZZI_MSBLQL := M->ZZI_MSBLQL
               ZZI->(MSUNLOCK()) 
               ZZI->(DBSKIP())
            ENDDO        
         ENDIF
      ENDIF
   ELSEIF LEFT(M->ZZI_TIPO,1) = "2" .AND. M->ZZI_MSBLQL = "1"// SÓ REPASSA PARA OS DESMAIS SE FOR PARA BLOQUEAR , PQ SENÃO SOBREPOE OS BLOQUEADOS INDIVIDUAIS
      ZZI->(DBSETORDER(4))//ZDA_FILIAL+M->ZZI_NIVEL2
      IF ZZI->(DBSEEK(xFilial() + M->ZZI_CODINV  ))
         DO WHILE ZZI->(!EOF()) .AND. xFilial("ZZI")+M->ZZI_CODINV  == ZZI->ZZI_FILIAL+ZZI->ZZI_NIVEL2
            ZZI->(RECLOCK("ZZI",.F.)) 
            ZZI->ZZI_MSBLQL := M->ZZI_MSBLQL
            ZZI->(MSUNLOCK()) 
            ZZI->(DBSKIP())
         ENDDO        
      ENDIF		
   ENDIF

ENDIF         

IF M->ZZI_TIPO $ "2,3"  .OR. _cChamada $ "BOTAO/NIVEIS/GRVA"//Não envia e-mail quando for subs e não é inclusao
	RETURN .T.	    
ENDIF

//********  ENVIA E-MAIL SÓ NA INCLUSAO (_cChamada=GRVI) E M->ZZI_TIPO = 1  **************************************

_cQry := "SELECT ZZL_EMAIL "
_cQry += "FROM " + RetSqlName("ZZL") + " "
_cQry += "WHERE ZZL_FILIAL = '" + xFilial("ZZL") + "' "
_cQry += "  AND ZZL_ENVINV  = 'S' AND ZZL_FILWEP LIKE '%"+cFilant+"%'"
_cQry += "  AND D_E_L_E_T_ = ' ' "
_cQry := ChangeQuery(_cQry)
MPSysOpenQuery(_cQry,"TRBZZL")

TRBZZL->(dbGoTop())

_acTo:={}
DO While !TRBZZL->(Eof())
	AADD(_acTo,AllTrim(TRBZZL->ZZL_EMAIL))
	TRBZZL->(DBSKIP())
ENDDO
TRBZZL->(dbCloseArea())

_cMsgEml := '<html>'
_cMsgEml += '<head><title>'+cTit+'</title></head>'
_cMsgEml += '<body>'
_cMsgEml += '<style type="text/css"><!--'
_cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
_cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
_cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
_cMsgEml += '--></style>'
_cMsgEml += '<center>'
_cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="900" height="50"><br>'
_cMsgEml += '<table class="bordasimples" width="900">'
_cMsgEml += '    <tr>'
_cMsgEml += '	     <td class="titulos"><center>'+cTit+'</center></td>'
_cMsgEml += '	 </tr>'
_cMsgEml += '</table>'
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="900">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="2" class="grupos">Dados do Investimento</b></td>'
_cMsgEml += '    </tr>'

_cPer:="18"

_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="left" width="'+_cPer+'%"><b>Usuario:</b></td>'
_cMsgEml += '      <td class="itens" >'+ UsrFullName(__cUserID) +'</td>'
_cMsgEml += '    </tr>'

_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="left" width="'+_cPer+'%"><b>Codigo:</b></td>'
_cMsgEml += '      <td class="itens" >'+ M->ZZI_CODINV +'</td>' 
_cMsgEml += '    </tr>'

_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="left" width="'+_cPer+'%"><b>Descricao:</b></td>'
_cMsgEml += '      <td class="itens" >'+ M->ZZI_DESINV +'</td>' 
_cMsgEml += '    </tr>'

_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="left" width="'+_cPer+'%"><b>Data Inclusao:</b></td>'
_cMsgEml += '      <td class="itens" >'+DTOC(DATE())+'</td>'
_cMsgEml += '    </tr>'

_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="left" width="'+_cPer+'%"><b>Data Inicio:</b></td>'
_cMsgEml += '      <td class="itens" >'+DTOC(M->ZZI_DTINIC)+'</td>'
_cMsgEml += '    </tr>'

_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="left" width="'+_cPer+'%"><b>Data Fim:</b></td>'
_cMsgEml += '      <td class="itens" >'+DTOC(M->ZZI_DTFIM)+'</td>'
_cMsgEml += '    </tr>'

_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="left" width="'+_cPer+'%"><b>Observacao:</b></td>'
_cMsgEml += '      <td class="itens" >'+ALLTRIM(M->ZZI_OBS)+'</td>'
_cMsgEml += '    </tr>'


_cMsgEml += '</table>'
_cMsgEml += '</center>'
_cMsgEml += '<br>'
_cMsgEml += '<br>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="left" ><b>Ambiente:</b></td>'
_cMsgEml += '      <td class="itens" align="left" > ['+ GETENVSERVER() +'] / <b>Fonte:</b> [ACOM003]</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '</body>'
_cMsgEml += '</html>'


FOR E := 1 TO LEN(_acTo)

    cGetPara:=_acTo[E]
    // Chama a função para envio do e-mail
//    ITEnvMail(cFrom        ,cEmailTo,_cEmailCo,cEmailBcc,cAssunto ,cMensagem,cAttach   ,cAccount    ,cPassword   ,cServer     ,cPortCon    ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro)
    U_ITENVMAIL(_aConfig[01], cGetPara,         ,         ,cGetAssun,_cMsgEml ,          ,_aConfig[01],_aConfig[02],_aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )
		
    If _lAmbTeste
       U_ITMSG(UPPER(_cEmlLog)+CHR(13)+CHR(10)+;
		           "E-mail para: "+cGetPara,"Envio do E-MAIL",,3)
    ENDIF

NEXT

Return .T.

/*
===============================================================================================================================
Programa----------: ACOM03GRV
Autor-------------: Alex Wallauer
Data da Criacao---: 03/01/2021
Descrição---------: Valida e Monta e envia email e Grava manual
Parametros--------: _cChamada
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC FUNCTION ACOM03GRV(_cChamada)
LOCAL _cCod1    := SPACE(6)
LOCAL _cCod2    := SPACE(6)
LOCAL _cCod3    := SPACE(6)
LOCAL _aLog     := {}
LOCAL _aTotN1   := {}
LOCAL nInv:=nTot:= 0 , A
LOCAL _nRecAtual:= ZZI->(RECNO())
LOCAL nTotN1GE  := 0
LOCAL nTotN2GE  := 0
LOCAL aAcertoN2 := {}
LOCAL lAcertaN2 := .F.

FOR nInv := 1 TO LEN(_aDadosGrava)

   If !_aDadosGrava[nInv][01]
      lAcertaN2:=.T.
      LOOP
   ENDIF
   
   ZZI->(DBSETORDER(1))//ZDA_FILIAL+ZZI_CODINV
   IF !EMPTY(_aDadosGrava[nInv][4])
      IF !ZZI->(DBSEEK(xFilial() + ALLTRIM(_aDadosGrava[nInv][4]) ))//SEEK NO NIVEL 3
         LOOP
      ENDIF
   ELSE
      IF !ZZI->(DBSEEK(xFilial() + ALLTRIM(_aDadosGrava[nInv][3]) ))//SEEK NO NIVEL 4
         LOOP
      ENDIF
   ENDIF
   
   _cCod1  := SPACE(6)
   _cCod2  := SPACE(6)
   _cCod3  := SPACE(6)
   _cCod1D := ""
   _cCod2D := ""
   _cDesc  := ZZI->ZZI_DESINV//Descrição cadastrada atual
   _cTipo  := ZZI->ZZI_TIPO  //TIPO DO NIVEL PROSICIONADO
   _nValor := ZZI->ZZI_VLRPRV
	_cCod   := GetSXENum("ZZI","ZZI_CODINV")//Codigo novo 
   
   IF _cTipo = "2"//TIPO DO NIVEL PROSICIONADO
      _cCod1 := M->ZZI_CODINV //COD NIVEL 1 ATUAL
      _cCod1D:= M->ZZI_DESINV //DESC NIVEL 1 ATUAL
      IF ASCAN(_aTotN1, {|T| T[1]== ZZI->ZZI_CODINV }) = 0
         //Total      {Cod. N2        ,Vlr N2         ,Vlr N3,Cod. N2 Novo}
         AADD(_aTotN1,{ZZI->ZZI_CODINV,ZZI->ZZI_VLRPRV,0     ,_cCod       ,_cDesc})//GRAVA DADOS PARA USAR NOS NIVEIS 3 DO NIVEL 2 ATUAL
      ENDIF
   
   ELSEIF _cTipo = "3"//TIPO DO NIVEL PROSICIONADO
   
      IF LEFT(M->ZZI_TIPO,1) = "1" // SÓ NO CADASTRO NIVEL 1 // TIPO DO NIVEL DO CADASTRO ATUAL
         _cCod1  := M->ZZI_CODINV  // COD NIVEL 1 ATUAL
         _cCod1D := M->ZZI_DESINV  // DESC NIVEL 1 ATUAL
         IF (nTot:= ASCAN(_aTotN1, {|T| T[1]== ZZI->ZZI_NIVEL2 })) <> 0
            _aTotN1[nTot,3]+=ZZI->ZZI_VLRPRV//SOMA DO NIVEL 1     
            _cCod2 := _aTotN1[nTot,4]//Pega Codigo novo do nivel 2
            _cCod2D:= _aTotN1[nTot,5]//Pega descricao do nivel 2
         ENDIF

      ELSEIF LEFT(M->ZZI_TIPO,1) = "2"// SÓ NO CADASTRO NIVEL 2  // TIPO DO NIVEL DO CADASTRO ATUAL
         _cCod1  := M->ZZI_INVPAI     // Pega Codigo do nivel 1 se tiver no N2
         _cCod1D := M->ZZI_DESINV     // DESC NIVEL 1 ATUAL
         _cCod2  := M->ZZI_CODINV     // COD NIVEL 2 ATUAL
         _cCod2D := M->ZZI_DESINV     // DESCRICAO DI N2 ATUAL
         nTotN2GE+= ZZI->ZZI_VLRPRV   // TOTAL DO NIVEL 3 NO CADASTRO DO NIVEL 2
      
      ENDIF
      _cCod3:=_cCod //Codigo novo do nivel 3 NOVO
   
   ENDIF   
	ZZI->(RECLOCK("ZZI",.T.))
	ZZI->ZZI_FILIAL := xFilial("ZZI")
	ZZI->ZZI_CODINV := _cCod
   ZZI->ZZI_INVPAI := _cCod1
   ZZI->ZZI_NIVE1D := _cCod1D
   ZZI->ZZI_NIVEL2 := _cCod2
   ZZI->ZZI_NIVE2D := _cCod2D
	ZZI->ZZI_DESINV := _cDesc
	ZZI->ZZI_TIPO   := _cTipo
   ZZI->ZZI_VLRPRV := _nValor
	ZZI->ZZI_DTINIC := M->ZZI_DTINIC
	ZZI->ZZI_DTFIM  := M->ZZI_DTFIM
	ZZI->ZZI_OBS    := M->ZZI_OBS   
	ZZI->ZZI_MSBLQL := M->ZZI_MSBLQL
   IF M->ZZI_TIPO = "1"// Inclusao do NIVEL 1
      IF _cTipo = "2"  // Inclusao do NIVEL 2 no NIVEL 1
         ZZI->ZZI_CHAVE  := _cCod1+_cCod
         AADD(aAcertoN2,{ ZZI->ZZI_CHAVE,0,ZZI->(RECNO()),ZZI->ZZI_CODINV})
      ELSE             // Inclusao do NIVEL 3 no NIVEL 1
         ZZI->ZZI_CHAVE  := _cCod1+_cCod2+_cCod3
         IF (nPos:=ASCAN(aAcertoN2,{|A| A[1]= ZZI->ZZI_INVPAI+ZZI->ZZI_NIVEL2 } ))  <> 0
             aAcertoN2[nPos,2]+=_nValor
         ENDIF
      ENDIF
   ELSEIF M->ZZI_TIPO = "2"         // Inclusao do NIVEL 2 que pode ter ou não vin
      ZZI->ZZI_CHAVE := ALLTRIM(_cCod1)+_cCod2+_cCod// Inclusao do NIVEL 3 no NIVEL 2
   ENDIF
   ZZI->(MSUNLOCK())
	ConfirmSX8() 
   IF _cTipo = "2"//ATUALIA PARA O CODIGO NOVO GERADO
      _cCod2:=_cCod
   ENDIF
	AADD(_aLog,{_cCod1,_cCod2, _cCod3 , ZZI->ZZI_DESINV, ZZI->ZZI_DTINIC, ZZI->ZZI_DTFIM , "R$ "+ALLTRIM(Transform( _nValor ,"@E 999,999,999,999,999.99")),ZZI->ZZI_CHAVE })
//                1      2        3            4               5               6                                      7                                            8
NEXT

ZZI->(DBGOTO(_nRecAtual))//POSICIONA DE VOLTA NO NIVEL DO CADASTRO PARA ACERTO
IF ZZI->ZZI_TIPO = "1" 
   FOR nTot := 1 TO LEN(_aTotN1)
       IF _aTotN1[nTot,3] > 0 
          nTotN1GE+=_aTotN1[nTot,3]
       ELSE
          nTotN1GE+=_aTotN1[nTot,2]
       ENDIF
   NEXT
   M->ZZI_VLRPRV:=(M->ZZI_VLRPRV+nTotN1GE)
   IF lAcertaN2
      FOR A := 1 TO LEN(aAcertoN2)
          ZZI->(DBGOTO(aAcertoN2[A,3]))//POSICIONA NIVEL 2 PARA ACERTAR O VALOR COM A SOMATORIA DO N3
          ZZI->(RECLOCK("ZZI",.F.)) 
          ZZI->ZZI_VLRPRV := aAcertoN2[A,2]
          ZZI->(MSUNLOCK()) 
          IF (nPos:=ASCAN(_aLog,{|L| L[8] == aAcertoN2[A,1] } )) <> 0 
              _aLog[nPos,7]:="R$ "+ALLTRIM(Transform( aAcertoN2[A,2] ,"@E 999,999,999,999,999.99"))
          ENDIF          
      NEXT
      ZZI->(DBGOTO(_nRecAtual))//POSICIONA DE VOLTA NO NIVEL DO CADASTRO ATUAL PARA ACERTO
   ENDIF

ELSEIF ZZI->ZZI_TIPO = "2" 
   M->ZZI_VLRPRV:=(M->ZZI_VLRPRV+nTotN2GE)
ENDIF
IF _cChamada = "GRVI"//INCLUSAO TEM QUE TRAVAR
   ZZI->(MSUNLOCK()) //Por garantia
   ZZI->(RECLOCK("ZZI",.F.)) // não tá travado na inclusao as vezes
   ZZI->ZZI_VLRPRV := M->ZZI_VLRPRV
   IF ZZI->ZZI_TIPO $ "1,2" // N1 E N2
      ZZI->ZZI_CHAVE  := ZZI->ZZI_CODINV
   ENDIF
   ZZI->(MSUNLOCK()) 
ELSEIF _cChamada = "GRVA"//ALTERACAO NÃO PRECISA TRAVAR
   ZZI->ZZI_VLRPRV := M->ZZI_VLRPRV
   IF M->ZZI_TIPO = "2" // quando vincula N3 NO N2
      ZZI->ZZI_CHAVE:= M->ZZI_CODINV
   ENDIF
ENDIF

IF LEN(_aLog) > 0
   aCab:={}
   AADD(aCab,"Cod.Nivel 1")
   AADD(aCab,"Cod.Nivel 2")
   AADD(aCab,"Cod.Nivel 3")
   AADD(aCab,"Descricao")
   AADD(aCab,"Dt Inicio")
   AADD(aCab,"Dt Fim")
   AADD(aCab,"Valor Previsto")
   AADD(aCab,"Chave Ordenacao")
   _cTitulo:='Lista dos Investimentos Vinculados com sucesso'
                           //, _aCols,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons )
   U_ITListBox(_cTitulo,aCab,_aLog   , .T.    , 1    ,       ,          ,        ,         ,     ,        , )
ELSE
   U_ITMSG("Nao houve alteracoes nos sub-niveis",'Atenção!',,3)
ENDIF
_aDadosGrava:={}//Limpa a variavel PRIVATE para prevenir duplicidade

RETURN .T.

/*
===============================================================================================================================
Programa--------: ACOM03Tela()
Autor-----------: Alex Walaluer
Data da Criacao-: 29/03/2021
Descrição-------: Tela de capa e detalhe
Parametros------:  cAlias ; _nOpc ; nReg
Retorno---------: .t.
===============================================================================================================================
*/
STATIC Function ACOM03Tela(cAlias,_nRec,_nOpc,_aBotoes)//cAlias,nReg,nOpc
Local aDarGets		 := NIL
Local aCamposMostra:= {}
Local aTB_Campos	 := {}
Local _aCamposTrb  := {}
Local aSemSX3		 := { {"TRBF_OK","C",02,0} , {"REC_ZZI","N",10,0}  }
Local _bOk := {|| U_ACOM03Wrkf("VALGRV")}
Local I,_nI, _nRegAtu 

Private  aHeader:= {}
Private cAliasWK:= GetNextAlias()
Private cMarca  := GetMark()
Private oEnCh1, oMark, oDlg

If SELECT(cAliasWK) # 0
   (cAliasWK)->(DBCLOSEAREA())
EndIf
AADD(aCamposMostra,"NOUSER")
DBSelectArea(cAlias)
For i := 1 To FCount()
   IF LEFT(ZZI->ZZI_TIPO,1) = "1" .AND. FieldName(i) $ "ZZI_NIVEL2/ZZI_NIVE2D/ZZI_NIVE1D/ZZI_INVPAI"
      LOOP
   ELSEIF LEFT(ZZI->ZZI_TIPO,1) = "2" .AND. FieldName(i) $ "ZZI_NIVEL2/ZZI_NIVE2D"
      LOOP
   ENDIF
    M->&(FieldName(i)) := FieldGet(i)
    AADD(aCamposMostra,FieldName(i))
Next 

Aadd(_aCamposTrb, "ZZI_TIPO  ")
Aadd(_aCamposTrb, "ZZI_CODINV")
Aadd(_aCamposTrb, "ZZI_DESINV")   
Aadd(_aCamposTrb, "ZZI_NIVEL2")
Aadd(_aCamposTrb, "ZZI_NIVE2D")
Aadd(_aCamposTrb, "ZZI_VLRPRV")  
Aadd(_aCamposTrb, "ZZI_DTINIC")  
Aadd(_aCamposTrb, "ZZI_DTFIM")   
Aadd(_aCamposTrb, "ZZI_CHAVE")  
Aadd(_aCamposTrb, "ZZI_MSBLQL")  
   
//==========================================================================
// Monta aHeader e a estrutura da tabela temporária.
//==========================================================================   
SX3->(DbSetOrder(2)) // X3_CAMPO
DbSelectArea("SX3")

AADD( aTB_Campos , { "TRBF_OK",,"",} )

For _nI := 1 To Len(_aCamposTrb)
    Aadd(aHeader,{Trim(Getsx3cache(_aCamposTrb[_nI],"X3_TITULO")),;                      
                       _aCamposTrb[_nI],;                      
                       Getsx3cache(_aCamposTrb[_nI],"X3_PICTURE"),;                      
                       Getsx3cache(_aCamposTrb[_nI],"X3_TAMANHO"),;
                       Getsx3cache(_aCamposTrb[_nI],"X3_DECIMAL"),;                      
                       Getsx3cache(_aCamposTrb[_nI],"X3_VALID"  ),;                      
                                      "",;                      
                       Getsx3cache(_aCamposTrb[_nI],"X3_TIPO"   ),;                      
                                      "",;                      
                                      "" })
    Aadd(aSemSX3, {_aCamposTrb[_nI],;                      
                    Getsx3cache(_aCamposTrb[_nI],"X3_TIPO"),;                      
                    Getsx3cache(_aCamposTrb[_nI],"X3_TAMANHO"),;                   
                    Getsx3cache(_aCamposTrb[_nI],"X3_DECIMAL")})	

    IF _aCamposTrb[_nI] $ "ZZI_NIVEL2/ZZI_NIVE2D"
       LOOP
    ENDIF

    IF _aCamposTrb[_nI] = "ZZI_TIPO"
       AADD(aTB_Campos,{{|| IF((cAliasWK)->ZZI_TIPO="1","Investimento Nivel 1",IF((cAliasWK)->ZZI_TIPO="2",;
                                                      "Investimento Nivel 2",;
                                                      "Investimento Nivel 3")) },,"Tipo",;
                                                      ""})
    ELSE
       AADD(aTB_Campos,{_aCamposTrb[_nI],,Trim(Getsx3cache(_aCamposTrb[_nI],"X3_TITULO")),;
                                               Getsx3cache(_aCamposTrb[_nI],"X3_PICTURE")})
    ENDIF
Next
_oTemp:= FWTemporaryTable():New( cAliasWK, aSemSX3 )

IF LEFT(M->ZZI_TIPO,1) = "1"
   _oTemp:AddIndex( "01", {"ZZI_CHAVE","ZZI_NIVEL2","ZZI_CODINV"} )
   _oTemp:AddIndex( "02", {"ZZI_CODINV"} )
ELSE
   _oTemp:AddIndex( "01", {"ZZI_CODINV"} )
EndIf

_oTemp:Create()

If _nOpc <> 2
   aDarGets:= NIL 
ElseIf _nOpc = 2 // VISUAL
   _bOk    := {|| .T.}
   aDarGets:= {}
EndIf

IF LEFT(M->ZZI_TIPO,1) = "1"
   ZZI->(DBSETORDER(3))//ZZI_FILIAL+ZZI_INVPAI
   IF ZZI->(DBSEEK(xFilial() + M->ZZI_CODINV ))
      DO WHILE ZZI->(!EOF()) .AND. xFilial("ZZI")+M->ZZI_CODINV == ZZI->ZZI_FILIAL+ZZI->ZZI_INVPAI
		   (cAliasWK)->(DBAPPEND())
         AVREPLACE("ZZI",cAliasWK)
         (cAliasWK)->REC_ZZI:=ZZI->(RECNO())
         ZZI->(DBSKIP())
      ENDDO        
   ENDIF
ELSEIF LEFT(M->ZZI_TIPO,1) = "2"
   ZZI->(DBSETORDER(4))//ZDA_FILIAL+M->ZZI_NIVEL2
   IF ZZI->(DBSEEK(xFilial() + M->ZZI_CODINV  ))
      DO WHILE ZZI->(!EOF()) .AND. xFilial("ZZI")+M->ZZI_CODINV  == ZZI->ZZI_FILIAL+ZZI->ZZI_NIVEL2
		   (cAliasWK)->(DBAPPEND())
         AVREPLACE("ZZI",cAliasWK)
         (cAliasWK)->REC_ZZI:=ZZI->(RECNO())
         ZZI->(DBSKIP())
      ENDDO        
   ENDIF		
ENDIF

_aCores := {}
aAdd(_aCores,{"(cAliasWK)->ZZI_MSBLQL == '1'","BR_VERMELHO"})   
aAdd(_aCores,{"(cAliasWK)->ZZI_TIPO   == '2'","BR_AZUL"    })
aAdd(_aCores,{"(cAliasWK)->ZZI_TIPO   == '3'","BR_AMARELO" })
aAdd(_aCores,{"(cAliasWK)->ZZI_TIPO   == ' '","BR_PRETO"   })

Do While .T.
	nOpca:=0
	aCoors:= FWGetDialogSize(oMainWnd)
	oMainWnd:ReadClientCoords()//So precisa declarar uma fez para o Programa todo
	Define MSDialog oDlg Title "Cadastro de Investimentos" From aCoors[1],aCoors[2] To aCoors[3],aCoors[4] OF oMainWnd Pixel
		nLinha :=Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/2.5)-50

		(cAlias)->(DBGOTO(_nRec))
		//MsmGet(): New (   [ cAlias], uPar2,nOpc>,,,, [ aAcho]    , [ aPos]                             ,[ aCpos],nModelo, [ uPar11], [ uPar12], [ uPar13], [ oWnd], [ lF3], [ lMemoria], [ lColumn], [ caTela], [ lNoFolder], [ lProperty], [ aField], [ aFolder], [ lCreate], [ lNoMDIStretch], [ uPar25] )																												,,,,,,,   ,,.T.)
		oEnCh1:=MsMget():New( cAlias ,_nRec ,_nOpc,,,,aCamposMostra,{15,1,nLinha,(oDlg:nClientWidth-4)/2},aDarGets,1      )  

		(cAliasWK)->(DBGoTop())
		oMark:=MSSELECT():New(cAliasWK,"TRBF_OK","ZZI_TIPO =' '",aTB_Campos,.F.,@cMarca,{nLinha+1,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2},,,,,_aCores)
   	oMark:bMark := {|| ACOM03Mark(oMark,cAliasWK,oEnCh1)}
       
	Activate MSDialog oDlg ON INIT ( EnchoiceBar(oDlg, {|| IF(Eval(_bOk),(nOpca:=1,oDlg:End()),) } ,;
                                                      {|| (nOpca:=0,oDlg:End()) },,_aBotoes) ,;
                                    oEnCh1:oBox:Align:=CONTROL_ALIGN_TOP ,;
                                    oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT ,;
                                    oMark:oBrowse:Refresh() )
	If nOpca = 1 .AND. _nOpc <> 2
      //===============  Atualizar aqui a Work.
      
      If _nOpc == 4
         _nRegAtu := ZZI->(Recno())

         (cAliasWK)->(DbGoTop())
         Do While ! (cAliasWK)->(Eof())
            ZZI->(DbGoTo((cAliasWK)->REC_ZZI))

            ZZI->(RecLock("ZZI",.F.))
            ZZI->ZZI_DTINIC := (cAliasWK)->ZZI_DTINIC
            ZZI->ZZI_DTFIM  := (cAliasWK)->ZZI_DTFIM
            ZZI->(MsUnLock())

            (cAliasWK)->(DbSkip())
         EndDo 

         ZZI->(DbGoTo(_nRegAtu))
      EndIf 

      ZZI->(RECLOCK("ZZI",.F.)) 
      AVREPLACE("M", "ZZI") 
	   IF U_ACOM03Wrkf("GRVA")
         ZZI->(MSUNLOCK()) 
			Exit
      ENDIF
      ZZI->(MSUNLOCK()) 
		If SELECT(cAliasWK) # 0
			Loop
		Else//Se o TRB For fechado erroniamente
			Exit
		EndIf         
	EndIf

	Exit

EndDo

If SELECT(cAliasWK) # 0
   _otemp:delete()
EndIf

Return .T.               

/*
===============================================================================================================================
Programa--------: ACOM03Tela()
Autor-----------: Alex Walaluer
Data da Criacao-: 29/03/2021
Descrição-------: Tela de capa e detalhe
Parametros------:  oMark,cAliasWK,oEnCh1
Retorno---------: .t.
===============================================================================================================================
*/
STATIC Function ACOM03Mark(oMark,cAliasWK,oEnCh1)
Local _oDlg
Local _nOpcao   := 00
Local _nLinha   := 05
Local _nPula    := 20
Local _nTam     := 50
Local _nCol1    := 10
Local _nCol2    := _nCol1+40
Local _cTit	    := "ALTERA OU EXCLUI LINHA DO INVENSTIMENTO"
Local _bValid   := {|| IF(_dDT_Fim >= _dDT_Ini,.T.,(U_ITMSG("Periodo INVALIDO",'Atenção!',"Tente novamente com outro periodo",3),.F.) ) }
Local _bOK      := {|| (If(EVAL(_bValid) ,(_nOpcao:=1,_oDlg:End()),))  }
Local _cInv     := (cAliasWK)->ZZI_CODINV+" - "+ALLTRIM((cAliasWK)->ZZI_DESINV)
Local _cCodigo  := (cAliasWK)->ZZI_CODINV//CODIGO DA LINHA ATUAL
Local _cNivel2  := (cAliasWK)->ZZI_NIVEL2
LOCAL _nRecAtuWR:= (cAliasWK)->(RECNO())
LOCAL _nRecAtual:= ZZI->(RECNO())
PRIVATE _nValor := (cAliasWK)->ZZI_VLRPRV
PRIVATE _dDT_Ini:= (cAliasWK)->ZZI_DTINIC 
PRIVATE _dDT_Fim:= (cAliasWK)->ZZI_DTFIM
PRIVATE _cBloq  := (cAliasWK)->ZZI_MSBLQL

DO While .T.

   _lOK   := .F.
   _nLinha:= 05

   Define MSDialog _oDlg Title _cTit From 000,000 To 280,480 Pixel
   
    @ _nLinha,_nCol1       Button "Gravar Alteracao" Size 55,15 Action (EVAL(_bOK)) OF _oDlg Pixel
    @ _nLinha,(_nCol1+060) Button "Excluir Linha"    Size 55,15 Action (_nOpcao:=2,_oDlg:End()) OF _oDlg Pixel
    @ _nLinha,(_nCol1+120) Button "CANCELAR"         Size 55,15 Action (_nOpcao:=0,_oDlg:End()) OF _oDlg Pixel
      _nLinha+=_nPula
					
    @ _nLinha, _nCol1 SAY "Investimento" SIZE 160,010  OF _oDlg PIXEL 
    @ _nLinha, _nCol2 MSGET _cInv  PICTURE "@!" SIZE 140,008 OF _oDlg PIXEL WHEN .F.
      _nLinha+=_nPula

    @ _nLinha+1, _nCol1 SAY "Valor Previsto" SIZE 060,010  OF _oDlg PIXEL 
    @ _nLinha  , _nCol2 MSGET _nValor  PICTURE PesqPict("ZZI","ZZI_VLRPRV") SIZE _nTam,008 OF _oDlg PIXEL VALID (NaoVazio(_nValor) .AND. Positivo(_nValor)) 
      _nLinha+=_nPula

    @ _nLinha+1, _nCol1 SAY "Data Inicial" SIZE 060,010  OF _oDlg PIXEL 
    @ _nLinha  , _nCol2 MSGET _dDT_Ini  PICTURE "@D" SIZE _nTam,008 OF _oDlg PIXEL VALID NaoVazio(_dDT_Ini)
      _nLinha+=_nPula

    @ _nLinha+1, _nCol1 SAY "Data Final" SIZE 060,010  OF _oDlg PIXEL 
    @ _nLinha  , _nCol2 MSGET _dDT_Fim  PICTURE "@D" SIZE _nTam,008 OF _oDlg PIXEL VALID NaoVazio(_dDT_Ini)
      _nLinha+=_nPula

    @ _nLinha+1, _nCol1 SAY "Bloquear" SIZE 060,010  OF _oDlg PIXEL 
    @ _nLinha  , _nCol2 MSCOMBOBOX _cBloq ITEMS {"1=Sim","2=Não"} SIZE 050, 010 OF _oDlg PIXEL Valid {|| Pertence('12')} 
      _nLinha+=_nPula

   Activate MSDialog _oDlg Centered

   If _nOpcao = 1

      (cAliasWK)->TRBF_OK:=cMarca

      M->ZZI_VLRPRV:=(M->ZZI_VLRPRV - (cAliasWK)->ZZI_VLRPRV + _nValor )//ACERTA O NIVEL da capa
      ZZI->(RECLOCK("ZZI",.F.)) 
      ZZI->ZZI_VLRPRV:=M->ZZI_VLRPRV //EFETIVA A CAPA PQ O USUARIO PODE CANCELAR
      ZZI->(MSUNLOCK()) 

      _nSalvaValor:=(cAliasWK)->ZZI_VLRPRV

      (cAliasWK)->ZZI_VLRPRV:=_nValor 
      (cAliasWK)->ZZI_DTINIC:=_dDT_Ini
      (cAliasWK)->ZZI_DTFIM :=_dDT_Fim
      (cAliasWK)->ZZI_MSBLQL:=_cBloq
      
      ZZI->(DBGOTO((cAliasWK)->REC_ZZI))
      ZZI->(RECLOCK("ZZI",.F.)) 
      ZZI->ZZI_VLRPRV:=_nValor 
      ZZI->ZZI_DTINIC:=_dDT_Ini
      ZZI->ZZI_MSBLQL:=_cBloq
      ZZI->ZZI_DTFIM :=_dDT_Fim
      ZZI->(MSUNLOCK()) 

      IF LEFT(M->ZZI_TIPO,1) = "1" .AND. (cAliasWK)->ZZI_TIPO = "3" 
         (cAliasWK)->(DBSETORDER(2))
         IF (cAliasWK)->(DBSEEK( _cNivel2  ))//Vai no N2 do N3 para acertar o valor
            (cAliasWK)->ZZI_VLRPRV:=((cAliasWK)->ZZI_VLRPRV - _nSalvaValor + _nValor )//ACERTA NO NIVEL 2
            ZZI->(DBGOTO((cAliasWK)->REC_ZZI))
            ZZI->(RECLOCK("ZZI",.F.)) 
            ZZI->ZZI_VLRPRV:=(ZZI->ZZI_VLRPRV - _nSalvaValor + _nValor )//ACERTA NO NIVEL 2
            ZZI->(MSUNLOCK()) 
         ENDIF
      ENDIF
      (cAliasWK)->(DBGOTO(_nRecAtuWR))//POSICIONA DE VOLTA NO NIVEL DA LINHA NO TRB
      U_ITMSG("DADOS GRAVADOS COM SUCESSO","Atenção",,2)

   ELSEIf _nOpcao = 2 

      ZZI->(DBGOTO((cAliasWK)->REC_ZZI))//Posiciona no ZZI da linha do TRB para validar se tá em alguma SC
      IF !U_ACOM003E(.T.)
         EXIT
      ENDIF

      (cAliasWK)->TRBF_OK:=cMarca

      M->ZZI_VLRPRV:=(M->ZZI_VLRPRV - (cAliasWK)->ZZI_VLRPRV )//ACERTA O NIVEL da capa
      ZZI->(RECLOCK("ZZI",.F.)) 
      ZZI->ZZI_VLRPRV:=M->ZZI_VLRPRV //EFETIVA A CAPA PQ O USUARIO PODE CANCELAR
      ZZI->(MSUNLOCK()) 

      IF LEFT(M->ZZI_TIPO,1) = "1" .AND. (cAliasWK)->ZZI_TIPO = "3"
         (cAliasWK)->(DBSETORDER(2))
         IF (cAliasWK)->(DBSEEK( _cNivel2  ))//Vai no N2 do N3 para acertar o valor
            (cAliasWK)->ZZI_VLRPRV:=(ZZI->ZZI_VLRPRV - (cAliasWK)->ZZI_VLRPRV )//ACERTA O VALOR NO NIVEL 2 DO N3
            ZZI->(DBGOTO((cAliasWK)->REC_ZZI))
            ZZI->(RECLOCK("ZZI",.F.)) 
            ZZI->ZZI_VLRPRV:=(ZZI->ZZI_VLRPRV - (cAliasWK)->ZZI_VLRPRV )//ACERTA O VALOR NO NIVEL 2 DO N3
            ZZI->(MSUNLOCK()) 
         ENDIF		
      ELSEIF LEFT(M->ZZI_TIPO,1) = "1" .AND. (cAliasWK)->ZZI_TIPO = "2" 
         (cAliasWK)->(DBSETORDER(2))
         DO WHILE (cAliasWK)->(DBSEEK( _cCodigo  )) .AND. (cAliasWK)->(!EOF())//Vai nos N3 para deletar
            ZZI->(DBGOTO((cAliasWK)->REC_ZZI))
            ZZI->(RECLOCK("ZZI",.F.)) 
            ZZI->(DBDELETE()) 
            ZZI->(MSUNLOCK()) 
            (cAliasWK)->(DBDELETE()) 
         ENDDO
      ENDIF

      (cAliasWK)->(DBGOTO(_nRecAtuWR))//POSICIONA DE VOLTA NO NIVEL DA LINHA NO TRB
      ZZI->(DBGOTO((cAliasWK)->REC_ZZI))
      ZZI->(RECLOCK("ZZI",.F.)) 
      ZZI->(DBDELETE()) 
      ZZI->(MSUNLOCK()) 

      (cAliasWK)->(DBDELETE()) //DELETA LINHA ATUAL

      U_ITMSG("DADOS EXCLUIDO COM SUCESSO","Atenção",,2)
      
      (cAliasWK)->(DBSETORDER(1))
      (cAliasWK)->(DBGOTOP())

   EndIf

   Exit

EndDo

ZZI->(DBSETORDER(1))
ZZI->(DBGOTO(_nRecAtual))//POSICIONA DE VOLTA NO NIVEL DO CADASTRO PARA ACERTO

oMark:oBrowse:Refresh()
oEnCh1:Refresh()
RETURN .T.

/*
===============================================================================================================================
Programa--------: ACOM03DT()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 25/11/2022
Descrição-------: Na alteração da data principal de inicio e fim, replica os valores para as datas dos níveis inferiores.
Parametros------: _cCampo = Campo que chamou a rotina
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function ACOM03DT(_cCampo)
Local _nRegAtu 

Begin Sequence 
   
   If _cCampo == "ZZI_DTINIC"
      _cRet := M->ZZI_DTINIC
   EndIf 

   If _cCampo == "ZZI_DTFIM"
      _cRet := M->ZZI_DTFIM
   EndIf 

   If ! ALTERA
      Break
   EndIf 

   If M->ZZI_TIPO <> "1"
      Break 
   EndIf 
   
   _nRegAtu := (cAliasWK)->(Recno())
   
   (cAliasWK)->(DbGoTop())
   Do While ! (cAliasWK)->(Eof())
      
      If (cAliasWK)->ZZI_DTINIC <> M->ZZI_DTINIC
         (cAliasWK)->ZZI_DTINIC := M->ZZI_DTINIC 
      EndIf 

      If (cAliasWK)->ZZI_DTFIM <> M->ZZI_DTFIM
         (cAliasWK)->ZZI_DTFIM := M->ZZI_DTFIM
      EndIf 
   
      (cAliasWK)->(DbSkip())
   EndDo 

   (cAliasWK)->(DbGoTo(_nRegAtu))
   
   oMark:oBrowse:Refresh()

End Sequence

Return _cRet
