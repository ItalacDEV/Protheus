/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
    Autor     |    Data    |                                             Motivo                                           
------------------------------------------------------------------------------------------------------------------------------- 
              |            |
=============================================================================================================================== 
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#include "PROTHEUS.ch"
#Include "FWMVCDef.Ch"

//Static _cChamada := "LINHA"
/*
===============================================================================================================================
Fun��o-------------: MOMS071
Autor--------------: Julio de Paula Paz
Data da Criacao----: 04/04/2024
===============================================================================================================================
Descri��o----------: Rotina para rodar em Scheduller e para excluir pedidos de vendas do portal rejeitados, ap�s um 
                     numeros de dias informados em par�metro. Chamado 41001.
===============================================================================================================================
Parametros---------: Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/  
User Function MOMS071()
Local _LigaDesWS

Begin Sequence

   //=============================================================================
   // Ativa a filial "01" apenas para exclus�o do Pedidos do Portal
   //=============================================================================
   RpcClearEnv()  // Fecha o ambiente caso esteja aberto.
   RpcSetType(2)  // Indica que o ambiente ser� aberto sem consumir licen�a.
   
   //=============================================================================
   // Inicia processamento com base nas filiais do par�metro.
   //=============================================================================
	U_ItConOut( '[MOMS071] -  Abrindo o ambiente para filial 01...' )
 
   //===========================================================================================
   // Preparando o ambiente com a filial 01
   //===========================================================================================
   RpcSetEnv("01", "01",,,"OMS",, {"SA2","SC5","SC6",'SZW', "ZZM"})

   Sleep( 5000 ) //Aguarda 5 segundos para subam as configura��es do ambiente.
   
   //========================================================================
   // Liga ou Desliga a exclus�o de pedidos de vendas rejeitados do portal.
   //========================================================================
   _LigaDesWS := U_ITGETMV('IT_LIGAEXPV', .T.) 
   If ! _LigaDesWS
      Break 
   EndIf 

   U_ItConOut( '[MOMS071] - Iniciando Schedule de Exclusao de Pedidos de Vendas do Portal')
   //=========================================================================
   // Roda a rotina Schechuduller de exclus�o de Pedidos de Vendas do Portal.
   //=========================================================================
   U_ItConOut( '[MOMS071D] - Efetuando a leitura dos dados. Localizando Pedidos de Vendas do Portal Rejeitados...')
   
   U_MOMS071D(.T.) // Efetura a leitura dos dados.
   
   //=========================================================================
   // Excluindo os pedidos de vendas do portal rejeitados conforme
   // per�odo informado em par�metro.
   //=========================================================================
   U_ItConOut( '[MOMS071D] - Exclui os pedidos de vendas, conforme leitura realizada.')

   U_MOMS071E(.T.) // Efetura a exclus�o dos Pedidos de Vendas, conforme leitura dos dados.

   U_ItConOut( '[MOMS071] - Finalizando schedule de Exclusao de Pedidos de Vendas do Portal ' )

 End Sequence 

If Select("TRBSZW") > 0
   TRBSZW->( DBCloseArea() )
EndIf

Return Nil 

 /*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Julio de Paula Paz
Data da Criacao---: 26/10/2023
===============================================================================================================================
Descri��o---------: Rotina de constru��o do menu
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina Title 'Pesquisar'  Action 'U_MOMS071P()'  OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Exclus�o PV Rejeitados do Portal'  Action 'U_MOMS071T()'  OPERATION 2 ACCESS 0

Return( aRotina )

/*
===============================================================================================================================
Programa----------: MOMS071P
Autor-------------: Julio de Paula Paz
Data--------------: 04/04/2024
===============================================================================================================================
Descri��o---------: Permite pesquisar um pedido de Vendas do Portal.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS071P()

Local _oGet1	  := Nil 
Local _oDlgP	  := Nil 
Local _cGet1	  := Space(60)
Local _nOpca	  := 0
Local _cComboBx1  := "Filial e Pedido"
Local _aComboBx1  := {"Filial e Pedido Portal","Filial e Pedido Protheus"}
Local _nRegAtu    := TRBSZW->(Recno())

Begin Sequence 

   DEFINE MSDIALOG _oDlgP TITLE "Pesquisar Pedido de Vendas Portal" FROM 178,181 TO 259,697 PIXEL

      @ 004,003 ComboBox	_cComboBx1	Items _aComboBx1 Size 213,010 OF _oDlgP PIXEL
	  @ 020,003 MsGet		_oGet1	Var _cGet1		Size 212,009 OF _oDlgP PIXEL COLOR CLR_BLACK Picture "@!"
	
	  DEFINE SBUTTON FROM 004,227 TYPE 1 ENABLE ACTION ( _nOpca := 1 , _oDlgP:End() ) OF _oDlgP
	  DEFINE SBUTTON FROM 021,227 TYPE 2 ENABLE ACTION ( _nOpca := 0 , _oDlgP:End() ) OF _oDlgP

   ACTIVATE MSDIALOG _oDlgP CENTERED

   If _nOpca == 1
      If ALLTRIM(_cComboBx1) == ALLTRIM(_aComboBx1[1])
         TRBSZW->(DbSetOrder(1))
      Else
         TRBSZW->(DbSetOrder(2))        
      EndIf 
   
      If ! TRBSZW->(MsSeek(RTrim(_cGet1)))
         U_ITMSG("Pedido de Vendas n�o encontrado.","Aten��o",,1)
         TRBSZW->(DbSetOrder(1))
         TRBSZW->(DbGoTo(_nRegAtu))
      Else
         _oMarkBRW:oBrowse:Refresh()
      EndIf 
   EndIf

End Sequence

Return .T. 

/*
===============================================================================================================================
Fun��o-------------: MOMS071T
Autor--------------: Julio de Paula Paz
Data da Criacao----: 04/04/2024
===============================================================================================================================
Descri��o----------: Rotina de Exclus�o de Pedidos de Vendas Rejeitados do Portal em Tela.
===============================================================================================================================
Parametros---------: Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/  
User Function MOMS071T()
Local _aFields := {}
Local _nDiasExPv := U_ITGETMV('IT_NDIASEXP', 7)

Private _oMarkBRW

Begin Sequence

   Processa( {|| U_MOMS071D()  } , "Efetuando Leitura dos Dados..." , "Aguarde!" )

   _aFields := {}
   aAdd( _aFields , { "Filial"		   , {|| TRBSZW->ZW_FILIAL }  , "C" , "@!" , 0 , 2		                   , 0 } )
   aAdd( _aFields , { "Pedido Portal"  , {|| TRBSZW->ZW_IDPED }	, "C" , "@!" , 0 , TamSX3("ZW_IDPED")[01]	 , 0 } )
   aAdd( _aFields , { "Dt.Emiss�o"	   , {|| TRBSZW->ZW_EMISSAO}	, "D" , "@!" , 0 , 8					          , 0 } )
   aAdd( _aFields , { "Cliente"		   , {|| TRBSZW->ZW_CLIENTE } , "C" , "@!" , 0 , TamSX3("ZW_CLIENTE")[01], 0 } )
   aAdd( _aFields , { "Loja"	         , {|| TRBSZW->ZW_LOJACLI } , "C" , "@!" , 0 , TamSX3("ZW_LOJACLI")[01], 0 } )
   aAdd( _aFields , { "Nome "		      , {|| TRBSZW->WK_NOMECLI } , "C" , "@!" , 0 , TamSX3("C5_I_NOME")[01] , 0 } )
   aAdd( _aFields , { "Representante"  , {|| TRBSZW->ZW_VEND1}  	, "C" , "@!" , 0 , TamSX3("ZW_VEND1")[01]	 , 0 } )
   aAdd( _aFields , { "Nome Repres."   , {|| TRBSZW->WK_NOMEVEN}  , "C" , "@!" , 0 , TamSX3("C5_I_NOME")[01] , 0 } )
   aAdd( _aFields , { "Pedido Protheus", {|| TRBSZW->ZW_NUMPED }	, "C" , "@!" , 0 , TamSX3("ZW_NUMPED")[01] , 0 } ) 
   aAdd( _aFields , { "Status"         , {|| TRBSZW->ZW_STATUS}  	, "C" , "@!" , 0 , TamSX3("ZW_STATUS")[01] , 0 } )
   aAdd( _aFields , { "Des.Status"     , {|| TRBSZW->WK_DESSTAT}  , "C" , "@!" , 0 , 25                  	 , 0 } )

   _oMarkBRW := FWMarkBrowse():New()		   												// Inicializa o Browse

   _oMarkBRW:SetAlias( "TRBSZW" )			   												// Define Alias que ser� a Base do Browse
   _oMarkBRW:SetDescription( "Exclus�o de Pedidos de Vendas Rejeitados no Portal, a " + AllTrim(Str(_nDiasExPv,10)) + " Dias. "   )	// Define o titulo do browse de marcacao
   _oMarkBRW:SetFieldMark( "MARCA" )														// Define o campo que sera utilizado para a marca��o
   _oMarkBRW:SetMenuDef( 'MOMS0071' )	
   _oMarkBRW:SetAllMark({|| U_MOMS071A()})  

   _oMarkBRW:SetAfterMark({|| U_MOMS071M() })  // Executa um bloco de c�digo ap�s um registro ser marcado. 

   _oMarkBRW:SetFields( _aFields )													 		// Campos para exibi��o
   _oMarkBRW:AddButton( "Pesquisar" , {|| Processa( {|| U_MOMS071P() } , "Pesquisando Pedidos do Portal..." , "Aguarde!" ) } ,, 4 )
   _oMarkBRW:AddButton( "Excluir Pedidos" , {|| Processa( {|| U_MOMS071E(.F.) } , "Excluindo Pedidos do Portal..." , "Aguarde!" ) } ,, 4 )
   
   _oMarkBRW:Activate()																		// Ativacao da classe
 
End Sequence 

If Select("TRBSZW") > 0
   TRBSZW->( DBCloseArea() )
EndIf

Return Nil 

/*
===============================================================================================================================
Fun��o-------------: MOMS071D
Autor--------------: Julio de Paula Paz
Data da Criacao----: 04/04/2024
===============================================================================================================================
Descri��o----------: Rotina de Leitura dos dados  para a Exclus�o de Pedidos de Vendas Rejeitados do Portal em Tela.
===============================================================================================================================
Parametros---------: _lScheduller = .T. = Rotina rodada em modo Scheduller.
                                    .F. = Rotina rodada em tela.
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/  
User Function MOMS071D(_lScheduller)
Local _aCpos  := {}
Local _cMarca := GetMark()  
Local _nDiasExPv := U_ITGETMV('IT_NDIASEXP', 7)
Local _dDataExPv  // Data para exclus�o de pedido de vendas

Begin Sequence

   aAdd( _aCpos , { "MARCA"		, "C" , 2					    , 0 } )
   AAdd( _aCpos , { "ZW_FILIAL"	, "C" , 2                       , 0 } )
   AAdd( _aCpos , { "ZW_IDPED"	, "C" , TamSX3("ZW_IDPED")[01]  , 0 } )
   AAdd( _aCpos , { "ZW_EMISSAO", "D" , 8		                , 0 } )
   AAdd( _aCpos , { "ZW_NUMPED"	, "C" , TamSX3("ZW_NUMPED")[01] , 0 } )
   AAdd( _aCpos , { "ZW_CLIENTE", "C" , TamSX3("ZW_CLIENTE")[01], 0 } )
   AAdd( _aCpos , { "ZW_LOJACLI", "C" , TamSX3("ZW_LOJACLI")[01], 0 } )
   AAdd( _aCpos , { "WK_NOMECLI", "C" , TamSX3("C5_I_NOME")[01]	, 0 } )
   AAdd( _aCpos , { "ZW_VEND1 "	, "C" , TamSX3("ZW_VEND1")[01]	, 0 } )
   AAdd( _aCpos , { "WK_NOMEVEN", "C" , TamSX3("C5_I_NOME")[01]	, 0 } )
   AAdd( _aCpos , { "ZW_STATUS" , "C" , TamSX3("ZW_STATUS")[01]	, 0 } )
   AAdd( _aCpos , { "WK_DESSTAT", "C" , 25                   	, 0 } )
   AAdd( _aCpos , { "WK_RECNO"	, "N" , 10                      , 0 } )

   If Select("TRBSZW") > 0
	   TRBSZW->( DBCloseArea() )
   EndIf

   _otemp := FWTemporaryTable():New("TRBSZW", _aCpos )
   
   _otemp:AddIndex( "01", {"ZW_FILIAL","ZW_IDPED"} )
   _otemp:AddIndex( "02", {"ZW_FILIAL","ZW_NUMPED"} )

   _otemp:Create()  // Cria a tabela tempor�ria

   _dDataExPv := Date() - _nDiasExPv  // Data para exclus�o de pedido de vendas
   
   _cQry := "SELECT ZW_FILIAL, ZW_STATUS, ZW_IDPED, ZW_EMISSAO, ZW_NUMPED, ZW_CLIENTE, ZW_LOJACLI, ZW_VEND1 , SZW.R_E_C_N_O_ NRREG " 
   _cQry += " FROM  " + RetSqlName("SZW") + " SZW "
   _cQry += " WHERE "
   _cQry += "     SZW.D_E_L_E_T_  = ' ' "
   _cQry += " AND SZW.ZW_STATUS = 'R' "  
   _cQry += " AND SZW.ZW_DTREC <> ' ' "
   _cQry += " AND SZW.ZW_DTREC <= '" + Dtos(_dDataExPv) + "' "
   _cQry += " ORDER BY ZW_FILIAL, ZW_IDPED "

   If Select("QRYSZW") > 0
	   QRYSZW->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQry) , "QRYSZW" , .T. , .F. )
   TCSetField('QRYSZW',"ZW_EMISSAO","D",8,0)
   
   If ! _lScheduller
      Count To _nTotRegs
      ProcRegua(_nTotRegs)
   EndIf 
   
   QRYSZW->(DbGoTop())

   _nI := 1

   Do While ! QRYSZW->(Eof())
      If ! _lScheduller
         IncProc("Lendo dados: " + AllTrim(Str(_nI,10)) + " de " + AllTrim(Str(_nTotRegs,10))  )
      EndIf 
      _nI += 1

      _cDeStatus := ""
      If QRYSZW->ZW_STATUS == "R"
         _cDeStatus := "REPROVADO"
      ElseIf QRYSZW->ZW_STATUS == "L"
         _cDeStatus := "LIBERADO"
      ElseIf QRYSZW->ZW_STATUS == "I"
         _cDeStatus := "IMPORTADO"
      ElseIf QRYSZW->ZW_STATUS == "A"
         _cDeStatus := "AGUARDANDO APROVACAO"
      EndIf 

      TRBSZW->( RecLock( "TRBSZW" , .T. ) )
      If _lScheduller
         TRBSZW->MARCA := _cMarca
      EndIf 
      TRBSZW->ZW_FILIAL  := QRYSZW->ZW_FILIAL
      TRBSZW->ZW_IDPED   := QRYSZW->ZW_IDPED
      TRBSZW->ZW_EMISSAO := QRYSZW->ZW_EMISSAO
      TRBSZW->ZW_NUMPED  := QRYSZW->ZW_NUMPED
      TRBSZW->ZW_CLIENTE := QRYSZW->ZW_CLIENTE
      TRBSZW->ZW_LOJACLI := QRYSZW->ZW_LOJACLI
      TRBSZW->WK_NOMECLI := Posicione("SA1",1,xfilial("SA1")+QRYSZW->ZW_CLIENTE+QRYSZW->ZW_LOJACLI,"A1_NOME")
      TRBSZW->ZW_VEND1   := QRYSZW->ZW_VEND1
      TRBSZW->WK_NOMEVEN := Posicione("SA3",1,xfilial("SA3")+QRYSZW->ZW_VEND1,"A3_NOME")
      TRBSZW->ZW_STATUS  := QRYSZW->ZW_STATUS
      TRBSZW->WK_DESSTAT := _cDeStatus
      TRBSZW->WK_RECNO   := QRYSZW->NRREG
      TRBSZW->( MSUnLock() )

      QRYSZW->(DbSkip())

   EndDo 
 
End Sequence 

If Select("QRYSZW") > 0
   QRYSZW->( DBCloseArea() )
EndIf

Return Nil 

/*
===============================================================================================================================
Fun��o-------------: MOMS071M
Autor--------------: Julio de Paula Paz
Data da Criacao----: 04/04/2024
===============================================================================================================================
Descri��o----------: Fun��o Rodada ap�s a marca��o de um registro.
===============================================================================================================================
Parametros---------: Nenhum 
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/  
User Function MOMS071M()
Local _aItensPV := {}
Local _nI
Local _cMarcaIte 

Begin Sequence 
   If IsInCallStack("U_MOMS071A") // If _cChamada <> "LINHA"
      Break 
   EndIf

   _cMarca := _oMarkBRW:Mark()

   If _oMarkBRW:IsMark(_cMarca)
      _cMarcaIte := _cMarca 
   Else
      _cMarcaIte := Space(2)
   EndIf 
   
   _nRegAtu := TRBSZW->(Recno())

   TRBSZW->(DbSetOrder(1))

   _cCodFil := TRBSZW->ZW_FILIAL
   _cPedido := TRBSZW->ZW_IDPED

   TRBSZW->(MsSeek(_cCodFil + _cPedido))

   Do While ! TRBSZW->(Eof()) .And. TRBSZW->ZW_FILIAL+TRBSZW->ZW_IDPED == _cCodFil + _cPedido
         
      Aadd(_aItensPV,TRBSZW->(Recno()))

      TRBSZW->(DbSkip())
   EndDo 
   
   //==============================================================================
   // Um RecLock dentro de um While, as vezes desposiciona o ponteiro de registros 
   // e encerra o While antes de terminar o processamento de todos os registros.
   // Utilizando um For...Next como alternativa.
   //==============================================================================
   For _nI := 1 To Len(_aItensPV)  
       TRBSZW->(DbGoTo(_aItensPV[_nI]))
       TRBSZW->MARCA := _cMarcaIte
       TRBSZW->(MsUnLock())
   Next 

   TRBSZW->(DbGoTo(_nRegAtu))

End Sequence 

_oMarkBRW:Refresh(.F.)

Return Nil 

/*
===============================================================================================================================
Fun��o-------------: MOMS071A
Autor--------------: Julio de Paula Paz
Data da Criacao----: 04/04/2024
===============================================================================================================================
Descri��o----------: Rotina chamada e rodada na marca��o / Desmarca��o de todos os registros.
===============================================================================================================================
Parametros---------: Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/  
User Function MOMS071A()
Local _aItensPV := {}
Local _nI
Local _cMarcaIte 

Begin Sequence
   
   _cMarca := _oMarkBRW:Mark()

   If _oMarkBRW:IsMark(_cMarca)
      _cMarcaIte := Space(2)
      //_cMarcaIte := _cMarca
   Else
      //_cMarcaIte := Space(2)
      _cMarcaIte := _cMarca
   EndIf 
   
   _nRegAtu := TRBSZW->(Recno())

   TRBSZW->(DbGoTop())

   Do While ! TRBSZW->(Eof())
         
      Aadd(_aItensPV,TRBSZW->(Recno()))

      TRBSZW->(DbSkip())
   EndDo 
   
   //==============================================================================
   // Um RecLock dentro de um While, as vezes desposiciona o ponteiro de registros 
   // e encerra o While antes de terminar o processamento de todos os registros.
   // Utilizando um For...Next como alternativa.
   //==============================================================================
   For _nI := 1 To Len(_aItensPV)  
       TRBSZW->(DbGoTo(_aItensPV[_nI]))
       TRBSZW->MARCA := _cMarcaIte
       TRBSZW->(MsUnLock())
   Next 

   TRBSZW->(DbGoTop())

End Sequence 

_oMarkBRW:Refresh()

Return Nil 

/*
===============================================================================================================================
Fun��o-------------: MOMS071E
Autor--------------: Julio de Paula Paz
Data da Criacao----: 04/04/2024
===============================================================================================================================
Descri��o----------: Excluindo Pedidos de Vendas Selecionados em modo tela, com data de rejei��o superior ao numero de dias
                     configurado em Par�metro. 
                     Em modo Scheduller,  exclui todos os pedidos de vendas rejeitados, com data de rejei��o superior ao numero
                     de dias configurado em par�metro.
===============================================================================================================================
Parametros---------: _lScheduller = .T. = Rotina rodada em modo Scheduller.
                                    .F. = Rotina rodada em tela.
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/  
User Function MOMS071E(_lScheduller)

Local _aTRBRecno := {}
Local _nI 

Begin Sequence     
    
   If ! _lScheduller
      If ! U_ItMsg("Confirma a exclus�o dos Pedidos de Vendas do Portal Rejeitados?","Exclus�o de Pedidos de Vendas Rejeitados do Portal.",,2,2,2) 
         Break 
      EndIf 
   EndIf  

   TRBSZW->(DbGoTop())

   _aTRBRecno := {}
   Do While ! TRBSZW->(Eof())
         
      If ! Empty(TRBSZW->MARCA) // Exclui os pedidos do portal.
         SZW->(DbGoto(TRBSZW->WK_RECNO))
         SZW->(RecLock("SZW",.F.))
         SZW->(DbDelete())
         SZW->(MsUnLock())

         Aadd(_aTRBRecno,TRBSZW->(Recno()))
      EndIf 

      TRBSZW->(DbSkip())
   EndDo 

   If ! Empty(_aTRBRecno) // Exclui os Pedidos da tabela tempor�ria.
      For _nI := 1 To Len(_aTRBRecno)
          TRBSZW->(DbGoTo(_aTRBRecno[_nI]))
          TRBSZW->(RecLock("TRBSZW",.F.))
          TRBSZW->(DbDelete())
          TRBSZW->(MsUnlock())
      Next 
   EndIf 

   If ! _lScheduller
      U_ITMSG("Exclus�o de pedidos de vendas do Portal concluida.","Aten��o",,1)       
   Else 
      U_ITCONOUT("[MOMS071E] - Exclus�o de pedidos de vendas do Portal concluida.")       
   EndIf 

End Sequence 

TRBSZW->(DbGoTop())

If ! _lScheduller
   _oMarkBRW:Refresh()
EndIf 

Return Nil
