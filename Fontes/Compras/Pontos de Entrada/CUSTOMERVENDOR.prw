/* 
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 13/08/2024 | Chamado 47782. Jerry. Incluir nova coluna para exibir o novo campo Tipo Averb. Carga (A2_I_TPAVE) 
Lucas Borges  | 10/12/2024 | Chamado 49331. Modificada regra para validar o campo A2_INCLTMG.
Lucas Borges  | 28/04/2025 | Chamado 50533. Criada valida��o para o mesmo produtor n�o ter configura��es de impostos diferentes
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#Include "Protheus.ch"
#Include "Parmtype.ch"

STATIC _aLogDif:={}

/*
===============================================================================================================================
Programa----------: CUSTOMERVENDOR
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 13/03/2019
Descri��o---------: Ponto de Entrada padr�o MVC no cadastro de Fornecedor
Parametros--------: PARAMIXB
Retorno-----------: L�gico - Define se passou pela valida��o
===============================================================================================================================
*/
User Function CUSTOMERVENDOR

Local aParam	:= PARAMIXB
Local _lRet		:= .T.
Local oObj		:= ""
Local cIdPonto	:= ""
Local cIdModel	:= ""
Local lIsGrid	:= .F.
Local _aArea	:= GetArea()
Local _cAlias	:= GetNextAlias()
Local _cMsg		:= ""
Local _cCodMsg	:= ""
Local _cSolMsg	:= ""
Local _cCampo	:= ""
Local _nRecSA2	:= 0
Local _aDadLog	:= {}
Local _cCodUsr	:= RetCodUsr()
Local _aTab		:={}
Local _nX		:= 0
Local _dDatLog	:= Date()
Local _cHorLog	:= Time()			
Local _aDadosCTD:= {}
Local _cFilOld	:= cFilAnt
Local _cA2_NOME := ""
Local _cA2_NREDUZ := ""
Local _cA2_END    := ""
Local _cA2_BAIRRO := ""
Local _cA2_COMPLEM := ""
Local _cA2_ENDCOMP := ""
Local _cA2_CONTATO := ""
Local _aCampLeit := {}
Local _cFiltro	:= "% %" as String

Private lMsErroAuto		:= .F. //Vari�vel de controle interno da rotina autom�tica que informa se houve erro durante o processamento.
Private lMsHelpAuto		:= .T. //Vari�vel que define que o help deve ser gravado no arquivo de log e que as informa��es est�o vindo � partir da rotina autom�tica.
Private lAutoErrNoFile	:= .T.//Vari�vel obrigat�rio para alimenta��o do GetAutoGRLog. For�a a grava��o das informa��es de erro em array para manipula��o da grava��o.

