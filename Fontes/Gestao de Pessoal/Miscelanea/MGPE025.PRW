/*  
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |   Data     |                              Motivo                       										 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 12/05/2023 | Chamado 41896. Alteracao da P8_DATA para o P8_DATAAPO em alguns lugares
Alex Wallauer | 30/11/2023 | Chamado 45701. NÃO considerar a marcação na SP8 esteja como deletada manualmente (P8_TMPCREP = D)
Alex Wallauer | 11/12/2023 | Chamado 45801. correção do nome do campo para P8_TPMCREP.
============================================================================================================================================================
Analista         - Programador     - Inicio     - Envio    - Chamado - Motivo da Alteração
------------------------------------------------------------------------------------------------------------------------------------------------------------
Andre Carvalho   - Igor Melgaço    - 10/06/25   - 20/06/25 - 50981   - Ajustes para processamento de registros já inclusos na SP5
Andre Carvalho   - Igor Melgaço    - 23/06/25   - 24/06/25 - 50981   - Ajustes para validação do período selecionado de acordo com o MV_PONMES
============================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE "rwmake.ch"

/*
===============================================================================================================================
Programa--------: MGPE025 // U_MGPE025
Autor-----------: Igor Melgaço
Data da Criacao-: 07/03/2023   
===============================================================================================================================
Descrição-------: Rotina de apontamento automático para o vale refeição contabilizar pelo registro de jornada. CHAMADO 41896 
===============================================================================================================================
Parametros------: NENHUM
===============================================================================================================================
Retorno---------: NENHUM
===============================================================================================================================
*/
User Function MGPE025()
Local _aParAux  := {} As Array
Local nI := 0 As Numeric
Local _aParRet  := {} As Array
Local _cPeriodo := SuperGetMV('MV_PONMES',.F.,'') As Character
Local _bOk := {|| U_MGPE025VP(_cPeriodo) } As Block

MV_PAR01 := dDataBase
MV_PAR02 := dDataBase

AADD( _aParAux , { 1 , "Data de"	      , MV_PAR01, "@D"	, ""	, ""		, "" , 050 , .F. } )
AADD( _aParAux , { 1 , "Data ate"         , MV_PAR02, "@D"	, ""	, ""		, "" , 050 , .F. } )

For nI := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nI][03] )
Next 

DO WHILE ParamBox( _aParAux , "SELECIONE OS FILTROS" , _aParRet , _bOk , , , , , , , .T. , .T. )
	FWMSGRUN(,{|oProc|  MGPE025PROC(oProc) },'Aguarde o processamento...','Lendo dados...')
ENDDO

Return

/*
===============================================================================================================================
Programa--------: MGPE025PROC 
Autor-----------: Igor Melgaço
Data da Criacao-: 11/08/2022   
===============================================================================================================================
Descrição-------: Rotina de Processamento da Listagem. 
===============================================================================================================================
Parametros------: oProc = Objeto da regua de processamento
===============================================================================================================================
Retorno---------: NENHUM
===============================================================================================================================
*/
STATIC Function MGPE025PROC(oProc As Object)
Local _aDados := {} As Array
Local _aCab := {} As Array
Local i := 0 As Numeric
Local z := 0 As Numeric
Local _nAtual := 0 As Numeric
Local _nTotal   := 0 As Numeric
Local _lExistente := .F. As Logical
Local _lNovo := .F. As Logical
Local aBotoes := {} As Array
Local cSubTitulo := "" As Character
Local cMensagem := "" As Character
Local _nRet := 0 As Numeric
Local lContinua := .F. As Logical
Local _aColXML := {} As Array
Local _aLinha := {} As Array
Local lExcluir := .F. As Logical

_aDados := MGPE025QRY(oProc)

If Len(_aDados) = 0 
    U_ITMSG("Não há dados no periodo.","Envio do E-MAIL",,3)
