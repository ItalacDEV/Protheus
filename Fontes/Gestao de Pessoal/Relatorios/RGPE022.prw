/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Igor Melga�o  |14/02/2022| Chamado 39170. Adicionado agrupamento e total por Funcion�rio
Igor Melga�o  |16/02/2022| Chamado 39170. Adi��o de filtro na query para o campo RA_CATFUNC
Lucas Borges  |08/10/2024| Chamado 48465. Retirada manipula��o do SX1
===============================================================================================================================
*/
#include "report.ch"
#include "protheus.ch" 
#include "topconn.ch"

Static _cAlias := ""
/*
===============================================================================================================================
Programa----------: RGPE022
Autor-------------: Igor Melga�o
Data da Criacao---: 13/01/2022
===============================================================================================================================
Descri��o---------: Relatorio de Verba - Chamado 38872
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGPE022()
Private oReport		:= Nil
Private oSecEntr_1	:= Nil

Private _aOrd		:= {} 

Private _cPerg		:= "RGPE022"
Private _nCont		:= 0

Pergunte( _cPerg , .T. )

DEFINE REPORT oReport	NAME		_cPerg ;
						TITLE		"Relatorio de Verba" ;
						PARAMETER	_cPerg ;
						ACTION		{|oReport| RGPE022PR( oReport ) } ;
						Description	"Este relat�rio emitir� a rela��o de Verba por Data de Pagamento."

//====================================================================================================
// Seta Padrao de impressao como Paisagem
//====================================================================================================
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)

oReport:nFontBody	:= 08
oReport:cFontBody	:= "Courier New"
oReport:nLineHeight	:= 45 // Define a altura da linha.

If mv_par03 == 1

    DEFINE SECTION oSecEntr_1 OF oReport TITLE "Por Filial" TABLES "SRD" //ORDERS _aOrd
	DEFINE CELL NAME "RD_FILIAL"	OF oSecEntr_1 ALIAS "SRD"  TITLE "Filial"	  			SIZE 02
	DEFINE CELL NAME "RD_VALOR"	    OF oSecEntr_1 ALIAS "SRD"  TITLE "Vlr. Total"			SIZE 20 PICTURE "@E 99,999,999,999.99" 

ElseIf mv_par03 == 2

	DEFINE SECTION oSecEntr_1 OF oReport TITLE "Por Funcion�rio"  TABLES "SRD"  //ORDERS _aOrd
	DEFINE CELL NAME "RD_FILIAL"	OF oSecEntr_1 ALIAS "SRD"  TITLE "Filial"	  			SIZE 02
	DEFINE CELL NAME "RD_MAT"	    OF oSecEntr_1 ALIAS "SRD"  TITLE "Matricula"		    SIZE 10
	DEFINE CELL NAME "RA_NOME"	    OF oSecEntr_1 ALIAS "SRA"  TITLE "Nome"		            SIZE 50
    DEFINE CELL NAME "RD_VALOR"	    OF oSecEntr_1 ALIAS "SRD"  TITLE "Valor"    			SIZE 20 PICTURE "@E 99,999,999,999.99" 

    //DEFINE FUNCTION FROM oSecEntr_1:Cell("RD_VALOR")  FUNCTION SUM  TITLE "Valor"    			//SIZE 20 PICTURE "@E 99,999,999,999.99" //BLOCK{||IIF(MV_PAR14 == 2,(_cAliasQRY)->VALBRUT,(_cAliasQRY)->VALBRUT*(((_cAliasQRY)->VALMERC-(_cAliasQRY)->TOTDEV)/(_cAliasQRY)->VALMERC))}
    //TRFunction():New(/*Cell*/,/*cId*/,/*Function*/,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,/*Section*/)
    TRFunction():New(oSecEntr_1:Cell("RD_VALOR"),,"SUM",,,"@E 99,999,999,999.99",,.F.,.T.,.F.,oSecEntr_1)

Else

	DEFINE SECTION oSecEntr_1 OF oReport TITLE "Por Funcionario, Verba e Data de Pagto"  TABLES "SRD"  //ORDERS _aOrd
	DEFINE CELL NAME "RD_FILIAL"	OF oSecEntr_1 ALIAS "SRD"  TITLE "Filial"	  			SIZE 02
	DEFINE CELL NAME "RD_MAT"	    OF oSecEntr_1 ALIAS "SRD"  TITLE "Matricula"		    SIZE 10
	DEFINE CELL NAME "RA_NOME"	    OF oSecEntr_1 ALIAS "SRA"  TITLE "Nome"		            SIZE 50
	DEFINE CELL NAME "RD_PD"	    OF oSecEntr_1 ALIAS "SRD"  TITLE "Verba"    		    SIZE 10
    DEFINE CELL NAME "RD_DATPGT"	OF oSecEntr_1 ALIAS "SRD"  TITLE "Data Pagto"		    SIZE 10
    DEFINE CELL NAME "RD_VALOR"	    OF oSecEntr_1 ALIAS "SRD"  TITLE "Valor"    			SIZE 20 PICTURE "@E 99,999,999,999.99" 

    //TRFunction():New(/*Cell*/,/*cId*/,/*Function*/,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,/*Section*/)
    TRFunction():New(oSecEntr_1:Cell("RD_VALOR"),,"SUM",,,"@E 99,999,999,999.99",,.F.,.T.,.F.,oSecEntr_1)

