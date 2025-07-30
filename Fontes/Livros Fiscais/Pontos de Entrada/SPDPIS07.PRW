/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 07/12/2017 | Acrescentei o Cleinte e Fornecedor  - Chamado 21796
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 14/05/2018 | Acrescentei um tratamento para o campo novo ZGH_NATURE - Chamado 23254
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 09/08/2018 | Retirado o retorno das contas genericas - Chamado 25825
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 13/12/2019 | Alterar função de obtenção da conta contábil para funcionar de forma genérica. Chamado 31211. 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 24/01/2020 | Colocada a CFOP  6108 como exceção - Chamado 31770
===============================================================================================================================
*/

#include "protheus.ch"
#define FO_READWRITE  2
#define FO_EXCLUSIVE 16    // Exclusive use (other processes have no access)
#define ENTER CHR(13)+CHR(10)
/*
===============================================================================================================================
Programa----------: SPDPIS07
Autor-------------: Josué Danich Prestes
Data da Criacao---: 08/11/2017
===============================================================================================================================
Descrição---------: Ponto de entrada de ajuste de dados no Sped Pis/Cofins - Chamado 21796
===============================================================================================================================
Parametros--------: PARAMIXB[1]	 	 	Caracter	 	 		FT_FILIAL	 	 	 	 	 	 	 	 	 	 
 					PARAMIXB[2]	 	 	Array of Record	 	 	FT_TIPOMOV	 	 	 	 	 	 	 	 	 	 
 					PARAMIXB[3]	 	 	Array of Record	 	 	FT_SERIE	 	 	 	 	 	 	 	 	 	 
 					PARAMIXB[4]	 	 	Array of Record	 	 	FT_NFISCAL	 	 	 	 	 	 	 	 	 	 
 					PARAMIXB[5]	 	 	Array of Record	 	 	FT_CLIEFOR	 	 	 	 	 	 	 	 	 	 
 					PARAMIXB[6]	 	 	Array of Record	 	 	FT_LOJA	 	 	 	 	 	 	 	 	 	 
 					PARAMIXB[7]	 	 	Array of Record	 	 	FT_ITEM	 	 	 	 	 	 	 	 	 	 
 					PARAMIXB[8]	 	 	Array of Record	 	 	FT_PRODUTO	 	 	
===============================================================================================================================
Retorno-----------: _cContAju - Código da Conta Contábil Ajustada
===============================================================================================================================
*/
User Function SPDPIS07()
Local _cContAju := " " //Se não tiver regra retorna vazio para não gerar a linha 500

Begin Sequence
   //_cContAju := SPDPIS7C(_cFilial   , _cTipoMov ,  _cSerie  , _cNFiscal , _cClieForn, _cLoja    , _cItem    , _cProduto )
   _cContAju   := U_SPDPIS7C(PARAMIXB[1],PARAMIXB[2],PARAMIXB[3],PARAMIXB[4],PARAMIXB[5],PARAMIXB[6],PARAMIXB[7],PARAMIXB[8])

End Sequence

Return _cContAju
                        
/*
===============================================================================================================================
Programa----------: SPDPIS7C
Autor-------------: Julio de Paula Paz
Data da Criacao---: 13/12/2019
===============================================================================================================================
Descrição---------: Função generica para retornar o numero da conta contábil, utilizada pelo Ponto de entrada de ajuste de 
                    dados no Sped Pis/Cofins. Rotina transferida da função SPDPIS07 para função SPDPIS7C.
===============================================================================================================================
Parametros--------: _cFilial   - Codigo da filial        - PARAMIXB[1]  Caracter	 	 FT_FILIAL	 	 	 	 	 	 	 	 	 	 
 					_cTipoMov  - Tipo de movimento       - PARAMIXB[2]  Array of Record  FT_TIPOMOV	 	 	 	 	 	 	 	 	 	 
 					_cSerie    - Serie da NF             - PARAMIXB[3]  Array of Record  FT_SERIE	 	 	 	 	 	 	 	 	 	 
 					_cNFiscal  - Nr Nota Fiscal          - PARAMIXB[4]  Array of Record  FT_NFISCAL	 	 	 	 	 	 	 	 	 	 
 					_cClieForn - Cliente/Fornecedor      - PARAMIXB[5]  Array of Record	 FT_CLIEFOR	 	 	 	 	 	 	 	 	 	 
 					_cLoja     - Loja Cliente/Fornecedor - PARAMIXB[6] 	Array of Record	 FT_LOJA	 	 	 	 	 	 	 	 	 	 
 					_cItem     - Item da NF              - PARAMIXB[7] 	Array of Record	 FT_ITEM	 	 	 	 	 	 	 	 	 	 
 					_cProduto  - Codigo do Produto       - PARAMIXB[8] 	Array of Record	 FT_PRODUTO	 	 	
===============================================================================================================================
Retorno-----------: _cContAju  - Código da Conta Contábil Ajustada, com base nas regras estabelecidas.
===============================================================================================================================
*/                //      1          2          3        4          5          6      7        8
User Function SPDPIS7C(_cFilial, _cTipoMov, _cSerie, _cNFiscal, _cClieForn, _cLoja, _cItem, _cProduto)
Local _cContAju := " " //Se não tiver regra retorna vazio para não gerar a linha 500
Local _aareaSB1 := SB1->(GetArea())
Local _aareaSFT := SFT->(GetArea())
Local _cAlias   := Getnextalias()

