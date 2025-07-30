/*
===================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===================================================================================================================================
Autor        |   Data   |                              Motivo                      										 
Alex Wallauer| 22/06/17 | Chamado 19351. Alteração para começar a chamar a função GrvMonitor().  
Josué Prestes| 18/10/18 | Chamado 26678. Revisão de código para novos padrões de codificação Totvs.       
Lucas Borges | 14/10/19 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25. 
Julio Paz    | 08/08/20 | Chamado 29634. Reescrever e desenvolver a nova rotina de monitoramento (Gestão de Carteira). 
Julio Paz    | 10/09/20 | Chamado 29634. Incluir rotinas Visualizar PV, Alterar Armazém, Filtro por Legenda e Remover filtro.
Jerry        | 03/11/20 | Chamado 34569. Adicionar Tipo de Agendamento R-Reagendar e N-Reagendar com Multa. 
Julio Paz    | 16/07/21 | Chamado 37166. Criação de rotina simples de manutenção do cadastro de justificativas de alterações. 
Julio Paz    | 24/09/21 | Chamado 37814. Inclusão de novas regras para definir transit time na validação da data de entrega. 
Julio Paz    | 06/07/23 | Chamado 44387. Correções no cálculo da data de entrega na alteração do tipo de agendamento. 
Alex Wallauer| 25/07/23 | Chamado 44529. Adcionar os campos C5_ASSCOD/C5_ASSNOM/ZPG_EMAIL no Browser e no envio do e-mail.
Alex Wallauer| 18/10/23 | Chamado 45295. Ajustar monitor para gerar Log de PV e tb atualizar RDC: U_ENVSITPV(,.F.)=ON LINE.
Alex Wallauer| 30/10/23 | Chamado 44881. Tela de preencher observação e justificativa para alteração de C5_I_AGEND OU C5_I_DTENT.
Alex Wallauer| 08/02/24 | Chamado 44782. Jerry. Ajustes para a nova opcao de tipo de entrega: O = Agendado pelo Op.Log.
Alex Wallauer| 05/03/24 | Chamado 46373. Andre. Criacao do controlo de contagem de alterações para data entrega/tipo agendamento.
Alex Wallauer| 29/07/24 | Chamado 47700. Andre. Incluido o filtro por por código de gerente C5_VEND3.
Lucas Borges | 23/07/25 | Chamado 51340. Ajustar função para validação de ambiente de teste
==============================================================================================================================================================
Analista    - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
Jerry       - Alex Wallauer - 08/10/24 - 23/10/24 - 48154   - Acrescentado contador de Linhas selecionadas e ajustes na validacao da Dt.Ent.PV.
Jerry       - Igor Melgaço  - 25/02/24 - 20/03/25 - 39201   - Ajustes para contabilizar a quantidade de alterações efetuadas no pedido de vendas.
Jerry       - Alex Wallauer - 24/03/24 - 24/03/25 - 39201   - Ajustes para contabilizar a quantidade de alterações efetuadas no pedido de vendas, correçaõ de error.log.
Alex        - Alex Wallauer - 22/04/25 - 18/07/25 - 49966   - CORREÇÃO DE ERROR.LOG: variable does not exist _ODLGJ on {|| NOPC := 2, _ODLGJ:END()}(AOMS097.PRW) 25/03/2025 07:16:16 line : 2495
Jerry       - Julio Paz     - 13/05/25 - 18/07/25 - 49758   - Realização de Ajustes nas Telas de Solicitação de Justificativa para Alteração de Tipo de Agendamento e Data de Entrega do Pedido de Vendas.
Jerry       - Julio Paz     - 29/05/25 - 18/07/25 - 50129   - Ajustar a rotina para listar pedidos de vendas liberados.
===============================================================================================================================================================

*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"
#Include 'totvs.ch'
#Include 'TopConn.ch'
#include "fileio.ch"  

#define	MB_OK				0
#define MB_ICONASTERISK		64
#Define STR_PULA        Chr(13)+ Chr(10)

/*
===============================================================================================================================
Programa----------: AOMS097
Autor-------------: Josué Danich Prestes
Data da Criacao---: 06/04/2017
===============================================================================================================================
Descrição---------: Rotina responsavel pelo Monitor de Pedido de Vendas - Chamado 19351
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS097()
Local _aStruct 
Local _aCmpZY3, _aCmpSC5
Local _lInvSC5 := .F., _lInvZY3 := .F.  
Local _aSizeAut  := MsAdvSize(.T.)
Local _nI
Local _bOk, _bCancel

Private _aCores := {}
Private _bLegend
Private _cPerg := "AOMS097"
Private _nTotRegs := 0
Private _oMarkZY3
Private _cNumPed := Space(6)
Private _oDlgH
Private _dGetEE := Ctod("  /  /  ")
Private _oMarkSC5
Private aHeader := {}, aCols := {}
Private _aHeadZY3 := {}
Private _aCmpZY8 := {}, _aCmpZY8Tela := {}
Private _cMarcaSC5 := GetMark(), _cMarcaZY3 := GetMark()
Private _cSelecLeg := ""
/*
Private aRotina	:=  {{"Pesquisar"                 ,"U_AOMS097Q()"    , 0, 2, 0, nil},;
	                    {"Visualizar"		          ,"U_AOMS097T('V')" , 0, 2, 0, nil},;
						     {"Incluir"			          ,"U_AOMS097T('I')" , 0, 3, 0, nil},;
						     {"Alterar"			          ,"U_AOMS097T('A')" , 0, 4, 0, .F.},;
                       {"Visualiza Pedido Vendas"   ,"U_AOMS097V()"    , 0, 4, 0, .F.},;
						     {"Notas"			             ,"U_A097PLA()"	  , 0, 2, 0, .F.},; 
						     {"Alterar Dt.Ent.PV"	       ,"FWMSGRUN(,{|O|U_A097DTEN(O)})",0,2,0,.F.},;
						     {"Alterar Tipo Agen"	       ,"FWMSGRUN(,{|O|U_AOMS097A(O)})",0,2,0,.F.},;  // ALTEARA ESTA FUNÇÃO
						     {"Inserir Justificativa"	    ,"U_AOMS097J()"    , 0, 2, 0, .F.},;
						     {"Relatorio Por E-Mail"	    ,"U_AOMS097C()"    , 0, 2, 0, .F.},;
                       {"Manutencao Ped.Vendas"     ,"U_AOMS097L()"    , 0, 2, 0, .F.},; 
                       {"Filtra por Legenda"        ,"U_AOMS97FIL()"   , 0, 2, 0, .F.},; 
                       {"Cancela Filtro por Legenda","U_AOMS97Clear()" , 0, 2, 0, .F.},; 
                       {"Legenda"			          ,"U_A097LEG"	     , 0, 2, 0, .F.},;
                       {"Manut.Cad.Justificativa"	 ,"U_AOM97ZY5"	     , 0, 2, 0, .F.}}
*/
Private aRotina	:=  {{"","" , 0, 2, 0, nil},;
	                    {"","" , 0, 2, 0, nil},;
						     {"","" , 0, 3, 0, nil},;
						     {"","" , 0, 4, 0, .F.},;
                       {"","" , 0, 4, 0, .F.},;
						     {"","" , 0, 2, 0, .F.},; 
						     {"","" , 0, 2 ,0, .F.},;
						     {"","" , 0, 2 ,0, .F.},;
						     {"","" , 0, 2, 0, .F.},;
						     {"","" , 0, 2, 0, .F.},;
                       {"","" , 0, 2, 0, .F.},; 
                       {"","" , 0, 2, 0, .F.},; 
                       {"","" , 0, 2, 0, .F.},; 
                       {"","" , 0, 2, 0, .F.},;
                       {"","" , 0, 2, 0, .F.}}
Private _aButtons := {}

Begin Sequence
   M->C5_TABELA := Space(3) 
   M->C5_I_TAB  := Space(3) 
 
   _aCores:={}
   //_bLegend := {|| U_AOMS097R()} //Função que carrega váriavel com cores da legenda
   _bLegend := {|| TRBSC5->WK_LEGENDA}
   AADD(_aCores,{'Eval(_bLegend)=="1"',"BR_VIOLETA"})   // Agendamento maior que o permitido
   AADD(_aCores,{'Eval(_bLegend)=="2"',"BR_AZUL"})      // Aguardando data para Faturamento
   AADD(_aCores,{'Eval(_bLegend)=="3"',"BR_VERDE"})     // Cobrar faturamento
   AADD(_aCores,{'Eval(_bLegend)=="4"',"BR_AMARELO"})   // Faturamento urgente
   AADD(_aCores,{'Eval(_bLegend)=="5"',"BR_VERMELHO"})  // Perdeu agenda
   AADD(_aCores,{'Eval(_bLegend)=="6"',"BR_CINZA"})     // Bloqueado para Faturamento

   //====================================================
   // Define as opções de menu
   //====================================================
   _bAlteraDT:= {|| FWMSGRUN(,{|O| U_A097DTEN(O)          }) }
   _bAlteraTA:= {|| FWMSGRUN(,{|O| U_AOMS097A(O)          }) }
   _bAlteraMD:= {|| FWMSGRUN(,{|O| U_AOMS097M(_cMarcaSC5) }) }
   
   Aadd( _aButtons , {"", {|| U_AOMS097Q()}   , "Pesquisar..."              , "Pesquisar"                 , {|| .T.}})// "Pesquisar" 
   Aadd( _aButtons , {"", {|| U_AOMS097T("V")}, "Visualizar..."             , "Visualizar"                , {|| .T.}})// "Visualizar"
   Aadd( _aButtons , {"", {|| U_AOMS097T("I")}, "Incluir..."                , "Incluir"                   , {|| .T.}})// "Incluir"
   Aadd( _aButtons , {"", {|| U_AOMS097T("A")}, "Alterar..."                , "Alterar"                   , {|| .T.}})// "Alterar"
   Aadd( _aButtons , {"", {|| U_AOMS097V("V")}, "Visualiza Pedido Vendas"   , "Visualiza Pedido Vendas"   , {|| .T.}})// "Visualiza Pedio Vendas"
   Aadd( _aButtons , {"", {|| U_A097PLA()}    , "Notas..."                  , "Notas"                     , {|| .T.}})// "Notas"
   Aadd( _aButtons , {"", _bAlteraDT          ,"Alterar Dt.Ent.PV..."       , "Alterar Dt.Ent.PV"         , {|| .T.}})// "Alt.Dt.Ent.PV"
   Aadd( _aButtons , {"", _bAlteraTA          ,"Alterar Tipo Agen"	       , "Alterar Tipo Agen"         , {|| .T.}})// "Alt.Tipo Agen" 
   Aadd( _aButtons , {"", {|| U_AOMS097J()}   , "Inserir Justificativas"    , "Inserir Justificativas"    , {|| .T.}})// "Ins.Justificat"
   Aadd( _aButtons , {"", {|| U_AOMS097C()}   , "Relatorio Por E-Mail"	    , "Relatorio Por E-Mail"      , {|| .T.}})// "Rel.Por E-Mail"
   Aadd( _aButtons , {"", {|| U_AOMS097L()}   , "Manututencao Ped.Vendas"   , "Manutencao Ped.Vendas"     , {|| .T.}})// "Manut.Ped.Vendas"
   Aadd( _aButtons , {"", _bAlteraMD          , "Marca/Desmarca Todos"      , "Marca/Desmarca Todos"      , {|| .T.}})// "Marca/Desmarca Todos"
   Aadd( _aButtons , {"", {|| U_AOMS097V("A")}, "Alteração Armazem Item PV" , "Alteração Armazem Item PV" , {|| .T.}})// "Alteração Armazem Item PV"
   Aadd( _aButtons , {"", {|| U_AOMS97FIL()}  , "Filtra por Legenda"        , "Filtra por Legenda"        , {|| .T.}})// "Filtra por Legenda"
   Aadd( _aButtons , {"", {|| U_AOMS97Clear()}, "Cancela Filtro por Legenda", "Cancela Filtro por Legenda", {|| .T.}})// "Cancela Filtro Legenda"
   Aadd( _aButtons , {"", {|| U_A097LEG()}    , "Legenda..."                , "Legenda"                   , {|| .T.}})// "Legenda"
   Aadd( _aButtons , {"", {|| U_AOM97ZY5()}   , "Manut.Cad.Justificativas"  , "Manut.Cad.Justificativas"   , {|| .T.}})// "Manut.Cad.Justificativa"

 

   //====================================================
   // Cria a tela de parâmetros iniciais caso não exista
   //====================================================
   //AOMS097X()
   
   //====================================================
   // Exibe a tela de parâmetros iniciais 
   //====================================================
   If ! Pergunte(_cPerg)
      Break
   EndIf
   
   INCLUI := .F.

   ALTERA := .T.

   //======================================================
   // Roda a query com base na tela de parâmetros iniciais
   // e cria tabela temporária.
   //======================================================
   Processa( {|| U_ROMS097Q() }, "Aguarde...", "Filtrando os Dados...",.F.)

   //======================================================
   // Cria a tabela temporária TRBSC5.
   //======================================================
   _aStruct := {} // ZY3->(DbStruct())
   Aadd(_aStruct, {"C5_FILIAL" , "C", 2 , 0})

   //_aCampoSC5 := {"C5_FILIAL","C5_NUM","C5_I_NOME","C5_I_FANTA","C5_I_NOMRD","C5_I_DESCO"}
    
   //                     Campo                 Titulo           Picture
   //============================================================================
   //Montagem do aheader SC5                                                       
   //=============================================================================
   aHeader := {}
   FillGetDados(1,"SC5",1,,,{||.T.}, , /*_aCampoSC5*/,,,,.T.)
   
   //                          1                    2               3              4               5                6             7        8              9                 10 
   // AADD(aHeader, {Alltrim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()", USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
   
   //================================================================================
   // Cria as estruturas das tabelas temporárias
   //================================================================================
   _aCmpSC5 := {}
   Aadd( _aCmpSC5 , { "WK_OK"	 ,    , "Marca"   ,"@!"})
   Aadd( _aCmpSC5 , { "C5_FILIAL", "" , "Filial"  , "@!" } )

   Aadd(_aStruct, {"WK_OK" , "C" , 2 , 0})
   _aCmpnoFinal:={}
   For _nI := 1 To Len(aHeader)

       IF !AllTrim(aHeader[_nI,2]) $ "C5_ALI_WT/C5_REC_WT"
	       Aadd(_aStruct, {aHeader[_nI,2], aHeader[_nI,8], aHeader[_nI,4], aHeader[_nI,5]})
       ENDIF

       If AllTrim(aHeader[_nI,2]) $ "C5_ASSNOM/C5_ASSCOD/C5_I_ENVRD"//Campo Reais para entrar no fim do Browse
          Aadd( _aCmpnoFinal , { aHeader[_nI,2], "" , aHeader[_nI,1]  , aHeader[_nI,3] } )
       ELSEIF AllTrim(aHeader[_nI,2]) = "C5_I_AGEND"
          //                     Campo                                         Titulo           Picture
          Aadd( _aCmpSC5 , { {|| TRBSC5->C5_I_AGEND+"-"+U_TipoEntrega(TRBSC5->C5_I_AGEND)  }, "" , aHeader[_nI,1]  , aHeader[_nI,3] } )
       ELSEIF !AllTrim(aHeader[_nI,2]) $ "C5_ALI_WT/C5_REC_WT"
          //                     Campo                 Titulo           Picture
          Aadd( _aCmpSC5 , { aHeader[_nI,2], "" , aHeader[_nI,1]  , aHeader[_nI,3] } )
       ENDIF

       If AllTrim(aHeader[_nI,2]) == "C5_LOJA"
          Aadd(_aStruct, {"C5_I_NOME", "C", 50, 0})
          //                     Campo           Titulo           Picture
          Aadd( _aCmpSC5 , { "C5_I_NOME", "" , "Nome Cliente"  , "@!" } )
       EndIf 

   Next   
   For _nI := 1 To Len(_aCmpnoFinal)
      Aadd( _aCmpSC5 , { _aCmpnoFinal[_nI,1], "" , _aCmpnoFinal[_nI,3]  , _aCmpnoFinal[_nI,4] } )
   NEXT
   //Campo Virtuais para entrar no fim do Browse
   Aadd( _aCmpSC5,{"ZPG_EMAIL", "" ,"E-Mail Assistente", "" } )
   Aadd( _aStruct,{"ZPG_EMAIL", "C",LEN(ZPG->ZPG_EMAIL),0})

   Aadd(_aStruct, {"WK_LEGENDA", "C", 1, 0})
   Aadd(_aStruct, {"WK_RECNO"  , "N", 10, 0})

   If Select("TRBSC5") > 0
      TRBSC5->(DbCloseArea())
   EndIf

   _otemp := FWTemporaryTable():New( "TRBSC5", _aStruct )
    
   _otemp:AddIndex( "I1", {"C5_NUM","C5_FILIAL"} )
   _otemp:Create()
   
   //                          1                    2               3              4               5                6             7        8              9                 10 
   // AADD(aHeader, {Alltrim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()", USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
   
   //======================================================
   // Cria a tabela temporária TRBZY8
   //======================================================
   _aStruct := {} // ZY3->(DbStruct())
   Aadd(_aStruct, {"WK_OK" , "C" , 2 , 0})
   Aadd(_aStruct, {"ZY8_FILIAL" , "C", 2 , 0})
    
   //                     Campo                 Titulo           Picture
   //============================================================================
   //Montagem do aheader ZY8                                                      
   //=============================================================================
   aHeader := {}
   FillGetDados(1,"ZY8",1,,,{||.T.},,,,,,.T.)
   
   //                          1                    2               3              4               5                6             7        8              9                 10 
   // AADD(aHeader, {Alltrim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()", USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
   
   //================================================================================
   // Cria as estruturas das tabelas temporárias
   //================================================================================
   _aCmpZY8 := {}
   Aadd( _aCmpZY8 , { "WK_OK"	 ,    , "Marca"                ,"@!"})
   Aadd( _aCmpZY8 , { "ZY8_FILFT" , "" , "Filial Fat."       , "@!" } )
   Aadd( _aCmpZY8 , { "ZY8_CODPRD", "" , "Codigo Produto."   , "@!" } )
   Aadd( _aCmpZY8 , { "ZY8_DSCPRD", "" , "Descrição Produto" , "@!" } )
   Aadd( _aCmpZY8 , { "ZY8_NUMPV" , "" , "Nr Ped Venda"      , "@!" } ) 
   Aadd( _aCmpZY8 , { "ZY8_UNSVEN", "" , "Qtd Ven 2 UM"      , "@E 99,999.999"} ) 
   Aadd( _aCmpZY8 , { "ZY8_SEGUM" , "" , "Segunda UM"        , "@!" } )  
   Aadd( _aCmpZY8 , { "ZY8_QTDVEN", "" , "Quantidade"        , "@E 999,999,999.999" } ) 
   Aadd( _aCmpZY8 , { "ZY8_UM"    , "" , "Unidade"           , "@!" } )

   For _nI := 1 To Len(aHeader)
   
	   Aadd(_aStruct, {aHeader[_nI,2], aHeader[_nI,8], aHeader[_nI,4], aHeader[_nI,5]})
        
      If ! AllTrim(aHeader[_nI,2]) $ "ZY8_CODPRD/ZY8_DSCPRD/ZY8_SEQUEN/ZY8_FILIAL/ZY8_NUMPV/ZY8_UNSVEN/ZY8_SEGUM/ZY8_QTDVEN/ZY8_UM"  
         //                     Campo                 Titulo           Picture
         Aadd( _aCmpZY8 , { aHeader[_nI,2], "" , aHeader[_nI,1]  , aHeader[_nI,3] } )
      EndIf 
   Next
   
   Aadd(_aStruct, {"ZY8_FILFT" , "C", 2, 0}) 
   Aadd(_aStruct, {"WK_RECNO"  , "N", 10, 0})
   Aadd(_aStruct, {"WKRECTRBY8", "N", 10, 0})

   _aCmpZY8Tela := {}
   Aadd( _aCmpZY8Tela , { "ZY8_FILFT" , "" , "Filial Fat."       , "@!" } )
   Aadd( _aCmpZY8Tela , { "ZY8_CODPRD", "" , "Codigo Produto."   , "@!" } )
   Aadd( _aCmpZY8Tela , { "ZY8_DSCPRD", "" , "Descrição Produto" , "@!" } )
   Aadd( _aCmpZY8Tela , { "ZY8_NUMPV" , "" , "Nr Ped Venda"      , "@!" } ) 
   Aadd( _aCmpZY8Tela , { "ZY8_UNSVEN", "" , "Qtd Ven 2 UM"      , "@E 99,999.999"} ) 
   Aadd( _aCmpZY8Tela , { "ZY8_QTDVEN", "" , "Quantidade"        , "@E 999,999,999.999" } ) 
   Aadd( _aCmpZY8Tela , { "ZY8_DTMONI", "" , 'Dt Monitoram'      , "@!" } ) 
   Aadd( _aCmpZY8Tela , { "ZY8_HRMONI", "" , 'Hr Monitoram'      , "@!" } ) 
   Aadd( _aCmpZY8Tela , { "ZY8_DTPREV", "" , 'Dt.Prev.Est'       , "" } ) 
   Aadd( _aCmpZY8Tela , { "ZY8_DTECLI", "" , 'Dt.Entr.Clie'      , "" } ) 
   Aadd( _aCmpZY8Tela , { "ZY8_OBSERV", "" , 'Observ.Just.'      , "@!" } ) 
   Aadd( _aCmpZY8Tela , { "ZY8_NOMUSR", "" , 'Nome Usuario'      , "@!" } ) 
   Aadd( _aCmpZY8Tela , { "ZY8_JUSCOD", "" , 'Cod. Justi'        , "@!" } ) 
   Aadd( _aCmpZY8Tela , { "ZY8_JUSDES", "" , 'Justificativ'      , "@!" } ) 

   If Select("TRBZY8") > 0
      TRBZY8->(DbCloseArea())
   EndIf

   _otemp := FWTemporaryTable():New( "TRBZY8", _aStruct )
    
   _otemp:AddIndex( "I1", {"ZY8_FILFT","ZY8_NUMPV","ZY8_SEQUEN"} )
   _otemp:AddIndex( "I2", {"ZY8_NUMPV"} )
   _otemp:Create()

   If Select("GDBZY8") > 0
      GDBZY8->(DbCloseArea())
   EndIf

   _otemp := FWTemporaryTable():New( "GDBZY8", _aStruct )
    
   _otemp:AddIndex( "I1", {"ZY8_FILFT","ZY8_NUMPV","ZY8_SEQUEN"} )
   _otemp:AddIndex( "I2", {"ZY8_DSCPRD","ZY8_NUMPV"} )

   _otemp:Create()

   //======================================================
   // Cria a tabela temporária TRBZY3.
   //======================================================
   _aStruct := {} // ZY3->(DbStruct())
   Aadd(_aStruct, {"ZY3_FILIAL" , "C", 2 , 0})
    
   //                     Campo                 Titulo           Picture
   //============================================================================
   //Montagem do aheader ZY3                                                      
   //=============================================================================
   aHeader := {}
   FillGetDados(1,"ZY3",1,,,{||.T.},,,,,,.T.)
   
   //================================================================================
   // Cria as estruturas das tabelas temporárias
   //================================================================================
   _aCmpZY3 := {}
   Aadd( _aCmpZY3 , { "ZY3_FILIAL", "" , "Filial"  , "@!" } )
   Aadd( _aCmpZY3 , { "ZY3_FILFT" , "" , "Filial Fat." , "@!" } )

   For _nI := 1 To Len(aHeader)
	   Aadd(_aStruct, {aHeader[_nI,2], aHeader[_nI,8], aHeader[_nI,4], aHeader[_nI,5]})

       //                     Campo                 Titulo           Picture
       Aadd( _aCmpZY3 , { aHeader[_nI,2], "" , aHeader[_nI,1]  , aHeader[_nI,3] } )
   
   Next
   
   Aadd(_aStruct, {"ZY3_FILFT" , "C", 2, 0}) 
   Aadd(_aStruct, {"WK_RECNO"  , "N", 10, 0})
   Aadd(_aStruct, {"WKRECTRBY3", "N", 10, 0})

   If Select("TRBZY3") > 0
      TRBZY3->(DbCloseArea())
   EndIf

   _otemp := FWTemporaryTable():New( "TRBZY3", _aStruct )
    
   _otemp:AddIndex( "I1", {"ZY3_FILFT","ZY3_NUMPV"} )
   _otemp:Create()

   If Select("GDBZY3") > 0
      GDBZY3->(DbCloseArea())
   EndIf

   _otemp := FWTemporaryTable():New( "GDBZY3", _aStruct )
    
   _otemp:AddIndex( "I1", {"ZY3_FILFT","ZY3_NUMPV"} )
   _otemp:Create()


   Processa( {|| U_AOMS097G(_nTotRegs) }, "Aguarde...", "Gravando Dados nas Tabelas Temporarias...",.F.)

   //================================================================================
   // Monta a tela MsSelect SC5  x MsSelect ZY3
   //================================================================================    
   _aObjects := {} 
   AAdd( _aObjects, { 315,  50, .T., .T. } )
   AAdd( _aObjects, { 100, 100, .T., .T. } )

   _aInfo := { _aSizeAut[ 1 ], _aSizeAut[ 2 ], _aSizeAut[ 3 ], _aSizeAut[ 4 ], 3, 3 } 

   _aPosObj := MsObjSize( _aInfo, _aObjects, .T. ) 
   
   _bOk     := {|| _lRet := .T., _oDlgH:End()}
   _bCancel := {|| _lRet := .F., _oDlgH:End()}
                       
   _cTitulo := "Manutenção Gestão de Carteira"
   
   TRBSC5->(DbGoTop())
   
   _cNumPed := TRBSC5->C5_NUM

   U_AOMS097H()

   _aHeadZY3 := {}
   For _nI := 1 To Len(aHeader)
       If AllTrim(aHeader[_nI,2]) == "ZY3_ALI_WT"       
          Aadd(_aHeadZY3, {  "ZY3_ALI_WT",;  
                             "",;
                             "Alias WT",; 
                             ""})                 

       ElseIf AllTrim(aHeader[_nI,2]) == "ZY3_REC_WT"
          Aadd(_aHeadZY3, {  "ZY3_REC_WT",;  
                             "",;
                             "Recno WT",; 
                             ""})                 
       Else 
          //                     Campo    ""           Titulo           Picture
          Aadd(_aHeadZY3, {  AllTrim(GetSx3Cache(aHeader[_nI,2],"X3_CAMPO")),;  
                             "",;
                             AllTrim(GetSx3Cache(aHeader[_nI,2],"X3_TITULO")),; 
                             AllTrim(GetSx3Cache(aHeader[_nI,2],"X3_PICTURE"))})
       EndIf 
   Next