Else
	_cTitulo := "Apontamento automático para o vale refeição contabilizar pelo registro de jornada."
	
	AADD(_aCab," ")
	AADD(_aCab,"Filial")
	AADD(_aCab,"Matricula")
	AADD(_aCab,"Nome")
	AADD(_aCab,"Data")
	AADD(_aCab,"Centro de Custo")
	AADD(_aCab,"Valor Ref")
	AADD(_aCab,"Desc")

	_nTotal := Len(_aDados)
	For i := 1 to _nTotal
		_aLinha := {}
		For z := 1 to Len(_aCab)
			AADD(_aLinha, _aDados[i,z]) 
		Next
		AADD(_aColXML, _aLinha)
		If !_aDados[i,1]
			_lExistente := .T.
		Else 
			_lNovo := .T.
		EndIf
	Next

	_aButtons := {}
    AADD(_aButtons,{"LEGENDA",{||  U_MGPE025L() },"Legenda", "Legenda" }) 

	//					  //  , _aCols   ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca )
	//If U_ITListBox(_cTitulo,_aCab,_aDados   , .T.    , 1    ,        ,          ,        ,         ,     ,        ,          ,       ,         ,          ,            )
	_cMsgTop := ""
	   //ITListBox( _cTitAux , _aHeader , _aCols     , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca,_bLegenda   ,_lHasOk,_bHeadClk,_aSX1)
    If U_ITListBox( _cTitulo , _aCab     , _aColXML   , .T.      , 4      , _cMsgTop ,          ,         ,         ,     ,        , _aButtons,       ,         ,          ,           ,            , .T.   ,         ,     )
 
		If _lExistente .and. _lNovo
			aBotoes    := {"Substituir os Existentes e Incluir os Novos","Somente Incluir os Novos","Cancelar"}
			cSubTitulo := "Já existem registros de almoço existentes para este período selecionado!"
			cMensagem  := "O que desja fazer com este conjunto de registros?"
		    //Aviso( <cTitulo>                       , <cMensagem>, aBotoes>, <nTamTela>, <cSubTitulo>, <nRotAut>, <cBitMap>   , <lEditMemo>, <nTimer> )
		    _nRet := Aviso( "", cMensagem  , aBotoes , 3         ,  cSubTitulo ,          , "ENGRENAGEM",    .F.     ,          )
			If _nRet = 3
				lContinua := .F.
				lExcluir := .F.
			Else
				If _nRet = 1
					lExcluir := .T.
				Else
					lExcluir := .F.
				EndIf
				lContinua := .T.
			EndIf
		ElseIf _lExistente .and. !_lNovo
			aBotoes    := {"Substituir os Existentes","Cancelar"}
			cSubTitulo := "Para todo este conjunto de registros já existem registros de almoço existentes para este período selecionado!"
			cMensagem  := "O que desja fazer com este conjunto de registros?"
		    //Aviso( <cTitulo>                       , <cMensagem>, aBotoes>, <nTamTela>, <cSubTitulo>, <nRotAut>, <cBitMap>   , <lEditMemo>, <nTimer> )
		    _nRet := Aviso( "", cMensagem  , aBotoes , 3         ,  cSubTitulo ,          , "ENGRENAGEM",    .F.     ,          )
			If _nRet = 2
				lExcluir := .F.
				lContinua := .F.
			Else
				lExcluir := .T.
				lContinua := .T.
			EndIf
		ElseIf !_lExistente .and. _lNovo
			lContinua := .T.
			lExcluir := .F.
		EndIf
		
		If lContinua
			Begin Transaction
				For i := 1 to _nTotal
					If !Empty(Alltrim(_aDados[i,9]))	
						If lExcluir
							DBSelectArea("SP5")
							SP5->(DBGoTo(_aDados[i,10]))
							RECLOCK( "SP5", .F. )
							SP5->(DbDelete())
							SP5->(MSUNLOCK())
							_lContinua := .T.
						Else
							_lContinua := .F.
						EndIf
					Else
						_lContinua := .T.
					EndIf

					If _lContinua
						DBSelectArea("SP5")
						RECLOCK( "SP5", .T. )
						SP5->P5_FILIAL 	:= _aDados[i,2]
						SP5->P5_MAT 	:= _aDados[i,3]
						SP5->P5_DATA 	:= CTOD(_aDados[i,5])
						SP5->P5_HORA 	:= 12
						SP5->P5_CODREF 	:= "01"
						SP5->P5_TIPOREF := "02" // Almoço
						SP5->P5_SEQ		:= "03" //fDesc("SP1","02","P1_SEQ",TamSx3("P1_SEQ")[1],NIL,2)
						SP5->P5_SEQMARC := "01"
						SP5->P5_GERAFOL := "S"
						SP5->P5_PD 		:= "035"
						SP5->P5_PDEMPR 	:= "015"
						SP5->P5_VALREF 	:= _aDados[i,7] //Posicione("SPM",1,fFilFunc("SPM")+"02","PM_VALREF") //15.91 //
						SP5->P5_DESCFUN := _aDados[i,8] //Round(SP5->P5_VALREF * ( Posicione("SPM",1,fFilFunc("SPM")+"02","PM_PERCFUN") / 100),2) //3.18 //
						SP5->P5_CC 		:= _aDados[i,6] //CENTRO DE CUSTO
						SP5->P5_RELOGIO := "090"
						SP5->P5_FLAG 	:= "I"
						SP5->P5_APONTA 	:= "N"
						SP5->P5_DATAAPO := Date()
						SP5->(MSUNLOCK())
					EndIf

					_nAtual++
					oProc:cCaption := ("Gravando registro "+Alltrim(cValToChar(_nAtual)) + " de " + Alltrim(cValToChar(_nTotal)) + " ...")
					ProcessMessages()
				Next
			End Transaction

			If _nAtual > 0
				U_ITMSG("Processamento concluido. Foram processados "+Alltrim(Str(_nAtual))+" registros!","Apontamento automático para o vale refeição","",2)
			EndIf
		EndIf
	EndIf
