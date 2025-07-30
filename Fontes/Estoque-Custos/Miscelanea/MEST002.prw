/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
André Lisboa  |22/09/2016| Chamado 17011. Correção no valor do custo a importar da planilha
André Lisboa  |01/04/2024| Chamado 46767. Permitir importar valores com 5 casas decimais e negativos                   |
Lucas Borges  |08/10/2024| Chamado 48465. Retirada manipulação do SX1
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*
===============================================================================================================================
Programa----------: MEST002
Autor-------------: Guilherme Diogo
Data da Criacao---: 22/10/2012
===============================================================================================================================
Descrição---------: Rotina para realizar a importacao de dados atraves de um arquivo CSV contendo dados do almoxarifado para a 
tabela ZZR, que será responsável pela rotina de atualização de estoque.   
===============================================================================================================================
Uso---------------: Italac
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
Usuario-----------: 
===============================================================================================================================
Setor-------------: TI
===============================================================================================================================
*/
User Function MEST002()

Local _bProcess    	:= {|oSelf|MEST002I(oSelf)}
Local _cFunction   	:= "MEST002"
Local _cTitle      	:= "Importação de Planilha do Almoxarifado"
Local _cDescri		:= "Rotina com o objetivo ler arquivo CSV para gerar a importacao da Planilha do Almoxarifado"

Private	_cPerg   	:= "MEST002"

tNewProcess():New( _cFunction, _cTitle, _bProcess, _cDescri, _cPerg,,,,,,.T. )

Return
/*
===============================================================================================================================
Programa----------: MEST002I
Autor-------------: Guilherme Diogo
Data da Criacao---: 22/10/2012
===============================================================================================================================
Descrição---------: Funcao responsavel por realizar a importacao dos dados.
===============================================================================================================================
Uso---------------: Italac
===============================================================================================================================
Parametros--------: oSelf - objeto da tela de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
Usuario-----------: 
===============================================================================================================================
Setor-------------: TI
===============================================================================================================================
*/
Static Function MEST002I(oSelf)

Local _cDados   	:= ""
Local _nCont    	:= 0
Local _nReg     	:= 0
Local _lRet     	:= .T.
//Local _cArmPad  	:= ""
Local _nCusMed  	:= 0
Local lCusto 		:= .F.
Local nQtdPl 		:= 0
//Local _cAlias  	:= GetNextAlias()
Local _cTipo 		:= ""

Private _aLog   := {}

//---------------------------------------------------------
//verifica parâmetros de armazém e arquivo origem
//---------------------------------------------------------

If len(alltrim(mv_par02)) < 2

xmaghelpfis("Armazém Inválido",;
		"Entrar com armazém válido.")
		Return
	
EndIf

If len(alltrim(mv_par03)) < 6

	//se campo de documento não está completamente preenchido gera automaticamente um número de documento
	MV_PAR03 := NextNumero("ZZR",1,"ZZR_DOC",.T.,"")
	
	xmaghelpfis("Documento Inválido",;
	"Será utilizado o número de documento " + ALLTRIM(MV_PAR03))
	
Else

	//verifica se o número de documento já não existe no arquivo
	_ctemp   := MV_PAR03
	MV_PAR03 := NextNumero("ZZR",1,"ZZR_DOC",.F.,MV_PAR03)
	
	if _ctemp != MV_PAR03
	
		xmaghelpfis("Documento já existente",;
		"Será utilizado o número de documento " + ALLTRIM(MV_PAR03))
		
	Endif
	
Endif

