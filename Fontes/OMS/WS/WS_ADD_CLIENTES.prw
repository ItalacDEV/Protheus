/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 16/02/2020 | Chamado 33016. Gravacao do campo ZX_TIMEEMI com FWTimeStamp( 4, DATE(), TIME() )
Alex Wallauer | 30/03/2021 | Chamado 36221. Ajustes na leitura dos dados de contato e do SLC
Lucas Borges  | 22/04/2025 | Chamado 50505. Alterada a picture do CNPJ para contemplar campo alfanumérico
===============================================================================================================================
 Analista     - Programador  - Inicio   - Envio    - Chamado - Motivo da Alteração
=====================================================================================================================================================================
Jerry         - Julio Paz    - 07/04/25 - 10/04/25 - 44503   - Inclusão de nova tag Segmento do cliente e atualização do cadastro de clientes e portal de vandas.
=====================================================================================================================================================================

*/                                        
//====================================================================================================
// Definicoes de Includes da Rotina
//====================================================================================================
#Include 'Protheus.ch'
#Include 'apwebsrv.ch'
#Include 'TbiConn.ch'

/*
===============================================================================================================================
Programa----------: AddCliente
Autor-------------: TOTVS
Data da Criacao---: n/a
Descrição---------: Integração de Clientes
Parametros--------: XML
Retorno-----------: Grava o Cliente
===============================================================================================================================
*/

WSSTRUCT tAdContatoDet

	WSDATA   CONTATODW		AS string // código do contato na DW
	WSDATA   CONTATOPRT		AS string OPTIONAL // código do contato no Protheus
	WSDATA   CONTATONOME	AS string // contato
	WSDATA   CONTATODDD		AS string OPTIONAL
	WSDATA   CONTATOCELULAR	AS string OPTIONAL
	WSDATA   CONTATOFONE	AS string OPTIONAL // telefone
	WSDATA   CONTATOEMAIL	AS string OPTIONAL // email
	WSDATA   CONTATOFUNCAO	AS string OPTIONAL // cargo
	WSDATA   CONTATOSTATUS	AS string OPTIONAL //

ENDWSSTRUCT

WSSTRUCT tAdContatoCab

	WSDATA zzItensDoContato		AS Array Of tAdContatoDet OPTIONAL

ENDWSSTRUCT
//===========================================================================================================================
//

WSSERVICE WANW002 DESCRIPTION "Serviço de atualização dos Clientes"// NAMESPACE "http://local.com.br/"

	WSDATA   EMPRESA           	AS string OPTIONAL// cnpj
	WSDATA   FILIAL            	AS string OPTIONAL// cnpj
	WSDATA   CNPJ             	AS string // cnpj
	WSDATA   RAZAOSOCIAL        AS string //razao_social
	WSDATA   NOMEFANTASIA       AS string // nome_fantasia
	WSDATA   INSESTADUAL        AS string // inscricao_estadual
	WSDATA   INSMUNICIPAL       AS string OPTIONAL // inscricao_municipal
	WSDATA   INSRURAL           AS string OPTIONAL // inscricao_rural
	WSDATA   DATANASC			AS date OPTIONAL // data_fundacao
	WSDATA   HOMEPAGE           AS string OPTIONAL // site
	WSDATA   TIPO             	AS string // tipo
	WSDATA   DDD                AS string
	WSDATA   TELEFONE           AS string // telefone_geral_1
	WSDATA   TELFAX             AS string OPTIONAL // telefone_geral_2
	WSDATA   EMAIL              AS string // email_nfe
	WSDATA   CEP             	AS string // endereco_cep
	WSDATA   ENDERECO           AS string // endereco_rua
	WSDATA   NUMERO             AS string // endereco_numero
	WSDATA   BAIRRO             AS string // endereco_bairro
	WSDATA   COMPLEMENTO        AS string OPTIONAL // endereco_complemento
	WSDATA   OBSERVACAO         AS string OPTIONAL // observacao
	WSDATA   VENDEDOR           AS string // vendedor_codigo
	WSDATA   DATACADASTRO		AS date // data_cadastro
	WSDATA   HORACADASTRO       AS string // hora_cadastro
	WSDATA   SUFRAMA            AS string OPTIONAL // suframa
	WSDATA   RGFISICA           AS string OPTIONAL // rg
	WSDATA   ESTADO             AS string // estado_codigo_ibge
	WSDATA   CODMUNICIPIO       AS string // municipio_codigo_ibge
	WSDATA   FISICAJURIDICA     AS string // fisica_juridica
	WSDATA   CNAE	            AS string OPTIONAL // cnae
	WSDATA   SEGMENTO     		AS string // OPTIONAL// Segmento
	WSDATA   COND               AS string   //Cond de Pagamento
	WSDATA   GRUPOVENDA			AS string  // Grupo de Vendas
	WSDATA   TRANSPORTADORA		AS string // Transportadora
	WSDATA 	 NUMERODW			AS String // codigo   
	WSDATA 	 CCHEP  			AS String OPTIONAL // CHEP
	WSDATA 	 LC    			    AS float OPTIONAL // LC
	WSDATA 	 TADCONTATO			AS tAdContatoCab OPTIONAL

	// Retorno do WEBSERVICE
	WSDATA AtualCliente		AS String

	WSMETHOD AddCliente		DESCRIPTION "Inclusao/Atualizacao de Cliente - SA1"

