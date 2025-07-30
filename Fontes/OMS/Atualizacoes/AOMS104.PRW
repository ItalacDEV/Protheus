/*
==============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
==============================================================================================================================
Autor         |    Data    |                              Motivo                      										 
------------------------------------------------------------------------------------------------------------------------------
Josué Danich  | 06/08/2018 | Chamado: 25763 - Inclusão de consulta e preenchimento de campo A1_SIMPNAC.
------------------------------------------------------------------------------------------------------------------------------
Josué Danich  | 28/08/2018 | Chamado: 26030 - Ajuste para gravação de muro RDC.
------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 14/10/2019 | Chamado: 28346 - Removidos os Warning na compilação da release 12.1.25. 
------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 26/10/2020 | Chamado: 34262 - Remoção de bugs apontados pelo Totvs CodeAnalysis. 
------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 12/01/2021 | Chamado: 35270 - Corrigir erro na rotina de atualização gerel de clientes 
------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço  | 24/06/2021 | Chamado: 36758 - Implementação de gravação do campo de Suframa. 
------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço  | 24/06/2021 | Chamado: 36758 - Ajuste para gravação do campo de Suframa e Simples Nacional. 
------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço  | 12/07/2021 | Chamado: 36759 - Ajustes para integração com nova plataforma. 
------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço  | 11/08/2022 | Chamado: 40048 - Ajustes para conversão de caracteres na tabela SA1. 
------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 21/12/2022 | Chamado: 42158 - Alterar rotina p/utilizarnovo links/forma de acesso ao CISP.Ajustar novo layout.
------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 28/06/2023 | Chamado: 44289 - Correção de Error Log e Criação de Opção de Filtro por Estado.
------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 28/06/2023 | Chamado: 45374 - Corrigir a rotina para não exibir tela em modo Scheduller.
-------------------------------------------------------------------------------------------------------------------------------
Igor Melgaço  | 30/11/2023 | Chamado: 30952 - Ajuste para nova validação dos campos de endereço do cadastro de Cliente e Fornecedor. 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 23/07/2025 | Chamado 51340. Trocado e-mail padrão para sistema@italac.com.br
==============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "APWEBSRV.CH"
#Include 'Protheus.ch'  
#INCLUDE "TBICONN.CH"   
#INCLUDE "RESTFUL.CH"

#DEFINE ENTER	Chr(13)+Chr(10)
/*
===============================================================================================================================
Programa----------: AOMS104
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/09/2017
===============================================================================================================================
Descrição---------: Rotina integração dados cadastrais cisp/sintegra/receita - Chamado 21086
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS104()

Local cMatUsr			:= U_UCFG001(1) 
Local cAutoriz		:= GetAdvFVal( "ZZL" , "ZZL_ATUCLI" , xFilial("ZZL") + cMatUsr , 1 , "N" )

Private oproc
Private _cdtl := date() - u_itgetmv("ITDIASCLI",30) //data limite de atualização dos clientes
Private bType := {|x| Type(x)}


//-- Controle de acesso por usuario conforme parametrizacao no Gerenciador (Gestao de Usuarios) --//
If !( cAutoriz == "S" )
	U_ITMSG("Usuário sem acesso à rotina de avaliação dos Pedidos bloqueados para análise de Crédito.","Atenção!",,1)
	Return()
EndIf


//Log de utilização
U_ITLOGACS()

aRotina := {{ OemToAnsi("Pesquisar")  , "AxPesqui"   , 0 , 1 },; 
            { OemToAnsi("Visualizar") , 'AxVisual'   , 0 , 2 },; 
            { OemToAnsi("Atualizar")  , "fwmsgrun(,{|oproc|  U_AOMS104A(oproc)},'Aguarde consulta...','Iniciando consulta...')" , 0 , 2 },;
            { OemToAnsi("Atua Geral") , "fwmsgrun(,{|oproc|  U_AOMS104G(oproc)},'Aguarde consulta...','Iniciando consulta...')" , 0 , 2 }}  
 
cCadastro := OemToAnsi( "Integração dados cadastrais CISP/SINTEGRA/RECEITA" )


aCores :=   {{'SA1->A1_I_D3ST > _cdtl ', 'ENABLE'},;        // Atualizado
             {'SA1->A1_I_D3ST <= _cdtl' , 'BR_VERMELHO' }}        // Desautalizado
 
SA1->(MsFilter("SA1->A1_PESSOA == 'J' .AND. SA1->A1_COD	> '000001'"))
MBrowse( ,,,, "SA1" ,,,,,, acores )
SA1->(Dbclearfilter())

Return 

/*
===============================================================================================================================
Programa----------: AOMS104A
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/09/2017
===============================================================================================================================
Descrição---------: Chamad de webservice de atualização do CISP/SINTEGRA
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
					_lemail - determina se envia email de aviso de alteração individual
					_aaju - array de retorno do ajuste
					_lgrava - grava resultados
					_csintegra - objeto de dados do sintegra
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS104A(oproc,_lemail,_aaju,_lgrava,_cSint)
//Local cUrlSintegra := "/sintegra/v1/cnpj/" + alltrim(SA1->A1_CGC)
Local cUrlReceita  := "/receita-federal/v1/cnpj/" + alltrim(SA1->A1_CGC)
Local cUrlSimples  := "/simples-nacional/v1/cnpj/" + alltrim(SA1->A1_CGC)
Local cUrlSuframa  := "/suframa/v1/cnpj/" + alltrim(SA1->A1_CGC)
Local cUrlcisp     := "https://servicos.cisp.com.br/v1/avaliacao-analitica/raiz/" + substr(alltrim(SA1->A1_CGC),1,8)
Local aHeadOut        := {}
Local cHdSintegra     := ""
Local cCorSintegra    := ""
Local _osintegra
Local cHdReceita      := ""
Local cCorReceita     := ""
Local _oReceita
Local cHdSuframa      := ""
Local cCorSuframa     := ""
Local _oSuframa   
Local cHdSimples      := ""
Local cCorSimples     := ""
Local _osimples
Local _lret           := .T.
Local _ldivuf         := .F.
Local _lbloqueia      := .F.
Local _lerro          := .F.
Local _cerro          := ""
Local _lisento 		  := .F.
Local _latu           := .F.
Local _cSufra         := ""
Local _cSufrn         := ""
Local _cSuframa       := ""
Local _lGrvSufr       := .F.
Local _lGrvSimp       := .F.
Local _cDtSufrAt      :=  ""
Local _lLinkPrd       := U_ItGetMv("IT_LKCISPP", .T.)
Local _nI 
Local _cpasswd        := u_itgetmv("IT_PWCISP","!t@lac95_01#")
Local _cuser	      := u_itgetmv("IT_USCISP","ws09501")
Local _cDecodeTxt     := ""

Default oproc         := nil
Default _lemail		  := .T.
Default _aaju         := {}
Default _lgrava       := .T.
Default _cSint        := nil

Begin Sequence

   //Não atualiza cliente bloqueado
   If (SA1->A1_MSBLQL = "1")

      If _lgrava
         u_itmsg("Não atualiza cliente bloqueado","Atenção",,1)
      Endif
	  _lret :=  .F.
	  Break
	
    Endif


   //Só atualiza pessoas juridicas
   If !(SA1->A1_PESSOA = "J")

      If _lgrava
    	 u_itmsg("Não é pessoa jurídica","Atenção",,1)
      Endif
	  _lret :=  .F.
	  Break
	
   Endif
  
   //Não atualiza clientes marcados como não atualizaveis
   If SA1->A1_I_ATCIS == "N"
      If _lgrava
    	 u_itmsg("Cliente marcado como não atualizável via Cisp","Atenção",,1)
      Endif
	  _lret :=  .F.
	  Break
	
   Endif

   If _lLinkPrd
      //====================================================================
      // Link base produção
      //====================================================================
      cUrlsintegra := "https://api.maxxi.cisp.com.br/public-bases/v1/sintegra/cnpj/" + Alltrim(SA1->A1_CGC )+ "/uf/" + AllTrim(SA1->A1_EST) + "?key=dwnljGS5DRJ0BkzGGgRsrNZCUxqdqrZw" //"https://servicos.cisp.com.br/v1/sintegra/" + alltrim(M->ZX_CGC)
      cUrlreceita  := "https://api.maxxi.cisp.com.br/public-bases/v1/receita-federal/cnpj/"+ alltrim(SA1->A1_CGC) + "?key=dwnljGS5DRJ0BkzGGgRsrNZCUxqdqrZw" //"https://servicos.cisp.com.br/v1/receita-federal/" + alltrim(M->ZX_CGC)
      cUrlsimples  := "https://api.maxxi.cisp.com.br/public-bases/v1/simples-nacional/cnpj/"+ alltrim(SA1->A1_CGC) + "?key=dwnljGS5DRJ0BkzGGgRsrNZCUxqdqrZw" //"https://servicos.cisp.com.br/v1/simples-nacional/" + alltrim(M->ZX_CGC)
      //cUrlSuframa  := "https://api.maxxi.cisp.com.br/public-bases/v1/suframa/cnpj/"+ alltrim(SA1->A1_CGC) + "?key=dwnljGS5DRJ0BkzGGgRsrNZCUxqdqrZw" 
      cUrlSuframa  := "https://api.maxxi.cisp.com.br/public-bases/v1/suframa/cnpj/"+ alltrim(SA1->A1_CGC)+ "/uf/" + AllTrim(SA1->A1_EST) +"?key=dwnljGS5DRJ0BkzGGgRsrNZCUxqdqrZw"                      
   Else 
      //====================================================================
      // Link base homologação
      //====================================================================
      cUrlsintegra := "https://api-homol.maxxi.cisp.com.br/public-bases/v1/sintegra/cnpj/"+ Alltrim(SA1->A1_CGC) + "/uf/" + AllTrim(SA1->A1_EST) + "?key=43c629ff-e72e-4172-a0fe-ffdef386573a" //"https://servicos.cisp.com.br/v1/sintegra/" + alltrim(M->ZX_CGC)
      cUrlreceita  := "https://api-homol.maxxi.cisp.com.br/public-bases/v1/receita-federal/cnpj/"+ alltrim(SA1->A1_CGC) + "?key=43c629ff-e72e-4172-a0fe-ffdef386573a" //"https://servicos.cisp.com.br/v1/receita-federal/" + alltrim(M->ZX_CGC)
      cUrlsimples  := "https://api-homol.maxxi.cisp.com.br/public-bases/v1/simples-nacional/cnpj/"+ alltrim(SA1->A1_CGC) + "?key=43c629ff-e72e-4172-a0fe-ffdef386573a" //"https://servicos.cisp.com.br/v1/simples-nacional/" + alltrim(M->ZX_CGC)
      //cUrlSuframa  := "https://api-homol.maxxi.cisp.com.br/public-bases/v1/suframa/cnpj/"+ alltrim(SA1->A1_CGC) + "?key=43c629ff-e72e-4172-a0fe-ffdef386573a" //"https://servicos.cisp.com.br/v1/simples-nacional/" + alltrim(M->ZX_CGC)
      cUrlSuframa  := "https://api-homol.maxxi.cisp.com.br/public-bases/v1/suframa/cnpj/"+ alltrim(SA1->A1_CGC) + "/uf/" + AllTrim(SA1->A1_EST) + "?key=43c629ff-e72e-4172-a0fe-ffdef386573a" //"https://servicos.cisp.com.br/v1/simples-nacional/" + alltrim(M->ZX_CGC)
   EndIf 

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
   _ocisp   := nil
   _acisp := strtokarr(cHdcisp,chr(10))

   //Verifica e formata resposta do cisp
   If substr(cHdcisp,1,15) == "HTTP/1.1 200 OK" .and. FWJsonDeserialize(cCorcisp,@_ocisp)
	  _cNome   := _ocisp:cliente:razaosocial
	  _cNReduz := _ocisp:cliente:nomefantasia
   EndIf 

   //======================================================
   // Consultando SINTEGRA
   //======================================================
   aHeadOut := {} 
   aAdd( aHeadOut , "accept:application/json")

   IF valtype(oproc) = "O"
   	  oproc:cCaption := ("Consultando Sintegra...")
   	  ProcessMessages()
   ENDIF

   //Faz chamada ao webservice do Sintegra

   cCorSintegra := HttpGet(cUrlsintegra,"",NIL,aHeadOut,@cHdSintegra)
   _lisento := .F.

   //cCorSintegra := DecodeUTF8(cCorSintegra, "cp1252")  
   _cDecodeTxt := ""
   If ! Empty(cCorSintegra)
      _cDecodeTxt := DecodeUTF8(cCorSintegra, "cp1252")
   EndIf

   If ! Empty(_cDecodeTxt)
      cCorSintegra := _cDecodeTxt
   EndIf    

   _oJson := JsonObject():new() 

   _cRet := _oJson:FromJson(cCorSintegra)

   //Verifica e formata resposta do Sintegra 
   If !(substr(cHdSintegra,10,3) == "200" .and. ValType(_cRet) == "U" ) //FWJsonDeserialize(cCorSintegra,@_oSintegra) .and. Len(_oSintegra:Sintegras) > 0)
      
	  If _lgrava
         u_itmsg("Falha no webservice do sintegra","Atenção",cHdSintegra,1)
      EndIf 

      _lRet := .F.
      _lErro := .T.
      _cErro := cHdSintegra
    
      Reclock("SA1",.F.)
      SA1->A1_I_SCST := "ERRO DE CONSULTA"
  	   SA1->A1_I_D1ST := STOD("20010101")
  	   SA1->A1_I_D2ST := STOD("20010101") //Grava uma data impossível para facilitar localização de registros com problema de consulta
  	   SA1->A1_I_D3ST := DATE()
  	   SA1->A1_I_HRST := TIME()
      SA1->(Msunlock())
   
      Break
   Endif

   //=======================================================
   // remover caracteres especiais neste trecho. 
   //=======================================================
   cCorSintegra := StrTran(cCorSintegra,"º"," ")
   cCorSintegra := StrTran(cCorSintegra,"ª"," ") 
   cCorSintegra := StrTran(cCorSintegra,"´"," ") 
   cCorSintegra := StrTran(cCorSintegra,"`"," ") 
   cCorSintegra := StrTran(cCorSintegra,"^"," ") 
   cCorSintegra := StrTran(cCorSintegra,"~"," ") 

   _aNames := _oJson:GetNames()
 
   _osintegra := _oJson:GetJsonObject("company")

   If ValType(_osintegra) == "A" .And. Len(_osintegra) == 0
      If _lgrava
         u_itmsg("Falha no webservice do sintegra","Atenção","Json de retorno incompleto: "+ CRLF + cCorSintegra,1)
      EndIf 
    
      _lRet := .F.
      _lErro := .T.
      _cErro := "Json de retorno incompleto: " + CRLF + cCorSintegra
    
      Reclock("SA1",.F.)
      SA1->A1_I_SCST := "ERRO DE CONSULTA"
      SA1->A1_I_D1ST := STOD("20010101")
  	  SA1->A1_I_D2ST := STOD("20010101") //Grava uma data impossível para facilitar localização de registros com problema de consulta
  	  SA1->A1_I_D3ST := DATE()
  	  SA1->A1_I_HRST := TIME()
      SA1->(Msunlock())
   
      Break
   EndIf 

   _osintegra := _osintegra[1] 

   _nI := Ascan(_aNames, "updateDate" )
   If _nI > 0
      _cDtAlter := _oJson[_aNames[_nI]]
   EndIf 

   _oDoctos := _osintegra:GetJsonObject("documents") //_oJson:GetJsonObject("document")
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
  
   IF valtype(oproc) = "O"
   	  oproc:cCaption := ("Consultando Receita...")
   	  ProcessMessages()
   ENDIF

   //Faz chamada ao webservce da Receita
   cCorReceita  := HttpGet(cUrlReceita,"",NIL,aHeadOut,@cHdReceita)
   _lerrorec    := .F. 

   _cDecodeTxt := ""
   //cCorReceita := DecodeUTF8(cCorReceita, "cp1252")  
   If ! Empty(cCorReceita)
      _cDecodeTxt := DecodeUTF8(cCorReceita, "cp1252")  
   EndIf 

   If ! Empty(_cDecodeTxt)
      cCorReceita :=_cDecodeTxt
   EndIf 

   _oJsonRec   := JsonObject():new()

   _cRetRec := _oJsonRec:FromJson(cCorReceita) // FromJson(cCorSintegra)

   _lerrorec := .F. 
  
   //Verifica e formata resposta da Receita
   If !(substr(cHdReceita,10,3) == "200" .and.  ValType(_cRetRec) == "U" ) //( substr(cHdReceita,1,6) == "200 OK" .and.FWJsonDeserialize(cCorReceita,@_oReceita) )
      
	  If _lgrava 
  	     u_itmsg("Falha no webservice da receita","Atenção",cHdReceita,1)
      EndIf 

      _lret := .F.
      _lerro := .T.
      _cerro := cHdReceita
       
      Reclock("SA1",.F.)
      SA1->A1_I_SCST := "ERRO DE CONSULTA"
  	   SA1->A1_I_D1ST := STOD("20010101")
  	   SA1->A1_I_D2ST := STOD("20010101") //Grava uma data impossível para facilitar localização de registros com problema de consulta
  	   SA1->A1_I_D3ST := DATE()
      SA1->A1_I_HRST := TIME()
      SA1->(Msunlock())
    
      Break
   Endif

   //=======================================================
   // remover caracteres especiais neste trecho. 
   //=======================================================
   cCorReceita := StrTran(cCorReceita,"º"," ")
   cCorReceita := StrTran(cCorReceita,"ª"," ") 
   cCorReceita := StrTran(cCorReceita,"´"," ") 
   cCorReceita := StrTran(cCorReceita,"`"," ") 
   cCorReceita := StrTran(cCorReceita,"^"," ") 
   cCorReceita := StrTran(cCorReceita,"~"," ") 

   _aNamesRec := _oJsonRec:GetNames()

   _oReceita  := _oJsonRec:GetJsonObject("company")

   If ValType(_oReceita) == "A" .And. Len(_oReceita) == 0

      If _lgrava 
  	     u_itmsg("Falha no webservice da receita","Atenção","Json de retorno incompleto: "+ CRLF + cCorReceita,1)
      EndIf 

      _lret := .F.
      _lerro := .T.
      _cerro := "Json de retorno incompleto: "+ CRLF + cCorReceita
       
      Reclock("SA1",.F.)
      SA1->A1_I_SCST := "ERRO DE CONSULTA"
  	  SA1->A1_I_D1ST := STOD("20010101")
  	  SA1->A1_I_D2ST := STOD("20010101") //Grava uma data impossível para facilitar localização de registros com problema de consulta
  	  SA1->A1_I_D3ST := DATE()
      SA1->A1_I_HRST := TIME()
      SA1->(Msunlock())
    
      Break
   Endif

   _oReceita  := _oReceita[1]
   _aNameComp := _oReceita:GetNames()

   _cDtCriac := _oReceita:GetJsonObject("openingDate")

   _oRegSit   := _oReceita:GetJsonObject("register")
   _aNameReg  := _oRegSit:GetNames()

   _nI := Ascan(_aNameReg, "status" )

   If _nI > 0
      _cSituacRg := _oRegSit[_aNameReg[_nI]]
      _cSituacRg := Upper(_cSituacRg)
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
   
   _aNameDocs := _oDoctosR:GetNames()

   _nI := Ascan(_aNameDocs ,"type" )
   _cTipoDocR := ""

   If _nI > 0
      _cTipoDocR := _oDoctosR[_aNameDocs[_nI]]	  
   EndIf 

   _nI := Ascan(_aNameDocs ,"value" )
   _cNrDocRec := ""

   If _nI > 0
      _cNrDocRec := _oDoctosR[_aNameDocs[_nI]]	
      _cNrDocRec := StrTran(_cNrDocRec,".","")  
   EndIf 

   _oBusiness := _oReceita:GetJsonObject("business")

   _oIndustri := _oBusiness:GetJsonObject("industries")
   _cCodNegoc   := ""
   _cDesecNegoc := ""

   For _nI := 1 To Len(_oIndustri)

       _aIndAtiva := _oIndustri[_nI]
	   _lIndAtiva := _oIndustri[_nI]:GetJsonObject("main")
	   If _lIndAtiva 
	      _cCodNegoc := _oIndustri[_nI]:GetJsonObject("code")
          _cDesecNegoc := _oIndustri[_nI]:GetJsonObject("description")
       EndIf 

   Next 

   If _lisento  //Se é isento iguala dados da receita para sintegra
  
  	  _CSINTEGRA := _CRECEITA
 	  
   	  _CRECSIT := _cSituacRg   //_CRECEITA:situacaoCadastral 
   	  _CRECATU := _cDtAltRec   //_CRECEITA:dataAtualizacao 
   	  _CRECCON := Dtoc(Date()) //_CRECEITA:dataConsulta 
   Else
   	  If _lerrorec //Se deu erro na receita e é não isento atualiza dados da receita com dados do sintegra
    	 _CRECEITA := _csintegra
    	 _CRECSIT := "ERRO DE CONSULTA"
    	 _CRECATU := '2001-01-01' //MARCA COM DATA IMPOSSIVEL PARA LOCALIZARMOS OS REGISTROS COM PROBLEMAS
    	 _CRECCON := '2001-01-01'
      Else
		 _CRECSIT := _cSituacRg   //_CRECEITA:situacaoCadastral 
   	     _CRECATU := _cDtAltRec   //_CRECEITA:dataAtualizacao 
   	     _CRECCON := Dtoc(Date()) //_CRECEITA:dataConsulta 
      Endif
   Endif

   If Empty(_cNome)
      _nI := Ascan(_aNameComp ,{|x| x=="registeredName"})
      //_cNome := ""

      If _nI > 0
         _cNome := _oRECEITA[_aNameComp[_nI]]
      EndIf 
   EndIf 
   
   If Empty(_cNReduz)
      //_cNReduz := ""

      If !Empty( _oRECEITA:GetJsonObject("name"))
  	     _cNReduz := _oRECEITA:GetJsonObject("name") // _CRECEITA:nomeFantasia
      EndIf
   EndIf

   If SubStr(AllTrim(_cNReduz),1,1) == "*"
      _cNReduz := SubStr(_cNome,1,20) 
   EndIf 
    
   _aaju := {}
  
   If !(alltrim(_cNome) == alltrim(SA1->A1_NOME)) // (alltrim(SUBSTR(_oRECEITA:razaoSocial,1,60)) == alltrim(SA1->A1_NOME))
  	  aadd(_aaju,{"Razão Social",alltrim(SA1->A1_NOME),alltrim(SUBSTR(_cNome,1,60))})
   Endif

   If !(alltrim(_cNReduz) == alltrim(SA1->A1_NREDUZ)) 
  	  aadd(_aaju,{"Nome Fantasia",alltrim(SA1->A1_NREDUZ),alltrim(SUBSTR(_cNReduz,1,20))})
   Endif

   _nI := Ascan(_aNameComp ,"address" )
   _cEndRece := ""

   If _nI > 0
      _cEndRece := _oRECEITA[_aNameComp[_nI]]	  
   EndIf 

   _oEndRece := _cEndRece:GetJsonObject("state")
   _cUfRece  := _oEndRece:GetJsonObject("code")

   _cRua     := _cEndRece:GetJsonObject("line1")
   _cNumero  := _cEndRece:GetJsonObject("line2")
   _cCidade  := _cEndRece:GetJsonObject("city")
   _cCep     := _cEndRece:GetJsonObject("postalCode")
   _cComplem := _cEndRece:GetJsonObject("extension")
   _cBairro  := _cEndRece:GetJsonObject("district")

   If ! Empty(_cComplem) .And. SubStr(AllTrim(_cComplem),1,1) == "*"
      _cComplem := ""
   EndIf 

   _CSINTEGRA := _osintegra // _osintegra[1]
   _aNameSint := _CSINTEGRA:GetNames()

   _aNameRec  := _oJsonRec:GetNames()

   _cDtAltSint := ""
   _nI := Ascan(_aNameRec, "updateDate" )
   If _nI > 0
      _cDtAltSint := _oJsonRec[_aNameRec[_nI]]
	  _cDtAltSint := StrTran(_cDtAltSint,"-","")
   EndIf 

   //==============================================================
   // Obtem dos dados de endereços do Sintegra.
   //============================================================== 
   _nI := Ascan(_aNameSint ,"address" )
   _cEndSint := ""

   If _nI > 0
      _cEndSint := _CSINTEGRA[_aNameSint[_nI]]	  
   EndIf 

   _oEndSint := _cEndSint:GetJsonObject("state")
   _cUfSint  := _oEndSint:GetJsonObject("code")

   If Empty(_cRua)
      _cRua     := _cEndSint:GetJsonObject("line1")
   EndIf 

   If Empty(_cNumero)
      _cNumero  := _cEndSint:GetJsonObject("line2")
   EndIf 

   If Empty(_cCidade)
      _cCidade  := _cEndSint:GetJsonObject("city")
   EndIf 

   If Empty(_cCep)
      _cCep     := _cEndSint:GetJsonObject("postalCode")
   EndIf 

   If Empty(_cComplem)
      _cComplem := _cEndSint:GetJsonObject("extension")
   EndIf 

   If Empty(_cBairro)
      _cBairro  := _cEndSint:GetJsonObject("district")
   EndIf 
   //==============================================================

   _nI := Ascan(_aNameSint ,{|x| x=="register"})
   _cRegiSint := ""
   _cSituSint := ""

   If _nI > 0
      _cRegiSint := _CSINTEGRA[_aNameSint[_nI]]	  
      _cSituSint := _cRegiSint:GetJsonObject("status")
   EndIf 
    
   If empty(alltrim(_cNumero)) .and. empty(alltrim(_cComplem))  // empty(alltrim(_CSINTEGRA:numero)) .and. empty(alltrim(_CSINTEGRA:complemento))
   	  _cend := Alltrim(_cRua) // alltrim(_CSINTEGRA:endereco)
   Else 
  	  _cend := ALLTRIM(alltrim(_cRua) + ", " + alltrim(_cNumero)+ " " + alltrim(_cComplem))
   Endif
  
   If !(_cend == alltrim(SA1->A1_END))
   	  aadd(_aaju,{"Endereço",alltrim(SA1->A1_END),_cend})
   Endif
    
   If !(alltrim(_cBairro) == alltrim(SA1->A1_BAIRRO)) .and. !empty(alltrim(_cBairro)) // !(alltrim(_CSINTEGRA:bairro) == alltrim(SA1->A1_BAIRRO)) .and. !empty(alltrim(_CSINTEGRA:bairro))
  	  aadd(_aaju,{"Bairro",alltrim(SA1->A1_BAIRRO),alltrim(_cBairro)})
   Endif
  
   If !(alltrim(_cCidade) == alltrim(SA1->A1_MUN)) .AND. !EMPTY((alltrim(_cCidade))) // !(alltrim(_CSINTEGRA:cidade) == alltrim(SA1->A1_MUN)) .AND. !EMPTY((alltrim(_CSINTEGRA:cidade)))
  	  aadd(_aaju,{"Municipio",alltrim(SA1->A1_MUN),alltrim(_cCidade)})
   Endif
  
   //Verifica se estado informado pela receita é igual ao informado pelo Sintegra
   If alltrim(_cUfSint) != alltrim(_cUfRece ) .and. !empty(alltrim(_cUfSint)) .and. !empty(alltrim(_cUfRece)) // alltrim(_CSINTEGRA:uf) != alltrim(_CRECEITA:uf) .and. !empty(alltrim(_CSINTEGRA:uf)) .and. !empty(alltrim(_CRECEITA:uf))
  	  _ldivuf := .T.
	  aadd(_aaju,{"UF Sintegra",alltrim(SA1->A1_EST),alltrim(_cUfSint)})
  	  aadd(_aaju,{"UF Receita",alltrim(SA1->A1_EST),alltrim(_cUfRece)})

  	  If _lgrava
 		 u_itmsg("UF informada pela Receita diverge do Sintegra, Cliente será bloqueado!","Atenção","Será necessário realizar análise fiscal do cliente",1)
  	  Endif
   Endif
  
   If !(alltrim(_cUfRece) == alltrim(SA1->A1_EST)) .and. !empty(alltrim(_cUfRece)) //!(alltrim(_CRECEITA:uf) == alltrim(SA1->A1_EST)) .and. !empty(alltrim(_CRECEITA:uf))
      aadd(_aaju,{"UF",alltrim(SA1->A1_EST),alltrim(_cUfRece)}) //aadd(_aaju,{"UF",alltrim(SA1->A1_EST),alltrim(_CRECEITA:uf)})
   Endif
  
   If !(alltrim(_cCep) == alltrim(SA1->A1_CEP))  // If !(alltrim(strzero(_CSINTEGRA:cep,8)) == alltrim(SA1->A1_CEP))
  	  aadd(_aaju,{"CEP",alltrim(SA1->A1_CEP),alltrim(_cCep)}) // aadd(_aaju,{"CEP",alltrim(SA1->A1_CEP),alltrim(strzero(_CSINTEGRA:cep,8))})
   Endif
  
   _lbloqueia := .F. 
  	
   _CSITSINTEGRA := AllTrim(Upper(_cSituSint)) // alltrim(_CSINTEGRA:situacaoCadastral)
  	
   If _ldivuf .OR.;
  	  !(_CSITSINTEGRA == "HABILITADO" .OR. _CSITSINTEGRA == "HABILITADA" .OR. _CSITSINTEGRA == "ATIVO" .OR. _CSITSINTEGRA == "ATIVA" .OR. _CSITSINTEGRA == "ATIVO - HABILITADO" .OR. _CSITSINTEGRA == "HABILITADO - ATIVO");
  	  				.OR. !(alltrim(_CRECSIT) == "ATIVA" .OR. alltrim(_CRECSIT) == "ATIVO" .OR. alltrim(_CRECSIT) == "ERRO DE CONSULTA")
  	
  	  _lbloqueia := .T.
   Endif

   aadd(_aaju,{"Sit Sintegra",SA1->A1_I_SCST,alltrim(_CSITSINTEGRA)})
   aadd(_aaju,{"Sit Receita" ,SA1->A1_I_SCRC,alltrim(_CRECSIT)})
  
   //Atualiza sempre os campos de logradouro, numero e complemento
   If SA1->A1_I_ATCIS != "N" .and. U_ITGETMV("ITGRVCLI",.F.) .And. ! Empty(_cRua)
      Reclock("SA1",.F.)
   	  SA1->A1_I_LOGRA := _cRua      // _CSINTEGRA:endereco
   	  SA1->A1_I_NUMER := _cNumero   // _CSINTEGRA:numero
   	  SA1->A1_I_COMPL := _cComplem  // _CSINTEGRA:complemento
   	  SA1->(Msunlock())
   Endif
  
   // Verifica se é simples nacional
  
   _catusimples := ' '	  		
  		
   //===============================================================================================================
   //Consulta ao sistema Simpes Nacional
   //===============================================================================================================

   IF valtype(oproc) = "O"
 	  oproc:cCaption := ("Consultando Simples...")
 	  ProcessMessages()
   Else
      u_itconout("Consultando Simples...")
   ENDIF

   //Faz chamada ao webservice do Simples  	 	
   CHdSimples  := ""
   cCorSimples := HttpGet(cUrlsimples,"",NIL,aHeadOut,@cHdSimples)
   _osimples   := nil
   
   _cDecodeTxt := ""
   //cCorSimples := DecodeUTF8(cCorSimples, "cp1252")  
   If ! Empty(cCorSimples)
      _cDecodeTxt := DecodeUTF8(cCorSimples, "cp1252")  
   EndIf 

   If ! Empty(_cDecodeTxt)
      cCorSimples :=_cDecodeTxt
   EndIf 

   _oJsonSimp  := JsonObject():new()

   _cRetSimpl := _oJsonSimp:FromJson(cCorSimples) 

   //Verifica e formata resposta do Simples
   If Substr(cHdSimples,10,3) == "200" .and. ValType(_cRetSimpl) == "U" // FWJsonDeserialize(cCorSimples,@_osimples) 
	  _aNamesSip := _oJsonSimp:GetNames()

      _oSimplNac := _oJsonSimp:GetJsonObject("company")
      _oSimplNac := _oSimplNac[1]
      _cSimplNac := _oSimplNac:GetJsonObject("business")
      _cSimplOpt := _cSimplNac:GetJsonObject("taxSystem")
      _cSimpNcOp := _cSimplOpt:GetJsonObject("statusSimplesNacional")

      If ! Empty(_cSimpNcOp)
         _cSimpNcOp := Upper(_cSimpNcOp)
      EndIf

      If type("_cSimpNcOp") == "C" .and. substr(alltrim(_cSimpNcOp),1, 7) == "OPTANTE" // type("_osimples:descricaoOptante") == "C" .and. substr(alltrim(_osimples:descricaoOptante),1, 7) == "OPTANTE"
	     _catusimples := '1'
			
  		 If SA1->A1_SIMPNAC <> _catusimples
            _lGrvSimp := .T.
            aadd(_aaju,{"Optante Simples","Vazio","Sim"}) 
         Else
            _lGrvSimp := .F.
         EndIf
	  Else
		 _catusimples := '2'
			
         If SA1->A1_SIMPNAC <> _catusimples
            _lGrvSimp := .T.
            aadd(_aaju,{"Optante Simples","Vazio","Não"})
         Else
            _lGrvSimp := .F.
         EndIf
  	  Endif
   Else
	  _lGrvSimp := .F.
      _catusimples := ''
   Endif
 
   //Verifica o SUFRAMA
   _cSuframa := ''
  	  		
   //===============================================================================================================
   //Consulta ao sistema Suframa. Esta consulta deve ser realizada apenas para os estados: AM, AC, RO, RR e AP. 
   //===============================================================================================================
   If SA1->A1_EST $ "AM,AC,RO,RR,AP" // Verifica se o estado do Cliente é suframa antes da consulta.

      IF valtype(oproc) = "O"
	      oproc:cCaption := ("Consultando Suframa...")
 	      ProcessMessages()
      Else
         u_itconout("Consultando Suframa...")
      EndIf

      cCorSuframa  := HttpGet(cUrlSuframa,"",NIL,aHeadOut,@cHdSuframa)
      _lerrorec    := .F. 

      _cDecodeTxt := ""
      //cCorSuframa := DecodeUTF8(cCorSuframa, "cp1252")  
      If ! Empty(cCorSuframa)
         _cDecodeTxt := DecodeUTF8(cCorSuframa, "cp1252")  
      EndIf 
      
      If ! Empty(_cDecodeTxt)
         cCorSuframa :=_cDecodeTxt
      EndIf 

      _oJsonSufr   := JsonObject():new()

      _cRetRSufr   := _oJsonSufr:FromJson(cCorSuframa) // FromJson(cCorSintegra)

      // Verifica e formata resposta do Suframa
      If substr(cHdSuframa,10,3) == "200" .and. ValType(_cRetRSufr) == "U" // substr(cHdSuframa,1,6) == "200 OK" .and. FWJsonDeserialize(cCorSuframa,@_oSuframa) 	  		
	      _aNamesSufr := _oJsonSufr:GetNames()

         If Len(_aNamesSufr) > 0
            _cDtSufrAt := ""

	         _nI := Ascan(_aNamesSufr, "updateDate" )
            If _nI > 0
               _cDtSufrAt := _oJsonSufr[_aNamesSufr[_nI]]
            EndIf 

            //======================================================================================
            // No JSON Cisp Suframa, o código Suframa vem na Tag company->Document->Value
	         // No Cisp Suframa, o número da Inscrição Estatual enviado no JSON é o código Suframa.
		      //======================================================================================
            _oSuframa   := _oJsonSufr:GetJsonObject("company")
		     _oSuframa   := _oSuframa[1]

		     _aNameSufr  := _oSuframa:GetNames()
			
		     _oDoctosSuf := ""
			
		     _nI := Ascan(_aNameSufr,"document" )
           If _nI > 0
              _oDoctosSuf := _oSuframa[_aNameSufr[_nI]]	
		        _oDoctosSuf := _oDoctosSuf[1]  
           EndIf 
      
	        _aNameDcSuf := _oDoctosSuf:GetNames()

           _nI := Ascan(_aNameDcSuf,"type" )
           _cTipoDcSuf := ""

           If _nI > 0
              _cTipoDcSuf := _oDoctosSuf[_aNameDcSuf[_nI]]	  
           EndIf 

           _nI := Ascan(_aNameDcSuf ,"value" )
           _cSuframa := ""

            If _nI > 0
               _cSuframa := _oDoctosSuf[_aNameDcSuf[_nI]]	
                _cSuframa := StrTran(_cSuframa,".","")  
            EndIf 

            If ! (Alltrim(SA1->A1_SUFRAMA) == Alltrim(_cSuframa)) .And. ! Empty(_cSuframa) 
               _lGrvSufr := .T.
          	   aadd(_aaju,{"SUFRAMA",alltrim(SA1->A1_SUFRAMA),_cSuframa})
            Else
               _lGrvSufr := .F.
            EndIf
         Else
            _lGrvSufr := .F.
         EndIf
      Else
	      _lGrvSufr := .F.
	      _cSuframa := ''
      Endif
    EndIf // Final do If de Estados Suframa.

   //Manda campos de momentos das consultas para atualização geral
   If !(_lgrava)
  	  aadd(_aaju,{"Consulta Receita",SA1->A1_I_D1RC,stod(substr(alltrim(_CRECCON),1,4)+substr(alltrim(_CRECCON),6,2)+substr(alltrim(_CRECCON),9,2)),alltrim(SA1->A1_COD),alltrim(SA1->A1_LOJA)})
   	  aadd(_aaju,{"Atua Receita",SA1->A1_I_D2RC,stod(substr(alltrim(_CRECATU),1,4)+substr(alltrim(_CRECATU),6,2)+substr(alltrim(_CRECATU),9,2)),alltrim(SA1->A1_COD),alltrim(SA1->A1_LOJA)})  		 	
   	  aadd(_aaju,{"Consulta Sintegra",SA1->A1_I_D1ST,Date()}) // Não tem no JSON a data da consulta. Obter a data do dia.
   	  aadd(_aaju,{"Atua Sintegra"    ,SA1->A1_I_D2ST,stod(_cDtAltSint)})   		 	
   Endif  
  
   _ahead := {"Campo","Dados Protheus","Dados Receita/Sintegra"}
  
   If len(_aaju) > 2 .OR. _lbloqueia
  	  if _lgrava
  	  	 _latu := u_itlistbox("Cadastro desatualizado",_ahead,_aaju,.T.,1)
  	  Endif
  	  _cobs := "Cadastro atualizado manualmente"
   Else
      _latu := .T.
      _cobs := "Consulta indicou cadastro igual ao Sintegra/Receita, somente datas de consulta atualizadas"
   Endif
  	  	
   If _latu .and. _lgrava   		
  	  _lnaoatu := .F.
  	  	
  	  //Só atualiza se existir o parâmetro ativando gravação do SA1
  	  If U_ITGETMV("ITGRVCLI",.F.)
  	   	 //Atualiza cadastro no SA1
  	  	 Reclock("SA1",.F.)
		 If ! Empty(_cNome)
  	  	    SA1->A1_NOME   := AllTrim(_cNome) // alltrim(SUBSTR(_CRECEITA:razaoSocial,1,60))   
		 EndIf
		 
		 If ! Empty(_cNReduz) 
  		    SA1->A1_NREDUZ := AllTrim(_cNReduz)  
         EndIf 

  	  	 If !(_lisento) .And. ! Empty(_cNrDocs)
  	  		SA1->A1_INSCR := alltrim(_cNrDocs) // alltrim(_CSINTEGRA:inscricaoEstadual)
  	  	 Endif
    		
	     If ! Empty(_cend)		
  	  	    SA1->A1_END := _cend
  	  	 EndIf

  	  	 If !empty(AllTrim(_cBairro))  // !empty(alltrim(_CSINTEGRA:bairro))
  	  		SA1->A1_BAIRRO := AllTrim(_cBairro) // alltrim(_CSINTEGRA:bairro)
  	  	 Endif
  	  		
  	 	 If !empty(alltrim(_cUfRece)) // !empty(alltrim(_CRECEITA:uf))
  	  	    SA1->A1_EST := AllTrim(_cUfRece) // alltrim(_CRECEITA:uf)
  	  	 Endif

		 If alltrim(_cCidade) == 'SANT& X27 ANA DO LIVRAMENTO'
			_cCidade := 'SANTANA DO LIVRAMENTO'
		 Endif

		 _CMUN := POSICIONE("CC2",4,xfilial("CC2")+SA1->A1_EST+alltrim(_cCidade),"CC2_CODMUN")
  	  	 If !empty(alltrim(_cCidade)) .AND. !EMPTY(alltrim(_cmun)) //  !empty(alltrim(_CSINTEGRA:cidade)) .AND. !EMPTY(alltrim(_cmun))
  	  		SA1->A1_MUN := alltrim(_cCidade) //alltrim(_CSINTEGRA:cidade)
  	  	    SA1->A1_COD_MUN := _cmun
  	  	 Endif
  	  		
  	  	 If !(alltrim(_cCep) == '99999999' .or. alltrim(_cCep) == '00000000') // !(alltrim(strzero(_CSINTEGRA:cep,8)) == '99999999' .or. alltrim(strzero(_CSINTEGRA:cep,8)) == '00000000')
		    If ! Empty(_cCep)
	  	       SA1->A1_CEP := _cCep //alltrim(strzero(_CSINTEGRA:cep,8))
			EndIf 
  	  	 Endif
  	  		
  	  	 _csimpa := SA1->A1_SIMPNAC
  	  		
  	  	 If _lGrvSimp
		    If ! Empty(_catusimples)
  	  		   SA1->A1_SIMPNAC := _catusimples
			EndIf 
         Endif
  	  		
  	  	 _csimpn := SA1->A1_SIMPNAC

         _cSufra := SA1->A1_SUFRAMA

         If _lGrvSufr
		    If ! Empty(_cSuframa)
               SA1->A1_SUFRAMA := _cSuframa
			EndIf 
         EndIf
         
		 _cSufrn := SA1->A1_SUFRAMA

  	  	 SA1->A1_I_SCST := _cSituSint //alltrim(_CSINTEGRA:situacaoCadastral)
  	  	 SA1->A1_I_D1ST := Date() // Não há data de consulta no JSON. Utilizar data do dia. //stod(substr(alltrim(_CSINTEGRA:dataConsulta),1,4)+substr(alltrim(_CSINTEGRA:dataConsulta),6,2)+substr(alltrim(_CSINTEGRA:dataConsulta),9,2))
  	  	 SA1->A1_I_D2ST := Stod(_cDtAltSint) // stod(substr(alltrim(_CSINTEGRA:dataAtualizacao),1,4)+substr(alltrim(_CSINTEGRA:dataAtualizacao),6,2)+substr(alltrim(_CSINTEGRA:dataAtualizacao),9,2))
  	  	 SA1->A1_I_D3ST := DATE()
  	  	 SA1->A1_I_HRST := TIME()
  	  	 SA1->A1_I_SCRC := alltrim(_CRECSIT)
  	  	 SA1->A1_I_D1RC := stod(substr(alltrim(_CRECCON),1,4)+substr(alltrim(_CRECCON),6,2)+substr(alltrim(_CRECCON),9,2))
  	  	 SA1->A1_I_D2RC := stod(substr(alltrim(_CRECATU),1,4)+substr(alltrim(_CRECATU),6,2)+substr(alltrim(_CRECATU),9,2))
   		 
  	  	 If _lbloqueia
  			SA1->A1_MSBLQL := "1"
  		 Endif
  		
  	  	 SA1->(Msunlock())
  	  Else
  	  	 _cobs := _cobs + " - Cadastro não atualizado, parâmetro ITGRVCLI desabilitado"
  	  	 _lnaoatu := .T.
  	  Endif
  	  	
  	  //Grava log de consulta
  	  Reclock("ZGF",.T.)
  	  ZGF->ZGF_CODCLI := SA1->A1_COD
  	  ZGF->ZGF_LOJA := SA1->A1_LOJA
  	  //ZGF->ZGF_HASH := _asintegra[10] + " - " + _areceita[10]
  	  ZGF->ZGF_NOMEA := SA1->A1_NOME
  	  ZGF->ZGF_NOMEN := _cNome // alltrim(SUBSTR(_CRECEITA:razaoSocial,1,60))  
  	  If !(_lisento)
  	  	 ZGF->ZGF_INSCA := SA1->A1_INSCR 
  	  	 ZGF->ZGF_INSCN := Alltrim(_cNrDocs) // alltrim(_CSINTEGRA:inscricaoEstadual)
  	  Endif
  	  ZGF->ZGF_ENDA := SA1->A1_END
  	  ZGF->ZGF_ENDN := _cend
  	  ZGF->ZGF_SIMPA := _csimpa
  	  ZGF->ZGF_SIMPN := SA1->A1_SIMPNAC
  	  ZGF->ZGF_BAIRA := SA1->A1_BAIRRO
  	  ZGF->ZGF_BAIRN := _cBairro // alltrim(_CSINTEGRA:bairro)
  	  ZGF->ZGF_MUNA := SA1->A1_MUN
  	  ZGF->ZGF_MUNN := _cCidade // alltrim(_CSINTEGRA:cidade)
  	  ZGF->ZGF_CMUNA := SA1->A1_COD_MUN
  	  ZGF->ZGF_CMUNN := POSICIONE("CC2",2,xfilial("CC2")+alltrim(_cCidade),"CC2_CODMUN") // POSICIONE("CC2",2,xfilial("CC2")+alltrim(_CSINTEGRA:cidade),"CC2_CODMUN")
  	  ZGF->ZGF_ESTA := SA1->A1_EST
  	  ZGF->ZGF_ESTN := AllTrim(_cUfRece) // alltrim(_CRECEITA:uf)
  	  ZGF->ZGF_CEPA := SA1->A1_CEP
  	  ZGF->ZGF_CEPN := alltrim(_cCep) //alltrim(strzero(_CSINTEGRA:cep,8))
  	  ZGF->ZGF_SCSTA := SA1->A1_I_SCST
  	  ZGF->ZGF_SCSTN := AllTrim(_cSituSint) // alltrim(_CSINTEGRA:situacaoCadastral)
  	  ZGF->ZGF_D1STA := SA1->A1_I_D1ST
  	  ZGF->ZGF_D1STN := Date() // stod(substr(alltrim(_CSINTEGRA:dataConsulta),1,4)+substr(alltrim(_CSINTEGRA:dataConsulta),6,2)+substr(alltrim(_CSINTEGRA:dataConsulta),9,2))
  	  ZGF->ZGF_D2STA := SA1->A1_I_D2ST
  	  ZGF->ZGF_D2STN := Stod(_cDtAltSint) // stod(substr(alltrim(_CSINTEGRA:dataAtualizacao),1,4)+substr(alltrim(_CSINTEGRA:dataAtualizacao),6,2)+substr(alltrim(_CSINTEGRA:dataAtualizacao),9,2))
  	  ZGF->ZGF_D3STA := SA1->A1_I_D3ST
  	  ZGF->ZGF_D3STN := DATE()
  	  ZGF->ZGF_MSBLA := SA1->A1_MSBLQL
  	  ZGF->ZGF_MSBLN := IIF(_lbloqueia,'1', SA1->A1_MSBLQL) 
  	  ZGF->ZGF_HRSTA := SA1->A1_I_HRST
  	  ZGF->ZGF_HRSTN := TIME()
  	  ZGF->ZGF_RCSTA := SA1->A1_I_SCRC
  	  ZGF->ZGF_RCSTN := alltrim(_CRECSIT)
  	  ZGF->ZGF_D1RCA := SA1->A1_I_D1RC
  	  ZGF->ZGF_D1RCN := stod(substr(alltrim(_CRECCON),1,4)+substr(alltrim(_CRECCON),6,2)+substr(alltrim(_CRECCON),9,2))
  	  ZGF->ZGF_D2RCA := SA1->A1_I_D2RC
  	  ZGF->ZGF_D2RCN := stod(substr(alltrim(_CRECATU),1,4)+substr(alltrim(_CRECATU),6,2)+substr(alltrim(_CRECATU),9,2))
  	  ZGF->ZGF_USER  := cusername
  	  ZGF->ZGF_OBS   := _cobs
      ZGF->ZGF_SUFRA := _cSufra
  	  ZGF->ZGF_SUFRN := _cSufrn
  	  ZGF->(Msunlock())
   	  	
   	  //===================================================================================
      // Grava os dados dos clientes nas tabelas de muro para integração com o sistema RDC.
      //===================================================================================
      U_AOMS076G()
   		
  	  //Envia email de atualização 
  	  If _lemail .and. (len(_aaju) > 2 .OR. _lbloqueia) .and. _lgrava
  	  	 IF valtype(oproc) = "O"
    		oproc:cCaption := ("Enviando email...")
	    	ProcessMessages()
   	     ENDIF
  	     
		 AOMS104E(_aaju)
  	  Endif
  		
  	  If _lnaoatu .and. (len(_aaju) > 2 .OR. _lbloqueia) .and. _lgrava
  		 u_itmsg("Cadastro não atualizado!","Atenção","Verifique parâmetro ITGRVCLI desabilitado",1)
  			
  	  Elseif _lgrava
  		 u_itmsg("Cadastro atualizado!","Informação",,2) 
  	  Endif
  	
  	  Break
   Else
  	  if _lgrava
  		 u_itmsg("Cadastro não foi atualizado!","Atenção",,1)
  	  Endif
  	   	
  	  _lret := .F.
  	  Break
   Endif
     
End Sequence

//Se teve erro na consulta grava o log do erro
If _lerro

	  	//Grava log de consulta
  	  	Reclock("ZGF",.T.)
  	  	ZGF->ZGF_CODCLI := SA1->A1_COD
  	  	ZGF->ZGF_LOJA := SA1->A1_LOJA
   	  	ZGF->ZGF_USER  := cusername
  	  	ZGF->ZGF_OBS   := "Erro na consulta - " + _cerro
  	  	
  	  	ZGF->(Msunlock())

Endif

Return _lret

/*
===============================================================================================================================
Programa----------: AOMS104E
Autor-------------: Josué Danich
Data da Criacao---: 15/09/2017
===============================================================================================================================
Descrição---------: Rotina para enviar e-mail de notificação de atualização de cadastro de cliente
===============================================================================================================================
Parametros--------: _aaju - array com alterações realizada
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS104E(_aaju)

Local _aConfig	:= U_ITCFGEML('')
Local _cMsgEml	:= ''
Local _cEmail	:= U_ITGETMV( 'IT_CISPCLI' , 'sistema@italac.com.br' )
Local _cData	:= Dtoc(DATE())
Local _cHoraT   := time()
Local _cAssunto := 'Workflow - Atualização de cadastro de cliente - ' + alltrim(SA1->A1_COD) + "/" + ALLTRIM(SA1->A1_LOJA) + " - " + alltrim(SA1->A1_NOME)
Local _ni := 1
Default _aaju := {}

If len(_aaju) < 1

	Return
	
Endif

_cMsgEml := '<html>'
_cMsgEml += '<head><title></title>Log de Processamento</head>'
_cMsgEml += '<body>'
_cMsgEml += '<style type="text/css"><!--'
_cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
_cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
_cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
_cMsgEml += 'td.aceito	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #00CC00; }'
_cMsgEml += 'td.recusa  { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FF0000; }'
_cMsgEml += '--></style>'
_cMsgEml += '<center>'
_cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="700" height="50"><br>'
_cMsgEml += '<table class="bordasimples" width="700">'
_cMsgEml += '    <tr>'
_cMsgEml += '	<td class="titulos"><center>Atualização dados Manual no cadasto de clientes - ' + alltrim(SA1->A1_COD) + "/" + ALLTRIM(SA1->A1_LOJA) + " - " + alltrim(SA1->A1_NOME) + "</center></td>'
_cMsgEml += '	</tr>'
_cMsgEml += '</table>'
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="700">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="2" class="grupos">Log Processamento</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Data:</b></td>'
_cMsgEml += '      <td class="itens" align="left" >'+ _cData +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Hora:</b></td>'
_cMsgEml += '      <td class="itens" align="left" >'+ _cHoraT +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Observação:</b></td>'
_cMsgEml += '      <td class="itens" align="left" >'+ AllTrim( ZGF->ZGF_OBS ) +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Responsável:</b></td>'
_cMsgEml += '      <td class="itens" align="left" >'+ AllTrim( ZGF->ZGF_USER ) +'</td>'
_cMsgEml += '    </tr>'


_cMsgEml += '	<tr>'
_cMsgEml += '      <td class="titulos" align="center" colspan="2"><font color="red">Esta é uma mensagem automática. Por favor não responder!</font></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '</table>'

	
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="1200">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="5" class="grupos">Alterações realizadas</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Informação</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="40%"><b>Valor Original</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="40%"><b>Novo Valor</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '</center>'

For _ni := 1 to len(_aaju)

_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="left" >' + _aaju[_ni][1] + '</td>'
_cMsgEml += '      <td class="itens" align="left" >'+ _aaju[_ni][2] + '</td>'
_cMsgEml += '      <td class="itens" align="left" >'+ _aaju[_ni][3] + '</td>'
_cMsgEml += '    </tr>'

Next

_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center">     </td>'
_cMsgEml += '      <td class="itens" align="left" >      </td>'
_cMsgEml += '    </tr>'

_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
_cMsgEml += '      <td class="itens" align="left" > ['+ GetEnvServer() +'] </td>'
_cMsgEml += '    </tr>'

_cMsgEml += '</body>'
_cMsgEml += '</html>'

_cEmlLog := ''
//    ITEnvMail(cFrom     ,cEmailTo ,cEmailCo,cEmailBcc,cAssunto ,cMensagem,cAttach   ,cAccount    ,cPassword   ,cServer      ,cPortCon    ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro)
U_ITENVMAIL( _aConfig[01] , _cEmail ,        ,         ,_cAssunto, _cMsgEml ,         ,_aConfig[01],_aConfig[02], _aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

Return .T.

/*
===============================================================================================================================
Programa----------: AOMS104G
Autor-------------: Josué Danich Prestes
Data da Criacao---: 19/09/2017
===============================================================================================================================
Descrição---------: Atualização geral de clientes
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS104G(oproc)

Local cUrlsintegra    := "https://servicos.cisp.com.br/v1/monitoramento-sintegra/atual"
Local cUrlsimples     := "https://servicos.cisp.com.br/v1/simples-nacional/"
//Local cUrlreceita     := "https://servicos.cisp.com.br/v1/receita-federal/"
Local aHeadOut        := {}
Local cHdSintegra     := ""
Local cCorSintegra    := ""
Local _osintegra
Local _asintegra      := {}
//Local cHdReceita      := ""
//Local cCorReceita     := ""
//Local _oReceita
//Local _aReceita       := {}
Local _cpasswd        := ""
Local _cuser		  := ""
Local _ni := 1
Local _nii := 1
Local _nit	:= 0
Local _ntot := 0
Local cAlias  // := GetNextAlias()
Local _chash := ""
Local _aajug := {}
Local _CSINTEGRA
Local _lLinkPrd // := U_ItGetMv("IT_LKCISPP", .T.)
Local _lSchedule := .F.

Private _cUFProc := Space(100) // Lista de estados a serem processados na atualização geral

Default oproc := nil

//Define parâmetros para execução por Job
MV_PAR01 := "00000000"
MV_PAR02 := "99999999"
MV_PAR03 := "000000"
MV_PAR04 := "ZZZZZZ"

If (isincallstack("MDIEXECUTE") .or. isincallstack("SIGAADV")) //Detecta se é execução via schedule ou via tela

   If !(u_itmsg("Realiza atualização geral de clientes?","Atenção",,3,2,2))
		Return
	Endif

Else
   //Monta ambiente
   u_itconout("Preparando ambiente")
   PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01'; 
   TABLES "SA1","ZP1";
   MODULO 'OMS'
   _lSchedule := .T.
EndIf

//========================================================================
// Tela para seleção de filtro por Estado. 
//========================================================================
If ! _lSchedule // Não exibir tela em modo Scheduller.
   If ! U_AOMS104T() // !ParamBox( _aParAux , "Estados para Atualização CISP" , @_aParRet )
  	   U_ItMsg( "Operação cancelada pelo usuário!" , "Atenção!",,1 )
	   Return  
   EndIf
EndIf 

cAlias    := GetNextAlias()
_lLinkPrd := U_ItGetMv("IT_LKCISPP", .T.)

_cpasswd := u_itgetmv("IT_PWCISP","!t@lac95_01#")
_cuser	:= u_itgetmv("IT_USCISP","ws09501")

//============================================================================
// Define o bloco de código bType,caso não exista.  
//============================================================================
If Type("bType") == "U"
   bType := {|x| Type(x)}
EndIf 

//============================================================================
// Define usuário e password
//============================================================================
aAdd( aHeadOut , "Authorization: Basic "+Encode64(_cuser + ":" + _cpasswd ) )

//===============================================================================================================
//Consulta monitoramento do Sintegra
//===============================================================================================================
If valtype(oproc) = "O"
  	oproc:cCaption := ("Consultando Sintegra...")
	ProcessMessages()
Else
  	U_ItConOut("Consultando Sintegra...")
EndIf 

//Faz chamada ao webservice do Sintegra
cCorSintegra := HttpGet(cUrlsintegra,"",NIL,aHeadOut,@cHdSintegra)
_asintegra   := strtokarr(cHdSintegra,chr(10))

// Verifica e formata resposta do Sintegra 
If substr(cHdSintegra,1,15) == "HTTP/1.1 200 OK" .and. FWJsonDeserialize(cCorSintegra,@_osintegra) .and. len(_osintegra) > 0
  	_aAjug := {}
   _ntot := len(_osintegra) 	
  	
  	For _ni := 1 to _ntot //len(_osintegra)
  		 _aaju := {}
  		 _CSINTEGRA := _osintegra[_ni]
   		 
  		 If valtype(oproc) = "O"
  		  	 oproc:cCaption := ("Carregando dados do Sintegra  - " + strzero(_ni,6) + " de " + strzero(_ntot,6))
   		 ProcessMessages()
   	 Else
   		 U_Itconout("Carregando dados do Sintegra  - " + strzero(_ni,6) + " de " + strzero(_ntot,6))
  		 EndIf 
       
       //=============================================
       // Filtro por Estado.
       //=============================================
       If ! Empty(_cUFProc) .And. ! _CSINTEGRA:UF $ _cUFProc 
          Loop 
       EndIf 

  		 //Procura cliente
  		 SA1->(Dbsetorder(3))
  		 _ddataconsulta := stod(substr(alltrim(_CSINTEGRA:dataConsulta),1,4)+substr(alltrim(_CSINTEGRA:dataConsulta),6,2)+substr(alltrim(_CSINTEGRA:dataConsulta),9,2))
   		 
   	 If SA1->(Dbseek(xfilial("SA1")+strzero(_CSINTEGRA:identificacaoCliente,14))) .and. SA1->A1_I_D1ST < _ddataconsulta .and. SA1->A1_I_ATCIS != "N" .AND. SA1->A1_MSBLQL != "1"
  		 	 If !(alltrim(_CSINTEGRA:inscricaoEstadual) == alltrim(SA1->A1_INSCR)) 
   		 	 aAdd(_aaju,{"Inscrição Estadual",alltrim(SA1->A1_INSCR),alltrim(_CSINTEGRA:inscricaoEstadual),alltrim(SA1->A1_COD),alltrim(SA1->A1_LOJA)})
  		 	 EndIf
   		 	
   		 If Empty(alltrim(_CSINTEGRA:numero)) .and. Empty(alltrim(_CSINTEGRA:complemento))
   		 	 _cend := alltrim(_CSINTEGRA:endereco)
          Else
    		 	 _cend := ALLTRIM(alltrim(_CSINTEGRA:endereco) + ", " + alltrim(_CSINTEGRA:numero)+ " " + alltrim(_CSINTEGRA:complemento))
  	       Endif
  
   		 If !(_cend == alltrim(SA1->A1_END))
     		 	 aAdd(_aaju,{"Endereço",alltrim(SA1->A1_END),_cend,alltrim(SA1->A1_COD),alltrim(SA1->A1_LOJA)})
  	       EndIf
   		 	
   		 If !(alltrim(_CSINTEGRA:bairro) == alltrim(SA1->A1_BAIRRO)) .and. !empty(alltrim(_CSINTEGRA:bairro))
             aAdd(_aaju,{"Bairro",alltrim(SA1->A1_BAIRRO),alltrim(_CSINTEGRA:bairro),alltrim(SA1->A1_COD),alltrim(SA1->A1_LOJA)})
  		 	 Endif
  
   		 If !(alltrim(_CSINTEGRA:cidade) == alltrim(SA1->A1_MUN))
             aAdd(_aaju,{"Municipio",alltrim(SA1->A1_MUN),alltrim(_CSINTEGRA:cidade),alltrim(SA1->A1_COD),alltrim(SA1->A1_LOJA)})
  		 	 EndIf
   		
   		 If !(alltrim(strzero(_CSINTEGRA:cep,8)) == alltrim(SA1->A1_CEP))
     		 	 aAdd(_aaju,{"CEP",alltrim(SA1->A1_CEP),alltrim(strzero(_CSINTEGRA:cep,8)),alltrim(SA1->A1_COD),alltrim(SA1->A1_LOJA)})
  		    Endif
   		 	
   		 If Empty(alltrim(SA1->A1_SIMPNAC)) 
   		 	 //===============================================================================================================
   		  	 //Consulta ao sistema Simpes Nacional
   		  	 //===============================================================================================================
   		  	 IF valtype(oproc) = "O"
  		  	 		 oproc:cCaption := ("Consultando Simples...")
   		  	 	 ProcessMessages()
             Else
  		  	 		 U_ItConOut("Consultando Simples...")
  		  	 	 EndIf 

   		  	 //Faz chamada ao webservice do Simples
             If _lLinkPrd
                //====================================================================
                // Link base produção
                //====================================================================
                cUrlsimples  := "https://api.maxxi.cisp.com.br/public-bases/v1/simples-nacional/cnpj/"+ alltrim(SA1->A1_CGC) + "?dwnljGS5DRJ0BkzGGgRsrNZCUxqdqrZw" //"https://servicos.cisp.com.br/v1/simples-nacional/" + alltrim(M->ZX_CGC)
             Else 
                //====================================================================
                // Link base homologação
                //====================================================================
                cUrlsimples  := "https://api-homol.maxxi.cisp.com.br/public-bases/v1/simples-nacional/cnpj/"+ alltrim(SA1->A1_CGC) + "?key=43c629ff-e72e-4172-a0fe-ffdef386573a" //"https://servicos.cisp.com.br/v1/simples-nacional/" + alltrim(M->ZX_CGC)
             EndIf 

				aHeadOut := {}
            aAdd( aHeadOut , "accept:application/json")

 		  	 	CHdSimples  := ""
 		  	 	cCorSimples := HttpGet(cUrlsimples ,"",NIL,aHeadOut,@cHdSimples)
   		  	 	//_osimples   := nil
   		  	 	//_asimples := strtokarr(cHdSimples,chr(10))
                //cCorSimples := DecodeUTF8(cCorSimples, "cp1252")  
            
            _cDecodeTxt := ""

            If ! Empty(cCorSimples)    
				   _cDecodeTxt := DecodeUTF8(cCorSimples, "cp1252")  
            EndIf 

				If ! Empty(_cDecodeTxt)
               cCorSimples :=_cDecodeTxt
            EndIf 

            If Empty(cCorSimples)
               Loop 
            EndIf 

            _oJsonSimp  := JsonObject():new()

            _cRetSimpl := _oJsonSimp:FromJson(cCorSimples) 

            //Verifica e formata resposta do Simples
   		  	If Substr(cHdSimples,1,12) == "HTTP/1.1 200" .and. ValType(_cRetSimpl) == "U" // FWJsonDeserialize(cCorSimples,@_osimples) 
				   _aNamesSip := _oJsonSimp:GetNames()
               _oSimplNac := _oJsonSimp:GetJsonObject("company")
               _oSimplNac := _oSimplNac[1]
               _cSimplNac := _oSimplNac:GetJsonObject("business")
               _cSimplOpt := _cSimplNac:GetJsonObject("taxSystem")
               _cSimpNcOp := _cSimplOpt:GetJsonObject("statusSimplesNacional")

               If ! Empty(_cSimpNcOp)
                  _cSimpNcOp := Upper(_cSimpNcOp)
               EndIf 

  		  	 	   //Verifica e formata resposta do Simples
  		  	 	   //If substr(cHdSimples,1,15) == "HTTP/1.1 200 OK" .and. FWJsonDeserialize(cCorSimples,@_osimples) 
  		  	 	   If Eval(bType,"_cSimpNcOp") == "C" .and. substr(alltrim(_cSimpNcOp),1, 7) == "OPTANTE" // If Eval(bType,"_osimples:descricaoOptante") == "C" .and. substr(alltrim(_osimples:descricaoOptante),1, 7) == "OPTANTE"
  		  	 		   Aadd(_aaju,{"Optante Simples","Vazio","Sim",alltrim(SA1->A1_COD),alltrim(SA1->A1_LOJA)})
  		  	 	   Else
                  Aadd(_aaju,{"Optante Simples","Vazio","Não",alltrim(SA1->A1_COD),alltrim(SA1->A1_LOJA)})
  		  	 	   EndIf
  		  	 	Else
  		  	 	   Aadd(_aaju,{"Optante Simples","Vazio","Não",alltrim(SA1->A1_COD),alltrim(SA1->A1_LOJA)})
  		  	 	EndIf
  		  	EndIf
   		 	
   		//Atualiza sempre os campos de logradouro, numero e complemento
   		If SA1->A1_I_ATCIS != "N" .and. U_ITGETMV("ITGRVCLI",.F.)
 			   Reclock("SA1",.F.) 
			   SA1->A1_I_LOGRA := _CSINTEGRA:endereco
			   SA1->A1_I_NUMER := _CSINTEGRA:numero
			   SA1->A1_I_COMPL := _CSINTEGRA:complemento
			   SA1->A1_I_D3ST := DATE()
			   SA1->(Msunlock())
   		Endif
   		    		 	
  		 	If len(_aaju) > 0
  		 		aadd(_aaju,{"Sit Sintegra",SA1->A1_I_SCST,alltrim(_CSINTEGRA:situacaoCadastral),alltrim(SA1->A1_COD),alltrim(SA1->A1_LOJA)})
  		 		aadd(_aaju,{"Consulta Sintegra",SA1->A1_I_D1ST,stod(substr(alltrim(_CSINTEGRA:dataConsulta),1,4)+substr(alltrim(_CSINTEGRA:dataConsulta),6,2)+substr(alltrim(_CSINTEGRA:dataConsulta),9,2)),alltrim(SA1->A1_COD),alltrim(SA1->A1_LOJA)})
  		 		aadd(_aaju,{"Atua Sintegra",SA1->A1_I_D2ST,stod(substr(alltrim(_CSINTEGRA:dataAtualizacao),1,4)+substr(alltrim(_CSINTEGRA:dataAtualizacao),6,2)+substr(alltrim(_CSINTEGRA:dataAtualizacao),9,2)),alltrim(SA1->A1_COD),alltrim(SA1->A1_LOJA)})   		 	
   		 	
  		 		aadd(_aajug,{"---------","---------------","-------------------","---------------","-------------------","----------------"})
  		 		aadd(_aajug,{"Cliente",SA1->A1_COD + "/" + SA1->A1_LOJA + "  -  "  + SA1->A1_NOME, "  ",alltrim(SA1->A1_COD),alltrim(SA1->A1_LOJA),"Monitor Sintegra"})
   		 		
  		 		For _nii := 1 to len(_aaju)
   		 		 aadd(_aajug,{_aaju[_nii][1],_aaju[_nii][2],_aaju[_nii][3],_aaju[_nii][4],_aaju[_nii][5],"Monitor Sintegra"})
  		 		Next
   	 	Endif
		EndIf
  	Next
Endif   

//===============================================================================================================
// Atualiza demais clientes ativos na Cisp que não tenha atualização recente
//===============================================================================================================
If valtype(oproc) = "O"
  	oproc:cCaption := ("Carregando clientes ativos...")
	ProcessMessages()
Else
	u_itconout("Carregando clientes ativos...")
EndIf 
  
 _cdatalim := dtos(date() - u_itgetmv("ITDIASCLI",30)) //data limite de atualização dos clientes
 _nlimite  := u_itgetmv("ITLIMCLI",10) // quantidade máxima de clientes a ser atualizada
  
//===========================================================================
//| Monta a consulta de atualização do Cadastro de Clientes na base da CISP |
//===========================================================================
cQuery := " SELECT SA1.R_E_C_N_O_ NREC"+ENTER

cQuery += " FROM "+ RetSqlName("SA1") +" SA1 JOIN "+ RetSqlName("SZY") +" SZY ON TRIM(SZY.ZY_PCCCLI) = TRIM(SUBSTR(SA1.A1_CGC,1,8))"+ENTER

cQuery += " WHERE "+ENTER 
cQuery += " 		SA1.D_E_L_E_T_			= ' ' "+ENTER
cQuery += " AND		SA1.A1_PESSOA			= 'J' "+ENTER
cQuery += " AND     SA1.A1_I_ATCIS         <> 'N' "+ENTER
cQuery += " AND     SA1.A1_MSBLQL          <> '1' "+ENTER
cQuery += " AND		SA1.A1_FILIAL			= '"+ xFilial("SA1") +"' "+ENTER
cQuery += " AND		SUBSTR(SA1.A1_CGC,1,8)	<> '"+ Space(08) +"' "+ENTER
cQuery += " AND		SUBSTR(SA1.A1_CGC,1,8)	<> '00000000' "+ENTER
cQuery += " AND		SA1.A1_COD				> '000001' "
cQuery += " AND		SUBSTR(SA1.A1_CGC,1,8)  BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"' "+ENTER
cQuery += " AND		SA1.A1_COD  BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"' "+ENTER
cQuery += " AND     (((SA1.A1_I_D1ST < '" + _cdatalim + "' OR SA1.A1_I_D1RC  < '" + _cdatalim + "') "
cQuery += " AND     SA1.A1_I_D3ST < '" +  _cdatalim + "') OR SA1.A1_SIMPNAC = ' ') "
cQuery += " AND     SZY.ZY_PCDUCM > '" + DTOS(DATE()-365) + "' "
cQuery += " AND     SZY.D_E_L_E_T_ = ' ' "+ENTER

If ! Empty(_cUFProc) // Filtro por Estado.  
   cQuery += " AND SA1.A1_EST IN " + FormatIn(_cUFProc,";")
EndIf 

cQuery += " ORDER BY SA1.A1_COD"

//===========================================================================
//| Verifica e inicializa os dados para análise                             |
//===========================================================================
If Select(cAlias) > 0
	(cAlias)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAlias , .T. , .F. )

_nI		:= 1
nTotReg	:= 0

DBSelectArea(cAlias)
(cAlias)->( DBGoTop() )

(cAlias)->( DBEVAL( {|| nTotReg++ } ) )
(cAlias)->( DBGoTop() )

If ntotreg > _nlimite
	ntotreg := _nlimite
Endif

_csimplesj := " "

Do While !((cAlias)->( EOF() ))  .and. _ni <= _nlimite
  	
   IF valtype(oproc) = "O"
     	oproc:cCaption := ("Atualizando registros antigos - " + strzero(_ni,6) + " de " + strzero(nTotReg,6))
  		ProcessMessages()
  	Else
  		u_itconout("Atualizando registros antigos - " + strzero(_ni,6) + " de " + strzero(nTotReg,6))
  	EndIf 

	SA1->(Dbgoto((cAlias)->NREC))

	//Se já tem na atualização da receita ou do sintegra não realiza atualização nesse momento
	If ascan(_aajug,{|_aux|,ALLTRIM(_aux[4]) == ALLTRIM(SA1->A1_COD) .AND. ALLTRIM(_aux[5]) == ALLTRIM(SA1->A1_LOJA)}) > 0
	 	(cAlias)->( dbskip() )
      Loop
	Else
		_aaju := {}	
		//U_AOMS104A(nil,.F., @_aaju,.F.,@_CSINTEGRA) //Carrega dados do sintegra e receita por requisição manual
		U_AOMS104A(nil,.T., @_aaju,.F.,@_CSINTEGRA)   //Carrega dados do sintegra e receita por requisição manual
	
		_ltemdif := .F.
		For _nit := 1 to len(_aaju)
			 If _aaju[_nit][2] != _aaju[_nit][3]
				 _ltemdif := .T.
             Exit 
			 Endif
		Next
		
		If Empty(alltrim(SA1->A1_SIMPNAC)) .and. _csimplesj != alltrim(SA1->A1_CGC)
	  	 	//===============================================================================================================
    	 	//Consulta ao sistema Simpes Nacional
    	 	//===============================================================================================================
	  	 	_csimplesj := alltrim(SA1->A1_CGC)
	  	 	IF valtype(oproc) = "O"
	  	 		oproc:cCaption := ("Consultando Simples...")
	  	 		ProcessMessages()
		  	Else  
   			u_itconout("Consultando Simples...")
	  	 	EndIf

         //Faz chamada ao webservice do Simples
         If _lLinkPrd
            //====================================================================
            // Link base produção
            //====================================================================
            cUrlsimples  := "https://api.maxxi.cisp.com.br/public-bases/v1/simples-nacional/cnpj/"+ alltrim(SA1->A1_CGC) + "?dwnljGS5DRJ0BkzGGgRsrNZCUxqdqrZw" //"https://servicos.cisp.com.br/v1/simples-nacional/" + alltrim(M->ZX_CGC)
         Else 
            //====================================================================
            // Link base homologação
            //====================================================================
            cUrlsimples  := "https://api-homol.maxxi.cisp.com.br/public-bases/v1/simples-nacional/cnpj/"+ alltrim(SA1->A1_CGC) + "?key=43c629ff-e72e-4172-a0fe-ffdef386573a" //"https://servicos.cisp.com.br/v1/simples-nacional/" + alltrim(M->ZX_CGC)
         EndIf 
			
         aHeadOut := {} 
         aAdd( aHeadOut , "accept:application/json")

   		//Faz chamada ao webservice do Simples
   		CHdSimples  := ""
   		cCorSimples := HttpGet(cUrlsimples ,"",NIL,aHeadOut,@cHdSimples)
         //cCorSimples := DecodeUTF8(cCorSimples, "cp1252") 
         
         _cDecodeTxt := ""
         If ! Empty(cCorSimples) 
			   _cDecodeTxt := DecodeUTF8(cCorSimples, "cp1252")  
         EndIf 
			
         If ! Empty(_cDecodeTxt)
            cCorSimples :=_cDecodeTxt
         EndIf 

         //Verifica e formata resposta do Simples
   		If Substr(cHdSimples,1,15) == "HTTP/1.1 200 OK" .and. ValType(_cRetSimpl) == "U" // FWJsonDeserialize(cCorSimples,@_osimples) 
            _oJsonSimp  := JsonObject():new()

            _cRetSimpl := _oJsonSimp:FromJson(cCorSimples) 

			   _aNamesSip := _oJsonSimp:GetNames()
            _oSimplNac := _oJsonSimp:GetJsonObject("company")
            _oSimplNac := _oSimplNac[1]
            _cSimplNac := _oSimplNac:GetJsonObject("business")
            _cSimplOpt := _cSimplNac:GetJsonObject("taxSystem")
            _cSimpNcOp := _cSimplOpt:GetJsonObject("statusSimplesNacional")

            If ! Empty(_cSimpNcOp)
               _cSimpNcOp := Upper(_cSimpNcOp)
            EndIf 
   		  	
	  	 	   //Verifica e formata resposta do Simples
	  	 	   If Eval(bType,"_cSimpNcOp") == "C" .and. substr(alltrim(_cSimpNcOp),1, 7) == "OPTANTE" // If Eval(bType,"_osimples:descricaoOptante") == "C" .and. substr(alltrim(_osimples:descricaoOptante),1, 7) == "OPTANTE"
	  	 		   Aadd(_aaju,{"Optante Simples","Vazio","Sim",alltrim(SA1->A1_COD),alltrim(SA1->A1_LOJA)})
  		  	 		_ltemdif := .T.
  	  		   Else
  	  			   Aadd(_aaju,{"Optante Simples","Vazio","Não",alltrim(SA1->A1_COD),alltrim(SA1->A1_LOJA)})
   		  	 	_ltemdif := .T.
  	  		   EndIf
   		Else
   		   Aadd(_aaju,{"Optante Simples","Vazio","Não",alltrim(SA1->A1_COD),alltrim(SA1->A1_LOJA)})
   		   _ltemdif := .T.
	  	 	EndIf
	   EndIf
 
		If _ltemdif
			aadd(_aajug,{"---------","---------------","-------------------","---------------","-------------------","------------------"})
  		 	aadd(_aajug,{"Cliente",SA1->A1_COD + "/" + SA1->A1_LOJA + "  -  "  + SA1->A1_NOME, "  ",alltrim(SA1->A1_COD),alltrim(SA1->A1_LOJA),"Atua cliente antigo"})
 	
			For _nii:= 1 to len(_aaju)
				aadd(_aajug,{_aaju[_nii][1],_aaju[_nii][2],_aaju[_nii][3],alltrim(SA1->A1_COD),alltrim(SA1->A1_LOJA),"Atua cliente antigo"})
			Next
		Endif
			
		_ni++
	Endif
   
   (cAlias)->( dbskip() )
   
Enddo

(cAlias)->( Dbclosearea())

_ahead := {"Campo","Dados Originais Protheus","Dados Sintegra/Receita","CODCLI","LOJACLI","ORIGEM"}

If len(_aajug) == 0
	u_itmsg("Todos os registros estão atualizados!","Atenção",,2)
	Return
Endif

If !(isincallstack("MDIEXECUTE") .or. isincallstack("SIGAADV")) //Detecta se é execução via schedule ou via tela
	_latu := .T.
Else
	_latu := u_itlistbox("Alterações a realizar",_ahead,_aajuG,.T.,1)
Endif

If _latu
	If U_ITGETMV("ITGRVCLI",.F.)
		//Realiza atualizações
		AOMS104H(oproc,_aajug,_chash)
	Endif

	//Manda email
	// AOMS104K(oproc,_aajug) // Na chamada da função AOMS104A o e-mail é enviado.

	u_itmsg("Registros atualizados","Concluído",,2)
Else
   u_itmsg("Processamento cancelado","Atenção",,1)
EndIf
 
Return

/*
===============================================================================================================================
Programa----------: AOMS104K
Autor-------------: Josué Danich
Data da Criacao---: 15/09/2017
===============================================================================================================================
Descrição---------: Rotina para enviar e-mail de notificação de atualização geral  de cadastro de clientes
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
					_aaju - array com alterações realizadas
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS104K(oproc,_aaju)

Local _aConfig	:= U_ITCFGEML('')
Local _cMsgEml	:= ''
Local _cEmail	:= U_ITGETMV( 'IT_CISPCLI' , 'sistema@italac.com.br' )
Local _cData	:= Dtoc(DATE())
Local _cHoraT   := time()
Local _cAssunto := 'Workflow - Atualização geral de cadastro de clientes - ' + dtoc(date()) + " - " + time() 
Local _ni := 1
Default _aaju := {}

If len(_aaju) < 1

	Return
	
Endif

IF valtype(oproc) = "O"

      	oproc:cCaption := ("Enviando email...")
   		ProcessMessages()
 
ENDIF


_cMsgEml := '<html>'
_cMsgEml += '<head><title></title>Log de Processamento</head>'
_cMsgEml += '<body>'
_cMsgEml += '<style type="text/css"><!--'
_cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
_cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
_cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
_cMsgEml += 'td.aceito	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #00CC00; }'
_cMsgEml += 'td.recusa  { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FF0000; }'
_cMsgEml += '--></style>'
_cMsgEml += '<center>'
_cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="700" height="50"><br>'
_cMsgEml += '<table class="bordasimples" width="700">'
_cMsgEml += '    <tr>'
_cMsgEml += '	<td class="titulos"><center>Atualização dados geral no cadasto de clientes - ' + dtoc(date()) + " - " + time()  + "</center></td>'
_cMsgEml += '	</tr>'
_cMsgEml += '</table>'
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="700">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="2" class="grupos">Log Processamento</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Data:</b></td>'
_cMsgEml += '      <td class="itens" align="left" >'+ _cData +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Hora:</b></td>'
_cMsgEml += '      <td class="itens" align="left" >'+ _cHoraT +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'

If !(isincallstack("MDIEXECUTE") .or. isincallstack("SIGAADV")) //Detecta se é execução via schedule ou via tela

	_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Responsável:</b></td>'
	_cMsgEml += '      <td class="itens" align="left" >Schedule</td>'
	_cMsgEml += '    </tr>'

Else

	_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Responsável:</b></td>'
	_cMsgEml += '      <td class="itens" align="left" >'+ cusername +'</td>'
	_cMsgEml += '    </tr>'

Endif

If !(U_ITGETMV("ITGRVCLI",.F.))

	_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Obs:</b></td>'
	_cMsgEml += '      <td class="itens" align="left" >Alterações não foram efetuadas pois o parâmetro ITGRVCLI está desabilitado</td>'
	_cMsgEml += '    </tr>'

Endif

_cMsgEml += '	<tr>'
_cMsgEml += '      <td class="titulos" align="center" colspan="2"><font color="red">Esta é uma mensagem automática. Por favor não responder!</font></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '</table>'

	
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="2500">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="5" class="grupos">Alterações realizadas</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Cliente</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Informação</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="40%"><b>Valor Original</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="40%"><b>Novo Valor</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="40%"><b>Origem dos dados</b></td>'
_cMsgEml += '    </tr>'

//_ahead := {"Campo","Dados Originais Protheus","Dados Sintegra/Receita","CODCLI","LOJACLI","ORIGEM"}

_cMsgEml += '</center>'

For _ni := 1 to len(_aaju)

	If alltrim(_aaju[_ni][1]) != "Cliente" .and. _aaju[_ni][2] != _aaju[_ni][3];
		.and. !(alltrim(_aaju[_ni][1]) == "Consulta Receita" .or. alltrim(_aaju[_ni][1]) == "Atua Receita";
		  		.or. alltrim(_aaju[_ni][1]) == "Consulta Sintegra"  .or. alltrim(_aaju[_ni][1]) == "Atua Sintegra")
		
	
		_dori := _aaju[_ni][2]
		_dnew := _aaju[_ni][3]
	
		If Eval(bType,'_dori') = "C"
		
			_dadoori := _aaju[_ni][2]
			
		Elseif Eval(bType,'_dori') = "D"
		
			_dadoori := dtoc(_aaju[_ni][2])
			
		Else
		
			_dadoori := " "
			
		Endif
		
		If Eval(bType,'_dnew') = "C"
		
			_dadonew := _aaju[_ni][3]
			
		Elseif Eval(bType,'_dnew') = "D"
		
			_dadonew := dtoc(_aaju[_ni][3])
			
		Else
		
			_dadonew := " "
			
		Endif
		
		_cMsgEml += '    <tr>'
		_cMsgEml += '      <td class="itens" align="left" >' + _aaju[_ni][4] + '/' + _aaju[_ni][5] + ' - ' 
		_cMsgEml += substr(posicione("SA1",1,xfilial("SA1")+_aaju[_ni][4]+_aaju[_ni][5],"A1_NOME"),1,20) + '</td>'
		_cMsgEml += '      <td class="itens" align="left" >' + _aaju[_ni][1] + '</td>'
		_cMsgEml += '      <td class="itens" align="left" >'+ _dadoori + '</td>'
		_cMsgEml += '      <td class="itens" align="left" >'+ _dadonew + '</td>'
		_cMsgEml += '      <td class="itens" align="left" >'+ _aaju[_ni][6] + '</td>'
		_cMsgEml += '    </tr>'

	Endif

  
Next

_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center">     </td>'
_cMsgEml += '      <td class="itens" align="left" >      </td>'
_cMsgEml += '    </tr>'

_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
_cMsgEml += '      <td class="itens" align="left" > ['+ GetEnvServer() +'] </td>'
_cMsgEml += '    </tr>'

_cMsgEml += '</body>'
_cMsgEml += '</html>'

_cEmlLog := ''
//    ITEnvMail(cFrom     ,cEmailTo ,cEmailCo,cEmailBcc,cAssunto ,cMensagem,cAttach   ,cAccount    ,cPassword   ,cServer      ,cPortCon    ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro)
U_ITENVMAIL( _aConfig[01] , _cEmail ,        ,         ,_cAssunto, _cMsgEml ,         ,_aConfig[01],_aConfig[02], _aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

Return .T.


/*
===============================================================================================================================
Programa----------: AOMS104H
Autor-------------: Josué Danich
Data da Criacao---: 15/09/2017
===============================================================================================================================
Descrição---------: Grava alterações de ajuste geral
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
					_aaju - array com alterações realizadas
					_chash - consultas realizadas
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function AOMS104H(oproc,_aaju,_chash)

Local _ni := 1

Default _aaju := {}

If !(isincallstack("MDIEXECUTE") .or. isincallstack("SIGAADV")) //Detecta se é execução via schedule ou via tela

  cusername := "Schedule"
  
Endif

If len(_aaju) < 1

	Return
	
Endif

IF valtype(oproc) = "O"

      	oproc:cCaption := ("Gravando alterações...")
   		ProcessMessages()
 
ENDIF

Begin Transaction

For _ni := 1 to len(_aaju)

	IF valtype(oproc) = "O"

      	oproc:cCaption := ("Gravando alterações - " + strzero(_ni,6) + " de " + strzero(len(_aaju),6))
   		ProcessMessages()
 
   	ENDIF


	SA1->(Dbsetorder(1))
	If _aaju[_ni][1] != "---------" .and. _aaju[_ni][1] != "Cliente" .and. SA1->(Dbseek(xfilial("SA1")+_aaju[_ni][4] + _aaju[_ni][5]))
	
		_lbloq := .F.
		Reclock("SA1",.F.)
		Reclock("ZGF",.T.)
		
		ZGF->ZGF_CODCLI := SA1->A1_COD
  	  	ZGF->ZGF_LOJA := SA1->A1_LOJA
  	  	ZGF->ZGF_HASH := _chash
  	  	ZGF->ZGF_NOMEA := SA1->A1_NOME
  		ZGF->ZGF_INSCA := SA1->A1_INSCR 
  		ZGF->ZGF_ENDA := SA1->A1_END
  	  	ZGF->ZGF_BAIRA := SA1->A1_BAIRRO
  	  	ZGF->ZGF_MUNA := SA1->A1_MUN
  	  	ZGF->ZGF_CMUNA := SA1->A1_COD_MUN
  	  	ZGF->ZGF_ESTA := SA1->A1_EST
  	  	ZGF->ZGF_CEPA := SA1->A1_CEP
  	  	ZGF->ZGF_SCSTA := SA1->A1_I_SCST
  	  	ZGF->ZGF_D1STA := SA1->A1_I_D1ST
  	  	ZGF->ZGF_D2STA := SA1->A1_I_D2ST
  	  	ZGF->ZGF_D3STA := SA1->A1_I_D3ST
  	  	ZGF->ZGF_D3STN := DATE()
  	  	ZGF->ZGF_MSBLA := SA1->A1_MSBLQL
  	  	ZGF->ZGF_HRSTA := SA1->A1_I_HRST
  	  	ZGF->ZGF_HRSTN := TIME()
  	  	ZGF->ZGF_RCSTA := SA1->A1_I_SCRC
  	  	ZGF->ZGF_D1RCA := SA1->A1_I_D1RC
  	  	ZGF->ZGF_D2RCA := SA1->A1_I_D2RC
  	  	ZGF->ZGF_USER  := cusername
  	  	ZGF->ZGF_OBS   := "Atualização geral de clientes"
  	  	ZGF->ZGF_SIMPA := SA1->A1_SIMPNAC
		
		If _aaju[_ni][1] == "Optante Simples" .and. _aaju[_ni][3] == "Não"
	  	
			SA1->A1_SIMPNAC := '2'
			
		Endif
		
		If _aaju[_ni][1] == "Optante Simples" .and. _aaju[_ni][3] == "Sim"
	  	
			SA1->A1_SIMPNAC := '1'
			
		Endif		
		
		ZGF->ZGF_SIMPN := SA1->A1_SIMPNAC

		If _aaju[_ni][1] == "Inscrição Estadual"
	  	
			SA1->A1_INSCR := _aaju[_ni][3]
			
		Endif
		
		If _aaju[_ni][1] == "Endereço"
	  		
			SA1->A1_END := U_CRMA980VCP(_aaju[_ni][3] ,"A1_END",.T.) 
			
		Endif
		
		If _aaju[_ni][1] == "Bairro" .and. !empty(_aaju[_ni][3])
	  	
			SA1->A1_BAIRRO := U_CRMA980VCP(_aaju[_ni][3] ,"A1_BAIRRO",.T.) 
			
		Endif
		
		If _aaju[_ni][1] == "UF" .AND. !(EMPTY(_aaju[_ni][3]))
	  	
			SA1->A1_EST := _aaju[_ni][3]
			
		Endif
		
		
		If _aaju[_ni][1] == "Municipio"
	  	
			//Exceções
			If alltrim(_aaju[_ni][3]) == 'SANT& X27 ANA DO LIVRAMENTO'
				_aaju[_ni][3] := 'SANTANA DO LIVRAMENTO'
			Endif
			
			_cmun := POSICIONE("CC2",4,xfilial("CC2")+SA1->A1_EST+alltrim(_aaju[_ni][3]),"CC2_CODMUN")
			
			If !empty(_cmun)			
			
				SA1->A1_MUN := _aaju[_ni][3]
				SA1->A1_COD_MUN := _cmun
				
			Endif 
			
		Endif
		
		If _aaju[_ni][1] == "CEP"
	  	
	  		If !(_aaju[_ni][3] == '99999999' .or. _aaju[_ni][3] == '00000000')
	  		
  	  			SA1->A1_CEP := _aaju[_ni][3]
  	  			
  	  		Endif
			
		Endif
				
		
		If _aaju[_ni][1] == "Sit Sintegra"
	  	
			SA1->A1_I_SCST := _aaju[_ni][3]
			
			_csitst := alltrim(_aaju[_ni][3])

			If !(_csitst == "HABILITADO" .OR. _csitst == "HABILITADA" .OR. _csitst == "ATIVO" .OR. _csitst == "ATIVA" .OR. _csitst == "ATIVO - HABILITADO"  .OR. _csitst == "HABILITADO - ATIVO")
			
				SA1->A1_MSBLQL := '1'
				
			Endif
			
		Endif
		
		If _aaju[_ni][1] == "Razão Social"
	  	
			SA1->A1_NOME := U_CRMA980VCP(_aaju[_ni][3] ,"A1_NOME",.T.) 
			
		Endif
		
				
		If _aaju[_ni][1] == "Sit Receita"
	  	
			SA1->A1_I_SCRC := _aaju[_ni][3]
			
			If alltrim(_aaju[_ni][3]) != "ATIVA" .AND.  alltrim(_aaju[_ni][3]) != "ERRO DE CONSULTA"
			
				SA1->A1_MSBLQL := '1'
				
			Endif
			
			
		Endif
		
		If _aaju[_ni][1] == "Consulta Receita"
	  	
			SA1->A1_I_D1RC := _aaju[_ni][3]
			
		Endif
		
		If _aaju[_ni][1] == "Atua Receita"
	  	
			SA1->A1_I_D2RC := _aaju[_ni][3]
			
		Endif
		
		If _aaju[_ni][1] == "Consulta Sintegra"
	  	
			SA1->A1_I_D1ST := _aaju[_ni][3]
			
		Endif

		If _aaju[_ni][1] == "Atua Sintegra"
	  	
			SA1->A1_I_D2ST := _aaju[_ni][3]
			
		Endif
				
  	  	SA1->A1_I_D3ST := DATE()
  	  	SA1->A1_I_HRST := TIME()
  	  	
  	  	ZGF->ZGF_NOMEN := SA1->A1_NOME
  	  	ZGF->ZGF_INSCN := SA1->A1_INSCR
  	  	ZGF->ZGF_ENDN := SA1->A1_END
  	  	ZGF->ZGF_BAIRN := SA1->A1_BAIRRO
  	  	ZGF->ZGF_MUNN := SA1->A1_MUN
  	  	ZGF->ZGF_CMUNN := SA1->A1_COD_MUN
  	  	ZGF->ZGF_ESTN := SA1->A1_EST
  	  	ZGF->ZGF_CEPN := SA1->A1_CEP
  	  	ZGF->ZGF_SCSTN := SA1->A1_I_SCST
  	  	ZGF->ZGF_D1STN := SA1->A1_I_D1ST
  	  	ZGF->ZGF_D2STN := SA1->A1_I_D2ST
  	  	ZGF->ZGF_MSBLN := SA1->A1_MSBLQL
  	  	ZGF->ZGF_RCSTN := SA1->A1_I_SCRC
  	  	ZGF->ZGF_D1RCN := SA1->A1_I_D1RC
  	  	ZGF->ZGF_D2RCN := SA1->A1_I_D2RC
  	  	
  	  	SA1->(Msunlock())
  	  	ZGF->(Msunlock())
  	  	
   	   //===================================================================================
       // Grava os dados dos clientes nas tabelas de muro para integração com o sistema RDC.
       //===================================================================================
       U_AOMS076G()
  		
  	Endif
  	  	
Next

End Transaction

Return

/*
=================================================================================================================================
Programa--------: AOMS104T()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 28/06/2023
=================================================================================================================================
Descrição-------: Tela para seleção filtros para processamento geral.
=================================================================================================================================
Parametros------: Nenhum
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AOMS104T()
Local _lRet := .F.

Begin Sequence
   //================================================================================
   // Tela de Aprovação de Pedido de Vendas
   //================================================================================      
   _cTitulo := "Atualização Geral CISP - Seleção de Estados"
   _bOk := {|| (_lRet := .T., _oDlgCISP:End())}
   _bCancel := {|| _lRet := .F., _oDlgCISP:End()}
   
   _cUFProc := Space(100)

   Define MsDialog _oDlgCISP Title _cTitulo From 9,0 To 17,90 Of oMainWnd 
      
      @ 40,20 Say "Estado/Estados: " Of _oDlgCISP Pixel 
      @ 39,80 MSGet _cUFProc Picture "@!" F3 "LSTEST"  Size 100, 10 Of _oDlgCISP Pixel

   Activate MsDialog _oDlgCISP On Init EnchoiceBar(_oDlgCISP,_bOk,_bCancel) CENTERED 

End Sequence

Return _lRet   

