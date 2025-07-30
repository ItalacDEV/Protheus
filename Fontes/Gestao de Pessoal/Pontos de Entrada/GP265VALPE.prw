/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich     | 19/09/2017 | Troca de numerador do DA4 para getsxexnum - Chamado 21467  
-------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich     | 18/07/2018 | Reescrita de cadastro para aproveitar fornecedor/motorista pr� existente - Chamado 25427
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 02/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "RwMake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*
===============================================================================================================================
Programa----------: Gp265ValPE
Autor-------------: Tiago Correa Castro
Data da Criacao---: 06/11/2008
===============================================================================================================================
Descri��o---------: Ponto de Entrada para validar a inclusao/alteracao do cadastro de autonomo
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T. - Permite a Inclus�o/Altera��o
------------------: .F. - N�o permite a Inclus�o/Altera��o
===============================================================================================================================
*/
User Function Gp265ValPE()

Local _aArea		:= GetArea()
Local _lRet			:= .T.
Local _cCPF			:= M->RA_CIC
Local _cSefip		:= M->RA_CATEG
Local _cMatric		:= M->RA_MAT
Local _cAutFret		:= M->RA_I_AUTFR
Local cCodigo		:= "00001"
Local _cAliasSRA	:= GetNextAlias()
Local nCountRec		:= 0

//Log de utiliza��o
U_ITLOGACS()

//Valida filial de cadastro de autonomos
If !(cfilant $ u_itgetmv("ITFILAUT","01"))

	u_itmsg("Filial " + cfilant + " n�o autorizada para cadastro de autonomos!","Aten��o","Filial(is) autorizada(s) para cadastro de autonomos: " + alltrim(u_itgetmv("ITFILAUT","01")),1)
	Return .F.

Endif

//================================================================================
//| Verifico preenchimento dos campos de DDD e n�mero do celular
//================================================================================
If Empty(M->RA_DDDCELU) .or. Empty(M->RA_NUMCELU)
	u_itmsg(	 "Preenchimento do campo de DDD e n�mero do celular � obrigat�rio. Devido a integra��o com o cadastro de motoristas."	,"Campo Obrigat�rio.",;
					"Favor preencher o campo de DDD e n�mero do celular.",1				 												)

	Return(.F.)
EndIf


If Len(AllTrim(_cCPF)) > 0

	cQuery := " SELECT RA_MAT "
	cQuery += " FROM " + RetSqlName("SRA")
	If inclui 
		cQuery += " WHERE D_E_L_E_T_ = ' ' AND RA_SITFOLH <> 'D' AND RA_CIC = '"  + _cCPF    + "' AND RA_CATEG = '"  + _cSefip + "' "
	ElseIf altera
		cQuery += " WHERE D_E_L_E_T_ = ' ' AND RA_SITFOLH <> 'D' AND RA_MAT <> '" + _cMatric + "' AND RA_CIC = '"    + _cCPF   + "' "
		cQuery += " AND RA_CATEG = '" + _cSefip + "' "
	EndIf
	
	If Select(_cAliasSRA) > 0
		(_cAliasSRA)->( DBCloseArea() )
	EndIf
	
	DBUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , _cAliasSRA , .T. , .F. )
	COUNT TO nCountRec
	
	DBSelectArea(_cAliasSRA)
	(_cAliasSRA)->( DBCloseArea() )
	
	If nCountRec > 0
		
		If Inclui
		
			u_itmsg("Nao ser� poss�vel a inclusao desse registro pois ja existe um registro com o mesmo CPF e Categ. SEFIP na base de Dados!!","Cadastro duplicado - Inclusao",;
						"Favor verificar se os dados do Registro est�o corretos!!",1)
			_lRet	:=	.F.
			
		ElseIf Altera
		
			u_itmsg("Nao ser� poss�vel a alteracao desse registro pois ja existe um registro com o mesmo CPF e Categ. SEFIP com Matricula diferente na base de Dados!!",;
						"Cadastro duplicado - Alteracao",;
						"Favor verificar se os dados do Registro est�o corretos!!",1)
			_lRet	:=	.F.
			
		Endif                                                                          
	
	Endif                                                                              