If aParam <> NIL
	oObj := aParam[1]
	cIdPonto := aParam[2]
	cIdModel := aParam[3]
	lIsGrid := (Len(aParam) > 3)
	
	If cIdPonto == "MODELPOS" //Chamada na valida��o total do modelo.
	
       _aLogDif:={}
	   _aStrutura:=SA2->( DBSTRUCT() )
	   For _nX := 1 To Len(_aStrutura)
		   aAdd(_aLogDif,{_aStrutura[_nX,1] ,SA2->(FIELDGET(_nX)) })
	   Next
	
	ElseIf cIdPonto == "FORMPOS"//Chamada na valida��o total do formul�rio.
	    //========================================================================
        // Fixa a averba��o do transportador como Sim.
		//========================================================================
        //If oObj:GetValue('A2_I_CLASS') == "T"           
		//   oObj:LoadValue('A2_I_AVERB','1')
        //EndIf 

		//Retira tabula��o que gera erro em arquivos magn�ticos do Fisco e Receita
		oObj:SetValue("A2_NOME",StrTran(oObj:GetValue("A2_NOME"),"	",""))
		oObj:SetValue("A2_END",StrTran(oObj:GetValue("A2_END"),"	",""))
		oObj:SetValue("A2_BAIRRO",StrTran(oObj:GetValue("A2_BAIRRO"),"	",""))
		oObj:SetValue("A2_ENDCOMP",StrTran(oObj:GetValue("A2_ENDCOMP"),"	",""))
		oObj:SetValue("A2_INSCR",StrTran(oObj:GetValue("A2_INSCR"),"	",""))
		oObj:SetValue("A2_INSCR",StrTran(oObj:GetValue("A2_INSCR"),"	",""))
		oObj:SetValue("A2_INSCR",StrTran(oObj:GetValue("A2_INSCR"),"	",""))
		//Grava Conta Cont�bil caso o usu�rio n�o informe nenhuma
		If Empty(oObj:GetValue("A2_CONTA"))
			oObj:SetValue("A2_CONTA",U_C_CONTABIL())
		EndIf
		//Trata Inscri��o Estadual
		If Empty(oObj:GetValue("A2_INSCR")) .Or. AllTrim(oObj:GetValue("A2_INSCR")) == "ISENTO"
			oObj:SetValue("A2_CONTRIB","2")
		Else
			oObj:SetValue("A2_CONTRIB","1")
		EndIf
		If Left(oObj:GetValue('A2_COD'),1) == "P"
		
			//Sempre que for produtor, marca para envio ao SmartQuestion
			oObj:SetValue('A2_L_SMQST','P')

			//Valida preenchimento de campos obrigat�rios do Leite			
			_aSX3 := FWSX3Util():GetAllFields( "SA2" , .F. )
			For _nX := 1 To Len(_aSX3)
				If AllTrim(_aSX3[_nX]) $ "A2_L_LI_RO/A2_L_TP_LR/A2_L_LI_RO/A2_L_TANQ/A2_L_ATIVO/A2_L_LI_RO/A2_L_CLASS/A2_L_LI_RO/A2_L_FAZEN/A2_L_LI_RO/A2_L_TPPAG"
					If Empty( oObj:GetValue(_aSX3[_nX]))
						_cCampo += AllTrim(GetSx3Cache(_aSX3[_nX],"X3_TITULO")) +" ; "
					EndIf
				EndIf
			Next _nX

			If !Empty( _cCampo )
				_cCodMsg:= "CUSTOMERVENDOR01"
				_cMsg	:= "Os campos a seguir, na pasta Gest�o do Leite s�o obrigat�rios para Produtores: " + _cCampo
				_cSolMsg:= "Preencha os campos informados."
				_lRet 	:= .F.
			EndIf
		EndIf
		//Valida��es para Transportador
		If _lRet .And. oObj:GetValue('A2_L_TIPPR') == "A" .AND. (Empty(oObj:GetValue('A2_L_ATRCO')) .OR. Empty(oObj:GetValue('A2_L_ATRLO',)))
			_cCodMsg:= "CUSTOMERVENDOR02"
			_cMsg	:= "Para o Produtor do tipo A - Atravessador deve ser informado os campos de "+AllTrim(GetSx3Cache("A2_L_ATRCO","X3_TITULO"))+" e "+AllTrim(GetSx3Cache("A2_L_ATRLO","X3_TITULO"))+" na Aba Gest�o do Leite."
			_cSolMsg:= "Revise conte�do do campo informado."
			_lRet 	:= .F.
		ElseIf _lRet .And. !(oObj:GetValue('A2_L_TIPPR') $ "A") .AND. (!Empty(oObj:GetValue('A2_L_ATRCO')) .OR. !Empty(oObj:GetValue('A2_L_ATRLO')))
			_cCodMsg:= "CUSTOMERVENDOR03"
			_cMsg	:= "Para o Produtor que N�O � do tipo A=Atravessador N�O deve ser informado os campos de "+AllTrim(GetSx3Cache("A2_L_ATRCO", "X3_TITULO"))+" e "+AllTrim(GetSx3Cache("A2_L_ATRLO", "X3_TITULO"))+" na Aba Gest�o do Leite."
			_cSolMsg:= "Revise conte�do do campo informado."
			_lRet := .F.	
		ElseIf _lRet .And. oObj:GetValue('A2_I_CLASS') == 'G' .And. oObj:GetValue('A2_TIPO') == 'J' .And. oObj:GetValue('A2_L_CTRC') <> 'S'
			_cCodMsg:= "CUSTOMERVENDOR04"
			_cMsg	:= "Transportador de leite a Granel pessoa jur�dica deve ter o Campo "+AllTrim(GetSx3Cache("A2_L_CTRC", "X3_TITULO"))+" informado com Sim."
			_cSolMsg:= "Revise conte�do do campo informado."
			_lRet := .F.
		ElseIf _lRet .And. oObj:GetValue('A2_L_TIPPR') = "A" .AND. (!Empty(oObj:GetValue('A2_L_ATRCO')) .AND. !Empty(oObj:GetValue('A2_L_ATRLO')))
		     _nRecSA2:=SA2->(RECNO())
		     If SA2->(DBSeek(xFilial("SA2")+oObj:GetValue('A2_L_ATRCO')+oObj:GetValue('A2_L_ATRLO'))) .AND. (!(SA2->A2_L_TIPPR $ "P") .OR. !(SA2->A2_I_CLASS $ "P"))
				_cCodMsg:= "CUSTOMERVENDOR05"
				_cMsg	:= "Os campos de Cod.Atravessador e Loja Atravessador devem ser da Classificacao: P-PRODUTOR e do Tipo: P-PRODUTOR."
				_cSolMsg:= "Revise conte�do do campo informado."
			 EndIf
		
		     SA2->(DBGoTo(_nRecSA2))
		EndIf
		
		//Valida��es referente � impostos
		If _lRet .And. Left(oObj:GetValue('A2_COD',),1) == "P" .And. oObj:GetValue('A2_TIPO') == "J" .AND. !Empty(oObj:GetValue('A2_TIPORUR'))
			_cCodMsg:= "CUSTOMERVENDOR06"
			_cMsg	:= "O campo" + AllTrim(GetSX3Cache("A2_TIPORUR","X3_TITULO")) + "� de uso exclusivo para Pessoa F�sica na gera��o do Reinf."
			_cSolMsg:= "Revise conte�do do campo informado."
			_lRet := .F.
		ElseIf _lRet .And. Left(oObj:GetValue('A2_COD',),1) == "P" .And. oObj:GetValue('A2_TIPO') == "J" .AND. !Empty(oObj:GetValue('A2_INDCP'))
			_cCodMsg:= "CUSTOMERVENDOR07"
			_cMsg	:= "O campo" + AllTrim(GetSX3Cache("A2_INDCP","X3_TITULO")) + "� de uso exclusivo para Pessoa F�sica na gera��o do Reinf."
			_cSolMsg:= "Revise conte�do do campo informado."
			_lRet := .F.
		ElseIf _lRet .And. Left(oObj:GetValue('A2_COD',),1) == "P" .And. oObj:GetValue('A2_TIPO') == "J" .AND. oObj:GetValue('A2_RECINSS') == 'S'
			_cCodMsg:= "CUSTOMERVENDOR08"
			_cMsg	:= "O campo" + AllTrim(GetSX3Cache("A2_RECINSS","X3_TITULO")) + "� de uso exclusivo para Pessoa F�sica na gera��o do Reinf."
			_cSolMsg:= "Revise conte�do do campo informado."
			_lRet := .F.
		ElseIf _lRet .And. Left(oObj:GetValue('A2_COD',),1) == "P" .And. oObj:GetValue('A2_TIPO') == "F" .And. (Empty(oObj:GetValue('A2_INDCP')) .Or. Empty(oObj:GetValue('A2_TIPORUR')))
			_cCodMsg:= "CUSTOMERVENDOR09"
			_cMsg	:="Para o Produtor Pessoa F�sica, os campos "+AllTrim(GetSx3Cache("A2_INDCP", "X3_TITULO"))+" e "+AllTrim(GetSx3Cache("A2_TIPORUR", "X3_TITULO"))+" devem ser preenchidos para correta gera��o do Reinf." 
			_cSolMsg:= "Revise conte�do do campo informado."
			_lRet := .F.
		ElseIf _lRet .And. oObj:GetValue('A2_TIPO') == "F" .And. oObj:GetValue('A2_INDCP') == "2" .AND. !oObj:GetValue('A2_RECINSS') == 'N'
			_cCodMsg:= "CUSTOMERVENDOR10"
			_cMsg	:= "Para o Fornecedor Pessoa F�sica que opte pelo desconto em folha do INSS e Gilrat, o campo "+AllTrim(GetSx3Cache("A2_RECINSS", "X3_TITULO"))+" n�o podem calcular o imposto para correta gera��o do Reinf." 
			_cSolMsg:= "Revise conte�do do campo informado."
			_lRet := .F.
		ElseIf _lRet .And. oObj:GetValue('A2_TIPO') == "F" .And. oObj:GetValue('A2_INDCP') == "1" .AND. oObj:GetValue('A2_RECINSS') <> 'S'
			_cCodMsg:= "CUSTOMERVENDOR11"
			_cMsg	:= "Para o Fornecedor Pessoa F�sica que N�o opte pelo desconto em folha do INSS e Gilrat, o campo "+AllTrim(GetSx3Cache("A2_RECINSS", "X3_TITULO"))+" deve calcular o imposto para correta gera��o do Reinf." 
			_cSolMsg:= "Revise conte�do do campo informado."
			_lRet := .F.
		ElseIf _lRet .And. ((oObj:GetValue('A2_TIPO') == "F" .And. oObj:GetValue('A2_TIPORUR') == "J") .Or. (oObj:GetValue('A2_TIPO') == "J" .And. oObj:GetValue('A2_TIPORUR') $ "F/8L"))
			_cCodMsg:= "CUSTOMERVENDOR12"
			_cMsg	:= "O campo "+ AllTrim(GetSX3Cache("A2_TIPORUR","X3_TITULO")) +" s� deve ser preenchido com F-F�sica / L-Familiar quando o fornecedor for Pessoa F�sica e J-Jur�dica quando por Pessoa Jur�dica para correta gera��o do Reinf."
			_cSolMsg:= "Revise conte�do do campo informado."
			_lRet := .F.
		ElseIf _lRet .And. oObj:GetValue('A2_INCLTMG') <> '1' .And. Left(oObj:GetValue('A2_COD'),1) == 'P' .And. oObj:GetValue('A2_TIPO') == 'F' .And.;
			F22->(DBSeek(xFilial("F22")+SuperGetMV("LT_REGINCP",.F.,"")+"1"))
			If oObj:GetValue('A2_INCLTMG') <> '1'
				MsgAlert("O campo "+ AllTrim(GetSX3Cache("A2_INCLTMG","X3_TITULO")) +" deve ser preenchido como 1-Sim para que seja calculado o Incentivo � Produ��o de Leite-MG. Seu conte�do foi ajustado."+;
						"D�vidas procurar departamento FISCAL.","CUSTOMERVENDOR13")
			EndIf
			oObj:SetValue('A2_INCLTMG','1')
		ElseIf _lRet
			_cAlias := GetNextAlias()
			If Altera
				_cFiltro := "% AND R_E_C_N_O_ <> " + CValToChar(SA2->(RECNO())) + " %"
			EndIf
			BeginSQL Alias _cAlias
				SELECT A2_TIPO, A2_TIPORUR, A2_INDCP, A2_RECINSS, A2_INCLTMG
				FROM %Table:SA2%
				WHERE D_E_L_E_T_ =' '
				AND A2_FILIAL = %xFilial:SA2%
				AND A2_CGC = %exp:oObj:GetValue('A2_CGC')%
				AND A2_COD LIKE 'P%'
				%exp:_cFiltro%
				AND (A2_TIPO <> %exp:oObj:GetValue('A2_TIPO')%
				OR A2_TIPORUR <> %exp:oObj:GetValue('A2_TIPORUR')%
				OR A2_INDCP <> %exp:oObj:GetValue('A2_INDCP')%
				OR A2_RECINSS <> %exp:oObj:GetValue('A2_RECINSS')%
				OR A2_INCLTMG <> %exp:oObj:GetValue('A2_INCLTMG')%)
				AND ROWNUM = 1
			EndSQL
			_cMsg := ""
			If !(_cAlias)->(EOF())
				If (_cAlias)->A2_TIPO <> oObj:GetValue('A2_TIPO')
					_cMsg += AllTrim(GetSX3Cache("A2_TIPO","X3_TITULO")) + "/ "
				EndIf
				If (_cAlias)->A2_TIPORUR <> oObj:GetValue('A2_TIPORUR')
					_cMsg += AllTrim(GetSX3Cache("A2_TIPORUR","X3_TITULO")) + "/ "
				EndIf
				If (_cAlias)->A2_INDCP <> oObj:GetValue('A2_INDCP')
					_cMsg += AllTrim(GetSX3Cache("A2_INDCP","X3_TITULO")) + "/ "
				EndIf
				If (_cAlias)->A2_RECINSS <> oObj:GetValue('A2_RECINSS')
					_cMsg += AllTrim(GetSX3Cache("A2_RECINSS","X3_TITULO")) + "/ "
				EndIf
				If (_cAlias)->A2_INCLTMG <> oObj:GetValue('A2_INCLTMG')
					_cMsg += AllTrim(GetSX3Cache("A2_INCLTMG","X3_TITULO"))
				EndIf
				If !FWAlertYesNo("Algumas configura��es de impostos est�o diferentes nos outros cadastros desse produtor: "+_cMsg+" Deseja continuar?", "CUSTOMERVENDOR24")
					_lRet := .F.
				EndIf
			EndIf
			(_cAlias)->(DBCloseArea())
		EndIf
		//Valida��o para Aut�nomos
		If _lRet .And. !Empty(oObj:GetValue('A2_I_FAUTA')) .And. !Empty(oObj:GetValue('A2_I_AUTAV'))
			_cAlias := GetNextAlias()
			BeginSQL Alias _cAlias
				SELECT A2_COD,A2_LOJA,A2_NOME
				FROM %Table:SA2%
				WHERE D_E_L_E_T_ =' '
				AND A2_FILIAL = %xFilial:SA2%
				AND R_E_C_N_O_ <> %exp:SA2->(RECNO())%
				AND A2_I_FAUTA = %exp:oObj:GetValue('A2_I_FAUTA')%
				AND A2_I_AUTAV = %exp:oObj:GetValue('A2_I_AUTAV')%
			EndSQL
		
			If !(_cAlias)->(EOF())
				_cCodMsg:= "CUSTOMERVENDOR14"
				_cMsg	:= "O Autonomo indicado j� se encontra amarrado ao Fornecedor: " + (_cAlias)->A2_COD + "/" + (_cAlias)->A2_LOJA + "-" + AllTrim((_cAlias)->A2_NOME)+" para gera��o do RPA avulso."
				_cSolMsg:= "Informe outro Aut�nomo ou corrija o cadastro do Fornecedor informado."
				_lRet := .F.
			EndIf
			(_cAlias)->(DBCloseArea())
		EndIf
		If _lRet .And. oObj:GetValue('A2_MSBLQL') == '1'
			_cAlias := GetNextAlias()			
			BeginSql alias _cAlias
				SELECT A3_COD, A3_FORNECE, A3_LOJA, A3_MSBLQL
				FROM %table:SA3%
				WHERE D_E_L_E_T_ =' '
				AND A3_FILIAL = %xFilial:SA3%
				AND A3_FORNECE = %exp:oObj:GetValue('A2_COD')%
				AND A3_LOJA = %exp:oObj:GetValue('A2_LOJA')%
			EndSql
				
			If !(_cAlias)->(EOF()) .and. (_cAlias)->A3_MSBLQL != '1'
				_cCodMsg:= "CUSTOMERVENDOR15"
				_cMsg	:= "O Fornecedor n�o pode ter seu cadastro bloqueado pois est� associado a um cadastro de vendedor ativo: " + (_cAlias)->A3_COD
				_cSolMsg:= "Bloquei primeiramente o Vendedor ou desassocie os dois."
				_lRet := .F.
			EndIf
			(_cAlias)->( DBCloseArea() )
		EndIf
		//Informativo para campos importantes quando n�o vier do GPE
		If _lRet .And. !IsInCallStack("U_GP010VALPE") .And. !IsInCallStack("U_GP265VALPE")
			If Empty(oObj:GetValue('A2_INSCR'))
				MsgAlert("O campo "+ AllTrim(GetSX3Cache("A2_INSCR","X3_TITULO")) +" est� vazio. Preencher como ISENTO quando for dispensado de IE e deixar em branco quando for n�o contribuinte do ICMS."+;
				"D�vidas procurar departamento FISCAL.","CUSTOMERVENDOR16")
			EndIf
				
			If Empty(oObj:GetValue('A2_EMAIL'))
				MsgAlert("O campo "+ AllTrim(GetSX3Cache("A2_EMAIL","X3_TITULO")) +" est� vazio. Esse campo � obrigat�rio para emiss�o de NF-e, por�m s� deve ser preenchido com um e-mail v�lido."+;
				"N�o cadastre endere�os gen�ricos como funionarios@italac.com.br ou nfe@italac.com.br. N�o existindo, deixe em branco","CUSTOMERVENDOR17")
			EndIf
		EndIf

		_cA2_NOME := oObj:GetValue('A2_NOME')
		If _lRet .And. !Empty(_cA2_NOME)
			_lRet := U_CRMA980VCP(@_cA2_NOME  ,"A2_NOME")
			oObj:LoadValue('A2_NOME',_cA2_NOME )
		EndIf

		_cA2_NREDUZ := oObj:GetValue('A2_NREDUZ')
		If _lRet .And. !Empty(_cA2_NREDUZ)
			_lRet := U_CRMA980VCP(@_cA2_NREDUZ  ,"A2_NREDUZ")
			oObj:LoadValue('A2_NREDUZ',_cA2_NREDUZ )
		EndIf

		_cA2_END := oObj:GetValue('A2_END')
		If _lRet .And. !Empty(_cA2_END)
			_lRet := U_CRMA980VCP(@_cA2_END  ,"A2_END")
			oObj:LoadValue('A2_END',_cA2_END )
		EndIf

		_cA2_BAIRRO := oObj:GetValue('A2_BAIRRO')
		If _lRet .And. !Empty(_cA2_BAIRRO)
			_lRet := U_CRMA980VCP(@_cA2_BAIRRO  ,"A2_BAIRRO")
			oObj:LoadValue('A2_BAIRRO',_cA2_BAIRRO )
		EndIf

		_cA2_COMPLEM := oObj:GetValue('A2_COMPLEM')
		If _lRet .And. !Empty(_cA2_COMPLEM)
			_lRet := U_CRMA980VCP(@_cA2_COMPLEM  ,"A2_COMPLEM")
			oObj:LoadValue('A2_COMPLEM',_cA2_COMPLEM )
		EndIf

		_cA2_ENDCOMP := oObj:GetValue('A2_ENDCOMP')
		If _lRet .And. !Empty(_cA2_ENDCOMP)
			_lRet := U_CRMA980VCP(@_cA2_ENDCOMP ,"A2_ENDCOMP")
			oObj:LoadValue('A2_ENDCOMP',_cA2_ENDCOMP )
		EndIf

		_cA2_CONTATO := oObj:GetValue('A2_CONTATO')
		If _lRet .And. !Empty(_cA2_CONTATO)
			_lRet := U_CRMA980VCP(@_cA2_CONTATO  ,"A2_CONTATO")
			oObj:LoadValue('A2_CONTATO',_cA2_CONTATO )
		EndIf

		If oObj:GetOperation() == 3
			oObj:SetValue("A2_COD",ITGeraCF(oObj))
			oObj:SetValue("A2_LOJA",U_ACOM006(oObj:GetValue("A2_CGC"),oObj:GetValue("A2_COD"),oObj:GetValue("A2_I_CLASS")))
		EndIf		

		If oObj:GetOperation() == 5 //Exclus�o

			aAdd(_aTab,{"%"+RetSqlName("ZLD")+"%","%ZLD_RETIRO%",'%ZLD_RETILJ%','Recep Leite Pr�prio'})//[1]
			aAdd(_aTab,{"%"+RetSqlName("ZLD")+"%","%ZLD_FRETIS%",'%ZLD_LJFRET%','Recep Leite Pr�prio'})//[2]
			aAdd(_aTab,{"%"+RetSqlName("ZLW")+"%","%ZLW_RETIRO%",'%ZLW_RETILJ%','Recep Leite Terceiros'})//[3]
			aAdd(_aTab,{"%"+RetSqlName("ZLW")+"%","%ZLW_FRETIS%",'%ZLW_LJFRET%','Recep Leite Terceiros'})//[4]
			aAdd(_aTab,{"%"+RetSqlName("ZL2")+"%","%ZL2_SA2COD%",'%ZL2_SA2LJ%','Setor do Leite associado'})//[5]
			aAdd(_aTab,{"%"+RetSqlName("ZL0")+"%","%ZL0_FRETIS%",'%ZL0_FRETLJ%','Motorista do Leite associado'})//[6]
			aAdd(_aTab,{"%"+RetSqlName("ZL3")+"%","%ZL3_FRETIS%",'%ZL3_FRETLJ%','Linha do Leite associada'})//[7]
			aAdd(_aTab,{"%"+RetSqlName("ZLC")+"%","%ZLC_FRETIS%",'%ZLC_LJFRET%','Desvio de Rota do Leite'})//[8]
			aAdd(_aTab,{"%"+RetSqlName("ZLM")+"%","%ZLM_SA2COD%",'%ZLM_SA2LJ%','Empr�stimo do Leite'})//[9]
			aAdd(_aTab,{"%"+RetSqlName("ZLL")+"%","%ZLL_CONVEN%",'%ZLL_LJCONV%','Conv�nio do Leite'})//[10]
			aAdd(_aTab,{"%"+RetSqlName("ZLL")+"%","%ZLL_RETIRO%",'%ZLL_RETILJ%','Conv�nio do Leite'})//[11]
			aAdd(_aTab,{"%"+RetSqlName("ZLB")+"%","%ZLB_RETIRO%",'%ZLB_RETILJ%','An�lise de Qualidade do Leite'})//[12]
			aAdd(_aTab,{"%"+RetSqlName("Z08")+"%","%Z08_CODFOR%",'%Z08_LOJFOR%','Pgto Neg Fornecedores'})//[13]
			aAdd(_aTab,{"%"+RetSqlName("ZLX")+"%","%ZLX_FORNEC%",'%ZLX_LJFORN%','Recep Leite Terceiros'})//[14]
			aAdd(_aTab,{"%"+RetSqlName("ZLX")+"%","%ZLX_TRANSP%",'%ZLX_LJTRAN%','Recep Leite Terceiros'})//[15]
			aAdd(_aTab,{"%"+RetSqlName("ZF5")+"%","%ZF5_FORTER%",'%ZF5_LOJTER%','Ocorrencias de Frete'})//[16]
			aAdd(_aTab,{"%"+RetSqlName("ZZN")+"%","%ZZN_FTRANS%",'%ZZN_LOJAFT%','Conhecimento e NF-e de Frete'})//[17]
			aAdd(_aTab,{"%"+RetSqlName("ZZT")+"%","%ZZT_TRANSP%",'%ZZT_LJTRAN%','Frete Leite Terceiros'})//[18]
			aAdd(_aTab,{"%"+RetSqlName("ZZU")+"%","%ZZU_TRANSP%",'%ZZU_LJTRAN%','Item Frete Terceiros associado'})//[19]
			aAdd(_aTab,{"%"+RetSqlName("ZZU")+"%","%ZZU_FORNEC%",'%ZZU_LJFORN%','Item Frete Terceiros associado'})//[20]
			aAdd(_aTab,{"%"+RetSqlName("ZZV")+"%","%ZZV_TRANSP%",'%ZZV_LJTRAN%','Veic Leite Terceiros associado'})//[21]
			aAdd(_aTab,{"%"+RetSqlName("ZZX")+"%","%ZZX_FORNEC%",'%ZZX_LJFORN%','Analise QL Leite Terceiros associada'})//[22]
			aAdd(_aTab,{"%"+RetSqlName("ZZX")+"%","%ZZX_TRANSP%",'%ZZX_LJTRAN%','Analise QL Leite Terceiros associada'})//[23]
			aAdd(_aTab,{"%"+RetSqlName("ZF0")+"%","%ZF0_CODFOR%",'%ZF0_LOJFOR%','Tabelas de Frete associada'})//[24]
			aAdd(_aTab,{"%"+RetSqlName("ZLJ")+"%","%ZLJ_CODTRN%",'%ZLJ_LOJTRN%','Recep��o SmartQuestion associada'})//[25]
			aAdd(_aTab,{"%"+RetSqlName("DAK")+"%","%DAK_I_REDP%",'%DAK_I_RELO%','Carga associada'})//[26]
			aAdd(_aTab,{"%"+RetSqlName("DAK")+"%","%DAK_I_OPER%",'%DAK_I_OPLO%','Carga associada'})//[27]
			aAdd(_aTab,{"%"+RetSqlName("SF2")+"%","%F2_I_REDP%",'%F2_I_RELO%','Documento de Sa�da associado'})//[28]
			aAdd(_aTab,{"%"+RetSqlName("SF2")+"%","%F2_I_OPER%",'%F2_I_OPLO%','Documento de Sa�da associada'})//[29]
			aAdd(_aTab,{"%"+RetSqlName("SA2")+"%","%A2_L_ATRCO%",'%A2_L_ATRLO%','Atravessador de Leite associado'})//[30]
			aAdd(_aTab,{"%"+RetSqlName("SA2")+"%","%A2_L_TANQ%",'%A2_L_TANLJ%','Tanque de Leite associado'})//[31]
			aAdd(_aTab,{"%"+RetSqlName("SA2")+"%","%A2_L_FORTX%",'%A2_L_LOJTX%','Fornecedor Taxa Assoc. Leite associado'})//[32]
			
			For _nX:=1 to Len(_aTab)
				_cAlias := GetNextAlias()
				BeginSql alias _cAlias	
					SELECT COUNT(1) NUMREG
					FROM %Exp:_aTab[_nX][1]%
					WHERE D_E_L_E_T_ = ' '
				      AND %Exp:_aTab[_nX][2]% = %Exp:oObj:GetValue('A2_COD')%
				      AND %Exp:_aTab[_nX][3]% = %oObj:GetValue('A2_LOJA')%
				      AND ROWNUM = 1
				EndSql   
				If (_cAlias)->NUMREG > 0
					_cCodMsg:= "CUSTOMERVENDOR18"
					_cMsg	:= "Este fornecedor j� foi utilizado na rotina "+_aTab[_nX][4]
					_cSolMsg:= "N�o � poss�vel excluir registro j� utilizado"
				    _lRet := .F.
				    Exit
				EndIf
				(_cAlias)->(DbCloseArea())
			Next _nX
		EndIf	
        
		//========================================================================================
        // Inserir aqui as valida��es para reenvio de dados a Cia do Leite.  
		//========================================================================================
