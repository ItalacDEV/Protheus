/*
===============================================================================================================================
                          ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
    Autor     |    Data    |                                             Motivo                                          
===============================================================================================================================
Alex Wallauer | 11/04/2017 | Chamado 19481. Apagar o NCM dos produtos do GRUPO 1000, para todos os itens que forem TIPO SV.
Andre Lisboa  | 12/05/2017 | Chamado 20029. Envio de workflow também para os produtos diferentes de PA.
Julio Paz     | 12/01/2017 | Chamado 23121. Alteração de validação para permitir a gravação de Produto sem informar a NCM. 
Josué Danich  | 16/11/2018 | Chamado 26971. Ajuste de mensagens e obrigatoriedade de motivo de bloqueio.
Alex Wallauer | 28/12/2018 | Chamado 27498. Bloqueio p/ quando estiver descrições iguais entre Desc. produto e Detalhada.
Alex Wallauer | 30/04/2019 | Chamado 28740. Descrições não pode ser alteradas quando o produto possui niveis preenchidos.
Alex Wallauer | 26/09/2019 | Chamado 30673. Ajustes em validaçoes para o novo nivel 5 dos produtos.
Alex Wallauer | 04/11/2019 | Chamado 30984. Nova validação com Workflow de alteração de UM.
Alex Wallauer | 29/12/2019 | Chamado 31466. Nova controle da inclusão em fases do produto - habilitdo 12/01/22.
Alex Wallauer | 13/05/2021 | Chamado 36529. Correcao da validacao da descricao do produto.
Igor Melgaço  | 15/06/2021 | Chamado 36815. Substituição da função PswRet.
Igor Melgaço  | 02/08/2021 | Chamado 37310. Troca de chamada mata240 por mata241.		
Igor Melgaço  | 01/06/2022 | Chamado 40048. Ajustes para validação de caracteres inválidos. 
Igor Melgaço  | 11/08/2022 | Chamado 40048. Ajuste para substituição de caracteres inválidos. 
Alex Wallauer | 30/03/2021 | Chamado 43436. Gravacao dos campos B1_I_USRNA e B1_I_USRDA.
Julio Paz     | 29/08/2024 | Chamado 48278. Ajutar a rotina para retornar mensagem de erro específica e não o erro do Execauto.
Lucas Borges  | 22/07/2025 | Chamado 51340. Ajustar função para validação de ambiente de teste
==============================================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
Andre    - Alex Wallauer - 14/10/24 - 25/10/24 -  48836  - Nova validação não permitir informar aliquota de ICMS e IPI para produtos do B1_TIPO = "SV".
Andre    - Alex Wallauer - 25/05/24 - 24/05/25 -  50795  - Correção da palavra "ateradas" para "alteradas" nas mensagens de alerta.
==============================================================================================================================================================
*/

//*****************************************************************************************************
//******************* USE ESSE PONTO PARA VALIDAÇÕES E O AEST045.PRW PARA GRAVAÇÕES *******************
//*****************************************************************************************************

#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TBICONN.CH"  

/*
===============================================================================================================================
Programa----------: A010TOK
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 20/04/2010
Descrição---------: Ponto de Entrada que valida a inclusao e alteracao de produtos (Fonte: MATA010.PRX) 
                    Chamada do antigo A010TudoOk() do Fonte: MATA010.PRX
                    USE ESSE PONTO PARA VALIDAÇÕES E O AEST045.PRW PARA GRAVAÇÕES
Parametros--------: Nenhum
Retorno-----------: .T. = Permite confirmar lancamento
------------------: .F. = Nao Permite confirmar lancamento 
===============================================================================================================================
*/
User Function A010TOK()

Local _lExecuta   := .T.
Local _nCont
Local _oModel     := FWModelActive()
Local _oModelSB1  := _oModel:GetModel('SB1MASTER')
Local _cB1_DESC   := ""
Local _cB1_I_DESCD:= ""
Local _lFasesB1   := U_ItGetMv("IT_FASESB1",.F.)
Local _cIT_PRDSVOK:= SUPERGETMV("IT_PRDSVOK",.F.,"")

//===================================================================================================
// Valida digitação de caracteres invalidos
//===================================================================================================
If Inclui .Or. Altera
	_cB1_DESC := _oModelSB1:GetValue('B1_DESC') 
	If !Empty(Alltrim(_cB1_DESC))
		_lExecuta := U_CRMA980VCP(@_cB1_DESC   ,"B1_DESC")
		_oModelSB1:LoadValue('B1_DESC',_cB1_DESC)  
	EndIf
	
	_cB1_I_DESCD := _oModelSB1:GetValue('B1_I_DESCD') 
	If _lExecuta .And. !Empty(Alltrim(_cB1_I_DESCD))
		_lExecuta := U_CRMA980VCP(@_cB1_I_DESCD   ,"B1_I_DESCD")
		_oModelSB1:LoadValue('B1_I_DESCD',_cB1_I_DESCD)  
	EndIf
EndIf

//===================================================================================================
// Valida digitação da segunda unidade de medida do produto se não for grupo de exceção de medida
//===================================================================================================
If (! Empty(M->B1_SEGUM) .And. Empty(M->B1_CONV) .and. !(M->B1_GRUPO $ u_ITGetMV( "ITGR2N" , "0006" ) )) .OR.;
	( Empty(M->B1_SEGUM) .And. ! Empty(M->B1_CONV) .and. !(M->B1_GRUPO $ u_ITGetMV( "ITGR2N" , "0006" ) ))

   u_itmsg(  "Fator de conversão não preenchido para a segunda unidade de medida.","Atenção",;
				"Favor preencher o fator de conversão. Ao informar a segunda unidade de medida, o fator de conversão precisa ser preenchido.",1,,,.T.)

   _lExecuta := .F.

EndIf

