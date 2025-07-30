/*  
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS -                             
===============================================================================================================================
 Autor       |   Data   |                              Motivo                      										 
Alex Wallauer| 11/10/22 | Chamado 41508. Novos Filtros e alteracao da Ordem de prioridade / Botão de Corte de Produtos. 
Alex Wallauer| 20/10/22 | Chamado 41508. Novas Telas: Saldo Consolidado / Pré Reserva / Adicionar Campos na Tela de Corte.
Alex Wallauer| 07/02/23 | Chamado 41508. Correção do saldo negativo para não atrapalhar os calculos de peso.
Alex Wallauer| 09/02/23 | Chamado 41508. Acerto da variavel da data do dia e criacao do parametro IT_MOMS66HR para hora.
Alex Wallauer| 23/02/23 | Chamado 43081. Novos ajustes e Botao Ped X Prod S/Est e controle de acesso via ZZL_GESCPV.
Alex Wallauer| 16/03/23 | Chamado 43309. Gravacao do campo C5_I_STATU apos a libercao.
Julio Paz    | 09/08/23 | Chamado 43829. Incluir Botão na Rotina para Detalhar os dados dos Pedidos de vendas Por Itens.
Alex Wallauer| 12/09/23 | Chamado 45005. Bloqueio de filial que não estiver no parametro: IT_MOMS66FI .
Alex Wallauer| 08/02/24 | Chamado 44782. Jerry. Ajustes para a nova opcao de tipo de entrega: O = Agendado pelo Op.Log.
Alex Wallauer| 08/03/24 | Chamado 46599. Vanderlei. Novo layout do monitor de pedidos de vendas.
Alex Wallauer| 17/06/24 | Chamado 46599. Vanderlei. Novo BOTAÕ DA SIMULACAO DE GERACAO.
Alex Wallauer| 30/07/24 | Chamado 46599. Vanderlei. Nova Tela para informar o saldo liberado do produto/Agrupamento de Pedidos.
Alex Wallauer| 13/08/24 | Chamado 46599. Vanderlei. Novo tratamento para o palete fechado no Local de Embaque "SP02".
Lucas Borges | 23/07/25 | Chamado 51340. Ajustar função para validação de ambiente de teste
==============================================================================================================================================================
Analista    - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
Vanderlei   - Alex Wallauer - 16/08/24 - 18/09/24 - 48138   - Tratamento do Local de Embarque (ZG5_LOCEMB) no cadastro de Transit Time.
Vanderlei   - Alex Wallauer - 27/08/24 - 28/08/24 - 46599   - Fixar SC5->C5_I_LOCEM $ "SP50/PR50/PR51" para sempre -Paletizada" e ajuste no botão despesa.
Vanderlei   - Alex Wallauer - 03/02/25 - 04/02/25 - 49798   - Ajustes no calculo de pallets dos pedidos vinculados.
Vanderlei   - Alex Wallauer - 13/02/25 - 13/02/25 - 49798   - Correção do controle acessos que estava validando invertido.
Vanderlei   - Alex Wallauer - 14/02/25 - 25/02/25 - 49798   - Ajustes no calculo de pallets dos pedidos vinculados.
Vanderlei   - Alex Wallauer - 19/02/25 - 25/02/25 - 49798   - Nova opção de dobrar a capacidade da Filial.
Jerry       - Igor Melgaço  - 25/02/24 - 20/03/25 - 39201   - Ajustes para contabilizar a quantidade de alterações efetuadas no pedido de vendas.
Jerry       - Alex Wallauer - 11/03/25 - 20/03/25 - 49966   - Correção do ERROR.LOG: variable does not exist _CJUTIFICATIVA on MOMS66GRV(MOMS066.PRW) 25/02/2025 14:52:31 line : 2968
Vanderlei   - Alex Wallauer - 20/03/25 - 21/03/25 - 50197   - Novo tratamento para cortes e desmembramentos de pedidos - IGNORAR: M->C5_I_BLSLD = "S"
==============================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'protheus.ch'
#INCLUDE "topconn.ch"
#include "msmgadd.ch"
#include "dbtree.ch"                  

#DEFINE _ENTER CHR(13)+CHR(10)
#DEFINE LEGENDAS_ABCP "BR_AMARELO/BR_BRANCO/BR_CINZA/BR_PRETO"
/*
===============================================================================================================================
Programa--------: MOMS066 // U_MOMS066
Autor-----------: Alex Wallauer
Data da Criacao-: 28/06/2022
===============================================================================================================================
Descrição-------: Geracao lista de Pedidos Pendentes / Monitor de Pedidos. CHAMADO 40644 
===============================================================================================================================
Parametros------: NENHUM
===============================================================================================================================
Retorno---------: NENHUM
===============================================================================================================================
*/
USER FUNCTION MOMS066()// U_MOMS066

Local _aParAux  := {} As Array, nI As Numeric
Local _aParRet  := {} As Array
Local _lLoop    := .F. As Logical

PRIVATE _lAmbTeste  := SuperGetMV("IT_AMBTEST",.F.,.T.) As Logical
Private _aOpcCart   := { '1-Sim', '2-Não'} As Array
Private _aOpcLibEs  := { '1-Sim', '2-Não'} As Array
PRIVATE _cFilPrc    := cFilAnt As Character
PRIVATE lRegioes    := .F. As Logical //ATUALIZADO DENTRO DA MOMS66Obj ()
PRIVATE cPastaR     := "" As Character //ATUALIZADO DENTRO DA MOMS66Obj ()
PRIVATE cOrigemDebug:= "INICIO" As Character //PARA VER NO DEBUG E NO ERROR.LOG
PRIVATE _cFilTer    := AllTrim(U_ITGetMV('IT_EST3FIL', , '')) As Character // Verifica parâmetro de configurações das Filiais que usam estoque em poder de terceiros
PRIVATE _cLocTer    := AllTrim(U_ITGetMV('IT_EST3LOC', , '')) As Character // Verifica parâmetro de configurações dos Armazéns que usam estoque em poder de terceiros
PRIVATE lClicouMarca:= .F. As Logical ///Desativa a atualização na troca de pasta
PRIVATE _aOpcTran   := {"Com Transferencias", "Sem Transferencias", "Só Transferências"} As Array
PRIVATE _aOpcTpCar  := {"Carga Refrigerada", "Carga Seca", "Todas"} As Array
PRIVATE _nPesoMax   := IF(_lAmbTeste, 0, 9999999) As Numeric //Peso máximo Operador logístico - ZEL_PMAXOL 

_cSelectSB1:="SELECT B1_COD , B1_TIPO, B1_DESC FROM "+RETSQLNAME("SB1")+" SB1 WHERE D_E_L_E_T_ <> '*' AND B1_MSBLQL <> '1' AND B1_TIPO = 'PA'  ORDER BY B1_COD "

_cSelectZLE:="SELECT ZEL_CODIGO, ZEL_DESCRI, ZEL_LOCAL FROM "+RETSQLNAME("ZEL")+" ZEL WHERE D_E_L_E_T_ <> '*' AND ZEL_FILFIS = '"+_cFilPrc+"'  ORDER BY ZEL_CODIGO "

_aGerProd:={}

_aItalac_F3:={}//       1           2         3                      4                      5               6                    7         8          9         10         11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela ,_nCpoChave              , _nCpoDesc              ,_bCondTab    , _cTitAux            , _nTamChv, _aDados , _nMaxSel    , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR03" ,_cSelectZLE,{|Tab|(Tab)->ZEL_CODIGO},{|Tab|(Tab)->ZEL_LOCAL+" "+(Tab)->ZEL_DESCRI}, ,"Local de Embarque"  ,         ,         ,1            ,.F.        ,       , } )
AADD(_aItalac_F3,{"MV_PAR04" ,_cSelectSB1,{|Tab|(Tab)->B1_COD},{|Tab|(Tab)->B1_TIPO+" "+(Tab)->B1_DESC}, ,"Produtos"           ,         ,         ,20           ,.F.        ,       , } )
mTam:=LEN(SC6->C6_PRODUTO+SC6->C6_LOCAL)//11+LEN(SC6->C6_LOCAL)
AADD(_aItalac_F3,{"M->ZPQ_PRODUT",       ,                    ,                                          , ,"Produtos Lidos"     ,mTam     ,_aGerProd,1})

DO WHILE .T.

    MV_PAR01:=_dDataDia:=DATE()
    MV_PAR02:=U_ItGetMv("IT_MOMS66HR","14:00")
    MV_PAR03:=SPACE(004)
    MV_PAR04:=SPACE(200)
    MV_PAR05:=SPACE(050)
    MV_PAR06:=SPACE(200) 
    MV_PAR07:=1
    MV_PAR08:=1
    MV_PAR09:=2
    MV_PAR10:=3
    MV_PAR11:=2

    _cTitulo:="Lista de Pedidos Pendentes / Monitor de Pedidos"
        
    IF !_lLoop//Para não duplicar quando der loop

        IF !_lAmbTeste
           AADD( _aParAux , { 9 , "DATA DE EMISSAO DO PEDIDO ATE "+DTOC(_dDataDia), 150 , 9, .T. } )
        ELSE
           AADD( _aParAux , { 1 , "Data Emissao ate", MV_PAR01, "@D"  , "" ,"", ".T." , 070 , .T. } )
        ENDIF
        AADD( _aParAux , { 9 , "HORA DO PEDIDO ATE "+ MV_PAR02  , 150 , 9, .T. } )
        
        AADD( _aParAux , { 1 , "Local de Embarque"              , MV_PAR03, "@!"  , ""  ,"F3ITLC", "" , 100 , .T. } ) 
        AADD( _aParAux , { 1 , "Produtos"                       , MV_PAR04, "@!"  , ""  ,"F3ITLC", "" , 100 , .F. } ) 
        AADD( _aParAux , { 1 , "Tipo de Agendamento"            , MV_PAR05, "@!"  , ""  ,"LSTAGE", "" , 100 , .F. } ) 
        AADD( _aParAux , { 1 , "Gerente"                        , MV_PAR06, "@!"  , ""  ,"LSTGER", "" , 100 , .F. } )
        
        AADD( _aParAux , { 3 , "Carteira Toda"                  , MV_PAR07,_aOpcCart , 60 , '' , .T. } )
        AADD( _aParAux , { 3 , "Tranferecias"                   , MV_PAR08,_aOpcTran , 60 , '' , .T. } )
        AADD( _aParAux , { 3 , "Considerar Liberação de Estoque", MV_PAR09,_aOpcLibEs, 60 , '' , .T. } )
        AADD( _aParAux , { 3 , "Tipo de Carga"                  , MV_PAR10,_aOpcTpCar, 60 , '' , .T. } )
        AADD( _aParAux , { 3 , "Dobrar a Capacidade"            , MV_PAR11,_aOpcLibEs, 60 , '' , .T. } )
              
        For nI := 1 To Len( _aParAux )
            aAdd( _aParRet , _aParAux[nI][03] )
        Next 
        _lLoop:=.T.
     
     ENDIF
           
     // 1-aParametros,2-cTitle                                   ,3-aRet    ,4-bOk      ,5-aButtons,6-lCentered,7-nPosX,8-nPosY,9-oDlgWizard,10-cLoad,11-lCanSave,12-lUserSave
     IF !ParamBox( _aParAux    , "CONFIRME A LEITURA DOS PEDIDOS PENDENTES", _aParRet , {|| .T. } ,          ,           ,       ,       ,            ,        , .T.       , .T.        )
         Return .T.
     EndIf

     _dDataDia:=MV_PAR01

     IF VALTYPE(MV_PAR07) = "C"
        MV_PAR07:=VAL(MV_PAR07)
     ENDIF
     IF VALTYPE(MV_PAR08) = "C"
        MV_PAR08:=VAL(MV_PAR08)
     ENDIF
       
     _cTitulo+=" - "+DTOC(_dDataDia)+" - "+TIME()
     ZEL->(DBSETORDER(1))//  // ZEL_FILIAL+ZEL_CODIGO         // COMPARTILHADA
     IF !ZEL->(Dbseek(xFilial()+ALLTRIM(MV_PAR03))) .OR. (ZEL->ZEL_FILFIS <> _cFilPrc)
        U_ITMSG('Local de embarque "'+ALLTRIM(MV_PAR03)+'" NÃO cadastrado para essa filial: '+_cFilPrc,'Atenção!',"Selecione um local de embarque via F3 por favor." ,1)    
        LOOP
     ENDIF
     ZEL->(DbSetOrder(1))  // ZEL_FILIAL+ZEL_CODIGO         // COMPARTILHADA
     IF ZEL->(FIELDPOS("ZEL_MULPAL")) > 0  .AND. ZEL->(FIELDPOS("ZEL_MULPES")) > 0 
        
        IF ZEL->(DBSEEK(xFilial()+ALLTRIM(MV_PAR03))) .AND.;
                                 !EMPTY(ZEL->ZEL_CAPKG ) .AND.;
                                 !EMPTY(ZEL->ZEL_CAPALE) .AND.;
                                 !EMPTY(ZEL->ZEL_MULPAL) .AND.;
                                 !EMPTY(ZEL->ZEL_MULPES)
          _nCapacPes:= ZEL->ZEL_CAPKG  //Capacidade peso
          _nCapacPal:= ZEL->ZEL_CAPALE //Capacidade de Palete
          _cMultPall:= ALLTRIM(ZEL->ZEL_MULPAL) //Multiplo de Paletes
          _cMultPeso:= ALLTRIM(ZEL->ZEL_MULPES) //Multiplo de Pesos  
          IF ZEL->(FIELDPOS("ZEL_PMAXOL")) > 0 .AND. !EMPTY(ZEL->ZEL_PMAXOL)
             _nPesoMax := ZEL->ZEL_PMAXOL //Peso máximo Operador logístico
          ENDIF	    
        ELSE
          
          _cCampo :=""
          IF EMPTY(ZEL->ZEL_CAPKG)
             _cCampo += '[capacidade de peso] '
          ENDIF
          IF EMPTY(ZEL->ZEL_CAPALE) 
             _cCampo += '[capacidade de paletes] ' 
          ENDIF
          IF EMPTY(ZEL->ZEL_MULPAL) 
             _cCampo += '["multiplo de Paletes] ' 
          ENDIF
          IF EMPTY(ZEL->ZEL_MULPES)   
             _cCampo += '["multiplo de peso]' 
          ENDIF
          IF ZEL->(FIELDPOS("ZEL_PMAXOL")) > 0 .AND. EMPTY(ZEL->ZEL_PMAXOL)
             _cCampo += '[Peso máximo Operador logístico]' 
          ENDIF

          U_ITMSG('Cadastro de local de embarque "'+MV_PAR03+'" esta incompleto.','Atenção!',"Cadastre o(s) campo(s): "+_cCampo ,1)    
          
          If _lAmbTeste
             ZEL->(DBSEEK(xFilial()+ALLTRIM(MV_PAR03))) 
             Z24->(DBSEEK(xFilial()+_cFilPrc+"  "))// Procura para todas as filiais
             _nCapacPes:=IF(EMPTY(ZEL->ZEL_CAPKG ),Z24->Z24_PESO       ,ZEL->ZEL_CAPKG)
             _nCapacPal:=IF(EMPTY(ZEL->ZEL_CAPALE),(Z24->Z24_PESO/1000),ZEL->ZEL_CAPALE)
             _cMultPall:=IF(EMPTY(ZEL->ZEL_MULPAL),"01 / 02 / 03 / 10",ALLTRIM(ZEL->ZEL_MULPAL))
             _cMultPeso:=IF(EMPTY(ZEL->ZEL_MULPES),"01 / 02 / 04 / 10",ALLTRIM(ZEL->ZEL_MULPES))
             U_ITMSG("Como esta no Ambiente "+GetEnvServer()+" que não é produção, será usado os seguintes valores :"+_ENTER;
                      +"Capacidade de peso: "+cValToChar(_nCapacPes)+_ENTER;
                      +"Capacidade de paletes: "+cValToChar(_nCapacPal)+_ENTER;
                      +"Multiplo de Paletes: "+_cMultPall+_ENTER;
                      +"Multiplo de peso: "+_cMultPeso+_ENTER;
                      +"Peso máximo Operador logístico: "+cValToChar(_nPesoMax);
                      ,'Atenção!', ,2)    
          ELSE
             LOOP
          ENDIF
        
        ENDIF
    ELSE
       ZEL->(DBSEEK(xFilial()+ALLTRIM(MV_PAR03))) 
       Z24->(DBSEEK(xFilial()+_cFilPrc+"  "))// Procura para todas as filiais
       _nCapacPes:=IF(EMPTY(ZEL->ZEL_CAPKG ),Z24->Z24_PESO       ,ZEL->ZEL_CAPKG)
       _nCapacPal:=IF(EMPTY(ZEL->ZEL_CAPALE),(Z24->Z24_PESO/1000),ZEL->ZEL_CAPALE)
       _cMultPall:="12 / 28 / 44 / 48"
       _cMultPeso:="14 / 30 / 46 / 50"
    ENDIF

    IF !EMPTY(MV_PAR03)
        _cTitulo+=" - Local: "+ALLTRIM(MV_PAR03)
    ENDIF
    IF !EMPTY(MV_PAR04)
        _cTitulo+=" - Prods: "+ALLTRIM(MV_PAR04)
    ENDIF
    IF !EMPTY(MV_PAR05)
        _cTitulo+=" - Tipos: "+ALLTRIM(MV_PAR05)
    ENDIF
    IF !EMPTY(MV_PAR06)
        _cTitulo+=" - Gerentes: "+ALLTRIM(MV_PAR06)
    ENDIF	
    
   IF _nCapacPes <= 0
       U_ITMSG("Filial "+_cFilPrc+" sem limite de carregamento cadastrada",'Atenção!',"Cadastre um limite de carragamento para a filial : "+_cFilPrc,3) 
       LOOP
    ENDIF

    IF MV_PAR11 = 1
       _nCapacPes:=(_nCapacPes*2)
       _nCapacPal:=(_nCapacPal*2)
    EndIf

    DO WHILE .T.
       
          cSair := "SAIR"
          FWMSGRUN(,{|oProc|  cSair := MOMS66CP(oProc)  }, "Analisando os Pedidos...","Filtrando pedidos pendentes..." )
        
          EXIT
        
    ENDDO
    
    IF cSair = "SAIR"
       EXIT
    ENDIF

ENDDO
    
Return

/*
===============================================================================================================================
Programa--------: MOMS66CP
Autor-----------: Alex Wallauer
Data da Criacao-: 28/06/2022
===============================================================================================================================
Descrição-------: Pego os pedidos necessários para realizar a manutenção na tabela ZY3
===============================================================================================================================
Parametros------: oProc - objeto para o carregamento do FWMSGRUN quando a tela estiver ativa.
===============================================================================================================================
Retorno---------: cSair: "LOOP" ou "SAIR"
===============================================================================================================================*/
Static Function MOMS66CP(oProc)
Local _cQuery        := "" As Character, P As Numeric, M As Numeric
Local _cAlias2       := GetNextAlias() As Character
Local _cTpOper       := U_ITGetMv("IT_OMS48TO", '02;07;15;18;19;21;22;23;31;40;41;50;51;99') As Character
Local _cAliasC9      := GetNextAlias() As Character
PRIVATE _cOper50     := ALLTRIM( U_ITGETMV( "IT_CHEPCLIS" ) ) As Character //OPERAÇÃO EXCLUSIVA PARA CLIENTE CHEP
PRIVATE _cOper51     := ALLTRIM( U_ITGETMV( "IT_CHEPCLIN" ) ) As Character //OPERAÇÃO EXCLUSIVA PARA CLIENTE NÃO CHEP
PRIVATE _dHoje       := _dDataDia As Date
PRIVATE _lEfetivar   := .T. As Logical //DESBLOQUEIA O BOTÃO GERAR
Private _aSB2        := {} As Array
Private _aSB2Inic    := {} As Array
Private _aPedidos    := {} As Array
Private _lGravaLOG   :=.F. As Logical
Private _lGrava      :=.F. As Logical
Private _lSimular    :=.F. As Logical
PRIVATE _nTotPesoLib := 0 As Numeric
PRIVATE _nTotPalsLib := 0 As Numeric
PRIVATE _nSEstPesoLib:= 0 As Numeric //TOTAL LIBERADO SEM OLHA ESTOQUE 
PRIVATE _nSEstPalsLib:= 0 As Numeric //TOTAL LIBERADO SEM OLHA ESTOQUE 
Private _nPesSaldoIni:= 0 As Numeric
Private _aItensSemEstoque:= {} As Array

IF oProc <> NIL
   oProc:cCaption := ("Filtrando pedidos pendentes..." )
   ProcessMessages()
ENDIF
SC5->(dbSetOrder(1))
SC6->(dbSetOrder(1))
SB1->(DbSetOrder(1))
Z24->(DbSetOrder(1))

IF !_lAmbTeste
   _dHoje:=_dDataDia:=DATE() // POR GARANTIA
ENDIF

_cQuery := "SELECT C5.R_E_C_N_O_ C5REC "
_cQuery += "FROM " + RetSqlName("SC5") + " C5 "
_cQuery += "WHERE C5_TIPO = 'N' " 
_cQuery += "  AND C5_NOTA = ' ' "
_cQuery += "  AND (C5_EMISSAO < '" + DTOS(_dHoje)+"' "
_cQuery += "       OR (C5_EMISSAO = '" + DTOS(_dHoje)+"' AND C5_I_HREMI <= '"+MV_PAR02+"')) "

_cQuery += "  AND (C5_I_AGEND IN ('M','A','I','O') OR (C5_I_OPER = '20' AND C5_I_TRCNF <> 'S')) "

// Filtra Agendamento
If !EMPTY( MV_PAR05 )      
    If Len(ALLTRIM(MV_PAR05)) = 1
        _cQuery += "AND C5_I_AGEND = '"+ ALLTRIM(MV_PAR05) + "' "
    Else
        _cQuery += "AND C5_I_AGEND IN "+ FORMATIN(ALLTRIM(MV_PAR05), ";" )
    EndIf
EndIf
// Filtra Gerente
 IF !EMPTY( MV_PAR06 )             
     IF LEN(ALLTRIM(MV_PAR06)) <= 6
         _cQuery += " AND C5_VEND3 = '"+ ALLTRIM(MV_PAR06) + "' "
     Else
         _cQuery += " AND C5_VEND3 IN "+ FORMATIN( ALLTRIM(MV_PAR06) , ";" )
     EndIf
 EndIf
_cQuery += "  AND C5_FILIAL = '"+_cFilPrc+"' "
_cQuery += "  AND NOT C5_I_OPER IN " + FormatIn(_cTpOper, ";") + " " 
// Filtra LOCAL DE EMBARQUE
If !EMPTY( MV_PAR03 )      
   _cQuery += "              AND C5_I_LOCEM = '"+ ALLTRIM(MV_PAR03) + "' "
EndIf

//FILTRA: 1-Com Transferencias  / 2-Sem Transferencias / 3-Só Transferências
If MV_PAR08 = 2 
   _cQuery += "              AND C5_I_OPER <> '20' "
ELSEIf MV_PAR08 = 3
   _cQuery += "              AND C5_I_OPER  = '20' "
EndIf
//============================================================================================ 
//Novo tratamento para cortes e desmembramentos de pedidos - IGNORAR: M->C5_I_BLSLD = "S"
//============================================================================================ 
If SC5->(FIELDPOS("C5_I_BLSLD")) > 0
   _cQuery += " AND C5_I_BLSLD = 'N' "
EndIf

_cQuery += "  AND C5.D_E_L_E_T_  = ' ' " 
_cQuery += "  AND EXISTS (SELECT 'Y' FROM " +RetSqlName("SC6")+" C6, " + RetSqlName("SB1") + " B1 "
_cQuery += "               WHERE C6.D_E_L_E_T_ = ' ' AND C6.C6_FILIAL = C5.C5_FILIAL AND C6.C6_NUM = C5.C5_NUM "
// Filtra PRODUTO
If !EMPTY( MV_PAR04 )      
    If Len(ALLTRIM(MV_PAR04)) <= 11
        _cQuery += "             AND C6_PRODUTO = '"+ ALLTRIM(MV_PAR04) + "' "
    Else
        _cQuery += "             AND C6_PRODUTO IN "+ FORMATIN(ALLTRIM(MV_PAR04), ";" )
    EndIf
EndIf
_cQuery += "                     AND B1.D_E_L_E_T_ = ' ' AND B1.B1_FILIAL = ' ' AND B1.B1_COD = C6.C6_PRODUTO "

_cQuery += "                     AND B1_TIPO = 'PA' AND C6_LOCAL NOT IN ( '40','42') ) "	

_cQuery += "  AND NOT EXISTS (SELECT 'Y' FROM " +RetSqlName("SC9")+" C9 WHERE C9.D_E_L_E_T_ = ' ' AND C9.C9_FILIAL = C5.C5_FILIAL AND C9.C9_PEDIDO = C5.C5_NUM ) "

//IF _cFilPrc = "90" //aOptions:={"Somente arm. 36 ","Diferente arm. 36"}
//   IF MV_PAR03 = "1" // TEM 36
//      _cQuery += "AND NOT EXISTS (SELECT 'Y' FROM " +RetSqlName("SC6") +" C6 WHERE C6.D_E_L_E_T_ = ' ' AND C6.C6_FILIAL = C5.C5_FILIAL AND C6.C6_NUM = C5.C5_NUM AND C6.C6_LOCAL <> '36' ) "	
//   ELSEIF MV_PAR03 = "2"//NÃO TEM 36
//      _cQuery += "AND NOT EXISTS (SELECT 'Y' FROM " +RetSqlName("SC6") +" C6 WHERE C6.D_E_L_E_T_ = ' ' AND C6.C6_FILIAL = C5.C5_FILIAL AND C6.C6_NUM = C5.C5_NUM AND C6.C6_LOCAL = '36' ) "	
//   ENDIF
//ELSEIF _cFilPrc = "93"//aOptions:={"Somente arm. 36 ","Somente arm. 38"}
//   IF MV_PAR03 = "1" //TEM 38
//      _cQuery += "AND NOT EXISTS (SELECT 'Y' FROM " +RetSqlName("SC6") +" C6 WHERE C6.D_E_L_E_T_ = ' ' AND C6.C6_FILIAL = C5.C5_FILIAL AND C6.C6_NUM = C5.C5_NUM AND C6.C6_LOCAL <> '38' ) "
//   ELSEIF MV_PAR03 = "2"//NÃO TEM 38
//      _cQuery += "AND NOT EXISTS (SELECT 'Y' FROM " +RetSqlName("SC6") +" C6 WHERE C6.D_E_L_E_T_ = ' ' AND C6.C6_FILIAL = C5.C5_FILIAL AND C6.C6_NUM = C5.C5_NUM AND C6.C6_LOCAL = '38' ) "	
//   ENDIF
//ENDIF

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias2 , .T. , .F. )

_nTot:=nConta:=0
COUNT TO _nTot
_cTotGeral:=ALLTRIM(STR(_nTot))

(_cAlias2)->(DbGoTop())
IF (_cAlias2)->(EOF())
    U_ITMSG("Não existe pedidos para processamento.",'Atenção!',,3) 
    RETURN "LOOP"
ENDIF
    
IF !U_ITMSG("Serão processados "+_cTotGeral+' Pedidos da Filial Atual: '+_cFilPrc+', Confirma ?','Atenção!',,3,2,3,,"CONFIRMA","VOLTAR")
   RETURN "LOOP"
ENDIF

IF oProc <> NIL
   oProc:cCaption := ("1-Calculando Saldo Inicial do Carregamento..." )
   ProcessMessages()
ENDIF

//_cQuery := " SELECT C9.R_E_C_N_O_ C9REC "
_cQuery := " SELECT DISTINCT C9.C9_FILIAL,C9.C9_PEDIDO "
_cQuery += " FROM " +RetSqlName("SC9")+" C9 "
_cQuery += " WHERE C9.D_E_L_E_T_ = ' ' "
_cQuery += "   AND C9.C9_FILIAL  = '"+_cFilPrc+"' "
IF !_lAmbTeste
   _cQuery += "AND C9.C9_DATALIB = '" + DTOS(_dHoje)+"' "
ELSE
   _cQuery += "AND C9.C9_DATALIB >= '" + DTOS(_dHoje)+"' "
ENDIF
_cQuery += "  AND EXISTS "
_cQuery += "     (SELECT 'Y' FROM " +RetSqlName("SC5")+" C5 WHERE " 
_cQuery += "                                             C5.D_E_L_E_T_ = ' '          AND "
_cQuery += "                                             C5.C5_FILIAL  = C9.C9_FILIAL AND "
_cQuery += "                                             C5.C5_NUM     = C9.C9_PEDIDO AND "
If !EMPTY( MV_PAR03 )      // Filtra LOCAL DE EMBARQUE
   _cQuery += "                                          C5_I_LOCEM    = '"+ ALLTRIM(MV_PAR03) + "' AND "
EndIf
IF !_lAmbTeste
   _cQuery += "                                          C5.C5_I_LILO  = '" + DTOS(_dHoje)+"' ) "
ELSE
   _cQuery += "                                          C5.C5_I_LILO  >= '" + DTOS(_dHoje)+"' ) "//No ambiente de testes vc tem que selcionar uma data antiga mas gera com a data do dia do teste DATE()
ENDIF

//IF _cFilPrc = "90" //aOptions:={"Somente arm. 36 ","Diferente arm. 36"}
//   IF MV_PAR03 = "1" // SE SÓ TEM 36
//      _cQuery += "AND C9.C9_LOCAL = '36' "	
//      //_cQuery += "AND NOT EXISTS (SELECT 'Y' FROM " +RetSqlName("SC6") +" C6 WHERE C6.D_E_L_E_T_ = ' ' AND C6.C6_FILIAL = C9.C9_FILIAL AND C6.C6_NUM = C9.C9_PEDIDO AND C6.C6_LOCAL <> '36' ) "	
//   ELSEIF MV_PAR03 = "2"//NÃO TEM NENNHUM 36
//      _cQuery += "AND C9.C9_LOCAL <> '36' "	
//      //_cQuery += "AND NOT EXISTS (SELECT 'Y' FROM " +RetSqlName("SC6") +" C6 WHERE C6.D_E_L_E_T_ = ' ' AND C6.C6_FILIAL = C9.C9_FILIAL AND C6.C6_NUM = C9.C9_PEDIDO AND C6.C6_LOCAL = '36' ) "	
//   ENDIF
//ELSEIF _cFilPrc = "93"//aOptions:={"Somente arm. 36 ","Somente arm. 38"}
//   IF MV_PAR03 = "1" //SE SÓ TEM 38
//      _cQuery += "AND C9.C9_LOCAL = '38' "	
//      //_cQuery += "AND NOT EXISTS (SELECT 'Y' FROM " +RetSqlName("SC6") +" C6 WHERE C6.D_E_L_E_T_ = ' ' AND C6.C6_FILIAL = C9.C9_FILIAL AND C6.C6_NUM = C9.C9_PEDIDO AND C6.C6_LOCAL <> '36 ) "	
//   ELSEIF MV_PAR03 = "2"//NÃO TEM NENNHUM 38
//      _cQuery += "AND C9.C9_LOCAL <> '38' "	
//      //_cQuery += "AND NOT EXISTS (SELECT 'Y' FROM " +RetSqlName("SC6") +" C6 WHERE C6.D_E_L_E_T_ = ' ' AND C6.C6_FILIAL = C9.C9_FILIAL AND C6.C6_NUM = C9.C9_PEDIDO AND C6.C6_LOCAL <> '38' ) "	
//   ENDIF
//ENDIF

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAliasC9 , .T. , .F. )

SC5->(DBSETORDER(1))
_nPesSaldoIni:=0
_nPalSaldoIni:=0
DO WHILE (_cAliasC9)->(!EOF())
   
   //SC9->(DbGoTo((_cAliasC9)->C9REC))   
   //_nPesoItem:=MOMS66KG(SC9->C9_PRODUTO,SC9->C9_QTDLIB,0)   
   //_nPesSaldoIni+=_nPesoItem

   IF SC5->(DBSEEK( (_cAliasC9)->C9_FILIAL+(_cAliasC9)->C9_PEDIDO)) 
       
      M->C5_I_TIPCA:=SC5->C5_I_TIPCA
      IF !M->C5_I_TIPCA $ "1/2"
         M->C5_I_TIPCA :="2"//-Batida"
         SA1->(DbSetOrder(1))                         
         If SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
            IF LEN(ALLTRIM(SA1->A1_I_CCHEP)) == 10
                M->C5_I_TIPCA :="1"//-Paletizada"//PALETE CHEP
            Else
                M->C5_I_TIPCA :="2"//-Batida"    //ESTIVADA
            EndIf   
         Endif
         If SC5->C5_I_OPER == _cOper50 .OR. SC5->C5_I_OPER == _cOper51 //PEDIDO DE PALLET DEVE SER ENVIADO COMO ESTIVADO
            M->C5_I_TIPCA :="2"//-Batida"
         Endif
      ENDIF

      IF  M->C5_I_TIPCA = "1" .AND. SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))
          _nTotPall:=0
          DO WHILE SC6->(!EOF()) .AND. SC6->C6_FILIAL == SC5->C5_FILIAL .AND. SC6->C6_NUM == SC5->C5_NUM
               _nTotPall+=MOMS66CT(SC6->C6_PRODUTO,SC6->C6_QTDVEN,.T.)
               SC6->(DbSkip())
          ENDDO
          _nPalSaldoIni+=_nTotPall      //Paletizada
      ELSE                     
          _nPesSaldoIni+=SC5->C5_I_PESBR//Batida
      ENDIF
   ENDIF   
   (_cAliasC9)->(DBSKIP())
ENDDO

aPedVin:={}
aFolderRGBR:={}//Preenchido na funcao ITRegiaoBR ()
aFolderMeso:={}
DO WHILE (_cAlias2)->(!EOF())
        
    SC5->(DbGoTo((_cAlias2)->C5REC))
    IF oProc <> NIL
       nConta++
       oProc:cCaption := ("2-Lendo Ped.: "+SC5->C5_NUM+" - "+STRZERO(nConta,5) +" de "+ _cTotGeral )
       ProcessMessages()
    ENDIF

    _aSC6_do_PV:= {}
    _cClassEnt:=Posicione("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_I_CLABC")
    IF _cClassEnt = '1'
       _cClassEnt:="1-TOP 1 NACIONAL"
    ELSEIF _cClassEnt = '2'
       _cClassEnt:="2-TOP 5 Reg. SP "
    ELSEIF _cClassEnt = '3'
       _cClassEnt:="3-TOP 5 Reg. RS "
    ENDIF

    _dDataCalculada:=SC5->C5_I_DTENT //Usado na funcao MOMS66Ord ()
    _cObs  :=""                      //Preenchido na funcao MOMS66Ord ()
    _nDias :=0                       //Preenchido na funcao MOMS66Ord ()
    _lAchouZG5:=.F.                  //Preenchido na funcao MOMS66Ord ()
    _cRegra:=""                      //Preenchido na funcao MOMS66Ord ()
    
    _cChave:=MOMS66Ord(_cClassEnt)   //BUSCA A CHAVE DE PRIORIDADE 

    If _cChave == "LOOP"
       (_cAlias2)->(DbSkip())
       LOOP
    ENDIF	 
   //_nDias := ALLTRIM(STR(_nDias)) + " ["+_cRegra+"]" // PARA TESTES
    aProd:={}
    _cTipCarga:=" "
    _nTotValor:=_nTotPall:=_nPesoTot:=0
    _cPaletFechado:="1-SIM"//PREENCHIDA DENTRO DA FUNÇÃO MOMS66CT(
    iF SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))

         _cTipCarga:=POSICIONE("SB1",1,xfilial("SB1")+SC6->C6_PRODUTO,"B1_TIPCAR")

       IF MV_PAR10 = 1// CARGA REFRIGERADA
          IF _cTipCarga <> "000002" // CARGA SECA
             (_cAlias2)->(DbSkip())
             LOOP
          ENDIF
       ELSEIF MV_PAR10 = 2// CARGA SECA
          IF _cTipCarga == "000002" // CARGA REFRIGERADA
             (_cAlias2)->(DbSkip())
             LOOP
          ENDIF
       ENDIF

       M->C5_I_TIPCA :="2-Batida" // _nPosTPCA
       IF SC5->C5_I_TIPCA = "1" .OR. SC5->C5_I_LOCEM $ "SP50/PR50/PR51" //LOCAL QUE SÓ VENDE PALITAZADOS
          M->C5_I_TIPCA :="1-Paletizada"
       ELSEIF !SC5->C5_I_TIPCA = "1/2"
          SA1->(DbSetOrder(1))                         
          If SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
             IF LEN(ALLTRIM(SA1->A1_I_CCHEP)) == 10
                 M->C5_I_TIPCA :="1-Paletizada"//PALETE CHEP
             Else
                 M->C5_I_TIPCA :="2-Batida"    //ESTIVADA
             EndIf   
          Endif
          If SC5->C5_I_OPER == _cOper50 .OR. SC5->C5_I_OPER == _cOper51 //PEDIDO DE PALLET DEVE SER ENVIADO COMO ESTIVADO
             M->C5_I_TIPCA :="2-Batida"
          Endif
       ENDIF

       DO WHILE SC6->(!EOF()) .AND. SC6->C6_FILIAL == SC5->C5_FILIAL .AND. SC6->C6_NUM == SC5->C5_NUM
            
            _nItemPall:=MOMS66CT(SC6->C6_PRODUTO,SC6->C6_QTDVEN,.F.,M->C5_I_TIPCA)//SC6->C6_I_QPALT //Pesquisar n MOMS66CT(
            _nTotPall +=_nItemPall
            //A funcao MOMS66CT() já posiciona no SB1
            //_nPesoTot += (SB1->B1_PESBRU * SC6->C6_QTDVEN)

            Aadd(_aSC6_do_PV, { SC6->(RECNO()) ,;// RECNO 
                                           .T. ,;// SE TEM ESTOQUE
                                             0 ,;// (_nQtdeATend*_nfator)
                                             0 ,;// (_nQtdeFalta*_nfator)//QTDE FALTANTE
                                             0 ,;// _nPesoFalta
             (SB1->B1_PESBRU * SC6->C6_QTDVEN) ,;// Peso  por item
                                    _nItemPall })// Palet por item
            
            IF SC5->C5_I_OPER = "42" .OR. Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC") = 'S' 
               _nTotValor+=(SC6->C6_QTDVEN * SC6->C6_PRCVEN)
            ENDIF

            //IF ASCAN(_aGerProd, SC6->C6_PRODUTO+SC6->C6_LOCAL+"-"+ALLTRIM(SC6->C6_DESCRI)) = 0//PARA O F3 DO PRODUTO DO GERENTE
            //    AADD(_aGerProd, SC6->C6_PRODUTO+SC6->C6_LOCAL+"-"+ALLTRIM(SC6->C6_DESCRI))
            //ENDIF
            
            SC6->(DbSkip())
       ENDDO
    ELSE
       (_cAlias2)->(DbSkip())
       LOOP
    ENDIF
    nSalvaRecSC5:=SC5->(RECNO())
    _nPesoTot:=SC5->C5_I_PESBR
    _nTotAuxPall:=_nTotPall//GUARDA O TOTAL DE PALETES DO PEDIDO ANTES DE SOMAR O PEDIDO VINCULADO PARA MOSTRA NA COLUNA DA TELA
    IF !Empty(SC5->C5_I_PEVIN)//Soma os Paletes do pedido vinculado
       
       _cPedVinc:=SC5->C5_FILIAL+SC5->C5_I_PEVIN
       IF SC5->(DbSeek(_cPedVinc))
          _nPesoTot+=SC5->C5_I_PESBR
       EndIF
       SC5->(DBGOTO(nSalvaRecSC5))
       IF (_nPos:=ASCAN(aPedVin,{|aPed| aPed[1] == SC5->C5_I_PEVIN } )) > 0//SE ACHOU NA LISTA GERAL DE VINCULADOS não precisa fazer o while de novo
       
          _nTotPall+=aPedVin[_nPos][6]
       
       ElseIf SC6->(DbSeek(_cPedVinc))
       
          DO WHILE SC6->(!EOF()) .AND. SC6->C6_FILIAL+SC6->C6_NUM == _cPedVinc
               
             _nItemPall:=MOMS66CT(SC6->C6_PRODUTO,SC6->C6_QTDVEN,.F.,M->C5_I_TIPCA)//SC6->C6_I_QPALT //Pesquisar n MOMS66CT(
             _nTotPall +=_nItemPall
             SC6->(DbSkip())
          ENDDO
       
       EndIF
    EndIf
    SC5->(DBGOTO(nSalvaRecSC5))
    
    //Paletes Fechados ?
    _cCargaFechada:="2-NAO"
    if _cPaletFechado = "1-SIM" //PREENCHIDA DENTRO DA FUNÇÃO MOMS66CT(
       IF INT(_nTotPall) = _nTotPall .AND. STRZERO(_nTotPall,2,0) $ _cMultPall
          _cCargaFechada:="1-SIM"
       ELSEIF STRZERO( ROUND((_nPesoTot/1000),0)  ,2,0) $ _cMultPeso 
          _cCargaFechada:="1-SIM"
       ENDIF
    ELSE
       IF STRZERO( ROUND((_nPesoTot/1000),0)  ,2,0) $ _cMultPeso 
          _cCargaFechada:="1-SIM"
       ENDIF
    Endif
    
    _cTipoEntr := U_TipoEntrega(SC5->C5_I_AGEND)
    IF SC5->C5_I_OPER="20"
       _cTipoEntr := "Transferencia"
    ENDIF

    IF _cTipCarga == "000002" // CARGA REFRIGERADA - _nPosTPDACA
       _cTipCarga :="Carga Refrigerada"
    ELSE// Carga Seca
       _cTipCarga :="Carga Seca"
    ENDIF

   _cNomeCli  := SC5->C5_CLIENTE+"-"+SC5->C5_LOJACLI+"-"+SC5->C5_I_NOME
   _cMicroReg := Posicione("CC2",1,xFilial("CC2")+SA1->A1_EST+SA1->A1_COD_MUN,"CC2_I_MICR")
   IF CC2->(FIELDPOS("CC2_I_MELO")) > 0
      _cMesoReg:= IF(EMPTY(CC2->CC2_I_MELO),CC2->CC2_I_MESO,CC2->CC2_I_MELO)
   ELSE
      _cMesoReg:= CC2->CC2_I_MESO
   ENDIF	
   _cMicroReg := ALLTRIM(POSICIONE("Z22",4,XFILIAL("Z22")+SA1->A1_EST+CC2->CC2_I_MESO+_cMicroReg,"Z22_NOME"))
 //_cMesoReg  := _cMesoReg+"-"+ALLTRIM(POSICIONE("Z21",1,XFILIAL("Z21")+_cMesoReg,"Z21_NOME"))
   _cMesoReg  := ALLTRIM(POSICIONE("Z21",1,XFILIAL("Z21")+_cMesoReg,"Z21_NOME"))
   _cRegiao   := ALLTRIM(U_ITRegiaoBR(Z21->Z21_EST,_cMesoReg))

   IF !Empty(SC5->C5_I_PEVIN)
       AADD(aPedVin,{SC5->C5_NUM    ,;// 01 - PEDIDO DA COLUNA 1 com os dados deles abaixo
                     SC5->C5_I_PEVIN,;// 02 - PEDIDO DA COLUNA 2 VINCULADO
                     _cMesoReg      ,;// 03 - GUARDA A MESO   DO PEDIDO DA COLUNA 1 - CONTEUDO ALTERADO DEPOIS
                     _cRegiao       ,;// 04 - GUARDA A REGIAO DO PEDIDO DA COLUNA 1 - CONTEUDO TALVEZ ALTERADO DEPOIS P/ PASTA 1 OU 2
                     _cMesoReg      ,;// 05 - GUARDA A MESO   DO PEDIDO DA COLUNA 1 - CONTEUDO FIXO / SEM ALTERACAO
                     _nTotAuxPall   ,;// 06 - TotaL de Pallets doa pedidoa vinculados DO PEDIDO DA COLUNA 1
                     _cClassEnt     ,;// 07 - "1-TOP 1 NACIONAL" DO PEDIDO DA COLUNA 1
                     "Palete Fechado: "+_cPaletFechado ,;// 08 - Pallet Fechado ou não DO PEDIDO DA COLUNA 1
                     "Carga Fechada: "+_cCargaFechada ,;// 09 - Carga Fechada ou não DO PEDIDO DA COLUNA 1
                     M->C5_I_TIPCA  ,;// 10 - Tipo: 1-Paletizada ou 2-Batida DO PEDIDO DA COLUNA 1
                     SC5->C5_I_PESBR})// 11 - Peso total do pedido DO PEDIDO DA COLUNA 1 - Deicar por ultimo sempre
   ENDIF

   IF EMPTY(_cObs)//_cObs: Preenchido na funcao MOMS66Ord ()
      _cLegenda:="ENABLE"
   ELSEIF _cObs = "D"//DEPOIS DE HOJE
      _cLegenda:="BR_BRANCO"
   ELSE //_cObs = "A"//ANTES DE HOJE
      _cLegenda:="BR_PRETO"
   ENDIF

   Aadd(_aPedidos, {"LBNO"          ,;                     //
                    "LBNO"          ,;                     //
                    "   "           ,;                     //CARGA C1 C2 C3 ...
                    _cLegenda       ,;                     //_cObs: Preenchido na funcao MOMS66Ord ()
                    "DISABLE"       ,;                     // 
                    "DISABLE"       ,;                     //"UP3",;"DOWN3",;0,;//07 //Ordem Prioridade Comercial ( Pode Alterar )
                    SC5->C5_NUM     ,;                     //
                    SC5->C5_EMISSAO ,;                     //
                    M->C5_I_TIPCA   ,;                     //TIPO DE CARGA - _nPosTPCA
                    _cTipCarga      ,;                     //TIPO DA CARGA - _nPosTPDACA
                    _nTotAuxPall    ,;                     //_nPosPalete
                    SC5->C5_I_PESBR ,;                     //_nPosPesBru
                    (DATE()-SC5->C5_EMISSAO) ,;            //
                    SC5->C5_I_DTENT ,;                     //
                    _dDataCalculada ,;                     // 
                    _cTipoEntr      ,;                     //Tp Agend
                    0               ,;                     //Ordem Prioridade Tipo de Agendamento ( Gerada ) _nPosOrdem
                    _nTotValor      ,;                     //_nPosTotPed
                    0               ,;                     //PESO SEM ESTOQUE - _nPosPesEst
                    _cNomeCli       ,;                     //
                    Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NOME") ,;
                    Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND2,"A3_NOME") ,;
                    Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND3,"A3_NOME") ,;
                    SC5->C5_I_MUN   ,;                     //
                    _cMicroReg      ,;                     //
                    _cMesoReg       ,;                     //
                    SC5->C5_I_EST   ,;                     //
                    _cRegiao        ,;                     //
                    SC5->C5_I_OPER  ,;                     //
                    SC5->C5_TPFRETE ,;                     //
                    SC5->C5_I_PEVIN ,;                     //
                    _cObs           ,;                     //_cObs: Preenchido na funcao MOMS66Ord ()
                    SC5->C5_I_QTDA  ,;                     //
                    _nDias          ,;                     //_nPosDias
                    _cClassEnt      ,;                     // TOP 1 NACIONAL - _nPosClass
                    _cPaletFechado  ,;                     // _nPosPaFec
                    _cCargaFechada  ,;                     // _nPosCaFechada
                    _cChave         ,;                     //CHAVE DE PRIORIDADE  
                    {SC5->(RECNO()),_aSC6_do_PV,(_nCapacPes-_nPesSaldoIni),.F.,(_nCapacPal-_nPalSaldoIni)},;//** POSICAO FIXA NÃO POR NENHUM CAMPO DEPOIS DESSE **
                    .F.            })                      //** POSICAO FIXA NÃO POR NENHUM CAMPO DEPOIS DESSE **

    (_cAlias2)->(dbSkip())

ENDDO

IF LEN(_aPedidos) = 0
   U_ITMSG("Nenhum pedido atendeu aos critérios de pendencias.",'Atenção!',,3) 
   RETURN "LOOP"
ENDIF

//_aGerProd:=ASORT(_aGerProd,,,{|X,Y| X < Y })//ORDENA PELA CHAVE DE PRIORIDADE

_cTotGeral:=ALLTRIM(STR(LEN(_aPedidos)))

(_cAlias2)->(DbCloseArea())

/*------------------------------------------*\
| Estrutura do aHeader do MsNewGetDados      |
|--------------------------------------------|
| aHeader[01] - X3_TITULO  | Título          |
| aHeader[02] - X3_CAMPO   | Campo           |
| aHeader[03] - X3_PICTURE | Picture         |
| aHeader[04] - X3_TAMANHO | Tamanho         |
| aHeader[05] - X3_DECIMAL | Decimal         |
| aHeader[06] - X3_VALID   | Validação       |
| aHeader[07] - X3_USADO   | Usado           |
| aHeader[08] - X3_TIPO    | Tipo            |
| aHeader[09] - X3_F3      | F3              |
| aHeader[10] - X3_CONTEXT | Contexto (R,V)  |
| aHeader[11] -,X3_CBOX    | Combobox        |
| aHeader[12] -,X3_RELACAO | Inicial. Padrao |
| aHeader[13] -,X3_WHEN    | Habilita edicao |
| aHeader[14] -,X3_VISUAL  | Alteravel (A,V) |
| aHeader[15] -,X3_VLDUSER | Valid de User   |
| aHeader[16] -,X3_PICTVAR | Picture         |
| aHeader[17] -,X3_OBRIGAT | Obrigatorio     |
\*------------------------------------------*/

Private aHeaderP:={}
Private aColsP  :={}
                                                                                //ESSE X3_TIPO SÓ INFLUENCIA NA GERAÇÃO DO EXCEL EM DECIDIR A PICTURE DA COLUNA
                                                                                //NÃO INTERFERE E NÃO SEGUE O TIPO GRAVADO NA _aPedidos, É INDEPENDENTE NOS CASO DE "C" e "N"
//                          1          2            3   4 5       6          7        8       9           10    11       12         13         14          15        16             17
//aHeader,{Alltrim(SX3->X3_TITULO), X3_CAMPO   , PICT ,TA,D, AllwaysTrue(),  USADO,X3_TIPO,ARQUIVO,X3_CONTEXT,X3_CBOX,X3_RELACAO,X3_WHEN   ,X3_VISUAL ,X3_VLDUSER,X3_PICTVAR,X3_OBRIGAT
Aadd(aHeaderP,{"Suger."            ,"MARCA"     ,"@BMP",04,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        ,".T."})  // 
nPosOK :=LEN(aHeaderP)                                
Aadd(aHeaderP,{"Logi.OK"          ,"MARCA2"    ,"@BMP",04,0,""                ,""  ,"C"    ,""     ,""        ,""     ,""        ,".T."})  // 
nPosOK2:=LEN(aHeaderP)                                
Aadd(aHeaderP,{"Carga"             ,"CARGA"     ,"!!" ,02,0,""                ,""  ,"C"    ,""     ,""        ,""     ,""        ,".T."})  // 
nPosC1 :=LEN(aHeaderP)                                
Aadd(aHeaderP,{"Carregar"          ,"PO_OK"     ,"@BMP",05,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        ,".T."})  // 
nPosCar:=LEN(aHeaderP)                                
Aadd(aHeaderP,{"Estoque"           ,"ESTOQUE"   ,"@BMP",05,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        ,".T."})
_nPosEst:=LEN(aHeaderP)                                
Aadd(aHeaderP,{"Capacidade"        ,"CAPACIDA"  ,"@BMP",05,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        ,".T."})
_nPosCap:=LEN(aHeaderP)                                
//Aadd(aHeaderP,{"-"               ,"PO_UP"     ,"@BMP",01,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        , "aColsP[n][nPosCar] <> 'BR_ PRETO'" })// 
//_nPosUP  :=LEN(aHeaderP)//02                                
//Aadd(aHeaderP,{"+"               ,"PO_DOWN"   ,"@BMP",01,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        , "aColsP[n][nPosCar] <> 'BR_ PRETO'" })//0
//_nPosDOWN:=LEN(aHeaderP)//03                                
//Aadd(aHeaderP,{"Com. Alt","PO_ORDEMC","9999",04,0,"U_M66Valid()"            ,""  ,"N"    ,""     ,""        ,""     ,""        , "aColsP[n][nPosCar] <> 'BR_ PRETO'" })// //Chave Prioridade Comercial ( Gerada / Alterada)
//_nPosORC:=LEN(aHeaderP)//04                                
Aadd(aHeaderP,{"Pedido"            ,"PEDIDO"    ,"@!"  ,LEN(SC5->C5_NUM),0,"" ,""  ,"C"    ,""     ,""        ,""     ,""        ,".T."}) //
_nPosPed:=LEN(aHeaderP)//06                                
Aadd(aHeaderP,{"Dt Emissao"        ,"C5EMISSAO" ,"@D"  ,08,0,""               ,""  ,"D"    ,""     ,""        ,""     ,"CTOD('')",".F."})
_nPosEms:=LEN(aHeaderP)//07                                
Aadd(aHeaderP,{"Tipo de Carga"     ,"TPDECARGA" ,"@!"  ,15,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosTPCA :=LEN(aHeaderP)//M->C5_I_TIPCA                                  
Aadd(aHeaderP,{"Tipo da Carga"     ,"CTIPCARGA" ,"@!"  ,15,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosTPDACA :=LEN(aHeaderP)//_cTipCarga                                  
Aadd(aHeaderP,{"Qtde Palete"       ,"QTDE_PALETE","@E 999,999.99"     ,09,2,"",""  ,"N"    ,""     ,""        ,""     ,""        ,".F."})
_nPosPalete:=LEN(aHeaderP)                                
Aadd(aHeaderP,{"Peso Bruto"        ,"C5_I_PESBR","@E 999,999,999.9999",14,4,"",""  ,"N"    ,""     ,""        ,""     ,""        ,".F."})
_nPosPesBru:=LEN(aHeaderP)                                  
Aadd(aHeaderP,{"Dias"              ,"DIAS_ATRASO",""   ,06,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosAtraso:=LEN(aHeaderP)//07                                
Aadd(aHeaderP,{"Dt Entrega"        ,"C5I_DTENT"  ,"@D" ,08,0,""               ,""  ,"D"    ,""     ,""        ,""     ,"CTOD('')",".F."})
_nPosEnt:=LEN(aHeaderP)                                
Aadd(aHeaderP,{"Dt Necessidade"    ,"DT_NECESSI","@D"  ,08,0,""               ,""  ,"D"    ,""     ,""        ,""     ,"CTOD('')",".F."})
_nPosNes:=LEN(aHeaderP)                                
Aadd(aHeaderP,{"Tp Agend "         ,"TIPO_AGEND",""    ,15,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosTpA:=LEN(aHeaderP)                                
Aadd(aHeaderP,{"Posicao"           ,"PO_ORDEMA" ,"9999",04,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        ,".T."}) // //Chave Prioridade Tipo de Agendamento
_nPosOrdem:=LEN(aHeaderP)//05                                
Aadd(aHeaderP,{"Total Pedido"      ,"TOT_PEDIDO","@E 999,999,999,999.99",01,0,"","","N"    ,""     ,""        ,""     ,""        ,".F."})
_nPosTotPed:=LEN(aHeaderP)//_nTotValor
Aadd(aHeaderP,{"Peso sem Estoque"  ,"PES_S_ESTO","@E 999,999,999.9999"  ,01,0,"","","N"    ,""     ,""        ,""     ,""        ,".F."})
_nPosPesEst:=LEN(aHeaderP)                                  
Aadd(aHeaderP,{"Cliente"           ,"C5_CLIENTE","@!" ,040,0,""                ,"" ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosCli:=LEN(aHeaderP)                                  
Aadd(aHeaderP,{"Vendedor"          ,"C5VEND1"   ,"@!" ,040,0,""                ,"" ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosVend:=LEN(aHeaderP)                                  
Aadd(aHeaderP,{"Coordenador"       ,"C5_VEND2"  ,"@!" ,040,0,""                ,"" ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosCoor:=LEN(aHeaderP)                                  
Aadd(aHeaderP,{"Gerente"           ,"C5_VEND3"  ,"@!" ,040,0,""                ,"" ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosGer:=LEN(aHeaderP)                                  
Aadd(aHeaderP,{"Mucnicipio"        ,"C5_I_MUN"  ,"@!" ,LEN(SC5->C5_I_MUN),0,"" ,"" ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosMun:=LEN(aHeaderP)                                  
Aadd(aHeaderP,{"Microrregião"      ,"Z22_NOME"  ,"@!" ,LEN(Z22->Z22_NOME),0,"" ,"" ,"C"    ,""     ,""        ,""     ,""        ,".F."})
Aadd(aHeaderP,{"Mesorregião"       ,"Z21_NOME"  ,"@!" ,LEN(Z21->Z21_NOME),0,"" ,"" ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosMeso:=LEN(aHeaderP)//_cMesoReg                                
Aadd(aHeaderP,{"UF"                ,"C5_I_EST"  ,"@!" ,002,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosUF:=LEN(aHeaderP)
Aadd(aHeaderP,{"Região do Brasil"  ,"REGIAOBR"  ,"@!" ,015,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosRGBR:=LEN(aHeaderP)//_cRegiao                                
Aadd(aHeaderP,{"Tp Operacao"       ,"C5_I_OPER" ,"@!" ,001,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosTpO:=LEN(aHeaderP)                                
Aadd(aHeaderP,{"Tp Frete"          ,"C5_TPFRETE","@!" ,001,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosTpF:=LEN(aHeaderP)                                
Aadd(aHeaderP,{"Ped. Vinculado"   ,"C5_I_PEVIN","@!" ,LEN(SC5->C5_NUM)+14,0,"",""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosPedVin=LEN(aHeaderP)                                
Aadd(aHeaderP,{"Observacao"        ,"OBSERVAC"  ,"  " ,150,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosObs  :=LEN(aHeaderP)                                
Aadd(aHeaderP,{"Qtd Reagend."      ,"C5_I_QTDA" ,"99" ,002,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosReg:=LEN(aHeaderP)                                
Aadd(aHeaderP,{"T.T."              ,"DIAS"      ,"9999",004,0,""              ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosDias:=LEN(aHeaderP)                                
Aadd(aHeaderP,{"Classif. Entrega"  ,"CLASENTREG","@!" ,020,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosClass:=LEN(aHeaderP)//"1-TOP 1 NACIONAL" / _cClassEnt                                
Aadd(aHeaderP,{"Paletes Fechados?"  ,"CARGACOMPL","@!",005,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosPaFec:=LEN(aHeaderP)//_cPaletFechado                                
Aadd(aHeaderP,{"Carga Fechada?"    ,"CARGAFECHA","@!" ,005,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosCaFechada:=LEN(aHeaderP)//_cCargaFechada                                
Aadd(aHeaderP,{"Controle"          ,"CONTROLE"  ,"@!" ,050,0,""               ,""  ,"C"    ,""     ,""        ,""     ,""        ,".F."})
_nPosChave:=LEN(aHeaderP)                                                        //ESSE TIPO SÓ INFLUENCIA NA GERAÇÃO DO EXCEL EM DECIDIR A PICTURE DA COLUNA
                                                                                 //NÃO INTERFERE E NÃO SEGUE O TIPO GRAVADO NA _aPedidos, É INDEPENDENTE NOS CASO DE "C" e "N"

_nPosRecnos:=(LEN(aHeaderP)+1)//{SC5->(RECNO()),_aSC6_do_PV,(_nCapacPes-_nPesSaldoIni),.F.}

PRIVATE _nTotGerFin  := _nTotNaoGerFin := _nTotPonFat := _nToRPonFat := 0
PRIVATE _aGerentes   := {}
PRIVATE _aCortaItem  := {}//BOTAO "CORTAR PRODUTOS" 
PRIVATE _aCortaPed   := {}//BOTAO "CORTAR PRODUTOS" 
PRIVATE _aPedXProdSE := {}//BOTAO "PEDIDOS X PRODUTOS SEM ESTOQUE"

// *************  DIVIDE OS PEDIDOS *********************** //

_aPedTOP1:={}
_aPedCAFE:={}
_aPedFORA:={}
_aPedRGBR:={{},{},{},{},{}}// 5 - REGIOES
aFoders1:={}
AADD(aFoders1,"Cargas Fechadas TOP1")        //Se mudar os nomes tem que mudar em todo o programa pq eles são chave de Pesquisa      
AADD(aFoders1,"Cargas Fechadas")             //Se mudar os nomes tem que mudar em todo o programa pq eles são chave de Pesquisa 
AADD(aFoders1,"Pedidos fora de padrão")
AADD(aFoders1,"Cargas por Regioes")
_aTotPonFat :={}
AADD(_aTotPonFat,{"TOTAL GERAL"         ,0})
AADD(_aTotPonFat,{aFoders1[1]           ,0})//"Cargas Fechadas TOP1"
AADD(_aTotPonFat,{aFoders1[2]           ,0})//"Cargas Fechadas"     
AADD(_aTotPonFat,{aFoders1[3]           ,0})//"Pedidos fora de padrão"
AADD(_aTotPonFat,{"Regiao Sudeste"      ,0})//Se mudar os nomes tem que mudar em todo o programa pq eles são chave de Pesquisa
AADD(_aTotPonFat,{"Regiao Sul"          ,0})//Se mudar os nomes tem que mudar em todo o programa pq eles são chave de Pesquisa
AADD(_aTotPonFat,{"Regiao Centro Oeste" ,0})//Se mudar os nomes tem que mudar em todo o programa pq eles são chave de Pesquisa
AADD(_aTotPonFat,{"Regiao Norte"        ,0})//Se mudar os nomes tem que mudar em todo o programa pq eles são chave de Pesquisa
AADD(_aTotPonFat,{"Regiao Nordeste"     ,0})//Se mudar os nomes tem que mudar em todo o programa pq eles são chave de Pesquisa

AADD(aFolderRGBR,"Regiao Centro Oeste" )
AADD(aFolderRGBR,"Regiao Norte"        )
AADD(aFolderRGBR,"Regiao Nordeste"     )
AADD(aFolderRGBR,"Regiao Sudeste"      )
AADD(aFolderRGBR,"Regiao Sul"          )
aFolderRGBR:= ASORT(aFolderRGBR)//ATE 5 REGIOES 

_cTotGeral:=ALLTRIM(STR(LEN(_aPedidos)))

IF MV_PAR09 = 1 .AND. SB2->(FIELDPOS("B2_I_QLIBE")) > 0 
   MOMS66CLB(_aPedidos,oProc)
ENDIF

FOR P := 1 TO LEN(_aPedidos) 
   
   nConta++
   oProc:cCaption := ("3-Separando os pedidos - "+STRZERO(nConta,5) +" de "+ _cTotGeral )
   ProcessMessages()
    
    _nPesoAux:=_aPedidos[P,_nPosPesBru]
    IF !EMPTY(_aPedidos[P,_nPosPedVin]) .AND. (_nPos:=ASCAN(aPedVin,{|aPed| aPed[1] == _aPedidos[P,_nPosPed] } )) > 0
       _nPesoAux+=aPedVin[_nPos][ LEN(aPedVin[_nPos]) ]
    EndIf

    IF _aPedidos[P,_nPosClass] == "1-TOP 1 NACIONAL" .AND. _aPedidos[P,_nPosCaFechada] == "1-SIM" // _cClassEnt
       AADD(_aPedTOP1,_aPedidos[P])           //TOP 1 NACIONAL e CARGA FECHADA
       
       IF !EMPTY(_aPedidos[P,_nPosPedVin]) .AND. (_nPos:=ASCAN(aPedVin,{|aPed| aPed[1] == _aPedidos[P,_nPosPed] } )) > 0
           aPedVin[_nPos,3]:=aFoders1[1]+" ("+_aPedidos[P,_nPosRGBR]+" /"+_aPedidos[P,_nPosMeso]+")"
           aPedVin[_nPos,4]:=aFoders1[1]      //"Cargas Fechadas TOP1"
       ENDIF
    
    ELSEIF _aPedidos[P,_nPosCaFechada] == "1-SIM" 
       AADD(_aPedCAFE,_aPedidos[P])           //CARGA FECHADA

       IF !EMPTY(_aPedidos[P,_nPosPedVin]) .AND. (_nPos:=ASCAN(aPedVin,{|aPed| aPed[1] == _aPedidos[P,_nPosPed] } )) > 0
           aPedVin[_nPos,3]:=aFoders1[2]+" ("+_aPedidos[P,_nPosRGBR]+" /"+ALLTRIM(_aPedidos[P,_nPosMeso]) + ")"
           aPedVin[_nPos,4]:=aFoders1[2]//"Cargas Fechadas"
       ENDIF

    ELSEIF _nPesoAux > _nPesoMax
       AADD(_aPedFORA,_aPedidos[P])           //"Pedidos fora de padrão"

       IF !EMPTY(_aPedidos[P,_nPosPedVin]) .AND. (_nPos:=ASCAN(aPedVin,{|aPed| aPed[1] == _aPedidos[P,_nPosPed] } )) > 0
           aPedVin[_nPos,3]:=aFoders1[3]+" ("+_aPedidos[P,_nPosRGBR]+" /"+ALLTRIM(_aPedidos[P,_nPosMeso]) + ")"
           aPedVin[_nPos,4]:=aFoders1[3]      //"Pedidos fora de padrão"
       ENDIF

    ELSEIF _aPedidos[P,_nPosCaFechada] <> "1-SIM" //CARGA NAO FECHADA

       IF !EMPTY(_aPedidos[P,_nPosPedVin]) .AND. (_nPos:=ASCAN(aPedVin,{|aPed| aPed[1] == _aPedidos[P,_nPosPed] } )) > 0
           aPedVin[_nPos,3]:=_aPedidos[P,_nPosRGBR]+ " / "+_aPedidos[P,_nPosMeso]//+" / "+ALLTRIM(aPedVin[_nPos,3]) 
       ENDIF

       IF (nPosR:=ASCAN(aFolderRGBR,_aPedidos[P,_nPosRGBR] )) > 0 //PROCURA A REGIAO PARA POR NA POSICAO CERTA A MESO
           AADD(_aPedRGBR[nPosR], { _aPedidos[P,_nPosMeso] , _aPedidos[P] , _aPedidos[P,_nPosRGBR] })
       Endif
    
    ENDIF
NEXT

oProc:cCaption := ("4-Analisando Pedidos TOP 1..." )
ProcessMessages()
_aSB2Inic:= {} 
_lSomaPontFat:=.T.//LIGA AQUI A SOMA PARA NA CARGA INICIAL

_aPedTOP1:=MOMS66PVinc(_aPedTOP1)              // ANALIZA OS PEDIDOS VINCULADOS E MARCA A ORDEM DE CONSUMO DO ESTOQUE
_aPedTOP1:=MOMS66PC(_aPedTOP1,"TODOS",.T.,.F.,,aFoders1[1]) //ZERA A ARRAY _aSB2 NO PRIMEIRO PARA LER O ESTOQUE OFICIAL// VERIFICANDO ESTOQUE E CAPACIDADE DA UNIDADE PROCESSAMENTO PRINCIPAL  ////

oProc:cCaption := ("5-Analisando Pedidos Carga fechada..." )
ProcessMessages()

_aPedCAFE:=MOMS66PVinc(_aPedCAFE)              // ANALIZA OS PEDIDOS VINCULADOS E MARCA A ORDEM DE CONSUMO DO ESTOQUE
_aPedCAFE:=MOMS66PC(_aPedCAFE,"TODOS",.F.,.F.,,aFoders1[2]) // VERIFICANDO ESTOQUE E CAPACIDADE DA UNIDADE PROCESSAMENTO PRINCIPAL  ////

oProc:cCaption := ("5-Analisando Pedidos fora de padrão..." )
ProcessMessages()

_aSB2:=MOMS66aSB2(_aSB2,"SALVA")//Salva estoque antes de processar as Regioes
_nBKPPesoLib  := _nTotPesoLib   //Salva totais antes de processar as Regioes
_nBKPPalsLib  := _nTotPalsLib   //Salva totais antes de processar as Regioes
_nBKPGerFin   := _nTotGerFin    //Salva totais antes de processar as Regioes
_nBKPNaoGerFin:= _nTotNaoGerFin //Salva totais antes de processar as Regioes

_aPedFORA:=MOMS66PVinc(_aPedFORA)              // ANALIZA OS PEDIDOS VINCULADOS E MARCA A ORDEM DE CONSUMO DO ESTOQUE
_aPedFORA:=MOMS66PC(_aPedFORA,"TODOS",.F.,.T.,,aFoders1[3]) // VERIFICANDO ESTOQUE E CAPACIDADE DA UNIDADE PROCESSAMENTO PRINCIPAL  ////

_nTot:=LEN(_aPedRGBR) 
P:=1
DO  WHILE P <= _nTot 
    IF LEN(_aPedRGBR[P]) = 0
       aDEL(aFolderRGBR,P)
       aSIZE(aFolderRGBR,Len(aFolderRGBR)-1)
       aDEL(_aPedRGBR,P)
       aSIZE(_aPedRGBR,Len(_aPedRGBR)-1)
       _nTot:=LEN(_aPedRGBR) 
    ELSE
       P++
    ENDIF
ENDDO
IF _nTot = 0
  aDEL(aFoders1,4)
  aSIZE(aFoders1,3)
ENDIF

aPedsReg1:={}//Array com todos os Pedidos das mesos da Regiao 1
aPedsReg2:={}//Array com todos os Pedidos das mesos da Regiao 2
aPedsReg3:={}//Array com todos os Pedidos das mesos da Regiao 3
aPedsReg4:={}//Array com todos os Pedidos das mesos da Regiao 4
aPedsReg5:={}//Array com todos os Pedidos das mesos da Regiao 5

aFoldReg1:={}//Array com todos os nomes das mesos da Regiao 1
aFoldReg2:={}//Array com todos os nomes das mesos da Regiao 2
aFoldReg3:={}//Array com todos os nomes das mesos da Regiao 3
aFoldReg4:={}//Array com todos os nomes das mesos da Regiao 4
aFoldReg5:={}//Array com todos os nomes das mesos da Regiao 5
_cTotGeral:=ALLTRIM(STR(LEN(_aPedRGBR)))
FOR P := 1 TO LEN(_aPedRGBR) //LENDO AS 5 REGIOES

    IF P <= LEN(aFolderRGBR)
       oProc:cCaption := ("6-Analisando "+aFolderRGBR[P]+" - "+STRZERO(P,1) +" de "+ _cTotGeral )
       ProcessMessages()
    ENDIF

    _aPedPasta:=_aPedRGBR[P]
    IF LEN(_aPedPasta) = 0
       LOOP
    ENDIF
    _aPedPasta:=ASORT( _aPedPasta, , , {|X,Y| X[1] < Y[1] } )//POR MESO
    _cMesoReg:=ALLTRIM(_aPedPasta[1,1])
    IF P = 1 
        AADD(aFoldReg1,_cMesoReg)//PRIMEIRA NOME AQUI 
    ELSEIF P = 2
        AADD(aFoldReg2,_cMesoReg)//PRIMEIRA NOME AQUI 
    ELSEIF P = 3
        AADD(aFoldReg3,_cMesoReg)//PRIMEIRA NOME AQUI 
    ELSEIF P = 4
        AADD(aFoldReg4,_cMesoReg)//PRIMEIRA NOME AQUI 
    ELSEIF P = 5
        AADD(aFoldReg5,_cMesoReg)//PRIMEIRA NOME AQUI 
    ENDIF
    aMesoAux:={}
    FOR M := 1 TO LEN(_aPedPasta) //LENDO AS MESO DE CADA REGIAO
        IF ALLTRIM(_aPedPasta[M,1]) == _cMesoReg
          AADD(aMesoAux,_aPedPasta[M,2])
        ELSE
          _cMesoReg := ALLTRIM(_aPedPasta[M,1])
          IF P = 1 
              AADD(aPedsReg1,aMesoAux)   
              AADD(aFoldReg1,_cMesoReg)//SEGUNDO EM DIANTE NOME AQUI 
          ELSEIF P = 2
              AADD(aPedsReg2,aMesoAux)   
              AADD(aFoldReg2,_cMesoReg)//SEGUNDO EM DIANTE NOME AQUI 
          ELSEIF P = 3
              AADD(aPedsReg3,aMesoAux)   
              AADD(aFoldReg3,_cMesoReg)//SEGUNDO EM DIANTE NOME AQUI 
          ELSEIF P = 4
              AADD(aPedsReg4,aMesoAux)   
              AADD(aFoldReg4,_cMesoReg)//SEGUNDO EM DIANTE NOME AQUI 
          ELSEIF P = 5
              AADD(aPedsReg5,aMesoAux)   
              AADD(aFoldReg5,_cMesoReg)//SEGUNDO EM DIANTE NOME AQUI 
          ENDIF
          aMesoAux:={}
          AADD(aMesoAux,_aPedPasta[M,2])
       ENDIF
    NEXT
    IF P = 1 
       AADD(aPedsReg1,aMesoAux)   
    ELSEIF P = 2
       AADD(aPedsReg2,aMesoAux)   
    ELSEIF P = 3
       AADD(aPedsReg3,aMesoAux)   
    ELSEIF P = 4
       AADD(aPedsReg4,aMesoAux)   
    ELSEIF P = 5
       AADD(aPedsReg5,aMesoAux)   
    ENDIF
NEXT

FOR P := 1 TO LEN(aPedsReg1) //LENDO AS REGIOES
    _aPedPasta:=aPedsReg1[P]
    aPedsReg1[P]:=MOMS66PVinc(_aPedPasta)       //// ANALIZA OS PEDIDOS VINCULADOS E MARCA A ORDEM DE CONSUMO DO ESTOQUE
    aPedsReg1[P]:=MOMS66PC(aPedsReg1[P],"TODOS",.F.,.T.) // VERIFICANDO ESTOQUE E CAPACIDADE DA UNIDADE PROCESSAMENTO PRINCIPAL  ////
NEXT
FOR P := 1 TO LEN(aPedsReg2) //LENDO AS REGIOES
    _aPedPasta:=aPedsReg2[P]
    aPedsReg2[P]:=MOMS66PVinc(_aPedPasta)       //// ANALIZA OS PEDIDOS VINCULADOS E MARCA A ORDEM DE CONSUMO DO ESTOQUE
    aPedsReg2[P]:=MOMS66PC(aPedsReg2[P],"TODOS",.F.,.T.) // VERIFICANDO ESTOQUE E CAPACIDADE DA UNIDADE PROCESSAMENTO PRINCIPAL  ////
NEXT
FOR P := 1 TO LEN(aPedsReg3) //LENDO AS REGIOES
    _aPedPasta:=aPedsReg3[P]
    aPedsReg3[P]:=MOMS66PVinc(_aPedPasta)       //// ANALIZA OS PEDIDOS VINCULADOS E MARCA A ORDEM DE CONSUMO DO ESTOQUE
    aPedsReg3[P]:=MOMS66PC(aPedsReg3[P],"TODOS",.F.,.T.) // VERIFICANDO ESTOQUE E CAPACIDADE DA UNIDADE PROCESSAMENTO PRINCIPAL  ////
NEXT
FOR P := 1 TO LEN(aPedsReg4) //LENDO AS REGIOES
    _aPedPasta:=aPedsReg4[P]
    aPedsReg4[P]:=MOMS66PVinc(_aPedPasta)       //// ANALIZA OS PEDIDOS VINCULADOS E MARCA A ORDEM DE CONSUMO DO ESTOQUE
    aPedsReg4[P]:=MOMS66PC(aPedsReg4[P],"TODOS",.F.,.T.) // VERIFICANDO ESTOQUE E CAPACIDADE DA UNIDADE PROCESSAMENTO PRINCIPAL  ////
NEXT
FOR P := 1 TO LEN(aPedsReg5) //LENDO AS REGIOES
    _aPedPasta:=aPedsReg5[P]
    aPedsReg5[P]:=MOMS66PVinc(_aPedPasta)       //// ANALIZA OS PEDIDOS VINCULADOS E MARCA A ORDEM DE CONSUMO DO ESTOQUE
    aPedsReg5[P]:=MOMS66PC(aPedsReg5[P],"TODOS",.F.,.T.) // VERIFICANDO ESTOQUE E CAPACIDADE DA UNIDADE PROCESSAMENTO PRINCIPAL  ////
NEXT

_lSomaPontFat:=.F.//DESLIGA A SOMA PARA FRENTE

oProc:cCaption := ("Montando Pastas..." )
ProcessMessages()

_aSB2:=MOMS66aSB2(_aSB2,"VOLTA")//RESTAURA AQUI PQ O ESTOQUE DAS REGIOES NÃO CONSOME AINDA PQ É SIMULACAO 
_nTotPesoLib  := _nBKPPesoLib   //RESTAURA AQUI PQ O ESTOQUE DAS REGIOES NÃO CONSOME AINDA PQ É SIMULACAO 
_nTotPalsLib  := _nBKPPalsLib   //RESTAURA AQUI PQ O ESTOQUE DAS REGIOES NÃO CONSOME AINDA PQ É SIMULACAO 
_nTotGerFin   := _nBKPGerFin    //RESTAURA AQUI PQ O ESTOQUE DAS REGIOES NÃO CONSOME AINDA PQ É SIMULACAO 
_nTotNaoGerFin:= _nBKPNaoGerFin //RESTAURA AQUI PQ O ESTOQUE DAS REGIOES NÃO CONSOME AINDA PQ É SIMULACAO 

IF LEN(_aPedidos) > 0 
   
   Private _aSize := MsAdvSize()
   Private _aInfo := { _aSize[1] , _aSize[2] , _aSize[3] , _aSize[4] , 3 , 3 }
   
   // pega tamanhos das telas
   aObjects := {}
   AADD( aObjects , { 100 , 050 , .T. , .F. , .F. } )
   AADD( aObjects , { 100 , 100 , .T. , .T. , .F. } )
   aPosObj  := MsObjSize( _aInfo , aObjects )
   nNext    := 0
   nOpca    := 0
   nGDAction:= GD_UPDATE

   aColsP := _aPedidos//SEM ACLONE PQ SE MEXER NO ACOLS TEM QUE MEXE NO _APEDIDOS  ******************************************

   
// bReprocessa:={|| IF(U_ITMSG("Confirma REPROCESSAMENTO ?",'Atenção!',"O estoque será lido novamente e as marcações selecionadas serão perdidas!!!",2,2,2),(_lReprocessar:=.T.,oDlg2:End()),) }
   bReprocessa:={|| IF(U_ITMSG("Confirma REPROCESSAMENTO ?",'Atenção!',,2,2,2),(_lReprocessar:=.T.,oDlg2:End()),) }
   _bEfetivar :={|| IF(MOMS66Acesso(_lEfetivar) .AND.;
                    U_ITMSG("Confirma EFETIVACAO / GRAVACAO ?",'EFETIVACAO / GRAVACAO!',"ATENÇÃO: Cargas não validadas nas Mesorregiões não serão liberadas.",2,2,2),(_lGrava:=.T.,oDlg2:End()),) }
   _bSair     :={|| (_lGrava:=.F.,oDlg2:End())  }
   _bSimular  :={|| IF(MOMS66Acesso(_lEfetivar) .AND.;
                    U_ITMSG("Confirma SIMULACAO / GRAVACAO ?",'SIMULACAO / GRAVACAO!',,2,2,2),(_lSimular:=.T.,oDlg2:End()),) }

   aBotoes:={} 
   AADD(aBotoes,{"",bReprocessa         ,"","REPROCESSAR"}) 
   AADD(aBotoes,{"",{|| FWMSGRUN( ,{|| MOMS66Pesq()              },"Pesquisando.."         ,"H.I. : "+TIME()+" - Aguarde..." )},"","PESQUISAR"                 }) //
   AADD(aBotoes,{"",_bSimular                                     ,"","SIMULACAO"})            
   AADD(aBotoes,{"",{|| MOMS66Alt(.T.)                           },"","Desvincula Pedidos"  })    																  // 
   AADD(aBotoes,{"",{|| MOMS66Alt(.F.)                           },"","CORTAR PRODUTOS"     })    																  // 
   AADD(aBotoes,{"",{|| FWMSGRUN( ,{|| MOMS66Item("PEDXPRODSEST")},"Lendo Itens.."         ,"H.I. : "+TIME()+" - Aguarde...")},"","Pedidos X Prod. sem Estoque"}) // 
   AADD(aBotoes,{"",{|| FWMSGRUN( ,{|| MOMS66Item("ITENS"       )},"Lendo Itens.."         ,"H.I. : "+TIME()+" - Aguarde...")},"","VER / CORTAR Itens Pedido"  }) // 
   AADD(aBotoes,{"",{|| FWMSGRUN( ,{|| MOMS66Item("CONSOLIDADO" )},"Lendo Itens.."         ,"H.I. : "+TIME()+" - Aguarde...")},"","SALDO CONSOLIDADO"          }) // 
// AADD(aBotoes,{"",{|| FWMSGRUN( ,{|| MOMS66Item("GERENTES"    )},"Lendo Itens.."         ,"H.I. : "+TIME()+" - Aguarde...")},"","RESERVA dos GERENTES"       }) // RETIRADO POR ENQUANTO PARA REVER A LOGICA PARA O NOVO LAYOUT
   AADD(aBotoes,{"",{|| FWMSGRUN( ,{|| MOMS66PPV("S")            },"Lendo Pedidos.."       ,"H.I. : "+TIME()+" - Aguarde...")},"","Ver Pedido Monitor"         }) // 
   AADD(aBotoes,{"",{|| FWMSGRUN( ,{|| MOMS66PPV("D")            },"Lendo Pedidos.."       ,"H.I. : "+TIME()+" - Aguarde...")},"","Ver Pedido Detalhado"       }) // 
   AADD(aBotoes,{"",{|| FWMSGRUN( ,{|O| MOMS66Excel("DETI",O,)   },"Lendo Pedidos.."       ,"H.I. : "+TIME()+" - Aguarde...")},"","Detalhamento por Itens"     }) // 
   AADD(aBotoes,{"",{|| FWMSGRUN( ,{|O| MOMS66Excel("XLSX",O,)   },"Gerando Excel (XLSX)..","H.I. : "+TIME()+" - Aguarde...")},"","Exportacao para XLSX"       }) //  
   AADD(aBotoes,{"",{|| FWMSGRUN( ,{|O| MOMS66Excel("XML" ,O,)   },"Gerando Excel (XML).. ","H.I. : "+TIME()+" - Aguarde...")},"","Exportacao para XML "       }) // 
   IF !(GetRemoteType() == 5) //Valida se o ambiente é Protheus via HTML           
   AADD(aBotoes,{"",{|| FWMSGRUN( ,{|O| MOMS66Excel("CSV" ,O,)   },"Gerando Excel (CSV).. ","H.I. : "+TIME()+" - Aguarde...")},"","Exportacao para CSV "       }) //
   ENDIF
   AADD(aBotoes,{"",{|| MOMS66LEG(.F.) },"","Legendas"   }) 
   
   DO WHILE .T.

      _lReprocessar:=.F.
      _lGrava:=.F.
      _lSimular:=.F.
      nLin01:=05
      nLin02:=08 
      nLin03:=25 
      nCol01:=02
      aBrowses:={}
      oTFolder01:=NIL
   
      DEFINE MSDIALOG oDlg2 TITLE _cTitulo OF oMainWnd PIXEL FROM _aSize[7],0 TO _aSize[6],_aSize[5]

      //PARTE DE CIMA DA TELA PRINCIPAL **************************************************************************
                                                        //Largura , ALTURA
       oPnlTopTop := TPanel():New( 1 , 0 , , oDlg2 , , , , , , 80 , 20 , .F. , .F. )   

       oMenu:=TMenu():New(0,0,0,0,.T.)  
       _aMenu:={}
       FOR P := 1 TO LEN(aBotoes)
           AADD( _aMenu , TMenuItem():New(oMenu,aBotoes[P,4],,,,aBotoes[P,2],,,,,,,,,.T.) )
           oMenu:Add(_aMenu[P])
       NEXT

//	   @ nLin01, nCol01 BUTTON oBtMenu PROMPT  "REPROCESSAR" SIZE 045, 013 OF oPnlTopTop ACTION EVAL( bReprocessa ) PIXEL
       @ nLin01, nCol01 BUTTON oBtMenu PROMPT  "AÇÕES"       SIZE 045, 013 OF oPnlTopTop ACTION EVAL( .T. ) PIXEL
       oBtMenu:SetPopupMenu(oMenu)
       nCol01+=49
       
       @ nLin01, nCol01 BUTTON  "GERAR"          SIZE 030, 013 OF oPnlTopTop ACTION EVAL( _bEfetivar  ) PIXEL
       nCol01+=35
       
       @ nLin01, nCol01 BUTTON  "SAIR"           SIZE 025, 013 OF oPnlTopTop ACTION EVAL( _bSair      ) PIXEL
       nCol01+=30	   

          @ nLin02-5,nCol01 SAY "Saldo Inicial: " +("KG "+ALLTRIM(TRANS(_nPesSaldoIni,"@E 999,999,999,999.999"))) SIZE 099,009 OF oPnlTopTop PIXEL 
          @ nLin02+5,nCol01 SAY "Qtde de Palete: "+(ALLTRIM(TRANS(_nPalSaldoIni,"@E 999,999,999,999.999")))       SIZE 099,009 OF oPnlTopTop PIXEL 	   
       nCol01+=(35+55)
          
       @ nLin02-5,nCol01 SAY oSAYPesLib PROMPT "A Liberar: "+("KG "+ALLTRIM(TRANS( _nTotPesoLib,"@E 999,999,999,999.999"))) SIZE 099,009 OF oPnlTopTop PIXEL 
          @ nLin02+5,nCol01 SAY oSAYPalLib PROMPT "Qtde Palete: "+(ALLTRIM(TRANS( _nTotPalsLib,"@E 999,999,999,999.999")))     SIZE 099,009 OF oPnlTopTop PIXEL 
       nCol01+=(24+55)
       
          @ nLin02-5,nCol01 SAY "Capacidade UN: " +("KG "+ALLTRIM(TRANS(_nCapacPes,"@E 999,999,999,999"))) SIZE 199,009 OF oPnlTopTop PIXEL 
          @ nLin02+5,nCol01 SAY "Qtde de Palete: "+(ALLTRIM(TRANS(_nCapacPal,"@E 999,999,999,999")))       SIZE 199,009 OF oPnlTopTop PIXEL 
       nCol01+=(38+55)

          @ nLin02-5,nCol01 SAY oSAYVlGer   PROMPT "Valor Gera Financeiro: "   +("R$ "+ALLTRIM(TRANS( _nTotGerFin  ,"@E 999,999,999,999.99"))) SIZE 199,009 OF oPnlTopTop PIXEL 
          @ nLin02+5,nCol01 SAY oSAYPesNGer PROMPT "Peso Não Gera Financeiro.:"+("KG "+ALLTRIM(TRANS(_nTotNaoGerFin,"@E 999,999,999,999.99"))) SIZE 199,009 OF oPnlTopTop PIXEL 
       nCol01+=(55+55)

          @ nLin02-5,nCol01 SAY oSAYToPon   PROMPT "Potencial Faturamento Geral: "               +("R$ "+ALLTRIM(TRANS( _nTotPonFat,"@E 999,999,999,999.99"))) SIZE 199,009 OF oPnlTopTop PIXEL 
          @ nLin02+5,nCol01 SAY oSAYRTotPon PROMPT "Potencial Faturamento "+ALLTRIM(cPastaR)+": "+("R$ "+ALLTRIM(TRANS( _nToRPonFat,"@E 999,999,999,999.99"))) SIZE 199,009 OF oPnlTopTop PIXEL 

       //FOLDER PRINCIPAL COM 3 PASTAS **************************************************************************
       _nColFolder:=aPosObj[2,4]//350
       _nLinFolder:=aPosObj[2,3]-10//100

       oTFolder01:= TFolder():New( nLin03,1,aFoders1,,oDlg2,,,,.T., , _nColFolder,_nLinFolder )
       oTFolder01:bChange    :={|| MOMS66Atu("P1") }	   

       oPastaTOP1:=oTFolder01:aDialogs[1] // "CARGAS FECHADAS TOP1  ********************** //
        
       oBrwTOP1:=MOMS66Brw(aHeaderP,_aPedTOP1,oPastaTOP1)

       oPastaCaFe:=oTFolder01:aDialogs[2]   // CARGAS FECHADAS *************************** //

       oBrwCaFe:=MOMS66Brw(aHeaderP,_aPedCAFE,oPastaCaFe)

       oPastaFORA:=oTFolder01:aDialogs[3]   // Pedidos Fora de Padrão *************************** //

       oBrwFORA:=MOMS66Brw(aHeaderP,_aPedFORA,oPastaFORA)
       
       IF LEN(aFoders1) > 3 
          oPastaCaRe := oTFolder01:aDialogs[4] // CARGAS POR REGIOES DO BRASIL ************** //
       ENDIF

       oPnlBoton:= TPanel():New( 1 , 0 , , oDlg2 , , , , , , 80 , 20 , .F. , .F. )   
       oPnlBoton:Align := CONTROL_ALIGN_BOTTOM
      
       _nRMesoPesoLib  :=0
       _nVMesoPesoLib  :=0
       _nRMesoPalsLib  :=0
       _nVMesoPalsLib  :=0
       _nRMesoValor    :=0
       _nVMesoValor    :=0
       _nRMesoNaoGerFin:=0
       _nMesoPonFat    :=0
       nMesoPonPeso    :=0
       _cRQtdeCarrega  :=" "
       nCol01:=2
          nLin01:=6
       lRegioes:=.F.//ATUALIZADO DENTRO DA MOMS66Obj ()
       cPastaR :="" //ATUALIZADO DENTRO DA MOMS66Obj ()

       @ nLin01-2, nCol01 BUTTON oBotValCar PROMPT "VALIDA CARGA"  SIZE 050, 012 OF oPnlBoton ACTION ( MOMS66VCarga() ) PIXEL 
       nCol01+=55
       
          @ nLin01-4,nCol01 SAY oSAYRPeso  PROMPT "A Liberar Marcado : "+("KG "+ALLTRIM(TRANS( _nRMesoPesoLib,"@E 999,999,999,999.999")))             SIZE 200,009 OF oPnlBoton PIXEL 
          @ nLin01+5,nCol01 SAY oSAYVPeso  PROMPT "A Liberar Sugerido: "+("KG "+ALLTRIM(TRANS( _nVMesoPesoLib,"@E 999,999,999,999.999")))             SIZE 200,009 OF oPnlBoton PIXEL 
       nCol01+=95        
          @ nLin01-4,nCol01 SAY oSAYRPale  PROMPT "Qtde Palete Marcado : "+(ALLTRIM(TRANS( _nRMesoPalsLib,"@E 999,999,999,999.99")))                  SIZE 200,009 OF oPnlBoton PIXEL 
          @ nLin01+5,nCol01 SAY oSAYVPale  PROMPT "Qtde Palete Sugerido: "+(ALLTRIM(TRANS( _nVMesoPalsLib,"@E 999,999,999,999.99")))                  SIZE 200,009 OF oPnlBoton PIXEL 
       nCol01+=95        
          @ nLin01-4,nCol01 SAY oSAYRVGerF PROMPT "Valor Gera Financeiro Marcado : "+(ALLTRIM(TRANS( _nRMesoValor,"@E 999,999,999,999.99")))          SIZE 200,009 OF oPnlBoton PIXEL 
          @ nLin01+5,nCol01 SAY oSAYVVGerF PROMPT "Valor Gera Financeiro Sugerido: "+(ALLTRIM(TRANS( _nVMesoValor,"@E 999,999,999,999.99")))          SIZE 200,009 OF oPnlBoton PIXEL 
       nCol01+=125
          @ nLin01-4,nCol01 SAY oSAYRPnGer PROMPT "Peso não Gera Financeiro Marcado: "+(ALLTRIM(TRANS( _nRMesoNaoGerFin ,"@E 999,999,999,999.999")))  SIZE 200,009 OF oPnlBoton PIXEL 
          @ nLin01+5,nCol01 SAY oSAYVPnGer PROMPT "Potencial Fat.: R$ "+ALLTRIM(TRANS(_nMesoPonFat,"@E 999,999,999,999.99"))+" - KG "+ALLTRIM(TRANS(nMesoPonPeso,"@E 999,999,999,999.099"))   SIZE 200,009 OF oPnlBoton PIXEL 
       nCol01+=136
          @ nLin01-4,nCol01 SAY oSAYNPastA PROMPT "Pasta Ativa "+Capital(MOMS66Obj(.T.)[1])                                                           SIZE 200,009 OF oPnlBoton PIXEL 
          @ nLin01+5,nCol01 SAY oSAYValCar PROMPT "Qtde Carrgamento: "+_cRQtdeCarrega                                                                 SIZE 200,009 OF oPnlBoton PIXEL 

       //FOLDER 4 DAS REGIOES DO BRASIL COM ATE 5 PASTAS **************************************************************************
       _nLinFolder:=(_nLinFolder-15)

       IF LEN(aFoders1) > 3 
          oPastaRegs:= TFolder():New( 0 , 1 ,aFolderRGBR,,oPastaCaRe,,,,.T., , _nColFolder,_nLinFolder )   
          oPastaRegs:Align:=CONTROL_ALIGN_ALLCLIENT
          oPastaRegs:bChange   :={|| MOMS66Atu("RB") }	
       ELSE
          oPastaRegs:=NIL   
       ENDIF

       _nLinFolder:=(_nLinFolder-85)

       IF LEN(aFoldReg1) > 0 // CARGAS POR MESO DA REGIAO 1 ************************** //
          oProc:cCaption := ("1/5 - Montando Pasta: "+aFolderRGBR[1] )
          ProcessMessages()
          oPastaR1  := oPastaRegs:aDialogs[1] 
          oPastMeso1:= TFolder():New( 1 , 1 ,aFoldReg1,,oPastaR1,,,,.T., , _nColFolder,_nLinFolder )   
          oPastMeso1:Align:=CONTROL_ALIGN_ALLCLIENT
          oPastMeso1:bChange   :={|| MOMS66Atu("R1") }	   
          FOR P := 1 TO LEN(aFoldReg1)
              oBrwMeso1:=MOMS66Brw(aHeaderP,aPedsReg1[P],oPastMeso1:aDialogs[P])
              oBrwMeso1:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
          NEXT
       ENDIF	  
       IF LEN(aFoldReg2) > 0 // CARGAS POR MESO DA REGIAO 2 ************************** //
          oProc:cCaption := ("2/5 - Montando Pasta: "+aFolderRGBR[2] )
          oPastaR2  := oPastaRegs:aDialogs[2] 
          oPastMeso2:= TFolder():New( 1 , 1 ,aFoldReg2,,oPastaR2,,,,.T., , _nColFolder,_nLinFolder )   
          oPastMeso2:Align:=CONTROL_ALIGN_ALLCLIENT
          oPastMeso2:bChange   :={|| MOMS66Atu("R2") }	   
          FOR P := 1 TO LEN(aFoldReg2)
              oBrwMeso2:=MOMS66Brw(aHeaderP,aPedsReg2[P],oPastMeso2:aDialogs[P])
              oBrwMeso2:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
          NEXT
       ENDIF	  
       IF LEN(aFoldReg3) > 0 // CARGAS POR MESO DA REGIAO 3 ************************** //
          oProc:cCaption := ("3/5 - Montando Pasta: "+aFolderRGBR[3] )
          oPastaR3  := oPastaRegs:aDialogs[3] 
          oPastMeso3:= TFolder():New( 1 , 1 ,aFoldReg3,,oPastaR3,,,,.T., , _nColFolder,_nLinFolder )   
          oPastMeso3:Align:=CONTROL_ALIGN_ALLCLIENT
          oPastMeso3:bChange   :={|| MOMS66Atu("R3") }	   
          FOR P := 1 TO LEN(aFoldReg3)
              oBrwMeso3:=MOMS66Brw(aHeaderP,aPedsReg3[P],oPastMeso3:aDialogs[P])
              oBrwMeso3:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
          NEXT
       ENDIF	  
       IF LEN(aFoldReg4) > 0 // CARGAS POR MESO DA REGIAO 4 ************************** //
          oProc:cCaption := ("4/5 - Montando Pasta: "+aFolderRGBR[4] )
          oPastaR4  := oPastaRegs:aDialogs[4] 
          oPastMeso4:= TFolder():New( 1 , 1 ,aFoldReg4,,oPastaR4,,,,.T., , _nColFolder,_nLinFolder )   
          oPastMeso4:Align:=CONTROL_ALIGN_ALLCLIENT
          oPastMeso4:bChange   :={|| MOMS66Atu("R4") }	   
          FOR P := 1 TO LEN(aFoldReg4)
              oBrwMeso4:=MOMS66Brw(aHeaderP,aPedsReg4[P],oPastMeso4:aDialogs[P])
              oBrwMeso4:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
          NEXT
       ENDIF	  
       IF LEN(aFoldReg5) > 0 // CARGAS POR MESO DA REGIAO 5 ************************** //
          oProc:cCaption := ("5/5 - Montando Pasta: "+aFolderRGBR[5] )
          oPastaR5  := oPastaRegs:aDialogs[5] 
          oPastMeso5:= TFolder():New( 1 , 1 ,aFoldReg5,,oPastaR5,,,,.T., , _nColFolder,_nLinFolder )   
          oPastMeso5:Align:=CONTROL_ALIGN_ALLCLIENT
          oPastMeso5:bChange   :={|| MOMS66Atu("R5") }	   
          FOR P := 1 TO LEN(aFoldReg5)
              oBrwMeso5:=MOMS66Brw(aHeaderP,aPedsReg5[P],oPastMeso5:aDialogs[P])
              oBrwMeso5:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
          NEXT
       ENDIF

       oDlg2:lMaximized:=.T.
       
       MOMS66Atu("INICIO")//PRIMEIRA CARGA DA TELA
          
      ACTIVATE MSDIALOG oDlg2 ON INIT (oPnlTopTop:Align:= CONTROL_ALIGN_TOP                          ,;// TELA PRINCIPAL
                                       oTFolder01:Align:= CONTROL_ALIGN_ALLCLIENT                    ,;// TELA PRINCIPAL
                                       oPnlBoton:Align := CONTROL_ALIGN_BOTTOM                       ,;// PAINEL DE TOTAIS SUGERIDOS 
                                       IF(oPastaRegs<>NIL,oPastaRegs:Align:=CONTROL_ALIGN_ALLCLIENT,),;// PASTA DAS 5 REGIOES DO BRASIL
                                       oBrwCaFe:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT               ,;// PASTA CARGAS FECHADAS
                                       oBrwFORA:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT               ,;// PASTA PEDIDOS FORA DE PADRÃO
                                          oBrwTOP1:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT                )// PASTA CARGAS FECHADAS TOP1
      IF _lReprocessar 
         
         FWMSGRUN( ,{|oProc| MOMS66Reproc(oProc) },"Reprocessando todos os Pedidos...","Aguarde...")

      ELSEIF _lGrava .OR. _lSimular

         FWMSGRUN( ,{|oProc| MOMS66Proc(oProc) },"Processando todos os Pedidos...","Aguarde...")
         RETURN "SAIR" 
   
      ELSEIF U_ITMSG("Confirma SAIR ?",'Atenção!',"Todas as alterações serão predidas!",3,2,2)
         
         EXIT
   
      ENDIF

   ENDDO

ENDIF

Return "LOOP"
/*
===============================================================================================================================
Programa--------: MOMS66Brw
Autor-----------: Alex Wallauer
Data da Criacao-: 14/03/2024
===============================================================================================================================
Descrição-------: Cria os blowses
===============================================================================================================================
Parametros------: aHeaderP,_aColsP,oPasta
===============================================================================================================================
Retorno---------: oMsMGet
===============================================================================================================================*/
Static Function MOMS66Brw(aHeaderP,_aColsP,oPasta)
LOCAL oMsMGet

IF LEN(_aColsP) > 0
   nGDAction:= GD_UPDATE
ELSE
   nGDAction:= GD_INSERT
ENDIF
/*------------------------------------------*\
| Estrutura do aHeader do MsNewGetDados      |
|--------------------------------------------|
| aHeader[01] - X3_TITULO  | Título          |
| aHeader[02] - X3_CAMPO   | Campo           |
| aHeader[03] - X3_PICTURE | Picture         |
| aHeader[04] - X3_TAMANHO | Tamanho         |
| aHeader[05] - X3_DECIMAL | Decimal         |
| aHeader[06] - X3_VALID   | Validação       |
| aHeader[07] - X3_USADO   | Usado           |
| aHeader[08] - X3_TIPO    | Tipo            |
| aHeader[09] - X3_F3      | F3              |
| aHeader[10] - X3_CONTEXT | Contexto (R,V)  |
| aHeader[11] - X3_CBOX    | Combobox        |
| aHeader[12] - X3_RELACAO | Inicial. Padrao |
| aHeader[13] - X3_WHEN    | Habilita edicao |
| aHeader[14] - X3_VISUAL  | Alteravel (A,V) |
| aHeader[15] - X3_VLDUSER | Valid de User   |
| aHeader[16] - X3_PICTVAR | Picture         |
| aHeader[17] - X3_OBRIGAT | Obrigatorio     |
\*------------------------------------------*/
                             //[ nTop]          , [ nLeft]   , [ nBottom] , [ nRight ] , [ nStyle],cLinhaOk,cTudoOk,cIniCpos, [ aAlter]                                              , [ nFreeze], [ nMax], [ cFieldOk], [ cSuperDel], [ cDelOk], [ oWnd], [ aPartHeader], [ aParCols], [ uChange], [ cTela], [ aColsSize] 
oMsMGet := MsNewGetDados():New((aPosObj[2,1]+12),aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nGDAction ,        ,       ,        ,{"MARCA","MARCA2","PO_OK","ESTOQUE","CAPACIDA","PEDIDO"},           ,        ,            ,             ,          ,oPasta  ,aHeaderP        , _aColsP   ,)
oMsMGet:SetEditLine(.F.)
oMsMGet:AddAction("MARCA"    ,{|| MOMS662CLIK() }) // LEGENDAS
oMsMGet:AddAction("MARCA2"   ,{|| MOMS662CLIK() }) // LEGENDAS
oMsMGet:AddAction("PO_OK"    ,{|| MOMS662CLIK() }) // LEGENDAS
oMsMGet:AddAction("ESTOQUE"  ,{|| MOMS662CLIK() }) // ITENS DOS PEDIDOS
oMsMGet:AddAction("CAPACIDA" ,{|| MOMS662CLIK() }) // LEGENDAS
oMsMGet:AddAction("PEDIDO"   ,{|| MOMS662CLIK() }) // VER PEDIDO
//bEdit := {|| If(nNext > 0,(oMsMGet:oBrowse:nAt := n := nNext,oMsMGet:oBrowse:Refresh()),) , oMsMGet:oBrowse:GoLeft() }
//oMsMGet:AddAction("PO_UP"    ,{|| nNext := U_M66Reorder(n,n-1,aColsP),oMsMGet:oBrowse:bEditCol := bEdit,"UP3"  })
//oMsMGet:AddAction("PO_DOWN"  ,{|| nNext := U_M66Reorder(n,n+1,aColsP),oMsMGet:oBrowse:bEditCol := bEdit,"DOWN3"})
//oMsMGet:oBrowse:bldblclick:=  {|| MOMS662CLIK() }
//oMsMGet:oBrowse:lUseDefaultColors := .F.
//oMsMGet:oBrowse:SetBlkBackColor({|| GETDCLR()})

//******************************************************************************************************************************//
                //MESOS         , BROWSE
AADD(aBrowses,{ oPasta:cCaption , oMsMGet })//GUARDA TODOS OS OBJETOS DE BROUSE DE TODAS AS PASTAS PARA BUSCA NA FUNÇÃO MOMS66Obj ().
//******************************************************************************************************************************//
RETURN oMsMGet
/*
===============================================================================================================================
Programa--------: MOMS662CLIK()
Autor-----------: Alex Wallauer
Data da Criacao-: 28/06/2022
===============================================================================================================================
Descrição-------: Opcoes do 2 clique nas linhas
===============================================================================================================================
Parametros------: NENHUM
===============================================================================================================================
Retorno---------: NENHUM
===============================================================================================================================*/
STATIC Function MOMS662CLIK()
LOCAL N := 1
LOCAL C := 1
PRIVATE _cRet:="BR_AZUL"

IF (oMsMGet:=MOMS66Obj()) = NIL 
   RETURN _cRet
ENDIF

IF oMsMGet <> NIL
   N:=oMsMGet:oBrowse:nAt
   C:=oMsMGet:oBrowse:nColPos
   aColsP:=oMsMGet:aCols
   _cRet:=aColsP[N,C]
ENDIF

IF C = nPosOK .OR. C = nPosOK2//PRIMEIRA COLUNA E SEGUNDA COLUNA

   IF !aColsP[N,nPosCar] $ LEGENDAS_ABCP 
      _cRet2:=aColsP[N,nPosOK2]//O QUE VALE PARA A MARECAÇÃO É A COLUNA 2
      IF _cRet2 = "LBNO" 
         _cRet2 = "LBOK"//NÃO POSSO MEXER NO _cRet ate validar pq devolvo ele no Retorno abaixo
      ELSE
         _cRet2 = "LBNO"//NÃO POSSO MEXER NO _cRet ate validar pq devolvo ele no Retorno abaixo
      ENDIF
      IF MOMS66Val(N,aColsP,_cRet2)
         _cRet:=_cRet2
         aColsP[N,nPosOK ]:=_cRet
         aColsP[N,nPosOK2]:=_cRet
         MOMS66Atu("MARCA",N,aColsP)
         oMsMGet:aCols:=aColsP
         _lEfetivar  := .F.//BLOQUEIA O BOTÃO GERAR
         lClicouMarca:= .T.//Ativa a atualização na troca de pasta
      ENDIF
   ENDIF

ELSEIF C = nPosCar//COLUNA CARGA
   MOMS66LEG(.F.)
ELSEIF C = _nPosEst//COLUNA ESTOQUE
   FWMSGRUN( ,{|| MOMS66Item("ITENS")},"Lendo Itens..","Aguarde...")
ELSEIF C = _nPosCap//COLUNA CAPACIDADE
   MOMS66LEG(.F.)
//ELSEIF C = _nPosOrdem//COLUNA Com. //NÃO FUNCIONA
   //MOMS66Pesq(oMsMGet)
ELSEIF C = _nPosPed//COLUNA PEDIDO//NÃO FUNCIONA
   FWMSGRUN( ,{|| MOMS66PPV("S")},"Lendo Pedido..","Aguarde...")
ENDIF

RETURN _cRet//RETORNA O CONTEUDO DELE MESMO 

/*
===============================================================================================================================
Programa--------: M66Valid()
Autor-----------: Alex Wallauer
Data da Criacao-: 28/06/2022
===============================================================================================================================
Descrição-------: Valida a ordem digitada
===============================================================================================================================
Parametros------: NENHUM
===============================================================================================================================
Retorno---------: .T. ou .F.
===============================================================================================================================*/
USER Function M66Valid()
Local lRet := .T.
LOCAL cCampo:=READVAR()

//IF (oMsMGet:=MOMS66Obj()) = NIL 
//   RETURN .F.
//ENDIF
IF cCampo = "M->B2_1_QLIBE"

     IF oMsMGetG <> NIL
        N:=oMsMGetG:nAt
        _aTabAux:=oMsMGetG:aCols
     ELSE
        RETURN .F.   
     ENDIF
     IF !POSITIVO(M->B2_1_QLIBE)
        RETURN .F.
     ENDIF

     //Carrega fator de conversão se existir
     _nfator := 1
     If SB1->(Dbseek(xfilial("SB1")+LEFT(_aTabAux[N][nPosProde],11)))
        If SB1->B1_CONV == 0
           If SB1->B1_I_QQUEI == 'S' .and. SB1->B1_I_FATCO > 0
              _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_I_FATCO,SB1->B1_I_FATCO)
           Endif
        Else
           _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_CONV,SB1->B1_CONV)
        Endif
     Endif

     M->B2_2_QLIBE:= (M->B2_1_QLIBE * _nfator)//PARA CALCULAR A SEGUNDA UNIDADE DE MEDIDA

     //IF _aTabAux[N][nPosPoder3] > 0 .AND. M->B2_2_QLIBE > _aTabAux[N][nPosPoder3]
     
        //U_ITMSG("Quantidade digitada em 2um ("+cValToChar(M->B2_2_QLIBE)+") maior que a saldo em poder de 3o. disponivel.",'Atenção!',,3) 
        //RETURN .F.

     IF M->B2_2_QLIBE > _aTabAux[N][nPosDispo]
     
        U_ITMSG("Quantidade digitada em 2M ("+cValToChar(M->B2_2_QLIBE)+") maior que o Saldo disponivel.",'Atenção!',,3) 
        RETURN .F.
     
     ENDIF 

     oMsMGetG:aCols[N][nPos2QLIBE]:= M->B2_2_QLIBE

ELSEIF cCampo = "M->B2_2_QLIBE"

     IF oMsMGetG <> NIL
        N:=oMsMGetG:nAt
        _aTabAux:=oMsMGetG:aCols
     ELSE
        RETURN .F.   
     ENDIF

     IF !POSITIVO(M->B2_2_QLIBE)
        RETURN .F.
     ENDIF

     //IF _aTabAux[N][nPosPoder3] > 0 .AND. M->B2_2_QLIBE > _aTabAux[N][nPosPoder3]
     
        //U_ITMSG("Quantidade digitada em 2um ("+cValToChar(M->B2_2_QLIBE)+") maior que a saldo em poder de 3o. disponivel.",'Atenção!',,3) 
        //RETURN .F.

     IF M->B2_2_QLIBE > _aTabAux[N][nPosDispo]
     
        U_ITMSG("Quantidade digitada em 2M ("+cValToChar(M->B2_2_QLIBE)+") maior que o Saldo disponivel.",'Atenção!',,3) 
        RETURN .F.
     
     ENDIF 

     //Carrega fator de conversão se existir
     _nfator := 1
     If SB1->(Dbseek(xfilial("SB1")+LEFT(_aTabAux[N][nPosProde],11)))
        If SB1->B1_CONV == 0
           If SB1->B1_I_QQUEI == 'S' .and. SB1->B1_I_FATCO > 0
              _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_I_FATCO,SB1->B1_I_FATCO)
           Endif
        Else
           _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_CONV,SB1->B1_CONV)
        Endif
     Endif

     M->B2_1_QLIBE:= (M->B2_2_QLIBE / _nfator)//PARA CALCULAR A PRIMEIRA UNIDADE DE MEDIDA

     oMsMGetG:aCols[N][nPosQLIBE]:= M->B2_1_QLIBE

ENDIF

//IF cCampo = "M->PO_ORDEMC"
//    If M->PO_ORDEMC > 0 .and. M->PO_ORDEMC <= Len(aColsP) .and. aColsP[M->PO_ORDEMC][nPosCar] <> "BR_ PRETO"
//    	If aColsP[n][_nPosORC] <> M->PO_ORDEMC
//		   N:=oMsMGet:oBrowse:nAt	
//           aColsP:=oMsMGet:aCols
//    	   oMsMGet:oBrowse:bEditCol := {|| U_M66Reorder(n,M->PO_ORDEMC,aColsP) ,oMsMGet:oBrowse:Refresh() , oMsMGet:oBrowse:GoLeft() }//o:Refresh(),o:GoLeft()}
//    	EndIf
//    EndIf
//ELSE
/*
IF cCampo = "M->ZPQ_PRODUT"

     IF o <> NIL
        N:=o:nAt
        C:=o:nColPos
        _aGerentes:=oMsMGetG:aCols
     ELSE
        RETURN .F.   
     ENDIF
     _aGerentes[N][1]:=LEFT(M->ZPQ_PRODUT,11)+"  "//+ 2 para digitar o Armazem manual
     _aGerentes[N][2]:=ALLTRIM(POSICIONE("SB1",1,xfilial("SB1")+LEFT(M->ZPQ_PRODUT,11),"B1_DESC"))
     IF LEN(ALLTRIM(M->ZPQ_PRODUT)) >= 13 //11+2
        _aGerentes[N][3]:=RIGHT(M->ZPQ_PRODUT,LEN(SC6->C6_LOCAL))	 
     ENDIF
     M->ZPQ_PRODUT:=_aGerentes[N][1]
     IF SB1->(EOF())
        U_ITMSG("Produto não cadastrado..",'Atenção!',,3) 
        RETURN .F.
     ENDIF

     IF (_nPos:=aScan(_aSB2, {|x| x[1] == _cFilPrc .AND. LEFT(x[2],11) == LEFT(M->ZPQ_PRODUT,11) .AND. x[7] = _aGerentes[N][3] })) > 0

        //Carrega fator de conversão se existir
        _nfator := 1
        If SB1->(Dbseek(xfilial("SB1")+LEFT(M->ZPQ_PRODUT,11)))
           If SB1->B1_CONV == 0
              If SB1->B1_I_QQUEI == 'S' .and. SB1->B1_I_FATCO > 0
                    _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_I_FATCO,SB1->B1_I_FATCO)
              Endif
           Else
              _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_CONV,SB1->B1_CONV)
           Endif
        Endif

        _aGerentes[N][4]:=(_aSB2[_nPos,11]*_nfator) //11-DISPONIVEL INICIAL - 2um
        _aGerentes[N][9]:=_aSB2[_nPos,11]           //11-DISPONIVEL INICIAL - 1um
     ELSE
        _aGerentes[N][4]:=0
        _aGerentes[N][9]:=0
     ENDIF

ELSEIF cCampo = "M->ZPQ_GERENT"

     IF o <> NIL
        N:=o:nAt
        _aGerentes:=oMsMGetG:aCols
     ELSE
        RETURN .F.   
     ENDIF
     _aGerentes[N][6]:=ALLTRIM(Posicione("SA3",1,xFilial("SA3")+M->ZPQ_GERENT,"A3_NOME"))
     IF SA3->(EOF())
        U_ITMSG("Gerente não cadastrado..",'Atenção!',,3) 
        RETURN .F.
     ENDIF

ELSEIF cCampo = "M->ZPQ_QATU"

     IF o <> NIL
        N:=o:nAt
        C:=o:nColPos
        _aGerentes:=oMsMGetG:aCols
     ELSE
        RETURN .F.   
     ENDIF
     IF !POSITIVO(M->ZPQ_QATU)
        RETURN .F.
     ENDIF
     IF M->ZPQ_QATU > _aGerentes[N][4]
        U_ITMSG("Quantidade digitada maior que a disponivel.",'Atenção!',,3) 
        RETURN .F.
     ELSE

        //Carrega fator de conversão se existir
        _nfator := 1
        If SB1->(Dbseek(xfilial("SB1")+LEFT(_aGerentes[N][1],11)))
           If SB1->B1_CONV == 0
              If SB1->B1_I_QQUEI == 'S' .and. SB1->B1_I_FATCO > 0
                    _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_I_FATCO,SB1->B1_I_FATCO)
              Endif
           Else
              _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_CONV,SB1->B1_CONV)
           Endif
        Endif
        _aGerentes[N][08]:=M->ZPQ_QATU          //"Saldo Ger 2um	"
        _aGerentes[N][10]:=(M->ZPQ_QATU/_nfator)//"Reserva 1um"
        _aGerentes[N][11]:=(M->ZPQ_QATU/_nfator)//"Saldo Ger 1um"
     ENDIF

ENDIF*/

Return lRet

/*
===============================================================================================================================
Programa--------: MOMS66Alt()
Autor-----------: Alex Wallauer
Data da Criacao-: 28/06/2022
===============================================================================================================================
Descrição-------: Desvincula um pedido de outro pedido vinculado / CORTA ITENS DE PEDIDOS
===============================================================================================================================
Parametros------: _lDesvincula
===============================================================================================================================
Retorno---------: NENHUM
===============================================================================================================================*/
STATIC FUNCTION MOMS66Alt(_lDesvincula)
LOCAL L , P
IF !MOMS66Acesso()
   RETURN .F.
ENDIF

IF (oMsMGet:=MOMS66Obj()) = NIL 
   RETURN .F.
ENDIF
aColsP:=oMsMGet:aCols
IF LEN(aColsP) = 0
   RETURN .F.
ENDIF
N:=oMsMGet:oBrowse:nAt	
IF VALTYPE(aColsP[N][_nPosRecnos]) <> "A"//LINHA EM BRANCO
   RETURN .F.
ENDIF

IF _lDesvincula//*************************************** TELA DO BOTÃO "Desvincula Pedidos" *************************************

   SC5->(DBSETORDER(1))
   If !EMPTY(aColsP[N,_nPosPedVin])
      
      If aColsP[n][_nPosRecnos][1] <> 0  .AND. U_ITMSG("Confirma DESVINCULAR os Pedidos : "+aColsP[N,_nPosPed]+" - "+aColsP[N,_nPosPedVin]+" ?",'Atenção!',,3,2,2)
          SC5->(DBGOTO( aColsP[n][_nPosRecnos][1] ))

          _cPedAtual:=SC5->C5_FILIAL+SC5->C5_NUM
          IF !SC5->(DBSEEK( _cPedAtual)) //PEDIDO QUE NÃO EXISTE MAIS NESSA FILIAL
               aColsP[n][nPosCar ]:= "BR_AMARELO"
             aColsP[n][_nPosObs]:= "Pedido não existe mais nessa filial: "+SC5->C5_FILIAL+" "+SC5->C5_NUM+". FAÇA O REPROCESSAMENTO."
             U_ITMSG("Pedido não existe mais nessa filial: "+SC5->C5_FILIAL+" "+SC5->C5_NUM,'Atenção!',"Faça o reprocessamento ou tente marca novamente esse pedido.",1)
             RETURN .F.
          ENDIF

          IF !EMPTY(SC5->C5_I_PEVIN)
             IF (nPos:=ASCAN(aColsP,{|aPed| aPed[_nPosPed] == SC5->C5_I_PEVIN } ) ) > 0 //PRIMEIRO BUSCA NA MESMA PASTA
                   aColsP[nPos][_nPosPedVin  ]:=" "
                IF aColsP[nPos][nPosCar   ] ="BR_CINZA"
                   aColsP[nPos][nPosCar   ]:="DISABLE"
                ENDIF
                aColsP[nPos][_nPosRecnos,4]:=.F.
             ELSE
                 IF (_nPos:=ASCAN(aPedVin,{|aPed| aPed[1] == SC5->C5_I_PEVIN } )) > 0   //Procura o pedido na lista geral de vinculados 
                    _aPedPasta:={}
                    IF aPedVin[_nPos,4] == aFoders1[1]                                  //"Cargas Fechadas TOP1"
                       _aPedPasta:=oBrwTOP1:aCols
                    ELSEIF aPedVin[_nPos,4] == aFoders1[2]                              //"Cargas Fechadas"
                       _aPedPasta:=oBrwCaFe:aCols
                    ELSEIF aPedVin[_nPos,4] == aFoders1[3]                              //PEDIDOS FORA DE PADRÃO
                       _aPedPasta:=oBrwFORA:aCols
                    ELSEIF (nPos:=ASCAN(aBrowses, {|B| B[1] == aPedVin[_nPos,5] } )) > 0//Cargas por Regioes do Brasil - Procura o nome da MESO
                       oMsMGet2:=aBrowses[nPos,2]
                       _aPedPasta:=oMsMGet2:aCols
                       ENDIF
                    IF !EMPTY(_aPedPasta) .AND. (nPos:=ASCAN(_aPedPasta,{|aPed| aPed[_nPosPed] == SC5->C5_I_PEVIN } ) ) > 0 //Procura o pedido vinculado na lista de pedidos da aba deles para limpar
                          _aPedPasta[nPos][_nPosPedVin]:=" "
                       IF _aPedPasta[nPos][nPosCar ] ="BR_CINZA"
                          _aPedPasta[nPos][nPosCar ]:="DISABLE"
                       ENDIF
                       _aPedPasta[nPos][_nPosRecnos,4 ]:=.F.
                       ENDIF
                 ENDIF
             ENDIF
                cPedVinc:=SC5->C5_FILIAL+SC5->C5_I_PEVIN
             IF SC5->(DBSEEK( cPedVinc )) 
                   SC5->(Reclock("SC5",.F.))
                   SC5->C5_I_PEVIN := " "
                   SC5->(Msunlock())     
               ELSE
                U_ITMSG("Pedido não existe mais nessa filial: "+SC5->C5_FILIAL+" "+SC5->C5_I_PEVIN,'Atenção!',"O campo de Pedido vinculado desse pedido será limpo.",3) 
               ENDIF
            SC5->(DBGOTO( aColsP[n][_nPosRecnos][1] ))
               SC5->(Reclock("SC5",.F.))
               SC5->C5_I_PEVIN        :=" "
               SC5->(Msunlock())
               aColsP[N,_nPosPedVin  ]:=" "
            IF aColsP[N][nPosCar  ] ="BR_CINZA"
               aColsP[N][nPosCar  ]:="DISABLE"
            ENDIF

            aColsP[N,_nPosRecnos,4]:=.F.
            U_ITMSG("Pedidos: "+aColsP[N,_nPosPed]+" - "+aColsP[N,_nPosPedVin]+" desvinculados COM SUCESSO.",'Atenção!',,2) 
               _lEfetivar  := .F.//BLOQUEIA O BOTÃO GERAR
            lClicouMarca:= .T.//Ativa a atualização na troca de pasta
          ENDIF
       ENDIF
   
   ELSE
      U_ITMSG("Esse pedido "+aColsP[N,_nPosPed]+" não possui pedido vinculado.",'Atenção!',"Posicione em uma linha que o pedido tenha um pedido vinculado para usar essa opção.",3) 
   ENDIF
   
   IF oMsMGet <> NIL
      oMsMGet:oBrowse:Refresh()
   ENDIF

ELSE//*************************************** TELA DO BOTAO "CORTAR PRODUTOS" *************************************

   IF !_lEfetivar//BLOQUEIA O BOTÃO GERAR
      U_ITMSG("Houve Alterações, clique em Reprocessar antes de Cortar os Produtos novamente.",'Atenção!',"",3)  
      RETURN .F.
   ENDIF

//*********************************** COLUNAS DE SELECAO DE PRODUTOS ***********************************
   aCab1:={}
   AADD(aCab1,"")          //01
   AADD(aCab1,"Codigo")    //02
   AADD(aCab1,"Descricao") //03
   AADD(aCab1,"Qtde 2a UM")//04
   AADD(aCab1,"2a UM")     //05

//*********************************** COLUNAS DE SELECAO DE PEDIDOS ***********************************
   aCab2:={}
   AADD(aCab2,"")          //01
   AADD(aCab2,"Filial")    //02
   AADD(aCab2,"Pedido")    //03
   AADD(aCab2,"Codigo")    //04
   AADD(aCab2,"Descricao") //05
   AADD(aCab2,"Qtde 2a UM")//06
   AADD(aCab2,"2a UM")
   AADD(aCab2,"Razao Social")
   AADD(aCab2,"Nome Fantasia")
   AADD(aCab2,"UF Do Cliente")
   AADD(aCab2,"Rede")
   AADD(aCab2,"Nome Rede")
   AADD(aCab2,"Nome Gerente")
   AADD(aCab2,"Nome Coord.")
   AADD(aCab2,"Preço Venda")
   AADD(aCab2,"Preço Net")
   AADD(aCab2,"Vlr Total")
   AADD(aCab2,"Ped. Cliente")
   AADD(aCab2,"RDC")
   AADD(aCab2,"Mesorregião")
   AADD(aCab2,"UF")
   AADD(aCab2,"Região do Brasil")
   AADD(aCab2,"Mensagens de Erro")
   _nColMen:=LEN(aCab2)
   AADD(aCab2,"Registro")
   _nColRec:=LEN(aCab2)

   cPictQ:=AVSX3('C6_QTDVEN',6)
   FOR L := 1 TO LEN(_aCortaItem)
       IF VALTYPE(_aCortaItem[L,4]) = "N"
          _aCortaItem[L,4] := TRANS( (_aCortaItem[L,4]) , cPictQ )
       ENDIF
   NEXT
   
   DO WHILE .T.

      _cTitulo:='SELECIONE 1 OU MAIS PRODUTOS PARA CORTAR'
                       //      ,_aCols     ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons )
      IF !U_ITListBox(_cTitulo,aCab1,_aCortaItem, .T.    , 2    ,    ,          ,       ,         ,     ,        , )
         EXIT
      ENDIF

      _lAtual:=U_ITMSG("Procurar o(s) produto(s) marcado(s) na somente Pasta Atual? ",'Atenção!',,2,2,3,,"ATUAL","TODAS")//OK

      cPictQ:=AVSX3('C6_QTDVEN',6)
      FOR L := 1 TO LEN(_aCortaPed)
          IF VALTYPE(_aCortaPed[L,6]) = "N"
             _aCortaPed[L,6] := TRANS( (_aCortaPed[L,6]) , cPictQ )
          ENDIF
      NEXT

      _aCortaSelPed:={}
      _aCortaPed:=ASORT( _aCortaPed, , , {|X,Y| X[4] < Y[4] } )//POR ITEM
      FOR L := 1 TO LEN(_aCortaItem)
          IF _aCortaItem[L,1]
              FOR P := 1 TO LEN(_aCortaPed)
                  IF _aCortaItem[L,2] == _aCortaPed[P,4] .AND. (!_lAtual .OR. ASCAN(aColsP, { |aPed| aPed[_nPosPed] == _aCortaPed[P,3] } ) <> 0 )
                     AADD(_aCortaSelPed,_aCortaPed[P])
                  ENDIF
              NEXT
          ENDIF
      NEXT
      IF LEN(_aCortaSelPed) > 0
         _aCortaSelPed:=ASORT( _aCortaSelPed, , , {|X,Y| X[2]+X[3] < Y[2]+Y[3] } )//POR FILIAL +PEDIDO
      ELSE
         U_ITMSG("Nenhum pedido encontrado com esse(s) produto(s) selecionado(s).",'Atenção!',"Selecione outro(s) produto(s).",2) 	      
         LOOP
      ENDIF

      _cTitulo:='SELECIONE 1 OU MAIS PEDIDOS PARA CORTAR'
                       //      ,_aCols     ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons )
      IF !U_ITListBox(_cTitulo,aCab2,_aCortaSelPed, .T.    , 2    ,        ,          ,        ,         ,     ,        , )
         LOOP
      ENDIF   

      _aCortaRes:={}
      FOR L := 1 TO LEN(_aCortaSelPed)
          IF _aCortaSelPed[L,1]	     //MARCADOS PARA CORTE
               AADD(_aCortaRes,_aCortaSelPed[L])
            ENDIF
      NEXT		 

      IF LEN(_aCortaRes) > 0
         _aCortaRes:=ASORT( _aCortaRes, , , {|X,Y| X[2]+X[3] < Y[2]+Y[3] } )//ORDEM DE FILIAL + PEDIDO
      ENDIF
      
      IF !MOMS66Motivo()
         LOOP
      ENDIF
      
      _aItensCorta:= {}
      _cSC6Chave:=""
      FOR L := 1 TO LEN(_aCortaRes)
          SC6->(DBGOTO(_aCortaRes[L, _nColRec ] ))
          If SC6->(Deleted())
             LOOP
          ENDIF
          IF !EMPTY(_cSC6Chave) .AND. _cSC6Chave <> SC6->C6_FILIAL+SC6->C6_NUM//QUEBRA POR PEDIDO
             FWMSGRUN( ,{|oProc| MOMS047QGR(_cSC6Chave,oProc,_aItensCorta) },"Processando!","Aguarde...") //ALTERA O PEDIDO MSEXECAUTO()
             SC6->(DBGOTO(_aCortaRes[L, _nColRec ] ))
             _aItensCorta:= {}
             _cSC6Chave:=SC6->C6_FILIAL+SC6->C6_NUM
          ELSEIF EMPTY(_cSC6Chave)
             _cSC6Chave:=SC6->C6_FILIAL+SC6->C6_NUM
          ENDIF
          // Grava o Array _aItensCorta com todos os itens de um pedidos de vendas para atualização da base de dados
          Aadd(_aItensCorta,{SC6->C6_FILIAL   ,;//01
                             SC6->C6_NUM      ,;//02
                             SC6->C6_ITEM     ,;//03
                             SC6->C6_PRODUTO  ,;//04
                             SC6->C6_LOCAL    ,;//05
                             SC6->C6_QTDVEN   ,;//06
                             "S"              ,;//07
                             SC6->C6_UNSVEN    ;//08
                             })
                      
          lTemItemPraAlterar:=.T.
      NEXT
      IF LEN(_aItensCorta) > 0//QUEBRA POR PEDIDO
         FWMSGRUN( ,{|oProc| MOMS047QGR(_cSC6Chave,oProc,_aItensCorta) },"Processando!","Aguarde...") //ALTERA O PEDIDO MSEXECAUTO()
      ENDIF

       IF lTemItemPraAlterar	
         IF LEN(_aCortaRes) = 0 
            FOR L := 1 TO LEN(_aCortaSelPed)
                IF _aCortaSelPed[L,1]	     
                   AADD(_aCortaRes,_aCortaSelPed[L])
                ENDIF
            NEXT		 
         ENDIF
      
         IF LEN(_aCortaRes) > 0 
            aBotoesM:={}
            AADD(aBotoesM,{"",{|| U_ITMsgLog(oLbxAux:aArray[oLbxAux:nAt][ _nColMen ], "MENSAGEM" )},"","MENSAGEM"} )
            _bDblClk:={|oLbxAux| U_ITMsgLog(oLbxAux:aArray[oLbxAux:nAt][ _nColMen ], "MENSAGEM" )}
            
            _cTitulo:='RESULTADO DOS CORTES'
                             //          ,_aCols     ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab ,bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk)
            IF !U_ITListBox(_cTitulo,aCab2,_aCortaRes, .T.    , 4    ,        ,          ,        ,         ,     ,        , aBotoesM  ,       ,_bDblClk,           ,          ,         ,       ,          )
               LOOP
            ENDIF 
        ELSE
            U_ITMSG("Nenhum PEDIDO SELECIONADO.",'Atenção!',"SELECIONE 1 OU MAIS PEDIDOS",2) 	      
            LOOP 	      
        ENDIF  

       ELSE
          U_ITMSG("Nenhum PEDIDO SELECIONADO.",'Atenção!',"SELECIONE 1 OU MAIS PEDIDOS",2) 	      
          LOOP
       ENDIF
       
       EXIT
   
   ENDDO

ENDIF

RETURN .T.

/*
===============================================================================================================================
Programa--------: MOMS66B2
Autor-----------: Alex Wallauer
Data da Criacao-: 28/06/2022
===============================================================================================================================
Descrição-------: Monta o array com os valores atuais da SB2
===============================================================================================================================
Parametros------: _aTelaPedidos,lZera
===============================================================================================================================
Retorno---------: NENHUM
===============================================================================================================================*/
STATIC FUNCTION MOMS66B2(_aTelaPedidos,lZera)
Local _nX := 0
Local _nY := 0
Local _lSomaPTer:= .F.

SB2->(DbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL
IF lZera
   _aSB2:= {}
ENDIF

FOR _nX := 1 TO Len(_aTelaPedidos)
    
    IF _aTelaPedidos[_nX,nPosCar]  $ LEGENDAS_ABCP
       LOOP
    ENDIF

    _aSC6_do_PV:=_aTelaPedidos[_nX][_nPosRecnos]

    FOR _nY := 1 TO Len(_aSC6_do_PV[2])
        SC6->(DbGoTo(_aSC6_do_PV[2][_nY,1]))
         If SC6->(Deleted())
            LOOP
         ENDIF

        IF SB2->(DbSeek(SC6->C6_FILIAL+SC6->C6_PRODUTO+SC6->C6_LOCAL)) .AND.;
           (aScan(_aSB2, {|x| x[1] == SB2->B2_FILIAL .AND. x[2] == SB2->B2_COD .AND. x[7] == SB2->B2_LOCAL})) = 0
        
               _lSomaPTer :=(SC6->C6_FILIAL $ _cFilTer .And. SC6->C6_LOCAL $ _cLocTer)
               
               IF MV_PAR09 = 1 .AND. SB2->(FIELDPOS("B2_I_QLIBE")) > 0  .AND. SB2->B2_I_QLIBE > 0 
                  _nSaldoDisp:=SB2->B2_I_QLIBE
               ELSE
                  _nSaldoDisp:=SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QEMP + IF(_lSomaPTer,SB2->B2_QNPT,0)
               ENDIF
               
               _nDispInicial:=_nSaldoDisp//DISPONIVEL INICIAL 1UM SEM ZERAR
               
               _nSaldoDisp:=IF( _nSaldoDisp < 0 , 0 , _nSaldoDisp )//ZEREI O SALDO NEGATIVO PARA NÃO DAR ERRO NOS CALDULOS DE PESO			   

                Aadd(_aSB2, {SB2->B2_FILIAL ,;              //01 - FILIAL
                             SB2->B2_COD    ,;              //02 - PRODUTO
                             SB2->B2_QATU   ,;              //03 - 1UM
                             SB2->B2_RESERVA,;              //04 - 1UM
                             SB2->B2_QEMP   ,;              //05 - 1UM
                             _nSaldoDisp    ,;              //06 - DISPONIVEL FINAL 1UM SÓ MAIOR OU IGUAL A ZERO
                             SB2->B2_LOCAL  ,;              //07 - ARMAZEM
                             IF(_lSomaPTer,SB2->B2_QNPT,0),;//08 - 1UM
                             0              ,;              //09 - Quantidade Carteira na 2ª UM (SOMTORIA BOLINHA VERDE)
                             0              ,;              //10 - Saldo na 2ª UM (DISPONIVEL - BOLINHA VERDE) CALCULADO
                             _nDispInicial  ,;              //11 - DISPONIVEL INICIAL 1UM
                             0              ,;              //12 - SOMATORIA DAS RESERVAS DOS GERENTES 1UM
                             _nSaldoDisp    })              //13 - POSICAO PARA SALVAR O SALDO ANTERIOR A SIMULACAO: INICIA IGUAL PQ NA SIMULACAO PODE TER ITENS NOVOS

                AADD(_aSB2Inic,  ACLONE( _aSB2[LEN(_aSB2)] )  )
        ENDIF
    
    NEXT _nY

NEXT _nX

//FOR _nX := 1 TO LEN(_aGerentes)
//	IF (_nPos:=aScan(_aSB2, {|x| x[01] == _cFilPrc .AND.;                        // 01-FILIAL
//                          LEFT(x[02],11) == LEFT(_aGerentes[_nX][1],11) .AND.; // 02-PRODUTO
//                               x[07] = _aGerentes[_nX][3] })) > 0              // 07-LOCAL 
//	   _aSB2[_nPos,12]+=_aGerentes[_nX][10]//RESERVA 1um GERENTES                // 12-SOMATORIA DAS RESERVAS DOS GERENTES 1UM
//	ENDIF
//NEXT

RETURN

/*
===============================================================================================================================
Programa--------: MOMS66PC
Autor-----------: Alex Wallauer
Data da Criacao-: 28/06/2022
===============================================================================================================================
Descrição-------: Processa os pedidos para gerar as justificativas
===============================================================================================================================
Parametros------: _aTelaPedidos - Array contendo os pedidos a ser processado ,cMarcados,lZera,lSimulacao,oProc
===============================================================================================================================
Retorno---------: NENHUM
===============================================================================================================================*/
Static Function MOMS66PC(_aTelaPedidos,cMarcados,lZera,lSimulacao,oProc,cPastaR)
Local _nX,_nY
Local _nPesoPedido  := 0
Local _nPedTotPalete:= 0
Local _aItensPed    := {}
Local _nVlrPGerFin  := 0
Local _nPesoNGerFin := 0
Local cPictP:=AVSX3('C6_VALOR',6)
DEFAULT lZera       :=.F.

_nTot :=Len(_aTelaPedidos)
IF _nTot = 0 .OR. VALTYPE(_aTelaPedidos[1][_nPosRecnos]) <> "A"//LINHA EM BRANCO
   RETURN _aTelaPedidos
ENDIF
_cTot :=ALLTRIM(STR(_nTot))

Private _nPos:= 0
IF lZera //INICIA O CONSUMO
   _nTotPesoLib    := 00 //PESO LIBERADO
   _nTotPalsLib    := 00 //PALETES LIBERADO
   _nTotGerFin     := 00 //ZERA AQUI DE NOVO POR CAUSA DO REPROCESSAMENTO
   _nTotNaoGerFin  := 00 //ZERA AQUI DE NOVO POR CAUSA DO REPROCESSAMENTO
   _nSEstPesoLib   := 00 //PESO LIBERADO SEM OLHA ESTOQUE 
   _nSEstPalsLib   := 00 //PALETES LIBERADO SEM OLHA ESTOQUE 
   _lSomaPontFat   := .T.//SE ZERA LIGA A SOMA DE NOVO PARA REFAZER _nSEstPalsLib
   _aCortaItem     := {} //BOTAO "CORTAR PRODUTOS" 
   _aCortaPed      := {} //BOTAO "CORTAR PRODUTOS" 
   _aPedXProdSE    := {} //BOTAO "PEDIDOS X PRODUTOS SEM ESTOQUE"
   AEVAL(_aTotPonFat,{|x| x[2] := 0})//VALORES GERAL E POR PASTA SEM OLHA ESTOQUE 
ELSEIF lSimulacao//REINICIA O CONSUMO 
   _aSB2:=MOMS66aSB2(_aSB2,"VOLTA")  //RESTAURA AQUI PQ O ESTOQUE DAS REGIOES NÃO CONSOME AINDA PQ É SIMULACAO 
   _nTotPesoLib    := _nBKPPesoLib     //RESTAURA AQUI PQ O ESTOQUE DAS REGIOES NÃO CONSOME AINDA PQ É SIMULACAO 
   _nTotPalsLib    := _nBKPPalsLib     //RESTAURA AQUI PQ O ESTOQUE DAS REGIOES NÃO CONSOME AINDA PQ É SIMULACAO 
   _nTotGerFin     := _nBKPGerFin      //RESTAURA AQUI PQ O ESTOQUE DAS REGIOES NÃO CONSOME AINDA PQ É SIMULACAO 
   _nTotNaoGerFin  := _nBKPNaoGerFin   //RESTAURA AQUI PQ O ESTOQUE DAS REGIOES NÃO CONSOME AINDA PQ É SIMULACAO 
ENDIF

//CARREGA OS DADOS DA SB2 PARA O PROCESSAMENTO //***************
IF !cMarcados == "D2" //NÃO RECARREGA QUANDO É TROCA DE PASTA
   MOMS66B2(_aTelaPedidos,lZera)
ENDIF
//CARREGA OS DADOS DA SB2 PARA O PROCESSAMENTO //***************

FOR _nX := 1 TO _nTot// LOOP NOS PEDIDOS
    _aTelaPedidos[_nX,_nPosRecnos,4]:=.F.//LIMPA A VERIFICACO POR CAUSA DO REPROCESSAMENTO
NEXT
nConta:=0
SB1->(DBSETORDER(1))
FOR _nX := 1 TO _nTot//Len(_aTelaPedidos)// LOOP NOS PEDIDOS

    IF oProc <> NIL
       nConta++
       oProc:cCaption := ("Processando: "+STRZERO(nConta,5) +" de "+ _cTot)
       ProcessMessages()
    ENDIF

    //LENDO OS MARCADOS 	
    IF cMarcados = "M" .AND. _aTelaPedidos[_nX,nPosOK2] = "LBNO"//LOOP NOS DESMARCADOS
       LOOP
    ENDIF
    
    //LENDO OS DESMARCADOS 	
    IF cMarcados = "D" .AND. _aTelaPedidos[_nX,nPosOK2] = "LBOK"//LOOP NOS MARCADOS
       LOOP
    ENDIF

    _aSC6_do_PV:=_aTelaPedidos[_nX][_nPosRecnos]
    SC5->(DbGoTo(_aSC6_do_PV[1]))

    _cPedAtual:=SC5->C5_FILIAL+SC5->C5_NUM
    IF !SC5->(DBSEEK( _cPedAtual)) //Pedido que não existe mais nessa filial
        _aTelaPedidos[_nX,nPosCar ] := "BR_AMARELO"
        _aTelaPedidos[_nX,_nPosObs] := "Pedido não existe mais nessa filial: "+SC5->C5_FILIAL+" "+SC5->C5_NUM+". FAÇA O REPROCESSAMENTO."
        LOOP	
    ENDIF
    
    // Pedidos para REAGENDAR/futuro/excluidos     OU  Ve se foi verificado já (QUANDO SÃO PEDIDOS VINCULADOS).
    IF _aTelaPedidos[_nX][nPosCar] $ LEGENDAS_ABCP .OR. _aTelaPedidos[_nX][_nPosRecnos,4]
       LOOP
    ENDIF
    
    _nPesoCapacFil :=_aSC6_do_PV[3]//_nCapacPes
    _nPaleCapacFil :=_aSC6_do_PV[5]//_nCapacPal
    _lTemEstoque   :=.T.
    _cProdSEst     :=""
    _nPesoPedido   := 0
    _nPedTotPalete := 0
    _nVlrPGerFin   := 0
    _nPesoNGerFin  := 0
    _aItensPed     := {}
    DEFAULT cPastaR:=_aTelaPedidos[_nX,_nPosRGBR]
    _aTelaPedidos[_nX,_nPosObs   ]:=""//LIMPA POR CAUSA DO REPROCESSAMENTO
    _aTelaPedidos[_nX,_nPosPesEst]:=0 //LIMPA POR CAUSA DO REPROCESSAMENTO

    FOR _nY := 1 TO Len(_aSC6_do_PV[2]) // LOOP NO ITENS DO PEDIDO
        
        SC6->(DbGoTo(_aSC6_do_PV[2][_nY,1]))
        If SC6->(Deleted())
           LOOP
        ENDIF
    
        //REALIZA O CONSUMO DA SB2 
        IF (_nPos:=aScan(_aSB2, {|x| x[1] == SC6->C6_FILIAL .AND. x[2] == SC6->C6_PRODUTO .AND. x[7] = SC6->C6_LOCAL })) > 0 				
            
           //IF (_nPosGer:=aScan(_aGerentes, {|x| LEFT(x[1],11) == LEFT(SC6->C6_PRODUTO ,11) .AND. x[3] == SC6->C6_LOCAL .AND. x[5] == SC5->C5_VEND3 })) > 0
           //    _nReservGer:=_aGerentes[_nPosGer,11]
           //ELSE
           //    _nReservGer:=0
           //ENDIF
            //            Disponivel      //- RESERVAS DOS GERENTES + RESERVA DO GERENTE DO PEDIDOS POSICINADO
            _nSaldoDisp:=_aSB2[_nPos][06] //- _aSB2[_nPos][12]    //+ _nReservGer

            _aSB2[_nPos][09] += SC6->C6_UNSVEN //Quantidade Carteira na 2ª UM - BOTÃO ITENS DO PEDIDO // SOMTORIA TODAS AS BOLINHAS

            IF _nSaldoDisp  >= SC6->C6_QTDVEN //.AND. (_nReservGer = 0 .OR. _nReservGer > SC6->C6_QTDVEN) // <<<<<<<<<<<<< CONSOME O ESOQUE  <<<<<<<<<<<<<<
               
               _aSB2[_nPos][06]-= SC6->C6_QTDVEN // SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QEMP // DISPONIVEL
               
                //IF _nPosGer > 0
                //   _aSB2[_nPos][12]       -= SC6->C6_QTDVEN // TIRA DA RESERV GERAL  1UM
                //   _aGerentes[_nPosGer,08]-= SC6->C6_UNSVEN // TIRA DA SALDO GERENTE 2UM 
                //   _aGerentes[_nPosGer,11]-= SC6->C6_QTDVEN // TIRA DA SALDO GERENTE 1UM 
                //ENDIF
               
               _aSC6_do_PV[2][_nY,2]:=.F. //Marca o item que não tem estoque
               AADD(_aItensPed,{SC6->( RECNO() ),SC6->C6_QTDVEN,SC5->( RECNO() ) , SC6->C6_UNSVEN })

                //BOTÃO: "VER / CORTAR Itens Pedido""
                _nQtdeATend := SC6->C6_QTDVEN
                _nQtdeFalta := 0
                _nPesoFalta := 0
            
            ELSE//NÃO TEM MAIS ESTOQUE 
                
                _aSC6_do_PV[2][_nY,2]:=.F. //Marca o item que não tem estoque
                _lTemEstoque:=.F.
                _cProdSEst+="[ "+ALLTRIM(SC6->C6_PRODUTO)+"/ Qtde "+ALLTRIM(TRANS(SC6->C6_QTDVEN,"@E 999,999,999,999.999")) +" > Saldo "+ALLTRIM(TRANS(_nSaldoDisp,"@E 999,999,999,999.999")) +" ]"
                
                //BOTÃO: "VER / CORTAR Itens Pedido""
                _nQtdeATend := _nSaldoDisp
                _nQtdeFalta := (SC6->C6_QTDVEN - _nSaldoDisp)
                _nPesoFalta := (SC6->C6_I_PTBRU / SC6->C6_QTDVEN)  * (SC6->C6_QTDVEN - _nSaldoDisp)

            
            ENDIF
            //Carrega fator de conversão se existir
            _nfator := 1
            If SB1->(Dbseek(xfilial("SB1")+SC6->C6_PRODUTO))
               If SB1->B1_CONV == 0
                  If SB1->B1_I_QQUEI == 'S' .and. SB1->B1_I_FATCO > 0
                     _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_I_FATCO,SB1->B1_I_FATCO)
                  Endif
               Else
                  _nfator := IIF(SB1->B1_TIPCONV=="D", 1/SB1->B1_CONV,SB1->B1_CONV)
               Endif
            Endif
            _aTelaPedidos[_nX,_nPosPesEst]+= _nPesoFalta

            //BOTÃO: "VER / CORTAR Itens Pedido""
            _aSC6_do_PV[2][_nY,3]:=(_nQtdeATend*_nfator)
            _aSC6_do_PV[2][_nY,4]:=(_nQtdeFalta*_nfator)//QTDE FALTANTE
            _aSC6_do_PV[2][_nY,5]:=_nPesoFalta

        ENDIF
         
    NEXT _nY

    _aTelaPedidos[_nX][_nPosRecnos]:=ACLONE(_aSC6_do_PV)///***************************************
    
    _lPalitizada  :=_aTelaPedidos[_nX][_nPosTPCA] = "1" //C5_I_TIPCA
    _nPedTotPalete:=_aTelaPedidos[_nX][_nPosPalete]//Qtde de Paletes do Pedido 	
    _nPesoPedido  :=SC5->C5_I_PESBR

//	SC6->(DbGoTo(_aSC6_do_PV[2][1,1]))//PRIMEIRO ITEM DO PEDIDO  PODE ESTA DELETADO
    SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))
    
    If SC5->C5_I_OPER = "42" .OR. Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC") = 'S' 
       _nVlrPGerFin+=_aTelaPedidos[_nX][_nPosTotPed]
    ELSE
       _nPesoNGerFin+=SC5->C5_I_PESBR
    ENDIF

    IF !EMPTY(_cProdSEst)
       _aTelaPedidos[_nX,_nPosObs]:="Prods. s/ Estoque: "+_cProdSEst
    ENDIF

    ///////////////////////////////////////////////   VINCULADOS  ///////////////////////////////////////////////////////////
    //VER SE TEM PEDIDO VINVCULADO TESTA AQUI JUNTO COM O OUTRO PEDIDO
    nPosVinc:=0
    IF (nPosVinc:=ASCAN(_aTelaPedidos,{|aPed| aPed[_nPosPed] == SC5->C5_I_PEVIN } ) ) > 0 ;//Procura o pedido vinculado NA _aTelaPedidos
                 .AND. !_aTelaPedidos[nPosVinc][_nPosRecnos,4]                            ;// Ve se não foi verificado ainda
                 .AND. !_aTelaPedidos[nPosVinc,nPosCar] $ LEGENDAS_ABCP                    ;// Ve se não é para agendar / Ve se não tá excluido / Depois de hoje
                 
       
       _aTelaPedidos[nPosVinc,_nPosRecnos,4]:=.T.//MARCA QUE EU JÁ VERIFIQUEI ESSE PEDIDO PARA CONTROLE DO VINCULADO
       _aTelaPedidos[nPosVinc][_nPosObs]    :="" //LIMPA POR CAUSA DO REPROCESSMENTO
       _aTelaPedidos[nPosVinc,_nPosPesEst]  := 0 //LIMPA POR CAUSA DO REPROCESSMENTO

       _cProdSEst:=""
       _aSC6_do_PV:=_aTelaPedidos[nPosVinc][_nPosRecnos]
       SC5->(DbGoTo(_aSC6_do_PV[1]))//PEDIDO VINCULADO
       
       FOR _nY := 1 TO Len(_aSC6_do_PV[2]) // LOOP NO ITENS DO PEDIDO VINCULADO
            
            SC6->(DbGoTo(_aSC6_do_PV[2][_nY,1]))
            If SC6->(Deleted())
               LOOP
            ENDIF
            //REALIZA O CONSUMO DA SB2 

            IF (_nPos:=aScan(_aSB2, {|x| x[1] == SC6->C6_FILIAL .AND. x[2] == SC6->C6_PRODUTO .AND. x[7] = SC6->C6_LOCAL })) > 0 				

            //IF (_nPosGer:=aScan(_aGerentes, {|x| LEFT(x[1],11) == LEFT(SC6->C6_PRODUTO ,11) .AND. x[3] == SC6->C6_LOCAL .AND. x[5] == SC5->C5_VEND3 })) > 0
            //    _nReservGer:=_aGerentes[_nPosGer,11]//1UM
            //ELSE
            //    _nReservGer:=0
            //ENDIF
                //            Disponivel      //- reservas dos gerentes + reserva do gerente do pedidos posicinado
                _nSaldoDisp:=_aSB2[_nPos][06] //- _aSB2[_nPos][12]    //+ _nReservGer

               _aSB2[_nPos][09] += SC6->C6_UNSVEN //Quantidade Carteira na 2ª UM - itens do pedido // SOMTORIA TODAS AS BOLINHAS

               IF _nSaldoDisp  >= SC6->C6_QTDVEN //.AND. (_nReservGer = 0 .OR. _nReservGer > SC6->C6_QTDVEN) // <<<<<<<<<<<<<<<<<<<<<<<<<<<
                  
                  _aSB2[_nPos][06]       -= SC6->C6_QTDVEN // SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QEMP // DISPONIVEL
                  //IF _nPosGer > 0
                  //   _aSB2[_nPos][12]       -= SC6->C6_QTDVEN // TIRA DA RESERVA GERAL 1UM
                  //   _aGerentes[_nPosGer,08]-= SC6->C6_UNSVEN // TIRA DA Saldo GERENTE 2um 
                  //   _aGerentes[_nPosGer,11]-= SC6->C6_QTDVEN // TIRA DA Saldo GERENTE 1um 
                  //ENDIF

                   AADD(_aItensPed,{SC6->( RECNO() ),SC6->C6_QTDVEN,SC5->( RECNO() ) , SC6->C6_UNSVEN })
                   _aSC6_do_PV[2][_nY,2]:=.T. //Marca o item que TEM ESTOQUE PARA Gravar ZY8 (MOMS66ZY8 ())

                   //BOTÃO: "VER / CORTAR Itens Pedido""
                   _nQtdeATend := SC6->C6_QTDVEN
                   _nQtdeFalta := 0
                   _nPesoFalta := 0

                ELSE
                    
                    _aSC6_do_PV[2][_nY,2]:=.F. //Marca o item que NAO TEM ESTOQUE PARA Gravar ZY8 (MOMS66ZY8 ())
                    _lTemEstoque:=.F.
                    _cProdSEst+="[ "+ALLTRIM(SC6->C6_PRODUTO)+"/ Qtde "+ALLTRIM(TRANS(SC6->C6_QTDVEN,"@E 999,999,999,999.999")) +" > Saldo "+ALLTRIM(TRANS(_nSaldoDisp,"@E 999,999,999,999.999")) +" (V) ]"
                    
                    //BOTÃO: "VER / CORTAR Itens Pedido""
                    _nQtdeATend := (_nSaldoDisp*_nfator)
                    _nQtdeFalta := ((SC6->C6_QTDVEN - _nSaldoDisp)*_nfator)
                    _nPesoFalta := (SC6->C6_I_PTBRU / SC6->C6_QTDVEN)  * (SC6->C6_QTDVEN - _nSaldoDisp)
               
                ENDIF
                
                //Carrega fator de conversão se existir
                _nfator := 1
                If SB1->(Dbseek(xfilial("SB1")+SC6->C6_PRODUTO))
                   If SB1->B1_CONV == 0
                      If SB1->B1_I_QQUEI == 'S' .and. SB1->B1_I_FATCO > 0
                         _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_I_FATCO,SB1->B1_I_FATCO)
                      Endif
                   Else
                      _nfator := IIF(SB1->B1_TIPCONV=="D", 1/SB1->B1_CONV,SB1->B1_CONV)
                   Endif
                Endif
                _aTelaPedidos[nPosVinc,_nPosPesEst]+= _nPesoFalta
            
                //BOTÃO: "VER / CORTAR Itens Pedido""
                _aSC6_do_PV[2][_nY,3]:=(_nQtdeATend*_nfator)
                _aSC6_do_PV[2][_nY,4]:=(_nQtdeFalta*_nfator)//QTDE FALTANTE
                _aSC6_do_PV[2][_nY,5]:=_nPesoFalta

            ENDIF
             
        NEXT _nY
        
        //IF _aTelaPedidos[nPosVinc][_nPosTPCA] = "1"//PALITIZADO
           _nPedTotPalete+=_aTelaPedidos[nPosVinc][_nPosPalete]
        //ELSE
           _nPesoPedido+=SC5->C5_I_PESBR
        //ENDIF

        //SC6->(DbGoTo(_aSC6_do_PV[2][1,1]))//PRIMEIRO ITEM DO PEDIDO VINCULADO
        SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))

        If SC5->C5_I_OPER = "42" .OR. Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC") = 'S' 
           _nVlrPGerFin+=_aTelaPedidos[nPosVinc][_nPosTotPed]
        ELSE   
           _nPesoNGerFin+=SC5->C5_I_PESBR
        ENDIF
        
        IF !EMPTY(_cProdSEst)
           _aTelaPedidos[nPosVinc,_nPosObs]:="Prods. s/ Estoque: "+_cProdSEst
        ENDIF
        _aTelaPedidos[nPosVinc][_nPosRecnos]:=ACLONE(_aSC6_do_PV)

    ENDIF
///////////////////////////////////////////////   VINCULADOS  ///////////////////////////////////////////////////////////

////////////////////////  ESTOQUE  ///////////////////////////////////
    IF _lTemEstoque 
       _aTelaPedidos[_nX,_nPosEst]:="ENABLE"//COLUNA ESTOQUE SIMULACAO 
       IF nPosVinc <> 0//Pedido Vinculdo se tiver
          _aTelaPedidos[nPosVinc,_nPosEst]:="ENABLE"//COLUNA ESTOQUE
       ENDIF
    ELSE
       _aTelaPedidos[_nX,_nPosEst]:="DISABLE"//COLUNA ESTOQUE SIMULACAO 
       IF nPosVinc <> 0//Pedido Vinculdo se tiver
          _aTelaPedidos[nPosVinc,_nPosEst]:="DISABLE"//COLUNA ESTOQUE
       ENDIF
    ENDIF
////////////////////////  ESTOQUE  ///////////////////////////////////

////////////////////////  CAPACIDADE  ///////////////////////////////////
    IF _lPalitizada//***********************************************  COM PALETE  **********************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************

       IF _lSomaPontFat
          _nSEstPalsLib+=_nPedTotPalete     // VALOR TOTAL LIBERADO SEM OLHA ESTOQUE 
          IF _nSEstPalsLib <= _nPaleCapacFil// LIIMITE DA CAPACIDADE DE PALETES DA FILIAL
               _aTotPonFat[1,2] += _nVlrPGerFin  // VALOR TOTAL LIBERADO SEM OLHA ESTOQUE 
             IF (nPos:=ASCAN(_aTotPonFat,{|P| P[1] == cPastaR})) > 0 
                 _aTotPonFat[nPos,2]+=_nVlrPGerFin
             ENDIF
          ENDIF
       ENDIF

       _nTotPalsLib +=_nPedTotPalete

       IF _nTotPalsLib <= _nPaleCapacFil//LIIMITE DA CAPACIDADE DE PALETES DA FILIAL
          _lTemCapacidade:=.T.
          _aTelaPedidos[_nX,_nPosCap]:="ENABLE"//COLUNA CAPACIDADE
          IF nPosVinc <> 0//Pedido Vinculdo se tiver
                _aTelaPedidos[_nX     ,_nPosObs]:="Pedido ("+_aTelaPedidos[_nX     ,_nPosPed]+"+"+_aTelaPedidos[_nX     ,_nPosPedVin]+") DENTRO da capacidade: "+ALLTRIM(TRANS((_nTotPalsLib-_nPedTotPalete),"@E 999,999,999.999"))+" + "+ALLTRIM(TRANS( _nPedTotPalete,"@E 999,999,999.999"))+" ) < "+ALLTRIM(TRANS( _nPaleCapacFil,"@E 999,999,999.999")+" Paletes ")+IF(!EMPTY(_aTelaPedidos[_nX     ,_nPosObs])," / "+_aTelaPedidos[_nX     ,_nPosObs],"")
             _aTelaPedidos[nPosVinc,_nPosObs]:="Pedido ("+_aTelaPedidos[nPosVinc,_nPosPed]+"+"+_aTelaPedidos[nPosVinc,_nPosPedVin]+") DENTRO da capacidade: "+ALLTRIM(TRANS((_nTotPalsLib-_nPedTotPalete),"@E 999,999,999.999"))+" + "+ALLTRIM(TRANS( _nPedTotPalete,"@E 999,999,999.999"))+" ) < "+ALLTRIM(TRANS( _nPaleCapacFil,"@E 999,999,999.999")+" Paletes ")+IF(!EMPTY(_aTelaPedidos[nPosVinc,_nPosObs])," / "+_aTelaPedidos[nPosVinc,_nPosObs],"")
             _aTelaPedidos[nPosVinc,_nPosCap]:="ENABLE"//COLUNA ESTOQUE
          ELSE
               _aTelaPedidos[_nX,_nPosObs]:="Pedido DENTRO da capacidade: "+ALLTRIM(TRANS((_nTotPalsLib-_nPedTotPalete),"@E 999,999,999.999"))+" + "+ALLTRIM(TRANS( _nPedTotPalete,"@E 999,999,999.999"))+" ) < "+ALLTRIM(TRANS( _nPaleCapacFil,"@E 999,999,999.999")+" Paletes ")+IF(!EMPTY(_aTelaPedidos[_nX,_nPosObs])," / "+_aTelaPedidos[_nX,_nPosObs],"")
          ENDIF   
       ELSE
          _lTemCapacidade:=.F.
          _aTelaPedidos[_nX,_nPosCap]:="DISABLE"//COLUNA SEM CAPACIDADE
          IF nPosVinc <> 0//Pedido Vinculdo se tiver
             _aTelaPedidos[_nX     ,_nPosObs]:="Pedido ("+_aTelaPedidos[_nX     ,_nPosPed]+"+"+_aTelaPedidos[_nX     ,_nPosPedVin]+") FORA da capacidade: ( "+ALLTRIM(TRANS((_nTotPalsLib-_nPedTotPalete),"@E 999,999,999.999"))+" + "+ALLTRIM(TRANS( _nPedTotPalete,"@E 999,999,999.999"))+" ) > "+ALLTRIM(TRANS( _nPaleCapacFil,"@E 999,999,999.999")+" Paletes ")+IF(!EMPTY(_aTelaPedidos[_nX     ,_nPosObs])," / "+_aTelaPedidos[_nX     ,_nPosObs],"")
             _aTelaPedidos[nPosVinc,_nPosObs]:="Pedido ("+_aTelaPedidos[nPosVinc,_nPosPed]+"+"+_aTelaPedidos[nPosVinc,_nPosPedVin]+") FORA da capacidade: ( "+ALLTRIM(TRANS((_nTotPalsLib-_nPedTotPalete),"@E 999,999,999.999"))+" + "+ALLTRIM(TRANS( _nPedTotPalete,"@E 999,999,999.999"))+" ) > "+ALLTRIM(TRANS( _nPaleCapacFil,"@E 999,999,999.999")+" Paletes ")+IF(!EMPTY(_aTelaPedidos[nPosVinc,_nPosObs])," / "+_aTelaPedidos[nPosVinc,_nPosObs],"")
             _aTelaPedidos[nPosVinc,_nPosCap]:="DISABLE"//COLUNA ESTOQUE
          ELSE
             _aTelaPedidos[_nX,_nPosObs]:="Pedido FORA da capacidade: ( "+ALLTRIM(TRANS((_nTotPalsLib-_nPedTotPalete),"@E 999,999,999.999"))+" + "+ALLTRIM(TRANS( _nPedTotPalete,"@E 999,999,999.999"))+" ) > "+ALLTRIM(TRANS( _nPaleCapacFil,"@E 999,999,999.999")+" Paletes ")+IF(!EMPTY(_aTelaPedidos[_nX,_nPosObs])," / "+_aTelaPedidos[_nX,_nPosObs],"")
          ENDIF
       ENDIF

    ELSE//***********************************************  SEM PALETE / POR PESO **********************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************

       IF _lSomaPontFat
          _nSEstPesoLib+=_nPesoPedido       // VALOR TOTAL LIBERADO SEM OLHA ESTOQUE 
          IF _nSEstPesoLib <= _nPesoCapacFil// LIIMITE DA CAPACIDADE DE PALETES DA FILIAL
               _aTotPonFat[1,2] += _nVlrPGerFin  // VALOR TOTAL LIBERADO SEM OLHA ESTOQUE 
             IF (nPos:=ASCAN(_aTotPonFat,{|P| P[1] == cPastaR })) > 0 
                 _aTotPonFat[nPos,2]+=_nVlrPGerFin
             ENDIF
          ENDIF
       ENDIF

       _nTotPesoLib +=_nPesoPedido

       IF _nTotPesoLib <= _nPesoCapacFil//LIIMITE DA CAPACIDADE DE PESO DA FILIAL
          _lTemCapacidade:=.T.
          _aTelaPedidos[_nX,_nPosCap]:="ENABLE"//COLUNA CAPACIDADE
          IF nPosVinc <> 0//Pedido Vinculdo se tiver
                _aTelaPedidos[_nX,_nPosObs]     :="Pedido ("+_aTelaPedidos[_nX     ,_nPosPed]+"+"+_aTelaPedidos[_nX     ,_nPosPedVin]+") DENTRO da capacidade: "+ALLTRIM(TRANS((_nTotPesoLib-_nPesoPedido),"@E 999,999,999.999"))+" + "+ALLTRIM(TRANS( _nPesoPedido,"@E 999,999,999.999"))+" ) < KG "+ALLTRIM(TRANS( _nPesoCapacFil,"@E 999,999,999.999"))+IF(!EMPTY(_aTelaPedidos[_nX     ,_nPosObs])," / "+_aTelaPedidos[_nX     ,_nPosObs],"")
             _aTelaPedidos[nPosVinc,_nPosObs]:="Pedido ("+_aTelaPedidos[nPosVinc,_nPosPed]+"+"+_aTelaPedidos[nPosVinc,_nPosPedVin]+") DENTRO da capacidade: "+ALLTRIM(TRANS((_nTotPesoLib-_nPesoPedido),"@E 999,999,999.999"))+" + "+ALLTRIM(TRANS( _nPesoPedido,"@E 999,999,999.999"))+" ) < KG "+ALLTRIM(TRANS( _nPesoCapacFil,"@E 999,999,999.999"))+IF(!EMPTY(_aTelaPedidos[nPosVinc,_nPosObs])," / "+_aTelaPedidos[nPosVinc,_nPosObs],"")
             _aTelaPedidos[nPosVinc,_nPosCap]:="ENABLE"//COLUNA CAPACIDADE
          ELSE
                 _aTelaPedidos[_nX,_nPosObs]:="Pedido DENTRO da capacidade: "+ALLTRIM(TRANS((_nTotPesoLib-_nPesoPedido),"@E 999,999,999.999"))+" + "+ALLTRIM(TRANS( _nPesoPedido,"@E 999,999,999.999"))+" ) < KG "+ALLTRIM(TRANS( _nPesoCapacFil,"@E 999,999,999.999"))+IF(!EMPTY(_aTelaPedidos[_nX,_nPosObs])," / "+_aTelaPedidos[_nX,_nPosObs],"")
          ENDIF
       ELSE
          _lTemCapacidade:=.F.
          _aTelaPedidos[_nX,_nPosCap]:="DISABLE"//COLUNA SEM CAPACIDADE
          IF nPosVinc <> 0//Pedido Vinculdo se tiver
             _aTelaPedidos[_nX     ,_nPosObs]:="Pedido ("+_aTelaPedidos[_nX     ,_nPosPed]+"+"+_aTelaPedidos[_nX     ,_nPosPedVin]+") FORA da capacidade: ( "+ALLTRIM(TRANS((_nTotPesoLib-_nPesoPedido),"@E 999,999,999.999"))+" + "+ALLTRIM(TRANS( _nPesoPedido,"@E 999,999,999.999"))+" ) > KG "+ALLTRIM(TRANS( _nPesoCapacFil,"@E 999,999,999.999"))+IF(!EMPTY(_aTelaPedidos[_nX     ,_nPosObs])," / "+_aTelaPedidos[_nX     ,_nPosObs],"")
             _aTelaPedidos[nPosVinc,_nPosObs]:="Pedido ("+_aTelaPedidos[nPosVinc,_nPosPed]+"+"+_aTelaPedidos[nPosVinc,_nPosPedVin]+") FORA da capacidade: ( "+ALLTRIM(TRANS((_nTotPesoLib-_nPesoPedido),"@E 999,999,999.999"))+" + "+ALLTRIM(TRANS( _nPesoPedido,"@E 999,999,999.999"))+" ) > KG "+ALLTRIM(TRANS( _nPesoCapacFil,"@E 999,999,999.999"))+IF(!EMPTY(_aTelaPedidos[nPosVinc,_nPosObs])," / "+_aTelaPedidos[nPosVinc,_nPosObs],"")
             _aTelaPedidos[nPosVinc,_nPosCap]:="DISABLE"//COLUNA CAPACIDADE
          ELSE
             _aTelaPedidos[_nX,_nPosObs]:="Pedido FORA da capacidade: ( "+ALLTRIM(TRANS((_nTotPesoLib-_nPesoPedido),"@E 999,999,999.999"))+" + "+ALLTRIM(TRANS( _nPesoPedido,"@E 999,999,999.999"))+" ) > KG "+ALLTRIM(TRANS( _nPesoCapacFil,"@E 999,999,999.999"))+IF(!EMPTY(_aTelaPedidos[_nX,_nPosObs])," / "+_aTelaPedidos[_nX,_nPosObs],"")
          ENDIF
       ENDIF

    ENDIF
////////////////////////  CAPACIDADE  ///////////////////////////////////

    IF !_lTemEstoque .OR. !_lTemCapacidade

        //ESTORNA RESERVA VIRTUAL DO PEDIDO TODO DO VINCULADO TB
        FOR _nY := 1 TO Len(_aItensPed)
            
            SC5->(DbGoTo( _aItensPed[_nY,3] ))
            SC6->(DbGoTo( _aItensPed[_nY,1] ))
            
            IF (_nPos:=aScan(_aSB2, {|x| x[1] == SC6->C6_FILIAL .AND. x[2] == SC6->C6_PRODUTO .AND. x[7] = SC6->C6_LOCAL })) > 0 				
                
                _aSB2[_nPos][06] += _aItensPed[_nY,2]//1um
                
                //IF (_nPosGer:=aScan(_aGerentes, {|x| LEFT(x[1],11) == LEFT(SC6->C6_PRODUTO ,11) .AND. x[3] == SC6->C6_LOCAL .AND. x[5] == SC5->C5_VEND3 })) > 0
                //    _aSB2[_nPos][12]       += SC6->C6_QTDVEN // SOMA NA RESERVA GERAL 1UM
                //    _aGerentes[_nPosGer,08]+= _aItensPed[_nY,4]//2um
                //    _aGerentes[_nPosGer,11]+= _aItensPed[_nY,2]//1um
                //ENDIF

            ENDIF
        NEXT

        IF _lPalitizada
           _nTotPalsLib -=_nPedTotPalete
        ELSE
           _nTotPesoLib -=_nPesoPedido
        ENDIF		    
        
        _aTelaPedidos[_nX][nPosCar]:="DISABLE"//COLUNA CARREGAMENTO
        IF nPosVinc <> 0//Pedido Vinculdo se tiver
           _aTelaPedidos[nPosVinc][nPosCar]:="DISABLE"//COLUNA CARREGAMENTO
        ENDIF
    ELSE
        _aTelaPedidos[_nX][nPosCar]:="ENABLE"//COLUNA CARREGAMENTO
        IF nPosVinc <> 0//Pedido Vinculdo se tiver
           _aTelaPedidos[nPosVinc][nPosCar]:="ENABLE"//COLUNA CARREGAMENTO
        ENDIF
    ENDIF

    IF _aTelaPedidos[_nX][nPosCar] = "ENABLE" //COLUNA CARREGAMENTO       
       _aTelaPedidos[_nX][nPosOK] := "LBOK"   //SIMULACAO DO USO SO ESTOQUE (_aSB2)
       IF !lSimulacao
          _aTelaPedidos[_nX][nPosOK2] :="LBOK"//USO DO ESTOQUE (_aSB2) REAL 
       ENDIF
       IF nPosVinc <> 0//Pedido Vinculdo se tiver
          _aTelaPedidos[nPosVinc][nPosOK] :="LBOK"   //SIMULACAO 
          IF !lSimulacao
             _aTelaPedidos[nPosVinc][nPosOK2]:="LBOK"//REAL 
          ENDIF
       ENDIF
       _nTotGerFin   +=_nVlrPGerFin //VALOR
       _nTotNaoGerFin+=_nPesoNGerFin//PESO	
    ELSE
       _aTelaPedidos[_nX][nPosOK ] :="LBNO"        // SIMULACAO DO USO SO ESTOQUE (_aSB2)
       _aTelaPedidos[_nX][nPosOK2] :="LBNO"        // USO DO ESTOQUE (_aSB2) REAL 
       IF nPosVinc <> 0                            // Pedido Vinculdo se tiver
          _aTelaPedidos[nPosVinc][nPosOK ]:="LBNO" // SIMULACAO 
          _aTelaPedidos[nPosVinc][nPosOK2]:="LBNO" // REAL 
       ENDIF
    ENDIF

    IF _aTelaPedidos[_nX,_nPosEst] = "DISABLE"//COLUNA ESTOQUE *** VAI PARA O BOTÃO DE CORTES DE PRODUTO ****
    
        _aSC6_do_PV:=_aTelaPedidos[_nX][_nPosRecnos]
        SC5->(DbGoTo(_aSC6_do_PV[1]))

        FOR _nY := 1 TO Len(_aSC6_do_PV[2]) // FOR NOS ITENS DOS PEDIDOS VERMELHO (_aTelaPedidos[_nX,_nPosEst] = "DISABLE")
            
            SC6->(DbGoTo(_aSC6_do_PV[2][_nY,1]))
            If SC6->(Deleted())
               LOOP
            ENDIF
//**********************************************************************************
            IF (_nPos:=aScan(_aCortaItem, {|x| x[2] == SC6->C6_PRODUTO  })) = 0
                _aItens:={}	    	
                AADD(_aItens,.F.)
                AADD(_aItens,SC6->C6_PRODUTO)
                AADD(_aItens,SC6->C6_DESCRI )
                AADD(_aItens,SC6->C6_UNSVEN )//C6_UNSVEN - A SOMATOTIA É DENTRO DO IF ABAIXO **
                AADD(_aItens,SC6->C6_SEGUM  )//C6_SEGUM
                
                AADD(_aCortaItem,_aItens)//TELA DE SELECAO DE PRODUTOS
            ENDIF
//**********************************************************************************
            IF (_nPos:=aScan(_aCortaPed, {|x| x[2] == SC6->C6_FILIAL .AND. x[3] == SC6->C6_NUM .AND. x[4] == SC6->C6_PRODUTO })) = 0 				
                _aItens:={}
                AADD(_aItens,.F.)            //01      
                AADD(_aItens,SC6->C6_FILIAL )//02                  
                AADD(_aItens,SC6->C6_NUM    )//03                  
                AADD(_aItens,SC6->C6_PRODUTO)//04
                AADD(_aItens,SC6->C6_DESCRI )//05
                AADD(_aItens,SC6->C6_UNSVEN )//C6_UNSVEN
                AADD(_aItens,SC6->C6_SEGUM  )//C6_SEGUM
                AADD(_aItens,SC5->C5_I_NOME )
                AADD(_aItens,SC5->C5_I_FANTA)
                AADD(_aItens,SC5->C5_I_EST  )
                AADD(_aItens,SC5->C5_I_GRPVE)
                AADD(_aItens,POSICIONE("ACY",1,XFILIAL("ACY")+SC5->C5_I_GRPVE,"ACY_DESCRI"))
                AADD(_aItens,SC5->C5_VEND3+"-"+Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND3,"A3_NOME"))
                AADD(_aItens,SC5->C5_VEND2+"-"+Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND2,"A3_NOME"))
                AADD(_aItens,TRANS(SC6->C6_PRCVEN , cPictP ))
                AADD(_aItens,TRANS(SC6->C6_I_PRNET, cPictP ))
                AADD(_aItens,TRANS(SC6->C6_VALOR  , cPictP ))
                AADD(_aItens,SC6->C6_PEDCLI)
                AADD(_aItens,SC5->C5_I_ENVRD)
                AADD(_aItens,_aTelaPedidos[_nX][_nPosMeso])
                AADD(_aItens,_aTelaPedidos[_nX][_nPosUF])
                AADD(_aItens,_aTelaPedidos[_nX][_nPosRGBR])
                AADD(_aItens,"" )    
                AADD(_aItens,SC6->(RECNO()) )
                
                AADD(_aCortaPed,_aItens)//TELA DE SELECAO DE PEDIDOS

                IF (_nPos:=aScan(_aCortaItem, {|x| x[2] == SC6->C6_PRODUTO  })) > 0 				
                   _aCortaItem[_nPos][4]  += SC6->C6_UNSVEN // SOMA AQUI PARA NÃO DUPLICAR A QUANTIDADE DO PRODUTO **
                ENDIF

            ENDIF
//*************************************************************************
            IF (_nPos:=aScan(_aPedXProdSE, {|x| x[1] == SC6->C6_FILIAL .AND. x[2] == SC6->C6_NUM .AND. x[8] == SC6->C6_PRODUTO })) = 0 				
               _cSemEstoque:="SIM"
               IF _aSC6_do_PV[2][_nY,4] = 0// QTDE FALTANTE
                  //_cSemEstoque:="NAO"
                  LOOP // NÃO POE O ITEM NA LISTA 
               ENDIF
               _aItens:={}
               AADD(_aItens,SC6->C6_FILIAL)         //01
               AADD(_aItens,SC6->C6_NUM   )         //02
               AADD(_aItens,SC5->C5_I_NOME)//Cliente//03
               AADD(_aItens,Posicione("SA1",1,xfilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ,"A1_GRPVEN"))//Rede  //04
               AADD(_aItens,SC5->C5_VEND3+"-"+Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND3,"A3_NOME"))//Gerente      //05
               AADD(_aItens,SC5->C5_VEND2+"-"+Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND2,"A3_NOME"))//Coordenador  //06
               AADD(_aItens,SC5->C5_I_EST  )        //07
               AADD(_aItens,SC6->C6_PRODUTO)        //08
               AADD(_aItens,SC6->C6_DESCRI )        //09
               AADD(_aItens,SC6->C6_LOCAL  )//Local //10
               AADD(_aItens,SC6->C6_UNSVEN )//Quantidade Carteira na 2ª UM //11
               AADD(_aItens,SC6->C6_SEGUM  )//2ª UM //12
               AADD(_aItens,"")//Qtde Carteira 2a UM//13
               AADD(_aItens,"")//Qtde Disponivel 2a UM  Inicial //14
               AADD(_aItens,_cSemEstoque)//Sem Estoque ? //15
               
               AADD(_aPedXProdSE,_aItens)//TELA DO BOTAO "PEDIDOS X PRODUTOS SEM ESTOQUE"
            ENDIF
//*************************************************************************
            
        NEXT _nY
    ENDIF
    
NEXT _nX
///////////////////////////////////////////////   VINCULADOS

Return _aTelaPedidos

/*
===============================================================================================================================
Programa--------: MOMS66SEC
Autor-----------: Alex Wallauer
Data da Criacao-: 28/06/2022
===============================================================================================================================
Descrição-------: Retorna sequencia da ZY3 
===============================================================================================================================
Parametros------: NENHUM
===============================================================================================================================
Retorno---------: _cSec: proxima sequencia
===============================================================================================================================*/
STATIC FUNCTION MOMS66SEC()
Local _cSec := "0001" 
ZY3->(DbSetOrder(1)) // ZY3_FILIAL+ZY3_NUMPV+ZY3_SEQUEN 
IF ZY3->(DbSeek( xFilial("ZY3")+SC5->C5_NUM ))
    WHILE ZY3->(!EOF()) .AND. ZY3->ZY3_NUMPV == SC5->C5_NUM .AND. ZY3->ZY3_FILIAL = xFilial("ZY3")
        IF ZY3->ZY3_SEQUEN >= _cSec
            _cSec := StrZero(VAL(ZY3->ZY3_SEQUEN)+1,4)
        ENDIF
        ZY3->(DBSKIP())
    ENDDO
ENDIF
RETURN _cSec


/*
===============================================================================================================================
Função------------: MOMS66KG
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2022
===============================================================================================================================
Descrição---------:  Retorna peso bruto da quantidade informada.
===============================================================================================================================
Parametros--------: _cProd,_nQtde,_nPesoBruto
===============================================================================================================================
Retorno-----------: _nPeso
===============================================================================================================================
*/
STATIC FUNCTION MOMS66KG(_cProd,_nQtde,_nPesoBruto)
Local _nPeso := 0
IF SB1->(DbSeek(xFilial("SB1")+_cProd))
   If SB1->B1_I_PCCX > 0 .And. _nPesoBruto <> 0 // Peso Variável
      _nPeso := _nPesoBruto
   ELSE
      _nPeso := _nQtde * SB1->B1_PESBRU
   ENDIF
ENDIF
RETURN _nPeso

/*
===============================================================================================================================
Programa--------: M66Reorder
Autor-----------: Alex Wallauer
Data da Criacao-: 28/06/2022
===============================================================================================================================
Descrição-------: Reordena a coluna Prioridade Comercial
===============================================================================================================================
Parametros------: nAt,nNext,aArray
===============================================================================================================================
Retorno---------: nNext
===============================================================================================================================
USER Function M66Reorder(nAt,nNext,aArray)
Local ni
Local nSkip
Local nPos
Local nDiff := 1
Local nLen
Local bWhile

nLen := Len(aArray)

If nNext > 0 .and. nNext <= nLen .and. nAt <> nNext
    If nAt < nNext
        nSkip := -1
        ni := nPos := nAt+1
        bWhile := {|| ni <= nLen .and. ni <= nNext}
    Else
        nSkip := 1
        ni := nPos := nAt-1
        bWhile := {|| ni > 0 .and. ni >= nNext}
    EndIf
    
    DO While Eval(bWhile)
        If aArray[ni][nPosCar] $ LEGENDAS_ABCP//== "BR_ PRETO"
            nDiff++
            If ni == nNext
                nNext += nSkip*(-1)
            EndIf
        Else
            nPos := ni+(nSkip*nDiff)
            aArray[ni][_nPosORC] := nPos
            nDiff := 1
        EndIf
        ni += nSkip*(-1)
    End
    
    If nNext > 0 .and. nNext <= nLen
        aArray[nAt][_nPosORC] := nNext
        aArray := Asort(aArray,,,{|x,y| x[_nPosORC] < y[_nPosORC]})
    Else
        nNext := 0
    EndIf
Else
    nNext := 0
EndIf

_lEfetivar  := .F.//BLOQUEIA O BOTÃO GERAR
lClicouMarca:= .T.//Ativa a atualização na troca de pasta

oMsMGet:aCols:=aArray

Return nNext*/


/*===============================================================================================================================
Programa----------: MOMS66Proc
Autor-------------: Alex Wallauer
Data da Criacao---: 03/05/2024
===============================================================================================================================
Descrição---------: LIERACAO DOS PEDIDOS
===============================================================================================================================
Parametros--------: oProc
===============================================================================================================================
Retorno-----------: NENHUM
===============================================================================================================================*/
Static Function MOMS66Proc(oProc)
LOCAL P , B

_lGravaLOG  :=.T.//COLOCAR PARAMENTRO (ZP1) AQUI CASO NÃO PRECISE GRAVAR O LOG 
_aColsTGrv  :={} //GRAVA NA FUNCAO MOMS66Grv () PARA MOSTRA NA TELA DEPOIS NA FUNCAO MOMS66TGrv ()
nLiberados  := 0 //GRAVA NA FUNCAO MOMS66Grv () PARA MOSTRA NA TELA DEPOIS NA FUNCAO MOMS66TGrv ()
_nTotPesoLib:= 0 //GRAVA NA FUNCAO MOMS66Grv () PARA MOSTRA NA TELA DEPOIS NA FUNCAO MOMS66TGrv ()
_nTotPalsLib:= 0 //GRAVA NA FUNCAO MOMS66Grv () PARA MOSTRA NA TELA DEPOIS NA FUNCAO MOMS66TGrv ()

Private _cTime:=TIME()//UM HORARIO SÓ PARA TODOS 
Private _cVinc:=Dtos(_dHoje)+substr(_cTime,1,5)
oProc:cCaption:="Liberando Pedidos Cargas TOP1..."
ProcessMessages()
_cPasta:="1-"+aFoders1[1]+" "
_aPedTOP1:=oBrwTOP1:aCols
BEGIN TRANSACTION
MOMS66Grv(_aPedTOP1,oProc,.F.,_cPasta)
END TRANSACTION

oProc:cCaption:="Liberando Pedidos Cargas Fechadas..."
ProcessMessages()
_cPasta:="2-"+aFoders1[2]+" "
_aPedCAFE:=oBrwCaFe:aCols
BEGIN TRANSACTION
MOMS66Grv(_aPedCAFE,oProc,.F.,_cPasta)
END TRANSACTION

oProc:cCaption:="Liberando Pedidos Fora de Padrão..."
ProcessMessages()
_cPasta:="3-"+aFoders1[3]+" "
_aPedFORA:=oBrwFORA:aCols
BEGIN TRANSACTION
MOMS66Grv(_aPedFORA,oProc,.F.,_cPasta)
END TRANSACTION

_cPasta:="4-"
FOR P := 1 TO LEN(aPedsReg1) 
     IF (nPos:=ASCAN(aBrowses, {|B| B[1] == aFoldReg1[P] } )) > 0
       oMsMGet:=aBrowses[nPos,2]
       _aPedPasta:=oMsMGet:aCols
       oProc:cCaption:="Liberando Pedidos "+aFoldReg1[P]
       ProcessMessages()
       MOMS66PreGrv(_aPedPasta,oProc,_cPasta)
     Endif
NEXT
FOR P := 1 TO LEN(aPedsReg2) 
     IF (nPos:=ASCAN(aBrowses, {|B| B[1] == aFoldReg2[P] } )) > 0
       oMsMGet:=aBrowses[nPos,2]
       _aPedPasta:=oMsMGet:aCols
       oProc:cCaption:="Liberando Pedidos "+aFoldReg2[P]
       ProcessMessages()
       MOMS66PreGrv(_aPedPasta,oProc,_cPasta)
     ENDIF
NEXT
FOR P := 1 TO LEN(aPedsReg3) 
     IF (nPos:=ASCAN(aBrowses, {|B| B[1] == aFoldReg3[P] } )) > 0
       oMsMGet:=aBrowses[nPos,2]
       _aPedPasta:=oMsMGet:aCols
       oProc:cCaption:="Liberando Pedidos "+aFoldReg3[P]
       ProcessMessages()
       MOMS66PreGrv(_aPedPasta,oProc,_cPasta)
     ENDIF
NEXT
FOR P := 1 TO LEN(aPedsReg4) 
     IF (nPos:=ASCAN(aBrowses, {|B| B[1] == aFoldReg4[P] } )) > 0
       oMsMGet:=aBrowses[nPos,2]
       _aPedPasta:=oMsMGet:aCols
       oProc:cCaption:="Liberando Pedidos "+aFoldReg4[P]
       ProcessMessages()
       MOMS66PreGrv(_aPedPasta,oProc,_cPasta)
     ENDIF
NEXT
FOR P := 1 TO LEN(aPedsReg5) 
     IF (nPos:=ASCAN(aBrowses, {|B| B[1] == aFoldReg5[P] } )) > 0
       oMsMGet:=aBrowses[nPos,2]
       _aPedPasta:=oMsMGet:aCols
       oProc:cCaption:="Liberando Pedidos "+aFoldReg5[P]
       ProcessMessages()
       MOMS66PreGrv(_aPedPasta,oProc,_cPasta)
    ENDIF
NEXT

RETURN  MOMS66TGrv(_aColsTGrv,oProc)//TELA DE LOG DE TODAS AS GRAVAÇÕES DE TODAS AS PASTAS

/*===============================================================================================================================
Programa----------: MOMS66Grv
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2022
===============================================================================================================================
Descrição---------: LIERACAO DOS PEDIDOS
===============================================================================================================================
Parametros--------: _aTelaPedidos,oProc,lTemColCarga,_cPasta
===============================================================================================================================
Retorno-----------: NENHUM
===============================================================================================================================*/
Static Function MOMS66Grv(_aTelaPedidos,oProc,lTemColCarga,_cPasta,_cC5Agrupamento)
LOCAL _nX , P
LOCAL nConta:=0
LOCAL _nTot :=Len(_aTelaPedidos)
LOCAL _cTot :=ALLTRIM(STR(_nTot))
DEFAULT lTemColCarga := .T.//PASTAS COM A COLUNA DA CARGA VALIDADA NAS MESORREGIÕES
DEFAULT _cC5Agrupamento:=""

IF _nTot = 0 .OR. VALTYPE(_aTelaPedidos[1][_nPosRecnos]) <> "A"//LINHA EM BRANCO
   RETURN .F.
ENDIF
_lDisarmou:=.F.
SC5->(DBSETORDER(1))
FOR _nX := 1 TO _nTot// LOOP NOS PEDIDOS
        
    IF oProc <> NIL
       nConta++
       oProc:cCaption := ("Processando: "+STRZERO(nConta,5) +" de "+ _cTot+" - Liberados: "+CValToChar(nLiberados))
       ProcessMessages()
    ENDIF

    IF _aTelaPedidos[_nX,nPosCar] = "BR_BRANCO" 
       LOOP
    ENDIF

    _aSC6_Produtos:=_aTelaPedidos[_nX][_nPosRecnos][2]
    SC5->(DbGoTo(_aTelaPedidos[_nX][_nPosRecnos][1]))
    
    _cPedAtual:=SC5->C5_FILIAL+SC5->C5_NUM

    IF !SC5->(DBSEEK( _cPedAtual)) 
        _aTelaPedidos[_nX,nPosCar ]:= "BR_AMARELO"//REJEITADO
        _aTelaPedidos[_nX,_nPosObs]:= "Pedido não existe mais nessa filial: "+SC5->C5_FILIAL+" "+SC5->C5_NUM
        LOOP
    ENDIF

    IF EMPTY(_aTelaPedidos[_nX,_nPosObs])
       _aTelaPedidos[_nX,_nPosObs]:= "Pedido não PROCESSADO"
    ENDIF

    IF _aTelaPedidos[_nX,nPosCar] = "BR_PRETO/BR_CINZA" .AND. SC5->C5_I_AGEND $ "M,A" .AND. SC5->C5_TPFRETE <> "F"  .AND. SC5->C5_I_OPER <> "20" .AND. _aTelaPedidos[_nX,_nPosNes] < _dHoje

       IF _lSimular
          _aTelaPedidos[_nX,_nPosObs] := "Pedido seria alterado para Reagendamento. Qtd reagend. Atual: "+CValToChar(SC5->C5_I_QTDA)
          LOOP
       ENDIF
   
       BEGIN TRANSACTION
          //Alterar o tipo para R- Reagendar ou  N- Reagendar com Multa // Somar mais um no Contador do Reagendamento da SC5 
          //(Campo novo: C5_I_QTDA – Quantidade de Reagendamento) // E não mostrar na lista de pedidos pendentes mandar para Logística  
          SC5->(RECLOCK("SC5",.F.))
          IF SC5->C5_I_AGEND = "M"//Agendado com Multa
             SC5->C5_I_AGEND:= "N"//Reagendar com Multa
                //SC5->C5_I_QTDA := SC5-> C5_I_QTDA+1
          ELSEIF SC5->C5_I_AGEND = "A"//Agendado
             SC5->C5_I_AGEND:= "R"    //Reagendar
                //SC5->C5_I_QTDA := SC5-> C5_I_QTDA+1
          ENDIF
          SC5->(MSUNLOCK())
          _aTelaPedidos[_nX,_nPosObs] := "Pedido FOI alterado para Reagendamento. Qtd reagend.: "+CValToChar(SC5->C5_I_QTDA)
   
          MOMS66ZY3("006", _dHoje, _cTime,_cVinc,_aTelaPedidos,_nX) //REAGENDAR
       END TRANSACTION
       
       LOOP/// LOOP **************************** DOS PRETOS

    ENDIF

//  BEGIN TRANSACTION
    BEGIN SEQUENCE

       //PASTAS 1,2,3 OU PASTAS DAS MESORREGIÕES COM CARGA VALIDADA
       IF _aTelaPedidos[_nX,nPosCar]        == "ENABLE" .AND.;//CARREGAR SIM 
          _aTelaPedidos[_nX][nPosOK2]       == "LBOK"   .AND.;//MARCADO REAL
          (!lTemColCarga       .OR. !EMPTY(_aTelaPedidos[_nX][nPosC1]) )
          //MARCADO PASTAS 1,2,3  OU  MARCADO COM CARGA VALIDADA NAS MESOS

          IF _lSimular
             _aTelaPedidos[_nX,_nPosObs] := "1-Pedido Talvez seria LIBERADO"
             IF _aTelaPedidos[_nX][_nPosTPCA] = "1"//PALITIZADO
                _nTotPalsLib+=_aTelaPedidos[_nX][_nPosPalete]
             ELSE
                _nTotPesoLib+=SC5->C5_I_PESBR
             ENDIF
             BREAK
          ENDIF

          IF lTemColCarga .AND. _lDisarmou
             _aTelaPedidos[_nX,_nPosObs] := "2-Pedido não liberado pq a carga dele teve um pedido que não foi liberar."
             BREAK
          ENDIF

          _cLogErro:=""//Preenchido na funcao Ver_Lib_PV ()
          IF Ver_Lib_PV(SC5->C5_FILIAL+SC5->C5_NUM)//LIBERA O PEDIDO SEM ALTERACOES 
             _SeqZY3 := MOMS66ZY3("025", _dHoje, _cTime,_cVinc,_aTelaPedidos,_nX) //ESTOQUE LIBERADO
                SC5->(RECLOCK("SC5",.F.))
             SC5->C5_I_STATU:= U_STPEDIDO() //Função de análise do pedido de vendas
             SC5->C5_I_BLOG := "S"
             IF SC5->(FIELDPOS("C5_I_AGRUP")) > 0
                SC5->C5_I_AGRUP:=_cC5Agrupamento
             ENDIF
             IF !_lAmbTeste
                SC5->C5_I_LILO := DATE()
             ELSE
                SC5->C5_I_LILO := _dHoje
             ENDIF

                SC5->(MSUNLOCK())

             _aTelaPedidos[_nX,_nPosObs] := "1-Pedido LIBERADO"//ZPP->ZPP_OK:="LIBERADO"
             IF _aTelaPedidos[_nX][_nPosTPCA] = "1"//PALITIZADO
                _nTotPalsLib+=_aTelaPedidos[_nX][_nPosPalete]
             ELSE
                _nTotPesoLib+=SC5->C5_I_PESBR
             ENDIF

             nLiberados++
          ELSE          
             IF lTemColCarga
                Disarmtransaction()//para quando é carga completa das mesos / Tem que ser antes pq o MOMS66ZY8() grava na base
                _lDisarmou:=.T.
             ENDIF
                _aTelaPedidos[_nX,nPosCar] = "BR_AMARELO"//REJEITADO //ZPP->ZPP_OK:="REJEITADO"
             _SeqZY3:= MOMS66ZY3("005", _dHoje, _cTime,_cVinc,_aTelaPedidos,_nX) //FALTA DE ESTOQUE
             MOMS66ZY8("005",_SeqZY3, _dHoje, _cTime,_cVinc,_aSC6_Produtos)      //FALTA DE ESTOQUE
             _aTelaPedidos[_nX,_nPosObs] := "2-Pedido com problema na liberacao - Item: "+SC6->C6_PRODUTO+" - "+_cLogErro

             IF lTemColCarga .AND. _lDisarmou
                BREAK
             ENDIF
          ENDIF

       // PASTAS 1 , 2, 3 E DAS MESOS
       ELSEIF _aTelaPedidos[_nX,nPosCar]   == "ENABLE" .AND.;// VERDE - Carregar SIM
              (_aTelaPedidos[_nX][nPosOK2] == "LBNO"   .OR. (lTemColCarga .AND. EMPTY(_aTelaPedidos[_nX][nPosC1])))
                  // REAL - DESMARCADO                  OU  REAL MARCADO MAS SEM CARGA VALIDADA 

              _cJutificativa:="027"//PEDIDO FORA DO PADRAO PARA CARREGAMENTO           
              _aTelaPedidos[_nX,_nPosObs] := "3.4-Pedido fora do padrao para carregamento"

              IF _aTelaPedidos[_nX,_nPosCaFechada] == "1-SIM"  //PASTA 1 E 2
              
                 _cJutificativa:="022"//NÃO CARREGOU POR DECISÃO DO COMERCIAL
                 _aTelaPedidos[_nX,_nPosObs] := "3.1-Pedido nao carregou por decisao do comercial"
              
              ELSEIF lTemColCarga// PASTAS DA MESORREGIÕES
                 nMesoPeso:=0
                 FOR P := 1 TO LEN(_aTelaPedidos)
                     IF _aTelaPedidos[P][nPosCar] == "ENABLE" .AND.;// VERDE - Carregar SIM
                       (_aTelaPedidos[P][nPosOK2] == "LBNO"   .OR. (lTemColCarga .AND. EMPTY(_aTelaPedidos[P][nPosC1])))
                        // REAL - DESMARCADO                  OU  REAL MARCADO MAS SEM CARGA VALIDADA 
                        nMesoPeso+=_aTelaPedidos[P][_nPosPesBru]//SC5->C5_I_PESBR
                     ENDIF
                 NEXT  
                 IF nMesoPeso > 0 .AND. ROUND((nMesoPeso/1000),0) > VAL(ALLTRIM(_cMultPeso))//Ex.: "14 / 30 / 46 / 50" VAL() DEVVOLVE 14
                    _cJutificativa:="022"//NÃO CARREGOU POR DECISÃO DO COMERCIAL
                    _aTelaPedidos[_nX,_nPosObs] := "3.2-Pedido nao carregou por decisao do comercial"
                 ELSE
                    _cJutificativa:="021"//FALTA DE VOLUME PARA FORMAR CARGA
                    _aTelaPedidos[_nX,_nPosObs] := "3.3-Pedido nao carregou por falta de volume para formar carga"
                 ENDIF

              ENDIF

              IF _lSimular
                 BREAK
              ENDIF
              _SeqZY3:= MOMS66ZY3(_cJutificativa, _dHoje, _cTime,_cVinc,_aTelaPedidos,_nX) 
              MOMS66ZY8(_cJutificativa,_SeqZY3, _dHoje, _cTime,_cVinc,_aSC6_Produtos)      
   
       ELSEif _aTelaPedidos[_nX,_nPosEst] = "DISABLE" //FALTA DE ESTOQUE
       
          _aTelaPedidos[_nX,_nPosObs] := "4-Pedido nao carregou por falta de estoque"
          IF _lSimular
             BREAK
          ENDIF
          _SeqZY3:= MOMS66ZY3("005", _dHoje, _cTime,_cVinc,_aTelaPedidos,_nX) //FALTA DE ESTOQUE
          MOMS66ZY8("005",_SeqZY3, _dHoje, _cTime,_cVinc,_aSC6_Produtos)      //FALTA DE ESTOQUE // // GRAVA SÓ OS PRODUTOS QUE FALTOU ESTOQUE
       
       ELSEIF _aTelaPedidos[_nX,_nPosCap] = "DISABLE" //SEM CAPACIDADE
          
          _aTelaPedidos[_nX,_nPosObs] := "5-Pedido nao carregou por falta de capacidade"
          IF _lSimular
             BREAK
          ENDIF
          MOMS66ZY3("002", _dHoje, _cTime,_cVinc,_aTelaPedidos,_nX) //FALTA DE CAPACIDADE
       
       ENDIF

    END SEQUENCE
//  END TRANSACTION

    AADD(_aColsTGrv,_aTelaPedidos[_nX])

NEXT

IF _lGravaLOG
   oProc:cCaption := ("Processando: "+STRZERO(nConta,5) +" de "+ _cTot+" - Liberados: "+CValToChar(nLiberados)+" - Gravando Log...")
   MOMS66LG("PEDIDOS",_aTelaPedidos,oProc,_cPasta,{},lTemColCarga)//GRAVA ITEM DA TELA
ENDIF

RETURN  .T.

/*===============================================================================================================================
Programa----------: MOMS66TGrv
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2022
===============================================================================================================================
Descrição---------: Tela com resultado da Gravacao
===============================================================================================================================
Parametros--------: _aColsTGrv,oProc
===============================================================================================================================
Retorno-----------: NENHUM
===============================================================================================================================*/
Static Function MOMS66TGrv(_aColsTGrv,oProc)
LOCAL _bSair :={|| oDlg2:End()  }
LOCAL aHeader:=aHeaderP//{}
LOCAL aBotoes:={}

IF _lGravaLOG
   MOMS66LG("INICIAL" ,,oProc,"",_aSB2Inic   )//GRAVA STATUS INICIAL DA SB2
// MOMS66LG("GERENTES",,oProc,"",,,_aGerentes)//GRAVA A TELA DE RESERVA DOS GERENTES
   MOMS66LG("FINAL"   ,,oProc,"",_aSB2       )//GRAVA ITEM DE CONSUMO DA SB2
ENDIF


/*
Aadd(aHeader,{"Liberado"          ,"PO_OK"     ,"@BMP",10,0,""               ,"","C","","","","","   "})// 01
Aadd(aHeader,{"Estoque"           ,"ESTOQUE"   ,"@BMP",10,0,""               ,"","C","","","","",".F."})// 02
Aadd(aHeader,{"Capacidade"        ,"CAPACIDA"  ,"@BMP",10,0,""               ,"","C","","","","",".F."})// 03
//Aadd(aHeader,{"Com. Alt"        ,"PO_ORDEMC" ,"9999",04,0,""               ,"","N","","","","",".F."})// 04
Aadd(aHeader,{"Posicao"           ,"PO_ORDEMA" ,"9999",04,0,""               ,"","N","","","","",".F."})// 05
Aadd(aHeader,{"Pedido"            ,"PEDIDO"    ,"@!"  ,LEN(SC5->C5_NUM),0,"" ,"","C","","","","",".F."})// 06
_nPosPed:=LEN(aHeader)// 06 - renumera a variavel para não dar pau nos botões
Aadd(aHeader,{"Dt Emissao"        ,"C5_EMISSAO","@D"  ,08,0,""               ,"","D","","","","",".F."})// 07
Aadd(aHeader,{"Dias"              ,"DIAS_ATRASO",""   ,10,0,""               ,"","N","","","","",".F."})// 08
Aadd(aHeader,{"Dt Entrega"        ,"C5_I_DTENT","@D"  ,08,0,""               ,"","D","","","","",".F."})// 09
Aadd(aHeader,{"Dt Necessidade"    ,"DT_NECESSI","@D"  ,08,0,""               ,"","D","","","","",".F."})// 10
Aadd(aHeader,{"Tp Entrega"        ,"C5_I_AGEND","@!"  ,01,0,""               ,"","C","","","","",".F."})// 11
Aadd(aHeader,{"Cliente"           ,"C5_CLIENTE","@!"  ,40,0,""               ,"","C","","","","",".F."})// 12
Aadd(aHeader,{"Vendedor"          ,"C5_VEND1"  ,"@!"  ,40,0,""               ,"","C","","","","",".F."})// 13
Aadd(aHeader,{"Coordenador"       ,"C5_VEND2"  ,"@!"  ,40,0,""               ,"","C","","","","",".F."})// 14
Aadd(aHeader,{"Gerente"           ,"C5_VEND3"  ,"@!"  ,40,0,""               ,"","C","","","","",".F."})// 15
Aadd(aHeader,{"Tp Operacao"       ,"C5_I_OPER" ,"@!"  ,01,0,""               ,"","C","","","","",".F."})// 16
Aadd(aHeader,{"Tp Frete"          ,"C5_TPFRETE","@!"  ,01,0,""               ,"","C","","","","",".F."})// 17
Aadd(aHeader,{"Ped. Vinculado"    ,"C5_I_PEVIN","@!"  ,LEN(SC5->C5_NUM),0,"" ,"","C","","","","",".F."})// 18
Aadd(aHeader,{"Observacao"        ,"OBSERVAC"  ,""    ,150,0,""              ,"","C","","","","",".F."})// 19
Aadd(aHeader,{"Qtd Reagendamento" ,"C5_I_QTDA" ,"99"  ,02,0,""               ,"","C","","","","",".F."})// 20
Aadd(aHeader,{"Controle"          ,"CONTROLE"  ,"@!"  ,50,0,""               ,"","C","","","","",".F."})// 21
_nPosRecnos:=(LEN(aHeader)+1)//{SC5->(RECNO()),_aSC6_do_PV,(_nCapacPes-_nPesSaldoIni),.F.}//22
*/
aBotoes:={}
AADD(aBotoes,{"",{|| FWMSGRUN( ,{|| MOMS66Pesq(oMsMGet)           },"Pesquisando.."    ,"Aguarde..." )},"","PESQUISAR"        })
AADD(aBotoes,{"",{|| FWMSGRUN( ,{|O| MOMS66Excel("XLSX",O,oMsMGet)},"H.I. : "+TIME()+" - Aguarde...", "Gerando Excel (XLSX)..")},"","Exportacao para XLSX"})
AADD(aBotoes,{"",{|| FWMSGRUN( ,{|O| MOMS66Excel("XML" ,O,oMsMGet)},"H.I. : "+TIME()+" - Aguarde...", "Gerando Excel (XML).. ")},"","Exportacao para XML "})
AADD(aBotoes,{"",{|| FWMSGRUN( ,{|O| MOMS66Excel("CSV" ,O,oMsMGet)},"H.I. : "+TIME()+" - Aguarde...", "Gerando Excel (CSV).. ")},"","Exportacao para CSV "})
AADD(aBotoes,{"",{|| FWMSGRUN( ,{|| MOMS66PPV("S",oMsMGet)        },"Lendo Pedido..","Aguarde...")},"","Ver Pedido Monitor"   })
AADD(aBotoes,{"",{|| FWMSGRUN( ,{|| MOMS66PPV("D",oMsMGet)        },"Lendo Pedido..","Aguarde...")},"","Ver Pedido Detalhado" })
AADD(aBotoes,{"",{|| MOMS66LEG(.T.,oMsMGet)                       },"","LEGENDAS"})

nLin01:=05
nLin02:=08 
nLin03:=25 
nCol01:=10

DEFINE MSDIALOG oDlg2 TITLE _cTitulo OF oMainWnd PIXEL FROM _aSize[7],0 TO _aSize[6],_aSize[5]

                                                     //Largura , ALTURA
    oPnlTopTop := TPanel():New( 1 , 0 , , oDlg2 , , , , , , 80 , 20 , .F. , .F. )

          @ nLin02-5,nCol01 SAY "Saldo Inicial: " +("KG "+ALLTRIM(TRANS(_nPesSaldoIni,"@E 999,999,999,999.999"))) SIZE 099,009 OF oPnlTopTop PIXEL 
          @ nLin02+5,nCol01 SAY "Qtde de Palete: "+(ALLTRIM(TRANS(_nPalSaldoIni,"@E 999,999,999,999.999")))       SIZE 099,009 OF oPnlTopTop PIXEL 	   
       nCol01+=35
       nCol01+=55
          @ nLin02-5,nCol01 SAY oSAYPesLib PROMPT "Liberado: "+("KG "+ALLTRIM(TRANS( _nTotPesoLib,"@E 999,999,999,999.999"))) SIZE 099,009 OF oPnlTopTop PIXEL 
          @ nLin02+5,nCol01 SAY oSAYPalLib PROMPT "Qtde Palete: "+(ALLTRIM(TRANS( _nTotPalsLib,"@E 999,999,999,999.999")))    SIZE 099,009 OF oPnlTopTop PIXEL 
       nCol01+=24
       nCol01+=55
          @ nLin02-5,nCol01 SAY "Capacidade UN: " +("KG "+ALLTRIM(TRANS(_nCapacPes,"@E 999,999,999,999"))) SIZE 199,009 OF oPnlTopTop PIXEL 
          @ nLin02+5,nCol01 SAY "Qtde de Palete: "+(ALLTRIM(TRANS(_nCapacPal,"@E 999,999,999,999")))           SIZE 199,009 OF oPnlTopTop PIXEL 
       nCol01+=38
       nCol01+=55
          @ nLin02-5,nCol01 SAY oSAYVlGer PROMPT "Valor Gerou Financeiro: "+("R$ "+ALLTRIM(TRANS( _nTotGerFin,"@E 999,999,999,999.99"))) SIZE 199,009 OF oPnlTopTop PIXEL 
          @ nLin02+5,nCol01 SAY "Potencial Faturamento: "+("R$ "+ALLTRIM(TRANS( _nTotPonFat,"@E 999,999,999,999.99"))) SIZE 199,009 OF oPnlTopTop PIXEL 
       nCol01+=55
       nCol01+=55
          @ nLin02-5,nCol01 SAY oSAYPesNGer PROMPT "Peso Não Gerou Financeiro.:"+("KG "+ALLTRIM(TRANS(_nTotNaoGerFin,"@E 999,999,999,999.99"))) SIZE 199,009 OF oPnlTopTop PIXEL 

                                 //[ nTop]       , [ nLeft]   , [ nBottom] , [ nRight ] , [ nStyle],cLinhaOk,cTudoOk,cIniCpos, [ aAlter, nFreeze], [ nMax], [ cFieldOk], [ cSuperDel], [ cDelOk], [ oWnd], [ aPartHeader], [ aParCols], [ uChange], [ cTela], [ aColsSize] 
    oMsMGet := MsNewGetDados():New((aPosObj[2,1]),aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],GD_UPDATE ,        ,       ,        ,{"PO_OK"},         ,        ,            ,             ,          ,oDlg2   ,aHeader        ,_aColsTGrv,)

    oMsMGet:SetEditLine(.F.)
    oMsMGet:AddAction("PO_OK"   ,{|| MOMS66LEG(.T.,oMsMGet)  })
    //oMsMGet:oBrowse:lUseDefaultColors := .F.
     //oMsMGet:oBrowse:SetBlkBackColor({|| GETDCLR(oMsMGet:aCols,oMsMGet:nAt)})
       oDlg2:lMaximized:=.T.
       
ACTIVATE MSDIALOG oDlg2 ON INIT (EnchoiceBar(oDlg2,_bSair,_bSair,,aBotoes),;
                                             oPnlTopTop:Align:=CONTROL_ALIGN_TOP,;
                                           oMsMGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT )


RETURN .T.

/*
===============================================================================================================================
Programa--------: Ver_Lib_PV(cChave)
Autor-----------: Alex Wallauer
Data da Criacao-: 26/09/2016
===============================================================================================================================
Descrição-------: Verefica se no SC9 esta tudo OK ou tenta liberar o Pedido
===============================================================================================================================
Parametros------: cChave: Filia + Pedido, _lLiberaPF: Se .T. tenta Liberar o Pedido senao só ver se ta liberado OK
==============================================================================================================================
Retorno---------: Lógico (.F.) Tá com erro (.T.) Tá tudo OK
===============================================================================================================================
*/
*====================================================================================================*
Static Function Ver_Lib_PV(cChave)
*====================================================================================================*
LOCAL _lOK:=.T.//Não Tem erro
LOCAL _nQtdLib:=0

SC6->( DbSetOrder(1) )//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
IF !SC6->( DBSeek( cChave ) )
    _lOK:=.F.//TEM ERRO
    _cLogErro:="Nao achou SC6: "+cChave
    RETURN .F.
ENDIF

SC9->(DBSETORDER(1))
SC6->(DBSETORDER(1))
DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == cChave
    
    IF !SC9->(DBSEEK(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))
        _nQtdLib := MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN)//LIBERA ITEM DO PEDIDO
    ENDIF
    
    IF SC9->(DBSEEK(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))
        If SC9->C9_QTDLIB <> SC6->C6_QTDVEN
            _cLogErro:="C9_QTDLIB diferente C6_QTDVEN"
            _lOK:=.F.//TEM ERRO
            EXIT
        ElseIf !Empty(SC9->C9_BLEST)
            _lOK:=.F.//TEM ERRO
            _cLogErro:="C9_BLEST = "+SC9->C9_BLEST
            EXIT
        ENDIF	    
        If !(EMPTY(SC9->C9_BLCRED))
           SC9->(RECLOCK("SC9",.F.))
             SC9->C9_BLCRED := " "	   
              SC9->(MsUnlock("SC9"))
               
           //Faz análise e liberação de estoque pois o padrão não analisa estoque se o crédito está bloqueado
           //Posiciona SC6 pois a função A440VerSb2 depende do SC6 posicionado para analisar o estoque
           If SC6->(DbSeek(SC9->C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM)) .AND. A440VerSB2(SC9->C9_QTDLIB)
                 If !(empty(SC9->C9_BLEST))
                    SC9->(RECLOCK("SC9",.F.))
                 SC9->C9_BLEST := ""
                    If !(MaAvalSC9("SC9",5,{{ "","","","",SC9->C9_QTDLIB,SC9->C9_QTDLIB2,Ctod(""),"","","",SC9->C9_LOCAL}}))
                       SC9->C9_BLEST := "02"
                    _lOK:=.F.//TEM ERRO
                    _cLogErro:="C9_BLEST = "+SC9->C9_BLEST
                    EXIT
                    Endif	
                 SC9->(MsUnlock("SC9"))
              Endif
              Endif	
           Endif	

    ELSE
       _lOK:=.F.//TEM ERRO
       _cLogErro:="Nao achou SC9: "+SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM
       EXIT
    ENDIF
    SC6->( DBSkip() )
    
ENDDO

RETURN _lOK
/*
===============================================================================================================================
Programa--------: MOMS66ZY3
Autor-----------: Alex Wallauer
Data da Criacao-: 28/06/2022
===============================================================================================================================
Descrição-------: Grava as informações necessárias na tabela ZY3
===============================================================================================================================
Parametros------: cCodjus, _dHoje, _cTime, _cVinc,_aTelaPedidos,_nX
===============================================================================================================================
Retorno---------: NENHUM
===============================================================================================================================*/
Static Function MOMS66ZY3(cCodjus, _dHoje, _cTime, _cVinc,_aTelaPedidos,_nX)
Local _cSec := MOMS66SEC()

ZY3->(RECLOCK("ZY3", .T.))
ZY3->ZY3_FILIAL := xFilial("ZY3")
ZY3->ZY3_FILFT  := SC5->C5_FILIAL
ZY3->ZY3_NUMPV  := SC5->C5_NUM
ZY3->ZY3_SEQUEN := _cSec
ZY3->ZY3_DTMONI := _dHoje
ZY3->ZY3_HRMONI := _cTime
ZY3->ZY3_COMENT := "Processamento de Pedidos Pendentes (MOMS066)"
ZY3->ZY3_CODUSR := __CUSERID
ZY3->ZY3_NOMUSR := UsrFullName(__cUserID)
ZY3->ZY3_ENCMON := "N"
ZY3->ZY3_DTNECE := SC5->C5_I_DTNEC
ZY3->ZY3_DTFAT  := _aTelaPedidos[_nX,_nPosNes]
ZY3->ZY3_DTFOLD := SC5->C5_I_DTENT
ZY3->ZY3_JUSCOD := cCodjus
ZY3->ZY3_ORIGEM := "MOMS066" 
ZY3->ZY3_VNCZY8 := (SC5->C5_NUM + _cVinc)
ZY3->(MSUNLOCK())

Return _cSec

/*
===============================================================================================================================
Programa--------: MOMS66ZY8
Autor-----------: Alex Wallauer
Data da Criacao-: 28/06/2022
===============================================================================================================================
Descrição-------: Grava as informações necessárias na tabela ZY8 
===============================================================================================================================
Parametros------: cCodJus - Código da justificativa
===============================================================================================================================
Retorno---------: NENHUM
===============================================================================================================================*/
Static Function MOMS66ZY8(cCodjus,_cSeq, _dHoje, _cTime, _cVinc,_aSC6_Produtos)
LOCAL I

FOR I := 1 TO LEN(_aSC6_Produtos)
    IF _aSC6_Produtos[I,2] //SE TEM ESTOQUE LOOP
       LOOP
    ENDIF
    SC6->(DbGoTo(_aSC6_Produtos[I,1]))
    If SC6->(Deleted())
       LOOP
    ENDIF

    ZY8->(RecLock("ZY8", .T.))
    ZY8->ZY8_FILIAL := xFilial("ZY8")
    ZY8->ZY8_NUMPV  := SC6->C6_NUM
    ZY8->ZY8_SEQUEN := _cSeq
    ZY8->ZY8_DTMONI := _dHoje
    ZY8->ZY8_HRMONI := _cTime
    ZY8->ZY8_CODUSR := __CUSERID
    ZY8->ZY8_NOMUSR := UsrFullName(__cUserID)
    ZY8->ZY8_CODPRD := SC6->C6_PRODUTO
    ZY8->ZY8_DSCPRD := SC6->C6_DESCRI 
    ZY8->ZY8_UNSVEN := SC6->C6_UNSVEN
    ZY8->ZY8_SEGUM  := SC6->C6_SEGUM
    ZY8->ZY8_QTDVEN := SC6->C6_QTDVEN
    ZY8->ZY8_UM     := SC6->C6_UM
    ZY8->ZY8_FILFT  := SC6->C6_FILIAL
    ZY8->ZY8_JUSCOD := cCodjus
    ZY8->ZY8_ORIGEM := "MOMS066" 
    ZY8->ZY8_VNCZY3 := (SC6->C6_NUM +  _cVinc)
    ZY8->(MsUnLock())
NEXT

RETURN

/*
===============================================================================================================================
Programa----------: MOMS66Excel
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2022
===============================================================================================================================
Descrição---------: Geracao de relatorio da tela
===============================================================================================================================
Parametros--------: _cTipo,oProc,oMsMGet
===============================================================================================================================
Retorno-----------: NENHUM
===============================================================================================================================*/
Static Function MOMS66Excel(_cTipo As Character, oProc As Object, oMsMGet As Object) As Logical
Local _aParAux := {} , nI As Numeric , P As Numeric
Local _aParRet := {}
Local MV_SALVA1:=MV_PAR01 As Numeric
Local MV_SALVA2:=MV_PAR02 As Numeric
PRIVATE _cTitExcel:="Lista de Pedidos apos geração" As Character

MV_PAR01:=1
MV_PAR02:=3

IF oMsMGet = NIL 

   _aOpcP:={"Atual"   ,"Todas"}
   _aOpcM:={"Marcados","Desmarcados","Todos"}

   AADD( _aParAux , { 3 , "Pastas"       , MV_PAR01,_aOpcP, 60 , '' , .T. } )
   AADD( _aParAux , { 3 , "Pedidos"      , MV_PAR02,_aOpcM, 60 , '' , .T. } )

   For nI := 1 To Len( _aParAux )
       aAdd( _aParRet , _aParAux[nI][03] )
   Next     


   IF !ParamBox( _aParAux , "SELECIONE OS FILTROS DOS PEDIDOS" , _aParRet , {|| .T. } , , , , , , , .T. , .T. )
       Return .F.
   EndIf

   IF VALTYPE(MV_PAR01) = "C"
      MV_PAR01:=VAL(MV_PAR01)
   ENDIF
   IF VALTYPE(MV_PAR02) = "C"
      MV_PAR02:=VAL(MV_PAR02)
   ENDIF
   _cTitExcel:=""
   IF MV_PAR02 = 1
      _cTitExcel:=" - Marcados"
   ELSEIF MV_PAR02 = 2
      _cTitExcel:=" - Desmarcados" 
   ENDIF
   
   IF MV_PAR01 = 1//PASTA ATUAL

      _cTitExcel:="Lista de Pedidos da Pasta "+MOMS66Obj(.T.)[1]+_cTitExcel
      IF (oMsMGet:=MOMS66Obj()) = NIL 
         RETURN .F.//LOOP 
      ENDIF
       aCols:=oMsMGet:aCols
       IF LEN(aCols) = 0 .OR. VALTYPE(aCols[1][_nPosRecnos]) <> "A"//LINHA EM BRANCO
          RETURN .F.//LOOP
       ENDIF

    ELSE// TODAS AS PASTAS

       _cTitExcel:="Lista de Pedidos de Todas as Pastas"+_cTitExcel
       aCols:={}

         oProc:cCaption:="Lendo Pedidos Cargas TOP1..."
         ProcessMessages()
         aColsAux:=aClone(oBrwTOP1:aCols)
          IF LEN(aColsAux) > 0 .AND. VALTYPE(aColsAux[1][_nPosRecnos]) = "A"//LINHA EM BRANCO
             FOR P := 1 TO LEN(aColsAux) 
                 AADD(aCols,aClone(aColsAux[P]))
                 aCols[P,_nPosRGBR]:="Cargas TOP1 / "+aCols[P,_nPosRGBR]
             NEXT
          ENDIF

         oProc:cCaption:="Lendo Pedidos Cargas Fechadas..."
         ProcessMessages()
         aColsAux:=aClone(oBrwCaFe:aCols)
          IF LEN(aColsAux) > 0 .AND. VALTYPE(aColsAux[1][_nPosRecnos]) = "A"//LINHA EM BRANCO
             FOR P := 1 TO LEN(aColsAux) 
                 AADD(aCols,aClone(aColsAux[P]))
                 aCols[P,_nPosRGBR]:="Cargas Fechadas / "+aCols[P,_nPosRGBR]
             NEXT
          ENDIF

         oProc:cCaption:="Lendo Pedidos Pedidos Fora de Padrão..."
         ProcessMessages()
         aColsAux:=aClone(oBrwFORA:aCols)
          IF LEN(aColsAux) > 0 .AND. VALTYPE(aColsAux[1][_nPosRecnos]) = "A"//LINHA EM BRANCO
             FOR P := 1 TO LEN(aColsAux) 
                 AADD(aCols,aClone(aColsAux[P]))
                 aCols[P,_nPosRGBR]:="Pedidos Fora de Padrão / "+aCols[P,_nPosRGBR]
             NEXT
          ENDIF

         FOR P := 1 TO LEN(aPedsReg1) 
              IF (nPos:=ASCAN(aBrowses, {|B| B[1] == aFoldReg1[P] } )) > 0
                oProc:cCaption:="Lendo Pedidos "+aFoldReg1[P]
                ProcessMessages()
                oMsMGet:=aBrowses[nPos,2]
                aColsAux:=aClone(oMsMGet:aCols)
                FOR nI := 1 TO LEN(aColsAux) 
                    AADD(aCols,aClone(aColsAux[nI]))
                NEXT
             Endif
         NEXT
         FOR P := 1 TO LEN(aPedsReg2) 
              IF (nPos:=ASCAN(aBrowses, {|B| B[1] == aFoldReg2[P] } )) > 0
                oProc:cCaption:="Lendo Pedidos "+aFoldReg2[P]
                ProcessMessages()
                oMsMGet:=aBrowses[nPos,2]
                aColsAux:=aClone(oMsMGet:aCols)
                FOR nI := 1 TO LEN(aColsAux) 
                    AADD(aCols,aClone(aColsAux[nI]))//
                NEXT
             ENDIF
         NEXT
         FOR P := 1 TO LEN(aPedsReg3) 
              IF (nPos:=ASCAN(aBrowses, {|B| B[1] == aFoldReg3[P] } )) > 0
                oProc:cCaption:="Lendo Pedidos "+aFoldReg3[P]
                ProcessMessages()
                oMsMGet:=aBrowses[nPos,2]
                aColsAux:=aClone(oMsMGet:aCols)
                FOR nI := 1 TO LEN(aColsAux) 
                    AADD(aCols,aClone(aColsAux[nI]))
                NEXT
             ENDIF
         NEXT
         FOR P := 1 TO LEN(aPedsReg4) 
              IF (nPos:=ASCAN(aBrowses, {|B| B[1] == aFoldReg4[P] } )) > 0
                oProc:cCaption:="Lendo Pedidos "+aFoldReg4[P]
                ProcessMessages()
                oMsMGet:=aBrowses[nPos,2]
                aColsAux:=aClone(oMsMGet:aCols)
                FOR nI := 1 TO LEN(aColsAux) 
                    AADD(aCols,aClone(aColsAux[nI]))
                NEXT
             ENDIF
         NEXT
         FOR P := 1 TO LEN(aPedsReg5) 
              IF (nPos:=ASCAN(aBrowses, {|B| B[1] == aFoldReg5[P] } )) > 0
                oProc:cCaption:="Lendo Pedidos "+aFoldReg5[P]
                ProcessMessages()
                oMsMGet:=aBrowses[nPos,2]
                aColsAux:=aClone(oMsMGet:aCols)
                FOR nI := 1 TO LEN(aColsAux) 
                    AADD(aCols,aClone(aColsAux[nI]))
                NEXT
             ENDIF
         NEXT
    ENDIF

ELSE
   _cTitExcel:="Lista de Pedidos apos geração"
   aCols:=oMsMGet:aCols
   IF LEN(aCols) = 0 .OR. VALTYPE(aCols[1][_nPosRecnos]) <> "A"//LINHA EM BRANCO
      RETURN .F.
   ENDIF
ENDIF

IF LEN(aCols) > 0
   IF _cTipo = "DETI"
      MOMS66DET(oProc,aCols)//GERA O RELATÓRIO DETALHANDO OS DADOS POR ITENS.
   ELSE
      MOMS66GerExcel(_cTipo,aHeaderP,aCols,oProc)
   ENDIF
ENDIF
MV_PAR01:=MV_SALVA1
MV_PAR02:=MV_SALVA2
RETURN .T.

/*
===============================================================================================================================
Programa----------: MOMS66GerExcel
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2022
===============================================================================================================================
Descrição---------: Geracao de relatorio da tela
===============================================================================================================================
Parametros--------: _cTipo,aHeader,aCols
===============================================================================================================================
Retorno-----------: NENHUM
===============================================================================================================================*/
Static Function MOMS66GerExcel(_cTipo,aHeader,aCols,oProc)
LOCAL H , C , nIncio:=1
LOCAL aCabCSV:={}
LOCAL _aCabXML:={}

AADD(_aCabXML,{"Filial",2,1,.F.})
AADD(aCabCSV,"Filial")

FOR H := nIncio TO LEN(aHeader)
   // Alinhamento: 1-Left   ,2-Center,3-Right
   // Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
   IF aHeader[H,8] = "C" .OR. aHeader[H,2] $ ""
      //           Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
      AADD(_aCabXML,{aHeader[H,1]     ,1           ,1         ,.F.})//ESQUERDA,GERAL
   ELSEIF aHeader[H,2] = "TOT_PEDIDO"
      //           Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
      AADD(_aCabXML,{aHeader[H,1]     ,3           ,3         ,.F.})//DIREITA,MONETARIO
   ELSEIF aHeader[H,8] ="N" //"C5_I_PESBR/PES_S_ESTO/QTDE_PALETE"
      //           Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
      AADD(_aCabXML,{aHeader[H,1]     ,3           ,2         ,.F.})//DIREITA,NUMERO 
   ELSE
      //           Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
      AADD(_aCabXML,{aHeader[H,1]     ,2           ,1         ,.F.})//CENTRO,GERAL
   ENDIF
   AADD(aCabCSV,aHeader[H,1])
NEXT
aColsXML:={}
_nTotal:=LEN(aHeader)
nMarcados:=0
nDesmarcados:=0
FOR H := nIncio TO LEN(aCols)

   oProc:cCaption:="Lendo Pedidos Marcados: "+STRZERO(nMarcados,7)+" - Desmarcados: "+STRZERO(nDesmarcados,7)
   ProcessMessages()
   IF aCols[H,nPosOK2] = "LBOK"
      nMarcados++
   ELSEIF aCols[H,nPosOK2] = "LBNO"
      nDesmarcados++
   ENDIF
   IF MV_PAR02 = 1 //MARCADOS
      IF aCols[H,nPosOK2] = "LBNO"
         LOOP
      ENDIF
   ELSEIF MV_PAR02 = 2//DESMARCADOS
      IF aCols[H,nPosOK2] = "LBOK"
         LOOP
      ENDIF
   ENDIF
   aItem:={}
   AADD(aItem,_cFilPrc)
   FOR C := nIncio TO _nTotal
      _cConteudo:=ALLTRIM(AllToChar(aCols[H,C]))
      IF _cConteudo == "LBOK"
         AADD(aItem,"Marcado")
      ELSEIF _cConteudo == "LBNO"
         AADD(aItem,"Desmarcado")
      ELSEIF _cConteudo == "ENABLE"
         AADD(aItem,"SIM")
      ELSEIF _cConteudo == "DISABLE"
         AADD(aItem,"NAO")
      ELSEIF _cConteudo == "BR_PRETO"
         AADD(aItem,"PRETO")
      ELSEIF _cConteudo == "BR_BRANCO"
         AADD(aItem,"BRANCO")
      ELSEIF _cConteudo == "BR_CINZA"
         AADD(aItem,"CINZA")
      ELSEIF _cConteudo == "BR_AMARELO"
         AADD(aItem,"AMARELO")
      ELSE
         AADD(aItem,aCols[H,C])
      ENDIF	
   NEXT
   AADD(aColsXML,aItem)
NEXT

_cTitXML:=_cTitExcel+" / "+_cFilPrc+ " - " + AllTrim(FWFilialName(cEmpAnt,_cFilPrc,1))
IF _cTipo = "CSV"
   DlgToExcel( { { "ARRAY" , _cTitXML , aCabCSV , aColsXML } } ) 
ELSEIF _cTipo = "XML"
   U_ITGEREXCEL(,,_cTitXML,,_aCabXML,aColsXML)
ELSEIF _cTipo = "XLSX" //Exportação para Excel (.XLSX)
   U_ITGEREXCEL(,,_cTitXML,,_aCabXML,aColsXML,,,,,,,,.T.)
ENDIF

U_ITMSG("Geração Concluida!  ["+DTOC(DATE())+"] ["+TIME()+"]")

RETURN

/*
===============================================================================================================================
Programa----------: MOMS66PPV
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2022
===============================================================================================================================
Descrição---------: Função para visualizar Pedidos de Vendas Simples ou Detalhado
===============================================================================================================================
Parametros--------: _cTela
===============================================================================================================================
Retorno-----------: NENHUM
===============================================================================================================================
*/
Static Function MOMS66PPV(_cTela,oMsMGet)

IF oMsMGet = NIL .AND. (oMsMGet:=MOMS66Obj()) = NIL 
   RETURN ""
ENDIF

IF oMsMGet <> NIL
   aCols:=oMsMGet:aCols
   IF LEN(aCols) = 0 .OR. VALTYPE(aCols[1][_nPosRecnos]) <> "A"//LINHA EM BRANCO
      RETURN ""
   ENDIF
   N:=oMsMGet:oBrowse:nAt
   C:=oMsMGet:oBrowse:nColPos
ELSE
   RETURN ""
ENDIF

DBSelectArea("SC5")
SC5->( DBSetOrder(1) )
If SC5->( DBSeek( _cFilPrc + aCols[n][_nPosPed] ) ) 
   IF _cTela = "D"
      MatA410(Nil, Nil, Nil, Nil, "A410Visual")
   ELSEIF _cTela = "S"
      MOMS66Visualiza("SC5",SC5->(RECNO()))
   EndIf
EndIf

RETURN ""


/*
===============================================================================================================================
Função------------: MOMS66LG
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2022
===============================================================================================================================
Descrição---------: Grava movimentação da SB2 
===============================================================================================================================
Parametros--------: cTipo,_aTelaPedidos,oProc,_cPasta,_aSB2,lTemColCarga,_aGerentes
===============================================================================================================================
Retorno-----------: NENHUM
===============================================================================================================================
*/
STATIC FUNCTION MOMS66LG(cTipo,_aTelaPedidos,oProc,_cPasta,_aSB2,lTemColCarga,_aGerentes)
Local _nX := 0
DEFAULT _aSB2:={}

IF oProc <> NIL
   oProc:cCaption := ("Gravando LOG do tipo: "+cTipo)
   ProcessMessages()
ENDIF
IF  Len(_aSB2) > 0
    FOR _nX := 1 TO Len(_aSB2)

        ZPQ->(RECLOCK("ZPQ",.T.))
        ZPQ->ZPQ_FILIAL := _cFilPrc
        ZPQ->ZPQ_DATA   := DATE()
        ZPQ->ZPQ_HORA   := _cTime 
        ZPQ->ZPQ_TIPO   := cTipo//"INICIAL" OU "FINAL"
        ZPQ->ZPQ_PRODUT := _aSB2[_nX][2]
        ZPQ->ZPQ_QATU   := _aSB2[_nX][3]  
        ZPQ->ZPQ_RESERV := _aSB2[_nX][4]
        ZPQ->ZPQ_EMPEN  := _aSB2[_nX][5]
        ZPQ->ZPQ_SALDO  := _aSB2[_nX][6] 
        ZPQ->ZPQ_LOCAL  := _aSB2[_nX][7] 
        ZPQ->ZPQ_QNPT   := _aSB2[_nX][8] 		
        ZPQ->(MSUNLOCK())

    NEXT
ENDIF

IF cTipo = "PEDIDOS"
    FOR _nX := 1 TO Len(_aTelaPedidos)

        IF _aTelaPedidos[_nX,nPosCar] = "BR_BRANCO" 
           LOOP
        ENDIF

        ZPP->(RECLOCK("ZPP",.T.))
        ZPP->ZPP_FILIAL:= _cFilPrc
        ZPP->ZPP_DATA  := DATE()
        ZPP->ZPP_HORA  := _cTime

        IF _aTelaPedidos[_nX,nPosCar] == "BR_AMARELO"		   
           ZPP->ZPP_OK:="REJEITADO"	   

        ELSEIF _aTelaPedidos[_nX,nPosCar]  $ "BR_PRETO/BR_CINZA"		   
           ZPP->ZPP_OK:="REAGENDADO"	   

        ELSEIF _aTelaPedidos[_nX,nPosCar]    == "ENABLE" .AND.;//CARREGAR = SIM
           _aTelaPedidos[_nX,nPosOK2]        == "LBOK"   .AND.;//REAL - MARCADO
          (!lTemColCarga .OR. !EMPTY(_aTelaPedidos[_nX][nPosC1]) )
    //MARCADO PASTAS 1,2  OU  MARCADO COM CARGA VALIDADA
          
           ZPP->ZPP_OK:="LIBERADO"

        ELSEIF _aTelaPedidos[_nX,nPosCar]   == "ENABLE" .AND.;//CARREGAR = SIM
              (_aTelaPedidos[_nX][nPosOK2] == "LBNO"   .OR. (lTemColCarga .AND. EMPTY(_aTelaPedidos[_nX][nPosC1])))
                  // REAL - DESMARCADO                  OU  REAL MARCADO MAS SEM CARGA VALIDADA NA MESO

              IF _aTelaPedidos[_nX,_nPosObs] = "3.1-"//_aTelaPedidos[_nX,_nPosCaFechada] == "1-SIM"  //PASTA 1 E 2
                 ZPP->ZPP_OK:="DESMARCADO" //"3.1-Pedido nao carregou por decisao do comercial"
              
              ELSEIF _aTelaPedidos[_nX,_nPosObs] = "3.2-"//PASTAS DA MESORREGIÕES
                 ZPP->ZPP_OK:="DESMARCADO" //"3.2-Pedido nao carregou por decisao do comercial"

              ELSEIF _aTelaPedidos[_nX,_nPosObs] =  "3.3-"// PASTAS DA MESORREGIÕES
                 ZPP->ZPP_OK:="FALTAVOLUME" //"3.3-Pedido nao carregou por falta de volume para formar carga"
              ENDIF
       
       ELSEif _aTelaPedidos[_nX,_nPosEst] = "DISABLE" //FALTA DE ESTOQUE
          ZPP->ZPP_OK:="FALTAESTOQUE"    //"3.1-Pedido nao carregou por falta de estoque"
       ELSEIF _aTelaPedidos[_nX,_nPosCap] = "DISABLE" //SEM CAPACIDADE
          ZPP->ZPP_OK:="FALTACAPACIDADE" //"3.2-Pedido nao carregou por falta de capacidade"
       ENDIF	   
       IF EMPTY(ZPP->ZPP_OK)
          ZPP->ZPP_OK:="NAOPROCESSADO"	   
       ENDIF
        IF _lSimular
          ZPP->ZPP_OK:="S"+ZPP->ZPP_OK
       ENDIF
        ZPP->ZPP_PEDIDO :=   _aTelaPedidos[_nX,_nPosPed]
        ZPP->ZPP_ORDEMC :=   STRZERO(_aTelaPedidos[_nX,_nPosOrdem],4)//STRZERO(_aTelaPedidos[_nX,_nPosORC],4)
        ZPP->ZPP_ORDEMA :=   STRZERO(_aTelaPedidos[_nX,_nPosOrdem],4)
        ZPP->ZPP_EMISSA :=   _aTelaPedidos[_nX,_nPosEms]
        ZPP->ZPP_DTENT  :=   _aTelaPedidos[_nX,_nPosEnt]
        ZPP->ZPP_QTDA   :=   STRZERO(_aTelaPedidos[_nX,_nPosReg],2)
        ZPP->ZPP_DTNECE :=   _aTelaPedidos[_nX,_nPosNes]
        ZPP->ZPP_AGEND  :=   _aTelaPedidos[_nX,_nPosTpA]
        ZPP->ZPP_ESTOQ  :=IF(_aTelaPedidos[_nX,_nPosEst]="ENABLE","Com Estoque"   ,"Sem Estoque")
        ZPP->ZPP_CAPACI :=IF(_aTelaPedidos[_nX,_nPosCap]="ENABLE","Com Capacidade","Sem Capacidade")
        ZPP->ZPP_OPER   :=   _aTelaPedidos[_nX,_nPosTpO] 
        ZPP->ZPP_TPFRET :=   _aTelaPedidos[_nX,_nPosTpF]
        ZPP->ZPP_PEVIN  :=   _aTelaPedidos[_nX,_nPosPedVin] 
        ZPP->ZPP_OBSERV :=   _aTelaPedidos[_nX,_nPosObs]
        ZPP->ZPP_CONTRO :=   _aTelaPedidos[_nX,_nPosChave]
        IF ZPP->(FIELDPOS("ZPP_PASTA")) > 0 
           ZPP->ZPP_PASTA:=  _cPasta+"("+_aTelaPedidos[_nX,_nPosRGBR]+" /"+_aTelaPedidos[_nX,_nPosMeso]+")"
        ENDIF
        ZPP->(MSUNLOCK())

    NEXT

ENDIF

/*
IF cTipo = "GERENTES"
    FOR _nX := 1 TO Len(_aGerentes)
        ZPQ->(RECLOCK("ZPQ",.T.))
        ZPQ->ZPQ_FILIAL := _cFilPrc
        ZPQ->ZPQ_DATA   := DATE()
        ZPQ->ZPQ_HORA   := _cTime 
        ZPQ->ZPQ_TIPO   := cTipo//"GERENTES"
        ZPQ->ZPQ_PRODUT := _aGerentes[_nX][1]
        ZPQ->ZPQ_LOCAL  := _aGerentes[_nX][3] 
        ZPQ->ZPQ_GERENT := _aGerentes[_nX][5] 
        ZPQ->ZPQ_QATU   := _aGerentes[_nX][7]  
        ZPQ->ZPQ_SALDO  := _aGerentes[_nX][8] 
        ZPQ->(MSUNLOCK())
    NEXT
    RETURN .T.
ENDIF
*/

RETURN .T.

/*
===============================================================================================================================
Função------------: MOMS66LEG
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2022
===============================================================================================================================
Descrição---------: LEGENDAS
===============================================================================================================================
Parametros--------: lPosGrv,oMsMGet
===============================================================================================================================
Retorno-----------: NENHUM
===============================================================================================================================
*/
STATIC FUNCTION MOMS66LEG(lPosGrv,oMsMGet)
LOCAL aLegenda:={}
LOCAL N , aCols , C

IF lPosGrv
   AADD(aLegenda,{"ENABLE"    ,"Liberados"                         })
   AADD(aLegenda,{"DISABLE"   ,"Não Processados"                   })
   AADD(aLegenda,{"BR_AMARELO","Rejeitados na Liberação"           })
   AADD(aLegenda,{"BR_PRETO"  ,"Reagendados"                       })
   AADD(aLegenda,{"BR_CINZA"  ,"Reagendados"                       })
   AADD(aLegenda,{"BR_BRANCO" ,"Agendamentos futuro"               })
ELSE
   AADD(aLegenda,{"ENABLE"    ,"Sim / Com Estoque / Com Capacidade"})
   AADD(aLegenda,{"DISABLE"   ,"Não / Sem Estoque / Sem Capacidade"})
   AADD(aLegenda,{"BR_PRETO"  ,"Fora da Data e será Reagendado"    })
   AADD(aLegenda,{"BR_CINZA"  ,"Pedido Vinculado com problema"     })
   AADD(aLegenda,{"BR_BRANCO" ,"Agendamento futuro"                })
   AADD(aLegenda,{"BR_AMARELO","Pedido excluido"                   })
ENDIF

BrwLegenda("PEDIDOS","Legenda",aLegenda)

IF oMsMGet = NIL .AND. (oMsMGet:=MOMS66Obj()) = NIL 
   RETURN "BR_AZUL"
ENDIF

IF oMsMGet <> NIL
   aCols:=oMsMGet:aCols
   IF LEN(aCols) = 0 .OR. VALTYPE(aCols[1][_nPosRecnos]) <> "A"//LINHA EM BRANCO
      RETURN "BR_AZUL"
   ENDIF
   N:=oMsMGet:oBrowse:nAt
   C:=oMsMGet:oBrowse:nColPos
   _cRet:=aCols[N][C]//RETORNA O CONTEUDO DELE MESMO 
   //bEdit2 := {|| oMsMGet:oBrowse:GoLeft() }
   //oMsMGet:oBrowse:bEditCol := bEdit2
   RETURN _cRet//RETORNA O CONTEUDO DELE MESMO 
ENDIF

return "BR_AZUL"//Se devolver azul é pq deu KAKA


/*
===============================================================================================================================
Programa----------: MOMS66CT
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 28/06/2022
===============================================================================================================================
Descrição---------: Retorna a Carga Total = ao relatorio de Ordem de Carga
===============================================================================================================================
Parametros--------: _cProduto: SC6->C6_PRODUTO , _nQtde: SC6->C6_QTDVEN , 
                   lInicial: USADO PARA CALCULAR O SALDO INICIAL NO SC9
                   _cC5_I_TIPCA: C5_I_TIPCA
===============================================================================================================================
Retorno-----------: Carga Total
===============================================================================================================================
*/
Static Function MOMS66CT(_cProduto,_nQtde,lInicial,_cC5_I_TIPCA)
Local _nQtPalete:= 0
DEFAULT _cC5_I_TIPCA:= ""

//A ordem foi setada no inicio do programa
IF !SB1->(DBSEEK(xFilial()+_cProduto))
   _cPaletFechado:="2-NAO"
   RETURN 0
ENDIF
//================================================================================
// Cálculo da quantidade de Paletes
//================================================================================
If SB1->B1_I_UMPAL == '1'

    _nQtPalete	:= ( _nQtde / SB1->B1_I_CXPAL )
    _cUMPal:= cValToChar( SB1->B1_I_CXPAL  ) +' '+SB1->B1_UM
    
ElseIf SB1->B1_I_UMPAL == '2'

    If AllTrim(SB1->B1_SEGUM) == "PC" .And. AllTrim(SB1->B1_TIPO) == "PA" //Tratamento para o QUEIJO
       _nQtPalete	:= (  _nQtde  / SB1->B1_I_CXPAL )
    ELSE
       _nQtPalete	:= ( MOMS66CNV( _nQtde , 1 , 2 ) / SB1->B1_I_CXPAL )
    ENDIF
    _cUMPal:= cValToChar( SB1->B1_I_CXPAL  ) +' '+SB1->B1_SEGUM
    
ElseIf SB1->B1_I_UMPAL == '3'

    _nQtPalete:= ( MOMS66CNV( _nQtde , 1 , 3 ) / SB1->B1_I_CXPAL )
    _cUMPal   := cValToChar( SB1->B1_I_CXPAL  ) +' '+SB1->B1_I_3UM

Else
    _cUMPal:= ''
    _nQtPalete:= 0
EndIf

IF lInicial//USADO PARA CALCULAR O SALDO INICIAL NO SC9
   Return _nQtPalete//COM Decimal
ENDIF

IF _nQtPalete <> Int(_nQtPalete) .OR. _cC5_I_TIPCA = "2" //Batida
   _cPaletFechado:="2-NAO"
ENDIF

IF _nQtPalete = Int(_nQtPalete) .AND. (ALLTRIM(MV_PAR03) = "SP02")
   _cPaletFechado:="1-SIM"
ENDIF

//_nQtPalete :=  Int(_nQtPalete)

Return _nQtPalete

/*
===============================================================================================================================
Programa----------: MOMS66CNV
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 28/06/2022
===============================================================================================================================
Descrição---------: Função para conversão entre unidades de medida - COPIA DA ROMS004CNV
===============================================================================================================================
Parametros--------: _nQtdAux , _nUMOri , _nUMDes
===============================================================================================================================
Retorno-----------: NENHUM
===============================================================================================================================
*/
Static Function MOMS66CNV( _nQtdAux , _nUMOri , _nUMDes )

Local _nRet	:= 0

Do Case

    Case _nUMDes == 1
        
        //================================================================================
        // Conversão da Segunda UM para a Primeira
        //================================================================================
        If _nUMOri == 2
            
            If SB1->B1_TIPCONV == 'D'
                _nRet := _nQtdAux * SB1->B1_CONV
            ElseIf SB1->B1_TIPCONV == 'M'
                _nRet := _nQtdAux / SB1->B1_CONV
            EndIf
        
        //================================================================================
        // Conversão da Terceira UM para a Primeira
        //================================================================================
        ElseIf _nUMOri == 3
            
            _nRet := _nQtdAux * SB1->B1_I_QT3UM
            
        EndIf
        
    Case _nUMDes == 2
        
        //================================================================================
        // Conversão da Primeira UM para a Segunda
        //================================================================================
        If _nUMOri == 1
            
            If SB1->B1_TIPCONV == 'D'
                _nRet := _nQtdAux / SB1->B1_CONV
            ElseIf SB1->B1_TIPCONV == 'M'
                _nRet := _nQtdAux * SB1->B1_CONV
            EndIf
        
        //================================================================================
        // Conversão da Terceira UM para a Segunda
        //================================================================================	
        ElseIf _nUMOri == 3
            
            _nRet := _nQtdAux * SB1->B1_I_QT3UM
            
            If SB1->B1_TIPCONV == 'D'
                _nRet := _nRet / SB1->B1_CONV
            ElseIf SB1->B1_TIPCONV == 'M'
                _nRet := _nRet * SB1->B1_CONV
            EndIf
            
        EndIf
    
    Case _nUMDes == 3
    
        //================================================================================
        // Conversão da Primeira UM para a Terceira
        //================================================================================
        If _nUMOri == 1
            
            _nRet := _nQtdAux / SB1->B1_I_QT3UM
        
        //================================================================================
        // Conversão da Segunda UM para a Terceira
        //================================================================================	
        ElseIf _nUMOri == 2
            
            If SB1->B1_TIPCONV == 'D'
                _nRet := _nQtdAux * SB1->B1_CONV
            ElseIf SB1->B1_TIPCONV == 'M'
                _nRet := _nQtdAux / SB1->B1_CONV
            EndIf
            
            _nRet := _nRet / SB1->B1_I_QT3UM
            
        EndIf

EndCase

Return( _nRet )

/*
===============================================================================================================================
Programa----------: MOMS66Item
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 28/06/2022
===============================================================================================================================
Descrição---------: Tela dos itens do Pedido e dos itens que sobrou o estoque 
===============================================================================================================================
Parametros--------: cTela "ITENS" ou "CONSOLIDADO" ou "GERENTES" 
===============================================================================================================================
Retorno-----------: NENHUM
===============================================================================================================================
*/
Static Function MOMS66Item(cTela)
Local aCab       :={} , L
Local aSize      :={}
Local aItens     :={}
Local _aSC6_do_PV:={}
//LOCAL aHeader2 :={} //"GERENTES"
//LOCAL _bEfetivar    //"GERENTES"
//LOCAL _bSair        //"GERENTES"
//LOCAL oDlgGer       //"GERENTES"

IF (oMsMGet:=MOMS66Obj()) = NIL 
   RETURN ""
ENDIF

IF cTela = "GERENTES"
/*
   IF !MOMS66Acesso()
      RETURN ""
   ENDIF

   nTaG:=LEN(SC5->C5_VEND3)
//                     1                2             3                            4          5        6        7       8       9       10          11      12        13       14         15        16   17
// aAdd(aHeader ,{trim(x3_titulo)   ,x3_campo    ,x3_picture                 ,x3_tamanho,x3_decimal,x3_valid,x3_usado,x3_tipo, x3_f3,x3_context,	x3_cbox,x3_relacao,x3_when,X3_TRIGGER,	X3_PICTVAR,.F.,.F.})
   Aadd(aHeader2,{"Produto"         ,"ZPQ_PRODUT","@!"                       ,13,0,"U_M66Valid()","","C","F3ITLC","","","",".T."})//01 GRV
   Aadd(aHeader2,{"Descricao"       ,"DESCRITEM" ,"@!"                       ,45,0,"            ","","C","      ","","","",".F."})//02
   Aadd(aHeader2,{"Armazem"         ,"ZPQ_LOCAL" ,"@!"                       ,02,0,"            ","","C","      ","","","",".F."})//03 GRV
   Aadd(aHeader2,{"Disponivel 2um"  ,"SALDOITEM" ,"@E 9,999,999,999,999.9999",18,4,"            ","","N","      ","","","",".F."})//04
   Aadd(aHeader2,{"Gerente"         ,"ZPQ_GERENT","@!"                     ,nTaG,0,"U_M66Valid()","","C","SA3_02","","","",".T."})//05 GRV
   Aadd(aHeader2,{"Nome Gerente"    ,"NOMEGER"   ,"@!"                       ,45,0,"            ","","C","      ","","","",".F."})//06
   Aadd(aHeader2,{"Reserva na 2a UM","ZPQ_QATU"  ,"@E 9,999,999,999,999.9999",18,4,"U_M66Valid()","","N","      ","","","",".T."})//07 GRV
   Aadd(aHeader2,{"Saldo Ger 2um"   ,"ZPQ_SALDO" ,"@E 9,999,999,999,999.9999",18,4,"            ","","N","      ","","","",".F."})//08 GRV CONTROLE
   Aadd(aHeader2,{"Disponivel 1um"  ,"SALDOITEM" ,"@E 9,999,999,999,999.9999",18,4,"            ","","N","      ","","","",".F."})//09
   Aadd(aHeader2,{"Reserva 1um"     ,"ZPQ_QATU"  ,"@E 9,999,999,999,999.9999",18,4,"            ","","N","      ","","","",".F."})//10
   Aadd(aHeader2,{"Saldo Ger 1um"   ,"ZPQ_SALDO" ,"@E 9,999,999,999,999.9999",18,4,"            ","","N","      ","","","",".F."})//11   - CONTROLE  
   
   IF LEN(_aGerentes) > 0
      _nGDAction:=GD_INSERT + GD_UPDATE + GD_DELETE
   ELSE
      _aGerentes:={}
      _nGDAction:=GD_INSERT + GD_UPDATE + GD_DELETE
   ENDIF

   // pega tamanhos das telas
   _aSize := MsAdvSize()
   _aInfoG := { _aSize[1] , _aSize[2] , _aSize[3] , _aSize[4] , 1 , 1 }
   
   aGObjects := {}
   AAdd( aGObjects, { 100, 100, .T., .T. } )
   
   aPosGObj := MsObjSize( _aInfoG , aGObjects )

   _bEfetivar :={|| IF(U_ITMSG("Confirma GRAVACAO ?",'Atenção!',,2,2,2),(_lGrava:=.T.,oDlgGer:End()),) }
   _bSair     :={|| (_lGrava:=.F.,oDlgGer:End())  }
   
   _cTitulo:="RESERVA DE GERENTES"
   
   DO WHILE .T.

      _lGrava:=.F.

      DEFINE MSDIALOG oDlgGer TITLE _cTitulo OF oMainWnd PIXEL FROM _aSize[7],0 TO _aSize[6],_aSize[5]

                                  //[ nTop]          , [ nLeft]   , [ nBottom] , [ nRight ] , [ nStyle]  ,cLinhaOk,cTudoOk,cIniCpos, [ aAlter], [ nFreeze], [ nMax], [ cFieldOk], [ cSuperDel], [ cDelOk], [ oWnd], [ aPartHeader], [ aParCols], [ uChange], [ cTela], [ aColsSize] 
         oMsMGetG := MsNewGetDados():New((aPosGObj[1,1]),aPosGObj[1,2],aPosGObj[1,3],aPosGObj[1,4],_nGDAction,        ,       ,        ,          ,           ,        ,            ,             ,          ,oDlgGer ,aHeader2       , _aGerentes ,)
       
        oDlgGer:lMaximized:=.T.
          
      ACTIVATE MSDIALOG oDlgGer ON INIT (EnchoiceBar(oDlgGer,_bEfetivar,_bSair,,) , oMsMGetG:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT )
   
      IF _lGrava 
         FOR L := 1 TO LEN(_aSB2)
             _aSB2[L,12]:=0//ZERA PARA NÃO ACUMULAR DO Anterior
         NEXT
         _aGerAux:={}
         lLOOP:=.F.
         FOR L := 1 TO LEN(oMsMGetG:ACOLS)
             IF !aTail(oMsMGetG:ACOLS[L])// Se Linha não Deletada
                AADD(_aGerAux,oMsMGetG:ACOLS[L])
                IF EMPTY(_aGerAux[L][1]) .OR. EMPTY(_aGerAux[L][3]) .OR. EMPTY(_aGerAux[L][5]) .OR. EMPTY(_aGerAux[L][7])
                   U_ITMSG("Os campos: Produto, Armazem, Gerente e Reserva 2um devem ser preenchidos.",'Atenção!',"Ajuste a linha "+STRZERO(L,3),2)	      				   
                   lLOOP:=.T.
                   EXIT
                ENDIF
                IF (_nPos:=aScan(_aSB2, {|x| x[1] == _cFilPrc .AND. LEFT(x[2],11) == LEFT(_aGerAux[L][1],11) .AND. x[7] = _aGerAux[L][3] })) > 0
                   _aSB2[_nPos,12]+=_aGerAux[L][10]//Reserva 1um GERENTES
                ENDIF
                IF _aSB2[_nPos,12] > _aSB2[_nPos,11]
                   cPictQ:=AVSX3('C6_QTDVEN',6)
                   U_ITMSG("A somatoria de reserva dos gerentes do produto "+_aGerAux[L][2]+" é maior que o Saldo disponivel do Produto.",'Atenção!',"A somatorio deve ser menor que "+TRANS(_aGerAux[L][9],cPictQ)+" na 1um",2)
                   lLOOP:=.T.
                   EXIT
                ENDIF
             ENDIF
         NEXT
         IF lLOOP
            LOOP
         ENDIF
         _aGerentes:=ACLONE(_aGerAux)
         _lEfetivar  :=.F.//BLOQUEIA O BOTÃO GERAR
         lClicouMarca:= .T.//Ativa a atualização na troca de pasta
      ENDIF
   
      EXIT

   ENDDO

   RETURN ""*/

ELSEIF cTela = "ITENS"//**************************************************************************************

   aColsI:=oMsMGet:aCols
   IF LEN(aColsI) = 0
      RETURN .F.
   ENDIF
   N:=oMsMGet:oBrowse:nAt
   IF VALTYPE(aColsI[N][_nPosRecnos]) <> "A"//LINHA EM BRANCO
      RETURN .F.
   ENDIF
   _aSC6_do_PV:=aColsI[N][_nPosRecnos][2]

   AADD(aCab,"")
   AADD(aCab,"")
   AADD(aCab,"Codigo")
   AADD(aCab,"Produto")
   AADD(aCab,"Local")
   AADD(aCab,"Qtd 2 Um")
   AADD(aCab,"Seg. Um")
   AADD(aCab,"Qtd")
   AADD(aCab,"Unidade")
   AADD(aCab,"Qtd Palete")// (C6_I_QPALT)
   AADD(aCab,"Vol. por Palete")
   AADD(aCab,"Prc Unitário")
   AADD(aCab,"Vlr Total")
   AADD(aCab,"Qtd Atendida 2 Um") // (2ª UM)
   AADD(aCab,"Qtd Sem Estoque 2 Um")//  (2ª UM)
   AADD(aCab,"Peso Sem Estoque")
   AADD(aCab,"Ger. Finan.")
   AADD(aCab,"Registro")
   _nColRec:=LEN(aCab)

   cPictQ:=AVSX3('C6_QTDVEN',6)
   cPictP:=AVSX3('C6_PRCVEN',6)
   SC6->(Dbsetorder(1))//SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM

   FOR L := 1 TO LEN(_aSC6_do_PV)

         SC6->(DbGoTo(_aSC6_do_PV[L,1]))//MESMO DELETADO O GOTO Posiciona
       If SC6->(Deleted())
          LOOP
       ENDIF
       _cUMPal:=""//Preenchido dentro da Função MOMS66CT ()
       _nQtdePalete:=MOMS66CT(SC6->C6_PRODUTO,SC6->C6_QTDVEN,.F.)
       If SC5->C5_I_OPER = "42" .OR. Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC") = "S"
          cFatura:="Sim"
       ELSE
          cFatura:="Nao"
       ENDIF

       aItem:={}
       AADD(aItem,.F. )
       AADD(aItem,(_aSC6_do_PV[L,4]=0) )// QTDE FALTANTE
       AADD(aItem,SC6->C6_PRODUTO)
       AADD(aItem,ALLTRIM(POSICIONE("SB1",1,xfilial("SB1")+SC6->C6_PRODUTO,"B1_DESC")))
       AADD(aItem,SC6->C6_LOCAL)
       AADD(aItem,TRANS(SC6->C6_UNSVEN , cPictQ ))
       AADD(aItem,SC6->C6_SEGUM)
       AADD(aItem,TRANS(SC6->C6_QTDVEN , cPictQ ))
       AADD(aItem,SC6->C6_UM)
       AADD(aItem,TRANS(_nQtdePalete, "@E 9,999.999" ))//SC6->C6_I_QPALT
       AADD(aItem,_cUMPal)
       AADD(aItem,TRANS(SC6->C6_PRCVEN , cPictP ))
       AADD(aItem,TRANS((SC6->C6_PRCVEN*SC6->C6_QTDVEN), cPictP ))
       AADD(aItem,TRANS(_aSC6_do_PV[L,3],cPictQ) )//_nQtdeATend
       AADD(aItem,TRANS(_aSC6_do_PV[L,4],cPictQ) )//_nQtdeFalta
       AADD(aItem,TRANS(_aSC6_do_PV[L,5],cPictQ) )//_nPesoFalta
       AADD(aItem,cFatura) 
       AADD(aItem,_aSC6_do_PV[L,1])
       
       AADD(aItens,aItem)
   NEXT
   IF LEN(aItens) = 0
      U_ITMSG("Esse pedido já foi Excluido do sistema.",'Atenção!',"",3)  
      RETURN ""
   ENDIF
   _cTitulo:='ITENS DO PEDIDO: '+SC6->C6_NUM
   _cMsgTop:=NIL
    _bCondMarca:={|oLbxAux,nAt| !oLbxAux:aArray[nAt][2] }

    DO WHILE .T.
                      //          ,_aCols     ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab ,bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk)
       _lRet:=U_ITListBox(_cTitulo,aCab,aItens, .T.    , 2    ,_cMsgTop ,          ,aSize  ,         ,     ,        ,          ,       ,        ,          , _bCondMarca,         ,       ,         )
       
       IF _lRet 
          IF !MOMS66Acesso()
             LOOP
          ENDIF
    
          // Grava o Array _aItensCorta com todos os itens de um pedidos de vendas para atualização da base de dados
          _aItensCorta:={}
          _aCortaRes:={}
          FOR L := 1 TO LEN(aItens)
             IF aItens[L,1] .AND. !aItens[L,2]
                SC6->(DBGOTO(aItens[L,_nColRec]))
                Aadd(_aItensCorta,{SC6->C6_FILIAL ,;//01
                                 SC6->C6_NUM      ,;//02
                                 SC6->C6_ITEM     ,;//03
                                 SC6->C6_PRODUTO  ,;//04
                                 SC6->C6_LOCAL    ,;//05
                                 SC6->C6_QTDVEN   ,;//06
                                 "S"              ,;//07
                                 SC6->C6_UNSVEN    ;//08
                                 })
                  
             ENDIF
          NEXT    

          IF LEN(_aItensCorta) > 0 .AND. U_ITMSG("CONFIRMA A EXCLUSAO DOS PRODUTOS SELECIONADOS DO PEDIDO ?",'Atenção!',,3,2,2) .AND. MOMS66Motivo()
             _aCortaRes:={}
             _cRetorno:=""
             FWMSGRUN( ,{|oProc| _cRetorno:=MOMS047QGR(SC6->C6_FILIAL+SC6->C6_NUM,oProc,_aItensCorta) },"Processando!","Aguarde...") //ALTERA O PEDIDO MSEXECAUTO()

             IF LEN(_aCortaRes) = 0 
                FOR L := 1 TO LEN(aItens)
                    IF aItens[L,1] .AND. !aItens[L,2]	     
                       aItem:={}
                       
                       AADD(aItem,("SUCESSO" $ _cRetorno))
                       AADD(aItem,aItens[L,3])
                       AADD(aItem,aItens[L,4])
                       AADD(aItem,_cRetorno  )
                       
                       AADD(_aCortaRes,aItem)
                    ENDIF
                NEXT		 
             ENDIF

             IF LEN(_aCortaRes) > 0 
                aCab2:={}
                AADD(aCab2,"")
                AADD(aCab2,"Codigo")
                AADD(aCab2,"Produto")
                AADD(aCab2,"Mensagem")
                _nColMen:=LEN(aCab2)
                  
                 aBotoesM:={}
                 AADD(aBotoesM,{"",{|| U_ITMsgLog(oLbxAux:aArray[oLbxAux:nAt][ _nColMen ], "MENSAGEM" )},"","MENSAGEM"} )
                 _bDblClk:={|oLbxAux| U_ITMsgLog(oLbxAux:aArray[oLbxAux:nAt][ _nColMen ], "MENSAGEM" )}
                 
                 _cTitulo:='RESULTADO DO CORTE - '+_cTitulo
                                  //          ,_aCols    ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab ,bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk)
                 IF !U_ITListBox(_cTitulo,aCab2,_aCortaRes, .T.    , 4    ,        ,          ,        ,         ,     ,        , aBotoesM  ,       ,_bDblClk,           ,          ,         ,       ,          )
                    LOOP
                 ENDIF 
             ELSE
                 U_ITMSG("Nenhum produto selecionado.",'Atenção!',"Selecione 1 ou mais produtos",2)	      
                 LOOP 	      
             ENDIF  

          ELSEIF LEN(_aItensCorta) = 0 
             U_ITMSG("Nenhum produto selecionado.",'Atenção!',"Selecione 1 ou mais produtos",2)
             LOOP
          ELSE
             LOOP
          ENDIF   
       ENDIF
       
       EXIT
    
    ENDDO

ELSEIF cTela = "CONSOLIDADO"

   AADD(aCab,""       )                      //01   
   AADD(aCab,"Codigo" )                      //02   
   AADD(aCab,"Produto")                      //03   
   AADD(aCab,"Local"  )                      //04   
   AADD(aCab,"Qtde Disponivel 2a UM Inicial")//05                         
   AADD(aCab,"2a UM"  )                      //06   
   AADD(aCab,"Qtde Carteira 2a UM")          //07               
   AADD(aCab,"Saldo 2a UM")                  //08       
   AADD(aCab,"Qtde Disponivel 2a UM Final")  //09                       
   //AADD(aCab,"Qtde Reserva Gerentes 1um")    //10                     
   
   cPictQ:=AVSX3('B2_QATU',6)
   
   FOR L := 1 TO LEN(_aSB2)
       aItem:={}

        //Carrega fator de conversão se existir
        _nfator := 1
        If SB1->(Dbseek(xfilial("SB1")+_aSB2[L,2]))
           If SB1->B1_CONV == 0
              If SB1->B1_I_QQUEI == 'S' .and. SB1->B1_I_FATCO > 0
                    _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_I_FATCO,SB1->B1_I_FATCO)
              Endif
           Else
              _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_CONV,SB1->B1_CONV)
           Endif
        Endif
       
       _aSB2[L,10]:= (_aSB2[L,11]*_nfator)-_aSB2[L,09] //SALDO
       
       AADD(aItem,(_aSB2[L,10]>=0) )//01
       AADD(aItem,_aSB2[L,2]     )//02
       AADD(aItem,SB1->B1_DESC   )//03
       AADD(aItem,_aSB2[L,7]     )//04
       AADD(aItem,TRANS( (_aSB2[L,11]*_nfator) , cPictQ ))//05 DISPONIVEL INICIAL
       AADD(aItem,SB1->B1_SEGUM  )//06
       AADD(aItem,TRANS( _aSB2[L,09] , cPictQ ))//07 QTDE Carteira
       AADD(aItem,TRANS( _aSB2[L,10] , cPictQ ))//08 SALDO
       AADD(aItem,TRANS((_aSB2[L,06]*_nfator) , cPictQ ))//09 DISPONIVEL FINAL
//	   AADD(aItem,TRANS((_aSB2[L,12]        ) , cPictQ ))//10 Qtde Reserva Gerentes 1um

       AADD(aItens,aItem)
   NEXT

    aItens := ASORT(aItens,,,{|x,y| x[3] < y[3]})

   _cTitulo:='SALDO CONSOLIDADO DO ESTOQUE DE TODOS OS ITENS DOS PEDIDOS LISTADOS'
   _cMsgTop:=NIL

           //          ,_aCols     ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab ,bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk)
   U_ITListBox(_cTitulo,aCab,aItens, .T.    , 4    ,_cMsgTop ,          ,aSize  ,         ,     ,        ,          ,       ,        ,          ,           ,         ,       ,         )

ELSEIF cTela = "PEDXPRODSEST"

   AADD(aCab,"Filial"    )                   //01     
   AADD(aCab,"Pedido"    )                   //02     
   AADD(aCab,"Cliente"   )                   //03
   AADD(aCab,"Rede"      )                   //04
   AADD(aCab,"Gerente"   )                   //05
   AADD(aCab,"Coord."    )                   //06
   AADD(aCab,"UF Cliente")                   //07
   AADD(aCab,"Codigo" )                      //08   
   AADD(aCab,"Produto")                      //09   
   AADD(aCab,"Local"  )                      //10   
   AADD(aCab,"Qtde 2a UM Ped")               //11       
   AADD(aCab,"2a UM"  )                      //12   
   AADD(aCab,"Qtde Carteira 2a UM")          //13               
   AADD(aCab,"Qtde Disponivel 2a UM Inicial")//14                         
   AADD(aCab,"Sem Estoque?")                 //15                         
   
   cPictQ:=AVSX3('C6_QTDVEN',6)
   FOR L := 1 TO LEN(_aPedXProdSE)
       IF VALTYPE(_aPedXProdSE[L,11]) = "N"
          _aPedXProdSE[L,11] := TRANS(  _aPedXProdSE[L,11], cPictQ )//Qtde 2a UM Ped
       ENDIF
   NEXT
   cPictQ:=AVSX3('B2_QATU',6)
   
   FOR L := 1 TO LEN(_aPedXProdSE)
       
        IF (_nPos:=aScan(_aSB2, {|x| x[1] == _aPedXProdSE[L,1]  .AND. x[2] == _aPedXProdSE[L,8] .AND. x[7] = _aPedXProdSE[L,10] })) > 0
           //Carrega fator de conversão se existir
           _nfator := 1
           If SB1->(Dbseek(xfilial("SB1")+_aSB2[_nPos,2]))
              If SB1->B1_CONV == 0
                 If SB1->B1_I_QQUEI == 'S' .and. SB1->B1_I_FATCO > 0
                       _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_I_FATCO,SB1->B1_I_FATCO)
                 Endif
              Else
                 _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_CONV,SB1->B1_CONV)
              Endif
           Endif
        //_aPedXProdSE[L,11] := TRANS(  _aPedXProdSE[L,11]       , cPictQ )//Qtde 2a UM Ped
          _aPedXProdSE[L,13] := TRANS(  _aSB2[_nPos,09]          , cPictQ )//QTDE CARTEIRA
          _aPedXProdSE[L,14] := TRANS( (_aSB2[_nPos,11]*_nfator) , cPictQ )//DISPONIVEL INICIAL
       ELSE
        _nfator := 1//_aPedXProdSE[L,11] := TRANS(  _aPedXProdSE[L,11]       , cPictQ )//Qtde 2a UM Ped
       ENDIF
       
   NEXT

    //_aPedXProdSE := ASORT(_aPedXProdSE,,,{|x,y| x[2] < y[2]})

   _cTitulo:='PEDIDOS X PRODUTOS SEM ESTOQUE'
   _cMsgTop:=NIL

           //               ,_aCols      ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab ,bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk)
   U_ITListBox(_cTitulo,aCab,_aPedXProdSE, .T.    , 1    ,_cMsgTop ,          ,aSize  ,         ,     ,        ,          ,       ,        ,          ,           ,         ,       ,         )

ENDIF

RETURN ""

/*
===============================================================================================================================
Programa----------: MOMS66Pesq
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 28/06/2022
===============================================================================================================================
Descrição---------: Pesquisa Pedidos
===============================================================================================================================
Parametros--------: oMsMGet
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/
Static Function MOMS66Pesq(oMsMGet)

Local _oGet1		:= Nil
Local _oDlg			:= Nil
Local _cGet1		:= Space(LEN(SC5->C5_NUM))
Local _aComboBx1	:= { "1 - Pedido" , "2 - Linha Com." }
Local _cComboBx1	:= "1 - Pedido"
Local _nOpca		:= 0
Local _nPos			:= 0
Local _lAchou		:= .F.

IF oMsMGet = NIL .AND. (oMsMGet:=MOMS66Obj()) = NIL 
   RETURN .F.
ENDIF

IF oMsMGet <> NIL
   aCols:=oMsMGet:aCols
   //IF LEN(aCols) = 0 .OR. VALTYPE(aCols[1][_nPosRecnos]) <> "A"//LINHA EM BRANCO
   //   RETURN .F.
   //ENDIF
   //N:=oMsMGet:oBrowse:nAt
   //C:=oMsMGet:oBrowse:nColPos
   _cTotGeral:=ALLTRIM(STR(LEN(aCols)))
ELSE
   RETURN .F.
ENDIF

DEFINE MSDIALOG _oDlg TITLE "Pesquisar" FROM 178,181 TO 259,697 PIXEL 

@020,003 MsGet _oGet1 Var _cGet1				Size 212,009 PIXEL OF _oDlg COLOR CLR_BLACK Picture "@!" F3 "SC5"

DEFINE SBUTTON FROM 004,227 TYPE 1 ENABLE ACTION ( _nOpca := 1 , _oDlg:End() ) OF _oDlg
DEFINE SBUTTON FROM 021,227 TYPE 2 ENABLE ACTION ( _nOpca := 0 , _oDlg:End() ) OF _oDlg

@004,003 ComboBox _cComboBx1 Items _aComboBx1	Size 213,010 PIXEL OF _oDlg

ACTIVATE MSDIALOG _oDlg CENTERED

If _nOpca == 1
   _cGet1 := ALLTRIM( _cGet1 )
   _cPasta:= ""
   IF _cComboBx1 = "1"
            
      If (_nPos := ASCAN(aCols,{|P| P[_nPosPed] == _cGet1 }) ) <> 0 // Procura o pedido na pasta atual
           oMsMGet:oBrowse:nAt    := N :=_nPos
         oMsMGet:oBrowse:nColPos:= C :=_nPosPed
           _lAchou:= .T.
         _cPasta:= "Atual"
      ELSE
         IF (_nPos:=ASCAN(_aPedidos,{|aPed| aPed[_nPosPed] == _cGet1 } )) > 0 // Procura o pedido na lista geral dos Pedidos para ve se veio no filtro
            cPastaAtual:=MOMS66Obj(.T.)[1]//Nome da pasta 1 ou 2 ou meso
            cRegiaoBR  :=_aPedidos[_nPos,_nPosRGBR]
            cNomeMeso  :=_aPedidos[_nPos,_nPosMeso]
            _aPedPasta  := {}
            
            IF cPastaAtual <> aFoders1[1]                                 // 1-"Cargas Fechadas TOP1"
               _aPedPasta:=oBrwTOP1:aCols
               IF (_nPos:=ASCAN(_aPedPasta,{|aPed| aPed[_nPosPed] == _cGet1 } )) > 0    // Procura o pedido na pasta 1-"Cargas Fechadas TOP1"
                  _cPasta:= aFoders1[1]
                  _lAchou:=.T.
               ENDIF
            ENDIF
            
            IF !_lAchou .AND. cPastaAtual <>  aFoders1[2]                 // 2-"Cargas Fechadas"
               _aPedPasta:=oBrwCaFe:aCols
               IF (_nPos:=ASCAN(_aPedPasta,{|aPed| aPed[_nPosPed] == _cGet1 } )) > 0    // Procura o pedido na pasta 2-"Cargas Fechadas"
                  _cPasta:= aFoders1[2]
                  _lAchou:=.T.
               ENDIF
            ENDIF

            IF !_lAchou .AND. cPastaAtual <>  aFoders1[3]                 // Pedidos Fora de Padrão
               _aPedPasta:=oBrwFORA:aCols
               IF (_nPos:=ASCAN(_aPedPasta,{|aPed| aPed[_nPosPed] == _cGet1 } )) > 0    // Procura o pedido na pasta Pedidos Fora de Padrão
                  _cPasta:= aFoders1[3]
                  _lAchou:=.T.
               ENDIF
            ENDIF

            IF !_lAchou .AND. (_nPos:=ASCAN(aBrowses, {|B| B[1] == cNomeMeso } )) > 0// Cargas por Regioes do Brasil - Procura o nome da MESO
               oMsMGet2:=aBrowses[_nPos,2]
               _aPedPasta:=oMsMGet2:aCols
               IF !EMPTY(_aPedPasta) .AND. (_nPos:=ASCAN(_aPedPasta,{|aPed| aPed[_nPosPed] == _cGet1 } ) ) > 0 //Procura o pedido na lista de pedidos da aba dele
                  _cPasta:= cRegiaoBR+" / "+cNomeMeso
                  _lAchou:=.T.
               ENDIF	  
               ENDIF
         ELSE
            _lAchou:=.F.
         ENDIF
      EndIf	  	
                
   ELSEIF _cComboBx1 = "2"
                
      If (_nPos := ASCAN(aCols,{|P| P[_nPosOrdem] = VAL(_cGet1) }) ) <> 0 
           oMsMGet:oBrowse:nAt    := N :=_nPos
         oMsMGet:oBrowse:nColPos:= C :=_nPosOrdem
           _lAchou:= .T.
      EndIf
                
    EndIf
ELSE
   RETURN .F.
EndIf

If _lAchou
   oMsMGet:oBrowse:Refresh()
   oMsMGet:oBrowse:SetFocus()
   IF _cComboBx1 = "1"
      U_ITMSG("O Pedido "+_cGet1+" esta na linha "+ALLTRIM(STR(_nPos))+" da pasta "+_cPasta ,'Atenção!',,2) 
   ENDIF
ELSE
   IF _cComboBx1 = "1"
      U_ITMSG("PEDIDO não encontrado em nenhuma pasta.",'Atenção!',"Tente outro pedido",3) 
   ELSE
      U_ITMSG("Linha não encontrada.",'Atenção!',"O numero maximo de linhas é "+_cTotGeral,3) 
   ENDIF
EndIf

RETURN .T.

/*
===============================================================================================================================
Programa----------: MOMS66Visualiza
Autor-------------: Alex Wallauer
Data da Criacao---: 28/06/2022
===============================================================================================================================
Descrição---------: Visualiza PEDIDO SIMPLES
===============================================================================================================================
Parametros--------: cAlias,nReg
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/
STATIC Function MOMS66Visualiza(cAlias,nReg)

Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Local aCpos	    := NIL//{"",""}
Local aAcho     := {}//NIL//{"",  "","",}
LOCAL nInc //, _nI
Local _cAlias     := GetNextAlias()
AADD(aAcho,"C5_I_IDPED")
AADD(aAcho,"C5_CLIENTE")
AADD(aAcho,"C5_LOJACLI")
AADD(aAcho,"C5_I_NOME" )
AADD(aAcho,"C5_I_FANTA")
AADD(aAcho,"C5_I_NOMRD")
AADD(aAcho,"C5_I_MUN  ")
AADD(aAcho,"C5_I_EST"  )
AADD(aAcho,"C5_I_BAIRR")
AADD(aAcho,"C5_I_OBPED")
AADD(aAcho,"C5_MENNOTA")
AADD(aAcho,"C5_I_OPTRI")
AADD(aAcho,"C5_I_PVREM")
AADD(aAcho,"C5_I_PVFAT")
AADD(aAcho,"C5_I_TRCNF")
AADD(aAcho,"C5_I_FILFT")
AADD(aAcho,"C5_I_FLFNC")
AADD(aAcho,"C5_I_TAB")
AADD(aAcho,"C5_I_DSCTB")
AADD(aAcho,"NOUSER")

Private cCadastro := "Visualizacao do Monitor do PEDIDO: "+SC5->C5_NUM
Private aTela[0][0],aGets[0]

aRotina := {}
AADD( aRotina , { "Pesquisar"	, "" , 0 , 1 } )
AADD( aRotina , { "Visualizar"	, "" , 0 , 2 } )
nOpc:=2

//Cria variaveis M->????? da Enchoice
//RegToMemory( "SC5", .F., .F. )
For nInc := 1 To SC5->(FCount())
    M->&(SC5->(FieldName(nInc))) := SC5->(FieldGet(nInc))
Next

_aAuxZY3:=ZY3->(DBSTRUCT())
_cCampo :="ZY3_JUSDES"//Inseri o Campo Virtual de Descrição
aAdd( _aAuxZY3 ,{  Getsx3cache(_cCampo,"X3_CAMPO")    ,;
                   Getsx3cache(_cCampo,"X3_TIPO")     ,;
                   Getsx3cache(_cCampo,"X3_TAMANHO")  ,;
                   Getsx3cache(_cCampo,"X3_DECIMAL")  })

_otemp := FWTemporaryTable():New(_cAlias,_aAuxZY3)
_otemp:AddIndex( "I1", {"ZY3_SEQUEN"} )
_otemp:Create()

DbSelectArea("ZY3")

ZY3->(DbSetOrder(1)) // ZY3_FILIAL+ZY3_NUMPV+ZY3_SEQUEN 
IF ZY3->(DbSeek( xFilial("ZY3")+SC5->C5_NUM ))
   Do While ! ZY3->(Eof()) .And. xFilial("ZY3")+SC5->C5_NUM == ZY3->(ZY3_FILIAL+ZY3_NUMPV)
      (_cAlias)->(DBAPPEND())
      For nInc := 1 To (_cAlias)->(FCount())
          If (nPos:=ZY3->(FIELDPOS( (_cAlias)->( FieldName(nInc)) ))) <> 0 
             (_cAlias)->(FieldPut( nInc , ZY3->( FieldGet(nPos) )  ))
          ENDIF
      NEXT 
      (_cAlias)->ZY3_JUSDES := POSICIONE("ZY5",1,xFilial("ZY5")+ZY3->ZY3_JUSCOD,"ZY5_DESCR") 
      ZY3->(DbSkip())
   EndDo
ELSE
   U_ITMSG("Pedido "+SC5->C5_NUM+" não tem historico.",'Atenção!',"",3)
ENDIF

_aZY3:={}
For nInc := 1 to len(_aAuxZY3)
    _cUsado:=Getsx3cache(_aAuxZY3[nInc][1],"X3_USADO")
    If X3USO(_cUsado) //.AND. Getsx3cache(_aAuxZY3[nInc][1],"X3_BROWSE") = "S"
       AADD(_aZY3,{_aAuxZY3[nInc][1], Getsx3cache(_aAuxZY3[nInc][1],"X3_ORDEM")} )
    ENDIF
NEXT
_aZY3:=ASORT(_aZY3,,,{|X,Y| X[2] < Y[2] })//ORDEM DE ORDEM

aTB_Campos:={}
For nInc := 4 To LEN(_aZY3)
    AADD(aTB_Campos,{_aZY3[nInc,1],,;
                     Getsx3cache(_aZY3[nInc,1],"X3_TITULO"),;
                     Getsx3cache(_aZY3[nInc,1],"X3_PICTURE")})
NEXT

aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 200, 200, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)
lNoFolder:=.F.
DEFINE MSDIALOG oDlg1 TITLE cCadastro From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

   DbSelectArea("SC5")
   //      cAlias, nReg, nOpc, aCRA, cLetra, cTexto, aAcho, aPos     ,aCpos , nModelo, nColMens, cMensagem, cTudoOk, oWnd, lF3,lMemoria, lColumn, caTela, lNoFolder, lProperty
   EnChoice("SC5", nReg, nOpc,     ,       ,       , aAcho,aPosObj[1], aCpos,        ,         ,          ,        , oDlg1,   , .F.    ,        ,       , lNoFolder,          )
   
   DbSelectArea(_cAlias)		
   (_cAlias)->(DBGoTop())
   oMark:=MSSELECT():New(_cAlias,,,aTB_Campos,.F.,,aPosObj[2])

ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| oDlg1:End() },{|| oDlg1:End() },,)

RETURN .T.

/*
Static Function GETDCLR(aLinha,nLinha)
//Local nCor01:= CLR_BLACK       // RGB( 0, 0, 0 )
//Local nCor02:= CLR_BLUE        // RGB( 0, 0, 128 )
//Local nCor03:= CLR_GREEN       // RGB( 0, 128, 0 )
//Local nCor04:= CLR_CYAN        // RGB( 0, 128, 128 )
//Local nCor05:= CLR_RED         // RGB( 128, 0, 0 )
//Local nCor06:= CLR_MAGENTA     // RGB( 128, 0, 128 )
//Local nCor07:= CLR_BROWN       // RGB( 128, 128, 0 )
//Local nCor08:= CLR_HGRAY       // RGB( 192, 192, 192 )
Local nCor09:= CLR_LIGHTGRAY     // RGB( 192, 192, 192 )
//Local nCor10:= CLR_GRAY        // RGB( 128, 128, 128 )
//Local nCor11:= CLR_HBLUE       // RGB( 0, 0, 255 )
Local nCor12:= CLR_HGREEN        // RGB( 0, 255, 0 )
//Local nCor13:= CLR_HCYAN       // RGB( 0, 255, 255 )
Local nCor14:= CLR_HRED          // RGB( 255, 0, 0 )
//Local nCor15:= CLR_HMAGENTA    // RGB( 255, 0, 255 )
Local nCor16:= CLR_YELLOW        // RGB( 255, 255, 0 )
Local nCor17:= CLR_WHITE         // RGB( 255, 255, 255 ) 
Local nColuna := 1
Local nRet := nCor17
If aLinha[nLinha][nColuna] = "ENABLE"
   nRet := nCor12
ElseIf aLinha[nLinha][nColuna] = "DISABLE"
   nRet := nCor14
ElseIf aLinha[nLinha][nColuna] = "BR_AMARELO"
   nRet := nCor16
ElseIf aLinha[nLinha][nColuna] = "BR_ PRETO"
   nRet := nCor09
Endif
Return nRet */

/*
===============================================================================================================================
Programa----------: MOMS047QGR
Autor-------------: Alex Wallauer
Data da Criacao---: 30/01/2020
===============================================================================================================================
Descrição---------: ALTERA O PEDIDO
===============================================================================================================================
Parametros--------: _cChave : Filial do pedido de vendas + Numero do pedido dew vendas , oProc , _aItensCorta
===============================================================================================================================
Retorno-----------: NENHUM
===============================================================================================================================
*/
Static Function MOMS047QGR(_cChave,oProc,_aItensCorta)
Local _aCabPV  :={}
Local _aItemPV :={}
Local _aItensPV:={} 
Local _nI  , E

Begin Sequence
_aCabPV  :={}
_aItemPV :={}
_aItensPV:={}
cErro:=""

IF oProc <> NIL
    oProc:cCaption := ("Alterando Pedido: "+_cChave)
    ProcessMessages()
ENDIF

SC5->(DbSetOrder(1))
IF !SC5->(DbSeek( _cChave ))
   cErro:="Pedido não encontrado: "+_cChave
   BREAK
ENDIF

SC6->( DBSETORDER(12) )//C6_FILIAL+C6_NUM+C6_PRODUTO+C6_SOLCOM
IF !SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
   cErro:="Itens do Pedido não encontrado: "+SC5->C5_FILIAL + SC5->C5_NUM
   BREAK
ENDIF

//====================================================================================================
// Monta o cabeçalho do pedido
//====================================================================================================
Aadd( _aCabPV, { "C5_FILIAL"  	,SC5->C5_FILIAL  , Nil}) // filial
Aadd( _aCabPV, { "C5_NUM"    	,SC5->C5_NUM	 , Nil}) // Numero do Pedido de Vendas
Aadd( _aCabPV, { "C5_TIPO"	    ,SC5->C5_TIPO    , Nil}) // Tipo de pedido
Aadd( _aCabPV, { "C5_I_OPER" 	,SC5->C5_I_OPER  , Nil}) // Tipo da operacao
Aadd( _aCabPV, { "C5_CLIENTE"	,SC5->C5_CLIENTE , NiL}) // Codigo do cliente
Aadd( _aCabPV, { "C5_CLIENT" 	,SC5->C5_CLIENT	 , Nil}) // Cliente de Entregra
Aadd( _aCabPV, { "C5_LOJAENT"	,SC5->C5_LOJAENT , NiL}) // Loja Cliente de Entrega
Aadd( _aCabPV, { "C5_LOJACLI"	,SC5->C5_LOJACLI , NiL}) // Loja do cliente
Aadd( _aCabPV, { "C5_EMISSAO"	,SC5->C5_EMISSAO , NiL}) // Data de emissao
Aadd( _aCabPV, { "C5_TRANSP" 	,SC5->C5_TRANSP	 , Nil}) // Transpordadora
Aadd( _aCabPV, { "C5_CONDPAG"	,SC5->C5_CONDPAG , NiL}) // Codigo da condicao de pagamanto*
Aadd( _aCabPV, { "C5_I_TAB"  	,SC5->C5_I_TAB   , Nil}) // Tabela de preços
Aadd( _aCabPV, { "C5_VEND1"  	,SC5->C5_VEND1	 , Nil}) // Vendedor
Aadd( _aCabPV, { "C5_VEND2"  	,SC5->C5_VEND2	 , Nil}) // Coordenador
Aadd( _aCabPV, { "C5_VEND3"  	,SC5->C5_VEND3	 , Nil}) // Gerente
Aadd( _aCabPV, { "C5_MOEDA"	    ,SC5->C5_MOEDA   , Nil}) // Moeda
Aadd( _aCabPV, { "C5_MENPAD" 	,SC5->C5_MENPAD	 , Nil}) // Mensagem padrão para a nota
Aadd( _aCabPV, { "C5_LIBEROK"	,SC5->C5_LIBEROK , NiL}) // Liberacao Total
Aadd( _aCabPV, { "C5_TIPLIB"  	,SC5->C5_TIPLIB  , Nil}) // Tipo de Liberacao
Aadd( _aCabPV, { "C5_TIPOCLI"	,SC5->C5_TIPOCLI , NiL}) // Tipo do Cliente
Aadd( _aCabPV, { "C5_I_NPALE"	,SC5->C5_I_NPALE , NiL}) // Numero que originou a pedido de palete
Aadd( _aCabPV, { "C5_I_PEDPA"	,SC5->C5_I_PEDPA , NiL}) // Pedido Refere a um pedido de Palete
Aadd( _aCabPV, { "C5_I_DTENT"	,SC5->C5_I_DTENT , Nil}) // Dt de Entrega foi alterado para data do dia
Aadd( _aCabPV, { "C5_I_TRCNF"   ,SC5->C5_I_TRCNF , Nil}) // Troca Nota
Aadd( _aCabPV, { "C5_I_BLPRC"   ,SC5->C5_I_BLPRC , Nil}) // Bloqueio de Preços
Aadd( _aCabPV, { "C5_I_FILFT"   ,SC5->C5_I_FILFT , Nil}) // Filial de Faturamento
Aadd( _aCabPV, { "C5_I_FLFNC"   ,SC5->C5_I_FLFNC , Nil})
Aadd( _aCabPV, { "C5_FILGCT"    ,SC5->C5_FILGCT  , Nil})

//====================================================================================================
// Monta o item do pedido
//====================================================================================================
_nTotal:=0

Do While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM
    
    _nI := Ascan(_aItensCorta, {|x| x[1] == SC6->C6_FILIAL .AND.;
                                    x[2] == SC5->C5_NUM    .AND.;
                                    x[3] == SC6->C6_ITEM   .AND.;
                                    x[4] == SC6->C6_PRODUTO})
    If _nI > 0	
        
        _aItemPV:={}
        
        AAdd( _aItemPV , { "LINPOS"     ,"C6_ITEM"                           , SC6->C6_ITEM }) //  Informa a posição do item
        IF _aItensCorta[_nI,7] = "S"
           AAdd( _aItemPV , { "AUTDELETA"  ,_aItensCorta[_nI,7]                 , Nil }) // Informa se o item será ou não excluído.
        ENDIF
        AAdd( _aItemPV , { "C6_FILIAL"  , SC6->C6_FILIAL                     , Nil }) // Filial
        AAdd( _aItemPV , { "C6_NUM"     , SC6->C6_NUM	                     , Nil }) // Numero do Pedido de Vendas
        AAdd( _aItemPV , { "C6_PRODUTO" , SC6->C6_PRODUTO                    , Nil }) // Codigo do Produto
          If _aItensCorta[_nI,7] = "S"
           AAdd(_aItemPV,{ "C6_QTDVEN"  , SC6->C6_QTDVEN                     , Nil }) // 1oUM Quantidade 
           AAdd(_aItemPV,{ "C6_UNSVEN"  , SC6->C6_UNSVEN                     , Nil }) // 2oUM Quantidade 
        ELSE
           AAdd(_aItemPV,{ "C6_QTDVEN"  , _aItensCorta[_nI,6]                , Nil,,SC6->C6_QTDVEN }) // 1oUM Quantidade 
           AAdd(_aItemPV,{ "C6_UNSVEN"  , _aItensCorta[_nI,8]                , Nil,,SC6->C6_UNSVEN }) // 2oUM Quantidade 
        ENDIF   
        AAdd( _aItemPV , { "C6_PRCVEN"  , SC6->C6_PRCVEN                     , Nil }) // Preco Unitario Liquido
        AAdd( _aItemPV , { "C6_PRUNIT"  , SC6->C6_PRUNIT                     , Nil }) // Preco Unitario Liquido
        AAdd( _aItemPV , { "C6_ENTREG"  , SC6->C6_ENTREG                     , Nil }) // Data da Entrega
        AAdd( _aItemPV , { "C6_LOJA"    , SC6->C6_LOJA	                     , Nil }) // Loja do Cliente
        AAdd( _aItemPV , { "C6_SUGENTR" , SC6->C6_SUGENTR                    , Nil }) // Data da Entrega
          If _aItensCorta[_nI,7] = "S"
           AAdd( _aItemPV , { "C6_VALOR"   , SC6->C6_VALOR                   , Nil }) // valor total do item
        ELSE
           AAdd( _aItemPV , { "C6_VALOR"   , ROUND((SC6->C6_PRCVEN*_aItensCorta[_nI,6]),2), Nil,,SC6->C6_VALOR  }) // valor total do item
        ENDIF   
        AAdd( _aItemPV , { "C6_UM"      , SC6->C6_UM                         , Nil }) // Unidade de Medida Primar.
          If _aItensCorta[_nI,7] = "S"
           AAdd(_aItemPV,{ "C6_LOCAL"   , SC6->C6_LOCAL                      , Nil }) // Armazem / lmoxarifado  // SC6->C6_LOCAL
        ELSE
           AAdd(_aItemPV,{ "C6_LOCAL"   , _aItensCorta[_nI,5]                , Nil,,SC6->C6_LOCAL }) // Armazem / lmoxarifado  // SC6->C6_LOCAL
        ENDIF   
        AAdd( _aItemPV , { "C6_DESCRI"  , SC6->C6_DESCRI                     , Nil }) // Descricao
        AAdd( _aItemPV , { "C6_QTDLIB"  , SC6->C6_QTDLIB                     , Nil }) // Quantidade Liberada
        AAdd( _aItemPV , { "C6_PEDCLI"  , SC6->C6_PEDCLI                     , Nil }) // Pedido do Cliente
        AAdd( _aItemPV , { "C6_I_BLPRC" , SC6->C6_I_BLPRC                    , Nil }) // Bloqueio de Preço
        
        AAdd( _aItensPV ,_aItemPV )

    EndIf
    _nTotal++
    
    SC6->( DBSkip() )
EndDo

SC6->( DBSETORDER(1) )//C6_FILIAL+C6_NUM+C6_PRODUTO+C6_SOLCOM

lMsErroAuto   := .F.
_lMsgEmTela   := .F.
_cAOMS074Vld  := ""
_cAOMS074     := "MOMS066" //NAO MOSTRA MENSAGENS DO MATA410 / MT410TOK


IF !MOMS66Travou(_aItensCorta,@cErro,.F.,oProc)
    BREAK
ENDIF

IF _nTotal = LEN(_aItensCorta)//Exclui o pedido se for todos os itens
   _lExclui:=.T.
ELSE
   _lExclui:=.F.
ENDIF

//_cMotivs:="01"//FALTA DE ESTOQUE
_cLocMot := _cMotivs

Begin Transaction

MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPV , _aItensPV , IF(_lExclui,5,4) )

End Transaction

_cMotivs:= _cLocMot

_nTotDepois:=0
SC6->( DBSETORDER(12) )//C6_FILIAL+C6_NUM+C6_PRODUTO+C6_SOLCOM
IF !SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
   Do While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM
      _nTotDepois++
         SC6->( DBSkip() )
   EndDo
ENDIF

If lMsErroAuto .OR. (_nTotDepois = _nTotal)//!EMPTY(_cAOMS074Vld)
   _cErro:=MostraErro(Upper(GetSrvProfString("STARTPATH","")),"MOMS066.LOG")
   _cErro:="[ Exclusão NÃO Realizada: ( "+_cAOMS074Vld + " ) (" + _cErro + ") ]"
ELSE
    _lEfetivar  := .F.//BLOQUEIA O BOTÃO GERAR
    lClicouMarca:= .T.//Ativa a atualização na troca de pasta
    _cErro:="[ Exclusão Realizada com SUCESSO ]"
EndIf

END SEQUENCE

FOR E := 1 TO LEN(_aCortaRes)
    IF _cChave = _aCortaRes[E,2]+_aCortaRes[E,3]
       IF lMsErroAuto
          _aCortaRes[E , 1 ] := .F.
          _aCortaRes[E , _nColMen ] := _cErro
       ELSE
          _aCortaRes[E , 1 ] := .T.
          _aCortaRes[E , _nColMen ] := _cErro
       ENDIF
    ENDIF
NEXT

Return _cErro

/*
===============================================================================================================================
Programa----------: MOMS66Travou()
Autor-------------: Alex Wallauer
Data da Criacao---: 09/10/2018
===============================================================================================================================
Descrição---------: Loca os registro de tabelas previamente, Tenta realizar lock de todos os registros por _ni segundos
===============================================================================================================================
Parametros--------: _aItensCorta: itens, _cErro: Mensagens erro,lSoLiberaPV,aTabelas
===============================================================================================================================
Retorno-----------: _ltravou: .T. / .F. 
===============================================================================================================================
*/
Static Function MOMS66Travou(_aItensCorta,_cErro,lSoLiberaPV,oProc,aTabelas)
LOCAL _lIT_LOCKPD:= U_ITGETMV( 'IT_LOCKPD' , .F. )
LOCAL _tini      := SECONDS()
LOCAL _dini      := DATE()
LOCAL _ltravou   := .F.  
LOCAL  _cMenAtual:=""
DEFAULT aTabelas :={"SC5","SB2"}//"SC6","SA1",
DEFAULT _cErro   :=""

IF oProc <> NIL
   _cMenAtual:=oProc:cCaption
ENDIF

DO WHILE !(_ltravou)

   _tini:= SECONDS()
   _dini:= DATE()
    
    DO WHILE !(_ltravou) .and. (seconds() - _tini) < 10 .and. date() == _dini
        
        _ltravou := .T.
        _cErro   := ""

        IF oProc <> NIL
           oProc:cCaption := _cMenAtual+". Tentativa:  "+ALLTRIM( STR((SECONDS()-_tini)+1,2,0) ) 
           ProcessMessages()
        ENDIF

        IF ASCAN(aTabelas,"SC5") <>  0
            
            If !SC5->(MsRLock(SC5->(RECNO())))
                _cUser:= TCInternal(53)
                _cErro:= "PV esta em uso por "+_cUser
                _ltravou := .F.
                
            Else
                
                If  _lIT_LOCKPD
                    
                    SC5->(MSUNLOCKALL())
                    SC5->(Msunlock())

                    
                Endif
                
            Endif
            
        Endif
        
        IF ASCAN(aTabelas,"SA1") <>  0
            
            SA1->(Dbsetorder(1))
            SA1->(Dbseek(SA1->(xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)))
            If  !SA1->(MsRLock(SA1->(RECNO())))
                _cUser:= TCInternal(53)
                _cErro := "Cliente esta uso: "+AllTrim(SC5->C5_CLIENTE + "/" + SC5->C5_LOJACLI)+" por "+_cUser
                _ltravou := .F.
                
            Else
                
                If  _lIT_LOCKPD
                    
                    SA1->(MSUNLOCKALL())
                    SA1->(Msunlock())

                    
                Endif
                
            Endif
            
        Endif
        
        IF ASCAN(aTabelas,"SC6") <>  0 .OR. ASCAN(aTabelas,"SB2") <>  0
            
            SB2->(Dbsetorder(1))
            SC6->(Dbsetorder(1))
            SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))
            
            Do while SC6->C6_NUM == SC5->C5_NUM .AND. SC5->C5_FILIAL == SC6->C6_FILIAL .AND. SC6->(!EOF())
                
                IF ASCAN(aTabelas,"SC6") <>  0
                    If !SC6->(MsRLock(SC6->(RECNO())))
                        _cUser:= TCInternal(53)
                        _cErro := "Item do PV esta em uso: "+AllTrim(SC6->C6_FILIAL+"/"+SC6->C6_PRODUTO+"/ "+SC6->C6_LOCAL)+" por "+_cUser
                        _ltravou := .F.
                        
                    Else
                        
                        If  _lIT_LOCKPD
                            
                            SC6->(MSUNLOCKALL())
                            SC6->(Msunlock())
                            
                        Endif
                        
                    Endif
                Endif
                
                IF ASCAN(aTabelas,"SB2") <>  0
                    
                    SB2->(Dbseek(SC6->C6_FILIAL+SC6->C6_PRODUTO+SC6->C6_LOCAL))
                    
                    If !SB2->(MsRLock(SB2->(RECNO())))
                        _cUser:= TCInternal(53)
                        _cErro := "Produto / Armazem esta em uso: "+ALLTRIM(SC6->C6_PRODUTO)+" / "+SC6->C6_LOCAL+" por "+_cUser
                        _ltravou := .F.
                    Else
                        If  _lIT_LOCKPD
                            SB2->(MSUNLOCKALL())
                            SB2->(Msunlock())
                        Endif
                    Endif
                    
                    If !lSoLiberaPV
                        
                        _nI := Ascan(_aItensCorta, {|x| x[1] == SC6->C6_FILIAL .AND.;
                                                     x[2] == SC5->C5_NUM    .AND.;
                                                     x[3] == SC6->C6_ITEM   .AND.;
                                                      x[4] == SC6->C6_PRODUTO})
                        
                        If _nI > 0
                            
                            SB2->(Dbseek(SC6->C6_FILIAL+SC6->C6_PRODUTO+_aItensCorta[_nI,5] ))
                            
                            If !SB2->(MsRLock(SB2->(RECNO())))
                                _cUser:= TCInternal(53)
                                _cErro := "Produto / Armazem esta em uso: "+ALLTRIM(SC6->C6_PRODUTO)+" / "+_aItensCorta[_nI,5]+" por "+_cUser
                                _ltravou := .F.
                            Else
                                If  _lIT_LOCKPD
                                    SB2->(MSUNLOCKALL())
                                    SB2->(Msunlock())
                                Endif
                            Endif
                            
                            
                        Endif
                    Endif
                Endif
                
                SC6->(DbSkip())
                
            Enddo
            
        Endif
        
        IF !_ltravou 
           Sleep(100) //Segura o processamento para testar no máximo 10 vezes por segundo os travamentos
        ENDIF
    Enddo
    
    IF !_ltravou .AND. !lSoLiberaPV
       IF U_ITMSG("Não foi possivel alocar os registros do PV: "+SC5->C5_NUM+" pq o "+_cErro ,;
                  'Atenção!',;
                  "Deseja TENTAR novamente alocar o PV ou FINALIZAR o processamento ?",3,2,3,,"TENTAR","FINALIZAR")//ALERT
          LOOP
       ELSE
          EXIT   
       ENDIF		
    ELSE
       EXIT
    ENDIF
    
Enddo
IF !EMPTY(_cErro)
   _cErro:="[ "+_cErro+" ]"
ENDIF   
IF oProc <> NIL
   oProc:cCaption := _cMenAtual
   ProcessMessages()
ENDIF

Return _ltravou

/*
===============================================================================================================================
Programa----------: MOMS66Acesso()
Autor-------------: Alex Wallauer
Data da Criacao---: 23/02/2023
===============================================================================================================================
Descrição---------: Controle de acesso do ususario via ZZL
===============================================================================================================================
Parametros--------: NENHUM
===============================================================================================================================
Retorno-----------: .T. / .F. 
===============================================================================================================================
*/
Static Function MOMS66Acesso(_lEfetivar2)
LOCAL _cFilAcesso:=AllTrim( U_ITGetMV( 'IT_MOMS66FI',' ') )
LOCAL lRet:=.T.
DEFAULT _lEfetivar2 := .T.//DEFAULT com .T. pq só no botão GERAR vai receber a variavel _lEfetivar2 para dar mensagem ou não.

ZZL->( DBSetOrder(3) )
If ZZL->( DBSeek( xFilial("ZZL") + RetCodUsr() ) )
   If !ZZL->ZZL_GESCPV = "S"
      IF !_lAmbTeste
         U_ITMSG("USUARIO SEM ACESSO A ESSA ROTINA.",'Atenção!',"Solicite acesso a Area responsavel. [ZZL_GESCPV = 'S']",3) 
         lRet:=.F.
      ENDIF
   EndIf
EndIf
ZZL->(DBSetOrder(1))

IF lRet .AND. !EMPTY(_cFilAcesso) .AND. !_cFilPrc $ _cFilAcesso
   IF !_lAmbTeste
      U_ITMSG("FILIAL "+_cFilPrc+" SEM ACESSO A ESSA ROTINA.",'Atenção!',"Filiais Habilitadas para Gestão de Carteira [ZP1-IT_MOMS66FI]: "+_cFilAcesso,3) 
      lRet:=.F.
   ENDIF
ENDIF

//IF lRet .AND. MV_PAR07 = 1 //SIM
//   U_ITMSG('ROTINA NÃO PERMITIDA DA OPCAO "Carteira Toda" = Sim .','Atenção!','Escolha a opção "Carteira Toda?" = Não ',3) 
//   lRet:=.F.
//ENDIF

IF lRet .AND. !_lEfetivar2
   U_ITMSG("Houve Alterações, clique em Reprocessar antes de Efetivar / Gravar",'Atenção!',"",3)
   lRet:=.F.
ENDIF

RETURN lRet


/*
===============================================================================================================================
Programa----------: MOMS66Motivo()
Autor-------------: Alex Wallauer
Data da Criacao---: 23/02/2023
===============================================================================================================================
Descrição---------: Motivo do corte
===============================================================================================================================
Parametros--------: NENHUM
===============================================================================================================================
Retorno-----------: .T. / .F. 
===============================================================================================================================
*/
Static Function MOMS66Motivo()
LOCAL _lRet   := .F. , _oDlg2
LOCAL _amotivs:= {}
Local nLinha  := 10
Local _nCol	  := 15
LOCAL _cQuery := " SELECT "
_cQuery += " DISTINCT X5_CHAVE CHAVE,X5_DESCRI DESCRI "
_cQuery += " FROM "+ RetSqlName("SX5") +" X5 "
_cQuery += " WHERE "
_cQuery += "     D_E_L_E_T_ = ' ' "
_cQuery += " AND X5_TABELA  = 'Z1' AND TRIM(X5_CHAVE) <> '98' AND TRIM(X5_CHAVE) <> '99' "
_cQuery += " ORDER BY X5_CHAVE "
If Select("TMPCF") > 0 
    ("TMPCF")->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TCGenQry( ,, _cQuery ) , 'TMPCF' , .F. , .T. )


DO While TMPCF->( !Eof() )
                               
    aAdd( _amotivs , AllTrim( TMPCF->CHAVE ) + " - " + AllTrim( TMPCF->DESCRI ) )

    TMPCF->( DBSkip() )
EndDo

("TMPCF")->( DBCloseArea() )

PUBLIC _cMotivs:= _AMOTIVS[1]

DEFINE MSDIALOG _oDlg2 TITLE ("Corte por exclusão de PVs") From 0,0 To 325, 650 OF oMainWnd PIXEL
                                                                       
    @ nLinha,_nCol SAY "Selecione o motivo para corte:"
    nLinha+=12

    _omotiv := TComboBox():New(nLinha,_nCol,{|u|if(PCount()>0,_cMotivs:=u,_cMotivs)}, _amotivs,250,20,_oDlg2,,,,,,.T.,,,,,,,,,'') //40

    nLinha+=38

    @ nLinha,_nCol    Button "OK"      SIZE 41,15 ACTION ( _oDlg2:End(),_lRet := .T. ) Pixel 
    @ nLinha,_nCol+57 Button "Cancela" SIZE 41,15 ACTION ( _oDlg2:End(),_lRet := .F. ) Pixel 

ACTIVATE MSDIALOG _oDlg2 

RETURN _lRet

/*
===============================================================================================================================
Programa----------: MOMS66DET()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 09/08/2023
===============================================================================================================================
Descrição---------: GERA O RELATÓRIO DETALHANDO OS DADOS POR ITENS.
===============================================================================================================================
Parametros--------: oProc = Objeto de mensagens / _aTelaPedidos = Dados dos Pedidos de Vendas 
===============================================================================================================================
Retorno-----------: NENHUM
===============================================================================================================================
*/
Static Function MOMS66DET(oProc,_aTelaPedidos)
Local _nI, _nX 
Local _aSldItens := {}
Local _aItemSC6
Local _cRegional 
Local _aItens 
Local _cTipoVeic, _cTipoCarga
Local _cCol1, _cCol2, _cCol3
LOCAL _aDadosRel := {}

//IF (oMsMGet:=MOMS66Obj()) = NIL 
//   RETURN .F.
//ENDIF
//_aTelaPedidos:=oMsMGet:aCols
_nTotDados:=Len(_aTelaPedidos)

IF _nTotDados = 0 .OR. VALTYPE(_aTelaPedidos[1][_nPosRecnos]) <> "A"//LINHA EM BRANCO
   RETURN .F.
ENDIF
_cTotGeral:=ALLTRIM(STR(_nTotDados))
   
If ! U_ITMSG("Confirma Emissão do Detalhamento da Listagem de Pedidos Pendentes por Itens ?",'Atenção!',"Serão processado "+_cTotGeral+" pedido(s) e seus itens.",3,2,2)
   Break 
EndIf 

DAI->(DbSetOrder(4)) // DAI_FILIAL+DAI_PEDIDO+DAI_COD+DAI_SEQCAR
DAK->(DbSetorder(1)) // DAK_FILIAL+DAK_COD+DAK_SEQCAR
DA3->(Dbsetorder(1)) // DA3_FILIAL+DA3_COD                                                                                                                                              
SA1->(DbSetOrder(1))                         
nMarcados   :=0
nDesmarcados:=0

For _nI := 1 To _nTotDados

       oProc:cCaption:="Lendo Pedidos Marcados: "+STRZERO(nMarcados,7)+" - Desmarcados: "+STRZERO(nDesmarcados,7)
       ProcessMessages()
       IF _aTelaPedidos[_nI,nPosOK2] = "LBOK"
          nMarcados++
       ELSEIF _aTelaPedidos[_nI,nPosOK2] = "LBNO"
          nDesmarcados++
       ENDIF
       IF MV_PAR02 = 1 //MARCADOS
          IF _aTelaPedidos[_nI,nPosOK2] = "LBNO"
             LOOP
          ENDIF
       ELSEIF MV_PAR02 = 2//DESMARCADOS
          IF _aTelaPedidos[_nI,nPosOK2] = "LBOK"
             LOOP
          ENDIF
       ENDIF

       _aItemSC6  := _aTelaPedidos[_nI,_nPosRecnos] // Possui os recnos dos itens dos pedidos de vendas. 
       SC5->(DbGoto(_aItemSC6[1])) // Posiciona na capa do pedido de vendas.
       //=============================================================
       // Se tiver carga, busca o tipo de veiculo.
       //=============================================================
       _cTipoVeic := " "
       If DAI->(MsSeek(SC5->C5_FILIAL+SC5->C5_NUM))
          DAK->(MsSeek(DAI->DAI_FILIAL+DAI->DAI_COD)) 
          If ! Empty(DAK->DAK_CAMINH)
             If DA3->(MsSeek(xFilial("DA3") + DAK->DAK_CAMINH)) 
                If DA3->DA3_I_TPVC == "1" 
                   _cTipoVeic := "CARRETA"
                ElseIf DA3->DA3_I_TPVC == "2" 
                   _cTipoVeic := "CAMINHAO"
                ElseIf DA3->DA3_I_TPVC == "3" 
                   _cTipoVeic := "BI-TREM"
                ElseIf DA3->DA3_I_TPVC == "4" 
                   _cTipoVeic := "UTILITARIO"
                ElseIf DA3->DA3_I_TPVC == "5" 
                   _cTipoVeic := "RODOTREM"
                EndIf 
             EndIf 
          EndIf 
       EndIf 

       // _cTipoCarga
       _cTipoCarga := "Batida"
       If SC5->C5_I_TIPCA == "1"
          _cTipoCarga := "Paletizada"
       ELSEIF !SC5->C5_I_TIPCA $ "1/2"
         If SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
            IF LEN(ALLTRIM(SA1->A1_I_CCHEP)) == 10
                _cTipoCarga :="Paletizada"//-Paletizada"//PALETE CHEP
            Else
                _cTipoCarga:="Batida"//-Batida"    //ESTIVADA
            EndIf   
         Endif
         If SC5->C5_I_OPER == _cOper50 .OR. SC5->C5_I_OPER == _cOper51 //PEDIDO DE PALLET DEVE SER ENVIADO COMO ESTIVADO
            _cTipoCarga :="Batida"//-Batida"
         Endif
      ENDIF

       _cRegional := U_ROMS002R(SC5->C5_VEND2, SC5->C5_VEND3) // (Coordenador , Gerente ) // Retorna a Regional do Pedido de Vendas
    
       _aSldItens := MOMS66SLDI(_aItemSC6[2]) // Retorna os saldos dos itens dos pedidos de vendas.

       For _nX := 1 To Len(_aSldItens)
           
           SC6->(DbGoTo(_aSldItens[_nX,13]))  
           If SC6->(Deleted())
              LOOP
           ENDIF

           _cCol1 := "NAO"
           _cCol2 := "NAO"
           _cCol3 := "NAO"

           If Upper(AllTrim(_aTelaPedidos[_nI,nPosCar])) == "ENABLE"
              _cCol1 := "SIM"
           ElseIf Upper(AllTrim(_aTelaPedidos[_nI,nPosCar])) == "DISABLE" 
              _cCol1 := "NAO"  
           ElseIf Upper(AllTrim(_aTelaPedidos[_nI,nPosCar])) == "BR_AMARELO"
              _cCol1 := "EXCLUIDO"
           ElseIf Upper(AllTrim(_aTelaPedidos[_nI,nPosCar])) == "BR_BRANCO"
              _cCol1 := "AGENDAMENTO FUTURO"
           ElseIf Upper(AllTrim(_aTelaPedidos[_nI,nPosCar])) $ "BR_PRETO/BR_CINZA"
              _cCol1 := "REAGENDAR"
           EndIf 

           If Upper(AllTrim(_aTelaPedidos[_nI,_nPosEst])) == "ENABLE"
              _cCol2 := "SIM"
           ElseIf Upper(AllTrim(_aTelaPedidos[_nI,_nPosEst])) == "DISABLE" 
              _cCol2 := "NAO"  
           EndIf 

           If Upper(AllTrim(_aTelaPedidos[_nI, _nPosCap])) == "ENABLE"
              _cCol3 := "SIM"
           ElseIf Upper(AllTrim(_aTelaPedidos[_nI,_nPosCap])) == "DISABLE" 
              _cCol3 := "NAO"  
           EndIf 

           _aItens := {_cCol1,;                         // "Carregar"          ,"PO_OK"        // 01
                       _cCol2,;                         // "Estoque"           ,"ESTOQUE"      // 02 
                       _cCol3,;                         // "Capacidade"        ,"CAPACIDA"     // 03 _aTelaPedidos[_nI, 6],;  // "Com. Alt"          ,"PO_ORDEMC"     // 4 
                       _aTelaPedidos[_nI,_nPosOrdem ],; // "Com."              ,"PO_ORDEMA"    // 04 
                       _aTelaPedidos[_nI,_nPosPed   ],; // "Pedido"            ,"PEDIDO"       // 05    
                       _aTelaPedidos[_nI,_nPosEms   ],; // "Dt Emissao"        ,"C5_EMISSAO"   // 06 
                       _aTelaPedidos[_nI,_nPosAtraso],; // "Dias"              ,"DIAS_ATRASO"  // 07 
                       _aTelaPedidos[_nI,_nPosEnt   ],; // "Dt Entrega"        ,"C5_I_DTENT"   // 08 
                       _aTelaPedidos[_nI,_nPosNes   ],; // "Dt Necessidade"    ,"DT_NECESSI"   // 09 
                       _aTelaPedidos[_nI,_nPosTpA   ],; // "Tp Agend "         ,"TIPO_AGEND"   // 10 
                       _aTelaPedidos[_nI,_nPosTotPed],; // "Total Pedido"      ,"TOT_PEDIDO"   // 11 
                       _aTelaPedidos[_nI,_nPosPesBru],; // "Peso Bruto"        ,"C5_I_PESBR"   // 12 
                       _aTelaPedidos[_nI,_nPosPesEst],; // "Peso sem Estoque"  ,"PES_S_ESTO"   // 13 
                       _aTelaPedidos[_nI,_nPosPalete],; // "Qtde Palete"       ,"QTDE_PALETE"  // 14 
                       _aTelaPedidos[_nI,_nPosCli   ],; // "Cliente"           ,"C5_CLIENTE"   // 15 
                       _aTelaPedidos[_nI,_nPosVend  ],; // "Vendedor"          ,"C5_VEND1"     // 16   
                       _aTelaPedidos[_nI,_nPosCoor  ],; // "Coordenador"       ,"C5_VEND2"     // 17   
                       _aTelaPedidos[_nI,_nPosGer   ],; // "Gerente"           ,"C5_VEND3"     // 18   
                       _aTelaPedidos[_nI,_nPosMun   ],; // "Mucnicipio"        ,"C5_I_MUN"     // 19   
                       _aTelaPedidos[_nI,_nPosUF    ],; // "UF"                ,"C5_I_EST"     // 20 
                       _aTelaPedidos[_nI,_nPosTpO   ],; // "Tp Operacao"       ,"C5_I_OPER"    // 21 
                       _aTelaPedidos[_nI,_nPosTpF   ],; // "Tp Frete"          ,"C5_TPFRETE"   // 22 
                       _aTelaPedidos[_nI,_nPosPedVin],; // "Ped. Vinculado"    ,"C5_I_PEVIN"   // 23 
                       _aTelaPedidos[_nI,_nPosObs   ],; // "Observacao"        ,"OBSERVAC"     // 24   
                       _aTelaPedidos[_nI,_nPosReg   ],; // "Qtd Reagend."      ,"C5_I_QTDA"    // 25  
                       _aTelaPedidos[_nI,_nPosDias  ],; // "T.T."              ,"DIAS"         // 26  
                       _cTipoCarga,;                    // "Tipo de Carga"     ,"C5_I_TIPCA"   // 27
                       _aTelaPedidos[_nI,_nPosChave ],; // "Controle"          ,"CONTROLE"     // 28 
                       _cTipoVeic,;                     // Tipo de Veiculo                     // 29
                       _cRegional,;                     // Regional                            // 30
                       SC6->C6_PRODUTO,;                // Produto                             // 31
                       SC6->C6_DESCRI,;                 // Descrição                           // 32  
                       SC6->C6_UNSVEN,;                 // Quantidade Segunda unid. med.       // 33
                       SC6->C6_SEGUM,;                  // Segunda Unid. Medida                // 34
                       SC6->C6_QTDVEN,;                 // Quantidade                          // 35
                       SC6->C6_UM,;                     // Unidade de Medida                   // 36
                       SC6->C6_PRCVEN,;                 // Preço Unitário                      // 37
                       SC6->C6_VALOR,;                  // Valor Total                         // 38
                       _aSldItens[_nX,3],;              // Saldo Atual                         // 39
                       _aSldItens[_nX,4],;              // Qtd. Reserva                        // 40 
                       _aSldItens[_nX,5],;              // Qtd. Empenhada                      // 41
                       _aSldItens[_nX,6],;              // Saldo Disponível                    // 42
                       _aSldItens[_nX,7]}               // Armazem                             // 43

           Aadd(_aDadosRel, _aItens)
                              
       Next 
Next  

   aDadosXML:=ACLONE(_aDadosRel)

   _cTitulo := _cTitExcel+" / "+_cFilPrc+ " - " + AllTrim(FWFilialName(cEmpAnt,_cFilPrc,1))//'Lista de Pedidos Pendentes Detalhados por Itens'
   
   _aCabec := {"Carregar?",;                          // 01 Legenda
               "Tem Estoque?",;                       // 02 Legenda
               "Tem Capacidade?",;                    // 03 Legenda 
               "Posicao",;                            // 04 
               "Pedido",;                             // 05    
               "Dt Emissao",;                         // 06 
               "Dias",;                               // 07 
               "Dt Entrega",;                         // 08 
               "Dt Necessidade",;                     // 09 
               "Tp Agend ",;                          // 10 
               "Total Pedido",;                       // 11 
               "Peso Bruto",;                         // 12 
               "Peso sem Estoque",;                   // 13 
               "Qtde Palete",;                        // 14 
               "Cliente",;                            // 15 
               "Vendedor",;                           // 16   
               "Coordenador",;                        // 17   
               "Gerente",;                            // 18   
               "Mucnicipio",;                         // 19   
               "UF",;                                 // 20 
               "Tp Operacao",;                        // 21 
               "Tp Frete",;                           // 22 
               "Ped. Vinculado",;                     // 23 
               "Observacao",;                         // 24   
               "Qtd Reagend.",;                       // 25  
               "T.T.",;                               // 26  
               "Tipo de Carga",;                      // 27 
               "Controle",;                           // 28 
               "Tipo de Veiculo",;                    // 29
               "Regional",;                           // 30
               "Produto",;                            // 31 
               "Descrição",;                          // 32  
               "Quantidade Segunda unid. med.",;      // 33
               "Segunda Unid. Medida",;               // 34
               "Quantidade",;                         // 35
               "Unidade de Medida",;                  // 36
               "Preço Unitário",;                     // 37
               "Valor Total",;                        // 38
               "Saldo Atual",;                        // 39 
               "Qtd. Reserva",;                       // 40 
               "Qtd. Empenhada",;                     // 41
               "Saldo Disponível",;                   // 42
               "Armazem"}                             // 43

   cPictQ:=AVSX3('C6_QTDVEN',6)
   cPictP:=AVSX3('C6_VALOR' ,6)
   cPictN:="@E 9,999"
   FOR _nX := 1 TO LEN(_aDadosRel)
       _aDadosRel[_nX,12] := TRANS( (_aDadosRel[_nX,12]) , cPictQ )
       _aDadosRel[_nX,13] := TRANS( (_aDadosRel[_nX,13]) , cPictQ )
       _aDadosRel[_nX,14] := TRANS( (_aDadosRel[_nX,14]) , cPictQ )
       _aDadosRel[_nX,33] := TRANS( (_aDadosRel[_nX,33]) , cPictQ )
       _aDadosRel[_nX,35] := TRANS( (_aDadosRel[_nX,35]) , cPictQ )
       _aDadosRel[_nX,39] := TRANS( (_aDadosRel[_nX,39]) , cPictQ )
       _aDadosRel[_nX,40] := TRANS( (_aDadosRel[_nX,40]) , cPictQ )
       _aDadosRel[_nX,41] := TRANS( (_aDadosRel[_nX,41]) , cPictQ )
       _aDadosRel[_nX,42] := TRANS( (_aDadosRel[_nX,42]) , cPictQ )

       _aDadosRel[_nX,04] := TRANS( (_aDadosRel[_nX,04]) , cPictN )
       _aDadosRel[_nX,07] := TRANS( (_aDadosRel[_nX,07]) , cPictN )
       _aDadosRel[_nX,25] := TRANS( (_aDadosRel[_nX,25]) , cPictN )
       _aDadosRel[_nX,26] := TRANS( (_aDadosRel[_nX,26]) , cPictN )       
       
       _aDadosRel[_nX,11] := "R$  "+ALLTRIM(TRANS( (_aDadosRel[_nX,11]) , cPictP ))
       _aDadosRel[_nX,37] := "R$  "+ALLTRIM(TRANS( (_aDadosRel[_nX,37]) , cPictP ))
       _aDadosRel[_nX,38] := "R$  "+ALLTRIM(TRANS( (_aDadosRel[_nX,38]) , cPictP ))
   NEXT
//   ITListBox( _cTitAux , _aHeader , _aCols    , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca,_bLegenda,_lHasOk,_bHeadClk,_aSX1)
   U_ITListBox(_cTitulo  , _aCabec  , _aDadosRel, .T.    , 1    , /*_cMsgTop*/ ,          , /*aSize*/  ,         ,     ,        ,          ,       ,      ,aDadosXML ,           ,         ,       ,         )

Return Nil 

/*
===============================================================================================================================
Programa--------: MOMS66SLDI
Autor-----------: Julio de Paula Paz
Data da Criacao-: 09/08/2023
===============================================================================================================================
Descrição-------: Rotina para retornar os saldos dos itens de pedidos de vendas. Versão simplificada da função MOMS66B2.
===============================================================================================================================
Parametros------: _aItemSC6 = Array com os itens do pedido de vendas.
===============================================================================================================================
Retorno---------: _aRet = Array com os saldos e dados dos itens dos pedidos de vendas.
===============================================================================================================================*/
Static Function MOMS66SLDI(_aItemSC6)
Local _nI 
Local _lSomaPTer:= .F.
Local _nSaldoDisp, _aRet  

SB2->(DbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL
_aRet := {}

For _nI := 1 To Len(_aItemSC6)
        
       SC6->(DBGOTO(_aItemSC6[_nI,1]))
       If SC6->(Deleted())
          LOOP
       ENDIF

       If SB2->(DbSeek(SC6->C6_FILIAL+SC6->C6_PRODUTO+SC6->C6_LOCAL)) //.And. (aScan(_aRet, {|x| x[1] == SB2->B2_FILIAL .AND. x[2] == SB2->B2_COD .AND. x[7] == SB2->B2_LOCAL})) = 0
        
          _lSomaPTer := (SC6->C6_FILIAL $ _cFilTer .And. SC6->C6_LOCAL $ _cLocTer)

          _nSaldoDisp:=SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QEMP + IF(_lSomaPTer,SB2->B2_QNPT,0)
               //_nSaldoDisp:=If( _nSaldoDisp < 0 , 0 , _nSaldoDisp ) //ZEREI O SALDO NEGATIVO PARA NÃO DAR ERRO NOS CALDULOS DE PESO			   

          Aadd(_aRet, {SB2->B2_FILIAL ,;   //01 - FILIAL
                       SB2->B2_COD    ,;   //02 - PRODUTO
                       SB2->B2_QATU   ,;   //03 - 1UM
                       SB2->B2_RESERVA,;   //04 - 1UM
                       SB2->B2_QEMP   ,;   //05 - 1UM
                       _nSaldoDisp    ,;   //06 - DISPONIVEL FINAL 1UM
                       SB2->B2_LOCAL  ,;   //07 - ARMAZEM
                       If(_lSomaPTer,SB2->B2_QNPT,0),;//08 -  1UM
                       0              ,;   //09 - Quantidade Carteira na 2ª UM (SOMTORIA BOLINHA VERDE)
                       0              ,;   //10 - Saldo na 2ª UM (DISPONIVEL - BOLINHA VERDE) CALCULADO
                       SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QEMP + IF(_lSomaPTer,SB2->B2_QNPT,0),;//11-DISPONIVEL INICIAL 1UM
                       0              ,;   //12 - SOMATORIA DAS RESERVAS DOS GERENTES 1UM
                       SC6->(Recno())})    //13 - Recno item de Pedido de Vendas (Tabela SC6) 

        EndIf
    
Next 

Return _aRet 


/*
===============================================================================================================================
Programa--------: ITRegiaoBR(cEstado)
Autor-----------: Alex Wallauer
Data da Criacao-: 12/03/2024
===============================================================================================================================
Descrição-------: Rotina para retornar as Regioes do Brasil
===============================================================================================================================
Parametros------: Estado (UF) , _cMesoReg
===============================================================================================================================
Retorno---------: Regiao do Brasil
===============================================================================================================================*/
User Function ITRegiaoBR(cEstado,_cMesoReg)
Local cRegiao:= "N/A"
If cEstado $ "SP|RJ|MG|ES"
    cRegiao := "Regiao Sudeste"
ElseIf cEstado $ "SC|RS|PR"
    cRegiao := "Regiao Sul"
ElseIf cEstado $ "MS|MT|TO|GO|DF"
    cRegiao := "Regiao Centro Oeste"
ElseIf cEstado $ "AC|AM|AP|MA|PA|RO|RR"
    cRegiao := "Regiao Norte"
ElseIf cEstado $ "AL|BA|CE|PB|PE|PI|RN|SE"
    cRegiao := "Regiao Nordeste"
ElseIf cEstado $ "EX"
    cRegiao := "Exterior"
EndIf
//IF ASCAN(aFolderRGBR,cRegiao) = 0
   //AADD(aFolderRGBR,cRegiao)
//ENDIF
IF ASCAN(aFolderMeso,{|M| M[1] = cRegiao .AND. M[2] = _cMesoReg } ) = 0
   AADD(aFolderMeso,{cRegiao,_cMesoReg})
ENDIF

return cRegiao


/*
===============================================================================================================================
Programa--------: MOMS66PVinc
Autor-----------: Alex Wallauer
Data da Criacao-: 14/03/2024
===============================================================================================================================
Descrição-------: Analiza os pedidos vinculados e marca a ordem de consumo do estoque
===============================================================================================================================
Parametros------: _aPedidos
===============================================================================================================================
Retorno---------: _aPedidos
===============================================================================================================================*/
Static Function MOMS66PVinc(_aPedidos)
LOCAL P 

_aPedidos:=ASORT(_aPedidos,,,{|X,Y| X[_nPosChave] < Y[_nPosChave] })//ORDENA PELA CHAVE DE PRIORIDADE

FOR P := 1 TO LEN(_aPedidos) //ANALISE DOS PEDIDOS VINCULADOS 
    IF EMPTY(_aPedidos[P,_nPosPedVin]) //NÃO TEM VINCULADO LOOP
       LOOP
    ENDIF	   
    IF (_nPosVin:=ASCAN(_aPedidos,{|aPed| aPed[_nPosPed] == _aPedidos[P,_nPosPedVin] } )) > 0 //ACHOU PEDIDO VINCULADO NA MESMA ABA
       _cPedVinc:=_cFilPrc+_aPedidos[P,_nPosPedVin] 
       IF !SC5->(DBSEEK( _cPedVinc))
         _aPedidos[P,_nPosPedVin]:="Nao achou (SC5): "+_cPedVinc
         LOOP
       ENDIF
       IF SC5->C5_I_OPER == _cOper50 .OR. SC5->C5_I_OPER == _cOper51 //SE PEDIDO DE PALETE VINCULADO IGNORA
          _aPedidos[_nPosVin,_nPosPedVin]:="Palete: "+_aPedidos[_nPosVin,_nPosPedVin]
          LOOP
       ENDIF
       _aPedidos[P,_nPosChave]:=_aPedidos[_nPosVin,_nPosChave]//IGUALA A CHAVE PARA FICAREM JUNTAS
       IF _aPedidos[_nPosVin,nPosCar] = "BR_PRETO" .OR. _aPedidos[_nPosVin,nPosCar] = "BR_BRANCO"
          IF _aPedidos[P,nPosCar ] $ "ENABLE/DISABLE"
             _aPedidos[P,nPosCar ]:="BR_CINZA"//_aPedidos[_nPosVin,nPosCar]
          ENDIF
          IF EMPTY(_aPedidos[P,_nPosObs])
              _aPedidos[P,_nPosObs]:="O pedido "+_aPedidos[P,_nPosPedVin]+" vinculado a esse pedido "+_aPedidos[P,_nPosPed]+" esta fora do criterio de pendencias (Legenda)"
          ENDIF
       ENDIF
    ELSE
        IF (_nPos:=ASCAN(aPedVin,{|aPed| aPed[1] == _aPedidos[P,_nPosPedVin] } )) > 0//SE ACHOU NA LISTA GERAL DE VINCULADOS
           _cPedVinc:=_cFilPrc+_aPedidos[P,_nPosPedVin] 
            IF !SC5->(DBSEEK( _cPedVinc))
              _aPedidos[P,_nPosPedVin]:="Nao achou (SC5): "+_cPedVinc
              LOOP
           ENDIF 
           IF SC5->C5_I_OPER == _cOper50 .OR. SC5->C5_I_OPER == _cOper51 //SE PEDIDO DE PALETE VINCULADO IGNORA
              _aPedidos[_nPosVin,_nPosPedVin]:="Palete: "+_aPedidos[_nPosVin,_nPosPedVin]
              LOOP
           ENDIF
           _cObs:="O pedido "+_aPedidos[P,_nPosPedVin]+" vinculado a esse pedido "+_aPedidos[P,_nPosPed]+" esta na pasta: "+aPedVin[_nPos,3]
        ELSE//SE NAÕ ACHOU NA LISTA GERAL DE VINCULADOS
           _cObs:="O pedido "+_aPedidos[P,_nPosPedVin]+" vinculado a esse pedido "+_aPedidos[P,_nPosPed]+" esta fora do criterio de pendencias. (Filtro)"
        ENDIF
        IF _aPedidos[P,nPosCar ] $ "ENABLE/DISABLE"
           _aPedidos[P,nPosCar ]:="BR_CINZA"//"BR_PRETO"
        ENDIF
        _aPedidos[P,_nPosObs]:=_cObs
    ENDIF
NEXT
   
_aPedidos:=ASORT(_aPedidos,,,{|X,Y| X[_nPosChave] < Y[_nPosChave] })//REORDENA PELA CHAVE DE PRIORIDADE

//MARCA A ORDEM DE CONSUMO DO ESTOQUE
FOR P := 1 TO LEN(_aPedidos)
   _aPedidos[P,_nPosOrdem]:=P
NEXT
//MARCA A ORDEM DE CONSUMO DO ESTOQUE

RETURN _aPedidos

/*
===============================================================================================================================
Programa--------: MOMS66Ord
Autor-----------: Alex Wallauer
Data da Criacao-: 14/03/2024
===============================================================================================================================
Descrição-------: Processa o pedido para retornar a prioridade
===============================================================================================================================
Parametros------: _cClassEnt
===============================================================================================================================
Retorno---------: _cChave
===============================================================================================================================*/

Static Function MOMS66Ord(_cClassEnt)
LOCAL _cChave:= "9999"

//Chave Prioridade Comercial + Prioridade Tipo de Agendamento + Qtd de Reagendamento + Data de Emissao + Pedido 			
IF SC5->C5_I_OPER = "20" .AND. SC5->C5_I_TRCNF <> "S" 
   _cChave:="2599"+DTOS(SC5->C5_EMISSAO)+SC5->C5_NUM                           // PRIORIDADE: 02
ELSEIF SC5->C5_TPFRETE = "F"                                                    
   _cChave:="8599"+DTOS(SC5->C5_EMISSAO)+SC5->C5_NUM                           // PRIORIDADE: 05
ELSEIF SC5->C5_I_AGEND = "M"
   _cChave:="10"+STRZERO(99-SC5->C5_I_QTDA,2)+DTOS(SC5->C5_EMISSAO)+SC5->C5_NUM// PRIORIDADE: 01 *
ELSEIF SC5->C5_I_AGEND = "A"
   _cChave:="35"+STRZERO(99-SC5->C5_I_QTDA,2)+DTOS(SC5->C5_EMISSAO)+SC5->C5_NUM// PRIORIDADE: 03
ELSEIF SC5->C5_I_AGEND $ "I/O"
   _cChave:="3599"+DTOS(SC5->C5_EMISSAO)+SC5->C5_NUM                           // PRIORIDADE: 04
ELSE
   _cChave:="9099"+DTOS(SC5->C5_EMISSAO)+SC5->C5_NUM                           // PRIORIDADE: 06
ENDIF  

_dDataCalculada:=SC5->C5_I_DTENT
_cObs:=""
_nDias:=0

IF _cClassEnt == "1-TOP 1 NACIONAL"
   _cChave:="0"+_cChave// PRIORIDADE: 01 * 
ELSE
   _cChave:="1"+_cChave// PRIORIDADE: 02
ENDIF
_lAchouZG5:=.F.
_cRegra:=""

IF SC5->C5_I_AGEND $ "M,A" .AND. SC5->C5_TPFRETE <> "F"  .AND. SC5->C5_I_OPER <> "20" 

   aHeader:={}//Usa na funcao U_OMSVLDEN T()
   aCols  :={}//Usa na funcao U_OMSVLDEN T()
   _nDias:=(U_OMSVLDENT(SC5->C5_I_DTENT,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_I_FILFT,SC5->C5_NUM,1,.F.,SC5->C5_FILIAL,SC5->C5_I_OPER,SC5->C5_I_TPVEN,@_lAchouZG5,@_cRegra,SC5->C5_I_LOCEM))
   //IF _nDias > 0
   //   _nDias--
   //ENDIF

   If SC5->C5_I_TPVEN == "F"     // Carga Fechada 
      _dDataCalculada:=SC5->C5_I_DTENT-_nDias 
      _dDataCalculada:=DataValida( _dDataCalculada, .F. )  // VOLTA DIAS CORRIDOS 
   ELSEIf SC5->C5_I_TPVEN == "V" // Carga Fracionada (Varejo)
      _ni:= 0
      Do while _ni < _nDias
         _dDataCalculada := (_dDataCalculada - 1 )         // VOLTA DIAS UTEIS
         if _dDataCalculada =  DataValida( _dDataCalculada, .F. )
            _ni++
         EndIf 	
      ENDDO
   ENDIF
   IF _dDataCalculada > _dHoje 
      IF (MV_PAR07 = 2) //SE NÃO MOSTRA A CARTEIRA TODA = NÃO 
         _cChave:="LOOP"
      ELSE
         _cObs:="D-Data de necessidade ("+DTOC(_dDataCalculada)+") MAIOR que HOJE."//"BR_BRANCO"
         _cChave:="9699"+DTOS(SC5->C5_EMISSAO)+SC5->C5_NUM       
      ENDIF
   ELSEIF _dDataCalculada < _dHoje
      _cObs:="A-Data de necessidade ("+DTOC(_dDataCalculada)+") MENOR que HOJE. Pedido será alterado para Reagendar"//"BR_PRETO"
      _cChave:="9599"+DTOS(SC5->C5_EMISSAO)+SC5->C5_NUM
   ENDIF
    
ENDIF

RETURN _cChave


/*
===============================================================================================================================
Programa----------: MOMS66Obj
Autor-------------: Alex Wallauer
Data da Criacao---: 18/03/2024
===============================================================================================================================
Descrição---------: Retorna o Browse da pasta ativa
===============================================================================================================================
Parametros--------: lPasta: devolve nome e numero da pasta se .t. senão o objeto 
===============================================================================================================================
Retorno-----------: oMsMGet ativo
===============================================================================================================================*/
Static Function MOMS66Obj(lPasta)
LOCAL nPos
LOCAL cTitPasta:=""
LOCAL nPasta:=(oTFolder01:nOption)
DEFAULT lPasta:=.F.

lRegioes:=.F.
cPastaR:=""

IF LEN(oTFolder01:aPrompts) > 0 .AND. nPasta > 0
   cTitPasta:=oTFolder01:aPrompts[nPasta]
   cPastaR:=cTitPasta//Pasta 1 e 2 e 3
ENDIF

IF LEN(aFoders1) > 3 .AND. cTitPasta = aFoders1[4]
   nPasta:=oPastaRegs:nOption
   IF LEN(oPastaRegs:aPrompts) > 0 .AND. nPasta > 0
      cTitPasta:=oPastaRegs:aPrompts[nPasta]
      cPastaR:=cTitPasta//Pastas das Regioes
      lRegioes:=.T.
   ENDIF
   IF cTitPasta = aFolderRGBR[1]
      nPasta:=oPastMeso1:nOption
      IF LEN(oPastMeso1:aPrompts) > 0 .AND. nPasta > 0
         cTitPasta:=oPastMeso1:aPrompts[nPasta]
      ENDIF
   ELSEIF cTitPasta = aFolderRGBR[2]
      nPasta:=oPastMeso2:nOption
      IF LEN(oPastMeso2:aPrompts) > 0 .AND. nPasta > 0
         cTitPasta:=oPastMeso2:aPrompts[nPasta]
      ENDIF
   ELSEIF cTitPasta = aFolderRGBR[3]
      nPasta:=oPastMeso3:nOption
      IF LEN(oPastMeso3:aPrompts) > 0 .AND. nPasta > 0
         cTitPasta:=oPastMeso3:aPrompts[nPasta]
      ENDIF
   ELSEIF cTitPasta = aFolderRGBR[4]
      nPasta:=oPastMeso4:nOption
      IF LEN(oPastMeso4:aPrompts) > 0 .AND. nPasta > 0
         cTitPasta:=oPastMeso4:aPrompts[nPasta]
      ENDIF
   ELSEIF cTitPasta = aFolderRGBR[5]
      nPasta:=oPastMeso5:nOption
      IF LEN(oPastMeso5:aPrompts) > 0 .AND. nPasta > 0
         cTitPasta:=oPastMeso5:aPrompts[nPasta]
      ENDIF
   ENDIF
ENDIF

IF lPasta
   IF VALTYPE(cTitPasta) <> "C"
      cTitPasta:=""
   ELSEIF lRegioes  
      cTitPasta:="Meso: "+cTitPasta
   ELSE
      cTitPasta:=": "+cTitPasta
   ENDIF
   RETURN {cTitPasta,IF(nPasta>0,nPasta,1)} // SAIDA 1
ENDIF

oMsMGet:=NIL
IF (nPos:=ASCAN(aBrowses, {|B| B[1] == cTitPasta } )) > 0
   
   oMsMGet:=aBrowses[nPos,2]

ELSE
//   U_ITMSG("Nenhum pasta com browse selecionada. ["+cTitPasta+"]",'Atenção!',"Selecione 1 pasta com browse para usar essa opção",1)
   RETURN NIL  // SAIDA 2
ENDIF

RETURN oMsMGet // SAIDA 3

/*
===============================================================================================================================
Programa----------: MOMS66Atu
Autor-------------: Alex Wallauer
Data da Criacao---: 18/03/2024
===============================================================================================================================
Descrição---------: Atualiza todos os valores totais da tela 
===============================================================================================================================
Parametros--------: _cOrigem: dá onde chamou ,_nX,_aTelaPedidos
===============================================================================================================================
Retorno-----------: .T. ou .F.
===============================================================================================================================*/
Static Function MOMS66Atu(_cOrigem,_nX,_aTelaPedidos)
LOCAL nRNaoGerFin:= nVlrPGerFin := 0

cOrigemDebug    :=_cOrigem//VARIAVEL PRIVATE PARA APARECER NO ERROR.LOG 
lRegioes        :=.F.//ALTERA DENTRO DA MOMS66Obj ()
cPastaR         :="" //ALTERA DENTRO DA MOMS66Obj ()

IF _cOrigem = "MARCA" // MARCA E DESMARCA 

   IF LEN(_aTelaPedidos) = 0 .OR. VALTYPE(_aTelaPedidos[_nX][_nPosRecnos]) <> "A"//LINHA EM BRANCO
      RETURN .F.
   ENDIF

// ****  ATUALIZA OS TOTAIS DA PARTE DE CIMA  ******
   _lPalitizada  :=_aTelaPedidos[_nX][_nPosTPCA] = "1"
   _nPedTotPalete:=_aTelaPedidos[_nX][_nPosPalete]//Qtde de Paletes do Pedido 
    
   SC5->(DbGoTo(_aTelaPedidos[_nX][_nPosRecnos][1]))

    SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))
    If SC5->C5_I_OPER = "42" .OR. Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC") = 'S' 
       nVlrPGerFin:=_aTelaPedidos[_nX][_nPosTotPed]
       nRNaoGerFin:=0
    ELSE
       nVlrPGerFin:=0
       nRNaoGerFin:=SC5->C5_I_PESBR
    ENDIF

    IF _aTelaPedidos[_nX][nPosOK2] = "LBOK" //COLUNA REAL
       _nTotGerFin   +=nVlrPGerFin
       _nTotNaoGerFin+=nRNaoGerFin
       //IF _lPalitizada // JÁ SOMA NA FUNÇÃO MOMS66VAL ()
       //   _nTotPalsLib+=_nPedTotPalete
       //ELSE
       //   _nTotPesoLib+=SC5->C5_I_PESBR
       //ENDIF
    ELSEIF _aTelaPedidos[_nX][nPosOK2] = "LBNO" //COLUNA REAL
       _nTotGerFin   -=nVlrPGerFin
       _nTotNaoGerFin-=nRNaoGerFin
       //IF _lPalitizada // JÁ SOMA NA FUNÇÃO MOMS66VAL ()
       //   _nTotPalsLib-=_nPedTotPalete
       //ELSE
       //   _nTotPesoLib-=SC5->C5_I_PESBR
       //ENDIF
    ENDIF
  
    oSAYPesLib:Refresh()   
    oSAYPalLib:Refresh()   
    oSAYVlGer:Refresh() 
    oSAYPesNGer:Refresh()     
// ****  ATUALIZA OS TOTAIS DA PARTE DE CIMA  ******

ENDIF

// ************************** TODAS AS PASTAS QUANDO TROCA DE PASTA  ************************** //
oSAYNPastA:Refresh()

//CASO A PASTA 1 E 2 ESTEJA ZERADA 
_nRMesoPesoLib  :=0
_nVMesoPesoLib  :=0
_nRMesoPalsLib  :=0
_nVMesoPalsLib  :=0
_nRMesoValor    :=0
_nVMesoValor    :=0
_nRMesoNaoGerFin:=0
_nMesoPonFat    :=0
nMesoPonPeso    :=0
_nVCMesoPalsLib :=0
_nVCMesoPesoLib :=0
_cRQtdeCarrega  :=" "
oSAYValCar:Refresh()
oSAYRPeso:Refresh()
oSAYVPeso:Refresh()
oSAYRPale:Refresh()
oSAYVPale:Refresh()
oSAYRVGerF:Refresh()
oSAYVVGerF:Refresh()
oSAYRPnGer:Refresh()
oSAYVPnGer:Refresh()
oBotValCar:Hide()
oSAYValCar:Hide()
_nTotPonFat:=_aTotPonFat[1,2]
_nToRPonFat:=0
oSAYToPon:Refresh()
oSAYRTotPon:Refresh()
//CASO A PASTA 1 E 2 ESTEJA ZERADA 

IF (oMsMGet:=MOMS66Obj()) = NIL 
   RETURN .F.
ENDIF

IF lRegioes//lRegioes: INICIADA DENTRO DA MOMS66Obj ()
   oBotValCar:Show()
   oSAYValCar:Show()
ELSE
   oBotValCar:Hide()
   oSAYValCar:Hide()
ENDIF

IF (nPos:=ASCAN(_aTotPonFat,{|P| P[1] == cPastaR })) > 0 //ALTERA DENTRO DA MOMS66Obj ()
    _nToRPonFat:=_aTotPonFat[nPos,2]
ENDIF
oSAYRTotPon:Refresh()

_aTelaPedidos:=oMsMGet:aCols
IF LEN(_aTelaPedidos) = 0
   RETURN .F.
ENDIF

IF VALTYPE(_aTelaPedidos[1][_nPosRecnos]) <> "A"//LINHA EM BRANCO
   RETURN .F.
ENDIF

IF _cOrigem <> "MARCA" .AND. _cOrigem <> "INICIO" .AND. lClicouMarca
   FWMSGRUN( ,{|oProc| MOMS66Atu2(oMsMGet,oProc) },"Reprocessando PASTA...","Aguarde...")  //TODAS AS PASTAS
ENDIF

//************** ATUALIZA O RODAPE DA TELA COM OS TOTAIS DA PASTA **************************

_nRMesoPesoLib  :=0
_nVMesoPesoLib  :=0
_nRMesoPalsLib  :=0
_nVMesoPalsLib  :=0
_nRMesoValor    :=0
_nVMesoValor    :=0
_nRMesoNaoGerFin:=0
_nMesoPonFat    :=0
nMesoPonPeso    :=0
_nVCMesoPalsLib :=0
_nVCMesoPesoLib :=0

FOR _nX := 1 TO LEN(_aTelaPedidos)

    _lPalitizada  :=_aTelaPedidos[_nX][_nPosTPCA] = "1"
    _nPedTotPalete:=_aTelaPedidos[_nX][_nPosPalete]//Qtde de Paletes do Pedido 
    
    SC5->(DbGoTo(_aTelaPedidos[_nX][_nPosRecnos][1]))

    SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))
    If SC5->C5_I_OPER = "42" .OR. Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC") = 'S' 
       nVlrPGerFin:=_aTelaPedidos[_nX][_nPosTotPed]
       nRNaoGerFin:=0
    ELSE
       nVlrPGerFin:= 0
       nRNaoGerFin:=SC5->C5_I_PESBR
    ENDIF

    IF !_aTelaPedidos[_nX,nPosCar]  $ LEGENDAS_ABCP
       _nMesoPonFat+=nVlrPGerFin
       nMesoPonPeso+=SC5->C5_I_PESBR
    ENDIF

     IF _aTelaPedidos[_nX][nPosOK] = "LBOK" //COLUNA SUGERIDA 
        _nVMesoValor    +=nVlrPGerFin
        //IF _lPalitizada
           _nVMesoPalsLib+=_nPedTotPalete
        //ELSE
           _nVMesoPesoLib+=SC5->C5_I_PESBR
        //ENDIF
     ENDIF

     IF _aTelaPedidos[_nX][nPosOK2] = "LBOK" //COLUNA REAL
        _nRMesoValor+=nVlrPGerFin
        _nRMesoNaoGerFin+=nRNaoGerFin
        //IF _lPalitizada
           _nRMesoPalsLib+=_nPedTotPalete
        //ELSE
           _nRMesoPesoLib+=SC5->C5_I_PESBR
        //ENDIF

        IF !EMPTY(_aTelaPedidos[_nX][nPosC1])
           LOOP
         ENDIF
        //IF _lPalitizada //C5_I_TIPCA
           _nVCMesoPalsLib+=_aTelaPedidos[_nX][_nPosPalete]//Qtde de Paletes do Pedido 
        //ELSE
           _nVCMesoPesoLib+=SC5->C5_I_PESBR 
        //ENDIF

     ENDIF

NEXT

_cRQtdeCarrega:=" "
IF _nVCMesoPesoLib > 0 
   _cRQtdeCarrega:="TO "+ALLTRIM(TRANS( _nVCMesoPesoLib/1000 ,"@E 999,999,999,999.999"))
ENDIF
IF _nVCMesoPalsLib > 0
   IF _nVCMesoPesoLib > 0 
      _cRQtdeCarrega:=_cRQtdeCarrega+" / "+ALLTRIM(TRANS( _nVCMesoPalsLib ,"@E 999,999.999"))+ " Palete(s)"
   ELSE
      _cRQtdeCarrega:=ALLTRIM(TRANS( _nVCMesoPalsLib ,"@E 999,999.999"))+ " Palete(s)"
   ENDIF	
ENDIF
oSAYValCar:Refresh()

oSAYRPeso:Refresh()
oSAYVPeso:Refresh()
oSAYRPale:Refresh()
oSAYVPale:Refresh()

oSAYRVGerF:Refresh()
oSAYVVGerF:Refresh()
oSAYRPnGer:Refresh()
oSAYVPnGer:Refresh()

//************** ATUALIZA O RODAPE DA TELA COM OS TOTAIS DA PASTA **************************

RETURN .T.

/*
===============================================================================================================================
Programa----------: MOMS66Val
Autor-------------: Alex Wallauer
Data da Criacao---: 18/03/2024
===============================================================================================================================
Descrição---------: Atualiza o ESTOQUE
===============================================================================================================================
Parametros--------: _nX,_aTelaPedidos,_cRet
===============================================================================================================================
Retorno-----------: .T. ou .F.
===============================================================================================================================*/
Static Function MOMS66Val(_nX,_aTelaPedidos,_cRet)
LOCAL _nY 

IF LEN(_aTelaPedidos) = 0
   RETURN .F.
ENDIF
IF VALTYPE(_aTelaPedidos[_nX][_nPosRecnos]) <> "A"//LINHA EM BRANCO
   RETURN .F.
ENDIF

_aSC6_do_PV:=ACLONE(_aTelaPedidos[_nX][_nPosRecnos])
SC5->(DbGoTo(_aSC6_do_PV[1]))

_cPedAtual:=SC5->C5_FILIAL+SC5->C5_NUM
IF !SC5->(DBSEEK( _cPedAtual)) //Pedido que não existe mais nessa filial
    _aTelaPedidos[_nX,nPosCar] := "BR_AMARELO"
    _aTelaPedidos[_nX,_nPosObs]:= "Pedido não existe mais nessa filial: "+SC5->C5_FILIAL+" "+SC5->C5_NUM+". FAÇA O REPROCESSAMENTO."
    U_ITMSG("Pedido não existe mais nessa filial: "+SC5->C5_FILIAL+" "+SC5->C5_NUM,'Atenção!',,1)
    RETURN .F.
ENDIF
    
// Pedidos para ignorar
IF _aTelaPedidos[_nX][nPosCar] $ LEGENDAS_ABCP
    RETURN .F.
ENDIF

IF !MOMS66Acesso()
   RETURN .F.
ENDIF

///////////////////////////////////////////////  ESTOQUE  ///////////////////////////////////////////////
_nPesoCapacFil:=_aSC6_do_PV[3]//_nCapacPes
_nPaleCapacFil:=_aSC6_do_PV[5]//_nCapacPal
_lTemEstoque  :=.T.
_cProdSEst    :=""
_cObs         :=""
_aSB2         := MOMS66aSB2(_aSB2,"SALVA")

FOR _nY := 1 TO Len(_aSC6_do_PV[2]) // LOOP NO ITENS DO PEDIDO
        
        SC6->(DBGOTO(_aSC6_do_PV[2][_nY,1]))
        If SC6->(DELETED())
           LOOP
        ENDIF
    
        //REALIZA A CONSUMO DA SB2 
        IF (_nPos:=aScan(_aSB2, {|x| x[1] == SC6->C6_FILIAL .AND. x[2] == SC6->C6_PRODUTO .AND. x[7] = SC6->C6_LOCAL })) > 0 				
            
           //IF (_nPosGer:=aScan(_aGerentes, {|x| LEFT(x[1],11) == LEFT(SC6->C6_PRODUTO ,11) .AND. x[3] == SC6->C6_LOCAL .AND. x[5] == SC5->C5_VEND3 })) > 0
           //    _nReservGer:=_aGerentes[_nPosGer,11]
           //ELSE
           //    _nReservGer:=0
           //ENDIF
            //            Disponivel      //- reservas dos gerentes + reserva do gerente do pedidos posicinado
            _nSaldoDisp:=_aSB2[_nPos][06] //- _aSB2[_nPos][12]    //+ _nReservGer

            IF _cRet = "LBOK"//REALIZA O CONSUMO DA SB2  *** MARCA ***

                IF _nSaldoDisp >= SC6->C6_QTDVEN //.AND. (_nReservGer = 0 .OR. _nReservGer > SC6->C6_QTDVEN) // SE TEM ESTOQUE
                   
                   _aSB2[_nPos][06]-= SC6->C6_QTDVEN // (SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QEMP) // DISPONIVEL
                   
                    //IF _nPosGer > 0
                    //   _aSB2[_nPos][12]       -= SC6->C6_QTDVEN // TIRA DA RESERV GERAL  1UM
                    //   _aGerentes[_nPosGer,08]-= SC6->C6_UNSVEN // TIRA DA Saldo GERENTE 2um 
                    //   _aGerentes[_nPosGer,11]-= SC6->C6_QTDVEN // TIRA DA Saldo GERENTE 1um 
                    //ENDIF
                   
                   _aSC6_do_PV[2][_nY,2]:=.T. //MARCA O ITEM QUE TEM ESTOQUE PARA GRAVAR ZY8 (MOMS66ZY8 ())
    
                    //BOTÃO: "VER / CORTAR Itens Pedido""
                    _nQtdeATend := SC6->C6_QTDVEN
                    _nQtdeFalta := 0
                    _nPesoFalta := 0

                    //CARREGA FATOR DE CONVERSÃO SE EXISTIR
                    _nfator := 1
                    If SB1->(Dbseek(xfilial("SB1")+SC6->C6_PRODUTO))
                       If SB1->B1_CONV == 0
                          If SB1->B1_I_QQUEI == 'S' .and. SB1->B1_I_FATCO > 0
                                _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_I_FATCO,SB1->B1_I_FATCO)
                          Endif
                       Else
                          _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_CONV,SB1->B1_CONV)
                       Endif
                    Endif			    
                    //BOTÃO: "VER / CORTAR Itens Pedido""
                    _aSC6_do_PV[2][_nY,3]:=(_nQtdeATend*_nfator)
                    _aSC6_do_PV[2][_nY,4]:=_nQtdeFalta
                    _aSC6_do_PV[2][_nY,5]:=_nPesoFalta

                ELSE
                     
                    _lTemEstoque:=.F.
                    _cProdSEst  +=_ENTER+ALLTRIM(SC6->C6_PRODUTO)+"/ Qtde "+ALLTRIM(TRANS(SC6->C6_QTDVEN,"@E 999,999,999,999.999")) +" > Saldo "+ALLTRIM(TRANS(_nSaldoDisp,"@E 999,999,999,999.999"))
                
                ENDIF
                
            ELSEIF _cRet = "LBNO"//ACRESCENTA NO ESTOQUE DE VOLTA *** DESMARCA ***

                _aSB2[_nPos][06]+= SC6->C6_QTDVEN // (SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QEMP) // DISPONIVEL			    
                //IF _nPosGer > 0
                //   _aSB2[_nPos][12]       += SC6->C6_QTDVEN // SOMA DA RESERV GERAL  1UM
                //   _aGerentes[_nPosGer,08]+= SC6->C6_UNSVEN // SOMA DA Saldo GERENTE 2um 
                //   _aGerentes[_nPosGer,11]+= SC6->C6_QTDVEN // SOMA DA Saldo GERENTE 1um 
                //ENDIF

                //BOTÃO: "VER / CORTAR Itens Pedido""
                _aSC6_do_PV[2][_nY,3]:=0//_nQtdeATend
                _aSC6_do_PV[2][_nY,4]:=0//_nQtdeFalta
                _aSC6_do_PV[2][_nY,5]:=0//_nPesoFalta

                //_aTelaPedidos[_nX,_nPosObs]:="(D) "+_aTelaPedidos[_nX,_nPosObs]
            ENDIF
        ELSE
            U_ITMSG("Pedido / Produto / Local: "+SC6->C6_NUM+" / "+ALLTRIM(SC6->C6_PRODUTO)+" / "+SC6->C6_LOCAL+" não encontrado no estoque (_aSB2).",'Atenção!',"Faça o reprocessamento ou/e entre em contato com o TI.",1)
            RETURN .F.//// SAIR SEM FAZER NADA  *****************
        ENDIF
NEXT 

/////////////   VINCULADOS  /////////////
//VER SE TEM PEDIDO VINVCULADO TESTA AQUI JUNTO COM O OUTRO PEDIDO
nPosVinc:=0
IF (nPosVinc:=ASCAN(_aTelaPedidos,{|aPed| aPed[_nPosPed] == SC5->C5_I_PEVIN } ) ) > 0 ;//PROCURA O PEDIDO VINCULADO NA _ATELAPEDIDOS
             .AND. !_aTelaPedidos[nPosVinc,nPosCar] $ LEGENDAS_ABCP
   
   _aSC6doVinc:=ACLONE(_aTelaPedidos[nPosVinc][_nPosRecnos])
   
   SC5->(DbGoTo(_aSC6doVinc[1]))//PEDIDO VINCULADO
   _cPedAtual:=SC5->C5_FILIAL+SC5->C5_NUM
   IF !SC5->(DBSEEK( _cPedAtual)) //PEDIDO QUE NÃO EXISTE MAIS NESSA FILIAL
      _aTelaPedidos[nPosVinc,nPosCar] := "BR_AMARELO"
      _aTelaPedidos[nPosVinc,_nPosObs]:= "Pedido não existe mais nessa filial: "+SC5->C5_FILIAL+" "+SC5->C5_NUM+". FAÇA O REPROCESSAMENTO."
      U_ITMSG("Pedido vinculado não existe mais nessa filial: "+SC5->C5_FILIAL+" "+SC5->C5_NUM,'Atenção!',"Faça o reprocessamento ou tente marca novamente esse pedido.",1)
      RETURN .F.
   ENDIF

   FOR _nY := 1 TO Len(_aSC6doVinc[2]) // LOOP NO ITENS DO PEDIDO VINCULADO
        
        SC6->(DBGOTO(_aSC6doVinc[2][_nY,1]))
        If SC6->(Deleted())
           LOOP
        ENDIF    	
        
        IF _cRet = "LBOK"//REALIZA O CONSUMO DA SB2 *** MARCA ***

            IF (_nPos:=aScan(_aSB2, {|x| x[1] == SC6->C6_FILIAL .AND. x[2] == SC6->C6_PRODUTO .AND. x[7] = SC6->C6_LOCAL })) > 0 				

               //IF (_nPosGer:=aScan(_aGerentes, {|x| LEFT(x[1],11) == LEFT(SC6->C6_PRODUTO ,11) .AND. x[3] == SC6->C6_LOCAL .AND. x[5] == SC5->C5_VEND3 })) > 0
               //    _nReservGer:=_aGerentes[_nPosGer,11]//1UM
               //ELSE
               //    _nReservGer:=0
               //ENDIF
                //            Disponivel      //- reservas dos gerentes + reserva do gerente do pedidos posicinado
                _nSaldoDisp:=_aSB2[_nPos][06] //- _aSB2[_nPos][12]    //+ _nReservGer

               _aSB2[_nPos][09] += SC6->C6_UNSVEN //Quantidade Carteira na 2ª UM - itens do pedido // SOMTORIA TODAS AS BOLINHAS

               IF _nSaldoDisp  >= SC6->C6_QTDVEN //.AND. (_nReservGer = 0 .OR. _nReservGer > SC6->C6_QTDVEN) // <<<<<<<<<<<<<<<<<<<<<<<<<<<
                  
                  _aSB2[_nPos][06] -= SC6->C6_QTDVEN // SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QEMP // DISPONIVEL
                  //IF _nPosGer > 0
                  //   _aSB2[_nPos][12]       -= SC6->C6_QTDVEN // TIRA DA RESERVA GERAL 1UM
                  //   _aGerentes[_nPosGer,08]-= SC6->C6_UNSVEN // TIRA DA SALDO GERENTE 2UM 
                  //   _aGerentes[_nPosGer,11]-= SC6->C6_QTDVEN // TIRA DA SALDO GERENTE 1UM 
                  //ENDIF

                   _aSC6doVinc[2][_nY,2]:=.T. //Marca o item que TEM ESTOQUE PARA Gravar ZY8 (MOMS66ZY8 ())

                    //BOTÃO: "VER / CORTAR Itens Pedido""
                    _nQtdeATend := SC6->C6_QTDVEN
                    _nQtdeFalta := 0
                    _nPesoFalta := 0
                   
                   //CARREGA FATOR DE CONVERSÃO SE EXISTIR
                   _nfator := 1
                   If SB1->(Dbseek(xfilial("SB1")+SC6->C6_PRODUTO))
                      If SB1->B1_CONV == 0
                         If SB1->B1_I_QQUEI == 'S' .and. SB1->B1_I_FATCO > 0
                               _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_I_FATCO,SB1->B1_I_FATCO)
                         Endif
                      Else
                         _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_CONV,SB1->B1_CONV)
                      Endif
                   Endif			
                   //BOTÃO: "VER / CORTAR Itens Pedido""
                   _aSC6doVinc[2][_nY,3]:=(_nQtdeATend*_nfator)
                   _aSC6doVinc[2][_nY,4]:=(_nQtdeFalta*_nfator)//QTDE FALTANTE
                   _aSC6doVinc[2][_nY,5]:=_nPesoFalta

                ELSE

                    _lTemEstoque:=.F.
                    _cProdSEst  +=_ENTER+ALLTRIM(SC6->C6_PRODUTO)+"/ Qtde "+ALLTRIM(TRANS(SC6->C6_QTDVEN,"@E 999,999,999,999.999")) +" > Saldo "+ALLTRIM(TRANS(_nSaldoDisp,"@E 999,999,999,999.999"))+" (V)"

                ENDIF
                
            ENDIF

        
        ELSEIF _cRet = "LBNO"//ACRESCENTA NO ESTOQUE DE VOLTA  *** DESMARCA ***
           
            _aSB2[_nPos][06]+= SC6->C6_QTDVEN // (SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QEMP) // DISPONIVEL			    
            //IF _nPosGer > 0
            //   _aSB2[_nPos][12]       += SC6->C6_QTDVEN // SOMA DA RESERV GERAL  1UM
            //   _aGerentes[_nPosGer,08]+= SC6->C6_UNSVEN // SOMA DA Saldo GERENTE 2um 
            //   _aGerentes[_nPosGer,11]+= SC6->C6_QTDVEN // SOMA DA Saldo GERENTE 1um 
            //ENDIF
            //BOTÃO: "VER / CORTAR Itens Pedido""
            _aSC6doVinc[2][_nY,3]:=0//_nQtdeATend
            _aSC6doVinc[2][_nY,4]:=0//_nQtdeFalta
            _aSC6doVinc[2][_nY,5]:=0//_nPesoFalta

            //_aTelaPedidos[nPosVinc,_nPosObs]:="(D) "+_aTelaPedidos[nPosVinc,_nPosObs]
        
       ENDIF     

   NEXT _nY
  
ENDIF
/////////////   VINCULADOS  /////////////

IF !_lTemEstoque 

   _aSB2:= MOMS66aSB2(_aSB2,"VOLTA") //VOLTA O ESTOQUE COMO ESTAVA
   U_ITMSG("SEM ESTOQUE PARA OS PRODUTOS: "+_cProdSEst,'Atenção!',"Desmarque outro Pedido que tenha esses itens, para obter mais saldo.",1)

   RETURN .F.//// SAIR SEM FAZER NADA  *****************

ENDIF
///////////////////////////////////////////////  ESTOQUE  ///////////////////////////////////////////////


///////////////////////////////////////////////  CAPACIDADE  ///////////////////////////////////////////////
_lPalitizada   :=_aTelaPedidos[_nX][_nPosTPCA] = "1"  //C5_I_TIPCA
_nPedTotPalete :=_aTelaPedidos[_nX][_nPosPalete]      //QTDE DE PALETES DO PEDIDO 
_nPesoPedido   :=_aTelaPedidos[_nX][_nPosPesBru]      //SC5->C5_I_PESBR
IF nPosVinc > 0 
  _nPedTotPalete+=_aTelaPedidos[nPosVinc][_nPosPalete]//QTDE DE PALETES DO PEDIDO 
  _nPesoPedido  +=_aTelaPedidos[nPosVinc][_nPosPesBru]//SC5->C5_I_PESBR
ENDIF
_lTemCapacidade:=.T.

IF _cRet = "LBOK"//REALIZA O CONSUMO DA CAPACIDADE *** MARCA ***

   IF _lPalitizada//***********************************************  COM PALETE  **********************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************
      
      _nTotPalsLib +=_nPedTotPalete //+++++++++++++++++++++++++ SOMA  +++++++++++++++++++++++++
      
      IF _nTotPalsLib <= _nPaleCapacFil//LIIMITE DA CAPACIDADE DE PALETES DA FILIAL
      
         _lTemCapacidade:=.T.
         IF nPosVinc <> 0//Pedido Vinculdo se tiver
            _cObs:="Pedido ("+_aTelaPedidos[nPosVinc,_nPosPed]+"+"+_aTelaPedidos[nPosVinc,_nPosPedVin]+") DENTRO da capacidade: "+ALLTRIM(TRANS((_nTotPalsLib-_nPedTotPalete),"@E 999,999,999,999"))+" + "+ALLTRIM(TRANS( _nPedTotPalete,"@E 999,999,999,999"))+" ) < "+ALLTRIM(TRANS( _nPaleCapacFil,"@E 999,999,999,999")+" Paletes ")
         ELSE
             _cObs:="Pedido DENTRO da capacidade: "+ALLTRIM(TRANS((_nTotPalsLib-_nPedTotPalete),"@E 999,999,999,999"))+" + "+ALLTRIM(TRANS( _nPedTotPalete,"@E 999,999,999,999"))+" ) < "+ALLTRIM(TRANS( _nPaleCapacFil,"@E 999,999,999,999")+" Paletes ")
         ENDIF   
      
      ELSE
        
         _lTemCapacidade:=.F.
         IF nPosVinc <> 0//Pedido Vinculdo se tiver
            U_ITMSG("Pedidos ("+_aTelaPedidos[_nX,_nPosPed]+"+"+_aTelaPedidos[_nX,_nPosPedVin]+") FORA da capacidade: ( "+ALLTRIM(TRANS((_nTotPalsLib-_nPedTotPalete),"@E 999,999,999,999"))+" + "+ALLTRIM(TRANS( _nPedTotPalete,"@E 999,999,999,999"))+" ) > "+ALLTRIM(TRANS( _nPaleCapacFil,"@E 999,999,999,999"))+" Paletes ",'Atenção!',"Desmarque outro Pedido que tenha esses itens, para obter mais capacidade.",1)
         ELSE
            U_ITMSG("Pedido FORA da capacidade: ( "+ALLTRIM(TRANS((_nTotPalsLib-_nPedTotPalete),"@E 999,999,999,999"))+" + "+ALLTRIM(TRANS( _nPedTotPalete,"@E 999,999,999,999"))+" ) > "+ALLTRIM(TRANS( _nPaleCapacFil,"@E 999,999,999,999"))+" Paletes ",'Atenção!',"Desmarque outro Pedido que tenha esses itens, para obter mais capacidade.",1)
         ENDIF
   
         _nTotPalsLib -=_nPedTotPalete//------------------- DIMIMINUI O QUE SOMOU ACIMA -------------------
   
      ENDIF
   
   ELSE//***********************************************  SEM PALETE / POR PESO **********************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************
   
      _nTotPesoLib +=_nPesoPedido//+++++++++++++++++++++++++ SOMA +++++++++++++++++++++++++
      
      IF _nTotPesoLib <= _nPesoCapacFil//LIIMITE DA CAPACIDADE DE PESO DA FILIAL
         _lTemCapacidade:=.T.
         
         IF nPosVinc <> 0//PEDIDO VINCULDO SE TIVER
            _cObs:="Pedido ("+_aTelaPedidos[nPosVinc,_nPosPed]+"+"+_aTelaPedidos[nPosVinc,_nPosPedVin]+") DENTRO da capacidade: "+ALLTRIM(TRANS((_nTotPesoLib-_nPesoPedido),"@E 999,999,999,999"))+" + "+ALLTRIM(TRANS( _nPesoPedido,"@E 999,999,999,999"))+" ) < KG "+ALLTRIM(TRANS( _nPesoCapacFil,"@E 999,999,999,999"))//+IF(!EMPTY(_aTelaPedidos[nPosVinc,_nPosObs])," / "+_aTelaPedidos[nPosVinc,_nPosObs],"")
         ELSE
            _cObs:="Pedido DENTRO da capacidade: "+ALLTRIM(TRANS((_nTotPesoLib-_nPesoPedido),"@E 999,999,999,999"))+" + "+ALLTRIM(TRANS( _nPesoPedido,"@E 999,999,999,999"))+" ) < KG "+ALLTRIM(TRANS( _nPesoCapacFil,"@E 999,999,999,999"))
         ENDIF
      ELSE
         _lTemCapacidade:=.F.

         IF nPosVinc <> 0//PEDIDO VINCULDO SE TIVER
            U_ITMSG("Pedidos ("+_aTelaPedidos[_nX,_nPosPed]+"+"+_aTelaPedidos[_nX,_nPosPedVin]+") FORA da capacidade: ( "+ALLTRIM(TRANS((_nTotPesoLib-_nPesoPedido),"@E 999,999,999,999"))+" + "+ALLTRIM(TRANS( _nPesoPedido,"@E 999,999,999,999"))+" ) > KG "+ALLTRIM(TRANS( _nPesoCapacFil,"@E 999,999,999,999")),'Atenção!',"Desmarque outro Pedido que tenha esses itens, para obter mais capacidade.",1)
         ELSE
            U_ITMSG("Pedido FORA da capacidade: ( "+ALLTRIM(TRANS((_nTotPesoLib-_nPesoPedido),"@E 999,999,999,999"))+" + "+ALLTRIM(TRANS( _nPesoPedido,"@E 999,999,999,999"))+" ) > KG "+ALLTRIM(TRANS( _nPesoCapacFil,"@E 999,999,999,999")),'Atenção!',"Desmarque outro Pedido que tenha esses itens, para obter mais capacidade.",1)
         ENDIF
   
         _nTotPesoLib -=_nPesoPedido//------------------- DIMINMUI O QUE SOMOU ACIMA -------------------
   
      ENDIF
   ENDIF

ELSEIF _cRet = "LBNO"//ACRESCENTA NO ESTOQUE DE VOLTA  *** DESMARCA ***

   IF _lPalitizada
      _nTotPalsLib -=_nPedTotPalete
   ELSE
      _nTotPesoLib -=_nPesoPedido
   ENDIF
   
   _aTelaPedidos[_nX,_nPosObs]:="(D) "+STRTRAN(_aTelaPedidos[_nX,_nPosObs],"(M) ", "")//(M) DE MARCADO / (D) DE DESMARCADO
   IF nPosVinc > 0 //PEDIDO VINCULDO SE TIVER
      _aTelaPedidos[nPosVinc,nPosOK     ]:=_cRet
      _aTelaPedidos[nPosVinc,nPosOK2    ]:=_cRet
      _aTelaPedidos[nPosVinc,_nPosObs   ]:="(D) "+STRTRAN(_aTelaPedidos[nPosVinc,_nPosObs],"(M) ", "")//(M) DE MARCADO / (D) DE DESMARCADO
   ENDIF
   
   IF !EMPTY(_aTelaPedidos[_nX][nPosC1])
      _cCodCarga:=_aTelaPedidos[_nX][nPosC1]
      FOR _nY := 1 TO Len(_aTelaPedidos)// LOOP NOS PEDIDOS
          IF _aTelaPedidos[_nY,nPosC1] = _cCodCarga
             _aTelaPedidos[_nY,nPosC1]:="  "//LIMPA A MARCACOES DA CARGAS C1 ou C2 ou C3...
          ENDIF
      NEXT   
   ENDIF

   RETURN .T. //***************** SAIDA NO DESMARCA ***************** 

ENDIF     

IF !_lTemCapacidade
   _aSB2:= MOMS66aSB2(_aSB2,"VOLTA") //VOLTA O ESTOQUE COMO ESTAVA
   RETURN .F. // SAIR SEM FAZER NADA  *****************
ENDIF

_aTelaPedidos[_nX,_nPosRecnos]:=_aSC6_do_PV
_aTelaPedidos[_nX,nPosCar    ]:="ENABLE"     //COLUNA CARREGAMENTO
_aTelaPedidos[_nX,_nPosEst   ]:="ENABLE"     //COLUNA ESTOQUE
_aTelaPedidos[_nX,_nPosCap   ]:="ENABLE"     //COLUNA CAPACIDADE
_aTelaPedidos[_nX,_nPosObs   ]:="(M) "+_cObs //(M) DE MARCADO
IF nPosVinc > 0 //PEDIDO VINCULDO SE TIVER
   _aTelaPedidos[nPosVinc,_nPosRecnos]:=_aSC6doVinc
   _aTelaPedidos[nPosVinc,nPosOK     ]:=_cRet
   _aTelaPedidos[nPosVinc,nPosOK2    ]:=_cRet
   _aTelaPedidos[nPosVinc,nPosCar    ]:="ENABLE"    // COLUNA CARREGAMENTO
   _aTelaPedidos[nPosVinc,_nPosEst   ]:="ENABLE"    // COLUNA ESTOQUE
   _aTelaPedidos[nPosVinc,_nPosCap   ]:="ENABLE"    // COLUNA CAPACIDADE
   _aTelaPedidos[nPosVinc,_nPosObs   ]:="(M) "+_cObs//(M) DE MARCADO
ENDIF

RETURN .T. //******** SAIDA DA MARCACAO *********


/*
===============================================================================================================================
Programa----------: MOMS66VCarga
Autor-------------: Alex Wallauer
Data da Criacao---: 18/03/2024
===============================================================================================================================
Descrição---------: VALIDA OS PEDIDOS MARCADOS NAS MESO PARA FORMAR UMA CARGA
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T. ou .F.
===============================================================================================================================*/
Static Function MOMS66VCarga()
LOCAL _nX           :=0
LOCAL _nLMesoPesoLib:=0
LOCAL _nLMesoPalsLib:=0
LOCAL _lCargaOK     :=.F.
LOCAL _cTipCarga    :=""
LOCAL _cCodCarga    :=""//C1,C2,C3,C4...

IF !lClicouMarca
   RETURN .F. 
ENDIF

IF !MOMS66Acesso()
   RETURN .F.
ENDIF

IF (oMsMGet:=MOMS66Obj()) = NIL 
   RETURN .F.
ENDIF

_aTelaPedidos:=oMsMGet:aCols

FOR _nX := 1 TO LEN(_aTelaPedidos)

     IF _aTelaPedidos[_nX][nPosOK2] <> "LBOK" //COLUNA REAL
        LOOP
     ENDIF

     IF _aTelaPedidos[_nX][nPosC1] > _cCodCarga
        _cCodCarga:=_aTelaPedidos[_nX][nPosC1]
     ENDIF

     IF !EMPTY(_aTelaPedidos[_nX][nPosC1])
        LOOP
      ENDIF

     IF EMPTY(_cTipCarga)
        _cTipCarga :=_aTelaPedidos[_nX][_nPosTPDACA]
     ELSEIF _cTipCarga <>_aTelaPedidos[_nX][_nPosTPDACA]
        _cTipCarga:="DIFERENTE"
     ENDIF

     //IF _aTelaPedidos[_nX][_nPosTPCA] = "1" //C5_I_TIPCA
     //   _nTMesoPesoLib+=_aTelaPedidos[_nX][_nPosPalete]//Qtde de Paletes do Pedido 
     //ELSE
     //   _nTMesoPalsLib+=_aTelaPedidos[_nX][_nPosPesBru]//SC5->C5_I_PESBR 
     //ENDIF
     _nLMesoPalsLib+=_aTelaPedidos[_nX][_nPosPalete]//Qtde de Paletes do Pedido 
     _nLMesoPesoLib+=_aTelaPedidos[_nX][_nPosPesBru]//SC5->C5_I_PESBR 

NEXT

IF  (_cTipCarga = "DIFERENTE") //(_nTMesoPesoLib > 0 .AND. _nTMesoPalsLib > 0) .OR.
   U_ITMSG("Pedidos marcados devem ter o mesmo tipo de carga",'Atenção!',"Ex.: Carga Seca com Carga Seca , Refrigerada com Refrigerada... ",1)
   RETURN .F.// SAI AQUI
ENDIF

IF _nLMesoPalsLib > 0 .AND. INT(_nLMesoPalsLib) = _nLMesoPalsLib .AND. STRZERO(_nLMesoPalsLib,2,0) $ _cMultPall
   U_ITMSG("Carga Fechada com SUCESSO com "+STRZERO(_nLMesoPalsLib,2,0)+" Palete(s)",'Atenção!',"Cargas Palitizadas fecham com "+_cMultPall,2)
   _lCargaOK:=.T.
ENDIF

IF !_lCargaOK .AND. _nLMesoPesoLib > 0 .AND. STRZERO( ROUND((_nLMesoPesoLib/1000),0)  ,2,0) $ _cMultPeso 
   U_ITMSG("Carga Fechada com SUCESSO com "+STRZERO( ROUND((_nLMesoPesoLib/1000),0),2,0)+" Tonelada(s).",'Atenção!',"Cargas Batidas fecham com "+_cMultPeso,2)
   _lCargaOK:=.T.
ENDIF

IF _lCargaOK

   IF !EMPTY(_cCodCarga)
      _cCodCarga:=SOMA1(_cCodCarga)
   ELSE
      _cCodCarga:="C1"
   ENDIF

   FOR _nX := 1 TO LEN(_aTelaPedidos)
     IF _aTelaPedidos[_nX][nPosOK2] = "LBOK" //COLUNA REAL
        IF EMPTY(_aTelaPedidos[_nX][nPosC1])
           _aTelaPedidos[_nX][nPosC1] := _cCodCarga
        ENDIF
     ENDIF
   NEXT

ELSE
   
   _cMensagem:=""
   _cSolucao:=""
   IF _nLMesoPalsLib > 0
      _cMensagem:="Carga PALITIZADA ainda não fechou, esta com "+ALLTRIM(TRANS(_nLMesoPalsLib,"@E 9,999.999"))+" Palete(s). Tem que ser "+STRZERO(INT(_nLMesoPalsLib),2,0)+" sem sobras."
      _cSolucao :="Cargas PALITIZADAS fecham com "+_cMultPall+ " Palete(s)."
   ENDIF   
   IF _nLMesoPesoLib > 0 
      _cMensagem+=_ENTER+"Carga BATIDA ainda não fechou, esta com "+ALLTRIM(TRANS((_nLMesoPesoLib/1000),"@E 999,999.999"))+" Tonelada(s). Considera: "+STRZERO( ROUND((_nLMesoPesoLib/1000),0),2,0)
      _cSolucao +=_ENTER+"Cargas BATIDAS fecham com "+_cMultPeso+" Toneladas"
   ENDIF
   IF !EMPTY(_cMensagem)
      U_ITMSG(_cMensagem,'Atenção!',_cSolucao,2)
      RETURN .F. // SAI AQUI
   ENDIF

ENDIF

_cRQtdeCarrega:=" "//Se não tem marcados ou marcados sem coluna carga em branco : LIMPA
oSAYValCar:Refresh()

RETURN .T.

/*
===============================================================================================================================
Programa----------: MOMS66Reproc
Autor-------------: Alex Wallauer
Data da Criacao---: 18/03/2024
===============================================================================================================================
Descrição---------: VALIDA OS PEDIDOS MARCADOS NAS MESO PARA FORMAR UMA CARGA
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
Static Function MOMS66Reproc(oProc)
LOCAL P 

/////////////////////////// MARCADOS /////////////////////////// 
_aSB2Inic:={}
oProc:cCaption :="1/3 - Reprocessando marcados Cargas TOP1..."
ProcessMessages()
_aPedTOP1:=oBrwTOP1:aCols
_aPedTOP1:= MOMS66PC(_aPedTOP1,"M",.T.,.F.,,aFoders1[1])//ZERA A ARRAY _aSB2 NO PRIMEIRO PARA LER O ESTOQUE DE NOVO *********************

oProc:cCaption :="2/3 - Reprocessando marcados Cargas Fechadas..."
ProcessMessages()
_aPedCAFE:=oBrwCaFe:aCols
_aPedCAFE:= MOMS66PC(_aPedCAFE,"M",.F.,.F.,,aFoders1[2])

oProc:cCaption :="3/3 - Reprocessando marcados Pedidos Fora de Padrão..."
ProcessMessages()
_aPedFORA:=oBrwFORA:aCols
_aPedFORA:= MOMS66PC(_aPedFORA,"M",.F.,.F.,,aFoders1[3])

FOR P := 1 TO LEN(aPedsReg1)     
    oProc:cCaption :="1/5 - Reprocessando marcados  "+aFoldReg1[P]
    ProcessMessages()
    IF (nPos:=ASCAN(aBrowses, {|B| B[1] == aFoldReg1[P] } )) > 0
       oMsMGet:=aBrowses[nPos,2]
       _aPedPasta:=oMsMGet:aCols
       aPedsReg1[P]:= MOMS66PC(_aPedPasta,"M",.F.,.F.)   
    Endif
NEXT
FOR P := 1 TO LEN(aPedsReg2) 
    oProc:cCaption :="2/5 - Reprocessando marcados  "+aFoldReg2[P]
    ProcessMessages()
    IF (nPos:=ASCAN(aBrowses, {|B| B[1] == aFoldReg2[P] } )) > 0
       oMsMGet:=aBrowses[nPos,2]
       _aPedPasta:=oMsMGet:aCols
       aPedsReg2[P]:= MOMS66PC(_aPedPasta,"M",.F.,.F.)   
    Endif
NEXT
FOR P := 1 TO LEN(aPedsReg3) 
    oProc:cCaption :="3/5 - Reprocessando marcados  "+aFoldReg3[P]
    ProcessMessages()
    IF (nPos:=ASCAN(aBrowses, {|B| B[1] == aFoldReg3[P] } )) > 0
       oMsMGet:=aBrowses[nPos,2]
       _aPedPasta:=oMsMGet:aCols
       aPedsReg3[P]:= MOMS66PC(_aPedPasta,"M",.F.,.F.)   
    Endif
NEXT
FOR P := 1 TO LEN(aPedsReg4) 
    oProc:cCaption :="4/5 - Reprocessando marcados  "+aFoldReg4[P]
    ProcessMessages()
    IF (nPos:=ASCAN(aBrowses, {|B| B[1] == aFoldReg4[P] } )) > 0
       oMsMGet:=aBrowses[nPos,2]
       _aPedPasta:=oMsMGet:aCols
       aPedsReg4[P]:= MOMS66PC(_aPedPasta,"M",.F.,.F.)   
    Endif
NEXT
FOR P := 1 TO LEN(aPedsReg5) 
    oProc:cCaption :="5/5 - Reprocessando marcados  "+aFoldReg5[P]
    ProcessMessages()
    IF (nPos:=ASCAN(aBrowses, {|B| B[1] == aFoldReg5[P] } )) > 0
       oMsMGet:=aBrowses[nPos,2]
       _aPedPasta:=oMsMGet:aCols
       aPedsReg5[P]:= MOMS66PC(_aPedPasta,"M",.F.,.F.)   
    Endif
NEXT

/////////////////////////// DESMARCADOS /////////////////////////// ///////////////////////////////////////////////////////////////////////

_aSB2:=MOMS66aSB2(_aSB2,"SALVA")//SALVA ESTOQUE ANTES PAREA PROCESSAR CADA PASTA DOS DEMACADOS COM ESSA FOTO
_nBKPPesoLib  := _nTotPesoLib   //Salva totais  antes de processar cada pasta dos demacados
_nBKPPalsLib  := _nTotPalsLib   //Salva totais  antes de processar cada pasta dos demacados
_nBKPGerFin   := _nTotGerFin    //Salva totais  antes de processar cada pasta dos demacados
_nBKPNaoGerFin:= _nTotNaoGerFin //Salva totais  antes de processar cada pasta dos demacados

oProc:cCaption :="1/3 - Reprocessando desmarcados Cargas TOP1..."
ProcessMessages()
_aPedTOP1:= MOMS66PC(_aPedTOP1,"D",.F.,.T.,,aFoders1[1])

oProc:cCaption :="2/3 - Reprocessando desmarcados Cargas Fechadas..."
ProcessMessages()
_aPedCAFE:= MOMS66PC(_aPedCAFE,"D",.F.,.T.,,aFoders1[2])

oProc:cCaption :="3/3 - Reprocessando marcados Pedidos Fora de Padrão..."
ProcessMessages()
_aPedFORA:= MOMS66PC(_aPedFORA,"D",.F.,.T.,,aFoders1[3])

IF LEN(aPedsReg1) > 0//LEN(aFolderRGBR) >= 1 // CARGAS POR MESO DA REGIAO 1 ************************** //
   oProc:cCaption := ("1/5 - Reprocessando desmarcados: "+aFolderRGBR[1] )
   ProcessMessages()
   FOR P := 1 TO LEN(aPedsReg1) 
       _aPedPasta:=aPedsReg1[P]
       aPedsReg1[P]:= MOMS66PC(_aPedPasta,"D",.F.,.T.)   
   NEXT
ENDIF

IF LEN(aPedsReg2) > 0//CARGAS POR MESO DA REGIAO 2 ************************** //
   oProc:cCaption := ("2/5 - Reprocessando desmarcados: "+aFolderRGBR[2] )
   ProcessMessages()
   FOR P := 1 TO LEN(aPedsReg2) 
       _aPedPasta:=aPedsReg2[P]
       aPedsReg2[P]:= MOMS66PC(_aPedPasta,"D",.F.,.T.)   
   NEXT
ENDIF

IF LEN(aPedsReg3) > 0//CARGAS POR MESO DA REGIAO 3 ************************** //
   oProc:cCaption := ("3/5 - Reprocessando desmarcados: "+aFolderRGBR[3] )
   ProcessMessages()
   FOR P := 1 TO LEN(aPedsReg3) 
       _aPedPasta:=aPedsReg3[P]
       aPedsReg3[P]:= MOMS66PC(_aPedPasta,"D",.F.,.T.)   
   NEXT
ENDIF

IF LEN(aPedsReg4) > 0//CARGAS POR MESO DA REGIAO 4 ************************** //
   oProc:cCaption := ("4/5 - Reprocessando desmarcados: "+aFolderRGBR[4] )
   ProcessMessages()
   FOR P := 1 TO LEN(aPedsReg4) 
       _aPedPasta:=aPedsReg4[P]
       aPedsReg4[P]:= MOMS66PC(_aPedPasta,"D",.F.,.T.)   
   NEXT
ENDIF

IF LEN(aPedsReg5) > 0//CARGAS POR MESO DA REGIAO 5 ************************** //
   oProc:cCaption := ("5/5 - Reprocessando desmarcados: "+aFolderRGBR[5] )
   ProcessMessages()
   FOR P := 1 TO LEN(aPedsReg5) 
       _aPedPasta:=aPedsReg5[P]              
       aPedsReg5[P]:= MOMS66PC(_aPedPasta,"D",.F.,.T.)   
   NEXT
ENDIF
_lSomaPontFat := .F.            //Desliga aqui de novo pq o lZera dentro da funcao MOMS66PC () RELIGA
_aSB2:=MOMS66aSB2(_aSB2,"VOLTA")//RESTAURA AQUI PQ O ESTOQUE DOS DESMACARDOS É SIMULACAO
_nTotPesoLib  := _nBKPPesoLib   //RESTAURA AQUI PQ O ESTOQUE DOS DESMACARDOS É SIMULACAO
_nTotPalsLib  := _nBKPPalsLib   //RESTAURA AQUI PQ O ESTOQUE DOS DESMACARDOS É SIMULACAO
_nTotGerFin   := _nBKPGerFin    //RESTAURA AQUI PQ O ESTOQUE DOS DESMACARDOS É SIMULACAO
_nTotNaoGerFin:= _nBKPNaoGerFin //RESTAURA AQUI PQ O ESTOQUE DOS DESMACARDOS É SIMULACAO

_lEfetivar  := .T.//ATIVA BOTÃO GERAR
lClicouMarca:= .F.//Desativa a atualização na troca de pasta

RETURN .T.

/*
===============================================================================================================================
Programa----------: MOMS66Atu2
Autor-------------: Alex Wallauer
Data da Criacao---: 18/03/2024
===============================================================================================================================
Descrição---------: ATUALIZA OS PEDIDOS DESMARCADO DO BROWSE POSICIONADO
===============================================================================================================================
Parametros--------: oMsMGet,oProc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
Static Function MOMS66Atu2(oMsMGet,oProc)

IF !lClicouMarca
   RETURN .F. 
ENDIF

IF oMsMGet = NIL .AND. (oMsMGet:=MOMS66Obj()) = NIL 
   RETURN .F.
ENDIF
_aTelaPedidos := oMsMGet:aCols  //CARREGA
_aSB2:=MOMS66aSB2(_aSB2,"SALVA")//SALVA ESTOQUE ANTES PAREA PROCESSAR CADA PASTA DOS DEMACADOS COM ESSA FOTO
_nBKPPesoLib  := _nTotPesoLib   //SALVA TOTAIS  ANTES DE PROCESSAR CADA PASTA DOS DEMACADOS
_nBKPPalsLib  := _nTotPalsLib   //SALVA TOTAIS  ANTES DE PROCESSAR CADA PASTA DOS DEMACADOS
_nBKPGerFin   := _nTotGerFin    //SALVA TOTAIS  ANTES DE PROCESSAR CADA PASTA DOS DEMACADOS
_nBKPNaoGerFin:= _nTotNaoGerFin //SALVA TOTAIS  ANTES DE PROCESSAR CADA PASTA DOS DEMACADOS

_aTelaPedidos:= MOMS66PC(_aTelaPedidos,"D2",.F.,.T.,oProc)

_aSB2:=MOMS66aSB2(_aSB2,"VOLTA")  //RESTAURA AQUI PQ O ESTOQUE DOS DESMACARDOS É SIMULACAO
_nTotPesoLib  := _nBKPPesoLib     //RESTAURA AQUI PQ O ESTOQUE DOS DESMACARDOS É SIMULACAO
_nTotPalsLib  := _nBKPPalsLib     //RESTAURA AQUI PQ O ESTOQUE DOS DESMACARDOS É SIMULACAO
_nTotGerFin   := _nBKPGerFin      //RESTAURA AQUI PQ O ESTOQUE DOS DESMACARDOS É SIMULACAO
_nTotNaoGerFin:= _nBKPNaoGerFin   //RESTAURA AQUI PQ O ESTOQUE DOS DESMACARDOS É SIMULACAO
oMsMGet:aCols := _aTelaPedidos    //DEVOLVE ATUALIZADO

oMsMGet:oBrowse:Refresh()
oMsMGet:oBrowse:SetFocus()

RETURN .T.

/*
===============================================================================================================================
Programa----------: MOMS66aSB2
Autor-------------: Alex Wallauer
Data da Criacao---: 18/03/2024
===============================================================================================================================
Descrição---------: SALVA E VOLTA O SALDO DO PRODUTO DA _aSB2
                    POSICAO PARA SALVAR O SALDO ANTERIOR A SIMULACAO: INICIA IGUAL PQ NA SIMULACAO PODE TER ITENS NOVOS NA SIMULACAO
===============================================================================================================================
Parametros--------: _aSB2,cManut: "SALVA ou "VOLTA"
===============================================================================================================================
Retorno-----------: _aSB2
===============================================================================================================================*/
Static Function MOMS66aSB2(_aSB2,cManut)
LOCAL L
//Aadd(_aSB2, {SB2->B2_FILIAL ,;              //01 - FILIAL
//			   SB2->B2_COD    ,;              //02 - PRODUTO
//			   SB2->B2_QATU   ,;              //03 - 1UM
//			   SB2->B2_RESERVA,;              //04 - 1UM
//			   SB2->B2_QEMP   ,;              //05 - 1UM
//			   _nSaldoDisp    ,;>>>>>>>>>>>>  //06 - DISPONIVEL FINAL 1UM SÓ MAIOR OU IGUAL A ZERO  <<<<<<<<<<
//			   SB2->B2_LOCAL  ,;              //07 - ARMAZEM
//			   IF(_lSomaPTer,SB2->B2_QNPT,0),;//08 -  1UM
//			   0              ,;              //09 - Quantidade Carteira na 2ª UM (SOMTORIA BOLINHA VERDE)
//			   0              ,;              //10 - Saldo na 2ª UM (DISPONIVEL - BOLINHA VERDE) CALCULADO
//			   SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QEMP + IF(_lSomaPTer,SB2->B2_QNPT,0),;//11-DISPONIVEL INICIAL 1UM
//			   0              ,;              //12 - SOMATORIA DAS RESERVAS DOS GERENTES 1UM
//			   _nSaldoDisp    })<<<<<<<<<<<<  //13 - POSICAO PARA SALVAR O SALDO ANTERIOR A SIMULACAO: INICIA IGUAL PQ NA SIMULACAO PODE TER ITENS NOVOS  >>>>>>>
IF LEN(_aSB2) > 0

   FOR L := 1 TO LEN(_aSB2)
       IF cManut = "SALVA"
          _aSB2[L,13] := _aSB2[L,06] // SALVA O SALDO DE ANTES DA SIMULACAO
       ELSE//cManut = "VOLTA"
          _aSB2[L,06] := _aSB2[L,13] // VOLTA O SALDO DEPOIS DA SIMULACAO
       ENDIF
   NEXT
   
ENDIF

RETURN _aSB2

/*
===============================================================================================================================
Programa----------: MOMS66PreGrv
Autor-------------: Alex Walaluer
Data da Criacao---: 31/07/2024
===============================================================================================================================
Descrição---------: Funcao para fazer a gravação dos dados por grupo de pediso de uma carga da meso
===============================================================================================================================
Parametros--------: _aPedPasta,oProc,_cPasta
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/
STATIC Function MOMS66PreGrv(_aPedPasta,oProc,_cPasta)
LOCAL B
LOCAL _aPedsCarga:={}
       
FOR B := 1 TO LEN(_aPedPasta) 
   //PASTAS DAS MESORREGIÕES COM CARGA VALIDADA
   IF _aPedPasta[B,nPosCar] == "ENABLE" .AND.;//CARREGAR SIM 
     _aPedPasta[B,nPosOK2] == "LBOK"   .AND.;//MARCADO REAL
     !EMPTY(_aPedPasta[B][nPosC1])           //MARCADO COM CARGA VALIDADA
     IF (nPos:=ASCAN(_aPedsCarga,{|P| P[1] == _aPedPasta[B][nPosC1]})) = 0 
        AADD(_aPedsCarga,{_aPedPasta[B][nPosC1],{ _aPedPasta[B] } , "GERAR" })//M->C5_I_AGRUP
     ELSE
        AADD(_aPedsCarga[nPos,2], _aPedPasta[B] )
     ENDIF
   ELSE
     IF (nPos:=ASCAN(_aPedsCarga,{|P| P[1] == "SEMCARGA" })) = 0 
        AADD(_aPedsCarga,{ "SEMCARGA" ,{ _aPedPasta[B]  } , " " })
     ELSE
        AADD(_aPedsCarga[nPos,2], _aPedPasta[B] )
     ENDIF
   Endif		  
NEXT
FOR B := 1 TO LEN(_aPedsCarga)
    BEGIN TRANSACTION
     IF _aPedsCarga[B,3] == "GERAR"
        IF SC5->(FIELDPOS("C5_I_AGRUP")) > 0
           _aPedsCarga[B,3]:= U_RetCodGru()//Gera codigo do C5_I_AGRUP
        ENDIF
     ENDIF
     MOMS66Grv(_aPedsCarga[B,2],oProc,.T.,_cPasta,_aPedsCarga[B,3])
    END TRANSACTION
NEXT

RETURN .T.
/*
===============================================================================================================================
Programa----------: RetCodGru
Autor-------------: Alex Walaluer
Data da Criacao---: 30/07/2024
===============================================================================================================================
Descrição---------: Funcao utilizada para retornar o codigo do grupo de pedidods de uma Carga.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _cCodigo: Grava no campo C5_I_AGRUP
===============================================================================================================================
*/
User Function RetCodGru()//Grava no campo C5_I_AGRUP

Local _cQuery   := ""
Local _cAlias:= GetNextAlias()  
Local _cCodigo  := ""

_cQuery := " SELECT COALESCE( MAX( C5_I_AGRUP ) , '0' ) CODIGO "
_cQuery += " FROM " + RetSqlName("SC5") + " "
_cQuery += " WHERE	D_E_L_E_T_	= ' ' "

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )
DBSelectArea(_cAlias)
(_cAlias)->( DBGotop() )

If AllTrim( (_cAlias)->CODIGO ) == '0'
   _cCodigo := '000001'
Else  
   _cCodigo :=  Soma1( (_cAlias)->CODIGO) 
EndIf

DO While !MayIUseCode( "C5_I_AGRUP"+_cCodigo )	        //verifica se esta na memoria, sendo usado
   _cCodigo :=  Soma1(_cCodigo) 	// busca o proximo numero disponivel
EndDo

(_cAlias)->( DBCloseArea() )

Return( _cCodigo ) //Grava no campo C5_I_AGRUP

/*
===============================================================================================================================
Programa--------: MOMS66CLB
Autor-----------: Alex Wallauer
Data da Criacao-: 28/06/2022
===============================================================================================================================
Descrição-------: Se Considerar liberação de estoque? = SIM Monta a tela para pegar as quantidade de estoque
===============================================================================================================================
Parametros------: _aTelaPedidos
===============================================================================================================================
Retorno---------: NENHUM
===============================================================================================================================*/
STATIC FUNCTION MOMS66CLB(_aTelaPedidos,oProc)
LOCAL _nX := 0 , L
LOCAL _nY := 0
LOCAL _lSomaPTer:= .F.
LOCAL _aSB2:={}
LOCAL _cTotGeral:=ALLTRIM(STR(Len(_aTelaPedidos)))

SB1->(DbSetOrder(1))
SB2->(DbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL
nConta:=0

FOR _nX := 1 TO Len(_aTelaPedidos)

   nConta++
   oProc:cCaption := ("2.1-Analizando Estoques - "+STRZERO(nConta,5) +" de "+ _cTotGeral )
   ProcessMessages()

    IF _aTelaPedidos[_nX,nPosCar]  $ LEGENDAS_ABCP
       LOOP
    ENDIF

    _aSC6_do_PV:=_aTelaPedidos[_nX][_nPosRecnos]

    FOR _nY := 1 TO Len(_aSC6_do_PV[2])
        SC6->(DbGoTo(_aSC6_do_PV[2][_nY,1]))
        If SC6->(Deleted())
           LOOP
        ENDIF

        IF SB2->(DbSeek(SC6->C6_FILIAL+SC6->C6_PRODUTO+SC6->C6_LOCAL)) .AND.;
           SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO)) .AND. SB1->B1_TIPO = 'PA'.AND. ;
           (aScan(_aSB2, {|x| x[1] == SB2->B2_COD .AND. x[3] == SB2->B2_LOCAL})) = 0
        
           //Carrega fator de conversão se existir
           _nfator := 1
           If SB1->(Dbseek(xfilial("SB1")+SC6->C6_PRODUTO))
              If SB1->B1_CONV == 0
                 If SB1->B1_I_QQUEI == 'S' .and. SB1->B1_I_FATCO > 0
                      _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_I_FATCO,SB1->B1_I_FATCO)
                 Endif
              Else
                 _nfator := IF(SB1->B1_TIPCONV=="D", 1/SB1->B1_CONV,SB1->B1_CONV)
              Endif
           Endif

           _cDescricao   := ALLTRIM(SB1->B1_DESC)
           _lSomaPTer    := (SC6->C6_FILIAL $ _cFilTer .And. SC6->C6_LOCAL $ _cLocTer)
           _nSaldoDisp   := SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QEMP + IF(_lSomaPTer,SB2->B2_QNPT,0)
           _nSaldoDisp   := _nSaldoDisp*_nfator
           _nPoderTer    := IF(_lSomaPTer,SB2->B2_QNPT,0)
           _nPoderTer    := _nPoderTer*_nfator
           IF SB2->(FIELDPOS("B2_I_QLIBE")) > 0
              M->B2_I_QLIBE := SB2->B2_I_QLIBE
              M->B2_2_QLIBE := SB2->B2_I_QLIBE*_nfator
           ELSE
              M->B2_I_QLIBE := 0
              M->B2_2_QLIBE := 0
           ENDIF

           AADD(_aSB2, {SB2->B2_COD    ,;//01 - PRODUTO
                        _cDescricao    ,;//02 - DESCRICAO DO PRODUTO
                        SB2->B2_LOCAL  ,;//03 - ARMAZEM
                        SC6->C6_SEGUM  ,;//04 - 2 UM 
                        M->B2_2_QLIBE  ,;//05 - 2 UM B2_I_QLIBE
                        SC6->C6_UM     ,;//06 - 1 UM 
                        M->B2_I_QLIBE  ,;//07 - 1 UM B2_I_QLIBE
                        _nSaldoDisp    ,;//08 - Disponivel Final 2 UM 
                        _nPoderTer     ,;//09 - Poder de 3o em 2 UM
                        SB2->(RECNO()) ,;//10 - Registro do SB2
                        .F.            })//11 - Coluna de delecao
       ENDIF
    
    NEXT 

NEXT _nX

aHeader2:={}
//                     1                  2             3                            4          5        6        7       8       9       10          11      12        13       14         15        16   17
//dd(aHeader2,{trim(x3_titulo)     ,x3_campo    ,x3_picture                 ,x3_tamanho,x3_decimal,x3_valid,x3_usado,x3_tipo, x3_f3,x3_context,	x3_cbox,x3_relacao,x3_when,X3_TRIGGER,	X3_PICTVAR,.F.,.F.})
Aadd(aHeader2,{"Produto"           ,"WK_PRODUT ","@!"                       ,13,0,"            ","","C","      ","","","",".F."})//01    
nPosProde := LEN(aHeader2)
Aadd(aHeader2,{"Descricao"         ,"WK_DESCRIT","@!"                       ,45,0,"            ","","C","      ","","","",".F."})//02
Aadd(aHeader2,{"Armazem"           ,"WK_LOCAL"  ,"@!"                       ,02,0,"            ","","C","      ","","","",".F."})//03    
Aadd(aHeader2,{"2 UM"              ,"C6_SEGUM"  ,"@!"                       ,03,0,"            ","","C","      ","","","",".F."})//04    
Aadd(aHeader2,{"Qtde Liberada 2 UM","B2_2_QLIBE","@E 9,999,999,999,999.9999",18,4,"U_M66Valid()","","N","      ","","","",".T."})//05
nPos2QLIBE:= LEN(aHeader2)
Aadd(aHeader2,{"1 UM"              ,"C6_UM"     ,"@!"                       ,03,0,"            ","","C","      ","","","",".F."})//06    
Aadd(aHeader2,{"Qtde Liberada 1 UM","B2_1_QLIBE","@E 9,999,999,999,999.9999",18,4,"U_M66Valid()","","N","      ","","","",".T."})//07    
nPosQLIBE := LEN(aHeader2)
Aadd(aHeader2,{"Disponivel 2 UM"    ,"WK_SALDOIT","@E 9,999,999,999,999.9999",18,4,"           ","","N","      ","","","",".F."})//08
nPosDispo := LEN(aHeader2)
Aadd(aHeader2,{"Em poder 3o 2 UM"  ,"WK_PODER3" ,"@E 9,999,999,999,999.9999",18,4,"            ","","N","      ","","","",".F."})//09
nPosPoder3:= LEN(aHeader2)
   
IF LEN(_aSB2) > 0
  _nGDAction:= GD_UPDATE 
ELSE
   U_ITMSG("Não há itens de PA com o filtro atual para poder ajustar.",'Atenção!',,1)
   RETURN 
ENDIF

   // pega tamanhos das telas
   _aSize := MsAdvSize()
   _aInfoG := { _aSize[1] , _aSize[2] , _aSize[3] , _aSize[4] , 1 , 1 }
   
   aGObjects := {}
   AAdd( aGObjects, { 100, 100, .T., .T. } )
   
   aPosGObj := MsObjSize( _aInfoG , aGObjects )

   _bEfetivar :={|| IF(U_ITMSG("Confirma GRAVACAO ?",'Atenção!',,2,2,2),(_lGrava:=.T.,oDlgGer:End()),) }
   _bSair     :={|| (_lGrava:=.F.,oDlgGer:End())  }
   
   _cTitulo:="MANUTENÇÃO DO SALDO / FILIAL: "+cFilAnt
   
   DO WHILE .T.

      _lGrava:=.F.

      DEFINE MSDIALOG oDlgGer TITLE _cTitulo OF oMainWnd PIXEL FROM _aSize[7],0 TO _aSize[6],_aSize[5]

                                  //[ nTop]          , [ nLeft]   , [ nBottom] , [ nRight ] , [ nStyle]  ,cLinhaOk,cTudoOk,cIniCpos, [ aAlter], [ nFreeze], [ nMax], [ cFieldOk], [ cSuperDel], [ cDelOk], [ oWnd], [ aPartHeader], [ aParCols], [ uChange], [ cTela], [ aColsSize] 
         oMsMGetG := MsNewGetDados():New((aPosGObj[1,1]),aPosGObj[1,2],aPosGObj[1,3],aPosGObj[1,4],_nGDAction,        ,       ,        ,          ,           ,        ,            ,             ,          ,oDlgGer ,aHeader2       , _aSB2 ,)
       
        oDlgGer:lMaximized:=.T.
          
      ACTIVATE MSDIALOG oDlgGer ON INIT (EnchoiceBar(oDlgGer,_bEfetivar,_bSair,,) , oMsMGetG:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT )
   
      IF _lGrava 
         _aGerAux:=oMsMGetG:ACOLS
         nConta:=0
         nGravou:=0
         _cTotGeral:=ALLTRIM(STR(Len(_aGerAux)))
         FOR L := 1 TO LEN(_aGerAux)
             nConta++
             oProc:cCaption := ("2.2-Gravando Estoques - "+STRZERO(nConta,5) +" de "+ _cTotGeral )
             ProcessMessages()
             IF !aTail(_aGerAux[L])// Se Linha não Deletada
                nRecSB2:=_aGerAux[L][LEN(_aGerAux[L])-1]
                IF !EMPTY(nRecSB2)
                   SB2->(DBGOTO(nRecSB2))
                   IF SB2->B2_I_QLIBE <> _aGerAux[L][nPosQLIBE]
                      SB2->(RECLOCK("SB2",.F.))
                      SB2->B2_I_QLIBE:=_aGerAux[L][nPosQLIBE]
                      SB2->(MSUNLOCK())
                      nGravou++
                   ENDIF
                ENDIF
             ENDIF
         NEXT
         
         U_ITMSG(ALLTRIM(STR(nGravou))+" Produtos Gravados"+IF(nGravou>0," Gravados com Sucesso.","."),'Atenção!',,2)

      ENDIF
   
      EXIT

   ENDDO

RETURN

/*
1 - Potencial da carteira (Peso e valor): 
ZPP->ZPP_OK="LIBERADO" + ZPP->ZPP_OK="DESMARCADO"+ ZPP->ZPP_OK="REJEITADO" + ZPP->ZPP_OK="FALTAVOLUME" 

2 - Pedidos liberados (Peso e valor): 
ZPP->ZPP_OK="LIBERADO" + ZPP->ZPP_OK="REJEITADO"

3 - Pedidos não liberados (Peso e valor) com o motivo da não liberação Motivos:

3.1 - Falta de produto (vermelhos) //FALTA DE ESTOQUE
ZPP->ZPP_OK="FALTAESTOQUE"

3.2 - Falta de capacidade (Verdes com capacidade vermelho)
ZPP->ZPP_OK="FALTACAPACIDADE"

3.3 - Falta de formação de carga (Pedidos verdes apenas nas pastas das mesos)
ZPP->ZPP_OK="FALTAVOLUME"

3.4 - Decisão comercial (pedidos verdes nas pastas 1 e 2 que foram desmarcados)
ZPP->ZPP_OK="DESMARCADO"

*/
