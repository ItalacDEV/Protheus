/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Erich Buttner  | 08/04/2013 | Chamado 03034. Melhoria da query para busca por filiais.    							          
Josu� Danich    | 09/10/2015 | Chamado 11509. Inclus�o de valida��o de campos de investimento. 	
Josu� Danich    | 28/10/2015 | Chamado 12551. Melhoria de  valida��o de campos de investimento. 							  
Josu� Danich    | 06/06/2018 | Chamado 25121. Valida��o de armaz�m e saldo dispon�vel. 							               
Andre Lisboa    | 05/09/2019 | Chamado 28685. Valida��o p/ n�o permitir fracionamento de UM que s�o inteiras. 
 Alex Wallauer  | 21/10/2022 | Chamado 41652. Permitir fracionar produtos <> "PA" quando o campo ZZL_PEFROU for = "S". 
 Alex Wallauer  | 17/01/2024 | Chamado 46095. Ajuste na valida��o do centro de custo ser v�lido com campo de investimento.
==============================================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Altera��o
==============================================================================================================================================================
Andre    - Igor Melga�o  - 16/07/25 -          -  51382  - Ajustes para preenchimento obrigat�rio do campo Motivo (CP_I_MOTIV).
==============================================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#Include "rwmake.ch"
#Include 'Protheus.ch'

