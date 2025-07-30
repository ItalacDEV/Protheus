/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer |09/05/2022| Chamado 39902. Correção da impressão dos campos A2_CALCIRF / A1_SIMPNAC.
Igor Melgaço  |19/09/2024| Chamado 48400. Ajustes para gerar excel.
Lucas Borges  |09/10/2024| Chamado 48465. Retirada manipulação do SX1
==================================================================================================================================================================================================================
Analista       - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==================================================================================================================================================================================================================
Antonio Ramos  - Igor Melgaço  - 11/07/25 - 11/07/25 -  51336  - Ajustes para reversão do fonte até as alterações do Chamado 48465 e posterior analise
==================================================================================================================================================================================================================
*/
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: RFIS006
Autor-------------: Julio de Paula Paz
Data da Criacao---: 04/04/2017
Descrição---------: Relatório de Conferência Fiscal
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function RFIS006()

Local oReport 
Private _aCabecalho:={}
Private _aCampos   :={}
Private _lRet      :=.T.
Private _aCabList := {}
Private _aCabExcel := {}
Private _aStrucRel := {}

_cSelCFOP:= " SELECT X5_CHAVE ,X5_DESCRI  FROM "+ RetSqlName("SX5") +" X5 WHERE D_E_L_E_T_ = ' ' AND X5_TABELA  = '13' AND X5_FILIAL  = '" + xFilial("SX5") + "' ORDER BY X5_CHAVE"

_aItalac_F3:={}//       1           2         3                   4                      5          6                     7         8          9         10         11        12
//  (_aItalac_F3,{"CPOCAMPO",_cTabela   ,_nCpoChave        , _nCpoDesc               ,_bCondTab   , _cTitAux        , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR07",_cSelCFOP   ,{|Tab|(Tab)->X5_CHAVE },{|Tab| (Tab)->X5_DESCRI},            ,"CFOP"      ,    4     ,          ,          ,.F.        ,       , } )

DO WHILE .T.

   IF !Pergunte("RFIS006")
      EXIT
   ENDIF
   
   IF MV_PAR04 = 1
   
       oReport:=Report()
       oReport:PrintDialog()
       oReport:=NIL
       U_ITLOGACS()
       Loop
   
   ELSE
   
       FWMSGRUN( , {|| RFIS006Trab() , _lRet := RFIS006D()}, "Aguarde!" , 'Lendo Dados do Relatório...' )
     
       If ! _lRet
          U_ITMSG("Não existem dados para emissão do relatório.","Atenção",,1)
          LOOP
       EndIf
      
       FWMSGRUN( , {|oproc| _lRet := RFIS006M(,oproc)}, "Aguarde!" , 'Gerando o Relatório...' )
      
   ENDIF

ENDDO
//================================================================================
// Fecha e exclui as tabelas temporárias
//================================================================================                    
If Select("TRBREL") > 0
     TRBREL->( DBCloseArea() )
EndIf

If Select("TRBRAT") > 0
   TRBRAT->( DBCloseArea() )
EndIf

Return

/*
===============================================================================================================================
Programa----------: Report()
Autor-------------: Alex Wallauer
Data da Criacao---: 18/09/2017
Descrição---------: Relatório de Conferência Fiscal
Parametros--------: Nenhum
Retorno-----------: Objeto
===============================================================================================================================
*/  
Static Function Report()

Local oReport,I
Local oSection1 


FWMSGRUN( , {|| RFIS006Trab() }, "Aguarde!" , 'Criando Tabelas Temporarias...' )

oReport := TReport():New("RFIS006","Relatório de Conferência Fiscal","RFIS006",{|oReport| RFIS006M(oReport)},"Relatório de Conferência Fiscal")

oSection := TRSection():New(oReport,""	,{""})
oSection:SetTotalInLine(.F.)
oSection1 := TRSection():New(oSection,"RELATORIO DE CONFERENCIA FISCAL"		,{"TRBREL"})
oSection1:SetTotalInLine(.F.)

FOR I := 1 TO LEN(_aCampos)

    SX3->(DBSETORDER(2))
    IF SX3->(DBSEEK(_aCampos[I]))
       nTam := getsx3cache(_aCampos[I],"X3_TAMANHO")	
       cPict:=ALLTRIM(getsx3cache(_aCampos[I],"X3_PICTURE"))
       TRCell():New(oSection1,_aCampos[I],"TRBREL",_aCabecalho[I,1],cPict,nTam,/*lPixel*/,/*Block*/	)
    ELSE
       nTam:=LEN(TRBREL->(FIELDGET(FIELDPOS(_aCampos[I]))))
       TRCell():New(oSection1,_aCampos[I],"TRBREL",_aCabecalho[I,1],"@!",nTam,/*lPixel*/,/*Block*/	)
    ENDIF

NEXT
SX3->(DBSETORDER(1))

Return oReport

/*
===============================================================================================================================
Programa----------: RFIS006D
Autor-------------: Julio de Paula Paz
Data da Criacao---: 04/04/2017
Descrição---------: Gera os dados do relatório e grava em tabelas temporárias para emissão do relatorio em Excel.
Parametros--------: Nenhum
Retorno-----------: .T. OU .F.
===============================================================================================================================
*/  
Static Function RFIS006D()                                                                                                                  
Local _cWhere, _cQry, _cOrder
Local _lRet := .T.

Begin Sequence 

   _cQry := " SELECT FT_FILIAL, '' AS ST_NOME, '' AS ST_CGC, '' AS ST_INSC, '' AS ST_INSCM, '' AS ST_CIDCOB,"
   _cQry += " '' AS ST__ESTCOB, FT_EMISSAO, FT_ENTRADA, FT_NFISCAL, FT_SERIE, FT_ESPECIE, FT_CHVNFE, '' AS F3_CODRSEF,"
   _cQry += " FT_TIPOMOV, FT_TIPO,'' AS D1_TES, '' AS F4_FINALID, FT_CFOP, FT_NFORI, FT_SERORI, '' AS CCUSTO, '' AS CTT_DESC01," 
   _cQry += " FT_CLIEFOR, FT_LOJA, '' AS NOME, '' AS CNPJ, '' AS INSCREST, '' AS NUNICIPIO, '' AS ESTADO, '' AS ARMAZEM,"
   _cQry += " B1_GRUPO, BM_DESC, FT_PRODUTO, FT_ITEM, B1_DESC, FT_POSIPI, '' AS UNIMEDIDA, FT_QUANT, FT_PRCUNIT, FT_DESCONT,"
   _cQry += " FT_DESPESA, FT_FRETE, FT_SEGURO, FT_TOTAL, FT_VALCONT, FT_CLASFIS, FT_BASEICM, FT_ALIQICM, FT_VALICM, FT_BASERET,"
   _cQry += " FT_ALIQSOL, FT_MARGEM, FT_ICMSRET, FT_BASEDES, FT_ICMSCOM, FT_CTIPI, FT_BASEIPI, FT_ALIQIPI, FT_VALIPI, FT_CSTPIS,"
   _cQry += " FT_BASEPIS, FT_ALIQPIS, FT_VALPIS, FT_CSTCOF, FT_BASECOF, FT_ALIQCOF, FT_VALCOF, FT_VALIRR, FT_VALINS, FT_VRETCSL," 
   _cQry += " FT_VRETPIS, FT_VRETCOF, 0 AS D1_VALISS, FT_VALFUM, FT_VLSENAR, FT_VALFUND, '' AS F2_I_CTRA, '' AS F2_I_LTRA, '' AS A2_NOME," 
   _cQry += "'' AS A2_MUN, '' AS A2_EST, '' AS F2_I_PLACA, 0 AS F2_I_FRET, '' AS F2_TPFRETE, '' AS F4_DUPLIC, '' AS F4_ESTOQUE, FT_VALANTI "
   _cQry += " FROM "+RetSqlName("SFT")+" SFT ," + RetSqlName("SB1")+" SB1 , "+RetSqlName("SBM")+" SBM "
   _cQry += " WHERE  SFT.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' AND SBM.D_E_L_E_T_ = ' ' "

   _cWhere :=  " AND FT_PRODUTO = B1_COD AND BM_GRUPO = B1_GRUPO "
             
   If ! Empty(MV_PAR05)      
      _cWhere +=  " AND B1_GRUPO = '"+MV_PAR05+"' "
   EndIf

   If ! Empty(MV_PAR01)
      _cWhere +=  " AND FT_FILIAL IN " + FORMATIN(MV_PAR01,";")
   EndIf              
   
   If ! Empty(MV_PAR02)        
      _cWhere +=  " AND FT_ENTRADA >= '"+Dtos(MV_PAR02)+"' "
   EndIf
   
   If ! Empty(MV_PAR03)        
      _cWhere +=  " AND FT_ENTRADA <= '"+Dtos(MV_PAR03)+"' "
   EndIf

   If ! Empty(MV_PAR07)
      _cWhere +=  " AND FT_CFOP IN " + FORMATIN(MV_PAR07,";")
   EndIf              

   If MV_PAR06 = 1
      _cWhere +=  " AND FT_TIPOMOV = 'E' "
   ELSEIf MV_PAR06 = 2
      _cWhere +=  " AND FT_TIPOMOV = 'S' "
   EndIf


   //=========================================		
   // Forncedor De - Ate 
   //=========================================
   If !Empty(MV_PAR10)	
   	_cWhere  += " AND FT_CLIEFOR BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR10 + "'"
   ELSEIf !Empty(MV_PAR08) 
   	_cWhere  += " AND FT_CLIEFOR >= '" + MV_PAR08 + "' "
   EndIf                                                             
   
   //=========================================		
   // Loja Forncedor De - Ate
   //=========================================
   If !Empty(MV_PAR11)	
   	_cWhere  += " AND FT_LOJA BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR11 + "'"
   ELSEIf !Empty(MV_PAR09) 
   	_cWhere  += " AND FT_LOJA >= '" + MV_PAR09 + "' "
   EndIf             
   
   //=========================================		
   // Cliente De - Ate 
   //=========================================
   If !Empty(MV_PAR14)	
   	_cWhere  += " AND FT_CLIEFOR BETWEEN '" + MV_PAR12 + "' AND '" + MV_PAR14 + "'"
   ELSEIf !Empty(MV_PAR12) 
   	_cWhere  += " AND FT_CLIEFOR >= '" + MV_PAR12 + "' "
   EndIf                                                             
   
   //=========================================		
   // Loja Cliente De - Ate
   //=========================================
   If !Empty(MV_PAR15)	
   	_cWhere  += " AND FT_LOJA BETWEEN '" + MV_PAR13 + "' AND '" + MV_PAR15 + "'"
   ELSEIf !Empty(MV_PAR13) 
   	_cWhere  += " AND FT_LOJA >= '" + MV_PAR13 + "' "
   EndIf             

   _cOrder :=  " ORDER BY FT_TIPOMOV, FT_ENTRADA, FT_NFISCAL, FT_SERIE, FT_CLIEFOR, FT_LOJA "

   _cQry += _cWhere + _cOrder     
     
   If Select("QRYSFT") > 0
      QRYSFT->(DbCloseArea())
   EndIf
   
   _cQry := ChangeQuery(_cQry) 
   DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry), "QRYSFT", .F., .T.)    
   TCSetField("QRYSFT", "FT_EMISSAO", "D", 8)
   TCSetField("QRYSFT", "FT_ENTRADA", "D", 8)

   If QRYSFT->(Eof()) .Or. QRYSFT->(Bof())
      _lRet := .F.
   EndIf                 
   
