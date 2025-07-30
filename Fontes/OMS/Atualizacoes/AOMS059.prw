/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 14/10/2019 | Chamado 28346. Removidos os Warning na compila��o da release 12.1.25. 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 23/04/2021 | Chamado 36219. Corrigidos erros apresentado durante testes pelo fiscal. 
-------------------------------------------------------------------------------------------------------------------------------
Igor Fricks   | 12/05/2022 | Chamado 36219. Corrigidos erros apresentado durante testes pelo fiscal. 
-------------------------------------------------------------------------------------------------------------------------------
Igor Fricks   | 16/05/2022 | Chamado 37448. Adcionado a fun��o copiar. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 13/06/2022 | Chamado 40456. Tratamento para o Novo Campo de Exceto Produto (ZZQ_PRODUT). 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 02/05/2022 | Chamado 43678. Cria��o e tratamento do novo bot�o " Excluir T�tulos". 
-------------------------------------------------------------------------------------------------------------------------------
Antonio Neves | 20/12/2024 | Chamado 45908. Exclus�o do T�tulo de CP que n�o est� tratado. 
-------------------------------------------------------------------------------------------------------------------------------
Antonio Neves | 26/01/2024 | Chamado 46172. Tratativa para considerar impedimento do cadastro NCM x MVA tambem o item de exce��o.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"
#Include "TopConn.ch"
/*
===============================================================================================================================
Programa----------: AOMS059
Autor-------------: Guilherme D. Gesualdo
Data da Criacao---: 03/09/2012
===============================================================================================================================
Descri��o---------: Cadastro de Regras NCM x MVA
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER FUNCTION AOMS059()
 
Private cAlias 		:= "ZZQ"
Private cCadastro 	:= "Cadastro de Regra NCM x MVA"
Private aRotina 	:= {}
Private cDelFunc 	:= ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
_aItalac_F3:={}
_bSelectSB1:={ || "SELECT B1_COD , B1_DESC FROM "+RETSQLNAME("SB1")+" SB1 WHERE B1_POSIPI = '"+aCOLS[n,GdFieldPos("ZZQ_NCM")]+"' AND D_E_L_E_T_ <> '*' ORDER BY B1_COD " }
AADD(_aItalac_F3,{"M->ZZQ_PRODUT",_bSelectSB1,{|Tab| (Tab)->B1_COD }                , {|Tab| (Tab)->B1_DESC   }   ,          ,"Produtos",,,010       ,.F.        ,       , } )

AADD( aRotina , { "Pesquisar"	   , "AxPesqui"  , 0 , 1 } )
AADD( aRotina , { "Visualizar"	   , "U_ZZQMNT"  , 0 , 2 } )
AADD( aRotina , { "Incluir"		   , "U_ZZQINC"  , 0 , 3 } )
AADD( aRotina , { "Manutencao"	   , "U_ZZQMNT"  , 0 , 4 } )
AADD( aRotina , { "Excluir T�tulos", "U_AOMS59E" , 0 , 5 } )
AADD( aRotina , { "Copiar"		   , "U_ZZQCPY"  , 0 , 3 } )

DBSelectArea(cAlias)
DBSetOrder(1)

MBrowse( ,,,, cAlias )

Return()

/*
===============================================================================================================================
Programa----------: ZZQINC
Autor-------------: Guilherme D. Gesualdo
Data da Criacao---: 03/09/2012
===============================================================================================================================
Descri��o---------: Fun��o para inclus�o de Regras - Utilizado no c�lculo e gera��o dos t�tulos de ST Antecipados
===============================================================================================================================
Parametros--------: cAlias , nReg , nOpc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER FUNCTION ZZQINC( cAlias , nReg , nOpc )

Local oTPanel1	:= Nil

Private oDlg	:= Nil
Private oGet	:= Nil

Private cCodigo	:= SPACE(6) 
Private cLoja	:= SPACE(4)
Private cNome	:= SPACE(40) 

Private aHeader	:= {} 
Private aCols	:= {} 
Private aReg	:= {} 

//Log de utiliza��o
U_ITLOGACS()

dbSelectArea( cAlias ) 
dbSetOrder(1)

ZZQHEADER(cAlias) 
ZZQCOLS( cAlias , nReg , nOpc )

DEFINE MSDIALOG oDlg TITLE cCadastro From 8,0 To 28,80 OF oMainWnd 
	
	oTPanel1 := TPanel():New(30,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,20,.T.,.F.) 
	
	@ 5, 006 SAY "C�d. Cliente:" SIZE 70,7 PIXEL OF oTPanel1 
	@ 5, 080 SAY "Loja:"         SIZE 70,7 PIXEL OF oTPanel1 
	@ 5, 140 SAY "Nome:"         SIZE 70,7 PIXEL OF oTPanel1 
	
	@ 4, 038 MSGET cCodigo F3 "SA1_02" PICTURE "@!" VALID U_ZZQCLI() SIZE 32,7 PIXEL OF oTPanel1
	@ 4, 095 MSGET Iif(cCodigo <> ' ',cLoja,' ') PICTURE "@!" SIZE 30,7 PIXEL OF oTPanel1
	@ 4, 160 MSGET Iif(cCodigo <> ' ',cNome,' ') WHEN .F.	PICTURE "@!" SIZE 150,7 PIXEL OF oTPanel1
		
	oGet := MSGetDados():New(0,0,0,0,nOpc,"U_ZZQTVLD('I')","AllwaysTrue()",,.T.)
	
    oDlg:lMaximized:=.T.

ACTIVATE MSDIALOG oDlg CENTER ON INIT (EnchoiceBar(oDlg,{|| IIF(U_ZZQTVLD('I'), ZZQGRVI(),.F.)},{|| oDlg:End() })  , oTPanel1:Align := CONTROL_ALIGN_TOP , oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT  )

Return 

/*
===============================================================================================================================
Programa----------: ZZQMNT
Autor-------------: Guilherme D. Gesualdo
Data da Criacao---: 03/09/2012
===============================================================================================================================
Descri��o---------: Fun��o para manuten��o das Regras - Utilizado no c�lculo e gera��o dos t�tulos de ST Antecipados
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER FUNCTION ZZQMNT(cAlias,nReg,nOpc)

Local oTPanel1 

Private cCodigo := SPACE(6) 
Private cLoja   := SPACE(4)
Private cNome   := SPACE(40) 

Private oDlg 
Private oGet 

Private aHeader := {}
Private aCOLS := {} 
Private aReg := {} 

//Log de utiliza��o
U_ITLOGACS()

dbSelectArea(cAlias) 
dbGoTo(nReg) 

cCodigo := ZZQ->ZZQ_CLIENT
cLoja   := ZZQ->ZZQ_LOJA
cNome   := Posicione("SA1",1,xFilial("SA1")+cCodigo,"A1_NOME")

ZZQHEADER(cAlias)
ZZQCOLS(cAlias, nReg, nOpc)

DEFINE MSDIALOG oDlg TITLE cCadastro From 8,0 To 28,80 OF oMainWnd 
	
	oTPanel1 := TPanel():New(30,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,20,.T.,.F.) 
	
	@ 5, 006 SAY "C�d. Cliente:" SIZE 70,7 PIXEL OF oTPanel1 
	@ 5, 080 SAY "Loja:"         SIZE 70,7 PIXEL OF oTPanel1 
	@ 5, 140 SAY "Nome:"         SIZE 70,7 PIXEL OF oTPanel1
	
	@ 4, 038 MSGET cCodigo F3 "SA1_02"  SIZE 32,7 PIXEL OF oTPanel1 
	@ 4, 095 MSGET cLoja   SIZE 30,7 PIXEL OF oTPanel1 
	@ 4, 160 MSGET cNome   When .F. SIZE 150,7 PIXEL OF oTPanel1
	
	If nOpc == 4 
		oGet := MSGetDados():New(0,0,0,0,nOpc,"U_ZZQTVLD('M')","AllwaysTrue()",,.T.) 
	Else
		oGet := MSGetDados():New(0,0,0,0,nOpc) 
	Endif 

    oDlg:lMaximized:=.T.
	
ACTIVATE MSDIALOG oDlg CENTER ON INIT (EnchoiceBar(oDlg,{|| IIF(U_ZZQTVLD('M'), ZZQALT(),.F.) },{|| oDlg:End() }) , oTPanel1:Align := CONTROL_ALIGN_TOP , oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT  )

Return()

/*
===============================================================================================================================
Programa----------: ZZQHEADER
Autor-------------: Guilherme D. Gesualdo
Data da Criacao---: 03/09/2012
===============================================================================================================================
Descri��o---------: Fun��o para Montagem do Cabe�alho do GRID na tela
===============================================================================================================================
Parametros--------: cAlias
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ZZQHEADER(cAlias) 

Local aArea := GetArea() 
Local _aZZQ := ZZQ->(Dbstruct())
Local _nnj	:= 0

For _nnj := 1 to len(_aZZQ)

	If 	Trim(_aZZQ[_nnj][1]) <> "ZZQ_FILIAL" .And. ;
	Trim(_aZZQ[_nnj][1]) <> "ZZQ_CLIENT" .And. ;
	Trim(_aZZQ[_nnj][1]) <> "ZZQ_LOJA"
	 
	  	 
	AADD( aHeader, { trim(getsx3cache(_aZZQ[_NNJ][1],"X3_TITULO") ),;
							getsx3cache(_aZZQ[_NNJ][1],"X3_CAMPO")		,;
							getsx3cache(_aZZQ[_NNJ][1],"X3_PICTURE")		,;
							getsx3cache(_aZZQ[_NNJ][1],"X3_TAMANHO")		,;
							getsx3cache(_aZZQ[_NNJ][1],"X3_DECIMAL")		,;
							getsx3cache(_aZZQ[_NNJ][1],"X3_VALID")		,;
							getsx3cache(_aZZQ[_NNJ][1],"X3_USADO")		,;
							getsx3cache(_aZZQ[_NNJ][1],"X3_TIPO")			,;
							getsx3cache(_aZZQ[_NNJ][1],"X3_ARQUIVO")		,;
							getsx3cache(_aZZQ[_NNJ][1],"X3_CONTEXT")	})
		
	Endif 

Next


RestArea(aArea) 

Return

/*
===============================================================================================================================
Programa----------: ZZQCOLS
Autor-------------: Guilherme D. Gesualdo
Data da Criacao---: 03/09/2012
===============================================================================================================================
Descri��o---------: Fun��o para incializa��o do GRID - Utilizado no c�lculo e gera��o dos t�tulos de ST Antecipados
===============================================================================================================================
Parametros--------: cAlias, nReg, nOpc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ZZQCOLS(cAlias, nReg, nOpc) 

Local aArea  := GetArea() 
Local cChave := ZZQ->ZZQ_CLIENTE+ZZQ->ZZQ_LOJA 
Local nI     := 0,nColuna

If nOpc <> 3   

	dbSelectArea(cAlias) 
	dbSetOrder(1) 
	dbSeek(xFilial(cAlias)+cChave) 
	
	While !EOF() .And. ZZQ->(ZZQ_FILIAL+ZZQ_CLIENTE+ZZQ_LOJA) == xFilial(cAlias)+cChave 
	
		AADD(aReg, ZZQ->(RecNo()))
		AADD(aCOLS, Array(Len(aHeader)+1)) 
		
		For nI := 1 To Len( aHeader ) 
		
			If aHeader[nI,10] == "V" 
				aCOLS[Len(aCOLS),nI] := CriaVar(aHeader[nI,2],.T.) 
			Else
				aCOLS[Len(aCOLS),nI] := FieldGet(FieldPos(aHeader[nI,2])) 
			Endif 
			
		Next nI 
		
		aCOLS[Len(aCOLS),Len(aHeader)+1] := .F. 
		
		dbSkip() 
	
	End 
	
Else 
	aCols := Array(1,Len(aHeader)+1)

	// Inicializa��o do aCols
	For nColuna := 1 to Len(aHeader)

		If aHeader[nColuna][8] == "C"
			aCols[1][nColuna] := SPACE(aHeader[nColuna][4])
		ElseIf aHeader[nColuna][8] == "N"
			aCols[1][nColuna] := 0
		ElseIf aHeader[nColuna][8] == "D"
			aCols[1][nColuna] := CTOD("")
		ElseIf aHeader[nColuna][8] == "L"
			aCols[1][nColuna] := .F.
		ElseIf aHeader[nColuna][8] == "M"
			aCols[1][nColuna] := ""
		Endif
		
	Next nColuna

	aCols[1][Len(aHeader)+1] := .F. // Linha n�o deletada
	
Endif 

Restarea(aArea) 


Return

/*
===============================================================================================================================
Programa----------: ZZQGRVI
Autor-------------: Guilherme D. Gesualdo
Data da Criacao---: 03/09/2012
===============================================================================================================================
Descri��o---------: Fun��o para grava��o das Regras na opera��o de Inclus�o
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ZZQGRVI() 

Local aArea := GetArea() 
Local nI    := 0 
Local nX    := 0 

dbSelectArea("ZZQ") 
dbSetOrder(1) 

For nI := 1 To Len( aCOLS ) 

	If ! aCOLS[nI,Len(aHeader)+1] 
	
	RecLock("ZZQ",.T.) 
		ZZQ->ZZQ_FILIAL := xFilial("ZZQ") 
		ZZQ->ZZQ_CLIENT := cCodigo 
		ZZQ->ZZQ_LOJA   := cLoja 
		
		For nX := 1 To Len( aHeader ) 
		
			FieldPut( FieldPos( aHeader[nX, 2] ), aCOLS[nI, nX] ) 
			
		Next nX 
		
	MsUnLock("ZZQ") 
	
	Endif 
	
Next nI 

RestArea(aArea) 

oDlg:End()

Return

/*
===============================================================================================================================
Programa----------: ZZQALT
Autor-------------: Guilherme D. Gesualdo
Data da Criacao---: 03/09/2012
===============================================================================================================================
Descri��o---------: Fun��o para grava��o nas opera��es de manuten��o das Regras
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ZZQALT() 

Local aArea := GetArea() 
Local nI := 0
Local nX := 0 

dbSelectArea("ZZQ")

For nI := 1 To Len(aCols) 

	If nI <= Len(aReg) 
		
		dbGoTo(aReg[nI]) 
		
		RecLock("ZZQ",.F.) 
		
		If aCols[nI, Len(aHeader)+1] 
		
			dbDelete() 
            
		Else
			
			ZZQ->ZZQ_FILIAL  := xFilial("ZZQ") 
			ZZQ->ZZQ_CLIENTE := cCodigo 
			ZZQ->ZZQ_LOJA    := cLoja
			
			For nX := 1 To Len(aHeader) 
			
				FieldPut(FieldPos(aHeader[nX, 2]), aCOLS[nI, nX]) 
				
			Next nX
			
		EndIf 
		
		MsUnLock()
	
	Else 
 		
 		If 	!aCols[nI, Len(aHeader)+1]  
	
			RecLock("ZZQ",.T.) 
	
   			ZZQ->ZZQ_FILIAL  := xFilial("ZZQ") 
			ZZQ->ZZQ_CLIENTE := cCodigo 
			ZZQ->ZZQ_LOJA    := cLoja 
			
			For nX := 1 To Len(aHeader) 
			
				FieldPut(FieldPos(aHeader[nX, 2]), aCOLS[nI, nX]) 
				
			Next nX 
			
		EndIf
	
	EndIf 
	
	MsUnLock() 
	
Next nI

RestArea(aArea)

oDlg:End() 

Return

/*
===============================================================================================================================
Programa----------: ZZQLVLD
Autor-------------: Guilherme D. Gesualdo
Data da Criacao---: 03/09/2012
===============================================================================================================================
Descri��o---------: Fun��o para valida��o dos dados nas linhas do GRID
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ZZQLVLD() 

Local aArea := GetArea()

Local lRet := .T. 
Local nI   := 0 
Local cMsg1 := "N�o ser� permitido linhas sem o NCM!" 
Local cMsg2 := "N�o ser� permitido linhas sem o MVA!" 
Local cMsg3 := "O NCM inserido j� foi cadastrado!"

For nI := 1 To Len( aCOLS ) 

If aCOLS[nI, Len(aHeader)+1] 
	Loop 
Endif

If ( aCols[len(aCols)][Len(aHeader)+1] == .F. ) 

	If !aCOLS[nI, Len(aHeader)+1] 
		If Empty(aCOLS[n,GdFieldPos("ZZQ_NCM")]) 
			U_ITMSG(cMsg1,"Aten��o",,1)
			lRet := .F.
			Exit
		ElseIf Empty(aCOLS[n,GdFieldPos("ZZQ_MVA")]) 
			U_ITMSG(cMsg2,"Aten��o",,1)
			lRet := .F.
			Exit
		ElseIf ( (nI <> n) .and. (aCols[nI][1] == aCols[n][1]) .and. (aCols[nI][Len(aHeader)+1] == .F.) )
			U_ITMSG(cMsg3,"Aten��o",,1)
			lRet := .F.
			Exit
		EndIf
	Endif 

EndIf

Next nI 

RestArea(aArea)

Return(lRet)

/*
===============================================================================================================================
Programa----------: ZZQTVLD
Autor-------------: Guilherme D. Gesualdo
Data da Criacao---: 03/09/2012
===============================================================================================================================
Descri��o---------: Fun��o para valida��o Total das Regras antes da grava��o
===============================================================================================================================
Parametros--------: _cTipo
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ZZQTVLD( _cTipo ) 

Local _aArea	:= GetArea()
Local _cQuery	:= ''
Local _cAlias	:= GetNextAlias()
Local _lRet		:= .T.
Local _nI		:= 0 

For _nI := 1 To Len( aCOLS )

	If aCOLS[ _nI ][ Len(aHeader) + 1 ]
		Loop
	Endif
	
	If !( aCols[ Len(aCols) ][ Len(aHeader) + 1 ] )
	
		If !aCOLS[ _nI ][ Len(aHeader) + 1 ]
		
			If Empty( aCOLS[ n ][ GdFieldPos("ZZQ_NCM") ] )
			
				u_itmsg('O NCM � obrigat�rio para todos os itens do cadastro.',"Aten��o",'Verifique os dados informados!',1 )

				_lRet := .F.
				Exit
			
			EndIf
			
			If Empty( aCOLS[ n ][ GdFieldPos("ZZQ_MVA") ] )
			
				u_itmsg('O MVA � obrigat�rio para todos os itens do cadastro.',"Aten��o",'Verifique os dados informados!',1 )
	
				_lRet := .F.
				Exit
				
			EndIf
			
			If ( ( _nI <> n ) .And. ( aCols[_nI][1] == aCols[n][1] ) .And. ( aCols[_nI][2] == aCols[n][2] ) .And. ( aCols[_nI][5] == aCols[n][5] ) .And. !aCols[n][Len(aHeader)+1] )
			
				u_itmsg('O NCM + Perc. MVA + C�d. Exce��o j� foi inclu�do no cadastro anteriormente.',"Aten��o",'Verifique os dados informados!',1 )

				_lRet := .F.
				Exit
				
			EndIf
			
		EndIf
		
		If _lRet .And. _cTipo == "I"
		
			_cQuery := " SELECT COUNT(1) AS REGS FROM "+ RetSqlName('ZZQ') +" ZZQ WHERE "+ RetSqlCond('ZZQ') +" AND ZZQ.ZZQ_NCM = '"+ aCols[n][1] +"' AND ZZQ.ZZQ_EXCNCM = '"+ aCols[n][5] +"' "+;
						"AND ZZQ_CLIENT = '"+cCodigo+"' AND ZZQ_LOJA = '"+cLoja+"'"
			
			If Select(_cAlias) > 0
				(_cAlias)->( DBCloseArea() )
			EndIf
			
			DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )
			
			DBSelectArea(_cAlias)
			(_cAlias)->( DBGoTop() )
			If (_cAlias)->( !Eof() ) .And. (_cAlias)->REGS > 0
			
				u_itmsg('O NCM + C�d. Exce��o j� foi inclu�do no cadastro anteriormente.',"Aten��o",'Verifique os dados informados!',1 )
			
				_lRet := .F.
				
			EndIf
			
			(_cAlias)->( DBCloseArea() )
		
		EndIf
	
	EndIf
	
Next _nI

RestArea( _aArea )

Return( _lRet )

/*
===============================================================================================================================
Programa----------: ZZQNCM
Autor-------------: Guilherme D. Gesualdo
Data da Criacao---: 03/09/2012
===============================================================================================================================
Descri��o---------: Fun��o para valida��o dos c�digos NCM
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ZZQNCM()
	
Local _aArea	:= GetArea()
Local _cQuery	:= ""
Local _cAlias	:= GetNextAlias()
Local _lRet		:= .T.          
Local _cNcm		:= ALLTRIM(M->ZZQ_NCM)
Local _nQtdNcm	:= 0

//====================================================================================================
// Query que verifica se o ncm est� cadastrado no cadastro de produto
//====================================================================================================
_cQuery := " SELECT COUNT(1) AS CONTNCM "
_cQuery += " FROM "+ RetSqlName("SB1")
_cQuery += " WHERE "
_cQuery += "     D_E_L_E_T_ = ' ' "
_cQuery += " AND B1_POSIPI  = '"+ _cNcm +"' "
_cQuery += " AND B1_TIPO    = 'PA' "

If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )

DBSelectArea(_cAlias)
(_cAlias)->( DBGoTop() )
If (_cAlias)->( !Eof() )
	_nQtdNcm := (_cAlias)->CONTNCM
EndIf

(_cAlias)->( DBCloseArea() )

If _nQtdNcm == 0

	u_itmsg('O NCM informado n�o existe no cadastro de Produtos do Sistema.',"Aten��o",'Verifique os dados informados!',1 )

	_lRet := .F.

EndIf
	
RestArea(_aArea)

Return( _lRet )

/*
===============================================================================================================================
Programa----------: ZZQCLI
Autor-------------: Guilherme D. Gesualdo
Data da Criacao---: 03/09/2012
===============================================================================================================================
Descri��o---------: Fun��o para valida��o dos dados de Clientes
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ZZQCLI()
	
Local _aArea    := GetArea()
Local _cQuery   := ""
Local lRet      := .T.
Local nQtdCli  	:= 0 

If cCodigo <> ' '

	//Query que verifica se o cliente entra na regra
	_cQuery := " SELECT SUM(INSTR('"+AllTrim(GetMv('IT_STEST'))+"',A1_EST)) AS CONTCLI "
	_cQuery += " FROM " + RetSqlName("SA1")
	_cQuery += " WHERE D_E_L_E_T_ <> '*'"
	_cQuery += " AND   A1_COD = '" + cCodigo + "' "
	_cQuery += " AND   A1_I_STESP = 'N' "
	
	If Select("QCLI") > 0
		dbSelectArea("QCLI")
		QCLI->(dbCloseArea())
	EndIf
	
	TcQuery _cQuery New Alias "QCLI"
	
	dbSelectArea("QCLI")
	dbGoTop()
	
	nQtdCli := QCLI->CONTCLI

	dbSelectArea("QCLI")
	dbCloseArea()
	
	If nQtdCli == 0
	
		u_itmsg("CLIENTE N�O EXISTENTE OU FORA DA REGRA DE GERA��O","Aten��o","Teclando F3 voc� pode ver os clientes que podem ser cadastrados.",1 )
	
		lRet := .F.

	EndIf

EndIf
	
RestArea(_aArea)

Return(lRet)


/*
===============================================================================================================================
Programa----------: ZZQCPY
Autor-------------: Igor Melga�o
Data da Criacao---: 12/05/2022
===============================================================================================================================
Descri��o---------: Fun��o para manuten��o das Regras - Utilizado no c�lculo e gera��o dos t�tulos de ST Antecipados
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER FUNCTION ZZQCPY(cAlias,nReg,nOpc)

Local oTPanel1 

Private cCodigo := SPACE(6) 
Private cLoja   := SPACE(4)
Private cNome   := SPACE(40) 

Private oDlg 
Private oGet 

Private aHeader := {}
Private aCOLS   := {} 
Private aReg    := {} 

//Log de utiliza��o
U_ITLOGACS()

DbSelectArea(cAlias) 
DbGoTo(nReg) 

cCodigo := Space(Len(ZZQ->ZZQ_CLIENT))
cLoja   := Space(Len(ZZQ->ZZQ_LOJA))
cNome   := Space(Len(Posicione("SA1",1,xFilial("SA1")+cCodigo,"A1_NOME")))

ZZQHEADER(cAlias)
ZZQCOLS(cAlias, nReg, nOpc)

DEFINE MSDIALOG oDlg TITLE cCadastro From 8,0 To 28,80 OF oMainWnd 
	
	oTPanel1 := TPanel():New(30,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,20,.T.,.F.) 
	
	@ 5, 006 SAY "C�d. Cliente:" SIZE 70,7 PIXEL OF oTPanel1 
	@ 5, 080 SAY "Loja:"         SIZE 70,7 PIXEL OF oTPanel1 
	@ 5, 140 SAY "Nome:"         SIZE 70,7 PIXEL OF oTPanel1
	
	@ 4, 038 MSGET cCodigo F3 "SA1_02"  PICTURE "@!" VALID U_ZZQCLI() SIZE 32,7 PIXEL OF oTPanel1 
	@ 4, 095 MSGET cLoja   PICTURE "@!" SIZE 30,7 PIXEL OF oTPanel1 
	@ 4, 160 MSGET cNome   When .F. SIZE 150,7 PIXEL OF oTPanel1
	
	If nOpc == 4 
		oGet := MSGetDados():New(0,0,0,0,nOpc,"U_ZZQTVLD('I')","AllwaysTrue()",,.T.) 
	Else
		oGet := MSGetDados():New(0,0,0,0,nOpc) 
	Endif 

    oDlg:lMaximized:=.T.

ACTIVATE MSDIALOG oDlg CENTER ON INIT (EnchoiceBar(oDlg,{|| IIF(U_ZZQTVLD('I'), ZZQGRVI(),.F.) },{|| oDlg:End() }) , oTPanel1:Align := CONTROL_ALIGN_TOP , oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT  )

Return()

/*
===============================================================================================================================
Programa----------: AOMS59E
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 02/05/2023
===============================================================================================================================
Descri��o---------: Fun��o com intuito de permitir que o usu�rio tenha a possibilidade de excluir os t�tulos gerados pela 
------------------: rotina uma vez que se for identificado alguma parametriza��o indevida.
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER Function AOMS59E(cAlias,nReg,nOpc)
Local _aParRet :={}
Local _aParAux :={} , nI 

MV_PAR01:=dDataBase
MV_PAR02:=dDataBase

AADD( _aParAux , { 1 , "Dt Emiss�o de"	      , MV_PAR01, "@D"	, ""	, ""		, "" , 060 , .T. } )
AADD( _aParAux , { 1 , "Dt Emiss�o ate"       , MV_PAR02, "@D"	, ""	, ""		, "" , 060 , .T. } )

For nI := 1 To Len( _aParAux )
	aAdd( _aParRet , _aParAux[nI][03] )
Next nI

DO WHILE .T.
             //aParametros, cTitle            , @aRet     ,[bOk]  , [ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ] 
   IF !ParamBox( _aParAux , "FILTRAR TITULOS" , @_aParRet ,/*bOK*/, /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
      EXIT
   EndIf

   _aDados:={}
   _nTotalM:=0
   _cTimeIni:=TIME()
   FWMSGRUN( ,{|oproc| _aDados:=AOMS59Ler(oproc) } , "Aguarde!" , "Hora Inicial: "+_cTimeIni+" / Executando a SELECT ..." )

   If LEN(_aDados) > 0
   
       aCab:={}
       AADD(aCab," ")
       AADD(aCab," ")
       AADD(aCab ,"Filial")
       AADD(aCab ,"Dt Emissao")    
       AADD(aCab ,"No. Titulo") ; _nPosTit:=LEN(aCab)
       AADD(aCab ,"Parcela")    
       AADD(aCab ,"Prefixo")    
       AADD(aCab ,"Tipo")  
       AADD(aCab ,"Natureza")    
       AADD(aCab ,"Cliente")
       AADD(aCab ,"Loja")  
       AADD(aCab ,"Dt Vecto")   
       AADD(aCab ,"Dt Vecto Real")    
       AADD(aCab ,"Valor") 
       AADD(aCab ,"Saldo") 
       AADD(aCab ,"Dt Baixa") 
       AADD(aCab ,"Situacao") 
       AADD(aCab ,"Registro") 
   	
       _cTitulo2:='Exclusao de Titulos - Data: ' + DtoC(Date()) 
       _cMsgTopFixo:=" - Dt Inicial: "+ALLTRIM(AllToChar(MV_PAR01))+"; Dt Final: "+ALLTRIM(AllToChar(MV_PAR02))+" -  H.I.: "+_cTimeIni+" H.F.: "+TIME()
       _cMsgTop:="Total Selecionado : "+ ALLTRIM(Transform(  _nTotalM  , "9999" ))+_cMsgTopFixo

       _bDblClk := {|| U_AOMS59Marca( @oLbxAux, @oSayAux, @_cMsgTop,.F.) }
       _bHeadClk := {|oLbx, ni| Iif(ni=1,FWMSGRUN( ,{|oProc|  U_AOMS59Marca( @oLbxAux, @oSayAux, @_cMsgTop, .T.,oProc) } , "Processando... " ),.F.)  }

		_aButtons:={}
		AADD(_aButtons,{"",{|| AOMS59Vis(oLbxAux:aArray[oLbxAux:nAt][LEN(oLbxAux:aArray[oLbxAux:nAt])])  },"", "Visualizar Titulo" })
        aAdd(_aButtons,{"",{|| AOMS59Pes( oLbxAux ) }, "" , "PESQUISAR TITULO"} )

	//      ITListBox(_cTitAux , _aHeader , _aCols ,_lMaxSiz,_nTipo,_cMsgTop,_lSelUnc , _aSizes , _nCampo , bOk , bCancel, _aButtons )
   	   If U_ITListBox(_cTitulo2, aCab     , _aDados, .T.    , 2    ,_cMsgTop, .F.     ,         ,         ,     ,        , _aButtons,, _bDblClk ,,,,, _bHeadClk )
          
          
          FWMSGRUN( ,{|oProc|  AOMS59Exc(oProc) }  , "Processando... " )

   	   Endif
     	
   Endif


