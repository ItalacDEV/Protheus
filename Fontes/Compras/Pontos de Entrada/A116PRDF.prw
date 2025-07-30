/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 18/06/2018 | Alterado produto padr�o para todas a opera��es. Chamado 25235
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 10/01/2019 | Inclu�do tratamento para CTeOS. Chamado 23984
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 28/04/2022 | Tratamento para demais tags de fornecedores. Chamado 39923
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa--------: A116PRDF
Autor-----------: Lucas Borges Ferreira
Data da Criacao-: 21/05/2018
===============================================================================================================================
Descri��o-------: Ponto de entrada utilizado na rotina de importa��o de XML de nota fiscal eletr�nica, referente ao conhecimento
				 do transporte, para alterar o c�digo do produto que identifica o  frete que ser� gravado na nota fiscal de 
				 entrada.
				 LOCALIZA��O: Fun��o ImpXML_Cte - respons�vel pelo processamento do arquivo xml CT-e para gravar os registros 
				 nas tabelas SDS e SDT.
				 EM QUE PONTO: Ap�s a leitura do arquivo na pasta xmlnfe/new e identifica��o se a Empresa � remetente ou desti-
				 nat�ria da nota. Chamado 13990
===============================================================================================================================
Parametros------: oXML := Objeto contendo a estrutura do arquivo XML referente ao conhecimento do transporte
===============================================================================================================================
Retorno---------: cPrdFrete - Retorna o c�digo do produto que deve ser considerado para grava��o da nota fiscal de entrada.
===============================================================================================================================
*/

User function A116PRDF()    

Local _aArea 	:= GetArea()
Local _oXML 	:= PARAMIXB[1]
Local _aPrdFrete:= {}
Local _cPrdFrete:= ""
Local _aAux1	:= {}
Local _cAlias	:= ""
Local _cCGCDes	:= ''
Local _cTagDest := ''
Local _nI		:= 0
Local _cChaveNF	:= ''

_aPrdFrete := StrTokArr(SuperGetMV("MV_XMLPFCT",.F.,""),";")

If Upper(_oXML:RealName) == "CTEOS" // Garanto que n�o executar� nenhuma valida��o para CTeOs
	//Produto exclusivo para o CTeOS
	_cPrdFrete := _aPrdFrete[4]
