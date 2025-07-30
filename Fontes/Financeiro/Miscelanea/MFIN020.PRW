/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include	"Protheus.Ch"
#Include	"FWMVCDef.Ch"
#Include	"topconn.Ch"

/*
===============================================================================================================================
Programa----------: MFIN020
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 12/05/2022
===============================================================================================================================
Descrição---------: Rotina de Leitura e Inclusao de titulos - Chamado 38967
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MFIN020()

	Local oproc := nil

//Grava Log de execução da rotina
	U_ITLOGACS( "MFIN020" )

	PRIVATE MV_PAR01:=Space(200)
	PRIVATE _cSalva_MV_PAR01 := MV_PAR01

	DO WHILE .T.
		lSair:=.T.

		FWMSGRUN( ,{|oproc| lSair:=MFIN020INI(oproc) } , "Processando..." , "Iniciando o processamento..." )

		IF lSair
			EXIT
		ENDIF
	ENDDO

	SET DATE FORMAT TO "DD/MM/YY"

Return()

/*
===============================================================================================================================
Programa----------: MFIN020INI
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 12/05/2022
===============================================================================================================================
Descrição---------: Rotina de montagem da tela de processamento
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: .T. OU .F.
===============================================================================================================================
*/
Static Function MFIN020INI(oproc)

	Local _aParAux	:= {}
	Local _aParRet	:= {}
	Local _aCpos	:= MFIN020CPS()
	Local _aFields	:= {}
	Local _nreg		:= 0
	Local _adados	:= {}
	Local _apesqui	:= {}
	Local _ni		:= 0
	Local _nlayout	:= 0
	Local _carq		:= ""
	Local _otemp    := nil  , nI

	Private oMarkBRW	:= Nil
	Private cAliasAux	:= GetNextAlias()
	Private _nTotReg	:= 0

	MV_PAR01 := _cSalva_MV_PAR01

	aAdd( _aParAux , { 6 ,"Selecione arquivo .CSV:"   , MV_PAR01 ,"","","",100,.T.,"Todos os arquivos (*.CSV) |*.CSV","C:\",GETF_LOCALHARD+GETF_MULTISELECT})
	aAdd( _aParAux , { 9 , "Deixe o campo acima em branco e clique em OK caso queira gerar um arquivo CSV de modelo.",200,14,.T. } ) 	//| 01 |

	For nI := 1 To Len( _aParAux )
		aAdd( _aParRet , _aParAux[nI][03] )
	Next nI

	DO WHILE .T.

		IF !ParamBox( _aParAux , "Rotina de inclusao de titulos automatica" , @_aParRet )
			Return .T.
		EndIf

		_cSalva_MV_PAR01 := MV_PAR01

		IF EMPTY(MV_PAR01)
			_aHeader:={"VALOR DO TITULO","VENCIMENTO DO TITULO","CODIGO FORNECEDOR","LOJA FORNECEDOR"}
			_aCols:={{"","","",""}}
			U_ITGERARQ( "" , _aHeader , _aCols )
			LOOP
		ENDIF


		oproc:cCaption := ("Abrindo arquivo...")
		ProcessMessages()

		IF (upper(right(alltrim(MV_PAR01),4))) == ".CSV"

			_carq := ALLTRIM(MV_PAR01)

			If FT_FUSE(_carq) == -1

				u_itmsg("1-Falha ao abrir o arquivo: "+_carq,"Erro",,1)

				LOOP//Return .F.

			Endif

			FT_FGOTOP() //POSICIONA NO TOPO DO ARQUIVO
			_cDados := FT_FREADLN()

			If UPPER(alltrim(_cDados)) == UPPER("VALOR DO TITULO;VENCIMENTO DO TITULO;CODIGO FORNECEDOR;LOJA FORNECEDOR")///********************
				_nlayout := 1 //Layout Padrão
			Endif

			//Fecha arquivo e prepara parâmetro com arquivo convertido
			FT_FUSE()

		ELSE

			U_ITMSG("O arquivo informado: "+Alltrim(MV_PAR01)+" não tem extenção [ .CSV ] ",;
				"Arquivo inválido",;
				"Favor informar uma arquivo no formato [ .CSV ].")
			LOOP//Return .F.

		EndIf

//Escolhido Layout continua leitura
		If _nlayout > 0

			If FT_FUSE(_carq) == -1

				u_itmsg("2-Falha ao abrir o arquivo: "+_carq,"Erro",,1)
				LOOP//Return .F.

			EndIf

			FT_FGOTOP() //POSICIONA NO TOPO DO ARQUIVO

			_nReg:= FT_FLASTREC()

			ProcRegua(_nReg)

			FT_FGOTOP() //POSICIONA NO TOPO DO ARQUIVO

			If _nReg == 0 //O arquivo informado nao possui nenhuma linha de dados

				U_ITMSG("O arquivo informado para relizar a importação não possui dados.",;
					"Arquivo inválido",;
					"Favor verificar se o arquivo informado esta no formato correto.")
				LOOP//Return .F.

			EndIf

			If _nlayout == 1

				_adados := MFIN020L(_nreg,oproc) //Faz leitura dos dados

			Endif

			If len(_adados) <= 0

				u_itmsg( "Não foram encontrados registros válidos no arquivo!" , "Atenção!",,1 )
				LOOP//Return .F.

			EndIf

		Else

			U_ITMSG("O arquivo "+_carq+" informado para relizar a importação não tem o layout padrão.",;
				"Arquivo com formato inválido",;
				"O CSV deve ter as colunas [ VALOR DO TITULO;VENCIMENTO DO TITULO;CODIGO FORNECEDOR;LOJA FORNECEDOR ] e o mesmo deve ser salvo "+;
				"no Excel no formato [ CSV (separado por virgulas) ] e "+;
				"no LibreOffice Calc com Demilitador de campo Ponto e Virgula e sem delimitador de texto.",1)
			LOOP//Return .F.

		Endif

		EXIT

	ENDDO
//================================================================================
// Verifica se ja existe um arquivo com mesmo nome, se sim deleta.
//================================================================================
	If Select(cAliasAux) > 0
		oproc:cCaption := ("Apagando temporário...")
		ProcessMessages()
		_otemp:Delete()
	EndIf

	oproc:cCaption := ("Criando arquivo temporário...")
	ProcessMessages()
	_otemp := FWTemporaryTable():New( cAliasAux, _aCpos )

	oproc:cCaption := ("Criando indices do arquivo temporário...")
	ProcessMessages()

	_otemp:AddIndex( "01", {"FILIAL","TITU"} )

	_otemp:Create()

	_aMarcados:={} 

	SE2->( DBSetOrder(1) )//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

	FOR  _ni := 1 TO len(_adados)

		oproc:cCaption := ("Lendo: "+ StrZero( _ni , 6 ) +" de "+ StrZero( len(_adados) , 6 ) +" Registros..." )
		ProcessMessages()

		If Empty(_aDados[_nI][06])
			cCodFor := Posicione("SA2",3,xFilial("SA2")+_aDados[_nI][05],"A2_COD")
			cCodLoj	:= Posicione("SA2",3,xFilial("SA2")+_aDados[_nI][05],"A2_LOJA")
		EndIf
		(cAliasAux)->( DBAPPEND(  ) )

		(cAliasAux)->FILIAL  := xFilial("SE2")
		(cAliasAux)->PREFIXO := _aDados[_ni][01]
		(cAliasAux)->TITU    := _aDados[_ni][02]
		(cAliasAux)->TIPO    := _aDados[_ni][03]
		(cAliasAux)->NATUREZA:= _aDados[_ni][04]
		(cAliasAux)->FORNECE := IIf (!Empty(cCodFor),cCodFor,_aDados[_ni][05])
		(cAliasAux)->LOJA	 := IIf (!Empty(cCodLoj),cCodLoj,_aDados[_ni][06])
		If !Empty(_aDados[_nI][06])
			(cAliasAux)->NOME	 := Posicione("SA2",1,xFilial("SA2")+_aDados[_ni][05]+_aDados[_ni][06],"A2_NOME")
		Else
			(cAliasAux)->NOME	 := Posicione("SA2",1,xFilial("SA2")+cCodFor+cCodLoj,"A2_NOME")
		EndIf
		(cAliasAux)->EMISSAO := _aDados[_ni][07]
		(cAliasAux)->VENCIME := _aDados[_ni][08]
		(cAliasAux)->WKVALOR := _aDados[_ni][09]

		If SE2->( DBSeek( xFilial("SE2") + (cAliasAux)->PREFIXO  + (cAliasAux)->TITU  + SPACE(LEN(SE2->E2_PARCELA)) + (cAliasAux)->TIPO + (cAliasAux)->FORNECE + (cAliasAux)->LOJA	) )
			_adados[_ni][11]:=_adados[_ni][11]+"[O titulo já existe: "+xFilial("SE2") +"+"+ (cAliasAux)->PREFIXO  +"+"+ (cAliasAux)->TITU +"+"+ SPACE(LEN(SE2->E2_PARCELA)) +"+"+(cAliasAux)->TIPO +"+"+ (cAliasAux)->FORNECE +"+"+ (cAliasAux)->LOJA+"] "
			_aDados[_ni][10]:='R'
		ENDIF

		(cAliasAux)->WKSTATUS:= _aDados[_ni][10]
		(cAliasAux)->ERRO    := _adados[_ni][11]
		(cAliasAux)->ERRO    := ALLTRIM((cAliasAux)->ERRO)//Para tirar os espacos da frente

		IF ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU }) = 0
			AADD(_aMarcados,{(cAliasAux)->FILIAL+(cAliasAux)->TITU,.F., "" })
		ENDIF

	NEXT
	cEmpAnt:=cEmpAnt
	aAdd( _aFields , { "Filial"	 		   	, {|| (cAliasAux)->FILIAL + " - "+AllTrim(FWFilialName(cEmpAnt,(cAliasAux)->FILIAL,1)) }  	, "C" , "@!" , 0 , 12, 0 } )
	aAdd( _aFields , { "Prefixo"			, {|| (cAliasAux)->PREFIXO }									, "C" , "@!" 				, 0 , 10, 0 } )
	aAdd( _aFields , { "Titulo"				, {|| (cAliasAux)->TITU  }										, "C" , "@!" 				, 0 , 10, 0 } )
	aAdd( _aFields , { "Tipo"    			, {|| (cAliasAux)->TIPO  }										, "C" , "@!" 				, 0 , 10, 0 } )
	aAdd( _aFields , { "Natureza"			, {|| (cAliasAux)->NATUREZA  }									, "C" , "@!" 				, 0 , 10, 0 } )
	aAdd( _aFields , { "Fornecedor"			, {|| (cAliasAux)->FORNECE + " - " + (cAliasAux)->LOJA }  		, "C" , "@!" , 0 , 08		, 0 } )
	aAdd( _aFields , { "Nome"				, {|| (cAliasAux)->NOME }										, "C" , "@!" , 0 , 30		, 0 } )
	aAdd( _aFields , { "Valor"              , {|| (cAliasAux)->WKVALOR }									, "N" , "@E 999,999,999.99" , 0 ,015, 2 } )
	aAdd( _aFields , { "Dt. Emissao"        , {|| (cAliasAux)->EMISSAO }								    , "D" , "@D"                , 0 , 8 , 0 } )
	aAdd( _aFields , { "Dt. Vencto"         , {|| (cAliasAux)->VENCIME }								    , "D" , "@D"                , 0 , 8 , 0 } )
	aAdd( _aFields , { "Observação"			, {|| (cAliasAux)->ERRO  }									    , "C" , ""  				, 0 ,100, 0 } )


	_apesqui := {}
	aadd(_apesqui,{"Titulo",{{"Filial","C",2,0,"Filial",,}, {"Titulo","C",9,0,"Titulo",,}},1})

	oMarkBRW:=FWMarkBrowse():New()		   											  		// Inicializa o Browse
	oMarkBRW:SetAlias( cAliasAux )			   												// Define Alias que será a Base do Browse
	oMarkBRW:SetDescription( "Rotina de inclusao de titulos automatica" )					// Define o titulo do browse de marcacao
	oMarkBRW:SetFieldMark( "MARCA" )														// Define o campo que sera utilizado para a marcação
	oMarkBRW:SetMenuDef( 'MFIN020' )														// Força a utilização do menu da rotina atual
	oMarkBRW:SetAllMark( {|| .F./*oMarkBRW:AllMark()*/ } )									// Ação do Clique no Header da Coluna de Marcação
	oMarkBRW:SetCustomMarkRec({||IF((cAliasAux)->WKSTATUS="A",U_MFIN020R("MARCAR"),.F.)})  // Indica o Code-Block executado para validar a marcação/desmarcação do registro
	oMarkBRW:AddLegend( "(cAliasAux)->WKSTATUS = 'A'","GREEN" , "Aceitos")                  // Permite adicionar legendas no Browse
	oMarkBRW:AddLegend( "(cAliasAux)->WKSTATUS = 'R'","RED"   , "Rejeitados")               // Permite adicionar legendas no Browse
	oMarkBRW:AddLegend( "(cAliasAux)->WKSTATUS = 'P'","BLUE"  , "Processados")              // Permite adicionar legendas no Browse
	oMarkBRW:SetFields( _aFields )													 		// Campos para exibição
	oMarkBRW:SetSeek(.T., _apesqui)                                                         // Indica os campos que serão adicionados as colunas do Browse
	oMarkBRW:AddButton( "Confirmar"         , {|| fwmsgrun( ,{|oproc| U_MFIN020B(oproc)},"Aguarde","Processando..."           ) } ,, 4 )// Adiciona um botão
	oMarkBRW:AddButton( "Totais"            , {|| fwmsgrun( ,{|| MFIN020Totais()}, "Aguarde","Totalizando titulos marcados...") } ,, 4 )// Adiciona um botão
	oMarkBRW:AddButton( "Marca Todos"       , {|| fwmsgrun( ,{|| MFIN13Todos(.T.)  }, "Aguarde","Marcando..."   ) } ,, 4 )// Adiciona um botão
	oMarkBRW:AddButton( "Desmarca Todos"    , {|| fwmsgrun( ,{|| MFIN13Todos(.F.)  }, "Aguarde","Desmarcando...") } ,, 4 )// Adiciona um botão
	oMarkBRW:DisableConfig()                                                                // Desabilita a utilização das configurações do Browse
	oMarkBRW:Activate()																		// Ativacao da classe

	(cAliasAux)->( DBCloseArea() )

