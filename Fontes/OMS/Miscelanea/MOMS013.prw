/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
  Andr� Lisboa 	  | 24/08/2017 | Ajuste gerais para V12 e incluido ITLOGACS - Chamado 20782
-------------------------------------------------------------------------------------------------------------------------------
  Julio Paz       | 10/07/2018 | Exibir comiss�es pendentes de meses anteriores em tela de conf.para fechamento. chamado 25429
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 11/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#Include "PROTHEUS.CH"  
#Include "TOPCONN.CH"
#define	MB_OK				

/*
===============================================================================================================================
Programa----------: MOMS013
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 14/03/2011
===============================================================================================================================
Descri��o---------: Rotina responsavel por realizar o fechamento da comissao na baixa
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS013()
                       
Local _oGetDtFech 
Local _oSay1
Local _oSay2     
Local _nOpca     := 0  
Local _cDataF    := GetMv("IT_COMFECH")  // Data do fechamento
Local _nmes      := month(stod(substr(_cDataf,4,4)+substr(_cDataf,1,2)+'01'))
Local _nano      := year(stod(substr(_cDataf,4,4)+substr(_cDataf,1,2)+'01'))

Private _cDtFecham := strzero(_nmes,2)+"/"+alltrim(str(_nano))
Private _aRecnoSE3 := {}

Static _oDlg

DEFINE MSDIALOG _oDlg TITLE "ROTINA DE FECHAMENTO DA COMISS�O" FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL 
_oDlg:lMaximized:= .F.
	_oPanel := TPanel():New(0,0,'',_oDlg,, .T., .T.,, ,40,90,.T.,.T. )

    @ 007, 017 SAY _oSay1 PROMPT "Esta rotina � respons�vel por efetuar o fechamento mensal da comiss�o de acordo com o m�s e ano informados pelo usu�rio." SIZE 217, 017 OF _oPanel COLORS 0, 16777215 PIXEL
    @ 035, 080 SAY _oSay2 PROMPT "M�s/Ano de fechamento:" SIZE 069, 007 OF _oPanel COLORS 0, 16777215 PIXEL
    @ 042, 080 MSGET _oGetDtFech VAR _cDtFecham SIZE 095, 011 OF _oPanel PICTURE "@R 99/9999" WHEN .F. COLORS 0, 16777215 PIXEL
     
ACTIVATE MSDIALOG _oDlg ON INIT (EnchoiceBar(_oDlg,{|| IIF(MOMS013VD(),Eval({|| _nOpca:= 1,_oDlg:End(),MsgRun("AGUARDE, PROCESSANDO O FECHAMENTO DA COMISS�O.",,{||CursorWait(), MOMS013Q("",4) , CursorArrow()})}),) },{|| _nOpca:= 0,_oDlg:End()},,),_oPanel:align:= CONTROL_ALIGN_TOP)   

Return     
                 
/*
===============================================================================================================================
Programa----------: MOMS013Q
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 14/03/2011
===============================================================================================================================
Descri��o---------: Funcao responsavel por armazenar as querys utilizadas
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS013Q(_cAlias,_nOpcao) 

Local _cFiltro:= "%"         
Local _cUpdate:= ""         
Local lSqlOk
Local _cDataF    := GetMv("IT_COMFECH")  // Data do fechamento
Local _nmes      := month(stod(substr(_cDataf,4,4)+substr(_cDataf,1,2)+'01'))+1
Local _nano      := year(stod(substr(_cDataf,4,4)+substr(_cDataf,1,2)+'01'))

Do Case
                                    
	//================================================================================
	//Verifica se existem lancamentos de comissao em aberto com uma
	//data inferior a data de fechamento informada pelo usuario.   
   	//================================================================================
	
	Case _nOpcao == 1      
			
		_cFiltro+= " AND SUBSTR(E3_EMISSAO,1,6) < '" + SubStr(_cDtFecham,4,4) +  SubStr(_cDtFecham,1,2) + "'"
		_cFiltro+= "%"
		
		// COUNT(*) NUMREG
		 
		BeginSql alias _cAlias			
			SELECT
			      R_E_C_N_O_ NUMREG
			FROM
			      %table:SE3%
			WHERE
			      D_E_L_E_T_ = ' '
			      AND E3_I_FECH <> 'S'			
			      %exp:_cFiltro%	      			 
           EndSql 
                                  
	   //==============================================================
	   //Verifica se ja houve fechamento para o mes/ano informados
	   //pelo usuario.                                            
	   //==============================================================
	   
	Case _nOpcao == 2  
       
    	_cFiltro+= " AND SUBSTR(E3_EMISSAO,1,6) = '" + SubStr(_cDtFecham,4,4) +  SubStr(_cDtFecham,1,2) + "'"
		_cFiltro+= "%"    
       
    	BeginSql alias _cAlias       		
     			SELECT
				      COUNT(*) NUMREG
				FROM
				      %table:SE3%
				WHERE
				      D_E_L_E_T_ = ' '
				      AND E3_I_FECH = 'S'			
				      %exp:_cFiltro%       		             
    	EndSql    
  	
		
		//==========================================================================
		//Realiza a atualizacao do fechamento da comissao de pagamento de 
		//acordo com o Mes/Ano de fechamento fornecido pelo usuario.      
		//==========================================================================
		
	Case _nOpcao == 4   
		 
		_cUpdate := "UPDATE " 
		_cUpdate +=	  RetSqlName("SE3") 
		_cUpdate += " SET E3_I_FECH = 'S' " 
		_cUpdate += " ,E3_I_DTFEC = '" + DtoS(date())       + "' " 
		_cUpdate += " ,E3_I_HRFEC = '" + SubStr(TIME(),1,5) + "' " 
		_cUpdate += " ,E3_I_USRFE = '" + U_UCFG001(1)        + "' " 
		_cUpdate += " ,E3_DATA = '" + DTOS( Date() ) + "'"  
		_cUpdate += "WHERE D_E_L_E_T_ = ' '"
		_cUpdate += " AND SUBSTR(E3_EMISSAO,1,6) = '" + SubStr(_cDtFecham,4,4) +  SubStr(_cDtFecham,1,2) + "'"
		_cUpdate += " AND E3_DATA < '20010101'"
		lSqlOk := !(TCSqlExec(_cUpdate) < 0)
		
		_cUpdate := "UPDATE " 
		_cUpdate +=	  RetSqlName("SE3") 
		_cUpdate += " SET E3_I_FECH = 'S' " 
		_cUpdate += " ,E3_I_DTFEC = '" + DtoS(date())       + "' " 
		_cUpdate += " ,E3_I_HRFEC = '" + SubStr(TIME(),1,5) + "' " 
		_cUpdate += " ,E3_I_USRFE = '" + U_UCFG001(1)        + "' " 
		_cUpdate += "WHERE D_E_L_E_T_ = ' '"
		_cUpdate += " AND SUBSTR(E3_EMISSAO,1,6) = '" + SubStr(_cDtFecham,4,4) +  SubStr(_cDtFecham,1,2) + "'"
		_cUpdate += " AND E3_DATA > '20010101'"
		lSqlOk2 := !(TCSqlExec(_cUpdate) < 0)
		
										
		//==========================================================================
		//Ocorreu um erro ao executar a atualizacao do fechamento da comissao.
		//==========================================================================
				
		If !lSqlOk .or. !lSqlOk2        
				
			xMagHelpFis("INFORMA��O",;
	       			"N�o foi poss�vel realizar a atualiza��o do fechamento da comiss�o para o seguinte M�s/Ano: " + _cDtFecham,;
	       			"Favor contactar o departamento de inform�tica informando de tal problema: " + TcSqlError())    	              	            												            					
							
			//==========================================================================
			//Caso nao ocorra erro na atualizacao do fechamento da comissao
			//atualiza o parametro IT_COMFECH com o ultimo Mes/Ano de      
			//fechamento da comissao.                                      
			//==========================================================================
							
		Else

			//=========================================================================================
			//grava log de atualiza��o para o fechamento na tabela de gest�o de fechamento de comiss�o
			//=========================================================================================
	
			If _nmes == 13

  				_nmes := 1
  				_nano += 1

			endif

			PutMv("IT_COMFECH",strzero(_nmes,2) + "/" + strzero(_nano,4))
	
			RecLock("ZC8",.T.)
 
 			ZC8->ZC8_FILIAL     := xFilial("ZC8")   
			ZC8->ZC8_SEQ        := U_MOMS009C()  //Gera nova sequ�ncia do ZC8
			ZC8->ZC8_ROTINA     := "Fechamento mensal"
			ZC8->ZC8_DATA       := DATE()
			ZC8->ZC8_HORA       := TIME()
			ZC8->ZC8_USER       := CUSERNAME
			ZC8->ZC8_CODUSU     := __CUSERID
			ZC8->ZC8_OBS        := _cDtFecham
			ZC8->ZC8_COMP       := _cDtFecham
 
			MSUNLOCK()
	
			RecLock("ZC9",.F.)
 
 			ZC9->ZC9_STATUS     := "2"   
 
 			MSUNLOCK()
	
			RecLock("ZC9",.T.)
 
			ZC9->ZC9_FILIAL     := xFilial("ZC8")   
			ZC9->ZC9_SEQ        := U_MOMS009H()  //Gera nova sequ�ncia do ZC9
			ZC9->ZC9_COMP       := strzero(_nmes,2) + "/" + strzero(_nano,4)
			ZC9->ZC9_STATUS     := "0"

			MSUNLOCK()
								 	    
			MsgInfo("Fechamento da comiss�o efetuado com sucesso!")   
															     						            					
		EndIf
		
		U_ITLOGACS('MOMS013')
            
EndCase     

Return

/*
===============================================================================================================================
Programa----------: MOMS013VD2
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 09/12/2015
===============================================================================================================================
Descri��o---------: Valida execu��o do fechamento de comiss�es
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: L�gico liberando ou n�o a execu��o do fechamento de comiss�es
===============================================================================================================================
*/
Static Function MOMS013VD2()