ENDDO

RETURN 

/*
===============================================================================================================================
Programa----------: MOMS66Pesq
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 08/05/2022
===============================================================================================================================
Descri��o---------: Pesquisa Pedidos
===============================================================================================================================
Parametros--------: _oLbxAux
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/
Static Function AOMS59Pes( oLbxAux ) 

Local _oGet1		:= Nil
Local _oDlg			:= Nil
Local _cGet1		:= SPACE(LEN(SE1->E1_NUM))
Local _nOpca		:= 0
Local nPos			:= 0
Local _lAchou		:= .F.

IF oLbxAux <> NIL
   N:=oLbxAux:nAt
   aCols:=oLbxAux:aArray
ELSE
   RETURN .F.
ENDIF

DEFINE MSDIALOG _oDlg TITLE "Pesquisar Numero do Titulo" FROM 178,181 TO 259,697 PIXEL 

@005,003 SAY "Numero do Titulo para Pesquisar :" Size 213,010 PIXEL OF _oDlg
@020,003 MsGet _oGet1 Var _cGet1				 Size 212,009 PIXEL OF _oDlg COLOR CLR_BLACK Picture "@!" F3 "SE1"

DEFINE SBUTTON FROM 004,227 TYPE 1 ENABLE ACTION ( _nOpca := 1 , _oDlg:End() ) OF _oDlg
DEFINE SBUTTON FROM 021,227 TYPE 2 ENABLE ACTION ( _nOpca := 0 , _oDlg:End() ) OF _oDlg

ACTIVATE MSDIALOG _oDlg CENTERED

If _nOpca == 1
   _cGet1 := RTrim( _cGet1 )
   If (nPos := ASCAN(aCols,{|P| P[_nPosTit] == _cGet1 }) ) <> 0 
   	  oLbxAux:nAt    := N :=nPos
   	 _lAchou:= .T.
   EndIf	  	
ELSE
   RETURN _cRet//RETORNA O CONTEUDO DELE MESMO 
EndIf

If _lAchou
   oLbxAux:Refresh()
   oLbxAux:SetFocus()
   U_ITMSG("O Titulo "+_cGet1+" esta na linha: "+ALLTRIM(STR(nPos)),'Aten��o!',,2) 
ELSE
   U_ITMSG("Titulo n�o encontrado nesta lista.",'Aten��o!',"Tente outro Titulo",3) 
EndIf

RETURN .T.



/*
===============================================================================================================================
Programa----------: AOMS59Ler
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 02/05/2023
===============================================================================================================================
Descri��o---------: Fun��o com intuito de permitir que o usu�rio tenha a possibilidade de excluir os t�tulos gerados pela 
------------------: rotina uma vez que se for identificado alguma parametriza��o indevida.
===============================================================================================================================
Parametros--------: cAlias,nReg,nOpc
===============================================================================================================================
Retorno-----------: _aDados
===============================================================================================================================
*/
STATIC Function AOMS59Ler(oproc)
Local _cAlias2:= GetNextAlias()
LOCAL _cQuery := "SELECT "  
_cQuery += " R_E_C_N_O_ SE1REC "
_cQuery += "FROM " + RetSqlName("SE1") + " E1 "  
_cQuery += "WHERE E1.D_E_L_E_T_ = ' ' "
_cQuery += "  AND E1.E1_FILIAL  = '" + xFilial("SE1") + "' "   
_cQuery += "  AND E1.E1_TIPO    = 'ICM' "
_cQuery += "  AND E1.E1_ORIGEM  = 'GRVICMST' "  
_cQuery += "  AND E1.E1_EMISSAO BETWEEN '" + DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' " 
_cQuery += "ORDER BY E1_NUM, E1_EMISSAO,  E1_PARCELA"