If Len(AllTrim(mv_par01)) > 0
	
	If FT_FUSE(mv_par01) == -1
		
		xmaghelpfis("Arquivo inválido",;
		"Não foi possível abrir o arquivo informado.",;
		"Favor verificar se o arquivo informado esta correto.")
		Return
	EndIf
	
	FT_FGOTOP() //POSICIONA NO TOPO DO ARQUIVO
	
	_nReg:= FT_FLASTREC()
	
	If _nReg == 0 //O arquivo informado nao possui nenhuma linha de dados
		
		xmaghelpfis("Arquivo inválido",;
		"O arquivo informado para relizar a importação não possui dados.",;
		"Favor verificar se o arquivo informado esta correto.")
		Return
	EndIf
	
	oSelf:SetRegua1(_nReg)
	oSelf:SaveLog("INICIO - IMPORTACAO PLANILHA DO ALMOXARIFADO")
	AADD(_aLog,"INICIO - IMPORTACAO PLANILHA DO ALMOXARIFADO")
	
	While !FT_FEOF()  //FACA ENQUANTO NAO FOR FIM DE ARQUIVO
		
		_nCont++
		
		If _nCont == 1
			
			FT_FSKIP()
			
		Else

			_lRet:= .T.
			
			//_cDados := strtokarr(FT_FREADLN(),";") // retorna array dos campos
			_cDados := SEPARA(FT_FREADLN(),";") // retorna array dos campos
			
			oSelf:IncRegua1("PRODUTO: " + AllTrim(_cDados[1]))
			
			//Nao existe dados na linha corrente
			If Len(_cDados) == 0 .or. len(alltrim(_cDados[1])) < 6
		
				oSelf:SaveLog("PROBLEMA ENCONTRADO NA LINHA: " + Alltrim(STRZERO(_nCont,4)))
				AADD(_aLog,"PROBLEMA ENCONTRADO NA LINHA: " + Alltrim(STRZERO(_nCont,4)))
				_lRet:= .F.
		
			EndIf
			
			//verifica se produto existe
			DBSelectArea("SB1")
			SB1->(dbSetOrder(1))
			
			If .not. SB1->(dbseek(xfilial("SB1")+alltrim(_cDados[1])))
		
				oSelf:SaveLog("PRODUTO INVALIDO NA LINHA: " + Alltrim(STRZERO(_nCont,4)) + " - " + _cDados[1])
				AADD(_aLog,"PRODUTO INVALIDO NA LINHA: " + Alltrim(STRZERO(_nCont,4))+ " - " + _cDados[1])
				_lRet:= .F.
	
			Endif
		
			If  _lRet
				
				lCusto := .F. //LOCAL DE ONDE CALCULA O CUSTO
				

				nQtdPl := Iif(ALLTRIM(_cDados[2])<>"", VAL(STRTRAN(_cDados[2],",",".")),0)
				_nCusMed := Iif(ALLTRIM(_cDados[6])<>"", VAL(STRTRAN(_cDados[6],",",".")),0)
				
				_nCusMed := Round(_nCusMed , 5)
				
				If _nCusMed = 0 //_nCusMed <= 0
					lCusto := .T.
					_nCusMed := Round( MEST002C(ALLTRIM(_cDados[1])) * nQtdPl , 5 )
				EndIf
				
				RecLock("ZZR",.T.)
				
				ZZR->ZZR_FILIAL := xFilial("ZZR")
				ZZR->ZZR_LINHA  := STRZERO(_nCont,4)
				ZZR->ZZR_COD    := _cDados[1]
				ZZR->ZZR_SALDO  := Round(nQtdPl,2)
				ZZR->ZZR_LOCAL  := MV_PAR02
				ZZR->ZZR_QMINI  := Iif(ALLTRIM(_cDados[4])<>"",VAL(STRTRAN(_cDados[4],",",".")),0)
				ZZR->ZZR_QMAX   := Iif(ALLTRIM(_cDados[5])<>"",VAL(STRTRAN(_cDados[5],",",".")),0)
				ZZR->ZZR_CUSTO  := _nCusMed
				ZZR->ZZR_STATUS := "1"
				ZZR->ZZR_DOC	:= MV_PAR03
				ZZR_LOCALIZ	  	:= _cDados[3]
				ZZR_OBS		  	:= MV_PAR04
				
				ZZR->(MsUnlock())
				
				_cTipo := posicione("SB1",1,xfilial("SB1")+alltrim(_cDados[1]),"B1_TIPO")

				If lCusto .and. _cTipo != "PA 
					oSelf:SaveLog("FOI UTILIZADO O CUSTO DA NOTA FISCAL ENTRADA PARA O PRODUTO "  + Alltrim(_cDados[1]) + " LOCALIZADO NA "+CVALTOCHAR(_nCont)+"ª LINHA")
					AADD(_aLog,"FOI UTILIZADO O CUSTO DA NOTA FISCAL ENTRADA PARA O PRODUTO "  + Alltrim(_cDados[1]) + " LOCALIZADO NA "+CVALTOCHAR(_nCont)+"ª LINHA")
				Elseif lCusto .and. _cTipo == "PA 
					oSelf:SaveLog("FOI UTILIZADO O CUSTO DA NOTA FISCAL VENDA PARA O PRODUTO "  + Alltrim(_cDados[1]) + " LOCALIZADO NA "+CVALTOCHAR(_nCont)+"ª LINHA")
					AADD(_aLog,"FOI UTILIZADO O CUSTO DA NOTA FISCAL VENDA PARA O PRODUTO "  + Alltrim(_cDados[1]) + " LOCALIZADO NA "+CVALTOCHAR(_nCont)+"ª LINHA")
				Else
					oSelf:SaveLog("FOI UTILIZADO O CUSTO DA PLANILHA PARA O PRODUTO "  + Alltrim(_cDados[1]) + " LOCALIZADO NA "+CVALTOCHAR(_nCont)+"ª LINHA")
					AADD(_aLog,"FOI UTILIZADO O CUSTO DA PLANILHA PARA O PRODUTO "  + Alltrim(_cDados[1]) + " LOCALIZADO NA "+CVALTOCHAR(_nCont)+"ª LINHA")
				EndIf
				
			EndIf
			
			FT_FSKIP()   //próximo registro no arquivo CSV
			
		EndIf
		
	EndDo
	
	FT_FUSE()//Fecha o arquivo
	
	oSelf:SaveLog("FINAL - IMPORTACAO PLANILHA DO ALMOXARIFADO")
	AADD(_aLog,"FINAL - IMPORTACAO PLANILHA DO ALMOXARIFADO")
	