//PRIVATE _oQtda:=NIL
PRIVATE _nQtdSel:=0

DO WHILE .T.

   Define MsDialog _oDlgH Title _cTitulo From _aSizeAut[7],00 To _aSizeAut[6], _aSizeAut[5] Of oMainWnd Pixel 
                 //MsSelect():New ( < cAlias>, [ cCampo], [ cCpo], [ aCampos], [ lInv] , [ cMar]    , < aCord>                                                   , [ cTopFun]   , [ cBotFun]   , < oWnd>       , [ uPar11], [ aColors] ) --> oSelf 
	  _oMarkSC5:= MsSelect():New("TRBSC5"   ,"WK_OK"   ,""      ,_aCmpSC5   ,@_lInvSC5, @_cMarcaSC5,{_aPosObj[1,1]+20, _aPosObj[1,2], _aPosObj[1,3]+70, _aPosObj[1,4]},              ,              ,               ,          ,  _aCores   )      
 	  _oMarkSC5:bMark:={|| AOMS97Marca(.F.) }
	  
	  _oMarkSC5:OBrowse:BCHANGE := {|| U_AOMS097H() }

     _oMarkZY3 := MsSelect():New("GDBZY3"   ,""   ,""      ,_aHeadZY3   ,@_lInvZY3, @_cMarcaZY3,{_aPosObj[2,1]+70, _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4]},              ,              ,               ,          ,  )        
     
     _oMarkZY3:bAval := {|| U_AOMS097O() }

     oTButton1 := TButton():New( _aPosObj[1,1], _aPosObj[1,2],     "Marca/Desmarca Todos"                    ,_ODlgH,{|| FWMSGRUN( ,{|| U_AOMS097M(_cMarcaSC5) } , "Aguarde!" , "Processando Marcações..." ) }, 80,15,,,.F.,.T.,.F.,,.F.,,,.F. )  
     oTButton2 := TButton():New( _aPosObj[1,1], _aPosObj[1,2]+100, "Visualizar Data Prev.Estoque"            ,_ODlgH,{|| U_AOMS097O()}                                                                        , 80,15,,,.F.,.T.,.F.,,.F.,,,.F. )  
     oTButton3 := TButton():New( _aPosObj[1,1], _aPosObj[1,2]+200, "Filtra por Legenda"                      ,_ODlgH,{|| U_AOMS97FIL()}                                                                       , 80,15,,,.F.,.T.,.F.,,.F.,,,.F. )  
     oTButton4 := TButton():New( _aPosObj[1,1], _aPosObj[1,2]+300, "Cancela Filtro por Legenda"              ,_ODlgH,{|| U_AOMS97Clear()}                                                                     , 80,15,,,.F.,.T.,.F.,,.F.,,,.F. )  
     oTButton5 := TButton():New( _aPosObj[1,1], _aPosObj[1,2]+400, "MARCADOS: "+TRANS(_nQtdSel,"@E 9999,999"),_ODlgH,{|| AOMS97Marca(.T.)}                                                                    , 80,15,,,.F.,.T.,.F.,,.F.,,,.F. )  

     //_nLin:=_aPosObj[1,1]+05
     //_nCol:=_aPosObj[1,2]+300
     //@_nLin,_nCol+100 Say "MARCADOS:"			                          OF _oDlgH PIXEL
     //@_nLin,_nCol+130 Say _oQtda VAR _nQtdSel Picture "@E 999,999,999" OF _oDlgH PIXEL SIZE 60,8
     
   Activate MsDialog _oDlgH On Init EnchoiceBar(_oDlgH,_bOk,_bCancel,,_aButtons) 
   
   IF U_ITMSG("Confirma Sair ?",'Atenção!',,3,2,3,,"CONFIRMA","VOLTAR",)
      EXIT
   ENDIF

ENDDO

End Sequence

If Select("TRBSC5") > 0
   TRBSC5->(DbCloseArea())
EndIf

If Select("TRBZY3") > 0
   TRBZY3->(DbCloseArea())
EndIf

If Select("TRBZY8") > 0
   TRBZY8->(DbCloseArea())
EndIf

Return

/*
===============================================================================================================================
Programa----------: AOMS97Marca()
Autor-------------: Alex Wallauer
Data da Criacao---: 08/10/2024
Descrição---------: Rotina para inverter a marcacao do registro posicionado.
Parametros--------: lBotao
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS97Marca(lBotao)
Local lMarcado := !Empty(TRBSC5->WK_OK)

IF lBotao//só mexe na marcacao se vier do botão , do click/mouse já vem processado/invertido
   If lMarcado
      TRBSC5->WK_OK:=""
   Else
      TRBSC5->WK_OK:=_cMarcaSC5
   EndIf
ENDIF
If !Empty(TRBSC5->WK_OK)
	_nQtdSel++
Else
	_nQtdSel--
EndIf
IF _nQtdSel < 0 
   _nQtdSel:=0
ENDIF
//_oQtda:Refresh()
oTButton5:cCaption:="MARCADOS: "+TRANS(_nQtdSel,"@E 9999,999")
IF lBotao //SÓ MEXE NA MARCACAO SE VIER DO BOTÃO , DO CLICK/MOUSE JÁ VEM PROCESSADO/INVERTIDO
   TRBSC5->(DBSKIP())
   IF TRBSC5->(EOF())
      TRBSC5->(DBGOBOTTOM())
      _oMarkSC5:OBrowse:Refresh()
   ENDIF
ENDIF
Return .T.

/*
===============================================================================================================================
Programa----------: A097PLA
Autor-------------: Josué Danich Prestes
Data da Criacao---: 27/04/2016
===============================================================================================================================
Descrição---------: Função criada para gerar tela para exportação dos dados para planilha
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function A097PLA()
Local _aArea	:= GetArea()
Local _aCampPla	 
Local _aLogPla	:= {}
Local _cQrySD2	:= ""
Local _nCont	:= 1
Local _dDataQry := Date() - 30

Begin Sequence
   If TRBSC5->(Eof()) .Or. TRBSC5->(Bof())
      U_ItMsg("Não há pedido de vendas selecionado para visualização dos dados da nota fiscal.", "Atenção", "Favor selecionar um pedido de vendas.",1) 
	  Break
   EndIf

   _aCampPla	:= {'Índice',;
                    'Filial',;
                    'Nota',;
                    'Série',;
                    'Operacao',;
                    'Dt. Emissão',;
                    'Pedido',;
                    'Cliente',;
                    'Loja',;
                    'Nome',;
                    'Item',;
                    'Produto',;
                    'Descrição',;
                    'Quantidade',;
                    'Preço Unitário',;
                    'Valor Total'}

   If Select("TRBSD2") > 0
      TRBSD2->(dbCloseArea())
   EndIf

   _cQrySD2 := " SELECT D2_FILIAL, D2_DOC, C5_I_OPER, D2_EMISSAO, D2_SERIE, D2_PEDIDO, D2_CLIENTE, D2_LOJA, D2_ITEM, D2_COD, D2_QUANT, D2_PRCVEN, D2_TOTAL, A1_NREDUZ, B1_DESC "
   _cQrySD2 += " FROM " + RetSqlName("SD2") + " SD2 "
   _cQrySD2 += " JOIN SA1010 SA1 ON A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND SA1.D_E_L_E_T_ = ' '"
   _cQrySD2 += " JOIN sc5010 SC5 ON C5_filial = D2_FILIAL  AND C5_NUM = D2_PEDIDO  "
   _cQrySD2 += " JOIN SB1010 SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = D2_COD AND SB1.D_E_L_E_T_ = ' ' "
   _cQrySD2 += " WHERE SD2.D_E_L_E_T_ = ' ' "
   _cQrySD2 += " AND D2_EMISSAO >= '" + Dtos(_dDataQry) + "' "
   _cQrySD2 += " AND D2_CLIENTE = '"+TRBSC5->C5_CLIENTE + "' "  //(Cliente do Pedido Posicionado)
   _cQrySD2 += " AND D2_LOJA    = '"+TRBSC5->C5_LOJACLI + "' "  // (LOJA do Pedido Posicionado)
   _cQrySD2 += " AND SC5.d_e_l_e_t_ = ' ' "
   _cQrySD2 += " AND C5_TIPO = 'N' "
   _cQrySD2 += " AND SD2.d_e_l_e_t_ = ' ' "

   //dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQrySD2 ) , "TRBSD2" , .T., .F. )
   MPSysOpenQuery( _cQrySD2 , "TRBSD2")

   dbSelectArea("TRBSD2")
   TRBSD2->(dbGoTop())

   If !TRBSD2->(Eof())
	  While !TRBSD2->(Eof())
	     aAdd( _aLogPla , { StrZero(_nCont++,4),;																//[1]  Índice
		                     TRBSD2->D2_FILIAL,;                                                                //[2]  Filial
							 TRBSD2->D2_DOC,;																	//[3]  Nota
							 TRBSD2->D2_SERIE,;																	//[4]  Série
							 TRBSD2->C5_I_OPER,;                                                                //[5]  Operação
							 StoD(TRBSD2->D2_EMISSAO),;											 				//[6]  Dt. Emissão
							 TRBSD2->D2_PEDIDO,;                                                                //[7]  Pedido
							 TRBSD2->D2_CLIENTE ,;	                                                            //[8]  Cliente
							 TRBSD2->D2_LOJA,;                                                                  //[9]  Loja
							 AllTrim(TRBSD2->A1_NREDUZ),;														//[10] Nome
							 TRBSD2->D2_ITEM,;														  			//[11] Item
							 TRBSD2->D2_COD,;														   			//[12] Produto
							 TRBSD2->B1_DESC,;																	//[13] Descrição
							 AllTrim(Transform(TRBSD2->D2_QUANT,PesqPict("SD2","D2_QUANT"))),;					//[14] Quantidade
							 AllTrim(Transform(TRBSD2->D2_PRCVEN,PesqPict("SD2","D2_PRCVEN"))),;				//[15] Preço Unitário
							 AllTrim(Transform(TRBSD2->D2_TOTAL,PesqPict("SD2","D2_TOTAL"))) })					//[16] Valor Total

	     TRBSD2->(dbSkip())
	  End

	  U_ITListBox( 'Geração Planilha' , _aCampPla , _aLogPla , .T. , 1 )

   Else
	  u_itmsg("Não existem dados a serem mostrados para o Pedido selecionado.", "Atenção", "Favor selecionar outro pedido.",2)
   EndIf

   If Select("TRBSD2") > 0
      TRBSD2->(dbCloseArea())
   EndIf

End Sequence

RestArea(_aArea)

Return Nil

/*
===============================================================================================================================
Programa----------: A097LEG
Autor-------------: Josué Danich Prestes
Data da Criacao---: 28/04/2016
===============================================================================================================================
Descrição---------: Função utilizada para montar a legenda
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function A097LEG()

 aLegenda := {  {"BR_VIOLETA" , "Agendamento maior que o permitido." },;
                {"BR_AZUL"    , "Aguardando data para faturamento." },;
                {"BR_VERDE"   , "Cobrar faturamento." },;
                {"BR_AMARELO" , "Faturamento urgente." },;
                {"BR_VERMELHO", "Perdeu agenda." },;
                {"BR_CINZA"   , "Bloqueado para Faturamento."}}

BrwLegenda("Gestão de Carteira de Pedidos de Vendas","Legenda",aLegenda)

return


/*
===============================================================================================================================
Programa----------: A097DTEN
Autor-------------: Josué Danich Prestes
Data da Criacao---: 06/06/2016
===============================================================================================================================
Descrição---------: Rotina para alteração de data de Ent.PV
===============================================================================================================================
Parametros--------: oProc1
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function A097DTEN(oProc1 As Object) As Logical
Local _oDlg2 As Object
Local aArea		:= GetArea() As Array
Local cGet1		:= STOD("//") As Date
Local nOpc		:= 0 As Numeric
Local _lAlterou:= .F. As Logical
Local _nRegAtu := TRBSC5->(Recno()) As Numeric
Local nLinha   := 10 As Numeric
Local _nCol1   := 05 As Numeric
Local _nCol2   := 60 As Numeric
Local _nCol3   := 90 As Numeric
Local _nCol4   := 150 As Numeric
Local _nCol5   := _nCol4+55 As Numeric
Local _nTam    := 285 As Numeric

_cJustDE := Space(3) // _aJustDE[1]
_cObseDE := SPACE(LEN(ZY3->ZY3_OBSERV))
 cGet2   := TRBSC5->C5_I_DTENT

_aFoders:={}
AADD(_aFoders,"Alterar Data de Entrega")

Begin Sequence


   DEFINE MSDIALOG _oDlg2 TITLE "Gestão de Carteira - Pedido de Vendas: "+TRBSC5->C5_NUM From 0,0 To 280, 700 PIXEL
                                                                       
	_nColFolder:=350
   _nLinFolder:=100
	nLinha:=1
   nOpc  :=0

   oTFolder1:= TFolder():New( nLinha,1,_aFoders,,_oDlg2,,,,.T., , _nColFolder,_nLinFolder )

   nLinha:=5
   @ nLinha+3, _nCol1 SAY "Nova Data Entrega: " SIZE 060, 012 OF oTFolder1:aDialogs[LEN(_aFoders)] PIXEL
 	@ nLinha  , _nCol2 MSGET cGet1               SIZE 060, 012 OF oTFolder1:aDialogs[LEN(_aFoders)] PIXEL 

   @ nLinha+3, _nCol4 SAY "Data Entrega Atual: " SIZE 060, 012 OF oTFolder1:aDialogs[LEN(_aFoders)] PIXEL
 	@ nLinha  , _nCol5 MSGET cGet2                SIZE 060, 012 OF oTFolder1:aDialogs[LEN(_aFoders)] PIXEL  WHEN .F.
	nLinha+=22

	@ nLinha+4,_nCol1 Say "Justificativas:"  OF oTFolder1:aDialogs[LEN(_aFoders)] PIXEL
	 //                 nRow ], nCol , [ bSetGet ]                            , nItens ],nWi  ,He    ,oWnd ]                           ,uPar,bChange,bValid,nClrText,nClrBack,lPixel,oFont,uParam15,uParam16,bWhen
   @ nLinha+4,_nCol2 MSGet _cJustDE  F3 "ZY5"  Valid(AOMS97VLJU(_cJustDE , "C5_I_DTENT")) SIZE 030,010 PIXEL OF oTFolder1:aDialogs[LEN(_aFoders)] 

	nLinha+=24
   
   @ nLinha+2,_nCol1 SAY  "Observação:" SIZE 060  ,012 PIXEL OF oTFolder1:aDialogs[LEN(_aFoders)] 
	@ nLinha,_nCol2 MsGet _cObseDE         SIZE _nTam,012 WHEN .F. PIXEL OF oTFolder1:aDialogs[LEN(_aFoders)] 

	nLinha+=65
	@ nLinha,_nCol3    BUTTON "OK"       SIZE 50,15 PIXEL OF _oDlg2 ACTION (If((lRet:=.F.,FWMSGRUN(,{|O|lRet:=U_AOMS097W(cGet1,.F.,O,"DT_ENTREGA")}),lRet),(nOpc := 1, _oDlg2:End()), ))
   @ nLinha,_nCol3+99 BUTTON "Cancelar" SIZE 50,15 PIXEL OF _oDlg2 ACTION (nOpc := 2, _oDlg2:End())
  
   ACTIVATE MSDIALOG _oDlg2 

   If nOpc == 1

	   TRBSC5->(DbGoTop()) 
      Private _aLogSC5 := {}
      Private _aLogSC6 := {}      
      _nConta:=0
	   Do While ! TRBSC5->(Eof())
	     
	      
	      If ! Empty(TRBSC5->WK_OK)
             
			   SC5->(DbGoto(TRBSC5->WK_RECNO))   

            _nConta++
            IF VALTYPE(oProc1) = "O"
               oProc1:cCaption := ("Pedidos Gravados: "+ALLTRIM(STR(_nConta)))
               ProcessMessages()
            ENDIF
        
            IF SC5->C5_I_DTENT <> cGet1
		         // Inicia a gravação de Log, Tabelas SC5 e SC6.
		         _aLogSC5 := U_ITIniLog( 'SC5' , {"C5_I_AGEND","C5_I_DTENT","C5_FECENT"} )
		         _aLogSC6 := INILOG6( {"C6_ENTREG"} )
            ENDIF

			   _ddtant := SC5->C5_I_DTENT
		      SC5->(RecLock("SC5",.F.))
		      SC5->C5_I_DTENT:= cGet1
				SC5->C5_FECENT := cGet1
            //If SC5->C5_I_AGEND $ "R|N" .AND.  M->C5_I_AGEND $ "A|T|O"  .AND. _ddtant <> cGet1
         	//   SC5->C5_I_QTDA := SC5->C5_I_QTDA+1//SOMA PARA CADA ALTERACAO EFETIVADA
            //EndIf
		      SC5->(MsUnLock()) 

            SC6->( DbSetOrder(1) )
            SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
            DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM
		         SC6->(RecLock("SC6",.F.))
               SC6->C6_ENTREG:=cGet1
		         SC6->(MsUnLock()) 
	            SC6->( DBSkip() ) 	
            ENDDO
            
            IF SC5->C5_I_DTENT <> _ddtant

               if SC5->C5_I_ENVRD = "S" .AND. !SuperGetMV("IT_AMBTEST",.F.,.T.)
                  U_ENVSITPV(,.F.)//ON LINE   //Envia interface de alteração de situação do pedido atual
               ENDIF
   
		         // Grava log de alterações do SC5 E SC6
		         If Type('_aLogSC5') == 'A' .And. !Empty( _aLogSC5 )
		         	U_ITGrvLog( _aLogSC5 , "SC5" , 1 , SC5->( C5_FILIAL + C5_NUM ) , "A" , __CUSERID , Date() , Time() )
		         EndIf
		         If Type('_aLogSC6') == 'A' .And. !Empty( _aLogSC6 )
		         	U_ITGrvLog( _aLogSC6 , "SC6" , 1 , SC5->( C5_FILIAL + C5_NUM ) , "A" , __CUSERID , Date() , Time() )
		         EndIf
   
			      //->(RecLock("TRBSC5",.F.))
		         TRBSC5->C5_I_DTENT := cGet1
		         //TRBSC5->(MsUnLock()) 
   
		         _dDTNECE := cGet1 
               //_cJUSCOD := "007"//Alterado Data de Entrega
               _cCOMENT := "Data de entrega modificada de " + dtoc(_ddtant) + " para " + dtoc(SC5->C5_I_DTENT) + "  via alteração de pedido de vendas."
   
                          //_cFilial,_cNum,_cJUSCOD,_cCOMENT,_cLENCMON,_dDTNECE,_dDTFAT      ,_dDTFOLD , _cObserv, _cVinculoTb, _dDtSugAgen
	            U_GrvMonitor(        ,     ,_cJustDE,_cCOMENT,""       ,_dDTNECE,SC5->C5_I_DTENT,_ddtant,_cObseDE)     
               U_AOMS097Z()
            
            ENDIF 

		      _lAlterou := .T.
	      EndIf

	      TRBSC5->(DbSkip())
      EndDo

      If _lAlterou 
	      U_Itmsg("Data de Entrega alterada com sucesso para todos os itens.","Atenção","Pedidos Gravados: "+ALLTRIM(STR(_nConta)),2)
      Else
         U_Itmsg("Não há itens marcados para alteração da data de entrega.","Atenção",,1)
	   EndIf 
   EndIf

End Sequence

TRBSC5->(DbGoTo(_nRegAtu))

RestArea(aArea)

RETURN 

/*
===============================================================================================================================
Programa----------: A0MS97Val(cGet1)
Autor-------------: Alex Wallauer
Data da Criacao---: 22/06/2017
===============================================================================================================================
Descrição---------: Rotina para GRAVAÇÃO
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER Function A0MS97Val(cGet1,_lValid)//Chamado do valid do CAMPO ZY3_JUSCOD U_A0MS97Val(M->ZY3_JUSCOD) / U_A0MS97Val(,.F.)
DEFAULT _lValid := .T.

IF !_lValid
   _dRet:=_dGetEE
   RETURN _dRet
ENDIF

IF EMPTY(cGet1)
   cGet2:=" "
   RETURN .T.
ELSEIF !ExistCpo("ZY5",cGet1) 
   RETURN .F.
ENDIF

IF cGet1 $ _cGrpAuto
   MSGSTOP("Essas justificativas não pode ser utilizadas: ["+_cGrpAuto+"]")
   RETURN .F.
ENDIF

cGet2:=POSICIONE("ZY5",1,xFilial("ZY5")+cGet1,"ZY5_DESCR")

RETURN .T.

/*
===============================================================================================================================
Programa--------: AOMS097X
Autor-----------: Julio de Paula Paz
Data da Criacao-: 15/07/2019
===============================================================================================================================
Descrição-------: Cria a tela de parâmetros iniciais do Relatório.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================

Static function AOMS097X()

Local aHelpPor := {}
Local aHelpSpa := {}
Local aHelpEng := {}

//Da Filial
Aadd( aHelpPor, 'Informe a filial inicial')
Aadd( aHelpPor, 'que deseja filtrar.                 ')
u_itputx1(_cPerg,"01","Filiais"," "," ","mv_ch1","C",75,0,0,"G","","LSTFIL","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//De Emissao
aHelpPor := {}
Aadd( aHelpPor, 'Informe a data da emissao inicial ')
Aadd( aHelpPor, 'que deseja filtrar.                 ')
u_itputx1(_cPerg,"02","De Emissao"," "," ","mv_ch3","D",8,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Ate Emissao
aHelpPor := {}
Aadd( aHelpPor, 'Informe a data da emissao final ')
Aadd( aHelpPor, 'que deseja filtrar.                 ')
u_itputx1(_cPerg,"03","Ate Emissao"," "," ","mv_ch4","D",8,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//De Entrega
aHelpPor := {}
Aadd( aHelpPor, 'Informe a data da entrega inicial ')
Aadd( aHelpPor, 'que deseja filtrar.                 ')
u_itputx1(_cPerg,"04","De Entrega"," "," ","mv_ch5","D",8,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Ate Entrega
aHelpPor := {}
Aadd( aHelpPor, 'Informe a data da entrega final ')
Aadd( aHelpPor, 'que deseja filtrar.                 ')
u_itputx1(_cPerg,"05","Ate Entrega"," "," ","mv_ch6","D",8,0,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//De produto
aHelpPor := {}
Aadd( aHelpPor, 'Informe o codigo inicial do produto')
Aadd( aHelpPor, 'que deseja filtrar.                 ')
u_itputx1(_cPerg,"06","De Produto"," "," ","mv_ch7","C",14,0,0,"G","","SB1","","","mv_par06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Ate produto
aHelpPor := {}
Aadd( aHelpPor, 'Informe o codigo final do produto')
Aadd( aHelpPor, 'que deseja filtrar.                 ')
u_itputx1(_cPerg,"07","Ate Produto"," "," ","mv_ch8","C",14,0,0,"G","","SB1","","","mv_par07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//De Cliente
aHelpPor := {}
Aadd( aHelpPor, 'Informe o cliente de entrega inicial  ')
Aadd( aHelpPor, 'que deseja filtrar.                   ') 
u_itputx1(_cPerg,"08","De Cliente"," "," ","mv_ch9","C",6,0,0,"G","","SA1","","","mv_par08","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Loja
aHelpPor := {}
Aadd( aHelpPor, 'Informe a loja inicial do cliente de  ')   
Aadd( aHelpPor, 'entrega que deseja filtrar.           ') 
u_itputx1(_cPerg,"09","Loja "," "," ","mv_cha","C",4,0,0,"G","","","","","mv_par09","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Ate Cliente
aHelpPor := {}
Aadd( aHelpPor, 'Informe o cliente de entrega final  ')
Aadd( aHelpPor, 'que deseja filtrar.                 ')
u_itputx1(_cPerg,"10","Ate Cliente"," "," ","mv_chb","C",6,0,0,"G","","SA1","","","mv_par10","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Loja
aHelpPor := {}
Aadd( aHelpPor, 'Informe a loja final do cliente de   ')  
Aadd( aHelpPor, 'entrega que deseja filtrar.          ') 
u_itputx1(_cPerg,"11","Loja "," "," ","mv_chc","C",4,0,0,"G","","","","","mv_par11","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Rede
aHelpPor := {}
Aadd( aHelpPor, 'Selecione as redes que deseja')
Aadd( aHelpPor, 'filtrar. Separe com ";" as redes.')
Aadd( aHelpPor, 'Ex.: 000001;000002;000003       ')
u_itputx1(_cPerg,"12","Rede"," "," ","mv_chd","C",75,0,0,"G","","LSTRED","","","mv_par12","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Do Estado
aHelpPor := {}
Aadd( aHelpPor, 'Informe os Estados que deseja ')
Aadd( aHelpPor, 'filtrar.Separe com ";" os vendedores.')
Aadd( aHelpPor, 'Ex.: GO;SP;MG       ')
u_itputx1(_cPerg,"13","Estado"," "," ","mv_che","C",75,0,0,"G","","LSTEST","","","mv_par13","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Do Municipio
aHelpPor := {}
Aadd( aHelpPor, 'Informe os municipios que deseja ')
Aadd( aHelpPor, 'filtrar. Separe com ";" os municipios.  ')
Aadd( aHelpPor, 'Ex.: 00001;00002;00003       ')
u_itputx1(_cPerg,"14","Municipio"," "," ","mv_chg","C",75,0,0,"G","","LSTMUN","","","mv_par14","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Do Vendedor
aHelpPor := {}
Aadd( aHelpPor, 'Selecione os vendedores que deseja   ')
Aadd( aHelpPor, 'filtrar.Separe com ";" os vendedores.')
Aadd( aHelpPor, 'Ex.: 000001;000002;000003       ')
u_itputx1(_cPerg,"15","Vendedor"," "," ","mv_chh","C",75,0,0,"G","","LSTVEN","","","mv_par15","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Coordenador
aHelpPor := {}
Aadd( aHelpPor, 'Selecione os Coordenador que deseja')
Aadd( aHelpPor, 'filtrar. Separe com ";" os Coordenador.')
Aadd( aHelpPor, 'Ex.: 000001;000002;000003       ')
u_itputx1(_cPerg,"16","Coordenador"," "," ","mv_chi","C",75,0,0,"G","","LSTSUP","","","mv_par16","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Grupo de Produtos
aHelpPor := {}
Aadd( aHelpPor, 'Selecione os grupos de produto ')
Aadd( aHelpPor, 'que deseja filtrar.Separe com ";" ')
Aadd( aHelpPor, 'os grupos. Ex.: 000001;000002;000003       ')
u_itputx1(_cPerg,"17","Grupo Produto"," "," ","mv_chj","C",75,0,0,"G","","LSTGRP","","","mv_par17","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Produto Nivel 2
aHelpPor := {}
Aadd( aHelpPor, 'Selecione os Produtos Nivel 2 que deseja')
Aadd( aHelpPor, 'filtrar.Separe com ";" os niveis.')
Aadd( aHelpPor, 'Ex.: 0001;0002;0003       ')
u_itputx1(_cPerg,"18","Produto Nivel 2"," "," ","mv_chk","C",75,0,0,"G","","LSTN2","","","mv_par18","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Produto Nivel 3
aHelpPor := {}
Aadd( aHelpPor, 'Selecione os Produtos Nivel 3 que deseja')
Aadd( aHelpPor, 'filtrar.Separe com ";" os niveis.')
Aadd( aHelpPor, 'Ex.: 0001;0002;0003       ')
u_itputx1(_cPerg,"19","Produto Nivel 3"," "," ","mv_chl","C",75,0,0,"G","","LSTN3","","","mv_par19","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Produto Nivel 4
aHelpPor := {}
Aadd( aHelpPor, 'Selecione os Produtos Nivel 4 que deseja')
Aadd( aHelpPor, 'filtrar.Separe com ";" os niveis.')
Aadd( aHelpPor, 'Ex.: 0001;0002;0003       ')
u_itputx1(_cPerg,"20","Produto Nivel 4"," "," ","mv_chm","C",75,0,0,"G","","LSTN4","","","mv_par20","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Status do Pedido
aHelpPor := {}
Aadd( aHelpPor, 'Informe o status dos pedidos que deseja  ')
Aadd( aHelpPor, 'visualizar. Liberados: Pronto para Faturar;')
Aadd( aHelpPor, 'Só emitidos: Somente emitidos, sem liberação')
u_itputx1(_cPerg,"21","Status"," "," ","mv_chp","C",1,0,0,"C","","","","","MV_PAR21","Liberados","","","","Só Emitidos","","","Todos","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Bloqueios
aHelpPor := {}
Aadd( aHelpPor, 'Informe o status dos Bloqueios que deseja  ')
Aadd( aHelpPor, 'visualizar. Bloqueio Crédito; Bloqueio Estoque;')
Aadd( aHelpPor, 'Bloqueio Crédito/Estoque; Liberados;Todos')
u_itputx1(_cPerg,"22","Bloqueio"," "," ","mv_chq","C",1,0,0,"C","","","","","MV_PAR22","Blq Crédito","","","","Blq Estoque","","","Blq Cred/Est","","","Liberados","","","Todos","","",aHelpPor,aHelpEng,aHelpSpa)

//Filtro usuario: filial + matricula
aHelpPor := {}
Aadd( aHelpPor, 'Selecione o usuario(filial + matricula)')
Aadd( aHelpPor, 'que deseja filtrar')
Aadd( aHelpPor, 'Ex.: 01000001;01000002')
u_itputx1(_cPerg,"23","Usuario"," "," ","mv_chr","C",8,0,0,"G","","","","","MV_PAR23","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//CFOPs
aHelpPor := {}
Aadd( aHelpPor, 'Informe os CFOPS que deseja filtrar')
u_itputx1(_cPerg,"24","CFOP's"," "," ","mv_chS","C",10,0,0,"G","","LSTTCF","","","MV_PAR24","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Do Armazem
Aadd( aHelpPor, 'Informe os armazens que deseja ')
Aadd( aHelpPor, 'filtrar.                 ')
u_itputx1(_cPerg,"25","Armazem"," "," ","mv_ch1","C",75,0,0,"G","","LSTNNR","","","MV_PAR25","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Sub Grupo de Produto
aHelpPor := {}
Aadd( aHelpPor, 'Selecione os Sub Grupo de Produos que')
Aadd( aHelpPor, 'deseja filtrar.Separe com ";" ')
Aadd( aHelpPor, 'Ex.: 001;002;003       ')
u_itputx1(_cPerg,"26","Sub Grupo Produto"," "," ","mv_chT","C",75,0,0,"G","","LSTZB9","","","MV_PAR26","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Peso de
aHelpPor := {}
Aadd( aHelpPor, 'Informe o peso inicial')
u_itputx1(_cPerg,"27","Peso de ?"," "," ","mv_chu","N",12,4,0,"G","","","","","MV_PAR27","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Peso ate
aHelpPor := {}
Aadd( aHelpPor, 'Informe o peso final')
u_itputx1(_cPerg,"28","Peso ate ?"," "," ","mv_chv","N",12,4,0,"G","","","","","MV_PAR28","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Tipo de Carga
aHelpPor := {}
Aadd( aHelpPor, 'Selecione o tipo de carga, sendo')
Aadd( aHelpPor, 'Paletizada e/ou Batida.')
u_itputx1(_cPerg,"29","Tipo de Carga ?"," "," ","mv_chx","C",10,0,0,"G","","LSTTCA","","","MV_PAR29","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Tipo de Entrega
aHelpPor := {}
//Aadd( aHelpPor, 'A – AGENDADA / M – AGENDADA COM MULTA')//A=AGENDADA ; I=IMEDIATA ; M=AGENDADA C/MULTA ; P=AGUARD. AGENDA
//Aadd( aHelpPor, 'I – IMEDIATA / P – AGUARD. AGENDA / T - TODOS ')
u_itputx1(_cPerg,"30","Tipo de Entrega ?"," "," ","mv_chz","C",16,0,0,"G","","LSTAGE","","","MV_PAR30","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

_aHelp := { 'Selecione os gerentes que deseja    ' , 'filtrar. Separe com ";" os gerentes.' , 'Ex.: 000001;000002;000003                ' }
u_itputx1(_cPerg,"31","Gerente"," "," ","mv_chy","C",99,0,0,"G","","LSTGER","","","MV_PAR31","","","","","","","","","","","","","","","","",_aHelp,_aHelp,_aHelp)

Return Nil*/

