/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor       |   Data   |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz   | 22/03/19 | Chamado 28557. Padronização de fontes para funcionar com o novo servidor Totvs Loboguará. 
 Julio Paz   | 26/03/19 | Chamado 28591. Realização de correções na rotina de envio e-mail para as cargas integradas. 
Lucas Borges | 16/10/19 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25. 
Igor Melgaco | 18/12/23 | Chamado 45807. Consulta de Carga sistema TMS embarcador.
Igor Melgaco | 01/02/24 | Chamado 45807. Tratamento para caso o link não tenha sido preenchido e assim corrigir error log no retorno ao executar o HttpPost.
Julio Paz    | 05/02/24 | Chamado 45229/46163. Desenvolvimento das rotinas Integração Webservice Cargas/Veiculos/Motoristas.
Julio Paz    | 05/02/24 | Chamado 45229/46163. Correções na gravação do campo sequência da carga (DAI_SEQUEN).
Alex Wallauer| 18/07/24 | Chamado 47924. Jerry. Correção na gravação do DA3 para fazer com Begin / End Transaction.
===============================================================================================================================

=========================================================================================================================================================
Analista         - Programador       - Inicio     - Envio      - Chamado - Motivo da Alteração
---------------------------------------------------------------------------------------------------------------------------------------------------------
Vanderlei Alves  -  Igor Melgaço     - 26/12/2024 - 09/06/25   - 49427   - Inclusão do metodo de alteração de carga.
Vanderlei Alves  -  Julio Paz        - 13/01/25   - 09/06/25   - 49551   - Ajustar a rotina de criação de cargas no Protheus para gravar o novo campos DAK_I_TMS para informar se a carga foi criada no RDC ou TMS MULTI EMBARCADOR.
Vanderlei Alves  -  Julio Paz        - 14/01/25   - 09/06/25   - 49586   - Realização de Ajustes na Integração de Cargas do TMS MultiEmbarcador.
Vanderlei Alves  -  Julio Paz        - 15/01/25   - 09/06/25   - 49604   - Readequação dos Métodos Utilizados para Integração de Cargas Geradas pelo TMS Multiembarcador
Vanderlei Alves  -  Julio Paz        - 13/03/25   - 09/06/25   - 50181   - Alterar a rotina de integração de Carga Webservice Multiembarcador para utilizar o mesmo CNPJ da Carga para atualizar o cadastro do motorista.
Vanderlei Alves  -  Julio Paz        - 05/02/24   - 10/06/25   - 45229   - Desenvolvimento das rotinas Integração Webservice Cargas/Veiculos/Motoristas.
Vanderlei Alves  -  Julio Paz        - 05/02/24   - 12/06/25   - 45229   - Correções na rotina de integração de Cargas.
Vanderlei Alves  -  Igor Melgaco     - 27/06/25   - 27/06/25   - 45229   - Correcao de url.
=========================================================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================

#Include 'Protheus.ch'
#INCLUDE "APWEBSRV.CH"
//----------------------
#INCLUDE "TBICONN.CH"


#Define TP_GERA_PALET   "1,3,5,6" //"1-Pallet Chep","3-Pallet PBR","5-Pallet Chep Retorno","6-Pallet PBR Retorno"