EndIf

Processa({||MEST002S(_aLog)},"Gravando dados no arquivo...")

//Registra acesso
U_ITLOGACS('MEST002')

//volta a tela inicial
U_MEST002()

Return

/*
===============================================================================================================================
Programa----------: MEST002C
Autor-------------: Microsiga  
Data da Criacao---: 22/12/2012
===============================================================================================================================
Descrição---------: Verifica o custo da ultima nota de entrada do produto
===============================================================================================================================
Uso---------------: Italac
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
Usuario-----------: 
===============================================================================================================================
Setor-------------: TI
===============================================================================================================================
*/
Static Function MEST002C(_cCod)

Local _cQuery   := ""
Local _cAliasCM := GetNextAlias()
Local _nCusto   := 0
Local _cTipo 	  := posicione("SB1",1,xfilial("SB1")+alltrim(_cCod),"B1_TIPO")

//se o produto não é PA pega o custo das notas de entrada
If  _ctipo != "PA"

	// obter o custo na maior data e ultimo registro na filial corrente
	_cQuery := "SELECT * "
	_cQuery += "FROM "
	_cQuery += "	(SELECT DECODE(D1_QUANT,0,D1_CUSTO,D1_CUSTO/D1_QUANT) CUSTO_UNIT "
	_cQuery += "	FROM "+RetSqlName("SD1")+" D1 "
	_cQuery += "	INNER JOIN "+RetSqlName("SF4")+" F4 "
	_cQuery += "	ON F4.D_E_L_E_T_ = ' ' "
	_cQuery += "	AND D1.D1_FILIAL = F4.F4_FILIAL "
	_cQuery += "	AND D1.D1_TES = F4.F4_CODIGO "
	_cQuery += "	WHERE D1.D_E_L_E_T_ = ' ' "
	_cQuery += "    AND D1.D1_FILIAL = '"+XFilial("SD1")+"' "
	_cQuery += "    AND F4.F4_FILIAL = '"+XFilial("SF4")+"' "
	_cQuery += "	AND F4.F4_ESTOQUE = 'S' "
	_cQuery += "	AND F4.F4_DUPLIC = 'S' "
	_cQuery += "	AND D1.D1_TIPO <> 'C' "
	_cQuery += "    AND D1.D1_COD = '"+_cCod+"' "
	_cQuery += "	ORDER BY D1_FILIAL, D1_DTDIGIT DESC , D1.R_E_C_N_O_ DESC) "
	_cQuery += "WHERE ROWNUM <= 1 "
	

	If Select(_cAliasCM) > 0
		(_cAliasCM)->(dbCloseArea())
	EndIf

	dbUseArea( .T., "TOPCONN",TcGenQry(,,_cQuery),_cAliasCM,.T.,.F.)

	dbSelectArea(_cAliasCM)
	(_cAliasCM)->(dbGotop())

	If (_cAliasCM)->CUSTO_UNIT <= 0
		// obter o custo nas demais filiais
		_cQuery := "SELECT * "
		_cQuery += "FROM "
		_cQuery += "	(SELECT  DECODE(D1_QUANT,0,D1_CUSTO,D1_CUSTO/D1_QUANT) CUSTO_UNIT "
		_cQuery += "	FROM "+RetSqlName("SD1")+" D1 "
		_cQuery += "	INNER JOIN "+RetSqlName("SF4")+" F4 "
		_cQuery += "	ON F4.D_E_L_E_T_ = ' ' "
		_cQuery += "	AND D1.D1_FILIAL = F4.F4_FILIAL "
		_cQuery += "	AND D1.D1_TES = F4.F4_CODIGO "
		_cQuery += "	WHERE D1.D_E_L_E_T_ = ' ' "
		_cQuery += "	AND F4.F4_ESTOQUE = 'S' "
		_cQuery += "	AND F4.F4_DUPLIC = 'S' "
		_cQuery += "	AND D1.D1_TIPO <> 'C' "
		_cQuery += "    AND D1.D1_COD = '"+_cCod+"' "
		_cQuery += "	ORDER BY D1_FILIAL, D1_DTDIGIT DESC , D1.R_E_C_N_O_ DESC) "
		_cQuery += "WHERE ROWNUM <= 1 "
		
		If Select(_cAliasCM) > 0
			(_cAliasCM)->(dbCloseArea())
		EndIf
	
		dbUseArea( .T., "TOPCONN",TcGenQry(,,_cQuery),_cAliasCM,.T.,.F.)
	
	EndIf

	_nCusto := (_cAliasCM)->CUSTO_UNIT

	dbSelectArea(_cAliasCM)
	(_cAliasCM)->(dbCloseArea())


