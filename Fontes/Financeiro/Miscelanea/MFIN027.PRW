/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 22/04/2025 | Chamado 50505. Alterada a picture do CNPJ para contemplar campo alfanumérico
===============================================================================================================================
*/

#Include	"Protheus.Ch"
#Include	"FWMVCDef.Ch"
#Include	"topconn.Ch"

/*
===============================================================================================================================
Programa----------: MFIN027
Autor-------------: Igor Melgaço
Data da Criacao---: 08/01/2025
Descrição---------: Rotina de Leitura e Desconto de titulos a receber - Chamado 49509
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MFIN027()

Local oProc := Nil As Object

//Restringe o uso do programa, é o mesmo teste que o Fina070.prx faz quando é chamado
If !(AmIIn(5,6,12,11,14,41,97,33,49,59,72))//Fat,Fin,Loja,Veiculos,Ofina, Pecas, Especiais e PLS, 49-GE, 59-GAC
	Return .F.
Endif

//Grava Log de execução da rotina
U_ITLOGACS( "MFIN027" )

PRIVATE MV_PAR01:=Space(200)
PRIVATE _cSalva_MV_PAR01 := MV_PAR01

DO WHILE .T.
   lSair:=.T.

   FWMSGRUN( ,{|oproc| lSair:=MFIN027INI(oproc) } , "Processando..." , "Iniciando o processamento..." )

   IF lSair
      EXIT
   ENDIF
ENDDO

SET DATE FORMAT TO "DD/MM/YY"
	
Return()

/*
===============================================================================================================================
Programa----------: MFIN027INI
Autor-------------: Igor Melgaço
Data da Criacao---: 08/01/2025
Descrição---------: Rotina de montagem da tela de processamento
Parametros--------: oproc - objeto da barra de processamento
Retorno-----------: .T. OU .F.
===============================================================================================================================
*/
Static Function MFIN027INI(oProc As Object) As Logical

Local _aParAux	:= {} As Array
Local _aParRet	:= {} As Array
Local _aCpos	:= MFIN027CPS() As Array
Local _aFields	:= {} As Array
Local _nreg		:= 0 As Numeric
Local _adados	:= {} As Array
Local _apesqui	:= {} As Array
Local _ni		:= 0 As Numeric
Local _nlayout	:= 0 As Numeric
Local _carq		:= ""  As Character
Local _llibof	:= .F. As Logical
Local _otemp    := nil  As Object
Local nI        := 0 As Character
Local _oFile    := Nil As Object

Private oMarkBRW	:= Nil As Object
Private cAliasAux	:= GetNextAlias() As Character
Private _nTotReg	:= 0 As Numeric

MV_PAR01 := _cSalva_MV_PAR01
 
aAdd( _aParAux , { 1 , "Selecione arquivo:"		, MV_PAR01, "@!"		, ""	, "DIR"		, "" , 100 , .F. } ) 	//| 01 |

For nI := 1 To Len( _aParAux )
	aAdd( _aParRet , _aParAux[nI][03] )
Next nI

If !ParamBox( _aParAux , "Leitura e baixa de titulos pagos por grande redes" , @_aParRet )
	Return .T.
EndIf

_cSalva_MV_PAR01 := MV_PAR01

oProc:cCaption := ("Abrindo arquivo...")
ProcessMessages()

If (Upper(Right(Alltrim(MV_PAR01),4))) == ".CSV" 

	_cArq  := Alltrim(MV_PAR01)
    _oFile := FwFileReader():New(_cArq)

    If !_oFile:Open()
		U_ItMsg("1-Falha ao abrir o arquivo: "+_cArq,"Erro",,1)
		Return .F.
	EndIf 
	
    //Do While (oFile:hasLine())
        _cDados := _oFile:GetLine(.F.)
    //EndDo
    

  	//FT_FGOTOP() //POSICIONA NO TOPO DO ARQUIVO
  	//_cDados := FT_FREADLN()

  	If Upper(Alltrim(_cDados)) == Upper("Titulo;Cliente;Valor do desconto;Parcela")///********************
	   _nLayout := 1 //Layout Padrão
  	EndIf

	//Fecha arquivo e prepara parâmetro com arquivo convertido
	//FT_FUSE()
    //_oFile:Close()

Else

	U_ItMsg("O arquivo informado: " + Alltrim(MV_PAR01) + " não tem extenção [ .CSV ] ",;
            "Arquivo inválido",;
		    "Favor informar uma arquivo no formato [ .CSV ].")
	Return .F.

EndIf

//Escolhido Layout continua leitura
If _nlayout > 0

    _aRegs := _oFile:getAllLines()
    _nReg:= Len(_aRegs)
	
    ProcRegua(_nReg)
	
	If _nReg == 0 //O arquivo informado nao possui nenhuma linha de dados
		
		U_ITMSG("O arquivo informado para relizar a importação não possui dados.",;
                "Arquivo inválido",;
				"Favor verificar se o arquivo informado esta no formato correto.")
		Return .F.
	
	EndIf

	If _nlayout == 1
	
		_adados := MFIN027L(_nreg,_llibof,oProc,_aRegs) //Faz leitura dos dados
	
	Endif

	If len(_adados) <= 0

		u_itmsg( "Não foram encontrados registros válidos no arquivo!" , "Atenção!",,1 )
		Return .F.
	
	EndIf

Else

	U_ITMSG("O arquivo "+_carq+" informado para relizar a importação não tem o layout padrão.",;
            "Arquivo com formato inválido",;
			"O CSV deve ter as colunas [ Titulo;Cliente;Valor do desconto;Parcela ] e o mesmo deve ser salvo "+;
		    "no Excel no formato [ CSV (separado por virgulas) ] e "+;
		    "no LibreOffice Calc com Demilitador de campo Ponto e Virgula e sem delimitador de texto.",1)
		Return .F.
	
Endif

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

_otemp:AddIndex( "01", {"WKSTATUS","FILIAL","TITU","WKPARCELA","VENCREA"} )

_otemp:Create()

_aMarcados:={}

FOR  _ni := 1 TO len(_adados)
	
	oproc:cCaption := ("Lendo: "+ StrZero( _ni , 6 ) +" de "+ StrZero( len(_adados) , 6 ) +" Registros..." )
	ProcessMessages()

	//(cAliasAux)->( RecLock( cAliasAux , .T. ) )
	(cAliasAux)->( DBAPPEND(  ) )
	(cAliasAux)->WKSTATUS 	:= _adados[_ni][09]
    (cAliasAux)->FILIAL	    := _adados[_ni][06]
	(cAliasAux)->TITU		:= _adados[_ni][01]
	(cAliasAux)->WKPARCELA	:= _adados[_ni][02]
	(cAliasAux)->CLIENTE	:= _adados[_ni][03]
	(cAliasAux)->LOJA		:= _adados[_ni][04]
	(cAliasAux)->NOME 		:= posicione("SA1",1,xfilial("SA1")+_adados[_ni][03]+_adados[_ni][04],"A1_NOME")
	(cAliasAux)->REDE		:= Capital( AllTrim( Posicione("ACY",1, xFilial("ACY")+posicione("SA1",1,xfilial("SA1")+_adados[_ni][03]+_adados[_ni][04],"A1_GRPVEN"),"ACY_DESCRI")))
	(cAliasAux)->CGC		:= MFIN027CGC( _adados[_ni][07] )
    //(cAliasAux)->VLRBAI     := ROUND(_adados[_ni][08],2)
	//(cAliasAux)->VLRBAI     := ROUND(_adados[_ni][08],2)
    (cAliasAux)->DESCONT    := ROUND(_adados[_ni][08],2)

	(cAliasAux)->ERRO   	:= _adados[_ni][10]
	IF _adados[_ni][11] # 0 
       SE1->(DBGOTO( _adados[_ni][11] ))
       (cAliasAux)->E5_VALOR:= ROUND(_adados[_ni][08],2)
	   (cAliasAux)->WKVALOR	:= SE1->E1_VALOR
	   (cAliasAux)->BAIXA	:= SE1->E1_BAIXA
	   (cAliasAux)->SALDO	:= SE1->E1_SALDO
	   (cAliasAux)->VENCREA := SE1->E1_VENCREA
       IF !EMPTY((cAliasAux)->BAIXA) 
	      (cAliasAux)->ERRO  := ALLTRIM((cAliasAux)->ERRO) + " [Esse Titulo contem Baixa(s): "+DTOC((cAliasAux)->BAIXA)+"]"
	   ENDIF

	   IF (cAliasAux)->FILIAL # xFilial("SE1")
 	      (cAliasAux)->WKSTATUS:= "R"
	      (cAliasAux)->ERRO  := ALLTRIM((cAliasAux)->ERRO) + " [Titulo não pertence a filial atual]"
	   ELSEIF (cAliasAux)->DESCONT = 0
 	      (cAliasAux)->WKSTATUS:= "R"
	      (cAliasAux)->ERRO  := ALLTRIM((cAliasAux)->ERRO) + " [Valor da Desconto do arquivo zerado]"
       ELSEIF (cAliasAux)->SALDO <= 0
 	      (cAliasAux)->WKSTATUS:= "R"
	      (cAliasAux)->ERRO    := ALLTRIM((cAliasAux)->ERRO) + " [Titulo sem Saldo]"
	   ELSEIF (cAliasAux)->SALDO < (cAliasAux)->DESCONT
 	      (cAliasAux)->WKSTATUS:= "R"
	      (cAliasAux)->ERRO  := ALLTRIM((cAliasAux)->ERRO) + " [Titulo com Saldo menor que o desconto]"
	   ENDIF
	   
	   (cAliasAux)->ERRO  := ALLTRIM((cAliasAux)->ERRO)//Para tirar os espacos da frente
	   (cAliasAux)->REGSE1:= SE1->( Recno() )
	ENDIF

	IF ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU }) = 0
       AADD(_aMarcados,{(cAliasAux)->FILIAL+(cAliasAux)->TITU,.F., "" })
	ENDIF

	//(cAliasAux)->( MSUnLock() )

NEXT 
cEmpAnt:=cEmpAnt
aAdd( _aFields , { "Filial"	 		   	, {|| (cAliasAux)->FILIAL + IF(!EMPTY((cAliasAux)->FILIAL)," - "+AllTrim(FWFilialName(cEmpAnt,(cAliasAux)->FILIAL,1)),"") }  	, "C" , "@!" , 0 , 12, 0 } )
aAdd( _aFields , { "Cliente"			, {|| (cAliasAux)->CLIENTE + " - " + (cAliasAux)->LOJA }  				, "C" , "@!" , 0 , 08		, 0 } )
aAdd( _aFields , { "Nome"				, {|| alltrim((cAliasAux)->NOME) + " - " + alltrim((cAliasAux)->REDE)}	, "C" , "@!" , 0 , 30		, 0 } )
aAdd( _aFields , { "CNPJ"				, {|| (cAliasAux)->CGC }	  									, "C" , "@!" 				, 0 , 12, 0 } )
aAdd( _aFields , { "Titulo"				, {|| (cAliasAux)->TITU  }										, "C" , "@!" 				, 0 , 10, 0 } )
aAdd( _aFields , { "Parcela"			, {|| (cAliasAux)->WKPARCELA }									, "C" , "@!" 				, 0 , 5	, 0 } )
aAdd( _aFields , { "Observação"			, {|| (cAliasAux)->ERRO  }									    , "C" , ""  				, 0 ,100, 0 } )
//aAdd( _aFields , { "Vlr. Baixa Arq."	, {|| (cAliasAux)->VLRBAI}									    , "N" , "@E 999,999,999.99" , 0 ,015, 2 } )
aAdd( _aFields , { "Desconto"	        , {|| (cAliasAux)->DESCONT}									    , "N" , "@E 999,999,999.99" , 0 ,015, 2 } )
aAdd( _aFields , { "Saldo Tit. Atual"   , {|| (cAliasAux)->SALDO }									    , "N" , "@E 999,999,999.99" , 0 ,015, 2 } )
aAdd( _aFields , { "Vlr. Tot. Atual"    , {|| (cAliasAux)->WKVALOR }										, "N" , "@E 999,999,999.99" , 0 ,015, 2 } )
aAdd( _aFields , { "Dt. Vencto"         , {|| (cAliasAux)->VENCREA }								    , "D" , "@D"                , 0 , 8 , 0 } )
aAdd( _aFields , { "Dt. Baixa"	        , {|| (cAliasAux)->BAIXA }									    , "D" , "@D"                , 0 , 8 , 0 } )

