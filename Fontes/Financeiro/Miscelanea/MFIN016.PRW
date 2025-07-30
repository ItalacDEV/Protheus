/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges | 10/10/2019 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25. 
 -------------------------------------------------------------------------------------------------------------------------------
 Jonathan     | 01/10/2020 | Chamado 33566. Ajuste na compensação da DTC com a NF. 
=-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer| 23/05/2023 | Chamado 43841. Ajuste para efetuar a baixa da NF com a NCC a maior com variação até 0,02. 
==============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include	"Protheus.Ch"
#Include	"FWMVCDef.Ch"
#Include	"topconn.Ch"
/*
===============================================================================================================================
Programa----------: MFIN016
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 28/05/2019
===============================================================================================================================
Descrição---------: Rotina de Leitura e compensacao titulos - Chamado 29364
===============================================================================================================================
Retorno-----------: Nenhum  
===============================================================================================================================
*/
User Function MFIN016()

PRIVATE MV_PAR01:=Space(200)
PRIVATE _cSalva_MV_PAR01 := MV_PAR01
PRIVATE  cMarca :=GetMark()

DO WHILE .T.
   lSair:=.T.

   fwmsgrun( ,{|oproc| lSair:=MFIN016INI(oproc) } , "Processando..." , "Iniciando o processamento..." )

   IF lSair
      EXIT
   ENDIF
ENDDO

SET DATE FORMAT TO "DD/MM/YY"
	
Return()

/*
===============================================================================================================================
Programa----------: MFIN016INI
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 19/05/2017
===============================================================================================================================
Descrição---------: Rotina de montagem da tela de processamento
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: .T. OU .F.
===============================================================================================================================
*/
Static Function MFIN016INI(oproc)

Local _aParAux	:= {}
Local _aParRet	:= {}
Local _aCpos	:= MFIN016CPS()
Local _nreg		:= 0
Local _adados	:= {}
Local _ni		:= 0
Local _carq		:= ""
Local _otemp    := nil  , nI
Private cAliasAux	:= GetNextAlias()

MV_PAR01 := _cSalva_MV_PAR01
 
aAdd( _aParAux , { 1 , "Selecione arquivo:"		, MV_PAR01, "@!"		, ""	, "DIR"		, "" , 100 , .F. } ) 	//| 01 |

For nI := 1 To Len( _aParAux )
	aAdd( _aParRet , _aParAux[nI][03] )
Next nI

IF !ParamBox( _aParAux , "Leitura e compensacao de titulos DCT" , @_aParRet )
	Return .T.
EndIf

//Grava Log de execução da rotina
U_ITLOGACS( "MFIN016" )

_cSalva_MV_PAR01 := MV_PAR01

oproc:cCaption := ("Abrindo arquivo...")
ProcessMessages()

IF (upper(right(alltrim(MV_PAR01),4))) == ".CSV" 

	_carq := ALLTRIM(MV_PAR01)

	If FT_FUSE(_carq) == -1
	
		u_itmsg("1-Falha ao abrir o arquivo: "+_carq,"Erro",,1)
		
		Return .F.
		
	Endif 
	          
  	FT_FGOTOP() //POSICIONA NO TOPO DO ARQUIVO 
  	_cDados := FT_FREADLN()

  	If !"TITULO" $ UPPER(alltrim(_cDados)) .OR. !"CLIENTE" $ UPPER(alltrim(_cDados))

	    U_ITMSG("O arquivo "+_carq+" informado para relizar a importação não tem o layout padrão.",;
            "Arquivo com formato inválido",;
			"O CSV deve ter as colunas [ Titulo;Cliente ] e o mesmo deve ser salvo "+;
		    "no Excel no formato [ CSV (separado por virgulas) ] e "+;
		    "no LibreOffice Calc com Demilitador de campo Ponto e Virgula e sem delimitador de texto.",1)
	    Return .F.

  	Endif

	//Fecha arquivo e prepara parâmetro com arquivo convertido
	FT_FUSE()

ELSE

	U_ITMSG("O arquivo informado: "+Alltrim(MV_PAR01)+" não tem extenção [ .CSV ] ",;
            "Arquivo inválido",;
		    "Favor informar uma arquivo no formato [ .CSV ].")
	Return .F.

EndIf


If .T.

	If FT_FUSE(_carq) == -1
		
		u_itmsg("2-Falha ao abrir o arquivo: "+_carq,"Erro",,1)
		Return .F.

	EndIf
	
	FT_FGOTOP() //POSICIONA NO TOPO DO ARQUIVO
	
	_nReg:= FT_FLASTREC()

	ProcRegua(_nReg)
	
	FT_FGOTOP() //POSICIONA NO TOPO DO ARQUIVO
	
	If _nReg == 0 //O arquivo informado nao possui nenhuma linha de dados
		
		U_ITMSG("O arquivo informado para relizar a importação não possui dados.",;
                "Arquivo inválido",;
				"Favor verificar se o arquivo informado esta no formato correto.")
		Return .F.
	
	EndIf

	
	_adados := MFIN016L(_nreg,oproc) //Faz leitura dos dados
	

	If len(_adados) <= 0

		u_itmsg( "Não foram encontrados registros válidos no arquivo!" , "Atenção!",,1 )
		Return .F.
	
	EndIf
	
