/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer |24/01/2024| Chamado 46063. Jerry. Adicionado 2 novas colunas: "Tipo de entrega" e "Dt NF Emissao".
Alex Wallauer |08/02/2024| Chamado 44782. Jerry. Ajustes para a nova opcao de tipo de entrega: O = Agendado pelo Op.Log.
Lucas Borges  |09/10/2024| Chamado 48465. Retirada manipulação do SX1
=================================================================================================================================================================================
 Analista      - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
=================================================================================================================================================================================
Jerry Santiago - Julio Paz     - 29/01/25 - 26/02/25 - 48758   - Inclusão de Novas Informações a Serem Exibidas na Rotina de Exportação de Dados de Ocorrências de Frete.
Jerry Santiago - Igor Melgaço  - 03/04/25 - 04/04/25 - 50342   - Ajustes para melhoria de performance.
Jerry Santiago - Igor Melgaço  - 28/05/25 - 30/05/25 - 50817   - Ajustes para ordem de coluna do cabeçalho.
Jerry Santiago - Alex Wallauer - 18/07/25 - 01/08/25 - 49733   - Adicionado os campos: ZF5_CAUCUS,F2_I_PENCL,F2_I_PENOL,F2_VALBRUT,F2_VALMERC
=================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include	"Protheus.Ch"

/*
===============================================================================================================================
Programa----------: MOMS031
Autor-------------: Josué Danich Prestes
Data da Criacao---: 16/02/2016
Descrição---------: Exportação de dados de ocorrência de fretes - Chamado 16351
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User function MOMS031()

Local _bProcess := nil As Block

Private _lSai  := .T. As Logical
Private _cPerg := "MOMS031" As Character
Private _oSelf := Nil As Object

_bSelectSX5 := {||"SELECT DISTINCT X5_CHAVE, X5_DESCRI FROM "+RETSQLNAME("SX5")+" SX5 WHERE D_E_L_E_T_ = ' ' AND X5_TABELA = 'ZC' ORDER BY X5_CHAVE "  }
    
_aItalac_F3 := {} //       1           2         3                      4                      5               6                    7         8          9         10         11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela    ,_nCpoChave           , _nCpoDesc            ,_bCondTab    , _cTitAux            , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR21"   ,_bSelectSX5 ,{|Tab| (Tab)->X5_CHAVE }, {|Tab|(Tab)->X5_DESCRI } ,/*_bCondSA1*/ ,"Regionais",,,,.F.        ,       , } )

Do While _lSai

   _lSai := .F.
   _bProcess    := {|_oSelf| U_MOMS031P(_oSelf,.F.)  }	

   tNewProcess():New(	"MOMS031"                                    ,; // Função inicial
                        "Exporta Tabela Ocorrencias"                 ,; // Descrição da Rotina
                        _bProcess                                    ,; // Função do processamento
                        "Rotina de geração de Tabela de Ocorrências",;// Descrição da Funcionalidade
                        "MOMS031"                                    ,; // Configuração dos Parâmetros
                        {}                                           ,; // Opções adicionais para o painel lateral
                        .F.                                          ,; // Define criação do Painel auxiliar
                        0                                            ,; // Tamanho do Painel Auxiliar
                        ''                                           ,; // Descrição do Painel Auxiliar
                        .T.                                          ,; // Se .T. exibe o painel de execução. Se falso, apenas executa a função sem exibir a régua de processamento.
                        .T.                                           ) // Se .T. cria apenas uma regua de processamento.

EndDo

Return

/*
===============================================================================================================================
Programa----------: MOMS031P
Autor-------------: Josué Danich Prestes
Data da Criacao---: 16/02/2016
Descrição---------: Processamento de exportação de dados de ocorrência de fretes 
Parametros--------: _oSelf - objeto da dialog
                    _lAuto - se rodando auto
Retorno-----------: Nenhum
===============================================================================================================================
*/
User function MOMS031P(_oSelf As Object, _lAuto As Logical)

Local _cNomeCliente := ""  As Character
Local _nLenCodCliente := TAMSX3("A1_COD")[1] As Numeric //Tamanho do campo 
Local _cColaborador := "" As Character
Local _cDescServico := "" As Character
Local _cCodsuper    := "" As Character
Local _cNomesuper   := "" As Character
Local _cCodGer      := "" As Character
Local _cNomeGer     := "" As Character
Local _cCodCoord    := "" As Character
Local _cNomeCoord   := "" As Character
Local _aCabecalho   := {} As Array
Local _cQuery       := "" As Character
Local _aDados       := {} As Array
Local _nConta       := 0 As Numeric
Local _nTotRegs     := 0 As Numeric
Local _cTotal       := "" As Character
Local _dDtEmisao    := Ctod("") As Date
Local _dDtCanhot    := Ctod("") As Date
Local _dDtEmisPV    := Ctod("") As Date
//Local _cCliRem      := Space(6) As Character
//Local _cLojaclRe    := Space(4) As Character
Local _cNomClRem    := Space(40) As Character    
Local _cNfRem       := Space(9) As Character
Local _dDtEntCli    := Ctod("") As Date

Local _cOperlogi    := Space(6) As Character
Local _cLojOpLog    := Space(4) As Character
Local _cNomOpLog    := Space(40) As Character
Local _nLeadTime    := 0 As Numeric
Local _cAliasTMP    := "" As Character

Default _lAuto := .F.

