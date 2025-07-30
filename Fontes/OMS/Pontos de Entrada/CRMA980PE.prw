/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
    Autor    |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Igor Melga�o | 11/10/2021 | Chamado 37363. Ajustes para n�o bloquear o vendedor na efetiva��o do prospect. 
Igor Melga�o | 04/11/2021 | Chamado 37363. Retirada de trecho para revis�o 4023 do fonte MA030BUT. 
Igor Melga�o | 10/11/2021 | Chamado 37363. Adi��o de fun��o para execu��o no When dos campos da SA1. 
Julio Paz    | 20/12/2021 | Chamado 25540. Desenv.Rotina Env.WorkFlow quando vendedor1,2,3,4 for alter.e Grupo Env.WorkFlow.
Igor Melga�o | 30/05/2022 | Chamado 40048. Adi��o de fun��o para valida��o de caracteres inv�lidos. 
Julio Paz    | 09/08/2022 | Chamado 40841. limpar conte�do campos Suframa,p/clientes n�o fazem parte de estados Suframa.
Julio Paz    | 09/08/2022 | Chamado 40931. Incl/Alt funcion�rios, Gravar cad.Clientes:Segmento=39/Tipo=Consumidor Final.
Igor Melga�o | 11/08/2022 | Chamado 40048. Ajustes para substitui��o de caracteres invalidos. 
Alex Wallauer| 17/02/2023 | Chamado 42425. Novo Tratamento para gravacao do campo A1_CONTRIB na nova Funcao CRMA980CON().
Julio Paz    | 24/05/2023 | Chamado 43808. Ajustar layout/valida��es execauto p/Importa��o Clientes Broker p/novo layout.  
Julio Paz    | 07/07/2023 | Chamado 44399. Corre��es nas valida��es de cadastro clientes criados na efetiva��o prospect
Igor Melga�o | 18/07/2023 | Chamado 41015. Ajustes para corre��o de error.log. 
Julio Paz    | 25/07/2023 | Chamado 44096. Ajustar rotina incl/alter gravar Grupo Tributa��o "023" p/Parana e Simples Nac
Alex Wallauer| 16/10/2023 | Chamado 45270. Novo regra para gravacao do campo A1_CONTRIB na Funcao CRMA980CON().
Igor Melga�o | 30/11/2023 | Chamado 30952. Nova valida��o dos campos de endere�o do cadatro de Cliente e Fornecedor. 
Antonio Neves| 12/12/2023 | Chamado 45802. Corre��o do caracter especial "grau" no retorno da CISP. 
Antonio Neves| 07/02/2024 | Chamado 46248. Adicionada as UFs AC - RO nos Estados do Suframa
Igor Melga�o | 19/06/2024 | Chamado 47127. Ajuste para n�o gravar o campo A1_MSBLQL.
Igor Melga�o | 12/07/2024 | Chamado 47556. Ajuste para preenchimento obrigat�rio do campo A1_CNAE.
Igor Melga�o | 29/07/2024 | Chamado 47955. Ajuste para tratamento da inscri��o estadual. 
Lucas Borges | 23/07/2025 | Chamado 51340. Trocado e-mail padr�o para sistema@italac.com.br
===============================================================================================================================
Analista         - Programador       - Inicio     - Envio      - Chamado - Motivo da Altera��o
---------------------------------------------------------------------------------------------------------------------------------------------------------
Bruno dos Reis   - Igor Melga�o      - 15/01/2025 - 14/02/2025 - 49377   - Ajuste para execu��o atraves do MGPE028.
Antonio          - Julio Paz         - 17/06/2025 - 27/06/2025 - 50278   - Cria��o de Campo e Inclus�o de valida��es para determinar usu�rios que podem incluir/alterar clientes com base nos limetes de cr�dito.
Antonio          - Julio Paz         - 01/07/2025 - 01/07/2025 - 51203   - Ajustar as valida��es por limite de cr�dito para n�o validar quando for MSEXECAUTO dos fontes: GP010VALPE/GPE10MENU/MOMS003/MOMS055. 
=========================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "parmtype.ch"
#INCLUDE "rwmake.ch" 
#INCLUDE "TOPCONN.CH"   
#Include 'fileio.ch'

#define CRLF		Chr(13) + Chr(10)

Static _lAltCodTab := .F.

Static _aBloqSA1 := {}  // Array Static para guardar informa��es de bloqueio por desconto contratual.

