/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer |30/08/2021| Chamado 37601. Trazer o conte�do do campo RA_NSOCIAL, quando preenchido no lugar do RA_NOME.
Lucas Borges  |09/10/2024| Chamado 48465. Retirada manipula��o do SX1
=================================================================================================================================================================================================
Analista       - Programador   - Inicio   - Envio    - Chamado - Motivo da Altera��o
=================================================================================================================================================================================================
Bruno          - Julio Paz     - 26/02/25 - 27/02/25 - 49946   - Desenvolvimento de uma nova vers�o deste relat�rio para per�odo fechado.
=================================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.Ch"
#INCLUDE 'TOPCONN.CH'

#Define TITULO	"Ponto Eletr�nico - Marca��es Diarias"
#Define CRLF	Chr(13)+Chr(10)

/*
===============================================================================================================================
Programa----------: RPON015
Autor-------------: Alex Wallauer
Data da Criacao---: 17/02/2021
Descri��o---------: Relat�rio de An�lise da Marca��o de Pontos - Jornada x Intervalo - CHAMADO 	35370
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RPON015()

Local _aRet			:= {}
Local _aParamBox	:= {}
Local _nTamSet		:= ( 16 * TamSX3("ZAK_COD")[01] )

SET DATE FORMAT TO "DD/MM/YYYY"

Begin Sequence 
   MV_PAR01 := Ctod("  /  /  ")
   MV_PAR02 := Ctod("  /  /  ")
   MV_PAR03 := Space( TamSX3("RA_MAT")[01] )
   MV_PAR04 := Space( TamSX3("RA_MAT")[01] )
   MV_PAR05 := Space( TamSX3("RA_TNOTRAB")[01] )
   MV_PAR06 := Space( TamSX3("RA_TNOTRAB")[01] )
   MV_PAR07 := Space(_nTamSet)
   MV_PAR08 := "1"

   //aAdd( _aParamBox , { 1 , "Filiais"		, Space(_nTamFil)				, ""                       , "U_RPON015P(1)"	, "SM0001"	, "" , 100 , .T. } )
   aAdd( _aParamBox , { 1 , "Data Inicial"	, MV_PAR01 , ""                       , ""			, ""		, "" , 050 , .T. } )//01
   aAdd( _aParamBox , { 1 , "Data Final"	, MV_PAR02 , ""                       , ""			, ""		, "" , 050 , .T. } )//02
   aAdd( _aParamBox , { 1 , "Matr�cula De"	, MV_PAR03 , ""                       , ""			, "SRA"		, "" , 050 , .F. } )//03
   aAdd( _aParamBox , { 1 , "Matr�cula At�" , MV_PAR04 , ""                       , ""			, "SRA"		, "" , 050 , .T. } )//04
   aAdd( _aParamBox , { 1 , "Turno De"	    , MV_PAR05 , ""                       , ""			, "SR6"		, "" , 050 , .F. } )//05
   aAdd( _aParamBox , { 1 , "Turno At�"	    , MV_PAR06 , ""                       , ""			, "SR6"		, "" , 050 , .F. } )//06
   aAdd( _aParamBox , { 1 , "Setores"		, MV_PAR07 , ""                       , "" 			, "ZAK001"	, "" , 100 , .F. } )//07
   aAdd( _aParamBox , { 2 , "Per�odo"		, MV_PAR08 , {"1=Aberto","2=Fechado"} , 90 		, ".T."	    , .F. } )           //08

   If ! ParamBox( _aParamBox , "Parametriza��o do Relat�rio:" , @_aRet ,,, .T. , , , , , .T. , .T. )
      Break
   EndIf 

   If MV_PAR08 == "1" // Per�odo Aberto
	  FWMSGRUN(,{|oProc| _aDados := RPON015ABE(oProc) } , "Aguarde!" , "Verificando as marca��es (Periodo Aberto)...")
   Else // Per�odo Fechado 
      FWMSGRUN(,{|oProc| _aDados := RPON015FEC(oProc) } , "Aguarde!" , "Verificando as marca��es (Per�odo Fechado)...")
   EndIf

End Sequence 

Return

/*
===============================================================================================================================
Programa----------: RPON015ABE
Autor-------------: Alex Wallauer
Data da Criacao---: 17/02/2021
Descri��o---------: Carrega dados para o relat�rio
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RPON015ABE(oProc)

//   				  01     02     03     04     05     06     07     08     09     10     11     12     13
//Local _aColPos	:= { 0050 , 0210 , 0750 , 0940 , 1100 , 1195 , 1280 , 1360 , 1465 , 1795 , 1975 , 2130 , 2275 }
//Local _aColAjs	:= { 0010 , 0000 , 0000 , 0000 , 0000 , 0010 , 0010 , 0015 , 0000 , 0000 , 0000 , 0015 , 0000 }
Local _aDados	:= {}
Local _aFiliais	:= {cFilAnt}//StrToKArr( AllTrim( MV_PAR01 ) , ";" )
Local _cAlias	:= GetNextAlias()
Local _cQuery	:= ""
Local _nTotReg	:= 0
Local _nAtuReg	:= 0
Local _nI		:= 0
Local aItens
Local _cNomeFunc
Local _cPC_PD
Local _cPK_CODABO
Local _cMarcacao

IF Empty( _aFiliais )
	Aviso( "Aten��o!" , "N�o foram informadas Filiais v�lidas para o processamento!" , {"Ok"} )
	Return()
EndIf
For _nI := 1 To Len( _aFiliais )

    oProc:cCaption := "Lendo Marcacao da Filial [ "+_aFiliais[_nI]+" ]"
    ProcessMessages()

    _cQuery := ""
	_cQuery += " SELECT "+ CRLF
	_cQuery += "     SP8.P8_FILIAL   AS FILIAL,   "+ CRLF
	_cQuery += "     SRA.RA_I_SETOR  AS SETOR,    "+ CRLF
	_cQuery += "     SP8.P8_MAT      AS MAT,      "+ CRLF
	_cQuery += "     SP8.P8_DATAAPO  AS DATA_APO, "+ CRLF
	_cQuery += "     TO_CHAR(TO_DATE(TO_CHAR(SP8.P8_HORA, '00.00'),'hh24:mi'),'hh24:mi') AS HORA, "+ CRLF
	_cQuery += "     SP8.P8_TURNO    AS TURNO  "+ CRLF
	_cQuery += " FROM "+ RetSqlName("SP8") +" SP8 "+ CRLF
	_cQuery += " INNER JOIN "+ RetSqlName("SRA") +" SRA ON "+ CRLF
	_cQuery += "     SRA.RA_FILIAL   = SP8.P8_FILIAL "+ CRLF
	_cQuery += " AND SRA.RA_MAT      = SP8.P8_MAT "+ CRLF
	_cQuery += " WHERE "+ CRLF
	_cQuery += "     SP8.D_E_L_E_T_  = ' ' "+ CRLF
	_cQuery += " AND SRA.D_E_L_E_T_  = ' ' "+ CRLF
	
	IF !Empty( MV_PAR07 )	
		_cQuery += " AND SRA.RA_I_SETOR	IN "+ FormatIn( AllTrim( MV_PAR07 ) , ";" ) + CRLF	
	EndIF

	IF !Empty( MV_PAR06 )	
	   _cQuery += " AND SP8.P8_TURNO BETWEEN '"+ MV_PAR05 +"' AND '"+ MV_PAR06 +"' "+ CRLF
	EndIF

 	_cQuery += " AND SP8.P8_APONTA  = 'S' "+ CRLF
	_cQuery += " AND SP8.P8_FILIAL  = '"+ _aFiliais[_nI] +"' " + CRLF
	_cQuery += " AND SP8.P8_DATAAPO	BETWEEN '"+ DTOS( MV_PAR01 ) +"' AND '"+ DTOS( MV_PAR02 ) +"' "+ CRLF
	_cQuery += " AND SP8.P8_MAT     BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"' "+ CRLF
	
	_cQuery += " ORDER BY FILIAL, SETOR, MAT, DATA_APO, HORA "+ CRLF
	
	//DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .T. )
	MPSysOpenQuery( _cQuery , _cAlias )
	
	_nAtuReg := 0
	_nTotReg := 0
	
	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	Count To _nTotReg // (_cAlias)->( DBEval( {|| _nTotReg++ } ) )
	(_cAlias)->( DBGoTop() )
	
	SPC->(DBSETORDER(2))
	SPK->(DBSETORDER(1))
	SP6->(DBSETORDER(1))
	SP9->(DBSETORDER(1))
	
	ProcRegua(_nTotReg)
	
	DO While (_cAlias)->(!Eof())
		
		_nAtuReg++
		oProc:cCaption := ( "Lendo Marcacoes ["+ StrZero( _nAtuReg , 9 ) +"] de ["+ StrZero( _nTotReg , 9 ) +"]" )
	    ProcessMessages()

        aItens:={}
        aAdd( aItens ,   (_cAlias)->FILIAL	)
        aAdd( aItens ,   (_cAlias)->MAT	    )
		_cNomeFunc := Posicione("SRA",1,(_cAlias)->FILIAL+(_cAlias)->MAT,"RA_NOME")
		IF !EMPTY(SRA->RA_NSOCIAL)
		   _cNomeFunc:=SRA->RA_NSOCIAL
		ENDIF
        aAdd( aItens ,   _cNomeFunc )
        aAdd( aItens ,   (_cAlias)->SETOR	)
        aAdd( aItens ,   Posicione("ZAK",1,xFilial("ZAK")+(_cAlias)->SETOR,"ZAK_DESCRI") )
        aAdd( aItens ,   (_cAlias)->TURNO )
        aAdd( aItens ,   Posicione("SR6",1,(_cAlias)->FILIAL+(_cAlias)->TURNO,"R6_DESC") )
        aAdd( aItens ,   DTOC( STOD((_cAlias)->DATA_APO ) ) )
		
	    _cPC_PD:=""
		IF SPC->(DBSEEK((_cAlias)->FILIAL+(_cAlias)->MAT+(_cAlias)->DATA_APO)) 
		   DO WHILE SPC->(!EOF()) .AND. (_cAlias)->FILIAL+(_cAlias)->MAT+(_cAlias)->DATA_APO == SPC->PC_FILIAL+SPC->PC_MAT+DTOS(SPC->PC_DATA)
		      IF !SPC->PC_PD+"-" $ _cPC_PD
		         _cPC_PD+=SPC->PC_PD+"-"+Posicione("SP9",1,(_cAlias)->FILIAL+SPC->PC_PD ,"P9_DESC")+CRLF		      
			  ENDIF
			  SPC->(DBSkip())
           ENDDO
		EndIF

	    _cPK_CODABO:=""
		IF SPK->(DBSEEK((_cAlias)->FILIAL+(_cAlias)->MAT+(_cAlias)->DATA_APO ))
		   DO WHILE SPK->(!EOF()) .AND. (_cAlias)->FILIAL+(_cAlias)->MAT+(_cAlias)->DATA_APO == SPK->PK_FILIAL+SPK->PK_MAT+DTOS(SPK->PK_DATA)
		      IF !SPK->PK_CODABO+"-" $ _cPK_CODABO
		         _cPK_CODABO+=SPK->PK_CODABO+"-"+Posicione("SP6",1,SPK->PK_FILIAL+SPK->PK_CODABO ,"P6_DESC")+CRLF		      
			  ENDIF
			  SPK->(DBSkip())
           ENDDO
		EndIF
		_cPK_CODABO:=LEFT(_cPK_CODABO,LEN(_cPK_CODABO)-2)
        
		_cChave:=(_cAlias)->FILIAL+(_cAlias)->MAT+(_cAlias)->DATA_APO 
		_cMarcacao:=""
	    DO While (_cAlias)->(!Eof()) .AND. _cChave == (_cAlias)->FILIAL+(_cAlias)->MAT+(_cAlias)->DATA_APO 
            _cMarcacao+= (_cAlias)->HORA+" - "
			(_cAlias)->(DBSkip())
        ENDDO
		_cMarcacao:=LEFT(_cMarcacao,LEN(_cMarcacao)-3)
        
		aAdd( aItens ,  _cMarcacao )
	    aAdd( aItens ,  _cPC_PD    )
	    aAdd( aItens ,  _cPK_CODABO)

        aAdd( _aDados , aItens )
		IF EMPTY(_cMarcacao)
		   (_cAlias)->( DBSkip() )
		ENDIF
	
	EndDo

	oProc:cCaption := ( "Lendo Faltas da Filial [ "+_aFiliais[_nI]+" ]" )
    ProcessMessages()

	(_cAlias)->( Dbclosearea() )

    _cQuery := ""
	_cQuery += " SELECT "+ CRLF
	_cQuery += "     SPC.PC_FILIAL   AS FILIAL,   "+ CRLF
	_cQuery += "     SRA.RA_I_SETOR  AS SETOR,    "+ CRLF
	_cQuery += "     SPC.PC_MAT      AS MAT,      "+ CRLF
	_cQuery += "     SPC.PC_DATA     AS DATA_APO, "+ CRLF
	_cQuery += "     SPC.PC_TURNO    AS TURNO,    "+ CRLF
	_cQuery += "     SPC.PC_PD                    "+ CRLF
	_cQuery += " FROM "+ RetSqlName("SPC") +" SPC "+ CRLF
	_cQuery += " INNER JOIN "+ RetSqlName("SRA") +" SRA ON "+ CRLF
	_cQuery += "     SRA.RA_FILIAL = SPC.PC_FILIAL "+ CRLF
	_cQuery += " AND SRA.RA_MAT    = SPC.PC_MAT    "+ CRLF
	_cQuery += " WHERE "+ CRLF
	_cQuery += "     SPC.D_E_L_E_T_  = ' ' "+ CRLF
	_cQuery += " AND SRA.D_E_L_E_T_  = ' ' "+ CRLF
	
	IF !Empty( MV_PAR07 )	
		_cQuery += " AND SRA.RA_I_SETOR	IN "+ FormatIn( AllTrim( MV_PAR07 ) , ";" ) + CRLF	
	EndIF

	IF !Empty( MV_PAR06 )	
	   _cQuery += " AND SPC.PC_TURNO BETWEEN '"+ MV_PAR05 +"' AND '"+ MV_PAR06 +"' "+ CRLF
	EndIF

 	_cQuery += " AND SPC.PC_PD  = '413' "+ CRLF
	_cQuery += " AND SPC.PC_FILIAL  = '"+ _aFiliais[_nI] +"' " + CRLF
	_cQuery += " AND SPC.PC_DATA BETWEEN '"+ DTOS( MV_PAR01 ) +"' AND '"+ DTOS( MV_PAR02 ) +"' "+ CRLF
	_cQuery += " AND SPC.PC_MAT  BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"' "+ CRLF
	
	_cQuery += " ORDER BY FILIAL, SETOR, MAT, DATA_APO"+ CRLF
	
	//DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .T. )
	MPSysOpenQuery( _cQuery , _cAlias )
	
	_nAtuReg := 0
	_nTotReg := 0
	
	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	Count To _nTotReg // (_cAlias)->( DBEval( {|| _nTotReg++ } ) )
	(_cAlias)->( DBGoTop() )
	
	ProcRegua(_nTotReg)
	
	DO While (_cAlias)->(!Eof())
		
		_nAtuReg++
		oProc:cCaption := ( "Lendo Faltas ["+ StrZero( _nAtuReg , 9 ) +"] de ["+ StrZero( _nTotReg , 9 ) +"]" )
	    ProcessMessages()

        aItens:={}
        aAdd( aItens ,   (_cAlias)->FILIAL	)
        aAdd( aItens ,   (_cAlias)->MAT	    )
		_cNomeFunc := Posicione("SRA",1,(_cAlias)->FILIAL+(_cAlias)->MAT,"RA_NOME")
		IF !EMPTY(SRA->RA_NSOCIAL)
		   _cNomeFunc:=SRA->RA_NSOCIAL
		ENDIF
        aAdd( aItens ,   _cNomeFunc )
        aAdd( aItens ,   (_cAlias)->SETOR	)
        aAdd( aItens ,   Posicione("ZAK",1,xFilial("ZAK")+(_cAlias)->SETOR,"ZAK_DESCRI") )
        aAdd( aItens ,   (_cAlias)->TURNO )
        aAdd( aItens ,   Posicione("SR6",1,(_cAlias)->FILIAL+(_cAlias)->TURNO,"R6_DESC") )
        aAdd( aItens ,   DTOC( STOD((_cAlias)->DATA_APO ) ) )
		
        _cPC_PD:=(_cAlias)->PC_PD+"-"+Posicione("SP9",1,(_cAlias)->FILIAL+(_cAlias)->PC_PD ,"P9_DESC")      

	    _cPK_CODABO:=""
		IF SPK->(DBSEEK((_cAlias)->FILIAL+(_cAlias)->MAT+(_cAlias)->DATA_APO ))
		   DO WHILE SPK->(!EOF()) .AND. (_cAlias)->FILIAL+(_cAlias)->MAT+(_cAlias)->DATA_APO == SPK->PK_FILIAL+SPK->PK_MAT+DTOS(SPK->PK_DATA)
		      IF !SPK->PK_CODABO+"-" $ _cPK_CODABO
		         _cPK_CODABO+=SPK->PK_CODABO+"-"+Posicione("SP6",1,SPK->PK_FILIAL+SPK->PK_CODABO ,"P6_DESC")+CRLF		      
			  ENDIF
			  SPK->(DBSkip())
           ENDDO
		EndIF
		_cPK_CODABO:=LEFT(_cPK_CODABO,LEN(_cPK_CODABO)-2)
        
		_cMarcacao:="SEM MARCAOES"
        
		aAdd( aItens ,  _cMarcacao )
	    aAdd( aItens ,  _cPC_PD    )
	    aAdd( aItens ,  _cPK_CODABO)

        aAdd( _aDados , aItens )
	    (_cAlias)->( DBSkip() )
	
	EndDo

    (_cAlias)->( Dbclosearea() )

Next _nI

IF Empty( _aDados )

	U_ITMSG(  "N�o foram encontrados registros para exibir! Verifique os par�metros e tente novamente." , "Aten��o!" ,,1 )
	Return()
	
Else
    _aCabec	:= {}
    AADD(_aCabec,"Filial"    )
    AADD(_aCabec,"Matricula" )
    AADD(_aCabec,"Nome do Funcionario"      )
    AADD(_aCabec,"Cod. Setor")
    AADD(_aCabec,"Descricoes dos Setor")
    AADD(_aCabec,"Cod Turno" )
    AADD(_aCabec,"Turno"     )
    AADD(_aCabec,"Data Apontamento")
    AADD(_aCabec,"Marcacoes")
    AADD(_aCabec,"Descricoes dos Eventos")
    AADD(_aCabec,"Descricoes dos Abono"  )
    _aCabecx := ACLONE(_aCabec)

	U_ITListBox( TITULO + "(Per�odo Aberto)" , _aCabecx , _aDados , .T. )

EndIf

Return .T.

/*
===============================================================================================================================
Programa----------: RPON015FEC
Autor-------------: Julio de Paula Paz
Data da Criacao---: 26/02/2025
Descri��o---------: Gera o relat�rio de Marca��o de Horas para Per�odo Fechado. 
                    � uma vers�o do relat�rio para Per�odo Aberto(a Fun��o )
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function RPON015FEC(oProc)
Local _aDados	:= {}
Local _aFiliais	:= {cFilAnt}
Local _cAlias	:= GetNextAlias()
Local _cQry	:= ""
Local _nTotReg	:= 0
Local _nAtuReg	:= 0
Local _nI		:= 0
Local _aItens
Local _cNomeFunc
Local _cPC_PD
Local _cPK_CODABO
Local _cMarcacao

Begin Sequence 
   If Empty( _aFiliais )
      U_ITMSGLOG("N�o foram informadas Filiais v�lidas para o processamento!","Aten��o")
 	  Break 
   EndIf
   
   For _nI := 1 To Len( _aFiliais )
       oProc:cCaption := "Lendo Marcacao da Filial [ "+_aFiliais[_nI]+" ]"
       ProcessMessages()

       _cQry := ""
	   _cQry += " SELECT "+ CRLF
	   _cQry += "     SPG.PG_FILIAL   AS FILIAL,   "+ CRLF
	   _cQry += "     SRA.RA_I_SETOR  AS SETOR,    "+ CRLF
	   _cQry += "     SPG.PG_MAT      AS MAT,      "+ CRLF
	   _cQry += "     SPG.PG_DATAAPO  AS DATA_APO, "+ CRLF
	   _cQry += "     TO_CHAR(TO_DATE(TO_CHAR(SPG.PG_HORA, '00.00'),'hh24:mi'),'hh24:mi') AS HORA, "+ CRLF
	   _cQry += "     SPG.PG_TURNO    AS TURNO  "+ CRLF
	   _cQry += " FROM "+ RetSqlName("SPG") +" SPG "+ CRLF
	   _cQry += " INNER JOIN "+ RetSqlName("SRA") +" SRA ON "+ CRLF
	   _cQry += "     SRA.RA_FILIAL   = SPG.PG_FILIAL "+ CRLF
	   _cQry += " AND SRA.RA_MAT      = SPG.PG_MAT "+ CRLF
	   _cQry += " WHERE "+ CRLF
	   _cQry += "     SPG.D_E_L_E_T_  = ' ' "+ CRLF
	   _cQry += " AND SRA.D_E_L_E_T_  = ' ' "+ CRLF
	
	   IF !Empty( MV_PAR07 )	
		  _cQry += " AND SRA.RA_I_SETOR	IN "+ FormatIn( AllTrim( MV_PAR07 ) , ";" ) + CRLF	
	   EndIF

	   IF !Empty( MV_PAR06 )	
	      _cQry += " AND SPG.PG_TURNO BETWEEN '"+ MV_PAR05 +"' AND '"+ MV_PAR06 +"' "+ CRLF
	   EndIF

 	   _cQry += " AND SPG.PG_APONTA  = 'S' "+ CRLF
	   _cQry += " AND SPG.PG_FILIAL  = '"+ _aFiliais[_nI] +"' " + CRLF
	   _cQry += " AND SPG.PG_DATAAPO	BETWEEN '"+ DTOS( MV_PAR01 ) +"' AND '"+ DTOS( MV_PAR02 ) +"' "+ CRLF
	   _cQry += " AND SPG.PG_MAT     BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"' "+ CRLF
	
	   _cQry += " ORDER BY FILIAL, SETOR, MAT, DATA_APO, HORA "+ CRLF
	
	   //DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQry) , _cAlias , .T. , .T. )
	   MPSysOpenQuery( _cQry , _cAlias )
	
	   _nAtuReg := 0
	   _nTotReg := 0
	
	   DBSelectArea(_cAlias)
	   (_cAlias)->( DBGoTop() )
	   Count To _nTotReg // (_cAlias)->( DBEval( {|| _nTotReg++ } ) )
	   (_cAlias)->( DBGoTop() )
	
	   SPC->(DBSETORDER(2))
	   SPK->(DBSETORDER(1))
	   SP6->(DBSETORDER(1))
	   SP9->(DBSETORDER(1))
	
	   ProcRegua(_nTotReg)
	
	   Do While (_cAlias)->(!Eof())
		
		  _nAtuReg++
		  oProc:cCaption := ( "Lendo Marcacoes ["+ StrZero( _nAtuReg , 9 ) +"] de ["+ StrZero( _nTotReg , 9 ) +"]" )
	      ProcessMessages()

          _aItens:={}
          aAdd( _aItens ,   (_cAlias)->FILIAL	)
          aAdd( _aItens ,   (_cAlias)->MAT	    )
		  _cNomeFunc := Posicione("SRA",1,(_cAlias)->FILIAL+(_cAlias)->MAT,"RA_NOME")
		  If ! Empty(SRA->RA_NSOCIAL)
		     _cNomeFunc := SRA->RA_NSOCIAL
		  EndIf
          aAdd( _aItens ,   _cNomeFunc )
          aAdd( _aItens ,   (_cAlias)->SETOR	)
          aAdd( _aItens ,   Posicione("ZAK",1,xFilial("ZAK")+(_cAlias)->SETOR,"ZAK_DESCRI") )
          aAdd( _aItens ,   (_cAlias)->TURNO )
          aAdd( _aItens ,   Posicione("SR6",1,(_cAlias)->FILIAL+(_cAlias)->TURNO,"R6_DESC") )
          aAdd( _aItens ,   DTOC( STOD((_cAlias)->DATA_APO ) ) )
		
	      _cPC_PD:=""
		  If SPC->(DBSEEK((_cAlias)->FILIAL+(_cAlias)->MAT+(_cAlias)->DATA_APO)) 
		     Do While SPC->(!EOF()) .AND. (_cAlias)->FILIAL+(_cAlias)->MAT+(_cAlias)->DATA_APO == SPC->PC_FILIAL+SPC->PC_MAT+DTOS(SPC->PC_DATA)
		        If ! SPC->PC_PD+"-" $ _cPC_PD
		           _cPC_PD+=SPC->PC_PD+"-"+Posicione("SP9",1,(_cAlias)->FILIAL+SPC->PC_PD ,"P9_DESC")+CRLF		      
			    EndIf
			    SPC->(DBSkip())
             EndDo
		  EndIF

	      _cPK_CODABO:=""
		  If SPK->(DBSEEK((_cAlias)->FILIAL+(_cAlias)->MAT+(_cAlias)->DATA_APO ))
		     Do While SPK->(!EOF()) .AND. (_cAlias)->FILIAL+(_cAlias)->MAT+(_cAlias)->DATA_APO == SPK->PK_FILIAL+SPK->PK_MAT+DTOS(SPK->PK_DATA)
		        If !SPK->PK_CODABO+"-" $ _cPK_CODABO
		           _cPK_CODABO += SPK->PK_CODABO + "-" + Posicione("SP6",1,SPK->PK_FILIAL+SPK->PK_CODABO ,"P6_DESC") + CRLF		      
			    EndIf
			    SPK->(DBSkip())
             EndDo
		  EndIF
		  _cPK_CODABO:=LEFT(_cPK_CODABO,LEN(_cPK_CODABO)-2)
        
		  _cChave := (_cAlias)->FILIAL + (_cAlias)->MAT + (_cAlias)->DATA_APO 
		  _cMarcacao:=""
	      Do While (_cAlias)->(!Eof()) .AND. _cChave == (_cAlias)->FILIAL+(_cAlias)->MAT + (_cAlias)->DATA_APO 
             _cMarcacao+= (_cAlias)->HORA+" - "
			 (_cAlias)->(DBSkip())
          EndDo
		  
		  _cMarcacao:=LEFT(_cMarcacao,LEN(_cMarcacao)-3)
        
		  aAdd( _aItens ,  _cMarcacao )
	      aAdd( _aItens ,  _cPC_PD    )
	      aAdd( _aItens ,  _cPK_CODABO)

          aAdd( _aDados , _aItens )
		  
		  If Empty(_cMarcacao)
		     (_cAlias)->( DBSkip() )
		  EndIf 
	   EndDo

	   oProc:cCaption := ( "Lendo Faltas da Filial [ "+_aFiliais[_nI]+" ]" )
       ProcessMessages()

	   (_cAlias)->( Dbclosearea() )

       _cQry := ""
	   _cQry += " SELECT "+ CRLF
	   _cQry += "     SPC.PC_FILIAL   AS FILIAL,   "+ CRLF
	   _cQry += "     SRA.RA_I_SETOR  AS SETOR,    "+ CRLF
	   _cQry += "     SPC.PC_MAT      AS MAT,      "+ CRLF
	   _cQry += "     SPC.PC_DATA     AS DATA_APO, "+ CRLF
	   _cQry += "     SPC.PC_TURNO    AS TURNO,    "+ CRLF
	   _cQry += "     SPC.PC_PD                    "+ CRLF
	   _cQry += " FROM "+ RetSqlName("SPC") +" SPC "+ CRLF
	   _cQry += " INNER JOIN "+ RetSqlName("SRA") +" SRA ON "+ CRLF
	   _cQry += "     SRA.RA_FILIAL = SPC.PC_FILIAL "+ CRLF
	   _cQry += " AND SRA.RA_MAT    = SPC.PC_MAT    "+ CRLF
	   _cQry += " WHERE "+ CRLF
	   _cQry += "     SPC.D_E_L_E_T_  = ' ' "+ CRLF
	   _cQry += " AND SRA.D_E_L_E_T_  = ' ' "+ CRLF
	
	   If ! Empty( MV_PAR07 )	
		  _cQry += " AND SRA.RA_I_SETOR	IN "+ FormatIn( AllTrim( MV_PAR07 ) , ";" ) + CRLF	
	   EndIF

	   If ! Empty( MV_PAR06 )	
	      _cQry += " AND SPC.PC_TURNO BETWEEN '"+ MV_PAR05 +"' AND '"+ MV_PAR06 +"' "+ CRLF
	   EndIF

 	   _cQry += " AND SPC.PC_PD  = '413' "+ CRLF
	   _cQry += " AND SPC.PC_FILIAL  = '"+ _aFiliais[_nI] +"' " + CRLF
	   _cQry += " AND SPC.PC_DATA BETWEEN '"+ DTOS( MV_PAR01 ) +"' AND '"+ DTOS( MV_PAR02 ) +"' "+ CRLF
	   _cQry += " AND SPC.PC_MAT  BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"' "+ CRLF
	
	   _cQry += " ORDER BY FILIAL, SETOR, MAT, DATA_APO"+ CRLF
	
	   //DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQry) , _cAlias , .T. , .T. )
	   MPSysOpenQuery( _cQry , _cAlias )
	
	   _nAtuReg := 0
	   _nTotReg := 0
	
	   DBSelectArea(_cAlias)
	   (_cAlias)->( DBGoTop() )
	   Count To _nTotReg // (_cAlias)->( DBEval( {|| _nTotReg++ } ) )
	   (_cAlias)->( DBGoTop() )
	
	   ProcRegua(_nTotReg)
	
	   Do While (_cAlias)->(!Eof())
		
		  _nAtuReg++
		  oProc:cCaption := ( "Lendo Faltas ["+ StrZero( _nAtuReg , 9 ) +"] de ["+ StrZero( _nTotReg , 9 ) +"]" )
	      ProcessMessages()

          _aItens:={}
          aAdd( _aItens ,   (_cAlias)->FILIAL	)
          aAdd( _aItens ,   (_cAlias)->MAT	    )
		  _cNomeFunc := Posicione("SRA",1,(_cAlias)->FILIAL+(_cAlias)->MAT,"RA_NOME")
		  
		  If !EMPTY(SRA->RA_NSOCIAL)
		     _cNomeFunc:=SRA->RA_NSOCIAL
		  EndIf 
           
		  aAdd( _aItens ,   _cNomeFunc )
          aAdd( _aItens ,   (_cAlias)->SETOR	)
          aAdd( _aItens ,   Posicione("ZAK",1,xFilial("ZAK")+(_cAlias)->SETOR,"ZAK_DESCRI") )
          aAdd( _aItens ,   (_cAlias)->TURNO )
          aAdd( _aItens ,   Posicione("SR6",1,(_cAlias)->FILIAL+(_cAlias)->TURNO,"R6_DESC") )
          aAdd( _aItens ,   DTOC( STOD((_cAlias)->DATA_APO ) ) )
		
          _cPC_PD:=(_cAlias)->PC_PD+"-"+Posicione("SP9",1,(_cAlias)->FILIAL+(_cAlias)->PC_PD ,"P9_DESC")      

	      _cPK_CODABO:=""
		  If SPK->(DBSEEK((_cAlias)->FILIAL+(_cAlias)->MAT+(_cAlias)->DATA_APO ))
		     Do While SPK->(!EOF()) .AND. (_cAlias)->FILIAL+(_cAlias)->MAT+(_cAlias)->DATA_APO == SPK->PK_FILIAL+SPK->PK_MAT+DTOS(SPK->PK_DATA)
		        If ! SPK->PK_CODABO + "-" $ _cPK_CODABO
		           _cPK_CODABO += SPK->PK_CODABO + "-" + Posicione("SP6",1,SPK->PK_FILIAL+SPK->PK_CODABO ,"P6_DESC") + CRLF		      
			    EndIf
			    
				SPK->(DBSkip())
             EndDo 
		  EndIf
		  
		  _cPK_CODABO := Left(_cPK_CODABO,LEN(_cPK_CODABO)-2)
        
		  _cMarcacao:="SEM MARCAOES"
        
		  aAdd( _aItens ,  _cMarcacao )
	      aAdd( _aItens ,  _cPC_PD    )
	      aAdd( _aItens ,  _cPK_CODABO)

          aAdd( _aDados , _aItens )
	      
		  (_cAlias)->( DBSkip() )
	   EndDo

       (_cAlias)->( Dbclosearea() )

   Next _nI

   If Empty( _aDados )
	  U_ITMSG(  "N�o foram encontrados registros para exibir! Verifique os par�metros e tente novamente." , "Aten��o!" ,,1 )
	  Break 
   Else
      _aCabec	:= {}
      Aadd(_aCabec,"Filial"    )
      Aadd(_aCabec,"Matricula" )
      Aadd(_aCabec,"Nome do Funcionario"      )
      Aadd(_aCabec,"Cod. Setor")
      Aadd(_aCabec,"Descricoes dos Setor")
      Aadd(_aCabec,"Cod Turno" )
      Aadd(_aCabec,"Turno"     )
      Aadd(_aCabec,"Data Apontamento")
      Aadd(_aCabec,"Marcacoes")
      Aadd(_aCabec,"Descricoes dos Eventos")
      Aadd(_aCabec,"Descricoes dos Abono"  )
      
	  _aCabecx := ACLONE(_aCabec)

	  U_ITListBox( TITULO + " (Per�odo Fechado)", _aCabecx , _aDados , .T. )
   EndIf

End Sequence 

Return .T.

