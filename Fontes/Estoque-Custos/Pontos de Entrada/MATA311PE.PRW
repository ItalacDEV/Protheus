/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
     Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer   | 09/05/2022 | Chamado 39945. Nova validacao da efetivcao dDataBase < NNS->NNS_DATA
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer   | 24/05/2022 | Chamado 40206. Nova validacao do MV_RASTRO está como "S"
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz       | 23/05/2024 | Chamado 46558. Criação da função MA311VLD() chamada na validação de campos.
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges    | 23/07/2025 | Chamado 51340. Ajustar função para validação de ambiente de teste
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#DEFINE CRLF		Chr(13) + Chr(10)

/*
===============================================================================================================================
Programa----------: MATA311
Autor-------------: Alex Wallauer
Data da Criacao---: 24/08/2021
===============================================================================================================================
Descrição---------: Ponto de entrada MVC MATA311 - Solicitacao de transferencia de armazens. CHAMADO 23063
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: lRet 
===============================================================================================================================
*/
User Function MATA311()
Local aParam:= PARAMIXB
Local _lRet := .T. 
Local _nni	:= 0
STATIC _cArmAcesso:=""
STATIC _cFilAcesso:=""

    If aParam <> NIL
        oObj      := aParam[1]
        cIdPonto  := aParam[2]
        cIdModel  := aParam[3]
        _nOper    := oObj:GetOperation()

	    If cIdPonto == 'MODELVLDACTIVE' 
       
		    _cUsrID	:= RetCodUsr()
          ZZL->(dbSetOrder(3)) //ZZL_FILIAL + ZZL_CODUSUs
          If !ZZL->(dbSeek(xFilial("ZZL") + __cUserId)) 
             U_ITmsg("Usuário sem permissão para acessar essa Rotina.",'Atenção!',"Cadastre o seu usuario no Cadastro de Gestao de Ususarios",,,,.T.)  //HELP PARA O MVC
             _lRet := .F.
          ENDIF
          IF (_nPos:=AT("/",ZZL->ZZL_ARMEFE)) > 0 
	          _cFilAcesso:=LEFT(ZZL->ZZL_ARMEFE, _nPos-1 )
             _cArmAcesso:=ALLTRIM(SUBSTR(ZZL->ZZL_ARMEFE, _nPos+1 ))
          ELSE   
             _cFilAcesso:=cFilAnt
             _cArmAcesso:=ALLTRIM(ZZL->ZZL_ARMEFE)
          ENDIF   
          If _lRet  .AND. !(cFilAnt $ _cFilAcesso)
             U_ITmsg("Usuário não tem permissão para acessar essa Rotina na Filial Atual: "+cFilAnt,'Atenção!',"Usuário só pode acessar essas Filiai(s): "+(_cFilAcesso),,,,.T.)  //HELP PARA O MVC
	         _lRet := .F.
          ENDIF

          if _lRet  .AND. IsInCallStack('A311Efetiv')//( _nOper == 4)
             IF _cUsrID = ALLTRIM(NNS->NNS_SOLICT)
                U_ITmsg("Solicitante da transferência não pode efetivar sua própria solicitação",'Atenção!',,,,,.T.)  //HELP PARA O MVC
			       _lRet := .F.
             ENDIF
             IF dDataBase < NNS->NNS_DATA
                U_ITmsg("Não é possivel efetivar transfência. Data logada no sistema tem que ser maior ou igual a data da solicitação da transferência: "+DTOC(NNS->NNS_DATA),'Atenção!',"Entre no sistema com data maior ou igual a "+DTOC(NNS->NNS_DATA),,,,.T.)  //HELP PARA O MVC
			       _lRet := .F.
             ENDIF
             NNT->(dbSetOrder(1))
             NNT->(dBSeek(NNS->NNS_FILIAL+NNS->NNS_COD))
             DO While _lRet  .AND. !( NNT->( EOF() ) ) .And. NNT->NNT_FILIAL+NNT->NNT_COD == NNS->NNS_FILIAL+NNS->NNS_COD
                If !(NNT->NNT_LOCLD $ _cArmAcesso) 
                   U_ITmsg("Usuário não tem permissão para efetivar o Armazém: "+NNT->NNT_LOCLD,'Atenção!',"Usuário só pode efetivar os armazéns: "+_cArmAcesso,,,,.T.)  //HELP PARA O MVC
	         	     _lRet := .F.
                   EXIT   
                ENDIF
                NNT->( DBSKIP() )
             ENDDO
             ZZL->(dbSetOrder(1))
         ELSEIF _lRet  .AND. ( _nOper == MODEL_OPERATION_UPDATE .OR. _nOper == MODEL_OPERATION_DELETE)
              If _cUsrID <> ALLTRIM(NNS->NNS_SOLICT)
                  U_ITmsg("Somente o solicitante pode "+IF(_nOper == MODEL_OPERATION_DELETE,"excluir","alterar")+" sua solicitação",'Atenção!',,,,,.T.)  //HELP PARA O MVC
			         _lRet := .F.
              Endif    
         ENDIF
			
        ElseIf cIdPonto == "MODELPOS" .AND. !IsInCallStack('A311Efetiv') //"CHAMADA NA VALIDAÇÃO total do modelo."

          _oModelDET:= oObj:GetModel('NNTDETAIL')
		    _lpassou  := .F.
		    _nlin 	  := _oModelDET:Length(.F.)
          lUsaRastr := ALLTRIM(SuperGetMv( "MV_RASTRO"  , .F. , ""  )) = "S"
         SB1->( DBSetOrder(1) )
         SBZ->( DBSetOrder(1) )
         //Valida LINHAS
		   For _nni := 1 to _nlin
            _oModelDET:Goline(_nni)
		   	//Se a linha está deletada não faz validações
		   	If _oModelDET:IsDeleted(_nni)//oObj:IsDeleted(_nni) 
		   		Loop
		   	Endif
        		SBZ->(DBSeek( xFilial("SBZ") + _oModelDET:GetValue( 'NNT_PROD' )))
            IF SBZ->BZ_LOCALIZ = "S" .AND. EMPTY(_oModelDET:GetValue( 'NNT_LOCALI' ))//ENDEREÇO 
               U_ITmsg("Preencha o campo Endereço, linha: "+cValToChar(_nni),'Atenção!',,,,,.T.)  //HELP PARA O MVC
		   		Return .F.
            ENDIF
            SB1->(DBSeek( xFilial("SB1") + _oModelDET:GetValue( 'NNT_PROD' )))
            IF lUsaRastr .AND. SB1->B1_RASTRO $ "L/S" .AND. EMPTY(_oModelDET:GetValue( 'NNT_LOTECT' )) //LOTE
               U_ITmsg("Preencha o campo Lote, linha: "+cValToChar(_nni),,'Atenção!',,,,,.T.)  //HELP PARA O MVC
		   		Return .F.
            ENDIF
            If !(_oModelDET:GetValue( 'NNT_LOCAL' ) $ _cArmAcesso) //!(_oModelDET:GetValue( 'NNT_LOCLD' ) $ _cArmAcesso) .AND. 
                U_ITmsg("Usuário não tem permissão para usar o Armazém: "+_oModelDET:GetValue( 'NNT_LOCAL' ) ,'Atenção!',"Usuário só pode usar os armazéns: "+_cArmAcesso,,,,.T.)  //HELP PARA O MVC
        	      _lRet := .F.
            ENDIF

		   Next
        ElseIf cIdPonto == "FORMPOS" //"Chamada na validação total do formulário."
        ElseIf cIdPonto == "FORMLINEPRE" //"Chamada na pré validação da linha do formulário. " 
        
        ElseIf cIdPonto == "FORMLINEPOS" .And. ( _nOper == MODEL_OPERATION_INSERT .Or. _nOper == MODEL_OPERATION_UPDATE ) //"Chamada na validação da linha do formulário."
				
            SBZ->( DBSetOrder(1) )
        		SBZ->(DBSeek( xFilial("SBZ") + oObj:GetValue( 'NNT_PROD' )))
            IF SBZ->BZ_LOCALIZ = "S" .AND. EMPTY(oObj:GetValue( 'NNT_LOCALI' ))//ENDEREÇO 
               U_ITmsg("Preencha o campo Endereço",'Atenção!',,,,,.T.)  //HELP PARA O MVC
              _lRet:=.F.
            ENDIF
            lUsaRastr := ALLTRIM(SuperGetMv( "MV_RASTRO"  , .F. , ""  )) = "S"
            SB1->( DBSetOrder(1) )
            SB1->(DBSeek( xFilial("SB1") + oObj:GetValue( 'NNT_PROD' )))
            IF lUsaRastr .AND. SB1->B1_RASTRO = "L" .AND. EMPTY(oObj:GetValue( 'NNT_LOTECT' ))//LOTE
               U_ITmsg("Preencha o campo Lote",'Atenção!',,,,,.T.)  //HELP PARA O MVC
              _lRet:=.F.
            ENDIF
            If  !(oObj:GetValue( 'NNT_LOCAL' ) $ _cArmAcesso) //!(oObj:GetValue( 'NNT_LOCLD' ) $ _cArmAcesso) .AND.
                U_ITmsg("Usuário não tem permissão para usar os Armazéns: "+oObj:GetValue( 'NNT_LOCAL' ) ,'Atenção!',"Usuário só pode usar os armazéns: "+_cArmAcesso,,,,.T.)  //HELP PARA O MVC
        	      _lRet := .F.
            ENDIF

        ElseIf cIdPonto == "MODELCOMMITTTS" //"Chamada após a gravação total do modelo e dentro da transação."
        
        ElseIf cIdPonto == "MODELCOMMITNTTS" .And. (_nOper == MODEL_OPERATION_INSERT .Or. _nOper == MODEL_OPERATION_UPDATE ) //"Chamada apos a gravacao total do modelo e fora da transacao."
        
               MA311Email()//INCLUIR / ALTERAR / COPIAR
        
        ElseIf cIdPonto == "FORMCOMMITTTSPRE" //"Chamada antes a gravação da tabela do formulário."
        ElseIf cIdPonto == "FORMCOMMITTTSPOS" //"Chamada após a gravação da tabela do formulário."
        ElseIf cIdPonto == "MODELCANCEL"
        ElseIf cIdPonto == "BUTTONBAR"

        EndIf
    EndIf

