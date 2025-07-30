/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor    |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer  | 01/10/2019 | Chamado 30406. Incluido as colunas de status na planilhas.
 Julio Paz      | 13/12/2019 | Chamado 31234. Correção na exibição do nome do cliente na exportação dos dados para o Excel.
 Alex Wallauer  | 06/11/2020 | Chamado 34499. Novo filtro por Status
 Alex Wallauer  | 06/11/2020 | Chamado 34490. Reajuste das ordem das colunas no botão gera Excel.
 Alex Wallauer  | 31/03/2021 | Chamado 35954. Tratamento para quando o vier zero nos status gravar branco.
 Alex Wallauer  | 26/01/2022 | Chamado 38682. Tratamento para deixar as versoes XML e Excel iguais.
 Alex Wallauer  | 13/04/2022 | Chamado 39768. Correção do Tratamento para quando o vier zero nos status gravar branco.
 Alex Wallauer  | 18/05/2022 | Chamado 39929. Alteraão do filtro de Status e novo filtro de Status de Emissão.
 Julio Paz      | 14/03/2023 | Chamado 43232. Inicializar campo Status Emissão com a nova opção Combobox 5=Vazio. 
 Julio Paz      | 14/03/2023 | Chamado 43241. Remover a gravação dos dados do vendedor do campo nota fiscal de origem.
 Julio Paz      | 24/03/2023 | Chamado 43364. Corrigir a gravação do campo data de emissão na rotina.
 Julio Paz      | 16/06/2023 | Chamado 44135. Incluir uma nova opção de filtro por cliente.
 Alex Wallauer  | 08/09/2023 | Chamado 44858. Adicionar na geração de relatórios exportação XML e Excel dois novos campos.
 Antonio Neves  | 14/12/2023 | Chamado 45669. Adicionar campos para identificação de poós vendas e oper. triangular
 Antonio Ramos  | 19/12/2023 | Chamado 45888. Adição de novas colunas no relatório.
 Antonio Ramos  | 22/12/2023 | Chamado 45935 .Inclusão de novas colunas ao relatório (Nf. Débito e Dev. Fábrica)
 Antonio Ramos  | 27/12/2023 | Chamado 45954 .Ajuste do Operador Logístico no Relatório
 Antonio Ramos  | 03/01/2024 | Chamado 45996 . Ajuste da Operação Triangular Adquirente e Destinatário - Adicionar
 Antonio Ramos  | 07/02/2024 | Chamado 46251 . Ajuste Para trazer a situação 08=Com Estoque ao Relatórios
 Antonio Ramos  | 20/03/2024 | Chamado 46681 . Incluir a opção de inconsistente na Analise de Devoluçao
=============================================================================================================================== 

=============================================================================================================================== 
Analista        - Programador     - Inicio     - Envio      - Chamado - Motivo de Alteração
===============================================================================================================================
Antonio Ramos   - Igor Melgaço    - 18/09/2024 - 04/10/2024 - 47819   - Ajuste para gravação de log de alteração.
Antonio Ramos   - Igor Melgaço    - 18/12/2024 - 23/01/2025 - 49056   - Ajustes para gravação de historico de alterações de campo da SE1
Antonio Ramos   - Julio Paz       - 23/01/2025 - 27/01/2025 - 49597   - Inclusão de Nova Opções de Filtro por Rede e Região no Relatório Monitor de Devoluções [OMS]
Antonio Ramos   - Igor Melgaço    - 18/07/25   - 18/07/2025 - 50861   - Inclusão coluna informação NF Troca Nota
Antonio Ramos   - Igor Melgaço    - 18/07/25   - 18/07/2025 - 51258   - Inclusão coluna NF de Remessa
=============================================================================================================================== 
*/
#include "rwmake.ch"
#include "APWEBSRV.CH"
#Include "Protheus.ch"
#INCLUDE "TBICONN.CH"   
#Include "FWMVCDef.Ch"
#Include "topconn.Ch"

