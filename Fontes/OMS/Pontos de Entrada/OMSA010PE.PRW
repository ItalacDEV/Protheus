/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges | 11/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
 Jerry        | 17/04/2020 | Ajustes e inclusão de melhorias nas rotinas de tabelas de preços. Chamado 28370.
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz    | 29/03/2021 | Correções na gravação do Status de alteração da tabela de preços. Chamado 35936.
===============================================================================================================================
*/ 
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"

/*
===============================================================================================================================
Programa----------: OMSA010
Autor-------------: Josué Danich Prestes
Data da Criacao---: 19/03/2018
===============================================================================================================================
Descrição---------: Pontos de entrada do formmodel do programa OMSA010 - Chamado 24295 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
user function OMSA010()
Local _aParam		:= If(Type("PARAMIXB") == "U", Nil,PARAMIXB) 
Local _nni			:= 0

If _aParam <> NIL

	_oObj		:= _aParam[01]
	_cIdPonto	:= _aParam[02]
	
	// Validacao de Ativacao
	_oModel 	:= FWModelActive()
	
	
	//Gravação de log
	If _cIdPonto == 'MODELPOS'

		_oModel 	:= FWModelActive()
		_oModelMAS 	:= _oModel:GetModel('DA0MASTER')
		_oModelDET 	:= _oModel:GetModel('DA1DETAIL')
		_nlinhas    := _oModelDET:GetQtdLine()
		_oObj		:= _aParam[01]
		_nOper		:= _oObj:GetOperation()
		_nposi := DA1->(Recno())
		
		
		//Inclusão ou cópia
		if _nOper == 3
		
			//Varre linhas criando uma linha de log para cada linha do modelo
			For _nni := 1 to _nlinhas
			
				If !_oModelDET:IsDeleted(_nni)
				
					_oModelDET::SetLine(_nni)
					Reclock("ZGS",.T.)
					ZGS->ZGS_FILIAL := xfilial("ZGS")
					ZGS->ZGS_ITEM   := _oModelDET:GetValue("DA1_ITEM")
					ZGS->ZGS_DATA   := date()
					ZGS->ZGS_HORA   := time()
					ZGS->ZGS_USER   := cusername
					ZGS->ZGS_MODULO := funname()	
					ZGS->ZGS_CODTAB := _oModelMAS:GetValue("DA0_CODTAB")
					ZGS->ZGS_DATDE 	:= _oModelMAS:GetValue("DA0_DATDE")
					ZGS->ZGS_HORADE	:= _oModelMAS:GetValue("DA0_HORADE")
					ZGS->ZGS_DATATE	:= _oModelMAS:GetValue("DA0_DATATE")
					ZGS->ZGS_HORATE	:= _oModelMAS:GetValue("DA0_HORATE")
					ZGS->ZGS_CONDPG	:= _oModelMAS:GetValue("DA0_CONDPG")
					ZGS->ZGS_TPHORA	:= _oModelMAS:GetValue("DA0_TPHORA")
					ZGS->ZGS_ATIVO 	:= _oModelMAS:GetValue("DA0_ATIVO")
					ZGS->ZGS_I_FILI := _oModelMAS:GetValue("DA0_I_FILI")
    				ZGS->ZGS_I_PRFE := _oModelDET:gETValue("DA1_I_PRFE")
    				ZGS->ZGS_I_DTCR := _oModelDET:gETValue("DA1_I_DTCR")
    				ZGS->ZGS_CODPRO	:= _oModelDET:GetValue("DA1_CODPRO")
					ZGS->ZGS_GRUPO 	:= _oModelDET:GetValue("DA1_GRUPO")

					ZGS->ZGS_PRCVEN	:= _oModelDET:GetValue("DA1_PRCVEN")

					ZGS->ZGS_I_PRCA	:= _oModelDET:GetValue("DA1_I_PRCA")
					ZGS->ZGS_PRCMAX	:= _oModelDET:GetValue("DA1_PRCMAX")
					ZGS->ZGS_I_PRMP	:= _oModelDET:GetValue("DA1_I_PRMP")
					ZGS->ZGS_I_PTBN	:= _oModelDET:GetValue("DA1_I_PTBN")
					ZGS->ZGS_I_VIGI	:= _oModelDET:GetValue("DA1_I_VIGI")
					ZGS->ZGS_I_VIGF	:= _oModelDET:GetValue("DA1_I_VIGF")
					ZGS->ZGS_PRF1	:= _oModelDET:GetValue("DA1_I_PRF1")
					ZGS->ZGS_PRF2	:= _oModelDET:GetValue("DA1_I_PRF2")
					ZGS->ZGS_PRF3	:= _oModelDET:GetValue("DA1_I_PRF3")
					ZGS->ZGS_PMF1	:= _oModelDET:GetValue("DA1_I_PMF1")
					ZGS->ZGS_PMF2	:= _oModelDET:GetValue("DA1_I_PMF2")
					ZGS->ZGS_PMF3	:= _oModelDET:GetValue("DA1_I_PMF3")
					ZGS->ZGS_STATUS := "I" // Status de inclusão									
					ZGS->(Msunlock())
					
				Endif
				
			Next
			
		Endif
		
		//Alteração e exclusão
		if _nOper == 4 .or. _nOper == 5
		
			//Varre linhas criando uma linha de log para cada linha do modelo
			For _nni := 1 to _nlinhas
			
				DA1->(Dbsetorder(3)) //DA1_FILIAL+DA1_CODTAB+DA1_ITEM
			
				If !(_oModelDET:IsDeleted(_nni) .and. _oModelDET:IsInserted(_nni))
				
					_oModelDET::SetLine(_nni)
					Reclock("ZGS",.T.)
					ZGS->ZGS_FILIAL := xfilial("ZGS")
					ZGS->ZGS_ITEM   := _oModelDET:GetValue("DA1_ITEM")
					ZGS->ZGS_DATA   := date()
					ZGS->ZGS_HORA   := time()
					ZGS->ZGS_USER   := cusername
					ZGS->ZGS_MODULO := funname()	
					ZGS->ZGS_CODTAB := _oModelMAS:GetValue("DA0_CODTAB")
					ZGS->ZGS_DATDE 	:= _oModelMAS:GetValue("DA0_DATDE")
					ZGS->ZGS_HORADE	:= _oModelMAS:GetValue("DA0_HORADE")
					ZGS->ZGS_DATATE	:= _oModelMAS:GetValue("DA0_DATATE")
					ZGS->ZGS_HORATE	:= _oModelMAS:GetValue("DA0_HORATE")
					ZGS->ZGS_CONDPG	:= _oModelMAS:GetValue("DA0_CONDPG")
					ZGS->ZGS_TPHORA	:= _oModelMAS:GetValue("DA0_TPHORA")
					ZGS->ZGS_ATIVO 	:= _oModelMAS:GetValue("DA0_ATIVO")
					ZGS->ZGS_I_FILI := _oModelMAS:GetValue("DA0_I_FILI")
    				ZGS->ZGS_I_PRFE := _oModelDET:gETValue("DA1_I_PRFE")
    				ZGS->ZGS_I_DTCR := _oModelDET:gETValue("DA1_I_DTCR")
					ZGS->ZGS_CODPRO	:= _oModelDET:GetValue("DA1_CODPRO")
					ZGS->ZGS_GRUPO 	:= _oModelDET:GetValue("DA1_GRUPO")
					ZGS->ZGS_PRCVEN	:= _oModelDET:GetValue("DA1_PRCVEN")
					ZGS->ZGS_I_PRCA	:= _oModelDET:GetValue("DA1_I_PRCA")
					ZGS->ZGS_PRCMAX	:= _oModelDET:GetValue("DA1_PRCMAX")
					ZGS->ZGS_I_PRMP	:= _oModelDET:GetValue("DA1_I_PRMP")
					ZGS->ZGS_I_PTBN	:= _oModelDET:GetValue("DA1_I_PTBN")
					ZGS->ZGS_I_VIGI	:= _oModelDET:GetValue("DA1_I_VIGI")
					ZGS->ZGS_I_VIGF	:= _oModelDET:GetValue("DA1_I_VIGF")
					ZGS->ZGS_PRF1	:= _oModelDET:GetValue("DA1_I_PRF1")
					ZGS->ZGS_PRF2	:= _oModelDET:GetValue("DA1_I_PRF2")
					ZGS->ZGS_PRF3	:= _oModelDET:GetValue("DA1_I_PRF3")
					ZGS->ZGS_PMF1	:= _oModelDET:GetValue("DA1_I_PMF1")
					ZGS->ZGS_PMF2	:= _oModelDET:GetValue("DA1_I_PMF2")
					ZGS->ZGS_PMF3	:= _oModelDET:GetValue("DA1_I_PMF3")					
					ZGS->ZGS_ODATDE := DA0->DA0_DATDE
					ZGS->ZGS_OHORAD := DA0->DA0_HORADE
					ZGS->ZGS_ODATAT := DA0->DA0_DATATE
					ZGS->ZGS_OHORAT := DA0->DA0_HORATE
					ZGS->ZGS_OCONDP := DA0->DA0_CONDPG
					ZGS->ZGS_OTPHOR := DA0->DA0_TPHORA
					ZGS->ZGS_OATIVO := DA0->DA0_ATIVO
					ZGS->ZGS_I_OFIL := DA0->DA0_I_FILI

					//Se já existe linha no da1 grava valores antigos
					If DA1->(Dbseek(XFILIAL("DA1")+_oModelMAS:GetValue("DA0_CODTAB")+_oModelDET:GetValue("DA1_ITEM")))

						ZGS->ZGS_OCODPR := DA1->DA1_CODPRO 
						ZGS->ZGS_OGRUPO := DA1->DA1_GRUPO
						ZGS->ZGS_OPRCVE := DA1->DA1_PRCVEN
						ZGS->ZGS_I_OPRC := DA1->DA1_I_PRCA
						ZGS->ZGS_OPRCMA := DA1->DA1_PRCMAX
						ZGS->ZGS_I_OPRM := DA1->DA1_I_PRMP
						ZGS->ZGS_I_OPTB := DA1->DA1_I_PTBN
						ZGS->ZGS_I_OVII := DA1->DA1_I_VIGI
						ZGS->ZGS_I_OVIF := DA1->DA1_I_VIGF
						ZGS->ZGS_I_OPRF := DA1->DA1_I_PRFE
    					ZGS->ZGS_I_ODTC := DA1->DA1_I_DTCR
						ZGS->ZGS_OPRF1	:= DA1->DA1_I_PRF1
						ZGS->ZGS_OPRF2	:= DA1->DA1_I_PRF2
						ZGS->ZGS_OPRF3	:= DA1->DA1_I_PRF3
						ZGS->ZGS_OPMF1	:= DA1->DA1_I_PMF1
						ZGS->ZGS_OPMF2	:= DA1->DA1_I_PMF2
						ZGS->ZGS_OPMF3	:= DA1->DA1_I_PMF3
																
					Endif
					
					//Se apagou a linha grava que foi deletada
					If _oModelDET:IsDeleted(_nni) .or. _nOper == 5
					   ZGS->ZGS_STATUS := "X" // Status de Exclusão
					Else 	
					   ZGS->ZGS_STATUS := "A" // Status de Alteração
					Endif
					
					//mantém posicionamento original do DA1
					DA1->(Dbgoto(_nposi))
														
					ZGS->(Msunlock())
					
				Endif
				
			Next
			
		Endif
		
	
	Endif
	
Endif

Return .T.  
