/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor       |   Data   |                              Motivo
Josu� Danich | 08/04/19 | Chamado 28694. Inclus�o de bot�o de PV em planejamento logistico.
Julio PAz    | 11/04/19 | Chamado 28585. Altera��o Transfer.Pedidos em duas Op��es:Ped.Posicionado e Varios Pedidos.  
Josu� Danich | 29/05/19 | Chamado 29435. Ajuste de espelho de pedido do portal para localizar multifiliais.
Jerry        | 01/12/20 | Chamado 34860. Mostra Nota no Bot�o Pesquisar PV. 
Julio Paz    | 09/12/20 | Chamado 34761. Inclus�o no menu, novo relatorio Espelho de Pedido Portal que roda sobre SC5/SC6.
Jerry        | 15/02/21 | Chamado 35371. Altera��o na Chamado do Espelho do Pedido Portal e Protheus. 
Julio Paz    | 30/07/21 | Chamado 37313. Desenvolver rotina para visualiza��o dos dados: operador logisticos e redespacho.
Igor Melga�o | 26/07/24 | Chamado 47487. Novas op��es de busca no Localizar PV / Senha do PV e Pedido do Cliente.
=================================================================================================================================================================================================
Analista         - Programador     - Inicio     - Envio    - Chamado - Motivo da Altera��o
=================================================================================================================================================================================================
Vanderlei Alves  - Alex Wallauer   - 06/06/25   - 10/06/25 - 45229   - Retirada do par�metro p/determinar se a integra��o WebS. ser� TMS Multiembarcador ou RDC para chamar a U_IT_TMS(_cLocEmb).
=================================================================================================================================================================================================
*/

#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"

/*
===============================================================================================================================
Programa----------: MA410MNU
Autor-------------: Wodson Reis Silva
Data da Criacao---: 16/07/2009
===============================================================================================================================
Descri��o---------: Ponto de entrada na abertura do Browse de Pedidos de Venda para adi��o de itens ao menu principal.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: aRotina : array com as op��es do menu
===============================================================================================================================
*/

User Function MA410MNU()

//============================================================
// Parametros do array a Rotina:                         
//                                                       
// 1. Nome a aparecer no cabecalho                       
// 2. Nome da Rotina associada                           
// 3. Reservado                                          
// 4. Tipo de Transacao a ser efetuada:                  
//      1 - Pesquisa e Posiciona em um Banco de Dados    
//      2 - Simplesmente Mostra os Campos                
//      3 - Inclui registros no Bancos de Dados          
//      4 - Altera o registro corrente                   
//      5 - Remove o registro corrente do Banco de Dados 
// 5. Nivel de acesso                                    
// 6. Habilita Menu Funcional                            
//============================================================

aAdd( aRotina , { 'Manutencao'				   , 'U_AOMS026'  , 0 , 2 , 0 , NIL } )          
aAdd( aRotina , { 'Transf.Pedido Posicionado', 'U_AOMS032("P")'	, 0 , 2 , 0 , NIL } )
aAdd( aRotina , { 'Transf.Varios Pedidos'	   ,  'U_AOMS032("V")'	, 0 , 2 , 0 , NIL } )
aAdd( aRotina , { 'Imprimir'				      , 'U_ROMS007'  , 0 , 2 , 0 , NIL } )
aAdd( aRotina , { 'Espelho Portal'	         , 'U_MA410ESP(1)'  , 0 , 2 , 0 , NIL } )
aAdd( aRotina , { 'Espelho Protheus  '	      , 'U_MA410ESP(2)'  , 0 , 2 , 0 , NIL } )
aAdd( aRotina , { 'WF Liberacao'			      , 'U_MOMS030()', 0 , 2 , 0 , NIL } )
aAdd( aRotina , { "Localiza PV"         	   , 'U_MA410LPV' , 0 , 1 , 0 , NIL } )
IF cFilAnt = "91"
   aAdd( aRotina,{'Desconto P/C ZF'			   , 'U_MA410TRO()', 0 , 2 , 0 , NIL } )//Esta nesse fonta abaixo
ENDIF

