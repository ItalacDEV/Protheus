/*
=====================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
=====================================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 27/03/2018 | Chamado 23393. Iniciar motivo da liberação com "Autorizado".
-------------------------------------------------------------------------------------------------------------------------------------
Josué Danich | 29/11/2018 | Chamado 27162. Retirada msg de processo concluído e revisado fonte para novas regras  TOTVS.  
-------------------------------------------------------------------------------------------------------------------------------------
Lucas Borges | 15/10/2019 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25. 
-------------------------------------------------------------------------------------------------------------------------------------
Jerry        | 06/05/2020 | Chamado 32654. Melhorias na efetivação dos Pedidos com novos bloqueios. 
-------------------------------------------------------------------------------------------------------------------------------------
Jerry        | 18/08/2020 | Chamado 33867. Melhorias para tratar o envio WF de Preço. 
-------------------------------------------------------------------------------------------------------------------------------------
Jerry        | 21/10/2020 | Chamado 34426. Ajuste para Bloquear Pedido Venda a Vista para posterior aprovação. 
-------------------------------------------------------------------------------------------------------------------------------------
Jerry        | 04/11/2020 | Chamado 34582. Validar novo campo de Tabela de Preço. 
-------------------------------------------------------------------------------------------------------------------------------------
Julio Paz    | 14/12/2020 | Chamado 34793. Incluir Nova Coluna Browser Rot.Liberação P.V.Bloqueado p/Informar Nr.dias Parado.. 
-------------------------------------------------------------------------------------------------------------------------------------
Jerry        | 19/02/2021 | Chamado 35610. Retirado a Tratativa do WF do Preço que não é necessário.  
-------------------------------------------------------------------------------------------------------------------------------------
Jerry        | 08/07/2021 | Chamado 37073. Ajuste da query para listar Pedidos com Bloqueio de Crédito. 
-------------------------------------------------------------------------------------------------------------------------------------
Jerry        | 17/08/2021 | Chamado 37500. Ajuste para não listar Pedidos não liberados pelo Coordenador. 
-------------------------------------------------------------------------------------------------------------------------------------
Jerry        | 13/09/2021 | Chamado 36809. Ajustes para detalhamento de bloqueio e atualização para RDC.  
-------------------------------------------------------------------------------------------------------------------------------------
Jerry        | 01/11/2021 | Chamado 38155. Ajustes do filtro do Pedido Portal e de Vendas com Bloqueio de Crédito. 
-------------------------------------------------------------------------------------------------------------------------------------
Jerry        | 11/04/2022 | Chamado 39741. Retirar do Filtro da SZW (Pedido Portal) Oper. 05. 
-------------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço | 03/06/2022 | Chamado 38887. Ajuste para visualização de dados da aprovação do Gerente na Bonificação. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 23/02/2024 | Chamado 46365. Jerry. Correcao do botão visualizar quando o Pedido não é da mesma filial logada.
=====================================================================================================================================
*/   

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"
#Include "TopConn.ch" 

#DEFINE _ENTER CHR(13)+CHR(10)
   
/*
===============================================================================================================================
Programa----------: AOMS052
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 02/08/2011
===============================================================================================================================
Descrição---------: Tela de liberação ( Portal / Protheus )
===============================================================================================================================
Parametros--------: ExpA01 - Se a primeira posicao do array conter 1, o usuario pressionou Ok, caso contrario Cancelar. 
===============================================================================================================================
Retorno-----------: ExpL01 - Se .T. continua a operacao, se .F. nao volta pra tela de pedido sem fazer nada.
===============================================================================================================================
*/    
User Function AOMS052()   

Private _cPerg		:= "AOMS052"
Private _cPerg1		:= "AOMS052A"    
Public aSize           := {}
Private cOrdem		:= ""
Private aOrdem		:= {"PEDIDO","CLIENTE"}
Private cPesquisa	:= SPACE(200)
Private aRotina 
Private cCadastro
Private _cMatriUSR	:= u_UCFG001(1)
Private nNumCol	:= 360

Private _MVPARORI	:= ""

aSize := MsAdvSize() // Obtém a a área de trabalho e tamanho da dialog

//Verifica se o usuario possui acesso a rotina de alteracao de status dos pedidos de venda do tipo bonificacao
dbSelectArea("ZZL") 
ZZL->(DbSetOrder(1))
If !ZZL->(DbSeek(xFilial("ZZL") + _cMatriUSR))   

	u_itmsg("O usuario não possui acesso a rotina de liberação de Pedidos Bloqueado.","Informação",;
	           "Favor contactar o Depto de informática comunicando de tal problema, este cadastro se encontra no CFG.",1)
	Return 
	
Else
	
	If ZZL->ZZL_APRBON <> 'S'
		
		u_itmsg("O usuario não possui acesso a rotina de liberação de Pedidos Bloqueado.","Informação",;
		"Favor contactar o Depto de informática comunicando de tal problema, este cadastro se encontra no CFG.",1)
		Return  
		
	EndIf
	
EndIf

If !Pergunte(_cPerg1,.T.)
	Return
EndIf

_MVPARORI := MV_PAR01
	
If !Pergunte(_cPerg,.T.)
	Return
EndIf

//Grava log de utilização da rotina
u_itlogacs()

_aHeader := {}                  //Variavel que montará o aHeader do grid
_aCols   := {}                  //Variável que receberá os dados

FwMsgRun(, {|OPROC| lOK:=AOMS052PP(OPROC) }, 'Aguarde!' , 'Carregando os dados...' , .F. ) 
 
@aSize[7],000 TO aSize[6],aSize[5] DIALOG oDlgLib TITLE ("Liberação de Pedidos Bloqueados do "+IF(_MVPARORI = 1,"Protheus","Portal"))

oMark := MsNewGetDados():New( 040  ,005    ,aSize[4]-15,aSize[3],,"AllwaysTrue","AllwaysTrue","AllwaysTrue", ,1       , LEN(_aCols),"AllwaysTrue", ""          ,"Eval({||.F.})", oDlgLib , _aHeader    ,_aCols    ,           ,          )

@ 003,006 To 034,820 Title OemToAnsi("Pedido")
@ 012,012 Say "Ordem: "
@ 010,040 ComboBox cOrdem ITEMS aOrdem	SIZE 060,50 Object oOrdem
@ 010,160 Get cPesquisa					SIZE 200,10 Object oPesquisa
@ 010,100 Button "Pesquisar"			SIZE 040,13 Action AOMS052PRO( CORDEM, cPesquisa )

oOrdem:bChange := {|| AOMS052FOR(CORDEM) , oMark:oBrowse:Refresh(.T.) }

If _MVPARORI = 1//Protheus
   @ 010,nNumCol+045	Button "Visualizar"		Size 40,13	Action U_AOMS052P()                                 Object oBtnRet
   @ 010,nNumCol+090	Button "Liberar"		Size 40,13	Action (U_AOMS052W("L"),oMark:oBrowse:Refresh(.T.)) Object oBtnRet
   @ 010,nNumCol+135	Button "Rejeitar"		Size 40,13	Action (U_AOMS052W("R"),oMark:oBrowse:Refresh(.T.)) Object oBtnRet
ELSE//Portal
   @ 010,nNumCol+045	Button "Visualizar"		Size 40,13	Action U_AOMS052V()                         	    Object oBtnRet
   @ 010,nNumCol+090	Button "Liberar"		Size 40,13	Action U_AOMS052G("L")								Object oBtnRet
   @ 010,nNumCol+135	Button "Rejeitar"		Size 40,13	Action U_AOMS052G("R")								Object oBtnRet
