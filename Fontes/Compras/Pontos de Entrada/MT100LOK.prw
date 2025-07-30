/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 20/12/2019 | Criar fun��o para calcular CAT 42/2018 na digita��o dos itens da nota de entrada. Chamado 30971.
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 16/01/2020 | Criada valida��o para n�o executar quando for chamado pelo TOTVS Colabora��o. Chamado 23984
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 02/07/2020 | Tratado para n�o ser executado quando chamado pelo Reprocessar. Chamado 33422
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: MT100LOK
Autor-------------: Tiago Correa Castro
Data da Criacao---: 09/01/2009
===============================================================================================================================
Descri��o---------: Ponto de entrada na validacao da linha digitada no documento de entrada
					Localiza��o : Function A119LinOk e A119TudOK - Fun��o de Valida��o ( linha OK da Getdados) para Inclus�o/
					Altera��o do item da NF de Despesas de Importa��o e A103LinOk - Fun��o de Valida��o da LinhaOk.
					Em que Ponto: No final das valida��es ap�s a confirma��o da inclus�o ou altera��o da linha, antes da 
					grava��o da NF de Despesas de Importa��o.
					Finalidade: Permite alterar itens da NF de Despesas de Importa��o.
===============================================================================================================================
Parametros--------: ExpL1 -> L -> Sempre .T., indicando que as valida��es est�o OK at� este ponto.
===============================================================================================================================
Retorno-----------: .T. = Permite a confirmacao da digitacao da linha
------------------: .F. = Nao Permite a confirmacao da digitacao da linha
===============================================================================================================================
*/
User Function MT100LOK()

Local _lRet   	:= .T.
Local _aArea	:= GetArea()
Local _cCodArmaz:=	aScan( aHeader , {|x| UPPER( Alltrim( x[2] ) ) == "D1_LOCAL"	} )
Local _cCodPro	:=	aScan( aHeader , {|x| UPPER( Alltrim( x[2] ) ) == "D1_COD"	} )
Local _lRLeite	:= !AllTrim( Upper( FUNNAME() ) ) $"U_MGLT009/MGLT010"

//Tratado para que o PE n�o seja executado indevidamente at� a an�lise da TOTVS
If !FWIsInCallStack("SCHEDCOMCOL")
   //========================================================================================
   //Valida��o de usu�rio x filial x armaz�m
   //========================================================================================

   If _lRLeite .And. !aCols[n][Len(aHeader)+1] //N�o verifica linhas deletadas
      
      //============================================
      //Valida armaz�mxprodutoxfilialxusu�rio
      //============================================
      _lRet := U_ACFG004E(alltrim(RetCodUsr()), alltrim(xFilial("SD1")), alltrim(acols[n][_cCodArmaz]),alltrim(acols[n][_ccodPro]),.T.)[1]
      
   EndIf

   If Inclui
      U_MT100CAT() 
   EndIf
EndIf

RestArea(_aArea)

Return( _lRet )             

/*
===============================================================================================================================
Programa----------: MT100CAT
Autor-------------: Julio de Paula Paz
Data da Criacao---: 20/12/2019
===============================================================================================================================
Descri��o---------: Calcula o CAT 42/2018 dos itens no momento da digita��o e l� as aliquotas/margens de cadastro.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MT100CAT()    
Local _nPosTes // , _nPosGrupo
                                     
Local _nPosBDes, _nPosIDes, _nPosADes
Local _nPosTot, _nPosVIcm
Local _cGrupoP

Begin Sequence            
   _nPosTes   := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="D1_TES"}) 
   //_nPosGrupo := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="D1_GRUPO"})  
   _nPosProd  := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="D1_COD"}) 
   _nPosBDes  := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="D1_BASNDES"}) 
   _nPosIDes  := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="D1_ICMNDES"}) 
   _nPosADes  := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="D1_ALQNDES"}) 
   _nPosTot   := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="D1_TOTAL"}) 
   _nPosVIcm  := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="D1_VALICM"}) 
       
   _cGrupoP   := Posicione("SB1",1,xFilial("SB1")+Acols[N,_nPosProd],"B1_GRUPO") 
   
   //=====================================================================================================
   // Atualiza campos da CAT 42/2018
   //===================================================================================================== 
   ZM2->(DbSetOrder(1)) // ZM2_FILIAL+ZM2_TES+ZM2_GRUPO

   If ZM2->(DbSeek(xFilial("ZM2")+Acols[N,_nPosTes]+_cGrupoP))   
      _nBasest := ZM2->ZM2_MARGEM 
      _nAliqn  := ZM2->ZM2_ALIQUO 

	  If _nBasest > 0
	     Acols[N,_nPosBDes] := Acols[N,_nPosTot] * _nBasest
	     Acols[N,_nPosIDes] := (Acols[N,_nPosTot] * _nBasest * (_naliqn/100)) - Acols[N,_nPosVIcm]
	     Acols[N,_nPosADes] := _nAliqn
      EndIf
   Endif

End Sequence

Return Nil