/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 10/05/2022 | Chamado 40071. Tratamento para novos filtros de "Tipo de Evento" e "Lista por".
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 17/05/2022 | Chamado 40149. Novos campos (Departamento / Eventos) na opcao 4.
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 09/06/2022 | Chamado 40412. Mostrar as horas com separador de decimmais com "," .
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 21/09/2023 | Chamado 45102. Fernando. Correção de error.log: variable does not exist _ABUTTONS. 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 19/10/2023 | Chamado 45371. Fernando. Correção de error.log: array out of bounds [1] of [0].
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE "PROTHEUS.CH"
#Define CRLF	Chr(13)+Chr(10)

/*
===============================================================================================================================
Programa----------: RPON018
Autor-------------: Alex Wallauer
Data da Criacao---: 16/02/2022
===============================================================================================================================
Descrição---------: Chamado 39218 - Fernando. Relatório de Acompanhamento de Hora Extra. 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RPON018()//U_RPON018

Local _cTitulo    := "Relatório de Acompanhamento de Hora Extra" 
Local _aDados	:= {}
Local oproc     := nil
Local nI		:= 0 
Local _aParRet	:= {}
Local _aParAux  := {}
Local _nTamFil	:= ( 2 )
Local _nTamCat	:= ( U_ITCONREG( "SX5" , "28" ) )
Local _nTamSit	:= ( U_ITCONREG( "SX5" , "31" ) )
Local _nTamSet	:= ( 16 * TamSX3("ZAK_COD")[01] )

SET DATE FORMAT TO "DD/MM/YYYY"

//Incluir o Pergunte - Tipo de Evento = 1 - Hora Extra, 2 - Atraso/Falta, 3 - Outros
//1 - Hora Extra = SP9_CLASEV = 01
//2 - Atraso/Falta = SP9_CLASEV = 02,03,04,05
//3 - Outros = SP9_CLASEV = ZZ

_BSelecSP9:={|| "SELECT P9_CODIGO,P9_DESC FROM "+RETSQLNAME("SP9")+" SP9 "+;
                " WHERE  D_E_L_E_T_ <> '*' AND P9_CLASEV "+  IF(MV_PAR09="1"," = '01' ",IF(MV_PAR09="2"," IN ('02','03','04','05') "," = 'ZZ' "))+" AND "+;
				" P9_FILIAL = '"+cFilAnt+"' ORDER BY P9_CODIGO " }

_aItalac_F3:={}//       1           2         3                      4                      5          6                      7         8          9         10         11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave            , _nCpoDesc              ,_bCondTab    , _cTitAux           , _nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR10" ,_BSelecSP9,{|Tab| (Tab)->P9_CODIGO }, {|Tab|(Tab)->P9_DESC              },,"Eventos"         ,          ,          ,          ,.T.        ,       , } ) 

aAdd( _aParAux , { 1 , "Filiais"		, SPACE(_nTamFil)			 , "@!" , "U_RPON018P(1)", "LSTFIL"	, "" , 100 , .F. }) // MV_PAR01
aAdd( _aParAux , { 1 , "Data Inicial"	, CTOD(SPACE(8))			 , "@D" , ""			 , ""		, "" , 050 , .T. }) // MV_PAR02
aAdd( _aParAux , { 1 , "Data Final"		, CTOD(SPACE(8))			 , "@D" , ""			 , ""		, "" , 050 , .T. }) // MV_PAR03
aAdd( _aParAux , { 1 , "Matrícula De"	, SPACE(LEN(SRA->RA_MAT))    , "@!" , ""			 , "SRA"    , "" , 050 , .F. }) // MV_PAR04
aAdd( _aParAux , { 1 , "Matrícula Até"	, SPACE(LEN(SRA->RA_MAT))    , "@!" , ""			 , "SRA"    , "" , 050 , .F. }) // MV_PAR05
aAdd( _aParAux , { 1 , "Categorias"		, SPACE(_nTamCat)			 , "@!" , "U_RPON018P(2)", "LSTCAT"	, "" , 080 , .F. }) // MV_PAR06
aAdd( _aParAux , { 1 , "Situações"		, SPACE(_nTamSit)			 , "@!" , "U_RPON018P(3)", "SX5L31"	, "" , 050 , .F. }) // MV_PAR07
aAdd( _aParAux , { 1 , "Setores"		, Space(_nTamSet)			 , "@!" , "" 			 , "ZAK001"	, "" , 100 , .F. }) // MV_PAR08
aAdd( _aParAux , { 2 , "Tipo Eventos"	, "1"		      		     , {"1-Hora Extra","2-Atraso/Falta", "3-Outros"}, 060,".T.",.T. ,".T."}) // MV_PAR09
aAdd( _aParAux , { 1 , "Eventos"		, Space(100)      		     , "@!" , "" 			 , "F3ITLC"	, "" , 100 , .T. })                  // MV_PAR10
AADD( _aParAux , { 2 , "Lista por"      , "1"		      		     , {"1-Função","2-Setor","3-Funcionario","4-Funcionario Dia"}, 060,".T.",.T. ,".T."}) // MV_PAR11

For nI := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nI][03] )
Next nI

DO WHILE .T.

     //ParamBox( _aParAux , cTitle                                  , @aRet     ,[bOk]    , [ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ] 
   IF !ParamBox( _aParAux , "Digite os filtros dos dados das Horas" , @_aParRet ,{||.T.}  , /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
       EXIT
   EndIf

   IF EMPTY(MV_PAR02) .OR.  EMPTY(MV_PAR03) .OR.  MV_PAR02 > MV_PAR03
      U_ITMSG("Periodo INVALIDO",'Atenção!',"Tente novamente com outro periodo com as 2 datas preenchidas",3)
      LOOP
   ENDIF
   //Log de utilização
   U_ITLOGACS()

   _aDados  := {}
   _aColXML := {}
  _aAuxExtra:= {}
   _lSair   := .F.
   cTimeInicial:=TIME()

   FWMSGRUN( ,{|oproc| _aDados := RPON018SEL(oproc) } , "Aguarde!" , "Lendo dados..." )

    IF LEN(_aDados) > 0

        aCab:={}
        _aCabXML:={}
		// Alinhamento: 1-Left   ,2-Center,3-Right
		// Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
	    IF MV_PAR11 = "1"
           AADD(aCab,"Setor")
		   //          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
		   AADD(_aCabXML,{aCab[LEN(aCab)],1           ,1         ,.F.})
           AADD(aCab,"Função")           
		   //          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
		   AADD(_aCabXML,{aCab[LEN(aCab)],1           ,1         ,.F.})
           AADD(aCab,"No. Colaboradores") 
		   //          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
		   AADD(_aCabXML,{aCab[LEN(aCab)],1           ,1         ,.F.})
           AADD(aCab,"No. Horas")                    
		   //          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
		   AADD(_aCabXML,{aCab[LEN(aCab)],3           ,2         ,.F.})
           AADD(aCab,"Medias de Horas")
		   //          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
		   AADD(_aCabXML,{aCab[LEN(aCab)],3           ,2         ,.F.})

	    ELSEIF MV_PAR11 = "2"
           AADD(aCab,"Setor")
		   //          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
		   AADD(_aCabXML,{aCab[LEN(aCab)],1           ,1         ,.F.})
           AADD(aCab,"No. Colaboradores") 
		   //          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
		   AADD(_aCabXML,{aCab[LEN(aCab)],1           ,1         ,.F.})
           AADD(aCab,"No. Horas")
		   //          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
		   AADD(_aCabXML,{aCab[LEN(aCab)],3           ,2         ,.F.})
           AADD(aCab,"Medias de Horas")
		   //          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
		   AADD(_aCabXML,{aCab[LEN(aCab)],3           ,2         ,.F.})
	    ELSEIF MV_PAR11 = "3"
           AADD(aCab,"Matricula")
		   //          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
		   AADD(_aCabXML,{aCab[LEN(aCab)],1           ,1         ,.F.})
           AADD(aCab,"Funcionario")
		   //          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
		   AADD(_aCabXML,{aCab[LEN(aCab)],1           ,1         ,.F.})
           AADD(aCab,"No. Horas")
		   //          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
		   AADD(_aCabXML,{aCab[LEN(aCab)],3           ,2         ,.F.})
	    ELSEIF MV_PAR11 = "4"
           AADD(aCab,"Matricula")
		   //          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
		   AADD(_aCabXML,{aCab[LEN(aCab)],1           ,1         ,.F.})
           AADD(aCab,"Funcionario")
		   //          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
		   AADD(_aCabXML,{aCab[LEN(aCab)],1           ,1         ,.F.})
           AADD(aCab,"Departamento")
		   //          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
		   AADD(_aCabXML,{aCab[LEN(aCab)],1           ,1         ,.F.})
           AADD(aCab,"Data")
		   //          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
		   AADD(_aCabXML,{aCab[LEN(aCab)],1           ,1         ,.F.})
           AADD(aCab,"Eventos")
		   //          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
		   AADD(_aCabXML,{aCab[LEN(aCab)],1           ,1         ,.F.})
           AADD(aCab,"No. Horas")
		   //          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
		   AADD(_aCabXML,{aCab[LEN(aCab)],3           ,2         ,.F.})
        ENDIF

        _cTitulo2:=_cTitulo+' - Data: ' + DtoC(Date()) +" -  H.I.: "+cTimeInicial+" H.F.: "+TIME()
        _cMsgTop:="Par. 1: "+ALLTRIM(AllToChar(MV_PAR01))+"; Par. 2: "+ALLTRIM(AllToChar(MV_PAR02))+"; Par. 3: "+ALLTRIM(AllToChar(MV_PAR03))+"; Par. 4: "+ALLTRIM(AllToChar(MV_PAR04))+;
                "; Par. 5: "+ALLTRIM(AllToChar(MV_PAR05))+"; Par. 6: "+ALLTRIM(AllToChar(MV_PAR06))+"; Par. 7: "+ALLTRIM(AllToChar(MV_PAR07))+"; Par. 7: "+ALLTRIM(AllToChar(MV_PAR08))+;
                "; Par. 9: "+ALLTRIM(AllToChar(MV_PAR09))+"; Par. 10: "+ALLTRIM(AllToChar(MV_PAR10))+"; Par. 11: "+ALLTRIM(AllToChar(MV_PAR11))
        _aButtons:=NIL
        IF LEN(_aAuxExtra) > 0
		   _aCabAux:={"Data","Horas","Evento","Filial + Matricula"}
           _aButtons:={}
           AADD(_aButtons,{"BUDGET",{||  U_ITListBox( _cMsgTop , _aCabAux , _aAuxExtra , .F.      , 1 )  },"Detalhar Horas", "Detalhar Horas" }) 
        ENDIF
                                //        ,_aCols  ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab  , bDblClk , _aColXML , bCondMarca )
       _lSair:=!U_ITListBox(_cTitulo2,aCab,_aDados , .T.    , 1    ,_cMsgTop,          ,        ,         ,     ,        , _aButtons,_aCabXML,         , _aColXML ,            )
    
    ELSE
      
      U_ITMSG("Não á registro para esses filtros",'Atenção!',"Tente novamente com outros filtros",3)
      
      LOOP
    
    ENDIF

   IF _lSair
      EXIT
   ENDIF   

ENDDO


Return Nil


/*
===============================================================================================================================
Programa----------: RPON018SEL
Autor-------------: Alex Wallauer
Data da Criacao---: 16/02/2022
===============================================================================================================================
Descrição---------: Carga de dados para o relatório
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processmento 
===============================================================================================================================
Retorno-----------: _aret - dados coletados do banco
===============================================================================================================================
*/
Static Function RPON018SEL(oproc)
Local _aRet		:= {}
Local _cAlias	:= GetNextAlias()
Local _aFiliais:= {}
Local _cQuery	:= ""
Local _nI,nI,_nA:= A := 0

