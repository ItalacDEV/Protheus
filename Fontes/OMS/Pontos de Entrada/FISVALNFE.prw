/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer     | 11/10/2017 | Acerto da ordem do SF2 para nota de Remessa - Chamado 21974 
-------------------------------------------------------------------------------------------------------------------------------
Josué Danich      | 26/10/2018 | Inclusão rotinas de transmissão e monitor por carga - Chamado 26701
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer     | 14/03/2022 | Nova validação da NF de remessa  - Chamado 39457
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#include "report.ch"
#include "protheus.ch"

/*
===============================================================================================================================
Programa----------: FISVALNFE()
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 21/08/2017 
===============================================================================================================================
Descrição---------: Ponto de entrada na transmissão do SPED apos selecionar as notas
===============================================================================================================================
Parametros--------: Recebe aValNFe Posições:
		Aadd(aValNFe,IF((cAliasSF3)->F3_CFO < "5","E","S"))// 1
		Aadd(aValNFe,(cAliasSF3)->F3_FILIAL)  // 2
		Aadd(aValNFe,(cAliasSF3)->F3_ENTRADA) // 3
		Aadd(aValNFe,(cAliasSF3)->F3_NFISCAL) // 4
		Aadd(aValNFe,(cAliasSF3)->F3_SERIE)   // 5
		Aadd(aValNFe,(cAliasSF3)->F3_CLIEFOR) // 6
		Aadd(aValNFe,(cAliasSF3)->F3_LOJA)    // 7
		Aadd(aValNFe,(cAliasSF3)->F3_ESPECIE) // 8
		Aadd(aValNFe,(cAliasSF3)->F3_FORMUL)  // 9
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER FUNCTION FISVALNFE()

LOCAL aValNFe:= PARAMIXB
LOCAL _lRet  := .T.
LOCAL _cChave:= aValNFe[2]+aValNFe[4]+aValNFe[5]+aValNFe[6]+aValNFe[7]//aValNFe[2]+SC9->C9_NFISCAL+SC9->C9_SERIENF+SC9->C9_CLIENTE+SC9->C9_LOJA)
Local _aSC5	 := GetArea("SC5")
Local _aSF2	 := GetArea("SF2")

BEGIN SEQUENCE

   SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
   If !SF2->(MsSeek(_cChave))
      BREAK
   ENDIF
   
   //Se passou por filtro de carga faz a conferência se está selecionada a nota
   if select ("IT_TRB") > 0
	
		DBSelectArea("IT_TRB")
		IT_TRB->( DBSetOrder(1) )
			
		IT_TRB->(MsSeek( alltrim(SF2->F2_DOC)  , .T. ))
		
		If !(alltrim(IT_TRB->TRBF_DOC) == alltrim(SF2->F2_DOC) .AND. IsMark( "TRBF_OK" , _cMarkado ))
		
		  _lret := .F.
		  BREAK
		
		Endif 
	
   Endif
   

   SC5->(DbSetOrder(1))
   IF !SC5->(DBSEEK(SF2->F2_FILIAL+SF2->F2_I_PEDID)) 
      BREAK
   ENDIF

   IF !SC5->C5_I_OPTRI $ "F,R" 
      BREAK
   ENDIF

   _nRecSC5:= SC5->(RECNO())
   _nRecSF2:= SF2->(RECNO())
   _cPedRemessa := SC5->C5_I_PVREM
   _cPedFaturam := SC5->C5_I_PVFAT
   _cProblema   := _cSolucao := ""
   SF2->(DBORDERNICKNAME("IT_I_PEDID"))

//  *****************     NOTA FICAL DE VENDA  ********************
   IF SC5->C5_I_OPTRI = "F" // Estou no PV de Faturamento e vou buscar o de Remessa
      IF !SC5->(DBSEEK(xFilial()+_cPedRemessa)) .OR. !SF2->(DBSEEK(xFilial()+_cPedRemessa))
         _cProblema:="Nota Fiscal do Pedido de Remessa : "+_cPedRemessa+" nao gerada."
         _cSolucao :="Transmitir essa Nota de Venda: "+aValNFe[4]+" somente apos gerar a nota do Pedido de Remessa."
         _lRet:= .F.
      ENDIF
//  *****************     NOTA FICAL DE REMESSA 42 ********************
   ELSEIF SC5->C5_I_OPTRI = "R" // ... SE O TIPO ATUAL FOR O PV DE REMESSA BUSCA A NF DE FATURAMENTO

     SA1->(DbSetOrder(1))
     If SA1->( DBSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ) ) .AND. SA1->A1_I_OBRAD = "S"
        IF EMPTY(SF2->F2_I_NTRIA)  //SF2 JÁ ESTA POSICIONADO NA LINHA 55
           _cProblema:="Nota Fiscal do Pedido de Remessa : "+_cPedRemessa+" nao possui os dados do adquirente."
           _cSolucao :="Transmitir essa Nota de Remessa (Oper.42) : "+aValNFe[4]+" somente apos colocar os dados do adquirente."
           _lRet:= .F.
        ENDIF     
        IF SF2->(DBSEEK(xFilial()+_cPedFaturam)) .AND. EMPTY(SF2->F2_CHVNFE)
           _cProblema:="Nota Fiscal de Venda (Oper.05) não transmitida para o Pedido : "+_cPedFaturam+" e Nfe : "+SF2->(F2_DOC+" "+F2_SERIE )
           _cSolucao :="Transmissão da Nota de Remessa (Oper.42) somente apos a Transmissão da Nota fiscal de Vendas (Oper.05)."
           _lRet:= .F.
        ENDIF
     ENDIF
      
     IF !SC5->(DBSEEK(xFilial()+_cPedFaturam)) .OR. !SF2->(DBSEEK(xFilial()+_cPedFaturam))
         _cProblema:="Nota Fiscal de Venda (Oper.05) não gerada para o do Pedido : "+_cPedFaturam+"."
         _cSolucao :="Transmissão da Nota de Remessa (Oper.42) somente apos a Transmissão da Nota fiscal de Vendas (Oper.05)."
         _lRet:= .F.
     ENDIF


   ENDIF

   IF _lRet
      IF EMPTY(SF2->F2_I_MENOT)
         _cProblema:="Campo de mensagem da Operacao Triangular não preenchido, Nota: "+aValNFe[4]+" Pedido: "+ALLTRIM(_cPedRemessa+_cPedFaturam)//Sempre um outro vai estar preenchido senão é que deu xabu
         _cSolucao :="Entrar em contato com a area de TI com printe dessa mensagem."
         _lRet  := .F.
      ENDIF
   ENDIF
   IF !EMPTY(_cProblema)
      U_ITMSG(_cProblema,"ATENÇÃO",_cSolucao,1)
   ENDIF

END SEQUENCE

Restarea(_aSC5) 
Restarea(_aSF2) 

RETURN _lRet