ENDWSSERVICE

//============================================================================================================================
//

/*WSMETHOD AddCliente WSRECEIVE Empresa, Filial, Cnpj, Razaosocial, Nomefantasia, Insestadual, Insmunicipal, Insrural, Datanasc,;
 Homepage, Tipo, Ddd, Telefone, Telfax, Email, Cep, Endereco, Numero, Bairro, Complemento,Observacao,  Vendedor,;
 Datacadastro,  Horacadastro, Suframa, Rgfisica,Estado,Codmunicipio,Cepentrega, Estentrega,Munentrega,;
 Bairroentrega,Endentrega, Numentrega, Complentrega, Fisicajuridica, Cnae, Segmento, Cond, GrupoVenda, Transportadora, Numerodw, TADCONTATO WSSEND AtualCliente WSSERVICE WANW002
*/

WSMETHOD AddCliente WSRECEIVE Empresa, Filial, Cnpj, Razaosocial, Nomefantasia, Insestadual, Insmunicipal, Insrural, Datanasc,;
 Homepage, Tipo, Ddd, Telefone, Telfax, Email, Cep, Endereco, Numero, Bairro, Complemento,Observacao,  Vendedor,;
 Datacadastro,  Horacadastro, Suframa, Rgfisica,Estado,Codmunicipio,;
 Fisicajuridica, Cnae, Segmento, Cond, GrupoVenda, Transportadora, Numerodw, cchep, lc , tadcontato WSSEND AtualCliente WSSERVICE WANW002

Local aVetor	:= {}
Local cCnpj			:= Alltrim(UnMaskCNPJ(::CNPJ))
Local cRazaosocial	:= Upper(Alltrim(::Razaosocial))
Local cNomefantasia	:= Upper(Alltrim(::Nomefantasia))
Local cInsestadual	:= Upper(Alltrim(::Insestadual))
Local cInsmunicipal	:= Upper(Alltrim(::Insmunicipal))
Local cInsrural		:= Upper(Alltrim(::Insrural))
Local dDatanasc		:= ::Datanasc
Local cHomepage		:= Upper(Alltrim(::Homepage))
Local cTipo			:= Upper(Alltrim(::Tipo))
Local cDdd			:= Upper(Alltrim(::Ddd))
Local cTelefone		:= Upper(Alltrim(::Telefone))
Local cTelfax		:= Upper(Alltrim(::Telfax))
Local cEmail		:= Upper(Alltrim(::Email))
Local cCep			:= Upper(Alltrim(::Cep))
Local cEndereco		:= Upper(Alltrim(::Endereco)) + ", " + Upper(Alltrim(::Numero))
Local cBairro		:= Upper(Alltrim(::Bairro))
Local cComplemento	:= Upper(Alltrim(::Complemento))
Local cObservacao	:= Upper(Alltrim(::Observacao))
Local cVendedor		:= Upper(Alltrim(::Vendedor))
Local dDatacadastro	:= ::Datacadastro
Local cHoracadastro	:= Upper(Alltrim(::Horacadastro))
Local cSuframa		:= Upper(Alltrim(::Suframa))
Local cRgfisica		:= Upper(Alltrim(::Rgfisica))
Local cEstado		:= Upper(Alltrim(::Estado))
Local cCodmunicipio	:= Upper(Alltrim(::Codmunicipio))
Local cFisicajuridica	:= Upper(Alltrim(::Fisicajuridica))
Local cCnae			:= Upper(Alltrim(::Cnae))
Local cSubSegmen	:= Upper(Alltrim(::Segmento)) 
Local cSegmento		:= Substr(cSubSegmen,1,2)     
Local cCond	     	:= Upper(Alltrim(::Cond))
Local cGrupoVenda	:= Upper(Alltrim(::GrupoVenda))
Local cTransportadora:= Upper(Alltrim(::Transportadora))
Local cNumerodw		:= Alltrim(::Numerodw)
Local cContato      := Upper(Alltrim(::TADCONTATO))
Local cCCHEP        := Upper(Alltrim(::cchep))
Local nLC           := ::lc
Local _lProspct     := U_ITGETMV("IT_INTPROSP",.F.) 
Local cCodigo	:= ""
Local cLoja		:= ""
Local aRecnoSM0	:= {}
Local cEmprWan	:= Upper(Alltrim(::Empresa))
Local cFilWan	:= Upper(Alltrim(::Filial))
Local lEmpres	:= .F.
Local nOpc		:= 0

