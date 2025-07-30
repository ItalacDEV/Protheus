/*
=====================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Analista     - Programador  - Inicio   - Envio    - Chamado - Motivo da Alteração
===============================================================================================================================
Vanderlei     - Igor Melgaço - 03/04/25 - 15/07/25 - 48781   - Ajustes para busca de titulo na SE2 e gravação do campo Serie do Documento.
=====================================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina
//====================================================================================================

#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.Ch"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF	Chr(13)+Chr(10)

Static _nRecnoZ32 := 0
Static _nRecnoZ34 := 0
//*************
// POST
//*************
WsRestful AOMS148 Description "WebService REST Italac x TMS Multiembarcador"

   WsMethod Post Fatura Description "Gravar dados da Fatura do Embarcador na temporaria" PATH "/AOMS148/Fatura"  WsSyntax "/AOMS148/Fatura" 

End WsRestFul

WsMethod POST Fatura WsService AOMS148
   Local _cBody    As Character
   Local _cErro    As Character
   Local _aRecFat  As Array
   Local _aRecnos  As Array
   Local _lRetorno As Logical
   Local _nI       As Numeric
   Local _cNome    As Character
   Local _cResp    As Character 
   Local _cIDInte  As Character

   _cBody    := ::GetContent()
   _cErro    := ""
   _aRecFat  := {}
   _aRecnos  := {}
   _lRetorno := .F.
   _nI       := 0
   _cNome    := ""
   _cIDInte  := ""

   If DecodeUtf8(_cBody) <> Nil
      _cBody := DecodeUtf8(_cBody)
   EndIf

   _lRetorno := U_AOMS148(_cBody,@_cErro,.T.,@_aRecFat,@_cNome,@_cIDInte)
   
   If _lRetorno 
      _cResp := '{ "retorno":"200" , "mensagem":"Integrado com sucesso!", "IDIntegracaoProtheus":"'+_cIDInte+'" }'

      ::SetResponse(_cResp)

      If Empty(Alltrim(_cErro))
         _lRetorno := AOMS148Arq(_aRecFat,_cNome,@_cErro)
      Else
         _lRetorno := .F.
      EndIf

      Z34->(DbGoto(_nRecnoZ34))
      Z34->(RecLock("Z34",.F.))
      Z34->Z34_STATUS := Iif(_lRetorno,"G","I")
      Z34->(MsUnLock())

      Z32->(DbGoto(_nRecnoZ32))
      Z32->(RecLock("Z32",.F.))
      Z32->Z32_STATUS := Iif(_lRetorno,"G","I")
      Z32->Z32_RESPOS := _cResp
      Z32->Z32_ERRO   := _cErro
      Z32->(MsUnLock())

   Else
      _cResp := '{ "retorno":"500" , "mensagem":"Integracao nao realizada!", "ID de Integracao Protheus":"'+_cIDInte+'", "Erro":"'+_cErro+'" }'

      //SetRestFault(400,'Ops')
      ::setStatus(500) 
      ::SetResponse( _cResp )

      Z32->(DbGoto(_nRecnoZ32))
      Z32->(RecLock("Z32",.F.))
      Z32->Z32_STATUS := "N"
      Z32->Z32_RESPOS := _cResp
      Z32->Z32_ERRO   := _cErro
      Z32->(MsUnLock())

   EndIf	

Return(.T.)

/*
===============================================================================================================================
Programa----------: AOMS148
Autor-------------: Igor Melgaço
Data da Criacao---: 03/04/2025
===============================================================================================================================
Descrição---------: Realiza de Integração - Chamado: 48781
===============================================================================================================================
Parametros--------: _cBody, _cErro, _lRest, _aRecFat, _cNome, _cIDInte
===============================================================================================================================
Retorno-----------: .T.  
===============================================================================================================================
*/ 
User Function AOMS148(_cBody As Character,_cErro As Character,_lRest As Logical,_aRecFat As Array,_cNome As Character, _cIDInte As Character) As Logical
   Local _aDocs     As Array
   Local _cNrfatura As Character
   Local _cDtHrFatu As Character
   Local _cTpOper   As Character
   Local _cTpCarga  As Character
   Local _cTomador  As Character
   Local _cVrFatura As Character
   Local _nVrDesc   As Numeric
   Local _nVrAcresc As Numeric
   Local _cObsFatur As Character
   Local _cTCpfCnpj As Character
   Local _cCodInteg As Character
   Local _nI        As Numeric
   Local _aAuxZ32   As Array
   Local _aAuxZ33   As Array
   Local _aAuxZ34   As Array
   Local _lRet      As Logical
   Local _cCod      As Character
   Local _cLoja     As Character
   Local _dData     As Date
   Local _cHora     As Character

   Default _cErro   := ""
   Default _lRest   := .T.
   Default _aRecFat := {}

   Private oJsoAux     As Object
   Private lMsErroAuto As Logical

   _aDocs     := {}
   _cNrfatura := ""
   _cDtHrFatu := ""
   _cTpOper   := ""
   _cTpCarga  := ""
   _cTomador  := ""
   _cVrFatura := ""
   _nVrDesc   := 0
   _nVrAcresc := 0
   _cObsFatur := ""
   _cTCpfCnpj := ""
   _cCodInteg := ""
   _nI        := 0
   _aAuxZ32   := {}
   _aAuxZ33   := {}
   _aAuxZ34   := {}
   _lRet      := .T.
   _cCod      := ""
   _cLoja     := ""
   _dData     := CTOD("")
   _cHora     := ""

   oJsoAux    := Nil
   lMsErroAuto := .F.

   FWJsonDeserialize(_cBody, @oJsoAux)

   _cFilial := oJsoAux:FILIAL
   
   If _lRest
      RpcClearEnv()
      RpcSetEnv("01",_cFilial)
   EndIf
    
   _cNrfatura := Iif(AttIsMemberOf(oJsoAux,"nrofatura")    ,Alltrim(Str(oJsoAux:nrofatura)),"") 
   _cDtHrFatu := Iif(AttIsMemberOf(oJsoAux,"dataHoraFatura")    ,oJsoAux:dataHoraFatura,"") 
   _cTpOper   := Iif(AttIsMemberOf(oJsoAux,"tipoOperacao")    ,oJsoAux:tipoOperacao,"") 
   _cTpCarga  := Iif(AttIsMemberOf(oJsoAux,"tipoCarga")    ,oJsoAux:tipoCarga,"") 
   _cTomador  := Iif(AttIsMemberOf(oJsoAux,"tomador")    ,oJsoAux:tomador,"") 
   _cVrFatura := Iif(AttIsMemberOf(oJsoAux,"valorFatura")    ,oJsoAux:valorFatura,"") 
   _nVrDesc   := Iif(AttIsMemberOf(oJsoAux,"valorDesconto")    ,oJsoAux:valorDesconto,"") 
   _nVrAcresc := Iif(AttIsMemberOf(oJsoAux,"valorAcrescimo")    ,oJsoAux:valorAcrescimo,"") 
   _cObsFatur := Iif(AttIsMemberOf(oJsoAux,"obsFatura")    ,oJsoAux:obsFatura,"")  
   _cTCpfCnpj := Iif(AttIsMemberOf(oJsoAux:transportador,"cpfCnpj")    ,oJsoAux:transportador:cpfCnpj,"")  
   _cCodInteg := Iif(AttIsMemberOf(oJsoAux:transportador,"codIntegracao")    ,oJsoAux:transportador:codIntegracao,"") 

   _lRet := AOMS148VT(_cTCpfCnpj,@_cCod,@_cLoja,@_cNome,@_cErro)

   If AttIsMemberOf(oJsoAux,"documentos") 
      For _ni := 1 to len(oJsoAux:documentos)
         
         If _lRet
            _cNrDoc    := U_ITKEY(oJsoAux:documentos[_ni]:numeroDocumento,"F1_DOC")  
            _cTipoDoc  := U_ITKEY(oJsoAux:documentos[_ni]:tipoDocumento,"F1_TIPO")  
            _cSerieDoc := U_ITKEY(oJsoAux:documentos[_ni]:serieDocumento,"F1_SERIE")  

            _lRet := AOMS148VF(_cCod,_cLoja,_cNome,_cSerieDoc,_cNrDoc,oJsoAux:documentos[_ni]:valorTotalDocumento,@_cErro,@_aRecFat)				
         EndIf

         AADD(_aDocs,{;
               Iif(AttIsMemberOf(oJsoAux:documentos[_ni],"numeroDocumento")    ,Alltrim(Str(oJsoAux:documentos[_ni]:numeroDocumento)),""),;
               Iif(AttIsMemberOf(oJsoAux:documentos[_ni],"tipoDocumento")      ,oJsoAux:documentos[_ni]:tipoDocumento,""),;
               Iif(AttIsMemberOf(oJsoAux:documentos[_ni],"serieDocumento")      ,oJsoAux:documentos[_ni]:serieDocumento,""),;
               Iif(AttIsMemberOf(oJsoAux:documentos[_ni],"numeroNFe")          ,oJsoAux:documentos[_ni]:numeroNFe,""),;
               Iif(AttIsMemberOf(oJsoAux:documentos[_ni],"serieNfe")           ,oJsoAux:documentos[_ni]:serieNfe,""),;  
               Iif(AttIsMemberOf(oJsoAux:documentos[_ni],"valorTotalDocumento"),oJsoAux:documentos[_ni]:valorTotalDocumento,0),;
               Iif(AttIsMemberOf(oJsoAux:documentos[_ni],"numeroCarga")        ,oJsoAux:documentos[_ni]:numeroCarga,""),;
               Iif(AttIsMemberOf(oJsoAux:documentos[_ni],"protocoloCarga")     ,Alltrim(Str(oJsoAux:documentos[_ni]:protocoloCarga)),""),;
               Iif(AttIsMemberOf(oJsoAux:documentos[_ni],"protocoloPedido")    ,Alltrim(Str(oJsoAux:documentos[_ni]:protocoloPedido)),""),;
               Iif(AttIsMemberOf(oJsoAux:documentos[_ni],"chaveCTE")           ,oJsoAux:documentos[_ni]:chaveCTE,"");
               })

      Next
   Else
      _lRet := .F.
      _cErro := "Não foi informado os documentos da fatura."
   EndIf

   _cIDinte := AOMS148GNU()
   _dData   := Date()
   _cHora   := Time()

   aAdd(_aAuxZ34, {"Z34_FILIAL", _cFilial				, Nil})
   aAdd(_aAuxZ34, {"Z34_NRFAT" , _cNrfatura			, Nil})
   aAdd(_aAuxZ34, {"Z34_CODINT", _cCodInteg			, Nil})
   aAdd(_aAuxZ34, {"Z34_DATA"  , _dData				, Nil})
   aAdd(_aAuxZ34, {"Z34_HORA"	 , _cHora				, Nil})
   aAdd(_aAuxZ34, {"Z34_IDINTE", _cIDinte				, Nil})
   aAdd(_aAuxZ34, {"Z34_CNPJTR", _cTCpfCnpj			, Nil})
   aAdd(_aAuxZ34, {"Z34_TOMADO", _cTomador         , Nil})
   aAdd(_aAuxZ34, {"Z34_VRFAT" , _cVrFatura			, Nil})
   aAdd(_aAuxZ34, {"Z34_VRDESC", _nVrDesc				, Nil})
   aAdd(_aAuxZ34, {"Z34_VRACRE", _nVrAcresc			, Nil})
   aAdd(_aAuxZ34, {"Z34_OBS"   , _cObsFatur			, Nil})	
   aAdd(_aAuxZ34, {"Z34_STATUS", Iif(_lRet,"I","N"), Nil})
   aAdd(_aAuxZ34, {"Z34_ERRO"  , _cErro				, Nil})      
   aAdd(_aAuxZ34, {"Z34_COD"   , _cCod					, Nil})
   aAdd(_aAuxZ34, {"Z34_LOJA"  , _cLoja				, Nil})
   aAdd(_aAuxZ34, {"Z34_NOME"  , _cNome				, Nil})

   AOMS148Z34(_aAuxZ34,_cErro,.T.)

   //Monta array de Dados da tabela Z32
   aAdd(_aAuxZ32, {"Z32_FILIAL", _cFilial       , Nil})
   aAdd(_aAuxZ32, {"Z32_NRFAT" , _cNrfatura     , Nil})
   aAdd(_aAuxZ32, {"Z32_IDINTE", _cIDinte       , Nil})
   aAdd(_aAuxZ32, {"Z32_DATA"  , _dData         , Nil})
   aAdd(_aAuxZ32, {"Z32_HORA" , _cHora          , Nil})
   aAdd(_aAuxZ32, {"Z32_TIPOOP", _cTpOper			, Nil})
   aAdd(_aAuxZ32, {"Z32_TIPOCA", _cTpCarga      , Nil})
   aAdd(_aAuxZ32, {"Z32_TOMADO", _cTomador      , Nil})
   aAdd(_aAuxZ32, {"Z32_VRFAT" , _cVrFatura     , Nil})
   aAdd(_aAuxZ32, {"Z32_VRDESC", _nVrDesc       , Nil})
   aAdd(_aAuxZ32, {"Z32_VRACRE", _nVrAcresc     , Nil})
   aAdd(_aAuxZ32, {"Z32_OBS"   , _cObsFatur     , Nil})	
   aAdd(_aAuxZ32, {"Z32_CNPJTR", _cTCpfCnpj     , Nil})
   aAdd(_aAuxZ32, {"Z32_CODINT", _cCodInteg     , Nil})
   aAdd(_aAuxZ32, {"Z32_PAYLOA", _cBody         , Nil})
   aAdd(_aAuxZ32, {"Z32_DTHR"	, _cDtHrFatu		      , Nil})
   aAdd(_aAuxZ32, {"Z32_STATUS", Iif(_lRet,"I","N")   , Nil})
   aAdd(_aAuxZ32, {"Z32_ERRO"  , _cErro				   , Nil})      
   aAdd(_aAuxZ32, {"Z32_COD"   , _cCod				      , Nil})
   aAdd(_aAuxZ32, {"Z32_LOJA"  , _cLoja			      , Nil})
   aAdd(_aAuxZ32, {"Z32_NOME"  , _cNome			      , Nil})

   AOMS148GRV("Z32",_aAuxZ32,.T.,@_nRecnoZ32)

   For _nI := 1 to Len(_aDocs)
      _aAuxZ33 := {}
      aAdd(_aAuxZ33, {"Z33_FILIAL"  , _cFilial				, Nil})
      aAdd(_aAuxZ33, {"Z33_NRFAT"   , _cNrfatura			, Nil})
      aAdd(_aAuxZ33, {"Z33_IDINTE"  , _cIDinte				, Nil})
      aAdd(_aAuxZ33, {"Z33_NRDOC"   , _aDocs[_nI,1]  		, Nil})
      aAdd(_aAuxZ33, {"Z33_TPDOC"   , _aDocs[_nI,2]  		, Nil})
      aAdd(_aAuxZ33, {"Z33_SERDOC"  , _aDocs[_nI,3]  		, Nil})
      aAdd(_aAuxZ33, {"Z33_NRNFE"   , _aDocs[_nI,4]      , Nil})
      aAdd(_aAuxZ33, {"Z33_SERIE"   , _aDocs[_nI,5]      , Nil})
      aAdd(_aAuxZ33, {"Z33_VRTOT"   , _aDocs[_nI,6]      , Nil})
      aAdd(_aAuxZ33, {"Z33_NRCARGA"	, _aDocs[_nI,7]      , Nil})
      aAdd(_aAuxZ33, {"Z33_PROTCAR"	, _aDocs[_nI,8]      , Nil})
      aAdd(_aAuxZ33, {"Z33_PROTPED"	, _aDocs[_nI,9]      , Nil})
      aAdd(_aAuxZ33, {"Z33_CHVCTE"	, _aDocs[_nI,10]		, Nil})
      aAdd(_aAuxZ33, {"Z33_CODINT"	, _cCodInteg			, Nil})

      AOMS148GRV("Z33",_aAuxZ33,.T.)
   Next

