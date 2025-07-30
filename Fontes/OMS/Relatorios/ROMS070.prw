/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 29/12/2020 | Adicionadas todas as placas que tiverem preenchidas no cadastro do veiculo - Chamado 40533
==============================================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
Andre    - Alex Wallauer - 12/11/24 - 14/11/25 -  49117  - Alteracao do campo data de DATE() para DAK->DAK_DATA.
Alex     - Igor Melgaço  - 02/05/25 - 06/05/25 -  50525  - Ajuste para remoção de diretório local C:\SMARTCLIENT\.
==============================================================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#Include "FWPrintSetup.ch"
#Include "Protheus.ch"
#INCLUDE "RPTDEF.CH"

/*
===============================================================================================================================
Programa----------: ROMS070
Autor-------------: Alex Wallauer
Data da Criacao---: 30/05/2022
===============================================================================================================================
Descrição---------: REGISTRO DE CHECK LIST DE INSPECAO DE CARREGAMENTO, CHAMADO 40254
===============================================================================================================================
Parametros--------: _laRotina
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ROMS070(_laRotina)

Local _cQuery		:= ''
Local nI
Private _cAlias		:= GetNextAlias()
Private _nPagAux	:= 0
Private _nLinPont   := 185

DEFAULT _laRotina   := .F.


_aItalac_F3:={}
_BSelectDAK:={|| "SELECT DISTINCT DAK_FILIAL, DAK_COD, DAK_DATA, DAK_FEZNF FROM "+RETSQLNAME("DAK")+" DAK "+;
                 " WHERE DAK_FILIAL = '"+cFilAnt+"' AND "+;
                 IF(!EMPTY(MV_PAR01)," DAK.DAK_DATA >= '"+Dtos(MV_PAR01) + "' AND"          ,"")+;
                 IF(!EMPTY(MV_PAR02)," DAK.DAK_DATA <= '"+Dtos(MV_PAR02) + "' AND"          ,"")+;
                 " DAK.D_E_L_E_T_ <> '*' ORDER BY DAK_FILIAL, DAK_COD " }

_aItalac_F3:={}//       1           2         3                       4                                                                                         5         6           7         8          9         10         11        12
//AD(_aItalac_F3,{"1CPO_CAMPO1",_cTabela,_nCpoChave             , _nCpoDesc                                                                                 ,_bCondTab, _cTitAux ,_nTamChv , _aDados  , _nMaxSel , _lFilAtual,_cMVRET,_bValida})
AADD(_aItalac_F3,{"MV_PAR03",_BSelectDAK,{|Tab| (Tab)->DAK_COD }, {|Tab| DTOC(STOD((Tab)->DAK_DATA))+" / "+IF((Tab)->DAK_FEZNF="1","Tem NF","Não tem NF") } ,         ,"CARGAS"  ,         ,          ,    20    ,.F.        ,       , } )

IF !_laRotina  
   MV_PAR01:=CTOD("")
   MV_PAR02:=CTOD("")
   MV_PAR03:=SPACE(100)
   
   _aParAux:={}
   AADD( _aParAux , { 1 , "Data Emissao de" , MV_PAR01, "@D"	, ""  , ""		 , "" , 050 , .T. } )
   AADD( _aParAux , { 1 , "Data Emissao ate", MV_PAR02, "@D"	, ""  , ""		 , "" , 050 , .F. } )
   AADD( _aParAux , { 1 , "Cargas"	        , MV_PAR03, "@!" 	, ""  , "F3ITLC" , "" , 100 , .T. } )//DAK01
   
   _aParRet:={}
   For nI := 1 To Len( _aParAux )
   	aAdd( _aParRet , _aParAux[nI][03] )
   Next 
   	
   IF !ParamBox( _aParAux , "REGISTRO DE CHECK LIST" , @_aParRet, {|| NaoVazio(MV_PAR01) }  ,, .T. , , , , , .T. , .T.)
   	  RETURN .F.
   EndIf

ELSE
   MV_PAR03:=DAK->DAK_COD
ENDIF

u_itlogacs()

PRIVATE _cDir    := GetTempPath()

FERASE(_cDir+"\testa.bat")
FERASE(_cDir+"\resp.txt")	
_nHandle := FCreate(_cDir+"\testa.bat")
FWrite(_nHandle, 'reg query "HKEY_CLASSES_ROOT\Excel.Application\CurVer" > '+_cDir+'\resp.txt' + CHR(13))
FClose(_nHandle)	
shellexecute("Open",_cDir+"\testa.bat","","",0)
//tempo de espera para garantir que arquivo foi finalizado
Sleep(1500)
FT_FUSE(_cDir+"\resp.txt")	
FT_FSKIP()		
_cHKEY := FT_FREADLN()
FERASE(_cDir+"\testa.bat")
FERASE(_cDir+"\resp.txt")
//detecta se é excel ou libreoffice e cria script de conversão
If !"HKEY_CLASSES_ROOT\Excel.Application\CurVer"  $ _cHKEY //Tem Excel	
   U_ITMSG("Esse programa não pode ser usado sem ter o Excel instalado","Execute esse programa em um computar com o excel instalado.",3)
   RETURN .F.
ENDIF

PRIVATE _cDirMod := "\data\Italac\ROMS070\"
PRIVATE _cModelo := "CHECK_LIST.xlsx"//Modelo criado na pasta \data\Italac\ROMS070\

IF FILE(_cDir+_cModelo)
   ferase(_cDir+_cModelo)
ENDIF
//Copia o modelo para estação local
IF CpyS2T(_cDirMod+_cModelo,_cDir)
   _cModelo := _cDir+_cModelo
ELSE
   U_ITMSG("Nenhuma PLANILHA pode ser gerada",'Atenção!',"Não foi possivel encontrar e copiar o arquivo de Modelo: "+_cDirMod+_cModelo,1)
   RETURN .F.
ENDIF

_cQuery := " SELECT R_E_C_N_O_ RECDAK "
_cQuery += " FROM  "+ RetSQLName('DAK') +" DAK "
_cQuery += " WHERE "+ RetSQLCond('DAK')
_cQuery += " AND DAK.DAK_COD IN " + FormatIn(ALLTRIM(MV_PAR03),";")

If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAlias , .T. , .F. )

DBSelectArea(_cAlias)
(_cAlias)->( DBGoTop() )
If (_cAlias)->(!Eof())

    _nGerouAlguma:=0
    _cArquivos:=""

	DO While (_cAlias)->(!Eof())
	
        (DAK->(DBGOTO((_cAlias)->RECDAK)))				

        FWMSGRUN(,{|oproc|  ROMS7ProcPlan(oproc) },'Aguarde processamento...','Lendo Carga: '+DAK->DAK_COD)

	    (_cAlias)->( DBSkip() )

	EndDo
	
	(_cAlias)->( DBCloseArea() )
	DBSELECTAREA("DAK")
    IF _nGerouAlguma > 0 
       IF _nGerouAlguma > 6
	      bBloco:={||  U_ITMsgLog("Arquivo(s) gerado(s) com sucesso: "+CHR(13)+CHR(10)+_cArquivos, "ATENCAO") }
	      U_ITMSG('Arquivo(s) gerado(s) com sucesso: Clique em "Mais Detalhes"','Atenção!',,2,,,,,,bBloco)
	   ELSE
	      U_ITMSG("Arquivo(s) gerado(s) com sucesso: "+_cArquivos,'Atenção!',,2)
	   ENDIF
	ENDIF

ELSE

    Return .F.

EndIf

Return .T.

/*
===============================================================================================================================
Programa----------: ROMS7ProcPlan()
Autor-------------: Alex Wallauer
Data da Criacao---: 27/07/2018
===============================================================================================================================
Descricao---------: Testa, gera e abre as novas planilhas
===============================================================================================================================
Parametros--------: _oself
===============================================================================================================================
*/
Static Function ROMS7ProcPlan(_oSelf)
LOCAL _nConta:=1 , _ni
LOCAL _cFile   :="CHECK_LIST_"+ALLTRIM(DAK->DAK_COD)+".xlsx"