//             TITULO                       CAMPO                       TIPO                PICTURE              TAMANHO               DECIMAL
aAdd(_aFields,{AVSX3("E5_MOTBX  ",5),{||(cAliasAux)->E5_MOTBX  },AVSX3("E5_MOTBX  ",2),AVSX3("E5_MOTBX  ",6),0,AVSX3("E5_MOTBX  ",3),AVSX3("E5_MOTBX  ",4)})
aAdd(_aFields,{AVSX3("E1_PORTADO",5),{||(cAliasAux)->E1_PORTADO},AVSX3("E1_PORTADO",2),AVSX3("E1_PORTADO",6),0,AVSX3("E1_PORTADO",3),AVSX3("E1_PORTADO",4)})
aAdd(_aFields,{AVSX3("E1_AGEDEP ",5),{||(cAliasAux)->E1_AGEDEP },AVSX3("E1_AGEDEP ",2),AVSX3("E1_AGEDEP ",6),0,AVSX3("E1_AGEDEP ",3),AVSX3("E1_AGEDEP ",4)})
aAdd(_aFields,{AVSX3("E1_CONTA  ",5),{||(cAliasAux)->E1_CONTA  },AVSX3("E1_CONTA  ",2),AVSX3("E1_CONTA  ",6),0,AVSX3("E1_CONTA  ",3),AVSX3("E1_CONTA  ",4)})
aAdd(_aFields,{AVSX3("E1_BAIXA  ",5),{||(cAliasAux)->E1_BAIXA  },AVSX3("E1_BAIXA  ",2),AVSX3("E1_BAIXA  ",6),0,AVSX3("E1_BAIXA  ",3),AVSX3("E1_BAIXA  ",4)})
aAdd(_aFields,{AVSX3("E1_DTACRED",5),{||(cAliasAux)->E1_DTACRED},AVSX3("E1_DTACRED",2),AVSX3("E1_DTACRED",6),0,AVSX3("E1_DTACRED",3),AVSX3("E1_DTACRED",4)})
aAdd(_aFields,{AVSX3("E5_HISTOR ",5),{||(cAliasAux)->E5_HISTOR },AVSX3("E5_HISTOR ",2),AVSX3("E5_HISTOR ",6),0,AVSX3("E5_HISTOR ",3),AVSX3("E5_HISTOR ",4)})
aAdd(_aFields,{AVSX3("E1_DESCONT",5),{||(cAliasAux)->E1_DESCONT},AVSX3("E1_DESCONT",2),AVSX3("E1_DESCONT",6),0,AVSX3("E1_DESCONT",3),AVSX3("E1_DESCONT",4)})
aAdd(_aFields,{AVSX3("E1_MULTA  ",5),{||(cAliasAux)->E1_MULTA  },AVSX3("E1_MULTA  ",2),AVSX3("E1_MULTA  ",6),0,AVSX3("E1_MULTA  ",3),AVSX3("E1_MULTA  ",4)})
aAdd(_aFields,{AVSX3("E1_JUROS  ",5),{||(cAliasAux)->E1_JUROS  },AVSX3("E1_JUROS  ",2),AVSX3("E1_JUROS  ",6),0,AVSX3("E1_JUROS  ",3),AVSX3("E1_JUROS  ",4)})
aAdd(_aFields,{AVSX3("E5_VALOR  ",5),{||(cAliasAux)->E5_VALOR  },AVSX3("E5_VALOR  ",2),AVSX3("E5_VALOR  ",6),0,AVSX3("E5_VALOR  ",3),AVSX3("E5_VALOR  ",4)})

_apesqui := {}
aadd(_apesqui,{"Titulo",{{"Filial","C",2,0,"Filial",,}, {"Titulo","C",9,0,"Titulo",,}},1})

oMarkBRW:=FWMarkBrowse():New()		   											  		// Inicializa o Browse
oMarkBRW:SetAlias( cAliasAux )			   												// Define Alias que será a Base do Browse
oMarkBRW:SetDescription( "Leitura e Desconto de titulos a Receber" )			// Define o titulo do browse de marcacao
oMarkBRW:SetFieldMark( "MARCA" )														// Define o campo que sera utilizado para a marcação
oMarkBRW:SetMenuDef( 'MFIN027' )														// Força a utilização do menu da rotina atual
oMarkBRW:SetAllMark( {|| .F./*oMarkBRW:AllMark()*/ } )									// Ação do Clique no Header da Coluna de Marcação
oMarkBRW:SetCustomMarkRec({||IF((cAliasAux)->WKSTATUS$ "A,E",U_MFIN027R("MARCAR"),.F.)})// Indica o Code-Block executado para validar a marcação/desmarcação do registro
oMarkBRW:AddLegend( "(cAliasAux)->WKSTATUS = 'A' .AND. !EMPTY((cAliasAux)->WKPARCELA)","YELLOW", "Aceitos Parcelados")       // Permite adicionar legendas no Browse
oMarkBRW:AddLegend( "(cAliasAux)->WKSTATUS = 'A'","GREEN" , "Aceitos")                  // Permite adicionar legendas no Browse
oMarkBRW:AddLegend( "(cAliasAux)->WKSTATUS = 'R'","RED"   , "Rejeitados")               // Permite adicionar legendas no Browse
oMarkBRW:AddLegend( "(cAliasAux)->WKSTATUS = 'E'","ORANGE", "Analizar")                 // Permite adicionar legendas no Browse
oMarkBRW:AddLegend( "(cAliasAux)->WKSTATUS = 'P'","BLUE"  , "Processados")              // Permite adicionar legendas no Browse
oMarkBRW:SetFields( _aFields )													 		// Campos para exibição
oMarkBRW:SetSeek(.T., _apesqui)                                                         // Indica os campos que serão adicionados as colunas do Browse 
oMarkBRW:AddButton( "Confirmar"         , {|| fwmsgrun( ,{|oproc| U_MFIN027B(oproc)},"Aguarde","Processando..."           ) } ,, 4 )// Adiciona um botão 
oMarkBRW:AddButton( "Totais"            , {|| fwmsgrun( ,{|| MFIN027Totais()}, "Aguarde","Totalizando titulos marcados...") } ,, 4 )// Adiciona um botão 
oMarkBRW:AddButton( "Marca Todos"       , {|| fwmsgrun( ,{|| MFIN27Todos(.T.)  }, "Aguarde","Marcando..."   ) } ,, 4 )// Adiciona um botão 
oMarkBRW:AddButton( "Desmarca Todos"    , {|| fwmsgrun( ,{|| MFIN27Todos(.F.)  }, "Aguarde","Desmarcando...") } ,, 4 )// Adiciona um botão 
//oMarkBRW:AddButton( "Dados Baixa Manual", {|| IF((cAliasAux)->WKSTATUS$ "A,E",U_MFIN027R("ALTERAR_ATUAL"),U_ITMSG("Posicione em um registro Aceito.",'Atenção!',,1))   } ,, 4 )// Adiciona um botão 
//oMarkBRW:AddButton( "Dados Baixa Automatica",{|| U_MFIN027R("ALTERAR_MARCADOS")                                             } ,, 4 )// Adiciona um botão 
oMarkBRW:DisableConfig()                                                                // Desabilita a utilização das configurações do Browse 
oMarkBRW:Activate()																		// Ativacao da classe

(cAliasAux)->( DBCloseArea() )

Return .F.

/*
===============================================================================================================================
Programa----------: MenuDef
Autor-------------: Igor Melgaço
Data da Criacao---: 08/01/2025
Descrição---------: Rotina de construção do menu
Retorno-----------: aRotina
===============================================================================================================================
*/

Static Function MenuDef() As Array

Local aRotina	:= {}

ADD OPTION aRotina TITLE 'Visualizar'             ACTION 'U_MFIN027R("VISUAL")'           OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Dados Baixa Automatica" ACTION 'U_MFIN027R("ALTERAR_MARCADOS")' OPERATION 4 ACCESS 0 
ADD OPTION aRotina TITLE "Dados Baixa Manual"     ACTION 'EVAL({|| IF((cAliasAux)->WKSTATUS$ "A,E",U_MFIN027R("ALTERAR_ATUAL"),U_ITMSG("Posicione em um registro Aceito.","Atenção!",,1))   })' OPERATION 4 ACCESS 0 

Return( aRotina )

/*
===============================================================================================================================
Programa----------: MFIN027Totais
Autor-------------: Igor Melgaço
Data da Criacao---: 08/01/2025
Descrição---------: Mostra totais
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MFIN027Totais()

Local _aTot := {0,0,0,0} As Array 
Local _cTexto := "" As Character

(cAliasAux)->( DBGoTop() )

DO While (cAliasAux)->( !EOF() )

   IF (cAliasAux)->WKSTATUS $ "A,E"
      oMarkBRW:GoTo( (cAliasAux)->( RECNO() ) , .T. )
   ELSE
      (cAliasAux)->(DBSKIP())
      LOOP
   ENDIF
	
  	If (cAliasAux)->WKSTATUS $ "A,E" .AND. oMarkBRW:IsMark()
       _aTot[1]+=(cAliasAux)->E1_DESCONT
       _aTot[2]+=(cAliasAux)->E1_MULTA
       _aTot[3]+=(cAliasAux)->E1_JUROS
       _aTot[4]+=(cAliasAux)->E5_VALOR
	ENDIF	
	
	(cAliasAux)->( DbSkip() )
	
EndDo

(cAliasAux)->( DBGoTop() )          

_cTexto:="TOTAIS DOS TITULOS MARCADOS:"+CHR(13)+CHR(10)
_cTexto+="DESCONTOS: R$ "+ALLTRIM(TRANSF(_aTot[1],"@E 999,999,999,999.99"))+CHR(13)+CHR(10)
_cTexto+="MULTAS: R$ "   +ALLTRIM(TRANSF(_aTot[2],"@E 999,999,999,999.99"))+CHR(13)+CHR(10)
_cTexto+="JUROS: R$ "    +ALLTRIM(TRANSF(_aTot[3],"@E 999,999,999,999.99"))+CHR(13)+CHR(10)
_cTexto+="** VALOR TOTAL DAS BAIXAS: R$ "+ALLTRIM(TRANSF(_aTot[4],"@E 999,999,999,999.99"))+" **"+CHR(13)+CHR(10)
U_ITMSG(_cTexto,"TOTAIS",,2)

oMarkBRW:GoTop()
oMarkBRW:Refresh()

RETURN
/*
===============================================================================================================================
Programa----------: MFIN027CNS
Autor-------------: Igor Melgaço
Data da Criacao---: 08/01/2025
Descrição---------: Rotina de consulta do cadastro completo do Cliente
Parametros--------: _cChama: da onde chama
Retorno-----------: .T. OU .F.
===============================================================================================================================
*/
User Function MFIN027R(_cChama As Character) As Logical

Local lRet := .T. As Logical
Local nReg := 0 As Numeric

