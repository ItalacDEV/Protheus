/*
====================================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
====================================================================================================================================
 Autor       |   Data   |                               Motivo
====================================================================================================================================
Alex Wallauer| 03/02/22 | Chamado 39057. Alteração na validacao dos campos A1_VEND / A1_I_VEND2.
Alex Wallauer| 21/03/22 | Chamado 37526. Retirar o Bloqueio PV, quando for FOB de Produto diferente de PA.
Alex Wallauer| 21/03/22 | Chamado 38943. Retirar o Bloqueio PV, na validação do PV se for Tipo de Operação 05-Triangular.
Julio Paz    | 01/04/22 | Chamado 36404. Inclusão de tratamentos para calculo de peso integrados do RDC na alteração de pedidos.
Jerry        | 29/04/22 | Chamado 38883. Ajuste na Efetivação Automatica Pedido Portal retirando paradas em tela.
Igor Melgaço | 20/05/22 | Chamado 39908. Ajuste para validação de Tipo de FOB.
Igor Melgaço | 20/05/22 | Chamado 39908. Ajuste na exibição da msg de validação do desconto.
Julio Paz    | 08/06/22 | Chamado 40365. Inclusão de rotina para cálculo do desconto de frete fob.
Julio Paz    | 21/06/22 | Chamado 39908. Para calcular Frete/Seguro Fob, validar operação em parâmetro/dt emissão superior param.
Jerry        | 21/07/22 | Chamado 40783. Corrigir gravação do Campo de Desconto (C5_DESCONT) quando Frete FOB não grava.
Julio Paz    | 05/09/22 | Chamado 41123. Inclusão Validações p/permitir manutenção em PV Transf. apenas usuarios autorizados.
Julio Paz    | 20/09/22 | Chamado 41205. Alteração na forma de validar a terceira unidade de medida, para Qtde Fracionada.
Alex Wallauer| 19/10/22 | Chamado 41508. Colocado FWIsInCallStack("U_MOMS066") Para não perguntar o MOTIVO DO CORTE
Igor Melgaço | 13/12/22 | Chamado 41604. Novo tratamento para Pedidos de Operacao Triangular.
Alex Wallauer| 06/01/23 | Chamado 42203. Validações dos Cadastros de GerxCooxVendxFils. de Troca NF e ProdxFils. de Faturamento.
Alex Wallauer| 23/02/23 | Chamado 43076. Busca no Cadastro de Assistente Adm Comercial responsável (U_BuscaAssistente()).
Julio Paz    | 06/03/23 | Chamado 43144. Recalcula as quantidades de Pallets dos itens na validação para inclusão e alteração.
Julio Paz    | 07/03/23 | Chamado 43199. Corrigir gravação campo centro custo(C6_CC), na copia/alteração/desmembramento e Transf.
Jerry        | 27/03/23 | Chamado 43410. Ajustar Qtd de Vol. ao gravar PV que conter Produto com controle de Qtd. na 3a UM
Alex Wallauer| 28/03/23 | Chamado 42203. Nova validacao para o Cadastro de Gerente Filiais de Troca NF X Itens. de Faturamento.
Alex Wallauer| 14/04/23 | Chamado 42203. Nova validacao para o Cadastro de Gerente Filiais de Troca NF X Itens. de Faturamento.
Alex Wallauer| 15/04/23 | Chamado 43562. Se não for mais TRATAMENTO DE OPERACAO TRIANGULAR limpa os campos relacionados.
Alex Wallauer| 22/05/23 | Chamado 43864. Busca no Cadastro de Local de Embarque (U_BuscaLocalEmbarque()).
Igor Melgaço | 27/07/23 | Chamado 44407. Validação de produtos bloqueados por filial.
Alex Wallauer| 14/08/23 | Chamado 44489. Ajuste para solicitar o motivo de corte na alteracao.
Alex Wallauer| 22/08/23 | Chamado 44799. Ajuste da função MT_ITMSG para receber a varivel de Texto do botão "Mais Detalhes".
Alex Wallauer| 28/08/23 | Chamado 44818. Ajuste nas validações do produto bloqueado na SBZ - Indicadores de Produtos.
Alex Wallauer| 28/08/23 | Chamado 43613. Ajuste na mensagem do Prazo Médio de Condição Pagamento do Cliente x Pedido.
Alex Wallauer| 06/10/23 | Chamado 45043. Desvio da função MT410_CT() para quando MSEXEAUTO do pedido chamado da função U_AOMS108.
Alex Wallauer| 11/10/23 | Chamado 45294. Correção do error.log: função nao existe ITMSGLOG.
Alex Wallauer| 25/10/23 | Chamado 44881. Tela de preencher observação e justificativa para alteração de C5_I_AGEND OU C5_I_DTENT.
Alex Wallauer| 25/10/23 | Chamado 45372. Alterar para que consulte o tipo de Operação por um Parâmetro.
Alex Wallauer| 23/01/24 | Chamado 46145. Jerry. Ativação do botão mais detalhes na validação Produto ativo na tabela de Preço.
Alex Wallauer| 08/02/24 | Chamado 44782. Jerry. Ajustes para a nova opcao de tipo de entrega: O = Agendado pelo Op.Log.
Alex Wallauer| 14/02/24 | Chamado 46279. Jerry. Alteracao da condição para Busca da Assistente do Pedido.
Alex Wallauer| 27/02/24 | Chamado 46373. Andre. Criacao do controlo de contagem de alterações para data entrega/tipo agendamento.
Julio Paz    | 12/03/24 | Chamado 45229. Incluir parâmetro p/determinar se a integração WebS. será TMS Multiembarcador ou RDC
Julio Paz    | 10/04/24 | Chamado 46888. Ajuste da validação data de entrega do pedido de vendas para ser por capa e não por item.
Alex Wallauer| 19/06/24 | Chamado 47415. Jerry. Ajuste da validação de condição de pagamento para validar na inclusao e alteracao.
Alex Wallauer| 26/06/24 | Chamado 47390. Jerry. Gravação dos campos novos C5_I_DIASV e C5_I_DIASO.
Alex Wallauer| 24/07/24 | Chamado 47864. Jerry. Quando exclusão não executar U_M410VLSDX() e ajustes em todos os IFs de Exclusão.
Alex Wallauer| 26/07/24 | Chamado 34804. Andre. Nova validação para os pedidos com tipo = "B" para a operacao da capa e dos itens.
Igor Melgaço | 01/07/24 | Chamado 47184. Jerry. Ajustes para gravação do campo C6_I_PRMIN
Alex Wallauer| 07/08/24 | Chamado 48134. Andre. Retirada das alterações solicitadas no chamado 34804.
Lucas Borges | 09/10/24 | Chamado 48465. Lucas. Retirada manipulação do SX1
==============================================================================================================================================================================================================================================================
Analista       - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================================================================================================================
Jerry          - Igor Melgaço  - 05/09/24 - 17/09/24 - 48570   - Jerry. Correção de error.log na função MT_ITmsg().
Jerry          - Alex Wallauer - 17/09/24 - 17/09/24 - 48570   - Criação e tratamento do parametro IT_VOLN3M.
Bremmer        - Alex Wallauer - 11/10/24 - 16/10/24 - 48700   - Alteracao para não justificar a alteração da data de entrega do PV quando for M->C5_I_AGEND = I.
Antônio        - Julio Paz     - 02/10/24 - 21/10/24 - 33879   - Desenvolvimento de rotina de geração de pedidos de Pallets de devolução para armazéns 40 e 42. Pedidos sem geração de carga.
Jerry          - Alex Wallauer - 23/10/24 - 24/10/24 - 48885   - Ajuste para quando for Transferencia (AOMS032) atualizar os campos C5_I_DIASV e C5_I_DIASO.
Antonio Ramos  - Igor Melgaço  - 05/11/24 - 06/11/24 - 48813   - Ajustes para validação de desconto contratual.
Jerry          - Alex Wallauer - 06/11/24 - 07/11/24 - 49075   - Ajuste para somente quando for _laoms074 não fazer a validacao das UNIDADES DE MEDIDA.
Jerry          - Alex Wallauer - 12/11/24 - 12/11/24 - 49116   - Retirado validações de unidades para quando é Exclusão.
Jerry          - Alex Wallauer - 03/12/24 - 03/12/24 - 49253   - Inserido Local de Embarque (M->C5_I_LOCEM) como parametro na função U_OMSVLDENT de calculo dos campos C5_I_DIASV/C5_I_DIASO.
Jerry          - Alex Wallauer - 10/01/24 - 21/01/25 - 44092   - Novo Tratamento para Tabela de Preços no Pedido de Vendas. Função U_ITTABPRC().
Antonio Ramos  - Igor Melgaço  - 30/12/24 - 21/01/25 - 49149   - Ajustes para validação de pedidos colocados para filiais.
Jerry          - Alex Wallauer - 22/01/25 - 20/03/25 - 44092   - Ajustes no Tratamento da Tabela de Preços no Pedido de Vendas. Função U_ITTABPRC().
Antonio Ramos  - Igor Melgaço  - 14/02/25 - 20/03/25 - 49432   - Ajustes para validação de pedidos com op 42.
Jerry          - Julio Paz     - 21/02/25 - 20/03/25 - 48849   - Criação de Validação de TES Inteligente em Pedidos de Vendas do Tipo Operação Triangular.
Jerry          - Igor Melgaço  - 25/02/24 - 20/03/25 - 39201   - Ajustes para contabilizar a quantidade de alterações efetuadas no pedido de vendas.
Jerry          - Julio Paz     - 11/03/25 - 20/03/25 - 48837   - Inclusão de validação para clientes com condição de pagamento especial.
Jerry          - Alex Wallauer - 27/03/25 - 01/04/25 - 50330   - Inclusão de validação para clientes com condição de pagamento especial. Ajustes na função que retorna a condição de pagamento.
Jerry          - Julio Paz     - 08/04/25 - 14/04/25 - 48275   - Inclusão de validação de produtos bloqueados por filial, com base no cadastro de produtos bloqueados por filial.
Jerry          - Julio Paz     - 08/04/25 - 02/05/25 - 48275   - Alterações nas regras de validação de produtos bloqueados por filial, com base no cadastro de produtos bloqueados por filial.
Jerry          - Julio Paz     - 07/05/25 - 12/05/25 - 49596   - Inclusão de validação para não permitir digitar data de entrega superior a data maxima permitida para agendamentos, na inclusão/copia de pedidos do tipo agendado/amandado com multa.
Jerry          - Julio Paz     - 08/04/25 - 12/05/25 - 48275   - Alterações nas regras de validação de produtos bloqueados por filial, com base no cadastro de produtos bloqueados por filial.
Antonio Ramos  - Igor Melgaço  - 14/02/25 - 16/05/25 - 49432   - Ajustes para validação de pedidos com op 42.
Antonio Ramos  - Igor Melgaço  - 16/05/25 - 29/05/25 - 49409   - Ajustes para validação de pedidos com op 15.
Vanderlei Alves- Alex Wallauer - 06/06/25 - 10/06/25 - 45229   - Retirada do parâmetro p/determinar se a integração WebS. será TMS Multiembarcador ou RDC para chamar a U_IT_TMS(_cLocEmb).
Vanderlei Alves- Alex Wallauer - 09/06/25 - 10/06/25 - 45229   - Tratamento para validar FWIsInCallStack("U_AOMS085B") junto com FWISINCALLSTACK("U_ALTERAP").
Andre Carvalho - Igor Melgaço  - 11/06/25 - 11/06/25 - 50716   - Ajustes para correção de msg de erro.
Jerry          - Julio Paz     - 13/05/25 - 18/07/25 - 49758   - Ajustes nas telas de solicitações de justificativas para alterações de tipo de agendamento e data de entrega.
Jerry          - Julio Paz     - 29/05/25 - 18/07/25 - 50758   - Realização de Ajustes nas Regras da Rotina de Bloqueio de Produtos por Filial 
Jerry          - Julio Paz     - 23/06/25 - 18/07/25 - 49825   - Inclusão de Validação para não permitir apenas quantidades em segunda unidade de medida em multiplos de Pallet.
Jerry          - Alex Wallauer - 07/07/25 - 18/07/25 - 51280   - Ajustes do cancelamento de carga para deletar os Trocas NF senão tiver mais SC9 para o pedido do DAI.
================================================================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"

#DEFINE _ENTER CHR(13)+CHR(10)

/*
===============================================================================================================================
Programa----------: MT410TOK 
Autor-------------: Wodson Reis
Data da Criacao---: 04/08/2009
===============================================================================================================================
Descrição---------: PE de validação do pedido de vendas.
===============================================================================================================================
Parametros--------: ExpA01 - Se a primeira posicao do array conter 1, o usuario pressionou Ok, caso contrario Cancelar.
===============================================================================================================================
Retorno-----------: ExpL01 - Se .T. continua a operacao, se .F. nao volta pra tela de pedido sem fazer nada.
===============================================================================================================================
*/
User Function MT410TOK() As Logical

 PRIVATE _lRet As Logical
 PRIVATE _lContOK := .T. As Logical
 
 _lRet:=.T.

 If .NOT. ( FWIsInCallStack("MDIEXECUTE") .OR. FWIsInCallStack("SIGAADV") )
    _lRet:=MT410_OK()
 ELSE
    FWMSGRUN( ,{|oProc|  _lRet:=MT410_OK(oProc) }  , "Aguarde...", "Validando dados..."  )//ATEÇÃO TEM GRAVAÇÃO DENTRO DESSA FUNÇÃO
    // NOVAS VALIDAÇOES SEM GRAVAÇÃO NA BASE PROCURE POR "COLOQUE AQUI" E INSIRA AS VALIDACOES LÁ POR FAVOR, NÃO COLOQUE NADA AQUI
 ENDIF

RETURN _lRet

/*=============================================================================================================================
Programa----------: MT410_OK()
Autor-------------: Alex Wallauer
Data da Criacao---: 21/09/2018
===============================================================================================================================
Descrição---------: PE de validação do pedido de venda
===============================================================================================================================
Parametros--------: NENHUM
===============================================================================================================================
Retorno-----------: ExpL01 - Se .T. continua a operacao, se .F. nao volta pra tela de pedido sem fazer nada.
===============================================================================================================================*/
STATIC Function MT410_OK(oProc)

Local nX As Numeric
Local nN As Numeric//Restaura o valor de n, que eh a variavel publica do protheus que indica a linha do aCols.
Local _aArea As Array
Local lBlq2 As Logical
Local lBlq3	As Logical
Local cTes As Character
Local nPosProduto As Numeric
Local nPosTes As Numeric
Local cItens As Character
Local cPosPrd As Character
Local cFatCon As Character
Local cPosVlr As Character
Local lPrim	As Logical
Local nTotal As Numeric
Local nDescPer As Numeric
Local cQtdZero As Character
Local nPerc	As Numeric
Local _nValVol As Numeric
Local _aprod As Array
Local _ccodpro As Character
Local _nY As Numeric
Local _cBlqCred As Character
Local nPosDifPe As Numeric
Local _lSegDif As Logical
Local _lMashup As Logical
Local _cFilHabilit As Character // Filiais habilitadas na integracao Webservice Italac x RDC.
Local _cFilOper	 As Character // Filiais a serem validadas
Local _cOperEst	 As Character // Tipos de operações a serem validados           <<<<<<
Local _cProdPe As Character	// Produtos permitidos                            <<<<<<
Local _cPrd3Um As Character // Produtos a validar pela 3ª unidade de medida
Local _cLocval As Character // Armazéns que não valida quantidade fracionada  <<<<<<
Local _cTpOper As Character //Armazena o tipo de operacao que na TES INTELIGENTE pode ter a TES alterada pelo usuario
Local _cProdNFrac As Character // Produtos proibidos de serem fracionados na Venda.
Local _lValAltPVin As Logical // Habilitar para validar se o PV Vinculado foi altearado para outro PV
Local _lLibMas As Logical
Local _nQtdDia As Numeric
Local _nQtdiaT As Numeric
Local _lExec As Logical
Local _cBloqSBZ  As Character
Local _lValCredito AS Logical // Tem que iniciar com .T. pq pode ta vindo de MSEXECAUTO(), com .T. não limpa os campos de validação de credito
Local _nTotPV AS Numeric
Local _ni As Numeric
Local y As Numeric
Local x As Numeric
LOCAL _lTravadoPorAlguem As Logical
LOCAL _aItensLock As Array
Local auser As Array
Local _nRecOrigem As Numeric
Local _cLocalNFrac  As Character // Armazens/Locais vinculados aos produtos proibidos de serem fracionados na Venda.
Local _cTipOpNFrac  As Character	// Tipos de Operações vinculados aos produtos proibidos de serem fracionados na Venda.
Local _l108 As Logical
Local _laoms074 As Logical
LOcal _nnipre As Numeric
Local _nRegVinc As Numeric
Local _lEstornoRDc As Logical
Local _nSalvaN As Numeric
Local _cUser As Character
Local _cchep  As Character
Local _nRegSC5 As Numeric
Local _aOrd As Array
LOcal _cFilSC5  As Character
Local _cBlqContrato As Character
Local _lUsaNovo As Logical
Local _cGrupoP  As Character
Local _cUFPedV  As Character
Local _cTipoProd As Character
Local _cDescriPrd As Character
Local _cDescTBPrc  As Character
Local nZ As Numeric
Local cItensnZ  As Character
Local aTabnZ As Array
Local nPesCarg As Numeric
Local nPsBru As Numeric
Local _cTipoPedido  As Character
Local _ccondr As Character
Local _dHoje As Date
Local _lItemAlterado As Logical
Local _cRedeCliente As Character
Local _lSimplNac As Logical
Local _cSimplNac As Character
Local _aBlqprc As Array
Local _lPrcErr As Logical
Local _nFaixa As Numeric
Local _cMsgPrc As Character
Local _cFilCarreg As Character
Local _lAoms112 As Logical
Local _lFob As Logical
Local _nDescPTon As Numeric
Local _cOperFret As Character
Local _dDtCalcFr As Date
Local _cOperTran As Character
Local _cCrtl3Um As Character // Produtos a validar quantidade fracionada na terceira unidade de medida.

Local _cTextoUnd As Character
Local _cTextCalc As Character

Local _cOperTriangular As Character
Local _cOperFat As Character
Local _cOperRemessa As Character
Local _aProdBlq As Array

//Local _lWsTms As Logical // Indica se rotina de integração WebService é TMS Multi-Embarcador ou RDC.
Local _cTextoMsg As Character

Local _cLocalPCh As Character
Local _nPos As Numeric
Local _nPosFilAnt As Numeric

Local _cSuframa  As Character
Local _cEstCli   As Character
Local _cEstFil   As Character
Local _cItemOpeT As Character
Local _cTESOperT As Character

Local _nPosDescr As Numeric

Local _dDtAgeMax 
Local _dDtAgeEnt
Local __cCodCli As Character
Local __cLojaCli As Character
Local _cFilValid As Character

IF !Inclui .AND. !(SC5->C5_NUM == M->C5_NUM)
   SC5->(DBSEEK(xFilial()+M->C5_NUM))//RePosiciona caso não esteja posicionado
ENDIF

Private lRet As Logical //Padrao variavel LOCAL
Private cNumPrd As Character
Private aItens As Array
Private lDifPes As Logical
Private lTemItemPA As Logical
Private _lItemNovo As Logical


nX			    := 1
nN			    := N //Restaura o valor de n, que eh a variavel publica do protheus que indica a linha do aCols.
_aArea		    := GetArea()
lBlq2		    := .F.
lBlq3	     	:= .F.
cTes			:= ""
nPosProduto	    := 0
nPosTes		    := 0
cItens 		    := ""
cPosPrd 	    := ""
cFatCon 		:= ""
cPosVlr		    := ""
lPrim			:= .T.
nTotal		    := 0
nDescPer  	    := 0
cQtdZero  	    := ""
nPerc			:= 0
_nValVol		:= 0
_aprod		    := {}
_ccodpro		:= " "
_nY			    := 1
_cBlqCred		:= '  '
nPosDifPe		:= 0
_lSegDif		:= .T.
_lMashup		:= U_ItGetMV("IT_MASHUP",.F.)
_cFilHabilit 	:= U_ITGETMV( 'IT_FILINTWS' , '' ) // Filiais habilitadas na integracao Webservice Italac x RDC.
_cFilOper		:= U_ITGETMV( "IT_FILOPE" , "  ")	// Filiais a serem validadas
_cOperEst		:= U_ITGETMV( "IT_OPEEST" , "  ")	// Tipos de operações a serem validados           <<<<<<
_cProdPe		:= U_ITGETMV( "IT_PRODPE" , "  ")	// Produtos permitidos                            <<<<<<
_cPrd3Um		:= U_ITGETMV( "IT_PRD3UM" , "  ")	// Produtos a validar pela 3ª unidade de medida
_cLocval		:= U_ITGETMV( "IT_LOCFRA" , "  ")	// Armazéns que não valida quantidade fracionada  <<<<<<
_cTpOper	    := GETMV("IT_TPOPER") //Armazena o tipo de operacao que na TES INTELIGENTE pode ter a TES alterada pelo usuario
_cProdNFrac     := U_ITGETMV( "IT_PRDNFRAC" , "  ")	// Produtos proibidos de serem fracionados na Venda.
_lValAltPVin    := U_ITGETMV( "IT_VALALTPV" , .T. )	// Habilitar para validar se o PV Vinculado foi altearado para outro PV
_lLibMas	    := .F.
_nQtdDia	    := 0
_nQtdiaT	    := 0
_lExec	        := .F.
_cBloqSBZ       := ""
_lValCredito    := .T. // Tem que iniciar com .T. pq pode ta vindo de MSEXECAUTO(), com .T. não limpa os campos de validação de credito
_nTotPV := 0
_ni := 0
y := 0
x := 0
_lTravadoPorAlguem := .F.
_aItensLock := {}
auser := {}
_nRecOrigem := 0
_cLocalNFrac  := U_ITGETMV( "IT_LOCNFRAC" , "  ")	// Armazens/Locais vinculados aos produtos proibidos de serem fracionados na Venda.
_cTipOpNFrac  := U_ITGETMV( "IT_TPONFRAC" , "  ")	// Tipos de Operações vinculados aos produtos proibidos de serem fracionados na Venda.
_l108 := .F.
_laoms074 := .F.
_nnipre := 0
_nRegVinc := 0
_lEstornoRDc := .F.
_nSalvaN := N
_cUser := RetCodUsr()
_cchep := alltrim(GetMV("IT_CCHEP"))
_nRegSC5 := 0
_aOrd := {}
_cFilSC5 := ""
_cBlqContrato := ""
_lUsaNovo := U_ItGetMv("IT_TABPRG",.F.)
_cGrupoP := ""
_cUFPedV := ""
_cTipoProd := ""
_cDescriPrd := ""
_cDescTBPrc := ""
nZ := 0
cItensnZ := ""
aTabnZ := {}
nPesCarg := U_ITGETMV("IT_PESOFEC",4000)
nPsBru := 0
_cTipoPedido := "V"
_ccondr := ""
_dHoje := DATE()
_lItemAlterado  := .F.
_cRedeCliente   := ""
_lSimplNac := .F.
_cSimplNac := ""
_aBlqprc := {}
_lPrcErr := .F.
_nFaixa  := 0
_cMsgPrc := ""
_cFilCarreg := ""
_lAoms112 := .F.
_lFob := .F.
_nDescPTon := 0
_cOperFret := U_ITGETMV("IT_OPERFRE","")
_dDtCalcFr := Ctod(U_ITGETMV("IT_DTCALCF","23/06/2022"))
_cOperTran := U_ITGETMV("IT_OPERTRA","20/21")
_cCrtl3Um := "N" // Produtos a validar quantidade fracionada na terceira unidade de medida.

_cTextoUnd := " 2a.UM (segunda) "
_cTextCalc := ""

_cOperTriangular := ""
_cOperFat        := ""
_cOperRemessa    := ""
_aProdBlq        := {}

//_lWsTms := U_ITGETMV( 'IT_WEBSTMS' , .F.) // Indica se rotina de integração WebService é TMS Multi-Embarcador ou RDC.
_cTextoMsg := ""

_cLocalPCh := U_ITGETMV( 'IT_ARMPACH' , '40;42;')
_nPos := 0
_nPosFilAnt := 0
__cCodCli   := ""
__cLojaCli  := ""

lRet 		:= .T. //Padrao variavel LOCAL
cNumPrd 	:= ""
aItens 		:= {}
lDifPes		:= .F.
lTemItemPA	:= .F.
_lItemNovo  := .F.

BEGIN SEQUENCE

//Se veio do webservice já retorna .T.
If FWIsInCallStack("U_ALTERAP") .or. FWIsInCallStack("U_INCLUIC") .or. FWIsInCallStack("U_AOMS085B") 
   _laoms074 := .T.
Endif

//Se veio da rotina de exclusão automática de pedidos de venda já retorna .T.
If FWIsInCallStack("U_AOMS108")
    _l108 := .T.
Endif

//Se esta sendo chamado via AOMS112/MOMS050 (Central Pedido Portal / Efetivaçao Automatica)
If FWIsInCallStack("U_AOMS112") .or. FWIsInCallStack("U_MOMS050")
    _lAoms112 := .T.
Endif

nPosProduto		:= Ascan( aHeader , { |x| Alltrim(x[2]) == "C6_PRODUTO"	} )
nPosTes 		:= Ascan( aHeader , { |x| Alltrim(x[2]) == "C6_TES"		} )
nPosBlPrc 		:= Ascan( aHeader , { |x| Alltrim(x[2]) == "C6_I_BLPRC"	} )
nPosPedCli 		:= Ascan( aHeader , { |x| Alltrim(x[2]) == "C6_PEDCLI"	} )
nPosUser 		:= Ascan( aHeader , { |x| AllTrim(x[2]) == "C6_I_USER"  } )
nPosVal			:= Ascan( aHeader , { |x| AllTrim(x[2]) == "C6_VALOR"   } )
nPosPreco		:= Ascan( aHeader , { |x| AllTrim(x[2]) == "C6_PRCVEN"  } )
nPosPLIBP		:= Ascan( aHeader , { |x| AllTrim(x[2]) == "C6_I_PLIBP" } )
nPosVLIBP		:= Ascan( aHeader , { |x| AllTrim(x[2]) == "C6_I_VLIBP" } )
nPosqtd			:= Ascan( aHeader , { |x| AllTrim(x[2]) == "C6_QTDVEN"  } )
nPosLoc	    	:= aScan( aHeader , { |x| alltrim(x[2]) == "C6_LOCAL"   } )
_cCFOP	        := aScan( aHeader , { |x| AllTrim(x[2]) == "C6_CF"	    } )
nPosQtd2		:= Ascan( aHeader , { |x| AllTrim(x[2]) == "C6_UNSVEN"	} )
nPosIte	    	:= aScan( aHeader , { |x| alltrim(x[2]) == "C6_ITEM"    } )
nPosAmz         := aScan( aHeader , { |x| Alltrim(x[2]) == "C6_LOCAL"   } )
_nPosItPc       := aScan( aHeader , { |x| Alltrim(x[2]) == "C6_ITEMPC"  } )
nPosPerc        := aScan( aHeader , { |x| ALLTRIM(x[2]) == "C6_I_PDESC" } )
nPosCVLTAB      := aScan( aHeader , { |x| Alltrim(x[2]) == "C6_I_VLTAB" } )
nPosFXPES       := aScan( aHeader , { |x| Alltrim(x[2]) == "C6_I_FXPES" } )
//nPosCVFLEX      := aScan( aHeader , { |x| Alltrim(x[2]) == "C6_I_VFLEX" } )
//nPosCVFLET      := aScan( aHeader , { |x| Alltrim(x[2]) == "C6_I_VFLET" } )
_nPosPrNet      := aScan( aHeader , { |x| AllTrim(x[2]) == "C6_I_PRNET" } )
_nPosQPale      := aScan( aHeader , { |x| AllTrim(x[2]) == "C6_I_QPALT" } )
_nPosCC         := aScan( aHeader , { |x| AllTrim(x[2]) == "C6_CC"      } )
_nPosC6OPER     := aScan( aHeader , { |x| AllTrim(x[2]) == "C6_OPER"    } )
nPosVlTab       := aScan( aHeader , { |x| AllTrim(x[2]) == "C6_I_VLTAB"      } )
nPosPrMin       := aScan( aHeader , { |x| AllTrim(x[2]) == "C6_I_PRMIN"      } )
_nPosDescr      := aScan( aHeader , { |x| AllTrim(x[2]) == "C6_DESCRI"} )

SC5->( DBSetOrder(1) )

_lbloq4 := .F.

_cOperTriangular:= ALLTRIM(U_ITGETMV( "IT_OPERTRI","05,42"))
_cOperFat       := LEFT(_cOperTriangular,2)
_cOperRemessa   := RIGHT(_cOperTriangular,2)

If INCLUI .And. !_lAoms112
    If M->C5_I_OPER = _cOperFat
        M->C5_I_OPTRI := "F"
    ElseIf M->C5_I_OPER = _cOperRemessa
        M->C5_I_OPTRI := "R"
    EndIf
EndIf
//================================================================================
// Tratamentos Operação Triangular e Clientes Remessa efetivação Pedidos do Portal
//================================================================================
If INCLUI .And. _lAoms112
   If Type("_cOperTri") <> "U"
      If ! Empty(_cOperTri)
         M->C5_I_OPTRI := _cOperTri
      EndIf
   EndIf

   If Type("_cCodClien") <> "U"
      If ! Empty(_cCodClien)
         M->C5_I_CLIEN := _cCodClien
      EndIf
   EndIf

   If Type("_cLojaClie") <> "U"
      If ! Empty(_cLojaClie)
         M->C5_I_LOJEN := _cLojaClie
      EndIf
   EndIf
EndIf
//================================================================================
// Tratamentos Gerente Nacional
//================================================================================
If INCLUI .Or. ALTERA
   If ! Empty(M->C5_VEND1) .And. Empty(M->C5_VEND5)
      M->C5_VEND5 := Posicione("SA3",1,xFilial("SA3")+M->C5_VEND1,"A3_I_GERNC")
   EndIf
EndIf

//================================================================================
// Indica se a funçõa foi chamada através da rotina de alteração de pedidos.
//================================================================================
PRIVATE _lMsgEmTela := .T.

If Type("_cAOMS074") <> "U" .OR. FWIsInCallStack("U_AOMS109")
   _lMsgEmTela := .F.
EndIf

_cTipoPedido := posicione("ZAY",1,xfilial("ZAY")+ AllTrim(aCols[1,_cCFOP]) ,"ZAY_TPOPER")

//================================================================================
// Calcula o Peso Bruto Total do Pedido
//================================================================================

nPsBru := M410LITotais()

_cRedeCliente := Posicione("SA1",1,xfilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI ,"A1_GRPVEN")
//================================================================================
// Validar clientes com bloqueio de contrato
//================================================================================

M410Proc(oProc,"Cadastro do Cliente")

If Inclui .Or. Altera
   If FWIsInCallStack("MATA410") .And. SA1->(FieldPos("A1_I_BLQCT") > 0) .And. M->C5_TIPO = "N"
      _cBlqContrato := Posicione("SA1",1,xfilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI ,"A1_I_BLQCT")
      If _cBlqContrato == "S"
         U_MT_ITMSG("Cliente com bloqueio de Contrato de Desconto.",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,"Favor procurar o departamento de Contratos para solicitar o desbloqueio.",1)
         lRet := .F.
      Endif
   EndIf
EndIf

//================================================================================
// *************           TRATAMENTO FOB       *********************
//================================================================================
If Inclui .Or. Altera
    If FWIsInCallStack("MATA410")
        _lFob := Posicione("SA1",1,xfilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI ,"A1_I_FOB")
        If Alltrim(M->C5_TPFRETE) $ "F/D" .And. !(M->C5_I_OPER $ _cOperFret) .And. Dtos(M->C5_EMISSAO) >= Dtos(_dDtCalcFr)
            If !_lFob
                U_MT_ITMSG("Para este Cliente não é permitdo o Tipo de Frete FOB.",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,"Para que permita a seleção de Tipo de Frete FOB modifique o respectivo campo no cadastro desse Cliente.",1)
                lRet := .F.
            EndIf
        EndIf
    EndIf
EndIf

//==========================================================================================
// Validar os usuários que são autorizados a fazer manutenção em pedidos de transferências.
//==========================================================================================
If ZZL->(FieldPos("ZZL_IPVTRA")) > 0
   If (Inclui .Or. Altera .Or. AllTrim(AROTINA[1][1]) == "Excluir") .And. M->C5_I_TRCNF <> "S" .And. !_lAoms074
      If M->C5_I_OPER $ _cOperTran
         ZZL->( DBSetOrder(3) )
         If ZZL->( DBSeek( xFilial("ZZL") + _cUser ) )
            If ZZL->ZZL_IPVTRA <> "S"
               U_MT_ITMSG("Usuário não autorizado a realizar manutenção em Pedidos de Vendas com operações de transferências de pedidos.",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,"",1)
               lRet := .F.
            EndIf
         Else
            U_MT_ITMSG("Usuário não autorizado a realizar manutenção em Pedidos de Vendas com operações de transferências de pedidos.",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,"",1)
            lRet := .F.
         EndIf
      EndIf
   EndIf
EndIf

//==================================================
// Calcula desconto por tonelada para fretes Fob.
//==================================================
If Inclui .Or. Altera
   _lFob := Posicione("SA1",1,xfilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI ,"A1_I_FOB")
   If _lFob .And. Alltrim(M->C5_TPFRETE) $ "F/D" .And. !(M->C5_I_OPER $ _cOperFret) .And. Dtos(M->C5_EMISSAO) >= Dtos(_dDtCalcFr)
      _nDescPTon := U_M410BDES(M->C5_FILIAL,M->C5_I_EST, M->C5_I_OPER , M->C5_I_CMUN) // Retorna o desconto por tonelada para pedidos Fob.
      If _nDescPTon > 0
         M->C5_DESCONT :=  ((nPsBru/1000)*_nDescPTon)
      EndIf
   EndIf
EndIf
//================================================================================
// *************           TRATAMENTO TABELA DE PREÇO        *********************
//================================================================================
_cSimplNac := Posicione("SA1",1,xfilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI ,"A1_SIMPNAC")
If _cSimplNac == "1"
   _lSimplNac := .T. // O cliente é optante do Simples Nacional
Else
   _lSimplNac := .F. // O cliente não é Optante do Simples Nacional
EndIf

//**************************************************************************************************************************//
//Busca do Local de Embarque - Chamado 43864
//-------------------------------------------//
IF M->C5_I_OPER <> _cOperFat .AND. ParamIXB[1] <> 1 .AND. ParamIXB[1] <> 5 //EXCLUIR DO MENU  OU  EXCLUSAO EXECAUTO
   _cLocal1oItem:=""
   FOR nX := 1 TO Len(aCols)
       IF aCols[nX][Len(aCols[nX])]
          LOOP
       ENDIF
       _cLocal1oItem:=AllTrim(aCols[nX,nPosLoc])//
       EXIT
   NEXT
   M->C5_I_LOCEM:=U_BuscaLocalEmbarque(cFilAnt,_cLocal1oItem,M->C5_VEND1)//Função no Programa AOMS136.PRW
ENDIF

//===================================================================================
// Carrega o grupo de produtos fora do If para ser utilizado em varias validações.
//===================================================================================
_cGrupoP   := Posicione("SB1",1,xFilial("SB1")+acols[N][nPosProduto],"B1_GRUPO")
_cTipoProd := Posicione("SB1",1,xFilial("SB1")+acols[N][nPosProduto],"B1_TIPO")

