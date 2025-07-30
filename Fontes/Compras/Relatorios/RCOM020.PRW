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
Programa----------: RCOM020
Autor-------------: Alex Wallauer
Data da Criacao---: 20/06/2022
Descricao---------: Relatorio de Ultima de Compra de Fonecedores / Produtos - CHAMADO 40480
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RCOM020()
Local _aParRet :={}
Local _aParAux :={}  , nI
Local _bOK     :={|| IF( LEN(ALLTRIM(MV_PAR01)) >= 10 .OR. LEN(ALLTRIM(MV_PAR02)) >= 11 .OR. LEN(ALLTRIM(MV_PAR03)) >= 4 ,.T.,(U_ITMSG("Parametros invalidos!",'Atencao',"Digite um fornecedor+loja ou um produto valido",3),.F.) ) }
_aItalac_F3:={}

_cSelSA2:="SELECT A2_COD,A2_LOJA,A2_NREDUZ FROM "+RETSQLNAME("SA2")+" SA2 WHERE D_E_L_E_T_ = ' ' AND SUBSTR(A2_COD,1,1) = 'F' AND A2_COD <> 'F00001'  ORDER BY A2_COD, A2_LOJA "
//Italac_F3:={}         1           2         3                                   4             5            6             7         8             9         10         11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave                         , _nCpoDesc     ,_bCondTab , _cTitAux      , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR01"   ,_cSelSA2,{|Tab|(Tab)->A2_COD+(Tab)->A2_LOJA},{|Tab| (Tab)->A2_NREDUZ}, ,"Fornecedores" ,          ,          ,20        ,.F.        ,       , } )
//AADD(_aItalac_F3,{"MV_PAR02"   ,_cSelSB1,{|Tab|(Tab)->B1_COD}               ,{|Tab|(Tab)->B1_DESC}   , ,"Produtos"     ,          ,          ,20        ,.F.        ,       , } )

MV_PAR01:=SPACE(200)
MV_PAR02:=SPACE(200)
MV_PAR03:=SPACE(200)
_lTrazBloqueados:=.T.

AADD( _aParAux , { 1 , "Fornecedores"  , MV_PAR01, "@!"  , ""  ,"F3ITLC", "" , 100 , .F. } ) 
AADD( _aParAux , { 1 , "Produtos"      , MV_PAR02, "@!"  , ""  ,"SB1ADD", "" , 100 , .F. } ) 
AADD( _aParAux , { 1 , "Grupos"        , MV_PAR03, "@!"  , ""  ,"LSTGRP", "" , 100 , .F. } ) //SBMLIS == >LSTGRP


For nI := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nI][03] )
Next nI
          //aParametros, cTitle                                                    , @aRet    ,[bOk], [ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ] 
