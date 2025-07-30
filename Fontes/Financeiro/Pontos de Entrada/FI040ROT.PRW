/*
===============================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-----------------------------------------------------------------------------------------------------------------------------------------------    
Josué Danich  | 15/01/2017 | Chamado 22908 - Inclusão de chamada de visualização de canhoto da nota.                    
Alex Wallauer | 23/01/2018 | Chamado 23332 - Ajuste na chamada do U_VISCANHO()
Julio Paz     | 11/07/2018 | Chamado 25437 - Inclusão de rotina para reabrir e fechar títulos de comissões dos vendedores. 
Julio Paz     | 11/07/2018 | Chamado 44564 - Consulta a Nota Fiscal Original referente a NCC
Igor Melgaco  | 07/11/2023 | Chamado 45465 - Ajustes para envio do boleto por email.
Igor Melgaco  | 09/01/2024 | Chamado 45465 - Ajustes para envio do Email coletando o email do contato do Cliente.
Igor Melgaco  | 20/02/2024 | Chamado 46253 - Ajustes para envio do Email qdo o Cliente não for cadastrado para emissão de boleto exibir msg.
Igor Melgaço  | 25/04/2024 | Chamado 46017 - Ajustes para conceder acesso ao Fonte AFIN034 através de privilegios do configurador 
===============================================================================================================================================

=========================================================================================================================================================
Analista         - Programador       - Inicio     - Envio      - Chamado - Motivo da Alteração
---------------------------------------------------------------------------------------------------------------------------------------------------------
Antonio Ramos    -  Igor Melgaço     - 18/12/2024 - 23/01/2025 - 49056   - Ajustes para gravação de historico de alterações de campo da SE1
=========================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina. 
//====================================================================================================
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"

/*
===============================================================================================================================
Programa--------: FI040ROT
Autor-----------: Josué Danich Prestes
Data da Criacao-: 07/08/2017
===============================================================================================================================
Descrição-------: P.E. para inclusão de botões na tela de manutenção dos títulos a receber no Financeiro - Chamado 16924
				  (Botões inclusos aqui devem ser inclusos no PE FA740BRW para manter o padrão de telas)
===============================================================================================================================
Parametros------: (ParamIxb) = Recebe um array aRotina com o menu padrão e adiciona novos itens ao menu
===============================================================================================================================
Retorno---------: Retorna um array aRotina com o(s) novo(s) itens do menu que foram adicionados.
===============================================================================================================================
*/

User Function FI040ROT() As Array
Local aRotina As Array

aRotina := Paramixb

aAdd( aRotina, {"Desbl Cnab", "U_AFIN024", 0, 3,0,nil}) 
aAdd( aRotina, {"Canhoto"   , "U_VISCANHO( SE1->E1_FILIAL, alltrim(SE1->E1_NUM) )", 0, 2,0,nil}) 
Aadd( aRotina, {"Manutenção Comissões", "U_AFIN026" , 0, 2, 0 ,nil } )
Aadd( aRotina, {"Consulta Nota Orig ", "U_FI040ORI" , 0, 2, 0 ,nil } )
Aadd( aRotina, {"Envia boleto ao Cliente", "U_FI040EM" , 0, 2, 0 ,nil } )
Aadd( aRotina, {"Follow-Up de Contas a Receber", "U_AFIN034" , 0, 2, 0 ,nil } )
Aadd( aRotina, {"Histórico de Alterações", "U_FI040HIS" , 0, 2, 0 ,nil } )

If FWIsInCallStack("CFGA530") // Trecho para conceder acesso ao Fonte AFIN034 através de privilegios do configurador 
   aAdd( aRotina, { 'AFIN034 Visualizar' , 'AxVisual', 0, 2, 0, NIL } )
   aAdd( aRotina, { 'AFIN034 Incluir' , 'AxInclui', 0, 3, 0, NIL } )
   aAdd( aRotina, { 'AFIN034 Alterar' , 'AxAltera', 0, 4, 0, NIL } )
   aAdd( aRotina, { 'AFIN034 Excluir' , 'AxDeleta', 0, 5, 0, NIL } )
EndIf

Return( aRotina )


/*
===============================================================================================================================
Programa--------: FI040ORI
Autor-----------: Igor Melgaço
Data da Criacao-: 07/11/2023
===============================================================================================================================
Descrição-------: Consulta Nota Fiscal Original referente ao Titulo NCC
===============================================================================================================================
Parametros------: 
===============================================================================================================================
Retorno---------: 
===============================================================================================================================
*/
User Function FI040ORI()
Local cQuery As Character
Local aLinha As Array
Local aDados As Array
Local aCabec As Array
Local cTitulo As Character
Local cPict As Character

cQuery  := ""
aLinha  := {}
aDados  := {}
aCabec  := {}
cTitulo := ""
cPict   := ""

