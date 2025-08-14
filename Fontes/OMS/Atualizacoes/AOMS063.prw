/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 06/11/2018 | Validação planilha importação de metas de vendas - Chamado 26886
 Julio Paz        | 04/02/2019 | Correções de erro log com a utilização da função GDDeleted(). Chamado 27917.
 Lucas Borges     | 14/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
========================================================================================================================================================================
Analista    - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
========================================================================================================================================================================
Andre       - Alex Wallauer - 09/05/25 -          - 50460   - Ajsutes para o novo layout de integração de dados dos vendedores via CSV.
==============================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "RWMAKE.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "vKey.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE 'protheus.ch'

/*
===============================================================================================================================
Programa----------: AOMS063
Autor-------------: Erich Buttner
Data da Criacao---: 11/04/2013
Descrição---------: Cadastro de Metas de Vendas
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS063()
 Local _bBotaoImp  as codeblock
 Local _bBotaoExc  as codeblock
 Local _bBotaoI    as codeblock
 Local _bBotaoY    as codeblock
 Local _bBotaoC    as codeblock
 Local _bBotaoZ    as codeblock
 Local _bBotaoG    as codeblock
 Local nI    := 0  as Numeric
 Local _aParAux    := {} as Array
 Local _aParRet    := {} as Array
 Private aCpoBrw   := {} as Array
 Private aCpoTmp   := {} as Array
 Private cArq      := "" as Character
 Private cPesq     := Space(50) as Character
 Private lCheck1   := .t. as Logical
 Private lCheck2   := .t. as Logical
 Private lCheck3   := .t. as Logical
 Private _cOrdem   := "Ano+Mes+Nome" as Character
 Private aOrdem	   := {"Ano+Mes+Nome","Coord./Vend.+Ano+Mes","Nome Coord./Vend."} as Array
 Private cPESQUISA := SPACE(200) as Character
 Private cAnoMes   := "" as Character
 Private cCoord    := "" as Character
 Private _cUserName:= UsrFullName(RetCodUsr()) as Character
 Private _nLB      := 20 as Numeric
 Private _nMSS     := 24 as Numeric
 Private cChama    := "RECARREGA" as Character
 Private aSize     := {} as Array
 Private aObjects  := {} as Array
 Private aInfo     := {} as Array
 Private aPosObj   := {} as Array
 Private _cAnoIni  := LEFT(DTOS(dDataBase),6) as Character
 Private _cAnoFim  := LEFT(DTOS(dDataBase),6) as Character
 Private oPesquisa as Object
 Private _oTemp    As Object
 Private lGravouDados:=.F. as Logical

 MV_PAR01:=LEFT(DTOS(dDataBase),6)
 MV_PAR02:=LEFT(DTOS(dDataBase),6)

 AADD( _aParAux , { 1 , "Ano-Mes Inicial:", MV_PAR01, "@R 9999-99","","","", 060 , .T. } )
 AADD( _aParAux , { 1 , "Ano-Mes Final:"  , MV_PAR02, "@R 9999-99","","","", 060 , .F. } )

 For nI := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nI][03] )
 Next nI

 IF !ParamBox( _aParAux , "Intervalo de Anos da Meta de Vendedores/Coordenadores" , @_aParRet, {|| .T. } )
    Return .F.
 EndIf

 _cAnoIni:=Left(Alltrim(MV_PAR01)+"000000",6)
 _cAnoFim:=Left(Alltrim(MV_PAR02)+"999999",6)

 IF !Empty(MV_PAR02) .and. _cAnoIni > _cAnoFim
  	U_ITMSG("Intervalo de Anos invalido.","Ano inicial dever ser menor ou igual ao ano final.",3)
    Return .F.
 EndIF

 _cAnoIni:=Alltrim(MV_PAR01)
 _cAnoFim:=Alltrim(MV_PAR02)

 _bBotaoImp:= {|| FwMsgRun( ,{|oProc| AOMS063K(oProc) } , TIME()+" - Processando..." , "Iniciando o processamento..." ) }
 _bBotaoExc:= {|| FwMsgRun( ,{|oProc| AOMS063N(oProc) } , TIME()+" - Processando..." , "Iniciando o processamento..." ) }
 _bBotaoY  := {|| FwMsgRun( ,{|oProc| AOMS063Y(oProc) } , TIME()+" - Processando..." , "Iniciando o processamento..." ) }
 _bBotaoI  := {|| FwMsgRun( ,{|oProc| AOMS063IM(oProc)} , TIME()+" - Processando..." , "Iniciando o processamento..." ) }
 _bBotaoC  := {|| FwMsgRun( ,{|oProc| AOMS063C(oProc) } , TIME()+" - Processando..." , "Iniciando o processamento..." ) }
 _bBotaoZ  := {|| FwMsgRun( ,{|oProc| AOMS063Z(oProc) } , TIME()+" - Processando..." , "Iniciando o processamento..." ) }
 _bBotaoG  := {|| FwMsgRun( ,{|oProc| AOMS063G(oProc) } , TIME()+" - Processando..." , "Iniciando o processamento..." ) }

 AOMS063TT()//Prepara variaveis de tamanho de tela aSize,aObjects,aInfo,aPosObj

 Do While cChama != "SAIR"

    nLinha:=15
    nCol1:=13
    nColB:=05
    nLar1:=75
    nAlt1:=15
    nAlt2:=15

    IF cChama = "RECARREGA"
       FwMsgRun( ,{|oProc| AOMS063U(oProc) }, 'Aguarde!' , 'Carregando os dados...'  ) //CARREGA O aCols
    ENDIF

    cChama := "SAIR"
    @ aSize[7],000 TO aSize[6],aSize[5] DIALOG oDlgLib TITLE " Metas de Vendas "

    oMark:=MsSelect():New("TMP","",,aCpoBrw,.T.,"XX",{040,005,aSize[4]-_nMSS,aSize[3]},,,,,)
    oMark:oBrowse:lHasMark := .T.
    oMark:oBrowse:lCanAllMark:=.T.

    @ 003,006 To 034,315 Title " Metas / Ordem "

    @ nLinha,nCol1 ComboBox _cOrdem ITEMS aOrdem Size nLar1,nAlt1 Object oOrdem
    @ nLinha,090   Get      cPESQUISA            Size 00200,nAlt2 Object oPesquisa
    oOrdem:bChange := {|| AOMS063FO(_cOrdem),oMark:oBrowse:Refresh(.T.)}

    @ 015,330 Button "Pesquisar"       	    Size 55,13 Action AOMS063PC(_cOrdem) Object oBotao1
    @ 015,390 Button "Log"                  Size 55,13 Action AOMS063R(.T.)      Object oBotao2
    @ 015,450 Button "Manutenção % diario"  Size 80,13 Action AOMS063MD()        Object oBotao3

    //@ aSize[4]-_nLB,nColB Button "Exportar" Size 40,13 Action AOMS063E()// NÃO TEM MAIS POR ENQUANTO SEGUNDO VANDERLEI
    @ aSize[4]-_nLB,nColB Button "Importar"   Size 40,13 Action Eval(_bBotaoImp) Object oBotao3//AOMS063K( )
    nColB+=045
    @ aSize[4]-_nLB,nColB Button "Visualizar" Size 40,13 Action Eval(_bBotaoY)   Object oBotao4//AOMS063Y( ) 
    nColB+=045
    @ aSize[4]-_nLB,nColB Button "Incluir"    Size 40,13 Action Eval(_bBotaoI)   Object oBotao5//AOMS063IM( )
    nColB+=045
    @ aSize[4]-_nLB,nColB Button "Alterar"    Size 40,13 Action Eval(_bBotaoG)   Object oBotao8//AOMS063G( )
    nColB+=045
    @ aSize[4]-_nLB,nColB Button "Excluir"    Size 40,13 Action Eval(_bBotaoExc) Object oBotao9//AOMS063N( )
    nColB+=045
    @ aSize[4]-_nLB,nColB Button "Copiar"     Size 40,13 Action Eval(_bBotaoC)   Object oBotao6//AOMS063C( )
    nColB+=045
    @ aSize[4]-_nLB,nColB Button "Replicar"   Size 40,13 Action Eval(_bBotaoZ)   Object oBotao7//AOMS063Z( )
    nColB+=045
    @ aSize[4]-_nLB,nColB Button "Relatorio"  Size 40,13 Action AOMS063R(.F.)    Object oBotaoR
    nColB+=045
    @ aSize[4]-_nLB,nColB Button "Sair"       Size 40,13 Action (cChama:="SAIR",oDlgLIb:End()) Object oBotaoS

    ACTIVATE DIALOG oDlgLib CENTERED

    //Grava Log de execução da rotina
    U_ITLOGACS()

 Enddo

 If Select("TMP") > 0 .AND. TYPE("_oTemp") == "O"
    _oTemp:Delete()
 EndIf

Return

/*
===============================================================================================================================
Programa----------: AOMS063PC
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
Descrição---------: Pesquisa Informações no Browse de acordo com a Ordem selecionada
Parametros--------: _cOrdem - indice a ser usado
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063PC(_cOrdem)
 TMP->( DbSetOrder(Ascan(aOrdem,_cOrdem)) )
 TMP->( DbGoTop() )
 TMP->( MsSeek(AllTrim(cPesquisa),.T.) )
 oMark:oBrowse:Refresh(.T.)
Return

/*
===============================================================================================================================
Programa----------: AOMS063PC
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
Descrição---------: Funcao executada na saida do campo Ordem, para ordenar o browse
Parametros--------: _cOrdem - indice a ser usado
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063FO(_cOrdem)
 //Local _nReg:=Recno()
 cPesquisa:=Space(200)
 oPesquisa:Refresh()
 TMP->(DbSetOrder(Ascan(aOrdem,_cOrdem)))
 TMP->(DbGoTop())
 //TMP->(DbGoTo(_nReg))     //Mantendo no mesmo registro que estava posicionado anteriormente
 oMark:oBrowse:Refresh(.T.)
Return


/*
===============================================================================================================================
Programa----------: AOMS063TT
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
Descrição---------: Define tamanho da tela
Parametros--------: Nenhum
Retorno-----------: aposobj - array com linhas e colunas
===============================================================================================================================
*/
Static Function AOMS063TT()

 // Obtém a a área de trabalho e tamanho da dialog
 aSize := MsAdvSize()
 Aadd( aObjects, { 000, 000, .T., .T. } ) // Dados da Enchoice
 Aadd( aObjects, { 000, 000, .T., .T. } ) // Dados da getdados
 // Dados da área de trabalho e separação
 aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } // Chama MsObjSize e recebe array e tamanhos
 aPosObj := MsObjSize( aInfo, aObjects,.T.)

Return aPosObj