If !_lAuto
  _oSelf:SetRegua1( 3 )
  _oSelf:IncRegua1( "1-Buscando dados (Executando SELECT), Aguarde...")
EndIf

_lSai := .T.

cTimeInicial:=TIME()
_cAliasTMP := GetNextAlias()

If _lAuto
   _oSelf:cCaption := ("Buscando dados (Executando SELECT), Aguarde...")
   MV_PAR07 := u_MOMS031L()
   ProcessMessages()
Else
  _oSelf:IncRegua1( "2-Buscando dados (Executando SELECT), Aguarde...")
EndIf

_cQuery := "SELECT SC5.C5_FILIAL, SC5.C5_I_FLFNC, SC5.C5_I_FILFT, SC5.C5_I_TRCNF,SA1.A1_NOME, SA1.A1_EST, SA1.A1_MUN, ZF5.*,"
_cQuery += " SC5.C5_I_AGEND, SA3.A3_TIPO, SA3.A3_NOME, SA3.A3_I_SUPE, SA3.A3_GEREN, SA3.A3_SUPER, "
_cQuery += " SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_NUM, SC5.C5_I_OPER, SC5.C5_I_TPVEN, SC5.C5_I_DIASV,SC5.C5_I_DIASO, "
_cQuery += " SC6.C6_I_QPALT, ZF5.ZF5_CAUCUS,SF2.F2_I_PENCL,SF2.F2_I_PENOL,SF2.F2_VALBRUT,SF2.F2_VALMERC , "//Campos adicionados ZF5_CAUCUS,F2_I_PENCL,F2_I_PENOL,F2_VALBRUT,F2_VALMERC
_cQuery += " SF2.F2_EMISSAO, SF2.F2_I_DTRC, DAI_I_OPLO, DAI_I_LOPL, DAI_I_TRED, DAI_I_LTRE, "
_cQuery += " SA2.A2_NOME AS NOMEOPLOG, SA2_2.A2_NOME AS NOMERED, ZFD_DESCRI, "
_cQuery += " SC5_2.C5_NOTA AS R_C5_NOTA, SA1_2.A1_NOME AS R_A1_NOME, "//SC5_2.C5_CLIENT AS R_C5_CLIENT, SC5_2.C5_LOJACLI AS R_C5_LOJACLI,
_cQuery += " SF2_2.F2_I_DENCL AS R_F2_I_DENCL, "
_cQuery += " SC5.C5_VEND4  , SA3_2.A3_NOME AS NOMESUP, "
_cQuery += " SC5.C5_VEND3  , SA3_3.A3_NOME AS NOMEGER, "
_cQuery += " SC5.C5_VEND2  , SA3_4.A3_NOME AS NOMECOO, "
_cQuery += " SC5.C5_ASSNOM , ZAM_REGCOD, SC5.C5_I_PVREM, SA1.A1_I_SHLFP, SC5.C5_NUM, SC5.C5_I_IDPED, SC5.C5_I_OPER, SC5.C5_EMISSAO, "
_cQuery += " (SELECT X5_DESCRI FROM " + RetSqlName("SX5") + " SX5 WHERE ZAM.ZAM_REGCOD = SX5.X5_CHAVE AND SX5.X5_TABELA = 'ZC' AND SX5.D_E_L_E_T_ = ' ' ) AS  ZAM_REGDES "

_cQuery += " FROM " + RetSqlName("ZF5") + " ZF5 " 
_cQuery += " JOIN " + RetSqlName("SC5") + " SC5 ON SC5.C5_FILIAL = ZF5.ZF5_FILIAL AND SC5.C5_NUM = ZF5.ZF5_PEDIDO AND SC5.D_E_L_E_T_ = ' ' "

_cQuery += " LEFT JOIN (" 
_cQuery += "   SELECT C6_FILIAL, C6_NUM, SUM(C6_I_QPALT) AS C6_I_QPALT" 
_cQuery += "   FROM " + RetSqlName("SC6") + " SC6 "
_cQuery += "   WHERE SC6.D_E_L_E_T_ = ' ' "
_cQuery += "   GROUP BY C6_FILIAL, C6_NUM "
_cQuery += " ) SC6 ON SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM "

_cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1 ON Substr(ZF5.ZF5_CLIENT,1," + Alltrim(Str(_nLenCodCliente)) + ") = SA1.A1_COD AND ZF5.ZF5_LOJA = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = ' ' "
_cQuery += " LEFT JOIN " + RetSqlName("SA3") + " SA3 ON ZF5.ZF5_REPRES = SA3.A3_COD AND SA3.D_E_L_E_T_ = ' ' "
_cQuery += " LEFT JOIN " + RetSqlName("SA3") + " SA3_2 ON SC5.C5_VEND4 = SA3_2.A3_COD AND SA3_2.D_E_L_E_T_ = ' ' "
_cQuery += " LEFT JOIN " + RetSqlName("SA3") + " SA3_3 ON SC5.C5_VEND3 = SA3_3.A3_COD AND SA3_3.D_E_L_E_T_ = ' ' "
_cQuery += " LEFT JOIN " + RetSqlName("SA3") + " SA3_4 ON SC5.C5_VEND2 = SA3_4.A3_COD AND SA3_4.D_E_L_E_T_ = ' ' "
_cQuery += " LEFT JOIN " + RetSqlName("ZAM") + " ZAM ON ZAM.ZAM_COOCOD = SC5.C5_VEND2 AND ZAM.ZAM_GERCOD = SC5.C5_VEND3 AND ZAM.D_E_L_E_T_ = ' ' "
_cQuery += " LEFT JOIN " + RetSqlName("SF2") + " SF2 ON ZF5.ZF5_FILIAL = SF2.F2_FILIAL AND ZF5.ZF5_DOCOC = SF2.F2_DOC AND ZF5.ZF5_SEROC = SF2.F2_SERIE AND ZF5.ZF5_CLIENT = SF2.F2_CLIENTE AND ZF5.ZF5_LOJA = SF2.F2_LOJA AND SF2.D_E_L_E_T_ = ' ' "