Static _aDadAlt := {}
/*
===============================================================================================================================
Programa----------: MOMS045
Autor-------------: ALEX WALLAUER
Data da Criacao---: 06/09/2019
===============================================================================================================================
Descrição---------: Monitor de devoluções Italac - CHAMADO 30406
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS045()
Local _cAlias As Character

Private cCadastro As Character
Private aRotina	As Array             
Private _bLegend As Block

_cAlias	  := "ZDS"
cCadastro := ""
aRotina	  := {}                
_bLegend  := {||.T.} 

AADD(aRotina,{"Pesquisar" ,"AxPesqui" ,0,1})
AADD(aRotina,{"Visualizar","AxVisual" ,0,2})
AADD(aRotina,{"Importar"  ,"FWMSGRUN( ,{|oProc| U_MOMS045P(oProc,1) },,'Iniciando o processamento...' )",0,4})
AADD(aRotina,{"Alterar"   ,"U_MOMS045A()" ,0,4})
AADD(aRotina,{"Alterar em Massa","FWMSGRUN( ,{|oProc| U_MOMS045P(oProc,4) },,'Iniciando o processamento...' )",0,2})
AADD(aRotina,{"Gera XML"  ,"FWMSGRUN( ,{|oProc| U_MOMS045P(oProc,3,.F.) },,'Iniciando o processamento...' )",0,2})
aAdd(aRotina,{"Legenda"   ,"U_MOMS45LE",0,2})
AADD(aRotina,{"Gera Excel","FWMSGRUN( ,{|oProc| U_MOMS045P(oProc,3,.T.) },,'Iniciando o processamento...' )",0,2})
AADD(aRotina,{"Historico de Alteracoes","FWMSGRUN( ,{|oProc| U_MOMS045H() },,'Iniciando o processamento...' )",0,2})

_aCores:={}
_bLegend := {|| U_MOMS045L()} //Função que carrega váriavel com cores da legenda
AADD(_aCores,{'Eval(_bLegend)=="D"',"BR_AMARELO" })   // Documento Nao Gerado
AADD(_aCores,{'Eval(_bLegend)=="P"',"BR_VERDE"   })   // Documento Gerado
AADD(_aCores,{'Eval(_bLegend)=="E"','BR_PRETO'   })   // Documento com Ocorrencia
AADD(_aCores,{'Eval(_bLegend)=="X"','BR_VERMELHO'})   // Documento Excluido

dbSelectArea(_cAlias)
dbSetOrder(1)
cCadastro:= "Monitor de devoluções ITALAC"

// owse(,,,,cAli>  ,<aFixe, <cCpo>, <nPar>, <cCorFun>, <nClickDef>, <aColors>, <cTopFun>, <cBotFun>, <nPar14>, <bInitBloc>, <lNoMnuFilter>, <lSeeAll>, <lChgAll>, <cExprFilTop>, <nInterval>, <uPar22>, <uPar23> )
mBrowse(,,,,_cAlias,      ,       ,       ,          ,            , _aCores)

Return

/*
===============================================================================================================================
Programa----------: MOMS045P
Autor-------------: Alex Wallauer
Data da Criacao---: 28/02/2018
===============================================================================================================================
Descrição---------: Processamento de Importação de DADOS DO SDS
===============================================================================================================================
Parametros--------: oProc - objeto da barra de processamento
                    lExcel - Gera Excel
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS045P(oProc As Object,nOpcao As Numeric,_lXLSX As Logical)
Local _cQuery1 As Character
Local nI As Numeric 
Local _nCpo As Numeric
Local nInc As Numeric
Local nAlt As Numeric
Local _aParAux As Array
Local _aParRet As Array
Local _cAlias As Character
Local _bOK As Block
Local aArea As Array
Local _cDevFab As Character
Local _cNfDeb As Character
Local _cNomeGVen As Character 
Local _cNumNFTN As Character
Local _cNumPVTN As Character
Local _cNumFilTN As Character
Local _cNumNFRM As Character

PRIVATE _aStatu As Array
PRIVATE _aStEmi As Array
PRIVATE _aStSit As Array
PRIVATE _aRegiao As Array
PRIVATE _aItalac_F3 As Array

_cQuery1 := ""
nI       := 0
_nCpo    := 0
nInc     := 0
nAlt     := 0
_aParAux := {}
_aParRet := {}
_cAlias  := GetNextAlias()
_bOK     := {|| .T. }
aArea    := ZDS->(GetArea())
_cDevFab := "N"
_cNfDeb  := "N"

_aStatu  := {"D-Nao Gerado    ",;
                   "P-Gerado        ",;
				   "E-Com Ocorrencia",;
				   "X-Excluido      "}

_aStEmi     := {"1-Ato da Entrega" ,"2-Pós Venda"       ,"3-Transferencia"       ,"4-Pallet"      ,"5-Vazio"}
_aStSit     := {"1-Canhoto Cobrado","2-Canhoto Recebido","3-Solicitado Recusa"   ,"4-Check List"  ,"5-Com Fiscal","6-Com Logistica","7-Com Comercial","8-Com Estoque"}
_aRegiao    := {"1-Regio Sudeste"  ,"2-Região Sul"      ,"3-Região Centro Oeste" ,"4-Região Norte","5-Região Nordeste"}

_aItalac_F3 := {}


//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave              , _nCpoDesc                   ,_bCondTab , _cTitAux        , _nTamChv , _aDados , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR04",     ,                              ,                             ,          ,"Status"         , 1        ,_aStatu  , LEN(_aStatu)                              } )
AADD(_aItalac_F3,{"MV_PAR05",     ,                              ,                             ,          ,"Status Emissao" , 1        ,_aStEmi  , LEN(_aStEmi)                              } )
AADD(_aItalac_F3,{"MV_PAR11",     ,                              ,                             ,          ,"Região"         , 1        ,_aRegiao , LEN(_aRegiao)                             } )

oProc:cCaption := ("Filtrar dados de devoluções...")
ProcessMessages()

MV_PAR06 := Space(6)
MV_PAR07 := Space(4)
MV_PAR08 := Space(6)
MV_PAR09 := Space(4)

IF nOpcao <> 4//Gera Excel / Gera XML   / Importar
    _bOK    := {|| IF(MV_PAR02 >= MV_PAR01 ,.T.,(U_ITMSG("Periodo INVALIDO",'Atenção!',"Tente novamente com outro periodo",3),.F.) ) }
	MV_PAR01:= dDataBase
	MV_PAR02:= dDataBase
	MV_PAR03:= SPACE(200)
	MV_PAR04:= SPACE(015)
	MV_PAR05:= SPACE(015)
	MV_PAR10:= Space(100)
	MV_PAR11:= Space(100)
	AADD( _aParAux , { 1 , "Data de"       , MV_PAR01, "@D"	 , ""  , ""		 , "" , 050 , .F. } )
	AADD( _aParAux , { 1 , "Data ate"      , MV_PAR02, "@D"	 , ""  , ""		 , "" , 050 , .F. } )
	AADD( _aParAux , { 1 , "Filial"        , MV_PAR03, "@S99", ""  ,"LSTFIL" , "" , 100 , .F. } )
	AADD( _aParAux , { 1 , "Status"        , MV_PAR04, "@!"  , ""  ,"F3ITLC" , "" , 050 , .F. } ) 
	AADD( _aParAux , { 1 , "Status Emissao", MV_PAR05, "@!"  , ""  ,"F3ITLC" , "" , 050 , .F. } ) 
	AADD( _aParAux , { 1 , "Cliente De:"   , MV_PAR06, "@!"  , ""  ,"SA1"    , "" , 035 , .F. } )
	AADD( _aParAux , { 1 , "Loja De:"      , MV_PAR07, "@!"  , ""  ,""       , "" , 015 , .F. } )
	AADD( _aParAux , { 1 , "Cliente Até:"  , MV_PAR08, "@!"  , ""  ,"SA1"    , "" , 035 , .F. } )
    AADD( _aParAux , { 1 , "Loja Até:"     , MV_PAR09, "@!"  , ""  ,""       , "" , 015 , .F. } )
    AADD( _aParAux , { 1 , "Rede"          , MV_PAR10, "@!"  , ""  ,"REDE50" , "" , 100 , .F. } )
	AADD( _aParAux , { 1 , "Região"        , MV_PAR11, "@!"  , ""  ,"F3ITLC" , "" , 50  , .F. } )

ELSE   //Alterar em Massa
	MV_PAR01:=SPACE(200)
	aAdd( _aParAux , { 1 , "Selecione arquivo .CSV:",MV_PAR01, "@!"	, "", "DIR","", 100, .T. } )
ENDIF

For nI := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nI][03] )
Next nI

// 1 - < aParametros > - Vetor com as configurações
// 2 - < cTitle >      - Título da janela
// 3 - < aRet >        - Vetor passador por referencia que contém o retorno dos parâmetros
// 4 - < bOk >         - Code block para validar o botão Ok
// 5 - < aButtons >    - Vetor com mais botões além dos botões de Ok e Cancel
// 6 - < lCentered >   - Centralizar a janela
// 7 - < nPosX >       - Se não centralizar janela coordenada X para início
// 8 - < nPosY >       - Se não centralizar janela coordenada Y para início
// 9 - < oDlgWizard >  - Utiliza o objeto da janela ativa
//10 - < cLoad >       - Nome do perfil se caso for carregar
//11 - < lCanSave >    - Salvar os dados informados nos parâmetros por perfil
//12 - < lUserSave >   - Configuração por usuário

//        aParametros,cTitle,aRet     ,bOk ,aButtons,lCentered,nPosX,nPosY,oDlgWizard,cLoad,lCanSave,lUserSave
IF !ParamBox( _aParAux , "" ,@_aParRet,_bOK,        ,         ,     ,     ,          ,     ,.T.     ,.T. )//Intervalo de Datas e Filial
    RETURN .F.
EndIf

oProc:cCaption := ("Lendo dados de devoluções...")
ProcessMessages()

IF nOpcao = 4//ALTERAR EM MASSA  ********************************************************************************
	
	_cArq := ALLTRIM(MV_PAR01)
	IF UPPER(RIGHT(_cArq,3)) <> "CSV" .OR. FT_FUSE(_cArq) == -1
		U_ITMSG("Não foi possível abrir o arquivo informado.",;
		        "Arquivo inválido","O arquivo informado deve ser .CSV ou verificar se o arquivo informado esta correto.",1)
		RETURN .F.
	ENDIF

	_cTot:=FT_FLASTREC()-1
	_cTot:=ALLTRIM(STR(_cTot))
	_nTam:=LEN(_cTot)
	
	FT_FGOTOP() //POSICIONA NO TOPO DO ARQUIVO
	_cDados := FT_FREADLN()
	
	If ! "CHAVE DE ACESSO;STATUS EMISSAO;SITUACAO;OBS FISCAL;OBS GERAIS;OBS ABAT NF" $ UPPER(ALLTRIM(_cDados))
		U_ITMSG("Arquivo informado com o cabeçalho incorreto.",;
	            "Arquivo inválido","O arquivo deve conter o cabeçalho: CHAVE DE ACESSO;STATUS EMISSAO;SITUACAO;OBS FISCAL;OBS GERAIS;OBS ABAT NF",1)
		RETURN .F.
	ENDIF
	
	FT_FSKIP() 
	_aDados:={}
	_nCont:=_nConta:=0
	_nErro:=0
    ZDS->(DBSETORDER(5)) //ZDS_CHAVNF
	
	DO WHILE !FT_FEOF()  //FACA ENQUANTO NAO FOR FIM DE ARQUIVO
		
		_nCont++		
		oProc:cCaption := ("Processando Dados: "+ STRZERO(_nCont,_nTam) +" de "+ _cTot)
		ProcessMessages()
		
		_cDados := FT_FREADLN()
		_cDados := STRTRAN(_cDados,'"','')//Tem que ter ate 6 colunas
		
		//Verifica se é final de arquivo
		IF ALLTRIM(_cDados) = ';;;;;' .and. _nConta > 10
		   _nConta++
		   EXIT
		ENDIF

		_aLinhas:= StrTokArr2(_cDados,";",.T.)//Tem que ter ate 6 colunas
		_aItens:={}

        IF LEN(_aLinhas) < 6
           _aLinhas:=U_ITTXTARRAY(_cDados,"",6)
        ENDIF  
        
        AADD(_aItens,.T.)//1
        AADD(_aItens,IF(LEN(_aLinhas) > 0,_aLinhas[1],""))//2
        AADD(_aItens,IF(LEN(_aLinhas) > 1,_aLinhas[2],""))//3
        AADD(_aItens,IF(LEN(_aLinhas) > 2,_aLinhas[3],""))//4
        AADD(_aItens,IF(LEN(_aLinhas) > 3,_aLinhas[4],""))//5
        AADD(_aItens,IF(LEN(_aLinhas) > 4,_aLinhas[5],""))//6
        AADD(_aItens,IF(LEN(_aLinhas) > 5,_aLinhas[6],""))//7
        AADD(_aItens,"" )//8 - Erro 
        
        IF EMPTY(_aItens[2]) .OR. !ZDS->(DBSEEK(_aItens[2]))
           _aItens[1]:=.F.
           _aItens[LEN(_aItens)]:="[Chave não informada ou não encontrada] "
        ELSE
           _aItens[2]:=ZDS->ZDS_FILIAL+" "+_aItens[2]
        ENDIF
        IF !EMPTY(_aItens[3]) .AND. !LEFT(_aItens[3],1) $ "0/1/2/3/4/5"//"1=Ato da Entrega;2=Pós Venda;3=Transferencia;4=Pallet;5=Vazio" 0-Em branco
           _aItens[1]:=.F.
           _aItens[LEN(_aItens)]+="[Status deve ser entre 0 e 5] "
        ELSEIF LEFT(_aItens[3],1) = "0" 
           _aItens[3]:="0"
        ELSEIF !EMPTY(_aItens[3])
           _aItens[3]:=_aStEmi[VAL(_aItens[3])]
        ENDIF
        IF !EMPTY(_aItens[4]) .AND. !LEFT(_aItens[4],1) $ "0/1/2/3/4/5/6/7"//"1=Canhoto Cobrado;2=Canhoto Recebido;3=Solicitado Recusa;4=Check List;5=Com Fiscal;6=Com Logistica;7=Com Comercial" 0-Em branco
           _aItens[1]:=.F.
           _aItens[LEN(_aItens)]+="[Situacao deve ser entre 0 e 7] "
        ELSEIF LEFT(_aItens[4],1) ="0"
           _aItens[4]:="0"
        ELSEIF !EMPTY(_aItens[4])
           _aItens[4]:=_aStSit[VAL(_aItens[4])]
        ENDIF
        IF _aItens[1] = .F.
           _nErro++
        ENDIF   
		AADD(_aDados,_aItens)

	    FT_FSKIP()
	
   Enddo

   FT_FUSE()

	If LEN(_aDados) > 0
		//Monta _aCab
		_aCab:={}
		_aSize:={}
		aadd(_aCab,"")//01
		aadd(_aSize,5)
		AAdd(_aCab,"Filial + Chave de Acesso")//02
		aadd(_aSize,110)
		AAdd(_aCab,"Status Emissao")//03
		aadd(_aSize,45)
		AAdd(_aCab,"Situacao")//04
		aadd(_aSize,45)
		AAdd(_aCab,"Obs Fiscal")//05
		aadd(_aSize,150)
		AAdd(_aCab,"Obs. Financeira")//06
		aadd(_aSize,150)
		AAdd(_aCab,"Obs. Logística")//07
		aadd(_aSize,150)
		AAdd(_aCab,"Erros")//08
		aadd(_aSize,150)
		
		_cTitulo:="Dados do Arquivo "+_cArq
		_cMsgTop:="Alteracao em Massa, Registros Lidos: "+ALLTRIM(TRANSFORM(VAL(_cTot),"@E 999,999,999"))+", Com Erros: "+ALLTRIM(TRANSFORM(_nErro,"@E 999,999,999"))
		DO WHILE .T.
		//        ITListBox(_cTitAux, _aHeader , _aCols    , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons )
		   lOK:=U_ITLISTBOX(_cTitulo, _aCab    , _aDados   , .T.      , 4      ,_cMsgTop  ,          , _aSize)
		   
		   IF lOK .AND. U_ITMSG("Confirma alteração dos registros válidos",'Atenção!',,3,2,3,,"CONFIRMA","Voltar")
		      MOMS45AM(oProc)//GRAVA OS DADOS DO CSV
              EXIT
		   ELSEIF !lOK .AND. U_ITMSG("Confirma SAIR",'Atenção!',"Todos os registros de válidações serão perdidos",3,2,3,,"CONFIRMA","Voltar")
		      EXIT
		   ENDIF
		   
		ENDDO
    else
	   U_ITMSG("Nenhum registro válido",'Atenção!',"Dados do Arquivo "+_cArq,1)		
	Endif
   ZDS->(DBSETORDER(1))

ELSEIF nOpcao = 2 .OR. nOpcao = 3//GERA .CSV (2-NÃO USA MAIS) OU GERA XML  **********************************************************************************************

    _aZDS:={}
    _aNFO:={}
       
	_cQuery1+= " SELECT ZDS.R_E_C_N_O_ ZDS_REC, A1_GRPVEN, A1_I_REGIA "
	_cQuery1+= "		FROM " + RetSqlName("ZDS")+" ZDS, " + RetSqlName("SA1")+" SA1 " 
	_cQuery1+= "  WHERE ZDS.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' "
	_cQuery1+= "  AND ZDS_FORNEC = A1_COD AND ZDS_LOJA = A1_LOJA "

	IF !EMPTY(MV_PAR02)
		_cQuery1 += "  AND ZDS.ZDS_EMISSA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	ELSEIF !EMPTY(MV_PAR01)
		_cQuery1 += "  AND ZDS.ZDS_EMISSA >= '" + DTOS(MV_PAR01) + "'"
	ENDIF
	If !EMPTY(MV_PAR03)
		IF LEN(ALLTRIM(MV_PAR03)) > 2
			_cQuery1 += " AND ZDS.ZDS_FILIAL IN " + FormatIn(ALLTRIM(MV_PAR03),";")
		ELSE
			_cQuery1 += " AND ZDS.ZDS_FILIAL = '"+ALLTRIM(MV_PAR03)+"' "
		Endif
	Endif

    //======================
	// Filtro por cliente 
	//======================
    If !Empty(MV_PAR06)
       _cQuery1 += " AND ZDS.ZDS_FORNEC >= '" + MV_PAR06 + "' " 
	EndIf

	If !Empty(MV_PAR07)
       _cQuery1 += " AND ZDS.ZDS_LOJA >= '" + MV_PAR07 + "' "  
	EndIf 

	If !Empty(MV_PAR08)
       _cQuery1 += " AND ZDS.ZDS_FORNEC <= '" + MV_PAR08 + "' " 
	EndIf 

	If !Empty(MV_PAR09)
       _cQuery1 += " AND ZDS.ZDS_LOJA <= '" + MV_PAR09 + "' "  
	EndIf 
    
	//======================
	// Filtro por Rede 
	//======================
    If ! Empty(MV_PAR10)
       _cQuery1 += " AND A1_GRPVEN IN " + FormatIn(AllTrim(MV_PAR10),";")

	EndIf 

	//======================
	// Filtro por Região 
	//======================
    If ! Empty(MV_PAR11)
	   _cRegioes := ""
	   If "1" $ MV_PAR11 //"1-Regio Sudeste"  
           _cRegioes += "SP;RJ;MG;ES;"
	   EndIf
	         
	   If "2" $ MV_PAR11 //"2-Região Sul"
           _cRegioes += "SC;RS;PR;"
	   EndIf
	   
	   If "3" $ MV_PAR11 //"3-Região Centro Oeste" 
          _cRegioes += "MS;MT;TO;GO;DF;
	   EndIf
	   
       If "4" $ MV_PAR11 //"4-Região Norte" 
          _cRegioes += "AC;AM;AP;MA;PA;RO;RR;"
	   EndIf

       If "5" $ MV_PAR11 //"5-Região Nordeste" 
          _cRegioes += "AL;BA;CE;PB;PE;PI;RN;SE;"
	   EndIf

       If ! Empty(_cRegioes)
          _cQuery1 += " AND ZDS_EST IN " + FormatIn(AllTrim(_cRegioes),";")
	   EndIf 

	EndIf 

	_cQuery1 += " ORDER BY ZDS_EMISSA "
	
	MPSysOpenQuery( _cQuery1 , _cAlias )
	
	oProc:cCaption := ("Contando os dados lidos...")
	ProcessMessages()
	DBSELECTAREA(_cAlias)
	(_cAlias)->(Dbgotop())
	_nConta:=_cTot := 0
	COUNT TO _cTot
	_cTot:=ALLTRIM(STR(_cTot))
	_nTam:=LEN(_cTot)
    _lXMLTambem:=.F.//Decide se poe o Status por ultimo no XML Tambem
	IF _lXMLTambem .OR. nOpcao = 2 .OR. nOpcao = 3  //.CSV (2-NÃO USA MAIS)*********************************************
	   _aSX3:={}
       AADD(_aSX3,"ZDS_OBSGER")
       AADD(_aSX3,"ZDS_OBSABA")
       AADD(_aSX3,"ZDS_STUEMI")
       AADD(_aSX3,"ZDS_STUSIT")
       AADD(_aSX3,"ZDS_OBSCOM")
       AADD(_aSX3,"ZDS_FILIAL")
       AADD(_aSX3,"ZDS_DOC")
       AADD(_aSX3,"ZDS_SERIE")
       AADD(_aSX3,"ZDS_FORNEC")
       AADD(_aSX3,"ZDS_LOJA")
       AADD(_aSX3,"ZDS_CNPJ") //*
       AADD(_aSX3,"ZDS_NOMFOR")
       AADD(_aSX3,"ZDS_EMISSA")
       AADD(_aSX3,"ZDS_CHAVNF")//*
       AADD(_aSX3,"ZDS_NFORIG")
       AADD(_aSX3,"ZDS_VLRTOT")
       AADD(_aSX3,"ZDS_EST")  
       AADD(_aSX3,"ZDS_CLIMUN")
       AADD(_aSX3,"ZDS_CLIEMA")
	   	   
 
	ELSE//XML ******************************************
       _aSX3:= FWSX3Util():GetAllFields( "ZDS" , .T. )  
	ENDIF  
    SF2->(DBSETORDER(1))
	(_cAlias)->(Dbgotop())
	DO WHILE (_cAlias)->(!EOF())
		
		_nConta++
		oProc:cCaption := ("Processando Dados: "+ STRZERO(_nConta,_nTam) +" de "+ _cTot)
		ProcessMessages()
		
		ZDS->(DBGOTO((_cAlias)->ZDS_REC))
		
		_cStatus:=U_MOMS045L()//Status Atual
		
		IF !EMPTY(MV_PAR04) .AND. !_cStatus $ ALLTRIM(MV_PAR04)
		   (_cAlias)->(DBSKIP())
		   LOOP
		ENDIF
		
        IF  !EMPTY(MV_PAR05) .AND. !ZDS->ZDS_STUEMI $ ALLTRIM(MV_PAR05)
		   (_cAlias)->(DBSKIP())
		   LOOP
		ENDIF

		_aItens:={}  
		
		IF !_lXMLTambem .AND. nOpcao = 3//XML ******************************************
           IF (nPos:=ASCAN(_aStatu,{|S| LEFT(S,1) = _cStatus} )) > 0 
	          AADD(_aItens, _aStatu[nPos] )
           ELSE
	          AADD(_aItens, "Sem Status" )
           ENDIF
        ENDIF
		
		FOR _nCpo:= 1 TO LEN(_aSX3)

  	        _nPos:=ZDS->( FIELDPOS(_aSX3[_nCpo]) )


            If AllTrim(_aSX3[_nCpo]) == "ZDS_NOMFOR"
               Aadd(_aItens,Space(30) )
            Else
		       Aadd(_aItens,ZDS->( FIELDGET(_nPos) ) )
			EndIf
			
            IF ZDS->( FIELD(_nPos) ) = "ZDS_STUEMI" 
               nPos:=VAL(_aItens[ LEN(_aItens) ])
               IF nPos > 0 .AND. nPos <= 5
                 _aItens[ LEN(_aItens) ]:=_aStEmi[nPos]
               ENDIF  

            ELSEIF  nOpcao = 2 .AND. ZDS->( FIELD(_nPos) ) $ "ZDS_FILIAL /ZDS_CNPJ /ZDS_CHAVNF /ZDS_DOC /ZDS_FORNEC /ZDS_LOJA " // Se .CSV (2-NÃO USA MAIS)
               _aItens[ LEN(_aItens) ]:="'"+_aItens[ LEN(_aItens) ]

            ELSEIF  nOpcao = 2 .AND. ZDS->( FIELD(_nPos) ) = "ZDS_NFORIG" // Se .CSV (2-NÃO USA MAIS)
			   IF (RIGHT(AllTrim(_aItens[ LEN(_aItens)]), 2 ) = CHR(13)+CHR(10))
                   _aItens[ LEN(_aItens) ]:=LEFT( _aItens[ LEN(_aItens) ] , LEN(AllTrim(_aItens[ LEN(_aItens)] )) - 2 )
               ENDIF

            ELSEIF ZDS->( FIELD(_nPos) ) = "ZDS_STUSIT"
               nPos:=VAL(_aItens[ LEN(_aItens) ])
               IF nPos > 0 .AND. nPos <= 8
                  _aItens[ LEN(_aItens) ]:=_aStSit[VAL(_aItens[ LEN(_aItens) ])]
               ENDIF
            ELSEIF AllTrim(_aSX3[_nCpo]) == "ZDS_NOMFOR"// ZDS->( FIELD(_nPos) ) = "ZDS_NOMFOR"
               _aItens[ LEN(_aItens) ] := POSICIONE("SA1",1,xFilial("SA1")+ZDS->ZDS_FORNEC+ZDS->ZDS_LOJA,"A1_NOME") 
               

            ENDIF
           
		NEXT
	    
   	  	If SF2->(Dbseek(ZDS->ZDS_FILIAL+SUBSTR(ZDS->ZDS_NFORIG,1,9)+SUBSTR(ZDS->ZDS_NFORIG,11,3)))
		   AADD(_aItens, SF2->F2_I_NTRAN)//CAMPOS NOVOS
		   IF nOpcao = 2 //(2-NÃO USA MAIS)
	          AADD(_aItens, "'"+SF2->F2_CARGA  )//CAMPOS NOVOS
		   ELSE
	          AADD(_aItens, SF2->F2_CARGA  )//CAMPOS NOVOS
		   ENDIF
        ELSE
		   AADD(_aItens, SPACE(LEN(SF2->F2_I_NTRAN)))//CAMPOS NOVOS
	       AADD(_aItens, SPACE(LEN(SF2->F2_CARGA  )))//CAMPOS NOVOS
		ENDIF
		
		
		AADD(_aItens, DTOC(SF2->F2_I_DENCL))//DATA ENTREGA
		
		ZGJ->(Dbsetorder(1))
	    IF ZGJ->(Dbseek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE))
			AADD(_aItens, DTOC(_cDtCanh := POSICIONE("ZGJ",1,SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE,"ZGJ_DTENT")))//DATA CANHOTO
		Else
			AADD(_aItens,DTOC(_cDtCanh := SF2->F2_I_DTRC))
		EndIf 
		
		If !Empty(_cDtCanh) //SF2->F2_I_DTRC //DATA CANHOTO
//			If SF2->F2_EMISSAO == SF2->F2_I_DTRC
			If ZDS->ZDS_EMISSA == _cDtCanh //SF2->F2_I_DTRC
				AADD(_aItens, "ATO ENTREGA") //ATO ENTREGA OU POS-VENDA
			ElseIf ZDS->ZDS_EMISSA > _cDtCanh //SF2->F2_I_DTRC
				AADD(_aItens, "POS-VENDA") //ATO ENTREGA OU POS-VENDA
			ElseIf ZDS->ZDS_EMISSA < _cDtCanh //SF2->F2_I_DTRC
				AADD(_aItens, "INCONSISTENCIA") //ATO ENTREGA OU POS-VENDA
			EndIf
		else
			AADD(_aItens, "SEM INFORMACAO") //ATO ENTREGA OU POS-VENDA
		ENDIF
		_cCodOper := POSICIONE("SC5",1,SF2->F2_FILIAL+SF2->F2_I_PEDID,"C5_I_OPER") //COD.OPER.TRIANG
		_cNumNFRM := " "
		If _cCodOper == "42" //OPERCAO REMESSA
			_cNumPvFt :=  POSICIONE("SC5",1,SF2->F2_FILIAL+SF2->F2_I_PEDID,"C5_I_PVFAT")
			_cCodLogt := POSICIONE("SC5",1,SF2->F2_FILIAL+_cNumPvFt,"C5_CLIENTE")
			_cLojLogt := POSICIONE("SC5",1,SF2->F2_FILIAL+_cNumPvFt,"C5_LOJACLI")
			AADD(_aItens, SUBSTR(POSICIONE("SA1",1,xFilial("SA1")+_cCodLogt+_cLojLogt,"A1_NOME"),1,20)) // OPERADOR TRIANGULAR
		ElseIf _cCodOper == "05"
			_cNumPvFt :=  POSICIONE("SC5",1,SF2->F2_FILIAL+SF2->F2_I_PEDID,"C5_I_PVREM")
			_cCodLogt := POSICIONE("SC5",1,SF2->F2_FILIAL+_cNumPvFt,"C5_CLIENTE")
			_cLojLogt := POSICIONE("SC5",1,SF2->F2_FILIAL+_cNumPvFt,"C5_LOJACLI")
			_cNumNFRM := SC5->C5_NOTA
			AADD(_aItens, SUBSTR(POSICIONE("SA1",1,xFilial("SA1")+_cCodLogt+_cLojLogt,"A1_NOME"),1,20)) // OPERADOR TRIANGULAR
		else
			AADD(_aItens," ")
		EndIf
		AADD(_aItens,IIF(POSICIONE("SC5",1,SF2->F2_FILIAL+SF2->F2_I_PEDID,"C5_I_TRCNF")=="S","S","N")) //TROCA NOTA S/N
		_cNumPVTN := SC5->C5_I_PDPR

		_cNumFilTN := POSICIONE("SC5",1,SF2->F2_FILIAL+SF2->F2_I_PEDID,"C5_I_FLFNC")
		AADD(_aItens,_cNumFilTN) //FILIAAL ORIGEM TROCA NOTA
		
		AADD(_aItens,ALLTRIM(POSICIONE("SA2",1,xFilial("SA2")+SF2->F2_I_OPER+SF2->F2_I_OPLO,"A2_NOME"))) //OPERADOR

		_cNumNFTN := POSICIONE("SC5",1,_cNumFilTN+_cNumPVTN,"C5_NOTA")
		AAdd(_aItens,_cNumPVTN+" - "+_cNumNFTN)
		//ADICAO CAMPOS NOVOS 
		dbSelectArea("ZF5")
		ZF5->(dbSetOrder(1))
		If ZF5->(dbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE))
     	
			DO WHILE ZF5->(!EOF()) .AND. SF2->F2_FILIAL == ZF5->ZF5_FILIAL .AND. SF2->F2_DOC == ZF5->ZF5_DOCOC;
								   .AND. SF2->F2_SERIE == ZF5->ZF5_SEROC
				If ZF5->ZF5_STATUS == "000008"
					_cDevFab := "S"
				EndIf

				If ZF5->ZF5_NDEBIT == "S"		
					_cNfDeb := "S"
				EndIf
				
				ZF5->(DBSKIP())
			ENDDO  
		EndIf
		ZF5->(dbCloseArea())

		AADD(_aItens,_cDevFab) //FILIAAL ORIGEM TROCA NOTA
		AADD(_aItens,_cNfDeb) //OPERADOR
		_cNomeGVen := Posicione("ACY",1,xFilial("ACY")+(_cAlias)->A1_GRPVEN,"ACY_DESCRI")
        AADD(_aItens,(_cAlias)->A1_GRPVEN+"-"+Alltrim(_cNomeGVen)) 
		AADD(_aItens,(_cAlias)->A1_I_REGIA) 
		AADD(_aItens,_cNumNFRM)

		_cDevFab := "N"
		_cNfDeb  := "N"
		
		AADD(_aZDS,_aItens)//.CSV e XML *********************************************
		
		aMemo :=StrTokArr(ALLTRIM(ZDS->ZDS_NFORIG),CHR(13)+CHR(10))
		IF LEN(aMemo) > 0 .AND. nOpcao = 3 // XML ******************************************
			FOR _nCpo := 1 TO LEN(aMemo)
		        _aItens:={}
		        AADD(_aItens,ZDS->ZDS_FILIAL)
		        AADD(_aItens,ZDS->ZDS_DOC   )
		        AADD(_aItens,ZDS->ZDS_SERIE )
		        AADD(_aItens,ZDS->ZDS_FORNEC)
		        AADD(_aItens,ZDS->ZDS_LOJA  )
				aDados:=StrTokArr(ALLTRIM(aMemo[_nCpo]),"-")
				IF LEN(aDados) > 4//As veses tem traço [-] no nome do vendedor
					AADD(_aItens,aDados[1])
					AADD(_aItens,ALLTRIM(aDados[2]))
					AADD(_aItens,ALLTRIM(aDados[3]))
					AADD(_aItens,ALLTRIM(aDados[4])+" - "+aDados[5])//As veses tem traço [-] no nome do vendedor
				ELSEIF LEN(aDados) > 3
					AADD(_aItens,aDados[1])
					AADD(_aItens,aDados[2])
					AADD(_aItens,aDados[3])
					AADD(_aItens,aDados[4])
				ELSE
					AADD(_aItens,"")
					AADD(_aItens,"")
					AADD(_aItens,"")
					AADD(_aItens,"")
				ENDIF
		        IF LEN(_aItens) = 9
		           AADD(_aNFO,_aItens)//SÓ XML ******************************************
		        ENDIF   
			NEXT
		ENDIF

        (_cAlias)->(DBSKIP())
        
    ENDDO
    
    (_cAlias)->(DBCloseArea())

	IF LEN(_aZDS) > 0
		
		_aCab:={}
		
		IF nOpcao = 2//.CSV (2-NÃO USA MAIS)*********************************************

		    FOR _nCpo:= 1 TO LEN(_aSX3)
                IF _aSX3[_nCpo] = "ZDS_STATUS"
		           AAdd(_aCab,"Status")
                ENDIF
		    	AAdd(_aCab,Getsx3cache(_aSX3[_nCpo],"X3_TITULO"))
		    NEXT
            AAdd(_aCab,"Transportadora")//CAMPOS NOVOS
            AAdd(_aCab,"Carga")         //CAMPOS NOVOS

			DlgToExcel( { { "ARRAY" , cCadastro , _aCab , _aZDS } } )//GERA ARQUIVO .CSV *********************************************
			
		ELSEIF nOpcao = 3//XML ******************************************
		    IF !_lXMLTambem 
		       AAdd(_aCab,"Status")
			ENDIF
		    FOR _nCpo:= 1 TO LEN(_aSX3)
			    IF _lXMLTambem .AND. _aSX3[_nCpo] = "ZDS_STATUS"
		           AAdd(_aCab,"Status")
                ENDIF
		    	AAdd(_aCab,Getsx3cache(_aSX3[_nCpo],"X3_TITULO"))
				IF _aSX3[_nCpo] = "ZDS_OBSGER"
				   _aCab[LEN(_aCab)]:="Obs. Financeira"
				ELSEIF _aSX3[_nCpo] = "ZDS_OBSABA"
				   _aCab[LEN(_aCab)]:="Obs. Fiscal"
				ENDIF                
		    NEXT

			_aCab2:={}
			For _nCpo := 1 to len(_aCab)
				// Alinhamento: 1-Left   ,2-Center,3-Right
				// Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
				//          Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
				IF ALLTRIM(_aCab[_nCpo]) = ALLTRIM( Getsx3cache("ZDS_VLRTOT","X3_TITULO") )
				   Aadd(_aCab2,{_aCab[_nCpo]   ,3           ,3         ,.T.})
				ELSE
				   Aadd(_aCab2,{_aCab[_nCpo]   ,1           ,1         ,.F.})
				ENDIF   
			Next
			Aadd(_aCab2,{"Transportadora"      ,1           ,1         ,.F.})//CAMPOS NOVOS
			Aadd(_aCab2,{"Carga"               ,2           ,1         ,.F.})//CAMPOS NOVOS
			Aadd(_aCab2,{"Dt.Entrega"               ,2           ,1         ,.F.})//CAMPOS NOVOS
			Aadd(_aCab2,{"Dt.Canhoto"               ,2           ,1         ,.F.})//CAMPOS NOVOS
			Aadd(_aCab2,{"Anal.Devolução"             ,2           ,1         ,.F.})//CAMPOS NOVOS CANHOTO
			Aadd(_aCab2,{"Oper. Triangular"             ,2           ,1         ,.F.})//CAMPOS OPERACAO TRIANGULAR
			Aadd(_aCab2,{"Troca Nota"             ,2           ,1         ,.F.})//CAMPOS NOVOS TROCA NOTA S/N
			Aadd(_aCab2,{"Fil.Carreg."             ,2           ,1         ,.F.})//CAMPOS NOVOS TROCA FILIAL CARREGAMENTO
			Aadd(_aCab2,{"Operador Logist."             ,2           ,1         ,.F.})//CAMPOS NOVOS OPERADOR LOGISTICO
			Aadd(_aCab2,{"NF Troca Nota"              ,2           ,1         ,.F.})//CAMPOS NOVOS 
			Aadd(_aCab2,{"Dev.Fabric?."             ,2           ,1         ,.F.})//CAMPOS NOVOS DEV.FÁBRICA?
			Aadd(_aCab2,{"NF.Deb?"             ,2           ,1         ,.F.})//CAMPOS NOVOS NF DÉBITO?
            Aadd(_aCab2,{"Rede"                ,2           ,1         ,.F.})//CAMPOS NOVOS 
			Aadd(_aCab2,{"Região"              ,2           ,1         ,.F.})//CAMPOS NOVOS 
			Aadd(_aCab2,{"NF Remessa"          ,2           ,1         ,.F.})//CAMPOS NOVOS 

			//AAdd(_aCab,"Rede")
			//AAdd(_aCab,"Região")


			_aCab3:={}
    	    // Alinhamento: 1-Left   ,2-Center,3-Right
    	    // Formatação.: 1-General,2-Number,3-Monetário,4-DateTime
			//           Titulo das Colunas ,Alinhamento ,Formatação, Totaliza?
			Aadd(_aCab3,{"Filial"           ,2           ,1         ,.F.})
			Aadd(_aCab3,{"Numero"           ,2           ,1         ,.F.})
			Aadd(_aCab3,{"Serie"            ,1           ,1         ,.F.})
			Aadd(_aCab3,{"Cliente"          ,2           ,1         ,.F.})
			Aadd(_aCab3,{"Loja"             ,2           ,1         ,.F.})
			Aadd(_aCab3,{"Nota/Serie Origem",2           ,1         ,.F.})
			Aadd(_aCab3,{"Emisssao"         ,2           ,1         ,.F.})
			Aadd(_aCab3,{"Cod. Vend."       ,2           ,1         ,.F.})
			Aadd(_aCab3,{"Nome do Vendedor" ,1           ,1         ,.F.})

            _aCab1:={}
			Aadd(_aCab1,{"Documentos"  ,_aCab2})
			Aadd(_aCab1,{"Notas Origem",_aCab3})
		    _aDetalhe:={_aZDS,_aNFO}
			         //  _cNomeArq,_cDiretorio,_cTitulo,_cNomePlan,_aCabecalho,_aDetalhe,_lLeTabTemp,_cAliasTab,_aCampos,_lScheduller,_lCriaPastas,_aPergunte,_lEnviaEmail,_lXLSX)
			U_ITGEREXCEL(         ,           ,cCadastro,          ,_aCab1     ,_aDetalhe,           ,          ,        ,            ,.T.         ,         ,            ,_lXLSX)
			//XML ******************************************
        ENDIF
	ELSE
	    U_ITMSG("Não há registros para o filtro informado",'Atenção!',,3)
    ENDIF   

ELSEIF nOpcao = 1 //IMPORTAR DADOS *************************************************************************************************************************
	
	_cQuery1+= " SELECT SDS.R_E_C_N_O_ SDS_REC  "
	_cQuery1+= "		FROM " + RetSqlName("SDS")+" SDS "
	_cQuery1+= "  WHERE SDS.D_E_L_E_T_ = ' ' "
	_cQuery1+= "    AND SDS.DS_TIPO     = 'D' "
	_cQuery1+= "    AND SDS.DS_FORMUL   = 'N' "
	_cQuery1+= "    AND SDS.DS_STATUS  <> 'E' "//Só ignora as com ocorrecias
	// Filtra Emissao
	IF !EMPTY(MV_PAR02)
		_cQuery1 += "  AND SDS.DS_EMISSA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	ELSEIF !EMPTY(MV_PAR01)
		_cQuery1 += "  AND SDS.DS_EMISSA >= '" + DTOS(MV_PAR01) + "'"
	ENDIF
	If !EMPTY(MV_PAR03)
		IF LEN(ALLTRIM(MV_PAR03)) > 2
			_cQuery1 += " AND SDS.DS_FILIAL IN " + FormatIn(ALLTRIM(MV_PAR03),";")
		ELSE
			_cQuery1 += " AND SDS.DS_FILIAL = '"+ALLTRIM(MV_PAR03)+"' "
		Endif
	Endif

    //======================
	// Filtro por cliente
	//======================
    If !Empty(MV_PAR06)
       _cQuery1 += " AND SDS.DS_FORNEC >= '" + MV_PAR06 + "' " 
	EndIf

	If !Empty(MV_PAR07)
       _cQuery1 += " AND SDS.DS_LOJA >= '" + MV_PAR07 + "' "  
	EndIf 

	If !Empty(MV_PAR08)
       _cQuery1 += " AND SDS.DS_FORNEC <= '" + MV_PAR08 + "' " 
	EndIf 

	If !Empty(MV_PAR09)
       _cQuery1 += " AND SDS.DS_LOJA <= '" + MV_PAR09 + "' "  
	EndIf 

	_cQuery1 += " ORDER BY R_E_C_N_O_ "
	
	MPSysOpenQuery( _cQuery1 , _cAlias )
	
	oProc:cCaption := ("Contando os dados lidos...")
	ProcessMessages()
	DBSELECTAREA(_cAlias)
	(_cAlias)->(Dbgotop())
	_nConta:=_cTot := 0
	COUNT TO _cTot
	_cTot:=ALLTRIM(STR(_cTot))
	_nTam:=LEN(_cTot)
	(_cAlias)->(Dbgotop())
	
	SA3->(DBSETORDER(1))
	SF2->(DBSETORDER(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	ZDS->(DBSETORDER(4)) //ZDS_FILIAL+ZDS_CHAVNF
	SDT->(DBSETORDER(2)) //SDT->DS_FILIAL+SDT->DT_FORNEC+SDT->DT_LOJA+SDT->DT_DOC+SDT->DT_SERIE
	
	DO WHILE (_cAlias)->(!EOF())
		
		_nConta++
		oProc:cCaption := ("Processando Dados: "+ STRZERO(_nConta,_nTam) +" de "+ _cTot)
		ProcessMessages()
		
		SDS->(DBGOTO((_cAlias)->SDS_REC))
		IF !(lAchou:=ZDS->(DBSEEK(SDS->DS_FILIAL+SDS->DS_CHAVENF)))
			IF SDS->DS_STATUS $ 'P/E'//Não inclui Com Ocorrecias e Geradas, só le na alteração
				(_cAlias)->(DBSKIP())
				LOOP//Loop Tem que ser fora do Begin Transaction
			ENDIF
		ENDIF
		
		Begin Transaction
		
		IF lAchou
			nAlt++
			ZDS->(RECLOCK("ZDS",.F.))
		ELSE
			nInc++
			ZDS->(RECLOCK("ZDS",.T.))
			ZDS->ZDS_FILIAL:=SDS->DS_FILIAL
			ZDS->ZDS_STATUS:=SDS->DS_STATUS
			ZDS->ZDS_DOC   :=SDS->DS_DOC
			ZDS->ZDS_SERIE :=SDS->DS_SERIE
			ZDS->ZDS_EMISSA:=SDS->DS_EMISSA
			ZDS->ZDS_FORNEC:=SDS->DS_FORNEC
			ZDS->ZDS_LOJA  :=SDS->DS_LOJA
			ZDS->ZDS_CNPJ  :=SDS->DS_CNPJ
			ZDS->ZDS_EST   :=SDS->DS_EST
			ZDS->ZDS_CHAVNF:=SDS->DS_CHAVENF
			ZDS->ZDS_VLRTOT:=((SDS->DS_VALMERC+SDS->DS_FRETE+SDS->DS_SEGURO)-SDS->DS_DESCONTO)
			ZDS->ZDS_STUEMI:= "5" // 5=Vazio
		ENDIF
		IF SA1->(DBSEEK(xFilial("SA1")+SDS->DS_FORNEC+SDS->DS_LOJA))
			ZDS->ZDS_CLIEMA:=SA1->A1_I_EMAIL
			ZDS->ZDS_CLIMUN:=SA1->A1_MUN
		ENDIF
		cDS_NFORIG:=""
		IF SDT->(DBSEEK(SDS->DS_FILIAL+SDS->DS_FORNEC+SDS->DS_LOJA+SDS->DS_DOC+SDS->DS_SERIE)) .AND. !EMPTY(SDT->DT_NFORI)
			DO WHILE SDT->(!EOF()) .AND. SDT->DT_FILIAL+SDT->DT_FORNEC+SDT->DT_LOJA+SDT->DT_DOC+SDT->DT_SERIE ==;
				                         SDS->DS_FILIAL+SDS->DS_FORNEC+SDS->DS_LOJA+SDS->DS_DOC+SDS->DS_SERIE
				
				//SF2->(DBSEEK(xFilial("SF2")+SDT->DT_NFORI+SDT->DT_SERIORI))
				SF2->(DBSEEK(SDT->DT_FILIAL+SDT->DT_NFORI+SDT->DT_SERIORI))
				SA3->(DBSEEK(xFilial("SA3")+SF2->F2_VEND1))
				//cDS_NFORIG+=SDT->DT_NFORI+" "+SDT->DT_SERIORI+" - "+DTOC(SF2->F2_EMISSAO)+" - "+SF2->F2_VEND1+" - "+ALLTRIM(SA3->A3_NOME)
				cDS_NFORIG+=SDT->DT_NFORI+" "+SDT->DT_SERIORI+" - "+DTOC(SF2->F2_EMISSAO)
				
				SDT->(DBSKIP())
				IF SDT->(!EOF()) .AND. SDT->DT_FILIAL+SDT->DT_FORNEC+SDT->DT_LOJA+SDT->DT_DOC+SDT->DT_SERIE ==;
				                       SDS->DS_FILIAL+SDS->DS_FORNEC+SDS->DS_LOJA+SDS->DS_DOC+SDS->DS_SERIE//Se tiver mais um, joga ENTER
				   cDS_NFORIG+=CHR(13)+CHR(10)
				ENDIF
			ENDDO
		ENDIF
		ZDS->ZDS_NFORIG:=cDS_NFORIG
		ZDS->ZDS_STATUS:=SDS->DS_STATUS
		ZDS->(MSUNLOCK())
		
		End Transaction
		
		(_cAlias)->(DBSKIP())
		
	ENDDO
	
	(_cAlias)->(DBCloseArea())
	
	U_ITMSG(ALLTRIM(STR(nInc))+" Regitros Incluidos"+CHR(13)+CHR(10)+;
            ALLTRIM(STR(nAlt))+" Regitros Atualizados"+CHR(13)+CHR(10),'Atenção!',,2)
	
ENDIF

RestArea(aArea)

RETURN .T.

/*
===============================================================================================================================
Programa----------: MOMS45AM()
Autor-------------: ALEX WALLAUER
Data da Criacao---: 06/09/2019
===============================================================================================================================
Descrição---------: Alteração em Massa
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function MOMS45AM(oProc) As Logical
Local nAlt As Numeric
Local _nCpo As Numeric
Local _nCont As Numeric
Local _cTot As Character
Local _nTam As Numeric

nAlt   := 0
_nCpo  := 0
_nCont :=0
_cTot  := ALLTRIM(STR(LEN(_aDados)))
_nTam  := LEN(_cTot)

ZDS->(DBSETORDER(4))

FOR _nCpo := 1 TO LEN(_aDados)

	_nCont++		
	oProc:cCaption := ("Processando Dados: "+ STRZERO(_nCont,_nTam) +" de "+ _cTot)
	ProcessMessages() 
	
	IF _aDados[_nCpo,1] 
	   _aDados[_nCpo,2]:=STRTRAN(_aDados[_nCpo,2]," ","")
       IF ZDS->(DBSEEK( _aDados[_nCpo,2] ))

         _aDadAlt:= {}

         aAdd( _aDadAlt , { "ZDS_FILIAL"   ,ZDS->ZDS_FILIAL   ,00,.F.} )
         aAdd( _aDadAlt , { "ZDS_DOC"      ,ZDS->ZDS_DOC      ,00,.F.} )
         aAdd( _aDadAlt , { "ZDS_SERIE"    ,ZDS->ZDS_SERIE    ,00,.F.} )
         aAdd( _aDadAlt , { "ZDS_EMISSA"   ,ZDS->ZDS_EMISSA   ,00,.F.} )
         aAdd( _aDadAlt , { "ZDS_FORNEC"   ,ZDS->ZDS_FORNEC   ,00,.F.} )
         aAdd( _aDadAlt , { "ZDS_LOJA"     ,ZDS->ZDS_LOJA     ,00,.F.} )
         aAdd( _aDadAlt , { "ZDS_CNPJ"     ,ZDS->ZDS_CNPJ     ,00,.F.} )
         aAdd( _aDadAlt , { "ZDS_EST"      ,ZDS->ZDS_EST      ,00,.F.} )
         aAdd( _aDadAlt , { "ZDS_CLIMUN"   ,ZDS->ZDS_CLIMUN   ,00,.F.} )
         aAdd( _aDadAlt , { "ZDS_CLIEMA"   ,ZDS->ZDS_CLIEMA   ,00,.F.} )
         aAdd( _aDadAlt , { "ZDS_VLRTOT"   ,ZDS->ZDS_VLRTOT   ,00,.F.} )
         aAdd( _aDadAlt , { "ZDS_CHAVNF"   ,ZDS->ZDS_CHAVNF   ,00,.F.} )
         aAdd( _aDadAlt , { "ZDS_NFORIG"   ,ZDS->ZDS_NFORIG   ,00,.F.} )
         aAdd( _aDadAlt , { "ZDS_STUEMI"   ,ZDS->ZDS_STUEMI   ,00,.F.} )
         aAdd( _aDadAlt , { "ZDS_STUSIT"   ,ZDS->ZDS_STUSIT   ,00,.F.} )
         aAdd( _aDadAlt , { "ZDS_OBSABA"   ,ZDS->ZDS_OBSABA   ,00,.F.} )
         aAdd( _aDadAlt , { "ZDS_OBSGER"   ,ZDS->ZDS_OBSGER   ,00,.F.} )
         aAdd( _aDadAlt , { "ZDS_OBSCOM"   ,ZDS->ZDS_OBSCOM   ,00,.F.} )
         aAdd( _aDadAlt , { "ZDS_STATUS"   ,ZDS->ZDS_STATUS   ,00,.F.} )       

		  ZDS->(RECLOCK("ZDS",.F.))
		  
		  If !EMPTY(_aDados[_nCpo,3])
		     IF _aDados[_nCpo,3] = "0"
	            ZDS->ZDS_STUEMI := "5" // "" // 5=Vazio 
			 ELSE
	            ZDS->ZDS_STUEMI := If(Empty(_aDados[_nCpo,3]),"5",_aDados[_nCpo,3])
			 ENDIF
		  Else 
             ZDS->ZDS_STUEMI := "5" // 5=Vazio  
		  EndIf    

		  IF !EMPTY(_aDados[_nCpo,4])
		     IF _aDados[_nCpo,4] = "0"
	            ZDS->ZDS_STUSIT:=""
			 ELSE
	            ZDS->ZDS_STUSIT:=_aDados[_nCpo,4]
			 ENDIF
		  ENDIF    
		  IF !EMPTY(_aDados[_nCpo,5])
		     ZDS->ZDS_OBSABA:=_aDados[_nCpo,5] // STRTRAN(_aDados[_nCpo,5],CHR(13)+CHR(10)," ")//
		  ENDIF    
		  IF !EMPTY(_aDados[_nCpo,6])
		     ZDS->ZDS_OBSGER:=_aDados[_nCpo,6] // STRTRAN(_aDados[_nCpo,6],CHR(13)+CHR(10)," ")//
		  ENDIF    
		  IF !EMPTY(_aDados[_nCpo,7])
		     ZDS->ZDS_OBSCOM:=_aDados[_nCpo,7] // STRTRAN(_aDados[_nCpo,7],CHR(13)+CHR(10)," ")//
		  ENDIF    
          ZDS->(MSUNLOCK())      

          IF !(EMPTY(_aDados[_nCpo,3]+_aDados[_nCpo,4]+_aDados[_nCpo,5]+_aDados[_nCpo,6]+_aDados[_nCpo,7]))
		     nAlt++
		  ENDIF

        U_ITGrvLog( _aDadAlt , 'ZDS' , 1 , _cChave , "A" , RetCodUsr(),Date(),Time() )   
       ENDIF
	ENDIF

NEXT

U_ITMSG(ALLTRIM(STR(LEN(_aDados)))+" Regitros Lidos"+CHR(13)+CHR(10)+;
        ALLTRIM(STR(nAlt))+" Regitros Atualizados"+CHR(13)+CHR(10),'Atenção!',,2)

RETURN .T.


/*
===============================================================================================================================
Programa----------: MOMS45LE()
Autor-------------: ALEX WALLAUER
Data da Criacao---: 06/09/2019
===============================================================================================================================
Descrição---------: LEGENDA DO Monitor de devoluções Italac
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER Function MOMS45LE()
Local aCores As Array

aCores	:= {}

aAdd(aCores,{'BR_AMARELO'  ,"Documento Nao Gerado"   })
aAdd(aCores,{'BR_VERDE'    ,"Documento Gerado"       })	  
aAdd(aCores,{'BR_PRETO'    ,"Documento com Ocorrencia"})
aAdd(aCores,{'BR_VERMELHO' ,"Documento Excluido"     })

BrwLegenda("Legenda","Legenda",aCores) //-- Legenda

Return

/*
===============================================================================================================================
Programa----------: MOMS045L()
Autor-------------: ALEX WALLAUER
Data da Criacao---: 06/09/2019
===============================================================================================================================
Descrição---------: LEGENDA DO Monitor de devoluções Italac
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Status
===============================================================================================================================
*/
USER Function MOMS045L() As Character
LOCAL cStatus As Character