Endif

//================================================================================
// Verifica se ja existe um arquivo com mesmo nome, SE SIM DELETA 
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

_otemp:AddIndex( "01", {"FILIAL","TITU","CLIENTE","WKPARCELA"} )
_otemp:Create()

_aMarcados:={}

FOR  _ni := 1 TO len(_adados)
	
	oproc:cCaption := ("Processando: "+ STRZERO( _ni , 6 ) +" de "+ STRZERO( LEN(_adados) , 6 ) +" Registros..." )
	ProcessMessages()
    
    IF _adados[_ni][12] # 0 // 'DCT'
	   SE1->(DBGOTO( _adados[_ni][12] ))//POSICIONA NO SE1
	   IF (cAliasAux)->( DBSEEK(SE1->E1_FILIAL+SE1->E1_NUM+SE1->E1_CLIENTE+SE1->E1_PARCELA) )
         (cAliasAux)->WKPARCDCT := SE1->E1_PARCELA
 	      (cAliasAux)->SALDO	  := SE1->E1_SALDO
	      (cAliasAux)->E1_TIPO   := SE1->E1_TIPO
	      (cAliasAux)->E1_PREFIXO:= SE1->E1_PREFIXO
     	   (cAliasAux)->LOJA 	  := SE1->E1_LOJA
         (cAliasAux)->REGSEDCT  := _adados[_ni][12]//12 - Recno SE1 DCT
	      IF (cAliasAux)->FILIAL <> cFilant
 	         (cAliasAux)->WKSTATUS:= "R"
	         (cAliasAux)->ERRO:=" [Titulo não pertence a filial atual]"//ALLTRIM((cAliasAux)->ERRO) + 
	      ELSEIF (cAliasAux)->SALDO <= 0
 	         (cAliasAux)->WKSTATUS:= "R"
	         (cAliasAux)->ERRO    := ALLTRIM((cAliasAux)->ERRO) + " [Titulo DCT sem Saldo]"
	      ELSEIF (cAliasAux)->SALDO > ((cAliasAux)->SALDONF+0.02)
 	         (cAliasAux)->WKSTATUS:= "R"
	         (cAliasAux)->ERRO  := ALLTRIM((cAliasAux)->ERRO) + " [Saldo do DCT maior que o saldo do NF]"
         ELSEIF EMPTY((cAliasAux)->ERRO )
             IF (_nPos:=ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU+(cAliasAux)->CLIENTE+(cAliasAux)->WKPARCELA  })) # 0
                IF (cAliasAux)->LOJANF == (cAliasAux)->LOJA 
                   _aMarcados[_nPos,2]:=.T.
                   (cAliasAux)->MARCA := cMarca
	            ELSE
 	               (cAliasAux)->WKSTATUS:= "E"
	               (cAliasAux)->ERRO  := ALLTRIM((cAliasAux)->ERRO) + " [Titulos com Lojas diferentes]"
	            ENDIF  
             ENDIF
         ENDIF
	      (cAliasAux)->ERRO    := ALLTRIM((cAliasAux)->ERRO)//Para tirar os espacos da frente
         LOOP//********************************************************************/
	   ELSE
	      (cAliasAux)->( DBAPPEND() ) // Senão achou a NF em aberto mostra a dct mesmo assim			
	   ENDIF
	ELSE
	   (cAliasAux)->( DBAPPEND() )
	ENDIF

   (cAliasAux)->FILIAL	 := _adados[_ni][01]
	(cAliasAux)->TITU		 := _adados[_ni][02]
	(cAliasAux)->CLIENTE	 := _adados[_ni][03]
   (cAliasAux)->WKPARCELA:= _adados[_ni][04]
	(cAliasAux)->WKSTATUS := _adados[_ni][05]
  	(cAliasAux)->ERRO   	 := _adados[_ni][06]
	
	IF _adados[_ni][11] # 0 .OR. _adados[_ni][12] # 0 

	  IF _adados[_ni][11] # 0 //NF
	     SE1->(DBGOTO( _adados[_ni][11] ))//POSICIONA NO SE1
 	     (cAliasAux)->SALDONF   := SE1->E1_SALDO
	     (cAliasAux)->E1_TIPONF := SE1->E1_TIPO
	     (cAliasAux)->E1_PREFINF:= SE1->E1_PREFIXO
     	  (cAliasAux)->LOJANF	 := SE1->E1_LOJA
        (cAliasAux)->REGSENF   := _adados[_ni][11]//11 - Recno SE1 NF
        IF (cAliasAux)->SALDONF <= 0
 	        (cAliasAux)->WKSTATUS:= "R"
	        (cAliasAux)->ERRO    := ALLTRIM((cAliasAux)->ERRO) + " [Titulo NF sem Saldo]"
		  ENDIF	
	  
	  ELSEIF _adados[_ni][12] # 0 // 'DCT'
	     SE1->(DBGOTO( _adados[_ni][12] ))//POSICIONA NO SE1
        (cAliasAux)->WKPARCDCT := SE1->E1_PARCELA
 	     (cAliasAux)->SALDO	    := SE1->E1_SALDO
	     (cAliasAux)->E1_TIPO   := SE1->E1_TIPO
	     (cAliasAux)->E1_PREFIXO:= SE1->E1_PREFIXO
     	  (cAliasAux)->LOJA 		 := SE1->E1_LOJA
        (cAliasAux)->REGSEDCT  := _adados[_ni][12]//12 - Recno SE1 DCT
	     IF (cAliasAux)->SALDO <= 0
 	        (cAliasAux)->WKSTATUS:= "R"
	        (cAliasAux)->ERRO    := ALLTRIM((cAliasAux)->ERRO) + " [Titulo DCT sem Saldo]"
	     ENDIF
	  ENDIF
	ENDIF   
	IF !EMPTY((cAliasAux)->FILIAL) .AND. (cAliasAux)->FILIAL <> cFilant
      (cAliasAux)->WKSTATUS:= "R"
      (cAliasAux)->ERRO:="[Titulo não pertence a filial atual]"
   ENDIF
   (cAliasAux)->ERRO    := ALLTRIM((cAliasAux)->ERRO)//Para tirar os espacos da frente	   

	IF ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU+(cAliasAux)->CLIENTE+(cAliasAux)->WKPARCELA }) = 0
       AADD(_aMarcados,{(cAliasAux)->FILIAL+(cAliasAux)->TITU+(cAliasAux)->CLIENTE+(cAliasAux)->WKPARCELA ,.F., (cAliasAux)->LOJANF})
	ENDIF
 
