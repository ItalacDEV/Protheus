/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |02/10/2019| Chamado 28346. Removidos os Warning na compilação da release 12.1.25.
Lucas Borges  |27/06/2025| Chamado 50617. Revisões diversas visando padronizar os fontes
===============================================================================================================================
*/

#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: PNA020GRV
Autor-------------: Josué Danich Prestes
Data da Criacao---: 04/12/2015
Descrição---------: Ponto de Entrada executado durante a inclusão, alteração ou exclusão dos feriados. - Chamado 12943
Parametros--------: Nenhum
Retorno-----------: 
===============================================================================================================================
*/
User Function PNA020GRV

Local aArea 	:= FWGetArea() As Array
Local lRet		:= .T. As Logical
Local aExist	:= {"MUNICIPAL","ESTADUAL","NACIONAL"} As Array
Local oDlg		:= Nil As Object
Local cAt		:= "MUNICIPAL" As Character
	
//================================================================================
//Se for inclusao ou alteracao pergunta o tipo de feriado
//Garante que o campo fixo será sempre gravado como não
//================================================================================
	
If paramixb[4] == 1 .OR. paramixb[4] == 2
	//Se é alteração já traz o combobox posicionado no valor atual
	If paramixb[4] == 2
		If SP3->P3_I_TPFER == 'N'
			cAt := "NACIONAL"
		ElseIf SP3->P3_I_TPFER == 'E'
			cAt := "ESTADUAL"
		Else
			cAt := "MUNICIPAL"
		EndIf
	EndIf

	DEFINE MSDIALOG oDlg TITLE "TIPO DE FERIADO" FROM 0,0 TO 150,230 PIXEL		
	@ 10,10 SAY "Escolha o tipo de feriado:"
	@ 30,10 MSCOMBOBOX oComboBo1 VAR cAt ITEMS aExist SIZE 90, 95 OF oDlg  PIXEL   
		
	DEFINE SBUTTON FROM 50,50 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTER
	
	SP3->(Reclock("SP3",.F.))
		SP3->P3_I_TPFER := SUBSTR(cAt,1,1)
		SP3->P3_FIXO := 'N'
		SP3->P3_MESDIA := ''
	SP3->(Msunlock())
EndIf

FWRestArea(aArea)

Return lRet
