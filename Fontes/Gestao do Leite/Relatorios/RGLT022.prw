/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 25/02/2019 | Tratamento para recep��es diferentes, por�m com mesmo c�digo de ticket. Chamado 28328 e 28329
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 26/07/2019 | Corrigida a barra de progresso. Help 28346
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 12/03/2020 | Criado tratamento para data de movimenta��o de estoque. Chamado 32266
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: RGLT022
Autor-------------: Abrahao P. Santos
Data da Criacao---: 29/01/2009
===============================================================================================================================
Descri��o---------: Relat�rio de Falta de Leite
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGLT022()

Local oReport
Pergunte("RGLT022",.F.)
//Inferface de Impress�o
oReport := ReportDef()
oReport:PrintDialog()

Return

/*
===============================================================================================================================
Programa----------: ReportDef
Autor-------------: Erich Buttner
Data da Criacao---: 27/03/2013
===============================================================================================================================
Descri��o---------: Defini��o do Componente
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportDef()

Local oReport
Local oSection
Local _aOrdem   := {"Por Fretista"}

//Criacao do componente de impressao
//TReport():New
//ExpC1 : Nome do relatorio
//ExpC2 : Titulo
//ExpC3 : Pergunte
//ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao
//ExpC5 : Descricao

oReport := TReport():New("RGLT022","Falta de Leite no per�odo","RGLT022",;
{|oReport| ReportPrint(oReport,_aOrdem)},"Apresenta as faltas de leite do transportador no per�odo informado")
oSection := TRSection():New(oReport,"Movimentos"	,/*uTable {}*/, _aOrdem/*aOrder*/, .F./*lLoadCells*/, .T./*lLoadOrder*/,"Total das Filiais: "/*uTotalText*/)

oSection:SetTotalInLine(.F.)

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
TRCell():New(oSection,"ZL2_FILIAL","ZL2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZL2_COD","ZL2","Setor"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZL2_DESCRI","ZL2",/*cTitle*/,/*Picture*/,35/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"FRETISTA",/*Tabela*/,"Transportador"/*cTitle*/,/*Picture*/,13/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"A2_NOME","SA2",/*cTitle*/,/*Picture*/,35/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZLD_TICKET","ZLD",/*cTitle*/,/*Picture*/,10/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"ZLD_DTCOLE","ZLD","Data"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"D3_EMISSAO","SD3","Estoque"/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"LINHAS",/*Tabela*/,"Linhas"/*cTitle*/,/*Picture*/,50/*Tamanho*/,/*lPixel*/,/*Block*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"FISICO",/*Tabela*/,"Vol. F�sico", "@E 9,999,999,999" ,12,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"COLETADO",/*Tabela*/,"Vol. Coleta", "@E 9,999,999,999" ,12,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection,"DIFERENCA",/*Tabela*/,"Diferen�a", "@E 9,999,999,999" ,12,/*lPixel*/,/*{||bBlock}*/,/*cAlign*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

Return oReport

/*
===============================================================================================================================
Programa----------: ReportPrint
Autor-------------: Erich Buttner
Data da Criacao---: 27/03/2013
===============================================================================================================================
Descri��o---------: Relacao Rota/Linha
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function ReportPrint(oReport,_aOrdem)

Local _cFiltro		:= "%"
Local _cCampo		:= "%"
Local _cTabela		:= " "
Local _cGroup		:= "%"
Local _cOrder		:= "%"
Local _cAlias		:= ""
Local _cAux			:= IIf( MV_PAR08 == 1 , "ZLD" , "ZLW" )//1-Produtor 2-Cooperativa
Local _aSelFil		:= {}
Local _nOrdem		:= oReport:Section(1):GetOrder() //1-Por Fretista
Local _lPlanilha 	:= oReport:nDevice == 4
Local _cFilial		:= ""
Local _cFret		:= ""
Local _cNome		:= ""
Local _cSetor		:= ""
Local _nCountRec	:= 0

//Chama fun��o que permitir� a sele��o das filiais
If MV_PAR10 == 1
	If Empty(_aSelFil)
		_aSelFil := AdmGetFil(.F.,.F.,_cAux)
	Endif
Else
	Aadd(_aSelFil,cFilAnt)
Endif

//=====================================================
// Adiciona a ordem escolhida ao titulo do relatorio  |
//=====================================================
oReport:SetTitle(oReport:Title() + " ("+AllTrim(_aOrdem[_nOrdem])+") ")

//==========================================================================
// Transforma parametros Range em expressao SQL                             	
//==========================================================================
MakeSqlExpr(oReport:uParam)

//================================================================================
//| Configura��o das quebras do relat�rio                                        |
//================================================================================
oQbrFret	:= TRBreak():New( oReport:Section(1)/*oParent*/, oReport:Section(1):Cell("FRETISTA") /*uBreak*/, {||"Total do Fretista: " + _cFret +" " + _cNome} /*uTitle*/, .F. /*lTotalInLine*/,/*cName*/,.F./*lPageBreak*/)
TRFunction():New(oReport:Section(1):Cell("FISICO")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFret/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("COLETADO")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFret/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("DIFERENCA")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFret/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)

