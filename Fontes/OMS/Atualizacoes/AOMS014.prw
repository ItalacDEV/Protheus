/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 20/10/2023 | Chamado 45189. Ajustar rotina de efetiva��o para validar JSons retornados vazios da CISP. 
Igor Melga�o  | 19/06/2024 | Chamado 47534. Ajuste para exibi��o da descri��o do CNAE. 
Lucas Borges  | 22/04/2025 | Chamado 50505. Alterada a picture do CNPJ para contemplar campo alfanum�rico
Lucas Borges  | 23/07/2025 | Chamado 51340. Ajustar fun��o para valida��o de ambiente de teste
===============================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Altera��o
==========================================================================================================================================================================================================
Lucas    - Alex Wallauer - 24/09/24 - 24/09/24 - 48465   - Removido warnings do code analisys.
Antonio  - Igor Melga�o  - 26/12/24 - 27/12/24 - 49451   - Ajuste para corre��o de erro.
Jerry    - Julio Paz     - 11/04/24 - 11/04/25 - 44503   - Alterar a rotina para gravar o Subsegmento (A1_I_SUBCO = ZX_SUB_COD). 
Andre    - Alex Wallauer - 09/06/25 - 09/06/25 - 50958   - Ajuste no tratamento da descri��o do corpo do e-mail.
Antonio  - Julio Paz     - 17/06/25 - 27/06/25 - 50278   - Cria��o de Campo e Inclus�o de valida��es para determinar usu�rios que podem aprovar o prospect com base nos limetes de cr�dito do Propspect.
==========================================================================================================================================================================================================
*/

#Include "Protheus.ch"
#Include "AP5mail.ch"
#include "fwmvcdef.ch"

