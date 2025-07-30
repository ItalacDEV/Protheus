/* 
================================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
================================================================================================================================
 Autor        |    Data    |                              Motivo
--------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 17/09/2019 | Chamado 30543. Ajuste para ignorar a funcao M520_Valida.
Jerry         | 03/11/2020 | Chamado 34566. Valida��o do Pre�o de Vendas conforme o Peso do Pedido.
Jerry         | 01/12/2020 | Chamado 34860. Ajuste de valida��es de origem Efetiva��o Portal/RDC/Troca Nota e Regras de Pre�o.
Jerry         | 19/02/2021 | Chamado 35610. Corrigido Fun��o de Busca de Tabela de Pre�o.
Jerry         | 29/04/2022 | Chamado 38883. Ajuste na Efetiva��o Automatica Pedido Portal retirando paradas em tela.
===================================================================================================================================================================
Analista         - Programador     - Inicio     - Envio    - Chamado - Motivo da Altera��o
===================================================================================================================================================================
Vanderlei Alves  - Alex Wallauer   - 09/06/25   - 10/06/25 - 45229   - Tratamento para validar FWIsInCallStack("U_AOMS085B") junto com FWISINCALLSTACK("U_ALTERAP")
===================================================================================================================================================================
*/ 

#include "protheus.ch"  
#include "topconn.ch"
#include "rwmake.ch"

#DEFINE _ENTER CHR(13) + CHR(10)
 
/*
===============================================================================================================================
Programa--------: AOMS017
Autor-----------: Frederico O. C. Jr
Data da Criacao-: 02/10/2008
===============================================================================================================================
Descri��o-------: Preenchimentos dos campos de endereco de entrega e condi��o de pagto do Pedido de Venda
===============================================================================================================================
Parametros------: _ntipo - 1 muda retorno para .T.
===============================================================================================================================
Retorno---------: cret - estado do cliente ou fornecedor do pedido de vendas
===============================================================================================================================
*/
User Function AOMS017(_ntipo)
 
Local aArea    := GetArea() 
Local aAreaSA1 := SA1->(GetArea())
Local aAreaSA3 := SA3->(GetArea())
Local aAreaSC5 := SC5->(GetArea())
Local aAreaACY := ACY->(GetArea())
Local cRet	   := ""
Local _ccond   := ""
Local _cproduto := ""
Local nPosPro:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"	})
Local _nhi := 0
Local _cGrupoP  := ""
Local _cTipoProd:= ""
Local _laoms074 := .F.
Local _l108     := .F.
Local _lAoms112 := .F.

Default _ntipo := 0


//Se veio do webservice j� retorna .T.
If FWIsInCallStack("U_ALTERAP") .or. FWIsInCallStack("U_INCLUIC") .or. FWIsInCallStack("U_AOMS085B")
	_laoms074 := .T.
Endif

//Se veio da rotina de exclus�o autom�tica de pedidos de venda j� retorna .T.
If FWIsInCallStack("U_AOMS108")
	_l108 := .T.
Endif 

//Se esta sendo chamado via AOMS112/MOMS050 (Central Pedido Portal / Efetiva��ao Automatica)
If FWIsInCallStack("U_AOMS112") .or. FWIsInCallStack("U_MOMS050")
	_lAoms112 := .T.
Endif
 