/*
===============================================================================================================================
Programa----------: MTA105LIN
Autor-------------: Guilherme Diogo 
Data da Criacao---: 07/01/2013 
===============================================================================================================================
Descri��o---------: Ponto de entrada que valida linha digitada na rotina de Solicitacao ao Armazem. 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MTA105LIN() as Logical

Local _lRet   := .T. As Logical
Local _cProd  := ALLTRIM(aCols[n][aScan(aHeader,{|x| UPPER(Alltrim(x[2])) == "CP_PRODUTO"})]) As Character
Local _cArmz  := ALLTRIM(aCols[n][aScan(aHeader,{|x| UPPER(Alltrim(x[2])) == "CP_LOCAL"})]) As Character
Local _nQtdAt := aCols[n][aScan(aHeader,{|x| UPPER(Alltrim(x[2])) == "CP_QUANT"})] As Numeric
Local _nQtdAt2:= aCols[n][aScan(aHeader,{|x| UPPER(Alltrim(x[2])) == "CP_QTSEGUM"})] As Numeric
Local _cMotiv := aCols[n][aScan(aHeader,{|x| UPPER(Alltrim(x[2])) == "CP_I_MOTIV"})] As Character
Local _nSaldo := 0 As Numeric
Local _nQuant := 0 As Numeric
Local _nSolic := 0 As Numeric
Local _nI     := 0 As Numeric
Local _aArea  := GetArea() As Array
//Local _nni 	:= 0
Local _cmens	:= "" As Character
Local _cCC		:= "" As Character
Local _cINVES := "" As Character
Local _cLOCIN := "" As Character
Local _lexcep := .F. As Logical
Local _cloca  := U_ITGETMV( "IT_MOTINV" , "15" ) As Character
Local _cArmazens:= U_ITGETMV( "IT_ARMCPR" , "02,04" ) As Character
Local _cUM_NO_Fracionada:=U_ITGetMV("IT_UMNOFRAC","PC,UN") As Character // parametro de unidades de medida para fracionamento           
Local _lValidFrac1UM:=.T. As Logical

BEGIN SEQUENCE

If (_cArmz $ _cArmazens)
   U_ITMSG("Para o armaz�m "+_cArmz+" n�o � permitido a inclus�o de SAs. Armazens n�o permitidos: '"+AllTrim(_cArmazens)+"'.",;
           "Permiss�es de Acesso Italac",;
           "Entre em contato com o departamento de Custo.",1)
    _lRet := .F.
    BREAK
Else
   ZZL->(DbSetOrder(3))  
   If ZZL->(DbSeek(xFilial("ZZL")+RetCodUsr()))
      If !(_cArmz $ ZZL->ZZL_ARMAZE)
             U_ITMSG("Usu�rio sem permiss�o para utilizar este armazem. N�o ser� poss�vel realizar a SA. Armazens permitidos ao usu�rio: '"+AllTrim(ZZL->ZZL_ARMAZE)+"'.",;
                     "Permiss�es de Acesso Italac",;
                     "Entre em contato com o suporte do TI.",1)
             _lRet := .F.
             BREAK
      EndIf
   Endif   
EndIf

If (UPPER(FunName()) == "MATA105" .OR. UPPER(FunName()) == "AEST015") .AND. !FwIsInCallStack("MSEXECAUTO") .AND. Empty(Alltrim(_cMotiv))
   U_ITMSG("� obrigat�rio o preenchimento do campo Cod Motivo.",;
         'Aten��o!',;
         "Prencha o campo Cod Motivo.",1)
   _lRet := .F.
   BREAK
EndIf

//============================================================
//Calcula o saldo disponivel do produto.      
//============================================================

SB2->(dbSetOrder(1))

_aSaldo := {}

If SB2->(dbSeek(xFilial("SB2")+padR(_cProd,15)+_cArmz))
   
   fwmsgrun(, {|| _aSaldo := Calcest(_cProd,_cArmz,date()+1)}, "Aguarde...", "Validando estoque....")
   _nsaldo := _aSaldo[1] - SB2->B2_RESERVA - SB2->B2_QACLASS - SB2->B2_QEMPSA - SB2->B2_QEMP
   
   If _nsaldo < 0
   
      _nsaldo := 0
      
   Endif

Else

   _nSaldo := 0
   
EndIf 

ZZL->(DbSetOrder(3))  
ZZL->(DbSeek(xFilial("ZZL")+RetCodUsr()))
If ZZL->ZZL_PEFROU == "S"
   _lValidFrac1UM:=.F.
EndIf

//============================================================
//Valida quantidade fracionada.
//============================================================
IF _lValidFrac1UM
   SB1->(dbSeek(xFilial("SB1") + ALLTRIM(_cProd)))
   If  SB1->B1_UM $ _cUM_NO_Fracionada
      If _nQtdAt <> Int(_nQtdAt) .and. !GDDeleted(n) 
         _lRet := .F.
         U_ITMSG("O produto / linha " + ALLTRIM(_cProd) + " / " + ALLTRIM(STR(n)) + " n�o pode ter quantidade 1um fracionada.",;
           "Quantidade inv�lida",;
           "Favor ajustar a quantidade 1um para uma quantidade inteira.",1) 
           BREAK
      EndIf
   EndIf
   If  SB1->B1_SEGUM $ _cUM_NO_Fracionada
      If _nQtdAt2 <> Int(_nQtdAt2) .and. !GDDeleted(n)
         _lRet := .F.
         U_ITMSG("O produto / linha " + ALLTRIM(_cProd) + " / " + ALLTRIM(STR(n)) + " n�o pode ter quantidade 2um fracionada.",;
            "Quantidade inv�lida",;
            "Favor ajustar a quantidade 2um para uma quantidade inteira.",1) 
         BREAK
      EndIf
   EndIf

EndIf

//============================================================
//Solicitacoes nao atendidas.                 
//============================================================

_nSolic := CalcSolic(cA105Num,_cProd,_cArmz)

//============================================================
//CALCULA QUANTIDADE DIGITADA DO PRODUTO NA SOLICITACAO.
//============================================================

For _nI := 1 To Len(aCols)

   If _nI <> n .And. ALLTRIM(aCols[_nI][aScan(aHeader,{|x| UPPER(Alltrim(x[2])) == "CP_PRODUTO"})]) == _cProd .And. !aCols[_nI][len(aHeader)+1]
   
      If ALLTRIM(aCols[_nI][aScan(aHeader,{|x| UPPER(Alltrim(x[2])) == "CP_LOCAL"})]) == _cArmz
   
         _nQuant += aCols[_nI][aScan(aHeader,{|x| UPPER(Alltrim(x[2])) == "CP_QUANT"})]
         
      Endif	
   
   EndIf

Next _nI


If _nSaldo - _nSolic - _nQuant - _nQtdAt < 0 .AND. _lRet

   U_ITMSG("J� existem solicita��es a serem atendidas para esse produto." + CRLF + CRLF + ;
            " Saldo atual: "+Transform(_nSaldo,'@E 999,999,999.99') + CRLF + CRLF + ;
            " Total solicita��es incluindo esta: "+Transform(_nSolic+_nQuant+_nQtdAt,'@E 999,999,999.99');
            ,"Saldo Indispon�vel",	"D�vidas, consulte o Almoxarifado.",1)
     
   _lRet := .F.
   BREAK

EndIf

//============================================
//Faz valida��o de campos de investimento
//============================================

If !(acols[n][len(aheader)+1])
   
   //l� campos
   _cCC 		:= acols[n][ascan(aHeader , {|X| UPPER( Alltrim( X[2] ) ) == "CP_CC"     } )]
   _cINVES	:= acols[n][ascan(aHeader , {|X| UPPER( Alltrim( X[2] ) ) == "CP_I_INVES"     } )]
   _cLOCIN	:= acols[n][ascan(aHeader , {|X| UPPER( Alltrim( X[2] ) ) == "CP_I_LOCIN"     } )]
   _cMOTIN	:= acols[n][ascan(aHeader , {|X| UPPER( Alltrim( X[2] ) ) == "CP_I_MOTIV"     } )]
   
   
   //verifica se � exce��o de valida��o
   If 	ALLTRIM(_cMOTIN) $ ALLTRIM(_cloca) 
     
      _lexcep := .T.
     
   Endif

   //Verifica se campo de centro de custo � v�lido com campo de investimento
   if substr(alltrim(_cCC),1,5) $ alltrim(u_vldcc())   .and. _cINVES <> "S" .and. !(empty( _cCC )) .and. !(_lexcep) .and. !FWIsInCallStack( "MDTA695" )

      _cmens += "Item " + strzero(n,4) + " - Para Centro de custo da filial � preciso que seja solicita��o de investimento." + CRLF + CRLF
      _lret := .F.

   Endif

   //Verifica se campo de centro de custo � v�lido com campo de investimento
   if !(substr(alltrim(_cCC),1,5) $ alltrim(_cCC))  .and. _cINVES = "S" .and. !(_lexcep)

      _cmens += "Item " + strzero(n,4) + " - Para investimento � preciso campo de centro de custo v�lido." + CRLF + CRLF
      _lret := .F.
   
   Endif

   //Verifica se campo investimento n�o est� como S se o campo local de investimento estiver preenchido
   if  _cINVES <> "S" .And. !(empty( _cLOCIN )) 

      _cmens += "Item " + strzero(n,4) + " - Para ter local de investimento � preciso ser solicita��o de investimento." + CRLF + CRLF
      _lret := .F.
   
   Endif

   //Verifica se campo local de investimento est� preenchido se campo investimento est� preenchido
   if  _cINVES = "S"  .And. (empty( _cLOCIN )) 

      _cmens += "Item " + strzero(n,4) + " - Para solicita��o de investimento � obrigat�rio local de investimento." + CRLF + CRLF
      _lret := .F.
   
   Endif

   //Se local de investimento est� preenchido garante que a descri��o de investimento est� preenchida
   if  _cINVES = "S"	.And. !(empty( _cLOCIN )) .and. !(_lexcep) 
 
      acols[n][ascan(aHeader , {|X| UPPER( Alltrim( X[2] ) ) == "CP_I_DESIN"     } )] := 	posicione("ZZI",1,xfilial("ZZI")+_cLOCIN,"ZZI_DESINV")
       
   Endif

Endif

//============================================
//Mostra lista de itens com problema
//============================================
If !(_lRet) .and. !(empty(_cmens))


   U_ITMSG( 'Problemas nos itens abaixo: ' + CRLF + CRLF + _cmens , 'Aten��o!',;
               'Caso necess�rio solicite a manuten��o � um usu�rio com acesso ou, se necess�rio, solicite o acesso � �rea de TI/ERP.' ,1 )
               
   BREAK
   
Endif

END SEQUENCE

RestArea(_aArea)

Return _lRet

/*
===============================================================================================================================
Programa----------: CalcSolic
Autor-------------: Guilherme Diogo 
Data da Criacao---: 07/01/2013 
===============================================================================================================================
Descri��o---------: Calcula solicitacoes nao atendidas.
===============================================================================================================================
Parametros--------: 	_cNumSA - Numero da SA
                  _cProd - Produto
                  _cArmz - Armaz�m
===============================================================================================================================
Retorno-----------:  _nQtd - Quantidade n�o atendida
===============================================================================================================================
*/
Static Function CalcSolic(_cNumSA As Character, _cProd As Character, _cArmz As Character) As Numeric

