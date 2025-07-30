/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           |
------------------:------------:----------------------------------------------------------------------------------------------:
 Julio Paz        | 21/03/2019 | Padroniza��o de fontes para funcionar com o novo servidor Totvs Loboguar�. Chamado 28557.    |
===============================================================================================================================
*/

#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa--------: MA080BUT
Autor-----------: Alexandre Villar
Data da Criacao-: 02/10/2015
===============================================================================================================================
Descri��o-------: P.E. na abertura da tela de manuten��o do cadastro de TES
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/

User Function MA080BUT()
Local _nI

Private aHeader, aCols

Public _aDadSF4	:= {}
Public _aDadCC7	:= {}

//====================================================================================================
// Validacao para inicializar as vari�veis para validar as altera��es realizadas no cadastro da TES
//====================================================================================================
If Altera
   //============================================================================
   // Montagem do aheader                                                        
   //=============================================================================
   aHeader := {}
   aCols   := {}
   FillGetDados(1,"SF4",1,,,{||.T.},,,,,,.T.)
   //                          1                    2               3              4               5                6             7        8              9                 10 
   // AADD(aHeader, {Alltrim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()", USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})

   _aDadSF4 := {}
   _aDadCC7 := {}

   For _nI := 1 To Len(aHeader)
       
       If X3USO( aHeader[_nI,7] ) .And. aHeader[_nI,10] <> 'V'
		  aAdd( _aDadSF4 , { aHeader[_nI,2] , &( 'SF4->'+ AllTrim( aHeader[_nI,2] ) ) } )
	   EndIf
   Next
   
   //=============================================================================
   // Montagem do aheader                                                        
   //=============================================================================
   aHeader := {}
   aCols   := {}
   FillGetDados(1,"CC7",1,,,{||.T.},,,,,,.T.)
   //                          1                    2               3              4               5                6             7        8              9                 10 
   // AADD(aHeader, {Alltrim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()", USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
	
   DBSelectArea('CC7')
   CC7->( DBSetOrder(1) )
   If CC7->( DBSeek( SF4->( F4_FILIAL + F4_CODIGO ) ) )
		
      While CC7->( !Eof() ) .And. CC7->( CC7_FILIAL + CC7_TES ) == SF4->( F4_FILIAL + F4_CODIGO )
         For _nI :=1 To Len(aHeader)
                    
             If X3USO( aHeader[_nI,7] ) .And. aHeader[_nI,10] <> 'V' .And. ! (AllTrim(aHeader[_nI,2]) $ "CC7_ALI_WT/CC7_REC_WT")
				aAdd( _aDadCC7 , { aHeader[_nI,2] , &( 'CC7->'+ AllTrim( aHeader[_nI,2] ) ) } )
			 EndIf
         Next

         CC7->( DBSkip() )
      EndDo
   EndIf

EndIf

Return()