/*
===============================================================================================================================
Programa----------: AOMS014
Autor-------------: Erich Buttner
Data da Criacao---: 04/03/2013
Descri��o---------: Rotina de an�lise e efetiva��o de Prospect cadastrado pelo Portal
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS014()

Private aRotina		:= {}
Private ccadastro   := "Prospect"
Private _lConsdBrk  := .T.  // Quando True considera os valores de limite de cr�dito do Broker. Quando False considera o limite de cr�dito do cadastro de clientes.

Aadd( aRotina , { "Efetivar"	  , "U_AOMS014T"	, 0 , 4 } )
Aadd( aRotina , { "Alterar"		  , "U_AOMS014Y" 	, 0 , 4 } )
Aadd( aRotina , { "Excluir"		  , "U_AOMS014R" 	, 0 , 4 } )  
Aadd( aRotina , { "At. Cisp"	  , "U_AOMS014K" 	, 0 , 4 } ) 
Aadd( aRotina , { "An. Cred"	  , "U_AOMS014C" 	, 0 , 4 } )
Aadd( aRotina , { "Enviar E-mail" , "U_AOMS014G" 	, 0 , 4 } )
Aadd( aRotina , { "Legenda"       , "U_AOMS014F" 	, 0 , 4 } )

SZX->( DBSetOrder(1) )
SZX->( DBGotop() )

oBrw := FWMBrowse():New()
oBrw:SetAlias( "SZX" )
oBrw:SetDescription( "Prospect" )
oBrw:SetFilterDefault( "SZX->ZX_STATUS = 'L'" )
//adiciona legenda
oBrw:AddLegend( "ZX_I_ENVML == 'S'" , "BLUE", "E-mail Enviado." )
oBrw:AddLegend( "!EMPTY(ZX_I_GRPVE) .AND. !EMPTY(ZX_I_RISCO) .and. !empty(ZX_I_ACRED)" , "GREEN", "An�lise efetuada" )
oBrw:AddLegend( "EMPTY(ZX_I_GRPVE) .OR. EMPTY(ZX_I_RISCO) .OR. EMPTY(ZX_I_ACRED)" , "RED" , "Falta grupo de vendas,risco de cr�dito e observa��o de an�lise" )
oBrw:Activate()

Return(.T.)

/*
===============================================================================================================================
Programa----------: AOMS014E
Autor-------------: Erich Buttner
Data da Criacao---: 04/03/2013
Descri��o---------: Efetiva��o de Cadastro de Prospect (Novo Cliente)
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS014E() As Logical

Local _aVetor As Array
Local _aCodAux As Array
Local _cCodAux As Character 
Local _nCodAux As Numeric
LOCAL nNRelmp As Numeric
Local _cQuery As Character
Local _cAlias As Character

Local _cNome As Character
Local _cNReduz As Character
Local _cEst	As Character
Local _cEnd	As Character
Local _cBairro As Character
Local _cContato	As Character
Local _cInscr As Character
Local _cComplem As Character
Local _cCarGc As Character
Local _cBoleto As Character
Local _cVendGen As Character
Local _cGrpGen As Character
Local _lMVCSA1 As Logical
Local _cUfMVA As Character
Local _cTRIBMVA As Character
Local _nLimeteAp As Numeric

PRIVATE lMsErroAuto	As Logical

_aVetor 		:= {}
_aCodAux		:= {}
_cCodAux		:= ""
_nCodAux		:= 0
nNRelmp			:= 0
_cQuery			:= ""
_cAlias			:= ""

_cNome 			:= ""
_cNReduz		:= ""
_cEst			:= ""
_cEnd			:= ""
_cBairro		:= ""
_cContato		:= ""
_cInscr		  := ""
_cComplem	  := ""
_cCarGc		  := ""
_cBoleto      := SZX->ZX_I_IBOLE
_cVendGen     := U_ITGetMV("IT_VENDGEN","000156")
_cGrpGen      := U_ITGetMV("IT_GRPGEN","11")
_lMVCSA1      := U_ItGetMv( "MV_MVCSA1" , .F. )
_cUfMVA       := U_ITGetMV("IT_UFSMVA","PR")
_cTRIBMVA     := U_ITGetMV("IT_TRIBMVA","023")
lMsErroAuto   := .F.

//================================================================ 
// Verifica se o usu�rio tem permiss�o para efetivar o prospect.
//================================================================
_nLimeteAp :=  Posicione("ZZL",3,xfilial("ZZL")+AllTrim(__cUserId),"ZZL_VLMAXP") // ZZL_FILIAL+ZZL_CODUSU
If ValType(_nLimeteAp) <> "N"
   _nLimeteAp := 0
EndIf 

If SZX->ZX_I_LC > _nLimeteAp  // Sugest�o de Limite de Cr�dito 
   U_ITMSG("O Valor do limite de cr�dito deste cliente: " + AllTrim(Str(SZX->ZX_I_LC,14,2)) + ", � superior ao limite permitido para este usu�rio aprovar: " + AllTrim(Str(_nLimeteAp,14,2))+".","Aten��o","",1)
   Return
EndIf 
 
//================================================================
// Valida Simples Nacional.
//================================================================
If empty(SZX->ZX_SIMPNAC)

	U_ITMSG("� obrigatorio selecionar se o cliente � Simples Nacional","Aten��o","Selecione se o cliente � Simples Nacional",1)
	Return
	
Endif

If empty(SZX->ZX_CONTRIB)

	U_ITMSG("� obrigatorio selecionar se o cliente � Contribuinte ICMS","Aten��o","Selecione se o cliente � Contribuinte ICMS",1)
	Return
	
Endif

//Valida se cliente est� ativo no Sintegra quando teve consulta pela Cisp
If !empty(ALLTRIM(SZX->ZX_SITST))

	_csitmaior := Upper(alltrim(SZX->ZX_SITST))
	If 	!(_csitmaior == "HABILITADO" .OR. _csitmaior == "HABILITADA" .OR. _csitmaior == "ATIVO" .OR. _csitmaior == "ATIVA" .OR. _csitmaior == "ATIVO - HABILITADO"  .OR. _csitmaior == "HABILITADO - ATIVO")
	
		u_itmsg("Cliente com restri��o no cadastro do Sintegra","Aten��o","Efetiva��o n�o ser� realizada",1)
		Return
		
	Endif

Endif


//Valida se cliente est� ativo no Sintegra quando teve consulta pela Cisp
If !empty(ALLTRIM(SZX->ZX_I_SITRF))

	_csitmaior := alltrim(SZX->ZX_I_SITRF)
	If 	!(_csitmaior == "HABILITADO" .OR. _csitmaior == "HABILITADA" .OR. _csitmaior == "ATIVO" .OR. _csitmaior == "ATIVA" .OR. _csitmaior == AllTrim(SubStr("ATIVO - HABILITADO",1,10))  .OR. _csitmaior == AllTrim(SubStr("HABILITADO - ATIVO",1,10))) // O campo ZX_I_SITRF tem um tamanho de 10 posi��es.
	
		u_itmsg("Cliente com restri��o no cadastro da Receita","Aten��o","Efetiva��o n�o ser� realizada",1)
		Return
		
	Endif

Endif


DBSelectArea('SA3')
SA3->( DBSetOrder(1) )
If SA3->( DBSeek( xFilial('SA3') + SZX->ZX_VEND ) )
	
	If SA3->A3_I_TIPV <> 'V'
	
	
		u_itmsg('O cadastro atual n�o pode ser efetivado pois o vendedor amarrado ao Cliente n�o est� classificado como Vendedor!',"Valida��o  de vendedor",;
				'Verifique os dados informados e/ou o cadastro do Vendedor no Sistema antes de solicitar a efetiva��o.',1)
			
		Return()

	EndIf
	
	If SA3->A3_MSBLQL == '1'
	
		u_itmsg('O cadastro atual n�o pode ser efetivado pois o vendedor amarrado ao Cliente est� bloqueado no sistema!',"Valida��o  de vendedor",;
				'Verifique os dados informados e/ou o cadastro do Vendedor no Sistema antes de solicitar a efetiva��o.',1)
				
		Return()

	EndIf
	
Else

	u_itmsg('O cadastro atual n�o pode ser efetivado pois o vendedor amarrado ao Cliente n�o � v�lido no cadastro do Sistema!',"Valida��o  de vendedor",;
				'Verifique os dados informados e/ou o cadastro do Vendedor no Sistema antes de solicitar a efetiva��o.',1)

	
	Return()
	
EndIf


//Valida se cliente est� pertence ao grupo 11 o vendedor tem que ser gen�rico
If !Empty(Alltrim(_cGrpGen)) .And. !Empty(Alltrim(_cVendGen)) 
	
	If SZX->ZX_GRCLI $ _cGrpGen .And. !(SZX->ZX_VEND $ _cVendGen)
		
		U_ITMSG("A efetiva��o n�o ser� realizada!"+Chr(13)+Chr(10)+"Para este grupo de clientes "+SZX->ZX_GRCLI+" s� � permito vincular os vendedores gen�ricos: "+_cVendGen,"Aten��o","Altere o vendedor para um que seja gen�rico conforme informado.",1)

		Return

	EndIf

EndIf


//Valida��o da inscri��o estadual
If alltrim(SZX->ZX_INSCR) != "ISENTO"

	_cInscr		:= U_AOMS014N(SZX->ZX_INSCR)

Else

	_cInscr     := "ISENTO"

Endif

M->A1_EST   := U_AOMS014S(SZX->ZX_EST)

//Nova regra para composi��o do Campo de IE da UF de MG, que deve conter sempre 13 caracteres

If M->A1_EST == 'MG'
	_cInscr := Alltrim(_cInscr)
    _cInscr := PadL(_cInscr, 13, '0')
ENDIF

M->A1_INSCR := _cInscr

If !(IE(M->A1_INSCR,M->A1_EST) .And. A030VldUCod()) .or. EMPTY(_cInscr)

  U_ITMSG("Falha na valida��o da inscri��o estadual!","Valida��o de inscri��o estadual","Verifique a inscri��o estadual no sintegra e digite somente os n�meros ou ISENTO",1)
  
  Return
  
Endif                                                                                  

//===============================================================================================
// ABRE CONTROLE DE TRANSACAO
//===============================================================================================
BeginTran()

Begin Sequence

DBSelectArea("CC2")
CC2->( DBSetOrder(1) )
CC2->( DBSeek( xFilial("CC2") + SZX->ZX_EST + SZX->ZX_CODMUN ) )

DBSelectArea("SA1")
SA1->( DBSetOrder(3) )
IF SA1->( DBSeek( xFilial("SA1") + SZX->ZX_CGC ) )

	u_itmsg(	"O CPF/CNPJ informado j� existe no cadastro de clientes com o C�digo/Loja: ["+ SA1->A1_COD +"/"+ SA1->A1_LOJA +"]", "Valida��o de CNPJ"	,;
					"N�o � permitido cadastrar dois Clientes com o mesmo CPF/CNPJ, verifique os cadastros antes de efetivar o Prospect.",1	 )
	
	nNRelmp := 0

Else
	
	_cQuery := " SELECT DISTINCT "
	_cQuery += "     A1_COD     ,"
	_cQuery += "     A1_MSBLQL   "
	_cQuery += " FROM  "+ RETSQLNAME('SA1') +" SA1 "
	_cQuery += " WHERE "+ RETSQLCOND('SA1')
	_cQuery += " AND A1_CGC     LIKE '"+ SubStr( SZX->ZX_CGC , 1 , 8 ) +"%' "
	_cQuery += " ORDER BY A1_COD "
	
	_cAlias := GetNextAlias()
	
	MPSysOpenQuery( _cQuery , _cAlias ) 
	
	_cCodAux := ""
	_nCodAux := 0
	
	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	While (_cAlias)->( !Eof() )
	
		aAdd( _aCodAux , { (_cAlias)->A1_COD , IIF( (_cAlias)->A1_MSBLQL == '1' , 'Bloqueado' , 'Ativo' ) } )
		
		If _cCodAux <> (_cAlias)->A1_COD
			_cCodAux := (_cAlias)->A1_COD
			_nCodAux++
		EndIf
		
		(_cAlias)->( DBSkip() )
	EndDo
	
	(_cAlias)->( DBCloseArea() )
	
	If _nCodAux > 1
		
		u_itmsg( 'Existe mais um c�digo de cliente cadastrado para esse CNPJ no sistema. Verifique o c�digo correto e selecione para continuar com a efetiva��o!' , 'Aten��o!' ,,1)
		_cCodAux := U_ITListBox( 'C�digos de cliente encontrados para o CNPJ' , {'C�digo','Status'} , _aCodAux , .F. , 3 , 'Selecione o c�digo a ser utilizado na efetiva��o:' ,,{100,100}, 1 )
		
		If Empty( _cCodAux )
			u_itmsg(  'Opera��o cancelada pelo usu�rio!' ,,,1 )
			DisarmTransaction()
			Break // Return()

		EndIf
	EndIf

	_cNome 		:= SZX->ZX_NOME
	_cNReduz	:= SZX->ZX_NREDUZ
	_cEst		:= SZX->ZX_EST
	_cEnd		:= SZX->ZX_END
	_cBairro	:= SZX->ZX_BAIRRO
	_cContato	:= SZX->ZX_CONTATO
	_cComplem	:= SZX->ZX_COMPLEM
	_cCarGc		:= SZX->ZX_CARGC

	_cBairro := StrTran(_cBairro,"�","") // Estes caracteres especiais estavam impedindo a cria��o do registro no Cadastro de clientes. No MSEXECAUTO. 
	_cBairro := StrTran(_cBairro,"�","") // Estes caracteres especiais estavam impedindo a cria��o do registro no Cadastro de clientes. No MSEXECAUTO. 
	
	If !(U_CRMA980VCP(@_cNome    ,"ZX_NOME"))
		Break // Return()
	EndIf
	If !(U_CRMA980VCP(@_cNReduz  ,"ZX_NREDUZ"))
		Break // Return()
	EndIf
	If !(U_CRMA980VCP(@_cEst     ,"ZX_EST"))
		Break // Return()
	EndIf
	If !(U_CRMA980VCP(@_cEnd     ,"ZX_END"))
		Break // Return()
	EndIf
	If !(U_CRMA980VCP(@_cBairro  ,"ZX_BAIRRO"))
		Break // Return()
	EndIf
	If !(U_CRMA980VCP(@_cContato ,"ZX_CONTATO"))
		Break // Return()
	EndIf
	If !(U_CRMA980VCP(@_cComplem ,"ZX_COMPLEM"))
		Break // Return()
	EndIf
	If !(U_CRMA980VCP(@_cCarGc   ,"ZX_CARGC"))
		Break // Return()
	EndIf

	//Valida��o de cadastro Chep
	If len(alltrim(SZX->ZX_I_CCHEP)) == 10
	
		_ccchep := alltrim(SZX->ZX_I_CCHEP)
		_cchep := "C"
			
	Else
	
		_ccchep := space(10)
		_cchep := "P"
	
	Endif
		Aadd(_aVetor,{ "A1_FILIAL"	, XFILIAL("SA1")								,Nil})
		Aadd(_aVetor,{ "A1_NOME"	, LEFT(_cNome,LEN(SA1->A1_NOME))				,Nil})
		Aadd(_aVetor,{ "A1_PESSOA"	, SZX->ZX_PESSOA								,Nil})
		Aadd(_aVetor,{ "A1_CGC"		, SZX->ZX_CGC									,Nil})
		Aadd(_aVetor,{ "A1_NREDUZ"	, LEFT(_cNReduz,LEN(SA1->A1_NREDUZ))			,Nil})
		Aadd(_aVetor,{ "A1_TIPO"	, SZX->ZX_TIPO									,Nil})
		Aadd(_aVetor,{ "A1_EST"		, _cEst											,Nil})
		Aadd(_aVetor,{ "A1_COD_MUN"	, CC2->CC2_CODMUN								,Nil})
		Aadd(_aVetor,{ "A1_CEP"		, SZX->ZX_CEP									,Nil})
		Aadd(_aVetor,{ "A1_DDD"		, SZX->ZX_DDD									,Nil})
		Aadd(_aVetor,{ "A1_TEL"		, SZX->ZX_TEL									,Nil})
		Aadd(_aVetor,{ "A1_END"		, _cEnd											,Nil}) 
		Aadd(_aVetor,{ "A1_BAIRRO"	, _cBairro										,Nil}) 
		Aadd(_aVetor,{ "A1_TELEX"	, SZX->ZX_TELEX									,Nil})	
		Aadd(_aVetor,{ "A1_FAX"		, SZX->ZX_FAX									,Nil})	
		Aadd(_aVetor,{ "A1_PAIS"	, SZX->ZX_PAIS									,Nil})	
		Aadd(_aVetor,{ "A1_CONTATO"	, _cContato										,Nil})		
		Aadd(_aVetor,{ "A1_INSCR"	, _cInscr										,Nil})	
		Aadd(_aVetor,{ "A1_PFISICA"	, SZX->ZX_PFISICA								,Nil})	
		Aadd(_aVetor,{ "A1_DTNASC"	, SZX->ZX_DTNASC								,Nil})	
		Aadd(_aVetor,{ "A1_EMAIL"	, SZX->ZX_EMAIL									,Nil})	
		Aadd(_aVetor,{ "A1_HPAGE"	, SZX->ZX_HPAGE									,Nil})	
		Aadd(_aVetor,{ "A1_INSCRM"	, SZX->ZX_INSCRM								,Nil})	
		Aadd(_aVetor,{ "A1_INSCRUR"	, SZX->ZX_INSCRUR								,Nil})	
		Aadd(_aVetor,{ "A1_COMPLEM"	, _cComplem										,Nil})	
		Aadd(_aVetor,{ "A1_MSBLQL"	, "2"											,Nil})	
		Aadd(_aVetor,{ "A1_ESTC"	, _cEst											,Nil})	
		Aadd(_aVetor,{ "A1_CEPC"	, SZX->ZX_CEP									,Nil})	
		Aadd(_aVetor,{ "A1_ENDCOB"	, _cEnd											,Nil})	
		Aadd(_aVetor,{ "A1_BAIRROC"	, _cBairro										,Nil})
		Aadd(_aVetor,{ "A1_VEND"	, SZX->ZX_VEND									,Nil})	
		Aadd(_aVetor,{ "A1_GRPVEN"	, SZX->ZX_I_GRPVE								,Nil})

		If _cEst $ _cUfMVA .And. SZX->ZX_SIMPNAC == "1" // Cliente do Parana e Optante do /simples nacional.
		   Aadd(_aVetor,{ "A1_GRPTRIB"	, _cTRIBMVA     							,Nil}) // "023" / Solicita��o chamado 44096.
		EndIf 

        SA3->(DbSetOrder(1)) 
		If SA3->(MsSeek(xFilial("SA3")+SZX->ZX_VEND))
           If SA3->A3_I_VBROK == 'B' .And. _lConsdBrk // Quando True considera os valores de limite de cr�dito do Broker. Quando False considera o limite de cr�dito do cadastro de clientes.
			  Aadd(_aVetor,{ "A1_LC"		, SA3->A3_I_LC     ,Nil})
			  Aadd(_aVetor,{ "A1_RISCO"	, SA3->A3_I_RISCO  ,Nil}) 
			  Aadd(_aVetor,{ "A1_TABELA"  , SA3->A3_I_TABPR  ,Nil}) 
			  //			ENDIF
			  //			_cBoleto := "S"
           Else 
			   Aadd(_aVetor,{ "A1_LC"		, SZX->ZX_I_LC	    ,Nil})			
			   Aadd(_aVetor,{ "A1_RISCO"	, SZX->ZX_I_RISCO   ,Nil})			
               If SZX->ZX_SIMPNAC == "1"
		          Aadd(_aVetor,{ "A1_TABELA"  , SA3->A3_I_TABSN ,Nil}) 
			   EndIf 
		    EndIf       
		 EndIf
		Aadd(_aVetor,{ "A1_I_DTCAD"	, dDatabase										,Nil})
		Aadd(_aVetor,{ "A1_COND"	, SZX->ZX_CONDPAG								,Nil})
		Aadd(_aVetor,{ "A1_I_CHEP"	, _cchep										,Nil})
		Aadd(_aVetor,{ "A1_I_CCHEP"	, _ccchep										,Nil})
		Aadd(_aVetor,{ "A1_I_CARGC"	, _cCarGc										,Nil})
		Aadd(_aVetor,{ "A1_I_GRCLI"	, SZX->ZX_GRCLI					 				,Nil})
		Aadd(_aVetor,{ "A1_I_CMUNC"	, CC2->CC2_CODMUN								,Nil})
		Aadd(_aVetor,{ "A1_I_EMAIL"	, SZX->ZX_EMAILC				 				,Nil})
		Aadd(_aVetor,{ "A1_NATUREZ"  , "111001"  									,Nil})  
		Aadd(_aVetor,{ "A1_VENCLC"	, SZX->ZX_I_VENCL 								,Nil})
		Aadd(_aVetor,{ "A1_CODPAIS"	, "01058"				  						,Nil})
		Aadd(_aVetor,{ "A1_I_ACRED" , SZX->ZX_I_ACRED								,Nil})
		Aadd(_aVetor,{ "A1_CONTRIB"	, SZX->ZX_CONTRIB								,Nil})
		Aadd(_aVetor,{ "A1_CNAE"    , LEFT(SZX->ZX_I_END,LEN(SA1->A1_CNAE))         ,Nil})
		Aadd(_aVetor,{ "A1_SIMPNAC"	, SZX->ZX_SIMPNAC								,Nil})
		Aadd(_aVetor,{ "A1_I_IBOLE"	, _cBoleto										,Nil}) 
	    Aadd(_aVetor,{ "A1_I_SUBCO"	, SZX->ZX_SUB_COD								,Nil}) 

	If _nCodAux > 1
		aAdd( _aVetor , { "A1_COD" , _cCodAux , Nil } )
	EndIf

    IF SA1->(FieldPos("A1_I_ORIGD")) > 0
       AADD(_aVetor,{"A1_I_ORIGD", SZX->ZX_I_ORIGD		  ,Nil})
    ENDIF    
    
    IF SA1->(FieldPos("A1_I_DW")) > 0         
       Aadd(_aVetor,{"A1_I_SLC"	, SZX->ZX_I_SLC		,Nil})  
	   Aadd(_aVetor,{"A1_I_DW" 	, SZX->ZX_I_DW		,Nil})  
    EndIf 

	nNRelmp		:= 2
	lMsErroAuto	:= .F.
	_aVetor:=U_AcertaDados("SA1",_aVetor)//por causado MVC 
	//===========================================================================
	//| Chama ExecAuto do Cadastro de Clientes                                  |
	//===========================================================================

    If _lMVCSA1  
        MSExecAuto( {|x,y,z| CRMA980(x,y,z) } , _aVetor , 3 ,{} ) // SIGA AUTO PARA A INCLUSAO DO CLIENTE
    Else 
		MSExecAuto( {|x,y| Mata030(x,y)} , _aVetor , 3 ) 
    EndIf 
	
	//===========================================================================
	//| Verifica o status do processamento                                      |
	//===========================================================================
	If lMsErroAuto
	
	   Mostraerro()
	   nNRelmp := 1
		
	Else
	
		//===========================================================================
		//| Verifica o cadastro ap�s a conclus�o                                    |
		//===========================================================================
		DBSelectArea("SA1")
		SA1->( DBSetOrder(3) )
		SA1->( DBGoTop() )
		If !SA1->( DBSeek( xFilial("SA1") + _aVetor[04][02] ) )
		
			nNRelmp := 1
		
		EndIf
	
	EndIF

EndIF

//===========================================================================
//| Tratativa para os casos que falham na inclus�o                          |
//===========================================================================
If nNRelmp == 1

	//===============================================================================================
	// DESFAZ O PROCESSO PELO CONTROLE DE TRANSACAO
	//===============================================================================================
	DisarmTransaction()
	
	If lMsErroAuto
	
		cNomArqErro	:= NomeAutoLog()
		cNomNovArq	:= __RELDIR + "SA1MIME.##R"
		MostraErro()
		
		If MsErase( cNomNovArq )
		   If ! Empty(cNomArqErro) .And. File(cNomArqErro)
			  __CopyFile( cNomArqErro , cNomNovArq )
		   EndIf 
		EndIf
		
		If ValType(cNomArqErro) == "C"
		   U_ItConout(cNomArqErro)
	    EndIf 
	EndIf
	
//===========================================================================
//| Tratativa para os casos que foram inclu�dos com sucesso                 |
//===========================================================================
ElseIF nNRelmp == 2
	
	//===========================================================================
	//| Registra o Status de "Importado" para o Prospect                        |
	//===========================================================================
	SZX->( RecLock( "SZX" , .F. ) )
		SZX->ZX_STATUS	:= "I"
		SZX->ZX_CLIENTE	:= SA1->A1_COD
		SZX->ZX_LOJA	:= SA1->A1_LOJA
	SZX->(MsUnlock())
	
	//===========================================================================
	//| Grava��o das Refer�ncias e Dados Banc�rios                              |
	//===========================================================================
	If !Empty(ALLTRIM(SZX->ZX_RC1CONT)) .Or.!EMPTY(ALLTRIM(SZX->ZX_RC1EMP))
		
		DBSelectArea("SAO")
		SAO->( RecLock( "SAO" , .T. ) )
		
			SAO->AO_FILIAL	:= xFilial("SAO")
			SAO->AO_CLIENTE	:= SA1->A1_COD
			SAO->AO_LOJA	:= SA1->A1_LOJA
			SAO->AO_TIPO	:= "2"
			SAO->AO_NOMINS	:= SZX->ZX_RC1EMP
			SAO->AO_DATA	:= dDataBase
			SAO->AO_TELEFON	:= SZX->ZX_RC1TEL
			SAO->AO_CONTATO	:= SZX->ZX_RC1CONT
			
		SAO->( MsUnlock() )
		
	EndIF
	
	IF !Empty(ALLTRIM(SZX->ZX_RC2CONT)) .Or.!EMPTY(ALLTRIM(SZX->ZX_RC2EMP))
		
		DBSelectArea("SAO")
		SAO->( RecLock("SAO",.T.) )
		
			SAO->AO_FILIAL	:= xFilial("SAO")
			SAO->AO_CLIENTE	:= SA1->A1_COD
			SAO->AO_LOJA	:= SA1->A1_LOJA
			SAO->AO_TIPO	:= "2"
			SAO->AO_NOMINS	:= SZX->ZX_RC2EMP
			SAO->AO_DATA	:= dDataBase
			SAO->AO_TELEFON	:= SZX->ZX_RC2TEL
			SAO->AO_CONTATO	:= SZX->ZX_RC2CONT
			
		SAO->( MsUnlock() )
		
	EndIF
	
EndIf

End Sequence 

//===============================================================================================
// FECHA CONTROLE DE TRANSACAO
//===============================================================================================
EndTran()
MsUnlockAll()

//===============================================================================================
// Mensagem de conclus�o do Processamento
//===============================================================================================
If nNRelmp == 1
	u_itmsg( "N�o foi poss�vel efetivar o cadastro, verifique os dados do Prospect e tente novamente."	,,,1 )
ElseIF nNRelmp == 2
	u_itmsg( "Cadastro efetivado com sucesso!"															,,,2 )
EndIf

Return( .T. )

/*
===============================================================================================================================
Programa----------: AOMS014T
Autor-------------: Erich Buttner
Data da Criacao---: 16/04/2013
Descri��o---------: Efetiva��o do cadastro de prospect (novo cliente)
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS014T()

Local nOpca	:= 0
Local aButtons := {}

//Valida se cadastro n�o est� na base de dados
If AOMS014V(SZX->ZX_CGC)
	Return
Endif

// Valida a parte de limite de cr�dito.
If ! U_AOMS014W("CREDITO")
   Return Nil 
EndIf 

//Atualiza via Cisp na hora de efetivar
regtomemory("SZX")
fwmsgrun(,{|oproc| U_AOMS014B(2,oproc)},"Aguarde...","Aguarde")
		
//Grava altera��o
u_itmemtor("SZX")

//adiciona botoes na Enchoice                       
aAdd( aButtons, { "CISP", {|| fwmsgrun(,{|oproc| U_AOMS014B(2,oproc)},"Aguarde...","Aguarde")}, "At. Cisp", "At. Cisp" } ) 
aAdd( aButtons, { "CRED", {|| fwmsgrun(,{|oproc| U_TelCred(1)},"Aguarde...","Aguarde")}, "An. Cred", "An. Cred" } ) 



nOpca := AxVisual(	"SZX"	,;	//<cAlias>
					9999	,;	//<nReg>
					2		,;	//<nOpc>
							,;	//<aAcho>
							,;	//<nColMens>
							,;	//<cMensagem>
							,;	//<cFunc>
				aButtons	,;	//<aButtons>
					.F.		 )	//<lMaximized>

If nOpca == 1

	U_AOMS014E()
			
EndIf

Return()

/*
===============================================================================================================================
Programa----------: AOMS014Y
Autor-------------: Josu� Danich
Data da Criacao---: 16/04/2013
Descri��o---------: Altera��o do cadastro de prospect (novo cliente)
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS014Y()

Local nOpca	:= 0

Private  aButtons := {}
Private cCadastro := "Altera��o de Prospect" // t�tulo da tela                                                                     

//Valida se cadastro n�o est� na base de dados
AOMS014V(SZX->ZX_CGC)

//Tenta atualiza��o Cisp primeiro
If empty(ALLTRIM(SZX->ZX_SITST))

   regtomemory("SZX")
   fwmsgrun(,{|oproc| U_AOMS014B(2,oproc)},"Aguarde...","Aguarde")
		
   //Grava altera��o
   u_itmemtor("SZX")
   
Endif

//adiciona botoes na Enchoice                       
aAdd( aButtons, { "CISP", {|| fwmsgrun(,{|oproc| U_AOMS014B(2,oproc)},"Aguarde...","Aguarde")}, "At. Cisp", "At. Cisp" } ) 
aAdd( aButtons, { "CRED", {|| fwmsgrun(,{|oproc| U_TelCred(1)},"Aguarde...","Aguarde")}, "An. Cred", "An. Cred" } ) 


nOpca := AxAltera("SZX",SZX->(Recno()),4,,,,,,,, aButtons,,,,.T.,,,,,)

Return()


/*
===============================================================================================================================
Programa--------: AOMS014R
Autor-----------: Talita
Data da Criacao-: 27/10/2014
Descri��o-------: Incluido na rotina a op��o de exclus�o do prospect, onde quando o credito excluir ser� aberta uma tela para
----------------: preenchimento do motivo da recusa e ap�s a confirma��o ser� encaminhado um e-mail com a ficha do prospect e
----------------: motivo da exclus�o. Chamado: 7858
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/

User Function AOMS014R() 
  
Local _nOpc := AxVisual(	"SZX"	,;	//<cAlias>
							9999	,;	//<nReg>
							4		,;	//<nOpc>
									,;	//<aAcho>
									,;	//<nColMens>
									,;	//<cMensagem>
									,;	//<cFunc>
									,;	//<aButtons>
							.T.		 )	//<lMaximized>

If _nOpc == 1

    SA3->( DBSetOrder (1) )
    If SA3->( DBSeek( xFilial("SA3") + SZX->ZX_VEND ) )
    	cEmail := AllTrim( SA3->A3_EMAIL )
	ELSE
	    cEmail := "Vendendor n�o encontrado: "+xFilial("SA3") +" "+ SZX->ZX_VEND
    EndIf
	cMens1 := ""
	cGetCc := SuperGetMV("IT_EMCCEP",.F.,"sistema@italac.com.br")+SPACE(200)//EMail Com Copia Exclus�o Prospect
	_nTam:=205
	_nCol:=009 
	_nLin:=005 
	
	DEFINE FONT oFont NAME "Tahoma" BOLD
	
	DEFINE MSDIALOG oDlg TITLE "Exclus�o de Prospect" From 0,0 to 350,500 Of oMainWnd PIXEL
	
		oTPanel1:= TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,450,200,.T.,.F.)
		
		@ _nLin,_nCol SAY "Informe o Motivo da Exclus�o do Prospect"				Of oTPanel1 Pixel FONT oFont
		_nLin+=11
	  	@ _nLin,_nCol SAY "Nome.........: "+	UPPER( ALLTRIM( SZX->ZX_NOME ) )	Of oTPanel1 Pixel
		_nLin+=10
		@ _nLin,_nCol SAY "CGC...........: "+	SZX->ZX_CGC							Of oTPanel1 Pixel
		_nLin+=10
		@ _nLin,_nCol SAY "Email para..: "+cEmail 									Of oTPanel1 Pixel
		_nLin+=11
		@ _nLin,_nCol SAY "Com Copia.: "        									Of oTPanel1 Pixel
		_nCol+=31
		_nLin-=02
		@ _nLin,_nCol Get cGetCc  Size _nTam,10        								Of oTPanel1 Pixel
		_nLin+=11
		
		oTFolder1 := TFolder():New( _nLin,005,{"Motivo"},,oTPanel1,,,,.T.,,245,090 )
	
		@ 005,005 Get oMemo01 var cMens1 MEMO Size 230,60 when .T.					of oTFolder1:aDialogs[1] Pixel
		_nLin+=95		
		TButton():New(_nLin,010, ' Confirma ', oTPanel1,{|| AOMS014R(ALLTRIM(cGetCc)) },70,15,,,,.T.)
		TButton():New(_nLin,090, ' Cancela ' , oTPanel1,{|| oDlg:END()                },70,15,,,,.T.)
		
	ACTIVATE MSDIALOG oDlg Centered

EndIf

Return()

/*
===============================================================================================================================
Programa--------: AOMS014R
Autor-----------: Talita
Data da Criacao-: 27/10/2014
Descri��o-------: Incluido na rotina a op��o de exclus�o do prospect, onde quando o credito excluir ser� aberta uma tela para
----------------: preenchimento do motivo da recusa e ap�s a confirma��o ser� encaminhado um e-mail com a ficha do prospect e
----------------: motivo da exclus�o. Chamado: 7858
Parametros------: cGetCc
Retorno---------: Nenhum
===============================================================================================================================
*/