/*
===============================================================================================================================
Programa----------: AOMS063IM
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
Descrição---------: INCLUSÃO DE METAS DE VENDAS
Parametros--------: oProc - Objeto de processo
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063IM(oProc)

    Local cTitulo := "Inclusão de Metas de Vendas",_l
    Local lRetMod2:= .F. // Retorno da função Modelo2 - .T. Confirmou / .F. Cancelou
    Private nOpcx := 3

    nUsado:=0
    aHeader:={}
    aCols:={}

    //Carrega aheader
    aYesFields := {"ZZS_COD","ZZS_DESCR","ZZS_DESCD","ZZS_QTD","ZZS_UM","ZZS_QTD2UM","ZZS_2UM","ZZS_QTD3UM","ZZS_3UM","ZZS_VALOR"}
    FillGetDados(2,"ZZS",1,,,,, aYesFields ,,,, .T. ,,,,,, )

    //Limpa dois ultimos campos do aheader
    asize(aheader,Len(aheader)-2)

    cAnoMes:= Space(06)
    cCoord := Space(06)
    cNmCoor:= Space(60)
    cTipoor:= Space(25)

    aC:={}
    // aC[n,1] = Nome da Variavel Ex.:"cCliente"
    // aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
    // aC[n,3] = Titulo do Campo
    // aC[n,4] = Picture
    // aC[n,5] = Validacao
    // aC[n,6] = F3
    // aC[n,7] = Se campo e' editavel .t. se nao .f.

    //"Inclusão de Metas de Vendas"
    Aadd(aC,{"cAnoMes",{15,003}," Ano-Mes ","@R 9999-99",,,.T.})
    Aadd(aC,{"cCoord" ,{15,080}," Codigo " ,"@!","U_AOMS063V('CCOORD') .And. (ExistCPO('SA3'))","SA3",.T.})
    Aadd(aC,{"cNmCoor",{15,155}," Nome "   ,"@!",,,.F.})
    Aadd(aC,{"cTipoor",{30,003}," Tipo "   ,"@!",,,.F.})

    // Array com descricao dos campos do Rodape do Modelo 2
    aR:={}
    // aR[n,1] = Nome da Variavel Ex.:"cCliente"
    // aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
    // aR[n,3] = Titulo do Campo
    // aR[n,4] = Picture
    // aR[n,5] = Validacao
    // aR[n,6] = F3
    // aR[n,7] = Se campo e' editavel .t. se nao .f.

    aButtons := {}
    Aadd(aButtons,{"S4WB011N",	{||U_AOMS063D(cAnoMes,cCoord)},"Imp. Produtos","Imp. Produtos"})

    // Array com coordenadas da GetDados no modelo2
    aCGD:={60,06,26,74}
    ACORDW  := {ASIZE[7],0,ASIZE[6],ASIZE[5]}

    cLinhaOk:="U_AOMS063O()"
    cTudoOk :="U_AOMS063Z(.T.)"//"INCLUSÃO DE METAS DE VENDAS"

    // Chamada da Modelo2
    // lRetMod2 = .t. se confirmou
    // lRetMod2 = .f. se cancelou
    //                cTitulo [ aC ] [ aR ] [ aGd ] [ nOp ] [ cLinhaOk ] [ cTudoOk ]aGetsD [ bF4 ] [ cIniCpos ] [ nMax ] [ aCordW ] [lDelGetD ] [lMaximazed ] [ aButtons ]
    lRetMod2:=Modelo2(cTitulo,aC	,  aR	, aCGD	,nOpcx	,  cLinhaOk	,  cTudoOk ,	  ,		  ,		   		,  9999	,   ACORDW ,            ,    .T.      , aButtons  )

    cChama := "NÃO RECARREGAR" //Se Cancelou

    If lRetMod2 // Gravacao. . .
        lGravouDados:=.T.

        nPosProd:= Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_COD'} )
        nPosDesc:= Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCR'} )
        nPosDesD:= Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCD'} )
        nPosUM	:= Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_UM'} )
        nPosQtd	:= Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD'} )
        nPos2UM	:= Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_2UM'} )
        nPos2Qtd:= Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD2UM'} )
        nPos3UM	:= Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_3UM'   } )//Novo
        nPos3Qtd:= Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD3UM'} )//Novo
        nPosVal := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_VALOR' } )//Novo

        _cReg:=AllTrim(Str(Len(aCols)))
        _nCont:=0

        For _l := 1 To Len(aCols)

            _nCont++
            oProc:cCaption := ( "Incluindo Metas: " + StrZero(_nCont,5) + " de " + _cReg)
            ProcessMessages()

            If ! Atail(aCols[_l])

                ZZS->(RecLock("ZZS",.T.))//INCLUSAO1
                ZZS->ZZS_FILIAL	:= xFilial("ZZS")
                ZZS->ZZS_COD	:= aCols [_l,nPosProd]
                ZZS->ZZS_DESCR	:= aCols [_l,nPosDesc]
                ZZS->ZZS_DESCD	:= aCols [_l,nPosDesD]
                ZZS->ZZS_UM		:= aCols [_l,nPosUM]
                ZZS->ZZS_QTD   	:= aCols [_l,nPosQtd]
                ZZS->ZZS_2UM	:= aCols [_l,nPos2UM]
                ZZS->ZZS_QTD2UM	:= aCols [_l,nPos2Qtd]
                ZZS->ZZS_3UM	:= aCols [_l,nPos3UM] //Novo
                ZZS->ZZS_QTD3UM	:= aCols [_l,nPos3Qtd]//Novo
                ZZS->ZZS_VALOR  := aCols [_l,nPosVal] //Novo
                ZZS->ZZS_TIPOV  := POSICIONE("SA3",1,xFilial("SA3")+cCoord,"A3_I_TIPV")//Novo
                ZZS->ZZS_COOR	:= cCoord
                ZZS->ZZS_NMCOOR	:= cNmCoor
                ZZS->ZZS_ANOMES	:= cAnoMes
                ZZS->(MsUnLock())

                ZGW->(RecLock("ZGW",.T.))//INCLUSAO1
                ZGW->ZGW_FILIAL	:= xFilial("ZGW")
                ZGW->ZGW_COD	:= aCols[_l,nPosProd]
                ZGW->ZGW_DESCR	:= aCols[_l,nPosDesc]
                ZGW->ZGW_DESCD	:= aCols[_l,nPosDesD]
                ZGW->ZGW_UM		:= aCols[_l,nPosUM]
                ZGW->ZGW_QTD   	:= aCols[_l,nPosQtd]
                ZGW->ZGW_2UM	:= aCols[_l,nPos2UM]
                ZGW->ZGW_QTD2UM	:= aCols[_l,nPos2Qtd]
                ZGW->ZGW_3UM	:= aCols[_l,nPos3UM] //Novo
                ZGW->ZGW_QTD3UM	:= aCols[_l,nPos3Qtd]//Novo
                ZGW->ZGW_VALOR	:= ZZS->ZZS_VALOR    //Novo
                ZGW->ZGW_TIPOV	:= ZZS->ZZS_TIPOV    //Novo
                ZGW->ZGW_DATAM  := ZZS->ZZS_DATA     //Novo
                ZGW->ZGW_COOR	:= cCoord
                ZGW->ZGW_NMCOOR	:= cNmCoor
                ZGW->ZGW_ANOMES	:= cAnoMes
                ZGW->ZGW_OPER   := "INCLUSAO1"
                ZGW->ZGW_USER   := _cUserName
                ZGW->ZGW_DATA   := DATE()
                ZGW->ZGW_HORA   := TIME()
                ZGW->(MsUnLock())

                AOMS063Ger("GERAR_VALORES_POR_DATA",ZZS->ZZS_ANOMES)

            EndIf

        Next _l

        u_itmsg("Inclusão gravada com sucesso","Atenção",,2)

        cChama = "RECARREGA"
        oDlgLIb:End()

    Endif



Return .T.


/*
===============================================================================================================================
Programa----------: AOMS063W
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
Descrição---------: Importação de Produtos para Inclusão
Parametros--------: nPorc - Porcentagem de reajuste dos precos ,oProc - Objeto de processo
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS063W(nPorc,oProc)

 Local cPrd   := "" As Character
 Local _cAlias:= GetNextAlias() As Character
 Local aItens := {} As Array
 Local nY:=nX := 0  As Numeric
 Local nPosProd:= Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_COD'   } ) As Numeric
 Local nPosDesc:= Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCR' } ) As Numeric
 Local nPosDesD:= Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCD' } ) As Numeric
 Local nPosUM  := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_UM'    } ) As Numeric
 Local nPosQtd := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD'   } ) As Numeric
 Local nPos2UM := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_2UM'   } ) As Numeric
 Local nPos2Qtd:= Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD2UM'} ) As Numeric
 Local nPos3UM := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_3UM'   } ) As Numeric//Novo
 Local nPos3Qtd:= Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD3UM'} ) As Numeric//Novo

 oProc:cCaption := ( "Lendo Dados..." )
 ProcessMessages()

 cPrd := " SELECT D2_COD PRODUTO, B1_DESC DESCR, B1_I_DESCD DESCRDET,"
 cPrd += " ROUND((SUM(D2_QUANT  )/3)+((SUM(D2_QUANT  )/3)* '"+AllTrim(Str(nPorc))+ "'),2) QTDMEDIA1UM, "
 cPrd += " ROUND((SUM(D2_QTSEGUM)/3)+((SUM(D2_QTSEGUM)/3)* '"+AllTrim(Str(nPorc))+ "'),2) QTDMEDIA2UM,"
 cPrd += " D2_UM UM, D2_SEGUM SEGUM "
 cPrd += " FROM SD2010 SD2, SF2010 SF2, SB1010 SB1 "
 cPrd += " WHERE SF2.F2_EMISSAO > '"+DTOS(DATE()-90)+"' "
 cPrd += " AND SF2.D_E_L_E_T_ = ' ' "
 cPrd += " AND SD2.D_E_L_E_T_ = ' ' "
 cPrd += " AND SB1.D_E_L_E_T_ = ' ' "
 cPrd += " AND SB1.B1_FILIAL = ' ' "
 cPrd += " AND SD2.D2_COD = SB1.B1_COD "
 cPrd += " AND SD2.D2_FILIAL = SF2.F2_FILIAL "
 cPrd += " AND SD2.D2_DOC = SF2.F2_DOC "
 cPrd += " AND SD2.D2_SERIE = SF2.F2_SERIE "
 cPrd += " AND SD2.D2_CLIENTE = SF2.F2_CLIENTE "
 cPrd += " AND SD2.D2_LOJA = SF2.F2_LOJA "
 cPrd += " AND SF2.F2_FORMUL = ' ' "
 cPrd += " AND SF2.F2_TIPO = 'N' "
 cPrd += " AND (SF2.F2_VEND2 = '"+AllTrim(cCoord)+"' OR SF2.F2_VEND1 = '"+AllTrim(cCoord)+"') "
 cPrd += " AND SB1.B1_TIPO = 'PA' "
 cPrd += " AND SB1.B1_MSBLQL = '2' "
 cPrd += " GROUP BY D2_COD,B1_DESC, B1_I_DESCD, D2_UM, D2_SEGUM "
 cPrd += " ORDER BY D2_COD "
 //cPrd := ChangeQuery(cPrd)

 //==============================================
 // Monta Area de Trabalho executando a Query
 //==============================================
 MPSysOpenQuery( cPrd , _cAlias)

 aCols:={}

 Do While (_cAlias)->(!Eof())

    cProd   := (_cAlias)->PRODUTO
    cDescr  := (_cAlias)->DESCR
    cDescrD := (_cAlias)->DESCRDET
    cUM		:= (_cAlias)->UM
    nQtd	:= (_cAlias)->QTDMEDIA1UM
    c2UM	:= (_cAlias)->SEGUM
    nQtd2um	:= (_cAlias)->QTDMEDIA2UM
    Aadd(aItens,{cProd,cDescr,cDescrD,cUM,nQtd,c2UM,nQtd2um})
    (_cAlias)->(Dbskip())

 Enddo

 _cReg:=AllTrim(Str(Len(aItens)))
 _nCont:=0

 FOR nX:= 1 TO Len(aItens)

     _nCont++
     oProc:cCaption := ( "Lendo Item: " + StrZero(_nCont,5) + " de " + _cReg)
     ProcessMessages()

     Aadd(aCols,Array(Len(aHeader)+1))
     For nY	:= 1 To Len(aHeader)
         aCols[Len(aCols)][nY] := CriaVar(aHeader[nY][2])
     Next nY

     N := Len(aCols)
     aCols[N][Len(aCols[N])] := .F.

     aCols [N,nPosProd]:= aItens[nX][1]
     aCols [N,nPosDesc]:= Posicione("SB1",1,Xfilial("SB1")+aItens[nX][1],"B1_DESC")
     aCols [N,nPosDesD]:= SB1->B1_I_DESCD
     aCols [N,nPosUM]  := SB1->B1_UM
     aCols [N,nPosQtd] := aItens[nX][5]
     aCols [N,nPos2UM] := SB1->B1_SEGUM
     aCols [N,nPos2Qtd]:= aItens[nX][7]
     aCols [N,nPos3UM] := SB1->B1_I_3UM
     IF !EMPTY(SB1->B1_I_QT3UM)
        aCols [N,nPos3Qtd]:= (aItens[nX][5] / SB1->B1_I_QT3UM )
     EndIf

 Next nX
 (_cAlias)->(dbCloseArea())
 xObj := CallMod2Obj()
 xObj:oBrowse:Refresh()

Return .T.

/*
===============================================================================================================================
Programa----------: AOMS063O
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
Descrição---------: VALIDA LINHA DO aCols
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS063O()
 Local nPosQtd  := 0 As Numeric
 Local nPos2Qtd := 0 As Numeric
 Local nPosDesc := 0 As Numeric
 Local nPosDesD := 0 As Numeric
 Local nPosUM   := 0 As Numeric
 Local nPos2UM  := 0 As Numeric
 Local nPos3UM  := 0 As Numeric//Novo
 Local nPos3Qtd := 0 As Numeric//Novo
 Local nPosVal  := 0 As Numeric//Novo
 Local nQtd     := 0 As Numeric
 Local nQtd2UM  := 0 As Numeric
 Local nQtd3UM  := 0 As Numeric//Novo
 Local nPosProd := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_COD'} ) As Numeric
 Local xObj     := CallMod2Obj() As Object
 Local N        := xObj:oBrowse:nat As Numeric
 Local cProd    := aCols[N,nPosProd] As Character
 Local cbloq    := Posicione("SB1",1,Xfilial("SB1")+cProd,"B1_MSBLQL") As Character
 Local _lRet    := .T.

 if Atail(aCols[N])
    Return .T.
 EndIf

 If (Empty(AllTrim(cProd)) .OR. Empty(SB1->B1_COD))
    u_itmsg("Escolha um Produto Valido.","Atenção",,1)
    _lRet	:= .F.
 EndIf

 If cbloq == '1'
    U_ITMSG("Produto Bloqueado","Atenção",,1)
    _lRet	:= .F.
 Endif

 If _lRet

    nPosQtd  := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD'   } )
    nPosDesc := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCR' } )
    nPosDesD := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCD' } )
    nPosUM	 := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_UM'    } )
    nPos2UM	 := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_2UM'   } )
    nPos2Qtd := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD2UM'} )
    nPos3UM  := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_3UM'   } )//Novo
    nPos3Qtd := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD3UM'} )//Novo
    nPosVal  := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_VALOR' } )//Novo

    aCols[N,nPosDesc] := SB1->B1_DESC
    aCols[N,nPosDesD] := SB1->B1_I_DESCD
    aCols[N,nPosUM  ] := SB1->B1_UM
    aCols[N,nPos2UM ] := SB1->B1_SEGUM
    aCols[N,nPos3UM ] := SB1->B1_I_3UM //Novo

    nQtd	:= aCols [n,nPosQtd ]
    nQtd2UM := aCols [n,nPos2Qtd]
    nQtd3UM := aCols [n,nPos3Qtd] //Novo

    If nQtd <= 0 .Or. nQtd2UM <= 0 .and. nQtd3UM < 0
        u_itmsg("Quantidade(s) com o conteudo invalido.","Atenção","Preencha as Quantidades da 1a e 2a e/ou 3a unidades com valor positivo.",1)
        _lRet	:= .F.
    EndIf

    If aCols [N,nPosVal] <= 0
        u_itmsg("Campo Valor (R$) com conteudo invalido.","Atenção","Preencha o valor com um numero positivo.",1)
        _lRet	:= .F.
    EndIf

 EndIf

RETURN _lRet

/*
===============================================================================================================================
Programa----------: AOMS063Z
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
Descrição---------: Validação geral das telas de inclusão e alteração
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS063Z(_lInclui)
 Local X       := 000 As Numeric
 Local _cErro  := " " As Character
 Local _aErros := { } As Array
 Local _lRet   := .T. As Logical
 Local nPosProd:= Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_COD'   } ) As Numeric
 Local nPosVal := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_VALOR' } ) As Numeric
 Local nPosQtd := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD'   } ) As Numeric //Novo
 Local nPos2Qtd:= Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD2UM'} ) As Numeric //Novo
 Local nPos3Qtd:= Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD3UM'} ) As Numeric //Novo

 ZZS->(DbSetOrder(4))
 If Empty(cAnoMes)
     u_itmsg("Ano / Mês não Preenchido, Favor Prenche-lo Antes de Prosseguir","Atenção",,1)
     _lRet	:= .F.
 ElseIf AOMS063B()
     u_itmsg("Nâo Há Produtos, Favor Preencher ou Importar Algum Produtos Antes de Prosseguir","Atenção",,1)
     _lRet	:= .F.
 ElseIf Empty(cCoord)
     u_itmsg("Coord/Vend não Preenchido, Favor Prenche-lo Antes de Prosseguir","Atenção",,1)
     _lRet	:= .F.
 Else
     If SA3->(MsSeek(xfilial("SA3")+cCoord))
        If SA3->A3_MSBLQL == '1'
           u_itmsg("Coord/Vend Bloqueado.","Atenção",,1)
        Endif
     Else
         u_itmsg("Coord/Vend não encontrado.","Atenção",,1)
     Endif
 Endif

 If _lInclui .AND. ZZS->(MsSeek(xFilial("ZZS")+AllTrim(cAnoMes)+AllTrim(cCoord)))
     u_itmsg("Tabela Já Cadastrada, Favor alterar o Coordenador ou o Ano / Mês, para dar continuidade","Atenção",,1)
     _lRet	:= .F.
 ElseIf AllTrim(cAnoMes) < Substr(DtoS(dDataBase),1,6)
     u_itmsg("Ano / Mes Menor que o Ano / Mês Atual","Atenção",,1)
     _lRet	:= .F.
 EndIf

 aCols   := aSort(aCols,,,{|x, y| x[1] < y[1]})//REORDENA A TABELA
 _cErro  := ""

 For X:= 1 To Len(aCols)
    _cErro:=""
    If !Atail(aCols[X])
        If (X+1) <= Len(aCols)
            If!Atail(aCols[X+1])
                If aCols [X,nPosProd] == aCols [X+1,nPosProd]
                    If X < Len(aCols)
                        lRt := .T.
                        _cErro += "[Produto: " + Alltrim(aCols[x,nPosProd])+ " duplicado] "
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf
    cbloq:= Posicione("SB1",1,Xfilial("SB1")+aCols[x,nPosProd],"B1_MSBLQL")
    If cbloq == '1'
       _cErro += "[Produto: " + Alltrim(aCols[x,nPosProd]) +" Bloqueado] "
    Endif
    If Empty(aCols[x,nPosVal])
       _cErro += "[Produto: " + Alltrim(aCols[x,nPosProd]) + " com valor zerado] "
    Endif
    If aCols[X,nPos2Qtd] <= 0 .Or. aCols[X,nPosQtd] <= 0  .Or. aCols[X,nPos3Qtd] < 0
       _cErro += "[Produto: " + Alltrim(aCols[x,nPosProd]) + " com Quantidade(s) invalida(s).]"
    EndIf
    If !EMPTY(_cErro)
        _cErro:="Linha " + StrZero(X,6) + " com erro(s): "+ _cErro
        Aadd(_aErros,{.F.,_cErro})
    Endif
 Next X

 IF Len(_aErros) > 0
     U_ITListBox("Quantidade de erros: "+ALLTRIM(STR(Len(_aErros))),{"","Erros"},_aErros,,4)
     _lRet	:= .F.
 ENDIF

RETURN _lRet

/*
===============================================================================================================================
Programa----------: AOMS063V
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
Descrição---------: Funcao de validadação e gatilhos ZZS_QTD / ZZS_QTD2UM / ZZS_QTD3UM
Parametros--------: _cCampo: origem da chamada
Retorno-----------: _xRet: Retorno de acorodo com a chamada
===============================================================================================================================
*/
User Function AOMS063V(_cCampo)

 Local _xRet  := 0 As Numeric
 Local _nPos  := 0 As Numeric
 Local C      := 0 As Numeric
 Local _nPerc := 0 As Numeric
 Local _dData As Date
 Local xObj   As Object

 IF _cCampo == "%" //U_AOMS063V("%")

    _xRet := .T.
    N:=oMsMGet:oBrowse:nAt
    C:=oMsMGet:oBrowse:nColPos//Posicao do Campo %
    aCols:=oMsMGet:aCols
    _dData:=aCols[N,C-1]
    _nPerc:=&(ReadVar())//aCols[N,C]
    IF Empty(_dData) .OR. LEFT(DTOC(_dData),5) = "29/02"//ANOS BISEXTOS
       aCols[N,C]  :=0
       &(ReadVar()):=0
    Else
       RETURN NaoVazio(_nPerc) .AND. Positivo(_nPerc)
    ENDIF
    oMsMGet:aCols:=aCols
    oMsMGet:oBrowse:Refresh()

 ElseIF _cCampo == 'CCOORD'
    _xRet := .T.
    cNmCoor:= POSICIONE("SA3",1,xFilial("SA3")+cCoord,"A3_NOME")
    cTipoor:= SA3->A3_I_TIPV//V=VENDEDOR;C=COORDENADOR;G=GERENTE;S=SUPERVISOR;N=GERENCIA NACIONAL
    IF cTipoor == "V"
        cTipoor := "Vendedor"
    ELSEIF cTipoor == "C"
        cTipoor := "Coordenador"
    ELSEIF cTipoor == "G"
        cTipoor := "Gerente"
    ELSEIF cTipoor == "S"
        cTipoor := "Supervisor"
    ELSEIF cTipoor == "N"
        cTipoor := "Gerencia Nacional"
    ELSE
        cTipoor := "Tipo de Vendedor não encontrado"
    ENDIF
    If Len(aCols) > 0 .and. Len(aCols[1]) > 0 .and. aCols[1][1] == 'ZZS_COD'
        _xRet := .F.
    EndIf

 ElseIF _cCampo == "ZZS_QTD"//Contra dominio ZZS_QTD2UM

    xObj          := CallMod2Obj()
    N             := xObj:oBrowse:nat
    _nPos         := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_COD'} )
    M->ZZS_COD    := aCols[N,_nPos]
    _xRet         := U_ITConv(M->ZZS_COD,M->ZZS_QTD   ,1,2)//Retona no ZZS_QTD2UM
    M->ZZS_QTD3UM := U_ITConv(M->ZZS_COD,M->ZZS_QTD   ,1,3)//Retona no ZZS_QTD3UM
    _nPos         := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD3UM'} )
    aCols[N,_nPos]:= M->ZZS_QTD3UM

 ElseIF _cCampo == "ZZS_QTD2UM"//Contra dominio ZZS_QTD

    xObj          := CallMod2Obj()
    N             := xObj:oBrowse:nat
    _nPos         := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_COD'} )
    M->ZZS_COD    := aCols[N,_nPos]
    _xRet         := U_ITConv(M->ZZS_COD,M->ZZS_QTD2UM,2,1)//Retona no ZZS_QTD
    M->ZZS_QTD3UM := U_ITConv(M->ZZS_COD,M->ZZS_QTD2UM,2,3)//Retona no ZZS_QTD3UM
    _nPos         := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD3UM'} )
    aCols[N,_nPos]:= M->ZZS_QTD3UM

 ElseIF _cCampo == "ZZS_QTD3UM"//Contra dominio ZZS_QTD

    xObj             := CallMod2Obj()
    N                := xObj:oBrowse:nat
    _nPos            := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_3UM'} )
    M->ZZS_3UM       := aCols[N,_nPos]
    IF EMPTY(M->ZZS_3UM) 
       //M->ZZS_QTD3UM := 0//Editado 
       _nPos         := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD3UM'} )
       aCols[N,_nPos]:= 0
       _nPos         := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD'} )
       _xRet         := aCols[N,_nPos]//Retona no ZZS_QTD o conteudo dele mesmo
    Else    
       _nPos         := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_COD'} )
       M->ZZS_COD    := aCols[N,_nPos]
       _xRet         := U_ITConv(M->ZZS_COD,M->ZZS_QTD3UM,3,1)//Retona no ZZS_QTD
       M->ZZS_QTD2UM := U_ITConv(M->ZZS_COD,M->ZZS_QTD3UM,3,2)//Retona no ZZS_QTD2UM
       _nPos         := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD2UM'} )
       aCols[N,_nPos]:= M->ZZS_QTD2UM
    EndIF

 EndIf

Return _xRet