Local _nQtd      := 0 As Numeric
Local _cQuery    := "" As Character
Local _cAliasSCP := GetNextAlias() As Character

_cQuery := " SELECT  SUM(CP.CP_QUANT - CP.CP_QUJE) QUANT "
_cQuery += " FROM " + RetSqlName("SCP") + " CP "
_cQuery += " WHERE CP.D_E_L_E_T_ = ' ' "
_cQuery += " AND CP.CP_STATUS = ' ' "
_cQuery += " AND CP.CP_FILIAL = '"+xFilial("SCP")+"' " 
_cQuery += " AND CP.CP_PRODUTO = '"+_cProd+"' "
_cQuery += " AND CP.CP_LOCAL = '"+_cArmz+"' "
_cQuery += " AND CP.CP_NUM <> '"+_cNumSA+"' "
_cQuery += " AND CP.CP_PREREQU = ' ' " 

MPSysOpenQuery( _cQuery,_cAliasSCP )

DbSelectArea(_cAliasSCP)
If (_cAliasSCP)->(!EOF())

   _nQtd := (_cAliasSCP)->QUANT	

EndIf

(_cAliasSCP)->(dbCloseArea())

Return _nQtd

/*
===============================================================================================================================
Programa----------: Vldinves
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 13/10/2015 
===============================================================================================================================
Descri��o---------: Valida se campo local de investimento � edit�vel ou n�o
===============================================================================================================================
Parametros--------: Nenhum	
===============================================================================================================================
Retorno-----------:  _lret - campo edit�vel ou n�o
===============================================================================================================================
*/
User function vldinves() As Logical

Local _lret := .T. As Logical

if acols[n][ascan(aHeader , {|X| UPPER( Alltrim( X[2] ) ) == "CP_I_INVES"     } )] <> "S"

  _lret := .F.
  
Endif

Return _lret

/*
===============================================================================================================================
Programa----------: Vldcc
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 13/10/2015 
===============================================================================================================================
Descri��o---------: Retorna centro de custo da filial
===============================================================================================================================
Parametros--------: 	
===============================================================================================================================
Retorno-----------:  _cCC - centro de custo da filial
===============================================================================================================================
*/
User function vldcc() As Character

Local _cCC := U_ITGETMV( "IT_CCFIL" , "18001001" ) As Character

Return _cCC
