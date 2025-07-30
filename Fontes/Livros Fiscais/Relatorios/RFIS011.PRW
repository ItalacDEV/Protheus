/*  
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS -                             
===============================================================================================================================
 Autor        |   Data   |                              Motivo                       										 
-------------------------------------------------------------------------------------------------------------------------------
Antonio Neves | 14/03/2024 | Ajustada a query de modo a buscar o IR pela emissão e PCC baixa
Antonio Neves | 19/06/2024 | Ajustado para aparecer valores de pcc ou ir conforme periodo de vencimento ou baixa
Antonio Neves | 27/08/2024 | Chamado 48324  -  Ajustado para adicionar os códigos de retenção da receita e separados os grupos de impostos
Antonio Neves | 04/09/2024 | Chamado 48421  -  Considerar data de contabilização ao invés da data de emissão
Antonio Neves | 17/10/2024 | Chamado 48878  -  Inclusão da Coluna Parcela
===============================================================================================================================


=========================================================================================================================================================
Analista         - Programador       - Inicio     - Envio      - Chamado - Motivo da Alteração
---------------------------------------------------------------------------------------------------------------------------------------------------------
Antonio Neves    -  Igor Melgaço     - 24/10/2024 - 25/10/2024 - 48878   - Inclusão da Coluna Parcela
=========================================================================================================================================================

*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE "rwmake.ch" 

/*
===============================================================================================================================
Programa--------: RFIS011 // U_RFIS011
Autor-----------: Igor Melgaço
Data da Criacao-: 07/11/2023   
===============================================================================================================================
Descrição-------: Relação para extração e integração dos blocos R4010 e R4020. Chamado 41268  
===============================================================================================================================
Parametros------: NENHUM
===============================================================================================================================
Retorno---------: NENHUM
===============================================================================================================================
*/

User Function RFIS011()
Local _aParAux  := {} , nI
Local _aParRet  := {}

MV_PAR01 := Space(200)
MV_PAR02 := CTOD("")
MV_PAR03 := CTOD("")

AADD( _aParAux , { 1 , "Filial"           , MV_PAR01, "@!"  , ""  ,"LSTFIL", "" , 060 , .F. } ) 
AADD( _aParAux , { 1 , "Emissão de"	 		, MV_PAR02, "@D"	, ""  , ""	   , "" , 50  , .T. } )
AADD( _aParAux , { 1 , "Emissão ate" 		, MV_PAR03, "@D"	, ""  , ""	   , "" , 50  , .T. } )

For nI := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nI][03] )
Next 

DO WHILE ParamBox( _aParAux , "SELECIONE OS FILTROS" , _aParRet , {|| .T. } , , , , , , , .T. , .T. )
	FWMSGRUN(,{|oproc|  RFIS011PROC(oProc) },'Aguarde processamento...','Lendo dados...')
ENDDO

Return

/*
===============================================================================================================================
Programa--------: RFIS011PROC 
Autor-----------: Igor Melgaço
Data da Criacao-: 07/11/2023   
===============================================================================================================================
Descrição-------: Rotina de Processamento da Listagem. 
===============================================================================================================================
Parametros------: oProc = Objeto da regua de processamento
===============================================================================================================================
Retorno---------: NENHUM
===============================================================================================================================
*/
STATIC Function RFIS011PROC(oproc)
Local _aDados := {}
Local _aCab := {}
Local _aCabXML := {}

_aDados := RFIS011QRY(oproc)

If Len(_aDados) = 0 
    U_ITMSG("Não há dados no periodo.","Envio do E-MAIL",,3)
