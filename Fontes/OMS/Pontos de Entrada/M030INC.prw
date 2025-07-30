/*
==================================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
==================================================================================================================================
 Autor       |    Data    |                              Motivo                      										 
----------------------------------------------------------------------------------------------------------------------------------
Josu� Danich | 06/12/2016 | Chamado 17585. Inclus�o de entidade cont�bil para novos fornecdores.
-------------------------------------------------------------------------- - -----------------------------------------------------
Darcio Sporl | 20/01/2017 | Chamado 17503. Foi inclu�do o tratamento para salvar o endere�o ao executar o mashup. 
----------------------------------------------------------------------------------------------------------------------------------
Lucas Borges | 03/04/2018 | Chamado 24395. Inclu�da na regra da Conta Cont�bil o tipo L-Produtor Rural pois est� sendo usado. 
----------------------------------------------------------------------------------------------------------------------------------
Julio Paz    | 12/09/2019 | Chamado 25540. Incluir valida��es espec�fica para altera��o cliente 1/cliente 2 do cad.clientes.
----------------------------------------------------------------------------------------------------------------------------------
Igor Melga�o | 03/04/2018 | Chamado 37363. Rollback para a revis�o 1930 de 04/04/18 que � o que esta em produ��o atualmente.  
----------------------------------------------------------------------------------------------------------------------------------
Julio Paz    | 29/12/2021 | Chamado 30177. Inclus�o de rotina para bloqueio e Workflow de clientes com desconto contratual. 
---------------------------------------------------------------------------------------------------------------------------------- 
Julio Paz    | 09/08/2022 | Chamado 40841. limpar conte�do campos Suframa,quando cliente n�o fizer parte dos estados Suframa. 
----------------------------------------------------------------------------------------------------------------------------------
Julio Paz    | 09/08/2022 | Chamado 40931. Na incl/alt de funcion�rios, Gravar cad.Clientes:Segmento=39 e Tipo=Consumidor Final.
----------------------------------------------------------------------------------------------------------------------------------
Igor Melga�o | 11/08/2022 | Chamado 40048. Ajuste para substitui��o de caracteres inv�lidos. 
----------------------------------------------------------------------------------------------------------------------------------
Igor Melga�o | 26/10/2022 | Chamado 40771. Corre��o de error.log variavel _lRet. 
----------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 17/02/2023 | Chamado 42425. Novo Tratamento para gravacao do campo A1_CONTRIB na nova Funcao CRMA980CON().
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz    | 25/07/2023 | Chamado 44096. Ajustar rotina incl/alter gravar Grupo Tributa��o "023" p/Parana e Simples Nac
-------------------------------------------------------------------------------------------------------------------------------
Antonio Neves| 07/02/2024 | Chamado 46248. Adicionada as UFs AC - RO nos Estados do Suframa
==================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa--------: M030INC
Autor-----------: Alexandre Villar
Data da Criacao-: 02/12/2015
===============================================================================================================================
Descri��o-------: Ponto de entrada para gravar os dados do cadastro do Cliente ap�s a inclus�o.
===============================================================================================================================
Parametros------: PARAMIXB -> Num�rico -> Tipo da opera��o do usu�rio. Conte�do 3 significa que o usu�rio cancelou a inclus�o.
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function M030INC()

Local _aArea	:= GetArea()
Local _cConta	:= ''
Local _cEnd		:= ''

Local _lMashup	:= U_ItGetMV("IT_MASHUP",.F.)

Local _nQtdDia	:= 0
Local _nQtdiaT	:= 0
Local _lExec	:= .F.

Local _lLibMas	:= .F.
Local _aBloqSA1

Local _cA1_NOME    := ""
Local _cA1_END     := ""
Local _cA1_BAIRRO  := ""
Local _cA1_ENDCOB  := ""
Local _cA1_ENDREC  := ""
Local _cA1_ENDENT  := ""
Local _cA1_BAIRROE := ""
Local _lRet        := .T.

Local _cUfMVA := U_ITGetMV("IT_UFSMVA","PR")
Local _cTRIBMVA := U_ITGetMV("IT_TRIBMVA","023")

//====================================================================================================
// Verifica a configura��o do cadastro para ajustar a conta cont�bil
//====================================================================================================
Do Case
	
	Case SA1->A1_TIPO $ 'F/L' .And. SA1->A1_EST == 'AM' .And. SA1->A1_PESSOA == 'F'
		_cConta := '1102069992'
	
	Case SA1->A1_TIPO $ 'F/L' .And. SA1->A1_EST == 'RS' .And. SA1->A1_PESSOA == 'F'
		_cConta := '1102069993'
	
	Case SA1->A1_TIPO $ 'F/L' .And. SA1->A1_EST == 'MG' .And. SA1->A1_PESSOA == 'F' .And. SA1->A1_COD_MUN == '69307' //Tr�s Cora��es
		_cConta := '1102069995'
	
	Case SA1->A1_TIPO $ 'F/L' .And. SA1->A1_EST == 'SP' .And. SA1->A1_PESSOA == 'F'
		_cConta := '1102069996'
	
	Case SA1->A1_TIPO $ 'F/L' .And. SA1->A1_EST $ 'MG/GO' .And. SA1->A1_PESSOA == 'F'
		_cConta := '1102069998'
	
	Case SA1->A1_TIPO $ 'F/L' .And. SA1->A1_EST == 'RO' .And. SA1->A1_PESSOA == 'F'
		_cConta := '1102069999'
	
EndCase

If !Empty( _cConta ) .And. _cConta <> SA1->A1_CONTA
	
	RecLock( 'SA1' , .F. )
	SA1->A1_CONTA := _cConta
	SA1->( MsUnLock() )
	
EndIf     
                 
//===================================================================================
// Grava os dados dos clientes nas tabelas de muro para integra��o com o sistema RDC.
//===================================================================================
If Type("M->A1_COD") <> "U" // Indica que foi confirmado uma inclus�o.
   U_AOMS076G()
EndIf

//================================================================================
// Cria item cont�bil para o novo fornecedor
//================================================================================
CTD->(Dbsetorder(1))

If .not. CTD->(Dbseek(xfilial("CTD")+"SA1"+ ALLTRIM(SA1->A1_COD)))

  Reclock("CTD", .T.)

  CTD->CTD_ITEM := "SA1" + ALLTRIM(SA1->A1_COD)
  CTD->CTD_DESC01 := SA1->A1_NOME
  CTD->CTD_BLOQ :=  "2"
  CTD->CTD_DTEXIS := stod("19800101")
  CTD->CTD_ITLP := "SA2" + ALLTRIM(SA1->A1_COD)
  CTD->CTD_CLOBRG := "2"
  CTD->CTD_ACCLVL := "1"
  CTD->CTD_CLASSE := "2"

  Msunlock()
  
Endif

If _lMashup

	_cUser := RetCodUsr()
			
	DBSelectArea("ZZL")
	ZZL->( DBSetOrder(3) )
	If ZZL->( DBSeek( xFilial("ZZL") + _cUser ) )
		If ZZL->ZZL_LIBMAS == "S"
			_lLibMas := .T.
		EndIf
	EndIf
	
	If SA1->A1_PESSOA <> "F"
		_nQtdDia	:= Val(SA1->A1_I_PEREX)
		_nQtdiaT	:= Iif(Empty(M->A1_I_DTEXE),0,dDataBase - M->A1_I_DTEXE)
		_lExec		:= Iif(_nQtdiaT > _nQtdDia, .T., .F.)
		If !_lLibMas .Or. _lExec
			If IsInCallStack("MA030Trans")
				If !Empty(SA1->A1_I_END) .And. Empty(SA1->A1_I_NUM)
					_cEnd := AllTrim(SA1->A1_I_END)
				ElseIf !Empty(SA1->A1_I_END) .And. !Empty(SA1->A1_I_NUM)
					_cEnd := AllTrim(SA1->A1_I_END) + ", " + AllTrim(SA1->A1_I_NUM)
				EndIf
			
				RecLock("SA1", .F.)
				SA1->A1_END		:= _cEnd
				SA1->A1_I_DTEXE	:= Date()
				SA1->(MsUnLock())
			EndIf
		Else
			RecLock("SA1", .F.)
			SA1->A1_I_DTEXE := Date()
			SA1->(MsUnLock())
		EndIf
	EndIf
EndIf
/*
If Empty(SA1->A1_INSCR) .Or. AllTrim(SA1->A1_INSCR) == "ISENTO"
	RecLock("SA1", .F.)
	SA1->A1_CONTRIB := "2"
	SA1->(MsUnLock())
Else
	RecLock("SA1", .F.)
	SA1->A1_CONTRIB := "1"
	SA1->(MsUnLock())
EndIf*/

