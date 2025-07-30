/*
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
     Autor    |    Data    |                              Motivo                                                          |
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 26/02/2023 | Chamado AEST050. Gatilho alterado para ser chamado para o Local de origem tambem.
=============================================================================================================================== 
*/
#INCLUDE 'PROTHEUS.CH'
/*
===============================================================================================================================
Programa----------: AEST050
Autor-------------: Alex Wallauer
Data da Criacao---: 17/02/2023
===============================================================================================================================
Descrição---------: Chamada do gatilho 007 do campo NNT_PROD - CHAMADO 43029 
===============================================================================================================================
Parametros--------: U_AEST050("ORIGEM") // U_AEST050("DESTINO")
===============================================================================================================================
Retorno-----------: _cLocRet: Armazem da linha de cima 
===============================================================================================================================
*/  
USER FUNCTION AEST050(_cChamado)
LOCAL _oModel  := FwModelActive()
LOCAL _N       := _oModel:aAllSubModels[2]:Getline()
LOCAL _cLocRet := "  "
DEFAULT _cChamado:="DESTINO"
IF _cChamado = "ORIGEM"
   IF _N > 1 
      _cLocRet:=FWFldGet("NNT_LOCAL",_N-1) 
   ELSE
      _cLocRet:=FWFldGet("NNT_LOCAL",_N) 
   ENDIF
ELSEIF _cChamado = "DESTINO"
   IF _N > 1 
      _cLocRet:=FWFldGet("NNT_LOCLD",_N-1) 
   ELSE
      _cLocRet:=FWFldGet("NNT_LOCLD",_N) 
   ENDIF
ENDIF
RETURN _cLocRet
