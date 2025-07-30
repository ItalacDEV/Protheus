/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 10/10/2019 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25
Lucas Borges  | 22/04/2025 | Chamado 50505. Alterada a picture do CNPJ para contemplar campo alfanumérico
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
===============================================================================================================================
Programa----------: RFIN003
Autor-------------: Wodson Reis
Data da Criacao---: 27/02/2009
Descrição---------: Relatorio dos Titulos do Contas a Receber em formulario pre-impresso de duplicata
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RFIN003()

Local titulo  := "EMISSAO DE DUPLICATAS"
Local cDesc1  := "Este programa ira emitir as Duplicatas conforme"
Local cDesc2  := "parametros especificados."
Local cDesc3  := ""
Local aOrd    := {}

Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 132
Private tamanho     := "M"
Private nomeprog    := "RFIN003"
Private nTipo       := 18
Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLin        := 0
Private nLastKey    := 0
Private nReg        := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "RFIN003"
Private cPerg       := "RFIN003"
Private cString     := "SE1"

dbSelectArea("SE1")
dbSetOrder(1)

//Chama a tela para preenchimento dos parametros
If !Pergunte(cPerg,.T.)
	Return()
EndIf

//Monta a interface padrao com o usuario...
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//Processamento. RPTSTATUS monta janela com a regua de processamento.
RptStatus({|| RptDetail()}, "Imprimindo Duplicata, aguarde...")

Return