_aFiliais:= StrToKArr( AllTrim(MV_PAR01) , ";" )

IF Empty(_aFiliais)

	u_itmsg(  "Não foram informadas Filiais válidas para o processamento!" , "Atenção!" ,,1 )
    RETURN {}

EndIF

For _nI := 1 To Len( _aFiliais )

	_cQuery := " SELECT "
	_cQuery += " R_E_C_N_O_ RECNO  "	  
	_cQuery += " FROM "+ RetSqlName("SRA") +" SRA "+ CRLF
	_cQuery += " WHERE "
	_cQuery += " 	RA_FILIAL = '"+ _aFiliais[_nI] +"' "+ CRLF
	_cQuery += " AND D_E_L_E_T_	= ' ' "+ CRLF
	If !EMPTY(MV_PAR04) 
		_cQuery += " AND RA_MAT >= '" + MV_PAR04 + "'  "
	Endif
	If !EMPTY(MV_PAR05)
		_cQuery += " AND RA_MAT <= '" + MV_PAR05 + "' "
	Endif
	
	If !EMPTY(MV_PAR06)
		cCatFun:=AllTrim(MV_PAR06)
		_cQuery += "AND trim(SRA.RA_CATFUNC) IN "+ FormatIn( RTrim( cCatFun ) , ";" )
	Endif 
	
	If !EMPTY(MV_PAR07)
		cSitFol:=""
	    For nI := 1 To Len( ALLTRIM(MV_PAR07) )
	    	If SubStr( ALLTRIM(MV_PAR07) , nI , 1 ) <> "*"
	    		cSitFol += SubStr( ALLTRIM(MV_PAR07) , nI , 1 ) + ";"
	    	EndIf
	    Next
	    cSitFol := SubStr( cSitFol , 1 , Len(cSitFol) - 1 )
		If " " $ RTRIM(MV_PAR07)
			_cQuery += " AND (trim(SRA.RA_SITFOLH)  IN "+ FormatIn( RTRIM( cSitFol ) , ";" ) + " OR SRA.RA_SITFOLH = ' ') "
		Else
			_cQuery += " AND trim(SRA.RA_SITFOLH)  IN "+ FormatIn( RTRIM( cSitFol ) , ";" )
		Endif 
	Endif

  	IF !Empty( MV_PAR08 )	
		_cQuery += " AND SRA.RA_I_SETOR	IN "+ FormatIn( AllTrim( MV_PAR08 ) , ";" ) + CRLF	
	EndIF
	
	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )
	
	DBSelectArea(_cAlias)
   _cTot := 0
	COUNT TO  _cTot
   _cTot:=ALLTRIM(STR(_cTot))
   _nTam:=LEN(_cTot)
   SPI->(DBSETORDER(2))

	(_cAlias)->( DBGoTop() )
	_nni := 0

	Do while (_cAlias)->( !Eof() )
		
		_nni++
		oproc:cCaption := ("Lendo Filial: " + _aFiliais[_ni] + " / funcionario " +STRZERO(_nni,_nTam) +" de "+ _cTot )
		ProcessMessages()
		
      SRA->(Dbgoto((_cAlias)->RECNO))

      _aMinExtra:= {}
      nMinExtras:=BuscaHextras()
      FOR A := 1 TO LEN(_aMinExtra)
	      AADD(_aAuxExtra,ACLONE( _aMinExtra[A] ))
	  NEXT

	  _cCargo:=""
	  IF MV_PAR11 = "1"
         _cCargo:=SRA->RA_CARGO
	  
	  ELSEIF MV_PAR11 = "3"
         AADD( _aRet , { SRA->RA_MAT , SRA->RA_NOME , 1 ,nMinExtras}) 
		 (_cAlias)->(Dbskip())
		 LOOP
	  
	  ELSEIF MV_PAR11 = "4"
	     FOR _nA := 1 To Len( _aMinExtra )                                 //4-HE               5-DATA APONTAMENTO   , 6-EVENTO         ,  7-DEPARTAMENTO 
	        AADD( _aRet , { SRA->RA_MAT , SRA->RA_NOME , IF(_nA=1,1,0) ,_aMinExtra[_nA,2]  , DTOC(_aMinExtra[_nA,1]) ,_aMinExtra[_nA,3] , POSICIONE("SQB",1,SRA->RA_FILIAL+SRA->RA_DEPTO,"QB_DESCRIC") }) 
		 NEXT
		 (_cAlias)->(Dbskip())
		 LOOP
      ENDIF			
      //MV_PAR11 = "1" E "2"
	  IF (_nPos:= ASCAN(_aRet , {|R| R[1]==SRA->RA_I_SETOR .AND. R[2]==_cCargo })) = 0
		 AADD( _aRet , { SRA->RA_I_SETOR , _cCargo    , 1 , nMinExtras  }) 
      ELSE
         _aRet[_nPos,3]+=1
         _aRet[_nPos,4]+=nMinExtras
      ENDIF						
		
      (_cAlias)->(Dbskip())
		
	Enddo

