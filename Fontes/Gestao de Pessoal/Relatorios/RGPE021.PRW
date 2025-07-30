/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |09/10/2024| Chamado 48465. Retirada manipulação do SX1
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE "PROTHEUS.CH"
#Define CRLF	Chr(13)+Chr(10)

/*
===============================================================================================================================
Programa----------: RGPE021
Autor-------------: Alex Wallauer
Data da Criacao---: 10/09/2021
Descrição---------: Relatório de Conferências de Folgas do dia 31 . Chamado 37715
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function RGPE021()

Local _cTitulo    := "Relatório de Conferências de Folgas do dia 31" , M , C
Private _nMesMax  := 12
Private _aPeriodo := {}
Private _aPergunts:= {}

SET DATE FORMAT TO "DD/MM/YYYY"

DO WHILE Pergunte("RGPE021",,_cTitulo)	          
                                                                                                             //ANO INICIAL          MAIOR QUE ANO FINAL                       //SE ANOS IGUAIS                       E   MES INICIAL         MAIOR QUE MES FINAL
   IF (LEN(ALLTRIM(MV_PAR06))+LEN(ALLTRIM(MV_PAR07))) < 12 .OR.;
       EMPTY(MV_PAR06) .OR.  EMPTY(MV_PAR07) .OR.;
       Val(SUBST(ALLTRIM(MV_PAR07),3,4)) < Val(SUBST(ALLTRIM(MV_PAR06),3,4)) .OR.;
       VAl(SUBST(MV_PAR06,3)) > VAl(SUBST(MV_PAR07,3)) .OR.;
      (VAl(SUBST(MV_PAR06,3)) = VAl(SUBST(MV_PAR07,3)) .AND.;
       VAl(LEFT(MV_PAR06,2)) > VAl(LEFT(MV_PAR07,2))  )
      U_ITMSG("Periodo INVALIDO",'Atenção!',"Tente novamente com outro periodo com as 2 datas preenchidas no formato MMAAAA",3)
      LOOP
   ENDIF
   MV_PAR06 := SUBSTR(MV_PAR06,1,2) + "/" + SUBSTR(MV_PAR06,3,4)
   MV_PAR07 := SUBSTR(MV_PAR07,1,2) + "/" + SUBSTR(MV_PAR07,3,4)

   
   If ALLTRIM(MV_PAR06) == ALLTRIM(MV_PAR07)
      nMeses := 1
   ELSEIf Val(SubStr(ALLTRIM(MV_PAR07),1,2)) - Val(SubStr(ALLTRIM(MV_PAR06),1,2)) = 1
      nMeses := 2 
   ELSE
      nMeses := INT((((LASTDAY(CTOD("01/"+MV_PAR07))-(CTOD("01/"+MV_PAR06)))/30)))+1
   ENDIF
   
   IF nMeses > _nMesMax
      U_ITMSG("Periodo INVALIDO de "+ALLTRIM(STR(nMeses))+" meses." ,'Atenção!',"Periodo nao pode ser maior que 12 meses",3)
      LOOP
   ENDIF

   cTimeInicial:=TIME()
   _cTexto:= ALLTRIM(MV_PAR06)
   AADD(_aPeriodo,_cTexto)//o primeiro periodo coloco fora do FOR por isso (_nMesMax-1)
   FOR M := 1 TO (_nMesMax-1)//MONTA SEMPRE _nMesMax DE MESES , INDENPENDETE DO PERIODO FILTRO 
       _nMes:=Val(SubStr(_cTexto,1,2))
       If _nMes < 12//NAO mexer nesse numero 12 é referente a DESEMBRO
          _cTexto:=STRZERO(_nMes+1,2)+SUBSTR(_cTexto,3)//SOMA AQUI + 1 MES NO MESMO ANO
       ELSE
          _cTexto:="01/"+ALLTRIM(STR(VAL(SUBSTR(_cTexto,4))+1))//SOMA AQUI + 1 ANO QUANDO TROCA DE DESEMBRO PARA JANEIRO 
       ENDIF
       AADD(_aPeriodo,_cTexto)
   NEXT
   MV_PAR06 := CTOD("01/"+ MV_PAR06)
   MV_PAR07 := LASTDAY(CTOD("01/"+ MV_PAR07))
   MV_PAR08 := U_ITSEPDEL( MV_PAR08 , 1 , ";" , "*" )
   _aDados  := {}
   _lSair   := .F.

   FWMSGRUN( ,{|oproc| _aDados := RGPE021SEL(oproc) } , "Aguarde!" , "Lendo dados..." )

    IF LEN(_aDados) > 0

        aCab:={}
        AADD(aCab,"Filial")
        AADD(aCab,"Matricula")
        AADD(aCab,"Nome") ; nPosFiltro:=LEN(aCab)
        AADD(aCab,"Dt. Admissao")
        AADD(aCab,"Setor")
        AADD(aCab,"Funcao")
        AADD(aCab,"Turno")
        AADD(aCab,"Banco de Horas")
        AADD(aCab,"Faltas")
        AADD(aCab,"Dias Gozados")
        FOR M := 1 TO LEN(_aPeriodo) 
            AADD(aCab,_aPeriodo[M])
        NEXT
        AADD(aCab,"Total Dias Afastamento")

        AADD(_aPergunts,{"0-FILTROS"         ,""})
        AADD(_aPergunts,{"1-Filial/Filiais?" ,ALLTRIM(AllToChar(MV_PAR01))})
        AADD(_aPergunts,{'2-Matricula De ?'  ,ALLTRIM(AllToChar(MV_PAR02))})
        AADD(_aPergunts,{'3-Matricula Até ?' ,ALLTRIM(AllToChar(MV_PAR03))})
        AADD(_aPergunts,{'4-Setor De ?'      ,ALLTRIM(AllToChar(MV_PAR04))})
        AADD(_aPergunts,{'5-Setor Ate ?'     ,ALLTRIM(AllToChar(MV_PAR05))})
        AADD(_aPergunts,{"6-Mes/Ano Inicial?",ALLTRIM(AllToChar(MV_PAR06))})
        AADD(_aPergunts,{"7-Mes/Ano Final?"  ,ALLTRIM(AllToChar(MV_PAR07))})
        AADD(_aPergunts,{'8-Situações ?'     ,ALLTRIM(AllToChar(MV_PAR08))})

        FOR M := 1 TO LEN (_aPergunts)
            AADD( _aDados, {} )
            FOR C := 1 TO LEN(aCab)
		          AADD( _aDados[LEN(_aDados)], "" )
            NEXT
            _aDados[LEN(_aDados),nPosFiltro]:=_aPergunts[M,1]+" "+_aPergunts[M,2]//Na coluna no coloca os parametros 
        NEXT

        _cTitulo:="Relatório de Conferências de Folgas do dia 31"+' - Data: ' + DtoC(Date()) +" -  H.I.: "+cTimeInicial+" H.F.: "+TIME()
        _cMsgTop:="Par. 1: "+ALLTRIM(AllToChar(MV_PAR01))+"; Par. 2: "+ALLTRIM(AllToChar(MV_PAR02))+"; Par. 3: "+ALLTRIM(AllToChar(MV_PAR03))+"; Par. 4: "+ALLTRIM(AllToChar(MV_PAR04))+;
                "; Par. 5: "+ALLTRIM(AllToChar(MV_PAR05))+"; Par. 6: "+ALLTRIM(AllToChar(MV_PAR06))+"; Par. 7: "+ALLTRIM(AllToChar(MV_PAR07))+"; Par. 7: "+ALLTRIM(AllToChar(MV_PAR08))

                                //       ,_aCols  ,_lMaxSiz,_nTipo,_cMsgTop, _lSelUnc ,_aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca )
       _lSair:=!U_ITListBox(_cTitulo,aCab,_aDados , .T.    , 1    ,_cMsgTop,          ,        ,         ,     ,        ,          ,       ,         ,          ,            )
    
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
Programa----------: RGPE021SEL
Autor-------------: Alex Wallauer
Data da Criacao---: 10/09/2021
Descrição---------: Carga de dados para o relatório
Parametros--------: oproc - objeto da barra de processmento 
Retorno-----------: _aret - dados coletados do banco
===============================================================================================================================
*/
Static Function RGPE021SEL(oproc)


