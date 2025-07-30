/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer |30/05/2023| Chamado 43996. Validacao de acesso do usuario para colocar a data em branco.  
Lucas Borges  |22/04/2025| Chamado 50505. Alterada a picture do CNPJ para contemplar campo alfanumérico
Lucas Borges  |09/05/2025| Chamado 50617. Corrigir chamada estática no nome das tabelas do sistema
===============================================================================================================================
*/

#Include 'Protheus.ch'

#define	MB_OK				0
#define 	MB_ICONASTERISK	64

/*
===============================================================================================================================
Programa----------: ACOM008
Autor-------------: Darcio Ribeiro Sporl 
Data da Criacao---: 30/06/2015
Descrição---------: Rotina para alteração de data de faturamento por pedido de compras
Parametros--------: Nenhum
Retorno-----------: Nenhum 
===============================================================================================================================
*/
User Function ACOM008(_lAltLoja)
Local aArea			:= GetArea()
Local cGet1			:= StoD("//")
Local _cMotivo   	:= SPACE(LEN(ZY1->ZY1_COMENT))
Local nX			:= 0
Local cQry			:= ""
Local cAliasQry		:= GetNextAlias()
Local aHeader		:= {}
Local aCols			:= {}
Local aRecnos		:= {}
Local aFields		:= {"C7_NUM","C7_TIPO","C7_ITEM","C7_I_DTFAT","C7_PRODUTO","C7_DESCRI","A2_NOME"}
Local aAlterFields	:= {}
Local nOpc			:= 0
Local _cCampoSX3

Local oGet1
Local oSayNDF
Local oSButton1
Local oSButton2
Local oDlg

Private oMSNewSC7

