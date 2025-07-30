/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich     | 17/12/2018 | Workaround para calcular vend bloqueado - Chamado 26771 
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges 	  | 09/10/2019 | Removidos os Warning na compila��o da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#DEFINE _ENTER CHR(13)+CHR(10)

/*
===============================================================================================================================
Programa----------: FA440VLD
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 15/02/2011
===============================================================================================================================
Descri��o---------: Ponto de entrada para realizar valida��es customizadas no c�lculo de comiss�o.
					Este ponto de entrada tem como finalidade criar valida��es adicionais a serem utilizadas na gera��o de 
					comiss�es, antes da grava��o da tabela SE3 (Comiss�es de Vendas).
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _lret - permite ou n�o o rec�lculo
===============================================================================================================================
*/
User Function FA440VLD()

Local _cTipComis:= PARAMIXB 
Local _lRet     := .T.
Local _sDtComiBx:= GetMv("IT_COMISBA")    
Local _aSE1 := GetArea("SE1") 
Local _aSE3 := GetArea("SE3") 
Local _aSE5 := GetArea("SE5") 

//Se veio da tela de gest�o de comiss�o
//finge que est� chamando direto do
//menu para n�o mudar o jeito de c�lculo do padr�o
If funname() == "MOMS009"
	lFina440 := .T.
EndIf

//============================================================
//Tipo da comissao igual 2 indica que a comissao esta sendo 
//gerada na baixa do titulo.                                
//============================================================
If _cTipComis == 2   	                            

	//==============================================================
	//Verifica se o titulo que vai gerar a comissao nao foi gerado
	//pela fatura, ou seja, varios titulos incluidos em um mesmo  
	//titulo para realizacao da baixa.                            
	//==============================================================
	If AllTrim(SE1->E1_ORIGEM) == 'FINA280'   
		_lRet:= VldFatura(SE1->E1_PREFIXO,SE1->E1_NUM,_sDtComiBx)
	 	
	//=====================================================================
	//Verifica se o titulo baixado foi gerado a partir de uma liquidacao,
	//pois caso tenha sido gerado sera necessario verificar os titulos   
	//que compoem esta liquidacao para constatar se eles se enquadram    
	//na data de inicio do pagamento de comissao pela baixa do titulo.   
	//=====================================================================
	ElseIf AllTrim(SE1->E1_ORIGEM) == 'FINA460'   
		_lRet:= VldLiquid(SE1->E1_NUMLIQ,_sDtComiBx)      
	Else
		//=============================================================
		//Somente a partir da data que consta no parametro IT_COMISBA
		//eh que sera possibilitada a geracao da comissao na baixa.  
		//=============================================================
		If SE1->E1_EMISSAO < StoD(_sDtComiBx)
			_lRet:= .F.
		EndIf 	
	EndIf			

//=================================================================
//Caso o tipo da baixa seja na emissao nao sera gerada a comissao
//pois nao trabalhamos com esse tipo de geracao de comissao.     
//=================================================================
Else
	_lRet:= .F.
EndIf   

SE1->(Restarea(_aSE1))
SE3->(Restarea(_aSE3))
SE5->(Restarea(_aSE5))

Return _lRet

/*
===============================================================================================================================
Programa----------: VldFatura
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 15/02/2011
===============================================================================================================================
Descri��o---------: Valida se t�tulo � fatura (titulo gerado antes do inicio de pagamento de comiss�o)
===============================================================================================================================
Parametros--------:  _cPrefixo - Prefixo da fatura
					_cNumTitul - Numero do titulo da fatura
					_sDtComis - Data de Inicio Comissao
===============================================================================================================================
Retorno-----------: _lret - valida ou n�o o t�tulo
===============================================================================================================================
*/
Static Function VldFatura(_cPrefixo,_cNumTitul,_sDtComis)
  
Local _lRet     := .T.
Local _cTitulos:= ""
Local _cAlias  := GetNextAlias()

