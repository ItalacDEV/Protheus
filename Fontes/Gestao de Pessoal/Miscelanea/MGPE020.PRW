/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
       Autor   |    Data   |                                             Motivo                                            
============================================================================================================================
 Lucas Borges  | 02/10/019 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25. 
 Alex Wallauer | 22/10/019 | Chamado 30969. Correção do fechamento do arquivo. 
 Alex Wallauer | 23/10/019 | Chamado 30969. Alteração do RA_NOME para RA_NOMECMP . 
 Alex Wallauer | 23/08/022 | Chamado 41105. Colocado decimais no campo R0_VALCAL na geracao do arquivo. 
 Igor Melgaço  | 17/07/023 | Chamado 44493. Ajuste para não incluir funcionários demitidos na listagem. 
===============================================================================================================================
==============================================================================================================================================================
Analista    - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
Bruno       - Alex Wallauer - 11/10/24 - 14/10/24 -  48760  - Adicionados os campos: RA_MAE / RA_EMAIL / RA_DDDCELU / RA_NUMCELU
Bruno       - Julio Paz     - 01/04/25 - 17/04/25 -  49948  - Alterações no Layout do relatório para filiais especificadas em parâmetros.
==============================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include	"Protheus.Ch"

/*
===============================================================================================================================
Programa----------: MGPE020
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 29/07/2019
===============================================================================================================================
Descrição---------: Rotina de extração dos dados para o envio a Alelo referente ao Vale Refeição - Chamado 30108
===============================================================================================================================
Retorno-----------: Nenhum  
===============================================================================================================================
*/
User Function MGPE020()

Local _aParAux:={} , nI
Local _aParRet:={}

PRIVATE _aItalac_F3:={}
_cRetorno:=SPACE(150)
//AADD(_aItalac_F3,{"TST_CAMPO",_cTabela ,_nCpoChave,_nCpoDesc , _bCondTab , _cTitAux , _nTamChv , _aDados , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{ "MV_PAR01"  ,         ,          ,          ,           ,          ,          ,         ,          ,           ,       ,{|A| U_MGPE20DIR() }})

PRIVATE MV_PAR01:=SPACE(100)
IF cFilant $ "90,92" 
   MV_PAR02:=U_ItGetMv("IT_VRCONTRA","11134414")+SPACE(10)
ELSE
   MV_PAR02:=U_ItGetMv("IT_VRCONTRA",SPACE(20))
ENDIF
PRIVATE MV_PAR03:="VR_"+ALLTRIM(cFilant)+"_"+DTOS(DATE())+".CSV"+SPACE(20)

aAdd( _aParAux , { 1 , "Selecione o Diretorio"    , MV_PAR01, "@!"    , ""	, 'F3ITLC', "" , 100 , .T. } )
aAdd( _aParAux , { 1 , "No. do Contrato da Filial", MV_PAR02, "@!"    , ""	, 	      , "" , 065 , .T. } )
aAdd( _aParAux , { 1 , "Nome Arquivo p/ Geracao"  , MV_PAR03, "@!"    , ""	, 	      , "" , 065 , !EMPTY(MV_PAR02) } )
For nI := 1 To Len( _aParAux )
    aAdd( _aParRet , _aParAux[nI][03] )
Next 

DO WHILE .T.

   lSair:=.T.
   
   IF !ParamBox( _aParAux , "Geração do Arquivo de Vale Refeição." , @_aParRet )
      Return .T.
   EndIf

   FWMSGRUN( ,{|oproc| lSair:=MGPE020INI(oproc) } , "Processando..." , "Iniciando o processamento..." )

   IF lSair
      EXIT
   ENDIF

ENDDO

SET DATE FORMAT TO "DD/MM/YY"
	
Return .T.

/*
===============================================================================================================================
Programa----------: ITSelDir
Autor-------------: Alexandre Villar
Data da Criacao---: 29/07/2019
===============================================================================================================================
Descrição---------: Permite selecionar um diretório local
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: cDir - Caminho do diretório selecionado
===============================================================================================================================
*/

User Function MGPE20DIR()

