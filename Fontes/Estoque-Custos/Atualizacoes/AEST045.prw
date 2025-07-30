/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer     | 29/12/2019 | Nova controle da inclus�o em fases do produto - Chamado 31466
===============================================================================================================================


===============================================================================================================================
Analista         - Programador       - Inicio    - Envio      - Chamado  - Motivo da Altera��o
===============================================================================================================================
Bremmer Henrique   Igor Melga�o       24/09/2024 - 02/10/2024 - 48586    - Exclus�o de registros da SBZ ao excluir o produto.
Bremmer Henrique   Igor Melga�o       03/10/2024 - 03/10/2024 - 48586    - Exclus�o das modifica��es feitas para o Chamado 31466
===============================================================================================================================
*/
#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"

//*****************************************************************************************************
//******************* USE ESSE PONTO PARA GRAVA��ES E O A010TOK.PRW PARA VALIDA��ES *******************
//*****************************************************************************************************

/*
===============================================================================================================================
Programa----------: ITEM / AEST045.PRW
Autor-------------: Julio de Paula Paz
Data da Criacao---: 11/02/2019
Descri��o---------: Ponto de entrada no padr�o MVC chamado pela rotina de manuten��o de Produtos (Fonte: MATA010.PRX) 
                    Chamado 27996.
  					     USE ESSE PONTO PARA GRAVA��ES E O A010TOK.PRW PARA VALIDA��ES 
Parametros--------: PARAMIXB = parametros padr�es de pontos de entrada Totvs.
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function ITEM() 
Local _aParam := PARAMIXB
Local _xRet := .T.
Local _oObj := ''
Local _cIdPonto   := ''  
Local _cIdModel := ''   

If _aParam <> NIL
   _oObj     := _aParam[1]
   _cIdPonto := _aParam[2]
   _cIdModel := _aParam[3]
   _nOper	 := _oObj:GetOperation()
      
   If _cIdPonto == 'MODELPOS'
      /*
      'Chamada na valida��o total do modelo (MODELPOS).' 
      */

   ElseIf _cIdPonto == 'MODELVLDACTIVE' //Chamada na valida��o da ativa��o do Model.


   ElseIf _cIdPonto == 'FORMPOS'
      /*   
      'Chamada na valida��o total do formul�rio (FORMPOS).'
      */
   ElseIf _cIdPonto == 'FORMLINEPRE'
      /*   
      If aParam[5] == 'DELETE'
         //
      EndIf
      
      'Chamada na pr� valida��o da linha do formul�rio (FORMLINEPRE). Onde esta se tentando deletar uma linha'
      '� um FORMGRID.'
      */
      
   ElseIf _cIdPonto == 'FORMLINEPOS'
      /*
      'Chamada na valida��o da linha do formul�rio (FORMLINEPOS).' 
      '� um FORMGRID.'
      */
   ElseIf _cIdPonto == 'MODELCOMMITTTS'
      /*
      'Chamada apos a grava��o total do modelo e dentro da transa��o (MODELCOMMITTTS).' 
      */

      //==============================================================================
      // Chama antigo ponto de entrada do fonte MATA010 da altera��o de produtos.
      //==============================================================================
      If _nOper == MODEL_OPERATION_INSERT 
         U_AEST045I() //U_MT010INC()
      ElseIf _nOper == MODEL_OPERATION_UPDATE
         U_AEST045M() //U_MT010ALT()
      ElseIf _nOper == MODEL_OPERATION_DELETE 
         U_AEST045E() 
      EndIf 

//*****************************************************************************************************
//******************* USE ESSE PONTO PARA GRAVA��ES E O A010TOK.PRW PARA VALIDA��ES *******************
//*****************************************************************************************************
      
   ElseIf _cIdPonto == 'MODELCOMMITNTTS'
      /*
     'Chamada apos a grava��o total do modelo e fora da transa��o(MODELCOMMITNTTS).' 
      */
   //ElseIf cIdPonto == 'FORMCOMMITTTSPRE'
   ElseIf _cIdPonto == 'FORMCOMMITTTSPOS'
      /*
     'Chamada apos a grava��o da tabela do formul�rio (FORMCOMMITTTSPOS).' 
      */
   ElseIf _cIdPonto == 'MODELCANCEL'  
      /*
      'Chamada no Bot�o Cancelar (MODELCANCEL).'
      */
   ElseIf _cIdPonto == 'MODELVLDACTIVE'
      /*
      'Chamada na valida��o da ativa��o do Model.' 
      */
   ElseIf _cIdPonto == 'BUTTONBAR'
      /*
      'Adicionando Bot�o na Barra de Bot�es (BUTTONBAR).'
      */
   EndIf
EndIf
	
Return _xRet 


