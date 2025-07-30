/*
===============================================================================================================================
                  ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                            
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 21/06/2018 | Ajustes na impressão do acesso das catracas - Chamado 29402
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 17/09/2019 | Retirada chamada da função itputx1. Chamado 28346 
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges  	  | 02/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 07/09/2021 | Alterado p/ o parametro ITCATRAC pegar filial(is) do filtro e não da Atual - Chamado 37671
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.Ch"

#Define TITULO	"Relatório de acompanhamento de jornadas"
#Define CRLF	Chr(13)+Chr(10)

/*
===============================================================================================================================
Programa----------: RPON011
Autor-------------: Josué Danich Prestes
Data da Criacao---: 24/03/2014
===============================================================================================================================
Descrição---------: Relatório de acompanhamento de jornadas - Chamado 25179
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RPON011()

Local _aColAux		:= { 0050		, 0000			, 0050			, 0300  			, 0600 	  , 1200		  	, 1800	            , 1980			, 2800		, 2950			}
Local _aCabec		:= { "Filial"	, "Setor"		, "Matrícula"	, "Funcionário"		, "Função",  "Setor"        , "Data do Apont."	, "Marcações"	, "Jornada"	, "Intervalo"	}
Local _aColAjs		:= { 0000		, 0000			, 0015			, -0100 			, 0000   , 0010		  	    , 0000	            , 0020			, 0020		, 0020			}
Local _aCabec2      := { "Filial"	, "Setor"		, "Matrícula"	, "Funcionário"		, "Função", "Data do Apont."	, "Marcações"	, "Jornada", "Intervalo"	}
Local _aDados		:= {}
Local _cPerg		:= "RPON011"
Local oproc         := nil
Local _nnh			:= 0

SET DATE FORMAT TO "DD/MM/YYYY"

DO WHILE .T.

   IF !Pergunte( _cPerg )
      RETURN
   ENDIF

   IF EMPTY(MV_PAR02) .OR.  EMPTY(MV_PAR03) .OR.  MV_PAR02 > MV_PAR03
      U_ITMSG("Periodo INVALIDO",'Atenção!',"Tente novamente com outro periodo com as 2 datas preenchidas",3)
      LOOP
   ENDIF

	//============================================================================
	//| Verifica o registro de ponto em busca das informações                    |
	//============================================================================
	fwmsgrun( ,{|oproc| _aDados := RPON011SEL(oproc) } , "Aguarde!" , "Selecionando dados..." )
	
    IF Empty(_aDados)
    	u_itmsg(  "Não foram encontrados registros para exibir! Verifique os parâmetros e tente novamente." , "Atenção" ,,1 )
    	LOOP
    EndIF
    
    EXIT

ENDDO

If MV_PAR11 == 1

	_adados2 := {}
	
	For _nnh := 1 to len(_aDados)
	
		aadd(_adados2, {_aDados[_nnh][1],_aDados[_nnh][7],_aDados[_nnh][3],_aDados[_nnh][4],_aDados[_nnh][5],_aDados[_nnh][9],_aDados[_nnh][10],_aDados[_nnh][11],_aDados[_nnh][12] })
	
	Next
	
	fwMsgRun( , {|| U_ITListBox( TITULO , _aCabec2 , _aDados2 , .T. ) },"Exportando dados para planilha, aguarde..." , TITULO  )
	
Elseif MV_PAR11 == 2

	_adados2 := {}
	
	For _nnh := 1 to len(_aDados)
	
		aadd(_adados2, {_aDados[_nnh][1],_aDados[_nnh][2],_aDados[_nnh][3],_aDados[_nnh][4],_aDados[_nnh][5],_aDados[_nnh][7],_aDados[_nnh][9],_aDados[_nnh][10],_aDados[_nnh][11],_aDados[_nnh][12] })
	
	Next
	
	fwMsgRun( , {|oproc| RPON011PRT( _aCabec , _aColAux , _aColAjs , _aDados2) }, "Imprimindo dados, aguarde..." , TITULO  )
	
Elseif MV_PAR11 == 3

	fwMsgRun( , {|oproc| RPON011W() }, "Enviando dados, aguarde..." , TITULO  )
	
EndIF

Return()

/*
===============================================================================================================================
Programa----------: RPON011SEL
Autor-------------: Alexandre Villar
Data da Criacao---: 24/03/2014
===============================================================================================================================
Descrição---------: Carga de dados para o relatório
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processmento
===============================================================================================================================
Retorno-----------: _aret - dados coletados do banco
===============================================================================================================================
*/
Static Function RPON011SEL(oproc)

Local _aRet			:= {}
Local _cAlias		:= GetNextAlias()
Local _cAlias2		:= GetNextAlias()
Local _cAlias3		:= GetNextAlias()
Local _cAlias4		:= GetNextAlias()
Local _aFiliais		:= {}
Local _cQuery		:= ""
Local _nTot			:= 0
Local _nI			:= 0
Local _nnj			:= 0
Local _nnd			:= 0

Default oproc := nil


_aFiliais			:= StrToKArr( AllTrim(MV_PAR01) , ";" )

IF Empty(_aFiliais)

	u_itmsg(  "Não foram informadas Filiais válidas para o processamento!" , "Atenção!" ,,1 )

EndIF

