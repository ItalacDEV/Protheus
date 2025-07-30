/*
===============================================================================================================================
                          ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
    Autor    |    Data    |                                             Motivo                                          
Julio Paz    | 23/01/2018 | Chamado 23340. Incluir no menu botão para o usuário visualizar o canhoto da nota fiscal. 
Josué Danich | 26/10/2018 | Chamado 26701. Inclusão rotinas de transmissão e monitor por carga. 
Lucas Borges | 11/10/2019 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25. 
Alex Wallauer| 16/11/2021 | Chamado 38056. Correcao da Funcao Static GetIdEnt() copiada do progrma SPEDNF.PRX. 
Alex Wallauer| 14/03/2022 | Chamado 39457. Nova opcao criada: "Informar NF Adquirente". 
Alex Wallauer| 14/03/2022 | Chamado 39457. Alteracao da logica mensagem acrescentada na NF de remessa. 
Alex Wallauer| 14/03/2023 | Chamado 43091. Correção do tamanho do campo serie. 
Igor Melgaço | 05/12/2023 | Chamado 45463. Ajuste para chamada de Ocorrencias de frete.
==============================================================================================================================================================
Analista    - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
Jerry       - Alex Wallauer - 03/02/25 - 03/02/25 - 49795   - Chamar os índices customizados da tabela SC5 com DBOrderNickName().
==============================================================================================================================================================
*/ 

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "protheus.ch"
#include "TopConn.ch"    
#Define ENTER CHR(13)+CHR(10)

/*
===============================================================================================================================
Programa----------: FISTRFNFE
Autor-------------: Andre Lisboa
Data da Criacao---: 18/10/2016
===============================================================================================================================
Descrição---------: Ponto de Entrada para tratar permissão de acesso ao botão parametros da rotina NFe - Chamado 16940
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: .T./.F.
===============================================================================================================================
*/
User Function FISTRFNFE()

Local _lRet 	:= .T.


If empty(alltrim(funname()))

	Return
	
Endif

aAdd( aRotina,{'Canhot. NF'	         , 'U_VISCANHO( SF2->F2_FILIAL, SF2->F2_DOC )'	, 0 , 2 , 0 , NIL } )  // Adiciona no menu da rotina NFE SEFAZ uma opção para visualização do canhoto da Nota Fiscal.
aAdd( aRotina,{'Trans Italac.'	      , 'U_ITTRANS()'	, 0 , 2 , 0 , NIL } )  
aAdd( aRotina,{'Monit Italac'	         , 'U_ITMONIT()'	, 0 , 2 , 0 , NIL } )  
aAdd( aRotina,{'Informar NF Adquirente', 'U_INFOADQ()'	, 0 , 2 , 0 , NIL } )  
aAdd( aRotina,{'Ocorrências de frete'  , 'U_AOMS003("'+"ZF5->ZF5_FILIAL == SF2->F2_FILIAL .AND. ZF5->ZF5_DOCOC ==  SF2->F2_DOC .AND. ZF5->ZF5_SEROC ==  SF2->F2_SERIE"+'" )'  , 0 , 2 , 0 , NIL } )  

dbSelectArea("ZZL")                                                                                    	
dbSetOrder(3) //ZZL_FILIAL + ZZL_CODUSU
dbSeek(xFilial("ZZL") + __cUserId)
If ZZL->ZZL_PRMNFE <> "S"
   _lRet := .F.
   aRotina[3][2]:=  "Aviso( 'Atenção!' , 'Usuário sem permissão de acesso aos Parametros.' , {'Fechar'} )" 
Endif		                     	

ZZL->(DBCloseArea())

Return _lRet