ENDIF
@ 010,nNumCol+180	Button "Legenda"		Size 40,13	Action U_AOMS052L()										Object oBtnRet
@ 010,nNumCol+225	Button "Sair"   		Size 40,13	Action oDlgLib:End()									Object oBtnRet

ACTIVATE DIALOG oDlgLib CENTERED


Return      


/*
===============================================================================================================================
Programa----------: AOMS052P
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 02/08/2011
===============================================================================================================================
Descrição---------: Chama funcao para visualizacao dos dados pedido de venda que o usuario esteja posicionado.
===============================================================================================================================
Parametros--------: _ctitulo - titulo da janela de visualização
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS052P(_ctitulo)    

Local _cFilial	:= ""
Local _cNumero	:= ""
Local _lRet		:= 0  
Local _aArea	:= GetArea() 
Local _nPosi    := 0
Local _aRotBack,_cCadBack,_nBack
Default _ctitulo:= 'VISUALIZACAO DO PEDIDO DE VENDA BLOQUEADO'	

IF LEN(_aCols) = 0
   RETURN .F.
ENDIF
_nPosi:=_aCols[oMark:naT,(LEN(_aCols[1])-1)]//TMP->(Recno())

TMP->(DBGOTO(_nPosi))
SC5->(DBGOTO(TMP->RECNO))

_cFilial	:= SC5->C5_FILIAL
_cNumero	:= SC5->C5_NUM 
cFilAntSalve:= cFilAnt
cFilAnt     := SC5->C5_FILIAL

If Type( "N" ) == "N"

	_nBack := n
	n     := 1

EndIf  

//============================================================
// Caso exista, faz uma copia do aRotina                    
//============================================================
If Type( "aRotina" ) == "A"

	_aRotBack := AClone( aRotina )

EndIf

//============================================================
// Caso exista, faz uma copia do cCadastro                  
//============================================================
If Type( "cCadastro" ) == "C"

	_cCadBack := cCadastro

EndIf
                                 	
cCadastro := _ctitulo 
aRotina   := { { "Visualizar","A410Visual",0,2 } }  //"Visualizar"
	
_lRet:= A410Visual("SC5",SC5->(RECNO()),1)        
		  	
cFilAnt:=cFilAntSalve
	
//====================================================================
// Restaura o aRotina                                               
//====================================================================
If ValType( _aRotBack ) == "A"

	aRotina := AClone( _aRotBack )

EndIf

//============================================================
// Caso exista, faz uma copia do cCadastro                  
//============================================================
If Type( "_cCadBack" ) == "C"

	cCadastro := _cCadBack

EndIf

If ValType( _nBack ) == "N"

	n := _nBack

EndIf
	
restArea(_aArea)	

Return _lRet      

/*
===============================================================================================================================
Programa----------: AOMS052W
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 02/08/2011
===============================================================================================================================
Descrição---------: Funcao responsavel por efetuar a liberacao dos pedidos de venda do tipo bloqueado.
===============================================================================================================================
Parametros--------: _copc - Opção de execução, L - Liberação e R para rejeição
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS052W(_copc)

Local _cFilial		:= ""
Local _cNumero		:= ""
Local _cTpPedido	:= ""
Local _cmotivo	    := SPACE(100)
Local _oTPanel1		:= nil
Local _nrotina		:= 1
Local _ntotprc		:= 0
Local _ntotqtd		:= 0
Local _lgravou      := .F.
Local _nPosi        := 0
IF LEN(_aCols) = 0
   RETURN .F.
ENDIF
_nPosi:=_aCols[oMark:naT,(LEN(_aCols[1])-1)]//TMP->(Recno())
TMP->(DBGOTO(_nPosi))
SC5->(DBGOTO(TMP->RECNO))

_cFilial	:= SC5->C5_FILIAL
_cNumero	:= SC5->C5_NUM 
_cTpPedido	:= SC5->C5_I_BLOQ  

If _cOpc == "L"
	If _cTpPedido == 'L' 
		u_itmsg( "Não será possível realizar a liberação deste pedido, pois o mesmo ja foi liberado anteriormente.","Atenção",,1 )
		Return
	EndIf
ElseIf _cOpc == "R"
	If _cTpPedido == 'R' 
		u_itmsg( "Não será possível realizar a liberação deste pedido, pois o mesmo ja foi liberado anteriormente.","Atenção",,1 )
		Return
	EndIf
EndIf

DBSelectArea("SC5")
SC5->(DBSetOrder(1))

If SC5->(DBSeek(_cFilial + _cNumero)) 
                                  	                  	
	//===========================================================================
	//Verifica se o usuario confirmou a alteracao do status do pedido de venda.
	//===========================================================================
	If U_AOMS052P(iif(_copc = "L", "Libera pedido Protheus", "Rejeita Pedido Protheus")) = 1
	
	
		//Lê motivo da liberação

		_cusername := UsrFullName(__cUserID)

		Do while _nrotina > 0 .and. empty(_cmotivo)

		    _cmotivo:=IF(_copc="L", "Autorizado"+SPACE(100-LEN("Autorizado")) , SPACE(100) )
		    
			@0,0 TO 180,500 DIALOG _onDlg TITLE IIF(_copc = "L", "Dados da liberação", "Dados da rejeição")
			
			@005,010 SAY IIF(_copc = "L", "Motivo da liberação", "Motivo da rejeição") 					
			@020,010 SAY "Pedido........: "	+ SC5->C5_NUM	
			@035,010 SAY "Cliente.......: "	+ SC5->C5_CLIENTE + " - " + SC5->C5_LOJAENT + " - " + ;
			POSICIONE("SA1",1,Xfilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJAENT, "A1_NOME") 	
			@050,010 SAY "Motivo........:"
			@050,050 Get _cmotivo 
		
			TButton():New( 075 , 010 , ' Confirma '	, _oTPanel1 , {|| _onDlg:END()	} , 70 , 10 ,,,, .T. )
			TButton():New( 075 , 080 , ' Cancela '	, _oTPanel1 , {|| _nrotina := 0, _onDlg:END()	} , 70 , 10 ,,,, .T. )
			
			ACTIVATE MSDIALOG _onDlg Centered

			If empty(_cmotivo) .and. _nrotina > 0

				u_itmsg(IIF(_copc = "L", "Motivo da liberação é obrigatório!","Motivo da rejeição é obrigatório!"),"Motivo",,1)
		
			Endif
	
		Enddo

	
		If _nrotina > 0
		
			//==================================================
			//Armazena dados da liberacao do pedido de vendas.
			//==================================================
			DBSelectArea("SC6")
			SC6->(DBSetOrder(1))
			SC6->(DBSeek(_cFilial + _cNumero))
			
			Do while SC6->C6_FILIAL == _cFilial .AND. SC6->C6_NUM == _cNumero
			
				RecLock("SC6",.F.)
				SC6->C6_I_LLIBB := SC6->C6_LOJA
   	 			SC6->C6_I_CLILB := SC6->C6_CLI
   	 			SC6->C6_I_VLIBB := SC6->C6_PRCVEN
   	 			SC6->C6_I_QLIBB := SC6->C6_QTDVEN
   	 			SC6->C6_I_MOTLB := _cmotivo
   	 			SC6->C6_I_PLIBB := DDATABASE + 30
   	 			SC6->C6_I_DLIBB := DDATABASE

 	 			_ntotprc += SC6->C6_PRCVEN
   	 			_ntotqtd += SC6->C6_QTDVEN
   	 			
   	 			SC6->( Dbskip() )
   	 			
     	 			
   	 		Enddo				
			
			_lgravou := .T.
			RecLock("SC5",.F.)
		
				SC5->C5_I_BLOQ  := IIF(_copc = "L","L","R")   
				SC5->C5_I_MTBON := _cMatriUSR
				SC5->C5_I_DLIBE := date()
				SC5->C5_I_HLIBE := time()
				SC5->C5_I_STAWF := 'S'
				SC5->C5_I_VLIBB := _ntotprc
   	 			SC5->C5_I_QLIBB := _ntotqtd
   	 			SC5->C5_I_LLIBB := SC5->C5_LOJACLI
   	 			SC5->C5_I_CLILB := SC5->C5_CLIENTE
   	 			SC5->C5_I_MOTLB := _cmotivo
    			SC5->C5_I_ULIBB := _cusername 				
		 
			SC5->(MsUnlock())
			
			//==============================================================
			//Envia interface para o rdc com status do pedido
			//==============================================================
			If  SC5->C5_I_ENVRD == "S"
				U_ENVSITPV(,.F.)   //Envia interface de alteração de situação do pedido atual
			Endif 

			TMP->(RecLock("TMP",.F.)) 
			TMP->(Dbdelete())
			TMP->(MsUnlock())
            ADEL(_aCols,oMark:naT)
            ASIZE(_aCols,LEN(_aCols)-1)
            oMark:SetArray(_aCols,.F.) 
			
		Endif						
		
	EndIf	                            
	
	SC5->(dbGotop())
	
EndIf

//=============================================================
//Refaz browse quando confirma processo
//=============================================================
If _lgravou

	SC5->(Dbgotop())
	
Endif

Return .T.                      

/*
===============================================================================================================================
Programa----------: AOMS052Y
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 02/08/2011
===============================================================================================================================
Descrição---------: Mostra Legenda 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/ 
User Function AOMS052Y()    

BrwLegenda("Legenda","Status dos Pedidos",{	{"ENABLE","Pedido de Venda Liberado"		},;
											{'BR_PRETO','Pedido de Venda com Bloqueio'	},;
											{'BR_CINZA','Pedido de Venda com Rejeitado'		}})
	
Return(.T.) 

/*
===============================================================================================================================
Programa----------: AOMS052Y
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 02/08/2011
===============================================================================================================================
Descrição---------: Mostra Legenda 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/ 
User Function AOMS052L()    

BrwLegenda("Legenda","Status dos Pedidos",{	{"ENABLE"		,"Pedidos Liberados"	},;
											{'BR_VERMELHO'	,'Pedidos Bloqueados'	},;
											{'BR_CINZA'		,'Pedidos Rejeitados'	}})
	
Return(.T.)

/*
===============================================================================================================================
Programa----------: AOMS052G
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 23/06/2016
===============================================================================================================================
Descrição---------: Função criada para fazer a gravação de liberação/rejeição
===============================================================================================================================
Parametros--------: _cOpc -> L - Liberado / R - Rejeitado
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/ 
User Function AOMS052G(_cOpc)

Local _cFilial	
Local _cNumPed	
Local _cBloq	
Local _lBloq	:= .T.
//Local _cTexto	:= ""
Local _lret   	:= .F.
Local _oTPanel1	:= nil
Local _cmotivo	:= SPACE(100)
Local _cCoord   := "" 
Local _cWF      := "" //Aprovador WF 1-Sim 2-Nao
Local _cVend1   := ""

DBSELECTAREA("SZW")
SZW->( DBSetOrder(1) )
//SZW->( DBSeek( substr(oMark:acols[oMark:nat][3],1,2) + oMark:acols[oMark:nat][5] ) )
IF LEN(_aCols) = 0
   RETURN .F.
ENDIF
_nPosi:=_aCols[oMark:naT,(LEN(_aCols[1])-1)]//TMP->(Recno())
TMP->(DBGOTO(_nPosi))
SZW->(DBGOTO(TMP->RECNO))

_cFilial:= SZW->ZW_FILIAL
_cNumPed:= SZW->ZW_IDPED
_cBloq	:= SZW->ZW_BLOQ
_cVend1 := SZW->ZW_VEND1

_cCoord:= posicione("SA3",1,xfilial("SA3")+_cVend1,"A3_SUPER") 
_cWF   := posicione("SA3",1,xfilial("SA3")+_cCoord,"A3_I_WF") 

If _cOpc == "L"
	If _cBloq == "S"
		_lBloq	:= .F.
		u_itmsg( "Não será possível realizar a liberação deste pedido, pois o mesmo ja foi liberado anteriormente.","Atenção",,1 )
	EndIf
ElseIf _cOpc == "R"
	If _cBloq == "R"
		_lBloq	:= .F.
		u_itmsg( "Não será possível realizar a rejeição deste pedido, pois o mesmo ja foi rejeitado anteriormente.","Atenção",,1 )
	EndIf
EndIf

If _lBloq

	//Apresenta pedido para confirmar processo
	_lret := u_AOMS052V(_cFilial, _cNumPed, iif(_copc = "L", "Libera pedido Portal", "Rejeita Pedido Portal"))
		
	Do while _lret .and. empty(_cmotivo)

	   _cmotivo:=IF(_copc="L", "Autorizado"+SPACE(100-LEN("Autorizado")) , SPACE(100) )

		@0,0 TO 180,500 DIALOG _onDlg TITLE IIF(_copc = "L", "Dados da liberação", "Dados da rejeição")
		
		@005,010 SAY IIF(_copc = "L", "Motivo da liberação","Motivo da rejeição")					
		@020,010 SAY "Pedido........: "+ SZW->ZW_IDPED
		@035,010 SAY "Cliente.......: "+ SZW->ZW_CLIENTE + " - " + SZW->ZW_LOJACLI + " - " + ;
		POSICIONE("SA1",1,Xfilial("SA1") + SZW->ZW_CLIENTE + SZW->ZW_LOJACLI, "A1_NOME") 	
		@050,010 SAY "Motivo........:"
		@050,050 Get _cmotivo 
		
		TButton():New( 075 , 010 , ' Confirma '	, _oTPanel1 , {|| _onDlg:END()	} , 70 , 10 ,,,, .T. )
		TButton():New( 075 , 080 , ' Cancela '	, _oTPanel1 , {|| _lret := .F. , _onDlg:END()	} , 70 , 10 ,,,, .T. )
			
		ACTIVATE MSDIALOG _onDlg Centered

		If empty(_cmotivo) .and. _lret

			u_itmsg(IIF(_copc = "L","Motivo da liberação é obrigatório!","Motivo da rejeição é obrigatório!"), "Motivo",,1)
		
		Endif
	
	Enddo

	
	If _lret
	
		DbSelectArea("SZW")
		SZW->( DbSetOrder(1) )
		SZW->( DbSeek(_cFilial + _cNumPed) )
		While SZW->(!Eof()) .And. _cFilial + _cNumPed == SZW->( ZW_FILIAL + ZW_IDPED )
	
			RecLock( "SZW" , .F. )
			SZW->ZW_I_MTBON := _cMatriUSR
			SZW->ZW_I_DLIBE := date() 
			SZW->ZW_I_HLIBE := time()         
			SZW->ZW_BLOQ	:= _cOpc
   			SZW->ZW_I_ULIBB := UsrFullName(__cUserID)//cusername
   			SZW->ZW_I_MOTLB := _cmotivo
   			SZW->ZW_STATUS  := _cOpc
			SZW->( MsUnLock() )
	
			SZW->( dbSkip() )
		
		End
	
		//Recarrega dados na tela
		_nli := oMark:nat
		FwMsgRun(, {|OPROC| lOK:=AOMS052PP(OPROC) }, 'Aguarde!' , 'Carregando os dados...' , .F. ) 
		oMark:aCols := _aCols
		oMark:ForceRefresh()
		oMark:oBrowse:Refresh(.T.)
		If _nli > len(oMark:acols)
			_nli := len(oMark:acols)
		Endif
		oMark:GoTOP()
		oMark:GoTo( _nLi )
	
	Endif
	
EndIf


Return

/*
===============================================================================================================================
Programa----------: AOMS052V
Autor-------------: Darcio Ribeiro Sporl
Data da Criacao---: 01/07/2016
===============================================================================================================================
Descrição---------: Rotina para visualização dos pedidos do portal
===============================================================================================================================
Parametros--------: cPed - Chave (IdPED) do pedido
------------------: cfilial - Filial do pedido
------------------: _ctitulo - Titulo da janela de visualização
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS052V(CFILIAL, CPED, _ctitulo)
Local aArea		:= GetArea(),nColuna
Local lRetMod2 	:= .F. // Retorno da função Modelo2 - .T. Confirmou / .F. Cancelou
Local nLinha	:= 0
Local _nPosi    := 0
Public nOpcx	:= 7

Default _cTitulo	:= "Visualização de Pedido Portal"

DBSelectArea("SX3")
SX3->( DBSetOrder(1) )
SX3->( DBSeek("SZW") )

//nUsado		:= 0
aHeader		:= {}
aCols		:= {}
cDescr		:= ""
nQtd2UM		:= 0
c2UM		:= ""
nVlrTot		:= 0
nVTot		:= 0

//====================================================================================================
// Montagem do aHeader
//====================================================================================================
aHeader := {	{ "Item"			, "ZW_ITEM"		, "@!"					,010,0,"AllwaysTrue()","","C","","R"},;
				{ "Produto"			, "ZW_PRODUTO"	, "@!"					,015,0,"AllwaysTrue()","","C","","R"},;
				{ "Descrição"		, "cDescr"		, "@!"					,020,0,"AllwaysTrue()","","C","","R"},;
				{ "Qtd Ven 2 UM"	, "nQtd2UM"		, "@e 999,999,999.99"	,014,2,"AllwaysTrue()","","C","","R"},;
				{ "Segunda UM"		, "c2UM"		, "@!"					,002,0,"AllwaysTrue()","","C","","R"},;
				{ "Quantidade"		, "ZW_QTDVEN"	, "@e 999,999,999.99"	,014,2,"AllwaysTrue()","","C","","R"},;
				{ "Unidade"			, "ZW_UM"		, "@!"					,002,0,"AllwaysTrue()","","C","","R"},;
				{ "Prc Unitario"	, "ZW_PRCVEN"	, "@e 9,999,999.9999"	,014,4,"AllwaysTrue()","","C","","R"},;
				{ "Vlr.Total "		, "nVlrTot"		, "@e 999,999,999.99"	,014,2,"AllwaysTrue()","","C","","R"}}

DBSELECTAREA("SZW")
SZW->( DBSetOrder(1) )
//SZW->( DBSeek( SubStr( CFILIAL , 1 , 2 ) + CPED ) )
IF LEN(_aCols) = 0
   RETURN .F.
ENDIF
_nPosi:=_aCols[oMark:naT,(LEN(_aCols[1])-1)]//TMP->(Recno())
TMP->(DBGOTO(_nPosi))
SZW->(DBGOTO(TMP->RECNO))
CFILIAL:= SZW->ZW_FILIAL
CPED   := SZW->ZW_IDPED
DO While SZW->( !Eof() ) .AND. SZW->( ZW_FILIAL + ZW_IDPED ) == SubStr( CFILIAL , 1 , 2 ) + CPED
	
	//====================================================================================================
	// Montagem do Acols
	//====================================================================================================
	AADD( aCols , Array( Len(aHeader) + 1 ) )
	nLinha++
	
	cDescr		:= GetAdvFVal( "SB1" , "B1_I_DESCD"		, xFilial("SB1") + ALLTRIM(SZW->ZW_PRODUTO)	, 1 , "" )
	nFatConv	:= GetAdvFVal( "SB1" , "B1_CONV"		, xFilial("SB1") + SZW->ZW_PRODUTO				, 1 , "" )
	cTpConv		:= GetAdvFVal( "SB1" , "B1_TIPCONV"		, xFilial("SB1") + SZW->ZW_PRODUTO				, 1 , "" )
	nNewFat		:= GetAdvFVal( "SB1" , "B1_I_FATCO"		, xFilial("SB1") + SZW->ZW_PRODUTO				, 1 , "" )
	c2UM		:= GetAdvFVal( "SB1" , "B1_SEGUM"		, xFilial("SB1")+ALLTRIM(SZW->ZW_PRODUTO)		, 1 , "" )
	
	If cTpConv == "M"
		nQtd2UM	:= IIf( nFatConv == 0 , nNewFat * SZW->ZW_QTDVEN	, nFatConv * SZW->ZW_QTDVEN	)
	Else
		nQtd2UM	:= IIf( nFatConv == 0 , SZW->ZW_QTDVEN / nNewFat	, SZW->ZW_QTDVEN / nFatConv	)
	EndIf
	
	nVlrTot		:= SZW->ZW_QTDVEN * SZW->ZW_PRCVEN
	nVtot		+= nVlrTot
	
	For nColuna := 1 to Len(aHeader)
		aCols[nLinha][nColuna] := &( aHeader[nColuna][2] )
	Next nColuna
	
	aCols[nLinha][Len(aHeader)+1] := .F. // Linha não deletada
	
	SZW->( DBSkip() )
EndDo

cFli		:= Space(20)
cFlip		:= Space(20)
cTipPed		:= Space(15)
cNumPed		:= Space(25)
cCliente	:= Space(06)
cNomCli		:= Space(60)
cLojaCli	:= Space(04)
cGrpCli		:= Space(30)
cCond		:= Space(50)
cVend1		:= Space(06)
cNmVend1	:= Space(40)
cVend2		:= Space(06)
cNmVend2	:= Space(40)
cPedCli		:= Space(09)
dDtEnt		:= CtoD("")
cHrEnt		:= Space(05)
cSha		:= Space(14)
cTipFre		:= Space(10)
cTipCar		:= Space(15)
cQtdCha		:= Space(03)
cHrDes		:= Space(05)
nCusDes		:= 0
cObsCom		:= Space(120)
cObsNF		:= Space(120)
cObsALC		:= Space(LEN(SZW->ZW_OBSAVAC))

//====================================================================================================
// Configuracao dos Campos
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
//====================================================================================================
aC := {	{ "cFli"		, {015,003}	, "Filial Fat" 		,"@!"   				,	,		,.F.	},;
		{ "cFlip"		, {015,203}	, "Filial Produção" ,"@!"   				,	,		,.F.	},;
		{ "cTipPed"		, {030,003}	, "Tipo Pedido" 	,"@!"   				,	,		,.F.	},;
		{ "cNumPed"		, {030,203}	, "Num. Pedido" 	,"@!"   				,	,		,.F.	},;
		{ "cCliente"	, {045,003}	, "Cliente" 		,"@!"   				,	,		,.F.	},;
		{ "cLojaCli"	, {045,085}	, "Loja"			,"@!"   				,	,		,.F.	},;
		{ "cNomCli"		, {045,140}	, "Nome Cliente"	,"@!"   				,	,		,.F.	},;
		{ "cGrpCli"		, {060,003}	, "Grupo Cliente"	,"@!"   				,	,		,.F.	},;
		{ "cCond"		, {060,285}	, "Cond. Pagto" 	,"@!"   				,	,		,.F.	},;
		{ "cVend1"		, {075,003}	, "Vendedor 1" 		,"@!"   				,	,		,.F.	},;
		{ "cNmVend1"	, {075,140}	, "Nome Vendedor 1"	,"@!"   				,	,		,.F.	},;
		{ "nVTot"		, {075,500}	, "Valor Total"		,"@e 999,999,999.99"	,	,		,.F.	},;
		{ "cVend2"		, {090,003}	, "Vendedor 2"  	,"@!"   				,	,		,.F.	},;
		{ "cNmVend2"	, {090,140}	, "Nome Vendedor 2" ,"@!"   				,	,		,.F.	},;
		{ "cPedCli"		, {105,003}	, "Pedido Cliente"	,"@!"   				,	,		,.F.	},;
		{ "dDtEnt"		, {105,140}	, "Data Entrega"	,"@!"   				,	,		,.T.	},;
		{ "cHrEnt"		, {105,245}	, "Hora Entrega"	,"@!"   				,	,		,.F.	},;
		{ "cSha"		, {105,325}	, "Senha"			,"@!"   				,	,		,.F.	},;
		{ "cTipFre"		, {105,500}	, "Tipo Frete"		,"@!"   				,	,		,.F.	},;
		{ "cTipCar"		, {120,003}	, "Carga"			,"@!"   				,	,		,.F.	},;
		{ "cQtdCha"		, {120,140}	, "Qtd. Chapa"		,"@!"   				,	,		,.F.	},;
		{ "cHrDes"		, {120,245}	, "Hora Descarga"	,"@!"   				,	,		,.F.	},;
		{ "nCusDes"		, {120,325}	, "Custo Descarga"	,"@e 999,999,999.99"	,	,		,.F.	},;
		{ "cObsCom"		, {135,003}	, "Obs. Comercial"	,"@!"					,	,		,.F.	},;
		{ "cObsNf"		, {150,003}	, "Mensagem NF"		,"@!"					,	,		,.F.	},;
		{ "cObsALC"		, {165,003}	, "Análise Lim. Cr.","@!"					,	,		,.F.	} }

//====================================================================================================
// Conteudo dos Campos
// aR[n,1] = Nome da Variavel Ex.:"cCliente"
// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aR[n,3] = Titulo do Campo
// aR[n,4] = Picture
// aR[n,5] = Validacao
// aR[n,6] = F3
// aR[n,7] = Se campo e' editavel .t. se nao .f.
//====================================================================================================
aR := {}

DBSELECTAREA("SZW")
SZW->( DBSetOrder (1) )
If SZW->( DBSeek( SubStr( CFILIAL , 1 , 2 ) + CPED ) )

	cFli		:= Alltrim(SubStr(CFILIAL,1,2)+" - "+GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(CFILIAL,1,2),1,""))
	cFlip		:= Alltrim(SubStr(SZW->ZW_FILPRO,1,2)+" - "+GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(SZW->ZW_FILPRO,1,2),1,"")) 
	cTipPed		:= SUBSTR(SZW->ZW_TIPO+" - "+GetAdvFVal("SX5","X5_DESCRI",xFilial("SX5")+"DJ"+SZW->ZW_TIPO,1,""),1,25)
	cNumPed  	:= CPED
	cCliente 	:= SZW->ZW_CLIENTE
	cLojaCli 	:= SZW->ZW_LOJACLI
	cNomCli 	:= GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI,1,"")
	cGrpCli		:= GetAdvFVal("SA1","A1_GRPVEN",xFilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI,1,"")+" - "+GetAdvFVal("SA1","A1_I_NGRPC",xFilial("SA1")+SZW->ZW_CLIENTE+SZW->ZW_LOJACLI,1,"")
	cCond		:= SZW->ZW_CONDPAG+" - "+GetAdvFVal("SE4","E4_DESCRI",xFilial("SE4")+SZW->ZW_CONDPAG,1,"")
	cVend1	 	:= SZW->ZW_VEND1
	cNmVend1 	:= GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+SZW->ZW_VEND1,1,"")
	cVend2   	:= SZW->ZW_VEND2
	cNmVend2 	:= GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+SZW->ZW_VEND2,1,"")
	nVTot 		:= nVTot
	cPedCli		:= SZW->ZW_PEDCLI
	dDtEnt		:= SZW->ZW_FECENT
	cHrEnt		:= SZW->ZW_HOREN
	cSha		:= SZW->ZW_SENHA
	cTipFre		:= IF(SZW->ZW_TPFRETE == 'C',SZW->ZW_TPFRETE+" - CIF",SZW->ZW_TPFRETE+" - FOB")
	cTipCar		:= IF(SZW->ZW_TIPCAR == '1',SZW->ZW_TIPCAR+" - Paletizada",SZW->ZW_TIPCAR+" - Batida")
	cQtdCha		:= SZW->ZW_CHAPA
	cHrDes		:= SZW->ZW_HORDES
	nCusDes		:= SZW->ZW_CUSDES
	cObsCom		:= SZW->ZW_OBSCOM
	cObsNF		:= SZW->ZW_MENNOTA
	cObsALC		:= SZW->ZW_OBSAVAC
	
	//====================================================================================================
	// Array com as Coordenadas da Tela para o GetDados
	//====================================================================================================
	aCGD:={350,06,26,74}
	
		
	//====================================================================================================
	// Chamada da Modelo2
	//====================================================================================================
	lRetMod2 := Modelo2( _cTitulo , aC , aR , aCGD , nOpcx ,,,,,, 9999 ,,, .T. )

Else
	
	u_itmsg(  'Não foi possível posicionar no pedido!' , 'Atenção!' ,,1 )
	
EndIf

RestArea(aArea)
Return(lRetMod2)

/*
===============================================================================================================================
Programa--------: AOMS052FOR
Autor-----------: Josué Danich Prestes
Data da Criacao-: 17/10/2017
===============================================================================================================================
Descrição-------: Função que ordena os dados do Browse de acordo com a ordem escolhida
===============================================================================================================================
Parametros------: cOrdem
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS052FOR( cORDEM )

_nReg		:= TMP->(Recno())
cPesquisa	:= Space(200)

oPesquisa:Refresh()

DbSelectArea("TMP") 
IF Ascan( aOrdem , cOrdem ) = 2
  _aCols := aSort(_aCols,,,{|x,y| x[3]+x[7]+x[8] < y[3]+y[7]+y[8] })//Ordena por Filial + Cliente + Loja
ELSE
  _aCols := aSort(_aCols,,,{|x,y| x[3]+x[5] < y[3]+y[5] })//Ordena por Filial + Pedido
ENDIF

TMP->( DbSetOrder( Ascan( aOrdem , cOrdem ) ) )
TMP->( DbGoTo( _nReg ) )  //Mantendo no mesmo registro que estava posicionado anteriormente

oMark:SetArray( _aCols , .T. ) 
oMark:oBrowse:Refresh(.T.)
oMark:ForceRefresh()

Return()


/*
===============================================================================================================================
Programa--------: AOMS052PP
Autor-----------: Josué Danich
Data da Criacao-: 25/11/2015
===============================================================================================================================
Descrição-------: Prepara dados da tela
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/

Static Function AOMS052PP(OPROC)
LOCAL _nCpo
//====================================================================================================
// Monta Query de Consulta
//====================================================================================================
If _MVPARORI == 1

	_cQuery := " SELECT "
	_cQuery += "     SC5.C5_FILIAL     FILIAL   ,"
  	_cQuery += "     SC5.C5_I_FILFT    FIL_FATU ,"
  	_cQuery += "     SC5.C5_I_FLFNC    ZW_FILPRO,"
	_cQuery += "     SC5.C5_I_OPER      TIPO     ,"
	_cQuery += "     SC5.C5_CLIENTE    CODCLI   ,"
	_cQuery += "     SC5.C5_LOJACLI    LOJA     ,"
	_cQuery += "     SC5.C5_TIPOCLI    TIPOCLI  ,"
	_cQuery += "     SC5.C5_CONDPAG    CONDPAGTO,"
	_cQuery += "     SC5.C5_VEND1      VEND1    ,"
  	_cQuery += "     SC5.C5_VEND2      VEND2    ,"
	_cQuery += "     SC5.C5_I_TAB      TAB_PREC ,"
	_cQuery += "     SC5.C5_EMISSAO    DTEMISS  ,"
	_cQuery += "     SC5.C5_TPFRETE    TPFRETE  ,"
	_cQuery += "     SC5.C5_DESPESA    DESPESA  ,"
	_cQuery += "     SC5.C5_MENNOTA    MENSANF  ,"
	_cQuery += "     SC5.C5_I_TIPCA    TPCAR    ,"
	_cQuery += "     SC5.C5_I_OBPED    OBSCOMER ,"
	_cQuery += "     SC5.C5_I_SENHA    SENHA    ,"
	_cQuery += "     SC5.C5_I_DTENT    DT_ENTREG,"
	_cQuery += "     SC5.C5_I_EVENT    EVENTO   ,"
	_cQuery += "     SC5.C5_NUM        NUMPED   ,"
	_cQuery += "     '2'               IMPRIME  ,"
	_cQuery += "     SC5.C5_I_OBS      OBS      ," 
	_cQuery += "     SC5.C5_I_DLIBG    DLIBG    ," 
	_cQuery += "     SC5.C5_I_HLIBG    HLIBG    ," 
	_cQuery += "     SC5.R_E_C_N_O_    RECNO    ,"
	_cQuery += "     SC5.C5_I_BLOQ     BLOQ      "
	_cQuery += " FROM  "+ RETSQLNAME('SC5')+" SC5 "
	_cQuery += " WHERE "+ RETSQLDEL('SC5') +" AND "
	_cQuery += " C5_I_BLCRE <> 'B' AND "
	//Pedidos bloqueados
	If MV_PAR01 == 1
		
		_cQuery += " C5_I_BLOQ = 'B' AND C5_NOTA = ' ' AND ( C5_I_OPER IN ('10', '40', '18','24','05') or C5_TPFRETE = 'F' ) "
		
		//Pedidos liberados
	ElseIf MV_PAR01 == 2
		
		_cQuery += " C5_I_BLOQ = 'L' AND C5_NOTA = ' ' AND ( C5_I_OPER IN ('10', '40', '18','24','05') or C5_TPFRETE = 'F'  ) "
		
		//Pedidos Rejeitados
	Else
		
		_cQuery += " C5_I_BLOQ = 'R' AND C5_NOTA = ' ' AND ( C5_I_OPER IN ('10', '40', '18','24','05') or C5_TPFRETE = 'F' ) "
		
	EndIf
	
	_cQuery += " ORDER BY SC5.C5_FILIAL, SC5.C5_NUM "
	
ELSE 
	
	_cQuery := " SELECT "
	_cQuery += "     SZW.ZW_FILIAL     FILIAL   ,"
  	_cQuery += "     SZW.ZW_FILIAL     FIL_FATU ,"
	_cQuery += "     SZW.ZW_FILPRO     ZW_FILPRO,"
	_cQuery += "     SZW.ZW_TIPO       TIPO     ,"
	_cQuery += "     SZW.ZW_CLIENTE    CODCLI   ,"
	_cQuery += "     SZW.ZW_LOJACLI    LOJA     ,"
	_cQuery += "     SZW.ZW_I_MOTBL    TIPOCLI  ,"
	_cQuery += "     SZW.ZW_CONDPAG    CONDPAGTO,"
	_cQuery += "     SZW.ZW_VEND1      VEND1    ,"
  	_cQuery += "     SZW.ZW_VEND2      VEND2    ,"
	_cQuery += "     SZW.ZW_TABELA     TAB_PREC ,"
	_cQuery += "     SZW.ZW_EMISSAO    DTEMISS  ,"
	_cQuery += "     SZW.ZW_TPFRETE    TPFRETE  ,"
	_cQuery += "     SZW.ZW_DESPESA    DESPESA  ,"
	_cQuery += "     SZW.ZW_MENNOTA    MENSANF  ,"
	_cQuery += "     SZW.ZW_TIPCAR     TPCAR    ,"
	_cQuery += "     SZW.ZW_OBSCOM     OBSCOMER ,"
	_cQuery += "     SZW.ZW_SENHA      SENHA    ,"
	_cQuery += "     SZW.ZW_FECENT     DT_ENTREG,"
	_cQuery += "     SZW.ZW_EVENTO     EVENTO   ,"
	_cQuery += "     SZW.ZW_IDPED      NUMPED   ,"
	_cQuery += "     SZW.ZW_IMPRIME    IMPRIME  ,"
	_cQuery += "     SZW.R_E_C_N_O_    RECNO    ,"
	_cQuery += "     SZW.ZW_BLOQ       BLOQ     ," 
	_cQuery += "     SZW.ZW_I_OBS      OBS      ," 
	_cQuery += "     SZW.ZW_I_DLIBG    DLIBG    ," 
	_cQuery += "     SZW.ZW_I_HLIBG    HLIBG     " 
	_cQuery += " FROM  "+ RETSQLNAME('SZW') +" SZW "
	_cQuery += " WHERE "+ RETSQLDEL('SZW') 
	
	_cQuery += " AND (ZW_TIPO in ('10','24') OR ZW_TPFRETE = 'F'   ) "

	_cQuery += " AND ZW_BLQLCR <> 'B' "
  
	//Pedidos bloqueados
	If MV_PAR01 == 1
		
		_cQuery += "AND ZW_BLOQ = ' ' AND ZW_STATUS NOT in ('R','I','A') AND ZW_ITEM = '1' AND ZW_NUMPED = ' '  "
		
		//Pedidos liberados
	ElseIf MV_PAR01 == 2
		
		_cQuery += "AND ZW_BLOQ = 'L' AND ZW_STATUS = 'L' AND ZW_ITEM = '1' AND ZW_NUMPED = ' ' "
		
		//Pedidos Rejeitados
	Else
		
		_cQuery += "AND ZW_BLOQ = 'R' AND ZW_ITEM = '1' AND ZW_NUMPED = ' ' "
		
	EndIf 
	
	_cQuery += " ORDER BY SZW.ZW_FILIAL, SZW.ZW_IDPED "
	
ENDIF

//====================================================================================================
// Fecha Alias se estiver em Uso
//====================================================================================================
If Select("TRB") >0
	("TRB")->( DBCloseArea() )
EndIf

If Select("TMP") >0
	("TMP")->( DBCloseArea() )
EndIf

//====================================================================================================
// Monta Area de Trabalho executando a Query
//====================================================================================================
TcQuery _cQuery New Alias "TRB"

DBSelectArea("TRB")
TRB->( DBGoTop() )

//====================================================================================================
// Monta arquivo temporario
//====================================================================================================
aCpoTmp := {	{ "OK"			, "C" , 001 , 0 } ,;
				{ "IMPRIME"		, "C" , 010 , 0 } ,;
				{ "FILIAL"		, "C" , 020 , 0 } ,;
				{ "FILPRO"		, "C" , 020 , 0 } ,;
				{ "RFILIAL"		, "C" , 002 , 0 } ,;
				{ "NUMPED"		, "C" , 025 , 0 } ,;
				{ "TIPO"		, "C" , 002 , 0 } ,;
				{ "VEND1"       , "C" , 006 , 0 } ,;
				{ "NMVEND1"     , "C" , 020 , 0 } ,;
				{ "CODCLI"		, "C" , 006 , 0 } ,;
				{ "LOJA"		, "C" , 004 , 0 } ,;
				{ "NMCLI"		, "C" , 060 , 0 } ,;
				{ "TIPOCLI"		, "C" , 060 , 0 } ,;
				{ "CONDPAGTO"	, "C" , 003 , 0 } ,;
				{ "VEND2"     	, "C" , 006 , 0 } ,;
				{ "NMVEND2"   	, "C" , 060 , 0 } ,;
				{ "TAB_PREC"	, "C" , 003 , 0 } ,;
				{ "DTEMISS"   	, "C" , 010 , 0 } ,;
				{ "DIASPARADO" 	, "N" , 008 , 0 } ,; 
				{ "TPFRETE"   	, "C" , 001 , 0 } ,;
  				{ "TRANSP"		, "C" , 006 , 0 } ,;
				{ "DESPESA"     , "N" , 014 , 2 } ,;
				{ "MENSANF"     , "C" , 120 , 0 } ,;
				{ "TPCAR"       , "C" , 001 , 0 } ,;
				{ "OBSCOMER"    , "C" , 120 , 0 } ,;
				{ "HORAENTR"    , "C" , 005 , 0 } ,;
				{ "SENHA"       , "C" , 014 , 0 } ,;
				{ "DT_ENTREG"   , "C" , 010 , 0 } ,;
				{ "BLQLCR" 	    , "C" , 001 , 0 } ,;
				{ "BLOCLI" 	    , "C" , 001 , 0 } ,;
				{ "BLOQ" 	    , "C" , 001 , 0 } ,;
				{ "OBS" 	    , "C" , 200 , 0 } ,;
				{ "DLIBG" 	    , "C" , 010 , 0 } ,;
				{ "HLIBG" 	    , "C" , 010 , 0 } ,;
				{ "RECNO" 	    , "N" , 018 , 0 } ,;
				{ "STAT_ZW"     , "C" , 002 , 0 }  }

_otemp := FWTemporaryTable():New( "TMP",  aCpoTmp )

_otemp:AddIndex( "01", {"FILIAL","NUMPED"} )
_otemp:AddIndex( "02", {"FILIAL","CODCLI","LOJA"} ) 
_otemp:AddIndex( "03", {"RFILIAL","NUMPED"} )

_otemp:Create()

_aHeader := {}         //Variavel que montará o aHeader do grid
_aCols   := {}         //Variável que receberá os dados

//====================================================================================================
// Alimenta arquivo temporário
//====================================================================================================
DO WHILE !TRB->( EOF() )
	
    OPROC:cCaption := "Lendo Pedido: "+TRB->NUMPED
    ProcessMessages()
	TMP->(DBAPPEND())
	
	TMP->OK		    := ""
	TMP->IMPRIME	:= IIF( Empty( ALLTRIM(TRB->IMPRIME) ) , "2" , ALLTRIM(TRB->IMPRIME) ) +"-"+ IIF( ALLTRIM(TRB->IMPRIME) == '1' , "SIM" , "NÃO" )
    IF EMPTY(TRB->ZW_FILPRO) .OR. ALLTRIM(TRB->ZW_FILPRO)=='0'
	   TMP->FILIAL	:= TRB->FILIAL   +" - "+GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(TRB->FILIAL,1,2),1,"")
	ELSE   
	   TMP->FILIAL	:= IF((!EMPTY(TRB->FIL_FATU ) .AND. !(ALLTRIM(TRB->FIL_FATU )=='0')),SubStr(TRB->FIL_FATU ,1,2)+" - "+GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(TRB->FIL_FATU ,1,2),1,""),"")
	   TMP->FILPRO  := IF((!EMPTY(TRB->ZW_FILPRO) .AND. !(ALLTRIM(TRB->ZW_FILPRO)=='0')),SubStr(TRB->ZW_FILPRO,1,2)+" - "+GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+SubStr(TRB->ZW_FILPRO,1,2),1,""),"")
	ENDIF
	TMP->RFILIAL    := TRB->FILIAL
	TMP->NUMPED 	:= TRB->NUMPED
	TMP->TIPO   	:= TRB->TIPO
	TMP->CODCLI 	:= TRB->CODCLI
	TMP->LOJA 		:= TRB->LOJA
	TMP->NMCLI		:= GetAdvFVal( "SA1" , "A1_NOME" , xFilial("SA1") + TRB->CODCLI + TRB->LOJA , 1 , "" )
	TMP->TIPOCLI	:= TRB->TIPOCLI
	TMP->CONDPAGTO  := TRB->CONDPAGTO
	TMP->VEND1 		:= TRB->VEND1
	TMP->NMVEND1	:= GetAdvFVal( "SA3" , "A3_NOME" , xFilial("SA3") + TRB->VEND1 , 1 , "" )
	TMP->VEND2		:= TRB->VEND2
	TMP->NMVEND2	:= GetAdvFVal( "SA3" , "A3_NOME" , xFilial("SA3") + TRB->VEND2 , 1 , "" )
	TMP->TAB_PREC	:= TRB->TAB_PREC
	TMP->DTEMISS	:= DtoC( StoD( TRB->DTEMISS ) )
	TMP->DIASPARADO := Date() - StoD( TRB->DTEMISS )
	TMP->TPFRETE	:= TRB->TPFRETE
	TMP->DESPESA	:= TRB->DESPESA
	TMP->MENSANF	:= TRB->MENSANF
	TMP->TPCAR		:= TRB->TPCAR
	TMP->OBSCOMER	:= TRB->OBSCOMER
	TMP->SENHA		:= TRB->SENHA
	TMP->DT_ENTREG	:= DtoC( StoD( TRB->DT_ENTREG ) )
	TMP->BLOQ       := TRB->BLOQ
	TMP->OBS        := TRB->OBS
	TMP->DLIBG      := DtoC( StoD( TRB->DLIBG ) )
	TMP->HLIBG      := TRB->HLIBG
	TMP->RECNO      := TRB->RECNO

   TRB->( DBSkip() )
EndDo

TRB->( DBCloseArea() )

_aHeader := {}         //Variavel que montará o aHeader do grid
_aCols   := {}         //Variável que receberá os dados

TMP->( Dbgotop() )

DO While !TMP->( EOF() )
   AADD(_aCols,{AOMS052RL(),TMP->IMPRIME,TMP->FILIAL,TMP->FILPRO,TMP->NUMPED,TMP->TIPO,TMP->VEND1,substr(TMP->NMVEND1,1,20),TMP->CODCLI,TMP->LOJA,TMP->NMCLI,TMP->TIPOCLI,TMP->CONDPAGTO,TMP->VEND2,;
                            TMP->NMVEND2,TMP->TAB_PREC,TMP->DTEMISS,TMP->DIASPARADO,TMP->TPFRETE,TMP->DESPESA,TMP->MENSANF,TMP->TPCAR,TMP->OBSCOMER,TMP->SENHA,TMP->DT_ENTREG,TMP->OBS,TMP->DLIBG ,TMP->HLIBG,TMP->(Recno()),.F.})
	
   TMP->( DBSkip() )
EndDo


//====================================================================================================
// Array com definicoes dos campos do browse
//====================================================================================================
aCpoBrw := {	{ "IMPRIME"    	,""	,"Impresso?"     		,"@!"               	,"10" ,"0"},;
				{ "FILIAL"    	,"LSTFAT","Filial Faturamento" 	,"@!"              	,"15" ,"0"},;
				{ "FILPRO"    	,"LSTCAR","Filial Carregamento"	,"@!"              	,"15" ,"0"},;
				{ "NUMPED"    	,""	,"Num. Pedido"     		,"@!"               	,"25" ,"0"},;
				{ "TIPO"    	,""	,"Tipo"    	  	   		,"@!"               	,"06" ,"0"},;
				{ "VEND1" 		,""	,"Vendedor1"       		,"@!"					,"06" ,"0"},;
				{ "NMVEND1"		,""	,"Nm. Vend1"       		,"@!"					,"20" ,"0"},;
				{ "CODCLI"    	,""	,"Cliente"         		,"@!"               	,"01" ,"0"},;
				{ "LOJA"    	,""	,"Loja"         		,"@!"               	,"04" ,"0"},;
				{ "NMCLI"		,""	,"Nm. Cliente"     		,"@!"					,"60" ,"0"},;
				{ "TIPOCLI"  	,""	,"Mot. Bloqueio"   		,"@!"               	,"30" ,"0"},;
				{ "CONDPAGTO"  	,""	,"Cond. Pagto."    		,"@!"					,"03" ,"0"},;
				{ "VEND2" 		,""	,"Vendedor2"       		,"@!"					,"06" ,"0"},;
				{ "NMVEND2"		,""	,"Nm. Vend2"       		,"@!"					,"60" ,"0"},;
				{ "TAB_PREC"   	,""	,"Tabela Preço"    		,"@!"					,"03" ,"0"},;
				{ "DTEMISS"    	,""	,"Dt. Emissâo"     		,"@D"	            	,"08" ,"0"},;
				{ "DIASPARADO" 	,""	,"Dias Parado"     		,"@E 99,999,999"	   	,"08" ,"0"},;
				{ "TPFRETE"		,""	,"Tp. Frete"	  		,"@!"               	,"06" ,"0"},;
				{ "DESPESA"		,""	,"Despesa"         		,"@E 9999,999,999.99"	,"02" ,"0"},;
				{ "MENSANF"    	,""	,"Mens. NF"       		,"@!"               	,"120","0"},;
				{ "TPCAR" 		,""	,"Tp. Carga"      		,"@!"               	,"01" ,"0"},;
				{ "OBSCOMER"   	,""	,"Observ. Comercial"	,"@!"               	,"120","0"},;
				{ "SENHA"   	,""	,"Senha"		 		,"@!"               	,"14" ,"0"},;
				{ "DT_ENTREG"	,""	,"Dt. Entrega"	     	,"@D"	            	,"08" ,"0"},;
				{ "OBS"   	    ,""	,"Observ. Lib. Bon."	,"@!"               	,"50" ,"0"},;
				{ "DLIBG"   	,""	,"Dt Lib. Bon."		 	,"@!"               	,"14" ,"0"},;
				{ "HLIBG"   	,""	,"Hr Lib. Bon."		 	,"@!"               	,"14" ,"0"} }

Aadd(_aHeader, {;
                  "",;      //X3Titulo()
                  "IMAGEM",;//X3_CAMPO
                  "@BMP",;  //X3_PICTURE
                  3,;		//X3_TAMANHO
                  0,;		//X3_DECIMAL
                  ".F.",;	//X3_VALID
                  "",;		//X3_USADO
                  "C",;		//X3_TIPO
                  "",; 		//X3_F3
                  "V",;		//X3_CONTEXT
                  "",;		//X3_CBOX
                  "",;		//X3_RELACAO
                  "",;		//X3_WHEN
                  "V"})		//

FOR _nCpo := 1 TO LEN(aCpoTmp)

   IF (_nPos:=ASCAN(aCpoBrw, {|C| C[1] == aCpoTmp[_nCpo,1]} )) = 0
      LOOP
   ENDIF

   Aadd(_aHeader, {;
                  aCpoBrw[_nPos,3],;//X3Titulo()
                  aCpoTmp[_nCpo,1],;//X3_CAMPO
                  aCpoBrw[_nPos,4],;//X3_PICTURE
                  aCpoTmp[_nCpo,3],;//X3_TAMANHO
                  aCpoTmp[_nCpo,4],;//X3_DECIMAL
                  "",;	            //X3_VALID
                  "",;	            //X3_USADO
                  aCpoTmp[_nCpo,2],;//X3_TIPO
                  aCpoBrw[_nPos,2],;//X3_F3
                  "R",;	    //X3_CONTEXT
                  "",;	    //X3_CBOX
                  "",;	    //X3_RELACAO
                  ""})	    //X3_WHEN


NEXT

Return .T.

/*
===============================================================================================================================
Programa----------: AOMS052RL
Autor-------------: Josué Danich Prestes
Data da Criacao---: 17/10/2017
===============================================================================================================================
Descrição---------: Verifica o Status para definição da legenda
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: cRet - Código para definição da legenda
===============================================================================================================================
*/
Static Function AOMS052RL()

