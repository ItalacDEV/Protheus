/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |23/07/2024| Chamado 47968. Altera��o da ordem da coluna Data
Lucas Borges  |09/10/2024| Chamado 48465. Retirada manipula��o do SX1
Lucas Borges  |27/06/2025| Chamado 50617. Revis�es diversas visando padronizar os fontes
===============================================================================================================================
*/

#Include 'Protheus.ch'
#Include 'Report.ch'

/*
===============================================================================================================================
Programa----------: RPON001
Autor-------------: Heder Andrade 
Data da Criacao---: 08/11/2011                                    .
Descri��o---------: Relatorio para apresentacao de eventos abonados do ponto.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RPON001

Private oReport := Nil As Object
Private oZAK	:= Nil As Object
Private oSPH 	:= Nil As Object
Private cPerg   := PadR( "RPON001",10," ") As Character
Private QRYSPH	:= Nil As Character
Private aOrdem  := {"Setor","Nome"} As Array 

//PARAMETROS DO PERGUNTE: 
//MV_PAR01 = Data de?
//MV_PAR02 = Data Ate?
//MV_PAR03 = Motivo Abono?
//MV_PAR04 = Setor?
//MV_PAR05 = Matricula de?
//MV_PAR06 = Matricula ate?
//MV_PAR07 = Periodo?
//MV_PAR08 = Situacoes?
//MV_PAR09 = Filiais?
Do While .T.
	If !Pergunte(cPerg,.T.)
		Return .F.
	EndIf

	If Empty(MV_PAR01) .Or. Empty(MV_PAR02)
		FWAlertInfo("Voc� n�o forneceu uma data de movimenta��o inicial e final v�lida. Favor verificar a data inicial e final fornecida para "+;
				"filtro da movimenta��o, para correta impress�o de dados do relat�rio. A Data fornecida tem que obrigat�riamente ser de um per�odo da folha j� encerrado.","RPON00101")
		Loop
	EndIf

	If Findfunction('U_ITVALFIL') .And. !U_ITVALFIL(@MV_PAR09)//Valida se as filiais s�o v�lidas e se o usuario tem acesso no ITALACXFUN
		Loop
	ElseIf Empty(MV_PAR09)
		FWAlertInfo("Campo filial em branco. Digite uma ou mais filiais validas selecione pelo F3.","RPON00102")
		Loop
	EndIf

	Exit
EndDo

DEFINE REPORT oReport NAME "RPON001" TITLE "Rela��o Abonos" PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)}

//Nao imprimir pagina de parametros
//oReport:HideParamPage()

//Define que ser� impressa a p�gina de par�metros do relat�rio.
oReport:ShowParamPage()

//Seta Padrao de impressao Paisagem.
//oReport:SetLandscape()

//Seta Padrao de impressao Retrato
oReport:SetPortrait()

//Define se os totalizadores ser�o impressos em linha ou coluna (para coluna informar parametro .F.)
oReport:SetTotalInLine(.F.)

//Desabilita a modificacao de orientacao do relatorio
oReport:DisableOrientation()

DEFINE SECTION oZAK OF oReport TITLE "SETORES" TABLES "QRYSPH" ORDERS aOrdem
	DEFINE CELL NAME "FILIAL"       OF oZAK ALIAS "QRYSPH" TITLE "Filial" 			    SIZE 04
	DEFINE CELL NAME "ZAK_COD" 		OF oZAK ALIAS "QRYSPH" TITLE "C�d." 			    SIZE 06 //COD DO SETOR
	DEFINE CELL NAME "DESC_SETOR"	OF oZAK ALIAS "QRYSPH" TITLE "Setor" 			    SIZE 30 //DESCRICAO DO SETOR

DEFINE SECTION oSPH OF oZAK TITLE "MOVIMENTACOES" TABLES "SPH", "SP6", "SRA"
	DEFINE CELL NAME "ZAK_COD" 	   OF oSPH ALIAS "QRYSPH" TITLE "C�d." 			        SIZE 06 //COD DO SETOR
	DEFINE CELL NAME "DESC_SETOR"  OF oSPH ALIAS "QRYSPH" TITLE "Setor" 			    SIZE 30 //DESCRICAO DO SETOR
	DEFINE CELL NAME "RA_MAT"	   OF oSPH ALIAS "SPH"    TITLE "Matr�cula"             SIZE 06
	DEFINE CELL NAME "FUNCIONARIO" OF oSPH ALIAS "SPH"    TITLE "Funcion�rio"           SIZE 50
	DEFINE CELL NAME "PH_PD" 	   OF oSPH ALIAS "SPH"    TITLE "Evento"			    SIZE 03
	DEFINE CELL NAME "PH_QUANTC"   OF oSPH ALIAS "SPH"    TITLE "Qtde Calculada"		SIZE 05 PICTURE "@E 99.99"
	DEFINE CELL NAME "PH_QUANTI"   OF oSPH ALIAS "SPH"    TITLE "Qtde Informada"		SIZE 05 PICTURE "@E 99.99"
	DEFINE CELL NAME "PH_ABONO"	   OF oSPH ALIAS "SPH"    TITLE "Mot. Abono" 			SIZE 03
	DEFINE CELL NAME "PH_DATA"	   OF oSPH ALIAS "SPH"    TITLE "Data" 			        SIZE 10
	DEFINE CELL NAME "P6_DESC"     OF oSPH ALIAS "SPH"    TITLE "Desc. Abono" 			SIZE 20
	DEFINE CELL NAME "PH_QTABONO"  OF oSPH ALIAS "SPH"    TITLE "Qtde Abonada"			SIZE 05 PICTURE "@E 99.99"
	
//Salta numero de linhas para a proxima secao
oZAK:SetLinesBefore(5)      	

//Alinhamento de cabecalho
oSPH:Cell("PH_QUANTC") :SetHeaderAlign("RIGHT")
oSPH:Cell("PH_QUANTI") :SetHeaderAlign("RIGHT")
oSPH:Cell("PH_QTABONO"):SetHeaderAlign("RIGHT")

//Define se os totalizadores ser�o impressos em linha ou coluna (passar .F.).
oSPH:SetTotalInLine(.F.)

//Define o texto que ser� impresso antes da impress�o dos totalizadores.
oSPH:SetTotalText("Total Movimentacao")

DEFINE FUNCTION FROM oSPH:Cell("PH_DATA") 	 FUNCTION COUNT	PICTURE "@E 999,999"
DEFINE FUNCTION FROM oSPH:Cell("PH_QTABONO") FUNCTION SUM	PICTURE "@E 999,9999.99"

//Exibe a tela de configura��o para a impress�o do relat�rio.
oReport:PrintDialog()

Return

/*
===============================================================================================================================
Programa----------: PrintReport
Autor-------------: Heder Andrade 
Data da Criacao---: 08/11/2011                                    .
Descri��o---------: Printa o relatorio
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function PrintReport(oReport As Object)

Private _cFiltro   	:= "%" As Character
Private _cFiltroSR8	:= "%" As Character
Private nOrdem  	:= oZAK:GetOrder() As Numeric//Retorna a ordem de impress�o selecionada.

U_ITLOGACS() // Grava log de utiliza��o

//Define o t�tulo do relat�rio.
oReport:SetTitle(oReport:Title() + " " + aOrdem[nOrdem] + " - Mov. de " + DtoC(mv_par01) + " at� "  + DtoC(mv_par02))

If nOrdem = 1 //ORDENA POR SETOR
   oSPH:Cell("ZAK_COD"):Disable()
   oSPH:Cell("DESC_SETOR"):Disable()
ElseIf nOrdem = 2 
   oZAK:Cell("ZAK_COD"):Disable()
   oZAK:Cell("DESC_SETOR"):Disable()
EndIf

//Define o filtro de acordo com os parametros informados
If MV_PAR07 = 2
	_cFiltro += " AND PH.PH_FILIAL IN " + FormatIn(AllTrim(MV_PAR09),";") + " "

	//verIfica se vai filtrar data de movimentacoes
	If !Empty(MV_PAR01) .And. !Empty(MV_PAR02)
		_cFiltro += " AND PH.PH_DATA BETWEEN '" + DToS(mv_par01) + "' AND '" + DToS(mv_par02) + "' "	
	EndIf

	//verIfica se vai filtrar motivo de abono
	If !Empty(MV_PAR03)
	   _cFiltro += " AND PH.PH_ABONO = '" + MV_PAR03 + "' "
	ELSE
	   _cFiltro += " AND PH.PH_PD IN ('017','413') "//TRAZ AS FALTAS COM OU SEM ABONO, solicitado pela Regina, chamado 47228
	EndIf

	//FILTRA FUNCIONARIOS
	If !Empty(MV_PAR05) .And. !Empty(MV_PAR06)
		_cFiltro += " AND PH.PH_MAT BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
	EndIf
Else
	_cFiltro += " AND PH.PC_FILIAL IN " + FormatIn(AllTrim(MV_PAR09),";") + " "

	//VERIFICA SE VAI FILTRAR DATA DE MOVIMENTACOES
	If !Empty(MV_PAR01) .And. !Empty(MV_PAR02)
		_cFiltro += " AND PH.PC_DATA BETWEEN '" + DtoS(mv_par01) + "' AND '" + DtoS(mv_par02) + "' "	
	EndIf

	//VERIFICA SE VAI FILTRAR MOTIVO DE ABONO
	If !Empty(MV_PAR03)
	   _cFiltro += " AND PH.PC_ABONO = '" + MV_PAR03 + "' "
	ELSE
	   _cFiltro += " AND PH.PC_PD IN ('017','413') "//TRAZ AS FALTAS COM OU SEM ABONO, solicitado pela Regina, chamado 47228
	EndIf

	//FILTRA FUNCIONARIOS
	If !Empty(MV_PAR05) .And. !Empty(MV_PAR06)
		_cFiltro += " AND PH.PC_MAT BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
	EndIf
EndIf

_cFiltroSR8 += " AND SR8.R8_FILIAL IN " + FormatIn(AllTrim(MV_PAR09),";") + " "

//FILTRA SETOR
If !Empty(MV_PAR04)
	_cFiltro  += " AND ZAK.ZAK_COD IN " + FormatIn(AllTrim(MV_PAR04),";") + " "
	_cFiltroSR8 += " AND ZAK.ZAK_COD IN " + FormatIn(AllTrim(MV_PAR04),";") + " "
EndIf

//FILTRA SITUACAO DA FOLHA
If !Empty(Alltrim(MV_PAR08)) .And. Alltrim(MV_PAR08) <> "*****"
	_cFiltro  += " AND SRA.RA_SITFOLH IN (" + FSQLIN(STRTRAN(MV_PAR08,"*",""),1) + ") "
	_cFiltroSR8 += " AND SRA.RA_SITFOLH IN (" + FSQLIN(STRTRAN(MV_PAR08,"*",""),1) + ") "
EndIf

If !Empty(MV_PAR01) .And. !Empty(MV_PAR02)
	_cFiltroSR8 += " AND (SR8.R8_DATAINI BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' OR "
	_cFiltroSR8 += "      SR8.R8_DATAFIM BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' ) "	
EndIf

//VERIFICA SE VAI FILTRAR O TIPO DO AFASTAMENTO
If !Empty(MV_PAR03)
   _cFiltroSR8 += " AND SR8.R8_TIPOAFA = '" + MV_PAR03 + "' "
EndIf

_cFiltro += "%"
_cFiltroSR8+= "%"

IF nOrdem = 1     // ORDENA POR QUEBRA DO SETOR + DATA + MATRICULA
   _cOrdem:="% FILIAL, DESC_SETOR , PH_DATA, RA_MAT  %"
ELSEIF nOrdem = 2 // ORDENA POR NOME DO FUNCIONARIO + MATRICULA + DATA
   _cOrdem:="% FILIAL, FUNCIONARIO, RA_MAT , PH_DATA %"
EndIf

BEGIN REPORT QUERY oReport:Section(1)

If MV_PAR07 = 2 //LE O SPH  - FECHADO
	BeginSql alias "QRYSPH"
		SELECT PH.PH_FILIAL FILIAL , ZAK.ZAK_COD, TRIM(ZAK.ZAK_DESCRI) DESC_SETOR, PH.PH_DATA, SRA.RA_MAT, TRIM(SRA.RA_NOMECMP) FUNCIONARIO,
				PH.PH_PD AS PH_PD, PH.PH_QUANTC, PH.PH_QUANTI, PH.PH_ABONO, SP6.P6_DESC, PH.PH_QTABONO
		FROM %Table:SPH% PH
		     JOIN %Table:SRA% SRA ON SRA.D_E_L_E_T_ = ' ' AND SRA.RA_FILIAL = PH.PH_FILIAL  AND SRA.RA_MAT    = PH.PH_MAT
		     JOIN %Table:ZAK% ZAK ON ZAK.D_E_L_E_T_ = ' ' AND ZAK.ZAK_COD   = SRA.RA_I_SETOR //FILIAL COMPARTILHADO
		LEFT JOIN %Table:SP6% SP6 ON SP6.D_E_L_E_T_ = ' ' AND SP6.P6_FILIAL = PH.PH_FILIAL  AND SP6.P6_CODIGO = PH.PH_ABONO
		WHERE  PH.D_E_L_E_T_ = ' ' %exp:_cFiltro%
    UNION	  
        SELECT SR8.R8_FILIAL FILIAL , ZAK.ZAK_COD, TRIM(ZAK.ZAK_DESCRI) DESC_SETOR, SR8.R8_DATAINI AS PH_DATA, SRA.RA_MAT , TRIM(SRA.RA_NOMECMP) FUNCIONARIO,  
               SR8.R8_TIPOAFA AS PH_PD, SR8.R8_DURACAO AS PH_QUANTC, 0 AS PH_QUANTI, SR8.R8_TIPOAFA AS PH_ABONO, 
			   'Afastamento Dt.final: '||SUBSTR(R8_DATAFIM, 7, 2) || '/' || SUBSTR(R8_DATAFIM, 5, 2) || '/' || SUBSTR(R8_DATAFIM, 1, 4) AS P6_DESC, 0 AS PH_QTABONO 
        FROM  %Table:SR8% SR8
        JOIN  %Table:SRA% SRA ON SRA.D_E_L_E_T_ = ' ' AND SRA.RA_FILIAL = SR8.R8_FILIAL AND SRA.RA_MAT = SR8.R8_MAT  
        JOIN  %Table:ZAK% ZAK ON ZAK.D_E_L_E_T_ = ' ' AND ZAK.ZAK_COD   = SRA.RA_I_SETOR //FILIAL COMPARTILHADO
        WHERE SR8.D_E_L_E_T_ = ' ' %exp:_cFiltroSR8%    AND (SR8.R8_TIPO <> 'F' AND SR8.R8_TIPOAFA <> '001')
		ORDER BY %Exp:_cOrdem%
	EndSql
Else            //LE O SPC - ABERTO
	BeginSql alias "QRYSPH"
		SELECT PH.PC_FILIAL FILIAL , ZAK.ZAK_COD, TRIM(ZAK.ZAK_DESCRI) DESC_SETOR, PH.PC_DATA AS PH_DATA, SRA.RA_MAT, TRIM(SRA.RA_NOMECMP) FUNCIONARIO,
				PH.PC_PD AS PH_PD, PH.PC_QUANTC AS PH_QUANTC, PH.PC_QUANTI AS PH_QUANTI, PH.PC_ABONO AS PH_ABONO, SP6.P6_DESC, PH.PC_QTABONO AS PH_QTABONO
		FROM %Table:SPC% PH
		     JOIN %Table:SRA% SRA ON SRA.D_E_L_E_T_ = ' ' AND SRA.RA_FILIAL = PH.PC_FILIAL AND SRA.RA_MAT    = PH.PC_MAT
		     JOIN %Table:ZAK% ZAK ON ZAK.D_E_L_E_T_ = ' ' AND ZAK.ZAK_COD   = SRA.RA_I_SETOR
		LEFT JOIN %Table:SP6% SP6 ON SP6.D_E_L_E_T_ = ' ' AND SP6.P6_FILIAL = PH.PC_FILIAL AND SP6.P6_CODIGO = PH.PC_ABONO
		WHERE PH.D_E_L_E_T_ = ' ' %exp:_cFiltro%			
    UNION	  
        SELECT SR8.R8_FILIAL FILIAL, ZAK.ZAK_COD, TRIM(ZAK.ZAK_DESCRI) DESC_SETOR, SR8.R8_DATAINI AS PH_DATA, SRA.RA_MAT , TRIM(SRA.RA_NOMECMP) FUNCIONARIO,  
               SR8.R8_TIPOAFA AS PH_PD, SR8.R8_DURACAO AS PH_QUANTC, 0 AS PH_QUANTI, SR8.R8_TIPOAFA AS PH_ABONO, 
			   'Afastamento Dt.final: '||SUBSTR(R8_DATAFIM, 7, 2) || '/' || SUBSTR(R8_DATAFIM, 5, 2) || '/' || SUBSTR(R8_DATAFIM, 1, 4) AS P6_DESC, 0 AS PH_QTABONO 
        FROM  %Table:SR8% SR8
        JOIN  %Table:SRA% SRA ON SRA.D_E_L_E_T_ = ' ' AND SRA.RA_FILIAL = SR8.R8_FILIAL AND SRA.RA_MAT = SR8.R8_MAT  
        JOIN  %Table:ZAK% ZAK ON ZAK.D_E_L_E_T_ = ' ' AND ZAK.ZAK_COD   = SRA.RA_I_SETOR //FILIAL COMPARTILHADO
        WHERE SR8.D_E_L_E_T_ = ' ' %exp:_cFiltroSR8%    AND (SR8.R8_TIPO <> 'F' AND SR8.R8_TIPOAFA <> '001')
		ORDER BY %Exp:_cOrdem%
	EndSql
EndIf

END REPORT QUERY oReport:Section(1)

//Define que a se��o filha utiliza a query da se��o pai na impress�o da se��o.
oReport:Section(1):Section(1):SetParentQuery()

If nOrdem = 1 .OR. (oReport:nDevice = 4 .AND. oReport:nExcelPrintType >= 3)//EXCEL //ORDENA POR SETOR
   //SetParentFilter - Define a regra de sa�da do loop de impress�o das se��es filhas ou seja qdo ser�o efetuadas as quebras de secoes.
   //bFilter Bloco de c�digo com a regra para sa�da do loop
   //bParam Bloco de c�digo com a express�o que retorna o valor que � enviado como par�metro para a regra de sa�da do loop
   oReport:Section(1):Section(1):SetParentFilter({|cParam| QRYSPH->FILIAL+QRYSPH->ZAK_COD == cParam },{|| QRYSPH->FILIAL+QRYSPH->ZAK_COD })
Else//PRO NOME
   oReport:Section(1):Section(1):SetParentFilter({|cParam| QRYSPH->FILIAL == cParam },{|| QRYSPH->FILIAL })
EndIf

//faz o controle de inicializa��o e finaliza��o da impress�o.
oReport:Section(1):Print(.T.)

Return