EndIf

oSecEntr_1:Disable()

oReport:PrintDialog()

Return()

/*
===============================================================================================================================
Programa----------: RGPE022PR
Autor-------------: Igor Melga�o
Data da Criacao---: 13/01/2022
===============================================================================================================================
Descri��o---------: Executa relat�rio
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RGPE022PR( oReport )
Local _cFiltro := "% "

_cAlias     := GetNextAlias()

oSecEntr_1:Enable()

If !empty(MV_PAR01)

	_cFiltro += " AND RD_FILIAL IN " + FormatIn(MV_PAR01,";") 
	
Endif

If Alltrim(MV_PAR02) <> "*"

	_cFiltro += " AND RD_PD IN " + FormatIn(RGPE022VER(MV_PAR02),";") 
	
EndIf

If !empty(MV_PAR04)

    _cFiltro += " AND RD_DATPGT BETWEEN '" + DTOS(MV_PAR04) + "' AND '" + DTOS(MV_PAR05) + "' "

EndIf

_cFiltro += " AND RA_CATFUNC <> 'A' "

_cFiltro += " %"

If mv_par03 == 1

	oReport:SetTitle( "Relatorio de Verba - Por Filial" )

	//====================================================================================================
	// Executa query para consultar Dados
	//====================================================================================================
	BEGIN REPORT QUERY oSecEntr_1

		BeginSql Alias _cAlias
			
			SELECT RD_FILIAL, SUM(RD_VALOR) RD_VALOR
			FROM %table:SRD% SRD
                JOIN %table:SRA% SRA
				ON (SRA.RA_FILIAL = SRD.RD_FILIAL AND SRA.RA_MAT = SRD.RD_MAT AND SRA.%notDel%)
			WHERE SRD.%notDel%
              %Exp:_cFiltro%
            GROUP BY RD_FILIAL 
			ORDER BY RD_FILIAL

		EndSql
		
    END REPORT QUERY oSecEntr_1

ElseIf mv_par03 == 2

	oReport:SetTitle( "Relatorio de Verba - Por Funcion�rio" )

	//====================================================================================================
	// Executa query para consultar Dados
	//====================================================================================================
	BEGIN REPORT QUERY oSecEntr_1

		BeginSql Alias _cAlias
			
			SELECT RD_FILIAL, RD_MAT, SUM(RD_HORAS) RD_HORAS, SUM(RD_VALOR) RD_VALOR, RA_NOME
			FROM %table:SRD% SRD
                JOIN %table:SRA% SRA
                ON (SRA.RA_FILIAL = SRD.RD_FILIAL AND SRA.RA_MAT = SRD.RD_MAT AND SRA.%notDel%)
			WHERE SRD.%notDel%
              %exp:_cFiltro%
			GROUP BY RD_FILIAL, RD_MAT, RA_NOME
            ORDER BY RD_FILIAL, RD_MAT

		EndSql
		 
	END REPORT QUERY oSecEntr_1

Else

	oReport:SetTitle( "Relatorio de Verba - Por Funcionario, Verba e Data de Pagto" )

	//====================================================================================================
	// Executa query para consultar Dados
	//====================================================================================================
	BEGIN REPORT QUERY oSecEntr_1

		BeginSql Alias _cAlias
			
			SELECT RD_FILIAL, RD_MAT, RD_PD, RD_HORAS, RD_DATPGT, RD_VALOR, RA_NOME
			FROM %table:SRD% SRD
                JOIN %table:SRA% SRA
                ON (SRA.RA_FILIAL = SRD.RD_FILIAL AND SRA.RA_MAT = SRD.RD_MAT AND SRA.%notDel%)
			WHERE SRD.%notDel%
              %exp:_cFiltro%
            ORDER BY RD_FILIAL, RD_MAT, RD_DATPGT, RD_PD

		EndSql
		 
	END REPORT QUERY oSecEntr_1
		

		
EndIf

oSecEntr_1:Print(.T.)

Return()

/*
===============================================================================================================================
Programa----------: RGPE022VER
Autor-------------: Igor Melga�o
Data da Criacao---: 20/01/2022
===============================================================================================================================
Descri��o---------: Fun��o para tratar o MV_PAR02
===============================================================================================================================
Parametros--------: cVerba - Verbas Selecionadas no MV_PAR02
===============================================================================================================================
Retorno-----------: cRet - Rela��o de verbas com tramento efetuado para posterior utiliza��o em query
===============================================================================================================================
*/
Static Function RGPE022VER(cVerba)
Local cRet := ""
Local i := 0

cVerba := Alltrim(cVerba)

For i := 1 To Len(cVerba)
    cRet += Subs(cVerba,i,1)
    If Mod(i,3) = 0
        cRet += ";"
    EndIf
Next

Return(cRet)