Local lRet		:= .T.
Local cRaizCNPJ	:= ""
Local nTamCdCli	:= 0

// iniciando-se os trabalhos
U_ITConOut("[WS_ADD_CLIENTE] "+Repl("-",150))
U_ITConOut("[WS_ADD_CLIENTE] WebService Cliente")
U_ITConOut("[WS_ADD_CLIENTE] Numero DW: " + cNumeroDw + " Dados Contato " + cContato)

Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .T.
Private lMsErroAuto		:= .F.
Private aAutoErro		:= {}


// tratamento para carregar a empresa diretamente no fonte
aRecnoSM0	:=	{cEmprWan,cFilWan} //Posição 1 referente ao codigo da empresa, posição 2 referente a filial caso não seja informado no aParam
If !empty(alltrim(aRecnoSM0[01])) .and. !empty(alltrim(aRecnoSM0[02]))
     Reset Environment
     RPCSetType(3)
     If FindFunction("WFPREPENV")
          WfPrepENV(aRecnoSM0[1],aRecnoSM0[2])
          lAuto	:=	.T.
     Else
          Prepare Environment Empresa aRecnoSM0[1] Filial aRecnoSM0[2]
     EndIf
     lEmpres := .T.
EndIf

begintran()

nTamCdCli := TamSX3("A1_COD")[1]
// primeiro valido o CNPJ. Se ele não existir, incluo. Caso contrário não rejito, pois pode ter alteração de contatos.
// Valido a existência do CNPJ
dbSelectArea("SA1")
dbSetOrder(3)
If !dbSeek(xFilial("SA1") + cCNPJ)
	//Valido a Existência do ID do cliente na base
	if FChkIdDW(cNumeroDw,"SA1")
		_cMsgErro	:= "Cliente DW [" + cNumeroDw + "] ja existe na base com outro CNPJ."
		_cObs := "ERRO:" + _cMsgErro
		SetSoapFault("Retorno",LEFT(_cObs,60))
		U_ITConOut(_cObs)
		::AtualCliente := "[FALSO] Erro ao realizar a atualizacao do Cliente " + _cObs
		lRet := .F.
	endif

	if _lProspct .AND. FChkIdDW(cNumeroDw,"SZX")
		_cMsgErro	:= "Cliente DW [" + cNumeroDw + "] ja existe na base com outro CNPJ."
		_cObs := "ERRO:" + _cMsgErro
		SetSoapFault("Retorno",LEFT(_cObs,60))
		U_ITConOut(_cObs)
		::AtualCliente := "[FALSO] Erro ao realizar a atualizacao do Cliente " + _cObs
		lRet := .F.
	endif

	// Valido o tipo do cliente
	If !(cTipo $ "FLRSX")
		_cMsgErro	:= "Tipo do cliente DW nao esta dentro dos parametros esperados: F=Cons.Final;L=Produtor Rural;R=Revendedor;S=Solidario;X=Exportacao"
		_cObs := "ERRO:" + _cMsgErro
		SetSoapFault("Retorno",LEFT(_cObs,60))
		U_ITConOut(_cObs)
		::AtualCliente := "[FALSO] Erro ao realizar a atualizacao do Cliente " + _cObs
		lRet := .F.
	EndIf

    SA3->( DBSetOrder(1) )
    If !SA3->( DBSeek( xFilial('SA3') +cVendedor ) )
		_cMsgErro:= "Vendedor do Cleinte DW não encontrado no Protheus: "+cVendedor
		_cObs    := "ERRO:" + _cMsgErro
		SetSoapFault("Retorno",LEFT(_cObs,60))
		U_ITConOut(_cObs)
		::AtualCliente := "[FALSO] Erro ao realizar a atualizacao do Cliente " + _cObs
		lRet := .F.
	EndIf


	if lRet
		nOpc := 3 // Inclusao
		// Tratamento de variaveis locais
		cPessoa		:= Iif(Len(cCNPJ) < 14,"F","J")
		cFisicajuridica	:= cPessoa
		cRaizCNPJ	:= SubStr(cCNPJ,1,8)

		if ::DataNasc == nil
			dDataNasc := stod("        ")
		else
			dDataNasc := ::DataNasc
		endif

		// Formatacao de codigo e loja.
		// A partir daqui nao pode mais usar AllTrim em nenhuma das 2 variaveis
		dbselectarea("SA1")
		SA1->(dbSetOrder(1))
		While (.T.)
			cCodigo := GETSXENUM("SA1","A1_COD")
			If !SA1->(dbSeek(xFilial("SA1") + cCodigo))
			    U_ITConOut("[WS_ADD_CLIENTE] Sera incluido esse codigo: "+cCodigo)
				SA1->(rollbackSx8())
				Exit
			Endif
			U_ITConOut("[WS_ADD_CLIENTE] Ja existe esse codigo: "+cCodigo)
			SA1->(ConfirmSX8())
		Enddo

	  	//cCodigo := GetNumSA1()
		IF _lProspct
		   cLoja:= LEFT(RIGHT(ALLTRIM(cCnpj),6),4)
		ELSE   
		   cLoja:= "0001"
        ENDIF
		// Campos fixos pelo padrão
		cPaisBacen	:= "01058"
		cPais		:= "105"

		// regra 01 - se o nome reduzido estiver em branco, assumo o campo cRazão, que alimentará o A1_NOME
		if empty(alltrim(cNomefantasia))
			cNomefantasia := cRazaosocial
		else
			cNomefantasia := alltrim(cNomefantasia)
		endif

		cCONTATO:=""
		cCARGC  :=""
		cEMAILC :=""
		IF Type("tAdContato:zzItensDoContato") == "A"
		   nItem:=1
		   oSU5Tmp:=::tAdContato:zzItensDoContato
		   IF LEN(oSU5Tmp) > 0 
	          IF Type("oSU5Tmp[nItem]:CONTATONOME"	)  = 'C'
	             cCONTATO:=ALLTRIM(UPPER(oSU5Tmp[nItem]:CONTATONOME))
	          ENDIF    
	          IF Type("oSU5Tmp[nItem]:CONTATOFUNCAO" ) = 'C'
	             cCARGC  :=ALLTRIM(UPPER(oSU5Tmp[nItem]:CONTATOFUNCAO))
	          ENDIF	  
	          IF Type("oSU5Tmp[nItem]:CONTATOEMAIL") == "C"
	             cEMAILC :=ALLTRIM(UPPER(oSU5Tmp[nItem]:CONTATOEMAIL))
	          ENDIF	  
            ENDIF
		ENDIF
		aAdd(aVetor,{"A1_COD"		,cCodigo		,Nil})
		aAdd(aVetor,{"A1_LOJA"		,cLoja			,Nil})
		aAdd(aVetor,{"A1_NOME"		,cRazaoSocial	,Nil})
		aAdd(aVetor,{"A1_NREDUZ"	,cNomeFantasia	,Nil})
		aAdd(aVetor,{"A1_PFISICA"	,cRgFisica		,Nil})
		aAdd(aVetor,{"A1_TIPO"		,cTipo			,Nil})
		aAdd(aVetor,{"A1_PESSOA"	,cFisicaJuridica,Nil})
		aAdd(aVetor,{"A1_CGC"		,cCnpj			,Nil})
		aAdd(aVetor,{"A1_EST"		,cEstado		,Nil})
		aAdd(aVetor,{"A1_COD_MUN"	,cCodMunicipio	,Nil})
		aAdd(aVetor,{"A1_INSCR"		,cInsEstadual	,Nil})
		aAdd(aVetor,{"A1_INSCRM"	,cInsMunicipal	,Nil})
		aAdd(aVetor,{"A1_INSCRUR"	,cInsRural		,Nil})
		aAdd(aVetor,{"A1_DTNASC"	,dDataNasc		,Nil})
		aAdd(aVetor,{"A1_HPAGE"		,cHomePage		,Nil})
		aAdd(aVetor,{"A1_TEL"		,cTelefone		,Nil})    
		aAdd(aVetor,{"A1_DDD"		,cDDD   		,Nil})    		
		aAdd(aVetor,{"A1_FAX"		,cTelFax		,Nil})
		aAdd(aVetor,{"A1_EMAIL"		,cEmail			,Nil})
		aAdd(aVetor,{"A1_CEP"		,cCEP			,Nil})
		aAdd(aVetor,{"A1_END"		,cEndereco		,Nil})
		aAdd(aVetor,{"A1_BAIRRO"	,cBairro		,Nil})
		aAdd(aVetor,{"A1_COMPLEM"	,cComplemento	,Nil})
		aAdd(aVetor,{"A1_OBS"		,cObservacao	,Nil})
		aAdd(aVetor,{"A1_VEND"		,cVendedor		,Nil})
		aAdd(aVetor,{"A1_DTCAD"		,dDataCadastro	,Nil})
		aAdd(aVetor,{"A1_HRCAD"		,cHoraCadastro	,Nil})
		aAdd(aVetor,{"A1_SUFRAMA"	,cSuframa		,Nil})
		aAdd(aVetor,{"A1_CNAE"		,cCNAE			,Nil})
		aAdd(aVetor,{"A1_CODPAIS"	,cPaisBacen		,Nil})
		aAdd(aVetor,{"A1_PAIS"		,cPais			,Nil})
		aAdd(aVetor,{"A1_MSBLQL"	,"2"			,Nil})
		aAdd(aVetor,{"A1_I_DW"		,cNumeroDw		,Nil})//A1_NUMDW
		aAdd(aVetor,{"A1_I_GRCLI"	,cSegmento		,Nil})
		aAdd(aVetor,{"A1_I_SUBCO"   ,cSubSegmen     ,Nil}) 
		aAdd(aVetor,{"A1_TRANSP"	,cTransportadora,Nil})
		aAdd(aVetor,{"A1_COND"	    ,cCond          ,Nil})
		aAdd(aVetor,{"A1_GRPVEN"	,cGrupoVenda    ,Nil})				
		aAdd(aVetor,{"A1_I_CCHEP"	,cCCHEP			,Nil})
		aAdd(aVetor,{"A1_I_CHEP"	,IF(EMPTY(cCCHEP),"P","C"),Nil})
		//ConOut("****[WS_ADD_CLIENTE] VALTYPE(nLC)    "+VALTYPE(nLC)) 
		IF VALTYPE(nLC) = "N"
		   aAdd(aVetor,{"A1_I_SLC"	,nLC   			,Nil})				
		ELSE
		   aAdd(aVetor,{"A1_I_SLC"	,0   			,Nil})				
		EndIF
		aAdd(aVetor,{"A1_CONTATO"   ,cCONTATO		,Nil})
		aAdd(aVetor,{"A1_I_CARGC"   ,cCARGC		    ,Nil})
		aAdd(aVetor,{"A1_I_EMAIL"   ,cEMAILC		,Nil})
        IF SA1->(FieldPos("A1_I_ORIGD")) > 0
		   aAdd(aVetor,{"A1_I_ORIGD","D"	   		,Nil})
		ENDIF   

	    SA3->( DBSetOrder(1) )
	    If SA3->( DBSeek( xFilial('SA3') +cVendedor ) )
		   aAdd(aVetor,{"A1_TABELA"	,SA3->A3_I_TABPR ,Nil})				
		   aAdd(aVetor,{"A1_RISCO"	,SA3->A3_I_RISCO ,Nil})				
		   aAdd(aVetor,{"A1_LC"	    ,SA3->A3_I_LC	 ,Nil})				
		ENDIF		   

		IF _lProspct
           GravaProspct(aVetor,cCCHEP)
        ELSE
           //MSExecAuto( {|x,y,z| mata030(x,y,z) } , aVetor ,, 3 )  
		   MSExecAuto({|x,y| Mata030(x,y)},aVetor,nOpc) // nOpc = 3 - inclusão, 4 - Alteracao
		ENDIF   

		If lMsErroAuto
			aAutoErro := GETAUTOGRLOG()
			_cObs := "[WS_ADD_CLIENTE] "+alltrim(xDatAt() + "[ERRO] [WS_ADD_CLIENTE] " + XCONVERRLOG(aAutoErro))
			SetSoapFault("Retorno",LEFT(_cObs,60))
			U_ITConOut(_cObs)
			::AtualCliente := "[FALSO] Erro ao realizar a atualizacao do Cliente " + _cObs
			lRet := .F.
		Else
			// verifico se realmente o cliente foi adicionado no Protheus
			IF _lProspct
				::AtualCliente := ALLTRIM(STR(SZX->(RECNO())))//"[SUCESSO] Cliente Gravado no Prospct Nr. DW: " + cNumeroDw
			ELSE
				SA1->(dbSetOrder(RetOrder("SA1","A1_FILIAL+A1_CGC")))
				If SA1->(dbSeek(xFilial("SA1")+PadR(cCNPJ,TamSX3("A1_CGC")[1])))
					::AtualCliente := SA1->A1_COD+SA1->A1_LOJA//"[SUCESSO] - Cliente gravado com o código: " + SA1->A1_COD + " - Loja: " + SA1->A1_LOJA // SA1->A1_COD+SA1->A1_LOJA
					U_ITConOut("[WS_ADD_CLIENTE] Cliente " + SA1->A1_COD +" - "+ SA1->A1_LOJA + " - " + IIf(nOpc == 4,"alterado","incluido") + " com sucesso!")
					
				Else
					_cMsgErro 	:= "CNPJ nao localizado apos inclusao do cliente: "
					_cMsgErro	+=  Transform(cCNPJ,IIf(Len(cCNPJ) < 14,"@R 999.999.999-99","@R! NN.NNN.NNN/NNNN-99"))
					_cObs 		:= "ERRO:" + _cMsgErro
					SetSoapFault("Retorno",LEFT(_cObs,60))
					U_ITConOut(_cObs)
					::AtualCliente := "[FALSO] Erro ao realizar a atualizacao do Cliente " + _cObs
					lRet := .F.
				endif
			EndIf
		ENDIF
	EndIf