Next

_aRet2:={}
_nTotFunc:=0
//_nTotCHorE:=0//Centesimal
_nTotSHorE:=0//Sexagenal
For _nI := 1 To Len( _aRet )
   nHoraExtra :=ROUND( (_aRet[_nI,4]*100)/60,2)//TOTAL DE HORAS GERAL  //Centesimal
   nHora2Extra:=INT(nHoraExtra)//INTEIRO DA HORA
   nHora2Extra:=(nHora2Extra*60)//TOTAL DE MINUTOS HORA CHEIA
   nHora2Extra:=(_aRet[_nI,4]*100)-nHora2Extra//TOTAL DE MINUTOS - TOTAL DE MINUTOS DAS HORAS CHEIAS
   nHora2Extra:=INT(nHoraExtra)+(nHora2Extra/100)//SOMA OS RESTOS DOS MINUTOS
   nHora2Extra:=ROUND(nHora2Extra,2)//Sexagesimal
   cHora2Extra:=TRANS(nHora2Extra,"@E 999999999.99") 
   nMediaHora2:=ROUND(IF(_aRet[_nI,3]=0,0,nHora2Extra/_aRet[_nI,3]),2)
   cMediaHora2:=TRANS(nMediaHora2,"@E 999999999.99") 
	IF MV_PAR11 = "1"//QUEBRA POR SETOR+FUNCAO
      AADD(_aRet2,{POSICIONE("ZAK",1,xfilial("ZAK")+_aRet[_nI,1],"ZAK_DESCRI"),;//Setor
                   POSICIONE("SQ3",1,xFilial("SQ3")+_aRet[_nI,2],"Q3_DESCSUM"),;//Função        
                   _aRet[_nI,3],;//                   nHoraExtra,; //Centesimal //No. Colaboradores
                   cHora2Extra,;//Sexagesimal                                   //No. Horas     
                   cMediaHora2;                                                 //Medias de Horas
                  })
	  AADD(_aColXML,{_aRet2[LEN(_aRet2),1] , _aRet2[LEN(_aRet2),2] , _aRet2[LEN(_aRet2),3] ,nHora2Extra, nMediaHora2})
   ELSEIF MV_PAR11 = "2"//QUEBRA SÓ POR SETOR
      AADD(_aRet2,{POSICIONE("ZAK",1,xfilial("ZAK")+_aRet[_nI,1],"ZAK_DESCRI"),;//Setor
                   _aRet[_nI,3],;//                   nHoraExtra,;//Centesimal  //No. Colaboradores
                   cHora2Extra,;//Sexagesimal                                   //No. Horas     
                   cMediaHora2;                                                 //Medias de Horas
                  })
	  AADD(_aColXML,{_aRet2[LEN(_aRet2),1] , _aRet2[LEN(_aRet2),2] , nHora2Extra, nMediaHora2})
	ELSEIF MV_PAR11 = "3"//POR FUNCIONARIO
      AADD(_aRet2,{_aRet[_nI,1],;//MATRICULA
                   _aRet[_nI,2],;//Funcionario
				   cHora2Extra;  //No. Horas - Sexagenal
                   })                  
	  AADD(_aColXML,{_aRet2[LEN(_aRet2),1] , _aRet2[LEN(_aRet2),2] , nHora2Extra})
	ELSEIF MV_PAR11 = "4"//POR FUNCIONARIO POR DIA
      AADD(_aRet2,{_aRet[_nI,1],;//01-MATRICULA
                   _aRet[_nI,2],;//02-NOME
                   _aRet[_nI,7],;//03-DEPARTAMENTO
                   _aRet[_nI,5],;//04-DATA
                   _aRet[_nI,6],;//05-EVENTO
				   cHora2Extra;  //06-HORA - Sexagenal
                   })                  
	  AADD(_aColXML,{_aRet2[LEN(_aRet2),1] , _aRet2[LEN(_aRet2),2] , _aRet2[LEN(_aRet2),3] ,_aRet2[LEN(_aRet2),4] ,_aRet2[LEN(_aRet2),5] ,nHora2Extra})
   ENDIF
   _nTotFunc +=_aRet[_nI,3]