Else //CTe
	//Definido que a opera��o padr�o � um frete sobre compras
	_cPrdFrete := _aPrdFrete[2]
	
	If ValType( XmlChildEx( _oXML:_InfCte:_Ide , "_TOMA4" ) ) <> "U" .And. AllTrim( _oXML:_InfCte:_Ide:_Toma4:_TOMA:Text ) == "4"
		_cTagDest	:= If( ValType( XmlChildEx(	_oXML:_InfCte:_Ide:_Toma4	, "_CNPJ" ) ) == "O" , "_CNPJ" , "_CPF" )
		_cCGCDes	:= AllTrim( XmlChildEx(_oXML:_InfCte:_Ide:_Toma4	, _cTagDest ):Text )
	ElseIf ValType(XmlChildEx(_oXML:_InfCte,"_DEST")) == "O"
		_cTagDest	:= If(ValType(XmlChildEx(_oXML:_InfCte:_Dest , "_CNPJ" ) ) == "O","_CNPJ","_CPF")
		_cCGCDes 	:= AllTrim( XmlChildEx(_oXML:_InfCte:_Dest , _cTagDest ):Text )
	ElseIf ValType(XmlChildEx(_oXML:_InfCte,"_EXPED")) == "O"
		_cTagDest	:= If(ValType(XmlChildEx(_oXML:_InfCte:_Exped , "_CNPJ" ) ) == "O","_CNPJ","_CPF")
		_cCGCDes 	:= AllTrim( XmlChildEx(_oXML:_InfCte:_Exped , _cTagDest ):Text )
	EndIf

	//====================================================================================================	
	// Se o tomador do servi�o � uma filial diferente da que est� sendo processada, indica que o CT-e �
	// referente � uma transfer�ncia. Produto 10000000014
	//====================================================================================================	
	If SubStr( SM0->M0_CGC , 1 , 8 ) == SubStr( _cCGCDes , 1 , 8 ) .And. AllTrim(SM0->M0_CGC) <> AllTrim(_cCGCDes)
		_cPrdFrete := _aPrdFrete[3]
	Else
	    _aAux1 := {}
	    If ValType( XmlChildEx(	_oXML:_INFCTE , "_INFCTENORM" ) ) <> 'U'
	       	If ValType( XmlChildEx(	_oXML:_INFCTE:_INFCTENORM , '_INFDOC' ) ) <> 'U'
		    	If ValType( XmlChildEx(	_oXML:_INFCTE:_INFCTENORM:_INFDOC , '_INFNFE' ) ) <> 'U'
		    		_aAux1 := IIf( ValType( XmlChildEx(	_oXML:_INFCTE:_INFCTENORM:_INFDOC , "_INFNFE" ) ) == "O" , { _oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE } , _oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE )
		    	EndIf
	    	EndIf
		ElseIf ValType( XmlChildEx(	_oXML:_INFCTE , "_INFCTESUB" ) ) <> 'U'
			_aAux1 := IIf( ValType( XmlChildEx(	_oXML:_INFCTE , "_INFCTESUB"	) ) == "O" , { _oXML:_INFCTE:_INFCTESUB	} , _oXML:_INFCTE:_INFCTESUB	)
		ElseIf ValType( XmlChildEx(	_oXML:_INFCTE , "_INFCTECOMP" ) ) <> 'U'
			_aAux1 := IIf( ValType( XmlChildEx(	_oXML:_INFCTE , "_INFCTECOMP"	) ) == "O" , { _oXML:_INFCTE:_INFCTECOMP	} , _oXML:_INFCTE:_INFCTECOMP	)
		ElseIf ValType( XmlChildEx(	_oXML:_INFCTE , "_INFCTEANU" ) ) <> 'U'
			_aAux1 := IIf( ValType( XmlChildEx(	_oXML:_INFCTE , "_INFCTEANU"	) ) == "O" , { _oXML:_INFCTE:_INFCTEANU	} , _oXML:_INFCTE:_INFCTEANU	)
		EndIf
		
		If !Empty( _aAux1 )
			For _nI := 1 To Len( _aAux1 )
				If ValType(XmlChildEx(_aAux1[_nI],"_CHAVE")) == "O"
					_cChaveNF := Padr( AllTrim( _aAux1[_nI]:_chave:Text ) , TamSX3("F1_CHVNFE")[1] )
				ElseIf ValType(XmlChildEx(_aAux1[_nI],"_CHCTE")) == "O"
					_cChaveNF := Padr( AllTrim( _aAux1[_nI]:_chCTE:Text ) , TamSX3("F1_CHVNFE")[1] )
				EndIF
				//====================================================================================================
				// Se alguma chave estiver referenciada no documento de sa�da, � um frete sobre venda.
				// N�o � necess�rio se preocupar com a filial nesse PE. Produto 10000000005
				//====================================================================================================
				_cAlias := GetNextAlias()
				BeginSQL Alias _cAlias
					SELECT COUNT(1) QTDREG
					  FROM %Table:SF2% SF2
					 WHERE SF2.D_E_L_E_T_ = ' '
					   AND SF2.F2_CHVNFE = %exp:_cChaveNF%
				EndSql
				If (_cAlias)->QTDREG > 0
					_cPrdFrete := _aPrdFrete[1]
					(_cAlias)->(DBCloseArea())
					Exit
				EndIf
				(_cAlias)->(DBCloseArea())
			Next _nI
		EndIf
	EndIf
EndIf

_cPrdFrete := PadR(_cPrdFrete,TamSX3("B1_COD")[1])
RestArea(_aArea)

Return _cPrdFrete
