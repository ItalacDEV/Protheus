/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/09/2019 | Retirada chamada da função itputx1. Chamado 28346 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 03/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
Jonathan      | 04/05/2020 | Alterar chamada "MsgBox" para "U_ITMSG". Chamado 32763
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"

/*
===============================================================================================================================
Programa----------: RPON008
Autor-------------: Josué Danich
Data da Criacao---: 18/08/2015
===============================================================================================================================
Descrição---------: Emissão do relatório de ocorrencias de horarios no ponto - Chamado 10871
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RPON008()

Local _aDados		:= {}
Local _cPerg		:= "RPON008"

SET DATE FORMAT TO "DD/MM/YYYY"

if Pergunte( _cPerg )

	Processa( {|| _aDados := RPON008SEL() } , "Aguarde!" , "Selecionando registros das recepções..." )
	
	IF Empty(_aDados)
	
		MessageBox( "Não foram encontrados registros para exibir! Verifique os parâmetros e tente novamente." , "Atenção" , 48 )
		
	Else
	
		Processa( {|| RPON008PRT( _aDados ) } , 'Aguarde!' , 'Imprimindo registros...' )
		
	EndIF

Else
	
	MsgInfo( 'Operação cancelada pelo usuário!' , 'Atenção!' )
	
EndIf

Return()

/*
===============================================================================================================================
Programa--------: RPON008SEL
Autor-----------: Josué Danich Pretses
Data da Criacao-: 18/08/2015
===============================================================================================================================
Descrição-------: Função para consulta e preparação dos dados do relatório
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _aRet - Dados do relatório
===============================================================================================================================
*/
Static Function RPON008SEL()

Local _aRet			:= {}
Local _cAlias		:= GetNextAlias()
Local _cQuery		:= ''
Local _nTotReg	:= 0
Local _nRegAtu	:= 0
Local _ni 			:= 1
   
_cquery :=	" SELECT Z10_FILIAL," 
_cquery +=	" Z10_DATA,"
_cquery +=	" Z10_MATRIC,"
_cquery +=	" Z10_TIPO," 
_cquery +=	" Z10_MOTIVO,"
_cquery +=	" Z10_IMPRES,"
_cquery +=	" Z10_ORIGEM "
_cquery +=	" FROM " + retsqlname("Z10") 
_cquery +=	" WHERE Z10_DATA BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "'"
_cquery += IIf( !Empty( MV_PAR01 ) , " AND Z10_FILIAL IN "+ FormatIn( Alltrim( MV_PAR01 ) , ';' )	, "" )
_cquery += " AND Z10_MATRIC BETWEEN '" + MV_PAR04 + "' AND '" +  MV_PAR05 + "'"
_cquery += " AND D_E_L_E_T_ <> '*'"

//Filtra advertência e notificação
If MV_PAR06 == 1

	_cquery += " AND Z10_TIPO = 'N'
	
Elseif MV_PAR06 == 2
	
	_cquery += " AND Z10_TIPO = 'A'
	
Endif

//Filtra impressos
If MV_PAR07 == 1

	_cquery += " AND Z10_IMPRES = 'S'
	
Elseif MV_PAR07 == 2
	
	_cquery += " AND Z10_IMPRES = 'N'
	
Endif

If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf


DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )

DBSelectArea(_cAlias)
(_cAlias)->( DBGoTop() )
(_cAlias)->( DBEval( {|| _nTotReg++ } ) )
(_cAlias)->( DBGoTop() )