/*
===============================================================================================================================
Programa----------: CRMA980
Autor-------------: Igor Melga�o
Data da Criacao---: 24/08/2021
===============================================================================================================================
Descri��o---------: Ponto de entrada MVC CRMA980 que substitui mata030.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: lRet 
===============================================================================================================================
*/
User Function CRMA980()
    Local aParam := PARAMIXB
    Local xRet := .T.
    Local oObj := ""
    Local cIdPonto := ""
    Local cIdModel := ""
    Local lIsGrid := .F.
	Local _oModel := FWModelActive()
	Local _oModelSA1
	Local _cVend1,_cVend2,_cVend3,_cVend4
	Local _aListaVend, _cEnvWorkF, _cNomeGrupo
    Local _cNomVendA, _cNomVendB, _cGrpVend
    Local _nOperation, _cDescCont
	Local _cBloq, _cBloqDesc
	
	Local _cUfMVA := U_ITGetMV("IT_UFSMVA","PR") 
    Local _cTRIBMVA
	Local _nLimCTela 
    Local _nLimeteAp 

    If aParam <> NIL
        oObj := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
        lIsGrid := (Len(aParam) > 3)
        If cIdPonto == "MODELPOS" //"Chamada na valida��o total do modelo."

        ElseIf cIdPonto == "FORMPOS" //"Chamada na valida��o total do formul�rio."

			_oModelSA1  := _oModel:GetModel('SA1MASTER')

            xRet := CRMA980TOK(_oModelSA1)			
            
			_nOperation := _oModel:GetOperation()

            //==================================================================
            // Valida permiss�o do usu�rio para incluir ou alterar um cliente.
            // Tendo como base o limite de cr�dito no cadastro de usu�rios. 
            //==================================================================
			If ! FWIsInCallStack("U_GP010VALPE") .And. ! FWIsInCallStack("IMPORTAFUN") .And. ! FWIsInCallStack("U_IMPCLI") .And. ! FWIsInCallStack("MOMS003L") .And. ! FWIsInCallStack("MOMS055I")
               _nLimCTela := _oModelSA1:GetValue("A1_LC")
               _nLimeteAp := Posicione("ZZL",3,xfilial("ZZL")+AllTrim(__cUserId),"ZZL_VLMAXP") // ZZL_FILIAL+ZZL_CODUSU
               If ValType(_nLimeteAp) <> "N"
                  _nLimeteAp := 0
               EndIf 
 
               If _nOperation == MODEL_OPERATION_INSERT .And. xRet
                  If _nLimCTela > _nLimeteAp
                     U_ITMSG("O Valor do limite de cr�dito deste cliente: " + AllTrim(Str(_nLimCTela,14,2)) + ", � superior ao limite permitido para este usu�rio incluir o cliente: " + AllTrim(Str(_nLimeteAp,14,2))+".","Aten��o","",1)
                     xRet := .F.      
                  EndIf 
               EndIf 

               If _nOperation == MODEL_OPERATION_UPDATE .And. xRet
                  If _nLimCTela <> SA1->A1_LC 
                     If _nLimCTela > _nLimeteAp
                        U_ITMSG("O Valor do limite de cr�dito deste cliente: " + AllTrim(Str(_nLimCTela,14,2)) + ", � superior ao limite permitido para este usu�rio alterar o cliente: " + AllTrim(Str(_nLimeteAp,14,2))+".","Aten��o","",1)
                        _lRet := .F.      
                     EndIf 
                  EndIF 
               EndIf 
            EndIf 

            //=============================================================================
			// Demais valida��es da Rotina de manuten��o de clientes em MVC
			//=============================================================================
            If xRet .And. _nOperation == MODEL_OPERATION_UPDATE //_oModelSA1:IsUpdated()
               _cVend1   := _oModelSA1:GetValue("A1_VEND")
			   _cVend2   := _oModelSA1:GetValue("A1_I_VEND2")
			   _cVend3   := _oModelSA1:GetValue("A1_I_VEND3")
			   _cVend4   := _oModelSA1:GetValue("A1_I_VEND4")
               _cGrpVend := _oModelSA1:GetValue("A1_GRPVEN")
		       //===================================================================================
               // Verifica se houve altera��es nos Vendedores para envio de Workflow para o
               // Respons�vel.
               //===================================================================================
               If (_cVend1 <> SA1->A1_VEND ;
                  .OR. _cVend2 <> SA1->A1_I_VEND2;
                  .OR. _cVend3 <> SA1->A1_I_VEND3;
                  .OR. _cVend4 <> SA1->A1_I_VEND4)
          
                   _aListaVend := {} 

                   _cEnvWorkF  := Posicione("ACY",1,xFilial("ACY")+_cGrpVend,"ACY_I_ALTV") // 1 = ACY_FILIAL+ACY_GRPVEN 
                   _cNomeGrupo := Posicione("ACY",1,xFilial("ACY")+_cGrpVend,"ACY_DESCRI")

	               If _cEnvWorkF == "S"

                      If _cVend1 <> SA1->A1_VEND
                         _cNomVendA := Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND,"A3_NOME")
                         _cNomVendB := Posicione("SA3",1,xFilial("SA3")+_cVend1,"A3_NOME")
		                 Aadd(_aListaVend,{M->A1_GRPVEN,_cNomeGrupo, SA1->A1_VEND,_cNomVendA,_cVend1,_cNomVendB,"Vendedor1"})
		              EndIf 

	                  If _cVend2 <> SA1->A1_I_VEND2
                         _cNomVendA := Posicione("SA3",1,xFilial("SA3")+SA1->A1_I_VEND2,"A3_NOME")
                         _cNomVendB := Posicione("SA3",1,xFilial("SA3")+_cVend2,"A3_NOME")
		                 Aadd(_aListaVend,{M->A1_GRPVEN,_cNomeGrupo, SA1->A1_I_VEND2,_cNomVendA,_cVend2,_cNomVendB,"Vendedor2"})
		              EndIf 

	                  If _cVend3 <> SA1->A1_I_VEND3
                         _cNomVendA := Posicione("SA3",1,xFilial("SA3")+SA1->A1_I_VEND3,"A3_NOME")
                         _cNomVendB := Posicione("SA3",1,xFilial("SA3")+_cVend3,"A3_NOME")
		                 Aadd(_aListaVend,{M->A1_GRPVEN,_cNomeGrupo, SA1->A1_I_VEND3,_cNomVendA,_cVend3,_cNomVendB,"Vendedor3"})
		              EndIf 

	                  If _cVend4 <> SA1->A1_I_VEND4
                         _cNomVendA := Posicione("SA3",1,xFilial("SA3")+SA1->A1_I_VEND4,"A3_NOME")
                         _cNomVendB := Posicione("SA3",1,xFilial("SA3")+_cVend4,"A3_NOME")
		                 Aadd(_aListaVend,{M->A1_GRPVEN,_cNomeGrupo, SA1->A1_I_VEND4,_cNomVendA,_cVend4,_cNomVendB,"Vendedor4"})
		              EndIf 
                      
					  U_CRMA980X(_aListaVend)

	               EndIf 
                EndIf  
             EndIf 

            //===================================================================================
            // Realiza bloqueio de Cliente por desconto contratual. Chamado 30177.
            //===================================================================================
            If xRet .And. (_nOperation == MODEL_OPERATION_UPDATE .Or. _nOperation == MODEL_OPERATION_INSERT)
               
			   _cGrpVend  := _oModelSA1:GetValue("A1_GRPVEN")
               _cDescCont := Posicione("ACY",1,xFilial("ACY")+_cGrpVend,"ACY_I_DESC") // ACY_FILIAL+ACY_GRPVEN  
               
			   _cBloq     := _oModelSA1:GetValue("A1_MSBLQL")
			   _cBloqDesc := _oModelSA1:GetValue("A1_I_BLQDC")
			   _aBloqSA1  := {.F.,;          // Bloqueio por contrato
	                         _cBloq,;        // Bloqueio por Cliente
		                     _cBloqDesc}     // Bloqueio Contrato 
               
               If (AllTrim(_cDescCont) == "S" .And. _nOperation == MODEL_OPERATION_INSERT) .Or. (_nOperation == MODEL_OPERATION_UPDATE .And. _cGrpVend <> SA1->A1_GRPVEN .And. AllTrim(_cDescCont) == "S")

                  // If AllTrim(_cDescCont) == "S"
                  
	              If U_ItMsg("O grupo de cliente informado para este cliente possui uma regra de desconto contratual preexistente,"+;
	                         " ao confirmar este cadastro o mesmo ser� bloqueado para an�lise do setor de contratos. "+ CRLF +;
				             " Deseja prosseguir?", "Aten��o", "",2,2,2) // 3,2,2 
		 		           
		             _aBloqSA1 := {.T.,;     // Bloqueio por contrato
		                           "1",;     // Bloqueio por Cliente
					               "1"}      // Bloqueio Contrato
		           
                  Else
		             _aBloqSA1 := {.F.,;          // Bloqueio por contrato
		                            "",;   //M->A1_MSBLQL,; // Bloqueio por Cliente
				                    ""}    //M->A1_I_BLQDC} // Bloqueio Contrato
                   
		             xRet := .F. 
                  EndIf 
               EndIf 
            EndIf 

        ElseIf cIdPonto == "FORMLINEPRE" //"Chamada na pr� valida��o da linha do formul�rio. " 

        ElseIf cIdPonto == "FORMLINEPOS" //"Chamada na valida��o da linha do formul�rio."

        ElseIf cIdPonto == "MODELCOMMITTTS" //"Chamada ap�s a grava��o total do modelo e dentro da transa��o."
            
            If oObj:GetOperation() == MODEL_OPERATION_UPDATE//ALTERACAO
                CRMA980MC()
                CRMA980PT(aParam)
				U_CRMA980CON()
                Return .T.
            ElseIf oObj:GetOperation() == MODEL_OPERATION_INSERT//INCLUSAO
                CRMA980INC()
				U_CRMA980CON()
                Return .T.
            EndIf
        
		ElseIf cIdPonto == "MODELCOMMITNTTS" //"Chamada apos a gravacao total do modelo e fora da transacao."
		    //=======================================================================
            // Verifica se as valida��es da rotina de desconto contratual se 
            // deve bloquear o Cliente. Caso afirmativo bloqueia o cliente por 
            // Desconto Contratual.
            //=======================================================================
            If _aBloqSA1[1]   // Bloqueia SA1 por Desconto Contratual = True or False
               SA1->(RECLOCK("SA1",.F.))
               //SA1->A1_MSBLQL  := "1" // Bloqueio por Cliente
               SA1->A1_I_BLQDC := "1"
               SA1->(MsUnlock())
               //==================================================================
               // Envia Workflow de bloqueio de clientes por desconto contratual.
               //==================================================================
               U_CRMA980Y()

            EndIf 
			
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
			Else 
			   If SA1->A1_GRPTRIB == _cTRIBMVA
			      SA1->(RECLOCK("SA1",.F.))
                  SA1->A1_GRPTRIB := " "
				  SA1->(MsUnlock())
               EndIf	
	        EndIf 


        ElseIf cIdPonto == "FORMCOMMITTTSPRE" //"Chamada ap�s a grava��o da tabela do formul�rio."

        ElseIf cIdPonto == "FORMCOMMITTTSPOS" //"Chamada ap�s a grava��o da tabela do formul�rio."

        ElseIf cIdPonto == "MODELCANCEL"

        ElseIf cIdPonto == "BUTTONBAR"
            xRet := CRMA980BUT(aParam)
        EndIf
    EndIf

Return xRet

/*
===============================================================================================================================
Programa----------: CRMA980MC
Autor-------------: Igor Melga�o
Data da Criacao---: 25/08/2021
===============================================================================================================================
Descri��o---------: Ponto de entrada para gravar os dados do cadastro do Cliente ap�s a altera��o. 
                    Substituiu o MALTCLI do mata030.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function CRMA980MC()

Local _aArea	:= GetArea()
Local _cCodUsr	:= RetCodUsr()
Local _cConta	:= ''

//================================================================================
//| Verifica se o LOG de Altera��es est� ativo e chama a ggrava��o do LOG        |
//================================================================================
If Type("_aITASA1") == "A" .And. !Empty(_aITASA1)
	U_ITGrvLog( _aITASA1 , "SA1" , 1 , SA1->( A1_FILIAL + A1_COD + A1_LOJA ) , "A" , _cCodUsr )
EndIf

_aITASA1 := {}

RestArea( _aArea )

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

Return



/*
===============================================================================================================================
Programa----------: CRMA980PT
Autor-------------: Igor Melga�o
Data da Criacao---: 25/08/2021
===============================================================================================================================
Descri��o---------: Ponto de entrada executado para valida��o ap�s confirma��o da altera��o do cliente
                    Substitui o M030PALT.
===============================================================================================================================
Parametros--------: PARAMIXB[1] - nOpc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function CRMA980PT(aParam)

Local _aArea	:= GetArea()
Local _nOpcao	:= aParam[1]
Local _lRet	 	:= .T.
Local _lMashup	:= U_ItGetMV("IT_MASHUP",.F.)
Local _lLibMas	:= .F.
Local _nQtdDia	:= Val(SA1->A1_I_PEREX)
Local _nQtdiaT	:= dDataBase - SA1->A1_I_DTEXE
Local _lExec	:= Iif(_nQtdDia > _nQtdiaT, .T., .F.)

Begin Sequence   
	If _nOpcao == 1
	   //===================================================================================
       // Grava os dados dos clientes nas tabelas de muro para integra��o com o sistema RDC.
       //===================================================================================
       U_AOMS076G()
   
       //===================================================================================
       // Rotina de Mashup
       //===================================================================================
		If _lMashup
			If SA1->A1_PESSOA <> "F"
				_cUser := RetCodUsr()
			
				DBSelectArea("ZZL")
				ZZL->( DBSetOrder(3) )
				If ZZL->( DBSeek( xFilial("ZZL") + _cUser ) )
					If ZZL->ZZL_LIBMAS == "S"
						_lLibMas := .T.
					EndIf
				EndIf
	            
				If !_lLibMas
					If (ALLTRIM(SA1->A1_I_SITRF) <> "ATIVO" .AND. ALLTRIM(SA1->A1_I_SITRF) <> "REGULAR" .AND. ALLTRIM(SA1->A1_I_SITRF) <> "APTO" .AND. ALLTRIM(SA1->A1_I_SITRF) <> "ATIVA") .Or. _lExec
						If !(AllTrim(SA1->A1_I_NUM) $ SA1->A1_END)
							RecLock("SA1", .F.)
							If !Empty(SA1->A1_I_END) .And. Empty(SA1->A1_I_NUM) .And. Empty(SA1->A1_COMPLEM)
								SA1->A1_END := AllTrim(SA1->A1_I_END)
							ElseIf !Empty(SA1->A1_I_END) .And. !Empty(SA1->A1_I_NUM) .And. Empty(SA1->A1_COMPLEM)
								SA1->A1_END := AllTrim(SA1->A1_I_END) + ", " + AllTrim(SA1->A1_I_NUM)
							ElseIf !Empty(SA1->A1_I_END) .And. !Empty(SA1->A1_I_NUM) .And. !Empty(SA1->A1_COMPLEM)
								SA1->A1_END := AllTrim(SA1->A1_I_END) + ", " + AllTrim(SA1->A1_I_NUM) + " " + AllTrim(SA1->A1_COMPLEM)
							EndIf
						EndIf
						SA1->A1_I_DTEXE := dDataBase
						SA1->(MsUnLock())
					EndIf
				EndIf
			EndIf
		EndIf
		U_AOMS076G()
	EndIf
End Sequence

If !Empty(SA1->A1_INSCR)
	RecLock("SA1", .F.)
	SA1->A1_INSCR := AllTrim(Strtran(SA1->A1_INSCR,"-",""))
	MsUnLock()
EndIf

If _lAltCodTab 
    SA1->(RecLock("SA1", .F.))
	SA1->A1_TABELA := "" // Cliente alterado simples nacional = N�O, deve limpar o codigo da tabela de pre�os simples nacional.
	SA1->(MsUnLock())

   _lAltCodTab := .F.
EndIf 

RestArea(_aArea)

Return(_lRet)   


/*
===============================================================================================================================
Programa----------: CRMA980PTB
Autor-------------: Igor Melga�o
Data da Criacao---: 25/08/2021
===============================================================================================================================
Descri��o---------: Determina se o campo A1_TABELA ser� alterado ap�s a grava��o.
                    Substitui o M30PALTAB do Fonte MA030TOK.
===============================================================================================================================
Parametros--------: _lAltTabela = .T./.F.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function CRMA980PTB(_lAltTabela)

Begin Sequence
   If _lAltTabela 
      _lAltCodTab := .T.
   Else
      _lAltCodTab := .F.
   EndIf 
End Sequence

Return Nil 

/*
===============================================================================================================================
Programa----------: CRMA980INC
Autor-------------: Igor Melga�o
Data da Criacao---: 25/08/2021
===============================================================================================================================
Descri��o---------: Ponto de entrada para gravar os dados do cadastro do Cliente ap�s a inclus�o.
                    Substitui o M030INC.
===============================================================================================================================
Parametros--------: PARAMIXB -> Num�rico -> Tipo da opera��o do usu�rio. Conte�do 3 significa que o usu�rio cancelou a inclus�o.
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function CRMA980INC()

Local _aArea	:= GetArea()
Local _cConta	:= ''
Local _cEnd		:= ''

Local _lMashup	:= U_ItGetMV("IT_MASHUP",.F.)

Local _nQtdDia	:= 0
Local _nQtdiaT	:= 0
Local _lExec	:= .F.

Local _lLibMas	:= .F.

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

RestArea(_aArea)
Return



/*
===============================================================================================================================
Programa----------: CRMA980TOK
Autor-------------: Igor Melga�o
Data da Criacao---: 25/08/2021
===============================================================================================================================
Descri��o---------: Valida��es no cadastro de Clientes. Substitui o MA030TOK.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: L�gico com exibi��o de mensagens para tratativa das negativas
===============================================================================================================================
*/
Static Function CRMA980TOK(_oModelSA1)
Local _aParam    := PARAMIXB
Local _oObj
Local _aArea	:= GetArea()
Local _cAlias	:= GetNextAlias()
Local _cQuery	:= ""
Local _cUser	:= ""
Local _cCodigo	:= ""
Local _cTxtAux	:= ""
Local _lRet		:= .T.
Local _cfilsa1 	:= xFilial("SA1")
Local _ccodcli 	:= M->A1_COD
Local _cgrpcli 	:= M->A1_GRPVEN
Local _cloja	:= M->A1_LOJA

