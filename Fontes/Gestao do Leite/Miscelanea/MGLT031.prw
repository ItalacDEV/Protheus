/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        | Data     |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |11/04/2025| Chamado 50448. Inclu�da valida��o para registros alterados ap�s primeira integra��o.
Lucas Borges  |15/07/2025| Chamado 51354. Corrgida grava��o da data e hora contemplando 4 d�gitos no ano
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: MGLT031
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 24/03/2025
Descri��o---------: Rotina de integra��o WebService App da Qualidade e Gest�o do Leite Protheus. Chamado 48203.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGLT031

Local _oSelf as Object

//============================================
//Cria interface principal
//============================================
tNewProcess():New(	"MGLT031"							/*cFunction*/	,; //Fun��o inicial
					"Integra App Qualidade"				/*cTitle*/		,; //Descri��o da Rotina
					{|_oSelf| MGLT031P(_oSelf) }		/*bProcess*/	,; //Fun��o do processamento
					"Rotina para realizar a integra��o com o app da Qualidade e buscar as informa��es das"+;
					" an�lises de qualidade"/*cDescription*/,; //Descri��o da Funcionalidade
					"MGLT031"  							/*cPerg*/		,; //Configura��o dos Par�metros
					{}									/*aInfoCustom*/	,; //Op��es adicionais para o painel lateral
					.F.									/*lPanelAux*/	,; //Define cria��o do Painel auxiliar
					0									/*nSizePanelAux*/,; //Tamanho do Painel Auxiliar
					''									/*cDescriAux*/	,; //Descri��o do Painel Auxiliar
					.F.									/*lViewExecute*/,; //Se .T. exibe o painel de execu��o. Se falso, apenas executa a fun��o sem exibir a r�gua de processamento.
                    .F.                                 /*lOneMeter*/	,; //Se .T. cria apenas uma regua de processamento.
					.T.									/*lSchedAuto*/	)  //Se .T. habilita o bot�o de processamento em segundo plano (execu��o ocorre pelo Scheduler)

Return