dbSelectArea("SY1")
SY1->(dbSetOrder(3)) //Y1_FILIAL + Y1_USER
If SY1->(dbSeek(xFilial("SY1") + __cUserID))
	
	IF !_lAltLoja
		//Montagem do aheader
		aHeader := {}
		aCols   := {}
		For nX := 1 To Len(aFields)
			_cCampoSX3 := aFields[nX]
			aAdd( aHeader , {   Getsx3cache(_cCampoSX3,"X3_TITULO")  ,;
			Getsx3cache(_cCampoSX3,"X3_CAMPO")   ,;
			Getsx3cache(_cCampoSX3,"X3_PICTURE") ,;
			Getsx3cache(_cCampoSX3,"X3_TAMANHO") ,;
			Getsx3cache(_cCampoSX3,"X3_DECIMAL") ,;
			Getsx3cache(_cCampoSX3,"X3_VALID")   ,;
			Getsx3cache(_cCampoSX3,"X3_USADO")   ,;
			Getsx3cache(_cCampoSX3,"X3_TIPO")    ,;
			Getsx3cache(_cCampoSX3,"X3_F3")      ,;
			Getsx3cache(_cCampoSX3,"X3_CONTEXT")  })
		Next
	ENDIF
	
	// Somente sao selecionados itens que nao possuem restricoes
	cQry := "SELECT C7_NUM,C7_TIPO,C7_ITEM,C7_PRODUTO,C7_DESCRI,C7_I_DTFAT,C7_FORNECE,C7_LOJA,SC7.R_E_C_N_O_ AS RECSC7,A2_NOME "
	cQry += "FROM " + RetSqlName("SC7") + " SC7 "
	cQry += "INNER JOIN " + RetSqlName("SA2") + " SA2 ON A2_FILIAL = '" + xFilial("SA2") + "' AND A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.D_E_L_E_T_ = ' ' "
	cQry += "WHERE C7_FILIAL = '" + xFilial("SC7") + "' "
	cQry += "  AND C7_NUM = '" + SC7->C7_NUM + "' "
	cQry += "  AND ((C7_QUJE < C7_QUANT "
	cQry += "  OR C7_QTDACLA > 0 ) "
	cQry += "  AND C7_RESIDUO <> 'S') "
	cQry += "  AND SC7.D_E_L_E_T_ = ' ' "
	cQry := ChangeQuery(cQry)
	MPSysOpenQuery(cQry,cAliasQry)
	
	(cAliasQry)->( DBGoTop() )
	
	If !(cAliasQry)->(Eof())
		
		IF !_lAltLoja
		   
		   DO While (cAliasQry)->(!Eof())
				Aadd(aCols,		{(cAliasQry)->C7_NUM, (cAliasQry)->C7_TIPO, (cAliasQry)->C7_ITEM, StoD((cAliasQry)->C7_I_DTFAT), (cAliasQry)->C7_PRODUTO, (cAliasQry)->C7_DESCRI,  (cAliasQry)->A2_NOME,.F.})
				Aadd(aRecnos,	(cAliasQry)->RECSC7)
				(cAliasQry)->(dbSkip())
		   ENDDO
			
			DEFINE MSDIALOG oDlg TITLE "Pedido de Compra - Alt.Dt.Fat.PC" FROM 000, 000  TO 300, 700 COLORS 0, 16777215 PIXEL
			
			oMSNewSC7 := MsNewGetDados():New( 001, 002, 101, 348, , "AllwaysTrue", "AllwaysTrue", "", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeader, aCols)
			@ 109, 002 SAY oSayNDF PROMPT "Nova Data Faturamento: " SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 107, 064 MSGET oGet1 VAR cGet1 SIZE 055, 010 OF oDlg VALID U_VLDDTFAT(cGet1,2,aRecnos) COLORS 0, 16777215 PIXEL
			
			@ 109, 125 SAY "Comentario:" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
			@ 107, 155 MSGET _cMotivo    SIZE 190, 010 OF oDlg COLORS 0, 16777215 PIXEL
			
			DEFINE SBUTTON oSButton1 FROM 129, 142 TYPE 01 OF oDlg ENABLE ACTION (IF(VLDUSER(cGet1),(nOpc:=1, oDlg:End()),))
			DEFINE SBUTTON oSButton2 FROM 129, 175 TYPE 02 OF oDlg ENABLE ACTION (nOpc := 0, oDlg:End())
			
			ACTIVATE MSDIALOG oDlg CENTERED
			
		ELSE
			
		   DO While (cAliasQry)->(!Eof())
				Aadd(aRecnos,	(cAliasQry)->RECSC7)
				(cAliasQry)->(dbSkip())
		   ENDDO
			cGetFor :=SC7->C7_FORNECE
			cGetLoj :=SC7->C7_LOJA
			cGetDFor:=Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NREDUZ")
  			cNovLoj :=SPACE(LEN(SC7->C7_LOJA))
            aNovLoj :={}
			IF SA2->(DBSEEK(xFilial("SA2")+SC7->C7_FORNECE))
			   DO WHILE SA2->(!EOF()) .AND. xFilial("SA2")+SC7->C7_FORNECE == SA2->A2_FILIAL+SA2->A2_COD
			      IF SA2->A2_MSBLQL <> '1'
			         If RetPessoa(SA2->A2_CGC) == "F"
			         	cCNPJCli := Transform(SA2->A2_CGC,"@R 999.999.999-99")
         			Else                                                      
		         		cCNPJCli := Transform(SA2->A2_CGC,"@R! NN.NNN.NNN/NNNN-99")
         			Endif
			         AADD(aNovLoj,SA2->A2_LOJA+" - "+cCNPJCli)
			      ENDIF   
			      SA2->(DBSKIP())
			   ENDDO   
			ENDIF

			DEFINE MSDIALOG oDlg TITLE "Pedido Compra - Alteração da Loja do Forncedor" FROM 000, 000  TO 190, 385 COLORS 0, 16777215 PIXEL
			
			@ 005, 006 SAY "Fornecedor:" SIZE 030, 007 OF oDlg PIXEL
			@ 015, 006 MSGET cGetFor     SIZE 050, 010 OF oDlg READONLY PIXEL  F3 "SA2"
			
			@ 005, 070 SAY "Nome:"       SIZE 025, 007 OF oDlg PIXEL
			@ 015, 070 MSGET cGetDFor    SIZE 120, 010 OF oDlg READONLY PIXEL
			
			@ 029, 006 SAY "Loja Atual:" SIZE 025, 007 OF oDlg PIXEL
			@ 039, 006 MSGET cGetLoj     SIZE 050, 010 OF oDlg READONLY PIXEL
			
			@ 029, 070 SAY "Nova Loja:"  SIZE 041, 007 OF oDlg COLORS 16711680, 16777215 PIXEL