If !FWIsInCallStack("U_AOMS032")

	//=========================================================
	//Se o tipo do pedido de venda for
	//Utiliza Fornecedor  ou   Devolucao de compras            
	//=========================================================                
	If M->C5_TIPO == 'B' .Or. M->C5_TIPO == 'D' 

		
		dbSelectArea("SA2")
		SA2->(dbSetOrder(1))
		If ( SA2->(dbSeek(xFilial("SA2")+M->C5_CLIENT+M->C5_LOJAENT)))
			
			cRet 			:= SA2->A2_EST
			M->C5_I_NOME	:= SA2->A2_NOME
			M->C5_I_FANTA	:= SA2->A2_NREDUZ
			M->C5_I_CMUN	:= SA2->A2_COD_MUN
			M->C5_I_MUN		:= SA2->A2_MUN
			M->C5_I_CEP		:= SA2->A2_CEP
			M->C5_I_END		:= SA2->A2_END
			M->C5_I_BAIRR	:= SA2->A2_BAIRRO
			M->C5_I_DDD		:= SA2->A2_DDD
			M->C5_I_TEL		:= SA2->A2_TEL
			M->C5_I_GRPVE   := ""
			M->C5_I_NOMRD   := ""    
		
		EndIf	
			
	Else

		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		If ( SA1->(dbSeek(xFilial("SA1")+M->C5_CLIENT+M->C5_LOJAENT)))
			
			cRet 			:= SA1->A1_EST
			M->C5_I_NOME	:= SA1->A1_NOME
			M->C5_I_FANTA	:= SA1->A1_NREDUZ
			M->C5_I_CMUN	:= SA1->A1_COD_MUN
			M->C5_I_MUN		:= SA1->A1_MUN
			M->C5_I_CEP		:= SA1->A1_CEP 
			M->C5_I_END		:= SA1->A1_END
			M->C5_I_BAIRR	:= SA1->A1_BAIRRO
			M->C5_I_DDD		:= SA1->A1_DDD
			M->C5_I_TEL		:= SA1->A1_TEL
			M->C5_I_GRPVE   := SA1->A1_GRPVEN
			M->C5_I_NOMRD   := POSICIONE("ACY",1,xFILIAL("ACY")+SA1->A1_GRPVEN,"ACY_DESCRI")
			M->C5_I_V1NOM   := POSICIONE("SA3",1,xFILIAL("SA3")+M->C5_VEND1,"A3_NOME")
			M->C5_I_V2NOM   := POSICIONE("SA3",1,xFILIAL("SA3")+M->C5_VEND2,"A3_NOME")
			M->C5_I_V3NOM   := POSICIONE("SA3",1,xFILIAL("SA3")+M->C5_VEND3,"A3_NOME")
			M->C5_I_HORP	:= SA1->A1_I_HORP
			
			If empty(M->C5_I_AGEND) .And. !empty(Alltrim(SA1->A1_I_AGEND))
			
				M->C5_I_AGEND	:= SA1->A1_I_AGEND
				
			Endif
			
			M->C5_I_TIPCA	:= SA1->A1_I_TIPCA
			M->C5_I_CHPCL	:= SA1->A1_I_CHAPA
		
			//===============================================================================
			//Localiza se existe condi��o de pagamento personalizada e preenche C5_CONDPAG 
			//===============================================================================
			
			//=============================================================================================================
			//Verifica condi��o personalizada para ultimo produto do acols n�o deletado
			//Como tem valida��o para s� permitir uma condi��o de pagto no pedido todo verificando a cada entrada de linha
			// n�o h� risco de ter condi��o de pagamento diferente da condi��o indicada pelo �ltimo produto do pedido
			//==============================================================================================================
			 
			_cproduto := ""  
			For _nhi := 1 to  len(acols)
			
				If acols[_nhi][len(acols[_nhi])]
				
					_cproduto := alltrim(acols[_nhi][npospro])
					
				Endif
				
			Next
			If M->C5_TIPO = "N" .AND. M->C5_I_OPER $ u_itgetmv("IT_TPOPER","01") .And. !FWIsInCallStack("U_AOMS032") .AND. ;
   				!(FunName() $ "MATA140,MATA521B,MATA460B,MATA103")  .And. !_lAoms112 .AND. !(FWIsInCallStack("U_AOMS099")) .and. !_l108 .and. !_laoms074

				_ccond := u_IT_conpg(alltrim(M->C5_CLIENT),alltrim(M->C5_LOJAENT),_cproduto)
				If !empty(_ccond)

					M->C5_CONDPAG := _ccond 
			
				Endif
				_cTipoProd := Posicione("SB1",1,xFilial("SB1")+_cproduto,"B1_TIPO")

				If _cTipoProd == "PA"
					_cGrupoP   := Posicione("SB1",1,xFilial("SB1")+_cproduto,"B1_GRUPO")				
					_atab := {}
					_atab := u_ittabprc(cfilant,cfilant,M->C5_VEND3,M->C5_VEND2,M->C5_VEND1,M->C5_CLIENTE,M->C5_LOJACLI,.T.,,M->C5_VEND4,M->C5_I_GRPVE , _cGrupoP)
					_ctab := _atab[1]
					M->C5_I_TAB := _ctab
					M->C5_I_ORTBP := _atab[2]
					M->C5_I_DTAB  := POSICIONE("DA0",1,cfilant+M->C5_I_TAB,'DA0_DESCRI')                                                          
				EndIF
			EndIF				
		Endif
	EndIf	 
EndIf

RestArea(aAreaSA1)
RestArea(aAreaSA3)
RestArea(aAreaSC5)
RestArea(aAreaACY)
RestArea(aArea)

//Retorno de valida��o sempre true
If _ntipo == 1

	cRet := .T.
	processmessages()

Endif

Return(cRet) 