Return _lRet

/*
===============================================================================================================================
Programa----------: MA311Email()
Autor-------------: Alex Wallauer
Data da Criacao---: 04/03/2022
===============================================================================================================================
Descrição---------: Monta e envia email 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MA311Email()
Local _aConfig	:= U_ITCFGEML('')
Local _cEmlLog	:= ""
Local _cMsgEml	:= ""
Local _nI , _aSizes:={}
Local cGetCc	:= ""
Local cGetPara	:= ""
Local _cNomeFil := cFilant+" - "+AllTrim( Posicione('SM0',1,"01"+cFilant,'M0_FILIAL') )
Local cTit      := "SOLICITACAO DE TRANSFERENCIA ENTRE ARMAZENS"
Local cGetAssun := "SOLICITACAO DE TRANSFERENCIA ENTRE ARMAZENS No.: "+NNS->NNS_COD
Local _aTLinhas :={}
Local _aCab     :={}
LOCAL _aSize    :={}
LOCAL _cAliasZZL:= GetNextAlias()

//Monta os titulos das colunas
AADD(_aCab,"Produto")//01
AADD(_aSize,"08")
AADD(_aCab,"Descrição")//02
AADD(_aSize,"30")
AADD(_aCab,"Arm.Ori.")//03
AADD(_aSize,"08")
AADD(_aCab,"Arm.Des.")//04
AADD(_aSize,"08")
AADD(_aCab,"Qtde")//05
AADD(_aSize,"08")
AADD(_aCab,"Lote")//06
AADD(_aSize,"08")
AADD(_aCab,"Observações")//07
AADD(_aSize,"30")

_cQuery := " SELECT ZZL.R_E_C_N_O_ AS REG_ZZL "
_cQuery += " FROM  "+ RetSQLName("ZZL") +" ZZL "
_cQuery += " WHERE "+ RetSqlCond('ZZL')
_cQuery += " AND ZZL.ZZL_ARMEFE <>  ' ' AND ZZL_EMAIL <> ' ' "
//_cQuery += " AND SUBSTR(ZZL.ZZL_ARMEFE,1,2) = '"+NNS->NNS_FILIAL+"' "//PRIMIERA 2 POSICOES DO CAMPO ZZL_ARMEFE É A FILIAL

cTam:=ALLTRIM(STR(LEN(ZZL->ZZL_ARMEFE)-2))
NNT->(dbSetOrder(1))
NNT->(dBSeek(NNS->NNS_FILIAL+NNS->NNS_COD))
DO While !( NNT->( EOF() ) ) .And. NNT->NNT_FILIAL+NNT->NNT_COD == NNS->NNS_FILIAL+NNS->NNS_COD

// IF AScan(_aTLinhas, {|T|  T[4] == NNT->NNT_LOCLD }) = 0
//    _cQuery += " AND SUBSTR(ZZL.ZZL_ARMEFE,3,"+cTam+") LIKE '%"+ALLTRIM(NNT->NNT_LOCLD)+"%' "   
//  ENDIF
   
   AADD(_aTLinhas,{NNT->NNT_PROD,;
                   ALLTRIM(POSICIONE("SB1",1,xfilial("SB1")+NNT->NNT_PROD,"B1_DESC")),;
                   NNT->NNT_LOCAL,;
                   NNT->NNT_LOCLD,;
                   TRANS(NNT->NNT_QUANT,"@E 999,999,999.99"),;
                   NNT->NNT_LOTECT,;
                   ALLTRIM(NNT->NNT_OBS)})
   NNT->( DBSKIP() )
 
ENDDO

DBUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQuery ) , _cAliasZZL , .T. , .F. )

_aEmail:={}
(_cAliasZZL)->( DBGoTop() )
DO While (_cAliasZZL)->(!Eof())
	ZZL->(DBGOTO((_cAliasZZL)->REG_ZZL))
   IF (_nPos:=AT("/",ZZL->ZZL_ARMEFE)) > 0 
	   _cFilEAcesso:=LEFT(ZZL->ZZL_ARMEFE, _nPos )
      _cArmEAcesso:=ALLTRIM(SUBSTR(ZZL->ZZL_ARMEFE, _nPos+1 ))
   ELSE   
      _cFilEAcesso:=cFilAnt
      _cArmEAcesso:=ALLTRIM(ZZL->ZZL_ARMEFE)
   ENDIF
   IF !cFilant $ _cFilEAcesso
      (_cAliasZZL)->(DBSKIP())
      LOOP
   ENDIF
   _lLoop:=.T.
   For _nI := 1 To LEN(_aTLinhas)
       IF _aTLinhas[_nI][04] $ _cArmEAcesso//BASTA UMA LINHA ESTA CONTIDA
          _lLoop:=.F.
          EXIT 
       ENDIF
   NEXT
   IF _lLoop
      (_cAliasZZL)->(DBSKIP())
      LOOP
   ENDIF

	AADD(_aEmail, {ALLTRIM(ZZL->ZZL_EMAIL),ALLTRIM(ZZL->ZZL_NOME),_cArmAcesso} )
	(_cAliasZZL)->(DBSKIP())
ENDDO

(_cAliasZZL)->(DBCLOSEAREA())

If !SuperGetMV("IT_AMBTEST",.F.,.T.)
   _aEmail:={}
	AADD(_aEmail, {LOWER(Alltrim(UsrRetMail(__cUserID))),cUserName,_cArmAcesso} )
Endif

_cMsgEml := '<html>'
_cMsgEml += '<head><title>'+cTit+'</title></head>'
_cMsgEml += '<body>'
_cMsgEml += '<style type="text/css"><!--'
_cMsgEml += 'table.bordasimples { border-collapse: collapse; }'
_cMsgEml += 'table.bordasimples tr td { border:1px solid #777777; }'
_cMsgEml += 'td.titulos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #C6E2FF; }'
_cMsgEml += 'td.grupos	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #E5E5E5; }'
_cMsgEml += 'td.itens	{ font-family:VERDANA; font-size:12px; V-align:middle; margin-right: 15px; margin-left: 15px; background-color: #FFFFFF; }'
_cMsgEml += '--></style>'
_cMsgEml += '<center>'
_cMsgEml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="600" height="50"><br>'
_cMsgEml += '<table class="bordasimples" width="600">'
_cMsgEml += '    <tr>'
_cMsgEml += '	     <td class="titulos"><center>'+cTit+'</center></td>'
_cMsgEml += '	 </tr>'
_cMsgEml += '</table>'
_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="600">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="2" class="grupos">Dados da solicitação</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Solicitado por: </b></td>'
_cMsgEml += '      <td class="itens" >'+ UsrFullName(__cUserID) +'</td>' 
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Filial:</b></td>'
_cMsgEml += '      <td class="itens" >'+ _cNomeFil +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Numero:</b></td>'
_cMsgEml += '      <td class="itens" >'+ NNS->NNS_COD +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
/*
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Observações:</b></td>'
_cMsgEml += '      <td class="itens" >'+cErMens+'</td>'
*/
_cMsgEml += '    </tr>'
_cMsgEml += '</table>'