IF !_cChama == "ALTERAR_MARCADOS"
   
   IF (cAliasAux)->WKSTATUS = 'P'"
      U_ITMSG("Titulo já processado com sucesso","Atenção",,1)
      RETURN .F.
   ENDIF   
   
   IF (cAliasAux)->WKSTATUS = 'R'"
      U_ITMSG("Titulo rejeitado na leitura do arquivo.","Atenção",,1)
      RETURN .F.
   ENDIF

   IF (nReg:=(cAliasAux)->REGSE1) = 0 
       U_ITMSG("Titulo não encontrado no SE1","Atenção",,1)
      RETURN .F.
   ENDIF
   
   SE1->( DBGoTo( nReg ) )
ENDIF

If _cChama = "VISUAL"
   cCadastro := "Título para baixar"
   DBSelectArea("SE1")
   AxVisual("SE1",nReg,2)
   DBSelectArea(cAliasAux)//Tem volta para o alias do browse pq senão dá erro
   RETURN .F.
ENDIF

If _cChama == "MARCAR"

   IF !oMarkBRW:IsMark() //Testa pq do duplo clique ele chama essa função 2 veses OR botão Alterar
	  
	  IF (_nPos:=ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU })) # 0
         IF _aMarcados[_nPos,2]
            U_ITMSG("Titulo ["+(cAliasAux)->TITU+"] já marcado na Parcela - Vencimento: "+_aMarcados[_nPos,3],"Atenção",,1)
            RETURN .F.
         ENDIF
	  ENDIF
   
	  //_lsai :=.F.   
	  //Do while !_lsai
  	  lRet:=.T.//MFIN27Tela("SE1",nReg,4,_cChama)
	  //Enddo
      
      IF lRet
	     (oMarkBRW:Alias())->MARCA := oMarkBRW:Mark()
         IF (_nPos:=ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU })) # 0
            _aMarcados[_nPos,2]:=.T.
			_aMarcados[_nPos,3]:=ALLTRIM((cAliasAux)->WKPARCELA)+" - "+DTOC((cAliasAux)->VENCREA)
		 ENDIF
	  ENDIF
	
   Else
     
      (oMarkBRW:Alias())->MARCA := ""
      IF (_nPos:=ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU })) # 0
         _aMarcados[_nPos,2]:=.F.//A colocação do .T. esta dentro da função MFIN27Tela("SE1",nReg,4)
         _aMarcados[_nPos,3]:="" //O preenchimento esta dentro da função MFIN27Tela("SE1",nReg,4)
      ENDIF
   
   ENDIF

ELSEIf _cChama == "ALTERAR"
   
   IF oMarkBRW:IsMark()
   
   	  _lsai := .F.   	  
   	  Do while !_lsai   
   	  	 lRet:=MFIN27Tela("SE1",nReg,4,_cChama)   	  	
   	  Enddo
   	  
   ELSE
      U_ITMSG("Somente titulos marcados podem ser alterados.","Atenção",,1)
   ENDIF

ELSEIf _cChama == "ALTERAR_ATUAL"
   
   	  _lsai := .F.   	  
   	  Do while !_lsai   
   	  	 lRet:=MFIN27Tela("SE1",nReg,4,_cChama)   	  	
   	  Enddo

      IF lRet
	     (oMarkBRW:Alias())->MARCA := oMarkBRW:Mark()
		 oMarkBRW:Refresh()
	  ENDIF

ELSEIf _cChama == "ALTERAR_MARCADOS"
   
   	  _lsai := .F.   	  
   	  Do while !_lsai   
	     lRet:=MFIN27Tela("SE1",nReg,4,_cChama)   	  	
   	  Enddo

ENDIF
DBSelectArea(cAliasAux)//Tem volta para o alias do browse pq senão dá erro

Return lRet

/*
===============================================================================================================================
Programa----------: MFIN027CPS
Autor-------------: Igor Melgaço
Data da Criacao---: 08/01/2025
Descrição---------: Define a criação de campos para exibição da análise
Retorno-----------: aRet - Campos que serão criados e exibidos na tela
===============================================================================================================================
*/
Static Function MFIN027CPS() As Array

Local _aCpos := {} As Array

aAdd( _aCpos , { "WKSTATUS"	    , "C" , 01, 0 } )
aAdd( _aCpos , { "MARCA"		, "C" , 01, 0 } )
AAdd( _aCpos , { "FILIAL"		, "C" , TamSX3("A1_FILIAL")[01]		, 0 } )
AAdd( _aCpos , { "CLIENTE"		, "C" , TamSX3("A1_COD")[01]		, 0 } )
AAdd( _aCpos , { "LOJA"			, "C" , TamSX3("A1_LOJA")[01]		, 0 } )
AAdd( _aCpos , { "NOME"			, "C" , TamSX3("A1_NOME")[01]		, 0 } )
AAdd( _aCpos , { "REDE"			, "C" , TamSX3("ACY_DESCRI")[01]	, 0 } )
AAdd( _aCpos , { "CGC"			, "C" , 20, 0 } )
AAdd( _aCpos , { "TITU"			, "C" , 09, 0 } )
AAdd( _aCpos , { "WKPARCELA"	, "C" , 03, 0 } )
AAdd( _aCpos , { "CONDI"		, "C" , 05, 0 } )
AAdd( _aCpos , { "DCONDI"		, "C" , 20, 0 } )
AAdd( _aCpos , { "WKVALOR"		, "N" , 18, 2 } )
AAdd( _aCpos , { "VENCTO"		, "D" , 08, 0 } )
AAdd( _aCpos , { "VENCREA"		, "D" , 08, 0 } )
AAdd( _aCpos , { "VLRARQ"		, "N" , 18, 8 } )
AAdd( _aCpos , { "VLRBAI"		, "N" , 18, 8 } )
AAdd( _aCpos , { "BAIXA"  		, "D" , 08, 0 } )
AAdd( _aCpos , { "SALDO"  		, "N" , 18, 8 } )
AAdd( _aCpos , { "REGSE1"		, "N" , 18, 0 } )
AAdd( _aCpos , { "ERRO"	  	    , "M" , 10, 0 } )
AAdd( _aCpos , { "DESCONT"		, "N" , 15, 2 } )

AAdd( _aCpos , { "E5_MOTBX"	  	, "C" , LEN(SE5->E5_MOTBX)  , 0 } )
AAdd( _aCpos , { "E1_PORTADO" 	, "C" , LEN(SE1->E1_PORTADO), 0 } )
AAdd( _aCpos , { "E1_AGEDEP" 	, "C" , LEN(SE1->E1_AGEDEP) , 0 } )
AAdd( _aCpos , { "E1_CONTA" 	, "C" , LEN(SE1->E1_CONTA)  , 0 } )
AAdd( _aCpos , { "E5_HISTOR" 	, "C" , LEN(SE5->E5_HISTOR) , 0 } )
AAdd( _aCpos , { "E1_BAIXA" 	, "D" , 8  , 0 } )
AAdd( _aCpos , { "E1_DTACRED" 	, "D" , 8  , 0 } )
AAdd( _aCpos , { "E1_DESCONT" 	, "N" , 15 , 2 } )
AAdd( _aCpos , { "E1_MULTA" 	, "N" , 15 , 2 } )
AAdd( _aCpos , { "E1_JUROS" 	, "N" , 15 , 2 } )
AAdd( _aCpos , { "E5_VALOR" 	, "N" , 15 , 2 } )

Return( _aCpos )

/*
===============================================================================================================================
Programa----------: MFIN027B
Autor-------------: Igor Melgaço
Data da Criacao---: 08/01/2025
Descrição---------: Processa o o ajuste de vencimentos dos titulos marcados
Parametros--------: oproc - objeto da barra de processamento
Retorno-----------: NIL
===============================================================================================================================
*/
User Function MFIN027B(oProc As Object) As Object

Local _nRegAtu	:= 0 As Numeric
Local _nTotReg	:= (cAliasAux)->( LASTREC() ) As Numeric
Local _nRegSel	:= 0 As Numeric
Local _nRegErro	:= 0 As Numeric
Local _nRecSalva:= 0 As Numeric


(cAliasAux)->( DBGoTop() )

DO While (cAliasAux)->( !EOF() )

	_nRegAtu++
	oproc:cCaption := ("Processando... ["+ StrZero(_nRegAtu,6) +"] de ["+ StrZero(_nTotReg,6) +"] Baixados: "+StrZero(_nRegSel,5) )
	ProcessMessages()
    IF (cAliasAux)->WKSTATUS = "A"
       oMarkBRW:GoTo( (cAliasAux)->( RECNO() ) , .T. )
    ELSE
       (cAliasAux)->(DBSKIP())
       LOOP
    ENDIF
	
  	If (cAliasAux)->WKSTATUS = 'A' .AND. oMarkBRW:IsMark()//!EMPTY((cAliasAux)->MARCA)
	
	   //_nRecAtual:=(cAliasAux)->(RECNO())
       (cAliasAux)->(DBSKIP())
	   _nRecSalva:=(cAliasAux)->(RECNO())
  	   //(cAliasAux)->(DBGOTO(_nRecAtual))//
	   (cAliasAux)->(DBSKIP(-1))
	   _cErro:=""
	   IF MFIN27Baixa()//BAIXA SE1
	      (cAliasAux)->WKSTATUS:='P'
	      _nRegSel++
		  oMarkBRW:MarkRec()
		  oMarkBRW:Refresh()
	   ELSE
	      _nRegErro++
	      (cAliasAux)->WKSTATUS:='E'
	      (cAliasAux)->ERRO  :=_cErro
	   ENDIF	
       (oMarkBRW:Alias())->MARCA := ""//Desmarca Sempre
       IF (_nPos:=ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU })) # 0
          _aMarcados[_nPos,2]:=.F.//A colocação do .T. esta dentro da função MFIN27Tela("SE1",nReg,4)
          _aMarcados[_nPos,3]:="" //O preenchimento esta dentro da função MFIN27Tela("SE1",nReg,4)
       ENDIF

	   (cAliasAux)->(DBGOTO(_nRecSalva))
    ELSE
	   (cAliasAux)->( DbSkip() )
	ENDIF		
	
EndDo

(cAliasAux)->( DBGoTop() )

_cMen:=ALLTRIM(STR(_nRegAtu))+" registro(s) processado(s)."+CHR(13)+CHR(10)
_cMen+=ALLTRIM(STR(_nRegSel))+" registro(s) Baixado(s) com sucesso."+CHR(13)+CHR(10)
_cMen+=ALLTRIM(STR(_nRegErro))+" registro(s) com erro."

U_ITMSG(_cMen,"Concluído!",,2)

oMarkBRW:Refresh()
oMarkBRW:GoTop()
ProcessMessages()

Return()

/*
===============================================================================================================================
Programa----------: MFIN027CGC
Autor-------------: Igor Melgaço
Data da Criacao---: 08/01/2025
Descrição---------: Formatação da Máscara para CPF/CNPJ
Parametros--------: _cCGCAux - cnpj sem máscara
Retorno-----------: _cRet - cnpj com máscara
===============================================================================================================================
*/
Static Function MFIN027CGC( _cCGCAux As Character) As Character

Local _cRet	:= "" As Character
Local _cAux	:= AllTrim( _cCGCAux ) As Character

IF Len( _cAux	 ) > 11

	_cAux	 := PadL( _cAux	 , 14 , "0" )
	_cRet := Transform( _cAux	 , "@R! NN.NNN.NNN/NNNN-99" )
	
Else

	_cAux	 := PadL( _cAux	 , 11 , "0" )
	_cRet := Transform( _cAux	 , "@R 999.999.999-99" )
	
EndIF

Return( _cRet )

/*
===============================================================================================================================
Programa----------: MFIN027L
Autor-------------: Igor Melgaço
Data da Criacao---: 08/01/2025
Descrição---------: Faz a leitura de dados no layout do Atacadao
Parametros--------: _nreg - número de linhas do arquivo
				    _llibof - se foi convertido pelo libreoffice
				    oproc - objeto da barra de processamento
Retorno-----------: _adados - array com dados carregados do arquivo
===============================================================================================================================
*/