/*
===============================================================================================================================
Programa----------: AOMS085
Autor-------------: Julio de Paula Paz
Data da Criacao---: 30/11/2016
===============================================================================================================================
Descrição---------: Rotina de visualização dos dados de integração e recebimento da Montagem de Carga dos Pedidos de Vendas 
                    via webservice do sistema RDC.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS085()
Local _aCores := {}
Private aRotina := {}
Private cCadastro 

Begin Sequence

   cCadastro := "Consulta dos dados de Integração de Montagem de Carga Via Webservice: Italac <---> RDC"

   Aadd(aRotina,{"Pesquisar"                            ,"AxPesqui"         ,0,1})
   Aadd(aRotina,{"Visualizar"                           ,"U_AOMS085V"       ,0,2})   
   Aadd(aRotina,{"Envio de Email"                       ,"U_AOMS101({'T'})" ,0,2})   
   Aadd(aRotina,{"Integração WebService"                ,"U_AOMS085R(,'N')" ,0,2})  // Rest/JSon
   Aadd(aRotina,{"Int.WebService Nr.Protocolo"          ,"U_AOMS085R(,'P')" ,0,2})  // Rest/JSon
   Aadd(aRotina,{"Consulta Vale Pedágio"                ,"U_AOMS140L(.F.)"  ,0,2})  // XML
   Aadd(aRotina,{"Integração Troca Nota-Teste"          ,"U_AOMS140H()"     ,0,2})  // XML
   Aadd(aRotina,{"Integração Fechar Carga-Teste"        ,"U_AOMS140J()"     ,0,2})
   Aadd(aRotina,{"Integração Carga Proxima Fase-Teste"  ,"U_AOMS140B()",0,2})
   Aadd(aRotina,{"Integração NF p/Obter Protocolo-Teste","U_AOMS144T()",0,2})
//----------------------------------------------------------------------------------------
   Aadd(aRotina,{"Int.Troca NF Gravação Dados NF"        ,"U_AOMS146A()",0,2})
   Aadd(aRotina,{"Int.Troca NF Transmis.Dados NF"        ,"U_AOMS146B()",0,2})
   Aadd(aRotina,{"Int.Troca NF Gravação.Dados Vinculação","U_AOMS146C()",0,2})
   Aadd(aRotina,{"Int.Troca NF Transmis.Vincula.Ped/NF"  ,"U_AOMS146D()",0,2})   
//----------------------------------------------------------------------------------------
   Aadd(aRotina,{"Int.Troca NF Gravação.Dados Vale Pedágio","U_AOMS146I()",0,2})
   Aadd(aRotina,{"Int.Troca NF Transmis.Vale Pedágio"      ,"U_AOMS146J()",0,2})      
//----------------------------------------------------------------------------------------
   Aadd(aRotina,{"Int.Troca NF Gravação.Dados Solic.Mudança Proxima Fase","U_AOMS146L()",0,2})
   Aadd(aRotina,{"Int.Troca NF Transmis.Mudança Proxima Fase"            ,"U_AOMS146G()",0,2})   
   Aadd(aRotina,{"Alterar Numero de Carga TMS"                           ,"U_AOMS085U()",0,2})   

   Aadd(aRotina,{"Legenda"                              ,"U_AOMS085L"       ,0,6})
   
   Aadd(_aCores,{"ZFU_SITUAC == 'N'" ,"BR_VERDE" })
   Aadd(_aCores,{"ZFU_SITUAC == 'P'" ,"BR_VERMELHO" })
   Aadd(_aCores,{"ZFU_SITUAC == 'R'" ,"BR_AMARELO" })

   DbSelectArea("ZFU")
   ZFU->(DbSetOrder(1)) 
   ZFU->(DbGoTop())
   MBrowse(6,1,22,75,"ZFU", , , , , , _aCores)
   
End Sequence

Return Nil    

/*
===============================================================================================================================
Função------------: AOMS085L
Autor-------------: Julio de Paula Paz
Data da Criacao---: 30/11/2016
===============================================================================================================================
Descrição---------: Rotina de Exibição da Legenda do MBrowse.
==============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS085L()       
Local _aLegenda := {}

Begin Sequence                                                                           
   Aadd(_aLegenda,{"BR_VERDE"    ,"Não Processado" })
   Aadd(_aLegenda,{"BR_AMARELO"  ,"Rejeitada" })
   Aadd(_aLegenda,{"BR_VERMELHO" ,"Processado" })

   BrwLegenda(cCadastro, "Legenda", _aLegenda)

End Sequence

Return Nil

/*
=================================================================================================================================
Programa--------: AOMS085V()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 30/11/2016
=================================================================================================================================
Descrição-------: Exibe os dados da Montagem de Carga do registro posicionado na tela do MsBrowse.
=================================================================================================================================
Parametros------: Nenhum
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function AOMS085V()
Local _aStrucZFV
Local _aCmpZFV := {}
Local _aSizeAut  := MsAdvSize(.T.)
Local _bOk, _bCancel , _cTitulo
Local _lInvZFV := .F.
Local _oDlgEnch, _nI
Local _nReg := 2 , _nOpcx := 2
Local _otemp

Private _oMarkZFV, _cMarcaZFV := GetMark() 
Private aHeader := {} , aCols := {}

Begin Sequence     
   //================================================================================
   // Cria as estruturas das tabelas temporárias
   //================================================================================
   _aStrucZFV := ZFV->(DbStruct())
 
   //================================================================================
   // Verifica se ja existe um arquivo com mesmo nome, se sim fecha.
   //================================================================================
   If Select("TRBZFV") > 0
      TRBZFV->( DBCloseArea() )
   EndIf
   
   //================================================================================
   // Abre o arquivo TRBZFU criado dentro do protheus.
   //================================================================================
   _otemp := FWTemporaryTable():New( "TRBZFV",  _aStrucZFV)
   
   //================================================================================
   // Cria os indices para o arquivo.
   //================================================================================
   _otemp:AddIndex( "01", {"ZFV_ITEM"} )
   _otemp:Create()   
   
   //================================================================================
   // Cria os indices da tabela temporária.
   //================================================================================
   DBSelectArea("TRBZFV")
   
   //============================================================================
   // Montagem do aheader                                                        
   //=============================================================================
   FillGetDados(1,"ZFV",1,,,{||.T.},,,,,,.T.)
   
   //                          1                    2               3              4               5                6             7        8              9                 10 
   // AADD(aHeader, {Alltrim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()", USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
   
   //================================================================================
   // Monta as colunas do MSSELECT para a tabela temporária TRBZFU 
   //================================================================================
   For _nI := 1 To Len(aHeader)
       //If AllTrim(aHeader[_nI,2])=="ZFU_FILIAL" .OR. AllTrim(aHeader[_nI,2])=="ZFU_DSCSIT"
       If !X3USO( aHeader[_nI,7] ) .Or. aHeader[_nI,10] == 'V' .Or. (AllTrim(aHeader[_nI,2]) $ "ZFV_ALI_WT/ZFV_REC_WT")
          Loop
       EndIf
       Aadd( _aCmpZFV , { aHeader[_nI,2], "" , aHeader[_nI,1]  , aHeader[_nI,3] } )
   Next
   
   //================================================================================
   // Carrega os dados da tabela ZFU
   //================================================================================
   For _nI := 1 To ZFU->(FCount())
       &("M->"+ZFU->(FieldName(_nI))) :=  &("ZFU->"+ZFU->(FieldName(_nI)))
   Next
   
   //================================================================================
   // Carrega os dados da tabela ZFV
   //================================================================================
   ZFV->(DbSetOrder(3))  // ZFV_FILIAL+ZFV_CODIGO+ZFV_SITUAC
   ZFV->(DbSeek(ZFU->(ZFU_FILIAL+ZFU_CODIGO+ZFU_SITUAC)))
   Do While ! ZFV->(Eof()) .And. ZFV->(ZFV_FILIAL+ZFV_CODIGO+ZFV_SITUAC) == ZFU->(ZFU_FILIAL+ZFU_CODIGO+ZFU_SITUAC)
      If ZFV->ZFV_REGCAP <> ZFU->ZFU_REGCAP
         ZFV->(DbSkip())
         Loop
      EndIf
      
      TRBZFV->(RecLock("TRBZFV",.T.))
      For _nI := 1 To TRBZFV->(FCount())
          &("TRBZFV->"+TRBZFV->(FieldName(_nI))) :=  &("ZFV->"+ZFV->(FieldName(_nI)))
      Next
      TRBZFV->(MsUnlock())
      
      ZFV->(DbSkip())
   EndDo
   TRBZFV->(DbGoTop())
                                       
   //================================================================================
   // Monta a tela Enchoice ZFU  x MsSelect ZFV
   //================================================================================    
   _aObjects := {} 
   AAdd( _aObjects, { 315,  50, .T., .T. } )
   AAdd( _aObjects, { 100, 100, .T., .T. } )

   _aInfo := { _aSizeAut[ 1 ], _aSizeAut[ 2 ], _aSizeAut[ 3 ], _aSizeAut[ 4 ], 3, 3 } 

   _aPosObj := MsObjSize( _aInfo, _aObjects, .T. ) 
   
   _bOk := {|| _oDlgEnch:End()}
   _bCancel := {|| _lRet := .F., _oDlgEnch:End()}
                       
   _cTitulo := "Integração de Montagem de Carga Via WebService - Visualização"
   
   Define MsDialog _oDlgEnch Title _cTitulo From _aSizeAut[7],00 To _aSizeAut[6], _aSizeAut[5] Of oMainWnd Pixel 
      
      EnChoice( "ZFU" ,_nReg, _nOpcx, , , , , _aPosObj[1], , 3 )
            
      _oMarkZFV := MsSelect():New("TRBZFV","","",_aCmpZFV,@_lInvZFV, @_cMarcaZFV,{_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4]})
        
   Activate MsDialog _oDlgEnch On Init EnchoiceBar(_oDlgEnch,_bOk,_bCancel) 

End Sequence

//================================================================================
// Fecha e exclui as tabelas temporárias
//================================================================================                    
If Select("TRBZFV") > 0
   TRBZFV->(DbCloseArea())
EndIf

Return Nil



/*
===============================================================================================================================
Programa----------: AOMS085J
Autor-------------: Igor Melgaço
Data da Criacao---: 18/12/2023
===============================================================================================================================
Descrição---------: Grava Motorista e Veiculos
===============================================================================================================================
Parametros--------: oMotorista,oVeiculo,oPlacas
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS085J(oMotorista,oVeiculo,oPlacas, _cXMLERRO)

	Local _nTamPlaca  := TAMSX3("DA3_PLACA")[1]
	Local _nTamCPF    := TAMSX3("DA4_CGC")[1]
	Local _nTamCNPJ   := TAMSX3("A2_CGC")[1]
	Local _nTamForn   := TAMSX3("A2_COD")[1]
	Local _nTamLojaF  := TAMSX3("A2_LOJA")[1]
	Local _nTamNReduz := TAMSX3("DA4_NREDUZ")[1]
   Local _lRet       := .T.
	Local _cCnpj
	Local _lAlterar
	Local _cCodEmpWS //:= U_ITGETMV( 'IT_EMPWEBSE' , '000001' )
	Local _cMsg, _cMsgOk
	Local _cQry
	Local _cCod_T, _cLoja_T
	Local _aPlaca := {}
	Local _cPlaca2, _cPlaca3 , _cPlaca4
   Local _nI := 0 

	Local _lTemTransp

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.
	lMsHelpAuto := .F.

	Begin Sequence
        
		_cCodEmpWS := SUPERGETMV('IT_EMPWEBSE',.F.,  "")
		If Empty(_cCodEmpWS)
		   _cCodEmpWS := U_ITGETMV( 'IT_EMPWEBSE' , '000001' )
		EndIf 

		_cMsg      := ""
		_cMsgOk    := ""

		//===========================================================================
		// Gravação do cadastro de  motorisata
		//==========================================================================
		M->DA4_FILIAL  := xFilial("DA4")
		M->DA4_COD     := GETSXENUM("DA4","DA4_COD")
		M->DA4_BAIRRO  := oMotorista:_C_ENDERECO:_D_BAIRRO:TEXT //U_VEICUL:BAIRROM    // Bairro Motorista
		M->DA4_MUNCNH  := oMotorista:_C_CATEGORIACNH:TEXT // U_VEICUL:CATCNH     // Categoria CNH do motorista
		M->DA4_CEP     := oMotorista:_C_ENDERECO:_D_CEP:TEXT //U_VEICUL:CEPM       // CEP do Motorista
		M->DA4_NUMCNH  := oMotorista:_C_NUMEROHABILITACAO:TEXT //U_VEICUL:CNHM       // CNH do motorista
		_cCnpj         := Padr(oMotorista:_C_TRANSPORTADOR:_D_CNPJ:TEXT,_nTamCNPJ," ") //Padr(U_VEICUL:CNPJT,_nTamCNPJ," ")      // CNPJ Transportadora
		M->DA4_CGC     := Padr(oMotorista:_C_CPF:TEXT,_nTamCPF," ")// Padr(U_VEICUL:CPFM ,_nTamCPF," ")      // CPF do motorista
		M->DA4_DTECNH  := Ctod(oMotorista:_C_DATAHABILITACAO:TEXT) //Ctod(U_VEICUL:EMICNH)     // Emissão da CNH
		M->DA4_END     := oMotorista:_C_ENDERECO:_D_LOGRADOURO:TEXT // U_VEICUL:ENDERECOM  // Endereco Motorista
		M->DA4_EST     := oMotorista:_C_ENDERECO:_D_ESTADO:TEXT //U_VEICUL:ESTADOM    // Estado do Motorista
		M->DA4_MAE     := "" //U_VEICUL:MAEM       // Mãe do Motorista
		M->DA4_MUN     := oMotorista:_C_ENDERECO:_D_CIDADE:TEXT //U_VEICUL:MUNICIPIOM // Municipio Motorista
		M->DA4_NOME    := oMotorista:_C_NOME:TEXT //U_VEICUL:NOMEM      // Nome do motorista
		M->DA4_NREDUZ  := SubStr(oMotorista:_C_NOME:TEXT,1,_nTamNReduz)      // Nome do motorista
		M->DA4_PAI     := ""//U_VEICUL:PAIM       // Pai do Motorista
		M->DA4_RG      := oMotorista:_C_RG:TEXT  //U_VEICUL:RGM        // RG do Motorista
		M->DA4_TEL     := oMotorista:_C_ENDERECO:_D_TELEFONE:TEXT  // U_VEICUL:TELEFONEM  // Telefone do Motorista
		M->DA4_TELREC  := oMotorista:_C_ENDERECO:_D_TELEFONE2:TEXT  // U_VEICUL:TELRECM    // Telefone recado Motorista
		M->DA4_DTVCNH  := ctod(oMotorista:_C_DATAVENCIMENTOHABILITACAO:TEXT) // If(Empty(U_VEICUL:VALCNH),Ctod("  /  /  "),Ctod(U_VEICUL:VALCNH))     // Validade da CNH

		SA2->(DbSetOrder(3)) //A2_FILIAL+A2_CGC
		M->DA4_FORNEC := ""
		M->DA4_LOJA    := ""
		_cCod_T  := ""
		_cLoja_T := ""
		_lTemTransp := .F.
		If SA2->(DbSeek(xFilial("SA2")+_cCnpj))
			Do while ! SA2->(Eof()) .And. SA2->(A2_FILIAL+A2_CGC) == xFilial("SA2")+_cCnpj
				If SA2->A2_I_CLASS $ "T/A"

					M->DA4_FORNEC := PadR(SA2->A2_COD,_nTamForn," ")
					M->DA4_LOJA   := PadR(SA2->A2_LOJA,_nTamLojaF," ")
					If SA2->A2_I_CLASS == "T"
						_cCod_T  := PadR(SA2->A2_COD,_nTamForn," ")
						_cLoja_T := PadR(SA2->A2_LOJA,_nTamLojaF," ")
					EndIf
					_lTemTransp := .T.
				EndIf
				SA2->(DbSkip())
			EndDo
		EndIf

		If !_lTemTransp // Não há transportadora cadastrada
			_cMsg := "Não há transportadora cadastrada para o motorista: " + U_VEICUL:NOMEM
			RollbackSx8() //Libera código de motorista que foi pedido
			Break
		EndIf

		//=====================================================================
		// Há transportadora cadastrada. Então atualiza cadastro de motoristas.
		//=====================================================================
		If !Empty(_cCod_T)
			M->DA4_FORNEC := _cCod_T
			M->DA4_LOJA   := _cLoja_T
		EndIf

		_cQry := " SELECT DA4.R_E_C_N_O_ AS NRECNO FROM " + RetSqlName("DA4") + " DA4 "
		_cQry += " WHERE DA4.D_E_L_E_T_ <> '*' AND DA4_CGC = '" + M->DA4_CGC + "' AND DA4_FORNEC = '"+M->DA4_FORNEC+"' AND DA4_LOJA = '"+M->DA4_LOJA+"' "

		If Select("QRYDA4") > 0
			QRYDA4->(DbCloseArea())
		EndIf

		_cQry := ChangeQuery(_cQry)
		//DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry), "QRYDA4", .F., .T.)
		MPSysOpenQuery( _cQry , "QRYDA4")
        DBSelectArea("QRYDA4")

		_lAlterar := .F.
		If ! QRYDA4->(Eof()) .And. !QRYDA4->(Bof())
			_lAlterar := .T.

			DA4->(DbGoTo(QRYDA4->NRECNO))
			M->DA4_COD := DA4->DA4_COD   // Na alteração, atualiza variavel de memoria como o código do Motorista para gravação no veículo.
			RollbackSx8() //Libera código de motorista que foi pedido
		EndIf

		If _lAlterar
			Do While ! QRYDA4->(Eof())
				DA4->(DbGoTo(QRYDA4->NRECNO))

				DA4->(RecLock("DA4",.F.))
				DA4->DA4_BAIRRO :=  M->DA4_BAIRRO      // Bairro Motorista
				DA4->DA4_MUNCNH :=  M->DA4_MUNCNH      // CNH do motorista
				DA4->DA4_EST    :=  M->DA4_EST         // Estado do Motorista
				DA4->DA4_CEP    :=  M->DA4_CEP         // CEP do Motorista
				DA4->DA4_NUMCNH :=  M->DA4_NUMCNH      // CNH do motorista
				DA4->DA4_LOJA   :=  M->DA4_LOJA        // Loja Fornecedor
				DA4->DA4_FORNEC :=  M->DA4_FORNEC      // Fornecedor
				DA4->DA4_LOJA   :=  M->DA4_LOJA        // Loja Fornecedor
				DA4->DA4_CGC    :=  M->DA4_CGC         // CPF do motorista
				DA4->DA4_DTECNH :=  M->DA4_DTECNH      // Emissão da CNH
				DA4->DA4_END    :=  M->DA4_END         // Endereco Motorista
				DA4->DA4_MAE    :=  M->DA4_MAE         // Mãe do Motorista
				DA4->DA4_MUN    :=  M->DA4_MUN         // Municipio Motorista
				DA4->DA4_NOME   :=  M->DA4_NOME        // Nome do motorista
				DA4->DA4_NREDUZ :=  M->DA4_NREDUZ      // Nome do motorista
				DA4->DA4_PAI    :=  M->DA4_PAI         // Pai do Motorista
				DA4->DA4_RG     :=  M->DA4_RG          // RG do Motorista
				DA4->DA4_TEL    :=  M->DA4_TEL         // Telefone do Motorista
				DA4->DA4_TELREC :=  M->DA4_TELREC      // Telefone recado Motorista
				DA4->DA4_DTVCNH :=  M->DA4_DTVCNH      // Validade da CNH
				DA4->(MsUnlock())

				QRYDA4->(DbSkip())
			EndDo
		EndIf

		If Select("QRYDA4") > 0
			QRYDA4->(DbCloseArea())
		EndIf

		If ! _lAlterar
			//===================================================================
			// Verifica se o código do motorista já existe na tabela DA4.
			// Se existir gera um novo código.
			//===================================================================
			DA4->(DbSetOrder(1)) // DA4_FILIAL+DA4_COD
			If DA4->(DbSeek(xFilial("DA4")+M->DA4_COD))
				_cQry := " SELECT Max(DA4.DA4_COD) AS CODMOTOR FROM " + RetSqlName("DA4") + " DA4 "
				_cQry += " WHERE DA4.D_E_L_E_T_ <> '*' "

				If Select("QRYDA4") > 0
					QRYDA4->(DbCloseArea())
				EndIf

				_cQry := ChangeQuery(_cQry)
				//DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry), "QRYDA4", .F., .T.)
				
				MPSysOpenQuery( _cQry , "QRYDA4")
                DBSelectArea("QRYDA4")

				If ! QRYDA4->(Eof()) .And. !QRYDA4->(Bof())
					M->DA4_COD := StrZero(Val(QRYDA4->CODMOTOR) + 1,6)
				EndIf

				If Select("QRYDA4") > 0
					QRYDA4->(DbCloseArea())
				EndIf

			EndIf

			//===================================================================
			// Faz a inclusão do novo motorista.
			//===================================================================
			DA4->(RecLock("DA4",.T.))
			DA4->DA4_FILIAL  := M->DA4_FILIAL
			DA4->DA4_COD     := M->DA4_COD
			DA4->DA4_BAIRRO :=  M->DA4_BAIRRO      // Bairro Motorista
			DA4->DA4_MUNCNH :=  M->DA4_MUNCNH      // CNH do motorista
			DA4->DA4_EST    :=  M->DA4_EST         // Estado do Motorista
			DA4->DA4_CEP    :=  M->DA4_CEP         // CEP do Motorista
			DA4->DA4_NUMCNH :=  M->DA4_NUMCNH      // CNH do motorista
			DA4->DA4_LOJA   :=  M->DA4_LOJA        // Loja Fornecedor
			DA4->DA4_FORNEC :=  M->DA4_FORNEC      // Fornecedor
			DA4->DA4_LOJA   :=  M->DA4_LOJA        // Loja Fornecedor
			DA4->DA4_CGC    :=  M->DA4_CGC         // CPF do motorista
			DA4->DA4_DTECNH :=  M->DA4_DTECNH      // Emissão da CNH
			DA4->DA4_END    :=  M->DA4_END         // Endereco Motorista
			DA4->DA4_MAE    :=  M->DA4_MAE         // Mãe do Motorista
			DA4->DA4_MUN    :=  M->DA4_MUN         // Municipio Motorista
			DA4->DA4_NOME   :=  M->DA4_NOME        // Nome do motorista
			DA4->DA4_NREDUZ :=  M->DA4_NREDUZ      // Nome do motorista
			DA4->DA4_PAI    :=  M->DA4_PAI         // Pai do Motorista
			DA4->DA4_RG     :=  M->DA4_RG          // RG do Motorista
			DA4->DA4_TEL    :=  M->DA4_TEL         // Telefone do Motorista
			DA4->DA4_TELREC :=  M->DA4_TELREC      // Telefone recado Motorista
			DA4->DA4_DTVCNH :=  M->DA4_DTVCNH      // Validade da CNH
			DA4->(MsUnlock())
			ConfirmSx8() //Confirma novo código de motorista
		EndIf

		If _lAlterar
			_cMsgOk := _cMsgOk +  " Alteração do motorista via RDC realizada com sucesso: " + oMotorista:_C_NOME:TEXT //U_VEICUL:NOMEM
		Else
			_cMsgOk := _cMsgOk + " / Inclusão de motorista via RDC realizada com sucesso: " + oMotorista:_C_NOME:TEXT //U_VEICUL:NOMEM
		EndIf

	  _ctipov := "1" // Tipo de Veiculo
	  _nqtd := 0
            
      _cPlaca2 := ""
      _cPlaca3 := ""
      _cPlaca4 := ""
      _cPlaca5 := ""
      
      _aPlaca := {}
	  
	  ConOUt("[AOMS085] - XML ERROR LOG_NOVO ARQUIVO...") 
	  ConOut(_cXMLERRO) 

      If ValType( oVeiculo:_C_REBOQUES:_C_VEICULO) == "A"

         _nqtd := Len(oVeiculo:_C_REBOQUES:_C_VEICULO)
         _cDescTipo := oVeiculo:_C_REBOQUES:_C_VEICULO[1]:_C_MODELOVEICULAR:_D_DESCRICAO:TEXT

         For _nI := 1 To Len(oVeiculo:_C_REBOQUES:_C_VEICULO)
            If !Empty(Alltrim(oVeiculo:_C_REBOQUES:_C_VEICULO[_nI]:_C_PLACA:TEXT)) .AND. aScan(_aPlaca,{|x| x == oVeiculo:_C_REBOQUES:_C_VEICULO[_nI]:_C_PLACA:TEXT}) = 0
               Aadd(_aPlaca,{oVeiculo:_C_REBOQUES:_C_VEICULO[_nI]:_C_PLACA:TEXT,oVeiculo:_C_REBOQUES:_C_VEICULO[_nI]:_C_MODELOVEICULAR:_D_DESCRICAO:TEXT})
            EndIf
         Next
         ASort(_aPlaca, , , {|x,y| x[1] < y[1]})

         For _nI := 1 To Len(_aPlaca)
            &("_cPlaca"+Alltrim(Str(_nI+1))) := PadR(_aPlaca[_nI],_nTamPlaca," ") 
         Next
      Else   
         _nqtd := 1
         _cDescTipo := oVeiculo:_C_REBOQUES:_C_VEICULO:_C_MODELOVEICULAR:_D_DESCRICAO:TEXT
      EndIf 

		If _nqtd == 3   //3 placas é bi trem
			_ctipov := "3"
		Endif

		If _nqtd == 4   //4 placas é bi trem
			_ctipov := "5"
		Endif

		//===========================================================================
		// Gravação do cadastro de Veículos
		//==========================================================================
		M->DA3_FILIAL := xFilial("DA3")
		M->DA3_DESC   := oVeiculo:_C_MODELOVEICULAR:_D_DESCRICAO:TEXT //oVeiculo:_C_DESCRICAO:TEXT //U_VEICUL:DESC        // Descrição do veiculo
		M->DA3_I_TPVC := _ctipov // Tipo do veiculo
		M->DA3_RENAVA := oVeiculo:_C_RENAVAM:TEXT //oPlacas[1]:_C_RENAVAM:TEXT //U_VEICUL:RENAVAN1      // Renavan 1

		M->DA3_PLACA  := PadR(oVeiculo:_C_PLACA:TEXT,_nTamPlaca," ")  // PadR(U_VEICUL:PLACA2,_nTamPlaca," ")  // Placa do Veiculo
		M->DA3_MUNPLA := "" //U_VEICUL:MUNICI2     // Municipio da placa
      M->DA3_ESTPLA := "" //oPlacas[1]:_C_UF:TEXT //U_VEICUL:ESTADO      // Estado da placa

      M->DA3_I_PLCV := _cPlaca2 //PadR(oPlacas[1]:_C_PLACA:TEXT,_nTamPlaca," ") //PadR(U_VEICUL:PLACA1,_nTamPlaca," ")  // Placa do Veiculo
      M->DA3_I_MUCV := ""                   // Municipio da placa
		M->DA3_I_UFCV := oVeiculo:_C_UF:TEXT //U_VEICUL:ESTADO      // Estado da placa

		M->DA3_I_PLVG := _cPlaca3 // PadR(U_VEICUL:PLACA3,_nTamPlaca," ")  // Placa do Vagao 1
		M->DA3_I_MUVG := ""                   // Municipio da placa
		M->DA3_I_UFVG := oVeiculo:_C_UF:TEXT  //U_VEICUL:ESTADO        // UF Vagão

		M->DA3_I_PLV3 := _cPlaca4 // PadR(U_VEICUL:PLACA4,_nTamPlaca," ")  // Placa do Vagao 3
		M->DA3_I_MUV3 := "" //U_VEICUL:MUNICI4     // Municipio da placa
		M->DA3_I_UFV3 := oVeiculo:_C_UF:TEXT //U_VEICUL:ESTADO

		_lAlterar := .F.
		If M->DA3_I_TPVC == "1" // CARRETA
			If Empty(M->DA3_I_PLCV)
				_cMsg += " Foi informado o tipo de veículo Carreta, mas a placa do cavalo não está preenchida. "
			EndIf

			If Empty(M->DA3_PLACA)
				_cMsg += " Foi informado o tipo de veículo Carreta, mas a placa do semi-reboque não está preenchida. "
			EndIf

		ElseIf M->DA3_I_TPVC == "2" .Or. M->DA3_I_TPVC == "4" // CAMINHAO ou UTILITARIO
			If Empty(M->DA3_PLACA  )
				_cMsg += " Foi informado o tipo de veículo Caminhão ou Utilitário, mas a placa não foi informada. "
			EndIf

		ElseIf M->DA3_I_TPVC == "3" // BI-TREM
			If Empty(M->DA3_I_PLCV)
				_cMsg += " Foi informado o tipo de veículo Bi-Trem, mas a placa do cavalo não foi informada. "
			EndIf

			If Empty(M->DA3_PLACA)
				_cMsg += " Foi informado o tipo de veículo Bi-Trem, mas a placa do ultimo vagão não foi informado. "
			EndIf

			If Empty(M->DA3_I_PLVG)
				_cMsg += " Foi informado o tipo de veículo Bi-Trem, mas a placa do vagão do meio não foi informada. "
			EndIf

		ElseIf M->DA3_I_TPVC == "5" // RODO-TREM
			If Empty(M->DA3_I_PLCV)
				_cMsg += " Foi informado o tipo de veículo Rodo-Trem, mas a placa do cavalo não foi informada. "
			EndIf

			If Empty(M->DA3_PLACA)
				_cMsg += " Foi informado o tipo de veículo Rodo-Trem, mas a placa do ultimo vagão não foi informada. "
			EndIf

			If Empty(M->DA3_I_PLVG)
				_cMsg += " Foi informado o tipo de veículo Rodo-Trem, mas a placa do primeiro vagão do meio ou dolly não foi informada. "
			EndIf

		EndIf


		If !Empty(_cMsg)
			Break
		EndIf

		DA3->(DbOrderNickName("MOTORIVEIC"))
		_lAlterar := .F.
		If DA3->(DbSeek(xFilial("DA3")+M->DA4_COD+M->DA3_PLACA+M->DA3_I_PLCV+M->DA3_I_PLVG+M->DA3_I_PLV3))
			_lAlterar := .T.
		EndIf
     BEGIN TRANSACTION
		If _lAlterar
			DA3->(RecLock("DA3",.F.))
		Else
		    M->DA3_COD    := U_AOMS018(M->DA3_I_TPVC)
			DA3->(RecLock("DA3",.T.))
			DA3->DA3_ATIVO  := "1"
			DA3->DA3_FILIAL := M->DA3_FILIAL  // Filial do Sistema
			DA3->DA3_COD    := M->DA3_COD
		EndIf
		DA3->DA3_MOTORI := M->DA4_COD     // Motorista
		DA3->DA3_I_TPVC := M->DA3_I_TPVC  // Tipo do veiculo
		DA3->DA3_DESC   := M->DA3_DESC    // Descrição do veiculo
		DA3->DA3_ESTPLA := M->DA3_ESTPLA  // Estado da placa
		DA3->DA3_MUNPLA := M->DA3_MUNPLA  // Municipio da placa
		DA3->DA3_PLACA  := M->DA3_PLACA   // Placa do Veiculo
		DA3->DA3_RENAVA := M->DA3_RENAVA  // Renavan
		DA3->DA3_I_MUCV := M->DA3_I_MUCV  // Municipio da placa

		DA3->DA3_I_PLCV := M->DA3_I_PLCV  // Placa do Veiculo
		DA3->DA3_I_UFCV := M->DA3_I_UFCV  // UF Cavalo
		DA3->DA3_I_MUV3 := M->DA3_I_MUV3  // Municipio da placa
		DA3->DA3_I_PLV3 := M->DA3_I_PLV3  // Placa do Veiculo
		DA3->DA3_I_UFV3 := M->DA3_I_UFV3  // UF Vagão 3

		DA3->DA3_I_PLVG := M->DA3_I_PLVG  // Placa do Veiculo
		DA3->DA3_I_MUVG := M->DA3_I_MUVG  // Municipio da placa
		DA3->DA3_I_UFVG := M->DA3_I_UFVG  // UF Vagão

		DA3->(MsUnlock())
     END TRANSACTION

		If _lAlterar
		   _cMsgOk := _cMsgOk + "/ Alteração de Veiculo via RDC realizada com sucesso: " + oVeiculo:_C_PLACA:TEXT //U_VEICUL:PLACA1
		Else
		   _cMsgOk := _cMsgOk + "/ Inclusão de Veiculo via RDC realizada com sucesso: " + oVeiculo:_C_PLACA:TEXT //U_VEICUL:PLACA1
		EndIf

	End Sequence

	If Empty(_cMsg)
		_cStatus := "SUCESSO:TRUE; "+AllTrim(_cMsgOk) // "Tudo OK na filial " + cfilant
	Else
		_cStatus := "SUCESSO:FALSE; "+AllTrim(_cMsg) // _cMsg
	EndIf

 //===========================================================================================
 // Gravação das tabela de muro do cadastro de veículos e motoristas para posterior consulta
 //===========================================================================================
	ZFN->(RecLock("ZFN",.T.))
	ZFN->ZFN_FILIAL := xFilial("ZFN")	  // Filial do Sistema
	ZFN->ZFN_DATA   := Date()              // Data de Emissão
	ZFN->ZFN_HORA   := Time()
	ZFN->ZFN_TIPO   := oVeiculo:_C_MODELOVEICULAR:_D_TIPOMODELOVEICULAR:TEXT // U_VEICUL:TIPO       // Tipo do veiculo
	ZFN->ZFN_DESC   := oVeiculo:_C_MODELOVEICULAR:_D_DESCRICAO:TEXT //U_VEICUL:DESC       // Descrição do veiculo
	
   ZFN->ZFN_PLACA1 := oVeiculo:_C_PLACA:TEXT //U_VEICUL:PLACA1	   // Placa do Veiculo 1
	ZFN->ZFN_MUNIC1 := "" //U_VEICUL:MUNICI1	   // Municipio da placa 1
	ZFN->ZFN_PLACA2 := _cPlaca2 // U_VEICUL:PLACA2     // Placa do Veiculo 2
	ZFN->ZFN_MUNIC2 := "" //U_VEICUL:MUNICI2    // Municipio da placa 2
	ZFN->ZFN_PLACA3 := _cPlaca3 //U_VEICUL:PLACA3     // Placa do Veiculo 3
	ZFN->ZFN_MUNIC3 := "" //U_VEICUL:MUNICI3    // Municipio da placa 3
	ZFN->ZFN_PLACA4 := _cPlaca4 //U_VEICUL:PLACA4     // Placa do Veiculo 4
	ZFN->ZFN_MUNIC4 := "" //U_VEICUL:MUNICI4	   // Municipio da placa 4

	ZFN->ZFN_ESTADO := oVeiculo:_C_UF:TEXT //U_VEICUL:ESTADO     // Estado da placa
	ZFN->ZFN_NOMEM  := oMotorista:_C_NOME:TEXT //U_VEICUL:NOMEM      // Nome do motorista
	ZFN->ZFN_CPFM   := oMotorista:_C_CPF:TEXT //U_VEICUL:CPFM       // CPF do motorista
	ZFN->ZFN_CNPJT  := oMotorista:_C_TRANSPORTADOR:_D_CNPJ:TEXT  //U_VEICUL:CNPJT      // CNPJ Transportadora
	ZFN->ZFN_ENDERM := oMotorista:_C_ENDERECO:_D_LOGRADOURO:TEXT //U_VEICUL:ENDERECOM  // Endereco Motorista
	ZFN->ZFN_BAIRRM := oMotorista:_C_ENDERECO:_D_BAIRRO:TEXT //U_VEICUL:BAIRROM    // Bairro Motorista
	ZFN->ZFN_MUNICM := oMotorista:_C_ENDERECO:_D_CIDADE:TEXT //U_VEICUL:MUNICIPIOM // Municipio Motorista
	ZFN->ZFN_ESTADM := oMotorista:_C_ENDERECO:_D_ESTADO:TEXT //U_VEICUL:ESTADOM    // Estado do Motorista
	ZFN->ZFN_CEPM   := oMotorista:_C_ENDERECO:_D_CEP:TEXT //U_VEICUL:CEPM       // CEP do Motorista
	ZFN->ZFN_TELEFM := oMotorista:_C_ENDERECO:_D_TELEFONE:TEXT //U_VEICUL:TELEFONEM  // Telefone do Motorista
	ZFN->ZFN_CNHM   := oMotorista:_C_NUMEROHABILITACAO:TEXT //U_VEICUL:CNHM       // CNH do motorista
	ZFN->ZFN_EMICNH := Ctod(oMotorista:_C_DATAHABILITACAO:TEXT) //Ctod(U_VEICUL:EMICNH)     // Emissão da CNH
	ZFN->ZFN_VALCNH := Ctod(oMotorista:_C_DATAVENCIMENTOHABILITACAO:TEXT) //If(Empty(U_VEICUL:VALCNH),Ctod("  /  /  "),Ctod(U_VEICUL:VALCNH)) // Validade da CNH
	ZFN->ZFN_CATCNH := oMotorista:_C_CATEGORIACNH:TEXT //U_VEICUL:CATCNH     // Categoria CNH
	ZFN->ZFN_PAIM   := "" //U_VEICUL:PAIM       // Pai do Motorista
	ZFN->ZFN_MAEM   := "" //U_VEICUL:MAEM       // Mãe do Motorista
	ZFN->ZFN_RGM    := oMotorista:_C_RG:TEXT //U_VEICUL:RGM        // RG do Motorista
	ZFN->ZFN_TELREM := oMotorista:_C_ENDERECO:_D_TELEFONE2:TEXT //U_VEICUL:TELRECM    // Telefone recado Motorista
	ZFN->ZFN_USUARI := __CUSERID           // Codigo do Usuário
	ZFN->ZFN_DATAAL :=  Date()	            // Data de Alteração
	ZFN->ZFN_SITUAC := "P"                 // Situação do Registro
	ZFN->ZFN_CODEMP := _cCodEmpWS	         // Codigo Empresa WebServer
	ZFN->ZFN_RETORN := _cStatus	         // Retorno Integracao Italac-RDC
	ZFN->(MsUnlock())

Return _lRet

/*
===============================================================================================================================
Programa----------: AOMS085R   // AOMS085K
Autor-------------: Julio de Paula Paz
Data da Criacao---: 03/01/2024
===============================================================================================================================
Descrição---------: Rotina de Integração de carga webservice para o sistema TMS da Multi-Embarcador / Multsoftware.
                    Reescrenvo no Padrão de Integração REST, a função AOMS085K() escrita pelo analista Igor.
===============================================================================================================================
Parametros--------: oproc = Objeto de mensagens
                    _cOpc = N = Geração da Carga por dados da NFE Pendentes
					        P = Geração da Carga por Numero de Protocolo ou Numero de Carga
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS085R(oProc,_cOpc)  //  AOMS085K
Local _cDirXML := ""
Local _aPlaca := {}
Local _nI := 0
Local _nJ := 0
Local _aDados := {}

Local _aCargas := {}
Local _cEmpWebService //:= U_ITGETMV( 'IT_EMPTMSM' , "000005")
Local _cToken //:= U_ITGETMV( 'IT_TOKMUTE' , "a78e0523d3794843855e8d95c2bff8d4")

Private _cMsgResp := ""  // Armazena as respostas das integrações

Default _cOpc := "N"

Begin Sequence 

   _cEmpWebService := SUPERGETMV('IT_EMPTMSM',.F.,  "")  
   If Empty(_cEmpWebService)
      _cEmpWebService := U_ITGETMV( 'IT_EMPTMSM' , "000005")
   EndIf 

   _cToken := SUPERGETMV('IT_TOKMUTE',.F.,  "")
   If Empty(_cToken) 
      _cToken := U_ITGETMV( 'IT_TOKMUTE' , "a78e0523d3794843855e8d95c2bff8d4")
   EndIf 

   //=======================================================================================================
   // Força a abertura das tabelas. Algumas tabelas não estão sendo aberta automaticamente pelo Protheus.
   //=======================================================================================================
   ChkFile("SM0")
   ChkFile("DA4")
   ChkFile("DA3")
   ChkFile("ZFU")
   ChkFile("ZFV")
   ChkFile("ZFM")
   ChkFile("SC5")
   ChkFile("SC6")
   ChkFile("SA1")
   ChkFile("SA2")
   ChkFile("SB1")
   ChkFile("SB2")
   ChkFile("ZEL")

   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cEmpWebService))
      _cDirXML   := ZFM->ZFM_LOCXML 
      _cLinkNfe  := AllTrim(ZFM->ZFM_LINK03)  // Link NFE
	  _CLinkCarg := AllTrim(ZFM->ZFM_LINK04)  // Link Cargas

   Else
      If ! _lScheduler
	     MsgInfo("Código de Empresa WebService Não Cadastrado.","Atenção")   
	  EndIf 
	  Break 
   EndIf 

	If Empty(Alltrim(_cLinkNfe)) .OR. Empty(Alltrim(_CLinkCarg)) 
      If ! _lScheduler
         MsgInfo("Empresa WebService para envio dos dados não possui link cadastrado!.","Atenção")
      EndIf
      Break   
	EndIf 

    _cJSonEnv  := "{}" 
	_nTimOut   := 120
	_aHeadOut  := {}
	_cJSonRet  := Nil   
	_oRetJSon  := Nil 

    If _cOpc == "N"  // Faz a integração de carga com base nos dados das cargas pendentes de geração de nota fiscal.
	   Aadd(_aHeadOut,"Content-Type: application/json") 
	   Aadd(_aHeadOut,"Authorization: Bearer Token") 
	   Aadd(_aHeadOut,"Token: " + AllTrim(_cToken)) 
	
       //=======================================================================
       // Integra solicitando dados NFE
       //=======================================================================
       _cRetHttp := AllTrim( HttpPost( _cLinkNfe , '' , _cJSonEnv , _nTimOut , _aHeadOut , @_cJSonRet ) ) 
         
       If ! Empty(_cRetHttp)
          //varinfo("WebPage-http ret.", _cRetHttp)
          FWJSonDeserialize(DecodeUtf8(_cRetHttp),@_oRetJSon)             
	   Else 
	      _cMsgResp += "Não há dados para integração de cargas. "
	      Break 
       EndIf

	   If Type("_oRetJSon:OBJETO:ITENS") == "U"
		  _cMsgResp += "Não há dados para integração de cargas. "
	      Break 
	   EndIf 

       If Type("_oRetJSon:OBJETO:ITENS") == "A"
	      _aDadosCar := _oRetJSon:OBJETO:ITENS
	   Else 
          _aDadosCar := {}
	      Aadd(_aDadosCar, _oRetJSon:OBJETO:ITENS)
	   EndIf 
    
	   _aCargas := {} 
      
       For _nI := 1 to Len(_aDadosCar)
           _cProtIntCarg := _aDadosCar[_nI]:PROTOCOLOINTEGRACAOCARGA
		   If ValType(_cProtIntCarg) == "N"
              _cProtIntCarg := AllTrim(Str(_cProtIntCarg,16))
		   EndIf 

           If aScan(_aCargas,{|x| x == _cProtIntCarg}) = 0
              Aadd(_aCargas,_cProtIntCarg)
           EndIf
       Next
    Else 
       _aRet := U_AOMS085T()
	   If ! _aRet[1]
          Break 
	   EndIf 

       Aadd(_aCargas,_aRet[2])
	EndIf 
    //==============================================
    // Busca de Veiculos e Motoristas de cada carga
    //==============================================
    _cJSonEnv  := "{}" 
	_nTimOut   := 120
	_aHeadOut  := {}
	_cJSonRet  := Nil   
	_oRetJSon  := Nil 

	Aadd(_aHeadOut,"Content-Type: application/json") 
	Aadd(_aHeadOut,"Authorization: Bearer Token") 
	Aadd(_aHeadOut,"Token: " + AllTrim(_cToken)) 

   For _nI := 1 to Len(_aCargas)
       
	   //================================================================================
	   // Json com o protocolo de integração de carga para obtenção dos dados da carga.
	   //================================================================================
 	   _cJSonEnv  := '{'+'"protocoloIntegracaoCarga":'+ '"'+_aCargas[_nI] + '" }' 

	   //=======================================================================
       // Integra solicitando dados NFE
       //=======================================================================
	   _cJSonRet := Nil
       _cRetHttp := AllTrim( HttpPost( _CLinkCarg , '' , _cJSonEnv , _nTimOut , _aHeadOut , @_cJSonRet ) ) 
       _oRetJSon := Nil 

       If Empty(_cJSonRet) .Or. ! "200 OK" $ Upper(_cJSonRet)
	      If ! Empty(_cJSonRet)
	         _cResult2 := _cJSonRet
		  EndIf 
	         _cMsgResp += "Não foi encontrado carga para o protocolo de integração de carga: " + _aCargas[_nI]
	       Loop 
	    EndIf 

       If ! Empty(_cRetHttp)
          _oJSonCarga := JsonObject():new()
          
          _cRet := _oJSonCarga:FromJson(_cRetHttp)

          If _cRet <> NIL
			 _cMsgResp += "Não foi possível ler o JSon de Cargas retornado pelo TMS Multiembarcador. "
	          Loop 
          EndIf 

		  If ! _oJSonCarga["status"]
			 _cMsgResp += "Não foi possível ler o JSon de Cargas retornado pelo TMS Multiembarcador. "
	         Loop 
		  EndIf 

          _aNonesCar := _oJSonCarga:GetNames()
          
          _nJ := Ascan(_aNonesCar,"objeto") 
          If _nJ == 0
			 _cMsgResp += "Não há dados no JSon de Carga retornado pelo TMS Multiembarcador. "
	         Loop
          EndIf 

          _oJSonObj  := _oJSonCarga:GetJsonObject("objeto") // objeto

	   Else 
	      _cResult2 := _cJSonRet
		  _cMsgResp += "Não foi encontrado carga para o protocolo de integração de carga: " + _aCargas[_nI]
	      Loop
	   EndIf

      If ValType(_oJSonObj) == "A"
         _oCarga := _oJSonObj[1]
      Else 
         _oCarga := _oJSonObj
      EndIf 

      _aNomesCar := _oCarga:GetNames()

      _nJ := Ascan(_aNomesCar,"motoristas")
      If _nJ == 0
		 _cMsgResp += "Carga sem dados do motorista. "
	     Loop
      EndIf
      
      _oMotorista := _oCarga[_aNomesCar[_nJ]] 
      If Len(_oMotorista) == 0
		 _cMsgResp += "Carga sem dados do motorista. "
	     Loop
	  EndIf 

	  _nJ := Ascan(_aNomesCar,"veiculo")
      If _nJ == 0
		 _cMsgResp += "Carga sem dados do veículo. "
	     Loop
      EndIf

      _oVeiculo := _oCarga[_aNomesCar[_nJ]]
      If ValType(_oVeiculo) == "A" .And. Len(_oVeiculo) == 0
		 _cMsgResp += "Carga sem dados do veículo. "
	     Loop
	  EndIf

      _nJ := Ascan(_aNomesCar,"veiculoDaNota")
      If _nJ == 0
		 _cMsgResp += "Carga sem dados do veículo da nota. "
	      Loop
      EndIf

      _oPlaca := _oCarga[_aNomesCar[_nJ]]

      If ValType(_oPlaca) == "A"
         _aPlaca := {}
         For _nJ := 1 To Len(_oPlaca)
             Aadd(_aPlaca, _oPlaca[_nJ])
         Next
      Else
         _aPlaca := {_oPlaca}
      EndIf
            
      Aadd(_aDados,{_oMotorista,_oVeiculo,_aPlaca,_oJSonObj})
   Next

   For _nI := 1 To Len(_aDados)
       _RetMotor := {.F.,""}
       
	  // If ValType() == "A"
	   
	   _jDadosMot := _aDados[_nI,1]
	   If ValType(_jDadosMot) == "A"
          _jDadosMot := _jDadosMot[1]  
	   EndIf 

	   _jDadosVei := _aDados[_nI,2]
       If ValType(_jDadosVei) == "A"
          _jDadosVei := _jDadosVei[1] 
       EndIf 
       
	   //======================================================================================
	   // Faz a integração de Veículos e Motoristas. Inclui Veiculos e Motoristas no Protheus.
	   //======================================================================================
	   _RetMotor := U_AOMS085M(_jDadosMot,_jDadosVei,_aDados[_nI,3],_aDados[_nI,4]) // Cadastra/Atualiza Veiculos e Motoristas no Protheus
       
	   //==========================================================================
	   // Faz a integração de Cargas. Cria as cargas no Protheus.
	   //==========================================================================
	   U_AOMS085C(_jDadosMot,_jDadosVei,_aDados[_nI,3],_aDados[_nI,4],_RetMotor[1],_RetMotor[2]) // Gera a Carga no Protheus
       
   Next

End Sequence 

_cMsgResp += " - Termino da rotina de integração de cargas."

If ! Empty(_cMsgResp)
   U_Itmsg(_cMsgResp,"Atenção",,2)
EndIf 


Return Nil

/*
===============================================================================================================================
Programa----------: AOMS085M   // AOMS085J
Autor-------------: Julio de Paula Paz
Data da Criacao---: 03/01/2024
===============================================================================================================================
Descrição---------: Integra dados dos Motorista e Veiculos
                    Reescrenvo no Padrão de Integração REST, a função AOMS085J() escrita pelo analista Igor.
===============================================================================================================================
Parametros--------: oMotorista,oVeiculo,oPlacas,_oCarga
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS085M(_oMotorista,_oVeiculo,_oPlacas,_oCarga) // AOMS085J
//Local _nTamForn   := TAMSX3("A2_COD")[1]
//Local _nTamLojaF  := TAMSX3("A2_LOJA")[1]
Local _lRet       := .T.
Local _lAlterar
Local _cCodEmpWS //:= U_ITGETMV( 'IT_EMPWEBSE' , '000001' )
Local _cMsg, _cMsgOk
Local _cQry
Local _cCod_T, _cLoja_T
Local _aPlaca := {}
Local _cPlaca1, _cPlaca2, _cPlaca3 , _cPlaca4, _cPlaca5
Local _nI := 0 
//Local _oMotorista,_oVeiculo

Local _lTemTransp

Private lMsErroAuto := .F.
Private lMsHelpAuto := .F.
lMsHelpAuto := .F.

Begin Sequence
   
   _cCodEmpWS := SUPERGETMV('IT_EMPWEBSE',.F.,  "")
   If Empty(_cCodEmpWS)
      _cCodEmpWS := U_ITGETMV( 'IT_EMPWEBSE' , '000001' )
   EndIf 

   //_oMotorista := _oDadosMot[1]
   //_oVeiculo   := _oDadosVei[1]

   _cMsg      := ""
   _cMsgOk    := ""

   _ctipov    := ""
   _cDescTipo := ""
   _cCodTipoV := ""
   _cPlaca1   := ""       
   _cPlaca2   := ""
   _cPlaca3   := ""
   _cPlaca4   := ""
   _cPlaca5   := ""

   //=======================================================
   // Dados da carga
   //=======================================================
   _oDadosCapa := _oCarga[1]
   _aNamesCapa := _oCarga[1]:GetNames()
   _ctipov     := ""
   _cDescTipo  := ""

   _oModeloV   := _oDadosCapa["modeloVeicular"]

   If ValType(_oModeloV['codigoIntegracao']) <> "U"
      _cCodTipoV := _oModeloV['codigoIntegracao']
   EndIf 

   If ValType(_oModeloV['descricao']) <> "U"
      _cDescTipo := _oModeloV['descricao']
   EndIf 

   //===========================================================================
   // Gravação do cadastro de  motorisata
   //==========================================================================
   M->DA4_FILIAL  := xFilial("DA4")
   M->DA4_COD     := GETSXENUM("DA4","DA4_COD")

   _oEnderMot := _oMotorista["endereco"]

   If Type("_oEnderMot['bairro']") <> "U" // "_oMotorista:ENDERECO:BAIRRO"
      M->DA4_BAIRRO  := U_ITKEY(_oEnderMot['bairro'],"DA4_BAIRRO")                 // _oMotorista:_C_ENDERECO:_D_BAIRRO:TEXT //U_VEICUL:BAIRROM    // Bairro Motorista
   EndIf 

   If ValType(_oMotorista['categoriaCNH']) <> "U"
      M->DA4_CATCNH  := U_ITKEY(_oMotorista['categoriaCNH'],"DA4_CATCNH")                    // _oMotorista:_C_CATEGORIACNH:TEXT // U_VEICUL:CATCNH     // Categoria CNH do motorista
   EndIf 

   If Type("_oEnderMot['cep']") <> "U"
      M->DA4_CEP     := U_ITKEY(_oEnderMot['cep'],"DA4_CEP")                       // _oMotorista:_C_ENDERECO:_D_CEP:TEXT //U_VEICUL:CEPM       // CEP do Motorista
   EndIf 

   If ValType(_oMotorista['numeroHabilitacao']) <> "U"
      M->DA4_NUMCNH  := U_ITKEY(_oMotorista['numeroHabilitacao'],"DA4_NUMCNH")               // _oMotorista:_C_NUMEROHABILITACAO:TEXT //U_VEICUL:CNHM       // CNH do motorista
   EndIf 

   If ValType(_oMotorista['cpf']) <> "U"		
      M->DA4_CGC     := U_ITKEY(_oMotorista['cpf'],"DA4_CGC")                                // Padr(_oMotorista:_C_CPF:TEXT,_nTamCPF," ")// Padr(U_VEICUL:CPFM ,_nTamCPF," ")      // CPF do motorista
   EndIf 

   If ValType(_oMotorista['dataHabilitacao']) <> "U"
      M->DA4_DTECNH  := Ctod(AllTrim(_oMotorista['dataHabilitacao']))                        // _C_DATAHABILITACAO:TEXT) //Ctod(U_VEICUL:EMICNH)     // Emissão da CNH
   EndIf 

   If Type("_oEnderMot['logradouro']") <> "U"
      M->DA4_END     := U_ITKEY(_oEnderMot['logradouro'],"DA4_END")                // _oMotorista:_C_ENDERECO:_D_LOGRADOURO:TEXT // U_VEICUL:ENDERECOM  // Endereco Motorista
   EndIf

   If Type("_oEnderMot['uf']") <> "U"
      M->DA4_EST     := U_ITKEY(_oEnderMot['uf'],"DA4_EST")                    // _oMotorista:_C_ENDERECO:_D_ESTADO:TEXT //U_VEICUL:ESTADOM    // Estado do Motorista
   EndIf 

   M->DA4_MAE     := ""                                                                // U_VEICUL:MAEM       // Mãe do Motorista

   If Type("_oEnderMot['cidade']") <> "U"
      M->DA4_MUN     := U_ITKEY(_oEnderMot['cidade'],"DA4_MUN")                    // _oMotorista:_C_ENDERECO:_D_CIDADE:TEXT //U_VEICUL:MUNICIPIOM // Municipio Motorista
   EndIf 

   If ValType(_oMotorista['nome']) <> "U"
      M->DA4_NOME    := U_ITKEY(_oMotorista['nome'],"DA4_NOME")                    // _oMotorista:_C_NOME:TEXT //U_VEICUL:NOMEM      // Nome do motorista
   EndIf 

   If ValType(_oMotorista['nome']) <> "U"
      M->DA4_NREDUZ  := SubStr(U_ITKEY(_oMotorista['nome'],"DA4_NOME"),1,20)                 // SubStr(_oMotorista:_C_NOME:TEXT,1,_nTamNReduz)      // Nome do motorista
   EndIf 

   M->DA4_PAI     := ""         
                                                          // U_VEICUL:PAIM       // Pai do Motorista
   If ValType(_oMotorista['rg']) <> "U"
      M->DA4_RG      := U_ITKEY(_oMotorista['rg'],"DA4_RG")                                  // _oMotorista:_C_RG:TEXT  //U_VEICUL:RGM        // RG do Motorista
   EndIf 

   If Type("_oEnderMot['telefone']") <> "U"
      M->DA4_TEL     := U_ITKEY(_oEnderMot['telefone'],"DA4_TEL")                  // _oMotorista:_C_ENDERECO:_D_TELEFONE:TEXT  // U_VEICUL:TELEFONEM  // Telefone do Motorista
   EndIf 

   If Type("_oEnderMot['telefone2']") <> "U"
      M->DA4_TELREC  := U_ITKEY(_oEnderMot['telefone2'],"DA4_TELREC")              // _oMotorista:_C_ENDERECO:_D_TELEFONE2:TEXT  // U_VEICUL:TELRECM    // Telefone recado Motorista
   EndIf 

   If ValType(_oMotorista['dataVencimentoHabilitacao']) <> "U"
      M->DA4_DTVCNH  := Ctod(AllTrim(_oMotorista['dataVencimentoHabilitacao'])) // ctod(_oMotorista:_C_DATAVENCIMENTOHABILITACAO:TEXT) // If(Empty(U_VEICUL:VALCNH),Ctod("  /  /  "),Ctod(U_VEICUL:VALCNH))     // Validade da CNH
   EndIf 

   SA2->(DbSetOrder(3)) //A2_FILIAL+A2_CGC
   M->DA4_FORNEC := ""
   M->DA4_LOJA    := ""
   _cCod_T  := ""
   _cLoja_T := ""
   _lTemTransp := .F.
   _cCnpjTrans := ""
   
   //==============================================
   // Obtendo dados da Transportadora
   //==============================================
   //_oTransport := _oMotorista["transportador"]   
   //_cCnpjTrans := _oTransport["cnpj"]
//-----------------------------------------------------------------------------------------
   If Valtype(_oCarga) == "A"
      _oTranspEm := _oCarga[1]
   Else 
      _oTranspEm := _oCarga
   EndIf

   _aNamesTrans := _oTranspEm:GetNames() 
   _nI :=  Ascan(_aNamesTrans, "transportadoraEmitente")

   If _nI > 0 
      _oTranport  := _oTranspEm["transportadoraEmitente"] 
      _cCnpjTrans := _oTranport["cnpj"]
   EndIf 
//-----------------------------------------------------------------------------------------
   If !Empty(_cCnpjTrans) .And. SA2->(DbSeek(xFilial("SA2")+U_ITKEY(_cCnpjTrans,"A2_CGC")))   //SA2->(DbSeek(xFilial("SA2")+U_ITKEY(_oMotorista['cpf'],"DA4_CGC")))  
	  Do while ! SA2->(Eof()) .And. SA2->(A2_FILIAL+A2_CGC) == xFilial("SA2")+ U_ITKEY(_cCnpjTrans,"A2_CGC") // U_ITKEY(_oMotorista['cpf'],"DA4_CGC")
	     If SA2->A2_I_CLASS $ "T/A"
		    M->DA4_FORNEC := SA2->A2_COD
		    M->DA4_LOJA   := SA2->A2_LOJA
		    If SA2->A2_I_CLASS == "T"
		       _cCod_T  := SA2->A2_COD
			   _cLoja_T := SA2->A2_LOJA
		    EndIf
		    _lTemTransp := .T.
		 EndIf
		 SA2->(DbSkip())
	  EndDo
   EndIf

   If !_lTemTransp // Não há transportadora cadastrada
	  _cMsg := "Não há transportadora cadastrada para o motorista: " + M->DA4_NOME
	  RollbackSx8() //Libera código de motorista que foi pedido
	  Break
   EndIf

   //=====================================================================
   // Há transportadora cadastrada. Então atualiza cadastro de motoristas.
   //=====================================================================
   If !Empty(_cCod_T)
      M->DA4_FORNEC := _cCod_T
      M->DA4_LOJA   := _cLoja_T
   EndIf

   _cQry := " SELECT DA4.R_E_C_N_O_ AS NRECNO FROM " + RetSqlName("DA4") + " DA4 "
   _cQry += " WHERE DA4.D_E_L_E_T_ <> '*' AND DA4_CGC = '" + M->DA4_CGC + "' AND DA4_FORNEC = '"+M->DA4_FORNEC+"' AND DA4_LOJA = '"+M->DA4_LOJA+"' "

   If Select("QRYDA4") > 0
	  QRYDA4->(DbCloseArea())
   EndIf

   _cQry := ChangeQuery(_cQry)
   //DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry), "QRYDA4", .F., .T.)
   MPSysOpenQuery( _cQry , "QRYDA4")
   DBSelectArea("QRYDA4")

   _lAlterar := .F.
   If ! QRYDA4->(Eof()) .And. !QRYDA4->(Bof())
	  _lAlterar := .T.

	  DA4->(DbGoTo(QRYDA4->NRECNO))
	  M->DA4_COD := DA4->DA4_COD   // Na alteração, atualiza variavel de memoria como o código do Motorista para gravação no veículo.
      RollbackSx8() //Libera código de motorista que foi pedido
   EndIf

   If _lAlterar
      Do While ! QRYDA4->(Eof())
	     DA4->(DbGoTo(QRYDA4->NRECNO))

		 DA4->(RecLock("DA4",.F.))
		 DA4->DA4_BAIRRO :=  M->DA4_BAIRRO      // Bairro Motorista
		 DA4->DA4_MUNCNH :=  M->DA4_MUNCNH      // CNH do motorista
		 DA4->DA4_EST    :=  M->DA4_EST         // Estado do Motorista
		 DA4->DA4_CEP    :=  M->DA4_CEP         // CEP do Motorista
	     DA4->DA4_NUMCNH :=  M->DA4_NUMCNH      // CNH do motorista
		 DA4->DA4_LOJA   :=  M->DA4_LOJA        // Loja Fornecedor
		 DA4->DA4_FORNEC :=  M->DA4_FORNEC      // Fornecedor
		 DA4->DA4_LOJA   :=  M->DA4_LOJA        // Loja Fornecedor
		 DA4->DA4_CGC    :=  M->DA4_CGC         // CPF do motorista
		 DA4->DA4_DTECNH :=  M->DA4_DTECNH      // Emissão da CNH
		 DA4->DA4_END    :=  M->DA4_END         // Endereco Motorista
		 DA4->DA4_MAE    :=  M->DA4_MAE         // Mãe do Motorista
		 DA4->DA4_MUN    :=  M->DA4_MUN         // Municipio Motorista
		 DA4->DA4_NOME   :=  M->DA4_NOME        // Nome do motorista
		 DA4->DA4_NREDUZ :=  M->DA4_NREDUZ      // Nome do motorista
		 DA4->DA4_PAI    :=  M->DA4_PAI         // Pai do Motorista
		 DA4->DA4_RG     :=  M->DA4_RG          // RG do Motorista
		 DA4->DA4_TEL    :=  M->DA4_TEL         // Telefone do Motorista
		 DA4->DA4_TELREC :=  M->DA4_TELREC      // Telefone recado Motorista
		 DA4->DA4_DTVCNH :=  M->DA4_DTVCNH      // Validade da CNH
		 DA4->DA4_CATCNH :=  M->DA4_CATCNH      // Categoria CNH
		 DA4->(MsUnlock())

		 QRYDA4->(DbSkip())
	  EndDo
   EndIf

   If Select("QRYDA4") > 0
	  QRYDA4->(DbCloseArea())
   EndIf

   If ! _lAlterar
	  //===================================================================
      // Verifica se o código do motorista já existe na tabela DA4.
	  // Se existir gera um novo código.
	  //===================================================================
	  DA4->(DbSetOrder(1)) // DA4_FILIAL+DA4_COD
      If DA4->(DbSeek(xFilial("DA4")+M->DA4_COD))
		 _cQry := " SELECT Max(DA4.DA4_COD) AS CODMOTOR FROM " + RetSqlName("DA4") + " DA4 "
		 _cQry += " WHERE DA4.D_E_L_E_T_ <> '*' "

		 If Select("QRYDA4") > 0
		 	QRYDA4->(DbCloseArea())
		 EndIf

         _cQry := ChangeQuery(_cQry)
		 //DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry), "QRYDA4", .F., .T.)
		 MPSysOpenQuery( _cQry , "QRYDA4")
         DBSelectArea("QRYDA4")

		 If ! QRYDA4->(Eof()) .And. !QRYDA4->(Bof())
			M->DA4_COD := StrZero(Val(QRYDA4->CODMOTOR) + 1,6)
		 EndIf

		 If Select("QRYDA4") > 0
			QRYDA4->(DbCloseArea())
		 EndIf

	  EndIf

	  //===================================================================
	  // Faz a inclusão do novo motorista.
	  //===================================================================
	  DA4->(RecLock("DA4",.T.))
	  DA4->DA4_FILIAL  := M->DA4_FILIAL
	  DA4->DA4_COD     := M->DA4_COD
	  DA4->DA4_BAIRRO :=  M->DA4_BAIRRO      // Bairro Motorista
	  DA4->DA4_MUNCNH :=  M->DA4_MUNCNH      // CNH do motorista
	  DA4->DA4_EST    :=  M->DA4_EST         // Estado do Motorista
	  DA4->DA4_CEP    :=  M->DA4_CEP         // CEP do Motorista
	  DA4->DA4_NUMCNH :=  M->DA4_NUMCNH      // CNH do motorista
	  DA4->DA4_LOJA   :=  M->DA4_LOJA        // Loja Fornecedor
	  DA4->DA4_FORNEC :=  M->DA4_FORNEC      // Fornecedor
	  DA4->DA4_LOJA   :=  M->DA4_LOJA        // Loja Fornecedor
	  DA4->DA4_CGC    :=  M->DA4_CGC         // CPF do motorista
	  DA4->DA4_DTECNH :=  M->DA4_DTECNH      // Emissão da CNH
	  DA4->DA4_END    :=  M->DA4_END         // Endereco Motorista
	  DA4->DA4_MAE    :=  M->DA4_MAE         // Mãe do Motorista
	  DA4->DA4_MUN    :=  M->DA4_MUN         // Municipio Motorista
	  DA4->DA4_NOME   :=  M->DA4_NOME        // Nome do motorista
	  DA4->DA4_NREDUZ :=  M->DA4_NREDUZ      // Nome do motorista
	  DA4->DA4_PAI    :=  M->DA4_PAI         // Pai do Motorista
	  DA4->DA4_RG     :=  M->DA4_RG          // RG do Motorista
	  DA4->DA4_TEL    :=  M->DA4_TEL         // Telefone do Motorista
	  DA4->DA4_TELREC :=  M->DA4_TELREC      // Telefone recado Motorista
	  DA4->DA4_DTVCNH :=  M->DA4_DTVCNH      // Validade da CNH
	  DA4->(MsUnlock())
	  ConfirmSx8() //Confirma novo código de motorista
   EndIf

   If _lAlterar
	  _cMsgOk := _cMsgOk +  " Alteração do motorista via TMS Multiembarcador realizada com sucesso: " + AllTrim(M->DA4_NOME) 
   Else
	  _cMsgOk := _cMsgOk + " Inclusão de motorista via TMS Multiembarcador realizada com sucesso: " + AllTrim(M->DA4_NOME) 
   EndIf

   _ctipov := "2" // Caminhão
   _nqtd := 0

   //===========================================================================
   // Se recebeu 3 ou mais placas força tipo de veiculo para rodo ou bi trem
   //==========================================================================

   _cPlaca1 := ""       
   _cPlaca2 := ""
   _cPlaca3 := ""
   _cPlaca4 := ""
   _cPlaca5 := ""
      
   _aPlaca := {}
   _cPlacaC := "" //_oItemReboq["placa"]
   _cPlacaReb := "" 
   If ValType(_oVeiculo["reboques"]) == "A" .And. Len(_oVeiculo["reboques"]) > 0
      //_nQtdReboq := Len(_oVeiculo["reboques"])
	  _oReboques := _oVeiculo["reboques"]
	  _oItemReboq := _oReboques[1]
	  _oModeloV   := _oItemReboq["modeloVeicular"]

	  //If ValType(_oModeloV['codigoIntegracao']) <> "U"
      //   _cCodTipoV := _oModeloV['codigoIntegracao']
	  //EndIf 
	  //If ValType(_oModeloV['tipoModeloVeicular']) <> "U"
      //   _cCodTipoV := _oModeloV['tipoModeloVeicular']
	  //EndIf 

      //If ValType(_oModeloV['descricao']) <> "U"
      //   _cDescTipo := _oModeloV['descricao']
	  //EndIf 

	  If ValType(_oVeiculo["placa"]) <> "U"
         _cPlacaReb := _oVeiculo["placa"]
	  EndIf
   Else 
      //_oReboques := _oVeiculo["reboques"]
	  //_oItemReboq := _oReboques[1]
	  //_oModeloV   := _oItemReboq["modeloVeicular"]
	  _oModeloV := _oVeiculo["modeloVeicular"]

	  //If ValType(_oModeloV['tipoModeloVeicular']) <> "U"
      //   _cCodTipoV := _oModeloV['tipoModeloVeicular']
	  //EndIf 

      //If ValType(_oModeloV['descricao']) <> "U"
      //   _cDescTipo := _oModeloV['descricao']
	  //EndIf 

	  If ValType(_oVeiculo["placa"]) <> "U"
         _cPlacaReb := _oVeiculo["placa"]
	  EndIf
   EndIf  
   
  // If ! Empty(_cPlacaC)
  //    Aadd(_aPlaca, _cPlacaC)
  // EndIf 

   If ValType(_oVeiculo["reboques"]) == "A" .And. Len(_oVeiculo["reboques"]) > 0
      For _nI := 1 To Len(_oPlacas)
          _oItemPlaca := _oPlacas[_nI]
	   
	      _cPlacaC := ""
	      _cPlacaC := _oItemPlaca["placa"] 
       
	      If ! Empty(_cPlacaC) .And. Ascan(_aPlaca,_cPlacaC) == 0
             Aadd(_aPlaca, _cPlacaC)
          EndIf 
      Next 
   EndIf 

   If Len(_aPlaca) > 0  // não ordenar a placa do cavalo/Placa principal.
      ASort(_aPlaca) 

      _aPlacaOrd := AClone(_aPlaca) 
      _aPlaca    := {}
      
	  Aadd(_aPlaca, _cPlacaReb)

      For _nI := 1 To Len(_aPlacaOrd)
          Aadd(_aPlaca, _aPlacaOrd[_nI])
	  Next 
   Else 
	  _aPlaca    := {}
      Aadd(_aPlaca, _cPlacaReb)
   EndIf 
   
   For _nI := 1 To Len(_aPlaca)
       &("_cPlaca"+Alltrim(Str(_nI,1))) := U_ItKey(_aPlaca[_nI],"DA3_PLACA") 
   Next
   
   _nqtd := Len(_aPlaca)

   If _nqtd == 2   // 2 placas é carreta
	  _cTipoV := "1"
   Endif

   If _nqtd == 3   // 3 placas é bi trem
	  _ctipov := "3"
   EndIf

   If _nqtd == 4   //4 placas é rodo trem
	  _ctipov := "5"
   Endif

   If _nQtd == 1  // Caminhão ou Utilitario 
	  If "CAMINH" $ Upper(_cDescTipo) // Caminhão
         _ctipov := "2" 
	  EndIf

      If "UTIL" $ Upper(_cDescTipo) .Or. "VAN" $ Upper(_cDescTipo) // Utilitario
         _ctipov := "4" 
      EndIf
   EndIf 

   //===========================================================================
   // Gravação do cadastro de Veículos
   //==========================================================================
   M->DA3_FILIAL := xFilial("DA3")
   M->DA3_DESC   := _cDescTipo        // _oVeiculo:MODELOVEICULAR:DESCRICAO // _oVeiculo:_C_MODELOVEICULAR:_D_DESCRICAO:TEXT //_oVeiculo:_C_DESCRICAO:TEXT //U_VEICUL:DESC        // Descrição do veiculo
   M->DA3_I_TPVC := _ctipov           // Tipo do veiculo
   If ! Empty(_cCodTipoV)
      If ValType(_cCodTipoV) == "N"
         _cCodTipoV := AllTrim(Str(_cCodTipoV,10)) 
	  EndIf 
      M->DA3_I_CODV := _cCodTipoV        // Código do Tipo de Veiculo do TMS.
   Else 
      M->DA3_I_CODV := ""
   EndIf 
   
   If Type("_oVeiculo['renavam']") <> "U"
      M->DA3_RENAVA := _oVeiculo['renavam']  // _oVeiculo:_C_RENAVAM:TEXT //_oPlacas[1]:_C_RENAVAM:TEXT //U_VEICUL:RENAVAN1      // Renavan 1
   EndIf 

   M->DA3_MUNPLA := ""                // U_VEICUL:MUNICI2     // Municipio da placa
   If Type("_oVeiculo['uf']") <> "U"
      M->DA3_ESTPLA := _oVeiculo['uf']     // _oPlacas[1]:_C_UF:TEXT //U_VEICUL:ESTADO      // Estado da placa
   EndIf 

   M->DA3_I_MUCV := ""                   // Municipio da placa

   If Type("_oVeiculo['uf']") <> "U"
      M->DA3_I_UFCV := _oVeiculo['uf'] //_oVeiculo:_C_UF:TEXT //U_VEICUL:ESTADO      // Estado da placa
   EndIf

   If _cTipoV == "1" .Or. _ctipov == "3"  .Or.  _ctipov == "5" // 1=2 placas é carreta // 3=3 placas é bi trem // 5=4 placas é rodo trem
	  M->DA3_PLACA  := _cPlaca2          // Placa secundária fica no campo padrão da Totvs.
      M->DA3_I_PLCV := _cPlaca1            // Placa principal é a do Cavalo
   Else // Para os demais tipos de veículos, a placa principal é o campo padrão da Totvs. 
      M->DA3_PLACA  := _cPlaca1          // PadR(_oVeiculo:_C_PLACA:TEXT,_nTamPlaca," ")  // PadR(U_VEICUL:PLACA2,_nTamPlaca," ")  // Placa do Veiculo
      M->DA3_I_PLCV := _cPlaca2          // PadR(_oPlacas[1]:_C_PLACA:TEXT,_nTamPlaca," ") //PadR(U_VEICUL:PLACA1,_nTamPlaca," ")  // Placa do Veiculo
   EndIf 

   M->DA3_I_PLVG := _cPlaca3 // PadR(U_VEICUL:PLACA3,_nTamPlaca," ")  // Placa do Vagao 1
   M->DA3_I_MUVG := ""                   // Municipio da placa
   If Type("_oVeiculo['uf']") <> "U"
      M->DA3_I_UFVG := _oVeiculo['uf'] // _oVeiculo:_C_UF:TEXT  //U_VEICUL:ESTADO        // UF Vagão
   EndIf 

   M->DA3_I_PLV3 := _cPlaca4 // PadR(U_VEICUL:PLACA4,_nTamPlaca," ")  // Placa do Vagao 3
   M->DA3_I_MUV3 := "" //U_VEICUL:MUNICI4     // Municipio da placa
   
   If Type("_oVeiculo['uf']") <> "U"
      M->DA3_I_UFV3 :=  _oVeiculo['uf'] //_oVeiculo:_C_UF:TEXT //U_VEICUL:ESTADO
   EndIf 

   _lAlterar := .F.
      
   If M->DA3_I_TPVC == "1" // CARRETA
	  If Empty(M->DA3_I_PLCV)
	     _cMsg += " Foi informado o tipo de veículo Carreta, mas a placa do cavalo não está preenchida. "
	  EndIf

      If Empty(M->DA3_PLACA)
		 _cMsg += " Foi informado o tipo de veículo Carreta, mas a placa do semi-reboque não está preenchida. "
	  EndIf

   ElseIf M->DA3_I_TPVC == "2" .Or. M->DA3_I_TPVC == "4" // CAMINHAO ou UTILITARIO
      If Empty(M->DA3_PLACA  )
		 _cMsg += " Foi informado o tipo de veículo Caminhão ou Utilitário, mas a placa não foi informada. "
      EndIf

   ElseIf M->DA3_I_TPVC == "3" // BI-TREM
	  If Empty(M->DA3_I_PLCV)
	     _cMsg += " Foi informado o tipo de veículo Bi-Trem, mas a placa do cavalo não foi informada. "
      EndIf

      If Empty(M->DA3_PLACA)
	     _cMsg += " Foi informado o tipo de veículo Bi-Trem, mas a placa do ultimo vagão não foi informado. "
	  EndIf

      If Empty(M->DA3_I_PLVG)
	     _cMsg += " Foi informado o tipo de veículo Bi-Trem, mas a placa do vagão do meio não foi informada. "
	  EndIf

   ElseIf M->DA3_I_TPVC == "5" // RODO-TREM
	  If Empty(M->DA3_I_PLCV) 
	 	 _cMsg += " Foi informado o tipo de veículo Rodo-Trem, mas a placa do cavalo não foi informada. "
	  EndIf

      If Empty(M->DA3_PLACA)
	     _cMsg += " Foi informado o tipo de veículo Rodo-Trem, mas a placa do ultimo vagão não foi informada. "
      EndIf

      If Empty(M->DA3_I_PLVG)
         _cMsg += " Foi informado o tipo de veículo Rodo-Trem, mas a placa do primeiro vagão do meio ou dolly não foi informada. "
	  EndIf
   EndIf

   If !Empty(_cMsg)
	  Break
   EndIf

   DA3->(DbOrderNickName("MOTORIVEIC"))
   _lAlterar := .F.
   If DA3->(DbSeek(xFilial("DA3")+M->DA4_COD+M->DA3_PLACA+M->DA3_I_PLCV+M->DA3_I_PLVG+M->DA3_I_PLV3))
	  _lAlterar := .T.
   EndIf
 
 BEGIN TRANSACTION
   If _lAlterar
	  DA3->(RecLock("DA3",.F.))
   Else
	  M->DA3_COD:= U_AOMS018(M->DA3_I_TPVC)
      DA3->(RecLock("DA3",.T.))
      DA3->DA3_ATIVO  := "1"
	  DA3->DA3_FILIAL := M->DA3_FILIAL  // Filial do Sistema
	  DA3->DA3_COD    := M->DA3_COD
   EndIf
   DA3->DA3_MOTORI := M->DA4_COD     // Motorista
   DA3->DA3_I_TPVC := M->DA3_I_TPVC  // Tipo do veiculo
   DA3->DA3_DESC   := M->DA3_DESC    // Descrição do veiculo
   
   If ! Empty(M->DA3_I_CODV)
      DA3->DA3_I_CODV := M->DA3_I_CODV  // Código do Tipo de Veiculo do TMS.
   EndIf

   DA3->DA3_ESTPLA := M->DA3_ESTPLA  // Estado da placa 
   DA3->DA3_MUNPLA := M->DA3_MUNPLA  // Municipio da placa
   DA3->DA3_PLACA  := M->DA3_PLACA   // Placa do Veiculo
   DA3->DA3_RENAVA := M->DA3_RENAVA  // Renavan
   DA3->DA3_I_MUCV := M->DA3_I_MUCV  // Municipio da placa

   DA3->DA3_I_PLCV := M->DA3_I_PLCV  // Placa do Veiculo
   DA3->DA3_I_UFCV := M->DA3_I_UFCV  // UF Cavalo
   DA3->DA3_I_MUV3 := M->DA3_I_MUV3  // Municipio da placa
   DA3->DA3_I_PLV3 := M->DA3_I_PLV3  // Placa do Veiculo
   DA3->DA3_I_UFV3 := M->DA3_I_UFV3  // UF Vagão 3

   DA3->DA3_I_PLVG := M->DA3_I_PLVG  // Placa do Veiculo
   DA3->DA3_I_MUVG := M->DA3_I_MUVG  // Municipio da placa
   DA3->DA3_I_UFVG := M->DA3_I_UFVG  // UF Vagão

   DA3->(MsUnlock())
END TRANSACTION
 
   If _lAlterar
	   _cMsgOk := _cMsgOk + "/ Alteração de Veiculo via RDC realizada com sucesso: " + _cPlaca1
   Else
      _cMsgOk := _cMsgOk + "/ Inclusão de Veiculo via RDC realizada com sucesso: " + _cPlaca1
   EndIf

End Sequence

If ! Empty(_cMsg)
   _cStatus := _cMsg
   _lRet := .F.
Else 
   _cStatus := _cMsgOk 
   _lRet := .T.
EndIf 

//===========================================================================================
// Gravação das tabela de muro do cadastro de veículos e motoristas para posterior consulta
//===========================================================================================
ZFN->(RecLock("ZFN",.T.))
ZFN->ZFN_FILIAL := xFilial("ZFN")	  // Filial do Sistema
ZFN->ZFN_DATA   := Date()              // Data de Emissão
ZFN->ZFN_HORA   := Time()
ZFN->ZFN_TIPO   := _ctipov //DA3_I_TPVC; 1=Carreta,2=Caminhão,3=BI TREM,4=UTILITARIO,5=RODOTREM // _oVeiculo:_C_MODELOVEICULAR:_D_TIPOMODELOVEICULAR:TEXT // U_VEICUL:TIPO       // Tipo do veiculo
ZFN->ZFN_DESC   := _cDescTipo  // _oVeiculo:MODELOVEICULAR:DESCRICAO  // _oVeiculo:_C_MODELOVEICULAR:_D_DESCRICAO:TEXT //U_VEICUL:DESC       // Descrição do veiculo
ZFN->ZFN_PLACA1 := _cPlaca1 // Placa do Veiculo 1
ZFN->ZFN_MUNIC1 := "" //U_VEICUL:MUNICI1	   // Municipio da placa 1
ZFN->ZFN_PLACA2 := _cPlaca2 // U_VEICUL:PLACA2     // Placa do Veiculo 2
ZFN->ZFN_MUNIC2 := "" //U_VEICUL:MUNICI2    // Municipio da placa 2
ZFN->ZFN_PLACA3 := _cPlaca3 //U_VEICUL:PLACA3     // Placa do Veiculo 3
ZFN->ZFN_MUNIC3 := "" //U_VEICUL:MUNICI3    // Municipio da placa 3
ZFN->ZFN_PLACA4 := _cPlaca4 //U_VEICUL:PLACA4     // Placa do Veiculo 4
ZFN->ZFN_MUNIC4 := "" //U_VEICUL:MUNICI4	   // Municipio da placa 4
ZFN->ZFN_CODMVE := M->DA3_I_CODV  //  Codigo do Tipo de Veiculo do TMS

//If Type("_oVeiculo['uf']") <> "U"
   ZFN->ZFN_ESTADO := M->DA3_ESTPLA //_oVeiculo['uf'] //U_VEICUL:ESTADO     // Estado da placa
//EndIf 

//If Type("_oMotorista:NOME") <> "U"
   ZFN->ZFN_NOMEM  := M->DA4_NOME //_oMotorista:NOME // U_VEICUL:NOMEM      // Nome do motorista
//EndIf 

//If Type("_oMotorista:CPF") <> "U"
   ZFN->ZFN_CPFM   := M->DA4_CGC  // _oMotorista:CPF  // U_VEICUL:CPFM       // CPF do motorista
//EndIf 

//If Type("_oMotorista:transportador:cnpj") <> "U"
   ZFN->ZFN_CNPJT  :=  M->DA4_CGC //_oMotorista:transportador:cnpj  //U_VEICUL:CNPJT      // CNPJ Transportadora
//EndIf 

//If Type("_oMotorista:ENDERECO:LOGRADOURO") <> "U"
   ZFN->ZFN_ENDERM := M->DA4_END //_oMotorista:ENDERECO:LOGRADOURO  //U_VEICUL:ENDERECOM  // Endereco Motorista
//EndIf 

//If Type("_oMotorista:ENDERECO:BAIRRO") <> "U"
   ZFN->ZFN_BAIRRM :=  M->DA4_BAIRRO //_oMotorista:ENDERECO:BAIRRO //U_VEICUL:BAIRROM    // Bairro Motorista
//EndIf 

//If Type("_oMotorista:ENDERECO:CIDADE") <> "U"
   ZFN->ZFN_MUNICM := M->DA4_NUMCNH //_oMotorista:ENDERECO:CIDADE //U_VEICUL:MUNICIPIOM // Municipio Motorista
//EndIf 

//If Type("_oMotorista:ENDERECO:ESTADO") <> "U"
   ZFN->ZFN_ESTADM := M->DA4_EST //_oMotorista:ENDERECO:ESTADO //U_VEICUL:ESTADOM    // Estado do Motorista
//EndIf 

//If Type("_oMotorista:ENDERECO:CEP") <> "U"
   ZFN->ZFN_CEPM   :=  M->DA4_END  // _oMotorista:ENDERECO:CEP //U_VEICUL:CEPM       // CEP do Motorista
//EndIf 

//If Type("_oMotorista:ENDERECO:TELEFONE") <> "U"
   ZFN->ZFN_TELEFM := M->DA4_TEL // _oMotorista:ENDERECO:TELEFONE //U_VEICUL:TELEFONEM  // Telefone do Motorista
//EndIf 

//If Type("_oMotorista:NUMEROHABILITACAO") <> "U"
   ZFN->ZFN_CNHM   := M->DA4_NUMCNH //_oMotorista:NUMEROHABILITACAO //U_VEICUL:CNHM       // CNH do motorista
//EndIf 

//If Type("_oMotorista:DATAHABILITACAO") <> "U"
   ZFN->ZFN_EMICNH := M->DA4_DTECNH  //Ctod(AllTrim(_oMotorista:DATAHABILITACAO)) //Ctod(U_VEICUL:EMICNH)     // Emissão da CNH
//EndIf 

//If Type("_oMotorista:DATAVENCIMENTOHABILITACAO") <> "U"
   ZFN->ZFN_VALCNH := M->DA4_DTVCNH  // Ctod(AllTrim(_oMotorista:DATAVENCIMENTOHABILITACAO)) //If(Empty(U_VEICUL:VALCNH),Ctod("  /  /  "),Ctod(U_VEICUL:VALCNH)) // Validade da CNH
//EndIf 

//If Type("_oMotorista:CATEGORIACNH") <> "U"
   ZFN->ZFN_CATCNH := M->DA4_CATCNH // _oMotorista:CATEGORIACNH //U_VEICUL:CATCNH     // Categoria CNH
//ENDIf 

ZFN->ZFN_PAIM   := "" //U_VEICUL:PAIM       // Pai do Motorista
ZFN->ZFN_MAEM   := "" //U_VEICUL:MAEM       // Mãe do Motorista

//If Type("_oMotorista:RG") <> "U"
   ZFN->ZFN_RGM := M->DA4_RG // _oMotorista:RG //U_VEICUL:RGM        // RG do Motorista
//EndIf 

//If Type("_oMotorista:ENDERECO:TELEFONE2") <> "U"
   ZFN->ZFN_TELREM := M->DA4_TELREC // _oMotorista:ENDERECO:TELEFONE2 //U_VEICUL:TELRECM    // Telefone recado Motorista
//EndIf 

ZFN->ZFN_USUARI := __CUSERID           // Codigo do Usuário
ZFN->ZFN_DATAAL :=  Date()	            // Data de Alteração
ZFN->ZFN_SITUAC := "P"                 // Situação do Registro
ZFN->ZFN_CODEMP := _cCodEmpWS	         // Codigo Empresa WebServer
ZFN->ZFN_RETORN := _cStatus	         // Retorno Integracao Italac-RDC
ZFN->(MsUnlock())

_aRet := {_lRet,_cStatus}

_cMsgResp := _cMsg + " - " + _cMsgOk

Return _aRet 

/*
===============================================================================================================================
Programa----------: AOMS085C
Autor-------------: Julio de Paula Paz
Data da Criacao---: 05/01/2024
===============================================================================================================================
Descrição---------: Gera a Carga no Protheus com base nos dados recebidos do TMS Multiembarcador                    
===============================================================================================================================
Parametros--------: _oMotorista = Dados do Motorista
                    _oVeiculo   = Dados do Veiculo
                    _oPlacas    = Placas do Veículo
                    _oCarga     = Dados da Carga 
===============================================================================================================================
Retorno-----------: _lRet = .T. = Gerou a Carga com sucesso.
                          = .F. = Falha na Geração da Carga.
===============================================================================================================================
*/  
User Function AOMS085C(_oMotorista,_oVeiculo,_oPlacas,_oCarga,_lVeicMotor,_cResposta)
Local _lRet := .T. 
Local _aOrd := SaveOrd({"SM0"})
Local _nRecnoSM0 := SM0->(Recno())
Local _nTamPedido
Local _nTamCGC
//Local _nTamPlaca
Local _cMsg := ""
Local _nI
Local _nJ
Local _nX 
Local _aFilial
Local _cFilial:="01", _nQtdLib, _cCodigo:=""
Local _lPesoLiq
Local _cPedido, _nCapacVolum, _aQtdClientes
Local _cCodEmpWS
Local _apedidos := {}
Local _lAteracao
Local _cMsgOk := ""
Local _aAprovacao, _lAprov, _cTextoRet
Local _cFilHabilit
Local _cCodTransp, _cLojaTransp
Local _cCodUsuario //, _nTamCodUser
Local _nRegAtu, _cTipoPeso
//	Local _lAchouCGC
Local _cCpfMotor, _lAchouTransp, _cCodMotor, _cCodVeic
Local _nTamCod
Local _cPlacaCV, _cPlaca, _cPlacaVG, _cPlacaVG3
Local _nTamTipoVeic, _cTipoVeic
Local _cChavePesq, _aJaProces, _cPedidos
Local _cTextoCred
Local _cTempoIni, _cTempoFin, _nTempoTot, _cTextoTempo
//	Local _aRetPallet
//	Local _aPlaca := {}  //, P
Local _cCodOperL, _cLojaOperL
Local _cCodOpT,_cLojaOpT, _cCodOpA,_cLojaOpA, _cCodOpF,_cLojaOpF
Local _aItensPallet:={}
Local _nValMaxFrete, _nValMaxPedagio
Local _aPedJSon, _cPedJSon, _aCargasAtu,_cMsgRDC
Local _cCodCarga, _lPedOk, _cPedGerador, _cOrdemEnt // , _nnh
Local _aPlacasV := {}
Local _cCodVTms := ""
Local _nOrdEntre := 0, _cOrdEntre := ""
Local _JsonCarga
Local _aItensPV 
Local _nQtdItem