//===================================================================================================
// Valida digitação da segunda unidade de medida do produto se não for grupo de exceção de medida
//===================================================================================================
If !Inclui .AND. _lExecuta
	
	IF  EMPTY(SB1->B1_I_NIV5) .AND.  EMPTY(M->B1_I_NIV5)//NÃO MEXEU E NÃO TEM N5
		
		If ALLTRIM(M->B1_I_DESN2)+" "+ALLTRIM(M->B1_I_DESN3)+" "+ALLTRIM(M->B1_I_DESN4)== ALLTRIM(M->B1_DESC) .OR.;
			(M->B1_MSBLQL = '1' .AND. "BLOQUEADO" $ M->B1_DESC)
			_lExecuta := .T.
		Elseif !Empty(M->B1_I_NIV2+M->B1_I_NIV3+M->B1_I_NIV4)  .AND.;
			(!ALLTRIM(SB1->B1_DESC) == ALLTRIM(M->B1_DESC) .OR. !ALLTRIM(SB1->B1_I_DESCD) == ALLTRIM(M->B1_I_DESCD) )
			
			U_ITMSG("Descrições não pode ser alteradas quando o produto possui niveis preenchidos ate o nivel 4.","Atenção",;
			        "Favor contactar o depto de custos, resposavel pelo cadastro de niveis.",1,,,.T.)
			_lExecuta := .F.
		ENDIF
		
	ELSEIF  EMPTY(SB1->B1_I_NIV5) .AND. !EMPTY(M->B1_I_NIV5)//COLOCOU  N5

        cCerto:=ALLTRIM(M->B1_I_DESN2)+" "+ALLTRIM(M->B1_I_DESN3)+" "+ALLTRIM(M->B1_I_DESN4)+" "+ALLTRIM(M->B1_I_DESN5)
		
		If (cCerto == ALLTRIM(M->B1_DESC) .AND. cCerto == ALLTRIM(M->B1_I_DESCD)).OR.;
			(M->B1_MSBLQL = '1' .AND. "BLOQUEADO" $ M->B1_DESC)
			_lExecuta := .T.
	   
			Elseif !Empty(M->B1_I_NIV2+M->B1_I_NIV3+M->B1_I_NIV4+M->B1_I_NIV5) // .AND.;
			//(!ALLTRIM(SB1->B1_DESC) == ALLTRIM(M->B1_DESC) .OR. !ALLTRIM(SB1->B1_I_DESCD) == ALLTRIM(M->B1_I_DESCD) )
			
			U_ITMSG("Descrições deve coincidir com a soma das descriçoes de todos os niveis.","Atenção",;
			        "Soma das descrições dos niveis: "+cCerto,1,,,.T.)
			_lExecuta := .F.
		ENDIF
   
	ELSEIF !EMPTY(SB1->B1_I_NIV5) .AND.  EMPTY(M->B1_I_NIV5)//TIROU  N5

        cCerto:=ALLTRIM(M->B1_I_DESN2)+" "+ALLTRIM(M->B1_I_DESN3)+" "+ALLTRIM(M->B1_I_DESN4)+" "+ALLTRIM(M->B1_I_DESN5)
        cCerto:=ALLTRIM(cCerto)
		If (cCerto == ALLTRIM(M->B1_DESC) .AND. cCerto == ALLTRIM(M->B1_I_DESCD)).OR.;
			(M->B1_MSBLQL = '1' .AND. "BLOQUEADO" $ M->B1_DESC)
			_lExecuta := .T.
		Elseif !Empty(M->B1_I_NIV2+M->B1_I_NIV3+M->B1_I_NIV4+M->B1_I_NIV5) // .AND.;
			//(!ALLTRIM(SB1->B1_DESC) == ALLTRIM(M->B1_DESC) .OR. !ALLTRIM(SB1->B1_I_DESCD) == ALLTRIM(M->B1_I_DESCD) )
			
			U_ITMSG("Descrições deve coincidir com a soma das descriçoes de todos os niveis.","Atenção",;
			        "Soma das descrições dos niveis: "+cCerto,1,,,.T.)
			_lExecuta := .F.
		ENDIF
	
	ELSEIF !EMPTY(SB1->B1_I_NIV5) .AND. !EMPTY(M->B1_I_NIV5) .AND.  M->B1_I_NIV5 = SB1->B1_I_NIV5//NÃO MEXEU E TEM OU NÃO TROCOU N5

        cCerto:=ALLTRIM(M->B1_I_DESN2)+" "+ALLTRIM(M->B1_I_DESN3)+" "+ALLTRIM(M->B1_I_DESN4)+" "+ALLTRIM(M->B1_I_DESN5)

		If (cCerto == ALLTRIM(M->B1_DESC) .AND. cCerto == ALLTRIM(M->B1_I_DESCD)).OR.;
			(M->B1_MSBLQL = '1' .AND. "BLOQUEADO" $ M->B1_DESC)
			_lExecuta := .T.
		Elseif !Empty(M->B1_I_NIV2+M->B1_I_NIV3+M->B1_I_NIV4+M->B1_I_NIV5)  .AND.;
			(!ALLTRIM(SB1->B1_DESC) == ALLTRIM(M->B1_DESC) .OR. !ALLTRIM(SB1->B1_I_DESCD) == ALLTRIM(M->B1_I_DESCD) )
			
			U_ITMSG("Descrições não pode ser alteradas quando o produto possui niveis preenchidos ate o nivel 4.","Atenção",;
			        "Favor contactar o depto de custos, resposavel pelo cadastro de niveis.",1,,,.T.)
			_lExecuta := .F.
		ENDIF

	ELSEIF !EMPTY(SB1->B1_I_NIV5) .AND. !EMPTY(M->B1_I_NIV5) .AND.  M->B1_I_NIV5 <> SB1->B1_I_NIV5//NÃO MEXEU E TEM OU TROCOU 

        cCerto:=ALLTRIM(M->B1_I_DESN2)+" "+ALLTRIM(M->B1_I_DESN3)+" "+ALLTRIM(M->B1_I_DESN4)+" "+ALLTRIM(M->B1_I_DESN5)

		If (cCerto == ALLTRIM(M->B1_DESC) .AND. cCerto == ALLTRIM(M->B1_I_DESCD)) .OR.;
			(M->B1_MSBLQL = '1' .AND. "BLOQUEADO" $ M->B1_DESC)
			_lExecuta := .T.
		Elseif !Empty(M->B1_I_NIV2+M->B1_I_NIV3+M->B1_I_NIV4+M->B1_I_NIV5) // .AND.;
 //			(!ALLTRIM(SB1->B1_DESC) == ALLTRIM(M->B1_DESC) .OR. !ALLTRIM(SB1->B1_I_DESCD) == ALLTRIM(M->B1_I_DESCD) )
			
			U_ITMSG("Descrições deve coincidir com a soma das descriçoes de todos os niveis.","Atenção",;
			        "Soma das descrições dos niveis: "+cCerto,1,,,.T.)
			_lExecuta := .F.
		ENDIF

		
	EndIf

ELSEIf Inclui .AND._lExecuta

	IF !EMPTY(M->B1_I_NIV2+M->B1_I_NIV3+M->B1_I_NIV4)  .AND. ;
	   (EMPTY(M->B1_I_NIV2) .OR. EMPTY(M->B1_I_NIV3) .OR. EMPTY(M->B1_I_NIV4))
			U_ITMSG("Todos os Niveis 2 , 3 e 4 devem ser preenchidos quando for PA ou embalagem de PA.","Atenção",;
			        "Preencha os niveis ou troque o tipo do produto.",1,,,.T.)
		_lExecuta := .F.
	ENDIF

EndIf


//================================================================================
// VALIDA PRODUTO ACABADO. 
//================================================================================
If M->B1_TIPO == 'PA'
 	
	If Empty(M->B1_I_SUBGR)
	   u_itmsg("Quando o tipo do Produto for igual a PA deve-se fornecer o Sub Grupo do Produto","Atenção",;
	   			"Favor preencher o campo Sub Grupo do Produto para confirmar o cadastro/alteração do Produto",1,,,.T.)
	   _lExecuta := .F.
	EndIf     
   
   //================================================================================
   // Validação para Código EAN. 
   //================================================================================

	If Empty(M->B1_CODBAR)
       u_itmsg("Quando o tipo do Produto for igual a PA deve-se informar o Código de Barras - EAN","Atenção",;
       			"Favor preencher o campo Cod Barras para confirmar o cadastro/alteração do Produto",1,,,.T.)
       _lExecuta := .F.
	EndIf

   //================================================================================
   // Validação para Código EAN. 
   //================================================================================
	If Empty(M->B1_CODBAR)
       u_itmsg("Quando o tipo do Produto for igual a PA deve-se informar o Código de Barras - EAN","Atenção",;
       			"Favor preencher o campo Cod Barras para confirmar o cadastro/alteração do Produto",1,,,.T.)
       _lExecuta := .F.
	EndIf

//================================================================================
// VALIDA PRODUTO DE SERVIÇO. 
//================================================================================
ELSEIf M->B1_TIPO == 'SV' .AND. !ALLTRIM(M->B1_COD) $ _cIT_PRDSVOK

	IF !EMPTY(M->B1_PICM)           
	   U_ITMSG("Aliquota de ICMS não pode ser preenchida para um produto de tipo = 'SV'","Atenção",;
			   "Zere Aliquota de ICMS desse produto ou troque o tipo para diferente de 'SV'",1,,,.T.)
	   _lExecuta := .F.
	ENDIF     
	IF !EMPTY(M->B1_IPI)           
	   U_ITMSG("Aliquota de IPI não pode ser preenchida para um produto de tipo = 'SV'","Atenção",;
			   "Zere Aliquota de IPI desse produto ou troque o tipo para diferente de 'SV'",1,,,.T.)
	   _lExecuta := .F.
	ENDIF     

ENDIF
  
//================================================================================
//  Inicio da validação realizada no campo B1_DESC afim de não permitir o uso de 
//  espaçamento feitos apartir da tecla tab e a tecla enter.
//================================================================================  
 	_nCont:= StrTran(M->B1_DESC	,'	',"") 
    
    If _nCont <> M->B1_DESC .Or. LTrim(StrTran(M->B1_DESC	,'	',"")) <> M->B1_DESC
   		u_itmsg("Erro no preenchimento do campo Descrição","Atenção","Favor retirar os espaços em branco para prosseguir com o cadastro",1,,,.T.) 
   		_lExecuta := .F. 
    EndIf    

    If Inclui .AND. _lExecuta
       SB1->(DBSETORDER(3))
       SB1->(DBSEEK( xFilial()+ALLTRIM(M->B1_DESC) ))
       DO WHILE SB1->(!EOF()) .AND. ALLTRIM(M->B1_DESC) == ALLTRIM(SB1->B1_DESC)
   	      
          IF ALLTRIM(M->B1_I_DESCD) == ALLTRIM(SB1->B1_I_DESCD)
   	         U_ITMSG("Produto já cadastrado","Atenção","Descrição já existente no Produto: "+SB1->B1_COD,1,,,.T.) 
   	         _lExecuta := .F. 
   	         EXIT
   	      ENDIF   
   	      SB1->(DBSKIP())
   	   ENDDO   
       SB1->(DBSETORDER(1))
    EndIf    