//			@ 040, 070 MSGET cNovLoj     SIZE 060, 010 OF oDlg PIXEL
            @ 039, 070 ComboBox cNovLoj  Items aNovLoj Size 120,80 Pixel Of oDlg VALID NaoVazio(cNovLoj)

	        @ 060, 006 SAY "Comentario:" SIZE 056, 007 OF oDlg COLORS 16711680, 16777215 PIXEL
	        @ 059, 040 MSGET _cMotivo    SIZE 150, 010 OF oDlg PIXEL 
			
			DEFINE SBUTTON oSButton1 FROM 075, 064 TYPE 01 OF oDlg ENABLE ACTION (nOpc := 2, oDlg:End())
			DEFINE SBUTTON oSButton2 FROM 075, 118 TYPE 02 OF oDlg ENABLE ACTION (nOpc := 0, oDlg:End())
			
			ACTIVATE MSDIALOG oDlg CENTERED			
			
		ENDIF
		
		If nOpc == 1

			If U_VLDDTFAT(cGet1,2,aRecnos)

			    _dDataOld:=CTOD("")
				dbSelectArea("SC7")
				For nX := 1 To Len(aRecnos)
					dbGoTo(aRecnos[nX])
					_dDataOld:=SC7->C7_I_DTFAT
					SC7->(RecLock("SC7",.F.))
					SC7->C7_I_DTFAT := cGet1
					SC7->(MsUnLock())
				Next nX

                ACOM8Monitor(_dDataOld,_cMotivo)
	            //Atualiza tabela ZZH de indicaores de pagamentos para pedidos de compra
	            U_ACOM008ZZH(alltrim(SC7->C7_FILIAL), alltrim(SC7->C7_NUM))

            	U_ITMSG("Data de Faturamento alterada de " + dtoc(_dDataOld) + " para " + DTOC(cGet1) +" com sucesso.","Atenção",,2)
	
			EndIf

		ELSEIf nOpc == 2
            
            cNovLoj:=LEFT(cNovLoj,LEN(SC7->C7_LOJA))
			
			dbSelectArea("SC7")
			For nX := 1 To Len(aRecnos)
				dbGoTo(aRecnos[nX])
				SC7->(RecLock("SC7",.F.))
				SC7->C7_LOJA := cNovLoj
				SC7->(MsUnLock())
			Next 
                
            _cMotivo:="Loja alterada de " + cGetLoj + " para " + cNovLoj+" - "+ALLTRIM(_cMotivo)
                
            ACOM8Monitor("",_cMotivo)

            U_ITMSG("Loja do Fornecedor alterada de " + cGetLoj + " para " + cNovLoj +" com sucesso.","Atenção",,2)

		EndIf
		
	Else
	
        U_ITMSG("Esse pedido possui itens com restrições","Pedido Inválido","Favor selecionar um pedido de compras válido!",1)
	
	EndIf
	
	(cAliasQry)->( DBCloseArea() )

Else

    U_ITMSG("O usuário: " + UsrFullName(__cUserID) + " não possui acesso para utilizar esta rotina.","Usuário Inválido","Verifique o cadastro do usuário como comprador.",1)

EndIf

//======================================================================
// Grava log da alteração de data de faturamento por pedido de compras 
//====================================================================== 
U_ITLOGACS('ACOM008')

RestArea(aArea)

Return    

/*
===============================================================================================================================
Programa----------: ACOM008ZZH 
Autor-------------: Josué Danich 
Data da Criacao---: 22/07/2015
Descrição---------: Rotina que atualiza a ZZH para um determinado pedido.
Parametros--------: _cfilial -> Filial do pedido que será atualizado para a ZZH
                    _cpedido -> Número do pedido que será atualziado para a ZZH
Retorno-----------: Nenhum 
===============================================================================================================================
*/
user function ACOM008ZZH(_cfilial, _cpedido)