Return(.T.)

/*
===============================================================================================================================
Programa----------: AOMS148GRV
Autor-------------: Igor Melgaço
Data da Criacao---: 03/04/2025
===============================================================================================================================
Descrição---------: Grava tabelas Muro
===============================================================================================================================
Parametros--------: _cTabela, _aCampos, _lInclui, _nRecno
===============================================================================================================================
Retorno-----------: _lRet   
===============================================================================================================================
*/
Static Function AOMS148GRV(_cTabela As Character,_aCampos as Array,_lInclui as Logical,_nRecno As Numeric) As Logical
Local _lRet As Logical
Local _cErro As Character
Local _ni As Numeric

Default _nRecno := 0

_lRet  := .T.
_cErro := ""
_ni    := 0

Begin Transaction

   If (_cTabela)->(RecLock(_cTabela,_lInclui))
      For _ni := 1 To Len(_aCampos)
         (_cTabela)->&(_aCampos[_ni,1]) := _aCampos[_ni,2]
      Next
      (_cTabela)->(MsUnLock())

      _nRecno := (_cTabela)->(Recno())

        _lRet := .T.
   Else
      _lRet := .F.
      _cErro += "AOSM148GRV: [ "+MostraErro(Upper(GetSrvProfString("STARTPATH","")),"AOMS148.LOG")+" ]"
      DisarmTransaction()
   EndIf