/*
===============================================================================================================================
Programa----------: ITTRANS
Autor-------------: Josué Danich Prestes
Data da Criacao---: 23/10/2018
===============================================================================================================================
Descrição---------: Trnasmissão personalizada de nfe
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITTRANS()

Local cperg := "ITTRANS"
Local _MV_PAR01 := MV_PAR01
Local _MV_PAR02 := MV_PAR02
Local _MV_PAR03 := MV_PAR03
Local _MV_PAR04 := MV_PAR04
Local _MV_PAR05 := MV_PAR05
Local _MV_PAR06 := MV_PAR06
Local _MV_PAR07 := MV_PAR07
Local _MV_PAR08 := MV_PAR08
Local aarea := getarea()
Local oproc := nil
Private _cserie := alltrim(SF2->F2_SERIE)
Private _cnotaini := SF2->F2_DOC
Private _cnotafim := SF2->F2_DOC
Private _otemp := nil
Private nOpca		:= 0

If pergunte(cperg) .and. !empty(MV_PAR01) .and. !empty(MV_PAR02)

	FWMSGRUN(,{|oproc| U_ITQRYPE(oproc)},"Aguarde...","Pesquisando notas das cargas selecionadas...")
		
	If empty(_cnotaini)
	
		u_itmsg("Não foram localizadas notas fiscais para as cargas indicadas no filtro","Atenção",,1)
		Return
		
	Endif
	
	If nopca == 2
	
		u_itmsg("Processo cancelado!","Atenção",,1)
		Return
		
	Endif
	
	cSerie := '1'+SPACE( LEN(SF2->F2_SERIE)-1 )
	cNotaIni := _cnotaini
	cNotaFim := _cnotafim
	
Else

	cSerie   := SF2->F2_SERIE
	cNotaIni := SF2->F2_DOC
	cNotaFim := SF2->F2_DOC
	
Endif

//Reconstrói pergunte original da função
MV_PAR01 := _MV_PAR01
MV_PAR02 := _MV_PAR02
MV_PAR03 := _MV_PAR03
MV_PAR04 := _MV_PAR04
MV_PAR05 := _MV_PAR05
MV_PAR06 := _MV_PAR06
MV_PAR07 := _MV_PAR07
MV_PAR08 := _MV_PAR08

//Função padrão de transmissão de nfe
Restarea(aarea)
FWMSGRUN(,{|| SpedNFeRe2(cSerie,cNotaIni,cNotaFim)},"Aguarde...","Pesquisando notas das cargas selecionadas...")

If select ("IT_TRB") > 0

	dbSelectArea("IT_TRB")
	IT_TRB->(Dbclosearea())
	_otemp:Delete()
	
Endif

Return

/*
===============================================================================================================================
Programa----------: ITQRYPE
Autor-------------: Josué Danich Prestes
Data da Criacao---: 23/10/2018
===============================================================================================================================
Descrição---------: Query de procura de nota inicial e final
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITQRYPE(oproc)

Private _ntot := 0
Private acampos := {}

If select ("IT_DAI") > 0

	dbSelectArea("IT_DAI")
	IT_DAI->(Dbclosearea())
	
Endif

_cQuery := " SELECT DAI_NFISCA "
_cQuery += " FROM " + RetSqlName("DAI")
_cQuery += " WHERE D_E_L_E_T_ <> '*' AND DAI_NFISCA > ' '"
_cQuery += " AND DAI_FILIAL = '" + CFILANT + "' AND DAI_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
	
TcQuery _cQuery New Alias "IT_DAI"
dbSelectArea("IT_DAI")

//Prepara parâmetros para a tela padrão do assistente de envio de nfe
//Se tiver notas válidas abre tela para conferência e seleção de envio de notas
If IT_DAI->(Eof())

	_cSerie := ''
	_cNotaIni := ''
	_cNotaFim := ''
	
Else

	_cSerie := '  1'
	_cNotaFim := alltrim(IT_DAI->DAI_NFISCA)
	_cNotaini := alltrim(IT_DAI->DAI_NFISCA)

	Do while IT_DAI->(!Eof())
			
		If alltrim(IT_DAI->DAI_NFISCA) > _cNotaFim
			_cNotaFim := alltrim(IT_DAI->DAI_NFISCA)
		Endif
		If alltrim(IT_DAI->DAI_NFISCA) < _cNotaini
			_cNotaini := alltrim(IT_DAI->DAI_NFISCA)
		Endif
		
		_ntot++
		IT_DAI->(Dbskip())
		
	Enddo
	
	//Monta tela de visualização e confirmação
	IT_DAI->(Dbgotop())
	FWMSGRUN(,{|oproc| U_ITPEARQ(oproc)},"Aguarde...","Carregando notas das cargas selecionadas...")
	_nopc := IFNFETRS()
		
Endif

If select ("IT_DAI") > 0

	dbSelectArea("IT_DAI")
	IT_DAI->(Dbclosearea())
	
Endif
	
Return

/*
===============================================================================================================================
Programa----------: ITPEARQ
Autor-------------: Josué Danich
Data da Criacao---: 25/10/2018
===============================================================================================================================
Descrição---------: Rotina para criação do arquivo temporário
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITPEARQ(oproc)

Local aEstru		:= {}
Local _npv          := 1

//================================================================================
// Armazena no array aEstru a estrutura dos campos da tabela.
//================================================================================
AADD( aEstru , { "TRBF_OK"		, 'C' , 02 , 0 } )
AADD( aEstru , { "TRBF_CARGA"	, 'C' , 06 , 0 } )
AADD( aEstru , { "TRBF_DOC"		, 'C' , 09 , 0 } )
AADD( aEstru , { "TRBF_DTEMI"	, 'D' , 08 , 0 } )
AADD( aEstru , { "TRBF_CODCL"	, 'C' , 06 , 0 } )
AADD( aEstru , { "TRBF_LOJCL"	, 'C' , 04 , 0 } )
AADD( aEstru , { "TRBF_DESCL"	, 'C' , 30 , 0 } )
AADD( aEstru , { "TRBF_UF"   	, 'C' , 02 , 0 } )
AADD( aEstru , { "TRBF_MUN"   	, 'C' , 12 , 0 } )

//================================================================================
// Armazena no array aCampos o nome, picture e descricao dos campos
//================================================================================
AADD( aCampos , { "TRBF_OK"		, "" , " "					, " "										} )
AADD( aCampos , { "TRBF_CARGA"	, "" , "Carga"				, PesqPict( "DAI" , "DAI_COD"	 )	 		} )
AADD( aCampos , { "TRBF_DOC"	, "" , "NF"					, PesqPict( "SF2" , "F2_DOC"	 )	 		} )
AADD( aCampos , { "TRBF_DTEMI"	, "" , "Data Emissão"		, PesqPict( "SC5" , "C5_I_DTENT" )	  		} )
AADD( aCampos , { "TRBF_UF"	    , "" , "UF"					, PesqPict( "SA1" , "A1_EST"     )	  		} )
AADD( aCampos , { "TRBF_MUN"    , "" , "Cidade"				, PesqPict( "SA1" , "A1_MUN"     )	  		} )
AADD( aCampos , { "TRBF_CODCL"	, "" , "Cliente"			, PesqPict( "SC5" , "C5_CLIENTE" )	  		} )
AADD( aCampos , { "TRBF_LOJCL"	, "" , "Loja"				, PesqPict( "SC5" , "C5_LOJACLI" )	  		} )
AADD( aCampos , { "TRBF_DESCL"	, "" , "Descricao Cliente"	, PesqPict( "SC5" , "C5_I_NOME"  )	  		} )


//================================================================================
// Verifica se ja existe um arquivo com mesmo nome, se sim deleta.
//================================================================================
If Select("IT_TRB") > 0
	oproc:cCaption := ("Apagando temporário...")
	ProcessMessages()
	IT_TRB->(Dbclosearea())
EndIf

oproc:cCaption := ("Criando arquivo temporário...")
ProcessMessages()
_otemp := FWTemporaryTable():New( "IT_TRB", aEstru )

oproc:cCaption := ("Criando indices do arquivo temporário...")
ProcessMessages()
_otemp:AddIndex( "DC", {"TRBF_DOC"} )

_otemp:Create()

DO While IT_DAI->(!EOF())

	//Atualiza régua
	oproc:cCaption := ("Processando nota... ["+ StrZero(_npv,6) +"] de ["+ StrZero(_ntot,6) +"]")
	ProcessMessages()
	_npv++    
 
	SF2->(Dbsetorder(1))
	SA1->(Dbsetorder(1))
	If SF2->(Dbseek(cfilant+alltrim(IT_DAI->DAI_NFISCA))) .AND. SA1->(Dbseek(xfilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
    		
		Reclock("IT_TRB",.T.)
		IT_TRB->TRBF_DOC	:= SF2->F2_DOC
		IT_TRB->TRBF_CARGA	:= SF2->F2_CARGA
		IT_TRB->TRBF_DTEMI	:= SF2->F2_EMISSAO
		IT_TRB->TRBF_CODCL	:= SF2->F2_CLIENTE
		IT_TRB->TRBF_LOJCL	:= SF2->F2_LOJA
		IT_TRB->TRBF_DESCL	:= SA1->A1_NREDUZ
		IT_TRB->TRBF_UF   	:= SF2->F2_EST
    	IT_TRB->TRBF_MUN	 := SA1->A1_MUN
    	
    Endif
	
    IT_DAI->( DBSkip() )
	
EndDo

IT_DAI->( DBCloseArea())

Return

/*
===============================================================================================================================
Programa----------: IFNFETRS
Autor-------------: Josué Danich Prestes
Data da Criacao---: 25/10/2018
===============================================================================================================================
Descrição---------: Função que monta a tela para processar
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function IFNFETRS()

Local oPanel		:= Nil
Local oDlg1			:= Nil
Local nHeight		:= 0
Local nWidth		:= 0
Local aSize			:= {}
Local aBotoes		:= {}
Local aCoors		:= {}

Private cFiltro		:= "%" 
Private _aAreaCabec	:= {} 
Private _cFilPed	:= ""
Private _cNumPed	:= ""          
Private oMark		:= Nil
Private nQtdTit		:= 0
Private nPesTit	    := 0
Private oQtda		:= Nil
Private oPesa		:= Nil
Public _cMarkado	:= GetMark()
Private lInverte	:= .F.


//================================================================================
// Faz o calculo automatico de dimensoes de objetos
//================================================================================
aSize := MSADVSIZE() 

//================================================================================
// Cria a tela para selecao dos pedidos
//================================================================================
_ctitulo := "Notas selecionadas para transmissão"
		

 DEFINE MSDIALOG oDlg1 TITLE OemToAnsi(_ctitulo) From 0,0 To aSize[6],aSize[5] PIXEL

	oPanel       := TPanel():New(30,0,'',oDlg1,, .T., .T.,, ,315,20,.T.,.T. )
	
	If FlatMode()
	
		aCoors	:= GetScreenRes()
		nHeight	:= aCoors[2]
		nWidth	:= aCoors[1]
		
	Else
	
		nHeight	:= 143
		nWidth	:= 315
		
	Endif
	
	DBSelectArea("IT_TRB")
	IT_TRB->(DbGotop()) 
	
	oMark					:= MsSelect():New( "IT_TRB" , "TRBF_OK" ,, aCampos , @lInverte , @_cMarkado , { 35 , 1 , nHeight , nWidth } )
	oMark:bMark				:= {|| ITNFEINV( _cMarkado , lInverte  ) }
	oMark:oBrowse:bAllMark	:= {|| ITNFEALL( _cMarkado  ) }

	oDlg1:lMaximized:=.T.

ACTIVATE MSDIALOG oDlg1 ON INIT ( EnchoiceBar(oDlg1,{|| nOpca := 1,oDlg1:End()},{|| nOpca := 2,oDlg1:End()},,aBotoes),;
                                  oPanel:Align:=CONTROL_ALIGN_TOP , oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT , oMark:oBrowse:Refresh())


Return nOpca

/*
===============================================================================================================================
Programa----------: ITNFEINV
Autor-------------: Josué Danich Prestes
Data da Criacao---: 26/10/2018
===============================================================================================================================
Descrição---------: Rotina para inverter a marcacao do registro posicionado.
===============================================================================================================================
Parametros--------: cmarca - string de marcação do registro da tabela
					linverte - flag de inversão de registros
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function ITNFEINV( cMarca , lInverte  )

IsMark( "TRBF_OK" , cMarca , lInverte )

Return()

/*
===============================================================================================================================
Programa----------: ITNFEALL
Autor-------------: Josué Danich Prestes
Data da Criacao---: 26/0/2018
===============================================================================================================================
Descrição---------: Rotina para marcar todos os registros.
===============================================================================================================================
Parametros--------: cMarca - string de marcação da tabela
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function ITNFEALL( cMarca  )

Local nReg     := IT_TRB->( Recno() )
Local lMarcado := .F.

DBSelectArea("IT_TRB")
IT_TRB->( DBGoTop() )

While IT_TRB->( !Eof() )
	
	lMarcado := IsMark( "TRBF_OK" , cMarca , lInverte )
	
	If lMarcado .Or. lInverte
	
		IT_TRB->( RecLock( "IT_TRB" , .F. ) )
		IT_TRB->TRBF_OK := Space(2)
		IT_TRB->( MsUnLock() )
				
	Else
	
		IT_TRB->( RecLock( "IT_TRB" , .F. ) )
		IT_TRB->TRBF_OK := cMarca
		IT_TRB->( MsUnLock() )
				
	EndIf
		
IT_TRB->( DBSkip() )
EndDo

IT_TRB->( DBGoto(nReg) )

oMark:oBrowse:Refresh(.T.)

Return()

/*
===============================================================================================================================
Programa----------: ITMONIT
Autor-------------: Josué Danich Prestes
Data da Criacao---: 26/10/2018
===============================================================================================================================
Descrição---------: Monitor Sefaz por carga
===============================================================================================================================
Parametros--------: Nenhum, todos são carregados por default
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITMONIT(cSerie,cNotaIni,cNotaFim, lCTe, lMDFe, cModel,lTMS, lAutoColab)

Local cIdEnt   := GetIdEnt()//StaticCall(SPEDNFE, GetIdEnt)
local cUrl	   := Padr( GetNewPar("MV_SPEDURL",""), 250 )
Local aPerg    := {}
Local aParam   := {Space(Len(SF2->F2_SERIE)),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC)),space(6),space(6)}
Local aSize    := {}
Local aObjects := {}
Local aInfo    := {}
Local aPosObj  := {}
Local oDlg
Local oListBox
Local oBtn1
Local oBtn4
Local cParNfeRem	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDNFEREM"
Local lOK			:= .F.

Default cSerie   := '1  '
Default cNotaIni := ''
Default cNotaFim := ''
Default lCTe     := .F.
Default lMDFe    := .F.
Default cModel   := ""
default lTMS     := .F.
Default lAutoColab := .F.

Private ccargaini := ""
Private ccargafim := ""
Private aListBox := {}

aadd(aPerg,{1,Iif(lMDFe,"Serie da Nota Fiscal","Serie da Nota Fiscal"),aParam[01],"",".T.","",".T.",30,.F.}) //"Serie da Nota Fiscal"
aadd(aPerg,{1,Iif(lMDFe,"Nota fiscal inicial" ,"Nota fiscal inicial"),aParam[02],"",".T.","",".T.",30,.F.}) //"Nota fiscal inicial"
aadd(aPerg,{1,Iif(lMDFe,"Nota fiscal final"   ,"Nota fiscal final"),aParam[03],"",".T.","",".T.",30,.F.}) //"Nota fiscal final"
aadd(aPerg,{1,Iif(lMDFe,"Carga inicial"       ,"Carga inicial"),aParam[04],"",".T.","",".T.",30,.F.}) //"Nota fiscal inicial"
aadd(aPerg,{1,Iif(lMDFe,"Carga final"         ,"Carga final"),aParam[05],"",".T.","",".T.",30,.F.}) //"Nota fiscal final"
	

aParam[01] := ParamLoad(cParNfeRem,aPerg,1,aParam[01])
aParam[02] := ParamLoad(cParNfeRem,aPerg,2,aParam[02])
aParam[03] := ParamLoad(cParNfeRem,aPerg,3,aParam[03])
aParam[04] := ParamLoad(cParNfeRem,aPerg,4,aParam[04])
aParam[05] := ParamLoad(cParNfeRem,aPerg,5,aParam[05])


lOK      := ParamBox(aPerg,"SPED - NFe",@aParam,,,,,,,cParNfeRem,.T.,.T.)
cSerie   := IF(EMPTY(aParam[01]),cSerie,aParam[01])
cNotaIni := aParam[02] 
cNotaFim :=	aParam[03] 	
cCargaini := aParam[04]
cCargaFim:= aParam[05]
			
If (empty(cnotaini) .or. empty(cnotafim)) .and. !empty(ccargaini) .and. !empty(ccargafim)
	
	//Determina nota inicial e final baseado no filtro de carga para maximizar performance				
	If select ("IT_DAI") > 0

		dbSelectArea("IT_DAI")
		IT_DAI->(Dbclosearea())
	
	Endif

	_cQuery := " SELECT min(dai_nfisca) AS MINI, MAX(dai_nfisca) AS MAXI  "
	_cQuery += " FROM " + RetSqlName("DAI")
	_cQuery += " WHERE D_E_L_E_T_ <> '*' and dai_nfisca > ' ' "
	_cQuery += " AND dai_filial = '" + CFILANT + "' AND dai_cod BETWEEN '" + alltrim(ccargaini) + "' AND '" + alltrim(ccargafim) + "'"
	
	TcQuery _cQuery New Alias "IT_DAI"
	dbSelectArea("IT_DAI")
			
	If empty(cnotaini)
				
		cnotaini := alltrim(IT_DAI->MINI)
					
	Endif
				
	If empty(cnotafim)
				
		cnotafim := alltrim(IT_DAI->MAXI)
					
	Endif

	dbSelectArea("IT_DAI")
	IT_DAI->(Dbclosearea())
			
Endif 			
			
aParam := {}
aadd(aparam,cSerie)
aadd(aparam,cNotaIni)
aadd(aparam,cNotaFim)
			
If (lOK)

	fwmsgrun(,{ || aListBox := getListBox(cIdEnt, cUrl, aParam, 1, cModel, lCte, .T., lMDFe, lTMS)},"Aguarde","Carregando notas...")
	
	If !Empty(aListBox) 
	
		aSize := MsAdvSize()
		aObjects := {}
		AAdd( aObjects, { 100, 100, .t., .t. } )
		AAdd( aObjects, { 100, 015, .t., .f. } )
				
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )
											
		DEFINE MSDIALOG oDlg TITLE "SPED - NFe" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
					
		@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER "","NF","Carga","Protocolo","Recomendação" SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
		
		oListBox:SetArray( aListBox )
		oListBox:bLine := { || { aListBox[ oListBox:nAT,1 ],aListBox[ oListBox:nAT,2 ],aListBox[ oListBox:nAT,3 ],aListBox[ oListBox:nAT,4 ],aListBox[ oListBox:nAT,5 ] } }
		
		@ aPosObj[2,1],aPosObj[2,4]-040 BUTTON oBtn1 PROMPT "OK"   		ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //
		@ aPosObj[2,1],aPosObj[2,4]-080 BUTTON oBtn4 PROMPT "Refresh" 	ACTION (fwmsgrun(,{ || aListBox := getListBox(cIdEnt, cUrl, aParam, 1, cModel, lCte, .T., lMDfe, lTMS)},"Aguarde...","Carregando notas..."),oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 035,011 //"Refresh"
		
		ACTIVATE MSDIALOG oDlg

	Else
	
		u_itmsg("Não foram localizadas notas válidas!","Atenção",,1)
	
	Endif
				
Endif

Return

/*
===============================================================================================================================
Programa----------: GETLISTBOX
Autor-------------: Josué Danich Prestes
Data da Criacao---: 26/10/2018
===============================================================================================================================
Descrição---------: Monta array de notas monitoradas
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static function getListBox(cIdEnt, cUrl, aParam, nTpMonitor, cModelo, lCte, lMsg, lMDfe, lTMS)
	
local aLote			:= {}
local aListBox			:= {}
local aRetorno			:= {}
local cId				:= ""
local cProtocolo		:= ""	
local cRetCodNfe		:= ""
local cAviso			:= ""
	
local nAmbiente		:= ""
local nModalidade		:= ""
local cRecomendacao	:= ""
local cTempoDeEspera	:= ""
local nTempomedioSef	:= ""
local nX				:= 0

local oOk				:= LoadBitMap(GetResources(), "ENABLE")
local oNo				:= LoadBitMap(GetResources(), "DISABLE")
		
default lMsg			:= .T.
default lCte			:= .F.	
default lMDfe			:= .F.
default cModelo			:= IIf(lCte,"57",IIf(lMDfe,"58","55"))
default lTMS			:= .F.
	
aRetorno := procMonitorDoc(cIdEnt, cUrl, aParam, nTpMonitor, cModelo, lCte, @cAviso)

if empty(cAviso)
	
	for nX := 1 to len(aRetorno)
			
		cId				:= aRetorno[nX][1]
		cProtocolo		:= aRetorno[nX][4]	
		cRetCodNfe		:= aRetorno[nX][5]
		nAmbiente		:= aRetorno[nX][7]
		nModalidade	:= aRetorno[nX][8]
		cRecomendacao	:= aRetorno[nX][9]
		cTempoDeEspera:= aRetorno[nX][10]
		nTempomedioSef:= aRetorno[nX][11]
		aLote			:= aRetorno[nX][12]
			
		SF2->(Dbsetorder(1))
		If SF2->(Dbseek(xfilial("SF2")+SUBSTR(ALLTRIM(cId),4,9)))
			
			ccarga := alltrim(SF2->F2_CARGA)
				
		Else
			
			ccarga := " "
				
		Endif
			
		If (empty(ccargaini) .and. empty(ccargafim)) .or. (ccarga >= ccargaini .and. ccarga <= ccargafim)
							
			aadd(aListBox,{	iif(empty(cProtocolo) .Or.  cRetCodNfe $ RetCodDene(),oNo,oOk),;
							cId,;
							ccarga,;
							cProtocolo,;
							substr(cRecomendacao,1,50);
						})
							
		Endif
			
	next	
    
    if Empty(aListBox) .and. lMsg .and. !lCte
    	//U_ITMSG("Não foram localizadas notas válidas","Atenção",,1)
    endIf

elseif !lCTe .And. lMsg
	u_itmsg(cAviso,"Atenção",,1)	
endif
    
return aListBox


/*
===============================================================================================================================
Programa----------: GetIdEnt
Autor-------------: Alex Wallauer
Data da Criacao---: 16/11/2021
===============================================================================================================================
Descrição---------: Funcao Static GetIdEnt() copiada do programa SPEDNF.PRX
===============================================================================================================================
Parametros--------: lUsaColab
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function GetIdEnt(lUsaColab)

local cIdEnt := ""
local cError := ""

Default lUsaColab := .F.

If !lUsaColab

	cIdEnt := getCfgEntidade(@cError)

	if(empty(cIdEnt))
		Aviso("SPED", cError, {"OK"}, 3) // STR0647 = "SPED"
	endif

else
	if !( ColCheckUpd() )
		Aviso("SPED", "UPDATE do TOTVS Colaboracao 2.0 nao aplicado. Desativado o uso do TOTVS Colaboracao 2.0",{"OK"},3) //STR0647 = "SPED", // STR0810 =  "UPDATE do TOTVS ColaboraÃ§Ã£o 2.0 nÃ£o aplicado. Desativado o uso do TOTVS ColaboraÃ§Ã£o 2.0"
	else
		cIdEnt := "000000"
	endif
endIf

Return(cIdEnt)


/*
===============================================================================================================================
Programa----------: INFOADQ
Autor-------------: Alex Wallauer
Data da Criacao---: 11/03/2021
===============================================================================================================================
Descrição---------: Tela de GEt dos dados da NF de Remessa
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER Function INFOADQ()
//================================================================================
//Tratamento para operação Triangular
//================================================================================
LOCAL _cPedRemessa := ""
LOCAL _cPedFaturam := ""
LOCAL _nMenFat     := ""
LOCAL _lEditaMens  := .T.
LOCAL _lRet        := .T.
LOCAL nLin    :=005
LOCAL nSay2   :=125
LOCAL nGet1   :=070
LOCAL nGet2   :=nSay2+50
LOCAL nPula   :=011
LOCAL _nLinDlg:=345
LOCAL _nLinFol:=060
LOCAL _nLinBtn:=_nLinFol+95
LOCAL _nRecOT := 0
LOCAL _nRecSC5:= PosicSC5(SF2->F2_DOC , SF2->F2_SERIE , SF2->F2_FILIAL)  // Retorna o numero do recno da tabela SC5 correspontentes a nota fiscal, serie e filial passados como parâmetros.
LOCAL _nRecSF2:= SF2->(RECNO())
PRIVATE _nMenRemessa:=""

BEGIN SEQUENCE// Essa lógica é para sempre pegar os dados das duas notas (venda e remessa) na geração da nota

    SC5->( DBGoTo( _nRecSC5 ))//Pedido atual Para saber o tipo atual

    If !SC5->C5_I_OPTRI $ "F,R" 
	    U_ITMSG("Essa NF não é tipo Remessa, Pedido: "+SC5->C5_NUM,'ATENÇÃO! C5_I_OPTRI ='+SC5->C5_I_OPTRI,"Posicione em uma NF tipo Remessa",3) // ALERT
        RETURN .F.//_lRet:=.F.//
    EndIf
    _cPedRemessa := SC5->C5_I_PVREM
    _cPedFaturam := SC5->C5_I_PVFAT
    SC5->(DBSetOrder(1))
    SF2->(DBOrderNickName("IT_I_PEDID"))
    
	//================================================================================
    //Nota Fiscal de Venda - Início
    //================================================================================
    If SC5->C5_I_OPTRI = "F" // Estou no PV de VENDA e vou buscar o de Remessa
	    U_ITMSG("Essa NF não é tipo Remessa, Pedido: "+SC5->C5_NUM,'Atenção! C5_I_OPTRI ='+SC5->C5_I_OPTRI,"Posicione em uma NF tipo Remessa",3) // ALERT
        RETURN .F.//_lRet:=.F.//
/*      //Se estou na NF de venda, posiciono na REMESSA
        If !SC5->(DBSeek(xFilial()+_cPedRemessa)) .OR. !SF2->(DBSEEK(xFilial()+_cPedRemessa))
            _nMenRemessa:= "NOTA FISCAL DO PEDIDO DE REMESSA : "+_cPedRemessa+" PENDENTE"
			_nMenFat:= "Apos gerar a Nota do Pedido de Remessa essa mensagem será preenchida automaticamente"
	        U_ITMSG(_nMenRemessa,'Atenção!',_nMenFat,3) // ALERT
            RETURN .F.
			_lEditaMens  := .F.
        EndIf
        //Carrega os dados da Carga do Pedido de REMESSA
        _nRecOT      := SF2->(RECNO())
        SF2->( DBGoTo( _nRecSF2 ))//NO CAMPO MEMO DA NF DE VENDA JA TEM OS DADOS DA DE REMESSA
        _nMenFat  := SF2->F2_I_MENOT//DADOS NA NF DE VENDA*/
    EndIf
    //================================================================================
    //Nota Fiscal de Venda - Fim
    //================================================================================

    SC5->( DBGoTo( _nRecSC5 ))//Volta para a nota atual onde estava para saber o tipo atual
    //================================================================================
    //Nota Fiscal de Remessa - Início
    //================================================================================
    If SC5->C5_I_OPTRI = "R" //Se o tipo atual for o PV de Remessa, busca a NF de Venda

        SA1->(DBSetOrder(1))
        If SA1->( DBSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ) ) .AND. SA1->A1_I_OBRAD = "S"
            _nMenRemessa:= SF2->F2_I_MENOT//DADOS DA NOTA DE REMESSA
        ELSE
	        U_ITMSG("Essa Nota de Remessa não é obrigada a informar os dados de adquirente",'Atenção!',"Posicione em uma NF tipo remessa que obrigue informar os dados (SA1->A1_I_OBRAD = 'S')",3) // ALERT
            RETURN .F.//_lRet:=.F.//
        EndIf

        //Se achou na de Remessa, posiciono na de venda
        If !SC5->(DBSeek(xFilial()+_cPedFaturam)) .OR. !SF2->(DBSeek(xFilial()+_cPedFaturam))
            _nMenRemessa:= "Nota Fiscal do Pedido de Venda : "+_cPedFaturam+" não gerada"
			_nMenFat:= "Somente permitido informar os dados da Nota Fiscal do Adquirente após a Transmissão da Nota fiscal de Vendas (Oper.05)."
	        U_ITMSG(_nMenRemessa,'Atenção!',_nMenFat,3) // ALERT
            RETURN .F.//_lRet:=.F.//
        EndIf
        //Se achou na de Remessa, posiciono na de venda
        If SF2->(DBSeek(xFilial()+_cPedFaturam)) .AND. EMPTY(SF2->F2_CHVNFE)
            _nMenRemessa:= "Nota Fiscal do Pedido de Venda : "+_cPedFaturam+" não transmitida para SEFAZ"
			_nMenFat:= "Somente permitido informar os dados da Nota Fiscal do Adquirente após a Transmissão da Nota fiscal de Vendas (Oper.05)."
	        U_ITMSG(_nMenRemessa,'Atenção!',_nMenFat,3) // ALERT
            RETURN .F.//_lRet:=.F.//
        EndIf

        _nMenFat  := SF2->F2_I_MENOT//DADOS NA NF DE VENDA
        _nRecOT:=SF2->(RECNO())
        SF2->( DBGoTo( _nRecSF2 ))
    EndIf
    //================================================================================
    //Nota Fiscal de Remessa - Fim
    //================================================================================
   