Else

	u_itmsg("Para realizar o cadastro do Autonomo � necessario que se preencha o campo CPF.","Informa��o",;
				"Favor fornecer o CPF do Autonomo antes de realizar o seu cadastro.",1)
	_lRet	:=	.F.

EndIF
    
If _lRet .and. Inclui .and. _cSefip == "15" .and. _cAutFret == "S"

	cQuery := " SELECT MAX( SUBSTR(RA_MAT,2,5) ) AS MAXIMO "
	cQuery += " FROM " + RetSqlName("SRA")
	cQuery += " WHERE RA_FILIAL = '01' AND D_E_L_E_T_ = ' ' AND SUBSTR(RA_MAT,1,1) = '4' "
	
	TcQuery cQuery New Alias "TEMP"
	
	DBSelectArea("TEMP")
	TEMP->( DbGotop() )
	
    If TEMP->( !Eof() )
    	cCodigo := StrZero( Val(TEMP->MAXIMO) + 1 , 5 )
    EndIf
	
	TEMP->( DBCloseArea() )
	
	cCodigo := "4" + cCodigo
	
	//================================================================================
	//| Verifica se o c�digo est� dispon�vel                                         |
	//================================================================================
	While !MayIUseCode( "SRA" + xFilial("SRA") + cCodigo )
		cCodigo := Soma1(cCodigo)
	EndDo
	
	M->RA_MAT := cCodigo

EndIf

//================================================================================
//| Gera cadastros DO MOTORISTA E TRANSPORTADORA para autonomo
//================================================================================
If _lRet

	If M->RA_CATEG == "15" .and. M->RA_I_AUTFR == "S"

		_lRet := OkGeraCad()
		
	Endif
	
Endif

//================================================================================
//| Restaura a area.                                                             |
//================================================================================
RestArea( _aArea )
	
Return _lRet                     
                     

/*
===============================================================================================================================
Programa----------: OkGeraCad
Autor-------------: Fabiano Dias
Data da Criacao---: 08/07/2010
===============================================================================================================================
Descri��o---------: Gera��o autom�tica do cadastro de Fornecedor e Motorista a partir do Aut�nomo
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: lret - se conseguiu gerar o cadastro com sucesso
===============================================================================================================================
*/
Static Function OkGeraCad()  

Local _lRet		:= .T.
Local aVetor 	:= {}
Local _cFilial	:= xfilial("SRA")
Local _cCodForn	:= ""
Local _cLojForn	:= "0001"
Local _cCodAuto := M->RA_MAT
Local _cNome 	:= ALLTRIM( M->RA_NOMECMP	)
Local _cNReduz	:= ALLTRIM( M->RA_NOME		)
Local _cEnd 	:= ALLTRIM( M->RA_ENDEREC	)
Local _cBairro 	:= ALLTRIM( M->RA_BAIRRO	)
Local _cMuni	:= ALLTRIM( M->RA_MUNICIP	)
Local _cEst 	:= M->RA_ESTADO
Local _cCodMuni := M->RA_CODMUN
Local _cCEP 	:= M->RA_CEP
Local _cTipo 	:= "F"
Local _cCPF 	:= M->RA_CIC
Local _cOrgRG	:= M->RA_RGORG
Local _cInscEst := "" // "ISENTO"
Local _cDDD		:= M->RA_DDDFONE
Local _cTel 	:= ALLTRIM( M->RA_TELEFON )
Local _cTelComp	:= M->RA_TELEFON
Local _cCNH		:= M->RA_HABILIT
Local _cPai		:= ALLTRIM( M->RA_PAI )
Local _cMae		:= ALLTRIM( M->RA_MAE )
Local _cCodMot	:= ""
Local _cRg		:= ALLTRIM( M->RA_RG ) 
Local _cEmail	:= AllTrim( M->RA_EMAIL )
Local _cDDDCel	:= M->RA_DDDCELU
Local _cCelula	:= ALLTRIM( M->RA_NUMCELU )

