/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Josu� Danich  | 15/09/2017 | Revis�o para vers�o 12 - Chamado 21472
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 14/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"
#INCLUDE "TopConn.ch"   

/*
===============================================================================================================================
Programa----------: AOMS057
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 19/08/2011
===============================================================================================================================
Descri��o---------: Rotina desenvolvida para possibilitar consultar o cadastro de produtos, de forma a escolher varios produtos
					de uma unica vez. Consulta Padrao( F3 ) personalizada.   
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS057()

Local oDlgPro            

Local oGrupo
Local oDescr
Local oTESIn
Local oTESOut  
Local oEstado     

Local cGrupo     := Space(04)
Local cDescr     := Space(60)
Local cTESIn     := Space(03)
Local cTESOut    := Space(03)
Local cEstado    := Space(02)

Local _aArea     := {}
Local _aAlias    := {} 

Private oBoxLib
Private nOpc      := 0
Private bNbMarked := LoadBitmap( GetResources(), "LBNO" )
Private bMarked   := LoadBitmap( GetResources(), "LBOK" )
Private aGrd      := {{LoadBitmap(GetResources(),"BR_CINZA"   ),bNbMarked,"",""}}

//==================
// Grava o log
//==================
U_ITLOGACS() 

//==================
//  Salva a area. 
//==================
AOMS057C(1,@_aArea,@_aAlias,{"SB1","ZZP"})

//=================================
// Tela para escolha do produto. 
//=================================
DEFINE MSDIALOG oDlgPro TITLE "Pesquisa de Produtos" FROM 178,181 TO 665,967 PIXEL
SetKey(VK_F5, {|| fwMsgRun(,{||  AOMS057B(cGrupo,cDescr)},"Processando registros...","Aguarde...")})
SetKey(VK_F6, {|| AOMS057I(cTESIn,cTESOut,cEstado),Close(oDlgPro) })

@ 004,004 TO 045,391 LABEL "Pesquisa:"   PIXEL OF oDlgPro
@ 048,004 TO 220,391 LABEL "Resultados:" PIXEL OF oDlgPro

@ 016,008 Say "Grupo:" Size 018,006 COLOR CLR_BLACK PIXEL OF oDlgPro
@ 023,008 MSGet oGrupo Var cGrupo F3 "SBM" Size 037,009 PIXEL OF oDlgPro
oGrupo:SetFocus()                                

@ 016,048 Say "Descri��o:" Size 026,006 COLOR CLR_BLACK PIXEL OF oDlgPro
@ 023,048 MsGet oDescr Var cDescr Picture "@!" Size 200,009 COLOR CLR_BLACK PIXEL OF oDlgPro
        
@ 009,252 Say "      TES     " Size 050,006 COLOR CLR_BLACK PIXEL OF oDlgPro
@ 016,252 Say "Dentro Estado:" Size 050,006 COLOR CLR_BLACK PIXEL OF oDlgPro
@ 023,252 MSGet oTESIn Var cTESIn Picture "@!" F3 "SF4" Size 037,009 COLOR CLR_BLACK PIXEL OF oDlgPro VALID IIF(Len(AllTrim(cTESIn)) > 0,ExistCpo("SF4",cTESIn).And.MaAvalTes("S",cTESIn),.T.) WHEN Len(AllTrim(cEstado)) == 0                                          

@ 009,293 Say "     TES    " Size 040,006 COLOR CLR_BLACK PIXEL OF oDlgPro
@ 016,293 Say "Fora Estado:" Size 040,006 COLOR CLR_BLACK PIXEL OF oDlgPro
@ 023,293 MSGet oTESOut Var cTESOut Picture "@!" F3 "SF4" Size 037,009 COLOR CLR_BLACK PIXEL OF oDlgPro VALID IIF(Len(AllTrim(cTESOut)) > 0,ExistCpo("SF4",cTESOut).And.MaAvalTes("S",cTESOut),.T.)

@ 016,335 Say "   Estado:  " Size 040,006 COLOR CLR_BLACK PIXEL OF oDlgPro
@ 023,335 MSGet oEstado Var cEstado Picture "@!" F3 "12" Size 037,009 COLOR CLR_BLACK PIXEL OF oDlgPro VALID IIF(Len(AllTrim(cEstado)) > 0,ExistCpo("SX5","12" + cEstado),.T.) WHEN Len(AllTrim(cTESIn)) == 0

@ 055,007 ListBox oBoxLib  Fields Headers 	" "," ","Codigo","Descricao" Size 381,163;
ON DBLCLICK ( AOMS057M() ) Pixel Of oDlgPro

oBoxLib:SetArray(aGrd)
oBoxLib:bLine := {|| {aGrd[oBoxLib:nAt,1],;
aGrd[oBoxLib:nAt,2],;
aGrd[oBoxLib:nAt,3],;
aGrd[oBoxLib:nAt,4]}}

oBoxLib:bHeaderClick := {|| AOMS057A(), oBoxLib:Refresh()}

@ 226,313 Button "Pesquisar [F5]" Size 037,012 PIXEL OF oDlgPro;
Action(fwMsgRun(,{||  AOMS057B(cGrupo,cDescr)},"Processando registros...","Aguarde...")) 
@ 226,353 Button "Ok [F6]"        Size 037,012 PIXEL OF oDlgPro;
Action(AOMS057I(cTESIn,cTESOut,cEstado),Close(oDlgPro))

ACTIVATE MSDIALOG oDlgPro CENTERED

SetKey(VK_F5,Nil)
SetKey(VK_F6,Nil)

//====================
// Restaura a area. 
//====================
AOMS057C(2,_aArea,_aAlias)
               
If nOpc <> 1
	//======================================================================================
	//Deve ser retornado .F. para que o sistema NAO atualize o campo de destino.          
	//======================================================================================
	Return .F.			

	/*
	//======================================================================
	//Para que nao ocorra um erro na hora da insercao dos produtos        
	//quando o usuario digitar um codigo do produto invalido e            
	//chamar a tela de selecao de produtos, pois desta forma nao          
	//eram inseridos os produtos informados na tela de selecao de produtos
	//pois validava o codigo incorreto do produto fornecido anteriormente.
	//======================================================================
	*/
