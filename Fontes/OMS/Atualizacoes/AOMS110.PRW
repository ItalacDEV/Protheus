/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich  |11/04/2019| Chamado 28694. Validações de bloqueio logístico
Lucas Borges  |08/10/2024| Chamado 48465. Retirada manipulação do SX1
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#Include "PROTHEUS.CH"  
#Include "RWMAKE.CH"             

/*
===============================================================================================================================
Programa----------: AOMS110
Autor-------------: Josué Danich Prestes
Data da Criacao---: 19/09/2018
===============================================================================================================================
Descrição---------: Tela de vinculo de pedido de vendas - Chamado 25661
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS110()
Local _cperg := "AOMS110"
Local _cCodUsr	:= RetCodUsr()
Local _nposori := SC5->(Recno())

//Valida bloqueio logístico
If SC5->C5_I_BLOG == "S"

	ZZL->(Dbsetorder(3))
	If !(ZZL->(Dbseek(xFilial("ZZL") + RetCodUsr()))) .OR. ZZL->ZZL_PVLOG != "S"	

		U_MT_ITMSG("Pedido em Planejamento Logístico, operação não permitida, Por favor entrar em contato com área de Logística","Atenção",,1)
		Return

	Endif

Endif

//Valida se pedido pode ser alterado
SC9->( DbSetOrder(1) )
IF SC9->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) ) 
      DO While SC9->( !EOF() ) .AND. SC9->( C9_FILIAL + C9_PEDIDO ) == SC5->C5_FILIAL + SC5->C5_NUM
          IF !EMPTY(SC9->C9_NFISCAL)
              U_MT_ITMSG("Pedido selecionado "+ALLTRIM(SC5->C5_NUM)+" já tem Nota: "+SC9->C9_NFISCAL,"Atenção!","Estorne a Nota "+ALLTRIM(SC9->C9_NFISCAL)+" ou selecione outro pedido",1)
              Return
          ENDIF 
          IF !EMPTY(SC9->C9_CARGA)
              U_MT_ITMSG("Pedido selecionado "+ALLTRIM(SC5->C5_NUM)+" já esta na carga: "+SC9->C9_CARGA,"Atenção!","Estorne a carga "+ALLTRIM(SC9->C9_CARGA)+" ou selecione outro pedido",1)
              Return
          ENDIF 
           SC9->(DBSKIP())
	   ENDDO
ENDIF

//Se o pedido já tiver pedido vinculado verifica se o pedido vinculado pode ser alterado
_nposori := SC5->(Recno())
_cpedido := SC5->C5_NUM

SC5->(Dbsetorder(1))
If SC5->(Dbseek(SC5->C5_FILIAL+SC5->C5_I_PEVIN))

	//Valida bloqueio logístico
	If SC5->C5_I_BLOG == "S"

		ZZL->(Dbsetorder(3))
		If !(ZZL->(Dbseek(xFilial("ZZL") + RetCodUsr()))) .OR. ZZL->ZZL_PVLOG != "S"	

	        U_MT_ITMSG("Pedido selecionado "+ALLTRIM(_cpedido)+" possui pedido vinculado, " + SC5->C5_NUM + " e em Planejamento Logístico. Por favor entrar em contato com área de Logística. ",;
              													"Atenção!","Retire o Planejamento Logístico ou selecione outro pedido",1)
   			Return

		Endif

	Endif

	SC9->( DbSetOrder(1) )
	IF SC9->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) ) 
      DO While SC9->( !EOF() ) .AND. SC9->( C9_FILIAL + C9_PEDIDO ) == SC5->C5_FILIAL + SC5->C5_NUM
          IF !EMPTY(SC9->C9_NFISCAL)
              U_MT_ITMSG("Pedido selecionado "+ALLTRIM(_cpedido)+" possui pedido vinculado, " + SC5->C5_NUM + " já tem Nota: "+SC9->C9_NFISCAL,;
              													"Atenção!","Estorne a Nota "+ALLTRIM(SC9->C9_NFISCAL)+" ou selecione outro pedido",1)
              Return
          ENDIF 
          IF !EMPTY(SC9->C9_CARGA)
              U_MT_ITMSG("Pedido selecionado "+ALLTRIM(_cpedido)+" possui pedido vinculado, " + SC5->C5_NUM + " já esta na carga: "+SC9->C9_CARGA,;
              "Atenção!","Estorne a carga "+ALLTRIM(SC9->C9_CARGA)+" ou selecione outro pedido",1)
              Return
          ENDIF 
           SC9->(DBSKIP())
	   ENDDO
	ENDIF

Endif

SC5->(Dbgoto(_nposori))

If SC5->C5_I_ENVRD != "V"

	_cperg := "AOMS1102"
	
Endif

Pergunte(_cperg,.F.)
MV_PAR01 := SC5->C5_I_PEVIN
MV_PAR02 := 1

If Pergunte(_cperg)

	SC5->(Dbgoto(_nposori))
	_cpedido := SC5->C5_NUM
	
	//valida para não escolher o próprio pedido
	If alltrim(SC5->C5_NUM) == alltrim(MV_PAR01)
	
		U_ITMSG("Não é possível vincular um pedido a si mesmo","Atenção",,1)
		Return
		
	Endif

	//Se o MV_PAR01 estiver em branco pergunta se quer remover vinculo do pedido de vendas
	If EMPTY(MV_PAR01) .AND. EMPTY(SC5->C5_I_PEVIN)
	
		U_ITMSG("Pedido atual não tem vínculo registrado, obrigatório indicar um vínculo","Atenção","Preencha o campo de pedido à vincular",1)
		Return
		
	Elseif EMPTY(MV_PAR01)
	
		If !(U_ITMSG("Deseja limpar vínculo do pedido " +SC5->C5_NUM + " com o pedido "+ SC5->C5_I_PEVIN + "?","Atenção",,2,2,2))
		
			u_itmsg("Processo cancelado","Atenção",,1)
			Return
		
		Endif
		
	Endif

	//Valida se pedido selecionado pode ser vinculado
     IF !EMPTY(MV_PAR01) .and. !SC5->(DBSEEK(xFilial()+MV_PAR01))
         U_MT_ITMSG("O Pedido vinculado "+MV_PAR01+" não existe.","PEDIDO VINCULADO",;
		            "Selecione um Pedido cadastrado",1)

		 Return
		       
     ELSEIF !EMPTY(MV_PAR01) .and. !EMPTY(SC5->C5_I_PEVIN) .AND. !(SC5->C5_I_PEVIN == _CPEDIDO)
      
         U_MT_ITMSG("O Pedido selecionado " + MV_PAR01 + " já esta vinculado com outro Pedido: "+SC5->C5_I_PEVIN,"PEDIDO VINCULADO",;
		            "Selecione outro um Pedido",1)

		 Return

	 ELSEIF SC5->C5_I_BLOG == "S"

		ZZL->(Dbsetorder(3))
		If !(ZZL->(Dbseek(xFilial("ZZL") + RetCodUsr()))) .OR. ZZL->ZZL_PVLOG != "S"	

	        U_MT_ITMSG("Pedido selecionado "+ALLTRIM(SC5->C5_NUM)+" em Planejamento Logístico!",;
              													"Atenção!","Retire do Planejamento Logístico ou selecione outro pedido",1)
   			Return

		Endif

     ELSEif !EMPTY(MV_PAR01)   //ve se tem carga e nota
      
         SC9->( DbSetOrder(1) )
         IF SC9->( DBSeek( SC5->C5_FILIAL + MV_PAR01 ) ) 
	        DO While SC9->( !EOF() ) .AND. SC9->( C9_FILIAL + C9_PEDIDO ) == SC5->C5_FILIAL + MV_PAR01
	           IF !EMPTY(SC9->C9_NFISCAL)
                  U_MT_ITMSG("Pedido Vinculado "+ALLTRIM(MV_PAR01)+" já tem Nota: "+SC9->C9_NFISCAL,"Atenção!","Estorne a Nota "+ALLTRIM(SC9->C9_NFISCAL)+" ou selecione outro pedido",1)
                  Return
	           ENDIF 
	           IF !EMPTY(SC9->C9_CARGA)
                  U_MT_ITMSG("Pedido selecionado "+ALLTRIM(MV_PAR01)+" já esta na carga: "+SC9->C9_CARGA,"Atenção!","Estorne a carga "+ALLTRIM(SC9->C9_CARGA)+" ou selecione outro pedido",1)
                  Return
	           ENDIF 
	           SC9->(DBSKIP())
	        ENDDO
         ENDIF
      
     ENDIF
	
	SC5->(Dbgoto(_nposori))
	
	BEGIN TRANSACTION

	//Se possui um vinculo atual diferente do indicado no MV_PAR01 apaga vinculo do pedido vinculado
	If !EMPTY(SC5->C5_I_PEVIN) .AND. ALLTRIM(MV_PAR01) !=  ALLTRIM(SC5->C5_I_PEVIN) .AND. SC5->(Dbseek(SC5->C5_FILIAL+SC5->C5_I_PEVIN))
    
		_aLogSC5 := U_ITIniLog( 'SC5')
    
		Reclock("SC5",.F.)
		SC5->C5_I_PEVIN := ""
		If SC5->C5_I_ENVRD == "V" .AND. MV_PAR02 = 1 
			SC5->C5_I_ENVRD := "R"
			SC5->C5_I_DTRET := DATE() - 1
			SC5->C5_I_HRRET := TIME()
			_CMENS := " - Pedido vinculado anteriormente" + SC5->C5_NUM + " liberado para envio ao RDC."
		Endif
		SC5->(Msunlock())
		
		//Grava log de alteração de tabela
         U_ITGrvLog( _aLogSC5 , "SC5" , 1 , SC5->( C5_FILIAL + C5_NUM ) ,"A" , _cCodUsr , date() , time() )    
		
		
		//Verifica se o pedido de vendas existe no RDC 
		_cQry := "select pedido,pedid2 from rdcitl.TGA447 WHERE  "
		_cQry += " pedido = '" + alltrim(SC5->C5_NUM) + "'"

		If select ("TRBPED") > 0

			dbselectarea("TRBPED")
			TRBPED->(Dbclosearea())
	
		Endif

		dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBPED" , .T., .F. )

		dbSelectArea("TRBPED")

		//se existe atualiza campo pedid2
		If !TRBPED->(Eof())
		
			_cQry := " UPDATE rdcitl.TGA447 SET pedid2 = ''"
			_cQry += " WHERE pedido = '" + alltrim(SC5->C5_NUM) + "'"
						
			_nres := TCSqlExec(_cQry)
		
		Elseif MV_PAR02 = 1
		
			//Se não existe marca o pedido para ser enviado ao RDC
			Reclock("SC5",.F.)
			SC5->C5_I_ENVRD := "R"
			SC5->C5_I_DTRET := DATE() - 1
			SC5->C5_I_HRRET := TIME()
			SC5->(Msunlock())
				
		Endif
		
		If select ("TRBPED") > 0

			dbselectarea("TRBPED")
			TRBPED->(Dbclosearea())
	
		Endif
		
	Endif

	SC5->(Dbgoto(_nposori))
	_CMENS := ""
	
	_aLogSC5 := U_ITIniLog( 'SC5')
	
	Reclock("SC5",.F.)
	//Se libera para envio ao RDC marca como recuperado em data anterior para o schedule gerar muro e enviar
	If SC5->C5_I_ENVRD == "V" .AND. MV_PAR02 = 1
		SC5->C5_I_ENVRD := "R"
    	SC5->C5_I_DTRET := DATE() - 1
    	SC5->C5_I_HRRET := TIME()
    	_CMENS := " - Pedido " + SC5->C5_NUM + " liberado para envio ao RDC."
    Endif
    
    SC5->C5_I_PEVIN := ALLTRIM(MV_PAR01)
    
    SC5->(Msunlock())
    
    //Grava log de alteração de tabela
     U_ITGrvLog( _aLogSC5 , "SC5" , 1 , SC5->( C5_FILIAL + C5_NUM ) ,"A" , _cCodUsr , date() , time() )    
        
    //Verifica se o pedido de vendas existe no RDC 
	_cQry := "select pedido,pedid2 from rdcitl.TGA447 WHERE  "
	_cQry += " pedido = '" + alltrim(SC5->C5_NUM) + "'"

	If select ("TRBPED") > 0

		dbselectarea("TRBPED")
		TRBPED->(Dbclosearea())
	
	Endif

	dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBPED" , .T., .F. )

	dbSelectArea("TRBPED")

	//se existe atualiza campo pedid2
	If !TRBPED->(Eof())
		
		_cQry := " UPDATE rdcitl.TGA447 SET pedid2 = '" + ALLTRIM(SC5->C5_I_PEVIN) + "'"
		_cQry += " WHERE pedido = '" + alltrim(SC5->C5_NUM) + "'"
						
		_nres := TCSqlExec(_cQry)
		
	Elseif MV_PAR02 = 1
		
		//Se não existe marca o pedido para ser enviado ao RDC
		Reclock("SC5",.F.)
		SC5->C5_I_ENVRD := "R"
		SC5->C5_I_DTRET := DATE() - 1
		SC5->C5_I_HRRET := TIME()
		SC5->(Msunlock())
				
	Endif
		
	If select ("TRBPED") > 0

		dbselectarea("TRBPED")
		TRBPED->(Dbclosearea())
	
	Endif
    
    
    //Atualiza pedido vinculado
    If !EMPTY(MV_PAR01) 
    	SC5->(Dbseek(SC5->C5_FILIAL+SC5->C5_I_PEVIN))
    	
    	_aLogSC5 := U_ITIniLog( 'SC5')
    	
    	Reclock("SC5",.F.)
    	SC5->C5_I_PEVIN := _cpedido
    	//Se libera para envio ao RDC marca como recuperado em data anterior para o schedule gerar muro e enviar
    	If SC5->C5_I_ENVRD == "V" .AND. MV_PAR02 = 1
    		SC5->C5_I_ENVRD := "R"
    		SC5->C5_I_DTRET := DATE() - 1
    		SC5->C5_I_HRRET := TIME()
    		_CMENS := " - Pedido " + SC5->C5_NUM + " vinculado também liberado para envio ao RDC."
    	Endif
    	SC5->(Msunlock())
    	
    	//Grava log de alteração de tabela
         U_ITGrvLog( _aLogSC5 , "SC5" , 1 , SC5->( C5_FILIAL + C5_NUM ) ,"A" , _cCodUsr , date() , time() )    
           
    	//Verifica se o pedido de vendas existe no RDC 
		_cQry := "select pedido,pedid2 from rdcitl.TGA447 WHERE  "
		_cQry += " pedido = '" + alltrim(SC5->C5_NUM) + "'"

		If select ("TRBPED") > 0

			dbselectarea("TRBPED")
			TRBPED->(Dbclosearea())
	
		Endif

		dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBPED" , .T., .F. )

		dbSelectArea("TRBPED")

		//se existe atualiza campo pedid2
		If !TRBPED->(Eof())
		
			_cQry := " UPDATE rdcitl.TGA447 SET pedid2 = '" + ALLTRIM(SC5->C5_I_PEVIN) + "'"
			_cQry += " WHERE pedido = '" + alltrim(SC5->C5_NUM) + "'"
						
			_nres := TCSqlExec(_cQry)
		
		Elseif MV_PAR02 = 1
		
			//Se não existe marca o pedido para ser enviado ao RDC
			Reclock("SC5",.F.)
			SC5->C5_I_ENVRD := "R"
			SC5->C5_I_DTRET := DATE() - 1
			SC5->C5_I_HRRET := TIME()
			SC5->(Msunlock())
				
		Endif
		
		If select ("TRBPED") > 0

			dbselectarea("TRBPED")
			TRBPED->(Dbclosearea())
	
		Endif
    	    	
    Endif
    
    END TRANSACTION
    
    SC5->(Dbgoto(_nposori))

    u_itmsg("Vínculo do pedido " + SC5->C5_NUM + " atualizado com sucesso!","Atenção","Pedido vinculado: " + SC5->C5_I_PEVIN + _CMENS,3)

Else

	u_itmsg("Encerrado sem alterações","Atenção",,1)
	
Endif

Return