NEXT

cEmpAnt:=cEmpAnt
_lAtivaMensagem:=.T.
MFIN16Tela(cAliasAux)
(cAliasAux)->( DBCloseArea() )

Return .F.
/*
===============================================================================================================================
Programa----------: MFIN016L
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 19/05/2017
===============================================================================================================================
Descrição---------: Faz a leitura de dados no layout do Atacadao
===============================================================================================================================
Parametros--------: _nreg - número de linhas do arquivo
				    oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: _adados - array com dados carregados do arquivo
===============================================================================================================================
*/

Static function MFIN016L(_nreg,oproc)

Local _nCont 	:= 0
Local _cdados	:= ""
Local _alinha	:= {}
Local _adados 	:= {}
Local _nColTit  := 1
Local _nColCli  := 2
Local _aTiraDupl:= {}


FT_FGOTOP() //POSICIONA NO TOPO DO ARQUIVO
FT_FSKIP()

DO While !FT_FEOF()  //FACA ENQUANTO NAO FOR FIM DE ARQUIVO
	
	_nCont++ 
	oproc:cCaption := ( "Lendo linha " + strzero(_nCont,5) + " de " + strzero(_nreg,5) + "." )
	ProcessMessages()
			
	_cDados := ALLTRIM(FT_FREADLN())
	_aLinha := StrTokArr(_cDados,";")
	
	//Verifica se é final de arquivo
	If alltrim(_cdados) = ';' .and. _nCont > 5
		Exit
	Endif 	
	
	//Verifica se é linha válida
	If LEN(_aLinha) < 2	
		FT_FSKIP()
		Loop		
	Endif

	_cE1_NUM    :=STRZERO(VAL(_alinha[_nColTit]),LEN(SE1->E1_NUM))
	_cE1_CLIENTE:=STRZERO(VAL(_alinha[_nColCli]),LEN(SE1->E1_CLIENTE))
   IF LEN(_alinha) > 2
      _cParcela:=STRZERO(VAL(_alinha[3]),LEN(SE1->E1_PARCELA))
   ELSE
      _cParcela:=SPACE(LEN(SE1->E1_PARCELA))
   ENDIF
	IF ASCAN(_aTiraDupl,_cE1_NUM+_cE1_CLIENTE+_cParcela) = 0
	   AADD(_aTiraDupl,_cE1_NUM+_cE1_CLIENTE+_cParcela)
	ELSE
	   FT_FSKIP()
	   LOOP//IGNORA CHAVE DUPLICADAS
	ENDIF
   
 	_cquery := " SELECT  R_E_C_N_O_ REC_SE1 "
	_cquery += " FROM " +RETSQLNAME("SE1") + " SE1 WHERE D_E_L_E_T_ <> '*' "
	_cquery += " AND (    (E1_TIPO    = 'NF'                      )   "// AND E1_SALDO > 0 
	_cquery += "       OR (E1_PREFIXO = 'DCT' AND E1_TIPO  = 'NCC') ) "
	_cquery += " AND E1_NUM     = '" + _cE1_NUM + "' "
	_cquery += " AND E1_CLIENTE = '" + _cE1_CLIENTE+"' "
