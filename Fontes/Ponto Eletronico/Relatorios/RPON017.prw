/*
===============================================================================================================================
                  ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                            
-------------------------------------------------------------------------------------------------------------------------------
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.Ch"

#Define TITULO	"Relatório de Bloqueio de Cracha"
#Define CRLF	Chr(13)+Chr(10)

/*
===============================================================================================================================
Programa----------: RPON017
Autor-------------: Alex Wallauer
Data da Criacao---: 08/02/2022
===============================================================================================================================
Descrição---------: Relatório de Bloqueio de Cracha - Chamado 39079
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RPON017()

Local _aDados	:= {}
Local oproc     := nil
Local nI		:= 0 
Local _aParRet	:= {}
Local _aParAux  := {}
Local _nTamFil	:= ( U_ITCONREG( "SM0" ) * 2 )
Local _nTamCat	:= ( U_ITCONREG( "SX5" , "28" ) )
Local _nTamSit	:= ( U_ITCONREG( "SX5" , "31" ) )


SET DATE FORMAT TO "DD/MM/YYYY"

aAdd( _aParAux , { 1 , "Filiais"		, SPACE(_nTamFil)				, "@!" , "U_RPON017P(1)", "LSTFIL"	, "" , 100 , .F. } )//MV_PAR01  LSTFIL SM0001
aAdd( _aParAux , { 1 , "Data Inicial"	, CTOD(SPACE(8))				, "@D" , ""				, ""		, "" , 050 , .T. } )//MV_PAR02
aAdd( _aParAux , { 1 , "Data Final"		, CTOD(SPACE(8))				, "@D" , ""				, ""		, "" , 050 , .T. } )//MV_PAR03
aAdd( _aParAux , { 1 , "Matrícula De"	, SPACE( TamSX3("RA_MAT")[01] ) , "@!" , ""				, "SRA"		, "" , 050 , .F. } )//MV_PAR04
aAdd( _aParAux , { 1 , "Matrícula Até"	, SPACE( TamSX3("RA_MAT")[01] )	, "@!" , ""				, "SRA"		, "" , 050 , .F. } )//MV_PAR05
aAdd( _aParAux , { 1 , "Categorias"		, SPACE(_nTamCat)				, "@!" , "U_RPON017P(2)", "LSTCAT"	, "" , 080 , .F. } )//MV_PAR06
aAdd( _aParAux , { 1 , "Situações"		, SPACE(_nTamSit)				, "@!" , "U_RPON017P(3)", "SX5L31"	, "" , 050 , .F. } )//MV_PAR07

For nI := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nI][03] )
Next nI

DO WHILE .T.

     //ParamBox( _aParAux , cTitle                                    , @aRet     ,[bOk]    , [ aButtons ] [ lCentered ] [ nPosX ] [ nPosy ] [ oDlgWizard ] [ cLoad ] [ lCanSave ] [ lUserSave ] 
   IF !ParamBox( _aParAux , "Digite os filtros dos dados dos Crachás" , @_aParRet ,{||.T.}  , /*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,.T.         ,.T.          )
       EXIT
   EndIf

   IF EMPTY(MV_PAR02) .OR.  EMPTY(MV_PAR03) .OR.  MV_PAR02 > MV_PAR03
      U_ITMSG("Periodo INVALIDO",'Atenção!',"Tente novamente com outro periodo com as 2 datas preenchidas",3)
      LOOP
   ENDIF
   //Log de utilização
   U_ITLOGACS()

	//============================================================================
	//| Verifica o registro de ponto em busca das informações                    |
	//============================================================================
	FWMSGRUN( ,{|oproc| _aDados := RPON017SEL(oproc) } , "Aguarde!" , "Selecionando dados..." )
	
    IF Empty(_aDados)
    	u_itmsg(  "Não foram encontrados registros para exibir! Verifique os parâmetros e tente novamente." , "Atenção" ,,1 )
    	LOOP
    EndIF
    
    _aCabec  := { "Filial"	, "Matrícula"	, "Funcionário"	, "Data de Bloqueio", "Hora de Bloqueio", "Data de Desbloqueio", "Hora de Desbloqueio","Motivo","Observação"}
    
    fwMsgRun( , {|| U_ITListBox( TITULO , _aCabec , _aDados , .T. ) },"Exportando dados para planilha, aguarde..." , TITULO  )

ENDDO

Return.T.

/*
===============================================================================================================================
Programa----------: RPON017SEL
Autor-------------: Alex Wallauer
Data da Criacao---: 08/02/2022
===============================================================================================================================
Descrição---------: Carga de dados para o relatório
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processmento
===============================================================================================================================
Retorno-----------: _aret - dados coletados do banco
===============================================================================================================================
*/
Static Function RPON017SEL(oproc)