_cQuery += " LEFT JOIN (" 
_cQuery += "   SELECT DAI_FILIAL, DAI_PEDIDO, DAI_I_OPLO, DAI_I_LOPL, DAI_I_TRED, DAI_I_LTRE " 
_cQuery += "   FROM " + RetSqlName("DAI") + " DAI "
_cQuery += "   WHERE DAI.D_E_L_E_T_ = ' ' "
_cQuery += "   GROUP BY DAI_FILIAL, DAI_PEDIDO, DAI_I_OPLO, DAI_I_LOPL, DAI_I_TRED, DAI_I_LTRE "
_cQuery += " ) DAI ON ZF5.ZF5_FILIAL = DAI.DAI_FILIAL AND SC5.C5_NUM = DAI.DAI_PEDIDO "

_cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2 ON DAI.DAI_I_OPLO = SA2.A2_COD AND DAI.DAI_I_LOPL = SA2.A2_LOJA AND SA2.D_E_L_E_T_ = ' ' "
_cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2_2 ON DAI.DAI_I_TRED = SA2_2.A2_COD AND DAI.DAI_I_LTRE = SA2_2.A2_LOJA AND SA2_2.D_E_L_E_T_ = ' ' "
_cQuery += " LEFT JOIN " + RetSqlName("ZFD") + " ZFD ON ZF5.ZF5_STATUS = ZFD.ZFD_CODIGO AND ZFD.D_E_L_E_T_ = ' ' "
_cQuery += " LEFT JOIN " + RetSqlName("SC5") + " SC5_2 ON SC5_2.C5_FILIAL = SC5.C5_FILIAL AND SC5_2.C5_NUM = SC5.C5_I_PVREM AND SC5_2.D_E_L_E_T_ = ' ' "
_cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1_2 ON SC5_2.C5_CLIENT = SA1_2.A1_COD AND SC5_2.C5_LOJACLI = SA1_2.A1_LOJA AND SA1_2.D_E_L_E_T_ = ' ' "
_cQuery += " LEFT JOIN " + RetSqlName("SF2") + " SF2_2 ON SC5_2.C5_FILIAL = SF2_2.F2_FILIAL AND SC5_2.C5_NUM = SF2_2.F2_I_PEDID AND SF2_2.D_E_L_E_T_ = ' ' "

_cQuery += " WHERE ZF5.D_E_L_E_T_ = ' ' " 

If !Empty(MV_PAR01)   
   _cQuery += " AND ZF5_DTFIN >= '" + DTOS(MV_PAR01) + "' "
EndIf 

If !Empty(MV_PAR02)
   _cQuery += " AND ZF5_DTFIN <= '" + DTOS(MV_PAR02) + "' "
EndIf

If !Empty(MV_PAR03)
   _cQuery += " AND ZF5_FILIAL IN " + FORMATIN(MV_PAR03,";") 
EndIf

If !Empty(MV_PAR04)
   _cQuery += " AND ZF5_DTINI >= '" + DTOS(MV_PAR04) + "' "
EndIf

If !Empty(MV_PAR05)
   _cQuery += " AND ZF5_DTINI <= '" + DTOS(MV_PAR05) + "' "
EndIf

If !Empty(MV_PAR06)
   _cQuery += " AND ZF5_TIPOO IN " + FORMATIN(MV_PAR06,";") 
EndIf

If !Empty(MV_PAR07)
   _cQuery += " AND ZF5_STATUS IN " + FORMATIN(MV_PAR07,";") 
EndIf

If MV_PAR08 == 2
   _cQuery +=" AND ZF5_APRREJ = 'R' "
ElseIf MV_PAR08 == 1
   _cQuery +=" AND ZF5_APRREJ = 'A' "
EndIf 

If !Empty(MV_PAR10)
   _cQuery += " AND ZF5_COORD IN " + FORMATIN(MV_PAR10,";") 
EndIf

If !Empty(MV_PAR11)
   _cQuery += " AND ZF5_REPRES IN " + FORMATIN(MV_PAR11,";") 
EndIf

If !empty(MV_PAR12)
   _cQuery += " AND (SELECT A1_GRPVEN FROM "  +  retsqlname("SA1") + " SA1 WHERE SA1.D_E_L_E_T_ = ' ' AND A1_COD = ZF5_CLIENT AND A1_LOJA = ZF5_LOJA) >= '" + MV_PAR12 + "' "
   _cQuery += " AND (SELECT A1_GRPVEN FROM "  +  retsqlname("SA1") + " SA1 WHERE SA1.D_E_L_E_T_ = ' ' AND A1_COD = ZF5_CLIENT AND A1_LOJA = ZF5_LOJA) <= '" + MV_PAR13 + "' "