End Sequence

Return _lRet

/*
===============================================================================================================================
Programa----------: RFIS006M
Autor-------------: Julio de Paula Paz
Data da Criacao---: 04/04/2017
Descrição---------: Monta o Relatório em Excel tendo como base a query gerada.
Parametros--------: oReport,oproc
Retorno-----------: Nenhum
===============================================================================================================================
*/  
Static Function RFIS006M(oReport,oproc)
Local  _nI
Local  _nJ
Local _aFilial := FWLoadSM0()
Local _cCnpj
Local _nTotRegs 
Local _cCamposFor
Local _nQtdItens
Local _cListaCFOP
Local _cCfopDev1 := U_ITGETMV( 'IT_CFOPDEV1' , '' )  
Local _cCfopDev2 := U_ITGETMV( 'IT_CFOPDEV2' , '' )  
Local _aDadosRel, _aRegDados, _cNomeCampo  

Begin Sequence                                                                       
   
   IF oReport # NIL
      _lRet:=.T.
      FWMSGRUN( , {|| _lRet := RFIS006D()}, "Aguarde!" , 'Gerando Dados do Relatório...' )
      If ! _lRet
         U_ITMSG("Não existem dados para emissão do relatório.","Atenção",,1)
         Break
      EndIf
   ENDIF
   
   //================================================================================
   // Conta total de registros a serem processados
   //================================================================================
   DBSELECTAREA("QRYSFT")
   Count to _nTotRegs                                      

   IF  _nTotRegs > 10000
      IF !U_ITMSG("Serão processado "+ALLTRIM(STR(_nTotRegs))+" Registros. Deseja Continuar?",'Atenção!',,3,2,2)
          RETURN .F.
      ENDIF
   ENDIF

   QRYSFT->(DbGoTop())
                                
   DBSelectArea("TRBREL")
   ZAP
   DBSelectArea("TRBRAT")
   ZAP

   IF oReport # NIL
      oReport:SetMeter(_nTotRegs)
      oReport:Section(1):Init()
      oReport:Section(1):PrintLine() 
      oReport:Section(1):Section(1):Init()
   ENDIF
   
   ncont:=0   
   //================================================================================
   // Efetua a leitura dos dados e grava na tabela temporária.
   //================================================================================   
   SA1->(DbSetOrder(1)) // CADASTRO DE CLIENTES            // F1_FILIAL+F1_COD+F1_LOJA
   SD1->(DbSetOrder(1)) // ITENS DA NOTA FISCAL DE ENTRADA // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
   SF3->(DbSetOrder(4)) // LIVROS FISCAIS                  // F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
   SF4->(DbSetOrder(1)) // TES TIPOS DE ENTRADA E SAÍDA    // F4_FILIAL+F4_CODIGO
   CTT->(DbSetOrder(1)) // CENTRO DE CUSTO                 // CTT_FILIAL+CTT_CUSTO 
   SD2->(DbSetOrder(3)) // ITENS DA NOTA FISCAL DE SAÍDA   // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
   SF2->(DbSetOrder(2)) // CAPA DA NOTA FISCAL DE SAÍDA    // F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE 
   SF1->(DbSetOrder(1)) // CAPA DA NOTA FISCAO DE ENTRADA  // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO  
   //-----------------------------------//
   SE2->(DbSetOrder(6)) // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
   SE1->(DbSetOrder(2)) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
   
   _cCamposFor := "D1_TES/CCUSTO/CTT_DESC01/NOME/CNPJ/INSCREST/NUNICIPIO/ESTADO/ARMAZEM/UNIMEDIDA/D1_VALISS/F2_I_CTRA/F2_I_LTRA/F2_I_PLACA/F2_I_FRET/F2_TPFRETE/F4_DUPLIC/F4_ESTOQUE/F4_FINALID/A2_NOME/A2_MUN/A2_EST"
   _cCamposFor += "/F3_CODRSEF/ST_NOME/ST_CGC/ST_INSC/ST_INSCM/ST_CIDCOB/ST__ESTCOB/ED_CODIGO/ED_DESCRIC/A2CALCIRF/A1SIMPNAC/D1_BASEISS/D1_ALIQISS/"
   
   _aDadosRel := {}
   _aRegDados := {}

   Do While ! QRYSFT->(Eof())

      TRBREL->(DBAPPEND())

      IF oReport # NIL
         oReport:IncMeter()
         ncont++
         oReport:SetMsgPrint("Lendo " + STRZERO(ncont,7) + " de " + STRZERO(_nTotRegs,7))
      ELSE
          IF valtype(oproc) = "O"
             ncont++
      	    oproc:cCaption := ("Lendo " + STRZERO(ncont,7) + " de " + STRZERO(_nTotRegs,7))
   		    ProcessMessages()
   	    ENDIF
      ENDIF
      
      SF3->(DbSeek(QRYSFT->(FT_FILIAL+FT_CLIEFOR+FT_LOJA+FT_NFISCAL+FT_SERIE))) // F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE

      For _nI := 1 To TRBREL->(FCount())    
          If ! Alltrim(TRBREL->(FieldName(_nI))) $ _cCamposFor // Esta condição exclui os campos que terão os valores atribuidos manualmente.         
             &("TRBREL->"+TRBREL->(FieldName(_nI))) := &("QRYSFT->"+(TRBREL->(FieldName(_nI))))
          EndIf
      Next   

      TRBREL->FT_TIPO:=TipoLanc(QRYSFT->FT_TIPO)
      
      SA2->(DbSetOrder(3)) // CADASTRO DE FORNECEDORES // F2_FILIAL+F2_CGC 
      _nI := Ascan(_aFilial,{|x| x[5] = QRYSFT->FT_FILIAL})   
      _cCnpj := _aFilial[_nI,18]
      If SA2->(DbSeek(xFilial("SA2")+AllTrim(_cCnpj)))
         TRBREL->ST_NOME    := SA2->A2_NOME
         TRBREL->ST_CGC     := _cCnpj
         TRBREL->ST_INSC    := SA2->A2_INSCR  
         TRBREL->ST_INSCM   := SA2->A2_INSCRM 
         TRBREL->ST_CIDCOB  := SA2->A2_MUN
         TRBREL->ST__ESTCOB := SA2->A2_EST
      EndIf
      
      SA2->(DbSetOrder(1)) // CADASTRO DE FORNECEDORES // F2_FILIAL+F2_COD+F2_LOJA

      Do While ! SF3->(Eof()) .And. QRYSFT->(FT_FILIAL+FT_CLIEFOR+FT_LOJA+FT_NFISCAL+FT_SERIE) == SF3->(F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE)
         If SF3->F3_ENTRADA == QRYSFT->FT_ENTRADA
            TRBREL->F3_CODRSEF := SF3->F3_CODRSEF 
            Exit 
         EndIf

         SF3->(DbSkip())
      EndDo

      If Val(AllTrim(QRYSFT->FT_CFOP)) < 5000 // FT_TIPOMOV == 'E' // Pagamento - dados da nota fiscal de entrada  
         
         //==========================>> INCLUIR AQUI UM SEEK NA SF1
         SF1->(DbSeek(QRYSFT->(FT_FILIAL+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA)))
         SD1->(DbSeek(QRYSFT->(FT_FILIAL+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM)))
         SF4->(DbSeek(xFilial("SF4")+SD1->D1_TES))
         CTT->(DbSeek(xFilial("CTT")+SD1->D1_CC)) 

         _cListaCFOP := _cCfopDev1 + "#" + _cCfopDev2 // Relacao de CFOPs de devolucao consideradas no relatorio de conferencia fiscal.
         If ! Empty(QRYSFT->FT_NFORI) .And. AllTrim(QRYSFT->FT_CFOP) $ _cListaCFOP
            SA1->(DbSeek(xFilial("SA1")+QRYSFT->(FT_CLIEFOR+FT_LOJA)))  
            
            TRBREL->NOME       := SA1->A1_NOME 
            TRBREL->CNPJ       := SA1->A1_CGC  
            TRBREL->INSCREST   := SA1->A1_INSCR 
            TRBREL->NUNICIPIO  := SA1->A1_MUN 
            TRBREL->ESTADO     := SA1->A1_EST 

            TRBREL->A1SIMPNAC := "" 
            If SA1->A1_SIMPNAC == "1"
               TRBREL->A1SIMPNAC := "SIM" 
            ElseIf SA1->A1_SIMPNAC == "2"
               TRBREL->A1SIMPNAC := "NAO"
            EndIf

         ElseIf ! Empty(QRYSFT->FT_NFORI) .And. RFIS006A(QRYSFT->FT_CLIEFOR)  // .and. So numeros em FT_CLIEFOR
            SA1->(DbSeek(xFilial("SA1")+QRYSFT->(FT_CLIEFOR+FT_LOJA)))  
            
            TRBREL->NOME       := SA1->A1_NOME 
            TRBREL->CNPJ       := SA1->A1_CGC  
            TRBREL->INSCREST   := SA1->A1_INSCR 
            TRBREL->NUNICIPIO  := SA1->A1_MUN 
            TRBREL->ESTADO     := SA1->A1_EST 

            TRBREL->A1SIMPNAC := "" 
            If SA1->A1_SIMPNAC == "1"
               TRBREL->A1SIMPNAC := "SIM" 
            ElseIf SA1->A1_SIMPNAC == "2"
               TRBREL->A1SIMPNAC := "NAO"
            EndIf
             
         Else
            SA2->(DbSeek(xFilial("SA2")+QRYSFT->(FT_CLIEFOR+FT_LOJA))) 

            TRBREL->NOME       := SA2->A2_NOME 
            TRBREL->CNPJ       := SA2->A2_CGC  
            TRBREL->INSCREST   := SA2->A2_INSCR 
            TRBREL->NUNICIPIO  := SA2->A2_MUN 
            TRBREL->ESTADO     := SA2->A2_EST 
            
            TRBREL->A2CALCIRF := "" 
            If SA2->A2_CALCIRF == '1' // ;; 
               TRBREL->A2CALCIRF := "NORMAL" // 1=Normal 
            ElseIf SA2->A2_CALCIRF == '2'
               TRBREL->A2CALCIRF := "IRRF BAIXA" // 2=IRRF Baixa; 
            ElseIf SA2->A2_CALCIRF == '3'
               TRBREL->A2CALCIRF := "SIMPLES" // 3=Simples
            ElseIf SA2->A2_CALCIRF == '4'
               TRBREL->A2CALCIRF := "EMPRESA INDIVIDUAL" // 4=Empresa Individual 
            EndIf 
         EndIf
         
         //--------------------
         // Entradas :  BC IPI -> D1_BASEIPI
         //               ALQ IPI -> D1_IPI
         //               VL IPI -> D1_VALIPI  
         TRBREL->FT_BASEIPI := SD1->D1_BASEIPI  // BC IPI	
         TRBREL->FT_ALIQIPI := SD1->D1_IPI      // ALQ IPI	
         TRBREL->FT_VALIPI  := SD1->D1_VALIPI   // VL IPI	
         
         //Entradas : DESPESAS -> D1_DESPESA
         //          FRETE -> D1_VALFRE
         //          SEGURO -> D1_SEGURO    
         
         TRBREL->FT_DESPESA := SD1->D1_DESPESA // DESPESAS	
         TRBREL->FT_FRETE   := SD1->D1_VALFRE  // FRETE	
         TRBREL->FT_SEGURO  := SD1->D1_SEGURO  // SEGURO	
         
         TRBREL->FT_PRCUNIT := SD1->D1_VUNIT   // VL UNITARIO // Valor de custo.
                 
         TRBREL->D1_TES     := SD1->D1_TES
         TRBREL->CCUSTO     := SD1->D1_CC
         TRBREL->CTT_DESC01 := CTT->CTT_DESC01 
         TRBREL->ARMAZEM    := SD1->D1_LOCAL
         TRBREL->UNIMEDIDA  := SD1->D1_UM
         //-------------------------------------------
         TRBREL->D1_BASEISS := SD1->D1_BASEISS
         TRBREL->D1_ALIQISS := SD1->D1_ALIQISS
         //-------------------------------------------
         TRBREL->D1_VALISS  := SD1->D1_VALISS    
         TRBREL->F4_DUPLIC  := SF4->F4_DUPLIC
         TRBREL->F4_ESTOQUE := SF4->F4_ESTOQUE
         TRBREL->F4_FINALID := SF4->F4_FINALID

         If SE2->(MsSeek(SF1->(F1_FILIAL+F1_FORNECE+F1_LOJA+F1_SERIE+F1_DOC)))
            TRBREL->ED_CODIGO  := SE2->E2_NATUREZ
            TRBREL->ED_DESCRIC := Posicione("SED",1,xfilial("SED")+SE2->E2_NATUREZ,"ED_DESCRIC") 
         EndIf

      Else // Recebimento Dados da nota fiscal de saída. // FT_TIPOMOV = 'S'         
         _nQtdItens := RFIS006R(QRYSFT->FT_FILIAL,QRYSFT->FT_NFISCAL,QRYSFT->FT_SERIE,QRYSFT->FT_CLIEFOR,QRYSFT->FT_LOJA)
      
         SD2->(DbSeek(QRYSFT->(FT_FILIAL+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM))) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM 
         SF4->(DbSeek(xFilial("SF4")+SD2->D2_TES))
         CTT->(DbSeek(xFilial("CTT")+SD2->D2_CCUSTO))
         SA1->(DbSeek(xFilial("SA1")+QRYSFT->(FT_CLIEFOR+FT_LOJA)))  
         SF2->(DbSeek(QRYSFT->(FT_FILIAL+FT_CLIEFOR+FT_LOJA+FT_NFISCAL+FT_SERIE))) // F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE 
         
         _cListaCFOP := _cCfopDev1 + "#" + _cCfopDev2 // Relacao de CFOPs de devolucao consideradas no relatorio de conferencia fiscal.
         If ! Empty(QRYSFT->FT_NFORI) .And. AllTrim(QRYSFT->FT_CFOP) $ _cListaCFOP
            SA2->(DbSeek(xFilial("SA2")+QRYSFT->(FT_CLIEFOR+FT_LOJA))) 

            TRBREL->NOME       := SA2->A2_NOME 
            TRBREL->CNPJ       := SA2->A2_CGC  
            TRBREL->INSCREST   := SA2->A2_INSCR 
            TRBREL->NUNICIPIO  := SA2->A2_MUN 
            TRBREL->ESTADO     := SA2->A2_EST 
            
            TRBREL->A2CALCIRF := "" 
            If SA2->A2_CALCIRF == '1' // ;; 
               TRBREL->A2CALCIRF := "NORMAL" // 1=Normal 
            ElseIf SA2->A2_CALCIRF == '2'
               TRBREL->A2CALCIRF := "IRRF BAIXA" // 2=IRRF Baixa; 
            ElseIf SA2->A2_CALCIRF == '3'
               TRBREL->A2CALCIRF := "SIMPLES" // 3=Simples
            ElseIf SA2->A2_CALCIRF == '4'
               TRBREL->A2CALCIRF := "EMPRESA INDIVIDUAL" // 4=Empresa Individual 
            EndIf
            
         ElseIf ! Empty(QRYSFT->FT_NFORI) .And. ! RFIS006A(QRYSFT->FT_CLIEFOR) // .and. Contem letras em FT_CLIEFOR
            SA2->(DbSeek(xFilial("SA2")+QRYSFT->(FT_CLIEFOR+FT_LOJA))) 

            TRBREL->NOME       := SA2->A2_NOME 
            TRBREL->CNPJ       := SA2->A2_CGC  
            TRBREL->INSCREST   := SA2->A2_INSCR 
            TRBREL->NUNICIPIO  := SA2->A2_MUN 
            TRBREL->ESTADO     := SA2->A2_EST 
            
            TRBREL->A2CALCIRF := "" 
            If SA2->A2_CALCIRF == '1' // ;; 
               TRBREL->A2CALCIRF := "NORMAL" // 1=Normal 
            ElseIf SA2->A2_CALCIRF == '2'
               TRBREL->A2CALCIRF := "IRRF BAIXA" // 2=IRRF Baixa; 
            ElseIf SA2->A2_CALCIRF == '3'
               TRBREL->A2CALCIRF := "SIMPLES" // 3=Simples
            ElseIf SA2->A2_CALCIRF == '4'
               TRBREL->A2CALCIRF := "EMPRESA INDIVIDUAL" // 4=Empresa Individual 
            EndIf

         Else
            SA1->(DbSeek(xFilial("SA1")+QRYSFT->(FT_CLIEFOR+FT_LOJA)))  
            
            TRBREL->NOME       := SA1->A1_NOME 
            TRBREL->CNPJ       := SA1->A1_CGC  
            TRBREL->INSCREST   := SA1->A1_INSCR 
            TRBREL->NUNICIPIO  := SA1->A1_MUN 
            TRBREL->ESTADO     := SA1->A1_EST 

            TRBREL->A1SIMPNAC := "" 
            If SA1->A1_SIMPNAC == "1"
               TRBREL->A1SIMPNAC := "SIM" 
            ElseIf SA1->A1_SIMPNAC == "2"
               TRBREL->A1SIMPNAC := "NAO"
            EndIf

         EndIf
   
         //--------------------
         
         //SAIDAS :  BC IPI -> SD2->D2_BASEIPI
         //          ALQ IPI -> SD2->D2_IPI
         //            VL IPI -> SD2->D2_VALIPI 
        
         TRBREL->FT_BASEIPI := SD2->D2_BASEIPI  // BC IPI	
         TRBREL->FT_ALIQIPI := SD2->D2_IPI      // ALQ IPI	
         TRBREL->FT_VALIPI  := SD2->D2_VALIPI   // VL IPI	
                                                
         
         //SAIDAS : DESPESAS -> SD2->D2_DESPESA
         //       FRETE -> SD2->D2_VALFRE
         //       SEGURO -> SD2->D2_SEGURO 

         TRBREL->FT_DESPESA := SD2->D2_DESPESA // DESPESAS	
         TRBREL->FT_FRETE   := SD2->D2_VALFRE  // FRETE	
         TRBREL->FT_SEGURO  := SD2->D2_SEGURO  // SEGURO	

         TRBREL->FT_PRCUNIT := SD2->D2_PRUNIT // VL UNITARIO	
        
         //--------------------
         
         TRBREL->D1_TES     := SD2->D2_TES 
         TRBREL->CCUSTO     := SD2->D2_CCUSTO 
         TRBREL->CTT_DESC01 := CTT->CTT_DESC01 
         //------------------------------------
         TRBREL->NOME       := SA1->A1_NOME 
         TRBREL->CNPJ       := SA1->A1_CGC  
         TRBREL->INSCREST   := SA1->A1_INSCR 
         TRBREL->NUNICIPIO  := SA1->A1_MUN   
         TRBREL->ESTADO     := SA1->A1_EST   
         //-------------------------------------
         TRBREL->ARMAZEM    := SD2->D2_LOCAL 
         TRBREL->UNIMEDIDA  := SD2->D2_UM
         //-------------------------------------
         TRBREL->D1_BASEISS := SD2->D2_BASEISS
         TRBREL->D1_ALIQISS := SD2->D2_ALIQISS 
         //-------------------------------------
         TRBREL->D1_VALISS  := SD2->D2_VALISS 
         TRBREL->F2_I_CTRA  := SF2->F2_I_CTRA  
         TRBREL->F2_I_LTRA  := SF2->F2_I_LTRA  
         TRBREL->F2_I_PLACA := SF2->F2_I_PLACA  
         TRBREL->F2_I_FRET  := SF2->F2_I_FRET / _nQtdItens // Ratear valor do frete pela qtd itens.
         TRBREL->F2_TPFRETE := SF2->F2_TPFRETE 
         TRBREL->F4_DUPLIC  := SF4->F4_DUPLIC  
         TRBREL->F4_ESTOQUE := SF4->F4_ESTOQUE  
         TRBREL->F4_FINALID := SF4->F4_FINALID                      
         
         If !Empty(SF2->F2_I_CTRA)
            SA2->(DbSeek(xFilial("SA2")+SF2->(F2_I_CTRA+F2_I_LTRA))) 
            TRBREL->A2_NOME    := SA2->A2_NOME    
            TRBREL->A2_MUN     := SA2->A2_MUN     
            TRBREL->A2_EST     := SA2->A2_EST              
         EndIf
          
      EndIf
      
      IF oReport # NIL
         oReport:Section(1):Section(1):PrintLine() 
      Else
      
         _aRegDados := {}
         
         For _nI := 1 To Len(_aCampos)
             _cNomeCampo := "TRBREL->"+_aCampos[_nI]
             
             _nJ := AsCan(_aStrucRel, {|x| x[1] =AllTrim(_aCampos[_nI])} )
             If _nJ > 0 .And. _aStrucRel[_nJ,2] == "C"
                If SubStr(AllTrim(&(_cNomeCampo)),1,1) $ "0123456789"
                   Aadd(_aRegDados, CHR(160)+&(_cNomeCampo) )
                Else
                   Aadd(_aRegDados, &(_cNomeCampo) )
                EndIf
             Else
                Aadd(_aRegDados, &(_cNomeCampo) )
             EndIf
         Next
         
         Aadd(_aDadosRel, _aRegDados)
      EndIf

      QRYSFT->(DbSkip())

   EndDo
   

