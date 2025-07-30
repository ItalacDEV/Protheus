/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
       Autor   |    Data  |                                             Motivo                                            
-------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich  | 24/08/15 | Chamado 11392. Ajustada an�lise de pre�o para somente PA ou grupo 0803
-------------------------------------------------------------------------------------------------------------------------------
 Josu� Danich  | 11/09/15 | Chamado 11766. Ajustada rotina para trabalhar com tabelas independentes por filial destino  
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 29/06/17 | Chamado 20621. Novo tratamento para o preco com a operacao 22         
------------------------------------------------------------------------------------------------------------------------------- 
 Julio Paz     | 18/06/17 | Chamado 22002. Inclus�o do trataemento do tipo de opera��es 22 e tabela Z09. 
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer | 29/08/23 | Chamado 43598. Alteracao da valida��o do PV quando for Opera��o de Transfer�ncia (c�digo 20).
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz     |25/04/2024| Chamado 46904. Desenvolver rotina p/buscar ultimo pre�o de compra p/ opera��es 22 e filias 20;23;93
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#include "protheus.ch"
#include "topconn.ch" 
#INCLUDE "RWMAKE.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "FONT.CH"
/*
===============================================================================================================================
Programa----------: AOMS002 
Autor-------------: Josu� Prestes
Data da Criacao---: 28/07/2015  
===============================================================================================================================
Descri��o---------: Gatilho para preencher o pre�o em pedido de venda de transfer�ncia - Chamado 11064	
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function AOMS002(_cCpoGatilho)

Local _npreco := 0 
Local _aArea     := getarea()
Local _cfildest  := ""
Local _cfiltab   := ""
Local _cfilmed   := ""
Local _ndiamed   := 15
Local _nfatortra := 1.0476
Local _dinicial  := stod('20010101')
Local _dfinal    := stod('20010101') 
Local _cmens     := ""
Local _cSvFilAnt := cFilAnt //Salva a Filial Anterior
Local _adatas    := {} , A
Local _nPosArm   := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "C6_LOCAL"  } ) // C�digo do Armaz�m
Local _nPosProd  := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "C6_PRODUTO"} )
Local _nPosPreco := aScan( aHeader , {|X| Upper( AllTrim( X[2] ) ) == "C6_PRCVEN"} )
Local _cOpPMedio := U_ITGETMV( 'IT_OPMEDIO' , "22" ) //Operacao do que busca o preco medio do SB2
Local _lRet      := .T.
Local _cFilBxEst, _cCFOBxEst 

DEFAULT _cCpoGatilho:="C6_PRODUTO"

Begin Sequence 

   U_ITLOGACS()//Grava log de utiliza��o da rotina

   //====================================================================================  
   // Busca no item da nota de entrada o ultimo valor de compra para retornar 
   // para o item do pedido de vendas, para tipos de opera��es Baixa de Estoques. 
   //====================================================================================
   _cFilBxEst := U_ITGETMV( 'IT_FILBXES' , "20;23;93") // Filiais de Baixa de Estoques.
   If "/" $ _cFilBxEst
      _cFilBxEst := StrTran(_cFilBxEst,'/',";")
   EndIf 

   If M->C5_I_OPER == "22" .And. AllTrim(SM0->M0_CODFIL) $ _cFilBxEst
      _cCFOBxEst := U_ITGETMV( 'IT_CFOBXES' , "1101;1102;1122;1151;1152;1403;2101;2102;2122;2151;2152;2403;") // CFOPs de Baixa de Estoques. 
      
	  If "/" $ _cCFOBxEst
         _cCFOBxEst := StrTran(_cCFOBxEst,'/',";")
      EndIf 

      _cCodProd := Alltrim(aCols[n][_nPosProd])

      //_nPreco := U_AOMS002B(_cCodProd, _cFilBxEst, _cCFOBxEst,  dDataBase)
	  _nPreco := U_AOMS002B(_cCodProd, AllTrim(SM0->M0_CODFIL), _cCFOBxEst,  dDataBase)

      If _nPreco > 0
		 Break
	  EndIf 
   EndIf 
   
   //====================================================================================
   // Para tipo de opera��es 22 verificar se as filiais de origem e destino na tabela Z09
   // s�o iguais a filial de login do usu�rio, e se o produto informado � igual  
   // ao produto da tabela Z09, e o codigo de opera��o da tabela Z09 � igual a 22.
   // Caso esta condi��o seja afirmativa, retornar o pre�o da tabela Z09.
   //==================================================================================
   Z09->( dbsetorder(3) ) // Z09_FILIAL+Z09_FILORI+Z09_FILDES+Z09_CODOPE+Z09_CODPRO   

   If (M->C5_I_OPER $ _cOpPMedio) .And. Z09->(DbSeek(xFilial("Z09")+ALLTRIM(SM0->M0_CODFIL)+ALLTRIM(SM0->M0_CODFIL)+M->C5_I_OPER+aCols[n][_nPosProd])) 
      If (Date() >= Z09->Z09_INIVIG .And. Date() <= Z09->Z09_FIMVIG)
         _npreco := Z09->Z09_PRECO  // Return Z09->Z09_PRECO
		 Break
      Else
         If ! U_ItMsg('N�o ser� poss�vel sugerir pre�o para o produto "'+Alltrim(aCols[n][_nPosProd])+'" pois a data atual '+Dtoc(Date())+;
            ' est� fora do per�odo de vigencia da tabela de pre�o para o tipo de opera��o 22.'+;
            ' O atual per�odo de vigencia da tabela de pre�os para este produto vai de '+ DToc(Z09->Z09_INIVIG) +' at� ' + Dtoc(Z09->Z09_FIMVIG) + '.', 'Aten��o!' ,;
            'Para que seja poss�vel sugerir um pre�o para o produto "'+Alltrim(aCols[n][_nPosProd])+;
            '", � necess�rio cadastrar um novo per�odo de vig�ncia para este produto e para o tipo de opera��o 22. Deseja usar o custo m�dio mesmo assim?' ,1,2 )
            _lRet := .F.
         EndIf
      EndIf 
   EndIf
 
   If _lRet .And. M->C5_I_OPER $ _cOpPMedio// "22"
   
      _nPreco:=Posicione( "SB2" , 1 , xFilial("SB2") + aCols[n][_nPosProd] + aCols[n][_nPosArm] , "B2_CM1" )
      If _nPreco # 0
         Break //Return _nPreco
      EndIf 

      _cTpProd:=Posicione("SB1",1,xfilial("SB1")+aCols[n][_nPosProd],"B1_TIPO")
      If _cTpProd = "PA"
         _aArm:={'20','30','31','21'}
      Else 
         _aArm:={'04','02','00'}
      EndIf 

      For A := 1 To LEN(_aArm)
          _nPreco:=Posicione( "SB2" , 1 , xFilial("SB2") + aCols[n][_nPosProd] + _aArm[A] , "B2_CM1" )
          If _nPreco # 0
             Exit 
          EndIf 
      Next 

      If _nPreco = 0
	     xMagHelpFis("AOMS002"	,;
	      		  "Custo m�dio do produto n�o encontrado",;
				  "favor entrar em contato com o departamento de Custos para verificar o custo m�dio do produto")      
      EndIf

      Break //Return _nPreco

   ElseIf _cCpoGatilho == "C6_LOCAL"

      _nPreco := aCols[n][_nPosPreco] // Return aCols[n][_nPosPreco]
	  Break 

   EndIf 

   dbselectarea("Z09")
   Z09->( dbsetorder(2) )

   If M->C5_I_OPER = "20" .AND. ;//posicione("SB1",1,xfilial("SB1")+alltrim(M->C6_PRODUTO),"B1_TIPO") == 'PA' .OR. Posicione("SB1",1,xfilial("SB1")+alltrim(M->C6_PRODUTO),"B1_GRUPO") == '0813') .AND. ;
      Z09->(DbSeek(XFilial("Z09")+M->C5_I_OPER))
	
	  //s� verifica se o produto � PA ou Pallet e  existir pelo menos um cadastro da opera��o na z09

	  //verifica se cliente tem campo filial origem v�lido
	  dbselectarea("SA1")
	  SA1->( dbsetorder(1) )
	
	  If SA1->( dbseek(xfilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI) )
	  
	 	 If !(alltrim(SA1->A1_I_FILOR) >= '01' .and. alltrim(SA1->A1_I_FILOR) <= 'ZZ')
		
		    xMagHelpFis("AOMS002"	,;
		    "Cliente n�o � filial v�lida para receber transfer�ncia",;
		    "Favor solicitar apoio ao Departamento Fiscal.")
	        _nPreco := 0 // Return 0
  		    Break 
  	     EndIf
  		
  	  EndIf
  		
  	  _cfildest  := alltrim(posicione("SA1",1,xfilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"SA1->A1_I_FILOR")) //filial destino do cliente selecionado

	  _cfiltab   := U_ITGETMV("IT_FILTABT",_cfildest) //filiais que usam tabela de pre�o
	  _cfilmed   := U_ITGETMV("IT_FILMEDT","") //filiais que usam m�dia de pre�o   
	  _ndiamed   := U_ITGETMV("IT_DIASTRA",15)  //dias corridos para fazer a m�dia de pre�o
	  _nfatortra := 0 //fator a ser aplicado a m�dia de pre�o
	  _cproduto  := alltrim(M->C6_PRODUTO)
   
	  //muda para filial destino para pegar o par�metro
	  cFilAnt := _cfildest

	  _nfatortra := U_ITGETMV("IT_FATORTRA",1.0476) //fator a ser aplicado a m�dia de pre�o
	
	  //volta a filial local
	  cFilAnt := _cSvFilAnt

	  //Se filial destino pertence ao IT_FILMEDTRA usa m�dia de pre�o
	  If alltrim(_cfildest) $ _cfilmed

		  //calcula faixa de an�lise de m�dia de vendas
    	  //ultimo dia de venda desde que n�o seja o dia atual (que n�o est� completo) menos a quantidade de dias do IT_DIASTRA
          _adatas := U_AOMS002C(_cfildest,_cproduto,_ndiamed)
          _dinicial := _adatas[1]
          _dfinal   := _adatas[2]     	  
	  
	      //calcula m�dia de preco de vendas
	      _npreco := U_AOMS002M(_dinicial,_dfinal,_cfildest,_cproduto,_nfatortra)
	 
	 	  If _npreco == 0
  		  
    		 //se n�o achar vendas do produto na filial destino avisa e usa tabela de pre�os de transfer�ncia
    		 _cmens := "tabela"
     
  		  EndIf
  	
	  Else  

  	     //marca flag para executa c�lculo por tabela de pre�o de transfer�ncia
  		 _cmens     := "tabela"

	  EndIf

	  If len(_cmens) > 1

  		 //carrega pre�o da tabela de precos de transferencia para a opera��o do pedido de vendas
  	     _npreco := U_AOMS002P(M->C6_PRODUTO,xfilial("SC5"),_cfildest,M->C5_I_OPER)[1]
  
	  EndIf

   EndIf
   
End Sequence 

restarea(_aArea)	
	
Return	_npreco

/*
===============================================================================================================================
Programa----------: AOMS002C 
Autor-------------: Josu� Prestes
Data da Criacao---: 30/07/2015  
===============================================================================================================================
Descri��o---------: C�lcula faixa de datas a partir de ultima venda e tamanho do per�odo  - Chamado 11064	
===============================================================================================================================
Parametros--------: 	_cfildest	Filial
						_cproduto	Produto
						_ndiamed	Quantidade de dias da faixa de datas
===============================================================================================================================
Retorno-----------: _npreco  Pre�o m�dio com fator aplicado
===============================================================================================================================
*/	
	