Else
	_cTitulo := "Previsão REINF 4010-4020 "

	AADD(_aCab,"Bloco")
	AADD(_aCabXML,{_aCab[LEN(_aCab)]   ,1           ,1         ,.F.})
	AADD(_aCab,"Filial")
	AADD(_aCabXML,{_aCab[LEN(_aCab)]   ,1           ,1         ,.F.})
	AADD(_aCab,"Natureza")
	AADD(_aCabXML,{_aCab[LEN(_aCab)]   ,1           ,1         ,.F.})
	AADD(_aCab,"CGC/CPF")
	AADD(_aCabXML,{_aCab[LEN(_aCab)]   ,1           ,1         ,.F.})
	AADD(_aCab,"Cod Forn.")
	AADD(_aCabXML,{_aCab[LEN(_aCab)]   ,1           ,1         ,.F.})
	AADD(_aCab,"Loja")
	AADD(_aCabXML,{_aCab[LEN(_aCab)]   ,1           ,1         ,.F.})
	AADD(_aCab,"Razão Social")
	AADD(_aCabXML,{_aCab[LEN(_aCab)]   ,1           ,1         ,.F.})
	AADD(_aCab,"Título")
	AADD(_aCabXML,{_aCab[LEN(_aCab)]   ,1           ,1         ,.F.})
	AADD(_aCab,"Parcela")
	AADD(_aCabXML,{_aCab[LEN(_aCab)]   ,1           ,1         ,.F.})
	AADD(_aCab,"FAT_BX")
	AADD(_aCabXML,{_aCab[LEN(_aCab)]   ,1           ,1         ,.F.})
	AADD(_aCab,"Dt_Contab")
	AADD(_aCabXML,{_aCab[LEN(_aCab)]   ,1           ,1         ,.F.})
	AADD(_aCab,"Baixa")
	AADD(_aCabXML,{_aCab[LEN(_aCab)]   ,3           ,1         ,.F.})
	AADD(_aCab,"Vr Título")
	AADD(_aCabXML,{_aCab[LEN(_aCab)]   ,3           ,3         ,.F.})
	AADD(_aCab,"IRRF")
	AADD(_aCabXML,{_aCab[LEN(_aCab)]   ,3           ,3         ,.F.})
	AADD(_aCab,"PIS")
	AADD(_aCabXML,{_aCab[LEN(_aCab)]   ,3           ,3         ,.F.})
	AADD(_aCab,"COFINS")
	AADD(_aCabXML,{_aCab[LEN(_aCab)]   ,3           ,3         ,.F.})
	AADD(_aCab,"CSLL")
	AADD(_aCabXML,{_aCab[LEN(_aCab)]   ,3           ,3         ,.F.})
	AADD(_aCab,"Vr Nota Fiscal")
	AADD(_aCabXML,{_aCab[LEN(_aCab)]   ,3           ,3         ,.F.})
	AADD(_aCab,"Cod. Ret. IR")
	AADD(_aCabXML,{_aCab[LEN(_aCab)]   ,1           ,1         ,.F.})
	AADD(_aCab,"Cod. Ret. PCC")
	AADD(_aCabXML,{_aCab[LEN(_aCab)]   ,1           ,1         ,.F.})

						 //             , _aCols   ,_lMaxSiz  ,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab     , bDblClk , _aColXML , bCondMarca )
	U_ITListBox(_cTitulo,_aCab     ,_aDados[1]   , .T.      , 1    ,        ,          ,        ,         ,     ,        ,          , _aCabXML  ,         ,_aDados[2]          ,            )

EndIf

Return 


/*
===============================================================================================================================
Programa--------: RFIS011QRY 
Autor-----------: Igor Melgaço
Data da Criacao-: 07/11/2023   
===============================================================================================================================
Descrição-------: Processamento da Query 
===============================================================================================================================
Parametros------: oProc = Objeto da regua de processamento
===============================================================================================================================
Retorno---------: _aDados = Dados de retorno do processamento da query
===============================================================================================================================
*/
STATIC Function RFIS011QRY(oproc)
Local _cAliasQRY := ''
Local _cFiltro	  := ''
Local _aDados    := {}
Local _aDadosXml := {}
Local _nAtual    := 0
Local _nCol      := 0

_cAliasQRY := GetNextAlias()

_cFiltro += "% "

If !Empty(MV_PAR03)
   _cFiltro += " BETWEEN '"+ DTOS(MV_PAR02) +"' AND '"+ DTOS(MV_PAR03) +"' "
EndIf


If !Empty(ALLTRIM(MV_PAR01))
	_cFiltro += " AND E2_FILIAL IN " +FormatIn(ALLTRIM(MV_PAR01),";")
EndIf


_cFiltro += " %"

BeginSql Alias _cAliasQRY