aAdd( aRotina,{'Solic.Ret.Pedido <== TMS', 'U_AOMS084B()', 0 , 2 , 0 , NIL } )
aAdd( aRotina,{'Devolve Pedido ==> TMS'  , 'U_AOMS084F()', 0 , 2 , 0 , NIL } )

aAdd( aRotina,{'Desmembra Pedido'	   , 'U_AOMS099()'	, 0 , 2 , 0 , NIL } )
aAdd( aRotina,{'Canhoto NF'	    	   , 'U_VISCANHO()', 0 , 2 , 0 , NIL } )//Esta no ITALACXFUN.PRW
aAdd( aRotina,{'Consulta Historico'    , 'U_COMS001()'	, 0 , 2 , 0 , NIL } )
aAdd( aRotina,{'Vincula Pedido' 	    	, 'U_AOMS110()'	, 0 , 2 , 0 , NIL } )
aAdd( aRotina,{'WF Desb Cliente'			, 'U_MOMS041Z()', 0 , 2 , 0 , NIL } )
aAdd( aRotina,{'Planej Logistico'		, 'U_MOMS042()', 0 , 2 , 0 , NIL } )


Return( aRotina )                                

/*
===============================================================================================================================
Programa----------: MA410Troca
Autor-------------: Alex Wallauer
Data da Criacao---: 09/08/2016
===============================================================================================================================
Descri��o---------: Troca do conteudo do pararametro MV_DESZFPC
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MA410Troca() 

Local _lMV_DESZFPC	:=GetMv("MV_DESZFPC")
Local _cmens 		:= "Conteudo Atual: "+IF(_lMV_DESZFPC,"Habilitado","Desabilitado")+CHR(13)+CHR(10)
Local _cmens2 		:= "Deseja " + IF(_lMV_DESZFPC,"desabilitar","habilitar") +  " o desconto do PIS e COFINS para vendas? "
Local _lRet := u_itmsg( _cmens + _cmens2 , "Desconto P/C Vendas Manaus (MV_DESZFPC)",,3,2 ,2 )

//grava log de acesso
u_itlogacs()

If _lRet .and. !_lMV_DESZFPC

   PutMV("MV_DESZFPC", .T. )
   u_itmsg("Desconto P/C Vendas Manaus (MV_DESZFPC) habilitado com sucesso!","Aten��o",,2)

ElseIf _lRet .and. _lMV_DESZFPC

   PutMV("MV_DESZFPC", .F. )
   u_itmsg("Desconto P/C Vendas Manaus (MV_DESZFPC) desabilitado com sucesso!","Aten��o",,2)

EndIf

Return .T.

/*
===============================================================================================================================
Programa----------: MA410LPV()
Autor-------------: Alex Wallauer
Data da Criacao---: 16/09/2016
===============================================================================================================================
Descri��o---------: Localiza Pedido de Venda 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER Function MA410LPV(cAlias,nReg,nOpc)

Local _cPV   := Space(50)
Local _cSay  := "Nr Pedido"
Local _lOK   := .F.
Local _oDlg, aCpoBrw:={},aSemSX3:={}
Local _nLinha:= 5
Local _nCol1 := 5//30
Local _nCol2 := _nCol1+65//073
Local _nTam  := 1100
Local _bValid:= {|| MA410Ler(_cPV,_cSay)  }
Local aCpoBusca := {"Nr Pedido","Pedido do Cliente","Senha do Pedido"}

Private aCampos:=ARRAY( SC5->(Fcount()) )
 
SX3->(DbSetOrder(2))

AADD( aSemSX3 , { "C5_NOTA"   	, 'C' , 9 , 0 } )
AADD( aSemSX3 , { "C5_SERIE"   	, 'C' , 3 , 0 } )
AADD( aSemSX3 , { "C5_FILIAL"  	, 'C' , 2 , 0 } )
AADD( aSemSX3 , { "C5_NUM"     	, 'C' , 6 , 0 } )
AADD( aSemSX3 , { "C5_I_FLFNC" 	, 'C' , 2 , 0 } )
AADD( aSemSX3 , { "C5_I_PDPR"  	, 'C' , 6 , 0 } )
AADD( aSemSX3 , { "C5_I_FILFT" 	, 'C' , 2 , 0 } )
AADD( aSemSX3 , { "C5_I_PDFT"  	, 'C' , 6 , 0 } )
AADD( aSemSX3 , { "C5_CLIENTE" 	, 'C' , 6 , 0 } )
AADD( aSemSX3 , { "C5_LOJACLI" 	, 'C' , 4 , 0 } )
AADD( aSemSX3 , { "C5_I_NOME"  	, 'C' , 50 , 0 } )
AADD( aSemSX3 , { "C5_VEND1"  	, 'C' , 50 , 0 } )
AADD( aSemSX3 , { "C5_I_V1NOM" 	, 'C' , 6 , 0 } )
AADD( aSemSX3 , { "C5_I_TRCNF" 	, 'C' , 1 , 0 } )
AADD( aSemSX3 , { "C5_I_CARGA" 	, 'C' , 6 , 0 } )
AADD( aSemSX3 , { "C5_I_PEDPA" 	, 'C' , 6 , 0 } )
AADD( aSemSX3 , { "C5_I_PEDGE" 	, 'C' , 6 , 0 } )
AADD( aSemSX3 , { "C5_I_NPALE" 	, 'C' , 6 , 0 } )
AADD( aSemSX3 , { "WK_OPERAD" 	, 'C' , 12, 0 } )
AADD( aSemSX3 , { "A2_COD" 	   , 'C' , 6 , 0 } )
AADD( aSemSX3 , { "A2_LOJA" 	   , 'C' , 4 , 0 } )
AADD( aSemSX3 , { "A2_NOME" 	   , 'C' , 40, 0 } )
AADD( aSemSX3 , { "A2_NREDUZ"    , 'C' , 20, 0 } )
AADD( aSemSX3 , { "A2_END" 	   , 'C' , 90, 0 } )
AADD( aSemSX3 , { "A2_CEP" 	   , 'C' , 9 , 0 } )
AADD( aSemSX3 , { "A2_MUN" 	   , 'C' , 50, 0 } )
AADD( aSemSX3 , { "A2_EST" 	   , 'C' , 2 , 0 } )
AADD( aSemSX3 , { "A2_DDD" 	   , 'C' , 3 , 0 } )
AADD( aSemSX3 , { "A2_TEL" 	   , 'C' , 50, 0 } )
AADD( aSemSX3 , { "A2_EMAIL" 	   , 'C' ,100, 0 } )
AADD( aSemSX3 , { "TA2_COD" 	   , 'C' , 6 , 0 } )
AADD( aSemSX3 , { "TA2_LOJA" 	   , 'C' , 4 , 0 } )
AADD( aSemSX3 , { "TA2_NOME" 	   , 'C' , 40, 0 } )
AADD( aSemSX3 , { "TA2_NREDUZ"   , 'C' , 20, 0 } )
AADD( aSemSX3 , { "TA2_END" 	   , 'C' , 90, 0 } )
AADD( aSemSX3 , { "TA2_CEP" 	   , 'C' , 9 , 0 } )
AADD( aSemSX3 , { "TA2_MUN" 	   , 'C' , 50, 0 } )
AADD( aSemSX3 , { "TA2_EST" 	   , 'C' , 2 , 0 } )
AADD( aSemSX3 , { "TA2_DDD" 	   , 'C' , 3 , 0 } )
AADD( aSemSX3 , { "TA2_TEL" 	   , 'C' , 50, 0 } )
AADD( aSemSX3 , { "TA2_EMAIL" 	, 'C' ,100, 0 } )
AADD( aSemSX3 , { "TA2_OK" 	, 'C' ,2, 0 } )


_otemp := FWTemporaryTable():New( "TRB", aSemSX3 )
_otemp:Create() 

Aadd(aCpoBrw,{"C5_FILIAL" ,,"Fil. Pedido"}) 
Aadd(aCpoBrw,{"C5_NUM" ,,"Nr Pedido"}) 
Aadd(aCpoBrw,{"C5_I_FLFNC",,"Fil. Carreg."})
Aadd(aCpoBrw,{"C5_I_PDPR" ,,"PV Carreg."})
Aadd(aCpoBrw,{"C5_I_FILFT",,"Fil. Fatur."})
Aadd(aCpoBrw,{"C5_I_PDFT" ,,"PV Fatur."})
Aadd(aCpoBrw,{"C5_NOTA",,"Nota"})
Aadd(aCpoBrw,{"C5_CLIENTE",,"Cod. Cli."})
Aadd(aCpoBrw,{"C5_LOJACLI",,"Loja"})
Aadd(aCpoBrw,{"C5_I_NOME" ,,"Cliente"})
Aadd(aCpoBrw,{"C5_VEND1"  ,,"Cod. Vend. 1"})
Aadd(aCpoBrw,{"C5_I_V1NOM",,"Vendedor"})
Aadd(aCpoBrw,{"C5_I_TRCNF",,"PV Troca NF?"})
Aadd(aCpoBrw,{"C5_I_CARGA",,"Carga"})
Aadd(aCpoBrw,{"C5_NOTA"   ,,"Nota"})
Aadd(aCpoBrw,{"C5_SERIE"  ,,"Serie"})
Aadd(aCpoBrw,{"C5_I_PEDPA",,"Ped. de Pallet?"})
Aadd(aCpoBrw,{"C5_I_PEDGE",,"Ped. Gerou Pallet?"})
Aadd(aCpoBrw,{"C5_I_NPALE",,"Pedido Pallet"})
Aadd(aCpoBrw,{ "WK_OPERAD",,"Tipo de Operador"})
Aadd(aCpoBrw,{ "A2_COD"   ,,"C�digo"})
Aadd(aCpoBrw,{ "A2_LOJA"  ,,"Loja"})
Aadd(aCpoBrw,{ "A2_NOME"  ,,"Raz�o Social"})
Aadd(aCpoBrw,{ "A2_NREDUZ",,"Nome Reduzido"})
Aadd(aCpoBrw,{ "A2_END"   ,,"Endere�o"})
Aadd(aCpoBrw,{ "A2_CEP"   ,,"CEP"})
Aadd(aCpoBrw,{ "A2_MUN"   ,,"Cidade"})
Aadd(aCpoBrw,{ "A2_EST"   ,,"Estado"})
Aadd(aCpoBrw,{ "A2_DDD"   ,,"DDD"})
Aadd(aCpoBrw,{ "A2_TEL"   ,,"Telefone"})
Aadd(aCpoBrw,{ "A2_EMAIL" ,,"E-mail"})
Aadd(aCpoBrw,{ "TA2_COD"   ,,"C�d.Transportadora"})
Aadd(aCpoBrw,{ "TA2_LOJA"  ,,"Loja Transp."})
Aadd(aCpoBrw,{ "TA2_NOME"  ,,"Raz�o Social Transp."})
Aadd(aCpoBrw,{ "TA2_NREDUZ",,"Nome Reduzido Transp."})
Aadd(aCpoBrw,{ "TA2_END"   ,,"Endere�o Transp."})
Aadd(aCpoBrw,{ "TA2_CEP"   ,,"CEP Transp."})
Aadd(aCpoBrw,{ "TA2_MUN"   ,,"Cidade Transp."})
Aadd(aCpoBrw,{ "TA2_EST"   ,,"Estado Transp."})
Aadd(aCpoBrw,{ "TA2_DDD"   ,,"DDD Transp."})
Aadd(aCpoBrw,{ "TA2_TEL"   ,,"Telefone Transp."})
Aadd(aCpoBrw,{ "TA2_EMAIL" ,,"E-mail Transp."})
Aadd(aCpoBrw,{ "TA2_OK" ,,"OK"})


DO WHILE .T.
   oBusca := Nil
   _nLinha:=5
   _lOK   := .F.
   oMainWnd:ReadClientCoords()//So precisa declarar uma fez para o Programa todo
   DEFINE MSDIALOG _oDlg TITLE "Localiza Pedido de Venda (MA410MNU)" FROM 000,000 TO 200,_nTam OF oMainWnd PIXEL //650

      @ _nLinha+2, _nCol1     MSCOMBOBOX oBusca VAR _cSay ITEMS aCpoBusca   SIZE 60,10 OF _oDlg PIXEL ON CHANGE ( _cPV := Space(50) )  //F3 "SC5"
      @ _nLinha  , _nCol2     MSGET _cPV  SIZE 50,10 OF _oDlg VALID ( EVAL(_bValid) ) PIXEL //F3 "SC5  Picture "@!"
      @ _nLinha  , _nCol2+100 BUTTON "Visual. Ped." SIZE 50,11 ACTION U_MA410VPV(_oDlg) OF _oDlg PIXEL

      _nLinha+=17

      TRB->(DBGOTOP())
    
      oMarkLPV:=MsSelect():New("TRB","TA2_OK",,aCpoBrw,.F.,"",{_nLinha,5,(_nLinha+75),  (_oDlg:nClientWidth-9)/2 })
      oMarkLPV:bMark := {|| U_MA410VPV(_oDlg)}
      oMarkLPV:oBrowse:bAllMark := { || }

   Activate MSDialog _oDlg Centered

   EXIT

ENDDO

_otemp:Delete()

RETURN .F.

/*
===============================================================================================================================
Programa----------: MA410Ler
Autor-------------: Alex Wallauer
Data da Criacao---: 16/09/2016
===============================================================================================================================
Descri��o---------: Localiza Pedido de Venda 
===============================================================================================================================
Parametros--------: _cPV - numero do pedido de vendas
===============================================================================================================================
Retorno-----------: l�gico indicando se achou pedido de vendas
===============================================================================================================================
*/
STATIC Function MA410Ler(_cPV,_cSay)