Static Function AOMS014R(cGetCc)

Local EnvEmail := .F.
Local _aConfig := U_ITCFGEML('')
Local _cEmlLog := ""
Private cEmail := SuperGetMV("IT_EMCCEP",.F.,"sistema@italac.com.br")
DEFAULT cGetCc := SuperGetMV("IT_EMCCEP",.F.,"sistema@italac.com.br")

DbSelectArea("SA3")
SA3->( DBSetOrder (1) )
If SA3->( DBSeek( xFilial("SA3") + SZX->ZX_VEND ) )
	cEmail := AllTrim( SA3->A3_EMAIL )
EndIf

If cEmail <> ""
		
	cMsg := '<table width="75%" border="1">' 
	cMsg += '<tr>'  
	cMsg += '<td bordercolor="#000000" bgcolor="#778899"><div align="center"><font color="#FFFFFF">AVISO DE EXCLUS�O DE PROSPECT</font></div></td>'
	cMsg += '</tr>'
	cMsg += '</table>'
	cMsg += '<BR>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<tr>'
	cMsg += '<td bordercolor="#000000" bgcolor="#778899"><div align="center"><font color="#FFFFFF">DADOS GERAIS</font></div></td>'
	cMsg += '</tr>'
	cMsg += '</table>'
	cMsg += '<tr>'
	cMsg += '<table width="75%" border="1"> '
	cMsg += '<tr>'
	cMsg += '<td><strong>Tipo: </strong>'+"Revendedor"+'</td>' 
	
	If SZX->ZX_PESSOA == 'J'
		cMsg += '<td><strong>Pessoa: </strong>'+"Juridica"+'</td>'
	Else 
		cMsg += '<td><strong>Pessoa: </strong>'+"Fisica"+'</td>'
	EndIf
	
	cMsg += '</table>'
	cMsg += '<BR>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<td><strong>CGC: </strong>'+Transform(SZX->ZX_CGC,"@R! NN.NNN.NNN/NNNN-99")+'</td>'
	cMsg += '<td><strong>Inscri��o Estadual: </strong>'+SZX->ZX_INSCR+'</td>'
	cMsg += '</table>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<td><strong>Nome: </strong>'+SZX->ZX_NOME+' </td>'
	cMsg += '</table>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<td><strong>Nome Fantasia: </strong>'+SZX->ZX_NREDUZ+' </td>'
	cMsg += '</table>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<td><strong>Data de Emiss�o: </strong>'+dtoc(SZX->ZX_EMISSAO)+' </td>'
	cMsg += '<td><strong>Data de Funda��o: </strong>'+dtoc(SZX->ZX_DTNASC)+' </td>'
	cMsg += '</table>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<td><strong>E-mail: </strong>'+SZX->ZX_EMAIL+' </td>'
	cMsg += '<td><strong>Home Page: </strong>'+SZX->ZX_HPAGE+' </td>'
	cMsg += '</table>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<td><strong>Condi��o de Pagamento: </strong>'+SZX->ZX_CONDPAG+ " - "+ALLTRIM(Posicione("SE4",1,xFilial("SE4")+SZX->ZX_CONDPAG,"SE4->E4_DESCRI"))+' </td>'
	
	If SZX->ZX_CHEP = 'S'
	cMsg += '<td><strong>Cadastro na Chep: </strong>'+"Sim"+' </td>'
	Else  
	cMsg += '<td><strong>Cadastro na Chep: </strong>'+"N�o"+' </td>'
	EndIf
	
	cMsg += '<td><strong>Cod. Chep: </strong>'+SZX->ZX_I_CCHEP+' </td>'
	cMsg += '</table>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<td><strong>Segmento: </strong>'+SZX->ZX_GRCLI+ " - " + ALLTRIM(Posicione("ZZ6",1,xFilial("ZZ6")+SZX->ZX_GRCLI,"ZZ6->ZZ6_DESCRO"))+' </td>'
	cMsg += '</table>'
	cMsg += '<br>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<tr>'
	cMsg += '<td bordercolor="#000000" bgcolor="#778899"><div align="center"><font color="#FFFFFF">ENDERE�O</font></div></td>'
	cMsg += '</tr>'
	cMsg += '</table>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<td><strong>Estado: </strong>'+SZX->ZX_EST+' </td>'
	cMsg += '<td><strong>C�digo de Municipio: </strong>'+SZX->ZX_CODMUN+' </td>'
	cMsg += '</table>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<td><strong>Municipio: </strong>'+ALLTRIM(Posicione("CC2",1,xFilial("CC2")+SZX->ZX_EST+SZX->ZX_CODMUN,"CC2->CC2_MUN"))+' </td>'
	cMsg += '</table>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<td><strong>CEP: </strong>'+SZX->ZX_CEP+' </td>'
	cMsg += '</table>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<td><strong>Endere�o: </strong>'+SZX->ZX_END+' </td>'
	cMsg += '</table>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<td><strong>Complemento: </strong>'+SZX->ZX_COMPLEM+' </td>'
	cMsg += '</table>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<td><strong>Bairro: </strong>'+SZX->ZX_BAIRRO+' </td>'
	cMsg += '</table>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<td><strong>DDD: </strong>'+SZX->ZX_DDD+' </td>'
	cMsg += '<td><strong>Telefone: </strong>'+SZX->ZX_TEL+' </td>'
	cMsg += '<td><strong>Fax: </strong>'+SZX->ZX_FAX+' </td>'
	cMsg += '</table>'
	cMsg += '<BR>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<tr>'
	cMsg += '<td bordercolor="#000000" bgcolor="#778899"><div align="center"><font color="#FFFFFF">OBSERVA��ES</font></div></td>'
	cMsg += '</tr>'
	cMsg += '</table>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<td><strong>Obs.: </strong>'+SZX->ZX_OBS+' </td>'
	cMsg += '</table>'
	cMsg += '<br>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<tr>'
	cMsg += '<td bordercolor="#000000" bgcolor="#778899"><div align="center"><font color="#FFFFFF">CONTATO</font></div></td>'
	cMsg += '</tr>'
	cMsg += '</table>'
	cMsg += '<table width="75%" border="1"> '
	cMsg += '<td><strong>Nome do Contato: </strong>'+SZX->ZX_CONTATO+' </td>'
	cMsg += '<td><strong>Cargo do Contato: </strong>'+SZX->ZX_CARGC+' </td>'
	cMsg += '<td><strong>E-mail do Contato: </strong>'+SZX->ZX_EMAILC+' </td>'
	cMsg += '</table>'
	cMsg += '<br>' 
	cMsg += '<table width="75%" border="1">'
	cMsg += '<tr>'
	cMsg += '<td bordercolor="#000000" bgcolor="#778899"><div align="center"><font color="#FFFFFF">REFERENCIA COMERCIAL</font></div></td>'
	cMsg += '</tr>'
	cMsg += '</table>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<td><strong>Empresa: </strong>'+SZX->ZX_RC1EMP+' </td>'
	cMsg += '<td><strong>Telefone: </strong>'+SZX->ZX_RC1TEL+' </td>'
	cMsg += '<td><strong>Nome: </strong>'+SZX->ZX_RC1CONT+' </td>'
	cMsg += '</table>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<td><strong>Empresa: </strong>'+SZX->ZX_RC2EMP+' </td>'
	cMsg += '<td><strong>Telefone: </strong>'+SZX->ZX_RC2TEL+' </td>'
	cMsg += '<td><strong>Nome: </strong>'+SZX->ZX_RC2CONT+' </td>'
	cMsg += '</table>'
	cMsg += '<BR>'
	cMsg += '<table width="75%" border="1">'
	cMsg += '<tr>'
	cMsg += '<td bordercolor="#000000" bgcolor="#778899"><div align="center"><font color="#FFFFFF">OBSERVA��ES ANALISE DE CR�DITO</font></div></td>'
	cMsg += '</tr>'
	cMsg += '</table>'
	cMsg += '<table width="75%" border="1"> '
	cMsg += '<td><strong>Obs. Cr�dito: </strong>'+SZX->ZX_I_ACRED+' </td>'
	cMsg += '</table>'
	cMsg += '<table width="75%" border="1"> '
	cMsg += '<td><strong>Motivo da Recusa: </strong>'+cMens1+' </td>'
	cMsg += '</table>'
	cMsg += '</tr>'
	