Local _lMashup	:= U_ItGetMV("IT_MASHUP",.F.)
Local _lLibMas	:= .F.

Local _nQtdDia	:= Val(M->A1_I_PEREX)
Local _nQtdiaT	:= Iif(Empty(M->A1_I_DTEXE),0,dDataBase - M->A1_I_DTEXE)
Local _lExec	:= Iif(_nQtdiaT > _nQtdDia, .T., .F.)

Local _cVendGen := U_ITGetMV("IT_VENDGEN","000156")
Local _cGrpGen  := U_ITGetMV("IT_GRPGEN","11")

Local _cA1_NOME    := ""
Local _cA1_END     := ""
Local _cA1_BAIRRO  := ""
Local _cA1_ENDCOB  := ""
Local _cA1_ENDREC  := ""
Local _cA1_ENDENT  := ""
Local _cA1_BAIRROE := ""

Private _cMensagem	:= ""
Private _lAuto		:= FunName() == "MOMS003"
Private _lVarLog	:= Type("_aLogM003") == "A"

_oObj := _aParam[1]

If _oObj:GetOperation() == MODEL_OPERATION_INSERT
	
	//================================================================================
	// Valida��o do c�digo de Cliente gerado automaticamente
	//================================================================================
	_cQuery := " SELECT MAX(A1_COD) AS CODIGO "
	_cQuery += " FROM "+ RetSqlName( 'SA1' )
	_cQuery += " WHERE D_E_L_E_T_ = ' ' "
	
	If Select(_cAlias) > 0
		(_cAlias)->( DBCloseArea() )
	EndIf
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQuery ) , _cAlias , .T. , .F. )
	
	DBSelectArea( _cAlias )
 	(_cAlias)->( DBGotop() )
	IF (_cAlias)->( !Eof() )
		_cCodigo := (_cAlias)->CODIGO
	Else
		_cCodigo := StrZero( 0 , TamSX3("A1_COD")[01] )
	EndIf
	
	(_cAlias)->( DBCloseArea() )
	
    If _cCodigo == M->A1_COD

		//Verifica se existe o codigo do cliente com a mesma loja ja cadastrado.
		_cQry := " SELECT COUNT(*) AS CONTADOR "
		_cQry += " FROM " + RetSqlName("SA1") + " "
		_cQry += " WHERE A1_COD = '" + M->A1_COD + "' "
		_cQry += "   AND A1_LOJA = '" + M->A1_LOJA + "' "

		DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBCLI" , .T. , .F. )
		
		dbSelectArea("TRBCLI")
		TRBCLI->(dbGotop())
		
		If TRBCLI->CONTADOR <> 0

			If _lAuto
				If _lVarLog
					aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"O c�digo de cliente: " + M->A1_COD + " e Loja: " + M->A1_LOJA + " j� existe." } )
				EndIf
			Else
				u_itmsg("Este c�digo de cliente j� est� em uso!","Valida��o C�digo","Favor digitar novamente o CPF/CNPJ.",1)
			EndIf
			
			_lRet := .F.

		EndIf
		
		dbSelectArea("TRBCLI")
		TRBCLI->(dbCloseArea())
	
	EndIf

	DBSelectArea( 'SA1' )
	SA1->( DBSetOrder (3) )
	If SA1->( DBSeek( xFilial("SA1") + M->A1_CGC ) )
	
		_cUser := RetCodUsr()
		
		DBSelectArea("ZZL")
		ZZL->( DBSetOrder(3) )
		If ZZL->( DBSeek( xFilial("ZZL") + _cUser ) )
		
			If ZZL->ZZL_INCCLI <> 'S'
				
				If _lAuto
					If _lVarLog
						aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"O usu�rio: " + Capital( UsrFullName( _cUser ) ) + " n�o tem permiss�o para incluir cliente que j� possui cadastro com o mesmo CPF/CNPJ" } )
					EndIf
				Else
					u_itmsg("O usu�rio "+ Capital( UsrFullName( _cUser ) ) +" n�o tem permiss�o para incluir um cliente que j� possui cadastro com o mesmo CPF/CNPJ.",;
							"Valida��o usu�rio",;
							"Informar a �rea de TI/ERP solicitando a libera��o!",1)
				EndIf
				
				_lRet := .F.
				
			EndIf
		
		Else

			If _lAuto
				If _lVarLog
					aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"O usu�rio: " + Capital( UsrFullName( _cUser ) ) + " n�o tem permiss�o para incluir cliente que j� possui cadastro com o mesmo CPF/CNPJ" } )
				EndIf
			Else
				u_itmsg("O usu�rio "+ Capital( UsrFullName( _cUser ) ) +" n�o tem permiss�o para incluir um cliente que j� possui cadastro com o mesmo CPF/CNPJ.",;
						"Valida��o usu�rio",;
						"Informar a �rea de TI/ERP solicitando a libera��o!",1)
			EndIf
			
			_lRet := .F.
			
		EndIf
		
	EndIf
	
	If _lRet .And. !IsInCallStack("U_AOMS014")
    	_lRet := CRMA980RIS()
    EndIf
	
EndIf