EndIf

If !empty(MV_PAR14)
   _cQuery += " AND ZF5_CLIENT >= '" + MV_PAR14 + "' AND ZF5_LOJA >= '" + MV_PAR15 + "' "
   _cQuery += " AND ZF5_CLIENT <= '" + MV_PAR16 + "' AND ZF5_LOJA <= '" + MV_PAR17 + "' "
EndIf 

If !Empty(MV_PAR19)
   _cQuery += " AND SA1.A1_EST IN " + FORMATIN(MV_PAR19,";") 
EndIf

If !Empty(MV_PAR20)
   _cQuery += " AND SC5.C5_VEND3 IN " + FORMATIN(MV_PAR20,";") 
EndIf

If !Empty(MV_PAR21)
   _cQuery += " AND ZAM.ZAM_REGCOD IN " + FORMATIN(MV_PAR21,";") 
EndIf

_cQuery += " ORDER BY ZF5_DTINI"

MPSysOpenQuery( ChangeQuery(_cQuery) , _cAliasTMP )

If _lAuto
   _oSelf:cCaption := ("Contando dados, Aguarde...")
   ProcessMessages()
Else
   _oSelf:IncRegua1("3-Contando dados, Aguarde...")
EndIf

DbSelectArea(_cAliasTMP)
COUNT TO _nTotRegs 

_cTotal := ALLTRIM(STR(_nTotRegs))

If !_lAuto
   _oSelf:SetRegua1( _nTotRegs )
EndIf