else
	::AtualCliente := "[FALSO] Cliente ja cadastrado, codigo: " + SA1->A1_COD + " - " + SA1->A1_LOJA
EndIf

endtran()

U_ITConOut("[WS_ADD_CLIENTE] Fim: " + Time() + " Data: " + DtoC(Date()))
U_ITConOut("[WS_ADD_CLIENTE] "+Repl("-",150))

Return lRet

//=========================================================================================================================
// função que cria / altera os contatos

static Function WSADDCONTATO(xCodigo,xLoja,oSU5Tmp,cCONTATO)

Local nItem		:= 0
//Local xCodCont	:= ""
Local nItens 	:= 0
Local _aItCont	:= oSU5Tmp
//Local cxCARGC:=cxEMAILC:=""

nItens := Len(_aItCont)

U_ITConOut("[WS_ADD_CLIENTE] Lendo  " +ALLTRIM(STR(nItens))+ " contatos " )

for nItem := 1 to nItens
	IF nItem == 1
	   IF Type("oSU5Tmp[nItem]:CONTATONOME"	)  = 'C'
	      cCONTATO:=ALLTRIM(UPPER(oSU5Tmp[nItem]:CONTATONOME))
	   ENDIF

	   IF Type("oSU5Tmp[nItem]:CONTATOFUNCAO" ) = 'C'
	      cCARGC  :=ALLTRIM(UPPER(oSU5Tmp[nItem]:CONTATOFUNCAO))
	   ENDIF	  
	   IF Type("oSU5Tmp[nItem]:CONTATOEMAIL") == "C"
	      cEMAILC :=ALLTRIM(UPPER(oSU5Tmp[nItem]:CONTATOEMAIL))
	   ENDIF	  
    ENDIF
