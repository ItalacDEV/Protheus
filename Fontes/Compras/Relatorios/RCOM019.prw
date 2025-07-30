/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |09/05/2025| Chamado 50617. Corrigir chamada estática no nome das tabelas do sistema
===============================================================================================================================
Analista       - Programador     - Inicio     - Envio    - Chamado - Motivo de Alteração
===============================================================================================================================
Lucas          - Alex Wallauer   - 02/05/2025 - 06/05/25 - 50525   - Ajuste para remoção de diretório local C:\SMARTCLIENT\.
===============================================================================================================================
*/

#INCLUDE 'PROTHEUS.CH'

/*
===============================================================================================================================
Programa----------: RCOM019
Autor-------------: Jonathan Torioni
Data da Criacao---: 19/06/2020
Descrição---------: Romaneio Pedido de compra X NFs
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RCOM019()
    PRIVATE nHandle       := 0
    PRIVATE cNomArq       := "RCOM019D"+DtoS(Date())+"N000"
    PRIVATE cExt          := ".XML"
    PRIVATE oBj           := Nil

    Private cCab        := "\data\italac\RCOM019\RCOM019_CAB.txt"
    Private cRodp       := "\data\italac\RCOM019\RCOM019_RODP.txt"
    Private cPedido     := SC7->C7_NUM
    Private aArq        := {}
    Private cPathSrv    := GetTempPath()

    IF !File(cCab)
        U_ITMSG("Layout XML não encontrado","Falha", "Entre em contato com a equipe de TI.",1)
        RETURN
    ENDIF

    //===============================================
    // Montagem do corpo do XML
    //===============================================
    FWMSGRUN(,{|oBj|  ROMS019B(oBj) },'Aguarde processamento...','Carregando dados...')

RETURN

/*
===============================================================================================================================
Programa----------: RCOM019B
Autor-------------: Jonathan Torioni
Data da Criacao---: 19/06/2020
Descrição---------: Monta o corpo do XML no array aArq
Parametros--------: Obj - Processamento visual
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function ROMS019B(Obj)
    Local cQuery        := ""
    Local cNwAlias      := GetNextAlias()
    Local cConsumo      := 's86'
    Local cServ         := 's87'
    Local cManut        := 's87'
    Local cInvest       := 's87'
    Local cStlyP        := 's95'
    Local cOBS          := ""
    Local cCodP         := ""
    Local cNfs          := ""
    Local nX            := 0
    Local nI            := 0
    Local nZ            := 0
    Local nSaldo        := 0
    Local nQuant        := 0
    Local aSaldo        := {}
    Local aProds        := {}
    Local cProdA        := ""
    Local cResid        := ""

    FT_FUSE(cCab)
    nTotal := FT_FLASTREC()
    FT_FGOTOP()
    //===============================================
    // Gravo todas as linhas do arquivo no aArq
    //===============================================
    WHILE !FT_FEOF() 
        Aadd(aArq, FT_FREADLN())
        FT_FSKIP()
    ENDDO
    FT_FUSE()

    Obj:cCaption := ("Gerando arquivo...")
    ProcessMessages()

    cQuery += " SELECT                                           "
    cQuery += " C7.C7_NUM,                                       "
    cQuery += " C7.C7_RESIDUO,                                   "
    cQuery += " D1.D1_PEDIDO,                                    "
    cQuery += " D1.D1_COD,                                       "
    cQuery += " B1.B1_I_DESCD,                                   "
    cQuery += " B1.B1_DESC,                                      "
    cQuery += " B1.B1_FILIAL,                                    "
    cQuery += " B1.B1_LOCPAD,                                    "
    cQuery += " C7.C7_UM,                                        "
    cQuery += " C7.C7_QUANT,                                     "
    cQuery += " D1.D1_QUANT,                                     "
    cQuery += " D1.D1_ITEMPC,                                    "
    cQuery += " C7.C7_ITEM,                                      "
    cQuery += " D1.D1_DOC,                                       "
    cQuery += " D1.D1_SERIE,                                     "
    cQuery += " D1.D1_DTDIGIT,                                   "
    cQuery += " BZ.BZ_I_LOCAL,                                   "
    cQuery += " C7.C7_OBS,                                       "
    cQuery += " C7.C7_LOCAL,                                     "
    cQuery += " C7.C7_I_APLIC                                    "
    cQuery += " FROM                                             "
    cQuery += " " + RetSqlName("SD1") + " D1,                    "
    cQuery += " " + RetSqlName("SC7") + " C7,                    "
    cQuery += " " + RetSqlName("SB1") + " B1,                    "
    cQuery += " " + RetSqlName("SBZ") + " BZ                     "
    cQuery += " WHERE                                            "
    cQuery += " D1.D_E_L_E_T_ = ' '                              "
    cQuery += " AND D1.D1_FILIAL = '" + cFilAnt + "'             "
    cQuery += " AND D1.D1_PEDIDO = '" + cPedido + "'             "
    cQuery += " AND C7.C7_NUM = D1.D1_PEDIDO                     "
    cQuery += " AND C7.C7_ITEM = D1.D1_ITEMPC                    "
    cQuery += " AND C7.C7_FILIAL = D1.D1_FILIAL                  "
    cQuery += " AND C7.D_E_L_E_T_ = ' '                          "
    cQuery += " AND C7.C7_PRODUTO = D1.D1_COD                    "
    cQuery += " AND B1.D_E_L_E_T_ = ' '                          "
    cQuery += " AND B1.B1_COD = D1.D1_COD                        "
    cQuery += " AND BZ.D_E_L_E_T_ = ' '                          "
    cQuery += " AND BZ.BZ_FILIAL = D1.D1_FILIAL                  "
    cQuery += " AND BZ.BZ_COD = D1.D1_COD                        "
    cQuery := ChangeQuery(cQuery)

    MPSysOpenQuery(cQuery,cNwAlias)

    IF (cNwAlias)->(EOF())
        U_ITMSG("Pedido não possui notas vinculadas!", "Falha",,1)
        RETURN 
    ENDIF
    //===========================================================
    // Montagem do Corpor do XML
    //===========================================================
    DO CASE
        CASE (cNwAlias)->C7_I_APLIC == 'C'
            cConsumo      := cStlyP
            cServ         := 's87'
            cManut        := 's87'
            cInvest       := 's87' 
        CASE (cNwAlias)->C7_I_APLIC == 'M'
            cConsumo      := 's86'
            cServ         := 's87'
            cManut        := cStlyP
            cInvest       := 's87' 
        CASE (cNwAlias)->C7_I_APLIC == 'I'
            cConsumo      := 's86'
            cServ         := 's87'
            cManut        := 's87'
            cInvest       := cStlyP  
        CASE (cNwAlias)->C7_I_APLIC == 'S'
            cConsumo      := 's86'
            cServ         := cStlyP
            cManut        := 's87'
            cInvest       := 's87' 
    ENDCASE 

    cOBS := (cNwAlias)->C7_OBS

    Aadd(aArq, '<Row ss:AutoFitHeight="0" ss:Height="15">' )
    Aadd(aArq, '    <Cell ss:MergeAcross="8" ss:StyleID="s66"><Data ss:Type="String">ROMANEIO DE LANCAMENTO DE NOTA FISCAL</Data></Cell>' )
    Aadd(aArq, '    <Cell ss:StyleID="s68"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s69"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s69"/>' )
    Aadd(aArq, '   </Row>' )
    Aadd(aArq, '   <Row ss:AutoFitHeight="0" ss:Height="15.75">' )
    Aadd(aArq, '    <Cell ss:StyleID="s68"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s68"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s68"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s68"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s68"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s68"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s68"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s68"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s70"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s70"/>' )
    Aadd(aArq, '   </Row>' )
    Aadd(aArq, '   <Row ss:AutoFitHeight="0" ss:Height="15.45" ss:StyleID="s71">' )
    Aadd(aArq, '    <Cell ss:Index="3" ss:MergeAcross="1" ss:StyleID="m406893492"><Data' )
    Aadd(aArq, '      ss:Type="String">PEDIDO DE COMPRA </Data></Cell>' )
    Aadd(aArq, '    <Cell ss:StyleID="s78"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s78"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s78"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s78"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s79"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s79"/>' )
    Aadd(aArq, '   </Row>' )
    Aadd(aArq, '   <Row ss:AutoFitHeight="0" ss:Height="18">' )
    Aadd(aArq, '    <Cell ss:Index="3" ss:MergeAcross="1" ss:StyleID="m406893512"><Data' )
    Aadd(aArq, '      ss:Type="String">'+cPedido+'</Data></Cell>' )
    Aadd(aArq, '    <Cell ss:StyleID="s68"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s68"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s68"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s68"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s70"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s70"/>' )
    Aadd(aArq, '   </Row>' )
    Aadd(aArq, '   <Row ss:AutoFitHeight="0" ss:Height="15.45" ss:StyleID="s71">' )
    Aadd(aArq, '    <Cell ss:Index="3" ss:StyleID="s80"><Data ss:Type="String">CONSUMO</Data></Cell>' )
    Aadd(aArq, '    <Cell ss:StyleID="'+cConsumo+'"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s78"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s78"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s78"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s78"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s79"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s79"/>' )
    Aadd(aArq, '   </Row>' )
    Aadd(aArq, '   <Row ss:AutoFitHeight="0" ss:Height="15.45" ss:StyleID="s71">' )
    Aadd(aArq, '    <Cell ss:Index="3" ss:StyleID="s80"><Data ss:Type="String">SERVICO</Data></Cell>' )
    Aadd(aArq, '    <Cell ss:StyleID="'+cServ+'"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s88"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s88"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s88"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s88"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s79"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s79"/>' )
    Aadd(aArq, '   </Row>' )
    Aadd(aArq, '   <Row ss:AutoFitHeight="0" ss:Height="15.45" ss:StyleID="s71">' )
    Aadd(aArq, '    <Cell ss:Index="3" ss:StyleID="s80"><Data ss:Type="String">MANUTENCAO</Data></Cell>' )
    Aadd(aArq, '    <Cell ss:StyleID="'+cManut+'"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s88"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s88"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s88"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s88"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s79"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s79"/>' )
    Aadd(aArq, '   </Row>' )
    Aadd(aArq, '   <Row ss:AutoFitHeight="0" ss:Height="15.45" ss:StyleID="s71">' )
    Aadd(aArq, '    <Cell ss:Index="3" ss:StyleID="s80"><Data ss:Type="String">INVESTIMENTO</Data></Cell>' )
    Aadd(aArq, '    <Cell ss:StyleID="'+cInvest+'"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s88"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s88"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s88"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s88"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s79"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s79"/>' )
    Aadd(aArq, '   </Row>' )
    Aadd(aArq, '   <Row ss:AutoFitHeight="0" ss:Height="18" ss:StyleID="s70">' )
    Aadd(aArq, '    <Cell ss:StyleID="s89"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s89"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s89"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s89"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s89"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s89"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s89"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s89"/>' )
    Aadd(aArq, '   </Row>' )
    Aadd(aArq, '   <Row ss:AutoFitHeight="0" ss:Height="15.45" ss:StyleID="s71">' )
    Aadd(aArq, '    <Cell ss:StyleID="s90"><Data ss:Type="String">CODIGO</Data></Cell>' )
    Aadd(aArq, '    <Cell ss:StyleID="s90"><Data ss:Type="String">DESC DETALH.</Data></Cell>' )
    Aadd(aArq, '    <Cell ss:StyleID="s90"><Data ss:Type="String">DESCRICAO</Data></Cell>' )
    Aadd(aArq, '    <Cell ss:StyleID="s90"><Data ss:Type="String">U.M.</Data></Cell>' )
    Aadd(aArq, '    <Cell ss:StyleID="s90"><Data ss:Type="String">QUANT PC</Data></Cell>' )
    Aadd(aArq, '    <Cell ss:StyleID="s90"><Data ss:Type="String">QUANT NF</Data></Cell>' )
    Aadd(aArq, '    <Cell ss:StyleID="s90"><Data ss:Type="String">ENDERECO</Data></Cell>' )
    Aadd(aArq, '    <Cell ss:StyleID="s90"><Data ss:Type="String">ESTOQUE</Data></Cell>' )
    Aadd(aArq, '    <Cell ss:StyleID="s90"><Data ss:Type="String">RESID</Data></Cell>' )
    Aadd(aArq, '    <Cell ss:StyleID="s79"/>' )
    Aadd(aArq, '   </Row>' )

    WHILE (cNwAlias)->(!EOF())
        Obj:cCaption := ("Gerando arquivo...")
        ProcessMessages()
        Aadd(aProds, {;
            (cNwAlias)->D1_COD,;
            (cNwAlias)->D1_ITEMPC,;
            (cNwAlias)->C7_ITEM,;
            (cNwAlias)->D1_DOC,;
            (cNwAlias)->D1_SERIE,;
            (cNwAlias)->D1_DTDIGIT,;
            (cNwAlias)->D1_QUANT})
        (cNwAlias)->(DBSKIP())
    ENDDO

    (cNwAlias)->(DBGOTOP())

    WHILE (cNwAlias)->(!EOF())

        IF (cNwAlias)->D1_COD == cProdA
            (cNwAlias)->(DBSKIP())
            LOOP
        ENDIF

        Obj:cCaption := ("Gerando arquivo...")
        ProcessMessages()
        nX++
        cCodP := (cNwAlias)->D1_COD

        aSaldo := CalcEst(cCodP,(cNwAlias)->C7_LOCAL,DATE()+1, cFilAnt)
        nSaldo := aSaldo[1]

        FOR nI := 1 TO Len(aProds)
            IF aProds[nI][1] == (cNwAlias)->D1_COD .AND. aProds[nI][2] == (cNwAlias)->C7_ITEM
                cNfs += aProds[nI][4] +"/"+aProds[nI][5] + " - " +  Strzero(Day(StoD(aProds[nI][6])),2)+"/"+Strzero(Month(StoD(aProds[nI][6])),2)+"/"+Substr(Str(Year(StoD(aProds[nI][6])),4),3,2) + "; "
                nQuant += aProds[nI][7]
                cResid := IIF(!EMPTY((cNwAlias)->C7_RESIDUO), "SIM","NAO" )
            ENDIF
        Next nI

        (cNwAlias)->(DBGOTO(nX))

        Aadd(aArq, '<Row ss:AutoFitHeight="0">' )
        Aadd(aArq, '    <Cell ss:StyleID="s91"><Data ss:Type="String">'+(cNwAlias)->D1_COD+'</Data></Cell>' )
        Aadd(aArq, '    <Cell ss:StyleID="s91"><Data ss:Type="String">'+(cNwAlias)->B1_I_DESCD+'</Data></Cell>' )
        Aadd(aArq, '    <Cell ss:StyleID="s91"><Data ss:Type="String">'+(cNwAlias)->B1_DESC+'</Data></Cell>' )
        Aadd(aArq, '    <Cell ss:StyleID="s91"><Data ss:Type="String">'+(cNwAlias)->C7_UM+'</Data></Cell>' )
        Aadd(aArq, '    <Cell ss:StyleID="s93"><Data ss:Type="Number">'+cValToChar((cNwAlias)->C7_QUANT)+'</Data></Cell>' )
        Aadd(aArq, '    <Cell ss:StyleID="s93"><Data ss:Type="Number">'+cValToChar(nQuant)+'</Data></Cell>' )
        Aadd(aArq, '    <Cell ss:StyleID="s91"><Data ss:Type="String">'+(cNwAlias)->BZ_I_LOCAL+'</Data></Cell>' )
        Aadd(aArq, '    <Cell ss:StyleID="s93"><Data ss:Type="Number">'+cValToChar(nSaldo)+'</Data></Cell>' )
        Aadd(aArq, '    <Cell ss:StyleID="s94"><Data ss:Type="String">'+cResid+'</Data></Cell>' )
        Aadd(aArq, '    <Cell ss:StyleID="s70"/>' )
        Aadd(aArq, '   </Row>' )
        Aadd(aArq, '   <Row ss:AutoFitHeight="0">' )
        Aadd(aArq, '    <Cell ss:MergeAcross="8" ss:StyleID="m406893532"><Data ss:Type="String">'+cNfs+'</Data></Cell>' )
        Aadd(aArq, '    <Cell ss:StyleID="s70"/>' )
        Aadd(aArq, '   </Row>' )

        cNfs := ""
        cResid:= ""
        nQuant := 0
        cProdA := (cNwAlias)->D1_COD
        (cNwAlias)->(DBSKIP())
    ENDDO
    Aadd(aArq, ' <Row ss:AutoFitHeight="0" ss:Height="15" ss:StyleID="s70">' )
    Aadd(aArq, '    <Cell ss:StyleID="s102"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s102"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s102"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s102"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s102"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s102"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s102"/>' )
    Aadd(aArq, '    <Cell ss:StyleID="s102"/>' )
    Aadd(aArq, '   </Row>' )
    Aadd(aArq, '   <Row ss:AutoFitHeight="0" ss:Height="15.75" ss:StyleID="s70">' )
    Aadd(aArq, '    <Cell ss:MergeAcross="8" ss:StyleID="s104"><Data ss:Type="String">OBSERVACAO</Data></Cell>' )
    Aadd(aArq, '   </Row>' )
    Aadd(aArq, '   <Row ss:AutoFitHeight="0">' )
    Aadd(aArq, '    <Cell ss:MergeAcross="8" ss:MergeDown="4" ss:StyleID="m406893572"><Data' )
    Aadd(aArq, '      ss:Type="String">'+cOBS+'</Data></Cell>' )
    Aadd(aArq, '    <Cell ss:StyleID="s70"/>' )
    Aadd(aArq, '   </Row>' )
    Aadd(aArq, '   <Row ss:AutoFitHeight="0">' )
    Aadd(aArq, '    <Cell ss:Index="10" ss:StyleID="s70"/>' )
    Aadd(aArq, '   </Row>' )
    Aadd(aArq, '   <Row ss:AutoFitHeight="0">' )
    Aadd(aArq, '    <Cell ss:Index="10" ss:StyleID="s70"/>' )
    Aadd(aArq, '   </Row>' )
    Aadd(aArq, '   <Row ss:AutoFitHeight="0">' )
    Aadd(aArq, '    <Cell ss:Index="10" ss:StyleID="s70"/>' )
    Aadd(aArq, '   </Row>' )
    Aadd(aArq, '   <Row ss:AutoFitHeight="0" ss:Height="15">' )
    Aadd(aArq, '    <Cell ss:Index="10" ss:StyleID="s70"/>' )
    Aadd(aArq, '   </Row>' )

    (cNwAlias)->(DbCloseArea())

    FT_FUSE(cRodp)
    nTotal := FT_FLASTREC()
    FT_FGOTOP()

    //===============================================
    // Grava todas as linhas do arquivo no aArq
    //===============================================
    WHILE !FT_FEOF()
        Obj:cCaption := ("Gerando arquivo...")
        ProcessMessages()
        Aadd(aArq, FT_FREADLN())
        FT_FSKIP()
    ENDDO
    FT_FUSE()

    //===============================================
    // Garava o arquivo
    //===============================================
    WHILE File(cPathSrv+cNomArq+cExt)
        cNomArq := Soma1(cNomArq)
    ENDDO
    
    nHandle := FCreate(cPathSrv+cNomArq+cExt)
    IF nHandle = -1
        U_ITMSG("Nã foi possível gerar o arquivo "+cPathSrv+" "+cNomArq+cExt,"Falha","Entre em contato com a equipe de TI",1)
    ELSE
        FOR nZ := 1 TO Len(aArq)
            FWrite(nHandle, aArq[nZ] + CRLF)
        NEXT nZ
        FClose(nHandle)
        U_ITMSG("Arquvio "+cPathSrv+" "+cNomArq+cExt+" gerado com sucesso!","Processo concluído!",,2)
    ENDIF

     //Tentando abrir o objeto
    nRet := shellExecute("Open", cNomArq+cExt, "", cPathSrv, 1 )
    //Se houver algum erro
    If nRet <= 32
        MsgStop("Não foi possível abrir o arquivo " +cDirP+" "+cNomeArqP+ "!", "Atenção")
    EndIf
Return