// _nTotCHorE+= nHoraExtra//Centesimal
// _nTotSHorE+= nHora2Extra//Sexagesimal
NEXT


IF MV_PAR11 = "1"//QUEBRA POR SETOR+FUNCAO
   ASORT(_aRet2,,, { | x,y | x[1]+x[2] < y[1]+y[2] })
   AADD( _aRet2 , { "TOTAL " , "" , _nTotFunc          , /*TRANS(_nTotSHorE,"@E 999999999.99")*/   , '' })//5 Colunas
   ASORT(_aColXML,,, { | x,y | x[1]+x[2] < y[1]+y[2] })
   AADD( _aColXML , { "TOTAL " , "" , _nTotFunc        , /*TRANS(_nTotSHorE,"@E 999999999.99")*/   , '' })//5 Colunas
ELSEIF MV_PAR11 = "2"//QUEBRA SÓ POR SETOR
   ASORT(_aRet2,,, { | x,y | x[1] < y[1] })
   AADD( _aRet2 , { "TOTAL" ,      _nTotFunc          ,  /*TRANS(_nTotSHorE,"@E 999999999.99")*/ , '' })//4 Colunas
   ASORT(_aColXML,,, { | x,y | x[1] < y[1] })
   AADD( _aColXML , { "TOTAL" ,      _nTotFunc        ,  /*TRANS(_nTotSHorE,"@E 999999999.99")*/ , '' })//4 Colunas