End Transaction

Return(_lRet)

/*
===============================================================================================================================
Programa----------: AOMS148GNU
Autor-------------: Igor Melgaço
Data da Criacao---: 03/04/2025
===============================================================================================================================
Descrição---------: Retorna proximo numero de integração
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: _cRetorno   
===============================================================================================================================
*/
Static Function AOMS148GNU() as Character
   Local _cRetorno As Character
   Local _cQuery As Character
   Local _nTam As Numeric
   Local _cAliasZ32 As Character

   _cRetorno := ""
   _cQuery   := ""
   _nTam     := Len(Z32->Z32_IDINTE)
   _cAliasZ32 := GetNextAlias()

   //////////////////////////////////////////////////////
   //Resgata ID de integração
   //////////////////////////////////////////////////////		
   _cQuery := " SELECT MAX(Z32_IDINTE) AS ID "
   _cQuery += " FROM " + RetSqlName("Z32")
   _cQuery += " WHERE D_E_L_E_T_ <> '*'"

   MPSysOpenQuery( _cQuery , _cAliasZ32)
   
   DbSelectArea(_cAliasZ32)
   DbGoTop()

   _cRetorno := StrZero(Val(Right(Alltrim((_cAliasZ32)->ID),_nTam))+1,_nTam)

   Do While !MayIUseCode( "Z32_IDINTE"+xFilial("Z32")+_cRetorno)  //verifica se esta na memoria, sendo usado
      _cRetorno := Soma1(_cRetorno)						 // busca o proximo numero disponivel
   EndDo

   DbSelectArea(_cAliasZ32)
   DbCloseArea()

Return _cRetorno


/*
===============================================================================================================================
Programa----------: AOMS148VT
Autor-------------: Igor Melgaço
Data da Criacao---: 03/04/2025
===============================================================================================================================
Descrição---------: Valida Transportadora
===============================================================================================================================
Parametros--------: _cCnpj, _cCod, _cLoja, _cNome, _cErro
===============================================================================================================================
Retorno-----------: _lRet   
===============================================================================================================================
*/
Static Function AOMS148VT(_cCnpj As Character,_cCod As Character,_cLoja As Character,_cNome As Character,_cErro As Character) As Logical
Local _lRet As Logical
Local _cNewCnpj As Character
Local _nI As Numeric