Static function MFIN027L(_nReg As Numeric,_lLibof As Logical,oProc As Object, _aRegs As Array) As Array

Local _nCont 	   := 0 As Numeric
Local _cdados	   := "" As Character
Local _alinha	   := {} As Array
Local _adados 	   := {} As Array
Local _nTamCli     := TamSX3("A1_COD")[01] As Numeric
Local _cParcela    := "" As Character
Local _nValorTotal := 0 As Numeric
Local _cquery	   := "" As Character
Local _nColTit     := 1 As Numeric
Local _nColCli     := 2 As Numeric
Local _nColVlB     := 3 As Numeric
Local _nColPar     := 4 As Numeric
Local i := 0 As Numeric

Local _cAliasSE1 := GetNextAlias() 

For i := 1 To Len(_aRegs)

	_nCont++ 

	oproc:cCaption := ( "Lendo linha " + strzero(_nCont,5) + " de " + strzero(_nreg,5) + "." )
	ProcessMessages()

    _cDados := _aRegs[i]

	_aLinha := StrTokArr(_cDados,";")
	
	//Verifica se é final de arquivo
	If alltrim(_cdados) = ';;' .and. _nCont > 5
		Exit
	Endif 	
	
	//Verifica se é linha válida
	If len(_aLinha) >= 3
   
        _alinha[_nColVlB]:=STRTRAN(_alinha[_nColVlB],".","")//Tira o seprador de milhar brasileiro
        _alinha[_nColVlB]:=STRTRAN(_alinha[_nColVlB],",",".")//Troca os sepradores de decimal brasileiro para o ingles

        _nValorTotal:=0
       	IF LEN(_alinha) > 3
           _cParcela:=Strzero(val(_alinha[_nColPar]),2)
        ELSE
           _cParcela:=""
        ENDIF

    	_cQuery := "SELECT E1_FILIAL, E1_LOJA , E1_PARCELA , E1_VALOR , E1_SALDO , R_E_C_N_O_ REC_SE1 
        _cQuery += " FROM " +retsqlname("SE1") + " SE1 "
        _cQuery += " WHERE D_E_L_E_T_ = ' ' "
    	_cQuery += "    AND E1_TIPO    = 'NF' "
    	_cQuery += "    AND E1_NUM     = '" + Strzero(val(_alinha[_nColTit]),9) + "'"
    	_cQuery += "    AND E1_CLIENTE = '" + Strzero(val(_alinha[_nColCli]),_nTamCli)+"' "
        IF !EMPTY(val(_cParcela))
    	   _cQuery += " AND E1_PARCELA = '" + _cParcela + "'"
    	ENDIF
    	_cQuery += " ORDER BY E1_FILIAL, E1_NUM, E1_PARCELA, E1_VENCREA "

        _cQuery := ChangeQuery(_cQuery)

        MPSysOpenQuery( _cQuery , _cAliasSE1 )

    	_nTotTit:=0
        
        Dbselectarea(_cAliasSE1)
    	COUNT TO _nTotTit
    	
        If _nTotTit = 0
           _cErro:="[Titulo nao encontrado] "
           _cTipoErro:="R"//WKSTATUS
        ELSE
           _cErro:=""
           _cTipoErro:="A"//WKSTATUS
        ENDIF
        (_cAliasSE1)->(DBGOTOP())
    	DO WHILE !(_cAliasSE1)->(Eof()) .OR. _nTotTit = 0

            IF _nTotTit > 1
                _cErro:="[Existem "+ALLTRIM(STR(_nTotTit))+" titulos com esse No.: "+Strzero(val(_alinha[_nColTit]),9)+"] "
                _cTipoErro:='E'//Deixa marcar para baixar WKSTATUS
            ENDIF
    	    
            IF (_cAliasSE1)->E1_SALDO < val(_alinha[_nColVlB])  
                _cErro+="[Saldo do título  R$ "+ALLTRIM(STR((_cAliasSE1)->E1_SALDO,15,2))+" menor que o desconto.] "
                _cTipoErro:='E'//Deixa marcar para baixar WKSTATUS
            EndIf
    	    
            aadd(_adados,{Strzero(val(_alinha[_nColTit]),9),;  													//01 -num titulo
    					 (_cAliasSE1)->E1_PARCELA                 ,;													//02 - parcela
    					 Strzero(val(_alinha[_nColCli]),_nTamCli),;												//03 - codigo do cliente
    					 (_cAliasSE1)->E1_LOJA	 				  ,;													//04 - loja do cliente  Strzero(val(_alinha[_nColLoj]),4)
    					 _nValorTotal                     ,;													//05 - Valor Titulo
    					 (_cAliasSE1)->E1_FILIAL  		   		  ,;													//06 - filial Italac
    					 posicione("SA1",1,xfilial("SA1")+Strzero(val(_alinha[_nColCli]),_nTamCli)+(_cAliasSE1)->E1_LOJA,"A1_CGC"),;//07 - CNPJ cliente
    					 val(_alinha[_nColVlB])           ,;													//08 - Valor Baixa
    					 _cTipoErro                       ,;													//09 - Bola Vermelha
    					 _cErro                           ,;													//10 - Erro WKSTATUS
    					 (_cAliasSE1)->REC_SE1				      })													//11 - Recno SE1
    	    
            IF _nTotTit = 0
                EXIT
            ENDIF

            _cErro := ""

            (_cAliasSE1)->( DBSKIP() )	    

    	ENDDO

    	(_cAliasSE1)->( Dbclosearea() )

    EndIf
	
Next
	
Return _adados


/*
===============================================================================================================================
Programa----------: MFIN27Tela()
Autor-------------: Igor Melgaço
Data da Criacao---: 08/01/2025
Descrição---------: Tela para Baixa de Titulos
Parametros--------: cAlias,nReg,nOpcx//Padroes
Retorno-----------: .T. OU .F.
===============================================================================================================================
*/
STATIC Function MFIN27Tela(cAlias As Character,nReg As Numeric,nOpcx As Numeric,_cChama As Character) As Logical

LOCAL oDlg As Object
LOCAL oCbx As Object
LOCAL oCodCli As Object
LOCAL aDescMotbx := {} As Array   
LOCAL oMulta As Object
LOCAL oJuros As Object
LOCAL nDecrescF := 0 As Numeric
LOCAL nOpt := 0 As Numeric
LOCAL lRet     :=.F. As Logical
LOCAL nSalvRec := 0 As Numeric
LOCAL cParcela := "" As Character
LOCAL cNum := CRIAVAR ("E1_NUM",.F.) As Character
LOCAL cPrefixo := "" As Character
LOCAL cMoeda := "" As Character
LOCAL nOrdem := 0 As Numeric
LOCAL aCaixaLoja := {} As Array
LOCAL nTolerPg    := GetMv("MV_TOLERPG") As Numeric
LOCAL aMotBx	  := ReadMotBx() As Array
LOCAL nEstOriginal:= 0 As Numeric
Local nUltLin := 0 As Numeric
Local bSetKey  := {||} As Block
Local aColsSEV := {} As Array
Local NI := 0 As Numeric
Local aArea      := GetArea() As Array
Local nTotAdto   := 0 As Numeric
Local lBaixaAbat := .F. As Logical
Local nVlrBaixa  := 0 As Numeric
Local lBxCec     := .F. As Logical
Local lBxLiq	 := .F. As Logical
Local cTipo  := "" As Character
Local cCliente := "" As Character
Local cLoja := "" As Character           
Local aBaixa   := {} As  Array
Local x := 0 As Numeric
Local nLinha   := 0 As Numeric
LOCAL oValorLiq As Object
Local nLin2    := 0 As Numeric
LOCAL oNaturez As Object
LOCAL oTipo As Object
Local lAcessMul	:= .T. As Logical
Local lAcessJur	:= .T. As Logical
Local lAcessDesc:= .T. As Logical
Local lAcessdBaixa:= .T. As Logical
Local lAcessDtCredito:= .T. As Logical

Local oDtBaixa As Object
Local oDtCredito As Object
Local nTotMult		:= 0 As Numeric

//Controla o Pis Cofins e Csll na baixa  (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default) )
Local lPccBxCr  := .F. As Logical //If (lFuncPCCBx,FPccBxCr(),.F.)
Local lIrPjBxCr	:= .F. As Logical //If (lFuncIrPjBx,FIrPjBxCr(),.F.) //Controla IRPJ na baixa
Local lTipBxCP  := .F. As Logical 
Local lSigaloja := .F. As Logical 
Local lTpDesc	:= SE5->(FieldPos("E5_TPDESC"))	> 0  As Logical //Verifica campo TPDESC na tabela SE5 (<C>ondicional ou <I>ncondicional)
Local lNatApura	:=	.F.  As Logical //Natureza configurada para apurar impostos no SPED PIS/COFINS.                                    
Local lCposSped	:=	 (SED->(FieldPos("ED_APURCOF")) > 0 .And. SED->(FieldPos("ED_APURPIS")) > 0)  As Logical //Campos que apuram impostos no SPED PIS/COFINS.
Local aAreaSED 	:= {} As Array
Local cAuxMBx	:= "" As Character
Local dDtRecbAux := CTOD("") As Date
Local _nPos     := 0 As Numeric
Local nParcImp	:= 0 As Numeric 

IF _cChama == "ALTERAR_MARCADOS"
   
   (cAliasAux)->(DBGOTOP())
   DO WHILE (cAliasAux)->(!EOF())           
	  oMarkBRW:GoTo( (cAliasAux)->( RECNO() ) , .T. )
  	  IF (cAliasAux)->WKSTATUS = "A" .AND. oMarkBRW:IsMark()
	     EXIT
	  ENDIF
      (cAliasAux)->(DBSKIP())
   ENDDO

   IF (cAliasAux)->(EOF())  
       U_ITMSG("Marque 2 ou mais titulos para usar essa opção","Atenção",,1)
	   _lsai := .T.
      RETURN .F.
   ENDIF

   IF (nReg:=(cAliasAux)->REGSE1) = 0 
       U_ITMSG("Titulo não encontrado no SE1","Atenção",,1)
	   _lsai := .T.
      RETURN .F.
   ENDIF
   
   SE1->( DBGoTo( nReg ) )

ENDIF 

nValRec   := (cAliasAux)->E5_VALOR
cMotBx    := (cAliasAux)->E5_MOTBX
cBanco    := (cAliasAux)->E1_PORTADO
cAgencia  := (cAliasAux)->E1_AGEDEP
cConta    := (cAliasAux)->E1_CONTA
dBaixa    := (cAliasAux)->E1_BAIXA
dDtCredito:= (cAliasAux)->E1_DTACRED
cHist070  := (cAliasAux)->E5_HISTOR
nDescont  := (cAliasAux)->E1_DESCONT
nMulta    := (cAliasAux)->E1_MULTA
nJuros    := (cAliasAux)->E1_JUROS

Pergunte("FIN070",.F.)