//=============================================================================================================================
// Apagar o NCM dos produtos do GRUPO 1000, para todos os itens que forem TIPO SV - Chamado 19481
//=============================================================================================================================
ZZL->(DBSEEK(xFilial("ZZL") + __cUserId))
If _lFasesB1
	_lValida:=!ZZL->ZZL_CADPRD = "1" // Alex: Não retirar esse comentario CHAMADO 31466 Habilitdo por enquanto  .T.//desabilitdo
Else
	_lValida:=.T.
EndIf
If (M->B1_GRUPO $ U_ITGetMV( "IT_GRUNCM" , "1000" ) .AND. M->B1_TIPO $ U_ITGetMV( "IT_TIPNCM" , 'SV' )) .Or. M->B1_TIPO $ U_ITGetMV( "IT_TIPOPRDS" , 'IM')

   IF _lExecuta .AND. !EMPTY(M->B1_POSIPI) .AND. _lValida
      If (M->B1_GRUPO $ U_ITGetMV( "IT_GRUNCM" , "1000" ) .AND. M->B1_TIPO $ U_ITGetMV( "IT_TIPNCM" , 'SV' )) 
         u_itmsg( "O produto pertence ao(s) grupo(s) "+ALLTRIM(U_ITGetMV("IT_GRUNCM","1000"))+" e ao(s) tipo(s) "+ALLTRIM(U_ITGetMV("IT_TIPNCM",'SV'))+". ","Atenção",;
		       "Portanto o conteúdo do campo NCM será removido.", 1,,,.T.)
      Else  // M->B1_TIPO $ U_ITGetMV( "IT_TIPOPRDS" , 'IM')
         u_itmsg("O produto pertence ao(s) tipo(s) "+ALLTRIM(U_ITGetMV("IT_TIPOPRDS",'IM'))+". ", "Atenção",;
		       "Portanto o conteúdo do campo NCM será removido.", 1,,,.T.)
      EndIf   
      //M->B1_POSIPI:=SPACE(LEN(SB1->B1_POSIPI))     
                               
      _oModelSB1:LoadValue('B1_POSIPI', "          ")

   ENDIF
   
ELSEIF EMPTY(M->B1_POSIPI) .AND. _lValida

   u_itmsg("O campo da NCM não esta preenchido.","Atenção","Favor preencher o campo da NCM na pasta Impostos (segunda pasta)",1,,,.T.) 
   _lExecuta := .F. 

EndIf
//================================================================================
// Valida preenchimento Motivo do bloqueio 
//================================================================================
If M->B1_MSBLQL == '1' .And. EMPTY(M->B1_I_MOTBL)
	_lExecuta := .F.
	U_ITMSG('Campo Motivo Bloqueio vazio!',"ATENÇÃO",;
			'Para produtos bloqueados favor preencher o motivo do bloqueio.',3,,,.T.)
ELSEIF M->B1_MSBLQL <> '1'
   M->B1_I_MOTBL:=SPACE(LEN(SB1->B1_I_MOTBL))
   _oModelSB1:LoadValue('B1_I_MOTBL',SPACE(LEN(SB1->B1_I_MOTBL)))
Endif	

//================================================================================
// Se for inclusão de PA, envia Workflow para sistema@italac.com.br
//================================================================================
// Alex: Não retirar esse comentario CHAMADO 31466 desabilitdo por enquanto
If _lFasesB1
	IF _lExecuta .AND. (Inclui .OR. "#CONTROLE" $ SB1->B1_I_MOTBL)
		_lExecuta:=A010WlInc(_oModelSB1)
	ENDIF
Endif
//================================================================================
// Se for inclusão de PA, envia Workflow para sistema@italac.com.br
//================================================================================
If _lExecuta .AND. !Inclui .AND. (SB1->B1_UM <> M->B1_UM .OR. SB1->B1_SEGUM <> M->B1_SEGUM .OR. SB1->B1_CONV <> M->B1_CONV .OR. SB1->B1_TIPCONV <> M->B1_TIPCONV)
   IF !(ISINCALLSTACK("MDIEXECUTE") .OR. ISINCALLSTACK("SIGAADV"))
	  _lExecuta := A010CadSB1()
   ELSE
      FWMSGRUN( ,{|oProc| _lExecuta := A010CadSB1(oProc) } , "Processando..." , "Validando Armazem..." )
   ENDIF
Endif
//================================================================================
// Se for inclusão de PA, envia Workflow para sistema@italac.com.br
//================================================================================
If _lExecuta .and. Inclui//M->B1_TIPO == 'PA' .and. _lExecuta .and. Inclui
	WorkFlow()
Endif

If _lExecuta .and. !Inclui .AND. !FWIsInCallStack("MSEXECAUTO")
   M->B1_I_USRNA:=Capital(RTrim(UsrFullName(RetCodUsr())))
   M->B1_I_USRDA:=DTOC(DATE())
   _oModelSB1:LoadValue('B1_I_USRNA' ,M->B1_I_USRNA)
   _oModelSB1:LoadValue('B1_I_USRDA' ,M->B1_I_USRDA)
ENDIF

//*****************************************************************************************************
//******************* USE ESSE PONTO PARA VALIDAÇÕES E O AEST045.PRW PARA GRAVAÇÕES *******************
//*****************************************************************************************************


Return (_lExecuta)