ProcRegua(_nTotReg)
While (_cAlias)->( !Eof() )
	
	_nRegAtu++
	IncProc( "Lendo registros: ["+ StrZero( _nRegAtu , 6 ) +"] de ["+ StrZero( _nTotReg , 6 ) +"]" )

	if 	Posicione("SRA",1,(_cAlias)->Z10_FILIAL + (_cAlias)->Z10_MATRIC, "RA_CC") >= alltrim(MV_PAR08) .AND.;
		Posicione("SRA",1,(_cAlias)->Z10_FILIAL + (_cAlias)->Z10_MATRIC, "RA_CC") <= alltrim(MV_PAR09) .AND.;
		Posicione("SRA",1,(_cAlias)->Z10_FILIAL + (_cAlias)->Z10_MATRIC, "RA_I_SETOR") >= alltrim(MV_PAR10) .AND.;
		Posicione("SRA",1,(_cAlias)->Z10_FILIAL + (_cAlias)->Z10_MATRIC, "RA_I_SETOR") <= alltrim(MV_PAR11)

		aAdd( _aRet , {	(_cAlias)->Z10_FILIAL																,; //01 - Filial
					  	(_cAlias)->Z10_DATA																	,; //02 - Data
						(_cAlias)->Z10_MATRIC																,; //03 - Matricula
						posicione("SRA",1,(_cAlias)->Z10_FILIAL+(_cAlias)->Z10_MATRIC,"RA_NOME")		,; //04 - Nome
						(_cAlias)->Z10_TIPO																	,; //05 - Advertencia ou Notificacao
						(_cAlias)->Z10_MOTIVO																,; //06 - Observação
						(_cAlias)->Z10_ORIGEM																,; //07 - HE , DSR, Interjornada ou Intrajornada
						(_cAlias)->Z10_IMPRES    	 														,;	//08 - Impresso
						Posicione("SRA",1,(_cAlias)->Z10_FILIAL + (_cAlias)->Z10_MATRIC, "RA_NOME")  ,;	//09 - Nome
						Posicione("SRA",1,(_cAlias)->Z10_FILIAL + (_cAlias)->Z10_MATRIC, "RA_CC")    ,; //10 - Centro de custo
						Posicione("ZAK",1,xfilial("ZAK")+;
						Posicione("SRA",1,(_cAlias)->Z10_FILIAL + (_cAlias)->Z10_MATRIC, "RA_I_SETOR"),"ZAK_DESCRI") })    //11 - Setor
						
	Endif
	
	(_cAlias)->( DBSkip() )
	
EndDo

(_cAlias)->( DBCloseArea() )

//organiza matriz

_aRet := ASort(_aRet, , , {|x,y | y[1]+y[10]+y[11]+y[3]+y[2] > x[1]+x[10]+x[11]+x[3]+x[2]})
	
	
//roda matriz para deixar o campo 5 marcado só se é a única ou última ocorrência do dia

For _ni := 1 to len(_aRet)

	if (_ni + 1) <= len(_aRet)
	
		//se os campos de qualificação e data forem iguais ao do próximo registro limpa o campo que indica se é notificação ou advertência
		if 	_aRet[_ni][1]+_aRet[_ni][10]+_aRet[_ni][11]+_aRet[_ni][3]+_aRet[_ni][2] == ;
			_aRet[_ni+1][1]+_aRet[_ni+1][10]+_aRet[_ni+1][11]+_aRet[_ni+1][3]+_aRet[_ni+1][2]
			
				_aRet[_ni][5] := " "
				
		endif
		
	Endif
	
Next	

	
Return( _aRet )

