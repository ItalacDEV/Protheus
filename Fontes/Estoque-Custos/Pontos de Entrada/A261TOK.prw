/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |07/10/2024| Chamado 48759. Validado o campo ZZL_ARMAZE quando o ZZL_ARMEFE estiver vazio
Lucas Borges  |08/10/2024| Chamado 48759. Revertidas as últimas alterações para melhor análise do André
Lucas Borges  |13/10/2024| Chamado 48465. Retirada da função de conout
==============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina. 
//====================================================================================================

#INCLUDE "RWMAKE.CH" 
#INCLUDE "PROTHEUS.CH"
 
/*
===============================================================================================================================
Programa----------: A261TOK
Autor-------------: Guilherme Diogo
Data da Criacao---: 19/10/2012
Descrição---------: Ponto de Entrada que valida movimento de transferencia modelo II
Parametros--------: Nenhum
Retorno-----------: Lógico validando o lançamento 
===============================================================================================================================
*/     
User Function  A261TOK()
Local _oDlg    
Local _oMainWnd
Local _oProd
Local _cVarQ
//Local _aArea   := GetArea()
Local _lRet    := .T.    
Local _aProd   := {}
Local _cDesc1  :=""
Local _cDesc2  :=""
Local _aErro1   := {}    
Local _aErro2   := {}    
Local _cItens   := ""  
Local _lErro1   := .F.
Local _lErro2   := .F.
Local _aErro    := {} 
Local _aSldNeg  := {} 
Local _lErro    := .F.
Local _nDifCM	:= 0
Local _nDifCM2	:= 0
Local _nI		:= 0  , nX  , x  , y
Local _nCMorig	:= 0
Local _nCMdest	:= 0
Local _nDifPrd	:= 0
Local _nLocalOrig, _nLocalDest     
Local _aOrd := SaveOrd({"ZZL"})
Local _lmt103fim := .F.
Local _laglt003 := .F.
Local _cLinhas:=""
Local _cArmVirtual:=""
Local _cArmFisico:=""
Local _lValidFrac1UM:=.T.
Local _cUM_NO_Fracionada:=U_ITGetMV("IT_UMNOFRAC","PC,UN")
Local _cARM_MATA311:=U_ITGetMV("IT_ARMAT311","")//20,22,31,61
Local _nDsctptrs

Local _nMotTrRef, _nDscMTrRf 
Local _cFilVld34 := U_ITGetMV("IT_FILVLD34","01") // Filiais Habilitadas para Validação de Transferência para o Armazém 34.

Local _cPRD_MATA311:=U_ITGetMV("IT_PRDMT311","")//00020010501,00020020501,08140000045,08140000046,00090020501,00090010501
//00020010501, - LEITE EM PO INTEGRAL 25 KG ITALAC
//00020020501, - LEITE EM PO DESNATADO 25 KG ITALAC
//08140000045, - LEITE EM PÓ INTEGRAL IMPORTADO (CONAPROLE)
//08140000046, - LEITE EM PÓ DESNATADO IMPORTADO (CONAPROLE)
//00090020501, - SORO EM PO PARC. DESMINERALIZADO 25 KG ITALAC
//00090010501, - SORO EM PO 25 KG ITALAC

//Verifica se está sendo executado automaticamente a partir do mt103fim
If isincallstack("U_MT103FIM")

	_lmt103fim := .T.
	
Endif

//Verifica se está sendo executado automaticamente a partir do aglt003
If isincallstack("U_AGLT003G")

	_laglt003 := .T.
	
Endif

_lAOMS116S:=IsInCallStack("U_AOMS116S")

_lMCOM004:=IsInCallStack("MCOM4Trans")

_lMATA311:=IsInCallStack("MATA311")

Begin Sequence


   If !_lmt103fim .and. !_laglt003 .AND. !_lAOMS116S .AND. !_lMCOM004 .and.  !U_ITVACESS( 'ZZL' , 3 , 'ZZL_AUTMUL' , 'S' ) 
      U_ITMSG("Usuário sem permissão para realizar transferência multipla. Não será possível realizar a transferência.",;
      "Permissões de Acesso Italac",;
      "Entre em contato com o suporte do TI.",1)
      _lRet := .F.
      Break                                                  
   EndIf       

   _nLocalOrig := Ascan(aHeader,{|x| x[1] = 'Armazem Orig.'})
   _nLocalDest := Ascan(aHeader,{|x| x[1] = 'Armazem Destino'})