//    ITEnvMail(cFrom         ,cEmailTo,cEmailCo,cEmailBcc,cAssunto                  ,cMensagem,cAttach,cAccount    ,cPassword   ,cServer      ,cPortCon    ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro)
	U_ITENVMAIL( _aConfig[01] , cEmail ,cGetCc  ,         ,"Prospect: "+ SZX->ZX_NOME, cMsg ,         ,_aConfig[01],_aConfig[02], _aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

	If _cEmlLog == "Sucesso: e-mail enviado corretamente!"
		EnvEmail := .T.
		u_itmsg("Enviado email de aviso ao representante: " + cEmail+ " / Com copia:  "+cGetCc,,,3)
	Else
		u_itmsg("Falha no envio do email de aviso ao representante: " + _cEmlLog,,,1)
	Endif

Else
	
	u_itmsg(  "E-mail n�o encontrado!" ,"Erro de email", "Favor verificar o c�digo do vendedor e se o e-mail do vendedor est� preenchido!",1)

EndIf

If EnvEmail

	RecLock( "SZX" , .F. )
 	SZX->ZX_MOTREC := cMens1
	SZX->( DbDelete() )
	SZX->( MsUnLock() )
	
EndIf

oDlg:END()

Return( .T. )

/*
===============================================================================================================================
Programa--------: AOMS014S
Autor-----------: Darcio Ribeiro Sp�rl
Data da Criacao-: 19/12/2016
Descri��o-------: Fun��o criada para tirar todos os caracteres especiais de uma vari�vel texto
Parametros------: _cTexto	- Texto a serem retirados os caracteres especiais
Retorno---------: _cRet		- Retorna o texto limpo sem os caracteres especiais
===============================================================================================================================
*/
User Function AOMS014S(_cTexto)
Local _aCarc_Esp	:= {}
Local _nI			:= 0
Local _cRet			:= _cTexto

AADD(_aCarc_Esp,{"!", ""})
AADD(_aCarc_Esp,{"#", ""})
AADD(_aCarc_Esp,{"$", ""})
//AADD(_aCarc_Esp,{"&", ""})
AADD(_aCarc_Esp,{"%", ""})
AADD(_aCarc_Esp,{"*", ""})
//AADD(_aCarc_Esp,{"/", ""})
AADD(_aCarc_Esp,{"(", ""})
AADD(_aCarc_Esp,{")", ""})
AADD(_aCarc_Esp,{"+", ""})
AADD(_aCarc_Esp,{"�", ""})
AADD(_aCarc_Esp,{"=", ""})
AADD(_aCarc_Esp,{"~", ""})
AADD(_aCarc_Esp,{"^", ""})
AADD(_aCarc_Esp,{"]", ""})
AADD(_aCarc_Esp,{"[", ""})
AADD(_aCarc_Esp,{"{", ""})
AADD(_aCarc_Esp,{"}", ""})
AADD(_aCarc_Esp,{";", ""})
AADD(_aCarc_Esp,{":", ""})
AADD(_aCarc_Esp,{">", ""})
AADD(_aCarc_Esp,{"<", ""})
AADD(_aCarc_Esp,{"?", ""})
AADD(_aCarc_Esp,{"_", ""})
AADD(_aCarc_Esp,{",", ""})
AADD(_aCarc_Esp,{"'", ""})
AADD(_aCarc_Esp,{"  ", " "})
AADD(_aCarc_Esp,{"   ", " "})
AADD(_aCarc_Esp,{"    ", " "})
AADD(_aCarc_Esp,{"     ", " "})
AADD(_aCarc_Esp,{"      ", " "})
AADD(_aCarc_Esp,{"       ", " "})
AADD(_aCarc_Esp,{"        ", " "})

//Executa o Laco ate o Tamanho Total do Array
For _nI := 1 To Len(_aCarc_Esp)
	//Verifica se Algum dos Caracteres Especiais foi Digitado
	If _aCarc_Esp[_nI][1] $ AllTrim(_cRet)
		_cRet := StrTran(_cRet, _aCarc_Esp[_nI][1], _aCarc_Esp[_nI][2])
	EndIf
Next

_cRet := UPPER(FWNOACCENT(ALLTRIM(_cRet)))

Return(_cRet)


/*
===============================================================================================================================
Programa--------: AOMS014N
Autor-----------: Josu� Danich Prestes
Data da Criacao-: 30/10/2017
Descri��o-------: Fun��o criada para tirar todos os caracteres n�o num�ricos de uma vari�vel texto
Parametros------: _cTexto	- Texto a serem retirados os caracteres n�o num�ricos
Retorno---------: _cRet		- Retorna o texto limpo sem os caracteres n�o num�ricos
===============================================================================================================================
*/
User Function AOMS014N(_cTexto)
Local _nI			:= 0
Local _cRet			:= _cTexto

For _ni := 1 to len(_ctexto)

  If substr(_ctexto,_ni,1) != '0' .and. substr(_ctexto,_ni,1) != '1' .and. substr(_ctexto,_ni,1) != '2';
   			.and. substr(_ctexto,_ni,1) != '3' .and. substr(_ctexto,_ni,1) != '4' .and. substr(_ctexto,_ni,1) != '5' .and.;
   			 substr(_ctexto,_ni,1) != '6' .and. substr(_ctexto,_ni,1) != '7' .and. substr(_ctexto,_ni,1) != '8' .and. substr(_ctexto,_ni,1) != '9' 

   	  _cRet := StrTran(_cRet, substr(_ctexto,_ni,1) , "")

  Endif
  
Next

Return(_cRet)

/*
===============================================================================================================================
Programa----------: AOMS014A
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 04/03/2013
Descri��o---------: Altera��o de Cadastro de Prospect (Novo Cliente)
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS014A()

Local _aCodAux		:= {}
Local _cCodAux		:= ""
Local _nCodAux		:= 0
LOCAL nNRelmp		:= 0
Local _cQuery		:= ""
Local _cAlias		:= ""
Local _cInscr		:= ""

PRIVATE lMsErroAuto	:= .F.

If empty(M->ZX_SIMPNAC)

	U_ITMSG("� obrigatorio selecionar se o cliente � Simples Nacional","Aten��o","Selecione se o cliente � Simples Nacional",1)
	Return
	
Endif

If empty(M->ZX_CONTRIB)

	U_ITMSG("� obrigatorio selecionar se o cliente � Contribuinte ICMS","Aten��o","Selecione se o cliente � Contribuinte ICMS",1)
	Return
	
Endif


DBSelectArea('SA3')
SA3->( DBSetOrder(1) )
If SA3->( DBSeek( xFilial('SA3') + M->ZX_VEND ) )
	
	If SA3->A3_I_TIPV <> 'V'
	
	
		u_itmsg('O cadastro atual n�o pode ser efetivado pois o vendedor amarrado ao Cliente n�o est� classificado como Vendedor!',"Valida��o  de vendedor",;
				'Verifique os dados informados e/ou o cadastro do Vendedor no Sistema antes de solicitar a efetiva��o.',1)
			
		Return()

	EndIf
	
	If SA3->A3_MSBLQL == '1'
	
		u_itmsg('O cadastro atual n�o pode ser efetivado pois o vendedor amarrado ao Cliente est� bloqueado no sistema!',"Valida��o  de vendedor",;
				'Verifique os dados informados e/ou o cadastro do Vendedor no Sistema antes de solicitar a efetiva��o.',1)
				
		Return()

	EndIf
	
Else

	u_itmsg('O cadastro atual n�o pode ser efetivado pois o vendedor amarrado ao Cliente n�o � v�lido no cadastro do Sistema!',"Valida��o  de vendedor",;
				'Verifique os dados informados e/ou o cadastro do Vendedor no Sistema antes de solicitar a efetiva��o.',1)

	
	Return()
	
EndIf

//Valida��o da inscri��o estadual
If alltrim(M->ZX_INSCR) != "ISENTO"

	_cInscr		:= U_AOMS014N(M->ZX_INSCR)

Else

	_cInscr     := "ISENTO"

Endif

M->A1_INSCR := _cInscr
M->A1_EST   := U_AOMS014S(SZX->ZX_EST)

If !(IE(M->A1_INSCR,M->A1_EST) .And. A030VldUCod()) .or. EMPTY(_cInscr)

  U_ITMSG("Falha na valida��o da inscri��o estadual!","Valida��o de inscri��o estadual","Verifique a inscri��o estadual no sintegra e digite somente os n�meros ou ISENTO",1)
  
  Return
  
Endif                                                                                  

//===============================================================================================
// ABRE CONTROLE DE TRANSACAO
//===============================================================================================
BeginTran()

Begin Sequence

DBSelectArea("CC2")
CC2->( DBSetOrder(1) )
CC2->( DBSeek( xFilial("CC2") + M->ZX_EST + M->ZX_CODMUN ) )

DBSelectArea("SA1")
SA1->( DBSetOrder(3) )
IF SA1->( DBSeek( xFilial("SA1") + M->ZX_CGC ) )

	u_itmsg(	"O CPF/CNPJ informado j� existe no cadastro de clientes com o C�digo/Loja: ["+ SA1->A1_COD +"/"+ SA1->A1_LOJA +"]", "Valida��o de CNPJ"	,;
					"N�o � permitido cadastrar dois Clientes com o mesmo CPF/CNPJ, verifique os cadastros antes de efetivar o Prospect.",1	 )
	
	nNRelmp := 0

Else
	
	_cQuery := " SELECT DISTINCT "
	_cQuery += "     A1_COD     ,"
	_cQuery += "     A1_MSBLQL   "
	_cQuery += " FROM  "+ RETSQLNAME('SA1') +" SA1 "
	_cQuery += " WHERE "+ RETSQLCOND('SA1')
	_cQuery += " AND A1_CGC     LIKE '"+ SubStr( M->ZX_CGC , 1 , 8 ) +"%' "
	_cQuery += " ORDER BY A1_COD "
	
	_cAlias := GetNextAlias()
	
	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	
	DBUseArea( .T. , 'TopConn' , TcGenQry(,,_cQuery) , _cAlias , .F. , .T. )
	
	_cCodAux := ""
	_nCodAux := 0
	
	DBSelectArea(_cAlias)
	(_cAlias)->( DBGoTop() )
	While (_cAlias)->( !Eof() )
	
		aAdd( _aCodAux , { (_cAlias)->A1_COD , IIF( (_cAlias)->A1_MSBLQL == '1' , 'Bloqueado' , 'Ativo' ) } )
		
		If _cCodAux <> (_cAlias)->A1_COD
			_cCodAux := (_cAlias)->A1_COD
			_nCodAux++
		EndIf
		
	(_cAlias)->( DBSkip() )
	EndDo
	
	(_cAlias)->( DBCloseArea() )
	
	If _nCodAux > 1
		
		u_itmsg( 'Existe mais um c�digo de cliente cadastrado para esse CNPJ no sistema. Verifique o c�digo correto e selecione para continuar com a efetiva��o!' , 'Aten��o!' ,,1)
		_cCodAux := U_ITListBox( 'C�digos de cliente encontrados para o CNPJ' , {'C�digo','Status'} , _aCodAux , .F. , 3 , 'Selecione o c�digo a ser utilizado na efetiva��o:' ,,{100,100}, 1 )
		
		If Empty( _cCodAux )
		
			u_itmsg(  'Opera��o cancelada pelo usu�rio!' ,,,1 )
			DisarmTransaction()
			Break // Return()
			
		EndIf
		
	EndIf
	
	//Grava altera��o
	u_itmemtor("SZX")	
   
   nNRelmp := 2 //Registra grava��o bem sucedida
	
Endif

End Sequence
//===============================================================================================
// FECHA CONTROLE DE TRANSACAO
//===============================================================================================
EndTran()
MsUnlockAll()

//===============================================================================================
// Mensagem de conclus�o do Processamento
//===============================================================================================
If nNRelmp == 1
	u_itmsg( "N�o foi poss�vel efetivar o cadastro, verifique os dados do Prospect e tente novamente."	,,,1 )
ElseIF nNRelmp == 2
	u_itmsg( "Cadastro efetivado com sucesso!"															,,,2 )
EndIf

Return( .T. )

/*
===============================================================================================================================
Programa----------: AOMS014B
Autor-------------: Josu� Danich
Data da Criacao---: 16/04/2013
Descri��o---------: Consulta Cisp
Parametros--------: _natua - tipo de consulta, 1 em segundo plano, 2 em tela
					oproc - objeto da barra de processamento
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER FUNCTION AOMS014B(_natua,oproc)

Local cUrlsintegra   // := "https://servicos.cisp.com.br/v1/sintegra/" + alltrim(M->ZX_CGC)
Local cUrlreceita    // := "https://servicos.cisp.com.br/v1/receita-federal/" + alltrim(M->ZX_CGC)
Local cUrlsimples    // := "https://servicos.cisp.com.br/v1/simples-nacional/" + alltrim(M->ZX_CGC)
Local aHeadOut        := {}
Local cHdSintegra     := ""
Local cCorSintegra    := ""
Local _osintegra
Local _asintegra      := {}
Local cHdReceita      := ""
Local cCorReceita     := ""
Local _oReceita
Local _aReceita       := {}
Local _lret           := .T.
Local _lerro          := .F.
Local _cerro          := ""
Local _lisento 		  := .F.
Local _csintegra    := nil
Local _nI 

Local _nnj			:= 0
Local _lLinkPrd     := U_ItGetMv("IT_LKCISPP", .T.)
Local cUrlcisp      := "https://servicos.cisp.com.br/v1/avaliacao-analitica/raiz/" + substr(alltrim(M->ZX_CGC),1,8)
Local _cpasswd      := u_itgetmv("IT_PWCISP","!t@lac95_01#")
Local _cuser	    := u_itgetmv("IT_USCISP","ws09501")
Local _cDecodeTxt   := ""
Local _cNomeSint, _cNomeRSit

Default oproc         := nil
Default _natua := 2

If _lLinkPrd
   //====================================================================
   // Link base produ��o
   //====================================================================
   cUrlsintegra := "https://api.maxxi.cisp.com.br/public-bases/v1/sintegra/cnpj/"+ Alltrim(M->ZX_CGC)+"/uf/"+AllTrim(M->ZX_EST)+"?key=dwnljGS5DRJ0BkzGGgRsrNZCUxqdqrZw" //"https://servicos.cisp.com.br/v1/sintegra/" + alltrim(M->ZX_CGC)
   cUrlreceita  := "https://api.maxxi.cisp.com.br/public-bases/v1/receita-federal/cnpj/"+ alltrim(M->ZX_CGC) + "?key=dwnljGS5DRJ0BkzGGgRsrNZCUxqdqrZw" //"https://servicos.cisp.com.br/v1/receita-federal/" + alltrim(M->ZX_CGC)
   cUrlsimples  := "https://api.maxxi.cisp.com.br/public-bases/v1/simples-nacional/cnpj/"+ alltrim(M->ZX_CGC) + "?key=dwnljGS5DRJ0BkzGGgRsrNZCUxqdqrZw" //"https://servicos.cisp.com.br/v1/simples-nacional/" + alltrim(M->ZX_CGC)
Else 
   //====================================================================
   // Link base homologa��o
   //====================================================================
   cUrlsintegra := "https://api-homol.maxxi.cisp.com.br/public-bases/v1/sintegra/cnpj/"+ Alltrim(M->ZX_CGC)+"/uf/"+AllTrim(M->ZX_EST)+"?key=43c629ff-e72e-4172-a0fe-ffdef386573a" //"https://servicos.cisp.com.br/v1/sintegra/" + alltrim(M->ZX_CGC)
   cUrlreceita  := "https://api-homol.maxxi.cisp.com.br/public-bases/v1/receita-federal/cnpj/"+ alltrim(M->ZX_CGC) + "?key=43c629ff-e72e-4172-a0fe-ffdef386573a" //"https://servicos.cisp.com.br/v1/receita-federal/" + alltrim(M->ZX_CGC)
   cUrlsimples  := "https://api-homol.maxxi.cisp.com.br/public-bases/v1/simples-nacional/cnpj/"+ alltrim(M->ZX_CGC) + "?key=43c629ff-e72e-4172-a0fe-ffdef386573a" //"https://servicos.cisp.com.br/v1/simples-nacional/" + alltrim(M->ZX_CGC)
EndIf 

//S� atualiza pessoas juridicas
If (M->ZX_PESSOA == "F")

    If _natua == 2
    	u_itmsg("N�o atualiza pessoa f�sica via Cisp","Aten��o",,1)
    Endif

    M->ZX_I_SITRF := " "
    M->ZX_I_DTSRF := " "
  
    M->ZX_SITST := " "
    M->ZX_DTST  := " "

    Return
    
Endif

//========================================
// Consultando CISP
//========================================
aHeadOut := {}
aAdd( aHeadOut , "Authorization: Basic "+Encode64(_cuser + ":" + _cpasswd ) )
_cNome   := ""
_cNReduz := ""

//Faz chamada ao webservice do cisp
CHdcisp  := ""
cCorcisp := HttpGet(cUrlcisp,"",NIL,aHeadOut,@cHdcisp)

//======================================================
// Descriptografia do JSon Recebido
//======================================================
_cDecodeTxt := ""
If ! Empty(cCorcisp)
	_cDecodeTxt := DecodeUTF8(cCorcisp, "cp1252")   
EndIf 

If ! Empty(_cDecodeTxt)
	cCorcisp := _cDecodeTxt
EndIf 

// Remover caracteres especiais do JSON.
cCorcisp := U_ITSUBCHR(cCorcisp, {{"*",""},{"$",""}})

_ocisp   := nil
_acisp := strtokarr(cHdcisp,chr(10))

//Verifica e formata resposta do cisp
If substr(cHdcisp,1,15) == "HTTP/1.1 200 OK" .and. FWJsonDeserialize(cCorcisp,@_ocisp)
   _cNome   := _ocisp:cliente:razaosocial
   _cNReduz := _ocisp:cliente:nomefantasia
EndIf 


//====================================================
// Consultando Sintegra
//====================================================
//Define usu�rio e password
aAdd( aHeadOut , "accept:application/json")

IF valtype(oproc) = "O"

   	oproc:cCaption := ("Consultando Sintegra...")
	ProcessMessages()
 
ENDIF

//====================================
// >> Obtem os dados Link Sintegra. <<
//====================================

//Faz chamada ao webservice do Sintegra
cCorSintegra  := HttpGet(cUrlsintegra,"",NIL,aHeadOut,@cHdSintegra)

//======================================================
// Descriptografia do JSon Recebido
//======================================================
_cDecodeTxt := ""
If ! Empty(cCorSintegra)
	_cDecodeTxt := DecodeUTF8(cCorSintegra, "cp1252")   
EndIf 

If ! Empty(_cDecodeTxt)
	cCorSintegra := _cDecodeTxt
EndIf 

// Remover caracteres especiais do JSON.
cCorSintegra := U_ITSUBCHR(cCorSintegra, {{"*",""},{"$",""}})

If Empty(cCorSintegra)
   If _natua == 2
   	  U_ItMsg("[AOMS014] - Falha na consulta do Sintegra.","Aten��o",,1)
   Else 
      ConOut("[AOMS014] - Falha na consulta do Sintegra.") 
   Endif

   M->ZX_I_SITRF := " "
   M->ZX_I_DTSRF := " "
  
   M->ZX_SITST := " "
   M->ZX_DTST  := " "

   Return
EndIf 

If !(substr(cHdSintegra,1,12) == "HTTP/1.1 200")
   If _natua == 2
   	  U_ItMsg("[AOMS014] - Falha na consulta do Sintegra: [ " + AllTrim(cCorSintegra) + " ]","Aten��o",,1)
   Else 
      ConOut("[AOMS014] - Falha na consulta do Sintegra: [" + AllTrim(cCorSintegra) + " ]") 
   Endif

   M->ZX_I_SITRF := " "
   M->ZX_I_DTSRF := " "
  
   M->ZX_SITST := " "
   M->ZX_DTST  := " "

   Return

EndIf 

_lisento := .F.

_oJson := JsonObject():new()

_cRet := _oJson:FromJson(cCorSintegra)

//Verifica e formata resposta do Sintegra 

If ! (ValType(_cRet) == "U") //!(substr(cHdSintegra,1,12) == "HTTP/1.1 200" .and. (ValType(_cRet) == "U")) //FWJsonDeserialize(cCorSintegra,@_osintegra) .and. !Empty(_osintegra))
    
    If alltrim(M->ZX_INSCR) == "ISENTO" .OR. alltrim(M->ZX_INSCR) == "ISENTA"
    	_lisento := .T.
		Return
    Else
       If _natua == 2
       	  U_Itmsg("Falha no webservice do sintegra, consulta n�o foi completada","Aten��o",cHdSintegra,1)
 
    	  M->ZX_I_SITRF := " "
    	  M->ZX_I_DTSRF := " "
  
   	      M->ZX_SITST := " "
   	      M->ZX_DTST  := " "
    	  
    	  Return
       EndIf
    
      _lret := .F.
      _lerro := .T.
      _cerro := cHdSintegra
    
      Return
    
    Endif

Endif

_aNames := _oJson:GetNames()

_cTipoDocs := ""
_cNrDocs := ""
_cNomeSint := ""
_cNomeRSit := ""

_osintegra := _oJson:GetJsonObject("company")
If (ValType(_osintegra) == "A" .Or. ValType(_osintegra) == "J") .And. ! Empty(_osintegra)
   _osintegra := _osintegra[1]

//---------------------------------------------------
   _aCompany := _osintegra:GetNames() 
   _nI := Ascan(_aCompany, "registeredName" )
   If _nI > 0
      _cNomeSint := _osintegra[_aCompany[_nI]]
   EndIf 

   _nI := Ascan(_aCompany, "name" )
   If _nI > 0
      _cNomeRSit := _osintegra[_aCompany[_nI]]
   EndIf 
//---------------------------------------------------

   _nI := Ascan(_aNames, "updateDate" )
   If _nI > 0
      _cDtAlter := _oJson[_aNames[_nI]]
   EndIf 

   _oDoctos := _osintegra:GetJsonObject("documents") 
   _oDoctos := _oDoctos[1]

   _aNameDocs := _oDoctos:GetNames()

   _nI := Ascan(_aNameDocs ,"type" )
   _cTipoDocs := ""

   If _nI > 0
      _cTipoDocs := _oDoctos[_aNameDocs[_nI]]	  
   EndIf 

   _nI := Ascan(_aNameDocs ,"value" )
   _cNrDocs := ""

   If _nI > 0
      _cNrDocs := _oDoctos[_aNameDocs[_nI]]	
      _cNrDocs := StrTran(_cNrDocs,".","")  
   EndIf 

   If Empty(_cNrDocs)
      _cNrDocs := "ISENTO"
   EndIf 
EndIf 

IF valtype(oproc) = "O"

      	oproc:cCaption := ("Consultando Receita...")
   		ProcessMessages()
 
ENDIF

//===========================================
// >> Obtem os dados Link Receita Federal. <<
//===========================================

//Faz chamada ao webservce da Receita
cCorReceita  := HttpGet(cUrlReceita,"",NIL,aHeadOut,@cHdReceita)

//======================================================
// Descriptografia do JSon Recebido
//======================================================
_cDecodeTxt := ""
If ! Empty(cCorReceita)
	_cDecodeTxt := DecodeUTF8(cCorReceita, "cp1252")   
EndIf 

If ! Empty(_cDecodeTxt)
	cCorReceita := _cDecodeTxt
EndIf 

// Remover caracteres especiais do JSON.
cCorReceita := U_ITSUBCHR(cCorReceita, {{"*",""},{"$",""}})

If Empty(cCorReceita)
   If _natua == 2
   	  U_ItMsg("[AOMS014] - Falha na consulta da Receita Federal.","Aten��o",,1)
   Else 
      ConOut("[AOMS014] - Falha na consulta da Receita Federal.") 
   Endif

   M->ZX_I_SITRF := " "
   M->ZX_I_DTSRF := " "
  
   M->ZX_SITST := " "
   M->ZX_DTST  := " "

   Return
EndIf 

If !(substr(cHdReceita,1,12) == "HTTP/1.1 200")
   
   If _natua == 2
   	  U_ItMsg("[AOMS014] - Falha na consulta da Receita Federal: ["+AllTrim(cHdReceita)+"]","Aten��o",,1)
   Else 
      ConOut("[AOMS014] - Falha na consulta da Receita Federal: [ "+AllTrim(cHdReceita)+" ]") 
   Endif

   M->ZX_I_SITRF := " "
   M->ZX_I_DTSRF := " "
  
   M->ZX_SITST := " "
   M->ZX_DTST  := " "

   Return


EndIf 

_lerrorec    := .F. 

_oJsonRec   := JsonObject():new()

_cRetRec := _oJsonRec:FromJson(cCorReceita) // FromJson(cCorSintegra)

// Verifica e formata resposta da Receita

If ! (ValType(_cRetRec) == "U") //!(substr(cHdReceita,1,12) == "HTTP/1.1 200" .and. (ValType(_cRetRec) == "U"))
     
    If _lisento //Se � isento e n�o achou na receita n�o atualiza 
    
       _lret := .F.
       _lerro := .T.
       _cerro := cHdReceita
       
       	If _natua == 2
  	
       		u_itmsg("Falha no webservice da receita, n�o h� dados para atualizar","Aten��o",cHdReceita,1)
       		
       		M->ZX_I_SITRF := " "
       		M->ZX_I_DTSRF := " "
  
       		M->ZX_SITST := " "
       		M->ZX_DTST  := " "
       		
       		Return
  		  		
  		Endif
     	
    Else //Se n�o � isento usa os dados do sintegra no lugar dos dados da receita
    
    	_cReceita := _osintegra[1]
    	_lerrorec := .T.
    	
    	If _natua == 2
  	
       		u_itmsg("Falha no webservice da receita, usando somente dados do sintegra","Aten��o",cHdReceita,1)
  		  		
  		Endif
    	
    
    Endif

Endif

_aNamesRec := _oJsonRec:GetNames()

_oReceita  := _oJsonRec:GetJsonObject("company")
_oReceita  := _oReceita[1]
_aNameComp := _oReceita:GetNames()

_cDtCriac := _oReceita:GetJsonObject("openingDate")

//===========================================================
// Se a raz�o social e nome reduzido estverem
// vazios, devem ser lidos da receita-federal.
// Pois n�o existem na CISP.
//===========================================================
If Empty(_cNome)
   _cNome := _oReceita:GetJsonObject("registeredName")
EndIf 

If Empty(_cNReduz)
   _cNReduz := _oReceita:GetJsonObject("name")
EndIf 

If SubStr(AllTrim(_cNReduz),1,1) == "*"
   _cNReduz := SubStr(_cNome,1,20) 
EndIf 
//===========================================================

_oRegSit   := _oReceita:GetJsonObject("register")
_aNameReg  := _oRegSit:GetNames()

_nI := Ascan(_aNameReg, "status" )

If _nI > 0
   _cSituacRg := _oRegSit[_aNameReg[_nI]]
EndIf  

If Empty(_cDtCriac) 
   _nI := Ascan(_aNameReg, "date" )

   If _nI > 0
      _cDtCriac := _oRegSit[_aNameReg[_nI]]
   EndIf  

EndIf

_nI := Ascan(_aNamesRec, "updateDate" )
If _nI > 0
   _cDtAltRec := _oJsonRec[_aNamesRec[_nI]]
EndIf 

_oDoctosR := _oJsonRec:GetJsonObject("document")

_oBusiness := _oReceita:GetJsonObject("business")

_cCodNegoc   := ""
_cDesecNegoc := ""

If ValType(_oBusiness) <> "U"
   
   _oIndustri := _oBusiness:GetJsonObject("industries")

   For _nI := 1 To Len(_oIndustri)

       _aIndAtiva := _oIndustri[_nI]
	   _lIndAtiva := _oIndustri[_nI]:GetJsonObject("main")
	   If _lIndAtiva 
	      _cCodNegoc := _oIndustri[_nI]:GetJsonObject("code")
          _cDesecNegoc := _oIndustri[_nI]:GetJsonObject("description")
       EndIf 

   Next 

EndIf 

If _lisento  //Se � isento iguala dados da receita para sintegra
  
 	_CSINTEGRA := _oReceita
  	_CRECEITA := _oReceita
 
  	_asintegra := strtokarr(cHdReceita,chr(10))
  	_areceita := strtokarr(cHdReceita,chr(10))

   _aNameRece := _CRECEITA:GetNames()
  
   _oRegSit := _CRECEITA:GetJsonObject("register")
   _aNameReg  := _oRegSit:GetNames()

   _nI := Ascan(_aNameReg, "status" )

   If _nI > 0
      _cSituacRg := _oRegSit[_aNameReg[_nI]]
   EndIf  

   _cDtAltRec := ""

   _nI := Ascan(_aNamesRec, "updateDate" )
   If _nI > 0
      _cDtAltRec := _oJsonRec[_aNamesRec[_nI]]
   EndIf 

   _CRECSIT := _cSituacRg // _CRECEITA:situacaoCadastral 
   _CRECATU := _cDtAltRec // _CRECEITA:dataAtualizacao 
   _CRECCON := Dtoc(Date())     // _CRECEITA:dataConsulta 
  
Else
     
    _cinsco := M->ZX_INSCR 
    //Analisa resposta do sintegra e pega consulta habilitada igual � IE atual ou se n�o tiver pega �ltima consulta habilitada 
    _csintegra := _osintegra // _osintegra[1]
    if _lerrorec
    	_CRECEITA := _csintegra
    Else
    	_CRECEITA := _oReceita
    Endif

    _dmaior := Date() 

   _oRegSit := _CRECEITA:GetJsonObject("register")
   _aNameReg  := _oRegSit:GetNames()

   _nI := Ascan(_aNameReg, "status" )

   If _nI > 0
      _cSituacRg := _oRegSit[_aNameReg[_nI]]
   EndIf  

   _csitmaior := Upper(_cSituacRg) 
   _nia := 0

Endif

//=====================================================
// Obtem o endere�o do Sintegra.
//=====================================================
If ValType(_CSINTEGRA) == "O" .Or. ValType(_CSINTEGRA) == "J"
   _aNameSint := _CSINTEGRA:GetNames()

   _nI := Ascan(_aNameSint ,"address" )
   _cEndSint := ""

   If _nI > 0
      _cEndSint := _CSINTEGRA[_aNameSint[_nI]]	  
   EndIf 

   If _nI > 0
      _oEndSint := _cEndSint:GetJsonObject("state")
      _cUfSint  := _oEndSint:GetJsonObject("code")
      
      _cRua     := _cEndSint:GetJsonObject("line1")
      _cNumero  := _cEndSint:GetJsonObject("line2")
      _cCidade  := _cEndSint:GetJsonObject("city")
      _cCep     := _cEndSint:GetJsonObject("postalCode")
      _cComplem := _cEndSint:GetJsonObject("extension")
      _cBairro  := _cEndSint:GetJsonObject("district")
   EndIf 
EndIf 

//=====================================================
// Obtem o endere�o do CISP Receita Federal
//=====================================================
_aNameRece := _CRECEITA:GetNames()

_nI := Ascan(_aNameRece ,"address" )
_cEndRece := ""

If _nI > 0
   _cEndRece := _CRECEITA[_aNameRece[_nI]]	  
EndIf 

_oEndRece := _cEndRece:GetJsonObject("state")
_cUfRece  := _oEndRece:GetJsonObject("code")

If ! Empty(_cEndRece:GetJsonObject("line1"))
   _cRua     := _cEndRece:GetJsonObject("line1")
EndIf 

If ! Empty(_cEndRece:GetJsonObject("line2"))
   _cNumero  := _cEndRece:GetJsonObject("line2")
EndIf 

If ! Empty(_cEndRece:GetJsonObject("city"))
   _cCidade  := _cEndRece:GetJsonObject("city")
EndIf 

If ! Empty(_cEndRece:GetJsonObject("postalCode"))
   _cCep     := _cEndRece:GetJsonObject("postalCode")
EndIf 

If ! Empty(_cEndRece:GetJsonObject("extension"))
   _cComplem := _cEndRece:GetJsonObject("extension")
EndIf 

If ! Empty(_cEndRece:GetJsonObject("district"))
   _cBairro  := _cEndRece:GetJsonObject("district")
EndIf 

//Verifica se estado informado pela receita � igual ao informado pelo Sintegra
/* Valida��o desnecess�ria. Remover conforme solicita��o do Agnaldo.
If _cUfSint <> _cUfRece // alltrim(_CSINTEGRA:uf) != alltrim(_CRECEITA:uf) 
  
  	U_Itmsg("UF indicada pelo Sintegra diverge da indicada pela Receita, consulta n�o ser� aplicada!","Aten��o",,1)
  	M->ZX_INSCR := _cinsco
  	Return
  	
EndIf  
*/

_cRegiSint := ""
_cSituSint := ""

If Type("_aNameSint") == "A"
   _nI := Ascan(_aNameSint ,{|x| x=="register"})

   If _nI > 0
      _cRegiSint := _CSINTEGRA[_aNameSint[_nI]]	  
      _cSituSint := _cRegiSint:GetJsonObject("status")
   EndIf 
EndIf 

_nI := Ascan(_aNameRece ,{|x| x=="register"})
_cRegiRece := ""
_cSituRece := ""

If _nI > 0
   //_cRegiRece := _CSINTEGRA[_aNameRece[_nI]]
   _cRegiRece := _CRECEITA[_aNameRece[_nI]]	  
   _cSituRece := _cRegiRece:GetJsonObject("status")
EndIf 

_CSITSINTEGRA := Upper(_cSituSint) // alltrim(_CSINTEGRA:situacaoCadastral)
_CRECSIT      := Upper(_cSituRece) // CRECEITA:situacaoCadastral
  
If  !(_CSITSINTEGRA == "HABILITADO" .OR. _CSITSINTEGRA == "HABILITADA" .OR. _CSITSINTEGRA == "ATIVO" .OR. _CSITSINTEGRA == "ATIVA" .OR.;
			_CSITSINTEGRA == "ATIVO - HABILITADO" .OR. _CSITSINTEGRA == "HABILITADO - ATIVO");
			.OR. !(AllTrim(_CRECSIT) == "HABILITADO" .OR. AllTrim(_CRECSIT) == "HABILITADA" .Or. alltrim(_CRECSIT) == "ATIVA" .Or.  alltrim(_CRECSIT) == "ATIVO" ;
			.OR. !AllTrim(_CRECSIT) == "ATIVO - HABILITADO" .OR. !AllTrim(_CRECSIT) == "HABILITADO - ATIVO" .OR. alltrim(_CRECSIT) == "ERRO DE CONSULTA")
  	                                    
  		U_ITMSG("Existem restri��es de cadastro no Sintegra e/ou Receita, consulta n�o ser� aplicada","Aten��o",,1)
  		M->ZX_INSCR := _cinsco
  		Return
Else 
   _CRECSIT := "ATIVA" // Este campo tem dez posi��es. Para n�o gravar conte�do truncado. Por exempo: "ATIVO - HA" ou "ATIVA - HA"
Endif
  
If !empty(alltrim(M->ZX_INSCR))
  
  	M->ZX_CONTRIB := "1"
  	
Endif

//=====================================================================
// Se a raz�o social da CISP-Receita estiver vazio, e do CISP-SINTEGRA 
// estiver vazio, pegar do CISP SINTEGRA.
//=====================================================================
If Empty(_cNome) .And. ! Empty(_cNomeSint)
   _cNome := _cNomeSint 
EndIf 

//=====================================================================
// Se o Nome Fantasia da CISP-Receita estiver vazio, e do CISP-SINTEGRA 
// estiver vazio, pegar do CISP SINTEGRA.
//=====================================================================
If Empty(_cNReduz) .And. ! Empty(_cNomeRSit)
   _cNReduz := _cNomeRSit
EndIf 

//=====================================================================
If !Empty(_cNome)
   M->ZX_NOME := _cNome 
EndIf 

If ! Empty(_cNReduz)
   M->ZX_NREDUZ := _cNReduz 
EndIf 

/*
_nI := Ascan(_aNameSint ,{|x| x=="registeredName"})

If _nI > 0
   M->ZX_NOME := _CSINTEGRA[_aNameSint[_nI]]
EndIf 

If !Empty( _cRegiSint:GetJsonObject("name"))
  	M->ZX_NREDUZ := _cRegiSint:GetJsonObject("name") // _CRECEITA:nomeFantasia
EndIf
*/

//_nI := Ascan(_aNameSint ,{|x| x=="address"})
//If _nI > 0
//   _oEndSint  := _CSINTEGRA[_aNameSint[_nI]] // _cRegiSint:GetJsonObject("address")
//EndIf 

If ! Empty( _cDtCriac )
    _cDtCriac := StrTran( _cDtCriac,"-","")
EndIf 

//If Empty(_cNrDocs)
//   _cNrDocs := 'ISENTO'
//EndIf

M->ZX_PAIS  := '105'

If ! Empty(_cNrDocs)
   M->ZX_INSCR := _cNrDocs  // iif("inscricaoEstadual" $ cCorSintegra,alltrim(_CSINTEGRA:inscricaoEstadual),"ISENTO")
EndIf 

If ! Empty(_cDtCriac)
   M->ZX_DTNASC := Stod(_cDtCriac)  // stod(substr(alltrim(_CRECEITA:dataAbertura),1,4)+substr(alltrim(_CRECEITA:dataAbertura),6,2)+substr(alltrim(_CRECEITA:dataAbertura),9,2))
EndIf 

If ! Empty(_cCodNegoc)
   //Valida se j� tem cnae no CC3 e se n�o tiver inclui
   _ccnae := AllTrim(_cCodNegoc) // alltrim(_CRECEITA:codigoAtividadeFiscal)
   _ccnae := substr(_ccnae,1,2) + substr(_ccnae,4,4) + "/" + substr(_ccnae,9,2) 
   CC3->(Dbsetorder(1))

   If !empty(_ccnae) .and. !(CC3->(Dbseek(xfilial("CC3")+_ccnae)))
  
  	  CC3->(Reclock("CC3",.T.))
  	  CC3->CC3_COD := _ccnae
  	  CC3->CC3_DESC := _cDesecNegoc // ALLTRIM(_CRECEITA:descricaoAtividadeFiscal)
  	  CC3->(Msunlock())
  	
   EndIf
 
   If ! Empty(_ccnae)
      M->ZX_I_END := _ccnae 
      M->ZX_I_DCNAE := _cDesecNegoc 
   EndIf

EndIf 

//--------------------------------------------
//_cUfRece  := _oEndRece:GetJsonObject("code")
//--------------------
//_cRua     := _cEndRece:GetJsonObject("line1")
//_cNumero  := _cEndRece:GetJsonObject("line2")
//_cCidade  := _cEndRece:GetJsonObject("city")
//_cCep     := _cEndRece:GetJsonObject("postalcode")
//_cComplem := _cEndRece:GetJsonObject("extension")
//_cBairro  := _cEndRece:GetJsonObject("district")
//--------------------------------------------

If Empty(_cUfRece) .And. ! Empty(_cUfSint)
   _cUfRece := _cUfSint
EndIf 

If !Empty(_cComplem) .And. !AllTrim(SubStr(_cComplem,1,1)) $ "*"
   _cComplem := ""
EndIf 

If empty(alltrim(_cNumero)) .and. empty(alltrim(_cComplem))
   If ! Empty(_cRua)
      M->ZX_END :=  alltrim(_cRua) // _CSINTEGRA:endereco
   EndIf 
Else 
   If ! Empty(_cRua)
      M->ZX_END := ALLTRIM(alltrim(_cRua) + ", " + alltrim(_cNumero)+ " " + alltrim(_cComplem))
   EndIf 
Endif
  
If ! empty(alltrim(_cBairro)) // empty(alltrim(_CSINTEGRA:bairro))
   M->ZX_BAIRRO := _cBairro // alltrim(_CSINTEGRA:bairro)
Endif
  
If !(alltrim(_cCep) == '99999999' .or. alltrim(_cCep) == '00000000')

  		//Testa se existe o Cep e se n�o tiver j� inclui
  		ZA5->(Dbsetorder(1))
  		If ! (ZA5->(Dbseek(xfilial("ZA5")+alltrim(_cCep)))) //(ZA5->(Dbseek(xfilial("ZA5")+alltrim(strzero(_CSINTEGRA:cep,8)))))
  		
  			//Separa tipo de logradouro de logradouro
  			_endere := alltrim(_cRua) //alltrim(_CSINTEGRA:endereco)
  			_ctiplog := ""
  			_clog := ""
  			_nposi := 1  //_cRua 
  			For _nnj := 1 to len(alltrim(_cRua)) // len(alltrim(_CSINTEGRA:endereco))
  			
  				If substr(_endere,_nnj,1) == " " .and. _nposi == 1
  					_nposi := 2
  				Elseif _nposi == 1
  					_ctiplog += substr(_endere,_nnj,1)
  				Elseif _nposi == 2
  					_clog += substr(_endere,_nnj,1)
  				Endif 					
  			
  			Next
  		
  			ZA5->(Reclock("ZA5",.T.))
  			ZA5->ZA5_UF := _cUfRece // alltrim(_CRECEITA:uf)
  			ZA5->ZA5_CEP := AllTrim(_cCep) // alltrim(strzero(_CSINTEGRA:cep,8))
  			ZA5->ZA5_TPLOG := _ctiplog
  			ZA5->ZA5_LOGRAD := _clog
  			ZA5->ZA5_BAIRRO := AllTrim(_cBairro) // alltrim(_CSINTEGRA:bairro) 			
  			ZA5->(Msunlock())
  			
  		Endif

	  	If ! Empty(_cCep)	
  		   M->ZX_CEP := AllTrim(_cCep) // alltrim(strzero(_CSINTEGRA:cep,8))
		EndIf 
  	  			
Endif

If ! Empty(_cUfRece)  
   M->ZX_EST := AllTrim(_cUfRece) // alltrim(_CRECEITA:uf)
EndIf 

_CMUN := POSICIONE("CC2",4,xfilial("CC2")+M->ZX_EST+alltrim(_cCidade),"CC2_CODMUN")
If !empty(alltrim(_cCidade)) .AND. !EMPTY(alltrim(_cmun))
   M->ZX_MUN := AllTrim(_cCidade) // alltrim(_CSINTEGRA:cidade)
   M->ZX_CODMUN := _cmun
Endif

If ! Empty(_CRECSIT)   
   M->ZX_I_SITRF := _CRECSIT
EndIf

M->ZX_I_DTSRF := dtoc(DATE())

If ! Empty(_cSituacRg)
   M->ZX_SITST := AllTrim(_cSituacRg) // alltrim(_CSINTEGRA:situacaoCadastral) 
EndIf 

M->ZX_DTST  := dtoc(DATE())

//===============================================================================================================
//Consulta ao sistema Simpes Nacional
//===============================================================================================================

IF valtype(oproc) = "O"
   oproc:cCaption := ("Consultando Simples...")
   ProcessMessages()
ENDIF

//============================================
// >> Obtem os dados Link Simples Nacional. <<
//============================================

//Faz chamada ao webservice do Simples
CHdSimples  := ""
cCorSimples := HttpGet(cUrlsimples,"",NIL,aHeadOut,@cHdSimples)

//======================================================
// Descriptografia do JSon Recebido
//======================================================
_cDecodeTxt := ""
If ! Empty(cCorSimples)
	_cDecodeTxt := DecodeUTF8(cCorSimples, "cp1252")   
EndIf 

If ! Empty(_cDecodeTxt)
	cCorSimples := _cDecodeTxt
EndIf 

// Remover caracteres especiais do JSON.
cCorSimples := U_ITSUBCHR(cCorSimples, {{"*",""},{"$",""}})

_osimples   := nil

If ! Empty(cCorSimples)

   _oJsonSimp  := JsonObject():new()

   _cRetSimpl := _oJsonSimp:FromJson(cCorSimples) 

   _cSimpNcOp := ""
   _cSimplOpt := ""

   If ValType(_cRetSimpl) == "U"
      _aNamesSip := _oJsonSimp:GetNames()

      _oSimplNac := _oJsonSimp:GetJsonObject("company")
      If ValType(_oSimplNac) == "J" .Or. ValType(_oSimplNac) == "A"
	     If Len(_oSimplNac) > 0 
            _oSimplNac := _oSimplNac[1]     
            _cSimplNac := _oSimplNac:GetJsonObject("business")
            _cSimplOpt := _cSimplNac:GetJsonObject("taxSystem")
            _cSimpNcOp := _cSimplOpt:GetJsonObject("statusSimplesNacional")
		 Else 
            _cSimpNcOp := "NAO OPTANTE" // JSON RETORNADO SEM INFORMA��ES.      
		 EndIf 
      EndIf
   EndIf

   If ! Empty(_cSimpNcOp)
      _cSimpNcOp := Upper(_cSimpNcOp)
   EndIf 
EndIf 

//Verifica e formata resposta do Simples
If ! Empty(cCorSimples) .And. Substr(cHdSimples,1,12) == "HTTP/1.1 200" .and. ValType(_cRetSimpl) == "U" //FWJsonDeserialize(cCorSimples,@_osimples) 
   If type("_cSimpNcOp") == "C" .and. substr(alltrim(_cSimpNcOp),1, 7) == "OPTANTE"
	  _catusimples := '1'
   Else
   	  _catusimples := '2'
   Endif
Else
   _catusimples := '2'
Endif
  	  		
M->ZX_SIMPNAC := _catusimples
  
//Grava��o de defaults nos campos mais usados
If empty(M->ZX_I_RISCO)
   M->ZX_I_RISCO := "B"
Endif

If empty(M->ZX_I_GRPVE)
   M->ZX_I_GRPVE  := '999999'
Endif

If u_itgetmv("ITDTPROS","1225") >= SUBSTR(DTOS(DATE()),5,4)
   If empty(M->ZX_I_VENCL)
	  M->ZX_I_VENCL := stod(substr(dtos(date()),1,4)+"1231")
   Endif
Else
   If empty(M->ZX_I_VENCL)
	  M->ZX_I_VENCL := stod(substr(dtos(date()+365),1,4)+"1231")
   Endif
Endif   
  
Return 

/*
===============================================================================================================================
Programa----------: AOMS014K
Autor-------------: Josu� Danich
Data da Criacao---: 16/04/2013
Descri��o---------: Consulta Cisp via browse
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User function AOMS014K()

Local oproc

If empty(ALLTRIM(SZX->ZX_SITST)) .OR. Empty(SZX->ZX_END) 

   If u_itmsg("Atualiza prospect com dados de consulta Cisp?","Aten��o",,2,2,2)
	
      regtomemory("SZX")
      fwmsgrun(,{|oproc| U_AOMS014B(2,oproc)},"Aguarde...","Aguarde")
		
      //Grava altera��o
      u_itmemtor("SZX")

	  U_ItMsg("Atualiza��o do Prospect com os dados da Cisp conclu�do.","Aten��o",,2)
		
   EndIf
	
Else

	u_itmsg("Registro j� foi atualizado via Cisp","Aten��o",,1)

Endif

Return

/*
===============================================================================================================================
Programa----------: AOMS014C
Autor-------------: Josu� Danich
Data da Criacao---: 16/04/2013
Descri��o---------: Consulta Cisp via browse
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS014C()

	fwmsgrun(,{ || U_TelCred(1)}, "Aguarde...","Realizando consulta Cisp...")

Return

/*
===============================================================================================================================
Programa----------: AOMS014V
Autor-------------: Josu� Danich
Data da Criacao---: 29/08/2018
Descri��o---------: Valida se cnpj j� est� cadastrado na base
Parametros--------: _ccnpj - cnpj a ser testado
Retorno-----------: _lret - valida��o de exist�ncia
===============================================================================================================================
*/
Static Function AOMS014V(_ccnpj)

Local _lret := .F.

SA1->(Dbsetorder(3))
If SA1->(Dbseek(xfilial("SA1")+alltrim(_ccnpj)))

	_lret := .T.
	u_itmsg("CNPJ j� est� cadastrado como cliente!","Aten��o","Cliente: " + SA1->A1_COD + "/" + SA1->A1_LOJA + " - " + SA1->A1_NOME,1)
	
Endif

Return _lret

/*
===============================================================================================================================
Programa----------: AOMS014D
Autor-------------: Julio de Paula Paz
Data da Criacao---: 04/09/2019
Descri��o---------: Fun��o respons�vel por exibir a janela para a digita��o dos endere�os de email, assunto, mensagem
Parametros--------: _cAnexo		- Endere�o do arquivo anexo
------------------: _cEmail		- Endere�o de E-mail para qual ser� enviado a mensagem
------------------: _cCc		- Endere�o de E-mail que est� no campo Com C�pia
------------------: _cAssunto	- Assunto do E-mail
------------------: _cMens		- Mensagem de texto para o corpo do E-mail
------------------: cMailCom    - Email de remetente
Retorno-----------: _lRet == .T. = E-mail enviado
                             .F. = Envio de E-mail cancelado.
===============================================================================================================================
*/
User Function AOMS014D(_cAnexo,_cEmail,_cCc,_cAssunto,_cMens,cMailCom)

Local oAssunto
Local oButCan
Local oButEnv
Local oCc

Local oGetAssun
Local oGetCc

Local oGetPara
Local oMens
Local oPara

Local _csetor := ""

Local _aConfig	:= U_ITCFGEML('')
Local _cEmlLog	:= ""
Local cHtml		:= ""
Local nOpcA		:= 2

Local cGetAssun	:= _cAssunto
Local cGetCc	:= _cCc
Local cGetPara	:= _cEmail + Space(80)
Local _lRet     := .F.

Private oDlgMail , _oFont


If (Len(PswRet()) # 0) // Quando nao for rotina automatica do configurador

	_csetor	:= AllTrim(PswRet()[1][12])		// Pega departamento do usuario
   
Endif


If empty(alltrim(_csetor))
 
 	_csetor := "Cr�dito"
 	
Endif

cHtml := 'Prezados(as), '
cHtml += '<br><br>'
cHtml += 'Pedimos a gentileza de enviar-nos as solicita��es abaixo: <br>'
cHtml += '<br><br>'
cHtml += '<table>'
cHtml += '   <tr>'
cHtml += '     <td> Cliente:</th>'
cHtml += '     <td>' + AllTrim(SZX->ZX_NOME) + '</th>'
cHtml += '   </tr>'
cHtml += '   <tr>'
cHtml += '     <td> CNPJ: </td>'
cHtml += '     <td> ' + Transform(SZX->ZX_CGC,"@R! NN.NNN.NNN/NNNN-99") + '</td>'
cHtml += '   </tr>'
cHtml += '   <tr>'
cHtml += '     <td> Municipio: </td>'
cHtml += '     <td> ' + RETFIELD("CC2",1,XFILIAL("CC2")+SZX->ZX_EST+SZX->ZX_CODMUN,"CC2_MUN") + '</td>'
cHtml += '   </tr>'
cHtml += '   <tr>'
cHtml += '     <td> Estado: </td>'
cHtml += '     <td> ' + SZX->ZX_EST + '</td>'
cHtml += '   </tr>'
cHtml += '   <tr>'
cHtml += '     <td> DDD: </td>'
cHtml += '     <td> ' + SZX->ZX_DDD + '</td>'
cHtml += '   </tr>'
cHtml += '   <tr>'
cHtml += '     <td> Telefone: </td>'
cHtml += '     <td> ' + SZX->ZX_TEL + '</td>'
cHtml += '   </tr>'
cHtml += '   <tr>'
cHtml += '     <td> E-mail: </td>'
cHtml += '     <td> ' + SZX->ZX_EMAIL + '</td>'
cHtml += '   </tr>'
cHtml += '</table> 
cHtml += '<br><br>'
cHtml += 'Sem mais e a disposi��o.'
cHtml += '<br><br>'

cHtml += '<table class=MsoNormalTable border=0 cellpadding=0>'
cHtml += '<tr>'
cHtml +=     '<td style="padding:.75pt .75pt .75pt .75pt">'
cHtml +=         '<p class=MsoNormal align=center style="text-align:center">'
cHtml +=             '<b><span style="font-size:18.0pt;font-family:'+"'"+'Arial'+"'"+','+"'"+'sans-serif'+"'"+';color:#1D2668;mso-fareast-language:PT-BR">'+ Capital( AllTrim( UsrFullName( RetCodUsr() ) ) ) +'</span></b>'
cHtml +=             '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>
cHtml +=     '</td>'
cHtml +=     '<td style="background:#A2CFF0;padding:.75pt .75pt .75pt .75pt">&nbsp;</td>'
cHtml +=     '<td style="padding:.75pt .75pt .75pt .75pt">
cHtml +=         '<table class=MsoNormalTable border=0 cellpadding=0>'
cHtml +=              '<tr>'
cHtml +=                  '<td style="padding:.75pt .75pt .75pt .75pt">'
cHtml +=                      '<p class=MsoNormal><b><span style="font-size:13.5pt;font-family:'+"'"+'Arial'+"'"+','+"'"+'sans-serif'+"'"+';color:#6FB4E3;mso-fareast-language:PT-BR">' + _cSetor + '</span></b>'
cHtml +=                      '<b><span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></b>
cHtml +=                      '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"><br></span>
cHtml +=                      '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>
cHtml +=                  '</td>'
cHtml +=              '</tr>'
cHtml +=              '<tr>'
cHtml +=                  '<td style="padding:.75pt .75pt .75pt .75pt">
cHtml +=                      '<p class=MsoNormal><span style="font-size:12.0pt;font-family:'+"'"+'Arial'+"'"+','+"'"+'sans-serif'+"'"+';color:#1D2668;mso-fareast-language:PT-BR">Tel: ' + Posicione("SY1",3,xFilial("SY1") + RetCodUsr(),"Y1_TEL") + '</span>'
cHtml +=                      '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>
cHtml +=                  '</td>'
cHtml +=              '</tr>'
cHtml +=         '</table>'
cHtml +=     '</td>'
cHtml += '</tr>'
cHtml += '</table>'
cHtml += '<table class=MsoNormalTable border=0 cellpadding=0 width=437 style="width:327.75pt">'
cHtml +=     '<tr>'
cHtml +=         '<td style="padding:.75pt .75pt .75pt .75pt">'
cHtml +=             '<p class=MsoNormal align=center style="text-align:center">'
cHtml +=             '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR">'
cHtml +=                 '<img width=400 height=51 src="http://www.italac.com.br/assinatura-italac/images/marcas-goiasminas-industria-de-laticinios-ltda.jpg">'
cHtml +=             '</span>
cHtml +=             '</p>'
cHtml +=         '</td>'
cHtml +=     '</tr>'
cHtml += '</table>'
cHtml += '<p class=MsoNormal><span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';display:none;mso-fareast-language:PT-BR">&nbsp;</span></p>'
cHtml += '<table class=MsoNormalTable border=0 cellpadding=0>'
cHtml +=     '<tr>'
cHtml +=         '<td style="padding:.75pt .75pt .75pt .75pt">'
cHtml +=             '<p class=MsoNormal align=center style="text-align:center">'
cHtml +=             '<b><span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';color:#1D2668;mso-fareast-language:PT-BR">Pol�tica de Privacidade </span></b>'
cHtml +=             '<span style="font-size:12.0pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>
cHtml +=             '<p class=MsoNormal style="mso-margin-top-alt:auto;mso-margin-bottom-alt:auto;text-align:justify">'
cHtml +=             '<span style="font-size:7.5pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';color:#1D2668;mso-fareast-language:PT-BR">
cHtml +=                 'Esta mensagem � destinada exclusivamente para fins profissionais, para a(s) pessoa(s) a quem for dirigida, podendo conter informa��o confidencial e legalmente privilegiada. '
cHtml +=                 'Ao receb�-la, se voc� n�o for destinat�rio desta mensagem, fica automaticamente notificado de abster-se a divulgar, copiar, distribuir, examinar ou, de qualquer forma, utilizar '
cHtml +=                 'sua informa��o, por configurar ato ilegal. Caso voc� tenha recebido esta mensagem indevidamente, solicitamos que nos retorne este e-mail, promovendo, concomitantemente sua '
cHtml +=                 'elimina��o de sua base de dados, registros ou qualquer outro sistema de controle. Fica desprovida de efic�cia e validade a mensagem que contiver v�nculos obrigacionais, expedida '
cHtml +=                 'por quem n�o detenha poderes de representa��o, bem como n�o esteja legalmente habilitado para utilizar o referido endere�o eletr�nico, configurando falta grave conforme nossa '
cHtml +=                 'pol�tica de privacidade corporativa. As informa��es nela contidas s�o de propriedade da Italac, podendo ser divulgadas apenas a quem de direito e devidamente reconhecido pela empresa.'
cHtml +=             '</span>'
cHtml +=             '<span style="font-size:7.5pt;font-family:'+"'"+'Times New Roman'+"'"+','+"'"+'serif'+"'"+';mso-fareast-language:PT-BR"></span></p>'
cHtml +=         '</td>'
cHtml +=     '</tr>
cHtml += '</table>'

DEFINE MSDIALOG oDlgMail TITLE "E-Mail" FROM 000, 000  TO 415, 584 COLORS 0, 16777215 PIXEL

	//======
	// Para:
	//======
	@ 005, 006 SAY oPara PROMPT "Para:" SIZE 015, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	@ 005, 030 MSGET oGetPara VAR cGetPara SIZE 256, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL

	//===========
	// Com c�pia:
	//===========
	@ 021, 006 SAY oCc PROMPT "Cc:" SIZE 015, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	@ 021, 030 MSGET oGetCc VAR cGetCc SIZE 256, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL

	//=========
	// Assunto:
	//=========
	@ 037, 006 SAY oAssunto PROMPT "Assunto:" SIZE 022, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	@ 037, 030 MSGET oGetAssun VAR cGetAssun SIZE 256, 010 OF oDlgMail PICTURE "@x" COLORS 0, 16777215 PIXEL

	//==========
	// Mensagem:
	//==========
	@ 069, 006 SAY oMens PROMPT "Mensagem:" SIZE 030, 007 OF oDlgMail COLORS 0, 16777215 PIXEL
	_oFont		:= TFont():New( 'Courier new' ,, 12 , .F. )
	_oScrAux	:= TSimpleEditor():New( 080 , 006 , oDlgMail , 285 , 105 ,,,,, .T. )
	_oScrAux:TextFormat(1)
	_oScrAux:Load( cHtml )
    _cHtml:=cHtml
		
	@ 189, 201 BUTTON oButEnv PROMPT "&Enviar"		SIZE 037, 012 OF oDlgMail ACTION ( nOpcA := 1 , cHtml := _oScrAux:RetText() , oDlgMail:End() ) PIXEL
	@ 189, 245 BUTTON oButCan PROMPT "&Cancelar"	SIZE 037, 012 OF oDlgMail ACTION ( nOpcA := 2 , oDlgMail:End() ) PIXEL

ACTIVATE MSDIALOG oDlgMail CENTERED

If nOpcA == 1
   If Empty(cHtml) .OR. cHtml = NIL
      cHtml:=_cHtml
   EndIf
   U_ITENVMAIL( Lower(AllTrim(UsrRetMail(RetCodUsr()))), cGetPara, cGetCc, cMailCom, cGetAssun, cHtml, , _aConfig[01], _aConfig[02], _aConfig[03], _aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )
   
   _lRet := "SUCESSO" $ UPPER(_cEmlLog)
   U_ITMSG( _cEmlLog+CHR(13)+CHR(10)+"E-mail para: "+ALLTRIM(cGetPara) , "Aten��o!" ,"CC: "+cGetCc,3 )


Else
	u_itmsg( 'Envio de e-mail cancelado pelo usu�rio.' , 'Aten��o!' , ,1 )
EndIf

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS014F
Autor-------------: Julio de Paula Paz
Data da Criacao---: 04/09/2019
Descri��o---------: Fun��o utilizada no bot�o de legenda mostrar o significado de cada cor.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS014F()

Local cCadastro:=OemToAnsi("Efetiva��o do Cadastro de Prospect")

BrwLegenda(cCadastro,"Legenda",{	{"BR_VERDE", "An�lise efetuada"},;
	                                {"BR_VERMELHO","Falta grupo de vendas,risco de cr�dito e observa��o..."},;
									{"BR_AZUL","E-mail enviado"}})

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS014G
Autor-------------: Julio de Paula Paz
Data da Criacao---: 04/09/2019
Descri��o---------: Fun��o de envio de e-mail na Efetiva��o do cadastro de prospect.
Parametros--------: Nenhum
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS014G()
Local _cEmail := ""
Local _cCC := " "
Local _cMailcom := " " 
Local _cAssunto := ""
Local _cCoord, _cGeren, _cSuper, _cEmailGer

Begin Sequence
   //Envia email de Informa��es Comerciais
   _cEmail := posicione("SA3",1,xfilial("SA3")+SZX->ZX_VEND,"A3_EMAIL") //Email do representante respons�vel pelo pedido
   _cCoord := posicione("SA3",1,xfilial("SA3")+SZX->ZX_VEND,"A3_SUPER")
   _cGeren := posicione("SA3",1,xfilial("SA3")+SZX->ZX_VEND,"A3_GEREN")
   _cSuper := posicione("SA3",1,xfilial("SA3")+SZX->ZX_VEND,"A3_I_SUPE")
   _cCC := " "

   _cEmailGer := ""	
   If !Empty(_cSuper)
      _cEmailGer := Posicione("SA3",1,xfilial("SA3")+_cSuper,"A3_EMAIL")
   EndIf

   If ! Empty(_cEmailGer)
      _cCC += AllTrim(_cEmailGer) + ";"
   EndIf

   _cEmailGer := ""
   If !Empty(_cCoord)
      _cEmailGer := Posicione("SA3",1,xfilial("SA3")+_cCoord,"A3_EMAIL")
   EndIf

   If ! Empty(_cEmailGer)
      _cCC += AllTrim(_cEmailGer) + ";"
   EndIf
   
   _cEmailGer := ""
   If !Empty(_cGeren)
      _cEmailGer := Posicione("SA3",1,xfilial("SA3")+_cGeren,"A3_EMAIL") 
   EndIf

   If ! Empty(_cEmailGer)
      _cCC += AllTrim(_cEmailGer) + ";"
   EndIf
   
   _cMailcom := " " 
   _cAssunto := "Informa��es comerciais e documenta��o do cliente: CNPJ " + Transform(SZX->ZX_CGC,"@R! NN.NNN.NNN/NNNN-99") + " -  NOME: " + SZX->ZX_NOME
  			
   If U_AOMS014D(,_cEmail,_cCC,_cAssunto,,_cMailcom)
      SZX->(RecLock("SZX",.F.))
      SZX->ZX_I_ENVML := "S"
      SZX->(MsUnlock())
   Endif

End Sequence

Return Nil

/*
===============================================================================================================================
Programa----------: AOMS014W
Autor-------------: Julio de Paula Paz
Data da Criacao---: 26/07/2023
Descri��o---------: Validar preenchimento de dados na tela do Prospect.
Parametros--------: _cValid = Validador a ser rodado
Retorno-----------: _lRet = .T. Valida��o Ok / .F. = Falha na valida��o.
===============================================================================================================================
*/
User function AOMS014W(_cValid)
Local _lRet := .T.
Local _cRaizCnpj := SubStr(SZX->ZX_CGC,1,8)
Local _nLimiteCr := 0 

Begin Sequence 
   If _cValid == "CREDITO"
      SA1->(DbSetOrder(17)) // H = STR(A1_CGC,1,8) // Raiz CNPJ
	  If SA1->(MsSeek(_cRaizCnpj))
	     Do While ! SA1->(Eof()) .And. SubStr(SA1->A1_CGC,1,8) == _cRaizCnpj
            
			If SA1->A1_MSBLQL == "2" .And. SA1->A1_LC > 0 .And. Dtos(SA1->A1_VENCLC) >= Dtos(Date())
               _nLimiteCr := SA1->A1_LC
               Exit
			EndIf 

            SA1->(DbSkip())
		 EndDo

         If _nLimiteCr > 0 .And. SZX->ZX_I_LC > 0 
            U_ItMsg("J� existe um grupo de clientes cadastrado com a mesma raiz de CNPJ, e com Limite de Cr�dito informado no valor de: "+AllTrim(Str(_nLimiteCr,16,2)),"Aten��o!","O limte de cr�dito informado no Prospect deve ser zerado.",1)
            _lRet := .F.
			Break
		 EndIf 
         
		 _lConsdBrk := .T.  // Quando True considera os valores de limite de cr�dito do Broker. Quando False considera o limite de cr�dito do cadastro de clientes.

		 SA3->(DbSetOrder(1)) 
	     If SA3->(MsSeek(xFilial("SA3")+SZX->ZX_VEND))
            If SA3->A3_I_VBROK == 'B' .And. SA3->A3_I_LC > 0 .And. _nLimiteCr >0
               U_ItMsg("Este cliente � um Broker e j� existe um grupo de clientes cadastrado com a mesma raiz de CNPJ, e com Limite de Cr�dito informado no valor de: "+AllTrim(Str(_nLimiteCr,16,2)),"Aten��o!","O limte de cr�dito do Broker n�o ser� considerado na efetiva��o do prospect.",1)
			   _lConsdBrk := .F.
			   Break
            EndIf 
		 EndIf 

		 If _nLimiteCr > 0 .And. SZX->ZX_I_LC == 0
		    _lRet := .T.
			Break 
		 EndIf 
      EndIf 

      _lConsdBrk := .T.  // Quando True considera os valores de limite de cr�dito do Broker. Quando False considera o limite de cr�dito do cadastro de clientes.
      SA3->(DbSetOrder(1)) 
	  If SA3->(MsSeek(xFilial("SA3")+SZX->ZX_VEND))
         If ! (SA3->A3_I_VBROK == 'B' .And. SA3->A3_I_LC > 0)
	        _lConsdBrk := .F.           
         EndIf 
	  EndIf 

	  If SZX->ZX_I_LC == 0 .And. ! _lConsdBrk
         U_ItMsg("O limite de cr�dito deste cliente precisa ser informado.","Aten��o!","Informe um limite de cr�dito para este cliente.",1)
         _lRet := .F.
		 Break 
	  EndIf 
   EndIf 

End Sequence 

Return _lRet