cStatus := "D"// Documento Nao Gerado

SDS->(DBSETORDER(2)) //DS_FILIAL+DS_CHAVENF
IF !SDS->(DBSEEK(ZDS->ZDS_FILIAL+ZDS->ZDS_CHAVNF))
   cStatus:="X"// Documento Excluido
ELSEIF SDS->DS_STATUS = "P"
   cStatus:="P"// Documento Gerado
ELSEIF SDS->DS_STATUS = "E"
   cStatus:="E"// Documento c/ Ocorrência
ENDIF

Return cStatus


/*
===============================================================================================================================
Programa----------: MOMS045T
Autor-------------: Igor Melgaço 
Data da Criacao---: 20/09/2024
===============================================================================================================================
Descrição---------: Rotina de Alteração do Registro
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: 	
===============================================================================================================================
*/
User Function MOMS045A()
Local aBtnUsr As Array

aBtnUsr := {}

_aDadAlt := {}

aAdd( aBtnUsr , { "Historico de Alteracoes","Historico de Alteracoes", {|| U_MOMS045() } } )

aAdd( _aDadAlt , { "ZDS_FILIAL"   ,ZDS->ZDS_FILIAL   ,00,.F.} )
aAdd( _aDadAlt , { "ZDS_DOC"      ,ZDS->ZDS_DOC      ,00,.F.} )
aAdd( _aDadAlt , { "ZDS_SERIE"    ,ZDS->ZDS_SERIE    ,00,.F.} )
aAdd( _aDadAlt , { "ZDS_EMISSA"   ,ZDS->ZDS_EMISSA   ,00,.F.} )
aAdd( _aDadAlt , { "ZDS_FORNEC"   ,ZDS->ZDS_FORNEC   ,00,.F.} )
aAdd( _aDadAlt , { "ZDS_LOJA"     ,ZDS->ZDS_LOJA     ,00,.F.} )
aAdd( _aDadAlt , { "ZDS_CNPJ"     ,ZDS->ZDS_CNPJ     ,00,.F.} )
aAdd( _aDadAlt , { "ZDS_EST"      ,ZDS->ZDS_EST      ,00,.F.} )
aAdd( _aDadAlt , { "ZDS_CLIMUN"   ,ZDS->ZDS_CLIMUN   ,00,.F.} )
aAdd( _aDadAlt , { "ZDS_CLIEMA"   ,ZDS->ZDS_CLIEMA   ,00,.F.} )
aAdd( _aDadAlt , { "ZDS_VLRTOT"   ,ZDS->ZDS_VLRTOT   ,00,.F.} )
aAdd( _aDadAlt , { "ZDS_CHAVNF"   ,ZDS->ZDS_CHAVNF   ,00,.F.} )
aAdd( _aDadAlt , { "ZDS_NFORIG"   ,ZDS->ZDS_NFORIG   ,00,.F.} )
aAdd( _aDadAlt , { "ZDS_STUEMI"   ,ZDS->ZDS_STUEMI   ,00,.F.} )
aAdd( _aDadAlt , { "ZDS_STUSIT"   ,ZDS->ZDS_STUSIT   ,00,.F.} )
aAdd( _aDadAlt , { "ZDS_OBSABA"   ,ZDS->ZDS_OBSABA   ,00,.F.} )
aAdd( _aDadAlt , { "ZDS_OBSGER"   ,ZDS->ZDS_OBSGER   ,00,.F.} )
aAdd( _aDadAlt , { "ZDS_OBSCOM"   ,ZDS->ZDS_OBSCOM   ,00,.F.} )
aAdd( _aDadAlt , { "ZDS_STATUS"   ,ZDS->ZDS_STATUS   ,00,.F.} )

 //AxAltera( <cAlias>, <nReg>         , <nOpc>, <aAcho>, <aCpos>, <nColMens>, <cMensagem>, <cTudoOk>, <cTransact>       , <cFunc>, <aButtons>, <aParam>, <aAuto>, <lVirtual>, <lMaximized>)
   AxAltera( "ZDS"   , ZDS->(Recno()) , 4     ,        ,        ,           ,            ,          ,  "U_MOMS045T()"   ,        ,  )