/*
===============================================================================================================================
Programa--------: ROMS097Q
Autor-----------: Julio de Paula Paz
Data da Criacao-: 15/07/2019
===============================================================================================================================
Descrição-------: Gera a query de dados do relatório.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _nRet = Total de Registros
===============================================================================================================================
*/
User function ROMS097Q()
Local _cQry
Local cFilBloqueio := ""

Begin Sequence
   //==============================================================
   // Define o filtro de acordo com os parametros digitados
   //==============================================================
   ProcRegua(0)
   IncProc("Rodando query de dados...")
      
   cFiltro := ""

   // Filtra Filial da SC5
   If !Empty(AllTrim(MV_PAR01))	
	  If Len(AllTrim(MV_PAR01)) < 5
	     MV_PAR01 := LEFT(MV_PAR01,2)
	     cFiltro  += " AND SC5.C5_FILIAL = '" + MV_PAR01+"' "
      Else
	     cFiltro += " AND SC5.C5_FILIAL IN " + FormatIn(ALLTRIM(MV_PAR01),";")
      EndIf
   EndIf

   //Filtra Emissao da SC5
   If ! Empty(MV_PAR02) .And. !Empty(MV_PAR03)
	  If MV_PAR02 == MV_PAR03
	     cFiltro += " AND SC5.C5_EMISSAO = '" + DTOS(MV_PAR02) + "' "
	  Else
	     cFiltro += " AND SC5.C5_EMISSAO BETWEEN '" + dtos(mv_par02) + "' AND '" + dtos(mv_par03) + "'"
	  EndIf
   EndIf

   //Filtra data Entrega
   If !EMPTY(MV_PAR04) .And. !EMPTY(MV_PAR05)
	  If MV_PAR04 == MV_PAR05
	     cFiltro += " AND SC5.C5_I_DTENT = '" + DTOS(MV_PAR04) + "' "
	  Else
	     cFiltro += " AND SC5.C5_I_DTENT BETWEEN '" + DTOS(MV_PAR04) + "' AND '" + DTOS(MV_PAR05) + "'"
	  EndIf
   EndIf

   //Filtra Produto
   If !EMPTY(MV_PAR06) .And. !EMPTY(MV_PAR07)      
      If MV_PAR06 == MV_PAR07
	     cFiltro += " AND SC6.C6_PRODUTO = '" + mv_par06 + "'"
	  Else    
	     cFiltro += " AND SC6.C6_PRODUTO BETWEEN '" + mv_par06 + "' AND '" + MV_PAR07 + "'"
	  EndIf
   EndIf

   // Filtra Cliente
   If !Empty(mv_par08) .And. !Empty(mv_par10)
	  cFiltro += " AND SC5.C5_CLIENT BETWEEN '" + mv_par08 + "' AND '" + mv_par10 + "'"
   EndIf

   //Filtra Loja Cliente
   If !Empty(mv_par09) .And. !empty(mv_par11)
	  cFiltro += " AND SC5.C5_LOJAENT BETWEEN '" + mv_par09 + "' AND '" + mv_par11 + "'"
   EndIf 

   //Filtra Rede Cliente
   If !Empty(mv_par12)
	  cFiltro += " AND SA1.A1_GRPVEN IN " + FormatIn(mv_par12,";")
   EndIf
     
   //Filtra Estado Cliente
   If ! Empty(mv_par13) 
	  cFiltro += " AND SA1.A1_EST IN " + FormatIn(mv_par13,";")
   EndIf

   //Filtra Cod Municipio Cliente
   If !Empty(mv_par14) 
	  cFiltro += " AND SA1.A1_COD_MUN IN " + FormatIn(mv_par14,";")
   EndIf

   //Filtra Vendedor
   If !Empty(mv_par15) 
	  cFiltro += " AND SA3.A3_COD IN " + FormatIn(mv_par15,";")
   Endif

   //Filtra Coordenador
   If !Empty(mv_par16)
	  cFiltro += " AND SC5.C5_VEND2 IN " + FormatIn(mv_par16,";")
   EndIf

   //Filtra Gerente
   If !Empty(MV_PAR31)
	  cFiltro += " AND SC5.C5_VEND3 IN " + FormatIn(MV_PAR31,";")
   EndIf

   //Filtra Grupo de Produtos
   If !Empty(mv_par17)
	  cFiltro += " AND SBM.BM_GRUPO IN " + FormatIn(mv_par17,";")
   EndIf

   //Filtra Produto Nivel 2
   If !Empty(mv_par18)
	  cFiltro += " AND SB1.B1_I_NIV2 IN " + FormatIn(mv_par18,";")
   EndIf

   //Filtra Produto Nivel 3
   If !empty(mv_par19)
	  cFiltro += " AND SB1.B1_I_NIV3 IN " + FormatIn(mv_par19,";")
   EndIf

   //Filtra Produto Nivel 4
   If !empty(mv_par20)
	  cFiltro += " AND SB1.B1_I_NIV4 IN " + FormatIn(mv_par20,";")
   EndIf

   //Filtra Status Pedido
   If MV_PAR21 == 1 //Pedido Liberados
	  cFiltro += " AND SC5.C5_LIBEROK <> ' ' AND SC5.C5_NOTA = ' ' AND SC5.C5_BLQ = ' '
   ElseIf MV_PAR21 == 2 //Somente Emitidos
	  cFiltro += " AND SC5.C5_LIBEROK = ' ' AND SC5.C5_NOTA = ' ' AND SC5.C5_BLQ = ' ' "  
   EndIf

   //Filtra usuario filial + matricula
   If !empty(MV_PAR23)
	  cFiltro += " AND SC5.C5_I_CDUSU = '" + MV_PAR23 + "' "
   EndIf 

   //busca CFOPS de acordo com parametro definido por usuario	
   If !empty(MV_PAR24)
	  //Senao tiver escolhido 'A' opcao todos
	  If !("A" $ MV_PAR24 )
	     cCfops := U_ITCFOPS(MV_PAR24)
	     cFiltro += " AND SC6.C6_CF IN " + FormatIn(cCfops,";")
	  EndIf
   EndIf

   //Filtra Armazem
   If !empty(MV_PAR25)
	  cFiltro += " AND SC6.C6_LOCAL IN " + FormatIn(MV_PAR25,";")
   EndIf

   //Sub Grupo de Produto
   If !empty(MV_PAR26)
	  cFiltro += " AND SB1.B1_I_SUBGR IN " + FormatIn(MV_PAR26,";")
   EndIf

   //Peso Bruto
   If MV_PAR27 > 0 .Or. MV_PAR28 > 0
	  cFiltro += " AND SC5.C5_I_PESBR BETWEEN " + AllTrim(Str(MV_PAR27)) + " AND " + AllTrim(Str(MV_PAR28)) + " "
   EndIf

   //Tipo de Carga
   If !Empty( MV_PAR29 )
	  cFiltro += " AND SC5.C5_I_TIPCA IN " + FormatIn( AllTrim( MV_PAR29) , ";" )
   EndIf

   //Tipo de Agenda
   If !Empty( MV_PAR30 )
   	  cFiltro += " AND SC5.C5_I_AGEND IN " + FormatIn( AllTrim(MV_PAR30) , ";" )
   EndIf  

   //=========================================================
   //Aqui define expressao de filtro para caso usuario escolher parametro  
   //de pedidos liberados ou todos e escolher motivo de codigo d e bloqueio
   //=========================================================
   If MV_PAR22 <> 5
	  cFilBloqueio := " JOIN " + retSqlName("SC9") + " SC9 ON SC6.C6_NUM = SC9.C9_PEDIDO "
	  cFilBloqueio += " AND SC6.C6_FILIAL = SC9.C9_FILIAL AND SC6.C6_ITEM = SC9.C9_ITEM "
	  cFilBloqueio += " AND SC9.D_E_L_E_T_ = ' ' "
   EndIf

   If MV_PAR22 == 1    // Bloqueio Credito
      cFilBloqueio += " AND SC9.C9_BLCRED = '01' "
   ElseIf MV_PAR22 == 2 // Bloqueio Estoque
      cFilBloqueio += " AND SC9.C9_BLEST = '02' And SC9.C9_BLCRED <> '01' "
   Elseif MV_PAR22 == 3 // Bloqueio Credito ou Estoque
      cFilBloqueio += " AND ( (SC9.C9_BLCRED = '01') OR (SC9.C9_BLEST = '02') ) "
   Elseif MV_PAR22 == 4 // Liberados
      cFilBloqueio += " AND SC9.C9_BLEST = ' ' AND SC9.C9_BLCRED = ' ' "
   Endif

   _cQry := "SELECT DISTINCT SC5.R_E_C_N_O_ NRRECNO " // Recno do Registro Tabela SC5.   
   _cQry += " FROM " + RETSQLNAME("SC5") + " SC5 "
   _cQry += " JOIN " + RETSQLNAME("SC6") + " SC6 ON SC6.C6_FILIAL = SC5.C5_FILIAL  AND SC6.C6_NUM = SC5.C5_NUM "
     
   If ! Empty(cFilBloqueio)       
      _cQry += cFilBloqueio
   EndIf
	
   _cQry += "  JOIN  " + RETSQLNAME("SA1") + " SA1 ON SA1.A1_FILIAL  = ' ' AND SC5.C5_CLIENT = SA1.A1_COD AND SC5.C5_LOJAENT = SA1.A1_LOJA "
   _cQry += "  JOIN  " + RETSQLNAME("SB1") + " SB1 ON SB1.B1_FILIAL  = ' ' AND SB1.B1_COD = SC6.C6_PRODUTO "
   _cQry += "  JOIN  " + RETSQLNAME("SA3") + " SA3 ON SA3.A3_FILIAL  = ' ' AND SA3.A3_COD = SC5.C5_VEND1 "
   _cQry += "  JOIN  " + RETSQLNAME("SBM") + " SBM ON SBM.BM_FILIAL  = ' ' AND SBM.BM_GRUPO = SB1.B1_GRUPO
   _cQry += "  JOIN  " + RETSQLNAME("ACY") + " ACY ON ACY.ACY_FILIAL = ' ' AND ACY.ACY_GRPVEN	= SA1.A1_GRPVEN "
   _cQry += "  LEFT JOIN " + RETSQLNAME("ZF8") + " ZF8 ON ZF8.ZF8_FILPED = SC5.C5_FILIAL AND ZF8.ZF8_NUMPED = SC5.C5_NUM AND ZF8.D_E_L_E_T_ = ' ' "
   _cQry += "  WHERE 
   _cQry += "  SC5.D_E_L_E_T_ = ' ' "
   _cQry += "  AND SC6.D_E_L_E_T_ = ' ' "
   _cQry += "  AND SA1.D_E_L_E_T_ = ' ' "
   _cQry += "  AND SB1.D_E_L_E_T_ = ' ' "
   _cQry += "  AND SA3.D_E_L_E_T_ = ' ' " 											
   _cQry += "  AND SBM.D_E_L_E_T_ = ' ' "			
   _cQry += "  AND ACY.D_E_L_E_T_ = ' ' "
   _cQry += "  AND SC6.C6_QTDVEN <> SC6.C6_QTDENT
   _cQry += "  AND SC6.C6_BLQ <> 'R'
   //_cQry += "  AND NOT EXISTS (SELECT C9_PEDIDO FROM " + RETSQLNAME("SC9") + " SC9 WHERE SC9.D_E_L_E_T_ = ' ' " 
   //_cQry += "  AND SC9.C9_FILIAL = SC5.C5_FILIAL AND SC5.C5_NUM = SC9.C9_PEDIDO ) "   
    
    If ! Empty(cFiltro)
	   _cQry += cFiltro
    EndIf

   If Select("QRYSC5") > 0
      QRYSC5->(DbCloseArea())
   EndIf

   //DBUseArea( .T. , "TOPCONN" , TCGenQry( ,, _cQry ) , "QRYSC5" , .F. , .T. )
   MPSysOpenQuery( _cQry , "QRYSC5")
   DbSelectArea("QRYSC5")
   
   Count To _nRet 
   
   _nTotRegs := _nRet