_lRet := .F.
_cCnpj := Alltrim(_cCnpj)
_cNewCnpj := ""
_nI = 0

For _nI := 1 To Len(_cCnpj)
   If Substr(_cCnpj,_ni,1) $ "0123456789"
      _cNewCnpj += Substr(_cCnpj,_ni,1)
   EndIf
Next

DbselectArea("SA2")
DbSetOrder(3)
If Dbseek(xFilial("SA2")+_cNewCnpj)
   _cCod  := SA2->A2_COD
   _cLoja := SA2->A2_LOJA
   _cNome := SA2->A2_NREDUZ

   If SA2->A2_MSBLQL
      _lRet := .F.
      _cErro := "Transportadora bloqueada!"
   Else
      _lRet := .T.
   EndIf
Else
   _lRet := .F.
   _cErro := "Transportadora não encontrada!"
EndIf

Return _lRet


/*
===============================================================================================================================
Programa----------: AOMS148VF
Autor-------------: Igor Melgaço
Data da Criacao---: 03/04/2025
===============================================================================================================================
Descrição---------: Verifica o Saldo dos titulos
===============================================================================================================================
Parametros--------: _cCod, _cLoja, _cNome, _cSerie, _cNumero, _nValor, _cErro, _aRecnos
===============================================================================================================================
Retorno-----------: _lRet   
===============================================================================================================================
*/
Static Function AOMS148VF(_cCod As Character,_cLoja As Character,_cNome As Character,_cSerie As Character,_cNumero As Character,_nValor As Numeric,_cErro As Character,_aRecnos As Array) As Logical
Local _lRet    As Logical
Local _nSaldo  As Numeric

_lRet    := .F.
_nSaldo  := 0

_cCnpj := Alltrim(_cCnpj)
_cSerie := U_ITKEY(_cSerie,"E2_PREFIXO")
_cNumero := U_ITKEY(_cNumero,"E2_NUM")
_cNumero := StrZero(Val(_cNumero),Len(_cNumero))

SA2->(DbSetOrder(1))
ZZN->(DbSetOrder(9))

DbselectArea("SE2")
DbSetOrder(6)
If Dbseek(xFilial("SE2")+_cCod+_cLoja+_cSerie+_cNumero)
   Do While xFilial("SE2")+_cCod+_cLoja+_cSerie+_cNumero == SE2->(E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM) .AND. SE2->(!EOF())
      _nSaldo += SE2->E2_SALDO
      AADD(_aRecnos,SE2->(Recno()))
      SE2->(DbSkip())
   EndDo

   If _nSaldo =  _nValor
      _lRet := .T.
   Else
      _lRet := .F.
      _cErro := " O saldo dos titulos diferem do valor do documento "+_cNumero+" para geração da fatura."
   EndIf
Else
   _lRet := .F.
   _cErro := " Não encontrado titulos do Documento "+_cNumero+" para geração da fatura."
EndIf

Return _lRet



/*
===============================================================================================================================
Programa----------: AOMS148SE()
Autor-------------: Igor Melgaço
Data da Criacao---: 03/04/2025
===============================================================================================================================
Descrição---------: Gravação da tabela Z34
===============================================================================================================================
Parametros--------: _aAuxZ34, _cErro, _lBeginTra
===============================================================================================================================
Retorno-----------: _lContinua
===============================================================================================================================
*/
Static Function AOMS148Z34(_aAuxZ34 As Array,_cErro As Character,_lBeginTra As Logical) As Logical
   Local _ni  As Numeric
   Local _nPos As Numeric
   Local _cNrFat As Character
   Local _lContinua As Logical
   Local _lInclui As Logical

   _ni        := 0
   _nPos      := 0
   _cNrFat   := ""
   _lContinua := .F.
   _lInclui   := .F. 

   If !(Len(_aAuxZ34) > 0)
      Return .F.
   EndIf

   If (_nPos := ASCAN(_aAuxZ34,{|A|A[1]=="Z34_NRFAT"})) <> 0
      _cNrFat := _aAuxZ34[_nPos,2]
   Else
      Return .F.
   EndIf

   DbSelectArea("Z34")
   DbSetOrder(1)
   If Dbseek(xFilial("Z34")+_cNrFat)
      If Z34->Z34_STATUS == "G" 
         _lContinua := .F.
         _cErro += " Registro ja incluido anteriormente"
      Else
         _lContinua := .T.
      EndIf
      _lInclui := .F.
   Else
      _lContinua := .T.
      _lInclui := .T.
   EndIf

   If _lContinua
      If _lBeginTra
         Begin Transaction
            Z34->(RecLock("Z34",_lInclui))
            For _ni := 1 To Len(_aAuxZ34)
               Z34->&(_aAuxZ34[_ni,1]) := _aAuxZ34[_ni,2]
            Next
            Z34->(MsUnLock())

            _nRecnoZ34 := Z34->(Recno())
         End Transaction
      Else
         Z34->(RecLock("Z34",_lInclui))
         For _ni := 1 To Len(_aAuxZ34)
            Z34->&(_aAuxZ34[_ni,1]) := _aAuxZ34[_ni,2]
         Next
         Z34->(MsUnLock())
      EndIf
      _nRecnoZ34 := Z34->(Recno())
   EndIf

Return _lContinua

/*
===============================================================================================================================
Programa----------: AOMS148Arq
Autor-------------: Igor Melgaço
Data da Criacao---: 03/04/2025
===============================================================================================================================
Descrição---------: Rotina para criação do arquivo temporário
===============================================================================================================================
Parametros--------: _aRecnos, _cNome, _cErro
===============================================================================================================================
Retorno-----------: _lRet
===============================================================================================================================
*/
Static Function AOMS148Arq(_aRecnos As Array,_cNome As Character,_cErro As Character) As Logical
Local nUsado   As Numeric
Local _lTemReg As Logical
Local aEstru   As Array
Local _aSE2    As Array
Local nQtdTit  As Numeric
Local nValTit  As Numeric
Local _nI      As Numeric
Local _oTRBF   As Object

nUsado   := 0
_lTemReg :=.F.
aEstru   := {}
_aSE2    := {}
nQtdTit  := 0
nValTit  := 0
_nI      := 0
_oTRBF   := Nil