// IF !EMPTY(val(_cParcela))
	_cquery += " AND E1_PARCELA = '" + _cParcela + "'"
//	ENDIF
	_cquery += " ORDER BY E1_FILIAL, E1_NUM, E1_CLIENTE, E1_LOJA, E1_PARCELA ,E1_TIPO DESC "
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cquery) , "SE1T" , .T. , .F. )

	_nTotTit:=0
	COUNT TO _nTotTit
	
    _cErro:=""
    _cStatus:="A"//WKSTATUS
    _nREGSENF:= 0
    _nREGSEDCT:= 0
    SE1T->(DBGOTOP())

	DO WHILE !SE1T->(Eof()) .OR. _nTotTit = 0

  	   IF _nTotTit > 0
         SE1->(DBGOTO(SE1T->REC_SE1))
	   ELSE 
	      SE1->(DBGOBOTTOM())    
		   SE1->(DBSKIP())
	   ENDIF  
  	   IF _nTotTit <= 1
  	      IF _nTotTit = 1
            IF SE1->E1_TIPO == 'NF '
                _cErro:="[Titulo DCT correspondente não localizada] "
			   ELSE	
                _cErro:="[Titulo NF correspondente não localizada] "
			   ENDIF
		   ELSE	 
            IF !EMPTY(val(_cParcela))
               _cErro:="[Nenhum Titulo encontrado para esse Cliente + parcela] "
				ELSE
               _cErro:="[Nenhum Titulo encontrado para esse Cliente ou titulo possui parcelas] "
				ENDIF	
		   ENDIF
         _cStatus:='R'
	   ENDIF	  

       _nREGSENF := 0
       _nREGSEDCT:= 0
       IF SE1->E1_TIPO == 'NF '
	      _nREGSENF := SE1T->REC_SE1
       ELSEIF SE1->E1_TIPO == 'NCC' 
	      _nREGSEDCT:= SE1T->REC_SE1
	   ENDIF	  	  

	   AADD(_adados,{;
					 SE1->E1_FILIAL ,;//01 - Filial Italac
		          _cE1_NUM          ,;//02 - Num titulo
					 _cE1_CLIENTE   ,;//03 - Codigo do cliente
					 _cParcela      ,;//04 - Parcela do arquivo
					 _cStatus       ,;//05 - WKSTATUS 
					 _cErro         ,;//06 - Erro 
					 SE1->E1_LOJA	,;//07 - Loja do cliente
					 SE1->E1_TIPO   ,;//08 - E1_TIPO
					 SE1->E1_PREFIXO,;//09 - Prefixo
					 SE1->E1_SALDO  ,;//10 - Saldo
					 _nREGSENF      ,;//11 - Recno SE1 NF
					 _nREGSEDCT     })//12 - Recno SE1 DCT
	    
  	   IF _nTotTit = 0
  	      EXIT
  	   ENDIF

       _cErro:=""
	
	   SE1T->( DBSKIP() )	    

	ENDDO
	SE1T->( Dbclosearea() )
	
	FT_FSKIP()
	
Enddo
	
Return _adados
/*
===============================================================================================================================
Programa----------: MFIN016CNS
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 19/05/2017
===============================================================================================================================
Descrição---------: Rotina de consulta do cadastro completo do Cliente
===============================================================================================================================
Parametros--------: _cChama: da onde chama
===============================================================================================================================
Retorno-----------: .T. OU .F.
===============================================================================================================================
*/

User Function MFIN016R(_cChama)
LOCAL lRet:=.T.
LOCAL nReg:=0

If _cChama == "MARCARALL" .OR. _cChama == "DESMARCARALL"  .OR. _cChama == "INVERTEMARCACAO"
   
   _lAtivaMensagem:=.F.
   (cAliasAux)->( DBGoTop() )
   DO WHILE (cAliasAux)->(!EOF())
   	
      IF (cAliasAux)->WKSTATUS $ 'A,E'
         If _cChama == "MARCARALL" 
	        (cAliasAux)->MARCA:= cMarca
		 ELSEIF _cChama == "DESMARCARALL"
	        (cAliasAux)->MARCA:= ""
		 ELSE//INVERTEMARCACAO
	        (cAliasAux)->MARCA:= IF(EMPTY((cAliasAux)->MARCA),cMarca,"")
		 ENDIF	
         IF (_nPos:=ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU+(cAliasAux)->CLIENTE+(cAliasAux)->WKPARCELA  })) # 0
            _aMarcados[_nPos,2]:=.T.
            _aMarcados[_nPos,3]:=(cAliasAux)->LOJANF
         ENDIF
	  ENDIF	
   	  (cAliasAux)->( DBSKIP() )
   
   ENDDO
   (cAliasAux)->( DBGoTop() )
   _lAtivaMensagem:=.T.
   RETURN .T.