Local _cAliasSC5:= GetNextAlias(),lExistePV:=.F.
Local _lTemNF, _cCod, _cLoja, _cCodTransp, _cLojaTransp
Local _cTipoOperador
LOCAL _cQuery  := ""

_cPV := Alltrim(_cPV)

If !Empty(_cPV)
   DBSELECTAREA("TRB")
   ZAP

   If Select(_cAliasSC5) > 0
      (_cAliasSC5)->( DBCloseArea() )
   EndIf

   _cQuery := " SELECT  SC5.R_E_C_N_O_ REC_SC5 "
   _cQuery += " FROM " + RetSqlName("SC5") + " SC5 "
   
   If _cSay == "Pedido do Cliente"
      _cQuery += " LEFT JOIN " + RetSqlName("SC6") + " SC6  ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND SC6.D_E_L_E_T_ = ' ' "
   EndIf

   _cQuery += " WHERE SC5.D_E_L_E_T_ = ' ' "

   If _cSay == "Nr Pedido"
      _cQuery += "    AND SC5.C5_NUM     = '"+_cPV+"' "
   ElseIf _cSay == "Pedido do Cliente"
      _cQuery += "    AND SC6.C6_PEDCLI  = '"+_cPV+"' "
   ElseIf _cSay == "Senha do Pedido"
      _cQuery += "    AND SC5.C5_I_SENHA = '"+_cPV+"' "
   EndIf

   _cQuery += " GROUP BY SC5.R_E_C_N_O_ "

   DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAliasSC5 , .T. , .F. )

   SF2->(DbSetOrder(20)) // F2_FILIAL+F2_I_PEDID 
   SA2->(DbSetOrder(1))

   Do While (_cAliasSC5)->(!EOF())
      
      SC5->(DBGOTO( (_cAliasSC5)->REC_SC5 ))
      
      _cCodTransp  := ""
      _cLojaTransp := ""

      _lTemNF := .F.
      If SF2->(MsSeek(SC5->C5_FILIAL+SC5->C5_NUM))
         _cCodTransp  := SF2->F2_I_CTRA
         _cLojaTransp := SF2->F2_I_LTRA

         If !Empty(SF2->F2_I_REDP) 
            _cCod  := SF2->F2_I_REDP
            _cLoja := SF2->F2_I_RELO
            _lTemNF := .T.
            _cTipoOperador := "REDESPACHO"
         ElseIf !Empty(SF2->F2_I_OPER) 
            _cCod  := SF2->F2_I_OPER
            _cLoja := SF2->F2_I_OPLO
            _lTemNF := .T.
            _cTipoOperador := "LOGISTICO"
         EndIf   

         If _lTemNF
            SA2->(MsSeek(xFilial("SA2")+_cCod+_cLoja))
         EndIf
      EndIf 

      lExistePV:=.T.
      TRB->(DBAPPEND())
      AVREPLACE("SC5","TRB")
      If _lTemNF
         TRB->WK_OPERAD := _cTipoOperador
         TRB->A2_COD    := SA2->A2_COD
         TRB->A2_LOJA   := SA2->A2_LOJA
         TRB->A2_NOME   := SA2->A2_NOME
         TRB->A2_NREDUZ := SA2->A2_NREDUZ
         TRB->A2_END    := SA2->A2_END
         TRB->A2_CEP    := SA2->A2_CEP
         TRB->A2_MUN    := SA2->A2_MUN
         TRB->A2_EST    := SA2->A2_EST
         TRB->A2_DDD    := SA2->A2_DDD
         TRB->A2_TEL    := SA2->A2_TEL
         TRB->A2_EMAIL  := SA2->A2_EMAIL
      EndIf 

      If ! Empty(_cCodTransp) .And. SA2->(MsSeek(xFilial("SA2")+_cCodTransp+_cLojaTransp))
         TRB->TA2_COD    := SA2->A2_COD
         TRB->TA2_LOJA   := SA2->A2_LOJA
         TRB->TA2_NOME   := SA2->A2_NOME
         TRB->TA2_NREDUZ := SA2->A2_NREDUZ
         TRB->TA2_END    := SA2->A2_END
         TRB->TA2_CEP    := SA2->A2_CEP
         TRB->TA2_MUN    := SA2->A2_MUN
         TRB->TA2_EST    := SA2->A2_EST
         TRB->TA2_DDD    := SA2->A2_DDD
         TRB->TA2_TEL    := SA2->A2_TEL
         TRB->TA2_EMAIL  := SA2->A2_EMAIL      
      EndIf 

      (_cAliasSC5)->(DBSKIP())
       
   EndDo

   TRB->(DBGOTOP())
   oMarkLPV:oBrowse:Refresh()

   IF !lExistePV
      u_itmsg("A busca n�o encontrou dados!","Aten��o",,1)
   ENDIF
