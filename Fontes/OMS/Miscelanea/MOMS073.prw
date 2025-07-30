/*
=========================================================================================================================================================
                          ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
=========================================================================================================================================================
Analista         - Programador       - Inicio     - Envio    - Chamado - Motivo da Alteração
---------------------------------------------------------------------------------------------------------------------------------------------------------
Jerry            - Alex Wallauer     - 06/03/2025 - 20/03/25 - 50107   - Solicitação do Comercial da nova regra de leite Magro
Lucas Borges     - Lucas Borges      - 23/07/2025 - 23/07/25 - 51340   - Ajustar função para validação de ambiente de teste
=========================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "Protheus.ch"
#include "TopConn.ch"

/*
===============================================================================================================================
Programa----------: MOMS073
Autor-------------: Alex Wallauer
Data da Criacao---: 06/03/2025
Descrição---------: Rotinas para Solicitação do Comercial nova regra de leite Magro
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS073()
 Local _aParRet    := {} As Array
 Local _aParAux    := {} As Array
 Local _bOK        := {||.T.} As Block
 Local _nI         := 0 As Numeric
 Local _lRet       := .F. As Logical
 Local _nDia99     := SuperGetMV("IT_DIAPER99",.F.,2)//Parametro tipo Numerico, Ate que dia do mes colocar 99 no campo A3_I_PERAC? Ex.: 1 = 1º dia do mes , 2 = 2º dia do mes, 3 = 3º dia do mes
 Private _lScheduler:= FWGetRunSchedule() As Logical

 MV_PAR01:= SPACE(070)
 MV_PAR02:= SPACE(070)
 MV_PAR04:= _dDataDia := DATE()
 _nDia   := Val(SubStr(Dtos(_dDataDia),7,2))
 _nMes   := Val(SubStr(Dtos(_dDataDia),5,2))
 _nAno   := Val(SubStr(Dtos(_dDataDia),1,4))
 _dDtIni := Ctod("01/"+StrZero(_nMes,2)+"/"+StrZero(_nAno,4))
 if _nDia <= _nDia99
    _lPoe99 := .T.
 Else
    _lPoe99 := .F.
 EndIf

 If _lScheduler
    MOMS73INT()
 Else
    aAdd( _aParAux , { 1 , "Gerente? "    , MV_PAR01, "@!" , "" , "LSTGER" , "EMPTY(MV_PAR02)" , 100 , .F. } )//01
    aAdd( _aParAux , { 1 , "Coordenador? ", MV_PAR02, "@!" , "" , "LSTSUP" , "EMPTY(MV_PAR01)" , 070 , .F. } )//02
    aAdd( _aParAux , { 9 , "DATA DE EMISSAO DE "+DTOC(_dDtIni)  , 150      , 9  , .T. } )      //03
    IF !SuperGetMV("IT_AMBTEST",.F.,.T.)
       aAdd( _aParAux , { 9 , "DATA DE EMISSAO ATE "+DTOC(_dDataDia), 150  , 9  , .T. } )      //04
    ELSE
       aAdd( _aParAux , { 1 , "Data Emissao ate", MV_PAR04, "@D", "","",".T.", 070, .T. } )    //04
    ENDIF

    For _nI := 1 To Len( _aParAux )
       aAdd( _aParRet , _aParAux[_nI][03] )
    Next _nI

    If !ParamBox( _aParAux , " Percentual de Meta e Percentual Acumulado do Coordenador " , @_aParRet, _bOK )
       _lRet := .F.
    Else
       _dDataDia:= MV_PAR04
       _nDia    := Val(SubStr(Dtos(_dDataDia),7,2))
       _nMes    := Val(SubStr(Dtos(_dDataDia),5,2))
       _nAno    := Val(SubStr(Dtos(_dDataDia),1,4))
       _dDtIni  := Ctod("01/"+StrZero(_nMes,2)+"/"+StrZero(_nAno,4))
       if _nDia <= _nDia99
          _lPoe99 := .T.
       Else
          _lPoe99 := .F.
       EndIf

       FWMSGRUN( ,{|oProc|  _lRet := MOMS73INT(oProc) } , "Hora Inicial: "+Time()+" Selecionando notas... " )

    EndIf
 EndIf

Return
/*
===============================================================================================================================
Programa----------: MOMS73INT
Autor-------------: Alex Wallauer
Data da Criacao---: 06/03/2025
Descrição---------: Rotinas para Ler as notas fiscais e PVs para calcular o percentual de meta e acumulado do Coordenador
Parametros--------: oProc As Object
Retorno-----------: .T.
===============================================================================================================================
*/
Static Function MOMS73INT(oProc As Object) As Logical
 Local aCab As Array
 Local _cTitAux As Character
 Local _cMsgTop As Character
 Local _cAlias:= GetNextAlias() As Character
 Local _cQry  := "" As Character
 Local aLog   := {} As Array
 Local _lRet  :=.T. As Logical
 Local cTimeInicial:=TIME()

 If oProc <> Nil
    oProc:cCaption:="Lendo de "+DTOC(_dDtIni)+" até "+DTOC(_dDataDia)
    ProcessMessages()
 EndIf

 If _lPoe99//********** SÓ O SA3 ***********************************************************************************************************************

    _cQry +=  " SELECT SA3.A3_COD C5_VEND2, ' ' B1_I_TIPLT, 0 QTDENF "
    _cQry +=  "   FROM "+ RetSqlName('SA3')+" SA3  "
    _cQry +=  "   WHERE SA3.A3_I_TIPV = 'C' AND A3_GEREN <> ' ' " //AND A3_MSBLQL <> '1' "
    If !Empty( MV_PAR01 )
       If Len(Alltrim(MV_PAR01)) = 6
          _cQry += " AND SA3.A3_GEREN = '"+ Alltrim(MV_PAR01) + "' "
       Else
          _cQry += " AND SA3.A3_GEREN IN "+ FormatIn( MV_PAR01 , ";" )
       EndIf
    EndIf
    If !Empty( MV_PAR02 )
       If Len(Alltrim(MV_PAR02)) = 6
          _cQry += " AND SA3.A3_COD = '"+ Alltrim(MV_PAR02) + "' "
       Else
          _cQry += " AND SA3.A3_COD IN "+ FormatIn( MV_PAR02 , ";" )
       EndIf
    EndIf
    _cQry +=  "      AND SA3.D_E_L_E_T_ = ' '  "
    _cQry +=  " ORDER BY A3_COD "

 Else//*********************** LE NOTAS E PEDIDOS *************************************************************************************************

    _cQry +=  " SELECT C5_VEND2, B1_I_TIPLT, SUM(QTDENF)  QTDENF"
    _cQry +=  " FROM ( SELECT SC5.C5_VEND2 C5_VEND2,SB1.B1_I_TIPLT B1_I_TIPLT, SUM(SD2.D2_QUANT - SD2.D2_QTDEDEV) AS QTDENF  "
    _cQry +=  "        FROM "+ RetSqlName('SD2')+" SD2  "
    _cQry +=  "        JOIN "+ RetSqlName('SC5')+" SC5 ON SD2.D2_FILIAL = SC5.C5_FILIAL  AND  SD2.D2_PEDIDO = SC5.C5_NUM AND SC5.D_E_L_E_T_ = ' ' "
    _cQry +=  "        JOIN "+ RetSqlName('ZAY')+" ZAY ON SD2.D2_CF = ZAY_CF  AND ZAY.ZAY_TPOPER = 'V' AND  ZAY.D_E_L_E_T_ = ' ' "
    _cQry +=  "        JOIN "+ RetSqlName('SB1')+" SB1 ON SD2.D2_COD  = SB1.B1_COD AND SB1.B1_I_TIPLT IN ('I','M')  AND  SB1.D_E_L_E_T_ = ' '  "
    _cQry +=  "            WHERE SD2.D2_EMISSAO BETWEEN '" + DtoS(_dDtIni) + "' AND '" + DtoS(_dDataDia) + "' "
    _cQry +=  "              AND SD2.D2_TIPO = 'N' AND (SD2.D2_QUANT - SD2.D2_QTDEDEV) > 0 "
    If !Empty( MV_PAR01 )
       If Len(Alltrim(MV_PAR01)) = 6
          _cQry += "         AND SC5.C5_VEND3 = '"+ Alltrim(MV_PAR01) + "' "
       Else
          _cQry += "         AND SC5.C5_VEND3 IN "+ FormatIn( MV_PAR01 , ";" )
       EndIf
    EndIf
    If !Empty( MV_PAR02 )
       If Len(Alltrim(MV_PAR02)) = 6
          _cQry += "         AND SC5.C5_VEND2 = '"+ Alltrim(MV_PAR02) + "' "
       Else
          _cQry += "         AND SC5.C5_VEND2 IN "+ FormatIn( MV_PAR02 , ";" )
       EndIf
    EndIf
    _cQry +=  "              AND SD2.D_E_L_E_T_ = ' '  "
    _cQry +=  "              GROUP BY C5_VEND2,B1_I_TIPLT "
    _cQry +=  "        UNION "
    _cQry +=  "        SELECT SC5.C5_VEND2 C5_VEND2,SB1.B1_I_TIPLT B1_I_TIPLT, SUM(SC6.C6_QTDVEN) AS QTDENF  "
    _cQry +=  "        FROM "+ RetSqlName('SC6') + " SC6  "
    _cQry +=  "        JOIN "+ RetSqlName('SC5') + " SC5 ON SC6.C6_FILIAL = SC5.C5_FILIAL  AND  SC6.C6_NUM  = SC5.C5_NUM AND SC5.C5_TIPO = 'N' AND SC5.D_E_L_E_T_ = ' ' "
    //_cQry +=  "      JOIN "+ RetSqlName('ZAY') + " ZAY ON SC6.C6_CF = ZAY_CF  AND ZAY.ZAY_TPOPER = 'V' AND  ZAY.D_E_L_E_T_ = ' ' "
    _cQry +=  "        JOIN "+ RetSqlName('SB1') + " SB1 ON SC6.C6_PRODUTO = SB1.B1_COD AND SB1.B1_I_TIPLT IN ('I','M')  AND  SB1.D_E_L_E_T_ = ' '  "
    _cQry +=  "            WHERE SC5.C5_EMISSAO BETWEEN '" + DtoS(_dDtIni) + "' AND '" + DtoS(_dDataDia) + "' AND  C5_NOTA = ' ' "
    _cQry +=  "              AND ( C5_I_OPER = '42' OR Exists( SELECT 'Y' FROM "+ RetSqlName('ZAY') + " ZAY where ZAY.d_e_l_e_t_ = ' ' AND ZAY.ZAY_CF = SC6.C6_CF AND ZAY.ZAY_TPOPER = 'V'  )  ) "
    _cQry +=  "              AND SC6.C6_QTDVEN > 0 "
    If !Empty( MV_PAR01 )
       If Len(Alltrim(MV_PAR01)) = 6
          _cQry += "         AND SC5.C5_VEND3= '"+ Alltrim(MV_PAR01) + "' "
       Else
          _cQry += "         AND SC5.C5_VEND3 IN "+ FormatIn( MV_PAR01 , ";" )
       EndIf
    EndIf
    If !Empty( MV_PAR02 )
       If Len(Alltrim(MV_PAR02)) = 6
          _cQry += "         AND SC5.C5_VEND2 = '"+ Alltrim(MV_PAR02) + "' "
       Else
          _cQry += "         AND SC5.C5_VEND2 IN "+ FormatIn( MV_PAR02 , ";" )
       EndIf
    EndIf
    _cQry +=  "              AND SC6.D_E_L_E_T_ = ' '  "
    _cQry +=  "              GROUP BY SC5.C5_VEND2,SB1.B1_I_TIPLT  ) "
    //_cQry +=  " JOIN "+ RetSqlName('SA3')+" SA3 ON SA3.A3_COD = C5_VEND2 AND SA3.D_E_L_E_T_ = ' '  AND A3_MSBLQL <> '1' "//????
    _cQry +=  " GROUP BY C5_VEND2,B1_I_TIPLT "
    _cQry +=  " ORDER BY C5_VEND2,B1_I_TIPLT "
 EndIf

 MPSysOpenQuery( _cQry,_cAlias )
 DbSelectArea(_cAlias)
 _nTot:=nConta:=0
 COUNT TO _nTot
 _cTot:=ALLTRIM(STR(_nTot))
 IF _nTot > 0 .AND. oProc <> Nil .And. !_lScheduler
    IF !U_ITMSG("Serão lidos "+_cTot+" Registros. Continua?","Hr Ini: "+cTimeInicial+" Hr final "+TIME(),"Resultado da leitura de "+DTOC(_dDtIni)+" até "+DTOC(_dDataDia)+" / Hr Ini: "+cTimeInicial+" Hr final "+TIME(),3,2,2)
        RETURN .F.
    ENDIF
 ENDIF
 cTimeInicial:=TIME()

 aCab:={}
 aAdd(aCab,"")                     //01
 nPos1:=LEN(aCab)
 aAdd(aCab,"Gerente")              //02
 aAdd(aCab,"Cod.Coord.")           //03
 nPosCoo:=LEN(aCab)
 aAdd(aCab,"Coordenador")          //04
 aAdd(aCab,"Qtde Leite Magro")     //05
 nPosQLM:=LEN(aCab)
 aAdd(aCab,"Qtde Leite Integral")  //06
 nPosQLI:=LEN(aCab)
 aAdd(aCab,"% Acumulado")          //07
 nPosAcu:=LEN(aCab)
 aAdd(aCab,"% Acumulado Anteriror")//08
 nPosAAcu:=LEN(aCab)
 aAdd(aCab,"% Meta de Magro")      //09
 aAdd(aCab,"Registro SA3")         //10
 nPosRec:=LEN(aCab)

 (_cAlias)->(DBGoTop())
 Do While (_cAlias)->(!EOF())
    nConta++
    If oProc <> Nil
       oProc:cCaption:='Quantidade de Registros Lidas: '+ALLTRIM(STR(nConta))+ " / "+_cTot
       ProcessMessages()
    EndIf

    IF (nPos:=Ascan(aLog,{|L| L[nPosCoo] == (_cAlias)->C5_VEND2 })) = 0
       cNome:=ALLTRIM(Posicione("SA3",1,xFilial("SA3")+(_cAlias)->C5_VEND2,"A3_NOME"))+IF(SA3->A3_MSBLQL="1"," (Inativo)","")
       _nA3_I_PERAC:=SA3->A3_I_PERAC//TRANS(SA3->A3_I_PERAC,"@E 99.99")
       _cA3_I_PERCM:=TRANS(SA3->A3_I_PERCM,"@E 99.99")
       _nRenoSA3:=SA3->(RECNO())
       cGerente:=SA3->A3_GEREN
       cGerente:=cGerente+"-"+Posicione("SA3",1,xFilial("SA3")+cGerente,"A3_NOME")//CUIDADO ESTA POSICIONADO NO GETENTE

       _aItens:={}
       aAdd(_aItens,.T.)                 //01
       aAdd(_aItens,cGerente)            //02
       aAdd(_aItens,(_cAlias)->C5_VEND2) //03
       aAdd(_aItens,cNome)               //04
       IF (_cAlias)->B1_I_TIPLT = "M"
          aAdd(_aItens,(_cAlias)->QTDENF)//05
          aAdd(_aItens,0)                //06
       ELSE
          aAdd(_aItens,0)                //05
          aAdd(_aItens,(_cAlias)->QTDENF)//06
       EndIf
       aAdd(_aItens,IF(_lPoe99,99,0))    //07
       aAdd(_aItens,_nA3_I_PERAC)        //08
       aAdd(_aItens,_cA3_I_PERCM)        //09
       aAdd(_aItens,_nRenoSA3)           //10
       IF _lPoe99
          _aItens[nPos1]:=(99 <> _nA3_I_PERAC) //01
       EndIf

       aAdd(aLog,_aItens)
    ElseIF !_lPoe99
       IF (_cAlias)->B1_I_TIPLT = "M"
          aLog[nPos][nPosQLM] += (_cAlias)->QTDENF//05
       ELSE
          aLog[nPos][nPosQLI] += (_cAlias)->QTDENF//06
       EndIf
       _nPercAcu:=ROUND( ( (aLog[nPos][nPosQLM]/ (aLog[nPos][nPosQLM] + aLog[nPos][nPosQLI])) *100 ) ,2)//Percentual Acumulado ? (( Qtd Leite Magro / ( QtdLeiteMago + QtdLeiteIntegral) ) * 100 )
       aLog[nPos][nPosAcu]:=_nPercAcu //07
       aLog[nPos][nPos1]  := (_nPercAcu <> aLog[nPos][nPosAAcu]) //01
    Endif
    (_cAlias)->(Dbskip())
 EndDo

 (_cAlias)->(Dbclosearea())

 If oProc <> NIL  .And. !_lScheduler
    If LEN(aLog) > 0
       _cTitAux := "Resultado do processamento, Data: "+DTOS(DATE())+" Hora: "+TIME()
       _cMsgTop := "Resultado do processamento, De "+DTOC(_dDtIni)+" até "+DTOC(_dDataDia)+" / Hr Ini: "+cTimeInicial+" Hr final "+TIME()
       DO WHILE .T.
          //         ITListBox( _cTitAux , _aHeader , _aCols , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca,_bLegenda                      ,_lHasOk,_bHeadClk,_aSX1)
          _lRet := U_ITListBox( _cTitAux , aCab     , aLog   , .T.      , 4      , _cMsgTop ,          ,         ,         ,     ,        ,          ,       ,         ,          ,           ,                               ,       ,         ,     )

          IF !_lRet .AND. U_ITMSG("Confirma SAIDA?","Gravação do SA3","Todos os dados serão perdidos.",3,2,2)

             Exit

          Elseif U_ITMSG("Confirma gravação dos dados?","Gravação do SA3",,3,2,2)

             FWMSGRUN( ,{|oProc|  _lRet := MOMS73Grv(oProc,aLog) } , "Hora Inicial: "+Time()+" Gravando Dados... " )
             Exit

          Else
             Loop
          EndIf
       Enddo
    Endif
 Else
    If LEN(aLog) > 0
       MOMS73Grv(,aLog)
    Endif
 Endif