BeginSql alias _cAlias
	SELECT E1_PREFIXO, E1_TIPO, E1_NUM, E1_PARCELA
	  FROM %Table:SE1%
	 WHERE D_E_L_E_T_ = ' '
	   AND E1_FILIAL = %xFilial:SE1%
	   AND E1_FATPREF = %exp:_cPrefixo%
	   AND E1_FATURA = %exp:_cNumTitul%
	   AND E1_EMISSAO < %exp:_sDtComis%
EndSql     

//================================================================
//Percorre todos os titulos que fazem parte da fatura para pegar
//os dados dos que possuem a emissao inferior a data permitida  
//para geracao da comissao na baixa, desta forma nao sera gerada
//comissao para nenhum titulo que faz parte da fatura.          
//================================================================
While (_cAlias)->(!Eof())
	_lRet:= .F.
	_cTitulos+= ",[ " + (_cAlias)->E1_PREFIXO + "-" + (_cAlias)->E1_TIPO + " - " + (_cAlias)->E1_NUM + "/" + (_cAlias)->E1_PARCELA + " ]"
	(_cAlias)->(dbSkip())
EndDo

(_cAlias)->(DBCloseArea())

Return _lRet                          
                 
/*
===============================================================================================================================
Programa----------: VldLiquid
Autor-------------: Fabiano Dias da Silva
Data da Criacao---: 16/02/2011
===============================================================================================================================
Descri��o---------: Valida se t�tulo � liquidacao (titulo gerado a partir de v�rios t�tulos)
===============================================================================================================================
Parametros--------:  _cNunLiqui - Numero da Liquidacao
					_sDtComis - Data de Inicio Comissao
===============================================================================================================================
Retorno-----------: _lret - valida ou n�o o t�tulo
===============================================================================================================================
*/
Static Function VldLiquid(_cNunLiqui,_sDtComis)

Local _lRet     := .T.
Local _cTitulos:= ""
Local _cAlias  := GetNextAlias()

BeginSql alias _cAlias
	SELECT E1.E1_PREFIXO, E1.E1_TIPO, E1.E1_NUM, E1.E1_PARCELA
	  FROM %Table:SE5% E5, %Table:SE1% E1
	 WHERE E5.D_E_L_E_T_ = ' '
	   AND E1.D_E_L_E_T_ = ' '
	   AND E1.E1_FILIAL = E5.E5_FILIAL
	   AND E1.E1_PREFIXO = E5.E5_PREFIXO
	   AND E1.E1_TIPO = E5.E5_TIPO
	   AND E1.E1_NUM = E5.E5_NUMERO
	   AND E1.E1_CLIENTE = E5.E5_CLIFOR
	   AND E1.E1_LOJA = E5.E5_LOJA
	   AND E1.E1_PARCELA = E5.E5_PARCELA
	   AND E5.E5_MOTBX = 'LIQ'
	   AND E5.E5_TIPODOC = 'BA'
	   AND E5.E5_SITUACA <> 'C'
	   AND E1.E1_FILIAL = %xFilial:SE1%
	   AND E5.E5_FILIAL = %xFilial:SE5%
	   AND E5.E5_DOCUMEN = %exp:_cNunLiqui%
	   AND E1.E1_EMISSAO < %exp:_sDtComis%
EndSql      

//==============================================================
//Seleciona os dados dos titulos que nao se enquadram na      
//data de inicio de pagamento de comissao pela baixa do titulo
//para emitir posteriormente msg informando ao usuario.       
//==============================================================
While (_cAlias)->(!Eof())
	_lRet:= .F.
	_cTitulos+= ",[ " + (_cAlias)->E1_PREFIXO + "-" + (_cAlias)->E1_TIPO + " - " + (_cAlias)->E1_NUM + "/" + (_cAlias)->E1_PARCELA + " ]"
	(_cAlias)->(dbSkip())
EndDo

(_cAlias)->(DBCloseArea())

Return _lRet