//===================================================================================
// Busca do Local de Embarque - Chamado 43864
//===================================================================================
If  lRet .and. M->C5_TIPO = "N" .AND. M->C5_I_OPER $ u_itgetmv("IT_TPOPER","01,42,08,12,15,24,25,26") .And.;
    !FWIsInCallStack("U_AOMS032") .AND.;
    !FWIsInCallStack("U_AOMS032EXE") .AND. ;
    !(FunName() $ "MATA140,MATA521B,MATA460B,MATA103")  .AND.;
    !(FWIsInCallStack("U_AOMS099")) .and. !_l108 .and. !_laoms074 .And. ParamIXB[1] <> 1 .AND. ParamIXB[1] <> 5 .And. !_lAoms112

    //_cGrupoP   := Posicione("SB1",1,xFilial("SB1")+acols[N][nPosProduto],"B1_GRUPO")
    //_cTipoProd := Posicione("SB1",1,xFilial("SB1")+acols[N][nPosProduto],"B1_TIPO")

    //================================================================================
    // Busca Dados do aCols para Tratar se o item sofre manutenção na função Alterar
    //================================================================================
    _lItemNovo:=.F.//Alterado dentro da função M410SITITEM()
    If Altera
        _lItemAlterado := M410SITITEM()
    EndIF

     IF FWIsInCallStack("MATA410") .And. _cTipoProd = 'PA' .And. !(FWIsInCallStack("U_AOMS098")) .And. !(FWIsInCallStack("U_AOMS099")) ;
        .And. !(FWIsInCallStack("U_AOMS032")) .And. !(FWIsInCallStack("U_AOMS074")) .And. ! (FWIsInCallStack("U_AOMS112"))
        //=========================================================================== 
        // Valida produtos bloqueados por filial, confome cadastro de 
        // produtos bloqueados por filial.
        //===========================================================================
        If lRet .And. Inclui // (Inclui .Or. Altera)
           If M->C5_I_OPER $ AllTrim(U_ITGETMV( 'IT_TPOPER' , '')) 
              
              ZBS->(DbSetOrder(1))
              //==================================================================
              // Quando for troca nota validar na filial de carregamento. 
              //==================================================================
              If M->C5_I_TRCNF == 'S'
                 _cFilValid :=  M->C5_I_FLFNC
              Else 
                 _cFilValid :=  xFilial("SC5")
              EndIf 

              If Empty(_cFilValid)
                 _cFilValid :=  xFilial("SC5")
              EndIf 
              
              For _nI := 1 to len(acols)
                  If aCols[_nI,len(aHeader)+1] // Se Linha Excluida
                     Loop
                  EndIf

                  If ZBS->(MsSeek(xFilial("ZBS")+_cFilValid+acols[_nI][nPosProduto])) //ZBS->(MsSeek(xFilial("ZBS")+xFilial("SC6")+acols[_nI][nPosProduto]))
                     If ZBS->ZBS_SITUAC == "B" 
                        U_MT_ITMSG("Produto [" + AllTrim(acols[_nI][nPosProduto]) + "-" + AllTrim(acols[_nI][_nPosDescr]) + "] bloqueado para filial [" + _cFilValid + "], de acordo com o cadastro de produtos bloqueados por filial.",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,;
                                  "Bloqueio definido pela equipe do Comercial.",1)
                        lRet := .F.           
                        Exit
			            EndIf 
                  EndIf 
              Next
           EndIf 
        EndIf           

        If Empty(Alltrim(M->C5_I_TAB))
           //Carrega tabela de preços
           aTabnZ := U_ITTABPRC(M->C5_FILGCT,M->C5_I_FILFT,M->C5_VEND3,M->C5_VEND2,M->C5_VEND1,M->C5_CLIENTE,M->C5_LOJACLI,.T.,,M->C5_VEND4,M->C5_I_GRPVE , _cGrupoP,M->C5_I_OPER,M->C5_I_LOCEM,M->C5_I_CLIEN,M->C5_I_LOJEN)
           _ctab    := aTabnZ[1]
           _ntab    := aTabnZ[2]
           _cGrupoP := aTabnZ[5]  // Grupo de estoque do produto.
           _cUFPedV := aTabnZ[6]  // UF do pedido de vendas.
           M->C5_I_ORTBP := _ntab
           M->C5_I_TAB   := _cTab
        Else
           _cTab    := M->C5_I_TAB
           _nTab    := M->C5_I_ORTBP
           _cUFPedV := M->C5_I_EST
        EndIF
        _cDescriPrd := ""
        _cDescTBPrc := ""

        If !Empty(M->C5_EMISSAO)
            _dHoje := M->C5_EMISSAO
        EndIf

         //Valida validade da tabela da regra posicionada, se for inválida pula a análise
        DA0->(Dbsetorder(1))

        If (DA0->(Dbseek(xfilial("DA0")+_ctab)))
           If DA0->DA0_ATIVO == '2'  //Tabela inativa
               _cDescTBPrc := AllTrim(_ctab) + "-" + AllTrim(DA0->DA0_DESCRI)
               U_MT_ITMSG("Tabela de preços " + _cDescTBPrc + ", Inativa!",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,"Verifique regras de tabelas de preço",1)
               lRet := .F.
           EndIf
           If lRet .And. DA0->DA0_DATDE > DATE() .OR. DA0->DA0_DATATE < _dHoje .And. !Altera
              _cDescTBPrc := AllTrim(_ctab) + "-" + AllTrim(DA0->DA0_DESCRI)
              U_MT_ITMSG("Tabela de preços " + _cTab + "-" + _cDescTBPrc + " fora da vigência!",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,"Verifique regras de tabelas de preço",1)
              lRet := .F.
           Endif
        Elseif EMPTY(_ctab)
           U_MT_ITMSG("Tabela de preços não preenchida!",'Atencao! Ped.: '+M->C5_NUM,"Verifique regras de tabelas de preço",1)
           lRet := .F.
        Else
           U_MT_ITMSG("Tabela de preços " + _ctab + " não localizada!",'Atencao! Ped.: '+M->C5_NUM,"Verifique regras de tabelas de preço",1)
           lRet := .F.
        Endif

        If lRet
           //If DA0->DA0_I_PES2 > 0 //Retirado pelo CHAMADO 44092: Ajustes no Tratamento da Tabela de Preços no Pedido de Vendas. Função U_ITTABPRC().
           //    nPesCarg := DA0->DA0_I_PES2
           //ElseIf DA0->DA0_I_PES1 > 0
           //    nPesCarg := DA0->DA0_I_PES1
           //EndIf
           IF M->C5_I_TPVEN == "F" .and. ParamIXB[1] <> 1 .AND. ParamIXB[1] <> 5//EXCLUIR DO MENU  OU  EXCLUSAO EXECAUTO
               IF nPsBru < nPesCarg .AND. Empty(M->C5_I_PODES)
                   U_MT_ITMSG("Este pedido não pode ser do tipo (F - Fechada).","Falha","Para que o pedido seja do tipo (F - Fechada) "+;
                               "o peso total do Pedido devem ser maior ou igual a "+ cValToChar(nPesCarg )+" Kg. Para concluir o pedido altere o Tipo de Venda "+;
                               "para (V - Fracionada).",1)
                   lRet := .F.
               ENDIF
           ENDIF

           _cDescTBPrc := AllTrim(_ctab) + "-" + AllTrim(DA0->DA0_DESCRI)

           If lRet .And. ( _lItemAlterado .Or. Inclui )  .And. !(FWIsInCallStack("U_AOMS098"))
              //Valida existência de produtos na tabela de preços selecionada
              For _nnipre := 1 to len(acols)
                  If aCols[_nnipre,len(aHeader)+1] // Se Linha Excluida
                     Loop
                  EndIf

                  DA1->(Dbsetorder(1)) //DA1_FILIAL+DA1_CODTAB+DA1_CODPRO
                  If !(DA1->(Dbseek(xfilial("DA1")+_ctab+acols[_nnipre][nPosProduto])))
                     _cDescriPrd += "Produto sem cadastro: " + AllTrim(acols[_nnipre][nPosProduto]) + "-" + AllTrim(Posicione("SB1",1,xFilial("SB1")+acols[_nnipre][nPosProduto],"B1_DESC"))+_ENTER
                     lRet := .F.
                  ELSE
                     If Inclui
                        If DA1->DA1_ATIVO == '1'
                           If nPsBru >=  DA0->DA0_I_PES1
                               acols[_nnipre][nPosCVLTAB] := DA1->DA1_I_PRF1
                               acols[_nnipre][nPosFXPES] := 1
                           ElseIf nPsBru >=  DA0->DA0_I_PES2 .AND. nPsBru <  DA0->DA0_I_PES1
                              acols[_nnipre][nPosCVLTAB] := DA1->DA1_I_PRF2
                              acols[_nnipre][nPosFXPES] := 2
                           Else
                              acols[_nnipre][nPosCVLTAB] := DA1->DA1_I_PRF3
                              acols[_nnipre][nPosFXPES] := 3
                           EndIf
                        ELSE
                           lRet := .F.
                           _cDescriPrd += "Produto Inativo: " + AllTrim(acols[_nnipre][nPosProduto]) + "-" + AllTrim(Posicione("SB1",1,xFilial("SB1")+acols[_nnipre][nPosProduto],"B1_DESC"))+_ENTER
                        ENDIF
                     ElseIf Altera
                          If  DA1->DA1_ATIVO == '1'
                              If nPsBru >=  DA0->DA0_I_PES1
                                 acols[_nnipre][nPosFXPES] := 1
                              ElseIf nPsBru >=  DA0->DA0_I_PES2 .AND. nPsBru <  DA0->DA0_I_PES1
                                 acols[_nnipre][nPosFXPES] := 2
                              Else
                                 acols[_nnipre][nPosFXPES] := 3
                              EndIf
                          ELSE
                              lRet := .F.
                              _cDescriPrd += "Produto Inativo: " + AllTrim(acols[_nnipre][nPosProduto]) + "-" + AllTrim(Posicione("SB1",1,xFilial("SB1")+acols[_nnipre][nPosProduto],"B1_DESC"))+_ENTER
                          ENDIF
                     ENDIF
                 Endif
            Next
              If !lRet
                  U_MT_ITMSG("Existem produtos que não constam na tabela de preço ou esta Inativo " + _cDescTBPrc+". Clique em mais detalhes",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
                             'Atencao!',"Verifique a tabela de preço e regras de tabela de preço para esse pedido"                               ,1     ,       ,        ,         ,     ,     ,{|| U_ITMSGLOG(_cDescriPrd,"Produtos com Problema.") },_cDescriPrd )
              Endif
          Endif
        Endif
        If lRet .AND. Empty(M->C5_I_PODES) .AND. Inclui //Inclusão e Não Desdobramento
           IF LEN(aCols) > 0
               FOR nZ := 1 to Len(aCols)
                   _aBlqprc  := U_BLQPRC(aCols[nZ][nPosProduto],aCols[nZ][nPosPreco],  M->C5_FILIAL,   .F.,M->C5_I_TAB,       ,_lusanovo,           ,        .T., _cGrupoP,_cUFPedV,         ,         ,_lSimplNac,nPsBru,0)
                   _lPrcErr  := _aBlqprc[1]
                   _nFaixa   := _aBlqprc[2]
                   _cMsgPrc  := _aBlqprc[3]  // Grupo de estoque do produto.
                   _nPrecoIt := _aBlqprc[4]
                   _nPrecoMin:= _aBlqprc[5]
                   If Len(_aBlqprc) > 6
                      _cDescTBPrc:=_aBlqprc[7] 
                   EndIf 
                   If _lPrcErr
                       cItensnZ += _cMsgPrc
                       aCols[nZ][nPosBlPrc] 	:= "B"
                   EndIf
                   aCols[nZ][nPosVlTab]  := _nPrecoIt
                   aCols[nZ][nPosPrMin]  := _nPrecoMin
                   //fim
               Next nZ
           ENDIF
           M->C5_I_FXPES := _nFaixa
           IF cItensnZ != ""
              U_MT_ITMSG("O(s) preço(s) praticado(s) algum(ns) item(ns) está(ão) fora da tabela de preço. Clique em mais detalhes",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
                         'Atencao!',"O pedido será marcado como bloqueado para posterior avaliação."                                              ,1     ,       ,        ,         ,     ,     ,{|| U_ITMSGLOG(cItensnZ,"Produtos fora da tabela de preço: "+_cDescTBPrc) },cItensnZ )
              M->C5_I_BLPRC	:= "B"
              M->C5_I_DTLIB	:= CTOD("")
           Else
              M->C5_I_BLPRC	:= " "
           ENDIF
        ENDIF
    ENDIF
ENDIF

//======================================================================
// Valida quantidades em segunda unidade de medida, multipla de Pallet.  
//======================================================================
If lRet .And. _cTipoProd = 'PA' .And. (FWIsInCallStack("MATA410") .Or. FWIsInCallStack("U_AOMS098") .Or. FWIsInCallStack("U_AOMS032") .Or. FWIsInCallStack("U_AOMS112")) .And. (Inclui .Or. Altera) .And. M->C5_TIPO = "N" .AND. M->C5_I_OPER $ U_ItGetMv("IT_TPOPER","01,42,08,12,15,24,25,26")
   
   _cTextoMsg := ""
   
   _cValFilEm := SUPERGETMV('IT_VFILLOC',.F.,"90SP50;93PR51") // Validação filial x Local de Embarque. 

   If (M->C5_I_TRCNF == "S" .And.  (M->C5_I_FLFNC+M->C5_I_LOCEM) $ _cValFilEm) .Or. (M->C5_I_TRCNF == "N" .And.  (xFilial("SC5")+M->C5_I_LOCEM) $ _cValFilEm)    

      For _nI := 1 to len(acols)
          If aCols[_nI,len(aHeader)+1] // Se Linha Excluida
             Loop
          EndIf
                   
          _nNCxPalet := Posicione("SB1",1,xfilial("SB1")+aCols[_nI][nPosProduto],"B1_I_CXPAL") // Numero de caixas por Pallet   

          If (_nNCxPalet > aCols[_nI][nPosQtd2]) .Or. (Mod( aCols[_nI][nPosQtd2], _nNCxPalet ) <> 0)
             _cTextoMsg +=  "Produto [" + AllTrim(acols[_nI][nPosProduto]) + "-" + AllTrim(acols[_nI][_nPosDescr]) + ;
                            "] com quantidades em segunda unidade diferente de multipo de palete."
             lRet := .F.  
          EndIf          
      Next

      If ! lRet
         U_MT_ITMSG(_cTextoMsg,'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,;
                    "As quantidades deste item devem ser multiplas de palete.",1)
      EndIf 
   EndIf 
EndIf 

//================================================================================
// *************           TRATAMENTO DE DEAD-LOCK           *********************
//================================================================================
IF lRet .AND. !FWIsInCallStack( "MSEXECAUTO" )
   M410Proc(oProc,"Locks")
   _lTravadoPorAlguem := U_LockPed(M->C5_CLIENTE,M->C5_LOJACLI,cFilAnt,_aItensLock) //Função no italacxfun que faz o lock completo previnindo deadlock
   IF _lTravadoPorAlguem
      lRet:=.F.
   ENDIF
ENDIF
//================================================================================
// *************           TRATAMENTO DE DEAD-LOCK           *********************
//================================================================================

//----------------------------------------------------------------------------------------------------
//Força campos de cliente e loja entrega a ficarem iguais aos campos cliente loja do pedido
//----------------------------------------------------------------------------------------------------
M->C5_CLIENTE := M->C5_CLIENT
M->C5_LOJAENT := M->C5_LOJACLI


//**************************************************************************************************************           
//Busca o/a Assistente do Pedido no Cadastro de Assistente Adm Comercial Responsável - Chamado 43076            
//**************************************************************************************************************
IF Inclui .AND. M->C5_TIPO = "N"
   //                              _cRede       ,_cVend     ,_cSupe     ,_cCoor     ,_cGere
   _aAssistente:=U_BuscaAssistente(_cRedeCliente,M->C5_VEND1,M->C5_VEND4,M->C5_VEND2,M->C5_VEND3)//Função no Programa AOMS135.PRW
   M->C5_ASSCOD:=_aAssistente[1]
   M->C5_ASSNOM:=_aAssistente[2]
ENDIF

