/*
====================================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
====================================================================================================================================
 Autor        |  Data    |                              Motivo                      										 
 ===================================================================================================================================
 Alex Wallauer| 13/02/19 | Chamado 28081. Ajuste para funcionar a chamada do MENUDEF.  
 Josu� Danich | 11/04/19 | Chamado 28694. Valida��es de bloqueio log�stico.  
 Lucas Borges | 15/10/19 | Chamado 28346. Removidos os Warning na compila��o da release 12.1.25. 
 Jerry        | 01/12/20 | Chamado 34828. Permitir Alterar Tipo de Frete e Valor de Desconto FOB. 
 Jerry        | 19/02/21 | Chamado 35647. Corre��o para Tratar Tipo Agend. Agenda c/Multa. 
 Julio Paz    | 14/07/21 | Chamado 36661. Corrigir rotina manuten��o pedidos vendas para validar dt entrega >= Dt.Atual.
 Julio Paz    | 24/09/21 | Chamado 37814. Inclus�o de novas regras para definir transit time na valida��o da data de entrega. 
 Jerry        | 17/06/22 | Chamado 40304. Alterar rotina de Manuten��o Ped.Vendas para calcular e gravar valor de seguro. 
 Julio Paz    | 21/06/22 | Chamado 39908. P/calcular Frete/Seguro Fob,validar opera��o em par�metro/data emiss�o superior param. 
 Alex Wallauer| 25/10/23 | Chamado 44881. Tela de preencher observa��o/justificativa para altera��o de C5_I_AGEND OU C5_I_DTENT.
 Alex Wallauer| 08/02/24 | Chamado 44782. Jerry. Ajustes para a nova opcao de tipo de entrega: O = Agendado pelo Op.Log.
 Alex Wallauer| 27/02/24 | Chamado 46373. Andre. Criacao do controlo de contagem de altera��es para data entrega/tipo agendamento.
 Alex Walaluer| 22/07/24 | Chamado 47863. Jerry. Corre��o do Error.log type mismatch on compare on MA410IMPOS(MATN410B.PRW).
==============================================================================================================================================================
Analista    - Programador   - Inicio   - Envio    - Chamado - Motivo da Altera��o
==============================================================================================================================================================
Bremmer     - Alex Wallauer - 11/10/24 - 20/03/25 -  48700 - Alteracao para n�o justificar a altera��o da data de entrega do PV quando for M->C5_I_AGEND = I.
Jerry       - Igor Melga�o  - 25/02/24 - 20/03/25 -  39201 - Ajustes para contabilizar a quantidade de altera��es efetuadas no pedido de vendas.
Jerry       - Julio Paz     - 13/05/25 - 18/07/25 -  49758 - Ajustes nas telas de solicita��es de justificativas para altera��es de tipo de agendamento e data de entrega.
================================================================================================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"
/*
===============================================================================================================================
Programa----------: AOMS026
Autor-------------: Wodson Reis Silva
Data da Criacao---: 16/07/2009
===============================================================================================================================
Descri��o---------: Rotina de alteracao de campos especificos do PV, sem perder libera��o de estoque
===============================================================================================================================
Parametros--------: ExpC01 - Nome do alias em uso no Browse.
                    ExpN02 - Numero do Recno do alias em uso no Browse.
                    ExpN03 - Numero da opcao selecionada no menu lateral do Browse.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS026(cAlias,nReg,nOpc)

//Declaracao de Variaveis.                                
	Local oDlg
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oGetD
	Local aPosObj   := {}
	Local aObjects  := {}
	Local aSize     := {}
	Local aPosGet   := {}
	Local aRegSC6   := {}
	Local aInfo     := {}
	Local aButtons  := {}
	Local nCntFor   := 0
	Local lContinua := .T.
	Local nOpcA     := 0
	Local nLinGet   := 0
	Local nTamAcols := 1
	Local cCampo    := ""
	Local cArqQry   := ""
	Local aArea     := GetArea()
	Local lFreeze   := (SuperGetMv("MV_PEDFREZ",.F.,0) <> 0)
	Local nColFreeze:= SuperGetMv("MV_PEDFREZ",.F.,0)
	Local _lret     := .T.
	Local oproc

	nOpc:=4//For�a a linha de altera��o do aRotina, pq a linha 13 vem como visualizar

	Private aCols     := {}
	Private aHeader   := {}
	Private aTES      := {}
	Private aNewTES   := {}
	Private aCpos1    := {}
	Private aCpos2    := {}
	Private aTELA[0][0]
	Private aGETS[0]

	Private aAreaSC5 := SC5->(GetArea())
	Private aAreaSC6 := SC6->(GetArea())
	Private aAreaSC9 := SC9->(GetArea())

	Private _cOperTriangular:= ALLTRIM(U_ITGETMV( "IT_OPERTRI","05,42"))// Tipos de opera��es da opera��o trigular
	Private _cOperFat       := LEFT(_cOperTriangular,2)
	Private _cOperRemessa   := RIGHT(_cOperTriangular,2)
	Private _nRecOrigem     := SC5->(RECNO())

//============================================================================
//Roda processo de valida��o
//============================================================================
	fwmsgrun( ,{|oproc| _lret := AOMS026V(oproc)}				, 'Aguarde!' , 'Verificando os dados...'  )
	If !_lret

		Return

	Endif


//============================================================================
//Indica as rotinas abaixo que se trata de alteracao                         
//=============================================================================
	ALTERA := .T.

//============================================================================
// Inicializa desta forma para criar uma nova instancia de variaveis private 
//=============================================================================
	RegToMemory( "SC5", .F., .F. )

//============================================================================
//Montagem do aheader                                                        
//=============================================================================
	FillGetDados(1,"SC6",1,,,{||.T.},,,,,,.T.)

//============================================================================
//Montagem do aCols                                                          
//=============================================================================
	aCols := {}

	If ( lContinua )

		dbSelectArea("SC6")
		dbSetOrder(1)
		cArqQry := "SC6"
		MsSeek(xFilial("SC6")+SC5->C5_NUM)

		While ( (cArqQry)->(!Eof()) .And. (cArqQry)->C6_FILIAL == xFilial("SC6") .And.;
				(cArqQry)->C6_NUM == SC5->C5_NUM .And. lContinua )

			//============================================================================
			// Adiciona os campos no Acols.
			//=============================================================================
			AADD(aCols,Array(Len(aHeader)+1))
			For nCntFor := 1 To Len(aHeader)
				cCampo := Alltrim(aHeader[nCntFor,2])
				If ( aHeader[nCntFor,10] # "V" .And. ! (cCampo $ "C6_QTDLIB/C6_ALI_WT/C6_REC_WT")) // cCampo <> "C6_QTDLIB"
					aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(cCampo))
				Else
					If cCampo == "C6_ALI_WT"
						aCols[Len(aCols)][nCntFor] := "SC6"
					ElseIf cCampo == "C6_REC_WT"
						aCols[Len(aCols)][nCntFor] := (cArqQry)->(RecNo())
					Else
						aCols[Len(aCols)][nCntFor] := CriaVar(cCampo)
					EndIf
				EndIf
			Next nCntFor

			aCols[Len(aCols)][Len(aHeader)+1] := .F.

			//=========================================================================
			//Guarda os registros do SC6 para posterior gravacao
			//==========================================================================
			aadd(aRegSC6, (cArqQry)->(RecNo()) )

			(cArqQry)->(dbSkip())
		EndDo
	EndIf


//============================================================================
//Valida os itens do aCols                                                   
//=============================================================================
	If ( Len(aCols) == 0 )
		U_ITmsg("N�o foram encontrdos itens nesse Pedido "+xFilial("SC6")+" "+SC5->C5_NUM,"Aten��o","Contate a area de TI",1)//HELP(" ",1,"A440S/ITEM")
		lContinua := .F.
	EndIf

//============================================================================
// Verifica o tamanho do aCols para nao permitir inclusao de novas linhas.   
//=============================================================================
	nTamAcols := Len(aCols)

	DO WHILE ( lContinua )

		lContinua:=.F.
		nOpcA:= 0
		aTela:={}
		aGets:={}
		//============================================================================
		//Calculo das dimensoes da Janela
		//=============================================================================
		aSize    := MsAdvSize()
		aObjects := {}
		AAdd( aObjects, { 100, 100, .T., .T. } )
		AAdd( aObjects, { 100, 100, .T., .T. } )
		AAdd( aObjects, { 100, 015, .T., .F. } )

		aInfo   := { aSize[ 1 ],aSize[ 2 ],aSize[ 3 ],aSize[ 4 ],03,03 }
		aPosObj := MsObjSize( aInfo, aObjects )
		aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{003,157,189,236,268}})

		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

		EnChoice( cAlias, nReg, nOpc, , , , , aPosObj[1], aCPos1, 3 )

		oGetd := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,,,"",,aCPos2,nColFreeze,,nTamAcols,,,,,,lFreeze)

		nLinGet := aPosObj[3,1]

		@ nLinGet,aPosGet[1,1] SAY oSAY1 VAR Space(40)             SIZE 120,09 PICTURE "@!"	OF oDlg PIXEL
		@ nLinGet,aPosGet[1,2] SAY OemToAnsi("Total: ")            SIZE 020,09 OF oDlg	PIXEL
		@ nLinGet,aPosGet[1,3] SAY oSAY2	VAR 0 PICTURE TM(0,16,2)  SIZE 040,09 OF oDlg PIXEL
		@ nLinGet,aPosGet[1,4] SAY OemToAnsi("Desc. :")            SIZE 020,09 OF oDlg PIXEL
		@ nLinGet,aPosGet[1,5] SAY oSAY3 VAR 0	PICTURE TM(0,16,2)  SIZE 040,09 OF oDlg PIXEL
		@ nLinGet + 10,aPosGet[1,4] SAY OemToAnsi("=")             SIZE 020,09 OF oDlg PIXEL
		@ nLinGet + 10,aPosGet[1,5] SAY oSAY4 VAR 0                SIZE 040,09 PICTURE TM(0,16,2) 	OF oDlg PIXEL
		oDlg:Cargo	:= {|c1,n2,n3,n4|  oSay1:SetText(c1),;
			oSay2:SetText(n2),;
			oSay3:SetText(n3),;
			oSay4:SetText(n4) }
		Ma410Rodap(oGetD)
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGetd:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()},,aButtons)

		If ( nOpcA == 1 )
			_lOK:=.T.
			fwMsgRun(,{|oproc| _lOK:=AOMS026G(oproc) },"Processando","Aguarde....Gravando dados...")
			IF !_lOK
				lContinua:=.T.
			ENDIF
		EndIf

	ENDDO

//=========================================================================
//Destravamento dos Registros                                             
//==========================================================================
	MsUnLockAll()
	RestArea(aArea)

Return

/*
===============================================================================================================================
Programa----------: AOMS026G
Autor-------------: Wodson Reis Silva
Data da Criacao---: 16/07/2009
===============================================================================================================================
Descri��o---------: Gravacao dos dados alterados. 
===============================================================================================================================
Parametros--------: oproc - obejto da barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS026G(oproc As Object) As Logical

Local nX   := 0 As Numeric
Local _dDtAnt := SC5->C5_I_DTENT As Date
Local _cAgAnt := SC5->C5_I_AGEND As Character
Local _antsc5 := {} As Array
Local _oproc := Nil As Object
Local _nValorPedido := 0 As Numeric
Local _lOk := .T. As Logical
Local _cFilCarreg := "" As Character
Local _nPerSegFob := U_ITGETMV( "IT_PERSEGFB" , 0.13 ) As Numeric
Local _cOperFret := U_ITGETMV("IT_OPERFRE","") As Character
Local _dDtCalcFr := Ctod(U_ITGETMV("IT_DTCALCF","23/06/2022")) As Date

Private _aLogSC5 := {} As Array
Private _aLogSC6 := {} As Array 

Default oproc := nil

SA1->( DBSetOrder(1) )
SA1->( DBSeek( xFilial('SA1') + M->( C5_CLIENTE + C5_LOJACLI ) ) )

Begin Sequence
        //============================================================================================================
        // Valida��o data de entrega.
        //============================================================================================================
        If Dtos(M->C5_I_DTENT) < Dtos(Date())
           U_MT_ITMSG("A data de entrega n�o pode ser menor que a data atual.","Atencao!","Informe uma data de entrega maior ou igual a data atual.",1)
           _lOk := .F.

		   Break 
        EndIf 
		IF M->C5_I_AGEND = 'M' .AND. SA1->A1_I_AGEND <> M->C5_I_AGEND//Quando o PV � M o Cliente tem que ser tb

			U_MT_ITMSG('Pedido '+M->C5_NUM + " Tipo de Entrega do Cliente ["+SA1->A1_I_AGEND+"] diferente do informado no Pedido [M].", 'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM, ;
				'Cliente n�o pode ser Agendado c/ multa. Altere o Tipo de Entrega do Pedido para DIFERENTE de [M � AGENDADA C/ MULTA]',1)
			
			_lOk := .F.

			Break 
		ENDIF

		PRIVATE _cJustAG := " " As Character // preenchido na fun��o MT410_JA()
		PRIVATE _cJustDE := " " As Character // preenchido na fun��o MT410_JA()
		PRIVATE _cObseAG := " " As Character // preenchido na fun��o MT410_JA()
		PRIVATE _cObseDE := " " As Character // preenchido na fun��o MT410_JA()
		PRIVATE _lGrvMon := .F. As Logical // preenchido no retorno da fun��o MT410_JA() //GRAVA O MONITOR DEPOIS DE TODAS AS VALIDA��ES 
		PRIVATE _lAltData := M->C5_I_DTENT <> _ddtant .AND. M->C5_I_AGEND <> "I" As Logical //n�o � necess�rio justificar a altera��o da data de entrega do pedido quando o pedido for Tp Entrega imediato (M->C5_I_AGEND = I)
		PRIVATE _lAltAgen := M->C5_I_AGEND <> _cAgAnt As Logical
		PRIVATE _lContOk := ((SC5->C5_I_AGEND = "P" .AND. _cAgAnt = "A") .OR. (SC5->C5_I_AGEND = "R" .AND. _cAgAnt = "A") .OR. (SC5->C5_I_AGEND = "P" .AND. _cAgAnt = "M") .OR. (SC5->C5_I_AGEND = "N" .AND. _cAgAnt = "A")) As Logical

        _lPrecisaPedir:=!(ALLTRIM(M->C5_I_OPER) $ AllTrim(U_ITGETMV( 'IT_MPVOP' , '50/51/02')))
        IF _lPrecisaPedir .AND. (_lAltData .OR. _lAltAgen)//Se � altera��o valida com tela, v� se alterou a data de entrega ou o tipo de agendamento e pergunta o codigo e a obeserva�ao da justificativa,  TEM TELA 
//		If M->C5_I_DTENT != _ddtant .AND. !(alltrim(M->C5_I_OPER) $ AllTrim(U_ITGETMV( 'IT_MPVOP' , '50/51/02')))

			//Se n�o for usu�rio autorizado faz valida��o de data de entrega
			If ! U_ITVACESS( 'ZZL' , 3 , 'ZZL_MNTDTE' , 'N' )
                
				_cFilCarreg := xFilial("SC5")
				If ! Empty(M->C5_I_FLFNC)
				   _cFilCarreg := M->C5_I_FLFNC
				EndIf 
                       //OMSVLDENT(_ddent       ,_cclient     ,_cloja        ,_cfilft       ,_cpedido  ,_nret,_lshow,_cFilCarreg,_cOperPedV  ,_cTipoVenda)
				If !(  u_omsvldent(M->C5_I_DTENT, M->C5_CLIENT, M->C5_LOJACLI, M->C5_I_FILFT, M->C5_NUM,0    ,      ,_cFilCarreg,M->C5_I_OPER,M->C5_I_TPVEN) ) //Valida data de entrega

					Break

				Endif

			EndIf

            IF _lAltData .OR. _lAltAgen//Se � altera��o valida com tela, v� se alterou a data de entrega ou o tipo de agendamento e pergunta o codigo e a obeserva�ao da justificativa,  TEM TELA 
               _lGrvMon:=MT410_JA()//PARA GRAVA NO ZY3 NA FUN��O GrvMonitor() (XFUNOMS.PRW)
            ENDIF
			//nopccnf := 0
			//DEFINE MSDIALOG oDlg TITLE "Entre com motivo da altera��o de data de entrega:";
			//	FROM 000,000 TO 140,600 OF oDlg PIXEL
			//@ 004,004 TO 026,296 LABEL "Motivo: (Obrigat�rio)" OF oDlg PIXEL
			//@ 011,008 MSGET cObsAva PICTURE "@x"	SIZE 220,010 PIXEL OF oDlg
			//@ 040,230 BUTTON "&Ok"					SIZE 030,014 PIXEL ACTION ( IIf( Empty(cObsAva) , MsgInfo("Obrigat�rio informar o motivo.","Aten��o") , ( nOpcCnf:=1 , oDlg:End() ) ) )
			//@ 040,261 BUTTON "&Cancelar"			SIZE 030,014 PIXEL ACTION ( nOpcCnf:=0 , oDlg:End() )
			//ACTIVATE MSDIALOG oDlg CENTER

			If !_lGrvMon//nOpc == 0
				Break
				_lOk := .F.
			EndIf
		EndIf

		//=================================================================================
		// Inicia a grava��o de Log, Tabelas SC5 e SC6.
		//=================================================================================
		_aLogSC5 := U_ITIniLog( 'SC5' )
		INILOG6(4 , _oproc, .F., .T.)

		//=========================
		// Gravacao do cabecalho.
		//==========================
		RestArea(aAreaSC5)
		RecLock("SC5",.F.)
		For nX := 1 To FCount() //Conta as colunas da tabela no banco, nao considera os campos virtuais
			aadd(_antsc5,SC5->&(FieldName(nX)))
			If ASCAN(aCpos1,FieldName(nX)) > 0 .OR. fieldname(nx) == "C5_FECENT" //Verifica se o campo existe no array aCpos1 ou se � o fecent
				FieldPut(nX,M->&(FieldName(nX)))
			EndIf
		Next nX
		MsUnlock()

		//=================================================
		//Valida Desconto FOB
		//=================================================
//================================================================================
// Verifica se Desconto � mais que 10% do Total
//================================================================================

		SC6->( DBSetOrder(1) )
		If 	SC6->( Dbseek( SC5->C5_FILIAL + SC5->C5_NUM ) )

			DO While SC6->(!Eof()) .and. SC6->C6_FILIAL+SC6->C6_NUM == SC5->C5_FILIAL + SC5->C5_NUM

				_nValorPedido := (_nValorPedido + SC6->C6_VALOR)

				SC6->( DBSkip() )

			EndDo

		EndIf


		If M->C5_DESCONT >= _nValorPedido

			U_MT_ITMSG("Valor de desconto n�o pode ser maior que o valor total do pedido!",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,"Revise valor do desconto",1)
			_lOk := .F.

		Endif

		//=================================================
		//Envia Interface de manuten��o de pedido de vendas
		//=================================================
		If SC5->C5_I_ENVRD == "S" .AND. GETMV("IT_ENVSIPV",,.T.)

			U_ENVSITPV(,.F.)   //Envia interface de altera��o de situa��o do pedido atual

			If ZGA->ZGA_SITUAC != "P"

				U_ITmsg("N�o foi poss�vel alterar pedido no RDC, Altera��es NAO seram salvas. Retorno  ["+ALLTRIM(ZGA->ZGA_RETORN)+"]","Falha de integra��o",,1)

				_lOk := .F.
			EndIF

		EndIf

		If _lOk 
			//==========================================================================================
			// Verifica e grava valor de seguro calculado sobre valor do pedido de vendas com impostos. 
			//==========================================================================================
			_lHabTpFFb := Posicione('SA1',1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),'A1_I_FOB')  
			
			If ValType(_lHabTpFFb) == "L" .And. _lHabTpFFb .And. SC5->C5_TPFRETE $ "F/D" .And. ! (SC5->C5_I_OPER $ _cOperFret) .And. Dtos(SC5->C5_EMISSAO) >= Dtos(_dDtCalcFr)
			   MV_PAR04 := 2
               INCLUI := .F.
               ALTERA := .F.
			   _nValTotImp := Ma410Impos( 6, .T., {}) // Total do Pedido de Vendas com impostos.
			   _nValSeguro := _nValTotImp * _nPerSegFob / 100
				
				SC5->( Reclock( "SC5", .F. ) )
				SC5->C5_SEGURO := Round(_nValSeguro,2)
				SC5->( MsUnlock() )
			Else  
				SC5->( Reclock( "SC5", .F. ) )
				SC5->C5_SEGURO := 0 
				SC5->( MsUnlock() )
			EndIF 
		ENDIF

		If !_lOk
			//=========================
			// Estorno do cabecalho.
			//==========================
			RestArea(aAreaSC5)
			RecLock("SC5",.F.)
			For nX := 1 To FCount() //Conta as colunas da tabela no banco, nao considera os campos virtuais
				If ASCAN(aCpos1,FieldName(nX)) > 0 //Verifica se o campo existe no array aCpos1
					FieldPut(nX,_antsc5[nX])
				EndIf
			Next nX
			MsUnlock()

			Break // Return .F.

		EndIf

		//========================================
		// Grava��o da data de entrega se alterou e se deu certo o envio do RDC
		//========================================
		If M->C5_I_DTENT != _ddtant
			M->C5_FECENT := M->C5_I_DTENT
			SC6->( DbSetOrder(1) )
			SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
			DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM
				SC6->(RecLock("SC6",.F.))
				SC6->C6_ENTREG:=M->C5_I_DTENT
				SC6->(MsUnLock())
				SC6->( DBSkip() )
			ENDDO
		ENDIF

/*
		IF SC5->(FIELDPOS("C5_I_OPTRI")) # 0  .AND. SC5->C5_I_OPTRI = "R" // Estou de PV de Remessa e vou alterar o de Venda
			_cPedAltera:=SC5->C5_I_PVFAT
			SC5->( DbSetOrder(1) )
			IF SC5->(DBSEEK(xFilial()+_cPedAltera))//Quando chega nesse ponto o pedido de Origem j� foi gravado
				SC5->(RecLock("SC5",.F.))
				For nX := 1 To SC5->(FCount()) //Conta as colunas da tabela no banco, nao considera os campos virtuais
					If ASCAN(aCpos1,SC5->(FieldName(nX))) > 0 .OR. fieldname(nx) == "C5_FECENT" //Verifica se o campo existe no array aCpos1 ou se � o fecent
						SC5->(FieldPut(nX,M->&(FieldName(nX))))
					EndIf
				Next
				SC5->(MsUnlock())
			ENDIF
			SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
			DO While SC6->( !EOF() ) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->C5_FILIAL + SC5->C5_NUM
				SC6->(RecLock("SC6",.F.))
				SC6->C6_ENTREG:=M->C5_I_DTENT
				SC6->(MsUnLock())
				SC6->( DBSkip() )
			ENDDO
			SC5->( DBGOTO( _nRecOrigem ))//volta Recno do Pedido do pedido atual
		ENDIF*/

		//========================================
		//Grava��o do monitor de pedido de vendas
		//========================================
	/*	If M->C5_I_DTENT != _ddtant .AND. !(alltrim(M->C5_I_OPER) $ AllTrim(U_ITGETMV( 'IT_MPVOP' , '50/51/02')))
		   //_cJUSCOD := "007"//Alterado Data de Entrega
           _cCOMENT := "Data de entrega modificada de " + dtoc(_ddtant) + " para " + dtoc(SC5->C5_I_DTENT) + "  via altera��o de pedido de vendas."

			//U_GrvMonitor(,           ,_cJUSCOD,cObsava,""        ,_dDTNECE,M->C5_I_DTENT,_ddtant)
                       //_cFilial,_cNum,_cJUSCOD,_cCOMENT,_cLENCMON,_dDTNECE,_dDTFAT      ,_dDTFOLD , _cObserv, _cVinculoTb, _dDtSugAgen
	        U_GrvMonitor(        ,     ,_cJustDE,_cCOMENT,""       ,_dDTNECE,M->C5_I_DTENT,_ddtant,_cObseDE)     
		Endif*/
        IF _lGrvMon//GRAVA O MONITOR AQUI POR J� PASSOU POR TODAS AS VALIDA��ES 
           //_cJustAG / _cJustDE / _cObseAG / _cObseDE  preenchidoS na fun��o MT410_JA()
 		   SC5->( Reclock( "SC5", .F. ) )
		   If _lContOk
		   		SC5->C5_I_QTDA := SC5->C5_I_QTDA+1//SOMA PARA CADA ALTERACAO EFETIVADA
		   EndIf
		   SC5->( MsUnlock() )

           _cFilCarreg := xFilial("SC5")
           If ! Empty(M->C5_I_FLFNC)
              _cFilCarreg := M->C5_I_FLFNC
           EndIf 
		   _dDTNECE := M->C5_I_DTENT - (U_OMSVLDENT(M->C5_I_DTENT,M->C5_CLIENTE,M->C5_LOJACLI,M->C5_I_FILFT,M->C5_NUM,1, ,_cFilCarreg,M->C5_I_OPER,M->C5_I_TPVEN))

           IF _lAltData
              _cCOMENT := "Data de entrega modificada de " + dtoc(_ddtant) + " para " + dtoc(M->C5_I_DTENT) + " via altera��o de pedido de vendas."
                         //_cFilial,_cNum,_cJUSCOD,_cCOMENT,_cLENCMON,_dDTNECE,_dDTFAT      ,_dDTFOLD, _cObserv, _cVinculoTb, _dDtSugAgen        
	          U_GrvMonitor(        ,     ,_cJustDE,_cCOMENT,""       ,_dDTNECE,M->C5_I_DTENT,_ddtant ,_cObseDE)     
           ENDIF
           IF _lAltAgen
              _cCOMENT := "Tipo de Agendamento modificada de " + _cAgAnt + " para " + M->C5_I_AGEND + " via altera��o de pedido de vendas."
                         //_cFilial,_cNum,_cJUSCOD,_cCOMENT,_cLENCMON,_dDTNECE,_dDTFAT      ,_dDTFOLD, _cObserv, _cVinculoTb, _dDtSugAgen
              U_GrvMonitor(        ,     ,_cJustAG,_cCOMENT,""       ,_dDTNECE,M->C5_I_DTENT,_ddtant ,_cObseAG)     
           ENDIF
        ENDIF


		//======================================================================
		// Chama rotina de atualiza��o das tabelas de muro para integra��o
		// com o RDC e atualiza��o do pedido de vendas.
		//======================================================================
		U_AOMS084P(, ,"MANUTENCAO")

		//======================================================================
		// Grava log de altera��es
		//======================================================================
		If Type('_aLogSC5') == 'A' .And. !Empty( _aLogSC5 )
			U_ITGrvLog( _aLogSC5 , "SC5" , 1 , SC5->( C5_FILIAL + C5_NUM ) , "A" , __CUSERID , Date() , Time() )
		EndIf

		If Type('_aLogSC6') == 'A' .And. !Empty( _aLogSC6 )
			U_ITGrvLog( _aLogSC6 , "SC6" , 1 , SC5->( C5_FILIAL + C5_NUM ) , "A" , __CUSERID , Date() , Time() )
		EndIf