/*
===============================================================================================================================
Programa----------: AOMS063D
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
Descrição---------: Valida Dados
Parametros--------: cAnoMes,cCoord,nRet
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS063D(cAnoMes,cCoord,nRet)
 Local oDlgAno  As Object
 Local nGet1:=0 As Numeric
 Local nPorc:=0 As Numeric

 ZZS->(DbSetOrder(4))

 If Empty(cCoord)

     u_itmsg("Coord/Vend não Preenchido, Favor Prenche-lo Antes de Prosseguir","Atenção",,1)

 ElseIf ZZS->(MsSeek(xFilial("ZZS")+AllTrim(cAnoMes)+AllTrim(cCoord)))

     u_itmsg("Tabela Já Cadastrada, Favor alterar o Coordenador ou o Ano / Mês, para dar continuidade","Atenção",,1)

 ElseIf EMPTY(cAnoMes)

     u_itmsg("Ano / Mês não Preenchido, Favor Prenche-lo Antes de Prosseguir","Atenção",,1)

 ElseIf AllTrim(cAnoMes) < Substr(DtoS(dDataBase),1,6)

     u_itmsg("Ano / Mes Menor Que o Ano / Mês Atual","Atenção",,1)

 Else

     DEFINE MSDIALOG oDlgAno FROM 0,0 TO 150,200 PIXEL TITLE 'Digite a Porcentagem'

     @10,05 Say "Digite a Porcentagem para o Calculo:" Size 91,08 COLOR CLR_BLACK PIXEL OF oDlgAno
     @30,10 MSGet nGet1 Picture "@E 999,999.99" Size 60,10 Pixel Of oDlgAno

     @50,15 Button "Ok" Size 20,10 PIXEL OF oDlgAno action (oDlgAno:end())

     ACTIVATE MSDIALOG oDlgAno CENTERED

     nPorc:= nGet1/100

     FwMsgRun( ,{|oProc| U_AOMS063W(nPorc,oProc) }, 'Aguarde!' , 'Carregando os dados...'  )

 EndIf

Return

/*
===============================================================================================================================
Programa----------: AOMS063Y ()
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
Descrição---------: Visualizar Cadastro de Previsão de Vendas
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063Y(oProc)

    Local cTitulo := "Visualização de Metas de Vendas"
    Local lRetMod2:= .F. // Retorno da função Modelo2 - .T. Confirmou / .F. Cancelou
    Private  nOpcx:= 2

    If(EMPTY(TMP->ANOMES))

        u_itmsg("Não Há Tabela A ser Visualizada","Atenção",,1)

    Else

        nUsado:=0
        aHeader:={}
        aCols:={}

        //Carrega aheader
        aYesFields := {"ZZS_COD","ZZS_DESCR","ZZS_DESCD","ZZS_QTD","ZZS_UM","ZZS_QTD2UM","ZZS_2UM","ZZS_QTD3UM","ZZS_3UM","ZZS_VALOR"}
        FillGetDados(2,"ZZS",1,,,,, aYesFields ,,,, .T. ,,,,,, )

        //Limpa dois ultimos campos do aheader
        asize(aheader,Len(aheader)-2)

        cAnoMes  := Space(06)
        cCoord	 := Space(06)
        cNmCoor	 := Space(60)


        aC:={}
        // aC[n,1] = Nome da Variavel Ex.:"cCliente"
        // aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
        // aC[n,3] = Titulo do Campo
        // aC[n,4] = Picture
        // aC[n,5] = Validacao
        // aC[n,6] = F3
        // aC[n,7] = Se campo e' editavel .t. se nao .f.

        cAnoMes       := TMP->ANOMES
        cCoord	      := TMP->COORD
        cNmCoor		  := AllTrim(TMP->NMCOORD)
        cTipoor		  := POSICIONE("SA3",1,xFilial("SA3")+TMP->COORD,"A3_I_TIPV")//V=VENDEDOR;C=COORDENADOR;G=GERENTE;S=SUPERVISOR;N=GERENCIA NACIONAL
        IF cTipoor == "V"
            cTipoor := "Vendedor"
        ELSEIF cTipoor == "C"
            cTipoor := "Coordenador"
        ELSEIF cTipoor == "G"
            cTipoor := "Gerente"
        ELSEIF cTipoor == "S"
            cTipoor := "Supervisor"
        ELSEIF cTipoor == "N"
            cTipoor := "Gerencia Nacional"
        ELSE
            cTipoor := "Tipo de Vendedor não encontrado"
        ENDIF

        //"Visualização de Metas de Vendas"
        Aadd(aC,{"cAnoMes",{15,003}," Ano-Mes ","@R 9999-99",,,.F.})
        Aadd(aC,{"cCoord" ,{15,080}," Codigo " ,"@!","U_AOMS063V('CCOORD') .And. (ExistCPO('SA3'))","SA3",.F.})
        Aadd(aC,{"cNmCoor",{15,155}," Nome "   ,"@!",,,.F.})
        Aadd(aC,{"cTipoor",{30,003}," Tipo "   ,"@!",,,.F.})
        //================================================================
        // Array com descricao dos campos do Rodape do Modelo 2
        //================================================================

        aR:={}
        // aR[n,1] = Nome da Variavel Ex.:"cCliente"
        // aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
        // aR[n,3] = Titulo do Campo
        // aR[n,4] = Picture
        // aR[n,5] = Validacao
        // aR[n,6] = F3
        // aR[n,7] = Se campo e' editavel .t. se nao .f.

        aCols:= {}
        _nCont:=0
        //------------MONTA OS ITENS COM OS DADOS-----------------------//
        ZZS->(DbSetOrder(7))//ZZS_FILIAL+ZZS_ANOMES+ZZS_COOR+ZZS_COD+ZZS_DATA
        ZZS->(MsSeek(xFilial("ZZS")+cAnoMes+cCoord))
        Do While ZZS->(!EOF()).AND. cAnoMes == ZZS->ZZS_ANOMES .AND. cCoord == ZZS->ZZS_COOR
           IF !EMPTY(ZZS->ZZS_DATA)
              ZZS->(Dbskip())
              Loop
           Endif
           _nCont++
           oProc:cCaption := ( "V-Lendo Metas: " + StrZero(_nCont,5))
           ProcessMessages()
           Aadd(aCols,{ZZS->ZZS_COD,ZZS->ZZS_DESCR,ZZS->ZZS_DESCD,ZZS->ZZS_QTD,ZZS->ZZS_UM,ZZS->ZZS_QTD2UM,;
                       ZZS->ZZS_2UM,ZZS->ZZS_QTD3UM,ZZS->ZZS_3UM,ZZS->ZZS_VALOR,.F.})//Novos
           ZZS->(Dbskip())
        Enddo

        //================================================================
        // Array com coordenadas da GetDados no modelo2
        //================================================================
        aButtons := {}
        Aadd(aButtons,{"",{|| AOMS063X(.T.) },"xGerar XML"  ,"Gerar XML"  })
        Aadd(aButtons,{"",{|| AOMS063X(.F.) },"xGerar Excel","Gerar Excel"})

        _bProdDia:={|| FwMsgRun( ,{|oProc| AOMS063Ger("LISTA_META_POR_DIA",cAnoMes,cCoord) }, 'V-Aguarde!' , 'V-Lendo as datas/metas do Produto...'  )  }
        Aadd(aButtons,{"",_bProdDia,"x% por Produto/Dia","% por Produto/Dia"})

        aCGD:={60,06,26,74}
        ACORDW  := {ASIZE[7],0,ASIZE[6],ASIZE[5]}

        cLinhaOk:=".T."
        cTudoOk :=".T."

        //================================================================
        // Chamada da Modelo2
        //================================================================
        // lRetMod2 = .t. se confirmou
        // lRetMod2 = .f. se cancelou
        //		          cTitulo [ aC ] [ aR ] [ aGd ] [ nOp ] [ cLinhaOk ] [ cTudoOk ]aGetsD [ bF4 ] [ cIniCpos ] [ nMax ] [ aCordW ] [ lDelGetD ] [ lMaximazed ] [ aButtons ]
        lRetMod2:=Modelo2(cTitulo,aC	,  aR	, aCGD	,nOpcx	,  cLinhaOk	,  cTudoOk ,	  ,		  ,			   ,  9999	, ACORDW   ,  .F.       ,    .T.  		, aButtons)

    EndIf

Return


/*
===============================================================================================================================
Programa----------: AOMS063C
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
Descrição---------: Copia Cadastro de Previsão de Vendas - CHAMADO 3008
Parametros--------: oProc - Objeto do processo
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063C(oProc)

    Local cTitulo	:= "Copia de Metas de Vendas",_l
    Local lRetMod2  := .F. // Retorno da função Modelo2 - .T. Confirmou / .F. Cancelou
    Private nOpcx := 3

    If(EMPTY(TMP->ANOMES))

        u_itmsg("Não Há Tabela a ser Copiada","Atenção",,1)

    Else

        nUsado:=0
        aHeader:={}
        aCols:={}

        //Carrega aheader
        aYesFields := {"ZZS_COD","ZZS_DESCR","ZZS_DESCD","ZZS_QTD","ZZS_UM","ZZS_QTD2UM","ZZS_2UM","ZZS_QTD3UM","ZZS_3UM","ZZS_VALOR"}
        FillGetDados(2,"ZZS",1,,,,, aYesFields ,,,, .T. ,,,,,, )

        //Limpa dois ultimos campos do aheader
        asize(aheader,Len(aheader)-2)


        cAnoMes:= TMP->ANOMES
        cCoord := TMP->COORD
        cNmCoor:= TMP->NMCOORD
        cTipoor:= POSICIONE("SA3",1,xFilial("SA3")+TMP->COORD,"A3_I_TIPV")//V=VENDEDOR;C=COORDENADOR;G=GERENTE;S=SUPERVISOR;N=GERENCIA NACIONAL
        IF cTipoor == "V"
            cTipoor:= "Vendedor"
        ELSEIF cTipoor == "C"
            cTipoor:= "Coordenador"
        ELSEIF cTipoor == "G"
            cTipoor:= "Gerente"
        ELSEIF cTipoor == "S"
            cTipoor:= "Supervisor"
        ELSEIF cTipoor == "N"
            cTipoor:= "Gerencia Nacional"
        ELSE
            cTipoor:= "Tipo de Vendedor não encontrado"
        ENDIF

        aC:={}
        // aC[n,1] = Nome da Variavel Ex.:"cCliente"
        // aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
        // aC[n,3] = Titulo do Campo
        // aC[n,4] = Picture
        // aC[n,5] = Validacao
        // aC[n,6] = F3
        // aC[n,7] = Se campo e' editavel .t. se nao .f.

        //"COPIA DE METAS DE VENDAS"
        Aadd(aC,{"cAnoMes",{15,003}," Ano-Mes ","@R 9999-99",,,.T.})
        Aadd(aC,{"cCoord" ,{15,080}," Codigo " ,"@!","U_AOMS063V('CCOORD') .And. (ExistCPO('SA3'))","SA3",.T.})
        Aadd(aC,{"cNmCoor",{15,155}," Nome "   ,"@!",,,.F.})
        Aadd(aC,{"cTipoor",{30,003}," Tipo "   ,"@!",,,.F.})

        //================================================================
        // Array com descricao dos campos do Rodape do Modelo 2
        //================================================================

        aR:={}
        // aR[n,1] = Nome da Variavel Ex.:"cCliente"
        // aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
        // aR[n,3] = Titulo do Campo
        // aR[n,4] = Picture
        // aR[n,5] = Validacao
        // aR[n,6] = F3
        // aR[n,7] = Se campo e' editavel .t. se nao .f.

        aCols:= {}

        //------------MONTA OS ITENS COM OS DADOS-----------------------//
        _nCont:=0
        ZZS->(DbSetOrder(7))//ZZS_FILIAL+ZZS_ANOMES+ZZS_COOR+ZZS_COD+ZZS_DATA
        ZZS->(MsSeek(xFilial("ZZS")+cAnoMes+cCoord))
        Do While ZZS->(!EOF()).AND. cAnoMes == ZZS->ZZS_ANOMES .AND. cCoord == ZZS->ZZS_COOR
           IF !EMPTY(ZZS->ZZS_DATA)
              ZZS->(Dbskip())
              Loop
           Endif
           _nCont++
           oProc:cCaption := ( "C-Lendo Metas: " + StrZero(_nCont,5))
           ProcessMessages()
           Aadd(aCols,{ZZS->ZZS_COD,ZZS->ZZS_DESCR,ZZS->ZZS_DESCD,ZZS->ZZS_QTD,ZZS->ZZS_UM,ZZS->ZZS_QTD2UM,;
                       ZZS->ZZS_2UM,ZZS->ZZS_QTD3UM,ZZS->ZZS_3UM,ZZS->ZZS_VALOR,.F.})//Novos
           ZZS->(Dbskip())
        Enddo

        //================================================================
        // Array com coordenadas da GetDados no modelo2
        //================================================================

        aCGD:={60,06,26,74}
        ACORDW  := {ASIZE[7],0,ASIZE[6],ASIZE[5]}

        cLinhaOk:="U_AOMS063O()"
        cTudoOk :="U_AOMS063Z(.T.)"//"COPIA DE METAS DE VENDAS"

        aButtons:={}
        _bProdDia:={|| FwMsgRun( ,{|oProc| AOMS063Ger("LISTA_META_POR_DIA",cAnoMes,cCoord) }, 'C-Aguarde!' , 'C-Lendo as datas/metas do Produto...'  )  }
        Aadd(aButtons,{"",_bProdDia,"x% por Produto/Dia","% por Produto/Dia"})
        //================================================================
        // Chamada da Modelo2
        //================================================================
        // lRetMod2 = .t. se confirmou
        // lRetMod2 = .f. se cancelou
        //              cTitulo [ aC ] [ aR ] [ aGd ] [ nOp ] [ cLinhaOk ] [ cTudoOk ]aGetsD [ bF4 ] [ cIniCpos ] [ nMax ] [ aCordW ] [ lDelGetD ] [ lMaximazed ] [ aButtons ]
        lRetMod2:=Modelo2(cTitulo,aC  ,  aR  , aCGD  ,nOpcx  ,  cLinhaOk  ,  cTudoOk ,      ,       ,            ,  9999  ,  ACORDW  ,            ,    .T.       ,  aButtons)

        cChama := "NÃO RECARREGAR" //Se Cancelou

        If lRetMod2 // Gravacao. . .
            lGravouDados:=.T.

            nPosProd := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_COD'   } )
            nPosDesc := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCR' } )
            nPosDesD := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCD' } )
            nPosUM	 := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_UM'    } )
            nPosQtd	 := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD'   } )
            nPos2UM	 := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_2UM'   } )
            nPos2Qtd := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD2UM'} )
            nPos3UM  := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_3UM'   } )//Novo
            nPos3Qtd := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD3UM'} )//Novo
            nPosVal  := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_VALOR' } )//Novo

            _cReg:=AllTrim(Str(Len(aCols)))
            _nCont:=0

            For _l := 1 To Len(aCols)

                _nCont++
                oProc:cCaption := ( "Copiando Metas: " + StrZero(_nCont,5) + " de " + _cReg)
                ProcessMessages()

                If !aCols[_l,Len(aHeader)+1]

                    ZZS->(RecLock("ZZS",.T.))//INCLUSAO2
                    ZZS->ZZS_FILIAL	:= xFilial("ZZS")
                    ZZS->ZZS_COD	:= aCols[_l,nPosProd]
                    ZZS->ZZS_DESCR	:= aCols[_l,nPosDesc]
                    ZZS->ZZS_DESCD	:= aCols[_l,nPosDesD]
                    ZZS->ZZS_UM		:= aCols[_l,nPosUM]
                    ZZS->ZZS_QTD   	:= aCols[_l,nPosQtd]
                    ZZS->ZZS_2UM	:= aCols[_l,nPos2UM]
                    ZZS->ZZS_QTD2UM	:= aCols[_l,nPos2Qtd]
                    ZZS->ZZS_3UM    := aCols[_l,nPos3UM ]//Novo
                    ZZS->ZZS_QTD3UM := aCols[_l,nPos3Qtd]//Novo
                    ZZS->ZZS_VALOR  := aCols[_l,nPosVal ]//Novo
                    ZZS->ZZS_TIPOV  := POSICIONE("SA3",1,xFilial("SA3")+cCoord,"A3_I_TIPV")//Novo
                    ZZS->ZZS_COOR	:= cCoord
                    ZZS->ZZS_NMCOOR	:= cNmCoor
                    ZZS->ZZS_ANOMES	:= cAnoMes
                    ZZS->(MsUnLock())//SEM DATA

                    ZGW->(RecLock("ZGW",.T.))//INCLUSAO2
                    ZGW->ZGW_FILIAL	:= xFilial("ZGW")
                    ZGW->ZGW_COD	:= aCols[_l,nPosProd]
                    ZGW->ZGW_DESCR	:= aCols[_l,nPosDesc]
                    ZGW->ZGW_DESCD	:= aCols[_l,nPosDesD]
                    ZGW->ZGW_UM		:= aCols[_l,nPosUM]
                    ZGW->ZGW_QTD   	:= aCols[_l,nPosQtd]
                    ZGW->ZGW_2UM	:= aCols[_l,nPos2UM]
                    ZGW->ZGW_QTD2UM	:= aCols[_l,nPos2Qtd]
                    ZGW->ZGW_3UM	:= ZZS->ZZS_3UM   //Novo
                    ZGW->ZGW_QTD3UM	:= ZZS->ZZS_QTD3UM//Novo
                    ZGW->ZGW_VALOR  := ZZS->ZZS_VALOR //Novo
                    ZGW->ZGW_TIPOV  := ZZS->ZZS_TIPOV //Novo
                    ZGW->ZGW_DATAM  := ZZS->ZZS_DATA  //Novo
                    ZGW->ZGW_COOR	:= cCoord
                    ZGW->ZGW_NMCOOR	:= cNmCoor
                    ZGW->ZGW_ANOMES	:= cAnoMes
                    ZGW->ZGW_OPER   := "INCLUSAO2"
                    ZGW->ZGW_USER   := _cUserName
                    ZGW->ZGW_DATA   := DATE()
                    ZGW->ZGW_HORA   := TIME()
                    ZGW->(MsUnLock())

                    AOMS063Ger("GERAR_VALORES_POR_DATA",ZZS->ZZS_ANOMES)//COM DATA

                EndIf
            Next _l

            cChama = "RECARREGA"
            oDlgLIb:End()

        Endif
    EndIf

Return

/*
===============================================================================================================================
Programa----------: AOMS063Z
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
Descrição---------: Replicar Cadastro de Previsão de Vendas - CHAMADO 3008
Parametros--------: oProc
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063Z(oProc)

 Local cAnoMes := TMP->ANOMES as Char
 Local cCoord  := TMP->COORD as Char
 Local cNmCoord:= TMP->NMCOORD as Char
 Local _aParAux:= {} as Array
 Local _aParRet:= {} as Array
 Local  I := 0 as Numeric

 cChama := "NÃO RECARREGAR" //Se Cancelar

 If(EMPTY(TMP->ANOMES))
     u_itmsg("Não Há Tabela a ser Replicada","Atenção","Posicione em Ano / mes Preenchido.",1)
     RETURN .F.
 EndIf

 MV_PAR01 := 0

 Aadd( _aParAux ,{ 1 ,"Qtde (Em Meses) a ser replicado" ,MV_PAR01,"@E 99","",""   ,"" ,020 ,.T. } )

 For I := 1 To Len( _aParAux )
     Aadd( _aParRet ,_aParAux[I][03] )
 Next I

 //          aParametros,cTitle                            ,@aRet    ,[bOk]  ,[ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ]
 IF !ParamBox( _aParAux ,"Qtde (Em Meses) a ser replicado" ,@_aParRet,       ,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
     Return .T.
 EndIf

 FwMsgRun( ,{|oProc| AOMS063Q(MV_PAR01,cAnoMes,cCoord,cNmCoord,oProc) } , "Processando..." , "Iniciando o processamento..." )

 Return

/*
===============================================================================================================================
Programa----------: AOMS063Q
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
Descrição---------: Processa Replicacao Cadastro de Previsão de Vendas
Parametros--------: nPeriod - Quantidade de periodos a replicar
                    cAnoMes - Data do movimento a replicar
                    cCoord  - Coordenador a replicar
                    cNmCoor - numero do coordenador
                    oProc   - objeto de processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063Q(nPeriod,cAnoMes,cCoord,cNmCoor,oProc)
    Local x
    Local _cAlias:= GetNextAlias()
    Local cAMes:= cAnoMes
    Local cGravados:=""
    Local cJaGravados:=""
    lGravouDados:=.F.
    ZZS->(DbSetOrder(4))
    For x:=1 To nPeriod

        ZZS->(MsSeek(xFilial("ZZS")+cAnoMes+cCoord))

        If StrZero((VAL(SubStr(cAMes,5,2)) + 1 ),2) > "12"
            cAMes:=StrZero((VAL(SubStr(cAMes,1,4)) + 1 ),4)+"01"
        Else
            cAMes:=StrZero( VAL(SubStr(cAMes,1,4))      ,4)+StrZero((VAL(SubStr(cAMes,5,2)) + 1 ),2)
        EndIf

        If !ZZS->(MsSeek(xFilial("ZZS")+cAMes+cCoord))

            cRep:= " SELECT ZZS_COD COD, ZZS_DESCR DESCR, ZZS_DESCD DESCD, ZZS_QTD QTD1UM, ZZS_UM UM1, ZZS_QTD2UM QTD2UM, "
            cRep+= " ZZS_VALOR,ZZS_TIPOV,ZZS_QTD3UM,ZZS_3UM , "//Novos
            cRep+= " ZZS_2UM UM2
            cRep+= " FROM ZZS010
            cRep+= " WHERE ZZS_ANOMES = '"+cAnoMes+"'
            cRep+= " AND ZZS_COOR = '"+cCoord+"'
            cRep+= " AND D_E_L_E_T_ = ' ' "
            cRep+= " AND ZZS_DATA = ' ' "            
            cRep+= " AND ZZS_FILIAL = '"+xFilial("ZZS")+"'
            cRep+= " Order by ZZS_COD "

            oProc:cCaption := ( "Criando Ano / Mes / Codigo: "+ cAMes+" / "+cCoord )
            ProcessMessages()

            //==============================================
            // Monta Area de Trabalho executando a Query
            //==============================================
            MPSysOpenQuery( cRep , _cAlias)

            _nCont:=0
            _cReg:=0
            dbSelectArea(_cAlias)
            COUNT TO _cReg
            _cReg:=AllTrim(Str(_cReg))
            (_cAlias)->(DBGoTop())

            DO While (_cAlias)->(!EoF())

                _nCont++
                oProc:cCaption := ( StrZero(X,2)+" Copia: " + StrZero(_nCont,4) + " de " + _cReg+" "+cGravados)
                ProcessMessages()

                ZZS->(RecLock("ZZS",.T.))//INCLUSAO3
                ZZS->ZZS_FILIAL	:= xFilial("ZZS")
                ZZS->ZZS_COD	:= (_cAlias)->COD
                ZZS->ZZS_DESCR	:= (_cAlias)->DESCR
                ZZS->ZZS_DESCD	:= (_cAlias)->DESCD
                ZZS->ZZS_UM		:= (_cAlias)->UM1
                ZZS->ZZS_QTD   	:= (_cAlias)->QTD1UM
                ZZS->ZZS_2UM	:= (_cAlias)->UM2
                ZZS->ZZS_QTD2UM	:= (_cAlias)->QTD2UM
                ZZS->ZZS_3UM    := (_cAlias)->ZZS_3UM   //Novo
                ZZS->ZZS_QTD3UM := (_cAlias)->ZZS_QTD3UM//Novo
                ZZS->ZZS_VALOR  := (_cAlias)->ZZS_VALOR //Novo
                ZZS->ZZS_TIPOV  := (_cAlias)->ZZS_TIPOV //Novo
                ZZS->ZZS_COOR	:= cCoord
                ZZS->ZZS_NMCOOR	:= cNmCoor
                ZZS->ZZS_ANOMES	:= cAMes
                ZZS->(MsUnLock())

                ZGW->(RecLock("ZGW",.T.))//INCLUSAO3
                ZGW->ZGW_FILIAL	:= xFilial("ZGW")
                ZGW->ZGW_COD	:= (_cAlias)->COD
                ZGW->ZGW_DESCR	:= (_cAlias)->DESCR
                ZGW->ZGW_DESCD	:= (_cAlias)->DESCD
                ZGW->ZGW_UM		:= (_cAlias)->UM1
                ZGW->ZGW_QTD   	:= (_cAlias)->QTD1UM
                ZGW->ZGW_2UM	:= (_cAlias)->UM2
                ZGW->ZGW_QTD2UM	:= (_cAlias)->QTD2UM
                ZGW->ZGW_3UM    := ZZS->ZZS_3UM   //Novo
                ZGW->ZGW_QTD3UM := ZZS->ZZS_QTD3UM//Novo
                ZGW->ZGW_VALOR	:= ZZS->ZZS_VALOR //Novo
                ZGW->ZGW_TIPOV	:= ZZS->ZZS_TIPOV //Novo
                ZGW->ZGW_DATAM  := ZZS->ZZS_DATA  //Novo
                ZGW->ZGW_COOR	:= cCoord
                ZGW->ZGW_NMCOOR	:= cNmCoor
                ZGW->ZGW_ANOMES	:= cAMes
                ZGW->ZGW_OPER   := "INCLUSAO3"
                ZGW->ZGW_USER   := _cUserName
                ZGW->ZGW_DATA   := DATE()
                ZGW->ZGW_HORA   := TIME()
                ZGW->(MsUnLock())

                AOMS063Ger("GERAR_VALORES_POR_DATA",ZZS->ZZS_ANOMES)

                (_cAlias)->(Dbskip())
                lGravouDados:=.T.
                IF !"["+cAMes+"] " $ cGravados
                    cGravados+="["+cAMes+"] "
                EndIf
            Enddo
           (_cAlias)->(dbCloseArea())
        Else
           cJaGravados+="["+cAMes+"] "
        EndIf
    Next x

    IF lGravouDados
       u_itmsg("Replicação Concluida Com Sucesso","Atenção","Mes(es) gravado(s): "+cGravados,2)
       cChama = "RECARREGA"
       oDlgLIb:End()
    ELSE
       u_itmsg("Nenhum registro replicado. Esse(s) mes(es) já estão gravado(s): "+cJaGravados,"Atenção","Selecione um mes que não tenha metas no mes seguinte em diante.",2)
    ENDIF

Return

/*
===============================================================================================================================
Programa----------: AOMS063G
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
Descrição---------: ALTERAR CADASTRO DE PREVISÃO DE VENDAS
Parametros--------: oProc - Objeto do processo
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063G(oProc)

 Local cTitulo	:= "Alteração de Metas de Vendas",_l
 Local lRetMod2  := .F. // Retorno da função Modelo2 - .T. Confirmou / .F. Cancelou
 Private nOpcx := 4

 If(EMPTY(TMP->ANOMES))
   u_itmsg("Não Há Tabela a ser alterada","Atenção",,1)
   RETURN .F.
 ElseIf TMP->ANOMES < LEFT(DTOS(Date()),6)
   u_itmsg("Metas com data menor que "+LEFT(DTOS(Date()),4)+"-"+Substr(DTOS(Date()),5,2)+" não podem serem alteradas.","Atenção",,1)
   RETURN .F.
 EndIf

 nUsado:=0
 aHeader:={}
 aCols:={}

 //Carrega aheader
 aYesFields := {"ZZS_COD","ZZS_DESCR","ZZS_DESCD","ZZS_QTD","ZZS_UM","ZZS_QTD2UM","ZZS_2UM","ZZS_QTD3UM","ZZS_3UM","ZZS_VALOR"}
 FillGetDados(2,"ZZS",1,,,,, aYesFields ,,,, .T. ,,,,,, )

 //Limpa dois ultimos campos do aheader
 asize(aheader,Len(aheader)-2)


 cAnoMes:= TMP->ANOMES
 cCoord := TMP->COORD
 cNmCoor:= TMP->NMCOORD
 cTipoor:= POSICIONE("SA3",1,xFilial("SA3")+TMP->COORD,"A3_I_TIPV")//V=VENDEDOR;C=COORDENADOR;G=GERENTE;S=SUPERVISOR;N=GERENCIA NACIONAL
 IF cTipoor == "V"
     cTipoor := "Vendedor"
 ELSEIF cTipoor == "C"
     cTipoor := "Coordenador"
 ELSEIF cTipoor == "G"
     cTipoor := "Gerente"
 ELSEIF cTipoor == "S"
     cTipoor := "Supervisor"
 ELSEIF cTipoor == "N"
     cTipoor := "Gerencia Nacional"
 ELSE
     cTipoor := "Tipo de Vendedor não encontrado"
 ENDIF

 aC:={}
 // aC[n,1] = Nome da Variavel Ex.:"cCliente"
 // aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
 // aC[n,3] = Titulo do Campo
 // aC[n,4] = Picture
 // aC[n,5] = Validacao
 // aC[n,6] = F3
 // aC[n,7] = Se campo e' editavel .t. se nao .f.
 //"ALTERAÇÃO DE METAS DE VENDAS"
 Aadd(aC,{"cAnoMes",{15,003}," Ano-Mes ","@R 9999-99",,,.F.})
 Aadd(aC,{"cCoord" ,{15,080}," Codigo " ,"@!","U_AOMS063V('CCOORD') .And. (ExistCPO('SA3'))","SA3",.F.})
 Aadd(aC,{"cNmCoor",{15,155}," Nome "   ,"@!",,,.F.})
 Aadd(aC,{"cTipoor",{30,003}," Tipo "   ,"@!",,,.F.})

 //================================================================
 // Array com descricao dos campos do Rodape do Modelo 2
 //================================================================

 aR:={}
 // aR[n,1] = Nome da Variavel Ex.:"cCliente"
 // aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
 // aR[n,3] = Titulo do Campo
 // aR[n,4] = Picture
 // aR[n,5] = Validacao
 // aR[n,6] = F3
 // aR[n,7] = Se campo e' editavel .t. se nao .f.
 aCols:= {}
 //------------MONTA OS ITENS COM OS DADOS-----------------------//
_nCont:=0
 ZZS->(DbSetOrder(7))//ZZS_FILIAL+ZZS_ANOMES+ZZS_COOR+ZZS_COD+ZZS_DATA
 ZZS->(MsSeek(xFilial("ZZS")+cAnoMes+cCoord))
 Do While ZZS->(!EOF()).AND. cAnoMes == ZZS->ZZS_ANOMES .AND. cCoord == ZZS->ZZS_COOR
    IF !EMPTY(ZZS->ZZS_DATA)
       ZZS->(Dbskip())
       Loop
    Endif
    _nCont++
    oProc:cCaption := ( "V-Lendo Metas: " + StrZero(_nCont,5))
    ProcessMessages()
    Aadd(aCols,{ZZS->ZZS_COD,ZZS->ZZS_DESCR,ZZS->ZZS_DESCD,ZZS->ZZS_QTD,ZZS->ZZS_UM,ZZS->ZZS_QTD2UM,;
                ZZS->ZZS_2UM,ZZS->ZZS_QTD3UM,ZZS->ZZS_3UM,ZZS->ZZS_VALOR,.F.})//Novos
    ZZS->(Dbskip())
 Enddo

 //================================================================
 // Array com coordenadas da GetDados no modelo2
 //================================================================
 aCGD:={60,06,26,74}
 ACORDW  := {ASIZE[7],0,ASIZE[6],ASIZE[5]}
 aButtons:={}
 _bProdDia:={|| FwMsgRun( ,{|oProc| AOMS063Ger("LISTA_META_POR_DIA",cAnoMes,cCoord) }, 'A-Aguarde!' , 'A-Lendo as datas/metas do Produto...'  )  }
 Aadd(aButtons,{"",_bProdDia,"x% por Produto/Dia","% por Produto/Dia"})
 cLinhaOk:="U_AOMS063O()"
 cTudoOk :="U_AOMS063Z(.F.)"//"ALTERAÇÃO DE METAS DE VENDAS"
 //================================================================
 // Chamada da Modelo2
 //================================================================
 // lRetMod2 = .t. se confirmou
 // lRetMod2 = .f. se cancelou
 //		          cTitulo [ aC ] [ aR ] [ aGd ] [ nOp ] [ cLinhaOk ] [ cTudoOk ] aGetsD [ bF4 ] [ cIniCpos ] [ nMax ] [ aCordW ] [ lDelGetD ] [ lMaximazed ] [ aButtons ]
 lRetMod2:=Modelo2(cTitulo,aC    ,  aR  , aCGD  ,nOpcx  ,  cLinhaOk  ,  cTudoOk  ,      ,       ,            ,  9999  ,  ACORDW  ,    .T.     ,    .T.       ,aButtons)

 cChama := "NÃO RECARREGAR" //Se Cancelou
 lGravouDados:=.F.//Se Cancelou

 If lRetMod2 // Gravacao. . .

    nPosProd := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_COD'   } )
    nPosDesc := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCR' } )
    nPosDesD := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCD' } )
    nPosUM	 := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_UM'    } )
    nPosQtd	 := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD'   } )
    nPos2UM	 := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_2UM'   } )
    nPos2Qtd := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD2UM'} )
    nPos3UM  := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_3UM'   } )//Novo
    nPos3Qtd := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD3UM'} )//Novo
    nPosVal  := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_VALOR' } )//Novo

    _cReg:=AllTrim(Str(Len(aCols)))
    _nCont:=0

    ZZS->(DbSetOrder(7))//ZZS_FILIAL+ZZS_ANOMES+ZZS_COOR+ZZS_COD+ZZS_DATA
    For _l := 1 To Len(aCols)

        _nCont++
        oProc:cCaption := ( "Gravando Metas: " + StrZero(_nCont,5) + " de " + _cReg)
        ProcessMessages()

        If !Atail(aCols[_l])

            IF !ZZS->(MsSeek(xFilial("ZZS")+cAnoMes+cCoord+aCols[_l,nPosProd]+"      "))//INCLUSAO
               ZZS->(RecLock("ZZS",.T.))//INCLUSAO4
               ZZS->ZZS_ANOMES	:= cAnoMes
               ZZS->ZZS_COOR 	:= cCoord
               ZZS->ZZS_NMCOOR	:= cNmCoor
               _COPER := "INCLUSAO4"
            Else
               ZZS->(RecLock("ZZS",.F.))//ALTERADO1
               _COPER := "ALTERADO1"//"ALTERADO-FINAL"
            EndIf

            ZZS->ZZS_COD	:= aCols[_l,nPosProd]
            ZZS->ZZS_DESCR	:= aCols[_l,nPosDesc]
            ZZS->ZZS_DESCD	:= aCols[_l,nPosDesD]
            ZZS->ZZS_UM		:= aCols[_l,nPosUM]
            ZZS->ZZS_QTD   	:= aCols[_l,nPosQtd]
            ZZS->ZZS_2UM	:= aCols[_l,nPos2UM]
            ZZS->ZZS_QTD2UM	:= aCols[_l,nPos2Qtd]
            ZZS->ZZS_3UM    := aCols[_l,nPos3UM ]//Novo
            ZZS->ZZS_QTD3UM := aCols[_l,nPos3Qtd]//Novo
            ZZS->ZZS_VALOR  := aCols[_l,nPosVal ]//Novo
            ZZS->ZZS_TIPOV  := POSICIONE("SA3",1,xFilial("SA3")+cCoord,"A3_I_TIPV")//Novo
            ZZS->(MsUnLock())

            ZGW->(RecLock("ZGW",.T.))//ALTERADO1 / INCLUSAO4
            ZGW->ZGW_FILIAL := xFilial("ZGW")
            ZGW->ZGW_COD    := ZZS->ZZS_COD
            ZGW->ZGW_DESCR  := ZZS->ZZS_DESCR
            ZGW->ZGW_DESCD  := ZZS->ZZS_DESCD
            ZGW->ZGW_UM     := ZZS->ZZS_UM
            ZGW->ZGW_QTD   	:= ZZS->ZZS_QTD
            ZGW->ZGW_2UM    := ZZS->ZZS_2UM
            ZGW->ZGW_QTD2UM	:= ZZS->ZZS_QTD2UM
            ZGW->ZGW_3UM    := ZZS->ZZS_3UM   //Novo
            ZGW->ZGW_QTD3UM := ZZS->ZZS_QTD3UM//Novo
            ZGW->ZGW_VALOR  := ZZS->ZZS_VALOR //Novo
            ZGW->ZGW_TIPOV  := ZZS->ZZS_TIPOV //Novo
            ZGW->ZGW_DATAM  := ZZS->ZZS_DATA  //Novo
            ZGW->ZGW_COOR   := ZZS->ZZS_COOR
            ZGW->ZGW_NMCOOR := ZZS->ZZS_NMCOOR
            ZGW->ZGW_ANOMES := ZZS->ZZS_ANOMES
            ZGW->ZGW_OPER   := _COPER
            ZGW->ZGW_USER   := _cUserName
            ZGW->ZGW_DATA   := DATE()
            ZGW->ZGW_HORA   := TIME()
            ZGW->(MsUnLock())
            lGravouDados:=.T.

            AOMS063Ger("GERAR_VALORES_POR_DATA",ZZS->ZZS_ANOMES)

        Else//EXCLUSAO

            IF ZZS->(MsSeek(xFilial("ZZS")+cAnoMes+cCoord+aCols[_l,nPosProd]+"      "))
               ZGW->(RecLock("ZGW",.T.))//EXCLUSAO_LINHA_PRODUTO
               ZGW->ZGW_FILIAL := xFilial("ZGW")
               ZGW->ZGW_COD    := ZZS->ZZS_COD
               ZGW->ZGW_DESCR  := ZZS->ZZS_DESCR
               ZGW->ZGW_DESCD  := ZZS->ZZS_DESCD
               ZGW->ZGW_UM     := ZZS->ZZS_UM
               ZGW->ZGW_QTD    := ZZS->ZZS_QTD
               ZGW->ZGW_QTD2UM := ZZS->ZZS_QTD2UM
               ZGW->ZGW_2UM    := ZZS->ZZS_2UM
               ZGW->ZGW_QTD3UM := ZZS->ZZS_QTD3UM//Novo
               ZGW->ZGW_3UM    := ZZS->ZZS_3UM   //Novo
               ZGW->ZGW_VALOR  := ZZS->ZZS_VALOR //Novo
               ZGW->ZGW_TIPOV  := ZZS->ZZS_TIPOV //Novo
               ZGW->ZGW_DATAM  := ZZS->ZZS_DATA  //Novo
               ZGW->ZGW_COOR   := ZZS->ZZS_COOR
               ZGW->ZGW_NMCOOR := ZZS->ZZS_NMCOOR
               ZGW->ZGW_ANOMES := ZZS->ZZS_ANOMES
               ZGW->ZGW_OPER   := "EXCLUSAO_LINHA_PRODUTO"
               ZGW->ZGW_USER   := _cUserName
               ZGW->ZGW_DATA   := DATE()
               ZGW->ZGW_HORA   := TIME()
               ZGW->(MsUnLock())

               AOMS063Ger("EXCLUIR_VALORES_POR_DATA")

               ZZS->(RecLock("ZZS",.F.))//EXCLUSAO_LINHA_PRODUTO
               ZZS->(dbDelete())
               ZZS->(MsUnLock())
               lGravouDados:=.T.

            ENDIF
        EndIf
    Next _l

 EndIf

 IF lGravouDados
    u_itmsg("Alteração Concluida Com Sucesso","Atenção",,2)
    //cChama = "RECARREGA" Não precisa recarregar na alteração
    oDlgLIb:End()
 ENDIF

Return

/*
===============================================================================================================================
Programa----------: AOMS063N
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
Descrição---------: Exclusão Cadastro de Previsão de Vendas
Parametros--------: oProc - objeto de processamento
                    _nOpcao - 1 - Exclui todos os coordenadores
                              2 - Exclui apenas o coordenador selecionado
                              3 - Cancela a exclusão
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063N(oProc)

 Local _nOpcao:= 0 As Numeric
 Local cAno   := SUBSTR(TMP->ANOMES,5,2)+"-"+SUBSTR(TMP->ANOMES,1,4) // Mes/Ano  As Char
 Local cCoo   := TMP->COORD   As Char
 Local cCooD  := AllTrim(TMP->NMCOORD) As Char

 _nOpcao:=AVISO("AOMS063N - Exclusão de Metas de Vendas","Deseja Excluir as metas do Mes: "+cAno+" todo de todos os coordenadores ou somente as metas do Coord/Vend: "+cCoo+" - "+cCooD,;
               {"SIM p/ Mes"        ,;   // 01
                "SIM p/ Coordenador",;   // 02
                "Cancelar"        },2)   // 03

 cChama := "NÃO RECARREGAR" //Se Cancelou

 If _nOpcao <> 3// Se não Cancelou
     _nCont:=0
     lGravouDados:=.F.
     ZZS->(DbSetOrder(4))
     ZZS->(MsSeek(xFilial("ZZS")+TMP->ANOMES+IF(_nOpcao=2,TMP->COORD,"")))

     DO While !ZZS->(EoF()) .And. TMP->ANOMES == ZZS->ZZS_ANOMES .And. IF(_nOpcao=2,(TMP->COORD == ZZS->ZZS_COOR),.T.)

         _nCont++
         oProc:cCaption := ( "Excluindo metas: " + StrZero(_nCont,6)+" - Data: "+DTOC(ZZS->ZZS_DATA)  )
         ProcessMessages()

         ZGW->(RecLock("ZGW",.T.))//EXCLUSAO_Mes-Ano_Coord/Vend - EXCLUSAO_Mes-Ano
         ZGW->ZGW_FILIAL:= xFilial("ZGW")
         ZGW->ZGW_COD   := ZZS->ZZS_COD
         ZGW->ZGW_DESCR	:= ZZS->ZZS_DESCR
         ZGW->ZGW_DESCD	:= ZZS->ZZS_DESCD
         ZGW->ZGW_UM	:= ZZS->ZZS_UM
         ZGW->ZGW_QTD   := ZZS->ZZS_QTD
         ZGW->ZGW_2UM   := ZZS->ZZS_2UM
         ZGW->ZGW_QTD2UM:= ZZS->ZZS_QTD2UM
         ZGW->ZGW_3UM   := ZZS->ZZS_3UM   //Novo
         ZGW->ZGW_QTD3UM:= ZZS->ZZS_QTD3UM//Novo
         ZGW->ZGW_VALOR := ZZS->ZZS_VALOR //Novo
         ZGW->ZGW_TIPOV := ZZS->ZZS_TIPOV //Novo
         ZGW->ZGW_DATAM := ZZS->ZZS_DATA  //Novo
         ZGW->ZGW_COOR  := ZZS->ZZS_COOR
         ZGW->ZGW_NMCOOR:= ZZS->ZZS_NMCOOR
         ZGW->ZGW_ANOMES:= ZZS->ZZS_ANOMES
         ZGW->ZGW_OPER  := IF(_nOpcao=2,"EXCLUSAO_Mes-Ano_Coord/Vend","EXCLUSAO_Mes-Ano")
         ZGW->ZGW_USER  := _cUserName
         ZGW->ZGW_DATA  := DATE()
         ZGW->ZGW_HORA  := TIME()
         ZGW->(MsUnLock())

         lGravouDados:=.T.

         ZZS->(RecLock("ZZS",.F.))//EXCLUSAO_Mes-Ano_Coord/Vend - EXCLUSAO_Mes-Ano
         ZZS->(DbDelete())
         ZZS->(MsUnLock())

        ZZS->(Dbskip())
     Enddo

     IF _nOpcao=2
         TMP->(DbDelete())   //Atual
         TMP->(dbskip())     //VAI PARA O PROXIMO
         iF TMP->(Eof())     //SE EOF()
            TMP->(DbSkip(-1))//VOLTA UM
         Endif
         u_itmsg("Mes-Ano: "+cAno+" do Coord/Vend: "+cCoo+" - "+cCooD+" Excluida Com Sucesso","Atenção",,2)
         oMark:oBrowse:Refresh(.T.)

     ELSE
         u_itmsg("Mes-Ano: "+cAno+" Excluido Com Sucesso","Atenção",,2)
         cChama := "RECARREGA" //Reinicia tela
         oDlgLIb:End()
     Endif

 EndIf

Return


/*
===============================================================================================================================
Programa----------: AOMS063B
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
Descrição---------: Valida produtos
Parametros--------: Nenhum
Retorno-----------: lRet - True se emcontro produtos
===============================================================================================================================
*/
Static Function AOMS063B()
 Local I
 nPosProd := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_COD'} )
 lRet := .T.
 For I:= 1 to Len(aCols)
     If !Empty(aCols[I,nPosProd]) .And. !Atail(aCols[I])
         Return .F.
     EndIf
 Next I