Local _aalertas  := {}
Local _cDataF    := GetMv("IT_COMFECH")  // Data do fechamento
Local _nmes      := month(stod(substr(_cDataf,4,4)+substr(_cDataf,1,2)+'01'))
Local _nano      := year(stod(substr(_cDataf,4,4)+substr(_cDataf,1,2)+'01'))
Local _cAlias	   := GetNextAlias()
Local _cseq      := ""
Local _aMsgItlist := {}, _aCabItList
Local _cTitulo, _lRet := NIL
Local _nI

//verifica parametro de fechamento de comissao
_aalertas := U_MOMS009VS()

//Verifica se usu�rio pode rodar a rotina
DBSelectArea('ZZL')
ZZL->( DBSetOrder(3) )

If !(ZZL->( DBSeek( xFilial('ZZL') + RetCodUsr() ) ) .And. ZZL->ZZL_ADMCMS == 'S')

    aadd(_aalertas,"Usu�rio " + alltrim(substr(cUsuario,7,15)) + " sem permiss�o para c�lculo de comiss�es!") 
 
End If


_cDataf := strzero(_nano,4)+strzero(_nmes,2)+"01"

//verifica se n�o est� fazendo fechamento o m�s atual ou futuro
If alltrim(str(_nano))+alltrim(strzero(_nmes,2)) >= alltrim(str(year(date())))+alltrim(strzero(month(date()),2))

  aadd(_aalertas,"M�s " + strzero(_nmes,2) + "/" + strzero(_nano,4) + " n�o terminou ainda!") 
  