IF oReport # NIL
   oReport:Section(1):SetPageBreak(.T.)
   oReport:Section(1):Finish()
   oReport:Section(1):Section(1):Finish()
ELSE
   //================================================================================
   // Abrindo o relatório no Excel.
   //================================================================================

   oproc:cCaption := ("Exportando para excel...")

   _cDir := GetTempPath() 
   _cArq := "RFIS006_"+STRTRAN(DTOC(Date()),"/","-")+"_"+StrTran(Time(),":","_")+".xlsx"
   //ITGEREXCEL(_cNomeArq,_cDiretorio,_cTitulo,_cNomePlan,_aCabecalho,_aDetalhe,_lLeTabTemp,_cAliasTab,_aCampos,_lScheduller,_lCriaPastas,_aPergunte,_lEnviaEmail,_lXLSX,oProc)
   U_ITGEREXCEL(_cArq,_cDir  ,"RELATORIO DE CONFERENCIA FISCAL" ,          ,_aCabExcel ,_aDadosRel,           ,          ,       , .T.        ,            ,          , .F.        ,.T.,oproc)

    //Tentando abrir o objeto
    nRet := ShellExecute("open", _cArq, "", _cDir, 1)
     
    //Se houver algum erro
    If nRet <= 32
        MsgStop("Não foi possível abrir o arquivo " +_cDir+_cArq+ "!", "Atenção")
    EndIf 

