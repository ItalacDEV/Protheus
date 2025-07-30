/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 09/09/2022 | Chamado 41230. Inclu�dos estados tratados pelo m�todo NfeConsultaCadastro
Lucas Borges  | 04/10/2022 | Chamado 41447. Corrigir caracter indevido inserido por esse teclado lixo
Lucas Borges  | 22/04/2025 | Chamado 50505. Alterada a picture do CNPJ para contemplar campo alfanum�rico
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: RGLT059
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 06/12/2018
Descri��o---------: Realiza consulta na SEFAZ sobre a situa��o cadastral do Produtor e lista Inativos
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGLT059()

Local oReport
//Inferface de Impress�o
oReport := ReportDef()
oReport:PrintDialog()

Return

/*
===============================================================================================================================
Programa----------: ReportDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 06/12/2018
Descri��o---------: Defini��o do Componente
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportDef()

Local oReport
Local oFornece

//Criacao do componente de impressao
//TReport():New
//ExpC1 : Nome do relatorio
//ExpC2 : Titulo
//ExpC3 : Pergunte
//ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao
//ExpC5 : Descricao

oReport := TReport():New("RGLT059","Situa��o Inscri��o Estadual SEFAZ","RGLT059",; 
{|oReport| ReportPrint(oReport)},"Verifica situa��o das Inscri��es Estaduais dos Fornecedores junto � SEFAZ")

Pergunte("RGLT059",.F.)
oReport:SetTotalInLine(.F.)

//=======================================================================
//Criacao da secao utilizada pelo relatorio
//TRSection():New
//ExpO1 : Objeto TReport que a secao pertence
//ExpC2 : Descricao da se�ao
//ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela
//			sera considerada como principal para a se��o.
//ExpA4 : Array com as Ordens do relat�rio
//ExpL5 : Carrega campos do SX3 como celulas
//			Default : False
//ExpL6 : Carrega ordens do Sindex
//			Default : False
//=======================================================================
//=======================================================================
//Criacao da celulas da secao do relatorio
//TRCell():New
//ExpO1 : Objeto TSection que a secao pertence
//ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado
//ExpC3 : Nome da tabela de referencia da celula
//ExpC4 : Titulo da celula
//			Default : X3Titulo()
//ExpC5 : Picture
//			Default : X3_PICTURE
//ExpC6 : Tamanho
//			Default : X3_TAMANHO
//ExpL7 : Informe se o tamanho esta em pixel
//			Default : False
//ExpB8 : Bloco de c�digo para impressao.
//			Default : ExpC2
//=======================================================================

//Secao 1 - Fornecedores
oFornece := TRSection():New(oReport,"Fornecedores",{"SA2"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oFornece:SetTotalInLine(.F.)
//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
TRCell():New(oFornece,"ZLD_SETOR","ZLD",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oFornece,"A2_COD","SA2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oFornece,"A2_LOJA","SA2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oFornece,"A2_NOME","SA2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oFornece,"A2_INSCR","SA2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oFornece,"A2_EST","SA2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oFornece,"SITUACAO",/*cAlias*/,"Situa��o"/*cTitle*/,/*Picture*/,09/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oFornece,"A2_CGC","SA2",/*cTitle*/,"@R XXXXXXXXXXXXXXXX"/*Picture*/,18/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

//Totalizador de fornecedores com inconsistencia
TRFunction():New(oFornece:Cell("A2_COD"),NIL,"COUNT",/*oBreak*/,/*cTitulo*/,/*cPicture*/,/*uFormula*/,.T.,.F.)

Return(oReport)

