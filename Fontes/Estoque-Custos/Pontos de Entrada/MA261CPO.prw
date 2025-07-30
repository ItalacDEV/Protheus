/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           |
------------------:------------:----------------------------------------------------------------------------------------------:
 Josu� Danich     | 21/06/2016 | Incluido campo D3_I_TPTRS e fun��o de controle - Chamado 20539                               |
------------------:------------:----------------------------------------------------------------------------------------------:
 Josu� Danich     | 28/06/2016 | Ajuste no campo D3_I_TPTRS - Chamado 20622                                                   |
------------------:------------:----------------------------------------------------------------------------------------------:
 Julio Paz        | 19/06/2023 | Cria��o de campo/ajuste fonte p/exibir descri��o do campo Tipo de Movimenta��o.Chamado 43825 |
------------------:------------:----------------------------------------------------------------------------------------------:
 Andr� Lisboa     | 12/03/2024 | Chamado 46558 - Altera��o na exibi��o campos motivo transf/descr transf/ incluido campo setor|
------------------:------------:----------------------------------------------------------------------------------------------:
 Julio Paz        | 20/05/2024 | Chamado 46558 - Desenvolvimento de melhorias nas rotinas de transfer�ncia de Produtos.       |
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)

/*
===============================================================================================================================
Programa----------: MA261CPO 
Autor-------------: Talita Teixeira
Data da Criacao---: 09/05/2013 
===============================================================================================================================
Descri��o---------: Ponto de entrada responsavel pela inclus�o de campos na tela de inclus�o da transf mod 2.Chamado 3254
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function MA261CPO()

Local aTam := {} 
//Local _aBackHead := {}
//Local _aCloneHed := {}
//Local _nI 
Local _cFilVld34 := U_ITGETMV( 'IT_FILVLD34','')
/*
_aBackHead := aClone(aHeader)

For _nI := 1 To Len(aHeader)
    // D3_QTSEGUM // Inserir D3_I_OBS ap�s este campo
    Aadd(_aCloneHed,aHeader[_nI])

    If AllTrim(aHeader[_nI,2]) == "D3_QTSEGUM"
       aTam := TamSX3('D3_I_OBS')
       Aadd(_aCloneHed, {'Observa��o'  ,'D3_I_OBS'   , PesqPict('SD3', 'D3_I_OBS'   , aTam[1]) , aTam[1], aTam[2], '', USADO, 'C', 'SD3', ''})
    EndIf 
Next 

aHeader := AClone(_aCloneHed)
*/

aTam := TamSX3('D3_I_OBS')
Aadd(aHeader, {'Observa��o'  ,'D3_I_OBS'   , PesqPict('SD3', 'D3_I_OBS'   , aTam[1]) , aTam[1], aTam[2], '', USADO, 'C', 'SD3', ''})

If ! xFilial("SD3") $ _cFilVld34 // Este campo n�o deve estar dispon�vel para filiais de valida��o do armaz�m 34 (Descarte).
   Aadd(aHeader, {'Tipo TRS'   , 'D3_I_TPTRS' , PesqPict('SD3', 'D3_I_TPTRS' , 1) , 1, 0, '', USADO, 'C', 'SD3', ''})        
   Aadd(aHeader, {'Descric.Tipo TRS','D3_I_DSCTM' , PesqPict('SD3', 'D3_I_DSCTM' , 1) , 1, 0, '', USADO, 'C', '', ''})  
EndIf 

If xFilial("SD3") $ _cFilVld34 // Este campo n�o deve estar dispon�vel para filiais de valida��o do armaz�m 34 (Descarte).
   Aadd(aHeader, {'Mot.Tran.Ref','D3_I_MOTTR' , PesqPict('SD3', 'D3_I_MOTTR' , 1) , 8, 0, '', USADO, 'C', 'SD3', ''})        
   Aadd(aHeader, {'Des.Mot.Tr.R','D3_I_DSCMT' , PesqPict('SD3', 'D3_I_DSCMT' , 1) , 40, 0, '', USADO, 'C', ''   , ''})  

   Aadd(aHeader, {'Origem Trf.' ,'D3_I_SETOR' , PesqPict('SD3', 'D3_I_SETOR' , 40) , 40, 0, '', USADO, 'C', '', ''}) // Aadd(aHeader, {'Setor Trf.'  ,'D3_I_SETOR' , PesqPict('SD3', 'D3_I_SETOR' , 6) , 6, 0, '', USADO, 'C', '', ''})       
   Aadd(aHeader, {'Destino'     ,'D3_I_DESTI' , PesqPict('SD3', 'D3_I_DESTI' , 40) , 40, 0, '', USADO, 'C', '', ''}) // Aadd(aHeader, {'Motiv.Transf','D3_I_MOTIV' , PesqPict('SD3', 'D3_I_MOTIV' , 6) , 6, 0, '', USADO, 'C', '', ''})          
EndIf 

//aTam := TamSX3('D3_I_OBS')
//Aadd(aHeader, {'Observa��o'  ,'D3_I_OBS'   , PesqPict('SD3', 'D3_I_OBS'   , aTam[1]) , aTam[1], aTam[2], '', USADO, 'C', 'SD3', ''})


Return 

/*
===============================================================================================================================
Programa----------: IT_TPTRS 
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 21/06/2017
===============================================================================================================================
Descri��o---------: Controla when do campo D3_I_TPTRS
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T. se campo � edit�vel ou .F. se campo n�o � edit�vel
===============================================================================================================================
*/

User Function IT_TPTRS()

Local _lret := .F.
Local _nLocal := 0
Local _oModel, _oModelGrid

If funname() == "MATA261"

	_nLocal := aScan(aHeader,{|x| AllTrim(x[1]) == "Armazem Destino"	})
	
	If acols[n][_nLocal] == '34'    
	
		_lret := .T.
		
	Endif
	
Endif

If funname() == "MATA260"

	If M->D3_LOCAL == '34'

		_lret := .T.
		
	Endif
	
Endif


If funname() == "MATA311" // ISINCALLSTACK("MATA311")
   _oModel := FwModelActivete()
   _oModelGrid := _oModel:GetModel('NNTDETAIL')

   _cArmazemD  := _oModelGrid:GetValue("NNT_LOCLD") 

   If _cArmazemD == '34' // M->NNT_LOCLD == '34'
      _lret := .T.
   EndIf 

EndIf 

Return _lret