Local _aItemJson
Local _aProdutos
Local _lQtdDif   := .F.
Local _aRetDesme
Local _cUndMed
Local _cTipCarga
Local _nTipCarga 

Private _lWebservice
Private _cMsgEfetiva
Private _cMailUsrCarga
Private _lEnviaEmail := .F.
Private __cUserID
_lWebservice := .T.

//Inicializa strings para evitar errorlogs
_cCodMotor := "                    "
_cPlaca := "                    "
_cPlacaCV := "                    "
_cPlacaVG := "                    "
_cPlacaVG3 := "                    "
_cTipoVeic := "                    "
_cMsgRDC := ""

_lPedOk     := .F.
_aCargasAtu := {}

Begin Sequence
   //===============================================
   // Registra o tempo inicial de criação da carga.
   //===============================================
   _cTempoIni := Time()

   _cMsg   := ""
   _cMsgOk := ""
   _nTamCGC:= TAMSX3("A2_CGC")[1]

   _oDadosCapa := _oCarga[1]
   _aNamesCapa := _oCarga[1]:GetNames()

   _cNrCarga  := ""                     // Numero da Carga = numeroCarga
   _cCPFUsuar := ""                     // Código Usuário - buscar por - operadorCargaCPF
   _cNrPedV   := ""                     // Pedido de Vendas = numeroPedidoEmbarcador
   _cCNPJEmb  := ""                     // filial:cnpj      = CNPJ Embarcador
   _oDadosEmb := _oDadosCapa["filial"]

   _cNrCarga  := _oDadosCapa["numeroCarga"]
   _cCPFUsuar := ""
   If Type('_oDadosCapa["operadorCargaCPF"]') <> "U" 
      _cCPFUsuar := _oDadosCapa["operadorCargaCPF"]
   EndIf 
   _cCPFUsuar := StrTran(_cCPFUsuar,".","")
   _cCPFUsuar := StrTran(_cCPFUsuar,"-","")
   _cCPFUsuar := StrTran(_cCPFUsuar,"/","")
   _cCNPJEmb  := _oDadosEmb["cnpj"]
   _cCNPJEmb  := StrTran(_cCNPJEmb,".","")
   _cCNPJEmb  := StrTran(_cCNPJEmb,"-","")
   _cCNPJEmb  := StrTran(_cCNPJEmb,"/","")
   _cNrPedV   := _oDadosCapa["numeroPedidoEmbarcador"]  // numero do pedido de vendas.
   _oDadosFre := _oDadosCapa["valorFrete"]
   _nValFrete := _oDadosFre["valorPrestacaoServico"]
   _nValPedag := _oDadosCapa["valorPedagio"] 
   _nPesoBrut := _oDadosCapa["pesoBruto"]
   _oTranport := _oDadosCapa["transportadoraEmitente"] 
   _cCnpjTran := _oTranport["cnpj"]
   _cCnpjReceb := ""

   _oRecebedor := _oDadosCapa["recebedor"]
   If ValType(_oRecebedor) <> "U"
      _cCnpjReceb := _oRecebedor["cpfcnpjSemFormato"] // Operador Logistico/Redespacho
   EndIf 

   _cDataHora  := _oDadosCapa["dataCriacaoCarga"]
   _cDataCarg  := SubStr(_cDataHora,1,10)
   _dDataCarg  := Ctod(_cDataCarg)
   //_nQtdPalet  := _oDadosCapa["numeroPaletes"]
   _nQtdPalet  := _oDadosCapa["numeroPaletesFracionado"]

   _cObsCarga  := _oDadosCapa["obsCarregamento"]
   _cProtCarga := _oDadosCapa["protocoloCarga"]

   _nValPedag  := 0

   _nJ := Ascan(_aNamesCapa,"consultaValePedagio")
   
   If _nJ > 0
      _oValPedag  := _oDadosCapa["consultaValePedagio"]
      If Type('_oValPedag["valorConsultaValePedagio"]') <> "U" 
         _nValPedag := _oValPedag["valorConsultaValePedagio"]  
      EndIf 
   EndIf 

   If ValType(_cProtCarga) == "N"
      _cProtCarga := AllTrim(Str(_cProtCarga,16))
   EndIf 

   _nValorTotal := 0
   _nPesoLiq    := 0
   _nValFrete   := 0
   
   _nPesoBrut   := 0
   

   _aPedJSon := {}
   For _nI := 1 To Len(_oCarga)
       _oDadosPV  := _oCarga[_nI]
       _cNrPedV   := _oDadosPV["numeroPedidoEmbarcador"]
       _cOrdemEnt := _oDadosPV["ordemEntrega"]

       _nValorTotal := _nValorTotal + _oDadosPV["valorTotalPedido"]

       _oDadosFre := _oDadosPV["valorFrete"] // _oDadosFre := _oDadosCapa["valorFrete"]
	   If ValType(_oDadosFre["valorPrestacaoServico"]) <> "U"
		  _nValFrete += _oDadosFre["valorPrestacaoServico"]
	   EndIf 
       
	 //  If ValType(_oDadosPV["valorPedagio"]) <> "U" //ValType(_oDadosCapa["valorPedagio"]) <> "U"
     //     _nValPedag += _oDadosPV["valorPedagio"]  //_oDadosCapa["valorPedagio"] 
	 //  EndIf 

	   If ValType(_oDadosPV["pesoBruto"]) <> "U" // ValType(_oDadosCapa["pesoBruto"]) <> "U"
          _nPesoBrut += _oDadosPV["pesoBruto"]  // _oDadosCapa["pesoBruto"]
	   EndIf 

       _cCnpjReceb := ""    
	   _oRecebedor := _oDadosPV["recebedor"] // _oDadosCapa["recebedor"]
       If ValType(_oRecebedor) <> "U"
	      //If ValType(_oRecebedor["cpfcnpjSemFormato"]) <> "U"
          _cCnpjReceb := _oRecebedor["cpfcnpjSemFormato"] // Operador Logistico/Redespacho
	   EndIf 


	   _cNumeroC := _oDadosPV["numeroCarga"]

	   _oProdutos := _oDadosPV["produtos"]
	   //_cPVAltera := _oDadosPV["pedidoAlterado"] // True/False

	   //------------------------------------------------
       _nTipCarga  := _oDadosPV["tipoPaleteCliente"]
       If ValType(_nTipCarga) == Nil 
          _cTipCarga := "2"
       ElseIf ValType(_nTipCarga) == "N"
          If _nTipCarga == 1
             _cTipCarga := "1"
	      ElseIf _nTipCarga == 2
             _cTipCarga := "2"
          ElseIf _nTipCarga == 3
             _cTipCarga := "5"
	      Else 
             _cTipCarga := "2"
	      EndIf 
       ElseIf ValType(_nTipCarga) == "C"
          If Upper(_nTipCarga) == "CHEP"
             _cTipCarga := "1"
	      ElseIf Upper(_nTipCarga) == "BATIDO"
             _cTipCarga := "2"
          ElseIf Upper(_nTipCarga) == "PALETE RETORNO"
             _cTipCarga := "5"
	      Else 
             _cTipCarga := "2"
	      EndIf 
       Else 
          _cTipCarga := "2"
       EndIf 
	
                              // Numero Ped.Venda, Cnpj Embarcador,Tipo de Carga, Nr.da Carga, Ordem de Entrega, Nova Ordem de Entrega, Itens PV  
       //Aadd(_aPedJSon,{U_ItKey(_cNrPedV,"C5_NUM"), _cCnpjReceb    , ""          ,_cNumeroC   ,_cOrdemEnt       ,_cOrdemEnt, _oProdutos})	 
	   Aadd(_aPedJSon,{U_ItKey(_cNrPedV,"C5_NUM"), _cCnpjReceb    , _cTipCarga    ,_cNumeroC   ,_cOrdemEnt       ,_cOrdemEnt, _oProdutos})	 
	   
	   //Aadd(_aPedJSon,{U_ItKey(_cNrPedV,"C5_NUM"),  // 1  = Numero Ped.Venda
	   //                           _cCnpjReceb    ,  // 2  = Cnpj Embarcador
	   //							""             ,  // 3  = Tipo de Carga
	   //							_cNumeroC      ,  // 4  = Nr.da Carga
	   //							_cOrdemEnt     ,  // 5  = Ordem de Entrega
	   //							_cOrdemEnt     ,  // 6  = Nova Ordem de Entrega
	   //							_oProdutos})	  // 7  = Itens PV  

   Next 

   //=============================================================== 
   // Ajustar a Ordem de entrega para que não haja repetições. 
   //===============================================================
   _nOrdEntre := 0
   _cOrdEntre := "" 
   _lRepeteSq := .F.
   
   If Len(_aPedJSon) > 0 
      //==============================================================
	  // Verifica se existem sequencias repetidas enviadas pelo TMS.
	  //==============================================================
      For _nI := 1 To Len(_aPedJSon)
	      _cOrdEntre := _aPedJSon[_nI,5] // Ordem de Entrega

	      For _nJ := 1 To Len(_aPedJSon)
              If _nI <> _nJ .And. _cOrdEntre == _aPedJSon[_nJ,5]
                 _lRepeteSq := .T.
			     Exit
			  EndIf 
		  Next
	  Next 
	  
	  //=================================================================================
	  // Se existir sequencias repetidas, refaz as sequencias de entrega aleatoriamente.
	  //=================================================================================
      If _lRepeteSq // Há sequencia repetida.
	     _nOrdEntre := 1

         For _nI := 1 To Len(_aPedJSon)
	         _cOrdEntre := StrZero(_nOrdEntre,6)
			 
			 _aPedJSon[_nI,6] := _cOrdEntre // Ordem de Entrega
			 _nOrdEntre += 5 
	     Next

	  EndIf 


   EndIf 

   //===============================================================
   // Dados Veiculos e Motoristas
   //===============================================================
   If ! _lVeicMotor
     _cMsg += " Problemas com os dados Motoristas/Veiculos: [" + Alltrim(_cResposta) + "]"
	  Break  
   Else 
      If ValType(_oMotorista) == "A"
         _oCPFMotor := _oMotorista[1]
      Else
	     _oCPFMotor := _oMotorista
      EndIf 
      _cCpfMotor := _oCPFMotor["cpf"]

      SA2->(Dbsetorder(3))
	  SA2->(DbSeek(xFilial("SA2")+U_ItKey(_cCnpjTran,"A2_CGC"))) 

      _cCodTMot  := ""
      _cLojaTMot := ""
      _cCodTMTr  := ""
      _cLojaTMTr := ""

      Do While ! SA2->(Eof()) .And. SA2->(A2_FILIAL+A2_CGC) == xFilial("SA2")+U_ItKey(_cCnpjTran,"A2_CGC") 
         If SA2->A2_I_CLASS $ "T/A"
		    _cCodTMot  := SA2->A2_COD
		    _cLojaTMot := SA2->A2_LOJA
		 		
		    If SA2->A2_I_CLASS == "T"
		       _cCodTMTr  := SA2->A2_COD
		       _cLojaTMTr := SA2->A2_LOJA
		    EndIf

	     EndIf
	     SA2->(DbSkip())
      EndDo

      If !Empty(_cCodTMTr) .And. !Empty(_cLojaTMTr)
         _cCodTMot  := _cCodTMTr
         _cLojaTMot := _cLojaTMTr
      EndIf 

      DA4->(DbSetOrder(3))
      DA4->(MsSeek(xFilial("DA4")+U_ItKey(_cCpfMotor,"DA4_CGC")))
      Do While ! DA4->(Eof()) .And. DA4->DA4_FILIAL+DA4->DA4_CGC == xFilial("DA4")+U_ItKey(_cCpfMotor,"DA4_CGC") 
         If DA4->DA4_FORNEC == _cCodTMot  .And. DA4->DA4_LOJA == _cLojaTMot
            _cCodMotor  :=  DA4->DA4_COD  // Posicione("DA4",3, xFilial("DA4")+U_ItKey(_cCpfMotor,"DA4_CGC") ,"DA4_COD") // DA4_FILIAL+DA4_CGC
            _cNomeMotor :=  DA4->DA4_NOME // Posicione("DA4",3,xFilial("DA4")+U_ItKey(_cCpfMotor,"DA4_CGC"),"DA4_NOME")  
	     EndIf 

         DA4->(DbSkip())
      EndDo 	  
	  
      _cPlaca := _oVeiculo["placa"]
   
      _aPlacasV := {}
      Aadd(_aPlacasV,_cPlaca)
   
      If Len(_oPlacas) > 0

         For _nI := 1 To Len(_oPlacas)
	         _oPlacasV := _oPlacas[_nI]
			 
		     _cPlaca := _oPlacasV["placa"]
		     _nJ := Ascan(_aPlacasV,_cPlaca)
			 If _nJ == 0
		        Aadd(_aPlacasV,_cPlaca)
			 EndIf 
	     Next
      EndIf 

      DA3->(DbSetOrder(2)) // DA3_FILIAL+DA3_MOTORI = Motorista
      DA3->(MsSeek(xFilial("DA3")+U_ItKey(_cCodMotor,"DA3_MOTORI")))

      _cTipoVeic := ""
      _cCodVeic  := ""
      _cNomeVeic := ""
	  _cCodVTms  := ""

      Do While ! DA3->(Eof()) .And. DA3->DA3_FILIAL+DA3->DA3_MOTORI == xFilial("DA3")+U_ItKey(_cCodMotor,"DA3_MOTORI")
         If Len(_aPlacasV) == 1
	        _nI := AsCan(_aPlacasV,AllTrim(DA3->DA3_PLACA))

		    _nJ := AsCan(_aPlacasV,AllTrim(DA3->DA3_I_PLCV))

		    If _nI > 0 .Or. _nJ > 0 // Caminhão/Utilitário
		       _cTipoVeic := DA3->DA3_I_TPVC // 1=CARRETA;2=CAMINHAO;3=BI-TREM;4=UTILITARIO;5=RODOTREM
               _cCodVeic  := DA3->DA3_COD   
               _cNomeVeic := DA3->DA3_DESC
			   _cCodVTms  := DA3->DA3_I_CODV
			   Exit 
		    EndIf 
	     EndIf

         If Len(_aPlacasV) == 2     // Carreta
	        _nI := AsCan(_aPlacasV,AllTrim(DA3->DA3_PLACA))

		    _nJ := AsCan(_aPlacasV,AllTrim(DA3->DA3_I_PLCV))

		    If _nI > 0 .And. _nJ > 0 
		       _cTipoVeic := DA3->DA3_I_TPVC // 1=CARRETA;2=CAMINHAO;3=BI-TREM;4=UTILITARIO;5=RODOTREM
               _cCodVeic  := DA3->DA3_COD   
               _cNomeVeic := DA3->DA3_DESC
			   _cCodVTms  := DA3->DA3_I_CODV
			   Exit 
		    EndIf 
	     EndIf

	     If Len(_aPlacasV) == 3  // Bi-Trem
	        _nI := AsCan(_aPlacasV,AllTrim(DA3->DA3_PLACA))

		    _nJ := AsCan(_aPlacasV,AllTrim(DA3->DA3_I_PLCV))

		    _nK := AsCan(_aPlacasV,AllTrim(DA3->DA3_I_PLVG))

		    If _nI > 0 .And. _nJ > 0 .And. _nK > 0 
		       _cTipoVeic := DA3->DA3_I_TPVC // 1=CARRETA;2=CAMINHAO;3=BI-TREM;4=UTILITARIO;5=RODOTREM
               _cCodVeic  := DA3->DA3_COD   
               _cNomeVeic := DA3->DA3_DESC
			   _cCodVTms  := DA3->DA3_I_CODV
		  	   Exit 
		    EndIf 
	     EndIf

	     If Len(_aPlacasV) == 4  // Rodo-Trem
	        _nI := AsCan(_aPlacasV,AllTrim(DA3->DA3_PLACA))

		    _nJ := AsCan(_aPlacasV,AllTrim(DA3->DA3_I_PLCV))

		    _nK := AsCan(_aPlacasV,AllTrim(DA3->DA3_I_PLVG))

		    _nL := AsCan(_aPlacasV,AllTrim(DA3->DA3_I_PLV3))

		    If _nI > 0 .And. _nJ > 0 .And. _nK > 0 .And. _nL > 0
		       _cTipoVeic := DA3->DA3_I_TPVC // 1=CARRETA;2=CAMINHAO;3=BI-TREM;4=UTILITARIO;5=RODOTREM
               _cCodVeic  := DA3->DA3_COD   
               _cNomeVeic := DA3->DA3_DESC
			   _cCodVTms  := DA3->DA3_I_CODV
			   Exit 
		    EndIf 
	     EndIf

         DA3->(DbSkip())
      EndDo 
   EndIf 

   //===================================================================================
   // Semaforo para controle de integrações. Não permitir a inclusão em duplicidade de
   // cargas.
   //===================================================================================
   If !LockByName("U_AMOS085C"+AllTrim(_cNrCarga) ,.F.,.F.,.T.) // LockByName("U_AMOS085C"+AllTrim(_oCarga:NUMEROCARGA) ,.F.,.F.,.T.)
	  _cMsg += " A integração desta carga já está em processamento. Aguarde! "
	  Break
   EndIf

   _cCNPJEmb  := StrTran(_cCNPJEmb,".","")
   _cCNPJEmb  := StrTran(_cCNPJEmb,"-","")
   _cCNPJEmb  := StrTran(_cCNPJEmb,"/","")
   
   //===================================================================================
   // Valida o CNPJ do Embarcador enviado pela TMS Multiembarcador
   //===================================================================================
   If Empty(_cCNPJEmb) 
	  _cMsg += " CNPJ Embarcador não preenchido. "
	  Break
   Else
      ZEL->(DbSetOrder(5)) // ZEL_FILIAL+ZEL_CNPJEM
      If ZEL->(MsSeek(xFilial("ZEL")+_cCNPJEmb))
         _cFilial := ZEL->ZEL_FILFIS 
	  Else
	     _aFilial := FwLoadSM0() 
	     If Ascan(_aFilial,{|x| x[18] = U_ItKey(_cCNPJEmb,"A2_CGC")}) == 0
            _cMsg += " CNPJ Embarcador não está cadastrado. "
	        Break 
		 Else 
	        _nI := Ascan(_aFilial,{|x| x[18] = U_ItKey(_cCNPJEmb,"A2_CGC")})
	        _cFilial := _aFilial[_nI,5]
		 EndIf 
	  EndIf 
   EndIf

   _cCPFUsuar := StrTran(_cCPFUsuar,".","")
   _cCPFUsuar := StrTran(_cCPFUsuar,"-","")
   _cCPFUsuar := StrTran(_cCPFUsuar,"/","")

   //==========================================================================================
   // Altera a filial para a filial do embarcador do JSON.
   //==========================================================================================
   SM0->(MsSeek("01"+_cFilial))
   cFilant := _cFilial

   //==========================================================================================
   // Verifica se o usuário do TMS Multiembarcador está cadastrado no cadastro usuários Italac.
   //==========================================================================================
   _cCodUsuario := Posicione("ZZL",6,xfilial("ZZL")+U_ItKey(_cCPFUsuar,"RA_CIC"),"ZZL_CODUSU") // ZZL_FILIAL+ZZL_RDCUSR
   If Empty(_cCodUsuario)
	  _cMsg := " Usuário não cadastrado no Cadastro de Usuários Italac. "
	  disarmtransaction()
	  Break
   EndIf

   __cUserId := _cCodUsuario // Carrega a variável do Workflow __cUserId com o código do solicitante da integração.
   
   _cCodEmpWS := SUPERGETMV('IT_EMPWEBSE',.F.,  "")
   If Empty(_cCodEmpWS)
      _cCodEmpWS := U_ITGETMV( 'IT_EMPWEBSE' , '000001' )
   EndIf 

   //================================================================================
   // Define se a filial de processamento está habilitada para a integração
   // Webservice, Italac x RDC.
   //================================================================================
   _cFilHabilit := SUPERGETMV('IT_FILINTWS',.F.,  "")
   If Empty(_cFilHabilit)
      _cFilHabilit := U_ITGETMV( 'IT_FILINTWS' , '' ) // Filiais habilitadas na integracao Webservice Italac x TMS Multiembarcador.
   EndIf 

   If !_cFilial $ _cFilHabilit // Filiais habilitadas na integracao Webservice Italac x TMS Multiembarcador.
	  _cMsg += " O CNPJ: " + _cCNPJEmb + ", Filial: " + _cFilial + ", não está habilitada para integração Webservice Italac x TMS Multiembarcador. "
   EndIf

   SM0->(DBSETORDER(1))

   If !SM0->(DBSEEK("01"+_cFilial))
	  _cMsg += " Filial: " + _cFilial + " não encotrada no SM0."
   EndIf

   If ! Empty(_cMsg)
	  //::U_STATUS := _cMsg
	  Disarmtransaction()
	  Break
   EndIf
   cFilAnt := _cFilial

   //===========================================================================================
   // Reinicializando váriaveis que dependem do ambiente
   //===========================================================================================
   _nTamPedido   := TAMSX3("C5_NUM")[1]
   _nTamCGC      := TAMSX3("A2_CGC")[1]
   _cTipoPeso    := GetMv('MV_PESOCAR')
   _nTamCod      := TAMSX3("DAK_I_CARG")[1]
   _nTamTipoVeic := TAMSX3("DA3_I_TPVC")[1]

   _lPesoLiq := .F.
   If AllTrim(_cTipoPeso) == "L"
	  _lPesoLiq := .T.
   EndIf

   SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM
   SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
   DA4->(DbSetOrder(3)) // DA4_FILIAL+DA4_CGC  // CPF MOTORISTA
   SA2->(DbSetOrder(3)) // A2_FILIAL+A2_CGC
   DAK->(DbSetOrder(1))
   DAI->(DbSetOrder(4)) // DAI_FILIAL+DAI_PEDIDO+DAI_COD+DAI_SEQCAR
   SC9->(DbSetOrder(1)) // C9_FILIAL + C9_PEDIDO

   _cCodCarga := ""
   _aCargasAtu := {}

   For _nI := 1 to Len(_aPedJSon) 
	   //==================================================================================
	   // Verifica se este pedido já existe lançado para alguma Carga.
	   //==================================================================================
       DAI->(Dbsetorder(4))  // DAI_FILIAL+DAI_PEDIDO+DAI_COD+DAI_SEQCAR
       If DAI->(DbSeek(_cFilial+ _aPedJSon[_nI,1])) 
		  If Empty(_cCodCarga)
		     _cCodCarga := DAI->DAI_COD
		  EndIf
		  
		  DAK->(Dbsetorder(1))
		  If DAK->(DbSeek(DAI->DAI_FILIAL+DAI->DAI_COD))
		     If SC9->(DbSeek(_cFilial+_aPedJSon[_nI,1]))
				//    Renco DAK       Recno DAI          DAK_I_RECR                        DAK_I_CARG
				Aadd(_aCargasAtu, {DAK->(Recno()), DAI->(Recno()), /*AllTrim(Str(U_CARGA:RECNUM,10))*/, _cNrCarga /* Padr(U_CARGA:CODIGO,_nTamCod," ")*/})
			 EndIf
		  EndIf
	   EndIf
   Next

   If Len(_aCargasAtu) > 0
	  //==================================================================================
	  // Verifica se os pedidos de vendas do JSon são exatamente os mesmos da tabela DAI.
      //==================================================================================
      _nI := 0
	  _lPedOk  := .T.
	  _nRegAtu := _aCargasAtu[1,1]

	  DAI->(DbSetOrder(1)) // DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN+DAI_PEDIDO
      DAI->(DbSeek(_cFilial+_cCodCarga))
      Do While ! DAI->(Eof()) .And. DAI->(DAI_FILIAL+DAI_COD) == _cFilial+_cCodCarga
	     _nI += 1

	     _nJ := Ascan(_aPedJSon,{|x| x[1] == DAI->DAI_PEDIDO})

		 _cPedGerador := Posicione('SC5',1,_cFilial+DAI->DAI_PEDIDO,"C5_I_PEDGE") // Indica se o pedido de vendas é
		 // Um Pedido Gerador ou um Pedido de Pallet.

         If _nJ == 0 .And. _cPedGerador = 'S'
			_lPedOk := .F.
			Exit
		 EndIf

		 DAI->(DbSKip())
	  EndDo

	  If ! _lPedOk
	     _cMsg += " Os pedidos de vendas informados já estão em outra carga. "
		 Break
      EndIf
   EndIf 

   //==================================================================================
   // Valida dados da carga criada.
   //==================================================================================
   DAK->(DBOrderNickname("CODCAR_RDC")) // DAK_FILIAL+DAK_I_CARG
   
   If DAK->(DbSeek(_cFilial+U_ITKEY(_cNrCarga, "DAK_I_CARG"))) //DAK->(DbSeek(_cFilial+U_ITKEY(_cProtCarga, "DAK_I_FRDC")+U_ITKEY(U_CARGA:CODIGO, "DAK_I_CARG"))) // DbSeek(_cFilial+U_CARGA:CODIGO)
      Do While ! DAK->(Eof()) .And. DAK->DAK_FILIAL+DAK->DAK_I_CARG == _cFilial+U_ITKEY(_cNrCarga, "DAK_I_CARG")
         If Alltrim(DAK->DAK_I_RECR) == AllTrim(_cProtCarga)
            _cMsg += "Já existe carga criada no Protheus na filial: " + DAK->DAK_FILIAL + ", com o numero de carga Protheus: " + DAK->DAK_COD + ", para a carga do TMS com o numero: " + _cNrCarga + ", e o Protocolo de Carga TMS: " + _cProtCarga +"."
            Break
		 EndIf 

         DAK->(DbSkip())
	  EndDo   
   EndIf 

   //===========================================================================================
   // Valida valores de frete e de pedágio.
   //===========================================================================================
   _nValMaxFrete := SUPERGETMV('IT_MAXFRETE',.F.,  "")
   If Empty(_nValMaxFrete)
      _nValMaxFrete := U_ItGetMv("IT_MAXFRETE", 100000)
   EndIf 

   _nValMaxPedagio := SUPERGETMV('IT_MAXPEDAG',.F.,  "")
   If Empty(_nValMaxPedagio)
      _nValMaxPedagio := U_ItGetMv("IT_MAXPEDAG", 100000)
   EndIf 
    
   If _nValFrete > _nValMaxFrete  // "valorCustoFrete"
      _cMsg += " O valor de frete informado para esta carga, supera o limite máximo definido no parâmetro IT_MAXFRETE. "
   EndIf

   If _nValPedag > _nValMaxPedagio // "valorPedagio"
      _cMsg += " O valor de pedágio informado para esta carga, supera o limite máximo definido no parâmetro IT_MAXPEDAG. "
   EndIf

   //===========================================================================================
   // Valida se pedidos podem ser lockados, util para definir se já não está rodando o processo
   //===========================================================================================
    _cPedJSon := ""

   _aItensPallet:={}
   For _nI := 1 to Len( _aPedJSon)
       SC5->(Dbsetorder(1))
       
	   If !SC5->(DbSeek(_cFilial+_aPedJSon[_nI,1]))
		  _cMsg += " O pedido  " + _aPedJSon[_nI,1] + " não pode ser localizado."
 	   Elseif !SC5->(MsRLock(SC5->(RECNO())))
          _cMsg += " No momento este Pedido de Vendas está sendo utilizado por outro usuário e não pode ser manipulado. Vefifique se já não há cargas para ele e tente integrar novamente mais tarde: " + _aPedJSon[_nI,1]
       ElseIf !EMPTY(SC5->C5_NOTA)
		  _cMsg += " Pedido não disponível para geração da carga/viagem TMS Multiembarcador: " + _cNrCarga + "! Pedido de vendas: "+ _aPedJSon[_nI,1] +" já faturado! "
	   Elseif posicione("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_MSBLQL") == '1'
		  _cMsg += "Cliente do pedido bloqueado no cadastro "+AllTrim(SC5->C5_CLIENTE+"/"+SC5->C5_LOJACLI)+"." + " Pedido de vendas: "+ _aPedJSon[_nI,1]
	   EndIf

       //==================================================================================
       // Verifica se este pedido já existe lançado para alguma Carga.
       //==================================================================================
       DAI->(Dbsetorder(4))
       If DAI->(DbSeek(_cFilial+_aPedJSon[_nI,1]))
          DAK->(Dbsetorder(1))
          If DAK->(DbSeek(DAI->DAI_FILIAL+DAI->DAI_COD))
             If DAK->DAK_I_CARG <> _cNrCarga 
                _cMsg += " Já existe o numero de pedido: " + _aPedJSon[_nI,1] + ", lançado na filial: " + _cFilial + ", para carga/viagem: " + AllTrim(DAK->DAK_I_CARG) + "."
			 EndIf
		  EndIf
	   EndIf

   Next

   _lAteracao := .F.

   If Empty(_nPesoBrut) 
	  _cMsg += " Peso bruto mercadoria não preenchido. "
   EndIf

   If Empty(_nValorTotal)  // U_CARGA:VALOR 
      _cMsg += " Valor da carga não preechido. "
   EndIf

   If Empty(_dDataCarg) // U_CARGA:DATAE
	  _cMsg += " Data de emissão da carga não preenchido. "
   EndIf

   _cCodTransp  := "" // SA2->A2_COD
   _cLojaTransp := "" // SA2->A2_LOJA

   If Empty(_cCnpjTran) // U_CARGA:CNPJTRA
	  _cMsg += " O CNPJ da transportadora deve ser preenchido. "
   EndIf

   _cAuto:=""
   _cCond:=""
   _cCodTransp  := ""
   _cLojaTransp := ""
   _lAchouTransp := .F.
	
   SA2->(Dbsetorder(3))
   SA2->(DbSeek(xFilial("SA2")+U_ItKey(_cCnpjTran,"A2_CGC"))) 
	
   Do While ! SA2->(Eof()) .And. SA2->(A2_FILIAL+A2_CGC) == xFilial("SA2")+U_ItKey(_cCnpjTran,"A2_CGC") 
      If SA2->A2_I_CLASS $ "T/A"
		 _cCodTransp  := SA2->A2_COD
		 _cLojaTransp := SA2->A2_LOJA

		 _cAuto       := SA2->A2_I_AUT
		 _cCond       := SA2->A2_COND
		
		 If SA2->A2_I_CLASS == "T"
			_cCodTransp  := SA2->A2_COD
			_cLojaTransp := SA2->A2_LOJA
			_cAuto       := SA2->A2_I_AUT
			_cCond       := SA2->A2_COND
		 EndIf

		 _lAchouTransp := .T.
	  EndIf
	  SA2->(DbSkip())
   EndDo

   If ! _lAchouTransp
	  _cMsg += " O CNPJ/CPF da transportadora/Autonomo não está cadastrado: "+U_ItKey(_cCnpjTran,"A2_CGC") 
   ElseIf Len(AllTrim(_cCnpjTran)) < 14//CPF
      If Empty(_cAuto) .OR. Empty(_cCond)
		 _cMsg += " O Cod. Autonomo ou a Cond. Pag. não preenchido no cadastrado de Forn.: "+_cCodTransp+_cLojaTransp
	  EndIf 
   EndIf

   //_cCodVeic   := ""
   
   DA4->(Dbsetorder(3))
   If Empty(_cCpfMotor) 
      _cMsg += " O CPF do motorista precisa ser preenchido. "
   ElseIf ! DA4->(DbSeek(xFilial("DA4")+U_ItKey(_cCpfMotor,"DA4_CGC"))) 
      _cMsg += " O CPF do motorista não está cadastrado.  "
   Else
      _cCpfMotor := U_ItKey(_cCpfMotor,"DA4_CGC") 
   EndIf

   //=========================================================================================
   // Valida código do Motorista
   //=========================================================================================
   If Empty(_cCodMotor)
      _cMsg += " Código do motorista não preenchido ou não localizado. "
   EndIf

   //==================================================================================
   // Verifica pedido bonificação bloqueado e PV vinculados
   //==================================================================================
   aP1Vinculados:={}
   aP2Vinculados:={}

   SC5->(Dbsetorder(1))
   For _nI := 1 To Len( _aPedJSon) 
       If SC5->(DbSeek(_cFilial+U_ItKey(_aPedJSon[_nI,1],"C5_NUM")))
          If SC5->C5_I_OPER = '10' .AND. (SC5->C5_I_BLOQ == "B" .OR. SC5->C5_I_BLOQ == "R")
			 _cMsg += "Pedido de bonificação sem liberação - " + SC5->C5_NUM + " "
		  EndIf

		  AADD(aP1Vinculados,SC5->C5_NUM)
		  IF !Empty(SC5->C5_I_PEVIN)
             Aadd(aP2Vinculados,{SC5->C5_NUM,SC5->C5_I_PEVIN})
		  EndIf

		  //_aPedJSon[_nI,3] := SC5->C5_I_TIPCA // Grava o tipo de carga. 1 = Paletizada , 2=Batida // é gravado na montagem do array _aPedJSon.

       EndIf
   Next

   cFaltaPVinculado:=""
   For _nI := 1 To LEN(aP2Vinculados)
	   If Ascan(aP1Vinculados, aP2Vinculados[_nI,2]) = 0
		  cFaltaPVinculado+=" PV "+aP2Vinculados[_nI,1]+" na carga sem o PV Vinculado "+aP2Vinculados[_nI,2]+", "
	   EndIf
   Next

   If ! Empty(cFaltaPVinculado)
      cFaltaPVinculado:=LEFT(cFaltaPVinculado,LEN(cFaltaPVinculado)-2)
	  _cMsg += cFaltaPVinculado
   EndIf

   If ! Empty(_cMsg)
      disarmtransaction()
      Break
   EndIf

   //======================================================================
   // Faz a leitura dos produtos e quantidades enviadas no JSon.
   //======================================================================
   Begin Transaction 

      If Empty(_cMsg) .And. Len(_aPedJSon) > 0 
         _aItensPV := {}
	     _lQtdDif   := .F.
         For _nI := 1 To Len(_aPedJSon)
             _aItemJson := _aPedJSon[_nI,7]
		  
		     For _nJ := 1 To Len(_aItemJson)
		         _aProdutos := _aItemJson[_nJ]
			                 //  1=Filial,2=Numero PV     , 3=Codigo Produto                    , 4=Quantidade            ,5=Item ,6=Mesclar            ,7=Ação     ,8=Unid.Med 
			     Aadd(_aItensPV,{_cFilial,_aPedJSon[_nI,1], AllTrim(_aProdutos["codigoProduto"]), _aProdutos["quantidade"],""     ,_aProdutos["mesclar"],"REJEITAR" ,"" })
             Next 

             //==================================================================
	         // Verifica se há diferenças no itens.
	         //==================================================================
	         SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO 
	         SC6->(MsSeek(_cFilial+_aPedJSon[_nI,1]))
             Do While ! SC6->(Eof()) .And. SC6->( C6_FILIAL+C6_NUM) == _cFilial+_aPedJSon[_nI,1]
		        _nQtdItem := 0

			    If SC6->C6_UNSVEN == 0 // Não há segunda unidade de medida
                   _nQtdItem := SC6->C6_QTDVEN
                   _cUndMed := "2"
                Else
                   If SC6->C6_UM == "KG" .And. SB1->B1_I_PCCX <> 0
                      _nQtdItem := SC6->C6_QTDVEN
                      _cUndMed := "2"
                   Else
                      _nQtdItem := SC6->C6_UNSVEN
                      _cUndMed  := "1"
                   EndIf
                EndIf
                _nX := Ascan(_aItensPV,{|x| x[2] == SC6->C6_NUM .And. x[3] == AllTrim(SC6->C6_PRODUTO)})

                If _nX > 0 
                   _aItensPV[_nX,5] := SC6->C6_ITEM
			       _aItensPV[_nX,8] := _cUndMed

				   If _aItensPV[_nX,4] == 0 .And. ! _aItensPV[_nX,6]   // _aItensPV[_nX,6] = False = MESCLAR
                      _aItensPV[_nX,7] := "EXCLUIR"
				      _lQtdDif := .T.
				   ElseIf _aItensPV[_nX,4] == 0 .And. _aItensPV[_nX,6] // _aItensPV[_nX,6] = False = MESCLAR
                      _aItensPV[_nX,7] := "DESMEMBRAR"
				      _lQtdDif := .T.
				   ElseIf _aItensPV[_nX,4] < _nQtdItem .And. _aItensPV[_nX,6]   // _aItensPV[_nX,6] = True = MESCLAR
                      _aItensPV[_nX,7] := "DESMEMBRAR"
				      _lQtdDif := .T.
				   ElseIf _aItensPV[_nX,4] < _nQtdItem .And. ! _aItensPV[_nX,6] // _aItensPV[_nX,6] = False = MESCLAR
                      _aItensPV[_nX,7] := "ALTERAR"  
				      _lQtdDif := .T.
				   ElseIf _aItensPV[_nX,4] > _nQtdItem  // _aItensPV[_nX,6] = False = MESCLAR
				      _aItensPV[_nX,7] := "ALTERAR"  
				      _lQtdDif := .T.
				   Else 
				      _aItensPV[_nX,7] := "ITEM_OK"  
				   EndIf 
                Else
			                      //  1=Filial,2=Numero PV, 3=Codigo Produto, 4=Quantidade  ,5=Item        ,6=Mesclar ,7=Ação  
			       Aadd(_aItensPV,{SC6->C6_FILIAL,SC6->C6_NUM, SC6->C6_PRODUTO , _nQtdItem , SC6->C6_ITEM ,.F.       ,"EXCLUIR", _cUndMed })
			       _lQtdDif := .T.
			    EndIf 

                SC6->(DbSkip())
	         EndDo 
         Next

         _nX := Ascan(_aItensPV,{|x| x[7] == "REJEITAR" })
	     If _nX > 0
            _cMsg += " Existem itens na Carga do TMS que não existem no Pedido de Vendas. "
	     EndIf 

	     If Empty(_cMsg) .And. _lQtdDif
            //=================================================================
		    // Roda a Rotina de Alteração / Desmembramento de Pedido de Vendas
		    //=================================================================
		    _aRetDesme :=  U_AOMS085B(_aItensPV)
		    If ! _aRetDesme[1] // Não foi possível alterar ou Desmembrar o Pedido de Vendas
               _cMsg += _aRetDesme[2]  // Mensagem de Erro no Processo de Alteração ou Desmembramento.
		    EndIf 
	     EndIf 
      EndIf 

      If ! Empty(_cMsg)
         Disarmtransaction()
         Break
      EndIf

      //===================================================================================
      // Realiza a liberação dos pedidos de vendas se passar no teste de crédito e estoque
      //===================================================================================
      If ! _lAteracao
	     _cChavePesq := ""
	     aJaProces  := {}
	     _cPedidos := ""

         //========================================================================================
         // Este trecho valida apenas o crédito dos pedidos de vendas através da função AOMS085S()
         //========================================================================================
         _cTextoCred := ""
			
         SC5->(Dbsetorder(1))
	     For _nI := 1 To Len(_aPedJSon)
             If SC5->(DbSeek(_cFilial+U_ItKey(_aPedJSon[_nI,1],"C5_NUM"))) .and. SC6->(DbSeek(_cFilial+U_ItKey(_aPedJSon[_nI,1],"C5_NUM")))
			    _aAprovacao := AOMS085S()     // Verifica as aprovações de credito.
			    _lAprov     := _aAprovacao[1] // True = Credito aprovado / False = Credito reejeitadao
			    _cTextoRet  := _aAprovacao[2] // Mensagem de retorno.
			    If ! _lAprov
				   _cTextoCred += _cTextoRet + " ### " // " Erro na liberação de crédito do Pedido de Vendas: "+AllTrim(SC5->C5_NUM)

				   SC5->(RecLock("SC5",.F.))
				   SC5->C5_I_BLCRE	:= "B"
				   SC5->C5_I_DTAVA := DATE()
				   SC5->C5_I_HRAVA := TIME()
				   SC5->C5_I_USRAV := cusername
				   SC5->C5_I_MOTBL := _cTextoRet
				   SC5->(MsUnLock())
			    EndIf
		     EndIf
	     Next
	
         SC6->(Dbsetorder(1))
		 SC5->(Dbsetorder(1))
		 SC9->(Dbsetorder(1))
		 SA1->(Dbsetorder(1))
		 SC5->(Dbsetorder(1))
		 SB2->(Dbsetorder(1))
		 
		 For _nI := 1 To Len(_aPedJSon)
		     // Monta valor total do pedido
			 ntotped := 0

			 SC6->(Dbsetorder(1))
			 If SC6->(DbSeek(_cFilial+U_ItKey(_aPedJSon[_nI,1],"C5_NUM")))
				Do while SC6->C6_FILIAL + SC6->C6_NUM == cFilial+U_ItKey(_aPedJSon[_nI,1],"C5_NUM")
				   ntotped += SC6->C6_VALOR
                   //========= Faz a somatória do peso liquido
                   _nPesoSb1 := Posicione('SB1',1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_PESO")
                   _nPesoLiq += (SC6->C6_QTDVEN * _nPesoSb1)

				   SC6->( Dbskip())
				Enddo
			 EndIf

			 SC5->(Dbsetorder(1))
			 If SC5->(DbSeek(_cFilial+U_ItKey(_aPedJSon[_nI,1],"C5_NUM"))) .and. SC6->(DbSeek(_cFilial+U_ItKey(_aPedJSon[_nI,1],"C5_NUM")))
				_aAprovacao := AOMS085S()     // Verifica as aprovações de credito.
				_lAprov     := _aAprovacao[1] // True = Credito aprovado / False = Credito reejeitadao
				_cTextoRet  := _aAprovacao[2] // Mensagem de retorno.
				_cChavePesq := ""
				_aJaProces  := {}

				//========================================================================================
				// Se a função AOMS085S() retornar verdadeiro, este trecho realiza várias validação.
				// valida crédito, estoque, etc. Utilizando outros métodos.
				//========================================================================================
				If Reclock("SC5",.F.) .and. _lAprov // AOMS085S()
				   SC6->(Dbsetorder(1))
				   SC6->(DbSeek(_cFilial+U_ItKey(_aPedJSon[_nI,1],"C5_NUM")))
				   Do While !(SC6->(Eof())) .And. SC6->(C6_FILIAL+C6_NUM) == _cFilial+U_ItKey(_aPedJSon[_nI,1],"C5_NUM")
					  _cChavePesq := SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM  // Para evitar que o mesmo item de pedido seja processado mais de uma vez
					  If Ascan(_aJaProces,_cChavePesq) == 0
					     Aadd(_aJaProces,_cChavePesq)
					  Else
					     SC6->(DbSkip())
					     Loop
					  EndIf

					  SC9->(Dbsetorder(1))
					  If !(SC9->(DbSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))) .OR. !EMPTY(SC9->C9_BLEST)  // verifica estoque se não tem liberação válida ainda
					     //Verifica se pode gravar registros do C6, A1 e B2
						 _lflock := .F.

						If !SC6->(MsRLock(SC6->(RECNO())))
						   _cmsg += "No momento este Pedido de Vendas está sendo utilizado por outro usuário e não pode ser manipulado. Tente integrar novamente mais tarde: " + SC6->C6_NUM + "/" + SC6->C6_ITEM
						   _lflock := .T.
						EndIf

						SA1->(Dbsetorder(1))
						SA1->(Dbseek(xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))

						SB2->(Dbsetorder(1))
						SB2->(Dbseek(SC6->C6_FILIAL+SC6->C6_PRODUTO+SC6->C6_LOCAL))

						If ! _lflock .and. !SB2->(MsRLock(SB2->(RECNO())))
						   _cmsg += "No momento este estoque está sendo utilizado por outro usuário e não pode ser manipulado. Tente integrar novamente mais tarde: " + SB2->B2_COD + "/" + SB2->B2_LOCAL
						   _lflock := .T.
						EndIf

						If _lflock .and. !Empty(_cMsg)  //Break exclusivo para falha de lock dos itens
						   disarmtransaction()
						   //	::U_STATUS := "<SUCESSO>FALSE</SUCESSO>" + _cMsg
						   Break
						EndIf

						SC9->(Dbsetorder(1))
						If (SC9->(DbSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))) .AND. !EMPTY(SC9->C9_BLEST)
						   SC9->(A460Estorna()) //Se já tem sc9 com bloqueio de estoque estorna a liberação
						EndIf

						_nQtdLib := MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN)//LIBERA PEDIDO

						//Analise da liberação de estoque
						_lestoque := .F.

						SC9->(Dbsetorder(1))
						If SC9->(DbSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))
                           If SC9->C9_QTDLIB <> SC6->C6_QTDVEN
							  _cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". A quantidade liberada diverge da quantidade do item: " + SC6->C6_ITEM + " - Produto: " +;
							  SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
						   ElseIf !Empty(SC9->C9_BLEST)
							  _nQtdEst := 0
							  If SB2->(DbSeek(SC6->C6_FILIAL+SC6->C6_PRODUTO+SC6->C6_LOCAL))
							     _nQtdEst := (SB2->B2_QATU - SB2->B2_QEMP - SB2->B2_QEMPN - SB2->B2_RESERVA - SB2->B2_QACLASS)
							  EndIf

							  _lBloqEst   := .T.
							  _cTextoMsg := " Erro na liberação do Estoque do PV: "+AllTrim(SC6->C6_NUM)+". Item: " + SC6->C6_ITEM + " - " +;
											AllTrim(SC6->C6_PRODUTO) + ". Qtd PV: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+" "+SC6->C6_UM+". Armazém: " + SC6->C6_LOCAL +;
											". Qtd Estoque: " + AllTrim(Str(_nQtdEst,18,5)) + " " + SC6->C6_UM

							  If !(_cTextoMsg $ _cMsg)
								 _cMsg += _cTextoMsg
							  EndIf
						   ElseIf !Empty(SC9->C9_BLCRED)
							  _cPedidos += " Nr.Pedido V.: " + AllTrim(SC6->C6_NUM) + " - Item: " + SC6->C6_ITEM + " - Produto: "+AllTrim(SC6->C6_PRODUTO) + " - Qtd: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+". ### "
						   ElseIf !Empty(SC9->C9_CARGA)
							  _cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". Bloqueio de carga para o item: " + SC6->C6_ITEM + " - Produto: " +;
									   SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
						   ElseIf !Empty(SC9->C9_NFISCAL)
							  _cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". Bloqueio de nota fiscal para o item: " + SC6->C6_ITEM + " - Produto: " +;
									   SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
						   Else
							  _lestoque := .T.
						   EndIf
						Else
						   _cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". Não foi gerado registro de liberação " + SC6->C6_ITEM + " - Produto: " +;
									SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
						EndIf

						If _lestoque
						   Aadd(_apedidos,SC6->C6_NUM)
						   MsUnLockAll()
						   Reclock("SC5",.F.)
						   SC5->C5_LIBEROK := "S"
						   MsUnLockAll()
						EndIf

					 ElseIf SC9->(DbSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))

						 If SC9->C9_QTDLIB <> SC6->C6_QTDVEN
						    _cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". A quantidade liberada diverge da quantidade do item: " + SC6->C6_ITEM + " - Produto: " +;
									SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
						 ElseIf !Empty(SC9->C9_BLEST)
						    _cTextoMsg := " Erro na liberação do Estoque do PV: "+AllTrim(SC6->C6_NUM)+". Item: " + SC6->C6_ITEM + " - " +;
   										 AllTrim(SC6->C6_PRODUTO) + ". Qtd PV: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+" "+SC6->C6_UM+". Armazém: " + SC6->C6_LOCAL +;
										 ". Qtd Estoque: " + AllTrim(Str(_nQtdEst,18,5)) + " " + SC6->C6_UM
						    _lBloqEst   := .T.
						    If !(_cTextoMsg $ _cMsg)
							  _cMsg += _cTextoMsg
						    EndIf
						 ElseIf !Empty(SC9->C9_BLCRED)
                            _cPedidos += " Nr.Pedido V.: " + AllTrim(SC6->C6_NUM) + " - Item: " + SC6->C6_ITEM + " - Produto: "+AllTrim(SC6->C6_PRODUTO) + " - Qtd: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+". ### "
						 ElseIf !Empty(SC9->C9_CARGA)
						    _cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". Bloqueio de carga para o item: " + SC6->C6_ITEM + " - Produto: " +;
						            SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
						 ElseIf !Empty(SC9->C9_NFISCAL)
						    _cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". Bloqueio de nota fiscal para o item: " + SC6->C6_ITEM + " - Produto: " +;
									SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
						 Else
						    Aadd(_apedidos,SC6->C6_NUM)
						    MsUnLockAll()
						    Reclock("SC5",.F.)
						    SC5->C5_LIBEROK := "S"
						    MsUnLockAll()
						 EndIf
					  Else
						 _cMsg += " Erro na liberação do Pedido de Vendas: "+AllTrim(SC6->C6_NUM)+". Não foi gerado registro de liberação " + SC6->C6_ITEM + " - Produto: " +;
					             SC6->C6_PRODUTO + " Quantidade: "+ AllTrim(Str(SC6->C6_QTDVEN,18,5))+"."
					  EndIf

					  SC6->(DbSkip())
				   EndDo

				   If ! Empty(_cPedidos) .And. ! _cPedidos $ _cMsg
					  _cMsg += " Erro na liberação do Pedido de Vendas. Bloqueio por Crédito: " + _cPedidos
				   EndIf

				   If !Empty(_cMsg)
				      Disarmtransaction()
					  MsUnLockAll()
					  Exit
				   EndIf
			    Else
				   //========================================================================================
				   // Se a função AOMS085S() retornar falso na validação do crédito, volta toda a transação
				   // das tabelas e retorna a(s) mensagem(ns) de rejeição.
				   //========================================================================================

				   _cMsg += _cTextoCred

				   MsUnLockAll()
				   Disarmtransaction()

				   Exit
                EndIf

			    If ! Empty(_cMsg)
				   MsUnLockAll()
				   DisarmTransaction()
			  	   Exit
			    EndIf
			 Else
			    _cMsg += " Erro em localizar o Pedido de Vendas: "+AllTrim(SC5->C5_NUM)
			    Exit
		     EndIf

		 	 MsUnLockAll()
	     Next
      EndIf

      If ! Empty(_cMsg)
         Disarmtransaction()
	     Break
      EndIf

      DA4->(DbSetOrder(3)) // DA4_FILIAL+DA4_CGC  // CPF MOTORISTA
      SA2->(DbSetOrder(3)) // A2_FILIAL+A2_CGC
      DAK->(DbOrderNickName("CODCAR_RDC"))

      //===================================================================================
      // Cria as cargas e grava os dados das tabelas DAK e DAI normalmente.
      //===================================================================================
      If !_lAteracao
		 _cCodigo := U_AOMS089(.F.,"DAK","DAK_COD",.F.)
		 DAK->(Reclock("DAK",.T.))
	     DAK->DAK_FILIAL := _cFilial // Filial do Embarcador
	     DAK->DAK_COD    := _cCodigo // GetSx8Num("DAK","DAK_COD")
         DAK->DAK_SEQCAR := "01"     // sempre 01
		 DAK->DAK_ROTEIR := ""       // sempre vazio
		 DAK->DAK_FEZNF  := "2"              // sempre 2
		 DAK->DAK_DATA   := Date()           // Date()
		 DAK->DAK_HORA   := Time()           // Time()
		 DAK->DAK_JUNTOU := "MANUAL"         // sempre MANUAL
		 DAK->DAK_ACECAR := "2"              // sempre 2
		 DAK->DAK_ACEVAS := "2"              // sempre 2
		 DAK->DAK_ACEFIN := "2"              // sempre 2
		 DAK->DAK_AJUDA1 := ""               // sempre vazio
		 DAK->DAK_AJUDA2 := ""               // sempre vazio
		 DAK->DAK_AJUDA3 := ""               // sempre vazio
		 DAK->DAK_DTACCA := ctod("  /  /  ") // sempre vazio
		 DAK->DAK_OK     := ""               // sempre vazio
		 DAK->DAK_FLGUNI := "2"              // sempre 2
		 DAK->DAK_DATENT := ctod("  /  /  ") // sempre vazio
		 DAK->DAK_BLWMS  := ""               // sempre vazio
		 DAK->DAK_BLQCAR := ""               // sempre vazio
		 DAK->DAK_HRSTAR := "08:00"          // sempre 08:00
		 DAK->DAK_I_FRET := 0                // sempre 0
		 DAK->DAK_ROTEIR := '999999'
		 DAK->DAK_I_REDP := ""               // sempre vazio
		 DAK->DAK_I_RELO := ""               // sempre vazio
		 DAK->DAK_I_OPER := ""               // sempre vazio
		 DAK->DAK_I_OPLO := ""               // sempre vazio
		 DAK->DAK_I_OBS  := _cObsCarga       // "Importado via TMS Multiembarcador. Numero Carga TMS Multiembarcador: " + _cNrCarga // U_CARGA:CODIGO // "Importado via RDC " + número da carga do RDC
		 DAK->DAK_I_VRPE := 0                // Sempre 0
		 DAK->DAK_I_CARG := _cNrCarga        // U_CARGA:CODIGO   // Número da carga do RDC
		 DAK->DAK_I_FRDC := _cFilial         // U_CARGA:CODFIL   // Codigo de filial do RDC.
	  Else
		 DAK->(Reclock("DAK",.F.))
		 _cCodigo := DAK->DAK_COD
	  EndIf

      DAK->DAK_I_INCC:= "N"            //Preencher com N
	  DAK->DAK_I_INCF:= "N"            //Preencher com N
      DAK->DAK_I_PREC := "2"  // Não é pré carga.

	  DAK->DAK_CAMINH := _cCodVeic //  DA3->DA3_COD // DA3_COD para  DA3_PLACA igual placa do xml
	  DAK->DAK_MOTORI := _cCodMotor // DA4->DA4_COD // DA4_COD para DA4_CGC igual ao cpf do motorista do JSon
	  DAK->DAK_I_CODV := _cCodVTms  // Código do Modelo Veicular do TMS.

      DAK->DAK_PESO   := If(_lPesoLiq,_nPesoLiq ,_nPesoBrut) // If(_lPesoLiq,U_CARGA:PESOL,U_CARGA:PESOB)     // PESOB ou PESOL ver parâmetro // Soma  de dai_peso
	  DAK->DAK_VALOR  := _nValorTotal   // U_CARGA:VALOR    // VALOR // soma de c6_valor
	  DAK->DAK_I_FRET := _nValFrete     //U_CARGA:FRETE    // VALOR DO FRETE.
	  DAK->DAK_I_TPFR := If(Len(AllTrim(_cCnpjTran))< 14,"1","2")  //If(Len(AllTrim(U_CARGA:CNPJTRA))< 14,"1","2")  // 1="Autonomo";2="PJ-Transportadora" (escolhe se cpf no transportador é 1, se é cgc no transportador é 2)
	  DAK->DAK_IDENT  := ""               // sempre vazio
	  DAK->DAK_TRANSP := _cCnpjTran // _cCodTransp // SA2->A2_COD      // SA2->A2_COD que tenha a2_cgc  igual a cnpj de transportadora do xml
	  DAK->DAK_I_VRPE := _nValPedag  // U_CARGA:PEDAGIO

	  _cMailUsrCarga := Posicione("ZZL",5,xfilial("ZZL")+_cCodUsuario,"ZZL_EMAIL") //Posicione("ZZL",5,xfilial("ZZL")+AllTrim(Str(U_CARGA:USUCAD,_nTamCodUser)),"ZZL_EMAIL") // E-mail do usuário que criou a carga utilizado na rotina de envio de e-mail da carga.
	  If Empty(_cMailUsrCarga)
	     _cMailUsrCarga := ""
	  EndIf

	  DAK->DAK_I_RECR := AllTrim(_cProtCarga)  //AllTrim(Str(U_CARGA:RECNUM,10)) // Grava o Recno RDC na Tabela DAK

      If DAK->(FieldPos("DAK_I_RATF")) > 0
         DAK->DAK_I_RATF := "N"  
	  EndIf 


	  DAK->DAK_USERGA := U_RetLgiLga(_cCodUsuario) // _cid - id de usuário do Protheus
	  DAK->DAK_USERGI := U_RetLgiLga(_cCodUsuario) // _cid - id de usuário do Protheus

	  //===================================================================================
	  // Gravação dos Itens da Carga.
	  //===================================================================================
	  _nCapacVolum  := 0
	  _aQtdClientes := {}
	  _lTemPallet   := .F.
	  _lTrocaNF     := .F.
	  _cFilFatTrocaNF:=""

	  _cSeqDAI   := ""
	  _nRecnoSC5 := 0 

	  DAI->(DbSetOrder(4)) // DAI_FILIAL+DAI_PEDIDO+DAI_COD+DAI_SEQCAR
	  SC5->(Dbsetorder(1))

	  For _nI := 1 To Len(_aPedJSon)
          //=======================================================================
		  // _aPedJSon[_nI, 1] == Numero do Pedido de Vendas
		  // _aPedJSon[_nI, 2] == Cnpj do Embarcador
		  // _aPedJSon[_nI, 3] == Tipo de Carga: '1' = Paletizzada, '2' = Estivada
		  // _aPedJSon[_nI, 4] == Numero da Carga   
		  // _aPedJSon[_nI, 5] == Ordem de Entrega  
          //=======================================================================

		  _cPedido := U_ItKey(_aPedJSon[_nI,1],"C5_NUM") // PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," ")
 
          If !(SC5->(DbSeek(_cFilial + _cPedido))) // Posiciona no numero de pedido da SC5
			 _cMsg := "Falha ao gravar itens da carga " + _cFilial + _cPedido
			 MsUnLockAll()
			 DisarmTransaction()
			 Break
		  EndIf
	      IF EMPTY(_cFilFatTrocaNF) .AND. SC5->C5_I_TRCNF = 'S' .AND. !EMPTY(SC5->C5_I_FILFT) .AND. !EMPTY(SC5->C5_I_FLFNC) .AND.;
	                                           SC5->C5_I_FILFT # SC5->C5_I_FLFNC .AND. EMPTY(SC5->C5_I_PDPR+SC5->C5_I_PDFT)//Pedidos de Troca Nota
	         _cFilFatTrocaNF:= SC5->C5_I_FILFT
	      ENDIF

		  If !_lAteracao
		     DAI->(RecLock("DAI",.T.))
			 DAI->DAI_FILIAL := _cFilial             // Filial do Embarcador
			 DAI->DAI_COD    := _cCodigo             // DAK->DAK_COD
		     DAI->DAI_SEQCAR := '01' // StrZero(_aPedJSon[_nI, 5],2) // Ordem de Entrega   // OrdemEntrega// "01"                 // sempre 01  
			 DAI->DAI_PEDIDO := _cPedido             // U_CARGA:ITENS[_nI]:PEDIDO // pedido indicado no xml
			 DAI->DAI_CLIENT := SC5->C5_CLIENTE      // c5_cliente
			 DAI->DAI_LOJA   := SC5->C5_LOJACLI      // c5_loja
			 DAI->DAI_VENDED := ""                   // sempre vazio
			 DAI->DAI_CAPVOL := 0          // sempre 0
			 DAI->DAI_PERCUR := "999999"   // sempre 999999
			 DAI->DAI_ROTA   := "999999"   // sempre 999999
			 DAI->DAI_ROTEIR := "999999"   // sempre 999999
			 DAI->DAI_SEQROT := ""         // sempre vazio
			 DAI->DAI_NFISCA := ""         // sempre vazio
			 DAI->DAI_SERIE  := ""         // sempre vazio
			 DAI->DAI_DATA   := Date()     // date()
			 DAI->DAI_HORA   := Time()     // Time()
			 DAI->DAI_CARORI := "CARGA"    // sempre CARGA
			 DAI->DAI_REMITO := ""         // sempre vazio
			 DAI->DAI_SERREM := ""         // sempre vazio
			 DAI->DAI_DTCHEG := Date()     // date()
			 DAI->DAI_CHEGAD := "08:00"    // sempre 08:00
			 DAI->DAI_TMSERV := "0000:00"  // sempre 0000:00
			 DAI->DAI_DTSAID := Date()     // date()
			 DAI->DAI_I_FRET := 0          // sempre 0
			 DAI->DAI_VALFRE := 0          // sempre 0
			 DAI->DAI_FREAUT := 0          // sempre 0
			 DAI->DAI_I_REDP := "2"     // A2_COD cujo a2_cgc igual a campo de redespacho
			 DAI->DAI_I_TRED := ""
			 DAI->DAI_I_LTRE := ""
			 DAI->DAI_I_OPER := "2"     // A2_COD cujo a2_cgc igual a campo deoperador logistico
			 DAI->DAI_I_OPLO := ""
			 DAI->DAI_I_LOPL := ""
		  Else
		     DAI->(DbSeek(_cFilial+U_ItKey(_aPedJSon[_nI,1],"C5_NUM")))
		     DAI->(RecLock("DAI",.F.))
		  EndIf

          //===============================================// Remover este trecho. Solicitação do Alex. Já é gravado abaixo.
          //If SC5->C5_I_TRCNF == "S"                      
          //   DAK->DAK_I_TRNF := "C" 
          //   DAK->DAK_I_FITN := SC5->C5_I_FILFT 
          //   _lTrocaNF := .T.
		  //EndIf 
		  //===============================================

		  DAI->DAI_PESO   := If(_lPesoLiq,SC5->C5_PESOL, SC5->C5_I_PESBR) // c5_pesol ou c5_pesob de acordo com parâmetro
          //==========================================================================================
		  // Grava dados do transportador de redespacho
		  // Embutido workaround para quando vier igual o cnpj de op logistico e redespacho considerar
		  // como operador logistico
		  //==========================================================================================
		  //U_ItKey(_aPedJSon[_nI,1],"C5_NUM")
		  /*
		  If !(Empty(_aPedJSon[_nI,2]))  // .and. (U_CARGA:ITENS[_nI]:CNPJRE != U_CARGA:ITENS[_nI]:CNPJOP)
			 SA2->(Dbsetorder(3))
			 SA2->(DbSeek(xFilial("SA2")+U_ItKey(_aPedJSon[_nI,2],"A2_CGC")))
			 DAI->DAI_I_REDP := "1"     // A2_COD cujo a2_cgc igual a campo de redespacho
			 DAI->DAI_I_TRED := SA2->A2_COD
			 DAI->DAI_I_LTRE := SA2->A2_LOJA
		  	 
			 DAK->DAK_I_REDP := SA2->A2_COD // Grava na capa os dados do redespacho
			 DAK->DAK_I_RELO := SA2->A2_LOJA
		  Else
             DAI->DAI_I_REDP := "2"
			 DAI->DAI_I_TRED := ""
			 DAI->DAI_I_LTRE := ""
          EndIf
          */
		  
		  //==========================================================================================
		  // Grava dados do operador logistico.
		  //==========================================================================================
		  If ! Empty(_aPedJSon[_nI,2]) // U_CARGA:ITENS[_nI]:CNPJOP
		     SA2->(Dbsetorder(3)) // A2_FILIAL+A2_CGC
		     SA2->(DbSeek(xFilial("SA2")+U_ItKey(_aPedJSon[_nI,2],"A2_CGC")))

			 //===========================================================================
			 // O código do operador logístico deve seguir a classificação descrita no
			 // SA2. Primeiro o tipo T, Segundo o Tipo A, Terceiro o Tipo C.
			 // Caso nenhum dos tipos sejam localizados, obter o primeiro código e loja.
			 //===========================================================================
			 _cCodOperL  := SA2->A2_COD
			 _cLojaOperL := SA2->A2_LOJA

			 _cCodOpT  := ""
			 _cLojaOpT := ""
			 _cCodOpA  := ""
			 _cLojaOpA := ""
			 _cCodOpF  := ""
			 _cLojaOpF := ""

			 Do While ! SA2->(Eof()) .And. SA2->(A2_FILIAL+A2_CGC) == xFilial("SA2")+U_ItKey(_aPedJSon[_nI,2],"A2_CGC")
				If SA2->A2_I_CLASS == "T" .And. Empty(_cCodOpT)
			       _cCodOpT  := SA2->A2_COD
				   _cLojaOpT := SA2->A2_LOJA
				EndIf

				If SA2->A2_I_CLASS == "A" .And. Empty(_cCodOpA)
				   _cCodOpA  := SA2->A2_COD
				   _cLojaOpA := SA2->A2_LOJA
				EndIf

				If SA2->A2_I_CLASS == "F" .And. Empty(_cCodOpF)
				   _cCodOpF  := SA2->A2_COD
				   _cLojaOpF := SA2->A2_LOJA
				EndIf

				SA2->(DbSkip())
			 EndDo

			 If ! Empty(_cCodOpT)
				_cCodOperL  := _cCodOpT
				_cLojaOperL := _cLojaOpT
			 ElseIf ! Empty(_cCodOpA)
				_cCodOperL  := _cCodOpA
				_cLojaOperL := _cLojaOpA
			 ElseIf ! Empty(_cCodOpF)
				_cCodOperL  := _cCodOpF
				_cLojaOperL := _cLojaOpF
			 EndIf

			 DAI->DAI_I_OPER := "1"     // A2_COD cujo a2_cgc igual a campo deoperador logistico
			 DAI->DAI_I_OPLO := _cCodOperL  // SA2->A2_COD
			 DAI->DAI_I_LOPL := _cLojaOperL // SA2->A2_LOJA
             
			 DAK->DAK_I_OPER := _cCodOperL  // SA2->A2_COD // Grava na capa os dados do operador logistico.
			 DAK->DAK_I_OPLO := _cLojaOperL // SA2->A2_LOJA
		  EndIf

		  DAI->DAI_I_TIPC := _aPedJSon[_nI,3] // AllTrim(U_CARGA:ITENS[_nI]:TPCARG) // 1 = "Paletizada" / 2 = "Batida"  
		  DAI->DAI_I_QTPA := _nQtdPalet // quantidade de pallets indicada no xml 
		  If DAI->DAI_I_TIPC  $ TP_GERA_PALET .AND. DAI->DAI_I_QTPA # 0
			 _lTemPallet:=.T.
		  EndIf

		  _nCapacVolum += DAI->DAI_CAPVOL // Somatória da capacidade volumétrica do item.

		  _cChave  := DAI->( DAI_CLIENT + DAI_LOJA )
		  If DAI->DAI_I_OPER="1" .AND. !EMPTY(DAI->DAI_I_OPLO)
			 _cChave  := DAI->DAI_I_OPLO+DAI->DAI_I_LOPL
		  EndIf

		  If DAI->DAI_I_REDP="1" .AND. !EMPTY(DAI->DAI_I_TRED)
		     _cChave  := DAI->DAI_I_TRED+DAI->DAI_I_LTRE
		  EndIf

		  If !EMPTY(_cChave) .AND. AsCan(_aQtdClientes,_cChave) = 0
		     Aadd(_aQtdClientes,_cChave)// Contagem de clientes diferentes nos itens da carga.
		  EndIf

          If Valtype(_aPedJSon[_nI, 6]) = "N"
		     DAI->DAI_SEQUEN := StrZero(_aPedJSon[_nI, 6],6) // StrZero(_aPedJSon[_nI, 5],6)  // StrZero(_nI,6)  // StrZero(_nI:SEQUENCIA,6)  //StrZero(U_CARGA:ITENS[_nI]:SEQUENCIA,6) 
		  Else 
             DAI->DAI_SEQUEN := _aPedJSon[_nI, 6]
		  EndIf 

		  DAI->(MsUnLock())

          //===========================================================
		  // Incluir aqui a leitura da maior sequencia de integração
		  //===========================================================
	      If _cSeqDAI < DAI->DAI_SEQUEN
		     _cSeqDAI   := DAI->DAI_SEQUEN
	         _nRecnoSC5 := SC5->(Recno())              
		  EndIf 
          //===========================================================

		  SC9->(Dbsetorder(1))
		  If SC9->(Dbseek(DAI->DAI_FILIAL+DAI->DAI_PEDIDO))
			 Do While DAI->DAI_FILIAL == SC9->C9_FILIAL .AND. DAI->DAI_PEDIDO == SC9->C9_PEDIDO

				If Reclock("SC9",.F.)
				   SC9->C9_CARGA := DAK->DAK_COD
				   SC9->C9_SEQCAR := '01' // DAI->DAI_SEQCAR
				   SC9->C9_SEQENT := DAI->DAI_SEQUEN // DAI->DAI_SEQCAR 
				Else
				   _cMsg := "Falha ao reservar pedido " + DAI->DAI_PEDIDO
				   MsUnLockAll()
				   DisarmTransaction()
				   Break
				EndIf

				SC9->(Dbskip())
			 Enddo
	 	  Else
		     _cMsg := "Falha ao reservar pedido " + DAI->DAI_PEDIDO
		     MsUnLockAll()
	         DisarmTransaction()
		     Break
          EndIf
      Next

      //==================================================
	  // Gravar aqui os dados do ultimo destino da carga.
	  //==================================================
	  SC5->(DbGoTo(_nRecnoSC5))
	  DAK->DAK_I_UFDE := SC5->C5_I_EST   // UF de Destino
      DAK->DAK_I_CIDE := SC5->C5_I_CMUN  // Cidade de Destino.
      DAK->DAK_I_LEMB := SC5->C5_I_LOCEM // Local de Embarque

      //===================================================================================
      // Continuação capa Gravação dos Capa da Carga.
      //===================================================================================
      DAK->DAK_CAPVOL := _nCapacVolum       // soma de dai_capvol
      DAK->DAK_PTOENT := Len(_aQtdClientes) // contagem de clientes diferentes, dai_client+cai_loja

	  IF !EMPTY(_cFilFatTrocaNF)
	     DAK->DAK_I_TRNF:= "C"            //Preencher o campo com C (Tem troca nota e é filial de carregamento)
	     DAK->DAK_I_FITN:= _cFilFatTrocaNF//Filial de faturamento do troca nota (C5_I_FILFT Filial para onde os pedidos de faturamento foram transferidos)
	  ELSE
	     DAK->DAK_I_TRNF:= "N"         //Preencher o campo com N
	  ENDIF
	  DAK->DAK_I_INCC:= "N"            //Preencher com N
	  DAK->DAK_I_INCF:= "N"            //Preencher com N

	  If DAK->(FieldPos("DAK_I_TMS")) > 0 
	     DAK->DAK_I_TMS  := "M" // Indica que a carga foi criada pelo sistema TMS Multiembarcador 
	  EndIf 
      DAK->(MsUnLock())
   
      _nRegAtu := DAK->(Recno())

	  //===================================================================================
	  // Realiza a efetivação da carga no Protheus.
	  //===================================================================================
	  _cMsgEfetiva := ""
 	  _lEnviaEmail := .F.

      If _lTemPallet .OR. DAK->DAK_I_TPFR == "1"//Se tem pallet ou se é autonomo
	     If LEN(_aItensPallet) > 0  //.AND.  !(U_AOMS085Y( {} , _aItensPallet , @_cMsgEfetiva ))
	        _cMsg := _cMsgEfetiva
			MsUnLockAll()
			DisarmTransaction()
			Break
		 EndIf
		 
		 _ccoddak := DAK->DAK_COD

         //=============================================================================================
         // Rotina de enfetivação da Pré-Carga. Apenas cria o pedido de pallet passando o ultimo 
		 // parâmetro como .T. 
		 // DAK->DAK_I_PREC == "1" // Pré-Carga = Ao rodar a rotina a carga é efetivada. 
		 //=============================================================================================
         DAK->(RecLock("DAK", .F.))
		 DAK->DAK_I_PREC := "1" // Deixar como Pré-Carga para geração de Pallets. A função U_OM20MNUP(,,,.T.) Efetiva a pré-carga.
		 DAK->(MsUnLock())
		
		 U_OM20MNUP(,,,.T.)  

		 //Reposiciona DAK para ver se geração de pallet não causou problemas na leitura
		 //Acontece quando não tem saldo de pallets e dá problema na liberação do pedido gerado
		 DAK->(DbGoto(_nRegAtu))

		 If !(DAK->DAK_COD == _ccoddak)
			_cMsg := "Falha na geração de pallets, verifique o saldo de pallets " + _cMsgEfetiva
			MsUnLockAll()
			DisarmTransaction()
			Break
		 EndIf
	  Else
	     _lEnviaEmail := .T.
	     If ZFU->(FIELDPOS("ZFU_ENMAIL")) = 0
		    U_OM200Email(.F.,Nil,.T.,.T.,.T.)//_lEstorno,_aCargas,_lEnviaDireto,_lScheduller,_lMarcaEnvio
		 EndIf
	  EndIf

	  If !Empty(_cMsgEfetiva)
	     _lEnviaEmail := .F.
		 _cMsg := _cMsgEfetiva
		 MsUnLockAll()
		 DisarmTransaction()
		 Break
	  Else
	     _lEnviaEmail := .T.
	  EndIf
	  
	  DAK->(DbGoto(_nRegAtu))
	  DAK->(RecLock("DAK",.F.))
	  DAK->DAK_I_PREC := "2"
	  DAK->DAK_USERGA := U_RetLgiLga(_cCodUsuario) // _cid - id de usuário do Protheus
	  DAK->DAK_USERGI := U_RetLgiLga(_cCodUsuario) // _cid - id de usuário do Protheus
	  DAK->(MsUnLock())
	 
	  _cMsgOk := " Carga TMS MultiEmbarcador: "+AllTrim(_cNrCarga)+", integrada com sucesso! "
	  _cMsgRDC := " Numero de Carga Protheus: NRSOLI=" + _cCodigo
	  ConfirmSX8()

	  DAK->(RecLock("DAK",.F.))
	  DAK->DAK_USERGA := U_RetLgiLga(_cCodUsuario) // _cid - id de usuário do Protheus
	  DAK->DAK_USERGI := U_RetLgiLga(_cCodUsuario) // _cid - id de usuário do Protheus
	  DAK->(MsUnLock())
      
      //===========================================================================
      // Atualiza tabela SC5.  _aPedJSon[_nI,1]
      //===========================================================================
      If Empty(_cMsg) // Integração com sucesso.
	     _nTamPedido := TAMSX3("C5_NUM")[1]
 	     For _nI := 1 To Len(_aPedJSon)
		     _cPedido := U_ItKey(_aPedJSon[_nI,1],"C5_NUM")  //PadR(U_CARGA:ITENS[_nI]:PEDIDO,_nTamPedido," ")
		     SC5->(Dbsetorder(1))
		     If (SC5->(DbSeek(_cFilial + _cPedido))) // Posiciona no numero de pedido da SC5
			    _ddataant := SC5->C5_I_DTENT
		        _aLogSC5 := U_ITIniLog( 'SC5')
		        SC5->(RecLock("SC5",.F.))
			    //SC5->C5_I_OBCOP := U_CARGA:ITENS[_nI]:OBSCPA  // Observação da condição de pagamento
			    //SC5->C5_I_OBPED := "Carga Importada via TMS Multiembarcador. Numero Carga TMS Multiembarcador: " + _cNrCarga  // U_CARGA:ITENS[_nI]:OBSPVE  // Observação do Pedido de Vendas
			    //SC5->C5_MENNOTA := U_CARGA:ITENS[_nI]:OBSNFE  // Observação da Nota Fiscal
			    //SC5->C5_I_DTENT := Ctod(U_CARGA:ITENS[_nI]:DTPREV) // Data de Previsão de Entrega
			    //SC5->C5_FECENT  := Ctod(U_CARGA:ITENS[_nI]:DTPREV) // Data de Previsão de Entrega
			    SC5->(MsUnlock())

                //Grava monitor de pedido de vendas
			    If SC5->C5_I_DTENT != _ddataant
			       _cJUSCOD := "007"//Alterado Data de Entrega
			       _cCOMENT := "Data de entrega modificada de " + dtoc(_ddataant) + " para " + dtoc(SC5->C5_I_DTENT) + "  via inclusão de Carga TMS MultiEmbarcador."
			       _cENCERR := ""
			       __cUserID := _cCodUsuario
			       U_GrvMonitor(,,_cJUSCOD,_cCOMENT,_cENCERR,_ddataant,SC5->C5_I_DTENT,_ddataant)
			    Endif
                    
			    //Grava log de alteração de tabela
		 	    U_ITGrvLog( _aLogSC5 , "SC5" , 1 , SC5->( C5_FILIAL + C5_NUM ) ,"A" , _cCodUsuario , date() , time() )
		        _cmotivs := "  " //Zera variável pública de motivo de corte para não repetir uso por engano
		     EndIf
	     Next
      EndIf

   End Transaction