_aSizeOK:=_aSize

_cMsgEml += '<br>'
_cMsgEml += '<table class="bordasimples" width="1300">'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td align="center" colspan="'+ALLTRIM(STR(LEN(_aSizeOK)))+'" class="grupos"><b>Produtos aguardando efetivação</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="left"   width="'+_aSizeOK[01]+'%"><b>'+_aCab[01]+'</b></td>'
_cMsgEml += '      <td class="itens" align="left"   width="'+_aSizeOK[02]+'%"><b>'+_aCab[02]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizeOK[03]+'%"><b>'+_aCab[03]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizeOK[04]+'%"><b>'+_aCab[04]+'</b></td>'
_cMsgEml += '      <td class="itens" align="right"  width="'+_aSizeOK[05]+'%"><b>'+_aCab[05]+'</b></td>'
_cMsgEml += '      <td class="itens" align="center" width="'+_aSizeOK[06]+'%"><b>'+_aCab[06]+'</b></td>'
_cMsgEml += '      <td class="itens" align="left"   width="'+_aSizeOK[07]+'%"><b>'+_aCab[07]+'</b></td>'
_cMsgEml += '    </tr>'

_cGetLista:=""
_lEnvia:=.F.
_aSizes:=_aSize

For _nI := 1 To LEN(_aTLinhas)
	
 /* IF oProc <> NIL
	   oProc:cCaption := ("Enviando Log: "+ALLTRIM(STRZERO(_nI,_nTam))+" de "+ _cTot)
	   ProcessMessages()
	ENDIF   */
	
		_cMsgEml += '    <tr>'
		_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[01]+'%">'+ _aTLinhas[_nI][01]+'</td>'
		_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[02]+'%">'+ _aTLinhas[_nI][02]+'</td>'
		_cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[03]+'%">'+ _aTLinhas[_nI][03]+'</td>'
		_cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[04]+'%">'+ _aTLinhas[_nI][04]+'</td>'
		_cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[05]+'%">'+ _aTLinhas[_nI][05]+'</td>'
		_cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[06]+'%">'+ _aTLinhas[_nI][06]+'</td>'
		_cMsgEml += '      <td class="itens" align="left"   width="'+_aSizes[07]+'%">'+ _aTLinhas[_nI][07]+'</td>'
		_cMsgEml += '    </tr>'
	    _lEnvia:=.T.