//----------------------------------------------------------------------------------------------------
//Se não for exclusão não permite cliente com mesmo cnpj da filial atual
//Só bloqueia para operações de venda e transferência
//----------------------------------------------------------------------------------------------------
If lRet .and. !_laoms074 .and. !_l108 .and. ParamIXB[1] <> 1 .AND. ParamIXB[1] <> 5 .and. alltrim(SM0->M0_CGC) == alltrim(POSICIONE("SA1",1,xfilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_CGC"))//EXCLUIR DO MENU  OU  EXCLUSAO EXECAUTO
    If _cTipoPedido $ "VT"
           U_MT_ITMSG("Pedido de venda ou transferência não pode ter como cliente a própria filial.",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,;
               "Altere o cliente",1)
        lRet := .F.
    Endif
Endif

//----------------------------------------------------------------------------------------------------
// Bloquear a alteração e exclusão de pedidos de vendas quando o campo C5_I_ENVRD (Enviado para o RDC)
// estiver com o conteúdo "S" (Sim).
//----------------------------------------------------------------------------------------------------
If lRet .and. !_laoms074 .and. !_l108 .AND. M->C5_TIPO = "N" .AND. (ParamIXB[1] = 4 .OR. ParamIXB[1] = 5 .OR. ParamIXB[1] = 1)//EXCLUIR DO MENU  OU  EXCLUSAO EXECAUTO

   If SC5->C5_FILIAL $ _cFilHabilit // Filiais habilitadas na integracao Webservice Italac x RDC.
      If SC5->C5_I_ENVRD == "S"
         If ParamIXB[1] = 4 .and. !FWIsInCallStack("U_ALTERAP") .and. !FWIsInCallStack("U_AOMS085B")// Alteração desde que não seja via webservice do RDC

            _cTextoMsg := 'O pedido '+SC5->C5_NUM+ " pedido já foi integrado ao sistema TMS e não pode ser alterado."

            U_MT_ITMSG(_cTextoMsg ,'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+SC5->C5_NUM,;
               "Solicite o retorno do pedido para o Protheus.",1)

         ElseIf ParamIXB[1] = 5 .OR. ParamIXB[1] = 1//EXCLUIR DO MENU  OU  EXCLUSAO EXECAUTO

            _cTextoMsg := 'O pedido '+SC5->C5_NUM+ " pedido já foi integrado ao sistema TMS e não pode ser excluido."

            U_MT_ITMSG(_cTextoMsg,'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+SC5->C5_NUM,;
               "Solicite o retorno do pedido para o Protheus.",1)

         EndIf
         lRet := .F.
      EndIf
   EndIf
EndIf

//==============================================================================================================
//Se já foi retornado do RDC e não for integração WEbservice deve preencher o campo C5_I_ENVRD com "N"
//Se não enviou ainda continua na pendência de enviar, se estiver como S ou R coloca para reenviar de imediato
//=============================================================================================================
If ParamIXB[1] = 4 .and. !_laoms074 .and. !FWIsInCallStack("U_ALTERAP") .and. !FWIsInCallStack("U_AOMS085B") .and. M->C5_TIPO = "N"  // Alteração desde que não seja via webservice do RDC

    M->C5_I_ENVRD := "N"

Endif

//==============================================================================================================
// Valida operação exclusiva para cliente Chep ( 50)
//==============================================================================================================

If lRet .And. !FWIsInCallStack("U_ALTERAP") .and. !_laoms074 .and. !_l108 .AND. (ParamIXB[1] = 3 .Or. ParamIXB[1] = 4) .and. !(FUNNAME() = 'OMSA200')

    _coper50 := AllTrim( U_ITGETMV( 'IT_CHEPCLIS' ) ) //Operação exclusiva para cliente Chep
    _coper51 := AllTrim( U_ITGETMV( 'IT_CHEPCLIN' ) ) //Operação exclusiva para cliente não Chep


    //Valida operação 50 para clientes cadastrados no Chep
    If lRet .and. M->C5_I_OPER = _coper50 .AND. (M->C5_TIPO != 'N' .OR. len(alltrim(POSICIONE("SA1",1,xfilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_I_CCHEP"))) != 10)

        U_MT_ITMSG( "Operação " + _coper50 + " é exclusiva para clientes cadastrados na Chep",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,;
                     "Altere o tipo de operação válida para cliente não Chep e tipo do pedido para Normal.",1)

        lRet := .F.

    ENDIF

    //Valida operação 51 só para clientes não cadastrados no chep
    If lRet .and. M->C5_I_OPER = _coper51 .AND. (M->C5_TIPO != 'N' .OR.len(alltrim(POSICIONE("SA1",1,xfilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_I_CCHEP"))) == 10)

        U_MT_ITMSG( "Operação " + _coper51 + " é exclusiva para clientes não cadastrados na Chep",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,;
                     "Altere o tipo de operação válida para cliente Chep e tipo do pedido para Normal.",1)

        lRet := .F.

    ENDIF


Endif

//================================================================================
// Validacao para a filial 91 - Manual
//================================================================================
IF cFilAnt = "91" .AND. lRet .and. !_l108 .and. !_laoms074 .and. M->C5_TIPO = "N"
   M410Proc(oProc,"Filial 91")
   lRet:= U_AOMS058(4)
ENDIF

//=================================================================================================================
// Validacao do Projeto de unificação de pedidos de troca nota
//=================================================================================================================
If  lRet .and. !_l108 .and. !_laoms074 .AND. M->C5_TIPO = "N"  .AND. ParamIXB[1] <> 5 .AND. ParamIXB[1] <> 1//EXCLUIR DO MENU  OU  EXCLUSAO EXECAUTO

    M410Proc(oProc,"Troca NF")
   _aAreaSC5:=SC5->(GetArea())

  //Só valida quando NÃO chamar da tela de Estorno de classificação e no estorno do doc da carga
   IF M->C5_I_TRCNF = "S" .AND. !(FUNNAME()) $ "MATA140,MATA521B,MATA460B,MATA103" .and. !(FWIsInCallStack("U_AOMS099"))  .and. !(FWIsInCallStack("M520_VALID")) .and. !(FWIsInCallStack("OMS200DELPV"))

      IF lRet .AND. M->C5_TIPO # "N"
         U_MT_ITMSG('O pedido '+M->C5_NUM +  " foi marcado como troca nota que só pode ser usado com Pedido do Tipo Normal",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+SC5->C5_NUM,;
                        'Altere o tipo do Pedido para "N"-Normal',1)
         lRet := .F.
      ENDIF

      IF lRet .AND. !EMPTY(M->C5_I_FILFT+M->C5_I_FLFNC) .AND. M->C5_I_FILFT == M->C5_I_FLFNC
         U_MT_ITMSG('Pedido: '+M->C5_NUM + " Filial de Faturamento não pode ser igual a de Carregamento",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+SC5->C5_NUM,;
                        "Altere a filial de Carregamento",1)

         lRet := .F.
      ENDIF

      IF lRet
         If Alltrim(U_ITGETMV( "IT_PRONF" , "N")) == "N" //Testa a Filial atual se pode ser troca nota
            U_MT_ITMSG('Pedido '+M->C5_NUM + " Filial Atual não é troca nota: "+cFilAnt,'Atencao! (MT410TOK) Ped.: '+M->C5_NUM,;
                           "Verifique o Parametro: IT_PRONF",1)
            lRet := .F.
         ENDIF
      ENDIF

      IF lRet
         cFilDes:= GetAdvFVal("ZZM","ZZM_DESCRI",xFilial("ZZM")+M->C5_I_FILFT,1,"")
         IF EMPTY(M->C5_I_FILFT) .OR. EMPTY(cFilDes)//Testa se a filial de faturamento foi preenchida e existe no ZZM
            U_MT_ITMSG('Pedido: '+M->C5_NUM + " Filial de Faturamento nao preenchida ou nao Cadastrada: " +M->C5_I_FILFT,'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,;
                           "Preencha uma filial cadastrada",1)

            lRet := .F.
         ENDIF
      ENDIF

      IF lRet
         _cFilSalva:= cFilAnt
         cFilAnt   := M->C5_I_FILFT
         If Alltrim(U_ITGETMV( "IT_FATNF" , "N")) == "N" //Testa a filial de Faturamento
           U_MT_ITMSG('Pedido: '+M->C5_NUM + " Filial de Faturamento não é troca nota: "+cFilAnt,'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,;
                           "Verifique o Parametro: IT_FATNF",1)
            lRet := .F.
         ENDIF
         cFilAnt := _cFilSalva
      ENDIF

      IF lRet//AWF - 18/11/2016
         cFilsFat:= ALLTRIM(GetAdvFVal("ZZM","ZZM_FILFAT",xFilial("ZZM")+M->C5_I_FLFNC,1,""))
         IF EMPTY(cFilsFat)//Testa se a filial de faturamento esta no grupo do campo ZZM
           U_MT_ITMSG('Pedido '+M->C5_NUM + " Filial de Carregamento: "+M->C5_I_FLFNC+" não possui grupo de Filiais de Faturamento",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,;
                           "Entre em contato com a area de TI para cadastrar novas filiais no grupo no Configurador Italac \ Usuários \ Cad Filiais.",1)
           lRet := .F.
         ELSEIF !M->C5_I_FILFT $ cFilsFat//Testa se a filial de faturamento esta no grupo do campo ZZM
           U_MT_ITMSG('Pedido '+M->C5_NUM + "Filial de Faturamento "+M->C5_I_FILFT+" nao esta no grupo de filiais ("+cFilsFat+") da Filial de Carregamento: "+M->C5_I_FLFNC,;
                               'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,;
                           "Entre em contato com a area de TI para cadastrar novas filiais no grupo no Configurador Italac \ Usuários \ Cad Filiais.",1)
            lRet := .F.
         ENDIF
      ENDIF

      SC5->( DBSetOrder(1) )
      IF lRet .AND. !EMPTY(M->C5_I_FLFNC) .AND. M->C5_I_FLFNC <> SC5->C5_FILIAL //Validaco se o usuario estiver na Filial de Faturamento Pedido de Faturamento de troca nota
         IF !EMPTY(M->C5_I_PDPR) .AND. SC5->( DBSeek( M->C5_I_FLFNC + M->C5_I_PDPR ) )
            U_MT_ITMSG('Pedido '+M->C5_NUM +  " nao pode ser alterado por possuir um Pedido de Carregamento: "+M->C5_I_FLFNC +" "+ M->C5_I_PDPR,'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,;
                           "Estorne o Documento de Transferencia",1)
            lRet := .F.
         ENDIF
      ENDIF

      IF lRet .AND. !EMPTY(M->C5_I_FILFT) .AND. M->C5_I_FILFT <> SC5->C5_FILIAL//Validaco se o usuario estiver no Pedido de Carregamento de troca nota
         IF !EMPTY(M->C5_I_PDFT) .AND. SC5->( DBSeek( M->C5_I_FILFT + M->C5_I_PDFT ) )
               U_MT_ITMSG('Pedido '+M->C5_NUM + " nao pode ser alterado por possuir um Pedido de Faturamento: "+M->C5_I_FILFT +" "+ M->C5_I_PDFT,'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,;
                           "Estorne o Documento de Transferencia",1)
            lRet := .F.
         ENDIF
      ENDIF

      IF lRet .AND. !EMPTY(M->C5_I_FILFT) .AND. M->C5_I_FILFT <> SC5->C5_FILIAL//validacao para nao transferir um numero de pedio que já exista na filial de faturamento
         IF SC5->( DBSeek( M->C5_I_FILFT + M->C5_NUM ) )//seek do numero atual na filial de faturamento
            U_MT_ITMSG('Pedido: '+M->C5_NUM + "nao pode ser alterado para troca nota por que já existe mesmo número na filial de Faturamento: "+M->C5_I_FILFT,'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,;
                           "Faça uma copia desse pedido para gerar um numero novo e altere a copia para troca nota.",1)
            lRet := .F.
         ENDIF
      ENDIF

      _cOperTriangular:= ALLTRIM(U_ITGETMV( "IT_OPERTRI","05,42"))// Tipos de operações da operação triangular
      lAchouZPE:=.F.

       IF lRet .AND. !M->C5_I_OPER $ "50/51" .AND. ZPE->(DBSEEK(xFilial("ZPE")))//Codigo se segurança para quando não tiver nada cadastrado não validar

            ZPE->(DBSETORDER(3))//ZPE_FILIAL+ZPE_GERCOD+ZPE_ESTADO+ZPE_OPERAC+ZPE_ADQUIR+ZPE_ADQLOJ+ZPE_FILCAR+ZPE_FILFAT
               _cProdZPF:=""
               IF ZPE->(DBSEEK(xFilial("ZPE")+M->C5_VEND3+M->C5_I_EST))

                  DO WHILE ZPE->(!EOF()) .AND. xFilial("ZPE")+ZPE->ZPE_GERCOD+ZPE->ZPE_ESTADO == ZPE->ZPE_FILIAL+M->C5_VEND3+M->C5_I_EST

                  IF M->C5_I_OPER $ ZPE->ZPE_OPERAC
                     IF !(M->C5_I_OPER $ _cOperTriangular) .OR. ZPE->ZPE_ADQUIR+ZPE->ZPE_ADQLOJ == M->C5_I_CLIEN+M->C5_I_LOJEN
                        IF M->C5_I_FLFNC $ ALLTRIM(ZPE->ZPE_FILCAR) .AND. M->C5_I_FILFT $ ALLTRIM(ZPE->ZPE_FILFAT)
                           IF ZPE->ZPE_MSBLQL <> "1"
                              lAchouZPE:=.T.
                           ENDIF
                        ENDIF
                        ENDIF
                     ENDIF

                      IF lAchouZPE

                      For _nnipre := 1 to LEN(acols)
                           If aCols[_nnipre][Len(aCols[_nnipre])]// SE LINHA DELETADA
                              Loop
                           EndIf
                           _cProdSZPF:=acols[_nnipre][nPosProduto]
                              ZPF->(DBSETORDER(1))//ZPF_FILIAL+ZPF_CODIGO+ZPF_PROCOD+ZPF_GRUPO
                           IF !ZPF->(DBSEEK(xFilial("ZPF")+ZPE->ZPE_CODIGO+_cProdSZPF)) .OR. ZPF->ZPF_MSBLQL = "1"
                                  ZPF->(DBSETORDER(2))//ZPF_FILIAL+ZPF_CODIGO+ZPF_GRUPO+ZPF_PROCOD
                               IF !ZPF->(DBSEEK(xFilial("ZPF")+ZPE->ZPE_CODIGO+LEFT(_cProdSZPF,4))) .OR. ZPF->ZPF_MSBLQL = "1"
                                       lAchouZPE:=.F.
                                       IF !ALLTRIM(_cProdSZPF) $ _cProdZPF
                                          _cProdZPF+=" ["+ALLTRIM(_cProdSZPF)+IF(ZPF->ZPF_MSBLQL='1'," (B)","")+"]"
                                       ENDIF
                                   ENDIF
                           ENDIF
                      NEXT

                       ENDIF

                       ZPE->(DBSKIP())

                   ENDDO

                IF !lAchouZPE
                    lRet := .F.
                    IF !EMPTY(_cProdZPF)
                        U_MT_ITMSG('Gerente: '+M->C5_VEND3+"-"+ALLTRIM(POSICIONE("SA3",1,xFilial("SA3")+M->C5_VEND3,"A3_NOME"))+", UF: "+M->C5_I_EST+", Oper.: "+M->C5_I_OPER+;
                                   ", Cliente: "+M->C5_CLIENTE+M->C5_LOJACLI+"-"+Alltrim( Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_NREDUZ"))+;
                                   " e Filiais da Troca Nota: "+M->C5_I_FLFNC+" / "+M->C5_I_FILFT+" não pertence ao grupo de filiais autorizadas cadastradas (ZPF) para esses Produtos: "+_cProdZPF,'Atencao!',;
                                   "Cadastre um grupo de filiais de Troca Nota para esse gerente, estado, Operacao, Filiais da Troca Nota e Produtos ou Grupos (ZPE/ZPF).",1)
                    ELSE
                        U_MT_ITMSG('Gerente: '+M->C5_VEND3+"-"+ALLTRIM(POSICIONE("SA3",1,xFilial("SA3")+M->C5_VEND3,"A3_NOME"))+", UF: "+M->C5_I_EST+", Oper.: "+M->C5_I_OPER+;
                                   ", Cliente: "+M->C5_CLIENTE+"-"+M->C5_LOJACLI+"-"+Alltrim( Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_NREDUZ") )+;
                                   " e Filiais da Troca Nota: "+M->C5_I_FLFNC+" / "+M->C5_I_FILFT+" não pertencem a nenhum grupo de filiais autorizadas cadastradas p/ Troca NF (ZPE).",'Atencao!',;
                                   "Cadastre um grupo de filiais de Troca Nota para esse gerente, estado, Operacao, Filiais da Troca Nota e Produtos ou Grupos (ZPE).",1)
                    ENDIF
                ENDIF

            ELSEIF !lAchouZPE
                 U_MT_ITMSG('Gerente: '+M->C5_VEND3+"-"+ALLTRIM(POSICIONE("SA3",1,xFilial("SA3")+M->C5_VEND3,"A3_NOME"))+", UF: "+M->C5_I_EST+", Oper.: "+M->C5_I_OPER+;
                            ", Cliente: "+M->C5_CLIENTE+"-"+M->C5_LOJACLI+"-"+Alltrim( Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_NREDUZ") )+;
                            " e Filiais da Troca Nota: "+M->C5_I_FLFNC+" / "+M->C5_I_FILFT+" não pertencem a nenhum grupo de filiais autorizadas cadastradas p/ Troca NF (ZPE).",'Atencao!',;
                            "Cadastre um grupo de filiais de Troca Nota para esse gerente, estado, Operacao, Filiais da Troca Nota e Produtos ou Grupos (ZPE).",1)
                 lRet := .F.
            ENDIF


           ENDIF

   ELSEIF M->C5_I_TRCNF = "N"

      IF EMPTY(M->C5_I_PDFT) .AND. EMPTY(M->C5_I_PDPR)
         M->C5_I_FLFNC:=SPACE(LEN(SC5->C5_I_FLFNC))
         M->C5_I_FILFT:=SPACE(LEN(SC5->C5_I_FILFT))
      ENDIF

   ENDIF

   RestArea(_aAreaSC5)
   RestArea(_aArea)

ELSEIf  lRet .and. !_l108 .and. !_laoms074 .AND. M->C5_I_TRCNF = "S"

    IF M->C5_TIPO # "N"
       U_MT_ITMSG('O pedido '+M->C5_NUM +  " foi marcado como troca nota que só pode ser usado com Pedido do Tipo Normal",'Atencao!',;
                  'Altere o tipo do Pedido para "N"-Normal',1)
       lRet := .F.
    ENDIF

Endif

SA1->( DBSetOrder(1) )
SA1->( DBSeek( xFilial('SA1') + M->( C5_CLIENTE + C5_LOJACLI ) ) )

//================================================================================
// Verifica se o ponto de entrada está sendo chamado da rotina de Efetivação
// do Pedido de Vendas (AOMS112), caso afirmativo, verifica se a variável de
// memória M->C5_I_AGEND está preenchida ou não. Caso a variável _cTpAgenda
// definida no fonte exista e possua conteúdo e a variável M->C5_I_AGEND esteja
// vazia, o conteúdo da variável _cTpAgenda é atribuido a variável:
//  M->C5_I_AGEND := _cTpAgenda.
// Obs.: A chamada do ponto de entrada MT410TOK estava limpando o conteúdo da
// da variável M->C5_I_AGEND.
//================================================================================
If _lAoms112
   If Empty(M->C5_I_AGEND) .And. Type("_cTpAgenda") == "C"
      If !Empty(_cTpAgenda)
         M->C5_I_AGEND := _cTpAgenda
      EndIf
   EndIf
EndIf

//================================================================================
// Validação do tipo de entrega
//================================================================================
If lRet .and. !_l108 .and. !_laoms074 .AND. (ParamIXB[1] = 3 .Or. ParamIXB[1] = 4) .AND.;
   M->C5_TIPO = "N" .AND. M->C5_I_OPER $ u_itgetmv("IT_TPOPER","01,42,08,12,15,24,25,26") .AND.;
  !(FunName() $ "MATA140,MATA521B,MATA460B,MATA103,AOMS003")  .AND. !(FWIsInCallStack("U_AOMS099")) .and. !(FWIsInCallStack("M520_VALID"))

   M410Proc(oProc,"Tipo de entrega")
   IF Empty(M->C5_I_AGEND)
      U_MT_ITMSG(' Pedido  '+M->C5_NUM + " Tipo de Entrega não preenchido.",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,;
                     'Preencher Tipo de Entrega, um dos ultimos campos da primeira pasta.',1)
      lRet := .F.

   ELSEIF M->C5_I_AGEND = 'M' .AND. SA1->A1_I_AGEND <> M->C5_I_AGEND//Quando o PV é M o Cliente tem que ser tb

     U_MT_ITMSG('Pedido '+M->C5_NUM + " Tipo de Entrega do Cliente ["+U_TipoEntrega(SA1->A1_I_AGEND)+"] diferente do informado no Pedido [M].", 'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM, ;
                     'Cliente não pode ser Agendado c/ multa. Altere o Tipo de Entrega do Pedido para DIFERENTE de [M – AGENDADA C/ MULTA]',1)
      lRet := .F.
   ENDIF

ENDIF

If Inclui .Or. Altera
   IF SA1->A1_I_BLQDC == "1" .And. M->C5_TIPO = "N"//Bloqueio por deconto contratual

     U_MT_ITMSG("Cliente com bloqueio de Desconto Contratual.",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,"Favor procurar o departamento de Contratos para solicitar o desbloqueio.",1)
     lRet := .F.

   ENDIF
ENDIF

//==================================================================
// Na criação/alteração do Pedido de Operação Triangular 42,
// Verifica se existe TES para o Pedido de Destino Operação 05.
//==================================================================  
_cItemOpeT := ""
If ParamIXB[1] == 3 .Or. ParamIXB[1] == 4 //1-Excluir; 3-Incluir/Copiar; 4-Alterar;
   If M->C5_I_OPER == _cOperRemessa .And. ! Empty(M->C5_I_CLIEN)
      SA1->(MsSeek(xFilial("SA1") + M->C5_I_CLIEN + M->C5_I_LOJEN))
      _cSuframa := If(!EMPTY(SA1->A1_SUFRAMA),"S","N")
      //_cCpoSN   := If(SA1->A1_SIMPNAC="1","S","N")
      //_cCpoCI   := If(SA1->A1_CONTRIB="2","N","S")
      _cEstCli  := SA1->A1_EST
      _cEstFil  := SM0->M0_ESTCOB
   EndIf 
EndIf 
//================================================================================
// Processa todos os itens do Pedido
//================================================================================
DO While nX <= Len(aCols) .And. lRet .and. !_l108 .and. !_laoms074
   //================================================================================
   // Muda o valor de N
   //================================================================================
   N := nX

   //================================================================================
   M410Proc(oProc,"Regras do Item "+aCols[nX][nPosIte])

   //================================================================================
   // ****************  REGRA DE BLOQUEIO DE VENDAS DO PEDIDO  *********************
   _cMenBroqueio:=""
   IF lRet .AND.  M->C5_I_TRCNF <> "S" .AND. M->C5_TIPO = "N" .AND. Inclui .AND. !(FunName() $ "OMSA200,MATA140,MATA521B,MATA460B,MATA103") .and. !(FWIsInCallStack("U_AOMS099"));
    .and. !(FWIsInCallStack("U_AOMS099"))  .and. !(FWIsInCallStack("M520_VALID"))
    IF U_BloqueiaPV(M->C5_CLIENTE,M->C5_LOJACLI,aCols[nX][nPosProduto],@_cMenBroqueio,M->C5_I_OPER)
        U_MT_ITMSG('Pedido '+M->C5_NUM + " " + _cMenBroqueio,'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,;
                   "Existe regra de bloqueio de faturamento para as condições acima deste pedido. Duvidas procurar o departamento fiscal.",1)
         lRet:=   .F.
         EXIT
      ENDIF
   ENDIF
   // ****************  REGRAS DE BLOQUEIO DE VENDAS DO PEDIDO  *********************
   //================================================================================

    If ParamIXB[1] == 3 .Or. ParamIXB[1] == 4 //1-Excluir; 3-Incluir/Copiar; 4-Alterar;

       If !(FWIsInCallStack("U_AOMS074"))
          aCols[nX][_nPosQPale] := U_AOMS010() // Recalcula quantidade de Pallets
       EndIf

       //======================================================
       // Atualiza campo Centro de Custo do Item C6_CC.
       //======================================================
       M->C6_PRODUTO := aCols[nX][nPosProduto]
       aCols[nX][_nPosCC] := U_ACOM034G()
       //======================================================

        aCols[nX][nPosPedCli]:= StrTran( StrTran( StrTran( aCols[nX][nPosPedCli] , "ª" , "" ) , "º" , "" ) , CHAR(176) , "" ) // VERIFICAR O PEDIDO DO CLIENTE NÃO CONTEM CARACTER ESPECIAL
          aCols[nX][_nPosItPc] := aCols[nX][nPosIte]
          cTes                 := GetAdvFVal( "SF4" , "F4_DUPLIC" , xFilial("SF4") + aCols[nX][nPosTes] , 1 , "" )

         If !GdDeleted(nX) .and. M->C5_TIPO = "N" .And. cTes == "S" .And. !FWIsInCallStack("U_AOMS032") .And. !FWIsInCallStack("U_AOMS032EXE") .And. !(FunName() $ "MATA140,MATA521B,MATA460B,MATA103")  .And. !_lAoms112 ;
            .And. alltrim(aCols[nX][nPosProduto]) <> _cchep
            If !(FWIsInCallStack("U_AOMS099")) .and. !(FWIsInCallStack("M520_VALID")) .AND. !(AllTrim(aCols[nX,_cCFOP]) $ '5910/6910/5911/6911') .AND. ParamIXB[1] <> 1 .AND. ParamIXB[1] <> 5  .And. !(FWIsInCallStack("U_AOMS098")) //EXCLUIR DO MENU  OU  EXCLUSAO EXECAUTO
                If _lItemAlterado .Or. Inclui  .Or. ( alltrim(SC5->C5_CLIENTE) != alltrim(M->C5_CLIENTE) .AND. alltrim(SC5->C5_LOJACLI) != alltrim(M->C5_LOJACLI))

                    _aBlqprc  := U_BLQPRC(aCols[nX][nPosProduto],aCols[nX][nPosPreco],SC5->C5_FILIAL,.F., M->C5_I_TAB,,_lusanovo,, .T., _cGrupoP,_cUFPedV ,         ,         ,_lSimplNac,nPsBru,0)
                    _lPrcErr  := _aBlqprc[1]
                    _nFaixa   := _aBlqprc[2]
                    _cMsgPrc  := _aBlqprc[3]  // Grupo de estoque do produto.
                    _nPrecoIt := _aBlqprc[4]
                    _nPrecoMin:= _aBlqprc[5]

                    M->C5_I_FXPES := _nFaixa

                    If _lPrcErr
                        lBlq3   			:= .T.
                        _lbloq4				:= .T.
                        M->C5_I_BLPRC		:= "B"
                        M->C5_I_DTLIB		:= CTOD("")
                        aCols[nX][nPosBlPrc] := "B"
                        //Se tem liberacao  de preco mas não passou na validacao verifica se o preco e prazo de liberacao estao ok
                        //Se tem liberacao  de preco mas não passou na validacao verifica se cliente e loja é igual ao original
                    EndIf
                    aCols[nX][nPosVlTab]  := _nPrecoIt
                    aCols[nX][nPosPrMin]  := _nPrecoMin
                EndIF
            EndIf
        EndIf

        If Inclui .or. Altera
            //================================================================================
            // VERIFICAR UNIDADES DE MEDIDA
            //================================================================================
            If lRet .And. !_laoms074 .and. M->C5_TIPO = "N"
                If !aCols[nx,len(aHeader)+1] // Se Linha Nao Deletada
                    cPosPrd	:= aScan( aHeader , {|nx| UPPER(Alltrim(nx[2]) ) == "C6_PRODUTO" } )
                    cNumPrd	:= ALLTRIM( Acols[nx][cPosPrd] )
                    cFatCon	:= Posicione( "SB1" , 1 , xFilial("SB1") + cNumPrd			, "B1_I_SFCON" )
                    cQtdZero	:= Posicione( "SF4" , 1 , xFilial("SF4") + aCols[n,nPosTes]	, "F4_QTDZERO" )

                    nPosDifPe 		:= Ascan( aHeader , { |x| AllTrim(x[2]) == "C6_I_DIFPE"  } )
                    cDifPe			:= acols[n,nPosDifPe]

                    SB1->( DBSetOrder(1) )
                    SB1->( DBSeek( xFilial("SB1") + cNumPrd ) )

                    If cDifPe == "S"

                        If lPrim

                            If U_MT_ITMSG("Ped.: " + M->C5_NUM + " Devolução é referente a Diferença de Pesagem entre a Italac e o Cliente?",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,,3,2,2 )
                                lDifPes := .T.
                            Else
                                If cFatCon == "1"

                                    _lSegDif := VldPeca(nx)

                                    If !_lSegDif
                                        acols[n,nPosDifPe] := "N"
                                    EndIf
                                EndIf
                            Endif

                        Endif

                        If !_lSegDif .and. !lDifPes

                            If !EMPTY(aItens)

                                For y := 1 to Len(aItens)

                                    cItens += aItens[y][1] +" "
                                    cItens += aItens[y][2] +" "
                                    cItens += CVALTOCHAR( aItens[y][3] ) +" / "
                                    cItens += CVALTOCHAR( aItens[y][4] ) +" = "
                                    cItens += CVALTOCHAR( aItens[y][5] ) +CHR(13)+CHR(10)

                                Next y


                                U_MT_ITMSG('Pedido '+M->C5_NUM + " Quantidades informadas (Quantidade/Qtd. 2a UM) não correspondem aos limites de fator de conversão."	,;
                                            'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,"Verifique as quantidades informadas para o(s) produto(s):"+ CHR(13) + CHR(10) + cItens + " ",1 )

                                lRet := .F.

                            Endif

                        Endif

                        lPrim := .F.
                        VldDev(nx)


                    Else
                        If cFatCon == "1"
                            _lSegDif := VldPeca(nx)

                            If !_lSegDif
                                acols[n,nPosDifPe] := "N"
                            EndIf
                        EndIf

                        If !_lSegDif

                            If !EMPTY(aItens)

                                For y := 1 to Len(aItens)
                                    cItens += aItens[y][1] +" "
                                    cItens += aItens[y][2] +" "
                                    cItens += CVALTOCHAR( aItens[y][3] ) +" / "
                                    cItens += CVALTOCHAR( aItens[y][4] ) +" = "
                                    cItens += CVALTOCHAR( aItens[y][5] ) +CHR(13)+CHR(10)
                                Next y

                                U_MT_ITMSG(	'Pedido '+M->C5_NUM + " Quantidades informadas (Quantidade/Qtd. 2a UM) não correspondem aos limites de fator de conversão."	,;
                                            'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,"Verifique as quantidades informadas para o(s) produto(s):"+ CHR(13) + CHR(10) + cItens + " ",1 )

                                lRet := .F.

                            Endif

                        Endif
                    Endif

                EndIf

            Endif
        EndIf
        //================================================================================
        //  Valida o preenchimento da segunda unidade de medida
        //================================================================================
         If lRet .AND. !(FunName() $ "MATA140,MATA521B,MATA460B,MATA103,AOMS003") .and. !(FWIsInCallStack("U_AOMS099")) .and. !(FWIsInCallStack("M520_VALID"))  //NÃO VALIDA NAS MOVIMENTAÇÕES DE PEDIDO DO TROCA NOTA
            lRet := U_AOMS050(1,aCols[n,nPosTes],lDifPes)
        EndIF

    EndIf

    If ParamIXB[1] == 3 .Or. ParamIXB[1] == 4 //1-Excluir; 3-Incluir/Copiar; 4-Alterar;
       //================================================================================
       // Valida NCM informado no cadastro do produto.
       //================================================================================
       IF lRet .AND. !(FunName() $ "MATA140,MATA521B,MATA460B,MATA103,AOMS003") .and. !(FWIsInCallStack("U_AOMS099")) .and. !(FWIsInCallStack("M520_VALID")) .And. _cTipoPedido !="T" //NÃO VALIDA NAS MOVIMENTAÇÕES DE PEDIDO DO TROCA NOTA
           lRet := U_AOMS050(2)
       EndIf

       //===============================================================================
       // Replica Data de Entrada Informada na C5 para C6
       //================================================================================
       IF lRet .AND. !(FunName() $ "MATA140,MATA521B,MATA460B,MATA103,AOMS003") .and. !(FWIsInCallStack("U_AOMS099")) .and. !(FWIsInCallStack("M520_VALID")) .And. _cTipoPedido !="T" .And. !_lAoms112 //NÃO VALIDA NAS MOVIMENTAÇÕES DE PEDIDO DO TROCA NOTA
         lRet := U_AOMS050(3)
       EndIf
       //================================================================================
       // Funcao responsavel por efetuar a validacao no pedido de venda para constatar se
       // o produto indicado na linha corrente possui regra de comissao amarrada para o
       // vendedor indicado no pedido de venda desta forma proibindo que se inclua um
       // pedido de venda sem autorizacao
       //================================================================================
       If lRet .And. M->C5_TIPO == 'N' .AND.;
          !(FunName() $ "MATA140,MATA521B,MATA460B,MATA103,AOMS003").and. !(FWIsInCallStack("M520_VALID"));
          .and. !(FWIsInCallStack("U_AOMS099"))  //NÃO VALIDA NAS MOVIMENTAÇÕES DE PEDIDO DO TROCA NOTA
          lRet:= U_AOMS049(M->C5_VEND1,.T., M->C5_CLIENTE,M->C5_LOJACLI,_cRedeCliente)
       EndIf

       //================================================================================
       // Chama a funcao de recalculo da comissao
       //================================================================================
       If M->C5_TIPO = "N"
           U_AOMS013(.T.)
       EndIf

       //================================================================================
       // Validar preco do produto com a tabela de preço de transferencias
       // somente quando não é troca nota
       //================================================================================
       If M->C5_I_OPER $ U_ITGETMV("IT_OPMEDIO", '22') .And. !GdDeleted(nx) .and. !(M->C5_I_TRCNF = "S") .and.  M->C5_TIPO = "N" .AND. !(FunName() $ "MATA140,MATA521B,MATA460B,MATA103,AOMS003") .And. !_lAoms112 .And. !(FWIsInCallStack("U_AOMS099")) .and. !(FWIsInCallStack("M520_VALID")) //NÃO VALIDA NAS MOVIMENTAÇÕES DE PEDIDO DO TROCA NOTA
          _ccodipro := U_ITVLPRTR( M->C5_I_OPER , GdFieldGet( "C6_PRODUTO" , nx ) , GdFieldGet( "C6_PRCVEN" , nx ), 2 )
          If Len(alltrim(_ccodipro)) > 1
             Aadd(_aprod,_ccodipro)  //se tem problema vai adicionando na matriz para mostrar todos de uma vez
          EndIf
       EndIf

       //===============================================================================
       //Valida se o armazém é para faturamento - Conforme cadastro "Locais de estoque"
       //Se operação estiver no campo de exceção para faturamento deixa faturar mesmo
       // que local de estoque não seja de faturamento
       //===============================================================================
       If lRet
          _cAmFatP := Posicione("NNR",1,xFilial("NNR")+aCols[nx,nPosLoc],"NNR_I_AMFT")
          _cAmDevo := Posicione("NNR",1,xFilial("NNR")+aCols[nx,nPosLoc],"NNR_I_AMDE")
          If _cAmFatP == "N" .and. !( alltrim(M->C5_I_OPER) $ alltrim(NNR->NNR_I_EXFT) ) .and. !(M->C5_TIPO == 'D' .AND. _cAmDevo == "S")
                lRet := .F.
                U_MT_ITMSG("O local informado: " + AllTrim(aCols[nx,nPosLoc]) + " , não é um armazém válido para faturamento.","Alerta",;
                "Favor informar outro armazém.",1)
          Endif
       Endif

    EndIf

    AADD(_aItensLock, { aCols[nX][nPosProduto] , aCols[nX][nPosAmz] })
    If aCols[nX][nPosBlPrc] == "B"
       _lbloq4 := .T.  //Existe Item Bloqueado, então bloquear C5_I_BLPRC
    EndIf

    //==================================================================
    // Na criação/alteração do Pedido de Operação Triangular 42,
    // Verifica se existe TES para o Pedido de Destino Operação 05.
    //==================================================================
    If ParamIXB[1] == 3 .Or. ParamIXB[1] == 4 //1-Excluir; 3-Incluir/Copiar; 4-Alterar;
       If M->C5_I_OPER == _cOperRemessa .And. ! Empty(M->C5_I_CLIEN)
          _cTESOperT := U_SelectTES(aCols[nX][nPosProduto],_cSuframa,_cEstCli,_cEstFil,M->C5_I_CLIEN,M->C5_I_LOJEN,"05",aCols[nX][nPosAmz],M->C5_TIPO)
          If Empty(_cTESOperT)
             _cItemOpeT += aCols[nX][nPosProduto] + "-" + Posicione("SB1",1,xfilial("SB1")+aCols[nX][nPosProduto],"B1_DESC") +"; "
          EndIf 
       EndIf 
    EndIf 

    nX++

EndDo

//==================================================================
// Na criação/alteração do Pedido de Operação Triangular 42,
// Verifica se existe TES para o Pedido de Destino Operação 05.
//==================================================================
If ParamIXB[1] == 3 .Or. ParamIXB[1] == 4 //1-Excluir; 3-Incluir/Copiar; 4-Alterar;
   If M->C5_I_OPER == _cOperRemessa .And. ! Empty(_cItemOpeT)
      U_MT_ITMSG("Não existem TES cadastradas para algum(uns) item(ns) do Pedido de Vendas de Operação Triangular 05.",;   //,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
                 'Atencao!',"Para gravar o Pedido de Vendas de Operação Triangular 42, deve-se cadastrar a TES dos itens do Pedido de Vendas de Operação Triangular 05.",1     ,       ,        ,         ,     ,     ,{|| U_ITMSGLOG(_cItemOpeT,"Itens sem TES cadastrada para Pedido de Operação Triangular 05.") }, _cItemOpeT)
      lRet := .F.
   EndIf 
EndIf 

//======================================================================
// Valida a data de entrega uma única vez na capa do pedido de vendas.
//======================================================================
If lRet
   If funname() == "MATA410" .and. (FWIsInCallStack('A410PCopia') .OR.  !INCLUI .And. M->C5_I_DTENT != SC5->C5_I_DTENT ) .OR. ( INCLUI .AND. M->C5_I_AGEND != "P")  //Só valida na alteração de houver mudança da data de entrega
      If (M->C5_I_AGEND <> 'P') .OR. !INCLUI .And. M->C5_I_DTENT != SC5->C5_I_DTENT  // ( INCLUI .AND. M->C5_I_AGEND != "P") // M->C5_I_AGEND == 'I'
         //Sempre valida na inclusão e entrega imediata e na alteração de data de entrega
         _cFilCarreg := xFilial("SC5")
         If ! Empty(M->C5_I_FLFNC)
            _cFilCarreg := M->C5_I_FLFNC
         EndIf

         lRet:= U_OMSVLDENT(M->C5_I_DTENT, M->C5_CLIENT, M->C5_LOJACLI, M->C5_I_FILFT, M->C5_NUM,0    ,      ,_cFilCarreg,M->C5_I_OPER,M->C5_I_TPVEN) //Valida data de entrega
      EndIf
   EndIf
EndIf

//================================================================================================
// Valida se a data de entrega é maior que a data máxima de agendamento para pedidos agendados.
//================================================================================================
If lRet 
   If funname() == "MATA410" .And. (INCLUI .Or. ALTERA)
      If (M->C5_I_AGEND == 'A' .Or. M->C5_I_AGEND == 'M')  //A=AGENDADA;I=IMEDIATA;M=AGENDADA C/MULTA;P=AGUARD. AGENDA;R=REAGENDAR;N=REAGENDAR C/MULTA;T=Agend. pelo Transp;O=AGENDADO PELO OP.LOG
        	                  // U_OMSVLDENT(M->C5_I_DTENT, M->C5_CLIENT, M->C5_LOJACLI, M->C5_I_FILFT, M->C5_NUM,0    ,      ,_cFilCarreg,M->C5_I_OPER,M->C5_I_TPVEN) //Valida data de entrega
         _dDtAgeEnt := DATE()+U_OmsVldEnt(DATE()       , M->C5_CLIENT,M->C5_LOJACLI,M->C5_I_FILFT  ,M->C5_NUM ,1    ,.F.   ,_cFilCarreg,M->C5_I_OPER,M->C5_I_TPVEN)

		   _dDtAgeMax := U_DTVAL112(_dDtAgeEnt)

         If M->C5_I_DTENT >_dDtAgeMax
            U_MT_ITMSG("A data de entrega: "+Dtoc(M->C5_I_DTENT) +",  não pode ser maior que a data máxima permitida para agendamento: " + Dtoc(_dDtAgeMax) +".",'Validação Data de Entrega',,1 )
            lRet := .F.
         EndIf 

      EndIf 
   EndIf 
EndIf 

//********************** VALIDACAO NOVA DE CREDITO UNIFICADA ***************************************************//
If lRet .And. !(FunName() $ "MATA140,MATA521B,MATA460B,MATA103,AOMS003") .And. !_lAoms112 .and. !(FWIsInCallStack("U_AOMS099")) .And. M->C5_TIPO = 'N' .AND. (Inclui .or. Altera) .and. !_l108 .and. !_laoms074 .and. !(FWIsInCallStack("M520_VALID"))

    M410Proc(oProc,"Credito Unificado")
    _nTotPV:=0
    _lValCredito:=.T.
    
    for _ni := 1 to len(acols)

       If !GdDeleted(_ni)

           _nTotPV += acols[_ni][nPosVal]

          If alltrim(aCols[_ni][nPosProduto]) == _cchep .OR. AllTrim(aCols[_ni,_cCFOP]) $ '5910/6910/5911/6911'//NÃO VALIDA CRÉDITO PARA PALLET CHEP E PARA BONIFICAÇÃO
             _lValCredito:=.F.
             EXIT
          ENDIF

          If posicione("SF4",1,xFilial("SF4")+aCols[_ni,nPosTes],"F4_DUPLIC") != 'S' //NÃO VALIDA CRÉDITO PARA PEDIDO SEM DUPLICATA
             _lValCredito:=.F.
             EXIT
          Endif

          If posicione("ZAY",1,xfilial("ZAY")+ AllTrim(aCols[_ni,_cCFOP]) ,"ZAY_TPOPER") != 'V' //NÃO VALIDA CRÉDITO PARA PEDIDO COM CFOP QUE NÃO SEJA DE VENDA
             _lValCredito:=.F.
             EXIT
          Endif

       Endif

    Next _ni

    IF _lValCredito
    
         If M->C5_I_OPER == _cOperRemessa .AND. !Empty(M->C5_I_CLIEN)
            __cCodCli := M->C5_I_CLIEN
            __cLojaCli := M->C5_I_LOJEN
         Else
            __cCodCli := M->C5_CLIENTE
            __cLojaCli := M->C5_LOJACLI
         Endif
         
         _aRetCre := U_ValidaCredito( _nTotPV , __cCodCli , __cLojaCli , Altera , , , , M->C5_MOEDA,Inclui,M->C5_NUM, M->C5_VEND3, M->C5_VEND2, M->C5_VEND4, M->C5_VEND1)
         _cBlqCred:=_aRetCre[1]

         If _aRetCre[2] = "B"//Se bloqueou

            If M->C5_I_BLCRE == "R"

                U_MT_ITMSG("Pedido " + M->C5_NUM + " Avaliação de crédito do pedido não foi aprovada - "	+;
                "O pedido continuará marcado como REJEITADO.",'Validação Crédito',,1 )
                lBlq2			:= .T.
                M->C5_I_BLCRE	:= "R"
                M->C5_I_DTAVA := DATE()
                M->C5_I_HRAVA := TIME()
                M->C5_I_USRAV := cusername
                M->C5_I_MOTBL := _cBlqCred


            Else

                U_MT_ITMSG("Pedido " + M->C5_NUM + " Avaliação de crédito do pedido não foi aprovada - "	+;
                            "O pedido será marcado como bloqueado para posterior avaliação.",'Validação Crédito',,1 )

                lBlq2			:= .T.
                M->C5_I_BLCRE	:= "B"
                M->C5_I_DTAVA := DATE()
                M->C5_I_HRAVA := TIME()
                M->C5_I_USRAV := cusername
                M->C5_I_MOTBL := _cBlqCred

            Endif

         EndIf

        M->C5_I_MOTBL := _cBlqCred//Sempre grava a descrição

    ENDIF//IF _lValCredito

ENDIF
//********************** VALIDACAO NOVA DE CREDITO UNIFICADA ***************************************************//

//===============================================================================
// Se bloqueiou uma das linhas por preço, bloqueia o pedido, senão libera
//===============================================================================
If _lbloq4

    M->C5_I_BLPRC := "B"
    M->C5_I_DTLIB := CTOD("")

Elseif M->C5_I_BLPRC != "L"

    M->C5_I_BLPRC := " "
    M->C5_I_DTLIB := CTOD("")

Endif

//===============================================================================
// Se bloqueiou uma das linhas por crédito bloqueia o pedido, senão libera
//===============================================================================

If !_lValCredito

    M->C5_I_LIBC  := 0
    M->C5_I_LIBCA := ""
    M->C5_I_LIBCT := ""
    M->C5_I_LIBL  := CTOD("")
    M->C5_I_LIBCV := 0
    M->C5_I_LIBCD := CTOD("")
    M->C5_I_BLCRE := ""
    M->C5_I_MOTBL := ""
    M->C5_I_DTLIC := CTOD("")

    M->C5_I_DTAVA := CTOD("")
    M->C5_I_HRAVA := ""
    M->C5_I_USRAV := ""

ELSEIf lBlq2

    If M->C5_I_BLCRE != "R"
        M->C5_I_BLCRE	:= "B"
    Endif
    M->C5_I_DTAVA := DATE()
    M->C5_I_HRAVA := TIME()
    M->C5_I_USRAV := cusername
    M->C5_I_MOTBL := _cBlqCred

Elseif M->C5_I_BLCRE != "L" .and. M->C5_I_LIBC != 2

    M->C5_I_BLCRE	:= ""
    M->C5_I_LIBC := 0
    M->C5_I_DTAVA := DATE()
    M->C5_I_HRAVA := TIME()
    M->C5_I_USRAV := cusername
    M->C5_I_MOTBL := _cBlqCred

Elseif M->C5_I_BLCRE != "L" .and. M->C5_I_LIBC == 2

    M->C5_I_BLCRE	:= "L"

Endif

//================================================================================
// Se tem produto com problema de preço de transferência apresenta mensagem
// com todos de uma vez.
//================================================================================
if len(_aprod) >= 1

    M410Proc(oProc,"Preco de transferencia")

     _ccodpro := "Para o tipo de operação "+M->C5_I_OPER+" existem produtos no pedido que não estão em conformidade com a Tabela de Preço de Transferência."
     //_ccodpro += +space(40)+"------------------------------------------------------------------------------------------------"
     for _nY := 1 to len(_aprod)

       _ccodpro += _ENTER + alltrim(_aprod[_ny]) + " - " + posicione("SB1",1,xfilial("SB1")+_aprod[_ny],"B1_DESC") //+space(20)

     next _nY

      //================================================================================
      //Não tem tabela de preço de transferência para o produto
      //================================================================================
                //_cMens                             ,_cTitu              ,_cSolu                                            ,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
          U_MT_ITMSG('Ped.: '+M->C5_NUM + " " + _ccodpro,"Validação de preço","Favor solicitar apoio ao Departamento Comercial.",1     ,       ,        ,         ,     ,     ,{|| U_ITMSGLOG(_ccodpro,"Validação de preço") }, _ccodpro)

    lRet := .F.

endif

If ParamIXB[1] == 3 .Or. ParamIXB[1] == 4 .and. !_l108 .and. !_laoms074//1-Excluir; 3-Incluir/Copiar; 4-Alterar;

    //================================================================================
    // Restaura o valor da variavel padrao
    //================================================================================
    N := nN

    //================================================================================
    // Validacao para campos C5_I_NFREF e C5_I_SERNF, quando o
    // usuario informar que eh uma nota fiscal de sedex devera necessariamente
    // informar a NF e Serie de Referencia
    //================================================================================
    if M->C5_I_NFSED == "S" .And. lRet .And. M->C5_TIPO = "N"

        lRet := (!empty(M->C5_I_NFREF) .and. !empty(M->C5_I_SERNF))

        if !lRet

            U_MT_ITMSG('Pedido '+M->C5_NUM + " Quando campo 'NF Sedex' for 'SIM', deverá necessáriamente ser preenchido a informação 'Número NF' e 'Serie NF'."	,;
                       "Validação Sedex","Preencher informações nos campos relacionados.",1)

        ELSEIF SC5->(FIELDPOS("C5_I_PVREF")) <> 0 .AND. !EMPTY(M->C5_I_PVREF)

            _cPallet:="2"
            _TipoC  :=""
            SA1->(Dbsetorder(1))
            If SA1->( DBSeek( xFilial("SA1") + M->C5_CLIENTE+M->C5_LOJACLI ) )
                _TipoC := SA1->A1_I_CHEP
                IF !EMPTY(SA1->A1_I_PALET)
                    _cPallet:= SA1->A1_I_PALET
                ENDIF
            EndIf
            IF EMPTY(_TipoC)
                _TipoC := "C"
            ENDIF
            IF !SC5->C5_TIPO $ "B/D"//Se NÃO for beneficiamento e Devolução
                IF _cPallet $ "S,1"
                    IF _TipoC = "C"
                        _TipoC:= "1"
                    ELSE
                        lRet:=.F.
                    ENDIF
                ELSE
                    lRet:=.F.
                ENDIF
            ELSE
                lRet:=.F.
            ENDIF

            IF !lRet
               U_MT_ITMSG("O cliente de Destino do SEDEX não é PALLET CHEP.","Validação Sedex","Não precisa preencher o campo PV Referencia e Quantidade de Pallet.",1)
               BREAK
            ENDIF

            SF2->(DBORDERNICKNAME("IT_I_PEDID"))
            IF !SF2->(Dbseek(xFilial()+M->C5_I_PVREF))
               U_MT_ITMSG('Pedido: ['+M->C5_I_PVREF+"] não tem nota fiscal relacionada.","Validação Sedex","Preencha o campo PV Referencia quando a Carga de origem tiver Pallet Chep.",1)
               lRet:=.F.
               BREAK
            ENDIF

            DAI->(Dbsetorder(4))//DAI_FILIAL+DAI_PEDIDO+DAI_COD+DAI_SEQCAR
            IF !DAI->(Dbseek(xFilial()+SF2->F2_I_PEDID+SF2->F2_CARGA))

               U_MT_ITMSG('Carga de Origem: ['+SF2->F2_CARGA +"] da Nota: ["+SF2->F2_DOC+" "+SF2->F2_SERIE+"] não encontrada.","Validação Sedex","Preencha o campo PV Referencia quando a Carga de origem tiver Pallet Chep.",1)
               lRet:=.F.
               BREAK

            ELSEIF DAI->DAI_I_TIPC <> "1" .OR. EMPTY(DAI->DAI_I_QTPA)

               U_MT_ITMSG('Pedido: ['+M->C5_I_PVREF+'] na Carga de Origem: ['+SF2->F2_CARGA + "] da Nota ["+SF2->F2_DOC+" "+SF2->F2_SERIE+"] não é PALLET CHEP.","Validação Sedex","Somente preencha o campo PV Referencia quando a Carga de origem tiver PALLET CHEP.",1)
               lRet:=.F.
               BREAK

            ELSEIF SC5->(FIELDPOS("C5_I_QTPA")) <> 0 .AND. EMPTY(M->C5_I_QTPA)

               U_MT_ITMSG('Pedido: ['+M->C5_I_PVREF+'] na Carga de Origem: ['+SF2->F2_CARGA + "] da Nota: ["+SF2->F2_DOC+" "+SF2->F2_SERIE+"] TEM PALLET CHEP.","Validação Sedex","Preencha o campo Quantidade Pallet quando a Carga de origem tiver Pallet Chep.",1)
               lRet:=.F.
               BREAK

            ENDIF

        ENDIF

    ENDIF

    //================================================================================
    // Funcao responsavel por calcular o somatorio dos valores de descontos
    // contratuais e pegar o numero do contrato caso exista um para o pedido e por
    // validar se o contrato esta ativo, ou com a data de vigencia valida
    //================================================================================
    // Comentado por Fabiano Dias no dia 23/02/10 devido a constatacao do Analista
    // Tiago Correa de que a rotina de desconto contratual nao mais englobaria a parte
    // de pedido de venda somente gerando valores na SF2-SD2-SE1
    //================================================================================
    If lRet .AND. M->C5_TIPO = "N"  .AND. !(FunName() $ "MATA140,MATA521B,MATA460B,MATA103") ;
       .and. !(FWIsInCallStack("U_AOMS099")) .and. !(FWIsInCallStack("M520_VALID")) .And. M->C5_I_OPER != "20" .And. !(FWIsInCallStack("U_AOMS098"))
       M410Proc(oProc,"Contrato")
       lRet := somContrato()
    EndIF

    If lRet

        M410Proc(oProc,"2a U.M.")
        If !valida2Um()

              U_MT_ITMSG(	'Pedido '+M->C5_NUM + " Existe(m) produto(s) informado(s) que não possui(em) a 2a U.M..", "Validação 2a. Unidade"		,;
                            "Favor informar no cadastro do produto a segunda unidade de medida.",1	 )

        EndIf

    EndIf

    If lRet
        For x := 1 to len(aCols)
            M410Proc(oProc,"Item "+aCols[x][nPosIte])
            _nProduto	:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) )	== "C6_PRODUTO"	})
            _nqtdsegu	:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) )	== "C6_UNSVEN"	})
            _cproduto	:= acols[x][_nProduto]
            _nquant		:= acols[x][_nqtdsegu]	//M->C6_UNSVEN

            If _nquant > 0 .and. posicione("SB1",1,xFilial("SB1")+alltrim(_cproduto),"B1_CONV") == 0 .AND. !(alltrim(posicione("SB1",1,xFilial("SB1")+alltrim(_cproduto),"B1_GRUPO ")) $ alltrim(U_ITGETMV("IT_GRP2U", "0006")))

               U_MT_ITMSG("Pedido " + M->C5_NUM + " Produto " + Alltrim(_cproduto) + " não tem fator de conversão cadastrado, impossível usar segunda medida!",'Validação 2a. Unidade',,1)

               lRet := .F.
               Exit
            EndIf
        Next x
    EndIf
EndIf

//================================================================================
// Verifica se Desconto é maior que 10% do Total do Pedido de Vendas
//================================================================================
If lRet .and. Alltrim(M->C5_TPFRETE) $ "F/D" .and. !_l108 .and. !_laoms074

    M410Proc(oProc,"Desconto")
    cPosVlr := aScan( aHeader , {|x| UPPER( Alltrim(x[2]) ) == "C6_VALOR" } )

    For x := 1 to len(aCols)
        nTotal += aCols[x,cPosVlr]
    Next x

    nPerc		:= GETMV( "IT_PERDESC" ,, 0 )
    nDescPer	:= ( nTotal * nPerc ) / 100 //Vlr Tot.*Perc. Permitido = Resulta no Valor permitido para desconto.
    If M->C5_DESCONT > nDescPer

       U_MT_ITMSG('Ped.: '+M->C5_NUM + " Foi informado o Valor do Desconto maior que "+CVALTOCHAR(nPerc)+"% do Valor Total do Pedido!"	, "Validação Desconto",;
                  "Favor verificar o Valor Total do Pedido e o Valor do Desconto.",1)

        lRet := .F.

    Endif

Endif

If ( ParamIXB[1] == 3 .Or. ParamIXB[1] == 4 ) .And. lRet  .and. !_l108//1-Excluir; 3-Incluir/Copiar; 4-Alterar;
    M410Proc(oProc,"TES")
    lRet := vldTESBloq()
EndIf

//================================================================================
// Valida e-mail do cadastro do cliente ou fornecedor
//================================================================================
If ( ParamIXB[1] == 3 .Or. ParamIXB[1] == 4 ) .And. lRet .and. !_l108 .and. !_laoms074 //1-Excluir; 3-Incluir/Copiar; 4-Alterar;
    M410Proc(oProc,"e-mail do cadastro do cliente ou fornecedor")
    lRet := U_vldEmail()
EndIf

//================================================================================
// Valida se o vendedor encontra-se bloqueado no cadastro de vendedor
//================================================================================
If (ParamIXB[1] == 3 .Or. ParamIXB[1] == 4) .And. lRet .and. !_l108 .and. !_laoms074//1-Excluir; 3-Incluir/Copiar; 4-Alterar;
    M410Proc(oProc,"vendedor encontra-se bloqueado no cadastro")
    lRet := U_AOMS044( M->C5_VEND1 )
EndIf

//================================================================================
// Valida o coordenador para verificar se é igual ao da regra de comissao.
//================================================================================
If cTes == "S" .AND. M->C5_TIPO = "N" .And. ( ParamIXB[1] == 3 .Or. ParamIXB[1] == 4 ) .And. lRet .and. !_l108 .and. !_laoms074//1-Excluir; 3-Incluir/Copiar; 4-Alterar;
    M410Proc(oProc,"coordenador")
    lRet := vldCoorden( M->C5_VEND1 , M->C5_VEND2 , M->C5_I_V2NOM , M->C5_CLIENTE , M->C5_LOJACLI , M->C5_VEND3 )
EndIf

//================================================================================
// Campos referentes ao controle de pedidos de venda do tipo bonificacao tenham seus status alterados
// corretamente. Somente na inclusao, copia ou alteracao de um pedido de venda.
//================================================================================
If ( ParamIXB[1] == 3 .Or. ParamIXB[1] == 4 ) .AND. M->C5_TIPO = "N" .And. M->C5_I_OPER = "10" .And. lRet .and. !_l108 .and. !_laoms074 .And. !FWIsInCallStack("U_AOMS032")//1-Excluir; 3-Incluir/Copiar; 4-Alterar;

    //================================================================================
    // Somente sera atualizado o status do pedido de venda quando este nao for
    // executado via siga-auto.
    //================================================================================
    If !l410Auto
       M410Proc(oProc,"bonificacao")

       //================================================================================
       // Verifica se o pedido corrente eh um pedido do tipo bonificacao
       //================================================================================
       If u_vldPedBon( aCols) .and. ParamIXB[1] == 3 //Se é inclusão, inclui bloqueado

            If M->C5_I_BLOQ	!= 'B'

                  U_MT_ITMSG(	"Pedido "+M->C5_NUM + " de bonificação bloqueado - "	+;
                            "O pedido deverá ser liberado antes de ficar disponível para faturamento.",'Validação Bonificação',,1)

            Endif

            M->C5_I_BLOQ	:= 'B'       //Armazena o status bloqueado em um pedido de venda do tipo bonificacao
            M->C5_I_MTBON	:= ' '       //Armazena a matricula do usuario que realizou a aprovacao de pedido de venda
            M->C5_I_DLIBE	:= StoD(' ') //Armazena a data da aprovacao de pedido de venda
            M->C5_I_HLIBE	:= ' ' 	     //Armazena a hora da aprovacao de pedido de venda
            M->C5_I_STAWF	:= 'N' 		 //Armazena se ja foi enviado o HTML para aprovacao a um aprovador
            M->C5_I_BLPRC   := ""
            M->C5_I_BLCRE   := ""

       Elseif  M->C5_I_BLOQ == "L" .and. !vldlibbon(aCols) //se é alteração só bloqueia não tem liberação ou liberação não é mais válida

            M->C5_I_BLOQ	:= 'B'       //Armazena o status bloqueado em um pedido de venda do tipo bonificacao
            M->C5_I_MTBON	:= ' '       //Armazena a matricula do usuario que realizou a aprovacao de pedido de venda
            M->C5_I_DLIBE	:= StoD(' ') //Armazena a data da aprovacao de pedido de venda
            M->C5_I_HLIBE	:= ' ' 	     //Armazena a hora da aprovacao de pedido de venda
            M->C5_I_STAWF	:= 'N' 		 //Armazena se ja foi enviado o HTML para aprovacao a um aprovador
            M->C5_I_BLPRC   := ""
            M->C5_I_BLCRE   := ""

       Elseif .not. u_vldPedBon( aCols) //se não é bonificação zera os campos de bonificação

            M->C5_I_BLOQ:= ' '
            M->C5_I_MTBON := ' '
            M->C5_I_DLIBE := StoD(' ')
            M->C5_I_HLIBE := ' '
            M->C5_I_STAWF := ' '

       EndIf

    EndIf
Else
    If  M->C5_I_OPER $ u_itgetmv("IT_TPOPER","01,42,08,12,15,24,25,26") .And. !(M->C5_I_OPER $ '24/05' .OR.  M->C5_TPFRETE $ "F/D" .OR. M->C5_CONDPAG = "001" ) .And. !FWIsInCallStack("U_AOMS032")
        M->C5_I_BLOQ	:= ' '
        M->C5_I_MTBON:= ' '
        M->C5_I_DLIBE:= StoD(' ')
        M->C5_I_HLIBE:= ' '
        M->C5_I_STAWF:= 'N'
    ElseIf ParamIXB[1] == 4 .And. !FWIsInCallStack("U_AOMS032") .And. M->C5_I_OPER <> "10" .And. SC5->C5_I_OPER == "10"
        M->C5_I_BLOQ	:= ' '
        M->C5_I_MTBON	:= ' '
        M->C5_I_DLIBE	:= StoD(' ')
        M->C5_I_HLIBE	:= ' '
        M->C5_I_STAWF	:= 'N'
    EndIF
EndIf

//Quando Inclusão
If ParamIXB[1] == 3 .And. M->C5_TIPO = "N" .And. lRet .And. !_l108 .And. !_laoms074 .And.;
  !(FunName() $ "MATA140,MATA521B,MATA460B,MATA103,AOMS003") .And. !_lAoms112 .And. ;
   M->C5_I_OPER $ u_itgetmv("IT_TPOPER","01,42,08,12,15,24,25,26") .And. !FWIsInCallStack("U_AOMS032")
   lTemItemPA:=.F.
   FOR _ni := 1 to len(acols)
       IF !GdDeleted(_ni)
          If alltrim(posicione("SB1",1,xfilial("SB1")+acols[_ni][nPosProduto],"B1_TIPO")) == "PA"
             lTemItemPA:=.T.
             EXIT
          ENDIF
       ENDIF
   NEXT

    If (M->C5_I_OPER = '24' .OR.  ( M->C5_TPFRETE $ "F/D" .AND. lTemItemPA) )
        M->C5_I_BLOQ	:= 'B'
        M->C5_I_MTBON	:= ' '
        M->C5_I_DLIBE	:= StoD(' ')
        M->C5_I_HLIBE	:= ' '
        M->C5_I_STAWF	:= 'N'
    EndIF
EndIF

//=====================================================================================
//Na copia, inclusao ou alteracao de um pedido de venda eh verificado para constatar 
//se existem regras de TES INTELIGENTE para os produtos inseridos no pedido de acordo
//com o produto, cliente e loja e suframa, nao necessario retorno por zerar a TES.
//=====================================================================================
If (ParamIXB[1] == 3 .Or. ParamIXB[1] == 4) .And. lRet .And. !l410Auto .and. !_l108 .and. !_laoms074//1-Excluir; 3-Incluir/Copiar; 4-Alterar;

   If M->C5_TIPO == 'N'
      M410Proc(oProc,"regras de TES INTELIGENTE")
      If Len(AllTrim(M->C5_I_OPER)) == 0
         U_MT_ITMSG('Pedido '+M->C5_NUM + " Para o tipo de pedido de venda normal é necessario o fornecimento do campo tipo da operação.","Validação Tipo Operação",;
                    "Para que possa ser realizada uma consulta para checar se existe TES INTELIGENTE.",1)
         lRet:= .F.
      Else

            //====================================================================
            //|Caso o tipo da operacao nao esteja contido nos tipos de operacoes |
            //|que podem ter a sua TES alterada pelo usuario na TES INTELIGENTE. |
            //====================================================================
            If !(M->C5_I_OPER $ AllTrim(_cTpOper))
                lRet:= U_AOMS058(3)
            EndIf

            //==================================================================
            //|Valida o tipo de operacao fornecido diante do cliente informado.|
            //==================================================================
            If lRet
                lRet:=vldTpOper()
            EndIf

      EndIf

   EndIf

EndIf

If (ParamIXB[1] == 3 .Or. ParamIXB[1] == 4) .And. lRet .and. !_l108 .and. !_laoms074

    M410Proc(oProc,"Totais")

    //================================================================================
    // Validação do valor máximo permitido para o campo C5_VOLUME1
    //================================================================================
    _nValVol := Val( AllTrim( StrTran( StrTran( PesqPict("SC5","C5_VOLUME1") , '@E' , '' ) , ',' , '' ) ) )

    If M->C5_VOLUME1 > _nValVol

       If _lMsgEmTela
          U_MT_ITMSG(	'Pedido '+M->C5_NUM +" O volume calculado para esse pedido é maior que o limite para o campo ["+ Transform( _nValVol , PesqPict("SC5","C5_VOLUME1") ) +"]."	,;
                          "Validação volumes",;
                        "O sistema permite que sejam informadas no máximo ["+ Transform( _nValVol , PesqPict("SC5","C5_VOLUME1") ) +"] unidades de Volumes, "	+;
                        "desta forma caso a quantidade digitada esteja correta será necessário digitar mais de um pedido para compor o total.",1					 )
       Else
          _cAOMS074Vld += 'Atencao! (MT410TOK) Ped.: '+M->C5_NUM +;
                           " O volume calculado para esse pedido é maior que o limite para o campo ["+ Transform( _nValVol , PesqPict("SC5","C5_VOLUME1") ) +"]."	+;
                           " O sistema permite que sejam informadas no máximo ["+ Transform( _nValVol , PesqPict("SC5","C5_VOLUME1") ) +"] unidades de Volumes, "	+;
                           " desta forma caso a quantidade digitada esteja correta será necessário digitar mais de um pedido para compor o total."
       EndIf
        lRet := .F.

    EndIf

EndIf

//================================================================================
// VERIFCAÇÃO DO NUMERO DO PEDIDO DE VENDA
//================================================================================
cPedido := M->C5_NUM

If ParamIXB[1] == 3  .and. !_l108 .and. !_laoms074

    cMay := "SC5"+ Alltrim( xFilial("SC5") )

    DBSelectArea("SC5")
    SC5->( DBSetOrder(1) )
    While SC5->( DBSeek( xFilial("SC5") + cPedido ) .Or. !MayIUseCode( cMay + cPedido ) )

          M410Proc(oProc,"No. do Pedido: "+cPedido)

          cPedido := Soma1( cPedido , Len( SC5->C5_NUM ) )
    EndDo

EndIf

//================================================================================
// GRAVAÇÃO DO NOME DO USUÁRIO NA INCLUSÃO
//================================================================================
If ParamIXB[1] == 3 .and. lRet .and. !_l108 .and. !_laoms074//Se inclusão e tudo ok

    PswOrder(1) // Busca por ID

    If PSWSEEK( __cUserID, .T. )
        aUser := PSWRET() // Retorna vetor com informações do usuário
    EndIf

    For Y := 1 to Len(aCols)

        If !aCols[y,len(aHeader)+1] //Se Linha Nao Deletada
            If len(auser) > 0
                aCols[y,nPosUser] := aUser[1,2] //Grava o Usuário no campo C6_I_USER
            Else
                aCols[y,nPosUser] := "Auto"
            Endif
        Endif

    Next y

Endif

//================================================================================
// Se filial Contem no Parametro IT_FILPV e Operação é 02, 	                      |
// o armazém deverá ser 21. Chamado 6498.                                        |
//================================================================================
If lRet .and. !_l108

    If cFilAnt $ GetMv("IT_FILPV") .and. M->C5_I_OPER == '02'

        nPosAmz  := aScan( aHeader , {|x| UPPER( Alltrim(x[2]) ) == "C6_LOCAL" } )
        nPosItem := aScan( aHeader , {|x| UPPER( Alltrim(x[2]) ) == "C6_ITEM" } )

        For x := 1 to Len(aCols)

            M410Proc(oProc,"Item "+aCols[x][nPosIte])

            If aCols[x,nPosAmz] <> '21'
                 If _lMsgEmTela .and. !_laoms074

                  U_MT_ITMSG('Pedido '+M->C5_NUM +  " No Item "+aCols[x,nPosItem]+", o Armazém "+aCols[x,nPosAmz]+" não pode ser utilizado se a Filial é "+cFilAnt+" e Tipo de Operação é '02 - Venda Funcionário'.",;
                                "Validação pedido funcionário",;
                              "Neste cenário, deverá ser utilizado Armazém '21'.",1)
                 Else

                  _cAOMS074Vld += 'Atencao! (MT410TOK) Ped.: '+M->C5_NUM +;
                                  " No Item "+aCols[x,nPosItem]+", o Armazém "+aCols[x,nPosAmz]+" não pode ser utilizado se a Filial é "+cFilAnt+" e Tipo de Operação é '02 - Venda Funcionário'." +;
                                  " Neste cenário, deverá ser utilizado Armazém '21'."
               EndIf

                lRet := .F.
                Exit

            Endif

           Next x

    Endif

Endif

//================================================================================
// Se for Cfop de venda para funcionário/produtor limita o pedido ao limite de
// crédito do cliente
//================================================================================
If (ParamIXB[1] == 3 .Or. ParamIXB[1] == 4) .and. !_l108 .and. !_laoms074//1-Excluir; 3-Incluir/Copiar; 4-Alterar;

    If lRet .AND. !_lAoms112

        M410Proc(oProc,"venda para funcionario/produtor")

        lRet := vldPedFun( aCols )

    Endif

Endif

//================================================================================
// Se é pedido manual verifica se usuário tem restrição filialxarmazém
//================================================================================
If alltrim(funname()) == "MATA410" .and. !_l108 .and. !_laoms074 .and. !_laoms112

    If lRet

        M410Proc(oProc,"se usuario tem restricao")

        lRet := vldFilArm ( aCols )

    Endif

Endif

//==============================================================================================
// Bloco de verificação de amarração com a programação de entrega e ajustes de exclusão
//==============================================================================================
If (ParamIXB[1] = 1 .OR. ParamIXB[1] = 5) .and. lRet .and. !_l108 .and. !_laoms074 .AND. M->C5_TIPO = "N" .And. !_lAoms112

    M410Proc(oProc,"amarracao com a programacao de entrega e ajustes de exclusao")

    lRet := u_veriprog()

Endif

//=======================================================================================================
// Verifica se a operação está sendo mudada para bonificação, se estiver bloqueia o pedido por
// bonificação
//=======================================================================================================
If lRet .and. SC5->C5_I_OPER != '10' .AND. M->C5_I_OPER == '10' .and. ParamIXB[1] == 4 .and. !_l108 .and. !_laoms074 .AND. M->C5_TIPO = "N" .And. !_lAoms112

        U_MT_ITMSG('Pedido '+M->C5_NUM + " Pedido sendo alterado para bonificação.",;
                    "Validação Bonificação",;
                    "Deverá passar por liberação antes de faturar.",2)

     M->C5_I_BLOQ	:= 'B'       //Armazena o status bloqueado em um pedido de venda do tipo bonificacao
     M->C5_I_MTBON	:= ' '       //Armazena a matricula do usuario que realizou a aprovacao de pedido de venda
     M->C5_I_DLIBE	:= StoD(' ') //Armazena a data da aprovacao de pedido de venda
     M->C5_I_HLIBE	:= ' ' 	     //Armazena a hora da aprovacao de pedido de venda
     M->C5_I_STAWF	:= 'N' 		 //Armazena se ja foi enviado o HTML para aprovacao a um aprovador
     M->C5_I_BLPRC  := ""
     M->C5_I_BLCRE  := ""

Endif

//================================
// Validação de execução do Mashup
//================================
If ParamIXB[1] == 3 .And. !l410Auto .and. !_l108 .and. !_laoms074 .AND. M->C5_TIPO = "N" .And. !_lAoms112
    If lRet
        If _lMashup

           M410Proc(oProc,"execucao do Mashup")

            DBSelectArea("ZZL")
            ZZL->( DBSetOrder(3) )
            If ZZL->( DBSeek( xFilial("ZZL") + _cUser ) )
                If ZZL->ZZL_LIBMAS == "S"
                    _lLibMas := .T.
                EndIf
            EndIf

            If !_lLibMas

                SA1->(dbSetOrder(1))
                SA1->(dbSeek(xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI))

                _nQtdDia	:= Val(SA1->A1_I_PEREX)
                _nQtdiaT	:= Iif(Empty(SA1->A1_I_DTEXE),0,dDataBase - SA1->A1_I_DTEXE)
                _lExec		:= Iif(_nQtdiaT > _nQtdDia, .T., .F.)

                If SA1->A1_PESSOA <> "F"
                    If ALLTRIM(SA1->A1_I_SITRF) <> "APTO" .And. ALLTRIM(SA1->A1_I_SITRF) <> "REGULAR" .And. ALLTRIM(SA1->A1_I_SITRF) <> "ATIVO" .And. ALLTRIM(SA1->A1_I_SITRF) <> "ATIVA" .Or. _lExec
                        _lRet := .F.
                        If _lExec
                            If AllTrim(SA1->A1_I_END) $ SA1->A1_END

                                  U_MT_ITMSG('É necessário realizar a consulta deste cadastro na Receita Federal devido a periodicidade de consulta. A consulta deve ser realizada no menu: Ações Relacionadas -> Mashups.' , "Validção Mashup",,1 )

                                lRet := .F.

                            EndIf
                        Else
                            If Empty(SA1->A1_I_SITRF)
                               If _lMsgEmTela
                                  U_MT_ITMSG('É necessário realizar a consulta deste cadastro na Receita Federal e se "Jurídico" no Sintegra também. A consulta pode ser realizada no menu: Ações Relacionadas -> Mashups.',"Validação Mashup",,1 )
                               Else

                                  _cAOMS074Vld += 'É necessário realizar a consulta deste cadastro na Receita Federal e se "Jurídico" no Sintegra também. A consulta pode ser realizada no menu: Ações Relacionadas -> Mashups.'

                               EndIf

                                lRet := .F.
                            Else
                               If _lMsgEmTela
                                  U_MT_ITMSG( 'Não é possível concluir o cadastro deste fornecedor, devido seu status na Receita Federal estar como [' + ALLTRIM(SA1->A1_I_SITRF) + '].',"Validação Mashup",,1 )
                               Else

                                  _cAOMS074Vld += 'Não é possível concluir o cadastro deste fornecedor, devido seu status na Receita Federal estar como [' + ALLTRIM(SA1->A1_I_SITRF) + '].'

                               EndIf
                                lRet := .F.
                            EndIf
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf
EndIf

//================================================================================
// Se um produto estiver contido no parâmetro IT_PRDNFRAC e se o armazem
// estiver no parâmetro IT_LOCNFRAC ou o tipo de oparação estiver no parâmetro
// IT_TPONFRAC, obrigatóriamente deverá validar as quantidades fracionadas.
//================================================================================
SB1->(dbSetOrder(1))
IF  !_laoms074 .And. lRet .and. !_l108 .AND. (!ParamIXB[1] = 5 .AND. !ParamIXB[1] = 1)//EXCLUIR DO MENU  OU  EXCLUSAO EXECAUTO

  _cProds:=""
  FOR nX := 1 TO Len(aCols)
   // Muda o valor de N
    N := nX
    M410Proc(oProc,"(2a) Quantidades fracionadas, Item "+aCols[nX][nPosIte])

    IF aCols[n][Len(aCols[n])]
       LOOP
    ENDIF

    If AllTrim(aCols[n,nPosProduto]) $ _cProdNFrac .And. (AllTrim(aCols[n,nPosLoc]) $ _cLocalNFrac .Or. M->C5_I_OPER $ _cTipOpNFrac)

        SB1->(dbSeek(xFilial("SB1") + AllTrim(aCols[n,nPosProduto])))
        If aCols[n,nPosQtd2] <> Int(aCols[n,nPosQtd2])
            _cTextCalc := " " + AllTrim(Transform(aCols[n,nPosQtd2],"@E 999,999,999.9999")) + " " + SB1->B1_SEGUM
            lRet := .F.
            _cProds+="Item: " + aCols[n,nPosIte]+" Produto: " + AllTrim(aCols[n,nPosProduto]) + " - " + LEFT(SB1->B1_DESC,45) + _cTextCalc + _ENTER
        EndIf

    Else
        //=====================================================================================
        //Validação de quantidade fracionada
        //=====================================================================================
        If cFilAnt $ _cFilOper
                If !(M->C5_I_OPER $ _cOperEst)
                    If !(AllTrim(aCols[n,nPosProduto]) $ _cProdPe) .and. 	 !aCols[n][Len(aCols[n])] 	//Se a linha nao estiver deletada
                        If !(AllTrim(aCols[n,nPosLoc]) $ _cLocval) .and. M->C5_I_NFSED != "S" //não valida para armazéns do IT_LOCFRA e para pedido Sedex

                           If SBZ->(FieldPos("BZ_I_PR3UM")) > 0
                              //=========================================
                              // Nova versão da validação.
                              //=========================================
                              //_cCrtl3Um := Posicione("SBZ",1, M->C5_FILIAL + aCols[n,nPosProduto] ,"BZ_I_PR3UM")
                              _cCrtl3Um := Posicione("SBZ",1, cFilant + aCols[n,nPosProduto] ,"BZ_I_PR3UM")

                              If _cCrtl3Um == "S"

                                 //If (AllTrim(aCols[n,nPosProduto]) $ _cPrd3Um)

                                 SB1->(dbSeek(xFilial("SB1") + AllTrim(aCols[n,nPosProduto])))
                                 If aCols[n,nPosqtd] / SB1->B1_I_QT3UM <> Int(aCols[n,nPosqtd] / SB1->B1_I_QT3UM)
                                    _cTextoUnd := " 3a.UM (terceira) "
                                    _cTextCalc := " " + AllTrim(Transform(aCols[n,nPosqtd] / SB1->B1_I_QT3UM,"@E 999,999,999.9999")) + " " + SB1->B1_I_3UM

                                    lRet := .F.
                                    _cProds+="Item: " + aCols[n,nPosIte]+" Produto: " + AllTrim(aCols[n,nPosProduto]) + " - " + LEFT(SB1->B1_DESC,45)+ _cTextCalc + _ENTER
                                 EndIf
                              Else
                                 dbSelectArea("SB1")
                                 dbSetOrder(1)
                                 dbSeek(xFilial("SB1") + AllTrim(aCols[n,nPosProduto]))
                                 If aCols[n,nPosQtd2] <> Int(aCols[n,nPosQtd2])
                                    _cTextCalc := " " + AllTrim(Transform(aCols[n,nPosQtd2],"@E 999,999,999.9999")) + " " + SB1->B1_SEGUM
                                     lRet := .F.
                                    _cProds+="Item: " + aCols[n,nPosIte]+" Produto: " + AllTrim(aCols[n,nPosProduto]) + " - " + LEFT(SB1->B1_DESC,45) + _cTextCalc + _ENTER
                                 EndIf
                              EndIf

                           Else
                              //============================================
                              // versão antiga da validação.
                              //============================================
                              If (AllTrim(aCols[n,nPosProduto]) $ _cPrd3Um)
                                 SB1->(dbSeek(xFilial("SB1") + AllTrim(aCols[n,nPosProduto])))
                                 If aCols[n,nPosqtd] / SB1->B1_I_QT3UM <> Int(aCols[n,nPosqtd] / SB1->B1_I_QT3UM)
                                    _cTextCalc := " " + AllTrim(Transform(aCols[n,nPosqtd] / SB1->B1_I_QT3UM,"@E 999,999,999.9999")) + " " + SB1->B1_I_3UM
                                    lRet := .F.
                                    _cProds+="Item: " + aCols[n,nPosIte]+" Produto: " + AllTrim(aCols[n,nPosProduto]) + " - " + LEFT(SB1->B1_DESC,45) + _cTextCalc + _ENTER
                                 EndIf
                              Else
                                 dbSelectArea("SB1")
                                 dbSetOrder(1)
                                 dbSeek(xFilial("SB1") + AllTrim(aCols[n,nPosProduto]))
                                 If aCols[n,nPosQtd2] <> Int(aCols[n,nPosQtd2])
                                    _cTextCalc := " " + AllTrim(Transform(aCols[n,nPosQtd2],"@E 999,999,999.9999")) + " " + SB1->B1_SEGUM
                                    lRet := .F.
                                    _cProds+="Item: " + aCols[n,nPosIte]+" Produto: " + AllTrim(aCols[n,nPosProduto]) + " - " + LEFT(SB1->B1_DESC,45) + _cTextCalc + _ENTER
                                 EndIf
                              EndIf
                           EndIf

                        Endif
                    EndIf
                Endif
        EndIf
    EndIf

  NEXT

  If !lRet
      U_MT_ITMSG("Existem produtos que não podem ser vendidos com quantidades fracionadas. Clique em mais detalhes",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
                    "Validação Fracionado","Favor informar apenas quantidades inteiras na" + _cTextoUnd + " de medida." ,1     ,       ,        ,         ,     ,     ,{|| U_ITMSGLOG(_cProds,"Validação Fracionado") },_cProds )

  ENDIF

ENDIF


//================================================================================
//Validação de campo de desconto
//================================================================================
If lRet .and. !_l108 .and. !_laoms074

    _nTotPV := 0
    for _ni := 1 to len(acols)

        If !GdDeleted(_ni)

            _nTotPV += acols[_ni][nPosVal]

        Endif

    Next

    If M->C5_DESCONT > _nTotPV .and. !_l108 .and. !_laoms074

        U_MT_ITMSG("Valor de desconto não pode ser maior que o valor total do pedido!",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,"Revise valor do desconto",1)
        lRet := .F.

    Endif

Endif



//=================================================================
// Valida a vinculação de notas fiscais SEDEX.
//=================================================================
If lRet .And. !_lAoms112 .AND. ParamIXB[1] <> 1 .AND. ParamIXB[1] <> 5 //EXCLUIR DO MENU  OU  EXCLUSAO EXECAUTO
   lRet := U_M410VLSDX("TUDOOK")
EndIf

END SEQUENCE

//================================================================================
//***********   TRATAMENTO DE OPERCAO TRIANGULAR  ********************************
//================================================================================
BEGIN SEQUENCE

_cOperTriangular:= ALLTRIM(U_ITGETMV( "IT_OPERTRI","05,42"))// Tipos de operações da operação triangular
_cOperFat       := LEFT(_cOperTriangular,2)
_cOperRemessa   := RIGHT(_cOperTriangular,2)
_nRecOrigem     := SC5->(RECNO())
If lRet .and. M->C5_TIPO = "N" .AND. (M->C5_I_OPER $ _cOperTriangular .OR. SC5->C5_I_OPER = _cOperFat)//Se antes da alteração era 05...

    If _laoms074//FWIsInCallStack("U_ALTERAP") .or. FWIsInCallStack("U_INCLUIC")

        nPsBru := M410LITotais()//Calcula os Totais

    ENDIF

   M410Proc(oProc,"TRATAMENTO DE OPERCAO TRIANGULAR")
/*
   IF !EMPTY(M->C5_I_PVREM) .AND. M->C5_I_OPER = _cOperFat//Verefica se o pedido de remessa do Pedido de Venda não tem carga
      SC9->( DbSetOrder(1) )
      IF SC9->( DBSeek( SC5->C5_FILIAL + M->C5_I_PVREM ) )
         DO While SC9->( !EOF() ) .AND. SC9->( C9_FILIAL + C9_PEDIDO ) == SC5->C5_FILIAL + M->C5_I_PVREM
            IF !EMPTY(SC9->C9_CARGA)
               U_MT_ITMSG("Pedido de Remessa "+ALLTRIM(M->C5_I_PVREM)+" desse Pedido já esta na carga: "+SC9->C9_CARGA,"Atencao!","Estorne a carga "+ALLTRIM(SC9->C9_CARGA)+" do Pedido de Remessa "+ALLTRIM(M->C5_I_PVREM)+" para dar manutenção nesse Pedido de Venda",1)
               lRet:=.F.
               BREAK
            ENDIF
            SC9->(DBSKIP())
         ENDDO
      ENDIF
   ENDIF*/
   //Coidgo de segurança
   IF !EMPTY(M->C5_I_PVFAT) .AND. M->C5_I_OPER = _cOperRemessa//Verefica se o Pedido de Venda do pedido de remessa não tem NOTA
      SF2->(DBORDERNICKNAME("IT_I_PEDID"))
      IF SF2->(DBSEEK(xFilial()+M->C5_I_PVFAT))
         U_MT_ITMSG("Pedido de Venda "+ALLTRIM(M->C5_I_PVFAT)+" desse Pedido já esta na NF: "+ALLTRIM(SF2->F2_DOC),"Atencao!",;
                  "Estorne a NF: "+ALLTRIM(SF2->F2_DOC)+" do Pedido de Venda "+ALLTRIM(M->C5_I_PVFAT)+" para dar manutenção nesse Pedido de Remessa",1)
         lRet:=.F.
         BREAK
      ENDIF
   ENDIF

   //     EXCLUIR DO MENU  OU  EXCLUSAO EXECAUTO      ALTERAR DO PV FAT
   //IF (ParamIXB[1] = 1 .OR. ParamIXB[1] = 5) .OR. (ParamIXB[1] = 4 .AND. SC5->C5_I_OPER = _cOperFat .AND. !M->C5_I_OPER = _cOperFat)//... e depois não é mais 05, exclui a remessa
   /*
   IF (ParamIXB[1] = 1 .OR. ParamIXB[1] = 5) .OR. (ParamIXB[1] = 4 .AND. SC5->C5_I_OPER = _cOperRemessa .AND. !M->C5_I_OPER = _cOperRemessa)//... e depois não é mais 42, exclui a faturamento


      lRet:=U_IT_OperTriangular(SC5->C5_NUM,.T.)//Exclui somente a remessa

      IF lRet .AND. (EMPTY(M->C5_I_PVREM) .OR. !SC5->(DBSEEK(xFilial()+M->C5_I_PVREM)))
         M->C5_I_OPTRI:=SPACE(LEN(SC5->C5_I_OPTRI))
         M->C5_I_PVREM:=SPACE(LEN(SC5->C5_I_PVREM))
         M->C5_I_PVFAT:=SPACE(LEN(SC5->C5_I_PVFAT))
         M->C5_I_CLIEN:=SPACE(LEN(SC5->C5_I_CLIEN))
         M->C5_I_LOJEN:=SPACE(LEN(SC5->C5_I_LOJEN))
      ELSE
         U_MT_ITMSG("Não foi possivel Excluir o Pedido de Remessa: "+M->C5_I_PVREM,"Atencao!","Tente novamente e verifique as mesangens de erro que ocorrerem.",1)
         lRet:=.F.
      ENDIF

      BREAK

   ENDIF
   */

   /*
   IF M->C5_I_TRCNF = "S"
      U_MT_ITMSG("Pedidos de operação triangular "+_cOperTriangular+", não podem ser troca nota","Atencao!","Altere para o pedido não ser troca nota ou o tipo da operação não ser "+_cOperTriangular,1)
      lRet:=.F.
      BREAK
   ENDIF
   */
   //IF M->C5_I_OPER = _cOperFat
   IF M->C5_I_OPER = _cOperRemessa
      //M->C5_I_OPTRI = "F"
      M->C5_I_OPTRI = "R"

      IF Empty(M->C5_I_CLIEN) .OR. Empty(M->C5_I_LOJEN)
         //U_MT_ITMSG("Cliente de remessa não preenchido para esse Pedido de Venda","Atencao!","Selecione um cliente de Remessa nesse Pedido de Venda para gerar o Pedido de Remessa",1)
         U_MT_ITMSG("Cliente de Faturamento não preenchido para esse Pedido de Venda","Atencao!","Selecione um cliente de Remessa nesse Pedido de Venda para gerar o Pedido de Remessa",1)
         lRet:=.F.
         BREAK
      ENDIF

      IF M->C5_I_CLIEN+M->C5_I_LOJEN == M->C5_CLIENTE+M->C5_LOJACLI
         U_MT_ITMSG("Cliente de remessa não pode ser igual ao cliente do Pedido de Venda","Atencao!","Selecione um cliente de Remessa diferente do cleinte do Pedido de Venda para gerar o Pedido de Remessa",1)
         lRet:=.F.
         BREAK
      ENDIF

   ENDIF

   SC5->(DBGOTO(_nRecOrigem)) //Volta o POSICIONAMENTO do pedido de origem SEMPRE
   IF ParamIXB[1] = 4//ALTERACAO
      SC5->(MSRLOCK(SC5->(RECNO())))  //Retrava por garantia
   ENDIF

Endif
//Se não for mais TRATAMENTO DE OPERACAO TRIANGULAR limpa tudo
IF lRet .AND. !M->C5_I_OPER $ _cOperTriangular
   M->C5_I_OPTRI:=SPACE(LEN(SC5->C5_I_OPTRI))
   M->C5_I_PVREM:=SPACE(LEN(SC5->C5_I_PVREM))
   M->C5_I_PVFAT:=SPACE(LEN(SC5->C5_I_PVFAT))
   M->C5_I_CLIEN:=SPACE(LEN(SC5->C5_I_CLIEN))
   M->C5_I_LOJEN:=SPACE(LEN(SC5->C5_I_LOJEN))
ENDIF

//================================================================================
//***********   TRATAMENTO DE OPERACAO TRIANGULAR  ********************************
//================================================================================

//================================================================================
//***********   Tratamento para PV vinculados  ***********************************
//================================================================================
If lRet .and. M->C5_TIPO = "N"  .and. !_laoms074 .AND. !FWIsInCallStack("U_AOMS032") .AND. !FWIsInCallStack("U_AOMS032EXE") .AND. (ParamIXB[1] = 3 .Or. ParamIXB[1] = 4 .OR. ParamIXB[1] = 1 .OR. ParamIXB[1] = 5) //EXCLUIR DO MENU  OU  EXCLUSAO EXECAUTO

   IF !EMPTY(M->C5_I_PEVIN) .AND. (ParamIXB[1] = 3 .Or. ParamIXB[1] = 4) // INCLUSAO OU ALTERACAO

      M410Proc(oProc,"PV vinculados")

      IF M->C5_NUM == M->C5_I_PEVIN
         U_MT_ITMSG("O numero do Pedido vinculado é igual ao numero do Pedido Atual.","PEDIDO VINCUALADO",;
                    "Selecione um Pedido diferente do atual",1)
         lRet:=.F.
         BREAK

      ENDIF

      IF _lValAltPVin .AND. ParamIXB[1] = 4 .AND. !EMPTY(SC5->C5_I_PEVIN) .AND. !(SC5->C5_I_PEVIN == M->C5_I_PEVIN)
         U_MT_ITMSG("O Pedido vinculado "+SC5->C5_I_PEVIN+" atual não pode ser alterado para o Pedido "+M->C5_I_PEVIN,"PEDIDO VINCUALADO",;
                    "Limpe o campo "+AVSX3("C5_I_PEVIN",5)+", grave o Pedido Atual e altere novamente para vincular o novo Pedido",1)
         lRet:=.F.
         BREAK

      ENDIF

      //SC5 Já esta na ordem e o recno já ta salvo
      IF !SC5->(DBSEEK(xFilial()+M->C5_I_PEVIN))
         U_MT_ITMSG("O Pedido vinculado "+M->C5_I_PEVIN+" não existe.","PEDIDO VINCUALADO",;
                    "Selecione um Pedido cadastrado",1)

         lRet:=.F.
         BREAK

      ELSEIF !EMPTY(SC5->C5_I_PEVIN) .AND. !(SC5->C5_I_PEVIN == M->C5_NUM)

         U_MT_ITMSG("O Pedido vinculado "+M->C5_I_PEVIN+" já esta vinculado com outro Pedido: "+SC5->C5_I_PEVIN,"PEDIDO VINCUALADO",;
                    "Selecione outro um Pedido",1)

         lRet:=.F.
         BREAK

      ELSE //ve se tem carga e nota

         SC9->( DbSetOrder(1) )
         IF SC9->( DBSeek( SC5->C5_FILIAL + M->C5_I_PEVIN ) )
            DO While SC9->( !EOF() ) .AND. SC9->( C9_FILIAL + C9_PEDIDO ) == SC5->C5_FILIAL + M->C5_I_PEVIN
               IF !EMPTY(SC9->C9_CARGA)
                  U_MT_ITMSG("Pedido Vinculado "+ALLTRIM(M->C5_I_PEVIN)+" já esta na carga: "+SC9->C9_CARGA,"Atencao!","Estorne a carga "+ALLTRIM(SC9->C9_CARGA)+" ou selecione outro pedido",1)
                  lRet:=.F.
                  BREAK
               ENDIF
               IF !EMPTY(SC9->C9_NFISCAL)
                  U_MT_ITMSG("Pedido Vinculado "+ALLTRIM(M->C5_I_PEVIN)+" já tem Nota: "+SC9->C9_NFISCAL,"Atencao!","Estorne a Nota "+ALLTRIM(SC9->C9_NFISCAL)+" ou selecione outro pedido",1)
                  lRet:=.F.
                  BREAK
               ENDIF
               SC9->(DBSKIP())
            ENDDO
         ENDIF

      ENDIF

   ELSEIF ParamIXB[1] = 1 .OR. ParamIXB[1] = 5 //EXCLUIR DO MENU  OU  EXCLUSAO EXECAUTO

      IF !EMPTY(SC5->C5_I_PEVIN)

         U_MT_ITMSG('Esse pedido possui outro pedido '+M->C5_I_PEVIN+" vinculado, não pode ser excluido.","PEDIDO VINCUALADO",;
                    "Entre na Alteração desse pedido para desvincular o pedido limpando o campo "+AVSX3("C5_I_PEVIN",5),1)

         lRet:=.F.
         BREAK

      ENDIF

   ENDIF

   SC5->(DBGOTO(_nRecOrigem)) //Volta o POSICIONAMENTO do pedido de origem SEMPRE
   IF ParamIXB[1] = 4//ALTERACAO
      SC5->(MSRLOCK(SC5->(RECNO()))) //Retrava por garantia
   ENDIF

ENDIF//***********   Tratamento para PV vinculados  ***********************************

//============================================================================================================
// Validação de consistência de condição de pagamento  
//============================================================================================================
IF lRet .And. M->C5_TIPO = "N" .AND.  (ParamIXB[1] == 3 .OR. ParamIXB[1] == 4) //3-Incluir/Copiar; 4-Alterar;
   //============================================
   // Manter a validação abaixo para: 
   // - Demembramento
   // - Operação Triangular faturamento (05)
   // - Transferência
   //============================================
   If M->C5_I_OPER $ _cOperFat .Or. FWIsInCallStack("U_AOMS098") .Or.  FWIsInCallStack("U_AOMS032EXE") // Operação Triangular 05  ou Desmembramento ou Transferência

      _ccondr := M->C5_CONDPAG

      If lRet //.And. Empty(Alltrim(SC5->C5_CONDPAG))
         _ccondr := U_IT_conpv(@lRet) //carrega condição de pagamento personalizada do pedido aberto
      EndIf

      If lRet .And. _ccondr <> SA1->A1_COND   // Somente aceitar quando for Diferente do Cliente, caso usr tenha alterado na inclusão
         M->C5_CONDPAG := _ccondr
      EndIf
   Else 
      //======================================================================
      // Valida condições de pagamento para clientes com condições especiais.
      //======================================================================
      _lOK:=.T.
      _ccondr := U_IT_conpv(@_lOK) //carrega condição de pagamento personalizada do pedido aberto

      If !Empty(_ccondr) .And. Empty(M->C5_CONDPAG)
         M->C5_CONDPAG := _ccondr
      ElseIf ! Empty(_ccondr) .And. M->C5_CONDPAG <> _ccondr 
         IF _lOK//SE NÃO deu mensagem dentro da função U_IT_conpv() dá aqui
            U_MT_ITMSG("Cliente com condição de pagamento específica: ("+_ccondr+"). ","Atencao!","A condição de pagamento ("+M->C5_CONDPAG+") informada no pedido de vendas não é permitida para esse Cliente.",1)
         EndIf
         lRet:=.F.
         Break
      ElseIf Empty(M->C5_CONDPAG)
         U_MT_ITMSG("A condição de pagamento não foi informada.","Atencao!",,1)
         lRet:=.F.
         Break
      EndIf
   EndIf  
EndIf

If lRet .AND. (ParamIXB[1] == 3 .OR. ParamIXB[1] == 4); //1-Excluir; 3-Incluir/Copiar; 4-Alterar;
        .AND. M->C5_TIPO = "N" .AND. M->C5_I_OPER $ u_itgetmv("IT_TPOPER","01,42,08,12,15,24,25,26")
   //=====================================================================
   // Regras de validação de prazo médio com base no cadastro de cliente.
   //=====================================================================
   _cCondCli  := Posicione("SA1",1,xfilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI ,"A1_COND")
   _nPrazoMCl := Posicione("SE4",1,xfilial("SE4") + _cCondCli ,"E4_I_PRZMD") // 1=E4_FILIAL+E4_CODIGO
   _cDCondCli := ALLTRIM(SE4->E4_DESCRI)
   //----------------------//
   _nPrazoPV  := Posicione("SE4",1,xfilial("SE4") + M->C5_CONDPAG ,"E4_I_PRZMD") // 1=E4_FILIAL+E4_CODIGO
   _cDCondPV  := ALLTRIM(SE4->E4_DESCRI)

   If _nPrazoPV > _nPrazoMCl
      U_MT_ITMSG("O prazo médio do pedido "+ALLTRIM(STR(_nPrazoPV))+" é maior que o prazo médio do cliente: "+ALLTRIM(STR(_nPrazoMCl))+_ENTER+;
                 "Cond. Cliente: "+_cCondCli+"-"+_cDCondCli+_ENTER+"Cond. Pedido: "+M->C5_CONDPAG+"-"+_cDCondPV,;
                 "Validação Condição de Pagamento.","Por favor entrar em contato com o departamento comercial."+_ENTER+;
                 "Filial + Pedido: "+M->C5_FILIAL+" "+M->C5_NUM+_ENTER+;
                 "Operação:  "+M->C5_I_OPER,2)
      lRet := .F.
      BREAK
   EndIf


EndIf

//============================================================================================================
//Validação para não permitir fracionamento para PAs onde a 1a UM for UN (represente 1 inteiro)
//============================================================================================================
If lRet .And. (ParamIXB[1] = 3 .OR. ParamIXB[1] = 4)
   M410Proc(oProc,"Verificando quantidade fracionadas...")
   lRet:=MT410_UN(oProc)
Endif

//================================================================================
// Valida se o cliente aceita troca nota ou não.
//================================================================================
If lRet .And. (ParamIXB[1] == 3 .Or. ParamIXB[1] == 4) //1-Excluir; 3-Incluir/Copiar; 4-Alterar;
   SA1->(dbSetOrder(1))
   SA1->(MSSeek(xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI))
   If M->C5_I_TRCNF == "S" .And. SA1->A1_I_TRCNF == "N"
      U_MT_ITMSG("O cliente "+M->C5_CLIENTE+" "+M->C5_LOJACLI+" - "+ALLTRIM(SA1->A1_NOME) + " deste pedido " + M->C5_NUM + " de vendas não aceita troca de NF.","Atencao!",,1)
      lRet:=.F.
      BREAK
   EndIf
EndIf

//================================================================================
// VALIDACAO DE PRODUTOS BLOQUEADOS POR FILIAL
//================================================================================
_cProds:=""
//NÃO VALIDAR:
//Quando Transferir o Pedido (U_AOMS032EXE)
//Quando Desmembrar o Pedido (U_AOMS098)
//Quando Receber dados WS do RDC (U_AOMS074)
If lRet .And. ( _lItemNovo .Or. Inclui ) .AND. !(FWIsInCallStack("U_AOMS098"))    .AND.;
                        M->C5_TIPO = "N" .AND. !(FWIsInCallStack("U_AOMS074"))    .AND.;
                                               !(FWIsInCallStack("U_AOMS032EXE")) .AND.;
                   M->C5_I_OPER $ u_itgetmv("IT_TPOPER","01,42,08,12,15,24,25,26")

    //Valida existência de produtos na tabela de preços selecionada
   SC6->(Dbsetorder(1))
    For _nnipre := 1 to len(acols)
        If aCols[_nnipre,len(aHeader)+1] // Se Linha Excluida
           Loop
        EndIf
        //Ignora os itens que já existia
           If _lItemNovo .AND. SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM+aCols[_nnipre][nPosIte]))
           Loop
        ENDIF

        _cBloqSBZ:=Posicione("SBZ",1,xFilial("SBZ")+acols[_nnipre][nPosProduto],"BZ_I_BLQPR")
        If _cBloqSBZ == "S"
           _cDescr:=Posicione("SB1",1,xFilial("SB1")+acols[_nnipre][nPosProduto],"B1_DESC")
           AADD(_aProdBlq,({acols[_nnipre][nPosIte],acols[_nnipre][nPosProduto],_cDescr}))
           _cProds+="Item: " + aCols[_nnipre,nPosIte]+" Produto: " + AllTrim(aCols[_nnipre,nPosProduto]) + "-" + _cDescr + _ENTER
           lRet := .F.
        EndIf
    Next

    If !lRet

        U_MT_ITMSG("Há produtos neste pedido constam como bloqueados para esta filial. Clique em mais detalhes",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
                    "Validação de Produtos Bloqueados","Favor informar apenas produtos desbloqueados."         ,1     ,       ,        ,         ,     ,     ,;
                    {|| U_ITListBox( 'Itens do Pedido com Bloqueio de Produto para Filial' , {"Item do Pedido","Codigo","Descricao do Produto"} , _aProdBlq , .F. , 1 ) },_cProds )
      BREAK
    Endif
Endif

//======================================================================================
// Validações para geração de Pedido de Pallets de devolução, para os armazéns 40 e 42
// para pedidos de vendas sem geração de carga.
//======================================================================================
If lRet .And. (ParamIXB[1] == 3 .Or. ParamIXB[1] == 4)
   //======================================================================================
   If M->C5_I_GPADV == "S"
   //======================================================================================
      If Empty(M->C5_I_TRAPA) .Or. Empty(M->C5_I_LTRAP)
         U_MT_ITMSG("Este pedido de vendas está configurado para gerar pedidos de pallets de devolução. O preenchimento dos campos código e loja da transportadora do pedido de pallets de devolução são obrigatórios.",;
                    "Atenção",;
                    "Preencha os campos códio e loja da transportadora do pedido de pallets de devolução.",1)
         lRet:= .F.
      EndIf

      If lRet
         SA1->(DbSetOrder(1))
         If ! SA1->(MsSeek(xFilial("SA1")+M->C5_I_TRAPA+M->C5_I_LTRAP))
            U_MT_ITMSG("O código e a loja da transportadora do pedido de pallets de devolução não existe.",;
                    "Atenção",;
                    "Informe um código e loja da transportadora do pedido de pallets de devolução que exista.",1)
            lRet:= .F.
         EndIf
      EndIf

      If lRet
         SA1->(DbSetOrder(1))
         If SA1->(MsSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
            If M->C5_I_GPADV == "S"
               If SA1->A1_I_CHEP <> "C"
                  U_MT_ITMSG("Este pedido de vendas está configurado para gerar pedido de pallets de devolução, mas o cliente não é do tipo Pallet Chep.",;
                  "Atenção",;
                  "Informe um cliente do tipo pallet chep.",1)
                  lRet:= .F.
               EndIf

               If lRet .And. Empty(SA1->A1_I_CCHEP)
                  U_MT_ITMSG("Este pedido de vendas está configurado para gerar pedido de pallets de devolução, mas o campo código chep do cadastro do cliente não está preenchido.",;
                  "Atenção",;
                  "Informe um cliente com o campo código Chep preenchido.",1)
                  lRet:= .F.
               EndIf
            EndIf
         EndIf
      EndIf

      //=================================================================
      // Verifica se há itens nos amrmazéns 40 e 42.
      //=================================================================
      // _nPosQPale      := aScan( aHeader , { |x| AllTrim(x[2]) == "C6_I_QPALT" } )
      _lTemLocPCh := .F.
      _lTemQtdPal := .F.
      For x := 1 to len(aCols)
          If acols[x][nPosLoc] $ _cLocalPCh
             _lTemLocPCh := .T.
          EndIf

          If acols[x][nPosLoc] $ _cLocalPCh .And. acols[x][_nPosQPale] > 0
             _lTemQtdPal := .T.
          EndIf
      Next

      If ! _lTemLocPCh
         U_MT_ITMSG("Este pedido de Vendas está com a opção gerar pedido de pallet igual a Sim, mas não existe nenhum item nos armazéns: " + AllTrim(_cLocalPCh) + ".",;
                    "Atenção",;
                    "Para gerar pedido de Pallets, é preciso ter itens nos armazéns: " + AllTrim(_cLocalPCh) + ".",1)
         lRet := .F.
      EndIf

      If ! _lTemQtdPal
         U_MT_ITMSG("Este pedido de Vendas está com a opção gerar pedido de pallet igual a Sim, mas não existe quantidade de palltes informado.",;
                    "Atenção",;
                    "Para gerar pedido de Pallets, é preciso informar a quantidade de pallets.",1)
         lRet := .F.
      EndIf

   EndIf //If M->C5_I_GPADV == "S"
EndIf

If lRet .And. !_lAoms112 .And. !_l108 .And. !_laoms074 .AND. M->C5_I_OPER $ "15|20|21|22|42"
	
   _aSM0 := FWLoadSM0()

   SA1->(DbSetOrder(1))
	SA1->(MsSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
   _nPos := aScan(_aSM0,{|x| x[18] = Alltrim(SA1->A1_CGC) })

   Do Case
		Case M->C5_I_OPER = "20" 
         If _nPos > 0 
            _nPosFilAnt := aScan(_aSM0,{|x| x[2] = Alltrim(FwCodFil()) })
            If _nPosFilAnt > 0  .AND. _aSM0[_nPos,18] == _aSM0[_nPosFilAnt,18]
               lRet := .F.
               U_MT_ITMSG("Para operação 20 não é permitido clientes que correspondam a filial logada.",;
                     "Atenção",;
                     "Selecione outro Cliente que corresponda a uma Filiais cadastradas.",1)
				EndIf
         Else
            lRet := .F.
            U_MT_ITMSG("Para operação 20 só é permitido clientes que correspondam a uma das filiais cadastradas.",;
                     "Atenção",;
                     "Selecione outro Cliente que corresponda a uma Filiais cadastradas.",1)
         EndIf
      Case M->C5_I_OPER = "21" .AND. _nPos = 0
         lRet := .F.
         U_MT_ITMSG("Para operação 21 só é permitido clientes que correspondam a uma das filiais cadastradas.",;
                  "Atenção",;
                  "Selecione o Cliente que corresponda a uma Filial cadastrada.",1)
		
      Case M->C5_I_OPER = "22" .AND. _nPos > 0
         _nPosFilAnt := aScan(_aSM0,{|x| x[2] = Alltrim(FwCodFil()) })
         If _nPosFilAnt > 0  .AND. _aSM0[_nPos,18] <> _aSM0[_nPosFilAnt,18]
            lRet := .F.
            U_MT_ITMSG("Para operação 22 só é permitido clientes que corresnponda a filial de inclusão do Pedido.",;
                  "Atenção",;
                  "Selecione o Cliente que corresponda a Filial logada.",1)
         EndIf
			
      Case M->C5_I_OPER = "15" .AND. !(SA1->A1_TIPO == "F" .AND. M->C5_TIPOCLI=="F" .AND. (Alltrim(UPPER(SA1->A1_INSCR)) == "ISENTO" .OR. Empty(SA1->A1_INSCR)))
         lRet := .F.
         U_MT_ITMSG("Para operação 15 só é permitido clientes do Tipo Consumidor Final com Inscrição Estatual preenchida como ISENTO ou não preenchida.",;
                  "Atenção",;
                  "Selecione outro Cliente ou troque a operação.",1)

      Case M->C5_I_OPER = "42" .AND. _nPos > 0 
         lRet := .F.
         U_MT_ITMSG("Para operação 42 só é permitido clientes que não correspondam a uma das filiais cadastradas.",;
                  "Atenção",;
                  "Selecione o Cliente que não corresponda a uma Filial cadastrada.",1)

   EndCase
EndIf

//======================================================================================
///Estamos deixando esse trecho comentado no fonte,
// para tratativa futura conforme alinhado com a usuária referente ao chamado 34804
//If lRet .And. (ParamIXB[1] = 3 .Or. ParamIXB[1] = 4) .AND. M->C5_TIPO = "B" //.AND. !FWIsInCallStack("MSEXECAUTO")
//    M410Proc(oProc,"Validando Pedidos tipo B - utiliza fornecedor")
//	//=================================================================================================================================================
//	// Validação do C5_TIPO - B para não permitir gravar o pedido caso o campo C5_I_OPER estiver preenchido e obrigar o preenchimento do campo C6_OPER
//	//=================================================================================================================================================
//	If !EMPTY(M->C5_I_OPER)
//        U_MT_ITMSG('Pedido '+M->C5_NUM +' não pode ter o campo "Tp. Operacao" no cabeçalho preenchido.',"Validação da operação",'Para pedidos de venda do tipo "B-Utiliza fornecedor", não preencher o campo "Tp. Operacao" no cabeçalho do pedido.',1)
//		lRet := .F.
//        BREAK
//	EndIf
//	//_cItens:=""
//	For x := 1 to len(aCols)
//		M->C6_OPER:= acols[x][_nPosC6OPER]
//		//M->C6_ITEM:= acols[x][nPosIte]
//		IF EMPTY(M->C6_OPER)
//		   //_cItens+=ALLTRIM(M->C6_ITEM)+"/"
//		   lRet := .F.
//		   EXIT
//		EndIf
//	Next
//	IF !lRet
//	   //_cItens:=LEFT(_cItens,LEN(_cItens)-1)
//       U_MT_ITMSG('Pedido '+M->C5_NUM +' não pode ter o campo "Tp. operação" nas linhas dos produtos não preenchido.',"Validação da operação",'Para pedidos de venda do tipo "B-Utiliza fornecedor", é obrigatório o preenchimento do campo "Tp. operação" nas linhas dos produtos',1)
//	   lRet := .F.
//       BREAK
//	ENDIF
//EndIf

//==========================================================================================================================================================
//==========================================================================================================================================================
//============================================================================================================================================================
// NOVAS VALIDAÇOES SEM GRAVAÇÃO NA BASE E SEM TELA "COLOQUE AQUI" ACIMA, ANTES DO END SEQUENCE
//============================================================================================================================================================
//==========================================================================================================================================================
//==========================================================================================================================================================

//============================================================================================================
//ESSAS VALIDAÇÕES ABAIXO TEM TELAS DEIXE ELAS SEMPRE POR ULTIMO
//============================================================================================================
//Não chama em desmembramento que não é considerado corte
//Não chama no corte da tela de central de pvs que tem a própria chamada de motivo
//============================================================================================================
PRIVATE _cJustAG := " "// preenchido na função MT410_JA()
PRIVATE _cJustDE := " "// preenchido na função MT410_JA()
PRIVATE _cObseAG := " "// preenchido na função MT410_JA()
PRIVATE _cObseDE := " "// preenchido na função MT410_JA()
PRIVATE _lGrvMon := .F.// preenchido no retorno da função MT410_JA() //GRAVA O MONITOR DEPOIS DE TODAS AS VALIDAÇÕES
If lRet .AND. !_laoms074 .and. ParamIXB[1] = 4 .AND. M->C5_TIPO = "N" .AND. !FWIsInCallStack("U_AOMS099") .AND.;
                                                                            !FWIsInCallStack("U_AOMS109") .AND.;
                                                                            !FWIsInCallStack("U_MOMS047") .AND.;
                                                                            !FWIsInCallStack("U_MOMS066") .AND.;
                                                                            !FWIsInCallStack("U_AOMS108") .AND.;
                                                                            !FWIsInCallStack("U_ITMA521CORRI") .AND.;
                                                                            !FWIsInCallStack("U_OM521BRW")
   M410Proc(oProc,"Verificando alteraçoes com justificativas...")
   PRIVATE _lAltData:=SC5->C5_I_DTENT <> M->C5_I_DTENT .AND. M->C5_I_AGEND <> "I"//não é necessário justificar a alteração da data de entrega do pedido quando o pedido for Tp Entrega imediato (M->C5_I_AGEND = I)
   PRIVATE _lAltAgen:=SC5->C5_I_AGEND <> M->C5_I_AGEND
   _lPrecisaPedir:=!(ALLTRIM(M->C5_I_OPER) $ AllTrim(U_ITGETMV( 'IT_MPVOP' , '50/51/02')))
   IF _lPrecisaPedir .AND. _lAltData .OR. _lAltAgen//Se é alteração valida com tela, vê se alterou a data de entrega ou o tipo de agendamento e pergunta o codigo e a obeservaçao da justificativa,  TEM TELA
      lRet:=_lGrvMon:=MT410_JA()//PARA GRAVA NO ZY3 NA FUNÇÃO GrvMonitor() (XFUNOMS.PRW)
   ENDIF
   IF lRet//Se é alteração valida com tela, vê se é corte e pergunta motivo de corte TEM TELA
      M410Proc(oProc,"Verificando corte...")
      lRet:=MT410_CT()//PARA GRAVA NO Z07 NA FUNÇÃO ITGrvLog() (ITALCXFUN.PRW)
   ENDIF
Endif
//============================================================================================================
//Se é alteração validada com tela vê se é corte e pergunta motivo de corte TEM TELA
//============================================================================================================

//============================================================================================================
//============================================================================================================
//============================================================================================================
END SEQUENCE // END SEQUENCE //END SEQUENCE //END SEQUENCE //END SEQUENCE
//============================================================================================================
//============================================================================================================
//============================================================================================================

//SF2->( DbSetOrder(1) )
SC5->(DBGOTO(_nRecOrigem))//Volta o POSICIONAMENTO do pedido de origem
IF !lRet .AND. ParamIXB[1] = 4//ALTERACAO  CASO devolva .F.
   SC5->(MSRLOCK(SC5->(RECNO())))  //Retrava por garantia
ENDIF

//============================================================================================================
// TRATAMENTO PARA  EXCLUI O PEDIDO DE PALLET
//============================================================================================================
If lRet .And. ParamIXB[1] == 4 .AND. M->C5_I_GPADV == "S"
   If !Empty(M->C5_I_NPALE)
      lRet := MT410EXCPA(M->C5_I_NPALE)
      If !lRet
         U_MT_ITMSG("Não foi possível excluir o pedido de Pallet: " + M->C5_I_NPALE,;
                 "Atenção",;
                 "O pedido de pallet precisa ser excluido manualmente.",1)
      Else
         M->C5_I_NPALE := ""
      EndIf
   EndIf
EndIf
//============================================================================================================
// TRATAMENTO PARA  EXCLUI O PEDIDO DE PALLET
//============================================================================================================

//==============================================================================================================================
//***********   Tratamento para PV vinculados - RDC     OPCAO DE TRANSFERENCIA           INCLUSAO         OU  ALTERACAO
//==============================================================================================================================
If lRet .and. M->C5_TIPO = "N" .and. !_laoms074  .AND. !FWIsInCallStack("U_AOMS032") .AND. !FWIsInCallStack("U_AOMS032EXE") .AND. (ParamIXB[1] = 3 .OR. ParamIXB[1] = 4)

    M410Proc(oProc,"PV vinculados")
   _lDiferente:=.F.
   _lAchou:=.F.

   IF !EMPTY(M->C5_I_PEVIN) .AND. ( ParamIXB[1] = 3 .OR. EMPTY(SC5->C5_I_PEVIN) )
      _lAchou:=SC5->(DBSEEK(xFilial()+M->C5_I_PEVIN))//Posiciona no Novo
   ELSEIF ParamIXB[1] # 3 .AND. !EMPTY(SC5->C5_I_PEVIN)
      IF !EMPTY(M->C5_I_PEVIN) .AND. !(SC5->C5_I_PEVIN = M->C5_I_PEVIN) // Tratamento para caso a variavel _lValAltPVin  = .F.
         _lDiferente:=.T.//Trocou o PV vinculado
      ENDIF
      _lAchou:=SC5->(DBSEEK(xFilial()+SC5->C5_I_PEVIN))//Posiciona no Antigo se _lDiferente = .T.
   ENDIF

   //================================================================================
   // Realiza a solicitação de retorno do pedido de vendas que foi vinculado para
   // o sistema RDC, caso este já tenha sido integrado.
   //================================================================================
   If _lAchou
      If ! MT410TOKC(@_lEstornoRDc)
         lRet := .F.
      EndIf

      _nRegVinc := SC5->(Recno())
   EndIf

   //================================================================================
   // NESSA FUNCAO MTPV_VIN TEM GRAVAÇÃO DE DADOS
   //================================================================================
   If lRet
      IF MTPV_VIN(_lAchou,_lDiferente)//Posiciona no Antigo se diferente e limpa OU no novo se não é diferente para atualizar
         IF _lDiferente// Tratamento para caso a variavel _lValAltPVin  = .F.
            _lAchou:=SC5->(DBSEEK(xFilial()+M->C5_I_PEVIN))//Posiciona no Novo
            IF !MTPV_VIN(_lAchou) // NESSA FUNCAO TEM GRAVAÇÃO DE DADOS
               lRet:=.F.
            ENDIF
         ENDIF
      ELSE
         lRet:=.F.
      ENDIF
   EndIf

   SC5->(DBGOTO(_nRecOrigem))//Volta o POSICIONAMENTO do pedido de origem SEMPRE
   IF ParamIXB[1] = 4//ALTERACAO
      SC5->(MSRLOCK(SC5->(RECNO())))  //Retrava por garantia
   ENDIF

ENDIF
//============================================================================================================
//***********   Tratamento para PV vinculados  ***********************************
//============================================================================================================

//==========================================================================================================================================================
//==========================================================================================================================================================
//==========================================================================================================================================================
// NÃO INCLUIR NENHUMA ALTERAÇÃO DA VARIÁVEL DE VALIDAÇÃO (lRet) para .F.
// APÓS ESSE TRECHO, POIS SÓ PODE SER EXECUTADO SE O RETORNO DA FUNÇÃO FOR TRUE
// NOVAS VALIDAÇOES SEM GRAVAÇÃO NA BASE PROCURE POR "COLOQUE AQUI" E INSIRA AS VALIDACOES LÁ POR FAVOR, NÃO COLOQUE NADA AQUI
//==========================================================================================================================================================
//==========================================================================================================================================================
//==========================================================================================================================================================

//Se for exclusão validada faz a exclusão do ZFQ E ZFR
If lRet .and. (ParamIXB[1] = 1 .OR. ParamIXB[1] = 5)

    ZFQ->(Dbsetorder(3))
    If ZFQ->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))

        Do while ZFQ->ZFQ_FILIAL == SC5->C5_FILIAL .AND. ZFQ->ZFQ_PEDIDO == SC5->C5_NUM

            If ZFQ->ZFQ_SITUAC == 'N'

                ZFQ->(RecLock("ZFQ",.F.))
                ZFQ->ZFQ_SITUAC  := "P"
                ZFQ->ZFQ_DATAAL  := Date()
                ZFQ->ZFQ_RETORN  := "Eliminado por exclusão do pedido no SC5"
                ZFQ->(MsUnlock())
                ZFQ->(Dbgotop())
                ZFQ->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))

            Else

                ZFQ->(Dbskip())

            Endif

        Enddo

    Endif

Endif

//====================================================================================================================================
//====================================================================================================================================
//====================================================================================================================================
// NOVAS VALIDAÇOES SEM GRAVAÇÃO NA BASE PROCURE POR "COLOQUE AQUI" E INSIRA AS VALIDACOES LÁ POR FAVOR, ANTES DO END SEQUENCE
//====================================================================================================================================
//====================================================================================================================================
//====================================================================================================================================

M410Proc(oProc," e Executando gravacoes finais")

//================================================================================
// Se estiver validado e existir programação de entrega faz atualização
// da data de entrega
//================================================================================
Dbselectarea("ZF8")
ZF8->( Dbsetorder(2) )

If  lRet .and. ZF8->( Dbseek( SC5->C5_FILIAL + M->C5_NUM ) )

    ZF8->( Reclock( "ZF8", .F. ) )

    ZF8->ZF8_DTENTR := M->C5_I_DTENT

    ZF8->( MsUnlock() )

Endif

//================================================================================
// Se estiver validado e for alteração de data de entrega inclui monitoria de
// pedido de vendas
//================================================================================
//ALTERACAO OU EXCLUIR DO MENU OU  EXCLUSAO EXECAUTO
If lRet .and. M->C5_TIPO = "N" .and. (ParamIXB[1] = 1 .OR. ParamIXB[1] = 5) .and. ;//EXCLUIR DO MENU  OU  EXCLUSAO EXECAUTO // ((ParamIXB[1] = 4 .and. M->C5_I_DTENT <> SC5->C5_I_DTENT) .OR.
             !(ALLTRIM(M->C5_I_OPER) $ AllTrim(U_ITGETMV( 'IT_MPVOP' , '50/51/02')))
    IF !FWIsInCallStack("U_AOMS032") .And. !FWIsInCallStack("U_AOMS032EXE")
           //IF ParamIXB[1] = 4 .And. ARO TINA[1][1] <> "Excluir"
          //	_cJUSCOD := "007"//Alterado Data de Entrega
          //	_cCOMENT := "Data de entrega modificada de " + dtoc(SC5->C5_I_DTENT) + " para " + dtoc(M->C5_I_DTENT) + "  via alteração de pedido de vendas."
          //	_cENCERR := ""
        //EndIf
           If ParamIXB[1] = 1 .OR. ParamIXB[1] = 5//EXCLUIR DO MENU  OU  EXCLUSAO EXECAUTO
           _dDTNECE := M->C5_I_DTENT
             _cJUSCOD := "010"//PEDIDO EXCLUÍDO
             _cCOMENT := "Monitor encerrado por exclusão do pedido de vendas"
             _cENCERR := "S"
              U_GrvMonitor(,,_cJUSCOD,_cCOMENT,_cENCERR,_dDTNECE,M->C5_I_DTENT,SC5->C5_I_DTENT)
        ENDIF
    EndIf
EndIf

//GRAVA POR JÁ PASSOU POR TODAS AS VALIDAÇÕES
IF lRet
   IF ParamIXB[1] = 3 .AND. (M->C5_I_AGEND = "A" .OR. M->C5_I_AGEND = "M")
      M->C5_I_QTDA:=1
   ELSEIF ParamIXB[1] = 4 .AND. _lGrvMon .AND. _lContOk
      M->C5_I_QTDA:=M->C5_I_QTDA+1
   ENDIF
ENDIF
IF lRet .and. _lGrvMon//GRAVA O MONITOR AQUI POR JÁ PASSOU POR TODAS AS VALIDAÇÕES
   //_cJustAG / _cJustDE / _cObseAG / _cObseDE  preenchidoS na função MT410_JA()
   IF _lAltData
      _cCOMENT := "Data de entrega modificada de " + dtoc(SC5->C5_I_DTENT) + " para " + dtoc(M->C5_I_DTENT) + " via alteração de pedido de vendas."
                 //_cFilial,_cNum,_cJUSCOD,_cCOMENT,_cLENCMON,_dDTNECE     ,_dDTFAT      ,_dDTFOLD       , _cObserv, _cVinculoTb, _dDtSugAgen
       U_GrvMonitor(        ,     ,_cJustDE,_cCOMENT,""       ,M->C5_I_DTENT,M->C5_I_DTENT,SC5->C5_I_DTENT,_cObseDE)
   ENDIF
   IF _lAltAgen
      _cCOMENT := "Tipo de Agendamento modificada de " + SC5->C5_I_AGEND + " para " + M->C5_I_AGEND + " via alteração de pedido de vendas."
                 //_cFilial,_cNum,_cJUSCOD,_cCOMENT,_cLENCMON,_dDTNECE     ,_dDTFAT      ,_dDTFOLD       , _cObserv, _cVinculoTb, _dDtSugAgen
      U_GrvMonitor(        ,     ,_cJustAG,_cCOMENT,""       ,M->C5_I_DTENT,M->C5_I_DTENT,SC5->C5_I_DTENT,_cObseAG)
   ENDIF
ENDIF

//=====================================================================================
// Enviar pedido de vendas vinculado para o sistema RDC, caso não tenha sido enviado.
//=====================================================================================
//**    INTEGRAÇÃO WEBSERVICE       OPCAO DE TRANSFERENCIA             INCLUSAO    OU  ALTERACAO
If lRet .and. M->C5_TIPO = "N" .And. !_laoms074 .And. !FWIsInCallStack("U_AOMS032") .And. !FWIsInCallStack("U_AOMS032EXE")  .And. (ParamIXB[1] = 3 .Or. ParamIXB[1] = 4) .And. !Empty(M->C5_I_PEVIN)
   _nRegSC5 := SC5->(Recno()) // Salva a posição atual do SC5.
   _aOrd := SaveOrd({"SC5"})  // Salva a ordem dos indices.
   _cFilSC5 := SC5->C5_FILIAL

   SC5->(DbSetOrder(1))       // C5_FILIAL+C5_NUM
   If SC5->(DbSeek(_cFilSC5+M->C5_I_PEVIN))  // Posiciona no Pedido de Vendas Vinculado.
      U_RETPVRDC() // Grava na tabela de muro o pedido de vendas vinculado para envio ao sistema RDC.
   EndIf

   SC5->(DbGoTo(_nRegSC5)) // Volta o SC5 para a posição original.
   RestOrd(_aOrd)          // Volta os indices para a posição original.
EndIf

RestArea(_aArea)

IF ParamIXB[1] = 3
   M->C5_I_DIASV:=0
   M->C5_I_DIASV:=0
ENDIF

//Grava campo de data de necessidade de faturamento
If lRet .And. M->C5_TIPO = "N" //.And. !FWIsInCallStack("U_AOMS032") .And. !FWIsInCallStack("U_AOMS032EXE") // Tem que recalcula C5_I_DTNEC na transferencia sim 23/10/24

   _cFilCarreg := xFilial("SC5")
   If ! Empty(M->C5_I_FLFNC)
      _cFilCarreg := M->C5_I_FLFNC
   EndIf
   _lAchouZG5:=.F.
   _cRegra:=""
   M->C5_I_DTNEC := M->C5_I_DTENT - (U_OMSVLDENT(M->C5_I_DTENT,M->C5_CLIENTE,M->C5_LOJACLI,M->C5_I_FILFT,M->C5_NUM,1,  ,_cFilCarreg,M->C5_I_OPER,M->C5_I_TPVEN,@_lAchouZG5,@_cRegra,M->C5_I_LOCEM))

   If _lAchouZG5
      If M->C5_I_TPVEN = "F"
         M->C5_I_DIASV:=ZG5->ZG5_DIASV
         M->C5_I_DIASO:=ZG5->ZG5_TMPOPE
      ElseIf M->C5_I_TPVEN = "V"
         M->C5_I_DIASV:=ZG5->ZG5_FRDIAV
         M->C5_I_DIASO:=ZG5->ZG5_FRTOP
      EndIf
   EndIf

Endif

If !lRet .And. M->C5_TIPO = "N" //Se não validou alteração do pedido libera os locks preventivos e cancela transação

    Disarmtransaction()
    SB2->(DBUNLOCK())
    SA1->(DBUNLOCK())
    MsUnlockAll()

    //===================================================================================
    // Houve um estorno do pedido de vendas do sistema RDC, mas uma das
    // validações não permitiu a gravação do pedido, então voltamos o pedido de vendas
    // para o sistema RDC desde que não esteja no webservice
    //===================================================================================
    If _lEstornoRDc .and. !_laoms074  .And. !_lAoms112
       SC5->(DbGoTo(_nRegVinc))
       U_RETPVRDC() // Grava tabelas de muro para envio ao sistema RDC.
       SC5->(DbGoTo(_nRecOrigem))
    EndIf
Endif

//====================================================================================================================================
//====================================================================================================================================
//====================================================================================================================================
// NOVAS VALIDAÇOES SEM GRAVAÇÃO NA BASE PROCURE POR "COLOQUE AQUI" E INSIRA AS VALIDACOES LÁ POR FAVOR, NÃO COLOQUE NADA AQUI
//====================================================================================================================================
//====================================================================================================================================
//====================================================================================================================================

IF TYPE("lMsErroAuto") = "L" .AND. !lRet .AND. !lMsErroAuto//Só altera o conteudo do lMsErroAuto se ele tiver Falso e o retorno for falso
   lMsErroAuto:=!lRet//Só Joga verdadeiro de for o caso
ENDIF

N := _nSalvaN

//====================================================================================================================================
//====================================================================================================================================
//====================================================================================================================================
// NOVAS VALIDAÇOES SEM GRAVAÇÃO NA BASE PROCURE POR "COLOQUE AQUI" E INSIRA AS VALIDACOES LÁ POR FAVOR, NÃO COLOQUE NADA AQUI
//====================================================================================================================================
//====================================================================================================================================
//====================================================================================================================================

Return( lRet )

/*
===============================================================================================================================
Programa----------: somContrato
Autor-------------: Fabiano Dias
Data da Criacao---: 02/12/2009
===============================================================================================================================
Descrição---------: Funcao utilizada para efetuar o somatorio do valor descontato na inclusao, alteracao, e copia dos itens de
------------------: um pedido de venda, e pegar o numero do contrato de desconto contratual.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Lógico - define se podera realizar a operacao de inclusao, alteracao ou copia
===============================================================================================================================
*/

Static Function somContrato()

//Local nvalorDesc	:= 0
//Local nvalorDPar	:= 0
Local aArea			:= GetArea()
Local nX			:= 0
Local nN			:= N //Restaura o valor de n, que eh a variavel publica do protheus que indica a linha do aCols.
Local aDados		:= {0,.T.,.T.,""}
//Local lControle		:= .F.
Local cNumContr		:= ""
Local lRet			:= .T. //Armazena se podera ser efetuada a alteracao, copia e inclusao de acordo com a vigencia dos dados do contrato
Local nProduto		:= aScan( aHeader , {|X| Upper(AllTrim(X[2])) == "C6_PRODUTO"	} )//Produto
Local nPosPerc		:= aScan( aHeader , {|x| Upper(Alltrim(x[2])) == "C6_I_PDESC"	} )

Private nTES		:= aScan( aHeader , {|X| Upper(AllTrim(X[2])) == "C6_TES"		} )

For nX := 1 To Len(aCols)

    //======================================================================
    // Atualiza o valor de N
    //======================================================================
    N := nX

    //======================================================================
    //Se a linha nao estiver deletada
    //======================================================================
    If !aCols[n][Len(aCols[n])]

        //======================================================================
        // Caso o usuario tenha fornecido uma TES verifica se tem contrato
        //======================================================================
        If !Empty(aCols[n][nTES])

            //======================================================================
            // Se a TES gerar financeiro busca dados de desconto contratual
            //======================================================================
            If (Posicione("SF4",1,xFilial("SF4") + aCols[n][nTES],"F4_DUPLIC") == 'S')

                aDados := u_veriContrato( M->C5_CLIENTE , M->C5_LOJACLI , aCols[n][nProduto] )

                //======================================================================
                // Se tem desconto
                //======================================================================
                If aDados[1] > 0

                    aCols[n,nPosPerc] := aDados[1]
                    //Para gravar os percentuais de todos os produtos eh necessario chamar a VeriContrato item a item

                Else

                    aCols[n,nPosPerc] := 0

                EndIf

                aCols[N,_nPosPrNet] := aCols[N,nPosPreco] - ((aCols[N,nPosPreco] * aCols[N,nPosPerc]) / 100)

                cNumContr := aDados[4] //Armazena o numero do contrato

                //======================================================================
                // Contrato nao esta aprovado pelo financeiro
                //======================================================================
                If !aDados[2]

                    lRet := .F.


                     U_MT_ITMSG(	'Pedido '+M->C5_NUM + " O contrato de desconto de venda: "+ cNumContr +" esta ativo para este cliente, aguardando somente a aprovacao do financeiro. "	+;
                                     "Solicite ao departamento financeiro a sua liberação antes de efetuar o pedido de venda."										,;
                                     "Validação de contrato",;
                                     "Ou solicite ao departamento comercial para que seja efetuado o bloqueio do contrato: "+ cNumContr,1								 )

                     Exit

                EndIf

                 //======================================================================
                // Contrato nao esta com a data de vigencia em vigor
                //======================================================================
                If !aDados[3]

                    lRet := .F.


                    U_MT_ITMSG(	'Pedido '+M->C5_NUM + " utiliza contrato de desconto "+ cNumContr	+;
                                    " ativo que esta com a data de vigencia vencida."				,;
                                    "Validação Contrato",;
                                    "Entrar em contato com o depto comercial",1						 )

                    Exit

                EndIf

            EndIf

        EndIf

    EndIf

Next nX

M->C5_I_NRZAZ:= cNumContr //Numero do contrato de desconto contratual

RestArea(aArea)

N:= nN //Restaura o valor de n, que eh a variavel publica do protheus que indica a linha do aCols.

Return( lRet )

/*
===============================================================================================================================
Programa----------: valida2Um
Autor-------------: Fabiano Dias
Data da Criacao---: 31/03/2010
===============================================================================================================================
Descrição---------: Funcao utilizada para validar no pedido de venda se o usuario esta infomando um valor na segunda unidade
------------------: de medida quando o produto nao possui uma segunda unidade de medida ou fator de conversao no seu cadastro
------------------: de produto.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Lógico - Define se o cadastro do produto possui inconsistências
===============================================================================================================================
*/

Static Function valida2Um()

Local nProduto	:=  aScan( aHeader , {|X| Upper( AllTrim( X[2] ) )	== "C6_PRODUTO"	} ) //Produto
Local nPosQtd2	:=  ascan( aHeader , {|x| AllTrim( x[2] )			== "C6_UNSVEN"	} )
//Local nPosUM2	:=  ascan( aHeader , {|x| AllTrim( x[2] )			== "C6_SEGUM"	} )

Local aArea		:= GetArea()
Local lRet		:= .T.
Local nOld		:= n,nX

For nX := 1 To Len(aCols)

    n := nX

    //================================================================================
    // Se a linha nao estiver deletada
    //================================================================================
    If !aCols[n][Len(aCols[n])]

        //================================================================================
        // Caso haja inconsistencia no cadastro de produto zerar a 2 qtde de medida
        //================================================================================
        If !vldQtde2um( aCols[n,nProduto] , aCols[n,nPosQtd2] )
            lRet := .F.
            EXIT
        EndIf

    EndIf

Next nx

n := nOld

RestArea(aArea)

Return( lRet )

/*
===============================================================================================================================
Programa----------: vldQtde2um
Autor-------------: Fabiano Dias
Data da Criacao---: 31/03/2010
===============================================================================================================================
Descrição---------: Funcao utilizada para validar no pedido de venda se o usuario esta infomando um valor na segunda unidade
------------------: de medida quando o produto nao possui uma segunda unidade de medida ou fator de conversao no seu cadastro
------------------: de produto.
===============================================================================================================================
Parametros--------: cproduto - produto a validar
                    qtdesegum - quantidade informada na segunda unidade
===============================================================================================================================
Retorno-----------: Verdadeiro - Caso encontre inconsistencia no cadastro do produto de acordo com a descricao citada acima
------------------: Falso - O cadastro do produto esta ok
===============================================================================================================================
*/

STATIC Function vldQtde2um(cProduto,qtdesegum)

Local cFiltro:= "%"
Local lRet:= .T.

if Select("QRYTMP2UM") > 0
    dbSelectArea("QRYTMP2UM")
    dbCloseArea()
endif

//Filtros

//Para o caso de algum dia o cadastro de produtos deixar de ser compartilhado
If !Empty(xFilial("SB1"))
    cFiltro+= " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
EndIf

cFiltro+= " AND SB1.B1_COD = '" + cProduto + "'"

cFiltro+= "%"

BeginSql alias "QRYTMP2UM"
    SELECT
    B1_SEGUM,B1_CONV,B1_GRUPO
    FROM
    %table:SB1% SB1
    WHERE
    SB1.%notDel%
    %exp:cFiltro%
EndSql

dbSelectArea("QRYTMP2UM")

If QRYTMP2UM->(!Eof())
    If (Empty(QRYTMP2UM->B1_SEGUM) .And. QRYTMP2UM->B1_CONV <> 0) .Or. (qtdesegum > 0 .And. Empty(QRYTMP2UM->B1_SEGUM))
        lRet:= .F.
    EndIf
EndIf

dbSelectArea("QRYTMP2UM")
dbCloseArea()

Return lRet

/*
===============================================================================================================================
Programa----------: vldTESBloq
Autor-------------: Fabiano Dias
Data da Criacao---: 28/09/2010
===============================================================================================================================
Descrição---------: Funcao utilizada para validar no pedido de venda se TES fornecida nao esta bloqueada, pois este tipo de
------------------: bloqueio somente pode ser feito por ponto de entrada.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Lógico - Define se todas as TES estão liberadas para uso
===============================================================================================================================
*/

Static Function vldTESBloq()

Local nTES	:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "C6_TES" } )
Local _nProduto := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "C6_PRODUTO" } )