End Sequence

//=======================================
// Restaura a area do cabecalho e item. 
//========================================
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)

	If _lOk
		U_ITmsg("DADOS GRAVADOS COM SUCESSO - " + 'PEDIDO: '+SC5->C5_NUM, "Conclu�do", ,2)
	Else
		U_ITmsg("DADOS ALTERADOS N�O FORAM GRAVADOS - " + 'PEDIDO: '+SC5->C5_NUM, "Conclu�do", ,2)
	EndIf

Return .T.


/*
===============================================================================================================================
Programa----------: AOMS026V
Autor-------------: Wodson Reis Silva
Data da Criacao---: 16/07/2009
===============================================================================================================================
Descri��o---------: Realiza valida��o do pedido
===============================================================================================================================
Parametros--------: oproc - obejto da barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS026V(oproc)

	Local _lret := .T.
	Default oproc := nil

	Procregua(3)

//============================================================================
// Verifica se o Pedido ja foi faturado.                                     
//=============================================================================

	IF valtype(oproc) = "O"

		oproc:cCaption := ("Verificando se pedido j� foi faturado...")
		ProcessMessages()

	ENDIF

//Verifica permiss�o de ajuste de bloqueio log�stico
	If SC5->C5_I_BLOG == "S"

		ZZL->(Dbsetorder(3))
		If !(ZZL->(Dbseek(xFilial("ZZL") + RetCodUsr()))) .OR. ZZL->ZZL_PVLOG != "S"

			u_itmsg("Usu�rio sem permiss�o para efetuar Manuten��o, Pedido em Planejamento Log�stico. Por favor entrar em contato com a �rea de Log�stica.","Aten��o",,1)
			Return .F.

		Endif

	Endif

	If SC5->(FIELDPOS("C5_I_OPTRI")) # 0  .AND. SC5->C5_I_OPER = _cOperFat

		U_ITmsg("Manuten��o n�o permitida, Pedido de  Faturamento da Opera��o Triangular.",'Aten��o! Ped.: '+SC5->C5_NUM,;
			"Acesse o Pedido de Remessa "+SC5->C5_I_PVREM+" para efetuar a manuten��o",1)
		RETURN .F.

	ENDIF

	If !Empty(SC5->C5_NOTA).Or.SC5->C5_LIBEROK=='E'

		U_ITmsg("Manuten��o n�o permitida, Pedido j� faturado.",'Aten��o! Ped.: '+SC5->C5_NUM,,1)
		RETURN .F.
		//===================================================================================================
		//Arrays de controle dos campos que deverao ser alterados no cabecalho qdo Pedido ja Faturado.
		//====================================================================================================
		aCpos1 := ALLTRIM(GetMv("IT_CMPCAB1"))
		aCpos1 := If(Empty(aCpos1),{},&aCpos1)

		//================================================================================================
		//Arrays de controle dos campos que deverao ser alterados nos itens qdo Pedido ja Faturado.
		//=================================================================================================
		aCpos2 := ALLTRIM(GetMv("IT_CMPITE1"))
		aCpos2 := If(Empty(aCpos2),{},&aCpos2)
	Else
		//===================================================================================================
		//Arrays de controle dos campos que deverao ser alterados no cabecalho qdo Pedido Nao Faturado.
		//====================================================================================================
		aCpos1 := ALLTRIM(GetMv("IT_CMPCAB2"))
		aCpos1 := If(Empty(aCpos1),{},&aCpos1)

		//================================================================================================
		//Arrays de controle dos campos que deverao ser alterados nos itens qdo Pedido Nao Faturado.
		//=================================================================================================
		aCpos2 := ALLTRIM(GetMv("IT_CMPITE2"))
		aCpos2 := If(Empty(aCpos2),{},&aCpos2)
	EndIf

//============================================================================
//Verifica se pedido pode sofrer manuten��o pelo RDC
//============================================================================
	IF valtype(oproc) = "O"

		oproc:cCaption := ("Verificando se pode sofrer manuten��o no RDC")
		ProcessMessages()

	ENDIF

	If SC5->C5_I_ENVRD == "S" .AND. GETMV("IT_ENVSIPV",,.T.)

		U_ENVSITPV(,.F.)   //Envia interface de altera��o de situa��o do pedido atual

		If ZGA->ZGA_SITUAC != "P"

			U_ITmsg("Manuten��o n�o permitida, Pedido j� incluso em carga no RDC.",'Aten��o! Ped.: '+SC5->C5_NUM,,1)

			Return .F.

		Endif

	Endif

Return _lret

/*
===============================================================================================================================
Programa--------: INILOG6
Autor-----------: Julio de Paula Paz
Data da Criacao-: 22/10/2018
===============================================================================================================================
Descri��o-------: Grava situa��o inicial do SC6 para log e altera��es
===============================================================================================================================
Parametros------: _nopc - tipo de opera��o
				  oproc - objeto da barra de processamento
				  _lshow - se exibe objetos gr�ficos de interface
				  _lret - status da valida��o geral
===============================================================================================================================
Retorno---------: _lret - valida��o da condi��o
===============================================================================================================================
*/
Static Function INILOG6(_nopc,oproc,_lshow,_lret)

	Local _aCampos	:= {'C6_ITEM','C6_PRODUTO','C6_PRCVEN','C6_TES','C6_QTDVEN','C6_LOCAL','C6_PEDCLI'}
	Local _lRetorno := .F.
	Local _nI
	Local _nTotCampos
	Local _cCampo, _cCpoAux

	Begin Sequence
		//Se valida��o n�o est� mais v�lida j� retorna false
		If !_lret
			_lRetorno := .F.
			Break
		EndIf

		SC6->( DBSetOrder(1) )

		_nTotCampos := SC6->(FCount())

		If SC6->( DBSeek( SC5->( C5_FILIAL + C5_NUM ) ) )
			Do While SC6->(!Eof()) .And. SC6->( C6_FILIAL + C6_NUM ) == SC5->( C5_FILIAL + C5_NUM )
				For _nI := 1 To _nTotCampos
					_cCampo := AllTrim(SC6->(FieldName(_nI)))
					If !Empty(_aCampos) .And. aScan( _aCampos , _cCampo) == 0
						Loop
					Else
						_cCpoAux := "SC6->"+ _cCampo
						aAdd( _aLogSC6 , { SC6->( C6_FILIAL + C6_NUM + SC6->C6_ITEM ) , _cCampo , &_cCpoAux } )
					EndIf
				Next

				SC6->( DBSkip() )
			EndDo

		EndIf

	End Sequence