If _oObj:GetOperation() == MODEL_OPERATION_INSERT .Or. _oObj:GetOperation() == MODEL_OPERATION_UPDATE
   
    
	//================================================================================
	// Valida��o do preenchimento do campo de e-mail. Rotina automatica n�o deve mostrar
	//================================================================================
	If !IsInCallStack("U_GP010VALPE") .And. !IsInCallStack("U_GP265VALPE")
		If Empty( M->A1_EMAIL ) .AND. ( FunName() <> "MOMS003" ) .AND. FUNNAME() <> "GPEA010"
			
			If _lAuto
				If _lVarLog
					aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"O campo E-Mail n�o foi preenchido no cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + ". N�o cadastre endere�os gen�ricos." } )
				EndIf
			Else
				u_itmsg('O campo "e-mail" n�o foi preenchido, esse campo n�o � obrigat�rio mas deve ser preenchido com um endere�o v�lido!',;
						'Valida��o Email','N�o cadastre endere�os gen�ricos como "funcionarios@italac.com.br" ou nfe@italac.com.br', 3)
			EndIf		
	
		EndIf
	
		If Empty(M->A1_INSCR) .AND. ( FunName() <> "MOMS003" ) .AND. ( FunName() <> "GPEA010" )
	
			
			u_itmsg('Preencher como ISENTO quando for dispensado de IE e deixar em branco quando for n�o contribuinte do ICMS.  ',;
					'Aten��o','D�vidas procurar departamento FISCAL.',2)
	
		EndIf
		
	EndIf

    _cTxtAux := LTrim( StrTran( M->A1_NOME , '	' , '' ) )
    
    If _cTxtAux <> M->A1_NOME

    	If _lAuto
   			If _lVarLog
	   			aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"O campo Nome n�o foi preenchido no cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + "." } )
	   		EndIf
	   	Else
	   		u_itmsg("Erro no preenchimento do campo Nome!","Valida��o de Nome","� necess�rio retirar os espa�os em branco para prosseguir com o cadastro.",1)
	   	EndIf

   		_lRet := .F.
    EndIf
    
    _cTxtAux := LTrim( StrTran( M->A1_END , '	' , '' ) )
    
    If _cTxtAux <> M->A1_END
		
		If _lAuto
			If _lVarLog
				aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"O campo Endere�o n�o foi preenchido no cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + "." } )
			EndIf
		Else
			u_itmsg("Erro no preenchimento do campo Endere�o!","Valida��o de endere�o","� necess�rio retirar os espa�os em branco para prosseguir com o cadastro.",1)
		EndIf

   		_lRet := .F.
    EndIf
    
    _cTxtAux := LTrim( StrTran( M->A1_BAIRRO , '	' , "" ) )
    
    If _cTxtAux <> M->A1_BAIRRO
   		
   		If _lAuto
   			If _lVarLog
	   			aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"O campo Bairro n�o foi preenchido no cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + "." } )
	   		EndIf
   		Else
   			u_itmsg("Erro no preenchimento do campo Endere�o!","Valida��o de endere�o","� necess�rio retirar os espa�os em branco para prosseguir com o cadastro.",1)
   		EndIf

   		_lRet := .F.
    EndIf
    
    _cTxtAux := LTrim( StrTran( M->A1_COMPLEM , '	' , "" ) )
    
    If M->A1_COMPLEM <> ' ' .And. _cTxtAux <> M->A1_COMPLEM
	   	
		If _lAuto
			If _lVarLog
				aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"O campo Complemento n�o foi preenchido no cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + "." } )
			EndIf
  		Else
  			u_itmsg("Erro no preenchimento do campo Complemento do Endere�o!","Valida��o Endere�o","� necess�rio retirar os espa�os em branco para prosseguir com o cadastro.",1)
  		EndIf

	   	_lRet := .F.
    EndIf
    
    _cTxtAux := LTrim( StrTran( M->A1_INSCR , '	' , "" ) )
    
    If _cTxtAux <> AllTrim(M->A1_INSCR)
   		
   		If _lAuto
			If _lVarLog
				aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"O campo Inscri��o Estadual n�o foi preenchido no cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + "." } )
			EndIf
		Else
			u_itmsg("Erro no preenchimento do campo Inscri��o Estadual!","Valida��o de inscri��o estadual","� necess�rio retirar os espa�os em branco para prosseguir com o cadastro.",1)
		EndIf

   		_lRet := .F.
    EndIf
 	
    If _lRet .And. !IsInCallStack("U_AOMS014")
    	_lRet := CRMA980RIS()
    EndIf

	//--------------------------------------------------------------------------------------------------------------
	//Valida se cliente tem outros registros com mesmo c�digo e lojas diferentes e se est�o todos na mesma rede	
	//--------------------------------------------------------------------------------------------------------------
	If M->A1_MSBLQL <> '1' .and. _lRet

		_cAlias  := GetNextAlias()
		_cfilsa1 := xFilial("SA1")
		_ccodcli := M->A1_COD
		_cgrpcli := M->A1_GRPVEN
		_cloja	  := M->A1_LOJA
  
		BeginSql alias _cAlias
			   	
   			SELECT 
	 			A1_GRPVEN, A1_LOJA
			FROM 
			%table:SA1% SA1
			WHERE 
	   			a1_filial = %exp:_cfilsa1%
	   			and a1_msblql <> '1'
	   			and a1_cod = %exp:_ccodcli%
	   			and a1_loja <> %exp:_cloja%
	   			and d_e_l_e_t_ = ' ' 

		EndSql

		DbSelectArea(_cAlias)
		(_cAlias)->(  dbgotop() )
 
		//-----------------------------------------------------
		//Prepara matriz com lojas com grupo diferente 
		//Analisa de grupo est� ok ou se existem outras com problema
		//-----------------------------------------------------
		_alojas := {}
		_cult := alltrim((_cAlias)->A1_GRPVEN)
		
		Do while .not. (_cAlias)->( Eof() )
		
			if alltrim((_cAlias)->A1_GRPVEN) != alltrim(_cult)
			
				_cult := "mudou"
				
			Endif
			
			if alltrim((_cAlias)->A1_GRPVEN) != alltrim(_cgrpcli)
			
				aadd( _alojas, { alltrim((_cAlias)->A1_LOJA), alltrim((_cAlias)->A1_GRPVEN)})
			
			Endif
			
			(_cAlias)->( dbskip())
			
		EndDo		
		
		//-----------------------------------------------------
		//se achou cliente do mesmo c�digo e grupo diferente
		//d� mensagem e trava o processo
		//-----------------------------------------------------
		(_cAlias)->(  dbgotop() )
 
		if .not. (_cAlias)->( Eof() )

			_cMensagem += "Erro no preenchimento do grupo de vendas!" + chr(10) + chr(13)
			
			//------------------------------------------------------------------------
			//Se o _cult n�o mudou significa que todas as lojas est�o no mesmo grupo
			//-----------------------------------------------------------------------
			If _cult == alltrim((_cAlias)->A1_GRPVEN)
			
				if _cult == alltrim((_cAlias)->A1_GRPVEN) .and. alltrim((_cAlias)->A1_GRPVEN) != alltrim(M->A1_GRPVEN)
				
					_lRet := .F.
					_cMensagem += "Todas as lojas desse cliente est�o no grupo " + alltrim((_cAlias)->A1_GRPVEN)
					
				Endif 
				
			//------------------------------------------------------------------------
			//Se n�o mostra lista de lojas com problema
			//-----------------------------------------------------------------------
			Else
				
				
				_lRet := .F.
				_cMensagem += "Existem clientes do mesmo c�digo em grupo de vendas diferente."
				_cMensagem += chr(10)+chr(13)
				
				_nx := 1
				
				Do while _nx <=  2 .and. _nx <= len(_alojas)
				
					_cMensagem += "Loja: " + _alojas[_nx][1] + "  - Grupo: " + _alojas[_nx][2]
					_cMensagem += chr(10)+chr(13)
					
					_nx++
					
				Enddo	
				
				If len(_alojas) > 2
				
					_cMensagem += "E mais " + alltrim(str(len(_alojas) - 2)) + " lojas com diverg�ncia."
					_cMensagem += chr(10)+chr(13)
				
				Endif	
			
			Endif
			
			_cMen2 := "Continua mesmo assim?"
	
			If _lAuto .and. !(_lRet)
			
				If _lVarLog
			
					aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"Existem clientes do mesmo c�digo em grupo de vendas diferente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + "." } )
			
				EndIf
		
			Elseif  !(_lRet)
			
				if u_itmsg(_cMensagem, "Valida��o Grupo de Vendas",_cMen2,3,2,2) 
				
					_lRet := .T.
					
				Else
				
					_lRet := .F.

                	
				Endif
			
			EndIf

			
		
		Endif
        
		If Select(_cAlias) > 0 
		   (_cAlias)->( DBCloseArea() )
	    EndIf

	Endif

	//================================================================================
	// Valida��o da sita��o cadastral do cliente, conforme retorno no mashups
	//================================================================================
	If _lMashup
		If M->A1_PESSOA <> "F" .And. M->A1_COD <> "000001"
			_cUser := RetCodUsr()
			
			DBSelectArea("ZZL")
			ZZL->( DBSetOrder(3) )
			If ZZL->( DBSeek( xFilial("ZZL") + _cUser ) )
				If ZZL->ZZL_LIBMAS == "S"
					_lLibMas := .T.
				EndIf
			EndIf
	
			If !_lLibMas
				If _oObj:GetOperation() == MODEL_OPERATION_INSERT
					If (ALLTRIM(M->A1_I_SITRF) <> "ATIVO" .AND. ALLTRIM(M->A1_I_SITRF) <> "REGULAR" .AND. ALLTRIM(M->A1_I_SITRF) <> "APTO" .AND. ALLTRIM(M->A1_I_SITRF) <> "ATIVA") .Or. _lExec
						If _lExec
							_lRet := .F.
							If IsInCallStack("U_MOMS003")
								aAdd( _aLogM003 , { Date() , Time() ,'Log' ,'� necess�rio realizar a consulta deste cadastro de Fornecedor na Receita Federal devido a periodicidade de consulta. A consulta deve ser realizada no menu: A��es Relacionadas -> Mashups.' } )
							Else
								u_itmsg( "� necess�rio realizar a consulta deste cadastro na Receita Federal devido a periodicidade de consulta.","Valida��o Mashup","A consulta deve ser realizada no menu: A��es Relacionadas -> Mashups.",1 )
							EndIf
						Else
							_lRet := .F.
							If Empty(M->A1_I_SITRF)
								If IsInCallStack("U_MOMS003")
									aAdd( _aLogM003 , { Date() , Time() ,'Log' ,'� necess�rio realizar a consulta deste cadastro de Fornecedor na Receita Federal e se "Jur�dico" no Sintegra tamb�m. A consulta pode ser realizada no menu: A��es Relacionadas -> Mashups.' } )
								Else
									u_itmsg( "� necess�rio realizar a consulta deste cadastro na Receita Federal e se 'Jur�dico' no Sintegra tamb�m.","Valida��o Mashup","A consulta pode ser realizada no menu: A��es Relacionadas -> Mashups.",1 )
								EndIf
							Else
								If IsInCallStack("U_MOMS003")
									aAdd( _aLogM003 , { Date() , Time() ,'Log' ,'N�o � poss�vel concluir a cria��o do cadastro de cliente, devido o status deste Fornecedor na Receita Federal estar como [' + ALLTRIM(A1_I_SITRF) + '].' } )
								Else
									u_itmsg( 'N�o � poss�vel concluir o cadastro deste cliente, devido seu status na Receita Federal estar como [' + ALLTRIM(M->A1_I_SITRF) + '].' , "Valida��o Mashup",,1 )
								EndIf
							EndIf
						EndIf
					EndIf
				ElseIf _oObj:GetOperation() == MODEL_OPERATION_UPDATE
					If (ALLTRIM(A1_I_SITRF) <> "ATIVO" .AND. ALLTRIM(A1_I_SITRF) <> "REGULAR" .AND. ALLTRIM(A1_I_SITRF) <> "APTO" .AND. ALLTRIM(A1_I_SITRF) <> "ATIVA") .Or. _lExec
						If _lExec
							_lRet := .F.
							If IsInCallStack("U_MOMS003")
								aAdd( _aLogM003 , { Date() , Time() ,'Log' ,'� necess�rio realizar a consulta deste cadastro de Fornecedor na Receita Federal devido a periodicidade de consulta. A consulta deve ser realizada no menu: A��es Relacionadas -> Mashups.' } )
							Else
								u_itmsg( '� necess�rio realizar a consulta deste cadastro na Receita Federal devido a periodicidade de consulta.',"Valida��o Mashup",'A consulta deve ser realizada no menu: A��es Relacionadas -> Mashups.' , 1)
							EndIf
						Else
							_lRet := .F.
							If Empty(A1_I_SITRF)
								If IsInCallStack("U_MOMS003")
									aAdd( _aLogM003 , { Date() , Time() ,'Log' ,'� necess�rio realizar a consulta deste cadastro de Fornecedor na Receita Federal e se "Jur�dico" no Sintegra tamb�m. A consulta pode ser realizada no menu: A��es Relacionadas -> Mashups.' } )
								Else
									u_itmsg( '� necess�rio realizar a consulta deste cadastro na Receita Federal e se "Jur�dico" no Sintegra tamb�m.',"Valida��o Mashup",'A consulta pode ser realizada no menu: A��es Relacionadas -> Mashups.' , 1 )
								EndIf
							Else
								If IsInCallStack("U_MOMS003")
									aAdd( _aLogM003 , { Date() , Time() ,'Log' ,'N�o � poss�vel concluir a cria��o do cadastro de cliente, devido o status deste Fornecedor na Receita Federal estar como [' + ALLTRIM(A1_I_SITRF) + '].' } )
								Else
									u_itmsg( 'N�o � poss�vel concluir o cadastro deste cliente, devido seu status na Receita Federal estar como [' + ALLTRIM(A1_I_SITRF) + '].' ,"Valida��o Mashup",,1 )
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf


//================================================================================
//Valida��o de campos Chep
//================================================================================
If _lRet .and. M->A1_I_CHEP  == "C" .AND. LEN(ALLTRIM(A1_I_CCHEP)) != 10

	u_itmsg("Campo de c�digo de cadastro chep inv�lido!","Valida��o Chep","Mude cliente para pallet pbr ou inclua c�digo Chep v�lido!",1)
	_lRet := .F.
	
Endif

If _lRet .and. M->A1_I_CHEP  != "C" .AND. LEN(ALLTRIM(A1_I_CCHEP)) > 0 

	u_itmsg("Campo de c�digo de cadastro chep prenchido para cliente n�o Chep!","Valida��o Chep","Mude cliente para chep pbr ou limpe o c�digo Chep v�lido!",1)
	_lRet := .F.
	
Endif

If !IsInCallStack("U_AOMS014")
	If !Empty(M->A1_INSCR)
		M->A1_INSCR := AllTrim(Strtran(M->A1_INSCR,"-",""))
	EndIf
    
	//==========================================================================
	// Quando o cliente for alterado para Simples Nacional == N�O, 
	// Limpar c�digo de tabela de pre�os Simples Nacional do campo A1_TABELA.
	//==========================================================================
	If _lRet .And. _oObj:GetOperation() == MODEL_OPERATION_UPDATE
       If SA1->A1_SIMPNAC == "1" .And. M->A1_SIMPNAC == "2"
          U_CRMA980PTB(.T.)
	   Else
	      U_CRMA980PTB(.F.)
	   EndIf 
	EndIf 
EndIf

If _lRet .And. !Empty(Alltrim(_cGrpGen)) .And. !Empty(Alltrim(_cVendGen))

	If M->A1_I_GRCLI $ _cGrpGen .And. (IsInCallStack("MATA030") .OR. IsInCallStack("CRMA980") ) .And. !(M->A1_VEND $ _cVendGen)
		
		U_ITMSG("A efetiva��o n�o ser� realizada!"+Chr(13)+Chr(10)+"Para este grupo de clientes "+M->A1_I_GRCLI+" s� � permito vincular os vendedores gen�ricos: "+_cVendGen,"Aten��o","Altere o vendedor para um que seja gen�rico conforme informado.",1)
		_lRet := .F.	

	EndIf

EndIf

_cA1_NOME := _oModelSA1:GetValue("A1_NOME")
If _lRet .And. !Empty(Alltrim(_cA1_NOME))
	_lRet := U_CRMA980VCP(@_cA1_NOME ,"A1_NOME")
	_oModelSA1:LoadValue("A1_NOME",_cA1_NOME) 
EndIf

_cA1_END := _oModelSA1:GetValue("A1_END")
If _lRet .And. !Empty(Alltrim(_cA1_END))
	_lRet := U_CRMA980VCP(@_cA1_END    ,"A1_END")
	_oModelSA1:LoadValue("A1_END",_cA1_END) 
EndIf

_cA1_BAIRRO := _oModelSA1:GetValue("A1_BAIRRO")
If _lRet .And. !Empty(Alltrim(_cA1_BAIRRO))
	_lRet := U_CRMA980VCP(@_cA1_BAIRRO    ,"A1_BAIRRO")
	_oModelSA1:LoadValue("A1_BAIRRO",_cA1_BAIRRO)
EndIf

_cA1_ENDCOB := _oModelSA1:GetValue("A1_ENDCOB")
If _lRet .And. !Empty(Alltrim(_cA1_ENDCOB))
	_lRet := U_CRMA980VCP(@_cA1_ENDCOB    ,"A1_ENDCOB")
	_oModelSA1:LoadValue("A1_ENDCOB",_cA1_ENDCOB)
EndIf

_cA1_ENDREC := _oModelSA1:GetValue("A1_ENDREC")
If _lRet .And. !Empty(Alltrim(_cA1_ENDREC))
	_lRet := U_CRMA980VCP(@_cA1_ENDREC    ,"A1_ENDREC")
	_oModelSA1:LoadValue("A1_ENDREC",_cA1_ENDREC)
EndIf

_cA1_ENDENT := _oModelSA1:GetValue("A1_ENDENT")
If _lRet .And. !Empty(Alltrim(_cA1_ENDENT))
	_lRet := U_CRMA980VCP(@_cA1_ENDENT    ,"A1_ENDENT")
	_oModelSA1:LoadValue("A1_ENDENT",_cA1_ENDENT)
EndIf

_cA1_BAIRROE := _oModelSA1:GetValue("A1_BAIRROE")
If _lRet .And. !Empty(Alltrim(_cA1_ENDENT))
	_lRet := U_CRMA980VCP(@_cA1_BAIRROE    ,"A1_BAIRROE")
	_oModelSA1:LoadValue("A1_BAIRROE",_cA1_BAIRROE)
EndIf

If _lRet .And. (_oObj:GetOperation() == MODEL_OPERATION_INSERT .Or. _oObj:GetOperation() == MODEL_OPERATION_UPDATE) .AND. !IsInCallStack("U_AOMS014")
   If _oModelSA1:GetValue("A1_PESSOA") == "J" .AND. (Empty(Alltrim(_oModelSA1:GetValue("A1_CNAE"))) .OR. _oModelSA1:GetValue("A1_CNAE") == "    - /  ")
		U_ITMSG("Necess�rio o preenchimento do campo CNAE para Clientes pessoa Jur�dica!","Aten��o","",1)
		_lRet := .F.
   EndIf
EndIf

RestArea( _aArea )


Return( _lRet )


/*
===============================================================================================================================
Programa----------: CRMA980RIS
Autor-------------: Igor Melga�o
Data da Criacao---: 25/08/2021
===============================================================================================================================
Descri��o---------: Valida�ao do grau de risco e limite de credito. Substitui o MA030RIS do fonte MA030TOK. 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: L�gico com exibi��o de mensagens para tratativa das negativas
===============================================================================================================================
*/
Static Function CRMA980RIS()
Local _aArea	:= GetArea()
Local _lRet		:= .T.
Local _cQry		:= ""
Local _cCliente	:= ""
Local _cLoja	:= ""
Local _cAlias	:= GetNextAlias()
Local _cQuery	:= ''
Local _aCliente	:= {}
Local _cLjvalid	:= ""
Local _aRecnos	:= {}
Local _lLimite	:= .F.
Local _lRisco	:= .F.
Local _nI		:= 0