For _nI := 1 To Len( _aFiliais )

	IF valtype(oproc) = "O"

		oproc:cCaption := ("Lendo funcionários para filial " + _aFiliais[_ni] + "...")
		ProcessMessages()
 
	ENDIF
	
	_cQuery := " SELECT "
	_cQuery += " R_E_C_N_O_ RECNO  "	  
	_cQuery += " FROM "+ RetSqlName("SRA") +" SRA "
	_cQuery += " WHERE "
	_cQuery += " 	RA_FILIAL = '"+ _aFiliais[_nI] +"' "
	_cQuery += " AND D_E_L_E_T_	= ' ' "
	   
	
	If !EMPTY(MV_PAR04) .AND. !EMPTY(MV_PAR05)
	
		_cQuery += " AND RA_MAT >= '" + MV_PAR04 + "' AND RA_MAT <= '" + MV_PAR05 + "' "
		
	Endif
	
	If !EMPTY(MV_PAR06)
	
		_cQuery += "						AND trim(SRA.RA_CATFUNC)	IN "+ FormatIn( RTrim( MV_PAR06 ) , ";" )
		
	Endif 
	
	If !EMPTY(MV_PAR07)
	
		_cQuery += "						AND TRIM(SRA.RA_CARGO)	IN "+ FormatIn( RTrim( MV_PAR07 ) , ";" )
		
	Endif 
	
	If !EMPTY(MV_PAR08)
	
		_cQuery += "						AND TRIM(SRA.RA_CODFUNC)	IN "+ FormatIn( RTrim( MV_PAR08 ) , ";" )
		
	Endif 
	
	If !EMPTY(MV_PAR09)
	
		_cQuery += "						AND TRIM(SRA.RA_I_SETOR)	IN "+ FormatIn( RTrim( MV_PAR09 ) , ";" )
		
	Endif 
	
	If !EMPTY(MV_PAR10)
	
		If " " $ rtrim(MV_PAR10)
		
			_cQuery += " 						AND (trim(SRA.RA_SITFOLH)  IN "+ FormatIn( RTrim( MV_PAR10 ) , ";" ) + " OR SRA.RA_SITFOLH = ' ') "
			
		Else
		
			_cQuery += " 						AND trim(SRA.RA_SITFOLH)  IN "+ FormatIn( RTrim( MV_PAR10 ) , ";" )
		
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

			oproc:cCaption := ("Lendo funcionários para filial " + _aFiliais[_ni] + ", funcionário " + strzero(_nni,6) + " de " + strzero(_nTot,6) + "...")
			ProcessMessages()
 
		ENDIF
		
		_nni++
	
		SRA->(Dbgoto((_cAlias)->RECNO))
		
		
		//carrega id do funcionário
		_cQuery :=  "select idcolab from suricato.tbcolab where numepis = '" + ALLTRIM(SRA->RA_PIS) + "'"
		
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
				
					_cQuery :=	" select dataaces,horaaces,direaces,CODICOLE from suricato.tbmarcaacess where " 
					_cQuery +=	" dataaces >= TO_DATE('" + DTOS(MV_PAR02) + "', 'yyyymmdd') " //data inicio do relatorio 
					_cQuery +=	" and dataaces <= TO_DATE('" + DTOS(MV_PAR03) + "', 'yyyymmdd') " //data fim do relatorio 
					_cQuery +=	" and ( ( dataaces = TO_DATE('" + DTOS(_acrachas[_nnj][2]) + "', 'yyyymmdd') and horaaces >= 1) "
					_cQuery +=	"                        or dataaces > TO_DATE('" + DTOS(_acrachas[_nnj][2]) + "', 'yyyymmdd')) " //data inicio do cracha
					
					//inclui filtro de data final do cracha só se a data final for diferente 31/12/1900
					If DTOS(_acrachas[_nnj][4]) != "19001231"
					
						_cQuery +=	" and ( ( dataaces = TO_DATE('" + DTOS(_acrachas[_nnj][4]) + "', 'yyyymmdd') and horaaces <= 1) "
						_cQuery +=	"                         or dataaces < TO_DATE('" + DTOS(_acrachas[_nnj][4]) + "', 'yyyymmdd')) " //data final do cracha
						
					Endif
					
					_cQuery +=	" and icard = " + alltrim(str(_acrachas[_nnj][1])) 
					_cQuery +=  " and tipoaces = 1 " //Acesso com sucesso na catraca
                    cFilSalva:=cFilAnt
                    cFilAnt  :=SRA->RA_FILIAL
					_cQuery +=  " and codicole in  " + FormatIn(u_itgetmv("ITCATRAC","1;2"),";") 
                    cFilAnt  :=cFilSalva
					_cQuery +=  " order by dataaces,horaaces"
		
					If select(_cAlias4) > 0
		
						Dbselectarea(_cAlias4)
						(_cAlias4)->(Dbclosearea())
			
					Endif
		
					DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias4 , .T. , .F. )
					DBSelectArea(_cAlias4)
					
					ajorns := {}
					_dultima := (_cAlias4)->dataaces
					
					Do while (_cAlias4)->( !Eof() )
					
						_nhoras := int((_cAlias4)->horaaces / 60)
						_nminutos :=  (_cAlias4)->horaaces - ((int((_cAlias4)->horaaces / 60))*60) 
						_choras := (_cAlias4)->direaces +"("+ALLTRIM(STR((_cAlias4)->CODICOLE))+") "+ strzero(_nhoras,2) + ":" + strzero(_nminutos,2)
					
						If (_cAlias4)->dataaces == _dultima
					
							If (_cAlias4)->direaces == "E"
							
								If len(ajorns) = 0 .OR. (len(ajorns) > 0 .and. ajorns[len(ajorns)][2] >= 0) //Validação contra dupla marcação de entrada
						
									aadd(ajorns,{(_cAlias4)->horaaces,-1})
									
								Endif
								
							Elseif (_cAlias4)->direaces == "S" .and. len(ajorns) > 0 .and. ajorns[len(ajorns)][2] = -1
							
								ajorns[len(ajorns)][2] := (_cAlias4)->horaaces
								
							Endif
							
						Else
						
							//Se virou o dia sem sair da fabrica marca final da jornada do dia as 23:59
							If (_cAlias4)->direaces == "S" .and. len(ajorns) > 0 .and. ajorns[len(ajorns)][2] = -1
							
								ajorns[len(ajorns)][2] := 1439
								
							Endif
							
							//Soma total da jornada e intervalo do dia
							_ntotdia := 0
							_nintdia := 0
							
							For _nnd := 1 to len(ajorns)
							
								If ajorns[_nnd][1] >= 0 .and. ajorns[_nnd][2] >= 0
								
									_ntotdia := _ntotdia + ajorns[_nnd][2] - ajorns[_nnd][1]
									
									If _nnd > 1
									
										_nintdia := _nintdia + ajorns[_nnd][1] - ajorns[_nnd-1][2]
									
									Endif
									
								Endif
							
							Next
							
							//Registra jornada do dia e reinicia contador 
							_nnk := ascan(_aRet,{|_vAux| _vAux[1]==alltrim(SRA->RA_FILIAL) .and.  _vAux[3]==alltrim(SRA->RA_MAT) .AND. _vAux[9]==alltrim(DtoC(_dultima)) }) 
							
							_aRet[_nnk][11] :=   strzero(int(_ntotdia/60),2) + ":" + strzero(_ntotdia-(int(_ntotdia/60)*60),2)
							_aRet[_nnk][12] :=   strzero(int(_nintdia/60),2) + ":" + strzero(_nintdia-(int(_nintdia/60)*60),2)
							
							ajorns := {}
							
							//Se virou o dia sem sair da fabrica registra entrada à 12:00 
							If (_cAlias4)->direaces == "S" 
							
								aadd(ajorns,{0,(_cAlias4)->horaaces})
								
							Else
							
								aadd(ajorns,{(_cAlias4)->horaaces,-1})
							
							Endif
							
							//vira ultimo dia
							_dultima := (_cAlias4)->dataaces
						
						Endif
					
						_nnp := ascan(_aRet,{|_vAux| _vAux[1]==alltrim(SRA->RA_FILIAL) .and.  _vAux[3]==alltrim(SRA->RA_MAT) .AND. _vAux[9]==alltrim(DtoC((_cAlias4)->dataaces)) }) 
					
						If len(alltrim(_choras)) > 45
						
							_choras := substr(alltrim(_choras),1,45) + "..."
							
						Endif
					
						If _nnp == 0
					
							aAdd( _aRet , {	alltrim(SRA->RA_FILIAL)	,; //Filial
							alltrim(SRA->RA_I_SETOR)						,; //Setor
							alltrim(SRA->RA_MAT)						,; //Matrícula
							alltrim(Capital(AllTrim(SRA->RA_NOME )))    ,; //Funcionário
							alltrim(POSICIONE("SRJ",1,xfilial("SRJ")+SRA->RA_CODFUNC,"RJ_DESC")) + space(5)	,; //Desc. Funçao 
							alltrim(POSICIONE("ZAK",1,xfilial("ZAK")+SRA->RA_I_SETOR,"ZAK_COD")) 	,; //Codigo Setor 
							alltrim(ZAK->ZAK_DESCRI) + space(5)					,; //Desc. Setor
							alltrim(DTOC(SRA->RA_ADMISSA))				,; //Dt Admissao 
							alltrim(DtoC((_cAlias4)->dataaces))				      ,; //Data do Apontamento
							alltrim(_choras)						,; //Marcações da Data
							alltrim(" ")						,; //Jornada
							alltrim(" ")				}) 				   //Intervalo
						
						Else
						
							_aRet[_nnp][10] := _aRet[_nnp][10] + " - " + _choras
						
						Endif
						
						(_cAlias4)->(Dbskip())
						
					Enddo
		
					//Faz ultima jornada
							
					//Soma total da jornada do dia
					_ntotdia := 0
					_nintdia := 0
							
					For _nnd := 1 to len(ajorns)
							
						If ajorns[_nnd][1] >= 0 .and. ajorns[_nnd][2] >= 0
								
							_ntotdia := _ntotdia + ajorns[_nnd][2] - ajorns[_nnd][1]
							
							If _nnd > 1
									
								_nintdia := _nintdia + ajorns[_nnd][1] - ajorns[_nnd-1][2]
									
							Endif
									
						Endif
							
					Next
							
					//Registra jornada do dia e reinicia contador 
					_nnk := ascan(_aRet,{|_vAux| _vAux[1]==alltrim(SRA->RA_FILIAL) .and.  _vAux[3]==alltrim(SRA->RA_MAT) .AND. _vAux[9]==alltrim(DtoC(_dultima)) }) 
							
					If _ntotdia > 0 .and. _nnk > 0
					
						_aRet[_nnk][11] :=   strzero(int(_ntotdia/60),2) + ":" + strzero(_ntotdia-(int(_ntotdia/60)*60),2)
						_aRet[_nnk][12] :=   strzero(int(_nintdia/60),2) + ":" + strzero(_nintdia-(int(_nintdia/60)*60),2)
						
					Elseif _nnk > 0
					
						_aRet[_nnk][11] := " "
						_aRet[_nnk][12] := " "
					
					Endif					
		
				Next
		
			Endif
		
		Endif
		
		(_cAlias)->(Dbskip())
		
	Enddo

