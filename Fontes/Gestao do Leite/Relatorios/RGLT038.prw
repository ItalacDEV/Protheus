/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 30/07/2019 | Chamado 28346. Revis�o de fontes
Lucas Borges  | 09/02/2021 | Chamado 35569. Corrigido error.log quando n�o h� registros a serem exibidos
Lucas Borges  | 22/04/2025 | Chamado 50505. Alterada a picture do CNPJ para contemplar campo alfanum�rico
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: RGLT038
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 05/12/2009
Descri��o---------: Resumo de Rendimentos do exercicio anual de um determinado fretista.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGLT038

Private _cPerg  	:= "RGLT038"
Private _oFont11b	:= Nil
Private _oPrint		:= Nil
Private _nLinha		:= 1
Private _nSalto		:= 60
 
Define Font _oFont11b Name "Courier New" Size 0,-09 Bold  // Tamanho 10 Negrito

If !Pergunte( _cPerg , .T. )
	Return
EndIf 

_oPrint := TMSPrinter():New( "Resumo de Rendimentos Fretista")
_oPrint:SetPortrait() 	//Retrato
_oPrint:SetPaperSize(9)	//Seta para papel A4
_oPrint:Setup()

_nLinha := 0100
// startando a impressora
_oPrint:Say( 0 , 0 , " " , _oFont11b , 100 )

Processa( {|| RGLT038DAD() } )

_oPrint:EndPage()	// Finaliza a Pagina.
_oPrint:Preview()	// Visualiza antes de Imprimir.

Return

