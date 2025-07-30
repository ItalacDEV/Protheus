/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo
-------------------------------------------------------------------------------------------------------------------------------
Jerry		  | 13/03/2018 | Ajustar o novo campo de Status do Pedido de Vendas (C5_I_STATU) quando Excluir Nota - Chamado 24091
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 02/07/2018 | Substituida exclusão dos complementos pela função ECompFis. Chamado 25362
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 31/07/2024 | Chamado 48058. Incluída função para excluir movimento interno referente ao desconto Tetra Pak.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa--------: SF2520E
Autor-----------: Tiago Correa Castro
Data da Criacao-: 08/02/2009
===============================================================================================================================
Descrição-------: Ponto de Entrada após a exclusão da Nota Fiscal de Saida.
===============================================================================================================================
Parametros------: cTabAux := Código da Tabela no SX5
----------------: nTamAux := Tamanho da Chave para o Retorno
===============================================================================================================================
Retorno---------: .T. - Compatibilidade com a utilização em F3
===============================================================================================================================
*/
User Function SF2520E()

Local _aArea		:= GetArea()
Local aVetor		:= {}
Local _cPedido		:=  SF2->F2_I_PEDID

Private lMsErroAuto	:= .F.

//================================================================================
//| Salvando Integridade do Sistema.                                             |
//================================================================================
dbSelectArea("SF2")
_nOrdSF2 := IndexOrd()
_nRecSF2 := Recno()

dbSelectArea("SC9")
_nOrdSC9 := IndexOrd()
_nRecSC9 := Recno()

dbSelectArea("DAI")
_nOrdDAI := IndexOrd()
_nRecDAI := Recno()

dbSelectArea("SD2")
_nOrdSD2 := IndexOrd()
_nRecSD2 := Recno()

dbSelectArea("SC5")
_nOrdSC5 := IndexOrd()
_nRecSC5 := Recno()

dbSelectArea("SC6")
_nOrdSC6 := IndexOrd()
_nRecSC6 := Recno()

//================================================================================
// Grava filial e matricula do usuario q esta fazendo a exclusao
// na tabela SF2 campo F2_I_UEXCL(Caracter 8)
//================================================================================
RecLock("SF2",.F.)
F2_I_UEXCL := U_UCFG001(1)
SF2->(MsUnlock())
SF2->(dbCommit())

//Exclui os complementos de notas fiscais de entrada e de saida com as informacoes necessarias ao Sped.
Processa( {|| U_ECompFis("S",SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA) }, "Aguarde...", "Excluindo Complementos Fiscais...",.F.)