Next _nI

Return( _aRet )

/*
===============================================================================================================================
Programa----------: RPON011PRT
Autor-------------: Alexandre Villar
Data da Criacao---: 28/04/2014
===============================================================================================================================
Descrição---------: Chamada de Impressao de Relatório dos dados de marcação de Ponto manual
===============================================================================================================================
Parametros--------: _aCabec	- Cabeçalho do Relatório
------------------: _aColAux	- Posicionamento das Colunas
------------------: _aColAjs	- Ajuste de posicionamento dos conteúdos
------------------: _aDados	- Dados do Relatório
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function RPON011PRT( _aCabec , _aColAux , _aColAjs , _aDados )

Local _aResTot	:= {}
Local _nLinha		:= 300
Local _nTotCol	:= Len(_aCabec)
Local _nI			:= 0
Local _nX			:= 0
Local _nCont		:= 0
Local _nConFil	:= 0
Local _nTotFun	:= 0
Local _nConTot	:= 0
Local _nJornada	:= 0
Local _nInterv	:= 0
Local _nJorSet	:= 0
Local _nIntSet	:= 0
Local _cChvAux	:= ""
Local _cSetAux	:= ""
Local _cTxtCab	:= ""
Local _oPrint		:= Nil
Local _oFont01	:= TFont():New( "Arial" , 9 , 14 ,.F.,.T.,,.T.,,.T.,.F.)
Local _oFont02	:= TFont():New( "Arial" , 9 , 08 ,.F.,.T.,,.T.,,.T.,.F.)
Local _oFont03	:= TFont():New( "Arial" , 9 , 08 ,.F.,.F.,,.T.,,.T.,.F.)
Local _oFont04	:= TFont():New( "Arial" , 9 , 10 ,.F.,.T.,,.T.,,.T.,.F.)

//=============================================================================
//| Inicializa o objeto do relatório                                          |
//=============================================================================
_oPrint := TMSPrinter():New( TITULO )
_oPrint:Setup()
_oPrint:SetLandscape()
_oPrint:SetPaperSize(9)

//=============================================================================
//| Processa a impressão dos dados                                            |
//=============================================================================
For _nI := 1 To Len(_aDados)
	
	//=============================================================================
	//| Inicializa as variáveis de controle                                       |
	//=============================================================================
	_cChvAux		:= _aDados[_nI][01] + _aDados[_nI][02] + _aDados[_nI][03]
	_nJornada	:= 0
	_nInterv		:= 0
	
	//=============================================================================
	//| Valida o controle do Setor atual                                          |
	//=============================================================================
	IF Empty(_cSetAux)
		
		//=============================================================================
		//| Inicializa a primeira página do relatório                                 |
		//=============================================================================
		_cSetAux := _aDados[_nI][01] + _aDados[_nI][02]
		
		_cTxtCab	:= "Filial: "+	_aDados[_nI][01] +" - "+ AllTrim( Posicione("ZZM",1,xFilial("ZZM")+_aDados[_nI][01],"ZZM_DESCRI") ) +" | "
		_cTxtCab	+= "Setor: "+	_aDados[_nI][02] +" - "+ AllTrim( Posicione("ZAK",1,xFilial("ZAK")+_aDados[_nI][02],"ZAK_DESCRI") )
		
		_nLinha	:= 50000
		_nTotFun	:= 1
		
		//=============================================================================
		//| Verifica o posicionamento da página                                       |
		//=============================================================================
		RPON011VPG( @_oPrint , @_nLinha , _aCabec , _cTxtCab , _aColAux , _oFont01 , _oFont02 , _oFont03 , _oFont04 , .F. )
		
		//=============================================================================
		//| Encerra Lote do Setor atual                                               |
		//=============================================================================
	ElseIF (_cSetAux <> _aDados[_nI][01] + _aDados[_nI][02])
		
		IF _nLinha > 2900
			
			_nLinha := 50000
			//=============================================================================
			//| Verifica o posicionamento da página                                       |
			//=============================================================================
			RPON011VPG( @_oPrint , @_nLinha , _aCabec , _cTxtCab , _aColAux , _oFont01 , _oFont02 , _oFont03 , _oFont04 )
			
		EndIF
		
		//=============================================================================
		//| Formata a informação para a impressão                                     |
		//=============================================================================
		_nJorSet		:= Round( ( _nJorSet / _nTotFun )	, 0 )
		_nIntSet		:= Round( ( _nIntSet / _nTotFun )	, 0 )
		
		__cMedInt		:= StrZero( Int( _nJorSet / 60 ) , 2 ) +":"+ StrZero( Mod( _nJorSet , 60 ) , 2 )
		cMedInt		:= StrZero( Int( _nIntSet / 60 ) , 2 ) +":"+ StrZero( Mod( _nIntSet , 60 ) , 2 )
		
		//=============================================================================
		//| Formata a informação para a impressão                                     |
		//=============================================================================
		aAdd( _aResTot , {	SubStr(_cSetAux,1,2) +" - "+ AllTrim( Posicione("ZZM",1,xFilial("ZZM")+_aDados[_nI][01],"ZZM_DESCRI") )	,;
		AllTrim( Posicione( "ZAK" , 1 , xFilial("ZAK") + SubStr(_cSetAux,3,6) , "ZAK_DESCRI" ) )					,;
		StrZero( _nTotFun , 6 )																					,;
		StrZero( _nConFil , 6 )																					,;
		__cMedInt																									,;
		cMedInt																									})
		
		_oPrint:Say( _nLinha , 0050 , "Setor: "+ AllTrim(Posicione("ZAK",1,xFilial("ZAK")+SubStr(_cSetAux,3,6),"ZAK_DESCRI"))	, _oFont02 )
		_nLinha += 040
		_oPrint:Say( _nLinha , 0050 , "Total de Funcionários: "+ StrZero( _nTotFun , 6 )								 		, _oFont02 )
		_oPrint:Say( _nLinha , 1000 , "Total de Marcações: "+ StrZero( _nConFil , 6 )									 		, _oFont02 )
		_nLinha += 040
		_oPrint:Say( _nLinha , 0050 , "Média de Jornadas: "+ __cMedInt															, _oFont02 )
		_oPrint:Say( _nLinha , 1000 , "Média de Intervalos: "+ cMedInt														, _oFont02 )
		_nLinha += 040
		_oPrint:Line( _nLinha + 020 , 0 , _nLinha + 020 , 5000 )
		_oPrint:Line( _nLinha + 021 , 0 , _nLinha + 021 , 5000 )
		_oPrint:Line( _nLinha + 022 , 0 , _nLinha + 022 , 5000 )
		_oPrint:Line( _nLinha + 023 , 0 , _nLinha + 023 , 5000 )
		_oPrint:Line( _nLinha + 024 , 0 , _nLinha + 024 , 5000 )
		
		//=============================================================================
		//| Reinicia as variáveis de controle                                         |
		//=============================================================================
		_nConFil	:= 0
		_nJorSet	:= 0
		_nIntSet	:= 0
		_nLinha	:= 50000
		_nTotFun	:= 1
		
		_cSetAux	:= _aDados[_nI][01] + _aDados[_nI][02]
		
		_cTxtCab	:= "Filial: "+	_aDados[_nI][01] +" - "+ AllTrim( Posicione("ZZM",1,xFilial("ZZM")+_aDados[_nI][01],"ZZM_DESCRI") ) +" | "
		_cTxtCab	+= "Setor: "+	_aDados[_nI][02] +" - "+ AllTrim( Posicione("ZAK",1,xFilial("ZAK")+_aDados[_nI][02],"ZAK_DESCRI") )
		
	Else
		
		_nLinha += 020
		_nTotFun++
		
	EndIF
	
	//=============================================================================
	//| Processa os dados do Funcionário Atual                                    |
	//=============================================================================
	While _nI <= Len(_aDados) .And. _cChvAux == _aDados[_nI][01] + _aDados[_nI][02] + _aDados[_nI][03]
		
		//=============================================================================
		//| Registra o processamento                                                  |
		//=============================================================================
		_nCont++
		_nConFil++
		
		//=============================================================================
		//| Verifica o posicionamento da página                                       |
		//=============================================================================
		RPON011VPG( @_oPrint , @_nLinha , _aCabec , _cTxtCab , _aColAux , _oFont01 , _oFont02 , _oFont03 , _oFont04 )
		
		//=============================================================================
		//| Guarda valores para o cálculo das médias                                  |
		//=============================================================================
		_nJornada	+= ( Val( SubStr( _aDados[_nI][09] , 1 , 2 ) ) * 60 ) + Val( SubStr( _aDados[_nI][09] , 4 , 2 ) )
		_nInterv		+= ( Val( SubStr( _aDados[_nI][10] , 1 , 2 ) ) * 60 ) + Val( SubStr( _aDados[_nI][10] , 4 , 2 ) )
		
		//=============================================================================
		//| Imprime os registros do Funcionário atual                                 |
		//=============================================================================
		For _nX := 3 To _nTotCol
			_oPrint:Say( _nLinha , _aColAux[_nX] + _aColAjs[_nX] , _aDados[_nI][_nX] , _oFont03 )
		Next _nX
		_nLinha += 030
		
		_nI++
	EndDo
	
	//=============================================================================
	//| Verifica o posicionamento da página                                       |
	//=============================================================================
	RPON011VPG( @_oPrint , @_nLinha , _aCabec , _cTxtCab , _aColAux , _oFont01 , _oFont02 , _oFont03 , _oFont04 )
	
	//=============================================================================
	//| Calcula a média dos apontamentos                                          |
	//=============================================================================
	_nJornada	:= Round( ( _nJornada / _nCont )	, 0 )
	_nInterv		:= Round( ( _nInterv / _nCont )	, 0 )
	
	//=============================================================================
	//| Grava a média dos apontamentos para totalizador do Setor                  |
	//=============================================================================
	_nJorSet		+= _nJornada
	_nIntSet		+= _nInterv
	
	//=============================================================================
	//| Formata a informação para a impressão                                     |
	//=============================================================================
	__cMedInt		:= StrZero( Int( _nJornada / 60 )	, 2 ) +":"+ StrZero( Mod( _nJornada	, 60 ) , 2 )
	cMedInt		:= StrZero( Int( _nInterv / 60 )		, 2 ) +":"+ StrZero( Mod( _nInterv	, 60 ) , 2 )
	
	//=============================================================================
	//| Imprime o totalizador do Funcionário                                      |
	//=============================================================================
	_oPrint:Line( _nLinha + 020 , 0 , _nLinha + 020 , 5000 )
	_oPrint:Line( _nLinha + 021 , 0 , _nLinha + 021 , 5000 )
	_oPrint:Line( _nLinha + 022 , 0 , _nLinha + 022 , 5000 )
	_nLinha += 030
	_oPrint:Say( _nLinha , _aColAux[01] , "Total de registros do Funcionário: "+ AllTrim( Transform( _nCont , "@E 999,999,999,999" ) )	, _oFont02 )
	_oPrint:Say( _nLinha , _aColAux[08] , "Média de Apontamento: "																		, _oFont02 )
	_oPrint:Say( _nLinha , _aColAux[09] + 015 , __cMedInt																				, _oFont02 )
	_oPrint:Say( _nLinha , _aColAux[10] + 020 , cMedInt																				, _oFont02 )
	_nLinha += 030
	_oPrint:Line( _nLinha + 020 , 0 , _nLinha + 020 , 5000 )
	_oPrint:Line( _nLinha + 021 , 0 , _nLinha + 021 , 5000 )
	_oPrint:Line( _nLinha + 022 , 0 , _nLinha + 022 , 5000 )
	_nLinha += 030
	
	//=============================================================================
	//| Ajusta as variáveis de controle                                           |
	//=============================================================================
	_nI--
	_nCont := 0
	
Next _nI

//|===========================================================
//| Considera o único ou último setor na totalização - Início|
//|===========================================================
IF _nLinha > 2900
			
	_nLinha := 50000
	//=============================================================================
	//| Verifica o posicionamento da página                                       |
	//=============================================================================
	RPON011VPG( @_oPrint , @_nLinha , _aCabec , _cTxtCab , _aColAux , _oFont01 , _oFont02 , _oFont03 , _oFont04 )
			
EndIF
		
//=============================================================================
//| Formata a informação para a impressão                                     |
//=============================================================================
_nJorSet		:= Round( ( _nJorSet / _nTotFun )	, 0 )
_nIntSet		:= Round( ( _nIntSet / _nTotFun )	, 0 )
		
__cMedInt		:= StrZero( Int( _nJorSet / 60 ) , 2 ) +":"+ StrZero( Mod( _nJorSet , 60 ) , 2 )
cMedInt		:= StrZero( Int( _nIntSet / 60 ) , 2 ) +":"+ StrZero( Mod( _nIntSet , 60 ) , 2 )
		
//=============================================================================
//| Formata a informação para a impressão                                     |
//=============================================================================
aAdd( _aResTot , {	SubStr(_cSetAux,1,2) +" - "+ AllTrim( Posicione("ZZM",1,xFilial("ZZM")+SubStr(_cChvAux,1,2),"ZZM_DESCRI") )	,;
					AllTrim( Posicione( "ZAK" , 1 , xFilial("ZAK") + SubStr(_cSetAux,3,6) , "ZAK_DESCRI" ) )					,;
					StrZero( _nTotFun , 6 )																					,;
					StrZero( _nConFil , 6 )																					,;
					__cMedInt																									,;
					cMedInt																									})
		
_oPrint:Say( _nLinha , 0050 , "Setor: "+ AllTrim(Posicione("ZAK",1,xFilial("ZAK")+SubStr(_cSetAux,3,6),"ZAK_DESCRI"))	, _oFont02 )
_nLinha += 040
_oPrint:Say( _nLinha , 0050 , "Total de Funcionários: "+ StrZero( _nTotFun , 6 )								 		, _oFont02 )
_oPrint:Say( _nLinha , 1000 , "Total de Marcações: "+ StrZero( _nConFil , 6 )									 		, _oFont02 )
_nLinha += 040
_oPrint:Say( _nLinha , 0050 , "Média de Jornadas: "+ __cMedInt															, _oFont02 )
_oPrint:Say( _nLinha , 1000 , "Média de Intervalos: "+ cMedInt														, _oFont02 )
_nLinha += 040
_oPrint:Line( _nLinha + 020 , 0 , _nLinha + 020 , 5000 )
_oPrint:Line( _nLinha + 021 , 0 , _nLinha + 021 , 5000 )
_oPrint:Line( _nLinha + 022 , 0 , _nLinha + 022 , 5000 )
_oPrint:Line( _nLinha + 023 , 0 , _nLinha + 023 , 5000 )
_oPrint:Line( _nLinha + 024 , 0 , _nLinha + 024 , 5000 )

//|========================================================
//| Considera o único ou último setor na totalização - Fim|
//|========================================================
		
//=============================================================================
//| Reinicia as variáveis de controle                                         |
//=============================================================================
_nConFil	:= 0
_nJorSet	:= 0
_nIntSet	:= 0
_nLinha	:= 50000
_nTotFun	:= 1
		
_cTxtCab	:= "Filial: "+	SubStr(_cChvAux,1,2) +" - "+ AllTrim( Posicione("ZZM",1,xFilial("ZZM")+SubStr(_cChvAux,1,2),"ZZM_DESCRI") ) +" | "
_cTxtCab	+= "Setor: "+	SubStr(_cSetAux,3,6) +" - "+ AllTrim( Posicione("ZAK",1,xFilial("ZAK")+SubStr(_cSetAux,3,6),"ZAK_DESCRI") )

_nLinha	:= 50000
_cTxtCab	:= "Resumo Geral do Relatório por Filial/Setor"
_aColAux := { ,, 0050 , 0600 , 1350 , 1650 , 1900 , 2150 }
_aColAjs := { ,, 0000 , 0000 , 0090 , 0080 , 0065 , 0080 }
_aCabec	:= { ,, "Filial" , "Setor" , "Total Funcionários" , "Total Marcações" , "Média Jornada" , "Média Intervalos" }
_cSetAux	:= ""
_nTotFun	:= 0
_nConTot := 0
_nCont	:= 0
_nConFil	:= 0

//=============================================================================
//| Verifica o posicionamento da página                                       |
//=============================================================================
RPON011VPG( @_oPrint , @_nLinha , _aCabec , _cTxtCab , _aColAux , _oFont01 , _oFont02 , _oFont03 , _oFont04 )

If !Empty(_aResTot)
	
	For _nI := 1 To Len( _aResTot )
		
		IF !Empty(_cSetAux) .And. _cSetAux <> SubStr( _aResTot[_nI][01] , 1 , 2 )
			
			//=============================================================================
			//| Verifica o posicionamento da página                                       |
			//=============================================================================
			RPON011VPG( @_oPrint , @_nLinha , _aCabec , _cTxtCab , _aColAux , _oFont01 , _oFont02 , _oFont03 , _oFont04 )
			
			//=============================================================================
			//| Grava o fechamento da Filial no relatório                                 |
			//=============================================================================
			_nLinha += 020
			_oPrint:Say( _nLinha , _aColAux[03] , "Total Geral da Filial ================= [ Funcionários: "+ StrZero( _nCont , 6 ) +" ] / [ Marcações: "+ StrZero( _nConFil , 6 ) +" ]" , _oFont02 )
			_nLinha += 040
			_oPrint:Line( _nLinha , 0 , _nLinha , 5000 )
			_nLinha += 050
			
			_nCont	:= 0
			_nConFil	:= 0
			
		EndIF
		
		_cSetAux := SubStr( _aResTot[_nI][01] , 1 , 2 )
		
		If _nLinha > 3100
			
			_nLinha := 50000
			
			//=============================================================================
			//| Verifica o posicionamento da página                                       |
			//=============================================================================
			RPON011VPG( @_oPrint , @_nLinha , _aCabec , _cTxtCab , _aColAux , _oFont01 , _oFont02 , _oFont03 , _oFont04 )
			
		EndIF
		
		//=============================================================================
		//| Imprime o resumo do relatório                                             |
		//=============================================================================
		For _nX := 1 To Len( _aResTot[_nI] )
			_oPrint:Say( _nLinha , _aColAux[_nX+2] + _aColAjs[_nX+2] , _aResTot[_nI][_nX] , _oFont02 )
		Next _nX
		
		//=============================================================================
		//| Registra o total geral do relatório                                       |
		//=============================================================================
		_nTotFun += Val( _aResTot[_nI][03] )
		_nCont	+= Val( _aResTot[_nI][03] )
		_nConTot	+= Val( _aResTot[_nI][04] )
		_nConFil	+= Val( _aResTot[_nI][04] )
		
		_nLinha += 035
		_oPrint:Line( _nLinha , 0 , _nLinha , 5000 )
		_nLinha += 020
		
	Next _nI
	
	//=============================================================================
	//| Verifica o posicionamento da página                                       |
	//=============================================================================
	RPON011VPG( @_oPrint , @_nLinha , _aCabec , _cTxtCab , _aColAux , _oFont01 , _oFont02 , _oFont03 , _oFont04 )
	
	//=============================================================================
	//| Grava o fechamento da última Filial do relatório                          |
	//=============================================================================
	_nLinha += 020
	_oPrint:Say( _nLinha , _aColAux[03] , "Total Geral da Filial ================= [ Funcionários: "+ StrZero( _nCont , 6 ) +" ] / [ Marcações: "+ StrZero( _nConFil , 6 ) +" ]" , _oFont02 )
	_nLinha += 040
	_oPrint:Line( _nLinha , 0 , _nLinha , 5000 )
	_nLinha += 050
	
	//=============================================================================
	//| Verifica o posicionamento da página                                       |
	//=============================================================================
	RPON011VPG( @_oPrint , @_nLinha , _aCabec , _cTxtCab , _aColAux , _oFont01 , _oFont02 , _oFont03 , _oFont04 )
	
	//=============================================================================
	//| Grava o fechamento do relatório                                           |
	//=============================================================================
	_nLinha += 050
	_oPrint:Line( _nLinha , 0 , _nLinha , 5000 )
	_nLinha += 020
	_oPrint:Say( _nLinha , _aColAux[03] , "==== Total Geral ==== [ Funcionários: "+ StrZero( _nTotFun , 6 ) +" ] / [ Marcações: "+ StrZero( _nConTot , 6 ) +" ] ====" , _oFont02 )
	_nLinha += 040
	_oPrint:Line( _nLinha , 0 , _nLinha , 5000 )
	
	
Else
	
	//=============================================================================
	//| Imprime o total geral do relatório                                        |
	//=============================================================================
	_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
	_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha += 7
	_oPrint:Say( _nLinha , _aColAux[01] , "Não foram encontrados registros para gerar o resumo do relatório." , _oFont01 ) ; _nLinha += 060
	_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha++
	_oPrint:Line( _nLinha , 0 , _nLinha , 5000 ) ; _nLinha += 7
	
EndIF

//=============================================================================
//| Starta o objeto de impressão                                              |
//=============================================================================
_oPrint:Preview()

Return()

/*
===============================================================================================================================
Programa----------: RPON011P
Autor-------------: Alexandre Villar
Data da Criacao---: 29/04/2014
===============================================================================================================================
Descrição---------: Validação das Perguntas da Rotina
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RPON011P( _nOpc )

Local _lRet		:= .T. //Se retornar .F. nao deixa sair do campo
Local _cNomeVar	:= ReadVar()
Local _xVarAux	:= &(_cNomeVar)
Local _aArea	:= GetArea()
Local _cEmpAux	:= cEmpAnt
Local _aAcesso	:= FWEmpLoad(.F.)
Local _aDadAux	:= {}
Local _nI		:= 0
Local _nX		:= 0

Do Case
	
	Case _nOpc == 1 //Filiais Consideradas ?
		
		//-- Verifica se o campo esta vazio --//
		If EMPTY(_xVarAux)
			
			u_itmsg(  "É obrigatório informar o filtro de Filiais, clique em 'selecionar todas' para utilizar todas as Filiais." , "Atenção!" ,,1 )
			_lRet := .F.
			
			//-- Verifica se o campo foi preenchido com conteudo valido --//
		Else
			
			_aDadAux := U_ITLinDel( AllTrim(_xVarAux) )
			
			For _nI := 1 To Len(_aDadAux)
				
				_lRet := .F.
				
				For _nX := 1 To Len(_aAcesso)
					
					If _aDadAux[_nI] == _aAcesso[_nX][03]
						_lRet := .T.
					EndIf
					
				Next _nX
				
				If !_lRet
					u_itmsg(  "O usuário não tem acesso às 'Filiais' informadas! Verifique os dados digitados." ,"Atenção!" ,,1 )
					Exit
				EndIf
				
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
			
			u_itmsg(  "É obrigatório informar o filtro de Categorias Funcionais, clique em 'selecionar todas' para utilizar todas as Categorias." , "Atenção!" ,,1 )
			_lRet := .F.
			
		Else
			
			_aDadAux := U_ITLinDel( AllTrim(_xVarAux) )
			
			For _nI := 1 To Len(_aDadAux)
				
				DBSelectArea("SX5")
				SX5->( DBSetOrder(1) )
				SX5->( DBGoTop() )
				If !SX5->( DBSeek( xFilial("SX5") + "28" + _aDadAux[_nI] ) )
					
					u_itmsg(  "As 'Categorias Funcionais' informadas não são válidas! Verifique os dados digitados." ,"Atenção!" ,,1 )
					_lRet := .F.
					Exit
					
				EndIf
				
			Next _nI
			
		EndIF
		
	Case _nOpc == 3 //Situações ?
		
		If EMPTY(_xVarAux)
			
			&(_cNomeVar) := " ;"
			
		Else
			
			_aDadAux := U_ITLinDel( _xVarAux )
			
			For _nI := 1 To Len(_aDadAux)
				
				DBSelectArea("SX5")
				SX5->( DBSetOrder(1) )
				SX5->( DBGoTop() )
				If !SX5->( DBSeek( xFilial("SX5") + "31" + _aDadAux[_nI] ) )
					
					u_itmsg( "As 'Situações na Folha' informadas não são válidas! Verifique os dados digitados." ,"Atenção!" , ,1)
					_lRet := .F.
					Exit
					
				EndIf
				
			Next _nI
			
		EndIf
		
		//=============================================================================
		//| Verifica se o campo "Time()" foi preenchido corretamente                  |
		//=============================================================================
	Case _nOpc == 4
		
		If	!( SubStr(	_xVarAux , 1 , 1 ) $ '0123456789' )	.Or.;
			!( SubStr(	_xVarAux , 2 , 1 ) $ '0123456789' )	.Or.;
			SubStr(		_xVarAux , 3 , 1 ) <> ':'			.Or.;
			!( SubStr(	_xVarAux , 4 , 1 ) $ '0123456789' )	.Or.;
			!( SubStr(	_xVarAux , 5 , 1 ) $ '0123456789' )
			
			u_itmsg(  "A hora digitada não é válida, informar o campo no formato correto: '00:00' ('HH:MM')" , "Atenção!" ,,1 )
			_lRet := .F.
			
		EndIf
		
		IF _lRet .And. Val( SubStr(_xVarAux,4,2) ) > 59
			u_itmsg(  "A hora digitada não é válida, informar valores válidos entre: '00:00' e '99:59'. (Formato:'HH:MM')" , "Atenção!" ,,1 )
			_lRet := .F.
		EndIF
		
EndCase

RestArea(_aArea)

Return(_lRet)

/*
===============================================================================================================================
Programa----------: RPON011VPG
Autor-------------: Alexandre Villar
Data da Criacao---: 29/04/2014
===============================================================================================================================
Descrição---------: Validação do pocicionamento da página atual para quebras
===============================================================================================================================
Parametros--------: _oPrint	- Objeto de Impressão do Relatório
------------------: _nLinha	- Variável de controle do posicionamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RPON011VPG( _oPrint , _nLinha , _aCabec , _cTxtCab , _aColAux , _oFont01 , _oFont02 , _oFont03 , _oFont04 , _lFinPag )

Local _nTotCol	:= Len( _aCabec )
Local _nLimPag	:= 2600
Local _nX		:= 0

Default _lFinPag := .T.

If _nLinha > _nLimPag
	
	//=============================================================================
	//| Encerra página atual e abre uma nova                                      |
	//=============================================================================
	IF _lFinPag
	
		_oPrint:EndPage()
	
	EndIF
	
	_oPrint:StartPage()
	
	//=============================================================================
	//| Reinicia o posicionamento da linha                                        |
	//=============================================================================
	_nLinha	:= 280
	
	//=============================================================================
	//| Insere logo no cabecalho                                                  |
	//=============================================================================
	If File( "LGRL01.BMP" )
	
		_oPrint:SayBitmap( 050 , _aColAux[01] , "LGRL01.BMP" , 300 , 130 )
	
	EndIf
	
	//=============================================================================
	//| Desenha quadro do Título                                                  |
	//=============================================================================
	_oPrint:Line( 050 , 0400 , 050 , 2450 )
	_oPrint:Line( 240 , 0400 , 240 , 2450 )
	_oPrint:Line( 050 , 0400 , 240 , 0400 )
	_oPrint:Line( 050 , 2450 , 240 , 2450 )
	
	//=============================================================================
	//| Insere Informações no cabecalho                                           |
	//=============================================================================
	_oPrint:Say( 060 , 420 , TITULO +" ( "+ DtoC(Date()) +" - "+ Time() +")" , _oFont01 )
	_oPrint:Say( 120 , 420 , "Período: "+ DTOC( MV_PAR02 ) +" - "+ DTOC( MV_PAR03 ) +" | Filiais: "+ AllTrim( MV_PAR01 )											, _oFont02 )
	_oPrint:Say( 150 , 420 ,	"Categorias: "+ AllTrim( MV_PAR06 ) +" | Sit. Folha: "+ AllTrim( MV_PAR07 ) +" | Intervalo: "+ MV_PAR08, _oFont02 )
	
	_oPrint:Say( 190 , 420 , _cTxtCab , _oFont04 )
	
	//=============================================================================
	//| Adiciona cabecalho do conteúdo                                            |
	//=============================================================================
	_nLinha := 255
	
	For _nX := 3 To _nTotCol
		_oPrint:Say( _nLinha , _aColAux[_nX] , _aCabec[_nX] , _oFont02 )
	Next _nX
	
	//=============================================================================
	//| Adiciona linha separadora e posiciona abaixo                              |
	//=============================================================================
	_oPrint:Line( 290 , 0 , 290 , 5000 )
	_nLinha := 300
	
EndIF

Return

/*
===============================================================================================================================
Programa----------: RPON011W
Autor-------------: Josue Danich Prestes
Data da Criacao---: 12/06/2018
===============================================================================================================================
Descrição---------: Envio de relatorio por email
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RPON011W()

	u_itmsg("Rotina de envio de email ainda não foi desenvolvida","Atenção",,1)
	
Return