ENDIF

IF (cAliasAux)->REGSENF = 0 .AND. (_cChama == "VISUALNF" .OR. _cChama <> "VISUALDCT" )
    U_ITMSG("Titulo NF não encontrado","Atenção",,1)
   RETURN .F.
ENDIF
IF (cAliasAux)->REGSEDCT = 0  .AND. (_cChama == "VISUALDCT" .OR. _cChama <> "VISUALNF" )
    U_ITMSG("Titulo DCT não encontrado","Atenção",,1)
   RETURN .F.
ENDIF

If "VISUAL" $_cChama 
   
   If _cChama == "VISUALNF"
      cCadastro := "Titulo NF"
      SE1->( DBGoTo( (cAliasAux)->REGSENF ) )
      nReg:=(cAliasAux)->REGSENF
   ELSEIf _cChama == "VISUALDCT"
      cCadastro := "Titulo DCT"
      SE1->( DBGoTo( (cAliasAux)->REGSEDCT ) )
      nReg:=(cAliasAux)->REGSEDCT
   ENDIF

   DBSelectArea("SE1")
   AxVisual("SE1",nReg,2)
   RETURN .T.
ENDIF

IF (cAliasAux)->WKSTATUS = 'P'"
   U_ITMSG("Titulo já processado com sucesso","Atenção",,1)
   RETURN .F.
ENDIF

IF (cAliasAux)->WKSTATUS = 'R'"
   U_ITMSG("Titulo rejeitado na leitura do arquivo.","Atenção",,1)
   RETURN .F.
ENDIF

If _cChama = "MARCAR"

   IF EMPTY((cAliasAux)->MARCA) 
	  
	  IF (_nPos:=ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU+(cAliasAux)->CLIENTE+(cAliasAux)->WKPARCELA  })) # 0
         IF _aMarcados[_nPos,2] .AND. _aMarcados[_nPos,3] <> (cAliasAux)->LOJA
            IF _lAtivaMensagem
               U_ITMSG("Titulo ["+(cAliasAux)->TITU+"] já marcado na Loja: "+_aMarcados[_nPos,3],"Atenção",,1)
			ENDIF   
            RETURN .F.
         ENDIF
	  ENDIF

      IF (cAliasAux)->SALDO <= 0
         IF _lAtivaMensagem
            U_ITMSG("Saldo da DCT zerado","Atenção",,1)
		ENDIF	
         RETURN .F.
      ENDIF

      IF (cAliasAux)->SALDO > ((cAliasAux)->SALDONF+0.02)
         IF _lAtivaMensagem
            U_ITMSG("Saldo do DCT maior que o saldo do NF + 0.02","Atenção",,1)
		 ENDIF  
         RETURN .F.
      ENDIF

      lRet:=.T.
      IF (_nPos:=ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU+(cAliasAux)->CLIENTE+(cAliasAux)->WKPARCELA })) # 0
         _aMarcados[_nPos,2]:=.T.
         _aMarcados[_nPos,3]:=(cAliasAux)->LOJANF
      ENDIF
      (cAliasAux)->WKSTATUS:='A'//Marca aceito de novo para poder altetrar e reprocessar caso tenha dado lMsErroAuto = .T.
	  (cAliasAux)->MARCA   := cMarca

   Else
     
	  (cAliasAux)->MARCA   := ""
      IF (_nPos:=ASCAN(_aMarcados,{|T| T[1]==(cAliasAux)->FILIAL+(cAliasAux)->TITU+(cAliasAux)->CLIENTE })) # 0
         _aMarcados[_nPos,2]:=.F.
         _aMarcados[_nPos,3]:="" 
      ENDIF
   
   ENDIF

ENDIF

DBSelectArea(cAliasAux)//Tem volta para o alias do browse pq senão dá erro

Return lRet

/*
===============================================================================================================================
Programa----------: MFIN016CPS
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 19/05/2017
===============================================================================================================================
Descrição---------: Define a criação de campos para exibição da análise
===============================================================================================================================
Retorno-----------: aRet - Campos que serão criados e exibidos na tela
===============================================================================================================================
*/
Static Function MFIN016CPS()

Local _aCpos := {}

