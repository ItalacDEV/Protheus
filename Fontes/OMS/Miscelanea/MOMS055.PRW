/*
===============================================================================================================================
               ULTIMAS ATUALIZAÃ‡Ã•ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------                  
 Igor Melgaço | 06/08/2021 | Troca de chamada mata030 por CRMA980 - Chamado 37363	
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 11/05/2023 | Ajustar o layout dessa rotina para o novo layout descrito no chamado. Chamado 43808.
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include	"Protheus.Ch"
#Include	"FWMVCDef.Ch"
#Include	"topconn.Ch"

/*
===============================================================================================================================
Programa----------: MOMS055
Autor-------------: Julio de Paula Paz
Data da Criacao---: 24/06/2020
===============================================================================================================================
Descrição---------: Rotina de importação de dados dos clientes do Broker. Chamado 33108.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS055()

Begin Sequence 
   //===========================================================================
   //| Define formato de data para exibiÃ§Ã£o nas telas da rotina                |
   //===========================================================================
   SET DATE FORMAT TO "DD/MM/YYYY"

   //fwmsgrun( ,{|oproc| MOMS055I(oproc) } , "Processando..." , "Iniciando o processamento..." )
   Processa( {|| MOMS055I() } , 'Aguarde!' , "Iniciando o processamento..." )

End Sequence 

Return Nil 

/*
===============================================================================================================================
Programa----------: MOMS055I
Autor-------------: Julio de Paula Paz
Data da Criacao---: 24/06/2020
===============================================================================================================================
DescriÃ§Ã£o---------: Rotina de montagem da tela de processamento
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS055I()
Local _aParAux	:= {}
Local _aParRet	:= {}
Local _aDados		:= {}
Local _nI		:= 0 
Local _aDadosSA1 := {}
Local _cDirErros := GetTempPath()
Local _cNomeArq  := "" 
Local _lMVCSA1   := U_ItGetMv( "MV_MVCSA1" , .F. ) // Parammetro para habilitar execução do ExecAuto do novo CRMA980 
Local _cCnpj     := ""  // CNPJ   		 
Local _cRazao    := "" // Razão Social
Local _cNomeReduz := "" // Nome Fantasia
Local _cEstado    := ""    // Estado
Local _cCodMunic  := ""  // Código do Municipio
Local _cCep       := ""       // CEP
Local _cEndereco  := ""  // Endereco
Local _cComplem   := ""   // Complemento
Local _cBairro    := ""    // Bairro
Local _cDDD       := ""       // DDD
Local _cTelefone  := ""  // Telefone
Local _cInscrEst  := ""  // Inscrição Estadual
Local _cEmail     := ""     // Email
Local _cCondPagto := "" // Condição de Pagamento
Local _cLimiteCr  := ""  // Limite de Crédito 
Local _cEmailCont := "" // E-mail Contato
Local _cContato   := ""   // Contato
Local _cCargoCont := "" // Cargo Contato
Local _cRefCom1   := ""   // Referencia Comercial 1
Local _cTelRefC1  := ""  // Telefone Referencia Comercial 1
Local _cNomeRefC  := ""  // Nome Contato Referencia Comercial 1
Local _cGrupoCli  := ""  // Grupo de Clientes
Local _Simples    := ""  // Simples Nacional
Local _aDadosCli  := {}
Local _cTipoPess  := "" 
Local _cMsgPreVl  := ""  
 
Default oproc2 := nil

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

Begin Sequence 
   
   ProcRegua(0)

   aAdd( _aParAux , { 1 , "Selecione arquivo:"		, Space(150)	, "@!"		, ""	, "DIR"		, "" , 100 , .F. } ) 	//| 01 |

   For _nI := 1 To Len( _aParAux )
	   aAdd( _aParRet , _aParAux[_nI][03] )
   Next _nI

   If !ParamBox( _aParAux , "Importação de clientes Broker" , @_aParRet )
	  U_ItMsg( "Operação cancelada pelo usuário!" , "Atenção!",,1 )
	  Break 
   EndIf

   IncProc("Abrindo arquivo...")
   
   //Se for arquivo excel vai converte primeiro para csv para poder trabalhar
   If ! Upper(Right(alltrim(MV_PAR01),3)) == "CSV" // .And. ! Upper(Right(AllTrim(MV_PAR01),4)) == "XLSX" 
      U_ItMsg( "O Arquivo informado não está no formato CSV." , "Atenção!",,1 ) // U_ItMsg( "O Arquivo informado não é uma planilha em Excel." , "Atenção!",,1 )
	  Break 
   EndIf 
 
   _aDados := U_MOMS055L(AllTrim(MV_PAR01))

   If Empty(_aDados) .Or. Len(_aDados)  == 0
      U_ItMsg( "Não ha dados para importação dos clientes Broker." , "Atenção!",,1 ) 
	  Break
   EndIf 
 
   ProcRegua(Len(_aDados))
      
   SA1->(DbSetOrder(3))
   ZA5->(DbSetOrder(1)) // ZA5_FILIAL+ZA5_CEP

   For _nI := 1 To Len(_aDados)

       IncProc("Processando Cliente: " + AllTrim(Str(_nI,10)) + " de " + AllTrim(Str(Len(_aDados),10)))

       _cLinha := _aDados[_nI]  
	    _alinha := U_ITTXTARRAY(_cLinha,";",23)

       //=============================================
       // Inicializa as Variáveis 
	    //=============================================
	    _cCnpj      := ""      // CNPJ   		 
       _cRazao     := ""     // Razão Social
       _cNomeReduz := "" // Nome Fantasia
       _cEstado := ""    // Estado
       _cCodMunic := ""  // Código do Municipio
       _cCep := ""       // CEP
       _cEndereco := ""  // Endereco
       _cComplem := ""   // Complemento
       _cBairro := ""    // Bairro
       _cDDD := ""       // DDD
       _cTelefone := ""  // Telefone
       _cInscrEst := ""  // Inscrição Estadual
       _cEmail := ""     // Email
       _cCondPagto := "" // Condição de Pagamento
       _cLimiteCr := ""  // Limite de Crédito 
       _cEmailCont := "" // E-mail Contato
       _cContato := ""   // Contato
       _cCargoCont := "" // Cargo Contato
       _cRefCom1 := ""   // Referencia Comercial 1
       _cTelRefC1 := ""  // Telefone Referencia Comercial 1
       _cNomeRefC := ""  // Nome Contato Referencia Comercial 1
       _cGrupoCli := ""  // Grupo de Clientes
       _cMsgPreVl := ""  // Mensagem de Pré-Validação
       _Simples   := ""  // Simples Nacional 

       //=============================================
       // Atribui os Dados.
	    //=============================================
       If "," $ _alinha[15] // Verifica se há virgula como separador de decimais no campo limite de crédito.
          _alinha[15] := StrTran(_alinha[15],",",".")
       EndIf 

       _cCnpj      :=  _alinha[1]  // CNPJ   		                       // 1 
       _cRazao     :=  _alinha[2]  // Razão Social                        // 2 
       _cNomeReduz :=  _alinha[3]  // Nome Fantasia                       // 3  
       _cEstado    :=  _alinha[4]  // Estado                              // 4
       _cCodMunic  :=  SubStr(_alinha[5],3,5)  // Código do Municipio     // 5
       _cCep       :=  _alinha[6]  // CEP                                 // 6
       _cEndereco  :=  _alinha[7]  // Endereco                            // 7 
       _cComplem   :=  _alinha[8]  // Complemento                         // 8 
       _cBairro    :=  _alinha[9]  // Bairro                              // 9
       _cDDD       :=  _alinha[10] // DDD                                 // 10
       _cTelefone  :=  _alinha[11] // Telefone                            // 11
       _cInscrEst  :=  _alinha[12] // Inscrição Estadual                  // 12
       _cEmail     :=  AllTrim(_alinha[13]) // Email                      // 13
       _cCondPagto :=  _alinha[14] // Condição de Pagamento               // 14
       _nLimiteCr  :=  Val(AllTrim(_alinha[15])) // Limite de Crédito     // 15
       _cEmailCont :=  AllTrim(_alinha[16]) // E-mail Contato             // 16  
       _cContato   :=  _alinha[17] // Contato                             // 17
       _cCargoCont :=  _alinha[18] // Cargo Contato                       // 18
       _cRefCom1   :=  _alinha[19] // Referencia Comercial 1              // 19
       _cTelRefC1  :=  _alinha[20] // Telefone Referencia Comercial 1     // 20
       _cNomeRefC  :=  _alinha[21] // Nome Contato Referencia Comercial 1 // 21
       _cGrupoCli  :=  _alinha[22] // Grupo de Clientes                   // 22
       _Simples    :=  _alinha[23] // Simples Nacional- (A1_SIMPNAC)      // 23

       If Upper(_cCnpj) == "CNPJ" // Desconsidera a linha de titulos.
	      Loop 
	    EndIf

       If SA1->(MSSEEK(xFilial("SA1")+U_ItKey(_cCnpj,"A1_CGC")))
          _cMsgPreVl += "Cliente já cadastrado, dados não foram importados."

        
            //SA1->(RecLock("SA1", .F.))  
            //SA1->A1_VEND    := '002186'
            //SA1->A1_I_VEND2 := '002185'
            //SA1->(MsUnLock())          
 
       EndIf 

      If Empty(_cRazao) // A1_NOME
         _cMsgPreVl += "Razão social não preenchida. "
      EndIf 

      If Empty(_cNomeReduz) // A1_NREDUZ
         //_cMsgPreVl += "Nome fantasia não preenchido. "
         _cNomeReduz := (SUBSTR( _cRazao, 1, 20))
      EndIf 

      If Empty(_cEstado) // A1_EST
         _cMsgPreVl += "Estado/UF não preenchido. "
      EndIf 

      If Empty(_cCodMunic) // A1_COD_MUN
         _cMsgPreVl += "Codigo de município não preenchido. "
      EndIf 

      If Empty(_cCep)  // A1_CEP
         _cMsgPreVl += "CEP não preenchido. "
      Else
         If ! ZA5->(MsSeek(xFilial("ZA5")+U_ItKey(_cCep,"ZA5_CEP"))) 
            _cMsgPreVl += "O CEP informado não existe no cadastro de CEP Italac. "
         Else 
            If !Empty(Alltrim(ZA5->ZA5_BAIRRO))
               _cBairro:=Alltrim(ZA5->ZA5_BAIRRO)
            End
         Endif

      EndIf

      If Empty(_cEndereco) // A1_END
         _cMsgPreVl += "Endereço não preenchido. "
      EndIf 

      If Empty(_cBairro) // A1_BAIRRO
         _cMsgPreVl += "Bairro não preenchido. "
      EndIf 
    
      If Empty(_cDDD) // A1_DDD
         _cMsgPreVl += "DDD não preenchido. "
      EndIf 

      If Empty(_cTelefone) // A1_TEL
         _cMsgPreVl += "Telefone não preenchido. "
      EndIf 

      If Empty(_cGrupoCli) // A1_I_GRCLI
         _cMsgPreVl += "Seguimento Clientes não preenchido. "
      EndIf 
      
      If Alltrim(_Simples) == "S"// A1_SIMPNAC
         _Simples := '1'
      Else 
         _Simples := '2'
      End

      If Empty(_cCondPagto) // A1_COND
         _cMsgPreVl += "Condição de pagamento não preenchida. "
      EndIf 

      //Limite de Crédito importado Padrão R$ 100,00 
      _nLimiteCr := 100
      //If _nLimiteCr == 0
      //   _cMsgPreVl += "Limite de Crédito não informado. " 
      //EndIf 

      If Right(_cEmail,1) == ","
         _cEmail := SubStr(_cEmail,1,Len(_cEmail) - 1)   
      EndIf 
     
      _cEmail := StrTran(_cEmail,",",";") 

      If Right(_cEmailCont,1) == ","
         _cEmailCont := SubStr(_cEmailCont,1,Len(_cEmailCont) - 1)
      EndIf 
      
      _cEmailCont := StrTran(_cEmailCont,",",";")

      If Empty(_cEmail)
         _cMsgPreVl += "O e-mail não foi informado."  
      ElseIf ! EEmail( _cEmail )
         _cMsgPreVl += "O e-mail informado não está no formato correto. "  
      EndIf 

      If !Empty(_cEmailCont) .And. ! EEmail( _cEmailCont )
         _cMsgPreVl += "O e-mail do contato informado não está no formato correto. "  
      EndIf 

      //=============================================
      // Monta o aDados
	   //=============================================
      Aadd(_aDadosCli,{_cCnpj,;       // CNPJ   		                        // 1
                        _cRazao,;      // Razão Social                        // 2 
                        _cNomeReduz,;  // Nome Fantasia                       // 3  
                        _cEstado,;     // Estado                              // 4
                        _cCodMunic,;   // Código do Municipio                 // 5
                        _cCep,;        // CEP                                 // 6
                        _cEndereco,;   // Endereco                            // 7 
                        _cComplem,;    // Complemento                         // 8 
                        _cBairro,;     // Bairro                              // 9
                        _cDDD,;        // DDD                                 // 10
                        _cTelefone,;   // Telefone                            // 11
                        _cInscrEst,;   // Inscrição Estadual                  // 12
                        _cEmail,;      // Email                               // 13
                        _cCondPagto,;  // Condição de Pagamento               // 14
                        _nLimiteCr,;   // _cLimiteCr,;   // Limite de Crédito // 15
                        _cEmailCont,;  // E-mail Contato                      // 16  
                        _cContato,;    // Contato                             // 17
                        _cCargoCont,;  // Cargo Contato                       // 18
                        _cRefCom1,;    // Referencia Comercial 1              // 19
                        _cTelRefC1,;   // Telefone Referencia Comercial 1     // 20
                        _cNomeRefC,;   // Nome Contato Referencia Comercial 1 // 21
                        _cGrupoCli,;   // Grupo de Clientes                   // 22
                        _Simples,;     // Simples Nacional                    // 23
					         _cMsgPreVl})   // "RESULTADO INTEGRAÇÃO"              // 24

   Next 

   IncProc("Exibindo lista de Clientes processados...")
 
   _aTitulos := {"CNPJ",;                    // 1
                 "RAZAO SOCIAL",;            // 2
	    		     "NOME FANTASIA",;           // 3
			        "UF",;                      // 4
			        "COD CIDADE",;              // 5
			        "CEP",;                     // 6
			        "ENDEREÇO",;                // 7
			        "COMPLEMENTO",;             // 8
			        "BAIRRO",;                  // 9 
			        "DDD",;                     // 10
			        "TELEFONE",;                // 11
			        "INS. ESTADUAL",;           // 12
			        "EMAIL para envio XML",;    // 13
			        "COND PAGTO",;              // 14
				     "LIMITE DE CREDITO",;       // 15 
			        "EMAIL DO CONTATO",;        // 16
			        "NOME DO CONTATO",;         // 17
			        "CARGO DO CONTATO",;        // 18
			        "REFERENCIA COMERCIAL 1",;  // 19
			        "TELEFONE REF.COM.1",;      // 20 
			        "NOME CONTATO REF.COM.1",;  // 21 
			        "SEGUIMENTO DO CLIENTE",;   // 22 
			        "SIMPLES NACIONAL",;   // 23
				     "RESULTADO INTEGRAÇÃO"}     // 24

      //ITListBox( _cTitAux                                      , _aHeader   , _aCols  , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons, _aCab , bDblClk , _aColXML , bCondMarca)
   If U_ITListBox( 'Importação de Dados de Clientes do Broker' ,  _aTitulos , _aDadosCli , .F.      , 1      , 'Clique em OK para confirmar a importação dos dados. ' )

      ProcRegua(Len(_aDadosCli))

	   For _nI := 1 To Len(_aDadosCli)
	  
         IncProc("Atualizando Cadastro de Clientes: " + AllTrim(Str(_nI,10)) + " de " + AllTrim(Str(Len(_aDadosCli),10)))

         If !Empty(_aDadosCli[_nI, 24])
            Loop // Há inconsistencia de dados.
         EndIf 
         
         _aDadosSA1 := {}

         _cTipoPess := "J"
         If Len(_aDadosCli[_nI, 1]) < 14
            _cTipoPess := "F"
         EndIf 

          Aadd(_aDadosSA1,{"A1_CGC"         , U_ITKEY(_aDadosCli[_nI, 1],"A1_CGC")     , Nil}) // CNPJ/CGC 	
		    Aadd(_aDadosSA1,{"A1_NOME"        , U_AOMS014S(U_ITKEY(_aDadosCli[_nI, 2],"A1_NOME"))    , Nil}) // Razão Social
          Aadd(_aDadosSA1,{"A1_NREDUZ"      , U_AOMS014S(U_ITKEY(_aDadosCli[_nI, 3],"A1_NREDUZ"))  , Nil}) // Nome Fantasia 	
          Aadd(_aDadosSA1,{"A1_EST"         , U_AOMS014S(U_ITKEY(_aDadosCli[_nI, 4],"A1_EST"))     , Nil}) // Estado 	
          Aadd(_aDadosSA1,{"A1_COD_MUN"     , U_ITKEY(_aDadosCli[_nI, 5],"A1_COD_MUN") , Nil}) // Código do Município 	
          Aadd(_aDadosSA1,{"A1_CEP"         , U_ITKEY(_aDadosCli[_nI, 6],"A1_CEP")     , Nil}) // CEP 	
          Aadd(_aDadosSA1,{"A1_END"         , U_AOMS014S(U_ITKEY(_aDadosCli[_nI, 7],"A1_END"))     , Nil}) // Endereço 	
          Aadd(_aDadosSA1,{"A1_COMPLEM"     , U_AOMS014S(U_ITKEY(_aDadosCli[_nI, 8],"A1_COMPLEM")) , Nil}) // Complemento de Endereço 	
          Aadd(_aDadosSA1,{"A1_BAIRRO"      , U_AOMS014S(U_ITKEY(_aDadosCli[_nI, 9],"A1_BAIRRO"))  , Nil}) // Bairro 	
          Aadd(_aDadosSA1,{"A1_DDD"         , U_ITKEY(_aDadosCli[_nI, 10],"A1_DDD")    , Nil}) // DDD 	
          Aadd(_aDadosSA1,{"A1_TEL"         , U_ITKEY(_aDadosCli[_nI, 11],"A1_TEL")    , Nil}) // Telefone 	
          Aadd(_aDadosSA1,{"A1_INSCR"       , U_ITKEY(_aDadosCli[_nI, 12],"A1_INSCR")  , Nil}) // Inscrição Estadual 	
          Aadd(_aDadosSA1,{"A1_EMAIL"       , U_ITKEY(_aDadosCli[_nI, 13],"A1_EMAIL")  , Nil}) // E-mail 	
          Aadd(_aDadosSA1,{"A1_COND"        , U_ITKEY(_aDadosCli[_nI, 14],"A1_COND")   , Nil}) // Condição de Pagamento 	
          Aadd(_aDadosSA1,{"A1_LC"          , _aDadosCli[_nI, 15]                      , Nil}) // Limite de Crédito. 	
          Aadd(_aDadosSA1,{"A1_I_EMAI"      ,(Alltrim(_aDadosCli[_nI, 16]),"A1_I_EMAI") , Nil}) // E-mail Contato 	
          Aadd(_aDadosSA1,{"A1_CONTATO"     , U_AOMS014S(U_ITKEY(_aDadosCli[_nI, 17],"A1_CONTATO")), Nil}) // Contato 	
          Aadd(_aDadosSA1,{"A1_I_CARGC"     , U_AOMS014S(U_ITKEY(_aDadosCli[_nI, 18],"A1_I_CARGC")), Nil}) // Cargo Contato 	
          Aadd(_aDadosSA1,{"A1_I_DTCAD"	  , dDatabase								         , Nil}) // 
          Aadd(_aDadosSA1,{"A1_NATUREZ"     , "111001"  							            , Nil}) 
          Aadd(_aDadosSA1,{"A1_CODPAIS"	  , "01058"				  				            , Nil})
          Aadd(_aDadosSA1,{"A1_MSBLQL"	     , "2"									            , Nil})
          Aadd(_aDadosSA1,{"A1_PAIS"	     , "105"								            , Nil})
          Aadd(_aDadosSA1,{"A1_PESSOA"	     , _cTipoPess                   				, Nil})	
          Aadd(_aDadosSA1,{"A1_RISCO"	     , "C"												   , Nil})	
          Aadd(_aDadosSA1,{"A1_I_IBOLE"	  , "S"								               , Nil}) 
          Aadd(_aDadosSA1,{"A1_TIPO"	     , "R"								               , Nil}) 
          Aadd(_aDadosSA1,{"A1_GRPVEN"	     , "999999"						               , Nil})
          Aadd(_aDadosSA1,{"A1_VEND"	     , "002191"						               , Nil})          
          Aadd(_aDadosSA1,{"A1_I_VEND2"	  , "002190"						               , Nil})   
          Aadd(_aDadosSA1,{"A1_CARGO3"	     , "MOMS055"						               , Nil})   
          Aadd(_aDadosSA1,{"A1_ESTC"        , U_AOMS014S(U_ITKEY(_aDadosCli[_nI, 4],"A1_ESTC"))    , Nil}) // Estado de Cobrança 	
          Aadd(_aDadosSA1,{"A1_I_CMUNC"     , U_ITKEY(_aDadosCli[_nI, 5],"A1_I_CMUNC") , Nil}) // Código do Município 	
          Aadd(_aDadosSA1,{"A1_CEPC"        , U_ITKEY(_aDadosCli[_nI, 6],"A1_CEP")     , Nil}) // CEP de Cobrança 	
          Aadd(_aDadosSA1,{"A1_BAIRROC"     , U_AOMS014S(U_ITKEY(_aDadosCli[_nI, 9],"A1_BAIRRO"))  , Nil}) // Bairro de Cobrança 		
          Aadd(_aDadosSA1,{"A1_I_GRCLI"     , U_ITKEY(_aDadosCli[_nI, 22],"A1_I_GRCLI"), Nil})  // Grupo de Clientes/Rede 
          Aadd(_aDadosSA1,{"A1_SIMPNAC"     , U_ITKEY(_aDadosCli[_nI, 23],"A1_SIMPNAC"), Nil})  // Simples Nacional
 
          If Alltrim(_aDadosCli[_nI, 23]) == "1" .And. Alltrim(_aDadosCli[_nI, 4]) == "PR"
               Aadd(_aDadosSA1,{"A1_GRPTRIB"     , "023", Nil})  // Simples Nacional
          ENDIF
  
          _cCodigo := U_MOMS055D(U_ITKEY(_aDadosCli[_nI, 1],"A1_CGC"))
          _cLoja  :=  U_MOMS055E(U_ITKEY(_aDadosCli[_nI, 1],"A1_CGC"))
   
          Aadd(_aDadosSA1,{"A1_COD"	     , _cCodigo					               , Nil}) 
          Aadd(_aDadosSA1,{"A1_LOJA"	  , _cLoja					               , Nil})           

          lMsErroAuto := .F. 
 
          If _lMVCSA1
             MSExecAuto( {|x,y,z| CRMA980(x,y,z) } , _aDadosSA1 , 3 , ) // SIGA AUTO PARA A INCLUSAO DO CLIENTE
          Else
             MSExecAuto({|x,y| Mata030(x,y)},_aDadosSA1,3)
          EndIf
 
          _cDirErros := AllTrim(_cDirErros)
          If Right(_cDirErros,1) <> "\"
             _cDirErros := _cDirErros + "\"
          EndIf
          
		  _cNomeArq := "Cliente_" + Alltrim(_aDadosCli[_nI,1 ]) + ".TXT"

		  If lMsErroAuto
		     //_cErro := (MostraErro(_cDirErros + _cNomeArq))
           _cErro := (MostraErro(_cDirErros + _cNomeArq))
			  _aDadosCli[_nI,24] := "Erro na Importação dos Dados do Cliente Broker: " + _cErro  
		  Else
			  _aDadosCli[_nI,24] := "Importado com Sucesso."   
           //=======================================================================
			  // Grava as REFERENCIAS COMERCIAIS E BANCÁRIAS.
			  //=======================================================================
			  //                 Contato                          Referencia Comercial
			  If !Empty(ALLTRIM(_aDadosCli[_nI, 17])) .Or.!EMPTY(ALLTRIM(_aDadosCli[_nI, 19]))
		
		        DBSelectArea("SAO")
		        SAO->( RecLock( "SAO" , .T. ) )
			     SAO->AO_FILIAL	:= xFilial("SAO")
			     SAO->AO_CLIENTE	:= SA1->A1_COD
			     SAO->AO_LOJA	:= SA1->A1_LOJA
			     SAO->AO_TIPO	:= "2"
			     SAO->AO_NOMINS	:= _aDadosCli[_nI,19] // SZX->ZX_RC1EMP // Referencia Comercial
			     SAO->AO_DATA	:= dDataBase
			     SAO->AO_TELEFON	:= _aDadosCli[_nI,20] // SZX->ZX_RC1TEL // Telefone Referência Comercial
			     SAO->AO_CONTATO	:= _aDadosCli[_nI,21] // SZX->ZX_RC1CONT // Nome Contato Referencia Comercial
		        SAO->( MsUnlock() )
			  EndIF

		  EndIf  
	  Next   

     U_ITListBox( 'Resultado da Importação de Dados de Clientes do Broker' ,  _aTitulos , _aDadosCli , .F.      , 1      , 'Clique em OK ou Cancelar para finalizar. ' )	  

   EndIf

End Sequence 

Return Nil

/*
===============================================================================================================================
Função-------------: MOMS055L
Autor--------------: Julio de Paula Paz
Data da Criacao----: 22/05/2023
===============================================================================================================================
Descrição---------: Lê o arquivo texto CSV e retorna uma String de Dados.
===============================================================================================================================
Parametros--------: _cArq = diretório + nome do arquivo a ser lido.
===============================================================================================================================
Retorno-----------: _cRet
===============================================================================================================================
*/  
User Function MOMS055L(_cArq)
Local _nStatusArq 
Local _cLine 
Local _aLinhas := {}

