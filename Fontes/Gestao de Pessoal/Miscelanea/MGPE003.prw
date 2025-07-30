/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Josu� Prestes | 21/02/2015 | Chamado 18890. Ajustado filtro para considerar funcionarios demitidos.
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 18/04/2017 | Chamado 19361. Ajustado filtro para considerar funcionarios demitidos dentro do periodo.
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/09/2019 | Chamado 28346. Retirada chamada da fun��o itputx1.
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 12/07/2021 | Chamado 37002. Corrigir a Subtra��o das Notas de devolu��o das notas de vendas funcionarios.
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 01/03/2024 | Chamado 46434. Fernando. Corre��o da coluna TOTAL_DEV para SUM(D1.D1_TOTAL+D1.D1_VALIPI).
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 25/06/2024 | Chamado 47331. Andre. Ajustado para considerar funcionarios demitidos sem cpf em outra matricula.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.Ch"
#INCLUDE "rwmake.ch"

/*
==================================================================================================================================
Programa----------: MGPE003
Autor-------------: Fabiano Dias/Hede
Data da Criacao---: 28/02/2011
==================================================================================================================================
Descri��o---------: Rotina desenvolvida para possibilitar a geracao de arquivo .txt com o somatorio total vendido por funcionario
==================================================================================================================================
Parametros--------: Nenhum
==================================================================================================================================
Retorno-----------: Nenhum
==================================================================================================================================
*/
User Function MGPE003()


Private _cPerg   := "MGPE003"              

Private _cFile
Private _cArqTxt
Private _nHdl  
Private _cEOL    := 	CHR(13)+CHR(10)  

Private _ogeratxt

Begin Sequence 

   pergunte(_cPerg,.F.)

   //===========================================================================
   // Montagem da tela de processamento.                                  
   //===========================================================================
   _lSair:=.T.
   @ 200,1 TO 400,380 DIALOG _ogeratxt TITLE OemToAnsi("Geracao de Arquivo Texto")
   @ 02,03 TO 080,190
   @ 20,018 Say " Este programa ira gerar um arquivo texto, conforme os parametros     "
   @ 40,018 Say " definidos  pelo usuario,  contendo a filial, matr�cula do funcion�rio"
   @ 60,018 Say " e total das compras efetuadas por este no per�odo filtrado.          "

   @ 85,100 BMPBUTTON TYPE 01 ACTION (Processa({|| _lSair:=MGPE003DA() },"Aguarde processando os dados..."), IF(_lSair,_ogeratxt:End(),) )
   @ 85,130 BMPBUTTON TYPE 05 ACTION Pergunte(_cPerg,.T.)      
   @ 85,160 BMPBUTTON TYPE 02 ACTION Close(_ogeratxt)

   Activate Dialog _ogeratxt Centered 

   fClose(_nHdl)

End Sequence 

Return .F.

/*
==================================================================================================================================
Programa----------: MGPE003DA
Autor-------------: Fabiano Dias/Hede
Data da Criacao---: 28/02/2011
==================================================================================================================================
Descri��o---------: Funcao que l� os dados e gera o arquivo
==================================================================================================================================
Parametros--------: Nenhum
==================================================================================================================================
Retorno-----------: Nenhum
==================================================================================================================================
*/
Static Function MGPE003DA() 
                      
Local _cQuery      := ""  
Local _nCountRec   := 0       
Local _cLin 

Private _cAliasSD2:= GetNextAlias()                                                                

cTitle:="Geracao de Arquivo Texto - Hora Inicial: "+TIME()

_cArqTxt := ALLTRIM(AllTrim(MV_PAR06))

If Empty(_cArqTxt) .Or. ! ("TXT" $ UPPER(_cArqTxt))
    U_ITMSG("Local de destino do arquivo ou o nome do arquivo n�o foi informado.","Aten��o",,1)
    Return .F.
EndIf 

_nHdl    := fCreate(_cArqTxt)

If _nHdl == -1

    U_ITMSG("O arquivo de nome " + _cArqTxt + " nao pode ser criado!","Aten��o",'Verifique os parametros.',1)
   	//MsgAlert("O arquivo de nome " + _cArqTxt + " nao pode ser criado! Verifique os parametros.","Atencao!")
	Return .F.

Endif     
                   
//===========================================================================
//Validacoes dos Parametros
//===========================================================================

If Empty(MV_PAR01) .Or. Empty(MV_PAR03) .Or. Empty(MV_PAR04) .Or. Empty(MV_PAR05) .Or. Empty(MV_PAR06)

	xmaghelpfis("Campos Obrigat�rios","Para executar esta rotina � necess�rio que se preencha TODOS os par�metros.",;
				"Favor informar par�metros novamente.")  
	Return.F.		     
				
EndIf            

ProcRegua(3) 
IncProc("Lendo dados, Aguarde...")
IncProc("Lendo dados, Aguarde...")
//===========================================================================
//Query principal
//===========================================================================