Begin Sequence

   SB1->(Dbsetorder(1))
   SFT->(Dbsetorder(1)) //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO

   If SB1->(Dbseek(xfilial("SB1")+alltrim(_cProduto))) .and. SFT->(Dbseek(_cFilial+_cTipoMov+_cSerie+_cNFiscal+_cClieForn+_cLoja+_cItem +_cProduto))

	  //Busca regras
	  _cQuery := " SELECT R_E_C_N_O_ REC_ZGH "
	  _cQuery += " FROM "+ RetSqlName("ZGH") +" ZGH "
	  _cQuery += " WHERE ZGH.ZGH_FILIAL = '"+ alltrim(SFT->FT_FILIAL)  +"' "
      _lEhClente:=.F.
      //A regras sempre estarão com os CFOP de 1000 a 1999 e de 5000 a 5999
      _xCFOP:=VAL(SFT->FT_CFOP)
      If (_xCFOP >= 2000 .AND. _xCFOP < 4000) 
         _xCFOP:="1"+SubStr(SFT->FT_CFOP,2)
      ElseIf (_xCFOP >= 6000 .AND. _xCFOP < 8000) .AND. _xCFOP <> 6108
         _xCFOP:="5"+SUBSTR(SFT->FT_CFOP,2)
      Else
         _xCFOP:=SFT->FT_CFOP
      EndIf   

      If !Empty(SFT->FT_CLIENT)// Se preenchido é Cliente 
	     _cQuery += " AND	( (ZGH.ZGH_CLIENT = '"+ ALLTRIM(SFT->FT_CLIEFOR) +"' ) OR (ZGH.ZGH_FORNER = '  ' AND ZGH.ZGH_CLIENT = '  ') ) "//AND ZGH.ZGH_CLILOJ = '"+ ALLTRIM(SFT->FT_LOJA) +"'
         _lEhClente:=.T.
      Else //  Se em branco é fornecedor
	     _cQuery += " AND	( (ZGH.ZGH_FORNER = '"+ ALLTRIM(SFT->FT_CLIEFOR) +"' ) OR (ZGH.ZGH_FORNER = '  ' AND ZGH.ZGH_CLIENT = '  ') ) "//AND ZGH.ZGH_FORLOJ = '"+ ALLTRIM(SFT->FT_LOJA) +"'
	  EndIf

	  _cQuery += " AND ( ZGH.ZGH_GRUPO = '"+ ALLTRIM(SB1->B1_GRUPO) +"' OR ZGH.ZGH_PRODUT = '" + ALLTRIM(SFT->FT_PRODUTO) +"' ) "

	  _cQuery += " AND ( ZGH.ZGH_TPMOV = '"+ ALLTRIM(SFT->FT_TIPOMOV) +"' OR ZGH.ZGH_CFOP = '" + ALLTRIM(_xCFOP) +"' ) "

	  _cQuery += " AND ZGH.D_E_L_E_T_	= ' ' "

      If ZGH->(FIELDPOS("ZGH_NATURE")) <> 0
	     _cQuery += " AND ZGH.ZGH_NATURE	= ' ' "
      EndIf

	  _cQuery += " ORDER BY ZGH_CLIENT DESC ,ZGH_FORNER DESC ,ZGH_PRODUT DESC, ZGH_CFOP DESC " //Essa é a orde de prioridade do resltado do SELECT

	  If Select(_cAlias) > 0
	     (_cAlias)->( DBCloseArea() )
	  EndIf

	  DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQuery) , _cAlias , .T. , .F. )

	  DBSelectArea(_cAlias)
	  _nConta:=0
 	  
 	  Do While (_cAlias)->(!Eof())
	                               
	     ZGH->(DBGOTO( (_cAlias)->REC_ZGH ) )
         _nConta++
         If _lEhClente// Se preenchido é Cliente 

            If !Empty(ZGH->ZGH_CLIENT) .AND. ZGH->ZGH_CLIENT # SFT->FT_CLIEFOR
               (_cAlias)->(DbSkip())
               Loop 
            EndIf
            If !Empty(ZGH->ZGH_CLILOJ) .AND. ZGH->ZGH_CLILOJ # SFT->FT_LOJA
               (_cAlias)->(DbSkip())
               Loop 
            EndIf

         Else

            If !Empty(ZGH->ZGH_FORNER) .AND. ZGH->ZGH_FORNER # SFT->FT_CLIEFOR
               (_cAlias)->(DbSkip())
               Loop 
            EndIf    
           
            If !Empty(ZGH->ZGH_FORLOJ) .AND. ZGH->ZGH_FORLOJ # SFT->FT_LOJA
               (_cAlias)->(DbSkip())
               Loop 
            EndIf

         EndIf

         If !Empty(ZGH->ZGH_GRUPO) .AND. ZGH->ZGH_GRUPO # SB1->B1_GRUPO
            (_cAlias)->(DbSkip())
            Loop 
         ElseIf !Empty(ZGH->ZGH_PRODUT) .AND. ZGH->ZGH_PRODUT # SFT->FT_PRODUTO
            (_cAlias)->(DbSkip())
            Loop 
         EndIf

         If !Empty(ZGH->ZGH_TPMOV) .AND. ZGH->ZGH_TPMOV # SFT->FT_TIPOMOV
            (_cAlias)->(DbSkip())
            Loop 
         ElseIf !Empty(ZGH->ZGH_CFOP) .AND. ZGH->ZGH_CFOP # ALLTRIM(_xCFOP)
            (_cAlias)->(DbSkip())
            Loop 
         EndIf

		 _cContAju := ALLTRIM(ZGH->ZGH_CONTA)
	     _nRecZGH  := ZGH->(Recno())//Usada dentro da USER FUNCTION AFIS008Busca()

		 Exit
      EndDo
	
	  DBSelectArea(_cAlias)
	  (_cAlias)->(Dbclosearea())

      If Empty(_cContAju)
         _cFileNome:="\DATA\ITALAC\CONTROLE\SPEED500.CSV"
	     nHandle:=0
         If File(_cFileNome)
            nHandle:=FOpen(_cFileNome,FO_READWRITE)
         EndIf
       
         If nHandle > 0 
            cString := Space(10)
            FReadLn(nHandle,@cString, 10, .F.) 
            If Empty(cString)
               _cLinha:="User;Filial;CFOP;Tipo;Grupo;Produto;Fornecedor;CFOP Original;Recno SFT;Resultado SELECT"+ENTER
               FWrite(nHandle,_cLinha)
            EndIf
         
            _cLinha:=CUSERNAME+";"+SFT->FT_FILIAL+";"+_xCFOP+";"+SFT->FT_TIPOMOV+";"+SB1->B1_GRUPO+";"+SFT->FT_PRODUTO+";"+SFT->FT_CLIEFOR+";"+SFT->FT_CFOP+";"+ALLTRIM(STR(SFT->(Recno())))+";"+ALLTRIM(STR(_nConta))+ENTER
            FSEEK(nHandle,0,2)
            FWrite(nHandle,_cLinha)
            FClose(nHandle)
            U_ITCONOUT(_cLinha)
         Else
            U_ITCONOUT("Nao abriu: "+_cFileNome)
         EndIf
      EndIf
   EndIf

End Sequence

SB1->(Restarea(_aareaSB1))
SFT->(Restarea(_aareaSFT))

Return _cContAju