//-------------------------------------------------------------------------
   If ! xFilial("SD3") $ _cFilVld34
      _nTPTRS     := Ascan(aHeader,{|x| x[2] = 'D3_I_TPTRS'})  
	  _nDsctptrs  := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_DSCTM"})  
   EndIf 
//-------------------------------------------------------------------------
   _nSetor     := Ascan(aHeader,{|x| x[2] = 'D3_I_SETOR'})
   _nD3_I_OBS  := Ascan(aHeader,{|x| x[2] = 'D3_I_OBS'  })
   nPosOCod    := 1//Ascan(aHeader,{|x| x[2] = 'D3_COD' })
   nPosDCod    := 6//Ascan(aHeader,{|x| x[2] = 'D3_COD' }) 
   nPosQtd     := Ascan(aHeader,{|x| x[2] = 'D3_QUANT'  }) 
   nPosQtd2    := Ascan(aHeader,{|x| x[2] = 'D3_QTSEGUM'}) 
      
   _nMotTrRef  := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_MOTTR"})
   _nDscMTrRf  := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_DSCMT"})

   _cFilEAcesso:=""
   _cArmEAcesso:=""
   
   If !_lmt103fim .and. !_laglt003 .AND. !_lAOMS116S .AND. !_lMCOM004 
	   _cAliasZZL:= GetNextAlias()
      _cQuery := " SELECT ZZL.R_E_C_N_O_ AS REG_ZZL "
      _cQuery += " FROM  "+ RetSQLName("ZZL") +" ZZL "
      _cQuery += " WHERE D_E_L_E_T_ = ' ' "
	  _cQuery += " AND ZZL_ARMEFE <> ' '"

      DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAliasZZL , .T. , .F. )

      (_cAliasZZL)->( DBGoTop() )
      DO While (_cAliasZZL)->(!Eof())
      	ZZL->(DBGOTO((_cAliasZZL)->REG_ZZL))
         IF (_nPos:=AT("/",ZZL->ZZL_ARMEFE)) > 0 
		    IF cFilant <> LEFT(ZZL->ZZL_ARMEFE, _nPos-1 )
		       (_cAliasZZL)->(DBSKIP())	   
			   LOOP
			ENDIF
      	   _cFilEAcesso+=LEFT(ZZL->ZZL_ARMEFE, _nPos )+";"
           _cArmEAcesso+=ALLTRIM(SUBSTR(ZZL->ZZL_ARMEFE, _nPos ))+"; "
         ELSE   
           _cArmEAcesso+=ALLTRIM(ZZL->ZZL_ARMEFE)+"; "
         ENDIF
      
      	(_cAliasZZL)->(DBSKIP())
      ENDDO
      (_cAliasZZL)->(DBCLOSEAREA())
   ENDIF
   
   ZZL->(DbSetOrder(3))  
   ZZL->(DbSeek(xFilial("ZZL")+RetCodUsr()))
   If ZZL->ZZL_PEFRPA == "S"  .OR. ZZL->ZZL_PEFROU == "S"
	  _lValidFrac1UM:=.F.
   EndIf
   
   For _nI := 1 To Len(aCols)
          
		  If aTail(aCols[_nI]) // Se Linha Deletada
             LOOP
          ENDIF

          IF !_lmt103fim .and. !_laglt003 .AND. !_lAOMS116S .AND. !_lMCOM004 .AND. !_lMATA311 .AND. EMPTY(_cPRD_MATA311+_cARM_MATA311)
          
		     If ZZL->ZZL_PERTRA <> "S" .AND. cFilant $ _cFilEAcesso .AND. aCols[_nI,_nLocalOrig] $ _cArmEAcesso .AND. aCols[_nI,_nLocalDest] $ _cArmEAcesso
                U_ITMSG("TRANSFERÊNCIA NÃO PERMITIDA!" ,;
                        "Permissões de Acesso Italac",;
                        "Para transferir usando os armazéns " +AllTrim(_cArmEAcesso)+ " usar a rotina Solicitação de Transferência.",1)
                _lRet := .F.
                Break  
		     ENDIF
          
		  ELSEIf !_lmt103fim .and. !_laglt003 .AND. !_lAOMS116S .AND. !_lMCOM004 .AND. !_lMATA311 

             IF !AllTrim(aCols[_nI,nPosOCod]) $ _cPRD_MATA311 .AND. (aCols[_nI,_nLocalOrig]  $ _cArmEAcesso  .OR.  aCols[_nI,_nLocalDest] $ _cArmEAcesso ) .AND.;
			                                                        (!aCols[_nI,_nLocalOrig] $ _cARM_MATA311 .OR. !aCols[_nI,_nLocalDest] $ _cARM_MATA311)
			 
			    If ZZL->ZZL_PERTRA <> "S" .AND. cFilant $ _cFilEAcesso .AND. aCols[_nI,_nLocalOrig] $ _cArmEAcesso .AND. aCols[_nI,_nLocalDest] $ _cArmEAcesso
                   U_ITMSG("TRANSFERÊNCIA NÃO PERMITIDA!" ,;
                           "Permissões de Acesso Italac",;
                           "Para transferir usando os armazéns " +AllTrim(_cArmEAcesso)+ " usar a rotina Solicitação de Transferência.",1)
                   _lRet := .F.
                   Break  
		        ENDIF			 
			 
			 ELSE			 
			    
				If ((AllTrim(aCols[_nI,nPosOCod]) $ _cPRD_MATA311 .AND. aCols[_nI,_nLocalOrig] $ _cARM_MATA311) .OR. ;
		            (AllTrim(aCols[_nI,nPosDCod]) $ _cPRD_MATA311 .AND. aCols[_nI,_nLocalDest] $ _cARM_MATA311)) .AND.;
		   	       (aCols[_nI,_nLocalDest] <> "34") 
      
                   _cProds:="PRODUTOS:"+CHR(13)+CHR(10)
                   _aProds:=StrToArray(AllTrim(_cPRD_MATA311),",")
		   	       FOR x := 1 TO LEN(_aProds)
		   	          _cProds+=_aProds[x]+" - "+ALLTRIM(POSICIONE("SB1",1,xFilial("SB1")+_aProds[x],"B1_I_DESCD"))+CHR(13)+CHR(10)
		   	       NEXT
      
		   	       U_ITMSG("TRANSFERÊNCIA NÃO PERMITIDA!" ,;
                            "Permissões de Acesso Italac",;
                            "Para transferir usando os armazéns " +AllTrim(_cARM_MATA311)+ " e produtos (Ver detalhes) usar a rotina Solicitação de Transferência.",1,,,,,,;
							{||  U_ITMsgLog(_cProds, "ATENCAO",1,.F.) })
      
                   _lRet := .F.
                   Break  
		        ENDIF
             
			 ENDIF
		  ENDIF
          
		  If !(aCols[_nI,_nLocalOrig] $ ZZL->ZZL_ARMAZE) .and. !_lmt103fim .and. !_laglt003 .AND. !_lAOMS116S .AND. !_lMCOM004
             U_ITMSG("Usuário sem permissão para utilizar este armazem de origem. Não será possível realizar a transferência multipla. Armazens permitidos ao usuário: '"+AllTrim(ZZL->ZZL_ARMAZE)+"'.",;
                     "Permissões de Acesso Italac",;
                     "Entre em contato com o suporte do TI.",1)
             _lRet := .F.
             Break  
          EndIf
          
          If ! (aCols[_nI,_nLocalDest] $ ZZL->ZZL_ARMAZE) .and. !_lmt103fim .and. !_laglt003 .AND. !_lAOMS116S .AND. !_lMCOM004
             U_ITMSG("Usuário sem permissão para utilizar este armazem de destino. Não será possível realizar a transferência multipla. Armazens permitidos ao usuário: '"+AllTrim(ZZL->ZZL_ARMAZE)+"'.",;
                     "Permissões de Acesso Italac",;
                     "Entre em contato com o suporte do TI.",1)
             _lRet := .F.
             Break  
          EndIf