Return .F.

/*
===============================================================================================================================
Programa----------: MFIN020Totais
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 12/05/2022
===============================================================================================================================
Descrição---------: Mostra totais
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MFIN020Totais()

	Local _aTot:={0,0,0,0} , _cTexto:=""
	(cAliasAux)->( DBGoTop() )

	DO While (cAliasAux)->( !EOF() )

		If (cAliasAux)->WKSTATUS $ "A" .AND. !EMPTY((cAliasAux)->MARCA)
			_aTot[1]+=(cAliasAux)->WKVALOR
			_aTot[2]+=1
		ENDIF

		(cAliasAux)->( DbSkip() )

	EndDo

	_cTexto:="TOTAIS DOS TITULOS MARCADOS: "+cValToChar(_aTot[2])+CHR(13)+CHR(10)
	_cTexto+="** VALOR TOTAL: R$ "+ALLTRIM(TRANSF(_aTot[1],"@E 999,999,999,999.99"))+" **"+CHR(13)+CHR(10)
	U_ITMSG(_cTexto,"TOTAIS",,2)

	(cAliasAux)->( DBGoTop() )
	oMarkBRW:GoTo( (cAliasAux)->( RECNO() ) , .T. )
//oMarkBRW:GoTop()
	oMarkBRW:Refresh()

RETURN
/*
===============================================================================================================================
Programa----------: MFIN020CNS
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 12/05/2022
===============================================================================================================================
Descrição---------: Rotina de consulta do cadastro completo do Cliente
===============================================================================================================================
Parametros--------: _cChama: da onde chama
===============================================================================================================================
Retorno-----------: .T. OU .F.
===============================================================================================================================
*/
User Function MFIN020R(_cChama)

	LOCAL lRet:=.T.

	If _cChama == "MARCAR"

		IF !oMarkBRW:IsMark() //Testa pq do duplo clique ele chama essa função 2 veses OR botão Alterar

			(oMarkBRW:Alias())->MARCA := oMarkBRW:Mark()

			IF (_nPos:=ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU })) # 0
				_aMarcados[_nPos,2]:=.T.
				//_aMarcados[_nPos,3]:=ALLTRIM((cAliasAux)->WKPARCELA)+" - "+DTOC((cAliasAux)->VENCREA)
			ENDIF

		Else

			(oMarkBRW:Alias())->MARCA := ""
			IF (_nPos:=ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU })) # 0
				_aMarcados[_nPos,2]:=.F.//A colocação do .T. esta dentro da função MFIN13Tela("SE1",nReg,4)
				_aMarcados[_nPos,3]:="" //O preenchimento esta dentro da função MFIN13Tela("SE1",nReg,4)
			ENDIF

		ENDIF


	ENDIF
	DBSelectArea(cAliasAux)//Tem volta para o alias do browse pq senão dá erro

