/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |30/11/2023| Chamado 45717. Retirado tipo Complemento e edi��o do XML
Lucas Borges  |23/05/2025| Chamado 50754. Inclu�do tratamento para CT-e Simplificado
Lucas Borges  |12/06/2025| Chamado 51021. Corrigido error.log quando XML est� corrompido
===============================================================================================================================
*/

#Include "Protheus.ch"

/*
===============================================================================================================================
Programa--------: MCOM019
Autor-----------: Lucas Borges Ferreira
Data da Criacao-: 19/05/2022
Descri��o-------: Corrige chaves informadas no CT-e. Chamado 40178
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function MCOM019

Local _aArea    := FWGetArea() as Array
Local _aAreaSDS :=SDS->(FWGetArea()) as Array
Local _aAreaSDT :=SDT->(FWGetArea()) as Array
Local _aAreaCKO :=CKO->(FWGetArea()) as Array
Local _lRet     := .F. As Logical
Local _nOpc     := 0 As Numeric
Local _cXML     := '' As Character
Local _cXMLNew  := '' As Character
Local _oXML     := Nil As Object
Local _oFullXML := Nil As Object
Local _cChaveNFe:= Space(44) as Character
Local _cError	:= ' ' As Character
Local _cWarning	:= ' ' As Character
Local _cTipo    := '' As Character
Local _cTipoNF  := '' As Character
Local _aTipoNF  := {'N=Normal','O=Bonifica��o','D=Devolu��o','B=Beneficiamento','C=Complemento'} As Array//o MATA140I descarta o PE se eu retornar Complemento
Local _nX       := 0 As Numeric
Local _lComp    := .F. As Logical
Local _bLine    := Nil As CodeBlock
Local _cTpCte   := '' As Character
Local _aAux 	:= {} As Array
Local _aAux1    := {} As Array
Local _aItens   := {} As Array
Local _oBrowse	:= Nil As Object
Local _cTagIni  := "<infNFe><chave>" As Character
Local _cTagFim  := "</chave></infNFe>" As Character
Local oDlg      := Nil As Object
Local oSize     := Nil As Object
Local oDlgKey   := Nil As Object
Local oBtnOut   := Nil As Object
Local oBtnCon   := Nil As Object
Local oMemo     := Nil As Object

DEFINE MSDIALOG oDlgKey TITLE "Manuten��o XML" FROM 0,0 TO 190,350 PIXEL OF GetWndDefault()

@ 12,008 SAY "1- Possibilida alterar as chaves informadas no CT-e. Necess�rio "+ CRLF +;
"para situa��es onde a chave informada foi recusada ou est� errada." PIXEL OF oDlgKey
@ 25,008 SAY  "2- Possibilita indicar se a NF-e ser� processada como Cliente ou "+ CRLF +;
"Fornecedor. " PIXEL OF oDlgKey
@ 38,008 SAY  "3- Manuten��o completa do XML. " PIXEL OF oDlgKey
@ 51,008 SAY  "Informe a Chave de acesso do documento a ser corrigido: " PIXEL OF oDlgKey
@ 63,015 MSGET _cChaveNFe SIZE 140,10 PIXEL OF oDlgKey

@ 79,030 BUTTON oBtnCon PROMPT "&Buscar" SIZE 38,11 PIXEL ACTION (IIf(!Empty(_cChaveNFe),_nOpc := 1,;
		MsgStop("Chave n�o informada.","MCOM01901" )) , oDlgKey:End())
@ 79,070 BUTTON oBtnOut PROMPT "&Editar XML" SIZE 38,11 PIXEL ACTION (IIf(!Empty(_cChaveNFe),_nOpc := 2,;
		MsgStop("Chave n�o informada.","MCOM01908" )), oDlgKey:End())
@ 79,110 BUTTON oBtnOut PROMPT "&Sair" SIZE 38,11 PIXEL ACTION oDlgKey:End()

ACTIVATE DIALOG oDlgKey CENTERED

If _nOpc == 1 .Or. _nOpc == 2
    _lRet := .T.
    If Substr(_cChaveNFe,21,2) == '55'
        _cTipo := '109'
    ElseIf Substr(_cChaveNFe,21,2) == '57'
        _cTipo := '214'
    EndIf
    DBSelectArea('CKO')
    CKO->(DbSetOrder(1))
    SDS->(dbSetorder(2))
    If !Empty(_cChaveNFe) .And. CKO->(DBSeek(_cTipo+_cChaveNFe+".xml")) .And. CKO->CKO_FLAG <> '9' .And. CKO->CKO_FILPRO == cFilAnt
        If SDS->(dbSeek(cFilAnt+_cChaveNFe)) .And. SDS->DS_STATUS == 'P'
            FWAlertWarning("Pre-nota j� gerada. Exclua o documento da rotina Documento de entrada", "MCOM01902")
        Else
            _cXML := AllTrim(CKO->CKO_XMLRET)
            If _nOpc == 1
                If _cTipo = '109'
                    _lRet := .F.

                    DEFINE MSDIALOG oDlgKey TITLE "Ajusta Tipo NF-e" FROM 0,0 TO 100,300 OF oDlgKey PIXEL
                                                                                            
                        _cTipoNF := TComboBox():New(10,28,{|u|if(PCount()>0,_cTipoNF:=u,_cTipoNF)}, _aTipoNF,100,20,oDlgKey,,,,,,.T.,,,,,,,,,'_cTipoNF')
                        @ 30,38 BUTTON oBtnCon PROMPT "&OK" SIZE 38,11 PIXEL ACTION (_lRet := .T., oDlgKey:End())
                        @ 30,78 BUTTON oBtnOut PROMPT "&Cancelar" SIZE 38,11 PIXEL ACTION oDlgKey:End()

                    ACTIVATE MSDIALOG oDlgKey 
                    //O MATA140I descarta o PE quando o tipo � C, logo, preciso alterar o XML e n�o usar o campo customizado
                    If _cTipoNF <> Nil .And. _cTipoNF == "C"
                        _cXMLNew := Substr(_cXML,1,At("<finNFe>",_cXML)+7)+"2"+ Substr(_cXML,At("</finNFe>",_cXML),Len(_cXML))
                        _cTipoNF := Nil
                    EndIf
                ElseIf _cTipo == '214'
                    _lRet := .F.
                    _cXML := SubStr( _cXML , At( '<' , _cXML ) )
                    
                    // Inicializa o objeto do XML
                    _oFullXML := XmlParser( _cXML , "_" , @_cError , @_cWarning )
                    If Empty(_cError)
                        If ValType( XmlChildEx( _oFullXML , "_NFEPROC" ) ) == "O" //-- Nota normal, devolucao, beneficiamento, bonificacao
                            If ValType( XmlChildEx( _oFullXML:_NFeProc , "_NFE" ) ) == "O"
                                _oXML := _oFullXML:_NFeProc:_Nfe    
                            Else
                                _oXML := _oFullXML:_NFeProc:_NFeProc:_Nfe
                            EndIf
                        ElseIf ValType(XmlChildEx(_oFullXML,"_CTE")) == "O" //-- Nota de transporte
                            _oXML := _oFullXML:_CTe
                        ElseIf ValType(XmlChildEx(_oFullXML,"_CTESIMPPROC")) == "O"
                            _oXML := _oFullXML:_CTeSimpProc:_CTeSimp
                        ElseIf ValType(XmlChildEx(_oFullXML,"_CTEPROC")) == "O" //-- Nota de transporte
                            If ValType(XmlChildEx(_oFullXML:_CTEPROC,"_ENVICTE")) == "O"
                                _oXML := _oFullXML:_CTeProc:_ENVICTE:_Cte
                            ElseIf ValType(XmlChildEx(_oFullXML:_CTEPROC,"_CTEOS")) == "O" //-- Nota de transporte CTEOS
                                _oXML := _oFullXML:_CTeProc:_CTEOS
                            Else
                                _oXML := _oFullXML:_CTeProc:_Cte
                            EndIf
                        ElseIf ValType(XmlChildEx(_oFullXML,"_CTEOSPROC")) == "O" //-- Nota de transporte CTEOS
                            _oXML := _oFullXML:_CTeOSProc:_CteOS
                        EndIf
                        
                        //-- Verifica se CTe � do tipo complementar
                        If Valtype(XmlChildEx(_oXml:_InfCte,"_INFCTECOMP")) != "U"
                            _lComp := .T.
                        EndIf
                        _cTpCte := If(ValType(XmlChildEx(_oXML:_InfCte,"_IDE")) == "O",AllTrim(_oXML:_InfCte:_Ide:_tpCTe:Text),"") //-- Armazena o tipo do CT-e.

                        //Extrai os documentos referenciados
                        If _lComp
                            //_aAux1 := If(ValType(_oXML:_InfCte:_InfCTeComp) == "O",{_oXML:_InfCte:_InfCTeComp},_oXML:_InfCte:_InfCTeComp)
                            FWAlertInfo("Situa��o n�o tratada. Favor acionar a TI.","MCOM01903" )
                        ElseIf _cTpCte == '2'
                            If ValType(XmlChildEx(_oXML:_InfCte:_infCteAnu,"_INFDOC")) != "U" .And. ValType(XmlChildEx(_oXML:_InfCte:_infCteAnu:_InfDoc,"_INFNF")) != "U"
                                //_aAux := If(ValType(_oXML:_InfCte:_infCteAnu:_InfDoc:_INFNF) == "O",{_oXML:_InfCte:_infCteAnu:_InfDoc:_INFNF},_oXML:_InfCte:_infCteAnu:_InfDoc:_INFNF)
                                FWAlertInfo("Situa��o n�o tratada. Favor acionar a TI.","MCOM01904" )
                            EndIf
                        ElseIf _oXML:_InfCte:_Versao:Text >= "2.00"
                            If Valtype(XmlChildEx(_oXml:_InfCte,"_INFCTENORM")) != "U"
                                If ValType(XmlChildEx(_oXML:_InfCte:_InfCTeNorm,"_INFDOC")) != "U" .And. ValType(XmlChildEx(_oXML:_InfCte:_InfCTeNorm:_InfDoc,"_INFNF")) != "U"
                                    _aAux := If(ValType(_oXML:_InfCte:_InfCTeNorm:_InfDoc:_INFNF) == "O",{_oXML:_InfCte:_InfCTeNorm:_InfDoc:_INFNF},_oXML:_InfCte:_InfCTeNorm:_InfDoc:_INFNF)
                                ElseIf ValType(XmlChildEx(_oXML:_InfCte:_InfCTeNorm,"_INFDOC")) != "U" .And. ValType(XmlChildEx(_oXML:_InfCte:_InfCTeNorm:_InfDoc,"_INFNFE")) != "U"
                                    _aAux1 := If(ValType(_oXML:_InfCte:_InfCTeNorm:_InfDoc:_INFNFE) == "O",{_oXML:_InfCte:_InfCTeNorm:_InfDoc:_INFNFE},_oXML:_InfCte:_InfCTeNorm:_InfDoc:_INFNFE)
                                EndIf
                            EndIf
                        Else
                            If ValType(XmlChildEx(_oXML:_InfCte:_Rem,"_INFNF")) != "U"
                                //_aAux := If(ValType(_oXML:_InfCte:_Rem:_INFNF) == "O",{_oXML:_InfCte:_Rem:_INFNF},_oXML:_InfCte:_Rem:_INFNF)
                                FWAlertInfo("Situa��o n�o tratada. Favor acionar a TI.","MCOM01905" )
                            ElseIf ValType(XmlChildEx(_oXML:_InfCte:_Rem,"_INFNFE")) != "U"
                                //_aAux1 := If(ValType(_oXML:_InfCte:_Rem:_INFNFE) == "O",{_oXML:_InfCte:_Rem:_INFNFE},_oXML:_InfCte:_Rem:_INFNFE)
                                FWAlertInfo("Situa��o n�o tratada. Favor acionar a TI.","MCOM01906" )
                            EndIf
                        EndIf
                            
                        //Trata os documentos referenciados de acordo com o formato enviado (NF-e)
                        For _nX :=1 To Len(_aAux1)
                            If ValType(XmlChildEx(_aAux1[_nX],"_CHAVE")) == "O"
                                aAdd(_aItens,{Padr(AllTrim(_aAux1[_nX]:_chave:Text),TamSX3("F1_CHVNFE")[1]),Padr(AllTrim(_aAux1[_nX]:_chave:Text),TamSX3("F1_CHVNFE")[1])})
                            ElseIf ValType(XmlChildEx(_aAux1[_nX],"_CHCTE")) == "O"
                                aAdd(_aItens,{Padr(AllTrim(_aAux1[_nX]:_chCTE:Text),TamSX3("F1_CHVNFE")[1]),Padr(AllTrim(_aAux1[_nX]:_chCTE:Text),TamSX3("F1_CHVNFE")[1])})
                            EndIf
                        Next _nX

                        //Trata os documentos referenciados de acordo com o formato enviado (Documentos N�o eletr�nicos)
                        For _nX :=1 To Len(_aAux)
                            aAdd(_aItens,{PadL(AllTrim(_aAux[_nX]:_nDoc:Text),TamSX3("F1_DOC")[1], "0") +" - "+ PadR(AllTrim(_aAux[_nX]:_Serie:Text),TamSX3("F1_SERIE")[1]),;
                                            PadR(PadL(AllTrim(_aAux[_nX]:_nDoc:Text),TamSX3("F1_DOC")[1], "0") +" - "+ PadR(AllTrim(_aAux[_nX]:_Serie:Text),TamSX3("F1_SERIE")[1]),TamSX3("F1_CHVNFE")[1])})
                        Next _nX

                        //Adiciono sempre uma linha em branco para situa��es onde precisa incluir mais uma chave
                        aAdd(_aItens,{Padr(' ',TamSX3("F1_CHVNFE")[1]),Padr(' ',TamSX3("F1_CHVNFE")[1])})

                        //Monta tela para troca dos documentos referenciados
                        If Len(_aItens) > 0
                            _bLine := {|| {	_aItens[_oBrowse:nAt,1],;									//-- Chave original
                                    _aItens[_oBrowse:nAt,2],}}											//-- Chave Nova

                            Define MsDialog oDlg Title "Documentos relacionados no CT-e" From 000,000 To 330,900 Pixel// alturaXlargura
                            //Calcula dimens�es
                            oSize := FwDefSize():New(.F.,,,oDlg)
                            oSize:AddObject( "CABECALHO",  100, 15, .T., .T. ) // Totalmente dimensionavel
                            oSize:AddObject( "GETDADOS" ,  100, 75, .T., .T. ) // Totalmente dimensionavel 
                            oSize:AddObject( "RODAPE"   ,  100, 10, .T., .T. ) // Totalmente dimensionavel
                            
                            oSize:lProp 	:= .T. // Proporcional             
                            oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
                            oSize:Process() 	   // Dispara os calculos   
                            //-- Cabecalho
                            @oSize:GetDimension("CABECALHO","LININI"),oSize:GetDimension("CABECALHO","COLINI") Say "Chave: " + _cChaveNFe Pixel Of oDlg

                            //-- Itens
                            _oBrowse := TCBrowse():New(oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
                                                            oSize:GetDimension("GETDADOS","XSIZE"),oSize:GetDimension("GETDADOS","YSIZE"),;
                                                            ,{"Chave Original","Chave Informada"},,oDlg,,,,,{||},,,,,,,,,.T.)
                            _oBrowse:SetArray(_aItens)
                            _oBrowse:bLine := _bLine
                            _oBrowse:bLDblClick	:= {|z,x|IIf(x==02,(lEditCell(_aItens,_oBrowse,"@E",x),.T.),.F.),_oBrowse:Refresh()}

                                        
                            //-- Botoes
                            TButton():New(oSize:GetDimension("RODAPE","LININI"),oSize:GetDimension("RODAPE","COLINI"),;
                                            "Continuar",oDlg,{|| _lRet := .T. ,oDlg:End()},055,012,,,,.T.) 
                            TButton():New(oSize:GetDimension("RODAPE","LININI"),oSize:GetDimension("RODAPE","COLINI")+060,;
                                            "Abortar",oDlg,{|| _lRet := .F. ,oDlg:End()},055,012,,,,.T.) 
                            Activate Dialog oDlg Centered
                        EndIf
                        //Verifico se realmente h� necessidade de alterar o XML, visto que n�o da para recriar exatamente o XML. Como existem situa��es al�m da tag infNFe e 
                        //n�o consegui tratar as tags individualmente, eu apago todo o bloco de documentos referenciados e crio do zero apenas com as chaves. Alguns CT-es tem 
                        //tags adicionais que ser�o perdidas. Trocar uma chave por ela mesma, em teoria n�o mudaria em nada, mas essas tags s�o perdidas, consequentemente o
                        //XML n�o ficaria exatamente igual. Dessa forma, tento evitar ao m�ximo alterar o XML.
                        _lRet := .F.
                        For _nX:=1 To Len(_aItens)
                            If _aItens[_nX][01] <> _aItens[_nX][02]
                                _lRet := .T.
                                Exit
                            EndIf
                        Next _nX

                        If _lRet
                            _cXMLNew := Substr(_cXML,1,At("<infDoc>",_cXML)+7)
                            If Len(_aItens) > 0
                                DbSelectArea("SF1")
                                SF1->(DbSetOrder(8))
                                For _nX:=1 To Len(_aItens)
                                    If !Empty(_aItens[_nX][02])
                                        If CKO->(dbSeek(IIf(Substr(_aItens[_nX][02],21,2)=='55','109','214')+_aItens[_nX][02]+'.xml')) .Or. SF1->(DBSeek(xFilial("SF1")+_aItens[_nX][02]))
                                            _cXMLNew += _cTagIni + _aItens[_nX][02] + _cTagFim//grava nova chave
                                        Else
                                            MsgStop("O XML da chave "+AllTrim(_aItens[_nX][02])+" n�o foi recebido e/ou escriturado e a chave ser� ignorada.", "MCOM01903")
                                            _cXMLNew += _cTagIni + _aItens[_nX][01] + _cTagFim//grava chave original
                                        EndIf
                                    EndIf
                                Next _nX
                            EndIf
                            _cXMLNew += Substr(_cXML,At("</infDoc>",_cXML),Len(_cXML))
                        Else
                            FWAlertInfo("N�o foi identificada necessidade de altera��o das chaves. Revise os dados informados.", "MCOM01907")
                        EndIf
                    Else
                        FWAlertError("Erro ao abrir o XML. Favor acionar a TI. Erro: "+_cError,"MCOM01909")
                    EndIf
                EndIf
            ElseIf _nOpc == 2
                _cXMLNew := _cXML

                DEFINE MSDIALOG oDlgKey TITLE "Manuten��o XML" FROM 0,0 TO 555,650 OF oDlgKey PIXEL
                    @ 010,008 SAY  "Chave: " + _cChaveNFe PIXEL OF oDlgKey
                    @ 020, 008 GET oMemo VAR _cXMLNew MEMO SIZE 310, 240 OF oDlgKey PIXEL
                    @ 263,120 BUTTON oBtnCon PROMPT "&OK" SIZE 38,11 PIXEL ACTION (_lRet := .T., oDlgKey:End())
                    @ 263,165 BUTTON oBtnOut PROMPT "&Cancelar" SIZE 38,11 PIXEL ACTION (_lRet := .F., oDlgKey:End())
                ACTIVATE MSDIALOG oDlgKey 

            EndIf

            If _lRet
                Begin Transaction
                SDT->(dbSetorder(3))
                If SDS->(dbSeek(cFilAnt+_cChaveNFe)) .And. SDS->DS_STATUS <> 'P'
                    //-- Deleta itens do documento 
                    SDT->(dbSeek(SDS->(DS_FILIAL+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)))
                    RecLock("SDS",.F.)
                    While !SDT->(EOF()) .And. SDT->(DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE) == SDS->(DS_FILIAL+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)
                        RecLock("SDT",.F.)
                        SDT->(dbDelete())
                        SDT->(MsUnLock())		
                        SDT->(dbSkip())
                    EndDo
                    //-- Deleta cabecalho do documento
                    SDS->(dbDelete())
                    SDS->(MsUnLock())
                EndIf
                CKO->(DBSeek(_cTipo+_cChaveNFe+".xml"))
                RecLock("CKO", .F.)
                    If !Empty(_cXMLNew) .And. _cXMLNew <> _cXML
                        If CKO->CKO_I_ALTX == 'N'
                            CKO->CKO_I_ORIG := _cXML
                            CKO->CKO_I_ALTX := 'S'
                        EndIf
                        Replace CKO->CKO_XMLRET With _cXMLNew
                    EndIf
                    If _cTipoNF <> Nil .And. CKO->CKO_I_TIPO <> _cTipoNF
                        CKO->CKO_I_TIPO := _cTipoNF
                    EndIf
                    CKO->CKO_FLAG = '0'
                CKO->(MsUnlock())
                End Transaction
            EndIf
        EndIf
        
        _oXML := Nil
        _oFullXML:= Nil
        DelClassIntF()
    Else
        FWAlertWarning("XML n�o localizado", "MCOM01904")
    EndIf
EndIf

FWRestArea(_aAreaSDT)
FWRestArea(_aAreaSDS)
FWRestArea(_aAreaCKO)
FWRestArea(_aArea)

Return