If SE1->E1_TIPO == 'NCC'
    
    cPict := PesqPict("SD1","D1_TOTAL")

    cTitulo := "Titulo Filial " + SE1->E1_FILIAL
    cTitulo += IIf(Empty(Alltrim(SE1->E1_PREFIXO)),""," Prefixo " + SE1->E1_PREFIXO)
    cTitulo += " Numero " + SE1->E1_NUM
    cTitulo += " Tipo " + SE1->E1_TIPO
    cTitulo += " Cliente " + SE1->E1_CLIENTE
    cTitulo += " Loja " + SE1->E1_LOJA
    cTitulo += " Nome " + SE1->E1_NOMCLI

    cQuery := " SELECT D1_FILIAL,"
    cQuery += "   D1_NFORI, "
    cQuery += "   D1_SERIORI, " 
    cQuery += "   D1_DATORI, "
    cQuery += "   SUM(D1_TOTAL) TOTAL "
    cQuery += " FROM SD1010 SD1 "
    cQuery += "  INNER JOIN SE1010 SE1 ON D1_FILIAL = E1_FILIAL "
    cQuery += "   AND D1_SERIE = E1_PREFIXO "
    cQuery += "   AND D1_DOC = E1_NUM "
    cQuery += "   AND E1_TIPO = 'NCC' "
    cQuery += "   AND D1_FORNECE = E1_CLIENTE "
    cQuery += "   AND D1_LOJA = E1_LOJA "
    cQuery += " WHERE SD1.D_E_L_E_T_ = ' ' "
    cQuery += "   AND D1_TIPO = 'D' "
    cQuery += "   AND E1_FILIAL = '"+ SE1->E1_FILIAL + "' "
    cQuery += "   AND E1_SERIE = '" + SE1->E1_PREFIXO + "' "
    cQuery += "   AND E1_NUM = '" + SE1->E1_NUM + "' "
    cQuery += "   AND E1_TIPO = 'NCC' "
    cQuery += "   AND E1_CLIENTE = '" + SE1->E1_CLIENTE+ "' "
    cQuery += "   AND E1_LOJA = '" + SE1->E1_LOJA+ "' "
    cQuery += " GROUP BY D1_FILIAL, D1_NFORI, D1_SERIORI, D1_DATORI "

    cQuery := ChangeQuery(cQuery)

    If Select("TRB") <> 0
        TRB->( DBCloseArea() )
    EndIf

    TCQUERY cQuery NEW ALIAS "TRB"

    TRB->( DbGoTop() )

    Do While !TRB->(EOF())
        aLinha := {}
        Aadd(aLinha,(TRB->D1_FILIAL))
        Aadd(aLinha,(TRB->D1_NFORI))
        Aadd(aLinha,(TRB->D1_SERIORI))
        Aadd(aLinha,(DTOC(STOD(TRB->D1_DATORI))))
        Aadd(aLinha,(TransForm(TRB->TOTAL,cPict)))
        AADD(aDados,aLinha)

        TRB->(DbSkip())
    EndDo

    Aadd(aCabec,("Filial"))
    Aadd(aCabec,("NF Original"))
    Aadd(aCabec,("Serie"))
    Aadd(aCabec,("Emissao"))
    Aadd(aCabec,("Total"))

    U_ITListBox( 'Consulta Nota Original '+cTitulo , aCabec , aDados , .F. , 1 )
Else
    U_ItMsg("Consulta somente para títulos de Devolução do tipo NCC.","Atenção",,1)
EndIf

Return


/*
===============================================================================================================================
Programa--------: FI040EM
Autor-----------: Igor Melgaço
Data da Criacao-: 27/07/2023
===============================================================================================================================
Descrição-------: Envio por email de boleto referente ao titulo posicionado.
===============================================================================================================================
Parametros------: 
===============================================================================================================================
Retorno---------: 
===============================================================================================================================
*/
User Function FI040EM()
Local lContinua As Logical
Local cMensagem As Character

lContinua := .T.
cMensagem := ""

If !(SE1->E1_SALDO > 0)
    lContinua := .F.
    cMensagem := "Título sem saldo para impressão do boleto."
ElseIf !(SE1->E1_TIPO == 'NF ' .OR. SE1->E1_TIPO == 'ICM') .AND. SUBSTR(SE1->E1_TIPO, 3, 1) <> '-'
    lContinua := .F.
    cMensagem := "Título inválido para impressão do boleto."
ElseIf Empty(Alltrim(SE1->E1_NUMBCO))
    lContinua := .F.
    cMensagem := "Ainda não foi gerado a impressão do boleto deste título."
Else
    DbSelectArea("SA1")
    DbSetOrder(1)
    If Dbseek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA)
        If SA1->A1_I_IBOLE == 'N'
            lContinua := .F.
            cMensagem := "Cliente não cadastrado para emissão de boleto. Campo A1_I_IBOLE = 'N' "
        EndIf
    EndIf
EndIf

If lContinua
    U_RFIN002()
Else
    U_ItMsg(cMensagem,"Atenção",,1)
EndIf

Return

/*
===============================================================================================================================
Programa--------: FI040HIS
Autor-----------: Igor Melgaço
Data da Criacao-: 02/01/2025
===============================================================================================================================
Descrição-------: Consulta histórico de Alterações
===============================================================================================================================
Parametros------: 
===============================================================================================================================
Retorno---------: 
===============================================================================================================================
*/
User Function FI040HIS()
U_MOMS045G( SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA), "Historico","SE1",1)
Return