Begin Sequence 
   
   If IsInCallStack("U_MOMS055") // N�o validar msexecauto da integra��o do Broker.
      Break
   EndIf 

   _cCliente	:= M->A1_COD
   _cLoja		:= M->A1_LOJA
			
   _cQuery := " SELECT "
   _cQuery += " 	A1.A1_COD, A1.A1_LOJA, A1.A1_LC, A1.R_E_C_N_O_ AS SA1REG "
   _cQuery += " FROM "+ RetSqlName ("SA1")+ " A1  "
   _cQuery += " WHERE "
   _cQuery += " 		A1.D_E_L_E_T_	= ' ' "
   _cQuery += " AND	A1.A1_LC		<> '0'   " 
   _cQuery += " AND	A1.A1_COD		= '"+ _cCliente + "' "
			
   If Select(_cAlias) > 0
	  (_cAlias)->( DBCloseArea() )
   EndIf
			
   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQuery ) , _cAlias , .T. , .F. )
		    
   DBSelectArea(_cAlias)
   (_cAlias)->( DBGoTop() )
   While (_cAlias)->( !EOF() )
			
	   If _cLoja <> (_cAlias)->A1_LOJA
    	  AAdd( _aCliente,	{ (_cAlias)->A1_LOJA }	)
          AAdd( _aRecnos,		{ (_cAlias)->SA1REG }	)
   	   EndIf
		    
       (_cAlias)->( DBSkip() )
   EndDo
		   	
   //================================================================================
   // N�o permite gravar Limite se j� tiver Limite gravado em outras Lojas. Rotina automatica n�o deve mostrar
   //================================================================================
   If Len( _aCliente ) > 0
			
	  If M->A1_LC <> 0 .AND. ( FunName() <> "MOMS003" )
		 _lLimite := .T.
	  EndIf
      //================================================================================
      // Tratativa para o chamado - 5717 - Permitir gravar Prospect sem Limite
      //================================================================================
   ElseIf M->A1_LC == 0 .And. ( FunName() <> "AOMS016" ) 

	  If _lAuto
		 If _lVarLog
			aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"O campo Limite de Cr�dito n�o foi preenchido no cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + ". � obrigat�rio o preencimento deste campo." } )
		 EndIf
	  Else
	   	 u_itmsg("Limite de cr�dito n�o preenchido!","Valida��o Cr�dito","� obrigat�rio incluir um limite de cr�dito para o cliente.",1)
	  EndIf

	  _lRet := .F.
   EndIf
			
   (_cAlias)->( DBCloseArea() )

   // Verificacao se existe alguma loja deste cliente com o risco diferente do que est� sendo informado
   _cQry := "SELECT COUNT(*) AS QTDENT "
   _cQry += "FROM " + RetSqlName("SA1") + " "
   _cQry += "WHERE A1_FILIAL = '" + xFilial("SA1") + "' "
   _cQry += "  AND A1_COD = '" + M->A1_COD + "' "
   _cQry += "  AND A1_LOJA <> '" + M->A1_LOJA + "' "
   _cQry += "  AND A1_RISCO <> '" + M->A1_RISCO + "' "
   _cQry += "  AND D_E_L_E_T_ = ' ' "
	
   DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBQTD" , .T. , .F. )
	
   dbSelectArea("TRBQTD")
   TRBQTD->(dbGoTop())
		
   If TRBQTD->QTDENT > 0
	  _lRisco := .T.
   EndIf

   dbSelectArea("TRBQTD")
   TRBQTD->(dbCloseArea())	

   If _lLimite .And. !_lRisco

	  _cLjvalid := ""
		   			
	  For _nI := 1 to Len( _aCliente )
					
		  If _nI == Len( _aCliente )
			 _cLjvalid  += _aCliente[_nI][01]
		  Else
			 _cLjvalid  += _aCliente[_nI][01] + "; "
		  EndIf
						
	  Next _nI
		
	  If u_itmsg("A(s) Loja(s) " + _cLjvalid + " do cliente " + AllTrim(Posicione("SA1", 1, xFilial("SA1") + M->A1_COD + M->A1_LOJA, "A1_NOME")) + ;
	 			" j� possui(em) valor(es) de Limite(s) cadastrado(s), como o valor de Limite � compartilhado entre as lojas somente uma loja dever� ter limite estabelecido!",;
	 			"Valida��o Cr�dito","Deseja manter este limite de cr�dito compartilhado para todas as lojas? O sistema ir� zerar o limite de cr�dito das outras lojas.",2,2,2)
		 CRMA980VLC(_lLimite, _aCliente, _aRecnos)
	  Else
		 If _lAuto
		 	If _lVarLog
		       aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"As lojas: " + _cLjvalid + " do cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + ", j� possui(em) valor(es) de Limite(s) cadastrado(s)." } )
			EndIf
		 EndIf
		 _lRet := .F.
	  EndIf
   ElseIf !_lLimite .And. _lRisco

	  If !IsInCallStack("U_MOMS003")
		
		 If u_itmsg("Erro no Grau de Risco informado para o cliente - " + AllTrim(Posicione("SA1", 1, xFilial("SA1") + M->A1_COD + M->A1_LOJA, "A1_NOME")) + chr(10) + chr(13) + ;
	 			"� necess�rio verificar o cadastro deste cliente, pois existem outras lojas com o Grau de Risco diferente deste cadastro.",;
	 			"Valida��o Cr�dito","Deseja replicar este Risco para todas as lojas?",2,2,2)
		
		    CRMA980VRIS()
		 Else
			_lRet := .F.
		 EndIf
	  Else
		 If _lAuto
		    If _lVarLog
			   aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"Erro no Grau de Risco informado no cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + ", existem outras lojas com o Grau de Risco diferente deste cadastro." } )
		    EndIf
		 EndIf
	 	 _lRet := .F.
	  EndIf
   ElseIf _lLimite .And. _lRisco

	  _cLjvalid := ""
		   			
	  For _nI := 1 to Len( _aCliente )
					
		  If _nI == Len( _aCliente )
			 _cLjvalid  += _aCliente[_nI][01]
		  Else
			 _cLjvalid  += _aCliente[_nI][01] + "; "
		  EndIf
						
	  Next _nI
	
	  If u_itmsg("A(s) Loja(s) " + _cLjvalid + " do cliente - " + AllTrim(Posicione("SA1", 1, xFilial("SA1") + M->A1_COD + M->A1_LOJA, "A1_NOME")) + ;
				"j� possui(em) valor(es) de Limite(s) cadastrado(s), como o valor de Limite � compartilhado entre as lojas somente uma loja dever� ter limite estabelecido!",;
				"Valida��o de limite de cr�dito","Deseja manter este Grau de Risco e limite de cr�dito compartilhado para todas as lojas? O sistema ir� zerar o limite de cr�dito das outras lojas.",2,2,2)
				
		 CRMA980VLC(_lLimite, _aCliente, _aRecnos)
		 CRMA980VRIS()
	  Else
		 If _lAuto
			If _lVarLog
			   aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"As lojas: " + _cLjvalid + " do cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + ", j� possui(em) valor(es) de Limite(s) cadastrado(s)." } )
			   aAdd( _aLogM003 , { Date() , Time() ,"Erro" ,"Erro no Grau de Risco informado no cliente: " + M->A1_COD + " loja: " + M->A1_LOJA + " nome: " + AllTrim(M->A1_NOME) + ", existem outras lojas com o Grau de Risco diferente deste cadastro." } )
			EndIf
		 EndIf
		 _lRet := .F.
	  EndIf
   EndIf

End Sequence 

RestArea(_aArea)
Return(_lRet)

/*
===============================================================================================================================
Programa----------: CRMA980VLC
Autor-------------: Igor Melga�o
Data da Criacao---: 25/08/2021
===============================================================================================================================
Descri��o---------: Funcao para zerar o limite de credito, caso uma outra loja ja o tenha. Substitui o VLDLIM do Fonte MA030TOK.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function CRMA980VLC(_lLimite, _aCliente, _aRecnos)

Local _nI		:= 0

If _lLimite
	If M->A1_LC > 0
		dbSelectArea("SA1")
		For _nI := 1 To Len( _aRecnos )
			dbGoTo( _aRecnos[_nI][01] )
			RecLock("SA1", .F.)
				Replace SA1->A1_LC With 0
				MsUnLock()
		Next _nI
	EndIf
EndIf

Return

/*
===============================================================================================================================
Programa----------: CRMA980VRIS
Autor-------------: Igor Melga�o
Data da Criacao---: 25/08/2021
===============================================================================================================================
Descri��o---------: Funcao para gravar o mesmo grau de risco para todas as lojas. Substitui o VLDLIM.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function CRMA980VRIS()
Local _cQry	:= ""

// Seleciona todos as lojas do cliente em questao, para que sejam atualizados os riscos em todos os registros deste cliente
_cQry := "SELECT A1_FILIAL, A1_COD, A1_LOJA, R_E_C_N_O_ AS RECSA1 "
_cQry += "FROM " + RetSqlName("SA1") + " "
_cQry += "WHERE A1_FILIAL = '" + xFilial("SA1") + "' "
_cQry += "  AND A1_COD = '" + M->A1_COD + "' "
_cQry += "  AND A1_LOJA <> '" + M->A1_LOJA + "' " 
_cQry += "  AND D_E_L_E_T_ = ' ' "
			
DBUseArea( .T. , "TOPCONN" , TcGenQry( ,, _cQry ) , "TRBSA1" , .T. , .F. )
					
dbSelectArea("TRBSA1")
TRBSA1->(dbGoTop())
					
While !TRBSA1->(Eof())
	dbSelectArea("SA1")
	dbGoTo(TRBSA1->RECSA1)
	RecLock("SA1", .F.)
		Replace SA1->A1_RISCO With M->A1_RISCO
	MsUnLock()
	TRBSA1->(dbSkip())
End
					
dbSelectArea("TRBSA1")
TRBSA1->(dbCloseArea())

Return

/*
===============================================================================================================================
Programa----------: CRMA980BUT
Autor-------------: Igor Melga�o
Data da Criacao---: 30/08/2021
===============================================================================================================================
Descri��o---------: Ponto de entrada para inclus�o de bot�es na tela de manuten��o do cadastro de Clientes. Substitui o MA030BUT
===============================================================================================================================
Parametros--------: PARAMIXB -> Num�rico -> Tipo da opera��o do usu�rio.
===============================================================================================================================
Retorno-----------: aBtnUsr - Array para inclus�o de bot�es na tela de manuten��o do cadastro de Clientes
===============================================================================================================================
*/
Static Function CRMA980BUT(aParam)

Local 	nOpcA		:= aParam[01]
Local 	aBtnUsr		:= {}
Local cMatUsr		:= U_UCFG001(1) 

//================================================================================
//| Inclui botoes na tela do cadastro de clientes se n�o for inclus�o            |
//================================================================================
If	nOpcA != 3

    aAdd( aBtnUsr , { "Historico de Alteracoes","Historico de Alteracoes", {|| U_COMS004() } } )
	
	//Se � usu�rio do cr�dito inclui bot�o de an�lise de cr�dito
	If GetAdvFVal( "ZZL" , "ZZL_LIBCRE" , xFilial("ZZL") + cMatUsr , 1 , "N" ) == "S"

        aAdd( aBtnUsr , { "Analise de Credito" , "Analise de Credito", {|| fwmsgrun(,{ || U_TelCred(2)}, "Aguarde...","Realizando consulta Cisp...") }} )

	Endif
	
EndIf

//================================================================================
//| Caso a chamada seja de altera��o, guarda os valores originais dos campos     |
//================================================================================
If nOpcA == 4
	Public _aITASA1 := U_ITINILOG( "SA1" )