Local _dDtVenc := CTOD('')
Local _nTOTAL := 0
Local _aCond := ""
Local _nprorp := 0     
Local _aDadVenc := {}
Local _nI := 1
Local aArea			:= GetArea()  
Local _lIgual := .T. 
Local _ccondi := 0

//carrega dados do sc7
dbSelectArea("SC7")
SC7->( dbSetOrder(1) )
If SC7-> ( dbSeek(_cfilial + _cpedido) )

  DO WHILE ALLTRIM(SC7->C7_FILIAL)+alltrim(SC7->C7_NUM) == alltrim(_cfilial)+alltrim(_cpedido) .AND. SC7->(!EOF())
  
   
    //só continua se tiver data de faturamento marcada
    if SC7->C7_I_DTFAT > ctod('01/01/2001')  
    
      _nTOTAL := ( ( ( (SC7->C7_PRECO * SC7->C7_QUANT )+SC7->C7_VALIPI+SC7->C7_DESPESA) - SC7->C7_VLDESC ) / SC7->C7_QUANT ) * ( SC7->C7_QUANT - SC7->C7_QUJE )
      _aCond		:= Condicao( _nTOTAL , SC7->C7_COND , 0 , SC7->C7_I_DTFAT )
      _lIgual := .T.
   
      //Arruma datas, proporcionalidade e monta matriz de vencimentos
      For _nI := 1 To Len( _aCond )
			
         _dDtVenc := DataValida( _aCond[_nI][01] ) //só dias úteis
	
         _nprorp := Round( _aCond[_nI][2]/_nTOTAL , 2 )  //indica proporcionalidade da parcela
 	            
         //se é primeira passagem grava a primeira proporção para comparar com as seeguintes
         if _nI == 1
 	              
             _ccondi := _nprorp
 	              
         else
 	            
             if _ccondi != _nprorp  //compara para ver se tem proporção diferente da primeira
 	              
                _ligual := .F.
 	                
             endif
 	              
         endif  
	
         aAdd( _aDadVenc , { _dDtVenc , Round( _aCond[_nI][2] , 2 ), _nprorp, SC7->C7_ITEM } )
          
      Next _nI
              
      //verifica se _nprorp é igual para todas as parcelas
      // se for deixa zerado para o BI calcular o valor com menor margemd e erro por arredondamento
      if _ligual
                
         For _nI := 1 To Len( _aDadVenc )
                
            _aDadVenc[_nI][3] := 0
                
         Next _nI
                
      endif

    Endif
	
	SC7-> ( DbSkip() )
		
  Enddo                   
  
  //primeiro apaga todos os registros do pedido
  Dbselectarea("ZZH")
  ZZH->( DBSetOrder(1) )
   
  if ZZH->( DBSeek( alltrim(_cfilial)+alltrim(_cpedido) ) )
   
     do while alltrim(ZZH->ZZH_PEDIDO) == alltrim(_cpedido)
     
       ZZH->(RecLock( "ZZH" , .F. ) )
       ZZH->( DBDelete () )
       ZZH->(MsUnlock())
       
       ZZH-> ( DbSkip () )
       
     enddo
   
  endif
       
  //Então reinclui     

  For _nI := 1 To Len( _aDadVenc ) 
  
      ZZH->(RecLock( "ZZH" , .T. ) )
      ZZH->ZZH_FILIAL := _cfilial
      ZZH->ZZH_PEDIDO := _cpedido
      ZZH->ZZH_DATA   := _aDadVenc[_ni][1]
      ZZH->ZZH_PRORP  := _aDadVenc[_ni][3]  
      ZZH->ZZH_ITEMPC := _aDadVenc[_ni][4]
      ZZH->ZZH_VALOR  := _aDadVenc[_ni][2]
      ZZH->(MsUnlock())
  
  Next _nI
		
endif

//======================================================================
// Grava log da atualização da ZZH para um determinado pedido.
//====================================================================== 
U_ITLOGACS('ACOM008ZZH')

RestArea(aArea)

return