Local _aRet			:= {}
Local _cAlias		:= GetNextAlias()
Local _aFiliais		:= {}
Local _cQuery		:= ""
Local _nI , T		:= 0

Default oproc := nil

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
	If !EMPTY(MV_PAR02) .AND. !EMPTY(MV_PAR03)
		_cQuery += " AND RA_MAT BETWEEN '"+ MV_PAR02 +"' AND '"+ MV_PAR03 +"' "+ CRLF
	Endif
	If !EMPTY(MV_PAR04) .AND. !EMPTY(MV_PAR05) 
		_cQuery += " AND RA_I_SETOR BETWEEN '"+ MV_PAR04 +"' AND '"+ MV_PAR05 +"' "+ CRLF
	Endif 
	If !EMPTY(MV_PAR08)
		_cQuery += " AND SRA.RA_SITFOLH IN "+ FormatIn( ALLTrim( MV_PAR08 ) , ";" )	+ CRLF
	Endif
   _cQuery += " ORDER BY SRA.RA_MAT "
	
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
		
        IF valtype(oproc) = "O"
		    _nni++
			oproc:cCaption := ("Lendo Filial: " + _aFiliais[_ni] + " / funcionario " +STRZERO(_nni,_nTam) +" de "+ _cTot )
			ProcessMessages()
		ENDIF
		SRA->(Dbgoto((_cAlias)->RECNO))

      _nFaltas	:= _nAbono := 0
      BuscaEventos()
      aTestados:=BuscaAfas(SRA->RA_FILIAL,SRA->RA_MAT)
					
		aAdd( _aRet , {	;
                        ALLTRIM(SRA->RA_FILIAL)	                                                                    ,; //Filial
						      ALLTRIM(SRA->RA_MAT)						                                                        ,; //Matrícula
						      ALLTRIM(Capital(AllTrim(IF(!EMPTY(SRA->RA_NSOCIAL),SRA->RA_NSOCIAL,SRA->RA_NOME) )))        ,; //Funcionário
						      DTOC(SRA->RA_ADMISSA)				                                                           ,; //Dt Admissao 
						      ALLTRIM(SRA->RA_I_SETOR+"-"+POSICIONE("ZAK",1,xfilial("ZAK")+SRA->RA_I_SETOR,"ZAK_DESCRI")) ,; //Desc. Setor
							   ALLTRIM(POSICIONE("SRJ",1,xfilial("SRJ")+SRA->RA_CODFUNC,"RJ_DESC"))                        ,; //Desc. Funçao 
						      ALLTRIM(SRA->RA_TNOTRAB+"-"+Posicione("SR6",1,SRA->RA_FILIAL+SRA->RA_TNOTRAB,"R6_DESC"))	  ,; //Desc. Turno
                        IF(SPI->(DBSEEK( SRA->RA_FILIAL + SRA->RA_MAT )),"Sim","Nao")                               ,; //Banco de Horas
                        ALLTRIM(STR(_nFaltas))                                                                      ,; //Faltas
						      ALLTRIM(STR(_nAbono))			                                                              }) //DIAS GOZADOS
        _nTotAfastados:=0
        FOR T := 1 TO LEN (aTestados)
		    AADD( _aRet[LEN(_aRet)] , ALLTRIM(STR(aTestados[T])))
          _nTotAfastados+=aTestados[T]
        NEXT
	     AADD( _aRet[LEN(_aRet)] , ALLTRIM(STR(_nTotAfastados)))//"Total de dias Afastamento"			                                                        ,; //Total de dias Afastamento
						
		
        (_cAlias)->(Dbskip())
		
	Enddo