EndIf

Return( aBtnUsr )

/*
===============================================================================================================================
Programa----------: CRMA980WHE
Autor-------------: Igor Melga�o
Data da Criacao---: 09/11/2021
===============================================================================================================================
Descri��o---------: Rotina ue retorna acesso a campos para usu�rio referentes a Libera��o de Credito   
===============================================================================================================================
Parametros--------: Nenhum      
===============================================================================================================================
Retorno-----------: (.T./.F.)
===============================================================================================================================
*/
User Function CRMA980WHE()
Local lExecAuto := .F.
Local lReturn   := .F.
Local _cCodID := __cUserId

lExecAuto := IsInCallStack('MSEXECAUTO')

If lExecAuto
    lReturn := .T.
Else

    If POSICIONE("ZZL",3,xfilial("ZZL")+AllTrim(_cCodID),"ZZL_LIBCRE") == "S"
        lReturn := .T.    
    Else
        lReturn := .F.
    EndIf

EndIf
//Substitui o When dos campos da SA1
//A1_LC, A1_VENCLC, A1_CLASSE, A1_LCFIN, A1_MOEDALC, A1_MSBLQL, A1_I_ACRED, A1_I_DTREA, A1_RISCO        
//X3_when => POSICIONE("ZZL",1,"  "+U_UCFG001(1),"ZZL_LIBCRE")=="S"
Return lReturn		

/*
===============================================================================================================================
Programa----------: CRMA980X
Autor-------------: Julio de Paula Paz
Data da Criacao---: 20/12/2021
===============================================================================================================================
Descri��o---------: Rotina de envio de e-mail WorkFlow notificando a altera��o dos vendedores.
===============================================================================================================================
Parametros--------: _aDados = {{ Rede , Nome Rede, Cod Vend. Anterior, Nome Vend. Anterior, Cod. Vend.Atual, Nome Vend.Atual},
                           ...,{ Rede , Nome Rede, Cod Vend. Anterior, Nome Vend. Anterior, Cod. Vend.Atual, Nome Vend.Atual}} 
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function CRMA980X(_aDados)
Local _aConfig	:= U_ITCFGEML('')
Local _cMsgEml	:= '',_nI 
Local _cAssunto := "WORKFLOW - ALTERA��O DE VENDEDOR EM CLIENTE COM CONTROLE DE REDE"
Local _cEmail1	:= AllTrim(U_ITGETMV("IT_EMALGP1",""))
Local _cEmail2	:= AllTrim(U_ITGETMV("IT_EMALGP2","")) 
Local _cEmailEnv, _cEmlLog := "" 

If Empty(_cEmail1) .And. Empty(_cEmail2)
   Return Nil 
EndIf 

_cEmailEnv := AllTrim(_cEmail1) + ";" + AllTrim(_cEmail2)

_cMsgEml := '<html>'
_cMsgEml += '<head><title>' + _cAssunto + '</title></head>'
_cMsgEml += '<body>'
_cMsgEml += '<style type="text/css"><!--'
_cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
_cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
_cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
_cMsgEml += 'td.aceito	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #00CC00; }'
_cMsgEml += 'td.recusa  { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FF0000; }'
_cMsgEml += 'td.AZUL    { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #0000FF; }'
_cMsgEml += 'td.amarelo { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFF00; }'
_cMsgEml += '--></style>'
_cMsgEml += '<center>'
_cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="700" height="50"><br>'
_cMsgEml += '<table class="bordasimples" width="700">'
_cMsgEml += '    <tr>'
_cMsgEml += '	<td class="titulos"><center>Log de Processamento</center></td>'
_cMsgEml += '	</tr>'
_cMsgEml += '</table>'
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="700">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="2" class="grupos" width="100%"><b>' + _cAssunto + '</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="20%"><b>Cliente:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="80%">' + SA1->A1_COD +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Loja:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="65%">' + SA1->A1_LOJA +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Nome:</b></td>'
_cMsgEml += '      <td class="itens" align="left width="65%">' + SA1->A1_NOME +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Rede:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="65%">' + _aDados[01][01] +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Descri��o Rede:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="65%">' + _aDados[01][02]  +'</td>'
_cMsgEml += '    </tr>'
//_cMsgEml += '    <tr>'
//_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Usuario:</b></td>'
//_cMsgEml += '      <td class="itens" align="left" >' + __cUserId +'</td>'
//_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Usuario Alterador:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="65%">' + UsrFullName (__cUserId)  +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Data da Altera��o:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="65%">' + Dtoc(Date()) +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Hora da Altera��o:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="65%">' + Time() + '</td>'
_cMsgEml += '    </tr>'
_cMsgEml += ' <tr>'
_cMsgEml += '   <td class="titulos" align="center" colspan="2"><font color="red">Esta � uma mensagem autom�tica. Por favor n�o responder!</font></td>'
_cMsgEml += ' </tr>'
_cMsgEml += '</table>'

_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="1300">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="center" width=10%"><b>Codigo Vendedor Anterior</b></td>'
_cMsgEml += '      <td class="grupos" align="center" width=25%"><b>Nome Vendedor Anterior</b></td>'
_cMsgEml += '      <td class="grupos" align="center" width=10%"><b>Codigo Vendedor Atual</b></td>'
_cMsgEml += '      <td class="grupos" align="center" width=25%"><b>Nome Vendedor Atual</b></td>'
_cMsgEml += '      <td class="grupos" align="center" width=25%"><b>Vendedor Alterado</b></td>'
_cMsgEml += '    </tr>'

For _nI := 1 To Len( _aDados )
	_cMsgEml += '    <tr>'
    _cMsgEml += '     <td class="itens" align="left" width="10%">'+_aDados[_nI][03]+'</td>'
	_cMsgEml += '     <td class="itens" align="left" width="25%">'+_aDados[_nI][04]+'</td>'
	_cMsgEml += '     <td class="itens" align="left" width="10%">'+_aDados[_nI][05]+'</td>'
	_cMsgEml += '     <td class="itens" align="left" width="25%">'+_aDados[_nI][06]+'</td>'
	_cMsgEml += '     <td class="itens" align="left" width="25%">'+_aDados[_nI][07]+'</td>'
	_cMsgEml += '    </tr>'
Next _nI
	
_cMsgEml += '</table>'

U_ITConOut('Enviando E-mail(s) para: '+_cEmailEnv+ " - Log de Processamento - Vendedores Alterados - "+TIME()+" - [ M030PALT]")

//    ITEnvMail(cFrom     ,cEmailTo ,_cEmailCo,cEmailBcc,cAssunto ,cMensagem,cAttach   ,cAccount    ,cPassword   ,cServer      ,cPortCon    ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro)
U_ITENVMAIL( _aConfig[01] , _cEmailEnv ,"",         ,_cAssunto, _cMsgEml ,         ,_aConfig[01],_aConfig[02], _aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

Return .T.

/*
===============================================================================================================================
Programa----------: CRMA980Y
Autor-------------: Julio de Paula Paz
Data da Criacao---: 20/12/2021
===============================================================================================================================
Descri��o---------: Rotina de envio de e-mail WorkFlow notificando a bloqueio do cliente por desconto contratual. 
                    Chamado 30177.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function CRMA980Y()
Local _aConfig	:= U_ITCFGEML('')
Local _cMsgEml	:= ''
Local _cAssunto := "WORKFLOW - CLIENTE BLOQUEADO PARA AVALIA��O DE REGRA DE DESCONTO CONTRATUAL"
Local _cEmail1	:= AllTrim(U_ITGETMV("IT_EMALCL1","sistema@italac.com.br"))
Local _cEmail2	:= AllTrim(U_ITGETMV("IT_EMALCL2","sistema@italac.com.br"))
Local _cEmailEnv, _cEmlLog := "" 

If Empty(_cEmail1) .And. Empty(_cEmail2)
   Return Nil 
EndIf 

_cEmailEnv := AllTrim(_cEmail1) + ";" + AllTrim(_cEmail2)

_cMsgEml := '<html>'
_cMsgEml += '<head><title>' + _cAssunto + '</title></head>'
_cMsgEml += '<body>'
_cMsgEml += '<style type="text/css"><!--'
_cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
_cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
_cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
_cMsgEml += 'td.aceito	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #00CC00; }'
_cMsgEml += 'td.recusa  { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FF0000; }'
_cMsgEml += 'td.AZUL    { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #0000FF; }'
_cMsgEml += 'td.amarelo { font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFF00; }'
_cMsgEml += '--></style>'
_cMsgEml += '<center>'
_cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="700" height="50"><br>'
_cMsgEml += '<table class="bordasimples" width="700">'
_cMsgEml += '    <tr>'
_cMsgEml += '	<td class="titulos"><center>Log de Processamento</center></td>'
_cMsgEml += '	</tr>'
_cMsgEml += '</table>'
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="700">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="2" class="grupos" width="100%"><b>' + _cAssunto + '</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="20%"><b>Cliente:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="80%">' + SA1->A1_COD +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Loja:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="65%">' + SA1->A1_LOJA +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Nome:</b></td>'
_cMsgEml += '      <td class="itens" align="left width="65%">' + SA1->A1_NOME +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Rede:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="65%">' + SA1->A1_GRPVEN+'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Descri��o Rede:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="65%">' + AllTrim(Posicione("ACY",1,xFilial("ACY")+SA1->A1_GRPVEN,"ACY_DESCRI" ))+'</td>'
_cMsgEml += '    </tr>'
//_cMsgEml += '    <tr>'
//_cMsgEml += '      <td class="itens" align="center" width="20%"><b>Usuario:</b></td>'
//_cMsgEml += '      <td class="itens" align="left" >' + __cUserId +'</td>'
//_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Usuario Alterador:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="65%">' + UsrFullName (__cUserId)  +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Data da Altera��o:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="65%">' + Dtoc(Date()) +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="left" width="35%"><b>Hora da Altera��o:</b></td>'
_cMsgEml += '      <td class="itens" align="left" width="65%">' + Time() + '</td>'
_cMsgEml += '    </tr>'
_cMsgEml += ' <tr>'
_cMsgEml += '   <td class="titulos" align="center" colspan="2"><font color="red">Esta � uma mensagem autom�tica. Por favor n�o responder!</font></td>'
_cMsgEml += ' </tr>'
_cMsgEml += '</table>'

_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="1300">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="grupos" align="center" width=10%"><b>Descri��o</b></td>'
_cMsgEml += '    </tr>'

_cMsgEml += '    <tr>'
_cMsgEml += '     <td class="itens" align="left" width="10%">'
//_cMsgEml += '     Este cliente foi bloqueado pois em seus cadastro foi informado um grupo de vendas para qual j� existe um contrato de desconto preexistente.'
//_cMsgEml += '     O desbloqueio do cadastro ser� realizado pela equipe de manuten��o dos cadastros de descontos contratuais. </td>'
_cMsgEml += '     Este cliente foi bloqueado pois foi informado em seu cadastro um grupo de vendas que possui um desconto contratual de uso restrito. '
_cMsgEml += '     A avalia��o deste cadastro e o seu desbloqueio ser� realizada pela equipe que faz a gest�o dos contratos de descontos! </td> '
_cMsgEml += '</table>'

U_ITConOut('Enviando E-mail(s) para: '+_cEmailEnv+ " - Log de Processamento - Cliente Bloqueado - "+TIME()+" - [ CRMA980Y]")

//    ITEnvMail(cFrom     ,cEmailTo ,_cEmailCo,cEmailBcc,cAssunto ,cMensagem,cAttach   ,cAccount    ,cPassword   ,cServer      ,cPortCon    ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro)
U_ITENVMAIL( _aConfig[01] , _cEmailEnv ,"",         ,_cAssunto, _cMsgEml ,         ,_aConfig[01],_aConfig[02], _aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )

Return .T.


/*
===============================================================================================================================
Programa----------: CRMA980VCP
Autor-------------: Igor Melga�o
Data da Criacao---: 30/05/2022
===============================================================================================================================
Descri��o---------: Rotina que verifica o prenchimento de caracteres invalidos
===============================================================================================================================
Parametros--------: Nenhum      
===============================================================================================================================
Retorno-----------: (.T./.F.) 
===============================================================================================================================
*/
User Function CRMA980VCP(cCampo,cDesc,lSubstitui,lAuto)
Local _cCarac      := U_ItGetMv("ITCARACINV","�����������~^`���[�#*><!?|��'��"+'"')
Local _cCaracInv   := ""
Local _lCaracInv   := .F.
Local i            := 0
Local j            := 0
Local _lRet        := .T.
Local _cTitulo     := ""
Local _cCaracSub   := U_ItGetMv("ITCARACSUB","S / N;S /N;S/ N;S Nr;SNr;S Num;S.Nr;S. Nr;S .Nr;S.Num;S. Num;S .Num")
Local _aSub        := {}
Local _aSub2       := {}
Local _aSubSp      := {}