PRIVATE lF070Auto := .F. As Logical
PRIVATE aCaixaFin := xCxFina() As Array// Caixa Geral do Financeiro (MV_CXFIN)
PRIVATE lRaRtImp  := .F. As Logical //lFinImp .And.FRaRtImp()     //Define se ha retencao de impostos PCC/IRPJ no R.A 
PRIVATE nParciais := 0 As Numeric
PRIVATE aBaixaSE5 := {} As Array
PRIVATE oVlEstrang As Object
PRIVATE oValrec As Object
PRIVATE oCM As Object
PRIVATE oAgencia  As Object
PRIVATE oBanco As Object
PRIVATE oConta As Object
PRIVATE oDescont As Object
PRIVATE nOtrga      := 0 As Numeric
PRIVATE nDifCambio  := 0 As Numeric
PRIVATE aTxMoedas	:= {} As Array
PRIVATE cModSpb		:= "1" As Character       
PRIVATE nAcrescF := 0 As Numeric
//Variaveis PRIVATE utilizadas pela funcao FA040AxAlt()
PRIVATE nIndexSE1   := "" As Character
PRIVATE cIndexSE1   := "" As Character
PRIVATE lAltera     := .T. As Logical
PRIVATE nOldValor   := SE1->E1_VALOR  As Numeric
PRIVATE nOldIrrf    := SE1->E1_IRRF As Numeric
PRIVATE nOldIss     := SE1->E1_ISS As Numeric
PRIVATE nOldInss    := SE1->E1_INSS As Numeric
PRIVATE nOldPis     := SE1->E1_PIS As Numeric
PRIVATE nOldCofins  := SE1->E1_COFINS As Numeric
PRIVATE nOldCsll    := SE1->E1_CSLL As Numeric
PRIVATE nOldVlAcres := SE1->E1_ACRESC As Numeric
PRIVATE nOldVlDecres:= SE1->E1_DECRESC As Numeric                
PRIVATE lAlterNat   := .F. As Logical
PRIVATE nOldVencto  := SE1->E1_VENCTO As Date
PRIVATE nOldVenRea  := SE1->E1_VENCREA As Date
PRIVATE cOldNatur	:= SE1->E1_NATUREZ As Character
PRIVATE nOldVlCruz	:= SE1->E1_VLCRUZ As Numeric
PRIVATE lAlterImp   := .F. As Logical
PRIVATE aDadosRet	:= {} As Array
PRIVATE nSomaCheq   := 0 As Numeric
Private nIrrf       := 0 As Numeric
PRIVATE nOldDescont := 0 As Numeric
PRIVATE nOldMulta   := 0 As Numeric
PRIVATE nOldJuros   := 0  As Numeric
PRIVATE lTitLote    :=.T. As Logical
Private cTpDesc     := "I" As Character               
PRIVATE lBloqSa1    := .T. As Logical
PRIVATE cFilAbat 	:= FwXFilial("SE1",cFilAnt) As Character
PRIVATE LBOLSA	    := .F. As Logical
PRIVATE lValidou	:= .F. As Logical //Usado na função AtulValidou() do FINA070.PRX
PRIVATE lF415Auto   := .F. As Logical //Usado na função FA070VALVR() do FINA070.PRX
PRIVATE lBQ10925    := SuperGetMV("MV_BQ10925",,"2") == "1" .And. !lRaRtImp  As Logical

//Variaveis utilizada para acrescimo e decrescimo
aBxAcr	:= {} 
aBxDec	:= {} 
nDecrVlr:= 0		//tratar visualizacao da varivel na tela de valores  
// Zerar variaveis para contabilizar os impostos da lei 10925.
VALOR5  := 0
VALOR6  := 0
VALOR7  := 0                   
PIS		:= 0
COFINS	:= 0
CSLL	:= 0
IRRF	:= 0
cTpDesc	:= "I"	
nOpc1   := 0

//Monta Hist¢rico da Baixa para digita‡„o pelo usu rio                  
IF EMPTY(cHist070) .AND. !_cChama == "ALTERAR_MARCADOS"
   cHist070 := Criavar("E5_HISTOR")        //Inicilizador padrao
   cHist070:=SE1->E1_NOMCLI+Space(Len(cHist070)-Len(SE1->E1_NOMCLI))//Copiei do User Func tion F070ACRE()
ENDIF

nOrdem:=IndexOrd()
dbSetOrder(1)

//Cria as vari veis utilizadas para receber os dados do t¡tulo           
IF EMPTY(dDtCredito)
   dDtCredito:= dDataBase
ENDIF
aCaixaLoja:= xCxLoja()
cPortado  := cBanco
If MV_PAR10 == 2 .AND. Empty(cBanco)
   cPortado    := IIF(SE1->E1_SITUACA $ "0FG", aCaixaFin[1] ,cBanco)
   cBanco      := IIF(SE1->E1_SITUACA $ "0FG", aCaixaFin[1] ,cBanco)
   cAgencia    := IIF(SE1->E1_SITUACA $ "0FG", aCaixaFin[2] ,cAgencia)
   cConta      := IIF(SE1->E1_SITUACA $ "0FG", aCaixaFin[3] ,cConta)
EndIf	