_cQuery := "SELECT QRY1.RA_FILIAL, QRY1.RA_MAT,QRY1.RA_CIC,QRY1.RA_NOME,QRY1.RA_SITFOLH, (QRY1.TOTAL_VEN - COALESCE(QRY2.TOTAL_DEV,0)) TOTAL FROM "
_cQuery += "(SELECT RA.RA_FILIAL,RA.RA_MAT,RA.RA_CIC,RA.RA_NOME,RA.RA_SITFOLH, COALESCE(SUM(D2.D2_VALBRUT),0) TOTAL_VEN "
_cQuery += "FROM " + RetSqlName("SRA") + " RA "
_cQuery += "INNER JOIN " + RetSqlName("SA1") + " A1 ON A1.A1_CGC = RA.RA_CIC "
_cQuery += "INNER JOIN " + RetSqlName("SD2") + " D2 ON D2.D2_CLIENTE = A1.A1_COD AND D2.D2_LOJA = A1.A1_LOJA "
_cQuery += "INNER JOIN " + RetSqlName("ZAY") + " ZAY ON ZAY.ZAY_CF = D2.D2_CF "
_cQuery += "INNER JOIN " + RetSqlName("SF4") + " SF4 ON SF4.F4_FILIAL = D2.D2_FILIAL AND SF4.F4_CODIGO = D2.D2_TES AND SF4.F4_DUPLIC <> 'S' AND SF4.D_E_L_E_T_ = ' '  "
_cQuery += "WHERE RA.D_E_L_E_T_ = ' ' "
_cQuery += "AND D2.D_E_L_E_T_ = ' ' "
_cQuery += "AND A1.D_E_L_E_T_ = ' ' " 
_cQuery += "AND ( RA.RA_CATFUNC = 'M' OR RA.RA_CATFUNC = 'E' ) "
_cQuery += "AND ZAY.ZAY_TPOPER = 'V' "
_cQuery += "AND RA.RA_FILIAL = '" + mv_par01 +"' "
_cQuery += "AND (RA.RA_DEMISSA = ' ' OR RA.RA_DEMISSA BETWEEN '" + DtoS(mv_par04) + "' AND '" + DtoS(mv_par05) + "') "
_cQuery += "AND RA.RA_MAT BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "' "
_cQuery += "AND D2.D2_EMISSAO BETWEEN '" + DtoS(mv_par04) + "' AND '" + DtoS(mv_par05) + "' "
_cQuery += "GROUP BY RA.RA_FILIAL,RA.RA_MAT,RA.RA_CIC,RA.RA_NOME,RA.RA_SITFOLH "
_cQuery += ") QRY1 "
_cQuery += "LEFT JOIN ( "
_cQuery += "SELECT RA.RA_FILIAL,RA.RA_MAT,RA.RA_CIC,RA.RA_NOME,RA.RA_SITFOLH, COALESCE(SUM(D1.D1_TOTAL+D1.D1_VALIPI),0) TOTAL_DEV "
_cQuery += "FROM " + RetSqlName("SRA") + " RA "
_cQuery += "INNER JOIN " + RetSqlName("SA1") + " A1 ON A1.A1_CGC = RA.RA_CIC "
_cQuery += "INNER JOIN " + RetSqlName("SD1") + " D1 ON D1.D1_FORNECE = A1.A1_COD AND D1.D1_LOJA = A1.A1_LOJA "
_cQuery += "INNER JOIN " + RetSqlName("SF4") + " SF4 ON SF4.F4_FILIAL = D1.D1_FILIAL AND SF4.F4_CODIGO = D1.D1_TES AND SF4.F4_DUPLIC <> 'S' AND SF4.D_E_L_E_T_ = ' '  "
_cQuery += "WHERE RA.D_E_L_E_T_ = ' ' "
_cQuery += "  AND D1.D_E_L_E_T_ = ' ' "
_cQuery += "  AND A1.D_E_L_E_T_ = ' ' "
_cQuery += "  AND ( RA.RA_CATFUNC = 'M' OR RA.RA_CATFUNC = 'E' ) "
_cQuery += "  AND D1.D1_TIPO = 'D' "
_cQuery += "  AND RA.RA_FILIAL = '" + mv_par01 +"' "
_cQuery += "  AND (RA.RA_DEMISSA = ' ' OR ( RA.RA_DEMISSA BETWEEN '" + DtoS(mv_par04) + "' AND '" + DtoS(mv_par05) +"' "
_cQuery += "  AND NOT EXISTS (SELECT 'Y' FROM " + RetSqlName("SRA") + " SRA2 "//IGNORAR OS DEMITIDOS QUE FORAM ADMITIDOS NO MESMO MES Ex. Aprediz para CLT
_cQuery += "  	               WHERE SRA2.D_E_L_E_T_ = ' ' AND SRA2.RA_CIC = RA.RA_CIC AND SRA2.RA_SITFOLH <> 'D' AND SRA2.RA_DEMISSA = ' ') "
_cQuery += "  )   )"
_cQuery += "  AND A1.A1_FILIAL = '" + xfilial("SA1") +"' "
_cQuery += "  AND RA.RA_MAT BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "' "
_cQuery += "  AND D1.D1_EMISSAO BETWEEN '" + DtoS(mv_par04) + "' AND '" + DtoS(mv_par05) + "' "
_cQuery += "GROUP BY RA.RA_FILIAL,RA.RA_MAT,RA.RA_CIC,RA.RA_NOME,RA.RA_SITFOLH "
_cQuery += ") QRY2 ON QRY1.RA_FILIAL = QRY2.RA_FILIAL AND QRY1.RA_MAT = QRY2.RA_MAT "
_cQuery += "ORDER BY QRY1.RA_FILIAL,QRY1.RA_MAT "
 
