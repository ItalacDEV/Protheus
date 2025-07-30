/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 01/06/2018 | Exceção de validação para execauto do MT103EXC
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 04/07/2018 | Exceção de validação para execauto do MTA140MNU - Chamado 25403 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 20/08/2024 | Incluir Validação no estorno movim./transf.com base no cadastro usuarios Italac. Chamado 47670
===============================================================================================================================
*/

#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "RWMake.ch"

/*
===============================================================================================================================
Programa----------: MA261EST
Autor-------------: Julio de Paula Paz
Data da Criacao---: 29/08/2016
===============================================================================================================================
Descrição---------: Ponto de entrada para validar estorno o estorno da transferência multipla.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lRet == Define se a transferência pode ser estornada
===============================================================================================================================
*/
User Function MA261EST()
Local _aArea   := GetArea()
Local _lRet	   := .T.
Local _nLocalOrig, _nLocalDest     
Local _aOrd := SaveOrd({"ZZL"})
Local _nI

//Verifica se está sendo executado automaticamente a partir do mt103exC
If isincallstack("U_ITEXCNF") .OR. isincallstack("U_AGLT003G")  .OR. isincallstack("U_MA140EXE")

	Return _lret
	
Endif


Begin Sequence    
   //================================================================================
   // Valida o estorno de acordo com o cadastro de usuários Italac.
   //================================================================================      
   If ! U_ITVACESS( 'ZZL' , 3 , 'ZZL_AUTMUL' , 'S' )
      u_itmsg("Usuário sem permissão para realizar estorno da transferência multipla. Não será possível realizar o estorno da transferência.",;
      				"Permissões de Acesso Italac","Entre em contato com o suporte do TI.",1)
      _lRet := .F.
      Break                                                  
   EndIf

   _nLocalOrig := Ascan(aHeader,{|x| x[1] = 'Armazem Orig.'})
   _nLocalDest := Ascan(aHeader,{|x| x[1] = 'Armazem Destino'})
 
   _nProdOrig := Ascan(aHeader,{|x| x[1] = 'Prod.Orig.'})
     
   ZZL->(DbSetOrder(3))  
   If ZZL->(DbSeek(xFilial("ZZL")+RetCodUsr()))
      _cLocaisEs := AllTrim(ZZL->ZZL_ARMAES) // Obter lista armazéns estorno.    

      _cProdEsto := AllTrim(ZZL->ZZL_TIPRES) // Obter lista de produtos de estorno 

      For _nI := 1 To Len(aCols)

          _cLocalOrg  := AllTrim(aCols[_nI,_nLocalOrig]) 
          _cCodProd   := AllTrim(aCols[_nI,_nProdOrig])  
          _cTipoProd  := Posicione("SB1",1,xFilial("SB1")+_cCodProd,"B1_TIPO")
          _cLocalDes  := AllTrim(aCols[_nI,_nLocalDest]) 

          If ! (_cLocalOrg $ _cLocaisEs) // Valida armzém de origem
             u_itmsg( "Usuário sem permissão para estornar movimentações deste armazém de origem: "+_cLocalOrg+". ",;
                         "Permissões de Acesso Italac","Entre em contato com o suporte do TI.",1)
             _lRet := .F.
             Break  
          EndIf

          If ! (_cLocalDes $ _cLocaisEs)  // Valida armazém de destino.
             u_itmsg( "Usuário sem permissão para estornar movimentações deste armazém de destino: "+_cLocalDes+". ",;
                         "Permissões de Acesso Italac","Entre em contato com o suporte do TI.",1)
             _lRet := .F.
             Break  
          EndIf

          If ! (_cTipoProd $ _cProdEsto) 
             u_itmsg( "Usuário sem permissão para estornar movimentações deste tipo de produto: "+_cTipoProd+". ",;
                         "Permissões de Acesso Italac","Entre em contato com o suporte do TI.",1)
             _lRet := .F.
             Break  
          EndIf

          If ! (aCols[_nI,_nLocalOrig] $ ZZL->ZZL_ARMAZE)
             u_itmsg( "Usuário sem permissão para utilizar este armazem de origem. Não será possível realizar o estorno da transferência multipla. Armazens permitidos ao usuário: '"+AllTrim(ZZL->ZZL_ARMAZE)+"'.",;
                         "Permissões de Acesso Italac","Entre em contato com o suporte do TI.",1)
             _lRet := .F.
             Break   
          EndIf
          
          If ! (aCols[_nI,_nLocalDest] $ ZZL->ZZL_ARMAZE)
             u_itmsg( "Usuário sem permissão para utilizar este armazem de destino. Não será possível realizar o estorno da transferência multipla. Armazens permitidos ao usuário: '"+AllTrim(ZZL->ZZL_ARMAZE)+"'.",;
                         "Permissões de Acesso Italac","Entre em contato com o suporte do TI.",1)
             _lRet := .F.
             Break  
          EndIf
      Next
   EndIf 

End Sequence              

RestOrd(_aOrd)
RestArea(_aArea)

Return( _lRet )