Local aArea	:= GetArea()
Local lRet	:= .T.  , nx
Local nOld	:= n

For nX := 1 To Len(aCols)

    n := nX

    //================================================================================
    // Se a linha nao estiver deletada
    //================================================================================
    If !aCols[n][Len(aCols[n])]
       //================================================================================
       // Verifica se a TES esta bloqueada
       //================================================================================
       If AllTrim(Posicione("SF4",1,xFilial("SF4") + aCols[n][nTES],"F4_MSBLQL")) == '1'
          lRet := .F.
       EndIf

       //================================================================================
       // Verifica se há contradição entre a TES que diz para não movimentar estoques
       // e a configuração do produto que diz para movimentar estoque.
       //================================================================================
       If AllTrim(Posicione("SF4",1,xFilial("SF4") + aCols[n][nTES],"F4_ESTOQUE")) == "N" .And.;
          AllTrim(Posicione("SB5",1,xFilial("SB5") + aCols[n][_nProduto],"B5_I_ESTOB")) == "S"

          U_MT_ITMSG("Ped.: " + M->C5_NUM + " O Produto " + Alltrim(aCols[n][_nProduto]) + " exige movimento de estoque e a TES " + Alltrim(aCols[n][nTES]) + " não movimenta estoque!",;
                  "Validação TES",,1 )

          lRet := .F.

       EndIf
    EndIf