cTimeINI:=TIME()
DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias2 , .T. , .F. )
   
_nTot:=nConta:=0
COUNT TO _nTot
_cTotGeral:=ALLTRIM(STR(_nTot))

cTimeFIM:="Hora Incial: "+cTimeINI+" - Hora Final: "+TIME()+" da leitura dos dados"

(_cAlias2)->(DbGoTop())
IF (_cAlias2)->(EOF())
   U_ITMSG("N�o tem titulos para listados com esses filtros.",cTimeFIM,"Altere os filtros.",3) 
   RETURN {}
ENDIF
      
IF _nTot > 500 .AND. !U_ITMSG("Ser�o listados "+_cTotGeral+' titulos , Confirma ?',cTimeFIM,,3,2,3,,"CONFIRMA","VOLTAR")
   RETURN {}
ENDIF
      
_aDados:={}
_nTotalM:=0
DO WHILE (_cAlias2)->(!EOF()) //**********************************  WHILE  ******************************************************
            
    IF oproc <> NIL
       nConta++
       oproc:cCaption := ("Lendo "+STRZERO(nConta,5) +" de "+ _cTotGeral )
       ProcessMessages()
    ENDIF
	
	SE1->(DBGOTO((_cAlias2)->SE1REC))
    If EMPTY(SE1->E1_BAIXA) .AND.  SE1->E1_SALDO = SE1->E1_VALOR
       _nTotalM++
    EndIf

    _aProd := {}
    AADD(_aProd , EMPTY(SE1->E1_BAIXA) .AND.  SE1->E1_SALDO = SE1->E1_VALOR .AND. SE1->E1_SITUACA = "0") 
    AADD(_aProd , EMPTY(SE1->E1_BAIXA) .AND.  SE1->E1_SALDO = SE1->E1_VALOR .AND. SE1->E1_SITUACA = "0") 
    AADD(_aProd ,SE1->E1_FILIAL )   
    AADD(_aProd ,SE1->E1_EMISSAO)    
    AADD(_aProd ,SE1->E1_NUM    ) 
    AADD(_aProd ,SE1->E1_PARCELA)    
    AADD(_aProd ,SE1->E1_PREFIXO)    
    AADD(_aProd ,SE1->E1_TIPO   )  
    AADD(_aProd ,SE1->E1_NATUREZ)    
    AADD(_aProd ,SE1->E1_CLIENTE)    
    AADD(_aProd ,SE1->E1_LOJA   )  
    AADD(_aProd ,SE1->E1_VENCTO )   
    AADD(_aProd ,SE1->E1_VENCREA)
    AADD(_aProd ,"R$ "+TRANS(SE1->E1_VALOR,"@E 999,999,999,999.99")  ) 
    AADD(_aProd ,"R$ "+TRANS(SE1->E1_SALDO,"@E 999,999,999,999.99")  ) 
    AADD(_aProd ,SE1->E1_BAIXA)
    AADD(_aProd ,IF(SE1->E1_SITUACA<>"0","EM BORDERO","          "))	
    AADD(_aProd ,SE1->(RECNO()))
    AADD(_aDados , _aProd  )
          
    (_cAlias2)->(dbSkip())
      