Return lRet

/*
===============================================================================================================================
Programa----------: MFIN020CPS
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 12/05/2022
===============================================================================================================================
Descrição---------: Define a criação de campos para exibição da análise
===============================================================================================================================
Retorno-----------: aRet - Campos que serão criados e exibidos na tela
===============================================================================================================================
*/
Static Function MFIN020CPS()

	Local _aCpos := {}

	aAdd( _aCpos , { "WKSTATUS"	    , "C" , 01, 0 } )
	aAdd( _aCpos , { "MARCA"		, "C" , 01, 0 } )
	AAdd( _aCpos , { "FILIAL"		, "C" , TamSX3("E2_FILIAL")[01]	, 0 } )
	AAdd( _aCpos , { "PREFIXO"		, "C" , TamSX3("E2_PREFIXO")[01], 0 } )
	AAdd( _aCpos , { "TITU"			, "C" , TamSX3("E2_NUM")[01]	, 0 } )
	AAdd( _aCpos , { "TIPO"		    , "C" , TamSX3("E2_TIPO")[01]	, 0 } )
	AAdd( _aCpos , { "NATUREZA"		, "C" , TamSX3("E2_NATUREZ")[01], 0 } )
	AAdd( _aCpos , { "FORNECE"		, "C" , TamSX3("E2_FORNECE")[01], 0 } )
	AAdd( _aCpos , { "LOJA"			, "C" , TamSX3("A1_LOJA")[01]	, 0 } )
	AAdd( _aCpos , { "NOME"			, "C" , TamSX3("A2_NOME")[01]	, 0 } )
	AAdd( _aCpos , { "EMISSAO"		, "D" , 08, 0 } )
	AAdd( _aCpos , { "VENCIME"		, "D" , 08, 0 } )
	AAdd( _aCpos , { "WKVALOR"		, "N" , 18, 2 } )
	AAdd( _aCpos , { "ERRO"	  	    , "M" , 10, 0 } )