Return _lRet


/*
===============================================================================================================================
Programa----------: MOMS73Grv
Autor-------------: Alex Wallauer
Data da Criacao---: 06/03/2025
Descrição---------: Gravaçã dos dados do SA3
Parametros--------: oProc As Object
Retorno-----------: .T.
===============================================================================================================================
*/
Static Function MOMS73Grv(oProc As Object,aLog As Array) As Logical
 Local _nI:=0 As Numeric
 Local _nGravados:=0 As Numeric

 For _nI := 1 To Len( aLog )
    If oProc <> Nil
       oProc:cCaption:='Gravando Registro: '+ALLTRIM(STR(_nI))+" / "+ALLTRIM(STR(Len(aLog)))
       ProcessMessages()
    EndIf
    If aLog[_nI][nPos1]
       If aLog[_nI][nPosRec] > 0
          SA3->(dbGoto(aLog[_nI][nPosRec]))
          SA3->(RecLock("SA3",.F.))
          SA3->A3_I_PERAC:=aLog[_nI][nPosAcu]
          SA3->(Msunlock())
          _nGravados++
       EndIf
    EndIf
 Next _nI

Return .T.


/*
===============================================================================================================================
Programa----------: SchedDef
Autor-------------: Alex Wallauer
Data da Criacao---: 06/03/2025
Descrição---------: Definição de Static Function SchedDef para o novo Schedule
Uso---------------: No novo Schedule existe uma forma para a definição dos Perguntes para o botão Parâmetros, além do cadastro
                    das funções no SXD. Ao definir em sua rotina a static function SchedDef(), no cadastro da rotina no Agenda-
                    mento do Schedule será verificado se existe esta static function e irá executá-la habilitando o botão Parâ-
                    metros com as informações do retorno da SchedDef(), deixando de verificar assim as informações na SXD. O
                    retorno da SchedDef deverá ser um array.
                    Válido para Function e User Function, lembrando que uma vez definido a SchedDef, ao chamar a rotina o ambi-
                    ente já está inicializado.
                    Uma vez definido a Static Function SchedDef(), a rotina deixa de ser uma execução como processo especial,
                    ou seja, não se deve cadastrá-la no Agendamento passando parâmetros de linha. Ex: Funcao("A","B") ou
                    U_Funcao("A","B").
Parametros--------: aReturn[1] - Tipo: "P" - para Processo, "R" -  para Relatórios
                    aReturn[2] - Nome do Pergunte, caso nao use passar ParamDef
                    aReturn[3] - Alias  (para Relatório)
                    aReturn[4] - Array de ordem  (para Relatório)
                    aReturn[5] - Título (para Relatório)
Retorno-----------: aParam
===============================================================================================================================
*/
Static Function SchedDef()

Local aParam  := {}
Local aOrd := {}

aParam := { "P",;
            "PARAMDEFF",;
            "",;
            aOrd,;
            }

Return aParam
