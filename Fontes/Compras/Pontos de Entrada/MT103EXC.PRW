/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  |19/06/2024| Chamado 47627. Retirada validaçao do estorno da transferência quando for o fechamento do leite
Lucas Borges  |19/06/2025| Chamado 50617. Revisões diversas visando padronizar os fontes
===============================================================================================================================
Analista    - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
===============================================================================================================================
Andre       - Alex Wallauer - 17/03/25 - 17/03/25 - 50203   - Retirada da validacao de saldo retroativo quando tem OP preenchida.
===============================================================================================================================
*/

#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: MT103EXC
Autor-------------: Josué /Danich Prestes
Data da Criacao---: 15/10/2015
Descrição---------: Ponto de entrada para validar exclusão documento de entrada - Chamado 12080
Parametros--------: Nenhum
Retorno-----------: Lógico - .T. se o registro for válido, .F. para descartar o registro
===============================================================================================================================
*/
User Function MT103EXC

Local _aArea    := FwGetArea() As Array
Local _lRet     := .T. As Logical
Local _nCodArmaz:= aScan( aHeader , {|x| UPPER( Alltrim( x[2] ) ) == "D1_LOCAL"  } ) As Numeric
Local _nCodPro  := aScan( aHeader , {|x| UPPER( Alltrim( x[2] ) ) == "D1_COD"    } ) As Numeric
Local _nCodQtd  := aScan( aHeader , {|x| UPPER( Alltrim( x[2] ) ) == "D1_QUANT"  } ) As Numeric
Local _nCoddta  := aScan( aHeader , {|x| UPPER( Alltrim( x[2] ) ) == "D1_DTDIGIT"} ) As Numeric
Local _nCodTes  := aScan( aHeader , {|x| UPPER( Alltrim( x[2] ) ) == "D1_TES"    } ) As Numeric
Local _nCodITEM := aScan( aHeader , {|x| UPPER( Alltrim( x[2] ) ) == "D1_ITEM"   } ) As Numeric
Local _nOrdProd := aScan( aHeader , {|x| UPPER( Alltrim( x[2] ) ) == "D1_OP"     } ) As Numeric
Local _cmens    := "" As Character
Local _aRet     := {} As Array
Local _Ni       := 1 As Numeric
Local _lRet2    := .T. As Logical
Local _cVldCM   := Posicione("NNR",1,xFilial("NNR")+alltrim(aCols[_Ni][_nCodArmaz]),"NNR_I_VDCM") As Character
Local _lgranel  := .F. As Logical
Local _aErros   := {} As Array
Local _cAlias   := GetNextAlias() As Character
Local _cLtGrn   := SuperGetMV("IT_LTGRN",.F.,'08000000062') As Character
Local _cCrGrn   := SuperGetMV("IT_CRGRN",.F.,'08000000064;08000000063') As Character