Endif

//verifica se j� foi liberado pelo financeiro
_cQuery := " SELECT ZC8_SEQ FROM "+ RETSQLNAME('ZC8') +" ZC8 WHERE ZC8_ROTINA = 'Fechamento Financeiro' "
_cQuery += " and ZC8_COMP = '" + strzero(_nmes,2) + "/" + strzero(_nano,4) + "' and  D_E_L_E_T_ <> '*' and ZC8_FILIAL = '" +Xfilial("ZC8") + "'"

DBUseArea( .T. , "TOPCONN" , TCGenQry( ,, _cQuery ) , _cAlias , .F. , .T. )
DBSelectArea(_cAlias)

if (_cAlias)->( Eof() )

  aadd(_aalertas,"N�o existe um fechamento financeiro para o per�odo de comiss�es em aberto!(" + strzero(_nmes,2) + "/" + strzero(_nano,4) + ")")
  (_cAlias)->( Dbclosearea() )  
  
else

	_cseq := alltrim((_cAlias)->ZC8_SEQ)
	(_cAlias)->( Dbclosearea() )

	//verifica se j� rodou rec�lculo de comiss�o ap�s a libera��o do financeiro

	_cAlias	:= GetNextAlias()

	_cQuery := " SELECT ZC8_SEQ FROM "+ RETSQLNAME('ZC8') +" ZC8 WHERE ZC8_ROTINA like 'Recalculo de Comissao%' "
	_cQuery += " and ZC8_COMP = '" + strzero(_nmes,2) + "/" + strzero(_nano,4) + "' and  D_E_L_E_T_ <> '*'  and ZC8_FILIAL = '" +Xfilial("ZC8") + "'"
	
	DBUseArea( .T. , "TOPCONN" , TCGenQry( ,, _cQuery ) , _cAlias , .F. , .T. )
	DBSelectArea(_cAlias)

	if (_cAlias)->( Eof() )

  		aadd(_aalertas,"N�o existe um rec�lculo de comiss�o ap�s a libera��o do financeiro para o per�odo de comiss�es em aberto!(" + strzero(_nmes,2) + "/" + strzero(_nano,4) + ")")
       (_cAlias)->( Dbclosearea() )
  
	else
	
		//verifica se j� rodou c�lculo de adicionais de comiss�o para bonifica��o
		(_cAlias)->( Dbclosearea() )
		_cAlias	:= GetNextAlias()

		_cQuery := " SELECT ZC8_SEQ FROM "+ RETSQLNAME('ZC8') +" ZC8 WHERE ZC8_ROTINA = 'Adicionais de Comissao' "
		_cQuery += " and ZC8_COMP = '" + strzero(_nmes,2) + "/" + strzero(_nano,4) + "' and ZC8_OBS = '2 - Bonifica��es'"
		_cQuery += " and D_E_L_E_T_ <> '*' and ZC8_FILIAL = '" +Xfilial("ZC8") + "'"

		DBUseArea( .T. , "TOPCONN" , TCGenQry( ,, _cQuery ) , _cAlias , .F. , .T. )
		DBSelectArea(_cAlias)

		if (_cAlias)->( Eof() )

  			aadd(_aalertas,"N�o existe um c�lculo de adicionais de bonifica��o ap�s a libera��o do financeiro para o per�odo de comiss�es em aberto!(" + strzero(_nmes,2) + "/" + strzero(_nano,4) + ")")
  			
  		Endif
		
		(_cAlias)->( Dbclosearea() )
	
	endif
	