aAdd( _aCpos , { "WKSTATUS"	    , "C" , 01, 0 } )
aAdd( _aCpos , { "MARCA"		, "C" , 02, 0 } )
AAdd( _aCpos , { "FILIAL"		, "C" , TamSX3("A1_FILIAL")[01]		, 0 } )
AAdd( _aCpos , { "CLIENTE"		, "C" , TamSX3("A1_COD")[01]		, 0 } )
AAdd( _aCpos , { "LOJA"			, "C" , TamSX3("A1_LOJA")[01]		, 0 } )
AAdd( _aCpos , { "TITU"			, "C" , 09, 0 } )
AAdd( _aCpos , { "WKPARCELA"	, "C" , 03, 0 } )
AAdd( _aCpos , { "WKPARCDCT"	, "C" , 03, 0 } )
AAdd( _aCpos , { "SALDO"  		, "N" , 18, 8 } )
AAdd( _aCpos , { "REGSENF"		, "N" , 18, 0 } )
AAdd( _aCpos , { "REGSEDCT"		, "N" , 18, 0 } )
AAdd( _aCpos , { "ERRO"	  	    , "C" , 150, 0 } )
AAdd( _aCpos , { "E1_TIPO" 	    , "C" , LEN(SE1->E1_TIPO), 0 } )
AAdd( _aCpos , { "E1_PREFIXO" 	, "C" , LEN(SE1->E1_PREFIXO), 0 } )
AAdd( _aCpos , { "E1_TIPONF"    , "C" , LEN(SE1->E1_TIPO), 0 } )
AAdd( _aCpos , { "E1_PREFINF"   , "C" , LEN(SE1->E1_PREFIXO), 0 } )
AAdd( _aCpos , { "SALDONF"  	, "N" , 18, 8 } )
AAdd( _aCpos , { "LOJANF"			, "C" , TamSX3("A1_LOJA")[01]		, 0 } )


Return( _aCpos )

/*
===============================================================================================================================
Programa----------: MFIN016B
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 19/05/2017
===============================================================================================================================
Descrição---------: Processa o o ajuste de vencimentos dos titulos marcados
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: NIL
===============================================================================================================================
*/
User Function MFIN016B(oproc)

Local _nRegAtu	:= 0
Local _cTotReg	:= ALLTRIM(STR((cAliasAux)->( LASTREC() )))
Local _nTamTot	:= LEN(_cTotReg)
Local _nRegSel	:= 0
Local _nRegErro	:= 0

(cAliasAux)->( DBGoTop() )

DO While (cAliasAux)->( !EOF() )

	_nRegAtu++
	oproc:cCaption := ("Processando: "+ Str(_nRegAtu,_nTamTot) +" de "+ _cTotReg+" / "+Str(_nRegSel,_nTamTot)+" Compensandos" )
	ProcessMessages()
	
  	If (cAliasAux)->WKSTATUS = 'A' .AND. !EMPTY((cAliasAux)->MARCA)
	
	   _cErro:=""
	   IF MFIN13Compensar((cAliasAux)->REGSENF ,(cAliasAux)->REGSEDCT)//COMPENSAR SE1
	      (cAliasAux)->WKSTATUS:='P'
	      (cAliasAux)->ERRO  :="Titulo compensado"
	      _nRegSel++
	   ELSE
	      _nRegErro++
	      (cAliasAux)->WKSTATUS:='E'
	      (cAliasAux)->ERRO  :=_cErro
	   ENDIF	
       (cAliasAux)->MARCA := ""//Desmarca Sempre

	ENDIF	
	
	(cAliasAux)->( DbSkip() )
	
EndDo

(cAliasAux)->( DBGoTop() )

_cMen:=ALLTRIM(STR(_nRegAtu ))+" registro(s) processado(s)."+CHR(13)+CHR(10)
_cMen+=ALLTRIM(STR(_nRegSel ))+" registro(s) Compensando(s) com sucesso."+CHR(13)+CHR(10)
_cMen+=ALLTRIM(STR(_nRegErro))+" registro(s) com erro."

U_ITMSG(_cMen,"Concluído!",,2)

Return()

/*
===============================================================================================================================
Programa----------: MFIN13Compensar()
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 29/05/2017
===============================================================================================================================
Descrição---------: nRecnoNF,nRecnoDCT
===============================================================================================================================
Retorno-----------: .T. OU .F.
===============================================================================================================================
*/
Static function MFIN13Compensar(nRecnoNF,nRecnoDCT)
LOCAL lContabiliza:= .F.
LOCAL lAglutina   := .F.
LOCAL lDigita     := .F.
LOCAL aRecNF      := { nRecnoNF  } //NF
LOCAL aRecSE1     := { nRecnoDCT } //DCT

BEGIN TRANSACTION

  IF nRecnoNF > 0 .AND. nRecnoDCT > 0
    If !MaIntBxCR(3,aRecNF,,aRecSE1,,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,,,DATE() )
	   //DisarmTransaction()
	   _cErro:="Erro: Não foi possível fazer a compensação do titulo "+SE1->E1_NUM 
    ENDIF
 ELSE
    _cErro:="Erro: Não foi possível fazer a compensação do titulo "+SE1->E1_NUM+" Registros invalido: ["+CVALTOCHAR(nRecnoNF)+"] ["+CVALTOCHAR(nRecnoDCT)+"] "
 ENDIF

