/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           |
------------------:------------:----------------------------------------------------------------------------------------------:
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "RWMAKE.CH"        


/*
===============================================================================================================================
Programa----------: AEST004
Autor-------------: Josué Danich Prestes
Data da Criacao---: 15/10/2015
===============================================================================================================================
Descrição---------: Rotina de explosão de estrutura de 1 nivel na tela de desmontagem ( MATA242 ) - Chamado 12268
===============================================================================================================================
Uso---------------: 
===============================================================================================================================
Parametros--------: 	__cProduto - Produto
						_nquant - quantidade do produto
						__oGet - objeto da tela
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
Usuario-----------:
===============================================================================================================================
Setor-------------: Estoque
===============================================================================================================================
*/
User Function AEST004(_cProduto,_nquant,_oGet)


Local _aEstrutura	:= {}
Local _ni        	:= 0
Local _nx        	:= 0
Local _lContinua 	:= .T.
Local _nPospro 	:= GDFieldPos("D3_COD")
Local _arateio	:= {}

Private nEstru:=0


//verifica se produto e quantidade foram preenchidos
If empty(_cproduto)

	messagebox("Preencha produto!","Atenção",0)
	Return
	
Endif

If _nquant == 0

	messagebox("Preencha quantidade!","Atenção",0)
	return

Endif


If _lContinua

	// Verifica se ja existe informacao digitada no aCols
	For _ni:=1 to Len(acols)

		If !(acols[_ni][len(aheader)+1]) .and. !(empty(acols[_ni][_npospro]))

				_lContinua := .F.

		EndIf

	Next _ni

	// Pergunta ao usuario se deve sobrescrever informacoes digitadas
	If !_lContinua 
	
		If messagebox("Ja existem informacoes digitadas para a desmontagem. Substitui?","Atenção",4) == 6

			_lContinua := .T.
		
		Endif

	EndIf

EndIf

If _lContinua .And. !Empty(_cProduto) .And. _nquant > 0

	// Le estrutura do produto origem da desmontagem
	_aEstrutura:=Estrut(_cProduto,_nquant,.T.)

	// Se o produto tiver estrutura cria um novo aCols e monta matriz de rateio
	If Len(_aEstrutura) > 0

		aCols:={}
		
		_arateio := AEST004ES(_aEstrutura,_cproduto,_nquant)

	Else
	
		messagebox("Não foi localizada estrutura para o produto!","Atenção",0)
		return
	
	EndIf

	If len(_arateio) == 0
	
		messagebox("Não foi localizada produção para o produto! Rateios virão zerados","Atenção",0)
		
	Endif
		
	// Le somente os itens de primeiro nivel
	For _ni:=1 to Len(_aEstrutura)

		// Adiciona item no acols
		AADD(aCols,Array(Len(aHeader)+1))

		// Preenche conteudo do acols
		For _nx:=1 to Len(aHeader)

			cCampo:=Alltrim(aHeader[_nx,2])

			If IsHeadRec(cCampo)

				aCols[Len(aCols)][_nx] := 0

			ElseIf IsHeadAlias(cCampo)

				aCols[Len(aCols)][_nx] := "SD3"

			Else

				aCols[Len(aCols)][_nx] := CriaVar(cCampo,.F.)

			EndIf

		Next _nx

		aCOLS[Len(aCols)][Len(aHeader)+1] := .F.

		if aScan(_arateio,{|x| AllTrim(x[1])== Alltrim(_aEstrutura[_ni,3]) }) > 0
		
			_nrateio := (_arateio[aScan(_arateio,{|x| AllTrim(x[1])== Alltrim(_aEstrutura[_ni,3]) })][2]) * 100
			
		Else
		
			_nrateio := 0
			
		Endif
		
		// Preenche campos especificos
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+_aEstrutura[_ni,3]))
		GDFieldPut("D3_COD",_aEstrutura[_ni,3],Len(aCols))
		GDFieldPut("D3_I_DESPR",SB1->B1_I_DESCD,Len(aCols))
		GDFieldPut("D3_QUANT",_aEstrutura[_ni,4],Len(aCols))
		GDFieldPut("D3_RATEIO",_nrateio,Len(aCols))
		GDFieldPut("D3_LOCAL",RetFldProd(SB1->B1_COD,"B1_LOCPAD"),Len(aCols))
		GDFieldPut("D3_QTSEGUM",ConvUm(_aEstrutura[_ni,3],_aEstrutura[_ni,4],0,2),Len(aCols))

	Next _ni

EndIf


Return 

/*
===============================================================================================================================
Programa----------: AEST004ES
Autor-------------: Josué Danich Prestes
Data da Criacao---: 15/10/2015
===============================================================================================================================
Descrição---------: Rotina de carregamento de rateio de valor da estrutura de produto - Chamado 12268
===============================================================================================================================
Uso---------------: 
===============================================================================================================================
Parametros--------: _aestrut - Estrutura do produto
===============================================================================================================================
Retorno-----------: _arateio - Matriz de rateios em sequência
===============================================================================================================================
Usuario-----------:
===============================================================================================================================
Setor-------------: Estoque
===============================================================================================================================
*/
Static Function AEST004ES(_aestrut, _cproduto,_nquant)

Local _nni 		:= 1
Local _arateio 	:= {}
Local _cQuery 	:= ""
Local _nvalorpro 	:= 0
Local _nmaior 	:= 0
Local _nsoma		:= 0
Local _nind		:= 0

//localiz ultima producao
_cQuery := "SELECT MAX(D3_NUMSEQ) AS SEQ"
_cQuery += " FROM " + RetSqlName("SD3") + " D3"
_cQuery += " WHERE D3.D_E_L_E_T_ = ' ' AND D3.D3_COD = '"+_cproduto+"'"
_cQuery += " AND D3.D3_FILIAL = '" + xFilial("SD3") + "'"
_cQuery += " AND D3.D3_CF = 'PR0'"

dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQuery), "SD3T", .T., .F. )
dbSelectArea("SD3T")

If .not. SD3T->( Eof() )

	dbselectarea("SD3")
	SD3->( dbsetorder(4) ) //D3_FILIAL + D3_NUMSEQ
	If SD3->( dbseek( xfilial("SD3") + alltrim( SD3T->SEQ ) ) )

		//roda registro de produção para pegar dados de valores totais
		Do while  alltrim(SD3->D3_NUMSEQ) == alltrim(SD3T->SEQ) .and. !(SD3->( Eof() ))
		
				//se é o PA pega o valor total para  a desmontagem e o original da produção
				If Alltrim(SD3->D3_COD) == alltrim(_cproduto)
				
					_nvalorpro	:= SD3->D3_CUSTO1
					
				Else
				
					aadd(_arateio,{SD3->D3_COD,SD3->D3_CUSTO1})
				
				Endif
				
				SD3->( Dbskip() )
				
		
		Enddo 
		
	Else
	
		return {}
		
	Endif

Else

	return {}
	
Endif

SD3T->( dbclosearea() )

//muda de valor para proporção

For _nni := 1 to len(_arateio)

	_arateio[_nni][2] := _arateio[_nni][2]/_nvalorpro
	
	//guarda maior rateio para ajuste
	if _arateio[_nni][2] > _nmaior
	
		_nmaior 	:= 	_arateio[_nni][2]
		_nind		:=	_nni
		
	Endif
	
	//faz somatorio para saber tamanho do ajuste
	_nsoma += _arateio[_nni][2]
	
Next

//faz ajuste no maior item do rateio
If _nsoma <> 1

	_arateio[_nind][2] := 1 - _nsoma + _arateio[_nind][2]
	
Endif


Return _arateio