Else
		
	M->ZZP_PRODUT:=""
	
EndIf

//======================================================================================
//Deve ser retornado .T. para que o sistema atualize o campo de destino               
//N�o precisa for�ar o campo no retorno pois o mesmo � atualizado pela montagem do SXB
//======================================================================================
Return .T.

/*
===============================================================================================================================
Programa----------: AOMS057M
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 19/08/2011
===============================================================================================================================
Descri��o---------: Funcao executada ao pressionar Duplo Clik na linha do Grid
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  

Static Function AOMS057M()

//Se nao esta marcado
If (aGrd[oBoxLib:nAt,2] == bNbMarked)
	aGrd[oBoxLib:nAt,2] := bMarked
Else
	aGrd[oBoxLib:nAt,2] := bNbMarked
EndIf

oBoxLib:Refresh()

Return

/*
===============================================================================================================================
Programa----------: AOMS057B
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 19/08/2011
===============================================================================================================================
Descri��o---------: Filtra os produtos na base e os apresenta na tela.
===============================================================================================================================
Parametros--------: cGrupo - Grupo de produtos a ser filtrado
					cDescr - M�scara de descri��o do produto
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  

Static Function AOMS057B(cGrupo,cDescr)

Local cQuery    := ""

Local _cAlias   := GetNextAlias()   
Local _nquant := 0

//===================================
// Query para filtrar os produtos. 
//===================================
cQuery := "SELECT B1_COD, B1_I_DESCD"
cQuery += " FROM " + RetSqlName("SB1")
cQuery += " WHERE D_E_L_E_T_ <> '*'"
cQuery += " AND B1_FILIAL  = '" + xFILIAL("SB1") + "'"
cQuery += " AND B1_MSBLQL <> '1'"

If !Empty(cGrupo) //Se o grupo nao esta vazio
	cQuery += " AND B1_GRUPO = '" + AllTrim(cGrupo) + "'"
EndIf

If !Empty(cDescr) //Se a descricao nao esta vazia, verifica se a expressao contem na descricao do produto
	cQuery += " AND B1_I_DESCD LIKE '%"+ AllTrim(cDescr) +"%'   "
EndIf

cQuery += " ORDER BY B1_I_DESCD"
cQuery := ChangeQuery(cQuery)     
                                
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), _cAlias, .T., .F. )
Count to _nquant

If _nquant > 10000

  u_itmsg("Filtro selecionado retornou mais de 10.000 produtos!","Aten��o","Modifique o filtro para trazer menos produtos na consulta",1)
  
  Return
  
Endif

//=====================================================
// Limpa o array que apresenta os produtos na tela. 
//=====================================================
aGrd := {}

//=============================================================
// Processa o arquivo do select preenchendo o array do Grid. 
//=============================================================
dbSelectArea(_cAlias)
(_cAlias)->(dbGoTop())

While (_cAlias)->(!EoF())
	
	aAdd(aGrd, {LoadBitmap(GetResources(),"BR_VERDE"),;
	bNbMarked 		    ,;
	(_cAlias)->B1_COD	,;
	(_cAlias)->B1_I_DESCD})
	
	(_cAlias)->(dbSkip())  
	
EndDo

If Len(aGrd) <= 0
	aGrd := {	{LoadBitmap(GetResources(),"BR_CINZA"),;
	bNbMarked,;
	"",;
	""}}
EndIf

dbSelectArea(_cAlias)
(_cAlias)->(dbCloseArea())

oBoxLib:SetArray(aGrd)
oBoxLib:bLine := {|| {aGrd[oBoxLib:nAt,1],;
aGrd[oBoxLib:nAt,2],;
aGrd[oBoxLib:nAt,3],;
aGrd[oBoxLib:nAt,4]}}
oBoxLib:Refresh()

Return

/*
===============================================================================================================================
Programa----------: AOMS057A
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 19/08/2011
===============================================================================================================================
Descri��o---------: Funcao para marcar e desmarcar todos os titulos
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  

Static Function AOMS057A()

Local nI    := 0
Local lMark := If(aGrd[1,2]==bMarked,.T.,.F.)

For nI := 1 To Len(aGrd)
	If (aGrd[nI,2] == bMarked)
		aGrd[nI,2] := If(lMark,bNbMarked,bMarked)
	Else
		aGrd[nI,2] := If(lMark,bNbMarked,bMarked)
	EndIf
Next

oBoxLib:Refresh()

Return

/*
===============================================================================================================================
Programa----------: AOMS057A
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 19/08/2011
===============================================================================================================================
Descri��o---------: Static Function auxiliar no GetArea e ResArea retornando   
           			o ponteiro nos Aliases descritos na chamada da Funcao.     
           			Exemplo:                                                   
           			Local _aArea  := {} // Array que contera o GetArea         
           			Local _aAlias := {} // Array que contera o                 
                               // Alias(), IndexOrd(), Recno()        
                                                                      
                               // Chama a Funcao como GetArea                             
                               AOMS057A(1,@_aArea,@_aAlias,{"SL1","SL2","SL4"})         
                                                                      
                               // Chama a Funcao como RestArea                            
                               AOMS057A(2,_aArea,_aAlias)        
===============================================================================================================================
Parametros--------:  nTipo   = 1=GetArea / 2=RestArea                           
           			_aArea  = Array passado por referencia que contera GetArea 
           			_aAlias = Array passado por referencia que contera         
           			{Alias(), IndexOrd(), Recno()}                   
           			_aArqs  = Array com Aliases que se deseja Salvar o GetArea
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  

Static Function AOMS057C(_nTipo,_aArea,_aAlias,_aArqs)

Local _nN := 0

// Tipo 1 = GetArea()
If _nTipo == 1
	_aArea := GetArea()
	For _nN := 1 To Len(_aArqs)
		DbSelectArea(_aArqs[_nN])
		AAdd(_aAlias,{ _aArqs[_nN], IndexOrd(), Recno() })
	Next
	// Tipo 2 = RestArea()
Else
	For _nN := 1 To Len(_aAlias)
		DbSelectArea(_aAlias[_nN,1])
		DbSetOrder(_aAlias[_nN,2])
		DbGoto(_aAlias[_nN,3])
	Next
	RestArea(_aArea)
Endif

Return

/*
===============================================================================================================================
Programa----------: AOMS057I
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 19/08/2011
===============================================================================================================================
Descri��o---------: Chamada ao pressionar F6 ou o botao de Ok. Insere no aCols os produtos marcados.
===============================================================================================================================
Parametros--------: _cTESIN - TES utilizada dentro do estado. 
					_cTESOUT - TES utilizada fora do estado.
					_cEstado - Estado da Tes
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/ 
Static Function AOMS057I(_cTESIN,_cTESOUT,_cEstado)

Local cNroItem:= aCols[Len(aCols)][1]
Local nI      := 0
Local lMark   := .F.    
Local nProc		:= 0
Local _nItem  := 1

For nI := 1 To Len(aGrd)
	
	//===============================================
	// Se esta marcado.                            
	//===============================================
	If (aGrd[nI,2] == bMarked)
		
		//========================================================
		// Identifica se pelo menos um produto foi selecionado. 
		//========================================================
		If !Empty(Alltrim(aGrd[nI,3]))
		    lMark := .T.
		EndIf
		
		//If !Empty(Alltrim(aCols[Len(aCols)][2])) 		
		/*
		//=========================================================================
		//Condicao inserida para que seja inserido o primeiro item na linha atual
		//que o usuario esteja posicionado.                                      
		//=========================================================================
		*/
		If _nItem <> 1
			
			//===============================================
			// Inicializa o Acols com uma linha em Branco. 
			//===============================================
			AADD(aCols,Array(Len(aHeader)+1))
			
			//=========================
			// Incrementa os Itens.  
			//=========================
			cNroItem := Soma1(cNroItem)
		EndIf  
		
		_nItem++
					
		//EndIf       		
		
		//================================================
		// Preenche o aCols com os campos da Estrutura. 
		//================================================
		For nProc := 1 To Len(aHeader)        
		
			If AllTrim(aHeader[nProc][2]) == "ZZP_ITEM"
				aCols[Len(aCols)][nProc] := cNroItem
			ElseIf AllTrim(aHeader[nProc][2]) == "ZZP_PRODUT"
				aCols[Len(aCols)][nProc] := aGrd[nI,3]
			ElseIf AllTrim(aHeader[nProc][2]) == "ZZP_DESCRI"
				aCols[Len(aCols)][nProc] := aGrd[nI,4]
			ElseIf AllTrim(aHeader[nProc][2]) == "ZZP_TSIN"
				aCols[Len(aCols)][nProc] := _cTESIN
			ElseIf AllTrim(aHeader[nProc][2]) == "ZZP_TSOUT"
				aCols[Len(aCols)][nProc] := _cTESOUT 
			ElseIf AllTrim(aHeader[nProc][2]) == "ZZP_ESTADO"
				aCols[Len(aCols)][nProc] := _cEstado			
			EndIf
			
			//===================================================
			// Informa que a linha do Acols nao esta deletada. 
			//===================================================
			aCols[Len(aCols)][Len(aHeader)+1] := .F.     
			
		Next nProc
	EndIf
Next nI

//=======================================================
// Verifica se pelo menos um produto foi marcado,     
// se sim nOpc recebe 1 para que a funcao retorne .T. 
//=======================================================
If lMark
	nOpc := 1
EndIf              

Return