END TRANSACTION

RETURN EMPTY(_cErro)

/*
===============================================================================================================================
Programa--------: MFIN16Tela()
Autor-----------: Alex Walaluer
Data da Criacao-: 03/06/2019
===============================================================================================================================
Descrição-------: Tela detalhe
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: .T.
===============================================================================================================================
*/
*==============================================================================================================================*
STATIC FUNCTION MFIN16Tela(cAliasWK)
*==============================================================================================================================*
Local aBotoes      :={}
Local aTB_Campos   :={}
Local bMarcaTodos  :={|| U_MFIN016R("INVERTEMARCACAO") , oMark:oBrowse:Refresh() }
Local aCpoBrowse   :={}
Local aCoors	   := FWGetDialogSize(oMainWnd)
Local oDlg,oMark,I
Local _cTitAux:="Compensacao de titulos DCT"
Local aCab:={};_aCols:={}

AADD(aBotoes,{"RESPONSA",{|| U_MFIN016R("DESMARCARALL") , oMark:oBrowse:Refresh() },"Desmarca Todos","Desmarca Todos"})
AADD(aBotoes,{"RESPONSA",{|| U_MFIN016R("MARCARALL") , oMark:oBrowse:Refresh() },"Marca Todos","Marca Todos"})
AADD(aBotoes,{"RESPONSA",{|| U_MFIN016R("VISUALNF") } ,"Visualizar NF"  ,"Visualizar NF"})
AADD(aBotoes,{"RESPONSA",{|| U_MFIN016R("VISUALDCT")} ,"Visualizar DCT","Visualizar DCT"})
AADD(aBotoes,{"BUDGET"  ,{|| MFIN16Legenda() } ,"Legenda"     ,"Legenda"})
AADD(aBotoes,{"Exp. Excel"	, {|| DlgToExcel( { { "ARRAY" , _cTitAux , aCab , _aCols } } ) }, "Exportação de Dados para Excel"		, "Exp. Excel"		} )
AADD(aBotoes,{"Exp. Arquivo", {|| U_ITGERARQ( _cTitAux , aCab , _aCols ) }					, "Exportação de Dados para Arquivo"	, "Exp. Arquivo"	} )

DBSELECTAREA(cAliasWK)

aAdd( aCpoBrowse , { "Filial"	 	,{|| (cAliasWK)->FILIAL + IF(!EMPTY((cAliasWK)->FILIAL)," - "+LEFT(FWFilialName(cEmpAnt,(cAliasWK)->FILIAL,1),25),SPACE(25)) },"@!" } )
aAdd( aCpoBrowse , { "Titulo"		,{|| (cAliasWK)->TITU  }	, "@!"} )
aAdd( aCpoBrowse , { "Tipo NF"      ,{|| (cAliasWK)->E1_TIPONF }, AVSX3("E1_TIPO "   ,6)})
aAdd( aCpoBrowse , { "Tipo DCT "    ,{|| (cAliasWK)->E1_TIPO   }, AVSX3("E1_TIPO "   ,6)})
aAdd( aCpoBrowse , { "Prefixo NF"   ,{|| (cAliasWK)->E1_PREFINF}, AVSX3("E1_PREFIXO ",6)})
aAdd( aCpoBrowse , { "Prefixo DCT"  ,{|| (cAliasWK)->E1_PREFIXO}, AVSX3("E1_PREFIXO ",6)})
aAdd( aCpoBrowse , { "Parcela NF"	,{|| (cAliasWK)->WKPARCELA }, "@!"} )
aAdd( aCpoBrowse , { "Parcela DCT"	,{|| (cAliasWK)->WKPARCDCT }, "@!"} )
aAdd( aCpoBrowse , { "Cliente"		,{|| (cAliasWK)->CLIENTE }  , "@!" } )
aAdd( aCpoBrowse , { "Loja NF"		,{|| (cAliasWK)->LOJANF } 	, "@!"  } )
aAdd( aCpoBrowse , { "Loja DCT"		,{|| (cAliasWK)->LOJA } 	, "@!"  } )
aAdd( aCpoBrowse , { "Saldo NF"     ,{|| (cAliasWK)->SALDONF }	, "@E 999,999,999.99" } )
aAdd( aCpoBrowse , { "Saldo DCT"    ,{|| (cAliasWK)->SALDO }	, "@E 999,999,999.99" } )
aAdd( aCpoBrowse , { "Observação"	,{|| (cAliasWK)->ERRO  }	, ""} )
aAdd( aCpoBrowse , { "Registro NF"  ,{|| (cAliasWK)->REGSENF }	, "@E 999,999,999"} )
aAdd( aCpoBrowse , { "Registro DCT" ,{|| (cAliasWK)->REGSEDCT } , "@E 999,999,999"} )

