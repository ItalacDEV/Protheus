/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
===============================================================================================================================
*/
#Include 'Protheus.ch'
#Include 'FwBrowse.ch'
#Include 'FwMVCDef.ch'


/*
===============================================================================================================================
Programa----------: AFIN024
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 20/08/2015
===============================================================================================================================
Descri��o---------: Fun��o criada para fazer a confirma��o do desbloqueio - Chamado 16924
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AFIN024()
Local _aArea	:= GetArea()
Local _lok := .T.
Local cMatUsr			:= U_UCFG001(1) 
Local cAutoriz		:= GetAdvFVal( "ZZL" , "ZZL_DCNAB" , xFilial("ZZL") + cMatUsr , 1 , "N" )


//-- Controle de acesso por usuario conforme parametrizacao no Gerenciador (Gestao de Usuarios) --//
If !( cAutoriz == "S" )
	U_ITMSG("Usu�rio sem acesso � rotina de libera��o de cnab.","Aten��o!",,1)
	Return()
EndIf

//Verifica se � t�tulo bloqueado por cnab
if !(EMPTY(ALLTRIM(SE1->E1_NUMBCO)))

	u_itmsg("Este t�tulo n�o est� bloqueado por cnab!","Aten��o",,1)
	
	Return
	
ElseIf (EMPTY(ALLTRIM(SE1->E1_IDCNAB)) .AND. EMPTY(ALLTRIM(SE1->E1_I_NUMBC)))

	u_itmsg("Este t�tulo n�o est� bloqueado por cnab!","Aten��o",,1)
	
	Return

		
Endif


If u_itmsg('Deseja realmente desbloquear este t�tulo?',"Aten��o",,3,2,2)
	
	FwMsgRun(,{||AFIN024E(@_lok)},,"Aguarde... Desbloqueando t�tulo selecionado...")
	
	If _lok
	
		u_itmsg('Processo conclu�do com sucesso!',"Aten��o",,2)
		
	Endif

Else

	u_itmsg('Processo cancelado pelo usu�rio.',"Aten��o",,1)	

EndIf

RestArea(_aArea)
Return()

/*
===============================================================================================================================
Programa----------: AFIN024E
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 09/11/2016
===============================================================================================================================
Descri��o---------: Fun��o para efetivar o Desbloqueio do T�tulo
===============================================================================================================================
Parametros--------: _lok - retorno se deu certo
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AFIN024E(_lok)

Local _lContinua	:= .T.
Default _lok := .F.


If !Empty(SE1->E1_I_NUMBC) 
	If U_ITMSG("Para este t�tulo, existe um Nosso N�mero de backup [" + AllTrim(SE1->E1_I_NUMBC) + "]. Deseja utilizar o mesmo n�mero?","Aten��o",,3,2,2)
		_lContinua := .F.
	EndIf
EndIf

Begin Transaction
	If _lContinua
		//============================================================
		//apaga backup do nosso numero 
		//============================================================
		RecLock("SE1",.F.)
			SE1->E1_IDCNAB  := " "
			SE1->E1_NUMBCO	:= " "
			SE1->E1_I_NUMBC	:= " "
		MsUnLock()
	Else
		//Gravo o desbloqueio do t�tulo
		RecLock("SE1",.F.)
			SE1->E1_NUMBCO	:= SE1->E1_I_NUMBC	//Gravo o nosso n�mero do backup
			SE1->E1_IDCNAB  := " "
		MsUnLock()
	EndIf
End Transaction

_lok := .T.

Return()

