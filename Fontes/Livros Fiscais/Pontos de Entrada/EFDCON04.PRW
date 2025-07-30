/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 02/10/2019 |  Não estava encontrado a conta de outras filiais - Chamado 30727
-------------------------------------------------------------------------------------------------------------------------------
===============================================================================================================================
*/

#define FO_READWRITE  2
#define ENTER CHR(13)+CHR(10)
/*
===============================================================================================================================
Programa----------: EFDCON04
Autor-------------: Alex Wallauer
Data da Criacao---: 10/09/2019
===============================================================================================================================
Descrição---------: PE no fonte FISX001.prw, para possibilitar a manipulação da descrição do ajuste, da informação 
                    complementar, do numero do processo e da conta contábil que tratam do detalhamento de ajuste do valor ou 
                    ajuste da base de calculo do Crédito de PIS/COFINS apurado - Chamado 27587 
===============================================================================================================================
Parametros--------: 
PARAMIXB[1]		Carácter	Chave EFD
PARAMIXB[2]		Carácter	Tipo de Ajuste
PARAMIXB[3]		Carácter	Descrição do ajuste
PARAMIXB[4]		Carácter	Código Conta Contábil
PARAMIXB[5]		Carácter	CST
PARAMIXB[6]		Número		Alíquota
PARAMIXB[7]		Número		Valor do Ajuste
PARAMIXB[8]		Carácter	Período Atual
PARAMIXB[9]		Data		Data Referência
PARAMIXB[10]	Lógico		Ajuste de Base de calculo ou de valor do tributo. Se .T. ajuste de base. Se .F. Ajuste de valor.
PARAMIXB[11]	Carácter	Tributo que está sendo ajustado. PIS = "1"; COFINS = "2"
PARAMIXB[12]	Carácter	Número do documento ou Processo
PARAMIXB[13]	Carácter	Informação complementar
===============================================================================================================================
Retorno-----------: 
aRet[1]	Carácter	Descrição do ajuste
aRet[2]	Carácter	Informação complementar do ajuste
aRet[3]	Carácter	Número do documento ou processo
aRet[4]	Carácter	Código da conta contábil
===============================================================================================================================
*/
User Function EFDCON04()

Local _aRet   := {"","","",""} 
Local _cContAju:=""

ZGH->(DBSETORDER(5))//ZGH_FILIAL+ZGH_IMPOST+ZGH_ALIQ
If ZGH->(Dbseek(cFilAnt+PARAMIXB[11]+STR(PARAMIXB[6],7,4) )) .OR. ZGH->(Dbseek("01"+PARAMIXB[11]+STR(PARAMIXB[6],7,4) ))//Tenta da Filial atual senão achar tenta da 01
   _cContAju:=ZGH->ZGH_CONTA
   _aRet:= {"","","",_cContAju} 
Endif

IF EMPTY(_cContAju)
	_cFileNome:="\DATA\ITALAC\CONTROLE\EFDCON04.CSV"
	nHandle:=0
	_cCab:='Nossa.ContaContabil;PIS="1"/COFINS="2";Alíquota;Chav.EFD;xFilial("ZGH");cFilAnt'+ENTER//;Tip.Ajuste;Desc.ajuste;Cód.ContaContabil;CST;Val.Ajuste;Per.Atual;Dt.Ref;Se.T.ajustedebase.Se.F.Ajuste.valr;Nodoc.ou.Processo;Inf.comp.'+ENTER
	IF FILE(_cFileNome)
		nHandle:=FOpen(_cFileNome,FO_READWRITE)
  	ELSE
/*		nHandle:=FCREATE(_cFileNome)
		IF nHandle > 0
			_cLinha:=_cCab
			FWrite(nHandle,_cLinha)
		ENDIF*/
	ENDIF
	
	IF nHandle > 0
		FSEEK(nHandle,0,0)
		cString:=Space(10)
		FReadLn(nHandle,@cString, 10, .F.)
		IF EMPTY(cString)
			_cLinha:=_cCab
			FWrite(nHandle,_cLinha)
		ENDIF
		_cLinha:=_cContAju+";"+PARAMIXB[11]+";"+STR(PARAMIXB[6],15,5)+";"+PARAMIXB[1]+";"+xFilial("ZGH")+";"+cFilAnt+ENTER//+";"+PARAMIXB[2]+";"+PARAMIXB[3]+";"+PARAMIXB[4]+";"+PARAMIXB[5]+";"+STR(PARAMIXB[7],15,5)+";"+PARAMIXB[8]+";"+DTOC(PARAMIXB[9])+";"+IF(PARAMIXB[10],"BASE","VALOR")+";"+PARAMIXB[12]+";"+PARAMIXB[13]+ENTER
		_cLinha:=STRTRAN(_cLinha,".",",")
		FSEEK(nHandle,0,2)
		FWrite(nHandle,_cLinha)
		FClose(nHandle)
		U_ITCONOUT(_cLinha)
	ELSE
		U_ITCONOUT("Nao abriu: "+_cFileNome)
	Endif
Endif


Return _aRet