Return

/*
===============================================================================================================================
Programa----------: MOMS045T
Autor-------------: Igor Melgaço 
Data da Criacao---: 20/09/2024
===============================================================================================================================
Descrição---------: Rotina de Gravção do Log
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: 	
===============================================================================================================================
*/
User Function MOMS045T()
Local  _cChave As Character

_cChave := ZDS->(ZDS_FILIAL+ZDS_DOC+ZDS_SERIE+ZDS_FORNEC+ZDS_LOJA )

//ITGrvLog( _aAux , _cAlias , _nOrdem , _cChave , _cOpcLog , _cCodUsr , _dDatLog , _cHorLog )
U_ITGrvLog( _aDadAlt , 'ZDS' , 1 , _cChave , "A" , RetCodUsr(),Date(),Time() )

Return Nil 

/*
===============================================================================================================================
Programa----------: MOMS045H
Autor-------------: Igor Melgaço 
Data da Criacao---: 20/09/2024
===============================================================================================================================
Descrição---------: Rotina de Consulta do  Histórico
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: 	
===============================================================================================================================
*/
User Function MOMS045H()
Local _cChave As Character
Local _cTexto As Character

	_cChave := ZDS->(ZDS_FILIAL+ZDS_DOC+ZDS_SERIE+ZDS_FORNEC+ZDS_LOJA )
	_cTexto := "Documento "+Alltrim(ZDS->ZDS_DOC)+" Serie "+ZDS->ZDS_SERIE+" Fornecedor "+ZDS->ZDS_FORNEC+"-"+ZDS->ZDS_LOJA
   
	U_MOMS045G( _cChave,_cTexto,"ZDS",1  )