End Sequence

Return _nRet 

/*
===============================================================================================================================
Programa--------: AOMS097G
Autor-----------: Julio de Paula Paz
Data da Criacao-: 15/07/2019
===============================================================================================================================
Descrição-------: Grava os dados das querys na tabela temporária.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _nRet = Total de Registros
===============================================================================================================================
*/
User function AOMS097G(_nTotRegs) 
Local _nI, _nTotCampos
Local _nJ, _cContexto, _cRelacao
Local _cCampo, _cFilBack := cFilAnt

Begin Sequence
   ProcRegua(_nTotRegs)
   _nTotCampos := SC5->(FCount())
   
   _nJ := 0

   ZY3->(DbSetOrder(2)) // ZY3_NUMPV
   ZY8->(DbSetOrder(2)) // ZY8_NUMPV
   
   QRYSC5->(DbGoTop())

   Do While ! QRYSC5->(Eof())
      _nJ += 1
      
	  //===================================================================
	  // Grava na tabela temporaria TRBSC5 os dados dos Pedidos de Vendas.
	  //===================================================================
      IncProc("Carregando dados dos Pedidos: " + StrZero(_nJ,6) + "/" + StrZero(_nTotRegs,6))
      SC5->(DbGoTo(QRYSC5->NRRECNO))
      
	  cFilAnt := SC5->C5_FILIAL
/*
	  For _nI := 1 To _nTotCampos
	      
         If AllTrim(TRBSC5->(FieldName(_nI))) $ "WK_RECNO/C5_ALI_WT/C5_REC_WT/WK_OK/WK_LEGENDA" .Or.;
            Empty(TRBSC5->(FieldName(_nI))) .OR.;
            SC5->(FIELDPOS(TRBSC5->(FieldName(_nI)))) = 0 
		      Loop			  
         EndIf
          
		  _cCampo := TRBSC5->(FieldName(_nI))
		  _cContexto := GetSx3Cache(_cCampo,"X3_CONTEXT")
          If _cContexto <> "V" 
		     &("M->"+_cCampo) := &("SC5->"+ _cCampo)
		  EndIf
	  Next*/
     _nTotCampos := TRBSC5->(FCount())//SC5->(FCount())
     TRBSC5->(DBAPPEND())//RecLock("TRBSC5",.T.))
      
	  For _nI := 1 To _nTotCampos
		  _cCampo := TRBSC5->(FieldName(_nI))
	     If AllTrim(_cCampo) $ "WK_RECNO/C5_ALI_WT/C5_REC_WT/WK_OK/WK_LEGENDA" .Or.;
           Empty(_cCampo)//.OR.;
           //SC5->(FIELDPOS(_cCampo)) = 0 
		     Loop			  
        EndIf
          
		  _cContexto := GetSx3Cache(_cCampo,"X3_CONTEXT")
        If _cContexto == "V" 
		     _cRelacao := GetSx3Cache(_cCampo,"X3_RELACAO")
			  If ! Empty(_cRelacao)
              &("TRBSC5->"+_cCampo) := &(_cRelacao)  
			  EndIf 
		  ElseIF SC5->(FIELDPOS(_cCampo)) <> 0 
		     &("TRBSC5->"+_cCampo) := &("SC5->"+ _cCampo)
		  EndIf
	  Next
     TRBSC5->C5_ASSNOM:=SC5->C5_ASSNOM
     TRBSC5->C5_ASSCOD:=SC5->C5_ASSCOD
     IF !EMPTY(SC5->C5_ASSCOD)
        TRBSC5->ZPG_EMAIL:=ALLTRIM(POSICIONE("ZPG",1,xFilial("ZPG")+SC5->C5_ASSCOD,"ZPG_EMAIL"))
     ENDIF
     TRBSC5->C5_FILIAL  := SC5->C5_FILIAL
     TRBSC5->WK_RECNO   := SC5->(RECNO())
	  //TRBSC5->(MsUnLock())
     
     //===================================================================
     // Gravando o código da legenda em TRBSC5
     // Colocado após TRBSC5->(MsUnLock()) para efetivação do Buffer.
     // A função AOMS097R() utiliza campos da tabela TRBSC5.
     //===================================================================
     //TRBSC5->(RecLock("TRBSC5",.F.))  
     TRBSC5->WK_LEGENDA := U_AOMS097R()
     //TRBSC5->(MsUnLock())

	  //===================================================================
	  // Grava na tabela temporária TRBZY3 os dados dos Pedidos de Vendas.
	  //=================================================================== 
     _nTotCampos := TRBZY3->(FCount()) 

      ZY3->(DbSeek(SC5->C5_NUM))
      Do While ! ZY3->(Eof()) .And. SC5->C5_NUM == ZY3->ZY3_NUMPV
	     TRBZY3->(DBAPPEND())//RecLock("TRBZY3",.T.))
         For _nI := 1 To _nTotCampos
		     
			    If AllTrim(TRBZY3->(FieldName(_nI))) $ "WK_RECNO/ZY3_ALI_WT/ZY3_REC_WT/WKRECTRBY3" .Or. Empty(TRBZY3->(FieldName(_nI)))
		          Loop			  
             EndIf

			    _cCampo := TRBZY3->(FieldName(_nI))
		       _cContexto := GetSx3Cache(_cCampo,"X3_CONTEXT")
             If _cContexto == "V" 
		          _cRelacao := GetSx3Cache(_cCampo,"X3_RELACAO")
			       If ! Empty(_cRelacao)
                   &("TRBZY3->"+_cCampo) := &(_cRelacao)  
			       EndIf 
		       Else
                &("TRBZY3->"+_cCampo) := &("ZY3->"+ _cCampo)
		       EndIf

			    If AllTrim(_cCampo) == "ZY3_JUSCOD"
                TRBZY3->ZY3_JUSDES := POSICIONE("ZY5",1,xFilial("ZY5")+ZY3->ZY3_JUSCOD,"ZY5_DESCR") 
		        EndIf
	      Next
         TRBZY3->ZY3_ALI_WT := "ZY3"
		   TRBZY3->ZY3_REC_WT := ZY3->(RECNO())
         TRBZY3->WK_RECNO   := ZY3->(RECNO())
	      //TRBZY3->(MsUnLock())

         ZY3->(DbSkip())
      EndDo
      
      //===================================================================
	   // Grava na tabela temporária TRBZY8 os dados dos Pedidos de Vendas.
	   //=================================================================== 
      _nTotCampos := TRBZY8->(FCount()) 
      
      ZY8->(DbSetOrder(2))
      ZY8->(DbSeek(SC5->C5_NUM))
      Do While ! ZY8->(Eof()) .And. SC5->C5_NUM == ZY8->ZY8_NUMPV
	     TRBZY8->(DBAPPEND())//RecLock("TRBZY8",.T.))
         For _nI := 1 To _nTotCampos
		     
			    If AllTrim(TRBZY8->(FieldName(_nI))) $ "WK_RECNO/ZY8_ALI_WT/ZY8_REC_WT/WKRECTRBY8/WK_OK" .Or. Empty(TRBZY8->(FieldName(_nI)))
		          Loop			  
             EndIf

			    _cCampo := TRBZY8->(FieldName(_nI))
		       _cContexto := GetSx3Cache(_cCampo,"X3_CONTEXT")
             If _cContexto == "V" 
		          _cRelacao := GetSx3Cache(_cCampo,"X3_RELACAO")
			       If ! Empty(_cRelacao)
                   &("TRBZY8->"+_cCampo) := &(_cRelacao)  
			       EndIf 
		       Else
                &("TRBZY8->"+_cCampo) := &("ZY8->"+ _cCampo)
		       EndIf

			    If AllTrim(_cCampo) == "ZY8_JUSCOD"
                TRBZY8->ZY8_JUSDES := POSICIONE("ZY5",1,xFilial("ZY5")+ZY8->ZY8_JUSCOD,"ZY5_DESCR") 
		        EndIf
	      Next
         TRBZY8->ZY8_ALI_WT := "ZY8"
		   TRBZY8->ZY8_REC_WT := ZY8->(RECNO())
         TRBZY8->WK_RECNO   := ZY8->(RECNO())
	      TRBZY8->(MsUnLock())

         ZY8->(DbSkip())
      EndDo
      ZY8->(DbSetOrder(1))

      QrySC5->(DbSkip())
   EndDo

End Sequence

cFilAnt := _cFilBack

Return Nil

/*
===============================================================================================================================
Programa--------: AOMS097R
Autor-----------: Julio de Paula Paz
Data da Criacao-: 13/08/2019
===============================================================================================================================
Descrição-------: Define as legendas dos pedidos de vendas.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: 
===============================================================================================================================
*/
User function AOMS097R()
Local _cRet := " "
Local _lPosicionou
Local _cCond1, _cCond2 , _cCond3 , _cCond4 , _cCond5

Begin Sequence          //              Filial     + Estado + Cod. Municip + Armazem  
   ZG5->(DbSetOrder(1)) // ZG5_FILIAL + ZG5_FILORI + ZG5_UF + ZG5_CODMUN   + ZG5_LOCAL 

   _lPosicionou := .F.
   
   If ZG5->(DbSeek(xFilial("ZG5")+TRBSC5->C5_FILIAL+TRBSC5->C5_I_EST+TRBSC5->C5_I_CMUN))  
      _lPosicionou := .T.
   ElseIf ZG5->(DbSeek(xFilial("ZG5")+TRBSC5->C5_FILIAL+TRBSC5->C5_I_EST))  
      _lPosicionou := .T.
   EndIf

   If _lPosicionou
      _cCond1 := ZG5->ZG5_COND1
      _cCond2 := ZG5->ZG5_COND2
      _cCond3 := ZG5->ZG5_COND3
      _cCond4 := ZG5->ZG5_COND4
      _cCond5 := ZG5->ZG5_COND5

      If &(_cCond1)
         _cRet := ZG5->ZG5_LEGCD1
      ElseIf &(_cCond2)
         _cRet := ZG5->ZG5_LEGCD2
      ElseIf &(_cCond3)
         _cRet := ZG5->ZG5_LEGCD3 
      ElseIf &(_cCond4)
         _cRet := ZG5->ZG5_LEGCD4
      ElseIf &(_cCond5)
         _cRet := ZG5->ZG5_LEGCD5
      EndIf
   EndIf

End Sequence

Return _cRet 

/*
=================================================================================================================================
Programa--------: AOMS097T()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 15/08/2019
=================================================================================================================================
Descrição-------: Tela de manutenção de Gestão de Carteira.
=================================================================================================================================
Parametros------: Nenhum
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AOMS097T(_cOpc)
Local _aSizeAut  := MsAdvSize(.T.)
Local _bOk, _bCancel , _cTitulo
Local _nI
Local _nReg := 2 , _nOpcx := 2
Local _cAcao,_ACmpEdit 
Local _lRet := .T.

Private aHeader := {} , aCols := {}
Private _cGrpAuto := U_ItGetMv("IT_JUSTAUT","007,008,010,012,013,014")
Private _oDlgE

Begin Sequence     
   
   aHeader := AClone(_aHeadZY3)

   If _cOpc == "I"
      _cAcao := "Inclusão"
	  _nOpcx := 3
   ElseIf _cOpc == "A"
      _cAcao := "Alteração"
	  _nOpcx := 4
   ElseIf _cOpc == "V"
      _cAcao := "Visualização"    
	  _nOpcx := 4   
   EndIf

   //================================================================================
   // Carrega os dados da tabela ZY3
   //================================================================================
   If _cOpc == "I"
      _ACmpEdit := {}
      For _nI := 1 To ZY3->(FCount())
          //&("M->"+ZY3->(FieldName(_nI))) :=  &("ZY3->"+ZY3->(FieldName(_nI)))
	      If ! AllTrim(ZY3->(FieldName(_nI))) $ "ZY3_DTFAT/ZY3_DTFOLD"
             &("M->"+ZY3->(FieldName(_nI))) :=  CriaVar(ZY3->(FieldName(_nI)))
	      EndIf
     
	      If ! AllTrim(ZY3->(FieldName(_nI))) $ "ZY3_NUMPV/ZY3_SEQUEN"
  	         Aadd(_ACmpEdit, ZY3->(FieldName(_nI)))
	      EndIf 
      Next 

      M->ZY3_NUMPV := TRBSC5->C5_NUM
      M->ZY3_SEQUEN := U_AOMS097E()
   Else
      If GDBZY3->(Eof()) .Or. GDBZY3->(Bof())
         U_ItMsg('Não existem dados selecionados para a opção: ' +  _cAcao,"Atenção",,1)
		   Break
	   EndIf

      TRBZY3->(DbGoTo(GDBZY3->WKRECTRBY3)) // Posiciona na tabela temporária TRBZY3.

      For _nI := 1 To TRBZY3->(FCount())
	  
          &("M->"+TRBZY3->(FieldName(_nI))) :=  &("TRBZY3->"+TRBZY3->(FieldName(_nI)) )

		  If AllTrim(TRBZY3->(FieldName(_nI))) == "ZY3_JUSCOD"
             TRBZY3->ZY3_JUSDES := POSICIONE("ZY5",1,xFilial("ZY5")+TRBZY3->ZY3_JUSCOD,"ZY5_DESCR") 
			 &("M->"+TRBZY3->(FieldName(_nI))) := TRBZY3->ZY3_JUSDES
		  EndIf
      Next 
   EndIf

   //================================================================================
   // Monta a tela Enchoice ZY3
   //================================================================================    
   _aObjects := {} 
   AAdd( _aObjects, { 315,  50, .T., .T. } )
   //AAdd( _aObjects, { 100, 100, .T., .T. } )

   _aInfo := { _aSizeAut[ 1 ], _aSizeAut[ 2 ], _aSizeAut[ 3 ], _aSizeAut[ 4 ], 3, 3 } 

   _aPosObj := MsObjSize( _aInfo, _aObjects, .T. ) 
   
   _bOk := {|| _lRet := .T. , _oDlgE:End()}
   _bCancel := {|| _lRet := .F., _oDlgE:End()}
                       
   _cTitulo := "Manutenção da Gestão de Carteira - " + _cAcao
   
   Define MsDialog _oDlgE Title _cTitulo From _aSizeAut[7],00 To _aSizeAut[6], _aSizeAut[5] Of oMainWnd Pixel 
             //   1      2      3     4  5  6  7    8              9
      EnChoice( "ZY3" ,_nReg, _nOpcx,  ,  ,  ,  , _aPosObj[1], _ACmpEdit , 3 )
      
	  M->ZY3_JUSCOD := TRBZY3->ZY3_JUSCOD 
	  M->ZY3_JUSDES := TRBZY3->ZY3_JUSDES 
       
   Activate MsDialog _oDlgE On Init EnchoiceBar(_oDlgE,_bOk,_bCancel) 
   
   If _cOpc == "I" .Or. _cOpc == "A"
      If _lRet
         If ! U_ITMSG("Confirma a " + _cAcao + " de dados?","Atenção" , ,3,2, 2)
            Break
	      Endif
         
		    If _cOpc == "I" 
		       TRBZY3->(DBAPPEND())//RecLock("TRBZY3", .T.))
		       For _nI := 1 To TRBZY3->(FCount())
			        If ! AllTrim(TRBZY3->(FieldName(_nI))) $ "ZY3_JUSDES/WK_RECNO/ZY3_ALI_WT/ZY3_REC_WT"
                    &("TRBZY3->"+TRBZY3->(FieldName(_nI)) ) := &("M->"+TRBZY3->(FieldName(_nI)))
                 EndIf
             Next 
             TRBZY3->ZY3_JUSDES := POSICIONE("ZY5",1,xFilial("ZY5")+M->ZY3_JUSCOD,"ZY5_DESCR") 
             TRBZY3->ZY3_FILFT  := TRBSC5->C5_FILIAL
             TRBZY3->ZY3_DTFOLD := TRBSC5->C5_I_DTENT // Stod(TRBSC5->C5_I_DTENT)
			    TRBZY3->ZY3_ORIGEM:= FUNNAME()
			    //TRBZY3->(MsUnLock())

             GDBZY3->(DBAPPEND())//RecLock("GDBZY3", .T.))
		       For _nI := 1 To GDBZY3->(FCount())
			        If ! AllTrim(GDBZY3->(FieldName(_nI))) $ "ZY3_JUSDES/WK_RECNO/ZY3_ALI_WT/ZY3_REC_WT"
                    &("GDBZY3->"+GDBZY3->(FieldName(_nI)) ) := &("M->"+GDBZY3->(FieldName(_nI)))
                 EndIf

		           If AllTrim(GDBZY3->(FieldName(_nI))) == "ZY3_JUSCOD"
                    GDBZY3->ZY3_JUSDES := POSICIONE("ZY5",1,xFilial("ZY5")+M->ZY3_JUSCOD,"ZY5_DESCR") 
			        EndIf
             Next 
             GDBZY3->ZY3_FILFT  := TRBSC5->C5_FILIAL
             GDBZY3->ZY3_DTFOLD := TRBSC5->C5_I_DTENT // Stod(TRBSC5->C5_I_DTENT)
			    GDBZY3->ZY3_ORIGEM := FUNNAME()
			    //GDBZY3->(MsUnLock())

			    ZY3->(RecLock("ZY3", .T.))
			    For _nI := 1 To TRBZY3->(FCount())
                 If ! AllTrim(TRBZY3->(FieldName(_nI))) $ "ZY3_JUSDES/WK_RECNO/ZY3_ALI_WT/ZY3_REC_WT/WKRECTRBY3"
			           &("ZY3->"+TRBZY3->(FieldName(_nI)) ) := &("M->"+TRBZY3->(FieldName(_nI)))
			        EndIf
             Next
         
             ZY3->ZY3_FILIAL := xFilial("ZY3")
             ZY3->ZY3_FILFT  := TRBSC5->C5_FILIAL
			    ZY3->ZY3_DTFOLD := TRBSC5->C5_I_DTENT
			    ZY3->ZY3_ORIGEM := FUNNAME()
			    ZY3->(MsUnLock()) 

			    //TRBZY3->(RecLock("TRBZY3", .F.)) 
			    TRBZY3->WK_RECNO := ZY3->(Recno())
             //TRBZY3->(MsUnlock())
		    Else
		       //TRBZY3->(RecLock("TRBZY3", .F.)) 
			    TRBZY3->ZY3_COMENT := M->ZY3_COMENT
			    TRBZY3->ZY3_JUSCOD := M->ZY3_JUSCOD
			    TRBZY3->ZY3_JUSDES := POSICIONE("ZY5",1,xFilial("ZY5")+M->ZY3_JUSCOD,"ZY5_DESCR") 
             //TRBZY3->(MsUnlock()) 

             ///GDBZY3->(RecLock("GDBZY3", .F.)) 
			    GDBZY3->ZY3_COMENT := M->ZY3_COMENT
			    GDBZY3->ZY3_JUSCOD := M->ZY3_JUSCOD
			    GDBZY3->ZY3_JUSDES := POSICIONE("ZY5",1,xFilial("ZY5")+M->ZY3_JUSCOD,"ZY5_DESCR") 
             //GDBZY3->(MsUnlock()) 

			    ZY3->(DbGoTo(TRBZY3->WK_RECNO))
			    ZY3->(RecLock("ZY3", .F.)) 
             ZY3->ZY3_COMENT := M->ZY3_COMENT
			    ZY3->ZY3_JUSCOD := M->ZY3_JUSCOD
			    ZY3->(MsUnlock()) 
		    EndIf
          
          GDBZY3->(DbGoTop())
          
          If ValType(_oMarkZY3) == "O" 
             _oMarkZY3:oBrowse:Refresh()
          EndIf 
      EndIf
   EndIf

End Sequence

Return Nil

/*
=================================================================================================================================
Programa--------: AOMS097E()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 15/08/2019
=================================================================================================================================
Descrição-------: Retorna a sequencia para o proximo item da gestão de carteira.
=================================================================================================================================
Parametros------: Nenhum
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AOMS097E()
Local _cRet := ""
Local _cSeq := "000"

Begin Sequence
   TRBZY3->(DbGoTop())
   Do While ! TRBZY3->(Eof())
      If _cSeq < TRBZY3->ZY3_SEQUEN
         _cSeq := TRBZY3->ZY3_SEQUEN
	  EndIf

      TRBZY3->(DbSkip())
   EndDo

End Sequence

_cRet := Soma1(_cSeq)

Return (_cRet)

/*
=================================================================================================================================
Programa--------: AOMS097Q
Autor-----------: Julio de Paula Paz
Data da Criacao-: 19/08/2019
=================================================================================================================================
Descrição-------: Permite pesquisar um pedido de vendas na tela. 
=================================================================================================================================
Parametros------: Nenhum
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AOMS097Q()
Local _bOk, _bCancel
Local _lRet := .T.
Local _cPedido := U_ITKEY(" ","C5_NUM")
Local _nRegAtu := TRBSC5->(Recno())

Begin Sequence
   _bOk := {|| _lRet := .T., _oDlgQ:End()}
   _bCancel := {|| _lRet := .F., _oDlgQ:End()}
                       
   _cTitulo := "Manutenção Gestão de Carteira - Pesquisar"
   
   _cPedido := _cPedido + Space(2)

   Define MsDialog _oDlgQ Title _cTitulo From 0,0 To 10, 50 Of oMainWnd 

      @ 040,010 SAY "Nr.Pedido + Filial:"	SIZE 065,010 PIXEL OF _oDlgQ 
      @ 040,060 MSGET _cPedido PICTURE "@!"	SIZE 40,010 PIXEL OF _oDlgQ

   Activate MsDialog _oDlgQ On Init EnchoiceBar(_oDlgQ,_bOk,_bCancel) CENTERED 

   If _lRet
      TRBSC5->(DbGoTop())

      If TRBSC5->(DbSeek(RTrim(_cPedido)))
         _oMarkSC5:OBrowse:Refresh() 
	  Else
         U_ItMsg('O numero de Pedido de Vendas + Filial, não foi localizado.',"Atenção",,1)
		 TRBSC5->(DbGoTo(_nRegAtu))
	  EndIf

   EndIf

End Sequence

Return Nil

/*
=================================================================================================================================
Programa--------: AOMS097W
Autor-----------: Julio de Paula Paz
Data da Criacao-: 20/08/2019
=================================================================================================================================
Descrição-------: Validar a digitação das datas de entrega para alteração dos pedidos de vendas.
=================================================================================================================================
Parametros------: _dNovaData = Nova data de entrega
                  _lSoStatus = .F. = Testa data e Status do PV
                  _lSoStatus = .T. = Testa somente Status do PV
=================================================================================================================================
Retorno---------: _lRet = .T. = Nova data e pedidos selecionados corretos.
                  _lRet = .F. = Nova Data e Pedidos selecionados incorretos.
=================================================================================================================================
*/ 
User Function AOMS097W(_dNovaData,_lSoStatus,oProcW,_cChamado)// CHAMADA DO PROGRAMA AOMS026.PRW TB
Local _lRet := .T.
Local _nRegAtu := TRBSC5->(Recno())
Local _lRegMarca := .F.
Local _aRejeito := {}
Local _aBackHeader := Aclone(aHeader)
Local _aBackACols  := Aclone(aCols)
Local _cFilCarreg := ""