oQbrFilial	:= TRBreak():New( oReport:Section(1)/*oParent*/, oReport:Section(1):Cell("ZL2_FILIAL")/*uBreak*/, {||"Total da Filial: " + _cFilial + ' - '+ FWFilialName(cEmpAnt,_cFilial,1 )}/*uTitle*/, .F. /*lTotalInLine*/,/*cName*/,.T./*lPageBreak*/)
TRFunction():New(oReport:Section(1):Cell("FISICO")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFilial/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("COLETADO")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFilial/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)
TRFunction():New(oReport:Section(1):Cell("DIFERENCA")/*oCell*/,/*cName*/,"SUM"/*cFunction*/,oQbrFilial/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,/*oParent*/,/*bCondition*/,/*lDisable*/,/*bCanPrint*/)

//==========================================================================
// Trata as c�lulas a serem exibidas de acordo com sess�o e par�metros
//==========================================================================
oReport:Section(1):Cell("ZLD_DTCOLE"):SetBlock({||STOD((_cAlias)->DTCOLETA) })
oReport:Section(1):Cell("ZLD_TICKET"):SetBlock({||(_cAlias)->TICKET })
oReport:Section(1):Cell("DIFERENCA"):SetBlock({||(_cAlias)->(FISICO-COLETADO) })

If !_lPlanilha
	oReport:Section(1):Cell("A2_NOME"):Disable()
	oReport:Section(1):Cell("ZL2_DESCRI"):Disable()
EndIf

//====================================================================================================
// Monta filtro de acordo com a tabela de origem
//====================================================================================================
_cTabela := "%" + RetSqlName(_cAux) +" E %"
_cFiltro += " AND E."+ _cAux +"_SETOR = ZL2.ZL2_COD"
_cFiltro += " AND E."+ _cAux +"_FILIAL = ZL2.ZL2_FILIAL"
_cFiltro += " AND D3_L_ORIG (+)= E."+ _cAux +"_TICKET"
_cFiltro += " AND E."+ _cAux +"_DTCOLE BETWEEN '"+ DTOS(MV_PAR01) +"' AND '"+ DTOS(MV_PAR02) +"' "
_cFiltro += " AND E."+ _cAux +"_FILIAL "+ GetRngFil( _aSelFil, _cAux, .T.,)

//Se preencheu os setores, j� fiz a valida��o de acesso no SX1
//Se n�o preencheu e n�o tem acesso a todos, filtra de forma que n�o retorme registros
If !Empty(MV_PAR03) .Or. Empty(MV_PAR03) .And. Posicione("ZLU",1,xFilial("ZLU")+RetCodUsr(),"ZLU_SETALL") <> 'S'
	_cFiltro += " AND ZL2.ZL2_COD IN "+ FormatIn( AllTrim(MV_PAR03) , ';' )
EndIf
_cFiltro += " AND E."+ _cAux +"_FRETIS = SA2.A2_COD"
_cFiltro += " AND E."+ _cAux +"_LJFRET = SA2.A2_LOJA"

//Verifica se foi fornecido o filtro de linha
If !Empty(MV_PAR09)
	_cFiltro += " AND E."+ _cAux +"_LINROT IN "+ FormatIn(MV_PAR09,";")
EndIf

_cFiltro += " AND EXISTS (SELECT 1 "
_cFiltro += "FROM " + RetSqlName(_cAux) + " D "
_cFiltro += "WHERE D.D_E_L_E_T_ = ' ' "
_cFiltro += "AND D." + _cAux + "_FILIAL = ZL2_FILIAL "
_cFiltro += "AND D."+ _cAux +"_DTCOLE BETWEEN '"+ DTOS(MV_PAR01) +"' AND '"+ DTOS(MV_PAR02) +"' "
_cFiltro += "AND (CASE WHEN D3_EMISSAO IS NULL THEN D."+ _cAux +"_DTCOLE ELSE D3_EMISSAO END) BETWEEN '"+ DTOS(MV_PAR11) +"' AND '"+ DTOS(MV_PAR12) +"' "
_cFiltro += "AND D." + _cAux + "_SETOR = E." + _cAux + "_SETOR "
_cFiltro += "AND D." + _cAux + "_TICKET = E." + _cAux + "_TICKET HAVING "
_cFiltro += "E." + _cAux + "_CODREC = MIN(D." + _cAux + "_CODREC)) "
         