//Obtem a moeda do banco
nOrdSA6:=SA6->(IndexOrd())
DbSetOrder(1)
SA6->(MsSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
nMoedaBco:= Max(SA6->A6_MOEDA,1)
SA6->(DbSetOrder(nOrdSA6))
IF EMPTY(dBaixa)
   dBaixa:=dDataBase
ENDIF

//SIGAPFS‚ A cotação para baixa dos títulos no módulo jurídico deve ser sempre na cotação diária.   
If UPPER(Alltrim(SE1->E1_ORIGEM)) $ "JURA203"  
	nTxMoeda := If(SE1->E1_MOEDA > 1, RecMoeda(dBaixa,SE1->E1_MOEDA), 0)
Else
	nTxMoeda := If(SE1->E1_MOEDA > 1, If(SE1->E1_TXMOEDA > 0, SE1->E1_TXMOEDA,RecMoeda(dBaixa,SE1->E1_MOEDA)),0)
EndIf

//verifica se o titulo é da integração Protheus X Tin, caso afirmativo, não e permitido alterar os valores
If AllTrim(SE1->E1_ORIGEM)=="FINI055"  .And. !SuperGetMv("MV_ITLBCPO",,.F.) == .F.
	lAcessMul      := .F.
	lAcessDesc     := .F.
	lAcessJur      := .F.
	lAcessdBaixa   := .F.
	lAcessDtCredito:= .F.
Elseif AllTrim(SE1->E1_ORIGEM)=="FINI055"  .And. SuperGetMv("MV_ITLBCPO",,.F.) == .T.
	lAcessMul      := .T.
	lAcessDesc     := .T.
	lAcessJur      := .T.
	lAcessdBaixa   := .T.
	lAcessDtCredito:= .T. 
Endif

cDesc1 	:= SubStr(GetMV("MV_SIMB1"),1,3)
cDesc2 	:= SubStr(GetMV("MV_SIMB2"),1,3)
cDesc3 	:= SubStr(GetMV("MV_SIMB3"),1,3)
cDesc4 	:= SubStr(GetMV("MV_SIMB4"),1,3)
cDesc5 	:= SubStr(GetMV("MV_SIMB5"),1,3)

Begin Sequence
    nISS        := 0
    nOpc1		:= 0
	nPIS	    := 0
	nCOFINS    	:= 0	
	nCSLL    	:= 0	
	nVlRetPis	:= 0
	nVlRetCof	:= 0
	nVlRetCsl	:= 0	
	nCM         := 0
	nValEstrang := 0
	nParciais   := 0
	aBaixaSE5   :={}
	nAcrescF    := SE1->E1_SDACRES 
	nDeCrescF	:= 0//SE1->E1_SDDECRE  + nDecrVlr
	nTotMult	:= 0 
    lRet        := .F.
	lNatApura	:= .F.
	aAreaSED 	:= SED->(GetArea())
	DbSelectArea("SED")							
	DbSetOrder(1)			
	If DbSeek(xFilial("SED")+ SE1->E1_NATUREZ) .And. lCposSped
		If (!Empty(SED->ED_APURCOF) .Or. !Empty(SED->ED_APURPIS))
			lNatApura	:=	.T. //Natureza configurada para apurar impostos no SPED PIS/COFINS.
		Endif	
	Endif
   RestArea(aAreaSED)

	nAcresc   := Round(NoRound(xMoeda(nAcrescF,SE1->E1_MOEDA,nMoedaBco,dBaixa,3,nTxMoeda),3),2)
	nDecresc  := Round(NoRound(xMoeda(nDeCrescF,SE1->E1_MOEDA,nMoedaBco,dBaixa,3,nTxMoeda),3),2)
	nCM1      := 0
	nProRata  := 0
	nSalvRec  := RecNO()
	cNum      := SE1->E1_NUM
	cPrefixo  := SE1->E1_PREFIXO
	cParcela  := SE1->E1_PARCELA
	cTipo     := SE1->E1_TIPO
	cCliente  := SE1->E1_CLIENTE
	cLoja     := SE1->E1_LOJA
	nTotAbat  := 0
	nTotAbImp := 0
	nTotAbLiq := 0
	nValorLiq := 0     
	nValPadrao:= 0
	nJurosZero:= 0
	nTotAbat  := SumAbatRec(cPrefixo,cNum,cParcela,SE1->E1_MOEDA,"S",dBaixa,@nTotAbImp,,,,,,cFilAbat, nTxMoeda)
	nVa:=0//Para não dar o erro: variable does not exist NVA on FA070CALC(FINA070.PRX) / Called from FA070CALC(FINA070.PRX) 03/10/2017 15:40:45 line : 7909 /Called from FA070VAL(FINA070.PRX) 03/10/2017 15:40:45 line : 7738

	
	nTotAbLiq := nTotAbat - nTotAbImp
	dbGoto(nSalvRec)
	cMoeda := IIF(Empty(SE1->E1_MOEDA),"1",AllTrim(Str(SE1->E1_MOEDA,2)))

	//Recebe os dados do t¡tulo a ser baixado                                
	SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
	cTitulo		:= SE1->E1_PREFIXO + " " + SE1->E1_NUM+ " " + SE1->E1_PARCELA
	cSituacao 	:= SE1->E1_SITUACA + " " + fa070situa()
	If cMoeda == "1"
		cDescMoeda 	:= cDesc1
	Endif
	
	If cMoeda == "2"
		cDescMoeda 	:= cDesc2
	Endif
	
	If cMoeda == "3"
		cDescMoeda 	:= cDesc3
	Endif
	
	If cMoeda == "4"
		cDescMoeda 	:= cDesc4
	Endif
	
	If cMoeda == "5"
		cDescMoeda 	:= cDesc5
	Endif
	
	
	// Para que o valor da baixa parcial nao fique negativo, verifico o saldo 
	If (SE1->E1_VALOR > SE1->E1_SALDO) .And. Empty(SE1->E1_TIPOLIQ)
		// Procura pelas baixas deste titulo  
		lTipBxCP:=lRaRtImp
		aBaixa := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /" + MV_CRNEG, cPrefixo, cNum, cParcela, cTipo,; 
			@nTotAdto, @lBaixaAbat, cCliente, cLoja, @nVlrBaixa, , @lBxCec, @lBxLiq ,@lSigaloja, @lTipBxCP)
		For x := 1 To Len(aBaixaSE5)
			nParciais += aBaixaSE5[x][8]
   			If lPccBxCr .And. lRaRtImp //.And. nParciais > nVlMinImp
			   nParciais += aBaixaSE5[x][18]+aBaixaSE5[x][19]+aBaixaSE5[x][20]+aBaixaSE5[x][30]// somar impostos PCC 
			Endif  
			nTotMult	 += (aBaixaSE5[x][14]+aBaixaSE5[x][15])  // Soma Acrescimo mais Multa
			If lRaRtImp
		 		nParciais += aBaixaSE5[x][32]+aBaixaSE5[x][33]
		 		nTotAbat  -= aBaixaSE5[x][32]+aBaixaSE5[x][33]
			Endif
		Next
		nParciais += nTotAdto
		If !lBQ10925
			nParciais	+= nParcImp
		EndIf
		//Soma valor de decrescimo em baixas parciais, para evitar 
		//diferencas entre valor original e valor recebido     
		If SE1->E1_SDDECRE <> SE1->E1_DECRESC
			nParciais += ( SE1->E1_DECRESC - SE1->E1_SDDECRE )
		EndIf
	Else
		nParciais 	:= SE1->E1_VALOR-SE1->E1_SALDO
	Endif
	
	If "RA" $ SE1->E1_TIPO
		nParciais 	:= SE1->E1_VALOR-SE1->E1_SALDO
	Endif	
	
	//Array aDescMotbx contendo apenas a descricao do motivo das Baixas.
	
    If Len( aDescMotbx ) == 0
		For nI := 1 to len( aMotBx )
            If substr(aMotBx[nI],01,03) == "DCT" 
                AADD( aDescMotbx,SubStr(aMotBx[nI],07,10))
            Endif
            /*
			If SubStr(aMotBx[nI],34,01) == "A" .or. SubStr(aMotBx[nI],34,01) =="R"
				If !(substr(aMotBx[nI],01,03) $ "FAT|LOJ|LIQ|CEC|CMP|STP") 
					AADD( aDescMotbx,SubStr(aMotBx[nI],07,10))
				EndIf
			EndIf
            */
		Next nI
	EndIf
    
	// Carrega varivael cmotbx para sua verifcacao na funcao fa080totmes()
	IF EMPTY(cMotBx)
       cMotBx:=criavar("E5_MOTBX")
  	   //cMotBx:="NORMAL    "///aDescMotBx[11]//NORMAL FA070POS
       cMotBx:="DESCONTO  "
    ENDIF
	nOldValRec:= nValRec//Para a função FA070ValRec() do FINA070.PRX
	aColsSEV  := {}

	nAuxJuros  :=nJuros  //Salva caso o usuario já alterou
	nAuxDescont:=nDescont//Salva caso o usuario já alterou

    IF !EMPTY(nAuxJuros)
       nJuros:=nAuxJuros//Volta caso o usuario já alterou
    ENDIF
    IF !EMPTY(nAuxDescont)
       nDescont:=nAuxDescont//Volta caso o usuario já alterou
    ENDIF
   
	bSetKey := SetKey(VK_F4,{|| If( !SE1->E1_TIPO $ MV_CRNEG,CadCheqCR(cBanco,cAgencia,cConta,nValRec,dBaixa,1),.F.)})

	DEFINE FONT oFontLbl NAME "Arial" SIZE 6, 15 BOLD
	nLin2 := 602
  
    DEFINE MSDIALOG oDlg FROM  69,33 TO nLin2,581 TITLE "Baixas a Receber" PIXEL //OF oMainWnd  
  
		oPanel1 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,45,45,.f.,.f. )

		oPanel2 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,30,30,.f.,.f. )
		
     IF !_cChama == "ALTERAR_MARCADOS"
		@ 001,002 GROUP oGrp1 TO 043, 272 LABEL "Principal" OF oPanel1 PIXEL 
		@ 001,139 GROUP oGrp3 TO 150, 272 LABEL "Valores da Baixa" OF oPanel2  PIXEL 
		oGrp1:oFont := oFontLbl
		oGrp3:oFont := oFontLbl
     ENDIF
	
		@ 001,002 GROUP oGrp2 TO 150, 133 LABEL "Dados Gerais" OF oPanel2  PIXEL 

		oGrp2:oFont := oFontLbl

    IF !_cChama == "ALTERAR_MARCADOS"
		//Dados do titulo
		@ 008,004 SAY "Prefixo"				SIZE 31,07 OF oPanel1 PIXEL 
		@ 008,027 MSGET SE1->E1_PREFIXO	SIZE 25,08 OF oPanel1 PIXEL When .F.
		@ 008,060 SAY "Número" 				SIZE 31,07 OF oPanel1 PIXEL 
		@ 008,085 MSGET SE1->E1_NUM		SIZE 70,08 OF oPanel1 PIXEL When .F.
		@ 008,165 SAY "Parcela"				SIZE 31,07 OF oPanel1 PIXEL 
		@ 008,188 MSGET SE1->E1_PARCELA	SIZE 25,08 OF oPanel1 PIXEL When .F.
		@ 008,220 SAY "Tipo"				SIZE 31,07 OF oPanel1 PIXEL 
		@ 008,238 MSGET oTipo VAR cTipo	F3 "SE1RDO" SIZE 30,08 OF oPanel1 PIXEL HASBUTTON  When .F.
		
		@ 019,004 SAY "Cliente" SIZE 22, 07 OF oPanel1 PIXEL 
		@ 019,027 MSGET oCodCli VAR SE1->E1_CLIENTE F3 "SA1" SIZE 65,08 OF oPanel1 PIXEL HASBUTTON  When .F.
		@ 019,105 MSGET SA1->A1_NOME SIZE 165,08 OF oPanel1 PIXEL When .F.

		@ 030,004 SAY "Natureza" 				SIZE 31,07 OF oPanel1 PIXEL 
		@ 030,027 MSGET oNaturez VAR SE1->E1_NATUREZ	F3 "SED" SIZE 70,08 OF oPanel1 PIXEL HASBUTTON  When .F.
		@ 030,105 SAY "Emissao" 				SIZE 31,07 OF oPanel1 PIXEL 
		@ 030,133 MSGET SE1->E1_EMISSAO	SIZE 48,08 OF oPanel1 PIXEL When .F.
		@ 030,189 SAY "Vencto.Atual"			SIZE 49,07 OF oPanel1 PIXEL 
		@ 030,222 MSGET SE1->E1_VENCREA	SIZE 48,08 OF oPanel1 PIXEL When .F.
    ENDIF
      
		//////////////////////////
		//Dados Gerais		

	 nUltLin := 10
     IF !_cChama == "ALTERAR_MARCADOS"
		@ nUltLin,005 SAY "Hist.Emissao" SIZE 39, 07 OF oPanel2 PIXEL 
		@ nUltLin,065 MSGET SE1->E1_HIST       SIZE 65, 08 OF oPanel2 PIXEL When .F.
		nUltLin += 12

		@ nUltLin,005 SAY "Situacao" SIZE 35, 07 OF oPanel2 PIXEL 
		@ nUltLin,065 MSGET cSituacao          SIZE 65, 08 OF oPanel2 PIXEL When .F.
		nUltLin += 12	
     ENDIF

		@ nUltLin,005 SAY "Mot.Baixa" SIZE 32, 07 OF oPanel2 PIXEL 

		@ nUltLin,065 MSCOMBOBOX oCbx VAR cMotBx ITEMS aDescMotBx SIZE 65, 47 OF oPanel2 PIXEL ;
															ON CHANGE oBanco:lReadOnly := SE1->E1_SITUACA$"27" .or. !MovBcobx(cMotBx, .T.) ;
															VALID fa070BDev(oJuros, oMulta, oDescont, oCM, nTxMoeda, oCbx)	//.and. ;
															//fA070Val(nValRec,nTxMoeda,(!Empty(oCbx) .AND. oCbx:lModified))
	
		nUltLin += 17
		@ nUltLin,005 SAY "Banco" SIZE 32, 07 OF oPanel2 PIXEL 
		
		
		@ nUltLin,065 MSGET oBanco var cBanco  SIZE 65, 08 OF oPanel2 PIXEL F3 "SA6" ;
				Valid ( AtulValidou() .And. !MovBcobx(cMotBx, .T.) .and. Empty(cBanco) ) .or. (F070VldBco(cBanco,@cAgencia,@cConta,.T.,.T.) ) HASBUTTON
		oBanco:lReadOnly := (SE1->E1_SITUACA$"27" .OR. !MovBcobx(cMotBx, .T.))
		
		nUltLin += 12
		@ nUltLin,005 SAY "Agencia" SIZE 32, 07 OF oPanel2 PIXEL 
		@ nUltLin,065 MSGET oAgencia var cAgencia  SIZE 65, 08 OF oPanel2 PIXEL Valid ;
							If(!lValidou,If(F070VldBco(cBanco,cAgencia,@cConta,.T.,.T.,cAgencia),.T.,oBanco:SetFocus()),.T.) ;
							WHEN ( If(SE1->E1_SITUACA$"27",.F.,.T.) .and. MovBcoBx(cMotBx, .T.))

		nUltLin += 12
		@ nUltLin,005 SAY "Conta" SIZE 28, 07 OF oPanel2 PIXEL 
		@ nUltLin,065 MSGET oConta var cConta  SIZE 65, 08 OF oPanel2 PIXEL Valid ;
							If(!lValidou,If(F070VldBco(cBanco,cAgencia,cConta,.T.,.T.,cAgencia+cConta),.T.,oBanco:SetFocus()),.T.);
							WHEN ( If(SE1->E1_SITUACA$"27",.F.,.T.) .and. MovBcoBx(cMotBx, .T.))

		nUltLin += 12
		dDtRecbAux := dBaixa		
		@ nUltLin,005 SAY "Data Receb." SIZE 39, 07 OF oPanel2 PIXEL
		@ nUltLin,065 MSGET oDtBaixa VAR dBaixa SIZE 65, 08 OF oPanel2 PIXEL HASBUTTON When .F./*F070DtRe() .and. !(AllTrim(SE1->E1_ORIGEM) =="FINI055") .and. lAcessdBaixa*/  /*Valid ;
							( fA070Data(@nTxMoeda,,oDtBaixa,oJuros) .And. If(GetNewPar("MV_SIGAGSP")=="1" , GSPF250() , .t.) .And. ( nOldJuros := nJuros, .T. ).and. If (dBaixa <> dDataBase .and.;
							  SE1->E1_VALOR == nValRec+nPis+nCofins+nCsll+nIrrf,(nIrrf:=FCaIrBxCR(SE1->E1_VALOR),f070TotMes(dBaixa,.T.,,,dBaixa <> dDtRecbAux)), .T. ))*/
		
		nUltLin += 12
		@ nUltLin,005 SAY "Data Credito" SIZE 32, 07 OF oPanel2 PIXEL 
		@ nUltLin,065 MSGET oDtCredito VAR dDtCredito SIZE 65, 08 OF oPanel2 PIXEL HASBUTTON /*Valid (dDtCredito >= dBaixa  .and. Iif(SuperGetMv("MV_BXDTFIN",,"1") == "2", DtMovFin(dDtCredito), .T.) ) .or. GetMv("MV_ANTCRED")*/ When .F.
	
		nUltLin += 12
		@ nUltLin,005 SAY "Hist.Baixa" SIZE 32, 07 OF oPanel2 PIXEL 
		@ nUltLin,065 MSGET cHist070           SIZE 65, 08 OF oPanel2 PIXEL HASBUTTON Picture "@!" VALID CheckSX3("E5_HISTOR") When VisualSX3("E5_HISTOR")

		//////////////////////////
		//Dados da Baixa		
     IF !_cChama == "ALTERAR_MARCADOS"
		nLinha := 10
		@ nLinha,144 SAY "Valor Original " + cDescMoeda SIZE 53, 08 OF oPanel2 PIXEL COLOR CLR_HBLUE
		@ nLinha,204 MSGET SE1->E1_VALOR  SIZE 66, 08 OF oPanel2 PIXEL COLOR CLR_HBLUE When .F. Picture PesqPict("SE1","E1_VALOR") 

		nEstOriginal := nValEstrang-(xMoeda(nJuros+(nCm1+nProRata)+nMulta-nDescont-nOtrga+nAcresc-nDecresc - Iif(lPccBxCr,nPis+nCofins+nCsll,0)-Iif(lIrPjBxCr,nIrrf,0),nMoedaBco,SE1->E1_MOEDA,,,,nTxMoeda)) 

		FA070CORR(nEstOriginal,nTxMoeda)
	
		nLinha +=12
		@ nLinha,144 SAY "- Abatimentos" SIZE 53, 07 OF oPanel2 PIXEL 
		@ nLinha,204 MSGET nTotAbLiq         SIZE 66, 08 OF oPanel2 PIXEL When .F.  Picture PesqPict( "SE1","E1_VALOR" ) 

		nLinha +=12
		@ nLinha,144 SAY  "- Impostos" SIZE 53, 07 OF oPanel2 PIXEL
		@ nLinha,204 MSGET nTotAbImp     SIZE 66, 08 OF oPanel2 PIXEL When .F.  Picture PesqPict( "SE1","E1_VALOR" )      

		nValorLiq :=  (SE1->E1_VALOR - nTotAbLiq - nTotAbImp)
		nLinha +=12
		@ nLinha,144 SAY "Valor Liquido" SIZE 53, 07 OF oPanel2 PIXEL 
		@ nLinha,204 MSGET oValorLiq VAR nValorLiq     SIZE 66, 08 OF oPanel2 PIXEL When .F. Picture PesqPict("SE1","E1_VLCRUZ")		

		nLinha +=12
		@ nLinha,144 SAY "- Decréscimo" SIZE 53, 07 OF oPanel2 PIXEL 
		@ nLinha,204 MSGET nParciais          SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON When .F.  Picture PesqPict( "SE1","E1_VALOR" )  

		nLinha +=12                                                                  
		@ nLinha,144 SAY  "- Pagtos Parciais" SIZE 53, 07 OF oPanel2 PIXEL 
		@ nLinha,204 MSGET if(nDecrescF > 0,nDecrescF,nDecrVlr)  SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON     Picture PesqPict( "SE1","E1_DECRESC" )  When .f. 
                                       

		nLinha +=12                                                                  
		@ nLinha,144 SAY "+ Acrescimo" SIZE 53, 07 OF oPanel2 PIXEL
		@ nLinha,204 MSGET nAcrescF  SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON     Picture PesqPict( "SE1","E1_ACRESC" )  When .F.
		
        nDescont := nValRec
        nValRec := 0

		nLinha +=12
		@ nLinha,144 SAY "- Descontos" SIZE 53, 07 OF oPanel2 PIXEL 
		@ nLinha,204 MSGET oDescont VAR nDescont  SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON When F070DSC() .And. If(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .And. !MovBcobx(cMotBx, .T.), .F., .T.) .And. lAcessDesc Picture PesqPict( "SE1","E1_DESCONT" ) ; 
															Valid Iif( nOldDescont # nDescont, ;
															(  fA070Val(nDescont,nTxMoeda) .and. ;
															nDescont <= xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,nMoedaBco,dBaixa,,nTxMoeda),;
															nOldDescont := nDescont,Fa070DesCI(lTpDesc,lNatApura)),.T.)  
		oDescont:SetEnable( lAcessDesc )
		nOldDescont := nDescont
																	
		nLinha +=12
		@ nLinha,144 SAY "+ Multa" SIZE 53, 07 OF oPanel2 PIXEL 
		@ nLinha,204 MSGET oMulta VAR nMulta  SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON When .F. ; 
															Valid (Iif(nOldMulta # nMulta, (fA070Val(nMulta,nTxMoeda),nOldMulta := nMulta), .T.))
															
		oMulta:SetEnable( lAcessMul )
		nOldMulta := nMulta

		nLinha +=12
 	    nOldJuros := nJuros:= nJurosZero :=0//Sempre 0
		@ nLinha,144 SAY "+ Tx.Permanenc." SIZE 53, 07 OF oPanel2 PIXEL 
		@ nLinha,204 MSGET oJuros VAR nJurosZero  SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON When .F.; 
		   													Valid Iif(nOldJuros # nJuros, (fA070Val(nJuros,nTxMoeda),nOldJuros := nJuros),.T.)		   													 
		oJuros:SetEnable( lAcessJur )
		nOldJuros := nJuros
				
		nLinha +=12
		@ nLinha,144 SAY "Valor Recebido" SIZE 53,07 OF oPanel2 PIXEL COLOR CLR_HBLUE 
		@ nLinha,204 MSGET oValRec VAR nValRec        SIZE 66, 08 OF oPanel2 ;
							PIXEL HASBUTTON COLOR CLR_HBLUE ;
							Valid ( oValRec:Refresh(), nValEstrang := nValRec ) ;
							Picture PesqPict( "SE1","E1_VALOR" ) 
	ENDIF
		
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| iIf(FA070BtOK(),iIf( IIf( MovBcoBx(cMotBx, .T.),F070VldBco(cBanco,cAgencia,cConta,.T.,.F.), .T. ) ;
		        	                                                .and. If(SuperGetMv("MV_BXDTFIN",,"1") == "2",DtMovFin(dBaixa),.T.) .and. 	PcoVldLan("000004","01","FINA070")  ;
		            	                                           ,IIf( ( FindFunction( "UsaSeqCor" ) .And. UsaSeqCor() ), IIf( FA070Diario(), (nOpc1 := 1,oDlg:End()),Nil), (nOpc1 := 1,oDlg:End()) ) ;
		                	                                    ,Nil),Nil)};
		                    		                           ,{||(nOpc1 := 0,oDlg:End())},,) ,IF(!_cChama == "ALTERAR_MARCADOS",oPanel1:Align := CONTROL_ALIGN_TOP,),oPanel2:Align := CONTROL_ALIGN_ALLCLIENT ) CENTERED
   		
	SetKey(VK_F4,bSetKey)
	
	If nOpc1 == 0
	   lRet:=.F.
	   _lsai := .T.
	   Break
	EndIF

	If nOpc1 == 1
       nOldJuros := nJuros:= nJurosZero :=0//Sempre 0
        /*
        IF nValRec > (cAliasAux)->VLRBAI
           U_ITMSG("O valor a ser baixado não pode ser maior que o valor informado na planilha (valor pago pelo cliente): R$ "+ALLTRIM(STR( nValRec,18,8) )+" > "+ALLTRIM(STR( (cAliasAux)->VLRBAI,18,8) ),"Atenção",,1)
           Break
        ENDIF
        */
		If nCM1 > 0
			nJuros += nCM1
		Else
			nDescont -= nCM1
		EndIf
		
		If nProRata > 0
			nJuros += nProRata
		Else
			nDescont -= nProRata
		EndIf
		
		// Verifica se dados bancários estão OK                                   
		If MovBcobx(cMotBx, .T.) .and. !CarregaSA6(@cBanco,@cAgencia,@cConta,.T.,,.T.)
			Break
		Endif

		// Verifica se nao foi alterado o banco quando for tit. em desconto.      
		If ( SE1->E1_SITUACA $ "27" .And.;
			cBanco+cAgencia+cConta!=SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA )
			Help(" ",1,"FINA070BCO")
			Break
		EndIf

		// Verifica se valor da baixa ‚ maior que o valor m ximo a receber        
			IF Str(nValRec,17,2) > Str(Round(xMoeda(SE1->E1_SALDO-nTotAbat + Iif(SE1->E1_JUROS > 0,nMulta,nTotMult),SE1->E1_MOEDA,nMoedaBco,dBaixa,7,nTxMoeda),2)+Round(Iif(Alltrim(SE1->E1_ORIGEM) == "FINA074",0,nJuros+nMulta-nDescont-nOtrga+nDifCambio+nTolerPg+nAcresc-nDecresc),2),17,2)
				Help(" ",1,"ValorMaior")
				Break
			EndIf
				
	
		If nValRec < (nJuros+nAcresc)                                                               
			nValPadrao := nValRec-(nJuros+Iif(SE1->E1_MOEDA<=1,nCM,0)+nMulta-nDescont-nDecresc)	
		Else
			nValPadrao := nValRec-(nJuros+Iif(SE1->E1_MOEDA<=1,nCM,0)+nMulta-nDescont+nAcresc-nDecresc)	
		Endif
	
		// Verifica se saldo estava em outra moeda, caso estiver, converte valor  
		// recebido pela taxa diaria da moeda                                     
		nOpt  := IIF(Str(nValPadrao,14,2)=Str(xMoeda(SE1->E1_SALDO-nTotAbat,SE1->E1_MOEDA,nMoedaBco,dBaixa,,nTxMoeda),14,2),1,2)

	    If Empty( cMotBx )
	    	//cMotBx:= "NORMAL    "///aDescMotBx[1] 	//NORMAL
            cMotBx:= "DESCONTO  "
	    Endif

		// Verifica se data da baixa e valida                                     
		IF (dBaixa < SE1->E1_EMISSAO .OR. dBaixa > dDataBase) .and. !GetMv("MV_ANTCRED")
			Help( " ", 1, "DATAERR" )
			// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
			// dados, senao abandona a baixa.
			Break
		Endif
		
		// Verifica se permite ou nao baixar o titulo com o valor recebido menor  
		// que a soma dos valores de juros, multa e desconto                      
		If !F070VldRec()
			Break
		Endif

		dbSelectArea("SE1")
		IF Empty(dBaixa) .or. (nValRec < 0 ) .or. Empty(cMotBx)
			Help(" ",1,"FA070INV")
			// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
			// dados, senao abandona a baixa.
			Break
		EndIF

      // Aqui neste ponto a variavel nJuros esta somada com o valor de nCM1
      // e da Prorata se esta for positiva, se for negativa
      // a prorata eh somada a nDescont
       
			If nDescont != Round(nMulta+nJuros+xMoeda((SE1->E1_SALDO+SE1->E1_ACRESC-(SE1->E1_DECRESC+nDecrescF+nDecrVlr)),SE1->E1_MOEDA,1,dBaixa,2,nTxMoeda),2) .And.;
				(!(AllTrim(SE1->E1_ORIGEM) $ "S|L|T") .And. AllTrim(cAuxMBx) <> "BOL") 
				If (nTotAbat=0.and.nValRec=0.and.nDescont==0).and.;
					(nValRec=0.and.nTotAbat!=SE1->E1_SALDO .and.nPIS==0.and.nCOFINS==0.and.nCSLL==0.and.;
					nDescont!=Round(nMulta+nJuros+xMoeda(SE1->E1_SALDO-nTotAbat,SE1->E1_MOEDA,1,dBaixa,3,nTxMoeda),2)+nAcresc-nDecresc)
					
					Help(" ",1,"FA070INV")
					// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
					// dados, senao abandona a baixa.
					Break
				Else
					If (nValRec=0.and.nDescont==0).and.;
					(nValRec=0.and.nTotAbat!=SE1->E1_SALDO .and.nPIS==0.and.nCOFINS==0.and.nCSLL==0.and.;
					nDescont!=Round(nMulta+nJuros+xMoeda(SE1->E1_SALDO-nTotAbat,SE1->E1_MOEDA,1,dBaixa,3,nTxMoeda),2)+nAcresc-nDecresc)
					Help(" ",1,"FA070INV")
					Break
					
					EndIf
				EndIf
			EndIF

		If !FA070ValMo()
			Break
		EndIF
 	    nOldJuros := nJuros:=0//Sempre 0

       	IF _cChama == "ALTERAR_MARCADOS"
	       FWMSGRUN( ,{|oproc| lRet:=MFIN27Grv(oproc) } , "Processando..." , "Gravando Dados..." )
		   lRet:=.F.
		   _lsai := .T.
		   BREAK
		ENDIF 

		(cAliasAux)->E5_VALOR  :=nValRec
        (cAliasAux)->E1_DTACRED:=dDtCredito
        (cAliasAux)->E1_DESCONT:=nDescont
        (cAliasAux)->E1_MULTA  :=nMulta
        (cAliasAux)->E1_JUROS  :=nJuros
        (cAliasAux)->E5_MOTBX  :=cMotBx
        (cAliasAux)->E1_PORTADO:=cBanco
        (cAliasAux)->E1_AGEDEP :=cAgencia
        (cAliasAux)->E1_CONTA  :=cConta
        (cAliasAux)->E1_BAIXA  :=dBaixa
        (cAliasAux)->E5_HISTOR :=cHist070
        (cAliasAux)->WKSTATUS  :='A'//Marca aceito de novo para poder altetrar e reprocessar caso tenha dado lMsErroAuto = .T.
        lRet:=.T.
       	IF _cChama <> "ALTERAR" .AND. (_nPos:=ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU+ALLTRIM((cAliasAux)->WKPARCELA) })) # 0
           _aMarcados[_nPos,2]:=.T.
           _aMarcados[_nPos,3]:=ALLTRIM((cAliasAux)->WKPARCELA)+" - "+DTOC((cAliasAux)->VENCREA)
        ENDIF

	ENDIF
	
	_lsai := .T.