/*
===============================================================================================================================
Programa----------: MGLT031P
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 24/03/2025
Descri��o---------: Realiza o processamento da rotina.
Parametros--------: _oSelf
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MGLT031P(_oSelf as Object)

Local _aHeadStr     := {}  As Array
Local cPostParms    := "" As Character
Local _cToken       := "" As Character
Local _cEmpCFG      := SuperGetMv('IT_ITAAPPQ',.F.,"000005") As Character
Local _jJSon        := Nil As JSon
Local _oRest        := Nil As Object
Local _cResult      := "" As Character
Local _nI, _nX      := 0 As Numeric
Local _aProd        := {} As Array
Local _aTipPrd      := {} As Array
Local _cAlias       := "" As Character
Local _aErro        := {} As Array
Local _cFornec      := "" As Character
Local _cLjForn      := "" As Character
Local _cCNPJFor     := "" As Character
Local _cTransp      := "" As Character
Local _cLjTran      := "" As Character
Local _cCNPJTran    := "" As Character
Local _cItem        := "" As Character
Local _cMsgAux      := "" As Character
Local _cDadosJson   := "" As Character
Local _cFormLogId   := "" As Character
Local _nCodProd     := 0 As Numeric
Local _lGrava       := .F. As Logical
Local _cUpdate      := "" As Character

DBSelectArea("ZFM")
ZFM->(DBSetOrder(1))
If ZFM->(DBSeek(xFilial("ZFM")+_cEmpCFG)) .And. !(Empty(ZFM->ZFM_LINK01) .Or. Empty(ZFM->ZFM_LINK02))

    _oRest := FwRest():New(ZFM->ZFM_LINK01)
    aAdd(_aHeadStr,"Content-Type: application/json") 
    cPostParms := '{"username": "'+ AllTrim(ZFM->ZFM_USRNOM) + '",'
    cPostParms += '"password": "'+  AllTrim(ZFM->ZFM_SENHA) +'"}'
    _oRest:SetPath("")
    _oRest:SetPostParams(cPostParms)

    If _oRest:Post(_aHeadStr)
        _jJson := JsonObject():new()
        
        If ValType(_cResult := _jJSon:FromJSON(_oRest:GetResult())) == "U" //Nil indica que conseguiu popular o objeto com o Json
            If _jJSon[1]:HasProperty("message")
                _cToken := _jJSon[1]["message"]
            Else
                FWAlertWarning("N�o foi possivel recuperar o token de acesso. "+ _oRest:getLastError(),"MGLT03101")
            EndIf
        Else
            FWAlertWarning("N�o foi poss�vel ler o JSon retornado o Token de acesso ao Webservice do App da Qualidade." + _oRest:getLastError(),"MGLT03102")
        EndIf
        FreeObj(_oRest)
        FreeObj(_jJSon)
    EndIf
    If !Empty(_cToken)
        //Cod integra��o/Cod Protheus/Descri��o/Processado/processado anteriormente/erro
        Aadd(_aTipPrd,{"1","Creme de Leite",0,0,0})
        Aadd(_aTipPrd,{"2","Soro de Leite",0,0,0})
        Aadd(_aTipPrd,{"3","Leite Cru",0,0,0})

        _cAlias := GetNextAlias()
        BeginSQL alias _cAlias
            SELECT DISTINCT ZA7_TIPPRD, ZA7_DENMIN, ZA7_DENMAX, ZA7_DENPAD,ZA7_GORMIN, ZA7_GORMAX, ZA7_ESTMIN, ZA7_ESTMAX, ZA7_DPADIN,
            TRIM(REGEXP_SUBSTR(ZA7_CODINT, '[^;]+', 1, LEVEL)) AS ZA7_CODINT
            FROM %Table:ZA7% ZA7
            WHERE ZA7.D_E_L_E_T_ = ' '
            AND ZA7_FILIAL = %xFilial:ZA7%
            AND ZA7_CODINT <> ' '
            CONNECT BY LEVEL <= REGEXP_COUNT(ZA7_CODINT, ';') + 1
            AND PRIOR ZA7_TIPPRD = ZA7_TIPPRD
            AND PRIOR SYS_GUID() <> ' '
        EndSql
        While (_cAlias)->(!EOF())
            Aadd(_aProd,{(_cAlias)->ZA7_TIPPRD,; //01
                        (_cAlias)->ZA7_CODINT,; //02
                        (_cAlias)->ZA7_DPADIN,; //03
                        (_cAlias)->ZA7_DENMIN,; //04
                        (_cAlias)->ZA7_DENMAX,; //05
                        (_cAlias)->ZA7_DENPAD,; //06
                        (_cAlias)->ZA7_GORMIN,; //07
                        (_cAlias)->ZA7_GORMAX,; //08
                        (_cAlias)->ZA7_ESTMIN,; //09
                        (_cAlias)->ZA7_ESTMAX}) //10
                        
            (_cAlias)->(DbSkip())
        EndDo
        (_cAlias)->(DBCloseArea())
        ZZX->(DbSetOrder(4)) // ZZX_FILIAL+ZZX_FLOGID
        ZAP->(DbSetOrder(2)) // ZAP_FILIAL+ZAP_FLOGID+ZAP_ITEM
        ZBQ->(DbSetOrder(1)) //ZBQ_FILIAL+ZBQ_FLOGID+ZBQ_GRUPO
        ZZV->(DbSetOrder(1)) //ZZV_FILIAL+ZZV_PLACA

	    _oSelf:SetRegua1(Len(_aTipPrd))
        For _nI := 1 To Len(_aTipPrd)
        	_aHeadStr := {}
            _oSelf:IncRegua1("Processando produto " + _aTipPrd[_nI,2])
            _oRest := FwRest():New(ZFM->ZFM_LINK02)
            Aadd(_aHeadStr,"Content-Type: application/json") 
            Aadd(_aHeadStr,"Authorization: Bearer " + AllTrim(_cToken)) 

            _jJSon := JsonObject():New()
            // A data e hora para a recupera��o dos dados no formato ISO 8601 (yyyy-MM-ddTHH:mm:ss). No banco da aplica��o a informa��o � gravada em UTC 0. 
            // A aplica��o vai converter o hor�rio que for enviado no UTC-0
            // Necess�rio excluir o indicador Zulo (Z). o Filtro � realizado no campo DataEntrada
            _jJSon["StartDate"]         := FWTimeStamp(3,MV_PAR01,"00:00:00")
            _jJSon["EndDate"]           := FWTimeStamp(3,MV_PAR02,"23:59:59")
            _jJSon["ProductId"]         := _aTipPrd[_nI,1]
            _jJSon["SourceLocationId"]  := "All"
            
            cPostParms := _jJSon:toJson()
            _oRest:SetPath("")
            _oRest:SetPostParams(cPostParms)
            
            If _oRest:Post(_aHeadStr)
                _jJson := JsonObject():new()
                _cResult := DecodeUTF8(_oRest:GetResult(),"CP1252")//Decodifico para mantar a acentua��o
                //As propriedades dos produtos s�o enviadas com n�mero antes, ex: 01 pH ou 02 pH, dependendo do produto.
                //Retiro esse sequencial para que as propriedades tenham sempre os mesmos nomes
                For _nX := 1 To 10//limitei a 10 eventos
                    _cResult := StrTran(_cResult,'"'+StrZero(_nX,2,0)+' ','"')
                    //Ajusto tamb�m a Densidade que tem duas nomenclaruras
                    _cResult := StrTran(_cResult,' a 15�C','')
                Next _nx
                If ValType(_jJSon:FromJSON(_cResult)) == "U" //Nil indica que conseguiu popular o objeto com o Json
                    //Sempre � retornado um Json com 1 item e dentro desse item, todas as an�lises
                    _oSelf:SetRegua2(Len(_jJSon))
                    For _nX := 1 To Len(_jJSon)
                        _lGrava := .F.
                        _oSelf:IncRegua2("Processando... Aguarde...")
                        
                        //Valido se o JSon possui alguma estrutura
                        If !_jJSon[_nX]:HasProperty("FormLogId")
                            Aadd(_aErro,{"FormLogId inv�lido. Posi��o do Json: " + StrZero(_nX,6)})
                            _aTipPrd[_nI,5]++
                            Loop
                        Else
                            _cFormLogId := StrZero(_jJSon[_nX]["FormLogId"],10)
                        EndIf

                        //Verifico se o produto recebido est� devidamente configurado
                        If (_nCodProd:= Ascan(_aProd,{|x| Upper(FwNoAccent(AllTrim(_jJSon[_nX]["Produto"]))) == AllTrim(x[2])})) == 0
                            Aadd(_aErro,{"Produto n�o configurado para integra��o: "+_jJSon[_nX]["Produto"]+". FormLogId:"+_cFormLogId})
                            _aTipPrd[_nI,5]++
                            Loop
                        EndIf

                        _cCNPJFor := StrTran(StrTran(StrTran(_jJSon[_nX]["Cliente_CPF_CNPJ"],".",""),"-",""),"/","")
                        _cCNPJTran := StrTran(StrTran(StrTran(_jJSon[_nX]["Transportadora_CPF_CNPJ"],".",""),"-",""),"/","")
                        _cPlaca := StrTran(_jJSon[_nX]["Placa"],"-","")
                        _cDadosJson := _jJSon[_nX]:toJson()   // Retorna um JSon TXT 

                        //Produtor
                        _cAlias:=GetNextAlias()
                        BeginSql alias _cAlias
                        SELECT A2_COD, A2_LOJA FROM %Table:SA2% WHERE A2_CGC = %exp:_cCNPJFor%
                            AND D_E_L_E_T_ = ' ' AND A2_MSBLQL = '2' 
                            AND A2_I_CLASS IN ('F','L','Z') AND A2_L_KMLE > 0
                            ORDER BY A2_COD
                        EndSql
                        _cFornec := (_cAlias)->A2_COD
                        _cLjForn := (_cAlias)->A2_LOJA
                        (_cAlias)->(DBCloseArea())
                        If Empty(_cFornec)
                            Aadd(_aErro,{"Fornecedor n�o localizado: "+_jJSon[_nX]["Cliente_CPF_CNPJ"]+". FormLogId:"+_cFormLogId})
                            _aTipPrd[_nI,5]++
                        Else
                            //Transportador
                            _cAlias:=GetNextAlias()
                            BeginSql alias _cAlias
                                SELECT A2_COD, A2_LOJA FROM %Table:SA2% SA2, %Table:ZZV% ZZV
                                WHERE A2_CGC = %exp:_cCNPJTran%
                                AND ZZV_FILIAL = %xFilial:ZZV%
                                AND ZZV_PLACA = %exp:_cPlaca%
                                AND ZZV_TRANSP = A2_COD
                                AND ZZV_LJTRAN = A2_LOJA
                                AND SA2.D_E_L_E_T_ = ' ' 
                                AND ZZV.D_E_L_E_T_ = ' '
                                AND A2_MSBLQL = '2'
                                AND ZZV_MSBLQL = '2'
                                ORDER BY A2_COD
                            EndSql
                            _cTransp := (_cAlias)->A2_COD
                            _cLjTran := (_cAlias)->A2_LOJA
                            (_cAlias)->(DBCloseArea())
                            If Empty(_cTransp)
                                Aadd(_aErro,{"Relacionamento Placa/Transportador n�o localizado: "+_jJSon[_nX]["Placa"]+" / ";
                                    +_jJSon[_nX]["Transportadora_CPF_CNPJ"]+". FormLogId:"+_cFormLogId})
                                _aTipPrd[_nI,5]++
                            EndIf
                        EndIf
                                                
                        BEGIN TRANSACTION
                        If Empty(_cTransp) .Or. Empty(_cFornec)
                            If ZZX->(MsSeek(xFilial("ZZX")+_cFormLogId))
                                If ZZX->ZZX_ANAUSE == .F.
                                    ZZX->(RecLock("ZZX", .F.))
                                    ZZX->(DBDelete())
                                    ZZX->(MsUnLock())
                                    _cUpdate 	:= "UPDATE "+RetSQLName("ZAP") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
                                    _cUpdate	+= "WHERE D_E_L_E_T_ = ' ' "
                                    _cUpdate	+= "AND ZAP_FILIAL = '"+cFilAnt+"' "
                                    _cUpdate	+= "AND ZAP_FLOGID = '"+_cFormLogId+"' "
                                    If TCSqlExec( _cUpdate ) < 0
                                        FWAlertError("Erro na exclus�o dos movimentos. Favor acionar a TI. Erro: "+AllTrim(TCSQLError()),"MGLT03103")
                                    Else
                                        Aadd(_aErro,{"Transportador/Fornecedor modificado mas n�o localizado. An�lise exclu�da (ZZX/ZAP). FormLogId:"+_cFormLogId})
                                    EndIf
                                           
                                    _cUpdate 	:= "UPDATE "+RetSQLName("ZBQ") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
                                    _cUpdate	+= "WHERE D_E_L_E_T_ = ' ' "
                                    _cUpdate	+= "AND ZBQ_FLOGID = '"+_cFormLogId+"' "
                                    If TCSqlExec( _cUpdate ) < 0
                                        FWAlertError("Erro na exclus�o dos movimentos. Favor acionar a TI. Erro: "+AllTrim(TCSQLError()),"MGLT03103")
                                    Else
                                        Aadd(_aErro,{"Transportador/Fornecedor modificado mas n�o localizado. Integra��o (ZQB) exclu�da. FormLogId:"+_cFormLogId})
                                    EndIf
                                Else
                                    Aadd(_aErro,{"Transportador/Fornecedor modificado mas n�o localizado. An�lise j� vinculada. N�o foi poss�vel realizar sua exclus�o FormLogId:"+_cFormLogId})
                                EndIf
                            EndIf
                        // Gravar Tabela de Muro
                        ElseIf !ZBQ->(DBSeek(xFilial("ZBQ")+_cFormLogId+_jJSon[_nX]["Grupo"]))
                            _lGrava := .T.
                            ZBQ->(RecLock("ZBQ",.T.))
                            ZBQ->ZBQ_FILIAL := cFilant //C 2 0 
                            ZBQ->ZBQ_FLOGID := _cFormLogId //C 10 0
                            ZBQ->ZBQ_GRUPO := _jJSon[_nX]["Grupo"] //C 15 0
                            ZBQ->ZBQ_TIPPRD := _jJSon[_nX]["TipoProduto"] //C 20 0
                            ZBQ->ZBQ_PRODUT := FwNoAccent(_jJSon[_nX]["Produto"]) //C 60 0
                        //Atualiza as informa��es quando a Qualidade realizar a libera��o.
                        ElseIf !ValType(_jJSon[_nX]["DataLibera��o"])=="J" .And. !Empty(_jJSon[_nX]["DataLibera��o"]) .And. Empty(ZBQ->ZBQ_DTLIBE)
                            _lGrava := .T.
                            ZBQ->(RecLock("ZBQ",.F.))
                        EndIf
                        If _lGrava
                            ZBQ->ZBQ_DTINTE := Date() //D 8 0
                            ZBQ->ZBQ_HRINTE := Time() //C 8 0
                            ZBQ->ZBQ_MAXDAT := DToC(FwDateTimeToLocal(_jJSon[_nX]["max(Data)"])[1])+" "+FwDateTimeToLocal(_jJSon[_nX]["max(Data)"])[2] //C 20 0
                            ZBQ->ZBQ_AMOSTR := _jJSon[_nX]["Amostra"] //N 2 0
                            ZBQ->ZBQ_CNPJTR := _cCNPJTran //C 14 0
                            ZBQ->ZBQ_PLACA := _cPlaca //C 8 0
                            ZBQ->ZBQ_CNPJOR := _cCNPJFor //C 14 0
                            ZBQ->ZBQ_ORIGEM := _jJSon[_nX]["Origem"] //C 80 0
                            //As datas s�o recebidas em UTC-0 mas devemos gravar no nosso fuso (-3:00), por isso a convers�o
                            ZBQ->ZBQ_DTENTR := DToC(FwDateTimeToLocal(Replace(_jJSon[_nX]["DataEntrada"]," ","T"))[1])+" "+FwDateTimeToLocal(Replace(_jJSon[_nX]["DataEntrada"]," ","T"))[2] //C 20 0
                            ZBQ->ZBQ_DTCOLE := DToC(FwDateTimeToLocal(Replace(_jJSon[_nX]["DataColeta"]," ","T"))[1])+" "+FwDateTimeToLocal(Replace(_jJSon[_nX]["DataColeta"]," ","T"))[2] //C 20 0
                            ZBQ->ZBQ_DTCHEG := DToC(FwDateTimeToLocal(Replace(_jJSon[_nX]["DataChegada"]," ","T"))[1])+" "+FwDateTimeToLocal(Replace(_jJSon[_nX]["DataChegada"]," ","T"))[2] //C 20 0
                            ZBQ->ZBQ_DTLIBE := If(ValType(_jJSon[_nX]["DataLibera��o"])=="J","",DToC(FwDateTimeToLocal(Replace(_jJSon[_nX]["DataLibera��o"]," ","T"))[1])+" "+FwDateTimeToLocal(Replace(_jJSon[_nX]["DataLibera��o"]," ","T"))[2]) //C 20 0
                            ZBQ->ZBQ_DTINIC := If(ValType(_jJSon[_nX]["DataInicio"])=="J","",DToC(FwDateTimeToLocal(Replace(_jJSon[_nX]["DataInicio"]," ","T"))[1])+" "+FwDateTimeToLocal(Replace(_jJSon[_nX]["DataInicio"]," ","T"))[2]) //C 20 0
                            ZBQ->ZBQ_DTFIM := If(ValType(_jJSon[_nX]["DataFim"])=="J","",DToC(FwDateTimeToLocal(Replace(_jJSon[_nX]["DataFim"]," ","T"))[1])+" "+FwDateTimeToLocal(Replace(_jJSon[_nX]["DataFim"]," ","T"))[2]) //C 20 0
                            ZBQ->ZBQ_VOLUME := Val(_jJSon[_nX]["Volume"]) //N 16 4
                            ZBQ->ZBQ_TEMPER := If(_jJSon[_nX]:HasProperty("Temperatura"),If(ValType(_jJSon[_nX]["Temperatura"])=="J",0,Val(_jJSon[_nX]["Temperatura"])),0) //N 6 2
                            ZBQ->ZBQ_SENSOR := If(_jJSon[_nX]:HasProperty("Sensorial"),If(ValType(_jJSon[_nX]["Sensorial"])=="J","",_jJSon[_nX]["Sensorial"]),"") //C 12 0
                            ZBQ->ZBQ_ESTALC := If(_jJSon[_nX]:HasProperty("Estabilidade Alco�lica"),If(ValType(_jJSon[_nX]["Estabilidade Alco�lica"])=="J","",_jJSon[_nX]["Estabilidade Alco�lica"]),"") //C 15 0
                            ZBQ->ZBQ_GRAALC := If(_jJSon[_nX]:HasProperty("Gradua��o Alco�lica"),If(ValType(_jJSon[_nX]["Gradua��o Alco�lica"])=="J",0,Val(_jJSon[_nX]["Gradua��o Alco�lica"])),0) //N 8 3
                            ZBQ->ZBQ_ACIDEZ := If(_jJSon[_nX]:HasProperty("Acidez"),If(ValType(_jJSon[_nX]["Acidez"])=="J",0,Val(_jJSon[_nX]["Acidez"])),0) //N 8 3
                            ZBQ->ZBQ_DENSID := If(_jJSon[_nX]:HasProperty("Densidade"),If(ValType(_jJSon[_nX]["Densidade"])=="J",0,Val(_jJSon[_nX]["Densidade"])),0) //N 10 3
                            ZBQ->ZBQ_GORDUR := If(_jJSon[_nX]:HasProperty("Gordura"),If(ValType(_jJSon[_nX]["Gordura"])=="J",0,Val(_jJSon[_nX]["Gordura"])),0) //N 8 3
                            ZBQ->ZBQ_OBSFQ1 := If(_jJSon[_nX]:HasProperty("Observa��o Fisico Quimico 1"),If(ValType(_jJSon[_nX]["Observa��o Fisico Quimico 1"])=="J","",_jJSon[_nX]["Observa��o Fisico Quimico 1"]),"") //C 100 0
                            ZBQ->ZBQ_EST := If(_jJSon[_nX]:HasProperty("EST"),If(ValType(_jJSon[_nX]["EST"])=="J",0,Val(_jJSon[_nX]["EST"])),0) //N 9 3
                            ZBQ->ZBQ_ESD := If(_jJSon[_nX]:HasProperty("ESD"),If(ValType(_jJSon[_nX]["ESD"])=="J",0,Val(_jJSon[_nX]["ESD"])),0) //N 9 3
                            ZBQ->ZBQ_CRIOSC := If(_jJSon[_nX]:HasProperty("Crioscopia"),If(ValType(_jJSon[_nX]["Crioscopia"])=="J",0,Val(_jJSon[_nX]["Crioscopia"])),0) //N 9 4
                            ZBQ->ZBQ_PROTEI := If(_jJSon[_nX]:HasProperty("Proteina"),If(ValType(_jJSon[_nX]["Proteina"])=="J",0,Val(_jJSon[_nX]["Proteina"])),0) //N 8 3
                            ZBQ->ZBQ_PH := If(_jJSon[_nX]:HasProperty("pH"),If(ValType(_jJSon[_nX]["pH"])=="J",0,Val(_jJSon[_nX]["pH"])),0) //N 8 3
                            ZBQ->ZBQ_ANTIBI := If(_jJSon[_nX]:HasProperty("Antibiotico - PPRO 1"),If(ValType(_jJSon[_nX]["Antibiotico - PPRO 1"])=="J",0,Val(_jJSon[_nX]["Antibiotico - PPRO 1"])),0) //N 9 4
                            ZBQ->ZBQ_OBSFQ2 := If(_jJSon[_nX]:HasProperty("Observa��o Fisico Quimico 2"),If(ValType(_jJSon[_nX]["Observa��o Fisico Quimico 2"])=="J","",_jJSon[_nX]["Observa��o Fisico Quimico 2"]),"") //C 100 0 
                            ZBQ->ZBQ_PEROHI := If(_jJSon[_nX]:HasProperty("01 Peroxido de Hidrogenio"),If(ValType(_jJSon[_nX]["01 Peroxido de Hidrogenio"])=="J","",_jJSon[_nX]["01 Peroxido de Hidrogenio"]),"") //C 15 0
                            ZBQ->ZBQ_FORMAL := If(_jJSon[_nX]:HasProperty("Formaldeido"),If(ValType(_jJSon[_nX]["Formaldeido"])=="J","",_jJSon[_nX]["Formaldeido"]),"") //C 15 0
                            ZBQ->ZBQ_OBSCON := If(_jJSon[_nX]:HasProperty("Observa��o Conservantes"),If(ValType(_jJSon[_nX]["Observa��o Conservantes"])=="J","",_jJSon[_nX]["Observa��o Conservantes"]),"") //C 100 0
                            ZBQ->ZBQ_ACIROS := If(_jJSon[_nX]:HasProperty("01 Acido Rosolico"),If(ValType(_jJSon[_nX]["01 Acido Rosolico"])=="J","",_jJSon[_nX]["01 Acido Rosolico"]),"") //C 15 0
                            ZBQ->ZBQ_FENOLF := If(_jJSon[_nX]:HasProperty("Fenolftale�na"),If(ValType(_jJSon[_nX]["Fenolftale�na"])=="J","",_jJSon[_nX]["Fenolftale�na"]),"") //C 15 0
                            ZBQ->ZBQ_OBSNEU := If(_jJSon[_nX]:HasProperty("Observa��o Neutralizantes"),If(ValType(_jJSon[_nX]["Observa��o Neutralizantes"])=="J","",_jJSon[_nX]["Observa��o Neutralizantes"]),"") //C 100 0
                            ZBQ->ZBQ_CLORET := If(_jJSon[_nX]:HasProperty("Cloreto"),If(ValType(_jJSon[_nX]["Cloreto"])=="J","",_jJSon[_nX]["Cloreto"]),"") //C 15 0
                            ZBQ->ZBQ_ALCETI := If(_jJSon[_nX]:HasProperty("Alcool Etilico"),If(ValType(_jJSon[_nX]["Alcool Etilico"])=="J","",_jJSon[_nX]["Alcool Etilico"]),"") //C 15 0
                            ZBQ->ZBQ_AMIDO := If(_jJSon[_nX]:HasProperty("Amido"),If(ValType(_jJSon[_nX]["Amido"])=="J","",_jJSon[_nX]["Amido"]),"") //C 15 0
                            ZBQ->ZBQ_SACARO := If(_jJSon[_nX]:HasProperty("Sacarose"),If(ValType(_jJSon[_nX]["Sacarose"])=="J","",_jJSon[_nX]["Sacarose"]),"") //C 15 0
                            ZBQ->ZBQ_OBSREC := If(_jJSon[_nX]:HasProperty("Observa��o Reconstituintes"),If(ValType(_jJSon[_nX]["Observa��o Reconstituintes"])=="J","",_jJSon[_nX]["Observa��o Reconstituintes"]),"") //C 100 0
                            ZBQ->ZBQ_FOSALC := If(_jJSon[_nX]:HasProperty("Fosfatase Alcalina"),If(ValType(_jJSon[_nX]["Fosfatase Alcalina"])=="J","",_jJSon[_nX]["Fosfatase Alcalina"]),"") //M 10 0
                            ZBQ->ZBQ_PEROXI := If(_jJSon[_nX]:HasProperty("Peroxidase"),If(ValType(_jJSon[_nX]["Peroxidase"])=="J","",_jJSon[_nX]["Peroxidase"]),"") //M 10 0
                            ZBQ->ZBQ_OBSTRA := If(_jJSon[_nX]:HasProperty("Observa��o Tratamento T�rmico"),If(ValType(_jJSon[_nX]["Observa��o Tratamento T�rmico"])=="J","",_jJSon[_nX]["Observa��o Tratamento T�rmico"]),"") //M 10 0
                            ZBQ->ZBQ_DESTIN := If(_jJSon[_nX]:HasProperty("Destino"),If(ValType(_jJSon[_nX]["Destino"])=="J","",_jJSon[_nX]["Destino"]),"") //C 12 0
                            ZBQ->ZBQ_JSON := _cDadosJson //M 10 0
                            ZBQ->ZBQ_SIF := If(_jJSon[_nX]:HasProperty("SIF"),Val(_jJSon[_nX]["SIF"]),0) //N 14 3
                            ZBQ->(MsUnLock())
                        
                            //Somente realizar a integra��o quando a Qualidade liberar a an�lise
                            If Empty(ZBQ->ZBQ_DTLIBE)
                                Aadd(_aErro,{"An�ise n�o finalizada pela qualidade. FormLogId: "+_cFormLogId})
                                _aTipPrd[_nI,5]++
                            ElseIf ZBQ->ZBQ_DENSID == 0
                                Aadd(_aErro,{"Densidade n�o informada. FormLogId: "+_cFormLogId})
                                _aTipPrd[_nI,5]++
                            //Densidade difernte de 1 precisa estar dentro da faixa de toler�ncia
                            ElseIf _aProd[_nCodProd,3] <> "1" .And. (ZBQ->ZBQ_DENSID < _aProd[_nCodProd,4] .Or. ZBQ->ZBQ_DENSID > _aProd[_nCodProd,5])
                                Aadd(_aErro,{"Densidade "+Str(ZBQ->ZBQ_DENSID)+" fora da taxa de toler�ncia: "+Str(_aProd[_nCodProd,4]) +" a "+ Str(_aProd[_nCodProd,5]) +". FormLogId: "+_cFormLogId})
                                _aTipPrd[_nI,5]++
                            //Gordura
                            ElseIf ZBQ->ZBQ_GORDUR < _aProd[_nCodProd,7] .Or. ZBQ->ZBQ_GORDUR > _aProd[_nCodProd,8]
                                Aadd(_aErro,{"Gordura "+Str(ZBQ->ZBQ_GORDUR)+" fora da taxa de toler�ncia: "+Str(_aProd[_nCodProd,7]) +" a "+ Str(_aProd[_nCodProd,8]) +". FormLogId: "+_cFormLogId})
                                _aTipPrd[_nI,5]++
                            //EST
                            ElseIf ZBQ->ZBQ_EST < _aProd[_nCodProd,9] .Or. ZBQ->ZBQ_EST > _aProd[_nCodProd,10]
                                Aadd(_aErro,{"EST "+Str(ZBQ->ZBQ_EST)+" fora da taxa de toler�ncia: "+Str(_aProd[_nCodProd,9]) +" a "+ Str(_aProd[_nCodProd,10]) +". FormLogId: "+_cFormLogId})
                                _aTipPrd[_nI,5]++
                            Else
                                If ! ZZX->(MsSeek(xFilial("ZZX")+_cFormLogId))
                                    // Grava os dados de capa - ZZX - Capa
                                    ZZX->(RecLock("ZZX",.T.))
                                    ZZX->ZZX_FILIAL := cFilAnt
                                    ZZX->ZZX_CODIGO := GETSXENUM("ZZX","ZZX_CODIGO")
                                    ZZX->ZZX_CODPRD := _aProd[_nCodProd,1]
                                    ZZX->ZZX_DATA   := CToD(ZBQ->ZBQ_DTENTR)
                                    ZZX->ZZX_HORA   := Substr(ZBQ->ZBQ_DTENTR,12,5)
                                    ZZX->ZZX_FORNEC := _cFornec // C�digo do Produtor
                                    ZZX->ZZX_LJFORN := _cLjForn // Loja do Produtor
                                    ZZX->ZZX_PLACA  := _cPlaca    //_jJSon[_nX]["Placa"]
                                    ZZX->ZZX_TRANSP := _cTransp // C�digo da Transportadora
                                    ZZX->ZZX_LJTRAN := _cLjTran // Loja da Transportadora
                                    ZZX->ZZX_DENSID := If(_aProd[_nCodProd,3] == "1",_aProd[_nCodProd,6],ZBQ->ZBQ_DENSID) //1-Indica usar o valor padr�o
                                    ZZX->ZZX_ANAUSE := .F.
                                    ZZX->ZZX_FLOGID := _cFormLogId
                                    ZZX->(MsUnlock())
                                    If __lSX8
                                        ConfirmSX8()
                                    Else
                                        RollBackSx8()
                                    EndIf
                                EndIf
                                
                                _cItem := _jJSon[_nX]["Grupo"] + Space(5)
                                _cItem := StrZero(Val(AllTrim(SubStr(_cItem,At( "_",_cItem)+1,2))),2)

                                If !ZAP->(MsSeek(ZZX->(ZZX_FILIAL+ZZX_FLOGID)+_cItem)) // J� foi feita a inclus�o deste item.
                                    // Grava os dados de item - ZAP - Item
                                    ZAP->(RecLock("ZAP",.T.))
                                    ZAP->ZAP_FILIAL := ZZX->ZZX_FILIAL
                                    ZAP->ZAP_CODIGO := ZZX->ZZX_CODIGO
                                    ZAP->ZAP_ITEM   := _cItem //_jJSon[_nX]["Grupo"]
                                    ZAP->ZAP_GORD   := ZBQ->ZBQ_GORDUR
                                    ZAP->ZAP_EST    := ZBQ->ZBQ_EST
                                    ZAP->ZAP_FLOGID := ZZX->ZZX_FLOGID
                                    ZAP->(MsUnLock()) 
                                    _aTipPrd[_nI,3]++
                                Else
                                    _aTipPrd[_nI,4]++
                                EndIf
                            EndIf
                        EndIf
                        END TRANSACTION
                    Next _nX
                Else
                    FWAlertWarning("N�o foi poss�vel ler o JSon com as informa��es do App da Qualidade." + _oRest:getLastError(),"MGLT03104")
                EndIf
            EndIf
            FreeObj(_oRest)
            FreeObj(_jJSon)
            _cMsgAux += "["+_aTipPrd[_nI,2]+Space(20-Len(_aTipPrd[_nI,2]))+"] Inclu�dos: "+AllTrim(Str(_aTipPrd[_nI,3],10)) + " J� processados: "+AllTrim(Str(_aTipPrd[_nI,4],10));
                    +" Com erro: "+AllTrim(Str(_aTipPrd[_nI,5],10))+ CRLF
        Next _nI
        FWAlertWarning("Termino da integra��o Webservice Protheus x App da Qualidade. "+CRLF+ _cMsgAux,"MGLT03105")
        If Len(_aErro) > 0 .And. !FWGetRunSchedule()
            U_ITListBox( 'Log de Processamento' , {"Erros"} , _aErro , .F. , 1 , 'Verifique os registros apresentados' )
        EndIf
        FreeObj(_oRest)
        FreeObj(_jJSon)
    EndIf
Else
    FWAlertWarning("N�o foi encontrada regras de configura��o para essa integra��o na tabela ZFM","MGLT03106")
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Scheddef
    Fun��o para defini��o de parametros na tela de schedule
@author Lucas Borges Ferreira
@since 19/03/2025
//-----------------------------------------------------------------*/
Static Function Scheddef()
    Local aParam := {} as array
    Local aOrd := {} as array

    Aadd(aParam, "P"        ) // 01 - Tipo R para relatorio P para processo
    Aadd(aParam, "MGLT031") // 02 - Pergunte do relatorio, caso nao use passar ParamDef
    Aadd(aParam, ""         ) // 03 - Alias
    Aadd(aParam, aOrd       ) // 04 - Array de ordens
    Aadd(aParam, ""         ) // 05 - Titulo
    Aadd(aParam, ""         ) // 06 - Nome do relat�rio (parametro 1 do metodo new da classe TReport)
 
Return aParam