End SEQUENCE
//Volto para onde estava
SF2->(DBSetOrder(1))
SC5->( DBGoTo( _nRecSC5 ))
SF2->( DBGoTo( _nRecSF2 ))

lGrava:=.F.
_cF2_I_NTRIA:=M->F2_I_NTRIA:=SPACE(10)//SF2->F2_I_NTRIA / POR CAUSA DA ALTERACAO NÃO POSSO TRAZER O TEXTO JÁ GRAVADO PQ NÃO O No. da NF
_cF2_I_STRIA:=M->F2_I_STRIA:=SF2->F2_I_STRIA
_cF2_I_DTRIA:=M->F2_I_DTRIA:=SF2->F2_I_DTRIA
_nMenAdquirente:=SF2->F2_I_NTRIA
_nSMenRemessa  :=_nMenRemessa//SALVA O TESTO ORIGINAL
_nMenRemessa   :=_nSMenRemessa+SF2->F2_I_NTRIA//ENTER+"CONFORME NOTA DE VENDA DO ADQUIRENTE ORIGINARIO "+M->F2_I_NTRIA+" SERIE "+M->F2_I_STRIA+" EMITIDA DIA "+DTOC(M->F2_I_DTRIA)

DEFINE MSDIALOG oDlg TITLE "Mensagem da Nota Fiscal" FROM 000,000 TO _nLinDlg,500 PIXEL

	   oTPanel1 := TPanel():New( 0 , 0 , "" , oDlg , NIL , .T. , .F. , NIL , NIL , 600 , 200 , .T. , .F. )
	
	   @ nLin,010   SAY "NF/Serie : "+ SF2->F2_DOC +"/"+ SF2->F2_SERIE Of oTPanel1 Pixel 
	   @ nLin,nSay2 SAY "Emissao : "+ DTOC(SF2->F2_EMISSAO)	           Of oTPanel1 Pixel 
         nLin+=nPula

	   @ nLin,010   SAY "Pedido de Remessa : "+_cPedRemessa Of oTPanel1 Pixel 
       @ nLin,nSay2 SAY "Pedido de Venda : "  +_cPedFaturam Of oTPanel1 Pixel 
         nLin+=nPula+1

	   @ nLin+2,010 SAY "Nota Adquirente:"                 Of oTPanel1 Pixel 
  	   @ nLin,nGet1 MSGET M->F2_I_NTRIA SIZE 35, 010       OF oDlg VALID U_VLDMen(_oMemoRMen)  PIXEL
	   @ nLin+2,nSay2 SAY "Serie Adquirente:"              Of oTPanel1 Pixel 
  	   @ nLin,nGet2 MSGET M->F2_I_STRIA SIZE 25, 010       OF oDlg VALID U_VLDMen(_oMemoRMen)  PIXEL
         nLin+=nPula+2

	   @ nLin+2,010 SAY "Dt Emissao Adquirente:"           Of oTPanel1 Pixel 
  	   @ nLin,nGet1 MSGET M->F2_I_DTRIA SIZE 35, 010       OF oDlg VALID U_VLDMen(_oMemoRMen)  PIXEL
	   
	   aAbas:={};AADD(aAbas,"Mens. Adquirente");;AADD(aAbas,"Mens. Remessa");AADD(aAbas,"Mens. Fatur.")
	   oTFolder1 := TFolder():New( _nLinFol , 005 , aAbas ,, oTPanel1 ,,,, .T. ,, 240 , 090 )
	
       @005,005 Get _oMemoRMen VAR _nMenAdquirente MEMO Size 230,060 OF oTFolder1:aDialogs[1] PIXEL WHEN .T.//!_lEditaMens
       @005,005 Get _oMemoRMen VAR _nMenRemessa    MEMO Size 230,060 OF oTFolder1:aDialogs[2] PIXEL WHEN !_lEditaMens
       @005,005 Get _oMemoVMen VAR _nMenFat        MEMO Size 230,060 OF oTFolder1:aDialogs[3] PIXEL WHEN !_lEditaMens

       TButton():New( _nLinBtn , 045 , ' GRAVAR ', oTPanel1 , {|| lGrava:=.T. , oDlg:END() }	, 70 , 12 ,,,, .T. )
       TButton():New( _nLinBtn , 140 , ' SAIR '  , oTPanel1 , {|| lGrava:=.F. , oDlg:END() }	, 70 , 12 ,,,, .T. )