Local cRet

If TMP->BLOQ == 'B' .OR. TMP->BLOQ == ' '

		cRet := LoadBitmap( GetResources(),"BR_VERMELHO")
		
ElseIf TMP->BLOQ == 'R' 

		cRet := LoadBitmap( GetResources(),"BR_CINZA")	

Elseif TMP->BLOQ == "L"

		cRet := LoadBitmap( GetResources(),"BR_VERDE")	

Endif

Return(cRet)

/*
===============================================================================================================================
Programa--------: AOMS052PRO
Autor-----------: Josué Danich Prestes
Data da Criacao-: 17/10/2017
===============================================================================================================================
Descrição-------: Função que pesquisa os dados na tela de acordo com a ordem escolhida
===============================================================================================================================
Parametros------: cOrdem - 1 para pesquisa por pedido e 2 para pesquisa por cliente
					cPesquisa - sting para pesquisar
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function AOMS052PRO( cOrdem, cPesquisa )

Local _lachou := .F.

DbSelectArea("TMP")
TMP->( DbSetOrder( Ascan( aOrdem , cOrdem ) ) )
TMP->( DbGoTop() )

//Faz scan manual para achar pelo campo escolhido e contendo o string escrito
Do while  TMP->( !Eof() ) .and. !_lachou

		If alltrim(cOrdem) == 'PEDIDO'
		
			If alltrim(cPesquisa) $ alltrim(TMP->NUMPED)
			
				_lachou := .T.
				exit
				
			Endif
			
		Else
		
				If alltrim(cPesquisa) $ alltrim(TMP->CODCLI)
			
				_lachou := .T.
				exit
				
			Endif
	
		Endif
		
		TMP->( Dbskip() )
		
Enddo	

If !_lachou

   TMP->( DBGOTOP() )
	
   u_itmsg("Registro não encontrado", "Procura", ,1)

else

   IF (_nLi:= ASCAN(_aCols,{|C| C[ LEN(C)-1 ] = TMP->( RECNO() ) }) ) # 0
      oMark:GoTOP()
      oMark:GoTo( _nLi )
   ENDIF
	
Endif

oMark:oBrowse:Refresh(.T.)

Return()