/*
-----------------------------------
      _cIdProdut := TRBCAB->A2_COD+"-"+TRBCAB->A2_LOJA         N�O ALTERAR
      _cMatLatic := TRBCAB->A2_COD+"-"+TRBCAB->A2_LOJA//            matricula_laticinio   N�O ALTERAR
      _cRazaoSoc := TRBCAB->A2_NOME             //            nome_razao_social        N�O ALTERAR
      _cCpf_Cnpj := TRBCAB->A2_CGC              //            cpf_cnpj                  N�O ALTERAR
      _cInscrEst := TRBCAB->A2_INSCR            //            inscricao_estadual        N�O ALTERAR 
      _cRg_IE    := TRBCAB->A2_PFISICA          //            rg_ie                    N�O ALTERAR  
	  _cSigSif    := TRBDET->A2_L_SIGSI      // N�O ALTERAR   
*/	  
//--------------------------------------------------------------------------------------------------//	  
        If oObj:GetOperation() == 4 .And. SA2->A2_I_CLASS == "P" .And. SA2->A2_I_ENVCL == "N" 
           Aadd(_aCampLeit,"A2_ENDCOMP")   // complemento              
           Aadd(_aCampLeit,"A2_END")       // endereco                  
           Aadd(_aCampLeit,"A2_BAIRRO")    // bairro                    
           Aadd(_aCampLeit,"A2_CEP")       // cep                       
           Aadd(_aCampLeit,"A2_MUN")       // municipio  
           Aadd(_aCampLeit,"A2_EST")       // estado        
           Aadd(_aCampLeit,"A2_COD_MUN")   // codigo_ibge
           Aadd(_aCampLeit,"A2_BANCO")     // Codigo do Banco
           Aadd(_aCampLeit,"A2_AGENCIA")   // Codigo da Agencia
           Aadd(_aCampLeit,"A2_NUMCON")    // Numero da Conta      
           Aadd(_aCampLeit,"A2_EMAIL")     // email                     
           Aadd(_aCampLeit,"A2_TEL")       // telefone1                 
           Aadd(_aCampLeit,"A2_L_FAZEN")   // nome_propriedade_rural    
           Aadd(_aCampLeit,"A2_L_NIRF")    // NIRF  
           Aadd(_aCampLeit,"A2_L_TANQ")    // tipo_tanque 
           Aadd(_aCampLeit,"A2_L_MARTQ")   // Marca do Tanque
           Aadd(_aCampLeit,"A2_L_CLASS")   // Classifica��o Produtor
           Aadd(_aCampLeit,"A2_L_CAPTQ")   // capacidade_tanque         
           Aadd(_aCampLeit,"A2_L_LATIT")   // latitude_propriedade      
           Aadd(_aCampLeit,"A2_L_LONGI")   // longitude_propriedade     
           Aadd(_aCampLeit,"A2_L_FREQU")   // frequencia_coleta         
           Aadd(_aCampLeit,"A2_L_CAPAC")   // Capacidade resfriamento
           Aadd(_aCampLeit,"A2_L_ATIVO")   // Ativo ou Inativo
           Aadd(_aCampLeit,"A2_L_TANLJ")   // Loja do Tanque
           Aadd(_aCampLeit,"A2_L_RESFR")   // Tipo de Resfriamento
           Aadd(_aCampLeit,"A2_L_LI_RO")   // codigo_linha_laticinio
           
		   For _nX := 1 To Len(_aCampLeit)
               If oObj:GetValue(_aCampLeit[_nX]) <> SA2->&(_aCampLeit[_nX])
                  oObj:LoadValue('A2_L_ENVAT','S')
				  Exit
			   EndIf   
		   Next 

		EndIf 

		//========================================================================
        // Valida��es chamamdo 47782. 
		//========================================================================
        If _lRet .And. oObj:GetValue('A2_I_CLASS') == "T"  
   
           If Empty(oObj:GetValue('A2_I_TPAVE') )  // Pasta outros.
              _cNomPasta := U_ITRETPAS("SA2",'A2_I_TPAVE', "D")
		      If Empty(_cNomPasta)
		         _cNomPasta := ""
		      Else 
		         _cNomPasta := "(contido na pasta: " + AllTrim(_cNomPasta) + ")"
		      EndIf

              _cCodMsg := "CUSTOMERVENDOR20"
              _cMsg	   := "Para Fornecedores classificados como Transportador, o preenchimento do campo 'Tipo Averb C' "+ _cNomPasta +" � obrigat�rio."
              _cSolMsg := "Preencha o campo 'Tipo Averb C' "+_cNomPasta + "."
			  _lRet    := .F.
           EndIf 

           If Empty(oObj:GetValue('A2_I_TPFRT') )  
              _cNomPasta := U_ITRETPAS("SA2",'A2_I_TPFRT', "D")
		      If Empty(_cNomPasta)
		         _cNomPasta := ""
		      Else 
		         _cNomPasta := "(contido na pasta: " + AllTrim(_cNomPasta) + ")"
		      EndIf

              _cCodMsg := "CUSTOMERVENDOR21"
              _cMsg	   := "Para Fornecedores classificados como Transportador, o preenchimento do campo 'Tp Seg Frete' " + _cNomPasta + " � obrigat�rio."
              _cSolMsg := "Preencha o campo 'Tp Seg Frete' " + _cNomPasta + "."
			  _lRet    := .F.
           EndIf 

		EndIf 

		If _lRet .And. ! Empty(oObj:GetValue('A2_I_TPAVE') )  .And. oObj:GetValue('A2_I_TPAVE') == "T" 
		   oObj:SetValue("A2_I_TPFRT",'N')  // Pasta Italac
		EndIf 
		
	ElseIf cIdPonto == "FORMLINEPRE"//Chamada na pr� valida��o da linha do formul�rio

	ElseIf cIdPonto == "FORMLINEPOS"//Chamada na valida��o da linha do formul�rio

	ElseIf cIdPonto == "MODELCOMMITTTS"//Chamada ap�s a grava��o total do modelo e dentro da transa��o.
		//================================================================================
		// Inicializa o LOG de altera��es
		//================================================================================
		If !oObj:GetOperation() == 5 .And. !oObj:GetOperation() == 3 //N�o � exclus�o nem inclus�o
			If !Empty( _aLogDif )
				U_ITGrvLog( _aLogDif , 'SA2' , 1 , oObj:GetValue("SA2MASTER","A2_FILIAL")+oObj:GetValue("SA2MASTER","A2_COD")+oObj:GetValue("SA2MASTER","A2_LOJA") , 'A' , _cCodUsr , _dDatLog , _cHorLog )
			EndIf
     		
		EndIf
		//Dispara na inclus�o ou quando o produtor for trocado de Setor. Uso o campo de linha que ter� o mesmo efeito
		If oObj:GetOperation() == 3 .Or. oObj:IsFieldUpdated("SA2MASTER","A2_L_LI_RO") == .T.
			//================================================================================
			// Cria item cont�bil para o novo fornecedor
			//================================================================================
			CTD->(Dbsetorder(1))
			If !CTD->(Dbseek(xFilial("CTD")+"SA2"+ oObj:GetValue("SA2MASTER","A2_COD")))
				_aDadosCTD:= {	{'CTD_ITEM',"SA2" + oObj:GetValue("SA2MASTER","A2_COD"), Nil},;	// Especifica qual o C�digo do item contabil
								{'CTD_CLASSE',"2", Nil},;	// Especifica a classe do Centro de Custo, que  poder� ser: - Sint�tica: Centros de Custo totalizadores dos Centros de Custo Anal�ticos - Anal�tica: Centros de Custo que recebem os valores dos lan�amentos cont�beis
								{'CTD_DESC01',oObj:GetValue("SA2MASTER","A2_NOME"), Nil},; // Indica a Nomenclatura do item contabil na Moeda 1
								{'CTD_BLOQ',"2", Nil},;	// Indica se o Centro de Custo est� ou n�o bloqueado para os lan�amentos cont�beis.
								{'CTD_DTEXIS',SToD("19800101"), Nil},;	// Especifica qual a Data de In�cio de Exist�ncia para este Centro de Custo
								{'CTD_ITLP',"SA2" + oObj:GetValue("SA2MASTER","A2_COD"), Nil},; //Indica o Item Cont�bil de Apura��o de Resultado.
								{'CTD_CLOBRG',"2", Nil},; //Indique se ao efetuar um Lan�amento Cont�bil com este Item Cont�bil Classe de Valor dever� ser informada obrigatoriamente.
								{'CTD_ACCLVL',"1", Nil},; //Indique se ao efetuar um Lan�amento Cont�bil com este Item Cont�bil a Classe de Valor poder� ser informada.
								{'CTD_CLASSE',"2", Nil}}//Especifica a classe cont�bil do Item Cont�bil, que  poder� ser: - Sint�tica: Itens Cont�beis Totalizadores dos Itens Anal�ticos - Anal�tica: Itens Cont�beis que recebem os valores dos lan�amentos cont�beis.
				MSExecAuto({|x, y| CTBA040(x, y)},_aDadosCTD, 3)
				If lMsErroAuto
					MostraErro()
					_cCodMsg:= "CUSTOMERVENDOR19"
					_cMsg	:= "Erro na inclus�o do Item cont�bil"
					_cSolMsg:= "Acione o departamento de TI"
					_lRet := .F.
				EndIf
			EndIf

			//=====================================================================================
			// Cria cadastro no configurador de tributos para o c�lculo do Incentivo a produ��o MG
			//=====================================================================================			
			cFilAnt:= Substr(oObj:GetValue("SA2MASTER","A2_L_LI_RO"),1,2)
			If Left(oObj:GetValue("SA2MASTER","A2_COD"),1) == "P" .And. oObj:GetValue("SA2MASTER","A2_TIPO") == 'F';
				.And. F28->(DbSeek(xFilial('F28')+SuperGetMV("LT_INCINCP",.F.,"")));
				.And. !F22->(DbSeek(xFilial("F22")+SuperGetMV("LT_REGINCP",.F.,"")+"1"+oObj:GetValue("SA2MASTER","A2_COD")+oObj:GetValue("SA2MASTER","A2_LOJA")))
				FSA164GF22(SuperGetMV("LT_REGINCP",.F.,"")/*cCodPerfil*/, "INCLUI"/*cOper*/, "1"/*cTpPart*/,oObj:GetValue("SA2MASTER","A2_COD")/*cCliFor*/,oObj:GetValue("SA2MASTER","A2_LOJA")/*cLoja*/)
			EndIf
			cFilAnt:= _cFilOld
			//================================================================================
			// Tratativa para grava��o do LOG de inclus�o de Fornecedores
			//================================================================================
			aAdd( _aDadLog , {'A2_COD'	,oObj:GetValue("SA2MASTER","A2_COD")	, '' } )
			aAdd( _aDadLog , {'A2_LOJA'	,oObj:GetValue("SA2MASTER","A2_LOJA")	, '' } )
			aAdd( _aDadLog , {'A2_CGC'	,oObj:GetValue("SA2MASTER","A2_CGC")	, '' } )
			aAdd( _aDadLog , {'A2_NOME'	,oObj:GetValue("SA2MASTER","A2_NOME")	, '' } )
			
			U_ITGrvLog( _aDadLog , 'SA2' , 1 , oObj:GetValue("SA2MASTER","A2_FILIAL")+oObj:GetValue("SA2MASTER","A2_COD")+oObj:GetValue("SA2MASTER","A2_LOJA") , 'I' , _cCodUsr , Date() , Time() )
		EndIf		
	ElseIf cIdPonto == "MODELCOMMITNTTS"//Chamada ap�s a grava��o total do modelo e fora da transa��o.
	ElseIf cIdPonto == "FORMCOMMITTTSPRE"//Chamada ap�s a grava��o da tabela do formul�rio.
	ElseIf cIdPonto == "FORMCOMMITTTSPOS"//Chamada ap�s a grava��o da tabela do formul�rio.
	ElseIf cIdPonto == "MODELCANCEL"
	ElseIf cIdPonto == "BUTTONBAR"
		_lRet := {{"LOG Altera��es", "Log - Historico de Alteracoes", {||U_CCOM001()}}}
	EndIf
