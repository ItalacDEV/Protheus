/* 
===============================================================================================================================
                          ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich      | 08/05/2018 | Ajuste de ponto de entrada para execauto MVC/TAF - Chamado 24794	 
Josué Danich      | 16/11/2018 | Ajuste de estabilidade de execauto e correções novos padrões código - Chamado 26969				  
Lucas Borges      | 02/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
Analista         - Programador       - Inicio     - Envio      - Chamado - Motivo da Alteração
-------------------------------------------------------------------------------------------------------------------------------
Bruno dos Reis   - Igor Melgaço      - 06/03/2025 - 10/03/2025 - 49456   - Ajustes para replicação das verbas
Bruno dos Reis   - Igor Melgaço      - 16/05/2025 - 19/05/2025 - 50567   - Ajustes para replicação das verbas
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "Protheus.ch"

/*
===============================================================================================================================
Programa--------: GP40VALPE
Autor-----------: Alexandre Villar
Data da Criacao-: 29/01/2016
===============================================================================================================================
Descrição-------: P.E. na validação do cadastro de Verbas
===============================================================================================================================
Parametros------: Nenhum - Variáveis em memória com dados da tabela de Verbas
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function GP40VALPE()

Local _lExec := .T. As Logical
Local oproc := nil As Object

_lExec := u_itmsg( 'Deseja replicar as alterações da Verba atual para as demais Filiais da Empresa?' , 'Atenção!',,2,2,2 )

If _lExec
		
	fwmsgrun(,{ |oproc| U_GP40REP(oproc)},"Aguarde...","Iniciando processo de replicação...")
	
Else

	u_itmsg("Processo de replicação cancelado!","Atenção",,1)

Endif

Return

/*
===============================================================================================================================
Programa--------: GPEA040
Autor-----------: Josué Danich
Data da Criacao-: 26/10/2017
===============================================================================================================================
Descrição-------: P.E. na validação do cadastro de Verbas via MVC
===============================================================================================================================
Parametros------: Nenhum - Variáveis em memória com dados da tabela de Verbas
===============================================================================================================================
Retorno---------: ( .T. ) Dados validados / ( .F. ) Dados não validados
===============================================================================================================================
*/
User Function GPEA040() 

Local aParam     := PARAMIXB As Array
Local xRet       := .T. 

oObj       := aParam[1]
cIdPonto   := aParam[2]
cIdModel   := aParam[3]

If cIdPonto == 'BUTTONBAR' .and. !IsInCallStack("U_AGPE006")

	xRet := { {'Replicar Verba', 'Replicar', { || U_GP40VALPE() }, 'Replica Verba para outras filiais' } }
		
Endif

Return xRet