If Select(_cAliasSD2) > 0
	(_cAliasSD2)->(DBCloseArea())
EndIf
 
dbUseArea( .T., "TOPCONN",TcGenQry(,,_cQuery),_cAliasSD2,.T.,.T.)

IncProc("Lendo dados, Aguarde...")

COUNT TO _nCountRec //Contabiliza o numero de registros encontrados pela query

IF _nCountRec = 0 
   U_ITMSG("N�o h� resgistros para esses filtros.","Aten��o",'Filtre novamente com outros dados.',1)
   RETURN .F.
ENDIF
	
(_cAliasSD2)->(dbGotop())     
	
//===========================================================================
//Percorre todos os registros selecionados na query 
//===========================================================================
aDet:={}
aDetEx:={}
_aTit:={}
_aCabXML:={}
// Alinhamento: 1-Left   ,2-Center,3-Right
// Formata��o.: 1-General,2-Number,3-Monet�rio,4-DateTime
//             Titulo das Colunas ,Alinhamento ,Formata��o, Totaliza?
//   (_aCabXML,{Titulo             ,1           ,1         ,.F.       })
AADD(_aTit,'Filial')
AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,2           ,1         ,.F.})//01
AADD(_aTit,'Matricula')
AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,2           ,1         ,.F.})//02
AADD(_aTit,'Nome')
AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,1           ,1         ,.F.})//03
AADD(_aTit,'Valor')
AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,3           ,3         ,.F.})//04
AADD(_aTit,'CPF')
AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,2           ,1         ,.F.})//05
AADD(_aTit,'Situa��o')
AADD(_aCabXML,{_aTit[LEN(_aTit)]   ,2           ,1         ,.F.})//05

cTot:=ALLTRIM(STR(_nCountRec))
nConta:=0
ProcRegua(_nCountRec)

While (_cAliasSD2)->(!Eof())        
	
    nConta++
    IncProc('Lendo: '+ALLTRIM(STR(nConta))+" de "+cTot )
	//IncProc("Processando dados matricula: " + (_cAliasSD2)->RA_MAT )  			
    aItem:={}
    AADD(aItem,(_cAliasSD2)->RA_FILIAL )//01
    AADD(aItem,(_cAliasSD2)->RA_MAT    )//02
    AADD(aItem,(_cAliasSD2)->RA_NOME   )//03
    AADD(aItem,(_cAliasSD2)->TOTAL     )//04
    AADD(aItem,(_cAliasSD2)->RA_CIC    )//05
    AADD(aItem,(_cAliasSD2)->RA_SITFOLH)//06
	//Filial
	_cLin 	:= 	PADR((_cAliasSD2)->RA_FILIAL,2) + " "
	_cLin 	+= 	PADR((_cAliasSD2)->RA_MAT,6) + " "		
	_cLin 	+=  PADL(AllTrim(Str((_cAliasSD2)->TOTAL,7,2)),7,"0")    			
	_cLin	+=  _cEOL                
	
	FWrite(_nHdl,_cLin,Len(_cLin))    
    
    aItem[5]:=TRANS((_cAliasSD2)->RA_CIC,"@R 999.999.999-99")//Trans para TELA Excel
    aItemEx:=ACLONE(aItem)//Excel
    AADD(aDetEx,aItemEx)  //Excel
    aItem[4]:=TRANS((_cAliasSD2)->TOTAL,"@E 999,999.99")//Trans s� para TELA 
    AADD(aDet,aItem)

	(_cAliasSD2)->(dbSkip())

EndDo  
    
//MsgAlert("Arquivo Gerado com Sucesso: "+_cArqTxt)
    
(_cAliasSD2)->(DBCloseArea())

_cTitulo:=cTitle+" - "+DTOC(DATE())+" - Hora Final: "+TIME()
_cMsgTop:= "Arquivo Gerado com Sucesso: "+_cArqTxt + " - Data Inicial: "+DTOC(MV_PAR04) +" - Data Final" + DTOC(MV_PAR05)

//                        ,_aCols,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons , _aCab  , bDblClk , _aColXML, bCondMarca,_bLegenda:EVAL(_bLegenda,_aCols,oLbxAux:nAt),_lHasOk,_bHeadClk,_aSX1)
U_ITListBox(_cTitulo,_aTit,aDet  , .T.    , 3    ,_cMsgTop,          ,        ,         ,     ,        ,           ,_aCabXML,         , aDetEx  ,           ,                                            ,       ,         ,     )

Return .T.