BEGIN SEQUENCE
	
    IF FILE(_cDir+_cFile)
	   
	   DO WHILE FERASE(_cDir+_cFile) = -1 .AND. _nConta <= 5
	   	  U_ITMSG("FECHE A PLANILHA: "+_cDir+_cFile,'Atenção! '+ALLTRIM(STR(_nConta))+" tentativas de 5","Para o sistema consegui-la gera-lá novamente",3)
		  _nConta++
	   ENDDO
	
	   IF FILE(_cDir+_cFile) .AND. FERASE(_cDir+_cFile) = -1
		  U_ITMSG("A PLANILHA: "+_cDir+_cFile+" não pode ser gerada",'Atenção!',"Não foi possivel apagar o arquivo "+_cDir+_cFile,1)
		  BREAK
	   ENDIF

    ENDIF

    _oself:cCaption:=("Gerando arquivo: "+_cDir+_cFile)
    ProcessMessages()
	ferase(_cDir+"\converzz.vbs")
    
	_cCarga:=AllTrim(DAK->DAK_COD)
	IF LEFT(_cCarga,1) = "0"
	   _cCarga:="'"+_cCarga
	ENDIF

    _cPlacas := AllTrim(Posicione("DA3",1,xFilial("DA3") + DAK->DAK_CAMINH,"DA3_PLACA"))
    IF !EMPTY(DA3->DA3_I_PLCV)
	   _cPlacas+=" / "+DA3->DA3_I_PLCV
	ENDIF
    IF !EMPTY(DA3->DA3_I_PLVG)
	   _cPlacas+=" / "+DA3->DA3_I_PLVG
	ENDIF
    IF !EMPTY(DA3->DA3_I_PLV3)
	   _cPlacas+=" / "+DA3->DA3_I_PLV3
	ENDIF

    SET DATE FORMAT TO "MM/DD/YYYY"
	_nHandle:= FCreate(_cDir+"\converzz.vbs")
	FWrite(_nHandle, "Dim oExcel" + CHR(13)+CHR(10))
	FWrite(_nHandle, 'Set oExcel = CreateObject("Excel.Application")'+ CHR(13)+CHR(10))
	FWrite(_nHandle, "Dim oBook"+ CHR(13)+CHR(10))
	FWrite(_nHandle, "Set oBook = oExcel.Workbooks.Open(Wscript.Arguments.Item(0))"+ CHR(13)+CHR(10))
	FWrite(_nHandle, 'oBook.Sheets(1).Range("C5").Value = "'+ALLTRIM(SM0->M0_FILIAL)+'"   '+ CHR(13)+CHR(10))
	FWrite(_nHandle, 'oBook.Sheets(1).Range("C6").Value = "'+ALLTRIM(Posicione("SA2",1,xFilial("SA2") + DAK->DAK_TRANSP,"A2_NREDUZ"))+'" '+ CHR(13)+CHR(10))
	FWrite(_nHandle, 'oBook.Sheets(1).Range("C7").Value = "'+_cPlacas+'" '+ CHR(13)+CHR(10))
	FWrite(_nHandle, 'oBook.Sheets(1).Range("C8").Value = "'+_cCarga+'" '+ CHR(13)+CHR(10))
	FWrite(_nHandle, 'oBook.Sheets(1).Range("I5").Value = "'+AllTrim(DTOC(DAK->DAK_DATA))+'" '+ CHR(13)+CHR(10))
	FWrite(_nHandle, 'oBook.Sheets(1).Range("I6").Value = "'+ALLTRIM(POSICIONE("DA4",1,XFILIAL("DA4")+DAK->DAK_MOTORI,"DA4_NOME"))+'" '+ CHR(13)+CHR(10))
	FWrite(_nHandle, 'oBook.Sheets(1).Range("A53").Value = "'+'Check List gerado: '+DTOC(DATE())+' - '+TIME()+'" '+ CHR(13)+CHR(10))
	FWrite(_nHandle, "oBook.SaveAs WScript.Arguments.Item(1) "+ CHR(13)+CHR(10))
	FWrite(_nHandle, "oBook.Close False"+ CHR(13)+CHR(10))
	FWrite(_nHandle, "oExcel.Quit"+ CHR(13)+CHR(10))
	FClose(_nHandle)
    SET DATE FORMAT TO "DD/MM/YY"

	ShellExecute("open", _cDir+"\converzz.vbs", _cModelo+" "+_cDir+_cFile, "", 0)
	FOR _ni := 1 TO 5
        IF FILE(_cDir+_cFile)
		   EXIT
		ENDIF
        SLEEP( 2000 )
	NEXT		    
    IF !FILE(_cDir+_cFile)
	   U_ITMSG("A PLANILHA: "+_cDir+_cFile+" NÃO pode ser gerada",'Atenção!',"Se ocorreu alguma mensagem de erro anterior a essa menssagem tente novamente, Print a mensagem e abra um chamado por favor.",1)
	   BREAK
	ENDIF
    _oself:cCaption:=("ABRINDO ARQUIVO: "+_cDir+_cFile)
    ProcessMessages()
	IF ShellExecute("open", _cFile, "", _cDir, 1) > 41// ABRE PLANILHA
       _nGerouAlguma++
	   _cArquivos+=_cFile+CHR(13)+CHR(10)
 	ENDIF
    
END SEQUENCE

RETURN 