Return _lret


/*=============================================================================================================================
Programa----------: MT410_JA()
Autor-------------: Alex Wallauer
Data da Criacao---: 25/10/2023
===============================================================================================================================
Descri��o---------: Ao alterar os campos C5_I_AGEND ou C5_I_DTENT, obrigar preenchimento do campo justificativa (ZY3_JUSCOD) 
                    especifica para esses campos e observa��o (ZY3_OBSERV) da justificativa com texto minimo de 10 caracteres
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Se .T. continua a as outras valida��es, se .F. nao volta pra tela de pedido sem fazer nada.
===============================================================================================================================*/
STATIC Function MT410_JA()
Local _lret    := .F.
Local nLinha   := 10
Local _nCol1   := 05
Local _nCol2   := 40
Local _nCol3   := 90
Local _nTam    := 300

_cJustAG := Space(3)  // _aJustAG[1]
_cJustDE := Space(3)  // _aJustDE[1]
_cObseAG := SPACE(LEN(ZY3->ZY3_OBSERV))
_cObseDE := SPACE(LEN(ZY3->ZY3_OBSERV))

_cTitJus:="Justificativas das altera��es"
_aFoders:={}
If _lAltAgen
   AADD(_aFoders,"Tipo de Agendamento")
   _cTitJus+="de Data de Entrega"