Return lRet

/*
===============================================================================================================================
Programa----------: AOMS063U
Autor-------------: Erich Buttner
Data da Criacao---: 22/04/13
Descrição---------: Prepara variáveis e dados
Parametros--------: oProc
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063U(oProc)
 Local _cAlias:=GetNextAlias()
 Local cQuery := " SELECT ZZS.ZZS_COOR COORD, ZZS.ZZS_NMCOOR NMCOORD, ZZS.ZZS_ANOMES ANOMES "
 cQuery += " FROM ZZS010 ZZS "
 cQuery += " WHERE ZZS_FILIAL = '"+xFilial("ZZS")+"' "
 cQuery += " AND D_E_L_E_T_ = ' ' "
 IF LEN(_cAnoIni) = 4 
    cQuery += " AND SubStr(ZZS.ZZS_ANOMES,1,4) >= '" + _cAnoIni+"' "
 ElseIf !Empty(_cAnoIni)
    cQuery += " AND ZZS.ZZS_ANOMES >= '" + _cAnoIni+"' "
 Endif
 IF LEN(_cAnoFim) = 4 
    cQuery += " AND SubStr(ZZS.ZZS_ANOMES,1,4) >= '" + _cAnoFim+"' "
 ElseIf !Empty(_cAnoFim)
    cQuery += " AND ZZS.ZZS_ANOMES <= '" + _cAnoFim+"' "
 Endif
 cQuery += " GROUP BY ZZS.ZZS_COOR, ZZS_NMCOOR, ZZS.ZZS_ANOMES "

 MPSysOpenQuery( cQuery , _cAlias)

 aCpoTmp:={}
 Aadd(aCpoTmp,{"ANOMES" ,"C",06,0})
 Aadd(aCpoTmp,{"COORD"  ,"C",06,0})
 Aadd(aCpoTmp,{"NMCOORD","C",60,0})
 Aadd(aCpoTmp,{"TIPO"   ,"C",40,0})
 Aadd(aCpoTmp,{"BLOQ"   ,"C",03,0})

 If Select("TMP") > 0 .AND. TYPE("_oTemp") == "O"
     _oTemp:Delete()
 EndIf

 _oTemp := FWTemporaryTable():New( "TMP", aCpoTmp )
 _oTemp:AddIndex( "01", {"ANOMES","NMCOORD"} )
 _oTemp:AddIndex( "02", {"COORD","ANOMES"  } )
 _oTemp:AddIndex( "03", {"NMCOORD"}          )

 _oTemp:Create()

 _nCont:=0
 _cReg:=0
 dbSelectArea(_cAlias)
  COUNT TO _cReg
 _cReg:=AllTrim(Str(_cReg))
 (_cAlias)->(dbGoTop())

 DO While !(_cAlias)->(EOF())

     _nCont++
     oProc:cCaption := ( "Lendo Metas: " + StrZero(_nCont,5) + " de " + _cReg)
     ProcessMessages()

     cTipoor     := POSICIONE("SA3",1,xFilial("SA3")+(_cAlias)->COORD,"A3_I_TIPV")//V=VENDEDOR;C=COORDENADOR;G=GERENTE;S=SUPERVISOR;N=GERENCIA NACIONAL
     IF cTipoor == "V"
         cTipoor := "Vendedor"
     ELSEIF cTipoor == "C"
         cTipoor := "Coordenador"
     ELSEIF cTipoor == "G"
         cTipoor := "Gerente"
     ELSEIF cTipoor == "S"
         cTipoor := "Supervisor"
     ELSEIF cTipoor == "N"
         cTipoor := "Gerencia Nacional"
     ELSE
         cTipoor := "Tipo de Vendedor não encontrado"
     ENDIF

     TMP->(DbAppend())
     TMP->COORD  := (_cAlias)->COORD
     TMP->ANOMES := (_cAlias)->ANOMES
     TMP->NMCOORD:= (_cAlias)->NMCOORD
     TMP->TIPO   := cTipoor
     TMP->BLOQ   := IF(SA3->A3_MSBLQL = '1', "SIM", "NAO")
     (_cAlias)->(Dbskip())

 Enddo

 (_cAlias)->(dbCloseArea())

 TMP->(DBGOTOP())
 aCpoBrw:={}
 Aadd(aCpoBrw,{"ANOMES" ,""	,"Ano - Mes"            ,"@R 9999-99","06","0"})
 Aadd(aCpoBrw,{"COORD"  ,""	,"Codigo"               ,"@!"        ,"06","0"})
 Aadd(aCpoBrw,{"NMCOORD",""	,"Nome"                 ,"@!"        ,"60","0"})
 Aadd(aCpoBrw,{"TIPO"   ,""	,"Tipo"                 ,"@!"        ,"40","0"})
 Aadd(aCpoBrw,{"BLOQ"   ,""	,"Coor.\Vend.Bloqueado?","@!"        ,"20","0"})

Return

/*
===============================================================================================================================
Programa----------: AOMS063E
Autor-------------: Josué Danich Prestes
Data da Criacao---: 19/04/2018
Descrição---------: Exporta tabela de dados
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
Static Function AOMS063E()
 If Pergunte( 'AOMS063' )
    If empty(MV_PAR01)
        U_ITMSG("Preenchimento do mês e ano é obrigatório!","Atenção",,1)
        Return
    Else
        FwMsgRun( ,{|| _aAlias := AOMS063L() } , 'Aguarde!' , 'Verificando os registros...' )
    Endif
 EndIf
Return*/