SELECT BLOCO,
       FILIAL,
	   NATUREZA,
	   CGC,
       COD_FORNECE,
       LOJA,
       RAZAO_SOCIAL,
       TITULO,
	   PREFIXO,
	   PARCELA,
       FAT_BX,
       DT_CONTAB,
       BAIXA,
	   CASE 
	   WHEN SUM(IRRF)>0 AND PESSOA = 'J' AND PREFIXO<>'MAN' AND SUBSTR(COD_FORNECE,1,1) <> 'V' THEN '1708' 
	   WHEN SUM(IRRF)>0 AND PESSOA = 'F' AND PREFIXO = 'MAN' AND SUBSTR(COD_FORNECE,1,1) <> 'V' THEN '3208'
	   WHEN SUM(IRRF)>0 AND SUBSTR(COD_FORNECE,1,1)='V' THEN '8045'
	   ELSE ' ' 
	   END AS CODRET_IR,
	   CASE
	   WHEN SUM(PIS)=0 AND SUM(COFINS)=0 AND SUM(CSLL)>0 THEN '5987'
	   WHEN SUM(PIS)>0 AND SUM(COFINS)>0 AND SUM(CSLL)>0 THEN '5952'
	   ELSE ' ' 
	   END AS CODRET_PCC,
       SUM(VALOR) VAL_TITULO,
       SUM(IRRF) IRRF,
       SUM(PIS) PIS,
       SUM(COFINS) COFINS,
       SUM(CSLL) CSLL,
       SUM(TOT_NF) VAL_NF
FROM
	(
		SELECT 'BLC-4010' BLOCO,
			E2_FILIAL FILIAL,
			E2_NATUREZ NATUREZA,
			A2_CGC CGC,
			E2_FORNECE COD_FORNECE,
			E2_LOJA LOJA,
			E2_NUM TITULO,
			E2_PREFIXO PREFIXO,
			E2_PARCELA PARCELA,
			A2_NOME RAZAO_SOCIAL,
			A2_TIPO PESSOA,
            'FAT' FAT_BX,
			E2_EMIS1 DT_CONTAB,
			E2_BAIXA BAIXA,
			(E2_VALOR+E2_IRRF+E2_PIS+E2_COFINS+E2_CSLL) VALOR,
			E2_IRRF IRRF,
			0 PIS,
			0 COFINS,
			0 CSLL,
			NVL(
					(SELECT SUM(D1_TOTAL)
						FROM
						%table:SD1% SD1 
						WHERE D1_FILIAL = E2_FILIAL
						AND D1_DOC = E2_NUM
						AND D1_SERIE = E2_PREFIXO
						AND D1_FORNECE = E2_FORNECE
						AND D1_LOJA = E2_LOJA
						AND SD1.D_E_L_E_T_ =' '),0
				) TOT_NF

		FROM	%table:SE2% SE2 
			INNER JOIN 	%table:SA2% SA2 ON A2_COD = E2_FORNECE AND A2_LOJA = E2_LOJA AND SA2.D_E_L_E_T_ =' ' AND A2_TIPO='F'
		WHERE 
			SE2.D_E_L_E_T_ =' '
            AND E2_IRRF>0 AND E2_PREFIXO <> 'AUT'
			AND 
            E2_EMIS1  			
			%exp:_cFiltro%

   	
		UNION ALL
		
		SELECT 'BLC-4020' BLOCO,
			E2_FILIAL FILIAL,
			E2_NATUREZ NATUREZA,
			A2_CGC CGC,
			E2_FORNECE COD_FORNECE,
			E2_LOJA LOJA,
			E2_NUM TITULO,
			E2_PREFIXO PREFIXO,
			E2_PARCELA PARCELA,
			A2_NOME RAZAO_SOCIAL,
			A2_TIPO PESSOA,
            'FAT' FAT_BX,
			E2_EMIS1 DT_CONTAB,
			E2_BAIXA BAIXA,
			(E2_VALOR+E2_IRRF+E2_PIS+E2_COFINS+E2_CSLL) VALOR,
			E2_IRRF IRRF,
			0 PIS,
			0 COFINS,
			0 CSLL,
			NVL(
					(SELECT SUM(D1_TOTAL)
						FROM %table:SD1% SD1 
						WHERE D1_FILIAL = E2_FILIAL
						AND D1_DOC = E2_NUM
						AND D1_SERIE = E2_PREFIXO
						AND D1_FORNECE = E2_FORNECE
						AND D1_LOJA = E2_LOJA
						AND SD1.D_E_L_E_T_ =' '),0
				) TOT_NF
				FROM %table:SE2% SE2
			INNER JOIN %table:SA2% SA2 ON A2_COD = E2_FORNECE AND A2_LOJA = E2_LOJA AND SA2.D_E_L_E_T_ =' '	AND A2_TIPO='J'
		WHERE 
			SE2.D_E_L_E_T_ =' '
            AND E2_IRRF>0 AND E2_PREFIXO <>'AUT'
			AND 
			E2_EMIS1  
			%exp:_cFiltro%

		UNION ALL
	
		SELECT 'BLC-4020' BLOCO,
			E2_FILIAL FILIAL,
			E2_NATUREZ NATUREZA,
			A2_CGC CGC,
			E2_FORNECE COD_FORNECE,
			E2_LOJA LOJA,
			E2_NUM TITULO,
			E2_PREFIXO PREFIXO,
			E2_PARCELA PARCELA,
			A2_NOME RAZAO_SOCIAL,
			A2_TIPO PESSOA,
            'BAIXA' FAT_BX,
			E2_EMIS1 DT_CONTAB,
			E2_BAIXA BAIXA,
			(E2_VALOR+E2_IRRF+E2_PIS+E2_COFINS+E2_CSLL) VALOR,
			0 IRRF,
			E2_PIS PIS,
			E2_COFINS COFINS,
			E2_CSLL CSLL,
			NVL(
					(SELECT SUM(D1_TOTAL)
					FROM %table:SD1% SD1 
					WHERE D1_FILIAL = E2_FILIAL
						AND D1_DOC = E2_NUM
						AND D1_SERIE = E2_PREFIXO
						AND D1_FORNECE = E2_FORNECE
						AND D1_LOJA = E2_LOJA
						AND SD1.D_E_L_E_T_ =' '),0) TOT_NF

					FROM %table:SE2% SE2 
			INNER JOIN %table:SA2% SA2  ON A2_COD = E2_FORNECE AND A2_LOJA = E2_LOJA	AND SA2.D_E_L_E_T_ =' ' AND A2_TIPO='J'
		WHERE 
			 SE2.D_E_L_E_T_ =' '
			AND (E2_COFINS>0 OR E2_PIS >0 OR E2_CSLL>0) AND E2_PREFIXO <>'AUT'
			AND E2_BAIXA 
			%exp:_cFiltro%

	)