(_cAliasTMP)->( Dbgotop() )
Do While (_cAliasTMP)->(!EOF())

   _nConta++
   If _lAuto
      _oSelf:cCaption := ("Registros Lidos: "+ALLTRIM(STR(_nConta))+" de "+_cTotal)
      ProcessMessages()
   Else	
      _oSelf:IncRegua1( "Registros Lidos: "+ALLTRIM(STR(_nConta))+" de "+_cTotal )	  
   EndIf

   _cCodsuper    := "" 
   _cNomesuper   := ""
   _cCodGer      := ""
   _cNomeGer     := ""
   _cCodCoord    := ""
   _cNomeCoord   := ""
   _cColaborador := ""

   //Tratamento para variação de tipo de parâmetro conforme configurações de usuário

   If (_cAliasTMP)->A3_TIPO == "I" //SA3->A3_TIPO == "I"
      _cColaborador := "Interno"
   ElseIf (_cAliasTMP)->A3_TIPO == "E"
      _cColaborador := "Externo"
   ElseIf (_cAliasTMP)->A3_TIPO == "P"
      _cColaborador := "Parceiro"                                                                                                  
   EndIf

   _cCodsuper   := (_cAliasTMP)->C5_VEND4 // Supervisor 
   _cCodGer     := (_cAliasTMP)->C5_VEND3 // Gerente
   _cCodCoord   := (_cAliasTMP)->C5_VEND2 // Coordenador	
   _cNomesuper  := (_cAliasTMP)->NOMESUP
   _cNomeGer    := (_cAliasTMP)->NOMEGER
   _cNomeCoord  := (_cAliasTMP)->NOMECOO
   _cStatus     := (_cAliasTMP)->ZF5_STATUS + "-" + (_cAliasTMP)->ZFD_DESCRI //posicione("ZFD",1,xfilial("ZFD")+(_cAliasTMP)->ZF5_STATUS,"ZFD_DESCRI")	
   _cNomeCliente:= (_cAliasTMP)->A1_NOME

   _cDescServico:= ""
   If (_cAliasTMP)->ZF5_SERVIC == "1"						
      _cDescServico := "Descarga"
   ElseIf (_cAliasTMP)->ZF5_SERVIC == "2"
      _cDescServico := "Deslocamento"
   ElseIf (_cAliasTMP)->ZF5_SERVIC == "3"
      _cDescServico := "Diaria" 
   ElseIf (_cAliasTMP)->ZF5_SERVIC == "4"
      _cDescServico := "Reentrega"
   ElseIf (_cAliasTMP)->ZF5_SERVIC == "5"
      _cDescServico := "Outros"
   EndIf

   _cDescTipoAgen := U_TipoEntrega((_cAliasTMP)->C5_I_AGEND)

   _dDtEmisPV  := stod((_cAliasTMP)->C5_EMISSAO) // Dt Emissao Ped.Vendas
   _dDtEmisao  := stod((_cAliasTMP)->F2_EMISSAO)
   _dDtCanhot  := stod((_cAliasTMP)->F2_I_DTRC)

   //_cCliRem   := Space(6)
   //_cLojaclRe := Space(4)
   _cNomClRem := Space(40)
   _cNfRem    := Space(9)
   _dDtEntCli := Ctod("") 
   
   _cOperlogi := Space(6)
   _cLojOpLog := Space(4)
   _cNomOpLog := Space(40)

   _cOperRede := Space(6)
   _cLojOpRed := Space(4)
   _cNomOpRed := Space(40)

   If !Empty((_cAliasTMP)->C5_I_PVREM)
      //_cCliRem   := (_cAliasTMP)->R_C5_CLIENT
      //_cLojaclRe := (_cAliasTMP)->R_C5_LOJACLI
      _cNomClRem := (_cAliasTMP)->R_A1_NOME
      _cNfRem    := (_cAliasTMP)->R_C5_NOTA
      _dDtEntCli := stod((_cAliasTMP)->R_F2_I_DENCL)
   EndIf

   If !Empty((_cAliasTMP)->DAI_I_OPLO)  // (codigo)
      _cOperlogi := (_cAliasTMP)->DAI_I_OPLO // (codigo)
      _cLojOpLog := (_cAliasTMP)->DAI_I_LOPL // (loja)
      _cNomOpLog := (_cAliasTMP)->NOMEOPLOG
   EndIf 
   
   If !Empty((_cAliasTMP)->DAI_I_TRED)
      _cOperRede := (_cAliasTMP)->DAI_I_TRED // (Codigo)
      _cLojOpRed := (_cAliasTMP)->DAI_I_LTRE // (Loja)
      _cNomOpRed := (_cAliasTMP)->NOMERED
   EndIf 

   _cTipoVeic := MOMS031A((_cAliasTMP)->C6_I_QPALT)

   _nDiasViag  := (_cAliasTMP)->C5_I_DIASV
   _nDiasOper  := (_cAliasTMP)->C5_I_DIASO
   _nLeadTime  := (_cAliasTMP)->C5_I_DIASV + (_cAliasTMP)->C5_I_DIASO
   
   IF !EMPTY((_cAliasTMP)->ZF5_CAUCUS)
      aSX5Z2:=FwGetSX5("Z2",(_cAliasTMP)->ZF5_CAUCUS)//Vetor com os dados do SX5 com: [1] FILIAL [2] TABELA [3] CHAVE [4] DESCRICAO   
      _cZF5_CAUCUS:=Alltrim(aSX5Z2[1,3])+"-"+Alltrim(aSX5Z2[1,4])
   Else
      _cZF5_CAUCUS:= "  "
   EndIf

   aadd(_aDados ,{   (_cAliasTMP)->ZF5_FILIAL ,;                  // 01   
                     (_cAliasTMP)->ZF5_DOCOC ,;                   // 02
                     (_cAliasTMP)->ZF5_SEROC ,;                   // 03
                     (_cAliasTMP)->ZF5_CODIGO ,;                  // 04
                     dtoc(stod((_cAliasTMP)->ZF5_DATAE))	,;       // 05
                     dtoc(stod((_cAliasTMP)->ZF5_DTINI))	,;       // 06
                     dtoc(stod((_cAliasTMP)->ZF5_DTFIN))	,;       // 07
                     _cStatus ,;                                  // 08
                     (_cAliasTMP)->ZF5_MOTIVO ,;                  // 09
                     (_cAliasTMP)->ZF5_CLIENT ,;                  // 10
                     (_cAliasTMP)->ZF5_LOJA ,;                    // 11
                     _cNomeCliente ,;                             // 12  
                     (_cAliasTMP)->A1_MUN ,;                      // 13
                     (_cAliasTMP)->A1_EST ,;                      // 14
                     (_cAliasTMP)->ZF5_PEDIDO ,;                  // 15
                     _cColaborador ,;                             // 16   	
                     (_cAliasTMP)->ZF5_REPRES ,;                  // 17
                     (_cAliasTMP)->ZF5_NREPRE ,;                  // 18
                     _cCodsuper ,;                                // 19
                     _cNomesuper ,;                               // 20
                     _cCodCoord ,;                                // 21    
                     _cNomeCoord ,;                               // 22    
                     _cCodGer ,;                                  // 23 
                     _cNomeGer ,;                                 // 24
                     (_cAliasTMP)->ZF5_CARGA		,;                // 25
                     dtoc(stod((_cAliasTMP)->ZF5_DTCAR)) ,;       // 26
                     (_cAliasTMP)->ZF5_SERVIC ,;                  // 27
                     _cDescServico ,;                             // 28
                     (_cAliasTMP)->ZF5_CUSTO ,;                   // 29
                     (_cAliasTMP)->ZF5_VLRTOT ,;                  // 30 
                     (_cAliasTMP)->ZF5_VALEMB ,;                  // 31
                     (_cAliasTMP)->ZF5_CUSTOC ,;                  // 32
                     (_cAliasTMP)->ZF5_CUSTOI ,;                  // 33
                     (_cAliasTMP)->ZF5_CUSTOR ,;                  // 34
                     (_cAliasTMP)->ZF5_CUSTOT ,;                  // 35
                     (_cAliasTMP)->ZF5_CUSTER ,;                  // 36 
                     (_cAliasTMP)->ZF5_OBSFR ,;                   // 37
                     (_cAliasTMP)->ZF5_MOTCUS ,;                  // 38
                     (_cAliasTMP)->ZF5_AGENDA ,;                  // 39                                                                        
                     (_cAliasTMP)->ZF5_USRINI ,;                  // 40 
                     UsrRetName((_cAliasTMP)->ZF5_USRINI) ,;      // 41
                     (_cAliasTMP)->ZF5_TRANSP ,;                  // 42
                     (_cAliasTMP)->ZF5_NTRANS ,;                  // 43
                     (_cAliasTMP)->ZF5_VALTON ,;                  // 44
                     (_cAliasTMP)->ZF5_VOLUM ,;                   // 45
                     (_cAliasTMP)->ZF5_PESO ,;                    // 46
                     (_cAliasTMP)->ZF5_PESON ,;                   // 47
                     (_cAliasTMP)->ZF5_FORTER ,;                  // 48
                     (_cAliasTMP)->ZF5_LOJTER ,;                  // 49
                     (_cAliasTMP)->ZF5_NOMTER ,;                  // 50
                     (_cAliasTMP)->ZF5_NDEBIT ,;                  // 51                     (_cAliasTMP)->ZF5_VALTON ,;                  // 52
                     (_cAliasTMP)->C5_ASSNOM ,;                   // 53
                     (_cAliasTMP)->C5_I_TRCNF ,;                  // 54
                     (_cAliasTMP)->C5_I_FLFNC ,;                  // 55
                     (_cAliasTMP)->C5_I_FILFT ,;                  // 56
                     (_cAliasTMP)->ZAM_REGCOD ,;                  // 57
                     (_cAliasTMP)->ZAM_REGDES ,;                  // 58
                     _cDescTipoAgen ,;                            // 59
                     Dtoc(_dDtEmisao) ,;                          // 60
                     (_cAliasTMP)->C5_I_IDPED ,;                  // 61  // "Pedido Portal" 
                     (_cAliasTMP)->C5_I_OPER ,;                   // 62  // "Tp Operacao" 
                     Dtoc(Stod((_cAliasTMP)->C5_EMISSAO)) ,;      // 63  // "Emissao do Pedido"
                     _cTipoVeic ,;                                // 64  // "Veiculo Pedido"
                     Dtoc(_dDtCanhot) ,;                          // 65  // "Dt.Entrega Canhoto"
                     (_cAliasTMP)->C5_I_PVREM ,;                  // 66  // "Rem/Vda Ped"
                     _cNomClRem ,;                                // 67  // "Rem/Vda Razo Social"	
                     _cNfRem ,;                                   // 68  // "Rem/Vda Nfe"	
                     (_cAliasTMP)->A1_I_SHLFP ,;                  // 69  // "Shelf Life do Produto"	
                     Dtoc(_dDtEntCli) ,;                          // 70  // "Dt entrega Cliente"	
                     _cNomOpLog ,;                                // 71  // "Operador Logistico"
                     _cNomOpRed ,;                                // 72  // "Operador Redespacho"
                     _nDiasViag ,;                                // 73  // "Dias de Viagem"
                     _nDiasOper ,;                                // 74  // "Dias Operacional"
                     _nLeadTime ,;                                // 75  // "Lead Time"
                     _cZF5_CAUCUS ,;                              // 76  // Causador (ZF5_CAUCUS)
                     Dtoc(Stod((_cAliasTMP)->F2_I_PENCL)) ,;      // 77  // Prev. Entrega Cliente (F2_I_PENCL)
                     Dtoc(Stod((_cAliasTMP)->F2_I_PENOL)) ,;      // 78  // Prev. Entrega Oper. Logístico (F2_I_PENOL)
                     (_cAliasTMP)->F2_VALBRUT ,;                  // 79  // Valor Bruto da Nota (F2_VALBRUT)
                     (_cAliasTMP)->F2_VALMERC })                  // 80  // Valor de Mercadoria da Nota (F2_VALMERC)


   (_cAliasTMP)->(Dbskip())