user function AOMS002C(_cfildest,_cproduto,_ndiamed)

Local _dinicial 	:= DATE()- 180
Local _dfinal   	:= DATE() 
Local _adatas   	:= {}
Local _cSvFilAnt	:= ""
Local _cfilzay 	:= ""
Default _cfildest	:= '99'
Default _cproduto	:= "   "
Default _ndiamed 	:= 1


//pega filial destino para a tabela zay
//muda para filial destino 
_cSvFilAnt := cFilAnt
cFilAnt    := _cfildest

_cfilzay := xfilial("ZAY")
	
//volta a filial local
cFilAnt := _cSvFilAnt


//calcula faixa de an�lise de m�dia de vendas
//ultimo dia de venda desde que n�o seja o dia atual (que n�o est� completo) menos a quantidade de dias do IT_DIASTRA
    
_cAlias := GetNextAlias()
  
BeginSql alias _cAlias
			   	
   	SELECT 
	 	max(d.d2_emissao) as dt 
	FROM 
		%table:SD2% d inner join %table:ZAY% z 
	ON d.d2_cf = z.zay_cf
	WHERE 
	   d.d2_nfori < '0' 
	   and d.d2_tipo <> 'D' 
	   and z.zay_filial = %exp:_cfilzay%
	   and z.zay_tpoper = 'V' 
	   and d.d2_filial = %exp:_cfildest%											     //filial da m�dia
	   and d.d2_emissao between %exp:_dinicial% and %exp:_dfinal%
	   and d.d2_cod =    %exp:_cproduto%                                            //produto da m�dia
	   and d.d_e_l_e_t_ = ' ' and z.d_e_l_e_t_ = ' ' 