Next nx

//================================================================================
// Caso tenha encontrada alguma TES Bloqueada que esteja em copia de pediddo
//================================================================================
If !lRet


    U_MT_ITMSG(	'Pedido '+M->C5_NUM + " Não poderá ser realizada a cópia/alteração deste pedido, pois possui TES bloqueada"			,;
                    "Validação TES",;
                    "Favor contactar o departamento fiscal.",1	 )

EndIf

n := nOld

RestArea(aArea)

Return( lRet )

/*
===============================================================================================================================
Programa----------: vldEmail
Autor-------------: Fabiano Dias
Data da Criacao---: 14/02/2011
===============================================================================================================================
Descrição---------: Funcao utilizada para validar na inclusao, alteracao ou copia do pedido de venda o campo e-mail do cliente
------------------: ou e-mail para verificar se o mesmo encontra-se com algum tipo de problema.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Lógico - Define se o campo e-mail foi preenchido corretamente.
===============================================================================================================================
*/

User Function vldEmail()

Local _aArea	:= GetArea()
Local _lRet		:= .T.

//================================================================================
// Caso o tipo do pedido de venda seja dos tipos:
//   N= Normal
//   C= Complemento de Precos
//   I= Complemento de ICMS
//   P= Complemento de IPI
// Sera efetuada uma busca na tabela SA1 pelo e-mail do cliente
// para posterior averiguacao.
//================================================================================
If M->C5_TIPO $ 'N/C/I/P'

    DBSelectArea("SA1")
    SA1->( DBSetOrder(1) )
    If SA1->( DBSeek(xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI ) )

        _lRet := U_EEmail( AllTrim( SA1->A1_EMAIL ) )

        If !_lRet .And. M->C5_I_OPER == '02'

            _lRet := .T.

        ElseIf !_lRet


            U_MT_ITMSG(	'Pedido  '+M->C5_NUM + " Foi encontrado um problema no E-MAIL do cliente: "+ _ENTER + _ENTER + M->C5_CLIENTE +'/'+ M->C5_LOJACLI +'-'+ SA1->A1_NOME,;
                            "Validação Email",;
                            "Favor alterar o cadastro do cliente antes de efetuar a conclusão desta operação, pois o mesmo encontra-se vazio ou com formato inválido.",1	 )

        EndIf

    EndIf