AADD(aTB_Campos,{"MARCA",,"",})
FOR I := 1 TO LEN(aCpoBrowse)
    AADD(aTB_Campos,{aCpoBrowse[I,2],,aCpoBrowse[I,1],aCpoBrowse[I,3]})
NEXT

//Botões de Exportar ***************************
AADD(aCab,"Status" )
FOR I := 2 TO LEN(aTB_Campos)
    AADD(aCab,ALLTRIM(aTB_Campos[ I,3 ]) )
NEXT
(cAliasWK)->(DBGOTOP())
DO WHILE (cAliasWK)->(!EOF())
   _aColuna:={}
   AADD(_aColuna, (cAliasWK)->WKSTATUS )
   AADD(_aColuna, (cAliasWK)->FILIAL + IF(!EMPTY((cAliasWK)->FILIAL)," - "+AllTrim(FWFilialName(cEmpAnt,(cAliasWK)->FILIAL,1)),"") )
   AADD(_aColuna, "'"+(cAliasWK)->TITU  )
   FOR I := 4 TO LEN(aTB_Campos)
       IF VALTYPE(aTB_Campos[ I,1 ]) = "C"
          _xConteudo:=cAliasWK+"->"+ALLTRIM(aTB_Campos[ I,1 ])
          _xConteudo:=&(_xConteudo)
          AADD(_aColuna,_xConteudo )
       ELSE
          _xConteudo:=EVAL(aTB_Campos[ I,1 ])
          AADD(_aColuna,_xConteudo )
       ENDIF   
   NEXT
   AADD(_aCols, _aColuna )
   (cAliasWK)->(DBSKIP())    
ENDDO
//Botões de Exportar ***************************

DO WHILE .T.
   nOpca:=0

   oMainWnd:ReadClientCoords()//So precisa declarar uma fez para o Programa todo
   DEFINE MSDIALOG oDlg TITLE _cTitAux From aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] OF oMainWnd PIXEL

    (cAliasWK)->(DBGOTOP())
    oMark:=MSSELECT():New(cAliasWK,"MARCA","WKSTATUS <> 'A'",aTB_Campos,.F.,@cMarca,{21,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})

  	oMark:bAval                      := {|| U_MFIN016R("MARCAR"),oMark:oBrowse:Refresh() }
  	oMark:oBrowse:bAllMark           := bMarcaTodos
	oMark:oBrowse:lhasMark           := .T.
	oMark:oBrowse:lCanAllmark        := .T.

    oMark:oBrowse:aColumns[2]        := TCColumn():New()
    oMark:oBrowse:aColumns[2]:lBitmap:= .T.
    oMark:oBrowse:aColumns[2]:lNoLite:= .T.
    oMark:oBrowse:aColumns[2]:nWidth := 33
    oMark:oBrowse:aColumns[2]:bData  := {|| If((cAliasWK)->WKSTATUS = 'A', "BR_VERDE",If((cAliasWK)->WKSTATUS = 'E',"BR_PRETO",If((cAliasWK)->WKSTATUS = 'P', "BR_AZUL","BR_VERMELHO")))}

   ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg, {|| (nOpca:=1,oDlg:End()) } , {|| (nOpca:=0,oDlg:End()) },,aBotoes) ,;
                                    oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT ,;
                                    oMark:oBrowse:Refresh() )
   IF nOpca = 1
      (cAliasWK)->(DBGOTOP()) 
      nTotal:=0
      (cAliasWK)->( DBEVAL( {|| nTotal++ }, {|| !EMPTY((cAliasWK)->MARCA) } , {|| .T.} ) )
      IF nTotal = 0
         U_ITMSG("Não existem registros marcados, marque pelo menos uma viagem válida para integrar!","Atenção",,1)
         LOOP
      ENDIF
      IF U_ITMSG("Confirma a Compensação?" ,"Atenção","Serão conpensados "+ALLTRIM(STR(nTotal,10))+" titulos",3,2,2 ) 
         FWMSGRUN( ,{|oproc| U_MFIN016B(oproc)},"Aguarde","Processando..." )
         LOOP
      ELSE
         LOOP
      ENDIF
   ELSEIF nOpca = 0 
      IF U_ITMSG("Confirma o CANCELAMENTO?" ,"Atenção" ,"Todos os dados lidos seram perdidos: ", 3,2,2 )
         RETURN .F.
      ELSE
         LOOP
      ENDIF
   ENDIF

   EXIT

ENDDO

RETURN .T.               

*--------------------------------------------------------------------------------------*
STATIC Function MFIN16Legenda()
*--------------------------------------------------------------------------------------*
LOCAL aLegenda:={}
AADD(aLegenda,{"ENABLE"    ,"Aceitos"    })
AADD(aLegenda,{"DISABLE"   ,"Rejeitados" })
AADD(aLegenda,{"BR_AZUL"   ,"Processados"})
AADD(aLegenda,{"BR_PRETO"  ,"Analizar"   })
BrwLegenda("Legenda","Legenda",aLegenda)
Return .T.