ENDDO


Return _aDados

/*
===============================================================================================================================
Programa----------: AOMS59Exc
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 08/05/2023
===============================================================================================================================
Descri��o---------: Rotina de exclusao do SE1
===============================================================================================================================
Parametros--------: oProc = Status de Processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
STATIC Function AOMS59Exc( oProc )
Local nI
Local nModAnt  := nModulo
Local cModAnt  := cModulo
Local _lSegue  := .T.  //Para excluir a SE1 somente se OK na exclus�o da SE2
Local _TitSE2  //ARRRAY PARA CARREGAR OS DADOS DO T�TULO DA SE2 PARA EXCLUS�O

_nConta:=0
// Altera o modulo para Financeiro, senao o SigaAuto nao executa.
nModulo := 6
cModulo := "FIN"

For nI := 1 To Len( _aDados )
     
	IF _aDados[nI,1] 

//INICIO DO TRATAMENTO DA EXCLUS�O DA SE2
		dbSelectArea("SE2")
		SE2->(dbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA                                                                                               
		If SE2->(dbSeek(_aDados[nI][3]+_aDados[nI][7]+_aDados[nI][5]+_aDados[nI][6]+_aDados[nI][8]))
     	
		DO WHILE SE2->(!EOF()) .AND. SE2->E2_FILIAL == _aDados[nI][3] .AND. SE2->E2_PREFIXO == _aDados[nI][7];
							   .AND. SE2->E2_NUM == _aDados[nI][5] .AND. SE2->E2_PARCELA == _aDados[nI][6];
							   .AND. SE2->E2_TIPO == _aDados[nI][8] .AND. SE2->E2_ORIGEM == "GRVICMST"
					_TitSE2 := {}
					aAdd(_TitSE2, {"E2_FILIAL",  SE2->E2_FILIAL,    Nil})
					aAdd(_TitSE2, {"E2_NUM",     SE2->E2_NUM,    Nil})
					aAdd(_TitSE2, {"E2_PREFIXO", SE2->E2_PREFIXO,Nil})
					aAdd(_TitSE2, {"E2_PARCELA", SE2->E2_PARCELA,Nil})
					aAdd(_TitSE2, {"E2_TIPO",    SE2->E2_TIPO,    Nil})
					aAdd(_TitSE2, {"E2_NATUREZ", SE2->E2_NATUREZ,    Nil})
					aAdd(_TitSE2, {"E2_FORNECE", SE2->E2_FORNECE,    Nil})
					aAdd(_TitSE2, {"E2_LOJA", SE2->E2_LOJA,    Nil})
					aAdd(_TitSE2, {"E2_NOMFOR", SE2->E2_NOMFOR,    Nil})
					aAdd(_TitSE2, {"E2_EMISSAO", SE2->E2_EMISSAO,    Nil})
					aAdd(_TitSE2, {"E2_VENCTO", SE2->E2_VENCTO,    Nil})
					aAdd(_TitSE2, {"E2_VENCREA", SE2->E2_VENCREA,    Nil})
					aAdd(_TitSE2, {"E2_VALOR", SE2->E2_VALOR,    Nil})
					aAdd(_TitSE2, {"E2_CONTAD", SE2->E2_CONTAD,    Nil})
					aAdd(_TitSE2, {"E2_HIST", SE2->E2_HIST,    Nil})
					aAdd(_TitSE2, {"E2_MOEDA", SE2->E2_MOEDA,    Nil})
					aAdd(_TitSE2, {"E2_ORIGEM",  "GRVICMST",     Nil})


        SE2->(DBSKIP())
        ENDDO  
		EndIf
		SE2->(dbCloseArea())


If !Empty(_TitSE2) 
//Inicia o controle de transa��o
Begin Transaction
    //Chama a rotina autom�tica
    lMsErroAuto := .F.
    MsExecAuto( { |x,y,z| FINA050(x,y,z)},_TitSE2,, 5) // 3 - Inclusao, 4 - Altera��o, 5 - Exclus�o
    //Se houve erro, mostra o erro ao usu�rio e desarma a transa��o
    If lMsErroAuto
        MostraErro()
        DisarmTransaction()
		_lSegue := .F.
    EndIf
//Finaliza a transa��o
End Transaction
EndIf 
//Fim da Tratativa da Exclus�o da SE2

//TRATATIVA DA SE1
If _lSegue
	   SE1->(DBGOTO( _aDados[nI,LEN(_aDados[nI] )]) )
       _cChave:=SE1->(E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
       _cChavErro:="Nota: "+SE1->E1_NUM+" / Cliente+Loja: "+SE1->E1_CLIENTE+SE1->E1_LOJA+" / Pref.: "+SE1->E1_PREFIXO+" / Parc.: "+SE1->E1_PARCELA
/*
        aArray:={{"E1_FILIAL"	,SE1->E1_FILIAL	, NIL },;
    			 {"E1_NUM"		,SE1->E1_NUM	, NIL },;
    			 {"E1_CLIENTE"	,SE1->E1_CLIENTE, NIL },;
    			 {"E1_LOJA"		,SE1->E1_LOJA   , NIL },;
        		 {"E1_PREFIXO"	,SE1->E1_PREFIXO, NIL },;
    			 {"E1_PARCELA"	,SE1->E1_PARCELA, NIL },;
              	 {"E1_TIPO"		,SE1->E1_TIPO	, NIL }}*/

	     aArray  := {	{"E1_FILIAL"  ,SE1->E1_FILIAL    		,Nil},;
         	          	{"E1_CLIENTE" ,SE1->E1_CLIENTE      	,Nil},;
	     				{"E1_LOJA"	  ,SE1->E1_LOJA 	     	,Nil},;
         	          	{"E1_PREFIXO" ,SE1->E1_PREFIXO   		,Nil},;
	     				{"E1_NUM"	  ,SE1->E1_NUM     	     	,Nil},;
	     				{"E1_TIPO"	  ,SE1->E1_TIPO           	,Nil},;
	     				{"E1_ORIGEM"  ,SE1->E1_ORIGEM         	,Nil}}      
	     

        lMsErroAuto := .F.	
	    MsExecAuto( {|x,y| FINA040( x , y ) } , aArray , 5 )  // 3 - Inclusao, 4 - Altera��o, 5 - Exclus�o
	
        SE1->( DBSetOrder(2) )//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	    If lMsErroAuto .OR. (lAchou:=SE1->(DBSeek(_cChave)))//SE1->(DBSEEK( SF1->F1_FILIAL+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC ))
		   IF lMsErroAuto
	          _cErro:=(MostraErro())
		   ELSE
	          _cErro:="Nao exclui titulo, tente novamente!"
		   ENDIF
           bBloco:={||  AVISO("MostraErro()",_cErro,{"Fechar"},3) }
           U_ITMSG("N�o foi possivel excluir o titulo / "+_cChavErro,"ATENCAO!","Verifique a mensagen de erro [Mais Detalhes] e tente novamente: ",1,,,,,,bBloco)
        ELSE
	    	_nConta++
        EndIf

   ENDIF