endif

//===================================================================================
//Verifica se nao existem outros meses em aberto antereriores ao 
//do que se esta tentando efetuar o fechamento.                  
//===================================================================================
_aCabItList := {"Filial","Vendedor","Nome Vendedor","No. Titulo","Dt Comiss�o","Serie N.F.","Cliente","Loja","Nome Cliente","Vlr.Base","% Vl.Base","Comiss�o","Data Pagto","Mensagem"}

_cAlias:= GetNextAlias()            
  
MOMS013Q(_cAlias,1)

dbSelectArea(_cAlias) 
(_cAlias)->(dbGotop())

Do While ! (_cAlias)->(Eof())
   //If (_cAlias)->NUMREG > 0
   //	aadd(_aalertas,"Existem comiss�es em aberto com o M�s/Ano inferior ao M�s/Ano informado para a realiza��o do fechamento da comiss�o.(" + strzero(_nmes,2) + "/" + strzero(_nano,4) + ")")
   //EndIf   
      
   SE3->(DbGoTo((_cAlias)->NUMREG))
   
   Aadd(_aMsgItlist, {SE3->E3_FILIAL,;   // Filial
                      SE3->E3_VEND  ,;   // Vendedor
                      Posicione("SA3",1,xFilial("SA3")+SE3->E3_VEND,"A3_NOME"),; // Nome do Vendedor
                      SE3->E3_NUM   ,;   // No. Titulo
                      SE3->E3_EMISSAO,;  // Dt Comiss�o
                      SE3->E3_SERIE  ,;  // Serie N.F.
                      SE3->E3_CODCLI ,;  // Cliente
                      SE3->E3_LOJA   ,;  // Loja
                      Posicione("SA1",1,xFilial("SA1")+SE3->E3_CODCLI+SE3->E3_LOJA,"A1_NOME"),; // Mome do Cliente
                      SE3->E3_BASE   ,;  // Vlr.Base
                      SE3->E3_PORC   ,;  // % Vl.Base
                      SE3->E3_COMIS  ,;  // Comiss�o
                      SE3->E3_DATA   ,;  // Data Pagto
                      "Existem comiss�es em aberto com o M�s/Ano inferior ao M�s/Ano informado para a realiza��o do fechamento da comiss�o.(" + strzero(_nmes,2) + "/" + strzero(_nano,4) + ")" }) // Mensagem
   
   Aadd(_aRecnoSE3, SE3->(Recno()))
   
   (_cAlias)->(DbSkip())
EndDo


dbSelectArea(_cAlias) 
(_cAlias)->(dbCloseArea())

//===================================================================================
//Verifica se ja nao houve fechamento para a comissao para o        
//mes/ano informado, pois somente podera ser realizado um fechamento
//da comissao.                                                      
//===================================================================================

_cAlias:= GetNextAlias()            
  
MOMS013Q(_cAlias,2)

dbSelectArea(_cAlias) 
(_cAlias)->(dbGotop())

