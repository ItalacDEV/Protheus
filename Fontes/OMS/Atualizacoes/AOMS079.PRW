/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor  |    Data    |                                             Motivo                                           
------------------------------------------------------------------------------------------------------------------------------- 
Julio Paz     | 08/06/2017 | Alterações da rotina para gravação do campo hora de emissão. Chamado: 20362.                 
------------------------------------------------------------------------------------------------------------------------------- 
Josué Danich  | 11/06/2019 | Ajustes para loboguara - Chamado 29593
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 14/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
-------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 27/04/2021 | Aterar Rotina para enviar para RDC: Peso variavel=S ou N, peso maximo e peso minimo.Chamado 36404
-------------------------------------------------------------------------------------------------------------------------------
Jerry         | 11/08/2023 | Adicionado leitura de Produto do Tipo PP.Chamado 44717
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: AOMS079
Autor-------------: Julio de Paula Paz
Data da Criacao---: 03/10/2016
===============================================================================================================================
Descrição---------: Rotina de gravação dos dados do produto(Carga Inicial)  Chamado 16681.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/  
User Function AOMS079() 
Local _cQry
Local _nI 
Local _nnj	:= 0
Local _aOrd := SaveOrd({"SX3","ZFI","ZZM","SA2","SB1"})   
Local _cCodEmpWS := U_ITGETMV( 'IT_EMPWEBSE' , '000001' )
Local _nEmpMax, _nQtdLastro
Local _cPesoVar := "N", _nPesoMin := 0, _nPesoMax := 0

Begin Sequence
   If ! u_itmsg("Confirma a gravação dos dados do produto tabela SB1, na tabela ZFI de envio de dados da integração Webservice?","Atenção",,2,2,2)
      Break
   EndIf
   
   //================================================================================
   // Monta query de dados dos clientes ativos
   //================================================================================   
   _cQry := " SELECT SB1.R_E_C_N_O_ AS NRECNO "
   _cQry += " FROM "+RetSqlName("SB1")+" SB1" 
   _cQry += " WHERE SB1.D_E_L_E_T_ <> '*' AND B1_TIPO IN ('PA','UN','PP') AND B1_MSBLQL = '2' "    // Não deletado, apenas produto acabado e unitizador.
   
   If Select("QRYSB1") > 0
      QRYSB1->( DbCloseArea())
   EndIf
           
   _cQry := ChangeQuery(_cQry) 
   DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry), "QRYSB1", .F., .T.)
   
   If QRYSB1->(Eof()) .Or. QRYSB1->(Bof())
      Break
   EndIf   
                     
   //================================================================================
   // Cria as variáveis de memória com seus respectivos incializadores padrão
   //================================================================================
   _acamps := ZFI->(Dbstruct())
   For _nnj := 1 to len(_acamps)
      &("M->"+alltrim(_acamps[_nnj][1])) := CriaVar(alltrim(_acamps[_nnj][1]))
   Next

   //================================================================================
   // Grava os dados da tabela SB1 de clientes ativos na tabela ZFI
   //================================================================================
   SA2->(DbSetOrder(3))
   QRYSB1->( DbGotop() )
   
   Do While ! QRYSB1->(Eof())  
      SB1->(DbGoTo(QRYSB1->NRECNO))

      ZZM->(DbGoTop())      

      Do While ! ZZM->(Eof())
         If ! SA2->(DbSeek(xFilial("SA2")+ZZM->ZZM_CGC))
            ZZM->(DbSkip())
            Loop
         EndIf
         
         ZFI->(DbSetOrder(3)) 
         If ZFI->(DbSeek(xFilial("ZFI")+SB1->B1_COD+SA2->A2_CGC+"N"))
            ZFI->(RecLock("ZFI",.F.))
         Else
            ZFI->(RecLock("ZFI",.T.))    
         EndIf
      
         For _nI := 1 To ZFI->(FCount())
             &("ZFI->"+ZFI->(FieldName(_nI))) := &("M->"+ZFI->(FieldName(_nI)))      
         Next             
      
         _nEmpMax := 0      
         _nQtdLastro := 0
         
         If SB5->(DbSeek(xFilial("SB5")+SB1->B1_COD))
            _nEmpMax := SB5->B5_EMPMAX  
            _nQtdLastro := 1 
         EndIf

         If SB1->B1_I_PCCX > 0 // b1_i_pccx  // SB1->B1_I_FTMIN > 0 .Or. SB1->B1_I_FTMAX > 0
            _cPesoVar := "S"
            _nPesoMin := SB1->B1_I_FTMIN
            _nPesoMax := SB1->B1_I_FTMAX         
         Else 
            _cPesoVar := "N"
         EndIf 

         ZFI->ZFI_FILIAL   := xFilial("ZFI")
         ZFI->ZFI_DATA     := Date() 	
         ZFI->ZFI_HORA     := Time() // Grava a hora de inclusão do registro na tabela de muro.
         ZFI->ZFI_CGC      := SA2->A2_CGC
         ZFI->ZFI_COD      := SB1->B1_COD    
         ZFI->ZFI_CODIDN   := AllTrim(SB1->B1_COD)+Right(AllTrim(SA2->A2_CGC),6)
         ZFI->ZFI_DESC     := SB1->B1_DESC   
         ZFI->ZFI_DESCPR   := SB1->B1_DESC   
         ZFI->ZFI_POSIPI   := SB1->B1_POSIPI
         ZFI->ZFI_UM	   := If(SB1->B1_UM <> "CX","1","2")
         ZFI->ZFI_SEGUM	   := If(SB1->B1_SEGUM <> "CX","1","2")  
         ZFI->ZFI_EMPMAX   := If(_nEmpMax == 0,1,_nEmpMax)
         ZFI->ZFI_QTDEL    := If(_nQtdLastro == 0,1,_nQtdLastro)
         //ZFI->ZFI_EMPMAX   := _nEmpMax
         ZFI->ZFI_EMB	   := "1" // SB1->B1_SEGUM
         ZFI->ZFI_SUBEMB   := "1" // SB1->B1_UM
         ZFI->ZFI_PESO	   := SB1->B1_PESBRU // If(SB1->B1_PESO == 0,1,SB1->B1_PESO)
         ZFI->ZFI_CODFOR   := SA2->A2_COD
         ZFI->ZFI_LOJA	   := SA2->A2_LOJA
         ZFI->ZFI_NOME	   := SA2->A2_NOME
         ZFI->ZFI_USUARI   := __CUSERID
         ZFI->ZFI_DATAAL   := Date()
         ZFI->ZFI_SITUAC   := "N"
         ZFI->ZFI_CODEMP   := _cCodEmpWS
         ZFI->ZFI_PESVAR   := _cPesoVar
         ZFI->ZFI_PESMIN   := _nPesoMin // SB1->B1_I_FTMIN
         ZFI->ZFI_PESMAX   := _nPesoMax // SB1->B1_I_FTMAX
         ZFI->(MsUnlock())
   
         ZZM->(DbSkip())
      EndDo                               

      QRYSB1->(DbSkip())
   EndDo                
      
End Sequence

If Select("QRYSB1") > 0
   QRYSB1->(DbCloseArea())
EndIf             

RestOrd(_aOrd)

u_itmsg("Término da carga inicial do cadastro de produtos para a tabela ZFI.","Atenção",,2)

Return