End Sequence

//==============================================================================================================================                 
// Se os registros das tabelas DAK e DAI já foram criados, mas ocorreu erro na 
// integração com o RDC e a integração foi reenviada.
// Atualiza os dados da tabela DAK e DAI com os novos RECNOS RDC e o novo numero de
// Viagem e finaliza a integração.
//                 //    Renco DAK       Recno DAI          DAK_I_RECR                        DAK_I_CARG
// Aadd(_aCargasAtu, {DAK->(Recno()), DAI->(Recno()), AllTrim(Str(U_CARGA:RECNUM,10)), Padr(U_CARGA:CODIGO,_nTamCod," ")})
//==============================================================================================================================                 
If Len(_aCargasAtu) > 0  .And. _lPedOk .and. Empty(_cMsg)
   Begin Transaction
	  DAK->(DbGoTo(_aCargasAtu[1,1]))
	  DAK->(Reclock("DAK",.F.))
	  DAK->DAK_I_RECR := AllTrim(_cProtCarga) // AllTrim(Str(U_CARGA:RECNUM,10))
	  DAK->DAK_I_CARG := _cNrCarga // U_CARGA:CODIGO
	  DAK->(MsUnLock())
   End Transaction

   _cMsgOk := " Efetivação de Carga TMS MultiEmbarcador: "+AllTrim(U_CARGA:CODIGO)+", integrada com sucesso! "
   _cMsgRDC := " Numero de Carga Protheus: NRSOLI=" + DAK->DAK_COD
   