//================================================================================
// Caso o tipo do pedido de venda seja dos tipos:
//   D= Devolucao de compras
//   B= Utiliza Fornecedor
// Sera efetuada uma busca na tabela SA2 pelo e-mail do fornecedor para posterior
// averiguacao.
//================================================================================
ElseIf M->C5_TIPO $ 'D/B'

    DBSelectArea("SA2")
    SA2->( DBSetOrder(1) )
    If SA2->( DBSeek( xFilial("SA2") + M->C5_CLIENTE + M->C5_LOJACLI ) )

        _lRet := U_EEmail( AllTrim( SA2->A2_EMAIL ) )

        If !_lRet .And. M->C5_I_OPER == '02'

            _lRet := .T.

        ElseIf !_lRet


            U_MT_ITMSG(	'Pedido '+M->C5_NUM + " Foi encontrado um problema no E-MAIL do fornecedor: "+ _ENTER + _ENTER + M->C5_CLIENTE +'/'+ M->C5_LOJACLI +'-'+ SA2->A2_NOME,;
                         "Validação Email",;
                            "Favor alterar o cadastro do fornecedor antes de efetuar a conclusão desta operação, pois o mesmo encontra-se vazio ou com formato inválido.",1	 )

        EndIf

    EndIf

EndIf

RestArea( _aArea )

Return( _lRet )

/*
===============================================================================================================================
Programa----------: vldCoorden
Autor-------------: Fabiano Dias
Data da Criacao---: 09/03/2011
===============================================================================================================================
Descrição---------: Funcao utilizada para validar o coordenador informado no pedido para constatar se este eh igual ao da regra
------------------: de comissao eh o mesmo do cadastro do vendedor.
===============================================================================================================================
Parametros--------: _cVendedor - Codigo do Vendedor
------------------: _cCoorden  - Codigo do Coordenador
------------------: _cDesCoord - Descricao do Coordenador
===============================================================================================================================
Retorno-----------: Lógico - Define se as informações estão corretas
===============================================================================================================================
*/

Static Function vldCoorden( _cVendedor , _cCoorden , _cDesCoord , _cCliente , _cLojaCli , _cCodGeren )

Local _cAlias		:= GetNextAlias()
Local _cAliasSA3	:= GetNextAlias()
Local _cAliasVal	:= ""
Local _cAliasSA1	:= ""

Local _lRet			:= .T.
Local _cFiltro		:= ""
Local _cFiltrSA3	:= ""
Local _cFiltrSA1	:= ""
Local _cFilSA3		:= ""

Local _cCodCoZAE	:= ""
Local _cCodExc		:= AllTrim( GetMV( 'IT_COMEXCR' ,, '' ) )

Local _lPedUnitz	:= .F.
Local x

Local _nPosProd  :=  ascan(aHeader,{|x| Upper(AllTrim(x[2])) == "C6_PRODUTO"})

//===============================================================
//|Percorre todos os itens do pedido de venda para constatar    |
//|se este eh um pedido de PALLET, pois os pedidos de pallet    |
//|sao feitos de forma sepada dos outros pedidos de venda, sendo|
//|que os pedidos de PALLET nao devem entrar na validacao.      |
//===============================================================
For x:=1 to Len(aCols)

    //===============================================
    //|Verifica se a linha nao se encontra deletada.|
    //===============================================
    If !aCols[x,len(aHeader)+1]

        //============================================
        //|Grupo de produtos dos unitizadores == 0813|
        //============================================
        If SubStr(aCols[x,_nPosProd],1,4) == '0813'

            _lPedUnitz:= .T.
            exit

        EndIf

    EndIf

Next x

//========================================================================
//|Somente quando o tipo do pedido de venda for igual a normal  		 |
//========================================================================
If M->C5_TIPO == 'N' .And. !_lPedUnitz .and. FUNNAME() != "AOMS003"

    _cFiltro := "% "
    _cFiltro += "     D_E_L_E_T_ = ' ' "
    _cFiltro += " AND ZAE_VEND   = '"+ _cVendedor +"' "
    _cFiltro += " %"

    BeginSql alias _cAlias

        SELECT		ZAE_CODSUP, ZAE_MSBLQL
        FROM		%table:ZAE%
        WHERE		%exp:_cFiltro%
        GROUP BY	ZAE_CODSUP, ZAE_MSBLQL

    EndSql

    DBSelectArea(_cAlias)
    (_cAlias)->( DBGotop() )
    If (_cAlias)->( !Eof() )

        If (_cAlias)->ZAE_MSBLQL == '1'

            _lRet := .F.

            //U_MT_ITMSG(_cMens,_cTitu,_cSolu,_ntipo
            U_MT_ITMSG('O cadastro das regras de comissão do '+;
                    'vendedor informado no pedido de venda '+;
                    'está bloqueado!'						,;
                    'Atencao(MT410TOK) P:'+M->C5_NUM        ,;
                    'Para confirmar o pedido, verifique o ' +;
                    'vendedor informado e/ou o cadastro das '+;
                    'regras de comissão para o mesmo.', 1 )

        EndIf

        If _lRet

            _cCodCoZAE := AllTrim( (_cAlias)->ZAE_CODSUP )

            //==============================================================
            //|Pesquisa o coordenador cadastradado no cadastro de vendedor.|
            //==============================================================
            _cFiltrSA3 := "% "
            _cFiltrSA3 += "     D_E_L_E_T_ = ' ' "
            _cFiltrSA3 += " AND A3_COD     = '"+ _cVendedor +"' "
            _cFiltrSA3 += " %"

            BeginSql alias _cAliasSA3

                SELECT	A3_SUPER
                FROM	%table:SA3%
                WHERE	%exp:_cFiltrSA3%

            EndSql

            DBSelectArea(_cAliasSA3)
            (_cAliasSA3)->( DBGotop() )

            //==================================================================
            //|Verifica se existe divergencia de cadastros na regra de comissao|
            //|com o cadastro de vendedor.                                     |
            //==================================================================
            If _cCodCoZAE <> AllTrim( (_cAliasSA3)->A3_SUPER )

                _lRet := .F.

                //U_MT_ITMSG(_cMens,_cTitu,_cSolu,_ntipo
                U_MT_ITMSG( 		 	'O cadastro do vendedor informado no '		+;
                                    'pedido de venda está com divergências '	+;
                                    'com relação às regras de comissão!'		,;
                                    'Atencao(MT410TOK) P:'+M->C5_NUM            ,;
                                     'O coordenador amarrado ao vendedor não '	+;
                                    'é o mesmo que está cadastrado nas regras '	+;
                                    'de comissão para o mesmo.'					, 1 )

            ElseIf _cCodCoZAE <>  AllTrim(_cCoorden)

                _lRet   := .F.

                //U_MT_ITMSG(_cMens,_cTitu,_cSolu,_ntipo
                U_MT_ITMSG(		    'O coordenador de vendas informado no '		+;
                                    'pedido de venda está com divergências '	+;
                                    'com relação às regras de comissão!'		,;
                                    'Atencao(MT410TOK) P:'+M->C5_NUM            ,;
                                     'Selecione novamente o vendedor no pedido '	+;
                                    'de venda para atualizar os dados do '		+;
                                    'cadastro ou verifique o cadastro do '		+;
                                    'vendedor para atualizar as informações!'	,1)

            EndIf

            DBSelectArea( _cAliasSA3 )
            (_cAliasSA3)->( DBCloseArea() )

        EndIf

    Else

        If Empty(_cCodExc) .Or. !( _cVendedor $ _cCodExc )

            _lRet   := .F.

            //U_MT_ITMSG(_cMens,_cTitu,_cSolu,_ntipo
            U_MT_ITMSG(			'O vendedor informado não possui regras de '+;
                                'comissão cadastradas no sistema!'			,;
                                 'Atencao(MT410TOK) P:'+M->C5_NUM+;
                                 'Para confirmar o pedido, verifique o '		+;
                                'vendedor informado e/ou o cadastro das '	+;
                                'regras de comissão para o mesmo.'			,,1 )

        EndIf

    EndIf

    DBSelectArea(_cAlias)
    (_cAlias)->( DBCloseArea() )

    //Verifca se o vendedor informado no pedido esta amarrado ao cliente e loja informados.
    If _lRet

        _cAliasSA1 := GetNextAlias()

        _cFiltrSA1 := "% "
        _cFiltrSA1 += "     D_E_L_E_T_ = ' ' "
        _cFiltrSA1 += " AND A1_COD     = '"+ _cCliente +"' "
        _cFiltrSA1 += " AND A1_LOJA    = '"+ _cLojaCli +"' "
        _cFiltrSA1 += " %"

        BeginSql alias _cAliasSA1

            SELECT	A1_VEND,A1_I_VEND2
            FROM	%table:SA1%
            WHERE	%exp:_cFiltrSA1%

        EndSql

        DBSelectArea(_cAliasSA1)
        (_cAliasSA1)->( DBGotop() )
        //Não validar quando for opercao 05 por causa do portal e operacao triangular
        If M->C5_I_OPER  <> "05" .AND. (_cAliasSA1)->A1_VEND <> _cVendedor .And. (_cAliasSA1)->A1_I_VEND2 <> _cVendedor

            _lRet := .F.

            //U_MT_ITMSG(_cMens,_cTitu,_cSolu,_ntipo
            U_MT_ITMSG(			'O vendedor informado no pedido de vendas '		+;
                                'está divergente do informado no cadastro '		+;
                                'do cliente ou o cliente não está amarrado '	+;
                                'à um vendedor responsável válido.'				,;
                                 'Atencao(MT410TOK) P:'+M->C5_NUM,;
                                 'Informe um vendedor que esteja amarrado '		+;
                                'ao cadastro do cliente ou verifique o '		+;
                                'cadastro do cliente para completar as '		+;
                                'informações necessárias.'						,1 )

        EndIf

        DBSelectArea(_cAliasSA1)
        (_cAliasSA1)->( DBCloseArea() )

    EndIf

    //=================================================================
    //|Valida se o coordenador e gerente informados no pedido de venda|
    //|são os mesmos informados no cadastro do vendedor.              |
    //=================================================================
    If _lRet

        _cAliasVal:= GetNextAlias()

        //=======================================================================
        //|Pesquisa o coordenador e gerente informados no cadastro de vendedor. |
        //=======================================================================
        _cFilSA3 := "% "
        _cFilSA3 += "     D_E_L_E_T_ = ' ' "
        _cFilSA3 += " AND A3_COD     = '"+ _cVendedor +"' "
        _cFilSA3 += " %"

        BeginSql alias _cAliasVal

            SELECT	A3_SUPER , A3_GEREN
            FROM	%table:SA3%
            WHERE	%exp:_cFilSA3%

        EndSql

        DBSelectArea(_cAliasVal)
        (_cAliasVal)->( DBGotop() )

        If (_cAliasVal)->( !Eof() )

            If (_cAliasVal)->A3_SUPER <> _cCoorden .Or. (_cAliasVal)->A3_GEREN <> _cCodGeren

                _lRet:= .F.

                //U_MT_ITMSG(_cMens,_cTitu,_cSolu,_ntipo
                U_MT_ITMSG(			'O cadastro do vendedor não está amarrado '		+;
                                    'ao coordenador/gerente informados no '			+;
                                    'pedido de venda atual. '						,;
                                     'Atencao(MT410TOK) P:'+M->C5_NUM,;
                                     'Selecione novamente o vendedor no pedido '		+;
                                    'de venda para atualizar os dados do '			+;
                                    'cadastro ou verifique o cadastro do '			+;
                                    'vendedor para atualizar as informações!'		,1)

            EndIf

        EndIf

        DBSelectArea(_cAliasVal)
        (_cAliasVal)->( DBCloseArea() )

    EndIf

EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: vldTpOper
Autor-------------: Fabiano Dias
Data da Criacao---: 25/10/2011
===============================================================================================================================
Descrição---------: Funcao utilizada para validar o tipo de operacao fornecida diante do cliente informado no pedido de venda.
===============================================================================================================================
Parametros--------: aCols - Dados dos ítens do pedido de venda
===============================================================================================================================
Retorno-----------: Lógico - Define se o tipo utilizado é válido.
===============================================================================================================================
*/

Static Function vldTpOper()

Local _lRet		:= .T.
Local _cTpOper2	:= GETMV("IT_TPOPER2") //Armazena o tipo de operacao que na TES INTELIGENTE pode ser utilizado para cliente 000001 - Italac //Lucas Borges Ferreira - 09/05/2012
Local _cTpOper3	:= GETMV("IT_TPOPER3")
Local _cFiltro	:= ""
Local cAliasSRA	:= "SRA"

//===================================================================
//|Operacao que estiverem contidas no parametro IT_TPOPER2 so pode- |
//|rao ser utilizadas para o cliente 000001, ou seja, a propria 	|
//|ITALAC e suas lojas. 		|
//|Alterado para que seja validada as operacoes que estiverem no    |
//|parametroIT_TPOPER2.												|
//===================================================================
If M->C5_I_OPER $ AllTrim(_cTpOper2)

    If M->C5_CLIENTE <> '000001'


        U_MT_ITMSG(	'Pedido.: '+M->C5_NUM + " Para o tipo de operacao: "+ AllTrim(_cTpOper2)+", somente podera ser informado o cliente 000001(ITALAC)."	,;
                    "Validação de operação",;
                        "Favor verificar se o tipo de operacao indicado esta correto, ou alterar o codigo do cliente informado.",1	 )

        _lRet := .F.

    EndIf

//==============================================================================
//|Outros tipo de operacao nao podem ter como cliente o codigo: 000001(ITALAC).|
//==============================================================================
Else

    If M->C5_CLIENTE == '000001'


        U_MT_ITMSG(	'Pedido '+M->C5_NUM + " Para o tipo de operacao diferente de: "+ AllTrim(_cTpOper2) +", nao podera ser informado o cliente 000001(ITALAC)."	,;
                    "Validação de operação",;
                        "Favor verificar se o tipo de operacao indicado esta correto, ou alterar o codigo do cliente informado.",1				 )

        _lRet := .F.

    EndIf

EndIf

//===================================================================
//|Operacao que estiverem contidas no parametro IT_TPOPER3 so pode- |
//|rao ser utilizadas para cliente que são funcionários ativos.     |
//|Incluida validação para     |
//|venda para funcionários										    |
//===================================================================
If M->C5_I_OPER $ AllTrim(_cTpOper3) .AND. M->C5_CLIENTE <> ' '

    DBSelectArea("SA1")
    SA1->( DBSetOrder(1) )
    SA1->( DBSeek( xFilial("SA1") + M->( C5_CLIENTE + C5_LOJACLI ) ) )

    _cFiltro := "% "
    _cFiltro += "     D_E_L_E_T_ = ' '
    _cFiltro += " AND RA_SITFOLH IN (' ','F','A')
    _cFiltro += " AND RA_CATFUNC IN ('M','E')
    _cFiltro += " AND RA_CIC     = '"+ SA1->A1_CGC +"' "
    _cFiltro += " %"

    cAliasSRA := GetNextAlias()

    BeginSql Alias cAliasSRA

        SELECT RA_MAT
        FROM	%table:SRA%
        WHERE	%exp:_cFiltro%

    EndSql

    If (cAliasSRA)->(Eof()) .Or. (cAliasSRA)->(Bof())

           U_MT_ITMSG(	'Pedido '+M->C5_NUM + " Para o tipo de operacao: "+ AllTrim(_cTpOper3) +", somente poderão ser informados clientes que também são funcionários."	,;
                       "Validação de operação",;
                           "Favor verificar se o tipo de operacao indicado esta correto, ou alterar o codigo do cliente informado.",1					 )

        _lRet := .F.

    Else
      //================================================================================
      // Bloquear a compra de produtos por funcionários afastados.
      //================================================================================
       SR8->(DbSetOrder(1))  // R8_FILIAL+R8_MAT+DTOS(R8_DATAINI)+R8_TIPO
       SR8->(DbSeek(xFilial("SR8")+(cAliasSRA)->RA_MAT))
       Do While ! SR8->(Eof()) .And. SR8->R8_FILIAL+SR8->R8_MAT == xFilial("SR8")+(cAliasSRA)->RA_MAT
           If SR8->R8_TIPO <> "Q" .Or. SR8->R8_TIPO <> "F"
            _lRet := .T.
             Exit
        Else
          If (Empty(SR8->R8_DATAFIM) .Or. SR8->R8_DATAFIM >= Date())

             U_MT_ITMSG('Pedido '+M->C5_NUM + "Funcionários com situação afastado não podem fazer pedidos de compras."	  ,;
                         "Validação pedido funcionário",;
                              "Os funcionários devem estar com situação ativo, para que os pedidos de compras possam ser realizados.",1	 )
            _lRet := .F.
            Exit
          EndIf
        Endif

          SR8->(DbSkip())
       EndDo
    EndIf
EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa----------: VldPeca
Autor-------------: Lucas Crevilari
Data da Criacao---: 04/09/2014
===============================================================================================================================
Descrição---------: Funcao utilizada para validar as quantidades (Qtd e Qtd 2a UM).Chamado 7182
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: ( .T. ) Dados validos para inclusao ( .F. ) caso contrario.
===============================================================================================================================
*/
Static Function VldPeca(nx)
Local _cOperEst		:= U_ITGETMV( "IT_OPEEST" , "  ")	// Tipos de operações que não valida quantidade fracionada
Local _cProdPe		:= U_ITGETMV( "IT_PRODPE" , "  ")	// Produtos permitidos que não validam quantidades fracinadas
Local _cLocval		:= U_ITGETMV( "IT_LOCFRA" , "  ")	// Armazéns que não valida quantidade fracionada
Local _nPosProduto, _nPosLoc
Local _cProdNFrac   := U_ITGETMV( "IT_PRDNFRAC" , "  ")	// Produtos proibidos de serem fracionados na Venda.
Local _cLocalNFrac  := U_ITGETMV( "IT_LOCNFRAC" , "  ")	// Armazens/Locais vinculados aos produtos proibidos de serem fracionados na Venda.
Local _cTipOpNFrac  := U_ITGETMV( "IT_TPONFRAC" , "  ")	// Tipos de Operações vinculados aos produtos proibidos de serem fracionados na Venda.

_nQuant2	:=	aScan(aHeader,{|nx|UPPER(Alltrim(nx[2]))	== "C6_UNSVEN"})
_nQtdPrd	:=  aScan(aHeader,{|nx|UPPER(Alltrim(nx[2]))	== "C6_QTDVEN"})
//_nDes2UM	:=  aScan(aHeader,{|nx|UPPER(Alltrim(nx[2]))	== "D1_SEGUM"})

_nPosProduto:=  aScan(aHeader,{|nx|UPPER(Alltrim(nx[2]))	== "C6_PRODUTO"})
_nPosLoc    :=  aScan(aHeader,{|nx|UPPER(Alltrim(nx[2]))	== "C6_LOCAL"})

nQtdProd 	:= Acols[nx][_nQtdPrd]
nQtd2UM 	:= Acols[nx][_nQuant2]
cNumIt		:= Acols[nx][1]
cDescIt		:= ALLTRIM(Acols[nx][3])

//================================================================================
// Se um produto estiver contido no parâmetro IT_PRDNFRAC e se o armazem
// estiver no parâmetro IT_LOCNFRAC ou o tipo de oparação estiver no parâmetro
// IT_TPONFRAC, obrigatóriamente deverá validar as quantidades fracionadas.
//================================================================================
If AllTrim(aCols[nx,_nPosProduto]) $ _cProdNFrac .And. (AllTrim(aCols[nx,_nPosLoc]) $ _cLocalNFrac .Or. M->C5_I_OPER $ _cTipOpNFrac)
   //================================================================================
   // Realiza a validação fracionamento de produtos na segunda unidade de medida.
   //================================================================================
   If nQtd2UM <> Int(nQtd2UM)
      U_MT_ITMSG("O produto" +AllTrim(SB1->B1_DESC)+" não pode ser vendido com quantidade fracionada na Segunda Unidade de Medida.",;
                 "Validação Fracionado",;
                 "Favor informar apenas quantidades inteiras na Segunda Unidade de Medida.",1)
      lRet:= .F.
      Return .F.
   EndIf
Else
   //================================================================================
   // As condições das 3 linhas a seguir, determinam se haverá ou não validação sobre
   // fracionamento da segunda unidade de medida.
   //================================================================================
   If !(M->C5_I_OPER $ _cOperEst)
      If !(AllTrim(aCols[nx,_nPosProduto]) $ _cProdPe)
         If !(AllTrim(aCols[nx,_nPosLoc]) $ _cLocval)
            //================================================================================
            // Realiza a validação fracionamento de produtos na segunda unidade de medida.
            //================================================================================
            If nQtd2UM <> Int(nQtd2UM)
               U_MT_ITMSG("O produto" +AllTrim(SB1->B1_DESC)+" não pode ser vendido com quantidade fracionada na Segunda Unidade de Medida.",;
                          "Validação Fracionado",;
                          "Favor informar apenas quantidades inteiras na Segunda Unidade de Medida.",1)
               lRet:= .F.
               Return .F.
            EndIf
         EndIf
      EndIf
   EndIf
EndIf

nVlrPeca := nQtdProd / nQtd2UM

nFtMin := Posicione("SB1",1,xFilial("SB1")+cNumPrd,"B1_I_FTMIN")
nFtMax := Posicione("SB1",1,xFilial("SB1")+cNumPrd,"B1_I_FTMAX")

If nVlrPeca < nFtMin .or. nVlrPeca > nFtMax //Fora dos limites: menor que o Minimo ou maior que o Maximo
    AADD(aItens,{cNumIt,cDescIt,nQtdProd,nQtd2UM,nVlrPeca, nx})
    Return  .F.
Endif

Return  .T.

/*
===============================================================================================================================
Programa----------: VldDev
Autor-------------: Lucas Crevilari
Data da Criacao---: 11/09/2014
===============================================================================================================================
Descrição---------: Funcao utilizada para verificar se é Devolucao de Diferenca de Pesagem. Chamado 7182
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function VldDev(nx)

_cDoc 		:= SC5->C5_NOTA 	 //aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="C6_NOTA"})
_cSerie 	:= SC5->C5_SERIE 	 //aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="C6_SERIE"})
_cCliente 	:= M->C5_CLIENTE //aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="C6_CLI"})
_cLoja 		:= M->C5_LOJACLI //aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="C6_LOJA"})
_cProduto 	:= aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="C6_PRODUTO"})

DbSelectArea("SD2")
DbSetOrder(3)
If DbSeek(xFilial("SD2")+_cDoc+_cSerie+_cCliente+_cLoja+Acols[nx,_cProduto])
    RecLock("SD2")
    IIF(lDifPes,cExpressao := "S", cExpressao := "N")
    Replace D2_I_DIFPE With cExpressao
    SD2->(MsUnlock())
Endif

_cDifPes := aScan(aHeader,{|nx| Upper(AllTrim(nx[2]))=="C6_I_DIFPE"}) //Diferenca de Pesagem.

If lDifPes
    Acols[nx,_cDifPes] := "S"
Else
    Acols[nx,_cDifPes] := "N"
Endif

Return()

/*
===============================================================================================================================
Programa----------: vldPedFun
Autor-------------: Josué Danich Prestes
Data da Criacao---: 12/09/2015
===============================================================================================================================
Descrição---------: Funcao utilizada para verificar atraves da CFOP se o pedido de venda corrente é de venda para funcionário
/produtor e limitar o valor de limite de crédito do mesmo
===============================================================================================================================
Parametros--------: aCols - Dados dos ítens do pedido de venda
===============================================================================================================================
Retorno-----------: Lógico - Define se o registro deverá ser bloqueado
===============================================================================================================================
*/

Static Function vldPedFun( aCols )

Local _lRet		:= .F.
Local _x			:= 1
Local _npedabr 	:= 0

Local _cCFOP	:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "C6_CF"	} )
Local _nValor	:= aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "C6_VALOR"	} )

Local _nSomator	:= 0
Local _nlimcre	:= 0
//Local _cCPF		:= " "
//Local _cVdFunc   	:= U_ITGETMV( "IT_VDFUNC" , "5101\5102" )


//só verifica para pedido normal de venda
If M->C5_TIPO = "N"

    //verifica se cliente ativo e puxa limite de crédito
    DBSelectArea("SA1")
    SA1->( DBSetOrder(1) )
    SA1->( DBSeek( xFilial("SA1") + M->( C5_CLIENTE + C5_LOJACLI ) ) )


    _cFiltro := "% "
    _cFiltro += "     D_E_L_E_T_ = ' '   "
    _cFiltro += " AND RA_CIC     = '"+ SA1->A1_CGC +"' "
    _cFiltro += " %"


    //verifica se é fornecedor produtor
    _cFiltro2 := "% "
    _cFiltro2 += "     D_E_L_E_T_ = ' ' "
    _cFiltro2 += " AND A2_I_CLASS = 'P' AND A2_MSBLQL <> '1' "
    _cFiltro2 += " AND A2_CGC     = '"+ SA1->A1_CGC +"' "
    _cFiltro2 += " %"


    cAliasSRA := GetNextAlias()

    BeginSql Alias cAliasSRA

        SELECT	RA_CIC
        FROM	%table:SRA%
        WHERE	%exp:_cFiltro%
        UNION ALL
        SELECT A2_CGC
        FROM %table:SA2%
        WHERE %exp:_cFiltro2%

    EndSql

    If (cAliasSRA)->( Eof())

        _lRet := .T.

    EndIf

    (cAliasSRA)->( dbclosearea())


Else

    //Se não é pedido normal já deixa validado
    _lRet := .T.

EndIf


If .not. _lRet

    //Verifica tipo de crédito e carrega se for tipo A ou B, também carrega o total de pedidos em abero
    If SA1->A1_RISCO == "A"

        _lRet := .T.

    Elseif SA1->A1_RISCO == "B"

        If SA1->A1_VENCLC >= Date()

            _nlimcre := SA1->A1_LC

            _cFiltro := "% "
            _cFiltro += "     C6.D_E_L_E_T_ = ' '
            _cFiltro += " AND C6.C6_CLI     = '"+ SA1->A1_COD +"' "
            _cFiltro += " AND C6.C6_LOJA     = '"+ SA1->A1_LOJA +"' "
            _cFiltro += " AND C6.C6_FILIAL     = '"+ xFilial("SC6") +"' "
            _cFiltro += " AND C6.C6_NUM     <> '"+ M->C5_NUM +"' "
            _cFiltro += " AND C6.C6_BLQ     <> 'R' "
            _cFiltro += " AND (SELECT ZAY_TPOPER FROM " + retsqlname("ZAY") + " ZAY WHERE ZAY.ZAY_FILIAL = '" + xFilial("ZAY") + "'"
            _cfiltro += " AND ZAY.ZAY_CF = C6.C6_CF AND ZAY.D_E_L_E_T_ = ' ')    = 'V' "
            _cFiltro += " %"


            cAliasSC6 := GetNextAlias()

            BeginSql Alias cAliasSC6

            SELECT	SUM(((C6_QTDVEN-C6_QTDENT)*C6_PRCVEN)-C6_VALDESC) SOMA
            FROM	%table:SC6% C6
            WHERE	%exp:_cFiltro%

            EndSql

            _npedabr := (cAliasSC6)->SOMA

            (cAliasSC6)->( dbclosearea() )

        Else


                U_MT_ITMSG('Pedido '+M->C5_NUM	+ " Limite de crédito do funcionário/produtor vencido, será considerado limite de crédito zerado.",;
                "Validação pedido Funcionário/Produtor",;
            "Favor solicitar apoio ao Departamento Financeiro/Comercial.")

        Endif

    Else


        U_MT_ITMSG('Pedido '+M->C5_NUM	 + " Funcionário/Produtor com risco de crédito " + alltrim(SA1->A1_RISCO) + ", será considerado limite de crédito zerado.",;
        "Validação pedido Funcionário/Produtor",;
        "Favor solicitar apoio ao Departamento Financeiro/Comercial.")

    Endif

Endif


//verifica se total do pedido e outros pedidos em aberto estão dentro do limite de crédito
If .not. _lRet

    For _x := 1 To Len(aCols)

        //================================================================================
        // Se a linha nao estiver deletada verifica se é cfop de venda e soma ao total
        //================================================================================
        If !aCols[_x][Len(aCols[_x])]

            If posicione("ZAY",1,xfilial("ZAY")+AllTrim(aCols[_x][_cCFOP]),"ZAY_TPOPER") == "V"

                _nSomator += aCols[_x][_nValor]

            EndIf

        EndIf

    Next _x

    If  (_nSomator + _npedabr) <= _nlimcre

        _lRet := .T.

    Else


        U_MT_ITMSG("Pedido ultrapassa limite de crédito disponível." + chr(13) + chr(10) +;
        "Limite de crédito....." + padl(alltrim(transform(_nlimcre,"@E 999,999,999.99")),13,".") + chr(13) + chr(10) +;
        "Pedidos em aberto" + padl(alltrim(transform(_npedabr,"@E 999,999,999.99")),13,".") + chr(13) + chr(10) +;
        "----------------------------------------------------------------" + chr(13) + chr(10) +;
        "Limite disponível..." + padl(alltrim(transform(_nlimcre - _npedabr,"@E 999,999,999.99")),13,".") + chr(13) + chr(10) +;
        "Total do pedido......." + padl(alltrim(transform(_nSomator,"@E 999,999,999.99")),13,"."),;
        "Validação pedido Funcionário/Produtor",;
        "Favor solicitar apoio ao Departamento Comercial/Crédito.",1)

    EndIf

Endif

Return( _lRet )

/*
===============================================================================================================================
Programa----------: vldFilArm
Autor-------------: Josué Danich Prestes
Data da Criacao---: 25/09/2015
===============================================================================================================================
Descrição---------: Identifica se usuário tem restrição para a Filial x Armazém
===============================================================================================================================
Parametros--------: aCols - Dados dos ítens do pedido de venda
===============================================================================================================================
Retorno-----------: Lógico - Define se o registro deverá ser bloqueado
===============================================================================================================================
*/
Static Function vldFilArm( aCols )

Local _lRet		    := .T.
Local _cCodArmaz	:=	aScan( aHeader , {|x| UPPER( Alltrim( x[2] ) ) == "C6_LOCAL"	} )
Local _cCodProd	    :=	aScan( aHeader , {|x| UPPER( Alltrim( x[2] ) ) == "C6_PRODUTO"	} )
Local _ni			:= 1
Local _cmens		:= ""
Local _ccodusr      := alltrim(RetCodUsr())
Local _cOperXLocal  := ""
Local _lRet2 := .T. , _cListaArmaz := ""

_cOperXLocal  := U_ITGETMV( 'IT_OPERXLOC' , '10;24;')
_cFilXArmazem := U_ITGETMV( 'IT_FILXARMZ' , '9036;')

For _ni := 1 to len(acols)

        If !aCols[_Ni	][Len(aHeader)+1] //Não verifica linhas deletadas

            //============================================
            //Valida armazémxprodutoxfilialxusuário
            //============================================
            _aRet:= U_ACFG004E(_ccodusr, alltrim(xFilial("SD1")), alltrim(acols[_Ni][_cCodArmaz]),alltrim(acols[_Ni][_cCodProd]),.F.)

            //se ainda está valido verifica se não teve erro
            If _lRet

              _lRet:= _aRet[1]

            Endif

            // adiciona armazens com problema se ainda não estiver na mensagem
            if empty(_cmens)

                _cmens += _aRet[2]

            elseif !(_aRet[2]$_cmens) .and. !(Empty(_aRet[2]))

                _cmens += ", " + _aRet[2]

            Endif

            //====================================================
            // Validação por Tipo de Operação X Filial X Armazém
            //====================================================
            If M->C5_I_OPER $  _cOperXLocal .And. cFilAnt+alltrim(acols[_Ni][_cCodArmaz]) $ _cFilXArmazem
               _lRet2 := .F.
               _cListaArmaz += alltrim(acols[_Ni][_cCodArmaz]) + "; "
            EndIf

        EndIf

Next

//============================================
//Mostra lista de armazéns com problema
//============================================
If !(_lRet)


        U_MT_ITMSG( 'Pedido '+M->C5_NUM + " Usuário sem acesso ao(s) armazém(éns) abaixo nessa filial: " + CRLF + _cmens,;
                    "Validação usuário",;
                    'Caso necessário solicite a manutenção à um usuário com acesso ou, se necessário, solicite o acesso à área de TI/ERP.',1 )

Endif

//======================================================================
// Mostra mensagem da Validação por Tipo de Operação X Filial X Armazém
//======================================================================
If ! _lRet2
   U_MT_ITMSG( " Filial: " + cFilAnt + ', Pedido Nr.: '+M->C5_NUM + ", Operação: " + M->C5_I_OPER +", Armazém: "+ _cListaArmaz + CRLF +;
               " Não é permitido utilizar esta operação para este armazém.",;
               " Validação Operação X Filial X Armazém:",'',1 )
   _lRet := .F.

EndIf

Return( _lRet )