next nX

return()  

//==========================================================================================================================
// função que converte o log, deixando-o mais "apresentável"

Static Function xConverrLog(aAutoErro)

Local cRet := ""
Local _ni   := 1

FOR _ni := 1 to Len(aAutoErro)
	cRet += CRLF + AllTrim(aAutoErro[_ni])
NEXT _ni

RETURN cRet

//==========================================================================================================================
//função que retorna a data atual em formato CARACTERE

Static Function xDatAt()

Local cRet	:=	""

//cRet :=	CRLF + "(" + DTOC(DATE()) + " " + TIME() + ")"

Return(cRet)


//===========================================================================================================================
// função que remove a máscara do CNPJ

Static Function UnMaskCNPJ( cCNPJ )

Local cCNPJClear := cCNPJ

BEGIN SEQUENCE

	IF Empty( cCNPJClear )
		BREAK
	EndIF

	cCNPJClear := StrTran( cCNPJClear , "." , "" )
	cCNPJClear := StrTran( cCNPJClear , "/" , "" )
	cCNPJClear := StrTran( cCNPJClear , "-" , "" )
	cCNPJClear := AllTrim( cCNPJClear )

END SEQUENCE

Return(cCNPJClear)

//===========================================================================================================================
// Função que valida a existencia do código DW no cliente

