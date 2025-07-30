/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 16/06/2019 | Chamado 29715 - Ajustar fonte de impress�o para exibir corretamente os dados do documento. 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/09/2019 | Chamado 28346 - Retirada chamada da fun��o itputx1.  
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 02/10/2019 | Chamado 28346 - Removidos os Warning na compila��o da release 12.1.25. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 30/08/2021 | Chamado 37601 - Trazer o conte�do do campo RA_NSOCIAL, quando preenchido no lugar do RA_NOME. 
-------------------------------------------------------------------------------------------------------------------------------
Igor Melga�o  | 20/06/2023 | Chamado 44223 - Ajustes para inclus�o de op��es no campo Z10_TIPO.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Totvs.Ch"

/*
===============================================================================================================================
Programa----------: RPON007
Autor-------------: Xavier
Data da Criacao---: 20/05/2015
===============================================================================================================================
Descri��o---------: Emiss�o do modelo de ocorrencias de horarios no ponto
===============================================================================================================================
Parametros--------: cTpModelo = Tipo do modelo para emitir (Comunicado ou Advertencia)
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RPON007(_lauto)

Local _aDados		:= {}
Local _cPerg		:= "RPON007"
Local _lroda    	:= .F.

Private _ncolini 	:= 100
Private _ncolfim 	:= 2300

Default _lauto := .F.

SET DATE FORMAT TO "DD/MM/YYYY"

_lroda := _lauto

If !(_lauto)

	_lroda := Pergunte( _cPerg )
	
Endif

If _lroda

	Processa( {|| _aDados := RPON007SEL(_lauto) } , "Aguarde!" , "Selecionando registros das recep��es..." )
	
	IF Empty(_aDados)
	
		MessageBox( "N�o foram encontrados registros para exibir! Verifique os par�metros e tente novamente." , "Aten��o" , 48 )
		
	Else
	
		Processa( {|| RPON007PRT( _aDados ) } , 'Aguarde!' , 'Imprimindo registros...' )
		
	EndIF

Else
	
	MsgInfo( 'Opera��o cancelada pelo usu�rio!' , 'Aten��o!' )
	
EndIf

Return()

/*
===============================================================================================================================
Programa--------: RPON007SEL
Autor-----------: Josu� Danich Pretses
Data da Criacao-: 18/08/2015
===============================================================================================================================
Descri��o-------: Fun��o para consulta e prepara��o dos dados do relat�rio
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: _aRet - Dados do relat�rio
===============================================================================================================================
*/
Static Function RPON007SEL(_lauto)

Local _aRet			:= {}
Local _cAlias		:= GetNextAlias()
Local _cQuery		:= ''
Local _nTotReg	:= 0
Local _nRegAtu	:= 0

Default _lauto 		:= .T.

//faz automatico com Z10 posicionado
If _lauto
   Private MV_PAR01 	:= alltrim(Z10->Z10_FILIAL)
   Private MV_PAR02 	:= Z10->Z10_DATA
   Private MV_PAR03 	:= Z10->Z10_DATA
   Private MV_PAR04 	:= ALLTRIM(Z10->Z10_MATRIC)
   Private MV_PAR05 	:= ALLTRIM(Z10->Z10_MATRIC)
   Private MV_PAR07 	:= 3 
   Private MV_PAR06 	:= 3
   Private MV_PAR08 	:= 3
   Private MV_PAR09 	:= "                   "
   Private MV_PAR10	:= "ZZZZZZZZZZZZZZZZZZZ"
   Private MV_PAR11 	:= "                   "
   Private MV_PAR12	:= "ZZZZZZZZZZZZZZZZZZZ"
EndIf