EndIf

If !Empty(_cCodMsg)
	Help(NIL, NIL, _cCodMsg, NIL, _cMsg, 1, 0, NIL, NIL, NIL, NIL, NIL, {_cSolMsg})
EndIf
RestArea( _aArea )

Return _lRet

/*
===============================================================================================================================
Programa----------: ITGeraCF
Autor-------------: Alexandre Villar
Data da Criacao---: 02/09/2014
Descri��o---------: Rotina para gerar c�digo de Fornecedor + Loja na inclus�o de novos fornecedores
Parametros--------: cClasse  : classifica��o de fornecedores
------------------: cTipo    : tipo de pessoa do fornecedor (F�sica/Jur�dica)
------------------: cCGC     : CPF/CNPJ do fornecedor
Retorno-----------: lRet     : Valida se pode ou n�o prosseguir com o cadastro
===============================================================================================================================
*/
Static Function ITGeraCF(oObj)

Local _aArea    := GetArea()
Local _cAlias	:= GetNextAlias()
Local _cCodigo  := ""
Local _cFiltro	:= ""
Local _lNew		:= .F.
Local _lTroca	:= .F.

//================================================================================
// Verifica se o C�digo de Fornecedor informado j� foi utilizado
//================================================================================
If oObj:GetValue("A2_TIPO") == "J" .And. !oObj:GetValue("A2_I_CLASS") == 'Z'
	_cFiltro := "% AND SUBSTR(A2_CGC,1,8) <> '"+ Left(oObj:GetValue("A2_CGC"),8) +"' %"