ELSEIF MV_PAR11 = "3"//POR FUNCIONARIO
   ASORT(_aRet2,,, { | x,y | x[1] < y[1] })
   AADD( _aRet2 , { "TOTAL" , _nTotFunc               , /*TRANS(_nTotSHorE,"@E 999999999.99")*/ })//3 Colunas
   ASORT(_aColXML,,, { | x,y | x[1] < y[1] })
   AADD( _aColXML , { "TOTAL" , _nTotFunc             , /*TRANS(_nTotSHorE,"@E 999999999.99")*/ })//3 Colunas
ELSEIF MV_PAR11 = "4"//POR FUNCIONARIO POR DIA
   ASORT(_aRet2,,, { | x,y | x[1]+DTOS(CTOD(x[4])) < y[1]+DTOS(CTOD(y[4])) })
// AADD( _aRet2 , { "TOTAIS" , ""  ,""  ,  ""  ,  "" , /*TRANS(_nTotSHorE,"@E 999999999.99")*/ })//6 Colunas
   ASORT(_aColXML,,, { | x,y | x[1]+DTOS(CTOD(x[4])) < y[1]+DTOS(CTOD(y[4])) })
// AADD( _aColXML , { "TOTAIS" , ""  ,""  ,  ""  ,  "" , /*TRANS(_nTotSHorE,"@E 999999999.99")*/ })//6 Colunas
ENDIF