Static Function FChkIdDW(cIdDW,cTabela)

Local aArea		:=	GetArea()
Local cAliasTrb	:=	GetNextAlias()
Local aQuery	:=	{}
Local lRet		:=	.F.

Default cIdDW	:=	""
Default	cTabela	:=	""

//-----------------------------------------------------------------
// Consulta se o cliente DW já existe na base de dados do Protheus
//-----------------------------------------------------------------
If cTabela == "SA1" .And. SA1->(FieldPos("A1_I_DW")) > 0

	BeginSql Alias cAliasTrb

		SELECT
			SA1.A1_FILIAL,
			SA1.A1_COD,
			SA1.A1_LOJA,
			SA1.A1_NOME,
			SA1.A1_CGC,
			SA1.R_E_C_N_O_ AS SA1_RECNO
		FROM
			%Table:SA1% SA1 (NOLOCK)
		WHERE
			SA1.%NotDel%
			AND	SA1.A1_I_DW = %Exp:cIdDW%
		ORDER BY
			%Order:SA1%
	EndSql

	aQuery := GetLastQuery(cAliasTrb)

	If (cAliasTrb)->SA1_RECNO > 0
		lRet := .T.
	EndIf

ELSEIf cTabela == "SZX" .And. SZX->(FieldPos("ZX_I_DW")) > 0

	BeginSql Alias cAliasTrb

		SELECT SZX.R_E_C_N_O_ AS SZX_RECNO
		FROM
			%Table:SZX% SZX (NOLOCK)
		WHERE
			SZX.%NotDel%
			AND	SZX.ZX_I_DW = %Exp:cIdDW%
		ORDER BY
			%Order:SZX%
	EndSql

	aQuery := GetLastQuery(cAliasTrb)

	If (cAliasTrb)->SZX_RECNO > 0
		lRet := .T.
	EndIf

