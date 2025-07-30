/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Andr� Carvalho| 29/07/2016 | Chamado 16419. Ajuste de grava��o do campo D3_I_OBS.
-------------------------------------------------------------------------------------------------------------------------------
Andr� Carvalho| 03/04/2017 | Chamado 19575. Ajuste de grava��o do campo D3_I_OBS.
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 11/09/2024 | Chamado 48465. Removendo warning de compila��o.
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: M185CAMP
Autor-------------: Talita Teixeira
Data da Criacao---: 11/03/2013
===============================================================================================================================
Descri��o---------: Ponto de entrada responsavel pelo preenchimento do campo D3_I_NUMCP de acordo com o numero da Solicita��o
        						do armazem na baixa da pr� requisi��o.Chamado 2729
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function M185CAMP()

Local _aArea 	:= FWGetArea()
Local _aAreaSCP:= SCP->(FWGetArea())
Local cCampo  := PARAMIXB[1]  //-- Nome do campo que esta sendo processado
Local z       := PARAMIXB[2]  //-- Numero da linha posicionada no aCols
  								  //-- Dimens�o de posi��o do array A185Dados ('Array onde esta os movimentos a serem gerados')
Local i       := PARAMIXB[4]  //-- Dimens�o do campo dentro do aCols.             
Local nX     := PARAMIXB[3]

DbSelectArea("SCP")
SCP->(DbSetOrder(2))

If cCampo == "D3_I_NUMCP" 
  SCP->(DbSeek(xFilial("SCP")+aCols[z][1]+cNumSa))
  aCols[z][i]:= SCP->CP_NUM  
EndIf   

If cCampo == "D3_I_OBS" // valida��o para que o conteudo do campo CP_OBS seja mostrado na baixa - Chamado:3168  
  SCP->(DbSeek(xFilial("SCP")+aCols[z][1]+cNumSa+a185dados[nx,3]))//CP_FILIAL+CP_PRODUTO+CP_NUM+CP_ITEM    
  aCols[z][i]:= SCP->CP_OBS   
EndIf    

If cCampo == "D3_I_MOTIV" // valida��o para que seja carregado o conteudo do campo CP_I_MOTIV na tela de baixa. Chamado: 3291	
  SCP->(DbSeek(xFilial("SCP")+aCols[z][1]+cNumSa))//CP_FILIAL+CP_PRODUTO+CP_NUM+CP_ITEM    
  aCols[z][i]:= SCP->CP_I_MOTIV  
EndIf     

SCP->(DbCloseArea())
SCP->(FWRestArea(_aAreaSCP))
FWRestArea(_aArea)

Return