Return( _aCpos )

/*
===============================================================================================================================
Programa----------: MFIN020B
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 12/05/2022
===============================================================================================================================
Descrição---------: Processa os titulos marcados
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: NIL
===============================================================================================================================
*/
User Function MFIN020B(oproc)

	Local _nRegAtu	:= 0
	Local _nTotReg	:= (cAliasAux)->( LASTREC() )
	Local _nRegSel	:= 0
	Local _nRegErro	:= 0
	Local _nRecSalva:= 0


	(cAliasAux)->( DBGoTop() )

	DO While (cAliasAux)->( !EOF() )

		_nRegAtu++
		oproc:cCaption := ("Processando... ["+ StrZero(_nRegAtu,6) +"] de ["+ StrZero(_nTotReg,6) +"] Incluidos: "+StrZero(_nRegSel,5) )
		ProcessMessages()
		IF (cAliasAux)->WKSTATUS = "A"
			oMarkBRW:GoTo( (cAliasAux)->( RECNO() ) , .T. )
		ELSE
			(cAliasAux)->(DBSKIP())
			LOOP
		ENDIF

		If (cAliasAux)->WKSTATUS = 'A' .AND. oMarkBRW:IsMark()//!EMPTY((cAliasAux)->MARCA)

			(cAliasAux)->(DBSKIP())
			_nRecSalva:=(cAliasAux)->(RECNO())
			(cAliasAux)->(DBSKIP(-1))
			_cErro:=""
			IF MFIN13Gera()//GERA SE2
				(cAliasAux)->WKSTATUS:='P'
				_nRegSel++
				oMarkBRW:MarkRec()
				oMarkBRW:Refresh()
			ELSE
				_nRegErro++
				(cAliasAux)->WKSTATUS:='R'
				(cAliasAux)->ERRO  :=_cErro
			ENDIF
			(oMarkBRW:Alias())->MARCA := ""//Desmarca Sempre
			IF (_nPos:=ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU })) # 0
				_aMarcados[_nPos,2]:=.F.
			ENDIF

			(cAliasAux)->(DBGOTO(_nRecSalva))
		ELSE
			(cAliasAux)->( DbSkip() )
		ENDIF

	EndDo

	(cAliasAux)->( DBGoTop() )

	_cMen:=ALLTRIM(STR(_nRegAtu))+" registro(s) processado(s)."+CHR(13)+CHR(10)
	_cMen+=ALLTRIM(STR(_nRegSel))+" registro(s) Incluido(s) com sucesso."+CHR(13)+CHR(10)
	_cMen+=ALLTRIM(STR(_nRegErro))+" registro(s) com erro."

	U_ITMSG(_cMen,"Concluído!",,2)

	(cAliasAux)->( DBGoTop() )
	oMarkBRW:GoTo( (cAliasAux)->( RECNO() ) , .T. )