/*
===============================================================================================================================
Programa--------: vldlibbon
Autor-----------: Josué Danich Prestes
Data da Criacao-: 12/04/2016
===============================================================================================================================
Descrição-------: Valida liberação de bonificação do pedido
===============================================================================================================================
Parametros------: acols - linhas do pedido
===============================================================================================================================
Retorno---------: _lret - se continua liberado ou não
===============================================================================================================================
*/
Static function vldlibbon( acols )

Local _lret 		:= .T.
Local _ntotprc 	:= 0
Local _ntotqtd 	:= 0
Local _nPosPreco	:= Ascan( aHeader , { |x| AllTrim(x[2]) == "C6_PRCVEN"  } )
Local _nPosqtd  	:= Ascan( aHeader , { |x| AllTrim(x[2]) == "C6_QTDVEN"  } )


//Verifica Status

If M->C5_I_BLOQ = "B"

    U_MT_ITMSG(	"Pedido " + M->C5_NUM + " de bonificação bloqueado "	,;
                "Validação Bonificação",;
                            "O pedido deverá ser liberado antes de ficar disponível para faturamento.",1 )

    Return .F.

Endif

If M->C5_I_BLOQ == "R"

    U_MT_ITMSG(	"Pedido " + M->C5_NUM + " de bonificação REJEITADO ",;
                    "Validação Bonificação",;
                            "O pedido não poderá ser enviado para faturamento.",1 )

    Return .F.

Endif

If M->C5_I_BLOQ == "L"

    //verifica alteração de cliente e loja

    If !(SC5->C5_I_CLILB == M->C5_CLIENTE .and. SC5->C5_I_LLIBB == M->C5_LOJACLI)

        U_MT_ITMSG(	"Pedido " + M->C5_NUM + " O cliente do pedido foi alterado desde a liberação de bonificação - "	,;
                        "Validação Bonificação",;
                            "O pedido deverá ser liberado novamente antes de ficar disponível para faturamento.",1)

        Return .F.

    Endif

    //roda acols para verificar preço e quantidade
    _ni := 1
    Dbselectarea("SC6")
    SC6->( Dbsetorder(1) )
    SC6->( Dbseek( SC5->C5_FILIAL + SC5->C5_NUM ) )

    Do while _ni <= len(acols)

        _ntotprc += acols[_ni][_nPosPreco]
        _ntotqtd += acols[_ni][_nPosqtd]

        If !(acols[_ni][_nPosPreco] == SC6->C6_PRCVEN .AND. acols[_ni][_nPosqtd] == SC6->C6_QTDVEN)

            U_MT_ITMSG(	"Pedido " + M->C5_NUM + " Preços e/ou quantidades foram alterados desde a liberação de bonificação ",;
                            "Validação Bonificação",;
                            "O pedido deverá ser liberado novamente antes de ficar disponível para faturamento.",1 )

            Return .F.

        Endif

        _ni++

        SC6->( Dbskip() )

    Enddo

    //verifica totais
    If !(_ntotprc == SC5->C5_I_VLIBB .AND. _ntotqtd == SC5->C5_I_QLIBB)

            U_MT_ITMSG(	"Pedido " + M->C5_NUM + " Preços e/ou quantidades foram alterados desde a liberação de bonificação - "	+;
                            "Validação Bonificação",;
                            "O pedido deverá ser liberado novamente antes de ficar disponível para faturamento.",1 )

            Return .F.

    Endif


Endif

Return _lret

/*
===============================================================================================================================
Programa--------: MTPV_VIN()
Autor-----------: Alex Wallauer
Data da Criacao-: 18/01/2018
===============================================================================================================================
Descrição-------: Tratamento para Pedido VINCULADO
===============================================================================================================================
Parametros--------: _lAchou: Achou no SC5 / _lLimpa: Limpa o campo C5_I_PEVIN
===============================================================================================================================
Retorno-----------: True ou False de acordo com A TRAVA SC5
===============================================================================================================================
*/
STATIC Function MTPV_VIN(_lAchou,_lLimpa)
LOCAL _lTravou:=.F.,M,_cUser,_cMen,_cSol
Local _laoms074 := .F.

//Se veio do webservice já retorna .T.
If FWIsInCallStack("U_ALTERAP") .or. FWIsInCallStack("U_INCLUIC") .or. FWIsInCallStack("U_AOMS085B")
    _laoms074 := .T.
Endif


IF _lAchou

    IF !SC5->(MSRLOCK(SC5->(RECNO())))
        FOR M := 1 TO 5
            IF SC5->(MsRLock(SC5->(RECNO())))
                _lTravou:=.T.
                EXIT
            ENDIF
        NEXT
        IF !_lTravou
            _cUser:= TCInternal(53)
            _cMen := "O Pedido vinculado "+M->C5_I_PEVIN+" esta sendo atualizado por outro Usuario ["+_cUser+"]"
            _cSol := "Aguarde por alguns instantes a liberação do Pedido e tente novamente."
            U_MT_ITMSG( _cMen , 'Atencao!',_cSol,1)

            lRet:=.F.
            RETURN .F.

        ENDIF
    ENDIF

    IF (EMPTY(M->C5_I_PEVIN) .OR. _lLimpa) .and. !_laoms074
       IF !EMPTY(SC5->C5_I_PEVIN)//Só faço atualização se necessario
          SC5->(RECLOCK("SC5",.F.))
          SC5->C5_I_PEVIN := ""

          U_RETPVRDC() // Grava tabelas de muro para envio ao sistema RDC.
       ENDIF
    ELSE
       IF SC5->C5_I_PEVIN <> M->C5_NUM .and. !_laoms074//Só faço atualização se necessario
          SC5->(RECLOCK("SC5",.F.))
          SC5->C5_I_PEVIN := M->C5_NUM

          U_RETPVRDC() // Grava tabelas de muro para envio ao sistema RDC.
       ENDIF
    ENDIF
    SC5->(MsUnlock())//destrava o MSRLOCK

ELSEIF !EMPTY(M->C5_I_PEVIN) .and. !_laoms074//Se não achar o gravado SC5->C5_I_PEVIN não preisa validar pq já que não existe não preciso atualizar
    //Essa validação é caso o pedido seja deletado entre a validação e gravação
    U_MT_ITMSG("O Pedido vinculado "+M->C5_I_PEVIN+" não existe.","PEDIDO VINCUALADO","Vincule um Pedido cadastrado",1)
    lRet:=.F.
    RETURN .F.

ENDIF

RETURN .T.

/*
=================================================================================================================================
Programa--------: MT410TOKC
Autor-----------: Julio de Paula Paz
Data da Criacao-: 21/08/2018
=================================================================================================================================
Descrição-------: Rotina de solicitação de retorno do Pedido integrado para o Sistema RDC/TMS multi-Embarcador(Cancela Pedido).

=================================================================================================================================
Parametros------: _lEstornoRDc = Variável passada por referencia que receberá o resultado da solicitação de retorno do pedido de
                                 vendas do sistema RDC. Esta variável indica se houve ou não integração com o sistema RDC.
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
Static Function MT410TOKC(_lEstornoRDc)
Local _lRet := .T.
//Local _lWsTms := U_ITGETMV( 'IT_WEBSTMS' , .F.) // Indica se rotina de integração WebService é TMS Multi-Embarcador ou RDC.
Local _cTextoMsg

Begin Sequence

   _lEstornoRDc := .F.

   If SC5->C5_I_ENVRD <> "S"
      Break
   EndIf

   //================================================================================
   // Realiza a integração do cancelamento do pedido de vendas selecionados e
   // atualiza tabelas de muro.
   //================================================================================
   If ! U_IT_TMS(SC5->C5_I_LOCEM)//_lWsTms
      fwmsgrun(,{|oproc| _lRet := U_AOMS094E(oproc,.F.)},'Aguarde processamento...','Integrando dados cancelamento Pedidos de Vendas...')
   Else
      fwmsgrun(,{|oproc| _lRet := U_AOMS140E(oproc,.T.)},'Aguarde processamento...','Integrando dados cancelamento Pedidos de Vendas...')
   EndIf
   IF !_lRet
      If ! U_IT_TMS(SC5->C5_I_LOCEM)//_lWsTms
         _cTextoMsg := "Não foi possível realizar o cancelamento de Pedidos de Vendas no Sistema RDC."
      Else
         _cTextoMsg := "Não foi possível realizar o cancelamento de Pedidos de Vendas no Sistema TMS Multi-Embarcador."
      EndIf
      U_MT_ITMSG(_cTextoMsg,"Atenção",,1)
   ENDIF
   _lEstornoRDc := _lRet

End Sequence

Return _lRet

/*
=================================================================================================================================
Programa--------: RETPVRDC()
Autor-----------: Julio de Paula Paz
Data da Criacao-: 21/08/2018
=================================================================================================================================
Descrição-------: Rotina de devolução de retorno do Pedido integrado para o Sistema RDC.
=================================================================================================================================
Parametros------: Nenhum
=================================================================================================================================
Retorno---------: Nenhum
=================================================================================================================================
*/
User Function RETPVRDC()

Begin Sequence
   If SC5->C5_I_ENVRD = "S"
      Break
   EndIf

   //================================================================================
   // Realiza a devolução do pedido de vendas selecionados e
   // atualiza tabelas de muro.
   //================================================================================
   Reclock("SC5",.F.)
   SC5->C5_I_ENVRD := "N"
   SC5->C5_I_DTRET := Stod("") // Data de retorno do pedido de vendas do RDC para o Protheus
   SC5->C5_I_HRRET := ""       // Hora de retorno do pedidod e vendas do RDC para o Protheus
   SC5->(MsUnlock())

   fwmsgrun(,{|oproc| U_AOMS084P(,oproc)},'Aguarde processamento...','Integrando dados devolução Pedidos de Vendas...' )

End Sequence

Return Nil

/*
===============================================================================================================================
Programa----------: M410LITotais
Autor-------------: Alex Wallauer
Data da Criacao---: 27/09/2017
===============================================================================================================================
Descrição---------: Calcula os Totais
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
STATIC Function M410LITotais()

Local nVolume   	:= 0
Local cEspecie  	:= ""
Local _nPesoBrut	:= 0
Local nQtdItem  	:= 0  , nx
Local nPesBruTotItem:= 0
Local nPosProduto	:= Ascan(aHeader,{|x| alltrim(x[2])=="C6_PRODUTO"})
Local nPosQtd1 	    := Ascan(aHeader,{|x| alltrim(x[2])=="C6_QTDVEN" })
Local nPosQtd2 	    := Ascan(aHeader,{|x| alltrim(x[2])=="C6_UNSVEN" })
Local nPosUM1 	    := Ascan(aHeader,{|x| alltrim(x[2])=="C6_UM"     })
Local nPosUM2 	    := Ascan(aHeader,{|x| alltrim(x[2])=="C6_SEGUM"  })
Local nPosPBTI	    := Ascan(aHeader,{|x| alltrim(x[2])=="C6_I_PTBRU"})
Local _lPesVaria    := .F.
Local _cCodTPONFRAC := U_ITGETMV( "IT_VOLN3M","00060034701")// QUEIJO RALADO 40 G


SB1->(DbSetOrder(1))

For nx:=1 to len(aCols)

    if !aTail(aCols[nx])  // Se Linha Nao Deletada

        SB1->(DbSeek(xfilial("SB1")+aCols[nx,nPosProduto]))

        //CALCULA O PESO BRUTO TOTAL DO PEDIDO DE VENDA

        If ! FWIsInCallStack("U_ALTERAP") .and. !FWIsInCallStack("U_AOMS085B")
           If SB1->B1_I_PCCX > 0 .And. aCols[nx][nPosPBTI] <> 0 .And. ! (FWIsInCallStack("U_AOMS098") .Or. FWIsInCallStack("U_AOMS099") .Or. FWIsInCallStack("U_AOMS032") ) // Peso Variável
              nPesBruTotItem := aCols[nx][nPosPBTI]
              _lPesVaria := .T.
           Else
              nPesBruTotItem:=(SB1->B1_PESBRU * aCols[nx,nPosQtd1])
              IF nPosPBTI <> 0
                 aCols[nx][nPosPBTI]:=nPesBruTotItem
              ENDIF
           EndIf
        Else
           IF nPosPBTI <> 0 .And. aCols[nx][nPosPBTI] == 0
              nPesBruTotItem :=(SB1->B1_PESBRU * aCols[nx,nPosQtd1])
              aCols[nx][nPosPBTI] := nPesBruTotItem

           ElseIf SB1->B1_I_PCCX > 0 // Peso Variável
              nPesBruTotItem := aCols[nx][nPosPBTI]
              _lPesVaria := .T.
           Else
              nPesBruTotItem :=(SB1->B1_PESBRU * aCols[nx,nPosQtd1])
              IF nPosPBTI <> 0
                 aCols[nx][nPosPBTI]:=nPesBruTotItem
              ENDIF
           EndIf
        EndIf
        _nPesoBrut += nPesBruTotItem

        nQtdItem++

        If SB1->B1_I_QT3UM > 0 .AND. !ALLTRIM(aCols[nx,nPosProduto]) $  _cCodTPONFRAC

            If AllTrim(SB1->B1_TIPO) == 'PA'
                If AllTrim(SB1->B1_SEGUM) == 'PC'
                    If aCols[nx,nPosQtd2]/SB1->B1_I_QT3UM >= 1
                        nVolume+=aCols[nx,nPosQtd2]/SB1->B1_I_QT3UM
                    Else
                        nVolume++
                    EndIf
                Elseif AllTrim(SB1->B1_SEGUM) == 'CX' .And. SB1->B1_I_QT3UM = 1
                    nVolume+=aCols[nx,nPosQtd2]/SB1->B1_I_QT3UM
                Else
                    If aCols[nx,nPosQtd1]/SB1->B1_I_QT3UM >= 1
                        nVolume+=aCols[nx,nPosQtd1]/SB1->B1_I_QT3UM
                    Else
                        nVolume++
                    EndIf
                EndIf
            EndIf
            if nQtdItem == 1
                cEspecie := SB1->B1_I_3UM
            Endif
            if cEspecie <> SB1->B1_I_3UM
                cEspecie := "DIVERSOS"
            Endif

        Elseif aCols[nx,nPosQtd2] > 0
            If aCols[nx,nPosQtd2] >= 1
                nVolume+=aCols[nx,nPosQtd2]
            Else
                nVolume++
            EndIf

            if nQtdItem == 1
                cEspecie := aCols[nx,nPosUM2]
            Endif
            if cEspecie <> aCols[nx,nPosUM2]
                cEspecie := "DIVERSOS"
            Endif

        Else
            If aCols[nx,nPosQtd1] >= 1
                nVolume+=aCols[nx,nPosQtd1]
            Else
                nVolume++
            EndIf

            if nQtdItem == 1
                cEspecie := aCols[nx,nPosUM1]
            Endif
            if cEspecie <> aCols[nx,nPosUM1]
                cEspecie := "DIVERSOS"
            Endif

        Endif

    Endif

Next nx

//Armazena o peso bruto total do Pedido de Venda
M->C5_I_PESBR:= _nPesoBrut

If FWIsInCallStack("U_AOMS098") .Or. FWIsInCallStack("U_AOMS099") .Or. FWIsInCallStack("U_AOMS032")
   M->C5_PBRUTO  := 0          // Zerar peso bruto padrão quando a rotina for chamada do Desmembramentos de pedidos.
ElseIf _lPesVaria .And. Type("ALTERA") <> "U" .And. ALTERA
   M->C5_PBRUTO  := _nPesoBrut // Gravar novo peso bruto quando o peso for variável e for uma alteração.
ElseIf ! _lPesVaria .And. Type("ALTERA") <> "U" .And. ALTERA
   M->C5_PBRUTO  := 0
EndIf
IF M->C5_TIPO <> 'B' .OR. EMPTY(M->C5_VOLUME1)
   M->C5_VOLUME1 := nVolume
ENDIF

IF M->C5_TIPO <> 'B' .OR. EMPTY(M->C5_ESPECI1)
   M->C5_ESPECI1 := cEspecie
ENDIF

Return _nPesoBrut

/*
===============================================================================================================================
Programa----------: M410Proc
Autor-------------: Alex Wallauer
Data da Criacao---: 27/09/2017
===============================================================================================================================
Descrição---------: Calcula os Totais
===============================================================================================================================
Parametros--------: oProc,_cMensagem
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
STATIC Function M410Proc(oProc,_cMensagem)
IF oProc <> NIL
   oProc:cCaption := "Validando "+_cMensagem+"..."
   ProcessMessages()
ENDIF
RETURN


/*
===============================================================================================================================
Programa----------: CPBT_SC5()
Autor-------------: Alex Wallauer
Data da Criacao---: 26/10/2018
===============================================================================================================================
Descrição---------: Carga Peso Bruto Total _ SC5
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER Function CPBT_SC5()
Local _cPerg:="FILTRA_PV"

IF !PERGUNTE(_cPerg , .T. )
   RETURN .F.
ENDIF

PRIVATE _nGravados:=0
cTimeInicial:=TIME()

FWMSGRUN( ,{|oProc|  CPBT_SC5(oProc,cTimeInicial) }  , "SC6 - Inicio: "+LEFT(cTimeInicial,5)+" ["+ALLTRIM(MV_PAR01)+"] ["+DTOC(MV_PAR02)+"] ["+DTOC(MV_PAR03)+"] ["+ALLTRIM(MV_PAR04)+"]" )

Return .T.

/*
===============================================================================================================================
Programa----------: CPBT_SC5()
Autor-------------: Alex Wallauer
Data da Criacao---: 26/10/2018
Descrição---------: Carga Peso Bruto Total _ SC5
Parametros--------: oProc,cTimeInicial
Retorno-----------: Nenhum
===============================================================================================================================
*/
STATIC Function CPBT_SC5(oProc,cTimeInicial)
LOCAL nConta :=0
LOCAL xTotal :=0
LOCAL nTam   :=0
Local _cAlias:= GetNextAlias()
LOCAL cQuery := " SELECT SC5.R_E_C_N_O_ RECSF FROM "+ RetSqlName("SC5")+" SC5 WHERE "

oProc:cCaption :=  "Filtrando SC5, Aguarde..."
ProcessMessages()

cQuery += " SC5.D_E_L_E_T_	= ' ' "
IF !EMPTY(MV_PAR01)
   cQuery += " AND	SC5.C5_FILIAL IN "+ FormatIn(ALLTRIM(MV_PAR01),";")
ENDIF
IF !EMPTY(MV_PAR03)
   cQuery += " AND SC5.C5_EMISSAO BETWEEN '"+ DTOS(MV_PAR02) +"' AND '"+ DTOS(MV_PAR03) +"' "
ELSEIF !EMPTY(MV_PAR02)
   cQuery += " AND SC5.C5_EMISSAO = '"+ DTOS(MV_PAR02)+"' "
ENDIF
IF !EMPTY(MV_PAR04)
   cQuery += " AND	SC5.C5_TIPO IN "+ FormatIn(MV_PAR04,";")
ENDIF

If Select(_cAlias) > 0
   (_cAlias)->( DBCloseArea() )
EndIf

MPSysOpenQuery(cQuery,_cAlias)
DBSELECTAREA(_cAlias)

(_cAlias)->( DBGOTOP() )
COUNT TO  xTotal

IF xTotal > 30000
   xTotal:=ALLTRIM(STR(xTotal))

    IF !U_ITMSG("Serão processado "+xTotal+" registros, CONFIRMA?","Atenção",,3,2,2)
        RETURN .F.
    ENDIF

    cTimeInicial:=TIME()
ELSE
   xTotal:=ALLTRIM(STR(xTotal))
ENDIF

(_cAlias)->( DBGOTOP() )
nTam:=LEN(xTotal)+1

DO While (_cAlias)->(!Eof())

   nConta++

   SC5->(DBGOTO( (_cAlias)->RECSF ) )

   oProc:cCaption :=  "Lendo "+STR(nConta,nTam)+" de "+xTotal +" Lendo PV: "+SC5->C5_FILIAL+" "+SC5->C5_NUM+" PB Gravados: "+ALLTRIM(STR(_nGravados))
   ProcessMessages()

   GravaPeso(@_nGravados)

   (_cAlias)->( DBSkip() )

EndDo

_nGravados:=ALLTRIM(STR(_nGravados))

U_ITMSG("Carga (SC6) do Peso Bruto completada com sucesso "+_nGravados+" registros gravados.","Atenção","Hora inicio "+cTimeInicial+" - Hora fim "+TIME()+" Parametros: ["+ALLTRIM(MV_PAR01)+"] ["+DTOC(MV_PAR02)+"] ["+DTOC(MV_PAR03)+"] ["+ALLTRIM(MV_PAR04)+"]",2)

Return .T.
/*
===============================================================================================================================
Programa----------: GravaPeso
Autor-------------: Alex Wallauer
Data da Criacao---: 15/10/2018
===============================================================================================================================
Descrição---------: Processa a gravação dos pesos do itens da NF
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

Static Function GravaPeso(_nGravados)
Local _cFilSB1 := xFilial("SB1")

IF SC6->(FIELDPOS("C6_I_PTBRU")) = 0
   RETURN .F.
ENDIF

DEFAULT _nGravados:=0

SC6->( DBSetOrder(1) )
If 	SC6->( Dbseek( SC5->C5_FILIAL + SC5->C5_NUM ) )

    DO While SC6->(!Eof()) .and. SC6->C6_FILIAL+SC6->C6_NUM == SC5->C5_FILIAL + SC5->C5_NUM

        IF EMPTY(SC6->C6_I_PTBRU) .AND. !EMPTY(SC6->C6_QTDVEN)

            _nPesoItem := ( POSICIONE( "SB1" , 1 , _cFilSB1 + SC6->C6_PRODUTO , "B1_PESBRU" ) * SC6->C6_QTDVEN )
            IF _nPesoItem <> 0 .AND. SC6->( RecLock( "SC6",.F.,,.T.))
                SC6->C6_I_PTBRU := _nPesoItem
                SC6->( MsUnlock() )
                _nGravados++
            ENDIF

        ENDIF
        SC6->( DBSkip() )

    EndDo

EndIf

Return .T.

/*=============================================================================================================================
Programa----------: MT410_CT()
Autor-------------: Josué Danich
Data da Criacao---: 21/09/2018
===============================================================================================================================
Descrição---------: Validação e entrada de motivo de corte
===============================================================================================================================
Parametros--------: oproc - objeto da barra de processamento
===============================================================================================================================
Retorno-----------: ExpL01 - Se .T. continua a operacao, se .F. nao volta pra tela de pedido sem fazer nada.
===============================================================================================================================*/
STATIC Function MT410_CT()
Local _lret := .T.
Local _aitens := {}
Local _nnk := 1
Local _ltemct := .F.
Local nLinha        := 10
Local _nCol			:= 15
Local nPosProduto		:= Ascan( aHeader , { |x| Alltrim(x[2]) == "C6_PRODUTO"	} )
Local nPosQtde			:= Ascan( aHeader , { |x| AllTrim(x[2]) == "C6_QTDVEN"  } )
Local _omotiv

Public _cmotivs    := "  "

SC6->(Dbsetorder(1))

If SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM))

    Do while SC6->C6_FILIAL == SC5->C5_FILIAL .AND. SC6->C6_NUM == SC5->C5_NUM

        //Só grava e questiona corte de produto PA em pedido de vendas
        If alltrim(posicione("SB1",1,xfilial("SB1")+SC6->C6_PRODUTO,"B1_TIPO")) == "PA" .and. posicione("ZAY",1,xfilial("ZAY")+SC6->C6_CF,"ZAY_TPOPER") == "V"

            aadd(_aitens,{SC6->C6_ITEM,SC6->C6_PRODUTO,SC6->C6_QTDVEN})

        Endif

        SC6->(Dbskip())

    Enddo

    For _nnk := 1 to len(_aitens)

        _npos := ascan(acols,{|apos| alltrim(apos[nPosProduto]) == alltrim(_aitens[_nnk][2])})

        //Se não achou o produto no acols é porque foi alterado
        //Se a linha está deletada é corte pois nção aceita linha com produto repetido mesmo deletada
        If _npos == 0 .or. aCols[_npos][Len(aCols[_npos])]

            _ltemct := .T.
            _lret := .F.
            Exit

        //Se não está deletada mas a quantidade diminui
        Elseif acols[_npos][nPosQtde] < _aitens[_nnk][3]

            _ltemct := .T.
            _lret := .F.
            Exit

        Endif

    Next

    If _ltemct

        _cQuery := " SELECT "
        _cQuery += " DISTINCT X5_CHAVE CHAVE,X5_DESCRI DESCRI "
        _cQuery += " FROM "+ RetSqlName("SX5") +" X5 "
        _cQuery += " WHERE "
        _cQuery += "     D_E_L_E_T_ = ' ' "
        _cQuery += " AND X5_TABELA  = 'Z1' AND TRIM(X5_CHAVE) <> '98' AND TRIM(X5_CHAVE) <> '99' "
        _cQuery += " ORDER BY X5_CHAVE "

        If Select("TMPCF") > 0
            ("TMPCF")->( DBCloseArea() )
        EndIf

        MPSysOpenQuery(_cQuery,'TMPCF')
        DBSELECTAREA('TMPCF')

        _amotivs := {}

        While TMPCF->( !Eof() )

            aAdd( _amotivs , AllTrim( TMPCF->CHAVE ) + " - " + AllTrim( TMPCF->DESCRI ) )

            TMPCF->( DBSkip() )
        EndDo

        ("TMPCF")->( DBCloseArea() )

        _cmotivs := _amotivs[1]

        DEFINE MSDIALOG _oDlg2 TITLE ("Corte por alteração de PV") From 0,0 To 325, 650 PIXEL

        @ nLinha,_nCol Say OemToAnsi("Selecione o motivo para corte:")
        nLinha+=12

        _omotiv := TComboBox():New(nLinha,_nCol,{|u|if(PCount()>0,_cmotivs:=u,_cmotivs)}, _amotivs,250,20,_oDlg2,,,,,,.T.,,,,,,,,,'') //40

        nLinha+=38

        @ nLinha,_nCol    Button "OK" SIZE 41,15 ACTION ( _lret := .T. ,_oDlg2:End()) Pixel
           @ nLinha,_nCol+57 Button "Cancela"     SIZE 41,15 ACTION ( _oDlg2:End() ) Pixel

        ACTIVATE MSDIALOG _oDlg2


        if !_lret

            U_MT_ITMSG("Não foi selecionado motivo de corte, alteração não será efetuada","Atenção",,1)

        Endif

    Endif

Endif

Return _lret

/*=============================================================================================================================
Programa----------: MT410_JA()
Autor-------------: Alex Wallauer
Data da Criacao---: 25/10/2023
===============================================================================================================================
Descrição---------: Ao alterar os campos c5_i_agend ou c5_i_dtent, obrigar preenchimento do campo justificativa (zy3_juscod)
                    especifica para esses campos e observação (zy3_observ) da justificativa com texto minimo de 10 caracteres
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Se .T. continua a as outras validações, se .F. nao volta pra tela de pedido sem fazer nada.
===============================================================================================================================*/
STATIC Function MT410_JA()
Local _lret    := .F.
Local nLinha   := 10
Local _nCol1   := 05
Local _nCol2   := 40
Local _nCol3   := 90
Local _nTam    := 300

_cJustAG := Space(3)  // _aJustAG[1]
_cJustDE := Space(3)  // _aJustDE[1]
_cObseAG := SPACE(LEN(ZY3->ZY3_OBSERV))
_cObseDE := SPACE(LEN(ZY3->ZY3_OBSERV))

_cTitJus:="Justificativas das alterações "
_aFoders:={}
If _lAltAgen
   AADD(_aFoders,"Tipo de Agendamento")
   _cTitJus+="de Data de Entrega"
EndIf
IF _lAltData
   AADD(_aFoders,"Data de Entrega")
   If _lAltAgen
      _cTitJus+=" e "
   ENDIF
   _cTitJus+="do Tipo de Agendamento"
EndIf

DO WHILE .T.

   DEFINE MSDIALOG _oDlg2 TITLE _cTitJus From 0,0 To 280, 700 PIXEL

    _nColFolder:=350
    _nLinFolder:=100
    nLinha:=1

    oTFolder1:= TFolder():New( nLinha,1,_aFoders,,_oDlg2,,,,.T., , _nColFolder,_nLinFolder )

    If _lAltAgen
        nLinha:=5
        @ nLinha,_nCol1 Say "Tipo de Agendamento de: "+U_TipoEntrega(SC5->C5_I_AGEND) OF oTFolder1:aDialogs[1] PIXEL

        nLinha+=15
        @ nLinha,_nCol1 Say "Tipo de Agendamento para: "+U_TipoEntrega(M->C5_I_AGEND) OF oTFolder1:aDialogs[1] PIXEL

        nLinha+=15
        @ nLinha+4,_nCol1 Say "Justificativas:"       OF oTFolder1:aDialogs[1] PIXEL
        @ nLinha,_nCol2 MSGET _cJustAG F3 "ZY5"   SIZE 30,010  Valid(MT410VLJUS(_cJustAG , "C5_I_AGEND")) PIXEL OF oTFolder1:aDialogs[1] WHEN _lAltAgen //MULTILINE
                
        nLinha+=20
        @ nLinha+2,_nCol1 SAY  "Observação:" SIZE 060  ,007  PIXEL OF oTFolder1:aDialogs[1]
        @ nLinha,_nCol2 MSGet _cObseAG       SIZE _nTam,010  PIXEL OF oTFolder1:aDialogs[1] WHEN .F. 
    ENDIF

///***********************  FOLDER 2 *************************************************
    If _lAltData
        nLinha:=5
        @ nLinha,_nCol1 Say "Data de Entrega de: "+DTOC(SC5->C5_I_DTENT) OF oTFolder1:aDialogs[LEN(_aFoders)] PIXEL

          nLinha+=15
        @ nLinha,_nCol1 Say "Data de Entrega para: "+DTOC(M->C5_I_DTENT) OF oTFolder1:aDialogs[LEN(_aFoders)] PIXEL

        nLinha+=15
        @ nLinha+4,_nCol1 Say "Justificativas:"           OF oTFolder1:aDialogs[LEN(_aFoders)] PIXEL
        @ nLinha,_nCol2 MSGet _cJustDE  F3 "ZY5"  Valid(MT410VLJUS(_cJustDE , "C5_I_DTENT")) SIZE 030,010 PIXEL OF oTFolder1:aDialogs[LEN(_aFoders)] WHEN _lAltData //MULTILINE

        nLinha+=20
        @ nLinha+2,_nCol1 SAY  "Observação:" SIZE 060  ,007 PIXEL OF oTFolder1:aDialogs[LEN(_aFoders)]
        @ nLinha,_nCol2 Get _cObseDE       SIZE _nTam,010 PIXEL OF oTFolder1:aDialogs[LEN(_aFoders)] WHEN .F.
    ENDIF
    nLinha+=60
    @ nLinha,_nCol3    Button "CONTINUAR" SIZE 50,15 ACTION ( _lret := .T. ,_oDlg2:End()) PIXEL
       @ nLinha,_nCol3+99 Button "VOLTAR"    SIZE 50,15 ACTION ( _lret := .F. ,_oDlg2:End()) PIXEL

   ACTIVATE MSDIALOG _oDlg2

   If ! _lret
      U_MT_ITMSG("Não foi selecionada/Digitada a Justificativa/Observação, alteração do Pedido não será efetuada.","Atenção",,1)
   Else
      If (_lAltData .And. Empty(_cJustDE)) 
         U_MT_ITMSG("O código de justificativa para alteração da data de entrega não foi informado.","Atenção",,1)
         _lRet := .F.
      EndIf 

      If (_lAltAgen .And. Empty(_cJustAG))
         U_MT_ITMSG("O código de justificativa para alteração do tipo de agendamento não foi informado.","Atenção",,1)
         _lRet := .F.
      EndIf

      If ParamIXB[1] = 4//ALTERACAO
         If (SC5->C5_I_AGEND ="P" .AND. M->C5_I_AGEND = "A") .OR.;
            (SC5->C5_I_AGEND ="R" .AND. M->C5_I_AGEND = "A") .OR.;
            (SC5->C5_I_AGEND ="P" .AND. M->C5_I_AGEND = "M") .OR.;
            (SC5->C5_I_AGEND ="N" .AND. M->C5_I_AGEND = "A")
          	_lContOk := .T.
         Else
         	_lContOk := .F.
         EndIf
      EndIf 	
   EndIf

   Exit
EndDo

Return _lret

/*
====================================================================================================================================================================
Programa----------: MT410_UN()
Autor-------------: Alex Wallauer
Data da Criacao---: 08/04/2019
====================================================================================================================================================================
Descrição---------: Validação para não permitir fracionamento para PAs (produtos acabados) onde a primeira unidade de medida for UN (represente 1 inteiro)
====================================================================================================================================================================
Parametros--------: oProc
====================================================================================================================================================================
Retorno-----------: .T. ou .F.
====================================================================================================================================================================*/
STATIC Function MT410_UN(oProc)
Local _lRet  := .T.
Local _cProds:="" , nX
Local nPosProduto:= Ascan( aHeader , { |x| Alltrim(x[2]) == "C6_PRODUTO"	} )

ZZL->( DBSetOrder(3) )
If ZZL->( DBSeek( xFilial("ZZL") + RetCodUsr() ) )
   If ZZL->(FIELDPOS("ZZL_PEFRPA")) = 0 .OR. ZZL->ZZL_PEFRPA == "S"
      RETURN .T.
   EndIf
EndIf

FOR nX := 1 TO Len(aCols)
   // Muda o valor de N
    N := nX
    M410Proc(oProc,"(1a) Quantidades fracionadas, Item "+aCols[nX][nPosIte])

    IF aCols[n][Len(aCols[n])]
       LOOP
    ENDIF

    SB1->(dbSeek(xFilial("SB1") + AllTrim(aCols[n,nPosProduto])))
    If SB1->B1_TIPO == "PA" .AND. SB1->B1_UM == "UN"

        If aCols[n,nPosQtd] <> noround((aCols[n,nPosQtd]),0)
            _lRet := .F.
            _cProds+="Item: " + aCols[n,nPosIte]+" Prod.: " + AllTrim(aCols[n,nPosProduto])+" - UM: "+SB1->B1_UM+ " - " + LEFT(SB1->B1_DESC,45) + CHR(13)+CHR(10)
        EndIf

    EndIf

NEXT

If !_lRet
   U_MT_ITMSG("Não é permitido fracionar a quantidade da 1a. UM de produto onde a UM for UN. Clique em mais detalhes",;//,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes
                 "Validação Fracionado","Favor informar apenas quantidades inteiras na Primeira Unidade de Medida."         ,1     ,       ,        ,         ,     ,     ,;
                 {|| U_ITMSGLOG(_cProds,"Validação Fracionado") },_cProds )
ENDIF

Return _lRet

/*
===============================================================================================================================
Programa----------: M410SITITEM()
Autor-------------: Jerry
Data da Criacao---: 09/12/2019
===============================================================================================================================
Descrição---------: Retorna verdadeiro quando o Preço ou Qtd do Produto foi alterado.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

STATIC Function M410SITITEM()
Local nX := 1
Local _lItemAlterado := .F.
Local _nPosProduto	:= 0
Local _nPosTes 		:= 0
Local _nPosUser 	:= 0
Local _nPosPreco	:= 0
Local _nPosqtd		:= 0
Local _cCFOP	    := 0
Local _nPosIte	    := 0
Local _nPosVal		:= 0
Local _cSimilar     := ""
Local _lCodAlterado := .F.
Local _cQueijo		:= "N"
Local _nQtdAlterado := 0
Local _ntolporc     := u_itgetmv("IT_TOLPC",10) //Percentual Tolerância para Produto PA do Tipo Queijo.

_nPosProduto	:= Ascan( aHeader , { |x| Alltrim(x[2]) == "C6_PRODUTO"	} )
_nPosTes 		:= Ascan( aHeader , { |x| Alltrim(x[2]) == "C6_TES"		} )
_nPosUser 		:= Ascan( aHeader , { |x| AllTrim(x[2]) == "C6_I_USER"  } )
_nPosPreco		:= Ascan( aHeader , { |x| AllTrim(x[2]) == "C6_PRCVEN"  } )
_nPosqtd		:= Ascan( aHeader , { |x| AllTrim(x[2]) == "C6_QTDVEN"  } )
_cCFOP	        := aScan( aHeader , { |x| AllTrim(x[2]) == "C6_CF"	    } )
_nPosIte	   	:= aScan( aHeader , { |x| alltrim(x[2]) == "C6_ITEM"    } )
_nPosVal		:= Ascan( aHeader , { |x| AllTrim(x[2]) == "C6_VALOR"   } )

//================================================================================
// Processa todos os itens do Pedido
//================================================================================
DO While nX <= Len(aCols) 
    If !GdDeleted(nX)

        _lCodAlterado := .F.

         SC6->(Dbsetorder(1))
           If SC6->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM+aCols[nX][_nPosIte]))
            _cQueijo  := Posicione( "SB1" , 1 , xFilial("SB1") + SC6->C6_PRODUTO , "B1_I_QQUEI")
            If aCols[nX][_nPosProduto] != SC6->C6_PRODUTO
                _lCodAlterado := .T.
                _cSimilar := Posicione( "SB1" , 1 , xFilial("SB1") + SC6->C6_PRODUTO , "B1_I_PRDSM")
                If Alltrim(aCols[nX][_nPosProduto]) $ Alltrim(_cSimilar)
                    _lCodAlterado := .F.
                End
            EndIf
               If aCols[nX][_nPosPreco] != SC6->C6_PRCVEN .Or. aCols[nX][_nPosqtd] > SC6->C6_QTDVEN .Or. _lCodAlterado
                   _nQtdAlterado := _nQtdAlterado+1

                If _cQueijo = "S" .And. aCols[nX][_nPosqtd] <= (  SC6->C6_QTDVEN  + (( SC6->C6_QTDVEN  * _ntolporc) / 100 ) )
                    _nQtdAlterado := _nQtdAlterado-1
                End
             Endif
        Else
            _lItemNovo:=.T.
            _nQtdAlterado := _nQtdAlterado+1
           Endif
    EndIF

    nX++
EndDo

If _nQtdAlterado > 0
    _lItemAlterado := .T.
EndIF

Return  _lItemAlterado

/*
===============================================================================================================================
Programa----------: M410VLSDX
Autor-------------: Julio de Paula Paz
Data da Criacao---: 17/09/2021
===============================================================================================================================
Descrição---------: Valida a seleção de notas fiscais Sedex vinculadas ao pedido de Vendas.
===============================================================================================================================
Parametros--------: _cCampo = Campo que chamou a validação.
                            = Ou validação final do Pedido de Vendas.
===============================================================================================================================
Retorno-----------: _lRet = .T. = Validação Ok
                            .F. = Erro de validação
===============================================================================================================================
*/
User Function M410VLSDX(_cCampo)
Local _lRet := .T.