AADD(_aSE2,"E2_PREFIXO")
AADD(_aSE2,"E2_NUM"    )
AADD(_aSE2,"E2_PARCELA")
AADD(_aSE2,"E2_TIPO"   )
AADD(_aSE2,"E2_NATUREZ")
AADD(_aSE2,"E2_FORNECE")
AADD(_aSE2,"E2_LOJA"   )
AADD(_aSE2,"E2_EMISSAO")
AADD(_aSE2,"E2_VENCREA")
AADD(_aSE2,"E2_VALOR"  )
AADD(_aSE2,"E2_SALDO"  )
AADD(_aSE2,"E2_BAIXA"  )
AADD(_aSE2,"E2_HIST"   )
AADD(_aSE2,"E2_DATALIB")
AADD(_aSE2,"E2_USUALIB")
AADD(_aSE2,"E2_SDDECRE")
AADD(_aSE2,"A2_NOME")

For nUsado := 1 TO LEN(_aSE2)
   AADD( aEstru , {  Getsx3cache(_aSE2[nUsado],"X3_CAMPO")  ,;
                     Getsx3cache(_aSE2[nUsado],"X3_TIPO")   ,;
                     Getsx3cache(_aSE2[nUsado],"X3_TAMANHO"),;
                     Getsx3cache(_aSE2[nUsado],"X3_DECIMAL")})
Next

AADD(aEstru,{"REC_SE2","N",10,0})
AADD(aEstru,{"OK"     ,"C",02,0})
AADD(aEstru,{"VLR_FAT","N",15,5})
AADD(aEstru,{"TIPO"   ,"C",01,0})
AADD(aEstru,{"PODALT" ,"L",01,0})
AADD(aEstru,{"PODEST" ,"L",01,0})

//================================================================================
// Verifica se ja existe um arquivo com mesmo nome, se sim deleta.
//================================================================================
If Select("TRBF") > 0
   TRBF->(DbCloseArea())
EndIf

If ValType(_oTRBF) == "O"
   _oTRBF:Delete()
EndIf

_oTRBF := FWTemporaryTable():New( "TRBF", aEstru )
_oTRBF:AddIndex( "TR", {"E2_NUM"       } )
_oTRBF:AddIndex( "CO", {"TIPO","E2_NUM"} )
_oTRBF:AddIndex( "DT", {"E2_EMISSAO","E2_NUM"} )
_oTRBF:Create()

DbselectArea("SE2")
For _nI := 1 To Len(_aRecnos)
   SE2->(DbGoTo(_aRecnos[_nI]))

   _cOK := "X"

   TRBF->(DBAPPEND())
   AVREPLACE("SE2","TRBF")

   TRBF->A2_NOME := _cNome
   TRBF->REC_SE2 := SE2->(Recno())
   TRBF->VLR_FAT := SE2->E2_SALDO - SE2->E2_SDDECRE
   TRBF->PODALT  := (SE2->E2_DECRESC = 0)
   TRBF->PODEST  := Iif(SE2->E2_SALDO == SE2->E2_VALOR ,.T.,.F.)
   
   If SE2->E2_TIPO = "NDF"
      TRBF->TIPO     := "9" //Nota de debito //AZUL
      TRBF->E2_SALDO := SE2->E2_SALDO*(-1)
      TRBF->E2_VALOR := SE2->E2_VALOR*(-1)
      TRBF->VLR_FAT  := TRBF->VLR_FAT*(-1)
      _cOK           := _cMarca
   ElseIf ZZN->(DBSEEK(cFilant+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA))
      TRBF->TIPO := "1" //Com canhoto com zzn //VERDE
      _cOK       := _cMarca
   Else
      TRBF->TIPO := "5" //Sem canhoto //AMARELO
   EndIf

   TRBF->OK := _cOK

   If !Empty(_cOK)
      nQtdTit++
      nValTit += TRBF->VLR_FAT
   EndIf

   _lTemReg:=.T.

Next

ZZN->(DbSetOrder(1))

_aTRBF := {}

TRBF->(DbSetOrder(2))
TRBF->(DbGoTop())
Do While TRBF->(!EOF())
   _aItens := {}
   
   AADD(_aItens,TRBF->OK        )//01
   AADD(_aItens,TRBF->E2_PREFIXO)//02
   AADD(_aItens,TRBF->E2_NUM    )//03
   AADD(_aItens,TRBF->E2_PARCELA)//04
   AADD(_aItens,TRBF->E2_TIPO   )//05
   AADD(_aItens,TRBF->E2_NATUREZ)//06
   AADD(_aItens,TRBF->E2_LOJA   )//07
   AADD(_aItens,TRBF->E2_EMISSAO)//08
   AADD(_aItens,TRBF->E2_VENCREA)//09
   AADD(_aItens,TRBF->E2_VALOR  )//10
   AADD(_aItens,TRBF->E2_SALDO  )//11
   AADD(_aItens,TRBF->E2_BAIXA  )//12
   AADD(_aItens,TRBF->E2_HIST   );_nPosHistoric:=LEN(_aItens)//13   _nPosHistoric se mudar atera essa variavel
   AADD(_aItens,TRBF->E2_DATALIB)//14
   AADD(_aItens,TRBF->E2_USUALIB)//15
   AADD(_aItens,TRBF->E2_SDDECRE);_nPosDesconto:=LEN(_aItens)//16 	_nPosDesconto se mudar atera essa variavel
   AADD(_aItens,TRBF->VLR_FAT   )//17
   AADD(_aItens,TRBF->E2_FORNECE)//18
   AADD(_aItens,TRBF->TIPO      )//19
   AADD(_aItens,TRBF->A2_NOME   )//20
   AADD(_aItens,TRBF->(RECNO()) )//21 - ULITMO SEMPRE

   AADD(_aTRBF,_aItens)

   TRBF->( DBSkip() )
EndDo
TRBF->(DbGotop())

_lRet := AOMS148GE(.T.,@_cErro)

Return _lRet