/*
===============================================================================================================================
Programa----------: AOMS063L
Autor-------------: Josué Danich Prestes
Data da Criacao---: 19/04/2018
Descrição---------: Gera tabela de exportação
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
Static Function AOMS063L()

 Local _cquery := ""
 Local calias  := GetNextAlias()
 Local _aLista := {}
 Local _ni		:= 0
 Local _nii		:= 0

 _cQuery := " SELECT "
 _cQuery += "    ZZS_COD,ZZS_DESCR,ZZS_DESCD,ZZS_QTD,ZZS_UM,ZZS_QTD2UM,ZZS_2UM,ZZS_COOR,ZZS_NMCOOR,ZZS_ANOMES"
 _cQuery += " FROM "+ RetSqlName("ZZS") +" ZZS "
 _cQuery += " WHERE ZZS.D_E_L_E_T_	= ' ' "
 If !empty(MV_PAR01)
     _cQuery += " AND	ZZS.ZZS_ANOMES	= '"+ MV_PAR01 +"' "
 Endif
 If !empty(MV_PAR02)
     _cQuery += " AND	ZZS.ZZS_COOR	>= '"+ MV_PAR02 +"' "
     _cQuery += " AND	ZZS.ZZS_COOR	<= '"+ MV_PAR03 +"' "
 Endif
 _cQuery += " ORDER BY ZZS_ANOMES,ZZS_COOR,ZZS_DESCR"

 MPSysOpenQuery( _cQuery , cAlias)

 //Popula array com coordenadores/vendedores
 _avend := {}

 Do While  (cAlias)->(!Eof())

    If Ascan(_avend,(cAlias)->ZZS_COOR + "/" + (cAlias)->ZZS_NMCOOR) == 0  .and. !empty((cAlias)->ZZS_COOR)
        Aadd(_avend,(cAlias)->ZZS_COOR+ "/" + (cAlias)->ZZS_NMCOOR)
        Aadd(_avend,"UN")
    Endif
    (cAlias)->(Dbskip())

 Enddo

 (cAlias)->( DBGoTop() )

 Do While  (cAlias)->(!Eof())

    _nposi := Ascan(_aLista,{|x| x[3] = AllTrim((cAlias)->ZZS_COD)})

    If _nposi == 0

        Aadd(_aLista,{ MV_PAR01,;
                        AllTrim((cAlias)->ZZS_DESCR) ,;
                        (cAlias)->ZZS_COD  })

        For _ni := 1 to Len(_avend)

            If Ascan(_avend,(cAlias)->ZZS_COOR + "/" + (cAlias)->ZZS_NMCOOR) == _ni

                Aadd(_aLista[Len(_aLista)],(cAlias)->ZZS_QTD2UM)
                Aadd(_aLista[Len(_aLista)],(cAlias)->ZZS_2UM)

            Else

                Aadd(_aLista[Len(_aLista)],0)
                Aadd(_aLista[Len(_aLista)],(cAlias)->ZZS_2UM)

            Endif

        Next

    Else

        _aLista[_nposi][Ascan(_avend,(cAlias)->ZZS_COOR + "/" + (cAlias)->ZZS_NMCOOR)+3] := (cAlias)->ZZS_QTD2UM

    Endif

    (cAlias)->( Dbskip() )

 Enddo

 _aHead := {	"ANOMES","PRODUTO","CODIGO","VALOR"}

 For _ni := 1 to Len(_avend)
    Aadd(_aHead,_avend[_ni])
 Next


 //Correcao de linhas para excluir colunas extras
 _atemp := {}

 For _ni := 1 to Len(_aLista)

    Aadd(_atemp, {})
    For _nii := 1 to Len(_aLista[_ni])

        If _nii <= Len(_aHead)

            Aadd(_atemp[Len(_atemp)],_aLista[_ni][_nii])

        Endif

    Next

 Next
 (_cAlias)->(dbCloseArea())
 _aLista := _atemp

 If Len(_aLista) > 0
   U_ITListBox( "Metas Venda",	_aHead,	 _aLista , .F. , 1,"Metas Venda"  )
 Else
    u_itmsg("Não foram Localizados registros com os parâmetros indicados","Atenção",,1)
 Endif

Return*/


/*
===============================================================================================================================
Programa----------: AOMS063K
Autor-------------: Josué Danich Prestes
Data da Criacao---: 19/04/2018
Descrição---------: Importa tabela de dados
Parametros--------: oProc
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063K(oProc)

    Local _cdados := ""
    Local _aHead  := {}
    Local _aLinhas:= {}
    Local I:=_nRep:=0 As numeric
    Local _aParAux:= {}
    Local _aParRet:= {}

    MV_PAR01 := SPACE(6)
    MV_PAR02 := SPACE(200)

    Aadd( _aParAux ,{ 1 ,"Digite o Ano/mes (AAAA-MM)" ,MV_PAR01,"@R 9999-99","",""   ,"" ,015 ,.T. } )
    Aadd( _aParAux ,{ 1 ,"Selecione arquivo de ajuste",MV_PAR02,"@!"        ,"","DIR","" ,100 ,.T. } )

    For I := 1 To Len( _aParAux )
        Aadd( _aParRet ,_aParAux[I][03] )
    Next I

    //aParametros,cTitle                                   ,@aRet    ,[bOk]  ,[ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ]
    IF !ParamBox( _aParAux ,"Selecione o Arquivo .CSV para Importar" ,@_aParRet,       ,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
        Return .F.
    EndIf

    _cArq  := AllTrim(MV_PAR02)
    _oFile := FwFileReader():New(_cArq)

    If !_oFile:Open()
        U_ItMsg("1-Falha ao abrir o arquivo: "+_cArq,"Erro",,1)
        Return .F.
    EndIf

    oProc:cCaption := ( "Lendo Dados: "+ _cArq )
    ProcessMessages()

    _cDados := _oFile:GetLine()

    //Verifica segunda linha de headers
    If !"REGIONAL;COOR.;COD. COOR.;MIX;" $ AllTrim(_cDados) .AND. !"REGIONAL;VEND.;COD. VENDEDOR;MIX;" $ AllTrim(_cDados)
        u_itmsg("Arquivo não está no layout de metas de venda","Atenção",;
            "Layout necessario: REGIONAL;COOR. ou VEND.;COD. COOR. ou VENDEDOR;MIX;FAMILIA;GRUPO - AJUSTADO;CODIGO;PRODUTO;VOLUME;UNI. VOL;VALOR (R$)",1)
        Return .F.
    Endif

    _aRegs := {}
    LjMsgRun( "Lendo Arq: "+_cArq , TIME()+" - AGUARDE..." , {|| _aRegs := _oFile:getAllLines() } )

    _cDados  := AllTrim(_cDados)
    _aHead   := StrTokArr2(_cDados,";",.T.) //_aHead:={REGIONAL;COOR.;COD. COOR.;MIX;FAMILIA;GRUPO - AJUSTADO;CODIGO;PRODUTO;VOLUME;UNI. VOL;VALOR (R$);ANOMES}
    _aHead[1]:= "ANO/MES"

    Private nColVen:= Ascan(_aHead,"COD. ")//DO VENDEDOR OU COORDENADOR
    Private nColPrd:= Ascan(_aHead,"CODIGO"    )
    Private nColVol:= Ascan(_aHead,"VOLUME"    )
    Private nColVal:= Ascan(_aHead,"VALOR (R$)")
    Private nColUM := Ascan(_aHead,"UNI. VOL"  )

    IF nColVen=0 .OR. nColPrd=0 .OR. nColVol=0 .OR. nColVal=0
        u_itmsg("Arquivo não está no layout de metas de venda","Atenção","Um desses nomes de campo não esta no arquivo: COD. , CODIGO , VOLUME, UNI. VOL ou VALOR (R$)",1)
        Return .F.
    Endif

    nColNome:=nColVen-1//coluna do nome do vendedor/coordenador
    nColNprd:=nColPrd+1//coluna do nome do vendedor/coordenador

    _nReg:= Len(_aRegs)

    If _nReg == 0 //O arquivo informado nao possui nenhuma linha de dados
        U_ITMSG("O arquivo informado para relizar a importação não possui dados.",;
            "Arquivo inválido",;
            "Favor verificar se o arquivo "+_cArq+" informado esta no formato correto.")
        Return .F.
    EndIf
    _nCont :=0
    _aErros:= {}
    _aDados:= {}
    SB1->(DbSetOrder(1))
    SA3->(DbSetOrder(1))

    For I := 2 To Len(_aRegs)
    //Do While (_oFile:hasLine()) // É LENTO

        _nCont++
        oProc:cCaption := ( "1/1 - Lendo / Validando linha " + StrZero(_nCont,6) + " de " + StrZero(_nReg,6) + ". Erros: "+StrZero(Len(_aErros),6) )
        ProcessMessages()

        _cErro :=""//para cada linha Limpa
        _cDados:= _aRegs[I]//AllTrim(_oFile:GetLine()) // É LENTO

        Aadd(_aLinhas,StrTokArr2(_cDados,";",.T.))

        _ni:= Len(_aLinhas)

        BEGIN SEQUENCE

            If Len(_aLinhas[_ni]) <> Len(_aHead)
                _cErro += "[Linha com divergência de colunas, verifique se todos as metas contém valores numéricos, em caso de meta zerada deve estar com número 0.] "
                IF Len(_aLinhas[_ni]) < nColVal
                    BREAK
                ENDIF
            Endif

            //Normaliza campos de código
            _aLinhas[_ni][1] :=  SUBSTR(MV_PAR01,5,2)+"/"+SUBSTR(MV_PAR01,1,4) // Mes/Ano
            _aLinhas[_ni][nColPrd] := StrZero(val(_aLinhas[_ni][nColPrd]),11)

            //Normaliza campos de valores para numérico
            _aLinhas[_ni][nColVol]  :=  Val(_aLinhas[_ni][nColVol])

            _xValor:=AllTrim(StrTran(_aLinhas[_ni][nColVal],"R$",""))//Remove R$
            _xValor:=(StrTran(_xValor,"." ,"" ))//Remove ponto
            _xValor:=(StrTran(_xValor,"," ,"."))//Troca virgula por ponto das decimais

            _aLinhas[_ni][nColVal]:=Val(_xValor)

            _cCodVend:=_aLinhas[_ni][nColVen]
            _cCodProd:=U_ITKey(_aLinhas[_ni][nColPrd],"ZZS_COD")
            _cUnidade:=UPPER(ALLTRIM(_aLinhas[_ni][nColUM]))
            _lprod := .T.
            If SB1->(MsSeek(xfilial("SB1")+_cCodProd))
                If SB1->B1_MSBLQL == '1'
                    _lprod := .F.
                    _cErro += '[Cod. Produto "'+AllTrim(_cCodProd)+'" Bloqueado] '
                ElseIF ALLTRIM(SB1->B1_UM) <> _cUnidade .AND. ALLTRIM(SB1->B1_SEGUM) <> _cUnidade .AND.  ALLTRIM(SB1->B1_I_3UM) <> _cUnidade
                    _lprod := .F.
                    _cErro += '[UM "'+_cUnidade+'" do Produto "'+AllTrim(_cCodProd)+'" Invalida, 1UM: "'+SB1->B1_UM+'", 2UM: "'+SB1->B1_SEGUM+'", 3UM: "'+SB1->B1_I_3UM+'".] '
                Endif
            Else
                _cErro += '[Cod. Produto "'+(_cCodProd)+'"  não encontrado] '
            Endif

            _lvend := .T.
            If SA3->(MsSeek(xfilial("SA3")+_cCodVend))
                _cNome := ALLTRIM(SA3->A3_NOME)
                If SA3->A3_MSBLQL == '1'
                    _lvend := .F.
                    _cErro += '[Cod. Vendedor "'+_cCodVend+'"-'+_cNome+" Bloqueado] "
                Endif
            Else
                _cNome := ALLTRIM(_aLinhas[_ni][nColNome])
                _cErro += '[Cod. Vendedor "'+_cCodVend+'"-'+_cNome+" não encontrado] "
                _lvend := .F.
            Endif

            //Valida se não está repetido na lista
            If _lprod
                For _nRep := 1 to Len(_aLinhas)
                    If _lprod .and.  AllTrim(_aLinhas[_nRep][nColPrd]) == AllTrim(SB1->B1_COD) .and. _nRep != _ni .and.;
                            AllTrim(_aLinhas[_nRep][nColVen]) == AllTrim(_cCodVend)
                        _lprod := .F.
                        _cErro += '[Cod. Produto + Cod. Vendedor "'+AllTrim(SB1->B1_COD)+'" + "'+_cCodVend+'" duplicado na tabela linha: '+Alltrim(Str(_nRep))+" ] "
                    Endif
                Next _nRep
            Endif

        END SEQUENCE

        If !EMPTY(_cErro)
            _cErro:="Linha " + StrZero(_ni,6) + " com erro(s): "+ _cErro
            Aadd(_aErros,{.F.,_cErro})
        Endif

        _aLinAux:={}
        _nTot:=Len(_aLinhas)//ULTIMA LINHA DO ARRAY ADIONADA

        Aadd(_aLinAux,EMPTY(_cErro))//COLUNA DAS BOLINHAS VERMELHA E VERDE
        For _nRep := 1 to Len(_aHead)//TODAS AS COLUNAS DO _aLinhas
            IF _nRep <= Len(_aLinhas[_nTot])
                Aadd(_aLinAux,_aLinhas[_nTot,_nRep])
            ELSE
                Aadd(_aLinAux,"")
            ENDIF
        Next _nRep
        Aadd(_aLinAux, _cErro )//COLUCNA DOS ERROS

        Aadd(_aDados,_aLinAux)

    Next I

    _oFile:Close()

    If Len(_aDados) > 0

        _aCab := {}
        Aadd(_aCab," ")//COLUNA DAS BOLINHAS VERMELHA E VERDE
        For _nRep := 1 to Len(_aHead)
            Aadd(_aCab,_aHead[_nRep])
        Next _nRep
        Aadd(_aCab,"Erros")//COLUCNA DOS ERROS

        _aLegenda := {{ "BR_VERDE", "Aceitos"},{"BR_VERMELHO","Rejeitados"} }
        _aButtons:={}
        aAdd(_aButtons,{"",{|| BRWLEGENDA( "Legenda", "Legenda", _aLegenda ) },"","Legenda"} )

       _cMsgTop := 'PARA REALIZAR A GRAVAÇÃO DAS METAS DE VENDAS ACEITAS ABAIXO CLIQUE EM "CONFIRMAR"'
       IF Len(_aErros) > 0
          _cMsgTop += " - Para ver a lista dos "+Alltrim(Str(Len(_aErros)))+' Erros, clique em "Outras Açoões" e depois clique em "Erros" '
          aAdd(_aButtons,{"",{|| U_ITListBox("ERROS: "+ALLTRIM(STR(Len(_aErros))),{"","Erros"},_aErros,,4) },"","Erros"} )
       ENDIF

            //ITListBox( _cTitAux                   ,_aHeader, _aCols , _lMaxSiz,_nTipo, _cMsgTop, _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _aButtons, _aCab , bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk,_aSX1,_lComCab)
        IF  U_ITListBox( 'Ajuste de meta de vendas' , _aCab  , _aDados, .T.     , 4    , _cMsgTop,          ,         ,         ,     ,        , _aButtons)
            _aLinhas := {}
            For _nRep := 1 to Len(_aDados)
                IF _aDados[_nRep][1]
                    aDel(_aDados[_nRep],1)//Remove a primeira coluna
                    Aadd(_aLinhas,_aDados[_nRep])
                ENDIF
            Next _nRep
            lGravouDados:=.T.
            FwMsgRun( ,{|oProc| _aAlias := AOMS063A(_aLinhas,_aHead,oProc) } , 'Aguarde!' , 'Importando metas...' )
        Endif
    Endif

Return

/*
===============================================================================================================================
Programa--------: AOMS063A
Autor-----------: Josué Danich Prestes
Data da Criacao-: 29/03/2018
Descrição-------: Ajusta metas de vendas
Parametros------: _aLista - dados
                  _aHead - cabecalho
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063A(_aLista,_aHead,oProc)

    Local _ni       := 0 as Numeric
    Local _aErros   := {} as array
    Local _cprod    := "N/C" as char
    Local _cvend    := "N/C" as char
    Local aVend     := {} as array
    Local nAlterados:= 0 as numeric
    Local _nOpcao   := 0 as numeric

    SA3->(DbSetOrder(1))
    ZZS->(DbSetOrder(6))//ZZS_FILIAL+ZZS_ANOMES+ZZS_COD+ZZS_COOR
    _nCont:=0
    _cReg:=AllTrim(Str(Len(_aLista)))
    _aAlterados := {}
    For _ni := 1 to Len(_aLista)

        _nCont++
        oProc:cCaption := ( "1/2 - Verificando Metas: " + StrZero(_nCont,5) + " de " + _cReg + ". Alterações: "+StrZero((nAlterados),6) )
        ProcessMessages()
        _cCodVend:=_aLista[_ni][nColVen]
        _cCodProd:=U_ITKey(_aLista[_ni][nColPrd],"ZZS_COD")

        //Procura se existe o produto e vendedor e deleta
        If (ZZS->(MsSeek(xfilial("ZZS")+AllTrim(MV_PAR01)+_cCodProd+_cCodVend ) ))

            If _nOpcao = 2 // "NÃO" - ENQUANTO O CODIGO DO VENDEDOR ESTIVER NA TABELA aVend LOOP SEM PERGUNTAR
                IF Ascan(aVend,AllTrim(ZZS->ZZS_COOR)) > 0
                    LOOP // *** LOOP *** //
                Else
                    _nOpcao = 0 //PERGUNTO DE NOVO NO PROXIMO VEDENDOR
                Endif

            ElseIf _nOpcao = 3 // "SIM" - ENQUANTO O CODIGO DO VENDEDOR ESTIVER NA TABELA aVend GRAVA A LINHA SEM PERGUNTAR
                If Ascan(aVend,AllTrim(ZZS->ZZS_COOR)) = 0
                    _nOpcao = 0 //PERGUNTO DE NOVO NO PROXIMO VEDENDOR
                Endif

            Endif

            If _nOpcao = 0 //PERGUNTAR
              _nOpcao:=AVISO("AOMS063A - Todos os dados das Metas serão sobrescritos pelos dados da tabela desse vendedor.","Já Existem dados gravados para o mês "+MV_PAR01+" do vendedor "+ZZS->ZZS_COOR+'-'+AllTrim(ZZS->ZZS_NMCOOR)+" importado, sobscrever?",;
                            {"SIM p/ Todos",;   // 01
                             "NÃO"         ,;   // 02
                             "SIM"         ,;   // 03
                             "NÃO p/ Todos"} ,2)// 04
            Endif

            If Ascan(aVend,AllTrim(ZZS->ZZS_COOR)) = 0
               Aadd(aVend,AllTrim(ZZS->ZZS_COOR))
            Endif

            If _nOpcao = 4 // "NÃO p/ Todos" - Sair do FOR
                U_ITMSG("Serão somente processadas as metas não existentes e ACEITAS de todos os vendedores/coordenadores dessa integração para o periodo selecionado.","Atenção",,3)
                EXIT //*** SAIR DO FOR ***//
            ElseIf _nOpcao = 2// "NÃO" - 1o LOOP DO "NÃO"
                LOOP // *** LOOP *** //
            Endif

            AADD(_aAlterados,ZZS->(Recno()))
            nAlterados++

        Endif

    NEXT _ni

    _ni:=0
    nGravados:=0
    _nErros:=0
    lGravouDados:=.F.
    SB1->(DbSetOrder(1))
    ZZS->(DbSetOrder(6))//ZZS_FILIAL+ZZS_ANOMES+ZZS_COD+ZZS_COOR
    _nCont:=0
    _aErros:={}
    _cReg:=AllTrim(Str(Len(_aLista)))

    For _ni := 1 to Len(_aLista)

        _nCont++
        oProc:cCaption := ( "2/2 - Incluindo Metas: " + StrZero(_nCont,5) + " de " + _cReg + ". Erros: "+StrZero(_nErros,6) )
        ProcessMessages()

        _cCodVend:=_aLista[_ni][nColVen]
        _cCodProd:=U_ITKey(_aLista[_ni][nColPrd],"ZZS_COD")
        _cUnidade:=UPPER(ALLTRIM(_aLista[_ni][nColUM]))
        _cErro   :=""

        _lprod := .T.
        If SB1->(MsSeek(xfilial("SB1")+_cCodProd))
            _cprod := ALLTRIM(SB1->B1_DESC)
            If SB1->B1_MSBLQL == '1'
                _lprod := .F.
                _cErro += '[Cod. Produto "'+_cCodProd+'" Bloqueado] '
            ElseIF ALLTRIM(SB1->B1_UM) <> _cUnidade .AND. ALLTRIM(SB1->B1_SEGUM) <> _cUnidade .AND.  ALLTRIM(SB1->B1_I_3UM) <> _cUnidade
                _lprod := .F.
                _cErro += '[UM "'+_cUnidade+'" do Produto "'+_cCodProd+'" Invalida, 1UM: "'+SB1->B1_UM+'", 2UM: "'+SB1->B1_SEGUM+'", 3UM: "'+SB1->B1_I_3UM+'".] '
            Endif
        Else
            _cErro += '[Cod. Produto "'+_cCodProd+'"  não encontrado] '
            _lprod := .F.
            _cprod := "N/C "+_aLista[_ni][nColNprd]
        Endif

        _lvend := .T.
        If SA3->(MsSeek(xfilial("SA3")+_cCodVend))
            _cvend := AllTrim(SA3->A3_NOME)
            If SA3->A3_MSBLQL == '1'
                _lvend := .F.
                _cErro += '[Cod. Vendedor "'+_cCodVend+'"-'+_cvend+" Bloqueado] "
            Endif
        Else
            _cErro += '[Cod. Vendedor "'+_cCodVend+'"-'+_cvend+" não encontrado] "
            _lvend := .F.
            _cvend := "N/C "+_aLista[_ni][nColNome]
        Endif

        If !_lprod .or. !_lvend
           _nErros++
           Aadd(_aErros,{.F.,_aLista[_ni][1],;
                         _cCodVend,_cvend,;
                         _cCodProd,_cprod,;
                         _aLista[_ni][nColVol],;
                         _cUnidade, 0,;
                         SB1->B1_UM,0,;
                         SB1->B1_SEGUM,0,;
                         SB1->B1_I_3UM,;
                         _aLista[_ni][nColVal],;
                         _cErro})
        Else

            //Procura se existe o produto e Coord/vendedor, e inclui se não achar, e altera se achar
            _lAchouAlt:=(ZZS->(MsSeek(xfilial("ZZS")+AllTrim(MV_PAR01)+_cCodProd+_cCodVend+"   ") ))
            If _lAchouAlt
               _lAchou:=Ascan(_aAlterados,ZZS->(Recno())) > 0//Se achou na lista de alterados, altera, senão não faz nada
            Else
               _lAchou:=.F.
            EndIf
            If !_lAchouAlt .OR. _lAchou//SE NÃO ACHOU OU ACHOU NA LISTA DE ALTERADOS

                //Carrega fator de conversão se existir
                _nQtde1um:=0
                _nQtde2um:=0
                _nQtde3um:=0
                _nfator  :=0
                 //**************************************************
                IF _cUnidade == SB1->B1_UM // Conversão da PRIMEIRA UM para...

                    If SB1->B1_CONV == 0
                        If SB1->B1_I_QQUEI == 'S' .and. SB1->B1_I_FATCO > 0
                            _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_I_FATCO,SB1->B1_I_FATCO)
                        Endif
                    Else
                        _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_CONV,SB1->B1_CONV)
                    Endif
                    _nQtde1um:=_aLista[_ni][nColVol]
                    _nQtde2um:=IF(_nfator>0,_aLista[_ni][nColVol]*_nfator,_aLista[_ni][nColVol])
                    If SB1->B1_I_QQUEI == 'S' .AND. SB1->B1_SEGUM = 'PC' .AND. SB1->B1_I_3UM = 'CX'
                       _nQtde3um:=( _nQtde2um / SB1->B1_I_QT3UM)// Conversão da SEGUNDA UM para a Terceira UM
                    Else
                       _nQtde3um:=( _nQtde1um * SB1->B1_I_QT3UM )// Conversão da PRIMEIRA UM para a Terceira UM
                    Endif

                 //**************************************************
                Elseif _cUnidade == SB1->B1_SEGUM // Conversão da SEGUNDA UM para...

                    If SB1->B1_CONV == 0
                        If SB1->B1_I_QQUEI == 'S' .and. SB1->B1_I_FATCO > 0
                            _nfator := IF(SB1->B1_TIPCONV=="M", 1/SB1->B1_I_FATCO,SB1->B1_I_FATCO)
                        Endif
                    Else
                        _nfator := IF(SB1->B1_TIPCONV=="M", 1/SB1->B1_CONV,SB1->B1_CONV)
                    Endif
                    _nQtde1um:=IF(_nfator>0,_aLista[_ni][nColVol]*_nfator,_aLista[_ni][nColVol])// Conversão da Segunda UM para a Primeira UM

                    _nQtde2um:=_aLista[_ni][nColVol]

                     If SB1->B1_I_QQUEI == 'S' .AND. SB1->B1_SEGUM = 'PC' .AND. SB1->B1_I_3UM = 'CX'
                        _nQtde3um:= _nQtde2um  / SB1->B1_I_QT3UM // Conversão da SEGUNDA UM para a Terceira UM
                     Else
                        _nQtde3um:= _nQtde1um  * SB1->B1_I_QT3UM // Conversão da PRIMEIRA UM para a Terceira UM
                     Endif

                //***************************************************
                ElseIF _cUnidade == SB1->B1_I_3UM  // Conversão da Terceira UM para...

                    _nQtde1um:= _aLista[_ni][nColVol]/ SB1->B1_I_QT3UM// Conversão #Normal* da Terceira UM para a Primeira UM

                    _nQtde3um:= _aLista[_ni][nColVol]

                    If SB1->B1_I_QQUEI == 'S' .AND. SB1->B1_SEGUM = 'PC' .AND. SB1->B1_I_3UM = 'CX'// Se Queijo*

                       _nQtde2um:= _nQtde3um * SB1->B1_I_QT3UM// Conversão da Terceira UM para a Segunda UM

                       If SB1->B1_CONV == 0
                           If SB1->B1_I_QQUEI == 'S' .and. SB1->B1_I_FATCO > 0
                               _nfator := IF(SB1->B1_TIPCONV=="M", 1/SB1->B1_I_FATCO,SB1->B1_I_FATCO)
                           Endif
                       Else
                           _nfator := IF(SB1->B1_TIPCONV=="M", 1/SB1->B1_CONV,SB1->B1_CONV)
                       Endif

                       _nQtde1um:= _nQtde2um * nFator // Conversão da Segunda UM para a Primeira UM

                    Else//Calculo #Normal* se ser queijo
                       If SB1->B1_CONV = 0
                           If SB1->B1_I_QQUEI == 'S' .and. SB1->B1_I_FATCO > 0
                               nFator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_I_FATCO,SB1->B1_I_FATCO)
                           Endif
                       Else
                           nFator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_CONV,SB1->B1_CONV)
                       Endif

                       _nQtde2um:= _nQtde1um * nFator// Conversão da Primeira UM para a Segunda UM

                    EndIf

                Endif

                Aadd(_aErros,{.T.,_aLista[_ni][1],;
                              _cCodVend,_cvend,;
                              _cCodProd,_cprod,;
                              _aLista[_ni][nColVol],;
                              _cUnidade,;
                              _nQtde1um,SB1->B1_UM,;
                              _nQtde2um,SB1->B1_SEGUM,;
                              _nQtde3um,SB1->B1_I_3UM,;
                              _aLista[_ni][nColVal],;
                              IF(_lAchou,"Alterado com sucesso","Incluido com sucesso")})

                ZZS->(Reclock("ZZS",!_lAchou))//"ALTERACAO/IMPORTACAO","INCLUSAO/IMPORTACAO"
                ZZS->ZZS_COD    := SB1->B1_COD
                ZZS->ZZS_DESCR  := SB1->B1_DESC
                ZZS->ZZS_DESCD  := SB1->B1_I_DESCD
                ZZS->ZZS_UM     := SB1->B1_UM
                ZZS->ZZS_2UM    := SB1->B1_SEGUM
                ZZS->ZZS_3UM    := SB1->B1_I_3UM        //Novo
                ZZS->ZZS_COOR   := SA3->A3_COD
                ZZS->ZZS_NMCOOR := SA3->A3_NOME
                ZZS->ZZS_ANOMES := MV_PAR01
                ZZS->ZZS_QTD    := _nQtde1um
                ZZS->ZZS_QTD2UM := _nQtde2um
                ZZS->ZZS_QTD3UM := _nQtde3um            //Novo
                ZZS->ZZS_VALOR  := _aLista[_ni][nColVal]//Novo
                ZZS->ZZS_TIPOV  := SA3->A3_I_TIPV       //Novo
                ZZS->(Msunlock())

                ZGW->(RecLock("ZGW",.T.))//"ALTERACAO/IMPORTACAO","INCLUSAO/IMPORTACAO"
                ZGW->ZGW_FILIAL:= xFilial("ZGW")
                ZGW->ZGW_COD   := ZZS->ZZS_COD
                ZGW->ZGW_DESCR := ZZS->ZZS_DESCR
                ZGW->ZGW_DESCD := ZZS->ZZS_DESCD
                ZGW->ZGW_UM    := ZZS->ZZS_UM
                ZGW->ZGW_QTD   := ZZS->ZZS_QTD
                ZGW->ZGW_QTD2UM:= ZZS->ZZS_QTD2UM
                ZGW->ZGW_2UM   := ZZS->ZZS_2UM
                ZGW->ZGW_QTD3UM:= ZZS->ZZS_QTD3UM//Novo
                ZGW->ZGW_3UM   := ZZS->ZZS_3UM   //Novo
                ZGW->ZGW_VALOR := ZZS->ZZS_VALOR //Novo
                ZGW->ZGW_TIPOV := ZZS->ZZS_TIPOV //Novo
                ZGW->ZGW_DATAM := ZZS->ZZS_DATA  //Novo
                ZGW->ZGW_COOR  := ZZS->ZZS_COOR
                ZGW->ZGW_NMCOOR:= ZZS->ZZS_NMCOOR
                ZGW->ZGW_ANOMES:= ZZS->ZZS_ANOMES
                ZGW->ZGW_OPER  := If(_lAchou,"ALTERACAO/IMPORTACAO","INCLUSAO/IMPORTACAO")
                ZGW->ZGW_USER  := _cUserName
                ZGW->ZGW_DATA  := DATE()
                ZGW->ZGW_HORA  := TIME()
                ZGW->(MsUnLock())

                AOMS063Ger("GERAR_VALORES_POR_DATA",ZZS->ZZS_ANOMES)

                nGravados++
                lGravouDados:=.T.
            Else
                _nErros++
                Aadd(_aErros,{.F.,_aLista[_ni][1],;
                              _cCodVend,_cvend,;
                              _cCodProd,_cprod,;
                              _aLista[_ni][nColVol],;
                              _cUnidade,0,;
                              SB1->B1_UM,0,;
                              SB1->B1_SEGUM,0,;
                              SB1->B1_I_3UM,;
                              _aLista[_ni][nColVal],;
                              "Produto já existe na tabela de metas para esse Coor./vend.: "+xfilial("ZZS")+" "+AllTrim(MV_PAR01)+" "+_cCodProd+" "+_cCodVend})
            Endif
        Endif
    Next _ni

    cChama = "NÃO RECARREGAR"
    If Len(_aErros) > 0
        _aHead2 := {"","Mesano","Cod Vend","Vendedor","Cod Prod","Produto","Volume","Unidade","Qtde 1Um","1Um","Qtde 2Um","2Um","Qtde 3Um","3Um","Valor (R$)","Erros"}
        U_ITListBox( 'Ajuste de meta de vendas' , _aHead2 , _aErros , .T. , 4, "Vendedor(es): Gravados "+AllTrim(Str(nGravados))+ " / Alterados "+AllTrim(Str(nAlterados))+" / Processados "+_cReg+ " / Erros: "+AllTrim(Str(_nErros)) )
        cChama = "RECARREGA"
        oDlgLIb:End()
    Else
        IF lGravouDados
           u_itmsg("Gravacao Concluida Com Sucesso","Atenção","Vendedor(es): Incluidos "+AllTrim(Str(nGravados))+ " / Alterados "+AllTrim(Str(nAlterados))+" / Processados "+  _cReg ,2)
           cChama = "RECARREGA"
           oDlgLIb:End()
        ELSE
           u_itmsg("Nenhum registro Gravado no mes "+AllTrim(MV_PAR01)+". Vendedor(es): Incluidos "+AllTrim(Str(nGravados))+ " / Alterados "+AllTrim(Str(nAlterados))+" / Processados "+  _cReg,"Atenção","Integre em um mês que não tenha metas de ninguem no mês.",2)
        ENDIF
    Endif

