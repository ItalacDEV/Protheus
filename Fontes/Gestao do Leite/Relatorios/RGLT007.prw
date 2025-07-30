/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 19/02/2020 | Chamado 32081. Corrigido error.log ao cancelar o relat�rio.
Lucas Borges  | 22/04/2025 | Chamado 50505. Alterada a picture do CNPJ para contemplar campo alfanum�rico
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: RGLT007
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 12/11/2019
Descri��o---------: Relat�rio Autoriza��o de Desconto Financeiro Frestista. Chamado 31174
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGLT007()

Local cDesc1	:= "Este programa tem como objetivo imprimir uma  "
Local cDesc2	:= "autoriza��o de Desconto Financeiro de d�bitos do   "
Local cDesc3	:= "Fretista."
Local _cTitulo	:= "Autoriza��o de Desconto Financeiro Frestista"
Local aOrd		:= {}
Local cTamanho	:= "P"
Local NomeProg	:= "RGLT007"
Local nTipo		:= 18
Local wnrel		:= "RGLT007" // Coloque aqui o nome do arquivo usado para impressao em disco
Local _cPerg	:= "RGLT007"
Private aReturn	:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private m_pag	:= 01 // Contador de Paginas
Private nLastKey:= 0 // Controla o cancelamento da SetPrint e SetDefault
Private lEnd	:= .F.// Controle de cancelamento do relatorio

Pergunte(_cPerg,.f.)

// Monta a interface padrao com o usuario...                           �
wnrel := SetPrint("",NomeProg,_cPerg,@_cTitulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,cTamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,"")

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|lEnd|RGLT007P(@lEnd) },_cTitulo)

Return()

/*
===============================================================================================================================
Programa----------: RGLT007P
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 24/05/2019
Descri��o---------: Processa relat�rio
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RGLT007P(lEnd)

Local nL			:= 0
Local nCount		:= 0

Local oFont18BU	:= TFont():New("Arial",,18/*nHeight*/,,.T./*lBold*/,,,,,.T./*lUnderline*/,.F./*lItalic*/)
Local oFont14B	:= TFont():New("Arial",,14/*nHeight*/,,.T./*lBold*/,,,,,.F./*lUnderline*/,.F./*lItalic*/)
Local oFont14BU	:= TFont():New("Arial",,14/*nHeight*/,,.T./*lBold*/,,,,,.T./*lUnderline*/,.F./*lItalic*/)
Local oFont14	:= TFont():New("Arial",,14/*nHeight*/,,.F./*lBold*/,,,,,.F./*lUnderline*/,.F./*lItalic*/)