GROUP BY BLOCO,
         FILIAL,
		 NATUREZA,
		 CGC,
         COD_FORNECE,
         LOJA,
         TITULO,
 		 PREFIXO,
		 PARCELA,
         RAZAO_SOCIAL,
		 PESSOA,
         FAT_BX,
         DT_CONTAB,
         BAIXA,
         VALOR
ORDER BY 1,2,4,8





EndSql

DbSelectArea(_cAliasQRY)
COUNT TO nTotal

(_cAliasQRY)->(DBGoTop())
If !(_cAliasQRY)->(EOF())


	ProcRegua(nTotal)
	Do While !(_cAliasQRY)->(EOF())
		_nAtual++
		AADD(_aDadosXml,{	(_cAliasQRY)->BLOCO,;
						(_cAliasQRY)->FILIAL,;
						(_cAliasQRY)->NATUREZA,;
						(_cAliasQry)->CGC,;
						(_cAliasQRY)->COD_FORNECE,;
						(_cAliasQRY)->LOJA,;
						(_cAliasQRY)->RAZAO_SOCIAL,;
						(_cAliasQRY)->TITULO,;
						(_cAliasQry)->PARCELA,;
						(_CAliasQRY)->FAT_BX,;
						DTOC(STOD((_cAliasQRY)->DT_CONTAB)),;
						DTOC(STOD((_cAliasQRY)->BAIXA)),;
						(_cAliasQRY)->VAL_TITULO,; //11
						(_cAliasQRY)->IRRF,;
						(_cAliasQRY)->PIS,;						
						(_cAliasQRY)->COFINS,;
						(_cAliasQRY)->CSLL,;
						(_cAliasQRY)->VAL_NF,; //16
						IIF(STOD((_cAliasQRY)->DT_CONTAB)<MV_PAR02 .OR. STOD((_cAliasQRY)->DT_CONTAB)>MV_PAR03,' ',(_cAliasQRY)->CODRET_IR),;
						IIF(STOD((_cAliasQRY)->BAIXA)>MV_PAR03,' ',(_cAliasQRY)->CODRET_PCC) })

		AADD(_aDados,_aDadosXml[Len(_aDadosXml)])

		For _nCol := 13 To 18
			_aDados[Len(_aDados),_nCol] := Transform(_aDados[Len(_aDados),_nCol],"@E 99,999,999,999.99")
		Next

		(_cAliasQRY)->(DBSkip())
		
		oproc:cCaption := ("Processando " + cValToChar(_nAtual) + " de " + cValToChar(nTotal) + "...")
		ProcessMessages()
	EndDo
	(_cAliasQRY)->( DBCloseArea() )
EndIf

RETURN {_aDados,_aDadosXml}