If (_cAlias)->NUMREG > 0
        
	aadd(_aalertas,"N�o ser� poss�vel realizar o fechamento da comiss�o para o M�s/Ano indicados, pois ja foi efetuado um fechamento para este M�s/Ano.(" + strzero(_nmes,2) + "/" + strzero(_nano,4) + ")")

EndIf   

dbSelectArea(_cAlias) 
(_cAlias)->(dbCloseArea()) 


If Len(_aMsgItlist) > 0
   _cTitulo := "Valida��o de Outros Meses em Aberto Anteriores ao Mes de Fechamento"
   
   _lRet := U_ITListBox('Valida��es do Fechamento de Comiss�es (MOMS013)',_aCabItList,_aMsgItlist,.T.,1,_cTitulo)
   
   If _lRet .And. Empty(_aalertas) 
      
      For _nI := 1 To Len(_aRecnoSE3)
          SE3->(DbGoTo(_aRecnoSE3[_nI]))
          SE3->(RecLock("SE3",.F.))
          SE3->E3_I_FECH := 'S'
          
          SE3->(MsUnlock())
      Next
      
      For _nI := 1 To Len(_aMsgItlist)   
          ZGD->(RecLock("ZGD", .T.))
          ZGD->ZGD_FILIAL  := _aMsgItlist[_nI,1]    //  Filial
          ZGD->ZGD_VEND    := _aMsgItlist[_nI,2]    //  Vendedor
          ZGD->ZGD_NOMEVD  := _aMsgItlist[_nI,3]    //  Nome Vended
          ZGD->ZGD_NUM     := _aMsgItlist[_nI,4]    //  No. Titulo
          ZGD->ZGD_EMISSAO := _aMsgItlist[_nI,5]    //  Dt Comiss�o
          ZGD->ZGD_SERIE   := _aMsgItlist[_nI,6]    //  Serie N.F.
          ZGD->ZGD_CODCLI  := _aMsgItlist[_nI,7]    //  Cliente
          ZGD->ZGD_LOJA    := _aMsgItlist[_nI,8]    //  Loja
          ZGD->ZGD_NOMECL  := _aMsgItlist[_nI,9]    //  Nome Cliente
          ZGD->ZGD_BASE    := _aMsgItlist[_nI,10]   //  Vlr.Base
          ZGD->ZGD_PORC    := _aMsgItlist[_nI,11]   //  % Vl.Base
          ZGD->ZGD_COMIS   := _aMsgItlist[_nI,12]   //  Comiss�o
          ZGD->ZGD_DATA    := _aMsgItlist[_nI,13]   //  Data Pagto
          ZGD->ZGD_MENSAG  := _aMsgItlist[_nI,14]   //  Mensagem Vld
          ZGD->ZGD_USUARI  := __cUserId             //  Cod.Usuario
          ZGD->ZGD_DTLOG   := Date()                //  Dt.Grv.Log
          ZGD->(MsUnlock())      
      Next
   ElseIf ! _lRet .And. Empty(_aalertas)
          Return .F.      
   EndIf
EndIf

//se teve qualquer alerta na verifica��o monta mensagem e impede o processamento
if len(_aalertas) > 0
  
    _cMensagem := "<html>"
	_cMensagem += "<body>"
	_cMensagem += "<strong>"
	_cMensagem += "<p>"
	_cMensagem += "Foram encontrados problemas com o processo!<br>"
	_cMensagem += "Fechamento n�o ser� efetuado, corrija o processo e execute novamente.<br>"
	_cMensagem += "</p>
	_cMensagem += "</strong>
	_cMensagem += "<hr>"
		
   for _ni = 1 to len(_aalertas)
  
  		_cMensagem += "<p>"
		_cMensagem += _aalertas[_ni] 
		_cMensagem += "</p>
		if _ni < len(_aalertas) 
		  _cMensagem += "<hr>"
		endif
		
	next
	
	_cMensagem += "</body>"
	_cMensagem += "</html>"
				
	MessageBox(_cMensagem, "Problema no processo", MB_OK)
  
  	return .F.
  	 
endif 

return .T.

/*
===============================================================================================================================
Programa----------: MOMS013VD
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 09/12/2015
===============================================================================================================================
Descri��o---------: Monta tela de valida��o de fechamento de comiss�o
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: L�gico liberando ou n�o a execu��o do fechamento de comiss�es
===============================================================================================================================
*/
Static Function MOMS013VD()

Local _lRet     := .T.    

MsgRun("AGUARDE, PROCESSANDO VALIDA��ES NO FECHAMENTO DA COMISS�O.",,{||CursorWait(), _lRet:= MOMS013VD2(), CursorArrow()})

Return _lRet