Return Nil 

/*
===============================================================================================================================
Programa----------: MOMS045HIS
Autor-------------: Igor Melgaço 
Data da Criacao---: 20/09/2024
===============================================================================================================================
Descrição---------: Monta a tela detalhada do Histórico de Alterações do Cadastro 
===============================================================================================================================
Parametros--------: _cChave, _cTexto
===============================================================================================================================
Retorno-----------: .T. - Permite seleção .F. - Não permite a seleção	
===============================================================================================================================
*/
User Function MOMS045G( _cChave As Character, _cTexto  As Character,cAlias  As Character,_nOrdem As Numeric)
Local oDlg As Object
Local oLbxTOP As Object
Local oLbxDET As Object
Local aPosObj As Array
Local aObjects As Array
Local aSize  As Array
Local bMontaTOP As Block
Local bMontaDET As Block

Local oBar As Object
Local oBold	As Object
Local oScrPanel As Object
Local aBtn As Array
Local aCabLbxTOP As Array
Local aCabLbxDET As Array

Default  cAlias   := "ZDS"
Default _nOrdem   := 1

Private	nDvPosAnt As Numeric
Private	cCadastro As Character

oDlg		:= Nil
oLbxTOP		:= Nil
oLbxDET		:= Nil
aPosObj   	:= {}
aObjects  	:= {}
aSize     	:= MsAdvSize()
bMontaTOP	:= Nil
bMontaDET	:= Nil