/*
===============================================================================================================================
Programa----------: Workflow
Autor-------------: Lucas Crevilari
Data da Criacao---: 12/09/2014
===============================================================================================================================
Descrição---------: Envio de Workflow quando for realizado cadastro de PA. Chamado 7363
===============================================================================================================================
Parametros--------: Nenhum	
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/   

Static Function Workflow()

Local _cEmail := Space(0)
Local _cErrorMsg, _Remetente, _cHtml, _cSubject
Local _lResult, _cTitulo, _cTexto2, _cAlias



CONNECT SMTP ;
SERVER GetMV("MV_RELSERV") ; 	// Nome do servidor de e-mail
ACCOUNT GetMV("MV_RELACNT") ; 	// Nome da conta a ser usada no e-mail
PASSWORD GetMV("MV_RELPSW") ; 	// Senha
RESULT _lResult 					// Resultado da tentativa de conexão

If !_lResult
	//================================================================================
	// Nao foi possivel estabelecer conexao com o servidor 
	//================================================================================
	u_itmsg("Falha no envio do email","Atenção",MailGetErr(),1,,,.T.)
EndIF

IF _lResult 
    
	//================================================================================
	// Conectado ao Servidor, enviando o e-mail... 
	//================================================================================
	MailAuth(GetMV("MV_RELACNT"),GetMV("MV_RELPSW"))
	_Remetente := GetMV("MV_RELACNT")

	If M->B1_TIPO == "PA"
		_cSubject := "Novo Cadastro de Produto Acabado" 
	Else
		_cSubject := "Novo Cadastro de Produto"
	Endif	 		

	_cHtml := Space(0)
	_cHtml += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN""http://www.w3.org/TR/html4/loose.dtd">'
	_cHtml += '<html>'
	_cHtml += '<head>'
	_cHtml += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"><title>Untitled Document</title>'
	_cHtml += '<style type="text/css">'
	_cHtml += '<!--body,td,th { font-family: Arial, Helvetica, sans-serif; font-size: 12px;}.negrito { font-family: Arial, Helvetica, sans-serif; font-size: 12px; font-weight: bold; color: #003366;}.negrito2 { font-family: Arial, Helvetica, sans-serif; font-size: 15px; font-weight: bold; color: #003366;}.texto1 { font-family: Arial, Helvetica, sans-serif; font-size: 11px; color: #666666;}.texto2 { font-family: Arial, Helvetica, sans-serif; font-size: 9px; color: #666666;}-->'
	_cHtml += '</style>'
	_cHtml += '</head>'
	_cHtml += '<body>'                                                         
	_cHtml += '<p class=MsoNormal>'
//	_cHtml += '<img src="http://www.italac.com.br/wp-content/themes/italac/assets/images/logo.svg" >'//alt="" width="171" height="63"> 
    _cHtml += '<img src="http://www.italac.com.br/wf/italac-wf.jpg" width="600" height="50"><br>'

	If M->B1_TIPO == "PA"
		_cTitulo := "Novo Cadastro de Produto Acabado"
		_cTexto2 := "Novo Produto Acabado cadastrado no Protheus:"		
	Else	
		_cTitulo := "Novo Cadastro de Produto"
		_cTexto2 := "Novo Produto cadastrado no Protheus:"		
	Endif	
    IF SuperGetMV("IT_AMBTEST",.F.,.T.)
	   _cTitulo += " - TESTE"
    ENDIF

	_cHtml += '<table width="996" height="39"> <tr> <td align="center"><span class="negrito2" align="center">'+_cTitulo+'</span><br>'
	_cHtml += '<br> </td> </tr> </table>'
	_cHtml += '<p><span class="negrito">Prezados, </span>'
	_cHtml += '<br><span class="negrito">'+_cTexto2+'</span><span class="texto1"></span></br></p>'

	_cHtml += '<p><span class="negrito">Codigo: </span>'+M->B1_COD
	_cHtml += '<br><span class="negrito">Descricao: </span></br>'+M->B1_DESC+'</p>'
	
	_cHtml += '<p><span class="negrito">Usuário que realizou cadastro: </span>'+Alltrim(RetCodUsr())+" - "+Alltrim(UsrFullName(RetCodUsr()))
	_cHtml += '<br><span class="negrito">Data de Cadastro: </span></br>'+dtoc(dDataBase)+" as "+TIME()+'</p>'
	_cHtml += '<table width="500" border="0" cellpadding="0" cellspacing="8"> <tr> <td width="167"><P class=MsoNormal> <span class="texto2" align="center"></span></p>'//</body></html>'

	_cHtml += '<br>'
	_cHtml += '<br>'
	_cHtml += '<br>'
//	_cHtml += '<td class="itens" align="left" ><b>Ambiente:</b> ['+ GETENVSERVER() +'] / <b>Fonte:</b> [A010TOK]</td>'
	_cHtml += '<p><span class="negrito">Ambiente: </span></br> ['+ GETENVSERVER() +']'
	_cHtml += '   <span class="negrito"> / Fonte:    </span></br> [A010TOK] </p>'
	_cHtml += '</body>'
	_cHtml += '</html>'	
	
	//====================================================================================================
	// Selecionar os e-mail's dos usuarios que sera enviado o resumo do HTML
	//====================================================================================================
	If M->B1_TIPO == "PA"
		_cAlias := GetNextAlias()
		BeginSql alias _cAlias
	
	
			SELECT ZZL_EMAIL
			FROM %Table:ZZL%
			WHERE	D_E_L_E_T_ = ' '
			AND		ZZL_ENVWFP = 'S'
		
		EndSql
	Else				
		_cAlias := GetNextAlias()
		BeginSql alias _cAlias
	
	
			SELECT ZZL_EMAIL
			FROM %Table:ZZL%
			WHERE	D_E_L_E_T_ = ' '
			AND		ZZL_ENVWPT = 'S'
		
		EndSql	
	Endif	
	
	//====================================================================================================
	// Verifica inicialmente para quais usuarios o resumo sera enviado
	//====================================================================================================
	DBSelectArea( _cAlias )
	(_cAlias)->( DBGoTop() )

	//====================================================================================================
	// Deve existir no minimo um e-mail para a rotina processar a montagem e envio do arquivo
	//====================================================================================================
	If (_cAlias)->( !Eof() )

		While (_cAlias)->( !Eof() )
	 
			_cEmail += ";"+ AllTrim( (_cAlias)->ZZL_EMAIL )
	 
		(_cAlias)->(DBSkip() )
		EndDo
	
		_cEmail := SubStr( _cEmail , 2 , Len( _cEmail ) )
	Endif

    If SuperGetMV("IT_AMBTEST",.F.,.T.)
	
	   _cEmlLog := "Rotina executada em Ambiente de Testes: ["+ GetEnvServer() +"]. Não será processado o envio de e-mail!"

            //  _cMens                                                                 ,_ctitu           ,_csolu,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
		U_ITMSG(UPPER(_cEmlLog)+CHR(13)+CHR(10)+"E-mail para: "+_cEmail+CHR(13)+CHR(10),"Envio do E-MAIL",      ,3     ,       ,        ,.F.)

	   Return()

    EndIF
	
	Send mail ; 		    // envia e-mail
	from _Remetente ; 	 // de
	To _cEmail ; 		    // para
	subject _cSubject ;  // assunto
	body _cHtml ;			// mensagem em HTML
	RESULT _lResult 
					
	If !_lResult 
	   GET MAIL ERROR _cErrorMsg
	   cLogErro := "Falha de Envio: "+ AllTrim(_cErrorMsg)
	Else
	   cLogErro := "Sucesso: e-mail enviado corretamente!"
    ENDIF

   DISCONNECT SMTP SERVER

    IF SuperGetMV("IT_AMBTEST",.F.,.T.)
            //  _cMens                                                                ,_ctitu           ,_csolu,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
  		U_ITMSG(UPPER(cLogErro)+CHR(13)+CHR(10)+"E-mail para: "+_cEmail+CHR(13)+CHR(10),"Envio do E-MAIL",    "",3     ,       ,        ,.F.)
    ENDIF

EndIf 

Return


/*
===============================================================================================================================
Programa----------: A010CadSB1()
Autor-------------: Alex Wallauer
Data da Criacao---: 04/11/2019
===============================================================================================================================
Descrição---------: Rotina para zerar a 1o Quantidade e da 2o Quantidade 
===============================================================================================================================
Parametros--------: oProc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function A010CadSB1(oProc)
Local _cObs     := "MOVIMENTO GERADO PELA ALTERACAO DE U.M. (A010TOK)"
Local _cArmaz   := ""
Local _cCod     := SB1->B1_COD 
LOCAL _lEfetivar:=.T.
Local _cAlias   := GetNextAlias()
Local aExecAuto :={}    , A
LOCAL _aLog     :={}
Local _lRet     := .T.
Local _cQuery   := " SELECT "
_cQuery += " NNR_CODIGO CODIGO, NNR_DESCRI DESCRICAO "
_cQuery += " FROM "+RetSqlName("NNR")+" NNR "
_cQuery += " WHERE D_E_L_E_T_ = ' ' "

DBUseArea( .T. , "TOPCONN" , TCGenQry(,,_cQuery) , _cAlias , .T. , .F. )
COUNT TO _nRegSB1

_cTot   :=ALLTRIM(STR(_nRegSB1))
_nTam   :=LEN(_cTot)+1
_nConta :=0		
_aLogTOK:={}

SB2->( DBSetOrder(1) )
ZZM->( DBSetOrder(1) )
ZZM->( DBGOTOP() )
DO WHILE ZZM->( !EOF() )
	
	_nConta:=0
	(_cAlias)->( DBGOTOP() )
	DO WHILE (_cAlias)->( !EOF() )
		
		_cArmaz := (_cAlias)->CODIGO
		_nConta++
		IF oProc <> NIL
	        oProc:cCaption := ("Analisando Filial ["+ZZM->ZZM_CODIGO+"] / Armazem:  ["+_cArmaz+"], "+ALLTRIM(STRZERO(_nConta,_nTam)) +" de "+ _cTot)
			ProcessMessages()
		ENDIF
		
		If SB2->( DBSeek( ZZM->ZZM_CODIGO+ _cCod + _cArmaz ) )

			_nQatu   := SB2->B2_QATU
			_nQatu2N := SB2->B2_QTSEGUM
			_nVatu1  := SB2->B2_VATU1
			IF SB1->B1_GRUPO $ u_ITGetMV( "ITGR2N" , "0006" )
			   lTemSegUM:= _nQatu2N > 0 
            ELSE
			   lTemSegUM:= (SB1->B1_CONV > 0 .AND. _nQatu2N > 0) .OR. (SB1->B1_CONV = 0 .AND. _nQatu2N = 0)
			ENDIF
		   
			If _nQatu > 0 .AND. _nVatu1 > 0 .AND. lTemSegUM
				
				AADD(aExecAuto,{_cArmaz,(_cAlias)->DESCRICAO,ZZM->ZZM_CODIGO,ZZM->ZZM_DESCRI})
				
			ELSEIf _nQatu > 0 .AND. _nVatu1 = 0 .AND. lTemSegUM
				
				AADD(aExecAuto,{_cArmaz,(_cAlias)->DESCRICAO,ZZM->ZZM_CODIGO,ZZM->ZZM_DESCRI})
				
			ELSEIF !(_nQatu = 0 .AND. _nVatu1 = 0 .AND. _nQatu2N = 0)
				
				AADD( _aLog ,{.F.,_cArmaz,(_cAlias)->DESCRICAO,_nQatu,_nQatu2N,_nVatu1,SB1->B1_CONV,"Armazem com quantidades / valores incorretos",ZZM->ZZM_CODIGO+" - "+ZZM->ZZM_DESCRI} )
				_lRet:= .F.

			ELSEIF _nQatu = 0 .AND. _nVatu1 = 0 .AND. _nQatu2N = 0
				
				AADD( _aLogTOK ,{.T.,_cArmaz,(_cAlias)->DESCRICAO,_nQatu,_nQatu2N,_nVatu1,SB1->B1_CONV,"INVENTARIAR URGENTE",ZZM->ZZM_CODIGO+" - "+ZZM->ZZM_DESCRI} )
				
			ENDIF
			
		ENDIF
		
		(_cAlias)->(DBSKIP())
	ENDDO
	ZZM->(DBSKIP())
ENDDO

If Select(_cAlias) > 0
	(_cAlias)->( DBCloseArea() )
EndIf

_cTot:=ALLTRIM(STR(LEN(aExecAuto)))
_nTam:=LEN(_cTot)
_nConta:=0		


_cQuery := "SELECT MAX(D3_DOC) AS MAXD3DOC "
_cQuery += " FROM " + RetSqlName("SD3") + " D3"
_cQuery += " WHERE D3.D_E_L_E_T_ = ' ' "
_cQuery += " AND SUBSTR( D3.D3_DOC , 1 , 1 ) IN ('0','1','2','3','4','5','6','7','8','9') "


SB2->( DBSetOrder(1) )

BEGIN SEQUENCE

FOR A :=  1 TO LEN(aExecAuto)
	
	_cArmaz := aExecAuto[A,1]
	_cDArmaz:= aExecAuto[A,2]
	_cFilial:= aExecAuto[A,3]
	_cFilDes:= aExecAuto[A,4]

	_nConta++
    IF oProc <> NIL
	   oProc:cCaption := ("Zerando Filial ["+_cFilial+"] / Armazem:  ["+_cArmaz+"], "+ALLTRIM(STRZERO(_nConta,_nTam)) +" de "+ _cTot)
	   ProcessMessages()
	ENDIF   
	
	If SB2->( DBSeek( _cFilial + _cCod + _cArmaz ) )

		_nQatu   := SB2->B2_QATU
		_nQatu2N := SB2->B2_QTSEGUM
		_nVatu1  := SB2->B2_VATU1
        
		IF SB1->B1_GRUPO $ u_ITGetMV( "ITGR2N" , "0006" )
		   lTemSegUM:= _nQatu2N > 0 
        ELSE
		   lTemSegUM:=(SB1->B1_CONV > 0 .AND. _nQatu2N > 0) .OR. (SB1->B1_CONV = 0 .AND. _nQatu2N = 0)
		ENDIF   

	    IF !_lRet
	       AADD( _aLog ,{.F.,_cArmaz,_cDArmaz,_nQatu,_nQatu2N,_nVatu1,SB1->B1_CONV,"Armazem não foi zerado, pois existem outros armazens incorretos",_cFilial+" - "+_cFilDes} )
           LOOP
	    ENDIF

	    _cD3_DOC:= ""
	    _cQueryF:= " AND D3.D3_FILIAL = '" + _cFilial + "'"
		DBUSEAREA(.T.,"TOPCONN", TcGenQry(,,(_cQuery+_cQueryF)), "SD3T", .T., .F. )
		IF SD3T->( !Eof() )
			_cD3_DOC:=SOMA1(SD3T->MAXD3DOC)
		ENDIF
		SD3T->( DBCLOSEAREA() )        

		_aSD31 := {}
        _aCab1 := {}
        _aToSD31 := {}

		If _nQatu > 0 .AND. _nVatu1 > 0 .AND. lTemSegUM

			_aCab1 := {	{ "D3_FILIAL"	, _cFilial			, Nil },;
			            { "D3_TM"		, "997"				, NIL },;//SAIDA
                        { "D3_CC"       ,"        "         , NIL },;
			            { "D3_DOC"		, _cD3_DOC			, NIL },;
			            { "D3_EMISSAO"	, DDATABASE			, NIL } }			

			_aSD31 := {	{ "D3_COD"		, _cCod				, NIL },;
			            { "D3_LOCAL"	, _cArmaz			, NIL },;
			            { "D3_QUANT"	, _nQatu    		, NIL },;//TIRAR
			            { "D3_CUSTO1"	, _nVatu1			, NIL },;//TIRAR
		            	{ "D3_CUSTO3"	, _nVatu1			, NIL },;//TIRAR
		            	{ "D3_QTSEGUM"	, _nQatu2N			, NIL },;//TIRAR
			            { "D3_I_OBS"    , _cObs				, NIL } }
			
		ELSEIf _nQatu > 0 .AND. _nVatu1 = 0 .AND. lTemSegUM

			_aCab1 := {	{ "D3_FILIAL"	, _cFilial			, Nil },;
			            { "D3_TM"		, "998"				, NIL },;//SAIDA
                        { "D3_CC"       ,"        "         , NIL },;
		            	{ "D3_DOC"		, _cD3_DOC			, NIL },;
			            { "D3_EMISSAO"	, DDATABASE			, NIL } }			

			_aSD31 := {	{ "D3_COD"		, _cCod				, NIL },;
			            { "D3_LOCAL"	, _cArmaz			, NIL },;
		            	{ "D3_QUANT"	, _nQatu    		, NIL },;//TIRAR
		            	{ "D3_CUSTO1"	, 0  				, NIL },;
			            { "D3_CUSTO3"	, 0					, NIL },;
			            { "D3_QTSEGUM"	, _nQatu2N			, NIL },;//TIRAR
			            { "D3_I_OBS"    , _cObs				, NIL } }
		ENDIF
		
        AADD(_aToSD31,_aSD31)

		BEGIN TRANSACTION
		
		lMsErroAuto := .F.
		
		IF _lEfetivar .AND. LEN(_aSD31) > 0

			cFilOld:=cFilAnt
			cFilAnt:=_cFilial
			
            MSExecAuto( {|x,y,z| mata241(x,y,z) } , _aCab1 , _aToSD31 , 3 ) //Inclusao
			
			cFilAnt:=cFilOld
			
		ENDIF
		
		If lMsErroAuto
			
			//_cErro:="MSExecAuto: [ "+MostraErro(Upper(GetSrvProfString("STARTPATH","")),"MEST015.LOG")+" ]" 
			_cErro := "MSExecAuto: [ Este armazém não foi zerado, verifique empenhos e reservas e remova-os antes de alterar o produto. ]" 
			
			AADD( _aLog ,{.F.,_cArmaz,_cDArmaz,_nQatu,_nQatu2N,_nVatu1,SB1->B1_CONV,_cErro,_cFilial+" - "+_cFilDes} )
		    _lRet:= .F.
			
			DisarmTransaction()
			
		ELSEIF LEN(_aSD31) > 0
			
			AADD( _aLog ,{.T.,_cArmaz,_cDArmaz,_nQatu,_nQatu2N,_nVatu1,SB1->B1_CONV,"Armazem com quantidades/valores zerado com sucesso",_cFilial+" - "+_cFilDes} )
			
		EndIf
		
		END TRANSACTION
		
	ENDIF

NEXT

END SEQUENCE  

_lTudoZerado:=.F.
IF LEN(_aLog) = 0 .AND. LEN(_aLogTOK) > 0
   _lTudoZerado:=.T.
   _aLog:=_aLogTOK
ENDIF

_aLogAux:=ACLONE(_aLog)
_aLog:={}
FOR A :=  1 TO LEN(_aLogAux)
	AADD( _aLog ,{_aLogAux[A,1],;
	              _aLogAux[A,9],;
	              _aLogAux[A,2],;
	              (Transform(_aLogAux[A,4],PesqPict("SB2","B2_QATU   "))),;
	              (Transform(_aLogAux[A,5],PesqPict("SB2","B2_QTSEGUM"))),;
	              (Transform(_aLogAux[A,6],PesqPict("SB2","B2_VATU1  "))),;
	              (Transform(_aLogAux[A,7],PesqPict("SB1","B1_CONV   "))),;
	              _aLogAux[A,8]} )
NEXT
ASORT(_aLog,,,{|X,Y| (X[2]+X[3]) < (Y[2]+Y[3]) })//ORDEM DE FILIAL + ARMAZEM

A010Log(_aLog,oProc,_lRet)

RETURN _lRet

/*
===============================================================================================================================
Programa----------: A010Log()
Autor-------------: Alex Wallauer
Data da Criacao---: 04/11/2019
===============================================================================================================================
Descrição---------: Rotina para zerar a 1o Quantidade e da 2o Quantidade 
===============================================================================================================================
Parametros--------: _aLog,oProc,_lRet
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function A010Log(_aLog,oProc,_lRet)
LOCAL _aCab:={}
LOCAL _aSize:={}

If Len(_aLog) > 0
	
	//Monta aheader
	aadd(_aCab,"")//01
	aadd(_aSize,5)
	AAdd(_aCab,"Filial")//02
	aadd(_aSize,90)
	AAdd(_aCab,"Armazem")//03
	aadd(_aSize,5)
	AAdd(_aCab,"Qtde.1a.UM")//04
	aadd(_aSize,45)
	AAdd(_aCab,"Qtde.2a.UM")//05
	aadd(_aSize,45)
	AAdd(_aCab,"Vlr.Tot.Atual")//06
	aadd(_aSize,45)
	AAdd(_aCab,"Fator.Conv.")//07
	aadd(_aSize,45)
	AAdd(_aCab,"Resultado")//08
	aadd(_aSize,150)

    nPosResu:=LEN(_aCab)//Posiçao do "Resultado"
    A010Email(_aLog,_aCab,oProc,_lRet)

    aBotoes:={}                                           
    AADD( aBotoes , { "" , {|| AVISO("ATENCAO",oLbxAux:aArray[oLbxAux:nAt][ nPosResu ],{"Fechar"},3) }	, "" , "Ver Resultado"		  } )
    AADD( aBotoes , { "" , {|| A010Email(_aLog,_aCab,oProc,_lRet) }	, "" , "Re-Envio de e-mail"		  } )
//          ITListBox(_cTitAux              , _aHeader , _aCols  , _lMaxSiz , _nTipo , _cMsgTop , _lSelUnc , _aSizes , _nCampo , bOk , bCancel, _abuttons )
   _lRet:=U_ITLISTBOX("Armazens Processados", _aCab    , _aLog   , .T.      , 4      ,          ,          , _aSize  ,         ,     ,        , aBotoes)
Else
//	U_ITMSG("Nenhum registro processado","Atenção",,1)
Endif
RETURN _lRet

/*
===============================================================================================================================
Programa----------: A010Email()
Autor-------------: Alex Wallauer
Data da Criacao---: 05/11/2019
===============================================================================================================================
Descrição---------: Monta e envia email 
===============================================================================================================================
Parametros--------: _aTLinhas,_aCab,oProc
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function A010Email(_aTLinhas,_aCab,oProc,_lRet)
Local _aConfig	:= U_ITCFGEML('')
Local _cEmlLog	:= ""
Local _cMsgEml	:= ""
Local _nI , _aSizes:={}
Local cGetCc	:= ""
Local cErMens	:= "Correções necessarias antes de alterar o cadastro"
Local cOKMens	:= "Inventariar o produto nos armazens relacionados"
Local cGetPara	:= "almoxarifados@italac.com.br"
Local _cTot     := ALLTRIM(STR(LEN(_aTLinhas)))
Local _nTam     := LEN(_cTot)
Local _cNomeFil := cFilant+" - "+AllTrim( Posicione('SM0',1,"01"+cFilant,'M0_FILIAL') )
Local cTit      := ""
Local cGetAssun := "Alterações do Produto "+ALLTRIM(SB1->B1_COD)+"-"+ALLTRIM(M->B1_DESC)+": "

IF SB1->B1_UM <> M->B1_UM 
   cTit     +='Alteração da 1a U.M. <b>De: "'+SB1->B1_UM+'" Para: "'+M->B1_UM+'"</b>'+CHR(13)+CHR(10)
   cGetAssun+='1a U.M. De: "'+SB1->B1_UM+'" Para: "'+M->B1_UM+'", '
ENDIF
IF SB1->B1_SEGUM <> M->B1_SEGUM 
   cTit     +='Alteração da 2a U.M. <b>De: "'+SB1->B1_SEGUM+'" Para: "'+M->B1_SEGUM+'"</b>'+CHR(13)+CHR(10)
   cGetAssun+='2a U.M. De: "'+SB1->B1_SEGUM+'" Para: "'+M->B1_SEGUM+'", '
ENDIF
IF SB1->B1_TIPCONV <> M->B1_TIPCONV 
   cTit     +='Alteração do Tipo Conversão <b>De: "'+SB1->B1_TIPCONV+'" Para: "'+M->B1_TIPCONV+'"</b>'+CHR(13)+CHR(10)
   cGetAssun+='Tipo Conv. De: "'+SB1->B1_TIPCONV+'" Para: "'+M->B1_TIPCONV+'", '
ENDIF
IF SB1->B1_CONV <> M->B1_CONV
   cTit     +='Alteração da Conversão <b>De: "'+ALLTRIM(STR(SB1->B1_CONV,10,2))+'" Para: "'+ALLTRIM(STR(M->B1_CONV,10,2))+'"</b>'+CHR(13)+CHR(10)
   cGetAssun+='Conversão De: "'+ALLTRIM(STR(SB1->B1_CONV,10,2))+'" Para: "'+ALLTRIM(STR(M->B1_CONV,10,2))+'", '
ENDIF

cTit     +="PRODUTO: <b>"+ALLTRIM(SB1->B1_COD)+"-"+ALLTRIM(M->B1_DESC)+"</b>"
cGetAssun:=LEFT(cGetAssun,LEN(cGetAssun)-2)

IF SuperGetMV("IT_AMBTEST",.F.,.T.)
   cGetPara	:= ""
ENDIF
If LEN(UsrRetGrp(PswChave(RetCodUsr()),RetCodUsr())) # 0 
   cGetCc  := LOWER(Alltrim(UsrRetMail(__cUserID)))+SPACE(150) // Pega e-mail do usuario
Endif

IF EMPTY(cGetPara)
   cGetPara:=cGetCc
ENDIF   
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
_cMsgEml += '      <td align="center" colspan="2" class="grupos">Dados da alteração</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Alterado por: </b></td>'
_cMsgEml += '      <td class="itens" >'+ UsrFullName(__cUserID) +'</td>' 
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Filial:</b></td>'
_cMsgEml += '      <td class="itens" >'+ _cNomeFil +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>Observações:</b></td>'
IF _lRet
   _cMsgEml += '      <td class="itens" >'+cOKMens+'</td>'
ELSE
   _cMsgEml += '      <td class="itens" >'+cErMens+'</td>'
ENDIF
_cMsgEml += '    </tr>'
_cMsgEml += '</table>'

//          01   02   03   04   05 
_aSizeOK:={"22","05","10","33","30"}
IF _lRet
    _cMsgEml += '<br>'
    _cMsgEml += '<table class="bordasimples" width="1300">'
    _cMsgEml += '    <tr>'
    _cMsgEml += '      <td align="center" colspan="'+ALLTRIM(STR(LEN(_aSizeOK)))+'" class="grupos"><b>Produto de Filiais / Armazens para INVENTARIAR URGENTE</b></td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizeOK[01]+'%"><b>'+_aCab[02]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizeOK[02]+'%"><b>'+_aCab[03]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="left"   width="'+_aSizeOK[03]+'%"><b>Produto</b></td>'
	_cMsgEml += '      <td class="itens" align="left"   width="'+_aSizeOK[04]+'%"><b>Descrição</b></td>'
	_cMsgEml += '      <td class="itens" align="left"   width="'+_aSizeOK[05]+'%"><b>'+_aCab[08]+'</b></td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '    #LISTAOK#'
	_cMsgEml += '</table>'
	_cMsgEml += '<br>'
ENDIF

IF !_lTudoZerado
	_cMsgEml += '<br>'
	_cMsgEml += '<table class="bordasimples" width="1300">'
	_cMsgEml += '    <tr>'
	//        01    02   03   04   05   06   07
	_aSizes:={"05","05","10","10","18","07","45"}
	IF _lRet
		_cMsgEml += ' <td align="center" colspan="'+ALLTRIM(STR(LEN(_aSizes)))+'" class="grupos"><b>Valores e Quantidades de Filiais / Armazens Zerados</b></td>'
	ELSE
		_cMsgEml += ' <td align="center" colspan="'+ALLTRIM(STR(LEN(_aSizes)))+'" class="grupos"><b>Filiais / Armazens com problemas</b></td>'
	ENDIF
	_cMsgEml += '    </tr>'
	_cMsgEml += '    <tr>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[01]+'%"><b>'+_aCab[02]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="center" width="'+_aSizes[02]+'%"><b>'+_aCab[03]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[03]+'%"><b>'+_aCab[04]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[04]+'%"><b>'+_aCab[05]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[05]+'%"><b>'+_aCab[06]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="right"  width="'+_aSizes[06]+'%"><b>'+_aCab[07]+'</b></td>'
	_cMsgEml += '      <td class="itens" align="left"   width="'+_aSizes[07]+'%"><b>'+_aCab[08]+'</b></td>'
	_cMsgEml += '    </tr>'
	_cMsgEml += '    #LISTA#'
	_cMsgEml += '</table>'
ENDIF

_cMsgEml += '</center>'
_cMsgEml += '<br>'
_cMsgEml += '<br>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
_cMsgEml += '      <td class="itens" align="left" > ['+ GETENVSERVER() +'] / <b>Fonte:</b> [A010TOK]</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '</body>'
_cMsgEml += '</html>'

_cOKLista:=""
_cGetLista:=""
_lEnvia:=.F.
For _nI := 1 To LEN(_aTLinhas)
	
    IF oProc <> NIL
	   oProc:cCaption := ("Enviando Log: "+ALLTRIM(STRZERO(_nI,_nTam))+" de "+ _cTot)
	   ProcessMessages()
	ENDIF   
//	IF !_lRet .AND. (_aTLinhas[_nI][1])
//		LOOP
//	ENDIF
	
	IF _lRet
		_cOKLista += '    <tr>'
		_cOKLista += '      <td class="itens" align="left"   width="'+_aSizeOK[01]+'%">'+ _aTLinhas[_nI][02]+'</td>'
		_cOKLista += '      <td class="itens" align="center" width="'+_aSizeOK[02]+'%">'+ _aTLinhas[_nI][03]+'</td>'
		_cOKLista += '      <td class="itens" align="left"   width="'+_aSizeOK[03]+'%">'+ SB1->B1_COD+'</td>'
		_cOKLista += '      <td class="itens" align="left"   width="'+_aSizeOK[04]+'%">'+ M->B1_DESC+'</td>'
		_cOKLista += '      <td class="itens" align="left"   width="'+_aSizeOK[05]+'%"><b>INVENTARIAR URGENTE</b></td>'
		_cOKLista += '    </tr>'
	    _lEnvia:=.T.
	ENDIF
	
	IF !_lTudoZerado
		_cGetLista += '    <tr>'
		_cGetLista += '      <td class="itens" align="center" width="'+_aSizes[01]+'%">'+ LEFT(_aTLinhas[_nI][02],2)+'</td>'
		_cGetLista += '      <td class="itens" align="center" width="'+_aSizes[02]+'%">'+ _aTLinhas[_nI][03]+'</td>'
		_cGetLista += '      <td class="itens" align="right"  width="'+_aSizes[03]+'%">'+ _aTLinhas[_nI][04]+'</td>'
		_cGetLista += '      <td class="itens" align="right"  width="'+_aSizes[04]+'%">'+ _aTLinhas[_nI][05]+'</td>'
		_cGetLista += '      <td class="itens" align="right"  width="'+_aSizes[05]+'%">R$ '+ _aTLinhas[_nI][06]+'</td>'
		_cGetLista += '      <td class="itens" align="right"  width="'+_aSizes[06]+'%">'+ _aTLinhas[_nI][07]+'</td>'
		_cGetLista += '      <td class="itens" align="left"   width="'+_aSizes[07]+'%">'+ _aTLinhas[_nI][08]+'</td>'
		_cGetLista += '    </tr>'
	    _lEnvia:=.T.
	ENDIF

Next

IF _lEnvia

   _cMsgEml:=STRTRAN(_cMsgEml,"#LISTAOK#",_cOKLista)
  
   _cMsgEml:=STRTRAN(_cMsgEml,"#LISTA#",_cGetLista)
		
   // Chama a função para envio do e-mail
   U_ITENVMAIL( Lower(AllTrim(UsrRetMail(RetCodUsr()))), cGetPara, cGetCc, "", cGetAssun, _cMsgEml, "", _aConfig[01], _aConfig[02], _aConfig[03], _aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )
		
   If SuperGetMV("IT_AMBTEST",.F.,.T.)
      U_ITMSG(UPPER(_cEmlLog)+CHR(13)+CHR(10)+;
		           "E-mail para: "+cGetPara+;
		           " Com Copia: "+cGetCc+CHR(13)+CHR(10),"Envio do E-MAIL",,3)
   ENDIF
ELSE   
   If SuperGetMV("IT_AMBTEST",.F.,.T.)
      U_ITMSG("Não tem registros para enviar","Envio do E-MAIL",,1)
   ENDIF   
ENDIF

Return .T.

/*
===============================================================================================================================
Programa----------: A010WlInc()
Autor-------------: Alex Wallauer
Data da Criacao---: 23/12/2019
===============================================================================================================================
Descrição---------: Monta e envia email 
===============================================================================================================================
Parametros--------: _oModelSB1
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function A010WlInc(_oModelSB1)
Local _aConfig	:= U_ITCFGEML('') , E
Local _cEmlLog	:= ""
Local _cMsgEml	:= ""
Local cGetCc	:= ""
Local cGetPara	:= "sistema@italac.com.br"
Local cTit      := "ALTERAÇÃO DE PRODUTO"
Local cGetAssun :='NOVO PRODUTO EM PROCESSO DE INCLUSAO'

DBSELECTAREA("ZZL")
DBSETORDER(3) //ZZL_FILIAL + ZZL_CODUSU

IF !Inclui .AND. !("#CONTROLE" $ SB1->B1_I_MOTBL)

	RETURN .T.	    

ELSEIf  (!DBSEEK(xFilial("ZZL") + __cUserId) .OR. ZZL->ZZL_CADPRD = "5" .OR. ZZL->ZZL_CADPRD = " ") .OR.;
    (!ZZL->ZZL_CADPRD $ "1,0" .AND. !Altera )

	U_ITMSG("O usuário: " + cUserName + " não possui permissão para executar esta ação neste cadastro.",;
		    "Usuário Sem Acesso",;
		    "Verificar com a área de TI a possibilidade de habilitar o seu usuário.",3,,,.T.)

	RETURN .F.	    

ELSEIF ZZL->ZZL_CADPRD = "0"

	RETURN .T.	    

EndIf

IF !Inclui
   M->B1_I_MOTBL:=SB1->B1_I_MOTBL
   M->B1_MSBLQL :=SB1->B1_MSBLQL
ENDIF   

IF ZZL->ZZL_CADPRD = "1"//Almoxarifado (Incluir)

   IF Inclui .OR. "#CONTROLE1" $ SB1->B1_I_MOTBL
      cTit :="INCLUSAO DE PRODUTO"
      cMens:="Aguardando FISCAL preencher campos"
      cTipo:=" = '2'"
      M->B1_MSBLQL :="1"
      M->B1_I_MOTBL:="#CONTROLE1 - "+cMens//Inclusão do Almoxarifado"
   ELSE
      RETURN .T.//SE NÃO TIVER NA FASE 1 NÃO ENVIA EMAIL
   ENDIF   

ELSEIF ZZL->ZZL_CADPRD = "2"//FISCAL 

   IF "#CONTROLE1" $ SB1->B1_I_MOTBL  .OR. "#CONTROLE2" $ SB1->B1_I_MOTBL  //NA FASE  ANTERIOR OU ATUAL DE NOVO
      cMens:="Aguardando CONTABILIDADE preencher campos"
      cTipo:=" = '3'"
      M->B1_I_MOTBL:="#CONTROLE2 - "+cMens//Alteração do Fiscal"
   ELSE
      RETURN .T.//SE NÃO TIVER NA FASE 2 NÃO ENVIA EMAIL
   ENDIF

ELSEIF ZZL->ZZL_CADPRD = "3"//CONTABILIDADE 

   IF "#CONTROLE2" $ SB1->B1_I_MOTBL .OR. "#CONTROLE3" $ SB1->B1_I_MOTBL  //NA FASE  ANTERIOR OU ATUAL DE NOVO
      cMens:="Aguardando EXPEDIÇÃO preencher campos"
      cTipo:=" = '4'"
      M->B1_I_MOTBL:="#CONTROLE3 - "+cMens//Alteração do Fiscal"
   ELSEIF !"#CONTROLE3" $ SB1->B1_I_MOTBL 
	  U_ITMSG("Deve-se aguardar a Fiscal preencher os campos para finalizar o processo.",;
	          "Usuário Sem Acesso",;
		      "Verificar com a área de Fiscal.",3,,,.T.)
	  RETURN .F.	    
   ENDIF   

ELSEIF ZZL->ZZL_CADPRD = "4"//EXPEDICAO 

   cTit :="Novo produto incluido com SUCESSO no cadastro"
   cMens:="PRODUTO DESBLOQUEADO E DISPONIVEL PARA USO"
   cGetAssun :=UPPER(cTit)
   IF "#CONTROLE3" $ SB1->B1_I_MOTBL  
      M->B1_I_MOTBL:=""
      M->B1_MSBLQL :="2"
   ELSE
	  U_ITMSG("Deve-se aguardar a Contabilidade preencher os campos para finalizar o processo.",;
	          "Usuário Sem Acesso",;
		      "Verificar com a área de Contabilidade.",3,,,.T.)
	  RETURN .F.	    
   ENDIF   
   cTipo:=" IN ('1','2','3','4') "
ELSE
   RETURN .T.
ENDIF

_oModelSB1:LoadValue('B1_MSBLQL' ,M->B1_MSBLQL)
_oModelSB1:LoadValue('B1_I_MOTBL',M->B1_I_MOTBL)

_cFileName:=NIL
IF !Inclui

	_cAlteracoes:="Produto:;"+M->B1_COD+"-"+ALLTRIM(M->B1_DESC)+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	_cAlteracoes+="CAMPO;ANTES;DEPOIS"+CHR(13)+CHR(10)
	
	_aStruct:= SB1->(DBSTRUCT())
	For E := 1 TO LEN(_aStruct)
	    _cUsado:=Getsx3cache(_aStruct[E][1],"X3_USADO")
		If !X3USO(_cUsado)
		   LOOP
		ENDIF
		_cConOrg := "SB1->"+ALLTRIM(_aStruct[E][1] )
		_cConAlt :=   "M->"+ALLTRIM(_aStruct[E][1] )
		DO CASE
			
			CASE _aStruct[E][2] == "C"
				_cConOrg := AllTrim( &(_cConOrg) )
				_cConAlt := AllTrim( &(_cConAlt) )
				
			CASE _aStruct[E][2] == "N"
				_cConOrg := " "+cValToChar( &(_cConOrg) )
				_cConAlt := " "+cValToChar( &(_cConAlt) )
				
			CASE _aStruct[E][2] == "D"
				_cConOrg := DtoC( &(_cConOrg) )
				_cConAlt := DtoC( &(_cConAlt) )
				
			CASE _aStruct[E][2] == "L"
				_cConOrg := IF( &(_cConOrg) , ".T." , ".F." )
				_cConAlt := IF( &(_cConAlt) , ".T." , ".F." )
				
			CASE _aStruct[E][2] == "M"
				_cConOrg := AllTrim( &(_cConOrg) )
				_cConAlt := AllTrim( &(_cConAlt) )
				
		ENDCASE
		IF !(_cConOrg == _cConAlt)
		   _cAlteracoes+=AllTrim( _aStruct[E][1] )+";"+_cConOrg+";"+_cConAlt+CHR(13)+CHR(10)
		ENDIF
	NEXT
   _cFileName:="ALTERACOES_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+".CSV"
   _cFileName:=ALLTRIM(GETMV("MV_RELT",,"\SPOOL\"))+_cFileName
   MemoWrite(_cFileName,_cAlteracoes)
ENDIF   

_cQry := "SELECT ZZL_EMAIL "
_cQry += "FROM " + RetSqlName("ZZL") + " "
_cQry += "WHERE ZZL_FILIAL = '" + xFilial("ZZL") + "' "
_cQry += "  AND ZZL_CADPRD "+cTipo
_cQry += "  AND D_E_L_E_T_ = ' ' "

dbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "TRBZZL" , .T., .F. )

dbSelectArea("TRBZZL")
TRBZZL->(dbGoTop())

_acTo:={}
DO While !TRBZZL->(Eof())
	AADD(_acTo,AllTrim(TRBZZL->ZZL_EMAIL))
	TRBZZL->(DBSKIP())
ENDDO
TRBZZL->(dbCloseArea())

If ZZL->ZZL_CADPRD <> "4" .AND. LEN(UsrRetGrp(PswChave(RetCodUsr()),RetCodUsr())) # 0 // Quando nao for rotina automatica do configurador
   cGetCc  := LOWER(Alltrim(UsrRetMail(__cUserID))) // Pega e-mail do usuario
   AADD(_acTo,cGetCc)
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
_cMsgEml += '      <td align="center" colspan="2" class="grupos">Dados do Produto</b></td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>CODIGO: </b></td>'
_cMsgEml += '      <td class="itens" >'+ M->B1_COD +'</td>' 
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>DESCRIÇÃO: </b></td>'
_cMsgEml += '      <td class="itens" >'+ M->B1_DESC +'</td>' 
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>SOLICITANTE:</b></td>'
_cMsgEml += '      <td class="itens" >'+ UsrFullName(__cUserID) +'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" width="30%"><b>STATUS: </b></td>'
_cMsgEml += '      <td class="itens" >'+cMens+'</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '</table>'
_cMsgEml += '</center>'
_cMsgEml += '<br>'
_cMsgEml += '<br>'
_cMsgEml += '    <tr>'
_cMsgEml += '      <td class="itens" align="center" ><b>Ambiente:</b></td>'
_cMsgEml += '      <td class="itens" align="left" > ['+ GETENVSERVER() +'] / <b>Fonte:</b> [A010TOK]</td>'
_cMsgEml += '    </tr>'
_cMsgEml += '</body>'
_cMsgEml += '</html>'


FOR E := 1 TO LEN(_acTo)

    cGetPara:=_acTo[E]
    // Chama a função para envio do e-mail
//    ITEnvMail(cFrom        ,cEmailTo,_cEmailCo,cEmailBcc,cAssunto ,cMensagem,cAttach   ,cAccount    ,cPassword   ,cServer     ,cPortCon    ,lRelauth     ,cUserAut     ,cPassAut     ,cLogErro)
    U_ITENVMAIL(_aConfig[01], cGetPara,         ,         ,cGetAssun,_cMsgEml ,_cFileName,_aConfig[01],_aConfig[02],_aConfig[03],_aConfig[04], _aConfig[05], _aConfig[06], _aConfig[07], @_cEmlLog )
		
    If SuperGetMV("IT_AMBTEST",.F.,.T.)
       U_ITMSG(UPPER(_cEmlLog)+CHR(13)+CHR(10)+;
		           "E-mail para: "+cGetPara,"Envio do E-MAIL",,3)//+;
//		           " Com Copia: "+cGetCc+CHR(13)+CHR(10),"Envio do E-MAIL",,3)
    ENDIF
    IF _cFileName <> NIL
	   FERASE(_cFileName)
	ENDIF   

NEXT

Return .T.