Private lMsErroAuto := .F.
				
Begin Transaction				

	//================================================================================
	//| Cadastro de fornecedor                                                       |
	//================================================================================
	
	//Identifica se j� existe fornecedor tipo autonomo com mesmo cpf
	_lachou := .F.
	SA2->(dbsetorder(3))
	If SA2->(Dbseek(xfilial("SA2")+alltrim(_cCPF)))
	
		Do while SA2->A2_FILIAL == xfilial("SA2") .and. alltrim(SA2->A2_CGC) ==  alltrim(_cCPF)
		
		  If alltrim(SA2->A2_I_CLASS) == "A"
		  
		  	_cCodForn := alltrim(SA2->A2_COD)
		  	_lachou := .T.
		  	
		  Endif
		  
		  SA2->(Dbskip())
		  
		Enddo
		
		If empty(_cCodForn)
		
			_cCodForn := U_ACOM005( "A" , _cTipo , _cCPF )
			
		Endif
		
	Else
	
		_cCodForn := U_ACOM005( "A" , _cTipo , _cCPF )
	
	Endif
	
	aAdd( aVetor , {	"A2_I_CLASS"	, "A"												, nil } )
	aAdd( aVetor , {	"A2_TIPO"		, _cTipo										 	, nil } )
	aAdd( aVetor , {	"A2_CGC"		, _cCPF												, nil } )
	aAdd( aVetor , {	"A2_COD"		, _cCodForn											, nil } )
	aAdd( aVetor , {	"A2_LOJA"		, _cLojForn											, nil } )
	aAdd( aVetor , {	"A2_NOME"		, PadR( _cNome		, TamSX3('A2_NOME')[01]		)	, nil } ) 
	aAdd( aVetor , {	"A2_NREDUZ"		, PadR( _cNReduz	, TamSX3('A2_NREDUZ')[01]	)	, nil } ) 
	aAdd( aVetor , {	"A2_EST"		, _cEst												, nil } )
	aAdd( aVetor , {	"A2_COD_MUN"	, _cCodMuni											, nil } )
	aAdd( aVetor , {	"A2_MUN"		, _cMuni											, nil } )
	aAdd( aVetor , {	"A2_CEP"		, _cCEP												, nil } )
	aAdd( aVetor , {	"A2_END"		, _cEnd												, nil } )
	aAdd( aVetor , {	"A2_BAIRRO"		, _cBairro											, nil } )
	aAdd( aVetor , {	"A2_INSCR" 		, _cInscEst											, nil } )
	aAdd( aVetor , {	"A2_DDD"		, _cDDD												, nil } )
	aAdd( aVetor , {	"A2_TEL"		, _cTel 											, nil } )
	If !Empty( _cEmail )
	aAdd( aVetor , {	"A2_EMAIL"		, _cEmail											, nil } )
	EndIf
	aAdd( aVetor , {	"A2_I_FLAUT"	, _cFilial										 	, nil } )
	aAdd( aVetor , {	"A2_I_AUT"		, _cCodAuto											, nil } )
	
	MSExecAuto( {|x,y| Mata020(x,y) } , aVetor , iif(_lachou,4,3) )
	
	IF lMSErroAuto
	
		DisarmTransaction()
		
		If ( __lSx8 )
			RollBackSx8()
		EndIf 
		
		Mostraerro()
		_lRet:= .F.    
		
	Else        
	
		dbCommit()
		
		If ( __lSX8 )
			ConfirmSX8()
		EndIf				
		
	Endif
    
    //================================================================================
	//| Cadastro de motorista                                                        |
	//================================================================================
	lMsErroAuto := .F.
	aVetor 		:= 	{}  
	_lachou := .F.

	DA4->(Dbsetorder(3))
	If DA4->(Dbseek(xfilial("DA4")+alltrim(_cCPF)))
	
		_cCodMot := DA4->DA4_COD
		_lachou := .T.
		aVetor := { { 'DA4_NOME'	, PadR( _cNome		, TamSX3('DA4_NOME')[01]	)	, nil },; 
				{ 'DA4_NREDUZ'	, PadR( _cNReduz	, TamSX3('DA4_NREDUZ')[01]	)	, nil },; 
				{ 'DA4_FORNEC'	, _cCodForn											, NIL },;
				{ 'DA4_LOJA'	, _cLojForn											, NIL },;
				{ 'DA4_EST'		, _cEst												, NIL },;
				{ 'DA4_I_CMUN'	, _cCodMuni											, NIL },;
				{ 'DA4_MUN'		, _cMuni											, NIL },;
				{ 'DA4_CEP'		, _cCEP												, NIL },;
				{ 'DA4_END'		, _cEnd												, NIL },;
				{ 'DA4_BAIRRO'	, _cBairro											, NIL },;
				{ 'DA4_I_DDD2'	, StrZero(Val(_cDDD),3,0)							, nil },;
				{ 'DA4_TELREC'	, _cTelComp											, nil },;
				{ 'DA4_DDD'		, StrZero(Val(_cDDDCel),3,0)						, nil },;
				{ 'DA4_TEL'		, _cCelula											, nil },;
				{ 'DA4_CGC'		, _cCPF												, NIL },;
				{ 'DA4_NUMCNH'	, _cCNH												, NIL },;
				{ 'DA4_PAI'		, _cPai												, NIL },;
				{ 'DA4_MAE'		, _cMae												, NIL },;
				{ 'DA4_RGORG'	, _cOrgRg											, NIL },; 
				{ 'DA4_RG'		, _cRg												, NIL } } 
		
		
	Else
	
		_cCodMot := GETSXENUM("DA4","DA4_COD")
		aVetor := { { 'DA4_COD'		, _cCodMot											, NIL },;
				{ 'DA4_NOME'	, PadR( _cNome		, TamSX3('DA4_NOME')[01]	)	, nil },; 
				{ 'DA4_NREDUZ'	, PadR( _cNReduz	, TamSX3('DA4_NREDUZ')[01]	)	, nil },; 
				{ 'DA4_FORNEC'	, _cCodForn											, NIL },;
				{ 'DA4_LOJA'	, _cLojForn											, NIL },;
				{ 'DA4_EST'		, _cEst												, NIL },;
				{ 'DA4_I_CMUN'	, _cCodMuni											, NIL },;
				{ 'DA4_MUN'		, _cMuni											, NIL },;
				{ 'DA4_CEP'		, _cCEP												, NIL },;
				{ 'DA4_END'		, _cEnd												, NIL },;
				{ 'DA4_BAIRRO'	, _cBairro											, NIL },;
				{ 'DA4_I_DDD2'	, StrZero(Val(_cDDD),3,0)							, nil },;
				{ 'DA4_TELREC'	, _cTelComp											, nil },;
				{ 'DA4_DDD'		, StrZero(Val(_cDDDCel),3,0)						, nil },;
				{ 'DA4_TEL'		, _cCelula											, nil },;
				{ 'DA4_CGC'		, _cCPF												, NIL },;
				{ 'DA4_NUMCNH'	, _cCNH												, NIL },;
				{ 'DA4_PAI'		, _cPai												, NIL },;
				{ 'DA4_MAE'		, _cMae												, NIL },;
				{ 'DA4_RGORG'	, _cOrgRg											, NIL },; 
				{ 'DA4_RG'		, _cRg												, NIL } } 
		
		
	Endif
	

	//================================================================================
	//| Rotina de ExecAuto usando MVC                                                | 
	//================================================================================
	lMSErroAuto := !ITExecAutoDA4( aVetor , iif(_lachou,4,3) )
	
	IF lMSErroAuto
	
		DisarmTransaction()
		
		If ( __lSx8 )
			RollBackSx8()
		EndIf 
		
		_lRet := .F.     
		
	Else
	
		DBCommit()
		
		If ( __lSX8 )
			ConfirmSX8()
		EndIf
		
	Endif