Begin Sequence

   _nStatusArq := FT_FUse(_cArq)
      
   // Se houver erro de abertura abandona processamento
   If _nStatusArq = -1  
      Break
   Endif
   
   // Posiciona na primeria linha
   FT_FGoTop()
   
   While !FT_FEOF()
      
	   _cLine  := FT_FReadLn() 

	   If SubStr(_cLine,1,3) == ";;;" // Indica linhas vazias na planilha CSV.
	      Exit 
	   EndIf 
      
	   Aadd(_aLinhas, _cLine)
   
      FT_FSKIP()
   End

   // Fecha o Arquivo
   FT_FUSE()

End Sequence

Return _aLinhas                    

/*
===============================================================================================================================
Programa----------: EEmail
Autor-------------: Fabiano Dias
Data da Criacao---: 16/02/2011
===============================================================================================================================
Descrição---------: Função para validar se o e-mail informado é válido
===============================================================================================================================
Parametros--------: _cmail - E-mail a ser validado
===============================================================================================================================
Retorno-----------: Lógico - define se o e-mail informado possui os requisitos mínimos de validade
===============================================================================================================================
*/
Static Function EEmail( _cmail ) 

Local _cCaracPerm	:= "ABCDEFGHIJKLMNOPQRSTUVXZWY0123456789"
Local _cCarEspPer	:= "@._-;"  
Local _cCaracter	:= _cCaracPerm + _cCarEspPer 
Local _cEmail		:= Upper(AllTrim(_cmail))
Local _cEmailAux	:= ''
Local _lRet			:= .T.  
Local _nQtde		:= 0
Local _nX			:= 1
Local _nI			:= 1
Local _nPosArrob	:= 0
Local _nPosPonto	:= 0