Local _aRet			:= {}
Local _cAlias		:= GetNextAlias()
Local _cAlias2		:= GetNextAlias()
Local _cAlias3		:= GetNextAlias()
Local _cAlias4		:= GetNextAlias()
Local _aFiliais		:= {}
Local _cQuery		:= ""
Local _nTot			:= 0
Local _nI			:= 0 , nI
Local _nnj			:= 0

Default oproc := nil


_aFiliais			:= StrToKArr( AllTrim(MV_PAR01)+";" , ";" )

IF Empty(_aFiliais)

	u_itmsg(  "Não foram informadas Filiais válidas para o processamento!" , "Atenção!" ,,1 )

EndIF

For _nI := 1 To Len( _aFiliais )

	IF valtype(oproc) = "O"

		oproc:cCaption := ("Lendo funcionários da filial " + _aFiliais[_ni] + "...")
		ProcessMessages()
 
	ENDIF
	
	_cQuery := " SELECT "
	_cQuery += " R_E_C_N_O_ RECNO  "	  
	_cQuery += " FROM "+ RetSqlName("SRA") +" SRA "
	_cQuery += " WHERE "
	_cQuery += " 	RA_FILIAL = '"+ _aFiliais[_nI] +"' "
	_cQuery += " AND D_E_L_E_T_	= ' ' "
	
	If !EMPTY(MV_PAR04) 
		_cQuery += " AND RA_MAT >= '" + MV_PAR04 + "'  "
	Endif
	If !EMPTY(MV_PAR05)
		_cQuery += " AND RA_MAT <= '" + MV_PAR05 + "' "
	Endif
	
	If !EMPTY(MV_PAR06)
//	    MV_PAR06:=AllTrim(MV_PAR06)
		cCatFun:=AllTrim(MV_PAR06)