Next _nI

Return( _aRet )
/*
===============================================================================================================================
Função------------: BuscaAfas
Autor-------------: Alex Wallauer
Data da Criacao---: 24/06/2020
Descrição---------: Retornar a ultima data de afastamento do funcionário.
Parametros--------: _cFilial    = Filial do funcionário
                    _cMatricula = Código de matricula
Retorno-----------: _DataAfast  = Data de afastamento do funcionário.
===============================================================================================================================
*/
Static function BuscaAfas(_cFilial, _cMatricula)
Local _cQry      :=""
Local _cAlias    := GetNextAlias()
LOCAL _aTestados :={} , M
LOCAL _dUltDiaMes:= LASTDAY(dDatabase)


FOR M := 1 TO _nMesMax
    AADD(_aTestados,0)
NEXT

_cQry += " SELECT R8_DATAINI , R8_DATAFIM FROM "+RetSqlName("SR8")+ " SR8 "+ CRLF
_cQry += " WHERE SR8.R8_FILIAL = '" + _cFilial + "' AND SR8.D_E_L_E_T_ = ' ' "+ CRLF
_cQry += " AND SR8.R8_MAT = '" + _cMatricula + "' "+ CRLF
_cQry += " AND SR8.R8_TIPOAFA <> '001' "+ CRLF
_cQry += " AND (SR8.R8_DATAINI BETWEEN '"+ DTOS( MV_PAR06 ) +"' AND '"+ DTOS( MV_PAR07 ) +"'  "+ CRLF
_cQry += "  OR  SR8.R8_DATAFIM BETWEEN '"+ DTOS( MV_PAR06 ) +"' AND '"+ DTOS( MV_PAR07 ) +"'  "+ CRLF
_cQry += "  OR  (SR8.R8_DATAFIM = ' '  AND SR8.R8_DATAINI <= '"+ DTOS( MV_PAR07 )        +"'))"+ CRLF
_cQry += " ORDER BY SR8.R8_DATAINI "
		