oBar			:= Nil
aBtn 	    	:= Array(02)
oBold			:= Nil
oScrPanel		:= Nil

aCabLbxTOP	:= { "Chave", "Campo" , "Descrição" , "Última Alt." } // 04

aCabLbxDET	:= { "Data"				,; // 01
                         "Hora"				,; // 02
                         "Usuário"			,; // 03
                         "Nome Usr."		,; // 04
                         "Cont. Orig."		,; // 05
                         "Cont. Alt."		 } // 06

nDvPosAnt := 0
cCadastro := "Histórico de Alterações da chave de registro - ["+ _cChave +"]" 


bMontaTOP		:= { || Processa({|lEnd| MOMS045LOG( @oLbxTOP , _cChave, cAlias ) }) }
bMontaDET		:= { || MOMS045DET( @oLbxDET ,cAlias, oLbxTOP:aArray[oLbxTOP:nAt][01] , oLbxTOP:aArray[oLbxTOP:nAt][02] ) }

//================================================================================
//| Verifica se existe histórico de alterações                                   |
//================================================================================
DBSelectArea("Z07")
Z07->( DBSetOrder(1) )
IF !Z07->( DBSeek( xFilial("Z07") + cAlias + Str(_nOrdem,2,0) + _cChave ) )
	MessageBox( "A Chave ["+ _cChave +"] não possui histórico de alterações." , "Atenção!" , 0 )
	Return()
