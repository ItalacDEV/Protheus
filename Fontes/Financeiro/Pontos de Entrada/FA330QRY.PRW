/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 03/12/2018 | Chamado 27196 - Inclusão de teste de variaveis para quando não executa pergunte
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 13/12/2018 | Chamado 27244 - Ajuste de variáveis e performance
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 23/01/2019 | Chamado 27495 - Retirada de pergunte redundante 
-------------------------------------------------------------------------------------------------------------------------------
 Igor Melgaço     | 06/05/2022 | Chamado 39987 - Substituição do E1_EMISSAO pelo E1_EMIS1 na query
===============================================================================================================================
*/

#Include "Protheus.ch"

/*
===============================================================================================================================
Programa----------: FA330QRY
Autor-------------: Josué Danich Prestes
Data da Criacao---: 01/11/2017
===============================================================================================================================
Descrição---------: Ponto de entrada de filtro do browse da tela de compensação - Chamado 22322
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: paramixb[1] - filtro sql
===============================================================================================================================
*/
User Function FA330QRY()

Local _cini := " " 
Local _cfim := " " 
Local _cfil := " "

//Testa para ver se paramixb veio com query 
If type("paramixb[1]") == "C"

	If "ORDER BY" $ paramixb[1]

		_cini := left(paramixb[1],at("ORDER BY",paramixb[1])-1)
		_cfim := right(paramixb[1],(len(paramixb[1])+1-at("ORDER BY",paramixb[1])))
		
	Else
	
		_cini := paramixb[1]
		_cfim := ""
		
	Endif
	
Else

	u_itmsg("Falha de localização de títulos","Atenção","Contate o TI - Filial " + SE1->E1_FILIAL + " - Titulo " + SE1->E1_NUM ,1)
	
	Return 

Endif

//Retesta mv_par para garantir que foram carregados corretamente
If type("MV_PAR18") == "D" .and. type("MV_PAR16") == "C" .AND. TYPE("MV_PAR17") == "N"
   
    
	If !(MV_PAR18 > STOD('20010101'))

		MV_PAR18 := STOD('20010101')
	
	Endif

	If !empty(MV_PAR16)

		_cfil += " AND SE1.E1_TIPO = '" + ALLTRIM(MV_PAR16) + "' "
  
	Endif

	If MV_PAR17 == 2

		_cfil += " AND SE1.E1_NUM = '" + ALLTRIM(SE1->E1_NUM) + "' " 
  
	Endif
	
	//paramixb[1] := _cini + _cfil + " AND SE1.E1_EMISSAO > '" + DTOS(MV_PAR18) + "' " + _cfim
	paramixb[1] := _cini + _cfil + " AND SE1.E1_EMIS1 > '" + DTOS(MV_PAR18) + "' " + _cfim
	
Else

	//Se falhou carga de parametros manda filtro restrito para não ter demora no processamento

	u_itmsg("Falha de leitura de parâmetros, carregando somente título com mesmo número","Atenção","Entre no F12 para carregar parâmetros",1)

	_cfil += " AND SE1.E1_NUM = '" + ALLTRIM(SE1->E1_NUM) + "' " 
	paramixb[1] := _cini + _cfil + _cfim

Endif



Return paramixb[1]
