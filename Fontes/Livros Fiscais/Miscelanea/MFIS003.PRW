/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor           |    Data    |                              Motivo                      										 
------------------------------------------------------------------------------------------------------------------------------- 
Darcio Sporl	 | 30/01/2017 | Foi feito tratamento para que os títulos "TX" possam herdar o código de retenção dos títulos
 				 |			  | principais. Chamado 14542
-------------------------------------------------------------------------------------------------------------------------------
Lucas B. Ferreira| 02/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: MFIS003
Autor-------------: Josue Danich
Data da Criacao---: 04/11/2016
===============================================================================================================================
Descricao---------: Ajuste de códigos de retencao para dirf - Chamado 14542
===============================================================================================================================
Parametros--------:
===============================================================================================================================
Retorno-----------:
===============================================================================================================================
*/
User Function MFIS003()

Local _bProcess  	:= nil
Local _oSelf		:= nil
Private _lsai 		:= .F.

Do while !(_lsai)

	//============================================
	//Cria interface principal
	//============================================
	_bProcess    := {|_oSelf| MFIS003M(_oSelf)  }
	_lsai := .T.
	tNewProcess():New( "MFIS003", "Ajusta retencao DIRF", _bProcess, "Rotina de ajuste de Retencao para Dirf","MFIS003",,,,,,.T.)

Enddo

Return