//oMarkBRW:GoTop()
	oMarkBRW:Refresh()
	ProcessMessages()

Return()

/*
===============================================================================================================================
Programa----------: MFIN020L
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 12/05/2022
===============================================================================================================================
Descrição---------: Faz a leitura de dados no layout 
===============================================================================================================================
Parametros--------: _nreg - número de linhas do arquivo
				    oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: _adados - array com dados carregados do arquivo
===============================================================================================================================
*/

Static function MFIN020L(_nreg,oproc)

	Local _nCont 	:= 0
	Local _cdados	:= ""
	Local _alinha	:= {}
	Local _adados 	:= {}
	Local _nValorTotal:=0
	Local _nColVlB:= 1
	Local _nColVen:= 2
	Local _nColFor:= 3
	Local _nColLoj:= 4
	Local _cNatura:= U_ItGetMV("IT_NATTIT",'232019')


	FT_FGOTOP() //POSICIONA NO TOPO DO ARQUIVO
	FT_FSKIP()

	cNumero := fGerNum()

	DO While !FT_FEOF()  //FACA ENQUANTO NAO FOR FIM DE ARQUIVO

		_nCont++
		oproc:cCaption := ( "Lendo linha " + strzero(_nCont,5) + " de " + strzero(_nreg,5) + "." )
		ProcessMessages()

		_cDados := FT_FREADLN()
		_aLinha := StrTokArr(_cDados,";")

		//Verifica se é final de arquivo
		If alltrim(_cdados) = ';;' .and. _nCont > 5
			Exit
		Endif

		//Verifica se é linha válida
		If len(_aLinha) < 3
			FT_FSKIP()
			Loop
		Endif

		_alinha[_nColVlB]:=STRTRAN(_alinha[_nColVlB],".","")//Tira o seprador de milhar brasileiro
		_nValorTotal:=VAL(STRTRAN(_alinha[_nColVlB],",","."))//Troca os sepradores de decimal brasileiro para o ingles
		_dVencto:=CTOD(_alinha[_nColVen])
		_cErro:=""
		_cTipoErro:="A"//WKSTATUS

		If Len(_aLinha[_nColFor]) > 6
			cCodFor := Posicione("SA2",3,xFilial("SA2")+_aLinha[_nColFor],"A2_COD")
			cCodLoj	:= Posicione("SA2",3,xFilial("SA2")+_aLinha[_nColFor],"A2_LOJA")

			SA2->(dbSetOrder(1))
	
			IF !SA2->(DBSEEK(xFilial("SA2")+cCodFor+cCodLoj))
				_cErro:="[Fornnecedor+Loja "+ALLTRIM(cCodFor+cCodLoj)+" nao cadastrado.] "
				_cTipoErro:='R'
			ELSEif SA2->A2_MSBLQL = '1'
				_cErro:="[Fornnecedor+Loja "+ALLTRIM(cCodFor+cCodLoj)+" bloqueado.] "
				_cTipoErro:='R'
			ENDIF
			If _nValorTotal <= 0
				_cErro+="[Valor invalido.] "
				_cTipoErro:='R'
			ENDIF
			If EMPTY(_dVencto)
				_cErro+="[Data de Vencimento invalida.] "
				_cTipoErro:='R'
			ELSEIF _dVencto < dDatabase
				_cErro+="[Data de Vencimento menor que hoje.] "
				_cTipoErro:='R'
			ENDIF


		aadd(_adados,{"TAC"              ,; //01 - PREFIXO
		cNumero            ,;	//02 - num titulo
		'RC'	 		     ,;	//03 - TIPO
		_cNatura           ,;	//04 - Natureza
		_alinha[_nColFor]  ,;	//05 - cliente
		" "			 ,; //06 - loja do cliente
		dDatabase          ,; //07 - Data de emissao
		_dVencto           ,; //08 - VENCIMENTO
		_nValorTotal       ,;	//09 - Valor Titulo
		_cTipoErro         ,;	//10 - Bolas
		_cErro             })	//11 - Erro WKSTATUS

		cNumero :=Soma1( cNumero)

		_cErro:=""





		Else
			IF LEN(_aLinha) < 4 .OR. EMPTY(VAL(_alinha[_nColLoj]))
				_cLoja:=STRZERO(1,LEN(SE2->E2_LOJA))
			ELSE
				_cLoja:=STRZERO(VAL(_alinha[_nColLoj]),LEN(SE2->E2_LOJA))
			ENDIF
			IF !SA2->(DBSEEK(xFilial("SA2")+_alinha[_nColFor]+_cLoja))
				_cErro:="[Fornnecedor+Loja "+ALLTRIM(_alinha[_nColFor]+_cLoja)+" nao cadastrado.] "
				_cTipoErro:='R'
			ELSEif SA2->A2_MSBLQL = '1'
				_cErro:="[Fornnecedor+Loja "+ALLTRIM(_alinha[_nColFor]+_cLoja)+" bloqueado.] "
				_cTipoErro:='R'
			ENDIF
			If _nValorTotal <= 0
				_cErro+="[Valor invalido.] "
				_cTipoErro:='R'
			ENDIF
			If EMPTY(_dVencto)
				_cErro+="[Data de Vencimento invalida.] "
				_cTipoErro:='R'
			ELSEIF _dVencto < dDatabase
				_cErro+="[Data de Vencimento menor que hoje.] "
				_cTipoErro:='R'
			ENDIF



		aadd(_adados,{"TAC"              ,; //01 - PREFIXO
		cNumero            ,;	//02 - num titulo
		'RC'	 		     ,;	//03 - TIPO
		_cNatura           ,;	//04 - Natureza
		_alinha[_nColFor]  ,;	//05 - cliente
		_cLoja			 ,; //06 - loja do cliente
		dDatabase          ,; //07 - Data de emissao
		_dVencto           ,; //08 - VENCIMENTO
		_nValorTotal       ,;	//09 - Valor Titulo
		_cTipoErro         ,;	//10 - Bolas
		_cErro             })	//11 - Erro WKSTATUS

		cNumero :=Soma1( cNumero)

		_cErro:=""
		EndIf

		FT_FSKIP()

	Enddo