IF _cChamado = "DT_ENTREGA"
   If ( EMPTY(_dNovaData) .OR. _dNovaData < DATE() ) 
      U_ITMSG("Data de Entrega precisa ser preenchida maior ou igual a hoje.","Atenção",,1)
      RETURN .F.
   Endif
ENDIF

IF ISINCALLSTACK( "U_AOMS026" )
   _lRet:=.T.
   if  SC5->C5_I_ENVRD = "S"//Testa O STATUS DO PV
       _cQry:="SELECT STATUS FROM RDCITL.TGA447 WHERE PEDIDO = '" + ALLTRIM(SC5->C5_NUM) + "' "
       //dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBPED" , .T., .F. )
       MPSysOpenQuery( _cQry , "TRBPED")
       DBSELECTAREA( "TRBPED" )

       If !TRBPED->(EOF())
          IF ALLTRIM(TRBPED->STATUS) <> "1"
             U_ITMSG('O Pedido está no RDC com Status ('+TRBPED->STATUS+') "Em Montagem de Carga.","Atenção","Por favor entrar em contato com Logística.',1)
             _lRet:=.F.
          ENDIF
       ELSE
          U_ITMSG('O Pedido NÃO FOI ENCONTRADO no RDC.","Atenção","Por favor entrar em contato com Logística.',1)
          _lRet:=.F.
       ENDIF 
       TRBPED->(Dbclosearea())
       DBSELECTAREA( "SC5" )
   ENDIF
   RETURN _lRet
ENDIF

_nConta:=0
_nRejeitados:=0
IF VALTYPE(oProcW) = "O"
   oProcW:cCaption := ("Pedidos Validados: "+ALLTRIM(STR(_nConta))+" - Rejeitados: "+ALLTRIM(STR(_nRejeitados)))
   ProcessMessages()
ENDIF
Begin Sequence
   TRBSC5->(DbGoTop())
   _cTimeIni:="H.I.: "+TIME()
   Do While ! TRBSC5->(Eof()) 
      
      If ! Empty(TRBSC5->WK_OK)

         _nConta++
         IF VALTYPE(oProcW) = "O"
            oProcW:cCaption := (_cTimeIni+"-Pedidos lidos: "+ALLTRIM(STR(_nConta))+" - Rejeitados: "+ALLTRIM(STR(_nRejeitados)))
            ProcessMessages()
         ENDIF
        
         _lRegMarca := .T.
         _lPedidoOK := .T.
         if !_lSoStatus//Testa data e Status do PV
            If !TRBSC5->C5_I_AGEND $ "I/O" .AND. !TRBSC5->C5_I_AGEND $ "M/A" .AND. !U_ITVACESS( 'ZZL' , 3 , 'ZZL_MNTDTE' , 'N' )
               //aHeader := {}
               //aCols := {}
               //FillGetDados(1,"SC6",1,,,{||.T.}, , /*_aCampoSC5*/,,,,.T.)
               
               _cFilCarreg := TRBSC5->C5_FILIAL
               If ! Empty(TRBSC5->C5_I_FLFNC)
                  _cFilCarreg := TRBSC5->C5_I_FLFNC
               EndIf
               _cObs:=""//Preenche dentro da funcão U_OMSVLDENT()
               If ! U_OMSVLDENT(_dNovaData,TRBSC5->C5_CLIENTE,TRBSC5->C5_LOJACLI,TRBSC5->C5_I_FILFT,TRBSC5->C5_NUM,0,.F.,_cFilCarreg,TRBSC5->C5_I_OPER,TRBSC5->C5_I_TPVEN)
                  Aadd(_aRejeito,{.F.,IF(EMPTY(TRBSC5->C5_I_FILFT),TRBSC5->C5_FILIAL,TRBSC5->C5_I_FILFT),;
                                  TRBSC5->C5_NUM,;
                                  TRBSC5->C5_I_AGEND+"-"+U_TipoEntrega(TRBSC5->C5_I_AGEND), _dNovaData,;
                                  TRBSC5->C5_CLIENTE,;
                                  TRBSC5->C5_LOJACLI,;
                                  IF(TRBSC5->C5_I_ENVRD="S","Sim","Não"),;
                                  'A nova data informada não é válida para esse PV. ['+_cObs+'] [PV FOI DESMARCADO]'})
                   _lPedidoOK := .F.
                   _nRejeitados++
		         EndIf
            EndIf
         ELSE
            SC5->(DbGoto(TRBSC5->WK_RECNO))   
            If _cTpAgenda $ "I/O"    
               _dDtEntrega:=Date()+U_OMSVLDENT(SC5->C5_I_DTENT,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_FILIAL,SC5->C5_NUM,1,,SC5->C5_FILIAL,SC5->C5_I_OPER,SC5->C5_I_TPVEN)
            ELSE
               _dDtEntrega:=SC5->C5_I_DTENT
            ENDIF            
         ENDIF
         
         if  TRBSC5->C5_I_ENVRD = "S"//Testa O STATUS DO PV
  		       _cQry:="SELECT STATUS FROM RDCITL.TGA447 WHERE PEDIDO = '" + ALLTRIM(TRBSC5->C5_NUM) + "' "
		       //dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBPED" , .T., .F. )
             MPSysOpenQuery( _cQry , "TRBPED")
             DBSELECTAREA( "TRBPED" )

		       If !TRBPED->(EOF())
                IF ALLTRIM(TRBPED->STATUS) <> "1"
                   AADD(_aRejeito,{.F.,IF(EMPTY(TRBSC5->C5_I_FILFT),TRBSC5->C5_FILIAL,TRBSC5->C5_I_FILFT),;
                                   TRBSC5->C5_NUM,;
                                   TRBSC5->C5_I_AGEND+"-"+U_TipoEntrega(TRBSC5->C5_I_AGEND),_dNovaData,;
                                   TRBSC5->C5_CLIENTE,;
                                   TRBSC5->C5_LOJACLI,;
                                   "Sim",;
                                   'O Pedido está no RDC com Status ('+TRBPED->STATUS+') "Em Montagem de Carga", por favor entrar em contato com Logística. [PV FOI DESMARCADO]'})
                   _lPedidoOK := .F.
                   _nRejeitados++
                ENDIF
             ELSE
                   AADD(_aRejeito,{.F.,IF(EMPTY(TRBSC5->C5_I_FILFT),TRBSC5->C5_FILIAL,TRBSC5->C5_I_FILFT),;
                                   TRBSC5->C5_NUM,;
                                   TRBSC5->C5_I_AGEND+"-"+U_TipoEntrega(TRBSC5->C5_I_AGEND), _dNovaData,;
                                   TRBSC5->C5_CLIENTE,;
                                   TRBSC5->C5_LOJACLI,;
                                   "Sim",;
                                   'O Pedido NÃO FOI ENCONTRADO no RDC, por favor entrar em contato com Logística. [PV FOI DESMARCADO]'})
                   _lPedidoOK := .F.
                   _nRejeitados++
             ENDIF 
             TRBPED->(Dbclosearea())
             DBSELECTAREA( "TRBSC5" )
         ENDIF
         IF _lPedidoOK
            Aadd(_aRejeito,{.T.,IF(EMPTY(TRBSC5->C5_I_FILFT),TRBSC5->C5_FILIAL,TRBSC5->C5_I_FILFT),;
                            TRBSC5->C5_NUM,;
                            TRBSC5->C5_I_AGEND+"-"+U_TipoEntrega(TRBSC5->C5_I_AGEND), _dNovaData,;
                            TRBSC5->C5_CLIENTE,;
                            TRBSC5->C5_LOJACLI,;
                            IF(TRBSC5->C5_I_ENVRD="S","Sim","Não"),;
                            'Pedido Aceito'})
         ELSE 
            TRBSC5->WK_OK:=""
         ENDIF

	  EndIf //If ! Empty(TRBSC5->WK_OK)

	  TRBSC5->(DbSkip())
   EndDo
   
   If ! _lRegMarca
      U_ItMsg('Nenhum pedido de vendas foi selecionado para alteração da data de entrega.',"Atenção",,1)
	  _lRet := .F.
	  Break
   EndIf

   DO WHILE _nRejeitados > 0
      
      _cTit:='LISTA DE PEDIDOS DE VENDAS MARCADOS A PROCESSAR E REJEITADOS.'
      _cMsg:="Pedidos Aceitos: "+ALLTRIM(STR(_nConta))+" - Rejeitados: "+ALLTRIM(STR(_nRejeitados)) 
      _aCab:={"","Filial Faturamento","Pedido de Vendas","Tipo Entrega", "Data Entrega","Cliente","Loja","RDC?","Alteração não permitida pq: "}

                              // _aCab, _aCols   ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,aSizes, _nCampo , bOk , bCancel, _abuttons )
      _lRet :=U_ITListBox(_cTit ,_aCab,_aRejeito ,.T.     ,4      ,_cMsg)      

      IF  _lRet 
          IF !U_ITMSG("Confirma gravar as alterações SOMENTE dos pedidos ACEITOS ?",'Atenção!',,2,2,2)
             LOOP
          ENDIF   
      ELSEIF !U_ITMSG("AO SAIR TODOS AS VALIDAÇÕES SERÃO REFEITAS AO CONFIRMAR DE NOVO, Confirmar SAIDA ?",'Atenção!',,3,2,2)
          LOOP
      ENDIF

      EXIT
   
   ENDDO

End Sequence

TRBSC5->(DbGoTo(_nRegAtu))
aHeader := AClone(_aBackHeader)
aCols   := AClone(_aBackACols)

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS097A
Autor-------------: Julio de Paula Paz
Data da Criacao---: 22/08/2019
===============================================================================================================================
Descrição---------: Rotina para alteração do tipo de agendamento.
===============================================================================================================================
Parametros--------: oProc2
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS097A(oProc2 As Object) As Logical
Local aArea		 := GetArea() As Array
Local nOpc		 := 0 As Numeric, _oDlg2 As Object
Local _lAlterou := .F. As Logical
Local _nRegAtu  := TRBSC5->(Recno()) As Numeric
Local _aTpAgenda:= U_TipoEntrega() As Array //{"A=AGENDADA","I=IMEDIATA","M=AGENDADA C/MULTA","P=AGUARD. AGENDA","R=REAGENDAR","N=REAGENDAR C/MULTA"}
Local nLinha    := 10 As Numeric
Local _nCol1    := 04 As Numeric
Local _nCol2    := 62 As Numeric
Local _nCol3    := 90 As Numeric
Local _nTam     := 285 As Numeric

_cJustAG := Space(3) // _aJustAG[1]
_cObseAG := SPACE(LEN(ZY3->ZY3_OBSERV))
_cTpAgenda:=_aTpAgenda[1]

_aFoders:={}
AADD(_aFoders,"Alterar Tipo Agendamento")

Begin Sequence


   DEFINE MSDIALOG _oDlg2 TITLE "Gestão de Carteira - Pedido de Vendas " From 0,0 To 280, 700 PIXEL
                                                                       
	_nColFolder:=350
   _nLinFolder:=100
	nLinha:=1
   nOpc  :=0

   oTFolder1:= TFolder():New( nLinha,1,_aFoders,,_oDlg2,,,,.T., , _nColFolder,_nLinFolder )

   nLinha:=5
	@ nLinha+3, _nCol1 SAY  "Novo Tp Agendamento:" PIXEL OF oTFolder1:aDialogs[LEN(_aFoders)] SIZE 060,007 
 	@ nLinha  , _nCol2 MSCOMBOBOX _cTpAgenda       PIXEL OF oTFolder1:aDialogs[LEN(_aFoders)] SIZE 100,009 ITEMS _aTpAgenda
	nLinha+=22

	@ nLinha+4,_nCol1 Say "Justificativas:"   OF oTFolder1:aDialogs[LEN(_aFoders)] PIXEL
	 //             nRow ], nCol , [ bSetGet ]                            , nItens ],nWi  ,He    ,oWnd ]                           ,uPar,bChange,bValid,nClrText,nClrBack,lPixel,oFont,uParam15,uParam16,bWhen
	@ nLinha,_nCol2 MsGet _cJustAG   F3 "ZY5" Valid(AOMS97VLJU(_cJustAG , "C5_I_AGEND")) SIZE 30,012 PIXEL OF oTFolder1:aDialogs[LEN(_aFoders)]
   nLinha+=24
   
   @ nLinha+2,_nCol1 SAY  "Observação:" SIZE 060  ,012 PIXEL OF oTFolder1:aDialogs[LEN(_aFoders)] 
	@ nLinha,_nCol2 Get _cObseAG         SIZE _nTam,012 WHEN .F. PIXEL OF oTFolder1:aDialogs[LEN(_aFoders)]
	nLinha+=65
   
	@ nLinha,_nCol3    BUTTON "OK"       SIZE 50,15 PIXEL OF _oDlg2 ACTION (If(U_AOMS097Y(_cTpAgenda),(nOpc := 1, _oDlg2:End()), ))
   @ nLinha,_nCol3+99 BUTTON "Cancelar" SIZE 50,15 PIXEL OF _oDlg2 ACTION (nOpc := 2, _oDlg2:End())
  
   ACTIVATE MSDIALOG _oDlg2 

   If nOpc == 1
  
	   TRBSC5->(DbGoTop()) 
      Private _aLogSC5 := {}
      Private _aLogSC6 := {}      
      _nConta:=0
      _cTimeIni:="H.I.: "+TIME()
	   Do While ! TRBSC5->(Eof())
	      
	      If ! Empty(TRBSC5->WK_OK)
             
			   SC5->(DbGoto(TRBSC5->WK_RECNO))   

            _nConta++
            IF VALTYPE(oProc2) = "O"
               oProc2:cCaption := (_cTimeIni+" - Pedidos Gravados: "+ALLTRIM(STR(_nConta)))
               ProcessMessages()
            ENDIF

			   _ddtant    := SC5->C5_I_DTENT
			   _cAgendAnt := SC5->C5_I_AGEND
            _dNovaData := SC5->C5_I_DTENT
            If _cTpAgenda == "P"
               If MONTH(DATE()) == 12 
				      _dNovaData:= STOD(ALLTRIM(STR((YEAR(DATE())+2)))+"0101")-1  
				   Else
				      _dNovaData:= STOD(ALLTRIM(STR((YEAR(DATE())+1)))+"0101")-1  
				   EndIf
            ElseIf _cTpAgenda $ "I/O"
               _dNovaData := Date() + U_OMSVLDENT(SC5->C5_I_DTENT,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_FILIAL,SC5->C5_NUM,1,,SC5->C5_FILIAL,SC5->C5_I_OPER,SC5->C5_I_TPVEN)
            EndIf
            
            IF SC5->C5_I_DTENT <> _dNovaData .OR. SC5->C5_I_AGEND <> _cTpAgenda

		         // Inicia a gravação de Log, Tabelas SC5 e SC6.
		         _aLogSC5 := U_ITIniLog( 'SC5' , {"C5_I_AGEND","C5_I_DTENT","C5_FECENT"} )
		         _aLogSC6 := INILOG6( {"C6_ENTREG"} )

		         SC5->(RecLock("SC5",.F.))
               If (SC5->C5_I_AGEND ="P" .AND. _cTpAgenda = "A") .OR.;
         		   (SC5->C5_I_AGEND ="R" .AND. _cTpAgenda = "A") .OR.;
         		   (SC5->C5_I_AGEND ="P" .AND. _cTpAgenda = "M") .OR.;
         		   (SC5->C5_I_AGEND ="N" .AND. _cTpAgenda = "A") 

                  SC5->C5_I_QTDA := SC5->C5_I_QTDA + 1
               EndIf
		         SC5->C5_I_AGEND   := _cTpAgenda
               If _cTpAgenda == "P"
				   	SC5->C5_I_DTENT:= _dNovaData
				   	SC5->C5_FECENT := _dNovaData
               ElseIf _cTpAgenda $ "I/O"
                  SC5->C5_I_DTENT:= _dNovaData
				   	SC5->C5_FECENT := _dNovaData
               EndIf

		         SC5->(MsUnLock()) 
               
               If _cTpAgenda $ "P/I/O"
                  SC6->( DbSetOrder(1) )
                  SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
                  DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM
		               SC6->(RecLock("SC6",.F.))
				   	   SC6->C6_ENTREG := _dNovaData
		               SC6->(MsUnLock()) 
	                  SC6->( DBSkip() ) 	
                  ENDDO
               EndIf 

               IF SC5->C5_I_ENVRD = "S" .AND. !SuperGetMV("IT_AMBTEST",.F.,.T.)
                  U_ENVSITPV(,.F.)//ON LINE   //Envia interface de alteração de situação do pedido atual
               ENDIF

		         // Grava log de alterações do SC5 E SC6
		         If Type('_aLogSC5') == 'A' .And. !Empty( _aLogSC5 )
		         	U_ITGrvLog( _aLogSC5 , "SC5" , 1 , SC5->( C5_FILIAL + C5_NUM ) , "A" , __CUSERID , Date() , Time() )
		         EndIf
		         If Type('_aLogSC6') == 'A' .And. !Empty( _aLogSC6 )
		         	U_ITGrvLog( _aLogSC6 , "SC6" , 1 , SC5->( C5_FILIAL + C5_NUM ) , "A" , __CUSERID , Date() , Time() )
		         EndIf
          
			      TRBSC5->C5_I_AGEND := _cTpAgenda
               TRBSC5->C5_I_DTENT := SC5->C5_I_DTENT
		       
               If _cAgendAnt <> SC5->C5_I_AGEND
		            _dDTNECE := SC5->C5_I_DTENT
               
                  _cCOMENT := "Tipo de Agendamento Alterado de  " + _cAgendAnt + " para " + _cTpAgenda + "  via alteração de pedido de vendas."
   
                 //_cFilial,_cNum,_cJUSCOD,_cCOMENT,_cLENCMON,_dDTNECE       ,_dDTFAT        ,_dDTFOLD, _cObserv, _cVinculoTb, _dDtSugAgen
                  U_GrvMonitor(        ,     ,_cJustAG,_cCOMENT,""       ,SC5->C5_I_DTENT,SC5->C5_I_DTENT,_ddtant ,_cObseAG)     
               ENDIF
               
               If _cTpAgenda $ "P/I/O" .AND. 	_ddtant <> SC5->C5_I_DTENT
                  _dDTNECE := SC5->C5_I_DTENT 
                  //_cJUSCOD := "007" //Alterado Data de Entrega
                  _cCOMENT := "Data de entrega modificada de " + dtoc(_ddtant) + " para " + dtoc(SC5->C5_I_DTENT) + "  via alteração de tipo de agendamento do pedido de vendas."

                             //_cFilial,_cNum,_cJUSCOD,_cCOMENT,_cLENCMON,_dDTNECE,_dDTFAT        ,_dDTFOLD, _cObserv, _cVinculoTb, _dDtSugAgen
                  U_GrvMonitor(        ,     ,_cJustAG,_cCOMENT,""       ,_dDTNECE,SC5->C5_I_DTENT,_ddtant ,_cObseAG)   
                  U_AOMS097Z()             
               EndIf                                

               U_AOMS097Z()             

		         _lAlterou := .T.
           ENDIF
	      EndIf

	      TRBSC5->(DbSkip())
       EndDo

       If _lAlterou 
	       U_ItMsg("Tipo de agendamento alterado com sucesso.","Atenção","Pedidos Gravados: "+ALLTRIM(STR(_nConta)),2)
       Else
          U_ItMsg("Não há itens marcados para alteração do Tipo de agendamento.","Atenção",,1)
	    EndIf 
   Else	

	  //U_ItMsg("Processo Cancelado.","Atenção",,1)
		
   EndIf

End Sequence

TRBSC5->(DbGoTo(_nRegAtu))

U_AOMS097H()

RestArea(aArea)

RETURN 

/*
=================================================================================================================================
Programa--------: AOMS097Y
Autor-----------: Julio de Paula Paz
Data da Criacao-: 20/08/2019
=================================================================================================================================
Descrição-------: Validar a digitação do tipo de agendamento.
=================================================================================================================================
Parametros------: _cTpAgen = Nova data de entrega
=================================================================================================================================
Retorno---------: _lRet = .T. = Nova data e pedidos selecionados corretos.
                  _lRet = .F. = Nova Data e Pedidos selecionados incorretos.
=================================================================================================================================
*/ 
User Function AOMS097Y(_cTpAgen)
Local _lRet := .T.
Local _nRegAtu := TRBSC5->(Recno())
Local _dDtEntrega, _dDtFecham 

Begin Sequence

   If Empty(_cTpAgen)
	   U_ITMSG("O novo tipo de agendamento precisa ser preenchido.","Atenção",,1)
		_lRet := .F.
	   Break
   EndIf

   If _cTpAgen == "P"    
      If MONTH(DATE()) == 12 
			_dDtEntrega:= STOD(ALLTRIM(STR((YEAR(DATE()) +2 )))+"0101")-1  
		Else 
	 	   _dDtEntrega:= STOD(ALLTRIM(STR((YEAR(DATE()) +1 )))+"0101")-1  
		Endif
      _dDtFecham  := _dDtEntrega 

	   If ! (lRet:=.F.,FWMSGRUN(,{|O|lRet:=U_AOMS097W(_dDtEntrega,.F.,O,"TP_ANGENDAMENTO")}),lRet ) //Valida o STATUS DOS PVS e DATAS
         //U_ItMsg('Alguns pedidos selecionados não permitem alterar o tipo de agendamento para "P=Aguardando Agendamento".',"Atenção",,1)
		   _lRet := .F.
		   Break 
	   EndIf 
   ELSE
	   If !(lRet:=.F.,FWMSGRUN(,{|O|lRet:=U_AOMS097W(,.T.,O,"TP_ANGENDAMENTO")}),lRet )//Só Valida o STATUS DOS PVS
		   _lRet := .F.
		   Break 
	   EndIf 
   EndIf
   
End Sequence

TRBSC5->(DbGoTo(_nRegAtu))

Return _lRet

/*
=================================================================================================================================
Programa--------: AOMS097Z
Autor-----------: Julio de Paula Paz
Data da Criacao-: 22/08/2019
=================================================================================================================================
Descrição-------: Grava na tabela TRBZY3 o histórico de alteração no pedido de vendas, para atualização do browse.
=================================================================================================================================
Parametros------: Nenhum
=================================================================================================================================
Retorno---------: Nenhum 
=================================================================================================================================
*/ 
User Function AOMS097Z()
Local _nI
Local _aOrd := SaveOrd({"ZY3"})
Local _nRegAtu := ZY3->(Recno())

Begin Sequence
   TRBZY3->(DbSeek(TRBSC5->(C5_FILIAL+C5_NUM)))
   Do While ! TRBZY3->(Eof()) .And. TRBSC5->(C5_FILIAL+C5_NUM) == TRBZY3->(ZY3_FILFT+ZY3_NUMPV)
      //TRBZY3->(RecLock("TRBZY3",.F.))
      TRBZY3->(DbDelete())
      //TRBZY3->(MsUnLock())

      TRBZY3->(DbSkip())
   EndDo
   
   ZY3->(DbSetOrder(1)) // ZY3_FILIAL+ZY3_NUMPV+ZY3_SEQUEN 

   ZY3->(DbSeek(xFilial("ZY3") + TRBSC5->C5_NUM))
   Do While ! ZY3->(Eof()) .And. xFilial("ZY3") + TRBSC5->C5_NUM == ZY3->(ZY3_FILIAL+ZY3_NUMPV)
      //TRBZY3->(RecLock("TRBZY3", .T.))
      TRBZY3->(DBAPPEND())
   
      For _nI := 1 To TRBZY3->(FCount())
	       If ! AllTrim(TRBZY3->(FieldName(_nI))) $ "ZY3_JUSDES/WK_RECNO/ZY3_ALI_WT/ZY3_REC_WT/WKRECTRBY3"
             &("TRBZY3->"+TRBZY3->(FieldName(_nI)) ) := &("ZY3->"+TRBZY3->(FieldName(_nI)))
          EndIf
      Next 
      TRBZY3->ZY3_JUSDES := POSICIONE("ZY5",1,xFilial("ZY5")+TRBZY3->ZY3_JUSCOD,"ZY5_DESCR") 
	   TRBZY3->ZY3_FILFT  := ZY3->ZY3_FILFT
      TRBZY3->ZY3_NUMPV  := ZY3->ZY3_NUMPV
      TRBZY3->ZY3_DTFOLD := TRBSC5->C5_I_DTENT
	   TRBZY3->ZY3_ORIGEM := FUNNAME()
	   //TRBZY3->(MsUnLock()) 

      ZY3->(DbSkip())
   EndDo

   U_AOMS097H()