//Se o produto é PA pega o ultimo D2_CUSTO da filial
Elseif _ctipo == "PA

// obter o custo na maior data e ultimo registro na filial corrente
	_cQuery := "SELECT * "
	_cQuery += "FROM "
	_cQuery += "	(SELECT DECODE(D2_QUANT,0,D2_CUSTO1,D2_CUSTO1/D2_QUANT) CUSTO_UNIT "
	_cQuery += "	FROM "+RetSqlName("SD2")+" D2 "
	_cQuery += "	INNER JOIN "+RetSqlName("SF4")+" F4 "
	_cQuery += "	ON F4.D_E_L_E_T_ = ' ' "
	_cQuery += "	AND D2.D2_FILIAL = F4.F4_FILIAL "
	_cQuery += "	AND D2.D2_TES = F4.F4_CODIGO "
	_cQuery += "	WHERE D2.D_E_L_E_T_ = ' ' "
	_cQuery += "    AND D2.D2_FILIAL = '"+XFilial("SD2")+"' "
	_cQuery += "    AND F4.F4_FILIAL = '"+XFilial("SF4")+"' "
	_cQuery += "	AND F4.F4_ESTOQUE = 'S' "
	_cQuery += "	AND F4.F4_DUPLIC = 'S' "
	_cQuery += "	AND D2.D2_TIPO = 'N' "
	_cQuery += "    AND D2.D2_COD = '"+_cCod+"' "
	_cQuery += "	ORDER BY D2_FILIAL, D2_EMISSAO DESC , D2.R_E_C_N_O_ DESC) "
	_cQuery += "WHERE ROWNUM <= 1 "
	

	If Select(_cAliasCM) > 0
		(_cAliasCM)->(dbCloseArea())
	EndIf

	dbUseArea( .T., "TOPCONN",TcGenQry(,,_cQuery),_cAliasCM,.T.,.F.)

	dbSelectArea(_cAliasCM)
	(_cAliasCM)->(dbGotop())

	If (_cAliasCM)->CUSTO_UNIT <= 0
		// obter o custo nas demais filiais
		_cQuery := "SELECT * "
		_cQuery += "FROM "
		_cQuery += "	(SELECT  DECODE(D2_QUANT,0,D2_CUSTO1,D2_CUSTO1/D2_QUANT) CUSTO_UNIT "
		_cQuery += "	FROM "+RetSqlName("SD2")+" D2 "
		_cQuery += "	INNER JOIN "+RetSqlName("SF4")+" F4 "
		_cQuery += "	ON F4.D_E_L_E_T_ = ' ' "
		_cQuery += "	AND D2.D2_FILIAL = F4.F4_FILIAL "
		_cQuery += "	AND D2.D2_TES = F4.F4_CODIGO "
		_cQuery += "	WHERE D2.D_E_L_E_T_ = ' ' "
		_cQuery += "	AND F4.F4_ESTOQUE = 'S' "
		_cQuery += "	AND F4.F4_DUPLIC = 'S' "
		_cQuery += "	AND D2.D2_TIPO = 'n' "
		_cQuery += "    AND D2.D2_COD = '"+_cCod+"' "
		_cQuery += "	ORDER BY D2_FILIAL, D2_EMISSAO DESC , D2.R_E_C_N_O_ DESC) "
		_cQuery += "WHERE ROWNUM <= 1 "
		
		If Select(_cAliasCM) > 0
			(_cAliasCM)->(dbCloseArea())
		EndIf
	
		dbUseArea( .T., "TOPCONN",TcGenQry(,,_cQuery),_cAliasCM,.T.,.F.)
	
	EndIf

	_nCusto := (_cAliasCM)->CUSTO_UNIT

	dbSelectArea(_cAliasCM)
	(_cAliasCM)->(dbCloseArea())