EndIF
 
aAdd( aObjects, { 100 , 025 , .T. , .F. , .T. } )
aAdd( aObjects, { 100 , 070 , .T. , .F. } )
aAdd( aObjects, { 100 , 100 , .T. , .T. } )

aInfo   := { aSize[1] , aSize[2] , aSize[3] , aSize[4] , 3 , 2 }
aPosObj := MsObjSize( aInfo , aObjects )

DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 to aSize[6],aSize[5] Of oMainWnd Pixel

	aPosObj[01][01] += 12
	aPosObj[02][01] += 10
	aPosObj[02][03] += 10
	aPosObj[03][01] += 10
	aPosObj[03][03] += 10
	
	//================================================================================
	//| Imprime o código e o nome do Cliente                                         |
	//================================================================================
	@ aPosObj[01][01],aPosObj[01][02] MSPANEL oScrPanel PROMPT "" SIZE aPosObj[01][03],aPosObj[01][04] OF oDlg LOWERED
	
	@ 004 , 004 SAY _cTexto 		SIZE 300,07 OF oScrPanel PIXEL FONT oBold COLOR CLR_BLUE
	
	//================================================================================
	//| Monta o resumo das alterações do cadastro                                    |
	//================================================================================
	@aPosObj[02][01],aPosObj[02][02] To aPosObj[02][03],aPosObj[02][04] LABEL "Campos Alterados" COLOR CLR_HBLUE OF oDlg PIXEL
	
	@aPosObj[02][01]+7,aPosObj[02][02]+4 	Listbox oLbxTOP Fields	;
											HEADER 	""		 		;
											On DbLCLICK ( Nil )		;
											Size aPosObj[02][04]-10,( aPosObj[02][03] - aPosObj[02][01] ) - 10 Of oDlg Pixel
	
	oLbxTOP:AHeaders	:= aClone(aCabLbxTOP)
	oLbxTOP:bChange		:= { || Eval(bMontaDET) }
	
	Eval(bMontaTOP)
	
	//================================================================================
	//| Monta os detalhes das alterações do cadastro                                 |
	//================================================================================
	@aPosObj[03][01],aPosObj[03][02] To aPosObj[03][03],aPosObj[03][04] LABEL "Histórico dos Campos" COLOR CLR_HBLUE OF oDlg PIXEL
	
	@aPosObj[03][01]+7,aPosObj[03][02]+4 	Listbox oLbxDET Fields;
											HEADER 	""		 		;
											On DbLCLICK ( Nil )		;
											Size aPosObj[03][04]-10,( aPosObj[03][03] - aPosObj[03][01] ) - 10 Of oDlg Pixel
					
	oLbxDET:AHeaders := aClone(aCabLbxDET)
	
	Eval(bMontaDET)
	
	//================================================================================
	//| Monta a barra de botões da tela                                              |
	//================================================================================
	DEFINE BUTTONBAR oBar SIZE 25,25 3D OF oDlg
	
	DEFINE BUTTON aBtn[01] RESOURCE PmsBExcel()[1] OF oBar GROUP ACTION DlgToExcel({{"ARRAY","",oLbxPM7:AHeaders,oLbxPM7:aArray}})	TOOLTIP "Exportar para Planilha..."
	aBtn[01]:cTitle := ""
	
	DEFINE BUTTON aBtn[02] RESOURCE "FINAL" 		OF oBar GROUP ACTION oDlg:End() 													TOOLTIP "Sair da Tela..."
	aBtn[02]:cTitle := ""
	
	oDlg:lMaximized := .T.
	