DBUseArea( .T. , "TOPCONN" , TCGenQry(,,_cQry) , _cAlias , .F. , .T. )
	
(_cAlias)->( DBGoTop() )
Do While (_cAlias)->( !Eof() )
  
   IF STOD((_cAlias)->R8_DATAINI) > MV_PAR06//DATA INICIAL MAIOR QUE A DO FILTRO VALE ELA 
      _dDtAux:=STOD((_cAlias)->R8_DATAINI)
   ELSE//SENÃO A DO FILTRO
      _dDtAux:=MV_PAR06
   ENDIF

   IF EMPTY((_cAlias)->R8_DATAFIM)  .OR. STOD((_cAlias)->R8_DATAFIM) > MV_PAR07//SE DATA FIM EM BRANCO OU MAIOR QUE A DO FILTRO VALE A DO FILTRO
      IF MV_PAR07 <= _dUltDiaMes//SE DATA FIM DO FILTRO FOR MENOR QUE A DO DIA DO MES CORRENTE
         _dDtFimAux:=MV_PAR07
      ELSE
         _dDtFimAux:=_dUltDiaMes
      ENDIF
   ELSE
      _dDtFimAux:=STOD((_cAlias)->R8_DATAFIM)
   ENDIF

   DO WHILE _dDtAux <= _dDtFimAux
      
      _cAchaCol:=SUBSTR(DTOS(_dDtAux),5,2)+"/"+LEFT(DTOS(_dDtAux),4)
      
      nPos :=ASCAN(_aPeriodo,_cAchaCol)
      IF nPos > 0
         _aTestados[nPos]++//SOMA NO MES DA DATA
     ELSE//TEM QUE ACHAR PQ SENAO TEM ALGUMA COISA ERRADA NA BASE
        U_ITMSG("Periodo "+_cAchaCol+" nao encontrado [ "+DTOC(_dDtAux)+" ]",'Atenção!',"FAVOR ENTRAR EM CONTATO COM A AREA DE TI COM PRINT DESSA MENSAGEM",3)
        EXIT
     ENDIF   
      _dDtAux:=(_dDtAux+1)//SOMA 1 DIA NA DATA CORRENTE
   ENDDO
		
   (_cAlias)->( DBSkip() )