/*
===============================================================================================================================
Programa----------: AOMS148GE()
Autor-------------: Igor Melgaço
Data da Criacao---: 03/04/2025
===============================================================================================================================
Descrição---------: Le Titulos marcados para gera os Faturas
===============================================================================================================================
Parametros--------: _lGera, _cErro
===============================================================================================================================
Retorno-----------: _lRetorno
===============================================================================================================================
*/
Static Function AOMS148GE(_lGera As Logical,_cErro As Character) As Logical
   Local T           As Numeric
   Local _aCab       As Array
   Local _aSize      As Array
   Local _lRet       As Logical
   Local _cNrTitulos As Character
   Local _lEMail     As Logical
   Local _lRetorno   As Logical

   Private _aTLinhas := {}

   T           := 0
   _aCab       := {}
   _aSize      := {}
   _lRet       := .T.
   _cNrTitulos := ""
   _lEMail     := .F.
   _lRetorno   := .T.

   _aTLinhas := {}

   _nConta := 0

   TRBF->(DbGoTop())
   Do While TRBF->(!EOF())
      If _lEMail
         If !Empty(TRBF->OK)
            _nConta++
         EndIf
      ElseIf _lGera .AND. !Empty(TRBF->OK)//GERACAO
         _nConta++
      ElseIf !_lGera .AND. !Empty(TRBF->OK)//ESTORNO
         _nConta++
      EndIf

      If ! Empty(TRBF->OK) .And. ! TRBF->PODEST .And. !_lGera // Titulos que não podem ser estornados.
         _cNrTitulos += If(Empty(_cNrTitulos),"",", ") + Alltrim(TRBF->E2_NUM) + If(!Empty(TRBF->E2_PARCELA),"-","") + Alltrim(TRBF->E2_PARCELA)
      EndIf

      TRBF->(Dbskip())
   EndDo

   If _nConta = 0
      
      If _lEMail
         U_ITMSG("Nenhum Fatura Selecionada","Atenção",,1)
      Else
         U_ITMSG("Nenhum Titulo Selecionado","Atenção",,1)
      EndIf

      Return .F.

   EndIf

   If ! Empty(_cNrTitulos)
      U_ITMSG("Os títulos: " + _cNrTitulos + ", não podem ser estornados pois estão compensados parcialmente ou totalmente. ","Atenção",,1)
      Return .F.
   EndIf

   _cTot   := Alltrim(STR(_nConta))
   _nTam   := Len(_cTot) + 1
   _nConta := 0

   SE2->( DbSetOrder(1) ) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

   aTitulos:={}
   aTitAlt :={}

   If _lEMail //REENVIO DE E-MAIL
      TRBF->(DbSetOrder(3))
   EndIf

   SA2->( DbSetOrder(1) )

   TRBF->(DbGoTop())
   SE2->(DbGoTo(TRBF->REC_SE2))

   Private _dDtIni :=""//SE2->E2_EMISSAO//PRIMEIRO DA LISTA
   Private _dDtFim :=""//SE2->E2_EMISSAO//PRIMEIRO DA LISTA
   
   _aChaveFAT := {}

   Do While TRBF->(!EOF())

      SE2->(DbGoTo(TRBF->REC_SE2))
      If _lEMail //REENVIO DE E-MAIL

         If !Empty(TRBF->OK)
            _nConta++

            AOMS148Tit(oProc,TRBF->REC_SE2,.T.)//CARREGA OS TITULOS DA FATURA NO _aTLinhas
            
            _aItens := {}//REENVIO _lEmail TIRULOS + FATURA

            AADD(_aItens,.T.              )//01
            AADD(_aItens,TRBF->E2_PREFIXO )//02
            AADD(_aItens,TRBF->E2_NUM     )//03
            AADD(_aItens,TRBF->E2_PARCELA )//04
            AADD(_aItens,TRBF->E2_TIPO    )//05
            AADD(_aItens,TRBF->E2_NATUREZ )//06
            AADD(_aItens,TRBF->E2_FORNECE )//07
            AADD(_aItens,TRBF->E2_LOJA    )//08
            AADD(_aItens,DTOC(TRBF->E2_EMISSAO))//09
            AADD(_aItens,DTOC(TRBF->E2_VENCREA))//10
            AADD(_aItens,Alltrim(TRANSFORM((TRBF->E2_SALDO-TRBF->E2_SDDECRE)*IF(TRBF->E2_TIPO="NDF",-1,1),"@E 999,999,999,999.99")))//11 // tira o desocnto para ficar = ao envio
            AAdd(_aItens,Alltrim(TRANSFORM(TRBF->E2_SDDECRE,"@E 999,999,999,999.99")))//12
            AADD(_aItens,TRBF->E2_HIST)         //13
            AADD(_aItens,"Gerado com sucesso")  //14
            AADD(_aItens,(TRBF->E2_SALDO-TRBF->E2_SDDECRE)*IF(TRBF->E2_TIPO="NDF",-1,1))//15
            AAdd(_aItens,TRBF->E2_SDDECRE)//16
            AADD(_aTLinhas,_aItens)
            AADD(_aChaveFAT, TRBF->REC_SE2 )//RENNO DA FATURA NO SE2 P/ O ANEXO

         EndIf

      ElseIf _lGera .AND. !Empty(TRBF->OK)//GERACAO
         _nConta++

         If Empty(_dDtIni) .OR. SE2->E2_EMISSAO < _dDtIni
            _dDtIni := SE2->E2_EMISSAO
         EndIf

         If Empty(_dDtFim) .OR. SE2->E2_EMISSAO > _dDtFim
            _dDtFim := SE2->E2_EMISSAO
         EndIf

         // Considerar Loja do Fornededor 08/04/2021  AADD(aTitulos,{SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA , SE2->E2_TIPO,.F.})//,SE2->E2_FORNECE,SE2->E2_LOJA
         AADD(aTitulos,{SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA , SE2->E2_TIPO,.F.,SE2->E2_FORNECE,SE2->E2_LOJA	  })

         If ASCAN(aTitAlt,{|A|A[5]==TRBF->E2_FORNECE}) = 0 .AND. SA2->(Dbseek(xfilial("SA2")+TRBF->E2_FORNECE))
            If Empty(SA2->A2_BANCO) .OR. Empty(SA2->A2_AGENCIA) .OR. Empty(SA2->A2_NUMCON)
               U_ITMSG("Banco ou agencia ou conta do cadastro do fornecedor não preenchido","Atenção",;
                  "Cadastre para o fornecedor+loja: "+TRBF->E2_FORNECE+" "+SA2->A2_LOJA+" - "+SA2->A2_NREDUZ,1)
               Return .F.
            EndIf
         EndIf

         AADD(aTitAlt ,{TRBF->REC_SE2   ,;//1
                        TRBF->E2_SDDECRE,;//2
                        (TRBF->E2_SDDECRE <> SE2->E2_SDDECRE .OR. TRBF->E2_HIST <> SE2->E2_HIST ),;//3
                        TRBF->E2_HIST   ,;//4
                        TRBF->E2_FORNECE})//5


      ElseIf !_lGera .AND. !Empty(TRBF->OK) //ESTORNO
         _nConta++

         AOM115Estorno(oProc)//ESTORNO DA FATURA
      EndIf

      TRBF->(Dbskip())

   EndDo
   
   TRBF->(DbGoTop())

   _cTot   := Alltrim(STR(LEN(aTitAlt)))
   _nTam   := Len(_cTot)+1
   _nConta := 0

   _lAlterouTodas := .T.

   IF _lGera .AND. LEN(aTitulos) > 0
      FOR T:= 1 TO LEN(aTitAlt)
         SE2->(DbGoTo( aTitAlt[T,1] ))
         _nConta++

         IF aTitAlt[T,3] .AND. !AOM114Altera(oProc,aTitAlt[T])//ALTERA E APROVEITA LIBERA OS TITULOS COM ALTERACAO DO DESCONTO E HISTORICO
            _lRet:=_lAlterouTodas:=.F.
            EXIT
         ENDIF
      NEXT

      IF _lAlterouTodas
      
         _nConta := 0
      
         FOR T:= 1 TO LEN(aTitAlt)
            _nConta++

            IF !aTitAlt[T,3] //SÓ LIBERA OS SEM ALTERACAO DO DESCONTO
               SE2->(DbGoTo( aTitAlt[T,1] ))
               SE2->(RecLock("SE2",.F.))
               SE2->E2_DATALIB := dDataBase
               SE2->E2_USUALIB := cUserName
               SE2->(MsUnlock())

               _aItens := {} //_lEmail TITULOS
               AADD(_aItens,.T.)
               AADD(_aItens,SE2->E2_PREFIXO)
               AADD(_aItens,SE2->E2_NUM)
               AADD(_aItens,SE2->E2_PARCELA)
               AAdd(_aItens,SE2->E2_TIPO)
               AAdd(_aItens,SE2->E2_NATUREZ)
               AAdd(_aItens,SE2->E2_FORNECE)
               AAdd(_aItens,SE2->E2_LOJA   )
               AAdd(_aItens,DTOC(SE2->E2_EMISSAO))
               AAdd(_aItens,DTOC(SE2->E2_VENCREA))
               AAdd(_aItens,Alltrim(TRANSFORM(SE2->E2_SALDO*IF(SE2->E2_TIPO="NDF",-1,1),"@E 999,999,999,999.99")))//11
               AAdd(_aItens,Alltrim(TRANSFORM(SE2->E2_DECRESC,"@E 999,999,999,999.99")))//12
               AAdd(_aItens,SE2->E2_HIST   )//13
               AADD(_aItens,"Liberado com sucesso")  //14
               AAdd(_aItens,SE2->E2_SALDO*IF(SE2->E2_TIPO="NDF",-1,1))//15
               AAdd(_aItens,SE2->E2_DECRESC)//16
               AADD(_aTLinhas,_aItens)

            ENDIF
         NEXT

         //**********************  GERACAO DA FATURA AQUI *************************************************
         _lRet := AOMS148SE(aTitulos,aTitAlt[1,1])
         //**********************  GERACAO DA FATURA AQUI *************************************************
      ENDIF
   ENDIF