Begin Sequence
   _cquery :=	" SELECT Z10_FILIAL, "
   _cquery +=	" Z10_DATA,   "
   _cquery +=	" Z10_MATRIC, "
   _cquery +=	" Z10_TIPO,   "
   _cquery +=	" Z10_MOTIVO, "
   _cquery +=	" Z10_IMPRES, "
   _cquery +=	" Z10_HORAIN, "
   _cquery +=	" Z10_HORAFI, "
   _cquery +=	" Z10_TEMPOD, "
   _cquery +=	" R_E_C_N_O_, "
   _cquery +=	" Z10_ORIGEM FROM "+ retsqlname("Z10") 
   _cquery +=	" WHERE Z10_DATA BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "'"
   _cquery += IIf( !Empty( MV_PAR01 ) , " AND Z10_FILIAL IN "+ FormatIn( Alltrim( MV_PAR01 ) , ';' )	, "" )
   _cquery += " AND Z10_MATRIC BETWEEN '" + MV_PAR04 + "' AND '" +  MV_PAR05 + "'"
   _cquery += " AND D_E_L_E_T_ <> '*'"

   //Filtra advert�ncia e notifica��o
   If MV_PAR06 == 1
	  _cquery += " AND Z10_TIPO = 'N'
   Elseif MV_PAR06 == 2
	  _cquery += " AND Z10_TIPO = 'A'
   EndIf

   //Filtra impressos
   If MV_PAR08 == 1
	  _cquery += " AND Z10_IMPRES = 'S'
   ElseIf MV_PAR08 == 2
	  _cquery += " AND Z10_IMPRES = 'N'
   EndIf
 
   If Select(_cAlias) > 0
	  (_cAlias)->( DBCloseArea() )
   EndIf

   DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )

   DBSelectArea(_cAlias)
   (_cAlias)->( DBGoTop() )
   (_cAlias)->( DBEval( {|| _nTotReg++ } ) )
   (_cAlias)->( DBGoTop() )

   SRA->( dbSetOrder( 1 ) )
   ProcRegua(_nTotReg)
   Do While (_cAlias)->( !Eof() )
	
	  _nRegAtu++
	  IncProc( "Lendo registros: ["+ StrZero( _nRegAtu , 6 ) +"] de ["+ StrZero( _nTotReg , 6 ) +"]" )

	       If Posicione("SRA",1,(_cAlias)->Z10_FILIAL + (_cAlias)->Z10_MATRIC, "RA_CC") >= alltrim(MV_PAR09) .AND.;
		        Posicione("SRA",1,(_cAlias)->Z10_FILIAL + (_cAlias)->Z10_MATRIC, "RA_CC") <= alltrim(MV_PAR10) .AND.;
		        Posicione("SRA",1,(_cAlias)->Z10_FILIAL + (_cAlias)->Z10_MATRIC, "RA_I_SETOR") >= alltrim(MV_PAR11) .AND.;
		        Posicione("SRA",1,(_cAlias)->Z10_FILIAL + (_cAlias)->Z10_MATRIC, "RA_I_SETOR") <= alltrim(MV_PAR12)

				_cNomeFunc := SRA->RA_NOMECMP
		        IF !EMPTY(SRA->RA_NSOCIAL)
		           _cNomeFunc:=SRA->RA_NSOCIAL
		        ENDIF

        
		        aAdd( _aRet ,{(_cAlias)->Z10_FILIAL																                           ,; //01 - Filial
					  	            (_cAlias)->Z10_DATA																	                           ,; //02 - Data    
						              (_cAlias)->Z10_MATRIC															                             ,; //03 - Matricula
						              _cNomeFunc		 ,; //04 - Nome
						              (_cAlias)->Z10_TIPO																	                           ,; //05 - Advertencia ou Notificacao
						              (_cAlias)->Z10_MOTIVO																                           ,; //06 - mOTIVO
						              (_cAlias)->Z10_ORIGEM																                           ,; //07 - HE , DSR, Interjornada ou Intrajornada
						              (_cAlias)->Z10_IMPRES    	 														                         ,; //08 - Impresso
						              (_cAlias)->R_E_C_N_O_                                                          ,; //09 - Registro
		                      (_cAlias)->Z10_HORAIN                                                          ,; //10 - Hora Inicial da Ocorrencia 
						              (_cAlias)->Z10_HORAFI                                                          ,; //11 - Hora Final da Ocorrencia    
						              (_cAlias)->Z10_TEMPOD})                                                           //12 - Tempo Decorrido
	       EndIf
	   
	   (_cAlias)->( DBSkip() )
   EndDo

   (_cAlias)->( DBCloseArea() )

   //organiza matriz
   IF MV_PAR07 == 1
	  _aRet := ASort(_aRet, , , {|x,y | y[2]+y[3]+y[4] > x[2]+x[3]+x[4]})
   ELSEIF MV_PAR07 == 2
      _aRet := ASort(_aRet, , , {|x,y | y[4]+y[2] > x[4]+x[2]})
   ELSEIF MV_PAR07 == 3
	  _aRet := ASort(_aRet, , , {|x,y | y[2]+y[4] > x[2]+x[4]})
   EndIf

End Sequence

Return( _aRet )

