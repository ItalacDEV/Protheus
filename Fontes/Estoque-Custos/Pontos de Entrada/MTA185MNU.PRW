/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: MTA185MNU
Autor-------------: Alex Wallauer
Data da Criacao---: 14/03/2019
===============================================================================================================================
Descrição---------: Ponto de entrada no MenuDef() do MATA185.PRX - Chamado 28444
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
User Function MTA185MNU()

LOCAL _nPos1:=ASCAN(aRotina, {|R| UPPER(R[2]) == UPPER("A185Estorn") } )
LOCAL _nPos2:=ASCAN(aRotina, {|R| UPPER(R[2]) == UPPER("A185Exclui") } )

IF _nPos1 # 0
   aRotina[_nPos1][2] := "U_MA185EST"
ENDIF

IF _nPos2 # 0
   aRotina[_nPos2][2] := "U_MA185EXC"
ENDIF

Return .T.
/*
===============================================================================================================================
Programa----------: MA185Est
Autor-------------: Alex Wallauer
Data da Criacao---: 14/03/2019
===============================================================================================================================
Descrição---------: Estona todos os itens de uma SA
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
User Function MA185Est(cAlias,nReg,nOpc)
                                                                                                //1    //2       //3
LOCAL _nOpcao:=AVISO('Atenção!', "Deseja Estornar TODOS os itens da SA ?"+CHR(13)+CHR(10)+"SIM: Estorna todos os Itens"+CHR(13)+CHR(10)+"NAO: Estona item posicionado", { "SIM", "NAO" , "Cancela"}, 2)

IF _nOpcao = 1//U_ITMSG("Deseja Estornar TODOS os itens da SA ?",'Atenção!',"SIM: Estorna todos os Itens"+CHR(13)+CHR(10)+"NAO: Estona item posicionado",2,2,2)
   FWMSGRUN(,{|oProc| MT185MSExec(cAlias,nReg,2,oProc) } , "Aguarde...", "Estornando SA: "+SCP->CP_NUM )//"Estorno"  2
ELSEIF _nOpcao = 2
   A185Estorn(cAlias,nReg,nOpc)
ENDIF
RETURN .T.
/*
===============================================================================================================================
Programa----------: MA185Est
Autor-------------: Alex Wallauer
Data da Criacao---: 14/03/2019
===============================================================================================================================
Descrição---------: Exclui todos os itens de uma SA
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
User Function MA185Exc(cAlias,nReg,nOpc)
                                                                                                //1    //2       //3
LOCAL _nOpcao:=AVISO('Atenção!', "Deseja Excluir TODOS os itens da SA ?"+CHR(13)+CHR(10)+"SIM: Exclui todos os Itens"+CHR(13)+CHR(10)+"NAO: Exclui item posicionado", { "SIM", "NAO" , "Cancela"}, 2)

IF _nOpcao = 1// U_ITMSG("Deseja Excluir TODOS os itens da SA ?",'Atenção!',"SIM: Exclui todos os Itens"+CHR(13)+CHR(10)+"NAO: Exclui item posicionado",2,2,2)
   FWMSGRUN(,{|oProc| MT185MSExec(cAlias,nReg,5,oProc) } , "Aguarde...", "Excluindo SA: "+SCP->CP_NUM )//"Excluir"  5
ELSEIF _nOpcao = 2
   A185Exclui(cAlias,nReg,nOpc)
ENDIF
RETURN .T.
/*
===============================================================================================================================
Programa----------: MA185Est
Autor-------------: Alex Wallauer
Data da Criacao---: 14/03/2019
===============================================================================================================================
Descrição---------: Exclui todos os itens de uma SA
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
STATIC Function MT185MSExec(cAlias,nReg,nOpcAuto,oProc)

LOCAL cNum:=SCP->CP_NUM 
LOCAL aCamposSCP
LOCAL aCamposSD3:= {{}}
LOCAL _aResult  := {}
LOCAL _cErro    := ""
//aRotina := {{STR0003,"A185Baixar" , 0 , 1,0,nil},;	//"Baixar"   1
//			  {STR0054,"A185Estorn"	, 0 , 2,0,nil},;	//"Estorno"  2
//			  {STR0004,"A185Exclui" , 0 , 5,0,nil},;	//"Excluir"  5
//			  {STR0037,"A185Encer"  , 0 , 6,0,nil}} 	//"Encerrar" 6 


SCP->(dbSetOrder(1))
If SCP->(dbSeek(xFilial("SCP")+cNum))

   BEGIN TRANSACTION

	DO WHILE SCP->(!EOF()) .AND. SCP->CP_FILIAL+SCP->CP_NUM == xFilial("SCP")+cNum

       aCamposSCP:={{"CP_NUM"  ,SCP->CP_NUM  ,Nil},;
                    {"CP_ITEM" ,SCP->CP_ITEM ,Nil},;
                    {"CP_QUANT",SCP->CP_QUANT,Nil}}

       lMsErroAuto := .F.
	   oProc:ccaption := ("Processando Item: " + SCP->CP_ITEM )
       ProcessMessages()

       MSExecAuto({|v,x,y,z| mata185(v,x,y,z)},aCamposSCP,aCamposSD3,nOpcAuto) // "Estorno"  2 / "Excluir"  5
	
	   If lMsErroAuto 
	      _cErro:=(MostraErro(GetTempPath()))
	      AADD( _aResult , { SCP->CP_PRODUTO ,SCP->CP_ITEM , StrTran(_cErro,CHR(13)+CHR(10)," ") } )
//        DisarmTransaction()
       ELSE
	      AADD( _aResult , { SCP->CP_PRODUTO ,SCP->CP_ITEM , "Processado com sucesso"} )
       EndIf

       SCP->(DBSKIP())
       
    ENDDO

   END TRANSACTION

   _aButtons:={}
   AADD(_aButtons,{"BUDGET",{|| AVISO("PROBLEMA",oLbxAux:aArray[oLbxAux:nAt][3],{"Fechar"},3)  },"Erro", "Erro" }) //"Formas de Pagamento"
   If !Empty( _aResult ) .AND. !EMPTY(_cErro)
//                 _cTitAux                             , _aHeader                       , _aCols   , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _aButtons
	  U_ITListBox( 'Status do Processamento SA: '+cNum  , { 'ITEM', "PRODUTO" , 'ERRO' } , _aResult , .T.      , 1      ,          ,          ,         ,         ,     ,        , _aButtons)
   ELSE
      bBloco:={|| U_ITListBox( 'Status do Processamento SA: '+cNum  , { 'ITEM', "PRODUTO" , 'OBSERVACAO' } , _aResult , .F.,1) }
	  U_ITMSG( 'O PROCESSAMENTO FOI CONCLUIDO CON SUCESSO.' , 'ATENCAO!' ,,2,,,,,,bBloco )
   ENDIF

EndIf 

SCP->(DBGOTO(nReg))

RETURN .T.