EndIf
IF _lAltData
   AADD(_aFoders,"Data de Entrega")
   If _lAltAgen
      _cTitJus+=" e "
   ENDIF
   _cTitJus+="do Tipo de Agendamento"
EndIf

DO WHILE .T.

   DEFINE MSDIALOG _oDlg2 TITLE _cTitJus From 0,0 To 280, 700 PIXEL
                                                                       
	_nColFolder:=350
    _nLinFolder:=100
	nLinha:=1

    oTFolder1:= TFolder():New( nLinha,1,_aFoders,,_oDlg2,,,,.T., , _nColFolder,_nLinFolder )

    If _lAltAgen
        nLinha:=5
        @ nLinha,_nCol1 Say "Tipo de Agendamento de: "+U_TipoEntrega(SC5->C5_I_AGEND) OF oTFolder1:aDialogs[1] PIXEL

        nLinha+=15
        @ nLinha,_nCol1 Say "Tipo de Agendamento para: "+U_TipoEntrega(M->C5_I_AGEND) OF oTFolder1:aDialogs[1] PIXEL

        nLinha+=15
        @ nLinha+4,_nCol1 Say "Justificativas:"       OF oTFolder1:aDialogs[1] PIXEL
        @ nLinha,_nCol2 MSGET _cJustAG F3 "ZY5"   SIZE 30,010  Valid(MT410VLJUS(_cJustAG , "C5_I_AGEND")) PIXEL OF oTFolder1:aDialogs[1] WHEN _lAltAgen //MULTILINE
                
        nLinha+=20
        @ nLinha+2,_nCol1 SAY  "Observa��o:" SIZE 060  ,007  PIXEL OF oTFolder1:aDialogs[1]
        @ nLinha,_nCol2 MSGet _cObseAG       SIZE _nTam,010  PIXEL OF oTFolder1:aDialogs[1] WHEN .F. 
    ENDIF

