/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data     |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 09/08/2021 | Tratamento para o novo campo Z07_ORIGEM. Chamado 36432 
-------------------------------------------------------------------------------------------------------------------------------
===============================================================================================================================
*/

#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"

/*
===============================================================================================================================
Programa----------: MOMS042
Autor-------------: Josué Danich Prestes
Data da Criacao---: 08/04/2019
===============================================================================================================================
Descrição---------: Altera planejamento logístico de pedidos de vendas - Chamado 28694 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS042()

//Valida se pedido não está  com nota emitida
If !Empty(SC5->C5_NOTA) 

    u_itmsg("Pedido já foi faturado","Atenção",,1)
    Return

Endif

//Valida se pedido não está  em carga
DAI->(Dbsetorder(4)) //DAI_FILIAL+DAI_PEDIDO
If DAI->(Dbseek(SC5->C5_FILIAL+SC5->C5_NUM)) 

    u_itmsg("Pedido já está em carga","Atenção",,1)
    Return

Endif

//Verifica permissão de ajuste de bloqueio logístico
ZZL->(Dbsetorder(3))
If !(ZZL->(Dbseek(xFilial("ZZL") + RetCodUsr()))) .OR. ZZL->ZZL_PVLOG != "S"

   	u_itmsg("Usuário sem permissão para Definir Pedido em Planejamento Logístico","Atenção",,1)    	
    Return

Endif

If SC5->C5_I_BLOG == "S" .AND. u_itmsg("Retirar Pedido do Planejamento Logístico " + SC5->C5_NUM + "?","Atenção",,2,2,2)

    U_MOMS042P("N")
    Return

Endif

If SC5->C5_I_BLOG != "S" .AND. u_itmsg("Definir Pedido em Planejamento Logístico " + SC5->C5_NUM + "?","Atenção",,2,2,2)

    U_MOMS042P("S")
    Return

Endif

Return

/*
===============================================================================================================================
Programa----------: MOMS042P
Autor-------------: Josué Danich Prestes
Data da Criacao---: 08/04/2019
===============================================================================================================================
Descrição---------: Grava flag de planejamento logístico
===============================================================================================================================
Parametros--------: _cgrv - string a gravar na flag
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS042P(_cgrv)

Local _nposi := SC5->(Recno())
Local _corig := SC5->C5_I_BLOG

BEGIN TRANSACTION

//Ajusta bloqueio no pedido posicionado
Reclock("SC5",.F.)
SC5->C5_I_BLOG := _cgrv
SC5->(Msunlock())

//Grava o log do ajuste de bloqueio
If _corig != _cgrv

    MOMS042L(_corig)

Endif

//Marca pedidos vinculados
If !empty(SC5->C5_I_PEVIN)

    SC5->(Dbsetorder(1))
    If SC5->(Dbseek(xfilial("SC5")+SC5->C5_I_PEVIN))

        _corig := SC5->C5_I_BLOG

        Reclock("SC5",.F.)
        SC5->C5_I_BLOG := _cgrv
        SC5->(Msunlock())

        //Grava o log do ajuste de bloqueio
        If _corig != _cgrv

            MOMS042L(_corig)

        Endif

    Endif

    SC5->(Dbgoto(_nposi))

Endif

//Marca pedidos com vinculo de operação triangular
If !empty(SC5->C5_I_PVREM) .AND. SC5->C5_I_PVREM != SC5->C5_NUM

    SC5->(Dbsetorder(1))
    If SC5->(Dbseek(xfilial("SC5")+SC5->C5_I_PVREM))

        _corig := SC5->C5_I_BLOG

        Reclock("SC5",.F.)
        SC5->C5_I_BLOG := _cgrv
        SC5->(Msunlock())

        //Grava o log do ajuste de bloqueio
        If _corig != _cgrv

            MOMS042L(_corig)

        Endif

    Endif

    SC5->(Dbgoto(_nposi))

Endif

//Marca pedidos com vinculo de operação triangular
If !empty(SC5->C5_I_PVFAT) .AND. SC5->C5_I_PVFAT != SC5->C5_NUM

    SC5->(Dbsetorder(1))
    If SC5->(Dbseek(xfilial("SC5")+SC5->C5_I_PVFAT))

        Reclock("SC5",.F.)
        SC5->C5_I_BLOG := _cgrv
        SC5->(Msunlock())
    Endif

    SC5->(Dbgoto(_nposi))

Endif

END TRANSACTION

Return

/*
===============================================================================================================================
Programa----------: MOMS042L
Autor-------------: Josué Danich Prestes
Data da Criacao---: 08/04/2019
===============================================================================================================================
Descrição---------: Grava log de ajuste de flag de planejamento logístico
===============================================================================================================================
Parametros--------: _corig - string original do pedido alterado
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MOMS042L(_corig)

Z07->( RecLock( "Z07" , .T. ) )
						
Z07->Z07_FILIAL		:= xFilial("Z07")
Z07->Z07_ALIAS		:= 'SC5'
Z07->Z07_ORDEM		:= 1
Z07->Z07_CHAVE		:= SC5->C5_FILIAL+SC5->C5_NUM
Z07->Z07_OPCAO		:= 'B'
Z07->Z07_CAMPO		:= 'C5_I_BLOG'
Z07->Z07_CONORG		:= _corig
Z07->Z07_CONALT		:= SC5->C5_I_BLOG
Z07->Z07_CODUSU		:= RetCodUsr()
Z07->Z07_DATA		:= Date()
Z07->Z07_HORA		:= time()
Z07->Z07_IFILIA		:= SC5->C5_FILIAL
Z07->Z07_INUM		:= SC5->C5_NUM
IF Z07->(FIELDPOS("Z07_ORIGEM")) <> 0
   Z07->Z07_ORIGEM := "MOMS042"
ENDIF
											
Z07->( MsUnLock() )

Return
