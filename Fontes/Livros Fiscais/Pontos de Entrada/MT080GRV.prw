/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Talita        | 17/07/2013 | Alterada valida��o para inclus�o da TES que era feita pelo par�metro IT_VCADTES e agora ser�
              |            | feita no campo ZZL_VCADTE. Chamado 3749
-------------------------------------------------------------------------------------------------------------------------------
Alexandre V.  | 02/10/2015 | Ajustes para grava��o do LOG de altera��es e bloqueio da TES para libera��o Fiscal, Estoque
              |            | e Pis/Cofins. Chamado 9688
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 03/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"

/*
===============================================================================================================================
Programa--------: MT080GRV
Autor-----------: Tiago Correa
Data da Criacao-: 20/08/2008
===============================================================================================================================
Descri��o-------: P.E. ap�s a grava��o dos dados da TES
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function MT080GRV()

Local _aArea 	:= GetArea()
Local _aDadLog	:= {}
Local _nPosBlq	:= 0
Local _nI		:= 0

//====================================================================================================
// Verifica tratativas na opera��o de inclus�o
//====================================================================================================
If Inclui
	If SF4->F4_MSBLQL <> '1'
		SF4->( RecLock( 'SF4' , .F. ) )
		SF4->F4_MSBLQL	:= '1'
		SF4->F4_I_BLFPE	:= 'NNN'
		SF4->( MsUnLock() )
	EndIf
	
	//====================================================================================================
	// Monta a estrutura para a grava��o do Log de inclus�o
	//====================================================================================================
	aAdd( _aDadLog , {	'F4_FILIAL'	, SF4->F4_FILIAL	, '' } )
	aAdd( _aDadLog , {	'F4_CODIGO'	, SF4->F4_CODIGO	, '' } )
	
	U_ITGrvLog( _aDadLog , 'SF4' , 1 , SF4->( F4_FILIAL + F4_CODIGO ) , 'I' , RetCodUsr() , Date() , Time() )
	
	MessageBox(	'A TES � inclu�da bloqueada e dever� ser solicitada a libera��o pelos respons�veis das �reas Fiscal, PIS/COFINS e Estoque. ' , 'MT080GRV01' , 48 )
	
	//====================================================================================================
	// Chama a replica��o da TES para todas as Filiais
	//====================================================================================================
	GeraSF4()
EndIf

//====================================================================================================
// Verifica tratativas na opera��o de altera��o
//====================================================================================================
If Altera .And. Type('_aDadSF4') == 'A' .And. !Empty( _aDadSF4 )
	For _nI := 1 To Len(_aDadSF4)
		If _aDadSF4[_nI][02] <> &( 'SF4->'+_aDadSF4[_nI][01] )
			aAdd( _aDadLog , { _aDadSF4[_nI][01] , _aDadSF4[_nI][02] , &( 'SF4->'+_aDadSF4[_nI][01] ) } )
		EndIf
	Next _nI
	
	If !Empty( _aDadLog )
		U_ITGrvLog( _aDadLog , 'SF4' , 1 , SF4->( F4_FILIAL + F4_CODIGO ) , 'A' , RetCodUsr() , Date() , Time() )
		_nPosBlq := aScan( _aDadLog , {|x| Upper(AllTrim(x[01])) == 'F4_MSBLQL' } )
		
		If _nPosBlq > 0 .And. _aDadLog[_nPosBlq][03] == '1'
			SF4->( RecLock( 'SF4' , .F. ) )
			SF4->F4_MSBLQL	:= '1'
			SF4->F4_I_BLFPE	:= 'NNN'
			SF4->( MsUnLock() )
		
			MessageBox(	'As altera��es realizadas bloqueiam o cadastro da TES e dever� ser solicitada a libera��o pelos respons�veis das �reas Fiscal, PIS/COFINS e Estoque. ' , 'MT080GRV02' , 48 )
			U_ITListBox( 'Altera��es no cadastro de TES:' , {'Campo','Conte�do Orig.','Novo Conte�do'} , _aDadLog , .F. , 1 )
		EndIf
	EndIf
EndIf

RestArea(_aArea)

Return

/*
===============================================================================================================================
Programa--------: GeraSF4
Autor-----------: Tiago Correa
Data da Criacao-: 20/08/2008
===============================================================================================================================
Descri��o-------: Rotina para replicar a TES para todas as Filiais
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function GeraSF4()

Local _cEmpCor	:= cEmpAnt
Local _cFilCor	:= cfilAnt

DBSelectArea("SM0")
SM0->( DBGotop() )
While SM0->( !Eof() ) .And. _cEmpCor == SM0->M0_CODIGO
	If	_cFilCor <> ALLTRIM(SM0->M0_CODFIL)
		DBSelectArea("SF4")
		RecLock( "SF4" , .T. )
		
			F4_FILIAL	:=	ALLTRIM(SM0->M0_CODFIL)
			F4_CODIGO	:=	M->F4_CODIGO
			F4_TIPO		:=	M->F4_TIPO
			F4_ICM 		:=	M->F4_ICM
			F4_IPI 		:=	M->F4_IPI
			F4_CREDICM 	:=	M->F4_CREDICM
			F4_CREDIPI 	:=	M->F4_CREDIPI
			F4_DUPLIC 	:=	M->F4_DUPLIC
			F4_ESTOQUE 	:=	M->F4_ESTOQUE
			F4_CF 		:=	M->F4_CF
			F4_TEXTO 	:=	ALLTRIM(M->F4_TEXTO)
			F4_PODER3 	:=	M->F4_PODER3
			F4_LFICM  	:=	M->F4_LFICM
			F4_LFIPI  	:=	M->F4_LFIPI
			F4_DESTACA  :=	M->F4_DESTACA
			F4_INCIDE  	:=	M->F4_INCIDE
			F4_COMPL 	:=	M->F4_COMPL
			F4_I_GTES  	:=	M->F4_I_GTES
			F4_FINALID	:=	M->F4_FINALID
			F4_MSBLQL	:=	"1"
			F4_I_BLFPE	:=	"NNN"
			
		MsUnlock()
	
	EndIf

	SM0->( DBSkip() )
Enddo

Return