EndIf

Return 


/*
===============================================================================================================================
Programa--------: MGPE025QRY 
Autor-----------: Igor Melgaço
Data da Criacao-: 06/03/2023
===============================================================================================================================
Descrição-------: Processamento da Query 
===============================================================================================================================
Parametros------: oProc = Objeto da regua de processamento
===============================================================================================================================
Retorno---------: _aDados = Dados de retorno do processamento da query
===============================================================================================================================
*/
STATIC Function MGPE025QRY(oProc As Object) As Array
Local _cAliasQRY := '' As Character
Local _cFiltro := '' As Character
Local _aDados := {} As Array
Local _nAtual := 0 As Numeric
Local nTotal   := 0 As Numeric
Local nValref := 0 As Numeric
Local nPerFun := 0 As Numeric
Local _lReproc := .F. As Logical

_cAliasQRY := GetNextAlias()

_cFiltro += "% "
_cFiltro += " SRA.D_E_L_E_T_  = ' ' "
_cFiltro += " AND P8_FILIAL  = '" + xFilial("SP8") + "' "
_cFiltro += " AND QRY1.P8_DATAAPO BETWEEN '" + DTOS(MV_PAR01) + "' AND '"+ DTOS(MV_PAR02) + "'"
_cFiltro += " %"

BeginSql Alias _cAliasQRY

	SELECT P8_FILIAL, P8_MAT,  P5_DATA, RA_NOME, RA_DEPTO, RA_CC , P8_DATAAPO, P5_MAT, SP5.R_E_C_N_O_
	FROM ( SELECT P8_FILIAL,P8_MAT, P8_DATAAPO
			FROM %Table:SP8% SP8
			WHERE SP8.D_E_L_E_T_ = ' ' AND SP8.P8_TPMCREP <> 'D'
			GROUP BY P8_FILIAL, P8_MAT, P8_DATAAPO ) QRY1 
	LEFT JOIN ( SELECT SP5.P5_FILIAL,SP5.P5_MAT, SP5.P5_DATA, SP5.R_E_C_N_O_ 
							FROM %Table:SP5% SP5
								JOIN %Table:SP1% SP1 ON SP1.P1_FILIAL = SP5.P5_FILIAL AND SP1.P1_CODREF = SP5.P5_CODREF AND SP1.P1_TIPOREF = SP5.P5_TIPOREF AND SP1.P1_SEQ = SP5.P5_SEQ AND SP1.D_E_L_E_T_ = ' '
								JOIN %Table:SPM% SPM ON SPM.PM_FILIAL = SP1.P1_FILIAL AND SPM.PM_TIPOREF = SP1.P1_TIPOREF AND SPM.D_E_L_E_T_ = ' '
							WHERE SP5.D_E_L_E_T_ = ' '
								AND SPM.PM_DESCREF = 'ALMOCO'
							GROUP BY SP5.P5_FILIAL, SP5.P5_MAT, SP5.P5_DATA, SP5.R_E_C_N_O_  ) SP5 ON QRY1.P8_FILIAL = SP5.P5_FILIAL AND QRY1.P8_MAT = SP5.P5_MAT AND QRY1.P8_DATAAPO = SP5.P5_DATA
	LEFT JOIN %Table:SRA% SRA ON SRA.RA_FILIAL = QRY1.P8_FILIAL AND SRA.RA_MAT = QRY1.P8_MAT AND SRA.D_E_L_E_T_ = ' '
	WHERE SRA.RA_I_REFEI = '1'
		AND %Exp:_cFiltro%
	ORDER BY P8_FILIAL, P8_MAT, P8_DATAAPO