/*
===============================================================================================================================
Programa----------: ReportPrint
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 06/12/2018
Descri��o---------: A funcao estatica ReportDef devera ser criada para todos os relatorios que poderao ser agendados pelo usuario.
Parametros--------: ExpO1: Objeto Report do Relat�rio
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportPrint(oReport)

Local _cAlias 		:= ""
Local _cFiltro		:= "%"
Local _aSelFil		:= {}
Local _nCount 		:= 0
Local _lFirst 		:= .T.
Local _nCountRec	:= 0
Local _lSchedule	:= FWGetRunSchedule()
Local _cSituacao	:= "Erro"

//Chama fun��o que permitir� a sele��o das filiais
If MV_PAR07 == 1
	If Empty(_aSelFil)
		_aSelFil := AdmGetFil(.F.,.F.,"ZLD")
	Endif
Else
	Aadd(_aSelFil,cFilAnt)
EndIf

//==========================================================================
// Transforma parametros Range em expressao SQL                             	
//==========================================================================
MakeSqlExpr(oReport:uParam)

//==========================================================================
// Trata as c�lulas a serem exibidas de acordo com sess�o e par�metros
//==========================================================================
oReport:Section(1):Cell("SITUACAO"):SetBlock({||_cSituacao })

//====================================================================================================
// Monta filtro de acordo com a tabela de origem
//====================================================================================================
If MV_PAR08 = 1
	_cFiltro += " AND ZLD_STATUS = 'F'"
EndIf
//Normalmente n�o precisaria desse filtro pois o fonte trataria o agendamento independente da filial, por�m, se for informado apenas a empresa, ele ir� processar
//e disparar e-mail para todas as filiais que nem usam o leite. Se informar todas as filiais que usam o leite, ele processar� todos ao mesmo tempo, ocupando todas as threads.
//Diante disso, travei para que sempre sejam processadas todas as filiais ao mesmo tempo, bastando agendar uma filial qualquer.
If !_lSchedule
	_cFiltro+=" AND ZLD_FILIAL " +GetRngFil( _aSelFil, "ZLD", .T.,) +"%"
EndIf

//==========================================================================
// Query do relat�rio da secao 1                                            
//==========================================================================
oReport:Section(1):BeginQuery()	
_cAlias := GetNextAlias()

oReport:SetMsgPrint("Consultando registros no Banco de Dados")
oReport:SetMeter(0)

BeginSql Alias _cAlias
	SELECT A2_COD, A2_LOJA, A2_NOME, A2_EST, A2_INSCR, A2_CGC, ZLD_SETOR
	FROM %Table:ZLD% ZLD, %Table:SA2% SA2
	  WHERE SA2.D_E_L_E_T_ = ' '
		AND ZLD.D_E_L_E_T_ = ' '
		AND A2_COD = ZLD_RETIRO
		AND A2_LOJA = ZLD_RETILJ
		%Exp:_cFiltro%
		AND A2_COD BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR03%
		AND A2_LOJA BETWEEN %exp:MV_PAR02% AND %exp:MV_PAR04%
		AND A2_EST IN ('AC','BA','CE','GO','MT','MS','MG','PB','PR','PE','RN','RS','SC','SP')
		AND ZLD_DTCOLE BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR06% 
	GROUP BY A2_COD, A2_LOJA, A2_NOME, A2_EST, A2_INSCR, A2_CGC, ZLD_SETOR
	ORDER BY A2_COD, A2_LOJA
EndSql
//==========================================================================
// Metodo EndQuery ( Classe TRSection )                                     
//                                                                          
// Prepara o relat�rio para executar o Embedded SQL.                        
//                                                                          
// ExpA1 : Array com os parametros do tipo Range                            
//                                                                          
//==========================================================================
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

//=======================================================================
//Impressao do Relatorio
//=======================================================================
oReport:Section(1):Init()
Count To _nCountRec
(_cAlias)->( DbGotop() )
oReport:SetMsgPrint("Imprimindo")
oReport:SetMeter(_nCountRec)

While !oReport:Cancel() .And. (_cAlias)->(!EOF())
	_nCount++
	oReport:Section(1):Cell("A2_CGC"):SetBlock( { || Transform((_cAlias)->A2_CGC, IIF(Len(Alltrim((_cAlias)->A2_CGC))>11,"@R! NN.NNN.NNN/NNNN-99","@R 999.999.999-99")) } )

	If Mod(_nCount, 100) == 0
		Sleep(5000)//Aguarda 1 segundos para evitar sobrecarga do TSS
	EndIf

	//Verifico se possui poss�vel inscri��o v�lida. Do cont�rio, n�o preciso consultar
	If Empty((_cAlias)->A2_INSCR) .Or. "ISENT" $ (_cAlias)->A2_INSCR
		_cSituacao := "N�o consultar"
	Else
		_cSituacao := "Erro"
		ConsCad((_cAlias)->A2_INSCR,(_cAlias)->A2_EST,_lSchedule,@_cSituacao)
	EndIf
	//1-Irregular/ 2-Todos
	If MV_PAR09 == 2 .Or. (_cSituacao == "Erro" .Or. _cSituacao == "Irregular")
		If _lFirst
			oReport:Section(1):Init()
			_lFirst := .F.
		EndIf
		oReport:Section(1):PrintLine()
		oReport:IncMeter()
	EndIf

	(_cAlias)->(dbSkip())

EndDo
If !_lFirst
	oReport:Section(1):Finish()
EndIf

Return
/*
===============================================================================================================================
Programa----------: ConsCad
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 06/12/2018
Descri��o---------: Realiza a consulta da situa��o cadastral do Fornecedor na SEFAZ
Parametros--------: cIE: Inscri��o Estadual
					cUF: Estado
					_lSchedule: Executado via Schedule
Retorno-----------: _lRet: .T. - Situa��o Regular - .F. Situa��o Irregular
===============================================================================================================================
*/
Static Function ConsCad(cIE,cUF,_lSchedule,_cSituacao)

Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cIdEnt	:= "" 
Local nX		:= {}
Local _lRepetir	:= .T.
Local _nQtd		:= 0
Private oWs