//Monta aheader
   aadd(_aCab,"")//01
   aadd(_aSize,5)
   AAdd(_aCab,Getsx3cache("E2_PREFIXO","X3_TITULO"))//02
   aadd(_aSize,5)
   AAdd(_aCab,Getsx3cache("E2_NUM"    ,"X3_TITULO"))//03
   aadd(_aSize,12)
   AAdd(_aCab,Getsx3cache("E2_PARCELA","X3_TITULO"))//04
   aadd(_aSize,5)
   AAdd(_aCab,Getsx3cache("E2_TIPO"   ,"X3_TITULO"))//05
   aadd(_aSize,5)
   AAdd(_aCab,Getsx3cache("E2_NATUREZ","X3_TITULO"))//06
   aadd(_aSize,8)
   AAdd(_aCab,Getsx3cache("E2_FORNECE","X3_TITULO"))//07
   aadd(_aSize,35)
   AAdd(_aCab,Getsx3cache("E2_LOJA"   ,"X3_TITULO"))//08
   aadd(_aSize,5)
   AAdd(_aCab,"Emissão")//09
   aadd(_aSize,40)
   AAdd(_aCab,Getsx3cache("E2_VENCREA" ,"X3_TITULO"))//10
   aadd(_aSize,40)
   AAdd(_aCab,"Valor Total")//11
   aadd(_aSize,40)
   AAdd(_aCab,Getsx3cache("E2_SDDECRE","X3_TITULO"))//12
   aadd(_aSize,30)
   AAdd(_aCab,Getsx3cache("E2_HIST"   ,"X3_TITULO"))//13
   aadd(_aSize,70)
   AAdd(_aCab,"Resultado / Histórico")//14
   aadd(_aSize,70)

   If Len(_aTLinhas) > 0
      
      nPosResu := Len(_aCab) //Posiçao do "Resultado"

      For T:= 1 TO LEN(_aTLinhas)
         If !_aTLinhas[T,1]
            _cErro += _aTLinhas[T,nPosResu]
            _lRetorno := .F.
         EndIf
      Next

   Else
      _cErro := "Nenhum registro localizado"
      _lRetorno  := .F.
   EndIf

Return _lRetorno