Else
	_cFiltro := "% AND A2_CGC  <> '"+ Alltrim(oObj:GetValue("A2_CGC")) +"' %"
EndIf
_cAlias := GetNextAlias()			
BeginSql alias _cAlias
	SELECT DISTINCT A2_COD CODIGO
	FROM %table:SA2%
	WHERE D_E_L_E_T_ =' '
	%exp:_cFiltro%
	AND A2_COD = %exp:oObj:GetValue("A2_COD")%
EndSql

If (_cAlias)->( !Eof() )
	_lTroca	:= .T.
Else
	_cCodigo:= oObj:GetValue("A2_COD")
EndIf

(_cAlias)->( DBCloseArea() )

//================================================================================
// Verifica se j� existe registros do mesmo fornecedor na Base
//================================================================================

If oObj:GetValue("A2_TIPO") == "J" .And. !oObj:GetValue("A2_I_CLASS") == 'Z'
	_cFiltro := "% AND SUBSTR(A2_CGC,1,8) = '"+ Left(oObj:GetValue("A2_CGC"),8) +"' %"
Else
	_cFiltro := "% AND A2_CGC  = '"+ Alltrim(oObj:GetValue("A2_CGC")) +"' %"
EndIf
_cAlias := GetNextAlias()			
BeginSql alias _cAlias
	SELECT A2_COD CODIGO, MAX(A2_LOJA) LOJA
	FROM %table:SA2%
	WHERE D_E_L_E_T_ =' '
	%exp:_cFiltro%
	GROUP BY A2_COD
