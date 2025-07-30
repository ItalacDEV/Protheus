/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 15/05/2024 | Chamado 47107. Jerry. Alteracao de "Dt.Cheg.Oper.Log" p/ "Dt Ocorr Oper Log" de "Dt.Cheg.Cliente" p/ "Dt.Ocorr.Cliente"
Julio Paz     | 08/07/2024 | Chamado 47784. Corre��o de error log na rotina de canhotos de notas fiscais ao informa data para Oper.Log.
Lucas Borges  | 22/04/2025 | Chamado 50505. Alterada a picture do CNPJ para contemplar campo alfanum�rico
===============================================================================================================================
Analista    - Programador   - Inicio   - Envio    - Chamado - Motivo da Altera��o
==============================================================================================================================================================
Jerry       - Alex Wallauer - 12/09/24 - 13/11/24 - 46161   - Grava��o dos campos F2_I_OUSER/F2_I_ODATA/F2_I_OHORA quando alterar a Dt Entrega no Op.Log (Dt.Canhoto) 
==============================================================================================================================================================
*/

#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
#Include "Colors.ch"
#Include "FWMVCDef.Ch"
#Include "topconn.Ch"

/*
===============================================================================================================================
Programa----------: MOMS016 
Autor-------------: Fabiano Dias
Data da Criacao---: 04/07/2011
Descri��o---------: Funcao responsavel por realizar o lancamento da data de entrega do canhoto no sistema.
Parametros--------: _cAliasAux	:= C�digo da Tabela no SX5
------------------: nTamAux		:= Tamanho da Chave para o Retorno
Retorno-----------: .T. - Compatibilidade com a utiliza��o em F3
===============================================================================================================================
*/
User Function MOMS016()

Private _cPerg := "MOMS016"
Private _cOperLog := Space(6)
Private _cNOperLog := ""

//================================================================================
// Valida a parametriza��o inicial e chama fun��o para montagem da tela para
// sele��o das NF que ter�o os recebimentos de canhoto informados.
//================================================================================
DO WHILE .T.

   If Pergunte(_cPerg,.T.)
	
	  IF MOMS016L()
	     LOOP
	  ENDIF

   EndIf
   
   EXIT 

ENDDO

Return()