EndIf      	  
Next	

// Restaura o modulo em uso.
nModulo := nModAnt
cModulo := cModAnt


U_itmsg('Processo conclu�do com sucesso. Titulos excluidos: '+CValToChar(_nConta),"Aten��o",,2)

RETURN .T.

/*
===============================================================================================================================
Programa----------: MDIN019GR
Autor-------------: Igor Melga�o
Data da Criacao---: 23/02/2022
===============================================================================================================================
Descri��o---------: Rotina de grava��o do Array
===============================================================================================================================
Parametros--------: oLbxDados = Objeto Lisbox 
------------------: oSayAux   = Objeto Say da Mensagem
------------------: _cMsgTop  = Mesnsagem exibida em cima do Listbox 
------------------: lHeader   = Define se foi executado no Clique na primeira coluna
------------------: oProc     = Status de Processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS59Marca( oLbxDados, oMsgStop, _cMsgTop, lHeader,oProc)
Local _nPos := 0
Local _nTam := 0

Default lHeader := .F.

   If lHeader
      _nTam := Len( oLbxDados:aArray )
      oproc:cCaption := ("Atualizando os registros...   Total: "+AllTrim(Str(_nTam)))
      ProcessMessages()
      
	  _nTotalM:=0
      For _nPos := 1 To _nTam
          If oLbxDados:aArray[ _nPos , 02 ]
		     oLbxDados:aArray[ _nPos , 01 ] := !oLbxDados:aArray[ _nPos , 01 ]
             If oLbxDados:aArray[ _nPos , 01 ]
                _nTotalM ++
             EndIf
          EndIf
      Next
   Else
      _nPos := oLbxAux:nAt

      If oLbxDados:aArray[ _nPos , 02 ]
         oLbxDados:aArray[ _nPos , 01 ] := !oLbxDados:aArray[ _nPos , 01 ]
         If oLbxDados:aArray[ _nPos , 01 ]
            _nTotalM ++
         Else
            _nTotalM --
         EndIf
      EndIf

   EndIf

   _cMsgTop :="Total Selecionado : "+ ALLTRIM(Transform(  _nTotalM  , "9999" ))+_cMsgTopFixo
   oMsgStop:cCaption:=_cMsgTop
   oMsgStop:Refresh()
   oLbxDados:Refresh()

Return()


/*
===============================================================================================================================
Programa----------: AOMS59Vis
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 08/05/2023
===============================================================================================================================
Descri��o---------: Funcao para Visualizacao do SE1.
===============================================================================================================================
Parametros--------: nRecno	
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/ 
Static Function AOMS59Vis(nRecno)
Local aArea:= GetArea()
cCadastro:="Visualizar Titulo" 

DbSelectArea("SE1")
SE1->(DbSetOrder(1))
SE1->(DBGOTO( nRecno ))
AxVisual( "SE1", SE1->( Recno() ), 2 )

RestArea( aArea )        
RETURN .t.
