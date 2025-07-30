/*
================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
================================================================================================================================
 Autor       |   Data   |                              Motivo                      										 
--------------------------------------------------------------------------------------------------------------------------------
Julio Paz    | 21/09/16 | Chamado 15769. Alterada a rotina p/ permitir a digitação do cód. projeto independente da aplicação.
--------------------------------------------------------------------------------------------------------------------------------
Julio Paz    | 17/07/17 | Chamado 20777. Virada de versão da P11 para a versão P12. Ajustes no fonte para a versão P12.                             
--------------------------------------------------------------------------------------------------------------------------------
Lucas Borges | 03/10/19 | Chamado 28346. Removidos os Warning na compilação da release 12.1.25.
--------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 22/10/19 | Chamado 30921. Tratamento para o campo NOVO CLAIM. 
--------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 01/11/19 | Chamado 30987. Atualizar valores em real dos itens.
--------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 16/12/19 | Chamado 31462. Novas Validadoçoes para os campos custumizados. 
--------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 13/07/20 | Chamado 33490. Implementado o controle de "sub-investimentos" para o compras -
--------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 04/03/22 | Chamado 38650. Reiniciar os campos C7_I_MEAGE / C7_I_QTORI na copia. 
--------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 08/02/23 | Chamado 42719. Acrescentada a opcao NF no campo C7_I_URGEN : S(SIM), N(NAO) F(NF).
--------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer| 15/07/23 | Chamado 47732. Ajuste do tamanho do titulo "Compra Direta" na tela via Web.
================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina.
//====================================================================================================
#include "protheus.ch"

/*
===============================================================================================================================
Programa----------: MT120TEL
Autor-------------: Talita Teixeira
Data da Criacao---: 31/01/2013
===============================================================================================================================
Descrição---------: Rotina responsavel pela inclusão do campo aplicação no cabeçalho do pedido de compra. 
					Localização: Function A120PEDIDO - Função do Pedido de Compras responsavel pela inclusão, alteração, exclusão
					e cópia dos PCs.
					Em que Ponto: Se encontra dentro da rotina que monta a dialog do pedido de compras antes  da montagem dos 
					folders e da chamada da getdados.
===============================================================================================================================
Parametros--------: PARAMIXB[1] -> O -> Objeto da dialog do Pedido de Compras
                    PARAMIXB[2] -> A -> Array contendo a posição dos gets do Pedido de Compras
                    PARAMIXB[3] -> A -> Array contendo os objetos relacionado aos campos dos folders do Pedido de Compras
                    PARAMIXB[4] -> N -> Opção selecionada no Pedido de Compras (inclusão, alteração, exclusão, etc.)
                    PARAMIXB[5] -> N -> Número do RECNO do registro do Pedido de Compras selecionado
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MT120TEL()

Local aArea		:= GetArea()  
Local oNewDialog:= PARAMIXB[1]
Local aPosGet	:= PARAMIXB[2]
Local nOpcx		:= PARAMIXB[4]
Local _nLinA    := 62
Local _nLinB    := 73
Local _nLinC    := 51  , _nX
Local nPosPreco := aScan(aHeader,{|x|AllTrim(x[2])=="C7_PRECO"})  
Local _nC7PRURS := aScan(aHeader,{|x|AllTrim(x[2])=="C7_I_PRURS"})
Local _nC7PRTRS := aScan(aHeader,{|x|AllTrim(x[2])=="C7_I_PRTRS"})
Local _nC7TOTAL := aScan(aHeader,{|x|AllTrim(x[2])=="C7_TOTAL"})
Local nPProduto := aScan(aHeader,{|x|AllTrim(x[2])=="C7_PRODUTO"})
Local nPosTabPre:= aScan(aHeader,{|x|AllTrim(x[2])=="C7_CODTAB"})  
//Local nPosQuant := aScan(aHeader,{|x|AllTrim(x[2])=="C7_QUANT"})  

Public cClaim	    := "2"//CLAIM
Public cAplic		:= ""
Public cUrgen		:= " "
Public cCompD		:= " "
Public cCInve		:= Space(TamSX3("C7_I_CDINV")[1])
Public cDsInv		:= Space(TamSX3("C7_I_DSINV")[1])
Public lSolic		:= .F.

IF lCop // lCop é PRIVATE DA lCopia que indica que é copia 
   AIB->(dbSetOrder(1))//AIB_FILIAL+AIB_CODFOR+AIB_LOJFOR+AIB_CODTAB+AIB_ITEM
   AIA->(dbSetOrder(1))//AIA_FILIAL+AIA_CODFOR+AIA_LOJFOR+AIA_CODTAB
   For _nX := 1 To Len( aCols )

       aCols[_nX][nPosTabPre] := SPACE(LEN(AIB->AIB_CODTAB))
       
       If AIA->(DbSeek(xFilial("AIA")+CA120FORN+CA120LOJ)) 
       
          DO WHILE AIA->(!EOF()) .AND. xFilial("AIA")+CA120FORN+CA120LOJ == AIA->(AIA_FILIAL+AIA_CODFOR+AIA_LOJFOR)
       
             IF AIA->AIA_DATDE <= DATE() .AND.  AIA->AIA_DATATE >= DATE() .AND. AIA->AIA_I_SITW = "A"//DENTRO DA VIGENCIA E APROVADA
               IF AIB->(DbSeek(xFilial("AIB")+CA120FORN+CA120LOJ+AIA->AIA_CODTAB))    
                  DO WHILE AIB->(!EOF()) .AND. xFilial("AIB")+CA120FORN+CA120LOJ+AIA->AIA_CODTAB == AIB->(AIB_FILIAL+AIB_CODFOR+AIB_LOJFOR+AIB->AIB_CODTAB)
                      IF aCols[_nX][nPProduto ] == AIB->AIB_CODPRO .AND. AIB->AIB_MOEDA = nMoedaPed
                         aCols[_nX][nPosTabPre] := AIB->AIB_CODTAB
                         //aCols[_nX][nPosPreco ] := AIB->AIB_PRCCOM   
                         //aCols[_nX][_nC7TOTAL]  := (aCols[_nX][nPosQuant ] * aCols[_nX][nPosPreco ])
                         EXIT
                      ENDIF
                      AIB->(DBSKIP())
                  ENDDO
                  IF !EMPTY(aCols[_nX][nPosTabPre]) 
                     IF !EMPTY(AIA->AIA_CONDPG) .AND. AIA->AIA_CONDPG <> cCondicao
                        cCondicao:= AIA->AIA_CONDPG// cCondicao VARIAVEL PRIVATE DA TELA PADRÃO DO PC
                     ENDIF
                     IF !EMPTY(AIA->AIA_I_TPFR) .AND. AIA->AIA_I_TPFR <> LEFT(cTpFrete,1)
                        cTpFrete :=RetTipoFrete(AIA->AIA_I_TPFR)
                     ENDIF
                     EXIT
                  ENDIF           
                ENDIF
             ENDIF
             AIA->(DBSKIP())
          ENDDO
       ENDIF
   NEXT
ENDIF

If nOpcx <> 3
    cClaim	:= SC7->C7_I_CLAIM//CLAIM
	cAplic	:= SC7->C7_I_APLIC
	cUrgen	:= SC7->C7_I_URGEN
	cCInve	:= SC7->C7_I_CDINV
	cDsInv	:= Posicione("ZZI",1,xFilial("ZZI") + SC7->C7_I_CDINV, "ZZI_DESINV")
	cCompD	:= SC7->C7_I_CMPDI
EndIf           
IF EMPTY(cClaim) .OR. cA120Forn <> "F00004"
   cClaim:= "2"
ENDIF

//=============================
//Posição referente a CLAIM
//=============================
IF SC7->(FIELDPOS("C7_I_CLAIM")) <> 0 
   @ _nLinC  , aPosGet[1,12]+10 SAY 'CLAIM' PIXEL SIZE 28,9 Of oNewDialog
   @ _nLinC-1, aPosGet[1,07]+15 MSCOMBOBOX cClaim ITEMS {"1=Sim","2=Não"} SIZE 036, 010 OF oNewDialog COLORS 0, 16777215 PIXEL Valid {|| Pertence('12')}  WHEN (IF(cA120Forn<>"F00004",cClaim:="2",),(cA120Forn="F00004"))
ENDIF
//=============================
//Posição referente a aplicação
//=============================
@ _nLinA, aPosGet[1,5]-12	SAY 'Aplicação' PIXEL SIZE 28,9 Of oNewDialog 
@ _nLinA, aPosGet[1,6]-25	MSCOMBOBOX oAplic VAR cAplic ITEMS {"C=Consumo","I=Investimento","M=Manutenção","S=Serviço"} SIZE 072, 010 OF oNewDialog COLORS 0, 16777215 PIXEL Valid {|| U_VldInf("P"), Pertence('CIMS')} WHEN MT120Vld()

//===========================================
//Posição referente ao Código de Investimento
//===========================================
@ _nLinB, aPosGet[1,1] 		SAY 'Código Projeto' PIXEL SIZE 60,9 Of oNewDialog  
@ _nLinB, aPosGet[1,2] 		MSGET cCInve F3 'ZZI_P' PIXEL SIZE 10,08 Of oNewDialog WHEN MT120Vld("PROJETO") Valid {|| U_VldInf("I")}  
@ _nLinB, aPosGet[1,2]+50	MSGET cDsInv PIXEL SIZE 80,08 Of oNewDialog WHEN .F.

//============================
//Posição referente ao Compra Direta
//============================
@ _nLinB, aPosGet[1,3]		SAY 'Compra Direta' PIXEL SIZE 60,9 Of oNewDialog 
@ _nLinB, aPosGet[1,4]		MSCOMBOBOX oCompD VAR cCompD ITEMS {"","S=Sim","N=Não","O=Outros"} SIZE 072, 010 OF oNewDialog COLORS 0, 16777215 PIXEL Valid {|| MT120Vld("COMPRA_DIRETA")  }

//==================================
//Posição referente ao Urgente
//==================================
@ _nLinB, aPosGet[1,5]-12	SAY 'Urgente' PIXEL SIZE 28,9 Of oNewDialog 
@ _nLinB, aPosGet[1,6]-25	MSCOMBOBOX oUrgen VAR cUrgen ITEMS {"","S=Sim","N=Não","F=NF"} SIZE 072, 010 OF oNewDialog COLORS 0, 16777215 PIXEL Valid {|| MT120Vld("URGENTE")  } WHEN MT120Vld()  

nSalva:=n
IF _nC7PRURS <> 0 .AND. nPosPreco <> 0 .AND. _nC7PRTRS <> 0 .AND. _nC7TOTAL <> 0
   For _nX := 1 To Len( aCols )
      n:=_nX 
      aCols[n,_nC7PRURS]:=aCols[n,nPosPreco]*nTxMoeda
      aCols[n,_nC7PRTRS]:=aCols[n,_nC7TOTAL]*nTxMoeda
   NEXT
ENDIF

IF lCop // lCop é PRIVATE DA lCopia que indica que é copia 
   nPosQt      := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_QUANT"})
   nPosQtOri   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_I_QTORI"})
   nPosMELT    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_I_MEAGE"})
   For _nX := 1 To Len( aCols )
      aCols[_nX,nPosQtOri]:=aCols[_nX,nPosQt]
      aCols[_nX,nPosMELT ]:=" "
   NEXT
ENDIF
n:=nSalva

RestArea(aArea)

Return

/*
===============================================================================================================================
Programa----------: MT120Vld
Autor-------------: Alex Wallauer
Data da Criacao---: 16/12/2019
===============================================================================================================================
Descrição---------: Validações e edições de campor custumizados
===============================================================================================================================
Parametros--------: Origem
===============================================================================================================================
Retorno-----------: .T. ou .F.
===============================================================================================================================
*/
Static Function MT120Vld(cCampo)
Local lRet := .T. , _nX
Local _nPosCdInv	:= aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C7_I_CDINV"})
Local _nPosDsInv	:= aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C7_I_DSINV"})
Local _nPosCdSInv	:= aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C7_I_SUBIN"})
Local _nPosDsSInv	:= aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C7_I_SUIND"})

