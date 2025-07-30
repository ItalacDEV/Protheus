/*
==============================================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
==============================================================================================================================================================
Analista    - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
Andre       - Alex Wallauer - 27/03/25 - 28/03/25 - 49970   - Ajuste da leitura do Departamento do usuário para aprovação
Andre       - Alex Wallauer - 07/04/25 - 07/04/25 - 50402   - Correcao das validações das datas da tabela de preço de AIA-> para M->.
Andre       - Alex Wallauer - 10/07/25 -          - 50990   - Correção para não alterar as vairaevis de capa quando o lRetorno = .F. .
==============================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"

/*
===============================================================================================================================
Programa----------: CM010TOK
Autor-------------: Alex Wallauer Ferreira
Data da Criacao---: 28/06/2024
Descrição---------: PE de validação DO OK Final do Cadastro de tabela de preço de Fornecedores dentro da
                    função Com010Tok()/COMA010.PRX. Andre. Chamado: 47732
Parametros--------: ParamIXB[1]
Retorno-----------: lRetorno : .T. ou .F.
===============================================================================================================================
*/
User Function CM010TOK()
 LOCAL nX
 Local nPosProd:=aScan(aHeader,{|x| AllTrim(x[2])=="AIB_CODPRO"})
 Local nPosMoed:=aScan(aHeader,{|x| AllTrim(x[2])=="AIB_MOEDA"})
 Local lRetorno:=ParamIXB[1]
 LOCAL _aProd  :={}
 
 IF !lRetorno
    RETURN lRetorno
 ENDIF
 
 AIB->(dbSetOrder(1))//AIB_FILIAL+AIB_CODFOR+AIB_LOJFOR+AIB_CODTAB+AIB_ITEM
 AIA->(dbSetOrder(1))//AIA_FILIAL+AIA_CODFOR+AIA_LOJFOR+AIB_CODTAB
 
 _cDep:="XXXXXXX"
 PswOrder(1) // Busca por ID
 If PSWSEEK(__cUserID, .T. )
    _aDados:=PSWRET(1)// Retorna vetor com informações do usuário
    _cDep  :=ALLTRIM(_aDados[1][12])// Departamento do usuário
 EndIf
 
 IF UPPER(_cDep) <> "DIRECAO"//para aprovação
    If M->AIA_I_SITW = "A" .AND. (DTOS(M->AIA_DATATE) >= DTOS(DATE()) .OR. EMPTY(DTOS(M->AIA_DATATE)))
       U_ITMSG("Tabela Aprovada não pode ser mais alterada.","Atenção",,1)
       lRetorno := .F.
    ENDIF
 ENDIF
 
 If lRetorno .AND. Empty( M->AIA_I_DTDE ) .OR. Empty( M->AIA_I_DATE ) .OR. ( M->AIA_I_DTDE > M->AIA_I_DATE )
    U_ITMSG("Datas de aprovacao invalidas","Atenção",'Preencha as 2 datas com "Dt.Apr.Final" maior que a "Dt.Apr.Inici" e maior ou igual a hoje.',1)
    lRetorno := .F.
 Endif
 
 nMoeda:=0
 For nX := 1 To Len(aCols)
    If !aCols[nX][LEN(aCols[nX])]
       IF nMoeda = 0
          nMoeda:=aCols[nX][nPosMoed]
       ELSEIF nMoeda <> aCols[nX][nPosMoed]
          U_ITMSG("Tabela com produtos com moedas distintas","Atenção","A Tabela de preços não pode ter produtos com moedas distintas.",1)////"PRODUTO: "+aCols[nX][nPosProd]+" com moeda distinta da moeda dos outros produtos, linha: "+STRZERO(nX,3)
          lRetorno := .F.
          EXIT
       ENDIF
       If ASCAN(_aProd,aCols[nX][nPosProd]) > 0 //( nPosProd == 0 .Or. aCols[nX][nPosProd] == aCols[N][nPosProd])
          U_ITMSG("PRODUTO: "+aCols[nX][nPosProd]+" repetido, linha: "+STRZERO(nX,3),"Atenção","Delete o produto ate ficar uma linha somente dele.",1)
          lRetorno := .F.
       ELSE
          AADD(_aProd,aCols[nX][nPosProd])
       EndIf
    EndIf
 Next
 
 //===============================================================================================================
 // AO INSERIR NOVAS VALIDAÇÕES SOMENTE ACIMA DAQUI , NADA ABAIXO DO IF ABAIXO , SOMENTE ALTERAÇÕES QUE GRAVAM
 //===============================================================================================================
 
 IF lRetorno
    IF UPPER(_cDep) <> "DIRECAO"//para aprovação
       M->AIA_DATDE :=DATE()-2
       M->AIA_DATATE:=DATE()-1
    ELSE//DIRETORIA TEM APROVACAO AUTOMATICO
       M->AIA_DATDE :=M->AIA_I_DTDE
       M->AIA_DATATE:=M->AIA_I_DATE
       M->AIA_I_SITW:="A"
       M->AIA_I_APRO:="Aprovado Automatico por Sr "+Capital(RTrim(UsrFullName(__cUserId)))+" no dia "+DTOC(DATE())+' as '+TIME()
    ENDIF
 ENDIF
 
 IF lRetorno .AND. Inclui
    AIA->(DBSETORDER(1))//AIA->(AIA_FILIAL+AIA_CODFOR+AIA_LOJFOR)
    DO WHILE AIA->(DBSEEK(xFilial("AIA")+M->AIA_CODFOR+M->AIA_LOJFOR+M->AIA_CODTAB))//QUANDO INCLUSAO
       U_M026Num()//GRAVA A VARIAVEL  " M->AIA_CODTAB "
    ENDDO
 ENDIF
 
 IF lRetorno
    SBZ->(DBSetOrder(1))//BZ_FILIAL+BZ_COD
    For nX := 1 To Len(aCols)
       If !aCols[nX][LEN(aCols[nX])]//DELETADOS
          IF SBZ->(dbSeek(xFilial("SBZ")+aCols[nX][nPosProd])) .AND. SBZ->BZ_I_VLDTP <> "S"
             SBZ->(RECLOCK("SBZ",.F.))
             SBZ->BZ_I_VLDTP:= "S"
             SBZ->(MSUNLOCK())
          ENDIF
       EndIf
    Next
 ENDIF

RETURN lRetorno