EndSql

If (_cAlias)->( !EOF() ) // Existe codigo para o CGC atual
	While (_cAlias)->( !Eof() )
		If ( SubStr( (_cAlias)->CODIGO , 1 , 1 ) == oObj:GetValue("A2_I_CLASS") ) //Validar se ja existe codigo para a classe
			_cCodigo := (_cAlias)->CODIGO
		EndIf
	(_cAlias)->( DBSkip() )
	EndDo
	
	If Empty( _cCodigo )
		If MsgYesNo( "Este "+ IIf( oObj:GetValue("A2_TIPO") == "J" , "CNPF" , "CPF" ) +" ja foi cadastrado para um fornecedor, porem este fornecedor possui outra classe." +;
						"Se deseja criar este fornecedor utilizando a nova classe informada, selecione [SIM]. Caso contrario, se desejar manter" +;
						" a mesma codifica��o utilizada na outra classe, selecione [N�O].", "CUSTOMERVENDOR22")
			_lNew := .T.
		Else
			(_cAlias)->( DBGotop() )
			_cCodigo	:= (_cAlias)->CODIGO
			_lTroca		:= .F.
			_lNew		:= .F.
		EndIf
	EndIf
EndIf

(_cAlias)->( DBCloseArea() )

//================================================================================
// Verifica se o C�digo de Fornecedor informado j� foi utilizado
//================================================================================
If _lTroca .Or. _lNew .OR. (oObj:GetValue("A2_EST") == 'EX' .AND. oObj:GetValue("A2_CGC") = '00000000000000')  //Se for fornecedor externo gera c�digo novo com cgc zerado
	_cAlias := GetNextAlias()			
	BeginSql alias _cAlias
		SELECT MAX(A2_COD) CODIGO
		FROM %table:SA2%
		WHERE D_E_L_E_T_ =' '
		AND SUBSTR(A2_COD,1,1) = %exp:oObj:GetValue("A2_I_CLASS")%
	EndSql
	If (_cAlias)->( !Eof() )
		_cCodigo := oObj:GetValue("A2_I_CLASS") + Soma1(Right((_cAlias)->CODIGO,5))
	Else
		_cCodigo := oObj:GetValue("A2_I_CLASS") + PadL('1',5,'0') 
	EndIf
	
	(_cAlias)->( DBCloseArea() )
	
	While !MayIUseCode( "A2_COD" + xFilial("SA2") + _cCodigo )	// verifica se esta sendo usado na memoria
		_cCodigo := Soma1( AllTrim( _cCodigo ) )				// busca o proximo n�mero disponivel
	EndDo
	
EndIf

RestArea(_aArea)

If _lTroca
	MsgAlert("O c�digo do fornecedor foi trocado para ["+ _cCodigo +"] pois j� havia um registro na base com o c�digo anterior.", "CUSTOMERVENDOR23")
EndIf

Return( _cCodigo )
