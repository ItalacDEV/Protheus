/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 14/08/2018 | Alteracao da gravação do arquivo de LOG - Chamado 25825
===============================================================================================================================
*/

#include "protheus.ch"
#define FO_READWRITE  2
#define FO_EXCLUSIVE 16    // Exclusive use (other processes have no access)
#define ENTER CHR(13)+CHR(10)
/*
===============================================================================================================================
Programa----------: EFDCON03
Autor-------------: Alex Wallauer
Data da Criacao---: 14/05/2018
===============================================================================================================================
Descrição---------: Ponto de entrada de ajuste de dados no Sped Pis/Cofins - Chamado 23254
===============================================================================================================================
Parametros--------: 
  PARAMIXB[1] //SE1/SE2/SE3
  PARAMIXB[2] //E1_NUM/E2_NUM/E5_NUMERO
  PARAMIXB[3] //E1_PREFIXO/E2_PREFIXO/E5_PREFIXO
  PARAMIXB[4] //E1_PARCELA/E2_PARCELA/E5_PARCELA
  PARAMIXB[5] //E1_TIPO/E2_TIPO/E5_TIPO
  PARAMIXB[6] //E1_CLIENTE/E2_FORNECE/E5_CLIENTE/E5_FORNECE
  PARAMIXB[7] //E1_LOJA/E2_LOJA/E5_LOJA
  PARAMIXB[8] //E1_NATUREZ/E2_NATUREZ/E2_NATUREZ
  PARAMIXB[9] //SE1->R_E_C_N_O_/SE2->R_E_C_N_O_/SE5->R_E_C_N_O_
===============================================================================================================================
Retorno-----------: _cContAju - Código da Conta Contábil Ajustada
===============================================================================================================================
*/
User Function EFDCON03()

Local _cContAju    :=  SPACE(LEN(ZGH->ZGH_CONTA)) //Se não tiver regra retorna vazio para não gerar a linha 500
Local _cTabela     :=  PARAMIXB[1] //SE1/SE2/SE3
//Local _cNumTit    :=  PARAMIXB[2] //E1_NUM/E2_NUM/E5_NUMERO
//Local _cPrefixo   :=  PARAMIXB[3] //E1_PREFIXO/E2_PREFIXO/E5_PREFIXO
//Local _cParcela   :=  PARAMIXB[4] //E1_PARCELA/E2_PARCELA/E5_PARCELA
//Local _cTipo      :=  PARAMIXB[5] //E1_TIPO/E2_TIPO/E5_TIPO
//Local _cPart      :=  PARAMIXB[6] //E1_CLIENTE/E2_FORNECE/E5_CLIENTE/E5_FORNECE
//Local _cLoja      :=  PARAMIXB[7] //E1_LOJA/E2_LOJA/E5_LOJA
Local _cNaturez    :=  PARAMIXB[8] //E1_NATUREZ/E2_NATUREZ/E2_NATUREZ
Local _nRecno      :=  PARAMIXB[9] //SE1->R_E_C_N_O_/SE2->R_E_C_N_O_/SE5->R_E_C_N_O_
Local _cFilial     :=  xFilial("ZGH")

(_cTabela)->(DBGOTO(_nRecno))

IF _cTabela = "SE1" 
   _cFilial:= SE1->E1_FILIAL
ELSEIF _cTabela = "SE2"
   _cFilial:= SE2->E2_FILIAL
ELSEIF _cTabela = "SE3"
   _cFilial:= SE3->E3_FILIAL
ENDIF

ZGH->(Dbsetorder(4))//ZGH_FILIAL+ZGH_NATURE

If ZGH->(Dbseek(_cFilial+_cNaturez )) 
   _cContAju := ZGH->ZGH_CONTA
Endif

IF EMPTY(_cContAju)
	_cFileNome:="\DATA\ITALAC\CONTROLE\SPEED500N.CSV"
	nHandle:=0
	IF FILE(_cFileNome)
		nHandle:=FOpen(_cFileNome,FO_READWRITE)
/*	ELSE
		nHandle:=FCREATE(_cFileNome)
		IF nHandle > 0
			_cLinha:="User;Filia;Natureza;Tabela;Recno"+ENTER
			FWrite(nHandle,_cLinha)
		ENDIF*/
	ENDIF
	IF nHandle > 0
       cString:=Space(10)
       FReadLn(nHandle,@cString, 10, .F.) 
       IF EMPTY(cString)
		  _cLinha:="User;Filia;Natureza;Tabela;Recno"+ENTER
          FWrite(nHandle,_cLinha)
       ENDIF
 	   _cLinha:=CUSERNAME+";"+_cFilial+";"+_cNaturez+";"+_cTabela+";"+ALLTRIM(STR( _nRecno ))+ENTER
	   FSEEK(nHandle,0,2)
	   FWrite(nHandle,_cLinha)
	   FClose(nHandle)
  	   U_ITCONOUT(_cLinha)
// 	ELSE
//		U_ITCONOUT("Nao abriu: "+_cFileNome)
	Endif
ENDIF	

//U_ITCONOUT("Filial: "+_cFilial+" / Natureza: "+ALLTRIM(_cNaturez)+" / Conta: "+_cContAju+" / TABELA: "+_cTabela+" / Recno:"+ALLTRIM(STR( _nRecno)))

Return _cContAju
