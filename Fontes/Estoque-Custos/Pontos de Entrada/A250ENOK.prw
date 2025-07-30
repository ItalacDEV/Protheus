/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
André Lisboa  | 13/11/17   | Chamado 22489. Alterada busca do solicitante para a variavel cSolic
-------------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 11/06/2018 | Chamado 29598. Ajustes na validação acrescentou .AND. cUsr <> "0"
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 11/09/2024 | Chamado 48465. Removendo warning de compilação.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: A250ENOK
Autor-------------: Lucas Crevilari
Data da Criacao---: 10/10/2014
===============================================================================================================================
Descrição---------: Valida o encerramento da OP
===============================================================================================================================
Parametros--------:
===============================================================================================================================
Retorno-----------: lRet
===============================================================================================================================
*/
User Function A250ENOK

Local lRet 		:= .T.
Local nQtdOrig	:= 0
Local nQtdEnc	:= 0
Local nPercent	:= GETMV("IT_PERQTDE")
Private cMotivo := SC2->C2_I_MOTIV
Private cNumOp	:= SD3->D3_OP
          
nQtdOrig := POSICIONE("SC2",1,xFilial("SC2")+cNumOp,"C2_QUANT")
nQtdEnc := POSICIONE("SC2",1,xFilial("SC2")+cNumOp,"C2_QUJE")
nPerOrig := (nQtdOrig*nPercent)/100

If nQtdEnc < nPerOrig
	Static oDlg
	Static oGet1
	Static oSay1
	
	DEFINE MSDIALOG oDlg TITLE "Motivo" FROM 000, 000  TO 250, 400 COLORS 0, 16777215 PIXEL
	
	@ 005, 002 SAY oSay1 PROMPT "Informe o motivo de encerramento:" SIZE 193, 117 OF oDlg COLORS 0, 16777215 PIXEL
	@ 007, 002 GET oGet1 VAR cMotivo MEMO SIZE 193, 084 OF oSay1 COLORS 0, 16777215 PIXEL
	
	oBtnAp := TButton():New(105,120,"      OK",oDlg,{|| IIF(EMPTY(cMotivo),(Alert("Informe o motivo do cancelamento!"),lRet:=.F.),(GrvMotiv(),lRet:=.T.,oDlg:End())) },C(45),C(015),,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnAp:SetCss("QPushButton{ background-image: url(rpo:ok.png);"+;
	" background-repeat: none; margin: 2px }")
	
	oBtn := TButton():New(105,030,"      Cancelar",oDlg,{|| lRet:=.F.,oDlg:End() },C(45),C(015),,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn:SetCss("QPushButton{ background-image: url(rpo:CANCEL.png);"+;
	" background-repeat: none; margin: 2px }")
	
	ACTIVATE MSDIALOG oDlg CENTERED
EndIf

Return lRet

/*
===============================================================================================================================
Programa----------: GrvMotiv
Autor-------------: Lucas Crevilari
Data da Criacao---: 10/10/2014
===============================================================================================================================
Descrição---------: Função para gravação do Motivo do Cancelamento
===============================================================================================================================
Parametros--------:
===============================================================================================================================
Retorno-----------: lRet
===============================================================================================================================
*/
Static Function GrvMotiv

DbSelectArea("SC2")
SC2->(DbSetOrder(1))
SC2->(DbSeek(xFilial("SC2")+cNumOP))

SC2->(RecLock("SC2",.F.))
SC2->C2_I_MOTIV := ALLTRIM(cMotivo)
SC2->(MsUnlock())

Return
