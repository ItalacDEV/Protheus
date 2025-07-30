/*
===============================================================================================================================
                                            ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
Autor         |    Data    |                              Motivo                       
-------------------------------------------------------------------------------------------------------------------------------
 
===============================================================================================================================
*/

#DEFINE CRLF CHR(13)+CHR(10)

/*
===============================================================================================================================
Programa----------: MTA650L 
Autor-------------: Alex Wallauer
Data da Criacao---: 18/01/2023
===============================================================================================================================
Descrição---------: P.E. Troca de linha e OK final NA TELA DE AJUSTE DE EMPEMHOS
------------------  Chamado 42590: Novo validacao para não deixar os aramzens sem preencher
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T. = Permite confirmar 
------------------: .F. = Nao Permite confirmar 
===============================================================================================================================*/
User Function MTA650L()
LOCAL nI, bBloco
LOCAL _cItens:=""
LOCAL _cSpcC :=13
LOCAL _cSpcT :=15

IF IsInCallStack("A650AETdOk")
    
    _cItens:=""
	_cSpcC:=13
	_cSpcT:=15
	For nI := 1 To Len(aCols)
    	If !aCols[nI,Len(aCols[nI])]  .AND. EMPTY(aCols[nI,nPosLocal])
   		   _cItens += ALLTRIM(aCols[nI,nPosCod])+SPACE(_cSpcT)+aCols[nI,nPosLocal]+CRLF
    	EndIf
    Next 

    IF !EMPTY(_cItens)
       bBloco:={|| AVISO("ATENCAO","  PRODUTO"+SPACE(_cSpcC)+"ARMAZEM"+CRLF+_cItens,{"Fechar"},3) }
       U_ITMSG("Existem Produtos com o armazem não preenchido","ATENCAO","Clique em mais detalhes para ver os produtos",1,,,,,,bBloco)
	   RETURN .F.
	ENDIF
ELSE
  	If !aCols[N,Len(aCols[N])]  .AND. EMPTY(aCols[N,nPosLocal])
       U_ITMSG("Produto "+aCols[N,nPosCod]+" com o armazem não preenchido","ATENCAO","Preencha o armazem",1)
	   RETURN .F.
    ENDIF
ENDIF

RETURN .T.