Return _adados



/*
===============================================================================================================================
Programa----------: MFIN13Gera()
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 12/05/2022
===============================================================================================================================
Descrição---------: Gera o titulo
===============================================================================================================================
Retorno-----------: .T. OU .F.
===============================================================================================================================
*/
Static function MFIN13Gera()

	Local _aAutSE2	:= {}
	Local _lOk		:= .T.
	Local _nModAux	:= nModulo
	Local _cModAux	:= cModulo

	Private lMsErroAuto := .F.

	IF EMPTY((cAliasAux)->FORNECE   ) .OR.;
			EMPTY((cAliasAux)->LOJA      ) .OR.;
			EMPTY((cAliasAux)->NATUREZA  ) .OR.;
			EMPTY((cAliasAux)->WKVALOR   ) .OR.;
			EMPTY((cAliasAux)->VENCIME   ) .OR.;
			EMPTY((cAliasAux)->EMISSAO   )
		_cErro:="Erro: [Fornecedor ou loja ou natreza ou valor ou datas não preenchidos]"
		RETURN .F.
	ENDIF


	AAdd( _aAutSE2 , { "E2_PREFIXO"	, (cAliasAux)->PREFIXO , NIL } )
	AAdd( _aAutSE2 , { "E2_NUM"		, (cAliasAux)->TITU    , NIL } )
	AAdd( _aAutSE2 , { "E2_TIPO"	, (cAliasAux)->TIPO    , NIL } )
	AAdd( _aAutSE2 , { "E2_NATUREZ"	, (cAliasAux)->NATUREZA, NIL } )
	AAdd( _aAutSE2 , { "E2_FORNECE"	, (cAliasAux)->FORNECE , NIL } )
	AAdd( _aAutSE2 , { "E2_LOJA"	, (cAliasAux)->LOJA	   , NIL } )
	AAdd( _aAutSE2 , { "E2_EMISSAO"	, (cAliasAux)->EMISSAO , NIL } )
	AAdd( _aAutSE2 , { "E2_VENCTO"	, (cAliasAux)->VENCIME , NIL } )