/*
===============================================================================================================================
Programa----------: ACOM8Monitor()
Autor-------------: Alex Wallauer
Data da Criacao---: 20/09/2018
Descrição---------: Rotina que atualiza a ZY1 do monitor
Parametros--------: _dDataOld:= dt anterior
Retorno-----------: Nenhum 
===============================================================================================================================
*/
STATIC function ACOM8Monitor(_dDataOld,_cMotivo)

LOCAL aRecnos2 := {} , nX
LOCAL _cQryZY1 := "SELECT R_E_C_N_O_ ZY1_REC , ZY1_SEQUEN "
_cQryZY1 += "FROM " + RetSqlName("ZY1") + " "
_cQryZY1 += "WHERE ZY1_FILIAL = '" + SC7->C7_FILIAL + "' "
_cQryZY1 += "  AND ZY1_NUMPC = '" + SC7->C7_NUM + "' "
_cQryZY1 += "  AND D_E_L_E_T_ = ' ' "
_cQryZY1 := ChangeQuery(_cQryZY1)
MPSysOpenQuery(_cQryZY1,"TRBZY1")
	
TRBZY1->(dbGoTop())
_cSeque:="0"
If !TRBZY1->(Eof()) .And. !Empty(TRBZY1->ZY1_SEQUEN)

   DO WHILE TRBZY1->(!Eof())
      AADD(aRecnos2, TRBZY1->ZY1_REC )
      IF VAL(TRBZY1->ZY1_SEQUEN) > VAL(_cSeque)
         _cSeque := TRBZY1->ZY1_SEQUEN
      ENDIF
     TRBZY1->(DBSKIP())
   ENDDO
    _cSeque := Soma1(_cSeque)

ELSE
   _cSeque := STRZERO(1,LEN(ZY1->ZY1_SEQUEN)) 
ENDIF   

TRBZY1->(dbCloseArea())

ZY1->(RecLock("ZY1", .T.))
ZY1->ZY1_FILIAL	:= SC7->C7_FILIAL
ZY1->ZY1_NUMPC	:= SC7->C7_NUM
ZY1->ZY1_SEQUEN	:= _cSeque
ZY1->ZY1_DTMONI	:= Date()
ZY1->ZY1_HRMONI	:= Time()
IF EMPTY(_cMotivo)
   ZY1->ZY1_COMENT:="Data de faturamento alterada de " + dtoc(_dDataOld) + " para " + DTOC(SC7->C7_I_DTFAT)
ELSE
   ZY1->ZY1_COMENT:=_cMotivo
ENDIF
ZY1->ZY1_CODUSR	:= __cUserID
ZY1->ZY1_NOMUSR	:= UsrFullName(__cUserID)
ZY1->ZY1_DTNECE := SC7->C7_DATPRF
ZY1->ZY1_DTFAT  := SC7->C7_I_DTFAT
ZY1->(MsUnLock())

For nX := 1 To Len(aRecnos2)
   ZY1->(DBGOTO(aRecnos2[nX]))
   ZY1->(RecLock("ZY1", .F.))
   ZY1->ZY1_DTFAT:= SC7->C7_I_DTFAT 
   ZY1->(MsUnLock())
Next nX

RETURN 

/*
===============================================================================================================================
Programa----------: VLDUSER()
Autor-------------: Alex Wallauer
Data da Criacao---: 30/05/2023
Descrição---------: Validacao do acesso do usuario 
Parametros--------: cGet1
Retorno-----------: _lRet := .T. OU .F. 
===============================================================================================================================
*/
STATIC FUNCTION VLDUSER(cGet1)
LOCAL _lRet:=.T.
IF ZZL->(FIELDPOS("ZZL_AUDTFA")) <> 0 .AND. EMPTY(cGet1)
   IF !U_ITVACESS( 'ZZL' , 3 , 'ZZL_AUDTFA' , "S" )
      U_ITMSG("O campo data de faturamento não pode ficar em branco.","VALIDACAO DA DATA",;
	          "Para deixar em branco, favor entrar em contato com Supervisor da Area de Compras!",3)
      _lRet := .F.
   ENDIF
ENDIF
RETURN _lRet