End Sequence

RestOrd(_aOrd)
ZY3->(DbGoTo(_nRegAtu))

Return Nil

/*
=================================================================================================================================
Programa--------: AOMS097H
Autor-----------: Julio de Paula Paz
Data da Criacao-: 22/08/2019
=================================================================================================================================
Descrição-------: Atualiza os dados da tabela GDBZY3 para exibição de dados no MSGetDB.
=================================================================================================================================
Parametros------: Nenhum
=================================================================================================================================
Retorno---------: Nenhum 
=================================================================================================================================
*/ 
User Function AOMS097H()
Local _nI

Begin Sequence
   GDBZY3->(DbGoTop())
   Do While ! GDBZY3->(Eof())
      //GDBZY3->(RecLock("GDBZY3",.F.))
      GDBZY3->(DbDelete())
      //GDBZY3->(MsUnLock())

      GDBZY3->(DbSkip())
   EndDo

   TRBZY3->(DbSeek(TRBSC5->(C5_FILIAL+C5_NUM))) 
   Do While ! TRBZY3->(Eof()) .And. TRBSC5->(C5_FILIAL+C5_NUM) = TRBZY3->(ZY3_FILFT+ZY3_NUMPV)
      //GDBZY3->(RecLock("GDBZY3", .T.))
      GDBZY3->(DBAPPEND())
      For _nI := 1 To TRBZY3->(FCount())
	       If ! AllTrim(TRBZY3->(FieldName(_nI))) $ "ZY3_JUSDES" //"/WK_RECNO/ZY3_ALI_WT/ZY3_REC_WT"
             &("GDBZY3->"+TRBZY3->(FieldName(_nI)) ) := &("TRBZY3->"+TRBZY3->(FieldName(_nI)))
          EndIf

          If AllTrim(TRBZY3->(FieldName(_nI))) == "ZY3_JUSCOD"
             GDBZY3->ZY3_JUSDES := POSICIONE("ZY5",1,xFilial("ZY5")+TRBZY3->ZY3_JUSCOD,"ZY5_DESCR") 
	       EndIf
      Next 
	   GDBZY3->WKRECTRBY3 := TRBZY3->(Recno())
	   //GDBZY3->(MsUnLock())  

      TRBZY3->(DbSkip())
   EndDo

   GDBZY3->(DbGoTop())

   If ValType(_oMarkZY3) == "O" 
      _oMarkZY3:oBrowse:Refresh()
   EndIf 

End Sequence

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS097J
Autor-------------: Julio de Paula Paz
Data da Criacao---: 26/08/2019
===============================================================================================================================
Descrição---------: Inserção de justificativa para multiplos pedidos de vendas selecionados.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS097J()
Local aArea			:= GetArea()
Local nOpc			:= 0
Local _lAlterou     := .F.
Local _aSizeAut   := MsAdvSize(.T.) 
Local _cCodJusEst := U_ItGetMv("IT_JUSTEST","005")
Local _nRegAtu := TRBSC5->(Recno())
Local _lInvZY8 := .F. 
Local _cVincZY3ZY8 := " "
Local _lPedVMark := .F.
Local _bOk, _bCancel

Private _cMarcaZY8 := GetMark()

Private _cComentar := Space(200), _oComentar
Private _cCodJust  := Space(3), _oCodJust
Private _cDescJust := Space(100), _oDescJust
Private _dDtEstoque := CTod("  /  /  ")
Private _cObserv := Space(200)
Private _oDtEstoque, _oObserv, _oMarkZY8
Private _dDtEntrega := Ctod("  /  /  "), _oDtEntrega
Private _dDtSugAgen:= Ctod("  /  /  "), _oDtSugAgen

Private _oDlgJ

Begin Sequence
   //================================================================================
   // Verifica se existe pedidos de vendas selecionado.
   //================================================================================   
   TRBSC5->(DbGoTop()) 
   Do While ! TRBSC5->(Eof())
      If ! Empty(TRBSC5->WK_OK)
         _lPedVMark := .T.
         Exit
      EndIf 

      TRBSC5->(DbSkip())
   EndDo   
   
   If ! _lPedVMark
      U_Itmsg("Não há Pedidos de vendas marcados para inclusão de justificativas.","Atenção",,1)
      Break
   EndIf 

   //================================================================================
   // Monta a tela MsSelect SC5  x MsSelect ZY8
   //================================================================================   
   _aObjects := {} 
   AAdd( _aObjects, { 315,  50, .T., .T. } )
   AAdd( _aObjects, { 100, 100, .T., .T. } )

   _aInfo := { _aSizeAut[ 1 ], _aSizeAut[ 2 ], _aSizeAut[ 3 ], _aSizeAut[ 4 ], 3, 3 } 

   _aPosObj := MsObjSize( _aInfo, _aObjects, .T. ) 
   
   _bOk := {|| If(U_AOMS097K("TUDO"),(nOpc := 1, _ODlgJ:End()), )}
   _bCancel := {|| nOpc := 2, _ODlgJ:End()}
                       
   _cTitulo := "Inclusão de Justificativas"

   //=====================================================================
   // Limpa a tabela temporária GDBZY8 para receber novos dados.
   //=====================================================================
   GDBZY8->(DbGoTop())
   Do While ! GDBZY8->(Eof())
      //GDBZY8->(RecLock("GDBZY8",.F.))
      GDBZY8->(DbDelete())
      //GDBZY8->(MsUnLock())

      GDBZY8->(DbSkip())
   EndDo

   //=====================================================================
   // Grava novos dados na tabela temporária GDBZY8.
   //=====================================================================
   SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
   TRBZY8->(DbSetOrder(2)) 

   TRBSC5->(DbGoTop()) 
   Do While ! TRBSC5->(Eof())
      If ! Empty(TRBSC5->WK_OK)
         SC6->(DbSeek(TRBSC5->(C5_FILIAL+C5_NUM)))
         Do While ! SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == TRBSC5->(C5_FILIAL+C5_NUM)
            GDBZY8->(DBAPPEND())//RecLock("GDBZY8", .T.))
            GDBZY8->ZY8_FILIAL := xFilial("ZY8")
            GDBZY8->ZY8_NUMPV  := SC6->C6_NUM
            GDBZY8->ZY8_SEQUEN := SC6->C6_ITEM
            GDBZY8->ZY8_DTMONI := Date()
            GDBZY8->ZY8_HRMONI := Time()
            GDBZY8->ZY8_CODUSR := __cUserId
            GDBZY8->ZY8_NOMUSR := cUsername
            GDBZY8->ZY8_CODPRD := SC6->C6_PRODUTO
            GDBZY8->ZY8_DSCPRD := SC6->C6_DESCRI 
            GDBZY8->ZY8_UNSVEN := SC6->C6_UNSVEN
            GDBZY8->ZY8_SEGUM  := SC6->C6_SEGUM
            GDBZY8->ZY8_QTDVEN := SC6->C6_QTDVEN
            GDBZY8->ZY8_UM     := SC6->C6_UM
            GDBZY8->ZY8_FILFT  := SC6->C6_FILIAL
            //GDBZY8->(MsUnLock())

            SC6->(DbSkip())
         EndDo 
      EndIf 

      TRBSC5->(DbSkip())
   EndDo
   TRBZY8->(DbSetOrder(1)) 
   GDBZY8->(DbSetOrder(2))
   GDBZY8->(DbGoTop() )

   nOpc :=0
   DEFINE MSDIALOG _ODlgJ TITLE "Gestão de Carteira - Pedido de Vendas - Inclusão de Justificativas" FROM _aSizeAut[7],00 To _aSizeAut[6], _aSizeAut[5] Of oMainWnd PIXEL
	
	   @ 40, 020 SAY oSayNDF PROMPT "Comentário: " SIZE 060, 007 OF _ODlgJ COLORS 0, 16777215 PIXEL
 	   @ 40, 084 MSGET _oComentar VAR _cComentar SIZE 200, 010 PICTURE "@!" OF _ODlgJ COLORS 0, 16777215 PIXEL    
  
      @ 55, 020 SAY oSayNDF PROMPT "Cod.Justificativa: " SIZE 060, 007 OF _ODlgJ COLORS 0, 16777215 PIXEL
 	   @ 55, 084 MSGET _oCodJust VAR _cCodJust SIZE 030, 010 F3 "ZY5" OF _ODlgJ VALID (Vazio() .Or. (NaoVazio(_cCodJust) .And. U_AOMS097K("_cCodJust"))) COLORS 0, 16777215 PIXEL   
    
      @ 70, 020 SAY oSayNDF PROMPT "Desc.Justificativa: " SIZE 060, 007 OF _ODlgJ COLORS 0, 16777215 PIXEL
 	   @ 70, 084 MSGET _oDescJust VAR _cDescJust SIZE 120, 010 OF _ODlgJ WHEN .F. COLORS 0, 16777215 PIXEL  

      @ 85, 020 SAY oSayNDF PROMPT "Data Estoque Previsto: " SIZE 060, 007 OF _ODlgJ COLORS 0, 16777215 PIXEL
 	   @ 85, 084 MSGET _oDtEstoque VAR _dDtEstoque SIZE 040, 010 OF _ODlgJ Valid(U_AOMS097P())  Picture "@D" COLORS 0, 16777215 PIXEL  

      @ 100, 020 SAY oSayNDF PROMPT "Data Sugerida Agendamento: " SIZE 060, 007 OF _ODlgJ COLORS 0, 16777215 PIXEL
 	   @ 100, 084 MSGET _oDtSugAgen VAR _dDtSugAgen SIZE 040, 010 OF _ODlgJ When .F. Picture "@D" COLORS 0, 16777215 PIXEL   

      @ 115, 020 SAY oSayNDF PROMPT "Data Entrega no Cliente: " SIZE 060, 007 OF _ODlgJ COLORS 0, 16777215 PIXEL
 	   @ 115, 084 MSGET _oDtEntrega VAR _dDtEntrega SIZE 040, 010 OF _ODlgJ  Picture "@D" COLORS 0, 16777215 PIXEL   
      
      @ 130, 020 SAY oSayNDF PROMPT "Observação: " SIZE 060, 007 OF _ODlgJ COLORS 0, 16777215 PIXEL
 	   @ 130, 084 MSGET _oObserv VAR _cObserv SIZE 200, 010 PICTURE "@!" OF _ODlgJ COLORS 0, 16777215 PIXEL    
 
      _oMarkZY8 := MsSelect():New("GDBZY8"   ,"WK_OK"   ,""      ,_aCmpZY8   ,@_lInvzy8, @_cMarcaZY8,{_aPosObj[2,1]+30 , _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4]},              ,              ,               ,          ,  )        
      
      _oDtEstoque:Disable()
      _oDtEntrega:Disable()
      _oObserv:Disable()
      //_oMarkZY8:oBrowse:Disable()

   Activate MsDialog _oDlgJ On Init EnchoiceBar(_oDlgJ,_bOk,_bCancel,,_aButtons) 
		
   If nOpc == 1
      If _cCodJust $ _cCodJusEst //"005" // Falta de produto
         _cVincZY3ZY8 := Dtos(Date())+Time()

         GDBZY8->(DbGotop())
         Do While ! GDBZY8->(Eof())
            If ! Empty(GDBZY8->WK_OK)
               //GDBZY8->(RecLock("GDBZY8", .F.))
               GDBZY8->ZY8_COMENT := _cComentar
               GDBZY8->ZY8_JUSCOD := _cCodJust
               GDBZY8->ZY8_OBSERV := _cObserv
               GDBZY8->ZY8_DTPREV := _dDtEstoque
               GDBZY8->ZY8_VNCZY3 := _cVincZY3ZY8
               GDBZY8->ZY8_DTECLI := _dDtEntrega 
               //GDBZY8->(MsUnLock())
            EndIf 

            GDBZY8->(DbSkip())
         EndDo

         U_AOMS097N() // Grava dados dos produtos
      EndIf

	   TRBSC5->(DbGoTop()) 

	   Do While ! TRBSC5->(Eof())
	      
	      If ! Empty(TRBSC5->WK_OK)
             
			   SC5->(DbGoto(TRBSC5->WK_RECNO))   
		      
            U_GrvMonitor(,,_cCodJust,_cComentar,"",SC5->C5_I_DTENT,SC5->C5_I_DTENT,SC5->C5_I_DTENT,_cObserv, _cVincZY3ZY8, _dDtSugAgen)
	         
            U_AOMS097Z()
            
            If _cCodJust $ _cCodJusEst // _cCodJust == "005" // Falta de produto
               SC5->(RecLock("SC5",.F.))
               SC5->C5_I_DTPRV := _dDtEstoque
               SC5->C5_I_DTCLI := _dDtEntrega 
               SC5->C5_I_DTSAG := _dDtSugAgen
               SC5->(MsUnLock())
            EndIf 

		      _lAlterou := .T.
	      EndIf

	      TRBSC5->(DbSkip())
      EndDo

      If _lAlterou 
	      U_Itmsg("Justificativas incluidas com sucesso.","Atenção",,2)
      Else
         U_Itmsg("Não há itens marcados para inclusão de justificativas.","Atenção",,1)
	   EndIf 
   Else	
	   //U_Itmsg("Processo Cancelado.","Atenção",,1)
   EndIf

End Sequence

GDBZY8->(DbSetOrder(1))
TRBSC5->(DbGoTo(_nRegAtu))

RestArea(aArea)

RETURN 

/*
===============================================================================================================================
Programa----------: AOMS097K
Autor-------------: Julio de Paula Paz
Data da Criacao---: 26/08/2019
===============================================================================================================================
Descrição---------: Valida a Inserção de justificativa para multiplos pedidos de vendas selecionados.
===============================================================================================================================
Parametros--------: _cCampo = Campo que chamou a validação
===============================================================================================================================
Retorno-----------: .T. / .F.
===============================================================================================================================
*/
User Function AOMS097K(_cCampo)
Local _lRet := .T.
Local _cCodJusEst := U_ItGetMv("IT_JUSTEST","005")
Local _lItemSelect := .F., _nRecAtu

Begin Sequence
   If _cCampo == "TUDO"
      If Empty(_cComentar)
         U_ItMsg("Comentário da justificativa não preenchido.", "Atenção", "Favor preencha o comentário da justificativa.",1) 
         _lRet := .F.
         Break
      EndIf

      If Empty(_cCodJust)
         U_ItMsg("Código da justificativa não preenchido.", "Atenção", "Favor preencha o código da justificativa.",1) 
         _lRet := .F.
         Break
      EndIf

      If _cCodJust $ _cCodJusEst
         If Empty(_dDtEstoque)
            U_ItMsg("Data prevista de estoque não preenchida.", "Atenção", "Favor preencha a data prevista de estoque.",1) 
            _lRet := .F.
            Break
         EndIf 
     
         _nRecAtu := GDBZY8->(Recno())

         GDBZY8->(DbGotop())
         Do While ! GDBZY8->(Eof())
            If ! Empty(GDBZY8->WK_OK)
               _lItemSelect := .T.
               Exit      
            EndIf 

            GDBZY8->(DbSkip())
         EndDo
      
         If ! _lItemSelect
            U_ItMsg("Não existem itens selecionados para a inclusão da justificativa.", "Atenção", "Para incluir uma justificativa é obrigatório selecionar um item.",1) 
            _lRet := .F.
         EndIf 

         GDBZY8->(DbGoto(_nRecAtu))
      EndIf 
   Else 
      If _cCodJust $ _cCodJusEst
         _oDtEstoque:Enable()
         _oDtEntrega:Enable()
         _oObserv:Enable()
         //_oMarkZY8:oBrowse:Enable()
      Else
         _oDtEstoque:Disable()
         _oDtEntrega:Disable()
         _oObserv:Disable()
         //_oMarkZY8:oBrowse:Disable()
      EndIf 
   EndIf

   If ! ExistCpo("ZY5",_cCodJust)
      _lRet := .F.
      Break
   EndIf

   _cDescJust := POSICIONE("ZY5",1,xFilial("ZY5")+_cCodJust,"ZY5_DESCR")
   _oDescJust:Refresh()
  
End Sequence

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS097C
Autor-------------: Julio de Paula Paz
Data da Criacao---: 26/08/2019
===============================================================================================================================
Descrição---------: Gera relatório para os pedidos devendas selecionados e envia por e-mail.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS097C()
Local oAssunto
Local oButCan
Local oButEnv
Local oCc
Local oGetAssun
Local oGetCc
Local oGetPara
Local oMens
Local oPara
Local nOpcA		:= 2

Local cGetAssun	:= "Relatório Gestão de Carteira de Pedidos de Vendas. "+Space(150)
Local cGetCc	:= Space(200)
Local cGetPara	:= Space(200)
Local _cHtml

Private oDlgMail , _oFont

Begin Sequence 
   
   _cHtml := '<b>Prezado Sr(a),</b>'
   _cHtml += '<br><br>'
   _cHtml += '&nbsp;&nbsp;&nbsp;Segue anexo o relatório de Gestão de Carteira de Pedidos de Vendas. '+'.<br>'
   _cHtml += '<br>'
   _cHtml += '<b>Observação: </b>O arquivo em anexo deve ser aberto com o Microsoft Excel.'
   _cHtml += '<br>'
   _cHtml += '<br>'
   _cHtml += '<br>'
   _cHtml += '<br>'
   _cHtml += '<br>'
   _cHtml += '<br>'
   _cHtml += '<br>'
   _cHtml += '<br>'
   _cHtml += '<br>'
   _cHtml += '<br>'
   _cHtml += '    <tr>'
   _cHtml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
   _cHtml += '      <td class="itens" align="left" > ['+ GETENVSERVER() +'] / <b>Fonte:</b> [AOMS097]</td>'
   _cHtml += '    </tr>'
   
   DEFINE MSDIALOG oDlgMail TITLE "E-Mail" FROM 000, 000  TO 415, 584 COLORS 0, 16777215 PIXEL

	   //======
	   // Para:
	   //======
	   @ 005, 006 SAY oPara PROMPT "Para:" SIZE 015, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	   @ 005, 030 MSGET oGetPara VAR cGetPara SIZE 256, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL

	   //===========
	   // Com cópia:
	   //===========
	   @ 021, 006 SAY oCc PROMPT "Cc:" SIZE 015, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	   @ 021, 030 MSGET oGetCc VAR cGetCc SIZE 256, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL

	   //=========
	   // Assunto:
	   //=========
	   @ 037, 006 SAY oAssunto PROMPT "Assunto:" SIZE 022, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	   @ 037, 030 MSGET oGetAssun VAR cGetAssun SIZE 256, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL

	   //==========
	   // Mensagem:
	   //==========
	   @ 069, 006 SAY oMens PROMPT "Mensagem:" SIZE 030, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	   _oFont		:= TFont():New( 'Courier new' ,, 12 , .F. )
	   _oScrAux	:= TSimpleEditor():New( 080 , 006 , oDlgMail , 285 , 105 ,,,,, .T. )
	
	   _oScrAux:Load( _cHtml )
	
	   @ 189, 201 BUTTON oButEnv PROMPT "&Enviar"		SIZE 037, 012 OF oDlgMail ACTION ( nOpcA := 1 , _cHtml := _oScrAux:RetText() , oDlgMail:End() ) PIXEL
	   @ 189, 245 BUTTON oButCan PROMPT "&Cancelar"	SIZE 037, 012 OF oDlgMail ACTION ( nOpcA := 2 , oDlgMail:End() ) PIXEL

   ACTIVATE MSDIALOG oDlgMail CENTERED

   If nOpcA == 1
      Processa( {|| U_AOMS097I(cGetPara, cGetCc, cGetAssun, _cHtml) }, "Aguarde...", "Gerando Relatório...",.F.)

      //U_ItMsg("Rotina de geração do relatório e envio de e-mail finalizada.", "Atenção", ,1) 

   EndIf 

End Sequence

Return Nil 