EndIf

If Select(cAliasTrb) > 0
	dbSelectArea(cAliasTrb)
	dbCloseArea()
EndIf

RestArea(aArea)

Return(lRet)

/*
===============================================================================================================================
Programa--------: GravaProspct()
Autor-----------: Alex Wallauer
Data da Criacao-: 10/01/2019
Descrição-------: Inclui dados do cliente no Prospct
Parametros------: aVetor,cCCHEP
Retorno---------:(.T.)
===============================================================================================================================
*/
Static Function GravaProspct(aVetor,cCCHEP)

LOCAL _aGrava:={},_nCpo,_nPos
//LOCAL _cTeste:=""
LOCAL _aCampos:={;
{ "A1_NOME"	  ,"ZX_NOME"  },;
{ "A1_PESSOA" ,"ZX_PESSOA"},;
{ "A1_CGC"	  ,"ZX_CGC"   },;
{ "A1_NREDUZ" ,"ZX_NREDUZ"},;
{ "A1_TIPO"	  ,"ZX_TIPO"  },;
{ "A1_EST"	  ,"ZX_EST"   },;
{ "A1_COD_MUN","ZX_CODMUN"},;
{ "A1_CEP"	  ,"ZX_CEP"},;
{ "A1_DDD"	  ,"ZX_DDD"},;
{ "A1_TEL"	  ,"ZX_TEL"},;
{ "A1_END"	  ,"ZX_END"},;
{ "A1_BAIRRO" ,"ZX_BAIRRO" },;//{ "A1_TELEX"  ,"ZX_TELEX"  },;
{ "A1_FAX"	  ,"ZX_FAX"    },;
{ "A1_PAIS"	  ,"ZX_PAIS"   },;
{ "A1_INSCR"  ,"ZX_INSCR"  },;
{ "A1_PFISICA","ZX_PFISICA"},;
{ "A1_DTNASC" ,"ZX_DTNASC" },;
{ "A1_EMAIL"  ,"ZX_EMAIL"  },;
{ "A1_HPAGE"  ,"ZX_HPAGE"  },;
{ "A1_INSCRM" ,"ZX_INSCRM" },;
{ "A1_INSCRUR","ZX_INSCRUR"},;
{ "A1_COMPLEM","ZX_COMPLEM"},;//{ "A1_CEPC"	  ,"ZX_CEP"    },;
{ "A1_VEND"	  ,"ZX_VEND"   },;
{ "A1_GRPVEN" ,"ZX_I_GRPVE"},;
{ "A1_COND"	  ,"ZX_CONDPAG"},;
{ "A1_I_GRCLI","ZX_GRCLI"  },;//{ "A1_RISCO"  ,"ZX_I_RISCO"},;//{ "A1_VENCLC" ,"ZX_I_VENCL"},;//{ "A1_CONTRIB","ZX_CONTRIB"},;
{ "A1_I_SUBCO","ZX_SUB_COD"},; 
{ "A1_CNAE"   ,"ZX_I_END"  },;
{ "A1_CONTATO","ZX_CONTATO"},;
{ "A1_I_CARGC","ZX_CARGC"  },;
{ "A1_I_EMAIL","ZX_EMAILC" },;//{ "A1_SIMPNAC","ZX_SIMPNAC"},; 
{ "A1_LOJA"	  ,"ZX_LOJA"   },;
{ "A1_I_CCHEP","ZX_I_CCHEP"} }