Private _aEmail		:= {}

_aEmail := StrTokarr(_cEmail,";")  

//================================================================================
// Caso o e-mail esteja em branco não valida e retorna .T. - Chamado 7767
//================================================================================
If Empty(_cEmail)
	Return( .T. ) 
EndIf

//================================================================================
// Verifica se existem caracteres que nao podem ser inseridos no campo e-mail, e 
// verifica o numero de caractres @.
//================================================================================
For _nI := 1 To Len( _aEmail )
    
	_nX := 1
	
	If _lRet
		
		_cEmailAux := AllTrim( _aEmail[_nI] )
		
		While _nX <= Len( _cEmailAux ) .And. _lRet
		
			If !( SubStr( _cEmailAux , _nX , 1 ) $ _cCaracter )
				_lRet := .F.
			EndIf
			
			If '@' == SubStr( _cEmailAux , _nX , 1 )
				_nQtde++
			EndIf
			
		_nX++
		EndDo
		
		If _lRet
		
			//================================================================================
			// Devera ser fornecido pelo  menos um '@' por e-mail
			//================================================================================
			If _nQtde == 0
				_lRet := .F.
			EndIf
			
			//================================================================================
			// Verifca se o primeiro cacter é válido
			//================================================================================
			If !( SubStr( _cEmailAux , 1 , 1 ) $ _cCaracPerm )
				_lRet := .F.
			EndIf
			
			If _lRet 
				
				//================================================================================
				// Verifica a posicao do simbolo @ dentro da string
				//================================================================================
				_nPosArrob := AT( "@" , _cEmailAux )
				
				//================================================================================
				// Verifica a posicao do simbolo @ é a primeira posição da String
				//================================================================================
				If _nPosArrob == 1
					_lRet := .F.
				EndIf
				
				//================================================================================
				// Verifica se existe o caracter '.' depois do '@'
				//================================================================================
				If !( '.' $ SubStr( _cEmailAux , _nPosArrob + 1 , Len( _cEmailAux ) ) )
					_lRet := .F.
				Else
				
					//================================================================================
					// Deve existir no minimo o caracter '.' e mais um carcter depois do .
					//================================================================================
					_nPosPonto := AT( "." , SubStr( _cEmailAux , _nPosArrob + 1 , Len( _cEmailAux ) ) )
					
					//================================================================================
					// Somatorio necessario para saber a posicao do caracter ponto depois do arroba
					//================================================================================
					_nPosPonto += _nPosArrob
					
					If _nPosPonto >= Len( _cEmailAux )
					
						_lRet := .F.
						
					Else
						
						//================================================================================
						// Deve existir no minimo um caracter entre o simbolo de @ e o primeiro '.'
						//================================================================================
						If _nPosArrob + 1 == _nPosPonto
							_lRet := .F.
						EndIf
						
					EndIf
					
					If SubStr( _cEmailAux , Len( _cEmailAux ) , 1 ) $ _cCarEspPer
						_lRet := .F.
					EndIf
					
				EndIf
				
			EndIf
			
		EndIf
		
	EndIf
	