//------------------------------------------------------------------------------
          If ! xFilial("SD3") $ _cFilVld34
		     If (aCols[_nI,_nLocalDest] $ "34") .AND. EMPTY(aCols[_nI,_nTPTRS]) .and. !_lmt103fim .and. !_laglt003 .AND. !_lAOMS116S .AND. !_lMCOM004
                U_ITMSG("Preencha o campo Tp TRS (Tipo de tranferencia)",;  
                        "Campo obrigatorio condicional",;
                        "Esse campo é obrigatório quando o armazem de destino é 34",1)
                _lRet := .F.
                Break  
		  
		     ElseIf (aCols[_nI,_nLocalDest] $ "34") .AND. !EMPTY(aCols[_nI,_nTPTRS]) 
                U_MT261VLD("A261TOK",_nI) // Atribui a descrição do tipo de movimentação/transferência.
             EndIf
          EndIf 
//-------------------------------------------------------------------------------
/*
		  If (aCols[_nI,_nLocalDest] $ "34") .AND. EMPTY(aCols[_nI,_nSetor]) .and. !_lmt103fim .and. !_laglt003 .AND. !_lAOMS116S .AND. !_lMCOM004
		  	U_ITMSG("Preencha o campo Setor. (Setor da tranferência)",;
                     "Campo obrigatorio condicional",;
                     "Esse campo é obrigatório quando o armazem de destino é 34",1)
             _lRet := .F.
             Break
		  Endif		   
*/
		  IF _lValidFrac1UM //.AND. SB1->B1_TIPO == "PA"

				SB1->(dbSeek(xFilial("SB1") + AllTrim(aCols[_nI,nPosOCod])))
				If SB1->B1_UM $ _cUM_NO_Fracionada
				   If aCols[_nI,nPosQtd] <> Int(aCols[_nI,nPosQtd])

			           AADD(_aProd,{aCols[_nI,nPosOCod],SB1->B1_I_DESCD,aCols[_nI,nPosDCod],Posicione("SB1",1,xFilial("SB1")+aCols[_nI,nPosDCod],"B1_I_DESCD"),;
			           "Não é permitido fracionar a quantidade da 1a. UM de produto onde a Unid. Medida for "+_cUM_NO_Fracionada})

				   EndIf
				EndIf

				SB1->(dbSeek(xFilial("SB1") + AllTrim(aCols[_nI,nPosOCod])))
				If SB1->B1_SEGUM  $ _cUM_NO_Fracionada//= "PC" .AND. LEFT( AllTrim(aCols[_nI,nPosOCod]),4)=="0006"
					If aCols[_nI,nPosQtd2] <> Int(aCols[_nI,nPosQtd2])

			           AADD(_aProd,{aCols[_nI,nPosOCod],SB1->B1_I_DESCD,aCols[_nI,nPosDCod],Posicione("SB1",1,xFilial("SB1")+aCols[_nI,nPosDCod],"B1_I_DESCD"),;
			           "Não é permitido fracionar a quantidade da 2a. UM de produto onde a Unid. Medida for "+_cUM_NO_Fracionada})

					EndIf
				EndIf
		  EndIf

	      //=============================================================================
	      // Validações Exclusiva para destino Armazém 34.
	      //=============================================================================
	      _nPosLocDe  := aScan( aHeader, { |x| Alltrim(x[1])== "Armazem Destino" } )
	      //_cLocalDest := aCols[_nI,_nPosMotiv] 
	      _cLocalDest := aCols[_nI ,_nPosLocDe] 

          If _cLocalDest == "34" .And. xFilial("SD3") $ _cFilVld34 // Valida apenas para as filiais contidas no Parâmetro IT_FILVLD34
             //- Não permitir gravar a transferência sem que seja preenchido o campo origem; D3_L_ORIG = Origem // Descrição: D3_I_SETOR 
	         
			 //================  1 - Validação
			 _cMotTrRef  := aCols[_nI,_nMotTrRef]
			 
			 If Empty(_cMotTrRef)
                //U_ItMsg("O preenchimento do motivo da transferênde de refugo é obrigatório quando o armazém de destino for 34.","Atenção", ,1) 
				U_ItMsg("Favor preencher campo do motivo da transferência. Obrigatório preenchimento para transferências para o armazém 34.","Atenção",;
				        "Verificar preenchimento do campo 'Mot. Tran. Ref.' (D3_I_MOTTR)." ,1) 
			    _lRet := .F.  
			 EndIf

             //================ 2 - Validação
			 _nPosOrig  := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_SETOR"})   // 2  
             _cOrig     := aCols[_nI,_nPosOrig]

		     If Empty(_cOrig)
                //U_ItMsg("O preenchimento do campo origem é obrigatório quando o armazém de destino for 34.","Atenção", ,1)
				U_ItMsg("Favor preencher campo da origem da transferência. Obrigatório preenchimento para transferências para o armazém 34.","Atenção",;
				        "Verificar preenchimento do campo 'Origem'. Trf. (D3_I_SETOR)." ,1)
				
			    _lRet := .F.
		     EndIf 

			 // ===============  3 - Validação
             //- Não permitir gravar a transferência sem que seja preenchido o campo destino ; D3_I_DESTI = Destinacao    
	         _nPosDest  := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_I_DESTI"})  // 3
	         _cDestino  := aCols[_nI,_nPosDest]      
		     If Empty(_cDestino)
                //U_ItMsg("O preenchimento do campo destino é obrigatório quando o armazém de destino for 34.","Atenção", ,1) 
				U_ItMsg("Favor preencher campo do destino da transferência. Obrigatório preenchimento para transferências para o armazém 34.","Atenção",;
				        "Verificar preenchimento do campo 'Destino' (D3_I_DESTI).",1) 
			    _lRet := .F. 
		     EndIf 
            
		     If ! _lRet
                Break
		     EndIf  
      
	      EndIf 

	      //============================================================================
	      // Validação Exclusiva para Produtos com controle de Rasteabilidade por lotes
	      //============================================================================
          //- Não permitir gravar a transferência quando o produto controlar rastro por lote (B1_RASTRO = 'L') e que os campos lote origem e lote destino esteja idênticos;
	      _nPosProd  := aScan(aHeader,{|x|Alltrim(Upper(x[2]))=="D3_COD"}) 
	      _cCodProd  := aCols[_nI,_nPosProd]  
	      _cRastro   := Posicione("SB1",1,xFilial("SB1")+U_ITKEY(_cCodProd,"B1_COD"),"B1_RASTRO")

	      If _cRastro == "L" // Rastreado por controle de lotes.
             _nPosLote  := AsCan(aHeader,{|x| x[1]=="Lote"}) 
	         _cLote     := aCols[_nI,_nPosLote] 
	     
		     _nPosLoteD := AsCan(aHeader,{|x| x[1]=="Lote Destino"})
	         _cLoteDest := aCols[_nI,_nPosLoteD] 
             /*
		     If AllTrim(_cLote) == AllTrim(_cLoteDest)
                U_ItMsg("Para produtos com rastreabilidade por lotes, o lote de origem não pode ser igual a lote de destino.","Atenção", ,1)
			    _lRet := .F. 
			    Break 
		     EndIf 
			 */
			 If AllTrim(_cLote) <> AllTrim(_cLoteDest) .AND. aCols[_nI,_nLocalOrig] <> aCols[_nI,_nLocalDest]
                U_ItMsg("Para produtos com rastreabilidade por lotes, o lote de origem não pode ser diferente do lote de destino.","Atenção", ,1)
			    _lRet := .F. 
			    Break 
		     EndIf 
    	  EndIf 
   Next