/*
===============================================================================================================================
Programa----------: AEST045E 
Autor-------------: Igor Melga�o
Data da Criacao---: 24/09/2024  
===============================================================================================================================
Descri��o---------: Ponto de entrada excluir indicadores relativos a ele	
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function AEST045E()

Local _aArea	:= GetArea()
Local _cEmpCor	:= cEmpAnt  

//====================================================================================================
// Percorrer todas as filiais
//====================================================================================================
DBSelectArea("SM0")
SM0->( DBGotop() )
While ( SM0->( !Eof() ) .And. _cEmpCor == SM0->M0_CODIGO )

	DBSelectArea("SBZ")
	SBZ->( DBSetOrder(1) )
	If SBZ->( DBSeek( alltrim(SM0->M0_CODFIL) + SB1->B1_COD ) )
	
		RecLock("SBZ",.F.)
      DbDelete()
		MsUnlock()

	EndIf

SM0->( DBSkip() )
EndDo

RestArea(_aArea)

Return()


/*
===============================================================================================================================
Programa----------: AEST045M
Autor-------------: Frederico O. C. Jr 
Data da Criacao---: 28/08/2008  
===============================================================================================================================
Descri��o---------: Ponto de entrada para validar alteracao do produto e atualizar indicadores relativos a ele	(Substitui��o do MT010ALT)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function AEST045M()

Local _aArea	:= GetArea()
Local _cEmpCor	:= cEmpAnt  

//====================================================================================================
// Percorrer todas as filiais
//====================================================================================================
DBSelectArea("SM0")
SM0->( DBGotop() )
While ( SM0->( !Eof() ) .And. _cEmpCor == SM0->M0_CODIGO )

	DBSelectArea("SBZ")
	SBZ->( DBSetOrder(1) )
	If SBZ->( DBSeek( alltrim(SM0->M0_CODFIL) + SB1->B1_COD ) )
	
		RecLock("SBZ",.F.)
			SBZ->BZ_ORIGEM  := SB1->B1_ORIGEM	//07/02/13 - Talita - Incluido valida��o para preencher as informa��es do campo BZ_ORIGEM
		    SBZ->BZ_TIPO   	:= SB1->B1_TIPO     //10/09/21 - Alex -Incluida a grava��o conforme chamado 37783
			SBZ->BZ_I_DESCR	:= SB1->B1_DESC		//COMENTADO GUILHERME - 17/12/2012 - Linha descomentada por Talita Teixeira conforme chamado 2518 -  No dia 13/02/13
			SBZ->BZ_IPI		:= SB1->B1_IPI		//27/02/13 - Talita - Incluido campo de IPI conforme chamado 2719 
			SBZ->BZ_I_DETPR := SB1->B1_I_DESCD	//21/05/13 - Talita - Incluido a grava��o do campo BZ_I_DETPR de acordo com a informa��o do B1_I_DESCD. Chamado: 3354
		  	SBZ->BZ_PIS		:= SB1->B1_PIS		//08/08/13 - Talita - Incluido a grava��o do campo BZ_PIS; BZ_COFINS; BZ_CSLL e BZ_IRRF de acordo com a informa��o do B1_PIS, B1_COFINS, B1_CSLL, B1_IRRF. Chamado: 3968
			SBZ->BZ_COFINS	:= SB1->B1_COFINS	//08/08/13 - Talita - Incluido a grava��o do campo BZ_PIS; BZ_COFINS; BZ_CSLL e BZ_IRRF de acordo com a informa��o do B1_PIS, B1_COFINS, B1_CSLL, B1_IRRF. Chamado: 3968
			SBZ->BZ_CSLL	:= SB1->B1_CSLL		//08/08/13 - Talita - Incluido a grava��o do campo BZ_PIS; BZ_COFINS; BZ_CSLL e BZ_IRRF de acordo com a informa��o do B1_PIS, B1_COFINS, B1_CSLL, B1_IRRF. Chamado: 3968
			SBZ->BZ_IRRF	:= SB1->B1_IRRF		//08/08/13 - Talita - Incluido a grava��o do campo BZ_PIS; BZ_COFINS; BZ_CSLL e BZ_IRRF de acordo com a informa��o do B1_PIS, B1_COFINS, B1_CSLL, B1_IRRF. Chamado: 3968 
			SBZ->BZ_ALIQISS	:= SB1->B1_ALIQISS	//11/03/14 - Lucas - Incluido a grava��o do campo BZ_ALIQISS e BZ_CODISS de acordo com a informa��o do B1_ALIQISS e B1_CODISS. Chamado: 5690 
			SBZ->BZ_CODISS	:= SB1->B1_CODISS	//11/03/14 - Lucas - Incluido a grava��o do campo BZ_ALIQISS e BZ_CODISS de acordo com a informa��o do B1_ALIQISS e B1_CODISS. Chamado: 5690
		    SBZ->BZ_PCOFINS := SB1->B1_PCOFINS	//15/07/15 - Josu� - Incluida a grava��o conforme chamado 10903
		    SBZ->BZ_PPIS    := SB1->B1_PPIS		//15/07/15 - Josu� - Incluida a grava��o conforme chamado 10903
		MsUnlock()

	EndIf

SM0->( DBSkip() )
EndDo

//====================================================================================================
// Grava os dados dos Produtos nas tabelas de muro para integra��o com o sistema RDC.
//====================================================================================================
U_AOMS078G("SB1")

RestArea(_aArea)

Return()


/*
===============================================================================================================================
Programa----------: AEST045I
Autor-------------: Frederico O. C. Jr 
Data da Criacao---: 28/08/2008  
===============================================================================================================================
Descri��o---------: Ponto de entrada para, na inclusao de produto, gerar indicadores de produto	(Substitui��o do MT010INC)	 
===============================================================================================================================
Parametros--------: nOpcao - n�o utilizado
					     _oProcess - n�o utilizado
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AEST045I(nOpcao,_oProcess)

Local aArea		:= GetArea()
Local cEmpCor	:= cEmpAnt  , _nk

Local aHeader := {}
Local aStruct := {}
Local nCont	  := 0
Local nI

Private cProduto:= SB1->B1_COD
	
	//Inicio da valida��o para preenchimento de campos na tabela SBZ conforme rotina padr�o. Chamado: 2518
	_acamps := SBZ->(Dbstruct()) 

	For _nk := 1 to len(_acamps)
	   
	  If Getsx3cache(_acamps[_nk][1],"X3_RELACAO") <> ' ' 
		nCont++
   		AADD(aHeader,{_acamps[_nk][1]})
   	   	AADD(aStruct,{Getsx3cache(_acamps[_nk][1],"X3_RELACAO")}) 
   	  EndIf
   
	Next  
	
	SM0->( DBGotop() )

 	While SM0->(!Eof()) .and. cEmpCor == SM0->M0_CODIGO   

	  // Incluir Indicador de Produto (SBZ)
	  dbSelectArea("SBZ")

   	  RecLock("SBZ",.T.)
	  SBZ->BZ_FILIAL	:= alltrim(SM0->M0_CODFIL)
	  SBZ->BZ_COD		:= SB1->B1_COD
	  SBZ->BZ_TIPO   	:= SB1->B1_TIPO
	  SBZ->BZ_LOCPAD	:= SB1->B1_LOCPAD
	  SBZ->BZ_ORIGEM	:= SB1->B1_ORIGEM 				
	  SBZ->BZ_I_DESCR	:= SB1->B1_DESC 
	  SBZ->BZ_IPI		:= SB1->B1_IPI 
	  SBZ->BZ_I_DETPR   := SB1->B1_I_DESCD 
	  SBZ->BZ_PIS		:= SB1->B1_PIS
	  SBZ->BZ_COFINS	:= SB1->B1_COFINS
	  SBZ->BZ_CSLL	    := SB1->B1_CSLL
	  SBZ->BZ_IRRF	    := SB1->B1_IRRF
	  SBZ->BZ_ALIQISS	:= SB1->B1_ALIQISS
	  SBZ->BZ_CODISS	:= SB1->B1_CODISS
	  SBZ->BZ_PCOFINS   := SB1->B1_PCOFINS
	  SBZ->BZ_PPIS      := SB1->B1_PPIS
	
	  For nI:= 1 to nCont 
			  
  	    If aHeader[nI][1] <> 'BZ_COD' .AND. aHeader[nI][1] <> 'BZ_LOCPAD' .AND. aHeader[nI][1] <> 'BZ_ORIGEM' 
		  if aHeader[nI][1] <> 'BZ_I_DESCR' .AND. aHeader[nI][1] <> 'BZ_PIS' .AND. aHeader[nI][1] <> 'BZ_COFINS' 
		    if aHeader[nI][1] <> 'BZ_CSLL' .AND. aHeader[nI][1] <> 'BZ_IRRF' .AND. aHeader[nI][1] <> 'BZ_PCOFINS' .and. aHeader[nI][1] <> 'BZ_PPIS' 
			     
		      SBZ->&(aHeader[nI][1]) := M->&(aStruct[nI][1]) 
			    
		    Endif
		  Endif
		EndIf
 		 	
 	  Next nI  
		   
	  SBZ->( MsUnlock() )
   	  SM0->( dbSkip() )
		
 	Enddo		
   
	RestArea(aArea)                                                            
	
    //====================================================================================
    // Grava os dados dos produtos nas tabelas de muro para integra��o com o sistema RDC.
    //====================================================================================
    U_AOMS078G("SB1")
  
Return    