//Lucas - Valida se NF-e foi vinculada há algum fechamento
If !FwIsInCallStack("U_MGLT010")
   If !Empty(SF1->F1_L_MIX) .And. Empty(SF1->F1_L_SETOR)
      BeginSQL alias _cAlias
         SELECT COUNT(1) QTD
         FROM %Table:ZLF%
         WHERE D_E_L_E_T_ = ' '
         AND ZLF_FILIAL = %exp:SF1->F1_FILIAL%
         AND ZLF_A2COD = %exp:SF1->F1_FORNECE%
         AND ZLF_CODZLE = %exp:SF1->F1_L_MIX%
         AND ZLF_STATUS = 'F'
      EndSQL
      If (_cAlias)->QTD > 0
         _lRet := .F.
         FWAlertWarning("Esse documento não pode ser excluído pois está vinculado ao Fechamento do Leite.","MT103EXC01")
      EndIf
      (_cAlias)->(DBCloseArea())
   EndIf

   //========================================================================================
   //Validações linha a linha 1a. parte
   //========================================================================================
   _ccodusr := RetCodUsr()

   For _ni := 1 to len(aCols)
      If !aCols[_ni][Len(aHeader)+1] .AND. posicione("SF4",1,xfilial("SF4")+alltrim(aCols[_Ni][_nCodTes]),"F4_ESTOQUE") = "S" //Não verifica linhas deletadas
                                                                                                // ou que não mov estoque
         //============================================
         //Valida armazémxprodutoxfilialxusuário
         //============================================
         _aRet:= U_ACFG004E(alltrim(_ccodusr), alltrim(xFilial("SD1")), alltrim(aCols[_Ni][_nCodArmaz]),alltrim(aCols[_Ni][_nCodPro]),.F.)
         
         //se ainda está valido verifica se não teve erro
         If _lRet
            _lRet:= _aRet[1]
         EndIf
         
         // adiciona armazens com problema se ainda não estiver na mensagem
         If Empty(_cmens)
            _cmens += _aRet[2]
         ElseIf !(_aRet[2]$_cmens) .and. !(Empty(_aRet[2])) 
            _cmens += ", " + _aRet[2]
         EndIf
      EndIf
   Next _nI

   //============================================
   //Realiza validações linha a linha, 2a. parte
   //============================================
   If _lret
      _aErros := {}
      For _ni := 1 to len(aCols)
         //Verifica se tem produto de transferência de leite a granel
         If ascan(STRTOKARR(_cLtGrn,";"),alltrim(aCols[_Ni][_nCodPro])) > 0
            _lgranel := .T.
         Endif
         
         //Verifica se tem produto de transferência de leite a granel
         If ascan(STRTOKARR(_cCrGrn,";"),alltrim(aCols[_Ni][_nCodPro])) > 0
            _lgranel := .T.
         Endif
         
         //============================================
         //Valida se não vai gerar saldos negativos
         //============================================ 
         _agetsd1 := SD1->(FwGetArea())
         SD1->(Dbsetorder(1))
         
         If  EMPTY(aCols[_Ni][_nOrdProd]) .AND. SD1->(Dbseek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+aCols[_Ni][_nCodPro]+aCols[_Ni][_nCodITEM]))
            If _cVldCM = "S" .AND. !aCols[_ni][Len(aHeader)+1] .AND. posicione("SF4",1,xfilial("SF4")+SD1->D1_TES,"F4_ESTOQUE") = "S" //Não verifica linhas deletadas
               _aneg := U_VldEstRetrNeg(aCols[_Ni][_nCodPro],alltrim(aCols[_Ni][_nCodArmaz]),aCols[_Ni][_nCodQtd],aCols[_Ni][_nCoddta])
               If len(_aneg) > 0
                  nDif :=  _aNeg[2] - aCols[_Ni][_nCodQtd]
                  AADD(_aErros,{aCols[_Ni][_nCodPro],posicione("SB1",1,xfilial("SB1")+aCols[_Ni][_nCodPro],"B1_DESC"),alltrim(aCols[_Ni][_nCodArmaz]),dtoc(_aNeg[1]),TRANSFORM(nDif,"@E 999,999,999.99")})
                  _lRet2 := .F.
               EndIf
            EndIf
         EndIf
   
         SD1->(FwRestArea(_agetsd1))
      Next _Ni
   EndIf

   //Bloqueia se tiver produto a granel e não for rotina excluir italac
   If _lgranel .and. !FwIsInCallStack("U_ITEXCNF") .and. !FwIsInCallStack("U_MA140ESTCLA")
      FWAlertWarning("Doc de entrada de produto a granel. Use a rotina Acoes Relacionadas->Excluir italac","MT103EXC02")
      _lRet := .F.
   EndIf

   //============================================
   //Mostra lista de armazéns com problema
   //============================================
   If !(_lRet)
      FWAlertWarning( 'Usuário sem acesso ao(s) armazém(éns) abaixo nessa filial: ' + CRLF + _cmens + CRLF +;
               'Caso necessário solicite a manutenção à um usuário com acesso ou, se necessário, solicite o acesso à área de TI/ERP.',"MT103EXC03")

   //========================================================
   //Mostra lista de produtos com problema de saldo negativo
   //========================================================	
   ElseIf !(_lRet2)
      aCampPla := {"Produto","Descr","Armazém","Data","Diferença"}
      _odet := {|| U_ITListBox( 'Produtos com saldo negativo' , aCampPla , _aErros , .T. , 1 )}

      u_itmsg( "Quantidade a estornar é maior que o saldo diário em um ou mais produtos","MT103EXC04",;
               "Verique os produtos e datas no botão mais detalhes e confira com o kardex",2,,,,,,_odet)
      _lret := .F.
   EndIf
EndIf
FwRestArea(_aArea)

Return(_lRet)