EndSql

DbSelectArea(_cAliasQRY)
(_cAliasQRY)->(DBGoTop())
If !(_cAliasQRY)->(EOF())
	DbSelectArea(_cAliasQRY)
	COUNT to nTotal
	(_cAliasQRY)->(DBGoTop())
	Do While !(_cAliasQRY)->(EOF())
		_nAtual++

		oProc:cCaption := ("Lendo registro "+cValToChar(_nAtual) + " de " + cValToChar(nTotal) + "...")
		ProcessMessages()

		Dbselectarea("SPM")
		SPM->(DBSETORDER( 2 ))
		If SPM->(Dbseek(xFilial("SPM")+'ALMOCO'))
			nValref := SPM->PM_VALREF 
			nPerFun := SPM->PM_PERCFUN
		Else
			nValref := 0
			nPerFun := 0
		EndIf

		If !Empty( Alltrim((_cAliasQRY)->P5_MAT) )
			_lReproc := .F.
		Else
			_lReproc := .T.
		EndIf

		AADD(_aDados,{  _lReproc,;
						(_cAliasQRY)->P8_FILIAL,;
						(_cAliasQRY)->P8_MAT,;
						(_cAliasQRY)->RA_NOME,;
						DTOC(StoD((_cAliasQRY)->P8_DATAAPO)),;
						(_cAliasQRY)->RA_CC,;
						nValref,;
						Round(nValref * (nPerFun / 100),2),;
						(_cAliasQRY)->P5_MAT,;
						(_cAliasQRY)->R_E_C_N_O_ })

		(_cAliasQRY)->(DBSkip())
	EndDo
	(_cAliasQRY)->( DBCloseArea() )
EndIf

RETURN _aDados



/*
===============================================================================================================================
Programa----------: MGPE025L
Autor-------------: Igor Melgaço
Data da Criacao---: 12/10/2023
===============================================================================================================================
Descrição---------: Monta Legenda
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/
User Function MGPE025L()

Local _aLegenda := {{ "BR_VERMELHO", "Registro já Existente"  },;
                 	{ "BR_VERDE",    "Registro Novo"} }

BRWLEGENDA( "Apontamento automático para o vale refeição", "Legenda", _aLegenda )

Return .T.

/*
===============================================================================================================================
Programa----------: MGPE025VP
Autor-------------: Igor Melgaço
Data da Criacao---: 12/10/2023
===============================================================================================================================
Descrição---------: Valida o periodo digitado pelo usuario
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: lRet
===============================================================================================================================
*/
User Function MGPE025VP(_cPeriodo As Character) As Logical
Local lRet := .T. As Logical
Local _dDataIni := CTOD("") As Date

_cPeriodo := StrTran(_cPeriodo,"/","")
_cPeriodo := StrTran(_cPeriodo,"-","")	
_cPeriodo := StrTran(_cPeriodo,".","")
_cPeriodo := StrTran(_cPeriodo,"|","")

_dDataIni := STOD(Subs(_cPeriodo,1,8)) //Parametro contem data de Incio e Fim, entao pega a data de fim

If Empty(MV_PAR01) .OR. Empty(MV_PAR02) 
	U_ITMSG("O periodo digitado não é válido.","Apontamento automático para o vale refeição","Os campos 'Data de' e 'Data ate' precisam ser preenchidos.",3)
	lRet := .F.
ElseIf !(MV_PAR01 >= _dDataIni .AND. MV_PAR02 >= _dDataIni)
	U_ITMSG("O periodo digitado não está dentro do intervalo de datas permitido.","Apontamento automático para o vale refeição","Digite um periodo superior a "+DTOC(_dDataIni)+".",3)
	lRet := .F.
EndIf
	
Return lRet