/*
===============================================================================================================================
Programa----------: AOMS097I
Autor-------------: Julio de Paula Paz
Data da Criacao---: 27/08/2019
===============================================================================================================================
Descrição---------: Gera os dados do relatório em Excel para envio por e-mail.
===============================================================================================================================
Parametros--------: cGetPara   = E-mail de destino
                    cGetCc     = E-mail de copia
                    cGetAssun  = Assunto do e-mail
                    _cHtml     = corpo do e-mail.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS097I(cGetPara, cGetCc, cGetAssun, _cHtml)
Local _aCabec 
Local _cDirExcel := "\spool"
Local _cDataHora 
Local _cNomeArq
Local _cTitulo
Local _aLista, _nRegAtu := TRBSC5->(Recno())

Begin Sequence
   //=============================================================================
   // Obtem Cabeçalho do Relatório
   //=============================================================================
   _aCabec := {} // Array com o cabeçalho das colunas do relatório. 
   // Alinhamento( 1-Left,2-Center,3-Right )
   // Formatação( 1-General,2-Number,3-Monetário,4-DateTime )
   //                  Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?  
   Aadd(_aCabec,{"Filial"                 ,1           ,1         ,.F.})    
   Aadd(_aCabec,{"Nr.Pedido"              ,1           ,1         ,.F.})     
   Aadd(_aCabec,{"Tipo"                   ,1           ,1         ,.F.})    
   Aadd(_aCabec,{"Operação"               ,1           ,1         ,.F.})    
   Aadd(_aCabec,{"Cliente"                ,1           ,1         ,.F.})    
   Aadd(_aCabec,{"Loja cliente"           ,1           ,1         ,.F.})    
   Aadd(_aCabec,{"Data Entrega"           ,1           ,1         ,.F.})    
   Aadd(_aCabec,{"Nome Cliente"           ,1           ,1         ,.F.})    
   Aadd(_aCabec,{"Estado"                 ,1           ,1         ,.F.})    
   Aadd(_aCabec,{"Municipio"              ,1           ,1         ,.F.})    
   Aadd(_aCabec,{"Sequence"               ,1           ,1         ,.F.})    
   Aadd(_aCabec,{"Data Monitoramento"     ,1           ,1         ,.F.})     
   Aadd(_aCabec,{"Hora Monitoramento"     ,1           ,1         ,.F.})    
   Aadd(_aCabec,{"Comentário"             ,1           ,1         ,.F.})    
   Aadd(_aCabec,{"Codigo Usuário"         ,1           ,1         ,.F.})    
   Aadd(_aCabec,{"Nome Usuário"           ,1           ,1         ,.F.})    // Aadd(_aCabec,{"Data Faturamento"       ,1           ,1         ,.F.})   //Aadd(_aCabec,{"Data Entrega"           ,1           ,1         ,.F.})    
   Aadd(_aCabec,{"Filial Faturamento"     ,1           ,1         ,.F.})    
   Aadd(_aCabec,{"Data Anterior"          ,1           ,1         ,.F.})    
   Aadd(_aCabec,{"Codigo Justificativa"   ,1           ,1         ,.F.})    
   Aadd(_aCabec,{"Descrição Justificativa",1           ,1         ,.F.})    
   Aadd(_aCabec,{"Origem"                 ,1           ,1         ,.F.})    
   Aadd(_aCabec,{"Cod. Assistente"        ,1           ,1         ,.F.})    
   Aadd(_aCabec,{"Assistente"             ,1           ,1         ,.F.})    
   Aadd(_aCabec,{"E-Mail Assistente"      ,1           ,1         ,.F.})    
  
   _aLista := {}

   TRBSC5->(DbGoTop()) 

   ProcRegua(0)

	Do While ! TRBSC5->(Eof())
	   IncProc("Montando o relatório...")   
	   If ! Empty(TRBSC5->WK_OK)
             
	      SC5->(DbGoto(TRBSC5->WK_RECNO))   
         
         If TRBZY3->(DbSeek(SC5->(C5_FILIAL+C5_NUM))) //"ZY3_FILFT","ZY3_NUMPV"		      
            Do While ! TRBZY3->(Eof()) .And.  SC5->(C5_FILIAL+C5_NUM) == TRBZY3->(ZY3_FILFT+ZY3_NUMPV)
               Aadd(_aLista, {SC5->C5_FILIAL,;     // - Filial
                              SC5->C5_NUM,;        //    - Nr.Pedido 
                              SC5->C5_TIPO,;       //   - Tipo
                              SC5->C5_I_OPER,;     // - Operação
                              SC5->C5_CLIENTE,;    // - Cliente
                              SC5->C5_LOJACLI,;    // - Loja cliente
                              SC5->C5_I_DTENT,;    // - Data Entrega
                              SC5->C5_I_NOME,;     //  - Nome Cliente
                              SC5->C5_I_EST,;      //   - Estado
                              SC5->C5_I_MUN,;      //   - Municipio
                              TRBZY3->ZY3_SEQUEN,; // - Sequence
                              TRBZY3->ZY3_DTMONI,; // - Data Monitoramento 
                              TRBZY3->ZY3_HRMONI,; // - Hora Monitoramento
                              TRBZY3->ZY3_COMENT,; // - Comentárioi
                              TRBZY3->ZY3_CODUSR,; // - Codigo Usuário
                              TRBZY3->ZY3_NOMUSR,; // - Nome Usuário //TRBZY3->ZY3_DTNECE,; // - Data Faturamento  // TRBZY3->ZY3_DTFAT,;  //  - Data Entrega
                              TRBZY3->ZY3_FILFT,;  //  - Filial Faturamento
                              TRBZY3->ZY3_DTFOLD,; // - Data Anterior 
                              TRBZY3->ZY3_JUSCOD,; // - Codigo Justificativa
                              TRBZY3->ZY3_JUSDES,; // - Descrição Justificativa
                              TRBZY3->ZY3_ORIGEM,; // - Origem
                              SC5->C5_ASSCOD,;     // - Cod. Assistente
                              SC5->C5_ASSNOM,;     // - Assistente  
                              IF(!EMPTY(SC5->C5_ASSCOD),ALLTRIM(POSICIONE("ZPG",1,xFilial("ZPG")+SC5->C5_ASSCOD,"ZPG_EMAIL"))," ") }) // - E-Mail Assistente

               TRBZY3->(DbSkip())
            EndDo
         Else
            Aadd(_aLista, {SC5->C5_FILIAL,;     // - Filial
                           SC5->C5_NUM,;        //    - Nr.Pedido 
                           SC5->C5_TIPO,;       //   - Tipo
                           SC5->C5_I_OPER,;     // - Operação
                           SC5->C5_CLIENTE,;    // - Cliente
                           SC5->C5_LOJACLI,;    // - Loja cliente
                           SC5->C5_I_DTENT,;    // - Data Entrega
                           SC5->C5_I_NOME,;     //  - Nome Cliente
                           SC5->C5_I_EST,;      //   - Estado
                           SC5->C5_I_MUN,;      //   - Municipio
                           "",;                 // - Sequence
                           "",;                 // - Data Monitoramento 
                           "",;                 // - Hora Monitoramento
                           "",;                 // - Comentárioi
                           "",;                 // - Codigo Usuário
                           "",;                 // - Nome Usuário //"",;          // - Data Faturamento  // "",;                 //  - Data Entrega
                           "",;                 //  - Filial Faturamento
                           "",;                 // - Data Anterior 
                           "",;                 // - Codigo Justificativa
                           "",;                 // - Descrição Justificativa
                           "",;                 // - Origem
                           SC5->C5_ASSCOD,;     // - Cod. Assistente
                           SC5->C5_ASSNOM,;     // - Assistente  
                           IF(!EMPTY(SC5->C5_ASSCOD),ALLTRIM(POSICIONE("ZPG",1,xFilial("ZPG")+SC5->C5_ASSCOD,"ZPG_EMAIL"))," ") }) // - E-Mail Assistente

         EndIf
      
      EndIf

	   TRBSC5->(DbSkip())
   EndDo

   If Len(_aLista) > 0
      IncProc("Enviando por e-mail...")
      _cDataHora := "_Dt_" + StrZero(Day(Date()),2) + "_" + StrZero(Month(Date()),2) + "_" + StrZero(Year(Date()),4) + "_Hr_" + StrTran(Time(),":","_")
      _cNomeArq  := "GESTAO_CARTEIRA_" +  _cDataHora + ".xlsx"//XLSX
      _cTitulo   := "Relatório Gestão de Carteira de Pedidos de Vendas " 
      //===============================================================
      // Gerando relatório em Excel para envio de e-mail
      //===============================================================
      //ITGEREXCEL(_cNomeArq,_cDiretorio,_cTitulo,_cNomePlan                 ,_aCabecalho,_aDetalhe,_lLeTabTemp,_cAliasTab,_aCampos,_lScheduller,_lCriaPastas,_aPergunte,_lEnviaEmail,_lXLSX)
      U_ITGEREXCEL(_cNomeArq,_cDirExcel ,_cTitulo,"Relatorio_Gestao_Carteira",_aCabec    ,_aLista  ,.F.        ,          ,        ,.T.         ,            ,          ,            ,.T.   ) 

      If File(_cDirExcel+"\"+_cNomeArq) .And. U_AOMS097F(_cDirExcel+"\"+_cNomeArq)
         //U_ItConOut("[AOMS097] - Arquivo: " + _cDirExcel + "\" + _cNomeArq + ", gerado com sucesso!" )
     
         U_AOMS097D(cGetPara, cGetCc, cGetAssun, _cHtml, _cDirExcel+"\"+_cNomeArq)            
      //Else
         //U_ItConOut("[AOMS097] - Falha na Geração do Arquivo: " + _cDirExcel + "\" + _cNomeArq + "." )
      EndIf
   Else
      U_ItMsg("Não há dados para geração do relatório e envio do e-mail.", "Atenção", ,1) 
   EndIf

End Sequence

TRBSC5->(DbGoto(_nRegAtu))

Return Nil
	  
/*
===============================================================================================================================
Programa----------: AOMS097D
Autor-------------: Julio de Paula Paz
Data da Criacao---: 19/02/2019
===============================================================================================================================
Descrição---------: Rotina de envio de relatório em Excel por e-mail da Gestão de carteira de pedidos.
===============================================================================================================================
Parametros--------: _cEmail      = E-mail de destino
                    _cEmailCC    = E-mail em cópia
                    _cAssunto    = Assunto do e-mail
                    _cHtml       = Conteúdo do e-mail
                    _cArqEnv     = Diretório + Nome do arquivo a ser enviado.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS097D(_cEmail, _cEmailCC , _cAssunto, _cHtml , _cArqEnv)
Local _aConfig	:= U_ITCFGEML('') // Configurações do servidor de envio de e-mail.
Local _cEmlLog := ""

Begin Sequence
     
   U_ITENVMAIL( "workflow@italac.com.br", _cEmail, _cEmailCC ,, _cAssunto, _cHtml     , _cArqEnv, _aConfig[01], _aConfig[02], _aConfig[03], _aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

   //_cEmlLog := Upper(_cEmlLog)
   
   If !Empty( _cEmlLog ) //.And. "SUCESSO" $ _cEmlLog
      U_ITMSG(UPPER(_cEmlLog)+CHR(13)+CHR(10)+;
		        "E-mail para: "+_cEmail+CHR(10)+;
		        "CC: "+_cEmailCC+CHR(10),;
		        "ENVIO DO E-MAIL",,3)

      //U_ItConOut("[AOMS097] - Envio de e-mail Relatório do Relatorio Gestão de Carteira de Pedidos de Vendas.")
      //U_ItConOut(_cEmlLog)
   //Else
      //U_ItConOut("[AOMS097] - Falha no envio de e-mail do Relatório Gestão de Carteira de Pedidos de Vendas.")
      //U_ItConOut("[AOMS097] - " + _cAssunto )
      //U_ItConOut(_cEmlLog)
   EndIf

End Sequence

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS097F
Autor-------------: Julio de Paula Paz
Data da Criacao---: 19/02/2019
===============================================================================================================================
Descrição---------: Realiza uma pausa e tenta abrir o arquivo passado por parâmetro para ver se já está disponível 
                    para ser enviado por e-mail.
===============================================================================================================================
Parametros--------: _cArqRelat = Arquivo de relatório a ser testado.
===============================================================================================================================
Retorno-----------: _lRet = .T. - arquivo aberto com sucesso.
                            .F. - não conseguiu abrir o arquivo.
===============================================================================================================================
*/
User Function AOMS097F(_cArqRelat)
Local _lRet := .F.
Local _nHandle
Local _nTempo := 0 , _nTempoTot := 30000

Begin Sequence
   Do While _nTempo <= _nTempoTot 
      // Abre o arquivon
      _nHandle := FT_FUse(_cArqRelat)
      
      If _nHandle <> -1  
         _lRet := .T.
         Break 
      EndIf
   
      _nTempo += 1000
      Sleep(1000)  // Faz uma pausa de 1 segundo.
   EndDo   

End sequence

// Fecha o Arquivo
FT_FUSE()

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS097L
Autor-------------: Julio de Paula Paz
Data da Criacao---: 27/08/2019
===============================================================================================================================
Descrição---------: Chama a rotina de manutenção de pedidos de vendas, para o pedido de vendas posicionado.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS097L()

Private _cCodFilial := Space(2)
Private _cNrPedido  := Space(6)

Begin Sequence
   SC5->(DbGoto(TRBSC5->WK_RECNO))
   If SC5->(Eof()) .Or. SC5->(Bof())
      U_ItMsg("Não posicionado nenhum pedido de vendas.", "Atenção", "É preciso posicionar o cursor sobre um pedido de vendas." ,1) 
      Break
   EndIf
   
   _cCodFilial := SC5->C5_FILIAL
   _cNrPedido  := SC5->C5_NUM

   MATA410()
   
   SC5->(DbGoto(TRBSC5->WK_RECNO))

End Sequence

Return Nil 

/*
===============================================================================================================================
Programa----------: AOMS097B
Autor-------------: Julio de Paula Paz
Data da Criacao---: 28/08/2019
===============================================================================================================================
Descrição---------: Rotina temporária para gerar os dados da tabela Transit Time no formato TXT, para o Update.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS097B()
Local _cLinha := ""
Local nHandle
//Local _cDir := GetTempPath()

Begin Sequence
   // Abre o arquivo
   nHandle := FCREATE('C:\temp\Dados_ZG5.txt')

   If nHandle == -1
      MsgStop('Erro na Criação do arquivo : FERROR '+str(ferror(),4))
      Break
   EndIf

   ZG5->(DbGoTop())
   
   Do While ! ZG5->(Eof()) 
      _cLinha := "Aadd(_aDados,{'"      + ZG5->(ZG5_FILIAL+ZG5_FILORI+ZG5_UF+ZG5_CODMUN+ZG5_LOCAL) + "',"
      _cLinha += '"ZG5->ZG5_COND1 := '  + "'" + AllTrim(ZG5->ZG5_COND1)  + "'" + ' ", '
      _cLinha += '"ZG5->ZG5_LEGCD1 := ' + "'" + AllTrim(ZG5->ZG5_LEGCD1) + "'" + ' ", '
      _cLinha += '"ZG5->ZG5_COND2 := '  + "'" + AllTrim(ZG5->ZG5_COND2)  + "'" + ' ", '
      _cLinha += '"ZG5->ZG5_LEGCD2 := ' + "'" + AllTrim(ZG5->ZG5_LEGCD2) + "'" + ' ", '
      _cLinha += '"ZG5->ZG5_COND3 := '  + "'" + AllTrim(ZG5->ZG5_COND3)  + "'" + ' ", '
      _cLinha += '"ZG5->ZG5_LEGCD3 := ' + "'" + AllTrim(ZG5->ZG5_LEGCD3) + "'" + ' ", '
      _cLinha += '"ZG5->ZG5_COND4 := '  + "'" + AllTrim(ZG5->ZG5_COND4)  + "'" + ' ", '
      _cLinha += '"ZG5->ZG5_LEGCD4 := ' + "'" + AllTrim(ZG5->ZG5_LEGCD4) + "'" + ' ", '
      _cLinha += '"ZG5->ZG5_COND5 := '  + "'" + AllTrim(ZG5->ZG5_COND5)  + "'" + ' ", '
      _cLinha += '"ZG5->ZG5_LEGCD5 := ' + "'" + AllTrim(ZG5->ZG5_LEGCD5) + "'" + ' ", '
      _cLinha += '"ZG5->ZG5_OBSERV := ' + "'" + AllTrim(ZG5->ZG5_OBSERV) + "'" + ' "}) ' + CRLF

      FWrite(nHandle, _cLinha) // Insere texto no arquivo
      
      ZG5->(DbSkip())
   EndDo

   fclose(nHandle)                   // Fecha arquivo

   MsgAlert('Processo concluído')

End Sequence

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS097M
Autor-------------: Julio de Paula Paz
Data da Criacao---: 11/08/2020
===============================================================================================================================
Descrição---------: Rotina de marca e desmarca todos os itens do MSSelect.
===============================================================================================================================
Parametros--------: _cMarca := Marca do msselect.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS097M(_cMarca)

Begin Sequence

   If ! Empty(TRBSC5->WK_OK)
       _cMarca := "  "
   ELSE
       _nQtdSel:=0
   EndIf
   
   TRBSC5->(DbGoTop())
   Do While ! TRBSC5->(Eof() )

      TRBSC5->WK_OK := _cMarca

      If !Empty(TRBSC5->WK_OK)
         _nQtdSel++
      ELSEIF _nQtdSel > 0
         _nQtdSel--
      EndIf
      //_oQtda:Refresh()
      oTButton5:cCaption:="MARCADOS: "+TRANS(_nQtdSel,"@E 9999,999")
 
      TRBSC5->(DbSkip())
   EndDo 
   
   TRBSC5->(DbGoTop())
   
   _oMarkSC5:OBrowse:Refresh()

End Sequence

Return Nil 
  
/*
===============================================================================================================================
Programa----------: AOMS097N
Autor-------------: Julio de Paula Paz
Data da Criacao---: 11/08/2020
===============================================================================================================================
Descrição---------: Grava os dados das Justificativas por produtos.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS097N()
Local _nTotCampos, _nI

Begin Sequence
   
   _nTotCampos := GDBZY8->(FCount()) 

   GDBZY8->(DbGoTop())
   Do While ! GDBZY8->(Eof())
      If Empty(GDBZY8->WK_OK)
         GDBZY8->(DbSkip())  
         Loop 
      EndIf 

      ZY8->(RecLock("ZY8",.T.))
      
      For _nI := 1 To _nTotCampos
		     
			 If AllTrim(GDBZY8->(FieldName(_nI))) $ "WK_RECNO/ZY8_ALI_WT/ZY8_REC_WT/WKRECTRBY8/WK_OK" .Or. Empty(TRBZY8->(FieldName(_nI)))
		       Loop			  
          EndIf

			 _cCampo := GDBZY8->(FieldName(_nI))
		    _cContexto := GetSx3Cache(_cCampo,"X3_CONTEXT")
          If _cContexto <> "V" 
             &("ZY8->"+_cCampo) := &("GDBZY8->"+ _cCampo)
		    EndIf
	   Next
      ZY8->(MsUnLock())

      If ! Empty(GDBZY8->ZY8_REC_WT) 
         GDBZY8->(MsSeek(GDBZY8->(ZY8_FILFT+ZY8_NUMPV+ZY8_SEQUEN)))
         //TRBZY8->(RecLock("TRBZY8",.F.))
      Else
         TRBZY8->(DBAPPEND())//RecLock("TRBZY8",.T.))
      EndIf
      
      For _nI := 1 To _nTotCampos
		    If AllTrim(GDBZY8->(FieldName(_nI))) $ "WK_RECNO/ZY8_ALI_WT/ZY8_REC_WT/WKRECTRBY8/WK_OK" .Or. Empty(TRBZY8->(FieldName(_nI)))
		       Loop			  
          EndIf

		    _cCampo := GDBZY8->(FieldName(_nI))
		    _cContexto := GetSx3Cache(_cCampo,"X3_CONTEXT")
          If _cContexto <> "V" 
	          &("TRBZY8->"+_cCampo) := &("GDBZY8->"+ _cCampo)
		    EndIf
	   Next
      //TRBZY8->(MsUnLock())

      GDBZY8->(DbSkip())
   EndDo 
End Sequence

Return Nil 

/*
===============================================================================================================================
Programa----------: AOMS097O
Autor-------------: Julio de Paula Paz
Data da Criacao---: 13/08/2020
===============================================================================================================================
Descrição---------: Visualização das datas previstas de estoque para a justificativa posicionada.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS097O()
Local aArea			:= GetArea()
Local nOpc			:= 0
Local _aSizeAut   := MsAdvSize(.T.) , _nI
Local _lInvZY8 := .F. 
Local _bOk, _bCancel

Private _cMarcaZY8 := GetMark()

Private _cComentar := Space(200), _oComentar
Private _cCodJust  := Space(3), _oCodJust
Private _cDescJust := Space(100), _oDescJust
Private _dDtEstoque := CTod("  /  /  ")
Private _cObserv := Space(200)
Private _oDtEstoque, _oObserv, _oMarkZY8

Private _oDlgO

Begin Sequence
   If GDBZY3->(Eof()) .Or. GDBZY3->(Bof()) .Or. Empty(GDBZY3->ZY3_VNCZY8)
      U_Itmsg("Não existem datas previstas de estoque para esta justificativa.","Atenção",,1)
      Break
   EndIf 

   //================================================================================
   // Monta a tela MsSelect ZY8
   //================================================================================   
   _aObjects := {} 
   AAdd( _aObjects, { 315,  50, .T., .T. } )
   AAdd( _aObjects, { 100, 100, .T., .T. } )

   _aInfo := { _aSizeAut[ 1 ], _aSizeAut[ 2 ], _aSizeAut[ 3 ], _aSizeAut[ 4 ], 3, 3 } 

   _aPosObj := MsObjSize( _aInfo, _aObjects, .T. ) 
   
   _bOk := {|| _oDlgO:End()}
   _bCancel := {|| _oDlgO:End()}
                       
   _cTitulo := "Visualização de Data Prevista para Estoque"

   //=====================================================================
   // Limpa a tabela temporária GDBZY8 para receber novos dados.
   //=====================================================================
   GDBZY8->(DbGoTop())
   Do While ! GDBZY8->(Eof())
      //GDBZY8->(RecLock("GDBZY8",.F.))
      GDBZY8->(DbDelete())
     // GDBZY8->(MsUnLock())

      GDBZY8->(DbSkip())
   EndDo

   //=====================================================================
   // Grava novos dados na tabela temporária GDBZY8.
   //=====================================================================
   TRBZY8->(DbSetOrder(2)) 

   TRBZY8->(MsSeek(GDBZY3->ZY3_NUMPV ))
   
   _nTotCampos := TRBZY8->(FCount()) 

   Do While ! TRBZY8->(Eof()) .And. GDBZY3->ZY3_NUMPV == TRBZY8->ZY8_NUMPV 
      If GDBZY3->ZY3_VNCZY8 == TRBZY8->ZY8_VNCZY3
         GDBZY8->(DBAPPEND())//RecLock("GDBZY8",.T.))
         
         For _nI := 1 To _nTotCampos
	    	    If AllTrim(GDBZY8->(FieldName(_nI))) $ "WK_RECNO/ZY8_ALI_WT/ZY8_REC_WT/WKRECTRBY8/WK_OK" .Or. Empty(TRBZY8->(FieldName(_nI)))
		          Loop			  
             EndIf

		       _cCampo := TRBZY8->(FieldName(_nI))
		       _cContexto := GetSx3Cache(_cCampo,"X3_CONTEXT")
             If _cContexto <> "V" 
		          &("GDBZY8->"+_cCampo) := &("TRBZY8->"+ _cCampo)
		       EndIf
	      Next

         GDBZY8->ZY8_JUSDES := POSICIONE("ZY5",1,xFilial("ZY5")+TRBZY8->ZY8_JUSCOD,"ZY5_DESCR") 
         //GDBZY8->(MsUnLock())
      EndIf 

      TRBZY8->(DbSkip())
   EndDo 

   GDBZY8->(DbGoTop() )
   GDBZY8->(DbSetOrder(2))

   nOpc :=0
   DEFINE MSDIALOG _oDlgO TITLE _cTitulo FROM _aSizeAut[7],00 To _aSizeAut[6] /1.5, _aSizeAut[5] / 1.5 Of oMainWnd PIXEL
	
      _oMarkZY8 := MsSelect():New("GDBZY8"   ,""   ,""      ,_aCmpZY8TELA   ,@_lInvzy8, @_cMarcaZY8,{_aSizeAut[7]+30 /*_aPosObj[2,1]*/, _aPosObj[2,2], _aPosObj[2,3] / 1.5, _aPosObj[2,4] / 1.5},              ,              ,               ,          ,  )        
      
   Activate MsDialog _oDlgO On Init EnchoiceBar(_oDlgO,_bOk,_bCancel,,_aButtons) CENTERED
		
   //U_Itmsg("Visualização da data prevista de estoque finalizada.","Atenção",,1)

End Sequence

GDBZY8->(DbSetOrder(1))

RestArea(aArea)

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS097P
Autor-------------: Julio de Paula Paz
Data da Criacao---: 13/08/2020
===============================================================================================================================
Descrição---------: Calcula a data sugerida de agendamento.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lRet = Sempre retorna True pois é chamada na validação de campo.
===============================================================================================================================
*/
User Function AOMS097P()
Local _lRet := .T.
Local _dDtAux := Ctod("  /  /  ")
Local _cFilCarreg := ""

Begin Sequence
      
   TRBSC5->(DbGoTop()) 
   _dDtSugAgen := Ctod("  /  /  ")
   
   aheader := {}
	aadd(aheader,{1,"C6_ITEM"})
	aadd(aheader,{2,"C6_PRODUTO"})
	aadd(aheader,{3,"C6_LOCAL"})

	Do While ! TRBSC5->(Eof())
	      
      If ! Empty(TRBSC5->WK_OK)
             
		   SC5->(DbGoto(TRBSC5->WK_RECNO))   

	      SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))
	      aCols:={}//Prepara acols para a função omsvldent  
	      Do While SC6->(!EOF()) .AND. SC5->C5_FILIAL == SC6->C6_FILIAL .AND. SC5->C5_NUM == SC6->C6_NUM
		      Aadd(acols,{SC6->C6_ITEM,SC6->C6_PRODUTO,SC6->C6_LOCAL})

		      SC6->(Dbskip())
	      Enddo

         _cFilCarreg := SC5->C5_FILIAL
         If ! Empty(SC5->C5_I_FLFNC)
            _cFilCarreg := SC5->C5_I_FLFNC
         EndIf

         _dDtAux := _dDtEstoque + U_OMSVLDENT(_dDtEstoque,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_I_FILFT,SC5->C5_NUM,1, ,_cFilCarreg,SC5->C5_I_OPER,SC5->C5_I_TPVEN)  
         
         If Dtos(_dDtAux) > Dtos(_dDtSugAgen)
            _dDtSugAgen := _dDtAux 
         EndIf

	   EndIf 	      

	   TRBSC5->(DbSkip())
   EndDo