/*
===============================================================================================================================
Programa--------: RPON007PRT
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 03/08/2015
===============================================================================================================================
Descri��o-------: Fun��o para controlar e imprimir os dados do relat�rio
===============================================================================================================================
Parametros------: _aDados  - Dados do relat�rio
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function RPON007PRT( _aDados )
                   // 1      2      3      4      5      6   
Local _aColCab	:= { 0020 , 0220 , 0440 , 0675 , 0875 , 1100 , 1750 , 1800 } // { 0020 , 0180 , 0300 , 0675 , 1875 , 1500 , 1750 , 1800 }
Local _aColItn	:= { 0010 , 0220 , 0440 , 0675 , 0875 , 1100 , 1750 , 1925 } // { 0010 , 0180 , 0300 , 0675 , 1875 , 1700 , 1950 , 1925 }
Local _nLinha	:= 300
Local _nI		:= 0
Local _oPrint	:= Nil
Local _nulin :=0

Private _oFont02	:= TFont():New( "Tahoma" ,, 18 , .F. , .T. ,, .T. ,, .T. , .F. )
Private _oFont03	:= TFont():New( "Tahoma" ,, 14 , .F. , .F. ,, .T. ,, .T. , .F. )
Private _oFont04	:= TFont():New( "Tahoma" ,, 12 , .F. , .T. ,, .T. ,, .T. , .F. )
Private _oFont04B	:= TFont():New( "Tahoma" ,, 11 , .F. , .T. ,, .T. ,, .T. , .F. )
Private _oFont05	:= TFont():New( "Tahoma" ,, 10 , .F. , .F. ,, .T. ,, .T. , .F. )
Private _npagi := 1
Private _cTitulo := "Notifica��o/Advert�ncia - Ocorr�ncias de ponto"

//====================================================================================================
// Inicializa o objeto do relat�rio
//====================================================================================================
_oPrint := TMSPrinter():New( _cTitulo )
_oPrint:Setup()
_oPrint:SetPortrait()
_oPrint:SetPaperSize(9)

//====================================================================================================
// Processa a impress�o dos dados
//====================================================================================================
For _nI := 1 To Len( _aDados )
	
	//====================================================================================================
	// Imprime ocorr�ncias
	//====================================================================================================
	IF _nI == 1 

		//cabe�alho para primeira folha
		
		_nulin  := _nLinha
		_nLinha := 5000
		
		_nLinha := RPON007VPG( _oPrint , _nLinha , .F., _adados, _ni,_nulin)
	
	    _oPrint:Say(  _nLinha + 0020 , _ncolini + _aColCab[01]		, 'Data'	  , _oFont04B )
		_oPrint:Say(  _nLinha + 0020 , _ncolini + _aColCab[02]		, 'Hora Inic.', _oFont04B )
		_oPrint:Say(  _nLinha + 0020 , _ncolini + _aColCab[03]		, 'Hora Final', _oFont04B )
		_oPrint:Say(  _nLinha + 0020 , _ncolini + _aColCab[04]		, 'Tempo'	  , _oFont04B )
		_oPrint:Say(  _nLinha + 0020 , _ncolini + _aColCab[05]		, 'Motivo'	  , _oFont04B ) 
		_oPrint:Say(  _nLinha + 0020 , _ncolini + _aColCab[06]		, 'Observa��o', _oFont04B ) 

		_nLinha += 075
		
		_culdata 	:= _aDados[_nI][02]
		_culmat 	:=	_aDados[_nI][03]
		
		
	Elseif _culdata != _aDados[_nI][02] .or. _culmat !=  _aDados[_nI][03]
		
		//cabe�alho quando mudar data e/ou matricula
		_nulin  := _nLinha
		_nLinha := 5000
		
		_nLinha := RPON007VPG( _oPrint , _nLinha , .T., _adados, _ni,_nulin)
	
		_oPrint:Say(  _nLinha + 0020 , _ncolini + _aColCab[01]	    , 'Data'	  , _oFont04B )  
		_oPrint:Say(  _nLinha + 0020 , _ncolini + _aColCab[02]		, 'Hora Inic.', _oFont04B )
		_oPrint:Say(  _nLinha + 0020 , _ncolini + _aColCab[03]		, 'Hora Final', _oFont04B )
		_oPrint:Say(  _nLinha + 0020 , _ncolini + _aColCab[04]		, 'Tempo'	  , _oFont04B )
		_oPrint:Say(  _nLinha + 0020 , _ncolini + _aColCab[05]		, 'Motivo'	  , _oFont04B ) 
		_oPrint:Say(  _nLinha + 0020 , _ncolini + _aColCab[06]		, 'Observa��o', _oFont04B ) 

		_nLinha += 075
		
		_culdata 	:= _aDados[_nI][02]
		_culmat 	:=	_aDados[_nI][03]
	 
	Endif	

	_oPrint:Line( _nLinha        , _ncolini              		 	, _nLinha        , _ncolfim		      )
	_oPrint:Line( _nLinha + 0075 , _ncolini             			, _nLinha + 0075 , _ncolfim	          )
	_oPrint:Line( _nLinha        , _ncolini              		 	, _nLinha + 0075 , _ncolini           )
	_oPrint:Line( _nLinha        , _ncolfim	       		 	        , _nLinha + 0075 , _ncolfim	          )
	_oPrint:Line( _nLinha        , _ncolini + _aColCab[02] - 015 	, _nLinha + 0075 , _ncolini + _aColCab[02] - 015 )
	_oPrint:Line( _nLinha        , _ncolini + _aColCab[03] - 015 	, _nLinha + 0075 , _ncolini + _aColCab[03] - 015 )
	_oPrint:Line( _nLinha        , _ncolini + _aColCab[04] - 015 	, _nLinha + 0075 , _ncolini + _aColCab[04] - 015 )
	_oPrint:Line( _nLinha        , _ncolini + _aColCab[05] - 015 	, _nLinha + 0075 , _ncolini + _aColCab[05] - 015 )
	_oPrint:Line( _nLinha        , _ncolini + _aColCab[06] - 015 	, _nLinha + 0075 , _ncolini + _aColCab[06] - 015 )
	
	_ctipo := U_APON001Y(_aDados[_nI][07]+"A")
		
	_oPrint:Say( _nLinha + 10 , _ncolini + _aColItn[01] , dtoc(stod(_aDados[_nI][02]))	          , _oFont05			) // _oFont03
	_oPrint:Say( _nLinha + 10 , _ncolini + _aColItn[02] , _aDados[_nI][10]	                      , _oFont05			)
	_oPrint:Say( _nLinha + 10 , _ncolini + _aColItn[03] , _aDados[_nI][11]	                      , _oFont05			)
	_oPrint:Say( _nLinha + 10 , _ncolini + _aColItn[04] , _aDados[_nI][12]	                      , _oFont05			)
	_oPrint:Say( _nLinha + 10 , _ncolini + _aColItn[05] , _ctipo	                              , _oFont05			)
	_oPrint:Say( _nLinha + 10 , _ncolini + _aColItn[06] , substr(alltrim(_aDados[_nI][06]),1,50)  , _oFont05			)
	
	_nLinha += 075
	
Next _nI


//Finaliza folha
_nulin  := _nLinha
_nlinha := 5000
_nLinha := RPON007VPG( _oPrint , _nLinha , .T., _adados, _ni-1,_nulin, .F.)


//=============================================================================
//| Starta o objeto de impress�o                                              |
//=============================================================================
_oPrint:Preview()

//marca registros como impressos
dbSelectArea("Z10")

for _ni := 1 to len(_adados)

	Z10->(Dbgoto(_adados[_ni][09]))
	RecLock("Z10", .F.)
	Z10->Z10_IMPRES := "S"
	Msunlock()
	
Next

Return()

/*
===============================================================================================================================
Programa--------: RPON007VPG
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 03/08/2014
===============================================================================================================================
Descri��o-------: Valida��o do posicionamento da p�gina atual para quebras
===============================================================================================================================
Parametros------: oPrint	- Objeto de Impress�o do Relat�rio
----------------: nLinha	- Vari�vel de controle do posicionamento
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
 */