Next _nI

If "ITALAC@ITALAC.COM.BR" $ _cEmail .and. _lRet

	_lret := .F.
	
Endif	

//If !_lRet .And. !IsInCallStack('MSEXECAUTO')
//	u_itmsg( 'O e-Mail informado não é válido para o cadastro!' , 'Atenção!',,1 )
//EndIf

Return( _lRet )


/*
===============================================================================================================================
Programa----------: ITCODCLI
Autor-------------: Cleiton Campos
Data da Criacao---: 14/07/2008
===============================================================================================================================
Descrição---------: Retorna o próximo código sequencial para o cadastro de Clientes
===============================================================================================================================
Parametros--------: _pcTipo 	- Tipo de Pessoa (A1_PESSOA)
------------------: _pcCGC		- CPF/CNPJ do CLiente que está sendo cadastrado (A1_CGC)
===============================================================================================================================
Retorno-----------: _cRetorno	- Retorna o novo código do Cliente para a inclusão (A1_COD)
===============================================================================================================================
*/ 

User Function MOMS055D(_pcCGC)

	Local _aArea    := GetArea()
	Local _cAlias	:= GetNextAlias()
	Local _cQuery   := ""
	local _cRetorno := ""
	Local _cCodigo  := ""
	Local _pcTipo	 := "J"

 

