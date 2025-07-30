/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor         |    Data    |                              Motivo                      										 
------------------------------------------------------------------------------------------------------------------------------- 
André Lisboa 	 | 07/04/2017 | Chamado 19631. Correção quando usuario nao possuia acesso a todos os parametros. 
------------------------------------------------------------------------------------------------------------------------------- 
Josué Danich     | 25/06/2018 | Chamado 25312. Mudança de parâmetro MV_ULMES para parâmetro MV_DBLQMOV. 
------------------------------------------------------------------------------------------------------------------------------- 
Alex Wallauer    | 18/07/2018 | Chamado 25545. Nova opção para desfazer virada de saldos do estoque/custos. 
------------------------------------------------------------------------------------------------------------------------------- 
Alex Wallauer    | 12/09/2018 | Chamado 26267. Nova opção para IT_VLDCUS - Habilta/Desabilta Custo Produção. 
------------------------------------------------------------------------------------------------------------------------------- 
Josué Danich     | 16/01/2019 | Chamado 27727. Ajuste para servidor loboguara. 
------------------------------------------------------------------------------------------------------------------------------- 
Alex Wallauer    | 09/04/2019 | Chamado 28839. Correção de erro.log: variable does not exist _NPORCENTA. 
------------------------------------------------------------------------------------------------------------------------------- 
Alex Wallauer    | 02/07/2019 | Chamado 29718. Nova opção para IT_ULMES - Reabrir Custo Gerencial. 
------------------------------------------------------------------------------------------------------------------------------- 
Jonathan         | 06/07/2020 | Chamado 33443. Permitir que o usuário possa alterar a data do parâmetro MV_ULMES. 
------------------------------------------------------------------------------------------------------------------------------- 
Alex Wallauer    | 17/01/2022 | Chamado 38940. Novo tratamento para IT_ULMES - Reabrir Custo Gerencial. 
------------------------------------------------------------------------------------------------------------------------------- 
Alex Wallauer    | 21/10/2022 | Chamado 41642. Picture alterada: mascara de @E 9,999.99 alterada para @E 999,999,999.99.
------------------------------------------------------------------------------------------------------------------------------- 
Julio Paz        | 06/06/2024 | Chamado 46558. Inclusão do novo parâmetro IT_DESTTRA.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"  
#Include "TopConn.ch"

#DEFINE _ENTER CHR(13)+CHR(10)      