IF cCampo = NIL
   If INCLUI
   	If lSolic
   		lRet := .F.
   	EndIf
   ElseIf ALTERA
   	If !Empty(SC7->C7_NUMSC)
   		lRet := .F.
   	EndIf
   EndIf
EndIf

IF cCampo = "PROJETO" .AND. lRet
   IF LEFT(cAplic,1) <> "I"
      cCInve:= Space(TamSX3("C7_I_CDINV")[1])
      cDsInv:= Space(TamSX3("C7_I_DSINV")[1])      
      For _nX := 1 To Len( aCols )
          aCols[_nX,_nPosCdInv ]:=cCInve
          aCols[_nX,_nPosDsInv ]:=cDsInv
          aCols[_nX,_nPosCdSInv]:=cCInve
          aCols[_nX,_nPosDsSInv]:=cDsInv
      NEXT
		lRet := .F.
   ENDIF
ENDIF

IF cCampo = "COMPRA_DIRETA" .AND. lRet
   IF cCompD = "S"
      cUrgen:="S"
   ENDIF
ENDIF

IF cCampo = "URGENTE" .AND. lRet
   IF cCompD = "S" .AND. cUrgen <> "S"
      U_ITMSG("Campo urgente dever esta igual a SIM quando for compra direta igual a SIM",'Atenção!',,1)
      lRet := .F.   
   ENDIF
ENDIF


Return(lRet)