EndDo 

If len(_aDados) > 0
   // Alinhamento: 1-Left   ,2-Center,3-Right
   // Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
   //                Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
   AADD(_aCabecalho,{"Filial"                        , 2 , 1 , .F.})// 01
   AADD(_aCabecalho,{"NF"                            , 2 , 1 , .F.})// 02
   AADD(_aCabecalho,{"Serie"                         , 2 , 1 , .F.})// 03
   AADD(_aCabecalho,{"Cod Ocor"                      , 2 , 1 , .F.})// 04
   AADD(_aCabecalho,{"Data entrega"                  , 2 , 4 , .F.})// 05
   AADD(_aCabecalho,{"Data Abertura"                 , 2 , 4 , .F.})// 06
   AADD(_aCabecalho,{"Data Encerrado"                , 2 , 4 , .F.})// 07
   AADD(_aCabecalho,{"Status Ocorrência"             , 1 , 1 , .F.})// 08
   AADD(_aCabecalho,{"Motivo"                        , 1 , 1 , .F.})// 09
   AADD(_aCabecalho,{"Cliente"                       , 2 , 1 , .F.})// 10
   AADD(_aCabecalho,{"Loja"                          , 2 , 1 , .F.})// 11
   AADD(_aCabecalho,{"Nome Cliente"                  , 1 , 1 , .F.})// 12
   AADD(_aCabecalho,{"Cidade Cliente"                , 1 , 1 , .F.})// 13
   AADD(_aCabecalho,{"UF Cliente"                    , 2 , 1 , .F.})// 14
   AADD(_aCabecalho,{"Pedido"                        , 1 , 1 , .F.})// 15
   AADD(_aCabecalho,{"Colaborador"                   , 2 , 1 , .F.})// 16
   AADD(_aCabecalho,{"Cod. Representante"            , 2 , 1 , .F.})// 17
   AADD(_aCabecalho,{"Nome Representante"            , 1 , 1 , .F.})// 18
   AADD(_aCabecalho,{"Cod. Supervisor"               , 2 , 1 , .F.})// 19
   AADD(_aCabecalho,{"Nome Supervisor"               , 1 , 1 , .F.})// 20
   AADD(_aCabecalho,{"Cod. Coordernador"             , 2 , 1 , .F.})// 21
   AADD(_aCabecalho,{"Nome Coordernador"             , 1 , 1 , .F.})// 22
   AADD(_aCabecalho,{"Cod. Gerente"                  , 2 , 1 , .F.})// 23
   AADD(_aCabecalho,{"Nome Gerente"                  , 1 , 1 , .F.})// 24
   AADD(_aCabecalho,{"Carga"                         , 2 , 1 , .F.})// 25
   AADD(_aCabecalho,{"Dt Carga"                      , 2 , 4 , .F.})// 26
   AADD(_aCabecalho,{"Cod. Serviço"                  , 2 , 1 , .F.})// 27
   AADD(_aCabecalho,{"Descrição Serviço"             , 1 , 1 , .F.})// 28
   AADD(_aCabecalho,{"Custo"                         , 3 , 3 , .F.})// 29
   AADD(_aCabecalho,{"Custo Ocorrência"              , 3 , 3 , .F.})// 30
   AADD(_aCabecalho,{"Custo Emb Frete"               , 3 , 3 , .F.})// 31
   AADD(_aCabecalho,{"Custo Cliente"                 , 3 , 3 , .F.})// 32
   AADD(_aCabecalho,{"Custo Italac"                  , 3 , 3 , .F.})// 33
   AADD(_aCabecalho,{"Custo Repres"                  , 3 , 3 , .F.})// 34
   AADD(_aCabecalho,{"Custo Transp"                  , 3 , 3 , .F.})// 35
   AADD(_aCabecalho,{"Custo Terceir"                 , 3 , 3 , .F.})// 36
   AADD(_aCabecalho,{"CTRC"                          , 1 , 1 , .F.})// 37
   AADD(_aCabecalho,{"Motivo Custo"                  , 1 , 1 , .F.})// 38
   AADD(_aCabecalho,{"Agenda"                        , 1 , 1 , .F.})// 39
   AADD(_aCabecalho,{"Cod. Usuario Inicial"          , 2 , 1 , .F.})// 40
   AADD(_aCabecalho,{"Nome Usuario Inicial"          , 1 , 1 , .F.})// 41
   AADD(_aCabecalho,{"Cod. Transportadora"           , 2 , 1 , .F.})// 42
   AADD(_aCabecalho,{"Transportadora"                , 1 , 1 , .F.})// 43
   AADD(_aCabecalho,{"Valor por Tonelada"            , 3 , 3 , .F.})// 44
   AADD(_aCabecalho,{"Volumes"                       , 3 , 2 , .F.})// 45
   AADD(_aCabecalho,{"Peso Carg"                     , 3 , 2 , .F.})// 46
   AADD(_aCabecalho,{"Peso NF"                       , 3 , 2 , .F.})// 47
   AADD(_aCabecalho,{"Forn. Terceiro"                , 2 , 1 , .F.})// 48
   AADD(_aCabecalho,{"Loja Forn. Terceiro"           , 2 , 1 , .F.})// 49
   AADD(_aCabecalho,{"Nome Forn. Terceiro"           , 1 , 1 , .F.})// 50
   AADD(_aCabecalho,{"Nf Debito"                     , 2 , 1 , .F.})// 51    AADD(_aCabecalho,{"Total Tonelada"                , 1 , 1 , .F.})// 52
   AADD(_aCabecalho,{"Assistente Comercial Resp."    , 1 , 1 , .F.})// 53
   AADD(_aCabecalho,{"Troca NF"                      , 2 , 1 , .F.})// 54
   AADD(_aCabecalho,{"Fil Carregamento"              , 2 , 1 , .F.})// 55
   AADD(_aCabecalho,{"Fil Faturamento"               , 2 , 1 , .F.})// 56
   AADD(_aCabecalho,{"Cod. Regional"                 , 2 , 1 , .F.})// 57
   AADD(_aCabecalho,{"Desc. Regional"                , 1 , 1 , .F.})// 58
   AADD(_aCabecalho,{"Tipo de entrega"               , 1 , 1 , .F.})// 59
   AADD(_aCabecalho,{"Dt NF Emissao"                 , 2 , 4 , .F.})// 60
   AADD(_aCabecalho,{"Pedido Portal"                 , 2 , 1 , .F.})// 61
   AADD(_aCabecalho,{"Tipo Operacao"                 , 2 , 1 , .F.})// 62
   AADD(_aCabecalho,{"Emissao do Pedido"             , 2 , 4 , .F.})// 63
   AADD(_aCabecalho,{"Veiculo Pedido"                , 1 , 1 , .F.})// 64
   AADD(_aCabecalho,{"Dt.Entrega Canhoto"            , 2 , 4 , .F.})// 65
   AADD(_aCabecalho,{"Rem/Vda Ped"                   , 2 , 1 , .F.})// 66
   AADD(_aCabecalho,{"Rem/Vda Razo Social"           , 1 , 1 , .F.})// 67
   AADD(_aCabecalho,{"Rem/Vda Nfe"                   , 2 , 1 , .F.})// 68
   AADD(_aCabecalho,{"Shelf Life do Produto"         , 1 , 1 , .F.})// 69
   AADD(_aCabecalho,{"Dt entrega Cliente"            , 2 , 4 , .F.})// 70
   AADD(_aCabecalho,{"Operador Logistico"            , 1 , 1 , .F.})// 71
   AADD(_aCabecalho,{"Operador Redespacho"           , 1 , 1 , .F.})// 72
   AADD(_aCabecalho,{"Dias de Viagem"                , 3 , 2 , .F.})// 73
   AADD(_aCabecalho,{"Dias Operacional"              , 3 , 2 , .F.})// 74
   AADD(_aCabecalho,{"Lead Time"                     , 3 , 2 , .F.})// 75
   AADD(_aCabecalho,{"Causador"                      , 1 , 1 , .F.})// 76
   AADD(_aCabecalho,{"Prev. Entrega Cliente"         , 2 , 4 , .F.})// 77
   AADD(_aCabecalho,{"Prev. Entrega Oper. Logístico" , 2 , 4 , .F.})// 78
   AADD(_aCabecalho,{"Valor Bruto da Nota"           , 3 , 3 , .F.})// 79
   AADD(_aCabecalho,{"Valor de Mercadoria da Nota"   , 3 , 3 , .F.})// 80

   _aDados := aSort(_aDados,,,{|x,y| x[22]+x[18]+x[38] < y[22]+y[18]+y[38]})  
   _cArq    := "MOMS031_"+DTOS(DATE())+"_"+StrTran(TIME(),":","_")+".xlsx"
   _cDir    := AllTrim(GetTempPath())
   _cTitulo := "Ocorrências de Frete - Hora Inicial: "+cTimeInicial+" - Hora Final: "+TIME()

   cETimeInicial := TIME()
   
   SET DATE FORMAT TO "DD/MM/YYYY"
                      //ITGEREXCEL(_cNomeArq,_cDiretorio,_cTitulo,_cNomePlan ,_aCabecalho,_aDetalhe,_lLeTabTemp,_cAliasTab,_aDados,_lScheduller,_lCriaPastas,_aPergunte,_lEnviaEmail,_lXLSX,oProc)   
   FWMSGRUN(,{|oProc| U_ITGEREXCEL(_cArq    ,_cDir      ,_cTitulo,"Relatorio",_aCabecalho,_aDados ,.F.       ,          ,        ,            ,            ,          ,            ,.T.   ,/*oProc*/)  },'Aguarde processamento, Hora Inicial: '+cTimeInicial,"H.I.:"+cETimeInicial+", Gerando Excel: "+_cArq)
   SET DATE FORMAT TO "DD/MM/YY"

   U_ItMsg("Relatorio gerado com Sucesso: "+Chr(13)+Chr(10)+_cDir+_cArq+Chr(13)+Chr(10)+;
            "Hora Inicial: "+cTimeInicial+Chr(13)+Chr(10)+;
            "Hora Ini Excel: "+cETimeInicial+Chr(13)+Chr(10)+;
            "Hora Final: "+TIME();
            ,"Atenção",,2)    