U_CRMA980CON()//Funcao do P.E. CRMA980PE.PRW

//=======================================================================
// Verifica se as valida��es da rotina de desconto contratual se 
// deve bloquear o Cliente. Caso afirmativo bloqueia o cliente por 
// Desconto Contratual.
//=======================================================================
_aBloqSA1 := U_MA30RETA()
If ValType(_aBloqSA1) == "A" .And. Len(_aBloqSA1) > 0 .And. ValType(_aBloqSA1[1]) == "L" .And. _aBloqSA1[1] // Bloqueia SA1 por Desconto Contratual = True or False
   SA1->(RECLOCK("SA1",.F.))
   SA1->A1_MSBLQL  := "1" // Bloqueio por Cliente
   SA1->A1_I_BLQDC := "1"
   SA1->(MsUnlock())
   
   //==================================================================
   // Envia Workflow de bloqueio de clientes por desconto contratual.
   //==================================================================
   U_M30PALWF()

EndIf 

//Substitui��o de caracteres de Campos
SA1->(RecLock("SA1", .F.))

_cA1_NOME := SA1->A1_NOME
If !Empty(Alltrim(M->A1_NOME))
	_lRet := U_CRMA980VCP(@_cA1_NOME   ,"A1_NOME")
	SA1->A1_NOME := _cA1_NOME
