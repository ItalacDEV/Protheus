/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------

===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'

/*
===============================================================================================================================
Programa----------: MOMS051
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 14/04/2020
===============================================================================================================================
Descrição---------: Rotina responsável por aprovar os prospects na tabela SZX.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
USER FUNCTION MOMS051()
    Local lSchedule := (Select("SX3") == 0)
    Local aTabelas  := {"SZX", "SA3"}

    If lSchedule
        RPCSetType(3)
        RpcSetEnv("01","01" ,,,, "SCHEDULE_APROVACAO_PROSPECT", aTabelas)
        sleep( 5000 )
        U_ItConOut("MOMS051 - Iniciando schedule de aprovacao de prospect")
        MOMS051P()
        U_ItConOut("MOMS051 - Processo de aprovacao de prospect finalizado")
        RPCClearEnv()
    ELSE
        U_ItConOut("MOMS051 - Iniciando schedule de aprovacao de prospect")
        MOMS051P()
        U_ItConOut("MOMS051 - Processo de aprovacao de prospect finalizado")
    Endif

RETURN

/*
===============================================================================================================================
Programa----------: MOMS051C
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 14/04/2020
===============================================================================================================================
Descrição---------: Função responsável por pegar o CGC dos prospects pendentes na tabela SZX
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _RECN
===============================================================================================================================
*/
STATIC FUNCTION MOMS051C()
    Local _RECN     := {}
    Local _cQuery    := ""
    Local _cAlias    := GetNextAlias()
    
    U_ItConOut("MOMS051C - Buscando por prospects pendentes . . .")

    _cQuery := " SELECT X.R_E_C_N_O_ AS RECNO FROM " + RetSqlName("SZX") + " X "
    _cQuery += " INNER JOIN " + RetSqlName("SA3") + " S "
    _cQuery += " ON X.ZX_VEND = S.A3_COD "
    _cQuery += " AND S.A3_I_VBROK = 'B' "
    _cQuery += " AND S.A3_MSBLQL  = '2' "
    _cQuery += " AND S.A3_I_TIPV = 'V' "
    _cQuery += " AND S.D_E_L_E_T_  = ' ' "
    _cQuery += " AND X.ZX_STATUS = 'A' "
    _cQuery += " AND X.D_E_L_E_T_  = ' ' "

    DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )

    DBSelectArea(_cAlias)

    WHILE (_cAlias)->(!EOF())
        Aadd(_RECN, (_cAlias)->RECNO)
        (_cAlias)->(DbSkip())
    ENDDO

    (_cAlias)->(dBCloseArea())

    U_ItConOut("MOMS051C - Total de registro pendentes: " + cValToChar(Len(_RECN)))

RETURN _RECN

/*
===============================================================================================================================
Programa----------: MOMS051P
Autor-------------: Jonathan Everton Torioni de Oliveira
Data da Criacao---: 14/04/2020
===============================================================================================================================
Descrição---------: Função responsável por aprovar os prospects pendentes
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _RECN
===============================================================================================================================
*/
STATIC FUNCTION MOMS051P()
    Local _nX       := 0
    Local _nCont    := 0
    Local _RECN     := MOMS051C()

    DbSelectArea("SZX")
    SZX->(DbSetOrder(1))

    FOR _nX := 1 TO Len(_RECN)
        SZX->(DBGOTO(_RECN[_nX]))
        RecLock("SZX", .F.)
        SZX->ZX_STATUS := "L"
        _nCont++
    NEXT

    SZX->(MsUnlock())
    SZX->(DbCloseArea())
    U_ItConOut("MOMS051C - Total de prospects efetivados: " + cValToChar(_nCont))

RETURN