/*
===============================================================================================================================
Programa----------: MOMS016Q
Autor-------------: Fabiano Dias
Data da Criacao---: 04/07/2011
Descri��o---------: Funcao responsavel por executar as consultas em banco de dados desta rotina.
Parametros--------: _nOpcao - Numero da consulta a ser executada.
------------------: _cAlias - Alias a ser utilizado nas consultas.
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS016Q( _nOpcao , _cAlias )

Local _cFiltro	:= "% "
Local _cFiltro2	:= "% "

ProcRegua(0)
IncProc("Filtrando NFs...")
//================================================================================
// Monta as consultas de acordo com os par�metros fornecidos pela chamada
//================================================================================
If _nOpcao == 1
	
	//================================================================================
	// FILTROS
	//================================================================================
	_cFiltro  += " AND F2.F2_FILIAL = '" + xFilial("SF2") + "' "
	_cFiltro2 += " AND F2.F2_FILIAL = '" + xFilial("SF2") + "' "

	//Da data de faturamento inicial a final
	_cFiltro  += " AND F2.F2_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "
	_cFiltro2 += " AND F2.F2_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "
	
	//Da nota fiscal inicial a final
	_cFiltro  += " AND F2.F2_DOC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
	_cFiltro2 += " AND F2.F2_DOC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
	
	//Da carga inicial a final
	_cFiltro += " AND F2.F2_CARGA BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'"
	
	//Selecionar notas que ja foi inserido o recebimento de canhoto
	If MV_PAR07 == 2
		_cFiltro	+= " AND F2.F2_I_DTRC <> '        ' "
		_cFiltro2	+= " AND F2.F2_I_DTRC <> '        ' "
	ElseIF MV_PAR07 == 1
		_cFiltro	+= " AND F2.F2_I_DTRC = '        ' "
		_cFiltro2	+= " AND F2.F2_I_DTRC = '        ' "
	EndIf
	
	//Selecionar notas com valor de frete
	If MV_PAR12 == 1
		_cFiltro	+= " AND F2.F2_I_FRET > 0 "
		_cFiltro2	+= " AND F2.F2_I_FRET > 0 "
	EndIf

	_cFiltro	+= " %"
	_cFiltro2	+= " %"
	
	BeginSql alias _cAlias
	
		SELECT
			F2.F2_TIPO		AS TIPONF,
			F2.F2_DOC		AS DOCUMENTO,
			F2.F2_SERIE		AS SERIE,
			F2.F2_I_DTRC	AS DTRECEB,
			F2.F2_I_DTOP    AS F2_I_DTOP, 
			F2.F2_I_DENOL   AS DENOLEDI, // VER CAMPO NOVO - F2_I_DENOL // F2.F2_I_DTOL    AS DTOPLOG, 
			F2.F2_EMISSAO	AS DTEMIS,
			A1.A1_CGC		AS CGC,
			F2.F2_CLIENTE	AS CODCLI,
			F2.F2_LOJA		AS LOJA,
			A1.A1_NOME		AS RAZSOCIAL,
			A1.A1_GRPVEN	AS CODREDE,
			CY.ACY_DESCRI	AS DESCREDE,
			F2.F2_CARGA		AS CARGA,
			F2.F2_COND		AS CONDPGTO,
			F2.F2_VALBRUT	AS VLRNF,
			F2.F2_I_OBRC	AS OBSERV,
			F2.R_E_C_N_O_   AS SF2_REC
		FROM %table:SF2% F2
		JOIN %table:SA1% A1 ON A1.A1_COD = F2.F2_CLIENTE AND A1.A1_LOJA = F2.F2_LOJA
		JOIN %table:ACY% CY ON CY.ACY_GRPVEN = A1.A1_GRPVEN
		JOIN %table:DAK% DAK ON DAK.DAK_FILIAL = F2.F2_FILIAL AND DAK.DAK_COD = F2.F2_CARGA
		JOIN %table:DA4% DA4 ON DA4.DA4_COD = DAK.DAK_MOTORI
		JOIN %table:SA2% A2 ON F2.F2_I_CTRA = A2.A2_COD AND F2.F2_I_LTRA = A2.A2_LOJA 
		WHERE
			F2.%NotDel%
		AND A1.%NotDel%
		AND CY.%NotDel%
		AND DAK.%NotDel%
		AND DA4.%NotDel%
		AND A2.%NotDel%
		AND F2.F2_TIPO	NOT IN ('D','B')
		%exp:_cFiltro%
		AND A2.A2_COD	BETWEEN %exp:MV_PAR08% AND %exp:MV_PAR10%
		AND A2.A2_LOJA	BETWEEN %exp:MV_PAR09% AND %exp:MV_PAR11%

		UNION ALL
		
		SELECT
			F2.F2_TIPO		AS TIPONF,
			F2.F2_DOC		AS DOCUMENTO,
			F2.F2_SERIE		AS SERIE,
			F2.F2_I_DTRC	AS DTRECEB,
			F2.F2_I_DTOP    AS F2_I_DTOP,
			F2.F2_I_DENOL   AS DENOLEDI, // VER CAMPO NOVO - F2_I_DENOL, F2.F2_I_DTOL    AS DTOPLOG,
			F2.F2_EMISSAO	AS DTEMIS,
			A1.A1_CGC		AS CGC,
			F2.F2_CLIENTE	AS CODCLI,
			F2.F2_LOJA		AS LOJA,
			A1.A1_NOME		AS RAZSOCIAL,
			A1.A1_GRPVEN	AS CODREDE,
			CY.ACY_DESCRI	AS DESCREDE,
			F2.F2_CARGA		AS CARGA,
			F2.F2_COND		AS CONDPGTO,
			F2.F2_VALBRUT	AS VLRNF,
			F2.F2_I_OBRC	AS OBSERV,
			F2.R_E_C_N_O_   AS SF2_REC
		FROM %table:SF2% F2
		JOIN %table:SA1% A1 ON A1.A1_COD = F2.F2_CLIENTE AND A1.A1_LOJA = F2.F2_LOJA
		JOIN %table:ACY% CY ON CY.ACY_GRPVEN = A1.A1_GRPVEN
		WHERE
			F2.%NotDel%
		AND A1.%NotDel%
		AND CY.%NotDel%
		AND F2.F2_CARGA = '      '
		AND F2.F2_TIPO NOT IN ('D','B')
		%exp:_cFiltro2%
		
		UNION ALL
		
		SELECT
			F2.F2_TIPO		AS TIPONF,
			F2.F2_DOC		AS DOCUMENTO,
			F2.F2_SERIE		AS SERIE,
			F2.F2_I_DTRC	AS DTRECEB,
			F2.F2_I_DTOP    AS F2_I_DTOP,
			F2.F2_I_DENOL   AS DENOLEDI, // VER CAMPO NOVO - F2_I_DENOL // F2.F2_I_DTOL    AS DTOPLOG,
			F2.F2_EMISSAO	AS DTEMIS,
			A2.A2_CGC		AS CGC,
			F2.F2_CLIENTE	AS CODCLI,
			F2.F2_LOJA		AS LOJA,
			A2.A2_NOME		AS RAZSOCIAL,
			TO_CHAR(NULL)	AS CODREDE,
			TO_CHAR(NULL)	AS DESCREDE,
			F2.F2_CARGA		AS CARGA,
			F2.F2_COND		AS CONDPGTO,
			F2.F2_VALBRUT	AS VLRNF,
			F2.F2_I_OBRC	AS OBSERV,
			F2.R_E_C_N_O_   AS SF2_REC
		FROM %table:SF2% F2
		JOIN %table:SA2% A2 ON A2.A2_COD = F2.F2_CLIENTE AND A2.A2_LOJA = F2.F2_LOJA
		WHERE
			F2.%NotDel%
		AND	A2.%NotDel%
		AND	F2.F2_TIPO IN ('D','B')
		%exp:_cFiltro%

	EndSql

    DBSelectArea( _cAlias )
    (_cAlias)->( DBGotop() )
    COUNT TO _nNumReg

EndIf

Return()

/*
===============================================================================================================================
Programa----------: MOMS016L
Autor-------------: Fabiano Dias
Data da Criacao---: 04/07/2011
Descri��o---------: Funcao responsavel por realizar a montagem da tela com as N.F. de acordo com os parametros informados, para
------------------: selecao das notas que terao seus recebimentos de canhotos informadas.
Parametros--------: _nOpcao - Numero da consulta a ser executada.
------------------: _cAlias - Alias a ser utilizado nas consultas.
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS016L()

Local _cAliasDad	:= ""
Local x				:= 0
Local oOK			:= LoadBitmap( GetResources() , 'LBOK' )
Local oNO			:= LoadBitmap( GetResources() , 'LBNO' )
Local oFont01		:= TFont():New( "Arial" ,, 14 ,, .F. ,,,, .T. , .F. )
Local oPanel		:= Nil

Local nHeight		:= 0
Local nWidth		:= 0

Local aSize			:= {}
Local aBotoes		:= {}
Local aCoors		:= {}
Local _cAlias		:= "TRB"//TABELA TEMPORARIA 


Private oDlg1		:= Nil
Private _nNumReg	:= 0                     
Private nOpca		:= 0
Private nQtdTit		:= 0 

Private cArqTRB1	:= ""
Private cArqTRB2	:= ""
Private cArqTRB3	:= ""
Private cArqTRB4	:= "" 
Private cArqTRB5	:= ""
Private cArqTRB6	:= ""

Private aTitulo		:= {}
Private aStruct		:= {}

Private _aProdutor	:= {}

Private aObjects	:= {}
Private aPosObj1	:= {}
Private aInfo		:= {}

Private oBrowse		:= Nil
Private oFont12b	:= Nil

//===============================================================================================
// Define a fonte a ser utilizada no GRID
//===============================================================================================
Define Font oFont12b Name "Courier New" Size 0,-12 Bold  // Tamanho 12 Negrito 

//===============================================================================================
// Seleciona as N.F. para o recebimento de canhotos
//===============================================================================================
_cAliasDad:= GetNextAlias()

fwmsgrun( ,{|| MOMS016Q(1,_cAliasDad)} , 'Aguarde' , "Selecionando as notas fiscais..."  )

//===============================================================================================
// Nao existem registros para exibir
//===============================================================================================
If _nNumReg == 0

	U_ITMSG("N�o foram encontradas notas fiscais de acordo com os par�metros fornecidos.",;
			"Informa��o",;
			"Favor checar se os par�metros foram fornecidos corretamente.",1)
	RETURN .T.
	    
Else

	//===============================================================================================
	// Cria o arquivo Temporario para insercao dos dados selecionados
	//===============================================================================================
	fwMsgRun( , {||  MOMS016C(_cAlias)  }, 'Aguarde', 'Montando a estrutura de dados...' )
	
	//==============================================================================================
	// Insere os dados no arquivo temporario criado
	//===============================================================================================
    fwmsgrun( , {|| MOMS016K(_cAlias,_cAliasDad)} , 'Aguarde', "Inserindo os dados selecionados..."  )
	
	//==============================================================================================
	// Faz o calculo automatico de dimensoes de objetos
	//==============================================================================================
	aSize := MSADVSIZE()
	
	//==============================================================================================
	// Obtem tamanhos das telas
	//==============================================================================================
	aAdd( aObjects , { 0 , 0 , .T. , .T. , .T. } )
	
	aInfo		:= { aSize[1] , aSize[2] , aSize[3] , aSize[4] , 3 , 3 }
	aPosObj1	:= MsObjSize( aInfo , aObjects ,, .T. )
	
	//==============================================================================================
	// Botoes da tela.
	//==============================================================================================
	aAdd( aBotoes , { "PESQUISA"	, {|| MOMS016E(_cAlias)	} , "Pesquisar..."					, "Pesquisar"	} )
	aAdd( aBotoes , { "S4WB005N"	, {|| MOMS016U(_cAlias)	} , "Visualizar N.F."				, "N.F."		} )
	aAdd( aBotoes , { "BMPVISUAL"	, {|| MOMS016P(_cAlias)	} , "Filtrar N.F."					, "Filtro"		} )
	Aadd( aBotoes , { "RESPONSA"	, {|| MOMS016N(_cAlias)	} , "Fornecer data do Canhoto..."	, "Canhoto"		} )
	Aadd( aBotoes , { 'NOTE'        , {|| U_AOMS003(" ZF5->ZF5_FILIAL == '"+xFilial("ZF5")+"' .AND. ZF5->ZF5_DOCOC ==  '"+&(_cAlias+'->'+_cAlias+'_DOC')+"' .AND. ZF5->ZF5_SEROC ==  '"+&(_cAlias+'->'+_cAlias+"_SERIE")+"' ")},"Ocorr�ncias de frete","Ocorr�ncias de frete"})  

	//===============================================================================================
	// Cria a tela para selecao dos Titulos
	//===============================================================================================
	DEFINE MSDIALOG oDlg1 TITLE OemToAnsi("ROTINA PARA CONTROLE DE RECEBIMENTO DE CANHOTOS") From 0,0 To aSize[6]-30,aSize[5]-30 OF oMainWnd PIXEL
	
		oDlg1:lMaximized:= .T.
		
		oPanel			:= TPanel():New( 0 , 0 , '' , oDlg1 ,, .T. , .T. ,,, 315 , 30 , .T. , .T. )
		
		@ 005 , 005 Say OemToAnsi( "Quantidade:" )				OF oPanel PIXEL FONT oFont12b 
		@ 005 , 035 Say oQtda VAR nQtdTit Picture "@E 999999"	OF oPanel PIXEL FONT oFont12b SIZE 60,8
		
		If FlatMode()
		
			aCoors	:= GetScreenRes()
			nHeight	:= aCoors[2]
			nWidth	:= aCoors[1]
			
		Else
		
			nHeight	:= 143
			nWidth	:= 315
			
		Endif                    

		DBSelectArea(_cAlias)     
		(_cAlias)->( DBGotop() )
		
		oBrowse := TCBrowse():New( 15,01,aPosObj1[1,3]+07,aPosObj1[1,4]-10,,,{20,20,20,20,20,20,20,20,30,20,20,17,20,20,20,15,20,30},oDlg1,,,,,{||},, oFont01 ,,,,,.F.,_cAlias,.T.,,.F.,,.T.,.T.)

		For x:=1 to (Len(aStruct)-1)
			
			If aStruct[x,1] == _cAlias + "_STATUS"
				oBrowse:AddColumn( TCColumn():New("",{|| IIF(&(_cAlias + '->' + _cAlias + "_STATUS") == Space(2),oNO,oOK)},,,,"CENTER",,.T.,.F.,,,,.F.,) )
			Else
				oBrowse:AddColumn( TCColumn():New(OemToAnsi(aTitulo[x,2]),&("{ || " + _cAlias + '->' + aStruct[x,1]+"}"),aTitulo[x,3],,,if(aStruct[x,2]=="N","RIGHT","LEFT"),,.F.,.F.,,,,.F.,) )
			EndIf     
			
		Next x
		
		//Insere imagem em colunas que os dados poderao ser ordenados
		MOMS016G( 3 )
		
		// Evento de duplo click na celula
		oBrowse:bLDblClick := {|| MOMS016S(_cAlias,&(_cAlias + '->' + _cAlias + "_STATUS")) }
		
    	//Evento quando o usuario clica na coluna desejada
		oBrowse:bHeaderClick := {|oBrowse, nCol| nColuna:= nCol,fwMsgRun(,{|| MOMS016O(_cAlias,nColuna) },"Processando...","Organizando registros...") }
		
	
	ACTIVATE MSDIALOG oDlg1 ON INIT ( EnchoiceBar( oDlg1 , {|| Eval({|| nOpca := 1,oDlg1:End()})} , {|| nOpca := 2,oDlg1:End()},,aBotoes,,,,,,.f.,,),oPanel:Align	:= CONTROL_ALIGN_TOP, oBrowse :Align	:= CONTROL_ALIGN_ALLCLIENT, oBrowse:Refresh() )
    // ACTIVATE MSDIALOG oDlg	ON INIT    EnchoiceBar(oDlg  ,{ || EVAL(bOk,oDlg)                    },{ || EVAL(bCancel,oDlg) }   ,,aButtons,,,,,,_lHasOk,,) CENTERED
	//===============================================================================================
	// Fecha a area de uso do arquivo temporario no Protheus.
	//===============================================================================================
	(_cAlias)->( DBCloseArea() )
	
EndIf

RETURN (nOpca=1)

/*
===============================================================================================================================
Programa----------: MOMS016C
Autor-------------: Fabiano Dias
Data da Criacao---: 04/07/2011
Descri��o---------: Cria tabela temporaria para montagem da tela
Parametros--------: _cAlias - Alias a ser utilizado
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS016C(_cAlias)

aStruct  := {}            
aTitulo  := {}                            

//================================================================================
// Criando estrutura da tabela temporaria das unidades
//================================================================================
aAdd( aStruct , { _cAlias +"_STATUS"  , "C" , 02,0    } )
aAdd( aStruct , { _cAlias +"_STATC"   , "C" , 16,0    } )
aAdd( aStruct , { _cAlias +"_TIPONF"  , "C" , 21,0    } )
aAdd( aStruct , { _cAlias +"_DOC"     , "C" , 09,0    } )
aAdd( aStruct , { _cAlias +"_SERIE"   , "C" , 03,0    } )
aAdd( aStruct , { _cAlias +"_DTREC"   , "D" , 08,0    } )
aAdd( aStruct , { _cAlias +"_DTOP"    , "D" , 08,0    } )
aAdd( aStruct , { _cAlias +"_DTLOGE"  , "D" , 08,0    } )
aAdd( aStruct , { _cAlias +"_DTEMIS"  , "D" , 08,0    } )
aAdd( aStruct , { _cAlias +"_CGC"     , "C" , 18,0    } )
aAdd( aStruct , { _cAlias +"_CODCLI"  , "C" , 06,0    } )
aAdd( aStruct , { _cAlias +"_LOJCLI"  , "C" , 04,0    } )
aAdd( aStruct , { _cAlias +"_DESCLI"  , "C" , 50,0    } )
aAdd( aStruct , { _cAlias +"_CODRED"  , "C" , 06,0    } )
aAdd( aStruct , { _cAlias +"_DESRED"  , "C" , 30,0    } )
aAdd( aStruct , { _cAlias +"_CARGA"   , "C" , 06,0    } )
aAdd( aStruct , { _cAlias +"_CONDPG"  , "C" , 09,0    } )
aAdd( aStruct , { _cAlias +"_VLRNF"   , "N" , 14,2    } )
aAdd( aStruct , { _cAlias +"_OBSRV"   , "C" , 50,0    } )
aAdd( aStruct , { "SF2_REC"           , "N" , 14,0    } )

//=================================================================================
// Armazena no array aCampos o nome, descricao dos campos e picture
//=================================================================================
AAdd( aTitulo , { _cAlias +"_STATUS"  , "  "					, "  "													} )
AAdd( aTitulo , { _cAlias +"_STATC"   , "Status do canhoto"  	, ""	                                                } )
AAdd( aTitulo , { _cAlias +"_TIPONF"  , "Tipo N.F."  			, "@!"													} )
AAdd( aTitulo , { _cAlias +"_DOC"     , "Nota fiscal"			, "@!"													} )
AAdd( aTitulo , { _cAlias +"_SERIE"   , "Serie"      			, "@!"													} )
AAdd( aTitulo , { _cAlias +"_DTREC"   , "Dt.canhoto"    		, "@!"													} )
AAdd( aTitulo , { _cAlias +"_DTOP"    , "Ent.oplog.dt.canhoto"  , "@!"	   												} )
AAdd( aTitulo , { _cAlias +"_DTLOGE"  , "Dt.ent.operador"   	, "@!"													} )
AAdd( aTitulo , { _cAlias +"_DTEMIS"  , "Emissao"    			, "@!"													} )
AAdd( aTitulo , { _cAlias +"_CGC"     , "CPF/CNPJ"   			, "@!"													} )
AAdd( aTitulo , { _cAlias +"_CODCLI"  , "Cliente"    			, "@!"													} )
AAdd( aTitulo , { _cAlias +"_LOJCLI"  , "Loja"       		  	, "@!"													} )
AAdd( aTitulo , { _cAlias +"_DESCLI"  , "Descricao do cliente"	, "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"	} )
AAdd( aTitulo , { _cAlias +"_CODRED"  , "Rede"		 			, "@!"													} )
AAdd( aTitulo , { _cAlias +"_DESRED"  , "Descricao da rede"   	, "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"						} )
AAdd( aTitulo , { _cAlias +"_CARGA"   , "Carga"      			, "@!"													} )
AAdd( aTitulo , { _cAlias +"_CONDPG"  , "Cond.pgto"  			, "@!"													} )
AAdd( aTitulo , { _cAlias +"_VLRNF"   , "Valor N.F." 			, PESQPICT("SF2","F2_VALBRUT")							} )
AAdd( aTitulo , { _cAlias +"_OBSRV"   , "Observ.receb.canhoto"	, "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"	} )

//=================================================================================
// Verifica se ja existe um arquivo com mesmo nome, se sim deleta
//=================================================================================
If Select(_cAlias) <> 0
	(_cAlias)->( DBCloseArea() )
EndIf

_otemp := FWTemporaryTable():New( _cAlias, aStruct )

_otemp:AddIndex( "01", {_cAlias + "_DOC" , _cAlias + "_SERIE" , _cAlias + "_CODCLI", _cAlias + "_LOJCLI"} )
_otemp:AddIndex( "02", {_cAlias + "_DESCLI"} )
_otemp:AddIndex( "03", {_cAlias + "_CODCLI" , _cAlias + "_LOJCLI"} )
_otemp:AddIndex( "04", {_cAlias + "_CGC"} )
_otemp:AddIndex( "05", {_cAlias + "_CARGA"} )
_otemp:AddIndex( "06", {_cAlias + "_STATC"} )

_otemp:Create()

//=================================================================================
// Agrega um arquivo de indice a um Alias ativo no sistema
//=================================================================================
DBSelectArea( _cAlias )

Return()

/*
===============================================================================================================================
Programa----------: MOMS016K
Autor-------------: Fabiano Dias
Data da Criacao---: 04/07/2011
Descri��o---------: Funcao usada para inserir os dados selecionados atraves da pesquisa no arquivo temporario
Parametros--------: _cAlias    - Alias a ser utilizado para grava��o dos dados
------------------: _cAliasDad - Alias que cont�m os dados a serem gravados
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS016K( _cAlias , _cAliasDad )

Local _cTipoNf := ""

DBSelectArea(_cAliasDad)
(_cAliasDad)->( DBGoTop() )

ProcRegua(_nNumReg)

While (_cAliasDad)->( !Eof() )

	//================================================================================
	//Verifica se est� de acordo com filtro de status
	//C=Aguardando Conf;A=Aprovado;R=Reprovado;N=Nao recepcionado
	//================================================================================
	_cstat := U_MOMS016J((_cAliasDad)->DOCUMENTO,(_cAliasDad)->SERIE)
	If !EMPTY(ALLTRIM(MV_PAR13))
	
		IF (_cstat == "Nao recepcionado" .AND. !("N" $ MV_PAR13)) .OR.;
		   (_cstat == "Aprovado"         .AND. !("A" $ MV_PAR13)) .OR.;
		   (_cstat == "Reprovado"        .AND. !("R" $ MV_PAR13)) .OR.;
		   (_cstat == "Aguardando Conf"  .AND. !("C" $ MV_PAR13)) 
		   
		   (_cAliasDad)->( DBSkip() )
		   Loop
			
		Endif
		
	Endif
			
	
	//================================================================================
	// Verifica o tipo da NF
	//================================================================================
	IncProc("Lendo NF: "+(_cAliasDad)->DOCUMENTO)
	
	Do Case
	
		Case (_cAliasDad)->TIPONF == 'N'	
			_cTipoNf := "Normal"
			
		Case (_cAliasDad)->TIPONF == 'D'	
			_cTipoNf := "Devolucao"
			
		Case (_cAliasDad)->TIPONF == 'C'	
			_cTipoNf := "Complemento Precos"
			
		Case (_cAliasDad)->TIPONF == 'I'	
			_cTipoNf := "Complemento ICMS"
			
		Case (_cAliasDad)->TIPONF == 'P'	
			_cTipoNf := "Complemento IPI"
			
		Case (_cAliasDad)->TIPONF == 'B'	
			_cTipoNf := "Utiliza Fornecedor"
		
	EndCase
	
	DbSelectArea(_cAlias)
	(_cAlias)->( RecLock( _cAlias , .T. ) )
		
		&( _cAlias +'->'+ _cAlias +'_STATUS'	) := Space(2)
		&( _cAlias +'->'+ _cAlias +'_TIPONF'	) := _cTipoNf
		&( _cAlias +'->'+ _cAlias +'_DOC'		) := (_cAliasDad)->DOCUMENTO
		&( _cAlias +'->'+ _cAlias +'_SERIE'		) := (_cAliasDad)->SERIE
		&( _cAlias +'->'+ _cAlias +'_DTREC'		) := StoD( (_cAliasDad)->DTRECEB )
		&( _cAlias +'->'+ _cAlias +'_DTOP'		) := StoD( (_cAliasDad)->F2_I_DTOP )
		&( _cAlias +'->'+ _cAlias +'_DTLOGE'	) := StoD( (_cAliasDad)->DENOLEDI)
		&( _cAlias +'->'+ _cAlias +'_DTEMIS'	) := StoD( (_cAliasDad)->DTEMIS )
		&( _cAlias +'->'+ _cAlias +'_CGC'		) := IIF( Len(AllTrim((_cAliasDad)->CGC)) == 14 , Transform(AllTrim((_cAliasDad)->CGC) , "@R! NN.NNN.NNN/NNNN-99") , Transform(AllTrim((_cAliasDad)->CGC) , "@R 999.999.999-99" ) )
		&( _cAlias +'->'+ _cAlias +'_CODCLI'	) := (_cAliasDad)->CODCLI
		&( _cAlias +'->'+ _cAlias +'_LOJCLI'	) := (_cAliasDad)->LOJA
		&( _cAlias +'->'+ _cAlias +'_DESCLI'	) := (_cAliasDad)->RAZSOCIAL
		&( _cAlias +'->'+ _cAlias +'_CODRED'	) := (_cAliasDad)->CODREDE
		&( _cAlias +'->'+ _cAlias +'_DESRED'	) := (_cAliasDad)->DESCREDE
		&( _cAlias +'->'+ _cAlias +'_CARGA'		) := (_cAliasDad)->CARGA
		&( _cAlias +'->'+ _cAlias +'_CONDPG'	) := (_cAliasDad)->CONDPGTO
		&( _cAlias +'->'+ _cAlias +'_VLRNF'		) := (_cAliasDad)->VLRNF
		&( _cAlias +'->'+ _cAlias +'_OBSRV'		) := (_cAliasDad)->OBSERV
		&( _cAlias +'->'+ _cAlias +'_STATC'		) := _cstat
		(_cAlias)->SF2_REC                        := (_cAliasDad)->SF2_REC
		
	(_cAlias)->( MsUnlock() )

(_cAliasDad)->( DBSkip() )
EndDo

(_cAliasDad)->( DBCloseArea() )

Return()

/*
===============================================================================================================================
Programa----------: MOMS016G
Autor-------------: Fabiano Dias
Data da Criacao---: 04/07/2011
Descri��o---------: Funcao para setar a coluna com uma imagem que identifica se ela esta ordenada ou nao
Parametros--------: _nCol - N�mero da Coluna
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS016G( _nCol )

Local _aColunas	:= {}
Local _nI		:= 0

aAdd( _aColunas , {03} )
aAdd( _aColunas , {07} )
aAdd( _aColunas , {08} )
aAdd( _aColunas , {10} )
aAdd( _aColunas , {13} )

For _nI := 1 To Len( _aColunas )
	
	//================================================================================
    // Seta a imagem na coluna ordenada e as demais colunas como nao ordenadas
	//================================================================================
	If _nCol == _aColunas[_nI][01]
		oBrowse:SetHeaderImage( _aColunas[_nI][01] , "COLDOWN"	)
	Else     
		oBrowse:SetHeaderImage( _aColunas[_nI][01] , "COLRIGHT"	)
	EndIf

Next _nI

Return()

/*
===============================================================================================================================
Programa----------: MOMS016S
Autor-------------: Fabiano Dias
Data da Criacao---: 04/07/2011
Descri��o---------: Funcao para atualizar o Status de marca��o para os �tens que forem sendo processados
Parametros--------: _cAlias  - Alias da Tabela que est� sendo utilizada
------------------: _cStatus - Marca��o do campo
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS016S( _cAlias , _cStatus )

If _cStatus == Space(2) 
	
	(_cAlias)->( RecLock( _cAlias , .F. ) )
	&( _cAlias +'->'+ _cAlias +'_STATUS' ) := 'XX'
	(_cAlias)->( MsUnlock() )
	
	nQtdTit++
	
Else
	
	(_cAlias)->( RecLock( _cAlias , .F. ) )
	&( _cAlias +'->'+ _cAlias +'_STATUS' ) := Space(2)
	(_cAlias)->( MsUnlock() )
	
	nQtdTit--
	
EndIf

nQtdTit := IIf( nQtdTit < 0 , 0 , nQtdTit )

oQtda:Refresh()

oBrowse:DrawSelect()
oBrowse:Refresh(.T.)

Return()

/*
===============================================================================================================================
Programa----------: MOMS016O
Autor-------------: Fabiano Dias
Data da Criacao---: 04/07/2011
Descri��o---------: Funcao para ordenar os dados na tela
Parametros--------: _cAlias  - Alias da Tabela que est� sendo utilizada
------------------: _nColuna - Coluna de base para a ordena��o
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS016O( _cAlias , _nColuna )

Local _aArea:= GetArea()

Do Case

	//Marca ou desmarca todos os titulos selecionados 	
	Case _nColuna == 1
	
		DBSelectArea(_cAlias)
		(_cAlias)->(dbGotop())
		
		While (_cAlias)->(!Eof())   
		
			//Se o titulo nao estiver selecionado
			If &(_cAlias+'->'+_cAlias+'_STATUS') == Space(2)
			
				RecLock( _cAlias , .F. )
				&(_cAlias+'->'+_cAlias+'_STATUS'):= 'XX'
				(_cAlias)->( MsUnlock() )
				
				nQtdTit++
			
			//Titulo selecionado
			Else
			
				RecLock( _cAlias , .F. )
				&(_cAlias+'->'+_cAlias+'_STATUS') := Space(2)
				(_cAlias)->( MsUnlock() )
				
				nQtdTit--
			
			EndIf
		
		(_cAlias)->( DBSkip() )
		EndDo
		
		nQtdTit := IIf( nQtdTit < 0 , 0 , nQtdTit )
		
		oQtda:Refresh()
		
		restArea(_aArea)
	
	//Status do canhoto
	Case _nColuna == 2
	
		DBSelectArea(_cAlias)
		(_cAlias)->( DBSetOrder(6) )
		(_cAlias)->( DBGoTop() )
	
		
	//Numero da N.F. + Serie + Codigo do Cliente + Loja
	Case _nColuna == 4
	
		DBSelectArea(_cAlias)
		(_cAlias)->( DBSetOrder(1) )
		(_cAlias)->( DBGoTop() )
	
	//CPF/CGC do cliente
	Case _nColuna == 8
	
		DBSelectArea(_cAlias)
		(_cAlias)->( DBSetOrder(4) )
		(_cAlias)->( DBGoTop() )
	
	//Codigo do Cliente + Loja
	Case _nColuna == 9
	
		DBSelectArea(_cAlias)
		(_cAlias)->( DBSetOrder(3) )
		(_cAlias)->( DBGoTop() )
	
	//Descricao do Cliente
	Case _nColuna == 11
	
		DBSelectArea(_cAlias)
		(_cAlias)->( DBSetOrder(2) )
		(_cAlias)->( DBGoTop() )
	
	//Carga
	Case _nColuna == 14
	
		DBSelectArea(_cAlias)
		(_cAlias)->( DBSetOrder(5) )
		(_cAlias)->( DBGoTop() )
	
EndCase

MOMS016G( _nColuna )

(_cAlias)->(dbGotop())

oBrowse:DrawSelect()
oBrowse:Refresh(.T.)

Return()

/*
===============================================================================================================================
Programa----------: MOMS016E
Autor-------------: Fabiano Dias
Data da Criacao---: 04/07/2011
Descri��o---------: Funcao para pesquisar os dados no Alias tempor�rio
Parametros--------: _cAlias  - Alias da Tabela que est� sendo utilizada
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS016E( _cAlias )

Local oDlg			:= Nil

Local aComboBx1		:= { "NOTA FISCAL + SERIE + CLIENTE + LOJA","DESCRICAO DO CLIENTE","CLIENTE + LOJA" , "CPF/CNPJ" , "CARGA" }
Local aCombForm		:= { "CNPJ" , "CPF" }
Local nOpca			:= 0
Local nI			:= 0

Private cGet1		:= SPACE(22)
Private oGet1		:= Nil
Private cComboBx1	:= ""
Private cCombForm	:= ""

//================================================================================
// DEFINE MSDIALOG oDlg TITLE "Pesquisar" FROM 178,181 TO 259,697 PIXEL
//================================================================================
@178,181 TO 259,697 Dialog oDlg Title "Pesquisar"

@004,003 ComboBox cComboBx1 Items aComboBx1	OF oDlg Size 213,010 PIXEL ON CHANGE MOMS016B(oDlg)
@020,003 MsGet oGet1 Var cGet1				OF oDlg Size 212,009 PIXEL COLOR CLR_BLACK Picture "@!"

@046,003 Say OemToAnsi("Escolha o formato para CPF/CNPJ:")	OF oDlg PIXEL
@041,092 ComboBox cCombForm Items aCombForm 				OF oDlg PIXEL Size 050,010 ON CHANGE MOMS016M()

DEFINE SBUTTON FROM 004,227 TYPE 1 ENABLE ACTION (nOpca:=1,oDlg:End()) OF oDlg
DEFINE SBUTTON FROM 021,227 TYPE 2 ENABLE ACTION (nOpca:=0,oDlg:End()) OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1

	If !Empty(cGet1)
	
		For nI := 1 To Len( aComboBx1 )
		
			If cComboBx1 == aComboBx1[nI]
			
				DBSelectArea(_cAlias)
				(_cAlias)->( DBSetOrder(nI) )
				(_cAlias)->( DBGoTop() )
				(_cAlias)->( DBSeek( AllTrim( cGet1 ) ) )
				
				oBrowse:DrawSelect()
				oBrowse:Refresh(.T.)
				
				Exit
				
			EndIf
			
		Next nI
	
	Else
	
		U_ITMSG("Favor informar um conte�do a ser pesquisado.",;
				"Pesquisa de Dados",;
				"Para realizar a pesquisa � necess�rio que se forne�a o conte�do a ser pesquisado.",3)
		
		
	
	EndIf

EndIf

Return()

/*
===============================================================================================================================
Programa----------: MOMS016M
Autor-------------: Fabiano Dias
Data da Criacao---: 04/07/2011
Descri��o---------: Funcao para identificar a mascara do campo
Parametros--------: _cAlias  - Alias da Tabela que est� sendo utilizada
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS016M()

If cCombForm == "CPF"

	cGet1 := Space(14)
	oGet1:Picture := "@E 999.999.999-99"
	
Else

	cGet1 := Space(18)
	oGet1:Picture := "@R! NN.NNN.NNN/NNNN-99"
	
EndIf

oGet1:SetFocus()

Return()

/*
===============================================================================================================================
Programa----------: MOMS016B
Autor-------------: Fabiano Dias
Data da Criacao---: 04/07/2011
Descri��o---------: Funcao para alterar a mascara do campo
Parametros--------: oDlg - Objeto da Dialog que dever� ser alterado
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS016B( oDlg )

If cComboBx1 == "NOTA FISCAL + SERIE + CLIENTE + LOJA"

	cGet1			:= SPACE(22)
	oGet1:Picture	:= "@!"
	oDlg:nHeight	:= 110

ElseIf cComboBx1 == "DESCRICAO DO CLIENTE"

	cGet1			:= Space(50)
	oGet1:Picture	:= "@!"
	oDlg:nHeight	:= 110

ElseIf cComboBx1 == "CPF/CNPJ"

	cGet1			:= Space(18)
	oGet1:Picture	:= "@R! NN.NNN.NNN/NNNN-99"
	oDlg:nHeight	:= 145

ElseIf cComboBx1 == "CLIENTE + LOJA"

	cGet1			:= Space(10)
	oGet1:Picture	:= "@!"
	oDlg:nHeight	:= 110

ElseIf cComboBx1 == "CARGA"

	cGet1			:= Space(06)
	oGet1:Picture	:="@!"
	oDlg:nHeight	:= 110
	
EndIf

oGet1:SetFocus()

Return()

/*
===============================================================================================================================
Programa----------: MOMS016U
Autor-------------: Fabiano Dias
Data da Criacao---: 04/07/2011
Descri��o---------: Funcao para visualizar a NF selecionada
Parametros--------: oDlg - Objeto da Dialog que dever� ser alterado
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS016U(_cAlias)

Local aArea			:= GetArea()
Local aRotBack		:= {}
Local cCadBack		:= ''
Local lRet			:= .T.

Local nBack			:= 0

Local _cFilial		:= xFilial("SD2")
Local _cDoc			:= &(_cAlias+'->'+_cAlias+'_DOC')
Local _cSerie		:= &(_cAlias+'->'+_cAlias+'_SERIE')
Local _cCliente		:= &(_cAlias+'->'+_cAlias+'_CODCLI')
Local _cLoja		:= &(_cAlias+'->'+_cAlias+'_LOJCLI')

If Type( "N" ) == "N"

	nBack := n
	n     := 1
	
EndIf

//================================================================================
// Caso exista, faz uma copia do aRotina
//================================================================================
If Type( "aRotina" ) == "A"
	aRotBack := AClone( aRotina )
EndIf

//================================================================================
// Caso exista, faz uma copia do cCadastro
//================================================================================
If Type( "cCadastro" ) == "C"
	cCadBack := cCadastro
EndIf

//================================================================================
// Pesquisa e exibe a nota
//================================================================================
DBSelectArea("SD2")   
SD2->( DBSetOrder(3) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
If SD2->( DBSeek( _cFilial + _cDoc + _cSerie + _cCliente + _cLoja ) )

	aRotina := { { "" , "AxPesqui" , 2 } , { "" , "a920NFSAI" , 0 , 2 } }
	A920NFSAI( "SD2" , SD2->( Recno() ) , 2 )

EndIf

//================================================================================
// Restaura o aRotina
//================================================================================
If ValType( aRotBack ) == "A"
	aRotina := AClone( aRotBack )
EndIf

//================================================================================
// Caso exista, faz uma copia do cCadastro
//================================================================================
If Type( "cCadBack" ) == "C"
	cCadastro := cCadBack
EndIf

If ValType( nBack ) == "N"
	n := nBack
EndIf

RestArea( aArea )

Return( lRet )

/*
===============================================================================================================================
Programa----------: MOMS016P
Autor-------------: Fabiano Dias
Data da Criacao---: 04/07/2011
Descri��o---------: Funcao para processar novamente os filtros da parametriza��o inicial
Parametros--------: _cAlias - Alias da tabela para processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS016P( _cAlias )

Local _cAliasDad	:= ""

//================================================================================
// Chama tela para selecao do Filtro
//================================================================================
If !Pergunte( _cPerg , .T. )
	Return()
EndIf

//=================================================================================
// Seleciona as N.F. para o recebimento de canhotos
//=================================================================================
_cAliasDad := GetNextAlias()

_nNumReg:= 0

fwmsgrun( , {|| MOMS016Q(1,_cAliasDad)} , 'Aguarde', "Selecionando as notas fiscais..."  )

If _nNumReg > 0

	//=================================================================================
	// Cria o arquivo Temporario para insercao dos dados selecionados
	//=================================================================================
	fwMsgRun( , {|| MOMS016C(_cAlias) },  'Aguarde', "Montando a estrutura de dados..."  )

	//=================================================================================
	// Insere os dados no arquivo temporario criado
	//=================================================================================
    fwmsgrun( ,{|| MOMS016K(_cAlias,_cAliasDad)} , 'Aguarde', "Inserindo os dados selecionados..."  )

	DBSelectArea(_cAlias)
	(_cAlias)->( DBGotop() )
	
	
Else

	U_ITMSG("N�o foram encontradas notas fiscais de acordo com os par�metros fornecidos.",;
			"Informa��o",;
			"Favor checar se os par�metros foram fornecidos corretamente.",1)
	
EndIf

oBrowse:DrawSelect()
oBrowse:Refresh(.T.)

Return()

/*
===============================================================================================================================
Programa----------: MOMS016N
Autor-------------: Fabiano Dias
Data da Criacao---: 04/07/2011
Descri��o---------: Funcao usada verificar quais as notas foram selecionadas para insercao dos dados do canhoto para chamar a
------------------: a rotina de insercao de dados do canhoto.
Parametros--------: _cAlias - Alias da tabela para processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS016N(_cAlias)

Private _nOpcao := 0

If nQtdTit > 0

	DBSelectArea( _cAlias )
	(_cAlias)->( DBGotop() )
	
	While (_cAlias)->( !Eof() )
		
		//================================================================================
		// Caso a linha de registros tenha sido marcada para alteracao dos dados do 
		// canhoto, chamara tela para realizar a possivel alteracao
		//================================================================================
		If &(_cAlias+'->'+_cAlias+'_STATUS') == 'XX'
		
			MOMS016A(_cAlias)
			nQtdTit--
			
			//================================================================================
			// Logo apos a insercao dos dados do canhoto o registro posicionado volta o seu 
			// estatus para nao marcado.
			//================================================================================
			&(_cAlias+'->'+_cAlias+'_STATUS') := Space(2)
			
		EndIf
		
		//================================================================================
		// Altera��o para grava��o dos registros item a item
		//================================================================================
		If _nOpcao == 1
		
			MOMS016I(_cAlias)
			_nOpcao := 0
			
		Endif
		
	(_cAlias)->( DBSkip() )
	EndDo
	
	(_cAlias)->( DBGotop() )
	
	nQtdTit := IIf( nQtdTit < 0 , 0 , nQtdTit )
	
	oQtda:Refresh()
	
Else

	U_ITMSG("Para realizar a execu��o desta rotina � necess�rio selecionar pelo menos um registro de dados.",;
			"Informa��o",;
			"Favor selecionar as notas desejadas para realizar a inser��o dos dados do canhoto.",3)
	
	
EndIf

Return()

/*
===============================================================================================================================
Programa----------: MOMS016A
Autor-------------: Fabiano Dias
Data da Criacao---: 04/07/2011
Descri��o---------: Funcao usada realizar a insercao dos dados do canhoto nos registros selecionados pelo usuario
Parametros--------: _cAlias - Alias da tabela para processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS016A( _cAlias )

Local oDlg2			:= Nil
Local oGCarga		:= Nil
Local cGCarga		:= &( _cAlias +'->'+ _cAlias +'_CARGA' ) 
Local oGCGC			:= Nil
Local cGCGC			:= &( _cAlias +'->'+ _cAlias +'_CGC' )
Local oGCliente		:= Nil
Local cGCliente		:= &( _cAlias +'->'+ _cAlias +'_CODCLI' ) +'/'+ &( _cAlias +'->'+ _cAlias +'_LOJCLI' )
Local oGDescCli		:= Nil
Local cGDescCli		:= &( _cAlias +'->'+ _cAlias +'_DESCLI' )
Local oGEmissao		:= Nil
Local cGEmissao		:= &( _cAlias +'->'+ _cAlias +'_DTEMIS' )
Local oGetDtCanh	:= Nil
Local oGetObser		:= Nil
Local cGetObser		:= &( _cAlias +'->'+ _cAlias +'_OBSRV' )
Local oGNumNF		:= Nil
Local cGNumNF		:= &( _cAlias +'->'+ _cAlias +'_DOC' ) 
Local oGRede		:= Nil
Local cGRede		:= &( _cAlias +'->'+ _cAlias +'_CODRED' ) +'/'+ &( _cAlias +'->'+ _cAlias +'_DESRED' )
Local oGSerie		:= Nil
Local cGSerie		:= &( _cAlias +'->'+ _cAlias +'_SERIE' )
Local oGTipNF		:= Nil
Local cGTipNF		:= &( _cAlias +'->'+ _cAlias +'_TIPONF' )
Local oGVlrNF		:= Nil
Local cGVlrNF		:= AllTrim( Transform( &( _cAlias +'->'+ _cAlias +'_VLRNF' ) , PesqPict( "SF2" , "F2_VALBRUT" ) ) )
Local oGetstat      := Nil
//Local oGetDtop      := Nil
Local _nLin1, _nLin2

//Local oGetOperLog   := Nil
Local cNOperLog     := ""

//------ carrega as datas com os dados da nota do produto
Local _dPrevEOL //:= SF2->F2_I_PENOL // Previs�o de entrega no operador log�stico 
Local _dPrevECL //:= SF2->F2_I_PENCL // Previs�o de entrega no cliente
Local _dChegOL  //:= SF2->F2_I_DCHOL // Data de chegada no operador log�stico 
Local _dChegCL  //:= SF2->F2_I_DCHCL // Data de chegada no cliente
Local _dEntrCL  //:= SF2->F2_I_DENCL // Data de entrega no cliente
Local _cAprOperL  := ""
Local _aBotoes  := {}

Private cGetstat      := IIF(EMPTY(&(_cAlias+'->'+_cAlias+'_STATC')),"Nao recepcionado",ALLTRIM(&(_cAlias+'->'+_cAlias+'_STATC')))  

Private cGetDtCanh  := &(_cAlias+'->'+_cAlias+'_DTREC') 
//Private cGetDtOp  := &(_cAlias+'->'+_cAlias+'_DTLOG') 
Private _dEntrOL    := Ctod("") // SF2->F2_I_DENOL // Data de entrega no operador log�stico  EDI // N�O pode MAIS ser editado.
Private _dEntOLCha  := Ctod("") // SF2->F2_I_DTOP  // Data em que o Transportador Entregou efetivamente a Carga no Operador Log�stico // pode ser editado.

//------ Incializa as vari�veis data
_dPrevEOL := Ctod("") // Previs�o de entrega no operador log�stico 
_dChegOL  := Ctod("") // Data de chegada no operador log�stico 
_dPrevECL := Ctod("") // Previs�o de entrega no cliente
_dChegCL  := Ctod("") // Data de chegada no cliente
_dEntrCL  := Ctod("") // Data de entrega no cliente

cAprovacao:=""
cNOperLog := ""

IF (_cAlias)->SF2_REC <> 0
   SF2->(DBGOTO((_cAlias)->SF2_REC))
   cAprovCanh  := ""
   ZGJ->(Dbsetorder(1))
   IF ZGJ->(Dbseek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE))
      cGetstat    := ZGJ->ZGJ_STATUS
      cGetDtCanh  := ZGJ->ZGJ_DTENT
      cAprovCanh  := UsrFullName(ALLTRIM(ZGJ->ZGJ_APROVA))
      cDatavCanh  := DTOC(ZGJ->ZGJ_DATAA)
      cHoravCanh  := ZGJ->ZGJ_HORAA
      cGetObser   := ZGJ->ZGJ_OBS
   ELSE
      cGetDtCanh  := SF2->F2_I_DTRC // data do cliente 
      cDatavCanh  := DTOC(SF2->F2_I_CDATA)
      cHoravCanh  := SF2->F2_I_CHORA
      cGetObser   := SF2->F2_I_OBRC
      IF !EMPTY(cGetDtCanh)
         cGetstat := "Aprovado"
      ENDIF
   ENDIF

   //cAprovCanh  := "" // UsrFullName((__cUserId))

   _cAprOperL  := ""

   IF EMPTY(cAprovCanh)//Pq o conteudo do campo ZGJ_APROVA dos antigos n�o � __cUserID, coloquei a partir de 16/06/2022
      cAprovCanh  := UsrFullName((SF2->F2_I_CUSER))
   ENDIF
   IF EMPTY(cAprovCanh)//Pq se conteudo do campo F2_I_CUSER for branco e o ZGJ_APROVA for o antigo vai ele mesmo
      cAprovCanh  := ZGJ->ZGJ_APROVA
   ENDIF
   cAprovacao:=ALLTRIM(cAprovCanh)
   IF !EMPTY(CTOD(cDatavCanh))
      cAprovacao+=" - "+cDatavCanh
   ENDIF
   IF !EMPTY(cHoravCanh)
      cAprovacao+=" - "+cHoravCanh
   ENDIF

   //------ carrega as datas Operador Logistico/Redespacho e Clientes com os dados da nota do produto
   _dPrevEOL := SF2->F2_I_PENOL // Previs�o de entrega no operador log�stico 
   _dChegOL  := SF2->F2_I_DCHOL // Data de chegada no operador log�stico EDI
   _dEntrOL  := SF2->F2_I_DENOL // Data de entrega no operador log�stico  EDI // Vem preenchido e o usu�rio //N�O pode MAIS ser editar.
   _dEntOLCha:= SF2->F2_I_DTOP  // Data em que o Transportador Entregou efetivamente a Carga no Operador Log�stico // pode ser editado.
   //-------------------------------------
   _dPrevECL := SF2->F2_I_PENCL // Previs�o de entrega no cliente 
   _dChegCL  := SF2->F2_I_DCHCL // Data de chegada no cliente  EDI
   _dEntrCL  := SF2->F2_I_DENCL // Data de entrega no cliente  EDI
   
   If ! Empty(SF2->F2_I_OUSER)
      _cAprOperL  := UsrFullName(SF2->F2_I_OUSER) + " - " + DToc(SF2->F2_I_ODATA) + " - " + SF2->F2_I_OHORA
   EndIf 

ENDIF

_nLin1 := 29  // soma 27
_nLin2 := 37  // soma 27

aAdd( _aBotoes, {'NOTE'     ,{||U_AOMS003(" ZF5->ZF5_FILIAL == '"+xFilial("ZF5")+"' .AND. ZF5->ZF5_DOCOC ==  '"+cGNumNF+"' .AND. ZF5->ZF5_SEROC ==  '"+cGSerie+"' " )},"Ocorr�ncias de frete"})  

DEFINE MSDIALOG oDlg2 TITLE "ALTERA��O DOS DADOS DO RECEBIMENTO DO CANHOTO" FROM 000, 000  TO 600, 1200  of oDlg1 PIXEL // 450, 1200 

	oPanel	:= TPanel():New( 0 , 0 , '' , oDlg2 ,, .T. , .T. ,,, 315 , 100 , .T. , .T. )

	@ 002, 014 SAY "Tipo da N.F."				SIZE 032, 007 PIXEL OF oPanel  
	@ 010, 014 MSGET oGTipNF VAR cGTipNF		SIZE 060, 010 PIXEL OF oPanel READONLY
	
	@ 002, 098 SAY "Numero da N.F."				SIZE 048, 007 PIXEL OF oPanel 
	@ 010, 097 MSGET oGNumNF VAR cGNumNF		SIZE 060, 010 PIXEL OF oPanel READONLY
	
	@ 002, 193 SAY "Serie"						SIZE 025, 007 PIXEL OF oPanel 
	@ 010, 193 MSGET oGSerie VAR cGSerie		SIZE 060, 010 PIXEL OF oPanel READONLY
	
	@ 002, 268 SAY "Cliente/Loja"				SIZE 033, 007 PIXEL OF oPanel 
	@ 010, 268 MSGET oGCliente VAR cGCliente	SIZE 060, 010 PIXEL OF oPanel READONLY
	
	@ 002, 343 SAY "Descri��o do Cliente"		SIZE 067, 007 PIXEL OF oPanel 
	@ 010, 343 MSGET oGDescCli VAR cGDescCli	SIZE 200, 010 PIXEL OF oPanel READONLY
	
	@ 029, 014 SAY "CNPJ/CPF"					SIZE 025, 007 PIXEL OF oPanel 
	@ 037, 014 MSGET oGCGC VAR cGCGC			SIZE 060, 010 PIXEL OF oPanel READONLY
	
	@ 029, 097 SAY "Codigo da Rede/Descri��o"	SIZE 074, 007 PIXEL OF oPanel 
	@ 037, 097 MSGET oGRede VAR cGRede			SIZE 074, 010 PIXEL OF oPanel READONLY
	
	@ 029, 193 SAY "Emiss�o"					SIZE 025, 007 PIXEL OF oPanel 
	@ 037, 193 MSGET oGEmissao VAR cGEmissao	SIZE 060, 010 PIXEL OF oPanel READONLY
	
	@ 029, 268 SAY "Carga"						SIZE 025, 007 PIXEL OF oPanel 
	@ 037, 268 MSGET oGCarga VAR cGCarga		SIZE 060, 010 PIXEL OF oPanel READONLY
	
	@ 029, 343 SAY "Valor da N.F."				SIZE 036, 007 PIXEL OF oPanel 
	@ 037, 343 MSGET oGVlrNF VAR cGVlrNF		SIZE 060, 010 PIXEL OF oPanel READONLY

	//S� mostra campo de data de operador logistico para notas que tem operador logistico ou ocorr�ncia de op logistico
	_loplog:=U_Nfoplog(cfilant,cGNumNF,cGSerie)//nota tem operador logistico
	If _loplog//Para alterar no DEBUG

        _nLin1 += 27
        _nLin2 += 27

        @ _nLin1 , 014 SAY "Prev.Entrega Oper.Logistico"   SIZE 081, 007 PIXEL OF oPanel            
        @ _nLin2 , 014 MSGET _dPrevEOL                     SIZE 060, 010 PIXEL OF oPanel   WHEN .F. 
        
		@ _nLin1 , 098 SAY "Dt.Ocorr.Oper.Logistico"       SIZE 081, 007 PIXEL OF oPanel            //"Dt.Chegada Oper.Logistico" 
        @ _nLin2 , 097 MSGET _dChegOL                      SIZE 060, 010 PIXEL OF oPanel   WHEN .F. 

        @ _nLin1 , 182 SAY "Dt. Entrega Op. Log. (EDI)"    SIZE 081, 007 PIXEL OF oPanel 
        @ _nLin2 , 182 MSGET _dEntrOL                      SIZE 060, 010 PIXEL OF oPanel   WHEN .F. // N�O pode MAIS ser editado.

        @ _nLin1 , 266 SAY "Entrega no OpLog (Dt.Canhoto)" SIZE 081, 007 PIXEL OF oPanel
        @ _nLin2 , 266 MSGET _dEntOLCha                    SIZE 060, 010 PIXEL OF oPanel   

	    @ _nLin1, 415 SAY   "Usuario Alt.Dt.Entrega Opl- Data - Hora:" SIZE 300, 007 PIXEL OF oPanel    
        @ _nLin2, 415 MSGET _cAprOperL                                 SIZE 165, 010 PIXEL OF oPanel  WHEN .F.

    EndIf 

    _nLin1 += 27
    _nLin2 += 27

	@ _nLin1 , 014 SAY "Prev.Entrega Cliente"            SIZE 081, 007 PIXEL OF oPanel           
    @ _nLin2 , 014 MSGET  _dPrevECL                      SIZE 060, 010 PIXEL OF oPanel   WHEN .F.

    @ _nLin1 , 098 SAY "Dt.Ocorrencia Cliente"           SIZE 081, 007 PIXEL OF oPanel  //"Dt.Chegada Cliente"
    @ _nLin2 , 097 MSGET  _dChegCL                       SIZE 060, 010 PIXEL OF oPanel   WHEN .F.

    @ _nLin1 , 182 SAY "Dt.Entrega Cliente (EDI)"        SIZE 081, 007 PIXEL OF oPanel
    @ _nLin2 , 182 MSGET  _dEntrCL                       SIZE 060, 010 PIXEL OF oPanel   WHEN .F.

	@ _nLin1 , 266 SAY "Entrega no Cliente (Dt.Canhoto)" SIZE 081, 007 PIXEL OF oPanel  // Canhoto Transp. // 056 // "Enterega no Cliente"
	@ _nLin2 , 266 MSGET oGetDtCanh VAR cGetDtCanh	     SIZE 060, 010 PIXEL OF oPanel  VALID { || cGetStat := IIF(alltrim(cGetStat)=="Nao recepcionado","Nao recepcionado","Aprovado")}  // 064
	
    _nColU:=415
    @ _nLin1, _nColU SAY "Usuario Apr. Canhoto - Data - Hora:" SIZE 300, 007 PIXEL OF oPanel    
    @ _nLin2, _nColU MSGET cAprovacao                          SIZE 165, 010 PIXEL OF oPanel  WHEN .F.

	_ncol := 97
	
	_nLin1 += 27
    _nLin2 += 27
    
	@ _nLin1 , 014 SAY "Status"					    SIZE 040, 007 PIXEL OF oPanel // 056
	@ _nLin2 , 014 MSCOMBOBOX oGetStat VAR cGetStat ITEMS IIF(alltrim(cGetStat)=="Nao recepcionado",{"Nao recepcionado"},{"Aguardando Conf","Aprovado","Reprovado"}) SIZE 074, 010 PIXEL OF oPanel  // 064

	@ _nLin1 , 098 SAY "Observa��o"					SIZE 040, 007 PIXEL OF oPanel  // 056
	@ _nLin2 , 098 MSGET oGetObser VAR cGetObser	SIZE 250, 010 PIXEL OF oPanel  // 064

	If alltrim(cGetStat)!="Nao recepcionado" .or. cfilant $ U_ITGETMV("ITFILESTC","01;90") //Filiais que l�em canhoto sempre tenta procurar na Estec

		//Carrega canhoto da p�gina da Estec
		_lreti := .F.
		fwmsgrun( ,{|oproc|_lreti :=  U_CARCANHO(cfilant,alltrim(cGNumNF),oproc,.F.) } , "Aguarde!", "Carregando imagem do canhoto..."  )
	
		oTBitmap1 := TBitmap():New(140,014,170,300,,"\temp\canhoto" + alltrim(cGNumNF)+ "_" + AllTrim(cfilant) + ".jpg",.T.,opanel,,,.F.,.F.,,,.F.,,.T.,,.F.) // 090,014,170,300
    
		oTBitmap1:lAutoSize := .T. 
		
		//Se achou canhoto sem muro j� muda de n�o recepcionado para aguardando confirma��o e grava muro
		If _lreti .and. alltrim(cGetStat) == "Nao recepcionado"
		
			cGetStat := "Aguardando Conf"
			
			If ZGJ->(Dbseek(cfilant+alltrim(cGNumNF))) 
			
				Reclock("ZGJ",.F.)
				
			Else
			
				Reclock("ZGJ",.T.)
			
			Endif
			
			ZGJ->ZGJ_FILIAL := cfilant
			ZGJ->ZGJ_NOTA  := alltrim(cGNumNF)
			ZGJ->ZGJ_SERIE := Alltrim(cGSerie)
			ZGJ->ZGJ_DTENT := stod("")
			ZGJ->ZGJ_DATAI := DATE()
			ZGJ->ZGJ_HORAI := TIME()
			ZGJ->ZGJ_STATUS:= "Aguardando Conf"
			ZGJ->(Msunlock())
		
		Endif
		
	Endif
		
	oGetDtCanh:SetFocus()	  

ACTIVATE MSDIALOG oDlg2 ON INIT ( EnchoiceBar( oDlg2 , {|| IIF( MOMS016V( cGEmissao , cGetDtCanh , &( _cAlias +'->'+ _cAlias +'_DTREC' ),cGNumNF, cGSerie ) , Eval( {|| _nOpcao := 1 , oDlg2:End() } ) , ) } , {|| _nOpcao := 2 , oDlg2:End() } ,,_aBotoes ) ,oPanel:Align	:= CONTROL_ALIGN_ALLCLIENT )//oBrowse:Refresh() )

//================================================================================
// Confirma reprova��o do canhoto
//================================================================================
If alltrim(cGetStat) == "Reprovado" .AND. _nopcao == 1
	
	If !u_itmsg("Confirma reprova��o do canhoto?","Aten��o","CTE n�o ser� liberado para pagamento!",3,2,2)
		
		_nopcao := 2
			
	Endif
		
Endif

//================================================================================
// Caso o usuario tenho confirmado a data de recebimento de canhoto e a observacao
// a serem inseridas na nota fiscal corrente
//================================================================================
If _nOpcao == 1

	&( _cAlias +'->'+ _cAlias +'_DTREC' ) := cGetDtCanh
	&( _cAlias +'->'+ _cAlias +'_DTOP'  ) := _dEntOLCha
//	&( _cAlias +'->'+ _cAlias +'_DTLOGE') := _dEntrOL// N�O pode MAIS ser editado.
	&( _cAlias +'->'+ _cAlias +'_OBSRV' ) := cGetObser
	&( _cAlias +'->'+ _cAlias +'_STATC' ) := IIF(EMPTY(&(_cAlias+'->'+_cAlias+'_STATC')),"Nao recepcionado",ALLTRIM(cGetStat))  

EndIf

//Apaga os arquivos gerados para mostrar o canhoto
ferase("\temp\canhoto" + alltrim(cGNumNF) + "_" + AllTrim(cfilant) + ".pdf")
ferase("\temp\canhoto" + alltrim(cGNumNF) + "_" + AllTrim(cfilant) + ".jpg")

Return( _nOpcao )

/*
===============================================================================================================================
Programa----------: MOMS016V
Autor-------------: Fabiano Dias
Data da Criacao---: 04/07/2011
Descri��o---------: Funcao para validar os dados de canhoto digitados
Parametros--------: _dDtEmis   = Data emiss�o
                    _dDtRecCan = Data Recebimento do Canhoto
					_dDtRecAnt = Data recebimento
					cGNumNF  = Numero da Nota Fiscal
					cGSerie = S�rie da Nota fiscal
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS016V( _dDtEmis , _dDtRecCan , _dDtRecAnt, cGNumNF , cGSerie )

Local _lRet := .T.


//================================================================================
// Valida se a data de recebimento de canhoto informada eh maior que a data de 
// emissao da nota fiscal e se n�o � maior que a data atual
//================================================================================
If ( _dDtRecCan < _dDtEmis .And. _dDtRecCan <> StoD('') ) .Or. _dDtRecCan > Date()

	U_ITMSG("N�o foi fornecida uma Data de Entrega no Cliente (Dt.Canhoto) v�lida.",;
			"Informa��o",;
			"Favor informar uma Data de Entrega no Cliente (Dt.Canhoto) que seja maior ou igual a data de emiss�o da nota fiscal e menor ou igual a data atual.",1)
	
	_lRet := .F.

EndIf

//================================================================================
// Valida se o usuario deseja apagar uma data de recebimento de canhoto informada
//================================================================================
If _lRet .And. _dDtRecCan == StoD('') .And. _dDtRecAnt <> StoD('')

	If !( U_ITMSG( "Deseja apagar os dados de recebimento do canhoto?" , "Confirma��o",,3,2,2 ) )
	 
		_lRet		:= .F.
		cGetDtCanh	:= _dDtRecAnt
	
	EndIf
	
EndIf

If _lRet .And. _loplog .AND. !EMPTY(_dEntOLCha) .AND. (_dEntOLCha < _dDtEmis) 	
   If ValType(cGNumNF)  == Nil 
      cGNumNF := ""
   Else 
      cGNumNF := AllTrim(cGNumNF)
   EndIf 

   If ValType(cGSerie)  == Nil 
      cGSerie := ""
   Else 
      cGSerie := AllTrim(cGSerie)
   EndIf 

   U_ItMsg("Data de Entrega no OL (Dt.Canhoto): "+DTOC(_dEntOLCha)+" precisa ser maior ou igual a data de emiss�o: "+DTOC(_dDtEmis)+" da nota de sa�da: "+cGNumNF+"-"+cGSerie,"Aten��o",,1)
   _lRet:= .F.
ENDIF

Return( _lRet )

/*
===============================================================================================================================
Programa----------: MOMS016I
Autor-------------: Fabiano Dias
Data da Criacao---: 04/07/2011
Descri��o---------: Funcao responsavel por inserir no registro corrente os dados do canhoto na tabela SF2
Parametros--------: _cAlias - Alias da tabela para processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS016I( _cAlias )

Local _dDtReceb		 := ""
Local _cObserv		 := "" 
Local _lRetNota		 := .F.
Local _lRetCarga	 := .F.
Local _cFilCarreg    := ""
Local _lGrvOperL     := .F.  // Indica se houve altera��es nas datas informadas pelo operador log�stico. 
Local _lGrvCanho     := .F.  // Indica se houve altera��es nas datas informados do canhoto.
Local _lTrocaNota    := .F.
Local _lTriangu      := .F.
//Local _aAreaSF2      := {}
//Local _cFilialAux    := ""
//Local _cPedidoAux    := ""
Local _cOperTriangular:= ALLTRIM(U_ITGETMV( "IT_OPERTRI","05,42"))// Tipos de opera��es da opera��o trigular
Local _cOperRemessa   := RIGHT(_cOperTriangular,2)//42
//Local _cOperFat     := LEFT(_cOperTriangular,2)//05

_dDtReceb	:= &( _cAlias +'->'+ _cAlias +'_DTREC' )
_dEntOLCha  := &( _cAlias +'->'+ _cAlias +'_DTOP'  )
//_dEntrOL  := &( _cAlias +'->'+ _cAlias +'_DTLOGE')// N�O pode MAIS ser editado.
_cObserv	:= &( _cAlias +'->'+ _cAlias +'_OBSRV' )

//================================================================================
// Posiciona na tabela SF2 para alteracao dos dados do canhoto
//================================================================================
DBSelectArea("SF2")
SF2->( DBSetOrder(2) ) //F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE
If SF2->( DBSeek( xFilial("SF2") + &( _cAlias +'->( '+ _cAlias +'_CODCLI + '+ _cAlias +'_LOJCLI + '+ _cAlias +'_DOC + '+ _cAlias +'_SERIE )' ) ) )
 
	//================================================================================
	// Se a nf n�o consta na ZZN passa
	//================================================================================
	DBSelectArea("ZZN")
	ZZN->( DBSetOrder(6) )
	If ZZN->( DBSeek( xFilial("ZZN")+ &( _cAlias+'->( '+ _cAlias +'_DOC + '+ _cAlias +'_SERIE )' ) ) ) 
		_lRetNota := .F.
	Else
		_lRetNota := .T.
	EndIf
	
	//================================================================================
	// Se a carga esta preenchida verifica se existe na ZZN
	//================================================================================
	DBSelectArea("ZZN")
	ZZN->( DBSetOrder(7) )
	If !Empty( AllTrim( &( _cAlias +'->'+ _cAlias +'_CARGA' ) ) )
	
		If ZZN->( DBSeek( xFilial("ZZN") + &( _cAlias +'->'+ _cAlias +'_CARGA' ) ) )
			_lRetCarga := .F.
		Else
			_lRetCarga := .T.
		EndIf
	
	//================================================================================
	//	Se a NF n�o consta na ZZN e a carga for vazia passa
	//================================================================================
	ElseIf _lRetNota
	
		cUserName  := .T.
		
	EndIf

	//================================================================================
	//	Verifica se � Troca Nota
	//================================================================================
	SC5->(Dbsetorder(1))
	If SC5->(Dbseek(SF2->F2_FILIAL+ALLTRIM(SF2->F2_I_PEDID)))

	   If SC5->C5_I_OPER = '51' 
		  U_ITMSG("A DATA DE CANHOTO INFORMADA � REFERENTE AO PEDIDO DE PALLET RETORNO.","ATEN��O",,3)
	   EndIf

	   IF SC5->C5_I_OPER = _cOperRemessa//42
	  	  //_cFilialAux  := SC5->C5_FILIAL //Filial de Faturamento
	  	  //_cPedidoAux  := SC5->C5_I_PVFAT//Pedido de Faturamento
	  	  _lTriangu:=.T.
		  _lReplica:=.T.
       ENDIF

	   IF SC5->C5_I_TRCNF == "S" .AND. SC5->C5_I_OPER <> "20" //.AND. SC5->C5_NUM == SC5->C5_I_PDPR
  	  	  _lTrocaNota:=.T.
		  _lReplica  :=.T.
	  	  //If SC5->C5_NUM == SC5->C5_I_PDPR//Faturamento
	  	  //	 //_cFilialAux := SC5->C5_I_FILFT //Filial de Faturamento
	  	  //	 //_cPedidoAux := SC5->C5_I_PDFT  //Pedido de Faturamento
	  	  //ElseIf SC5->C5_NUM == SC5->C5_I_PDFT//Carregamento
	  	  //	 //_cFilialAux := SC5->C5_I_FLFNC //Filial de Carregamento
	  	  //	 //_cPedidoAux := SC5->C5_I_PDPR  //Pedido de Carregamento
	  	  //	 _lTrocaNota := .T.
	  	  //EndIf
	   EndIf
	
	EndIf
	//================================================================================
	//	Se passou pelas valida��es grava os dados do canhoto
	//  Se for aprova��o grava sempre
	//================================================================================
	If (SF2->F2_I_DTRC <> _dDtReceb) //.And. !Empty(_dDtReceb) 	   
	   _lGrvCanho := .T.  // Indica se houve altera��es nas datas informados do canhoto.
	EndIf 

    If (SF2->F2_I_DTOP <> _dEntOLCha) //.And. !Empty(_dEntOLCha)
	   _lGrvOperL := .T.  // Indica se houve altera��es nas datas informadas pelo operador log�stico.
	EndIf 
    
	If (_lRetNota .And. _lRetCarga) .OR. alltrim(&( _cAlias +'->'+ _cAlias +'_STATC' )) != "Reprovado"
     
		//S� grava SF2 para liberar cte se o canhoto n�o foi reprovado
		If alltrim(&( _cAlias +'->'+ _cAlias +'_STATC' )) != "Reprovado"
		
			SF2->( RecLock( "SF2" , .F. ) )
			SF2->F2_I_DTRC:= _dDtReceb
            SF2->F2_I_DTOP:=_dEntOLCha // Data em que o Transportador Entregou efetivamente a Carga no Operador Log�stico // pode ser editado.
//------------------------------------------------------------------------
          //SF2->F2_I_DENOL := _dEntrOL  // Data de entrega no operador log�stico  EDI // N�O pode MAIS ser editado.
//------------------------------------------------------------------------
			SF2->F2_I_OBRC	:= _cObserv
            SF2->F2_I_CORIG := "MOMS016"
            
		    If _lGrvOperL
		       SF2->F2_I_OUSER := __cUserId
		       SF2->F2_I_ODATA := Date()
		       SF2->F2_I_OHORA := Time()
		    EndIf

            If _lGrvCanho
			   SF2->F2_I_CUSER := __cUserID // Usu�rio de aprova��o do canhoto.
               SF2->F2_I_CDATA := Date()    // Data de digita��o do Canhoto.
               SF2->F2_I_CHORA := Time()    // hora de digita��o do Canhoto.
			EndIf 
    		
			SF2->( MsUnlock() )
		
		Elseif  alltrim(&( _cAlias +'->'+ _cAlias +'_STATC' )) == "Reprovado"
		
			SF2->( RecLock( "SF2" , .F. ) )
			SF2->F2_I_DTRC	:= ctod(" ")
			SF2->F2_I_OBRC	:= _cObserv
			SF2->F2_I_CUSER := __cUserID
			SF2->F2_I_CDATA := DATE()
			SF2->F2_I_CHORA := TIME()
            SF2->F2_I_CORIG := "MOMS016"
			SF2->( MsUnlock() )
		
		Endif
		
		//================================================================================
		//	Atualiza muro de canhoto com a Estec
		//================================================================================
		ZGJ->(Dbsetorder(1))
		If ZGJ->(Dbseek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE))
		 
			If ZGJ->ZGJ_STATUS <> &( _cAlias +'->'+ _cAlias +'_STATC' ) 
			    If !EMPTY(_dDtReceb) .And. ZGJ->ZGJ_DTENT <> _dDtReceb
				   ZGJ->( RecLock( "ZGJ" , .F. ) )
				   ZGJ->ZGJ_DTENT	:= _dDtReceb
				   ZGJ->ZGJ_OBS	:= _cObserv
			       IF !EMPTY(_dDtReceb) //CHAMADO 39375. Quando informado uma Data de Canhoto e existir tabela de Controle de Digitaliza��o de Canhoto (ZGJ) gravar o status da digitaliza��o igual a "Aprovado" e Data de Entrega 
				      ZGJ->ZGJ_STATUS := "Aprovado"
				   ELSE
				      ZGJ->ZGJ_STATUS := &( _cAlias +'->'+ _cAlias +'_STATC' ) 
				   ENDIF
				   ZGJ->ZGJ_DATAA := DATE()
				   ZGJ->ZGJ_HORAA := TIME()
				   ZGJ->ZGJ_APROVA := __cUserID
				   ZGJ->( MsUnlock() )
				EndIf 
			ELSEIF !EMPTY(_dDtReceb) //CHAMADO 39375. Quando informado uma Data de Canhoto e existir tabela de Controle de Digitaliza��o de Canhoto (ZGJ) gravar o status da digitaliza��o igual a "Aprovado" e Data de Entrega 
				ZGJ->( RecLock( "ZGJ" , .F. ) )
				ZGJ->ZGJ_DTENT	:= _dDtReceb
				ZGJ->ZGJ_OBS	:= _cObserv
				ZGJ->ZGJ_STATUS := "Aprovado"
				ZGJ->ZGJ_DATAA  := DATE()
				ZGJ->ZGJ_HORAA  := TIME()
				ZGJ->ZGJ_APROVA := __cUserID
				ZGJ->( MsUnlock() )
			ENDIF
		
		Endif
		
		//================================================================================
		//	Encerra monitor de pedidos se houver e se o canhoto n�o estiver reprovado
		//=============================================================================== 
		SC5->(Dbsetorder(1))
		SC5->(Dbseek(SF2->F2_FILIAL+SF2->F2_I_PEDID))

		IF !(alltrim(SC5->C5_I_OPER) $ AllTrim(U_ITGETMV( 'IT_MPVOP' , '50/51/02'))) 
		
			aheader := {}
			acols := {}
			aadd(aheader,{1,"C6_ITEM"})
			aadd(aheader,{2,"C6_PRODUTO"})
			aadd(aheader,{3,"C6_LOCAL"})

			SC6->(Dbsetorder(1))
			SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))
		
			Do while SC6->(!EOF()) .AND. SC5->C5_FILIAL == SC6->C6_FILIAL .AND. SC5->C5_NUM == SC6->C6_NUM
				aadd(acols,{SC6->C6_ITEM,SC6->C6_PRODUTO,SC6->C6_LOCAL})
				SC6->(Dbskip())
			Enddo

            _cFilCarreg := SC5->C5_FILIAL 
            If ! Empty(SC5->C5_I_FLFNC)
               _cFilCarreg := SC5->C5_I_FLFNC
            EndIf 

			_dDTNECE := SC5->C5_I_DTENT - (U_OMSVLDENT(SC5->C5_I_DTENT,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_I_FILFT,SC5->C5_NUM,1, ,_cFilCarreg,SC5->C5_I_OPER,SC5->C5_I_TPVEN))

			IF !EMPTY(_dDtReceb) .and. alltrim(&( _cAlias +'->'+ _cAlias +'_STATC' )) != "Reprovado"
				_cJUSCOD := "012"//"RECEBIMENTO DE CANHOTO"
				_cCOMENT := "*** Encerrado por recebimento do canhoto - entrega em " + dtoc(_dDtReceb)
				_cLENCMON := 'S'
			ELSEIF EMPTY(_dDtReceb) 
				_cJUSCOD:= "013"//"ESTORNO DE RECEBIMENTO DE CANHOTO"
				_cCOMENT := "*** Estorno do recebimento do canhoto."
				_cLENCMON:= 'I'
			ELSEIF alltrim(&( _cAlias +'->'+ _cAlias +'_STATC' )) == "Reprovado"
				_cJUSCOD:= "013"//"ESTORNO DE RECEBIMENTO DE CANHOTO"
				_cCOMENT := "*** Reprovacao do recebimento do canhoto. - " + _cObserv
				_cLENCMON:= 'I'
			ENDIF

			U_GrvMonitor(,,_cJUSCOD,_cCOMENT,_cLENCMON,_dDTNECE,SC5->C5_I_DTENT,SC5->C5_I_DTENT)
     
		ENDIF

		//===============================================================================
        //REPLICA OS CAMPOS DO PEDIDO PRINCIPAL PARA OS GERADOS 
		//=============================================================================== 
	    If (_lTrocaNota .OR. _lTriangu) .AND. _lReplica
	 	   U_Repl2DtsTransTime( SF2->(RECNO()) , SF2->F2_I_OBRC ) //FUN��O ESTA NO AOMS054.PRW 
	    Endif
	
	Else
	
		U_ITMSG("N�o foi poss�vel a modifica��o da data de recebimento do canhoto refente a NF ",;
				"Informa��o",;
				&( _cAlias +'->'+ _cAlias +'_DOC' ) +"/"+ AllTrim( &( _cAlias +'->'+ _cAlias +'_SERIE' ) )	+;
				", uma vez que j� foi efetuado o lan�amento de CTR x NF Sa�da. "	+ ;
				"Para prosseguir com a altera��o da data de recebimento solicite a exclus�o do lan�amento de CTR x NF Sa�da efetuado.",1)
			
	EndIf

EndIf
	
Return

/*
===============================================================================================================================
Programa----------: MOMS016J
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 15/01/2017
Descri��o---------: Retorna status da canhoto na tabela de muro da Estec
Parametros--------: _cdoc - N�mero da nota
					_cserie - serie da nota
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS016J(_cdoc, _cserie)

Local _cstatus := "Nao recepcionado"   //,"Aguardando Conf","Aprovado","Reprovado"

ZGJ->(Dbsetorder(1))
If ZGJ->(Dbseek(xfilial("ZGJ")+_cdoc+_cserie))

  _cstatus := alltrim(ZGJ->ZGJ_STATUS)

Endif


Return _cstatus