EndIf

_cA1_END := SA1->A1_END
If _lRet .And. !Empty(Alltrim(_cA1_END))
	_lRet := U_CRMA980VCP(@_cA1_END    ,"A1_END")
	SA1->A1_END := _cA1_END
EndIf

_cA1_BAIRRO := SA1->A1_BAIRRO
If _lRet .And. !Empty(Alltrim(_cA1_BAIRRO))
	_lRet := U_CRMA980VCP(@_cA1_BAIRRO ,"A1_BAIRRO")
	SA1->A1_BAIRRO := _cA1_BAIRRO
EndIf

_cA1_ENDCOB := M->A1_ENDCOB
If _lRet .And. !Empty(Alltrim(_cA1_ENDCOB))
	_lRet := U_CRMA980VCP(@_cA1_ENDCOB ,"A1_ENDCOB")
	SA1->A1_ENDCOB := _cA1_ENDCOB
EndIf

_cA1_ENDREC := M->A1_ENDREC
If _lRet .And. !Empty(Alltrim(_cA1_ENDREC))
	_lRet := U_CRMA980VCP(@_cA1_ENDREC ,"A1_ENDREC")
	SA1->A1_ENDREC := _cA1_ENDREC
EndIf

_cA1_ENDENT := M->A1_ENDENT
If _lRet .And. !Empty(Alltrim(_cA1_ENDENT))
	_lRet := U_CRMA980VCP(@_cA1_ENDENT,"A1_ENDENT")
	SA1->A1_ENDENT := _cA1_ENDENT
EndIf

_cA1_BAIRROE := M->A1_BAIRROE
If _lRet .And. !Empty(Alltrim(_cA1_BAIRROE))
	_lRet := U_CRMA980VCP(@_cA1_BAIRROE,"A1_BAIRROE")
	SA1->A1_BAIRROE := _cA1_BAIRROE
EndIf

SA1->(MsUnLock())
//=====================================================================
// Para os clientes que n�o s�o dos estados "AM-RR-AP" gravar os campos
// suframa com: A1_CALCSUF = "N" e A1_SUFRAMA = " ".
//=====================================================================
If ! (SA1->A1_EST $ "AM-RR-AP-AC-RO")
   SA1->(RECLOCK("SA1",.F.))
   SA1->A1_CALCSUF := "N"
   SA1->A1_SUFRAMA := " "
   SA1->(MsUnlock())
EndIf

//=====================================================================
// Para os clientes que s�o funcion�rios, gravar tipo e seguimento
// como consumidor final.
//=====================================================================
If SA1->A1_CLIFUN == "1"
   SA1->(RECLOCK("SA1",.F.))
   SA1->A1_TIPO    := "F"  //  Tipo = Consumidor Final
   SA1->A1_I_GRCLI := "39" //  Seguimento = Consumidor Final   
   SA1->(MsUnlock())   
EndIf 

//=====================================================================
// Para os clientes do Paran� optantes pelo Simples Nacional grava
// grava o campo Grupo Tribut�rio com "023", para obterem benef�cios.
//=====================================================================
If SA1->A1_EST $ _cUfMVA .And. SA1->A1_SIMPNAC == "1" // 1=Sim;2=N�o
   SA1->(RECLOCK("SA1",.F.))
   SA1->A1_GRPTRIB := _cTRIBMVA //"023" //  Motivo: estado reduz o MVA para 30% (exce��o fiscal) e estamos iniciando opera��o de 4 Brokers que atender�o este grupo.
   SA1->(MsUnlock())
EndIf 

RestArea(_aArea)
Return