///***********************  FOLDER 2 *************************************************
    If _lAltData
        nLinha:=5
        @ nLinha,_nCol1 Say "Data de Entrega de: "+DTOC(SC5->C5_I_DTENT) OF oTFolder1:aDialogs[LEN(_aFoders)] PIXEL

          nLinha+=15
        @ nLinha,_nCol1 Say "Data de Entrega para: "+DTOC(M->C5_I_DTENT) OF oTFolder1:aDialogs[LEN(_aFoders)] PIXEL

        nLinha+=15
        @ nLinha+4,_nCol1 Say "Justificativas:"           OF oTFolder1:aDialogs[LEN(_aFoders)] PIXEL
        @ nLinha,_nCol2 MSGet _cJustDE  F3 "ZY5"  Valid(MT410VLJUS(_cJustDE , "C5_I_DTENT")) SIZE 030,010 PIXEL OF oTFolder1:aDialogs[LEN(_aFoders)] WHEN _lAltData //MULTILINE

        nLinha+=20
        @ nLinha+2,_nCol1 SAY  "Observa��o:" SIZE 060  ,007 PIXEL OF oTFolder1:aDialogs[LEN(_aFoders)]
        @ nLinha,_nCol2 Get _cObseDE       SIZE _nTam,010 PIXEL OF oTFolder1:aDialogs[LEN(_aFoders)] WHEN .F.
    ENDIF
    nLinha+=60
    @ nLinha,_nCol3    Button "CONTINUAR" SIZE 50,15 ACTION ( _lret := .T. ,_oDlg2:End()) PIXEL
       @ nLinha,_nCol3+99 Button "VOLTAR"    SIZE 50,15 ACTION ( _lret := .F. ,_oDlg2:End()) PIXEL

   ACTIVATE MSDIALOG _oDlg2 

   If ! _lRet
   	  U_MT_ITMSG("N�o foi selecionada/Digitada a Justificativa/Observa��o, altera��o do Pedido N�O ser� efetuada.","Aten��o",,1)
   EndIf

   EXIT