// EndIf

   For nX := 1 to Len(aCols)
       If aTail(aCols[nX]) // Se Linha Deletada
          LOOP
       ENDIF

	   If aCols[nX,1] <> aCols[nX,6] .and. !_lmt103fim .and. !_laglt003 .AND. !_lMCOM004 //Validação de produto divergente com exceção para leite a granel

	      If !(trim(aCols[nX,1]) $ (u_itgetmv("ITLTGRN",'08000000062')+u_itgetmv("ITLTMP",'08000000034')+u_itgetmv("ITCRGRN",'08000000063;08000000064')+u_itgetmv("ITCRMP",'08000000007')) .and.;
      		   trim(aCols[nX,6]) $ (u_itgetmv("ITLTGRN",'08000000062')+u_itgetmv("ITLTMP",'08000000034')+u_itgetmv("ITCRGRN",'08000000063;08000000064')+u_itgetmv("ITCRMP",'08000000007')) )
		
    		 _cDesc1 := AllTrim(Posicione("SB1",1,xFilial("SB1")+aCols[nX,1],"B1_I_DESCD"))
    		 _cDesc2 := AllTrim(Posicione("SB1",1,xFilial("SB1")+aCols[nX,6],"B1_I_DESCD"))  
	
			 AADD(_aProd,{aCols[nX,1],_cDesc1,aCols[nX,6],_cDesc2,"produtos de origem e destino divergentes"})

          EndIf

        
       EndIf   

          IF !_lmt103fim .and. !_laglt003 .AND. !_lMCOM004
             NNR->(DBSETORDER(1))
             NNR->(DBSEEK(xFilial()+aCols[nX,_nLocalOrig]))
             _cTipoOrigem :=NNR->NNR_I_TPFV
             NNR->(DBSEEK(xFilial()+aCols[nX,_nLocalDest]))
             _cTipoDestino:=NNR->NNR_I_TPFV
	         If _cTipoOrigem  <> _cTipoDestino .AND. LEN(ALLTRIM(aCols[nX,_nD3_I_OBS])) < 10//"1=Fisico;2=Virtual"
	            IF !aCols[nX,_nLocalOrig] $ _cArmVirtual .AND. _cTipoOrigem = "2"
                   _cArmVirtual+=aCols[nX,_nLocalOrig]+", "
                ENDIF   
	            IF !aCols[nX,_nLocalDest] $ _cArmFisico .AND. _cTipoOrigem = "1"
                   _cArmFisico +=aCols[nX,_nLocalDest]+", "
                ENDIF   
                _cLinhas+=STRZERO(nX,3)+", "
             EndIf
          EndIf


   Next nX 

   If Len(_aProd) > 0

	  //==============================================================
	  //| Monta tela para seleção dos arquivos contidos no diretório |
	  //==============================================================
	  IF FwGetRunSchedule() .OR. GetRemoteType() == -1
	     _lRet := .F.
		 FWLogMsg("INFO"/*cSeverity*/, /*cTransactionId*/, "SCHEDULE"/*cGroup*/, FunName()/*cCategory*/, /*cStep*/, "A261TOK01"/*cMsgId*/, "A261TOK01 - A operação não pode ser concluída com produtos com Problemas!"/*cMessage*/, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	  ELSE
      oMainWnd:ReadClientCoords()//So precisa declarar uma fez para o Programa todo
	  DEFINE MSDIALOG _oDlg TITLE "Produtos com Problemas"  From 150,0 To 440,oMainWnd:nRight-20 OF _oMainWnd PIXEL
		 _oDlg:lEscClose := .F.
 	     _nTam:=(_oDlg:nClientWidth-4)/2

	     @ 02,02 LISTBOX _oProd VAR _cVarQ Fields HEADER "Cod. Prod. Origem","Desc. Prod. Origem","Cod. Prod. Destino","Desc. Prod. Destino","Problemas" SIZE _nTam,110 OF _oDlg PIXEL
		 _oProd:SetArray(_aProd)
		 _oProd:bLine := {|| {;
	     _aProd[_oProd:nAt][1],;
	     ALLTRIM(_aProd[_oProd:nAt][2]),; 
	     _aProd[_oProd:nAt][3],;
	     ALLTRIM(_aProd[_oProd:nAt][4]),;
	     _aProd[_oProd:nAt][5];
	     }}
//		 DEFINE SBUTTON FROM 125,272 TYPE 1 ACTION (_lRet := .F.,U_ITMSG("A operação não pode ser concluída com produtos com Problemas!","Atenção",,1), _oDlg:End()) ENABLE OF _oDlg
//		 DEFINE SBUTTON FROM 125,302 TYPE 2 ACTION (_lRet := .F., _oDlg:End()) ENABLE OF _oDlg
		 @120,010 BUTTON "SAIR" SIZE 40,11 ACTION (_lRet := .F.,U_ITMSG("A operação não pode ser concluída com produtos com Problemas!","Atenção",,1), _oDlg:End()) OF _oDlg PIXEL
         
	  ACTIVATE MSDIALOG _oDlg CENTERED
      ENDIF
   EndIf 

	IF NNR->(FIELDPOS("NNR_I_TPFV")) <> 0 .and. !_lmt103fim .and. !_laglt003 .AND. !_lMCOM004 .AND. !EMPTY(_cArmVirtual) .AND. !EMPTY(_cArmFisico)
		_cLinhas    :=LEFT(_cLinhas,LEN(_cLinhas)-2)
        _cArmVirtual:="["+LEFT(_cLinhas,LEN(_cArmVirtual)-2)+"]"
        _cArmFisico :="["+LEFT(_cLinhas,LEN(_cArmFisico)-2)+"]"
		If !EMPTY(_cLinhas)
			U_ITMSG("Para tranferir produtos entre armazens virtuais "+_cArmVirtual+" e armazens fisicos "+_cArmFisico+" nessa rotina,"+;
			" o campo de observação deve ser preenchido detalhando o motivo da transferencia nas linha "+_cLinhas,;
			"ATENÇÃO",;
			"Preencha a observação da linha com uma descrição minima de 10 caracteres",1)
			_lRet := .F.
		EndIf
	EndIf

   If GETMV("IT_BLQMOV") .AND. DA261DATA > DATE()
	  U_ITMSG("Os movimentos com data maior que a data atual estão bloqueados.",;
	          "Movimento com data maior que a data atual",;
			  "Entre em contato com o departamento de TI para maiores informações.",1)
	  _lRet := .F.
		
   EndIf
   //=====================================================
   //Verifica saldo do produto. Chamado 7816 			  |
   //=====================================================
   If _lRet 
	  For x := 1 To Len(aCols)
          If aTail(aCols[x]) // Se Linha Deletada
             LOOP
          ENDIF
		  _aSldNeg := U_VldEstRetrNeg(aCols[x,1], aCols[x,4], aCols[x,16], DA261DATA)	
		  If Len(_aSldNeg) > 0
			 nDif := _aSldNeg[2] - aCols[x,16]
			 AADD(_aErro,{aCols[x,1],aCols[x,4],dtoc(_aSldNeg[1]),nDif})
			 _lErro := .T.
			 _lRet := .F.
		  Endif
	  Next x                                   
   Endif

   If _lErro .and. !_lmt103fim
	  _cItens := ""
	  For y := 1 To Len(_aErro)
   	      _cItens += _aErro[y,3]+SPACE(3)+ALLTRIM(_aErro[y,1])+"-"+_aErro[y,2]+SPACE(5)+ALLTRIM(TRANSFORM(_aErro[y,4], "@E 999,999,999,999.99"))+CHR(13)+CHR(10)
	  Next y                              
	  u_itmsg( "Quantidade requisitada é maior que o saldo no dia para o(s) produto(s): "+CHR(13)+CHR(10);
				  +"DIA"+SPACE(13)+"PRODUTO"+SPACE(16)+"DIFERENCA"+CHR(13)+CHR(10)+_cItens,"Saldo Insuficiente",;
				  "Verifique o saldo no Kardex.",1)
   Endif

   //=====================================================
   //Verificacao do CM origem e Destino                  |
   //=====================================================
   If _lRet .and. !_lmt103fim .and. !_laglt003 .AND. !_lMCOM004

	  _nDifCM 	:= GetMV( "IT_DIFCM"  ,, 70 ) //Percentual minimo de diferenca de CM para bloquear processo. (71%)
	  _nDifCM2	:= GetMV( "IT_DIFCM2" ,, 50 ) //Percentual minimo de diferenca de CM para exibir mensagem se continua ou nao. (51%)
	  SB2->(DBSETORDER(1))
	
	  For _nI := 1 To Len(aCols)
          If aTail(aCols[_nI]) // Se Linha Deletada
             LOOP
          ENDIF

	   	  _nCMorig := Posicione( "SB2" , 1 , xFilial("SB2") + aCols[_nI][01] + aCols[_nI][04] , "B2_CM1" )//SEEK NO PRODUTO DE ORIGEM
	      SB2->(DBSEEK(xFilial("SB2") + aCols[_nI][06] + aCols[_nI][09]))//SEEK NO PRODUTO DE DESTINO
	 	  _nCMdest := SB2->B2_CM1
		
		  If _nCMdest > 0 .AND. !( SB2->B2_QATU = 0 .AND. SB2->B2_VATU1 = 0 )//PRODUTO DE DESTINO
		
			 _nDifPrd := (_nCMdest - _nCMorig) / _nCMorig
			
			 If _nDifPrd < 0
				_nDifPrd := (_nDifPrd * (-1))
			 Endif
			
			 _nDifPrd := _nDifPrd * 100
			
			 //====================================================================================================
			 // Diferenca entre a % para exibição da mensagem e a % de bloqueio
			 //====================================================================================================
			 If _nDifPrd > _nDifCM2 .and. _nDifPrd <= _nDifCM
			
				AADD( _aErro1 , { _nI , ALLTRIM( aCols[_nI][02] ) , _nDifPrd } )
				_lErro1 := .T.
			
			    //====================================================================================================
			    // Diferença maior ou igual à % de bloqueio
			    //====================================================================================================
			 Elseif _nDifPrd > _nDifCM
			
				 AADD( _aErro2 , { _nI , ALLTRIM( aCols[_nI][02] ) , _nDifPrd } )
				 _lErro2 := .T.
				
			 EndIf
			
		  EndIf
		
	  Next _nI
	
	  If _lErro2 .and. !_lmt103fim .and. !_laglt003 .AND. !_lMCOM004
	
		 For x := 1 to Len(_aErro2)
			 _cItens += CVALTOCHAR(_aErro2[x][1])+" - "
			 _cItens += CVALTOCHAR(_aErro2[x][2])+": "
			 _cItens += ALLTRIM(TRANSFORM(_aErro2[x][3], "@E 999,999,999.9999"))+"% "+CHR(13)+CHR(10)		                  
		 Next x
	
		 u_itmsg("Diferença entre valor de Custo Medio de Origem e Destino no(s) item(ns):"+CHR(13)+CHR(10)+_cItens,"Transferência não permitida!",;
					 "Favor analisar o Kardex! Se necessário, entre em contato com o Depto. de TI.",1)
		 _lRet := .F.
		
	  Elseif _lErro1
	
		 For x := 1 to Len(_aErro1)
			 _cItens += CVALTOCHAR( _aErro1[x][1] ) +" - "
			 _cItens += CVALTOCHAR( _aErro1[x][2] ) +": "
			 _cItens += ALLTRIM(TRANSFORM(  _aErro1[x][3] , "@E 999,999,999.9999" )) +"% "+ CHR(13) + CHR(10)
		 Next x
		
		 If !u_itmsg("Diferença entre valor de Custo Medio de Origem e Destino no(s) item(ns):"+CHR(13)+CHR(10)+_cItens+"Deseja prosseguir?","ATENÇÃO!",,2,2,2)
			_lRet := .F.		
		 Endif
		
	  Endif
	
   Endif

End Sequence

IF TYPE("lMsErroAuto") = "L" .AND. !_lRet .AND. !lMsErroAuto//Só altera o conteudo do lMsErroAuto se ele tiver Falso e o retorno for falso
   lMsErroAuto:=!_lRet//Só Joga verdadeiro de for o caso
ENDIF

RestOrd(_aOrd)

Return (_lRet)