Static Function RPON007VPG( _oPrint , _nLinha , _lFinPag, _adados, _ni,_nulin, _lnovpag)

Local _nLimPag		:= 3350

Default _lFinPag	:= .T.
Default _lnovpag	:= .T.


If _nLinha > _nLimPag

	//====================================================================================================
	// Verifica se encerra a p�gina atual
	//====================================================================================================
	IF _lFinPag
	
		
		//faz texto do final da p�gina
		
		_nlinha := _nulin + 90
		
	
		_oPrint:Say( _nLinha, _ncolini, "Esclarecemos, ainda que a repeti��o de procedimentos como este poder� ser considerado como" , _oFont03			) 
		_nLinha += 75

		//Muda frase se � advert�ncia ou notifica��o
		_ctipo := ""
		If _adados[_ni][5] == 'A'

			_ctipo := "ato faltoso, pass�vel de nova advert�ncia e suspens�o."

		Elseif _adados[_ni][5] == 'O'

			_ctipo := "ato faltoso, pass�vel de nova ocorr�ncia e notifica��o."

		Elseif _adados[_ni][5] == 'S'

			_ctipo := "ato faltoso, pass�vel de demiss�o por justa causa."

		Else

			_ctipo := "ato faltoso, pass�vel de advert�ncia e suspens�o."
	
		Endif
		
		_oPrint:Say( _nLinha, _ncolini, _ctipo  , _oFont03			) 
		_nLinha += 75
		_oPrint:Say( _nLinha, _ncolini, "Para que n�o tenhamos, no futuro, de tomar as medidas que nos facultam a legisla��o vigente," , _oFont03			) 
		_nLinha += 75
		_oPrint:Say( _nLinha, _ncolini, "solicitamos que observe as normas internas definidas e amplamente divulgadas anteriormente." , _oFont03			)
		_nLinha += 75
		_oPrint:Say( _nLinha, _ncolini, "Favor dar o seu ciente," , _oFont03			) 

		_nLinha += 300       
		_oPrint:Line( _nLinha        , _ncolini               , _nLinha        , 1500              )
		_nLinha += 30       
		
		If _lnovpag
			_oPrint:Say( _nLinha, _ncolini,_adados[_ni-1][4] )
		Else
			_oPrint:Say( _nLinha, _ncolini,_adados[_ni][4] )
		Endif

		_nLinha += 300       
		_oPrint:Line( _nLinha        , _ncolini               , _nLinha        , 1500              )
		_nLinha += 30       
		_oPrint:Say( _nLinha, _ncolini, ALLTRIM(SM0->M0_NOMECOM))
      
		_nLinha += 150  
		_oPrint:Say( _nLinha, _ncolini, "Testemunha: (caso o colaborador advertido negue-se a assinar o documento. Serve para" , _oFont04			) 
		_nLinha += 75
		_oPrint:Say( _nLinha, _ncolini, " testemunhar que o colaborador foi advertido)" , _oFont04			) 

		_nLinha += 300       
		_oPrint:Line( _nLinha        , _ncolini               , _nLinha        , 925              )
		_oPrint:Say( _nLinha + 030, _ncolini, "Nome:")
		_oPrint:Say( _nLinha + 105, _ncolini, "CPF:")     
		
		_oPrint:Line( _nLinha        , 1200               , _nLinha        , _ncolfim              )
		_oPrint:Say( _nLinha + 030, 1200, "Nome:")
		_oPrint:Say( _nLinha + 105, 1200, "CPF:")     
	
		
		_oPrint:EndPage()

	EndIF
	
	
	if _lnovpag
	
	   
		//====================================================================================================
		// Inicializa a nova p�gina e o posicionamento
		//====================================================================================================
		_oPrint:StartPage()
		_nLinha	:= 280
	
		//====================================================================================================
		// Insere logo no cabecalho
		//====================================================================================================
		If File( "LGRL01.BMP" )
			_oPrint:SayBitmap( 050 , 1020 , "LGRL01.BMP" , 410 , 170 )
		EndIf
		
		If _adados[_ni][5] == 'A'
		
			_oPrint:Say( 290 , _ncolini + 970 , "Advert�ncia   " 								, _oFont02 )
			
			_npagi++
				
			//====================================================================================================
			// Adiciona cabecalho de conte�do
			//====================================================================================================
			_nLinha := 405
			
		
    	   _oPrint:Say(  _nLinha , _ncolini, ALLTRIM(SM0->M0_CIDCOB) + ", " + STRZERO(DAY(DATE()),2) + " de " + ALLTRIM(MESEXTENSO(Date())) + " de " + STRZERO(YEAR(DDATABASE),4) + "." 	, _oFont03			)
			_nLinha += 150
			_oPrint:Say(  _nLinha , _ncolini, "Ao Sr.(a): " + alltrim(_adados[_ni][4]) + ", Filial/Matr�cula: " + _adados[_ni][1] + "/" + _adados[_ni][3] , _oFont03			)
			_nLinha += 90
			_oPrint:Say(  _nLinha , _ncolini, "Esta carta tem a finalidade de advertir-lhe, em raz�o da(s) Notifica��o(�es) recebida(s) referente a(s)", _oFont03			)
			_nLinha += 90
			_oPrint:Say(  _nLinha,  _ncolini, "seguinte(s) ocorr�ncia(s) e irregularidade(s) abaixo discriminada(s):", _oFont03			)
			_nLinha += 90
   	 
		ElseIf _adados[_ni][5] == 'O' 
		
			_oPrint:Say( 290 , _ncolini + 970 , "Ocorr�ncia   " 								, _oFont02 )
			
			_npagi++
				
			//====================================================================================================
			// Adiciona cabecalho de conte�do
			//====================================================================================================
			_nLinha := 405
		
		    _oPrint:Say(  _nLinha , _ncolini, ALLTRIM(SM0->M0_CIDCOB) + ", " + STRZERO(DAY(DATE()),2) + " de " + ALLTRIM(MESEXTENSO(Date())) + " de " + STRZERO(YEAR(DDATABASE),4) + "." 	, _oFont03			)
			_nLinha += 150
			_oPrint:Say(  _nLinha , _ncolini, "Ao Sr.(a): " + alltrim(_adados[_ni][4]) + ", Filial/Matr�cula: " + _adados[_ni][1] + "/" + _adados[_ni][3] , _oFont03			)
			_nLinha += 75
			_oPrint:Say(  _nLinha , _ncolini, "Esta carta tem a finalidade de notificar-lhe, em raz�o da(s) seguinte(s) ocorr�ncia(s) e irregularidade(s) ", _oFont03			)
			_nLinha += 75
			_oPrint:Say(  _nLinha,  _ncolini, "abaixo discriminada(s):", _oFont03			)
			_nLinha += 90
    
		ElseIf _adados[_ni][5] == 'S' 
		
			_oPrint:Say( 290 , _ncolini + 970 , "Suspen��o   " 								, _oFont02 )
			
			_npagi++
				
			//====================================================================================================
			// Adiciona cabecalho de conte�do
			//====================================================================================================
			_nLinha := 405
		
		    _oPrint:Say(  _nLinha , _ncolini, ALLTRIM(SM0->M0_CIDCOB) + ", " + STRZERO(DAY(DATE()),2) + " de " + ALLTRIM(MESEXTENSO(Date())) + " de " + STRZERO(YEAR(DDATABASE),4) + "." 	, _oFont03			)
			_nLinha += 150
			_oPrint:Say(  _nLinha , _ncolini, "Ao Sr.(a): " + alltrim(_adados[_ni][4]) + ", Filial/Matr�cula: " + _adados[_ni][1] + "/" + _adados[_ni][3] , _oFont03			)
			_nLinha += 75
			_oPrint:Say(  _nLinha , _ncolini, "Esta carta tem a finalidade de suspen��o, em raz�o da(s) seguinte(s) ocorrencia(s) e irregularidade(s)", _oFont03			)
			_nLinha += 75
			_oPrint:Say(  _nLinha,  _ncolini, "abaixo discriminada(s):", _oFont03			)
			_nLinha += 90
    		
		Else
		
			_oPrint:Say( 290 , _ncolini + 970 , "Notifica��o   " 								, _oFont02 )
			
			_npagi++
				
			//====================================================================================================
			// Adiciona cabecalho de conte�do
			//====================================================================================================
			_nLinha := 405
		
		    _oPrint:Say(  _nLinha , _ncolini, ALLTRIM(SM0->M0_CIDCOB) + ", " + STRZERO(DAY(DATE()),2) + " de " + ALLTRIM(MESEXTENSO(Date())) + " de " + STRZERO(YEAR(DDATABASE),4) + "." 	, _oFont03			)
			_nLinha += 150
			_oPrint:Say(  _nLinha , _ncolini, "Ao Sr.(a): " + alltrim(_adados[_ni][4]) + ", Filial/Matr�cula: " + _adados[_ni][1] + "/" + _adados[_ni][3] , _oFont03			)
			_nLinha += 75
			_oPrint:Say(  _nLinha , _ncolini, "Esta carta tem a finalidade de notificar-lhe, em raz�o da(s) seguinte(s) ocorr�ncia(s) e irregularidade(s) ", _oFont03			)
			_nLinha += 75
			_oPrint:Say(  _nLinha,  _ncolini, "abaixo discriminada(s):", _oFont03			)
			_nLinha += 90
    
		
		EndIf
	
	Endif
		
EndIf

Return _nlinha