//AAdd(_aAutSE2, { "E2_VENCREA"	, DataValida((_cAlias)->E2_VENCREA), nil } )
	AAdd( _aAutSE2 , { "E2_VALOR"	, (cAliasAux)->WKVALOR , NIL } )
	AAdd( _aAutSE2 , { "E2_ORIGEM"	, "FINA050 "		   , NIL } )

	nModulo := 6
	cModulo := "FIN"

	MSExecAuto( {|x,y,z| Fina050(x,y,z) } , _aAutSE2 , 3 , 3 )

	If lMsErroAuto
		_cErro:="Erro: ["+ALLTRIM(MostraErro())+"]"
		_lOk := .F.
	Else
		SE2->( DBSetOrder(1) )//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		If !SE2->( DBSeek( xFilial("SE2") + (cAliasAux)->PREFIXO  + (cAliasAux)->TITU  + SPACE(LEN(SE2->E2_PARCELA)) + (cAliasAux)->TIPO + (cAliasAux)->FORNECE + (cAliasAux)->LOJA	) )
			_cErro:="Erro: [O titulo nao foi encontrdo apos a inclusao "+xFilial("SE2") +"+"+ (cAliasAux)->PREFIXO  +"+"+ (cAliasAux)->TITU +"+"+ SPACE(LEN(SE2->E2_PARCELA)) +"+"+(cAliasAux)->TIPO +"+"+ (cAliasAux)->FORNECE +"+"+ (cAliasAux)->LOJA+"]"
			_lOk := .F.
		EndIf
	EndIf

	nModulo := _nModAux
	cModulo := _cModAux