End Sequence

If "CX" $ cBanco
	aCaixaFin[1] := cBanco
	aCaixaFin[2] := cAgencia
	aCaixaFin[3] := cConta
Endif

If cAlias != NIL
	dbSelectArea(cAlias)
	dbSetOrder(nOrdem)
	dbGoTo( nReg )
EndIf

RestArea (aArea)

Return lRet


/*
===============================================================================================================================
Programa----------: MFIN27Grv()
Autor-------------: Igor Melgaço
Data da Criacao---: 08/01/2025
Descrição---------: Baixa o titulo
Retorno-----------: .T. OU .F.
===============================================================================================================================
*/
Static function MFIN27Grv(oProc As Object) As Logical
Local lRet := .F. As Logical
Local _nCont := 0 As Numeric
Local _nTotReg := (cAliasAux)->( LASTREC() ) As Numeric
Local _nGravados := 0 As Numeric

(cAliasAux)->(DBGOTOP())

DO WHILE (cAliasAux)->(!EOF())

	_nCont++ 
	oproc:cCaption := ( "Lendo linha " + strzero(_nCont,5) + " de " + strzero(_nTotReg,5) + " / Gravados: "+STRZERO(_nGravados,5) )
	ProcessMessages()
   IF (cAliasAux)->WKSTATUS = "A"
      oMarkBRW:GoTo( (cAliasAux)->( RECNO() ) , .T. )
   ELSE
      (cAliasAux)->(DBSKIP())
      LOOP
   ENDIF
   IF (cAliasAux)->WKSTATUS = "A" .AND. oMarkBRW:IsMark()
      (cAliasAux)->E5_MOTBX  :=cMotBx
      (cAliasAux)->E1_PORTADO:=cBanco
      (cAliasAux)->E1_AGEDEP :=cAgencia
      (cAliasAux)->E1_CONTA  :=cConta
      (cAliasAux)->E1_BAIXA  :=dBaixa
      (cAliasAux)->E1_DTACRED:=dDtCredito
      (cAliasAux)->E5_HISTOR :=cHist070
      (cAliasAux)->WKSTATUS  :='A'//Marca aceito de novo para poder altetrar e reprocessar caso tenha dado lMsErroAuto = .T.
      lRet:=.T.
      IF (_nPos:=ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU+ALLTRIM((cAliasAux)->WKPARCELA) })) # 0
         _aMarcados[_nPos,2]:=.T.
         _aMarcados[_nPos,3]:=ALLTRIM((cAliasAux)->WKPARCELA)+" - "+DTOC((cAliasAux)->VENCREA)
      ENDIF
	  _nGravados++
   ENDIF

   (cAliasAux)->(DBSKIP())