End Sequence

Return _lRet 
//------------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------------------//

/*
=================================================================================================================================
Programa--------: AOMS097V()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 02/09/2020
=================================================================================================================================
Descrição-------: Exibe os dados do Pedido de Vendas posicionado na tela do MsBrowse.
=================================================================================================================================
Parametros------: _cOpcao = V = Visualização do Pedido de Vendas.
                          = A = Alteração do armazém do item de pedido de vendas.
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AOMS097V(_cOpcao)
Local _aStrucSC6
Local _aCmpSC6 := {}
Local _aSizeAut  := MsAdvSize(.T.)
Local _bOk, _bCancel , _cTitulo
Local _lInvSC6 := .F.
Local _oDlgEnch, _nI , _lRet:=.T.
Local _nReg := 2 , _nOpcx := 2
Local _nTotCampos, _aButtons := {} 

Private _oMarkSC6, _cMarcaSC6 := GetMark() 
Private aHeader := {} , aCols := {}

Begin Sequence
   
   SC5->(DbGoto(TRBSC5->WK_RECNO)) 

   If _cOpcao == "A"  .AND. TRBSC5->C5_I_ENVRD = "S"//Testa O STATUS DO PV
       _cQry:="SELECT STATUS FROM RDCITL.TGA447 WHERE PEDIDO = '" + ALLTRIM(TRBSC5->C5_NUM) + "' "
		 //dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBPED" , .T., .F. )
       MPSysOpenQuery( _cQry , "TRBPED")
       DBSELECTAREA( "TRBPED" )

		 If !TRBPED->(Eof())
          IF ALLTRIM(TRBPED->STATUS) <> "1"
             U_ItMsg('O Pedido está no RDC com Status ('+TRBPED->STATUS+') "Em Montagem de Carga"',"Atenção",'Por favor entrar em contato com Logística.',1)
             _lRet:=.F.
          ENDIF
       ELSE
          U_ItMsg('O Pedido '+ALLTRIM(TRBSC5->C5_NUM)+' NÃO FOI ENCONTRADO no RDC.',"Atenção",'Por favor entrar em contato com Logística.',1)
          _lRet:=.F.
       ENDIF 
       TRBPED->(Dbclosearea())
       DBSELECTAREA( "TRBSC5" )
   ENDIF 
   IF !_lRet
      BREAK
   ENDIF

   //================================================================================
   // Cria as estruturas das tabelas temporárias
   //================================================================================
   _aStrucSC6 := {}
    Aadd(_aStrucSC6,{"WKRECNO", "N", 10,0})
  
   _nTotCampos := SC6->(FCount())
   For _nI := 1 To _nTotCampos //Len(aHeader)
       If Alltrim(SC6->(FieldName(_nI))) == "C6_FILIAL" // AllTrim(aHeader[_nI,2])=="C6_FILIAL"
          Loop
       EndIf

       _cCampo    := Getsx3cache(AllTrim(SC6->(FieldName(_nI))),"X3_CAMPO") 
       _cTitulo   := Getsx3cache(AllTrim(SC6->(FieldName(_nI))),"X3_TITULO")
       _cPicture  := Getsx3cache(AllTrim(SC6->(FieldName(_nI))),"X3_PICTURE")
       _cTipo     := Getsx3cache(AllTrim(SC6->(FieldName(_nI))),"X3_TIPO")
       _nTamanho  := Getsx3cache(AllTrim(SC6->(FieldName(_nI))),"X3_TAMANHO")
       _nDecimal  := Getsx3cache(AllTrim(SC6->(FieldName(_nI))),"X3_DECIMAL")
       
       //                     Campo                 Titulo           Picture
       Aadd( _aCmpSC6 , { _cCampo , "" , _cTitulo  , _cPicture  } )
       
       Aadd(_aStrucSC6,{_cCampo ,  _cTipo , _nTamanho,_nDecimal})
   Next   

   //================================================================================
   // Verifica se ja existe um arquivo com mesmo nome, se sim fecha.
   //================================================================================
   If Select("TRBSC6") > 0
      TRBSC6->( DBCloseArea() )
   EndIf

   //================================================================================
   // Abre o arquivo TRBSC6 criado dentro do protheus.
   //================================================================================
   _otemp := FWTemporaryTable():New( "TRBSC6",  _aStrucSC6 )
   
   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _otemp:AddIndex( "01", {"C6_ITEM"} )
   _otemp:Create()   

   //================================================================================
   // Carrega os dados da tabela SC5
   //================================================================================
   _nTotCampos := SC5->(FCount()) 

   For _nI := 1 To _nTotCampos
       &("M->"+SC5->(FieldName(_nI))) :=  &("SC5->"+SC5->(FieldName(_nI)))
   Next
   
   //================================================================================
   // Carrega os dados da tabela SC6
   //================================================================================
   _nTotCampos := TRBSC6->(FCount())
   
   SC6->(DbSetOrder(1))  // C6_FILIAL+C6_NUM
   SC6->(MSSeek(SC5->(C5_FILIAL+C5_NUM)))
   Do While ! SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)
           
      TRBSC6->(DBAPPEND())//RecLock("TRBSC6",.T.))
      For _nI := 1 To _nTotCampos 
          If AllTrim(TRBSC6->(FieldName(_nI))) == "WKRECNO"
             Loop
          ElseIf Getsx3cache(AllTrim(TRBSC6->(FieldName(_nI))),"X3_CONTEXT") == "V"
             &("TRBSC6->"+TRBSC6->(FieldName(_nI))) :=  &(Getsx3cache(AllTrim(TRBSC6->(FieldName(_nI))),"X3_RELACAO")) 
          ElseIf AllTrim(TRBSC6->(FieldName(_nI))) == "C6_ALI_WT" 
             TRBSC6->C6_ALI_WT := "SC6" 
          ElseIf AllTrim(TRBSC6->(FieldName(_nI))) == "C6_REC_WT"
             TRBSC6->C6_REC_WT := SC6->(Recno())
          Else
             &("TRBSC6->"+TRBSC6->(FieldName(_nI))) :=  &("SC6->"+TRBSC6->(FieldName(_nI)))
          EndIf
      Next
      TRBSC6->WKRECNO := SC6->(Recno())
      //TRBSC6->(MsUnlock())
      
      SC6->(DbSkip())
   EndDo
   TRBSC6->(DbGoTop())
                                       
   //================================================================================
   // Monta a tela Enchoice SC5  x MsSelect SC6
   //================================================================================  
   
   If _cOpcao == "A"  
      Aadd( _aButtons , {"S4WB011N", {|| U_AOMS097S()} , "Alteração Armazem Item PV","Alteração Armazem Item PV", {|| .T.}})  // "Alteração Armazem Item PV"
   EndIf 

   _aObjects := {} 
   AAdd( _aObjects, { 315,  50, .T., .T. } )
   AAdd( _aObjects, { 100, 100, .T., .T. } )

   _aInfo := { _aSizeAut[ 1 ], _aSizeAut[ 2 ], _aSizeAut[ 3 ], _aSizeAut[ 4 ], 3, 3 } 

   _aPosObj := MsObjSize( _aInfo, _aObjects, .T. ) 
   
   _bOk := {|| _oDlgEnch:End()}
   _bCancel := {|| _lRet := .F., _oDlgEnch:End()}
                       
   _cTitulo := "Gestão de Carteira - Visualização Pedido de Vendas"
   
   Define MsDialog _oDlgEnch Title _cTitulo From _aSizeAut[7],00 To _aSizeAut[6], _aSizeAut[5] Of oMainWnd Pixel 
      
      EnChoice( "SC5" ,_nReg, _nOpcx, , , , , _aPosObj[1], , 3 )
            
      _oMarkSC6 := MsSelect():New("TRBSC6","","",_aCmpSC6,@_lInvSC6, @_cMarcaSC6,{_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4]})      
        
   Activate MsDialog _oDlgEnch On Init EnchoiceBar(_oDlgEnch,_bOk,_bCancel,,_aButtons) 

End Sequence

//================================================================================
// Fecha e exclui as tabelas temporárias
//================================================================================                    
If Select("TRBSC6") > 0
   TRBSC6->(DbCloseArea())
EndIf

Return Nil

/*
===============================================================================================================================
Programa--------: AOMS097S
Autor-----------: Julio de Paula Paz
Data da Criacao-: 22/01/2018
===============================================================================================================================
Descrição-------: Permite alterar o armazem do item de Pedido de vendas posicionado.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AOMS097S() 
Local _bOk, _bCancel 
Local _oDlgLocal
Local _lRet := .T.
Local _cTitulo
Local _cArmazAtu, _cArmazNovo, _cCodProduto 
Local _cItem, _aItens := {"Atual (Posicionado)","Todos os Itens"}
Local _nAjusteLin := 30
Local _lAlterou := .F.

Begin Sequence
   //================================================================================
   // Tela de Alteração do Armazem do item de Pedido de Vendas
   //================================================================================      
   _cTitulo := "Alteração do Armazem do item de Pedido de Vendas"
   _bOk := {|| If(U_AOMS097U(_cArmazNovo,_cCodProduto),(_lRet := .T., _oDlgLocal:End()),)}
   _bCancel := {|| _lRet := .F., _oDlgLocal:End()}
   
   _cArmazAtu := TRBSC6->C6_LOCAL 
   
   _cArmazNovo := _cArmazAtu 
   
   _cCodProduto := TRBSC6->C6_PRODUTO
   
   Define MsDialog _oDlgLocal Title _cTitulo From 9,0 To 22,55 Of oMainWnd 

      @ 06+_nAjusteLin,20 Say "Item a Ser Alterado: " Of _oDlgLocal Pixel 
      @ 06+_nAjusteLin,80 ComboBox _cItem Items _aItens Of _oDlgLocal Pixel Size 080,010 
            
      @ 26+_nAjusteLin,20 Say "Armazem Atual: " Of _oDlgLocal Pixel 
      @ 25+_nAjusteLin,80 Get _cArmazAtu Size 30, 10 WHEN .F. Of _oDlgLocal Pixel
      
      @ 46+_nAjusteLin,20 Say "Novo Armazem: " Of _oDlgLocal Pixel
      @ 45+_nAjusteLin,80 MsGet _cArmazNovo F3 "NNR" Size 30, 10 Valid(U_AOMS097U(_cArmazNovo,_cCodProduto )) Of _oDlgLocal Pixel
      
   Activate MsDialog _oDlgLocal On Init EnchoiceBar(_oDlgLocal,_bOk,_bCancel) CENTERED 

   //================================================================================
   // Altera o armazem do Acol se confirmado a alteração pele usuário.
   //================================================================================
   If _lRet
      If _cItem == "Atual (Posicionado)"
         //===========================================================
         // Atualiza apenas o item de pedido de vendas posicionado.
         //===========================================================
         SC6->(DbGoto(TRBSC6->WKRECNO))
         SC6->(RecLock("SC6", .F.))
         SC6->C6_LOCAL := _cArmazNovo 
         SC6->(MsUnlock())
         
         //====================================
         // Atualiza tabela temporária.
         //====================================
         //TRBSC6->(RecLock("TRBSC6", .F.))
         TRBSC6->C6_LOCAL := _cArmazNovo 
         //TRBSC6->(MsUnlock())
         _lAlterou := .T.
      Else
         //===============================================
         // Atualiza todos os itens do pedido de vendas.
         //===============================================
         TRBSC6->(DbGoTop())  
         Do While ! TRBSC6->(Eof())
            //====================================
            // Atualiza tabela SC6
            //====================================
            SC6->(DbGoto(TRBSC6->WKRECNO))
            SC6->(RecLock("SC6", .F.))
            SC6->C6_LOCAL := _cArmazNovo 
            SC6->(MsUnlock())
            
            //====================================
            // Atualiza tabela temporária.
            //====================================
            //TRBSC6->(RecLock("TRBSC6", .F.))
            TRBSC6->C6_LOCAL := _cArmazNovo 
            //TRBSC6->(MsUnlock())
            
            _lAlterou := .T.

            TRBSC6->(DbSkip())
         EndDo 
         TRBSC6->(DbGoTop()) 
      EndIf
      If _lAlterou
         U_Itmsg("Alteração de Armazens realizada com sucesso.","Atenção",,2) 
      EndIf 
   Else  
      //U_Itmsg("Rotina de alteração de Armazens dos Pedidos de Vendas Cancelada pelo usuário.","Atenção",,1) 
   EndIf

   
End Sequence

Return Nil

/*
===============================================================================================================================
Programa--------: AOMS097U
Autor-----------: Julio de Paula Paz
Data da Criacao-: 08/09/2020
===============================================================================================================================
Descrição-------: Rotina de validação das digitações dos armazens.
===============================================================================================================================
Parametros------: _cArmazNovo = Novo código de armazem
                  _cCodProduto = Código do produto.
===============================================================================================================================
Retorno---------: _lRet = .T. validação OK.
                          .F. falha na validação.
===============================================================================================================================
*/
User Function AOMS097U(_cArmazNovo,_cCodProduto)
Local _lRet := .T.
Local _aOrd := SaveOrd({"SB2","NNR"})

Begin Sequence
  
   //SB2->(DbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
   NNR->(DbSetOrder(1)) // NNR_FILIAL+NNR_CODIGO
   
   If Empty(_cArmazNovo)
      U_ITMSG("O novo código do armazem precisa ser informado.","Atenção.", ,1) 
      lRet := .F.
      Break
   EndIf
   
   If ! NNR->(DbSeek(xFilial("NNR")+_cArmazNovo))
      U_ITMSG("O código de armazem informado não existe. ","Atenção.", ,1) 
      lRet := .F.
      Break
   EndIf
   
End Sequence

RestOrd(_aOrd)

Return _lRet

/*
===============================================================================================================================
Programa--------: AOMS97FIL
Autor-----------: Julio de Paula Paz
Data da Criacao-: 09/09/2020
===============================================================================================================================
Descrição-------: Permite filtrar dados da tela após Browser, conforme legenda selecionada.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AOMS97FIL()
Local _aCmpLeg := {} , _nI
Local _aLeg := {}, _cTitulo
Local _cMarcaLeg := GetMark()
Local _lInvLeg := .F.
Local _lRet := .F.
Local _bOk, _bCancel

Private _aCoresLeg :={}, _bLeg

Begin Sequence
   Aadd(_aLeg,{"1","Agendamento maior que o permitido."}) // "BR_VIOLETA"
   Aadd(_aLeg,{"2","Aguardando data para Faturamento."})  // "BR_AZUL"
   Aadd(_aLeg,{"3","Cobrar faturamento."})                // "BR_VERDE"
   Aadd(_aLeg,{"4","Faturamento urgente."})               // "BR_AMARELO"
   Aadd(_aLeg,{"5","Perdeu agenda."})                     // "BR_VERMELHO"
   Aadd(_aLeg,{"6","Bloqueado para Faturamento."})        // "BR_CINZA"

   _cTitulo := "Filtro por Legenda - Gestão de Carteira de Pedidos de Vendas"

   _aCmpLeg := {}
   Aadd( _aCmpLeg , { "WK_OK"	   ,    , "Marca"      ,"@!"})
   Aadd( _aCmpLeg , { "WK_DESCRI", "" , "Descrição"  , "@!" } )

   _aStruct := {}
   Aadd(_aStruct, {"WK_OK"     , "C" , 2  , 0})
   Aadd(_aStruct, {"WK_DESCRI" , "C" , 50 , 0})
   Aadd(_aStruct, {"WK_LEGENDA", "C" , 1  , 0})

   If Select("TRBLEG") > 0
      TRBLEG->(DbCloseArea())
   EndIf

   _otemp := FWTemporaryTable():New( "TRBLEG", _aStruct )
    
   _otemp:AddIndex( "I1", {"WK_LEGENDA"} )
   _otemp:Create()
   
   For _nI := 1 To Len(_aLeg)
       TRBLEG->(DBAPPEND())//RecLock("TRBLEG",.T.))
       TRBLEG->WK_LEGENDA := _aLeg[_nI,1] 
       TRBLEG->WK_DESCRI  := _aLeg[_nI,2] 
       //TRBLEG->(MsUnLock())
   Next 
   TRBLEG->(DbGoTop())

   _aCoresLeg:={}
    _bLeg := {|| TRBLEG->WK_LEGENDA} //Função que carrega váriavel com cores da legenda
   AADD(_aCoresLeg,{'Eval(_bLeg)=="1"',"BR_VIOLETA"})   // Agendamento maior que o permitido
   AADD(_aCoresLeg,{'Eval(_bLeg)=="2"',"BR_AZUL"})      // Aguardando data para Faturamento
   AADD(_aCoresLeg,{'Eval(_bLeg)=="3"',"BR_VERDE"})     // Cobrar faturamento
   AADD(_aCoresLeg,{'Eval(_bLeg)=="4"',"BR_AMARELO"})   // Faturamento urgente
   AADD(_aCoresLeg,{'Eval(_bLeg)=="5"',"BR_VERMELHO"})  // Perdeu agenda
   AADD(_aCoresLeg,{'Eval(_bLeg)=="6"',"BR_CINZA"})     // Bloqueado para Faturamento
  
   _bOk := {|| _lRet := .T., _oDlgG:End()}
   _bCancel := {|| _lRet := .F., _oDlgG:End()}

   Define MsDialog _oDlgG Title _cTitulo From 00,00 To 250, 500 Of oMainWnd Pixel 

	  _oMarkLeg := MsSelect():New("TRBLEG"   ,"WK_OK"   ,""      ,_aCmpLeg   ,@_lInvLeg, @_cMarcaLeg,{30, 05, 120, 250},              ,              ,               ,          ,  _aCoresLeg  )      
        
   Activate MsDialog _oDlgG On Init EnchoiceBar(_oDlgG,_bOk,_bCancel,,_aButtons) CENTERED 

   If _lRet
      _cSelecLeg := ""
      TRBLEG->(DbGoTop())
      Do While ! TRBLEG->(Eof())
         If ! Empty(TRBLEG->WK_OK)
            _cSelecLeg += TRBLEG->WK_LEGENDA + "/"
         EndIf
         TRBLEG->(DbSkip())
      EndDo 

      If Empty(_cSelecLeg)
         U_ITMSG("Nenhuma legenda foi selecionda. A filtragem de dados não poderá ser realizada.","Atenção.", ,1) 
         Break
      EndIf
      
      TRBSC5->(DbSetFilter({|| WK_LEGENDA $ _cSelecLeg}, "WK_LEGENDA $ _cSelecLeg"))
      TRBSC5->(DbGoTop())
	   U_AOMS097H()
      
      _oMarkSC5:OBrowse:Refresh()
      
      U_ITMSG("Filtragem por legenda realizada com sucesso.","Atenção.", ,2) 
   Else
      //U_ITMSG("Filtragem por legenda cancelada pelo usuário.","Atenção.", ,1) 
   EndIf 
   
End Sequence

If Select("TRBLEG") > 0
   TRBLEG->(DbCloseArea())
EndIf

Return Nil

/*
===============================================================================================================================
Programa--------: AOMS97Clear
Autor-----------: Julio de Paula Paz
Data da Criacao-: 09/09/2020
===============================================================================================================================
Descrição-------: Permite cancelar a filtragem por legenda.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AOMS97Clear()

Begin Sequence
   
   TRBSC5->(DBClearFilter())
   TRBSC5->(DbGoTop())
	U_AOMS097H()
      
   _oMarkSC5:OBrowse:Refresh()

   U_ITMSG("Filtragem por legenda cancelada com sucesso.","Atenção.", ,2) 

End Sequence

Return Nil


/*
===============================================================================================================================
Programa--------: AOM97ZY5
Autor-----------: Julio de Paula Paz
Data da Criacao-: 16/07/2021
===============================================================================================================================
Descrição-------: Manutenção no cadastro de Justificativas de Alteração de Pedidos de Vendas
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function AOM97ZY5

Local cAlias	:= "ZY5"
Local cTitulo	:= "Cadastro de Justificativas de Alteração de Pedidos de Vendas"

dbSelectArea(cAlias)
dbSetOrder(1)
AxCadastro(cAlias,cTitulo,,)

return  

/*
===============================================================================================================================
Programa--------: INILOG6
Autor-----------: Julio de Paula Paz
Data da Criacao-: 22/10/2018
===============================================================================================================================
Descrição-------: Grava situação inicial do SC6 para log e alterações
===============================================================================================================================
Parametros------: _aCampos
===============================================================================================================================
Retorno---------: _lret - validação da condição
===============================================================================================================================
*/
Static Function INILOG6(_aCampos)
Local _nI
Local _nTotCampos
Local _cCampo, _cCpoAux
Local _aLogSC6:={}
DEFAULT _aCampos	:= {'C6_ITEM','C6_PRODUTO','C6_PRCVEN','C6_TES','C6_QTDVEN','C6_LOCAL','C6_PEDCLI'}

SC6->( DBSetOrder(1) )
_nTotCampos := LEN(_aCampos)

If SC6->( DBSeek( SC5->( C5_FILIAL + C5_NUM ) ) )
	Do While SC6->(!Eof()) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->( C5_FILIAL + C5_NUM )
		For _nI := 1 To _nTotCampos
			_cCampo := AllTrim(_aCampos[_nI])//AllTrim(SC6->(FieldName(_nI)))
			_cCpoAux := "SC6->"+ _cCampo
			aAdd( _aLogSC6 , { SC6->( C6_FILIAL + C6_NUM + SC6->C6_ITEM ) , _cCampo , &_cCpoAux } )
		Next
		SC6->( DBSkip() )
	EndDo
EndIf

Return _aLogSC6

/*
===============================================================================================================================
Programa----------: AOMS97VLJU
Autor-------------: Julio de Paula Paz
Data da Criacao---: 14/05/2025
===============================================================================================================================
Descrição---------: Valida a digitação da justificativa de alteração de tipo de agendamenteo e alteração de data de entrega.
===============================================================================================================================
Parametros--------: _cDado  = Informação a ser validada
                    _cCampo = Campo que chamou a validação.
===============================================================================================================================
Retorno-----------: _lRet := .T. = Dados corretos
                             .F. = Erro nos dados
===============================================================================================================================
*/
Static Function AOMS97VLJU(_cDado, _cCampo)
Local _lRet := .T.

Begin Sequence 
   
   If Empty(_cDado) // (_lAltData .And. Empty(_cDado)) .Or. (_lAltAgen .And. Empty(_cDado))
      U_MT_ITMSG("O código de justificativa não foi informado.","Atenção",,1)
      _lRet := .F.
      Break 
   EndIf 

   ZY5->(DbSetOrder(1))
   If ! ZY5->(MsSeek(xFilial("ZY5")+_cDado))
      U_MT_ITMSG("O código de justificativa informado não existe.","Atenção",,1)
      _lRet := .F.
   Else 
      If _cCampo == "C5_I_AGEND"
         _cObseAG := ZY5->ZY5_DESCR
      Else 
         _cObseDE := ZY5->ZY5_DESCR
      EndIf 
   EndIf 

End Sequence 

Return _lRet 