/*
===============================================================================================================================
Programa--------: GP40rep
Autor-----------: Josué Danich
Data da Criacao-: 14/11/2018
===============================================================================================================================
Descrição-------: Rotina de replicação de verbas
===============================================================================================================================
Parametros------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/
User Function GP40REP(oProc As Object)

Local _aAreaSRV	:= SRV->(GetArea()) As Array
Local _aCpoSRV	:= {} As Array
Local _cCpoExc	:= Upper( AllTrim( U_ITGETMV( 'IT_CPONSRV' , '' ) ) ) As Char
Local _cEmpCor	:= alltrim(cEmpAnt) As Char
Local _cFilCor	:= alltrim(cfilAnt) As Char
Local _nii 		:= 0 As Numeric
Local _nnk		:= 0 As Numeric
Local _aCpoSRVt := {} As Array
Local _cFilAntBkp := cFilAnt As Char
Local _nI         := 0 As Numeric
Local _aSM0        := {} As Array

aadd(_aCpoSRVt,{"RV_COD","006"})
aadd(_aCpoSRVt,{"RV_DESC","T...NIO SOBRE VERBAS"})
aadd(_aCpoSRVt,{"RV_TIPOCOD","1"})
aadd(_aCpoSRVt,{"RV_CODCORR"," "})
aadd(_aCpoSRVt,{"RV_CODFOL","1285"})
aadd(_aCpoSRVt,{"RV_TIPO","V"})
aadd(_aCpoSRVt,{"RV_OBRIGAT","N"})
aadd(_aCpoSRVt,{"RV_QTDLANC","9"})
aadd(_aCpoSRVt,{"RV_INSS","S"})
aadd(_aCpoSRVt,{"RV_IR","S"})
aadd(_aCpoSRVt,{"RV_FGTS","S"})
aadd(_aCpoSRVt,{"RV_INCORP","S"})
aadd(_aCpoSRVt,{"RV_REF13","N"})
aadd(_aCpoSRVt,{"RV_REFFER","N"})
aadd(_aCpoSRVt,{"RV_ADIANTA","N"})
aadd(_aCpoSRVt,{"RV_PERICUL","N"})
aadd(_aCpoSRVt,{"RV_INSALUB","N"})
aadd(_aCpoSRVt,{"RV_PENSAO","N"})
aadd(_aCpoSRVt,{"RV_DSRHE","N"})
aadd(_aCpoSRVt,{"RV_HE","N"})
aadd(_aCpoSRVt,{"RV_ADICTS","N"})
aadd(_aCpoSRVt,{"RV_SINDICA","N"})
aadd(_aCpoSRVt,{"RV_SALFAMI","N"})
aadd(_aCpoSRVt,{"RV_SEGVIDA","N"})
aadd(_aCpoSRVt,{"RV_DEDINSS","N"})
aadd(_aCpoSRVt,{"RV_TAREFA"," "})
aadd(_aCpoSRVt,{"RV_PIS","N"})
aadd(_aCpoSRVt,{"RV_ENCARCC"," "})
aadd(_aCpoSRVt,{"RV_CUSTO"," "})
aadd(_aCpoSRVt,{"RV_LCTOP","A99"})
aadd(_aCpoSRVt,{"RV_MED13","N "})
aadd(_aCpoSRVt,{"RV_MEDFER","N "})
aadd(_aCpoSRVt,{"RV_MEDAVI","N "})
aadd(_aCpoSRVt,{"RV_GRAMED"," "})
aadd(_aCpoSRVt,{"RV_CONVCOL"," "})
aadd(_aCpoSRVt,{"RV_VALDISS"," "})
aadd(_aCpoSRVt,{"RV_MEDREAJ"," "})
aadd(_aCpoSRVt,{"RV_RAIS","A-**************************************                    "})
aadd(_aCpoSRVt,{"RV_DIRF","A "})
aadd(_aCpoSRVt,{"RV_COMPL_","S"})
aadd(_aCpoSRVt,{"RV_CODCOM_","230"})
aadd(_aCpoSRVt,{"RV_DSRPROF","N"})
aadd(_aCpoSRVt,{"RV_HRSATIV","N"})
aadd(_aCpoSRVt,{"RV_CUSTEMP","2"})
aadd(_aCpoSRVt,{"RV_LANCPCO"," "})
aadd(_aCpoSRVt,{"RV_HOMOLOG","018"})
aadd(_aCpoSRVt,{"RV_GRPVERB"," "})
aadd(_aCpoSRVt,{"RV_CODDSR"," "})
aadd(_aCpoSRVt,{"RV_DESCDET","TRIENIO SOBRE VERBAS                              "})
aadd(_aCpoSRVt,{"RV_LCTODIA"," "})
aadd(_aCpoSRVt,{"RV_VLIMDE",0})
aadd(_aCpoSRVt,{"RV_VLIMATE",0})
aadd(_aCpoSRVt,{"RV_RLIMDE",0})
aadd(_aCpoSRVt,{"RV_RLIMATE",0})
aadd(_aCpoSRVt,{"RV_CODMSEG"," "})
aadd(_aCpoSRVt,{"RV_I_CUSTG"," "})
aadd(_aCpoSRVt,{"RV_AGLTRCT"," "})
aadd(_aCpoSRVt,{"RV_RRA"," "})
aadd(_aCpoSRVt,{"RV_NATUREZ","1206"})
aadd(_aCpoSRVt,{"RV_INCIRF","11"})
aadd(_aCpoSRVt,{"RV_INCFGTS","11"})
aadd(_aCpoSRVt,{"RV_INCSIND","00"})
aadd(_aCpoSRVt,{"RV_INCCP","11"})
aadd(_aCpoSRVt,{"RV_INSSFER","2"})
aadd(_aCpoSRVt,{"RV_LEEINC","1"})
aadd(_aCpoSRVt,{"RV_LEEPRE","1"})
aadd(_aCpoSRVt,{"RV_LEEAUS","1"})
aadd(_aCpoSRVt,{"RV_LEEBEN","1"})
aadd(_aCpoSRVt,{"RV_LEEFIX","1"})
aadd(_aCpoSRVt,{"RV_ORIGEM"," "})
aadd(_aCpoSRVt,{"RV_FECCOMP","2"})
aadd(_aCpoSRVt,{"RV_CODREMU"," "})
aadd(_aCpoSRVt,{"RV_CODMEMO"," "})
aadd(_aCpoSRVt,{"RV_INSSJUB"," "})
aadd(_aCpoSRVt,{"RV_BSEREMT"," "})
aadd(_aCpoSRVt,{"RV_BASCAL","1"})
aadd(_aCpoSRVt,{"RV_FERSEG"," "})
aadd(_aCpoSRVt,{"RV_EMPCONS","2"})
aadd(_aCpoSRVt,{"RV_REFABON"," "})

For _nnk := 1 to len(_aCpoSRVt)
		
	If  !( AllTrim( _aCpoSRVt[_nnk][1] ) $ _cCpoExc )
		aAdd( _aCpoSRV , { AllTrim( _aCpoSRVt[_nnk][1] ) , &( 'M->'+ AllTrim( _aCpoSRVt[_nnk][1] ) ) } )
	EndIf
		
Next

oproc:cCaption := ("Contando filiais ativas...")
ProcessMessages()

_ntot := 0
_aSM0 := FwLoadSM0()

For _nI := 1 To Len(_aSM0)
	If _cEmpCor == _aSM0[_nI,1]
		_ntot++
	EndIf
Next

_nkk := 0
For _nI := 1 To Len(_aSM0)
	If _cEmpCor == _aSM0[_nI,1]
		
		_nkk++
		oproc:cCaption := ("Replicando verba da filial " + alltrim(_aSM0[_nI,2]) + " - " + strzero(_nkk,6) + " de " + strzero(_ntot,6) + ".")
		ProcessMessages()
		
		If _cFilCor <> alltrim(alltrim(_aSM0[_nI,2])) .and. !empty(alltrim(alltrim(_aSM0[_nI,2])))
				
			DBSelectArea("SRV")
			SRV->( DBSetOrder(1) )
			IF SRV->( DBSeek( alltrim(_aSM0[_nI,2]) + M->RV_COD ) ) 
				
				cfilant := alltrim(alltrim(_aSM0[_nI,2]))
				aCab := {}
						
				For _nii := 1 to len(_aCpoSRV)
						
					aAdd( aCab, { _aCpoSRV[_niI][01], &( 'M->'+ _aCpoSRV[_niI][01] ), Nil } )
					
				Next 
						
				_lretorno := FWMVCRotAuto(FwLoadModel("GPEA040"),'SRV',4,{{'SRVMASTER',aCab}},.F.,.T.) 
								
			Else
			
				cfilant := alltrim(alltrim(_aSM0[_nI,2]))
				aCab := {}
						
				For _nii := 1 to len(_aCpoSRV)
						
					aAdd( aCab, { _aCpoSRV[_nII][01], &( 'M->'+ _aCpoSRV[_nII][01] ), Nil } )
						
				Next 
											
				_lretorno := FWMVCRotAuto(FwLoadModel("GPEA040"),'SRV',3,{{'SRVMASTER',aCab}},.F.,.T.)
								
			EndIf
				
										
		EndIf
	EndIf
Next

SRV->(Restarea(_aAreaSRV))
cfilant := _cFilAntBkp
U_ItMsg("Replicação de verbas concluída!","Atenção",,2)

Return