Begin Sequence
   SF1->(DbSetOrder(1)) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO

   If _cCampo == "C5_I_NFREF"
      If Empty(M->C5_I_NFREF)
         U_MT_ITMSG("Este pedido está configurado como SEDEX. O preenchimento da nota fiscal de referência é obrigatório.",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,"Preencha o numero da nota fiscal de referência SEDEX.",1)
         _lRet := .F.
         Break
      EndIf

      If ! SF1->(MsSeek(xFilial("SF1")+M->C5_I_NFREF))
         U_MT_ITMSG("A nota fiscal informada não existe para esta filial.",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,"Informe um numero de nota fiscal que exista.",1)
         _lRet := .F.
      EndIf

   ElseIf _cCampo == "C5_I_SERNF"
      If Empty(M->C5_I_SERNF)
         U_MT_ITMSG("Este pedido está configurado como SEDEX. O preenchimento da série da nota fiscal de referência é obrigatório.",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,"Preencha a série da nota fiscal de referência SEDEX.",1)
         _lRet := .F.
         Break
      EndIf

      If ! SF1->(MsSeek(xFilial("SF1")+M->C5_I_NFREF+M->C5_I_SERNF))
         U_MT_ITMSG("A nota fiscal e série informadas não existe para esta filial.",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,"Informe um numero de nota fiscal e série que exista.",1)
         _lRet := .F.
         Break
      EndIf

   ElseIf _cCampo == "TUDOOK"
       If M->C5_I_NFSED <> "S"
          M->C5_I_NFREF := Space(9)
          M->C5_I_SERNF := Space(3)
          Break
       EndIf

       If Empty(M->C5_I_NFREF)
         U_MT_ITMSG("Este pedido está configurado como SEDEX. O preenchimento da nota fiscal de referência é obrigatório.",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,"Preencha o numero da nota fiscal de referência SEDEX.",1)
         _lRet := .F.
         Break
      EndIf

      If Empty(M->C5_I_SERNF)
         U_MT_ITMSG("Este pedido está configurado como SEDEX. O preenchimento da série da nota fiscal de referência é obrigatório.",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,"Preencha a série da nota fiscal de referência SEDEX.",1)
         _lRet := .F.
         Break
      EndIf

      If ! SF1->(MsSeek(xFilial("SF1")+M->C5_I_NFREF+M->C5_I_SERNF))
         U_MT_ITMSG("A nota fiscal e série informadas não existe para esta filial.",'Atencao! (MT410TOK-'+ALLTRIM(STR(ProcLine()))+') Ped.: '+M->C5_NUM,"Informe um numero de nota fiscal e série que exista.",1)
         _lRet := .F.
      EndIf

    ElseIf _cCampo == "C5_I_NFSED"
       If M->C5_I_NFSED <> "S"
          M->C5_I_NFREF := Space(9)
          M->C5_I_SERNF := Space(3)
          Break
       EndIf
   EndIf

End Sequence

Return _lRet

/*
===============================================================================================================================
Programa----------: M410BDES
Autor-------------: Julio de Paula Paz
Data da Criacao---: 08/06/2022
===============================================================================================================================
Descrição---------: Busca o desconto por tonelada no cadastro ZBL.
===============================================================================================================================
Parametros--------: _cFilOrige = Filial de Origem
                    _cUF       = Estado
                    _cOperVend = Operação de Venda
                    _cCodMunic = Codigo do municipio
===============================================================================================================================
Retorno-----------: _nRet = Desconto por tonelada cadastrado na tabel ZBL.
===============================================================================================================================
*/
User Function M410BDES(_cFilOrige , _cUF , _cOperVend , _cCodMunic)
Local _nRet := 0
Local _cMesoReg := Space(6)
Local _cMicroReg := Space(6)

Begin Sequence

   CC2->(DbSetOrder(1)) // CC2_FILIAL+CC2_EST+CC2_CODMUN
   If CC2->(MsSeek(xFilial("CC2")+_cUF+_cCodMunic))
      _cMesoReg  := CC2->CC2_I_MESO // Meso região
      _cMicroReg := CC2->CC2_I_MICR // Micro região
   EndIf

   ZBL->(DbSetOrder(4)) // ZBL_FILIAL+ZBL_FILORI+ZBL_UF+ZBL_OPER+ZBL_CODMUN+ZBL_MESO+ZBL_MICRO

   ZBL->(MsSeek(xFilial("ZBL") + _cFilOrige + _cUF)) //+ _cOperVend + _cCodMunic))

   Do While ! ZBL->(Eof()) .And. ZBL->(ZBL_FILIAL+ZBL_FILORI+ZBL_UF) == ;     // +ZBL_OPER+ZBL_CODMUN) == ;
                                 xFilial("ZBL") + _cFilOrige + _cUF           // + _cOperVend + _cCodMunic

      //If ! Empty(_cOperVend) .And. ! Empty(_cCodMunic) .And. ! Empty(_cMesoReg) .And. ! Empty(_cMicroReg)
      If ! Empty(ZBL->ZBL_OPER) .And. ! Empty(ZBL->ZBL_CODMUN) .And. ! Empty(ZBL->ZBL_MESO) .And. ! Empty(ZBL->ZBL_MICRO)
         If ZBL->ZBL_OPER == _cOperVend .And. ZBL->ZBL_CODMUN == _cCodMunic .And. ZBL->ZBL_MESO == _cMesoReg .And. ZBL->ZBL_MICRO == _cMicroReg
            _nRet := ZBL->ZBL_DESCON
            Break
         EndIf
      EndIf

      //If ! Empty(_cOperVend) .And. ! Empty(_cCodMunic) .And. ! Empty(_cMesoReg) .And. Empty(_cMicroReg)
      If ! Empty(ZBL->ZBL_OPER) .And. ! Empty(ZBL->ZBL_CODMUN) .And. ! Empty(ZBL->ZBL_MESO) .And. Empty(ZBL->ZBL_MICRO)
         If ZBL->ZBL_OPER == _cOperVend .And. ZBL->ZBL_CODMUN == _cCodMunic .And. ZBL->ZBL_MESO == _cMesoReg     //.And. ZBL->ZBL_MICRO == _cMicroReg
            _nRet := ZBL->ZBL_DESCON
            Break
         EndIf
      EndIf

      //If ! Empty(_cOperVend) .And. ! Empty(_cCodMunic) .And. Empty(_cMesoReg) .And. ! Empty(_cMicroReg)
      If ! Empty(ZBL->ZBL_OPER) .And. ! Empty(ZBL->ZBL_CODMUN) .And. Empty(ZBL->ZBL_MESO) .And. ! Empty(ZBL->ZBL_MICRO)
         If ZBL->ZBL_OPER == _cOperVend .And. ZBL->ZBL_CODMUN == _cCodMunic .And. ZBL->ZBL_MICRO == _cMicroReg    // .And. ZBL->ZBL_MESO == _cMesoReg
            _nRet := ZBL->ZBL_DESCON
            Break
         EndIf
      EndIf

      //If ! Empty(_cOperVend) .And. ! Empty(_cCodMunic) .And. Empty(_cMesoReg) .And. Empty(_cMicroReg)
      If ! Empty(ZBL->ZBL_OPER) .And. ! Empty(ZBL->ZBL_CODMUN) .And. Empty(ZBL->ZBL_MESO) .And. Empty(ZBL->ZBL_MICRO)
         If ZBL->ZBL_OPER == _cOperVend .And. ZBL->ZBL_CODMUN == _cCodMunic       // .And. ZBL->ZBL_MICRO == _cMicroReg // .And. ZBL->ZBL_MESO == _cMesoReg
            _nRet := ZBL->ZBL_DESCON
            Break
         EndIf
      EndIf

      //If ! Empty(_cOperVend) .And. Empty(_cCodMunic)     //.And. Empty(_cMesoReg) .And. Empty(_cMicroReg)
      If ! Empty(ZBL->ZBL_OPER) .And. Empty(ZBL->ZBL_CODMUN)     //.And. Empty(_cMesoReg) .And. Empty(_cMicroReg)
         If ZBL->ZBL_OPER == _cOperVend                  // .And. ZBL->ZBL_CODMUN == _cCodMunic // .And. ZBL->ZBL_MICRO == _cMicroReg // .And. ZBL->ZBL_MESO == _cMesoReg
            _nRet := ZBL->ZBL_DESCON
            Break
         EndIf
      EndIf
//-------------------------------------------------------------------------
      If Empty(ZBL->ZBL_OPER) .And. ! Empty(ZBL->ZBL_CODMUN) .And.  ! Empty(ZBL->ZBL_MESO) .And.  Empty(ZBL->ZBL_MICRO)
         If ZBL->ZBL_CODMUN == _cCodMunic .And. ZBL->ZBL_MESO == _cMesoReg              // ZBL->ZBL_OPER == _cOperVend // .And. // .And. ZBL->ZBL_MICRO == _cMicroReg // .And. ZBL->ZBL_MESO == _cMesoReg
            _nRet := ZBL->ZBL_DESCON
            Break
         EndIf
      EndIf

      If Empty(ZBL->ZBL_OPER) .And. ! Empty(ZBL->ZBL_CODMUN) .And.  Empty(ZBL->ZBL_MESO) .And.  ! Empty(ZBL->ZBL_MICRO)
         If ZBL->ZBL_CODMUN == _cCodMunic .And. ZBL->ZBL_MICRO == _cMicroReg  // ZBL->ZBL_OPER == _cOperVend // .And. // .And. ZBL->ZBL_MICRO == _cMicroReg // .And. ZBL->ZBL_MESO == _cMesoReg
            _nRet := ZBL->ZBL_DESCON
            Break
         EndIf
      EndIf
//-------------------------------------------------------------------------
      //If Empty(_cOperVend) .And. ! Empty(_cCodMunic)    //.And. Empty(_cMesoReg) .And. Empty(_cMicroReg)
      If Empty(ZBL->ZBL_OPER) .And. ! Empty(ZBL->ZBL_CODMUN)    //.And. Empty(_cMesoReg) .And. Empty(_cMicroReg)
         If ZBL->ZBL_CODMUN == _cCodMunic               // ZBL->ZBL_OPER == _cOperVend // .And. // .And. ZBL->ZBL_MICRO == _cMicroReg // .And. ZBL->ZBL_MESO == _cMesoReg
            _nRet := ZBL->ZBL_DESCON
            Break
         EndIf
      EndIf

      //If Empty(_cOperVend) .And. Empty(_cCodMunic) .And. Empty(_cMesoReg) .And. Empty(_cMicroReg)
      If Empty(ZBL->ZBL_OPER) .And. Empty(ZBL->ZBL_CODMUN) .And. Empty(ZBL->ZBL_MESO) .And. Empty(ZBL->ZBL_MICRO)
         If Empty(ZBL->ZBL_OPER) .And. Empty(ZBL->ZBL_CODMUN) .And. Empty(ZBL->ZBL_MICRO) .And. Empty(ZBL->ZBL_MESO)
            _nRet := ZBL->ZBL_DESCON
            Break
         EndIf
      EndIf

      ZBL->(DbSkip())
   EndDo

End Sequence

Return _nRet

/*
===============================================================================================================================
Programa--------: U_MT_ITMSG()
Autor-----------: Alex Wallauer
Data da Criacao-: 21/09/2017
===============================================================================================================================
Descrição-------: Tratamento para as mensagens não dar erro na integração do RDC e via MSEXECAUTO()
===============================================================================================================================
Parametros--------: _cMens         - Texto a ser apresentado na mensagem.
                    _ctitu         - Texto com título da mensagem.
                    _csolu         - Texto a ser apresentado como solução.
                    _ntipo         - número para escolher estilo e figura da mensagem.
                    _nbotao        - botão ok (1) ou botão ok e cancela (2).
                    _nmenbot       - Mensagem botões (1) Ok/Cancela (2) Sim/Não.
                    _lHelpMvc      - .T. chama função Help do MVC, .F. exibe tela customizada para a função ITMSG..
                    _cbt1,_cbt2    - Ajusta texto dos botões se tiver diferente do default (texto personalizado).
                    _bMaisDetalhes - CodeBlock que será executado no botão "Mais Detalhes".
                    _cMaisDetalhes - Texto que será somando na mensagem de erro para MSEXECAUTO().
===============================================================================================================================
Retorno-----------: True ou False de acordo com botão ok/sim ou cancela/não escolhido
===============================================================================================================================
*/
User Function MT_ITMSG(_cMens,_cTitu,_cSolu,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes,_cMaisDetalhes)
LOCAL _lRetorno:=.T.
DEFAULT _cMens:=""
DEFAULT _cTitu:=""
DEFAULT _cSolu:=""
DEFAULT _cMaisDetalhes:=""

IF VALTYPE(_cSolu) <> "C"
   _cSolu:=""
ENDIF
IF VALTYPE(_cMaisDetalhes) <> "C"
   _cMaisDetalhes:=""
ENDIF

If TYPE("_lMsgEmTela") <> "L" .OR. _lMsgEmTela
   _lRetorno:=U_ITMSG(_cMens,_cTitu,_cSolu,_ntipo,_nbotao,_nmenbot,_lHelpMvc,_cbt1,_cbt2,_bMaisDetalhes)
Else
   If TYPE("_cAOMS074Vld") = "C"
      If TYPE("_cAOMS074") <> "C"
         _cAOMS074 := ""
      EndIf

      IF EMPTY(_cAOMS074Vld) .AND. !EMPTY(M->C5_NUM)
         IF !EMPTY(_cAOMS074)
            _cAOMS074Vld += '('+_cAOMS074+'/MT410TOK) PV: '+ALLTRIM(M->C5_NUM)+". "
         ELSE
            _cAOMS074Vld += '(MT410TOK) PV: '+ALLTRIM(M->C5_NUM)+". "
         ENDIF
      ENDIF
      _cMens:=STRTRAN(_cMens,"Clique em mais detalhes","")
      _cAOMS074Vld += _cTitu+": "+_cMens+". "
      IF !EMPTY(_cSolu)
          _cAOMS074Vld += "Solucao: "+_cSolu+". "
      ENDIF
      IF !EMPTY(_cMaisDetalhes)
          _cAOMS074Vld += "Detalhes: "+_cMaisDetalhes+". "
      ENDIF
   ENDIF
Endif

RETURN _lRetorno


/*
===============================================================================================================================
Programa----------: M410BDES
Autor-------------: Julio de Paula Paz
Data da Criacao---: 03/10/2024
===============================================================================================================================
Descrição---------: Realiza a exclusão do pedido de pallets vinculado ao pedido de vendas, para que seja gerado um novo
                    pedido de pallets com os dados atualizados.
===============================================================================================================================
Parametros--------: _cNrPdPale = Numero do pedido de pallets vinculado os pedido de vendas.
===============================================================================================================================
Retorno-----------: _lRet := .T. = Pedido de pallet excluido com sucesso.
                             .F. = Não foi possível excluir o pedido de pallet.
===============================================================================================================================
*/
Static Function MT410EXCPA(_cNrPdPale)
Local _lRet := .T.
Local _nRegSC5 := SC5->(Recno())
Local _nRegSC6 := SC6->(Recno())
Local _cFilOrigem, _cPedOrigem

Begin Sequence
   If Empty(_cNrPdPale)
      Break
   EndIf


   _aCabPV  :={}
   _aItemPV :={}
   _aItensPV:={}

   SC5->(DbSetOrder(1))
   If ! SC5->(MsSeek(xFilial("SC5")+_cNrPdPale))
      //_lRet := .F.
      Break
   EndIf

   Aadd( _aCabPV, { "C5_FILIAL"	    ,SC5->C5_FILIAL   , Nil}) //filial
   Aadd( _aCabPV, { "C5_NUM"        ,SC5->C5_NUM	  , Nil})
   Aadd( _aCabPV, { "C5_TIPO"	    ,SC5->C5_TIPO     , Nil}) //Tipo de pedido
   Aadd( _aCabPV, { "C5_I_OPER"	    ,SC5->C5_I_OPER   , Nil}) //Tipo da operacao
   Aadd( _aCabPV, { "C5_CLIENTE"    ,SC5->C5_CLIENTE  , NiL}) //Codigo do cliente
   Aadd( _aCabPV, { "C5_CLIENT"     ,SC5->C5_CLIENT	  , Nil})
   Aadd( _aCabPV, { "C5_LOJAENT"    ,SC5->C5_LOJAENT  , NiL}) //Loja para entrada
   Aadd( _aCabPV, { "C5_LOJACLI"    ,SC5->C5_LOJACLI  , NiL}) //Loja do cliente
   Aadd( _aCabPV, { "C5_EMISSAO"    ,SC5->C5_EMISSAO  , NiL}) //Data de emissao
   Aadd( _aCabPV, { "C5_TRANSP"     ,SC5->C5_TRANSP	  , Nil})
   Aadd( _aCabPV, { "C5_CONDPAG"    ,SC5->C5_CONDPAG  , NiL}) //Codigo da condicao de pagamanto*
   Aadd( _aCabPV, { "C5_VEND1"      ,SC5->C5_VEND1	  , Nil})
   Aadd( _aCabPV, { "C5_MOEDA"	    ,SC5->C5_MOEDA    , Nil}) //Moeda
   Aadd( _aCabPV, { "C5_MENPAD"     ,SC5->C5_MENPAD	  , Nil})
   Aadd( _aCabPV, { "C5_LIBEROK"    ,SC5->C5_LIBEROK  , NiL}) //Liberacao Total
   Aadd( _aCabPV, { "C5_TIPLIB"     ,SC5->C5_TIPLIB   , Nil}) //Tipo de Liberacao
   Aadd( _aCabPV, { "C5_TIPOCLI"    ,SC5->C5_TIPOCLI  , NiL}) //Tipo do Cliente
   Aadd( _aCabPV, { "C5_I_NPALE"    ,SC5->C5_I_NPALE  , NiL}) //Numero que originou a pedido de palete
   Aadd( _aCabPV, { "C5_I_PEDPA"    ,SC5->C5_I_PEDPA  , NiL}) //Pedido Refere a um pedido de Pallet
   Aadd( _aCabPV, { "C5_I_DTENT"    ,SC5->C5_I_DTENT  , Nil}) //Dt de Entrega // SC5->C5_I_DTENT
   Aadd( _aCabPV, { "C5_I_TRCNF"    ,SC5->C5_I_TRCNF  , Nil})
   Aadd( _aCabPV, { "C5_I_OBCOP" 	,SC5->C5_I_OBCOP  , Nil})
   Aadd( _aCabPV, { "C5_I_OBPED" 	,SC5->C5_I_OBPED  , Nil})
   Aadd( _aCabPV, { "C5_I_BLPRC"    ,SC5->C5_I_BLPRC  , Nil})
   Aadd( _aCabPV, { "C5_I_BLCRE"    ,SC5->C5_I_BLCRE  , Nil})
   Aadd( _aCabPV, { "C5_I_FILFT"    ,SC5->C5_I_FILFT  , Nil})
   Aadd( _aCabPV, { "C5_I_FLFNC"    ,SC5->C5_I_FLFNC  , Nil})
   Aadd( _aCabPV, { "C5_I_BLCRE"    ,SC5->C5_I_BLCRE  , Nil})
   Aadd( _aCabPV, { "C5_I_TIPCA"    ,SC5->C5_I_TIPCA  , Nil})
   Aadd( _aCabPV, { "C5_MENNOTA"    ,SC5->C5_MENNOTA  , Nil})
   Aadd( _aCabPV, { "C5_MENPAD"     ,SC5->C5_MENPAD   , Nil})
   Aadd( _aCabPV, { "C5_I_PODES"    ,SC5->C5_NUM      , Nil})
   Aadd( _aCabPV, { "C5_I_BLPRC"    ,SC5->C5_I_BLPRC  , Nil})
   Aadd( _aCabPV, { "C5_I_DTLIB"    ,SC5->C5_I_DTLIB  , Nil})
   Aadd( _aCabPV, { "C5_I_IDPED"    ,SC5->C5_I_IDPED  , Nil})
   Aadd( _aCabPV, { "C5_ORIGEM "    ,SC5->C5_ORIGEM   , Nil})
   Aadd( _aCabPV, { "C5_I_DTAIM"    ,SC5->C5_I_DTAIM  , Nil})
   Aadd( _aCabPV, { "C5_I_HORAI"    ,SC5->C5_I_HORAI  , Nil})
   Aadd( _aCabPV, { "C5_I_DATAA"    ,SC5->C5_I_DATAA  , Nil})
   Aadd( _aCabPV, { "C5_I_HORAA"    ,SC5->C5_I_HORAA  , Nil})
   Aadd( _aCabPV, { "C5_I_DTLIP"    ,SC5->C5_I_DTLIP  , Nil})
   Aadd( _aCabPV, { "C5_I_MLIBP"    ,SC5->C5_I_MLIBP  , Nil})
   Aadd( _aCabPV, { "C5_I_DTAVA"    ,SC5->C5_I_DTAVA  , Nil})
   Aadd( _aCabPV, { "C5_I_HRAVA"    ,SC5->C5_I_HRAVA  , Nil})
   Aadd( _aCabPV, { "C5_I_USRAV"    ,SC5->C5_I_USRAV  , Nil})
   Aadd( _aCabPV, { "C5_I_LIBCA"    ,SC5->C5_I_LIBCA  , Nil})
   Aadd( _aCabPV, { "C5_I_LIBCT"    ,SC5->C5_I_LIBCT  , Nil})
   Aadd( _aCabPV, { "C5_I_LIBL "    ,SC5->C5_I_LIBL   , Nil})
   Aadd( _aCabPV, { "C5_I_LIBCV"    ,SC5->C5_I_LIBCV  , Nil})
   Aadd( _aCabPV, { "C5_I_LIBCD"    ,SC5->C5_I_LIBCD  , Nil})
   Aadd( _aCabPV, { "C5_I_BLCRE"    ,SC5->C5_I_BLCRE  , Nil})
   Aadd( _aCabPV, { "C5_I_MOTBL"    ,SC5->C5_I_MOTBL  , Nil})
   Aadd( _aCabPV, { "C5_I_DTLIC"    ,SC5->C5_I_DTLIC  , Nil})
   Aadd( _aCabPV, { "C5_I_PLIBP"    ,SC5->C5_I_PLIBP  , Nil})
   Aadd( _aCabPV, { "C5_I_ULIBP"    ,SC5->C5_I_ULIBP  , Nil})
   Aadd( _aCabPV, { "C5_I_VLIBP"    ,SC5->C5_I_VLIBP  , Nil})
   Aadd( _aCabPV, { "C5_I_MOTLP"    ,SC5->C5_I_MOTLP  , Nil})
   Aadd( _aCabPV, { "C5_I_MOTLB"    ,SC5->C5_I_MOTLB  , Nil})
   Aadd( _aCabPV, { "C5_I_QLIBP"    ,SC5->C5_I_QLIBP  , Nil})
   Aadd( _aCabPV, { "C5_I_VLIBB"    ,SC5->C5_I_VLIBB  , Nil})
   Aadd( _aCabPV, { "C5_I_QLIBB"    ,SC5->C5_I_QLIBB  , Nil})
   Aadd( _aCabPV, { "C5_I_CLILP"    ,SC5->C5_I_CLILP  , Nil})
   Aadd( _aCabPV, { "C5_I_CLILB"    ,SC5->C5_I_CLILB  , Nil})
   Aadd( _aCabPV, { "C5_I_LLIBB"    ,SC5->C5_I_LLIBB  , Nil})
   Aadd( _aCabPV, { "C5_I_ULIBB"    ,SC5->C5_I_ULIBB  , Nil})
   Aadd( _aCabPV, { "C5_I_LLIBP"    ,SC5->C5_I_LLIBP  , Nil})
   Aadd( _aCabPV, { "C5_I_HLIBP"    ,SC5->C5_I_HLIBP  , Nil})
   Aadd( _aCabPV, { "C5_I_FILOR"    ,SC5->C5_I_FILOR  , Nil})
   Aadd( _aCabPV, { "C5_I_PEDOR"   , SC5->C5_I_PEDOR  , Nil})
   Aadd( _aCabPV, { "C5_I_DTRAN"    ,SC5->C5_I_DTRAN  , Nil})
   Aadd( _aCabPV, { "C5_I_UTRAN"    ,SC5->C5_I_UTRAN  , Nil})
   Aadd( _aCabPV, { "C5_I_MTRAN"    ,SC5->C5_I_MTRAN  , Nil})
   Aadd( _aCabPV, { "C5_I_HORP "    ,SC5->C5_I_HORP   , Nil})
   Aadd( _aCabPV, { "C5_I_AGEND"    ,SC5->C5_I_AGEND  , Nil})
   Aadd( _aCabPV, { "C5_I_CHPCL"    ,SC5->C5_I_CHPCL  , Nil})
   Aadd( _aCabPV, { "C5_I_DOCA "    ,SC5->C5_I_DOCA   , Nil})
   Aadd( _aCabPV, { "C5_I_TRCNF"    ,SC5->C5_I_TRCNF  , Nil})
   Aadd( _aCabPV, { "C5_I_FLFNC"    ,SC5->C5_I_FLFNC  , Nil})
   Aadd( _aCabPV, { "C5_I_OBSAV"    ,SC5->C5_I_OBSAV  , Nil})
   Aadd( _aCabPV, { "C5_I_FILFT"    ,SC5->C5_I_FILFT  , Nil})
   Aadd( _aCabPV, { "C5_I_PDFT "    ,SC5->C5_I_PDFT   , Nil})
   Aadd( _aCabPV, { "C5_I_PDPR "    ,SC5->C5_I_PDPR   , Nil})
   Aadd( _aCabPV, { "C5_TPFRETE"    ,SC5->C5_TPFRETE  , Nil})
   Aadd( _aCabPV, { "C5_I_PSORI"    ,SC5->C5_I_PSORI  , Nil})
   Aadd( _aCabPV, { "C5_I_TAB"      ,SC5->C5_I_TAB    , Nil})
   Aadd( _aCabPV, { "C5_I_PEDDW"    ,SC5->C5_I_PEDDW  , Nil})
   Aadd( _aCabPV, { "C5_I_TPVEN"    ,SC5->C5_I_TPVEN  , Nil})
   Aadd( _aCabPV, { "C5_VEND2"      ,SC5->C5_VEND2	  , Nil})
   Aadd( _aCabPV, { "C5_VEND3"      ,SC5->C5_VEND3	  , Nil})
   Aadd( _aCabPV, { "C5_VEND4"      ,SC5->C5_VEND4	  , Nil})
   Aadd( _aCabPV, { "C5_VEND5"      ,SC5->C5_VEND5	  , Nil})
   Aadd( _aCabPV, { "C5_I_SENHA"    ,SC5->C5_I_SENHA  , Nil})
   Aadd( _aCabPV, { "C5_I_NRZAZ"    ,SC5->C5_I_NRZAZ  , Nil})
   Aadd( _aCabPV, { "C5_I_LIBC"     ,SC5->C5_I_LIBC	  , Nil})
   Aadd( _aCabPV, { "C5_I_OPTRIN"   ,SC5->C5_I_OPTRIN , Nil}) // Tipo PV na operacao trian
   Aadd( _aCabPV, { "C5_I_PVREM"    ,SC5->C5_I_PVREM  , Nil}) // Pedido de Remessa
   Aadd( _aCabPV, { "C5_I_PVFAT"    ,SC5->C5_I_PVFAT  , Nil}) // Pedido de FAturamento
   Aadd( _aCabPV, { "C5_I_CLIEN"    ,SC5->C5_I_CLIEN  , Nil}) // Cli Remessa
   Aadd( _aCabPV, { "C5_I_LOJEN"    ,SC5->C5_I_LOJEN  , Nil}) // Loj Remessa

   SC6->(Dbsetorder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
   SC6->(DbSeek(xFilial("SC6")+_cNrPdPale))
   Do While ! SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == xFilial("SC6") + _cNrPdPale

      _aItemPV:={}
      AAdd( _aItemPV , { "LINPOS"     ,"C6_ITEM"       , SC6->C6_ITEM }) //  Informa a posição do item
      AAdd( _aItemPV , { "AUTDELETA"  ,"N"             , Nil }) // Informa se o item será ou não excluído.
      AAdd( _aItemPV , { "C6_FILIAL"  ,SC6->C6_FILIAL  , Nil }) // FILIAL
      AAdd( _aItemPV , { "C6_NUM"     ,SC6->C6_NUM     , Nil }) // Num. Pedido
      AAdd( _aItemPV , { "C6_ITEM"    ,SC6->C6_ITEM    , Nil }) // Numero do Item no Pedido
      AAdd( _aItemPV , { "C6_PRODUTO" ,SC6->C6_PRODUTO , Nil }) // Codigo do Produto
      AAdd( _aItemPV , { "C6_UNSVEN"  ,SC6->C6_UNSVEN  , Nil }) // Quantidade Vendida 2 un
      AAdd( _aItemPV , { "C6_QTDVEN"  ,SC6->C6_QTDVEN  , Nil }) // Quantidade Vendida
      AAdd( _aItemPV , { "C6_PRCVEN"  ,SC6->C6_PRCVEN  , Nil }) // Preco Unitario Liquido
      AAdd( _aItemPV , { "C6_PRUNIT"  ,SC6->C6_PRUNIT  , Nil }) // Preco Unitario Liquido
      AAdd( _aItemPV , { "C6_ENTREG"  ,SC6->C6_ENTREG  , Nil }) // Data da Entrega
      AAdd( _aItemPV , { "C6_LOJA"    ,SC6->C6_LOJA	   , Nil })
      AAdd( _aItemPV , { "C6_SUGENTR" ,SC6->C6_SUGENTR , Nil }) // Data da Entrega
      AAdd( _aItemPV , { "C6_VALOR"   ,SC6->C6_VALOR   , Nil }) // valor total do item // SC6->C6_VALOR
      AAdd( _aItemPV , { "C6_UM"      ,SC6->C6_UM      , Nil }) // Unidade de Medida Primar.
      AAdd( _aItemPV , { "C6_TES"     ,SC6->C6_TES     , Nil })
      AAdd( _aItemPV , { "C6_LOCAL"   ,SC6->C6_LOCAL   , Nil }) // Almoxarifado
      AAdd( _aItemPV , { "C6_CF"      ,SC6->C6_CF	   , Nil })
      AAdd( _aItemPV , { "C6_DESCRI"  ,SC6->C6_DESCRI  , Nil }) // Descricao
      AAdd( _aItemPV , { "C6_QTDLIB"  ,SC6->C6_QTDLIB  , Nil }) // Quantidade Liberada
      AAdd( _aItemPV , { "C6_PEDCLI"  ,SC6->C6_PEDCLI  , Nil })
      AAdd( _aItemPV , { "C6_I_BLPRC" ,SC6->C6_I_BLPRC , Nil })
      AAdd( _aItemPV , { "C6_I_QPALT" ,SC6->C6_I_QPALT , Nil }) // Quantidade de Pallets
      Aadd( _aItemPV,  { "C6_I_USER " ,SC6->C6_I_USER , Nil})
      Aadd( _aItemPV,  { "C6_I_LIBPC" ,SC6->C6_I_LIBPC, Nil})
      Aadd( _aItemPV,  { "C6_I_DLIBP" ,SC6->C6_I_DLIBP, Nil})
      Aadd( _aItemPV,  { "C6_I_PLIBP" ,SC6->C6_I_PLIBP, Nil})
      Aadd( _aItemPV,  { "C6_I_ULIBP" ,SC6->C6_I_ULIBP, Nil})
      Aadd( _aItemPV,  { "C6_I_VLIBP" ,SC6->C6_I_VLIBP, Nil})
      Aadd( _aItemPV,  { "C6_I_MOTLP" ,SC6->C6_I_MOTLP, Nil})
      Aadd( _aItemPV,  { "C6_I_QTLIP" ,SC6->C6_I_QTLIP, Nil})
      Aadd( _aItemPV,  { "C6_I_CLILP" ,SC6->C6_I_CLILP, Nil})
      Aadd( _aItemPV,  { "C6_I_CLILB" ,SC6->C6_I_CLILB, Nil})
      Aadd( _aItemPV,  { "C6_I_VLIBB" ,SC6->C6_I_VLIBB, Nil})
      Aadd( _aItemPV,  { "C6_I_QLIBB" ,SC6->C6_I_QLIBB, Nil})
      Aadd( _aItemPV,  { "C6_I_LLIBP" ,SC6->C6_I_LLIBP, Nil})
      Aadd( _aItemPV,  { "C6_I_LLIBB" ,SC6->C6_I_LLIBB, Nil})
      Aadd( _aItemPV,  { "C6_I_MOTLB" ,SC6->C6_I_MOTLB, Nil})
      Aadd( _aItemPV,  { "C6_I_PLIBB" ,SC6->C6_I_PLIBB, Nil})
      Aadd( _aItemPV,  { "C6_I_DLIBB" ,SC6->C6_I_DLIBB, Nil})
      Aadd( _aItemPV,  { "C6_COMIS1"  ,SC6->C6_COMIS1, Nil})
      Aadd( _aItemPV,  { "C6_COMIS2"  ,SC6->C6_COMIS2, Nil})
      Aadd( _aItemPV,  { "C6_COMIS3"  ,SC6->C6_COMIS3, Nil})
      Aadd( _aItemPV,  { "C6_COMIS4"  ,SC6->C6_COMIS4, Nil})
      Aadd( _aItemPV,  { "C6_COMIS5"  ,SC6->C6_COMIS5, Nil})
      Aadd( _aItemPV,  { "C6_I_PDESC" ,SC6->C6_I_PDESC, Nil})
      Aadd( _aItemPV,  { "C6_I_VLTAB" ,SC6->C6_I_VLTAB, Nil})
      Aadd( _aItemPV,  { "C6_ITEMPC"  ,SC6->C6_ITEMPC, Nil})

      AAdd( _aItensPV ,_aItemPV )

      SC6->(DbSkip())
   EndDo

   _cFilOrigem := SC5->C5_FILIAL
   _cPedOrigem := SC5->C5_I_NPALE

   lMsErroAuto:=.F.

   MSExecAuto( {|x,y,z| Mata410(x,y,z) } , _aCabPV , _aItensPV, 5 )

   If lMsErroAuto
      _cNomeArqLog := "Pedido_de_Pallet_"+AllTrim(_cNrPdPale)+"_"+DTos(Date())+"_"+StrTran(Time(),":","_")+".log"
      _cMsgErro := MostraErro("\system\", _cNomeArqLog)
      //U_ItConOut(_cMsgErro)
      _lRet := .F.
   Else
      //=========================================================================================================
      // Confirmado a exclusão do pedido de pallet, remove o vinculo do pedido que originou o pedido de pallet.
      //=======================================================================================================
      If SC5->( DBSeek( _cFilOrigem + _cPedOrigem ) )
         SC5->( RecLock( 'SC5' , .F. ) )
         SC5->C5_I_NPALE := ''
         SC5->C5_I_PEDPA := ''
         SC5->C5_I_PEDGE := '' //É o Pedido Gerador de Pallet
         SC5->( MsUnlock() )
      EndIf
   EndIf

End Sequence

SC5->(DbGoto(_nRegSC5))
SC6->(DbGoto(_nRegSC6))

Return _lRet

/*
===============================================================================================================================
Programa----------: MT410VLJUS
Autor-------------: Julio de Paula Paz
Data da Criacao---: 13/05/2025
===============================================================================================================================
Descrição---------: Valida a digitação da justificativa de alteração de tipo de agendamenteo e alteração de data de entrega.
===============================================================================================================================
Parametros--------: _cDado  = Informação a ser validada
                    _cCampo = Campo que chamou a validação.
===============================================================================================================================
Retorno-----------: _lRet := .T. = Dados corretos
                             .F. = Erro nos dados
===============================================================================================================================
*/
Static Function MT410VLJUS(_cDado, _cCampo)
Local _lRet := .T.

Begin Sequence 
   /*
   If (_lAltData .And. Empty(_cDado)) .Or. (_lAltAgen .And. Empty(_cDado))
      U_MT_ITMSG("O código de justificativa não foi informado.","Atenção",,1)
      _lRet := .F.
      Break 
   EndIf 
   */

   If ! Empty(_cDado)
      ZY5->(DbSetOrder(1))
      If ! ZY5->(MsSeek(xFilial("ZY5")+_cDado))
         U_MT_ITMSG("O código de justificativa informado não existe.","Atenção",,1)
         _lRet := .F.
      Else 
         If _cCampo == "C5_I_AGEND"
            _cObseAG := ZY5->ZY5_DESCR
         Else 
            _cObseDE := ZY5->ZY5_DESCR
         EndIf 
      EndIf 
   EndIf 
End Sequence 

Return _lRet 