/*   	For nI := 1 To Len( MV_PAR06 )
	    	If SubStr( MV_PAR06 , nI , 1 ) <> "*"
	    		cCatFun += SubStr( MV_PAR06 , nI , 1 ) + ";"
	    	EndIf
	    Next nI*/
	    //cCatFun := SubStr( cCatFun , 1 , Len(cCatFun) - 1 )
		_cQuery += "AND trim(SRA.RA_CATFUNC)	IN "+ FormatIn( RTrim( cCatFun ) , ";" )
	Endif 
	
	If !EMPTY(MV_PAR07)
		cSitFol:=""
	    For nI := 1 To Len( ALLTRIM(MV_PAR07) )
	    	If SubStr( ALLTRIM(MV_PAR07) , nI , 1 ) <> "*"
	    		cSitFol += SubStr( ALLTRIM(MV_PAR07) , nI , 1 ) + ";"
	    	EndIf
	    Next nI
	    cSitFol := SubStr( cSitFol , 1 , Len(cSitFol) - 1 )
		If " " $ RTRIM(MV_PAR07)
			_cQuery += " AND (trim(SRA.RA_SITFOLH)  IN "+ FormatIn( RTRIM( cSitFol ) , ";" ) + " OR SRA.RA_SITFOLH = ' ') "
		Else
			_cQuery += " AND trim(SRA.RA_SITFOLH)  IN "+ FormatIn( RTRIM( cSitFol ) , ";" )
		Endif 
	Endif
	
	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )
	
	DBSelectArea(_cAlias)
	(_cAlias)->( DBEVAL( {|| _nTot++ } ) )
	(_cAlias)->( DBGoTop() )
	_nni := 1

	Do while (_cAlias)->( !Eof() )
	
	
		IF valtype(oproc) = "O"

			oproc:cCaption := ("Lendo funcionários, filial " + _aFiliais[_ni] + " : " + strzero(_nni,6) + " de " + strzero(_nTot,6))
			ProcessMessages()
 
		ENDIF
		
		_nni++
	
		SRA->(Dbgoto((_cAlias)->RECNO))
		
		
		//carrega id do funcionário
		_cQuery :=  "SELECT IDCOLAB FROM SURICATO.TBCOLAB WHERE NUMEPIS = '" + ALLTRIM(SRA->RA_PIS) + "'"
		
		If select(_cAlias2) > 0
		
			Dbselectarea(_cAlias2)
			(_cAlias2)->(Dbclosearea())
			
		Endif
		
		DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias2 , .T. , .F. )
	
		DBSelectArea(_cAlias2)
		
		If (_cAlias2)->( !Eof() )
		
			//Carrega crachas do funcionario no periodo
			_cQuery :=  "select icard,datainic,horainic,datafina,horafina from suricato.tbhistocrach where idcolab = " + alltrim(str((_cAlias2)->idcolab))   + " and datainic <= TO_DATE('" + dtos(MV_PAR03) + "', 'yyyymmdd') 
			_cQuery +=  "and (datafina >= TO_DATE('" + dtos(MV_PAR03) + "', 'yyyymmdd') or datafina = TO_DATE('19001231', 'yyyymmdd'))
		
			If select(_cAlias3) > 0
		
				Dbselectarea(_cAlias3)
				(_cAlias3)->(Dbclosearea())
			
			Endif
		
			DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias3 , .T. , .F. )
			DBSelectArea(_cAlias3)
			
			_acrachas := {}
		
			Do while (_cAlias3)->( !Eof() )
			
				aadd(_acrachas, {(_cAlias3)->icard,(_cAlias3)->datainic,(_cAlias3)->horainic,(_cAlias3)->datafina,(_cAlias3)->horafina} )
				
				(_cAlias3)->(Dbskip())
				
			Enddo
					
			If len(_acrachas) > 0
			
				//Carrega marcações do funcionario no periodo
				For _nnj := 1 to len(_acrachas)
				
					_cQuery :=	" SELECT ICARD , DATABLOQ, HORABLOQ, DATALIBE , HORALIBE ,OBSEBLOQLIBE , DESCMOTI , MOT.CODIMOTI MOT_CM , TBB.CODIMOTI MOT_TB"
					_cQuery +=	" FROM SURICATO.TBBLOQUCRACH TBB , SURICATO.TBMOTIVBLOQU MOT WHERE " 
					_cQuery +=	" DATABLOQ >= TO_DATE('" + DTOS(MV_PAR02) + "', 'yyyymmdd') " //data inicio do relatorio 
					_cQuery +=	" and DATABLOQ <= TO_DATE('" + DTOS(MV_PAR03) + "', 'yyyymmdd') " //data fim do relatorio 
					_cQuery +=	" AND ICARD = " + alltrim(str(_acrachas[_nnj][1])) 
					_cQuery +=	" AND MOT.CODIMOTI = TBB.CODIMOTI "
					_cQuery +=  " ORDER BY DATABLOQ,HORABLOQ"
		
					If select(_cAlias4) > 0
		
						Dbselectarea(_cAlias4)
						(_cAlias4)->(Dbclosearea())
			
					Endif
		
					DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias4 , .T. , .F. )
					DBSelectArea(_cAlias4)
					
					Do while (_cAlias4)->( !Eof() )
					
						_nBhoras   := int((_cAlias4)->HORABLOQ / 60)
						_nBminutos :=  (_cAlias4)->HORABLOQ - ((int((_cAlias4)->HORABLOQ / 60))*60) 
						_cBhoras   :=  STRZERO(_nBhoras,2) + ":" + STRZERO(_nBminutos,2)

						_nhoras   := int((_cAlias4)->HORALIBE / 60)
						_nminutos :=  (_cAlias4)->HORALIBE - ((int((_cAlias4)->HORALIBE / 60))*60) 
						_choras   :=  STRZERO(_nhoras,2) + ":" + STRZERO(_nminutos,2)

					
						aAdd( _aRet , {	alltrim(SRA->RA_FILIAL)	        ,; //Filial
							ALLTRIM(SRA->RA_MAT)						,; //Matrícula
							ALLTRIM(Capital(AllTrim(SRA->RA_NOME )))    ,; //Funcionário
							ALLTRIM(DtoC((_cAlias4)->DATABLOQ))		    ,; //Data do bloqueio
							ALLTRIM(_cBhoras)						    ,; //Hora de bloquio
							ALLTRIM(DtoC((_cAlias4)->DATALIBE))		    ,; //Data de liberacao
							ALLTRIM(_choras)		   					,; //hora de liberacao
							ALLTRIM((_cAlias4)->DESCMOTI)				,; //MOTIVO //ALLTRIM(STR(MOT_CM))+"="+ALLTRIM(STR(MOT_TB))+"/"+
							ALLTRIM((_cAlias4)->OBSEBLOQLIBE)			}) //OBS
						
						
						(_cAlias4)->(Dbskip())
						
					Enddo
							
				Next
		
			Endif
		
		Endif
		
		(_cAlias)->(Dbskip())
		
	Enddo

Next _nI

Return( _aRet )


/*
===============================================================================================================================
Programa----------: RPON017P
Autor-------------: Alex Wallauer
Data da Criacao---: 08/02/2022
===============================================================================================================================
Descrição---------: Validação das Perguntas da Rotina
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RPON017P( _nOpc )

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
			
			u_itmsg(  "É obrigatório informar o filtro de Filiais, clique em 'selecionar todas' para utilizar todas as Filiais." , "Atenção!" ,,1 )
			_lRet := .F.
			
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