Next

_cMsgEml += '</table>'
_cMsgEml += '<br>'
_cMsgEml += '</center>'
_cMsgEml += '<br>'
_cMsgEml += '<br>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
_cMsgEml += '      <td class="itens" align="left" > ['+ GETENVSERVER() +'] / <b>Fonte:</b> [MATA311PE]</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '</body>'
_cMsgEml += '</html>'


IF _lEnvia

   FOR _nI := 1 TO LEN(_aEmail)
       cGetPara:=_aEmail[_nI,1]
      // Chama a função para envio do e-mail
      U_ITENVMAIL( _aConfig[01], cGetPara, cGetCc, "", cGetAssun, _cMsgEml, "", _aConfig[01], _aConfig[02], _aConfig[03], _aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )
   		
      If SuperGetMV("IT_AMBTEST",.F.,.T.)
         U_ITMSG(UPPER(_cEmlLog)+CHR(13)+CHR(10)+;
   		           "E-mail para: "+cGetPara+;
   		           " Com Copia: "+cGetCc+CHR(13)+CHR(10),"Envio do E-MAIL",,3)
      ENDIF
   NEXT

ELSE   
   If SuperGetMV("IT_AMBTEST",.F.,.T.)
      U_ITMSG("Não tem registros para enviar","Envio do E-MAIL",,1)
   ENDIF   
ENDIF

Return .T.


/*
===============================================================================================================================
Programa----------: MA311VLD()
Autor-------------: Julio de Paula Paz
Data da Criacao---: 22/05/2024
===============================================================================================================================
Descrição---------: Validações de Campos Customizados da Tabela NNT.
===============================================================================================================================
Parametros--------: _cCampo =  Campo que chamou a validação.
===============================================================================================================================
Retorno-----------: _lRet = .T. = Válido
                            .F. = Não Válido
===============================================================================================================================
*/
User Function MA311VLD(_cCampo)
Local _lRet := .T.
Local _oModel, _oModelGrid

Begin Sequence 
   _oModel := FwModelActivete()
   _oModelGrid := _oModel:GetModel('NNTDETAIL')

   If _cCampo == "NNT_I_TPTR"
      _cMotTrans := _oModelGrid:GetValue("NNT_I_TPTR") 
      _cDescMoti := ""

      If ! Empty(_cMotTrans)
         _cDescMoti := POSICIONE("CYO",1,xFilial("CYO")+_cMotTrans,"CYO_DSRF")
      EndIf 

      _oModelGrid:LoadValue( 'NNT_I_DSCT', _cDescMoti)

   EndIf 

End Sequence 

Return _lRet