/*
===============================================================================================================================
Programa----------: MFIS003M
Autor-------------: Josue Danich Prestes
Data da Criacao---: 04/11/2016
===============================================================================================================================
Descricao---------: Rotina de ajuste principal
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
Static Function MFIS003M(_oself)      

Local cQuery	:= 	""
Local _ncont 	:= 0
Local _aheader 	:= {"Filial", "Título Principal", "Fornec Tit P", "Titulo TX", "Fornec Tit TX", "Vencimento","Valor", "Natureza", "Dirf original", "Dirf Alterado", "Cod Ret Original", "Cod Ret Alterado","Obs"}
Local _acols  	:= {}
Local _cRetPai	:= ""
Local _aInfHlp	:= {}
Local _cObsPai	:= ""
Local _cObsFil	:= ""
Local _cRetAnP	:= ""
Local _cRetAnF	:= ""
Local _cDfAnP	:= ""
Local _cDfAnF	:= ""

cQuery := "SELECT R_E_C_N_O_, E2_FILIAL, E2_EMISSAO, E2_NUM"
cQuery += " FROM " + RetSqlName("SE2") + " SE2"
cQuery += " WHERE SE2.D_E_L_E_T_ = ' '"
cQuery += " AND SE2.E2_EMISSAO >= '" + DTOS(MV_PAR02) + "' AND SE2.E2_EMISSAO <= '" + DTOS(MV_PAR03) + "'"
cQuery += " AND (SE2.E2_TIPO = 'NF' OR SE2.E2_TIPO = 'BOL' OR SE2.E2_TIPO = 'RES') "
cQuery += " AND SE2.E2_NATUREZ IN (SELECT ZFS_NATURE FROM " + RetSqlName("ZFS") + " ZFS WHERE ZFS.D_E_L_E_T_ <> '*')"
If !Empty(MV_PAR01)
	cQuery += " AND SE2.E2_FILIAL IN " + FormatIn(ALLTRIM(MV_PAR01),";")
EndIf


dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TEMP", .T., .F. )
dbSelectArea("TEMP")

COUNT TO _ncont

TEMP->(Dbgotop())

_oself:SetRegua1(_ncont)

If !TEMP->(Eof())

	Do while .not. TEMP->(Eof())
	
		_oself:IncRegua1( "Ajustando Retenções Dirf - " + TEMP->E2_FILIAL + " - " + DTOC(STOD(TEMP->E2_EMISSAO)) + " - " + TEMP->E2_NUM )
		
		//Ajusta Retenção de Título Pai
		SE2->(Dbgoto(TEMP->R_E_C_N_O_))
		
		If SE2->(Reclock("SE2",.F.))

			_cRetAnP		:= SE2->E2_CODRET
			_cDfAnP			:= SE2->E2_DIRF

		 	SE2->E2_CODRET	:= Posicione("ZFS",1,xfilial("ZFS")+AllTrim(SE2->E2_NATUREZ),"ZFS_RETENC")
		 	_cRetPai		:= SE2->E2_CODRET
		 	SE2->E2_DIRF	:= '2'

			If Empty(_cRetPai)
				_cObsPai := "Problema na Amarração Natureza x Retenção"
			Else
				_cObsPai := "Alterado com sucesso"
			EndIf

			aadd(_acols,{	SE2->E2_FILIAL,;
		 			 		SE2->E2_NUM,;
		 			 		SE2->E2_FORNECE + "-" + SE2->E2_LOJA + SUBSTR(Posicione("SA2",1,Xfilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"A2_NOME"),1,15),;
		 			 		"    ",;
		 			 		"    ",;
		 			 		SE2->E2_VENCTO,;
		 			 		SE2->E2_VALOR,;
		 			 		SE2->E2_NATUREZ,;
		 			 		IIF(_cDfAnP<>'1',"Não","Sim"),;
		 			 		"Não",;
		 			 		_cRetAnP,;
		 			 		SE2->E2_CODRET,;
		 			 		_cObsPai})
			
		 	SE2->( Msunlock())
		 	
		 Else
	
			aadd(_acols,{	SE2->E2_FILIAL,;
		 			 		SE2->E2_NUM,;
		 			 		SE2->E2_FORNECE + "-" + SE2->E2_LOJA + SUBSTR(Posicione("SA2",1,Xfilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"A2_NOME"),1,15) ,;
		 			 		"    ",;
		 			 		"    ",;
		 			 		SE2->E2_VENCTO,;
		 			 		SE2->E2_VALOR,;
		 			 		SE2->E2_NATUREZ,;
		 			 		IIF(SE2->E2_DIRF=='2',"Não","Sim"),;
		 			 		IIF(SE2->E2_DIRF=='2',"Não","Sim"),;
		 			 		SE2->E2_CODRET,;
		 			 		SE2->E2_CODRET,;
		 			 		"Falha de gravação"})
		 
		 Endif
		
		//Procura e ajusta títulos filhos
		cQuery := "SELECT R_E_C_N_O_"
		cQuery += " FROM " + RetSqlName("SE2") + " SE2"
		cQuery += " WHERE SE2.D_E_L_E_T_ = ' '"
		cQuery += " AND (SUBSTR(SE2.E2_TIPO,1,2) = 'TX' OR SE2.E2_TIPO = 'BOL' OR SE2.E2_TIPO = 'RES' ) "
		cQuery += " AND SE2.E2_NATUREZ IN (SELECT ZFS_NATURE FROM " + RetSqlName("ZFS") + " ZFS WHERE ZFS.D_E_L_E_T_ <> '*')"
		cQuery += " AND SE2.E2_FILIAL = '" + SE2->E2_FILIAL + "'"
		cQuery += " AND SE2.E2_TITPAI = '" + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA + "'"
		
		
		_cpnum	:= SE2->E2_NUM
		_cpforn	:= SE2->E2_FORNECE
		_cploja	:= SE2->E2_LOJA
		
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TEM2", .T., .F. )
		dbSelectArea("TEM2")
		
		Do while !(TEM2->(Eof()))
		        	
			SE2->(Dbgoto(TEM2->R_E_C_N_O_))
			
			If SE2->(Reclock("SE2",.F.))

				_cRetAnF	:= SE2->E2_CODRET
				_cDfAnF		:= SE2->E2_DIRF

				If posicione("ZFS",1,xfilial("ZFS")+AllTrim(SE2->E2_NATUREZ),"ZFS_HERRET") == "S"
					SE2->E2_CODRET := _cRetPai
				Else
					SE2->E2_CODRET := posicione("ZFS",1,xfilial("ZFS")+SE2->E2_NATUREZ,"ZFS_RETENC")
				EndIf
	
				SE2->E2_DIRF := '1'

				If Empty(SE2->E2_CODRET)
					_cObsFil := "Problema na Amarração Natureza x Retenção"
				Else
					_cObsFil := "Alterado com sucesso"
					
				EndIf

				aadd(_acols,{	SE2->E2_FILIAL,;
		 			 			SE2->E2_NUM,;
								SE2->E2_FORNECE + "-" + SE2->E2_LOJA + SUBSTR(Posicione("SA2",1,Xfilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"A2_NOME"),1,15),;
	 							_cpnum,;
								_cpforn + "-" + _cploja + SUBSTR(Posicione("SA2",1,Xfilial("SA2")+_cpforn+_cploja,"A2_NOME"),1,15),;
		 			 			SE2->E2_VENCTO,;
								SE2->E2_VALOR,;
								SE2->E2_NATUREZ,;
	 							IIF(_cDfAnF<>'1',"Não","Sim"),;
		 						"Sim",;
		 						_cRetAnF,;
		 			 			SE2->E2_CODRET,;
		 			 			_cObsFil})

				SE2->( Msunlock())
			
			Else
			
				aadd(_acols,{	SE2->E2_FILIAL,;
		 			 			SE2->E2_NUM,;
		 			 			SE2->E2_FORNEC + "-" + SE2->E2_LOJA + SUBSTR(Posicione("SA2",1,Xfilial("SA2")+SE2->E2_FORNEC+SE2->E2_LOJA,"A2_NOME"),1,15) ,;
		 			 			_cpnum,;
		 			 			_cpforn + "-" + _cploja + SUBSTR(Posicione("SA2",1,Xfilial("SA2")+_cpforn+_cploja,"A2_NOME"),1,15) ,;
		 			 			SE2->E2_VENCTO,;
		 			 			SE2->E2_VALOR,;
		 			 			SE2->E2_NATUREZ,;
		 			 			IIF(SE2->E2_DIRF=='2',"Não","Sim"),;
		 			 			IIF(SE2->E2_DIRF=='2',"Não","Sim"),;
		 			 			SE2->E2_CODRET,;
		 			 			SE2->E2_CODRET,;
		 			 			"Falha de gravação!"})
			
			Endif
			
			TEM2->( DbSkip())
			
		Enddo
		
		TEM2->( Dbclosearea())
		
		TEMP->(Dbskip())
		
	Enddo
Else
	_aInfHlp := {}
	//                  |....:....|....:....|....:....|....:....|	  |....:....|....:....|....:....|....:....|	  |....:....|....:....|....:....|....:....|
	aAdd( _aInfHlp	, { 'Não foram retornados dados para sua '		, 'pesquisa.                              '	, ''                             				} )
	aAdd( _aInfHlp	, { 'Favor verifique os parâmetros informados.' , ''										, ''											} )
	
	U_ITCADHLP( _aInfHlp , "MFIS0031" )
EndIf

TEMP->( Dbclosearea())

_lsai := .F.

If Len(_acols) > 0
	U_ITListBox( 'Relação de títulos ajustados' , _aheader , _acols, .F. , 1 , 'Títulos ajustados' )
EndIf

Return

/*
===============================================================================================================================
Programa----------: ValRet
Autor-------------: Darcio Ribeiro Spörl
Data da Criacao---: 18/01/2017
===============================================================================================================================
Descricao---------: Função criada para apagar os campos de código e descrição da retenção, caso seja informado sim no campo
------------------: Herdar Retenção do Título Pai.
===============================================================================================================================
Parametros--------:
===============================================================================================================================
Retorno-----------:
===============================================================================================================================
*/
User Function ValRet()
Local _lRet := .T.

If M->ZFS_HERRET == "S"
	M->ZFS_RETENC	:= Space(TamSX3("ZFS_RETENC")[1])
	M->ZFS_DESCR	:= Space(TamSX3("ZFS_DESCR")[1])
EndIf

Return(_lRet)