EndSql

DbSelectArea(_cAlias)
(_cAlias)->(  dbgotop() )
  
//se achou venda define datas
if .not. (_cAlias)->( Eof() )
   	
	_dinicial  := stod((_cAlias)->dt) - _ndiamed
	_dfinal    := stod((_cAlias)->dt)
		
	if _dfinal == date() //n�o considera o dia atual por n�o ter as vendas completas e distorcer m�dia
		
		_dinicial  := _dinicial - 1				   	
		_dfinal    := _dfinal  - 1
		
	Endif 
	
		
else
	
	//se n�o achou nem em 6 meses define data inv�lida para procurar por tabela
	_dinicial := stod('20010101')
	_dfinal   := stod('20010101')
		

Endif

(_cAlias)->(  dbclosearea() )

_adatas := { _dinicial, _dfinal }

Return _adatas


/*
===============================================================================================================================
Programa----------: AOMS002M 
Autor-------------: Josu� Prestes
Data da Criacao---: 30/07/2015  
===============================================================================================================================
Descri��o---------: Calcula m�dia de preco de venda em uma filial  - Chamado 11064	
===============================================================================================================================
Parametros--------: 	_dinicial	Data inicial de an�lise
						_dfinal	Data final de an�lise
						_cfildest	Filial
						_cproduto	Produto
						_nfatortra	Fator a ser aplicado sobre a m�dia
===============================================================================================================================
Retorno-----------: _npreco  Pre�o m�dio com fator aplicado
===============================================================================================================================
*/

