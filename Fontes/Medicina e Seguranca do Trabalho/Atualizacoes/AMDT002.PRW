/*
=====================================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
=====================================================================================================================================
	Autor	  |	Data	   |										Motivo																
-------------------------------------------------------------------------------------------------------------------------------------
Julio Paz     | 10/04/2018 | Ajustes nas entrega e devolução de EPI, para impressão correta dos comprovantes. Chamado 23960. 
-------------------------------------------------------------------------------------------------------------------------------------
Alex Wallauer | 11/06/2018 | Nova validação de saldo do Produto do aramzem digitado e do 05. Chamado 29619.  
=====================================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "TOTVS.CH"  
#INCLUDE "PROTHEUS.CH"
/*
===============================================================================================================================
Programa----------: AMDT002
Autor-------------: Josué Danich Prestes
Data da Criacao---: 01/09/2015
===============================================================================================================================
Descrição---------: Preenche armazém de EPI e valida quantidade selecionada com saldo de armazém padrão de EPI
===============================================================================================================================
Uso---------------: Italac - Gestão do Leite
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lret - lógico validando ou não o campo de quantidade
===============================================================================================================================
Usuario-----------: Nenhum
===============================================================================================================================
Setor-------------: TI
===============================================================================================================================
*/
User Function AMDT002()

Local _aArea 		:= GetArea()
Local _cprod 		:= ""
Local _lret 		:= .T.
Local _nsaldo 	:= 0
Local _cArmaz 	:= U_ITGETMV( "IT_ESTEPI" , "00" )