Return

/*
===============================================================================================================================
Programa--------: AOMS063R
Autor-----------: Josué Danich Prestes
Data da Criacao-: 18/09/2018
Descrição-------: Relatório de log de metas de vendas
Parametros------: _lLog: .T. - Log  / .F. - Relatório                  
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063R(_lLog)
 If Pergunte( 'AOMS063R' )
    FwMsgRun(,{|oProc|AOMS063S(oProc,_lLog) } ,'Aguarde!','Lendo dados...' )
 EndIf
Return

/*
===============================================================================================================================
Programa--------: AOMS063S
Autor-----------: Josué Danich Prestes
Data da Criacao-: 18/09/2018
Descrição-------: Execução de Relatório de log de metas de vendas
Parametros------: oProc , _lLog: .T. - Log  / .F. - Relatório    
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063S(oProc,_lLog)

 Local cRep    := "" As Char
 Local _cReg   := "" As Char
 Local _aHead  := {} As Array
 Local _alog   := {} As Array
 //Local _aColXML:= {} As Array
 Local _cAlias :=GetNextAlias() As Char
 Local _nCont  := 0 As Numeric
 Local A       := 0 As Numeric

 If _lLog 
    cRep:= " SELECT ZGW_COD,ZGW_DESCR,ZGW_QTD,ZGW_UM,ZGW_QTD2UM,ZGW_2UM,ZGW_COOR,ZGW_NMCOOR,ZGW_ANOMES,ZGW_OPER,ZGW_USER,ZGW_DATA,ZGW_HORA,"
    cRep+= "        ZGW_QTD3UM,ZGW_3UM,ZGW_VALOR,ZGW_DATAM"//Novos
    cRep+= " FROM " + retsqlname("ZGW")
    cRep+= " WHERE ZGW_ANOMES = '"+AllTrim(MV_PAR01)+"'
    If !empty(AllTrim(MV_PAR03))
        cRep+= " AND ZGW_COOR >= '"+ (MV_PAR02) + "' AND ZGW_COOR <= '" + (MV_PAR03) + "' "
    Endif
    If !empty(AllTrim(MV_PAR05))
        cRep+= " AND ZGW_COD >= '"+ (MV_PAR04) + "' AND ZGW_COD <= '" + (MV_PAR05) + "' ""
    Endif
    cRep+= " AND D_E_L_E_T_ = ' ' "
    cRep+= " ORDER BY ZGW_ANOMES,ZGW_NMCOOR,ZGW_DESCR,ZGW_DATAM,ZGW_DATA,ZGW_HORA"
    _cTit:='Log de registros de meta de vendas por Produto/Dia'
 Else
    cRep:= " SELECT ZZS_COD,ZZS_DESCR,ZZS_QTD,ZZS_UM,ZZS_QTD2UM,ZZS_2UM,ZZS_COOR,ZZS_NMCOOR,ZZS_ANOMES,"
    cRep+= "        ZZS_QTD3UM,ZZS_3UM,ZZS_VALOR,ZZS_DATA"//Novos
    cRep+= " FROM " + retsqlname("ZZS")
    cRep+= " WHERE ZZS_ANOMES = '"+AllTrim(MV_PAR01)+"'
    If !empty(AllTrim(MV_PAR03))
        cRep+= " AND ZZS_COOR >= '"+ (MV_PAR02) + "' AND ZZS_COOR <= '" + (MV_PAR03) + "' "
    Endif
    If !empty(AllTrim(MV_PAR05))
        cRep+= " AND ZZS_COD >= '"+ (MV_PAR04) + "' AND ZZS_COD <= '" + (MV_PAR05) + "' ""
    Endif
    cRep+= " AND D_E_L_E_T_ = ' ' "
    cRep+= " ORDER BY ZZS_ANOMES,ZZS_NMCOOR,ZZS_DESCR,ZZS_DATA"
    _cTit:='Relatorio de registros de meta de vendas por Produto/Dia'
 Endif
 
 MPSysOpenQuery( cRep , _cAlias)

 _nCont:=0
 _cReg:=0
 dbSelectArea(_cAlias)
  COUNT TO _cReg
 _cReg:=AllTrim(Str(_cReg))
 (_cAlias)->(dbGoTop())

 Do While (_cAlias)->(!EoF())

     _nCont++
     oProc:cCaption := ( "Lendo Metas: " + StrZero(_nCont,5) + " de " + _cReg)
     ProcessMessages()

     If _lLog 
       cTipoor:= POSICIONE("SA3",1,xFilial("SA3")+(_cAlias)->ZGW_COOR,"A3_I_TIPV")//V=VENDEDOR;C=COORDENADOR;G=GERENTE;S=SUPERVISOR;N=GERENCIA NACIONAL
     ELSE
       cTipoor:= POSICIONE("SA3",1,xFilial("SA3")+(_cAlias)->ZZS_COOR,"A3_I_TIPV")//V=VENDEDOR;C=COORDENADOR;G=GERENTE;S=SUPERVISOR;N=GERENCIA NACIONAL
     ENDIF
     IF cTipoor == "V"
         cTipoor:= "Vendedor"
     ELSEIF cTipoor == "C"
         cTipoor:= "Coordenador"
     ELSEIF cTipoor == "G"
         cTipoor:= "Gerente"
     ELSEIF cTipoor == "S"
         cTipoor:= "Supervisor"
     ELSEIF cTipoor == "N"
         cTipoor:= "Gerencia Nacional"
     ELSE
         cTipoor:= "Tipo de Vendedor não encontrado"
     ENDIF

     If _lLog 
        Aadd(_alog,{STod((_cAlias)->ZGW_DATA) ,;//01
                         (_cAlias)->ZGW_HORA  ,;//02
                         (_cAlias)->ZGW_USER  ,;//03
                         (_cAlias)->ZGW_ANOMES,;//04
                         (_cAlias)->ZGW_OPER  ,;//05
                         (_cAlias)->ZGW_COOR  ,;//06
                         (_cAlias)->ZGW_NMCOOR,;//07
                         (_cAlias)->ZGW_COD   ,;//08
                         (_cAlias)->ZGW_DESCR ,;//09
                    STOD((_cAlias)->ZGW_DATAM),;//10
                         (_cAlias)->ZGW_QTD   ,;//11*
                         (_cAlias)->ZGW_UM    ,;//12
                         (_cAlias)->ZGW_QTD2UM,;//13*
                         (_cAlias)->ZGW_2UM   ,;//14
                         (_cAlias)->ZGW_QTD3UM,;//15*
                         (_cAlias)->ZGW_3UM   ,;//16
                         (_cAlias)->ZGW_VALOR ,;//17*
                         cTipoor              })//18
     Else
        Aadd(_alog,{     (_cAlias)->ZZS_ANOMES,;//01
                         (_cAlias)->ZZS_COOR  ,;//02
                         (_cAlias)->ZZS_NMCOOR,;//03
                         (_cAlias)->ZZS_COD   ,;//04
                         (_cAlias)->ZZS_DESCR ,;//05
                    STOD((_cAlias)->ZZS_DATA) ,;//06
                         (_cAlias)->ZZS_QTD   ,;//07*
                         (_cAlias)->ZZS_UM    ,;//08
                         (_cAlias)->ZZS_QTD2UM,;//09*
                         (_cAlias)->ZZS_2UM   ,;//10
                         (_cAlias)->ZZS_QTD3UM,;//11*
                         (_cAlias)->ZZS_3UM   ,;//12
                         (_cAlias)->ZZS_VALOR ,;//13*
                         cTipoor              })//14
     Endif
     (_cAlias)->(Dbskip())

 Enddo

 //_aColXML:=AClone(_alog)

 For A := 1 TO Len(_alog)
     If _lLog 
        _alog[A,11]:= AllTrim(Trans(_alog[A,11],"@E 999,999,999.99"))//11*
        _alog[A,13]:= AllTrim(Trans(_alog[A,13],"@E 999,999,999.99"))//13*
        _alog[A,15]:= AllTrim(Trans(_alog[A,15],"@E 999,999,999.99"))//15*
        _alog[A,17]:= AllTrim(Trans(_alog[A,17],"@E 999,999,999.99"))//17*
    Else
        _alog[A,07]:= AllTrim(Trans(_alog[A,07],"@E 999,999,999.99"))//07*
        _alog[A,09]:= AllTrim(Trans(_alog[A,09],"@E 999,999,999.99"))//09*
        _alog[A,11]:= AllTrim(Trans(_alog[A,11],"@E 999,999,999.99"))//11*
        _alog[A,13]:= AllTrim(Trans(_alog[A,13],"@E 999,999,999.99"))//13*
    Endif
 Next A

 (_cAlias)->(dbCloseArea())

 If Len(_alog) > 0

    If _lLog 
       _aHead:={"Data Manut.",;//01
                "Hora"       ,;//02
                "Usuário"    ,;//03
                "Ano/Mês"    ,;//04
                "Operação"   ,;//05
                "Cod Vend"   ,;//06
                "Vendedor"   ,;//07
                "Cod Prod"   ,;//08
                "Produto"    ,;//09
                "Data Meta"  ,;//10
                "Qtde 1 Um"  ,;//11
                "1a Um"      ,;//12
                "Qtde 2Um"   ,;//13
                "2a Um"      ,;//14
                "Qtde 3Um"   ,;//15
                "3a Um"      ,;//16
                "Valor"      ,;//17
                "Tipo"       } //18
    Else
       _aHead:={"Ano/Mês"    ,;//01
                "Cod Vend"   ,;//02
                "Vendedor"   ,;//03
                "Cod Prod"   ,;//04
                "Produto"    ,;//05
                "Data Meta"  ,;//06
                "Qtde 1 Um"  ,;//07
                "1a Um"      ,;//08
                "Qtde 2Um"   ,;//09
                "2a Um"      ,;//10
                "Qtde 3Um"   ,;//11
                "3a Um"      ,;//12
                "Valor (R$)" ,;//13
                "Tipo"       } //14
    Endif
     U_ITListBox( _cTit , _aHead , _alog , .T. , 1,  )
 Else
     u_itmsg("Não foram Localizados registros de log para os parâmetros indicados.","Atenção","Altere os filtros e tente novamente.",1)
 Endif

Return

/*
===============================================================================================================================
Programa--------: AOMS063M
Autor-----------: Julio de Paula Paz
Data da Criacao-: 04/02/2019
Descrição-------: Gatilho para preenchimento dos campos de somente leitura do aCols para a tabela ZZS.
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AOMS063M()
 Local _cCodProd := "" As char
 Local _nPosDesc := 0 As Numeric
 Local _nPosDesD := 0 As Numeric
 Local _nPosUM   := 0 As Numeric
 Local _nPos2UM  := 0 As Numeric
 Local _nPos3UM  := 0 As Numeric
 //If IsInCallStack("AOMS063IM")//INCLUSAO, MAS NA TROCA DE LINHA CARREGA DE NOVO
     _cCodProd := M->ZZS_COD
     _nPosDesc := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCR'} )
     _nPosDesD := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_DESCD'} )
     _nPosUM   := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_UM'   } )
     _nPos2UM  := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_2UM'  } )
     _nPos3UM  := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_3UM'  } )
     aCols[N,_nPosDesc] := Posicione("SB1",1,Xfilial("SB1")+_cCodProd,"B1_DESC")
     aCols[N,_nPosDesD] := SB1->B1_I_DESCD
     aCols[N,_nPosUM  ] := SB1->B1_UM
     aCols[N,_nPos2UM ] := SB1->B1_SEGUM
     aCols[N,_nPos3UM ] := SB1->B1_I_3UM
 //EndIf
Return .T.


/*
===============================================================================================================================
Programa--------: AOMS063X
Autor-----------: Alex Wallauer
Data da Criacao-: 29/05/2025
Descrição-------: Gera Excel ou xml dos dados da tela
Parametros------: _lXML: .T. gera XML senão Excel
Retorno---------: .T.
===============================================================================================================================
*/
Static Function AOMS063X(_lXML)
 Local _lComCab := .T. As Logical
 Local _cTitAux := "Metas de "+SUBSTR(cAnoMes,5,2)+"/"+SUBSTR(cAnoMes,1,4)+" do "+Lower(cTipoor)+" "+cCoord+" - "+cNmCoor As Char
 Local _aCabExc := {} As Array
 Local _aLinhas := {} As Array
 Local _aLinAux := AClone(aCols) As Array
 Local _nRep    := 0 As Numeric

 //    Array com o cabeçalho das colunas do relatório.
 //    Alinhamento( 1-Left,2-Center,3-Right )
 //    Formatação( 1-General,2-Number,3-Monetário,4-DateTime )
 //                        Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
 AADD(_aCabExc,{"Cod. Produto"                ,2           ,1         ,.F.})
 AADD(_aCabExc,{"Descricao Produto"           ,1           ,1         ,.F.})
 AADD(_aCabExc,{"Descricao Completa"          ,1           ,1         ,.F.})
 AADD(_aCabExc,{"Quantidade 1a UM"            ,3           ,2         ,.F.})
 AADD(_aCabExc,{"1a UM"                       ,2           ,1         ,.F.})
 AADD(_aCabExc,{"Quantidade 2a UM"            ,3           ,2         ,.F.})
 AADD(_aCabExc,{"2a UM"                       ,2           ,1         ,.F.})
 AADD(_aCabExc,{"Quantidade 3a UM"            ,3           ,2         ,.F.})
 AADD(_aCabExc,{"3a UM"                       ,2           ,1         ,.F.})
 AADD(_aCabExc,{"Valor"                       ,3           ,3         ,.F.})

 _aLinhas:= {}
 For _nRep := 1 to Len(_aLinAux)
     aDel(_aLinAux[_nRep], Len(_aLinAux[_nRep]) )//Remove a ultima coluna do Del
     aSize(_aLinAux[_nRep],Len(_aLinAux[_nRep])-1)
     Aadd(_aLinhas, _aLinAux[_nRep] )
 Next _nRep

 IF _lXML
    //ITGEREXCEL(_cNomeArq,_cDiretorio,_cTitulo,_cNomePlan,_aCabecalho,_aDetalhe,_lLeTabTemp,_cAliasTab,_aCampos,_lScheduller,_lCriaPastas,_aPergunte,_lEnviaEmail,_lXLSX,_lComCab
    //Exportação para Excel (.XML)
    FWMSGRUN( ,{|_oProc| U_ITGEREXCEL(,,_cTitAux,,_aCabExc,_aLinhas,,,,,,,,.F.,_oProc,_lComCab),;
                         U_ITMSG("Geração Concluida!  ["+DTOC(DATE())+"] ["+TIME()+"]") },;
                         "H.I. : "+TIME()+" - Aguarde...","Gerando Excel (.XML)..."  )
 Else
    //Exportação para Excel (.XLSX)
    FWMSGRUN( ,{|_oProc| U_ITGEREXCEL(,,_cTitAux,,_aCabExc,_aLinhas,,,,,,,,.T.,_oProc,_lComCab),;
                         U_ITMSG("Geração Concluida!  ["+DTOC(DATE())+"] ["+TIME()+"]") },;
                         "H.I. : "+TIME()+" - Aguarde...","Gerando Excel (.XLSX)..." )
 Endif

