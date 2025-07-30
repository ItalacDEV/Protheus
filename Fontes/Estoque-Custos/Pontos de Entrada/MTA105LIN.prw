/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Erich Buttner  | 08/04/2013 | Chamado 03034. Melhoria da query para busca por filiais.    							          
Josué Danich    | 09/10/2015 | Chamado 11509. Inclusão de validação de campos de investimento. 	
Josué Danich    | 28/10/2015 | Chamado 12551. Melhoria de  validação de campos de investimento. 							  
Josué Danich    | 06/06/2018 | Chamado 25121. Validação de armazém e saldo disponível. 							               
Andre Lisboa    | 05/09/2019 | Chamado 28685. Validação p/ não permitir fracionamento de UM que são inteiras. 
 Alex Wallauer  | 21/10/2022 | Chamado 41652. Permitir fracionar produtos <> "PA" quando o campo ZZL_PEFROU for = "S". 
 Alex Wallauer  | 17/01/2024 | Chamado 46095. Ajuste na validação do centro de custo ser válido com campo de investimento.
==============================================================================================================================================================
Analista - Programador   - Inicio   - Envio    - Chamado - Motivo da Alteração
==============================================================================================================================================================
Andre    - Igor Melgaço  - 16/07/25 -          -  51382  - Ajustes para preenchimento obrigatório do campo Motivo (CP_I_MOTIV).
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
Descrição---------: Ponto de entrada que valida linha digitada na rotina de Solicitacao ao Armazem. 
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
   U_ITMSG("Para o armazém "+_cArmz+" não é permitido a inclusão de SAs. Armazens não permitidos: '"+AllTrim(_cArmazens)+"'.",;
           "Permissões de Acesso Italac",;
           "Entre em contato com o departamento de Custo.",1)
    _lRet := .F.
    BREAK
Else
   ZZL->(DbSetOrder(3))  
   If ZZL->(DbSeek(xFilial("ZZL")+RetCodUsr()))
      If !(_cArmz $ ZZL->ZZL_ARMAZE)
             U_ITMSG("Usuário sem permissão para utilizar este armazem. Não será possível realizar a SA. Armazens permitidos ao usuário: '"+AllTrim(ZZL->ZZL_ARMAZE)+"'.",;
                     "Permissões de Acesso Italac",;
                     "Entre em contato com o suporte do TI.",1)
             _lRet := .F.
             BREAK
      EndIf
   Endif   
EndIf

