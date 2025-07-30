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
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'

/*
===============================================================================================================================
Programa----------: REST018
Autor-------------: Jonathan Torioni
Data da Criacao---: 13/07/2020
===============================================================================================================================
Descrição---------: Demostrações de liberações de documentos. Chamado 33493
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function REST018()
    Local oReport
    Local _cPerg        := 'REST018'
    Local _cAlias       := GetNextAlias()
    Private _aSelFil      := {}

    Private _aItalac_F3 := {}

    AADD(_aItalac_F3,{"MV_PAR04" ,"SAK"     ,2                     ,4                       ,             ,"Aprovadores"} )
    AADD(_aItalac_F3,{"MV_PAR05" ,"SAL"     ,2                     ,4                       ,             ,"Grupos"} )

    Pergunte(_cPerg, .T.)

    oReport := REST018E(_cAlias, _aSelFil)

    oReport:PrintDialog()

Return

/*
===============================================================================================================================
Programa----------: REST018E
Autor-------------: Jonathan Torioni
Data da Criacao---: 13/07/2020
===============================================================================================================================
Descrição---------: Processa montagem do relatório
===============================================================================================================================
Parametros--------: _cAlias
                    _aSelFil
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function REST018E(_cAlias, _aSelFil)

    Local oSection1 
    Local _cTipo     := IIF(MV_PAR07 == 1,"Analítico", "Sintético")
    Local _nDCol     := IIF(MV_PAR07 == 1, 12, 14)
    //Cria componente de impressão
    //TReport():New
    //ExpC1 : Nome do relatorio
    //ExpC2 : Titulo
    //ExpC3 : Pergunte
    //ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao
    //ExpC5 : Descricao

    oReport := TReport():New('REST018', "Demonstrativo de Liberação de Documentos" , 'REST018', {|oReport| REST018P(oReport, _cAlias)}, "Demonstrativo de Liberação de Documentos", .T. )
    oReport:SetLandscape()
    oReport:SetTotalInLine(.F.)

    oSection1:= TRSection():New(oReport, _cTipo, {_cAlias}, , .F., .T.)
    IF MV_PAR07 == 1 //Analitico
        TRCell():New( oSection1 , "DOC"			,_cAlias,"Documento"    ,"@!"       ,10, , , , , , ,_nDCol )
        TRCell():New( oSection1 , "TIPO"		,_cAlias,"Tipo Doc"     ,"@!"       ,10, , , , , , ,_nDCol )
        TRCell():New( oSection1 , "STATUS"		,_cAlias,"Status"       ,"@!"       ,10, , , , , , ,_nDCol )
        TRCell():New( oSection1 , "EMISSAO"		,_cAlias,"Dt. Emissao"  ,"@D"       ,10, , , , , , ,_nDCol )
        TRCell():New( oSection1 , "DATALIB"		,_cAlias,"Dt. Liberacao","@!"       ,10, , , , , , ,_nDCol )
        TRCell():New( oSection1 , "TOTAL"		,_cAlias,"Total"        ,"@E 999,999,999.99",16, , , , , , ,_nDCol )
        TRCell():New( oSection1 , "QUANT"		,_cAlias,"Quantidade"   ,"@E 999,999,999.999",13, , , , , , ,_nDCol )
        TRCell():New( oSection1 , "OBS"			,_cAlias,"Observacao"   ,"@!"       ,100, , , , , , ,_nDCol)
    ELSE //Sintético
        TRCell():New( oSection1 , "APROV"       ,_cAlias,"Aprovador"            ,"@!",16, , , , , , ,_nDCol-10)
        TRCell():New( oSection1 , "NOME"        ,""     ,"Nome"                 ,"@!",50, , , , , , ,_nDCol-10)
        TRCell():New( oSection1 , "GRP"         ,""     ,"Grp Aprov SA "        ,"@!",20, , , , , , ,_nDCol-10)
        TRCell():New( oSection1 , "TOTLIB"      ,_cAlias,"Valor Liberado R$"    ,"@E 999,999,999.99",16, , , , , , ,_nDCol )
        TRCell():New( oSection1 , "TOTREJ"      ,_cAlias,"Valor Rejeitado R$"   ,"@E 999,999,999.99",16, , , , , , ,_nDCol)
        TRCell():New( oSection1 , "TOTPEN"      ,_cAlias,"Valor Pendente R$"    ,"@E 999,999,999.99",16, , , , , , ,_nDCol )
        TRCell():New( oSection1 , "TOTQTL"      ,_cAlias,"Total Liberado"  ,"@E 999,999,999",13, , , , , , ,_nDCol )
        TRCell():New( oSection1 , "TOTQTR"      ,_cAlias,"Total Rejeirado QTDE" ,"@E 999,999,999",13, , , , , , ,_nDCol )
        TRCell():New( oSection1 , "TOTQTP"      ,_cAlias,"Total Pendente QTDE"  ,"@E 999,999,999",13, , , , , , ,_nDCol)
        TRCell():New( oSection1 , "SALHOJE"     ,_cAlias,"Saldo R$ do dia "+AllToChar(date()),"@E 999,999,999.99",16, , , , , , ,_nDCol)
    ENDIF
Return oReport

/*
===============================================================================================================================
Programa----------: REST018E
Autor-------------: Jonathan Torioni
Data da Criacao---: 13/07/2020
===============================================================================================================================
Descrição---------: Processa montagem do relatório
===============================================================================================================================
Parametros--------: oReport
                    _cAlias
                    _aSelFil
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function REST018P(oReport, _cAlias)
    Local oSection1     := oReport:Section(1)
    Local _nContRec     := 0
    Local _cStatus      := ''
    Local _cQuery       := ''

    //============================================
    //PERGUNTE
    //MV_PAR01 -> DATA DE:
    //MV_PAR02 -> DATA ATE:
    //MV_PAR03 -> TIPO DOC: PC OU SA
    //MV_PAR04 -> APROVADOR MARCAÇÃO
    //MV_PAR05 -> GRUPOS: MARCAÇÃO
    //MV_PAR06 -> STATUS: PENDENTE, LIBERADOS
    //                    REJEITADOS, TODOS
    //MV_PAR07 -> TIPO RELATORIO: ANALIT/SINT
    //============================================

    //============================================
    //STATUS SCR
    //01=Aguardando nivel anterior;
    //02=Pendente;
    //03=Liberado;
    //04=Bloqueado;
    //05=Liberado outro usuario;
    //06=Rejeitado
    //============================================
    DO CASE
        CASE MV_PAR06 == 1
            _cStatus := '02'

        CASE MV_PAR06 == 2
            _cStatus := '03'

        Case MV_PAR06 == 3
            _cStatus := '06'

        CASE MV_PAR06 == 4
            _cStatus := "02;03;06"

    ENDCASE

    oReport:SetMsgPrint("Consultando registros no Banco de Dados")
    oReport:SetMeter(0)
    IF MV_PAR03 == 2 //PC
        IF MV_PAR07 == 1 //Analitico
            _cQuery += "SELECT " 
            _cQuery += "DISTINCT C7_NUM DOC,    "
            _cQuery += "CR_TIPO TIPO,           "
            _cQuery += "CR_STATUS STATUS,       "
            _cQuery += "C7_EMISSAO EMISSAO,     "
            _cQuery += "CR_DATALIB DATALIB,     "
            _cQuery += "(SELECT SUM(C7_TOTAL) FROM " + RetSqlName('SC7') + " SSC7 WHERE SC7.D_E_L_E_T_ = ' ' AND SSC7.C7_FILIAL = SC7.C7_FILIAL AND SSC7.C7_NUM = SC7.C7_NUM) AS TOTAL, "
            _cQuery += "(SELECT SUM(C7_QUANT) FROM " + RetSqlName('SC7') + " SSC7 WHERE SC7.D_E_L_E_T_ = ' ' AND SSC7.C7_FILIAL = SC7.C7_FILIAL AND SSC7.C7_NUM = SC7.C7_NUM) AS QUANT, "
            _cQuery += "(SELECT C7_OBS FROM " + RetSqlName('SC7') + " SSC7 WHERE SC7.D_E_L_E_T_ = ' ' AND SSC7.C7_FILIAL = SC7.C7_FILIAL AND SSC7.C7_NUM = SC7.C7_NUM AND SSC7.C7_ITEM = '0001') AS OBS "
            _cQuery += "FROM "+RetSqlName('SC7') +" SC7, "+ RetSqlName('SCR') + " SCR "
            _cQuery += "WHERE SC7.D_E_L_E_T_ = ' ' "
            _cQuery += "AND SC7.C7_FILIAL = '" + cFilAnt + "' "
            _cQuery += "AND SC7.C7_EMISSAO BETWEEN '" +DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "
            _cQuery += "AND SCR.D_E_L_E_T_ = ' ' "
            _cQuery += "AND SCR.CR_FILIAL = SC7.C7_FILIAL "
            _cQuery += "AND SCR.CR_NUM = SC7.C7_NUM "
            IF !EMPTY(MV_PAR04)
                _cQuery += "AND SCR.CR_APROV IN "+ FormatIn(MV_PAR04,";") + " "
            ENDIF
            IF !EMPTY(MV_PAR05)
                _cQuery += "AND SCR.CR_GRUPO IN " + FormatIn(MV_PAR05,";") + " "
            ENDIF
            IF MV_PAR06 != 4
                _cQuery += "AND SCR.CR_STATUS = '" + _cStatus + "' "
            ELSE
                _cQuery += "AND SCR.CR_STATUS IN " + FormatIn(_cStatus,";") + " "
            EnDIF
        ELSE //Sintético

        ENDIF

    ELSE //SA
        IF MV_PAR07 == 1 //Analitico
            _cQuery += "SELECT "
            _cQuery += "DISTINCT CR_NUM DOC, "
            _cQuery += "CR_TIPO TIPO, "
            _cQuery += "CR_STATUS STATUS, "
            _cQuery += "CR_EMISSAO EMISSAO, "
            _cQuery += "CR_DATALIB DATALIB, "
            _cQuery += "CR_VALLIB VALLIB, "
            _cQuery += "CR_TOTAL TOTAL, "
            _cQuery += "(SELECT SUM(CP_QUANT) FROM " +RetSqlName('SCP') + " SCP WHERE SCP.D_E_L_E_T_ = ' ' AND SCP.CP_FILIAL = SCR.CR_FILIAL AND SCP.CP_NUM = SCR.CR_NUM) AS QUANT, "
            _cQuery += "(SELECT CP_I_OBSAP FROM " +RetSqlName('SCP') +" SCP WHERE SCP.D_E_L_E_T_ = ' ' AND SCP.CP_FILIAL = SCR.CR_FILIAL AND SCP.CP_NUM = SCR.CR_NUM AND SCP.CP_ITEM = '01') AS OBS "
            _cQuery += "FROM "+RetSqlName('SCR')+ " SCR "
            _cQuery += "WHERE SCR.D_E_L_E_T_ = ' ' "
            _cQuery += "AND SCR.CR_FILIAL = '" +cFilAnt+ "' "
            _cQuery += "AND SCR.CR_EMISSAO BETWEEN '" + DtoS(MV_PAR01) +"' AND '" + DtoS(MV_PAR02) + "' "
            _cQuery += "AND SCR.CR_TIPO = 'SA'
            IF !EMPTY(MV_PAR04)
                _cQuery += "AND SCR.CR_APROV IN "+ FormatIn(MV_PAR04,";") + " "
            ENDIF
            IF !EMPTY(MV_PAR05)
                _cQuery += "AND SCR.CR_GRUPO IN " + FormatIn(MV_PAR05,";") + " "
            ENDIF
            IF MV_PAR06 != 4
                _cQuery += "AND SCR.CR_STATUS = '" + _cStatus + "' "
            ELSE
                _cQuery += "AND SCR.CR_STATUS IN " + FormatIn(_cStatus,";") + " "
            EnDIF
        ELSE//Sintético
            _cQuery += "    SELECT T.APROV APROVADOR, sum(t.quantp) QUANTP, sum(t.quantr) quantr, SUM(T.QUANTL) QUANTL, SUM(T.LIB) LIBERAD, SUM(T.REJEIT) REJEIT, SUM(T.PEND) PENDENT, T.SALHOJE FROM "
            _cQuery += "    (SELECT L.CR_APROV APROV, sum(l.cp_quant) quantl, 0 quantr, 0 quantp, SUM(L.CR_VALLIB) LIB, 0 REJEIT, 0 PEND, L.SALHOJE "
            _cQuery += "    FROM "
            _cQuery += "    (SELECT "
            _cQuery += "    DISTINCT CR_NUM, "
            _cQuery += "    CR_TIPO, "
            _cQuery += "    CR_STATUS, "
            _cQuery += "    CR_EMISSAO, "
            _cQuery += "    CR_DATALIB, "
            _cQuery += "    CR_VALLIB, "
            _cQuery += "    CR_TOTAL, "
            _cQuery += "    (SELECT SUM(CP_QUANT)  FROM "+RetSqlName("SCP")+" SCP WHERE SCP.D_E_L_E_T_ = ' ' AND SCP.CP_FILIAL = SCR.CR_FILIAL AND SCP.CP_NUM = SCR.CR_NUM) AS CP_QUANT, "
            _cQuery += "    (SELECT CP_I_OBSAP FROM "+RetSqlName("SCP")+" SCP WHERE SCP.D_E_L_E_T_ = ' ' AND SCP.CP_FILIAL = SCR.CR_FILIAL AND SCP.CP_NUM = SCR.CR_NUM AND SCP.CP_ITEM = '01') AS CP_I_OBSAP, "
            _cQuery += "    CR_APROV, "
            _cQuery += "    (SELECT ak_limite - nvl(( SELECT SUM(cr_vallib) FROM "+RetSqlName("SCR")+" SCRR WHERE SCR.D_E_L_E_T_ = ' ' AND SCRR.cr_datalib = '"+DtoS(Date())+"' AND SCRR.cr_aprov = SCR.CR_APROV AND SCRR.cr_filial = SCR.CR_FILIAL), 0) saldo FROM "+RetSqlName("SAK")+" SAK WHERE SAK.D_E_L_E_T_ = ' ' AND SAK.ak_cod = SCR.CR_APROV) AS SALHOJE "
            _cQuery += "    FROM "+RetSqlName("SCR")+" SCR "
            _cQuery += "    WHERE SCR.D_E_L_E_T_ = ' ' "
            _cQuery += "    AND SCR.CR_FILIAL = '"+cFilAnt+"' "
            _cQuery += "    AND SCR.CR_EMISSAO BETWEEN '"+DtoS(MV_PAR01) + "' AND '" +DtoS(MV_PAR02)+"' "
            _cQuery += "    AND SCR.CR_TIPO = 'SA'
            IF !EMPTY(MV_PAR04)
                _cQuery += "    AND SCR.CR_APROV IN "+ FormatIn(MV_PAR04,";") + " "
            ENDIF
            IF !EMPTY(MV_PAR05)
                _cQuery += "    AND SCR.CR_GRUPO IN " + FormatIn(MV_PAR05,";") + " "
            ENDIF
            IF MV_PAR06 != 4
                _cQuery += "    AND SCR.CR_STATUS = '" + _cStatus + "' "
            ELSE
                _cQuery += "    AND SCR.CR_STATUS IN " + FormatIn(_cStatus,";") + " "
            EnDIF
            _cQuery += "    AND SCR.CR_STATUS = '03' ) L "
            _cQuery += "    group by L.cr_aprov, L.SALHOJE "
            _cQuery += "    union all "
            _cQuery += "    select R.CR_APROV, 0 quantl, sum(r.cp_quant) quantr, 0 quantp, 0 LIB, SUM(R.CR_TOTAL) REJEIT, 0 PEND, R.SALHOJE 
            _cQuery += "    FROM "
            _cQuery += "    (SELECT "
            _cQuery += "    DISTINCT CR_NUM, "
            _cQuery += "    CR_TIPO, "
            _cQuery += "    CR_STATUS, "
            _cQuery += "    CR_EMISSAO, "
            _cQuery += "    CR_DATALIB, "
            _cQuery += "    CR_VALLIB, "
            _cQuery += "    CR_TOTAL, "
            _cQuery += "    (SELECT SUM(CP_QUANT) FROM "+RetSqlName("SCP")+" SCP WHERE SCP.D_E_L_E_T_ = ' ' AND SCP.CP_FILIAL = SCR.CR_FILIAL AND SCP.CP_NUM = SCR.CR_NUM) AS CP_QUANT, "
            _cQuery += "    (SELECT CP_I_OBSAP FROM "+RetSqlName("SCP")+" SCP WHERE SCP.D_E_L_E_T_ = ' ' AND SCP.CP_FILIAL = SCR.CR_FILIAL AND SCP.CP_NUM = SCR.CR_NUM AND SCP.CP_ITEM = '01') AS CP_I_OBSAP, "
            _cQuery += "    CR_APROV, "
            _cQuery += "    (SELECT ak_limite - nvl(( SELECT SUM(cr_vallib) FROM "+RetSqlName("SCR")+" SCRR WHERE SCR.D_E_L_E_T_ = ' ' AND SCRR.cr_datalib = '"+DtoS(Date())+"' AND SCRR.cr_aprov = SCR.CR_APROV AND SCRR.cr_filial = SCR.CR_FILIAL), 0) saldo FROM "+RetSqlName("SAK")+" SAK WHERE SAK.D_E_L_E_T_ = ' ' AND SAK.ak_cod = SCR.CR_APROV) AS SALHOJE "
            _cQuery += "    FROM "+RetSqlName("SCR")+" SCR "
            _cQuery += "    WHERE SCR.D_E_L_E_T_ = ' ' "
            _cQuery += "    AND SCR.CR_FILIAL = '"+cFilAnt+"' "
            _cQuery += "    AND SCR.CR_EMISSAO BETWEEN '"+DtoS(MV_PAR01) + "' AND '" +DtoS(MV_PAR02)+"' "
            _cQuery += "    AND SCR.CR_TIPO = 'SA'
            IF !EMPTY(MV_PAR04)
                _cQuery += "    AND SCR.CR_APROV IN "+ FormatIn(MV_PAR04,";") + " "
            ENDIF
            IF !EMPTY(MV_PAR05)
                _cQuery += "    AND SCR.CR_GRUPO IN " + FormatIn(MV_PAR05,";") + " "
            ENDIF
            IF MV_PAR06 != 4
                _cQuery += "    AND SCR.CR_STATUS = '" + _cStatus + "' "
            ELSE
                _cQuery += "    AND SCR.CR_STATUS IN " + FormatIn(_cStatus,";") + " "
            EnDIF
            _cQuery += "    AND SCR.CR_STATUS = '06') R "
            _cQuery += "    group by R.cr_aprov, R.SALHOJE "
            _cQuery += "    union all "
            _cQuery += "    select P.CR_APROV, 0 quantl, 0 quantr, sum(p.cp_quant) quantp, 0 LIB, 0 REJEIT, SUM(P.CR_TOTAL) PEND, P.SALHOJE "
            _cQuery += "    FROM "
            _cQuery += "    (SELECT "
            _cQuery += "    DISTINCT CR_NUM, "
            _cQuery += "    CR_TIPO, "
            _cQuery += "    CR_STATUS, "
            _cQuery += "    CR_EMISSAO, "
            _cQuery += "    CR_DATALIB, "
            _cQuery += "    CR_VALLIB, "
            _cQuery += "    CR_TOTAL, "
            _cQuery += "    (SELECT SUM(CP_QUANT)  FROM "+RetSqlName("SCP")+" SCP WHERE SCP.D_E_L_E_T_ = ' ' AND SCP.CP_FILIAL = SCR.CR_FILIAL AND SCP.CP_NUM = SCR.CR_NUM) AS CP_QUANT, "
            _cQuery += "    (SELECT CP_I_OBSAP FROM "+RetSqlName("SCP")+" SCP WHERE SCP.D_E_L_E_T_ = ' ' AND SCP.CP_FILIAL = SCR.CR_FILIAL AND SCP.CP_NUM = SCR.CR_NUM AND SCP.CP_ITEM = '01') AS CP_I_OBSAP, "
            _cQuery += "    CR_APROV, "
            _cQuery += "    (SELECT ak_limite - nvl(( SELECT SUM(cr_vallib) FROM "+RetSqlName("SCR")+" SCRR WHERE SCR.D_E_L_E_T_ = ' ' AND SCRR.cr_datalib = '"+DtoS(Date())+"' AND SCRR.cr_aprov = SCR.CR_APROV AND SCRR.cr_filial = SCR.CR_FILIAL), 0) saldo FROM "+RetSqlName("SAK")+" SAK WHERE SAK.D_E_L_E_T_ = ' ' AND SAK.ak_cod = SCR.CR_APROV) AS SALHOJE "
            _cQuery += "    FROM "+RetSqlName("SCR")+" SCR "
            _cQuery += "    WHERE SCR.D_E_L_E_T_ = ' ' "
            _cQuery += "    AND SCR.CR_FILIAL = '"+cFilAnt+"' "
            _cQuery += "    AND SCR.CR_EMISSAO BETWEEN '"+DtoS(MV_PAR01) + "' AND '" +DtoS(MV_PAR02)+"' "
            _cQuery += "    AND SCR.CR_TIPO = 'SA'
            IF !EMPTY(MV_PAR04)
                _cQuery += "    AND SCR.CR_APROV IN "+ FormatIn(MV_PAR04,";") + " "
            ENDIF
            IF !EMPTY(MV_PAR05)
                _cQuery += "    AND SCR.CR_GRUPO IN " + FormatIn(MV_PAR05,";") + " "
            ENDIF
            IF MV_PAR06 != 4
                _cQuery += "    AND SCR.CR_STATUS = '" + _cStatus + "' "
            ELSE
                _cQuery += "    AND SCR.CR_STATUS IN " + FormatIn(_cStatus,";") + " "
            EnDIF
            _cQuery += "    AND CR_DATALIB = ' ' "
            _cQuery += "    AND SCR.CR_STATUS = '02')P "
            _cQuery += "    group by P.cr_aprov, P.SALHOJE) T "
            _cQuery += "    GROUP BY T.APROV, T.SALHOJE "
            _cQuery += "    ORDER BY T.APROV "
        ENDIF

    ENDIF

    DBUseArea( .T. , "TOPCONN" , TCGenQry(,,_cQuery) , _cAlias , .F. , .T. )

    Count TO _nContRec
    (_cAlias)->(DBGoTop())
    oReport:SetMeter(_nContRec)
    oReport:SetMsgPrint("Imprimindo")
    oReport:SetMeter(_nContRec)
    oSection1:Init()
    WHILE !oReport:Cancel() .AND. (_cAlias)->(!EOF())
        oReport:IncMeter()
        IF MV_PAR07 == 1 //Analitico
            oSection1:Cell("DOC"):SetValue((_cAlias)->DOC)
            oSection1:Cell("TIPO"):SetValue((_cAlias)->TIPO)
            oSection1:Cell("STATUS"):SetValue(REST018F((_cAlias)->STATUS))
            oSection1:Cell("EMISSAO"):SetValue(IIF(!EMPTY((_cAlias)->EMISSAO), AllToChar(StoD((_cAlias)->EMISSAO)), ""))
            oSection1:Cell("DATALIB"):SetValue(IIF(!EMPTY((_cAlias)->DATALIB), AllToChar(StoD((_cAlias)->DATALIB)), ""))
            oSection1:Cell("TOTAL"):SetValue((_cAlias)->TOTAL)
            oSection1:Cell("QUANT"):SetValue((_cAlias)->QUANT)
            oSection1:Cell("OBS"):SetValue((_cAlias)->OBS)
        ELSE //Sintético
            oSection1:Cell("APROV"):SetValue((_cAlias)->APROVADOR)
            oSection1:Cell("NOME"):SetValue(REST018N((_cAlias)->APROVADOR))
            oSection1:Cell("GRP"):SetValue(REST018N((_cAlias)->APROVADOR,.T.))
            oSection1:Cell("TOTLIB"):SetValue((_cAlias)->LIBERAD)
            oSection1:Cell("TOTREJ"):SetValue((_cAlias)->REJEIT)
            oSection1:Cell("TOTPEN"):SetValue((_cAlias)->PENDENT)
            oSection1:Cell("TOTQTL"):SetValue((_cAlias)->QUANTL)
            oSection1:Cell("TOTQTR"):SetValue((_cAlias)->QUANTR)
            oSection1:Cell("TOTQTP"):SetValue((_cAlias)->QUANTP)
            oSection1:Cell("SALHOJE"):SetValue((_cAlias)->SALHOJE)
        ENDIF
        oSection1:PrintLine()
        (_cAlias)->(DBSkip())
    ENDDO
    
    oSection1:Finish()
Return

/*
===============================================================================================================================
Programa----------: REST018E
Autor-------------: Jonathan Torioni
Data da Criacao---: 14/07/2020
===============================================================================================================================
Descrição---------: Retorna status
===============================================================================================================================
Parametros--------: _cStatus
===============================================================================================================================
Retorno-----------: _cStatus
===============================================================================================================================
*/