EndIf

If Empty(_cMsg)
	U_AOMS140K()//Executa alteração da carga
EndIf

//===========================================================================
// Retorna sucesso ou erro na integração.
//===========================================================================
If Empty(_cMsg)
   //===============================================================
   // Calcula o tempo total gasto no processamento.
   //===============================================================
   _cTempoFin := Time()
   _nTempoTot := ELAPTIME( _cTempoIni, _cTempoFin )
   _cTextoTempo := " [Tempo de Processamento: "+AllTrim(_nTempoTot)+" Segundos] "
Else
   //Se pedido não estava liberado antes desse processo estorna a liberação do mesmo
   _nI := 1

   //garante que desarmou a transação
   disarmtransaction()

   //===============================================================
   // Calcula o tempo total gasto no processamento.
   //===============================================================
   _cTempoFin := Time()
   _nTempoTot := ELAPTIME( _cTempoIni, _cTempoFin )
   _cTextoTempo := " [Tempo de Processamento: "+AllTrim(_nTempoTot)+" Segundos] "

EndIf

_JsonCarga := ""
If Valtype(_oCarga) == "A" .Or. Valtype(_oCarga) == "J"
   _JsonCarga := _oCarga[1]:toJson() 
Else 
   _JsonCarga := _oCarga:toJson()  
