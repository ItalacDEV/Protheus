/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer |25/07/2017| Chamado 20915. Ajuste no SELECT e zerar a variavel _nVlrMix e recalulo com ZLJ
Alex Wallauer |15/08/2017| Chamado 21123. Adicionado tratamento para recepções manuais
Lucas Borges  |08/10/2024| Chamado 48465. Retirada manipulação do SX1
======================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#include "protheus.ch"
#include "topconn.ch" 
#INCLUDE "RWMAKE.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "FONT.CH"

/*
===============================================================================================================================
Programa----------: MEST012 
Autor-------------: Alexandro Ferreira
Data da Criacao---: 04/08/2016 
===============================================================================================================================
Descrição---------: Rotina de recálculo de custo de recepção do leite próprio - Chamado 15507
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/                     
User Function MEST012()

Local _cPerg   	:="MEST012"
Local _bProcess	:= nil
Local _oprocess	:= nil

Private _lsai		:= .F.

Do while .not. _lsai

	_lsai := .T.

	//============================================
	//Cria interface principal
	//============================================
	_bProcess    := {|_oprocess| MEST012E(_oprocess) }
	tNewProcess():New( _cPerg, "Rotina de recálculo do custo de entrada de recepção do leite próprio",;
								 _bProcess, "Rotina de recálculo do custo de entrada de recepção do leite próprio","MEST012")
							 
Enddo

return	
	
/*
===============================================================================================================================
Programa----------: MEST012E 
Autor-------------: Josué Prestes
Data da Criacao---: 04/08/2016 
===============================================================================================================================
Descrição---------: Processamento de recálculo de custo de entrada do leite próprio
===============================================================================================================================
Parametros--------: _oprocess
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static function MEST012E(_oprocess)	

Local _cAlias := GetNextAlias()
Local _nDias  := 0
Local _cDiasT := MV_PAR02-MV_PAR01+1
Local _cPicCus:= "@E 999,999,999,999.99"//PesqPict("SD3","D3_CUSTO1")
Local _nVlrMix:= 0,S
PRIVATE _aLog 	:= {}

_oProcess:SetRegua1(4)
_oProcess:SetRegua2(4)

_oProcess:IncRegua1("Processando o periodo...")
_oProcess:IncRegua2("Data Inicial: "+DTOC(MV_PAR01)+" ate Data Final: "+DTOC(MV_PAR02) )

_oProcess:IncRegua1("Processando o periodo...")
_oProcess:IncRegua2("Data Inicial: "+DTOC(MV_PAR01)+" ate Data Final: "+DTOC(MV_PAR02) )

_dDtini  := MV_PAR01
_dDtfim  := MV_PAR02

IF EMPTY(_dDtini) .OR. EMPTY(_dDtfim)
   Aviso( 'Atenção!' , "As duas datas devem ser preenchidas" , {'Voltar'} ) 
	_lsai := .F.
   RETURN .F.
ENDIF
_dDtMV_ULMES:= StoD( POSICIONE("SX6",1,cFilant+"MV_ULMES","X6_CONTEUD") )
IF _dDtini <= _dDtMV_ULMES
   Aviso( 'Atenção!' , "Data inicial menor ou igual que a data do fechamento do estoque: [ "+DTOC(_dDtMV_ULMES)+" ] " , {'Voltar'} ) 
	_lsai := .F.
   RETURN .F.
ENDIF
IF _dDtini > _dDtfim
  Aviso( 'Atenção!' , "Data inicial deve ser menor que a data final" , {'Voltar'} ) 
	_lsai := .F.
  RETURN .F.
ENDIF


_cQuery1:= " SELECT COUNT(DISTINCT SD3.R_E_C_N_O_) TOTAL  "

_cQuery2:= " SELECT DISTINCT SD3.R_E_C_N_O_ REC_SD3 "

_cQuery := " FROM "+ RetSqlName("SD3") +" SD3 "
_cQuery += "INNER JOIN "+ RetSqlName("ZLJ") +" ZLJ ON "
_cQuery += "  SD3.D3_FILIAL||TRIM(SD3.D3_L_ORIG)||SD3.D3_L_SETOR = ZLJ.ZLJ_FILIAL||ZLJ.ZLJ_VIAGEM||ZLJ.ZLJ_SETOR  AND "
_cQuery += "  ZLJ.D_E_L_E_T_ = ' ' AND ZLJ.ZLJ_DTIVIA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
_cQuery += "LEFT JOIN "+ RetSqlName("ZLD") +" ZLD ON "
_cQuery += "  SD3.D3_FILIAL||TRIM(SD3.D3_L_ORIG)||SD3.D3_L_SETOR = ZLD.ZLD_FILIAL||ZLD.ZLD_TICKET||ZLD.ZLD_SETOR  AND "
_cQuery += "  ZLD.D_E_L_E_T_ = ' ' AND ZLD.ZLD_DTCOLE BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
_cQuery += " WHERE  SD3.D_E_L_E_T_ = ' ' AND SD3.D3_ESTORNO <> 'S' "
IF !EMPTY(MV_PAR03)
   _cQuery += " AND SD3.D3_FILIAL IN "+FormatIn( ALLTRIM(MV_PAR03) , ';' )
ENDIF
_cQuery += "    UNION "

_cQuery4 := " FROM "+ RetSqlName("SD3") +" SD3 "
_cQuery4 += "INNER JOIN "+ RetSqlName("ZLD") +" ZLD ON "
_cQuery4 += "  SD3.D3_FILIAL||TRIM(SD3.D3_L_ORIG)||SD3.D3_L_SETOR = ZLD.ZLD_FILIAL||ZLD.ZLD_TICKET||ZLD.ZLD_SETOR  AND "
_cQuery4 += "  ZLD.D_E_L_E_T_ = ' ' AND ZLD.ZLD_DTCOLE BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
_cQuery4 += " WHERE  SD3.D_E_L_E_T_ = ' ' AND SD3.D3_ESTORNO <> 'S'  AND SUBSTR(SD3.D3_L_ORIG,1,1) <> 'S' "
IF !EMPTY(MV_PAR03)
   _cQuery4 += " AND SD3.D3_FILIAL IN "+FormatIn( ALLTRIM(MV_PAR03) , ';' )
ENDIF
	
If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf
	
DBUseArea( .T. , "TOPCONN" , TCGenQry( ,, _cQuery1+_cQuery+_cQuery1+_cQuery4 ) , _cAlias , .F. , .T. )

_oProcess:IncRegua1("Processando o periodo...")
_oProcess:IncRegua2("Data Inicial: "+DTOC(MV_PAR01)+" ate Data Final: "+DTOC(MV_PAR02) )

(_cAlias)->(dbgotop())
_nTotal:=(_cAlias)->TOTAL
(_cAlias)->(dbskip())
_nTotal+=(_cAlias)->TOTAL

If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf

_cDiasT := ALLTRIM(STR(_nTotal,10))	
	
DBUseArea( .T. , "TOPCONN" , TCGenQry( ,, _cQuery2+_cQuery+_cQuery2+_cQuery4 ) , _cAlias , .F. , .T. ) 

_oProcess:IncRegua1("Processando o periodo...")
_oProcess:IncRegua2("Data Inicial: "+DTOC(MV_PAR01)+" ate Data Final: "+DTOC(MV_PAR02) )

IF !MSGYESNO("Serao processados "+ALLTRIM(STR(_nTotal,10))+" registros. Continua?")
   RETURN .T.
ENDIF

_oProcess:SetRegua1(_nTotal)
_oProcess:SetRegua2(_nTotal)

(_cAlias)-> ( dbgotop() )
_nAcertos:=0
DO While !(_cAlias)->( eof() )

   SD3->(DBGOTO( (_cAlias)->REC_SD3 ) )
		
   _nDias++
   _oProcess:IncRegua1("Processando Data: "+DTOC(SD3->D3_EMISSAO))
   _oProcess:IncRegua2("Lendo registro: "+ALLTRIM(STR(_nDias,10))+" de "+_cDiasT+" ..." )

   If EMPTY(SD3->D3_L_ORIG)
      (_cAlias)->(dbskip())
      LOOP
   ENDIF		
   
   _nValor  := 0
   _cSetorPA:= SD3->D3_L_SETOR 
   _cSetores:= SD3->D3_L_SETOR 

   AADD( _aLog , {"",;//1
                  SD3->D3_FILIAL,;//2
                  ""            ,;//3 //Data de coleta do ZLD
                  ALLTRIM(SD3->D3_L_ORIG),;//4
                  SD3->D3_L_SETOR,;//5 Setor Anterior
                  SD3->D3_L_SETOR,;//6 Setores Atualizados
                  TRANSF(SD3->D3_QUANT,PesqPict("SD3","D3_QUANT")),;//7
                  TRANSF(SD3->D3_CUSTO1,_cPicCus),;//8 - 'Custo Anterior'
                  TRANSF(SD3->D3_CUSTO1,_cPicCus),;//9 - 'Custo Recalculado'
                  DTOC(SD3->D3_EMISSAO)          })//10 - Data de entrada no Estoque
   nPosCA:=LEN(_aLog[1])-1//Posicao do custo total

   ZLD-> ( DBSETORDER(5) )//ZLD_FILIAL+ZLD_TICKET+ZLD_SETOR
   ZLJ-> ( DBSETORDER(2) )//ZLJ_FILIAL+ZLJ_VIAGEM
		
   If LEFT(SD3->D3_L_ORIG,1)  = "S"
      _aSetores:= {}
      _nTotal  := 0 
      _cSetores:=""
		
	  IF ZLD->( DBSeek(SD3->D3_FILIAL+ALLTRIM(SD3->D3_L_ORIG)) )

         MEST012Calc("ZLD")

      ELSEIF ZLJ->( DBSeek(SD3->D3_FILIAL+ALLTRIM(SD3->D3_L_ORIG)) ) 

	         IF ZLJ->ZLJ_STATUS = "P"

                MEST012Calc("ZLJ")//Ticket nao efetivado

             ELSEIF ZLJ->ZLJ_STATUS = "E"//Ticket efetivado
                _aLog[LEN(_aLog),1]:="Ticket efetivado e não tem na ZLD"
                (_cAlias)->(dbskip())
                LOOP
	         ELSE
                _aLog[LEN(_aLog),1]:="Ticket com Status diferente de 'E' e 'P': "+ZLJ->ZLJ_STATUS
                (_cAlias)->(dbskip())
                LOOP
             ENDIF          
       
      ELSE

          _aLog[LEN(_aLog),1]:="Ticket nao encontrado"
          
          (_cAlias)->(dbskip())
          LOOP
          
      ENDIF
       
        _nValor:=0
        _nVlrMix:=0
        IF LEN(_aSetores) > 1
           FOR S := 1 to LEN(_aSetores)                       
		    // Total do setor dividido pelo total dos setores multiplicado pela diferenca = Total do setor com a diferenca 
		       _nVlrMix:=0
               _aSetores[S,3]:= _aSetores[S][2] / _nTotal  * SD3->D3_QUANT
               IF MV_PAR06 = 1//Sem frete
                  _nVlrMix:= POSICIONE("ZL2",1,SD3->D3_FILIAL+_aSetores[S,1],"ZL2_ULMISF")
               ENDIF
               IF _nVlrMix <= 0//Se for zero é a linha que foi gravada antes de existir o campo
                  _nVlrMix:= POSICIONE("ZL2",1,SD3->D3_FILIAL+_aSetores[S,1],"ZL2_ULTMIX")
               ENDIF
               _nValor  += (_nVlrMix * _aSetores[S,3])                          
	       NEXT                    
        ELSE
           IF MV_PAR06 = 1
              _nVlrMix:= Posicione("ZL2",1, SD3->D3_FILIAL + _cSetorPA , "ZL2_ULMISF")
           ENDIF
           IF _nVlrMix <= 0//Se for zero é a linha que foi gravada antes de existir o campo
              _nVlrMix:= Posicione("ZL2",1, SD3->D3_FILIAL + _cSetorPA , "ZL2_ULTMIX")
           ENDIF
           _nValor := (_nVlrMix * SD3->D3_QUANT)
        ENDIF			

    ENDIF

	If _nValor > 0//Recepcoes do SQ

	   IF ROUND(SD3->D3_CUSTO1,2) # ROUND(_nValor,2)
          IF MV_PAR04 = 1
             SD3->(RecLock( "SD3" , .F. )) 
             SD3->D3_CUSTO1 := _nValor
             SD3->D3_CUSTO3 := xMoeda(SD3->D3_CUSTO1,1,3,DATE()) 
             IF EMPTY(SD3->D3_L_SETOR) .AND. !EMPTY(_cSetorPA)
                SD3->D3_L_SETOR:=_cSetorPA
             ENDIF
             SD3->(MsUnlock())  
          ENDIF
          _nAcertos++
          _aLog[LEN(_aLog),1]     +=" Recalculado"//Alterado
          _aLog[LEN(_aLog),6]     :=_cSetores
          _aLog[LEN(_aLog),nPosCA]:=TRANSF(_nValor,_cPicCus)//ALLTRIM(TRANSF(SD3->D3_CUSTO1,_cPicCus))
       ELSE
          _aLog[LEN(_aLog),1]     +=" Sem Alteracao"
       ENDIF
           
    ElseIF !EMPTY(SD3->D3_L_SETOR) //Recepcao manual
       _nVlrMix:=0
       IF MV_PAR06 = 1
          _nVlrMix:= posicione("ZL2",1, SD3->D3_FILIAL + SD3->D3_L_SETOR , "ZL2_ULMISF")
       ENDIF
       IF _nVlrMix <= 0//Se for zero é a linha que foi gravada antes de existir o campo
          _nVlrMix:= posicione("ZL2",1, SD3->D3_FILIAL + SD3->D3_L_SETOR , "ZL2_ULTMIX")
       ENDIF
       _nValor:=SD3->D3_QUANT * _nVlrMix

	   IF ZLD->( DBSeek(SD3->D3_FILIAL+AVKEY(SD3->D3_L_ORIG,"ZLD_TICKET")+SD3->D3_L_SETOR) )
          _aLog[LEN(_aLog),3]:=DTOC(ZLD->ZLD_DTCOLE)//Data de coleta do ZLD
	   ENDIF

	   IF ROUND(SD3->D3_CUSTO1,2) # ROUND(_nValor,2)
          IF MV_PAR04 = 1
             SD3->(RecLock( "SD3" , .F. ))
             SD3->D3_CUSTO1 := _nValor
             SD3->D3_CUSTO3 := xMoeda(SD3->D3_CUSTO1,1,3,DATE()) 
             SD3->(MsUnlock())
          ENDIF
          _nAcertos++
          _aLog[LEN(_aLog),1]     :="[Manual Recalculado]"//Alterado
          _aLog[LEN(_aLog),nPosCA]:=TRANSF(_nValor,_cPicCus)//ALLTRIM(TRANSF(SD3->D3_CUSTO1,_cPicCus))
       ELSE
          _aLog[LEN(_aLog),1]     :="[Manual Sem Alteracao]"
       ENDIF  

    Endif

    IF EMPTY(SD3->D3_L_SETOR) .AND. EMPTY(_cSetorPA)
       _aLog[LEN(_aLog),1]:="[Sem Setor]"
    ENDIF
       
    (_cAlias)->(dbskip())
		
ENDDO

IF !EMPTY(_aLog)

   _aLog := aSort(_aLog,,,{|x,y| x[2]+DTOS(CTOD(x[3]))+x[4]+x[5] < y[2]+DTOS(CTOD(y[3]))+y[4]+y[5] })//Ordena por Filial + Data + Viagem + Setor 

   aAdd( _aLog , {"Total",""            ,DTOC(DATE()),ALLTRIM(STR(_nAcertos,10)),'Acertos',"","","","",DTOC(DATE())} )

   _cTitulo:='LOG DE PROCESSAMENTO - ACERTO DO CUSTO DO ESTOQUE'

   IF MV_PAR05 = 1
   
      _aCabecalho := {} // Array com o cabeçalho das colunas do relatório. 
      // Alinhamento( 1-Left,2-Center,3-Right )
      // Formatação( 1-General,2-Number,3-Monetário,4-DateTime )
      //          Titulo das Colunas  ,Alinhamento ,Formatação, Totaliza?
      Aadd(_aCabecalho,{'Status'            ,1           ,1         ,.F.}) 
      Aadd(_aCabecalho,{'Filial'            ,2           ,1         ,.F.}) 
      Aadd(_aCabecalho,{'Data Coleta'       ,2           ,4         ,.F.}) 
      Aadd(_aCabecalho,{'Ticket'            ,2           ,1         ,.F.}) 
      Aadd(_aCabecalho,{'Setor Anterior'    ,1           ,1         ,.F.}) 
      Aadd(_aCabecalho,{'Setores Atualizado',1           ,1         ,.F.}) 
      Aadd(_aCabecalho,{'Quantidade'        ,3           ,2         ,.F.}) 
      Aadd(_aCabecalho,{'Custo Anterior'    ,3           ,3         ,.F.}) 
      Aadd(_aCabecalho,{'Custo Recalculado' ,3           ,3         ,.F.}) 
      Aadd(_aCabecalho,{'Data Estoque'      ,2           ,4         ,.F.}) 

      _cDir := GetTempPath()  // Diretório de Geração das planilhas.
      _cArq := "ACERTO_ESTOQUE_"+Dtos(Date())+"_"+StrTran(Time(),":","")+".xml"  // Nome da planilha a ser gerada.   

      U_ITGEREXCEL(_cArq,_cDir,_cTitulo,"Relatorio",_aCabecalho,_aLog ,.F.)

      MSGINFO("Arquivo Gerado: "+_cDir+_cArq)
	  _lsai := .F.

   ELSE

      _cArq := 'MFIS001_'+ StrTran( Time() , ':' , '' ) + DtoS( Date() ) + RetCodUsr() +'.csv'

      U_ITGERARQ( _cTitulo , {'Status','Filial','Data Coleta','Ticket','Setor Anterior','Setores Atualizado','Quantidade','Custo Anterior','Custo Recalculado','Data Estoque'} , _aLog )

      MSGINFO("Arquivo Gerado no diretorio selecionado: "+_cArq)
	  _lsai := .F.

   ENDIF
   //ITListBox( _cTitAux                                            , _aHeader                                                                                  , _aCols,_lMaxSiz,_nTipo,_cMsgTop , _lSelUnc , _aSizes              , _nCampo ) 
//   U_ITListBox( 'Log de Processamento - Acerto de custo do Estoque' , {'Status','Filial','Data Emissao','Ticket','Setor Anterior','Setor Atualizado','Quantidade','Custo Anterior','Custo Recalculado'} , _aLog , .T.    , 1    ,         ,          ,;
//                                                                      { 20     , 10     , 30           , 35     , 50             , 90               , 40         , 50             , 50                } )
		
ELSE

   MSGINFO("Nao foram encontro registros para essas selecoes.")
	_lsai := .F.

ENDIF

//==============================================================================
// Grava log de Processamento de recálculo de custo de entrada do leite próprio
//============================================================================== 
U_ITLOGACS('MEST012')

Return .T. 

/*
===============================================================================================================================
Programa----------: MEST012Calc
Autor-------------: Josué Danich Prestes
Data da Criacao---: 26/07/2017
===============================================================================================================================
Descrição---------: Carrega variaveis para o recalculo do leite 
===============================================================================================================================
Parametros--------: _cAlias
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/
Static Function MEST012Calc(_cAlias)

_cSetores:=""
_aLog[LEN(_aLog),1]:=IF(_cAlias="ZLD","[COM Efetivacao]","[SEM Efetivacao]")
_aLog[LEN(_aLog),3]:=DTOC(IF(_cAlias="ZLD",(_cAlias)->ZLD_DTCOLE,(_cAlias)->ZLJ_DTIVIA))

Do while (_cAlias)->( !Eof() ) .AND. SD3->D3_FILIAL+ALLTRIM(SD3->D3_L_ORIG) == IF(_cAlias="ZLD", ZLD->ZLD_FILIAL+ZLD->ZLD_TICKET , ZLJ->ZLJ_FILIAL+ZLJ->ZLJ_VIAGEM )
	
	_nTotal += IF(_cAlias="ZLD", ZLD->ZLD_QTDBOM , ZLJ->ZLJ_VOLUME)  
	
	_nk := ascan( _aSetores,{|x| x[1] == IF(_cAlias="ZLD",ZLD->ZLD_SETOR,ZLJ->ZLJ_SETOR )} )
	
	If _nk > 0
		
		_aSetores[_nk][2] +=  IF(_cAlias="ZLD", ZLD->ZLD_QTDBOM , ZLJ->ZLJ_VOLUME)
		
	Else
		
		AADD(_aSetores, { IF(_cAlias="ZLD",ZLD->ZLD_SETOR,ZLJ->ZLJ_SETOR ), IF(_cAlias="ZLD", ZLD->ZLD_QTDBOM , ZLJ->ZLJ_VOLUME),0})
		
		IF LEN(_aSetores) = 1
			_cSetorPA:=IF(_cAlias="ZLD",ZLD->ZLD_SETOR,ZLJ->ZLJ_SETOR )
		ENDIF
		
		_cSetores+=IF(_cAlias="ZLD",ZLD->ZLD_SETOR,ZLJ->ZLJ_SETOR )+" "
		
	Endif

	(_cAlias)->( Dbskip() )
			
Enddo

RETURN .T.