/*
===============================================================================================================================
Programa----------: MEST014
Autor-------------: Josué Danich 
Data da Criacao---: 28/03/2017
===============================================================================================================================
Descrição---------: Rotina de atualização de parâmetros de estoque - Chamado 19460
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MEST014()       

Local _cArmazem := 0 
Local _cperg1 := "MV_CQ - Almoxarifado do Controle de Qualidade"
Local _cperg2 := "MV_DBLQMOV - Bloquear/desbloquear movimentos do estoque"
Local _cperg3 := "IT_DIFCM - Diferença de porcentagem no custo médio permitida nas transferências"
Local _cperg4 := "IT_DIFCMP - Percentual diferenca do CM nas producoes"
Local _cperg5 := "MV_ULMES - Desfazer ultima virada de saldos?"
Local _cperg6 := "IT_VLDCUS - Habilta/Desabilta Custo Produção?"
Local _cperg7 := "IT_ULMES - Reabrir Custo Gerencial?"
Local _cperg9 := "IT_DESTTRA - Código de Destino das Transferências para Filtro de Consulta (F3)."

//VERIFICA PERMISSÕES DE ACESSO
Local _lRet1 := U_ITVACESS( 'ZZL' , 3 , 'ZZL_PARDIF' , "S" )
Local _lRet2 := U_ITVACESS( 'ZZL' , 3 , 'ZZL_ULMES'  , "S" )
Local _lRet3 := U_ITVACESS( 'ZZL' , 3 , 'ZZL_PARDIF' , "S" )
Local _lRet4 := U_ITVACESS( 'ZZL' , 3 , 'ZZL_DIFCMP' , "S" )
Local _lRet5 := U_ITVACESS( 'ZZL' , 3 , 'ZZL_DESFAZ' , "S" )
Local _lRet6 := U_ITVACESS( 'ZZL' , 3 , 'ZZL_VLDCUS' , "S" )
Local _lRet7 := .T.
Local _lRet8 := U_ITVACESS( 'ZZL' , 3 , 'ZZL_AULMES' , "S" )
Local _lRet9 := U_ITVACESS( 'ZZL' , 3 , 'ZZL_AUTMUL' , "S" ) // Autorizado a fazer transferências multiplas.

IF ZZL->(FIELDPOS("ZZL_DESFCG")) <> 0
   _lRet7 := U_ITVACESS( 'ZZL' , 3 , 'ZZL_DESFCG' , "S" )
ENDIF

//MONTA VARIAVEIS
DbSelectArea("SX6")
SX6->(DbSetOrder(1))	

If SX6->(DbSeek(cFilAnt + "MV_CQ")) .AND. _lRet1
	
	_cArmazem := getmv("MV_CQ")
	
Else
	
    _cArmazem:=""
	_lRet1 := .F.
	
Endif

If SX6->(DbSeek(cFilAnt + "MV_DBLQMOV")) .and. _lRet2
	
	dDtUlMes:= GETMV("MV_DBLQMOV")
	
Elseif _lRet2
	
	U_ITMSG("Não foi efetuado o cadastro do parâmetro MV_DBLQMOV para a filial: " + cFilAnt,'Atenção!',;
	        "Favor contactar o departamento de informática informando do erro ocorrido.",1)
    dDtUlMes:=CTOD("")	
	_lRet2 := .T.
	
EndIf


If SX6->(DbSeek(cFilAnt + "IT_DIFCM")) .and. _lRet3
	
	_nporcenta := GETMV("IT_DIFCM")
	
Else
    
    _nporcenta:=0
	_lRet3 := .F.
	
Endif

If  _lRet4
	
	_nDIFCMP := U_ITGetMV("IT_DIFCMP","00")
	
Endif

If  SX6->(DbSeek(cFilAnt + "MV_ULMES")) .and. _lRet5
	
	_cUltMes := GETMV("MV_ULMES")

ELSE

   _lRet5:=.F.
	
Endif

If  _lRet6
	
	IF U_ITGetMV("IT_VLDCUS",.T.)
	   _cVLDCUS := "Sim"
    ELSE
	   _cVLDCUS := "Nao"
	ENDIF

Endif

If  _lRet7
	
	_cITUltMes := U_ITGETMV("IT_ULMES","00/0000")

Endif

If _lRet9

   _cDestTran := U_ITGETMV("IT_DESTTRA","") + Space(100)

EndIf

//Monta perguntas
Private _lwhen1 := _lRet1
Private _lwhen2 := _lRet2
Private _lwhen3 := _lRet3
Private _lwhen4 := _lRet4
Private _lwhen6 := _lRet6
Private _lwhen8 := _lRet8

Private _lwhen9 := _lRet9   // JPP TESTE

Private _oDlg				// Dialog Principal
Private _lcontinua := .T.
oMainWnd:ReadClientCoords()//So precisa declarar uma fez para o Programa todo                                                                                

nposv := 005
nposh := 010

navav := 040
navah := 230

//Monta array de posições
_ni := 0
_nqt := 10 // 9 // JPP TESTE

apos := {}	

Do while _ni <= _nqt
  
	aadd(apos,{nposv + ( iif(_ni > 4, _ni - 5, _ni) * navav ), (iif(_ni > 4, 1,0) * navah) + nposh})

	_ni++
	
Enddo

_lcontinua := .T.

Do while _lcontinua
	
	_ni := 1
	_lcontinua :=.T.
    _lRefazSaldo:=.F.
    _lReAbreCusGer:=.F.
	
	DEFINE MSDIALOG _oDlg TITLE "CENTRAL PARAMETROS ESTOQUE" FROM MEST014T(100),MEST014T(100) TO MEST014T(650),MEST014T(1100) PIXEL
	
	If _ni <= len(apos) .and. _lRet1
		
		@ MEST014T(apos[_ni][1]),MEST014T(apos[_ni][2]) TO MEST014T(apos[_ni][1]+35),MEST014T(apos[_ni][2]+216)  PIXEL OF _oDlg
		
		@ MEST014T(apos[_ni][1]+14),MEST014T(apos[_ni][2] +4) Say    _cperg1;
		Size MEST014T(150),MEST014T(015) COLOR CLR_BLACK PIXEL OF _oDlg
		
		@ MEST014T(apos[_ni][1]+13),MEST014T(apos[_ni][2] + 150) MsGet  _cArmazem Size MEST014T(030),MEST014T(008) COLOR CLR_BLACK WHEN _lwhen1 Picture "@E 99" PIXEL OF _oDlg
		
		_ni++
		
	Endif
	
	If _ni <= len(apos) .and. _lRet2
		
		@ MEST014T(apos[_ni][1]),MEST014T(apos[_ni][2]) TO MEST014T(apos[_ni][1]+35),MEST014T(apos[_ni][2]+216)  PIXEL OF _oDlg
		
		@ MEST014T(apos[_ni][1]+14),MEST014T(apos[_ni][2] + 4) Say    _cperg2;
		Size MEST014T(150),MEST014T(015) COLOR CLR_BLACK PIXEL OF _oDlg
		
		@ MEST014T(apos[_ni][1]+13),MEST014T(apos[_ni][2] + 150) MsGet dDtUlMes Size MEST014T(030),MEST014T(008) COLOR CLR_BLACK WHEN _lwhen2 Picture "@D 99/99/99" PIXEL OF _oDlg		
		
		_ni++
		
	Endif
	
	
	If _ni <= len(apos) .and. _lRet3
		
		@ MEST014T(apos[_ni][1]),MEST014T(apos[_ni][2]) TO MEST014T(apos[_ni][1]+35),MEST014T(apos[_ni][2]+216)  PIXEL OF _oDlg
		
		@ MEST014T(apos[_ni][1]+14),MEST014T(apos[_ni][2] +4) Say    _cperg3;
		Size MEST014T(150),MEST014T(015) COLOR CLR_BLACK PIXEL OF _oDlg
		
		@ MEST014T(apos[_ni][1]+13),MEST014T(apos[_ni][2] + 150) MsGet _nporcenta Size MEST014T(030),MEST014T(008) COLOR CLR_BLACK WHEN _lwhen3 Picture "@E 999,999,999.99" PIXEL OF _oDlg		
		
		_ni++
		
	Endif
	
	If _ni <= len(apos) .and. _lRet4
		
		@ MEST014T(apos[_ni][1]),MEST014T(apos[_ni][2]) TO MEST014T(apos[_ni][1]+35),MEST014T(apos[_ni][2]+216)  PIXEL OF _oDlg
		
		@ MEST014T(apos[_ni][1]+14),MEST014T(apos[_ni][2] +4) Say    _cperg4;
		Size MEST014T(150),MEST014T(015) COLOR CLR_BLACK PIXEL OF _oDlg
		
		@ MEST014T(apos[_ni][1]+13),MEST014T(apos[_ni][2] + 150) MsGet _nDIFCMP Size MEST014T(030),MEST014T(008) COLOR CLR_BLACK WHEN _lwhen4 Picture "@E 999,999,999.99" PIXEL OF _oDlg
		
		_ni++
		
	Endif
	
	If _ni <= len(apos) .and. _lRet5
		
		@ MEST014T(apos[_ni][1]),MEST014T(apos[_ni][2]) TO MEST014T(apos[_ni][1]+35),MEST014T(apos[_ni][2]+216)  PIXEL OF _oDlg
		
		@ MEST014T(apos[_ni][1]+14),MEST014T(apos[_ni][2] +4) Say _cperg5 Size MEST014T(150),MEST014T(015) COLOR CLR_BLACK PIXEL OF _oDlg
		
		@ MEST014T(apos[_ni][1]+13),MEST014T(apos[_ni][2] + 135) MsGet _cUltMes Size MEST014T(045),MEST014T(010) COLOR CLR_BLACK WHEN _lRet8 Picture "@D" PIXEL OF _oDlg
		
		@ MEST014T(apos[_ni][1]+13),MEST014T(apos[_ni][2] + 185) Button "SIM" Size MEST014T(025),MEST014T(012) PIXEL OF _oDlg ACTION( _lRefazSaldo:=.T.,Close(_oDlg) )
		
		_ni++
		
	Endif

	If _ni <= len(apos) .and. _lRet6
		
		@ MEST014T(apos[_ni][1]),MEST014T(apos[_ni][2]) TO MEST014T(apos[_ni][1]+35),MEST014T(apos[_ni][2]+216)  PIXEL OF _oDlg
		
		@ MEST014T(apos[_ni][1]+14),MEST014T(apos[_ni][2] +4) Say _cperg6 Size MEST014T(150),MEST014T(015) COLOR CLR_BLACK PIXEL OF _oDlg
		
		@ MEST014T(apos[_ni][1]+13),MEST014T(apos[_ni][2] + 135) COMBOBOX _cVLDCUS Size MEST014T(045),MEST014T(010) COLOR CLR_BLACK  PIXEL OF _oDlg ITEMS {"Sim","Nao"}

		_ni++
		
	Endif

	If _ni <= len(apos) .and. _lRet7
		
		@ MEST014T(apos[_ni][1]),MEST014T(apos[_ni][2]) TO MEST014T(apos[_ni][1]+35),MEST014T(apos[_ni][2]+216)  PIXEL OF _oDlg
		
		@ MEST014T(apos[_ni][1]+14),MEST014T(apos[_ni][2] +4) Say _cperg7 Size MEST014T(150),MEST014T(015) COLOR CLR_BLACK PIXEL OF _oDlg
		
		@ MEST014T(apos[_ni][1]+13),MEST014T(apos[_ni][2] + 135) MsGet _cITUltMes Size MEST014T(045),MEST014T(010) COLOR CLR_BLACK WHEN _lRet8 Picture "@!" PIXEL OF _oDlg
		
		@ MEST014T(apos[_ni][1]+13),MEST014T(apos[_ni][2] + 185) Button "SIM" Size MEST014T(025),MEST014T(012) PIXEL OF _oDlg ACTION( _lReAbreCusGer:=.T.,Close(_oDlg) )
		
		_ni++
		
	Endif
//------------------------------------------------------ // JPP TESTE

    If _ni <= len(apos) .and. _lRet9
		
		@ MEST014T(apos[_ni][1]),MEST014T(apos[_ni][2]) TO MEST014T(apos[_ni][1]+35),MEST014T(apos[_ni][2]+216)  PIXEL OF _oDlg
		
		@ MEST014T(apos[_ni][1]+14),MEST014T(apos[_ni][2] +4) Say    _cperg9;
		Size MEST014T(150),MEST014T(015) COLOR CLR_BLACK PIXEL OF _oDlg
		
		@ MEST014T(apos[_ni][1]+13),MEST014T(apos[_ni][2] + 150) MsGet  _cDestTran Size MEST014T(50),MEST014T(008) COLOR CLR_BLACK WHEN _lwhen9 PIXEL OF _oDlg
		
		_ni++
		
	Endif

//------------------------------------------------------

	@ MEST014T(215),MEST014T(300) Button "Atualizar Parametros" Size MEST014T(080),MEST014T(013) PIXEL OF _oDlg ACTION(fwMsgRun(,{|| _lcontinua := MEST014C(_cArmazem,dDtUlMes,_nporcenta,_oDlg)},"Processando alteracao, aguarde...","Aguarde"))
	
	@ MEST014T(215),MEST014T(400) Button "SAIR" Size MEST014T(045),MEST014T(013) PIXEL OF _oDlg ACTION(Close(_oDlg))
	
	ACTIVATE MSDIALOG _oDlg CENTERED

    IF _lRefazSaldo
       IF U_ITMSG( "Confirma DESFAZER ultima virada de saldos ?",'ATENCAO!',,3,2,2)
          
          FWMSGRUN( ,{|oProc| _lRefazSaldo:=MEST014F(oProc) } ,'Aguarde!','Verificando os dados...'  )
          
          IF !_lRefazSaldo
             LOOP
          ENDIF
       ELSE
          LOOP
       ENDIF
    ENDIF
	
    IF _lReAbreCusGer
       FWMSGRUN( ,{|oProc| _lReAbreCusGer:=MEST14CG(oProc) } ,'Aguarde!','Verificando os dados...'  )
          
       IF !_lReAbreCusGer
          LOOP
       ENDIF
    ENDIF

	_lcontinua :=.F.
	
Enddo

Return(.T.)
/*
===============================================================================================================================
Programa----------: MEST014F
Autor-------------: Alex Wallauer
Data da Criacao---: 17/07/2018
===============================================================================================================================
Descrição---------: Refaz Saldo ultimo saldo da filial corrente
===============================================================================================================================
Parametros--------: oProc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC FUNCTION MEST014F(oProc)
Local cAlias  := GetNextAlias()
Local _cData  := ""
Local _aSB9   := {}
Local _nQtdReg:=0
Local _cB9queryA:= " SELECT MAX(B9_DATA) UltData "
Local _cB9queryB:= " SELECT COUNT(R_E_C_N_O_) TOTAL "
Local _cB9queryC:= " SELECT R_E_C_N_O_ RECSB9 "
Local _cB9query1:= " FROM " + RETSQLNAME("SB9")+" WHERE D_E_L_E_T_ <> '*'  AND B9_FILIAL = '" +cFilAnt+"'
Local _cB9query2:= ""
   
TcQuery (_cB9queryA+_cB9query1) New Alias (cAlias)
_cData := (cAlias)->UltData
If SELECT(cAlias) > 0 
   (cAlias)->( DBCloseArea() )
EndIf

IF EMPTY( _cData ) .OR. EMPTY( _cUltMes )
   U_ITMSG("Filial sem fechamento.","ATENCAO",;
           "Favor verificar e ajustar antes de prosseguir",1)		
   RETURN .F.
ENDIF

IF _cData <> DTOS(_cUltMes)
   U_ITMSG("Data do parametro da virada (MV_ULMES) "+DTOC(_cUltMes)+" e data "+DTOC(STOD(_cData))+" dos registros gravados na tabela de saldos iniciais (SB9) divergentes.","ATENCAO",;
           "Favor verificar e ajustar antes de prosseguir",1)		
   RETURN .F.
ENDIF

If SELECT(cAlias) > 0 
   (cAlias)->( DBCloseArea() )
EndIf

_cB9query2:= " AND B9_DATA = '" +_cData+"' ORDER BY B9_LOCAL , B9_COD "

TcQuery(_cB9queryB+_cB9query1+_cB9query2) New Alias (cAlias)
_nQtdReg := (cAlias)->TOTAL 
If SELECT(cAlias) > 0 
   (cAlias)->( DBCloseArea() )
EndIf

_cTotal:=ALLTRIM(STR(_nQtdReg))

IF EMPTY( _nQtdReg )
   U_ITMSG("Filial sem fechamentos.","ATENCAO",;
           "Favor verificar e ajustar antes de prosseguir",1)		
   RETURN .F.
ELSEIF !U_ITMSG( "Serão processados "+_cTotal+" registros. Deseja Continuar?",'ATENCAO!',,3,2,2)
   RETURN .F.
ENDIF


If SELECT(cAlias) > 0 
   (cAlias)->( DBCloseArea() )
EndIf

TcQuery (_cB9queryC+_cB9query1+_cB9query2) New Alias (cAlias)

_nConta:=0	

DO WHILE ! (cAlias)->( Eof() )

   _nConta++

   oProc:cCaption := "Lendo Item: "+ALLTRIM(SB9->B9_COD)+" - "+ALLTRIM(STR(_nConta))+" / "+_cTotal
   ProcessMessages()

   SB9->(DBGOTO((cAlias)->RECSB9))

   AADD(_aSB9,{;
        SB9->B9_FILIAL,;
        SB9->B9_LOCAL ,;
        SB9->B9_COD   ,;
        Posicione('SB1',1,xFilial('SB1')+SB9->B9_COD,'B1_DESC'),;
        TRANS(SB9->B9_QINI ,"@E 999,999,999.99999") ,;
        TRANS(SB9->B9_VINI1,"@E 99,999,999,999.99") ,;
        SB9->B9_DATA})
   
   (cAlias)->(DBSKIP())

ENDDO

IF LEN(_aSB9) > 0
	_lOK    :=.F.
	_bOK    :={|oDlg| IF(U_ITMSG( "Todos os Registros listados serão excluidos, Confirma ? "  ,'ATENCAO!',,3,2,2),(_lOK:=.T. , oDlg:End()),.T.) }
	_bCancel:={|oDlg| IF(U_ITMSG("Confirma o Cancelamento? Todo o processamento será perdido!",'ATENCAO!',,3,2,2),(_lOK:=.F. , oDlg:End()),.T.) }
	
	U_ITListBox('Lista de Armazens / Produtos (MEST014)' ,;//ITListBox( _cTitAux , _aHeader , _aCols , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel )
	            {'Filial','Armazem','Codigo','Produto','Quantidade','Valor','Data'},_aSB9,.T.,1,"Lista de Armazens / Produtos com saldo fechado que seram abertos:",,;
	            {      35,       35,      50,      320,          60,     60,    40},, _bOK,_bCancel  )
	
	IF _lOK

       BEGIN TRANSACTION 

		_nConta:=0 
		(cAlias)->( DBGOTOP() )
		DO WHILE ! (cAlias)->( Eof() )
			
			SB9->(DBGOTO((cAlias)->RECSB9))
			_nConta++			
			oProc:cCaption := "Excluindo Item: "+ALLTRIM(SB9->B9_COD)+" - "+ALLTRIM(STR(_nConta))+" / "+_cTotal
			ProcessMessages()			
	        SB9->(RecLock("SB9",.F.))
            SB9->(DBDELETE())
			
			(cAlias)->(DBSKIP())
			
		ENDDO
        
		If SX6->(DbSeek(cFilAnt + "MV_ULMES"))
			
			If SELECT(cAlias) > 0
				(cAlias)->( DBCloseArea() )
			EndIf

            TcQuery (_cB9queryA+_cB9query1) New Alias (cAlias)
  	        _cUltMes := (cAlias)->UltData
	        
	        putmv("MV_ULMES",_cUltMes)    
 
        Endif

       END TRANSACTION 

	    U_ITMSG("Virada de saldos desfeita referente a data "+DTOC(STOD(_cData))+". Saldos inciais ajustados para a data "+DTOC(STOD(_cUltMes)),'ATENCAO!',,2)		

	    IF U_ITMSG('É <B>IMPRESCINDIVEL</B> QUE APOS A EXCLUSAO SEJA  EXECUTADA'+_ENTER+'A  ROTINA "REFAZ SALDOS", Executar agora?',"ATENCAO","",3,2,2)
		   oProc:cCaption := "EXCEUTANDO REFAZ SALDO, AGURADE..."
		   ProcessMessages()			
           MATA300()
        ELSE
	       U_ITMSG( "IMPORTANTE! NÃO SE ESQUEÇA DE RODAR O REFAZ SALDOS, SEM A EXECUÇÃO OS SALDOS ATUAIS PODEM FICAR COMPROMETIDOS!!",'ATENCAO!',,1)
        ENDIF
	ELSE
//	    U_ITMSG( "OPERACAO CANCELADO",'ATENCAO!',,2)
	ENDIF
	
ENDIF

If SELECT(cAlias) > 0 
   (cAlias)->( DBCloseArea() )
EndIf

Return(.T.)

/*
===============================================================================================================================
Programa----------: MEST014C
Autor-------------: Josué Danich 
Data da Criacao---: 09/01/2017
===============================================================================================================================
Descrição---------: Atualiza parâmetros da filial corrente 
===============================================================================================================================
Parametros--------: _cArmazem - Armazem CQ
					dDtUlMes
					_nporcenta
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MEST014C(_cArmazem,dDtUlMes,_nporcenta,_oDlg)     

Local _alog := {}
        
DbSelectArea("SX6")
SX6->(DbSetOrder(1))	


If SX6->(DbSeek(cFilAnt + "MV_CQ")) .AND. _lwhen1 
	     	
	putmv("MV_CQ",_cArmazem)
	
	aadd(_alog,{"MV_CQ  - O almoxarifado de qualidade foi definido como : " + alltrim(_cArmazem) + " para a filial: " + cFilAnt})
     	
EndIf  

If SX6->(DbSeek(cFilAnt + "MV_DBLQMOV")) .AND. _lwhen2 
	     	
	putmv("MV_DBLQMOV",dDtUlMes)
	
	aadd(_alog,{"MV_DBLQMOV  - A data de bloqueio do estoque foi definida como : " + alltrim(dtoc(dDtUlMes)) + " para a filial: " + cFilAnt})
     	
EndIf

If SX6->(DbSeek(cFilAnt + "IT_DIFCM")) .AND. _lwhen3
	     		
	putmv("IT_DIFCM",_nporcenta)
	
	aadd(_alog,{"IT_DIFCM  - A tolerância de diferença de custo na transferência foi definida como : " + alltrim(str(_nporcenta)) + " para a filial: " + cFilAnt})
     	
EndIf     

IF SX6->(DbSeek(cFilAnt + "MV_ULMES")) .AND. _lwhen8
	PutMv("MV_ULMES",_cUltMes)

	Aadd(_aLog, {"MV_ULMES - A data ultimo fechamento do estoque foi definida como: " + AllToChar(_cUltMes) + " para a filial: " + cFilAnt})

ENDIF

ZP1->(Dbsetorder(2))

If _lwhen8 .AND. (ZP1->(DbSeek('  ' + cFilAnt + "IT_ULMES")) .OR. ZP1->(DbSeek('  ' + '  ' + "IT_ULMES") )) 
	     	
	RecLock("ZP1",.F.)    
	     	
	ZP1->ZP1_CONTEUD	:= _cITUltMes
	     	
	ZP1->(MsUnlock())      
	
	aadd(_alog,{"IT_ULMES - Reabrir Custo Gerencial : " + _cITUltMes + " para a filial: " + cFilAnt})
     	
EndIf   

If _lwhen4 .AND. (ZP1->(DbSeek('  ' + cFilAnt + "IT_DIFCMP")) .OR. ZP1->(DbSeek('  ' + '  ' + "IT_DIFCMP") )) 
	     	
	RecLock("ZP1",.F.)    
	     	
	ZP1->ZP1_CONTEUD	:= alltrim(str(_nDIFCMP))
	     	
	ZP1->(MsUnlock())      
	
	aadd(_alog,{"IT_DIFCMP - Percentual diferenca do CM nas producoes : " + alltrim(str(_nDIFCMP)) + " para a filial: " + cFilAnt})
     	
EndIf   

If _lwhen6 .AND. (ZP1->(DbSeek('  ' + cFilAnt + "IT_VLDCUS")) .OR. ZP1->(DbSeek('  ' + '  ' + "IT_VLDCUS") )) 
	     	
	RecLock("ZP1",.F.)    
	     	
	IF _cVLDCUS = "Sim"
	   ZP1->ZP1_CONTEUD	:= ".T."
	ELSE
	   ZP1->ZP1_CONTEUD	:= ".F."
	ENDIF   
	     	
	ZP1->(MsUnlock())      
	
	aadd(_alog,{"IT_VLDCUS - Validação do custo de Produção : " + _cVLDCUS + " para a filial: " + cFilAnt})
     	
EndIf   

If _lwhen9 .AND. (ZP1->(DbSeek('  ' + cFilAnt + "IT_DESTTRA")) .OR. ZP1->(DbSeek('  ' + '  ' + "IT_DESTTRA") )) 
	     	
	RecLock("ZP1",.F.)    
	     	
	ZP1->ZP1_CONTEUD	:= _cDestTran
		     	
	ZP1->(MsUnlock())      
	
	aadd(_alog,{"IT_DESTTRA - Código de Destino das Transferências para Filtro de Consulta (F3): " + AllTrim(_cDestTran) + " para a filial: " + cFilAnt})
     	
EndIf

If len(_alog) == 0

	u_itmsg("Nenhuma alteração realizada!","Atenção",,3)
	
Else

	U_ITListBox( 'Ajustes realizados nos parâmetros' , {'Descrição'} , _alog , .F. , 1 , 'Os seguintes ajustes foram efetivados: ' )
	
Endif

//Registra log de acesso a rotina
U_ITLOGACS('MEST014')

Close(_oDlg)

Return .T.


/*
===============================================================================================================================
Programa----------: MEST014T
Autor-------------: André Lisboa
Data da Criacao---: 09/01/2017
===============================================================================================================================
Descrição---------: Funcao responsavel por manter o Layout independente da resolucao horizontal do Monitor do Usuario.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MEST014T(_nTam)                                                         

Local _nHres	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     

	If _nHres == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  

		_nTam *= 0.8                                                                

	ElseIf (_nHres == 798).Or.(_nHres == 800)	// Resolucao 800x600                

		_nTam *= 1   	                                                               

	Else	// Resolucao 1024x768 e acima faz proporcao                                          

		_nTam = (_nTam * 1)                                                               

	EndIf                                                                         

Return Int(_nTam)    


/*
===============================================================================================================================
Programa----------: MEST14CG
Autor-------------: Alex Wallauer
Data da Criacao---: 02/07/2018
===============================================================================================================================
Descrição---------: REABRE CUSTO GERENCIAL
===============================================================================================================================
Parametros--------: oProc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC FUNCTION  MEST14CG(oProc)
Local cAlias  := GetNextAlias()
Local _cData  := ""
Local _aZE0   := {}
Local _nQtdReg:=0
Local _cB9queryA:= " SELECT MAX(SUBSTR(ZE0_DATARQ,3,4)||SUBSTR(ZE0_DATARQ,1,2)) UltData "
Local _cB9queryC:= " SELECT R_E_C_N_O_ RECZE0 "
Local _cB9query1:= " FROM " + RETSQLNAME("ZE0")+" WHERE D_E_L_E_T_ <> '*'  AND ZE0_FILIAL = '" +cFilAnt+"'
Local _cB9query2:= ""
   
TcQuery (_cB9queryA+_cB9query1) New Alias (cAlias)
_cData := SUBSTR((cAlias)->UltData,5,2) + SUBSTR((cAlias)->UltData,1,4)
If SELECT(cAlias) > 0 
   (cAlias)->( DBCloseArea() )
EndIf

IF EMPTY( _cData ) .OR. EMPTY( _cITUltMes )
   U_ITMSG("Filial sem fechamento de Custo gerencial.","ATENCAO",;
           "Favor verificar e ajustar antes de prosseguir",1)		
   RETURN .F.
ENDIF

IF _cData <> _cITUltMes
   U_ITMSG("Data do parametro da virada (IT_ULMES) "+_cITUltMes+" e data "+_cData+" dos registros gravados na tabela (ZE0) divergentes.","ATENCAO",;
           "Favor verificar e ajustar antes de prosseguir",1)		
   RETURN .F.
ENDIF

If SELECT(cAlias) > 0 
   (cAlias)->( DBCloseArea() )
EndIf

_cB9query2:= " AND ZE0_DATARQ = '" +_cData+"'  "
TcQuery (_cB9queryC+_cB9query1+_cB9query2) New Alias (cAlias)

COUNT TO _nQtdReg
DBGOTOP()
_cTotal:=ALLTRIM(STR(_nQtdReg))

IF EMPTY( _nQtdReg )
   U_ITMSG("Filial sem fechamento de Custo gerencial.","ATENCAO",;
           "Favor verificar e ajustar antes de prosseguir",1)		
   RETURN .F.
ELSEIF !U_ITMSG( "Confirma REABRIR CUSTO GERENCIAL ?",'ATENCAO!',"Serão processados "+_cTotal+" registros.",3,2,2)
   RETURN .F.
ENDIF

_nConta:=0	

DO WHILE ! (cAlias)->( Eof() )

   _nConta++

   oProc:cCaption := "Lendo ZE0 - "+ALLTRIM(STR(_nConta))+" / "+_cTotal
   ProcessMessages()

   ZE0->(DBGOTO((cAlias)->RECZE0))

   AADD(_aZE0,{;
        ZE0->ZE0_FILIAL,;
        ZE0->ZE0_DATARQ,;
        ZE0->ZE0_TPCUS ,;
        ZE0->ZE0_DTPCT ,;
        ZE0->ZE0_EVCUS ,;
        TRANS(ZE0->ZE0_QTDE ,"@E 999,999,999.99999") ,;
        TRANS(ZE0->ZE0_VALOR,"@E 99,999,999,999.99") })
   
   (cAlias)->(DBSKIP())

ENDDO

IF LEN(_aZE0) > 0
	_lOK:=.F.
	_bOK    :={|oDlg| IF(U_ITMSG( "Todos os Registros listados serão excluidos, Confirma ? "  ,'ATENCAO!',,3,2,2),(_lOK:=.T. , oDlg:End()),.T.) }
	
	_bCancel:={|oDlg| IF(U_ITMSG("Confirma o Cancelamento? Todo o processamento será perdido!",'ATENCAO!',,3,2,2),(_lOK:=.F. , oDlg:End()),.T.) }
	
	U_ITListBox(_cTotal+' Registros ZE0 (MEST014)',;//ITListBox( _cTitAux , _aHeader , _aCols , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel )
	            {'Filial','Mes Ano',AVSX3("ZE0_TPCUS",5),AVSX3("ZE0_DTPCT",5),AVSX3("ZE0_EVCUS",5),'Quantidade','Valor'},_aZE0,.T.,1,_cTotal+' Registros ZE0 que seram excluidos (MEST014)',,;
	            {      35,       40,               35,                     50,                  40,          60,     60},, _bOK,_bCancel  )
	
	IF _lOK

       BEGIN TRANSACTION 

		_nConta:=0 
		(cAlias)->( DBGOTOP() )
		DO WHILE ! (cAlias)->( Eof() )
			
			ZE0->(DBGOTO((cAlias)->RECZE0))
			_nConta++			
			oProc:cCaption := "Excluindo ZE0 - "+ALLTRIM(STR(_nConta))+" / "+_cTotal
			ProcessMessages()			
	        ZE0->(RecLock("ZE0",.F.))
            ZE0->(DBDELETE())
			
			(cAlias)->(DBSKIP())
			
		ENDDO
        _nConta:=0
		ZE1->( dbsetorder(1) )
     	If ZE1->( Dbseek(cFilant+_cData ) )
		    DO WHILE ! ZE1->( Eof() ) .AND. ZE1->ZE1_FILIAL == cFilant .AND. ALLTRIM(ZE1->ZE1_COMP) == _cData
			   _nConta++			
			   oProc:cCaption := "Excluindo ZE1... - "+ALLTRIM(STR(_nConta))
			   ProcessMessages()			
	           ZE1->(RecLock("ZE1",.F.))
               ZE1->(DBDELETE())
			   ZE1->(DBSKIP())
		    ENDDO
		ENDIF 

        ZP1->(Dbsetorder(2))

        If (ZP1->(DbSeek('  ' + cFilAnt + "IT_ULMES")) .OR. ZP1->(DbSeek('  ' + '  ' + "IT_ULMES") )) 

           If SELECT(cAlias) > 0 
              (cAlias)->( DBCloseArea() )
           EndIf
           TcQuery (_cB9queryA+_cB9query1) New Alias (cAlias)
           _cData := SUBSTR((cAlias)->UltData,5,2) + SUBSTR((cAlias)->UltData,1,4)

	       ZP1->(RecLock("ZP1",.F.)    )
	       ZP1->ZP1_CONTEUD	:= _cData
	       ZP1->(MsUnlock())      
	       
        EndIf 

       END TRANSACTION 

	   U_ITMSG("Custo Gerencial Aberto referente a data "+_cITUltMes,'ATENCAO!',;
		       "Custo Gerencial Fechado atual na data "+_cData,2)		
	    
	ELSE
///	    U_ITMSG( "OPERACAO CANCELADO",'ATENCAO!',,2)
	ENDIF
	
ENDIF

If SELECT(cAlias) > 0 
   (cAlias)->( DBCloseArea() )
EndIf

Return(.T.)
