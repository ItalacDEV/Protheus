/*
===============================================================================================================================
                                  ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
       Autor      |    Data    |                              Motivo                                                                 
-------------------------------------------------------------------------------------------------------------------------------                  
 Alex Wallauer    | 06/11/2019 | Revisão de fonte para novo appserver - Chamado 28346  									
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

/*
===============================================================================================================================
Programa----------: MTA105OK
Autor-------------: André Lisboa
Data da Criacao---: 18/06/2014 
===============================================================================================================================
Descrição---------: Ponto de Entrada que valida estorno de produção / Chamado apos confirmação de estorno de produções. 
                    Este ponto de entrada permite validar algum campo especifico do usuario antes de se realizar o Estorno.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: .T. = Permite confirmar estorno / .F. = Nao Permite confirmar estorno   
===============================================================================================================================
*/
User Function MT250EST()
LOCAL XX   
   
   L_RET:=.T.
   N_AREAEST:=SELECT()
   
   DBSELECTAREA("SB2")
   N_ORDB2:=INDEXORD()
   N_REGB2:=RECNO()
   
   DBSEEK(xFILIAL("SB2")+SD3->(D3_COD+D3_LOCAL))
   N_SALDODSP:=SALDOSB2()
   N_SLDACLA :=SB2->B2_QACLASS
   
   IF dDATABASE<SD3->D3_EMISSAO
      U_ITMSG("A data base não pode ser anterior a data do movimento a estornar.","Atenção",;
			  "Favor ajustar a data do sistema para a data do estorno.",1)
      L_RET:=.F.
   ENDIF
   
   //VERIFICA SE TEM SALDO NA DATA DO ESTORNO DA PRODUCAO
   IF (L_RET) .AND.  (GETMV("MV_ESTNEG")<>"S")
   
      nDIASVERIF:=(DATE()-SD3->D3_EMISSAO)+1     //18/06/2014 - 14/05/2014 = 35 + 1 (para englobar tambem o dia atual)
      IF nDIASVERIF>0
         dDIAAUX:=SD3->D3_EMISSAO   //dia auxiliar para percorrer dias a verificar
         FOR XX:=1 TO nDIASVERIF
            aSaldos:=CalcEst(SD3->D3_COD,SD3->D3_LOCAL,dDIAAUX+1)
            nQuant :=aSaldos[1]

            IF nQUANT<SD3->D3_QUANT
               U_ITMSG("O lançamento não pode ser estornado pois geraria saldo negativo em: "+DTOC(dDIAAUX)+" Saldo disponivel na data: "+ALLTRIM(TRANSFORM(nQUANT,"@E 999999,999.99")),"Atenção",,1)
               L_RET:=.F.
               EXIT
            ENDIF 
            dDIAAUX:=dDIAAUX+1
         NEXT 
      ENDIF      
   ENDIF   
   
   DBSELECTAREA("SB2")
   DBSETORDER(N_ORDB2)
   DBGOTO(N_REGB2)
   
   DBSELECTAREA(N_AREAEST)
   
   //VERIFICA SE TEM APONTAMENTO DE PERDA APONTADO PARA A OP
      
   DBSELECTAREA("SBC")
   DBSETORDER(1)
   IF DBSEEK(xFILIAL("SBC")+SD3->D3_OP)
      U_ITMSG("Não é possível estonar a produção para esta OP, pois existe apontamento de perda lançado para a OP!.","Atenção",;
			  "Exclua os apontamentos de perda para esta OP antes de estornar a produção",1)
      L_RET:=.F.
   ENDIF   

RETURN(L_RET)