user function AOMS002M(_dinicial,_dfinal,_cfildest,_cproduto,_nfatortra)

Local _npreco := 0
Local _cfilzay := ""
Local _cSvFilAnt := ""
Default _dinicial := stod('20010101')
Default _dfinal   := stod('20010101')
Default _cfildest := '99'
Default _cproduto:= "   "
Default _nfatortra := 1
 	


//pega filial destino para a tabela zay
//muda para filial destino 
_cSvFilAnt := cFilAnt
cFilAnt    := _cfildest

_cfilzay := xfilial("ZAY")
	
//volta a filial local
cFilAnt := _cSvFilAnt


_cAlias := GetNextAlias()
 
BeginSql alias _cAlias  	   	
			   	
   	SELECT 
	 	sum(d.d2_quant) as quant, sum(d.d2_total) as total, sum(d.d2_total) / sum(d.d2_quant) as VLRMEDIO
	FROM %table:SD2% d  inner join %table:ZAY% z 
    ON d.d2_cf = z.zay_cf
    WHERE	d.d2_tipo <> 'D' 
    		and z.zay_filial = %exp:_cfilzay%
			and z.zay_tpoper = 'V' 
			and d.d2_emissao between %exp:_dinicial% and %exp:_dfinal%
			and d.d2_filial = %exp:_cfildest%
			and d.d2_cod =    %exp:_cproduto%                                            //produto da m�dia
			and d.d_e_l_e_t_ = ' ' and z.d_e_l_e_t_ = ' ' 

EndSql

DbSelectArea(_cAlias)
(_cAlias)->(  dbgotop() )
 
//se achou m�dia define o pre�o
if .not. (_cAlias)->( Eof() ) .and. (_cAlias)->VLRMEDIO > 0
  
	_npreco := round(((_cAlias)->VLRMEDIO / _nfatortra),2) 
  
Endif

dbSelectArea(_cAlias)
(_cAlias)->(dbCloseArea())

return _npreco


/*
===============================================================================================================================
Programa----------: AOMS002P
Autor-------------: Josu� Danich Prestes
Data da Criacao---: 09/09/2015
===============================================================================================================================
Descri��o---------: Retorna pre�o de tabela de transfer�ncia para um produtoxfilial orixfilial destx opera��o
===============================================================================================================================
Parametros--------: _cprod - Produto
					  _cfilori - Filial origem
					  _cfildes - Filial Destino
					  _coper - Opera��o
===============================================================================================================================
Retorno-----------: _apreco - matriz:
							posi��o 1: Pre�o de tabela para o produtoxfiliaisxopera��o, se n�o tiver cadastro retorna 0
							posi��o 2: margem de varia��o do pre�o permitida
===============================================================================================================================
*/
User Function AOMS002P(_cprod,_cfilori,_cfildes,_coper)

Local _apreco := {0,0}

dbselectarea("Z09")
Z09->( dbsetorder(3) )

if Z09->( dbseek(xfilial("Z09")+_cfilori+_cfildes+_coper+_cprod) )

	//procura pre�o com vig�ncia ativa
	Do while Z09->Z09_FILIAL == xfilial("Z09") .and. Z09->Z09_CODOPE == _coper;
			.and. Z09->Z09_FILORI == _cfilori .and. Z09->Z09_FILDES == _cfildes
  
		If Z09->Z09_INIVIG <=  date() .and. Z09->Z09_FIMVIG >= date() .and. alltrim(Z09->Z09_CODPRO) == alltrim(_cprod)
   
       	_apreco := {Z09->Z09_PRECO,(Z09->Z09_DESVIO/100)}
    
	   	Endif

    	Z09->( Dbskip() )
    
	Enddo