//===============================================================================================
// Monta a consulta do cadastro atual de Clientes
//===============================================================================================
	_cQuery := " SELECT MAX( SA1.A1_COD ) AS CODIGO"
	_cQuery += " FROM " + RetSqlName("SA1") +" SA1 "
	_cQuery += " WHERE "
	_cQuery += " 		SA1.D_E_L_E_T_	= ' ' "
	_cQuery += " AND	SA1.A1_FILIAL	= '"+ xFilial("SA1") +"' "

//===============================================================================================
// Verifica pelo CPF ou CNPJ de acordo com o tipo de cadastro
//===============================================================================================
	IF Alltrim(_pcTipo) == "J"
		_cQuery += " AND	SUBSTR( SA1.A1_CGC , 1 , 8 ) = '" + SubStr( _pcCGC , 1 , 8 ) + "' "
		_cQuery += " AND	SA1.A1_PESSOA = 'J' "
	Else
		_cQuery += " AND	SA1.A1_CGC  = '" + Alltrim( _pcCGC ) + "' "
	EndIF

	DBUseArea( .T. , "TOPCONN" , TCGENQRY(,, _cQuery ) , _cAlias , .F. , .F. )

	DBSelectArea(_cAlias)
	(_cAlias)->( DBGotop() )
	IF (_cAlias)->( !Eof() )
		_cCodigo := (_cAlias)->CODIGO
	EndIF

	(_cAlias)->( DBCloseArea() )