Endif


Return (_nCusto)

/*
===============================================================================================================================
Programa----------: MEST002S
Autor-------------: Guilherme Diogo
Data da Criacao---: 23/10/2012
===============================================================================================================================
Descrição---------: Salva log de eventos
===============================================================================================================================
Uso---------------: Italac
===============================================================================================================================
Parametros--------: _aLog - matriz com eventos do processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
Usuario-----------: 
===============================================================================================================================
Setor-------------: TI
===============================================================================================================================
*/
Static Function MEST002S(_aLog)

Local _cArq := ""
Local _nHdl := 0
Local _nPos := 0
Local _nI   := 0

Aviso("Salvar Log em TXT", "Este programa ira gerar um arquivo texto com o Log do processamento executado", {"Ok"}, 1, "Geração de Arquivo Texto")

_cArq := cGetFile("Documento Texto |*.TXT",OemToAnsi("Salvar Arquivo Como..."),0,"C:\",.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE)

If Empty(_cArq)
	Return nil
EndIf

_nPos := At(".TXT",UPPER(_cArq))

If _nPos == 0
	_cArq := Alltrim(_cArq) + ".TXT"
EndIf

_nHdl := fCreate(_cArq)

If _nHdl == -1
	MsgAlert("O arquivo de nome "+_cArq+" nao pode ser executado! Verifique os parametros.","Atencao!")
	Return
Endif

ProcRegua(Len(_aLog))

For _nI := 1 To Len(_aLog)
	
	FWrite(_nHdl, _aLog[_nI] + chr(13) + chr(10))
	
	If FError() # 0
		MsgAlert ("ERRO GRAVANDO ARQUIVO, ERRO: " + str(FError()))
		Exit
	EndIf
	
	IncProc()
	
Next _nI

FClose(_nHdl)

MsgInfo("Arquivo TXT gerado com sucesso!")

Return Nil