IF !ParamBox( _aParAux , "Relatorio de Ultima de Compra de Fonecedores / Produtos" , @_aParRet, _bOK, /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
    RETURN .F.
EndIf

U_ITLOGACS( "RCOM020" )

SET DATE FORMAT TO "DD/MM/YYYY"

cTimeInicial:=TIME()

FWMSGRUN( ,{|oProc|   RCOM020R(oProc) } , "Hora Inicial: "+cTimeInicial+", Aguarde...",  )

SET DATE FORMAT TO "DD/MM/YY"

Return


/*
===============================================================================================================================
Programa----------: RCOM020R
Autor-------------: Alex Wallauer
Data da Criacao---: 20/06/2022
Descrição---------: Selecao de dados
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function  RCOM020R(oProc)
Local cQry1		:= ""
LOCAL _cAlias  := GetNextAlias()

oProc:cCaption :=  "Selelecionado Dados, Aguarde... "
ProcessMessages()

cQry1 += " SELECT DISTINCT P.C7_FILIAL, P.C7_PRODUTO, B1.B1_DESC, P.C7_EMISSAO, P.C7_FORNECE, P.C7_LOJA, A2_NOME, P.C7_CONTATO, A2_EMAIL, A2_DDD, A2_TEL "
cQry1 += " FROM  " + RetSqlName("SC7") + "  P "
cQry1 += " JOIN  " + RetSqlName("SA2") + " A2 ON C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA "
cQry1 += " JOIN  " + RetSqlName("SB1") + " B1 ON C7_PRODUTO = B1_COD "
cQry1 += " WHERE C7_NUM IN ( SELECT MAX(C7_NUM)  FROM  " + RetSqlName("SC7") + " M WHERE M.D_E_L_E_T_ = ' '  "
cQry1 += "                                                        AND M.C7_FILIAL  = P.C7_FILIAL"
cQry1 += "                                                        AND M.C7_PRODUTO = P.C7_PRODUTO )"
cQry1 += " AND P.C7_FILIAL = '"+cFilAnt+"' "
IF !EMPTY(MV_PAR01)
   cQry1 += " AND P.C7_FORNECE||P.C7_LOJA IN "+FormatIn(ALLTRIM(MV_PAR01),";")
ENDIF
IF !EMPTY(MV_PAR02)
   cQry1 += " AND P.C7_PRODUTO IN "+FormatIn(ALLTRIM(MV_PAR02),";")
ENDIF
IF !EMPTY(MV_PAR03)
   cQry1 += " AND SUBSTR(P.C7_PRODUTO,1,4) IN "+FormatIn(ALLTRIM(MV_PAR03),";")
ENDIF
cQry1 += " AND P.D_E_L_E_T_ = ' ' AND A2.D_E_L_E_T_ = ' ' AND B1.D_E_L_E_T_ = ' '  "

cQry1 += " ORDER BY P.C7_FILIAL, P.C7_PRODUTO, P.C7_FORNECE, P.C7_LOJA
cQry1 := ChangeQuery(cQry1)

MPSysOpenQuery( cQry1, _cAlias ) 

nTotal:=nConta:=0
dbSelectArea(_cAlias)
COUNT TO nTotal
(_cAlias)->(dbGoTop())
_aDados:={}
nTotal:=ALLTRIM(STR(nTotal))
nTam:=LEN(nTotal)
SCR->(DBSETORDER(1))

cQryRec := "SELECT D3_CC FROM " + RetSqlName("SD3") + " SD3 WHERE SD3.R_E_C_N_O_ IN ( 
cQryRec += "   SELECT MAX(D3.R_E_C_N_O_) REC_SD3 "//ULTIMO CC DENTRO DA MAIOR RECNO
cQryRec += "          FROM " + RetSqlName("SD3") + " D3 "
cQryRec += "          WHERE D3.D_E_L_E_T_ = ' ' AND D3.D3_TM = '560' AND D3_ESTORNO <> 'S' AND D3.D3_FILIAL = '"+cFilAnt+"' "
_aCC:={}
DO While !(_cAlias)->(Eof())

   nConta++
   oProc:cCaption :=  "Lendo "+STRZERO(nConta,nTam)+" de "+nTotal+", Produto: "+(_cAlias)->C7_PRODUTO
   ProcessMessages()

     //******************  MAIOR REC
	   IF (nPos:=ASCAN( _aCC,{|C| C[1] == (_cAlias)->C7_PRODUTO  } ) ) = 0

	      cQry := " AND D3.D3_COD = '"+(_cAlias)->C7_PRODUTO+"' ) "
      
         MPSysOpenQuery( ChangeQuery(cQryRec + cQry), "TRB_REC" ) 

         _cCusto:=TRB_REC->D3_CC

         AADD( _aCC, { (_cAlias)->C7_PRODUTO , _cCusto })

	      TRB_REC->(DbCloseArea())
      ELSE
         _cCusto:= _aCC[nPos,2]
	   ENDIF
    //******************  MAIOR REC

//C7_FILIAL, C7_PRODUTO, B1_DESC, C7_EMISSAO, C7_FORNECE, C7_LOJA, A2_NOME, C7_CONTATO, A2_EMAIL, A2_DDD, A2_TEL

   _aItens:={}
   AADD(_aItens,(_cAlias)->C7_FILIAL ) 
   AADD(_aItens,(_cAlias)->C7_PRODUTO) 
   AADD(_aItens,(_cAlias)->B1_DESC   ) 
   AADD(_aItens,DTOC( STOD( (_cAlias)->C7_EMISSAO) )) 
   AADD(_aItens,(_cAlias)->C7_FORNECE+(_cAlias)->C7_LOJA ) 
   AADD(_aItens,(_cAlias)->A2_NOME   ) 
   AADD(_aItens,(_cAlias)->C7_CONTATO) 
   AADD(_aItens,(_cAlias)->A2_EMAIL  ) 
   AADD(_aItens,(_cAlias)->A2_DDD    ) 
   AADD(_aItens,(_cAlias)->A2_TEL    ) 
   AADD(_aItens,_cCusto+" - "+Posicione("CTT",1,xFilial("CTT") + _cCusto,"CTT_DESC01")   ) 
   AADD(_aDados,_aItens)
	(_cAlias)->(dbSkip())
ENDDO

IF LEN(_aDados) = 0 
    U_ITMSG("Nao ha dados para essa selecao",'Atencao!',,3)
ENDIF

DO WHILE LEN(_aDados) > 0 
   _aTit:={}
   _aSiz:={}

   AADD(_aTit,'Filial') 
   AADD(_aSiz,15)
   AADD(_aTit,'Produto')
   AADD(_aSiz,15)
   AADD(_aTit,'Descricao')
   AADD(_aSiz,30)
   AADD(_aTit,'Emissao')
   AADD(_aSiz,15)
   AADD(_aTit,'Fornecedor+Loja')
   AADD(_aSiz,15)
   AADD(_aTit,'Descricao')
   AADD(_aSiz,30)
   AADD(_aTit,'Contato')
   AADD(_aSiz,30)
   AADD(_aTit,'E-Mail')
   AADD(_aSiz,30)
   AADD(_aTit,'DDD')
   AADD(_aSiz,15)
   AADD(_aTit,'Telefone')
   AADD(_aSiz,20)
   AADD(_aTit,'Centro de Custo Ult. Baixa')
   AADD(_aSiz,50)

   _cTitulo:="Relatorio de Ultima de Compra de Fonecedores / Produtos"

   _cMsgTop:="Produtos encontradas - H.I.: "+cTimeInicial+" H.F.: "+TIME()+" Par. 1 : "+ALLTRIM(MV_PAR01)+"; Par. 2 : "+ALLTRIM(MV_PAR02)
   
   bOk:={|| IF(U_ITMSG("Confirma Gerar EXCEL ?",'Atencao!',,2,2,2) , DlgToExcel( { { "ARRAY" , _cTitulo , _aTit , _aDados } } )  ,.F. )   }

   //                           , _aCols  ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons )
   U_ITListBox(_cTitulo,_aTit,_aDados  , .T.    , 3    ,_cMsgTop,          ,_aSiz   ,         , bOk ,        , )
                                                                                                  

   IF  !U_ITMSG("Confirma Sair ?",'Atencao!',,3,2,2)
       LOOP
   ENDIF

    EXIT

ENDDO

Return