End Transaction

Return( _lRet )

/*
===============================================================================================================================
Programa----------: ITExecAutoDA4
Autor-------------: Alexandre Villar
Data da Criacao---: 30/07/2014
===============================================================================================================================
Descri��o---------: Processamento do ExecAuto via MVC de acordo com a rotina padr�o
===============================================================================================================================
Parametros--------: _avetor - array com campos e dados para o execauto
					_noper - opera��o do execauto
===============================================================================================================================
Retorno-----------: lret - se conseguiu executar o execauto com sucesso
===============================================================================================================================
*/
Static Function ITExecAutoDA4( _aVetor , _nOper )

Local _oModel	:= Nil
Local _oAux		:= Nil
Local _oStruct	:= Nil
Local _nI		:= 0
Local _nPos		:= 0
Local _lRet		:= .T.
Local _aAux		:= {}
Local _aErro	:= {}

DBSelectArea( 'DA4' )
DA4->( DBSetOrder( 1 ) )

//================================================================================
//| Instancia o objeto com o modelo de dados da Rotina                           |
//================================================================================
_oModel := FWLoadModel( 'OMSA040' )

//================================================================================
//| Define a opera��o: 3 � Inclus�o / 4 � Altera��o / 5 - Exclus�o               |
//================================================================================
_oModel:SetOperation( _nOper )