//===============================================================================================
// Se o cliente não existir no cadastro gera um novo sequencial.
//===============================================================================================
	If Empty( _cCodigo )

		DBSelectArea("SA1")
		SA1->( DBSetOrder(1) )
		SA1->( DBGoBottom( ) )
		IF SA1->( !Eof() )

			_cCodigo := Soma1( SA1->A1_COD , TamSX3("A1_COD")[01] )

			//===========================================================================
			//| Se o código estiver reservado na memória pega o próximo                 |
			//===========================================================================
			While !MayIUseCode( "A1_COD" + xFilial("SA1") + _cCodigo )
				_cCodigo := Soma1( _cCodigo , TamSX3("A1_COD")[01] )
			EndDo

		Else

			_cCodigo := StrZero( 1 , TamSX3("A1_COD")[01] )

		EndIF

	EndIf

	_cRetorno := _cCodigo

	RestArea( _aArea )

Return( _cRetorno )


/*
===============================================================================================================================
Programa----------: ITLOJCLI
Autor-------------: Cleiton Campos
Data da Criacao---: 14/07/2008
===============================================================================================================================
Descrição---------: Retorna o código da Loja para o cadastro de Clientes
===============================================================================================================================
Parametros--------: _pcTipo 	- Tipo de Pessoa (A1_PESSOA)
------------------: _pcCGC		- CPF/CNPJ do CLiente que está sendo cadastrado (A1_CGC)
===============================================================================================================================
Retorno-----------: _cRetorno	- Retorna o novo código do Cliente para a inclusão (A1_COD)
===============================================================================================================================
*/