RETURN _lOk

/*
===============================================================================================================================
Programa----------: MFIN13Todos
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 12/05/2022
===============================================================================================================================
Descrição---------: Mostra totais
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MFIN13Todos(_lMarca)

	(cAliasAux)->( DBGoTop() )

	DO While (cAliasAux)->( !EOF() )

		IF (cAliasAux)->WKSTATUS $ 'A'
			oMarkBRW:GoTo( (cAliasAux)->( RECNO() ) , .T. )
		ELSE
			(cAliasAux)->(DBSKIP())
			LOOP
		ENDIF

		IF _lMarca //MARCA TODOS

			If (cAliasAux)->WKSTATUS $ 'A'

				(oMarkBRW:Alias())->MARCA := oMarkBRW:Mark()

				IF (_nPos:=ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU })) # 0
					_aMarcados[_nPos,2]:=.T.
					//aMarcados[_nPos,3]:=ALLTRIM((cAliasAux)->WKPARCELA)+" - "+DTOC((cAliasAux)->VENCREA)
				ENDIF

			ENDIF

		ELSEIF oMarkBRW:IsMark() //DESMARCA TODOS

			(oMarkBRW:Alias())->MARCA := ""
			IF (_nPos:=ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU })) # 0
				_aMarcados[_nPos,2]:=.F.//A colocação do .T. esta dentro da função MFIN13Tela("SE1",nReg,4)
				_aMarcados[_nPos,3]:="" //O preenchimento esta dentro da função MFIN13Tela("SE1",nReg,4)
			ENDIF

		ENDIF

		(cAliasAux)->( DbSkip() )

	EndDo

	(cAliasAux)->( DBGoTop() )
	oMarkBRW:GoTo( (cAliasAux)->( RECNO() ) , .T. )
//oMarkBRW:GoTop()
	oMarkBRW:Refresh()

RETURN

/*
===============================================================================================================================
Programa----------: fGerNum()
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 12/05/2022
===============================================================================================================================
Descrição---------: Busca o proximo numero do titulo
===============================================================================================================================
Retorno-----------: No. do titulo 
===============================================================================================================================
*/
Static Function fGerNum()

	Local cNumTit	:= ""
	Local cAlsNum	:= GetNextAlias()
	Local cQuery	:= ""

	cQuery := " SELECT MAX(E2_NUM) NUMERO "
	cQuery += " FROM " + RetSqlName("SE2") + " SE2 "
	cQuery += " WHERE E2_PREFIXO = 'TAC' "
	cQuery += "	AND SE2.D_E_L_E_T_ = ' ' "

	If Select(cAlsNum) > 0; (cAlsNum)->(dbCloseArea()); Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsNum,.T.,.T.)

		If !Empty( (cAlsNum)->NUMERO )
			cNumTit := Soma1( (cAlsNum)->NUMERO )
		Else
			cNumTit := STRZERO(1,LEN(SE2->E2_NUM))
		EndIf

		(cAlsNum)->(dbCloseArea())

		Return(cNumTit)