ENDDO		

Return _lret
/*
===============================================================================================================================
Programa----------: MT410VLJUS
Autor-------------: Julio de Paula Paz
Data da Criacao---: 13/05/2025
===============================================================================================================================
Descri��o---------: Valida a digita��o da justificativa de altera��o de tipo de agendamenteo e altera��o de data de entrega.
===============================================================================================================================
Parametros--------: _cDado  = Informa��o a ser validada
                    _cCampo = Campo que chamou a valida��o.
===============================================================================================================================
Retorno-----------: _lRet := .T. = Dados corretos
                             .F. = Erro nos dados
===============================================================================================================================
*/
Static Function MT410VLJUS(_cDado, _cCampo)
Local _lRet := .T.

Begin Sequence 
   
   If (_lAltData .And. Empty(_cDado)) .Or. (_lAltAgen .And. Empty(_cDado))
      U_MT_ITMSG("O c�digo de justificativa n�o foi informado.","Aten��o",,1)
      _lRet := .F.
      Break 
   EndIf 

   ZY5->(DbSetOrder(1))
   If ! ZY5->(MsSeek(xFilial("ZY5")+_cDado))
      U_MT_ITMSG("O c�digo de justificativa informado n�o existe.","Aten��o",,1)
      _lRet := .F.
   Else 
      If _cCampo == "C5_I_AGEND"
         _cObseAG := ZY5->ZY5_DESCR
      Else 
         _cObseDE := ZY5->ZY5_DESCR
      EndIf 
   EndIf 

End Sequence 

Return _lRet 