Endif

//Se n�o achou pre�o v�lido procura com filial origem e filial destino em branco
if _apreco[1] == 0

	if Z09->( dbseek(xfilial("Z09")+"  "+"  "+_coper+_cprod) )

		//procura pre�o com vig�ncia ativa
		Do while Z09->Z09_FILIAL == xfilial("Z09") .and. Z09->Z09_CODOPE == _coper; 
				.and. Z09->Z09_FILORI == "  " .and. Z09->Z09_FILDES == "  "
  
			If Z09->Z09_INIVIG <=  date() .and. Z09->Z09_FIMVIG >= date() .and. alltrim(Z09->Z09_CODPRO) == alltrim(_cprod)
   
   		 	   	_apreco := {Z09->Z09_PRECO,(Z09->Z09_DESVIO/100)}
    
		   	Endif

    		Z09->( Dbskip() )
    
		Enddo

	Endif

Endif

Return _apreco

/*
===============================================================================================================================
Programa----------: AOMS002B 
Autor-------------: Josu� Prestes
Data da Criacao---: 28/07/2015  
===============================================================================================================================
Descri��o---------: Retorna o ultimo preco de compra do produto no mes de emiss�o do pedido de vendas.
===============================================================================================================================
Parametros--------: _cCodProd = C�digo do Produto
                    _cCFOPs   = CFOPs da nota de compra
					_dDtEmiss = Data de emiss�o do Pedido de compras
===============================================================================================================================
Retorno-----------: _nRet = Ultimo valor de compras do item do pedido de vendas.
===============================================================================================================================
*/
User Function AOMS002B(_cCodProd, _cFilBxEst , _cCFOPs, _dDtEmiss) // _cCodProd, _cFilBxEst, _cCFOBxEst,  _dDtEmiss
Local _nRet := 0
Local _cQry 
Local _cAnoMes
Local _nI
Local _nTotRegs, _cDtQry, _dDtQry

Begin Sequence
   _cAnoMes := StrZero(Year(_dDtEmiss),4)+ StrZero(Month(_dDtEmiss),2)

   For _nI := 1 To 24 // Busca o ultimo Pre�o at� os ultimos 2 anos.
       _cQry := " SELECT D1_DTDIGIT, Max(SD1.R_E_C_N_O_) REGSD1 " // "SELECT D1_DTDIGIT, D1_VUNIT " 
       _cQry += " FROM  "+ RetSqlName("SD1") +" SD1 "
       _cQry += " WHERE "
       _cQry += "     SD1.D_E_L_E_T_  = ' ' "
       //_cQry += " AND D1_FILIAL IN " + FormatIn(_cFilBxEst,";")    
	   _cQry += " AND D1_FILIAL = '" + _cFilBxEst + "' "   
       _cQry += " AND TRIM(D1_CF) IN " + FormatIn(_cCFOPs,";")  
       _cQry += " AND SUBSTR(D1_DTDIGIT,1,6) = '" + _cAnoMes +"' " 
       _cQry += " AND D1_COD = '" + _cCodProd + "' "    
       _cQry += " GROUP BY D1_DTDIGIT "
       _cQry += " ORDER BY D1_DTDIGIT DESC "

       If Select("QRYSD1") > 0
	      QRYSD1->( DBCloseArea() )
       EndIf

       DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQry) , "QRYSD1" , .T. , .F. )
   
       Count To _nTotRegs
       
	   If _nTotRegs > 0 
	      Exit 
	   EndIf

       _cDtQry := _cAnoMes+"01"
       _dDtQry := StoD(_cDtQry)
	   _dDtQry := _dDtQry - 1 // Muda a data para o Mes Anterior
	   _cAnoMes := StrZero(Year(_dDtQry),4)+ StrZero(Month(_dDtQry),2)
	
   Next

   QRYSD1->(DbGotop())
   
   Do While ! QRYSD1->(Eof()) 
      SD1->(DbGoto(QRYSD1->REGSD1))

      If SD1->D1_VUNIT > 0      // QRYSD1->D1_VUNIT > 0
         _nRet := SD1->D1_VUNIT // QRYSD1->D1_VUNIT
		 Exit
	  EndIf 

      QRYSD1->(DbSkip())
   EndDo 

End Sequence 

If Select("QRYSD1") > 0
   QRYSD1->( DBCloseArea() )
EndIf

Return _nRet 