Else
   U_ITMSG("Não foram localizados registros!","Atenção",,1)
EndIf                                                                                                   

If Select(_cAliasTMP)
   Dbselectarea(_cAliasTMP)
   (_cAliasTMP)->(Dbclosearea())	
EndIf
                        
Return

/*
===============================================================================================================================
Programa----------: MOMS031L
Autor-------------: Jerry 
Data da Criacao---: 31/10/2017
Descrição---------: Listar os Status com tipo Encerramento
Parametros--------: 
Retorno-----------: Código de Status de Encerramento
===============================================================================================================================
*/
User Function MOMS031L(_oSelf As Object, _lAuto As Logical) As Character
Local _cQry      := "" As Character
Local _cCodigos  := "" As Character
Local _cAliasTMP := GetNextAlias() As Character

_cQry := "SELECT ZFD_CODIGO "
_cQry += "FROM " + RetSqlName("ZFD") + " "
_cQry += "WHERE ZFD_STATUS = 'E' "
_cQry += "  AND D_E_L_E_T_ = ' ' "
    
MPSysOpenQuery( _cQry , _cAliasTMP )

DbSelectArea(_cAliasTMP)

If !(_cAliasTMP)->(Eof())
    _cCodigos += (_cAliasTMP)->ZFD_CODIGO + ";"