/*
===============================================================================================================================
Programa--------: RPON008PRT
Autor-----------: Josué Danich Prestes
Data da Criacao-: 03/08/2015
===============================================================================================================================
Descrição-------: Função para controlar e imprimir os dados do relatório
===============================================================================================================================
Parametros------: _aDados  - Dados do relatório
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function RPON008PRT( _aDados )

Local _aColCab	:= { 0055 , 0180 , 0600 , 0825 , 1125 , 1800 , 2050 , 2300 }
Local _nLinha		:= 300
Local _nI			:= 0
Local _nConTot	:= 0
Local _nConGer   	:= 0
Local _oPrint		:= Nil
Local _culfilial 	:= ""
Local _culcc 		:= ""
Local _culsetor 	:= ""
Local _cmode 		:= ""
Local _culmat 	:= ""
Local _aDadExp   	:= {}
Local _acabexcel 	:= {}

Private _oFont01	:= TFont():New( "Tahoma" ,, 14 , .F. , .T. ,, .T. ,, .T. , .F. )
Private _oFont03	:= TFont():New( "Tahoma" ,, 10 , .F. , .F. ,, .T. ,, .T. , .F. )
Private _oFont03B	:= TFont():New( "Tahoma" ,, 10 , .F. , .T. ,, .T. ,, .T. , .F. )
Private _npagi := 1
Private _cTitulo := "Notificação/Advertência - Ocorrências de ponto"

//====================================================================================================
// Inicializa o objeto do relatório
//====================================================================================================
_oPrint := TMSPrinter():New( _cTitulo )
_oPrint:Setup()
_oPrint:SetLandscape()
_oPrint:SetPaperSize(9)

//====================================================================================================
// Processa a impressão dos dados
//====================================================================================================
For _nI := 1 To Len( _aDados )
	
	//====================================================================================================
	// Imprime ocorrências
	//====================================================================================================
	IF _nI == 1 

		_nLinha := 5000
		
		_nLinha := RPON008VPG( _oPrint , _nLinha , .F., _adados, _ni)
		
	
		_oPrint:Say(  _nLinha + 0020 , _aColCab[01]			, 'Filial'				, _oFont03B )  
		_oPrint:Say(  _nLinha + 0020 , _aColCab[02]			, 'Setor'				, _oFont03B ) 
		_oPrint:Say(  _nLinha + 0020 , _aColCab[04]			, 'Matricula		'	, _oFont03B ) 
		_oPrint:Say(  _nLinha + 0020 , _aColCab[05]			, 'Nome			'	, _oFont03B ) 
		_oPrint:Say(  _nLinha + 0020 , _aColCab[06]			, 'Data			'	, _oFont03B ) 
		_oPrint:Say(  _nLinha + 0020 , _aColCab[07]			, 'Tipo			'	, _oFont03B ) 
		_oPrint:Say(  _nLinha + 0020 , _aColCab[08]			, 'Motivo			'	, _oFont03B ) 
		
		_nLinha += 060
		_oPrint:Line( _nLinha        , 0050               , _nLinha        , 3350               )
		
		_culfilial 	:= _aDados[_ni][01]
		_culcc 		:= _aDados[_ni][10]
 		_culsetor 		:= _aDados[_ni][11]
 		_culmat 		:= alltrim(_aDados[_ni][03])
 		_nConTot      := 1
 		_nConGer 		:= 1
	
	Elseif _nlinha > 2000
	
		_nLinha := RPON008VPG( _oPrint , _nLinha , .T., _adados, _ni)
		
		_oPrint:Say(  _nLinha + 0020 , _aColCab[01]			, 'Filial'				, _oFont03B )  
		_oPrint:Say(  _nLinha + 0020 , _aColCab[02]			, 'Setor'				, _oFont03B ) 
		_oPrint:Say(  _nLinha + 0020 , _aColCab[04]			, 'Matricula		'	, _oFont03B ) 
		_oPrint:Say(  _nLinha + 0020 , _aColCab[05]			, 'Nome			'	, _oFont03B ) 
		_oPrint:Say(  _nLinha + 0020 , _aColCab[06]			, 'Data			'	, _oFont03B ) 
		_oPrint:Say(  _nLinha + 0020 , _aColCab[07]			, 'Tipo			'	, _oFont03B ) 
		_oPrint:Say(  _nLinha + 0020 , _aColCab[08]			, 'Motivo			'	, _oFont03B ) 
		
		_nLinha += 060
		_oPrint:Line( _nLinha        , 0050               , _nLinha        , 3350              )
		
	ElseIf (_culfilial != _aDados[_ni][01] .or. _culsetor != _aDados[_ni][11])
	
		if MV_PAR12 == 1
		
			
			_nLinha += 060
			
			_oPrint:Say(  _nLinha + 0020 , _aColCab[01]			, 'Total'				, _oFont03B )  
			_oPrint:Say(  _nLinha + 0020 , _aColCab[04]			, strzero(_nConTot,4) + " funcionários"	, _oFont03B ) 
		
			_nLinha += 060
			_oPrint:Line( _nLinha        , 0050               , _nLinha        , 3350               )
		
			_nConTot := 0
	
			
			_nLinha := 5000
		
			_nLinha := RPON008VPG( _oPrint , _nLinha , .T., _adados, _ni)
		
		else
	
			_nLinha := RPON008VPG( _oPrint , _nLinha , .T., _adados, _ni)
			
			_oPrint:Say(  _nLinha + 0020 , _aColCab[01]			, 'Total'				, _oFont03B )  
			_oPrint:Say(  _nLinha + 0020 , _aColCab[04]			, strzero(_nConTot,4) + " funcionários"	, _oFont03B ) 
		
			_nLinha += 060
			_oPrint:Line( _nLinha        , 0050               , _nLinha        , 3350               )
		
			_nConTot := 0
			
			_nlinha += 120
	
		endif
		
		_oPrint:Say(  _nLinha + 0020 , _aColCab[01]			, 'Filial'				, _oFont03B )  
		_oPrint:Say(  _nLinha + 0020 , _aColCab[02]			, 'Setor'				, _oFont03B ) 
		_oPrint:Say(  _nLinha + 0020 , _aColCab[04]			, 'Matricula		'	, _oFont03B ) 
		_oPrint:Say(  _nLinha + 0020 , _aColCab[05]			, 'Nome			'	, _oFont03B ) 
		_oPrint:Say(  _nLinha + 0020 , _aColCab[06]			, 'Data			'	, _oFont03B ) 
		_oPrint:Say(  _nLinha + 0020 , _aColCab[07]			, 'Tipo			'	, _oFont03B ) 
		_oPrint:Say(  _nLinha + 0020 , _aColCab[08]			, 'Motivo			'	, _oFont03B ) 
		
		_nLinha += 060
		_oPrint:Line( _nLinha        , 0050               , _nLinha        , 3350              )
	
		//faz controle de quebra e totalização
		_culfilial 	:= _aDados[_ni][01]
		_culsetor 		:= _aDados[_ni][11]
 		
 		
	Endif	
	
	
	//carrega valores de tipo e origem da ocorrência
	_ctipo := U_APON001Y(_aDados[_nI][07])
	
	if _aDados[_ni][5] == "A"
	
		_cmode := "Advertência"
		
	elseif _aDados[_ni][5] == "N"
		
		_cmode := "Notificação"
		
	else 
	
		_cmode := ""
		
	endif
		
	_oPrint:Say(  _nLinha + 0020 , _aColCab[01]			, _aDados[_ni][01]											, _oFont03 )  
	_oPrint:Say(  _nLinha + 0020 , _aColCab[02]			, _aDados[_ni][11]											, _oFont03 ) 
	_oPrint:Say(  _nLinha + 0020 , _aColCab[04]			, _aDados[_ni][03]											, _oFont03 ) 
	_oPrint:Say(  _nLinha + 0020 , _aColCab[05]			, substr(_aDados[_ni][09],1,25)								, _oFont03 ) 
	_oPrint:Say(  _nLinha + 0020 , _aColCab[06]			, dtoc(stod(_aDados[_ni][02]))								, _oFont03 ) 
	_oPrint:Say(  _nLinha + 0020 , _aColCab[07]			, _cmode														, _oFont03 ) 
	_oPrint:Say(  _nLinha + 0020 , _aColCab[08]			, _ctipo														, _oFont03 ) 
		
	
	_nLinha += 060
	_oPrint:Line( _nLinha        , 0050               , _nLinha        , 3350              )
	
	//grava matriz de exportação
	aadd(_aDadExp,{_aDados[_ni][01],_aDados[_ni][11],_aDados[_ni][03],substr(_aDados[_ni][09],1,25),dtoc(stod(_aDados[_ni][02])),_cmode,_ctipo," "})
		
	//soma totalizadores cada mudança de matricula
	if alltrim(_culmat) != alltrim( _aDados[_ni][03])
 		
 		_nConTot++
 		_nConGer++
 		_culmat 		:= alltrim(_aDados[_ni][03])
 			
 	Endif	
	
	
Next _nI


//faz totalizador final
_nLinha += 060
		
_oPrint:Say(  _nLinha + 0020 , _aColCab[01]			, 'Total'				, _oFont03B )  
_oPrint:Say(  _nLinha + 0020 , _aColCab[04]			, strzero(_nConTot,4) + " funcionários"	, _oFont03B ) 
		
_nLinha += 060
_oPrint:Line( _nLinha        , 0050               , _nLinha        , 3350               )

_oPrint:Say(  _nLinha + 0020 , _aColCab[01]			, 'Total Geral'				, _oFont03B )  
_oPrint:Say(  _nLinha + 0020 , _aColCab[04]			, strzero(_nConGer,4) + " funcionários"	, _oFont03B ) 
		
_nLinha += 060
_oPrint:Line( _nLinha        , 0050               , _nLinha        , 3350               )

_oPrint:Say(  _nLinha + 0020 , _aColCab[01]			, 'Filial'				, _oFont03B )  
_oPrint:Say(  _nLinha + 0020 , _aColCab[02]			, 'Setor'				, _oFont03B ) 
_oPrint:Say(  _nLinha + 0020 , _aColCab[04]			, 'Matricula		'	, _oFont03B ) 
_oPrint:Say(  _nLinha + 0020 , _aColCab[05]			, 'Nome			'	, _oFont03B ) 
_oPrint:Say(  _nLinha + 0020 , _aColCab[06]			, 'Data			'	, _oFont03B ) 
_oPrint:Say(  _nLinha + 0020 , _aColCab[07]			, 'Tipo			'	, _oFont03B ) 
_oPrint:Say(  _nLinha + 0020 , _aColCab[08]			, 'Motivo			'	, _oFont03B ) 
		


//=============================================================================
//| Starta o objeto de impressão                                              |
//=============================================================================
_acabexcel := {}
AADD(_aCabExcel, {"Filial" ,"C", 02, 0})
AADD(_aCabExcel, {"Setor" ,"C", 06, 0})
AADD(_aCabExcel, {"Matricula" ,"C", 06, 0})
AADD(_aCabExcel, {"Nome" ,"C", 40, 0})
AADD(_aCabExcel, {"Data" ,"N", 18, 2})
AADD(_aCabExcel, {"Tipo" ,"C", 10, 0})
AADD(_aCabExcel, {"Motivo" ,"C", 10, 0})
AADD(_aCabExcel, {"." ,"C", 10, 0})

//escolhe saída para excel ou impressão
if U_ITMSG("Deseja exportar para o Excel?","Saída",,3,2,2)

	MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",;
	{||DlgToExcel({{"GETDADOS",;
	_cTitulo,;
	_aCabExcel,_aDadExp}})})

else

	_oPrint:Preview()
	
Endif

Return()

/*
===============================================================================================================================
Programa--------: RPON008VPG
Autor-----------: Josué Danich Prestes
Data da Criacao-: 03/08/2014
===============================================================================================================================
Descrição-------: Validação do posicionamento da página atual para quebras
===============================================================================================================================
Parametros------: oPrint	- Objeto de Impressão do Relatório
----------------: nLinha	- Variável de controle do posicionamento
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function RPON008VPG( _oPrint , _nLinha , _lFinPag, _adados, _ni )

Local _nLimPag		:= 2000
Local _cTitulo := "Lista Ocorrências de Ponto"
Local _ncolfim := 3350

Default _lFinPag	:= .T.

If _nLinha > _nLimPag

	//====================================================================================================
	// Verifica se encerra a página atual
	//====================================================================================================
	IF _lFinPag
		_oPrint:EndPage()
	EndIF
	
	//====================================================================================================
	// Inicializa a nova página e o posicionamento
	//====================================================================================================
	_oPrint:StartPage()
	_nLinha	:= 280
	
	//====================================================================================================
	// Insere logo no cabecalho
	//====================================================================================================
	If File( "LGRL01.BMP" )
		_oPrint:SayBitmap( 050 , 020 , "LGRL01.BMP" , 410 , 170 )
	EndIf
	
	
	//====================================================================================================
	// Imprime quadro do Título para advertência
	//====================================================================================================
	_oPrint:Line( 050 , 0400 , 050 , _ncolfim )
	_oPrint:Line( 240 , 0400 , 240 , _ncolfim )
	_oPrint:Line( 050 , 0400 , 240 , 0400 )
	_oPrint:Line( 050 , _ncolfim , 240 , _ncolfim )
		

	_oPrint:Say( 060 , 420 , _cTitulo +" ( "+ DtoC(Date()) +" - "+ Time() +")"								, _oFont01 )
	_oPrint:Say( 060, _ncolfim-280 , "Pág. " + strzero(_npagi,3))
	
	_npagi++
	
	_oPrint:Say( 130 , 420 , "Filiais: "+ iif(len(AllTrim( MV_PAR01 )) > 0,AllTrim( MV_PAR01 ),"TODAS")  , _oFont03 )
	_oPrint:Say( 180 , 420 , "Data de: " + dtoc(MV_PAR02) + "  até " + dtoc(MV_PAR03) , _oFont03)
	_oPrint:Say( 180 , 1220 , "Matricula de " + alltrim(MV_PAR04) + " até " + alltrim(MV_PAR05) , _oFont03 )
	_oPrint:Say( 189 , 1820 , "Impresso: " + iif(MV_PAR07==1,"Sim",iif(MV_PAR07==2,"Não","Ambos"))  , _oFont03 )
	_oPrint:Say( 189 , 2220 , "CC de: " + alltrim(MV_PAR08) + " até " + alltrim(MV_PAR09)  , _oFont03 )
		
EndIf

Return _nlinha