IF MV_PAR11 <> "4"
   IF LEN(_aRet2[1]) <> LEN(_aRet2[LEN(_aRet2)])
      U_ITMSG("Ultima linha do _aRet2 (TOTAIS) esta com menos colunas que as demais linhas anteriores",'Atenção!',"Insira o mesmo numero de colunas no AADD do _aRet2 de 'TOTAIS' ",3)
   ENDIF
ENDIF

Return( _aRet2 )

/*
===============================================================================================================================
Programa----------: BuscaHextras
Autor-------------: Alex Wallauer
Data da Criacao---: 16/02/2022
===============================================================================================================================
Descrição---------: Retorna HORAS EXTRAS DO FUNCIONARIO
===============================================================================================================================
Parametros--------: SRA POSICIONADA
===============================================================================================================================
Retorno-----------:  HORAS EXTRAS 
===============================================================================================================================
*/
Static Function BuscaHextras()
Local _cAlias	:= GetNextAlias()
Local _cQuery	:= ""
Local _nMinExtra:= 0
_aMinExtra:= {}

_cQuery += " SELECT SPC.PC_FILIAL,SPC.PC_DATA,SPC.PC_PD,  SPC.PC_QUANTC AS TOTHE "+ CRLF
_cQuery += " FROM "+ RetSqlName("SPC") +" SPC "+ CRLF
_cQuery += " WHERE "+ CRLF
_cQuery += "     SPC.D_E_L_E_T_  = ' ' "+ CRLF
_cQuery += " AND SPC.PC_ABONO    = ' ' "+ CRLF
_cQuery += " AND SPC.PC_PD	IN "+ FormatIn( AllTrim( MV_PAR10 ) , ";" ) + CRLF	
_cQuery += " AND SPC.PC_FILIAL  = '"+ SRA->RA_FILIAL +"' " + CRLF
_cQuery += " AND SPC.PC_DATA BETWEEN '"+ DTOS( MV_PAR02 ) +"' AND '"+ DTOS( MV_PAR03 ) +"' "+ CRLF
_cQuery += " AND SPC.PC_MAT = '"+SRA->RA_MAT+"' "+ CRLF
//_cQuery += " GROUP BY SPC.PC_FILIAL,SPC.PC_DATA,SPC.PC_PD "
_cQuery += " ORDER BY SPC.PC_FILIAL,SPC.PC_DATA,SPC.PC_PD "

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .T. )

