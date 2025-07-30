/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor         |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz     | 09/05/2018 | Padroniza��o dos cabe�alhos dos fontes e fun��es do m�dulo financeiro. Chamado 24726.
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 11/01/2019 | Novo bot�o "Ocorrencia de frete" . Chamado 27267
-------------------------------------------------------------------------------------------------------------------------------
 Jerry         | 29/09/2021 | Adicionar campos novos da Ocorr�ncia de Frete. Chamado 37679.
-------------------------------------------------------------------------------------------------------------------------------
 Jerry         | 05/08/2022 | Adicionar o campo Data Inicial. Chamado 40929
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa--------: F040BUT
Autor-----------: Alexandre Villar
Data da Criacao-: 14/01/2016
===============================================================================================================================
Descri��o-------: P.E. para inclus�o de bot�es na tela de manuten��o dos t�tulos a receber no Financeiro
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function F040BUT()

	Local _aRotAux := {}

	Aadd( _aRotAux , { "Hist�rico" , {|| U_AFIN005() } , "Hist�rico..." , "Hist�rico" } )

	Aadd( _aRotAux , { "FRETE", {|| U_FA4OcoFrete() }, "Ocorrencia de frete"})


Return( _aRotAux )

USER FUNCTION FA4OcoFrete()
	LOCAL _aCols  :={},C
	LOCAL _aHeader:={}
	LOCAL _aSizes :={         20,         20,          40,         35,          45,          45,         40,          40,          40,          40,          40,          40,          40,         40,         20 ,        20}
	LOCAL _aCampos:={'ZF5_DOCOC','ZF5_SEROC',"ZF5_STATUS","ZF5_DTINI","ZF5_DTOCOR","ZF5_MOTIVO","ZF5_MOTCUS","ZF5_CUSTO","ZF5_CUSTOC","ZF5_CUSTOI","ZF5_CUSTOR","ZF5_CUSTOC","ZF5_CUSTOT","ZF5_CUSTER","ZF5_DTFIN","ZF5_MERENT","ZF5_SITENT"}
	LOCAL _cEntr  := ""

 
	IF EMPTY(M->E1_NUM)
		U_ITMSG("Digite o No. do Titulo",'Aten��o!',,1)
		RETURN .F.
	ENDIF
 
	ZF5->(DBSETORDER(1))
	IF ZF5->(DBSEEK(xFilial("SE1")+M->E1_NUM))

		FOR C := 1 TO LEN(_aCampos)
			AADD(_aHeader, AVSX3(_aCampos[C],5) )
		NEXT

		DO WHILE ZF5->(!EOF()) .AND. xFilial("SE1")+M->E1_NUM == ZF5->ZF5_FILIAL+ZF5->ZF5_DOCOC
			AADD(_aCols, ARRAY(LEN(_aCampos)) )
			FOR C := 1 TO LEN(_aCampos)
				IF !_aCampos[C] $ "ZF5_STATUS"
					_xValor:=ZF5->( FIELDGET(FIELDPOS( _aCampos[C] )) )
					IF ValType(_xValor) = "N"
						_aCols[LEN(_aCols),C]:=TransForm(_xValor, PesqPict('ZF5', _aCampos[C]) )
					ELSEIF ValType(_xValor) = "D"
						_aCols[LEN(_aCols),C]:=DTOC(_xValor)
					ELSE
						_aCols[LEN(_aCols),C]:=ALLTRIM(_xValor)
					endif
               //inicio
               IF ALLTRIM(_aCampos[C]) == "ZF5_SITENT"
		   	      If ZF5->ZF5_SITENT == "P"
			   	      _cEntr := "PARCIAL"
				      ELSEIF ZF5->ZF5_SITENT == "I"
						   _cEntr := "INTEGRAL"
   					ELSE
						   _cEntr := " "
   					ENDIF
	   				_aCols[LEN(_aCols),C]:= _cEntr
               ENDIF
               //fim
				ELSEIF ALLTRIM(_aCampos[C]) == "ZF5_STATUS"
					_aCols[LEN(_aCols),C]:=ALLTRIM(Posicione("ZFD",1,xFilial("ZFD")+ZF5->ZF5_STATUS,"ZFD_DESCRI"))
				ENDIF
			NEXT
			ZF5->(DBSKIP())
		ENDDO
	ELSE
		U_ITMSG("N�o existem ocorrencias de frete para o Numero: "+M->E1_NUM,'Aten��o!',,1)
	ENDIF

	IF LEN(_aCols) > 0

		_cTitAux:="OCORENCIAS DE FRETE"
//   ITLISTBOX( _cTitAux,_aHeader , _aCols , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons
		U_ITLISTBOX( _cTitAux,_aHeader , _aCols, .T.       , 1      ,          ,          ,_aSizes , )
	ENDIF

RETURN