cIdEnt := RetIdEnti()
oWs:= WsNFeSBra() :New()
oWs:cUserToken := "TOTVS"
oWs:cID_ENT := cIdEnt
oWs:cUF := cUF
oWs:cCNPJ := ""
oWs:cCPF := ""
oWs:cIE := Alltrim(cIE)
oWs:_URL := AllTrim(cURL)+"/NFeSBRA.apw"

While _lRepetir
	_nQtd++
	If oWs:CONSULTACONTRIBUINTE()
		If ( Len(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE) > 0 )
			nX := Len(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE)
			//1 - Habilitado 0 - N�o Habilitado
			If oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cSituacao == '1'
				_cSituacao := "Regular"
			Else
				_cSituacao := "Irregular"
			EndIf
		  	_lRepetir:= .F.
		EndIf
	Else
		If _lSchedule .And. _nQtd > 2// N�o realizar uma segunda tentativa quando for agendado
			_lRepetir:= .F.
		ElseIf !_lSchedule .And. !ApMsgYesNo("N�o foi possivel realizar a consulta. Deseja fazer uma nova tentativa?","RGLT05901")
			_lRepetir:= .F.
			Sleep(5000)//Aguarda 5 segundos para testar novamente pois provavelmente sobrecarregou o TSS
		EndIf
	EndIf
EndDo				
Return

/*
===============================================================================================================================
Programa----------: SchedDef
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 25/05/2017
Descri��o---------: Defini��o de Static Function SchedDef para o novo Schedule
					No novo Schedule existe uma forma para a defini��o dos Perguntes para o bot�o Par�metros, al�m do cadastro 
					das fun��es no SXD. Ao definir em sua rotina a static function SchedDef(), no cadastro da rotina no Agenda-
					mento do Schedule ser� verificado se existe esta static function e ir� execut�-la habilitando o bot�o Par�-
					metros com as informa��es do retorno da SchedDef(), deixando de verificar assim as informa��es na SXD. O 
					retorno da SchedDef dever� ser um array.
					V�lido para Function e User Function, lembrando que uma vez definido a SchedDef, ao chamar a rotina o ambi-
					ente j� est� inicializado.
					Uma vez definido a Static Function SchedDef(), a rotina deixa de ser uma execu��o como processo especial, 
					ou seja, n�o se deve cadastr�-la no Agendamento passando par�metros de linha. Ex: Funcao("A","B") ou 
					U_Funcao("A","B").
Parametros--------: aReturn[1] - Tipo: "P" - para Processo, "R" -  para Relat�rios
					aReturn[2] - Nome do Pergunte, caso nao use passar ParamDef
					aReturn[3] - Alias  (para Relat�rio)
					aReturn[4] - Array de ordem  (para Relat�rio)
					aReturn[5] - T�tulo (para Relat�rio)
Retorno-----------: aParam
===============================================================================================================================
*/
Static Function SchedDef()

Local aParam  := {}
Local aOrd := {}

aParam := { "R",;
            "RGLT059",;
            "",;
            aOrd,;
            'Situa��o Inscri��o Estadual SEFAZ'}

Return aParam
