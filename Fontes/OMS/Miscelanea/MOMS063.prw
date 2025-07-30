/*
===============================================================================================================================
                          ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |    Data    |                                             Motivo                                          
-------------------------------------------------------------------------------------------------------------------------------
              |            |
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include "PROTHEUS.CH"
#Include "TopConn.ch"

/*
===============================================================================================================================
Programa----------: MOMS063
Autor-------------: Julio de Paula Paz
Data da Criacao---: 22/12/2021
===============================================================================================================================
Descri��o---------: Ajusta rede de acordo com cadastro de desconto contratual. Chamado 30177.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS063()

Begin Sequence 

   If ! U_ITMSG("Confirma os ajutes da Rede com base no cadastro de desconto contratual?","Aten��o" , , ,2, 2)
      Break 
   EndIf 

   Processa( {|| U_MOMS063P() }, "Aguarde...", "Ajuste Rede x Desconto Contratual...",.F.)

   U_ITMSG("Processamento Finalizado...","Aten��o", , 2)

End Sequence 

Return Nil

/*
===============================================================================================================================
Programa----------: MOMS063
Autor-------------: Julio de Paula Paz
Data da Criacao---: 22/12/2021
===============================================================================================================================
Descri��o---------: L� o cadastro de Redes, verifica se h� desconto contratual e ajusta a tabela.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MOMS063P()
Local _nI 
Local _cQry 
Local _nTotRegs 

Begin Sequence 

   ACY->(DbGoTop())

   _nTotRegs := ACY->(RecCount())

   ProcRegua(_nTotRegs)

   ACY->(DbGoTop())
   _nI := 1

   Do While ! ACY->(Eof())
      IncProc("Processando registros cadastro Grupo de Vendas: " + StrZero(_nI,8) +" / " + StrZero(_nTotRegs,8) )
      
      _cQry := " SELECT Count(*) AS TOTREGS "
      _cQry += " FROM " + RetSqlName("ZAZ") + " ZAZ "
      _cQry += " WHERE ZAZ.D_E_L_E_T_ = ' ' "
      _cQry += " AND ZAZ_GRPVEN = '" + ACY->ACY_GRPVEN +"' "

      If Select("QRYZAZ") > 0
         QRYZAZ->(DbCloseArea())
      EndIf
      
      DbUseArea( .T. , "TOPCONN" , TcGenQry(,, _cQry ) , "QRYZAZ" , .T., .F. )

      ACY->(RecLock("ACY",.F.))
      If QRYZAZ->TOTREGS > 0
         ACY->ACY_I_DESC := "S" // S=Sim = Possui desconto contratual 
      Else 
         ACY->ACY_I_DESC := "N" // N=Nao = possui desconto contratual
      EndIf 
      ACY->(MsUnLock())

      ACY->(DbSkip())
      _nI += 1

   EndDo 

End Sequence 

If Select("QRYZAZ") > 0
   QRYZAZ->(DbCloseArea())
EndIf

Return Nil