/*
===============================================================================================================================
Programa----------: RptDetail
Autor-------------: Wodson Reis
Data da Criacao---: 27/02/2009
Descrição---------: Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RptDetail()

Local _nVlrTotal 	:=	0 
Local _nParc		:=	0	

//Controle de impressao
SetPrc(0,0)
dbCommitAll()

@ 000,000 PSAY AvalImp(Limite)

@ 000,001 PSAY Chr(27)+Chr(48)		     // Ajusta espacamento de linha p/ 1/8'
@ 000,005 PSAY Chr(27)+Chr(120)+"0"	 // Fonte: DRAFT
@ 000,010 PSAY Chr(27)+Chr(67)+ Chr(87) // Tamanho da Pagina: 101 linhas
@ 000,015 PSAY Chr(18)  	 			 // Normal   -------+

//Chama o filtro dos dados
MsgRun("Aguarde.... filtrando dados...",,{||CursorWait(), FILTROSE1(), CursorArrow()})

//SETREGUA -> Indica quantos registros serao processados para a regua
SetRegua(RecCount())

//Posiciona no incio da tabela temporaria.
DbSelectArea("TMP")
TMP->(DbGoTop())

While TMP->(!EOF())
	
	//Verifica o cancelamento pelo usuario...
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	//Imprime os dados do titulo...
	
	//Verifica se eh necessaria a impressao do numero do banco, adicionado por Fabiano Dias no dia 21/06/10 mediante solicitacao feita por Tiago Correa
	If Len(AllTrim(TMP->E1_NUMBCO)) > 0   
	nLin := 08
	@ nLin,042 PSAY "BOLETO: " + AllTrim(TMP->E1_NUMBCO)
	EndIf
	
	nLin := 10
	@ nLin,050 PSAY DTOC(STOD(TMP->E1_EMISSAO))
	
	nLin += 5
	
	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek(TMP->E1_FILIAL+TMP->E1_PREFIXO+TMP->E1_NUM)
	While SE1->E1_FILIAL == TMP->E1_FILIAL .and. SE1->E1_NUM == TMP->E1_NUM .and. SE1->E1_CLIENTE == TMP->E1_CLIENTE 	.and. SE1->E1_LOJA == TMP->E1_LOJA 
			_nVlrTotal	:=	_nVlrTotal + SE1->E1_VALOR	 
			_nParc		:=	_nParc + 1 
		dbskip()
	Enddo	
	
	@ nLin,012 PSAY Transform(_nVlrTotal,"@E 9,999,999.99")
	_nVlrTotal	:=	0 
	@ nLin,026 PSAY ALLTRIM(TMP->E1_NUM)
	@ nLin,034 PSAY Transform(TMP->E1_VALOR,"@E 9,999,999.99")
	@ nLin,047 PSAY ALLTRIM(TMP->E1_NUM)	
	@ nLin,058 PSAY DTOC(STOD(TMP->E1_VENCTO))
	nLin += 1                                                                    
	@ nLin,029 PSAY ALLTRIM(TMP->E1_TIPO)
	@ nLin,050 PSAY TMP->E1_PARCELA + "/" + "0"+ ALLTRIM(TRANSFORM(_nParc,"99"))
	_nParc	:=	0	
 	nLin += 3
	@ nLin,019 PSAY Transform(TMP->E1_I_DESCO,"@E 9,999,999.99")
	
	nLin += 4
	
	//Posiciona no cadastro de clientes para impressao dos dados cadastrais.
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFILIAL("SA1")+TMP->E1_CLIENTE+TMP->E1_LOJA)
	
	If found()
		@ nLin,023 PSAY SUBSTR(SA1->A1_NOME,1,46)+" ("+SA1->A1_COD+")"
		
		nLin += 1
		@ nLin,023 PSAY SUBSTR(SA1->A1_END,1,44)
		@ nLin,067 PSAY SA1->A1_CEP Picture "@R 99999-999"
		
		nLin += 2
		@ nLin,023 PSAY ALLTRIM(SA1->A1_MUN)
		@ nLin,057 PSAY SA1->A1_EST
		
		nLin += 1
		@ nLin,023 PSAY If(Empty(SA1->A1_ENDCOB),SUBSTR(SA1->A1_END,1,44),SUBSTR(SA1->A1_ENDCOB,1,44))
		@ nLin,067 PSAY If(Empty(SA1->A1_CEPC),SA1->A1_CEP,SA1->A1_CEPC) Picture "@R 99999-999"
		
		nLin += 2
		If Empty(Alltrim(SA1->A1_CGC))
			@ nLin,023 PSAY "."
		ElseIf Len(Alltrim(SA1->A1_CGC)) > 11
			@ nLin,023 PSAY SA1->A1_CGC Picture "@R! NN.NNN.NNN/NNNN-99"
		Else
			@ nLin,023 PSAY SA1->A1_CGC Picture "@R 999.999.999-99"
		EndIf
		@ nLin,052 PSAY SA1->A1_INSCR
		
		nLin += 2
	EndIf
	
	@ nLin,023 PSAY Subs(RTRIM(SUBS(EXTENSO(TMP->E1_VALOR),1,55)) + REPLICATE("*",54),1,54)
	nLin += 1
	@ nLin,023 PSAY Subs(RTRIM(SUBS(EXTENSO(TMP->E1_VALOR),56,55)) + REPLICATE("*",54),1,54)
	nLin += 1
	@ nLin,023 PSAY Subs(RTRIM(SUBS(EXTENSO(TMP->E1_VALOR),112,55)) + REPLICATE("*",54),1,54)
	nLin += 1
	@ nLin,023 PSAY Subs(RTRIM(SUBS(EXTENSO(TMP->E1_VALOR),168,55)) + REPLICATE("*",54),1,54)
	
	//Controle do Salto de pagina
	nLin := 048
	@ nLin, 000 PSAY ""
	
	//Zera o Formulario
	SetPrc(0,0)
	//Eject
	
	TMP->(DbSkip())
EndDo

// Apaga o arquivo temporario...
DbSelectArea("TMP")
DbCloseArea()

//Finaliza a execucao do relatorio...
SET DEVICE TO SCREEN
SetPgEject(.F.)

//Se impressao em disco, chama o gerenciador de impressao...
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*
===============================================================================================================================
Programa----------: FILTROSE1
Autor-------------: Wodson Reis
Data da Criacao---: 27/02/2009
Descrição---------: Seleciona os dados a serem impressos.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function FILTROSE1()

Local cQuery  := ""

//Query para Selecao dos dados
cQuery := "SELECT E1_FILIAL, E1_CLIENTE,E1_LOJA,E1_EMISSAO,E1_VENCTO,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_VALOR,E1_I_DESCO,E1_TIPO,E1_NUMBCO FROM "
cQuery += RetSqlName("SE1")+" "
cQuery += "WHERE D_E_L_E_T_ = ' ' "
cQuery += "AND E1_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
cQuery += "AND E1_VENCTO  BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
cQuery += "AND E1_CLIENTE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
cQuery += "AND E1_LOJA    BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
cQuery += "AND E1_NUM     BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' "
cQuery += "AND E1_FILIAL  BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' "
cQuery += "AND E1_TIPO <> '"+MV_PAR13+"' "

If MV_PAR14 == 1
	cQuery += "AND E1_SALDO <> 0 "
Endif

cQuery += "ORDER BY E1_EMISSAO,E1_NUM,E1_PARCELA "

Count To nReg

TCQUERY cQuery NEW ALIAS "TMP"
DbSelectArea("TMP")

Return