//================================================================================
//| Exluindo titulo no financeiro ref. ao valor do frete                         |
//================================================================================
DbSelectArea("ZZ2")
ZZ2->(DbSetORder(2)) // ZZ2_FILIAL+ZZ2_CARGA
IF ZZ2->(DbSeek(xFilial("ZZ2")+SF2->F2_CARGA))
			
	DbSelectArea("SE2")
	SE2->( DBOrderNickName("IT_RPA")) //E2_FILIAL+E2_PREFIXO+E2_TIPO+E2_NUM+E2_PARCELA+E2_FORNECE+E2_LOJA                                                                                               
	SE2->( DBSeek( xFilial("SE2") + "AUT" + "RPA" + ZZ2->ZZ2_RECIBO ) )
	
	While SE2->(!EOF()) .and. SE2->E2_FILIAL == xFilial("SE2") .and. SE2->E2_PREFIXO == "AUT" .and. SE2->E2_NUM == ZZ2->ZZ2_RECIBO

		If SE2->E2_TIPO == "RPA" .and. SE2->E2_SALDO == SE2->E2_VALOR
			   
			lMsErroAuto := .F. 
			
			DbSelectArea("SA2")
			SA2->(DbSetOrder(1))
			SA2->(DbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
			
			DbSelectArea("SE2")
			SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			
			aVetor :={	{"E2_PREFIXO"	,SE2->E2_PREFIXO			,Nil},;
						{"E2_NUM"		,SE2->E2_NUM				,Nil},;
						{"E2_PARCELA"	,SE2->E2_PARCELA			,Nil},;
						{"E2_TIPO"		,SE2->E2_TIPO				,Nil},;
						{"E2_NATUREZ"	,SE2->E2_NATUREZ			,Nil},;
						{"E2_ORIGEM"    ,"GERAZZ3"      			,Nil} }
						
			MSExecAuto({|x,y,z| Fina050(x,y,z)},aVetor,,5) //Exclusao
			
			If lMsErroAuto
				Mostraerro()
			Endif
			
		Endif
		
		DbSelectArea("SE2")
		SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		SE2->(DbSkip())
		
	EndDo
	
	// Apaga os dados do arquivo ZZ3 quando a exclusao da NF por nota/carga(Deletando item da N.F.)
	DbSelectArea("ZZ3")
	ZZ3->(DbSetOrder(1)) //ZZ3_FILIAL+ZZ3_RECIBO+ZZ3_CARGA+ZZ3_DOC+ZZ3_SERIE
	ZZ3->(DbSeek(xFilial("ZZ3")+ZZ2->ZZ2_RECIBO+SF2->F2_CARGA))
	While ZZ3->(!EOF()) .and. ZZ3->ZZ3_FILIAL == xFilial("ZZ3") .And. ZZ3->ZZ3_RECIBO == ZZ2->ZZ2_RECIBO .And. ZZ3->ZZ3_CARGA == ZZ2->ZZ2_CARGA
		RecLock("ZZ3",.F.)
		Delete
		MsUnlock()
		ZZ3->(DbSkip())
	EndDo
	
	//Deleta ZZ2 caso a exclusao seja por carga(Cabecalho do recibo)
	If Upper(AllTrim(FunName())) == "MATA521B"
		If MV_PAR04 == 1 //Os Pedidos voltam a ficar em carteira desfazendo assim a Montagem da Carga
			DbSelectArea("ZZ2")
			RecLock("ZZ2",.f.)
			Delete
			MsUnLock()
		Endif
	Endif
Endif

//================================================================================
//| Verifica a exclusão de impostos calculados no RPA Avulso/Faturamento de Carga|
//================================================================================
U_ExcIMP()			// 31/07/2014 - Alexandre - Chamada da função que retira os impostos da ZZ2

//================================================================================
//| Verifica a exclusão de Títulos de NCC                                        |
//================================================================================
U_ExcNcc()	// 07/02/2013 - Talita - Chamada da função responsavel por excluir os titulos de NCC

//Atualizar Status do Pedido 

lCart := MV_PAR04==1
	
DbselectArea("SC5")
SC5->(DbsetOrder(1))//C5_FILIAL+C5_NUM
If SC5->(dbSeek(xFilial("SC5") + _cPedido ))
          
	SC5->(RecLock("SC5",.F.))
	If SC5->C5_I_TRCNF = "N"
		SC5->C5_I_STATU = IIF(lCart,"01","03")
	Else 
		If SC5->C5_I_FLFNC <> SC5->C5_FILIAL //PEDIDO FATURAMENTO
			SC5->C5_I_STATU = IIF(lCart,"14","15")			
		Else                  
			SC5->C5_I_STATU = "12"	//PEDIDO CARREGAMENTO
			SC5->C5_I_STATU = IIF(lCart,"12","13")						
		EndIf    
	EndIf
	SC5->( MsUnlock() )
 
EndIf    

If SF2->F2_CLIENTE == 'F00004' .And. SF2->F2_TIPO == "D"
	DescTetraS()
EndIf

//================================
//Restaura Integridade do Sistema.
//================================
dbSelectArea("SD2")
dbSetOrder(_nOrdSD2)
dbGoto(_nRecSD2)

dbSelectArea("SF2")
dbSetOrder(_nOrdSF2)
dbGoto(_nRecSF2)

dbSelectArea("SC9")
dbSetOrder(_nOrdSC9)
dbGoto(_nRecSC9)

dbSelectArea("DAI")
dbSetOrder(_nOrdDAI)
dbGoto(_nRecDAI)      

dbSelectArea("SC5")
dbSetOrder(_nOrdSC5)
dbGoto(_nRecSC5)

dbSelectArea("SC6")
dbSetOrder(_nOrdSC6)
dbGoto(_nRecSC6)

RestArea(_aArea)

Return()

/*
===============================================================================================================================
Programa--------: ExcIMP
Autor-----------: Alexandre Villar
Data da Criacao-: 15/12/2008
===============================================================================================================================
Descrição-------: Rotina que processa a eliminação do cálculo de impostos da ZZ2 no momento da exclusão.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T. - Permite o estorno
------------------: .F. - Impede o estorno
===============================================================================================================================
*/
User Function ExcIMP()

DBSelectArea('ZZ2')
ZZ2->( DBSetOrder(2) )
If ZZ2->( DBSeek( SF2->( F2_FILIAL + F2_CARGA ) ) )

	ZZ2->( RecLock( 'ZZ2' , .F. ) )
		ZZ2->ZZ2_SEST	:= 0
		ZZ2->ZZ2_INSS	:= 0
		ZZ2->ZZ2_IRRF	:= 0
	ZZ2->( MsUnLock() )

EndIf

Return

/*
===============================================================================================================================
Programa--------: ExcNCC
Autor-----------: Talita Teixeira
Data da Criacao-: 07/02/2013
===============================================================================================================================
Descrição-------: Consulta para verificar se a nota possui titulos de ncc se sim excluir os mesmos.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function ExcNcc()   

Local cNumero	:= SF2->F2_DOC
Local aExcNCC 	:= {}  

Private lMsErroAuto := .F.

	DbSelectArea ("SE1")
    SE1->(DbSetOrder(1))
    SE1->(DbSeek(xFilial("SE1")+"DCT"+cNumero))

    While SE1->(!Eof()) .And. SE1->E1_NUM = cNumero

    	If SE1->E1_TIPO = "NCC"

    	aExcNCC := {	{ "E1_FILIAL"	, SE1->E1_FILIAL	, NIL },;
    					{ "E1_PREFIXO"	, "DCT" 			, NIL },;
     					{ "E1_NUM"		, cNumero			, NIL } }
 
		MsExecAuto( {|x,y| FINA040(x,y) } , aExcNCC , 5 )  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

			If lMsErroAuto
   				 MostraErro()
			Endif

        EndIf

	SE1->( DBSkip() )
	EndDo

Return

/*
===============================================================================================================================
Programa----------: DescTetraS
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 31/07/2024
===============================================================================================================================
Descrição---------: Gera movimento interno para retornar o valor do desconto TetraPak do produto
===============================================================================================================================
Parametros--------: nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function DescTetraS()
Local _aSD3 := GetArea("SD3")

Private lMsErroAuto := .F.

SD3->(Dbsetorder(16)) //D3_FILIAL + D3_CHAVEF2
If SD3->(Dbseek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
	While !SD3->(EOF()) .And. SD3->D3_FILIAL+Substr(SD3->D3_CHAVEF2,1,22) == SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
		If SD3->D3_ESTORNO # "S"
			MsExecAuto({|x,y,z| MatA241(x,y,z)},{},Nil,6)
			If lMsErroAuto
				FWAlertError("Erro ao gerar movimento interno referente ao desconto Tetra Pak. Favor acionar a TI.","SF2520E01")
				Mostraerro()
			EndIf
		EndIf
		SD3->(dbSkip())
	EndDo
EndIf
Restarea(_aSD3)

Return