//verifica se já não tem SA
if .not. empty(alltrim(acols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_NUMSA" })]))

	alert("Entrega já possui SA!")
	_lret := .F.
	
endif


//Se for a função Funcionário x EPI
if alltrim(funname()) == "MDTA695" .and. _lret
	
	//grava código de produto a partir do campo TNF_CODEPI que contém o produto selecionado
	_cprod	:= alltrim(acols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_CODEPI" })])

	If Type("M->TNF_LOCAL") <> "U"
		_cArmaz := M->TNF_LOCAL
	Else
		_cArmaz	:= alltrim(acols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_LOCAL" })])
	EndIf

endif

//se for a função EPI x funcionário
if alltrim(funname()) == "MDTA630" .and. _lret

	//grava código de produto a partir da sb1 posicionada
	_cprod := SB1->B1_COD
	
	//preenche campo de armazém
	acols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_LOCAL" })] :=  _cArmaz 	

endif

//busca saldo disponível
dbSelectArea("SB2")

if dbSeek(xFilial("SB2") + padr(_cprod,15) + _cArmaz)

	_nsaldo := SaldoSb2()
	
endif

If Type("M->TNF_QTDENT") <> "U"
	_cQtdEnt := M->TNF_QTDENT
Else
	_cQtdEnt := acols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_QTDENT" })]
EndIf

//faz validação
if _nsaldo < _cQtdEnt .and. _lret

   _aSaldo  := {}     	
   _nSaldo05:= 0 
   IF _cArmaz <> "05"
      If SB2->(dbSeek(xFilial("SB2")+padR(_cProd,15)+"05"))
   	     fwmsgrun(, {|| _aSaldo := CalcEst(_cProd,"05",date()+1)}, "Aguarde...", "Validando estoque....")
   	     _nSaldo05 := _aSaldo[1] - SB2->B2_RESERVA - SB2->B2_QACLASS - SB2->B2_QEMPSA - SB2->B2_QEMP
   	     If _nSaldo05 < 0
   	  	    _nSaldo05 := 0
   	     Endif
      EndIf 
   EndIf 

	U_ITMSG("Somente é possível entregar até o saldo disponível: " + AllTrim(Transform(_nsaldo,"@E 9,999,999.99")),"Saldo Indisponível",;
			IF(_nSaldo05>0,"Existe saldo no armazem de reuso 05: "+CRLF+CRLF+"Saldo do Armazem de reuso 05: "+ALLTRIM(Transform(_nSaldo05,'@E 999,999,999.99')),;
			               "Dúvidas, consulte o Almoxarifado."),1)
	
	_lRet := .F.
	
Endif

If _lRet
   _aSaldo := {}
   _nSaldo := 0
   If SB2->(dbSeek(xFilial("SB2")+padR(_cProd,15)+_cArmaz))
   	  fwmsgrun(, {|| _aSaldo := CalcEst(_cProd,_cArmaz,date()+1)}, "Aguarde...", "Validando estoque....")
   	  _nsaldo := _aSaldo[1] - SB2->B2_RESERVA - SB2->B2_QACLASS - SB2->B2_QEMPSA - SB2->B2_QEMP
   	  If _nsaldo < 0
   	  	 _nsaldo := 0
   	  Endif
   EndIf 
   _nSolic := CalcSolic(_cProd,_cArmaz)
   
   If _nSaldo - _nSolic - _cQtdEnt < 0 .AND. _lRet

       _nSaldo05 := 0      	
       IF _cArmaz <> "05"
          If SB2->(dbSeek(xFilial("SB2")+padR(_cProd,15)+"05"))
       	     fwmsgrun(, {|| _aSaldo := CalcEst(_cProd,"05",date()+1)}, "Aguarde...", "Validando estoque....")
       	     _nSaldo05 := _aSaldo[1] - SB2->B2_RESERVA - SB2->B2_QACLASS - SB2->B2_QEMPSA - SB2->B2_QEMP
       	     If _nSaldo05 < 0
       	  	    _nSaldo05 := 0
       	     Endif
          EndIf 
       EndIf 

   	   U_ITMSG("Já existem solicitações a serem atendidas para esse produto:" + CRLF + CRLF + ;
   	   			" Saldo atual: "+Transform(_nSaldo,'@E 999,999,999.99') + CRLF + CRLF + ;
   	   			" Total solicitações incluindo esta: "+Transform(_nSolic+_cQtdEnt,'@E 999,999,999.99');
   	   			,"Saldo Indisponível",;
			    IF(_nSaldo05>0,"Existe saldo no armazem de reuso 05: "+CRLF+CRLF+"Saldo do Armazem de reuso 05: "+ALLTRIM(Transform(_nSaldo05,'@E 999,999,999.99')),;
				               "Dúvidas, consulte o Almoxarifado."),1)
   	   _lRet := .F.
   EndIf

EndIf

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
Parametros--------: 	_cProd - Produto
						_cArmz - Armazém
===============================================================================================================================
Retorno-----------:  _nQtd - Quantidade não atendida
===============================================================================================================================
*/
Static Function CalcSolic(_cProd,_cArmz)

Local _nQtd      := 0
Local _cQuery    := ""
Local _cAliasSCP := GetNextAlias()

_cQuery := " SELECT  SUM(CP.CP_QUANT - CP.CP_QUJE) QUANT "
_cQuery += " FROM " + RetSqlName("SCP") + " CP "
_cQuery += " WHERE CP.D_E_L_E_T_ = ' ' "
_cQuery += " AND CP.CP_STATUS = ' ' "
_cQuery += " AND CP.CP_FILIAL = '"+xFilial("SCP")+"' " 
_cQuery += " AND CP.CP_PRODUTO = '"+_cProd+"' "
_cQuery += " AND CP.CP_LOCAL = '"+_cArmz+"' "
_cQuery += " AND CP.CP_PREREQU = ' ' " 

dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQuery), _cAliasSCP, .T., .F. )

If (_cAliasSCP)->(!EOF())

	_nQtd := (_cAliasSCP)->QUANT	

EndIf

dbSelectArea(_cAliasSCP)
(_cAliasSCP)->(dbCloseArea())

Return _nQtd