/*
===============================================================================================================================
Programa----------: AOMS148SE()
Autor-------------: Igor Melgaço
Data da Criacao---: 03/04/2025
===============================================================================================================================
Descrição---------: Gera os Faturas dos Transportadores marcaods
===============================================================================================================================
Parametros--------: oProc,_aTitulos,nRecSE2
===============================================================================================================================
Retorno-----------: _lRet
===============================================================================================================================
*/
Static Function AOMS148SE(_aTitulos As Array,nRecSE2 As Numeric) As Logical
   Local _nModAux   As Numeric
   Local _cModAux   As Character
   Local _lRet      As Logical
   Local _cNatureza As Character
   Local _cFornece  As Character
   Local _cLoja     As Character
   Local _cCondicao As Character
   Local _dDtorig   As Date
   Local _nTit      As Numeric
   Local _nDesconto As Numeric
   Local _cHistoric As Character

   _nModAux   := nModulo
   _cModAux   := cModulo
   _lRet      := .T.
   _cNatureza := U_ITGETMV("ITNATFAT","231007")
   _cFornece  := TRBF->E2_FORNECE
   _cLoja     := TRBF->E2_LOJA 
   _cCondicao := "001" //, nSeq
   _dDtorig   := dDataBase
   _nTit      := 0
   _nDesconto := 0
   _cHistoric := ""

   IF DAY(dDataBase) >  23//24 a 31
      _dDtVenc := CTOD("08/"+StrZero( Month(Date())+1 , 2 ) +'/'+ StrZero( Year(Date()) , 4 ))
   ELSEIF DAY(dDataBase) >  8 //9 a 23
      _dDtVenc := CTOD("23/"+StrZero( Month(Date())   , 2 ) +'/'+ StrZero( Year(Date()) , 4 ))
   ELSE//1 a 8
      _dDtVenc := CTOD("08/"+StrZero( Month(Date())   , 2 ) +'/'+ StrZero( Year(Date()) , 4 ))
   ENDIF

   cUserName := cUserName

   _aItens := {} //_lEmail FATURA

   AADD(_aItens,.T.       ) //01
   AADD(_aItens,"MAN"     ) //02
   AADD(_aItens,""        ) //03  PREENCHIDO APOS A GERAÇÃO
   AADD(_aItens,'01'      ) //04
   AADD(_aItens,"FT "     ) //05
   AADD(_aItens,_cNatureza) //06
   AADD(_aItens,_cFornece ) //07
   AADD(_aItens,_cLoja    ) //08
   AADD(_aItens,DTOC(DataValida( _dDtVenc ))) //09
   AADD(_aItens,DTOC(DataValida( _dDtVenc ))) //10
   AADD(_aItens,""        ) //11  PREENCHIDO APOS A GERAÇÃO // 11
   AAdd(_aItens,Alltrim(TRANSFORM(_nDesconto,"@E 999,999,999,999.99"))) //12
   AADD(_aItens,_cHistoric) //13
   AADD(_aItens,""        ) //14 - _cErro
   AADD(_aItens,0         ) //15 - SE2->E2_VALOR-_nDesconto
   AADD(_aItens,_nDesconto) //16

   cLog       := ""
   _cFatura2  := SOMA1(GetMV( 'MV_NUMFATP' ,, '0' ))
   _cChaveFAT := cFilAnt + "MAN" + _cFatura2  + '01' + "FT " + _cFornece+_cLoja
   
   SE2->( DbSetOrder(1) )
   Do While SE2->( DBSeek( _cChaveFAT ) )
      cLog += " / Achou: [ "+_cChaveFAT+" ] "

      PUTMV("MV_NUMFATP", _cFatura2)
      
      _cFatura2  := SOMA1(_cFatura2)
      _cChaveFAT := cFilAnt + "MAN" + _cFatura2  + '01' + "FT " + _cFornece+_cLoja
   EndDo

//Cria Fatura no financeiro
   aArray := {}

   AADD(aArray,"MAN")     //01
   AADD(aArray,"FT" )     //02
   AADD(aArray,' ')       //03 //Em branco para seguir sequência de fatura do Protheus
   AADD(aArray,_cNatureza)//04
   AADD(aArray,_dDtIni)   //05
   AADD(aArray,_dDtFim)   //06
   AADD(aArray,_cFornece) //07
   AADD(aArray,"    ")    //08 //Loja em branco para trazer todos os títulos do fornecedor
   AADD(aArray,_cFornece) //09
   AADD(aArray,_cLoja)    //10
   AADD(aArray,_cCondicao)//11
   AADD(aArray,1)         //12
   AADD(aArray,_aTitulos) //13
   AADD(aArray,_nDesconto)//14
   AADD(aArray,0)         //15

   nModulo	   := 6
   cModulo	   := "FIN"
   lMsErroAuto := .F.
   dDataBase   := DataValida( _dDtVenc )

   SE2->(DbGoTo( nRecSE2 ))//POSICIONA NO PRIMEIRO TITULO DA LISTA

   BEGIN SEQUENCE

      BEGIN TRANSACTION
         DBSELECTAREA( "SE5" )
         MsExecAuto( { |x,y| FINA290(x,y)},3,aArray,) //INCLUSAO DA FATURA

         //cParaVernoDEBUG:=GetMV( 'MV_NUMFATP')

         _cErro := "FATURA Gerada com Sucesso"

         If lMsErroAuto

            _cErro     := Alltrim(MOSTRAERRO())//GETTEMPPATH()))
            _cErro     := "Não Gerou. Acesse Ver Resultado: " + CHR(13) + CHR(10) + Alltrim(_cErro)
            _aItens[1] := .F.
            _lRet      := .F.

            Disarmtransaction()

         ELSE

            _cChaveFAT := cFilAnt + "MAN" + _cFatura2  + '01' + "FT " + _cFornece + _cLoja

            SE2->( DbSetOrder(1) )
            If SE2->( DbSeek( _cChaveFAT ) )

               SE2->( RecLock('SE2',.F.) )
               SE2->E2_VENCTO	 := _dDtVenc
               SE2->E2_VENCORI := _dDtVenc
               SE2->E2_VENCREA := DataValida( _dDtVenc )
               SE2->E2_HIST    := _cHistoric
               SE2->E2_ORIGEM  := "AOMS148"
               SE2->( MsUnlock() )

               _aItens[03] := _cFatura2
               _aItens[11] := Alltrim(Transform(SE2->E2_VALOR-SE2->E2_SDDECRE,"@E 999,999,999,999.99"))
               _aItens[15] := SE2->E2_VALOR - _nDesconto
               
               AADD(_aChaveFAT, SE2->(RECNO()) )

               AOMSGRVFI8(_aTitulos)

            Else

               _cChaveFAT  := cFilAnt + "MAN [ " + _cFatura2  + ' ] 01' + "FT " + _cFornece + _cLoja
               _cErro      := "NÃO GEROU FATURA. Acesse Ver Resultado: "+CHR(13)+CHR(10)+"Titulo da fatura não localizado: "+_cChaveFAT+" / MV_NUMFATP = [ "+GetMV('MV_NUMFATP')+" ] "+cLog
               _aItens[01] := .F.
               _aItens[03] := _cFatura2
               _cChaveFAT  := ""
               _lRet       := .F.

               Disarmtransaction()
               Break

            EndIf

         EndIf

      END TRANSACTION
   END SEQUENCE

   dbSelectArea("SE5")
   dbSetOrder(2)  // FILIAL + TIPODOC + PREFIXO + NUMERO + PARCELA

   For _nTit := 1 To Len(_aTitulos)
      If SE5->(DbSeek(xFilial("SE5") + "DC" + _aTitulos[_nTit][1] + _aTitulos[_nTit][2] + _aTitulos[_nTit][3] + _aTitulos[_nTit][4] + DTOS(DDATABASE) + _aTitulos[_nTit][6] + _aTitulos[_nTit][7]))		
         Reclock("SE5",.F.)
         SE5->E5_TPDESC := "I"
         SE5->(MsUnLock())
      EndIf
   Next _nTit
   SE5->(dbCloseArea())

   _aItens[14] := _cErro //14

   AADD(_aTLinhas,_aItens)

   nModulo   := _nModAux
   cModulo   := _cModAux
   dDataBase := _dDtorig

Return _lRet
