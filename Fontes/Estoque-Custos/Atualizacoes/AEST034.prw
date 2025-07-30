/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
       Autor    |   Data   |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
Andre Lisboa    | 07/07/14 | Chamado 6538. Incluída a tratativa para novo tipo "PP".                                       
-------------------------------------------------------------------------------------------------------------------------------
Alexandre Villar| 06/08/15 | Chamado 11137. Atualização da rotina conforme.                                                  
----------------------------------- --------------------------------------------------------------------------------------------
Alexandre Villar| 18/08/15 | Chamado 11417. Correção da chamada do MsgBox padronizando para o MessageBox.                   
-------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer   | 21/02/24 | Chamado 46236. Andre. Ajustes do gatilhos dos campos: BC_PRODUTO-504,BC_QUANT-502,BC_QTSEGUM-502.
-------------------------------------------------------------------------------------------------------------------------------
André Lisboa    | 13/03/24 | Chamado 46587. Gatilho para grupo de produto "leite em po" para produto destino "Residuo lacteo"
===============================================================================================================================
*/

#Include "Protheus.ch"

/*
===============================================================================================================================
Programa--------: AEST034
Autor-----------: Alex Wallauer 
Data da Criacao-: 21/02/2024
===============================================================================================================================
Descrição-------: Rotina para preencher os Gatilhos dos campos BC_PRODUTO-502 / BC_PRODUTO-504 / BC_QUANT-502 / BC_QTSEGUM-502.
===============================================================================================================================
Parametros------: Nenhum
===============================================================================================================================
Retorno---------: Nenhum
===============================================================================================================================
*/

User Function AEST034(cContraDominio)

Local _aArea	:= GetArea()
//Local cPrdDstP	:= aScan( aHeader , {|X| Upper( Alltrim( X[2] ) ) == "BC_CODDEST" } )
//Local cPrdDst	:= aCols[N][cPrdDstP]
//Local cPrdOriP	:= aScan( aHeader , {|X| Upper( Alltrim( X[2] ) ) == "BC_PRODUTO" } )
//Local cPrdOri	:= aCols[N][cPrdOriP]
Local _cGrpPrd	:= GETMV( "IT_GRPSUCA" )
Local _cPrdSuc	:= GETMV( "IT_PRDSUCA" )
//Local cMotivo	:= aScan( aHeader , {|X| Upper( Alltrim( X[2] ) ) == "BC_MOTIVO" } )
//Local cMot		:= aCols[N][cMotivo]

//IF Alltrim(cPrdOri) $ cGrpPrd .And. cMot <> "PP"
//	cPrdDst := cPrdSuc
//ELSEIF cMot <> "PP"
//	cPrdDst := ""
//	MessageBox( "Se o apontamento de perda gerar sucata, não esqueça de preencher o produto destino!" , "Atenção!" , 48 )
//ENDIF
//IF cMot == "PP"
//   cPrdDst := ""
//ENDIF
SC2->(DBSETORDER(1))//SC2->C2_FILIAL+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
_lOPAberta:=.T.
IF XFILIAL("SC2")+CORDEMP <> SC2->C2_FILIAL+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
   IF SC2->(DBSEEK(XFILIAL("SC2")+CORDEMP)) 
      _lOPAberta:=EMPTY(SC2->C2_DATRF)
   ENDIF
ELSE
   _lOPAberta:=EMPTY(SC2->C2_DATRF)
ENDIF


DO CASE 
   CASE cContraDominio ="BC_LOCAL"   // Gatilho do campo BC_PRODUTO 502
        _cRet:=IF(_lOPAberta, GDFIELDGET("BC_LOCAL"  ,n) , "34")
   CASE cContraDominio ="BC_CODDEST" // Gatilho do campo BC_PRODUTO 504
//        _cRet:=IF(_lOPAberta, If(trim(GDFIELDGET("BC_PRODUTO",n)) $ _cGrpPrd,_cPrdSuc ,(GDFIELDGET("BC_CODDEST",n))),If(trim(GDFIELDGET("BC_PRODUTO",n)) $ _cGrpPrd,_cPrdSuc ,(GDFIELDGET("BC_CODDEST",n))))
          _cRet:=IF(_lOPAberta, If(trim(GDFIELDGET("BC_PRODUTO",n)) $ _cGrpPrd,If(U_ITMSG('Produto destino "Resíduo lácteo"','Atenção!','Gravar dados para destino "Resíduo lácteo"?',3,2,2,,"GRAVAR","VOLTAR"),_cPrdSuc ,""),""),If(trim(GDFIELDGET("BC_PRODUTO",n)) $ _cGrpPrd,If(U_ITMSG('Produto destino "Resíduo lácteo"','Atenção!','Gravar dados para destino "Resíduo lácteo"?',3,2,2,,"GRAVAR","VOLTAR"),_cPrdSuc ,GDFIELDGET("BC_PRODUTO",n)),GDFIELDGET("BC_PRODUTO",n)))   
   CASE cContraDominio ="BC_QTDDEST" // Gatilho do campo BC_QUANT   502
        _cRet:=IF(_lOPAberta, GDFIELDGET("BC_QTDDEST",n) , GDFIELDGET("BC_QUANT",n) )
   CASE cContraDominio ="BC_QTDDES2" // Gatilho do campo BC_QTSEGUM 502
        _cRet:=IF(_lOPAberta, GDFIELDGET("BC_QTDDES2",n) , GDFIELDGET("BC_QTSEGUM",n) )
ENDCASE

/*			If 	TRIM(GDFIELDGET("BC_CODDEST",_ni)) == TRIM(_cPrdSuc)
				If !U_ITMSG('Produto destino "Resíduo lácteo"','Atenção!','Gravar dados para destino "Resíduo lácteo"?',3,2,2,,"GRAVAR","VOLTAR")
					_lRet:=.F.
				Endif	
			Endif	*/

RestArea(_aArea)

Return( _cRet )
