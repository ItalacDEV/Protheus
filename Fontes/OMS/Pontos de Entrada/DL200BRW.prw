/* 
===============================================================================================================================
                          ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                          
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 16/01/2019 | Ajuste para novo servidor logo guara - Chamado 27727 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 17/09/2020 | Correções nas formações dos nomes de campos da tabela temporária TRBPED. Chamado 34159.
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE "Protheus.Ch"
#INCLUDE "RwMake.ch"
#INCLUDE "TopConn.CH"

#DEFINE _ENTER CHR(13)+CHR(10)         

/*
===============================================================================================================================
Programa----------: DL200BRW
Autor-------------: Wodson Reis Silva
Data da Criacao---: 03/08/2009
===============================================================================================================================
Descrição---------: PE para inclusão de campos no grid de montagem de carga
===============================================================================================================================
Parametros--------: PARAMIXB - Array com as caracteristicas dos campos do arquivo temporario.   
===============================================================================================================================
Retorno-----------: aret - Array com os campos incluídos.
===============================================================================================================================
*/
User Function DL200BRW()

Local aRet     := PARAMIXB
Local aCpos    := {} 
Local nX       := 0
Local _nPosTraco

//====================================================================================================
//Arrays de controle dos campos que deverao ser mostrados no Grid da rotina de Montagem de Carga.   
//====================================================================================================
aCpos := ALLTRIM(GetMv("IT_CMPCARG"))
aCpos := If(Empty(aCpos),{},&aCpos)

For nX := 1 To Len(aCpos)
	
	_cx3_campo := getsx3cache(aCpos[nX],"X3_CAMPO")
	_cx3_tipo := getsx3cache(aCpos[nX],"X3_TIPO")
	_cx3_titulo := getsx3cache(aCpos[nX],"X3_TITULO")

	If alltrim(aCpos[nX]) == alltrim(_cx3_campo)

	   _nPosTraco := At("_",_cx3_campo)
       If _nPosTraco == 0
		  _nPosTraco := 3
	   EndIf
  
	   //==============================================================
	   // Tratamento para que o nome do campo nao exceda 10 digitos. 
	   //==============================================================
	   If Len("PED"+Substr(_cx3_campo,_nPosTraco,Len(ALLTRIM(_cx3_campo))-2)) > 10 // Len("PED"+Substr(_cx3_campo,3,Len(ALLTRIM(_cx3_campo))-2)) > 10
			//================================================================
			// Para campos numerico passar mais um parametro com a mascara. 
			//================================================================
			If _cx3_tipo == "N"
				AADD(aRet,{"PED"+Substr(_cx3_campo,_nPosTraco,7),,ALLTRIM(_cx3_titulo),If(TamSx3(_cx3_campo)[2]>0,"99999999."+Replicate("9",TamSx3(_cx3_campo)[2]),"99999999") })
			Else
				AADD(aRet,{"PED"+Substr(_cx3_campo,_nPosTraco,7),,ALLTRIM(_cx3_titulo)})
			EndIf
		Else
			//================================================================
			// Para campos numerico passar mais um parametro com a mascara. 
			//================================================================		
			If _cx3_tipo == "N"
				AADD(aRet,{"PED"+Substr(_cx3_campo,_nPosTraco,Len(ALLTRIM(_cx3_campo))-2),,ALLTRIM(_cx3_titulo),If(TamSx3(_cx3_campo)[2]>0,"99999999."+Replicate("9",TamSx3(_cx3_campo)[2]),"99999999") })
			Else
				AADD(aRet,{"PED"+Substr(_cx3_campo,_nPosTraco,Len(ALLTRIM(_cx3_campo))-2),,ALLTRIM(_cx3_titulo)})
			EndIf
		EndIf
	Else
		U_ITMSG("O campo "+ALLTRIM(aCpos[nX])+" informado no parametro IT_CMPCARG, nao existe.","Atenção",;
		"Cadastre o mesmo atraves do modulo Configurador ou retire-o do parametro. "+;
		"Este campo é apresentado no Grid da rotina de Montagem de Carga.",1)
	EndIf
Next nX

Return aRet