Local cRaizServer	:= If(issrvunix(), "/", "\")
Local nQtdReg		:= 0
Local _cAlias		:= GetNextAlias()
Local _cFiltro		:= "%"
Local _cTransp		:= ""
Local _aSelFil		:= {}
Local _aArea		:= SM0->(GetArea())
Local _lNovo 		:= .T.
Local _cCidade		:= ""
Local _cNome		:= ""
Local _nTotal		:= 0
Local _cData		:= ""

// Objeto de impressao grafica
oPrint:= TMSPrinter():New( "Relatorio de Grafico" )
oPrint:SetPortrait() 
oPrint:Setup()
oPrint:SetPaperSize(9)//DMPAPER_A4 9

//Chama fun��o que permitir� a sele��o das filiais
If MV_PAR01 == 1
	If Empty(_aSelFil)
		_aSelFil := AdmGetFil(.F.,.F.,"ZLF")
	EndIf
Else
	Aadd(_aSelFil,cFilAnt)
EndIf

_cFiltro += " AND ZLF_FILIAL "+ GetRngFil( _aSelFil, "ZLF", .T.,)

//Se preencheu os setores, j� fiz a valida��o de acesso no SX1
//Se n�o preencheu e n�o tem acesso a todos, filtra de forma que n�o retorme registros
If !Empty(MV_PAR03) .Or. Empty(MV_PAR03) .And. Posicione("ZLU",1,xFilial("ZLU")+RetCodUsr(),"ZLU_SETALL") <> 'S'
	_cFiltro += " AND ZLF_SETOR IN "+ FormatIn( AllTrim(MV_PAR03) , ';' )
EndIf

//Verifica se foi fornecido o filtro de linha
If !Empty(MV_PAR04)
	_cFiltro += " AND ZLF_LINROT IN " + FormatIn(AllTrim(MV_PAR04),";")
EndIf

_cFiltro+= "%"
// Obtem dados de impressao
BeginSql alias _cAlias
	SELECT ZLF_FILIAL, ZLF_DTFIM, A2_COD, A2_LOJA, A2_NOME, ZLF_SETOR, A2_CGC, ZL8_DESCRI, SUM(ZLF_TOTAL) ZLF_TOTAL
	  FROM %table:ZLF% ZLF, %table:ZL8% ZL8, %table:SA2% SA2
	 WHERE ZLF.D_E_L_E_T_ = ' '
	   AND ZL8.D_E_L_E_T_ = ' '
	   AND SA2.D_E_L_E_T_ = ' '
	   AND ZLF_FILIAL = ZL8_FILIAL
	   AND ZLF_EVENTO = ZL8_COD
	   AND ZLF_A2COD = A2_COD
	   AND ZLF_A2LOJA = A2_LOJA
	   AND ZLF_DEBCRE = 'D'
	   AND SUBSTR(ZLF_A2COD,1,1) = 'G'
	   %exp:_cFiltro%
	   AND ZLF_CODZLE = %exp:MV_PAR02%
	   AND ZLF_A2COD BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR06%
	   AND ZLF_A2LOJA BETWEEN %exp:MV_PAR07% AND %exp:MV_PAR08%
	GROUP BY ZLF_FILIAL, ZLF_DTFIM, A2_COD, A2_LOJA, A2_NOME, ZLF_SETOR, A2_CGC, ZL8_DESCRI
	 ORDER BY ZLF_FILIAL, ZLF_SETOR, A2_COD, A2_LOJA
EndSql
Count to nQtdReg

ProcRegua(nQtdReg)

(_cAlias)->(DbGoTop())

While !(_cAlias)->(EOf())
	If lEnd
		@ Prow()+1,001 PSay "CANCELADO PELO OPERADOR"
		Exit
	EndIf
	nCount++                   
	incproc((_cAlias)->A2_COD)

	If (_cAlias)->(A2_COD+A2_LOJA) <> _cTransp .And. !_lNovo
		oPrint:Say(nL,100,"Total de D�bitos: ",oFont14B)
		oPrint:Say(nL,1900,"R$ "+Transform(_nTotal,GetSx3Cache("ZLF_TOTAL","X3_PICTURE")),oFont14B,/*nWidth*/,/*nClrText*/,,1/*nAlign*/)
		nL += 250
		oPrint:Say(nL,100,_cCidade+", "+Substr(_cData,7,2)+" de "+MesExtenso(SToD(_cData))+" de "+Substr(_cData,1,4)+".",oFont14)
		nL += 250
		oPrint:Say(nL,800,_cNome,oFont14)	
		oPrint:FillRect({nL,300,nL+1,2100},TBrush():New("",0)) 
		oPrint:EndPage()
		_lNovo := .T.
		_nTotal := 0
	EndIf
	
	If (_cAlias)->(A2_COD+A2_LOJA) <> _cTransp
		_cTransp := (_cAlias)->(A2_COD+A2_LOJA)
		SM0->(DbSeek(cEmpAnt + (_cAlias)->ZLF_FILIAL))
		_cCidade := AllTrim(SM0->M0_CIDENT)
		_cNome := (_cAlias)->A2_NOME
		_cData := (_cAlias)->ZLF_DTFIM
	    oPrint:StartPage()
	    
		nL := 50
	   	oPrint:SayBitmap(nL+20,100,cRaizServer + "system/lgrl01.bmp",250,100)
		nL += 60
		oPrint:Say(nL,600,"AUTORIZA��O DE DESCONTO FINANCEIRO",oFont18BU)
		nL += 300

		oPrint:Say(nL,100,"Transportadora:",oFont14B) 
		oPrint:Say(nL,500,(_cAlias)->A2_NOME,oFont14) 
		oPrint:Say(nL,1600,"CNPJ:",oFont14B)
		oPrint:Say(nL,1750,Transform((_cAlias)->A2_CGC,"@R! NN.NNN.NNN/NNNN-99"),oFont14)
		nL += 250
		
		oPrint:Say(nL,100,'Conforme pactuado no "CONTRATO DE PRESTA��O DE SERVI�OS DE COLETA E TRANS-',oFont14)
		nL += 50
		oPrint:Say(nL,100,'PORTE  DE  LEITE  A GRANEL"  e  as "NORMAS E PROCEDIMENTOS  PARA A  COLETA DE',oFont14)
		nL += 50
		oPrint:Say(nL,100,'LEITE A GRANEL", a  transportadora  CONTRATADA  autoriza o desconto dos d�bitos proveni-',oFont14)
		nL += 50		
		oPrint:Say(nL,100,'ente de conv�nios, empr�stimos, adiantamentos, seguros diversos, do fornecimento de equipa-',oFont14)
		nL += 50
		oPrint:Say(nL,100,'mentos, de manuten��o de  tanque rodovi�rio e telemetria,  bem como da falta de leite ou pelo',oFont14)
		nL += 50
		oPrint:Say(nL,100,'descarte parcial ou  integral da carga,  ressarcindo o preju�zo causado � CONTRATANTE, reco-',oFont14)
		nL += 50
		oPrint:Say(nL,100,'nhecendo que as n�o conformidades encontradas no leite coletado atrav�s de an�lises labora-',oFont14)
		nL += 50
		oPrint:Say(nL,100,'toriais ou diferen�as de volumes ocasionadas por erro de marca��o, foram decorrentes do n�o',oFont14)
		nL += 50
		oPrint:Say(nL,100,'cumprimento dos procedimentos estabelecidos e repassados �s transportadoras e seus agentes',oFont14)
		nL += 50
		oPrint:Say(nL,100,'de coletas atrav�s de treinamentos espec�ficos, referente � ocorr�ncia registrada. O valor total',oFont14)
		nL += 50
		oPrint:Say(nL,100,'ser� descontado no pagamento do frete que a CONTRATANTE efetuar� � CONTRATADA, refe-',oFont14)
		nL += 50
		oPrint:Say(nL,100,'rente ao transporte de leite efetuado no m�s de '+MesExtenso(SToD(_cData))+' de '+Substr(_cData,1,4)+'.',oFont14)
		nL += 150

		oPrint:Say(nL,100,"Descri��o dos D�bitos",oFont14BU)
		nL += 100
		_lNovo := .F.
	EndIf

	oPrint:Say(nL,100,AllTrim((_cAlias)->ZL8_DESCRI)+": ",oFont14)
	oPrint:Say(nL,1900,"R$ "+Transform((_cAlias)->ZLF_TOTAL,GetSx3Cache("ZLF_TOTAL","X3_PICTURE")),oFont14,/*nWidth*/,/*nClrText*/,,1/*nAlign*/)
	_nTotal += (_cAlias)->ZLF_TOTAL
	nL += 50

	(_cAlias)->(DbSkip())
	
EndDo

//Total da �ltima p�gina
oPrint:Say(nL,100,"Total de D�bitos: ",oFont14B)
oPrint:Say(nL,1900,"R$ "+Transform(_nTotal,GetSx3Cache("ZLF_TOTAL","X3_PICTURE")),oFont14B,/*nWidth*/,/*nClrText*/,,1/*nAlign*/)
nL += 250
oPrint:Say(nL,100,_cCidade+", "+Substr(_cData,7,2)+" de "+MesExtenso(SToD(_cData))+" de "+Substr(_cData,1,4)+".",oFont14)
nL += 250
oPrint:Say(nL,800,_cNome,oFont14)	
oPrint:FillRect({nL,300,nL+1,2100},TBrush():New("",0)) 
oPrint:EndPage()

(_cAlias)->(DbCloseArea())
	
oPrint:Preview()

RestArea(_aArea)

Return