DO WHILE .T.
//         cGetFile (cMascara], [ cTitulo]                     ,[ nMascpadrao],cDirinicial, [ lSalvar], [ nOpcoes]                                        , [ lArvore], [ lKeepCase] )
   cDir := cGetFile( "\" , "Selecione o Diretorio de Destino:" ,              ,MV_PAR01   ,           , GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE,.T. )
   cDir := AllTrim(cDir)
   //Verifica a existência do diretório e tenta criar caso não exista   
   If !EMPTY(cDir) .AND. !ExistDir(cDir)
	
		nCriaDir := MakeDir( cDir )
		
		If nCriaDir <> 0
		
			U_ITMSG("Não foi possível criar ou utilizar o diretório:"+ CRLF + CRLF + cDir,;
					            "Alerta", " Verificar permissões para Gravação na Pasta de destino.",1)
			LOOP
			
		EndIf
		
	EndIf
    EXIT
ENDDO 

IF !EMPTY(cDir)
    MV_PAR01  := cDir
ENDIF    
_cRetorno := .T.//_cRetorno É PUBLIC e tem que devolver logica

Return .F. //Tem Retornar .F. para não chamar o resto da função de F3

/*
===============================================================================================================================
Programa----------: MGPE020INI
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 29/07/2019
===============================================================================================================================
Descrição---------: Rotina de montagem da tela de processamento
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: .T. OU .F.
===============================================================================================================================
*/
Static Function MGPE020INI(oproc)

Local _cQuery	   := ""
Local _aDados	   := {}
Local _cArq		   := ""
Local _cLocalEnt  := RIGHT(ALLTRIM(SM0->M0_CGC),4)
Local _cFilVesao  := SuperGetMV('IT_MGP20RL',.F.,  "90;92")

Private cAliasAux	:= GetNextAli8as()

//Grava Log de execução da rotina
U_ITLOGACS( "MGPE020" )

SET DATE FORMAT TO "DD/MM/YYYY"

oproc:cCaption := ("Lendo dados...")
ProcessMessages()

_cQuery := " SELECT  R0_FILIAL, R0_MAT, R0_VALCAL, RA_NOMECMP , RA_CIC, RA_NASC, RA_SEXO, RA_MAE, RA_EMAIL, RA_DDDCELU, RA_NUMCELU "
_cQuery += " FROM " +RETSQLNAME("SR0") + " SR0 "
_cQuery += " JOIN " +RETSQLNAME("SRA") + " SRA ON SRA.RA_MAT = SR0.R0_MAT AND SRA.RA_FILIAL = SR0.R0_FILIAL " 
_cQuery += " WHERE  SR0.R0_TPVALE = 1   " 
_cQuery += " AND SR0.R0_FILIAL = '"+cFilant+"' AND SR0.D_E_L_E_T_ <> '*'  " 
_cQuery += " AND SRA.RA_FILIAL = '"+cFilant+"' AND SRA.D_E_L_E_T_ <> '*'  " 
_cQuery += " AND SRA.RA_DEMISSA = ' ' "
_cQuery += " ORDER BY R0_MAT "
	
MPSysOpenQuery( _cQuery , cAliasAux ) 

oProc:cCaption := ("Contando os dados lidos...")
ProcessMessages()
DBSELECTAREA(cAliasAux)
(cAliasAux)->(Dbgotop())
_cTot := 0
COUNT TO _cTot
_cTot:=ALLTRIM(STR(_cTot))
_nTam:=LEN(_cTot)
(cAliasAux)->(Dbgotop())
_npv:=0

IF RIGHT(ALLTRIM(MV_PAR01),1) <> "\"
   _cArq:=ALLTRIM(MV_PAR01)+"\"
ELSE
   _cArq:=ALLTRIM(MV_PAR01)
ENDIF   
_cArq:=_cArq+ALLTRIM(MV_PAR03)

IF FILE(_cArq)
   FERASE(_cArq)
ENDIF
_nHdl := fCreate(_cArq)

If _nHdl == -1
	MsgAlert("O arquivo de nome "+_cArq+" nao pode ser criado! Verifique os parametros.","Atencao!")
	Return .F.
Endif

_cLinha:=";CONTRATO;;;;;;;;"
FWrite(_nHdl, _cLinha + chr(13) + chr(10))

_cLinha:="%;11134414;%;;;;;;;"
FWrite(_nHdl, _cLinha + chr(13) + chr(10))

If ! Xfilial("SRA") $ _cFilVesao // Gerar o relatório no formato antigo.
   _cLinha:=";NOME DO USUARIO;CPF;DATA DE NASCIMENTO;CODIGO DE SEXO;VALOR;TIPO DE LOCAL ENTREGA;LOCAL DE ENTREGA;MATRICULA;NOME DA MAE;EMAIL;TELEFONE CELULAR"
Else // Para as filiais do parâmetro gerar o relatório no novo formato. 
   _cLinha:=";NOME DO USUARIO;CPF;DATA DE NASCIMENTO;CODIGO DE SEXO;VALOR;TIPO DE LOCAL ENTREGA;LOCAL DE ENTREGA;MATRICULA;"
EndIf 

FWrite(_nHdl, _cLinha + chr(13) + chr(10))

_nZerados:=0
_nGerados:=0

DO While (cAliasAux)->(!EOF())

	_npv++
	oProc:cCaption := ("Processando Dados: "+ STRZERO(_npv,_nTam) +" de "+ _cTot)
	ProcessMessages()
    _aItens:={}
   If ! Xfilial("SRA") $ _cFilVesao // Gerar o relatório no formato antigo. 
	   AADD(_aItens,.T.)
	   AADD(_aItens,(cAliasAux)->R0_FILIAL)
	   AADD(_aItens,(cAliasAux)->R0_MAT)
	   AADD(_aItens,(cAliasAux)->RA_NOMECMP)
	   AADD(_aItens,ALLTRIM(TRANSFORM((cAliasAux)->R0_VALCAL,"@E 999,999,999.99")))
	   AADD(_aItens,(cAliasAux)->RA_CIC)
	   AADD(_aItens,DTOC(STOD((cAliasAux)->RA_NASC)))
	   AADD(_aItens,(cAliasAux)->RA_SEXO)
	   AADD(_aItens,_cLocalEnt)
	   AADD(_aItens,(cAliasAux)->RA_MAE)
	   AADD(_aItens,(cAliasAux)->RA_EMAIL)
	   AADD(_aItens,ALLTRIM((cAliasAux)->RA_DDDCELU+" "+(cAliasAux)->RA_NUMCELU))
   Else // Novo layout do relatório.
      //AADD(_aItens,.T.)
      AADD(_aItens,"%") 
      AADD(_aItens,(cAliasAux)->RA_NOMECMP)
      AADD(_aItens,(cAliasAux)->RA_CIC)
      AADD(_aItens,DTOC(STOD((cAliasAux)->RA_NASC)))
      AADD(_aItens,(cAliasAux)->RA_SEXO)
	   AADD(_aItens,ALLTRIM(TRANSFORM((cAliasAux)->R0_VALCAL,"@E 999,999,999.99")))
	   AADD(_aItens,"FI") 
	   AADD(_aItens,_cLocalEnt)
	   AADD(_aItens,(cAliasAux)->R0_MAT)
      AADD(_aItens,"%") 
   EndIf 
   
//------------------------------------------------------------------------    
    _cLinha:="%;"+ALLTRIM((cAliasAux)->RA_NOMECMP)+";"+;
                  ALLTRIM((cAliasAux)->RA_CIC)+";"+;
                  DTOC(STOD((cAliasAux)->RA_NASC))+";"+;
                  (cAliasAux)->RA_SEXO+";"+;
                  ALLTRIM(TRANSFORM((cAliasAux)->R0_VALCAL,"@E 999,999,999.99"))+";FI;"+;
                  _cLocalEnt+";"+;
                  ALLTRIM(STR(VAL((cAliasAux)->R0_MAT)))+";"
    //--------------------------------------------------------------------
    If ! Xfilial("SRA") $ _cFilVesao // Gerar o relatório no formato antigo. 
       _cLinha+=ALLTRIM((cAliasAux)->RA_MAE)+";"
	    _cLinha+=ALLTRIM((cAliasAux)->RA_EMAIL)+";"
       IF !EMPTY((cAliasAux)->RA_NUMCELU)
	       _cLinha+=ALLTRIM(((cAliasAux)->RA_DDDCELU)+ALLTRIM((cAliasAux)->RA_NUMCELU)+";%")
       ELSE
	       _cLinha+=";%"
       ENDIF
    Else // Para o novo formato do relatório. 
       _cLinha+="%"
    EndIf    
    //---------------------------------------------------------------------
    IF (cAliasAux)->R0_VALCAL > 0
	    FWrite(_nHdl, _cLinha + chr(13) + chr(10))
       _nGerados++
    ELSE
       //_aItens[1]:=.F. 
       _nZerados++
    ENDIF

	 AADD(_aDados,_aItens)

    (cAliasAux)->(DBSKIP())
 
ENDDO

(cAliasAux)->( DBCloseArea() )

FClose(_nHdl)

//Monta _aCab
_aCab:={}

If ! Xfilial("SRA") $ _cFilVesao // Gerar o relatório no formato antigo. 
   AAdd(_aCab,"")
   AAdd(_aCab,UPPER(Getsx3cache("R0_FILIAL","X3_TITULO")))
   AAdd(_aCab,UPPER(Getsx3cache("R0_MAT","X3_TITULO")))
   AAdd(_aCab,UPPER(Getsx3cache("RA_NOMECMP","X3_TITULO")))
   AAdd(_aCab,UPPER(Getsx3cache("R0_VALCAL","X3_TITULO")))
   AAdd(_aCab,UPPER(Getsx3cache("RA_CIC","X3_TITULO")))
   AAdd(_aCab,UPPER(Getsx3cache("RA_NASC","X3_TITULO")))
   AAdd(_aCab,UPPER(Getsx3cache("RA_SEXO","X3_TITULO")))
   AAdd(_aCab,"LOCAL DE ENTREGA")
   AAdd(_aCab,"NOME DA MAE")
   AAdd(_aCab,"EMAIL")
   AAdd(_aCab,"TELEFONE CELULAR")
Else // Novo Layout
   //AAdd(_aCab,"")
   AAdd(_aCab,"")
   AAdd(_aCab,UPPER(Getsx3cache("RA_NOMECMP","X3_TITULO")))
   AAdd(_aCab,UPPER(Getsx3cache("RA_CIC","X3_TITULO")))
   AAdd(_aCab,UPPER(Getsx3cache("RA_NASC","X3_TITULO")))
   AAdd(_aCab,UPPER(Getsx3cache("RA_SEXO","X3_TITULO")))
   AAdd(_aCab,UPPER(Getsx3cache("R0_VALCAL","X3_TITULO")))
   AAdd(_aCab,"TIPO LOCAL DE ENTREGA")
   AAdd(_aCab,"LOCAL DE ENTREGA")
   AAdd(_aCab,UPPER(Getsx3cache("R0_MAT","X3_TITULO")))
   AAdd(_aCab,"")

EndIf  

If LEN(_aDados) > 0
   _cTitulo:="LOG dos dados gerados no arquivo "+_cArq
   _cMsgTop:="ARQUIVO "+UPPER(_cArq)+" GERADO COM SUCESSO / "+;
             ALLTRIM(TRANSFORM(_nGerados,"@E 999,999,999"))+" Matriculas Geradas / "+;
             _cTot+" Matriculas Lidas / "+;
             ALLTRIM(TRANSFORM(_nZerados,"@E 999,999,999"))+" Matriculas Zeradas"
   If ! Xfilial("SRA") $ _cFilVesao // Gerar o relatório no formato antigo.           
	   U_ITLISTBOX(_cTitulo, _aCab    , _aDados   , .T.      , 4      ,_cMsgTop)
   Else 
      U_ITLISTBOX(_cTitulo, _aCab    , _aDados   , .T.      ,        ,_cMsgTop)
   EndIf 
Else
	U_ITMSG("Nenhum registro gerado!","Atenção",,1)
Endif

Return .F.