EndIf 

If ValType(_JsonCarga) == Nil 
   _JsonCarga := "" 
EndIf 

// Grava log de comuinicação
//Begin Transaction 
   
   ZFU->(RecLock("ZFU",.T.))
   ZFU->ZFU_FILIAL  := _cFilial                              // Filial do Sistema
   ZFU->ZFU_CODEMP  := _cCodEmpWS	                         // Codigo Empresa WebServer
   ZFU->ZFU_DATA	:= Date()                                // Data de Emissão
   ZFU->ZFU_HORA    := Time()                                // Hora de inclusão na tabela de muro
   ZFU->ZFU_USUARI  := __CUSERID                             // Codigo do Usuário
   ZFU->ZFU_DATAAL  := Date()                                // Data de Alteração
   ZFU->ZFU_SITUAC  := "P"                                   // Situação do Registro
   ZFU->ZFU_ENSTUS  := "S"                                   // Marcou para enviar Status
   ZFU->ZFU_CNPJEM  := _cCNPJEmb // U_CARGA:CNPJEM                        // CNPJ do Embarcador
   ZFU->ZFU_CODIGO  := _cNrCarga // U_CARGA:CODIGO                        // Codigo da Carga no RDC
   ZFU->ZFU_I_FRDC  := _cFilial  // U_CARGA:CODFIL                        // Codigo da Filial RDC

   ZFU->ZFU_CODMVE  := _cCodVTms                             // Código do tipo de veículo do TMS.

   If Len(_aPlacasV) > 0
      ZFU->ZFU_PLACAC := _aPlacasV[1] // U_CARGA:PLACA1                        // Placa do caminhão
   EndIf 

   If Len(_aPlacasV) > 1
      ZFU->ZFU_PLACA2  := _aPlacasV[2] // U_CARGA:PLACA2                        // Placa do Veiculo 2
   EndIf 

   If Len(_aPlacasV) > 2
      ZFU->ZFU_PLACA3  := _aPlacasV[3] // U_CARGA:PLACA3                        // Placa do Veiculo 3
   EndIf 

   If Len(_aPlacasV) > 3
      ZFU->ZFU_PLACA4  := _aPlacasV[4] // U_CARGA:PLACA4                        // Placa do Veiculo 4
   EndIf 

   ZFU->ZFU_CPFMOT  := _cCpfMotor    // U_CARGA:CPFM	                         // CPF do motorista
   ZFU->ZFU_PESOBR  := _nPesoBrut    // U_CARGA:PESOB                         // Peso bruto
   ZFU->ZFU_PESOLQ  := _nPesoLiq     // U_CARGA:PESOL                         // Peso liquido
   ZFU->ZFU_VALCAR  := _nValorTotal  // U_CARGA:VALOR                         // Valor
   ZFU->ZFU_DTEMIS  := _dDataCarg    // CTod(U_CARGA:DATAE)                   // Data de emissão da Carga
   ZFU->ZFU_DTCARR  := _dDataCarg    // CTod(U_CARGA:DATAC)                   // Data de carregamento
   ZFU->ZFU_CNPJTR  := _cCnpjTran    // U_CARGA:CNPJTRA	                      // CNPJ da Transportadora
   ZFU->ZFU_TIPO    := _cTipoVeic    // U_CARGA:TIPO	                         // Tipo do veiculo
   ZFU->ZFU_FRETE   := _nValFrete    // U_CARGA:FRETE                         // Valor do Frete
   ZFU->ZFU_VLRPDG  := _nValPedag    // U_CARGA:PEDAGIO                       // Valor do Pedagio
   ZFU->ZFU_RDCUSR  := _cCPFUsuar    // AllTrim(Str(U_CARGA:USUCAD,6))        // Codigo do Usuário da Alteração
   //ZFU->ZFU_OBS1    := U_CARGA:OBSERV1                       // Observação 1
   //ZFU->ZFU_OBS2    := U_CARGA:OBSERV2                       // Observação 2
   ZFU->ZFU_PRECAR  := "N" // U_CARGA:PRECARGA                      // Precarga? S/N
   ZFU->ZFU_REGCAP  := StrZero(ZFU->(Recno()),10)            // Numero Registro Tab.Capa
   ZFU->ZFU_CODIGO  := _cNrCarga // U_CARGA:CODIGO                        // Codigo da Carga no RDC
   //ZFU->ZFU_RECRDC  := AllTrim(Str(U_CARGA:RECNUM,10))       // Grava o Recno RDC na Tabela de muro.
   ZFU->ZFU_RETORN  := If(! Empty(_cMsg), _cMsg, AllTrim(_cMsgOk) + _cTextoTempo +_cmsgRDC)    // AllTrim(Self:U_STATUS)+" [U_INCLUIC]"  // Retorno Integracao Italac-RDC
   ZFU->ZFU_JSONCG  := _JsonCarga

   If Empty(_cMsg)
	  If Empty(_cCodigo)
	     _cCodigo := DAK->DAK_COD
	  EndIf
      ZFU->ZFU_ENMAIL := "S"      // Marcou para enviar E-MAIL
      ZFU->ZFU_NCARGA := _cCodigo // Numero da cara no Protheus
   Else
	  ZFU->ZFU_NCARGA := " "
   EndIf

   If _lEnviaEmail
	  ZFU->ZFU_ENMAIL := "S" // Marcou para enviar E-MAIL
   EndIf

   ZFU->(MsUnLock())

   For _nI := 1 To Len(_aPedJSon)
       _oDadosCapa := _oCarga[_nI]
       //_aNamesCapa := _oCarga[_nI]:GetNames()

	   ZFV->(RecLock("ZFV",.T.))
	   ZFV->ZFV_FILIAL := _cFilial                                                             // Filial do Sistema
	   ZFV->ZFV_DATA   := Date()                                                               // Data de Emissão
	   ZFV->ZFV_HORA   := Time()                                                               // Hora de inclusão na tabela de muro
	   ZFV->ZFV_CODIGO := _cNrCarga                                                            // U_CARGA:ITENS[_nI]:CODIGO    // Identificador da carga
	   ZFV->ZFV_ITEM   := AllTrim(Str(_nI,5))                                                  // Item da carga
	   ZFV->ZFV_PEDIDO := _aPedJSon[_nI,1]                                                     // U_CARGA:ITENS[_nI]:PEDIDO    // Pedido
	   ZFV->ZFV_TPCARG := _aPedJSon[_nI,3]                                                     // U_CARGA:ITENS[_nI]:TPCARG    // Tipo da carga
	   ZFV->ZFV_CNPJOP := _aPedJSon[_nI,2]                                                     // U_CARGA:ITENS[_nI]:CNPJOP    // CNPJ Operador logistico
	   ZFV->ZFV_CNPJRE := _aPedJSon[_nI,2]                                                     // _cCnpjReceb // U_CARGA:ITENS[_nI]:CNPJRE    // CNPJ Transportadora de redespacho
	   ZFV->ZFV_QTDPLT := _oDadosCapa["numeroPaletes"]                                          // U_CARGA:ITENS[_nI]:QTDPALLET // Quantidade de Pallets
	   ZFV->ZFV_USUARI := __CUSERID                                                            // Codigo do Usuário
	   ZFV->ZFV_DATAAL := Date()	                                                           // Data de Alteração
	   ZFV->ZFV_SITUAC := "P"                                                                  // Situação do Registro
	   ZFV->ZFV_CODEMP := _cCodEmpWS                                                           // Codigo Empresa WebServer
	   ZFV->ZFV_RETORN := If(! Empty(_cMsg), _cMsg, AllTrim(_cMsgOk) + _cTextoTempo +_cmsgRDC) // AllTrim(Self:U_STATUS)       // Retorno Integracao Italac-RDC
	   ZFV->ZFV_REGCAP := StrZero(ZFU->(Recno()),10)                                           // Numero Registro Tab.Capa
	   ZFV->(MsUnLock())
   Next

//End Transaction 