ACTIVATE MSDIALOG oDlg CENTERED

Return()


/*
===============================================================================================================================
Programa----------: MOMS045LOG
Autor-------------: Igor Melgaço 
Data da Criacao---: 20/09/2024
===============================================================================================================================
Descrição---------: Monta estrutura do Log de Alterações 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T. - Permite seleção .F. - Não permite a seleção	
===============================================================================================================================
*/
Static Function MOMS045LOG( oLbxAux As Object, cChave As Character,cAlias As Character)

Local _cQuery As Character
Local _cAlias As Character
Local _aLbxAux As Array
Local _nTotReg As Numeric
Local _nCont As Numeric
 
Default cAlias := "ZDS"

_cQuery	 := ""
_cAlias	 := GetNextAlias()
_aLbxAux := {}
_nTotReg := 0
_nCont	 := 0

//================================================================================
//| Consulta para buscar o resumo das alterações do cadastro                     |
//================================================================================
_cQuery := " SELECT "
_cQuery += "	Z07.Z07_CHAVE		AS CHAVE,	"
_cQuery += " 	Z07.Z07_CAMPO 		AS CAMPO,	"
_cQuery += " 	MAX( Z07.Z07_DATA )	AS DT_ULT	"
_cQuery += " FROM "+ RetSqlName("Z07") +" Z07 "
_cQuery += " WHERE "
_cQuery += " 		Z07.D_E_L_E_T_  = ' ' "
_cQuery += " AND	Z07.Z07_ALIAS	= '"+ cAlias +"' "
_cQuery += " AND	Z07.Z07_CHAVE	= '"+ cChave +"' "
_cQuery += " GROUP BY Z07.Z07_CHAVE,  Z07.Z07_DATA,  Z07.Z07_CAMPO "
_cQuery += " ORDER BY Z07.Z07_CHAVE , Z07.Z07_DATA,  Z07.Z07_CAMPO "    
 
_cQuery	:= ChangeQuery(_cQuery)

MPSysOpenQuery( _cQuery , _cAlias)

TcSetField( _cAlias , "Z07.Z07_DATA" , "D" , 8 , 0 )

DBSelectArea(_cAlias)
(_cAlias)->(DBGoTop()) 

(_cAlias)->( dbEval( { || _nTotReg++ } ) )

ProcRegua(_nTotReg)

(_cAlias)->(DBGoTop())                                                                                   

//================================================================================
//| Grava os dados do Resumo                                                     |
//================================================================================
While (_cAlias)->(!Eof())
	
	aAdd( _aLbxAux , {	(_cAlias)->CHAVE								   		   ,; // 01
						      (_cAlias)->CAMPO							   		      ,; // 02
						      Posicione("SX3",2,(_cAlias)->CAMPO,"X3_DESCRIC")	,; // 03
                       	(_cAlias)->DT_ULT									         }) // 04

   _nCont++
   IncProc("Montando estrutura "+StrZero(_nCont,6)+" de "+StrZero(_nTotReg,6)  )
   (_cAlias)->( DBSkip() )
EndDo

(_cAlias)->( DBCloseArea() )

//================================================================================
//| Monta o objeto do ListBox                                                    |
//================================================================================
If	Len(_aLbxAux) > 0 .And. ValType(oLbxAux) == "O"
                     
	oLbxAux:SetArray(_aLbxAux)
	oLbxAux:bLine:={||{	_aLbxAux[oLbxAux:nAt][01]	,; // 01
						_aLbxAux[oLbxAux:nAt][02]	,; // 02
						_aLbxAux[oLbxAux:nAt][03]	,; // 03
						_aLbxAux[oLbxAux:nAt][04]	}} // 04
	
	oLbxAux:Refresh()

EndIf

Return()

/*
===============================================================================================================================
Programa----------: MOMS045DET
Autor-------------: Igor Melgaço 
Data da Criacao---: 20/09/2024
===============================================================================================================================
Descrição---------: Monta estrutura de Detalhes do Log de Alterações do Campo
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T. - Permite seleção .F. - Não permite a seleção	
===============================================================================================================================
*/
Static Function MOMS045DET( oLbxAux As Object,cAlias As Character, cChave As Character , cCampo As Character )

Local _cQuery As Character
Local _cAlias As Character
Local _aLbxAux As Array
Local _nTotReg As Numeric
Local _nCont As Numeric

_cQuery	 := ""
_cAlias	 := GetNextAlias()
_aLbxAux := {}
_nTotReg := 0
_nCont	 := 0

//================================================================================
//| Consulta para buscar os detalhes das alterações dos campos                   |
//================================================================================
_cQuery := " SELECT "
_cQuery += " 	Z07.Z07_DATA	AS DT_ALT	, "
_cQuery += " 	Z07.Z07_HORA	AS HORA		, "
_cQuery += " 	Z07.Z07_CODUSU	AS CODUSU	, "
_cQuery += " 	Z07.Z07_CONORG	AS CONT_ORG	, "
_cQuery += " 	Z07.Z07_CONALT	AS CONT_ALT	  "
_cQuery += " FROM "+ RetSqlName("Z07") +" Z07 "
_cQuery += " WHERE "
_cQuery += " 	Z07.D_E_L_E_T_  = ' ' "
_cQuery += " AND	Z07.Z07_ALIAS	= '"+ cAlias +"' "
_cQuery += " AND	Z07.Z07_CAMPO	= '"+ cCampo +"' "
_cQuery += " AND	Z07.Z07_CHAVE	= '"+ cChave +"' "
_cQuery += " ORDER BY Z07.Z07_DATA , Z07.Z07_HORA , Z07.Z07_CODUSU , Z07.Z07_CONORG "

_cQuery	:= ChangeQuery(_cQuery)

MPSysOpenQuery( _cQuery , _cAlias)

TcSetField( _cAlias , "Z07.Z07_DATA" , "D" , 8 , 0 )

DBSelectArea(_cAlias)
(_cAlias)->(DBGoTop()) 

(_cAlias)->( DBEval( { || _nTotReg++ } ) )

ProcRegua(_nTotReg) // Regua

(_cAlias)->(DBGoTop())                                                                                   

//================================================================================
//| Grava o resultado dos detalhes das alterações dos campos                     |
//================================================================================
While (_cAlias)->(!Eof())

		aAdd( _aLbxAux , {			(_cAlias)->DT_ALT		,; // 01
                         			(_cAlias)->HORA			,; // 02
                         			(_cAlias)->CODUSU		,; // 03
  AllTrim( Capital( UsrFullName(	(_cAlias)->CODUSU ) ) )	,; // 04
						AllTrim(	(_cAlias)->CONT_ORG )	,; // 05
						AllTrim(	(_cAlias)->CONT_ALT )	}) // 06

_nCont++
IncProc("Montando estrutura "+StrZero(_nCont,6)+" de "+StrZero(_nTotReg,6)  )
(_cAlias)->( DBSkip() )
EndDo

(_cAlias)->( DBCloseArea() )

//================================================================================
//| Monta o objeto do ListBox com os dados dos detalhes                          |
//================================================================================
If	Len(_aLbxAux) > 0 .And. ValType(oLbxAux) == "O"
                     
	oLbxAux:SetArray(_aLbxAux)
	oLbxAux:bLine:={||{	_aLbxAux[oLbxAux:nAt][01]	,; // 01
						_aLbxAux[oLbxAux:nAt][02]	,; // 02
						_aLbxAux[oLbxAux:nAt][03]	,; // 03
						_aLbxAux[oLbxAux:nAt][04]	,; // 04
						_aLbxAux[oLbxAux:nAt][05]	,; // 05
						_aLbxAux[oLbxAux:nAt][06]	}} // 06

	oLbxAux:Refresh()

EndIf

Return()