DO WHILE !(_cAlias)->(Eof())
   IF (_cAlias)->TOTHE >= 1
      nHora:=INT((_cAlias)->TOTHE) 
      nMin:= ((_cAlias)->TOTHE) - nHora
      _nMinExtra+= ( ( nHora * 0.60) + nMin )//Soma 0.60 pq a somatoria dos minutos esta dividida por 100
      AADD(_aMinExtra,{STOD((_cAlias)->PC_DATA) , ( ( nHora * 0.60) + nMin ) , (_cAlias)->PC_PD+"-"+Posicione("SP9",1,(_cAlias)->PC_FILIAL+(_cAlias)->PC_PD ,"P9_DESC")  , SPH->PH_FILIAL+SPH->PH_MAT })
   ELSE
      _nMinExtra+=(_cAlias)->TOTHE//Soma os minutos divididos por 100
      AADD(_aMinExtra,{STOD((_cAlias)->PC_DATA) , (_cAlias)->TOTHE , (_cAlias)->PC_PD+"-"+Posicione("SP9",1,(_cAlias)->PC_FILIAL+(_cAlias)->PC_PD ,"P9_DESC")  , SPH->PH_FILIAL+SPH->PH_MAT })
   ENDIF
   (_cAlias)->(DBSKIP())
ENDDO

(_cAlias)->(DbCloseArea())

_cQuery := " SELECT SPH.PH_FILIAL, SPH.PH_DATA, SPH.PH_PD, SPH.PH_QUANTC AS TOTHE , SPH.PH_MAT"+ CRLF
_cQuery += " FROM "+ RetSqlName("SPH") +" SPH "+ CRLF
_cQuery += " WHERE "+ CRLF
_cQuery += "     SPH.D_E_L_E_T_  = ' ' "+ CRLF
_cQuery += " AND SPH.PH_ABONO    = ' ' "+ CRLF
_cQuery += " AND SPH.PH_PD IN "+ FormatIn( AllTrim( MV_PAR10 ) , ";" ) + CRLF	
_cQuery += " AND SPH.PH_FILIAL  = '"+ SRA->RA_FILIAL +"' " + CRLF
_cQuery += " AND SPH.PH_DATA BETWEEN '"+ DTOS( MV_PAR02 ) +"' AND '"+ DTOS( MV_PAR03 ) +"' "+ CRLF
_cQuery += " AND SPH.PH_MAT = '"+SRA->RA_MAT+"' "+ CRLF
//_cQuery += " GROUP BY SPH.PH_FILIAL, SPH.PH_DATA, SPH.PH_PD "
_cQuery += " ORDER BY SPH.PH_FILIAL, SPH.PH_DATA, SPH.PH_PD "

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .T. )

DO WHILE !(_cAlias)->(Eof())
   IF (_cAlias)->TOTHE >= 1
      nHora:=INT((_cAlias)->TOTHE) 
      nMin:= ((_cAlias)->TOTHE) - nHora
      _nMinExtra+= ( (nHora * 0.60) + nMin )//Soma 0.60 pq a somatoria dos minutos esta dividida por 100
      AADD(_aMinExtra,{STOD((_cAlias)->PH_DATA) , ( ( nHora * 0.60) + nMin )  , (_cAlias)->PH_PD+"-"+Posicione("SP9",1,(_cAlias)->PH_FILIAL+(_cAlias)->PH_PD ,"P9_DESC") , SPH->PH_FILIAL+SPH->PH_MAT })
   ELSE
      _nMinExtra+=(_cAlias)->TOTHE//Soma os minutos divididos por 100
      AADD(_aMinExtra,{STOD((_cAlias)->PH_DATA) , (_cAlias)->TOTHE , (_cAlias)->PH_PD+"-"+Posicione("SP9",1,(_cAlias)->PH_FILIAL+(_cAlias)->PH_PD ,"P9_DESC") , SPH->PH_FILIAL+SPH->PH_MAT })


   ENDIF
   (_cAlias)->(DBSKIP())