EndDo
	
(_cAlias)->( DBCloseArea() )


Return _aTestados

/*
===============================================================================================================================
Programa----------: BuscaEventos
Autor-------------: Alex Wallauer
Data da Criacao---: 24/06/2020
Descrição---------: Retorna Faltas do funcionario.	
Parametros--------: SRA POSICIONADA
Retorno-----------: Preenche _nFaltas / _nAbono
===============================================================================================================================
*/
Static Function BuscaEventos()
Local _cAlias	:= GetNextAlias()
Local _cQuery	:= ""

_cQuery += " SELECT SPC.PC_PD PD_413 ,SPC.PC_ABONO ABONO_28 "+ CRLF
_cQuery += " FROM "+ RetSqlName("SPC") +" SPC "+ CRLF
_cQuery += " WHERE "+ CRLF
_cQuery += "     SPC.D_E_L_E_T_  = ' ' "+ CRLF
_cQuery += " AND (SPC.PC_PD  = '413' "+ CRLF
_cQuery += " OR   SPC.PC_ABONO = '028') " + CRLF
_cQuery += " AND SPC.PC_FILIAL  = '"+ SRA->RA_FILIAL +"' " + CRLF
_cQuery += " AND SPC.PC_DATA BETWEEN '"+ DTOS( MV_PAR06 ) +"' AND '"+ DTOS( MV_PAR07 ) +"' "+ CRLF
_cQuery += " AND SPC.PC_MAT = '"+SRA->RA_MAT+"' "+ CRLF

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .T. )


DO WHILE !(_cAlias)->(Eof())
   IF (_cAlias)->ABONO_28 = '028'
      _nAbono++
   ELSEIF (_cAlias)->PD_413 = "413" .AND. EMPTY((_cAlias)->ABONO_28)
     _nFaltas++
   ENDIF
   (_cAlias)->(DBSKIP())
ENDDO
(_cAlias)->(DbCloseArea())

_cQuery := " SELECT SPH.PH_PD PD_413,SPH.PH_ABONO ABONO_28"+ CRLF
_cQuery += " FROM "+ RetSqlName("SPH") +" SPH "+ CRLF
_cQuery += " WHERE "+ CRLF
_cQuery += "     SPH.D_E_L_E_T_  = ' ' "+ CRLF
_cQuery += " AND (SPH.PH_PD  = '413' "+ CRLF
_cQuery += " OR   SPH.PH_ABONO = '028') " + CRLF
_cQuery += " AND SPH.PH_FILIAL  = '"+ SRA->RA_FILIAL +"' " + CRLF
_cQuery += " AND SPH.PH_DATA BETWEEN '"+ DTOS( MV_PAR06 ) +"' AND '"+ DTOS( MV_PAR07 ) +"' "+ CRLF
_cQuery += " AND SPH.PH_MAT = '"+SRA->RA_MAT+"' "+ CRLF

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .T. )

DO WHILE !(_cAlias)->(Eof())
   IF (_cAlias)->ABONO_28 = '028'
      _nAbono++
   ELSEIF (_cAlias)->PD_413 = "413" .AND. EMPTY((_cAlias)->ABONO_28)
     _nFaltas++
   ENDIF
   (_cAlias)->(DBSKIP())
ENDDO
(_cAlias)->(DbCloseArea())

Return .T.