// Garante que vai liberar lock de todos os cabeçalhos e todos os itens
SC5->(Dbsetorder(1))
For _nI := 1 to Len(_aPedJSon) 
	If SC5->(DbSeek(_cFilial+_aPedJSon[_nI,1]))  
	   SC5->(Msunlock())
	   SC5->(Msunlockall())

       SA1->(Dbsetorder(1))
	   If SA1->(Dbseek(xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
		  SA1->(Msunlock())
		  SA1->(Msunlockall())
	   Endif

	   SC6->(Dbsetorder(1))
	   If SC6->(Dbseek(_cFilial+_aPedJSon[_nI,1]))
		  Do while SC6->C6_FILIAL == SC5->C5_FILIAL .AND. SC6->C6_NUM == SC5->C5_NUM
			 SC6->(Msunlock())
			 SC6->(Msunlockall())
			 SB2->(Dbsetorder(1))
			 
			 If SB2->(Dbseek(SC6->C6_FILIAL+SC6->C6_PRODUTO+SC6->C6_LOCAL))
				SB2->(Msunlock())
				SB2->(Msunlockall())
			 EndIf

			 SC6->(Dbskip())
          EndDo
       EndIf
	EndIf
Next

RestOrd(_aOrd)

SM0->(DbGoTo(_nRecnoSM0))

_cMsgResp := _cMsg + " - " + _cMsgOk

Return _lRet 

/*
===============================================================================================================================
Programa----------: AOMS085Z
Autor-------------: Julio de Paula Paz
Data da Criacao---: 22/08/2018
===============================================================================================================================
Descrição---------: Valida se a TES para o pedido de Pallet é válida.
===============================================================================================================================
Parametros--------: _cTipoCarga = Código do tipo de carga.
===============================================================================================================================
Retorno-----------: .T. / .F. 
===============================================================================================================================
*/
User Function AOMS085Z(_cTipoCarga)
	Local _lRet := .T.
	Local _aRet := {.T.,"",""}
	Local _nRegSC5 := SC5->(Recno())
	Local _nRegSC6 := SC6->(Recno())
	Local _cSuframa, _cEstCli, _cCliPed, _cLjCliPed
	Local _TipoC := "C" // 1-Pallet Chep
	Local _cArmSB1, _cArmSBZ, _cArmazem

	Begin Sequence
		_cCliPed   := SC5->C5_CLIENTE
		_cLjCliPed := SC5->C5_LOJACLI

		If SC5->C5_TIPO == "B"
			SA2->(DbSetOrder(1))
			SA2->(DbSeek(xFilial("SA2")+_cCliPed + _cLjCliPed))

			_cSuframa:= ""
			_cEstCli := SA2->A2_EST

		Else
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial("SA1")+_cCliPed + _cLjCliPed))

			_cSuframa:= SA1->A1_SUFRAMA
			_cEstCli := SA1->A1_EST

		EndIf

		If !EMPTY(_cSuframa)//O campo de Suframa não é "sim" ou "nao" é um código
			_cSuframa:= "S"
		Else
			_cSuframa:= "N"
		EndIf

		_cEstFil  := SM0->M0_ESTCOB
		_cCliPed  := SC5->C5_CLIENTE
		_cLjCliPed:= SC5->C5_LOJACLI

		If _cTipoCarga $ "3,6"//"3-Pallet PBR","6-Pallet PBR Retorno"
			_TipoC:="P"
		EndIf

		//====================================================================================================
		// Verifica o Tipo de Pallet e recupera o código do Produto referente
		//====================================================================================================
		If _TipoC == "C"
			_cProduto := GetMV( "IT_CCHEP" )
		ElseIf _TipoC == "P"
			_cProduto := GetMV( "IT_PPBR" )
		EndIf

		//Define se é cliente chep
		_clichep := "N"
		SA1->(Dbsetorder(1))
		If SA1->( DBSeek( xFilial("SA1") + ( _cCliPed + _cLjCliPed ) ) )

			IF LEN(ALLTRIM(SA1->A1_I_CCHEP)) == 10
				_clichep := "S"
			ENDIF

		EndIf

		//Define tipo de  de operação

		If _TipoC == "C" //Pallet Chep

			If _cCliPed == '000001'

				If _clichep == "S"
				    cTpOper := SUPERGETMV('IT_CHEPITLS',.F.,  "")
					If Empty(cTpOper)
					   cTpOper	:= AllTrim( U_ITGETMV( 'IT_CHEPITLS' ) )
					EndIf 
				Else
				    cTpOper := SUPERGETMV('IT_CHEPITLN',.F.,  "")
					If Empty(cTpOper)
					   cTpOper	:= AllTrim( U_ITGETMV( 'IT_CHEPITLN' ) )
					EndIf 
				EndIf

			Else

				If _clichep == "S"
				    cTpOper := SUPERGETMV('IT_CHEPCLIS',.F.,  "")
					If Empty(cTpOper)
					   cTpOper	:= AllTrim( U_ITGETMV( 'IT_CHEPCLIS' ) )
					EndIf
				Else
				    cTpOper := SUPERGETMV('IT_CHEPCLIN',.F.,  "")
					If Empty(cTpOper)
					   cTpOper	:= AllTrim( U_ITGETMV( 'IT_CHEPCLIN' ) )
					EndIf 
				EndIf

			EndIf

		Elseif _TipoC == "P" //Pallet PBR

			If _cCliPed == '000001'
                cTpOper := SUPERGETMV('IT_PBRITLP',.F.,  "") 
				If Empty(cTpOper)
				   cTpOper	:= AllTrim( U_ITGETMV( 'IT_PBRITLP','51' ) )
                EndIf 
			Else
                cTpOper := SUPERGETMV('IT_PBRCLIP',.F.,  "")
				If Empty(cTpOper)
				   cTpOper	:= AllTrim( U_ITGETMV( 'IT_PBRCLIP','51' ) )
				EndIf 

			Endif

		Endif

		_cArmSB1 := Posicione('SB1',1,xFilial("SB1")+U_ITKEY(_cProduto,"B1_COD"),'B1_LOCPAD')

		_cArmSBZ := Posicione('SBZ',1,SC5->C5_FILIAL+U_ITKEY(_cProduto,"B1_COD"),'BZ_LOCPAD')

		_cArmazem := If(Empty(_cArmSBZ), _cArmSB1 , _cArmSBZ )

		_cTES:= u_selectTES(U_ITKEY(_cProduto,"B1_COD"),_cSuframa,_cEstCli,_cEstFil,_cCliPed,_cLjCliPed,cTpOper,_cArmazem,SC5->C5_TIPO)

		If Empty(_cTES)
			_lRet := .F.
		EndIf

		_aRet := {_lRet,_cProduto, "Cliente: "+_cCliPed +"- Loja: "+_cLjCliPed }

	End Sequence

	Sc5->(DbGoTo (_nRegSC5))
	Sc6->(DbGoTo (_nRegSC6))

Return _aRet

/*
===============================================================================================================================
Programa--------: AOMS085S
Autor-----------: Josué Danich Prestes
Data da Criacao-: 18/02/2014
===============================================================================================================================
Descrição-------: Valida Limite de Crédito do Cliente para gravação da carga
===============================================================================================================================
Parametros------: cNumPed - Número do pedido de venda do portal
----------------: cFilAux - Filial do pedido de venda
===============================================================================================================================
Retorno---------: lRet    - Informa o resultado da validação
===============================================================================================================================
*/
Static Function AOMS085S( cNumPed , cFilAux, Altera )

	Local aAreaSC5	:= GetArea("SC5")
	Local aAreaSC6	:= GetArea("SC6")
	Local aAreaSA1	:= GetArea("SA1")
	Local _ntotped 	:= 0

	Local _lret := .T.   // "Outros"
	Local _nTotPV:=0
	Local _lValCredito:=.T.
	Local _cTextoRet := "Aprovado em avalição de crédito"


	Default cNumPed	:= SC5->C5_NUM //Número do Pedido Posicionado
	DEfault cFilAux	:= SC5->C5_FILIAL //Filial do Pedido Posicionado

	Default altera := .T.

	Begin Sequence

		SC6->(Dbsetorder(1))
		SC5->(Dbsetorder(1))

		SC6->(DbGotop())
		SC5->(DbGotop())

		If !(SC6->(Dbseek(cFilAux+cNumPed))) .OR. !(SC5->(Dbseek(cFilAux+cNumPed)))

			_lret      := .F.
			_cTextoRet := "Filial : " + cFilAux + " / Pedido: " + cNumPed + ". Não Localizado. "
			Break

		Else

			_cchep := alltrim(GetMV("IT_CCHEP"))
			Do While SC6->C6_FILIAL == cFilAux .AND. SC6->C6_NUM == cNumPed


				_nTotPV += SC6->C6_VALOR

				If alltrim(SC6->C6_PRODUTO) == _cchep .OR. AllTrim(SC6->C6_CF) $ '5910/6910/5911/6911'//NÃO VALIDA CRÉDITO PARA PALLET CHEP E PARA BONIFICAÇÃO
					_lValCredito:=.F.
					EXIT
				ENDIF

				If posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC") != 'S' //NÃO VALIDA CRÉDITO PARA PEDIDO SEM DUPLICATA
					_lValCredito:=.F.
					EXIT
				Endif

				If posicione("ZAY",1,xfilial("ZAY")+ AllTrim(SC6->C6_CF) ,"ZAY_TPOPER") != 'V' //NÃO VALIDA CRÉDITO PARA PEDIDO COM CFOP QUE NÃO SEJA DE VENDA
					_lValCredito:=.F.
					EXIT
				Endif

				_ntotped += (SC6->C6_QTDVEN * SC6->C6_PRCVEN)

				SC6->(DbSkip())

			EndDo

		Endif

		IF _lValCredito

			_aRetCre := U_ValidaCredito( _nTotPV , SC5->C5_CLIENTE , SC5->C5_LOJACLI , Altera , , , , SC5->C5_MOEDA,,SC5->C5_NUM)//AWF-11/01/2017
			_cBlqCred:=_aRetCre[1]

			If _aRetCre[2] = "B"//Se bloqueou

				_lret      := .F.
				_cTextoRet := "Pedido de vendas " + alltrim(SC5->C5_NUM) + " bloqueado por crédito, " + _cBlqCred
				Break
			EndIf

		Else

			_lret := .T.
			_cTextoRet := "Pedido não passa por avaliação de crédito"

		Endif


	End Sequence

	SC5->(RestArea(aAreaSC5))
	SC6->(RestArea(aAreaSC6))
	SA1->(RestArea(aAreaSA1))

Return( {_lret,_cTextoRet} )

/*
===============================================================================================================================
Função------------: AOMS085T
Autor-------------: Julio de Paula Paz
Data da Criacao---: 18/01/2024
===============================================================================================================================
Descrição---------: Tela para informar o numero do protocolo de integração de carga para integração das cargas.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _aRet = {_lRet , _cNumeroProtocoloIntegracao}
                             _lRet == .T. = Protocolo informado e integração da carga confirmada.
							          .F. = Protocolo não informado ou integração da carga cancelada.
							 _cNumeroProtocoloIntegracao = Numero do protocolo de integração da carga para integrar a carga.
===============================================================================================================================
*/  
User Function AOMS085T(_nRegAtu)
Local _bOk, _bCancel
Local _lRet := .T.
Local _cNrProtC 
Local _oDlgPesq
Local _aRet := {.T.,""}

Begin Sequence
   _cNrProtC := Space(15)

   _bOk := {|| _lRet := .T., _oDlgPesq:End()}
   _bCancel := {|| _lRet := .F., _oDlgPesq:End()}
                                                
   _cTitulo := "Integração de Carga por Numero de Protocolo de Integração de Carga [Digitado]"
      
   //================================================================================
   // Monta a tela de Pesquisa de Dados.
   //================================================================================      
   Define MsDialog _oDlgPesq Title _cTitulo From 9,0 To 22,65 Of oMainWnd      
                                                       
      @ 15,10 Say "Nr. Protocolo Integração Carga" Pixel of _oDlgPesq                                                 
      @ 15,90 Get _oNrProtC   Var _cNrProtC Picture "@!" Size 80,10 Pixel Of _oDlgPesq  
        
      @ 75,060  Button "Integrar Carga" Size 50,16  Of _oDlgPesq Pixel Action EVAL(_bOk)
      @ 75,145  Button "Cancelar"      Size 50,16  Of _oDlgPesq Pixel Action EVAL(_bCancel)
      
   Activate MsDialog _oDlgPesq CENTERED 

   If _lRet
      If Empty(_cNrProtC)  
         MsgInfo("O numero do protocolo de integração de carga não informado.","Atenção")
		 _lRet := .F.
      EndIf
   Else 	  
      _lRet := .F.
   EndIf 

   _aRet := {_lRet,AllTrim(_cNrProtC)}

End Sequence

Return _aRet 

/*
===============================================================================================================================
Função------------: AOMS085U
Autor-------------: Igor Melgaço
Data da Criacao---: 30/12/2024
===============================================================================================================================
Descrição---------: Executar a alteração da carga
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS085U(_nRegAtu)
DbSelectArea("DAK")
Dbsetorder(7)
If Dbseek(xFilial("DAK")+ZFU->ZFU_CODIGO)
	U_AOMS140M()
Else
	u_itmsg("Carga código "+ZFU->ZFU_CODIGO+" não encontrada para alteração!","Atenção",,1)
EndIf

Return 

/*
===============================================================================================================================
Programa----------: AOMS085A
Autor-------------: Julio de Paula Paz
Data da Criacao---: 16/01/2025
===============================================================================================================================
Descrição---------: Efetua a leitura das cargas integradas via Webservice Protheus x TMS Multiembarcador e verfica as que 
                    estão pendentes de rateio de frete e vale pedágio. 
					Efetua a atualização dos valores de frete e vale pedágio, e faz os rateios para os itens da carga.
===============================================================================================================================
Parametros--------: _lSchedule = .T. = Rotina rodando em modo Scheduller.
                                 .F. = Rotina chamada via tela.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS085A(_lSchedule) 
Local _cDirXML := ""
Local _nI := 0
Local _nJ := 0
//Local _nTotRegs := 0
Local _aCargas := {}
Local _cEmpWebService 
Local _cToken 
                                 
Local _cDtLerDAK := SUPERGETMV('IT_LERCARG',.F.,  "01/01/2024")

Local _cMsgResp := ""  // Armazena as respostas das integrações

Default _lSchedule := .F.

Begin Sequence 

   _cEmpWebService := SUPERGETMV('IT_EMPTMSM',.F.,  "")
   If Empty(_cEmpWebService)
      _cEmpWebService := U_ITGETMV( 'IT_EMPTMSM' , "000005")
   EndIf 

   _cToken := SUPERGETMV('IT_TOKMUTE',.F.,  "")
   If Empty(_cToken)
      _cToken := U_ITGETMV( 'IT_TOKMUTE' , "a78e0523d3794843855e8d95c2bff8d4")
   EndIf 

   //=======================================================================================================
   // Força a abertura das tabelas. Algumas tabelas não estão sendo aberta automaticamente pelo Protheus.
   //=======================================================================================================
   ChkFile("SM0")
   ChkFile("DA4")
   ChkFile("DA3")
   ChkFile("ZFU")
   ChkFile("ZFV")
   ChkFile("ZFM")
   ChkFile("SC5")
   ChkFile("SC6")
   ChkFile("SA1")
   ChkFile("SA2")
   ChkFile("SB1")
   ChkFile("SB2")
   ChkFile("ZEL")

   ZFM->(DbSetOrder(1))
   If ZFM->(DbSeek(xFilial("ZFM")+_cEmpWebService))
      _cDirXML   := ZFM->ZFM_LOCXML 
      _cLinkNfe  := AllTrim(ZFM->ZFM_LINK03)  // Link NFE
	  _CLinkCarg := AllTrim(ZFM->ZFM_LINK04)  // Link Cargas
   Else 
      If ! _lScheduler
         MsgInfo("Código de Empresa WebService Não Cadastrado.","Atenção")
	  EndIf 
	  Break 
   EndIf 

   If Empty(Alltrim(_cLinkNfe)) .OR. Empty(Alltrim(_CLinkCarg)) 
      If ! _lScheduler
         MsgInfo("Empresa WebService para envio dos dados não possui link cadastrado!.","Atenção")
      EndIf
      Break   
   EndIf 

   If Select("QRYDAKT") > 0
      QRYDAKT->(DbCloseArea())
   EndIf

   _cQry := "SELECT DAK_FILIAL, DAK_COD, DAK_I_RECR, R_E_C_N_O_ AS NRREG "
   _cQry += " FROM " + RetSqlName("DAK") + " DAK "
   _cQry += " WHERE DAK_DATA >= '" + Dtos(Ctod(_cDtLerDAK)) + "' "
   _cQry += " AND D_E_L_E_T_ = ' ' "
   _cQry += " AND DAK_I_TMS = 'M' "
   _cQry += " AND DAK_I_RATF = 'N' "

   MPSysOpenQuery( _cQry , "QRYDAKT")

   DBSelectArea("QRYDAKT")

   //Count To _nTotRegs

   //==============================================
   // Busca de Veiculos e Motoristas de cada carga
   //==============================================
   _cJSonEnv  := "{}" 
   _nTimOut   := 120
   _aHeadOut  := {}
   _cJSonRet  := Nil   
   _oRetJSon  := Nil 

   Aadd(_aHeadOut,"Content-Type: application/json") 
   Aadd(_aHeadOut,"Authorization: Bearer Token") 
   Aadd(_aHeadOut,"Token: " + AllTrim(_cToken)) 

   Do While ! QRYDAKT->(Eof())    
	   //================================================================================
	   // Json com o protocolo de integração de carga para obtenção dos dados da carga.
	   //================================================================================
 	   _cJSonEnv  := '{'+'"protocoloIntegracaoCarga":'+ '"'+AllTrim(QRYDAKT->DAK_I_RECR) + '" }' 

	   //=======================================================================
       // Integra solicitando dados NFE
       //=======================================================================
	   _cJSonRet := Nil
       _cRetHttp := AllTrim( HttpPost( _CLinkCarg , '' , _cJSonEnv , _nTimOut , _aHeadOut , @_cJSonRet ) ) 
       _oRetJSon := Nil 

       If Empty(_cJSonRet) .Or. ! "200 OK" $ Upper(_cJSonRet)
	      If ! Empty(_cJSonRet)
	         _cResult2 := _cJSonRet
		  EndIf 
	         _cMsgResp += "Não foi encontrado carga para o protocolo de integração de carga: " + _aCargas[_nI]
	       Loop 
	    EndIf 

       If ! Empty(_cRetHttp)
          _oJSonCarga := JsonObject():new()
          
          _cRet := _oJSonCarga:FromJson(_cRetHttp)

          If _cRet <> NIL
              _cMsgResp += "Não foi possível ler o JSon de Cargas retornado pelo TMS Multiembarcador. "
	          Loop 
          EndIf 

		  If ! _oJSonCarga["status"]
			 _cMsgResp += "Não foi possível ler o JSon de Cargas retornado pelo TMS Multiembarcador. "
	         Loop 
		  EndIf 

          _aNonesCar := _oJSonCarga:GetNames()
          
          _nJ := Ascan(_aNonesCar,"objeto") 
          If _nJ == 0
			 _cMsgResp += "Não há dados no JSon de Carga retornado pelo TMS Multiembarcador. "
	         Loop
          EndIf 

          _oJSonObj  := _oJSonCarga:GetJsonObject("objeto") // objeto

	   Else 
	      _cResult2 := _cJSonRet
		  _cMsgResp += "Não foi encontrado carga para o protocolo de integração de carga: " + _aCargas[_nI]
	      Loop
	   EndIf

      If ValType(_oJSonObj) == "A"
         _oCarga := _oJSonObj[1]
      Else 
         _oCarga := _oJSonObj
      EndIf 

      _aNomesCar := _oCarga:GetNames()

      //_oDadosCapa := _oCarga[1]
      //_aNamesCapa := _oCarga[1]:GetNames()

      //_oDadosFre := _oDadosCapa["valorFrete"]
	  _oDadosFre := _oCarga["valorFrete"]
      _nValFrete := _oDadosFre["valorPrestacaoServico"]
      //_nValPedag := _oDadosCapa["valorPedagio"] 
   
      _nJ := Ascan(_aNomesCar,"consultaValePedagio")
   
      If _nJ > 0
         _oValPedag  := _oCarga["consultaValePedagio"] //_oDadosCapa["consultaValePedagio"]
         If Type('_oValPedag["valorConsultaValePedagio"]') <> "U" 
            _nValPedag := _oValPedag["valorConsultaValePedagio"]  
         EndIf 
      EndIf 

	  _nSituacao := _oCarga["situacaoCarga"]

      DAK->(DbGoto(QRYDAKT->NRREG))

	  If _nSituacao == 13 .Or. _nSituacao == 18
         DAK->(RecLock("DAK",.F.))
         DAK->DAK_I_RATF := "C"
         DAK->(MsUnlock())
      ElseIf _nSituacao == 8 .Or. _nSituacao == 9 .Or. _nSituacao == 11
	     If _nValFrete > 0  .And. _nValPedag > 0
		    BEGIN Transaction
               DAK->(RecLock("DAK",.F.))
               DAK->DAK_I_RATF := "S"
			   DAK->DAK_I_VRFR := _nValFrete
			   DAK->DAK_I_VRPE := _nValPedag  
               DAK->(MsUnlock())

               //==========================================================================
			   // Roda a rotina para fazer o rateio do frete da DAK para os pedidos da DAI.
			   //==========================================================================
               AOMS085DAI()
            End Transaction
		 EndIf 
      EndIf 

	  QRYDAKT->(DbSkip())    
   EndDo	  
 
End Sequence 

_cMsgResp += " - Termino da rotina de integração de cargas."

If ! Empty(_cMsgResp) .And. ! _lSchedule
   U_Itmsg(_cMsgResp,"Atenção",,2)
EndIf 

Return Nil


/*
===============================================================================================================================
Programa----------: AOMS085DAI()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 29/08/2024
===============================================================================================================================
Descrição---------: Faz o Rateio de frete para os pedidos de vendas na tabela DAI.
                    Para a carga posicionada. (DAK)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum 
===============================================================================================================================
*/  
Static Function AOMS085DAI()
Local _cRet := ""
Local _nPesoTot  := 0
Local _nPesoTAux := 0
Local _nUltimRec := 0
Local _nTotPedid := 0  

Begin Sequence 
   //========================================================================================
   // Calcula os Pesos dos Pedidos de Vendas Desconsiderendo os pesos e produtos dos Pallets
   //========================================================================================
	_nPesoTot := U_CalPesCarg( DAK->DAK_COD , 1 )
	
	If _nPesoTot == 0 
		_nPesoTAux := DAK->DAK_PESO
	EndIf 

   //===============================================================================
   // Verifica quantos Pedidos de Vendas existem na DAI e Grava o Ultimo Registro.
   //===============================================================================
   _nUltimRec := 0
   _nTotPedid := 0  
   
   DAI->(MsSeek(DAK->DAK_FILIAL+DAK->DAK_COD))
   Do While ! DAI->(Eof()) .And. DAI->DAI_FILIAL+DAI->DAI_COD == DAK->DAK_FILIAL+DAK->DAK_COD
      SC5->(MsSeek(DAI->DAI_FILIAL+DAI->DAI_PEDIDO))

      If SC5->C5_I_PEDPA == "S"
         DAI->(DbSkip())
         Loop 
      EndIf 

      _nUltimRec := DAI->(Recno())
      _nTotPedid += 1  

      _nFretDAI:=0
		
	  If _nPesoTot > 0    
	     If U_CalPesCarg(DAI->DAI_PEDIDO,2) > 0
		    _nFretDAI	:=	((DAK->DAK_I_VRFR /	_nPesoTot)	*	DAI->DAI_PESO)	   
         EndIf
	  Else
         _nFretDAI	:=	( ( DAK->DAK_I_VRFR/ _nPesoTAux ) * DAI->DAI_PESO )
      EndIf

	  If _nFretDAI > 0
	     DAI->( RecLock( "DAI" , .F. ) )
	     DAI->DAI_I_FRET := _nFretDAI
		 DAI->( MsUnlock() )
	  EndIf
      
	  //===============================================================
	  // Roda a rotina que faz o rateio de frete e vale pedágio nas
	  // notas fiscais. 
	  //===============================================================
      AOMS085SF2() 

      DAI->(DbSkip())
   EndDo 

End Sequence 

Return _cRet 

/*
===============================================================================================================================
Programa----------: AOMS085SF2()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 16/01/2025
===============================================================================================================================
Descrição---------: Faz o Rateio de frete para as notas fiscais e para os itens da nota fiscal.
                    Para o Item da carga posicionada. (DAI)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum 
===============================================================================================================================
*/
Static Function AOMS085SF2()

Begin Sequence 

   //================================================================================
   //| Gravacao do Valor Frete por nota                                             |
   //================================================================================
   SF2->(DbSetOrder(20)) // F2_FILIAL+F2_I_PEDID
   If SF2->(MsSeek(DAI->DAI_FILIAL+DAI->DAI_PEDIDO))
      _nPesoTotC := Cal2PesCarg( SF2->F2_CARGA , 1 )//EFETUA O SOMATORIO DO PESO DA CARGA SEM OS PALLET
      _nPesoNota := SF2->F2_PBRUTO 

      _nVlrPedagNF :=  ( DAK->DAK_I_VRPE / _nPesoTotC ) * _nPesoNota 

      SF2->( RecLock( "SF2" , .F. ) )
      SF2->F2_I_FRET := ( ( DAK->DAK_I_VRFR / _nPesoTotC ) * _nPesoNota )
      SF2->( MsUnlock() )

      _nVlrFretNF := ( ( DAK->DAK_I_VRFR / _nPesoTotC) * _nPesoNota )

      //-------------------------------------------------------------
      _nPesoTotC   := Cal2PesCarg( SF2->F2_CARGA , 1 )  //EFETUA O SOMATORIO DO PESO DA CARGA SEM OS PALLET
      _nPesoNota   := SF2->F2_PBRUTO 

      //_nVlrPedagNF :=  ( _nTotPedagio / _nPesoTotC ) * _nPesoNota 
	  //_nVlrPedagNF :=  ( DAK->DAK_I_VRPE / _nPesoTotC ) * _nPesoNota 

      DBSelectArea("SD2")
      SD2->( DBSetOrder(3) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

      If SD2->( DBSeek( SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ) )

	     Do While SD2->(!Eof()) .and. SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA ) == SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA

		    _nPesoItem := ( POSICIONE( "SB1" , 1 , xFilial("SB1") + SD2->D2_COD , "B1_PESBRU" ) * SD2->D2_QUANT )
            //---------------------------------------------------------------------------------------------------
            //_nPesoTotItem  := ( _nPesoItem * SD2->D2_QUANT )
	 	    //_nVlrItemPedag := ( ( _nVlrPedagNF / _nPesoNota ) * _nPesoTotItem)  
			_nVlrItemPedag := ( ( _nVlrPedagNF / _nPesoNota ) * _nPesoItem)  
		    //================================================================================
		    //| Gravacao do Valor Frete por item da Nota                                     |
		    //================================================================================
		    SD2->( RecLock( "SD2" , .F. ) )
		    SD2->D2_I_FRET  := ( ( _nVlrFretNF / _nPesoNota ) * _nPesoItem )
            SD2->D2_I_VLPED := _nVlrItemPedag
		    SD2->( MsUnlock() )

		    SD2->( DBSkip() )
	     EndDo
      EndIf
   EndIf  
End Sequence 

Return Nil

/*
===============================================================================================================================
Programa----------: Cal2PesCarg
Autor-------------: Alex Wallauer
Data da Criacao---: 19/03/2014
===============================================================================================================================
Descrição---------: Funcao que soma o peso total da carga desconsiderando Produtos Unitizadores do Pallet
                    Por ser função Static, esta função foi copiada do fonte M460FIM.PRW, para este fonte.
===============================================================================================================================
Parametros--------: _cCodigo - Código da Carga/Pedido
------------------: _nTipo	 - 1 = Peso Total da Carga / 2 = Peso Total do Pedido / 3 e 4 - Operador Logistico
===============================================================================================================================
Retorno-----------: _nPesoTot- Peso total calculado
===============================================================================================================================
*/
Static Function Cal2PesCarg( _cCodigo , _nTipo )

Local _oAliasPes:= GetNextAlias()
Local _cQuery	:= ""
Local _cGrpUnit	:= GetMV( "IT_GRPUNIT" ,, "0813" )
Local _nPesoTot	:= 0     
Local _aArea	:= GetArea()

_cQuery += " SELECT "
_cQuery += " COALESCE( SUM( SB1.B1_PESBRU * SC6.C6_QTDVEN ) , 0 ) PESTOTAL "
_cQuery += " FROM " + RetSqlName("DAI") + " DAI "
_cQuery += " JOIN " + RetSqlName("SC6") + " SC6 ON DAI.DAI_PEDIDO = SC6.C6_NUM AND DAI.DAI_FILIAL = SC6.C6_FILIAL "
_cQuery += " JOIN " + RetSqlName("SB1") + " SB1 ON SC6.C6_PRODUTO = SB1.B1_COD "
_cQuery += " WHERE "
_cQuery += " 		DAI.D_E_L_E_T_	= ' ' "
_cQuery += " AND	SC6.D_E_L_E_T_	= ' ' "
_cQuery += " AND	SB1.D_E_L_E_T_	= ' ' "
_cQuery += " AND	SB1.B1_GRUPO NOT IN "+ FormatIn( _cGrpUnit , ";" ) //EXCLUI GRUPOS UNITIZADORES
_cQuery += " AND	DAI.DAI_FILIAL	= '" + XFILIAL("DAI") + "' "
_cQuery += " AND	SC6.C6_FILIAL	= '" + XFILIAL("SC6") + "' "

If _nTipo == 3 .OR. _nTipo == 4//Efetua o somatorio do peso total só dos pedidos com operador logistico
   _cQuery += " AND	(DAI_I_OPLO <> ' ' OR DAI_I_TRED	<> ' ') "
ENDIF

If _nTipo == 1 .OR. _nTipo == 3//Efetua o somatorio do peso total da Carga
   _cQuery += " AND	DAI.DAI_COD		= '"+ _cCodigo +"' "
ElseIf _nTipo == 2 .OR. _nTipo == 4 //Efetua o somatorio do Peso do Pedido
   _cQuery += " AND	SC6.C6_NUM		= '" + _cCodigo + "'"
EndIf

//DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _oAliasPes , .T. , .F. )
MPSysOpenQuery( _cQuery , _oAliasPes)

DBSelectArea(_oAliasPes)

If (_oAliasPes)->(!Eof())
	_nPesoTot := (_oAliasPes)->PESTOTAL
EndIf

(_oAliasPes)->( DBCloseArea() )

RestArea( _aArea )

Return( _nPesoTot )

/*
===============================================================================================================================
Função-------------: AOMS085P
Autor--------------: Julio de Paula Paz
Data da Criacao----: 17/01/2025
===============================================================================================================================
Descrição----------: Rotina para rodar em Scheduller a função:
                     U_AOMS05A()       
                     Esta função efetua a leitura das cargas integradas via Webservice Protheus x TMS Multiembarcador e 
					 verfica as que estão pendentes de rateio de frete e vale pedágio. 
					 Efetua a atualização dos valores de frete e vale pedágio, e faz os rateios para os itens da carga. 
===============================================================================================================================
Parametros---------: Nenhum
===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function AOMS085P()

Begin Sequence

   //=============================================================================
   // Ativa a filial "01" 
   //=============================================================================
   RESET ENVIRONMENT
   RpcSetType(2) // 3

   //===========================================================================================
   // Preparando o ambiente com a filial 01
   //===========================================================================================
   RpcSetEnv("01", "01",,,,, {"SA2","ZLJ","ZLD",'ZBG', "ZBH", "ZBI", "ZZM"})

   Sleep( 5000 ) //Aguarda 5 segundos para subam as configurações do ambiente.

   U_AOMS085A(.T.)

 End Sequence

 Return Nil

/*
===============================================================================================================================
Função-------------: AOMS085B
Autor--------------: Julio de Paula Paz
Data da Criacao----: 04/06/2025
===============================================================================================================================
Descrição----------: Rotina de Alteração de Desmembramento do Pedido de Vendas.
                     Rotina chamada pelo Webservice de criação de cargas vindas do TMS, no Protheus.
===============================================================================================================================
Parametros---------: _aItemCarg = Array com os Pedidos de Vendas e as Quantidades das Cargas do TMS.
                                 1=Filial      ,2=Numero PV     , 3=Codigo Produto           , 4=Quantidade            ,5=Item       ,6=Mesclar            ,7=Ação  
			         _aItemCarg={_cFilial      ,_aPedJSon[_nI,1], _aProdutos["codigoProduto"], _aProdutos["quantidade"],""            ,_aProdutos["mesclar"],"REJEITAR"})
                     _aItemCarg={SC6->C6_FILIAL,SC6->C6_NUM     , SC6->C6_PRODUTO            , SC6->C6_QTDVEN          , SC6->C6_ITEM ,.F.                  ,"EXCLUIR" })

===============================================================================================================================
Retorno------------: Nenhum
===============================================================================================================================
*/
User Function AOMS085B(_aItemCarg)
Local _aRet
Local _nI
Local _nJ 
Local _nX
//Local _cFilial
Local _aOrd := SaveOrd({"SC5","SC6"})
Local _aCabPV, _aItemPV,_aItensPV
Local _nTamFilial := TAMSX3("C5_FILIAL")[1]
Local _cUM, _c2UM, _nQtd, _n2Qtd
Local _cCodProd
Local _cCodUsuario, _cNomeArqLog
Local _cMsg, _cFator, _cTipoOper
Local _ltemlib := .F.
Local _nTotPesBr