ACTIVATE MSDIALOG oDlg Centered

SF2->( DBGoTo( _nRecSF2 ))
IF lGrava .AND. !EMPTY(SF2->F2_CHVNFE)
    _nMenRemessa:="DADOS NÃO GRAVADOS"+ENTER+"Nota Fiscal do Pedido de Remessa : "+_cPedFaturam+" transmitida para SEFAZ"
	_nMenFat:= "Somente permitido informar os dados da Nota Fiscal do Adquirente antes da Transmissão."
    U_ITMSG(_nMenRemessa,'Atenção!',_nMenFat,1) // ALERT
    RETURN .F.
EndIf

IF lGrava .AND. _lRet
   SF2->( RecLock( "SF2" , .F. ) )
   //SF2->F2_I_MENOT := STRTRAN( _nMenRemessa , ENTER , "" )
   SF2->F2_I_NTRIA := _nMenAdquirente//M->F2_I_NTRIA
   SF2->F2_I_STRIA := M->F2_I_STRIA
   SF2->F2_I_DTRIA := M->F2_I_DTRIA
   SF2->( MSUNLOCK() )
ENDIF

RETURN _lRet

/*
===============================================================================================================================
Programa----------: INFOADQ
Autor-------------: Alex Wallauer
Data da Criacao---: 11/03/2021
===============================================================================================================================
Descrição---------: Tela de GEt dos dados da NF de Remessa
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER FUNCTION VLDMen(_oMemoRMen) 

IF EMPTY(_nMenAdquirente) .OR. (!EMPTY(M->F2_I_NTRIA) .AND. _cF2_I_NTRIA <> M->F2_I_NTRIA) .OR. _cF2_I_STRIA <> M->F2_I_STRIA .OR. _cF2_I_DTRIA <> M->F2_I_DTRIA 
   _nMenAdquirente:="CONFORME NOTA DE VENDA DO ADQUIRENTE ORIGINARIO "+M->F2_I_NTRIA+" SERIE "+M->F2_I_STRIA+" EMITIDA DIA "+DTOC(M->F2_I_DTRIA)
   _cF2_I_NTRIA:=M->F2_I_NTRIA
   _cF2_I_STRIA:=M->F2_I_STRIA
   _cF2_I_DTRIA:=M->F2_I_DTRIA
ENDIF
_nMenRemessa:=_nSMenRemessa+ENTER+_nMenAdquirente
_oMemoRMen:Refresh()
oTFolder1:Refresh()
RETURN .T.
/*
===============================================================================================================================
Programa----------: PosicSC5
Autor-------------: Julio de Paula Paz/ Copie de outro progrma Alex Wallauer
Data da Criacao---: 11/04/2018
===============================================================================================================================
Descrição---------: Posicionar o registro da tabela SC5 no registro correto, de acordo com os campos: F2_DOC,F2_SERIE
                    F2_FILIAL.
===============================================================================================================================
Parametros--------: _cNrNota = Numero da nota fiscal
                    _cSerie  = Serie da nota
                    _cCodFil = Codigo da filial
===============================================================================================================================
Retorno-----------: _nRet = Retorna o numero do recno da tabela SC5.
===============================================================================================================================
*/
Static function PosicSC5(_cNrNota,_cSerie,_cCodFil)
Local _nRet := 0
Local _aOrd := SaveOrd({"SC5"})
Local _nRegAtu := SC5->(Recno())

Begin Sequence
   SC5->(DbOrderNickName("IT_NOTA")) // C5_FILIAL+C5_NOTA+C5_LIBEROK+C5_BLQ+C5_I_BLPRC+C5_I_BLOQ // k = ordem 20
   SC5->(DbSeek(U_ITKEY(_cCodFil,"C5_FILIAL")+U_ITKEY(_cNrNota,"C5_NOTA")))
   
   Do While ! SC5->(Eof()) .And. SC5->(C5_FILIAL+SC5->C5_NOTA) == U_ITKEY(_cCodFil,"C5_FILIAL")+U_ITKEY(_cNrNota,"C5_NOTA")
      If SC5->C5_SERIE == U_ITKEY(_cSerie,"C5_SERIE")
         _nRet := SC5->(Recno())
      EndIf
      
      SC5->(DbSkip())
   EndDo
   
End Sequence

RestOrd(_aOrd)

SC5->(DbGoTo(_nRegAtu))

Return _nRet