ENDIF

End Sequence

Return

/*
===============================================================================================================================
Programa----------: RFIS006R
Autor-------------: Julio de Paula Paz
Data da Criacao---: 18/05/2017
Descrição---------: Retorna a quantidade de itens da nota fiscal para rateio de frete.
Parametros--------: _cFilial  = Código da filial
                    _cNrNota  = Numero da Nota fiscal
                    _cSerieNF = Serie da Nota fiscal
                    _cFornec  = Codigo do Fornecedor
                    _cLoja    = Loja do Fornecedor
Retorno-----------: Quantidade de itens da nota fiscal.
===============================================================================================================================
*/  
Static Function RFIS006R(_cFilial,_cNrNota,_cSerieNF,_cFornec,_cLoja)

Local _nRet := 0
Local _aOrd := SaveOrd({"SD2"})
Local _nRegAtu := SD2->(Recno())
Local _nI

Begin Sequence
   If TRBRAT->(DbSeek(_cFilial+_cNrNota+_cSerieNF+_cFornec+_cLoja))
      _nRet := TRBRAT->QTDITENS
   Else  
      _nI := 0
      SD2->(DbSetOrder(3)) // ITENS DA NOTA FISCAL DE SAÍDA   // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
      SD2->(DbSeek(_cFilial+_cNrNota+_cSerieNF+_cFornec+_cLoja)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM 
      Do While ! SD2->(Eof()) .And. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == _cFilial+_cNrNota+_cSerieNF+_cFornec+_cLoja
         _nI += 1
         
         SD2->(DbSkip())
      EndDo   
      
      TRBRAT->(DbAppend())
      TRBRAT->FT_FILIAL  := _cFilial
      TRBRAT->FT_CLIEFOR := _cFornec
      TRBRAT->FT_LOJA    := _cLoja
      TRBRAT->FT_NFISCAL := _cNrNota
      TRBRAT->FT_SERIE   := _cSerieNF
      TRBRAT->QTDITENS   := If(_nI == 0,1,_nI)
      TRBRAT->(MsUnlock())
           
      _nRet := If(_nI == 0,1,_nI)
      
   EndIf
         
End Sequence

RestOrd(_aOrd)
SD2->(DbGoto(_nRegAtu))

Return _nRet

/*
===============================================================================================================================
Programa----------: RFIS006A
Autor-------------: Julio de Paula Paz
Data da Criacao---: 09/06/2017
Descrição---------: Verifica se em uma string possui apenas numueros ou existe letras com numeros.
Parametros--------: _cCampo = Contúdo a ser verificado.
Retorno-----------: .T. = Existe apenas numeros no conteúdo. ou .F. = Existe pelo menos uma letra no contéudo de _cCampo.
===============================================================================================================================
*/  
Static Function RFIS006A(_cCampo)

Local _lRet := .T.
Local _aDados, _nI 

Begin Sequence
   _cCampo := AllTrim(_cCampo)    
   _aDados := {}
   For _nI:= 1 to Len(_cCampo)
       Aadd(_aDados,SubStr(_cCampo,_nI,1))
   Next
                      
   For _nI:= 1 to Len(_aDados)
       If ! _aDados[_nI] $ "1234567890"
          _lRet := .F. // Existe pelo menos uma letra em _cCampo.
       EndIf        
   Next

End Sequence

Return _lRet

/*
===============================================================================================================================
Programa----------: RFIS006Trab
Autor-------------: Julio de Paula Paz
Data da Criacao---: 09/06/2017
Descrição---------: Verifica se em uma string possui apenas numueros ou existe letras com numeros.
Parametros--------: _cCampo = Contúdo a ser verificado.
Retorno-----------: .T. = Existe apenas numeros no conteúdo. ou .F. = Existe pelo menos uma letra no contéudo de _cCampo.
===============================================================================================================================
*/  
Static Function RFIS006Trab()

Local  _aStrucRat := {}
   
   _aStrucRel := {}
   Aadd(_aStrucRel,{"FT_FILIAL" ,TamSX3("FT_FILIAL")[3],TamSX3("FT_FILIAL")[1],TamSX3("FT_FILIAL")[2]})  // CODIGO
   Aadd(_aStrucRel,{"ST_NOME"   ,"C",60,0})	// RAZAO SOCIAL
   Aadd(_aStrucRel,{"ST_CGC"    ,"C",14,0}) // CNPJ	
   Aadd(_aStrucRel,{"ST_INSC"   ,"C",12,0}) // IE
   Aadd(_aStrucRel,{"ST_INSCM"  ,"C",15,0}) // IM	
   Aadd(_aStrucRel,{"ST_CIDCOB" ,"C",50,0}) // CIDADE	
   Aadd(_aStrucRel,{"ST__ESTCOB","C",2,0})  // UF	
   Aadd(_aStrucRel,{"FT_EMISSAO",TamSX3("FT_EMISSAO")[3],TamSX3("FT_EMISSAO")[1],TamSX3("FT_EMISSAO")[2]}) // DATA EMISSÃO	 
   Aadd(_aStrucRel,{"FT_ENTRADA",TamSX3("FT_ENTRADA")[3],TamSX3("FT_ENTRADA")[1],TamSX3("FT_ENTRADA")[2]}) // DATA ENT/SAI	
   Aadd(_aStrucRel,{"FT_NFISCAL",TamSX3("FT_NFISCAL")[3],TamSX3("FT_NFISCAL")[1],TamSX3("FT_NFISCAL")[2]}) // NÚMERO	
   Aadd(_aStrucRel,{"FT_SERIE"  ,TamSX3("FT_SERIE")[3]  ,TamSX3("FT_SERIE")[1]  ,TamSX3("FT_SERIE")[2]})   // SÉRIE	
   Aadd(_aStrucRel,{"FT_ESPECIE",TamSX3("FT_ESPECIE")[3],TamSX3("FT_ESPECIE")[1],TamSX3("FT_ESPECIE")[2]}) // MODELO	
   Aadd(_aStrucRel,{"FT_CHVNFE" ,TamSX3("FT_CHVNFE")[3] ,TamSX3("FT_CHVNFE")[1] ,TamSX3("FT_CHVNFE")[2]})  // CHAVE DE ACESSO	
   Aadd(_aStrucRel,{"F3_CODRSEF",TamSX3("F3_CODRSEF")[3],TamSX3("F3_CODRSEF")[1],TamSX3("F3_CODRSEF")[2]}) // SITUAÇÃO	
   Aadd(_aStrucRel,{"FT_TIPOMOV",TamSX3("FT_TIPOMOV")[3],TamSX3("FT_TIPOMOV")[1],TamSX3("FT_TIPOMOV")[2]}) // TIPO MOV	
   Aadd(_aStrucRel,{"FT_TIPO"   ,"C"                    ,20                     ,0                      }) // TIPO LANC	
   Aadd(_aStrucRel,{"D1_TES"    ,TamSX3("D1_TES")[3]    ,TamSX3("D1_TES")[1]    ,TamSX3("D1_TES")[2]})     // COD. TES	
   Aadd(_aStrucRel,{"F4_FINALID",TamSX3("F4_FINALID")[3],TamSX3("F4_FINALID")[1],TamSX3("F4_FINALID")[2]}) // DESCRIÇÃO TES	
   Aadd(_aStrucRel,{"FT_CFOP"   ,TamSX3("FT_CFOP")[3]   ,TamSX3("FT_CFOP")[1]   ,TamSX3("FT_CFOP")[2]})    // 	CFOP	

   Aadd(_aStrucRel,{"ED_CODIGO"   ,TamSX3("ED_CODIGO")[3]   ,TamSX3("ED_CODIGO")[1]   ,TamSX3("ED_CODIGO")[2]})    // 	NATUREZA DE OPERAÇÃO
   Aadd(_aStrucRel,{"ED_DESCRIC"   ,TamSX3("ED_DESCRIC")[3]   ,TamSX3("ED_DESCRIC")[1]   ,TamSX3("ED_DESCRIC")[2]})    // 	DESCRIÇÃO NATUREZA

   Aadd(_aStrucRel,{"FT_NFORI"  ,TamSX3("FT_NFORI")[3]  ,TamSX3("FT_NFORI")[1]  ,TamSX3("FT_NFORI")[2]})   // 	NÚMERO NOTA ORIGEM	
   Aadd(_aStrucRel,{"FT_SERORI" ,TamSX3("FT_SERORI")[3] ,TamSX3("FT_SERORI")[1] ,TamSX3("FT_SERORI")[2]})  // 	SÉRIE NOTA DE ORIGEM	
   Aadd(_aStrucRel,{"CCUSTO"    ,TamSX3("D1_CC")[3]     ,TamSX3("D1_CC")[1]     ,TamSX3("D1_CC")[2]})      // COD. CENTRO DE CUSTO	
   Aadd(_aStrucRel,{"CTT_DESC01",TamSX3("CTT_DESC01")[3],TamSX3("CTT_DESC01")[1],TamSX3("CTT_DESC01")[2]}) //  DESCRIÇÃO DO CENTRO DE CUSTO	
   Aadd(_aStrucRel,{"FT_CLIEFOR",TamSX3("FT_CLIEFOR")[3],TamSX3("FT_CLIEFOR")[1],TamSX3("FT_CLIEFOR")[2]}) // 	COD. CLIENTE/FORN	
   Aadd(_aStrucRel,{"FT_LOJA"   ,TamSX3("FT_LOJA")[3]   ,TamSX3("FT_LOJA")[1]   ,TamSX3("FT_LOJA")[2]})    //  LOJA CLIENTE/FORN	
   Aadd(_aStrucRel,{"NOME"      ,TamSX3("A1_NOME")[3]   ,TamSX3("A1_NOME")[1]   ,TamSX3("A1_NOME")[2]})    // 	RAZAO SOCIAL CLIENTE/FORN	
   Aadd(_aStrucRel,{"CNPJ"      ,TamSX3("A1_CGC")[3]    ,TamSX3("A1_CGC")[1]    ,TamSX3("A1_CGC")[2]})     // 	CNPJ OU CPF CLIENTE/FORN	
   Aadd(_aStrucRel,{"INSCREST"  ,TamSX3("A1_INSCR")[3]  ,TamSX3("A1_INSCR")[1]  ,TamSX3("A1_INSCR")[2]})   // IE CLIENTE/FORN	
   Aadd(_aStrucRel,{"NUNICIPIO" ,TamSX3("A1_MUN")[3]    ,TamSX3("A1_MUN")[1]    ,TamSX3("A1_MUN")[2]})     // CIDADE 	
   Aadd(_aStrucRel,{"ESTADO"    ,TamSX3("A1_EST")[3]    ,TamSX3("A1_EST")[1]    ,TamSX3("A1_EST")[2]})     // UF	
   
   Aadd(_aStrucRel,{"A2CALCIRF","C"    ,20    ,0})    // Calcula IRRF	
   Aadd(_aStrucRel,{"A1SIMPNAC","C"    ,3   ,0})     // Optante do Simples Nacional
 
   Aadd(_aStrucRel,{"ARMAZEM"   ,TamSX3("D1_LOCAL")[3]  ,TamSX3("D1_LOCAL")[1]  ,TamSX3("D1_LOCAL")[2]})   // ARMAZÉM/DEPÓSITO	
   Aadd(_aStrucRel,{"B1_GRUPO"  ,TamSX3("B1_GRUPO")[3]  ,TamSX3("B1_GRUPO")[1]  ,TamSX3("B1_GRUPO")[2]})   // COD GRUPO DE PRODUTO	
   Aadd(_aStrucRel,{"BM_DESC"   ,TamSX3("BM_DESC")[3]   ,TamSX3("BM_DESC")[1]   ,TamSX3("BM_DESC")[2]})    // DESCRICAO GRUPO PRODUTO	
   Aadd(_aStrucRel,{"FT_PRODUTO",TamSX3("FT_PRODUTO")[3],TamSX3("FT_PRODUTO")[1],TamSX3("FT_PRODUTO")[2]}) // COD. PRODUTO	
   Aadd(_aStrucRel,{"B1_DESC"   ,TamSX3("B1_DESC")[3]   ,TamSX3("B1_DESC")[1]   ,TamSX3("B1_DESC")[2]})    // DESCRICAO PRODUTO	
   Aadd(_aStrucRel,{"FT_POSIPI" ,TamSX3("FT_POSIPI")[3] ,TamSX3("FT_POSIPI")[1] ,TamSX3("FT_POSIPI")[2]})  // NCM	
   Aadd(_aStrucRel,{"UNIMEDIDA" ,TamSX3("D1_UM")[3]     ,TamSX3("D1_UM")[1]     ,TamSX3("D1_UM")[2]})      // UNIDADE DE MEDIDA	
   Aadd(_aStrucRel,{"FT_QUANT"  ,TamSX3("FT_QUANT")[3]  ,TamSX3("FT_QUANT")[1]  ,TamSX3("FT_QUANT")[2]})   // QUANTIDADE	
   Aadd(_aStrucRel,{"FT_PRCUNIT",TamSX3("FT_PRCUNIT")[3],TamSX3("FT_PRCUNIT")[1],TamSX3("FT_PRCUNIT")[2]}) // VL UNITARIO	
   Aadd(_aStrucRel,{"FT_DESCONT",TamSX3("FT_DESCONT")[3],TamSX3("FT_DESCONT")[1],TamSX3("FT_DESCONT")[2]}) // VL DESCONTO	
   Aadd(_aStrucRel,{"FT_DESPESA",TamSX3("FT_DESPESA")[3],TamSX3("FT_DESPESA")[1],TamSX3("FT_DESPESA")[2]}) // DESPESAS	
   Aadd(_aStrucRel,{"FT_FRETE"  ,TamSX3("FT_FRETE")[3]  ,TamSX3("FT_FRETE")[1]  ,TamSX3("FT_FRETE")[2]})   // FRETE	
   Aadd(_aStrucRel,{"FT_SEGURO" ,TamSX3("FT_SEGURO")[3] ,TamSX3("FT_SEGURO")[1] ,TamSX3("FT_SEGURO")[2]})  // SEGURO	
   Aadd(_aStrucRel,{"FT_TOTAL"  ,TamSX3("FT_TOTAL")[3]  ,TamSX3("FT_TOTAL")[1]  ,TamSX3("FT_TOTAL")[2]})   // VL TOTAL ITEM	
   Aadd(_aStrucRel,{"FT_VALCONT",TamSX3("FT_VALCONT")[3],TamSX3("FT_VALCONT")[1],TamSX3("FT_VALCONT")[2]}) // VL TOTAL NF	
   Aadd(_aStrucRel,{"FT_CLASFIS",TamSX3("FT_CLASFIS")[3],TamSX3("FT_CLASFIS")[1],TamSX3("FT_CLASFIS")[2]}) // CST ICMS	
   Aadd(_aStrucRel,{"FT_BASEICM",TamSX3("FT_BASEICM")[3],TamSX3("FT_BASEICM")[1],TamSX3("FT_BASEICM")[2]}) // BC ICMS	
   Aadd(_aStrucRel,{"FT_ALIQICM",TamSX3("FT_ALIQICM")[3],TamSX3("FT_ALIQICM")[1],TamSX3("FT_ALIQICM")[2]}) // ALQ ICMS	
   Aadd(_aStrucRel,{"FT_VALICM" ,TamSX3("FT_VALICM")[3] ,TamSX3("FT_VALICM")[1] ,TamSX3("FT_VALICM")[2]})  // VL ICMS
   Aadd(_aStrucRel,{"FT_VALANTI",TamSX3("FT_VALANTI")[3],TamSX3("FT_VALANTI")[1],TamSX3("FT_VALANTI")[2]}) // ICMS ANTECIPADO  
   Aadd(_aStrucRel,{"FT_BASERET",TamSX3("FT_BASERET")[3],TamSX3("FT_BASERET")[1],TamSX3("FT_BASERET")[2]}) // BC ICMS ST	
   Aadd(_aStrucRel,{"FT_ALIQSOL",TamSX3("FT_ALIQSOL")[3],TamSX3("FT_ALIQSOL")[1],TamSX3("FT_ALIQSOL")[2]}) // ALQ ST	
   Aadd(_aStrucRel,{"FT_MARGEM" ,TamSX3("FT_MARGEM")[3] ,TamSX3("FT_MARGEM")[1] ,TamSX3("FT_MARGEM")[2]})  // MVA ST	   
   Aadd(_aStrucRel,{"FT_ICMSRET",TamSX3("FT_ICMSRET")[3],TamSX3("FT_ICMSRET")[1],TamSX3("FT_ICMSRET")[2]}) // VL ICMS ST	
   Aadd(_aStrucRel,{"FT_BASEDES",TamSX3("FT_BASEDES")[3],TamSX3("FT_BASEDES")[1],TamSX3("FT_BASEDES")[2]}) // BASE DIFAL	
   Aadd(_aStrucRel,{"FT_ICMSCOM",TamSX3("FT_ICMSCOM")[3],TamSX3("FT_ICMSCOM")[1],TamSX3("FT_ICMSCOM")[2]}) // VL ICMS DIFAL	
   Aadd(_aStrucRel,{"FT_CTIPI"  ,TamSX3("FT_CTIPI")[3]  ,TamSX3("FT_CTIPI")[1]  ,TamSX3("FT_CTIPI")[2]})   // CST IPI	
   Aadd(_aStrucRel,{"FT_BASEIPI",TamSX3("FT_BASEIPI")[3],TamSX3("FT_BASEIPI")[1],TamSX3("FT_BASEIPI")[2]}) // BC IPI	
   Aadd(_aStrucRel,{"FT_ALIQIPI",TamSX3("FT_ALIQIPI")[3],TamSX3("FT_ALIQIPI")[1],TamSX3("FT_ALIQIPI")[2]}) // ALQ IPI	
   Aadd(_aStrucRel,{"FT_VALIPI" ,TamSX3("FT_VALIPI")[3] ,TamSX3("FT_VALIPI")[1] ,TamSX3("FT_VALIPI")[2]})  // VL IPI	
   Aadd(_aStrucRel,{"FT_CSTPIS" ,TamSX3("FT_CSTPIS")[3] ,TamSX3("FT_CSTPIS")[1] ,TamSX3("FT_CSTPIS")[2]})  // CST PIS	
   Aadd(_aStrucRel,{"FT_BASEPIS",TamSX3("FT_BASEPIS")[3],TamSX3("FT_BASEPIS")[1],TamSX3("FT_BASEPIS")[2]}) // BC PIS	
   Aadd(_aStrucRel,{"FT_ALIQPIS",TamSX3("FT_ALIQPIS")[3],TamSX3("FT_ALIQPIS")[1],TamSX3("FT_ALIQPIS")[2]}) // ALQ PIS	
   Aadd(_aStrucRel,{"FT_VALPIS" ,TamSX3("FT_VALPIS")[3] ,TamSX3("FT_VALPIS")[1] ,TamSX3("FT_VALPIS")[2]})  // VL PIS	
   Aadd(_aStrucRel,{"FT_CSTCOF" ,TamSX3("FT_CSTCOF")[3] ,TamSX3("FT_CSTCOF")[1] ,TamSX3("FT_CSTCOF")[2]})  // CST COFINS	
   Aadd(_aStrucRel,{"FT_BASECOF",TamSX3("FT_BASECOF")[3],TamSX3("FT_BASECOF")[1],TamSX3("FT_BASECOF")[2]}) // BC COFINS	
   Aadd(_aStrucRel,{"FT_ALIQCOF",TamSX3("FT_ALIQCOF")[3],TamSX3("FT_ALIQCOF")[1],TamSX3("FT_ALIQCOF")[2]}) // ALQ COFINS	
   Aadd(_aStrucRel,{"FT_VALCOF" ,TamSX3("FT_VALCOF")[3] ,TamSX3("FT_VALCOF")[1] ,TamSX3("FT_VALCOF")[2]})  // VL COFINS	
   Aadd(_aStrucRel,{"FT_VALIRR" ,TamSX3("FT_VALIRR")[3] ,TamSX3("FT_VALIRR")[1] ,TamSX3("FT_VALIRR")[2]})  // VL IRRF	
   Aadd(_aStrucRel,{"FT_VALINS" ,TamSX3("FT_VALINS")[3] ,TamSX3("FT_VALINS")[1] ,TamSX3("FT_VALINS")[2]})  // VL INSS	
   Aadd(_aStrucRel,{"FT_VRETCSL",TamSX3("FT_VRETCSL")[3],TamSX3("FT_VRETCSL")[1],TamSX3("FT_VRETCSL")[2]}) // VL CSSL RET	
   Aadd(_aStrucRel,{"FT_VRETPIS",TamSX3("FT_VRETPIS")[3],TamSX3("FT_VRETPIS")[1],TamSX3("FT_VRETPIS")[2]}) // VL PIS RET	
   Aadd(_aStrucRel,{"FT_VRETCOF",TamSX3("FT_VRETCOF")[3],TamSX3("FT_VRETCOF")[1],TamSX3("FT_VRETCOF")[2]}) // VL COFINS RET	
//---------------------------------------------------------------------------------------------------------------
   Aadd(_aStrucRel,{"D1_BASEISS",TamSX3("D1_BASEISS")[3],TamSX3("D1_BASEISS")[1],TamSX3("D1_BASEISS")[2]}) // Base ISS RET	
   Aadd(_aStrucRel,{"D1_ALIQISS",TamSX3("D1_ALIQISS")[3],TamSX3("D1_ALIQISS")[1],TamSX3("D1_ALIQISS")[2]}) // Aliquota ISS RET	
//---------------------------------------------------------------------------------------------------------------
   Aadd(_aStrucRel,{"D1_VALISS" ,TamSX3("D1_VALISS")[3] ,TamSX3("D1_VALISS")[1] ,TamSX3("D1_VALISS")[2]})  // VL ISS RET	
   Aadd(_aStrucRel,{"FT_VALFUM" ,TamSX3("FT_VALFUM")[3] ,TamSX3("FT_VALFUM")[1] ,TamSX3("FT_VALFUM")[2]})  // VL FUNRURAL RET	
   Aadd(_aStrucRel,{"FT_VLSENAR",TamSX3("FT_VLSENAR")[3],TamSX3("FT_VLSENAR")[1],TamSX3("FT_VLSENAR")[2]}) // VL SENAR RET	
   Aadd(_aStrucRel,{"FT_VALFUND",TamSX3("FT_VALFUND")[3],TamSX3("FT_VALFUND")[1],TamSX3("FT_VALFUND")[2]}) // VL FUNDESA RET	
   Aadd(_aStrucRel,{"F2_I_CTRA" ,TamSX3("F2_I_CTRA")[3] ,TamSX3("F2_I_CTRA")[1] ,TamSX3("F2_I_CTRA")[2]})  // COD TRANSPORTADOR	
   Aadd(_aStrucRel,{"F2_I_LTRA" ,TamSX3("F2_I_LTRA")[3] ,TamSX3("F2_I_LTRA")[1] ,TamSX3("F2_I_LTRA")[2]})  // LOJA TRANSPORTADOR	
   Aadd(_aStrucRel,{"A2_NOME"   ,TamSX3("A2_NOME")[3]   ,TamSX3("A2_NOME")[1]   ,TamSX3("A2_NOME")[2]})    // RAZAO SOCIAL TRANSPORTADOR	
   Aadd(_aStrucRel,{"A2_MUN"    ,TamSX3("A2_MUN")[3]    ,TamSX3("A2_MUN")[1]    ,TamSX3("A2_MUN")[2]})     // CIDADE	
   Aadd(_aStrucRel,{"A2_EST"    ,TamSX3("A2_EST")[3]    ,TamSX3("A2_EST")[1]    ,TamSX3("A2_EST")[2]})     // UF TRANSP	
   Aadd(_aStrucRel,{"F2_I_PLACA",TamSX3("F2_I_PLACA")[3],TamSX3("F2_I_PLACA")[1],TamSX3("F2_I_PLACA")[2]}) // PLACA	 			 	 		 		 	 	 	 	 	 	 	 	 	 	 			 		 	 		  		
   Aadd(_aStrucRel,{"F2_I_FRET" ,TamSX3("F2_I_FRET")[3] ,TamSX3("F2_I_FRET")[1] ,TamSX3("F2_I_FRET")[2]}) // VL FRETE	
   Aadd(_aStrucRel,{"F2_TPFRETE",TamSX3("F2_TPFRETE")[3],TamSX3("F2_TPFRETE")[1],TamSX3("F2_TPFRETE")[2]}) // TIPO FRETE	
   Aadd(_aStrucRel,{"F4_DUPLIC" ,TamSX3("F4_DUPLIC")[3] ,TamSX3("F4_DUPLIC")[1] ,TamSX3("F4_DUPLIC")[2]})  // FINANCEIRO	
   Aadd(_aStrucRel,{"F4_ESTOQUE",TamSX3("F4_ESTOQUE")[3],TamSX3("F4_ESTOQUE")[1],TamSX3("F4_ESTOQUE")[2]}) // ESTOQUE 	 		
      
   //================================================================================
   // Cria as estruturas das tabelas temporárias
   //================================================================================
   If Select("TRBREL") > 0
      TRBREL->( DBCloseArea() )
   EndIf
    
   _otemp := FWTemporaryTable():New( "TRBREL", _aStrucRel )

   _otemp:AddIndex( "01", {"FT_TIPOMOV","FT_ENTRADA","FT_NFISCAL","FT_SERIE","FT_LOJA"} )
 
   _otemp:Create()
     
   //================================================================================
   // Cria tabela temporária utilizada no rateio de frete.
   //================================================================================   
   _aStrucRat := {}                                
   Aadd(_aStrucRat,{"FT_FILIAL" ,TamSX3("FT_FILIAL")[3],TamSX3("FT_FILIAL")[1],TamSX3("FT_FILIAL")[2]})    // Código da Filial     
   Aadd(_aStrucRat,{"FT_CLIEFOR",TamSX3("FT_CLIEFOR")[3],TamSX3("FT_CLIEFOR")[1],TamSX3("FT_CLIEFOR")[2]}) // COD. CLIENTE/FORN	
   Aadd(_aStrucRat,{"FT_LOJA"   ,TamSX3("FT_LOJA")[3]   ,TamSX3("FT_LOJA")[1]   ,TamSX3("FT_LOJA")[2]})    // LOJA CLIENTE/FORN	
   Aadd(_aStrucRat,{"FT_NFISCAL",TamSX3("FT_NFISCAL")[3],TamSX3("FT_NFISCAL")[1],TamSX3("FT_NFISCAL")[2]}) // NÚMERO	    
   Aadd(_aStrucRat,{"FT_SERIE"  ,TamSX3("FT_SERIE")[3]  ,TamSX3("FT_SERIE")[1]  ,TamSX3("FT_SERIE")[2]})   // SÉRIE	
   Aadd(_aStrucRat,{"QTDITENS"  ,"N"                    ,5                      , 0})   // Quantidade de itens na Nota	
 
   If Select("TRBRAT") > 0
      TRBRAT->( DBCloseArea() )
   EndIf
    
   _otemp := FWTemporaryTable():New( "TRBRAT", _aStrucRat )

   _otemp:AddIndex( "01", {"FT_FILIAL","FT_NFISCAL","FT_SERIE","FT_CLIEFOR","FT_LOJA"} )
 
   _otemp:Create()
                                           
   //================================================================================
   // Montando Cabeçalho do Relatório
   //================================================================================         
   _aCabecalho:={}
   //                Titulo das Colunas             ,Alinhamento ,Formatação, Totaliza?
   Aadd(_aCabecalho,{"CODIGO"                       ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"RAZAO SOCIAL"                 ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"CNPJ	"                       ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"IE"                           ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"IM	"                       ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"CIDADE	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"UF	"                       ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"DATA EMISSÃO	 "              ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"DATA ENT/SAI	"               ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"NÚMERO	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"SÉRIE	"                       ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"MODELO	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"CHAVE DE ACESSO	"           ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"SITUAÇÃO	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"TIPO	"                       ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"TIPO	LANC"                     ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"COD. TES	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"DESCRIÇÃO TES	"               ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"CFOP	"                       ,1           ,1         ,.F.})

   Aadd(_aCabecalho,{"NATUREZA DE OPERAÇÃO"        ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"DESCRIÇÃO NATUREZA"          ,1           ,1         ,.F.})

   Aadd(_aCabecalho,{"NÚMERO NOTA ORIGEM	"       ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"SÉRIE NOTA DE ORIGEM	"       ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"COD. CENTRO DE CUSTO	"       ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"DESCRIÇÃO DO CENTRO DE CUSTO" ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"COD. CLIENTE/FORN	"           ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"LOJA CLIENTE/FORN	"           ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"RAZAO SOCIAL CLIENTE/FORN	"   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"CNPJ OU CPF CLIENTE/FORN	"   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"IE CLIENTE/FORN	"            ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"CIDADE 	"                     ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"UF	"                        ,1           ,1         ,.F.})

   Aadd(_aCabecalho,{"CÁLCULO IRRF"                 ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"OPT.SIMPLES NACIONAL"         ,1           ,1         ,.F.})

   Aadd(_aCabecalho,{"ARMAZÉM/DEPÓSITO	"           ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"COD GRUPO DE PRODUTO	"       ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"DESCRICAO GRUPO PRODUTO	"   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"COD. PRODUTO	"               ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"DESCRICAO PRODUTO	"           ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"NCM	"                       ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"UNIDADE DE MEDIDA	"           ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"QUANTIDADE	"               ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"VL UNITARIO	"               ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"VL DESCONTO	"               ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"DESPESAS	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"FRETE	"                       ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"SEGURO	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"VL TOTAL ITEM	"               ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"VL TOTAL NF	"               ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"CST ICMS	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"BC ICMS	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"ALQ ICMS	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"VL ICMS	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"ICMS ANTECIPADO"              ,1           ,1         ,.F.})  
   Aadd(_aCabecalho,{"BC ICMS ST	"               ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"ALQ ST	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"MVA ST	   "                ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"VL ICMS ST	"               ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"BASE DIFAL	"               ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"VL ICMS DIFAL	"               ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"CST IPI	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"BC IPI	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"ALQ IPI	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"VL IPI	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"CST PIS	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"BC PIS	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"ALQ PIS	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"VL PIS	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"CST COFINS	"                ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"BC COFINS	"                ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"ALQ COFINS	"                ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"VL COFINS	"                ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"VL IRRF	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"VL INSS	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"VL CSSL RET	"             ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"VL PIS RET	"                ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"VL COFINS RET	"             ,1           ,1         ,.F.})
//-------------------------------------------------------------------------------------
   Aadd(_aCabecalho,{"BASE ISS RET	"             ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"ALQ ISS RET	"             ,1           ,1         ,.F.})
//-------------------------------------------------------------------------------------
   Aadd(_aCabecalho,{"VL ISS RET	"                ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"VL FUNRURAL RET	"          ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"VL SENAR RET	"             ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"VL FUNDESA RET	"          ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"COD TRANSPORTADOR	"       ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"LOJA TRANSPORTADOR	"       ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"RAZAO SOCIAL TRANSPORTADOR" ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"CIDADE	"                   ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"UF TRANSP	"                ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"PLACA"                      ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"VL FRETE	"                ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"TIPO FRETE	"                ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"FINANCEIRO	"                ,1           ,1         ,.F.})
   Aadd(_aCabecalho,{"ESTOQUE 	 		"          ,1           ,1         ,.F.})
   
   //======================================================================================================================
   // Array com os campos para leitura de dados e montagem dos dados do relatório.
   //======================================================================================================================
   _aCampos   :={}
   Aadd(_aCampos,"FT_FILIAL")    // CODIGO
   Aadd(_aCampos,"ST_NOME") 	 // RAZAO SOCIAL
   Aadd(_aCampos,"ST_CGC")       // CNPJ	
   Aadd(_aCampos,"ST_INSC")      // IE
   Aadd(_aCampos,"ST_INSCM")     // IM	
   Aadd(_aCampos,"ST_CIDCOB")    // CIDADE	
   Aadd(_aCampos,"ST__ESTCOB")   // UF	
   Aadd(_aCampos,"FT_EMISSAO")   // DATA EMISSÃO	 
   Aadd(_aCampos,"FT_ENTRADA")   // DATA ENT/SAI	
   Aadd(_aCampos,"FT_NFISCAL")   // NÚMERO	
   Aadd(_aCampos,"FT_SERIE")     // SÉRIE	
   Aadd(_aCampos,"FT_ESPECIE")   // MODELO	
   Aadd(_aCampos,"FT_CHVNFE")    // CHAVE DE ACESSO	
   Aadd(_aCampos,"F3_CODRSEF")   // SITUAÇÃO	
   Aadd(_aCampos,"FT_TIPOMOV")   // TIPO MOV
   Aadd(_aCampos,"FT_TIPO "  )   // TIPO LANC
   Aadd(_aCampos,"D1_TES")       // COD. TES	
   Aadd(_aCampos,"F4_FINALID")   // DESCRIÇÃO TES	
   Aadd(_aCampos,"FT_CFOP")      // CFOP	

   Aadd(_aCampos,"ED_CODIGO")    // NATUREZA DE OPERAÇÃO	
   Aadd(_aCampos,"ED_DESCRIC")   // DESCRIÇÃO NATUREZA

   Aadd(_aCampos,"FT_NFORI")     // NÚMERO NOTA ORIGEM	
   Aadd(_aCampos,"FT_SERORI")    // SÉRIE NOTA DE ORIGEM	
   Aadd(_aCampos,"CCUSTO")       // COD. CENTRO DE CUSTO	
   Aadd(_aCampos,"CTT_DESC01")   // DESCRIÇÃO DO CENTRO DE CUSTO	
   Aadd(_aCampos,"FT_CLIEFOR")   // COD. CLIENTE/FORN	
   Aadd(_aCampos,"FT_LOJA")      // LOJA CLIENTE/FORN	
   Aadd(_aCampos,"NOME")         // RAZAO SOCIAL CLIENTE/FORN	
   Aadd(_aCampos,"CNPJ")         // CNPJ OU CPF CLIENTE/FORN	
   Aadd(_aCampos,"INSCREST")     // IE CLIENTE/FORN	
   Aadd(_aCampos,"NUNICIPIO")    // CIDADE 	
   Aadd(_aCampos,"ESTADO")       // UF	

   Aadd(_aCampos,"A2CALCIRF")   // CÁLCULO IRRF
   Aadd(_aCampos,"A1SIMPNAC")   // OPT.SIMPLES NACIONAL

   Aadd(_aCampos,"ARMAZEM")      // ARMAZÉM/DEPÓSITO	
   Aadd(_aCampos,"B1_GRUPO")     // COD GRUPO DE PRODUTO	
   Aadd(_aCampos,"BM_DESC")      // DESCRICAO GRUPO PRODUTO	
   Aadd(_aCampos,"FT_PRODUTO")   // COD. PRODUTO	
   Aadd(_aCampos,"B1_DESC")      // DESCRICAO PRODUTO	
   Aadd(_aCampos,"FT_POSIPI")    // NCM	
   Aadd(_aCampos,"UNIMEDIDA")    // UNIDADE DE MEDIDA	
   Aadd(_aCampos,"FT_QUANT")     // QUANTIDADE	
   Aadd(_aCampos,"FT_PRCUNIT")   // VL UNITARIO	
   Aadd(_aCampos,"FT_DESCONT")   // VL DESCONTO	
   Aadd(_aCampos,"FT_DESPESA")   // DESPESAS	
   Aadd(_aCampos,"FT_FRETE")     // FRETE	
   Aadd(_aCampos,"FT_SEGURO")    // SEGURO	
   Aadd(_aCampos,"FT_TOTAL")     // VL TOTAL ITEM	
   Aadd(_aCampos,"FT_VALCONT")   // VL TOTAL NF	
   Aadd(_aCampos,"FT_CLASFIS")   // CST ICMS	
   Aadd(_aCampos,"FT_BASEICM")   // BC ICMS	
   Aadd(_aCampos,"FT_ALIQICM")   // ALQ ICMS	
   Aadd(_aCampos,"FT_VALICM")    // VL ICMS	
   Aadd(_aCampos,"FT_VALANTI")   // ICMS ANTECIPADO  
   Aadd(_aCampos,"FT_BASERET")   // BC ICMS ST	
   Aadd(_aCampos,"FT_ALIQSOL")   // ALQ ST	
   Aadd(_aCampos,"FT_MARGEM")    // MVA ST	   
   Aadd(_aCampos,"FT_ICMSRET")   // VL ICMS ST	
   Aadd(_aCampos,"FT_BASEDES")   // BASE DIFAL	
   Aadd(_aCampos,"FT_ICMSCOM")   // VL ICMS DIFAL	
   Aadd(_aCampos,"FT_CTIPI")     // CST IPI	
   Aadd(_aCampos,"FT_BASEIPI")   // BC IPI	
   Aadd(_aCampos,"FT_ALIQIPI")   // ALQ IPI	
   Aadd(_aCampos,"FT_VALIPI")    // VL IPI	
   Aadd(_aCampos,"FT_CSTPIS")    // CST PIS	
   Aadd(_aCampos,"FT_BASEPIS")   // BC PIS	
   Aadd(_aCampos,"FT_ALIQPIS")   // ALQ PIS	
   Aadd(_aCampos,"FT_VALPIS")    // VL PIS	
   Aadd(_aCampos,"FT_CSTCOF")    // CST COFINS	
   Aadd(_aCampos,"FT_BASECOF")   // BC COFINS	
   Aadd(_aCampos,"FT_ALIQCOF")   // ALQ COFINS	
   Aadd(_aCampos,"FT_VALCOF")    // VL COFINS	
   Aadd(_aCampos,"FT_VALIRR")    // VL IRRF	
   Aadd(_aCampos,"FT_VALINS")    // VL INSS	
   Aadd(_aCampos,"FT_VRETCSL")   // VL CSSL RET	
   Aadd(_aCampos,"FT_VRETPIS")   // VL PIS RET	
   Aadd(_aCampos,"FT_VRETCOF")   // VL COFINS RET
//--------------------------------------------------------------   
   Aadd(_aCampos,"D1_BASEISS")   // BASE ISS RET
   Aadd(_aCampos,"D1_ALIQISS")   // ALQ ISS RET	
//--------------------------------------------------------------   
   Aadd(_aCampos,"D1_VALISS")    // VL ISS RET	
   Aadd(_aCampos,"FT_VALFUM")    // VL FUNRURAL RET	
   Aadd(_aCampos,"FT_VLSENAR")   // VL SENAR RET	
   Aadd(_aCampos,"FT_VALFUND")   // VL FUNDESA RET	
   Aadd(_aCampos,"F2_I_CTRA")    // COD TRANSPORTADOR	
   Aadd(_aCampos,"F2_I_LTRA")    // LOJA TRANSPORTADOR	
   Aadd(_aCampos,"A2_NOME")      // RAZAO SOCIAL TRANSPORTADOR	
   Aadd(_aCampos,"A2_MUN")       // CIDADE	
   Aadd(_aCampos,"A2_EST")       // UF TRANSP	
   Aadd(_aCampos,"F2_I_PLACA")   // PLACA	 			 	 		 		 	 	 	 	 	 	 	 	 	 	 			 		 	 		  		
   Aadd(_aCampos,"F2_I_FRET")    // VL FRETE	
   Aadd(_aCampos,"F2_TPFRETE")   // TIPO FRETE	
   Aadd(_aCampos,"F4_DUPLIC")    // FINANCEIRO	
   Aadd(_aCampos,"F4_ESTOQUE")   // ESTOQUE 	 	

   _aCabList := {"CODIGO"                        ,;
                 "RAZAO SOCIAL"                  ,;
                 "CNPJ	"                        ,;
                 "IE"                            ,;
                 "IM	"                           ,;
                 "CIDADE	"                     ,;
                 "UF	"                           ,;
                 "DATA EMISSÃO	 "              ,;  
                 "DATA ENT/SAI	"               ,;  
                 "NÚMERO	"                     ,;  
                 "SÉRIE	"                        ,;  
                 "MODELO	"                     ,;  
                 "CHAVE DE ACESSO	"            ,;  
                 "SITUAÇÃO	"                     ,;  
                 "TIPO	"                        ,;  
                 "TIPO	LANC"                    ,;  
                 "COD. TES	"                     ,;  
                 "DESCRIÇÃO TES	"               ,;  
                 "CFOP	"                        ,;  
                 "NATUREZA DE OPERAÇÃO	"         ,; 
                 "DESCRIÇÃO NATUREZA	"         ,; 
                 "NÚMERO NOTA ORIGEM	"         ,;  
                 "SÉRIE NOTA DE ORIGEM	"         ,;
                 "COD. CENTRO DE CUSTO	"         ,;
                 "DESCRIÇÃO DO CENTRO DE CUSTO"  ,;
                 "COD. CLIENTE/FORN	"            ,;
                 "LOJA CLIENTE/FORN	"            ,;
                 "RAZAO SOCIAL CLIENTE/FORN	"   ,;
                 "CNPJ OU CPF CLIENTE/FORN	"   ,;
                 "IE CLIENTE/FORN	"            ,;
                 "CIDADE 	"                     ,;
                 "UF	"                           ,;
                 "CÁLCULO IRRF"                  ,; 
                 "OPT.SIMPLES NACIONAL"          ,; 
                 "ARMAZÉM/DEPÓSITO	"            ,;
                 "COD GRUPO DE PRODUTO	"         ,;
                 "DESCRICAO GRUPO PRODUTO	"      ,;
                 "COD. PRODUTO	"               ,;
                 "DESCRICAO PRODUTO	"            ,;
                 "NCM	"                        ,;
                 "UNIDADE DE MEDIDA	"            ,;
                 "QUANTIDADE	"                  ,;
                 "VL UNITARIO	"                  ,;
                 "VL DESCONTO	"                  ,;
                 "DESPESAS	"                     ,;
                 "FRETE	"                        ,;
                 "SEGURO	"                     ,;
                 "VL TOTAL ITEM	"               ,;
                 "VL TOTAL NF	"                  ,;
                 "CST ICMS	"                     ,;
                 "BC ICMS	"                     ,;
                 "ALQ ICMS	"                     ,;
                 "VL ICMS	"                     ,;
                 "ICMS ANTECIPADO"               ,;     
                 "BC ICMS ST	"                  ,;
                 "ALQ ST	"                     ,;
                 "MVA ST	   "                  ,;
                 "VL ICMS ST	"                  ,;
                 "BASE DIFAL	"                  ,;
                 "VL ICMS DIFAL	"               ,;
                 "CST IPI	"                     ,;
                 "BC IPI	"                     ,;
                 "ALQ IPI	"                     ,;
                 "VL IPI	"                     ,;
                 "CST PIS	"                     ,;
                 "BC PIS	"                     ,;
                 "ALQ PIS	"                     ,;
                 "VL PIS	"                     ,;
                 "CST COFINS	"                  ,;
                 "BC COFINS	"                  ,;
                 "ALQ COFINS	"                  ,;
                 "VL COFINS	"                  ,;
                 "VL IRRF	"                     ,;
                 "VL INSS	"                     ,;
                 "VL CSSL RET	"                  ,;
                 "VL PIS RET	"                  ,;
                 "VL COFINS RET	"               ,;
                 "BASE ISS RET "                 ,;
                 "ALQ ISS RET	"                  ,;
                 "VL ISS RET	"                  ,;
                 "VL FUNRURAL RET	"            ,;
                 "VL SENAR RET	"               ,;
                 "VL FUNDESA RET	"               ,;
                 "COD TRANSPORTADOR	"            ,;
                 "LOJA TRANSPORTADOR	"         ,;
                 "RAZAO SOCIAL TRANSPORTADOR"    ,;
                 "CIDADE	"                     ,;
                 "UF TRANSP	"                  ,;
                 "PLACA"                         ,;
                 "VL FRETE	"                     ,; 
                 "TIPO FRETE	"                  ,;
                 "FINANCEIRO	"                  ,;
                 "ESTOQUE 	 		"}

AADD(_aCabExcel,{	"CODIGO"    	                  ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"RAZAO SOCIAL" 	               ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"CNPJ "    	                     ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"IE"      	                     ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"IM "      	                     ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"CIDADE  "   	                  ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"UF "      	                     ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"DATA EMISSÃO  "                 ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"DATA ENT/SAI  "                 ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"NÚMERO  "    	                  ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"SÉRIE "     	                  ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"MODELO  "    	                  ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"CHAVE DE ACESSO  "              ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"SITUAÇÃO "    	               ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"TIPO "     	                  ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"TIPO LANC"   	                  ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"COD. TES "    	               ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"DESCRIÇÃO TES "                 ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"CFOP "     	                  ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"NATUREZA DE OPERAÇÃO "          ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"DESCRIÇÃO NATUREZA  "           ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"NÚMERO NOTA ORIGEM  "      	   ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"SÉRIE NOTA DE ORIGEM "     	   ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"COD. CENTRO DE CUSTO "     	   ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"DESCRIÇÃO DO CENTRO DE CUSTO" 	,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"COD. CLIENTE/FORN "      	      ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"LOJA CLIENTE/FORN "      	      ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"RAZAO SOCIAL CLIENTE/FORN "  	,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"CNPJ OU CPF CLIENTE/FORN  "  	,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"IE CLIENTE/FORN  "      	      ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"CIDADE  "   	                  ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"UF "                         	,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"CÁLCULO IRRF"  	               ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"OPT.SIMPLES NACIONAL"      	   ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"ARMAZÉM/DEPÓSITO "      	      ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"COD GRUPO DE PRODUTO "     	   ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"DESCRICAO GRUPO PRODUTO "    	,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"COD. PRODUTO  "              	,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"DESCRICAO PRODUTO "           	,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"NCM  "                       	,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"UNIDADE DE MEDIDA "            	,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"QUANTIDADE " 	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"VL UNITARIO " 	               ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"VL DESCONTO "                	,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"DESPESAS "   	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"FRETE "    	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"SEGURO  "   	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"VL TOTAL ITEM "                	,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"VL TOTAL NF " 	               ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"CST ICMS "   	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"BC ICMS "   	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"ALQ ICMS "                   	,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"VL ICMS "   	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"ICMS ANTECIPADO"             	,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"BC ICMS ST " 	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"ALQ ST  "                    	,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"MVA ST   " 	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"VL ICMS ST " 	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"BASE DIFAL " 	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"VL ICMS DIFAL"                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"CST IPI "   	                  ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"BC IPI  "   	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"ALQ IPI "   	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"VL IPI  "   	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"CST PIS "   	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"BC PIS  "   	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"ALQ PIS "   	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"VL PIS  "   	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"CST COFINS " 	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"BC COFINS  " 	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"ALQ COFINS " 	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"VL COFINS  " 	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"VL IRRF "   	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"VL INSS "   	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"VL CSSL RET " 	               ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"VL PIS RET " 	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"VL COFINS RET "        	      ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"BASE ISS RET "         	      ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"ALQ ISS RET " 	               ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"VL ISS RET " 	                  ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"VL FUNRURAL RET  "      	      ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"VL SENAR RET  "        	      ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"VL FUNDESA RET "        	      ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"COD TRANSPORTADOR "      	      ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"LOJA TRANSPORTADOR  "     	   ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"RAZAO SOCIAL TRANSPORTADOR"  	,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"CIDADE  "   	                  ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"UF TRANSP  " 	                  ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"PLACA"     	                  ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"VL FRETE "    	               ,	3	,	2	,	.F.	})
AADD(_aCabExcel,{	"TIPO FRETE " 	                  ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"FINANCEIRO " 	                  ,	1	,	1	,	.F.	})
AADD(_aCabExcel,{	"ESTOQUE    "	                  ,	1	,	1	,	.F.	})

RETURN

STATIC FUNCTION TipoLanc(_cTipoLanc)

IF _cTipoLanc ="P"
   _cTipoLanc:="P-COMPL.IPI + ICMS"
ELSEIF _cTipoLanc ="I"
   _cTipoLanc:="I-COMPL.ICMS"
ELSEIF _cTipoLanc ="B"
   _cTipoLanc:="B-BENEFICIAMENTO"
ELSEIF _cTipoLanc ="C"
   _cTipoLanc:="C-CTE"
ELSEIF _cTipoLanc ="D"
   _cTipoLanc:="D-DEVOLUCAO"
ELSEIF _cTipoLanc ="S"
   _cTipoLanc:="S-NF COM ISS"
ELSEIF _cTipoLanc ="L"
   _cTipoLanc:="L-NF SEM LOTE"
ELSEIF _cTipoLanc =" "
   _cTipoLanc:=" "//NF CANCELADA
ENDIF

RETURN _cTipoLanc