Static Function REST018F(_cStatus)

    DO CASE 
        CASE _cStatus == "02"
            _cStatus := "Pendente"
        CASE _cStatus == "03"
            _cStatus := "Liberado"
        CASE _cStatus == "06"
            _cStatus := "Rejeitado"
    ENDCASE

Return _cStatus

/*
===============================================================================================================================
Programa----------: REST018N
Autor-------------: Jonathan Torioni
Data da Criacao---: 12/08/2020
===============================================================================================================================
Descrição---------: Retorna nome do aprovador ou grupo de aprovação
===============================================================================================================================
Parametros--------: _cCodApr, lOpc
===============================================================================================================================
Retorno-----------: _cRet
===============================================================================================================================
*/

STATIC FUNCTION REST018N(_cCodApr,lOpc)
    Local _cRet := ""
    Local _cGrp := ""
    Local _cOpcs := ""
    Local _cCodUsr := ""
    Local _aOpc := {}
    Local _nPos := 0
    DEFAULT lOpc := .F.

    IF !lOpc
        _cRet := POSICIONE("SAK",1,xFilial("SAK")+_cCodApr,"AK_NOME")
    ELSE
        _cCodUsr := POSICIONE("SAK",1,xFilial("SAK")+_cCodApr,"AK_USER")
        _cGrp := POSICIONE("ZZL",3,xFilial("ZZL")+_cCodUsr,"ZZL_GRPAPR")
        IF !EMPTY(_cGrp)
            _cOpcs := GetSx3Cache("ZZL_GRPAPR","X3_CBOX")
            _aOpc := StrTokArr(_cOpcs,";")
            IF (_nPos := aScan(_aOpc, {|x| SubStr(x,1,1) == _cGrp})) != 0
                _cRet := STRTRAN(_aOpc[_nPos], "=", " - ")
            ENDIF
        ENDIF
    ENDIF

RETURN _cRet