User Function MOMS055E(_cCNPJ)

	Local _aArea		:= GetArea()
	Local _cCod			:= ""
	Local _cRetorno		:= ""

	If Len( Alltrim( _cCNPJ ) ) > 11

		_cRetorno := SubStr( _cCNPJ , 9 , 4 )

		//====================================================================================================
		// VERIFICAR SE O CNPJ DO CLIENTE ESTA CADASTRADO EM ALGUMA LOJA
		//====================================================================================================
		_cCod := Posicione( "SA1" , 3 , xFilial("SA1") + _cCNPJ , "A1_COD" )

		IF !Empty(_cCod)

			_cRetorno := MOMS055F( _cCod , 1 )

		EndIF

	Else

		_cRetorno := MOMS055F( _cCNPJ , 2 )

	EndIf

//====================================================================================================
// Verifica se esta na memoria, sendo usado
//====================================================================================================
	If !MayIUseCode( "A1_LOJA"+ xFilial("SA1") + _cCod + _cRetorno )

		MSGSTOP( "Código: "+ _cCod + " / Loja: " + _cRetorno + " já está sendo utilizado. Contacte o administrador do sistema." )
		Return("")

	EndIf
 
	RestArea( _aArea )

Return( _cRetorno )

/*
===============================================================================================================================
Programa----------: ITRETLOJA
Autor-------------: Cleiton Campos
Data da Criacao---: 14/07/2008
===============================================================================================================================
Descrição---------: Retorna o código da Loja para o cadastro de Clientes
===============================================================================================================================
Parametros--------: _cAux - Tipo de Pessoa (A1_PESSOA)
------------------: _nOpc - Define se busca por CPF ou CNPJ
===============================================================================================================================
Retorno-----------: _cRetorno	- Retorna o novo código do Cliente para a inclusão (A1_COD)
===============================================================================================================================
*/

Static Function MOMS055F( _cAux , _nOpc )

	Local cQuery	:= ""
	Local _cRetorno		:= ""
	Local cAlias	:= GetNextAlias()

	cQuery := " SELECT "
	cQuery += "	MAX( SA1.A1_LOJA ) AS LOJA "
	cQuery += " FROM "+ RetSqlName("SA1") +" SA1 "
	cQuery += " WHERE "
	cQuery += " 	SA1.D_E_L_E_T_	= ' ' "
	If _nOpc == 1
		cQuery += " AND	SA1.A1_COD      = '" + Alltrim( _cAux ) +"' "
	Else
		cQuery += " AND	SA1.A1_CGC      = '" + Alltrim( _cAux ) +"' "
	EndIF

	IF Select(cAlias) > 0
		(cAlias)->( DBCloseArea() )
	EndIF

	DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQuery ) , cAlias , .T. , .F. )

	DBSelectArea(cAlias)
	(cAlias)->( DBGotop() )
	IF (cAlias)->( !Eof() )
		_cRetorno := Soma1( (cAlias)->LOJA )
	EndIF

	(cAlias)->( DBCloseArea() )

Return( _cRetorno )