Default cDesc      := ""
Default lSubstitui := .F.
Default lAuto      := .F.

//Tratamento para o Endere�o sem Numero
If !Empty(Alltrim(cDesc)) .AND. cDesc $ "A1_END | A1_ENDCOB | A1_ENDREC | A1_ENDENT | A2_END | A2_ENDCOB | A2_ENDREC | A2_ENDENT"
	 
	_aSub2 := strtokarr (_cCaracSub, ";") 

	For i := 1 To 10
		For j := 1 To Len(_aSub2)
			AADD(_aSubSp,StrTran(_aSub2[j]," " ,Space(i)))
		Next
	Next

	For i := 1 To Len(_aSubSp)
		AADD(_aSub,_aSubSp[i])
	Next

	cCampo := StrTran(cCampo,",          " ,", ")
	cCampo := StrTran(cCampo,",         " ,", ")
	cCampo := StrTran(cCampo,",        " ,", ")
	cCampo := StrTran(cCampo,",       " ,", ")
	cCampo := StrTran(cCampo,",      " ,", ")
	cCampo := StrTran(cCampo,",     " ,", ")
	cCampo := StrTran(cCampo,",    " ,", ")
	cCampo := StrTran(cCampo,",   " ,", ")
	cCampo := StrTran(cCampo,",  " ,", ")

	For i := 1 To Len(_aSub)
		
		cCampo := StrTran(cCampo," "+_aSub[i] ," S/N")
		cCampo := StrTran(cCampo,","+_aSub[i] ," S/N")
		cCampo := StrTran(cCampo,", "+_aSub[i] ," S/N")

	Next

EndIf

//===================================================================================================
// Converte os Caracteres
//===================================================================================================
cCampo := StrTran(cCampo ,"�","a")
cCampo := StrTran(cCampo ,"�","A")
cCampo := StrTran(cCampo ,"�","a")
cCampo := StrTran(cCampo ,"�","A")
cCampo := StrTran(cCampo ,"�","a")
cCampo := StrTran(cCampo ,"�","A")
cCampo := StrTran(cCampo ,"�","a")
cCampo := StrTran(cCampo ,"�","A")
cCampo := StrTran(cCampo ,"�","a")
cCampo := StrTran(cCampo ,"�","A")
cCampo := StrTran(cCampo ,"�","e")
cCampo := StrTran(cCampo ,"�","E")
cCampo := StrTran(cCampo ,"�","e")
cCampo := StrTran(cCampo ,"�","E")
cCampo := StrTran(cCampo ,"�","e")
cCampo := StrTran(cCampo ,"�","E")
cCampo := StrTran(cCampo ,"�","i")
cCampo := StrTran(cCampo ,"�","I")
cCampo := StrTran(cCampo ,"�","i")
cCampo := StrTran(cCampo ,"�","I")
cCampo := StrTran(cCampo ,"�","i")
cCampo := StrTran(cCampo ,"�","I")
cCampo := StrTran(cCampo ,"�","y")
cCampo := StrTran(cCampo ,"�","y")
cCampo := StrTran(cCampo ,"�","y")
cCampo := StrTran(cCampo ,"�","o")
cCampo := StrTran(cCampo ,"�","O")
cCampo := StrTran(cCampo ,"�","o")
cCampo := StrTran(cCampo ,"�","O")
cCampo := StrTran(cCampo ,"�","o")
cCampo := StrTran(cCampo ,"�","O")
cCampo := StrTran(cCampo ,"�","o")
cCampo := StrTran(cCampo ,"�","O")
cCampo := StrTran(cCampo ,"�","o")
cCampo := StrTran(cCampo ,"�","O")
cCampo := StrTran(cCampo ,"�","u")
cCampo := StrTran(cCampo ,"�","U")
cCampo := StrTran(cCampo ,"�","u")
cCampo := StrTran(cCampo ,"�","U")
cCampo := StrTran(cCampo ,"�","u")
cCampo := StrTran(cCampo ,"�","U")
cCampo := StrTran(cCampo ,"�","c")
cCampo := StrTran(cCampo ,"�","C")
cCampo := StrTran(cCampo ,"�","n")
cCampo := StrTran(cCampo ,"�","N")
cCampo := StrTran(cCampo ,"�","1/4")
cCampo := StrTran(cCampo ,"�","1/2")
cCampo := StrTran(cCampo ,"�","3/4")
cCampo := StrTran(cCampo ,";",",")
cCampo := StrTran(cCampo ,"�","-")
cCampo := StrTran(cCampo ,"!","")
cCampo := StrTran(cCampo ,"�","x")
cCampo := StrTran(cCampo ,"�","o")

If lSubstitui
	_lRet := cCampo
Else
	//===================================================================================================
	// Resgata a descri��o do Campo
	//===================================================================================================
	SX3->(DbSetOrder(2))
	SX3->( dbSeek(cDesc) )
	_cTitulo := X3TITULO()


	//===================================================================================================
	// Valida digita��o de caracteres invalidos na descri��o
	//===================================================================================================
	For i := 1 To Len(cCampo)
		If Subs(cCampo,i,1) $ _cCarac
			_cCaracInv += " " + Subs(cCampo,i,1)
			_lCaracInv := .T.
		EndIf
	Next

	If _lCaracInv 
		If !lAuto
			U_ItMsg( "Caracteres inv�lidos preenchidos no campo "+_cTitulo,"Aten��o",;
			"Retire os caracteres especiais.",1,,,.T.)
			//"Substitua os seguintes caracteres preenchidos "+_cCaracInv+".",1,,,.F.)
		EndIf
		_lRet := .F.
	EndIf
EndIf

Return _lRet


/*
===============================================================================================================================
Programa----------: CRMA980CON
Autor-------------: Alex Wallauer
Data da Criacao---: 17/02/2023
===============================================================================================================================
Descri��o---------: Acerto do campo A1_CONTRIB / Funcao chamada tb do PE MALTCLI e M030INC
===============================================================================================================================
Parametros--------: Nenhum      
===============================================================================================================================
Retorno-----------: .T.
===============================================================================================================================
*/
USER Function CRMA980CON()

SA1->(RecLock("SA1", .F.))
//A1_TPJ: 1=ME - Micro Empresa;2=EPP - Empresas de Pequeno Porte;3=MEI - Microempreendedor Individual;4=N�o Optante
If (Empty(SA1->A1_INSCR) .Or. AllTrim(SA1->A1_INSCR) == "ISENTO") .AND. SA1->A1_TPJ =="3" .AND. SA1->A1_EST $ "RS|SC|PR" .AND. SA1->A1_SIMPNAC=="1"//1=Sim;2=N�o
   SA1->A1_CONTRIB := "1"
ELSEIf Empty(SA1->A1_INSCR) .Or. AllTrim(SA1->A1_INSCR) == "ISENTO"
   SA1->A1_CONTRIB := "2"
Else
   SA1->A1_CONTRIB := "1" // 1=Sim;2=N�o
EndIf
If SA1->A1_CLIFUN = "1"   // 1=SIm;2=Nao
   SA1->A1_CONTRIB := "2" // 1=Sim;2=N�o
ENDIF

SA1->A1_INSCR := U_AOMS138N(SA1->A1_INSCR,SA1->A1_EST) 

SA1->(MsUnLock())

RETURN .T.