ENDDO

(_cAlias)->(DbCloseArea())

Return _nMinExtra

/*
===============================================================================================================================
Programa----------: RPON018P
Autor-------------: Alex Wallauer
Data da Criacao---: 16/02/2022
===============================================================================================================================
Descrição---------: Validação das Perguntas da Rotina
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RPON018P( _nOpc )

Local _lRet		:= .T. //Se retornar .F. nao deixa sair do campo
Local _cNomeVar	:= ReadVar()
Local _xVarAux	:= &(_cNomeVar)
Local _aArea	:= GetArea()
Local _cEmpAux	:= cEmpAnt
Local _aDadAux	:= {}
Local _nI		:= 0

Do Case
	
	Case _nOpc == 1 //Filiais Consideradas ?
		
		//-- Verifica se o campo esta vazio --//
		If EMPTY(_xVarAux)
			
//			u_itmsg(  "É obrigatório informar o filtro de Filiais, clique em 'selecionar todas' para utilizar todas as Filiais." , "Atenção!" ,,1 )
//			_lRet := .F.
			
			//-- Verifica se o campo foi preenchido com conteudo valido --//
		Else
			
			_aDadAux := U_ITLinDel( AllTrim(_xVarAux),";" )
			For _nI := 1 To Len(_aDadAux)
				
				_lRet := .F.
				DBSelectArea("SM0")
				SM0->( DBGoTop() )
				While SM0->(!Eof())
					
					If SM0->M0_CODIGO == _cEmpAux .And. ALLTRIM(SM0->M0_CODFIL) == _aDadAux[_nI]
						_lRet := .T.
						Exit
					EndIf
					
					SM0->( DBSkip() )
				EndDo
				
				If !_lRet
					u_itmsg(  "As 'Filiais' informadas não são válidas! Verifique os dados digitados." , "Atenção!" ,,1)
					Exit
				EndIf
				
			Next _nI
			
		EndIf
		
	Case _nOpc == 2 //Categorias a Imp. ?
		
		If EMPTY(_xVarAux)
			
			//u_itmsg(  "É obrigatório informar o filtro de Categorias Funcionais, clique em 'selecionar todas' para utilizar todas as Categorias." , "Atenção!" ,,1 )
			//_lRet := .F.
			
		Else
			
			_aDadAux := U_ITLinDel( AllTrim(_xVarAux),";",1)
			DBSelectArea("SX5")
			SX5->( DBSetOrder(1) )
			SX5->( DBGoTop() )
			
			For _nI := 1 To Len(_aDadAux)
				
				If _aDadAux[_nI] <> "*" .AND. !SX5->( DBSeek( xFilial("SX5") + "28" + _aDadAux[_nI] ) )
					
					u_itmsg(  "As 'Categorias Funcionais' informadas não são válidas! Verifique os dados digitados." ,"Atenção!" ,,1 )
					_lRet := .F.
					Exit
					
				EndIf
				
			Next _nI
			
		EndIF
		
	Case _nOpc == 3 //Situações ?
		
		If EMPTY(_xVarAux)
			
			//&(_cNomeVar) := " ;"
			
		Else
			
			_aDadAux := U_ITLinDel( _xVarAux,,1 )
			DBSelectArea("SX5")
			SX5->( DBSetOrder(1) )
			SX5->( DBGoTop() )
			
			For _nI := 1 To Len(_aDadAux)
				
				If _aDadAux[_nI] <> "*" .AND. !SX5->( DBSeek( xFilial("SX5") + "31" + _aDadAux[_nI] ) )
					
					u_itmsg( "As 'Situações na Folha' informadas não são válidas! Verifique os dados digitados." ,"Atenção!" , ,1)
					_lRet := .F.
					Exit
					
				EndIf
				
			Next _nI
			
		EndIf
		
	
EndCase

RestArea(_aArea)

Return(_lRet)
