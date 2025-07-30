/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Andre Lisboa  | 08/08/2017 | Correcao no array aprod para SPED Fiscal - Chamado 21119
-------------------------------------------------------------------------------------------------------------------------------
Andre Lisboa  | 17/08/2017 | Correcao no array aprod para EFD Contribuicoes - Chamado 21150
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 02/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "protheus.ch"

/*
===============================================================================================================================
Programa----------: SPEDPROD
Autor-------------: Andre Lisboa
Data da Criacao---: 07/10/2016
===============================================================================================================================
Descrição---------: Ponto de Entrada para retorna Array de Informações do Produto - SPED Fiscal
===============================================================================================================================
Parametros--------: cAliasSFT 	- Alias da tabela SFT filtrada
					cRegsped  	- Nome do registro
					cUnid		- Campo Unidade de Medida do produto
===============================================================================================================================
Retorno-----------: _aProd
===============================================================================================================================
*/
User Function SPEDPROD()

Local cAlias := Iif(Len(paramixb) >= 1 , paramixb[1], '')
Local aProd := {}
Local lFTProduto := .F.
Local lB1Cod := .F.
Local lCodItem := .F.
Local lD2Cod := .F.
Local lCF8Item := .F.
Local cPosPrd := ""
Local cProdut := ""
Local aTipos := {}
Public _cAliSpd := paramixb[1]

Do Case
     //Verifica se o campo FT_PRODUTO existe no alias 
     Case (cAlias)->(FieldPos('FT_PRODUTO')) > 0      	
          lFTProduto := .T.
          cPosPrd := (cAlias)->(FieldPos('FT_PRODUTO'))
     //Verifica se o campo B1_COD existe no alias
     Case (cAlias)->(FieldPos('B1_COD')) > 0
          lB1Cod := .T.
          cPosPrd := (cAlias)->(FieldPos('B1_COD'))
     //Verifica se o campo COD_ITEM existe no alias
     Case (cAlias)->(FieldPos('COD_ITEM')) > 0
          lCodItem := .T.
          cPosPrd := (cAlias)->(FieldPos('COD_ITEM'))
     //Verifica se o campo D2_COD existe no alias
     Case (cAlias)->(FieldPos('D2_COD')) > 0
          lD2Cod := .T.
          cPosPrd := (cAlias)->(FieldPos('D2_COD'))
     //Verifica se o campo CF8_ITEM existe no alias
     Case (cAlias)->(FieldPos('CF8_ITEM')) > 0 
          lCF8Item := .T.
          cPosPrd := (cAlias)->(FieldPos('CF8_ITEM'))          
EndCase

cProdut:=(cAlias)->(FieldGet(cPosPrd)) 

If Funname() == "FISA008" .or. Funname() == "FISA001" .OR. (PROCNAME(2) == "REGT007" .AND. FUNNAME() == "EXTFISXTAF")

aProd:={"","","","","","","","","","",""}
	
	SB1->(DBSETORDER(1))
	IF SB1->(DBSEEK(xFilial("SB1")+cProdut))
		
		aProd[01]:=SB1->B1_COD
		aProd[02]:=SB1->B1_DESC
		aProd[03]:=SB1->B1_CODBAR
		aProd[04]:=SB1->B1_CODANT
		aProd[05]:=SB1->B1_UM
		aProd[06]:=""
		aProd[07]:=SB1->B1_POSIPI
		aProd[08]:=SB1->B1_EX_NCM
		aProd[09]:=Iif(Empty(SB1->B1_CODISS),Left(SB1->B1_POSIPI,2),"00" )//Código do gênero do item (2 primeiros caracteres do NCM obs.:(se for um item de serviço o código do genero é 00))(campo padrão B1_POSIPI)
		aProd[10]:=SB1->B1_CODISS
		aProd[11]:=SB1->B1_PICM
		
		AADD(aTipos,{"ME","00"}) //MERCADORIA PARA REVENDA
		AADD(aTipos,{"MP","01"}) //MATERIA PRIMA
		AADD(aTipos,{"EM","02"}) //EMBALAGEM
		AADD(aTipos,{"PP","03"}) //PRODUTO EM PROCESSO
		_cTipFab := Posicione("SBZ",1,xFilial("SBZ")+ALLTRIM(cProdut),"BZ_I_REVEN")
		If alltrim(_cTipFab) == "S"
			AADD(aTipos,{"PA","00"}) //PRODUTO ACABADO
		ELSE
			AADD(aTipos,{"PA","04"}) //PRODUTO ACABADO
		ENDIF
		AADD(aTipos,{"SP","05"}) //SUBPRODUTO
		AADD(aTipos,{"PI","05"}) //PRODUTO INTERMEDIARIO
		AADD(aTipos,{"MC","07"}) //MATERIAL DE USO E CONSUMO
		AADD(aTipos,{"AI","08"}) //ATIVO IMOBILIZADO
		AADD(aTipos,{"MO","09"}) //SERVICOS
		aAdd(aTipos,{"IN","10"})
		aAdd(aTipos,{"OI","10"})
		aAdd(aTipos,{"SV","09"})
		aAdd(aTipos,{"MN","07"})
		
		nTipo := ASCAN(aTipos,{|x| x[1]==SB1->B1_TIPO})
		If nTipo > 0
			aProd[06]:=aTipos[nTipo][2]
		EndIf
		
	ENDIF

ENDIF

Return(aProd)