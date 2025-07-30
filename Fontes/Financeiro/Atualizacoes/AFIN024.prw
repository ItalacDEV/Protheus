/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
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
Autor-------------: Josué Danich Prestes
Data da Criacao---: 20/08/2015
===============================================================================================================================
Descrição---------: Função criada para fazer a confirmação do desbloqueio - Chamado 16924
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
	U_ITMSG("Usuário sem acesso à rotina de liberação de cnab.","Atenção!",,1)
	Return()
EndIf

//Verifica se é título bloqueado por cnab
if !(EMPTY(ALLTRIM(SE1->E1_NUMBCO)))

	u_itmsg("Este título não está bloqueado por cnab!","Atenção",,1)
	
	Return
	
ElseIf (EMPTY(ALLTRIM(SE1->E1_IDCNAB)) .AND. EMPTY(ALLTRIM(SE1->E1_I_NUMBC)))

	u_itmsg("Este título não está bloqueado por cnab!","Atenção",,1)
	
	Return

		
Endif


If u_itmsg('Deseja realmente desbloquear este título?',"Atenção",,3,2,2)
	
	FwMsgRun(,{||AFIN024E(@_lok)},,"Aguarde... Desbloqueando título selecionado...")
	
	If _lok
	
		u_itmsg('Processo concluído com sucesso!',"Atenção",,2)
		
	Endif

Else

	u_itmsg('Processo cancelado pelo usuário.',"Atenção",,1)	

EndIf

RestArea(_aArea)
Return()

/*
===============================================================================================================================
Programa----------: AFIN024E
Autor-------------: Josué Danich Prestes
Data da Criacao---: 09/11/2016
===============================================================================================================================
Descrição---------: Função para efetivar o Desbloqueio do Título
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
	If U_ITMSG("Para este título, existe um Nosso Número de backup [" + AllTrim(SE1->E1_I_NUMBC) + "]. Deseja utilizar o mesmo número?","Atenção",,3,2,2)
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
		//Gravo o desbloqueio do título
		RecLock("SE1",.F.)
			SE1->E1_NUMBCO	:= SE1->E1_I_NUMBC	//Gravo o nosso número do backup
			SE1->E1_IDCNAB  := " "
		MsUnLock()
	EndIf
End Transaction

_lok := .T.

Return()