_cCampo +=  "E." + _cAux + "_TICKET TICKET, " + "E." + _cAux + "_DTCOLE DTCOLETA, "
_cCampo +=  "(SELECT MAX(A." + _cAux + "_TOTBOM) "
_cCampo +=  "FROM " + RetSqlName(_cAux) + " A "
_cCampo +=  "WHERE A.D_E_L_E_T_ = ' '
_cCampo +=  "AND A." + _cAux + "_FILIAL = ZL2_FILIAL "
_cCampo +=  "AND A." + _cAux + "_TICKET = E." + _cAux + "_TICKET "
_cCampo +=  "AND A." + _cAux + "_SETOR = ZL2_COD) FISICO, "
_cCampo +=  "(SELECT SUM(B." + _cAux + "_QTDBOM) "
_cCampo +=  "FROM " + RetSqlName(_cAux) + " B "
_cCampo +=  "WHERE B.D_E_L_E_T_ = ' '
_cCampo +=  "AND B." + _cAux + "_FILIAL = ZL2_FILIAL "
_cCampo +=  "AND B." + _cAux + "_TICKET = E." + _cAux + "_TICKET "
_cCampo +=  "AND B." + _cAux + "_SETOR = ZL2_COD) COLETADO, "
_cCampo +=  "(SELECT LISTAGG(LINROT, '-') WITHIN GROUP(ORDER BY LINROT) "
_cCampo +=  "FROM (SELECT C." + _cAux + "_LINROT LINROT "
_cCampo +=  "FROM " + RetSqlName(_cAux) + " C "
_cCampo +=  "WHERE C.D_E_L_E_T_ = ' ' "
_cCampo +=  "AND C." + _cAux + "_FILIAL = ZL2_FILIAL "
_cCampo +=  "AND C." + _cAux + "_TICKET = E." + _cAux + "_TICKET "
_cCampo +=  "AND C." + _cAux + "_SETOR = ZL2_COD "
_cCampo +=  "GROUP BY C." + _cAux + "_LINROT)) LINHAS %"

_cFiltro += "%"
_cGroup += "E."+_cAux +"_TICKET, E."+ _cAux +"_DTCOLE %"
_cOrder += "E."+_cAux +"_DTCOLE, E."+ _cAux +"_TICKET %"

//==========================================================================
// Query do relat�rio da secao 1                                            
//==========================================================================
oReport:Section(1):BeginQuery()	
_cAlias := GetNextAlias()

oReport:SetMsgPrint("Consultando registros no Banco de Dados")
oReport:SetMeter(0)

BeginSql alias _cAlias
SELECT ZL2_FILIAL, A2_COD || ' - ' || A2_LOJA FRETISTA, A2_NOME, ZL2_COD, ZL2_DESCRI, D3_EMISSAO, %exp:_cCampo% 
    FROM %table:SA2% SA2, %table:ZL2% ZL2, %exp:_cTabela%, %table:SD3% SD3
         WHERE ZL2.D_E_L_E_T_ = ' '
           AND SA2.D_E_L_E_T_ = ' '
           AND E.D_E_L_E_T_ = ' '
		   AND SD3.D_E_L_E_T_ (+) = ' '
           %exp:_cFiltro%
           AND A2_FILIAL = %xFilial:SA2%
           AND D3_FILIAL (+) = ZL2_FILIAL
		   AND D3_ESTORNO (+) = ' '
           AND A2_COD BETWEEN %exp:MV_PAR04% AND %exp:MV_PAR05%
           AND A2_LOJA BETWEEN %exp:MV_PAR06% AND %exp:MV_PAR07%
 GROUP BY ZL2_FILIAL, A2_COD, A2_LOJA, A2_NOME, ZL2_COD, ZL2_DESCRI, D3_EMISSAO, %exp:_cGroup%
 ORDER BY ZL2_FILIAL, A2_COD, A2_LOJA, %exp:_cOrder% 
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
	oReport:Section(1):PrintLine()
	oReport:IncMeter()
	_cFilial := (_cAlias)->ZL2_FILIAL
	_cSetor	:= (_cAlias)->ZL2_COD + ' - ' + (_cAlias)->ZL2_DESCRI
	_cFret	:= (_cAlias)->FRETISTA
	_cNome:= (_cAlias)->A2_NOME
	(_cAlias)->(DbSkip())
EndDo

oReport:Section(1):Finish()
(_cAlias)->(dbCloseArea())

Return