//================================================================================
//| Ativa��o do Modelo de Dados                                                  |
//================================================================================
_oModel:Activate()

//================================================================================
//| Instancia o Modelo de Dados                                                  |
//================================================================================
_oAux := _oModel:GetModel( 'OMSA040_DA4' )

//================================================================================
//| Obt�m a estrutura de Dados e Campos                                          |
//================================================================================
_oStruct	:= _oAux:GetStruct()
_aAux		:= _oStruct:GetFields()

For _nI := 1 To Len( _aVetor )
	
	//================================================================================
	//| Verifica se os campos passados existem na estrutura do modelo                |
	//================================================================================
	If ( _nPos := aScan( _aAux , {|x| AllTrim( x[03] ) == AllTrim( _aVetor[_nI][01] ) } ) ) > 0
		
		//================================================================================
		//| Atribui conte�do ao campo do Model                                           |
		//================================================================================
		If !( _oModel:SetValue( 'OMSA040_DA4' , _aVetor[_nI][01] , _aVetor[_nI][02] ) )
			
			_lRet := .F.
			Exit
			
		EndIf
		
	EndIf
	
Next _nI

If _lRet

	//================================================================================
	//| Caso tenha feito a atribui��o dos dados, chama a valida��o da rotina         |
	//================================================================================
	If ( _lRet := _oModel:VldData() )
		_oModel:CommitData()
	EndIf
	
EndIf

If !_lRet
	
	//================================================================================
	//| Exibe o LOG da rotina em caso de erros                                       |
	//================================================================================
	_aErro := _oModel:GetErrorMessage()
	
	AutoGrLog( "Id do formul�rio de origem..: " + ' [' + AllToChar( _aErro[1] ) + ']' )
	AutoGrLog( "Id do campo de origem.......: " + ' [' + AllToChar( _aErro[2] ) + ']' )
	AutoGrLog( "Id do formul�rio de erro....: " + ' [' + AllToChar( _aErro[3] ) + ']' )
	AutoGrLog( "Id do campo de erro.........: " + ' [' + AllToChar( _aErro[4] ) + ']' )
	AutoGrLog( "Id do erro..................: " + ' [' + AllToChar( _aErro[5] ) + ']' )
	AutoGrLog( "Mensagem do erro............: " + ' [' + AllToChar( _aErro[6] ) + ']' )
	AutoGrLog( "Mensagem da solu��o.........: " + ' [' + AllToChar( _aErro[7] ) + ']' )
	AutoGrLog( "Valor atribu�do.............: " + ' [' + AllToChar( _aErro[8] ) + ']' )
	AutoGrLog( "Valor anterior..............: " + ' [' + AllToChar( _aErro[9] ) + ']' )
	
	MostraErro()
	
EndIf

_oModel:DeActivate()

Return( _lRet )