dbSelectArea("SZX")
AADD(_aCampos,{ "A1_I_DW" ,"ZX_I_DW" } )
AADD(_aCampos,{ "A1_I_SLC","ZX_I_SLC"} )


AADD(_aGrava,{"ZX_FILIAL" ,xFilial("SZX")})
AADD(_aGrava,{"ZX_EMISSAO",DATE()        })
AADD(_aGrava,{"ZX_CODEMP" ,'010'         })
AADD(_aGrava,{"ZX_MSBLQL" ,'2'           })
AADD(_aGrava,{"ZX_STATUS" ,'L'           })
AADD(_aGrava,{"ZX_EVENTO" ,'0'           })
AADD(_aGrava,{"ZX_TIMEEMI",FWTimeStamp( 4, DATE(), TIME() ) })
AADD(_aGrava,{"ZX_CHEP"   ,IF(EMPTY(cCCHEP),"N","S")})

IF SZX->(FieldPos("ZX_I_ORIGD")) > 0
   AADD(_aGrava,{"ZX_I_ORIGD" ,'D'       })
ENDIF 
                                
FOR _nCpo:= 1 TO LEN(_aCampos)
   IF (_nPos:=ASCAN(aVetor, {|I| I[1] == _aCampos[_nCpo,1] } )) > 0
                    //1-compo         2-conteudo
      AADD(_aGrava,{_aCampos[_nCpo,2],aVetor[_nPos,2]}) 
   ENDIF   
NEXT

BEGIN TRANSACTION

SZX->(RecLock("SZX",.T.))
For _nCpo := 1 To Len(_aGrava)
    IF SZX->(FieldPos(_aGrava[_nCpo][1])) > 0
	   SZX->(FieldPut( FieldPos(_aGrava[_nCpo][1]) , _aGrava[_nCpo][2] ))
	ENDIF   
Next
SZX->(MSUNLOCK())

END TRANSACTION

RETURN .T.