Return .T.


/*
===============================================================================================================================
Programa--------: AOMS063MD
Autor-----------: Alex Wallauer
Data da Criacao-: 04/06/2025
Descrição-------: Manutenção do % diario
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063MD()

 Local _cTitulo  := "Manutenção do % de meta diário" As Char
 Local nGDAction := 0 As Numeric
 Local _aSize    := {} As Array
 Local _aInfo    := {} As Array
 Local aObjects  := {} As Array
 Local aPosObj   := {} As Array
 Local _aAnos    := {} As Array
 Local _aAnosGrv := {} As Array
 Local _dDataAtual:= dDataBase As Date
 Local _cAnoAtual:= LEFT(DTOS(_dDataAtual),4) As Char
 Local _cAno     := LEFT(DTOS(_dDataAtual),4) As Char
 Local _cAnoAux  := "" As Char
 Local _nAno     := 00 As Numeric
 Local _nOpca    := 00 As Numeric
 Local nLinha    := 10 As Numeric
 Local oOrdem          As Object
 Local oBotao1         As Object
 Local oBotao2         As Object
 Local oBotao3         As Object
 Local oBotao4         As Object
 Local oBotao5         As Object
 Local oDlg2           As Object
 Local oDlgAno         As Object
 Private oMsMGet       As Object
 Private aHeader := {} As Array
 Private aCols   := {} As Array

for _nAno := (Year(_dDataAtual)-5) to (Year(_dDataAtual)+10)
    IF ZPA->(MsSeek(xFilial("ZPA")+StrZero(_nAno,4)))
       Aadd(_aAnos,StrZero(_nAno,4)+" (I)")
       IF _cAno = StrZero(_nAno,4)
          _cAno:= StrZero(_nAno,4)+" (I)"
       Endif
    ELSE
       Aadd(_aAnos,StrZero(_nAno,4))
    Endif
next _nAno

For _nAno := (Year(_dDataAtual)-15) to (Year(_dDataAtual)+15)
    IF ZPA->(MsSeek(xFilial("ZPA")+StrZero(_nAno,4)))
       Aadd(_aAnosGrv,StrZero(_nAno,4))
    Endif
Next _nAno

 DO While .T.
    nGDAction:=-1
    DEFINE MSDIALOG oDlgAno FROM 0,0 TO 200,300 PIXEL TITLE 'Escolha o ano e a manutenção'

         nLinha:= 25
       @ nLinha,10 ComboBox _cAno ITEMS _aAnos Size 35,10 Object oOrdem
       @ nLinha,55 Button "Visualizar"         Size 55,12 PIXEL OF oDlgAno action (nGDAction:=0,oDlgAno:end())
         nLinha+= 15
       @ nLinha,55 Button "Incluir / Alterar"  Size 55,12 PIXEL OF oDlgAno action (nGDAction:=GD_UPDATE,oDlgAno:end())
         nLinha+= 15
       @ nLinha,55 Button "Excluir"            Size 55,12 PIXEL OF oDlgAno action (nGDAction:=GD_DELETE,oDlgAno:end())
         nLinha+= 15
       @ nLinha,55 Button "Voltar"             Size 55,12 PIXEL OF oDlgAno action (nGDAction:=-1,oDlgAno:end())
         nLinha+= 20
       @ 10,05 To nLinha,130 Title " Escolha o ano e a manutenção: "

    ACTIVATE MSDIALOG oDlgAno CENTERED

    IF nGDAction = -1
       Return .f.
    EndIf
    _cSalvaAno:=_cAno //Variavel auxiliar para o ano
    _cAno:=LEFT(_cAno,4)

    IF nGDAction = 0 .and. !ZPA->(MsSeek(xFilial("ZPA")+_cAno)) //CRIA DE NÃO TIVER AINDA

       IF !U_ITMSG("Ano não cadastrodo.",'Atenção!',"Deseja cadastrar?",2,2,3,,"CONFIRMA","VOLTAR")
          _cAno:=_cSalvaAno
          LOOP
       EndIf
       nGDAction:= GD_UPDATE

    ElseIF nGDAction = GD_DELETE

       IF ZPA->(MsSeek(xFilial("ZPA")+_cAno))
          If _cAnoAtual <= _cAno .And. !ALLTRIM(GETENVSERVER()) == "HOMOLOGACAO_ALEXANDRO"
             u_itmsg("Não é possível excluir o ano atual ou inferior: "+_cAno,"Atenção",,3)
             _cAno:=_cSalvaAno
             LOOP
          EndIf
       Else
          u_itmsg("Registros não encontrado para o ano "+_cAno,"Atenção",,3)
          _cAno:=_cSalvaAno
          Loop
       EndIF

       IF !U_ITMSG("Confirma a exclusao do Ano de "+_cAno+' ?','Atenção!',,2,2,3,,"CONFIRMA","VOLTAR")
          _cAno:=_cSalvaAno
          LOOP
       EndIf

       FwMsgRun( ,{|oProc| AOMS063Ger("EXCLUIR_META_ANUAL",_cAno) }, 'Aguarde!' , 'Excluindo as datas/metas...'  )
       Return .T.
    EndIf

    EXIT

 Enddo

 FwMsgRun( ,{|oProc| AOMS063Ger("LER_META_ANUAL",_cAno) }, 'Aguarde!' , 'Carregando as datas/metas...'  )

 _bTotais:={|| FwMsgRun( ,{|oProc| AOMS063Ger("SOMAR_PERCENTUAL",,,oMsMGet) }, 'Aguarde!' , 'Somando % por mes...'  )  }

 // pega tamanhos das telas
 _aSize := MsAdvSize()
 _aInfo := { _aSize[1] , _aSize[2] , _aSize[3] , _aSize[4] , 1 , 1 }

 aObjects := {}
 aAdd( aObjects, { 100 , 100 , .T. , .T. } )
 aAdd( aObjects, { 100 , 100 , .T. , .T. } )
 aAdd( aObjects, { 100 , 100 , .T. , .T. } )
 aPosObj := MsObjSize( _aInfo , aObjects )
 _cAnoAux:= _cAno //Variavel auxiliar para o ano
 DO WHILE .T.

    _nOpca:= 0
    DEFINE MSDIALOG oDlg2 TITLE _cTitulo+" do Ano "+_cAno OF oMainWnd PIXEL FROM _aSize[7],0 TO _aSize[6],_aSize[5]

      IF nGDAction = GD_UPDATE
         @ 005,050 Button "GRAVAR" Size 55,13 Action ( _nOpca := 3 , oDlg2:End() ) Object oBotao1
         @ 005,110 Button "TOTAIS" Size 55,13 Action ( Eval(_bTotais)            ) Object oBotao2
         @ 005,170 Button "SAIR"   Size 55,13 Action ( _nOpca := 0 , oDlg2:End() ) Object oBotao3
      Else
         _nAlt :=30
         _nLarg:=99
         _nCol :=50
         @ 005,_nCol BTNBMP oBotao1 RESOURCE "VOLTAR2_OCEAN"      SIZE _nLarg,_nAlt PIXEL OF oDlg2 ACTION ( _nOpca := -2 , oDlg2:End() )
         _nCol+=100
         @ 005,_nCol BTNBMP oBotao2 RESOURCE "VOLTAR_OCEAN"       SIZE _nLarg,_nAlt PIXEL OF oDlg2 ACTION ( _nOpca := -1 , oDlg2:End() )
         _nCol+=100
         @ 005,_nCol BTNBMP oBotao3 RESOURCE "AVANCAR_OCEAN.BMP"  SIZE _nLarg,_nAlt PIXEL OF oDlg2 ACTION ( _nOpca :=  1 , oDlg2:End() )
         _nCol+=100
         @ 005,_nCol BTNBMP oBotao4 RESOURCE "AVANCAR2_OCEAN.BMP" SIZE _nLarg,_nAlt PIXEL OF oDlg2 ACTION ( _nOpca :=  2 , oDlg2:End() )
         _nCol+=100
         @ 005,_nCol BTNBMP oBotao5 RESOURCE "FINAL_OCEAN.BMP"    SIZE 030,030      PIXEL OF oDlg2 ACTION ( _nOpca :=  0 , oDlg2:End() )
      endif

      ///***********************  MSNEWGETDADOS() *************************
                              //[ nTop]          , [ nLeft]   , [ nBottom] , [ nRight ] , [ nStyle],cLinhaOk,cTudoOk,cIniCpos, [ aAlter], [ nFreeze], [ nMax], [ cFieldOk], [ cSuperDel], [ cDelOk], [ oWnd], [ aPartHeader], [ aParCols], [ uChange], [ cTela], [ aColsSize]
      oMsMGet := MsNewGetDados():New(25,aPosObj[3,2],aPosObj[3,3],aPosObj[3,4],nGDAction ,        ,       ,        ,          ,           ,        ,            ,             ,          ,oDlg2   ,aHeader        , aCols     ,)
      oDlg2:lMaximized:=.T.

    ACTIVATE MSDIALOG oDlg2

    if _nOpca = 0 //Sair

       EXIT

    Elseif _nOpca = 3 //GRAVAR

       _cMeses:= ""
       FwMsgRun( ,{|oProc| _cMeses:=AOMS063Ger("SOMAR_PERCENTUAL",,,oMsMGet) }, 'Aguarde!' , 'Somando % por mes...'  )
       IF !Empty(_cMeses)
          u_itmsg("O(s) mes(es) de "+_cMeses+" não esta com 100 % na somatoria.","Atenção","Acerte e grave novamente.",3)
          Loop
       EndIF
       FwMsgRun( ,{|oProc| AOMS063Ger("GRAVAR_META_ANUAL",_cAno) }, 'Aguarde!' , 'Gravando as datas/metas...'  )
       u_itmsg("Gravacao concluida com sucesso","Atenção",,2)
       Exit

    Elseif _nOpca = -2 //PRIMEIRO

       nPos:=1

    Elseif _nOpca = -1//VOLTA UM

       nPos:=ASCAN(_aAnosGrv,_cAno)
       IF nPos > 1
          nPos--
       Else
          nPos:=1
       EndIF

    Elseif _nOpca = 1//AVANCAO 1

       nPos:=ASCAN(_aAnosGrv,_cAno)
       IF nPos < (Len(_aAnosGrv)-1)
          nPos++
       Else
          nPos:=Len(_aAnosGrv)
       EndIF

    Elseif _nOpca = 2//ULTIMO

       nPos:=Len(_aAnosGrv)

    EndIf

    _cAno:=_aAnosGrv[nPos]
    _cAnoAux:=LEFT(_cAno,4) //Pega só o ano
    IF ZPA->(MsSeek(xFilial("ZPA")+_cAnoAux))
       FwMsgRun( ,{|oProc| AOMS063Ger("LER_META_ANUAL",_cAnoAux) }, 'Aguarde!' , 'Carregando as datas/metas...'  )
       _cAno:=_cAnoAux
    Endif

ENDDO

Return .T.

/*
===============================================================================================================================
Programa--------: AOMS063Ger
Autor-----------: Alex Wallauer
Data da Criacao-: 04/06/2025
Descrição-------: Leitura e geracao da Manutenção do % diario
Parametros------: _cAcao as char , _cAnoMes as char, _cCoord as char , oMsMGet as Object
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS063Ger(_cAcao as char,_cAnoMes as char ,_cCoord as char , oMsMGet as Object)
 Local M         := 000 As Numeric
 Local A         := 000 As Numeric
 Local N         := 000 As Numeric
 Local nCol      := 001 as numeric
 Local nPosProd  := 000 As Numeric
 Local _nQtde1um := 000 As Numeric
 Local _nQtde2um := 000 As Numeric
 Local _nQtde3um := 000 As Numeric
 Local _nValorMe := 000 As Numeric
 Local cProd     := " " As Character
 Local _cChave   := " " As Character
 Local _cOperacao:= " " As Character
 Local _cData    := " " As Character
 Local _lAchou   := .F. As Logical
 Local xObj      := Nil As Object
 Local _aAreaZZS := ZZS->(FwGetArea()) //SALVA A AREA DE ZZS INDICE E RECNO

 //************************************//
 IF _cAcao = "GERAR_VALORES_POR_DATA"
 //************************************//
    ZZA->(DbSetOrder(1))//ZPA_FILIAL+ZPA_SDATA
    IF ZPA->(MsSeek(xFilial("ZPA")+_cAnoMes))

       _cChave   := ZZS->ZZS_FILIAL+ZZS->ZZS_ANOMES+ZZS->ZZS_COOR+ZZS->ZZS_COD
       _nQtde1um := ZZS->ZZS_QTD
       _nQtde2um := ZZS->ZZS_QTD2UM
       _nQtde3um := ZZS->ZZS_QTD3UM
       _nValorMe := ZZS->ZZS_VALOR
       _cOperacao:= ALLTRIM(ZGW->ZGW_OPER)+"_DT"

       SB1->(DbSetOrder(1))
       SB1->(MsSeek(xfilial("SB1")+ZZS->ZZS_COD))
       SA3->(DbSetOrder(1))
       SA3->(MsSeek(xfilial("SA3")+ZZS->ZZS_COOR))
       ZZS->(DbSetOrder(7))//ZZS_FILIAL+ZZS_ANOMES+ZZS_COOR+ZZS_COD+ZZS_DATA

       DO While ZPA->(!EOF()) .AND. xFilial("ZPA")+_cAnoMes == ZPA->(ZPA_FILIAL+LEFT(ZPA_SDATA,6))//SÓ ANO + MES
                             //esse campo de ZPA_SDATA é o ano+mes+dia caracter,ex:20250101
          _lAchou:=ZZS->(MsSeek(_cChave+ZPA->ZPA_SDATA)) //ZZS_FILIAL+ZZS_ANOMES+ZZS_COOR+ZZS_COD+ZZS_DATA

          ZZS->(Reclock("ZZS",!_lAchou))
          IF !_lAchou//Se não achou, inclui
             ZZS->ZZS_ANOMES := _cAnoMes
             ZZS->ZZS_COD    := SB1->B1_COD
             ZZS->ZZS_DESCR  := SB1->B1_DESC
             ZZS->ZZS_DESCD  := SB1->B1_I_DESCD
             ZZS->ZZS_UM     := SB1->B1_UM
             ZZS->ZZS_2UM    := SB1->B1_SEGUM
             ZZS->ZZS_3UM    := SB1->B1_I_3UM
             ZZS->ZZS_COOR   := SA3->A3_COD
             ZZS->ZZS_NMCOOR := SA3->A3_NOME
             ZZS->ZZS_TIPOV  := SA3->A3_I_TIPV
             ZZS->ZZS_DATA   := STOD(ZPA->ZPA_SDATA)
          EndIf
          ZZS->ZZS_QTD    := ((_nQtde1um*ZPA->ZPA_PERCE)/100)
          ZZS->ZZS_QTD2UM := ((_nQtde2um*ZPA->ZPA_PERCE)/100)
          ZZS->ZZS_QTD3UM := ((_nQtde3um*ZPA->ZPA_PERCE)/100)
          ZZS->ZZS_VALOR  := ((_nValorMe*ZPA->ZPA_PERCE)/100)
          ZZS->(Msunlock())

          ZGW->(RecLock("ZGW",.T.))//_cOperacao+"_DT"
          ZGW->ZGW_FILIAL := xFilial("ZGW")
          ZGW->ZGW_COD    := ZZS->ZZS_COD
          ZGW->ZGW_DESCR  := ZZS->ZZS_DESCR
          ZGW->ZGW_DESCD  := ZZS->ZZS_DESCD
          ZGW->ZGW_UM     := ZZS->ZZS_UM
          ZGW->ZGW_QTD    := ZZS->ZZS_QTD
          ZGW->ZGW_QTD2UM := ZZS->ZZS_QTD2UM
          ZGW->ZGW_2UM    := ZZS->ZZS_2UM
          ZGW->ZGW_QTD3UM := ZZS->ZZS_QTD3UM//Novo
          ZGW->ZGW_3UM    := ZZS->ZZS_3UM   //Novo
          ZGW->ZGW_VALOR  := ZZS->ZZS_VALOR //Novo
          ZGW->ZGW_TIPOV  := ZZS->ZZS_TIPOV //Novo
          ZGW->ZGW_DATAM  := ZZS->ZZS_DATA  //Novo
          ZGW->ZGW_COOR   := ZZS->ZZS_COOR
          ZGW->ZGW_NMCOOR := ZZS->ZZS_NMCOOR
          ZGW->ZGW_ANOMES := ZZS->ZZS_ANOMES
          ZGW->ZGW_OPER   := _cOperacao
          ZGW->ZGW_USER   := _cUserName
          ZGW->ZGW_DATA   := DATE()
          ZGW->ZGW_HORA   := TIME()
          ZGW->(MsUnLock())

          ZPA->(DbSkip())
       EndDo
       FwRestArea(_aAreaZZS)//VOLTA A AREA DE ZZS INDICE E RECNO
    EndIf

 //************************************************************************************//
 ElseIF _cAcao = "EXCLUIR_VALORES_POR_DATA"
 //************************************************************************************//
    ZZS->(DbSetOrder(7))//ZZS_FILIAL+ZZS_ANOMES+ZZS_COOR+ZZS_COD+ZZS_DATA
    _cChave   := ZZS->ZZS_FILIAL+ZZS->ZZS_ANOMES+ZZS->ZZS_COOR+ZZS->ZZS_COD
    _lAchou   := ZZS->(MsSeek(_cChave)) //ZZS_FILIAL+ZZS_ANOMES+ZZS_COOR+ZZS_COD+ZZS_DATA
    _cOperacao:= ALLTRIM(ZGW->ZGW_OPER)+"_DT"

    DO While ZZS->(!EOF()) .AND. _cChave == ZZS->(ZZS_FILIAL+ZZS_ANOMES+ZZS_COOR+ZZS_COD)
       IF EMPTY(ZZS->ZZS_DATA)
          ZZS->(Dbskip())
          Loop
       Endif
       ZGW->(RecLock("ZGW",.T.))//_cOperacao+"_DT"
       ZGW->ZGW_FILIAL := xFilial("ZGW")
       ZGW->ZGW_COD    := ZZS->ZZS_COD
       ZGW->ZGW_DESCR  := ZZS->ZZS_DESCR
       ZGW->ZGW_DESCD  := ZZS->ZZS_DESCD
       ZGW->ZGW_UM     := ZZS->ZZS_UM
       ZGW->ZGW_QTD    := ZZS->ZZS_QTD
       ZGW->ZGW_QTD2UM := ZZS->ZZS_QTD2UM
       ZGW->ZGW_2UM    := ZZS->ZZS_2UM
       ZGW->ZGW_QTD3UM := ZZS->ZZS_QTD3UM//Novo
       ZGW->ZGW_3UM    := ZZS->ZZS_3UM   //Novo
       ZGW->ZGW_VALOR  := ZZS->ZZS_VALOR //Novo
       ZGW->ZGW_TIPOV  := ZZS->ZZS_TIPOV //Novo
       ZGW->ZGW_DATAM  := ZZS->ZZS_DATA  //Novo
       ZGW->ZGW_COOR   := ZZS->ZZS_COOR
       ZGW->ZGW_NMCOOR := ZZS->ZZS_NMCOOR
       ZGW->ZGW_ANOMES := ZZS->ZZS_ANOMES
       ZGW->ZGW_OPER   := _cOperacao
       ZGW->ZGW_USER   := _cUserName
       ZGW->ZGW_DATA   := DATE()
       ZGW->ZGW_HORA   := TIME()
       ZGW->(MsUnLock())

       ZZS->(RecLock("ZZS",.F.))
       ZZS->(DbDelete())
       ZZS->(MsUnLock())
       ZZS->(DbSkip())
    EndDo
    FwRestArea(_aAreaZZS)//VOLTA A AREA DE ZZS INDICE E RECNO

 //************************************************************************************//
 ElseIF _cAcao = "GRAVAR_META_ANUAL"//não usa _cAnoMes
 //************************************************************************************//
    For A := 1 TO 12
       FOR M := 1 TO LEN(aCols)
           IF EMPTY(aCols[M,nCol])//Não tem como o usuario por data em branco , server de controle de meses com mesmo de 31 dias
              LOOP
           EndIf
           _cSData:=DTOS(aCols[M,nCol])
           _nPerc :=aCols[M,(nCol+1)]
           IF ZPA->(MsSeek(xFilial("ZPA")+_cSData))
              ZPA->(RecLock("ZPA",.F.))
              ZPA->ZPA_PERCE:=_nPerc
              ZPA->(MsUnLock())
           ElseiF _nPerc > 0//Só inclui um reg se tiver percentual e data preenchidos
              ZPA->(RecLock("ZPA",.T.))
              ZPA->ZPA_SDATA:=_cSData
              ZPA->ZPA_PERCE:=_nPerc
              ZPA->(MsUnLock())
           Endif
        Next M
        nCol:=nCol+2
    Next A

 //************************************************************************************//
 ElseIf _cAcao = "EXCLUIR_META_ANUAL"//_cAnoMes: Ler Ano 4 digitos
 //************************************************************************************//
    IF ZPA->(MsSeek(xFilial("ZPA")+_cAnoMes))
       DO While ZPA->(!EOF()) .AND. xFilial("ZPA")+_cAnoMes == ZPA->(ZPA_FILIAL+LEFT(ZPA_SDATA,4))
          ZPA->(RecLock("ZPA",.F.))
          ZPA->(DbDelete())
          ZPA->(DbSkip())
       EndDo
       u_itmsg("Registros excluiodos do ano "+_cAnoMes+" com SUCESSO.","Atenção",,2)
    Else
       u_itmsg("Registros não encontrado para o ano "+_cAnoMes,"Atenção",,3)
    EndIF

 //************************************************************************************//
 ElseIf _cAcao = "LER_META_ANUAL"//_cAnoMes: Ler Ano 4 digitos
 //************************************************************************************//

    aHeader:={}
    /////aHeader,{X3_TITULO  ,   CAMPO   ,PICT,Tamanho,D,Validacao        ,USADO,X3_TIPO,ARQUIVO,X3_CONTEXT,X3_CBOX,X3_RELACAO,X3_WHEN,X3_VISUAL,X3_VLDUSER,X3_PICTVAR,X3_OBRIGAT
    Aadd(aHeader,{"Janeiro"  ,"TRB_JAN_D","@D"     ,08,0,"               ","","D","","","","",".F."})
    Aadd(aHeader,{"%"        ,"TRB_JAN_P","@E 99.9",04,1,'U_AOMS063V("%")',"","N","","","","",".T."})
    Aadd(aHeader,{"Fevereiro","TRB_FEV_D","@D"     ,08,0,"               ","","D","","","","",".F."})
    Aadd(aHeader,{"%"        ,"TRB_FEV_P","@E 99.9",04,1,'U_AOMS063V("%")',"","N","","","","",".T."})
    Aadd(aHeader,{"Março"    ,"TRB_MAR_D","@D"     ,08,0,"               ","","D","","","","",".F."})
    Aadd(aHeader,{"%"        ,"TRB_MAR_P","@E 99.9",04,1,'U_AOMS063V("%")',"","N","","","","",".T."})
    Aadd(aHeader,{"Abril"    ,"TRB_ABR_D","@D"     ,08,0,"               ","","D","","","","",".F."})
    Aadd(aHeader,{"%"        ,"TRB_ABR_P","@E 99.9",04,1,'U_AOMS063V("%")',"","N","","","","",".T."})
    Aadd(aHeader,{"Maio"     ,"TRB_MAI_D","@D"     ,08,0,"               ","","D","","","","",".F."})
    Aadd(aHeader,{"%"        ,"TRB_MAI_P","@E 99.9",04,1,'U_AOMS063V("%")',"","N","","","","",".T."})
    Aadd(aHeader,{"Junho"    ,"TRB_JUN_D","@D"     ,08,0,"               ","","D","","","","",".F."})
    Aadd(aHeader,{"%"        ,"TRB_JUN_P","@E 99.9",04,1,'U_AOMS063V("%")',"","N","","","","",".T."})
    Aadd(aHeader,{"Julho"    ,"TRB_JUL_D","@D"     ,08,0,"               ","","D","","","","",".F."})
    Aadd(aHeader,{"%"        ,"TRB_JUL_P","@E 99.9",04,1,'U_AOMS063V("%")',"","N","","","","",".T."})
    Aadd(aHeader,{"Agosto"   ,"TRB_AGO_D","@D"     ,08,0,"               ","","D","","","","",".F."})
    Aadd(aHeader,{"%"        ,"TRB_AGO_P","@E 99.9",04,1,'U_AOMS063V("%")',"","N","","","","",".T."})
    Aadd(aHeader,{"Setembro" ,"TRB_SET_D","@D"     ,08,0,"               ","","D","","","","",".F."})
    Aadd(aHeader,{"%"        ,"TRB_SET_P","@E 99.9",04,1,'U_AOMS063V("%")',"","N","","","","",".T."})
    Aadd(aHeader,{"Outubro"  ,"TRB_OUT_D","@D"     ,08,0,"               ","","D","","","","",".F."})
    Aadd(aHeader,{"%"        ,"TRB_OUT_P","@E 99.9",04,1,'U_AOMS063V("%")',"","N","","","","",".T."})
    Aadd(aHeader,{"Novembro" ,"TRB_NOV_D","@D"     ,08,0,"               ","","D","","","","",".F."})
    Aadd(aHeader,{"%"        ,"TRB_NOV_P","@E 99.9",04,1,'U_AOMS063V("%")',"","N","","","","",".T."})
    Aadd(aHeader,{"Dezembro" ,"TRB_DEZ_D","@D"     ,08,0,"               ","","D","","","","",".F."})
    Aadd(aHeader,{"%"        ,"TRB_DEZ_P","@E 99.9",04,1,'U_AOMS063V("%")',"","N","","","","",".T."})

    IF !ZPA->(MsSeek(xFilial("ZPA")+_cAnoMes)) //CRIA SE NÃO TIVER AINDA - CARGA INICIAL DO ANO SELECIONADO
       For A := 1 TO 31
           _aLinhas:={}
           For M := 1 TO 12
               _cData:=STRZERO(A,2)+"/"+STRZERO(M,2)+"/"+_cAnoMes
               IF !EMPTY(CTOD(_cData))
                  Aadd(_aLinhas,CTOD(_cData))
                  IF A >= 1 .AND. A <= 15// Todos os Meses
                     Aadd(_aLinhas,4)
                  ElseIF A >= 16 .AND. STRZERO(M,2) $ "01,03,05,07,08,10,12" // meses com 31 dias
                     Aadd(_aLinhas,2.5)
                  ElseIF A >= 16 .AND. A <= 22 .AND. STRZERO(M,2) $ "04,06,09,11" // meses com 30 dias
                     Aadd(_aLinhas,2.9)
                  ElseIF A >= 23 .AND. A <= 29 .AND. STRZERO(M,2) $ "04,06,09,11" // meses com 30 dias
                     Aadd(_aLinhas,2.5)
                  ElseIF A = 30 .AND. STRZERO(M,2) $ "04,06,09,11" // meses com 30 dias
                     Aadd(_aLinhas,2.2)
                  ElseIF M = 2 // Fevereiro e Bisexto
                     IF A >= 16 .AND. A <= 21
                        Aadd(_aLinhas,3.3)
                     ElseIF A >= 22 .AND. A <= 27
                        Aadd(_aLinhas,2.9)
                     ElseIF A = 28
                        Aadd(_aLinhas,2.8)
                     ElseIF A = 29
                        Aadd(_aLinhas,0)
                     Endif
                  EndIF
               Else
                  Aadd(_aLinhas,CTOD(""))
                  Aadd(_aLinhas,0)
               EndIF
           Next M
           Aadd(_aLinhas,.F.)
           Aadd(aCols,_aLinhas)
       Next A
    Else//LER SE EXISTE *************************************************************************************//
       _aColAux:={}
       DO While ZPA->(!EOF()) .AND. xFilial("ZPA")+_cAnoMes == ZPA->(ZPA_FILIAL+LEFT(ZPA_SDATA,4))
          AADD(_aColAux,{ ZPA->ZPA_SDATA , ZPA->ZPA_PERCE })
          ZPA->(DbSkip())
       EndDO
       aCols:={}
       For A := 1 TO 31
           _aLinhas:={}
           For M := 1 TO 12
               _cData:=_cAnoMes+STRZERO(M,2)+STRZERO(A,2)
               _nPos:=ASCAN(_aColAux,{ |x| x[1] == _cData })
               IF _nPos > 0
                  Aadd(_aLinhas,STOD(_aColAux[_nPos,1]))
                  Aadd(_aLinhas,_aColAux[_nPos,2])
               Else
                  Aadd(_aLinhas,CTOD(""))
                  Aadd(_aLinhas,0)
               EndIF
           Next
           Aadd(_aLinhas,.F.)
           Aadd(aCols,_aLinhas)
       Next

    EndIf
 //************************************************************************************//
 ElseIf _cAcao = "SOMAR_PERCENTUAL"//não usa _cAnoMes
 //************************************************************************************//
    //Calcula o percentual de cada mes
    aCols:=oMsMGet:aCols
    _aTotais:={}
    _cMeses:=""
    nCol:=1
    For A := 1 TO 12
        FOR M := 1 TO LEN(aCols)
           IF EMPTY(aCols[M,nCol])//Não tem como o usuario por data em branco , server de controle de meses com mesmo de 31 dias
              LOOP
           EndIf
           _cSData:=MesExtenso( Month( aCols[M,nCol]) )
           _nPerc :=aCols[M,(nCol+1)]
           IF (nPos:=ASCAN(_aTotais,{ |D| D[2] = _cSData })) > 0
              _aTotais[nPos,3] += _nPerc
              _aTotais[nPos,1] := (_aTotais[nPos,3] = 100)
           Else
               Aadd(_aTotais,{ .F. ,_cSData , _nPerc })
           EndIf
        Next M
        nCol:=nCol+2
    Next A

    _aColXML:=aClone(_aTotais)

    For A := 1 TO Len(_aTotais)
       IF !_aTotais[A,1] //Se o mes não tem 100% de somatoria
          _cMeses+="["+_aTotais[A,2]+"] "
       EndIf
       _aTotais[A,3]:= Trans(_aTotais[A,3],"@E 999.99")+" %"
    Next A

    _aCabTot:={}
    Aadd(_aCabTot,"   "    )
    Aadd(_aCabTot,"Mes"    )
    Aadd(_aCabTot,"Total %")
    _cMsg:=NIL
    IF !Empty(_cMeses)
       _cMsg:="O(s) mes(es) de "+_cMeses+"não esta com 100 % na somatoria."
    Endif
    _cTitulo:="Conferencia do Total (100%) por mes das Metas Anuais"
    //ITListBox( _cTitAux , _aHeader , _aCols , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk,_aSX1,_lComCab)
    U_ITListBox( _cTitulo , _aCabTot, _aTotais  , .F.    , 4      ,_cMsg     ,          ,         ,         ,     ,        ,          ,       ,         , _aColXML ,)

    Return _cMeses //Retorna os meses que não tem 100% de somatoria  //*********************  RETORNO  ****************************//

 //************************************************************************************//
 ElseIf _cAcao = "LISTA_META_POR_DIA"//_cAnoMes: Ler AnoMes 6 digitos
 //************************************************************************************//
    nPosProd  := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_COD'   })
    nPosQTD   := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD'   })
    nPosUM    := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_UM'    })
    nPosQTD2U := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD2UM'})
    nPos2UM   := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_2UM'   })
    nPosQTD3U := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_QTD3UM'})
    nPos3UM   := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_3UM'   })
    nPosVALOR := Ascan(aHeader,{ |x| AllTrim(x[2]) == 'ZZS_VALOR' })
    xObj      := CallMod2Obj()
    N         := xObj:oBrowse:nat
    cProd     := aCols[N,nPosProd]
    _cChave   := xFilial("ZZS")+_cAnoMes+_cCoord+cProd

    ZZS->(DbSetOrder(7))  // ZZS_FILIAL+ZZS_ANOMES+ZZS_COOR+ZZS_COD+ZZS_DATA
    ZZS->(MsSeek(_cChave))// ZZS_FILIAL+ZZS_ANOMES+ZZS_COOR+ZZS_COD
    ZZA->(DbSetOrder(1))  // ZPA_FILIAL+ZPA_SDATA
    lAchou:=.F.
    _aProdDia:={}
    _aTotais:={0,0,0,0,0,0,0} //Acumula os totais de cada coluna
    DO While ZZS->(!EOF()) .AND. _cChave == ZZS->(ZZS_FILIAL+ZZS_ANOMES+ZZS_COOR+ZZS_COD)
       IF Empty(ZZS->ZZS_DATA)
          ZZS->(Dbskip())
          Loop
       Endif
       ZPA->(MsSeek(xFilial("ZPA")+DTOS(ZZS->ZZS_DATA)))
       Aadd(_aProdDia,{DTOC(ZZS->ZZS_DATA),;//01
                       ZPA->ZPA_PERCE     ,;//02
                       ZZS->ZZS_QTD       ,;//03
                       ZZS->ZZS_UM        ,;//04
                       ZZS->ZZS_QTD2UM    ,;//05
                       ZZS->ZZS_2UM       ,;//06
                       ZZS->ZZS_QTD3UM    ,;//07
                       ZZS->ZZS_3UM       ,;//08
                       ZZS->ZZS_VALOR     })//09

       _aTotais[1] +=  ZZS->ZZS_QTD
       _aTotais[2] +=  ZZS->ZZS_QTD2UM
       _aTotais[3] +=  ZZS->ZZS_QTD3UM
       _aTotais[4] +=  ZZS->ZZS_VALOR
       _aTotais[5] +=  ZPA->ZPA_PERCE
       lAchou:=.T.
       ZZS->(Dbskip())
    Enddo

    IF !lAchou
       u_itmsg("Não existem datas para o produto "+AllTrim(cProd)+" no mes "+SUBSTR(_cAnoMes,5,2)+"/"+SUBSTR(_cAnoMes,1,4),"Atenção","A meta diaria do produto é gravada atuomaticamente na gravaçõo das metas mensais.",3)
       Return .F. //*********************  RETORNO  ****************************//
    EndIf

    ZZS->(MsSeek(_cChave+" ")) //ZZS_FILIAL+ZZS_ANOMES+ZZS_COOR+ZZS_COD

    Aadd(_aProdDia,{"SOMAS:"    ,;//01
                    _aTotais[5] ,;//02
                    _aTotais[1] ,;//03
                    ZZS->ZZS_UM ,;//04
                    _aTotais[2] ,;//05
                    ZZS->ZZS_2UM,;//06
                    _aTotais[3] ,;//07
                    ZZS->ZZS_3UM,;//08
                    _aTotais[4] })//09

    Aadd(_aProdDia,{"TOTAIS:"         ,;//01
                    100               ,;//02
                    aCols[N,nPosQTD  ],;//03
                    aCols[N,nPosUM   ],;//04
                    aCols[N,nPosQTD2U],;//05
                    aCols[N,nPos2UM  ],;//06
                    aCols[N,nPosQTD3U],;//07
                    aCols[N,nPos3UM  ],;//08
                    aCols[N,nPosVALOR]})//09

    Aadd(_aProdDia,{"Diferença:"                      ,;//01
                    (100               -_aTotais[5] ) ,;//02
                    (aCols[N,nPosQTD  ]-_aTotais[1] ) ,;//03
                    (aCols[N,nPosUM   ]             ) ,;//04
                    (aCols[N,nPosQTD2U]-_aTotais[2] ) ,;//05
                    (aCols[N,nPos2UM  ]             ) ,;//06
                    (aCols[N,nPosQTD3U]-_aTotais[3] ) ,;//07
                    (aCols[N,nPos3UM  ]             ) ,;//08
                    (aCols[N,nPosVALOR]-_aTotais[4] ) })//09

     _aColXML:=AClone(_aProdDia)

    For A := 1 TO Len(_aProdDia)
       _aProdDia[A,2]:= AllTrim(Trans(_aProdDia[A,2],"@E 999,999,999.99"))
       _aProdDia[A,3]:= AllTrim(Trans(_aProdDia[A,3],"@E 999,999,999.99"))
       _aProdDia[A,5]:= AllTrim(Trans(_aProdDia[A,5],"@E 999,999,999.99"))
       _aProdDia[A,7]:= AllTrim(Trans(_aProdDia[A,7],"@E 999,999,999.99"))
       _aProdDia[A,9]:= AllTrim(Trans(_aProdDia[A,9],"@E 999,999,999.99"))
    Next A

    _aCabDT:={}
    Aadd(_aCabDT,"Data"    )
    Aadd(_aCabDT,"%"       )
    Aadd(_aCabDT,"Qtde 1Um")
    Aadd(_aCabDT,"1a Um"   )
    Aadd(_aCabDT,"Qtde 2Um")
    Aadd(_aCabDT,"2a Um"   )
    Aadd(_aCabDT,"Qtde 3Um")
    Aadd(_aCabDT,"3a Um"   )
    Aadd(_aCabDT,"Valor"   )

    _cTitulo:="Valores por Dia do Produto "+cProd+" no mes "+SUBSTR(_cAnoMes,5,2)+"/"+SUBSTR(_cAnoMes,1,4)
    //ITListBox( _cTitAux , _aHeader , _aCols , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk,_aSX1,_lComCab)
    U_ITListBox( _cTitulo , _aCabDT , _aProdDia , .F.    , 1      ,          ,          ,         ,         ,     ,        ,          ,       ,         , _aColXML ,)

    FwRestArea(_aAreaZZS)//VOLTA A AREA DE ZZS INDICE E RECNO

 ENDIF

Return .T.