If (UPPER(FunName()) == "MATA105" .OR. UPPER(FunName()) == "AEST015") .AND. !FwIsInCallStack("MSEXECAUTO") .AND. Empty(Alltrim(_cMotiv))
   U_ITMSG("É obrigatório o preenchimento do campo Cod Motivo.",;
         'Atenção!',;
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
         U_ITMSG("O produto / linha " + ALLTRIM(_cProd) + " / " + ALLTRIM(STR(n)) + " não pode ter quantidade 1um fracionada.",;
           "Quantidade inválida",;
           "Favor ajustar a quantidade 1um para uma quantidade inteira.",1) 
           BREAK
      EndIf
   EndIf
   If  SB1->B1_SEGUM $ _cUM_NO_Fracionada
      If _nQtdAt2 <> Int(_nQtdAt2) .and. !GDDeleted(n)
         _lRet := .F.
         U_ITMSG("O produto / linha " + ALLTRIM(_cProd) + " / " + ALLTRIM(STR(n)) + " não pode ter quantidade 2um fracionada.",;
            "Quantidade inválida",;
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

   U_ITMSG("Já existem solicitações a serem atendidas para esse produto." + CRLF + CRLF + ;
            " Saldo atual: "+Transform(_nSaldo,'@E 999,999,999.99') + CRLF + CRLF + ;
            " Total solicitações incluindo esta: "+Transform(_nSolic+_nQuant+_nQtdAt,'@E 999,999,999.99');
            ,"Saldo Indisponível",	"Dúvidas, consulte o Almoxarifado.",1)
     
   _lRet := .F.
   BREAK

EndIf

//============================================
//Faz validação de campos de investimento
//============================================

If !(acols[n][len(aheader)+1])
   
   //lê campos
   _cCC 		:= acols[n][ascan(aHeader , {|X| UPPER( Alltrim( X[2] ) ) == "CP_CC"     } )]
   _cINVES	:= acols[n][ascan(aHeader , {|X| UPPER( Alltrim( X[2] ) ) == "CP_I_INVES"     } )]
   _cLOCIN	:= acols[n][ascan(aHeader , {|X| UPPER( Alltrim( X[2] ) ) == "CP_I_LOCIN"     } )]
   _cMOTIN	:= acols[n][ascan(aHeader , {|X| UPPER( Alltrim( X[2] ) ) == "CP_I_MOTIV"     } )]
   
   
   //verifica se é exceção de validação
   If 	ALLTRIM(_cMOTIN) $ ALLTRIM(_cloca) 
     
      _lexcep := .T.
     
   Endif

   //Verifica se campo de centro de custo é válido com campo de investimento
   if substr(alltrim(_cCC),1,5) $ alltrim(u_vldcc())   .and. _cINVES <> "S" .and. !(empty( _cCC )) .and. !(_lexcep) .and. !FWIsInCallStack( "MDTA695" )

      _cmens += "Item " + strzero(n,4) + " - Para Centro de custo da filial é preciso que seja solicitação de investimento." + CRLF + CRLF
      _lret := .F.

   Endif

   //Verifica se campo de centro de custo é válido com campo de investimento
   if !(substr(alltrim(_cCC),1,5) $ alltrim(_cCC))  .and. _cINVES = "S" .and. !(_lexcep)

      _cmens += "Item " + strzero(n,4) + " - Para investimento é preciso campo de centro de custo válido." + CRLF + CRLF
      _lret := .F.
   
   Endif

   //Verifica se campo investimento não está como S se o campo local de investimento estiver preenchido
   if  _cINVES <> "S" .And. !(empty( _cLOCIN )) 

      _cmens += "Item " + strzero(n,4) + " - Para ter local de investimento é preciso ser solicitação de investimento." + CRLF + CRLF
      _lret := .F.
   
   Endif

   //Verifica se campo local de investimento está preenchido se campo investimento está preenchido
   if  _cINVES = "S"  .And. (empty( _cLOCIN )) 

      _cmens += "Item " + strzero(n,4) + " - Para solicitação de investimento é obrigatório local de investimento." + CRLF + CRLF
      _lret := .F.
   
   Endif

   //Se local de investimento está preenchido garante que a descrição de investimento está preenchida
   if  _cINVES = "S"	.And. !(empty( _cLOCIN )) .and. !(_lexcep) 
 
      acols[n][ascan(aHeader , {|X| UPPER( Alltrim( X[2] ) ) == "CP_I_DESIN"     } )] := 	posicione("ZZI",1,xfilial("ZZI")+_cLOCIN,"ZZI_DESINV")
       
   Endif

Endif

//============================================
//Mostra lista de itens com problema
//============================================
If !(_lRet) .and. !(empty(_cmens))


   U_ITMSG( 'Problemas nos itens abaixo: ' + CRLF + CRLF + _cmens , 'Atenção!',;
               'Caso necessário solicite a manutenção à um usuário com acesso ou, se necessário, solicite o acesso à área de TI/ERP.' ,1 )
               
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
Descrição---------: Calcula solicitacoes nao atendidas.
===============================================================================================================================
Parametros--------: 	_cNumSA - Numero da SA
                  _cProd - Produto
                  _cArmz - Armazém
===============================================================================================================================
Retorno-----------:  _nQtd - Quantidade não atendida
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
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/10/2015 
===============================================================================================================================
Descrição---------: Valida se campo local de investimento é editável ou não
===============================================================================================================================
Parametros--------: Nenhum	
===============================================================================================================================
Retorno-----------:  _lret - campo editável ou não
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
Autor-------------: Josué Danich Prestes
Data da Criacao---: 13/10/2015 
===============================================================================================================================
Descrição---------: Retorna centro de custo da filial
===============================================================================================================================
Parametros--------: 	
===============================================================================================================================
Retorno-----------:  _cCC - centro de custo da filial
===============================================================================================================================
*/
User function vldcc() As Character

Local _cCC := U_ITGETMV( "IT_CCFIL" , "18001001" ) As Character

Return _cCC