/*
===============================================================================================================================
Programa----------: RGLT038CAB
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 05/12/2009
Descri��o---------: Imprime cabe�alho
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RGLT038CAB

Local _cRaizServer	:= If(issrvunix(), "/", "\")
Local _nColuna   	:= 0
Local _nColIni   	:= 0
Local _nColFin   	:= 0
Local _cTitulo   	:= ""

_oPrint:SayBitmap(_nLinha,0100,_cRaizServer + "system/lgrl01.bmp",250,100)   
_nLinha+=(_nSalto * 3) 
_oPrint:Line(_nLinha,0100,_nLinha,2380)    
	
_nLinha+=_nSalto - 30
//DADOS DA EMPRESA
_oPrint:Say (_nLinha,0100,SM0->M0_NOMECOM,_oFont11b)
_oPrint:Say (_nLinha,1250,"C.N.P.J.: " + Transform(SM0->M0_CGC, IIF(Len(AllTrim(SM0->M0_CGC))>11,'@R! NN.NNN.NNN/NNNN-99','@R 999.999.999-99')) ,_oFont11b) // Picture "@R! NN.NNN.NNN/NNNN-99"
_nLinha+=_nSalto
	
_oPrint:Say (_nLinha,0100,AllTrim(SM0->M0_ENDCOB),_oFont11b)
_oPrint:Say (_nLinha,1250,"Insc.: " + AllTrim(SM0->M0_INSC),_oFont11b)
_nLinha+=_nSalto

_oPrint:Say (_nLinha,0100,AllTrim(SM0->M0_CIDCOB) + " - " + AllTrim(SM0->M0_ESTCOB),_oFont11b)
_oPrint:Say (_nLinha,1250,"CEP: " + SubStr(AllTrim(SM0->M0_CEPCOB),1,2) + "." + SubStr(AllTrim(SM0->M0_CEPCOB),3,3) + "-" + SubStr(AllTrim(SM0->M0_CEPCOB),6,3),_oFont11b)
_nLinha+=_nSalto
//FIM DADOS DA EMPRESA
_oPrint:Line(_nLinha,0100,_nLinha,2380) 
_nLinha+=_nSalto

//====================================================================================================
//TITULO DO RELATORIO COM O PERIODO INFORMADO PELO USUARIO
//====================================================================================================
_nColIni	:= 0100
_nColFin	:= 2380
_cTitulo	:= "Resumo Anual de Rendimentos por fretista"

//====================================================================================================
// Calculo para que o nome fica alinhado no centro coluna INSS
// O valor 17.7 eh o valor que cada caractere ocupa
//====================================================================================================
_nColuna:=_nColIni + Int(((_nColFin-_nColIni) - (Len(_cTitulo)* 17.7))/2)
	
_oPrint:Say (_nLinha,_nColuna,_cTitulo,_oFont11b)
_nLinha+=_nSalto

_cTitulo:="Per�odo: " + DtoC(MV_PAR01) + " � " + DtoC(MV_PAR02)

//====================================================================================================
// Calculo para que o nome fica alinhado no centro coluna INSS   
// O valor 17.7 eh o valor que cada caractere ocupa
//====================================================================================================
_nColuna:=_nColIni + Int(((_nColFin-_nColIni) - (Len(_cTitulo)* 17.7))/2)

_oPrint:Say (_nLinha,_nColuna,_cTitulo,_oFont11b)
_nLinha+=_nSalto
_nLinha+=_nSalto

Return

/*
===============================================================================================================================
Programa----------: DadosRelat
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 05/12/2009
Descri��o---------: Imprime corpo relat�rio
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RGLT038DAD

Local _nCountRec	:= 0
Local _aDadosFret	:= {}
Local _cCodFretis	:= ""
Local _cCodLjFret	:= ""
Local _cFiltro		:= "%"
Local _cAlias		:= GetNextAlias()

//Estado
If !Empty(MV_PAR07)
	_cFiltro+=" And SA2.A2_EST = '" + MV_PAR07 + "'"
EndIf

//Municipio
If !Empty(MV_PAR08)
	_cFiltro+=" And SA2.A2_COD_MUN IN " + FormatIn(AllTrim(MV_PAR08),";")
EndIf

//Se preencheu os setores, j� fiz a valida��o de acesso no SX1
//Se n�o preencheu e n�o tem acesso a todos, filtra de forma que n�o retorme registros
If !Empty(MV_PAR09) .Or. Empty(MV_PAR09) .And. Posicione("ZLU",1,xFilial("ZLU")+RetCodUsr(),"ZLU_SETALL") <> 'S'
	_cFiltro += " AND ZLF.ZLF_SETOR IN "+ FormatIn( AllTrim(MV_PAR09) , ';' )
EndIf

_cFiltro += "%"

ProcRegua(0)
IncProc("Consultando registros no Banco de Dados")

//SQL que calcula as ENTRADAS do saldo anterior
BeginSql alias _cAlias
	SELECT ZLF.ZLF_A2COD,ZLF.ZLF_A2LOJA, SA2.A2_NOME, SA2.A2_TIPO, ZLF.ZLF_DTINI, 
			ZLF.ZLF_EVENTO, ZLF.ZLF_DEBCRE, SUM(ZLF.ZLF_QTDBOM) QTDBOM, SUM(ZLF.ZLF_TOTAL) TOTAL, SUM(ZLF.ZLF_VLRPAG) VLRPAG,
			NVL((SELECT SUM(ZLD_QTDBOM)
	  			FROM %Table:ZLD% ZLD
	  			WHERE ZLD.D_E_L_E_T_ = ' '
	  			AND ZLD.ZLD_FILIAL = ZLF.ZLF_FILIAL
	  			AND ZLD.ZLD_DTCOLE BETWEEN ZLF.ZLF_DTINI AND ZLF.ZLF_DTFIM
	  			AND ZLD.ZLD_STATUS = 'F'
				AND ZLD.ZLD_FRETIS = ZLF.ZLF_A2COD
				AND ZLD.ZLD_LJFRET = ZLF.ZLF_A2LOJA),0) VOLUME
	FROM %Table:ZLF% ZLF, %Table:SA2% SA2
	WHERE ZLF.D_E_L_E_T_ = ' '
	AND SA2.D_E_L_E_T_ = ' '
	AND ZLF.ZLF_A2COD = SA2.A2_COD
	AND ZLF.ZLF_A2LOJA = SA2.A2_LOJA
	AND ZLF.ZLF_FILIAL = %xFilial:ZLF%
	AND ZLF.ZLF_TP_MIX = 'F'
	%exp:_cFiltro%
	And ZLF.ZLF_DTINI BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
	And ZLF.ZLF_A2COD BETWEEN %exp:MV_PAR03% AND %exp:MV_PAR05%
	And ZLF.ZLF_A2LOJA BETWEEN %exp:MV_PAR04% AND %exp:MV_PAR06%
	GROUP BY ZLF.ZLF_FILIAL, ZLF.ZLF_A2COD,ZLF.ZLF_A2LOJA,ZLF.ZLF_DTINI, ZLF.ZLF_DTFIM, ZLF.ZLF_EVENTO,ZLF.ZLF_DEBCRE, SA2.A2_NOME, SA2.A2_TIPO
	ORDER BY ZLF.ZLF_FILIAL, ZLF.ZLF_A2COD,ZLF.ZLF_A2LOJA,ZLF.ZLF_DTINI,ZLF.ZLF_EVENTO,ZLF.ZLF_DEBCRE
EndSql

Count To _nCountRec
(_cAlias)->(DBGoTop())
ProcRegua(_nCountRec)

While (_cAlias)->(!Eof())

	IncProc("Imprimindo")

	If ((_cAlias)->ZLF_A2COD <> _cCodFretis)
		//Caso nao seja o primeiro registro
		If !Empty(_cCodFretis)
			_oPrint:StartPage()//Inicia uma nova pagina a cada novo produtor
			_nLinha:=0100
			RGLT038CAB()//Imprime Cabecalho	da PAGINA
			RGLT038FRET(_cCodFretis,_cCodLjFret)//Cabecalho Produtor
			RGLT038REN(_aDadosFret)//Monta os redimentos do produtor e sua loja
			_aDadosFret:={}        //Seta o vetor que contem os dados do produtor que acabou de imprimir os rendimentos
			_oPrint:EndPage()
    	EndIf
		//armazena os dados do primeiro registro do produtor
		aAdd(_aDadosFret,{(_cAlias)->ZLF_A2COD,(_cAlias)->ZLF_A2LOJA,(_cAlias)->zlf_dtini,(_cAlias)->zlf_evento,(_cAlias)->zlf_debcre,(_cAlias)->QTDBOM,(_cAlias)->TOTAL,(_cAlias)->VLRPAG,(_cAlias)->A2_TIPO, (_cAlias)->VOLUME})
		//Seta as variaveis codigo e loja do produtor para comparacao
		_cCodFretis:=(_cAlias)->ZLF_A2COD
		_cCodLjFret:=(_cAlias)->ZLF_A2LOJA
	Else
		If (_cAlias)->ZLF_A2LOJA <> _cCodLjFret
			_oPrint:StartPage()//Inicia uma nova pagina a cada novo produtor
			_nLinha:=0100
			RGLT038CAB()//Imprime Cabecalho	da PAGINA
			RGLT038FRET(_cCodFretis,_cCodLjFret)//Cabecalho Produtor
			RGLT038REN(_aDadosFret)//Monta os redimentos do produtor e sua loja
			_aDadosFret:={}        //Seta o vetor que contem os dados do produtor que acabou de imprimir os rendimentos
			_oPrint:EndPage()
			//Seta as variaveis codigo e loja do produtor para comparacao
			_cCodLjFret:=(_cAlias)->ZLF_A2LOJA
	    EndIf
       	aAdd(_aDadosFret,{(_cAlias)->ZLF_A2COD,(_cAlias)->ZLF_A2LOJA,(_cAlias)->zlf_dtini,(_cAlias)->zlf_evento,(_cAlias)->zlf_debcre,(_cAlias)->QTDBOM,(_cAlias)->TOTAL,(_cAlias)->VLRPAG, (_cAlias)->A2_TIPO, (_cAlias)->VOLUME})
	EndIf

	(_cAlias)->(dbSkip())
EndDo

If _nCountRec > 0
	//imprime os dados do ultimo produtor
	_nLinha := 0100
	RGLT038CAB()//Imprime Cabecalho	da PAGINA
	RGLT038FRET(_cCodFretis,_cCodLjFret)//Cabecalho Produtor
	RGLT038REN(_aDadosFret)
	_aDadosFret:={}
EndIf
(_cAlias)->(DBCloseArea())

Return

/*
===============================================================================================================================
Programa----------: RGLT038FRET
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 05/12/2009
Descri��o---------: Imprime corpo relat�rio
Parametros--------: _cALias
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RGLT038FRET(codFretist,lojFretist)

DbSelectArea("SA2")
SA2->(DbSetOrder(1))
SA2->(DbSeek(xFilial("SA2") + codFretist + lojFretist))

_oPrint:Say(_nLinha,0100,"TRANSPORTADOR: " + AllTrim(SA2->A2_COD) + " - " + SA2->A2_LOJA + "  " + AllTrim(SA2->A2_NOME),_oFont11b) 
_nLinha+=_nSalto

_oPrint:Say(_nLinha,0100,"CPF/CNPJ: "  + Transform(SA2->A2_CGC,IIf(SA2->A2_TIPO=="J",'@R! NN.NNN.NNN/NNNN-99','@R 999.999.999-99')), _oFont11b)
_oPrint:Say(_nLinha,1250,"INSCRI��O: " + SA2->A2_INSCR ,_oFont11b)
_nLinha+=_nSalto

_oPrint:Say(_nLinha,0100,"ENDERE�O: "  + SubStr(AllTrim(SA2->A2_END) + " - " + AllTrim(SA2->A2_BAIRRO),1,45),_oFont11b) 
_oPrint:Say(_nLinha,1250,"MUNICIPIO: " + AllTrim(SA2->A2_MUN),_oFont11b) 

Return

/*
===============================================================================================================================
Programa----------: RGLT038REN
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 08/12/2009
Descri��o---------: Trabalhar as informacoes do fretista e de sua respectiva fazenda dividindo ela por mes, para posteriormente
					a isso desenhar o quadro que comtem as informacoes por m�s.
Parametros--------: //1 - Codigo do fretista
					//2 - loja do fretista
					//3 - data inicial do mix
					//4 - codigo do evento 
					//5 - se o evento eh de debito ou credito (C/D) 
					//6 - somatorio de leite que entrou
					//7 - total 
					//8 - valor total pago
					//9 - Tipo (F-J)
					//10 - Volume
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RGLT038REN(aDadosRend)   

Local _aDadosMesR:= {{"01",0,0,0,0,0},{"02",0,0,0,0,0},{"03",0,0,0,0,0},{"04",0,0,0,0,0},{"05",0,0,0,0,0},{"06",0,0,0,0,0},;
					{"07",0,0,0,0,0},{"08",0,0,0,0,0},{"09",0,0,0,0,0},{"10",0,0,0,0,0},{"11",0,0,0,0,0},{"12",0,0,0,0,0}}
Local _nPos			:= 0
Local _nCont		:= 1
Local _nLinhaIni 	:= 0
Local _nTotalLitr	:= 0
Local _nTotalFund	:= 0
Local _nTotalInss	:= 0
Local _nTotalRend	:= 0
Local _aMes      	:={"Janeiro","Feveiro","Mar�o","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}

While _nCont <= Len(aDadosRend)
	//Verifica se o mes ja foi lancado
	_nPos:=aScan(_aDadosMesR,{|x| x[1] == SubStr(aDadosRend[_nCont,3],5,2)})
	If _nPos > 0
		_aDadosMesR[_nPos,6]:= aDadosRend[_nCont,10]
		If  aDadosRend[_nCont,5] == 'C'	//Efetua o somatorio da litragem transportada juntamente com o valor total pago 	 	
	 		_aDadosMesR[_nPos,3]+= aDadosRend[_nCont,7]//Rendimentos para IR 	
	    EndIf
	EndIf
	++_nCont
EndDo

_nLinha+=_nSalto
_nLinha+=_nSalto
_nLinhaIni := _nLinha //Usada para a linha inicial do box

_oPrint:Say(_nLinha,0120,"M�s de Refer�ncia",_oFont11b)
_oPrint:Say(_nLinha,0770,"Litragem ",_oFont11b)
_oPrint:Say(_nLinha,1230,"Rendimentos",_oFont11b)
_oPrint:Say(_nLinha,1900,"Descontos ",_oFont11b)

_nLinha+=_nSalto
_oPrint:Line(_nLinha,1580,_nLinha,2380)
_oPrint:Say(_nLinha,1230,"para IR" ,_oFont11b)
_oPrint:Say(_nLinha,1790,"INSS",_oFont11b)
_oPrint:Say(_nLinha,2200,"IRRF",_oFont11b)
_nLinha+=_nSalto

_oPrint:Line(_nLinha,0100,_nLinha,2380)
_nLinha+=_nSalto

_nCont:=1
While _nCont <= Len(_aDadosMesR)
	//Pega a litragem do produtor para o mes em questao
	//fretista, loja fretista e mes corrente
	_oPrint:Say(_nLinha,0150,_aDadosMesR[_nCont,1] + " - "+ _aMes[Val(_aDadosMesR[_nCont,1])],_oFont11b) //Mes
	_oPrint:Say(_nLinha,0850,transform(_aDadosMesR[_nCont,6],"@E 999,999,999"),_oFont11b) //Litragem
	_oPrint:Say(_nLinha,1310,transform(IIF(aDadosRend[1,9] = 'F',_aDadosMesR[_nCont,3] * 0.40,_aDadosMesR[_nCont,3]),"@E 99,999,999.99"),_oFont11b) //Tributaveis
	_oPrint:Say(_nLinha,1840,transform(_aDadosMesR[_nCont,4],"@E 9,999,999.99"),_oFont11b) //Funrural - INSS
	_oPrint:Say(_nLinha,2140,transform(_aDadosMesR[_nCont,5],"@E 9,999,999.99"),_oFont11b) //Fundepec
	_oPrint:Line(_nLinha,0100,_nLinha,2380)
	_nLinha+=_nSalto

	//Somatorio para totalizadores
	_nTotalLitr+= _aDadosMesR[_nCont,6]
	_nTotalRend+= _aDadosMesR[_nCont,3]

	++_nCont
EndDo

//Imprime totalizadores
_oPrint:Line(_nLinha,0100,_nLinha,2380)
_nLinha+=_nSalto
_oPrint:Line(_nLinha,0100,_nLinha,2380)

_oPrint:Say(_nLinha,0120,"Totais do Exercicio",_oFont11b)
_oPrint:Say(_nLinha,0850,transform(_nTotalLitr,"@E 999,999,999"),_oFont11b)
_oPrint:Say(_nLinha,1310,transform(_nTotalRend,"@E 99,999,999.99"),_oFont11b)
_oPrint:Say(_nLinha,1840,transform(_nTotalInss,"@E 9,999,999.99"),_oFont11b)
_oPrint:Say(_nLinha,2140,transform(_nTotalFund,"@E 9,999,999.99"),_oFont11b)
_nLinha+=_nSalto

_oPrint:Box(_nLinhaIni,0100,_nLinha,2380)
_oPrint:Line(_nLinhaIni,0630,_nLinha,0630)//Litragem
_oPrint:Line(_nLinhaIni,1080,_nLinha,1080)//Tributaveis
_oPrint:Line(_nLinhaIni,1580,_nLinha,1580)//Funrural - INSS
_oPrint:Line(_nLinhaIni+60,2080,_nLinha,2080)//Fundepec

_nLinha+=_nSalto
_nLinha+=_nSalto

//Imprime texto na tela para fretistas pessoa fisica
If aDadosRend[1,9] == 'F'
	_oPrint:Say(_nLinha,0100,"- RESSALVAMOS QUE A EMPRESA GOIASMINAS IND�STRIA DE LATIC�NIOS SOMENTE REPASSA O FRETE QUE � RETIDO DOS PRODUTORES",_oFont11b)
	_nLinha+=_nSalto
	_oPrint:Say(_nLinha,0100,"  DEVENDO SER INFORMADO NA DIRPF COMO RENDIMENTOS RECEBIDOS DE PESSOAS F�SICAS.",_oFont11b)
	_nLinha+=_nSalto
	_oPrint:Say(_nLinha,0100,"- NOS TERMOS DO REGULAMENTO DO IMPOSTO DE RENDA DEC. 3000/99 OS VALORES ACIMA DISPONIBILIZADOS NA COLUNA RENDIMEN-",_oFont11b)
	_nLinha+=_nSalto
	_oPrint:Say(_nLinha,0100,"  TOS PARA IR CORRESPONDEM � BASE DE C�LCULO PARA O IR(40% DO VALOR BRUTO DO FRETE).",_oFont11b)
EndIf

Return