ENDDO

RETURN lRet

/*
===============================================================================================================================
Programa----------: MFIN27Baixa()
Autor-------------: Igor Melgaço
Data da Criacao---: 08/01/2025
Descrição---------: Baixa o titulo
Retorno-----------: .T. OU .F.
===============================================================================================================================
*/
Static function MFIN27Baixa() As Logical

LOCAL aBaixa:={}
IF EMPTY((cAliasAux)->E5_MOTBX  ) .OR.;
   EMPTY((cAliasAux)->E1_BAIXA  ) .OR.; 
   EMPTY((cAliasAux)->E1_DTACRED) 
   _cErro:="Erro: [Motivo ou banco ou agencia ou conta ou datas não preenchidos]" 
   RETURN .F.
ENDIF

SE1->(DBGOTO( (cAliasAux)->REGSE1) )

AADD( aBaixa, { "E1_PREFIXO"  , SE1->E1_PREFIXO        , Nil } )
AADD( aBaixa, { "E1_NUM"      , SE1->E1_NUM            , Nil } )
AADD( aBaixa, { "E1_PARCELA"  , SE1->E1_PARCELA        , Nil } )
AADD( aBaixa, { "E1_TIPO"     , SE1->E1_TIPO           , Nil } )
AADD( aBaixa, { "E1_CLIENTE"  , SE1->E1_CLIENTE        , Nil } )
AADD( aBaixa, { "E1_LOJA"     , SE1->E1_LOJA           , Nil } )
AADD( aBaixa, { "AUTMOTBX"    , "DCT" /*(cAliasAux)->E5_MOTBX*/  , Nil } )
//AADD( aBaixa, { "AUTBANCO"    , (cAliasAux)->E1_PORTADO, Nil } )
//AADD( aBaixa, { "AUTAGENCIA"  , (cAliasAux)->E1_AGEDEP , Nil } )
//AADD( aBaixa, { "AUTCONTA"    , (cAliasAux)->E1_CONTA  , Nil } )
AADD( aBaixa, { "AUTDTBAIXA"  , (cAliasAux)->E1_BAIXA  , Nil } )
AADD( aBaixa, { "AUTDTCREDITO", (cAliasAux)->E1_DTACRED, Nil } )
AADD( aBaixa, { "AUTHIST"     , (cAliasAux)->E5_HISTOR , Nil } )
AADD( aBaixa, { "AUTDESCONT"  , (cAliasAux)->DESCONT   , Nil } )
AADD( aBaixa, { "AUTMULTA"    , 0                      , Nil } )
AADD( aBaixa, { "AUTJUROS"    , 0                      , Nil ,.T.} )//Foi passado o 4 parametro para considerar zero no juros
AADD( aBaixa, { "AUTVALREC"   , 0                      , Nil } )
AADD( aBaixa, { "AUTOUTGAS"   , 0                      , Nil } )
AADD( aBaixa, { "AUTVLRPG"    , 0                      , Nil } )
AADD( aBaixa, { "AUTVLRME"    , 0                      , Nil } )
AADD( aBaixa, { "AUTCHEQUE"   , ""                     , Nil } )

BEGIN TRANSACTION
	  
    lMsErroAuto := .F.
    MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3)//3 = Baixa de titulo
	If lMsErroAuto
	   DisarmTransaction()
	   _cErro:="Erro: ["+ALLTRIM(MostraErro())+"]" 
	EndIf

END TRANSACTION

RETURN !lMsErroAuto

/*
===============================================================================================================================
Programa----------: F070VLDBCO()
Autor-------------: Igor Melgaço
Data da Criacao---: 08/01/2025
Descrição---------: Valida o cadastro do banco + agencia + conta (função copiada do FINA070.PRX antigo)
Retorno-----------: .T. OU .F.
===============================================================================================================================*/
STATIC Function F070VldBco(cBco As Character,cAg As Character,cCnta As Character,lVldCnta As Logical,lHelp As Logical,cChaveBco As Character,lTelaLote As Logical) As Logical
Local aArea		:= GetArea() As Array
Local lRet 		:= .T. As Logical

DEFAULT lVldCnta  := .T. 
DEFAULT cChaveBco := ""  //Chave para considerar a agencia e/ou conta, quando necessario
DEFAULT lHelp := .F. 
DEFAULT lTelaLote := .F. 

If !lTelaLote 
	If Empty(cChaveBco) .and. !oBanco:lModiFied 
		cChaveBco:= cAg + cCnta
	Endif 
EndIf

DbSelectArea("SA6")
SA6->(dbSetOrder(1))
If Empty(cBco) .OR. Empty(cAg) .OR. (lVldCnta .And. Empty(cCnta)) .OR. ;
	!SA6->(dbSeek(xFilial("SA6") + cBco + cAg + IIf(lVldCnta,cCnta,"")))
	If (!SA6->(Found()) .OR. SA6->A6_COD # cBco) .OR. Empty(cAg) .OR. (lVldCnta .And. Empty(cCnta))
		If SA6->(dbSeek(xFilial("SA6") + cBco + cChaveBco)) 
			cAg := SA6->A6_AGENCIA
			cCnta := SA6->A6_NUMCON
		Else
			If lHelp
				Help(" ",1,"FA100BCO")
				lValidou := .T.
			EndIf
			lRet := .F.                                         
		Endif
	Else
		If lHelp
			Help(" ",1,"FA100BCO")
			lValidou := .T.
		EndIf
		lRet := .F.                                         
	Endif
ElseIf !Empty(cBco) .AND. !Empty(cAg) .AND. (!lVldCnta .OR. Empty(cCnta))	//Conta
	If SA6->(Found()) .AND. SA6->(A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON) == xFilial("SA6")+cBco+cAg+cCnta
		If !Empty(SA6->A6_NUMCON)
			cCnta := SA6->A6_NUMCON
		Else
			If lHelp
				Help(" ",1,"FA100BCO")
				lValidou := .T.
			EndIf
			lRet := .F.		
		Endif
	Else
		If lHelp
			Help(" ",1,"FA100BCO")
			lValidou := .T.
		EndIf
		lRet := .F.		
	Endif
EndIf

// Verifica se o banco selecionado pode ser usado para baixa do titulo
If lRet .AND. !lTelaLote .and. !Empty( cCnta ) .AND. FXMultSld()
	lRet := FXVldBxBco( cBco, cAg, cCnta, SE1->E1_NATUREZ, SE1->E1_MOEDA )
	If !lRet
		lValidou := .T.
	EndIf
EndIf

RestArea(aArea)

Return (lRet)
/*
===============================================================================================================================
Programa----------: MFIN27Todos
Autor-------------: Igor Melgaço
Data da Criacao---: 08/01/2025
Descrição---------: Mostra totais
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MFIN27Todos(_lMarca As Logical)

(cAliasAux)->( DBGoTop() )

DO While (cAliasAux)->( !EOF() )
   
   IF (cAliasAux)->WKSTATUS $ 'A,E'
      oMarkBRW:GoTo( (cAliasAux)->( RECNO() ) , .T. )
   ELSE
      (cAliasAux)->(DBSKIP())
      LOOP
   ENDIF
   IF _lMarca //MARCA TODOS
  	  
	   If (cAliasAux)->WKSTATUS $ 'A,E'
  
	      IF (_nPos:=ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU })) # 0
             IF _aMarcados[_nPos,2]
                //U_ITMSG("Titulo ["+(cAliasAux)->TITU+"] já marcado na Parcela - Vencimento: "+_aMarcados[_nPos,3],"Atenção",,1)
				(cAliasAux)->ERRO :="Erro ao marcar o Titulo ["+(cAliasAux)->TITU+"] já marcado na Parcela - Vencimento: "+_aMarcados[_nPos,3]
                (cAliasAux)->( DbSkip() )
	  	  	  LOOP
             ENDIF
	      ENDIF
       
	      (oMarkBRW:Alias())->MARCA := oMarkBRW:Mark()
          
	      IF (_nPos:=ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU })) # 0
             _aMarcados[_nPos,2]:=.T.
	         _aMarcados[_nPos,3]:=ALLTRIM((cAliasAux)->WKPARCELA)+" - "+DTOC((cAliasAux)->VENCREA)
	      ENDIF
  
	   ENDIF	
    
	ELSEIF oMarkBRW:IsMark() //DESMARCA TODOS

      (oMarkBRW:Alias())->MARCA := ""
      IF (_nPos:=ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU })) # 0
         _aMarcados[_nPos,2]:=.F.//A colocação do .T. esta dentro da função MFIN27Tela("SE1",nReg,4)
         _aMarcados[_nPos,3]:="" //O preenchimento esta dentro da função MFIN27Tela("SE1",nReg,4)
      ENDIF

	ENDIF	
	
	(cAliasAux)->( DbSkip() )
	
EndDo

(cAliasAux)->( DBGoTop() )          

oMarkBRW:GoTop()
oMarkBRW:Refresh()

RETURN