Local _cMsgErro  := ""    
Local _aPedido   := {}
Local _aProcItem := {}
Local _lTemItAlt
Local _cPedVenda 
Local _cFilPedV
//Local _lDesmembr := .F.

Private aHeader, aCols
Private _cCodTab := Space(3)
Private _cAOMS074    := "AOMS085"    //Não mostra mensagens do mata410
Private _cAOMS074Vld := " "         //Zera para cada pedido

aHeader := {}
aCols := {}

Begin Sequence
       
   Begin Transaction 
      _nI := Ascan(_aItemCarg, {|x| x[7] == "DESMEMBRAR" }) 
	  //If _nI > 0
      //   _lDesmembr := .T.
	  //EndIf 

	  For _nI := 1 To Len(_aItemCarg)
	      _cFilPedV  := _aItemCarg[_nI,1]
		  _cPedVenda := _aItemCarg[_nI,2]
          
	      _nJ := AsCan(_aPedido,_cPedVenda) // Pode ter mais de um Pedido de Vendas na Carga. Este Array filtra os Pedidos de Vendas já Processados.  
		  If _nJ > 0 // Pedido de Vendas Já Processado.
		     Loop 
          Else 
			 Aadd(_aPedido,_cPedVenda)
          EndIf  
          //=========================================================
		  // Monta Array com os itens a serem Alterados/Desmembrados
		  //=========================================================
		  _lTemItAlt := .F.
		  _aProcItem := {}
          For _nJ := 1 To Len(_aItemCarg)
		      If _aItemCarg[_nJ,2] <> _cPedVenda // Monta array apenas com os pedidos de vendas a serem processados.
			     Loop
			  EndIf  

               If _aItemCarg[_nJ,7] <> "ITEM_OK"  // Verifica se para este pedido de vendas tem Ateração / Desmembramento.
                 _lTemItAlt := .T.
			   EndIf

              Aadd(_aProcItem,_aItemCarg[_nJ])

		  Next _nJ 

          If ! _lTemItAlt // Não tem Alteração / Desmembramento para este Pedido de Vendas.
             Loop 
		  EndIf

          //========================================================
          // Inicia a Alteração/Desmembramento do Pedido de vendas
		  //========================================================
		  SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM
		  SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		  SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD
		  DA1->(DbSetOrder(1)) // DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
          //=======================================================================================================================================================
          //             1=Filial      ,2=Numero PV     , 3=Codigo Produto           , 4=Quantidade            ,5=Item       ,6=Mesclar            ,7=Ação  
		  // _aProcItem={_cFilial      ,_aPedJSon[_nI,1], _aProdutos["codigoProduto"], _aProdutos["quantidade"],""            ,_aProdutos["mesclar"],"REJEITAR"})
          // _aProcItem={SC6->C6_FILIAL,SC6->C6_NUM     , SC6->C6_PRODUTO            , SC6->C6_QTDVEN          , SC6->C6_ITEM ,.F.                  ,"EXCLUIR" })
          //=======================================================================================================================================================
          
		  SC5->(MsSeek(_cFilPedV+_cPedVenda))

		  //=============================================================================
		  // Valida cliente bloqueado
		  //=============================================================================
		  If Posicione("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_MSBLQL") == '1'
			 _cMsgErro := "Cliente do pedido bloqueado no cadastro "+AllTrim(SC5->C5_CLIENTE+"/"+SC5->C5_LOJACLI)+"."
			 Disarmtransaction()
			 Break
		  EndIf

          //=============================================================================
		  //Valida se é pedido que pode alterar
		  //=============================================================================
		  If !Empty(SC5->C5_NOTA)
			 _cMsgErro := "Pedido não disponível para alteração! Está faturado: "+SC5->C5_NUM+"."
			 Disarmtransaction()
			 Break
		  EndIf

          //=============================================================================
		  //Valida crédito
		  //=============================================================================
		  If  SC5->C5_TIPO = 'N'
			  _nTotPV:=0
			  _lValCredito:=.T.

			  SC6->(Dbsetorder(1))
			  SC6->(Dbgotop())
			  SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))
			  _cchep := alltrim(GetMV("IT_CCHEP"))

			  Do While SC6->C6_NUM == SC5->C5_NUM .AND. SC5->C5_FILIAL == SC6->C6_FILIAL
				 _nTotPV += SC6->C6_VALOR

				 If SC6->C6_PRODUTO == _cchep .OR. SC6->C6_CF $ '5910/6910/5911/6911'//NÃO VALIDA CRÉDITO PARA PALLET CHEP E PARA BONIFICAÇÃO
					_lValCredito:=.F.
				    Exit
			   	 EndIf 

				 If Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC") != 'S' //NÃO VALIDA CRÉDITO PARA PEDIDO SEM DUPLICATA
				    _lValCredito:=.F.
					Exit 
			  	 EndIf

			     If Posicione("ZAY",1,xfilial("ZAY")+ SC6->C6_CF ,"ZAY_TPOPER") != 'V' //NÃO VALIDA CRÉDITO PARA PEDIDO COM CFOP QUE NÃO SEJA DE VENDA
				 	_lValCredito:=.F.
					Exit
				 EndIf

				 SC6->(DbSkip())
			  EndDo 

		      If _lValCredito

				 _aRetCre := U_ValidaCredito( _nTotPV , SC5->C5_CLIENTE , SC5->C5_LOJACLI , .T. , , , , SC5->C5_MOEDA,,SC5->C5_NUM)
				 _cBlqCred:=_aRetCre[1]

				 Reclock("SC5",.F.)

				 If _aRetCre[2] = "B"//Se bloqueou
					If SC5->C5_I_BLCRE == "R"
					   lBlq2 := .T.
					   SC5->C5_I_BLCRE	:= "R"
					   SC5->C5_I_DTAVA := DATE()
					   SC5->C5_I_HRAVA := TIME()
					   SC5->C5_I_USRAV := cusername
					   SC5->C5_I_MOTBL := _cBlqCred
					Else
  					   lBlq2			:= .T.
					   SC5->C5_I_BLCRE	:= "B"
					   SC5->C5_I_DTAVA := DATE()
					   SC5->C5_I_HRAVA := TIME()
					   SC5->C5_I_USRAV := cusername
					   SC5->C5_I_MOTBL := _cBlqCred
					EndIf
				 EndIf

				 SC5->C5_I_MOTBL := _cBlqCred//Sempre grava a descrição
				 SC5->(Msunlock())
              EndIf
		   EndIf

		   //=====================================================================
		   // Este trecho trata a alteração de pedidos de vendas.
		   //=====================================================================

		   _aCabPV  :={}
		   _aItemPV :={}
		   _aItensPV:={}

		   Aadd( _aCabPV, { "C5_FILIAL"	   ,SC5->C5_FILIAL  , Nil})//filial
		   Aadd( _aCabPV, { "C5_NUM"       ,SC5->C5_NUM	    , Nil})
		   Aadd( _aCabPV, { "C5_TIPO"	   ,SC5->C5_TIPO    , Nil})//Tipo de pedido
		   Aadd( _aCabPV, { "C5_I_OPER"	   ,SC5->C5_I_OPER  , Nil})//Tipo da operacao
		   Aadd( _aCabPV, { "C5_CLIENTE"   ,SC5->C5_CLIENTE , NiL})//Codigo do cliente
		   Aadd( _aCabPV, { "C5_CLIENT"    ,SC5->C5_CLIENT	, Nil})
		   Aadd( _aCabPV, { "C5_LOJAENT"   ,SC5->C5_LOJAENT , NiL})//Loja para entrada
		   Aadd( _aCabPV, { "C5_LOJACLI"   ,SC5->C5_LOJACLI , NiL})//Loja do cliente
		   Aadd( _aCabPV, { "C5_EMISSAO"   ,SC5->C5_EMISSAO , NiL})//Data de emissao
		   Aadd( _aCabPV, { "C5_TRANSP"    ,SC5->C5_TRANSP	, Nil})
		   Aadd( _aCabPV, { "C5_CONDPAG"   ,SC5->C5_CONDPAG , NiL})//Codigo da condicao de pagamanto*
		   Aadd( _aCabPV, { "C5_VEND1"     ,SC5->C5_VEND1	, Nil})
	       Aadd( _aCabPV, { "C5_MOEDA"	  ,SC5->C5_MOEDA   , Nil})//Moeda
		   Aadd( _aCabPV, { "C5_MENPAD"    ,SC5->C5_MENPAD	, Nil})
		   Aadd( _aCabPV, { "C5_LIBEROK"   ,SC5->C5_LIBEROK , NiL})//Liberacao Total
	       Aadd( _aCabPV, { "C5_TIPLIB"    ,SC5->C5_TIPLIB  , Nil})//Tipo de Liberacao
		   Aadd( _aCabPV, { "C5_TIPOCLI"   ,SC5->C5_TIPOCLI , NiL})//Tipo do Cliente
		   Aadd( _aCabPV, { "C5_I_NPALE"   ,SC5->C5_I_NPALE , NiL})//Numero que originou a pedido de palete
		   Aadd( _aCabPV, { "C5_I_PEDPA"   ,SC5->C5_I_PEDPA , NiL})//Pedido Refere a um pedido de Pallet
		   Aadd( _aCabPV, { "C5_I_DTENT"   ,SC5->C5_I_DTENT , Nil}) //Dt de Entrega // SC5->C5_I_DTENT
		   Aadd( _aCabPV, { "C5_FECENT"    ,SC5->C5_FECENT , Nil}) //Dt de Entrega // SC5->C5_I_DTENT
		   Aadd( _aCabPV, { "C5_I_TRCNF"   ,SC5->C5_I_TRCNF , Nil})
		   Aadd( _aCabPV, { "C5_I_BLPRC"   ,SC5->C5_I_BLPRC , Nil})
		   Aadd( _aCabPV, { "C5_I_BLCRE"   ,SC5->C5_I_BLCRE , Nil})
		   Aadd( _aCabPV, { "C5_I_FILFT"   ,SC5->C5_I_FILFT , Nil})
		   Aadd( _aCabPV, { "C5_I_FLFNC"   ,SC5->C5_I_FLFNC , Nil})
		   Aadd( _aCabPV, { "C5_I_BLCRE"   ,SC5->C5_I_BLCRE , Nil})
		   Aadd( _aCabPV, { "C5_USERLGA"   ,u_retlgilga(__cUserId), Nil})
		   Aadd( _aCabPV, { "C5_I_TIPCA"   ,SC5->C5_I_TIPCA , Nil})
		   Aadd( _aCabPV, { "C5_I_AGEND"   ,SC5->C5_I_AGEND , Nil})
		   Aadd( _aCabPV, { "C5_I_OBCOP"   ,SC5->C5_I_OBCOP , Nil})
		   Aadd( _aCabPV, { "C5_MENNOTA"   ,SC5->C5_I_OBCOP , Nil})
		   Aadd( _aCabPV, { "C5_I_OBPED"   ,SC5->C5_I_OBCOP, Nil})
		   Aadd( _aCabPV, { "C5_TPFRETE"   ,SC5->C5_TPFRETE , Nil})
		   Aadd( _aCabPV, { "C5_I_TAB"     ,SC5->C5_I_TAB  , Nil})

		   _cCodTab := SC5->C5_I_TAB

		   _ltemlib := .T.
		   _cProdPe := U_ITGETMV( "IT_PRODPE" , "  ")	// Produtos permitidos que não validam quantidades fracinadas
		   _cLocval := U_ITGETMV( "IT_LOCFRA" , "  ")	// Armazéns que não valida quantidade fracionada

           _nTotPesBr := 0

          //=======================================================================================================================================================
          //             1=Filial      ,2=Numero PV     , 3=Codigo Produto           , 4=Quantidade            ,5=Item       ,6=Mesclar            ,7=Ação  
		  // _aProcItem={_cFilial      ,_aPedJSon[_nI,1], _aProdutos["codigoProduto"], _aProdutos["quantidade"],""            ,_aProdutos["mesclar"],"REJEITAR"})
          // _aProcItem={SC6->C6_FILIAL,SC6->C6_NUM     , SC6->C6_PRODUTO            , SC6->C6_QTDVEN          , SC6->C6_ITEM ,.F.                  ,"EXCLUIR" })
          //=======================================================================================================================================================

			For _nX := 1 To Len(_aProcItem)

				//Analisa se item está com liberação válida
				//SC9->(Dbsetorder(1))
				//If !( SC9->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM+_aProcItem[_nX,5])) .AND. SC9->C9_BLEST = '  ')
				//	_ltemlib := .F.
				//EndIf

				_cCodProd := _aProcItem[_nX,3]

				SB1->(Dbsetorder(1))
				If ! SB1->(DbSeek(xFilial("SB1")+_cCodProd ))
				   _cMsgErro := "Código de Produto não cadastrado: "+AllTrim(_cCodProd)+"."
				   Disarmtransaction()
				   Break
				ElseIf SB1->B1_MSBLQL == "1" // Bloqueado
				   _cMsgErro := "Código de Produto bloqueado: "+AllTrim(_cCodProd)+"."
				   Disarmtransaction()
				   Break
				EndIf
                
				If _aProcItem[_nX,7] == "EXCLUIR"
				   _cDeleta := "S"
				Else
				   _cDeleta := "N"
				EndIf

                If _aProcItem[_nX,8] == "1" // CX    //Verificação para produtos normais
				   _cUM   := SB1->B1_UM
				   _c2UM  := SB1->B1_SEGUM
				   If SB1->B1_TIPCONV == "M"
					  _nQtd  := _aProcItem[_nX,4] / SB1->B1_CONV
					  _cFator := AllTrim(Str(SB1->B1_CONV,18,6))
					  _cTipoOper := " Multiplicação. "
				   Else
					  _nQtd  := _aProcItem[_nX,4] * SB1->B1_CONV
					  _cFator := AllTrim(Str(SB1->B1_CONV,18,6))
					  _cTipoOper := " Divisão. "
				   EndIf
					
				   _n2Qtd := _aProcItem[_nX,4]

				ElseIf _aProcItem[_nX,8] == "2" // Unidade
				   _cUM   := SB1->B1_UM
				   _c2UM  := SB1->B1_SEGUM
				   _nQtd  := _aProcItem[_nX,4]
				   If SB1->B1_TIPCONV == "M"
					  _n2Qtd := _aProcItem[_nX,4] * SB1->B1_CONV
					  _cFator := AllTrim(Str(SB1->B1_CONV,18,6))
					  _cTipoOper := " Multiplicação. "
				   Else
					  _n2Qtd := _aProcItem[_nX,4] / SB1->B1_CONV
					  _cFator := AllTrim(Str(SB1->B1_CONV,18,6))
					  _cTipoOper := " Divisão. "
				   EndIf
                Else
       			   _cUM   := SB1->B1_UM
				   _c2UM  := SB1->B1_SEGUM
				   _nQtd  := _aProcItem[_nX,4]
				   If SB1->B1_TIPCONV == "M"
				      _n2Qtd := _aProcItem[_nX,4] * SB1->B1_CONV
				      _cFator := AllTrim(Str(SB1->B1_CONV,18,6))
				      _cTipoOper := " Multiplicação. "
			       Else
				      _n2Qtd := _aProcItem[_nX,4] / SB1->B1_CONV
				      _cFator := AllTrim(Str(SB1->B1_CONV,18,6))
				      _cTipoOper := " Divisão. "
			       EndIf
				EndIf 

				SC6->(Dbsetorder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO 
				If SC6->(MsSeek(_cFilPedV+_cPedVenda+_aProcItem[_Nx,5]+_aProcItem[_Nx,3]))

					_aItemPV:={}

					//Analisa se é alteração ou desmembramento, se for desmembramento não mexe aqui na quantidade
					If _aProcItem[_nX,7] == "DESMEMBRAR"
                       
					   If SC5->C5_I_OPER == '05'
							_cMsgErro += "Filial: '"+Padr(_cFilPedV,_nTamFilial," ")+"', Pedido de Vendas: '"+SC5->C5_NUM
							_cMsgErro += "' nao pode ser desmembrado pois possui PV Vinculado ou Op Triangular. "
							Disarmtransaction()
							Break
						EndIf

						_n2Qtd := SC6->C6_UNSVEN
						_nQtd := SC6->C6_QTDVEN
						_nqpallets := SC6->C6_I_QPALT
						_cmotivs:="98"//para gravar o motivo 98 no ITGrvLog()
					Else
                       If SB1->B1_I_UMPAL == '1'
						  _nqpallets := Int(_nQtd / SB1->B1_I_CXPAL )
			           ElseIf SB1->B1_I_UMPAL == '2'
						  _nqpallets	:= Int( _n2Qtd / SB1->B1_I_CXPAL )
				       Else 
                          _nqpallets := Int(_nQtd / SB1->B1_I_CXPAL )
					   EndIf 
					EndIf

					AAdd( _aItemPV , { "LINPOS"     ,"C6_ITEM", SC6->C6_ITEM }) //  Informa a posição do item
					AAdd( _aItemPV , { "AUTDELETA"  ,_cDeleta        , Nil }) // Informa se o item será ou não excluído.
					AAdd( _aItemPV , { "C6_FILIAL"  ,SC6->C6_FILIAL  , Nil }) // FILIAL
					AAdd( _aItemPV , { "C6_NUM"     ,SC6->C6_NUM     , Nil }) // Num. Pedido
					AAdd( _aItemPV , { "C6_ITEM"    ,SC6->C6_ITEM    , Nil }) // Numero do Item no Pedido
					AAdd( _aItemPV , { "C6_PRODUTO" ,SC6->C6_PRODUTO , Nil }) // Codigo do Produto
					AAdd( _aItemPV , { "C6_QTDVEN"  ,_nQtd           , Nil }) // Quantidade Vendida
					AAdd( _aItemPV , { "C6_UNSVEN"  ,_n2Qtd          , Nil }) // Quantidade Vendida 2 un
					AAdd( _aItemPV , { "C6_PRCVEN"  ,SC6->C6_PRCVEN  , Nil }) // Preco Unitario Liquido
					AAdd( _aItemPV , { "C6_PRUNIT"  ,SC6->C6_PRUNIT  , Nil }) // Preco Unitario Liquido
					AAdd( _aItemPV , { "C6_ENTREG"  ,SC6->C6_ENTREG  , Nil }) // Data da Entrega
					AAdd( _aItemPV , { "C6_LOJA"    ,SC6->C6_LOJA	  , Nil })
					AAdd( _aItemPV , { "C6_SUGENTR" ,SC6->C6_SUGENTR , Nil }) // Data da Entrega
					AAdd( _aItemPV , { "C6_VALOR"   ,round((SC6->C6_PRCVEN * _nQtd),2), Nil }) // valor total do item // SC6->C6_VALOR
					AAdd( _aItemPV , { "C6_UM"      ,SC6->C6_UM      , Nil }) // Unidade de Medida Primar.
					AAdd( _aItemPV , { "C6_LOCAL"   ,SC6->C6_LOCAL   , Nil }) // Almoxarifado
					AAdd( _aItemPV , { "C6_DESCRI"  ,SC6->C6_DESCRI  , Nil }) // Descricao
					AAdd( _aItemPV , { "C6_QTDLIB"  ,SC6->C6_QTDLIB  , Nil }) // Quantidade Liberada
					AAdd( _aItemPV , { "C6_PEDCLI"  ,SC6->C6_PEDCLI  , Nil })
					AAdd( _aItemPV , { "C6_I_BLPRC" ,SC6->C6_I_BLPRC , Nil })
					AAdd( _aItemPV , { "C6_I_VLIBP" ,SC6->C6_I_VLIBP , Nil }) // Preco Liberado
					AAdd( _aItemPV , { "C6_I_QPALT" ,_nqpallets      , Nil }) // Quantidade de Pallets

					AAdd( _aItemPV , { "C6_I_PTBRU" ,_nQtd * SB1->B1_PESBRU , Nil })

					_nTotPesBr += (_nQtd * SB1->B1_PESBRU)

					AAdd( _aItensPV ,_aItemPV )
				EndIf
			Next _nX

			Aadd( _aCabPV, { "C5_PBRUTO"    ,_nTotPesBr  , Nil})
			Aadd( _aCabPV, { "C5_I_PESBR"   ,_nTotPesBr  , Nil})


		    // Para executar o execauto precisa estar com C5_I_ENVRD = "N"
			Reclock("SC5",.F.)
			SC5->C5_I_ENVRD := "N"
			SC5->(Msunlock())

            //================================================================
			// Roda o MsExecauto de alteração de pedidos de vendas.
			//================================================================
			lMsErroAuto:=.F.
			
			MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPV , _aItensPV , 4 )

			Reclock("SC5",.F.)
			SC5->C5_I_ENVRD := "S"
			SC5->(Msunlock())

			If lMsErroAuto
			   _cNomeArqLog := "Pedido_"+AllTrim(SC5->C5_NUM)+"_"+DTos(Date())+"_"+StrTran(Time(),":","_")+".log"
			   _cMsg := MostraErro("\system\", _cNomeArqLog)
			   
			   _cMsgErro +=  "Erro na alteração do pedido de vendas: "+AllTrim(SC5->C5_NUM)+". "+_cMsg
			   DisarmTransaction()
			   Break
			EndIf
            
            //=======================================================================================================================================================
            //             1=Filial      ,2=Numero PV     , 3=Codigo Produto           , 4=Quantidade            ,5=Item       ,6=Mesclar            ,7=Ação  
		    // _aProcItem={_cFilial      ,_aPedJSon[_nI,1], _aProdutos["codigoProduto"], _aProdutos["quantidade"],""            ,_aProdutos["mesclar"],"REJEITAR"})
            // _aProcItem={SC6->C6_FILIAL,SC6->C6_NUM     , SC6->C6_PRODUTO            , SC6->C6_QTDVEN          , SC6->C6_ITEM ,.F.                  ,"EXCLUIR" })
            //=======================================================================================================================================================

			//=====================================================================
			// Este trecho trata o desmembramento de pedidos de vendas.
			//=====================================================================
			_aItemPV := {}
			_ldesmem := .F.
            
			SC6->(Dbsetorder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO 

			For _nX := 1 To Len(_aProcItem)
                If _aProcItem[_nX,7] == "EXCLUIR"
                   Loop 
			    EndIf 

				SC6->(MsSeek(_cFilPedV+_cPedVenda+_aProcItem[_Nx,5]+_aProcItem[_Nx,3]))

				_cCodProd := _aProcItem[_nX,3]

				SB1->(Dbsetorder(1))
				SB1->(Dbgotop())
				SB1->(DbSeek(xFilial("SB1")+_cCodProd ))

                If _aProcItem[_nX,8] == "1" // CX    //Verificação para produtos normais
				   _cUM   := SB1->B1_UM
				   _c2UM  := SB1->B1_SEGUM
				   If SB1->B1_TIPCONV == "M"
				      _nQtd  := _aProcItem[_nX,4] / SB1->B1_CONV
				      _cFator := AllTrim(Str(SB1->B1_CONV,18,6))
				      _cTipoOper := " Multiplicação. "
				   Else
				      _nQtd  := _aProcItem[_nX,4] * SB1->B1_CONV
				      _cFator := AllTrim(Str(SB1->B1_CONV,18,6))
				      _cTipoOper := " Divisão. "
				   EndIf
					
				   _n2Qtd := _aProcItem[_nX,4]

				ElseIf _aProcItem[_nX,8] == "2" // Unidade
				   _cUM   := SB1->B1_UM
				   _c2UM  := SB1->B1_SEGUM
				   _nQtd  := _aProcItem[_nX,4]
				   If SB1->B1_TIPCONV == "M"
				      _n2Qtd := _aProcItem[_nX,4] * SB1->B1_CONV
				      _cFator := AllTrim(Str(SB1->B1_CONV,18,6))
				      _cTipoOper := " Multiplicação. "
				   Else
				      _n2Qtd := _aProcItem[_nX,4] / SB1->B1_CONV
				      _cFator := AllTrim(Str(SB1->B1_CONV,18,6))
				      _cTipoOper := " Divisão. "
				   EndIf
                Else
                   _cUM   := SB1->B1_UM
				   _c2UM  := SB1->B1_SEGUM
				   _nQtd  := _aProcItem[_nX,4]
				   If SB1->B1_TIPCONV == "M"
				      _n2Qtd := _aProcItem[_nX,4] * SB1->B1_CONV
				      _cFator := AllTrim(Str(SB1->B1_CONV,18,6))
				      _cTipoOper := " Multiplicação. "
			       Else
				      _n2Qtd := _aProcItem[_nX,4] / SB1->B1_CONV
				      _cFator := AllTrim(Str(SB1->B1_CONV,18,6))
				      _cTipoOper := " Divisão. "
			       EndIf
				EndIf 
  
				//Analisa se é desmembramento, se não for, inclui com a quantidade atual do item para não mexer

				If _aProcItem[_nX,7] == "DESMEMBRAR"

                   Aadd(_aItemPV,{_aProcItem[_nX,5], _nQtd})
				   _ldesmem := .T.

				Else

				   Aadd(_aItemPV,{SC6->C6_ITEM, SC6->C6_QTDVEN})

				Endif

		    Next

		    If _ldesmem

		       //Para executar o execauto precisa estar com C5_I_ENVRD = "N"
			   Reclock("SC5",.F.)
			   SC5->C5_I_ENVRD := "N"
			   SC5->(Msunlock())
			   _npedori := SC5->(Recno())

				_aRet := U_AOMS098(SC5->C5_FILIAL,SC5->C5_NUM,_aItemPV, _cCodUsuario ) //Função que realiza desmembramento de pedido de vendas

				_npednovo := SC5->(Recno())

				SC5->(Dbgoto(_npedori))

				Reclock("SC5",.F.)
				SC5->C5_I_ENVRD := "S"
				SC5->(Msunlock())

				SC5->(Dbgoto(_npednovo))

				If _aRet[1] // Sucesso no desmembramento do pedido de vendas.
				   //Atualiza pedido desmembrado para C5_I_ENVRD = 'R' com data retroativa para que o schedule crie a tabela de muro e mande para o RDC
				   SC5->(Dbsetorder(1))
				   If SC5->(Dbseek(_cFilPedV+AllTrim(_aRet[2])))

					  Reclock("SC5", .F.)
					  SC5->C5_I_ENVRD := "R"
					  SC5->C5_I_DTRET := DATE() - 1
					  SC5->C5_I_HRRET := TIME()
					  SC5->(Msunlock())
				   Endif
     			Else // Falha o Desmembramento do pedido de vendas.
				   _cMsgErro += "Falha na geração de pedido desemembrado do pedido de vendas numero: "+ SC5->C5_NUM + ". " +;
				               _aRet[3] + CRLF + _aRet[5]
				   Disarmtransaction()
				   Break
  			    EndIf
			 Endif
         Next _nI 

   End Transaction

End Sequence
//===================================================================== 
//Desfaz todos os locks de cabeçalho
//===================================================================== 
SC5->(Msunlock())
SC5->(Msunlockall())
SA1->(Msunlock())
SA1->(Msunlockall())

RestOrd(_aOrd)

//Garante que vai liberar lock de todos os cabeçalhos e todos os itens
SC5->(Dbsetorder(1))
For _nX := 1 To Len(_aPedido)

	If SC5->(MsSeek(_cFilPedV+_aPedido[_nX]))
	   SC5->(Msunlock())
	   SC5->(Msunlockall())

	   ZFQ->(Dbsetorder(3))
	   If ZFQ->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))
		  Do while ZFQ->ZFQ_FILIAL == SC5->C5_FILIAL .AND. ZFQ->ZFQ_PEDIDO == SC5->C5_NUM
			 ZFQ->(MSUNLOCKALL())
			 ZFQ->(Msunlock())

		     ZFQ->(Dbskip())
		  Enddo
	   EndIf

	   ZFR->(Dbsetorder(3))
	   If ZFR->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))
		  Do While ZFR->ZFR_FILIAL == SC5->C5_FILIAL .AND. ZFR->ZFR_NUMPED == SC5->C5_NUM
  			 ZFR->(MSUNLOCKALL())
			 ZFR->(Msunlock())

			 ZFR->(Dbskip())
          Enddo
	   EndIf

	   SA1->(Dbsetorder(1))
	   If SA1->(Dbseek(xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
		  SA1->(Msunlock())
		  SA1->(Msunlockall())
       EndIf

	   SC6->(Dbsetorder(1))
	   If SC6->(Dbseek(_cFilPedV+_aPedido[_nX]))
		  Do while SC6->C6_FILIAL == SC5->C5_FILIAL .AND. SC6->C6_NUM == SC5->C5_NUM
			 SC6->(Msunlock())
			 SC6->(Msunlockall())

			 SB2->(Dbsetorder(1))
			 If SB2->(Dbseek(SC6->C6_FILIAL+SC6->C6_PRODUTO+SC6->C6_LOCAL))
				SB2->(Msunlock())
				SB2->(Msunlockall())
			 EndIf

			 SC6->(Dbskip())
		  EndDo
	   EndIf
	EndIf
Next 

If ! Empty(_cMsgErro)
   _aRet := {.F.,_cMsgErro}
Else 
   _aRet := {.T.,_cMsgErro}
EndIf 

Return _aRet