EndIf
    
DbSelectArea(_cAliasTMP)
(_cAliasTMP)->(DbCloseArea())

Return _cCodigos

/*
===============================================================================================================================
Programa----------: MOMS031A
Autor-------------: Julio de Paula Paz
Data da Criacao---: 31/01/2025
===============================================================================================================================
Descrição---------: Calcular a quantidade total de pallets do Pedido de Vendas e retornar tipo de véiculo a ser utilizado.
===============================================================================================================================
Parametros--------: _cfilial    = Código da Filial
                    _cPedVenda  = Numero do Pedido de Vendas
===============================================================================================================================
Retorno-----------: _cRet = Tipo de veículo a ser utilizado
===============================================================================================================================
*/
Static Function MOMS031A(_nQtPallet As Numeric) As Character
Local _cRet := "" As Character

   If _nQtPallet <= 10
      _cRet := "Sem veiculo"
   ElseIf _nQtPallet >= 11 .AND. _nQtPallet <= 14
      _cRet := "Truck"
   ElseIf _nQtPallet >= 15 .AND. _nQtPallet <= 19
      _cRet := "Sem veiculo"	
   ElseIf _nQtPallet >= 20 .AND. _nQtPallet <= 30
      _cRet := "Carreta"
   ElseIf _nQtPallet >= 31 .AND. _nQtPallet <= 50
      _cRet := "RodoTrem"
   Else
      _cRet := "Sem veiculo"
   EndIf

Return _cRet 