EndIf

RETURN .T.
 
/*
===============================================================================================================================
Programa----------: MA410ESP
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 26/03/2019
===============================================================================================================================
Descri��o---------: Impress�o de espelho do pedido do portal
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MA410ESP(_nOpcao)   

Local _cfilial       := cfilant
Private _aPed			:= {}
Private _nRadMnu1    := 1

Default _nOpcao      := 1

Begin Sequence
 
   If _nOpcao = 2
      U_ROMS064()
   Else   
      //Posiciona na SZW.
      SZW->(Dbsetorder(8))
      If SZW->(Dbseek(SC5->C5_I_IDPED))
         cfilant := SZW->ZW_FILIAL
         _aPed			:= {{alltrim(SZW->ZW_FILIAL) ,alltrim(SZW->ZW_IDPED) , alltrim(SZW->ZW_CLIENTE) , alltrim(SZW->ZW_LOJACLI) ,  SZW->ZW_VEND1 }}
         fwmsgrun(,{|oproc| U_ROMS035R(oproc)},"Aguarde...","Imprimindo espelho do pedido...")
         cfilant := _cfilial   
      Else
         u_itmsg("N�o foi localizado pedido do portal vinculado e este pedido de vendas","Aten��o",,1)
      Endif
   EndIf 

End Sequence

Return


/*
===============================================================================================================================
Programa----------: MA410VPV
Autor-------------: Igor Melga�o
Data da Criacao---: 26/07/2024
===============================================================================================================================
Descri��o---------: Visualiza��o do Pedido de Venda
===============================================================================================================================
Parametros--------: _cNum,_oDlg
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/
User Function MA410VPV(_oDlg) 
Local _cFilial := TRB->C5_FILIAL
Local _cNum := TRB->C5_NUM
Local _cFilBkp  := ""

DBSelectArea("SC5")
SC5->( DBSetOrder(1) )
If SC5->( DBSeek( _cFilial+_cNum ) )
   If _cFilial == cFilAnt
      _oDlg:End()
   Else
      _cFilBkp := cFilAnt
      cFilAnt := _cFilial
      MatA410(Nil, Nil, Nil, Nil, "A410Visual")
      cFilAnt := _cFilBkp
   EndIf
EndIf

Return .T.
