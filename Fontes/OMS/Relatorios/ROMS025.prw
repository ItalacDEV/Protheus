/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
   Autor      |   Data   |                              Motivo                                                          
-------------------------------------------------------------------------------------------------------------------------------
Igor Melga�o  |27/08/2024| Chamado 46903 - Adi��o de Campos de VAlores de Abatimento, Descovnto e verba
Igor Melga�o  |06/09/2024| Chamado 48444 - Corre��o de error.log
Lucas Borges  |09/10/2024| Chamado 48465. Retirada manipula��o do SX1
=========================================================================================================================================================
Analista         - Programador       - Inicio     - Envio      - Chamado - Motivo da Altera��o
---------------------------------------------------------------------------------------------------------------------------------------------------------
Antonio Ramos    -  Igor Melga�o     - 28/10/2024 - 28/10/2024 - 48925   - Ajuste para corre��o de error log e exibi��o de msg p�s exportar para excel
Antonio Ramos    -  Igor Melga�o     - 12/06/2025 - 20/06/2025 - 50837   - Ajustes para corre��o de error log e exibi��o correta de colunas de acordo com o cabe�alho
=========================================================================================================================================================
*/

#Include "Protheus.ch"      

/*
===============================================================================================================================
Programa--------: ROMS025
Autor-----------: Fabiano Dias
Data da Criacao-: 24/02/2011
Descri��o-------: Relatorio para demonstrar os valores de comissao gerados na baixa do titulo
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/  
User Function ROMS025()  
Local oProc As Object
Local _aHeader As Array
Local _aData As Array
Local _aLinha As Array
Local _nCol As Numeric
Local _nLin As Numeric
Local _nCampos As Numeric
Local _aHeaderD As Array

Private _aDados As Array
Private cPerg  As Character
Private oPrint	As Object
Private _aDadosExcel As Array
Private _aItalac_F3 As Array
Private _lPergunte As Logical
Private _aTitulo As Array

oProc     := {}
_aHeader  := {}
_aHeaderD := {}
_aData    := {}
_aLinha   := {}
_nCol     := 0
_nLin     := 0
_nCampos  := 0

_adados       := {}
cPerg         := "ROMS025N"
oPrint		  := Nil
_aDadosExcel  := {}
_aItalac_F3   := {} 
_lPergunte    := .T.  
_aTitulo      := {}

Aadd(_aDadosExcel,"G-Gerente")
Aadd(_aDadosExcel,"C-Coordenador")
Aadd(_aDadosExcel,"S-Supervisor")
Aadd(_aDadosExcel,"V-Vendedor")
Aadd(_aDadosExcel,"N-Gerente Nacional") 
               //        1           2             3             4               5            6                                           7         8        9  10  11  12
Aadd(_aItalac_F3,{"MV_PAR07",/*_cTabela*/ ,/*_nCpoChave*/ , /*_nCpoDesc*/ , /*_bCondTab*/ , "Dados a Serem Exibidos no Relat�rio Excel" , 1 , _aDadosExcel , 5,   ,   ,   })

Do While .T.
   _lPergunte := Pergunte( cPerg , .T.)
   
   If ! _lPergunte
      If U_ITMSG("Deseja realmente encerrar a emiss�o deste relat�rio?","Aten��o" , , ,2, 2) 
         Exit
      EndIf
   Else
      Exit
   EndIf
EndDo

If _lPergunte 
   If MV_PAR08 == 1
      fwmsgrun( ,{|oproc| ROMS025E(oproc) } , "Aguarde...", " Processando o relatorio..." ) // Baixa Vendedor
   ElseIf MV_PAR08 == 2
      fwmsgrun( ,{|oproc| ROMS025F(oproc) } , "Aguarde...", " Processando o relatorio..." ) // Baixa Detalhado
   ElseIf MV_PAR08 == 3
      fwmsgrun( ,{|oproc| ROMS025H(oproc) } , "Aguarde...", " Processando o relatorio..." ) // Previs�o de Comiss�o
   EndIf
   
   If MV_PAR08 == 2 // Gera os t�tulos para o relat�rio baixa detalhado.
      ROMS025D() 
   Else             // Gera os t�tulos para o relat�rio baixa vendedor e Previs�o de comiss�o.
      ROMS025C()
   EndIf 
      
   _aHeader := AClone(_aTitulo)

   If len(_aDados) > 0
	   If Len(_aDados[1]) < Len(_aHeader)
	      _nCampos := Len(_aDados[1]) 
	   Else
	      _nCampos := Len(_aHeader) 
	   EndIf

	   For _nLin := 1 to Len(_aDados)
	      _aLinha := {}
	      For _nCol := 1 to _nCampos
	        AADD(_aLinha,_adados[_nLin,_nCol])
	      Next
	      AADD(_aData,_aLinha)
	   Next
      If Len(_aHeader) > _nCampos
         For _nLin := 1 to _nCampos
            AADD(_aHeaderD,_aHeader[_nLin])
         Next
      Else
         _aHeaderD := aClone(_aHeader)
      EndIf
	   U_ITListBox( 'Fechamento de comiss�o - Anal�tico por Representante' ,_aHeaderD , _aData , .T. , 1 )
   Else
	   U_ItMsg("N�o foram encontrados dados","Aten��o",,1)
   EndIf
	
EndIf

Return()
/*
===============================================================================================================================
Programa--------: ROMS025QRY
Autor-----------: Fabiano Dias
Data da Criacao-: 24/02/2011
Descri��o-------: Funcao de monta e realiza as consultas de dados do relat�rio
Parametros------: _cAlias - Alias que ser� instanciado pela consulta
----------------: _nOpcao - Op��o de consulta que ser� processada
                  oproc   - Objeto FWMsgRun 
Retorno---------: Nenhum
===============================================================================================================================
*/                                    
Static Function ROMS025QRY( _cAlias As Character, _nOpcao As Numeric, oProc As Object )

Local _cFiltro As Character
Local _cFiltEmis As Character
Local _cFilVeCoo As Character
Local _cFilCooVe As Character
Local _cFilTRONC As Character
Local _cfiltrobon As Character
Local _cFilSemBaixa As Character
Local _cFechComis As Character
Local _cAnoMesFech As Character

_cFiltro		  := "%"
_cFiltEmis    := "%"
_cFilVeCoo	  := "%"
_cFilCooVe	  := "%"
_cFilTRONC	  := "" 
_cfiltrobon   := ""
_cFilSemBaixa := "" 
_cFechComis   := GetMv("IT_COMFECHA",.F., Space(6))
_cAnoMesFech  := ""

//====================================================================================================
// Filtra geracao da comissao
//====================================================================================================
If !Empty( MV_PAR01 )
   If MV_PAR08 <> 3 // N�o � a op��o Previs�o de Comiss�o
	  _cFiltro	+= " AND SUBSTR( E3_EMISSAO , 1 , 6 ) = '"+ SubStr( MV_PAR01 , 3 , 4 ) + SubStr( MV_PAR01 , 1 , 2 ) +"'"
	  _cFiltEmis	+= " AND SUBSTR( E3_EMISSAO , 1 , 6 ) = '"+ SubStr( MV_PAR01 , 3 , 4 ) + SubStr( MV_PAR01 , 1 , 2 ) +"'"
	  _cFilCooVe	+= " AND SUBSTR( E3_EMISSAO , 1 , 6 ) = '"+ SubStr( MV_PAR01 , 3 , 4 ) + SubStr( MV_PAR01 , 1 , 2 ) +"'"
	  _cFiltrobon	+= " AND SUBSTR( F2_EMISSAO , 1 , 6 ) = '"+ SubStr( MV_PAR01 , 3 , 4 ) + SubStr( MV_PAR01 , 1 , 2 ) +"'"
   Else // � a op��o Previs�o de Comiss�o
	  If Empty(MV_PAR09)
	     _cFiltro	 += " AND SUBSTR( E3_EMISSAO , 1 , 6 ) = '"+ SubStr( MV_PAR01 , 3 , 4 ) + SubStr( MV_PAR01 , 1 , 2 ) +"'"
	     _cFiltEmis	 += " AND SUBSTR( E3_EMISSAO , 1 , 6 ) = '"+ SubStr( MV_PAR01 , 3 , 4 ) + SubStr( MV_PAR01 , 1 , 2 ) +"'"
	     _cFilCooVe	 += " AND SUBSTR( E3_EMISSAO , 1 , 6 ) = '"+ SubStr( MV_PAR01 , 3 , 4 ) + SubStr( MV_PAR01 , 1 , 2 ) +"'"
	     _cFiltrobon += " AND SUBSTR( F2_EMISSAO , 1 , 6 ) = '"+ SubStr( MV_PAR01 , 3 , 4 ) + SubStr( MV_PAR01 , 1 , 2 ) +"'"
         //-----------------------------------------------------------------------------------------------------------------------//
	     _cFilSemBaixa += " AND SUBSTR( F2_EMISSAO , 1 , 6 ) = '"+ SubStr( MV_PAR01 , 3 , 4 ) + SubStr( MV_PAR01 , 1 , 2 ) +"'"
	  Else
	     _cFiltro	 += " AND SUBSTR( E3_EMISSAO , 1 , 6 ) >= '"+ SubStr( MV_PAR01 , 3 , 4 ) + SubStr( MV_PAR01 , 1 , 2 ) +"'"
	     _cFiltEmis	 += " AND SUBSTR( E3_EMISSAO , 1 , 6 ) >= '"+ SubStr( MV_PAR01 , 3 , 4 ) + SubStr( MV_PAR01 , 1 , 2 ) +"'"
	     _cFilCooVe	 += " AND SUBSTR( E3_EMISSAO , 1 , 6 ) >= '"+ SubStr( MV_PAR01 , 3 , 4 ) + SubStr( MV_PAR01 , 1 , 2 ) +"'"
	     _cFiltrobon += " AND SUBSTR( F2_EMISSAO , 1 , 6 ) >= '"+ SubStr( MV_PAR01 , 3 , 4 ) + SubStr( MV_PAR01 , 1 , 2 ) +"'"
		 
		 _cFiltro	 += " AND SUBSTR( E3_EMISSAO , 1 , 6 ) <= '"+ SubStr( MV_PAR09 , 3 , 4 ) + SubStr( MV_PAR09 , 1 , 2 ) +"'"
	     _cFiltEmis	 += " AND SUBSTR( E3_EMISSAO , 1 , 6 ) <= '"+ SubStr( MV_PAR09 , 3 , 4 ) + SubStr( MV_PAR09 , 1 , 2 ) +"'"
	     _cFilCooVe	 += " AND SUBSTR( E3_EMISSAO , 1 , 6 ) <= '"+ SubStr( MV_PAR09 , 3 , 4 ) + SubStr( MV_PAR09 , 1 , 2 ) +"'"
	     _cFiltrobon += " AND SUBSTR( F2_EMISSAO , 1 , 6 ) <= '"+ SubStr( MV_PAR09 , 3 , 4 ) + SubStr( MV_PAR09 , 1 , 2 ) +"'"
	     //-----------------------------------------------------------------------------------------------------------------------//
	     _cFilSemBaixa += " AND SUBSTR( F2_EMISSAO , 1 , 6 ) >= '"+ SubStr( MV_PAR01 , 3 , 4 ) + SubStr( MV_PAR01 , 1 , 2 ) +"'"
	     _cFilSemBaixa += " AND SUBSTR( F2_EMISSAO , 1 , 6 ) <= '"+ SubStr( MV_PAR09 , 3 , 4 ) + SubStr( MV_PAR09 , 1 , 2 ) +"'"
	  EndIf
	  //==========================================================================================
	  // Para as query que n�o s�o previs�o considerar o per�odo que a comiss�o n�o foi baixada.
	  //==========================================================================================
	  If ! Empty(_cFechComis) 
         _cAnoMesFech := SubStr(_cFechComis,4,4) + SubStr(_cFechComis,1,2) 
		 _cFiltro	 += " AND SUBSTR( E3_EMISSAO , 1 , 6 ) >= '" + _cAnoMesFech + "'"
	     _cFiltEmis	 += " AND SUBSTR( E3_EMISSAO , 1 , 6 ) >= '" + _cAnoMesFech + "'"
	     _cFilCooVe	 += " AND SUBSTR( E3_EMISSAO , 1 , 6 ) >= '" + _cAnoMesFech + "'"
	     _cFiltrobon += " AND SUBSTR( F2_EMISSAO , 1 , 6 ) >= '" + _cAnoMesFech + "'"
      EndIf
	  
   EndIf	
EndIf

//====================================================================================================
// Gerente Nacional  
//====================================================================================================
If !Empty( MV_PAR02 )
   _cFiltro	+= " AND F2.F2_VEND5 IN "+ FormatIn( MV_PAR02 , ";" )
   _cFilVeCoo	+= " AND F2.F2_VEND5 IN "+ FormatIn( MV_PAR02 , ";" )
   _cFilCooVe	+= " AND A3.A3_I_GERNC IN "+ FormatIn( MV_PAR02 , ";" )
   _cFiltroBON	+= " AND F2_VEND5 IN "+ FormatIn( MV_PAR02 , ";" )
   _cFilSemBaixa += " AND F2_VEND5 IN "+ FormatIn( MV_PAR02 , ";" )
EndIf

//====================================================================================================
// Gerente
//====================================================================================================
If !Empty( MV_PAR03 )
    
	_cFiltro	+= " AND F2.F2_VEND3 IN "+ FormatIn( MV_PAR03 , ";" )
	_cFilVeCoo	+= " AND F2.F2_VEND3 IN "+ FormatIn( MV_PAR03 , ";" )
	_cFilCooVe	+= " AND A3.A3_GEREN IN "+ FormatIn( MV_PAR03 , ";" )
	//_cFiltronc	+= " OR E3.E3_VEND IN "+ FormatIn( MV_PAR03 , ";" )  
	_cFiltroBON	+= " AND F2_VEND3 IN "+ FormatIn( MV_PAR03 , ";" )
    _cFilSemBaixa += " AND F2_VEND3 IN "+ FormatIn( MV_PAR03 , ";" )
    
EndIf

//====================================================================================================
// Coordenador
//====================================================================================================
If !Empty( MV_PAR04 )
    
	_cFiltro	+= " AND F2.F2_VEND2 IN "+ FormatIn( MV_PAR04 , ";" )
	_cFilVeCoo	+= " AND F2.F2_VEND2 IN "+ FormatIn( MV_PAR04 , ";" )
	_cFilCooVe	+= " AND A3.A3_SUPER IN "+ FormatIn( MV_PAR04 , ";" )
	_cFiltronc	+= " OR E3.E3_VEND IN "+ FormatIn( MV_PAR04 , ";" )
	_cFiltroBON	+= " AND F2_VEND2 IN "+ FormatIn( MV_PAR04 , ";" )
    _cFilSemBaixa += " AND F2_VEND2 IN "+ FormatIn( MV_PAR04 , ";" )

EndIf

//====================================================================================================
// Supervisor
//====================================================================================================
If !Empty( MV_PAR05 )
    
	_cFiltro	+= " AND F2.F2_VEND4 IN "+ FormatIn( MV_PAR05 , ";" )
	_cFilVeCoo	+= " AND F2.F2_VEND4 IN "+ FormatIn( MV_PAR05 , ";" )
	_cFilCooVe	+= " AND A3.A3_I_SUPE IN "+ FormatIn( MV_PAR05 , ";" )
	_cFiltronc	+= " OR E3.E3_VEND IN "+ FormatIn( MV_PAR05 , ";" )
	_cFiltroBON	+= " AND F2_VEND4 IN "+ FormatIn( MV_PAR05 , ";" )
    _cFilSemBaixa += " AND F2_VEND4 IN "+ FormatIn( MV_PAR05 , ";" )

EndIf


//====================================================================================================
// Vendedor
//====================================================================================================
If !Empty( MV_PAR06 )
    
	_cFiltro    += " AND F2.F2_VEND1 IN "+ FormatIn( MV_PAR06 , ";" )
	_cFilVeCoo  += " AND F2.F2_VEND1 IN "+ FormatIn( MV_PAR06 , ";" )
	_cFilCooVe  += " AND A3.A3_COD   IN "+ FormatIn( MV_PAR06 , ";" )
	_cFiltronc	+= " OR E3.E3_VEND IN "+ FormatIn( MV_PAR06 , ";" )
	_cFiltroBON += " AND F2_VEND1 IN "+ FormatIn( MV_PAR06 , ";" )
    _cFilSemBaixa += " AND F2_VEND1 IN "+ FormatIn( MV_PAR06 , ";" )

EndIf

_cFiltro	+= "%"
_cFiltEmis	+= "%"
_cFilVeCoo	+= "%"
_cFilCooVe	+= "%"

If !empty(_cFiltronc) .And. AllTrim(_cFiltronc) <> "%"
   _cFiltronc := "% AND (" + substr(_cFiltronc,4,len(_cFiltronc)) + ") %" 
ElseIf Empty(_cFiltronc) .Or.  AllTrim(_cFiltronc) == "%"
   _cFiltronc := "% %" 
EndIf

//_cFilTRONC	+= "%" 

Do Case

	//====================================================================================================
	// Seleciona dados para o relatorio do tipo analitico, para as comissoes de credito e debito
	//====================================================================================================
	Case _nOpcao == 1
	       
		BeginSql alias _cAlias
		
		SELECT
			E3.E3_FILIAL	AS FILIAL,
			E1.E1_EMISSAO	AS DTEMISSAO,
			E3.E3_EMISSAO	AS DTBAIXA,
			E3.E3_TIPO		AS TIPO,
			E3.E3_NUM		AS NUMERO,
			E3.E3_SERIE		AS SERIE,
			E3.E3_PREFIXO	AS PREFIXO,
			E3.E3_SEQ		AS SEQ,
			E3.E3_PARCELA	AS PARCELA,
			E3.E3_CODCLI	AS CODCLI,
			E3.E3_LOJA		AS LOJA,
			E1.E1_NOMCLI	AS NOMCLI,
			E1.E1_VALOR		AS VLRTITULO,
			E3.E3_BASE		AS BASECOMIS,
			E3.E3_COMIS		AS COMISSAO,
			E3.E3_VEND		AS CODVEND,
			A3.A3_NOME		AS NOMEVEND,
			(	SELECT COALESCE( SUM( E5.E5_VALOR ) , 0 )
				FROM %table:SE5% E5
				WHERE
					E1.E1_FILIAL    = E5.E5_FILIAL
				AND E1.E1_PREFIXO   = E5.E5_PREFIXO
				AND E1.E1_TIPO      = E5.E5_TIPO
				AND E1.E1_NUM       = E5.E5_NUMERO
				AND E1.E1_PARCELA   = E5.E5_PARCELA
				AND E1.E1_CLIENTE   = E5.E5_CLIENTE
				AND E1.E1_LOJA      = E5.E5_LOJA
				AND E5.D_E_L_E_T_   = ' '
				AND E5.E5_TIPO      = 'NF '
				AND E5.E5_TIPODOC  <> 'ES'
				AND E5.E5_SITUACA  <> 'C'
				AND E5.E5_MOTBX     = 'CMP'
				AND E5.E5_RECPAG    = 'R' ) - (	SELECT COALESCE( SUM( E5.E5_VALOR ) , 0 )
												FROM %table:SE5% E5
												WHERE
													E1.E1_FILIAL    = E5.E5_FILIAL
												AND E1.E1_PREFIXO   = E5.E5_PREFIXO
												AND E1.E1_TIPO      = E5.E5_TIPO
												AND E1.E1_NUM       = E5.E5_NUMERO
												AND E1.E1_PARCELA   = E5.E5_PARCELA
												AND E1.E1_CLIENTE   = E5.E5_CLIENTE
												AND E1.E1_LOJA      = E5.E5_LOJA
												AND E5.D_E_L_E_T_   = ' '
												AND E5.E5_TIPO     IN ('NF ','ICM')
												AND E5.E5_TIPODOC   = 'ES'
												AND E5.E5_SITUACA  <> 'C'
												AND E5.E5_MOTBX     = 'CMP'
												AND E5.E5_RECPAG    = 'P' ) COMPENSACAO,
			(	SELECT COALESCE( SUM( E5.E5_VALOR ) , 0 )
				FROM %table:SE5% E5
				WHERE
					E1.E1_FILIAL    = E5.E5_FILIAL   
				AND E1.E1_PREFIXO   = E5.E5_PREFIXO
				AND E1.E1_TIPO      = E5.E5_TIPO
				AND E1.E1_NUM       = E5.E5_NUMERO
				AND E1.E1_PARCELA   = E5.E5_PARCELA
				AND E1.E1_CLIENTE   = E5.E5_CLIENTE
				AND E1.E1_LOJA      = E5.E5_LOJA
				AND E5.D_E_L_E_T_   = ' ' 
				AND E5.E5_SITUACA  <> 'C'
				AND ( (		E5.E5_TIPO     = 'NF '
						AND E5.E5_TIPODOC <> 'ES'
						AND E5.E5_MOTBX   IN ('DCT','VBC')
						AND E5.E5_NATUREZ IN ('231002','231017','231019','231013','231014','231015','231016','233004','111001')
						AND E5.E5_RECPAG   = 'R')
					OR (	E5_TIPODOC     = 'DC' ) ) ) DESCONTO,
			(	SELECT COALESCE( SUM( E5.E5_VALOR ) , 0 )
				FROM %table:SE5% E5
				WHERE
					E1.E1_FILIAL    = E5.E5_FILIAL   
				AND E1.E1_PREFIXO   = E5.E5_PREFIXO
				AND E1.E1_TIPO      = E5.E5_TIPO
				AND E1.E1_NUM       = E5.E5_NUMERO
				AND E1.E1_PARCELA   = E5.E5_PARCELA
				AND E1.E1_CLIENTE   = E5.E5_CLIENTE
				AND E1.E1_LOJA      = E5.E5_LOJA
				AND E5.D_E_L_E_T_   = ' '
				AND E5.E5_TIPO      = 'NF '   
				AND E5.E5_TIPODOC  <> 'ES'   
				AND E5.E5_SITUACA  <> 'C'
				AND E5.E5_MOTBX    IN ('NOR','DAC','FAT','LQ ')
				AND E5.E5_RECPAG    = 'R'
				AND E5.E5_DATA      < E3.E3_EMISSAO ) - (	SELECT COALESCE( SUM( E5.E5_VALOR ) , 0 )
															FROM %table:SE5% E5
															WHERE
																E1.E1_FILIAL        = E5.E5_FILIAL
															AND E1.E1_PREFIXO   = E5.E5_PREFIXO
															AND E1.E1_TIPO      = E5.E5_TIPO
															AND E1.E1_NUM       = E5.E5_NUMERO
															AND E1.E1_PARCELA   = E5.E5_PARCELA
															AND E1.E1_CLIENTE   = E5.E5_CLIENTE
															AND E1.E1_LOJA      = E5.E5_LOJA
															AND E5.D_E_L_E_T_   = ' '
															AND E5.E5_TIPO      = 'NF '
															AND E5.E5_TIPODOC   = 'ES'
															AND E5.E5_SITUACA  <> 'C'
															AND E5.E5_MOTBX    IN ( 'NOR' , 'DAC' , 'FAT' , 'LQ ' )
															AND E5.E5_RECPAG    = 'P' ) BAIXASANT,
      		'C' ORDENADACAO, E3.E3_NUM E3NUMORI,E3.E3_SERIE E3SERORI,

         NVL((SELECT SUM(SE1_2.E1_VALOR) 
               FROM %table:SE1% SE1_2 
               WHERE SE1_2.E1_FILIAL = E1.E1_FILIAL AND SE1_2.E1_NUM = E1.E1_NUM AND SE1_2.E1_PREFIXO='DCT' AND SE1_2.E1_CLIENTE = E1.E1_CLIENTE AND SE1_2.E1_LOJA = E1.E1_LOJA AND SE1_2.E1_PARCELA = E1.E1_PARCELA AND SE1_2.D_E_L_E_T_ =' '), 0) VALDCT, /*VALOR DESCONTO */
         NVL((SELECT SUM(SE5.E5_VALOR) 
               FROM %table:SE5% SE5 
               WHERE SE5.E5_FILORIG = E1.E1_FILIAL AND SE5.E5_NUMERO = E1.E1_NUM AND SE5.E5_PREFIXO='DCT' AND SE5.E5_CLIFOR = E1.E1_CLIENTE AND SE5.E5_LOJA = E1.E1_LOJA AND SE5.E5_PARCELA = E1.E1_PARCELA AND SE5.D_E_L_E_T_ =' '), 0) SE5DCT, /*VALOR DESCONTO COMPENSADO*/
         NVL((SELECT SUM(SE5.E5_VALOR) 
               FROM %table:SE5% SE5 
               WHERE E1.E1_PREFIXO||E1.E1_NUM||E1.E1_TIPO||E1.E1_PARCELA||E1.E1_LOJA = SE5.E5_DOCUMEN AND SE5.E5_PREFIXO='VRB' AND SE5.D_E_L_E_T_ =' '), 0) SE5VRB, /*VALOR VERBA DESCONTADO */
         NVL((SELECT SUM(F2_ICMSRET) 
               FROM %table:SF2% SF2 
               WHERE SF2.F2_FILIAL = E1.E1_FILIAL AND SF2.F2_DOC = E1.E1_NUM AND SF2.F2_SERIE = E1.E1_PREFIXO AND SF2.D_E_L_E_T_ =' '),0) VALST /*VALOR ICM ST */
         		
      FROM %table:SE3% E3
		
		JOIN %table:SE1% E1 
		ON
			E1.E1_FILIAL  = E3.E3_FILIAL
		AND E1.E1_TIPO    = E3.E3_TIPO
		AND E1.E1_PREFIXO = E3.E3_PREFIXO
		AND E1.E1_NUM     = E3.E3_NUM  
		AND E1.E1_SERIE   = E3.E3_SERIE
		AND E1.E1_PARCELA = E3.E3_PARCELA
		AND E1.E1_CLIENTE = E3.E3_CODCLI
		AND E1.E1_LOJA    = E3.E3_LOJA
		
		JOIN %table:SF2% F2
		ON
			F2.F2_FILIAL  = E3.E3_FILIAL
		AND F2.F2_DOC     = E3.E3_NUM
		AND (F2.F2_SERIE   = E3.E3_PREFIXO OR E3.E3_PREFIXO = 'R')
		AND F2.F2_CLIENTE = E3.E3_CODCLI
		AND F2.F2_LOJA    = E3.E3_LOJA
		
		JOIN %table:SA3% A3 ON A3.A3_COD = E3.E3_VEND
		
		WHERE
			E3.D_E_L_E_T_ = ' '
		AND E1.D_E_L_E_T_ = ' '
		AND F2.D_E_L_E_T_ = ' '
		AND A3.D_E_L_E_T_ = ' '
		AND E3.E3_COMIS   > 0
		AND E1.E1_ORIGEM NOT IN ( 'FINA460' , 'FINA280' )
		
		%exp:_cFiltro%
		
		UNION ALL
		
		SELECT
			E3.E3_FILIAL FILIAL,
			E1.E1_EMISSAO DTEMISSAO,
			E3.E3_EMISSAO DTBAIXA,
			E3.E3_TIPO TIPO,
			E3.E3_NUM NUMERO,
			E3.E3_SERIE		AS SERIE,
			E3.E3_PREFIXO	AS PREFIXO,
			E3.E3_SEQ		AS SEQ,
			E3.E3_PARCELA	AS PARCELA,
			E3.E3_CODCLI CODCLI,
			E3.E3_LOJA LOJA,
			E1.E1_NOMCLI NOMCLI,
			E1.E1_VALOR VLRTITULO,
			E3.E3_BASE BASECOMIS,
			E3.E3_COMIS COMISSAO,
			E3.E3_VEND CODVEND,
			A3.A3_NOME NOMEVEND,
			(	SELECT COALESCE( SUM( E5.E5_VALOR ) , 0 )
				FROM %table:SE5% E5
				WHERE
					E1.E1_FILIAL    = E5.E5_FILIAL
				AND E1.E1_PREFIXO   = E5.E5_PREFIXO
				AND E1.E1_TIPO      = E5.E5_TIPO
				AND E1.E1_NUM       = E5.E5_NUMERO
				AND E1.E1_PARCELA   = E5.E5_PARCELA
				AND E1.E1_CLIENTE   = E5.E5_CLIENTE
				AND E1.E1_LOJA      = E5.E5_LOJA
				AND E5.D_E_L_E_T_   = ' '
				AND E5.E5_TIPO      = 'NF '
				AND E5.E5_TIPODOC  <> 'ES'
				AND E5.E5_SITUACA  <> 'C'
				AND E5.E5_MOTBX     = 'CMP'
				AND E5.E5_RECPAG    = 'R' ) - (	SELECT COALESCE(SUM(E5.E5_VALOR),0)
												FROM %table:SE5% E5
												WHERE
													E1.E1_FILIAL    = E5.E5_FILIAL
												AND E1.E1_PREFIXO   = E5.E5_PREFIXO
												AND E1.E1_TIPO      = E5.E5_TIPO
												AND E1.E1_NUM       = E5.E5_NUMERO
												AND E1.E1_PARCELA   = E5.E5_PARCELA
												AND E1.E1_CLIENTE   = E5.E5_CLIENTE
												AND E1.E1_LOJA      = E5.E5_LOJA
												AND E5.D_E_L_E_T_   = ' '
												AND E5.E5_TIPO     IN ('NF ','ICM')
												AND E5.E5_TIPODOC   = 'ES'
												AND E5.E5_SITUACA  <> 'C'
												AND E5.E5_MOTBX     = 'CMP'
												AND E5.E5_RECPAG    = 'P' ) COMPENSACAO,
			(	SELECT COALESCE( SUM( E5.E5_VALOR ) , 0 )
				FROM %table:SE5% E5
				WHERE
					E1.E1_FILIAL    = E5.E5_FILIAL
				AND E1.E1_PREFIXO   = E5.E5_PREFIXO
				AND E1.E1_TIPO      = E5.E5_TIPO
				AND E1.E1_NUM       = E5.E5_NUMERO
				AND E1.E1_PARCELA   = E5.E5_PARCELA
				AND E1.E1_CLIENTE   = E5.E5_CLIENTE
				AND E1.E1_LOJA      = E5.E5_LOJA
				AND E5.D_E_L_E_T_   = ' '
				AND E5.E5_SITUACA  <> 'C'
				AND ( (		E5.E5_TIPO      = 'NF '
						AND E5.E5_TIPODOC  <> 'ES'
						AND E5.E5_MOTBX    IN ('DCT','VBC')
						AND E5.E5_NATUREZ  IN ('231002','231017','231019','231013','231014','231015','231016','233004','111001')
						AND E5.E5_RECPAG    = 'R' )
					OR ( E5_TIPODOC = 'DC' ) ) ) DESCONTO,
			(	SELECT COALESCE( SUM( E5.E5_VALOR ) , 0 )
				FROM %table:SE5% E5
				WHERE
					E1.E1_FILIAL    = E5.E5_FILIAL
				AND E1.E1_PREFIXO   = E5.E5_PREFIXO
				AND E1.E1_TIPO      = E5.E5_TIPO
				AND E1.E1_NUM       = E5.E5_NUMERO
				AND E1.E1_PARCELA   = E5.E5_PARCELA
				AND E1.E1_CLIENTE   = E5.E5_CLIENTE
				AND E1.E1_LOJA      = E5.E5_LOJA
				AND E5.D_E_L_E_T_   = ' '
				AND E5.E5_TIPO      = 'NF '
				AND E5.E5_TIPODOC  <> 'ES'
				AND E5.E5_SITUACA  <> 'C'
				AND E5.E5_MOTBX    IN ( 'NOR' , 'DAC' , 'FAT' , 'LQ ' )
				AND E5.E5_RECPAG    = 'R'
				AND E5.E5_DATA      < E3.E3_EMISSAO ) - (	SELECT COALESCE( SUM( E5.E5_VALOR ) , 0 )
															FROM %table:SE5% E5
															WHERE
																E1.E1_FILIAL    = E5.E5_FILIAL
															AND E1.E1_PREFIXO   = E5.E5_PREFIXO
															AND E1.E1_TIPO      = E5.E5_TIPO
															AND E1.E1_NUM       = E5.E5_NUMERO
															AND E1.E1_PARCELA   = E5.E5_PARCELA
															AND E1.E1_CLIENTE   = E5.E5_CLIENTE
															AND E1.E1_LOJA      = E5.E5_LOJA
															AND E5.D_E_L_E_T_   = ' '
															AND E5.E5_TIPO      = 'NF '
															AND E5.E5_TIPODOC   = 'ES'
															AND E5.E5_SITUACA  <> 'C'
															AND E5.E5_MOTBX    IN ( 'NOR' , 'DAC' , 'FAT' , 'LQ ' )
															AND E5.E5_RECPAG    = 'P' ) BAIXASANT,
			'C' ORDENADACAO, E3.E3_NUM E3NUMORI,E3.E3_SERIE E3SERORI,

         NVL((SELECT SUM(SE1_2.E1_VALOR) 
               FROM %table:SE1% SE1_2 
               WHERE SE1_2.E1_FILIAL = E1.E1_FILIAL AND SE1_2.E1_NUM = E1.E1_NUM AND SE1_2.E1_PREFIXO='DCT' AND SE1_2.E1_CLIENTE = E1.E1_CLIENTE AND SE1_2.E1_LOJA = E1.E1_LOJA AND SE1_2.E1_PARCELA = E1.E1_PARCELA AND SE1_2.D_E_L_E_T_ =' '), 0) VALDCT, /*VALOR DESCONTO */
         NVL((SELECT SUM(SE5.E5_VALOR) 
               FROM %table:SE5% SE5 
               WHERE SE5.E5_FILORIG = E1.E1_FILIAL AND SE5.E5_NUMERO = E1.E1_NUM AND SE5.E5_PREFIXO='DCT' AND SE5.E5_CLIFOR = E1.E1_CLIENTE AND SE5.E5_LOJA = E1.E1_LOJA AND SE5.E5_PARCELA = E1.E1_PARCELA AND SE5.D_E_L_E_T_ =' '), 0) SE5DCT, /*VALOR DESCONTO COMPENSADO*/
         NVL((SELECT SUM(SE5.E5_VALOR) 
               FROM %table:SE5% SE5 
               WHERE E1.E1_PREFIXO||E1.E1_NUM||E1.E1_TIPO||E1.E1_PARCELA||E1.E1_LOJA = SE5.E5_DOCUMEN AND SE5.E5_PREFIXO='VRB' AND SE5.D_E_L_E_T_ =' '), 0) SE5VRB, /*VALOR VERBA DESCONTADO */
         NVL((SELECT SUM(F2_ICMSRET) 
               FROM %table:SF2% SF2 
               WHERE SF2.F2_FILIAL = E1.E1_FILIAL AND SF2.F2_DOC = E1.E1_NUM AND SF2.F2_SERIE = E1.E1_PREFIXO AND SF2.D_E_L_E_T_ =' '),0) VALST /*VALOR ICM ST */
         		
		FROM %table:SE3% E3
		
		JOIN %table:SE1% E1
        ON
        	E1.E1_FILIAL  = E3.E3_FILIAL
        AND E1.E1_TIPO    = E3.E3_TIPO
        AND E1.E1_PREFIXO = E3.E3_PREFIXO
        AND E1.E1_NUM     = E3.E3_NUM
        AND E1.E1_SERIE   = E3.E3_SERIE
        AND E1.E1_PARCELA = E3.E3_PARCELA
        AND E1.E1_CLIENTE = E3.E3_CODCLI
        AND E1.E1_LOJA    = E3.E3_LOJA
		
		JOIN %table:SA3% A3 ON A3.A3_COD = E3.E3_VEND
		
		JOIN %table:SF2% F2
		ON
			F2.F2_FILIAL  = E3.E3_FILIAL
		AND F2.F2_DOC     = E3.E3_NUM
		AND (F2.F2_SERIE   = E3.E3_PREFIXO OR E3.E3_PREFIXO = 'R')
		AND F2.F2_CLIENTE = E3.E3_CODCLI
		AND F2.F2_LOJA    = E3.E3_LOJA
		
		
		WHERE
			E3.D_E_L_E_T_ = ' '
	    AND E1.D_E_L_E_T_ = ' '
	    AND A3.D_E_L_E_T_ = ' '
	    AND E1.E1_NUM    IN (	SELECT SE1.E1_FATURA
								FROM %table:SE1% SE1
								JOIN %table:SF2% F2
								ON
									F2.F2_FILIAL   = SE1.E1_FILIAL
								AND F2.F2_DOC      = SE1.E1_NUM
								AND (F2.F2_SERIE    = SE1.E1_SERIE OR SE1.E1_SERIE = 'R')
								AND F2.F2_CLIENTE  = SE1.E1_CLIENTE
								AND F2.F2_LOJA     = SE1.E1_LOJA
								WHERE
									SE1.D_E_L_E_T_ = ' '
								AND F2.D_E_L_E_T_  = ' '
								AND SE1.E1_FATPREF = E1.E1_PREFIXO
								AND SE1.E1_FATURA  = E1.E1_NUM
								AND SE1.E1_FILIAL  = E1.E1_FILIAL
								AND F2.F2_FILIAL   = E1.E1_FILIAL
								AND SE1.E1_FATURA <> ' '
								%exp:_cFilVeCoo% )
		%exp:_cFiltEmis%
		AND E3.E3_COMIS  > 0
		AND E1.E1_ORIGEM = 'FINA280'
		%exp:_cFiltro%
				
	    UNION ALL
	    
		SELECT
			E3.E3_FILIAL FILIAL,
			E1.E1_EMISSAO DTEMISSAO,
			E3.E3_EMISSAO DTBAIXA,
			E3.E3_TIPO TIPO,
			E3.E3_NUM NUMERO,
			E3.E3_SERIE		AS SERIE,
			E3.E3_PREFIXO	AS PREFIXO,
			E3.E3_SEQ		AS SEQ,
			E3.E3_PARCELA	AS PARCELA,
			E3.E3_CODCLI CODCLI,
			E3.E3_LOJA LOJA,
			E1.E1_NOMCLI NOMCLI,
			E1.E1_VALOR VLRTITULO,
			E3.E3_BASE BASECOMIS,
			E3.E3_COMIS COMISSAO,
			E3.E3_VEND CODVEND,
			A3.A3_NOME NOMEVEND,
			(	SELECT COALESCE( SUM( E5.E5_VALOR ) , 0 )
				FROM %table:SE5% E5
				WHERE 
					E1.E1_FILIAL    = E5.E5_FILIAL   
				AND E1.E1_PREFIXO   = E5.E5_PREFIXO
				AND E1.E1_TIPO      = E5.E5_TIPO
				AND E1.E1_NUM       = E5.E5_NUMERO
				AND E1.E1_PARCELA   = E5.E5_PARCELA
				AND E1.E1_CLIENTE   = E5.E5_CLIENTE
				AND E1.E1_LOJA      = E5.E5_LOJA
				AND E5.D_E_L_E_T_   = ' '
				AND E5.E5_TIPO      = 'NF '
				AND E5.E5_TIPODOC  <> 'ES'
				AND E5.E5_SITUACA  <> 'C'
				AND E5.E5_MOTBX     = 'CMP'
				AND E5.E5_RECPAG    = 'R' ) - (	SELECT COALESCE( SUM( E5.E5_VALOR ) , 0 )
												FROM %table:SE5% E5
												WHERE
													E1.E1_FILIAL    = E5.E5_FILIAL   
												AND E1.E1_PREFIXO   = E5.E5_PREFIXO
												AND E1.E1_TIPO      = E5.E5_TIPO
												AND E1.E1_NUM       = E5.E5_NUMERO
												AND E1.E1_PARCELA   = E5.E5_PARCELA
												AND E1.E1_CLIENTE   = E5.E5_CLIENTE
												AND E1.E1_LOJA      = E5.E5_LOJA
												AND E5.D_E_L_E_T_   = ' '
												AND E5.E5_TIPO     IN ('NF ','ICM')   
												AND E5.E5_TIPODOC   = 'ES'   
												AND E5.E5_SITUACA  <> 'C'
												AND E5.E5_MOTBX     = 'CMP'
												AND E5.E5_RECPAG    = 'P' ) COMPENSACAO,
			(	SELECT COALESCE( SUM( E5.E5_VALOR ) , 0 )
				FROM %table:SE5% E5
				WHERE
					E1.E1_FILIAL    = E5.E5_FILIAL   
				AND E1.E1_PREFIXO   = E5.E5_PREFIXO
				AND E1.E1_TIPO      = E5.E5_TIPO
				AND E1.E1_NUM       = E5.E5_NUMERO
				AND E1.E1_PARCELA   = E5.E5_PARCELA
				AND E1.E1_CLIENTE   = E5.E5_CLIENTE
				AND E1.E1_LOJA      = E5.E5_LOJA
				AND E5.D_E_L_E_T_   = ' ' 
				AND E5.E5_SITUACA  <> 'C'
				AND ( (		E5.E5_TIPO     = 'NF '
						AND E5.E5_TIPODOC <> 'ES'
						AND E5.E5_MOTBX   IN ('DCT','VBC')
						AND E5.E5_NATUREZ IN ('231002','231017','231019','231013','231014','231015','231016','233004','111001')
						AND E5.E5_RECPAG   = 'R')
					OR(		E5_TIPODOC     = 'DC' ) ) ) DESCONTO,
			(	SELECT COALESCE( SUM( E5.E5_VALOR ) , 0 )
				FROM %table:SE5% E5
				WHERE
					E1.E1_FILIAL    = E5.E5_FILIAL
				AND E1.E1_PREFIXO   = E5.E5_PREFIXO
				AND E1.E1_TIPO      = E5.E5_TIPO
				AND E1.E1_NUM       = E5.E5_NUMERO
				AND E1.E1_PARCELA   = E5.E5_PARCELA
				AND E1.E1_CLIENTE   = E5.E5_CLIENTE
				AND E1.E1_LOJA      = E5.E5_LOJA
				AND E5.D_E_L_E_T_   = ' '
				AND E5.E5_TIPO      = 'NF '
				AND E5.E5_TIPODOC  <> 'ES'
				AND E5.E5_SITUACA  <> 'C'
				AND E5.E5_MOTBX    IN ('NOR','DAC','FAT','LQ ')
				AND E5.E5_RECPAG    = 'R'
				AND E5.E5_DATA      < E3.E3_EMISSAO ) - (	SELECT COALESCE( SUM( E5.E5_VALOR ) , 0 )
															FROM %table:SE5% E5
															WHERE 
																E1.E1_FILIAL    = E5.E5_FILIAL
															AND E1.E1_PREFIXO   = E5.E5_PREFIXO
															AND E1.E1_TIPO      = E5.E5_TIPO
															AND E1.E1_NUM       = E5.E5_NUMERO
															AND E1.E1_PARCELA   = E5.E5_PARCELA
															AND E1.E1_CLIENTE   = E5.E5_CLIENTE
															AND E1.E1_LOJA      = E5.E5_LOJA
															AND E5.D_E_L_E_T_   = ' '
															AND E5.E5_TIPO      = 'NF '
															AND E5.E5_TIPODOC   = 'ES'
															AND E5.E5_SITUACA  <> 'C'
															AND E5.E5_MOTBX    IN ('NOR','DAC','FAT','LQ ')
															AND E5.E5_RECPAG    = 'P' ) BAIXASANT,
			'C' ORDENADACAO, E3.E3_NUM E3NUMORI,E3.E3_SERIE E3SERORI,

         NVL((SELECT SUM(SE1_2.E1_VALOR) 
               FROM %table:SE1% SE1_2 
               WHERE SE1_2.E1_FILIAL = E1.E1_FILIAL AND SE1_2.E1_NUM = E1.E1_NUM AND SE1_2.E1_PREFIXO='DCT' AND SE1_2.E1_CLIENTE = E1.E1_CLIENTE AND SE1_2.E1_LOJA = E1.E1_LOJA AND SE1_2.E1_PARCELA = E1.E1_PARCELA AND SE1_2.D_E_L_E_T_ =' '), 0) VALDCT, /*VALOR DESCONTO */
         NVL((SELECT SUM(SE5.E5_VALOR) 
               FROM %table:SE5% SE5 
               WHERE SE5.E5_FILORIG = E1.E1_FILIAL AND SE5.E5_NUMERO = E1.E1_NUM AND SE5.E5_PREFIXO='DCT' AND SE5.E5_CLIFOR = E1.E1_CLIENTE AND SE5.E5_LOJA = E1.E1_LOJA AND SE5.E5_PARCELA = E1.E1_PARCELA AND SE5.D_E_L_E_T_ =' '), 0) SE5DCT, /*VALOR DESCONTO COMPENSADO*/
         NVL((SELECT SUM(SE5.E5_VALOR) 
               FROM %table:SE5% SE5 
               WHERE E1.E1_PREFIXO||E1.E1_NUM||E1.E1_TIPO||E1.E1_PARCELA||E1.E1_LOJA = SE5.E5_DOCUMEN AND SE5.E5_PREFIXO='VRB' AND SE5.D_E_L_E_T_ =' '), 0) SE5VRB, /*VALOR VERBA DESCONTADO */
         NVL((SELECT SUM(F2_ICMSRET) 
               FROM %table:SF2% SF2 
               WHERE SF2.F2_FILIAL = E1.E1_FILIAL AND SF2.F2_DOC = E1.E1_NUM AND SF2.F2_SERIE = E1.E1_PREFIXO AND SF2.D_E_L_E_T_ =' '),0) VALST /*VALOR ICM ST */
         		
		FROM %table:SE3% E3
		JOIN %table:SE1% E1
		ON
			E1.E1_FILIAL  = E3.E3_FILIAL
		AND E1.E1_TIPO    = E3.E3_TIPO
		AND E1.E1_PREFIXO = E3.E3_PREFIXO
		AND E1.E1_NUM     = E3.E3_NUM
		AND E1.E1_SERIE   = E3.E3_SERIE
		AND E1.E1_PARCELA = E3.E3_PARCELA
		AND E1.E1_CLIENTE = E3.E3_CODCLI
		AND E1.E1_LOJA    = E3.E3_LOJA
		
		JOIN %table:SA3% A3 ON A3.A3_COD = E3.E3_VEND
		
		JOIN %table:SF2% F2
		ON
			F2.F2_FILIAL  = E3.E3_FILIAL
		AND F2.F2_DOC     = E3.E3_NUM
		AND (F2.F2_SERIE   = E3.E3_PREFIXO OR E3.E3_PREFIXO = 'R')
		AND F2.F2_CLIENTE = E3.E3_CODCLI
		AND F2.F2_LOJA    = E3.E3_LOJA
		
		
		WHERE
			E3.D_E_L_E_T_ = ' '
		AND E1.D_E_L_E_T_ = ' '
		AND A3.D_E_L_E_T_ = ' '
		AND E1.E1_NUMLIQ IN (	SELECT SE5.E5_DOCUMEN
								FROM %table:SE5% SE5
								JOIN %table:SF2% F2
								ON
									F2.F2_FILIAL  = SE5.E5_FILIAL
								AND F2.F2_DOC     = SE5.E5_NUMERO
								AND (F2.F2_SERIE   = SE5.E5_PREFIXO OR SE5.E5_PREFIXO = 'R')
								AND F2.F2_CLIENTE = SE5.E5_CLIFOR
								AND F2.F2_LOJA    = SE5.E5_LOJA
								WHERE
									SE5.D_E_L_E_T_  = ' '
								AND F2.D_E_L_E_T_   = ' '
								AND SE5.E5_DOCUMEN  = E1.E1_NUMLIQ
								AND SE5.E5_FILIAL   = E1.E1_FILIAL
								AND F2.F2_FILIAL    = E1.E1_FILIAL
								AND SE5.E5_DOCUMEN <> ' '
								%exp:_cFilVeCoo% )
		AND E3.E3_COMIS > 0
		%exp:_cFiltEmis%
		AND E1.E1_ORIGEM = 'FINA460'
		%exp:_cFiltro%
				
		UNION ALL
		
		SELECT
			E3.E3_FILIAL FILIAL,
			E3.E3_EMISSAO DTEMISSAO,
			E3.E3_EMISSAO DTBAIXA,
			E3.E3_TIPO TIPO,
			(	SELECT F2.F2_DOC FROM %table:SD1% D1,%table:SF2% F2
								WHERE
									D1.D_E_L_E_T_ = ' '
								AND F2.D_E_L_E_T_ = ' '
								AND E3.E3_FILIAL  = D1.D1_FILIAL 
								AND E3.E3_NUM     = D1.D1_DOC
								AND E3.E3_SERIE   = D1.D1_SERIE
								AND E3.E3_CODCLI  = D1.D1_FORNECE 
								AND E3.E3_LOJA    = D1.D1_LOJA
								AND F2.F2_FILIAL  = D1.D1_FILIAL
								AND F2.F2_DOC     = D1.D1_NFORI
								AND F2.F2_SERIE   = D1.D1_SERIORI
								AND F2.F2_CLIENTE = D1.D1_FORNECE 
								AND F2.F2_LOJA    = D1.D1_LOJA
								AND ROWNUM = 1
								%exp:_cFilVeCoo% ) NUMERO,
				(	SELECT F2.F2_SERIE FROM %table:SD1% D1,%table:SF2% F2
								WHERE
									D1.D_E_L_E_T_ = ' '
								AND F2.D_E_L_E_T_ = ' '
								AND E3.E3_FILIAL  = D1.D1_FILIAL 
								AND E3.E3_NUM     = D1.D1_DOC
								AND E3.E3_SERIE   = D1.D1_SERIE
								AND E3.E3_CODCLI  = D1.D1_FORNECE 
								AND E3.E3_LOJA    = D1.D1_LOJA
								AND F2.F2_FILIAL  = D1.D1_FILIAL
								AND F2.F2_DOC     = D1.D1_NFORI
								AND F2.F2_SERIE   = D1.D1_SERIORI
								AND F2.F2_CLIENTE = D1.D1_FORNECE 
								AND F2.F2_LOJA    = D1.D1_LOJA
								AND ROWNUM = 1
								%exp:_cFilVeCoo% ) SERIE,
			E3.E3_PREFIXO	AS PREFIXO,
			E3.E3_SEQ		AS SEQ,
			E3.E3_PARCELA PARCELA,
			E3.E3_CODCLI CODCLI,
			E3.E3_LOJA LOJA,
			A1.A1_NREDUZ NOMCLI,
			TO_NUMBER(NULL) VLRTITULO,
			E3.E3_BASE BASECOMIS,
			E3.E3_COMIS COMISSAO,
			E3.E3_VEND CODVEND,
			A3.A3_NOME NOMEVEND,
			TO_NUMBER(NULL) COMPENSACAO,
			TO_NUMBER(NULL) DESCONTO,
			TO_NUMBER(NULL) BAIXASANT,
			'D' ORDENADACAO, E3.E3_NUM E3NUMORI,E3.E3_SERIE E3SERORI,

         NVL((SELECT SUM(SE1_2.E1_VALOR) 
               FROM %table:SE1% SE1_2 
               WHERE SE1_2.E1_FILIAL = E3.E3_FILIAL AND SE1_2.E1_NUM = E3.E3_NUM AND SE1_2.E1_PREFIXO='DCT' AND SE1_2.E1_CLIENTE = E3.E3_CODCLI AND SE1_2.E1_LOJA = E3.E3_LOJA AND SE1_2.E1_PARCELA = E3.E3_PARCELA AND SE1_2.D_E_L_E_T_ =' '), 0) VALDCT, /*VALOR DESCONTO */
         NVL((SELECT SUM(SE5.E5_VALOR) 
               FROM %table:SE5% SE5 
               WHERE SE5.E5_FILORIG = E3.E3_FILIAL AND SE5.E5_NUMERO = E3.E3_NUM AND SE5.E5_PREFIXO='DCT' AND SE5.E5_CLIFOR = E3.E3_CODCLI AND SE5.E5_LOJA = E3.E3_LOJA AND SE5.E5_PARCELA = E3.E3_PARCELA AND SE5.D_E_L_E_T_ =' '), 0) SE5DCT, /*VALOR DESCONTO COMPENSADO*/
         NVL((SELECT SUM(SE5.E5_VALOR) 
               FROM %table:SE5% SE5 
               WHERE E3.E3_PREFIXO||E3.E3_NUM||E3.E3_TIPO||E3.E3_PARCELA||E3.E3_LOJA = SE5.E5_DOCUMEN AND SE5.E5_PREFIXO='VRB' AND SE5.D_E_L_E_T_ =' '), 0) SE5VRB, /*VALOR VERBA DESCONTADO */
         NVL((SELECT SUM(F2_ICMSRET) 
               FROM %table:SF2% SF2 
               WHERE SF2.F2_FILIAL = E3.E3_FILIAL AND SF2.F2_DOC = E3.E3_NUM AND SF2.F2_SERIE = E3.E3_PREFIXO AND SF2.D_E_L_E_T_ =' '),0) VALST /*VALOR ICM ST */
         		
		FROM %table:SE3% E3
		JOIN %table:SA3% A3 ON E3.E3_VEND = A3.A3_COD
		JOIN %table:SA1% A1 ON A1.A1_COD = E3.E3_CODCLI AND A1.A1_LOJA = E3.E3_LOJA
		WHERE
			E3.D_E_L_E_T_ = ' '
		AND A3.D_E_L_E_T_ = ' ' 
		%exp:_cFiltronc%  
		AND A1.D_E_L_E_T_ = ' '
		AND E3.E3_TIPO    = 'NCC'
		%exp:_cFiltEmis%
		
		AND E3.E3_NUM    IN (	SELECT D1.D1_DOC FROM %table:SD1% D1,%table:SF2% F2
								WHERE
									D1.D_E_L_E_T_ = ' '
								AND F2.D_E_L_E_T_ = ' '
								AND E3.E3_FILIAL  = D1.D1_FILIAL 
								AND E3.E3_NUM     = D1.D1_DOC
								AND E3.E3_SERIE   = D1.D1_SERIE
								AND E3.E3_CODCLI  = D1.D1_FORNECE 
								AND E3.E3_LOJA    = D1.D1_LOJA
								AND F2.F2_FILIAL  = D1.D1_FILIAL
								AND F2.F2_DOC     = D1.D1_NFORI
								AND F2.F2_SERIE   = D1.D1_SERIORI
								AND F2.F2_CLIENTE = D1.D1_FORNECE 
								AND F2.F2_LOJA    = D1.D1_LOJA
								%exp:_cFilVeCoo% )
		
		UNION ALL
		
		SELECT
			E3.E3_FILIAL	FILIAL,
			E3.E3_EMISSAO	DTEMISSAO,
			E3.E3_EMISSAO	DTBAIXA,
			E3.E3_TIPO		TIPO,
				(	SELECT F2.F2_DOC FROM %table:SD1% D1,%table:SF2% F2
								WHERE
									D1.D_E_L_E_T_ = ' '
								AND F2.D_E_L_E_T_ = ' '
								AND E3.E3_FILIAL  = D1.D1_FILIAL 
								AND E3.E3_NUM     = D1.D1_DOC
								AND E3.E3_SERIE   = D1.D1_SERIE
								AND E3.E3_CODCLI  = D1.D1_FORNECE 
								AND E3.E3_LOJA    = D1.D1_LOJA
								AND F2.F2_FILIAL  = D1.D1_FILIAL
								AND F2.F2_DOC     = D1.D1_NFORI
								AND F2.F2_SERIE   = D1.D1_SERIORI
								AND F2.F2_CLIENTE = D1.D1_FORNECE 
								AND F2.F2_LOJA    = D1.D1_LOJA
								AND ROWNUM = 1
								%exp:_cFilVeCoo% ) NUMERO,
				(	SELECT F2.F2_SERIE FROM %table:SD1% D1,%table:SF2% F2
								WHERE
									D1.D_E_L_E_T_ = ' '
								AND F2.D_E_L_E_T_ = ' '
								AND E3.E3_FILIAL  = D1.D1_FILIAL 
								AND E3.E3_NUM     = D1.D1_DOC
								AND E3.E3_SERIE   = D1.D1_SERIE
								AND E3.E3_CODCLI  = D1.D1_FORNECE 
								AND E3.E3_LOJA    = D1.D1_LOJA
								AND F2.F2_FILIAL  = D1.D1_FILIAL
								AND F2.F2_DOC     = D1.D1_NFORI
								AND F2.F2_SERIE   = D1.D1_SERIORI
								AND F2.F2_CLIENTE = D1.D1_FORNECE 
								AND F2.F2_LOJA    = D1.D1_LOJA
								AND ROWNUM = 1
								%exp:_cFilVeCoo% ) SERIE,
			E3.E3_PREFIXO	AS PREFIXO,
			E3.E3_SEQ		AS SEQ,
			E3.E3_PARCELA	PARCELA,
			E3.E3_CODCLI	CODCLI,
			E3.E3_LOJA		LOJA,
			A1.A1_NREDUZ	NOMCLI,
			TO_NUMBER(NULL)	VLRTITULO,
			E3.E3_BASE		BASECOMIS,
			E3.E3_COMIS		COMISSAO,
			E3.E3_VEND		CODVEND,
			A3.A3_NOME		NOMEVEND,
			TO_NUMBER(NULL) COMPENSACAO,
			TO_NUMBER(NULL) DESCONTO,
			TO_NUMBER(NULL) BAIXASANT,
			'D'				ORDENADACAO, E3.E3_NUM E3NUMORI,E3.E3_SERIE E3SERORI,

         NVL((SELECT SUM(SE1_2.E1_VALOR) 
               FROM %table:SE1% SE1_2 
               WHERE SE1_2.E1_FILIAL = E3.E3_FILIAL AND SE1_2.E1_NUM = E3.E3_NUM AND SE1_2.E1_PREFIXO='DCT' AND SE1_2.E1_CLIENTE = E3.E3_CODCLI AND SE1_2.E1_LOJA = E3.E3_LOJA AND SE1_2.E1_PARCELA = E3.E3_PARCELA AND SE1_2.D_E_L_E_T_ =' '), 0) VALDCT, /*VALOR DESCONTO */
         NVL((SELECT SUM(SE5.E5_VALOR) 
               FROM %table:SE5% SE5 
               WHERE SE5.E5_FILORIG = E3.E3_FILIAL AND SE5.E5_NUMERO = E3.E3_NUM AND SE5.E5_PREFIXO='DCT' AND SE5.E5_CLIFOR = E3.E3_CODCLI AND SE5.E5_LOJA = E3.E3_LOJA AND SE5.E5_PARCELA = E3.E3_PARCELA AND SE5.D_E_L_E_T_ =' '), 0) SE5DCT, /*VALOR DESCONTO COMPENSADO*/
         NVL((SELECT SUM(SE5.E5_VALOR) 
               FROM %table:SE5% SE5 
               WHERE E3.E3_PREFIXO||E3.E3_NUM||E3.E3_TIPO||E3.E3_PARCELA||E3.E3_LOJA = SE5.E5_DOCUMEN AND SE5.E5_PREFIXO='VRB' AND SE5.D_E_L_E_T_ =' '), 0) SE5VRB, /*VALOR VERBA DESCONTADO */
         NVL((SELECT SUM(F2_ICMSRET) 
               FROM %table:SF2% SF2 
               WHERE SF2.F2_FILIAL = E3.E3_FILIAL AND SF2.F2_DOC = E3.E3_NUM AND SF2.F2_SERIE = E3.E3_PREFIXO AND SF2.D_E_L_E_T_ =' '),0) VALST /*VALOR ICM ST */
         		
		FROM %table:SE3% E3
		JOIN %table:SA3% A3 ON E3.E3_VEND = A3.A3_COD
		JOIN %table:SA1% A1 ON A1.A1_COD = E3.E3_CODCLI AND A1.A1_LOJA = E3.E3_LOJA
		WHERE
			E3.D_E_L_E_T_  = ' '
		AND A3.D_E_L_E_T_  = ' '
		AND A1.D_E_L_E_T_  = ' '
		AND E3.E3_TIPO     = 'NCC' 
		%exp:_cFiltronc%  
		AND A3.A3_SUPER   <> ' '
		%exp:_cFilCooVe%
		AND E3.E3_NUM NOT IN (	SELECT D1.D1_DOC
								FROM %table:SD1% D1,%table:SF2% F2
								WHERE
									D1.D_E_L_E_T_ = ' '
								AND F2.D_E_L_E_T_ = ' '
								AND E3.E3_FILIAL  = D1.D1_FILIAL
								AND E3.E3_NUM     = D1.D1_DOC
								AND E3.E3_SERIE   = D1.D1_SERIE
								AND E3.E3_CODCLI  = D1.D1_FORNECE
								AND E3.E3_LOJA    = D1.D1_LOJA
								AND F2.F2_FILIAL  = D1.D1_FILIAL
								AND F2.F2_DOC     = D1.D1_NFORI
								AND F2.F2_SERIE   = D1.D1_SERIORI
								AND F2.F2_CLIENTE = D1.D1_FORNECE
								AND F2.F2_LOJA    = D1.D1_LOJA 
								%exp:_cFilVeCoo% )
		ORDER BY CODVEND, ORDENADACAO, FILIAL, DTBAIXA, NUMERO, PARCELA
		
		EndSql
		
		/*
		//==============================================================================================
		//Seleciona os creditos e debitos de comissao gerados grupando por Filial, relatorio sintetico
		//==============================================================================================
		*/
   Case _nOpcao == 2 
	    	
	    	BeginSql alias _cAlias
	    	 	    	
				SELECT
				      E3.E3_FILIAL		AS FILIAL,
		              E3.E3_VEND		AS CODVEND,
		              A3.A3_NOME		AS NOMEVEND,
		              A3.A3_SUPER		AS CODSUPERV,
		              DESCSUPER.A3_NOME	AS NOMESUP,
		              E3.E3_TIPO		AS TIPO,
		              A3.A3_I_DEDUC		AS DEDUCAO,
		              E3.E3_I_ORIGE		AS ORIGEM,
		              SUM(E3.E3_COMIS)	AS COMISSAO,
		              SUM(E3.E3_BASE)	AS VLRRECEB,
		              SUM(E1.E1_VALOR)	AS VLRFATU,
		              'C'				AS ORDENADACAO
			 	FROM %table:SE3% E3
      		    JOIN %table:SE1% E1
      		          ON E1.E1_FILIAL   = E3.E3_FILIAL 
                      AND E1.E1_TIPO    = E3.E3_TIPO
                      AND E1.E1_PREFIXO = E3.E3_PREFIXO
                      AND E1.E1_NUM     = E3.E3_NUM  
                      AND E1.E1_SERIE   = E3.E3_SERIE
                      AND E1.E1_PARCELA = E3.E3_PARCELA
                      AND E1.E1_CLIENTE = E3.E3_CODCLI
                      AND E1.E1_LOJA    = E3.E3_LOJA
                    
			   JOIN %table:SF2% F2 
			   		  ON F2.F2_FILIAL   = E3.E3_FILIAL
			          AND F2.F2_DOC     = E3.E3_NUM
			          AND (F2.F2_SERIE   = E3.E3_PREFIXO OR E3.E3_PREFIXO = 'R')
			          AND F2.F2_CLIENTE = E3.E3_CODCLI
			          AND F2.F2_LOJA    = E3.E3_LOJA
			   JOIN %table:SA3% A3 
			          ON A3.A3_COD = E3.E3_VEND      
                ,
                (
                  SELECT
                        SA3.A3_NOME,SA3.A3_COD
                  FROM 
                        %table:SA3% SA3
                  WHERE    
                        SA3.D_E_L_E_T_ = ' '                                                        
                ) DESCSUPER
				WHERE
				      E3.D_E_L_E_T_     = ' '
				      AND E1.D_E_L_E_T_ = ' '    
				      AND F2.D_E_L_E_T_ = ' '   
				      AND A3.D_E_L_E_T_ = ' '
              		  AND DESCSUPER.A3_COD = A3.A3_SUPER    
              		  AND E3.E3_COMIS > 0               		  
              		  AND E1.E1_ORIGEM NOT IN ('FINA460','FINA280')	
              		  %exp:_cFiltro%
               GROUP BY 
		             E3.E3_FILIAL, 
		             E3.E3_VEND,
		             A3.A3_NOME,
		             A3.A3_SUPER,
		             DESCSUPER.A3_NOME,
		             E3.E3_TIPO,
		             A3.A3_I_DEDUC,
		             E3.E3_I_ORIGE
              UNION ALL
				SELECT
				      E3.E3_FILIAL      AS FILIAL,              
		              E3.E3_VEND        AS CODVEND,
		              A3.A3_NOME        AS NOMEVEND,		
		              A3.A3_SUPER       AS CODSUPERV,
		              DESCSUPER.A3_NOME AS NOMESUP,
		              E3.E3_TIPO        AS TIPO,             
		              A3.A3_I_DEDUC     AS DEDUCAO,
		              E3.E3_I_ORIGE     AS ORIGEM,
		              SUM(E3.E3_COMIS)  AS COMISSAO,
		              SUM(E3.E3_BASE)   AS VLRRECEB,
		              SUM(E1.E1_VALOR)  AS VLRFATU,
                      'C' ORDENADACAO
			 	FROM
                     %table:SE3% E3
      		    JOIN %table:SE1% E1 
      		          ON E1.E1_FILIAL   = E3.E3_FILIAL 
                      AND E1.E1_TIPO    = E3.E3_TIPO
                      AND E1.E1_PREFIXO = E3.E3_PREFIXO
                      AND E1.E1_NUM     = E3.E3_NUM  
                      AND E1.E1_SERIE   = E3.E3_SERIE
                      AND E1.E1_PARCELA = E3.E3_PARCELA
                      AND E1.E1_CLIENTE = E3.E3_CODCLI
                      AND E1.E1_LOJA    = E3.E3_LOJA                    
			   JOIN %table:SA3% A3 
			          ON A3.A3_COD = E3.E3_VEND      
                ,
                (
                  SELECT
                        SA3.A3_NOME,SA3.A3_COD
                  FROM 
                        %table:SA3% SA3
                  WHERE    
                        SA3.D_E_L_E_T_ = ' '                                                        
                ) DESCSUPER
				WHERE
				      E3.D_E_L_E_T_     = ' '
				      AND E1.D_E_L_E_T_ = ' '      
				      AND A3.D_E_L_E_T_ = ' '
              		  AND DESCSUPER.A3_COD = A3.A3_SUPER   
              		  AND E3.E3_COMIS > 0                     
                      AND E1.E1_NUM IN (
					                          SELECT
					                                 SE1.E1_FATURA
					                          FROM 
					                                 %table:SE1% SE1
					                                 JOIN %table:SF2% F2
					                                 ON  F2.F2_FILIAL  = SE1.E1_FILIAL
					                                 AND F2.F2_DOC     = SE1.E1_NUM
					                                 AND (F2.F2_SERIE   = SE1.E1_SERIE OR SE1.E1_SERIE = 'R')
					                                 AND F2.F2_CLIENTE = SE1.E1_CLIENTE
					                                 AND F2.F2_LOJA    = SE1.E1_LOJA
					                         WHERE       
					                                 SE1.D_E_L_E_T_ = ' '
					                                 AND F2.D_E_L_E_T_ = ' '
					                                 AND SE1.E1_FATPREF = E1.E1_PREFIXO
					                                 AND SE1.E1_FATURA  = E1.E1_NUM
					                                 AND SE1.E1_FILIAL  = E1.E1_FILIAL
					                                 AND F2.F2_FILIAL   = E1.E1_FILIAL   
					                                 AND SE1.E1_FATURA <> ' '
					                                 %exp:_cFilVeCoo%					                                 					                                 
					                          ) 	
					  %exp:_cFiltEmis%					                          		                          
					  AND E1.E1_ORIGEM = 'FINA280'	
                GROUP BY E3.E3_FILIAL, E3.E3_VEND, A3.A3_NOME, A3.A3_SUPER, DESCSUPER.A3_NOME, E3.E3_TIPO, A3.A3_I_DEDUC, E3.E3_I_ORIGE

				UNION ALL  

				SELECT
				      E3.E3_FILIAL      AS FILIAL,              
		              E3.E3_VEND        AS CODVEND,
		              A3.A3_NOME        AS NOMEVEND,		
		              A3.A3_SUPER       AS CODSUPERV,
		              DESCSUPER.A3_NOME AS NOMESUP,
		              E3.E3_TIPO        AS TIPO,             
		              A3.A3_I_DEDUC     AS DEDUCAO,
		              E3.E3_I_ORIGE     AS ORIGEM,
		              SUM(E3.E3_COMIS)  AS COMISSAO,
		              SUM(E3.E3_BASE)   AS VLRRECEB,
		              SUM(E1.E1_VALOR)  AS VLRFATU,
                      'C' ORDENADACAO
			 	FROM
                     %table:SE3% E3
      		    JOIN %table:SE1% E1 
      		          ON E1.E1_FILIAL   = E3.E3_FILIAL 
                      AND E1.E1_TIPO    = E3.E3_TIPO
                      AND E1.E1_PREFIXO = E3.E3_PREFIXO
                      AND E1.E1_NUM     = E3.E3_NUM  
                      AND E1.E1_SERIE   = E3.E3_SERIE
                      AND E1.E1_PARCELA = E3.E3_PARCELA
                      AND E1.E1_CLIENTE = E3.E3_CODCLI
                      AND E1.E1_LOJA    = E3.E3_LOJA
                      
			   JOIN %table:SA3% A3 
			          ON A3.A3_COD = E3.E3_VEND      
                ,
                (
                  SELECT
                        SA3.A3_NOME,SA3.A3_COD
                  FROM 
                        %table:SA3% SA3
                  WHERE    
                        SA3.D_E_L_E_T_ = ' '                                                        
                ) DESCSUPER
				WHERE
				      E3.D_E_L_E_T_     = ' '
				      AND E1.D_E_L_E_T_ = ' '    
				      AND A3.D_E_L_E_T_ = ' '
              		  AND DESCSUPER.A3_COD = A3.A3_SUPER   
              		  AND E3.E3_COMIS > 0   
                    	        AND E1.E1_NUMLIQ IN (
                          SELECT
                                 SE5.E5_DOCUMEN 
                          FROM 
                                 %table:SE5% SE5
                                 JOIN %table:SF2% F2
                                 ON  F2.F2_FILIAL  = SE5.E5_FILIAL
                                 AND F2.F2_DOC     = SE5.E5_NUMERO
                                 AND (F2.F2_SERIE   = SE5.E5_PREFIXO OR SE5.E5_PREFIXO = 'R')
                                 AND F2.F2_CLIENTE = SE5.E5_CLIFOR
                                 AND F2.F2_LOJA    = SE5.E5_LOJA
                         WHERE       
                                 SE5.D_E_L_E_T_ = ' '
                                 AND F2.D_E_L_E_T_  = ' '
                                 AND SE5.E5_DOCUMEN = E1.E1_NUMLIQ
                                 AND SE5.E5_FILIAL  = E1.E1_FILIAL
                                 AND F2.F2_FILIAL   = E1.E1_FILIAL  
                                 AND SE5.E5_DOCUMEN  <> ' '
                                 %exp:_cFilVeCoo%
                          )     
                           %exp:_cFiltEmis%	
       	 			       AND E1.E1_ORIGEM = 'FINA460'	
                GROUP BY E3.E3_FILIAL, E3.E3_VEND, A3.A3_NOME, A3.A3_SUPER, DESCSUPER.A3_NOME, E3.E3_TIPO, A3.A3_I_DEDUC,E3.E3_I_ORIGE   

				UNION ALL              

				SELECT
				      E3.E3_FILIAL      AS FILIAL,
				      E3.E3_VEND        AS CODVEND,
				      A3.A3_NOME        AS NOMEVEND,
				      A3.A3_SUPER       AS CODSUPERV,
				      DESCSUPER.A3_NOME AS NOMESUP,
				      E3.E3_TIPO        AS TIPO, 
				      A3.A3_I_DEDUC     AS DEDUCAO,
				      E3.E3_I_ORIGE     AS ORIGEM,
				      SUM(E3.E3_COMIS)  AS COMISSAO,
				      TO_NUMBER(NULL)   AS VLRRECEB,
		              TO_NUMBER(NULL)   AS VLRFATU,
		              'D' ORDENADACAO    
				FROM
    				  %table:SE3% E3,%table:SA3% A3,
      				(
                           SELECT 
                                 DISTINCT F2.F2_VEND1,D1.D1_FILIAL,D1.D1_DOC,D1.D1_SERIE,D1.D1_FORNECE,D1.D1_LOJA  FROM %table:SD1% D1,%table:SF2% F2
                           WHERE 
                                D1.D_E_L_E_T_ = ' '
                                AND F2.D_E_L_E_T_ = ' '                  
                                AND F2.F2_FILIAL  = D1.D1_FILIAL
                                AND F2.F2_DOC     = D1.D1_NFORI
                                AND F2.F2_SERIE   = D1.D1_SERIORI
                                AND F2.F2_CLIENTE = D1.D1_FORNECE 
                                AND F2.F2_LOJA    = D1.D1_LOJA
                                 %exp:_cFilVeCoo%                                                                                    
      			    ) COORDENAD,
			       (
			        	   SELECT
			            		SA3.A3_NOME,SA3.A3_COD
			               FROM 
			                    %table:SA3% SA3
			               WHERE    
			                    SA3.D_E_L_E_T_ = ' '                                                        
			       ) DESCSUPER
			WHERE
			      E3.D_E_L_E_T_        = ' '  
			      AND A3.D_E_L_E_T_    = ' '
			      AND E3.E3_FILIAL     = COORDENAD.D1_FILIAL
			      AND E3.E3_NUM        = COORDENAD.D1_DOC
			      AND E3.E3_SERIE      = COORDENAD.D1_SERIE
			      AND E3.E3_CODCLI     = COORDENAD.D1_FORNECE 
			      AND E3.E3_LOJA       = COORDENAD.D1_LOJA
			      AND A3.A3_COD        = E3.E3_VEND 
			      %exp:_cFiltEmis%
			      AND E3.E3_TIPO       = 'NCC'                                                                                     
		   GROUP BY E3.E3_FILIAL,
                 E3.E3_VEND,
                 A3.A3_NOME,
                 A3.A3_SUPER,
                 DESCSUPER.A3_NOME,
                 E3.E3_TIPO,
                 A3.A3_I_DEDUC,
                 E3.E3_I_ORIGE
	      UNION ALL
		  SELECT
		         E3.E3_FILIAL      AS FILIAL,
		         E3.E3_VEND        AS CODVEND,
		         A3.A3_NOME        AS NOMEVEND,
		         A3.A3_SUPER       AS CODSUPERV,
		         DESCSUPER.A3_NOME AS NOMESUP,
		         E3.E3_TIPO        AS TIPO,
		         A3.A3_I_DEDUC     AS DEDUCAO,
		         E3.E3_I_ORIGE     AS ORIGEM,
		         SUM(E3.E3_COMIS)  AS COMISSAO,
		         TO_NUMBER(NULL)   AS VLRRECEB,
		         TO_NUMBER(NULL)   AS VLRFATU,
		         'D' ORDENADACAO  
		 FROM
		        %table:SE3% E3    
		        JOIN %table:SA3% A3
		        ON E3.E3_VEND = A3.A3_COD
          ,
         (
                  SELECT
                        SA3.A3_NOME,SA3.A3_COD
                  FROM 
                        %table:SA3% SA3
                  WHERE    
                        SA3.D_E_L_E_T_ = ' '                                                        
         ) DESCSUPER
	     WHERE
      			E3.D_E_L_E_T_ = ' '    
		        AND A3.D_E_L_E_T_ = ' '  
		        AND DESCSUPER.A3_COD = A3.A3_SUPER
		        AND E3.E3_TIPO = 'NCC' 
		        AND A3.A3_COD <> A3.A3_SUPER   
		        AND A3.A3_SUPER <> ' '  
		        %exp:_cFilCooVe%
		        AND E3.E3_NUM NOT IN (
                           SELECT D1.D1_DOC FROM %table:SD1% D1,%table:SF2% F2
                           WHERE 
                                D1.D_E_L_E_T_ = ' '
                                AND F2.D_E_L_E_T_ = ' '
                                AND E3.E3_FILIAL  = D1.D1_FILIAL 
                                AND E3.E3_NUM     = D1.D1_DOC
                                AND E3.E3_SERIE   = D1.D1_SERIE
                                AND E3.E3_CODCLI  = D1.D1_FORNECE 
                                AND E3.E3_LOJA    = D1.D1_LOJA
                                AND F2.F2_FILIAL  = D1.D1_FILIAL
                                AND F2.F2_DOC     = D1.D1_NFORI
                                AND F2.F2_SERIE   = D1.D1_SERIORI
                                AND F2.F2_CLIENTE = D1.D1_FORNECE 
                                AND F2.F2_LOJA    = D1.D1_LOJA  
                                %exp:_cFilVeCoo% 
                                                                                                                
			      )   
		GROUP BY E3.E3_FILIAL, E3.E3_VEND, A3.A3_NOME, A3.A3_SUPER, DESCSUPER.A3_NOME, E3.E3_TIPO, A3.A3_I_DEDUC, E3.E3_I_ORIGE
		
		ORDER BY CODSUPERV, CODVEND, FILIAL
		
    	EndSql
            	
	Case _nOpcao == 3
	
		_cQuery := " SELECT "
		_cQuery += "    SF2.F2_FILIAL       AS F2_FILIAL   		, "
		_cQuery += "    SF2.F2_DOC          AS F2_DOC 		  	, "
		_cQuery += "    SF2.F2_SERIE        AS F2_SERIE   		, "
		_cQuery += "    SF2.F2_EMISSAO      AS F2_EMISSAO  		, "
		_cQuery += "    SF2.F2_CLIENTE      AS F2_CLIENTE   	, "
		_cQuery += "    SF2.F2_LOJA         AS F2_LOJA   		, "
		_cQuery += "    SF2.F2_VEND1        AS F2_VEND1   		, "
		_cQuery += "    SF2.F2_VEND2        AS F2_VEND2   		, "
		_cQuery += "    SF2.F2_VEND3        AS F2_VEND3   		, "
		_cQuery += "    SF2.F2_VEND4        AS F2_VEND4   		, "
		_cQuery += "    SF2.F2_VEND5        AS F2_VEND5   		, " 
		_cQuery += "    SUM((SD2.D2_VALBRUT-SD2.D2_VALDEV)) AS VALTOT           , "
		_cQuery += "    SUM(SD2.D2_COMIS1*(SD2.D2_VALBRUT-SD2.D2_VALDEV))  AS COMIS1           , "
		_cQuery += "    SUM(SD2.D2_COMIS2*(SD2.D2_VALBRUT-SD2.D2_VALDEV))  AS COMIS2           , "
		_cQuery += "    SUM(SD2.D2_COMIS3*(SD2.D2_VALBRUT-SD2.D2_VALDEV))  AS COMIS3           , "
		_cQuery += "    SUM(SD2.D2_COMIS4*(SD2.D2_VALBRUT-SD2.D2_VALDEV))  AS COMIS4           , "
		_cQuery += "    SUM(SD2.D2_COMIS5*(SD2.D2_VALBRUT-SD2.D2_VALDEV))  AS COMIS5           , "  
      _cQuery += "    0  AS VALDCT,            "  
      _cQuery += "    0  AS SE5DCT,            "  
      _cQuery += "    0  AS SE5VRB,            "  
      _cQuery += "    0  AS VALST,            "  
      _cQuery += "    0  AS COMPENSACAO,       "                    
      _cQuery += "    0  AS VLRTITULO            "                    
		_cQuery += " FROM "+ RetSqlName('SF2') +" SF2 "
		_cQuery += " JOIN "+ RetSqlName('SD2') +" SD2 ON SD2.D2_DOC		= SF2.F2_DOC	AND SD2.D2_SERIE	= SF2.F2_SERIE AND SD2.D2_FILIAL = SF2.F2_FILIAL "
		_cQuery += " JOIN "+ RetSqlName('SB1') +" SB1 ON SD2.D2_COD		= SB1.B1_COD AND SB1.B1_FILIAL = '  '"
		_cQuery += " JOIN "+ RetSqlName('SF4') +" SF4 ON SD2.D2_FILIAL	= SF4.F4_FILIAL	AND SD2.D2_TES		= SF4.F4_CODIGO "
		_cQuery += " JOIN "+ RetSqlName('ZAY') +" ZAY ON ZAY.ZAY_CF     = SD2.D2_CF "
		_cQuery += " WHERE "
		_cQuery += "     SF2.D_E_L_E_T_ = ' ' "
		_cQuery += " AND SD2.D_E_L_E_T_ = ' ' "
		_cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
		_cQuery += " AND SF4.D_E_L_E_T_ = ' ' "
		_cQuery += " AND ZAY.D_E_L_E_T_ = ' ' "
		_cQuery += " AND SB1.B1_TIPO    = 'PA' "
		_cQuery += " AND ZAY.ZAY_TPOPER	= 'B' "
		//_cQuery += " AND (SD2.D2_VALBRUT-SD2.D2_VALDEV) > 0"  
		_cQuery +=   _cfiltrobon
		_cQuery += " GROUP BY SF2.F2_FILIAL, SF2.F2_DOC, SF2.F2_SERIE,SF2.F2_EMISSAO, SF2.F2_CLIENTE,SF2.F2_LOJA,SF2.F2_VEND1, SF2.F2_VEND2, SF2.F2_VEND3, SF2.F2_VEND4, SF2.F2_VEND5 " 
		_cQuery += " ORDER BY SF2.F2_FILIAL,SF2.F2_DOC,SF2.F2_SERIE "
   
      If Select(_cAlias) > 0
         (_cAlias)->( DBCloseArea() )
      EndIf
      
      _cQuery := ChangeQuery(_cQuery)
		
		MPSysOpenQuery( _cQuery , _cAlias ) 
   Case _nOpcao == 4
        //========= Query Duplicatas Vencidas        
        _cQuery := " SELECT "
		_cQuery += "    F2.F2_FILIAL       AS F2_FILIAL   		, "
		_cQuery += "    F2.F2_DOC          AS F2_DOC 		  	, "
		_cQuery += "    F2.F2_SERIE        AS F2_SERIE   		, "
		_cQuery += "    F2.F2_EMISSAO      AS F2_EMISSAO  		, "
		_cQuery += "    F2.F2_CLIENTE      AS F2_CLIENTE   	    , "
		_cQuery += "    F2.F2_LOJA         AS F2_LOJA   		, "
		_cQuery += "    F2.F2_VEND1        AS F2_VEND1   		, "
		_cQuery += "    F2.F2_VEND2        AS F2_VEND2   		, "
		_cQuery += "    F2.F2_VEND3        AS F2_VEND3   		, "
		_cQuery += "    F2.F2_VEND4        AS F2_VEND4   		, " 
		_cQuery += "    F2.F2_VEND5        AS F2_VEND5   		, " 
		_cQuery += "    SUM(D2.D2_ICMSRET) AS ICMSRET          , " 			
        _cQuery += "    SUM(E1.E1_SALDO * (D2.D2_TOTAL / F2.F2_VALMERC))   AS VALTOT           , "
		_cQuery += "    SUM(D2.D2_COMIS1 * (E1.E1_SALDO - "
		_cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' )"		
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC) / 100 ) AS COMIS1 , "
		_cQuery += "    SUM(D2.D2_COMIS2 * (E1.E1_SALDO - "
		_cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' )"		
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC) / 100 ) AS COMIS2 , "
		_cQuery += "    SUM(D2.D2_COMIS3 * (E1.E1_SALDO - "
		_cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' )"		
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC) / 100 ) AS COMIS3 , "
		_cQuery += "    SUM(D2.D2_COMIS4 * (E1.E1_SALDO - "
		_cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' )"		
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC) / 100 ) AS COMIS4, "
        _cQuery += "    SUM(D2.D2_COMIS5 * (E1.E1_SALDO - "
		_cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' )"		
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC) / 100 ) AS COMIS5, "
        _cQuery += "    SUM((E1.E1_SALDO - "
		_cQuery += "  (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' ) "		
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC))   AS BASECOMIS  "
		_cQuery += "    FROM " + RetSqlName("SE1") + " E1 "
	    _cQuery += "    INNER JOIN " + RetSqlName("SF2") + " F2 "
	    _cQuery += "    ON "
	    _cQuery += "    F2.F2_FILIAL  = E1.E1_FILIAL "
        _cQuery += "    AND F2.F2_DOC     = E1.E1_NUM "
        _cQuery += "    AND (F2.F2_SERIE   = E1.E1_PREFIXO OR E1.E1_PREFIXO = 'R') "
        _cQuery += "    AND F2.F2_CLIENTE = E1.E1_CLIENTE "
        _cQuery += "    AND F2.F2_LOJA    = E1.E1_LOJA "
        _cQuery += "    INNER JOIN " + RetSqlName("SD2") + " D2 "
        _cQuery += "    ON "
	    _cQuery += "    F2.F2_FILIAL      = D2.D2_FILIAL "
        _cQuery += "    AND F2.F2_DOC     = D2.D2_DOC "
        _cQuery += "    AND F2.F2_SERIE   = D2.D2_SERIE "
        _cQuery += "    AND F2.F2_CLIENTE = D2.D2_CLIENTE "
        _cQuery += "    AND F2.F2_LOJA    = D2.D2_LOJA "
		_cQuery += "    WHERE "
		_cQuery += "    E1.D_E_L_E_T_ = ' ' " 
		_cQuery += "    AND F2.D_E_L_E_T_ = ' ' " 
		_cQuery += "    AND E1.E1_SALDO   > 0
		_cQuery += "    AND E1.E1_VENCREA < '" + Dtos( Date() ) + "' "
		_cQuery += "    AND E1.E1_ORIGEM  NOT IN ( 'FINA460' , 'FINA280' )
       	_cQuery += "    AND F2.F2_VEND1 = E1.E1_VEND1  "
		_cQuery += "    AND F2.F2_VEND2 = E1.E1_VEND2  "
		_cQuery += "    AND F2.F2_VEND3 = E1.E1_VEND3  "
		_cQuery += "    AND F2.F2_VEND4 = E1.E1_VEND4  " 
        _cQuery +=      _cFilSemBaixa
        _cQuery += "    GROUP BY F2.F2_FILIAL,F2.F2_DOC, F2.F2_SERIE, F2.F2_EMISSAO, F2.F2_CLIENTE, F2.F2_LOJA, F2.F2_VEND1, F2.F2_VEND2, F2.F2_VEND3, F2.F2_VEND4, F2.F2_VEND5 "
		_cQuery += "    UNION ALL "
		//==================== Query Duplicatas a Vencer
		_cQuery += " SELECT "
		_cQuery += "    F2.F2_FILIAL       AS F2_FILIAL   		, "
		_cQuery += "    F2.F2_DOC          AS F2_DOC 		  	, "
		_cQuery += "    F2.F2_SERIE        AS F2_SERIE   		, "
		_cQuery += "    F2.F2_EMISSAO      AS F2_EMISSAO  		, "
		_cQuery += "    F2.F2_CLIENTE      AS F2_CLIENTE   	, "
		_cQuery += "    F2.F2_LOJA         AS F2_LOJA   		, "
		_cQuery += "    F2.F2_VEND1        AS F2_VEND1   		, "
		_cQuery += "    F2.F2_VEND2        AS F2_VEND2   		, "
		_cQuery += "    F2.F2_VEND3        AS F2_VEND3   		, "
		_cQuery += "    F2.F2_VEND4        AS F2_VEND4   		, " 
		_cQuery += "    F2.F2_VEND5        AS F2_VEND5   		, " 
		_cQuery += "    SUM(D2.D2_ICMSRET) AS ICMSRET          , " 			
        _cQuery += "    SUM((E1.E1_SALDO + E1.E1_SDACRES - E1_SDDECRE) * (D2.D2_TOTAL / F2.F2_VALMERC)) AS VALTOT           , "
		_cQuery += "    SUM(D2.D2_COMIS1 * ( E1.E1_SALDO + E1.E1_SDACRES  - E1_SDDECRE - "
		_cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' )"
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC) / 100 ) AS COMIS1 , "
		_cQuery += "    SUM(D2.D2_COMIS2 * ( E1.E1_SALDO + E1.E1_SDACRES  - E1_SDDECRE - "
		_cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' )"
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC) / 100 ) AS COMIS2 , "
		_cQuery += "    SUM(D2.D2_COMIS3 * ( E1.E1_SALDO + E1.E1_SDACRES  - E1_SDDECRE - "
		_cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' )"
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC) / 100 ) AS COMIS3 , "
		_cQuery += "    SUM(D2.D2_COMIS4 * ( E1.E1_SALDO + E1.E1_SDACRES  - E1_SDDECRE - "
		_cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' )"
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC) / 100 ) AS COMIS4, "
        _cQuery += "    SUM(D2.D2_COMIS5 * ( E1.E1_SALDO + E1.E1_SDACRES  - E1_SDDECRE - "
		_cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' )"
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC) / 100 ) AS COMIS5, "
        _cQuery += "    SUM((E1.E1_SALDO + E1.E1_SDACRES - E1_SDDECRE - "
		_cQuery += "  (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' ) "		
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC)) AS BASECOMIS "
		_cQuery += "    FROM " + RetSqlName("SE1") + " E1 "
	   _cQuery += "    INNER JOIN " + RetSqlName("SF2") + " F2 "
	   _cQuery += "    ON "
	   _cQuery += "    F2.F2_FILIAL  = E1.E1_FILIAL "
      _cQuery += "    AND F2.F2_DOC     = E1.E1_NUM "
      _cQuery += "    AND (F2.F2_SERIE   = E1.E1_PREFIXO OR E1.E1_PREFIXO = 'R') "
      _cQuery += "    AND F2.F2_CLIENTE = E1.E1_CLIENTE "
      _cQuery += "    AND F2.F2_LOJA    = E1.E1_LOJA "
      _cQuery += "    INNER JOIN " + RetSqlName("SD2") + " D2 "
      _cQuery += "    ON "
	   _cQuery += "    F2.F2_FILIAL      = D2.D2_FILIAL "
      _cQuery += "    AND F2.F2_DOC     = D2.D2_DOC "
      _cQuery += "    AND F2.F2_SERIE  = D2.D2_SERIE "
      _cQuery += "    AND F2.F2_CLIENTE = D2.D2_CLIENTE "
      _cQuery += "    AND F2.F2_LOJA    = D2.D2_LOJA "
		_cQuery += "    WHERE "
	   _cQuery += "    E1.D_E_L_E_T_ = ' ' " 
		_cQuery += "    AND F2.D_E_L_E_T_ = ' ' " 
		_cQuery += "    AND F2.F2_VEND3   <> ' '
		_cQuery += "    AND ( ( E1.E1_SALDO + E1.E1_SDACRES ) - E1_SDDECRE ) > 0
		_cQuery += "    AND TO_DATE( E1.E1_VENCREA , 'YYYY/MM/DD' ) - TO_DATE('" + Dtos( date() ) + "' , 'YYYY/MM/DD' ) >= 0
		_cQuery += "    AND E1.E1_ORIGEM NOT IN ( 'FINA460' , 'FINA280' )
		_cQuery +=      _cFilSemBaixa   
      _cQuery += "    GROUP BY F2.F2_FILIAL,F2.F2_DOC, F2.F2_SERIE, F2.F2_EMISSAO, F2.F2_CLIENTE, F2.F2_LOJA, F2.F2_VEND1, F2.F2_VEND2, F2.F2_VEND3, F2.F2_VEND4 , F2.F2_VEND5"
		_cQuery += "    UNION ALL "
		_cQuery += " SELECT "
		_cQuery += "    F2.F2_FILIAL       AS F2_FILIAL   		, "
		_cQuery += "    F2.F2_DOC          AS F2_DOC 		  	, "
		_cQuery += "    F2.F2_SERIE        AS F2_SERIE   		, "
		_cQuery += "    F2.F2_EMISSAO      AS F2_EMISSAO  		, "
		_cQuery += "    F2.F2_CLIENTE      AS F2_CLIENTE   	    , "
		_cQuery += "    F2.F2_LOJA         AS F2_LOJA   		, "
		_cQuery += "    F2.F2_VEND1        AS F2_VEND1   		, "
		_cQuery += "    F2.F2_VEND2        AS F2_VEND2   		, "
		_cQuery += "    F2.F2_VEND3        AS F2_VEND3   		, "
		_cQuery += "    F2.F2_VEND4        AS F2_VEND4   		, " 
		_cQuery += "    F2.F2_VEND5        AS F2_VEND5   		, " 
		_cQuery += "    SUM(D2.D2_ICMSRET) AS ICMSRET           , " 				
      _cQuery += "    SUM((E1.E1_SALDO + E1.E1_SDACRES - E1_SDDECRE) * (D2.D2_TOTAL / F2.F2_VALMERC))   AS VALTOT           , "
		_cQuery += "    SUM(D2.D2_COMIS1 * ( E1.E1_SALDO + E1.E1_SDACRES  - E1_SDDECRE - "
		_cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' )"
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC) / 100 )  AS COMIS1 , "
		_cQuery += "    SUM(D2.D2_COMIS2 * ( E1.E1_SALDO + E1.E1_SDACRES  - E1_SDDECRE - "
		_cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' )"
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC) / 100 )  AS COMIS2 , "
		_cQuery += "    SUM(D2.D2_COMIS3 * ( E1.E1_SALDO + E1.E1_SDACRES  - E1_SDDECRE - "
		_cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' )"
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC) / 100 )  AS COMIS3 , "
		_cQuery += "    SUM(D2.D2_COMIS4 * ( E1.E1_SALDO + E1.E1_SDACRES  - E1_SDDECRE - "
		_cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' )"
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC) / 100 )  AS COMIS4, "
      _cQuery += "    SUM(D2.D2_COMIS5 * ( E1.E1_SALDO + E1.E1_SDACRES  - E1_SDDECRE - "
		_cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' )"
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC) / 100 )  AS COMIS5, "
      _cQuery += "    SUM((E1.E1_SALDO + E1.E1_SDACRES - E1_SDDECRE - "
      _cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' ) "				
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC)) AS BASECOMIS  "
		_cQuery += "    FROM " + RetSqlName("SE1") + " E1 "
	    _cQuery += "    INNER JOIN " + RetSqlName("SF2") + " F2 "
	    _cQuery += "    ON "
	    _cQuery += "    F2.F2_FILIAL  = E1.E1_FILIAL "
        _cQuery += "    AND F2.F2_DOC     = E1.E1_NUM "
        _cQuery += "    AND (F2.F2_SERIE   = E1.E1_PREFIXO OR E1.E1_PREFIXO = 'R') "
        _cQuery += "    AND F2.F2_CLIENTE = E1.E1_CLIENTE "
        _cQuery += "    AND F2.F2_LOJA    = E1.E1_LOJA "
        _cQuery += "    INNER JOIN " + RetSqlName("SD2") + " D2 "
        _cQuery += "    ON "
	    _cQuery += "    F2.F2_FILIAL      = D2.D2_FILIAL "
        _cQuery += "    AND F2.F2_DOC     = D2.D2_DOC "
        _cQuery += "    AND F2.F2_SERIE   = D2.D2_SERIE "
        _cQuery += "    AND F2.F2_CLIENTE = D2.D2_CLIENTE "
        _cQuery += "    AND F2.F2_LOJA    = D2.D2_LOJA "
		_cQuery += "    WHERE "
		_cQuery += "    E1.D_E_L_E_T_ = ' ' " 
		_cQuery += "    AND F2.D_E_L_E_T_ = ' ' " 
        _cQuery += "    AND E1.E1_ORIGEM  = 'FINA280' "
		_cQuery += "    AND ( ( E1.E1_SALDO + E1.E1_SDACRES ) - E1_SDDECRE ) > 0 "
		_cQuery += "    AND TO_DATE( E1.E1_VENCREA , 'YYYY/MM/DD' ) - TO_DATE('"+Dtos(date())+"', 'YYYY/MM/DD' ) >= 0 "
		_cQuery += "    AND E1.E1_NUM    IN (	SELECT SE1.E1_FATURA "
		_cQuery += "                         	FROM " + RetSqlName("SE1") + " SE1 "
		_cQuery += "                         	JOIN " + RetSqlName("SF2") + " SF2 "
		_cQuery += "                         	ON  SF2.F2_FILIAL   = SE1.E1_FILIAL "
		_cQuery += "                         	AND SF2.F2_DOC      = SE1.E1_NUM "
		_cQuery += "                         	AND (SF2.F2_SERIE   = SE1.E1_PREFIXO OR SE1.E1_PREFIXO = 'R') "
		_cQuery += "                         	AND SF2.F2_CLIENTE  = SE1.E1_CLIENTE "
		_cQuery += "                         	AND SF2.F2_LOJA     = SE1.E1_LOJA "
		_cQuery += "                         	WHERE "
		_cQuery += "                         	SE1.D_E_L_E_T_ = ' ' "
		_cQuery += "                         	AND SF2.D_E_L_E_T_  = ' ' "
		_cQuery += "                         	AND SF2.F2_VEND3   <> ' ' "
		_cQuery += "                         	AND SE1.E1_FATPREF = E1.E1_PREFIXO "
		_cQuery += "                         	AND SE1.E1_FATURA  = E1.E1_NUM "
		_cQuery += "                         	AND SE1.E1_FILIAL  = E1.E1_FILIAL "
		_cQuery += "                         	AND SF2.F2_FILIAL  = E1.E1_FILIAL "
		_cQuery += "                         	AND SE1.E1_FATURA <> ' ' ) "
		_cQuery +=      _cFilSemBaixa 
        _cQuery += "    GROUP BY F2.F2_FILIAL,F2.F2_DOC, F2.F2_SERIE, F2.F2_EMISSAO, F2.F2_CLIENTE, F2.F2_LOJA, F2.F2_VEND1, F2.F2_VEND2, F2.F2_VEND3, F2.F2_VEND4 , F2.F2_VEND5"
		_cQuery += "    UNION ALL "
		_cQuery += " SELECT "
		_cQuery += "    F2.F2_FILIAL       AS F2_FILIAL   		, "
		_cQuery += "    F2.F2_DOC          AS F2_DOC 		  	, "
		_cQuery += "    F2.F2_SERIE        AS F2_SERIE   		, "
		_cQuery += "    F2.F2_EMISSAO      AS F2_EMISSAO  		, "
		_cQuery += "    F2.F2_CLIENTE      AS F2_CLIENTE   	, "
		_cQuery += "    F2.F2_LOJA         AS F2_LOJA   		, "
		_cQuery += "    F2.F2_VEND1        AS F2_VEND1   		, "
		_cQuery += "    F2.F2_VEND2        AS F2_VEND2   		, "
		_cQuery += "    F2.F2_VEND3        AS F2_VEND3   		, "
		_cQuery += "    F2.F2_VEND4        AS F2_VEND4   		, " 
		_cQuery += "    F2.F2_VEND5        AS F2_VEND5   		, " 
        _cQuery += "    SUM(D2.D2_ICMSRET) AS ICMSRET          , " 			
		_cQuery += "    SUM((E1.E1_SALDO + E1.E1_SDACRES - E1_SDDECRE) * (D2.D2_TOTAL / F2.F2_VALMERC)) AS VALTOT           , "
		_cQuery += "    SUM(D2.D2_COMIS1 * ( E1.E1_SALDO + E1.E1_SDACRES  - E1_SDDECRE - "
        _cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' )"		
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC) / 100 ) AS COMIS1 , "
		_cQuery += "    SUM(D2.D2_COMIS2 * ( E1.E1_SALDO + E1.E1_SDACRES  - E1_SDDECRE - "
		_cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' )"
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC) / 100 ) AS COMIS2 , "
		_cQuery += "    SUM(D2.D2_COMIS3 * ( E1.E1_SALDO + E1.E1_SDACRES  - E1_SDDECRE - "
		_cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' )"
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC) / 100 ) AS COMIS3 , "
		_cQuery += "    SUM(D2.D2_COMIS4 * ( E1.E1_SALDO + E1.E1_SDACRES  - E1_SDDECRE - "
		_cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' )"
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC) / 100 ) AS COMIS4 , "
        _cQuery += "    SUM(D2.D2_COMIS5 * ( E1.E1_SALDO + E1.E1_SDACRES  - E1_SDDECRE - "
		_cQuery += " (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' )"
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC) / 100 ) AS COMIS5 , "
        _cQuery += "    SUM((E1.E1_SALDO + E1.E1_SDACRES - E1_SDDECRE - "
		_cQuery += "  (SELECT SUM(SD2.D2_ICMSRET) FROM " + RETSQLNAME("SD2") + " SD2 WHERE SD2.D2_FILIAL = E1.E1_FILIAL AND SD2.D2_DOC = E1.E1_NUM AND SD2.D2_SERIE   = E1.E1_PREFIXO AND SD2.D2_CLIENTE = E1.E1_CLIENTE AND SD2.D2_LOJA = E1.E1_LOJA AND SD2.D_E_L_E_T_ = ' ' ) "		
		_cQuery += ") * (D2.D2_TOTAL / F2.F2_VALMERC)) AS BASECOMIS "
		_cQuery += "    FROM " + RetSqlName("SE1") + " E1 "
	    _cQuery += "    INNER JOIN " + RetSqlName("SF2") + " F2 "
	    _cQuery += "    ON "
	    _cQuery += "    F2.F2_FILIAL  = E1.E1_FILIAL "
        _cQuery += "    AND F2.F2_DOC     = E1.E1_NUM "
        _cQuery += "    AND (F2.F2_SERIE   = E1.E1_PREFIXO OR E1.E1_PREFIXO = 'R') "
        _cQuery += "    AND F2.F2_CLIENTE = E1.E1_CLIENTE "
        _cQuery += "    AND F2.F2_LOJA    = E1.E1_LOJA "
        _cQuery += "    INNER JOIN " + RetSqlName("SD2") + " D2 "
        _cQuery += "    ON "
	    _cQuery += "    F2.F2_FILIAL      = D2.D2_FILIAL "
        _cQuery += "    AND F2.F2_DOC     = D2.D2_DOC "
        _cQuery += "    AND F2.F2_SERIE  = D2.D2_SERIE "
        _cQuery += "    AND F2.F2_CLIENTE = D2.D2_CLIENTE "
        _cQuery += "    AND F2.F2_LOJA    = D2.D2_LOJA "
		_cQuery += "    WHERE "
		_cQuery += "    E1.D_E_L_E_T_ = ' ' " 
		_cQuery += "    AND F2.D_E_L_E_T_ = ' ' " 
        _cQuery += "    AND E1.E1_TIPO  IN ( 'NF ' , 'ICM' ) "
		_cQuery += "    AND E1.E1_VEND1 <> ' ' "
		_cQuery += "    AND E1.E1_ORIGEM = 'FINA040' "
		_cQuery += "    AND ( ( E1.E1_SALDO + E1.E1_SDACRES ) - E1_SDDECRE ) > 0 "
		_cQuery += "    AND TO_DATE( E1.E1_VENCREA , 'YYYY/MM/DD' ) - TO_DATE('" + Dtos(date()) + "' , 'YYYY/MM/DD' ) >= 0 "
        _cQuery +=      _cFilSemBaixa 
        _cQuery += "    GROUP BY F2.F2_FILIAL,F2.F2_DOC, F2.F2_SERIE, F2.F2_EMISSAO, F2.F2_CLIENTE, F2.F2_LOJA, F2.F2_VEND1, F2.F2_VEND2, F2.F2_VEND3, F2.F2_VEND4 , F2.F2_VEND5 "
		_cQuery += "    ORDER BY F2_FILIAL,F2_DOC, F2_SERIE "
 
        If Select(_cAlias) > 0
		   (_cAlias)->( DBCloseArea() )
		EndIf
	
      _cQuery := ChangeQuery(_cQuery)
		
		MPSysOpenQuery( _cQuery , _cAlias ) 

EndCase       

Return Nil  
 
/*
===============================================================================================================================
Programa--------: ROMS025E
Autor-----------: Fabiano Dias
Data da Criacao-: 24/02/2011
Descri��o-------: Fun��o que processa a impress�o dos dados do relat�rio - Baixa Vendedor.
Parametros------: oproc - objeto da barra de processamento
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS025E(oProc As Object) 

Local _cAlias As Character
Local _cAlias3 As Character
Local _nCountRec As Numeric
Local _nTotreg As Numeric
Local _cRazaoCli As Character
Local _cCodGrupo  As Character
Local _cDescGrupo As Character
Local _cMVPAR05 As Character
Local _aVendBonif As Array
Local _cNumeroNf As Character
Local _cSerieNf As Character

Private _aFiliais As Array

_cAlias     := GetNextAlias()
_cAlias3    := GetNextAlias()
_nCountRec  := 0  
_ntotreg    := 0    
_cRazaoCli  := ""
_cCodGrupo  := ""
_cDescGrupo := ""
_cMVPAR05   := MV_PAR06 // Filtro Vendedor 
_aVendBonif := {}
_cNumeroNf  := ""
_cSerieNf   := ""

_aFiliais   := {} 

Begin Sequence
   If Empty(MV_PAR01)
	  U_itmsg("Favor preencher o par�metro: Mes/Ano antes de imprimir este relat�rio.","Aten��o",,1)
	  Break 
   EndIf
     
   //=======================================================================================================
   // Chama a rotina para selecao dos registros da comissao.												
   //=======================================================================================================
   fwMsgRun(,{|oproc|ROMS025QRY(_cAlias,1,oproc)},"Aguarde....","Filtrando os dados de credito e debito da comiss�o.")        
	
   dbSelectArea(_cAlias)
   (_cAlias)->(dbGotop())        
	            	
   //=============================================
   //Armazena o numero de registros encontrados.
   //=============================================
   COUNT TO _nCountRec 
		
   dbSelectArea(_cAlias)
   (_cAlias)->(dbGotop())       
	               	
   //=============================================
   //Verifica se existem registros selecionados.
   //=============================================
   If (_cAlias)->(!Eof())				
      _nni := 0
      
      Do While (_cAlias)->(!Eof()) 
         _nni++
         oproc:cCaption := ("Processando dados " + strzero(_nni,10) + " de " +  strzero(_nCountRec,10))
         ProcessMessages()
         _lachou := .F.

         //================================================
         // Busca dados adicionais
         //================================================
         SF2->(Dbsetorder(1))
         SA3->(Dbsetorder(1))
         If SF2->(Dbseek((_cAlias)->FILIAL+(_cAlias)->NUMERO)) .AND. ALLTRIM((_cAlias)->CODCLI) == ALLTRIM(SF2->F2_CLIENTE) 
            _cRazaoCli  := Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NOME")
			_cCodGrupo  := Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_GRPVEN")
			_cDescGrupo := Posicione("ACY",1,xFilial("ACY")+_cCodGrupo,"ACY_DESCRI")
            _ccodrep    := SF2->F2_VEND1
            _cnomerep   := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodrep)),SA3->A3_NOME," ")
            _ccodsup    := SF2->F2_VEND4
            _cnomesup   := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodsup)),SA3->A3_NOME," ")
            _ccodcoord  := SF2->F2_VEND2
            _cnomecoord := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodcoord)),SA3->A3_NOME," ")
            _ccodger    := SF2->F2_VEND3
            _cnomeger   := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodger)),SA3->A3_NOME," ")
            _cCodGNac    := SF2->F2_VEND5
            _cNomeGNac   := IIF(SA3->(Dbseek(xfilial("SA3")+_cCodGNac)),SA3->A3_NOME," ")

            _lachou     := .T.
         Else
            _cRazaoCli  := Posicione("SA1",1,xFilial("SA1")+(_cAlias)->CODCLI+(_cAlias)->LOJA,"A1_NOME")
			_cCodGrupo  := Posicione("SA1",1,xFilial("SA1")+(_cAlias)->CODCLI+(_cAlias)->LOJA,"A1_GRPVEN")
			_cDescGrupo := Posicione("ACY",1,xFilial("ACY")+_cCodGrupo,"ACY_DESCRI")
            _ccodrep    := (_cAlias)->CODVEND
            _cnomerep   := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodrep)),SA3->A3_NOME," ")
            _ccodsup    := POSICIONE("SA3",1,xfilial("SA3")+(_cAlias)->CODVEND,"A3_I_SUPE")
            _cnomesup   := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodsup)),SA3->A3_NOME," ")
            _ccodcoord  := POSICIONE("SA3",1,xfilial("SA3")+(_cAlias)->CODVEND,"A3_SUPER")
            _cnomecoord := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodcoord)),SA3->A3_NOME," ")
            _ccodger    := POSICIONE("SA3",1,xfilial("SA3")+(_cAlias)->CODVEND,"A3_GEREN")
            _cnomeger   := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodger)),SA3->A3_NOME," ")
            _cCodGNac    := POSICIONE("SA3",1,xfilial("SA3")+(_cAlias)->CODVEND,"A3_I_GERNC")
            _cNomeGNac   := IIF(SA3->(Dbseek(xfilial("SA3")+_cCodGNac)),SA3->A3_NOME," ")
         EndIf
				
         _ncomsup   := 0
		 _ncomcoord := 0
		 _ncomger   := 0
		 _ncomrep   := 0
		 _nComGNac  := 0
				
		 SE3->(Dbsetorder(1))
		 If SE3->(Dbseek((_cAlias)->FILIAL+(_cAlias)->PREFIXO+(_cAlias)->E3NUMORI+(_cAlias)->PARCELA+(_cAlias)->SEQ))
			Do while SE3->E3_FILIAL == (_cAlias)->FILIAL .AND. ;
			   SE3->E3_PREFIXO == (_cAlias)->PREFIXO .AND. ;
			   SE3->E3_NUM == (_cAlias)->E3NUMORI .AND. ;
			   SE3->E3_PARCELA == (_cAlias)->PARCELA .AND. ;
			   SE3->E3_SEQ == (_cAlias)->SEQ
               
               If SE3->E3_VEND == _ccodrep //Representante
                  _ncomrep := ROUND(_ncomrep + SE3->E3_COMIS ,3)
               EndIf
			   
			   If SE3->E3_VEND == _ccodsup  //Supervisor
                  _ncomsup := ROUND(_ncomsup + SE3->E3_COMIS ,3)
               EndIf
               
               If SE3->E3_VEND == _ccodcoord  //Coordenador
                  _ncomcoord := ROUND(_ncomcoord + SE3->E3_COMIS ,3)
               EndIf

               If SE3->E3_VEND == _ccodger  //Gerente
                  _ncomger := ROUND(_ncomger + SE3->E3_COMIS ,3)
               EndIf

	           If SE3->E3_VEND == _cCodGNac  //Gerente Nacional
                  _nComGNac := ROUND(_nComGNac + SE3->E3_COMIS ,3)
               EndIf
               SE3->(Dbskip())
            Enddo
         EndIf

         _nperrep := round(_ncomrep/(_cAlias)->BASECOMIS*100,3)
         _nperrep := iif(_nperrep<0,-1*_nperrep,_nperrep)
				
         _nbasecomis := iif((_cAlias)->COMISSAO<0,-1*(_cAlias)->BASECOMIS,(_cAlias)->BASECOMIS)
				
         _npersup := round(_ncomsup/(_cAlias)->BASECOMIS*100,3)
         _npersup := iif(_npersup<0,-1*_npersup,_npersup)
				
         _npercoo := round(_ncomcoord/(_cAlias)->BASECOMIS*100,3)
         _npercoo := iif(_npercoo<0,-1*_npercoo,_npercoo)
				
         _nperger := round(_ncomger/(_cAlias)->BASECOMIS*100,3)
         _nperger := iif(_nperger<0,-1*_nperger,_nperger)

         _nPerGNac := round(_nComGNac/(_cAlias)->BASECOMIS*100,3)
         _nPerGNac := IIf(_nPerGNac<0,-1*_nPerGNac,_nPerGNac)

         _dtemissao := iif(!empty((_cAlias)->DTEMISSAO),stod((_cAlias)->DTEMISSAO),"")
         _dtbaixa := iif(!empty((_cAlias)->DTBAIXA),stod((_cAlias)->DTBAIXA),"")
		                       
		 _cNumeroNf := (_cAlias)->NUMERO
		 _cSerieNf  := (_cAlias)->PARCELA
		 If AllTrim((_cAlias)->TIPO) == "NCC"
		 	_cNumeroNf := (_cAlias)->E3NUMORI
		    _cSerieNf  := (_cAlias)->E3SERORI
         EndIf		 	                                      
		 
         //verifica se tem duplicata
         If Empty(MV_PAR07) .Or. ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07) // Imprime todos os dados
            _npl :=  ascan(_adados,{|_vAux|	_vAux[1]  == (_cAlias)->FILIAL .and. ;
											_vAux[2]  == (_cAlias)->TIPO .and. ;
											_vAux[3]  == _dtemissao .and. ;
											_vAux[4]  == _dtbaixa .and. ;
											_vAux[5]  == _cNumeroNf .and. ;  // _vAux[5]  == (_cAlias)->NUMERO .and. ;
											_vAux[6]  == _cSerieNf .and. ; // _vAux[6]  == (_cAlias)->PARCELA .and. ;
											_vAux[7]  == _cCodGrupo .and. ;
											_vAux[8]  == _cDescGrupo .and. ;
											_vAux[9]  == (_cAlias)->CODCLI .and. ;
											_vAux[10] == (_cAlias)->LOJA .and. ;
											_vAux[11] == _cRazaoCli .AND. ;
											_vAux[37] == (_cAlias)->SEQ  })

		 ElseIf ("N" $ MV_PAR07 .And. "G" $ MV_PAR07 .And.  "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07) .Or. ; // N�o imprime vendedor
                ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07)  .Or. ; // N�o imprime supervisor
                ("G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07)  .Or. ; // N�o imprime Coordenador
                (! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07)  .Or. ; // N�o imprime gerente
                ("N" $ MV_PAR07 .And. "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07)           // N�o imprime gerente nacional
            
			_npl :=  ascan(_adados,{|_vAux|	_vAux[1]  == (_cAlias)->FILIAL .and. ;
											_vAux[2]  == (_cAlias)->TIPO .and. ;
											_vAux[3]  == _dtemissao .and. ;
											_vAux[4]  == _dtbaixa .and. ;
											_vAux[5]  == _cNumeroNf .and. ;  // _vAux[5]  == (_cAlias)->NUMERO .and. ;
											_vAux[6]  == _cSerieNf .and. ; // _vAux[6]  == (_cAlias)->PARCELA .and. ;
											_vAux[7]  == _cCodGrupo .and. ;
											_vAux[8]  == _cDescGrupo .and. ;
											_vAux[9]  == (_cAlias)->CODCLI .and. ;
											_vAux[10] == (_cAlias)->LOJA .and. ;
											_vAux[11] == _cRazaoCli .AND. ;
											_vAux[33] == (_cAlias)->SEQ })

		 Else
            _npl :=  ascan(_adados,{|_vAux|	_vAux[1]  == (_cAlias)->FILIAL .and. ;
											_vAux[2]  == (_cAlias)->TIPO .and. ;
											_vAux[3]  == _dtemissao .and. ;
											_vAux[4]  == _dtbaixa .and. ;
											_vAux[5]  == _cNumeroNf .and. ;  // _vAux[5]  == (_cAlias)->NUMERO .and. ;
											_vAux[6]  == _cSerieNf .and. ; // _vAux[6]  == (_cAlias)->PARCELA .and. ;
											_vAux[7]  == _cCodGrupo .and. ;
											_vAux[8]  == _cDescGrupo .and. ;
											_vAux[9]  == (_cAlias)->CODCLI .and. ;
											_vAux[10] == (_cAlias)->LOJA .and. ;
											_vAux[11] == _cRazaoCli .AND. ;
											_vAux[21] == (_cAlias)->SEQ  })
         EndIf

         If _npl == 0 //S� incrementa se n�o tiver no array 
		    //===============================================
			// Incrementa array para gera��o de excel
			//===============================================		  	
            If Empty(MV_PAR07) .Or. ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07) // Imprime todos os dados 
               Aadd(_adados,{(_cAlias)->FILIAL	,;	             					  //01
							 (_cAlias)->TIPO,;										  //02
			 				 _dtemissao,;											  //03
			 				 _dtbaixa,;												  //04
			 				 _cNumeroNf,;									          //05  // (_cAlias)->NUMERO,;									 //05
							 _cSerieNf,;									          //06  // (_cAlias)->PARCELA,;									 //06
							 _cCodGrupo ,;											  //07
							 _cDescGrupo,;											  //08
							 (_cAlias)->CODCLI,;									  //09
							 (_cAlias)->LOJA,;										  //10
							 _cRazaoCli,;											  //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	  //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),; //13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	  //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	  //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			  //16
							 _ccodrep,;												  //17
							 _cnomerep,;											  //18
							 _ccodsup,;												  //19
							 _cnomesup,;											  //20
							 _ccodcoord,;											  //21
							 _cnomecoord,;											  //22
							 _ccodger,;												  //23
							 _cnomeger,;											  //24
                             _cCodGNac,;                                              //25    
                             _cNomeGNac,;                                             //26
							 U_ROMS025I(_ncomrep,"@E 999,999,999.999"),;			  //27
							 U_ROMS025I(_nperrep,"@E 999,999,999.999"),;			  //28
							 U_ROMS025I(_ncomsup,"@E 999,999,999.999"),;			  //29
							 U_ROMS025I(_npersup,"@E 999,999,999.999"),;			  //30
							 U_ROMS025I(_ncomcoord,"@E 999,999,999.999"),;			  //31
							 U_ROMS025I(_npercoo,"@E 999,999,999.999"),;			  //32
							 U_ROMS025I(_ncomger,"@E 999,999,999.999"),;			  //33
							 U_ROMS025I(_nperger,"@E 999,999,999.999"),;			  //34
                             U_ROMS025I(_nComGNac,"@E 999,999,999.999"),;			  //35
							 U_ROMS025I(_nPerGNac,"@E 999,999,999.999"),;			  //36
							 (_cAlias)->SEQ,;                                         //37
                      U_ROMS025I((_cAlias)->(VALDCT),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})
							
            ElseIf "N" $ MV_PAR07 .And. "G" $ MV_PAR07 .And.  "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 //  N�o imprime vendedor
               aadd(_adados,{(_cAlias)->FILIAL	,;							         //01
							 (_cAlias)->TIPO,;										 //02
			 				 _dtemissao,;											 //03
			 				 _dtbaixa,;												 //04
			 				 _cNumeroNf,;									 //05  // (_cAlias)->NUMERO,;									 //05
							 _cSerieNf,;									 //06  // (_cAlias)->PARCELA,;									 //06
							 _cCodGrupo ,;											 //07
							 _cDescGrupo,;											 //08
							 (_cAlias)->CODCLI,;									 //09
							 (_cAlias)->LOJA,;										 //10
							 _cRazaoCli,;											 //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	 //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),; //13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	 //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			 //16
							 _ccodsup,;												 //17
							 _cnomesup,;											 //18
							 _ccodcoord,;											 //19
							 _cnomecoord,;											 //20
							 _ccodger,;												 //21
							 _cnomeger,;										     //22
                             _cCodGNac,;                                             //23    
                             _cNomeGNac,;                                            //24
							 U_ROMS025I(_ncomsup,"@E 999,999,999.999"),;				 //23 --> 25 
							 U_ROMS025I(_npersup,"@E 999,999,999.999"),;			 //24 --> 26 
							 U_ROMS025I(_ncomcoord,"@E 999,999,999.999"),;		     //25 --> 27 
							 U_ROMS025I(_npercoo,"@E 999,999,999.999"),;			 //26 --> 28
							 U_ROMS025I(_ncomger,"@E 999,999,999.999"),;				 //27 --> 29
							 U_ROMS025I(_nperger,"@E 999,999,999.999"),;			 //28 --> 30
                             U_ROMS025I(_nComGNac,"@E 999,999,999.999"),;			 //31
                             U_ROMS025I(_nPerGNac,"@E 999,999,999.999"),;			 //32 
							 (_cAlias)->SEQ,;                                         //31 --> 33
                      U_ROMS025I((_cAlias)->(VALDCT),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})

            ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07// N�o imprime supervisor
               aadd(_adados,{(_cAlias)->FILIAL	,;							         //01
							 (_cAlias)->TIPO,;										 //02
			 				 _dtemissao,;											 //03
			 				 _dtbaixa,;												 //04
			 				 _cNumeroNf,;									 //05 // (_cAlias)->NUMERO,;									 //05
							 _cSerieNf,;									 //06 // (_cAlias)->PARCELA,;									 //06
							 _cCodGrupo ,;											 //07
							 _cDescGrupo,;											 //08
							 (_cAlias)->CODCLI,;									 //09
							 (_cAlias)->LOJA,;										 //10
							 _cRazaoCli,;											 //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	 //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),; //13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	 //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			 //16
							 _ccodrep,;												 //17
							 _cnomerep,;											 //18
							 _ccodcoord,;											 //19
							 _cnomecoord,;											 //20
							 _ccodger,;												 //21
							 _cnomeger,;											 //22
                             _cCodGNac,;                                             //23    
                             _cNomeGNac,;                                            //24
							 U_ROMS025I(_ncomrep,"@E 999,999,999.999"),;				 //23 --> 25
							 U_ROMS025I(_nperrep,"@E 999,999,999.999"),;				 //24 --> 26
							 U_ROMS025I(_ncomcoord,"@E 999,999,999.999"),;			 //25 --> 27
							 U_ROMS025I(_npercoo,"@E 999,999,999.999"),;				 //26 --> 28
							 U_ROMS025I(_ncomger,"@E 999,999,999.999"),;				 //27 --> 29
							 U_ROMS025I(_nperger,"@E 999,999,999.999"),;				 //28 --> 30
                             U_ROMS025I(_nComGNac,"@E 999,999,999.999"),;			 //31 
                             U_ROMS025I(_nPerGNac,"@E 999,999,999.999"),;			 //32
							 (_cAlias)->SEQ,;                                         //33
                      U_ROMS025I((_cAlias)->(VALDCT),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})

            ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07// N�o imprime Coordenador
               aadd(_adados,{(_cAlias)->FILIAL	,;							         //01
							 (_cAlias)->TIPO,;										 //02
			 				 _dtemissao,;											 //03
			 				 _dtbaixa,;												 //04
			 				 _cNumeroNf,;									 //05 // (_cAlias)->NUMERO,;									 //05
							 _cSerieNf,;									 //06 // (_cAlias)->PARCELA,;									 //06
							 _cCodGrupo ,;											 //07
							 _cDescGrupo,;											 //08
							 (_cAlias)->CODCLI,;									 //09
							 (_cAlias)->LOJA,;										 //10
							 _cRazaoCli,;											 //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	 //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),; //13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	 //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			 //16
							 _ccodrep,;												 //17
							 _cnomerep,;											 //18
							 _ccodsup,;												 //19
							 _cnomesup,;										     //20
							 _ccodger,;												 //21
							 _cnomeger,;										     //22
                             _cCodGNac,;                                             //23    
                             _cNomeGNac,;                                            //24
							 U_ROMS025I(_ncomrep,"@E 999,999,999.999"),;				 //23 --> 25
							 U_ROMS025I(_nperrep,"@E 999,999,999.999"),;			 //24 --> 26
							 U_ROMS025I(_ncomsup,"@E 999,999,999.999"),;				 //25 --> 27
							 U_ROMS025I(_npersup,"@E 999,999,999.999"),;			 //26 --> 28
							 U_ROMS025I(_ncomger,"@E 999,999,999.999"),;				 //27 --> 29
							 U_ROMS025I(_nperger,"@E 999,999,999.999"),;			 //28 --> 30
                             U_ROMS025I(_nComGNac,"@E 999,999,999.999"),;			 //31
                             U_ROMS025I(_nPerGNac,"@E 999,999,999.999"),;			 //32
							 (_cAlias)->SEQ,;                                         //29 --> 33
                      U_ROMS025I((_cAlias)->(VALDCT),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})

            ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime gerente
               aadd(_adados,{(_cAlias)->FILIAL	,;							         //01
							 (_cAlias)->TIPO,;										 //02
			 				 _dtemissao,;											 //03
			 				 _dtbaixa,;												 //04
			 				 _cNumeroNf,;									 //05 // (_cAlias)->NUMERO,;									 //05
							 _cSerieNf,;									 //06 // (_cAlias)->PARCELA,;									 //06
							 _cCodGrupo ,;											 //07
							 _cDescGrupo,;											 //08
							 (_cAlias)->CODCLI,;									 //09
							 (_cAlias)->LOJA,;										 //10
							 _cRazaoCli,;											 //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	 //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),; //13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	 //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			 //16
							 _ccodrep,;												 //17
							 _cnomerep,;											 //18
							 _ccodsup,;												 //19
							 _cnomesup,;										 	 //20
							 _ccodcoord,;											 //21
							 _cnomecoord,;											 //22
                             _cCodGNac,;                                             //23    
                             _cNomeGNac,;                                            //24
							 U_ROMS025I(_ncomrep,"@E 999,999,999.999"),;				 //23 --> 25
							 U_ROMS025I(_nperrep,"@E 999,999,999.999"),;			 //24 --> 26
							 U_ROMS025I(_ncomsup,"@E 999,999,999.999"),;				 //25 --> 27
							 U_ROMS025I(_npersup,"@E 999,999,999.999"),;			 //26 --> 28
							 U_ROMS025I(_ncomcoord,"@E 999,999,999.999"),;		 	 //27 --> 29
							 U_ROMS025I(_npercoo,"@E 999,999,999.999"),;			 //28 --> 30
                             U_ROMS025I(_nComGNac,"@E 999,999,999.999"),;			 //31
                             U_ROMS025I(_nPerGNac,"@E 999,999,999.999"),;			 //32
							 (_cAlias)->SEQ,;                                         //33
                      U_ROMS025I((_cAlias)->(VALDCT),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})

                   ElseIf ! "N" $ MV_PAR07 .And. "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 // N�o imprime gerente nacional
                          Aadd(_adados,{(_cAlias)->FILIAL	,;	             		  //01
							 (_cAlias)->TIPO,;										  //02
			 				 _dtemissao,;											  //03
			 				 _dtbaixa,;												  //04
			 				 _cNumeroNf,;									          //05 
							 _cSerieNf,;									          //06 
							 _cCodGrupo ,;											  //07
							 _cDescGrupo,;											  //08
							 (_cAlias)->CODCLI,;									  //09
							 (_cAlias)->LOJA,;										  //10
							 _cRazaoCli,;											  //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	  //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),; //13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	  //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	  //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			  //16
							 _ccodrep,;												  //17
							 _cnomerep,;											  //18
							 _ccodsup,;												  //19
							 _cnomesup,;											  //20
							 _ccodcoord,;											  //21
							 _cnomecoord,;											  //22
							 _ccodger,;												  //23
							 _cnomeger,;											  //24
							 U_ROMS025I(_ncomrep,"@E 999,999,999.999"),;				  //25
							 U_ROMS025I(_nperrep,"@E 999,999,999.999"),;			  //26
							 U_ROMS025I(_ncomsup,"@E 999,999,999.999"),;				  //27
							 U_ROMS025I(_npersup,"@E 999,999,999.999"),;			  //28
							 U_ROMS025I(_ncomcoord,"@E 999,999,999.999"),;			  //29
							 U_ROMS025I(_npercoo,"@E 999,999,999.999"),;			  //30
							 U_ROMS025I(_ncomger,"@E 999,999,999.999"),;				  //31
							 U_ROMS025I(_nperger,"@E 999,999,999.999"),;			  //32
							 (_cAlias)->SEQ,;                                          //33
                      U_ROMS025I((_cAlias)->(VALDCT),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})
            ElseIf "N" $ MV_PAR07 .And. ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 // imprime apenas gerente nacional.
               aadd(_adados,{(_cAlias)->FILIAL	,;							          //01
							 (_cAlias)->TIPO,;										  //02
			 				 _dtemissao,;											  //03
			 				 _dtbaixa,;												  //04
			 				 _cNumeroNf,;									          //05 
							 _cSerieNf,;									          //06 
							 _cCodGrupo ,;											  //07
							 _cDescGrupo,;											  //08
							 (_cAlias)->CODCLI,;									  //09
							 (_cAlias)->LOJA,;										  //10
							 _cRazaoCli,;											  //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	  //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),; //13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	  //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	  //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			  //16
					         _cCodGNac,;                                              //17
                             _cNomeGNac,;                   						  //18
					         U_ROMS025I(_nComGNac,"@E 999,999,999.999"),;			  //19
                             U_ROMS025I(_nPerGNac,"@E 999,999,999.999"),;			  //20
							 (_cAlias)->SEQ,;                                         //21
                      U_ROMS025I((_cAlias)->(VALDCT),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})
//-----------------------------------------------------------------------------------------------							 
            ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 //  imprime apenas gerente
               aadd(_adados,{(_cAlias)->FILIAL	,;							         //01
							 (_cAlias)->TIPO,;										 //02
			 				 _dtemissao,;											 //03
			 				 _dtbaixa,;												 //04
			 				 _cNumeroNf,;									 //05 // (_cAlias)->NUMERO,;									 //05
							 _cSerieNf,;									 //06 // (_cAlias)->PARCELA,;									 //06
							 _cCodGrupo ,;											 //07
							 _cDescGrupo,;											 //08
							 (_cAlias)->CODCLI,;									 //09
							 (_cAlias)->LOJA,;										 //10
							 _cRazaoCli,;											 //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	 //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),; //13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	 //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			 //16
							 _ccodger,;												 //17
							 _cnomeger,;											 //18
							 U_ROMS025I(_ncomger,"@E 999,999,999.999"),;				 //19
							 U_ROMS025I(_nperger,"@E 999,999,999.999"),;				 //20
							 (_cAlias)->SEQ,;                                         //21
                      U_ROMS025I((_cAlias)->(VALDCT),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})
            ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas Coordenador
           	   aadd(_adados,{(_cAlias)->FILIAL	,;							         //01
							 (_cAlias)->TIPO,;										 //02
			 				 _dtemissao,;											 //03
			 				 _dtbaixa,;												 //04
			 				 _cNumeroNf,;									 //05 // (_cAlias)->NUMERO,;									 //05
							 _cSerieNf,;									 //06 // (_cAlias)->PARCELA,;									 //06
							 _cCodGrupo ,;											 //07
							 _cDescGrupo,;											 //08
							 (_cAlias)->CODCLI,;									 //09
							 (_cAlias)->LOJA,;										 //10
							 _cRazaoCli,;											 //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	 //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),; //13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	 //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			 //16
							 _ccodcoord,;											 //17
							 _cnomecoord,;											 //18
							 U_ROMS025I(_ncomcoord,"@E 999,999,999.999"),;			 //19
							 U_ROMS025I(_npercoo,"@E 999,999,999.999"),;				 //20
							 (_cAlias)->SEQ,;                                         //21
                      U_ROMS025I((_cAlias)->(VALDCT),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})
            ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07  .And. ! "N" $ MV_PAR07 // imprime apenas supervisor
               aadd(_adados,{(_cAlias)->FILIAL	,;							         //01
							 (_cAlias)->TIPO,;										 //02
			 				 _dtemissao,;											 //03
			 				 _dtbaixa,;												 //04
			 				 _cNumeroNf,;									 //05 // (_cAlias)->NUMERO,;									 //05
							 _cSerieNf,;									 //06 // (_cAlias)->PARCELA,;									 //06
							 _cCodGrupo ,;											 //07
							 _cDescGrupo,;											 //08
							 (_cAlias)->CODCLI,;									 //09
							 (_cAlias)->LOJA,;										 //10
							 _cRazaoCli,;											 //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	 //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),;//13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	 //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			 //16
							 _ccodsup,;												 //17
							 _cnomesup,;											 //18
							 U_ROMS025I(_ncomsup,"@E 999,999,999.999"),;				 //19
							 U_ROMS025I(_npersup,"@E 999,999,999.999"),;			 //20
							 (_cAlias)->SEQ,;                                         //21
                      U_ROMS025I((_cAlias)->(VALDCT),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})
            ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas vendedor
               aadd(_adados,{(_cAlias)->FILIAL	,;						             //01
							 (_cAlias)->TIPO,;										 //02
			 				 _dtemissao,;											 //03
			 				 _dtbaixa,;												 //04
			 				 _cNumeroNf,;									 //05 // (_cAlias)->NUMERO,;									 //05
							 _cSerieNf,;									 //06 // (_cAlias)->PARCELA,;									 //06
							 _cCodGrupo ,;											 //07
							 _cDescGrupo,;											 //08
							 (_cAlias)->CODCLI,;									 //09
							 (_cAlias)->LOJA,;										 //10
							 _cRazaoCli,;											 //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	 //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),;//13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	 //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			 //16
							 _ccodrep,;												 //17
							 _cnomerep,;											 //18
							 U_ROMS025I(_ncomrep,"@E 999,999,999.999"),;				 //19
							 U_ROMS025I(_nperrep,"@E 999,999,999.999"),;			 //20
							 (_cAlias)->SEQ,;                                         //21
                      U_ROMS025I((_cAlias)->(VALDCT),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})
            Else // N�o exibe dados do relat�rio em excel.
               _adados := {}		
            EndIf							  	
		 EndIf

		 //=======================================================================================================
		 // Chama a rotina para selecao dos registros da comissao.												
		 //=======================================================================================================
		 _nTotReg := 0
		 
		 If Ascan(_aVendBonif, (_cAlias)->CODVEND) == 0 //Ascan(_aVendBonif, MV_PAR06) == 0  // A Query da bonifica��o deve ser rodada apenas uma vez por vendedor
		    //Aadd(_aVendBonif, MV_PAR06)
		    Aadd(_aVendBonif, (_cAlias)->CODVEND)
		    MV_PAR06 := (_cAlias)->CODVEND   // Filtro codigo do Vendedor 
		    fwMsgRun(,{|oproc|ROMS025QRY(_cAlias3,3,oproc)},"Aguarde....","Filtrando os dados bonifica��o.")    
		 		
  		    DBSelectArea(_cAlias3)
		    (_cAlias3)->( DBGoTop() )
		    (_cAlias3)->( DBEval( {|| _nTotReg++ } ) )
		    (_cAlias3)->( DBGoTop() )
         EndIf
         
		 If _nTotReg > 0
			_nConAux := 0
			Do While (_cAlias3)->( !Eof() )
			   _nConAux++
			   oproc:cCaption := 'Processando bonifica��es... ['+ StrZero(_nConAux,9) +'] de ['+ StrZero(_nTotReg,9) +'].'
			   ProcessMessages()

 			   _cRazaoCli  := Posicione("SA1",1,xFilial("SA1")+(_cAlias3)->F2_CLIENTE+(_cAlias3)->F2_LOJA,"A1_NOME")
			   _cCodGrupo  := Posicione("SA1",1,xFilial("SA1")+(_cAlias3)->F2_CLIENTE+(_cAlias3)->F2_LOJA,"A1_GRPVEN")
			   _cDescGrupo := Posicione("ACY",1,xFilial("ACY")+_cCodGrupo,"ACY_DESCRI")
			   _cCodVen := (_cAlias3)->F2_VEND1
			   _ccodsup :=  (_cAlias3)->F2_VEND4
			   _cnomesup := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodsup)),SA3->A3_NOME," ")
			   _ccodcoord := (_cAlias3)->F2_VEND2
			   _cnomecoord := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodcoord)),SA3->A3_NOME," ")
		       _ccodger := (_cAlias3)->F2_VEND3
			   _cnomeger := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodger)),SA3->A3_NOME," ")
               _cCodGNac := (_cAlias3)->F2_VEND5 
			   _cNomeGNac := IIF(SA3->(Dbseek(xfilial("SA3")+_cCodGNac)),SA3->A3_NOME," ") 
			   
			   If ascan(_adados, {|_vAux| _vAux[1]==(_cAlias3)->F2_FILIAL .and. _vAux[2]=="BON" .and. _vAux[5]==(_cAlias3)->F2_DOC}) ==  0
				  // Incrementa array para gera��o de excel
                  If Empty(MV_PAR07) .Or. ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07) // Imprime todos os dados
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                          //01
								   "BON",;													                              //02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                  //03
								   "  ",;													                              //04
								   (_cAlias3)->F2_DOC,;									                                  //05
								   "  ",;													                              //06
								   _cCodGrupo ,;											                              //07
								   _cDescGrupo,;											                              //08
								   (_cAlias3)->F2_CLIENTE,;								                                  //09
								   (_cAlias3)->F2_LOJA,;									                              //10
								   _cRazaoCli,;											                                  //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									  //12
							       U_ROMS025I(0,"@E 999,999,999.99"),;													  //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													  //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													  //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							      //16
								   _cCodVen,;												                              //17
								   POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                              //18
								   _ccodsup,;												                              //19
								   _cnomesup,;												                              //20
								   _ccodcoord,;											                                  //21
								   _cnomecoord,;											                              //22
								   _ccodger,;												                              //23
								   _cnomeger,;												                              //24
                                   _cCodGNac,;                                                                            //25    
                                   _cNomeGNac,;                                                                           //26
								   U_ROMS025I(round((_cAlias3)->COMIS1/-100,3),"@E 999,999,999.999"),;					  //25-->27
								   U_ROMS025I(round((_cAlias3)->COMIS1/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		  //26-->28
								   U_ROMS025I(round((_cAlias3)->COMIS4/-100,3),"@E 999,999,999.999"),;					  //27-->29
								   U_ROMS025I(round((_cAlias3)->COMIS4/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		  //28-->30
								   U_ROMS025I(round((_cAlias3)->COMIS2/-100,3),"@E 999,999,999.99"),;					  //29-->31
								   U_ROMS025I(round((_cAlias3)->COMIS2/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		  //30-->32
								   U_ROMS025I(round((_cAlias3)->COMIS3/-100,3),"@E 999,999,999.999"),;					  //31-->33
								   U_ROMS025I(round((_cAlias3)->COMIS3/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		  //32-->34
								   U_ROMS025I(round((_cAlias3)->COMIS5/-100,3),"@E 999,999,999.999"),;					  //35
								   U_ROMS025I(round((_cAlias3)->COMIS5/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		  //36
								   " ",;    
                            U_ROMS025I((_cAlias3)->(VALDCT),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})
                  ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07 //  N�o imprime vendedor
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                           //01
								   "BON",;													                               //02
							       DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   //03
								   "  ",;													                               //04
								   (_cAlias3)->F2_DOC,;									                                   //05
								   "  ",;													                               //06
								   _cCodGrupo ,;											                               //07
								   _cDescGrupo,;											                               //08
								   (_cAlias3)->F2_CLIENTE,;								                                   //09
								   (_cAlias3)->F2_LOJA,;									                               //10
								   _cRazaoCli,;											                                   //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									   //12
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							       //16
								   _ccodsup,;												                               //17
								   _cnomesup,;												                               //18
								   _ccodcoord,;											                                   //19
								   _cnomecoord,;											                               //20
								   _ccodger,;												                               //21
								   _cnomeger,;	    										                               //22
								   _cCodGNac,;                                                                             //23    
                                   _cNomeGNac,;                                                                            //24 
								   U_ROMS025I(round((_cAlias3)->COMIS4/-100,3),"@E 999,999,999.999"),;					   //23-->25 
								   U_ROMS025I(round((_cAlias3)->COMIS4/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //24-->26
								   U_ROMS025I(round((_cAlias3)->COMIS2/-100,3),"@E 999,999,999.999"),;					   //25-->27
								   U_ROMS025I(round((_cAlias3)->COMIS2/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //26-->28
								   U_ROMS025I(round((_cAlias3)->COMIS3/-100,3),"@E 999,999,999.999"),;					   //27-->29
								   U_ROMS025I(round((_cAlias3)->COMIS3/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //28-->30
                                   U_ROMS025I(round((_cAlias3)->COMIS5/-100,3),"@E 999,999,999.999"),;					   //31
								   U_ROMS025I(round((_cAlias3)->COMIS5/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //32
								   " ",;    
                            U_ROMS025I((_cAlias3)->(VALDCT),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})
                  ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime supervisor
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                           //01
								   "BON",;													                               //02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   //03
								   "  ",;													                               //04
								   (_cAlias3)->F2_DOC,;									                                   //05
								   "  ",;													                               //06
								   _cCodGrupo ,;											                               //07
								   _cDescGrupo,;											                               //08
								   (_cAlias3)->F2_CLIENTE,;								                                   //09
								   (_cAlias3)->F2_LOJA,;									                               //10
								   _cRazaoCli,;											                                   //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									   //12
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							       //16
								   _cCodVen,;												                               //17
								   POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                               //18
								   _ccodcoord,;											                                   //19
								   _cnomecoord,;											                               //20
								   _ccodger,;												                               //21
								   _cnomeger,;												                               //22
								   _cCodGNac,;                                                                             //23    
                                   _cNomeGNac,;                                                                            //24 
								   U_ROMS025I(round((_cAlias3)->COMIS1/-100,3),"@E 999,999,999.999"),;					   //23-->25
								   U_ROMS025I(round((_cAlias3)->COMIS1/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //24-->26
								   U_ROMS025I(round((_cAlias3)->COMIS2/-100,3),"@E 999,999,999.999"),;					   //25-->27
								   U_ROMS025I(round((_cAlias3)->COMIS2/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //26-->28
								   U_ROMS025I(round((_cAlias3)->COMIS3/-100,3),"@E 999,999,999.999"),;					   //27-->29
								   U_ROMS025I(round((_cAlias3)->COMIS3/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //28-->30
								   U_ROMS025I(round((_cAlias3)->COMIS5/-100,3),"@E 999,999,999.999"),;					   //31
								   U_ROMS025I(round((_cAlias3)->COMIS5/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //32
								   " ",;    
                            U_ROMS025I((_cAlias3)->(VALDCT),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})
                  ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07  .And. "N" $ MV_PAR07 // N�o imprime Coordenador
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                           //01
								   "BON",;													                               //02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   //03
								   "  ",;													                               //04
								   (_cAlias3)->F2_DOC,;									                                   //05
								   "  ",;													                               //06
								   _cCodGrupo ,;											                               //07
								   _cDescGrupo,;											                               //08
								   (_cAlias3)->F2_CLIENTE,;								                                   //09
								   (_cAlias3)->F2_LOJA,;									                               //10
								   _cRazaoCli,;											                                   //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									   //12
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							       //16
								   _cCodVen,;												                               //17
								   POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                               //18
								   _ccodsup,;												                               //19
								   _cnomesup,;												                               //20
								   _ccodger,;												                               //21
								   _cnomeger,;												                               //22
								   _cCodGNac,;                                                                             //23    
                                   _cNomeGNac,;                                                                            //24 
								   U_ROMS025I(round((_cAlias3)->COMIS1/-100,3),"@E 999,999,999.999"),;					   //23-->25
								   U_ROMS025I(round((_cAlias3)->COMIS1/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //24-->26
								   U_ROMS025I(round((_cAlias3)->COMIS4/-100,3),"@E 999,999,999.999"),;					   //25-->27
								   U_ROMS025I(round((_cAlias3)->COMIS4/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //26-->28
								   U_ROMS025I(round((_cAlias3)->COMIS3/-100,3),"@E 999,999,999.993"),;					   //27-->29
								   U_ROMS025I(round((_cAlias3)->COMIS3/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //28-->30
                                   U_ROMS025I(round((_cAlias3)->COMIS5/-100,3),"@E 999,999,999.999"),;					   //31
								   U_ROMS025I(round((_cAlias3)->COMIS5/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //32
								   " ",;    
                            U_ROMS025I((_cAlias3)->(VALDCT),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})
                  //-----------------------------------------------------------------------------------
                  ElseIf !"G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime gerente 
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                           //01
								   "BON",;													                               //02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   //03
								   "  ",;													                               //04
								   (_cAlias3)->F2_DOC,;									                                   //05
								   "  ",;													                               //06
								   _cCodGrupo ,;											                               //07
								   _cDescGrupo,;											                               //08
								   (_cAlias3)->F2_CLIENTE,;								                                   //09
								   (_cAlias3)->F2_LOJA,;									                               //10
								   _cRazaoCli,;											                                   //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									   //12
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							       //16
								   _cCodVen,;												                               //17
								   POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                               //18
								   _ccodsup,;												                               //19
								   _cnomesup,;												                               //20
								   _ccodcoord,;											                                   //21
								   _cnomecoord,;											                               //22
								    _cCodGNac,;                                                                            //23    
                                   _cNomeGNac,;                                                                            //24 
								   U_ROMS025I(round((_cAlias3)->COMIS1/-100,3),"@E 999,999,999.999"),;					   //23-->25
								   U_ROMS025I(round((_cAlias3)->COMIS1/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //24-->26
								   U_ROMS025I(round((_cAlias3)->COMIS4/-100,3),"@E 999,999,999.999"),;					   //25-->27
								   U_ROMS025I(round((_cAlias3)->COMIS4/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //26-->28
								   U_ROMS025I(round((_cAlias3)->COMIS2/-100,3),"@E 999,999,999.999"),;					   //27-->29
								   U_ROMS025I(round((_cAlias3)->COMIS2/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //28-->30
								   U_ROMS025I(round((_cAlias3)->COMIS5/-100,3),"@E 999,999,999.999"),;					   //31
								   U_ROMS025I(round((_cAlias3)->COMIS5/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //32
								   " ",;    
                            U_ROMS025I((_cAlias3)->(VALDCT),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})
//------------------------------------
                  ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // N�o imprime gerente nacional
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                           //01
								   "BON",;													                               //02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   //03
								   "  ",;													                               //04
								   (_cAlias3)->F2_DOC,;									                                   //05
								   "  ",;													                               //06
								   _cCodGrupo ,;											                               //07
								   _cDescGrupo,;											                               //08
								   (_cAlias3)->F2_CLIENTE,;								                                   //09
								   (_cAlias3)->F2_LOJA,;									                               //10
								   _cRazaoCli,;											                                   //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									   //12
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							       //16
								   _cCodVen,;												                               //17
								   POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                               //18
								   _ccodsup,;												                               //19
								   _cnomesup,;												                               //20
								   _ccodcoord,;											                                   //21
								   _cnomecoord,;											                               //22
								   _ccodger,;												                               //21
								   _cnomeger,;												                               //22
								   U_ROMS025I(round((_cAlias3)->COMIS1/-100,3),"@E 999,999,999.999"),;					   //23-->25
								   U_ROMS025I(round((_cAlias3)->COMIS1/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //24-->26
								   U_ROMS025I(round((_cAlias3)->COMIS4/-100,3),"@E 999,999,999.999"),;					   //25-->27
								   U_ROMS025I(round((_cAlias3)->COMIS4/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //26-->28
								   U_ROMS025I(round((_cAlias3)->COMIS2/-100,3),"@E 999,999,999.999"),;					   //27-->29
								   U_ROMS025I(round((_cAlias3)->COMIS2/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //28-->30
								   U_ROMS025I(round((_cAlias3)->COMIS3/-100,3),"@E 999,999,999.999"),;					   //31
								   U_ROMS025I(round((_cAlias3)->COMIS3/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //32
								   " ",;    
                            U_ROMS025I((_cAlias3)->(VALDCT),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})

                  ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas gerente
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                           //01
								   "BON",;													                               //02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   //03
								   "  ",;													                               //04
								   (_cAlias3)->F2_DOC,;									                                   //05
								   "  ",;													                               //06
								   _cCodGrupo ,;											                               //07
								   _cDescGrupo,;											                               //08
								   (_cAlias3)->F2_CLIENTE,;								                                   //09
								   (_cAlias3)->F2_LOJA,;									                               //10
								   _cRazaoCli,;											                                   //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									   //12
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							       //16
								   _ccodger,;												                               //17
								   _cnomeger,;												                               //18
								   U_ROMS025I(round((_cAlias3)->COMIS3/-100,3),"@E 999,999,999.999"),;					   //19
								   U_ROMS025I(round((_cAlias3)->COMIS3/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //20
								   " ",;    
                            U_ROMS025I((_cAlias3)->(VALDCT),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})
                  ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07// imprime apenas Coordenador
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                           //01
							       "BON",;													                               //02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   //03
								   "  ",;													                               //04
								   (_cAlias3)->F2_DOC,;									                                   //05
								   "  ",;													                               //06
								   _cCodGrupo ,;											                               //07
								   _cDescGrupo,;											                               //08
								   (_cAlias3)->F2_CLIENTE,;								                                   //09
								   (_cAlias3)->F2_LOJA,;									                               //10
								   _cRazaoCli,;											                                   //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									   //12
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							       //16
								   _ccodcoord,;											                                   //17
								   _cnomecoord,;											                               //18
								   U_ROMS025I(round((_cAlias3)->COMIS2/-100,3),"@E 999,999,999.999"),;					   //19
								   U_ROMS025I(round((_cAlias3)->COMIS2/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //20
								   " ",;    
                            U_ROMS025I((_cAlias3)->(VALDCT),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})
                  ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07// imprime apenas supervisor
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                  //01
								   "BON",;													                               //02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                         //03
								   "  ",;													                               //04
								   (_cAlias3)->F2_DOC,;									                               //05
								   "  ",;													                               //06
								   _cCodGrupo ,;											                               //07
								   _cDescGrupo,;											                               //08
								   (_cAlias3)->F2_CLIENTE,;								                                   //09
								   (_cAlias3)->F2_LOJA,;									                               //10
								   _cRazaoCli,;											                                   //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									   //12
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							       //16
								   _ccodsup,;												                               //17
								   _cnomesup,;												                               //18
								   U_ROMS025I(round((_cAlias3)->COMIS4/-100,3),"@E 999,999,999.999"),;					   //19
				    			   U_ROMS025I(round((_cAlias3)->COMIS4/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //20
								   " ",;    
                            U_ROMS025I((_cAlias3)->(VALDCT),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})
                  ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas vendedor
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                           //01
								   "BON",;													                               //02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   //03
								   "  ",;													                               //04
								   (_cAlias3)->F2_DOC,;									                                   //05
								   "  ",;													                               //06
								   _cCodGrupo ,;											                               //07
								   _cDescGrupo,;											                               //08
								   (_cAlias3)->F2_CLIENTE,;								                                   //09
								   (_cAlias3)->F2_LOJA,;									                               //10
								   _cRazaoCli,;											                                   //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									   //12
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							       //16
								   _cCodVen,;												                               //17
								   POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                               //18
								   U_ROMS025I(round((_cAlias3)->COMIS1/-100,3),"@E 999,999,999.999"),;					   //19
								   U_ROMS025I(round((_cAlias3)->COMIS1/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //20
								   " ",;    
                            U_ROMS025I((_cAlias3)->(VALDCT),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})
					ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // imprime apenas Gerente Nacional
				       Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                           //01
								   "BON",;													                               //02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   //03
								   "  ",;													                               //04
								   (_cAlias3)->F2_DOC,;									                                   //05
								   "  ",;													                               //06
								   _cCodGrupo ,;											                               //07
								   _cDescGrupo,;											                               //08
								   (_cAlias3)->F2_CLIENTE,;								                                   //09
								   (_cAlias3)->F2_LOJA,;									                               //10
								   _cRazaoCli,;											                                   //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									   //12
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							       //16
								   _cCodGNac,;                                                                             //17    
                                   _cNomeGNac,;                                                                            //18
								   U_ROMS025I(round((_cAlias3)->COMIS5/-100,3),"@E 999,999,999.999"),;					   //19
								   U_ROMS025I(round((_cAlias3)->COMIS5/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //20
								   " ",;    
                            U_ROMS025I((_cAlias3)->(VALDCT),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->(VLRTITULO-COMPENSACAO),2),"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO)),2)  ,"@E 999,999,999.999"),;
							U_ROMS025I(ROUND((_cAlias)->((VLRTITULO-COMPENSACAO)-((VLRTITULO-COMPENSACAO)*(VALST/VLRTITULO))),2),"@E 999,999,999.999");
					})
                  Else // N�o exibe dados do relat�rio em excel.
                     _adados := {}		
                  EndIf
			   EndIf
			   
			   (_cAlias3)->( Dbskip() )
			Enddo
		 EndIf					
		 
		 (_cAlias)->(DbSkip())
		 
	  EndDo
   EndIf

End Sequence

MV_PAR06 := _cMVPAR05   // Filtro Vendedor 

//==========================
//Finaliza o alias criado.
//==========================
dbSelectArea(_cAlias)
(_cAlias)->(dbCloseArea())    

Return 

/*
===============================================================================================================================
Programa--------: ROMS025F
Autor-----------: Julio de Paula Paz
Data da Criacao-: 07/01/2019
Descri��o-------: Fun��o que processa a impress�o dos dados do relat�rio - Baixa Detalhado
Parametros------: oproc - objeto da barra de processamento
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS025F(oProc As Object)
Local _nCountRec As Numeric
Local _ntotreg As Numeric
Local _cRazaoCli As Character
Local _cCodGrupo As Character
Local _cDescGrupo As Character
Local _aLinhaD As Array
Local _aRegDados As Array
Local _cMVPAR05 As Character
Local _aVendBonif  As Array
Local _nI As Numeric
Local _cNumeroNf As Character
Local _cSerieNf As Character
Local _aLinhaAD As Array

Private _aFiliais As Array        
Private _cAlias As Character
Private _cAlias2 As Character
Private _cAlias3 As Character

_nCountRec  := 0  
_ntotreg    := 0    
_cRazaoCli  := ""
_cCodGrupo  := ""
_cDescGrupo := ""
_aLinhaD    := {}
_aRegDados  := {}
_cMVPAR05   := MV_PAR06 // Filtro Vendedor 
_aVendBonif := {}
_nI         := 0
_cNumeroNf  := ""
_cSerieNf   := ""
_aLinhaAD   := {}

_aFiliais   := {}            
_cAlias     := GetNextAlias()
_cAlias2    := GetNextAlias()
_cAlias3    := GetNextAlias()

Begin Sequence

   If Empty(MV_PAR01)
	  U_itmsg("Favor preencher o par�metro: Mes/Ano antes de imprimir este relat�rio.","Aten��o",,1)
	  Break 
   EndIf
     
   //=======================================================================================================
   // Chama a rotina para selecao dos registros da comissao.												
   //=======================================================================================================
   fwMsgRun(,{|oproc|ROMS025QRY(_cAlias,1,oproc)},"Aguarde....","Filtrando os dados de credito e debito da comiss�o.")        
	
   dbSelectArea(_cAlias)
   (_cAlias)->(dbGotop())        
	            	
   //=============================================
   //Armazena o numero de registros encontrados.
   //=============================================
   COUNT TO _nCountRec 
		
   dbSelectArea(_cAlias)
   (_cAlias)->(dbGotop())       
	               	
   //=============================================
   //Verifica se existem registros selecionados.
   //=============================================
   If (_cAlias)->(!Eof())				
      _nni := 0
      
      Do While (_cAlias)->(!Eof()) 
         _nni++
         oproc:cCaption := ("Processando dados " + strzero(_nni,10) + " de " +  strzero(_nCountRec,10))
         ProcessMessages()
         _lachou := .F.

         //================================================
         // Busca dados adicionais
         //================================================
         SF2->(Dbsetorder(1))
         SA3->(Dbsetorder(1))
         If SF2->(Dbseek((_cAlias)->FILIAL+(_cAlias)->NUMERO)) .AND. ALLTRIM((_cAlias)->CODCLI) == ALLTRIM(SF2->F2_CLIENTE) 
            _cRazaoCli  := Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NOME")
			_cCodGrupo  := Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_GRPVEN")
			_cDescGrupo := Posicione("ACY",1,xFilial("ACY")+_cCodGrupo,"ACY_DESCRI")
            _ccodrep    := SF2->F2_VEND1
            _cnomerep   := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodrep)),SA3->A3_NOME," ")
            _ccodsup    := SF2->F2_VEND4
            _cnomesup   := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodsup)),SA3->A3_NOME," ")
            _ccodcoord  := SF2->F2_VEND2
            _cnomecoord := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodcoord)),SA3->A3_NOME," ")
            _ccodger    := SF2->F2_VEND3
            _cnomeger   := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodger)),SA3->A3_NOME," ")  
            _cCodGNac    := SF2->F2_VEND5
            _cNomeGNac   := IIF(SA3->(Dbseek(xfilial("SA3")+_cCodGNac)),SA3->A3_NOME," ")
            _lachou     := .T.
         Else
            _cRazaoCli  := Posicione("SA1",1,xFilial("SA1")+(_cAlias)->CODCLI+(_cAlias)->LOJA,"A1_NOME")
			_cCodGrupo  := Posicione("SA1",1,xFilial("SA1")+(_cAlias)->CODCLI+(_cAlias)->LOJA,"A1_GRPVEN")
			_cDescGrupo := Posicione("ACY",1,xFilial("ACY")+_cCodGrupo,"ACY_DESCRI")
            _ccodrep    := (_cAlias)->CODVEND
            _cnomerep   := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodrep)),SA3->A3_NOME," ")
            _ccodsup    := POSICIONE("SA3",1,xfilial("SA3")+(_cAlias)->CODVEND,"A3_I_SUPE")
            _cnomesup   := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodsup)),SA3->A3_NOME," ")
            _ccodcoord  := POSICIONE("SA3",1,xfilial("SA3")+(_cAlias)->CODVEND,"A3_SUPER")
            _cnomecoord := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodcoord)),SA3->A3_NOME," ")
            _ccodger    := POSICIONE("SA3",1,xfilial("SA3")+(_cAlias)->CODVEND,"A3_GEREN")
            _cnomeger   := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodger)),SA3->A3_NOME," ")
            _cCodGNac    := POSICIONE("SA3",1,xfilial("SA3")+(_cAlias)->CODVEND,"A3_I_GERNC")
            _cNomeGNac   := IIF(SA3->(Dbseek(xfilial("SA3")+_cCodGNac)),SA3->A3_NOME," ")
         EndIf
				
         _ncomsup := 0
		 _ncomcoord := 0
		 _ncomger := 0
		 _ncomrep := 0
		 _nComGNac  := 0
				
		 SE3->(Dbsetorder(1))
		 If SE3->(Dbseek((_cAlias)->FILIAL+(_cAlias)->PREFIXO+(_cAlias)->E3NUMORI+(_cAlias)->PARCELA+(_cAlias)->SEQ))
			Do while SE3->E3_FILIAL == (_cAlias)->FILIAL .AND. ;
			   SE3->E3_PREFIXO == (_cAlias)->PREFIXO .AND. ;
			   SE3->E3_NUM == (_cAlias)->E3NUMORI .AND. ;
			   SE3->E3_PARCELA == (_cAlias)->PARCELA .AND. ;
			   SE3->E3_SEQ == (_cAlias)->SEQ
               
               If SE3->E3_VEND == _ccodrep //Representante
                  _ncomrep := ROUND(_ncomrep + SE3->E3_COMIS ,3)
               EndIf
			   
			   If SE3->E3_VEND == _ccodsup  //Supervisor
                  _ncomsup := ROUND(_ncomsup + SE3->E3_COMIS ,3)
               EndIf
               
               If SE3->E3_VEND == _ccodcoord  //Coordenador
                  _ncomcoord := ROUND(_ncomcoord + SE3->E3_COMIS ,3)
               EndIf

               If SE3->E3_VEND == _ccodger  //Gerente
                  _ncomger := ROUND(_ncomger + SE3->E3_COMIS ,3)
               EndIf

			   If SE3->E3_VEND == _cCodGNac //Gerente Nacional
                  _nComGNac := ROUND(_nComGNac + SE3->E3_COMIS ,3)
               EndIf

               SE3->(Dbskip())
            Enddo
         EndIf

         _nperrep := round(_ncomrep/(_cAlias)->BASECOMIS*100,3)
         _nperrep := iif(_nperrep<0,-1*_nperrep,_nperrep)
				
         _nbasecomis := iif((_cAlias)->COMISSAO<0,-1*(_cAlias)->BASECOMIS,(_cAlias)->BASECOMIS)
				
         _npersup := round(_ncomsup/(_cAlias)->BASECOMIS*100,3)
         _npersup := iif(_npersup<0,-1*_npersup,_npersup)
				
         _npercoo := round(_ncomcoord/(_cAlias)->BASECOMIS*100,3)
         _npercoo := iif(_npercoo<0,-1*_npercoo,_npercoo)
				
         _nperger := round(_ncomger/(_cAlias)->BASECOMIS*100,3)
         _nperger := iif(_nperger<0,-1*_nperger,_nperger)
		 
         _nPerGNac := round(_nComGNac/(_cAlias)->BASECOMIS*100,3)
         _nPerGNac := IIf(_nPerGNac<0,-1*_nPerGNac,_nPerGNac)

         _dtemissao := iif(!empty((_cAlias)->DTEMISSAO),stod((_cAlias)->DTEMISSAO),"")
         _dtbaixa := iif(!empty((_cAlias)->DTBAIXA),stod((_cAlias)->DTBAIXA),"")
			
		 _cNumeroNf := (_cAlias)->NUMERO
		 _cSerieNf  := (_cAlias)->PARCELA
		 If AllTrim((_cAlias)->TIPO) == "NCC"
		 	_cNumeroNf := (_cAlias)->E3NUMORI
		    _cSerieNf  := (_cAlias)->E3SERORI
         EndIf		 	                                      

         //verifica se tem duplicata
         If Empty(MV_PAR07) .Or. ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07) // Imprime todos os dados // 1
           _npl :=  ascan(_adados,{|_vAux|	_vAux[1]  == (_cAlias)->FILIAL .and. ;
											_vAux[2]  == (_cAlias)->TIPO .and. ;
											_vAux[3]  == _dtemissao .and. ;
											_vAux[4]  == _dtbaixa .and. ;
											_vAux[5]  == _cNumeroNf .and. ; // (_cAlias)->NUMERO .and. ;
											_vAux[6]  == _cSerieNf .and. ; // (_cAlias)->PARCELA
											_vAux[7]  == _cCodGrupo .and. ;
											_vAux[8]  == _cDescGrupo .and. ;
											_vAux[9]  == (_cAlias)->CODCLI .and. ;
											_vAux[10] == (_cAlias)->LOJA .and. ;
											_vAux[11] == _cRazaoCli .and. ;
											_vAux[47] == (_cAlias)->SEQ})

         ElseIf ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07) .Or. ; // N�o imprime vendedor   
                ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07) .Or. ; // N�o imprime supervisor 
                ("G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07) .Or. ; // N�o imprime Coordenador 
                (! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07) .Or. ; // N�o imprime gerente 
                ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07)        // N�o imprime gerente nacional 
										
            _npl :=  ascan(_adados,{|_vAux|	_vAux[1]  == (_cAlias)->FILIAL .and. ;
											_vAux[2]  == (_cAlias)->TIPO .and. ;
											_vAux[3]  == _dtemissao .and. ;
											_vAux[4]  == _dtbaixa .and. ;
											_vAux[5]  == _cNumeroNf .and. ; // (_cAlias)->NUMERO .and. ;
											_vAux[6]  == _cSerieNf .and. ; // (_cAlias)->PARCELA
											_vAux[7]  == _cCodGrupo .and. ;
											_vAux[8]  == _cDescGrupo .and. ;
											_vAux[9]  == (_cAlias)->CODCLI .and. ;
											_vAux[10] == (_cAlias)->LOJA .and. ;
											_vAux[11] == _cRazaoCli .and. ;
											_vAux[41] == (_cAlias)->SEQ})
         Else

            _npl :=  ascan(_adados,{|_vAux|	_vAux[1]  == (_cAlias)->FILIAL .and. ;
											_vAux[2]  == (_cAlias)->TIPO .and. ;
											_vAux[3]  == _dtemissao .and. ;
											_vAux[4]  == _dtbaixa .and. ;
											_vAux[5]  == _cNumeroNf .and. ; // (_cAlias)->NUMERO .and. ;
											_vAux[6]  == _cSerieNf .and. ; // (_cAlias)->PARCELA
											_vAux[7]  == _cCodGrupo .and. ;
											_vAux[8]  == _cDescGrupo .and. ;
											_vAux[9]  == (_cAlias)->CODCLI .and. ;
											_vAux[10] == (_cAlias)->LOJA .and. ;
											_vAux[11] == _cRazaoCli .and. ;
											_vAux[23] == (_cAlias)->SEQ})

         EndIf

         If _npl == 0 //S� incrementa se n�o tiver no array
		    //===============================================
			// Incrementa array para gera��o de excel
			//===============================================		  	
            If Empty(MV_PAR07) .Or. ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07) // Imprime todos os dados  // 1
               _aLinhaD:= {(_cAlias)->FILIAL	,;	             					 // 01
						   (_cAlias)->TIPO,;										 // 02
			 			   _dtemissao,;											     // 03
			 			   _dtbaixa,;												 // 04
			 			   _cNumeroNf,;									             // 05  (_cAlias)->NUMERO,;
						   _cSerieNf,;									             // 06  // (_cAlias)->PARCELA
						   _cCodGrupo ,;											 // 07
						   _cDescGrupo,;											 // 08
						   (_cAlias)->CODCLI,;									     // 09
						   (_cAlias)->LOJA,;										 // 10
						   _cRazaoCli,;											     // 11
						   (_cAlias)->VLRTITULO,;	                                 // 12
						   (_cAlias)->COMPENSACAO,;                                  // 13
						   U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 // 14
						   (_cAlias)->BAIXASANT,;	                                 // 15
						   U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),; //_nbasecomis,;	 // 16
						   _ccodrep,;												 // 17
						   _cnomerep,;											     // 18
						   _ccodsup,;												 // 19
						   _cnomesup,;											     // 20
						   _ccodcoord,;											     // 21
						   _cnomecoord,;											 // 22
						   _ccodger,;												 // 23
						   _cnomeger,;											     // 24
                           _cCodGNac,;                                               // 25 
						   _cNomeGNac,;                                              // 26
						   U_ROMS025I(_ncomrep,"@E 999,999,999.999"),;				  // 25-->27
						   U_ROMS025I(_nperrep,"@E 999,999,999.999"),;				  // 26-->28
                           U_ROMS025I(0,"@E 999,999,999.999"),;                        // 27-->29   "% Com Nota Rep",;          
						   U_ROMS025I(0,"@E 999,999,999.999"),;                        // 28-->30   "Media % Sistemica Rep",;   
						   U_ROMS025I(_ncomsup,"@E 999,999,999.999"),;				  // 29-->31   "Vlr Com Sup"	,;	
						   U_ROMS025I(_npersup,"@E 999,999,999.999"),;				  // 30-->32   "% Com Sup"	
                           U_ROMS025I(0,"@E 999,999,999.999"),;                        // 31-->33   "% Com Nota Sup"
						   U_ROMS025I(0,"@E 999,999,999.999"),;                        // 32-->34   "Media % Sistemica Sup"
						   U_ROMS025I(_ncomcoord,"@E 999,999,999.999"),;			      // 33-->35   "Vlr Com Cood"
						   U_ROMS025I(_npercoo,"@E 999,999,999.999"),;				  // 34-->36   "% Com Cood"
                           U_ROMS025I(0,"@E 999,999,999.999"),;                        // 35-->37   "% Com Nota Coord" 
						   U_ROMS025I(0,"@E 999,999,999.999"),;                        // 36-->38   "Media % Sistemica Coord"
						   U_ROMS025I(_ncomger,"@E 999,999,999.999"),;				  // 37-->39   "Vlr Com Ger"
						   U_ROMS025I(_nperger,"@E 999,999,999.999"),;				  // 38-->40   "% Com Ger"	
                           U_ROMS025I(0,"@E 999,999,999.999"),;                        // 39-->41   "% Com Nota Ger"
						   U_ROMS025I(0,"@E 999,999,999.999"),;                        // 40-->42   "Media % Sistemica Ger"
                           U_ROMS025I(_nComGNac,"@E 999,999,999.999"),;				  // 43  "Vlr Com Ger Nac"
						   U_ROMS025I(_nPerGNac,"@E 999,999,999.999"),;				  // 44  "% Com Ger Nac"	
                           U_ROMS025I(0,"@E 999,999,999.999"),;                        // 45  "% Com Nota Ger Nac"
						   U_ROMS025I(0,"@E 999,999,999.999"),;                        // 46  "Media % Sistemica Ger Nac"
						   (_cAlias)->SEQ;                                            // 41-->47  "Sequenc.Comiss�o"
						   }
                     _aLinhaAD :=  { U_ROMS025I((_cAlias)->VALDCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  		
                     }
            ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07//  N�o imprime vendedor // 2
               _aLinhaD :=  {(_cAlias)->FILIAL	,;							         // 01
							 (_cAlias)->TIPO,;										 // 02
			 				 _dtemissao,;											 // 03
			 				 _dtbaixa,;												 // 04
			 				 _cNumeroNf,;									         // 05 // (_cAlias)->NUMERO,;
							 _cSerieNf,;									         // 06 // (_cAlias)->PARCELA
							 _cCodGrupo ,;											 // 07
							 _cDescGrupo,;											 // 08
							 (_cAlias)->CODCLI,;									 // 09
							 (_cAlias)->LOJA,;										 // 10
							 _cRazaoCli,;											 // 11
							 (_cAlias)->VLRTITULO,;	                                 // 12
							 (_cAlias)->COMPENSACAO,;                                // 13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;   // 14
							 (_cAlias)->BAIXASANT,;	                                 // 15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),; //_nbasecomis,;	 // 16
							 _ccodsup,;												 // 17
							 _cnomesup,;											 // 18
							 _ccodcoord,;											 // 19
							 _cnomecoord,;											 // 20
							 _ccodger,;												 // 21
							 _cnomeger,;										     // 22
                             _cCodGNac,;                                             // 23
						     _cNomeGNac,;                                            // 24
							 U_ROMS025I(_ncomsup,"@E 999,999,999.999"),;				 // 23-->25
							 U_ROMS025I(_npersup,"@E 999,999,999.999"),;				 // 24-->26
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 25-->27  "% Com Nota Sup"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 26-->28  "Media % Sistemica Sup"							 
							 U_ROMS025I(_ncomcoord,"@E 999,999,999.999"),;		     // 27-->29  "Vlr Com Cood"	
							 U_ROMS025I(_npercoo,"@E 999,999,999.999"),;				 // 28-->30  "% Com Cood"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 29-->31  "% Com Nota Coord"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 30-->32  "Media % Sistemica Coord"							 
							 U_ROMS025I(_ncomger,"@E 999,999,999.999"),;				 // 31-->33  "Vlr Com Ger"
							 U_ROMS025I(_nperger,"@E 999,999,999.999"),;				 // 32-->34  "% Com Ger"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 33-->35  "% Com Nota Ger"  
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 34-->36  "Media % Sistemica Ger" 							 
                             U_ROMS025I(_nComGNac,"@E 999,999,999.999"),;			 // 37  "Vlr Com Ger Nac"
						     U_ROMS025I(_nPerGNac,"@E 999,999,999.999"),;			 // 38  "% Com Ger Nac"	
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 39  "% Com Nota Ger Nac"
						     U_ROMS025I(0,"@E 999,999,999.999"),;                     // 40  "Media % Sistemica Ger Nac"
							 (_cAlias)->SEQ;                                         // 35-->41  "Sequenc.Comiss�o"
							}
                     _aLinhaAD :=  { U_ROMS025I((_cAlias)->VALDCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  		
                     }
            ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime supervisor // 3
               _aLinhaD :=  {(_cAlias)->FILIAL	,;							         // 01
							 (_cAlias)->TIPO,;										 // 02
			 				 _dtemissao,;											 // 03
			 				 _dtbaixa,;												 // 04
			 				 _cNumeroNf,;									 // 05  // (_cAlias)->NUMERO,;
							 _cSerieNf,;									 // 06  // (_cAlias)->PARCELA
							 _cCodGrupo ,;											 // 07
							 _cDescGrupo,;											 // 08
							 (_cAlias)->CODCLI,;									 // 09
							 (_cAlias)->LOJA,;										 // 10
							 _cRazaoCli,;											 // 11
							 (_cAlias)->VLRTITULO,;	                                 // 12
							 (_cAlias)->COMPENSACAO,;                                // 13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 // 14
							 (_cAlias)->BAIXASANT,;	                                 // 15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),; //_nbasecomis,;	   // 16
							 _ccodrep,;												 // 17
							 _cnomerep,;											 // 18
							 _ccodcoord,;											 // 19
							 _cnomecoord,;											 // 20
							 _ccodger,;												 // 21
							 _cnomeger,;											 // 22
                             _cCodGNac,;                                             // 23
                             _cNomeGNac,;                                            // 24
							 U_ROMS025I(_ncomrep,"@E 999,999,999.999"),;				 // 23-->25
							 U_ROMS025I(_nperrep,"@E 999,999,999.999"),;				 // 24-->26
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 25-->27  "% Com Nota Rep"
							 U_ROMS025I(0,"@E 999,999,999.999"),;                     // 26-->28  "Media % Sistemica Rep"
							 U_ROMS025I(_ncomcoord,"@E 999,999,999.999"),;			 // 27-->29  "Vlr Com Cood"
							 U_ROMS025I(_npercoo,"@E 999,999,999.999"),;				 // 28-->30  "% Com Cood"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 29-->31  "% Com Nota Coord"
							 U_ROMS025I(0,"@E 999,999,999.999"),;                     // 30-->32  "Media % Sistemica Coord"
							 U_ROMS025I(_ncomger,"@E 999,999,999.999"),;				 // 31-->33  "Vlr Com Ger"
							 U_ROMS025I(_nperger,"@E 999,999,999.999"),;				 // 32-->34  "% Com Ger"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 33-->35  "% Com Nota Ger"
							 U_ROMS025I(0,"@E 999,999,999.999"),;                     // 34-->36  "Media % Sistemica Ger"
                             U_ROMS025I(_nComGNac,"@E 999,999,999.999"),;			 // 37  "Vlr Com Ger Nac"
						     U_ROMS025I(_nPerGNac,"@E 999,999,999.999"),;			 // 38  "% Com Ger Nac"	
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 39  "% Com Nota Ger Nac"
						     U_ROMS025I(0,"@E 999,999,999.999"),;                     // 40  "Media % Sistemica Ger Nac"
							 (_cAlias)->SEQ;                                         // 35-->41  "Sequenc.Comiss�o"
							 }
                     _aLinhaAD :=  { U_ROMS025I((_cAlias)->VALDCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  		
                     }
            ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime Coordenador // 4 
               _aLinhaD :=  {(_cAlias)->FILIAL	,;							         // 01
							 (_cAlias)->TIPO,;										 // 02
			 				 _dtemissao,;											 // 03
			 				 _dtbaixa,;												 // 04
			 				 _cNumeroNf,;									         // 05  // (_cAlias)->NUMERO,; 
							 _cSerieNf,;									         // 06  // (_cAlias)->PARCELA
							 _cCodGrupo ,;											 // 07
							 _cDescGrupo,;											 // 08
							 (_cAlias)->CODCLI,;									 // 09
							 (_cAlias)->LOJA,;										 // 10
							 _cRazaoCli,;											 // 11
							 (_cAlias)->VLRTITULO,;	                                 // 12
							 (_cAlias)->COMPENSACAO,;                                // 13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 // 14
							 (_cAlias)->BAIXASANT,;	                                 // 15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),; //_nbasecomis,;	   // 16
							 _ccodrep,;												 // 17
							 _cnomerep,;											 // 18
							 _ccodsup,;												 // 19
							 _cnomesup,;										     // 20
							 _ccodger,;												 // 21
							 _cnomeger,;										     // 22
                             _cCodGNac,;                                             // 23
						     _cNomeGNac,;                                            // 24
							 U_ROMS025I(_ncomrep,"@E 999,999,999.999"),;				 // 23-->25
							 U_ROMS025I(_nperrep,"@E 999,999,999.999"),;				 // 24-->26
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 25-->27  "% Com Nota Rep"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 26-->28  "Media % Sistemica Rep"							 
							 U_ROMS025I(_ncomsup,"@E 999,999,999.999"),;				 // 27-->29  "Vlr Com Sup"
							 U_ROMS025I(_npersup,"@E 999,999,999.999"),;				 // 28-->30  "% Com Sup"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 29-->31  "% Com Nota Sup"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 30-->32  "Media % Sistemica Sup							 
							 U_ROMS025I(_ncomger,"@E 999,999,999.999"),;				 // 31-->33  "Vlr Com Ger"
							 U_ROMS025I(_nperger,"@E 999,999,999.999"),;				 // 32-->34  "% Com Ger"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 33-->35  "% Com Nota Ger"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 34-->36  "Media % Sistemica Ger"
                             U_ROMS025I(_nComGNac,"@E 999,999,999.999"),;			 // 37  "Vlr Com Ger Nac"
						     U_ROMS025I(_nPerGNac,"@E 999,999,999.999"),;			 // 38  "% Com Ger Nac"	
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 39  "% Com Nota Ger Nac"
						     U_ROMS025I(0,"@E 999,999,999.999"),;                     // 40  "Media % Sistemica Ger Nac"
							 (_cAlias)->SEQ;                                         // 35-->41  "Sequenc.Comiss�o"
							} 

                     _aLinhaAD :=  { U_ROMS025I((_cAlias)->VALDCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  		
                     }
            ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07// N�o imprime gerente // 5
               _aLinhaD :=  {(_cAlias)->FILIAL	,;							         // 01
							 (_cAlias)->TIPO,;										 // 02
			 				 _dtemissao,;											 // 03
			 				 _dtbaixa,;												 // 04
			 				 _cNumeroNf,;									         // 05  // (_cAlias)->NUMERO,;
							 _cSerieNf,;									         // 06  // (_cAlias)->PARCELA
							 _cCodGrupo ,;											 // 07
							 _cDescGrupo,;											 // 08
							 (_cAlias)->CODCLI,;									 // 09
							 (_cAlias)->LOJA,;										 // 10
							 _cRazaoCli,;											 // 11
							 (_cAlias)->VLRTITULO,;	                                 // 12
							 (_cAlias)->COMPENSACAO,;                                // 13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 // 14
							 (_cAlias)->BAIXASANT,;	                                 // 15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),; //_nbasecomis,;	   // 16
							 _ccodrep,;												 // 17
							 _cnomerep,;											 // 18
							 _ccodsup,;												 // 19
							 _cnomesup,;										 	 // 20
							 _ccodcoord,;											 // 21
							 _cnomecoord,;											 // 22
                             _cCodGNac,;                                             // 23
                             _cNomeGNac,;                                            // 24 
							 U_ROMS025I(_ncomrep,"@E 999,999,999.999"),;				 // 23-->25
							 U_ROMS025I(_nperrep,"@E 999,999,999.999"),;				 // 24-->26
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 25-->27  "% Com Nota Rep"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 26-->28  "Media % Sistemica Rep"							 
							 U_ROMS025I(_ncomsup,"@E 999,999,999.999"),;				 // 27-->29  "Vlr Com Sup" 
							 U_ROMS025I(_npersup,"@E 999,999,999.999"),;				 // 28-->30  "% Com Sup"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 29-->31  "% Com Nota Sup"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 30-->32  "Media % Sistemica Sup"							 
							 U_ROMS025I(_ncomcoord,"@E 999,999,999.999"),;		 	 // 31-->33  "Vlr Com Cood"
							 U_ROMS025I(_npercoo,"@E 999,999,999.999"),;				 // 32-->34  "% Com Cood"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 33-->35  "% Com Nota Coord"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 34-->36  "Media % Sistemica Coord"
                             U_ROMS025I(_nComGNac,"@E 999,999,999.999"),;			 // 37  "Vlr Com Ger Nac"
						     U_ROMS025I(_nPerGNac,"@E 999,999,999.999"),;			 // 38  "% Com Ger Nac"	
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 39  "% Com Nota Ger Nac"
						     U_ROMS025I(0,"@E 999,999,999.999"),;                     // 40  "Media % Sistemica Ger Nac" 
							 (_cAlias)->SEQ;                                         // 35-->41  "Sequenc.Comiss�o"
							 }

                     _aLinhaAD :=  { U_ROMS025I((_cAlias)->VALDCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  		
                     }
            ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07// N�o imprime gerente nacional // 5
               _aLinhaD :=  {(_cAlias)->FILIAL	,;							         // 01
							 (_cAlias)->TIPO,;										 // 02
			 				 _dtemissao,;											 // 03
			 				 _dtbaixa,;												 // 04
			 				 _cNumeroNf,;									         // 05  // (_cAlias)->NUMERO,;
							 _cSerieNf,;									         // 06  // (_cAlias)->PARCELA
							 _cCodGrupo ,;											 // 07
							 _cDescGrupo,;											 // 08
							 (_cAlias)->CODCLI,;									 // 09
							 (_cAlias)->LOJA,;										 // 10
							 _cRazaoCli,;											 // 11
							 (_cAlias)->VLRTITULO,;	                                 // 12
							 (_cAlias)->COMPENSACAO,;                                // 13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 // 14
							 (_cAlias)->BAIXASANT,;	                                 // 15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),; //_nbasecomis,;	     // 16
							 _ccodrep,;												 // 17
							 _cnomerep,;											 // 18
							 _ccodsup,;												 // 19
							 _cnomesup,;										 	 // 20
							 _ccodcoord,;											 // 21
							 _cnomecoord,;											 // 22
                             _ccodger,;												 // 23
							 _cnomeger,;										     // 24
							 U_ROMS025I(_ncomrep,"@E 999,999,999.999"),;				 // 23-->25
							 U_ROMS025I(_nperrep,"@E 999,999,999.999"),;				 // 24-->26
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 25-->27  "% Com Nota Rep"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 26-->28  "Media % Sistemica Rep"							 
							 U_ROMS025I(_ncomsup,"@E 999,999,999.999"),;				 // 27-->29  "Vlr Com Sup" 
							 U_ROMS025I(_npersup,"@E 999,999,999.999"),;				 // 28-->30  "% Com Sup"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 29-->31  "% Com Nota Sup"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 30-->32  "Media % Sistemica Sup"							 
							 U_ROMS025I(_ncomcoord,"@E 999,999,999.999"),;		 	 // 31-->33  "Vlr Com Cood"
							 U_ROMS025I(_npercoo,"@E 999,999,999.999"),;				 // 32-->34  "% Com Cood"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 33-->35  "% Com Nota Coord"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 34-->36  "Media % Sistemica Coord"
                             U_ROMS025I(_ncomger,"@E 999,999,999.999"),;				 // 37  "Vlr Com Ger"
							 U_ROMS025I(_nperger,"@E 999,999,999.999"),;				 // 38  "% Com Ger"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 39  "% Com Nota Ger"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 40  "Media % Sistemica Ger"
							 (_cAlias)->SEQ;                                         // 35-->41  "Sequenc.Comiss�o"
							 }

                     _aLinhaAD :=  { U_ROMS025I((_cAlias)->VALDCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  		
                     }

            ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07// imprime apenas gerente nacional
               _aLinhaD :=  {(_cAlias)->FILIAL	,;							         // 01
							 (_cAlias)->TIPO,;										 // 02
			 				 _dtemissao,;											 // 03
			 				 _dtbaixa,;												 // 04
			 				 _cNumeroNf,;									         // 05  // (_cAlias)->NUMERO,;
							 _cSerieNf,;									         // 06  // (_cAlias)->PARCELA
							 _cCodGrupo ,;											 // 07
							 _cDescGrupo,;											 // 08
							 (_cAlias)->CODCLI,;									 // 09
							 (_cAlias)->LOJA,;										 // 10
							 _cRazaoCli,;											 // 11
							 (_cAlias)->VLRTITULO,;	                                 // 12
							 (_cAlias)->COMPENSACAO,;                                // 13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 // 14
							 (_cAlias)->BAIXASANT,;	                                 // 15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),; //_nbasecomis,;		// 16
							 _cCodGNac,;                                             // 17
                             _cNomeGNac,;                                            // 18 
							 U_ROMS025I(_nComGNac,"@E 999,999,999.999"),;			 // 19  "Vlr Com Ger Nac"
						     U_ROMS025I(_nPerGNac,"@E 999,999,999.999"),;			 // 20  "% Com Ger Nac"	
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 21  "% Com Nota Ger Nac"
						     U_ROMS025I(0,"@E 999,999,999.999"),;                     // 22  "Media % Sistemica Ger Nac" 							 
							 (_cAlias)->SEQ;                                         // 23  "Sequenc.Comiss�o"
							}  

                     _aLinhaAD :=  { U_ROMS025I((_cAlias)->VALDCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  		
                     }
            ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07// imprime apenas gerente // 6
               _aLinhaD :=  {(_cAlias)->FILIAL	,;							         // 01
							 (_cAlias)->TIPO,;										 // 02
			 				 _dtemissao,;											 // 03
			 				 _dtbaixa,;												 // 04
			 				 _cNumeroNf,;									         // 05  // (_cAlias)->NUMERO,;
							 _cSerieNf,;									         // 06  // (_cAlias)->PARCELA
							 _cCodGrupo ,;											 // 07
							 _cDescGrupo,;											 // 08
							 (_cAlias)->CODCLI,;									 // 09
							 (_cAlias)->LOJA,;										 // 10
							 _cRazaoCli,;											 // 11
							 (_cAlias)->VLRTITULO,;	                                 // 12
							 (_cAlias)->COMPENSACAO,;                                // 13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 // 14
							 (_cAlias)->BAIXASANT,;	                                 // 15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),; //_nbasecomis,;	  // 16
							 _ccodger,;												 // 17
							 _cnomeger,;											 // 18
							 U_ROMS025I(_ncomger,"@E 999,999,999.999"),;				 // 19
							 U_ROMS025I(_nperger,"@E 999,999,999.999"),;				 // 20
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 21 "% Com Nota Ger"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 22 "Media % Sistemica Ger" 							 
							 (_cAlias)->SEQ;                                         // 23 "Sequenc.Comiss�o"
							}
                     _aLinhaAD :=  { U_ROMS025I((_cAlias)->VALDCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  		
                     }
            ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas Coordenador // 7
           	   _aLinhaD :=  {(_cAlias)->FILIAL	,;							         // 01
							 (_cAlias)->TIPO,;										 // 02
			 				 _dtemissao,;											 // 03
			 				 _dtbaixa,;												 // 04
			 				 _cNumeroNf,;									         // 05  // (_cAlias)->NUMERO,;
							 _cSerieNf,;									         // 06  // (_cAlias)->PARCELA
							 _cCodGrupo ,;											 // 07
							 _cDescGrupo,;											 // 08
							 (_cAlias)->CODCLI,;									 // 09
							 (_cAlias)->LOJA,;										 // 10
							 _cRazaoCli,;											 // 11
							 (_cAlias)->VLRTITULO,;	                                 // 12
							 (_cAlias)->COMPENSACAO,;                                // 13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 // 14
							 (_cAlias)->BAIXASANT,;	                                 // 15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),; //_nbasecomis,;   // 16
							 _ccodcoord,;											 // 17
							 _cnomecoord,;											 // 18
							 U_ROMS025I(_ncomcoord,"@E 999,999,999.999"),;			 // 19
							 U_ROMS025I(_npercoo,"@E 999,999,999.999"),;				 // 20
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 21 "% Com Nota Coord"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 22 "Media % Sistemica Coord"							 
							 (_cAlias)->SEQ;                                         // 23 "Sequenc.Comiss�o"
							}

                     _aLinhaAD :=  { U_ROMS025I((_cAlias)->VALDCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  		
                     }
            ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07// imprime apenas supervisor // 8
               _aLinhaD :=  {(_cAlias)->FILIAL	,;							         // 01
							 (_cAlias)->TIPO,;										 // 02
			 				 _dtemissao,;											 // 03
			 				 _dtbaixa,;												 // 04
			 				 _cNumeroNf,;									         // 05  // (_cAlias)->NUMERO,;
							 _cSerieNf,;									         // 06  // (_cAlias)->PARCELA
							 _cCodGrupo ,;											 // 07
							 _cDescGrupo,;											 // 08
							 (_cAlias)->CODCLI,;									 // 09
							 (_cAlias)->LOJA,;										 // 10
							 _cRazaoCli,;											 // 11
							 (_cAlias)->VLRTITULO,;	                                 // 12
							 (_cAlias)->COMPENSACAO,;                                // 13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 // 14
							 (_cAlias)->BAIXASANT,;	                                 // 15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),; //_nbasecomis,;	   // 16
							 _ccodsup,;												 // 17
							 _cnomesup,;											 // 18
							 U_ROMS025I(_ncomsup,"@E 999,999,999.999"),;				 // 19
							 U_ROMS025I(_npersup,"@E 999,999,999.999"),;				 // 20
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 21 "% Com Nota Sup"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 22 "Media % Sistemica Sup"							 
							 (_cAlias)->SEQ;                                         // 23 "Sequenc.Comiss�o"
							}		

                     _aLinhaAD :=  { U_ROMS025I((_cAlias)->VALDCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  		
                     }				
            ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas vendedor // 9 
               _aLinhaD :=  {(_cAlias)->FILIAL	,;						             // 01
							 (_cAlias)->TIPO,;										 // 02
			 				 _dtemissao,;											 // 03
			 				 _dtbaixa,;												 // 04
			 				 _cNumeroNf,;									         // 05  // (_cAlias)->NUMERO,;
							 _cSerieNf,;									         // 06  // (_cAlias)->PARCELA
							 _cCodGrupo ,;											 // 07
							 _cDescGrupo,;											 // 08
							 (_cAlias)->CODCLI,;									 // 09
							 (_cAlias)->LOJA,;										 // 10
							 _cRazaoCli,;											 // 11
							 (_cAlias)->VLRTITULO,;	                                 // 12
							 (_cAlias)->COMPENSACAO,;                                // 13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 // 14
							 (_cAlias)->BAIXASANT,;	                                 // 15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),; //_nbasecomis,;	 // 16
							 _ccodrep,;												 // 17
							 _cnomerep,;											 // 18
							 U_ROMS025I(_ncomrep,"@E 999,999,999.999"),;				 // 19
							 U_ROMS025I(_nperrep,"@E 999,999,999.999"),;				 // 20
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 21 "% Com Nota Rep"
                             U_ROMS025I(0,"@E 999,999,999.999"),;                     // 22 "Media % Sistemica Rep"							 
							 (_cAlias)->SEQ;                                         // 23 "Sequenc.Comiss�o"
							}					

                     _aLinhaAD :=  { U_ROMS025I((_cAlias)->VALDCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  		
                     }
            Else // N�o exibe dados do relat�rio em excel.
              _aLinhaD :=  {}		
              _aDados  := {}
            EndIf							  	
		 EndIf
         
         If ! Empty(_aLinhaD)                                                    
                                        //      1               2                  3                 4                  5                 6             7         
            //_aRegDados := ROMS025G(_aLinhaD, (_cAlias)->FILIAL, (_cAlias)->NUMERO, (_cAlias)->SERIE, (_cAlias)->CODCLI, (_cAlias)->LOJA,(_cAlias)->TIPO)
            _aRegDados := ROMS025G(_aLinhaD, (_cAlias)->FILIAL, (_cAlias)->NUMERO, (_cAlias)->SERIE, (_cAlias)->CODCLI, (_cAlias)->LOJA,(_cAlias)->TIPO,_aLinhaAD)
            
            For _nI := 1 To Len(_aRegDados)
                Aadd(_aDados, AClone(_aRegDados[_nI]))
            Next

			_aLinhaD :=  {}	
         EndIf

		 //=======================================================================================================
		 // Chama a rotina para selecao dos registros da comissao.												
		 //=======================================================================================================
		 MV_PAR06 := (_cAlias)->CODVEND  // Filtro codigo do Vendedor 
		 
		 _nTotReg := 0 
		 
		 If Ascan(_aVendBonif, MV_PAR06) == 0  // A Query da bonifica��o deve ser rodada apenas uma vez por vendedor
		    Aadd(_aVendBonif, MV_PAR06)
		    
		    fwMsgRun(,{|oproc|ROMS025QRY(_cAlias3,3,oproc)},"Aguarde....","Filtrando os dados bonifica��o.")    
		 		
  		    DBSelectArea(_cAlias3)
		    (_cAlias3)->( DBGoTop() )
		    (_cAlias3)->( DBEval( {|| _nTotReg++ } ) )
		    (_cAlias3)->( DBGoTop() )
         EndIf
         
         If _nTotReg > 0
			_nConAux := 0
			Do While (_cAlias3)->( !Eof() )
			   _nConAux++
			   oproc:cCaption := 'Processando bonifica��es... ['+ StrZero(_nConAux,9) +'] de ['+ StrZero(_nTotReg,9) +'].'
			   ProcessMessages()

 			   _cRazaoCli  := Posicione("SA1",1,xFilial("SA1")+(_cAlias3)->F2_CLIENTE+(_cAlias3)->F2_LOJA,"A1_NOME")
			   _cCodGrupo  := Posicione("SA1",1,xFilial("SA1")+(_cAlias3)->F2_CLIENTE+(_cAlias3)->F2_LOJA,"A1_GRPVEN")
			   _cDescGrupo := Posicione("ACY",1,xFilial("ACY")+_cCodGrupo,"ACY_DESCRI")
			   _cCodVen := (_cAlias3)->F2_VEND1
			   _ccodsup :=  (_cAlias3)->F2_VEND4
			   _cnomesup := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodsup)),SA3->A3_NOME," ")
			   _ccodcoord := (_cAlias3)->F2_VEND2
			   _cnomecoord := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodcoord)),SA3->A3_NOME," ")
		       _ccodger := (_cAlias3)->F2_VEND3
			   _cnomeger := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodger)),SA3->A3_NOME," ")

			   _cCodGNac := (_cAlias3)->F2_VEND5
               _cNomeGNac := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodger)),SA3->A3_NOME," ")
			   
			   If ascan(_adados, {|_vAux| _vAux[1]==(_cAlias3)->F2_FILIAL .and. _vAux[2]=="BON" .and. _vAux[5]==(_cAlias3)->F2_DOC}) ==  0
				  // Incrementa array para gera��o de excel
                  If Empty(MV_PAR07) .Or. ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 ) // Imprime todos os dados  // 1
				     _aLinhaD :=  {(_cAlias3)->F2_FILIAL	,;					                                          // 01
								   "BON",;													                              // 02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                  // 03
								   "  ",;													                              // 04
								   (_cAlias3)->F2_DOC,;									                                  // 05
								   "  ",;													                              // 06
								   _cCodGrupo ,;											                              // 07
								   _cDescGrupo,;											                              // 08
								   (_cAlias3)->F2_CLIENTE,;								                                  // 09
								   (_cAlias3)->F2_LOJA,;									                              // 10
								   _cRazaoCli,;											                                  // 11
								   (_cAlias3)->VALTOT,;									                                  // 12
							       0,;													                                  // 13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													  // 14
								   0,;													                                  // 15
								   (_cAlias3)->VALTOT*-1,;							                                      // 16
								   _cCodVen,;												                              // 17
								   POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                              // 18
								   _ccodsup,;												                              // 19
								   _cnomesup,;												                              // 20
								   _ccodcoord,;											                                  // 21
								   _cnomecoord,;											                              // 22
								   _ccodger,;												                              // 23
								   _cnomeger,;												                              // 24
                                   _cCodGNac,;                                                                            // 25
                                   _cNomeGNac,;                                                                           // 26 
								   U_ROMS025I(round((_cAlias3)->COMIS1/-100,3),"@E 999,999,999.999"),;					  // 25-->27 
								   U_ROMS025I(round((_cAlias3)->COMIS1/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		  // 26-->28 
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                    // 27-->29  "% Com Nota Rep"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                    // 28-->30  "Media % Sistemica Rep"
								   U_ROMS025I(round((_cAlias3)->COMIS4/-100,3),"@E 999,999,999.999"),;					  // 29-->31  "Vlr Com Sup"
								   U_ROMS025I(round((_cAlias3)->COMIS4/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		  // 30-->32  "% Com Sup"	
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                    // 31-->33  "% Com Nota Sup"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                    // 32-->34  "Media % Sistemica Sup"
								   U_ROMS025I(round((_cAlias3)->COMIS2/-100,3),"@E 999,999,999.999"),;					  // 33-->35  "Vlr Com Cood"
								   U_ROMS025I(round((_cAlias3)->COMIS2/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		  // 34-->36  "% Com Cood"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                    // 35-->37  "% Com Nota Coord"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                    // 36-->38  "Media % Sistemica Coord"
								   U_ROMS025I(round((_cAlias3)->COMIS3/-100,3),"@E 999,999,999.999"),;					  // 37-->39  "Vlr Com Ger"
								   U_ROMS025I(round((_cAlias3)->COMIS3/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		  // 38-->40  "% Com Ger"	
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                    // 39-->41  "% Com Nota Ger"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                    // 40-->42  "Media % Sistemica Ger"
                                   U_ROMS025I(round((_cAlias3)->COMIS5/-100,3),"@E 999,999,999.999"),;					  // 43 "Vlr Com Ger Nac"
								   U_ROMS025I(round((_cAlias3)->COMIS5/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		  // 44 "% Com Ger Nac"	
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                    // 45 "% Com Nota Ger Nac"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                    // 46 "Media % Sistemica Ger Nac"
								   " ";                                                                                   // 41-->47  "Sequenc.Comiss�o"
								   }                           
							_aLinhaAD :=  { U_ROMS025I((_cAlias3)->VALDCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  		
                           }
                  ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07 //  N�o imprime vendedor  // 2
				     _aLinhaD :=  {(_cAlias3)->F2_FILIAL	,;					                                           // 01
								   "BON",;													                               // 02
							       DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   // 03
								   "  ",;													                               // 04
								   (_cAlias3)->F2_DOC,;									                                   // 05
								   "  ",;													                               // 06
								   _cCodGrupo ,;											                               // 07
								   _cDescGrupo,;											                               // 08
								   (_cAlias3)->F2_CLIENTE,;								                                   // 09
								   (_cAlias3)->F2_LOJA,;									                               // 10
								   _cRazaoCli,;											                                   // 11
								   (_cAlias3)->VALTOT,;									                                   // 12
								   0,;													                                   // 13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   // 14
								   0,;													                                   // 15
								   (_cAlias3)->VALTOT*-1,;							                                       // 16
								   _ccodsup,;												                               // 17
								   _cnomesup,;												                               // 18
								   _ccodcoord,;											                                   // 19
								   _cnomecoord,;											                               // 20
								   _ccodger,;												                               // 21
								   _cnomeger,;												                               // 22
                                   _cCodGNac,;                                                                             // 23
                                   _cNomeGNac,;                                                                            // 24 
								   U_ROMS025I(round((_cAlias3)->COMIS4/-100,3),"@E 999,999,999.999"),;					   // 23-->25 
								   U_ROMS025I(round((_cAlias3)->COMIS4/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 24-->26 
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 25-->27   "% Com Nota Sup"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 26-->28   "Media % Sistemica Sup"
								   U_ROMS025I(round((_cAlias3)->COMIS2/-100,3),"@E 999,999,999.999"),;					   // 27-->29   "Vlr Com Cood"
								   U_ROMS025I(round((_cAlias3)->COMIS2/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 28-->30   "% Com Cood"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 29-->31   "% Com Nota Coord"   
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 30-->32   "Media % Sistemica Coord" 
								   U_ROMS025I(round((_cAlias3)->COMIS3/-100,3),"@E 999,999,999.999"),;					   // 31-->33   "Vlr Com Ger"
								   U_ROMS025I(round((_cAlias3)->COMIS3/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 32-->34   "% Com Ger"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 33-->35   "% Com Nota Ger"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 34-->36   "Media % Sistemica Ger"
                                   U_ROMS025I(round((_cAlias3)->COMIS5/-100,3),"@E 999,999,999.999"),;					   // 37  "Vlr Com Ger Nac"
								   U_ROMS025I(round((_cAlias3)->COMIS5/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 38  "% Com Ger Nac"	
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 39  "% Com Nota Ger Nac"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 40  "Media % Sistemica Ger Nac"
								   " ";                                                                                    // 35-->41  "Sequenc.Comiss�o"
							       }
                           _aLinhaAD :=  { U_ROMS025I((_cAlias3)->VALDCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  		
                           }
                  ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime supervisor // 3
				     _aLinhaD :=  {(_cAlias3)->F2_FILIAL	,;					                                           // 01
								   "BON",;													                               // 02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   // 03
								   "  ",;													                               // 04
								   (_cAlias3)->F2_DOC,;									                                   // 05
								   "  ",;													                               // 06
								   _cCodGrupo ,;											                               // 07
								   _cDescGrupo,;											                               // 08
								   (_cAlias3)->F2_CLIENTE,;								                                   // 09
								   (_cAlias3)->F2_LOJA,;									                               // 10
								   _cRazaoCli,;											                                   // 11
								   (_cAlias3)->VALTOT,;									                                   // 12
								   0,;													                                   // 13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   // 14
								   0,;													                                   // 15
								   (_cAlias3)->VALTOT*-1,;							                                       // 16
								   _cCodVen,;												                               // 17
								   POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                               // 18
								   _ccodcoord,;											                                   // 19
								   _cnomecoord,;											                               // 20
								   _ccodger,;												                               // 21
								   _cnomeger,;												                               // 22
                                   _cCodGNac,;                                                                             // 23
                                   _cNomeGNac,;                                                                            // 24 
								   U_ROMS025I(round((_cAlias3)->COMIS1/-100,3),"@E 999,999,999.999"),;					   // 23-->25
								   U_ROMS025I(round((_cAlias3)->COMIS1/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 24-->26 
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 25-->27   "% Com Nota Rep"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 26-->28   "Media % Sistemica Rep"
								   U_ROMS025I(round((_cAlias3)->COMIS2/-100,3),"@E 999,999,999.999"),;					   // 27-->29   "Vlr Com Cood"
								   U_ROMS025I(round((_cAlias3)->COMIS2/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 28-->30   "% Com Cood"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 29-->31   "% Com Nota Coord"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 30-->32   "Media % Sistemica Coord"
								   U_ROMS025I(round((_cAlias3)->COMIS3/-100,3),"@E 999,999,999.999"),;					   // 31-->33   "Vlr Com Ger"
								   U_ROMS025I(round((_cAlias3)->COMIS3/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 32-->34   "% Com Ger"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 33-->35   "% Com Nota Ger"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 34-->36   "Media % Sistemica Ger"
                                   U_ROMS025I(round((_cAlias3)->COMIS5/-100,3),"@E 999,999,999.999"),;					   // 37 "Vlr Com Ger Nac"
								   U_ROMS025I(round((_cAlias3)->COMIS5/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 38 "% Com Ger Nac"	
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 39 "% Com Nota Ger Nac"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 40 "Media % Sistemica Ger Nac"
								   " ";                                                                                    // 35-->41  "Sequenc.Comiss�o"
							 	   }
                           _aLinhaAD :=  { U_ROMS025I((_cAlias3)->VALDCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  		
                           }
                  ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07// N�o imprime Coordenador  // 4 
				     _aLinhaD :=  {(_cAlias3)->F2_FILIAL	,;					                                           // 01
								   "BON",;													                               // 02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   // 03
								   "  ",;													                               // 04
								   (_cAlias3)->F2_DOC,;									                                   // 05
								   "  ",;													                               // 06
								   _cCodGrupo ,;											                               // 07
								   _cDescGrupo,;											                               // 08
								   (_cAlias3)->F2_CLIENTE,;								                                   // 09
								   (_cAlias3)->F2_LOJA,;									                               // 10
								   _cRazaoCli,;											                                   // 11
								   (_cAlias3)->VALTOT,;									                                   // 12
								   0,;													                                   // 13
								   U_ROMS025I(0,"@E 999,999,999.99"),;												       // 14
								   0,;													                                   // 15
								   (_cAlias3)->VALTOT*-1,;							                                       // 16
								   _cCodVen,;												                               // 17
								   POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                               // 18
								   _ccodsup,;												                               // 19
								   _cnomesup,;												                               // 20
								   _ccodger,;												                               // 21
								   _cnomeger,;												                               // 22
                                   _cCodGNac,;                                                                             // 23
                                   _cNomeGNac,;                                                                            // 24 
								   U_ROMS025I(round((_cAlias3)->COMIS1/-100,3),"@E 999,999,999.999"),;					   // 23-->25
								   U_ROMS025I(round((_cAlias3)->COMIS1/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 24-->26
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 25-->27  "% Com Nota Rep"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 26-->28  "Media % Sistemica Rep"
								   U_ROMS025I(round((_cAlias3)->COMIS4/-100,3),"@E 999,999,999.999"),;					   // 27-->29  "Vlr Com Sup"
								   U_ROMS025I(round((_cAlias3)->COMIS4/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 28-->30  "% Com Sup"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 29-->31  "% Com Nota Sup"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 30-->32  "Media % Sistemica Sup"
								   U_ROMS025I(round((_cAlias3)->COMIS3/-100,3),"@E 999,999,999.999"),;					   // 31-->33  "Vlr Com Ger"
								   U_ROMS025I(round((_cAlias3)->COMIS3/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 32-->34  "% Com Ger"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 33-->35  "% Com Nota Ger"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 34-->36  "Media % Sistemica Ger"
                                   U_ROMS025I(round((_cAlias3)->COMIS5/-100,3),"@E 999,999,999.999"),;					   // 37 "Vlr Com Ger Nac"
								   U_ROMS025I(round((_cAlias3)->COMIS5/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 38 "% Com Ger Nac"	
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 39 "% Com Nota Ger Nac"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 40 "Media % Sistemica Ger Nac"
								   " ";                                                                                    // 35-->41  "Sequenc.Comiss�o"
								   }
                           _aLinhaAD :=  { U_ROMS025I((_cAlias3)->VALDCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  		
                           }
                  ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07// N�o imprime gerente  // 5
				     _aLinhaD :=  {(_cAlias3)->F2_FILIAL	,;					                                           // 01
								   "BON",;													                               // 02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   // 03
								   "  ",;													                               // 04
								   (_cAlias3)->F2_DOC,;									                                   // 05
								   "  ",;													                               // 06
								   _cCodGrupo ,;											                               // 07
								   _cDescGrupo,;											                               // 08
								   (_cAlias3)->F2_CLIENTE,;								                                   // 09
								   (_cAlias3)->F2_LOJA,;									                               // 10
								   _cRazaoCli,;											                                   // 11
								   (_cAlias3)->VALTOT,;									                                   // 12
								   0,;													                                   // 13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   // 14
								   0,;													                                   // 15
								   (_cAlias3)->VALTOT*-1,;							                                       // 16
								   _cCodVen,;												                               // 17
								   POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                               // 18
								   _ccodsup,;												                               // 19
								   _cnomesup,;												                               // 20
								   _ccodcoord,;											                                   // 21
								   _cnomecoord,;											                               // 22
                                   _cCodGNac,;                                                                             // 23
                                   _cNomeGNac,;                                                                            // 24 
								   U_ROMS025I(round((_cAlias3)->COMIS1/-100,3),"@E 999,999,999.999"),;					   // 23-->25
								   U_ROMS025I(round((_cAlias3)->COMIS1/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 24-->26
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 25-->27  "% Com Nota Rep"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 26-->28  "Media % Sistemica Rep"
								   U_ROMS025I(round((_cAlias3)->COMIS4/-100,3),"@E 999,999,999.999"),;					   // 27-->29  "Vlr Com Sup"
								   U_ROMS025I(round((_cAlias3)->COMIS4/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 28-->30  "% Com Sup"	
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 29-->31  "% Com Nota Sup"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 30-->32  "Media % Sistemica Sup"
								   U_ROMS025I(round((_cAlias3)->COMIS2/-100,3),"@E 999,999,999.999"),;					   // 31-->33  "Vlr Com Cood"
								   U_ROMS025I(round((_cAlias3)->COMIS2/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 32-->34  "% Com Cood"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 33-->35  "% Com Nota Coord" 
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 34-->36  "Media % Sistemica Coord"
                                   U_ROMS025I(round((_cAlias3)->COMIS5/-100,3),"@E 999,999,999.999"),;					   // 37 "Vlr Com Ger Nac"
								   U_ROMS025I(round((_cAlias3)->COMIS5/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 38 "% Com Ger Nac"	
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 39 "% Com Nota Ger Nac"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 40 "Media % Sistemica Ger Nac"
								   " ";                                                                                    // 35-->41 "Sequenc.Comiss�o"
								   }
                           _aLinhaAD :=  { U_ROMS025I((_cAlias3)->VALDCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  		
                           }
                  ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // N�o imprime gerente Nacional // 5
				     _aLinhaD :=  {(_cAlias3)->F2_FILIAL	,;					                                           // 01
								   "BON",;													                               // 02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   // 03
								   "  ",;													                               // 04
								   (_cAlias3)->F2_DOC,;									                                   // 05
								   "  ",;													                               // 06
								   _cCodGrupo ,;											                               // 07
								   _cDescGrupo,;											                               // 08
								   (_cAlias3)->F2_CLIENTE,;								                                   // 09
								   (_cAlias3)->F2_LOJA,;									                               // 10
								   _cRazaoCli,;											                                   // 11
								   (_cAlias3)->VALTOT,;									                                   // 12
								   0,;													                                   // 13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   // 14
								   0,;													                                   // 15
								   (_cAlias3)->VALTOT*-1,;							                                       // 16
								   _cCodVen,;												                               // 17
								   POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                               // 18
								   _ccodsup,;												                               // 19
								   _cnomesup,;												                               // 20
								   _ccodcoord,;											                                   // 21
								   _cnomecoord,;											                               // 22
								   _ccodger,;												                               // 23
								   _cnomeger,;												                               // 24
								   U_ROMS025I(round((_cAlias3)->COMIS1/-100,3),"@E 999,999,999.999"),;					   // 23-->25
								   U_ROMS025I(round((_cAlias3)->COMIS1/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 24-->26
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 25-->27  "% Com Nota Rep"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 26-->28  "Media % Sistemica Rep"
								   U_ROMS025I(round((_cAlias3)->COMIS4/-100,3),"@E 999,999,999.999"),;					   // 27-->29  "Vlr Com Sup"
								   U_ROMS025I(round((_cAlias3)->COMIS4/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 28-->30  "% Com Sup"	
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 29-->31  "% Com Nota Sup"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 30-->32  "Media % Sistemica Sup"
								   U_ROMS025I(round((_cAlias3)->COMIS2/-100,3),"@E 999,999,999.999"),;					   // 31-->33  "Vlr Com Cood"
								   U_ROMS025I(round((_cAlias3)->COMIS2/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 32-->34  "% Com Cood"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 33-->35  "% Com Nota Coord" 
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 34-->36  "Media % Sistemica Coord"
								   U_ROMS025I(round((_cAlias3)->COMIS3/-100,3),"@E 999,999,999.999"),;					   // 37  "Vlr Com Ger"
								   U_ROMS025I(round((_cAlias3)->COMIS3/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 38  "% Com Ger"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 39  "% Com Nota Ger"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 40  "Media % Sistemica Ger"
								   " ";                                                                                    // 35-->41  "Sequenc.Comiss�o"
								   } 
                           _aLinhaAD :=  { U_ROMS025I((_cAlias3)->VALDCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  		
                           }
                  ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // imprime apenas gerente nacional
				     _aLinhaD :=  {(_cAlias3)->F2_FILIAL	,;					                                           // 01
								   "BON",;													                               // 02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   // 03
								   "  ",;													                               // 04
								   (_cAlias3)->F2_DOC,;									                                   // 05
								   "  ",;													                               // 06
								   _cCodGrupo ,;											                               // 07
								   _cDescGrupo,;											                               // 08
								   (_cAlias3)->F2_CLIENTE,;								                                   // 09
								   (_cAlias3)->F2_LOJA,;									                               // 10
								   _cRazaoCli,;											                                   // 11
								   (_cAlias3)->VALTOT,;									                                   // 12
								   0,;													                                   // 13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   // 14
								   0,;													                                   // 15
								   (_cAlias3)->VALTOT*-1,;							                                       // 16
								   _cCodGNac,;                                                                             // 17
                                   _cNomeGNac,;                                                                            // 18 
								   U_ROMS025I(round((_cAlias3)->COMIS5/-100,3),"@E 999,999,999.999"),;					   // 19 "Vlr Com Ger Nac"
								   U_ROMS025I(round((_cAlias3)->COMIS5/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 20 "% Com Ger Nac"	
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 21 "% Com Nota Ger Nac"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 22 "Media % Sistemica Ger Nac"
								   " ";                                                                                    // 23 "Sequenc.Comiss�o"
							    	}
                           _aLinhaAD :=  { U_ROMS025I((_cAlias3)->VALDCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  		
                           }
                  ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07// imprime apenas gerente // 6
				     _aLinhaD :=  {(_cAlias3)->F2_FILIAL	,;					                                           // 01
								   "BON",;													                               // 02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   // 03
								   "  ",;													                               // 04
								   (_cAlias3)->F2_DOC,;									                                   // 05
								   "  ",;													                               // 06
								   _cCodGrupo ,;											                               // 07
								   _cDescGrupo,;											                               // 08
								   (_cAlias3)->F2_CLIENTE,;								                                   // 09
								   (_cAlias3)->F2_LOJA,;									                               // 10
								   _cRazaoCli,;											                                   // 11
								   (_cAlias3)->VALTOT,;									                                   // 12
								   0,;													                                   // 13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   // 14
								   0,;													                                   // 15
								   (_cAlias3)->VALTOT*-1,;							                                       // 16
								   _ccodger,;												                               // 17
								   _cnomeger,;												                               // 18
								   U_ROMS025I(round((_cAlias3)->COMIS3/-100,3),"@E 999,999,999.999"),;					   // 19
								   U_ROMS025I(round((_cAlias3)->COMIS3/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 20
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 21 "% Com Nota Ger"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 22 "Media % Sistemica Ger"
								   " ";                                                                                    // 23 "Sequenc.Comiss�o"
							    	}
                           _aLinhaAD :=  { U_ROMS025I((_cAlias3)->VALDCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  		
                           }
                  ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas Coordenador // 7
				     _aLinhaD :=  {(_cAlias3)->F2_FILIAL	,;					                                           // 01
							       "BON",;													                               // 02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   // 03
								   "  ",;													                               // 04
								   (_cAlias3)->F2_DOC,;									                                   // 05
								   "  ",;													                               // 06
								   _cCodGrupo ,;											                               // 07
								   _cDescGrupo,;											                               // 08
								   (_cAlias3)->F2_CLIENTE,;								                                   // 09
								   (_cAlias3)->F2_LOJA,;									                               // 10
								   _cRazaoCli,;											                                   // 11
								   (_cAlias3)->VALTOT,;									                                   // 12
								   0,;													                                   // 13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   // 14
								   0,;													                                   // 15
								   (_cAlias3)->VALTOT*-1,;							                                       // 16
								   _ccodcoord,;											                                   // 17
								   _cnomecoord,;											                               // 18
								   U_ROMS025I(round((_cAlias3)->COMIS2/-100,3),"@E 999,999,999.999"),;					   // 19
								   U_ROMS025I(round((_cAlias3)->COMIS2/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 20
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 21 "% Com Nota Coord"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 22 "Media % Sistemica Coord"
								   " ";                                                                                    // 23 "Sequenc.Comiss�o"
								   }
                           _aLinhaAD :=  { U_ROMS025I((_cAlias3)->VALDCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  		
                           }
                  ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas supervisor // 8 
				     _aLinhaD :=  {(_cAlias3)->F2_FILIAL	,;					                                           // 01
								   "BON",;													                               // 02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   // 03
								   "  ",;													                               // 04
								   (_cAlias3)->F2_DOC,;									                                   // 05
								   "  ",;													                               // 06
								   _cCodGrupo ,;											                               // 07
								   _cDescGrupo,;											                               // 08
								   (_cAlias3)->F2_CLIENTE,;								                                   // 09
								   (_cAlias3)->F2_LOJA,;									                               // 10
								   _cRazaoCli,;											                                   // 11
								   (_cAlias3)->VALTOT,;									                                   // 12
								   0,;													                                   // 13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   // 14
								   0,;													                                   // 15
								   (_cAlias3)->VALTOT*-1,;							                                       // 16
								   _ccodsup,;												                               // 17
								   _cnomesup,;												                               // 18
								   U_ROMS025I(round((_cAlias3)->COMIS4/-100,3),"@E 999,999,999.999"),;					   // 19
				    			   U_ROMS025I(round((_cAlias3)->COMIS4/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 20
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 21 "% Com Nota Sup"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 22 "Media % Sistemica Sup"
								   " ";                                                                                    // 23 "Sequenc.Comiss�o"
								   }
                           _aLinhaAD :=  { U_ROMS025I((_cAlias3)->VALDCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  		
                           }
                  ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas vendedor // 9 
				     _aLinhaD :=  {(_cAlias3)->F2_FILIAL	,;					                                           // 01
								   "BON",;													                               // 02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   // 03
								   "  ",;													                               // 04
								   (_cAlias3)->F2_DOC,;									                                   // 05
								   "  ",;													                               // 06
								   _cCodGrupo ,;											                               // 07
								   _cDescGrupo,;											                               // 08
								   (_cAlias3)->F2_CLIENTE,;								                                   // 09
								   (_cAlias3)->F2_LOJA,;									                               // 10
								   _cRazaoCli,;											                                   // 11
								   (_cAlias3)->VALTOT,;									                                   // 12
								   0,;													                                   // 13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   // 14
								   0,;													                                   // 15
								   (_cAlias3)->VALTOT*-1,;							                                       // 16
								   _cCodVen,;												                               // 17
								   POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                               // 18
								   U_ROMS025I(round((_cAlias3)->COMIS1/-100,3),"@E 999,999,999.999"),;					   // 19
								   U_ROMS025I(round((_cAlias3)->COMIS1/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   // 20
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 21 "% Com Nota Rep"
                                   U_ROMS025I(0,"@E 999,999,999.999"),;                                                     // 22 "Media % Sistemica Rep"
								   " ";                                                                                    // 23 "Sequenc.Comiss�o"
							 	   }
                           _aLinhaAD :=  { U_ROMS025I((_cAlias3)->VALDCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  		
                           }
                  Else // N�o exibe dados do relat�rio em excel.
                     _aLinhaD := {}		
                     _aDados  := {}
                  EndIf
			   EndIf

			   If ! Empty(_aLinhaD)
                  _aRegDados := ROMS025G(_aLinhaD, (_cAlias3)->F2_FILIAL, (_cAlias3)->F2_DOC, (_cAlias3)->F2_SERIE, (_cAlias3)->F2_CLIENTE, (_cAlias3)->F2_LOJA,"BON",_aLinhaAD)
            
                  For _nI := 1 To Len(_aRegDados)
                      Aadd(_aDados, AClone(_aRegDados[_nI]))
                  Next

				  _aLinhaD :=  {}	

               EndIf
			   
			   (_cAlias3)->( Dbskip() )
			Enddo
		 EndIf					
		 
		 (_cAlias)->(DbSkip())
		 
	  EndDo
   EndIf

End Sequence

MV_PAR06 := _cMVPAR05   // Filtro Vendedor 
	
//==========================
//Finaliza o alias criado.
//==========================
dbSelectArea(_cAlias)
(_cAlias)->(dbCloseArea())    

Return 

/*
===============================================================================================================================
Programa--------: ROMS025G
Autor-----------: Julio de Paula Paz
Data da Criacao-: 07/01/2019
Descri��o-------: Le e retorna os dados dos itens das notas fiscais.
Parametros------: _aDadosRel = Array com os dados do relat�rio.
                  _cFilialNF = Filial da nota.
                  _cNRNF     = Numero da nota.
                  _cSerieNf  = Serie da nota.
                  _cCodCli   = Codigo do Cliente.
                  _cLojaCli  = Loja do Cliente.
                  _cTipoDoc  = Tipo de Documento: NF, NCC.                  
Retorno---------: aRet = Array com os dados do relat�rio mais os dados dos itens da nota fiscal.
===============================================================================================================================
*/                          //1            2                        3                    4                       5                       6                      7                       8
Static Function ROMS025G(_aDadosR As Array, _cFilialNF As Character, _cNRNF As Character, _cSerieNf As Character, _cCodCli As Character, _cLojaCli As Character, _cTipoDoc As Character, _aDadosRAD As Array) As Array
Local _aRet As Array
Local _aLinhaNF As Array
Local _aOrd As Array
Local _nI As Numeric
Local _cDescPrd As Character
Local _aComiss As Array
Local _nComisVend As Numeric
Local _nComisSuper As Numeric
Local _nComisCoord As Numeric
Local _nComisGer As Numeric
Local _nComisGNac As Numeric
Local _nValTotMerc As Numeric
Local _nTotNF As Numeric
Local _nPercItem As Numeric
Local _nFatorBas As Numeric
Local _nMedSisVd As Numeric
Local _nMedSisSp As Numeric
Local _nMedSisCo As Numeric
Local _nMedSisGe As Numeric
Local _nMedSisGN As Numeric
Local _nPerSisVd As Numeric
Local _nPerSisSp As Numeric
Local _nPerSisCo As Numeric
Local _nPerSisGe As Numeric
Local _nPerSisGN As Numeric
Local _nValTotItem As Numeric
Local _cBIMIX As Character
Local i As Numeric

_aRet := {}
_aLinhaNF := {}
_aOrd := SaveOrd({"SD1","SD2","SE1","SF1","SF2"})
_nI:= 0
_cDescPrd := ""
_aComiss := {}
_nComisVend  := 0
_nComisSuper := 0
_nComisCoord := 0
_nComisGer := 0
_nComisGNac := 0
_nValTotMerc := 1 // Inicializado com um para divis�o.
_nTotNF := 0
_nPercItem := 0
_nFatorBas := 0
_nMedSisVd := 0
_nMedSisSp := 0
_nMedSisCo := 0
_nMedSisGe := 0
_nMedSisGN := 0
_nPerSisVd := 0
_nPerSisSp := 0
_nPerSisCo := 0
_nPerSisGe := 0
_nPerSisGN := 0
_nValTotItem := 0
_cBIMIX := ""
i := 0

Begin Sequence
   //==========================================================================
   // Nota Fiscal de Devolu��o - Deve-se localizar a nota fiscal de origem.
   //==========================================================================
   If AllTrim(_cTipoDoc) == "NCC"   // DEVOLU��O
      SD1->(DbSetOrder(1)) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM                                                                                                     
      If SD1->(DbSeek(U_ItKey(_cFilialNF,"D1_FILIAL")+U_ItKey(_cNRNF,"D1_DOC")+U_ItKey(_cSerieNf,"D1_SERIE")+U_ItKey(_cCodCli,"D1_FORNECE")+U_ItKey(_cLojaCli,"D1_LOJA")))
	     SF1->(DbSetOrder(1)) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO

         Do While ! SD1->(Eof()) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == U_ItKey(_cFilialNF,"D1_FILIAL")+U_ItKey(_cNRNF,"D1_DOC")+U_ItKey(_cSerieNf,"D1_SERIE")+U_ItKey(_cCodCli,"D1_FORNECE")+U_ItKey(_cLojaCli,"D1_LOJA")
		    SF1->(DbSeek(SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)))
            _nTotNF := SF1->F1_VALMERC
            _nPercItem := SD1->D1_TOTAL / SF1->F1_VALMERC

            _aLinhaNF := {}
            For _nI := 1 To Len(_aDadosR)
                Aadd(_aLinhaNF, _aDadosR[_nI])
            Next

            _aComiss     := U_ROMS025B(SD1->D1_FILIAL,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_COD)
            _nComisVend  := _aComiss[1] // % Comiss�o Vendedor            - D2_COMIS1
            _nComisCoord := _aComiss[2] // % Comiss�o Coordenador         - D2_COMIS2
            _nComisGer   := _aComiss[3] // % Comiss�o Gerente             - D2_COMIS3
            _nComisSuper := _aComiss[4] // % Comiss�o Supervidor          - D2_COMIS4
            _nValTotMerc := _aComiss[5] // Valor total mercadoria SF2     - F2_VALMERC
            _nValTotItem := _aComiss[6] // Valor Total do item Tabela SD2 - D2_TOTAL
            _nComisGNac  := _aComiss[7] // % Comiss�o Gerente Nacional    - D2_COMIS5

            If _nValTotMerc == 0
               _nValTotMerc := 1 // Inicializado com 1 para divis�o. 
            EndIf

            _nTotNF := _nValTotMerc //SF2->F2_VALMERC 

            _nFatorBas := _aDadosR[16] / _nTotNF

            _nPercItem := _nValTotItem / _nTotNF 
            
            _nMedSisVd := (_nValTotItem * _nComisVend  * _nFatorBas) / 100
			_nMedSisSp := (_nValTotItem * _nComisSuper * _nFatorBas) / 100
			_nMedSisCo := (_nValTotItem * _nComisCoord * _nFatorBas) / 100
			_nMedSisGe := (_nValTotItem * _nComisGer   * _nFatorBas) / 100
            _nMedSisGN := (_nValTotItem * _nComisGNac   * _nFatorBas) / 100
            _nPerSisVd := (_nMedSisVd / _nValTotItem / _nFatorBas) * 100
			_nPerSisSp := (_nMedSisSp / _nValTotItem / _nFatorBas) * 100
			_nPerSisCo := (_nMedSisCo / _nValTotItem / _nFatorBas) * 100
			_nPerSisGe := (_nMedSisGe / _nValTotItem / _nFatorBas) * 100
            _nPerSisGN := (_nMedSisGN / _nValTotItem / _nFatorBas) * 100
            
            If Empty(MV_PAR07) .Or. ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 ) // Imprime todos os dados  // 1
               _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                                      // SD1->D1_TOTAL // 12   Valor total do item.	
			   _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem                              // (SD1->D1_TOTAL/_nValTotMerc)  // 13   Compensa��o  
			   _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem                               // 14 Desconto do item.	SD1->D1_DESC 						
			   _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem                               // 15 (SD1->D1_TOTAL/_nValTotMerc)             // 15   
			   _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                                      // 16 _nbasecomis * _nPercItem        // (SD1->D1_TOTAL/_nValTotMerc)                      // 16   
			   _aLinhaNF[27] := _aLinhaNF[16] * (_nComisVend / 100)                             // 25 -- > 27 
			   _aLinhaNF[28] := _nComisVend                                                     // 26 -- > 28  

			   _aLinhaNF[29] := _nPerSisVd                                                      // "% Com Nota Rep",;          // 27 --> 29
			   _aLinhaNF[30] := _nMedSisVd		                                                // "Media % Sistemica Rep",;   // 28 --> 30

			   _aLinhaNF[31] := _aLinhaNF[16] * (_nComisSuper / 100)                            // 29 --> 31 // "Vlr Com Sup"
			   _aLinhaNF[32] := _nComisSuper	                                                // 30 --> 32 // "% Com Sup"

			   _aLinhaNF[33] := _nPerSisSp                                                      // "% Com Nota Sup",;        // 31 --> 33
			   _aLinhaNF[34] := _nMedSisSp                                                      // "Media % Sistemica Sup",; // 32 --> 34

			   _aLinhaNF[35] := _aLinhaNF[16] * (_nComisCoord / 100)		                    // "Vlr Com Cood" 33 --> 35  
			   _aLinhaNF[36] := _nComisCoord	                                                // "% Com Cood"   34 --> 36  

			   _aLinhaNF[37] := _nPerSisCo                                                      // "% Com Nota Coord",;        // 35 -->37  Calculado
			   _aLinhaNF[38] := _nMedSisCo                                                      // "Media % Sistemica Coord",; // 36 -->38  Calculado 

			   _aLinhaNF[39] := _aLinhaNF[16]  * (_nComisGer / 100)	                            // "Vlr Com Ger"  37 -->39
			   _aLinhaNF[40] := _nComisGer                                                      // "% Com Ger"    38 -->40

               _aLinhaNF[41] := _nPerSisGe                                                      // "% Com Nota Ger",;         39 -->41  Calculado
			   _aLinhaNF[42] := _nMedSisGe                                                      // "Media % Sistemica Ger",;  40 -->42  Calculado			   

               _aLinhaNF[43] := _aLinhaNF[16]  * (_nComisGNac / 100)	                        // "Vlr Com Ger Nac"  
			   _aLinhaNF[44] := _nComisGNac                                                     // "% Com Ger Nac"    

               _aLinhaNF[45] := _nPerSisGN                                                     // "% Com Nota Ger Nac",;         
			   _aLinhaNF[46] := _nMedSisGN                                                     // "Media % Sistemica Ger Nac",;  

			   //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
               _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                    // 12   Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                    // 13   Compensa��o  
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                    // 14   Desconto do item.							
			   _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                    // 15   
			   _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")                    // 16   
			   _aLinhaNF[25] := U_ROMS025I(_aLinhaNF[25],"@E 999,999,999.999")                    // 25   
			   _aLinhaNF[26] := U_ROMS025I(_aLinhaNF[26],"@E 999,999,999.999")                    // 26   
			   _aLinhaNF[27] := U_ROMS025I(_aLinhaNF[27],"@E 999,999,999.999")                    //
			   _aLinhaNF[28] := U_ROMS025I(_aLinhaNF[28],"@E 999,999,999.999") 		            // 
			   _aLinhaNF[29] := U_ROMS025I(_aLinhaNF[29],"@E 999,999,999.999")                    // 
			   _aLinhaNF[30] := U_ROMS025I(_aLinhaNF[30],"@E 999,999,999.999")                    // 
			   _aLinhaNF[31] := U_ROMS025I(_aLinhaNF[31],"@E 999,999,999.999")                    // 
			   _aLinhaNF[32] := U_ROMS025I(_aLinhaNF[32],"@E 999,999,999.999")                    // 
			   _aLinhaNF[33] := U_ROMS025I(_aLinhaNF[33],"@E 999,999,999.999") 		            // 
			   _aLinhaNF[34] := U_ROMS025I(_aLinhaNF[34],"@E 999,999,999.999") 	                // 
			   _aLinhaNF[35] := U_ROMS025I(_aLinhaNF[35],"@E 999,999,999.999")                    // 
			   _aLinhaNF[36] := U_ROMS025I(_aLinhaNF[36],"@E 999,999,999.999")                    // 
			   _aLinhaNF[37] := U_ROMS025I(_aLinhaNF[37],"@E 999,999,999.999") 	                // 
			   _aLinhaNF[38] := U_ROMS025I(_aLinhaNF[38],"@E 999,999,999.999")                    // 
               _aLinhaNF[39] := U_ROMS025I(_aLinhaNF[39],"@E 999,999,999.999")                    // 
			   _aLinhaNF[40] := U_ROMS025I(_aLinhaNF[40],"@E 999,999,999.999")                    // 
		       _aLinhaNF[41] := U_ROMS025I(_aLinhaNF[41],"@E 999,999,999.999")                    // 41 
			   _aLinhaNF[42] := U_ROMS025I(_aLinhaNF[42],"@E 999,999,999.999")                    // 42 
			   _aLinhaNF[43] := U_ROMS025I(_aLinhaNF[43],"@E 999,999,999.999") 	                 // 43
			   _aLinhaNF[44] := U_ROMS025I(_aLinhaNF[44],"@E 999,999,999.999")                    // 44
               _aLinhaNF[45] := U_ROMS025I(_aLinhaNF[45],"@E 999,999,999.999")                    // 45
			   _aLinhaNF[46] := U_ROMS025I(_aLinhaNF[46],"@E 999,999,999.999")                    // 46


            ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07 //  N�o imprime vendedor // 2 
               _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                                       //_aLinhaNF[12]  := SD1->D1_TOTAL                                                   // 12  Valor total do item.	
			   _aLinhaNF[13]  := (_cAlias)->COMPENSACA * _nPercItem                              // (SD1->D1_TOTAL/_nValTotMerc)            // 13  Compensa��o
			   _aLinhaNF[14]  := (_cAlias)->DESCONTO  * _nPercItem                               // 14  Desconto do item.	//SD1->D1_DESC						
			   _aLinhaNF[15]  := (_cAlias)->BAIXASANT * _nPercItem                               // (SD1->D1_TOTAL/_nValTotMerc)             // 15  
			   _aLinhaNF[16]  := _aLinhaNF[16] * _nPercItem                                      // _nbasecomis * _nPercItem // (SD1->D1_TOTAL/_nValTotMerc)                      // 16  

			   _aLinhaNF[25]  := _aLinhaNF[16] * (_nComisSuper / 100)                            // 23-->25   
			   _aLinhaNF[26]  := _nComisSuper                                                    // 24-->26  
               _aLinhaNF[27]  := _nPerSisSp                                                      // "% Com Nota Sup",;           25-->27  
               _aLinhaNF[28]  := _nMedSisSp                                                      // "Media % Sistemica Sup",;    26-->28   
			   _aLinhaNF[29]  := _aLinhaNF[16] * (_nComisCoord / 100)                            // "Vlr Com Cood"               27-->29 
			   _aLinhaNF[30]  := _nComisCoord                                                    // "% Com Cood"                 28-->30 
               _aLinhaNF[31]  :=  _nPerSisCo                                                     // "% Com Nota Coord",;         29-->31  
               _aLinhaNF[32]  :=  _nMedSisCo                                                     // "Media % Sistemica Coord",;  30-->32    
			   _aLinhaNF[33]  := _aLinhaNF[16] * (_nComisGer / 100)                              // "Vlr Com Ger"                31-->33  
			   _aLinhaNF[34]  := _nComisGer                                                      // "% Com Ger"		             32-->34 
               _aLinhaNF[35]  :=  _nPerSisGe                                                     // "% Com Nota Ger",;           33-->35   
               _aLinhaNF[36]  :=  _nMedSisGe                                                     // "Media % Sistemica Ger",;    34-->36  

			   _aLinhaNF[37] := _aLinhaNF[16]  * (_nComisGNac / 100)	                         // "Vlr Com Ger Nac"  
			   _aLinhaNF[38] := _nComisGNac                                                      // "% Com Ger Nac"    
               _aLinhaNF[39] := _nPerSisGN                                                       // "% Com Nota Ger Nac",;         
			   _aLinhaNF[40] := _nMedSisGN                                                       // "Media % Sistemica Ger Nac",;  

			   //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
			   _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.99")                     // 12  Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.99")                     // 13  Compensa��o
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.99")                     // 14  Desconto do item.							
			   _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.99")                     // 15  
			   _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.99")                     // 16  

			   _aLinhaNF[25] := U_ROMS025I(_aLinhaNF[25],"@E 999,999,999.999")                     // 23-->25  
			   _aLinhaNF[26] := U_ROMS025I(_aLinhaNF[26],"@E 999,999,999.999")                     // 24-->26  
               _aLinhaNF[27] := U_ROMS025I(_aLinhaNF[27],"@E 999,999,999.999")                     // "% Com Nota Sup"          25-->27
               _aLinhaNF[28] := U_ROMS025I(_aLinhaNF[28],"@E 999,999,999.999")                     // "Media % Sistemica Sup"   26-->28 
			   _aLinhaNF[29] := U_ROMS025I(_aLinhaNF[29],"@E 999,999,999.999")                     // "Vlr Com Cood"	           27-->29
			   _aLinhaNF[30] := U_ROMS025I(_aLinhaNF[30],"@E 999,999,999.999")                     // "% Com Cood"              28-->30
               _aLinhaNF[31] := U_ROMS025I(_aLinhaNF[31],"@E 999,999,999.999")                     // "% Com Nota Coord"        29-->31 
               _aLinhaNF[32] := U_ROMS025I(_aLinhaNF[32],"@E 999,999,999.999")                     // "Media % Sistemica Coord" 30-->32   
			   _aLinhaNF[33] := U_ROMS025I(_aLinhaNF[33],"@E 999,999,999.999")                     // "Vlr Com Ger"             31-->33 
			   _aLinhaNF[34] := U_ROMS025I(_aLinhaNF[34],"@E 999,999,999.999")                     // "% Com Ger"		       32-->34
               _aLinhaNF[35] := U_ROMS025I(_aLinhaNF[35],"@E 999,999,999.999")                     // "% Com Nota Ger"          33-->35  
               _aLinhaNF[36] := U_ROMS025I(_aLinhaNF[36],"@E 999,999,999.999")                     // "Media % Sistemica Ger"   34-->36 
			   _aLinhaNF[37] := U_ROMS025I(_aLinhaNF[37],"@E 999,999,999.999")                     // "Vlr Com Ger Nac"             
			   _aLinhaNF[38] := U_ROMS025I(_aLinhaNF[38],"@E 999,999,999.999")                     // "% Com Ger Nac"		       
               _aLinhaNF[39] := U_ROMS025I(_aLinhaNF[39],"@E 999,999,999.999")                     // "% Com Nota Ger Nac"          
               _aLinhaNF[40] := U_ROMS025I(_aLinhaNF[40],"@E 999,999,999.999")                     // "Media % Sistemica Ger Nac"   


            ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime supervisor  // 3
               _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                                       // _aLinhaNF[12] := SD1->D1_TOTAL 	                                                // 12 Valor total do item.	
			   _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem                               // (SD1->D1_TOTAL/_nValTotMerc)            // 13 Compensa��o
			   _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem                                // 14 Desconto do item.	// SD1->D1_DESC						
			   _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem                                // (SD1->D1_TOTAL/_nValTotMerc)             // 15 
			   _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                                       // _nbasecomis * _nPercItem // (SD1->D1_TOTAL/_nValTotMerc) 	                    // 16 
			   _aLinhaNF[25] := _aLinhaNF[16] * (_nComisVend / 100) 	                         // 23-->25  
			   _aLinhaNF[26] := _nComisVend	                                                     // 24-->26 
               _aLinhaNF[27] := _nPerSisVd                                                       // "% Com Nota Rep",;          25-->27  
               _aLinhaNF[28] := _nMedSisVd                                                       // "Media % Sistemica Rep",;   26-->28 
			   _aLinhaNF[29] := _aLinhaNF[16] * (_nComisCoord / 100)	                         // "Vlr Com Cood"	,;		    27-->29
			   _aLinhaNF[30] := _nComisCoord	                                                 // "% Com Cood"	,;		    28-->30 
               _aLinhaNF[31] := _nPerSisCo                                                       // "% Com Nota Coord",;        29-->31  
			   _aLinhaNF[32] := _nMedSisCo                                                       // "Media % Sistemica Coord",; 30-->32 
			   _aLinhaNF[33] := _aLinhaNF[16] * (_nComisGer / 100)                               // "Vlr Com Ger"	,;		    31-->33
			   _aLinhaNF[34] :=	_nComisGer                                                       // "% Com Ger"		,;			32-->34
               _aLinhaNF[35] := _nPerSisGe                                                       // "% Com Nota Ger",;          33-->35
               _aLinhaNF[36] := _nMedSisGe                                                       // "Media % Sistemica Ger",;   34-->36
               _aLinhaNF[37] := _aLinhaNF[16]  * (_nComisGNac / 100)	                         // "Vlr Com Ger Nac"  
			   _aLinhaNF[38] := _nComisGNac                                                      // "% Com Ger Nac"    
               _aLinhaNF[39] := _nPerSisGN                                                       // "% Com Nota Ger Nac",;         
			   _aLinhaNF[40] := _nMedSisGN                                                       // "Media % Sistemica Ger Nac",;  			   
			   //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
               _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                    // 12 Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                    // 13 Compensa��o
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                    // 14 Desconto do item.							
			   _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                    // 15 
			   _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999") 	                 // 16 
			   _aLinhaNF[25] := U_ROMS025I(_aLinhaNF[23],"@E 999,999,999.999")                    // 23-->25  
			   _aLinhaNF[26] := U_ROMS025I(_aLinhaNF[24],"@E 999,999,999.999")                    // 24-->26  
               _aLinhaNF[27] := U_ROMS025I(_aLinhaNF[25],"@E 999,999,999.999")                    // "% Com Nota Rep"          25-->27 
               _aLinhaNF[28] := U_ROMS025I(_aLinhaNF[26],"@E 999,999,999.999")                    // "Media % Sistemica Rep"   26-->28
			   _aLinhaNF[29] := U_ROMS025I(_aLinhaNF[27],"@E 999,999,999.999")                    // "Vlr Com Cood"		      27-->29
			   _aLinhaNF[30] := U_ROMS025I(_aLinhaNF[28],"@E 999,999,999.999")                    // "% Com Cood"			  28-->30
               _aLinhaNF[31] := U_ROMS025I(_aLinhaNF[29],"@E 999,999,999.999")                    // "% Com Nota Coord"        29-->31  
			   _aLinhaNF[32] := U_ROMS025I(_aLinhaNF[30],"@E 999,999,999.999")                    // "Media % Sistemica Coord" 30-->32 
			   _aLinhaNF[33] := U_ROMS025I(_aLinhaNF[31],"@E 999,999,999.999")                    // "Vlr Com Ger"		      31-->33
			   _aLinhaNF[34] :=	U_ROMS025I(_aLinhaNF[32],"@E 999,999,999.999")                    // "% Com Ger"			      32-->34
               _aLinhaNF[35] := U_ROMS025I(_aLinhaNF[33],"@E 999,999,999.999")                    // "% Com Nota Ger"          33-->35
               _aLinhaNF[36] := U_ROMS025I(_aLinhaNF[34],"@E 999,999,999.999")                    // "Media % Sistemica Ger"   34-->36
			   _aLinhaNF[37] := U_ROMS025I(_aLinhaNF[37],"@E 999,999,999.999")                     // "Vlr Com Ger Nac"             
			   _aLinhaNF[38] := U_ROMS025I(_aLinhaNF[38],"@E 999,999,999.999")                     // "% Com Ger Nac"		       
               _aLinhaNF[39] := U_ROMS025I(_aLinhaNF[39],"@E 999,999,999.999")                     // "% Com Nota Ger Nac"          
               _aLinhaNF[40] := U_ROMS025I(_aLinhaNF[40],"@E 999,999,999.999")                     // "Media % Sistemica Ger Nac"   

            ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime Coordenador  // 4
			   _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                                      // _aLinhaNF[12] := SD1->D1_TOTAL                                                   // 12  Valor total do item.	
			   _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem                              // (SD1->D1_TOTAL/_nValTotMerc) // 13  Compensa��o
			   _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem                               // 14  Desconto do item.	// SD1->D1_DESC			
			   _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem                               // (SD1->D1_TOTAL/_nValTotMerc) // 15  
			   _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                                      // _nbasecomis * _nPercItem //  (SD1->D1_TOTAL/_nValTotMerc)                      // 16  
			   _aLinhaNF[25] := _aLinhaNF[16] * (_nComisVend / 100)                             // 23-->25  
			   _aLinhaNF[26] := _nComisVend                                                     // 24-->26 
			   _aLinhaNF[27] := _nPerSisVd                                                      // "% Com Nota Rep"          25-->27
               _aLinhaNF[28] := _nMedSisVd                                                      // "Media % Sistemica Rep"   26-->28 
			   _aLinhaNF[29] := _aLinhaNF[16] * (_nComisSuper / 100)                            // "Vlr Com Sup"             27-->29
			   _aLinhaNF[30] := _nComisSuper                                                    // "% Com Sup"	             28-->30
               _aLinhaNF[31] := _nPerSisSp                                                      // "% Com Nota Sup"          29-->31
               _aLinhaNF[32] := _nMedSisSp                                                      // "Media % Sistemica Sup"   30-->32  
			   _aLinhaNF[33] := _aLinhaNF[16] * (_nComisGer / 100)                              // "Vlr Com Ger"             31-->33
			   _aLinhaNF[34] := _nComisGer                                                      // "% Com Ger"	             32-->34
               _aLinhaNF[35] := _nPerSisGe                                                      // "% Com Nota Ger"          33-->35
               _aLinhaNF[36] := _nMedSisGe                                                      // "Media % Sistemica Ger"   34-->36
               _aLinhaNF[37] := _aLinhaNF[16]  * (_nComisGNac / 100)	                         // "Vlr Com Ger Nac"  
			   _aLinhaNF[38] := _nComisGNac                                                      // "% Com Ger Nac"    
               _aLinhaNF[39] := _nPerSisGN                                                       // "% Com Nota Ger Nac",;         
			   _aLinhaNF[40] := _nMedSisGN                                                       // "Media % Sistemica Ger Nac",;  			   

			   //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
               _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                    // 12  Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                    // 13  Compensa��o
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                    // 14  Desconto do item.							
			   _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                    // 15  
			   _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")                    // 16  
			   _aLinhaNF[25] := U_ROMS025I(_aLinhaNF[25],"@E 999,999,999.999")                    // 23-->25  
			   _aLinhaNF[26] := U_ROMS025I(_aLinhaNF[26],"@E 999,999,999.999")                    // 24-->26  
			   _aLinhaNF[27] := U_ROMS025I(_aLinhaNF[27],"@E 999,999,999.999")                    // "% Com Nota Rep",;         25-->27 
               _aLinhaNF[28] := U_ROMS025I(_aLinhaNF[28],"@E 999,999,999.999")                    // "Media % Sistemica Rep",;  26-->28 
			   _aLinhaNF[29] := U_ROMS025I(_aLinhaNF[29],"@E 999,999,999.999")                    // "Vlr Com Sup"              27-->29
			   _aLinhaNF[30] := U_ROMS025I(_aLinhaNF[30],"@E 999,999,999.999")                    // "% Com Sup"	               28-->30
               _aLinhaNF[31] := U_ROMS025I(_aLinhaNF[31],"@E 999,999,999.999")                    // "% Com Nota Sup"           29-->31 
               _aLinhaNF[32] := U_ROMS025I(_aLinhaNF[32],"@E 999,999,999.999")                    // "Media % Sistemica Sup"    30-->32 
			   _aLinhaNF[33] := U_ROMS025I(_aLinhaNF[33],"@E 999,999,999.999")                    // "% Com Ger"	               32-->34
               _aLinhaNF[35] := U_ROMS025I(_aLinhaNF[35],"@E 999,999,999.999")                    // "% Com Nota Ger"           33-->35 
               _aLinhaNF[36] := U_ROMS025I(_aLinhaNF[36],"@E 999,999,999.999")                    // "Media % Sistemica Ger"    34-->36 
               _aLinhaNF[37] := U_ROMS025I(_aLinhaNF[37],"@E 999,999,999.999")                    // "Vlr Com Ger Nac"             
			   _aLinhaNF[38] := U_ROMS025I(_aLinhaNF[38],"@E 999,999,999.999")                    // "% Com Ger Nac"		       
               _aLinhaNF[39] := U_ROMS025I(_aLinhaNF[39],"@E 999,999,999.999")                    // "% Com Nota Ger Nac"          
               _aLinhaNF[40] := U_ROMS025I(_aLinhaNF[40],"@E 999,999,999.999")                    // "Media % Sistemica Ger Nac"   

            ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime gerente     // 5 
               _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                                      //_aLinhaNF[12] := SD1->D1_TOTAL                                                   // 12  Valor total do item.	
			   _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem                              //(SD1->D1_TOTAL/_nValTotMerc)   // 13  Compensa��o
			   _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem                               // 14  Desconto do item. // SD1->D1_DESC		
		       _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem                               // (SD1->D1_TOTAL/_nValTotMerc)  // 15 
			   _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem // _nbasecomis * _nPercItem // (SD1->D1_TOTAL/_nValTotMerc)           // 16 
			   _aLinhaNF[25] := _aLinhaNF[16] * (_nComisVend / 100)                             // 23-->25 
			   _aLinhaNF[26] := _nComisVend                                                     // 24-->26 
               _aLinhaNF[27] := _nPerSisVd                                                      // "% Com Nota Rep"          25-->27
               _aLinhaNF[28] := _nMedSisVd                                                      // "Media % Sistemica Rep"   26-->28 
			   _aLinhaNF[29] := _aLinhaNF[16] * (_nComisSuper / 100)                            //  "Vlr Com Sup"            27-->29
			   _aLinhaNF[30] := _nComisSuper                                                    // "% Com Sup"	             28-->30
               _aLinhaNF[31] := _nPerSisSp                                                      // "% Com Nota Sup"          29-->31 
               _aLinhaNF[32] := _nMedSisSp                                                      // "Media % Sistemica Sup"   30-->32
			   _aLinhaNF[33] := _aLinhaNF[16] * (_nComisCoord / 100)                            // "Vlr Com Cood"            31-->33 
			   _aLinhaNF[34] := _nComisCoord                                                    // "% Com Cood"	             32-->34
               _aLinhaNF[35] := _nPerSisCo                                                      // "% Com Nota Coord"        33-->35 
               _aLinhaNF[36] := _nMedSisCo                                                      // "Media % Sistemica Coord" 34-->36 
               _aLinhaNF[37] := _aLinhaNF[16]  * (_nComisGNac / 100)	                         // "Vlr Com Ger Nac"  
			   _aLinhaNF[38] := _nComisGNac                                                      // "% Com Ger Nac"    
               _aLinhaNF[39] := _nPerSisGN                                                       // "% Com Nota Ger Nac",;         
			   _aLinhaNF[40] := _nMedSisGN                                                       // "Media % Sistemica Ger Nac",;  			   

			   //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
               _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                    // 12  Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                    // 13  Compensa��o
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                    // 14  Desconto do item.							
		       _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                    // 15 
	           _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")                    // 15 
			   _aLinhaNF[25] := U_ROMS025I(_aLinhaNF[25],"@E 999,999,999.999")                    // 23-->25 
			   _aLinhaNF[26] := U_ROMS025I(_aLinhaNF[26],"@E 999,999,999.999")                    // 24-->26 
               _aLinhaNF[27] := U_ROMS025I(_aLinhaNF[27],"@E 999,999,999.999")                    // "% Com Nota Rep"          25-->27
               _aLinhaNF[28] := U_ROMS025I(_aLinhaNF[28],"@E 999,999,999.999")                    // "Media % Sistemica Rep"   26-->28
			   _aLinhaNF[29] := U_ROMS025I(_aLinhaNF[29],"@E 999,999,999.999")                    //  "Vlr Com Sup"            27-->29
			   _aLinhaNF[30] := U_ROMS025I(_aLinhaNF[30],"@E 999,999,999.999")                    // "% Com Sup"	              28-->30
               _aLinhaNF[31] := U_ROMS025I(_aLinhaNF[31],"@E 999,999,999.999")                    // "% Com Nota Sup",;        29-->31
               _aLinhaNF[32] := U_ROMS025I(_aLinhaNF[32],"@E 999,999,999.999")                    // "Media % Sistemica Sup"   30-->32
			   _aLinhaNF[33] := U_ROMS025I(_aLinhaNF[33],"@E 999,999,999.999")                    // "Vlr Com Cood"            31-->33 
			   _aLinhaNF[34] := U_ROMS025I(_aLinhaNF[34],"@E 999,999,999.999")                    // "% Com Cood"	          32-->34
               _aLinhaNF[35] := U_ROMS025I(_aLinhaNF[35],"@E 999,999,999.999")                    // "% Com Nota Coord"        33-->35 
               _aLinhaNF[36] := U_ROMS025I(_aLinhaNF[36],"@E 999,999,999.999")                    // "Media % Sistemica Coord" 34-->36 
               _aLinhaNF[37] := U_ROMS025I(_aLinhaNF[37],"@E 999,999,999.999")                    // "Vlr Com Ger Nac"             
			   _aLinhaNF[38] := U_ROMS025I(_aLinhaNF[38],"@E 999,999,999.999")                    // "% Com Ger Nac"		       
               _aLinhaNF[39] := U_ROMS025I(_aLinhaNF[39],"@E 999,999,999.999")                    // "% Com Nota Ger Nac"          
               _aLinhaNF[40] := U_ROMS025I(_aLinhaNF[40],"@E 999,999,999.999")                    // "Media % Sistemica Ger Nac"   
           
		   ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime gerente nacional 
               _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                                      
			   _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem                              
			   _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem                               
		       _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem                               
			   _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem  
			   _aLinhaNF[25] := _aLinhaNF[16] * (_nComisVend / 100)                             // 23-->25 
			   _aLinhaNF[26] := _nComisVend                                                     // 24-->26 
               _aLinhaNF[27] := _nPerSisVd                                                      // "% Com Nota Rep"          25-->27
               _aLinhaNF[28] := _nMedSisVd                                                      // "Media % Sistemica Rep"   26-->28 
			   _aLinhaNF[29] := _aLinhaNF[16] * (_nComisSuper / 100)                            //  "Vlr Com Sup"            27-->29
			   _aLinhaNF[30] := _nComisSuper                                                    // "% Com Sup"	             28-->30
               _aLinhaNF[31] := _nPerSisSp                                                      // "% Com Nota Sup"          29-->31 
               _aLinhaNF[32] := _nMedSisSp                                                      // "Media % Sistemica Sup"   30-->32
			   _aLinhaNF[33] := _aLinhaNF[16] * (_nComisCoord / 100)                            // "Vlr Com Cood"            31-->33 
			   _aLinhaNF[34] := _nComisCoord                                                    // "% Com Cood"	             32-->34
               _aLinhaNF[35] := _nPerSisCo                                                      // "% Com Nota Coord"        33-->35 
               _aLinhaNF[36] := _nMedSisCo                                                      // "Media % Sistemica Coord" 34-->36 
               _aLinhaNF[37] := _aLinhaNF[16] * (_nComisGer / 100)                              // "Vlr Com Ger"             
			   _aLinhaNF[38] := _nComisGer                                                      // "% Com Ger"	             
               _aLinhaNF[39] := _nPerSisGe                                                      // "% Com Nota Ger"          
               _aLinhaNF[40] := _nMedSisGe                                                      // "Media % Sistemica Ger"   

			   //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
               _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                    // 12  Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                    // 13  Compensa��o
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                    // 14  Desconto do item.							
		       _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                    // 15 
	           _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")                    // 15 
			   _aLinhaNF[25] := U_ROMS025I(_aLinhaNF[25],"@E 999,999,999.999")                    // 23-->25 
			   _aLinhaNF[26] := U_ROMS025I(_aLinhaNF[26],"@E 999,999,999.999")                    // 24-->26 
               _aLinhaNF[27] := U_ROMS025I(_aLinhaNF[27],"@E 999,999,999.999")                    // "% Com Nota Rep"          25-->27
               _aLinhaNF[28] := U_ROMS025I(_aLinhaNF[28],"@E 999,999,999.999")                    // "Media % Sistemica Rep"   26-->28
			   _aLinhaNF[29] := U_ROMS025I(_aLinhaNF[29],"@E 999,999,999.999")                    //  "Vlr Com Sup"            27-->29
			   _aLinhaNF[30] := U_ROMS025I(_aLinhaNF[30],"@E 999,999,999.999")                    // "% Com Sup"	              28-->30
               _aLinhaNF[31] := U_ROMS025I(_aLinhaNF[31],"@E 999,999,999.999")                    // "% Com Nota Sup",;        29-->31
               _aLinhaNF[32] := U_ROMS025I(_aLinhaNF[32],"@E 999,999,999.999")                    // "Media % Sistemica Sup"   30-->32
			   _aLinhaNF[33] := U_ROMS025I(_aLinhaNF[33],"@E 999,999,999.999")                    // "Vlr Com Cood"            31-->33 
			   _aLinhaNF[34] := U_ROMS025I(_aLinhaNF[34],"@E 999,999,999.999")                    // "% Com Cood"	          32-->34
               _aLinhaNF[35] := U_ROMS025I(_aLinhaNF[35],"@E 999,999,999.999")                    // "% Com Nota Coord"        33-->35 
               _aLinhaNF[36] := U_ROMS025I(_aLinhaNF[36],"@E 999,999,999.999")                    // "Media % Sistemica Coord" 34-->36 
               _aLinhaNF[37] := U_ROMS025I(_aLinhaNF[37],"@E 999,999,999.999")                    // "Vlr Com Ger"              
			   _aLinhaNF[38] := U_ROMS025I(_aLinhaNF[38],"@E 999,999,999.999")                    // "% Com Ger"	               
               _aLinhaNF[39] := U_ROMS025I(_aLinhaNF[39],"@E 999,999,999.999")                    // "% Com Nota Ger"            
               _aLinhaNF[40] := U_ROMS025I(_aLinhaNF[40],"@E 999,999,999.999")                    // "Media % Sistemica Ger"     
 
            ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07  .And. ! "N" $ MV_PAR07  // imprime apenas gerente  // 6
               _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                                      // _aLinhaNF[12] := SD1->D1_TOTAL                                                   // 12  Valor total do item.	
			   _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem                              // (SD1->D1_TOTAL/_nValTotMerc)      // 13  Compensa��o
			   _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem                               // 14  Desconto do item.  //SD1->D1_DESC 							
			   _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem                               //(SD1->D1_TOTAL/_nValTotMerc)             // 15  
			   _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                                      // _nbasecomis * _nPercItem // (SD1->D1_TOTAL/_nValTotMerc)                      // 16  
			   _aLinhaNF[19] := _aLinhaNF[16] * (_nComisGer / 100)                              // 19  
			   _aLinhaNF[20] := _nComisGer                                                      // 20  
			   _aLinhaNF[21] := _nPerSisGe                                                      // "% Com Nota Ger",;          // 21 A 
               _aLinhaNF[22] := _nMedSisGe                                                      // "Media % Sistemica Ger",;   // 22 A
	
			   //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
               _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                   // 12  Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                   // 13  Compensa��o
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                   // 14  Desconto do item.							
			   _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                   // 15  
			   _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")                   // 16  
			   _aLinhaNF[19] := U_ROMS025I(_aLinhaNF[19],"@E 999,999,999.999")                   // 19  
			   _aLinhaNF[20] := U_ROMS025I(_aLinhaNF[20],"@E 999,999,999.999")                   // 20  
               _aLinhaNF[21] := U_ROMS025I(_aLinhaNF[21],"@E 999,999,999.999")                    // "% Com Nota Ger",;          // 21 A 
               _aLinhaNF[22] := U_ROMS025I(_aLinhaNF[22],"@E 999,999,999.999")                    // "Media % Sistemica Ger",;   // 22 A
 
            ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas Coordenador // 7 
           	   _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem  // _aLinhaNF[12] := SD1->D1_TOTAL                                                   // 12  Valor total do item.	
			   _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem                              // (SD1->D1_TOTAL/_nValTotMerc)     // 13  Compensa��o
			   _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem                               // 14  Desconto do item.	// SD1->D1_DESC				
			   _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem                               // (SD1->D1_TOTAL/_nValTotMerc)     // 15  
			   _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                                      // _nbasecomis * _nPercItem         // (SD1->D1_TOTAL/_nValTotMerc)                      // 16  
			   _aLinhaNF[19] := _aLinhaNF[16] * (_nComisCoord / 100)                            // 19  
               _aLinhaNF[20] := _nComisCoord                                                    // 20  
	           _aLinhaNF[21] := _nPerSisCo                                                      // "% Com Nota Coord",;        // 21 A
               _aLinhaNF[22] := _nMedSisCo                                                      // "Media % Sistemica Coord",; // 22 A 

	           //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
               _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                    // 12  Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                    // 13  Compensa��o
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                    // 14  Desconto do item.							
			   _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                    // 15  
			   _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")                    // 16  
			   _aLinhaNF[19] := U_ROMS025I(_aLinhaNF[19],"@E 999,999,999.999")                    // 19  
               _aLinhaNF[20] := U_ROMS025I(_aLinhaNF[20],"@E 999,999,999.999")                    // 20  
			   _aLinhaNF[21] := U_ROMS025I(_aLinhaNF[21],"@E 999,999,999.999")                    // "% Com Nota Coord",;        // 21 A
               _aLinhaNF[22] := U_ROMS025I(_aLinhaNF[22],"@E 999,999,999.999")                    // "Media % Sistemica Coord",; // 22 A 
               
            ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas supervisor  // 8
               _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                                      // _aLinhaNF[12] := SD1->D1_TOTAL                                                   // 12  Valor total do item.	
			   _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem                              // (SD1->D1_TOTAL/_nValTotMerc)    // 13  Compensa��o
			   _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem                               // 14  Desconto do item.	// SD1->D1_DESC						
			   _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem                               // (SD1->D1_TOTAL/_nValTotMerc)             // 15  
			   _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                                      // _nbasecomis * _nPercItem // (SD1->D1_TOTAL/_nValTotMerc)                      // 16  
			   _aLinhaNF[19] := _aLinhaNF[16] * (_nComisSuper / 100)                            // 19  
			   _aLinhaNF[20] := _nComisSuper                                                    // 20  
               _aLinhaNF[21] := _nPerSisSp                                                      // "% Com Nota Sup",;          // 21 A
               _aLinhaNF[22] := _nMedSisSp                                                      // "Media % Sistemica Sup",;   // 22 A

               //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
			   _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                    // 12  Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                    // 13  Compensa��o
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                    // 14  Desconto do item.							
			   _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                    // 15  
			   _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")                    // 16  
			   _aLinhaNF[19] := U_ROMS025I(_aLinhaNF[19],"@E 999,999,999.999")                    // 19  
			   _aLinhaNF[20] := U_ROMS025I(_aLinhaNF[20],"@E 999,999,999.999")                    // 20  
			   _aLinhaNF[21] := U_ROMS025I(_aLinhaNF[21],"@E 999,999,999.999")                    // "% Com Nota Sup",;          // 21 A
               _aLinhaNF[22] := U_ROMS025I(_aLinhaNF[22],"@E 999,999,999.999")                    // "Media % Sistemica Sup",;   // 22 A

            ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas vendedor  // 9 
               _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                                     // _aLinhaNF[12] := SD1->D1_TOTAL                                                   // 12 Valor total do item.	
			   _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem                             // (SD1->D1_TOTAL/_nValTotMerc)            // 13 Compensa��o
			   _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem                              // 14  Desconto do item.		//SD1->D1_DESC					
			   _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem                              // (SD1->D1_TOTAL/_nValTotMerc)             // 15  
			   _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                                     // _nbasecomis * _nPercItem // (SD1->D1_TOTAL/_nValTotMerc)                      // 16  
			   _aLinhaNF[19] := _aLinhaNF[16] * (_nComisVend / 100)                            // 19  
		       _aLinhaNF[20] := _nComisVend                                                    // 20  
               _aLinhaNF[21] := _nPerSisVd                                                     // "% Com Nota Rep",;          // 21 A
               _aLinhaNF[22] := _nMedSisVd                                                     // "Media % Sistemica Rep",;   // 22 A

               //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
               _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                    // 12 Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                    // 13 Compensa��o
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                    // 14  Desconto do item.							
			   _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                    // 15  
			   _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")                    // 16  
			   _aLinhaNF[19] := U_ROMS025I(_aLinhaNF[19],"@E 999,999,999.999")                    // 19  
		       _aLinhaNF[20] := U_ROMS025I(_aLinhaNF[20],"@E 999,999,999.999")                    // 20  
			   _aLinhaNF[21] := U_ROMS025I(_aLinhaNF[21],"@E 999,999,999.999")                    // "% Com Nota Rep",;          // 21 A
               _aLinhaNF[22] := U_ROMS025I(_aLinhaNF[22],"@E 999,999,999.999")                    // "Media % Sistemica Rep",;   // 22 A

            ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // imprime apenas Gerente Nacional  
               _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                                     
			   _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem                             
			   _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem                              
			   _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem                              
			   _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                                     
               _aLinhaNF[19] := _aLinhaNF[16]  * (_nComisGNac / 100)	                         // "Vlr Com Ger Nac"  
			   _aLinhaNF[20] := _nComisGNac                                                      // "% Com Ger Nac"    
               _aLinhaNF[21] := _nPerSisGN                                                       // "% Com Nota Ger Nac",;         
			   _aLinhaNF[22] := _nMedSisGN                                                       // "Media % Sistemica Ger Nac",;  			   
 
			   //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
               _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                    // 12 Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                    // 13 Compensa��o
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                    // 14  Desconto do item.							
			   _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                    // 15  
			   _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")                    // 16  
			   _aLinhaNF[19] := U_ROMS025I(_aLinhaNF[19],"@E 999,999,999.999")                    // 19  
		       _aLinhaNF[20] := U_ROMS025I(_aLinhaNF[20],"@E 999,999,999.999")                    // 20  
			   _aLinhaNF[21] := U_ROMS025I(_aLinhaNF[21],"@E 999,999,999.999")                    // "% Com Nota Rep",;          // 21 A
               _aLinhaNF[22] := U_ROMS025I(_aLinhaNF[22],"@E 999,999,999.999")                    // "Media % Sistemica Rep",;   // 22 A
            EndIf

            _cDescPrd := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DESC")     // Desc. Prod.
            _cBIMIX   := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_I_BIMIX")  // Mix BI
            
			Aadd(_aLinhaNF, _cBIMIX        )    // Mix BI
            Aadd(_aLinhaNF, SD1->D1_ITEM   )    // "Item"           
            Aadd(_aLinhaNF, SD1->D1_COD    )    // "Produto"           
            Aadd(_aLinhaNF, _cDescPrd      )    // "Descri��o"        
			Aadd(_aLinhaNF, U_ROMS025I(SD1->D1_PICM,"@E 999,999,999.999"))          // "Aliq.%"           
            Aadd(_aLinhaNF, U_ROMS025I(SD1->D1_QUANT,"@E 999,999,999.999"))         // "Qtde"             
			Aadd(_aLinhaNF, SD1->D1_UM     )    // "U.M."               
			Aadd(_aLinhaNF, U_ROMS025I(SD1->D1_QTSEGUM,"@E 999,999,999.999"))       // "Qtde 2a U.M."  
            Aadd(_aLinhaNF, SD1->D1_SEGUM  )    // "2a U.M."         
            Aadd(_aLinhaNF, U_ROMS025I(SD1->D1_VUNIT,"@E 999,999,999.999"))         // "Vlr.Uni."        
            Aadd(_aLinhaNF, U_ROMS025I(SD1->D1_TOTAL,"@E 999,999,999.999"))         // "Valor Total"     

            Aadd(_aLinhaNF, SD1->D1_NFORI  )    // "NF.Origem"       
            Aadd(_aLinhaNF, SD1->D1_SERIORI)    // "Serie Origem"  
            
            For i := 1 to Len(_aDadosRAD)
               AADD(_aLinhaNF,_aDadosRAD[i])
            Next

            Aadd(_aRet, AClone(_aLinhaNF))
                        
            SD1->(DbSkip())
         EndDo
      Else
         _aLinhaNF := {}
         For _nI := 1 To Len(_aDadosR)
             Aadd(_aLinhaNF, _aDadosR[_nI])
         Next
         
         //SE1->(DbSetOrder(31)) // 31 - V - E1_FILIAL+E1_NUM+E1_SERIE+E1_CLIENTE+E1_LOJA    
         SE1->(DbSetOrder(2)) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO    
         
         If SE1->(DbSeek(U_ItKey(_cFilialNF,"E1_FILIAL")+U_ItKey(_cCodCli,"E1_CLIENTE")+U_ItKey(_cLojaCli,"E1_LOJA")+U_ItKey("DCT","E1_PREFIXO")+U_ItKey(_cNRNF,"E1_NUM")  ))
            Do While ! SE1->(Eof()) .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == U_ItKey(_cFilialNF,"E1_FILIAL")+U_ItKey(_cCodCli,"E1_CLIENTE")+U_ItKey(_cLojaCli,"E1_LOJA")+U_ItKey("DCT","E1_PREFIXO")+U_ItKey(_cNRNF,"E1_NUM")
               If AllTrim(SE1->E1_TIPO) == "NCC" .And. AllTrim(SE1->E1_PREFIXO) == "DCT"
                  _aLinhaNF[2] := "DCT"
                  Exit
               EndIf
               
               SE1->(DbSkip())
            EndDo
         EndIf

         If ValType(_aLinhaNF[12]) == "N"
            _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                    // 12   Valor total do item.	
	     EndIf
		 If ValType(_aLinhaNF[13]) == "N"
			_aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                    // 13   Compensa��o  
		 EndIf	
		 If ValType(_aLinhaNF[14]) == "N"
			_aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                    // 14   Desconto do item.							
		 EndIf
		 If ValType(_aLinhaNF[15]) == "N"
			_aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                    // 15   
		 EndIf
		 If ValType(_aLinhaNF[16]) == "N"
			_aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")                    // 16   
		 EndIf	
		 If Len(_aLinhaNF) >= 25 .And. ValType(_aLinhaNF[25]) == "N"
			_aLinhaNF[25] := U_ROMS025I(_aLinhaNF[25],"@E 999,999,999.999")                    // 25   
	     EndIf		
		 If Len(_aLinhaNF) >= 26 .And. ValType(_aLinhaNF[26]) == "N"
			_aLinhaNF[26] := U_ROMS025I(_aLinhaNF[26],"@E 999,999,999.999")                    // 26   
	     EndIf		
		 If Len(_aLinhaNF) >= 27 .And. ValType(_aLinhaNF[27]) == "N"
			_aLinhaNF[27] := U_ROMS025I(_aLinhaNF[27],"@E 999,999,999.999")                    // 27  
		 EndIf	
		 If Len(_aLinhaNF) >= 28 .And. ValType(_aLinhaNF[28]) == "N"
			_aLinhaNF[28] := U_ROMS025I(_aLinhaNF[28],"@E 999,999,999.999")                    // 28   
		 EndIf	
		 If Len(_aLinhaNF) >= 30 .And. ValType(_aLinhaNF[30]) == "N"
			_aLinhaNF[30] := U_ROMS025I(_aLinhaNF[30],"@E 999,999,999.999")                    // 30   
		 EndIf	
		 If Len(_aLinhaNF) >= 31 .And. ValType(_aLinhaNF[31]) == "N"
			_aLinhaNF[31] := U_ROMS025I(_aLinhaNF[31],"@E 999,999,999.999")                    // 31   
		 EndIf	
		 If Len(_aLinhaNF) >= 32 .And. ValType(_aLinhaNF[32]) == "N"
			_aLinhaNF[32] := U_ROMS025I(_aLinhaNF[32],"@E 999,999,999.999")                    // 32   
		 EndIf 	
		 If Len(_aLinhaNF) >= 33 .And. ValType(_aLinhaNF[33]) == "N"
			_aLinhaNF[33] := U_ROMS025I(_aLinhaNF[33],"@E 999,999,999.999")                    // 33   
		 EndIf 
		 If Len(_aLinhaNF) >= 34 .And. ValType(_aLinhaNF[34]) == "N"
			_aLinhaNF[34] := U_ROMS025I(_aLinhaNF[34],"@E 999,999,999.999")                    // 34   
		 EndIf 
		 If Len(_aLinhaNF) >= 35 .And. ValType(_aLinhaNF[35]) == "N"
			_aLinhaNF[35] := U_ROMS025I(_aLinhaNF[35],"@E 999,999,999.999")                    // 35   
		 EndIf 
		 If Len(_aLinhaNF) >= 36 .And. ValType(_aLinhaNF[36]) == "N"
			_aLinhaNF[36] := U_ROMS025I(_aLinhaNF[36],"@E 999,999,999.999")                    // 36   
		 EndIf 
		 If Len(_aLinhaNF) >= 37 .And. ValType(_aLinhaNF[37]) == "N"
			_aLinhaNF[37] := U_ROMS025I(_aLinhaNF[37],"@E 999,999,999.999")                    // 37   
		 EndIf 
		 If Len(_aLinhaNF) >= 38 .And. ValType(_aLinhaNF[38]) == "N"
			_aLinhaNF[38] := U_ROMS025I(_aLinhaNF[38],"@E 999,999,999.999")                    // 38   
		 EndIf 
		 If Len(_aLinhaNF) >= 39 .And. ValType(_aLinhaNF[39]) == "N"
			_aLinhaNF[39] := U_ROMS025I(_aLinhaNF[39],"@E 999,999,999.999")                    // 39   
		 EndIf
         If Len(_aLinhaNF) >= 40 .And. ValType(_aLinhaNF[40]) == "N"
			_aLinhaNF[40] := U_ROMS025I(_aLinhaNF[40],"@E 999,999,999.999")                    // 40   
		 EndIf

         If Len(_aLinhaNF) >= 41 .And. ValType(_aLinhaNF[41]) == "N"
			_aLinhaNF[41] := U_ROMS025I(_aLinhaNF[41],"@E 999,999,999.999")                    // 41   
		 EndIf

		 If Len(_aLinhaNF) >= 42 .And. ValType(_aLinhaNF[42]) == "N"
			_aLinhaNF[42] := U_ROMS025I(_aLinhaNF[42],"@E 999,999,999.999")                    // 42   
		 EndIf

		 If Len(_aLinhaNF) >= 43 .And. ValType(_aLinhaNF[43]) == "N"
			_aLinhaNF[43] := U_ROMS025I(_aLinhaNF[43],"@E 999,999,999.999")                    // 43   
		 EndIf

		 If Len(_aLinhaNF) >= 44 .And. ValType(_aLinhaNF[44]) == "N"
			_aLinhaNF[44] := U_ROMS025I(_aLinhaNF[44],"@E 999,999,999.999")                    // 44   
		 EndIf

		 If Len(_aLinhaNF) >= 45 .And. ValType(_aLinhaNF[45]) == "N"
			_aLinhaNF[45] := U_ROMS025I(_aLinhaNF[45],"@E 999,999,999.999")                    // 45   
		 EndIf

		 If Len(_aLinhaNF) >= 46 .And. ValType(_aLinhaNF[46]) == "N"
			_aLinhaNF[46] := U_ROMS025I(_aLinhaNF[46],"@E 999,999,999.999")                    // 46   
		 EndIf

         For i := 1 to Len(_aDadosRAD)
            AADD(_aLinhaNF,_aDadosRAD[i])
         Next
		 
       Aadd(_aLinhaNF, "" )    // Mix BI
         Aadd(_aLinhaNF, "" )    // "Item"           
         Aadd(_aLinhaNF, "" )    // "Produto"           
         Aadd(_aLinhaNF, "" )    // "Descri��o"        
         Aadd(_aLinhaNF, U_ROMS025I(0 ,"@E 999,999,999.99"))    // "Aliq.%"           
         Aadd(_aLinhaNF, U_ROMS025I(0 ,"@E 999,999,999.99"))    // "Qtde"             
         Aadd(_aLinhaNF, "" )    // "U.M."               
         Aadd(_aLinhaNF, U_ROMS025I(0 ,"@E 999,999,999.99"))    // "Qtde 2a U.M."  
         Aadd(_aLinhaNF, "" )    // "2a U.M."         
         Aadd(_aLinhaNF, U_ROMS025I(0 ,"@E 999,999,999.99"))    // "Vlr.Uni."        
         Aadd(_aLinhaNF, U_ROMS025I(0 ,"@E 999,999,999.99"))    // "Valor Total"     
         Aadd(_aLinhaNF, "" )    // "NF.Origem"       
         Aadd(_aLinhaNF, "" )    // "Serie Origem"  


         
         Aadd(_aRet, AClone(_aLinhaNF))
             
      EndIf

      Break
   EndIf   

   //==========================================================================
   //  Nota fiscal de venda.
   //==========================================================================
   If AllTrim(_cTipoDoc) <> "NCC" // Venda
      _nValTotMerc := 1 // Inicializado com um para divis�o.
     
      _nRegSF2 := SF2->(Recno())
       
      SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
      If SF2->(DbSeek(U_ItKey(_cFilialNF,"D2_FILIAL")+U_ItKey(_cNRNF,"D2_DOC")+U_ItKey(_cSerieNf,"D2_SERIE")+U_ItKey(_cCodCli,"D2_CLIENTE")+U_ItKey(_cLojaCli,"D2_LOJA")))
         _nValTotMerc := SF2->F2_VALMERC
      EndIf
      
      SF2->(DbGoTo(_nRegSF2))
       
	  _nTotNF := _nValTotMerc //SF2->F2_VALMERC 

      _nFatorBas := _aDadosR[16] / _nTotNF

      SD2->(DbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
      If SD2->(DbSeek(U_ItKey(_cFilialNF,"D2_FILIAL")+U_ItKey(_cNRNF,"D2_DOC")+U_ItKey(_cSerieNf,"D2_SERIE")+U_ItKey(_cCodCli,"D2_CLIENTE")+U_ItKey(_cLojaCli,"D2_LOJA")))
         Do While ! SD2->(Eof()) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == U_ItKey(_cFilialNF,"D2_FILIAL")+U_ItKey(_cNRNF,"D2_DOC")+U_ItKey(_cSerieNf,"D2_SERIE")+U_ItKey(_cCodCli,"D2_CLIENTE")+U_ItKey(_cLojaCli,"D2_LOJA")
            _aLinhaNF := {}
            For _nI := 1 To Len(_aDadosR)
                Aadd(_aLinhaNF, _aDadosR[_nI])
            Next

            If AllTrim(_cTipoDoc ) == "BON"
               _aLinhaNF[02] := "BON"
            EndIf
            
            //_nComisItem := (SD2->D2_TOTAL * SD2->D2_COMIS1 * _nFatorBas) / 100

			_nPercItem := SD2->D2_TOTAL / _nTotNF 
            
            _nMedSisVd := (SD2->D2_TOTAL * SD2->D2_COMIS1 * _nFatorBas) / 100
			_nMedSisSp := (SD2->D2_TOTAL * SD2->D2_COMIS4 * _nFatorBas) / 100
			_nMedSisCo := (SD2->D2_TOTAL * SD2->D2_COMIS2 * _nFatorBas) / 100
			_nMedSisGe := (SD2->D2_TOTAL * SD2->D2_COMIS3 * _nFatorBas) / 100 
            _nMedSisGN := (SD2->D2_TOTAL * SD2->D2_COMIS5 * _nFatorBas) / 100 
            _nPerSisVd := (_nMedSisVd / SD2->D2_TOTAL / _nFatorBas) * 100
			_nPerSisSp := (_nMedSisSp / SD2->D2_TOTAL / _nFatorBas) * 100
			_nPerSisCo := (_nMedSisCo / SD2->D2_TOTAL / _nFatorBas) * 100
			_nPerSisGe := (_nMedSisGe / SD2->D2_TOTAL / _nFatorBas) * 100
            _nPerSisGN := (_nMedSisGN / SD2->D2_TOTAL / _nFatorBas) * 100

            If Empty(MV_PAR07) .Or. ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07) // Imprime todos os dados // 1
               _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                    // 12   SD2->D2_TOTAL  =  Valor total do item.	
			      _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem            // 13   ( (_cAlias)->COMPENSACA * (SD2->D2_TOTAL/_nValTotMerc)
			      _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem             // 14   SD2->D2_DESC    = Desconto do item.							
			      _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem             // 15   ( (_cAlias)->BAIXASANT * (SD2->D2_TOTAL/_nValTotMerc)
               If AllTrim(_aLinhaNF[02]) == "BON"
			         _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                 // * -1 //_nbasecomis * _nPercItem * -1                                // 16   Bonifica��o n�o gera comiss�o. O Valor � negativo.  
			      Else
			         _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                 // _nbasecomis * _nPercItem                                     // 16   ( _nbasecomis * (SD2->D2_TOTAL/(_cAlias)->VLRTITULO))
			      EndIf

			   _aLinhaNF[27] := _aLinhaNF[16] * (SD2->D2_COMIS1 / 100)        // 25-->27   Percentual comiss�o 1 - Vendedor
			   _aLinhaNF[28] := SD2->D2_COMIS1                                // 26-->28   comiss�o 1 - Vendedor 

               _aLinhaNF[29] := _nPerSisVd                                    // "% Com Nota Rep"          27-->29
 			   _aLinhaNF[30] := _nMedSisVd                                    // "Media % Sistemica Rep"   28-->30

			   _aLinhaNF[31] := _aLinhaNF[16] * (SD2->D2_COMIS4 / 100)        // "Vlr Com Sup"             29-->31 
			   _aLinhaNF[32] := SD2->D2_COMIS4	                              // "% Com Sup"	           30-->32 
			   
			   _aLinhaNF[33] := _nPerSisSp                                    // "% Com Nota Sup"          31-->33
			   _aLinhaNF[34] := _nMedSisSp                                    // "Media % Sistemica Sup"   32-->34 

			   _aLinhaNF[35] := _aLinhaNF[16] * (SD2->D2_COMIS2 / 100)		  // "Vlr Com Cood"            33-->35
			   _aLinhaNF[36] := SD2->D2_COMIS2	                              // "% Com Cood"	           34-->36 

               _aLinhaNF[37] := _nPerSisCo                                    // "% Com Nota Coord         35-->37
			   _aLinhaNF[38] := _nMedSisCo                                    // "Media % Sistemica Coord  36-->38  

			   _aLinhaNF[39] := _aLinhaNF[16]  * (SD2->D2_COMIS3 / 100)	      // "Vlr Com Ger"             37-->39
			   _aLinhaNF[40] := SD2->D2_COMIS3                                // "% Com Ger"	           38-->40

			   _aLinhaNF[41] := _nPerSisGe                                    // "% Com Nota Ger"          39-->41
			   _aLinhaNF[42] := _nMedSisGe                                    // "Media % Sistemica Ger"   40-->42

               _aLinhaNF[43] := _aLinhaNF[16]  * (SD2->D2_COMIS5 / 100)	      // "Vlr Com Ger Nac"
			   _aLinhaNF[44] := SD2->D2_COMIS5                                // "% Com Ger Nac"

			   _aLinhaNF[45] := _nPerSisGN                                    // "% Com Nota Ger Nac"
			   _aLinhaNF[46] := _nMedSisGN                                    // "Media % Sistemica Ger Nac"

			   //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
			   _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999") // 12   SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999") // 13   ( (_cAlias)->COMPENSACA * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999") // 14   SD2->D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999") // 15   ( (_cAlias)->BAIXASANT * (SD2->D2_TOTAL/_nValTotMerc)
               _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999") // 16   ( _nbasecomis * (SD2->D2_TOTAL/(_cAlias)->VLRTITULO))
			   _aLinhaNF[27] := U_ROMS025I(_aLinhaNF[27],"@E 999,999,999.999") // 25-->27  Percentual comiss�o 1 - Vendedor
			   _aLinhaNF[28] := U_ROMS025I(_aLinhaNF[28],"@E 999,999,999.999") // 26-->28  comiss�o 1 - Vendedor 
               _aLinhaNF[29] := U_ROMS025I(_aLinhaNF[29],"@E 999,999,999.999") // "% Com Nota Rep"           27-->29 
			   _aLinhaNF[30] := U_ROMS025I(_aLinhaNF[30],"@E 999,999,999.999") // "Media % Sistemica Rep"    28-->30
			   _aLinhaNF[31] := U_ROMS025I(_aLinhaNF[31],"@E 999,999,999.999") // "Vlr Com Sup"              29-->31 
			   _aLinhaNF[32] := U_ROMS025I(_aLinhaNF[32],"@E 999,999,999.999") // "% Com Sup"	            30-->32 
			   _aLinhaNF[33] := U_ROMS025I(_aLinhaNF[33],"@E 999,999,999.999") // "% Com Nota Sup"           31-->33 
			   _aLinhaNF[34] := U_ROMS025I(_aLinhaNF[34],"@E 999,999,999.999") // "Media % Sistemica Sup"    32-->34
			   _aLinhaNF[35] := U_ROMS025I(_aLinhaNF[35],"@E 999,999,999.999") // "Vlr Com Cood"             33-->35
			   _aLinhaNF[36] := U_ROMS025I(_aLinhaNF[36],"@E 999,999,999.999") // "% Com Cood"	            34-->36 
               _aLinhaNF[37] := U_ROMS025I(_aLinhaNF[37],"@E 999,999,999.999") // "% Com Nota Coord"         35-->37
			   _aLinhaNF[38] := U_ROMS025I(_aLinhaNF[38],"@E 999,999,999.999") // "Media % Sistemica Coord   36-->38
			   _aLinhaNF[39] := U_ROMS025I(_aLinhaNF[39],"@E 999,999,999.999") // "Vlr Com Ger"              37-->39 
			   _aLinhaNF[40] := U_ROMS025I(_aLinhaNF[40],"@E 999,999,999.999") // "% Com Ger"	            38-->40 
			   _aLinhaNF[41] := U_ROMS025I(_aLinhaNF[41],"@E 999,999,999.999") // "% Com Nota Ger"           39-->41 
			   _aLinhaNF[42] := U_ROMS025I(_aLinhaNF[42],"@E 999,999,999.999") // "Media % Sistemica Ger"    40-->42 
               _aLinhaNF[43] := U_ROMS025I(_aLinhaNF[43],"@E 999,999,999.999") // "Vlr Com Ger Nac"             
			   _aLinhaNF[44] := U_ROMS025I(_aLinhaNF[44],"@E 999,999,999.999") // "% Com Ger Nac"		       
               _aLinhaNF[45] := U_ROMS025I(_aLinhaNF[45],"@E 999,999,999.999") // "% Com Nota Ger Nac"          
               _aLinhaNF[46] := U_ROMS025I(_aLinhaNF[46],"@E 999,999,999.999") // "Media % Sistemica Ger Nac"   

            ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07 //  N�o imprime vendedor     // 2
               _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                   // 12  SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem           // 13  ( (_cAlias)->COMPENSACA * (SD2->D2_TOTAL/(_cAlias)->VLRTITULO)) 
			   _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem            // 14  SD2->D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem            // 15  ( (_cAlias)->BAIXASANT * (SD2->D2_TOTAL/_nValTotMerc)
			   
			   If AllTrim(_aLinhaNF[02]) == "BON"
			      _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                //* -1 // _nbasecomis * _nPercItem * -1                                // 16   Bonifica��o n�o gera comiss�o. O Valor � negativo.  
			   Else
			      _aLinhaNF[16]	:= _aLinhaNF[16] * _nPercItem                // _nbasecomis * _nPercItem                                     // 16  ( _nbasecomis * (SD2->D2_TOTAL/_nValTotMerc)
			   EndIf

			   _aLinhaNF[25] := _aLinhaNF[16] * (SD2->D2_COMIS4 / 100)       // 23-->25  Percentual comiss�o Supervidor
			   _aLinhaNF[26] := SD2->D2_COMIS4                               // 24-->26  comiss�o  - Supervidor

               _aLinhaNF[27] := _nPerSisSp                                   // "% Com Nota Sup"           25-->27 
               _aLinhaNF[28] := _nMedSisSp                                   // "Media % Sistemica Sup"    26-->28 

			   _aLinhaNF[29] := _aLinhaNF[16] * (SD2->D2_COMIS2 / 100)       // "Vlr Com Cood"             27-->29
			   _aLinhaNF[30] := SD2->D2_COMIS2                               // "% Com Cood"               28-->30

			   _aLinhaNF[31] := _nPerSisCo                                   // "% Com Nota Coord"         29-->31
               _aLinhaNF[32] := _nMedSisCo                                   // "Media % Sistemica Coord"  30-->32

			   _aLinhaNF[33] := _aLinhaNF[16] * (SD2->D2_COMIS3 / 100)       // "Vlr Com Ger"              31-->33
			   _aLinhaNF[34] := SD2->D2_COMIS3                               // "% Com Ger"	               32-->34

			   _aLinhaNF[35] := _nPerSisGe                                   // "% Com Nota Ger"           33-->35 
               _aLinhaNF[36] := _nMedSisGe                                   // "Media % Sistemica Ger"    34-->36

               _aLinhaNF[37] := _aLinhaNF[16]  * (SD2->D2_COMIS5 / 100)	      // "Vlr Com Ger Nac"
			   _aLinhaNF[38] := SD2->D2_COMIS5                                // "% Com Ger Nac"

			   _aLinhaNF[39] := _nPerSisGN                                    // "% Com Nota Ger Nac"
			   _aLinhaNF[40] := _nMedSisGN                                    // "Media % Sistemica Ger Nac"

			   //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
               _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")	   // 12  SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")	   // 13  ( (_cAlias)->COMPENSACA * (SD2->D2_TOTAL/(_cAlias)->VLRTITULO)) 
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")	   // 14  SD2->D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")	   // 15  ( (_cAlias)->BAIXASANT * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")	   // 16  ( _nbasecomis * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[25] := U_ROMS025I(_aLinhaNF[25],"@E 999,999,999.999")	   // 23-->25  Percentual comiss�o Supervidor
			   _aLinhaNF[26] := U_ROMS025I(_aLinhaNF[26],"@E 999,999,999.999")	   // 24-->26  Comiss�o Supervidor
               _aLinhaNF[27] := U_ROMS025I(_aLinhaNF[27],"@E 999,999,999.999")      // "% Com Nota Sup"           25-->27 
               _aLinhaNF[28] := U_ROMS025I(_aLinhaNF[28],"@E 999,999,999.999")      // "Media % Sistemica Sup"    26-->28  
			   _aLinhaNF[29] := U_ROMS025I(_aLinhaNF[29],"@E 999,999,999.999")      // "Vlr Com Cood"             27-->29 
			   _aLinhaNF[30] := U_ROMS025I(_aLinhaNF[30],"@E 999,999,999.999")      // "% Com Cood"               28-->30 
			   _aLinhaNF[31] := U_ROMS025I(_aLinhaNF[31],"@E 999,999,999.999")      // "% Com Nota Coord"         29-->31 
               _aLinhaNF[32] := U_ROMS025I(_aLinhaNF[32],"@E 999,999,999.999")      // "Media % Sistemica Coord"  30-->32
			   _aLinhaNF[33] := U_ROMS025I(_aLinhaNF[33],"@E 999,999,999.999")      // "Vlr Com Ger"              31-->33
			   _aLinhaNF[34] := U_ROMS025I(_aLinhaNF[34],"@E 999,999,999.999")      // "% Com Ger"	             32-->34
			   _aLinhaNF[35] := U_ROMS025I(_aLinhaNF[35],"@E 999,999,999.999")      // "% Com Nota Ger"           33-->35
               _aLinhaNF[36] := U_ROMS025I(_aLinhaNF[36],"@E 999,999,999.999")      // "Media % Sistemica Ger"    34-->36 
               _aLinhaNF[37] := U_ROMS025I(_aLinhaNF[37],"@E 999,999,999.999")      // "Vlr Com Ger Nac"             
			   _aLinhaNF[38] := U_ROMS025I(_aLinhaNF[38],"@E 999,999,999.999")      // "% Com Ger Nac"		       
               _aLinhaNF[39] := U_ROMS025I(_aLinhaNF[39],"@E 999,999,999.999")      // "% Com Nota Ger Nac"          
               _aLinhaNF[40] := U_ROMS025I(_aLinhaNF[40],"@E 999,999,999.999")      // "Media % Sistemica Ger Nac"  

            ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime supervisor  // 3
               _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                                      // 12  SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem                              // 13   ( (_cAlias)->COMPENSACA * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem                               // 14 D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem                               // 15 ( (_cAlias)->BAIXASANT * (SD2->D2_TOTAL/_nValTotMerc) 
			   
			   If AllTrim(_aLinhaNF[02]) == "BON"
			      _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem //* -1 // _nbasecomis * _nPercItem * -1                                // 16   Bonifica��o n�o gera comiss�o.  
			   Else
			      _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem      // _nbasecomis * _nPercItem                  	                // 16 ( _nbasecomis * (SD2->D2_TOTAL/_nValTotMerc)
			   EndIf

			   _aLinhaNF[25] := _aLinhaNF[16] * (SD2->D2_COMIS1 / 100) 	  // 23-->25 Percentual comiss�o Vendedor
			   _aLinhaNF[26] := SD2->D2_COMIS1	                          // 24-->26 comiss�o Vendedor
               _aLinhaNF[27] := _nPerSisVd                                // "% Com Nota Rep"            25-->27  
               _aLinhaNF[28] := _nMedSisVd                                // "Media % Sistemica Rep"     26-->28 

			   _aLinhaNF[29] := _aLinhaNF[16] * (SD2->D2_COMIS2 / 100)	  // "Vlr Com Cood"              27-->29 
			   _aLinhaNF[30] := SD2->D2_COMIS2	                          // "% Com Cood"	             28-->30 
               _aLinhaNF[31] := _nPerSisCo                                // "% Com Nota Coord"          29-->31 
               _aLinhaNF[32] := _nMedSisCo                                // "Media % Sistemica Coord"   30-->32 

			   _aLinhaNF[33] := _aLinhaNF[16] * (SD2->D2_COMIS3 / 100)    // "Vlr Com Ger"                31-->33
			   _aLinhaNF[34] :=	SD2->D2_COMIS3                            // "% Com Ger"	              32-->34
               _aLinhaNF[35] := _nMedSisGe                                // "% Com Nota Ger"             33-->35
               _aLinhaNF[36] := _nPerSisGe                                // "Media % Sistemica Ger"      34-->36

               _aLinhaNF[37] := _aLinhaNF[16]  * (SD2->D2_COMIS5 / 100)	      // "Vlr Com Ger Nac"
			   _aLinhaNF[38] := SD2->D2_COMIS5                                // "% Com Ger Nac"

			   _aLinhaNF[39] := _nPerSisGN                                    // "% Com Nota Ger Nac"
			   _aLinhaNF[40] := _nMedSisGN                                    // "Media % Sistemica Ger Nac" 

               //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
         	   _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")     // 12  SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")     // 13   ( (_cAlias)->COMPENSACA * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999") 	 // 14 D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999") 	 // 15 ( (_cAlias)->BAIXASANT * (SD2->D2_TOTAL/_nValTotMerc) 
		       _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999") 	 // 16 ( _nbasecomis * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[25] := U_ROMS025I(_aLinhaNF[25],"@E 999,999,999.999") 	 // 23-->25 Percentual comiss�o Vendedor
			   _aLinhaNF[26] := U_ROMS025I(_aLinhaNF[26],"@E 999,999,999.999")    // 24-->26 comiss�o Vendedor
			   
			   _aLinhaNF[27] := U_ROMS025I(_aLinhaNF[27],"@E 999,999,999.999")    // "% Com Nota Rep"           25-->27  
               _aLinhaNF[28] := U_ROMS025I(_aLinhaNF[28],"@E 999,999,999.999")    // "Media % Sistemica Rep"    26-->28 
			   _aLinhaNF[29] := U_ROMS025I(_aLinhaNF[29],"@E 999,999,999.999")    // "Vlr Com Cood"             27-->29 
			   _aLinhaNF[30] := U_ROMS025I(_aLinhaNF[30],"@E 999,999,999.999") 	 // "% Com Cood"	           28-->30 
               _aLinhaNF[31] := U_ROMS025I(_aLinhaNF[31],"@E 999,999,999.999")    // "% Com Nota Coord"         29-->31
               _aLinhaNF[32] := U_ROMS025I(_aLinhaNF[32],"@E 999,999,999.999")    // "Media % Sistemica Coord"  30-->32
			   _aLinhaNF[33] := U_ROMS025I(_aLinhaNF[33],"@E 999,999,999.999")    // "Vlr Com Ger"              31-->33
			   _aLinhaNF[34] :=	U_ROMS025I(_aLinhaNF[34],"@E 999,999,999.999")    // "% Com Ger"	               32-->34
               _aLinhaNF[35] := U_ROMS025I(_aLinhaNF[35],"@E 999,999,999.999")    // "% Com Nota Ger"           33-->35
               _aLinhaNF[36] := U_ROMS025I(_aLinhaNF[36],"@E 999,999,999.999")    // "Media % Sistemica Ger"    34-->36
               _aLinhaNF[37] := U_ROMS025I(_aLinhaNF[37],"@E 999,999,999.999")    // "Vlr Com Ger Nac"             
			   _aLinhaNF[38] := U_ROMS025I(_aLinhaNF[38],"@E 999,999,999.999")    // "% Com Ger Nac"		       
               _aLinhaNF[39] := U_ROMS025I(_aLinhaNF[39],"@E 999,999,999.999")    // "% Com Nota Ger Nac"          
               _aLinhaNF[40] := U_ROMS025I(_aLinhaNF[40],"@E 999,999,999.999")    // "Media % Sistemica Ger Nac"  

            ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime Coordenador  // 4 
			   _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                  // 12  SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem          // 13  ( (_cAlias)->COMPENSACA * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem           // 14  SD2->D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem           // 15  ( (_cAlias)->BAIXASANT * (SD2->D2_TOTAL/_nValTotMerc) 
			   
			   If AllTrim(_aLinhaNF[02]) == "BON"
			      _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem //* -1        // _nbasecomis * _nPercItem * -1                                // 16   Bonifica��o n�o gera comiss�o. O valor deve ser negativo. 
			   Else
			      _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem               // _nbasecomis * _nPercItem                                     // 16  ( _nbasecomis * (SD2->D2_TOTAL/_nValTotMerc)
			   EndIf

			   _aLinhaNF[25] := _aLinhaNF[16] * _nPercItem                  // 23-->25 Percentual comiss�o Vendedor
			   _aLinhaNF[26] := SD2->D2_COMIS1                              // 24-->26 Comiss�o Vendedor
			   _aLinhaNF[27] := _nPerSisVd                                  // "% Com Nota Rep"           25-->27
               _aLinhaNF[28] := _nMedSisVd                                  // "Media % Sistemica Rep"    26-->28 
			   _aLinhaNF[29] := _aLinhaNF[16] * _nPercItem                  // "Vlr Com Sup"              27-->29 
			   _aLinhaNF[30] := SD2->D2_COMIS4                              // "% Com Sup"	              28-->30 
			   _aLinhaNF[31] := _nPerSisSp                                  // "% Com Nota Sup",;         29-->31
               _aLinhaNF[32] := _nMedSisSp                                  // "Media % Sistemica Sup"    30-->32
			   _aLinhaNF[33] := _aLinhaNF[16] * _nPercItem                  // "Vlr Com Ger"              31-->33
			   _aLinhaNF[34] := SD2->D2_COMIS3                              // "% Com Ger"	              32-->34
			   _aLinhaNF[35] := _nPerSisGe                                  // "% Com Nota Ger",;         33-->35
               _aLinhaNF[36] := _nMedSisGe                                  // "Media % Sistemica Ger",;  34-->36
               _aLinhaNF[37] := _aLinhaNF[16]  * (SD2->D2_COMIS5 / 100)	    // "Vlr Com Ger Nac"
			   _aLinhaNF[38] := SD2->D2_COMIS5                              // "% Com Ger Nac"

			   _aLinhaNF[39] := _nPerSisGN                                  // "% Com Nota Ger Nac"
			   _aLinhaNF[40] := _nMedSisGN                                  // "Media % Sistemica Ger Nac" 

			   //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
			   _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                    // 12  SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                    // 13  ( (_cAlias)->COMPENSACA * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                    // 14  SD2->D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                    // 15  ( (_cAlias)->BAIXASANT * (SD2->D2_TOTAL/_nValTotMerc) 
               _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")                    // 16  ( _nbasecomis * (SD2->D2_TOTAL/_nValTotMerc)

			   _aLinhaNF[25] := U_ROMS025I(_aLinhaNF[25],"@E 999,999,999.999")                    // 23-->25  Percentual comiss�o Vendedor
			   _aLinhaNF[26] := U_ROMS025I(_aLinhaNF[26],"@E 999,999,999.999")                    // 24-->26  Comiss�o Vendedor

			   _aLinhaNF[27] := U_ROMS025I(_aLinhaNF[27],"@E 999,999,999.999")                    // "% Com Nota Rep"           25-->27
               _aLinhaNF[28] := U_ROMS025I(_aLinhaNF[28],"@E 999,999,999.999")                    // "Media % Sistemica Rep"    26-->28
			   _aLinhaNF[29] := U_ROMS025I(_aLinhaNF[29],"@E 999,999,999.999")                    // "Vlr Com Sup"	           27-->29
			   _aLinhaNF[30] := U_ROMS025I(_aLinhaNF[30],"@E 999,999,999.999")                    // "% Com Sup"	               28-->30
			   _aLinhaNF[31] := U_ROMS025I(_aLinhaNF[31],"@E 999,999,999.999")                    // "% Com Nota Sup",;         29-->31
               _aLinhaNF[32] := U_ROMS025I(_aLinhaNF[32],"@E 999,999,999.999")                    // "Media % Sistemica Sup"    30-->32 
			   _aLinhaNF[33] := U_ROMS025I(_aLinhaNF[33],"@E 999,999,999.999")                    // "Vlr Com Ger"              31-->33
			   _aLinhaNF[34] := U_ROMS025I(_aLinhaNF[34],"@E 999,999,999.999")                    // "% Com Ger"	               32-->34
			   _aLinhaNF[35] := U_ROMS025I(_aLinhaNF[35],"@E 999,999,999.999")                    // "% Com Nota Ger"           33-->35
               _aLinhaNF[36] := U_ROMS025I(_aLinhaNF[36],"@E 999,999,999.999")                    // "Media % Sistemica Ger"    34-->36 

               _aLinhaNF[37] := U_ROMS025I(_aLinhaNF[37],"@E 999,999,999.999")    // "Vlr Com Ger Nac"             
			   _aLinhaNF[38] := U_ROMS025I(_aLinhaNF[38],"@E 999,999,999.999")    // "% Com Ger Nac"		       
               _aLinhaNF[39] := U_ROMS025I(_aLinhaNF[39],"@E 999,999,999.999")    // "% Com Nota Ger Nac"          
               _aLinhaNF[40] := U_ROMS025I(_aLinhaNF[40],"@E 999,999,999.999")    // "Media % Sistemica Ger Nac"  

            ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07  .And. "N" $ MV_PAR07 // N�o imprime gerente  // 5 
               _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                                      // 12  SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem                              // 13  ( (_cAlias)->COMPENSACA * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem                               // 14  SD2->D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem                               // 15 ((_cAlias)->BAIXASANT * (SD2->D2_TOTAL/_nValTotMerc)

			   If AllTrim(_aLinhaNF[02]) == "BON"
			      _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem //* -1 // _nbasecomis * _nPercItem * -1                                // 16   Bonifica��o n�o gera comiss�o. O valor deve ser negativo.  
			   Else
			      _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem // _nbasecomis * _nPercItem                                     // 16 ( _nbasecomis * (SD2->D2_TOTAL/_nValTotMerc)
			   EndIf

			   _aLinhaNF[25] := _aLinhaNF[16]  * (SD2->D2_COMIS1 / 100)                         // 23-->25 Percentual comiss�o Vendedor
			   _aLinhaNF[26] := SD2->D2_COMIS1                                                  // 24-->26 Comiss�o Vendedor

               _aLinhaNF[27] :=  _nPerSisVd                                                     // "% Com Nota Rep"          25-->27
               _aLinhaNF[28] :=  _nMedSisVd                                                     // "Media % Sistemica Rep"   26-->28

			   _aLinhaNF[29] := _aLinhaNF[16] * (SD2->D2_COMIS4 / 100)                          // "Vlr Com Sup"             27-->29
			   _aLinhaNF[30] := SD2->D2_COMIS4                                                  // "% Com Sup"	             28-->30
            
			   _aLinhaNF[31] := _nPerSisSp                                                      // "% Com Nota Sup"          29-->31
               _aLinhaNF[32] := _nMedSisSp                                                      // "Media % Sistemica Sup"   30-->32

			   _aLinhaNF[33] := _aLinhaNF[16] * (SD2->D2_COMIS2 / 100)                          // "Vlr Com Cood"            31-->33
			   _aLinhaNF[34] := SD2->D2_COMIS2                                                  // "% Com Cood"	             32-->34

               _aLinhaNF[35] :=  _nPerSisCo                                                     // "% Com Nota Coord"        33-->35 
               _aLinhaNF[36] :=  _nMedSisCo                                                     // "Media % Sistemica Coord" 34-->36 

               _aLinhaNF[37] := _aLinhaNF[16]  * (SD2->D2_COMIS5 / 100)	                        // "Vlr Com Ger Nac"
			   _aLinhaNF[38] := SD2->D2_COMIS5                                                  // "% Com Ger Nac"

			   _aLinhaNF[39] := _nPerSisGN                                                      // "% Com Nota Ger Nac"
			   _aLinhaNF[40] := _nMedSisGN                                                      // "Media % Sistemica Ger Nac" 

			   //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
			   _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                   // 12  SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                   // 13  ( (_cAlias)->COMPENSACA * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                   // 14  SD2->D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                   // 15 ((_cAlias)->BAIXASANT * (SD2->D2_TOTAL/_nValTotMerc)
		       _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")                   // 16 ( _nbasecomis * (SD2->D2_TOTAL/_nValTotMerc)

			   _aLinhaNF[25] := U_ROMS025I(_aLinhaNF[25],"@E 999,999,999.999")                   // 23-->25 Percentual comiss�oVendedor
			   _aLinhaNF[26] := U_ROMS025I(_aLinhaNF[26],"@E 999,999,999.999")                   // 24-->26 comiss�o Vendedor

               _aLinhaNF[27] := U_ROMS025I(_aLinhaNF[27],"@E 999,999,999.999")                   // "% Com Nota Rep"          25-->27
               _aLinhaNF[28] := U_ROMS025I(_aLinhaNF[28],"@E 999,999,999.999")                   // "Media % Sistemica Rep"   26-->28

			   _aLinhaNF[29] := U_ROMS025I(_aLinhaNF[29],"@E 999,999,999.999")                   // "Vlr Com Sup"             27-->29
			   _aLinhaNF[30] := U_ROMS025I(_aLinhaNF[30],"@E 999,999,999.999")                   // "% Com Sup"	             28-->30
            
			   _aLinhaNF[31] := U_ROMS025I(_aLinhaNF[31],"@E 999,999,999.999")                   // "% Com Nota Sup"          29-->31
               _aLinhaNF[32] := U_ROMS025I(_aLinhaNF[32],"@E 999,999,999.999")                   // "Media % Sistemica Sup"   30-->32

			   _aLinhaNF[33] := U_ROMS025I(_aLinhaNF[33],"@E 999,999,999.999")                   // "Vlr Com Cood"            31-->33
			   _aLinhaNF[34] := U_ROMS025I(_aLinhaNF[34],"@E 999,999,999.999")                   // "% Com Cood"	             32-->34

               _aLinhaNF[35] := U_ROMS025I(_aLinhaNF[35],"@E 999,999,999.999")                   // "% Com Nota Coord"        33-->35 
               _aLinhaNF[36] := U_ROMS025I(_aLinhaNF[36],"@E 999,999,999.999")                   // "Media % Sistemica Coord" 34-->36 

               _aLinhaNF[37] := U_ROMS025I(_aLinhaNF[37],"@E 999,999,999.999")                   // "Vlr Com Ger Nac"             
			   _aLinhaNF[38] := U_ROMS025I(_aLinhaNF[38],"@E 999,999,999.999")                   // "% Com Ger Nac"		       
               _aLinhaNF[39] := U_ROMS025I(_aLinhaNF[39],"@E 999,999,999.999")                   // "% Com Nota Ger Nac"          
               _aLinhaNF[40] := U_ROMS025I(_aLinhaNF[40],"@E 999,999,999.999")                   // "Media % Sistemica Ger Nac"  

            ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07  .And. "N" $ MV_PAR07 // N�o imprime gerente nacional
               _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                                      // 12  SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem                              // 13  ( (_cAlias)->COMPENSACA * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem                               // 14  SD2->D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem                               // 15 ((_cAlias)->BAIXASANT * (SD2->D2_TOTAL/_nValTotMerc)

			   If AllTrim(_aLinhaNF[02]) == "BON"
			      _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem //* -1 // _nbasecomis * _nPercItem * -1                                // 16   Bonifica��o n�o gera comiss�o. O valor deve ser negativo.  
			   Else
			      _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem // _nbasecomis * _nPercItem                                     // 16 ( _nbasecomis * (SD2->D2_TOTAL/_nValTotMerc)
			   EndIf

			   _aLinhaNF[25] := _aLinhaNF[16]  * (SD2->D2_COMIS1 / 100)                         // 23-->25 Percentual comiss�o Vendedor
			   _aLinhaNF[26] := SD2->D2_COMIS1                                                  // 24-->26 Comiss�o 1 Vendedor

               _aLinhaNF[27] :=  _nPerSisVd                                                     // "% Com Nota Rep"          25-->27
               _aLinhaNF[28] :=  _nMedSisVd                                                     // "Media % Sistemica Rep"   26-->28

			   _aLinhaNF[29] := _aLinhaNF[16] * (SD2->D2_COMIS4 / 100)                          // "Vlr Com Sup"             27-->29
			   _aLinhaNF[30] := SD2->D2_COMIS4                                                  // "% Com Sup"	             28-->30 
            
			   _aLinhaNF[31] := _nPerSisSp                                                      // "% Com Nota Sup"          29-->31
               _aLinhaNF[32] := _nMedSisSp                                                      // "Media % Sistemica Sup"   30-->32

			   _aLinhaNF[33] := _aLinhaNF[16] * (SD2->D2_COMIS2 / 100)                          // "Vlr Com Cood"            31-->33
			   _aLinhaNF[34] := SD2->D2_COMIS2                                                  // "% Com Cood"	             32-->34

               _aLinhaNF[35] := _nPerSisCo                                                     // "% Com Nota Coord"        33-->35
               _aLinhaNF[36] := _nMedSisCo                                                     // "Media % Sistemica Coord" 34-->36 

               _aLinhaNF[37] := _aLinhaNF[16] * _nPercItem                                      // "Vlr Com Ger"   
			   _aLinhaNF[38] := SD2->D2_COMIS3                                                  // "% Com Ger"	   
			   _aLinhaNF[39] := _nPerSisGe                                                      // "% Com Nota Ger"
               _aLinhaNF[40] := _nMedSisGe                                                      // "Media % Sistemica Ger"

			   //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
			   _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                   // 12  SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                   // 13  ( (_cAlias)->COMPENSACA * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                   // 14  SD2->D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                   // 15 ((_cAlias)->BAIXASANT * (SD2->D2_TOTAL/_nValTotMerc)
		       _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")                   // 16 ( _nbasecomis * (SD2->D2_TOTAL/_nValTotMerc)

			   _aLinhaNF[25] := U_ROMS025I(_aLinhaNF[25],"@E 999,999,999.999")                   // 23-->25  Percentual Comiss�oVendedor
			   _aLinhaNF[26] := U_ROMS025I(_aLinhaNF[26],"@E 999,999,999.999")                   // 24-->26  Comiss�o Vendedor

               _aLinhaNF[27] := U_ROMS025I(_aLinhaNF[27],"@E 999,999,999.999")                   // "% Com Nota Rep"          25-->27
               _aLinhaNF[28] := U_ROMS025I(_aLinhaNF[28],"@E 999,999,999.999")                   // "Media % Sistemica Rep"   26-->28

			   _aLinhaNF[29] := U_ROMS025I(_aLinhaNF[29],"@E 999,999,999.999")                   // "Vlr Com Sup"             27-->29
			   _aLinhaNF[30] := U_ROMS025I(_aLinhaNF[30],"@E 999,999,999.999")                   // "% Com Sup"	             28-->30
            
			   _aLinhaNF[31] := U_ROMS025I(_aLinhaNF[31],"@E 999,999,999.999")                   // "% Com Nota Sup"          29-->31
               _aLinhaNF[32] := U_ROMS025I(_aLinhaNF[32],"@E 999,999,999.999")                   // "Media % Sistemica Sup"   30-->32

			   _aLinhaNF[33] := U_ROMS025I(_aLinhaNF[33],"@E 999,999,999.999")                   // "Vlr Com Cood"            31-->33
			   _aLinhaNF[34] := U_ROMS025I(_aLinhaNF[34],"@E 999,999,999.999")                   // "% Com Cood"	             32-->34

               _aLinhaNF[35] := U_ROMS025I(_aLinhaNF[35],"@E 999,999,999.999")                   // "% Com Nota Coord"        33-->35 
               _aLinhaNF[36] := U_ROMS025I(_aLinhaNF[36],"@E 999,999,999.999")                   // "Media % Sistemica Coord" 34-->36 

               _aLinhaNF[37] := U_ROMS025I(_aLinhaNF[37],"@E 999,999,999.999")                    // "Vlr Com Ger"              
			   _aLinhaNF[38] := U_ROMS025I(_aLinhaNF[38],"@E 999,999,999.999")                    // "% Com Ger"	              
			   _aLinhaNF[39] := U_ROMS025I(_aLinhaNF[39],"@E 999,999,999.999")                    // "% Com Nota Ger"           
               _aLinhaNF[40] := U_ROMS025I(_aLinhaNF[40],"@E 999,999,999.999")                    // "Media % Sistemica Ger"     

           ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // imprime apenas gerente nacional
               _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                                     // 12  SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem                             // 13  ( (_cAlias)->COMPENSACA * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem                              // 14  SD2->D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem                              // 15  ( (_cAlias)->BAIXASANT * (SD2->D2_TOTAL/_nValTotMerc)
			   
			   If AllTrim(_aLinhaNF[02]) == "BON"
			      _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                                  //* -1 // _nbasecomis * _nPercItem * -1  // 16   Bonifica��o n�o gera comiss�o. O valor dever ser negativo.  
			   Else
			      _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                                  // _nbasecomis * _nPercItem   // 16  ( _nbasecomis * (D2_TOTAL/_nValTotMerc) 
			   EndIf

               _aLinhaNF[19] := _aLinhaNF[16]  * (SD2->D2_COMIS5 / 100)	                        // "Vlr Com Ger Nac"
			   _aLinhaNF[20] := SD2->D2_COMIS5                                                  // "% Com Ger Nac"

			   _aLinhaNF[21] := _nPerSisGN                                                      // "% Com Nota Ger Nac"
			   _aLinhaNF[22] := _nMedSisGN                                                      // "Media % Sistemica Ger Nac"  
   

               //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
               _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                   // 12  SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                   // 13  ( (_cAlias)->COMPENSACA * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                   // 14  SD2->D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                   // 15  ( (_cAlias)->BAIXASANT * (SD2->D2_TOTAL/_nValTotMerc)
	           _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")                   // 16  ( _nbasecomis * (D2_TOTAL/_nValTotMerc) 
			   _aLinhaNF[19] := U_ROMS025I(_aLinhaNF[19],"@E 999,999,999.999")                   // 19  Percentual comiss�o Gerente nacional
			   _aLinhaNF[20] := U_ROMS025I(_aLinhaNF[20],"@E 999,999,999.999")                   // 20  Comiss�o Gerente Nacional    
			   
			   _aLinhaNF[21] := U_ROMS025I(_aLinhaNF[21],"@E 999,999,999.999")                   // "% Com Nota Ger Nac"
               _aLinhaNF[22] := U_ROMS025I(_aLinhaNF[22],"@E 999,999,999.999")                   // "Media % Sistemica Ger Nac"

            ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas gerente  // 6 
               _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                                     // 12  SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem                             // 13  ( (_cAlias)->COMPENSACA * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem                              // 14  SD2->D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem                              // 15  ( (_cAlias)->BAIXASANT * (SD2->D2_TOTAL/_nValTotMerc)
			   
			   If AllTrim(_aLinhaNF[02]) == "BON"
			      _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                                  //* -1 // _nbasecomis * _nPercItem * -1  // 16   Bonifica��o n�o gera comiss�o. O valor dever ser negativo.  
			   Else
			      _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                                  // _nbasecomis * _nPercItem   // 16  ( _nbasecomis * (D2_TOTAL/_nValTotMerc) 
			   EndIf

			   _aLinhaNF[19] := _aLinhaNF[16] * (SD2->D2_COMIS3 / 100)                         // 19  * SD2->D2_COMIS3  - Percentual comiss�o 3 - Gerente
			   _aLinhaNF[20] := SD2->D2_COMIS3                                                 // 20  = SD2->D2_COMIS3  - Percentual comiss�o 3 - Gerente

			   _aLinhaNF[21] := _nPerSisGe                                                     // "% Com Nota Ger",;          // 21 A 
               _aLinhaNF[22] := _nMedSisGe                                                     // "Media % Sistemica Ger",;   // 22 A

               //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
               _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                   // 12  SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                   // 13  ( (_cAlias)->COMPENSACA * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                   // 14  SD2->D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                   // 15  ( (_cAlias)->BAIXASANT * (SD2->D2_TOTAL/_nValTotMerc)
	           _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")                   // 16  ( _nbasecomis * (D2_TOTAL/_nValTotMerc) 
			   _aLinhaNF[19] := U_ROMS025I(_aLinhaNF[19],"@E 999,999,999.999")                   // 19  * SD2->D2_COMIS3  - Percentual comiss�o 3 - Gerente
			   _aLinhaNF[20] := U_ROMS025I(_aLinhaNF[20],"@E 999,999,999.999")                   // 20  = SD2->D2_COMIS3  - Percentual comiss�o 3 - Gerente    
			   
			   _aLinhaNF[21] := U_ROMS025I(_aLinhaNF[21],"@E 999,999,999.999")                   // "% Com Nota Ger",;          // 21 A 
               _aLinhaNF[22] := U_ROMS025I(_aLinhaNF[22],"@E 999,999,999.999")                   // "Media % Sistemica Ger",;   // 22 A

            ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas Coordenador // 7 
           	   _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                                     // 12  SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem                             // 13  ( (_cAlias)->COMPENSACA * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem                              // 14  SD2->D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem                              // 15  ( (_cAlias)->BAIXASANT * (SD2->D2_TOTAL/_nValTotMerc)
			   
			   If AllTrim(_aLinhaNF[02]) == "BON"
			      _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                                   //* -1 // _nbasecomis * _nPercItem * -1                               // 16   Bonifica��o n�o gera comiss�o. O valor deve ser negativo. 
			   Else
			      _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                                   // _nbasecomis * _nPercItem                                    // 16  ( _nbasecomis * (SD2->D2_TOTAL/_nValTotMerc)
			   EndIf
			   
			   _aLinhaNF[19] := _aLinhaNF[16] * (SD2->D2_COMIS2 / 100)                         // 19  * SD2->D2_COMIS2  - Percentual comiss�o 2 - Coordenador
               _aLinhaNF[20] := SD2->D2_COMIS2                                                 // 20  = SD2->D2_COMIS2  - Percentual comiss�o 2 - Coordenador

			   _aLinhaNF[21] := _nPerSisCo                                                     // "% Com Nota Coord",;        // 21 A
               _aLinhaNF[22] := _nMedSisCo                                                     // "Media % Sistemica Coord",; // 22 A 

			   //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
			   _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                   // 12  SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                   // 13  ( (_cAlias)->COMPENSACA * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                   // 14  SD2->D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                   // 15  ( (_cAlias)->BAIXASANT * (SD2->D2_TOTAL/_nValTotMerc)
		       _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")                   // 16  ( _nbasecomis * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[19] := U_ROMS025I(_aLinhaNF[19],"@E 999,999,999.999")                   // 19  * SD2->D2_COMIS2  - Percentual comiss�o 2 - Coordenador
               _aLinhaNF[20] := U_ROMS025I(_aLinhaNF[20],"@E 999,999,999.999")                   // 20  = SD2->D2_COMIS2  - Percentual comiss�o 2 - Coordenador

			   _aLinhaNF[21] := U_ROMS025I(_aLinhaNF[21],"@E 999,999,999.999")                   // "% Com Nota Coord",;        // 21 A
               _aLinhaNF[22] := U_ROMS025I(_aLinhaNF[22],"@E 999,999,999.999")                   // "Media % Sistemica Coord",; // 22 A 

            ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas supervisor  // 8
               _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                                     // 12  SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem                             // 13  ( (_cAlias)->COMPENSACA * (D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem                              // 14  SD2->D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem                              // 15  ( (_cAlias)->BAIXASANT * (D2_TOTAL/_nValTotMerc)
			   
			   If AllTrim(_aLinhaNF[02]) == "BON"
			      _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                                  //* -1  // _nbasecomis * _nPercItem * -1                               // 16   Bonifica��o n�o gera comiss�o. O valor dever ser negativo.  
			   Else
			      _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                                  // _nbasecomis * _nPercItem                                    // 16  ( _nbasecomis * (D2_TOTAL/_nValTotMerc)
			   EndIf
			   
			   _aLinhaNF[19] := _aLinhaNF[16] * (SD2->D2_COMIS4 / 100)                         // 19  * D2_COMIS4  - Percentual comiss�o 4 - Supervidor
			   _aLinhaNF[20] := SD2->D2_COMIS4                                                 // 20  = D2_COMIS4  - Percentual comiss�o 4 - Supervidor			   

			   _aLinhaNF[21] := _nPerSisSp                                                     // "% Com Nota Sup",;          // 21 A
               _aLinhaNF[22] := _nMedSisSp                                                     // "Media % Sistemica Sup",;   // 22 A

			   //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
			   _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                   // 12  SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                   // 13  ( (_cAlias)->COMPENSACA * (D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                   // 14  SD2->D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                   // 15  ( (_cAlias)->BAIXASANT * (D2_TOTAL/_nValTotMerc)
               _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")                   // 16  ( _nbasecomis * (D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[19] := U_ROMS025I(_aLinhaNF[19],"@E 999,999,999.999")                   // 19  * D2_COMIS4  - Percentual comiss�o 4 - Supervidor
			   _aLinhaNF[20] := U_ROMS025I(_aLinhaNF[20],"@E 999,999,999.999")                   // 20  = D2_COMIS4  - Percentual comiss�o 4 - Supervidor
													
               _aLinhaNF[21] := U_ROMS025I(_aLinhaNF[21],"@E 999,999,999.999")                   // "% Com Nota Sup",;          // 21 A
			   _aLinhaNF[22] := U_ROMS025I(_aLinhaNF[22],"@E 999,999,999.999")                   // "Media % Sistemica Sup",;   // 22 A

            ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas vendedor  // 9
               _aLinhaNF[12] := _aLinhaNF[12] * _nPercItem                                     // 12   SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := (_cAlias)->COMPENSACA * _nPercItem                             // 13   ( (_cAlias)->COMPENSACA * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[14] := (_cAlias)->DESCONTO  * _nPercItem                              // 14  SD2->D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := (_cAlias)->BAIXASANT * _nPercItem                              // 15  ( (_cAlias)->BAIXASANT * (SD2->D2_TOTAL/_nValTotMerc)
			   
			   If AllTrim(_aLinhaNF[02]) == "BON"
			      _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                                   //* -1  // _nbasecomis * _nPercItem * -1  // 16   Bonifica��o n�o gera comiss�o. O valor deve ser negativo. 
			   Else
			      _aLinhaNF[16] := _aLinhaNF[16] * _nPercItem                                   // _nbasecomis * _nPercItem               // 16  ( _nbasecomis * (SD2->D2_TOTAL/_nValTotMerc)
			   EndIf
			   
			   _aLinhaNF[19] := _aLinhaNF[16] * (SD2->D2_COMIS1 / 100)                         // 19  * SD2->D2_COMIS1  - Percentual comiss�o 1 - Vendedor 
			   _aLinhaNF[20] := SD2->D2_COMIS1                                                 // 20  = SD2->D2_COMIS1  - Percentual comiss�o 1 - Vendedor

               _aLinhaNF[21] :=  _nPerSisVd                                                    // "% Com Nota Rep",;          // 21 A
               _aLinhaNF[22] :=  _nMedSisVd                                                    // "Media % Sistemica Rep",;   // 22 A

               //==========================================================
			   // Formatando os campos de valores
			   //==========================================================
               _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                   // 12   SD2->D2_TOTAL  =  Valor total do item.	
			   _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                   // 13   ( (_cAlias)->COMPENSACA * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                   // 14  SD2->D2_DESC    = Desconto do item.							
			   _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                   // 15  ( (_cAlias)->BAIXASANT * (SD2->D2_TOTAL/_nValTotMerc)
		       _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")                   // 16  ( _nbasecomis * (SD2->D2_TOTAL/_nValTotMerc)
			   _aLinhaNF[19] := U_ROMS025I(_aLinhaNF[19],"@E 999,999,999.999")                   // 19  * SD2->D2_COMIS1  - Percentual comiss�o 1 - Vendedor 
			   _aLinhaNF[20] := U_ROMS025I(_aLinhaNF[20],"@E 999,999,999.999")                   // 20  = SD2->D2_COMIS1  - Percentual comiss�o 1 - Vendedor
               
			   _aLinhaNF[21] := U_ROMS025I(_aLinhaNF[21],"@E 999,999,999.999")                   // "% Com Nota Rep",;          // 21 A
               _aLinhaNF[22] := U_ROMS025I(_aLinhaNF[22],"@E 999,999,999.999")                   // "Media % Sistemica Rep",;   // 22 A
            EndIf

            For i := 1 to Len(_aDadosRAD)
               AADD(_aLinhaNF,_aDadosRAD[i])
            Next
            
            _cDescPrd := Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC")    // Desc. Prod.
			_cBIMIX   := Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_I_BIMIX") // Mix BI
            
			Aadd(_aLinhaNF, _cBIMIX        )                                      // "Mix BI"           
            Aadd(_aLinhaNF, SD2->D2_ITEM   )                                      // "Item"           
            Aadd(_aLinhaNF, SD2->D2_COD    )                                      // "Produto"           
            Aadd(_aLinhaNF, _cDescPrd      )                                      // "Descri��o"   
            Aadd(_aLinhaNF, U_ROMS025I(SD2->D2_PICM,"@E 999,999,999.99")   )       // "Aliq.%"           
            Aadd(_aLinhaNF, U_ROMS025I(SD2->D2_QUANT,"@E 999,999,999.99")  )       // "Qtde"             
			Aadd(_aLinhaNF, SD2->D2_UM     )                                      // "U.M."               
			Aadd(_aLinhaNF, U_ROMS025I(SD2->D2_QTSEGUM,"@E 999,999,999.99"))       // "Qtde 2a U.M."  
    		Aadd(_aLinhaNF, SD2->D2_SEGUM  )                                      // "2a U.M."         
            Aadd(_aLinhaNF, U_ROMS025I(SD2->D2_PRCVEN,"@E 999,999,999.99") )       // "Vlr.Uni."        
            Aadd(_aLinhaNF, U_ROMS025I(SD2->D2_TOTAL,"@E 999,999,999.99")  )       // "Valor Total"     
			Aadd(_aLinhaNF, SD2->D2_NFORI  )                                      // "NF.Origem"       
            Aadd(_aLinhaNF, SD2->D2_SERIORI)                                      // "Serie Origem"  

            Aadd(_aRet, AClone(_aLinhaNF))
                        
            SD2->(DbSkip())
            
         EndDo
	  Else 
         _aLinhaNF := {}
         For _nI := 1 To Len(_aDadosR)
             Aadd(_aLinhaNF, _aDadosR[_nI])
         Next

         If ValType(_aLinhaNF[12]) == "N"
            _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                    // 12   Valor total do item.	
	     EndIf
	     If ValType(_aLinhaNF[13]) == "N"
	    	_aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                    // 13   Compensa��o  
	     EndIf	
	     If ValType(_aLinhaNF[14]) == "N"
		    _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                    // 14   Desconto do item.							
	     EndIf
	     If ValType(_aLinhaNF[15]) == "N"
	 	    _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                    // 15   
	     EndIf
	     If ValType(_aLinhaNF[16]) == "N"
		    _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")                    // 16   
	     EndIf	
	     If Len(_aLinhaNF) >= 25 .And. ValType(_aLinhaNF[25]) == "N"
	        _aLinhaNF[25] := U_ROMS025I(_aLinhaNF[25],"@E 999,999,999.999")                    // 25   
	     EndIf		
	     If Len(_aLinhaNF) >= 26 .And. ValType(_aLinhaNF[26]) == "N"
	        _aLinhaNF[26] := U_ROMS025I(_aLinhaNF[26],"@E 999,999,999.999")                    // 26   
	     EndIf		
	     If Len(_aLinhaNF) >= 27 .And. ValType(_aLinhaNF[27]) == "N"
	        _aLinhaNF[27] := U_ROMS025I(_aLinhaNF[27],"@E 999,999,999.999")                    // 27  
	     EndIf	
	     If Len(_aLinhaNF) >= 28 .And. ValType(_aLinhaNF[28]) == "N"
	        _aLinhaNF[28] := U_ROMS025I(_aLinhaNF[28],"@E 999,999,999.999")                    // 28   
	     EndIf	
	     If Len(_aLinhaNF) >= 30 .And. ValType(_aLinhaNF[30]) == "N"
	        _aLinhaNF[30] := U_ROMS025I(_aLinhaNF[30],"@E 999,999,999.999")                    // 30   
	     EndIf	
	     If Len(_aLinhaNF) >= 31 .And. ValType(_aLinhaNF[31]) == "N"
	        _aLinhaNF[31] := U_ROMS025I(_aLinhaNF[31],"@E 999,999,999.999")                    // 31   
	     EndIf	
	     If Len(_aLinhaNF) >= 32 .And. ValType(_aLinhaNF[32]) == "N"
	        _aLinhaNF[32] := U_ROMS025I(_aLinhaNF[32],"@E 999,999,999.999")                    // 32   
	     EndIf 	

	     If Len(_aLinhaNF) >= 33 .And. ValType(_aLinhaNF[33]) == "N"
	        _aLinhaNF[33] := U_ROMS025I(_aLinhaNF[33],"@E 999,999,999.999")                    // 33   
	     EndIf 	

         If Len(_aLinhaNF) >= 34 .And. ValType(_aLinhaNF[34]) == "N"
	        _aLinhaNF[34] := U_ROMS025I(_aLinhaNF[34],"@E 999,999,999.999")                    // 34  
	     EndIf 	

         If Len(_aLinhaNF) >= 35 .And. ValType(_aLinhaNF[35]) == "N"
	        _aLinhaNF[35] := U_ROMS025I(_aLinhaNF[35],"@E 999,999,999.999")                    // 35   
	     EndIf 	

         If Len(_aLinhaNF) >= 36 .And. ValType(_aLinhaNF[36]) == "N"
	        _aLinhaNF[36] := U_ROMS025I(_aLinhaNF[36],"@E 999,999,999.999")                    // 36   
	     EndIf 	

         If Len(_aLinhaNF) >= 37 .And. ValType(_aLinhaNF[37]) == "N"
	        _aLinhaNF[37] := U_ROMS025I(_aLinhaNF[37],"@E 999,999,999.999")                    // 37   
	     EndIf 	

         If Len(_aLinhaNF) >= 38 .And. ValType(_aLinhaNF[38]) == "N"
	        _aLinhaNF[38] := U_ROMS025I(_aLinhaNF[38],"@E 999,999,999.999")                    // 38   		 
	     EndIf 	
      
	     If Len(_aLinhaNF) >= 39 .And. ValType(_aLinhaNF[39]) == "N"
	        _aLinhaNF[39] := U_ROMS025I(_aLinhaNF[39],"@E 999,999,999.999")                    // 39   
	     EndIf 	
      
	     If Len(_aLinhaNF) >= 40 .And. ValType(_aLinhaNF[40]) == "N"
	        _aLinhaNF[40] := U_ROMS025I(_aLinhaNF[40],"@E 999,999,999.999")                    // 40   
	     EndIf 	

         If Len(_aLinhaNF) >= 41 .And. ValType(_aLinhaNF[41]) == "N"
	        _aLinhaNF[41] := U_ROMS025I(_aLinhaNF[41],"@E 999,999,999.999")                    // 41   
	     EndIf 	

	     If Len(_aLinhaNF) >= 42 .And. ValType(_aLinhaNF[42]) == "N"
	        _aLinhaNF[42] := U_ROMS025I(_aLinhaNF[42],"@E 999,999,999.999")                    // 42   
	     EndIf 	

	     If Len(_aLinhaNF) >= 43 .And. ValType(_aLinhaNF[43]) == "N"
	        _aLinhaNF[43] := U_ROMS025I(_aLinhaNF[43],"@E 999,999,999.999")                    // 43   
	     EndIf 	

	     If Len(_aLinhaNF) >= 44 .And. ValType(_aLinhaNF[44]) == "N"
	        _aLinhaNF[44] := U_ROMS025I(_aLinhaNF[44],"@E 999,999,999.999")                    // 44   
	     EndIf 	

	     If Len(_aLinhaNF) >= 45 .And. ValType(_aLinhaNF[45]) == "N"
	        _aLinhaNF[45] := U_ROMS025I(_aLinhaNF[45],"@E 999,999,999.999")                    // 45   
	     EndIf 	

	     If Len(_aLinhaNF) >= 46 .And. ValType(_aLinhaNF[46]) == "N"
	        _aLinhaNF[46] := U_ROMS025I(_aLinhaNF[46],"@E 999,999,999.999")                    // 46   
	     EndIf 	
      
	     Aadd(_aLinhaNF, "" )                                // Mix BI
         Aadd(_aLinhaNF, "" )                                // "Item"           
         Aadd(_aLinhaNF, "" )                                // "Produto"           
         Aadd(_aLinhaNF, "" )                                // "Descri��o"        
         Aadd(_aLinhaNF, U_ROMS025I(0,"@E 999,999,999.99"))  // "Aliq.%"           
         Aadd(_aLinhaNF, U_ROMS025I(0,"@E 999,999,999.99"))  // "Qtde"             
         Aadd(_aLinhaNF, "" )                                // "U.M."               
         Aadd(_aLinhaNF, U_ROMS025I(0 ,"@E 999,999,999.99")) // "Qtde 2a U.M."  
         Aadd(_aLinhaNF, "" )                                // "2a U.M."         
         Aadd(_aLinhaNF, U_ROMS025I(0,"@E 999,999,999.99"))  // "Vlr.Uni."        
         Aadd(_aLinhaNF, U_ROMS025I(0,"@E 999,999,999.99"))  // "Valor Total"     
         Aadd(_aLinhaNF, "" )                                // "NF.Origem"       
         Aadd(_aLinhaNF, "" )                                // "Serie Origem"  
 
         For i := 1 to Len(_aDadosRAD)
            AADD(_aLinhaNF,_aDadosRAD[i])
         Next

         Aadd(_aRet, AClone(_aLinhaNF))

      EndIf   
   Else
      _aLinhaNF := {}
      For _nI := 1 To Len(_aDadosR)
          Aadd(_aLinhaNF, _aDadosR[_nI])
      Next

      If ValType(_aLinhaNF[12]) == "N"
         _aLinhaNF[12] := U_ROMS025I(_aLinhaNF[12],"@E 999,999,999.999")                    // 12   Valor total do item.	
	  EndIf
	  If ValType(_aLinhaNF[13]) == "N"
		 _aLinhaNF[13] := U_ROMS025I(_aLinhaNF[13],"@E 999,999,999.999")                    // 13   Compensa��o  
	  EndIf	
	  If ValType(_aLinhaNF[14]) == "N"
		 _aLinhaNF[14] := U_ROMS025I(_aLinhaNF[14],"@E 999,999,999.999")                    // 14   Desconto do item.							
	  EndIf
	  If ValType(_aLinhaNF[15]) == "N"
		 _aLinhaNF[15] := U_ROMS025I(_aLinhaNF[15],"@E 999,999,999.999")                    // 15   
	  EndIf
	  If ValType(_aLinhaNF[16]) == "N"
		 _aLinhaNF[16] := U_ROMS025I(_aLinhaNF[16],"@E 999,999,999.999")                    // 16   
	  EndIf	
	  If Len(_aLinhaNF) >= 25 .And. ValType(_aLinhaNF[25]) == "N"
	     _aLinhaNF[25] := U_ROMS025I(_aLinhaNF[25],"@E 999,999,999.999")                    // 25   
	  EndIf		
	  If Len(_aLinhaNF) >= 26 .And. ValType(_aLinhaNF[26]) == "N"
	     _aLinhaNF[26] := U_ROMS025I(_aLinhaNF[26],"@E 999,999,999.999")                    // 26   
	  EndIf		
	  If Len(_aLinhaNF) >= 27 .And. ValType(_aLinhaNF[27]) == "N"
	     _aLinhaNF[27] := U_ROMS025I(_aLinhaNF[27],"@E 999,999,999.999")                    // 27  
	  EndIf	
	  If Len(_aLinhaNF) >= 28 .And. ValType(_aLinhaNF[28]) == "N"
	     _aLinhaNF[28] := U_ROMS025I(_aLinhaNF[28],"@E 999,999,999.999")                    // 28   
	  EndIf	
	  If Len(_aLinhaNF) >= 30 .And. ValType(_aLinhaNF[30]) == "N"
	     _aLinhaNF[30] := U_ROMS025I(_aLinhaNF[30],"@E 999,999,999.999")                    // 30   
	  EndIf	
	  If Len(_aLinhaNF) >= 31 .And. ValType(_aLinhaNF[31]) == "N"
	     _aLinhaNF[31] := U_ROMS025I(_aLinhaNF[31],"@E 999,999,999.999")                    // 31   
	  EndIf	
	  If Len(_aLinhaNF) >= 32 .And. ValType(_aLinhaNF[32]) == "N"
	     _aLinhaNF[32] := U_ROMS025I(_aLinhaNF[32],"@E 999,999,999.999")                    // 32   
	  EndIf 	

	  If Len(_aLinhaNF) >= 33 .And. ValType(_aLinhaNF[33]) == "N"
	     _aLinhaNF[33] := U_ROMS025I(_aLinhaNF[33],"@E 999,999,999.999")                    // 33   
	  EndIf 	

      If Len(_aLinhaNF) >= 34 .And. ValType(_aLinhaNF[34]) == "N"
	     _aLinhaNF[34] := U_ROMS025I(_aLinhaNF[34],"@E 999,999,999.999")                    // 34  
	  EndIf 	

      If Len(_aLinhaNF) >= 35 .And. ValType(_aLinhaNF[35]) == "N"
	     _aLinhaNF[35] := U_ROMS025I(_aLinhaNF[35],"@E 999,999,999.999")                    // 35   
	  EndIf 	

      If Len(_aLinhaNF) >= 36 .And. ValType(_aLinhaNF[36]) == "N"
	     _aLinhaNF[36] := U_ROMS025I(_aLinhaNF[36],"@E 999,999,999.999")                    // 36   
	  EndIf 	

      If Len(_aLinhaNF) >= 37 .And. ValType(_aLinhaNF[37]) == "N"
	     _aLinhaNF[37] := U_ROMS025I(_aLinhaNF[37],"@E 999,999,999.999")                    // 37   
	  EndIf 	

      If Len(_aLinhaNF) >= 38 .And. ValType(_aLinhaNF[38]) == "N"
	     _aLinhaNF[38] := U_ROMS025I(_aLinhaNF[38],"@E 999,999,999.999")                    // 38   		 
	  EndIf 	
      
	  If Len(_aLinhaNF) >= 39 .And. ValType(_aLinhaNF[39]) == "N"
	     _aLinhaNF[39] := U_ROMS025I(_aLinhaNF[39],"@E 999,999,999.999")                    // 39   
	  EndIf 	
      
	  If Len(_aLinhaNF) >= 40 .And. ValType(_aLinhaNF[40]) == "N"
	     _aLinhaNF[40] := U_ROMS025I(_aLinhaNF[40],"@E 999,999,999.999")                    // 40   
	  EndIf 	

      If Len(_aLinhaNF) >= 41 .And. ValType(_aLinhaNF[41]) == "N"
	     _aLinhaNF[41] := U_ROMS025I(_aLinhaNF[41],"@E 999,999,999.999")                    // 41   
	  EndIf 	

	  If Len(_aLinhaNF) >= 42 .And. ValType(_aLinhaNF[42]) == "N"
	     _aLinhaNF[42] := U_ROMS025I(_aLinhaNF[42],"@E 999,999,999.999")                    // 42   
	  EndIf 	

	  If Len(_aLinhaNF) >= 43 .And. ValType(_aLinhaNF[43]) == "N"
	     _aLinhaNF[43] := U_ROMS025I(_aLinhaNF[43],"@E 999,999,999.999")                    // 43   
	  EndIf 	

	  If Len(_aLinhaNF) >= 44 .And. ValType(_aLinhaNF[44]) == "N"
	     _aLinhaNF[44] := U_ROMS025I(_aLinhaNF[44],"@E 999,999,999.999")                    // 44   
	  EndIf 	

	  If Len(_aLinhaNF) >= 45 .And. ValType(_aLinhaNF[45]) == "N"
	     _aLinhaNF[45] := U_ROMS025I(_aLinhaNF[45],"@E 999,999,999.999")                    // 45   
	  EndIf 	

	  If Len(_aLinhaNF) >= 46 .And. ValType(_aLinhaNF[46]) == "N"
	     _aLinhaNF[46] := U_ROMS025I(_aLinhaNF[46],"@E 999,999,999.999")                    // 46   
	  EndIf 
	  	
      For i := 1 to Len(_aDadosRAD)
         AADD(_aLinhaNF,_aDadosRAD[i])
      Next
	  
	  Aadd(_aLinhaNF, "" )                                // Mix BI
      Aadd(_aLinhaNF, "" )                                // "Item"           
      Aadd(_aLinhaNF, "" )                                // "Produto"           
      Aadd(_aLinhaNF, "" )                                // "Descri��o"        
      Aadd(_aLinhaNF, U_ROMS025I(0,"@E 999,999,999.99"))  // "Aliq.%"           
      Aadd(_aLinhaNF, U_ROMS025I(0,"@E 999,999,999.99"))  // "Qtde"             
      Aadd(_aLinhaNF, "" )                                // "U.M."               
      Aadd(_aLinhaNF, U_ROMS025I(0 ,"@E 999,999,999.99")) // "Qtde 2a U.M."  
      Aadd(_aLinhaNF, "" )                                // "2a U.M."         
      Aadd(_aLinhaNF, U_ROMS025I(0,"@E 999,999,999.99"))  // "Vlr.Uni."        
      Aadd(_aLinhaNF, U_ROMS025I(0,"@E 999,999,999.99"))  // "Valor Total"     
      Aadd(_aLinhaNF, "" )                                // "NF.Origem"       
      Aadd(_aLinhaNF, "" )                                // "Serie Origem"  

      Aadd(_aRet, AClone(_aLinhaNF))
             
   EndIf
  
End Sequence'

RestOrd(_aOrd)

Return _aRet

/*
===============================================================================================================================
Programa--------: ROMS025H
Autor-----------: Julio de Paula Paz
Data da Criacao-: 29/03/2019
Descri��o-------: Fun��o que processa a impress�o dos dados do relat�rio - Previs�o de Comiss�o
Parametros------: oproc - objeto da barra de processamento
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS025H(oProc As Object)

Local _cAlias As Character
Local _cAlias3 As Character
Local _cAlias4 As Character
Local _nCountRec As Numeric
Local _nTotreg As Numeric  
Local _cRazaoCli As Character
Local _cCodGrupo  As Character
Local _cDescGrupo  As Character
Local _cMVPAR05  As Character
Local _aDadosIndex As Array
Local _aDadosLin As Array
Local _nI As Numeric
Local _nJ As Numeric 
Local _nTotColun As Numeric
Local _aParcelaPre As Numeric
Local _cParcela As Character
Local _nPercParcela As Numeric
Local _nTotParcela As Numeric
Local _nIcmsRet As Numeric
Local _nValICMParc  As Numeric
Local _nBaseComiss As Numeric
Local _nComiss1 As Numeric 
Local _nComiss2 As Numeric
Local _nComiss3 As Numeric
Local _nComiss4 As Numeric
Local _nPerCom1
Local _nPerCom2 As Numeric
Local _nPerCom3 As Numeric
Local _nPerCom4 As Numeric
Local _aComissao As Numeric

Private _aFiliais As Array        

_cAlias    := GetNextAlias()
_cAlias3   := GetNextAlias()
_cAlias4   := GetNextAlias()
_nCountRec := 0  
_ntotreg  := 0    
_cRazaoCli := ""
_cCodGrupo := ""
_cDescGrupo := ""
_cMVPAR05 := MV_PAR06 // Filtro Vendedor 
_aDadosIndex := {}
_aDadosLin := {}
_nI := 0
_nJ := 0
_nTotColun  := 0
_aParcelaPre := {}
_cParcela  := ""
_nPercParcela := 0
_nTotParcela := 0
_nIcmsRet := 0
_nValICMParc := 0
_nBaseComiss := 0
_nComiss1 := 0
_nComiss2 := 0
_nComiss3 := 0
_nComiss4 := 0
_nPerCom1 := 0
_nPerCom2  := 0
_nPerCom3  := 0
_nPerCom4  := 0
_aComissao := {}

_aFiliais:= {}     

Begin Sequence
   If Empty(MV_PAR01)
	  U_itmsg("Favor preencher o par�metro: Mes/Ano antes de imprimir este relat�rio.","Aten��o",,1)
	  Break 
   EndIf
     
   //=======================================================================================================
   // Chama a rotina para selecao dos registros da comissao.												
   //=======================================================================================================
   fwMsgRun(,{|oproc|ROMS025QRY(_cAlias,1,oproc)},"Aguarde....","Filtrando os dados de credito e debito da comiss�o.")        
	
   dbSelectArea(_cAlias)
   (_cAlias)->(dbGotop())        
	            	
   //=============================================
   //Armazena o numero de registros encontrados.
   //=============================================
   COUNT TO _nCountRec 
		
   dbSelectArea(_cAlias)
   (_cAlias)->(dbGotop())       
	
   //=============================================
   //Verifica se existem registros selecionados.
   //=============================================
   If (_cAlias)->(!Eof())				
      _nni := 0
      
      Do While (_cAlias)->(!Eof()) 
         _nni++
         oproc:cCaption := ("Processando dados " + strzero(_nni,10) + " de " +  strzero(_nCountRec,10))
         ProcessMessages()
         _lachou := .F.
         
         //================================================
         // Busca dados adicionais
         //================================================
         SF2->(Dbsetorder(1))
         SA3->(Dbsetorder(1))
         If SF2->(Dbseek((_cAlias)->FILIAL+(_cAlias)->NUMERO)) .AND. ALLTRIM((_cAlias)->CODCLI) == ALLTRIM(SF2->F2_CLIENTE) 
            _cRazaoCli  := Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NOME")
			_cCodGrupo  := Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_GRPVEN")
			_cDescGrupo := Posicione("ACY",1,xFilial("ACY")+_cCodGrupo,"ACY_DESCRI")
            _ccodrep    := SF2->F2_VEND1
            _cnomerep   := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodrep)),SA3->A3_NOME," ")
            _ccodsup    := SF2->F2_VEND4
            _cnomesup   := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodsup)),SA3->A3_NOME," ")
            _ccodcoord  := SF2->F2_VEND2
            _cnomecoord := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodcoord)),SA3->A3_NOME," ")
            _ccodger    := SF2->F2_VEND3
            _cnomeger   := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodger)),SA3->A3_NOME," ")
		
			_cCodGNc    := SF2->F2_VEND5
            _cNomeGnc   := IIF(SA3->(Dbseek(xfilial("SA3")+_cCodGNc)),SA3->A3_NOME," ")
            _lachou     := .T.
         Else
            _cRazaoCli  := Posicione("SA1",1,xFilial("SA1")+(_cAlias)->CODCLI+(_cAlias)->LOJA,"A1_NOME")
			_cCodGrupo  := Posicione("SA1",1,xFilial("SA1")+(_cAlias)->CODCLI+(_cAlias)->LOJA,"A1_GRPVEN")
			_cDescGrupo := Posicione("ACY",1,xFilial("ACY")+_cCodGrupo,"ACY_DESCRI")
            _ccodrep    := (_cAlias)->CODVEND
            _cnomerep   := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodrep)),SA3->A3_NOME," ")
            _ccodsup    := POSICIONE("SA3",1,xfilial("SA3")+(_cAlias)->CODVEND,"A3_I_SUPE")
            _cnomesup   := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodsup)),SA3->A3_NOME," ")
            _ccodcoord  := POSICIONE("SA3",1,xfilial("SA3")+(_cAlias)->CODVEND,"A3_SUPER")
            _cnomecoord := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodcoord)),SA3->A3_NOME," ")
            _ccodger    := POSICIONE("SA3",1,xfilial("SA3")+(_cAlias)->CODVEND,"A3_GEREN")
            _cnomeger   := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodger)),SA3->A3_NOME," ")
        
			_cCodGnc    := POSICIONE("SA3",1,xfilial("SA3")+(_cAlias)->CODVEND,"A3_I_GERNC")
            _cNomeGnc   := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodger)),SA3->A3_NOME," ")
         EndIf
				
         _ncomsup := 0
		 _ncomcoord := 0
		 _ncomger := 0
		 _ncomrep := 0
		 _nComGnc := 0

		 SE3->(Dbsetorder(1))
		 If SE3->(Dbseek((_cAlias)->FILIAL+(_cAlias)->PREFIXO+(_cAlias)->E3NUMORI+(_cAlias)->PARCELA+(_cAlias)->SEQ))
			Do while SE3->E3_FILIAL == (_cAlias)->FILIAL .AND. ;
			   SE3->E3_PREFIXO == (_cAlias)->PREFIXO .AND. ;
			   SE3->E3_NUM == (_cAlias)->E3NUMORI .AND. ;
			   SE3->E3_PARCELA == (_cAlias)->PARCELA .AND. ;
			   SE3->E3_SEQ == (_cAlias)->SEQ
               
               If SE3->E3_VEND == _ccodrep //Representante
                  _ncomrep := ROUND(_ncomrep + SE3->E3_COMIS ,3)
               EndIf
			   
			   If SE3->E3_VEND == _ccodsup  //Supervisor
                  _ncomsup := ROUND(_ncomsup + SE3->E3_COMIS ,3)
               EndIf
               
               If SE3->E3_VEND == _ccodcoord  //Coordenador
                  _ncomcoord := ROUND(_ncomcoord + SE3->E3_COMIS ,3)
               EndIf

               If SE3->E3_VEND == _ccodger  //Gerente
                  _ncomger := ROUND(_ncomger + SE3->E3_COMIS ,3)
               EndIf 

			   If SE3->E3_VEND == _cCodGnc  //Gerente Nacional
                  _nComGnc := ROUND(_nComGnc + SE3->E3_COMIS ,3)
               EndIf

               SE3->(Dbskip())
            Enddo
         EndIf
            
         _nperrep := round(_ncomrep/(_cAlias)->BASECOMIS*100,3)
         _nperrep := iif(_nperrep<0,-1*_nperrep,_nperrep)
			
         _nbasecomis := iif((_cAlias)->COMISSAO<0,-1*(_cAlias)->BASECOMIS,(_cAlias)->BASECOMIS)
				
         _npersup := round(_ncomsup/(_cAlias)->BASECOMIS*100,3)
         _npersup := iif(_npersup<0,-1*_npersup,_npersup)
				
         _npercoo := round(_ncomcoord/(_cAlias)->BASECOMIS*100,3)
         _npercoo := iif(_npercoo<0,-1*_npercoo,_npercoo)
				
         _nperger := round(_ncomger/(_cAlias)->BASECOMIS*100,3)
         _nperger := iif(_nperger<0,-1*_nperger,_nperger)   

         _nPerGnc := round(_nComGnc/(_cAlias)->BASECOMIS*100,3)
         _nPerGnc := iif(_nPerGnc<0,-1*_nPerGnc,_nPerGnc)   
				
         _dtemissao := iif(!empty((_cAlias)->DTEMISSAO),stod((_cAlias)->DTEMISSAO),"")
         _dtbaixa := iif(!empty((_cAlias)->DTBAIXA),stod((_cAlias)->DTBAIXA),"")
			
         //verifica se tem duplicata
         If Empty(MV_PAR07) .Or. ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07) // Imprime todos os dados
            _npl :=  ascan(_adados,{|_vAux|	_vAux[1]  == (_cAlias)->FILIAL .and. ;
											_vAux[2]  == (_cAlias)->TIPO .and. ;
											_vAux[3]  == _dtemissao .and. ;
											_vAux[4]  == _dtbaixa .and. ;
											_vAux[5]  == (_cAlias)->NUMERO .and. ;
											_vAux[6]  == (_cAlias)->PARCELA .and. ;
											_vAux[7]  == _cCodGrupo .and. ;
											_vAux[8]  == _cDescGrupo .and. ;
											_vAux[9]  == (_cAlias)->CODCLI .and. ;
											_vAux[10] == (_cAlias)->LOJA .and. ;
											_vAux[11] == _cRazaoCli .AND. ;
											_vAux[37] == (_cAlias)->SEQ })

        ElseIf ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07) .Or. ; // N�o imprime vendedor   
               ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07) .Or. ; // N�o imprime supervisor 
               ("G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07) .Or. ; // N�o imprime Coordenador 
               (! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07) .Or. ; // N�o imprime gerente 
               ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07)        // N�o imprime gerente nacional 

            _npl :=  ascan(_adados,{|_vAux|	_vAux[1]  == (_cAlias)->FILIAL .and. ;
											_vAux[2]  == (_cAlias)->TIPO .and. ;
											_vAux[3]  == _dtemissao .and. ;
											_vAux[4]  == _dtbaixa .and. ;
											_vAux[5]  == (_cAlias)->NUMERO .and. ;
											_vAux[6]  == (_cAlias)->PARCELA .and. ;
											_vAux[7]  == _cCodGrupo .and. ;
											_vAux[8]  == _cDescGrupo .and. ;
											_vAux[9]  == (_cAlias)->CODCLI .and. ;
											_vAux[10] == (_cAlias)->LOJA .and. ;
											_vAux[11] == _cRazaoCli .AND. ;
											_vAux[33] == (_cAlias)->SEQ })
         Else
            _npl :=  ascan(_adados,{|_vAux|	_vAux[1]  == (_cAlias)->FILIAL .and. ;
											_vAux[2]  == (_cAlias)->TIPO .and. ;
											_vAux[3]  == _dtemissao .and. ;
											_vAux[4]  == _dtbaixa .and. ;
											_vAux[5]  == (_cAlias)->NUMERO .and. ;
											_vAux[6]  == (_cAlias)->PARCELA .and. ;
											_vAux[7]  == _cCodGrupo .and. ;
											_vAux[8]  == _cDescGrupo .and. ;
											_vAux[9]  == (_cAlias)->CODCLI .and. ;
											_vAux[10] == (_cAlias)->LOJA .and. ;
											_vAux[11] == _cRazaoCli .AND. ;
											_vAux[21] == (_cAlias)->SEQ }) 
         EndIf

         If _npl == 0 //S� incrementa se n�o tiver no array
		    //===============================================
			// Incrementa array para gera��o de excel
			//===============================================		  	
            If Empty(MV_PAR07) .Or. ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07) // Imprime todos os dados
               Aadd(_adados,{(_cAlias)->FILIAL	,;	             					 //01
							 (_cAlias)->TIPO,;										 //02
			 				 _dtemissao,;											 //03
			 				 _dtbaixa,;												 //04
			 				 (_cAlias)->NUMERO,;									 //05
							 (_cAlias)->PARCELA,;									 //06
							 _cCodGrupo ,;											 //07
							 _cDescGrupo,;											 //08
							 (_cAlias)->CODCLI,;									 //09
							 (_cAlias)->LOJA,;										 //10
							 _cRazaoCli,;											 //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	 //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),; //13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	 //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			 //16
							 _ccodrep,;												 //17
							 _cnomerep,;											 //18
							 _ccodsup,;												 //19
							 _cnomesup,;											 //20
							 _ccodcoord,;											 //21
							 _cnomecoord,;											 //22
							 _ccodger,;												 //23
							 _cnomeger,;											 //24
                             _cCodGNc,;                                              //25
							 _cNomeGnc,;                                             //26
							 U_ROMS025I(_ncomrep,"@E 999,999,999.999"),;			 //25-->27
							 U_ROMS025I(_nperrep,"@E 999,999,999.999"),;			 //26-->28
							 U_ROMS025I(_ncomsup,"@E 999,999,999.999"),;			 //27-->29
							 U_ROMS025I(_npersup,"@E 999,999,999.999"),;			 //28-->30
							 U_ROMS025I(_ncomcoord,"@E 999,999,999.999"),;			 //29-->31
							 U_ROMS025I(_npercoo,"@E 999,999,999.999"),;			 //30-->32
							 U_ROMS025I(_ncomger,"@E 999,999,999.999"),;			 //31-->33
							 U_ROMS025I(_nperger,"@E 999,999,999.999"),;			 //32-->34
                             U_ROMS025I(_nComGnc,"@E 999,999,999.999"),;			 //35
							 U_ROMS025I(_nPerGnc,"@E 999,999,999.999"),;			 //36
							 (_cAlias)->SEQ,;                                         //33-->37
                      U_ROMS025I((_cAlias)->(SE5DCT+SE5VRB+COMPENSACAO),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  
							})
							
            ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07//  N�o imprime vendedor
               aadd(_adados,{(_cAlias)->FILIAL	,;							         //01
							 (_cAlias)->TIPO,;										 //02
			 				 _dtemissao,;											 //03
			 				 _dtbaixa,;												 //04
			 				 (_cAlias)->NUMERO,;									 //05
							 (_cAlias)->PARCELA,;									 //06
							 _cCodGrupo ,;											 //07
							 _cDescGrupo,;											 //08
							 (_cAlias)->CODCLI,;									 //09
							 (_cAlias)->LOJA,;										 //10
							 _cRazaoCli,;											 //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	 //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),; //13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	 //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			 //16
							 _ccodsup,;												 //17
							 _cnomesup,;											 //18
							 _ccodcoord,;											 //19
							 _cnomecoord,;											 //20
							 _ccodger,;												 //21
							 _cnomeger,;										     //22
                             _cCodGNc,;                                              //23
							 _cNomeGnc,;                                             //24
							 U_ROMS025I(_ncomsup,"@E 999,999,999.999"),;			 //23-->25
							 U_ROMS025I(_npersup,"@E 999,999,999.999"),;			 //24-->26
							 U_ROMS025I(_ncomcoord,"@E 999,999,999.999"),;		     //25-->27
							 U_ROMS025I(_npercoo,"@E 999,999,999.999"),;			 //26-->28
							 U_ROMS025I(_ncomger,"@E 999,999,999.999"),;			 //27-->29
							 U_ROMS025I(_nperger,"@E 999,999,999.999"),;			 //28-->30
                             U_ROMS025I(_nComGnc,"@E 999,999,999.999"),;			 //31
							 U_ROMS025I(_nPerGnc,"@E 999,999,999.999"),;			 //32
							 (_cAlias)->SEQ,;                                         //29-->33
                      U_ROMS025I((_cAlias)->(SE5DCT+SE5VRB+COMPENSACAO),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  
							})
            ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07// N�o imprime supervisor
               aadd(_adados,{(_cAlias)->FILIAL	,;							         //01
							 (_cAlias)->TIPO,;										 //02
			 				 _dtemissao,;											 //03
			 				 _dtbaixa,;												 //04
			 				 (_cAlias)->NUMERO,;									 //05
							 (_cAlias)->PARCELA,;									 //06
							 _cCodGrupo ,;											 //07
							 _cDescGrupo,;											 //08
							 (_cAlias)->CODCLI,;									 //09
							 (_cAlias)->LOJA,;										 //10
							 _cRazaoCli,;											 //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	 //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),; //13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	 //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			 //16
							 _ccodrep,;												 //17
							 _cnomerep,;											 //18
							 _ccodcoord,;											 //19
							 _cnomecoord,;											 //20
							 _ccodger,;												 //21
							 _cnomeger,;											 //22
                             _cCodGNc,;                                              //23
							 _cNomeGnc,;                                             //24
							 U_ROMS025I(_ncomrep,"@E 999,999,999.999"),;			 //23-->25
							 U_ROMS025I(_nperrep,"@E 999,999,999.999"),;			 //24-->26
							 U_ROMS025I(_ncomcoord,"@E 999,999,999.999"),;			 //25-->27
							 U_ROMS025I(_npercoo,"@E 999,999,999.999"),;			 //26-->28
							 U_ROMS025I(_ncomger,"@E 999,999,999.999"),;			 //27-->29
							 U_ROMS025I(_nperger,"@E 999,999,999.999"),;			 //28-->30
                             U_ROMS025I(_nComGnc,"@E 999,999,999.999"),;			 //31
							 U_ROMS025I(_nPerGnc,"@E 999,999,999.999"),;			 //32
							 (_cAlias)->SEQ,;                                         //29-->33
                      U_ROMS025I((_cAlias)->(SE5DCT+SE5VRB+COMPENSACAO),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  
							 })
            ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07// N�o imprime Coordenador
               aadd(_adados,{(_cAlias)->FILIAL	,;							         //01
							 (_cAlias)->TIPO,;										 //02
			 				 _dtemissao,;											 //03
			 				 _dtbaixa,;												 //04
			 				 (_cAlias)->NUMERO,;									 //05
							 (_cAlias)->PARCELA,;									 //06
							 _cCodGrupo ,;											 //07
							 _cDescGrupo,;											 //08
							 (_cAlias)->CODCLI,;									 //09
							 (_cAlias)->LOJA,;										 //10
							 _cRazaoCli,;											 //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	 //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),; //13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	 //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			 //16
							 _ccodrep,;												 //17
							 _cnomerep,;											 //18
							 _ccodsup,;												 //19
							 _cnomesup,;										     //20
							 _ccodger,;												 //21
							 _cnomeger,;										     //22
                             _cCodGNc,;                                              //23
							 _cNomeGnc,;                                             //24
							 U_ROMS025I(_ncomrep,"@E 999,999,999.999"),;				 //23-->25
							 U_ROMS025I(_nperrep,"@E 999,999,999.999"),;				 //24-->26
							 U_ROMS025I(_ncomsup,"@E 999,999,999.999"),;				 //25-->27
							 U_ROMS025I(_npersup,"@E 999,999,999.999"),;				 //26-->28
							 U_ROMS025I(_ncomger,"@E 999,999,999.999"),;				 //27-->29
							 U_ROMS025I(_nperger,"@E 999,999,999.999"),;				 //28-->30
                             U_ROMS025I(_nComGnc,"@E 999,999,999.999"),;			 //31
							 U_ROMS025I(_nPerGnc,"@E 999,999,999.999"),;			 //32
							 (_cAlias)->SEQ,;                                         //29-->33
                      U_ROMS025I((_cAlias)->(SE5DCT+SE5VRB+COMPENSACAO),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  
							}) 
            ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07// N�o imprime gerente
               aadd(_adados,{(_cAlias)->FILIAL	,;							         //01
							 (_cAlias)->TIPO,;										 //02
			 				 _dtemissao,;											 //03
			 				 _dtbaixa,;												 //04
			 				 (_cAlias)->NUMERO,;									 //05
							 (_cAlias)->PARCELA,;									 //06
							 _cCodGrupo ,;											 //07
							 _cDescGrupo,;											 //08
							 (_cAlias)->CODCLI,;									 //09
							 (_cAlias)->LOJA,;										 //10
							 _cRazaoCli,;											 //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	 //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),; //13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	 //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			 //16
							 _ccodrep,;												 //17
							 _cnomerep,;											 //18
							 _ccodsup,;												 //19
							 _cnomesup,;										 	 //20
							 _ccodcoord,;											 //21
							 _cnomecoord,;											 //22
                             _cCodGNc,;                                              //23
							 _cNomeGnc,;                                             //24
							 U_ROMS025I(_ncomrep,"@E 999,999,999.999"),;				 //23-->25
							 U_ROMS025I(_nperrep,"@E 999,999,999.999"),;				 //24-->26
							 U_ROMS025I(_ncomsup,"@E 999,999,999.999"),;				 //25-->27
							 U_ROMS025I(_npersup,"@E 999,999,999.999"),;				 //26-->28
							 U_ROMS025I(_ncomcoord,"@E 999,999,999.999"),;		 	 //27-->29
							 U_ROMS025I(_npercoo,"@E 999,999,999.999"),;				 //28-->30
                             U_ROMS025I(_nComGnc,"@E 999,999,999.999"),;			 //31
							 U_ROMS025I(_nPerGnc,"@E 999,999,999.999"),;			 //32
							 (_cAlias)->SEQ,;                                         //29-->33
                      U_ROMS025I((_cAlias)->(SE5DCT+SE5VRB+COMPENSACAO),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  
							 })
            ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07// N�o imprime gerente nacional
               aadd(_adados,{(_cAlias)->FILIAL	,;							         //01
							 (_cAlias)->TIPO,;										 //02
			 				 _dtemissao,;											 //03
			 				 _dtbaixa,;												 //04
			 				 (_cAlias)->NUMERO,;									 //05
							 (_cAlias)->PARCELA,;									 //06
							 _cCodGrupo ,;											 //07
							 _cDescGrupo,;											 //08
							 (_cAlias)->CODCLI,;									 //09
							 (_cAlias)->LOJA,;										 //10
							 _cRazaoCli,;											 //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	 //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),; //13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	 //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			 //16
							 _ccodrep,;												 //17
							 _cnomerep,;											 //18
							 _ccodsup,;												 //19
							 _cnomesup,;										 	 //20
							 _ccodcoord,;											 //21
							 _cnomecoord,;											 //22
							 _ccodger,;												 //23
							 _cnomeger,;										     //24
							 U_ROMS025I(_ncomrep,"@E 999,999,999.999"),;				 //23-->25
							 U_ROMS025I(_nperrep,"@E 999,999,999.999"),;				 //24-->26
							 U_ROMS025I(_ncomsup,"@E 999,999,999.999"),;				 //25-->27
							 U_ROMS025I(_npersup,"@E 999,999,999.999"),;				 //26-->28
							 U_ROMS025I(_ncomcoord,"@E 999,999,999.999"),;		 	 //27-->29
							 U_ROMS025I(_npercoo,"@E 999,999,999.999"),;				 //28-->30
							 U_ROMS025I(_ncomger,"@E 999,999,999.999"),;				 //31
							 U_ROMS025I(_nperger,"@E 999,999,999.999"),;				 //32
							 (_cAlias)->SEQ,;                                         //29-->33
                      U_ROMS025I((_cAlias)->(SE5DCT+SE5VRB+COMPENSACAO),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  
							 })

            ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // imprime apenas gerente nacional
               aadd(_adados,{(_cAlias)->FILIAL	,;							         //01
							 (_cAlias)->TIPO,;										 //02
			 				 _dtemissao,;											 //03
			 				 _dtbaixa,;												 //04
			 				 (_cAlias)->NUMERO,;									 //05
							 (_cAlias)->PARCELA,;									 //06
							 _cCodGrupo ,;											 //07
							 _cDescGrupo,;											 //08
							 (_cAlias)->CODCLI,;									 //09
							 (_cAlias)->LOJA,;										 //10
							 _cRazaoCli,;											 //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	 //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),; //13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	 //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			 //16
							 _cCodGNc,;                                              //17
			                 _cNomeGnc,;                                             //18
							 U_ROMS025I(_nComGnc,"@E 999,999,999.999"),;			 //19
							 U_ROMS025I(_nPerGnc,"@E 999,999,999.999"),;			 //20
							 (_cAlias)->SEQ,;                                         //21
                      U_ROMS025I((_cAlias)->(SE5DCT+SE5VRB+COMPENSACAO),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  
							})
//------------------------------------------------------------------------------------------------------------------------------
            ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07  // imprime apenas gerente
               aadd(_adados,{(_cAlias)->FILIAL	,;							         //01
							 (_cAlias)->TIPO,;										 //02
			 				 _dtemissao,;											 //03
			 				 _dtbaixa,;												 //04
			 				 (_cAlias)->NUMERO,;									 //05
							 (_cAlias)->PARCELA,;									 //06
							 _cCodGrupo ,;											 //07
							 _cDescGrupo,;											 //08
							 (_cAlias)->CODCLI,;									 //09
							 (_cAlias)->LOJA,;										 //10
							 _cRazaoCli,;											 //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	 //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),; //13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	 //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			 //16
							 _ccodger,;												 //17
							 _cnomeger,;											 //18
							 U_ROMS025I(_ncomger,"@E 999,999,999.999"),;				 //19
							 U_ROMS025I(_nperger,"@E 999,999,999.999"),;				 //20
							 (_cAlias)->SEQ,;                                         //21
                      U_ROMS025I((_cAlias)->(SE5DCT+SE5VRB+COMPENSACAO),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  
							})
            ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas Coordenador
           	   aadd(_adados,{(_cAlias)->FILIAL	,;							         //01
							 (_cAlias)->TIPO,;										 //02
			 				 _dtemissao,;											 //03
			 				 _dtbaixa,;												 //04
			 				 (_cAlias)->NUMERO,;									 //05
							 (_cAlias)->PARCELA,;									 //06
							 _cCodGrupo ,;											 //07
							 _cDescGrupo,;											 //08
							 (_cAlias)->CODCLI,;									 //09
							 (_cAlias)->LOJA,;										 //10
							 _cRazaoCli,;											 //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	 //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),; //13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	 //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			 //16
							 _ccodcoord,;											 //17
							 _cnomecoord,;											 //18
							 U_ROMS025I(_ncomcoord,"@E 999,999,999.999"),;			 //19
							 U_ROMS025I(_npercoo,"@E 999,999,999.999"),;				 //20
							 (_cAlias)->SEQ,;                                         //21
                      U_ROMS025I((_cAlias)->(SE5DCT+SE5VRB+COMPENSACAO),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  
							})
            ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas supervisor
               aadd(_adados,{(_cAlias)->FILIAL	,;							         //01
							 (_cAlias)->TIPO,;										 //02
			 				 _dtemissao,;											 //03
			 				 _dtbaixa,;												 //04
			 				 (_cAlias)->NUMERO,;									 //05
							 (_cAlias)->PARCELA,;									 //06
							 _cCodGrupo ,;											 //07
							 _cDescGrupo,;											 //08
							 (_cAlias)->CODCLI,;									 //09
							 (_cAlias)->LOJA,;										 //10
							 _cRazaoCli,;											 //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	 //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),; //13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	 //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			 //16
							 _ccodsup,;												 //17
							 _cnomesup,;											 //18
							 U_ROMS025I(_ncomsup,"@E 999,999,999.999"),;				 //19
							 U_ROMS025I(_npersup,"@E 999,999,999.999"),;				 //20
							 (_cAlias)->SEQ,;                                         //21
                      U_ROMS025I((_cAlias)->(SE5DCT+SE5VRB+COMPENSACAO),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  
							})						
            ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas vendedor
               aadd(_adados,{(_cAlias)->FILIAL	,;						             //01
							 (_cAlias)->TIPO,;										 //02
			 				 _dtemissao,;											 //03
			 				 _dtbaixa,;												 //04
			 				 (_cAlias)->NUMERO,;									 //05
							 (_cAlias)->PARCELA,;									 //06
							 _cCodGrupo ,;											 //07
							 _cDescGrupo,;											 //08
							 (_cAlias)->CODCLI,;									 //09
							 (_cAlias)->LOJA,;										 //10
							 _cRazaoCli,;											 //11
							 U_ROMS025I((_cAlias)->VLRTITULO,"@E 999,999,999.99"),;	 //12
							 U_ROMS025I((_cAlias)->COMPENSACAO,"@E 999,999,999.99"),; //13
							 U_ROMS025I((_cAlias)->DESCONTO,"@E 999,999,999.99"),;	 //14
							 U_ROMS025I((_cAlias)->BAIXASANT,"@E 999,999,999.99"),;	 //15
							 U_ROMS025I(_nbasecomis,"@E 999,999,999.99"),;			 //16
							 _ccodrep,;												 //17
							 _cnomerep,;											 //18
							 U_ROMS025I(_ncomrep,"@E 999,999,999.999"),;				 //19
							 U_ROMS025I(_nperrep,"@E 999,999,999.999"),;				 //20
							 (_cAlias)->SEQ,;                                         //21
                      U_ROMS025I((_cAlias)->(SE5DCT+SE5VRB+COMPENSACAO),"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5DCT,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->SE5VRB,"@E 999,999,999.999"),;
                      U_ROMS025I((_cAlias)->VALST,"@E 999,999,999.999");  
							})							
            Else // N�o exibe dados do relat�rio em excel.
               _adados := {}		
            EndIf							  	
		 EndIf

		 //=======================================================================================================
		 // Chama a rotina para selecao dos registros da comissao.												
		 //=======================================================================================================
		 MV_PAR06 := (_cAlias)->CODVEND   // Filtro codigo do Vendedor 
		 fwMsgRun(,{|oproc|ROMS025QRY(_cAlias3,3,oproc)},"Aguarde....","Filtrando os dados bonifica��o.")    
		
		 _nTotReg := 0 
		 		
  		 DBSelectArea(_cAlias3)
		 (_cAlias3)->( DBGoTop() )
		 (_cAlias3)->( DBEval( {|| _nTotReg++ } ) )
		 (_cAlias3)->( DBGoTop() )

		 If _nTotReg > 0
			_nConAux := 0
			Do While (_cAlias3)->( !Eof() )
			   _nConAux++
			   oproc:cCaption := 'Processando bonifica��es... ['+ StrZero(_nConAux,9) +'] de ['+ StrZero(_nTotReg,9) +'].'
			   ProcessMessages()

 			   _cRazaoCli  := Posicione("SA1",1,xFilial("SA1")+(_cAlias3)->F2_CLIENTE+(_cAlias3)->F2_LOJA,"A1_NOME")
			   _cCodGrupo  := Posicione("SA1",1,xFilial("SA1")+(_cAlias3)->F2_CLIENTE+(_cAlias3)->F2_LOJA,"A1_GRPVEN")
			   _cDescGrupo := Posicione("ACY",1,xFilial("ACY")+_cCodGrupo,"ACY_DESCRI")
			   _cCodVen := (_cAlias3)->F2_VEND1
			   _ccodsup :=  (_cAlias3)->F2_VEND4
			   _cnomesup := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodsup)),SA3->A3_NOME," ")
			   _ccodcoord := (_cAlias3)->F2_VEND2
			   _cnomecoord := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodcoord)),SA3->A3_NOME," ")
		       _ccodger := (_cAlias3)->F2_VEND3
			   _cnomeger := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodger)),SA3->A3_NOME," ")
			   
			   _cCodGNc  := (_cAlias3)->F2_VEND5
			   _cNomeGnc := IIF(SA3->(Dbseek(xFilial("SA3")+_cCodGNc)),SA3->A3_NOME," ")

			   If ascan(_adados, {|_vAux| _vAux[1]==(_cAlias3)->F2_FILIAL .and. _vAux[2]=="BON" .and. _vAux[5]==(_cAlias3)->F2_DOC}) ==  0
				  // Incrementa array para gera��o de excel
                  If Empty(MV_PAR07) .Or. ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07) // Imprime todos os dados
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                          //01
								   "BON",;													                              //02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                  //03
								   "  ",;													                              //04
								   (_cAlias3)->F2_DOC,;									                                  //05
								   "  ",;													                              //06
								   _cCodGrupo ,;											                              //07
								   _cDescGrupo,;											                              //08
								   (_cAlias3)->F2_CLIENTE,;								                                  //09
								   (_cAlias3)->F2_LOJA,;									                              //10
								   _cRazaoCli,;											                                  //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									  //12
							       U_ROMS025I(0,"@E 999,999,999.99"),;													  //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													  //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													  //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							      //16
								   _cCodVen,;												                              //17
								   POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                              //18
								   _ccodsup,;												                              //19
								   _cnomesup,;												                              //20
								   _ccodcoord,;											                                  //21
								   _cnomecoord,;											                              //22
								   _ccodger,;												                              //23
								   _cnomeger,;												                              //24
								   _cCodGNc,;                                                                             //25
			                       _cNomeGnc,;                                                                            //26
								   U_ROMS025I(round((_cAlias3)->COMIS1/-100,3),"@E 999,999,999.999"),;					  //25-->27
								   U_ROMS025I(round((_cAlias3)->COMIS1/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		  //26-->28
								   U_ROMS025I(round((_cAlias3)->COMIS4/-100,3),"@E 999,999,999.999"),;					  //27-->29
								   U_ROMS025I(round((_cAlias3)->COMIS4/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		  //28-->30
								   U_ROMS025I(round((_cAlias3)->COMIS2/-100,3),"@E 999,999,999.999"),;					  //29-->31
								   U_ROMS025I(round((_cAlias3)->COMIS2/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		  //30-->32
								   U_ROMS025I(round((_cAlias3)->COMIS3/-100,3),"@E 999,999,999.999"),;					  //31-->33
								   U_ROMS025I(round((_cAlias3)->COMIS3/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		  //32-->34
								   U_ROMS025I(round((_cAlias3)->COMIS5/-100,3),"@E 999,999,999.999"),;					  //35
								   U_ROMS025I(round((_cAlias3)->COMIS5/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		  //36
								   " ",;                                                                                   //33-->37
                            U_ROMS025I((_cAlias3)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  
								   })

                  ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07 //  N�o imprime vendedor
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                           //01
								   "BON",;													                               //02
							       DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   //03
								   "  ",;													                               //04
								   (_cAlias3)->F2_DOC,;									                                   //05
								   "  ",;													                               //06
								   _cCodGrupo ,;											                               //07
								   _cDescGrupo,;											                               //08
								   (_cAlias3)->F2_CLIENTE,;								                                   //09
								   (_cAlias3)->F2_LOJA,;									                               //10
								   _cRazaoCli,;											                                   //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									   //12
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							       //16
								   _ccodsup,;												                               //17
								   _cnomesup,;												                               //18
								   _ccodcoord,;											                                   //19
								   _cnomecoord,;											                               //20
								   _ccodger,;												                               //21
								   _cnomeger,;												                               //22
								   _cCodGNc,;                                                                              //23
			                       _cNomeGnc,;                                                                             //24
								   U_ROMS025I(round((_cAlias3)->COMIS4/-100,3),"@E 999,999,999.999"),;					   //23-->25
								   U_ROMS025I(round((_cAlias3)->COMIS4/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //24-->26
								   U_ROMS025I(round((_cAlias3)->COMIS2/-100,3),"@E 999,999,999.999"),;					   //25-->27
								   U_ROMS025I(round((_cAlias3)->COMIS2/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //26-->28
								   U_ROMS025I(round((_cAlias3)->COMIS3/-100,3),"@E 999,999,999.999"),;					   //27-->29
								   U_ROMS025I(round((_cAlias3)->COMIS3/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //28-->30
								   U_ROMS025I(round((_cAlias3)->COMIS5/-100,3),"@E 999,999,999.999"),;					   //31
								   U_ROMS025I(round((_cAlias3)->COMIS5/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //32
								   " ",;                                                                                    //29-->33
                            U_ROMS025I((_cAlias3)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  
							       })

                  ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime supervisor
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                           //01
								   "BON",;													                               //02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   //03
								   "  ",;													                               //04
								   (_cAlias3)->F2_DOC,;									                                   //05
								   "  ",;													                               //06
								   _cCodGrupo ,;											                               //07
								   _cDescGrupo,;											                               //08
								   (_cAlias3)->F2_CLIENTE,;								                                   //09
								   (_cAlias3)->F2_LOJA,;									                               //10
								   _cRazaoCli,;											                                   //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									   //12
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							       //16
								   _cCodVen,;												                               //17
								   POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                               //18
								   _ccodcoord,;											                                   //19
								   _cnomecoord,;											                               //20
								   _ccodger,;												                               //21
								   _cnomeger,;												                               //22
								   _cCodGNc,;                                                                              //23
			                       _cNomeGnc,;                                                                             //24
								   U_ROMS025I(round((_cAlias3)->COMIS1/-100,3),"@E 999,999,999.999"),;					   //23-->25
								   U_ROMS025I(round((_cAlias3)->COMIS1/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //24-->26
								   U_ROMS025I(round((_cAlias3)->COMIS2/-100,3),"@E 999,999,999.999"),;					   //25-->27
								   U_ROMS025I(round((_cAlias3)->COMIS2/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //26-->28
								   U_ROMS025I(round((_cAlias3)->COMIS3/-100,3),"@E 999,999,999.999"),;					   //27-->29
								   U_ROMS025I(round((_cAlias3)->COMIS3/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //28-->30
								   U_ROMS025I(round((_cAlias3)->COMIS5/-100,3),"@E 999,999,999.999"),;					   //31
								   U_ROMS025I(round((_cAlias3)->COMIS5/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //32
								   " ",;                                                                                    //29-->33
                            U_ROMS025I((_cAlias3)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  
							 	   })

                  ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime Coordenador
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                           //01
								   "BON",;													                               //02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   //03
								   "  ",;													                               //04
								   (_cAlias3)->F2_DOC,;									                                   //05
								   "  ",;													                               //06
								   _cCodGrupo ,;											                               //07
								   _cDescGrupo,;											                               //08
								   (_cAlias3)->F2_CLIENTE,;								                                   //09
								   (_cAlias3)->F2_LOJA,;									                               //10
								   _cRazaoCli,;											                                   //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									   //12
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							       //16
								   _cCodVen,;												                               //17
								   POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                               //18
								   _ccodsup,;												                               //19
								   _cnomesup,;												                               //20
								   _ccodger,;												                               //21
								   _cnomeger,;												                               //22 
								   _cCodGNc,;                                                                              //23
			                       _cNomeGnc,;                                                                             //24
								   U_ROMS025I(round((_cAlias3)->COMIS1/-100,3),"@E 999,999,999.999"),;					   //23-->25
								   U_ROMS025I(round((_cAlias3)->COMIS1/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //24-->26
								   U_ROMS025I(round((_cAlias3)->COMIS4/-100,3),"@E 999,999,999.999"),;					   //25-->27
								   U_ROMS025I(round((_cAlias3)->COMIS4/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //26-->28
								   U_ROMS025I(round((_cAlias3)->COMIS3/-100,3),"@E 999,999,999.999"),;					   //27-->29
								   U_ROMS025I(round((_cAlias3)->COMIS3/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //28-->30
								   U_ROMS025I(round((_cAlias3)->COMIS5/-100,3),"@E 999,999,999.999"),;					   //31
								   U_ROMS025I(round((_cAlias3)->COMIS5/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //32
								   " ",;                                                                                    //29-->33
                            U_ROMS025I((_cAlias3)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  
								   })

                  ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime gerente
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                           //01
								   "BON",;													                               //02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   //03
								   "  ",;													                               //04
								   (_cAlias3)->F2_DOC,;									                                   //05
								   "  ",;													                               //06
								   _cCodGrupo ,;											                               //07
								   _cDescGrupo,;											                               //08
								   (_cAlias3)->F2_CLIENTE,;								                                   //09
								   (_cAlias3)->F2_LOJA,;									                               //10
								   _cRazaoCli,;											                                   //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									   //12
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							       //16
								   _cCodVen,;												                               //17
								   POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                               //18
								   _ccodsup,;												                               //19
								   _cnomesup,;												                               //20
								   _ccodcoord,;											                                   //21
								   _cnomecoord,;											                               //22
								   _cCodGNc,;                                                                              //23
			                       _cNomeGnc,;                                                                             //24
								   U_ROMS025I(round((_cAlias3)->COMIS1/-100,3),"@E 999,999,999.999"),;					   //23-->25
								   U_ROMS025I(round((_cAlias3)->COMIS1/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //24-->26
								   U_ROMS025I(round((_cAlias3)->COMIS4/-100,3),"@E 999,999,999.999"),;					   //25-->27
								   U_ROMS025I(round((_cAlias3)->COMIS4/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //26-->28
								   U_ROMS025I(round((_cAlias3)->COMIS2/-100,3),"@E 999,999,999.999"),;					   //27-->29
								   U_ROMS025I(round((_cAlias3)->COMIS2/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //28-->30
								   U_ROMS025I(round((_cAlias3)->COMIS5/-100,3),"@E 999,999,999.999"),;					   //31
								   U_ROMS025I(round((_cAlias3)->COMIS5/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //32
								   " ",;                                                                                    //29-->33
                            U_ROMS025I((_cAlias3)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  
								   })

//-------------------------------------------------------------------------------------------------------------------------------
ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // N�o imprime gerente nacional.
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                           //01
								   "BON",;													                               //02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   //03
								   "  ",;													                               //04
								   (_cAlias3)->F2_DOC,;									                                   //05
								   "  ",;													                               //06
								   _cCodGrupo ,;											                               //07
								   _cDescGrupo,;											                               //08
								   (_cAlias3)->F2_CLIENTE,;								                                   //09
								   (_cAlias3)->F2_LOJA,;									                               //10
								   _cRazaoCli,;											                                   //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									   //12
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							       //16
								   _cCodVen,;												                               //17
								   POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                               //18
								   _ccodsup,;												                               //19
								   _cnomesup,;												                               //20
								   _ccodcoord,;											                                   //21
								   _cnomecoord,;											                               //22
								   _ccodger,;												                               //23
								   _cnomeger,;												                               //24 
								   U_ROMS025I(round((_cAlias3)->COMIS1/-100,3),"@E 999,999,999.999"),;					   //23-->25
								   U_ROMS025I(round((_cAlias3)->COMIS1/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //24-->26
								   U_ROMS025I(round((_cAlias3)->COMIS4/-100,3),"@E 999,999,999.999"),;					   //25-->27
								   U_ROMS025I(round((_cAlias3)->COMIS4/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //26-->28
								   U_ROMS025I(round((_cAlias3)->COMIS2/-100,3),"@E 999,999,999.999"),;					   //27-->29
								   U_ROMS025I(round((_cAlias3)->COMIS2/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //28-->30
								   U_ROMS025I(round((_cAlias3)->COMIS3/-100,3),"@E 999,999,999.999"),;					   //31
								   U_ROMS025I(round((_cAlias3)->COMIS3/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //32
								   " ",;                                                                                    //29-->33
                            U_ROMS025I((_cAlias3)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  
								   })
//-------------------------------------------------------------------------------------------------------------------------------
                  ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // imprime apenas gerente nacional
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                           //01
								   "BON",;													                               //02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   //03
								   "  ",;													                               //04
								   (_cAlias3)->F2_DOC,;									                                   //05
								   "  ",;													                               //06
								   _cCodGrupo ,;											                               //07
								   _cDescGrupo,;											                               //08
								   (_cAlias3)->F2_CLIENTE,;								                                   //09
								   (_cAlias3)->F2_LOJA,;									                               //10
								   _cRazaoCli,;											                                   //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									   //12
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							       //16
								   _cCodGNc,;                                                                              //17
			                       _cNomeGnc,;                                                                             //18
								   U_ROMS025I(round((_cAlias3)->COMIS5/-100,3),"@E 999,999,999.999"),;					   //19
								   U_ROMS025I(round((_cAlias3)->COMIS5/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //20
								   " ",;                                                                                    //21
                            U_ROMS025I((_cAlias3)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  
							    	})
//-----------------------------------------------------------------------------------------------------------------------------------------------
                  ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas gerente
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                           //01
								   "BON",;													                               //02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   //03
								   "  ",;													                               //04
								   (_cAlias3)->F2_DOC,;									                                   //05
								   "  ",;													                               //06
								   _cCodGrupo ,;											                               //07
								   _cDescGrupo,;											                               //08
								   (_cAlias3)->F2_CLIENTE,;								                                   //09
								   (_cAlias3)->F2_LOJA,;									                               //10
								   _cRazaoCli,;											                                   //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									   //12
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							       //16
								   _ccodger,;												                               //17
								   _cnomeger,;												                               //18
								   U_ROMS025I(round((_cAlias3)->COMIS3/-100,3),"@E 999,999,999.999"),;					   //19
								   U_ROMS025I(round((_cAlias3)->COMIS3/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //20
								   " ",;                                                                                    //21
                            U_ROMS025I((_cAlias3)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  
							    	})
                  ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas Coordenador
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                           //01
							       "BON",;													                               //02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   //03
								   "  ",;													                               //04
								   (_cAlias3)->F2_DOC,;									                                   //05
								   "  ",;													                               //06
								   _cCodGrupo ,;											                               //07
								   _cDescGrupo,;											                               //08
								   (_cAlias3)->F2_CLIENTE,;								                                   //09
								   (_cAlias3)->F2_LOJA,;									                               //10
								   _cRazaoCli,;											                                   //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									   //12
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							       //16
								   _ccodcoord,;											                                   //17
								   _cnomecoord,;											                               //18
								   U_ROMS025I(round((_cAlias3)->COMIS2/-100,3),"@E 999,999,999.999"),;					   //19
								   U_ROMS025I(round((_cAlias3)->COMIS2/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;		   //20
								   " ",;                                                                                    //21
                            U_ROMS025I((_cAlias3)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  
								   })
                  ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas supervisor
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                           //01
								   "BON",;													                               //02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   //03
								   "  ",;													                               //04
								   (_cAlias3)->F2_DOC,;									                                   //05
								   "  ",;													                               //06
								   _cCodGrupo ,;											                               //07
								   _cDescGrupo,;											                               //08
								   (_cAlias3)->F2_CLIENTE,;								                                   //09
								   (_cAlias3)->F2_LOJA,;									                               //10
								   _cRazaoCli,;											                                   //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									   //12
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							       //16
								   _ccodsup,;												                               //17
								   _cnomesup,;												                               //18
								   U_ROMS025I(round((_cAlias3)->COMIS4/-100,3),"@E 999,999,999.999"),;					   //19
				    			   U_ROMS025I(round((_cAlias3)->COMIS4/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //20
								   " ",;                                                                                    //21
                            U_ROMS025I((_cAlias3)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  
								   })
                  ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas vendedor
				     Aadd(_adados,{(_cAlias3)->F2_FILIAL	,;					                                           //01
								   "BON",;													                               //02
								   DTOC(stod((_cAlias3)->F2_EMISSAO)),;					                                   //03
								   "  ",;													                               //04
								   (_cAlias3)->F2_DOC,;									                                   //05
								   "  ",;													                               //06
								   _cCodGrupo ,;											                               //07
								   _cDescGrupo,;											                               //08
								   (_cAlias3)->F2_CLIENTE,;								                                   //09
								   (_cAlias3)->F2_LOJA,;									                               //10
								   _cRazaoCli,;											                                   //11
								   U_ROMS025I((_cAlias3)->VALTOT,"@E 999,999,999.99"),;									   //12
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
								   U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
								   U_ROMS025I((_cAlias3)->VALTOT*-1,"@E 999,999,999.99"),;							       //16
								   _cCodVen,;												                               //17
								   POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                               //18
								   U_ROMS025I(round((_cAlias3)->COMIS1/-100,3),"@E 999,999,999.999"),;					   //19
								   U_ROMS025I(round((_cAlias3)->COMIS1/(_cAlias3)->VALTOT,3),"@E 999,999,999.999"),;	   //20
								   " ",;                                                                                    //21
                            U_ROMS025I((_cAlias3)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias3)->VALST,"@E 999,999,999.999");  
							 	   })
                  Else // N�o exibe dados do relat�rio em excel.
                     _adados := {}		
                  EndIf
			   EndIf
			   
			   (_cAlias3)->( Dbskip() )
			Enddo
		 EndIf					
		 
		 (_cAlias)->(DbSkip())
		 
	  EndDo

   EndIf
   
   MV_PAR06 := _cMVPAR05   // Filtro Vendedor 
   
   //=======================================================================================================
   // Chama a rotina para selecao dos registros da previs�o de comissao.												
   //=======================================================================================================
   //MV_PAR06 := (_cAlias)->CODVEND   // Filtro codigo do Vendedor 
   fwMsgRun(,{|oproc|ROMS025QRY(_cAlias4,4,oproc)},"Aguarde....","Filtrando os dados Previs�o de Comiss�o")    
		
   _nTotReg := 0 
		 		
   DBSelectArea(_cAlias4)
   (_cAlias4)->( DBGoTop() )
   (_cAlias4)->( DBEval( {|| _nTotReg++ } ) )
   (_cAlias4)->( DBGoTop() )

   If _nTotReg > 0
	  _nConAux := 0
	  Do While (_cAlias4)->( !Eof() )
         _nConAux++
		 oproc:cCaption := 'Processando dados previs�o de comiss�es... ['+ StrZero(_nConAux,9) +'] de ['+ StrZero(_nTotReg,9) +'].'
		 ProcessMessages()

 		 _cRazaoCli  := Posicione("SA1",1,xFilial("SA1")+(_cAlias4)->F2_CLIENTE+(_cAlias4)->F2_LOJA,"A1_NOME")
	     _cCodGrupo  := Posicione("SA1",1,xFilial("SA1")+(_cAlias4)->F2_CLIENTE+(_cAlias4)->F2_LOJA,"A1_GRPVEN")
	     _cDescGrupo := Posicione("ACY",1,xFilial("ACY")+_cCodGrupo,"ACY_DESCRI")
		 _cCodVen := (_cAlias4)->F2_VEND1
		 _ccodsup :=  (_cAlias4)->F2_VEND4
		 _cnomesup := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodsup)),SA3->A3_NOME," ")
		 _ccodcoord := (_cAlias4)->F2_VEND2
		 _cnomecoord := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodcoord)),SA3->A3_NOME," ")
		 _ccodger := (_cAlias4)->F2_VEND3
		 _cnomeger := IIF(SA3->(Dbseek(xfilial("SA3")+_ccodger)),SA3->A3_NOME," ")

         _cCodGNc  := (_cAlias4)->F2_VEND5
		 _cNomeGnc := IIF(SA3->(Dbseek(xfilial("SA3")+_cCodGNc)),SA3->A3_NOME," ")

		_aParcelaPre := ROMS025P((_cAlias4)->F2_FILIAL, (_cAlias4)->F2_CLIENTE, (_cAlias4)->F2_LOJA, (_cAlias4)->F2_SERIE, (_cAlias4)->F2_DOC)
		_nTotParcela := Len(_aParcelaPre)
         
		For _nI := 1 To _nTotParcela

		    _cParcela     := _aParcelaPre[_nI,1]
		    _nPercParcela := _aParcelaPre[_nI,2]
			_nPerCom1     := _aParcelaPre[_nI,3]     
			_nPerCom2     := _aParcelaPre[_nI,4]
			_nPerCom3     := _aParcelaPre[_nI,5]
			_nPerCom4     := _aParcelaPre[_nI,6]
			_nValorTit    := _aParcelaPre[_nI,7]
			_nSaldo       := _aParcelaPre[_nI,8]

			_nPercRest    := _nSaldo / _nValorTit
			
			_nIcmsRet    := (_cAlias4)->ICMSRET   
		    _nValICMParc := _nIcmsRet * _nPercParcela 
			_nValICMParc := _nValICMParc * _nPercRest
			//_nBaseComiss := ((_cAlias4)->BASECOMIS + _nIcmsRet) - _nValICMParc
            _nBaseComiss  := _nSaldo - _nValICMParc

            _aComissao := ROMS025R(_cParcela, _nBaseComiss, _nPercParcela ,(_cAlias4)->F2_FILIAL, (_cAlias4)->F2_CLIENTE, (_cAlias4)->F2_LOJA, (_cAlias4)->F2_SERIE, (_cAlias4)->F2_DOC)

			_nComiss1 := _aComissao[2]
			_nPerCom1 := _aComissao[3]
			_nComiss2 := _aComissao[4]
			_nPerCom2 := _aComissao[5]
			_nComiss3 := _aComissao[6]
			_nPerCom3 := _aComissao[7]
			_nComiss4 := _aComissao[8]
			_nPerCom4 := _aComissao[9]

            _nComiss5 := _aComissao[10]
			_nPerCom5 := _aComissao[11] 


		     If ascan(_adados, {|_vAux| _vAux[1]==(_cAlias4)->F2_FILIAL .and. _vAux[2]=="PRE" .and. _vAux[5]==(_cAlias4)->F2_DOC .And. _vAux[6] == _cParcela }) ==  0
			    // Incrementa array para gera��o de excel
                If Empty(MV_PAR07) .Or. ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07) // Imprime todos os dados
			       Aadd(_adados,{(_cAlias4)->F2_FILIAL	,;					                                              //01
			 		             "PRE",;													                              //02
							     DTOC(stod((_cAlias4)->F2_EMISSAO)),;					                                  //03
							     "  ",;													                                  //04
							     (_cAlias4)->F2_DOC,;									                                  //05
							     _cParcela,;											                                  //06
							     _cCodGrupo ,;											                                  //07
							     _cDescGrupo,;											                                  //08
							     (_cAlias4)->F2_CLIENTE,;								                                  //09
							     (_cAlias4)->F2_LOJA,;									                                  //10
							     _cRazaoCli,;											                                  //11
							     U_ROMS025I((_cAlias4)->VALTOT * _nPercParcela , "@E 999,999,999.99"),;					  //12
							     U_ROMS025I(0,"@E 999,999,999.99"),;													  //13
							     U_ROMS025I(0,"@E 999,999,999.99"),;													  //14
							     U_ROMS025I(0,"@E 999,999,999.99"),;													  //15
							     U_ROMS025I(_nBaseComiss, "@E 999,999,999.99"),;				                          //16  // U_ROMS025I(_nBaseComiss * _nPercParcela ,"@E 999,999,999.99"),;	
							     _cCodVen,;												                                  //17
							     POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                                  //18
							     _ccodsup,;												                                  //19
							     _cnomesup,;												                              //20
							     _ccodcoord,;											                                  //21
							     _cnomecoord,;											                                  //22
							     _ccodger,;												                                  //23
							     _cnomeger,;												                              //24
                                 _cCodGNc,;                                                                               //25
			                     _cNomeGnc,;                                                                              //26
							     U_ROMS025I(round( _nComiss1 , 3)  ,"@E 999,999,999.999")     ,;	                      //25-->27  
							     U_ROMS025I(round( _nPerCom1 , 3)  ,"@E 999,999,999.999")     ,;                          //26-->28  
							     U_ROMS025I(round( _nComiss4 , 3)  ,"@E 999,999,999.999")     ,;	                      //27-->29  
							     U_ROMS025I(round( _nPerCom4 , 3)  ,"@E 999,999,999.999")     ,;	                      //28-->30  
							     U_ROMS025I(round( _nComiss2 , 3)  ,"@E 999,999,999.999")     ,;	                      //29-->31  
							     U_ROMS025I(round( _nPerCom2 , 3)  ,"@E 999,999,999.999")     ,;	                      //30-->32  
							     U_ROMS025I(round( _nComiss3 , 3)  ,"@E 999,999,999.999")     ,;		                  //31-->33  
								 U_ROMS025I(round( _nPerCom3 , 3)  ,"@E 999,999,999.999")     ,;	                      //32-->34
								 U_ROMS025I(round( _nComiss5 , 3)  ,"@E 999,999,999.999")     ,;		                  //35  
								 U_ROMS025I(round( _nPerCom5 , 3)  ,"@E 999,999,999.999")     ,;	                      //36  
                         "  ",;
                           U_ROMS025I(0,"@E 999,999,999.99"),; //37
                           U_ROMS025I(0,"@E 999,999,999.99"),; //38
                           U_ROMS025I(0,"@E 999,999,999.99"),; //39
                           U_ROMS025I(0,"@E 999,999,999.99"),; //40
                           U_ROMS025I(0,"@E 999,999,999.99"); //41
							     })
							  
                ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07 //  N�o imprime vendedor
			       Aadd(_adados,{(_cAlias4)->F2_FILIAL	,;					                                               //01
					    	     "PRE",;													                               //02
							     DTOC(stod((_cAlias4)->F2_EMISSAO)),;					                                   //03
							     "  ",;													                                   //04
							     (_cAlias4)->F2_DOC,;									                                   //05
							     _cParcela,;											                                   //06
							     _cCodGrupo ,;											                                   //07
							     _cDescGrupo,;											                                   //08
							     (_cAlias4)->F2_CLIENTE,;								                                   //09
							     (_cAlias4)->F2_LOJA,;									                                   //10
							     _cRazaoCli,;											                                   //11
							     U_ROMS025I((_cAlias4)->VALTOT * _nPercParcela,"@E 999,999,999.99"),;					   //12
							     U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
							     U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
							     U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
							     U_ROMS025I(_nBaseComiss ,"@E 999,999,999.99"),;						                   //16  // U_ROMS025I(_nBaseComiss * _nPercParcela,"@E 999,999,999.99"),;	
							     _ccodsup,;												                                   //17
							     _cnomesup,;												                               //18
							     _ccodcoord,;											                                   //19
							     _cnomecoord,;											                                   //20
							     _ccodger,;												                                   //21
							     _cnomeger,;												                               //22
								 _cCodGNc,;                                                                                //23
			                     _cNomeGnc,;                                                                               //24
							     U_ROMS025I(round(_nComiss4 ,3),"@E 999,999,999.999"),;				                       //23-->25
							     U_ROMS025I(round(_nPerCom4 ,3),"@E 999,999,999.999"),;	                                   //24-->26
							     U_ROMS025I(round(_nComiss2 ,3),"@E 999,999,999.999"),;				                       //25-->27
							     U_ROMS025I(round(_nPerCom2 ,3),"@E 999,999,999.999"),;	                                   //26-->28 
						         U_ROMS025I(round(_nComiss3 ,3),"@E 999,999,999.999"),;				                       //27-->29 
							     U_ROMS025I(round(_nPerCom3 ,3),"@E 999,999,999.999"),;	                                   //28-->30 
								 U_ROMS025I(round(_nComiss5 ,3),"@E 999,999,999.999"),;				                       //31 
							     U_ROMS025I(round(_nPerCom5 ,3),"@E 999,999,999.999"),;	                                   //32 
							      " ",;                                                                                     //29-->33
                            U_ROMS025I((_cAlias4)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->VALST,"@E 999,999,999.999");   
							     })
                ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime supervisor
			       Aadd(_adados,{(_cAlias4)->F2_FILIAL	,;					                                               //01
				    	 	     "PRE",;													                               //02
							     DTOC(stod((_cAlias4)->F2_EMISSAO)),;					                                   //03
							     "  ",;													                                   //04
							     (_cAlias4)->F2_DOC,;									                                   //05
							     _cParcela,;											                                   //06
							     _cCodGrupo ,;											                                   //07
							     _cDescGrupo,;											                                   //08
							     (_cAlias4)->F2_CLIENTE,;								                                   //09
							     (_cAlias4)->F2_LOJA,;									                                   //10
							     _cRazaoCli,;											                                   //11
							     U_ROMS025I((_cAlias4)->VALTOT * _nPercParcela,"@E 999,999,999.99"),;					   //12
							     U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
							     U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
							     U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
							     U_ROMS025I(_nBaseComiss ,"@E 999,999,999.99"),;						                   //16  // U_ROMS025I(_nBaseComiss * _nPercParcela,"@E 999,999,999.99"),;	
							     _cCodVen,;												                                   //17
							     POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                                   //18
							     _ccodcoord,;											                                   //19
							     _cnomecoord,;											                                   //20
							     _ccodger,;												                                   //21
							     _cnomeger,;												                               //22
								 _cCodGNc,;                                                                                //23
			                     _cNomeGnc,;                                                                               //24
						         U_ROMS025I(round(_nComiss1 ,3),"@E 999,999,999.999"),;				                       //23-->25 
							     U_ROMS025I(round(_nPerCom1 ,3),"@E 999,999,999.999"),;	                                   //24-->26 
							     U_ROMS025I(round(_nComiss2 ,3),"@E 999,999,999.999"),;				                       //25-->27 
							     U_ROMS025I(round(_nPerCom2 ,3),"@E 999,999,999.999"),;	                                   //26-->28 
							     U_ROMS025I(round(_nComiss3 ,3),"@E 999,999,999.999"),;				                       //27-->29 
							     U_ROMS025I(round(_nPerCom3 ,3),"@E 999,999,999.999"),;	                                   //28-->30 
                                 U_ROMS025I(round(_nComiss5 ,3),"@E 999,999,999.999"),;				                       //31 
							     U_ROMS025I(round(_nPerCom5 ,3),"@E 999,999,999.999"),;	                                   //32  
							     " ",;                                                                                      //29-->33
                            U_ROMS025I((_cAlias4)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->VALST,"@E 999,999,999.999");   
							    })
                ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime Coordenador
				   Aadd(_adados,{(_cAlias4)->F2_FILIAL	,;					                                               //01
								"PRE",;													                                   //02
								DTOC(stod((_cAlias4)->F2_EMISSAO)),;					                                   //03
								"  ",;													                                   //04
								(_cAlias4)->F2_DOC,;									                                   //05
								_cParcela,;												                                   //06
								_cCodGrupo ,;											                                   //07
								_cDescGrupo,;											                                   //08
								(_cAlias4)->F2_CLIENTE,;								                                   //09
								(_cAlias4)->F2_LOJA,;									                                   //10
								_cRazaoCli,;											                                   //11
								U_ROMS025I((_cAlias4)->VALTOT * _nPercParcela,"@E 999,999,999.99"),;					   //12
								U_ROMS025I(0,"@E 999,999,999.99"),;													       //13
								U_ROMS025I(0,"@E 999,999,999.99"),;													       //14
								U_ROMS025I(0,"@E 999,999,999.99"),;													       //15
								U_ROMS025I(_nBaseComiss,"@E 999,999,999.99"),;						                       //16 // U_ROMS025I(_nBaseComiss * _nPercParcela,"@E 999,999,999.99"),;						       //16 
								_cCodVen,;												                                   //17
								POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                                   //18
								_ccodsup,;												                                   //19
								_cnomesup,;												                                   //20
								_ccodger,;												                                   //21
								_cnomeger,;												                                   //22
                                _cCodGNc,;                                                                                 //23
			                    _cNomeGnc,;                                                                                //24
								U_ROMS025I(round(_nComiss1 ,3),"@E 999,999,999.999"),;				                       //23-->25 
								U_ROMS025I(round(_nPerCom1 ,3),"@E 999,999,999.999"),;	                                   //24-->26 
								U_ROMS025I(round(_nComiss4 ,3),"@E 999,999,999.999"),;				                       //25-->27 
								U_ROMS025I(round(_nPerCom4 ,3),"@E 999,999,999.999"),;	                                   //26-->28 
								U_ROMS025I(round(_nComiss3 ,3),"@E 999,999,999.999"),;				                       //27-->29 
								U_ROMS025I(round(_nPerCom3 ,3),"@E 999,999,999.999"),;	                                   //28-->30
                                U_ROMS025I(round(_nComiss5 ,3),"@E 999,999,999.999"),;				                       //31 
							    U_ROMS025I(round(_nPerCom5 ,3),"@E 999,999,999.999"),;	                                   //32  
								" ",;                                                                                       //29-->33
                            U_ROMS025I((_cAlias4)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->VALST,"@E 999,999,999.999");   
								})
                ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime gerente
			       Aadd(_adados,{(_cAlias4)->F2_FILIAL	,;					                                               //01
						         "PRE",;													                               //02
							      DTOC(stod((_cAlias4)->F2_EMISSAO)),;					                                   //03
							      "  ",;													                               //04
							      (_cAlias4)->F2_DOC,;									                                   //05
							      _cParcela,;												                               //06
							      _cCodGrupo ,;											                                   //07
							      _cDescGrupo,;											                                   //08
							      (_cAlias4)->F2_CLIENTE,;								                                   //09
							      (_cAlias4)->F2_LOJA,;									                                   //10
							      _cRazaoCli,;											                                   //11
							      U_ROMS025I((_cAlias4)->VALTOT * _nPercParcela,"@E 999,999,999.99"),;					   //12
							      U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
							      U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
							      U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
							      U_ROMS025I(_nBaseComiss,"@E 999,999,999.99"),;					                       //16 // U_ROMS025I(_nBaseComiss * _nPercParcela,"@E 999,999,999.99"),;
							      _cCodVen,;												                               //17
							      POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                               //18
							      _ccodsup,;												                               //19
							      _cnomesup,;												                               //20
							      _ccodcoord,;											                                   //21
							      _cnomecoord,;											                                   //22
                                  _cCodGNc,;                                                                               //23
			                      _cNomeGnc,;                                                                              //24
							      U_ROMS025I(round(_nComiss1 ,3),"@E 999,999,999.999"),;				                   //23-->25 
							      U_ROMS025I(round(_nPerCom1 ,3),"@E 999,999,999.999"),;	                               //24-->26 
							      U_ROMS025I(round(_nComiss4 ,3),"@E 999,999,999.999"),;				                   //25-->27 
								  U_ROMS025I(round(_nPerCom4 ,3),"@E 999,999,999.999"),;	                               //26-->28  
							      U_ROMS025I(round(_nComiss2 ,3),"@E 999,999,999.999"),;				                   //27-->29 
							      U_ROMS025I(round(_nPerCom2 ,3),"@E 999,999,999.999"),;	                               //28-->30
                                  U_ROMS025I(round(_nComiss5 ,3),"@E 999,999,999.999"),;		                           //31 
							      U_ROMS025I(round(_nPerCom5 ,3),"@E 999,999,999.999"),;	                               //32  
							      " ",;                                                                                     //29-->33
                            U_ROMS025I((_cAlias4)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->VALST,"@E 999,999,999.999");   
								  })       
                ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // N�o imprime gerente nacional
			       Aadd(_adados,{(_cAlias4)->F2_FILIAL	,;					                                               //01
						         "PRE",;													                               //02
							      DTOC(stod((_cAlias4)->F2_EMISSAO)),;					                                   //03
							      "  ",;													                               //04
							      (_cAlias4)->F2_DOC,;									                                   //05
							      _cParcela,;												                               //06
							      _cCodGrupo ,;											                                   //07
							      _cDescGrupo,;											                                   //08
							      (_cAlias4)->F2_CLIENTE,;								                                   //09
							      (_cAlias4)->F2_LOJA,;									                                   //10
							      _cRazaoCli,;											                                   //11
							      U_ROMS025I((_cAlias4)->VALTOT * _nPercParcela,"@E 999,999,999.99"),;					   //12
							      U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
							      U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
							      U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
							      U_ROMS025I(_nBaseComiss,"@E 999,999,999.99"),;					                       //16 
							      _cCodVen,;												                               //17
							      POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                               //18
							      _ccodsup,;												                               //19
							      _cnomesup,;												                               //20
							      _ccodcoord,;											                                   //21
							      _cnomecoord,;											                                   //22
                                  _ccodger,;												                               //23
								  _cnomeger,;	                                                                           //24
							      U_ROMS025I(round(_nComiss1 ,3),"@E 999,999,999.999"),;				                   //23-->25 
							      U_ROMS025I(round(_nPerCom1 ,3),"@E 999,999,999.999"),;	                               //24-->26 
							      U_ROMS025I(round(_nComiss4 ,3),"@E 999,999,999.999"),;				                   //25-->27 
								  U_ROMS025I(round(_nPerCom4 ,3),"@E 999,999,999.999"),;	                               //26-->28  
							      U_ROMS025I(round(_nComiss2 ,3),"@E 999,999,999.999"),;				                   //27-->29 
							      U_ROMS025I(round(_nPerCom2 ,3),"@E 999,999,999.999"),;	                               //28-->30
                                  U_ROMS025I(round(_nComiss3 ,3),"@E 999,999,999.999"),;				                   //27-->29 
							      U_ROMS025I(round(_nPerCom3 ,3),"@E 999,999,999.999"),;                                   //28-->30
							      " ",;                                                                                     //29-->33
                            U_ROMS025I((_cAlias4)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->VALST,"@E 999,999,999.999");   
								  })       

                ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // imprime apenas gerente nacional
			       Aadd(_adados,{(_cAlias4)->F2_FILIAL	,;					                                               //01
						          "PRE",;													                               //02
							      DTOC(stod((_cAlias4)->F2_EMISSAO)),;					                                   //03
							      "  ",;													                               //04
							      (_cAlias4)->F2_DOC,;									                                   //05
							      _cParcela,;												                               //06
							      _cCodGrupo ,;											                                   //07
							      _cDescGrupo,;											                                   //08
							      (_cAlias4)->F2_CLIENTE,;								                                   //09
							      (_cAlias4)->F2_LOJA,;									                                   //10
							      _cRazaoCli,;											                                   //11
							      U_ROMS025I((_cAlias4)->VALTOT * _nPercParcela,"@E 999,999,999.99"),;					   //12
							      U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
							      U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
							      U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
							      U_ROMS025I(_nBaseComiss,"@E 999,999,999.99"),;					                       //16
							      _cCodGNc,;                                                                               //17
			                      _cNomeGnc,;                                                                              //18
                                  U_ROMS025I(round(_nComiss5 ,3),"@E 999,999,999.999"),;		                           //19 
							      U_ROMS025I(round(_nPerCom5 ,3),"@E 999,999,999.999"),;	                               //20  
							      " ",;                                                                                     //21
                            U_ROMS025I((_cAlias4)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->VALST,"@E 999,999,999.999");   
							 })
                ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas gerente
			       Aadd(_adados,{(_cAlias4)->F2_FILIAL	,;					                                               //01
						          "PRE",;													                               //02
							      DTOC(stod((_cAlias4)->F2_EMISSAO)),;					                                   //03
							      "  ",;													                               //04
							      (_cAlias4)->F2_DOC,;									                                   //05
							      _cParcela,;												                               //06
							      _cCodGrupo ,;											                                   //07
							      _cDescGrupo,;											                                   //08
							      (_cAlias4)->F2_CLIENTE,;								                                   //09
							      (_cAlias4)->F2_LOJA,;									                                   //10
							      _cRazaoCli,;											                                   //11
							      U_ROMS025I((_cAlias4)->VALTOT * _nPercParcela,"@E 999,999,999.99"),;					   //12
							      U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
							      U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
							      U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
							      U_ROMS025I(_nBaseComiss,"@E 999,999,999.99"),;					                       //16
							      _ccodger,;												                               //17
							      _cnomeger,;												                               //18
							      U_ROMS025I(round(_nComiss3 ,3),"@E 999,999,999.999"),;				                   //19 
							      U_ROMS025I(round(_nPerCom3 ,3),"@E 999,999,999.999"),;	                               //20 
							      " ",;                                                                                     //21
                            U_ROMS025I((_cAlias4)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->VALST,"@E 999,999,999.999");   
							 })
                ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas Coordenador
			       Aadd(_adados,{(_cAlias4)->F2_FILIAL	,;					                                               //01
							     "PRE",;													                               //02
							     DTOC(stod((_cAlias4)->F2_EMISSAO)),;					                                   //03
							     "  ",;													                                   //04
							     (_cAlias4)->F2_DOC,;									                                   //05
							     _cParcela,;											                                   //06
							     _cCodGrupo ,;											                                   //07
							     _cDescGrupo,;											                                   //08
							     (_cAlias4)->F2_CLIENTE,;								                                   //09
							     (_cAlias4)->F2_LOJA,;									                                   //10
							     _cRazaoCli,;											                                   //11
							     U_ROMS025I((_cAlias4)->VALTOT * _nPercParcela,"@E 999,999,999.99"),;					   //12
							     U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
							     U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
							     U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
							     U_ROMS025I(_nBaseComiss,"@E 999,999,999.99"),;						                       //16 // U_ROMS025I(_nBaseComiss * _nPercParcela,"@E 999,999,999.99"),;	
							     _ccodcoord,;											                                   //17
							     _cnomecoord,;											                                   //18
							     U_ROMS025I(round(_nComiss2 ,3),"@E 999,999,999.999"),;				                       //19 
							     U_ROMS025I(round(_nPerCom2 ,3),"@E 999,999,999.999"),;                                    //20 
							     " ",;                                                                                      //21
                            U_ROMS025I((_cAlias4)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->VALST,"@E 999,999,999.999");   
							     })
                ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas supervisor
			       Aadd(_adados,{(_cAlias4)->F2_FILIAL	,;					                                               //01
						         "PRE",;													                               //02
							     DTOC(stod((_cAlias4)->F2_EMISSAO)),;					                                   //03
							     "  ",;													                                   //04
							     (_cAlias4)->F2_DOC,;									                                   //05
							     _cParcela,;											                                   //06
							     _cCodGrupo ,;											                                   //07
							     _cDescGrupo,;											                                   //08
							     (_cAlias4)->F2_CLIENTE,;								                                   //09
							     (_cAlias4)->F2_LOJA,;									                                   //10
							     _cRazaoCli,;											                                   //11
							    U_ROMS025I((_cAlias4)->VALTOT * _nPercParcela,"@E 999,999,999.99"),;					   //12
							    U_ROMS025I(0,"@E 999,999,999.99"),;													       //13
							    U_ROMS025I(0,"@E 999,999,999.99"),;													       //14
							    U_ROMS025I(0,"@E 999,999,999.99"),;													       //15
							    U_ROMS025I(_nBaseComiss,"@E 999,999,999.99"),;						                       //16 // U_ROMS025I(_nBaseComiss * _nPercParcela,"@E 999,999,999.99"),;
							    _ccodsup,;												                                   //17
							    _cnomesup,;												                                   //18
							    U_ROMS025I(round(_nComiss4 ,3),"@E 999,999,999.999"),;				                       //19 
				    		    U_ROMS025I(round(_nPerCom4 ,3),"@E 999,999,999.999"),;	                                   //20 
							    " ",;                                                                                       //21
                            U_ROMS025I((_cAlias4)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->VALST,"@E 999,999,999.999");   
							    })
                ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas vendedor
			       Aadd(_adados,{(_cAlias4)->F2_FILIAL	,;					                                               //01
					     	     "PRE",;													                               //02
						    	 DTOC(stod((_cAlias4)->F2_EMISSAO)),;					                                   //03
							     "  ",;													                                   //04
							     (_cAlias4)->F2_DOC,;									                                   //05
							     _cParcela,;											                                   //06
							     _cCodGrupo ,;											                                   //07
							     _cDescGrupo,;											                                   //08
							    (_cAlias4)->F2_CLIENTE,;								                                   //09
							    (_cAlias4)->F2_LOJA,;									                                   //10
							     _cRazaoCli,;											                                   //11
							     U_ROMS025I((_cAlias4)->VALTOT * _nPercParcela,"@E 999,999,999.99"),;					   //12
							     U_ROMS025I(0,"@E 999,999,999.99"),;													   //13
							     U_ROMS025I(0,"@E 999,999,999.99"),;													   //14
							     U_ROMS025I(0,"@E 999,999,999.99"),;													   //15
							     U_ROMS025I(_nBaseComiss ,"@E 999,999,999.99"),;						                   //16 // U_ROMS025I(_nBaseComiss * _nPercParcela,"@E 999,999,999.99"),;	
							     _cCodVen,;												                                   //17
							     POSICIONE("SA3",1,xfilial("SA3")+_cCodVen,"A3_NOME"),;	                                   //18
							     U_ROMS025I(round(_nComiss1 ,3),"@E 999,999,999.999"),;				                       //19 
							     U_ROMS025I(round(_nPerCom1 ,3),"@E 999,999,999.999"),;                                    //20 
							     " ",;                                                                                      //21
                            U_ROMS025I((_cAlias4)->(SE5DCT+SE5VRB),"@E 999,999,999.999"),;//U_ROMS025I((_cAlias4)->VALDCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->SE5DCT,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->SE5VRB,"@E 999,999,999.999"),;
                            U_ROMS025I((_cAlias4)->VALST,"@E 999,999,999.999");   
							 })
               EndIf
		    EndIf
		Next //EndIf	   
		 (_cAlias4)->( Dbskip() )
	  Enddo
   EndIf					

   //========================================================================================
   // Ordena os dados do Array _aDados.
   //========================================================================================
   // _aDadosIndex, _aDadosLin, _nI, _nJ, _nTotColun   
   If Len(_aDados) > 0
      _nTotColun := Len(_aDados[1])
      _aDadosIndex := {}
      
      For _nI := 1 To Len(_aDados) 
          _aDadosLin := {}
          For _nJ := 1 To _nTotColun
              Aadd(_aDadosLin, _aDados[_nI,_nJ])
          Next
          
          If AllTrim(_aDados[_nI,2]) == "NF"
             Aadd(_aDadosLin, "1") // Primeira linha na ordena��o. 
          ElseIf AllTrim(_aDados[_nI,2]) == "PRE"          
             Aadd(_aDadosLin, "2") // Segunda linha na ordena��o. 
          ElseIf AllTrim(_aDados[_nI,2]) == "BON"          
             Aadd(_aDadosLin, "3") // Segunda linha na ordena��o. 
          ElseIf AllTrim(_aDados[_nI,2]) == "NCC"          
             Aadd(_aDadosLin, "9") // Segunda linha na ordena��o. 
          Else         
             Aadd(_aDadosLin, "9") // Ultima linha na ordena��o. 
          EndIf
          
          Aadd(_aDadosIndex,_aDadosLin) 
      Next
   
      _nTotColun += 1
      
      _aDadosIndex := aSort(_aDadosIndex,,,{|x,y| x[1]+x[5]+x[_nTotColun] < y[1]+y[5]+y[_nTotColun] })
      
      _nTotColun -= 1
      
      _aDados := {}
      
      For _nI := 1 To Len(_aDadosIndex) 
          _aDadosLin := {}
      
          For _nJ := 1 To _nTotColun
              Aadd(_aDadosLin, _aDadosIndex[_nI,_nJ])
          Next

          Aadd(_aDados , _aDadosLin) 
      Next
   
   EndIf		 

End Sequence

MV_PAR06 := _cMVPAR05   // Filtro Vendedor 

//==========================
//Finaliza o alias criado.
//==========================
dbSelectArea(_cAlias)
(_cAlias)->(dbCloseArea())    

Return 

/*
===============================================================================================================================
Programa--------: ROMS025V
Autor-----------: Julio de Paula Paz
Data da Criacao-: 29/03/2019
Descri��o-------: Validar a digita��o da data final de Previs�o de Comiss�o.
Parametros------: _cCampo = Campo que disparou a valida��o.
Retorno---------: .T. / .F.
===============================================================================================================================
*/
User Function ROMS025V(_cCampo As Character) As Logical
Local _lRet As Logical

_lRet := .T.

Begin Sequence
   If _cCampo == "MV_PAR09"
      If MV_PAR08 <> 3 .And. ! Empty(MV_PAR09)
         U_ITMSG("A data final de previs�o de comiss�o deve ser preenchida apenas quando o tipo de emiss�o de relat�rio for 'Previs�o de Comiss�o'.","Aten��o", ,1) 
         _lRet := .F.
      EndIf
   EndIf
End Sequence

Return _lRet

/*
===============================================================================================================================
Programa--------: ROMS025C
Autor-----------: Julio de Paula Paz
Data da Criacao-: 03/05/2019
Descri��o-------: Monta o Cabe�alho dos Relat�rios "Baixa Vendedor" e "Previs�o de Comiss�o".
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS025C()

Begin Sequence
   //===========================================================================================
   //   T�TULOS UTILIZADOS NOS RELAT�RIO BAIXA VENDEDOR E PREVIS�O DE COMISS�O
   //===========================================================================================
   If Empty(MV_PAR07) .Or. ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07) // Imprime todos os dados
	  _aTitulo := {	"Filial"		,;			//01
	       			"Tipo"			,;			//02
		    		"Dt. Emiss�o"	,;			//03
		 	    	"Dt. Baixa"		,;			//04
		 	    	"Documento"		,;			//05
			    	"Parcela"		,;			//06
			    	"Rede"			,;			//07
		    		"Desc Rede"		,;			//08
		   			"Cliente"		,;			//09
		   			"Loja"			,;			//10
		   			"Raz�o Social"	,;			//11
		   			"Valor Original",;			//12
		   			"Vlr Compensado",;			//13
		   			"Vlr Desconto"	,;			//14
		   			"Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Representante" ,;			//17
				    "Nome rep."     ,;			//18
				    "Supervisor" 	,;			//19
				    "Nome sup."     ,;			//20
				    "Coordenador" 	,;			//21
				    "Nome cood."    ,;			//22
				    "Gerente" 		,;			//23
				    "Nome ger."     ,;			//24
                    "Gerente Nac."  ,;			//25
				    "Nome ger.Nac." ,;			//26
				    "Vlr Com Rep"	,;			//25-->27
				    "% Com Rep"		,;			//26-->28
				    "Vlr Com Sup"	,;			//27-->29
				    "% Com Sup"		,;			//28-->30
				    "Vlr Com Cood"	,;			//29-->31
				    "% Com Cood"	,;			//30-->32
				    "Vlr Com Ger"	,;			//31-->33
				    "% Com Ger"		 ,;			//32-->34
					"Vlr Com Ger.Nac",;			//35
				    "% Com Ger.Nac"	 ,;			//36
				    "Sequenc.Comiss�o",;         //33-->37 
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",;
                "Vr ICM ST";
				   }		
          
   ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07 //  N�o imprime vendedor
       _aTitulo := {"Filial"		,;			//01
				    "Tipo"			,;			//02
				    "Dt. Emiss�o"	,;			//03
				    "Dt. Baixa"		,;			//04
				    "Documento"		,;			//05
				    "Parcela"		,;			//06
				    "Rede"			,;			//07
				    "Desc Rede"		,;			//08
				    "Cliente"		,;			//09
				    "Loja"			,;			//10
				    "Raz�o Social"	,;			//11
				    "Valor Original",;			//12
				    "Vlr Compensado",;			//13
				    "Vlr Desconto"	,;			//14
				    "Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Supervisor" 	,;			//17
				    "Nome sup."     ,;			//18
				    "Coordenador" 	,;			//19
				    "Nome cood."    ,;			//20
				    "Gerente" 		,;			//21
				    "Nome ger."     ,;			//22
					"Gerente Nac."  ,;			//23
				    "Nome ger.Nac"  ,;			//24
				    "Vlr Com Sup"	,;			//23-->25 
				    "% Com Sup"		,;			//24-->26
				    "Vlr Com Cood"	,;			//25-->27
				    "% Com Cood"	,;			//26-->28
				    "Vlr Com Ger"	,;			//27-->29
				    "% Com Ger"		,;			//28-->30
					"Vlr Com Ger.Nac",;			//31
				    "% Com Ger.Nac"	 ,;			//32
				    "Sequenc.Comiss�o",;         //29-->33
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",;
                "Vr ICM ST";
				  	}		
      
   ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 // N�o imprime supervisor
       _aTitulo := {"Filial"		,;			//01
				    "Tipo"			,;			//02
		 	     	"Dt. Emiss�o"	,;			//03
		 	    	"Dt. Baixa"		,;			//04
		 		    "Documento"		,;			//05
				    "Parcela"		,;			//06
				    "Rede"			,;			//07
				    "Desc Rede"		,;			//08
				    "Cliente"		,;			//09
				    "Loja"			,;			//10
				    "Raz�o Social"	,;			//11
				    "Valor Original",;			//12
				    "Vlr Compensado",;			//13
				    "Vlr Desconto"	,;			//14
				    "Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Representante" ,;			//17
				    "Nome rep."     ,;			//18
				    "Coordenador" 	,;			//19
				    "Nome cood."    ,;			//20
				    "Gerente" 		,;			//21
				    "Nome ger."     ,;			//22
				    "Gerente Nac."  ,;			//23
				    "Nome ger.Nac"  ,;			//24
				    "Vlr Com Rep"	,;			//23-->25
				    "% Com Rep"		,;			//24-->26
				    "Vlr Com Cood"	,;			//25-->27
				    "% Com Cood"	,;			//26-->28
				    "Vlr Com Ger"	,;			//27-->29
				    "% Com Ger"		,;			//28-->30
					"Vlr Com Ger.Nac",;			//31
				    "% Com Ger.Nac"	 ,;			//32
				    "Sequenc.Comiss�o",;         //29-->35
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",;
                "Vr ICM ST";
			    	}		

   ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 // N�o imprime Coordenador
       _aTitulo := {	"Filial"		,;			//01
				    "Tipo"			,;			//02
		 		    "Dt. Emiss�o"	,;			//03
		 		    "Dt. Baixa"		,;			//04
		 		    "Documento"		,;			//05
				    "Parcela"		,;			//06
				    "Rede"			,;			//07
				    "Desc Rede"		,;			//08
				    "Cliente"		,;			//09
				    "Loja"			,;			//10
				    "Raz�o Social"	,;			//11
				    "Valor Original",;			//12
				    "Vlr Compensado",;			//13
				    "Vlr Desconto"	,;			//14
				    "Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Representante" ,;			//17
				    "Nome rep."     ,;			//18
				    "Supervisor" 	,;			//19
				    "Nome sup."     ,;			//20
				    "Gerente" 		,;			//21
				    "Nome ger."     ,;			//22
				    "Gerente Nac."  ,;			//23
				    "Nome ger.Nac"  ,;			//24
				    "Vlr Com Rep"	,;			//23-->25
				    "% Com Rep"		,;			//24-->26
				    "Vlr Com Sup"	  ,;    	//25-->27
				    "% Com Sup"		  ,;		//26-->28
				    "Vlr Com Ger"	  ,;		//27-->29
				    "% Com Ger"		  ,;		//28-->30
                    "Vlr Com Ger.Nac" ,;		//31
				    "% Com Ger.Nac"	  ,;	    //32
				    "Sequenc.Comiss�o",;         //29-->33
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",;
                "Vr ICM ST";
				  	 }		
      
   ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 // N�o imprime gerente
       _aTitulo := {	"Filial"		,;			//01
				    "Tipo"			,;			//02
		 		    "Dt. Emiss�o"	,;			//03
		 		    "Dt. Baixa"		,;			//04
		 		    "Documento"		,;			//05
				    "Parcela"		,;			//06
				    "Rede"			,;			//07
				    "Desc Rede"		,;			//08
				    "Cliente"		,;			//09
				    "Loja"			,;			//10
				    "Raz�o Social"	,;			//11
				    "Valor Original",;			//12
				    "Vlr Compensado",;			//13
				    "Vlr Desconto"	,;			//14
				    "Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Representante" ,;			//17
				    "Nome rep."     ,;			//18
			 	    "Supervisor" 	,;			//19
				    "Nome sup."     ,;			//20
				    "Coordenador" 	,;			//21
				    "Nome cood."    ,;			//22
				    "Gerente Nac."  ,;			//23
				    "Nome ger.Nac"  ,;			//24
				    "Vlr Com Rep"	,;			//23-->25
				    "% Com Rep"		,;			//24-->26
				    "Vlr Com Sup"	,;			//25-->27
				    "% Com Sup"		,;			//26-->28
				    "Vlr Com Cood"	,;			//27-->29
				    "% Com Cood"	,;			//28-->30
                    "Vlr Com Ger.Nac",;			//31
				    "% Com Ger.Nac"	 ,;		    //32					
				    "Sequenc.Comiss�o",;         // 29-->33 
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",;
                "Vr ICM ST";
				  	}		

   ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07// imprime apenas gerente nacional.
       _aTitulo := {"Filial"		,;			//01
				    "Tipo"			,;			//02
		 		    "Dt. Emiss�o"	,;			//03
		 		    "Dt. Baixa"		,;			//04
		 		    "Documento"		,;			//05
				    "Parcela"		,;			//06
				    "Rede"			,;			//07
				    "Desc Rede"		,;			//08
				    "Cliente"		,;			//09
				    "Loja"			,;			//10
				    "Raz�o Social"	,;			//11
				    "Valor Original",;			//12
				    "Vlr Compensado",;			//13
				    "Vlr Desconto"	,;			//14
				    "Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Gerente Nac."  ,;			//17
				    "Nome ger.Nac"  ,;			//18
                    "Vlr Com Ger.Nac",;			//19
				    "% Com Ger.Nac"	 ,;		    //20
				    "Sequenc.Comiss�o",;         // 23 A // 21 B 
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",;
                "Vr ICM ST";
				  	}		

   ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07// imprime apenas gerente
       _aTitulo := {	"Filial"		,;			//01
				    "Tipo"			,;			//02
		 		    "Dt. Emiss�o"	,;			//03
		 		    "Dt. Baixa"		,;			//04
		 		    "Documento"		,;			//05
				    "Parcela"		,;			//06
				    "Rede"			,;			//07
				    "Desc Rede"		,;			//08
				    "Cliente"		,;			//09
				    "Loja"			,;			//10
				    "Raz�o Social"	,;			//11
				    "Valor Original",;			//12
				    "Vlr Compensado",;			//13
				    "Vlr Desconto"	,;			//14
				    "Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Gerente" 		,;			//17
				    "Nome ger."     ,;			//18
				    "Vlr Com Ger"	,;			//19
				    "% Com Ger"		,;			//20
				    "Sequenc.Comiss�o",;         // 23 A // 21 B 
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",;
                "Vr ICM ST";
				  	}		

   ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 // imprime apenas Coordenador
       _aTitulo := {	"Filial"		,;			//01
				    "Tipo"			,;			//02
		 		    "Dt. Emiss�o"	,;			//03
		 		    "Dt. Baixa"		,;			//04
		 		    "Documento"		,;			//05
				    "Parcela"		,;			//06
				    "Rede"			,;			//07
				    "Desc Rede"		,;			//08
				    "Cliente"		,;			//09
				    "Loja"			,;			//10
				    "Raz�o Social"	,;			//11
				    "Valor Original",;			//12
				    "Vlr Compensado",;			//13
				    "Vlr Desconto"	,;			//14
				    "Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Coordenador" 	,;			//17
				    "Nome cood."    ,;			//18
				    "Vlr Com Cood"	,;			//19
				    "% Com Cood"	,;			//20
				    "Sequenc.Comiss�o",;         // 23 A // 21 B 
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",;
                "Vr ICM ST";
				  	}		
					  	
   ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 // imprime apenas supervisor
       _aTitulo := {	"Filial"		,;			//01
				    "Tipo"			,;			//02
		 		    "Dt. Emiss�o"	,;			//03
		 		    "Dt. Baixa"		,;			//04
		 		    "Documento"		,;			//05
				    "Parcela"		,;			//06
				    "Rede"			,;			//07
				    "Desc Rede"		,;			//08
				    "Cliente"		,;			//09
				    "Loja"			,;			//10
				    "Raz�o Social"	,;			//11
				    "Valor Original",;			//12
				    "Vlr Compensado",;			//13
				    "Vlr Desconto"	,;			//14
				    "Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Supervisor" 	,;			//17
				    "Nome sup."     ,;			//18
				    "Vlr Com Sup"	,;			//19
				    "% Com Sup"		,;			//20
				    "Sequenc.Comiss�o",;         // 23 A // 21 B 
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",;
                "Vr ICM ST";
				  	}		
					  	
   ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 // imprime apenas vendedor
       _aTitulo := {	"Filial"		,;			//01
				    "Tipo"			,;			//02
		 		    "Dt. Emiss�o"	,;			//03
		 		    "Dt. Baixa"		,;			//04
		 		    "Documento"		,;			//05
				    "Parcela"		,;			//06
				    "Rede"			,;			//07
				    "Desc Rede"		,;			//08
				    "Cliente"		,;			//09
				    "Loja"			,;			//10
				    "Raz�o Social"	,;			//11
				    "Valor Original",;			//12
				    "Vlr Compensado",;			//13
				    "Vlr Desconto"	,;			//14
				    "Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Representante" ,;			//17
				    "Nome rep."     ,;			//18
				    "Vlr Com Rep"	,;			//19
				    "% Com Rep"		,;			//20
				    "Sequenc.Comiss�o",;         // 23 A // 21 B 
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",;
                "Vr ICM ST";
				  	}		
   EndIf

End Sequence

Return Nil

/*
===============================================================================================================================
Programa--------: ROMS025D
Autor-----------: Julio de Paula Paz
Data da Criacao-: 03/05/2019
Descri��o-------: Monta o Cabe�alho do Relat�rio Baixa Detalhado. 
Parametros------: Nenhum
Retorno---------: Nenhum
===============================================================================================================================
*/
Static Function ROMS025D()

Begin Sequence
   //===========================================================================================
   //   T�TULOS UTILIZADOS NOS RELAT�RIO BAIXA DETALHADO
   //===========================================================================================
   If Empty(MV_PAR07) .Or. ("G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07) // Imprime todos os dados  // 1 
	  _aTitulo := {	"Filial"		,;			//01
	       			"Tipo"			,;			//02
		    		"Dt. Emiss�o"	,;			//03
		 	    	"Dt. Baixa"		,;			//04
		 	    	"Documento"		,;			//05
			    	"Parcela"		,;			//06
			    	"Rede"			,;			//07
		    		"Desc Rede"		,;			//08
		   			"Cliente"		,;			//09
		   			"Loja"			,;			//10
		   			"Raz�o Social"	,;			//11
		   			"Valor Original",;			//12
		   			"Vlr Compensado",;			//13
		   			"Vlr Desconto"	,;			//14
		   			"Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Representante" ,;			//17
				    "Nome rep."     ,;			//18
				    "Supervisor" 	,;			//19
				    "Nome sup."     ,;			//20
				    "Coordenador" 	,;			//21
				    "Nome cood."    ,;			//22
				    "Gerente" 		,;			//23
				    "Nome ger."     ,;			//24
					"Gerente Nacional",;		// 
				    "Nome ger.Nac." ,;			// 
				    "Vlr Com Rep"	,;			//25  sd1
				    "% Com Rep"		,;			//26  sd1
                    "% Com Nota Rep",;          // 27 A  Calculado.
					"Media % Sistemica Rep",;   // 28 A  Calculado.
				    "Vlr Com Sup"	,;			// 29 A // 27 B
				    "% Com Sup"		,;			// 30 A // 28 B
                    "% Com Nota Sup",;          // 31 A
					"Media % Sistemica Sup",;   // 32 A
				    "Vlr Com Cood"	,;			// 33 A // 29 B
				    "% Com Cood"	,;			// 34 A // 30 B
                    "% Com Nota Coord",;        // 35 A 
					"Media % Sistemica Coord",; // 36 A 
				    "Vlr Com Ger"	,;			// 37 A // 31 B
				    "% Com Ger"		,;			// 38 A // 32 B 
                     "% Com Nota Ger",;         // 40 A 
					"Media % Sistemica Ger",;   // 41 A 
					"Vlr Com Ger Nac"	,;		 // 
				    "% Com Ger Nac"		,;		 // 
                    "% Com Nota Ger Nac",;       // 
					"Media % Sistemica Ger Nac",;// 
				    "Sequenc.Comiss�o",;         // 23 A // 21 B 
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",;
                "Vr ICM ST";
				   }		
          
   ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07//  N�o imprime vendedor  // 2
       _aTitulo := {	"Filial"		,;			//01
				    "Tipo"			,;			//02
				    "Dt. Emiss�o"	,;			//03
				    "Dt. Baixa"		,;			//04
				    "Documento"		,;			//05
				    "Parcela"		,;			//06
				    "Rede"			,;			//07
				    "Desc Rede"		,;			//08
				    "Cliente"		,;			//09
				    "Loja"			,;			//10
				    "Raz�o Social"	,;			//11
				    "Valor Original",;			//12
				    "Vlr Compensado",;			//13
				    "Vlr Desconto"	,;			//14
				    "Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Supervisor" 	,;			//17
				    "Nome sup."     ,;			//18
				    "Coordenador" 	,;			//19
				    "Nome cood."    ,;			//20
				    "Gerente" 		,;			//21
				    "Nome ger."     ,;			//22
					"Gerente Nacional",;		// 
                    "Nome ger.Nac." ,;		    // 
				    "Vlr Com Sup"	,;			//23
				    "% Com Sup"		,;			//24
                    "% Com Nota Sup",;          // 25 A
                    "Media % Sistemica Sup",;   // 26 A 
				    "Vlr Com Cood"	,;			// 27 A // 25 B
				    "% Com Cood"	,;			// 28 A // 26 B 
                    "% Com Nota Coord",;        // 29 A
                    "Media % Sistemica Coord",; // 30 A 
				    "Vlr Com Ger"	,;			// 31 A // 27 B
				    "% Com Ger"		,;			// 32 A // 28 B 
                    "% Com Nota Ger",;         // 33 A 
                    "Media % Sistemica Ger",;  // 34 A
					"Vlr Com Ger Nac"	,;		 // 
			        "% Com Ger Nac"		,;		 // 
                    "% Com Nota Ger Nac",;       // 
					"Media % Sistemica Ger Nac",;// 
				    "Sequenc.Comiss�o",;         // 23 A // 21 B 
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",;
                "Vr ICM ST";
				  	}		
      
   ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime supervisor // 3
       _aTitulo := {"Filial"		,;			//01
				    "Tipo"			,;			//02
		 	     	"Dt. Emiss�o"	,;			//03
		 	    	"Dt. Baixa"		,;			//04
		 		    "Documento"		,;			//05
				    "Parcela"		,;			//06
				    "Rede"			,;			//07
				    "Desc Rede"		,;			//08
				    "Cliente"		,;			//09
				    "Loja"			,;			//10
				    "Raz�o Social"	,;			//11
				    "Valor Original",;			//12
				    "Vlr Compensado",;			//13
				    "Vlr Desconto"	,;			//14
				    "Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Representante" ,;			//17
				    "Nome rep."     ,;			//18
				    "Coordenador" 	,;			//19
				    "Nome cood."    ,;			//20
				    "Gerente" 		,;			//21
				    "Nome ger."     ,;			//22
					"Gerente Nacional",;		// 
                    "Nome ger.Nac." ,;		    // 
				    "Vlr Com Rep"	,;			//23
				    "% Com Rep"		,;			//24
                    "% Com Nota Rep",;          // 25 A 
                    "Media % Sistemica Rep",;   // 26 A
				    "Vlr Com Cood"	,;			// 27 A // 25 B
				    "% Com Cood"	,;			// 28 A // 26 B
                    "% Com Nota Coord",;        // 29 A 
                    "Media % Sistemica Coord",; // 30 A 
				    "Vlr Com Ger"	,;			 // 31 A // 27 B
				    "% Com Ger"		,;			 // 32 A // 28 B
                    "% Com Nota Ger",;           // 33 A
                    "Media % Sistemica Ger",;    // 34 A
					"Vlr Com Ger Nac"	,;		 // 
			        "% Com Ger Nac"		,;		 // 
                    "% Com Nota Ger Nac",;       // 
					"Media % Sistemica Ger Nac",;// 
				    "Sequenc.Comiss�o",;         // 23 A // 21 B 
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",;
                "Vr ICM ST";
			    	}		

   ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime Coordenador // 4
       _aTitulo := {"Filial"		,;			//01
				    "Tipo"			,;			//02
		 		    "Dt. Emiss�o"	,;			//03
		 		    "Dt. Baixa"		,;			//04
		 		    "Documento"		,;			//05
				    "Parcela"		,;			//06
				    "Rede"			,;			//07
				    "Desc Rede"		,;			//08
				    "Cliente"		,;			//09
				    "Loja"			,;			//10
				    "Raz�o Social"	,;			//11
				    "Valor Original",;			//12
				    "Vlr Compensado",;			//13
				    "Vlr Desconto"	,;			//14
				    "Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Representante" ,;			//17
				    "Nome rep."     ,;			//18
				    "Supervisor" 	,;			//19
				    "Nome sup."     ,;			//20
				    "Gerente" 		,;			//21
				    "Nome ger."     ,;			//22
					"Gerente Nacional",;		// 
                    "Nome ger.Nac." ,;		    // 
				    "Vlr Com Rep"	,;			//23
				    "% Com Rep"		,;			//24
                    "% Com Nota Rep",;          // 25 A
                    "Media % Sistemica Rep",;   // 26 A
				    "Vlr Com Sup"	,;			// 27 A // 25 B
				    "% Com Sup"		,;			// 27 A // 26 B
                    "% Com Nota Sup",;          // 28 A
                    "Media % Sistemica Sup",;   // 29 A 
				    "Vlr Com Ger"	,;			// 30 A // 27 B
				    "% Com Ger"		,;			// 31 A // 28 B
                    "% Com Nota Ger",;         // 32 A
                    "Media % Sistemica Ger",;  // 33 A
					"Vlr Com Ger Nac"	,;		 // 
	                "% Com Ger Nac"		,;		 // 
                    "% Com Nota Ger Nac",;       // 
					"Media % Sistemica Ger Nac",;// 
				    "Sequenc.Comiss�o",;         // 23 A // 21 B 
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",;
                "Vr ICM ST";
				  	 }		
      
   ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. "N" $ MV_PAR07 // N�o imprime gerente  // 5
       _aTitulo := {"Filial"		,;			//01
				    "Tipo"			,;			//02
		 		    "Dt. Emiss�o"	,;			//03
		 		    "Dt. Baixa"		,;			//04
		 		    "Documento"		,;			//05
				    "Parcela"		,;			//06
				    "Rede"			,;			//07
				    "Desc Rede"		,;			//08
				    "Cliente"		,;			//09
				    "Loja"			,;			//10
				    "Raz�o Social"	,;			//11
				    "Valor Original",;			//12
				    "Vlr Compensado",;			//13
				    "Vlr Desconto"	,;			//14
				    "Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Representante" ,;			//17
				    "Nome rep."     ,;			//18
			 	    "Supervisor" 	,;			//19
				    "Nome sup."     ,;			//20
				    "Coordenador" 	,;			//21
				    "Nome cood."    ,;			//22
					"Gerente Nacional",;		// 
                    "Nome ger.Nac." ,;		    // 
				    "Vlr Com Rep"	,;			//23
				    "% Com Rep"		,;			//24
                    "% Com Nota Rep",;          // 25 A
                    "Media % Sistemica Rep",;   // 26 A
				    "Vlr Com Sup"	,;			// 27 A // 25 B
				    "% Com Sup"		,;			// 28 A // 26 B
                    "% Com Nota Sup",;          // 29 A
                    "Media % Sistemica Sup",;   // 30 A
				    "Vlr Com Cood"	,;			// 31 A // 27 B
				    "% Com Cood"	,;			// 32 A // 28 B
                    "% Com Nota Coord",;        // 33 A 
                    "Media % Sistemica Coord",; // 34 A 
					"Vlr Com Ger Nac"	,;		 // 
			        "% Com Ger Nac"		,;		 // 
                    "% Com Nota Ger Nac",;       // 
					"Media % Sistemica Ger Nac",; // 
				    "Sequenc.Comiss�o",;         // 23 A // 21 B 
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",;
                "Vr ICM ST";
				  	}		

 ElseIf "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // N�o imprime gerente nacional
       _aTitulo := {"Filial"		,;			//01
				    "Tipo"			,;			//02
		 		    "Dt. Emiss�o"	,;			//03
		 		    "Dt. Baixa"		,;			//04
		 		    "Documento"		,;			//05
				    "Parcela"		,;			//06
				    "Rede"			,;			//07
				    "Desc Rede"		,;			//08
				    "Cliente"		,;			//09
				    "Loja"			,;			//10
				    "Raz�o Social"	,;			//11
				    "Valor Original",;			//12
				    "Vlr Compensado",;			//13
				    "Vlr Desconto"	,;			//14
				    "Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Representante" ,;			//17
				    "Nome rep."     ,;			//18
			 	    "Supervisor" 	,;			//19
				    "Nome sup."     ,;			//20
				    "Coordenador" 	,;			//21
				    "Nome cood."    ,;			//22
					"Gerente"       ,;	    	// 
                    "Nome ger."     ,;		    // 
				    "Vlr Com Rep"	,;			//23
				    "% Com Rep"		,;			//24
                    "% Com Nota Rep",;          // 25 A
                    "Media % Sistemica Rep",;   // 26 A
				    "Vlr Com Sup"	,;			// 27 A // 25 B
				    "% Com Sup"		,;			// 28 A // 26 B
                    "% Com Nota Sup",;          // 29 A
                    "Media % Sistemica Sup",;   // 30 A
				    "Vlr Com Cood"	,;			// 31 A // 27 B
				    "% Com Cood"	,;			// 32 A // 28 B
                    "% Com Nota Coord",;        // 33 A 
                    "Media % Sistemica Coord",; // 34 A 
					"Vlr Com Ger"	,;		    // 
			        "% Com Ger"		,;		    // 
                    "% Com Nota Ger",;          // 
					"Media % Sistemica Ger",;   // 
				    "Sequenc.Comiss�o",;         // 23 A // 21 B 
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",;
                "Vr ICM ST";
				  	}		

   ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. "N" $ MV_PAR07// imprime apenas gerente nacional
       _aTitulo := {"Filial"		,;			//01
				    "Tipo"			,;			//02
		 		    "Dt. Emiss�o"	,;			//03
		 		    "Dt. Baixa"		,;			//04
		 		    "Documento"		,;			//05
				    "Parcela"		,;			//06
				    "Rede"			,;			//07
				    "Desc Rede"		,;			//08
				    "Cliente"		,;			//09
				    "Loja"			,;			//10
				    "Raz�o Social"	,;			//11
				    "Valor Original",;			//12
				    "Vlr Compensado",;			//13
				    "Vlr Desconto"	,;			//14
				    "Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Gerente Nacional",;		//17
				    "Nome Ger.Nac." ,;			//18
				    "Vlr Com Ger Nac"	,;		 //19
				    "% Com Ger Nac"		,;		 //20
                    "% Com Nota Ger Nac",;       // 21 A 
                    "Media % Sistemica Ger Nac",;// 22 A
				    "Sequenc.Comiss�o",;         // 23 A // 21 B 
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",;
                "Vr ICM ST";
				  	}		

   ElseIf "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07// imprime apenas gerente  // 6
       _aTitulo := {	"Filial"		,;			//01
				    "Tipo"			,;			//02
		 		    "Dt. Emiss�o"	,;			//03
		 		    "Dt. Baixa"		,;			//04
		 		    "Documento"		,;			//05
				    "Parcela"		,;			//06
				    "Rede"			,;			//07
				    "Desc Rede"		,;			//08
				    "Cliente"		,;			//09
				    "Loja"			,;			//10
				    "Raz�o Social"	,;			//11
				    "Valor Original",;			//12
				    "Vlr Compensado",;			//13
				    "Vlr Desconto"	,;			//14
				    "Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Gerente" 		,;			//17
				    "Nome ger."     ,;			//18
				    "Vlr Com Ger"	,;			//19
				    "% Com Ger"		,;			//20
                    "% Com Nota Ger",;          // 21 A 
                    "Media % Sistemica Ger",;   // 22 A
				    "Sequenc.Comiss�o",;         // 23 A // 21 B 
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",;
                "Vr ICM ST";
				  	}		

   ElseIf ! "G" $ MV_PAR07 .And. "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas Coordenador  // 7 
       _aTitulo := {"Filial"		,;			//01
				    "Tipo"			,;			//02
		 		    "Dt. Emiss�o"	,;			//03
		 		    "Dt. Baixa"		,;			//04
		 		    "Documento"		,;			//05
				    "Parcela"		,;			//06
				    "Rede"			,;			//07
				    "Desc Rede"		,;			//08
				    "Cliente"		,;			//09
				    "Loja"			,;			//10
				    "Raz�o Social"	,;			//11
				    "Valor Original",;			//12
				    "Vlr Compensado",;			//13
				    "Vlr Desconto"	,;			//14
				    "Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Coordenador" 	,;			//17
				    "Nome cood."    ,;			//18
				    "Vlr Com Cood"	,;			//19
				    "% Com Cood"	,;			//20
                    "% Com Nota Coord",;        // 21 A
                    "Media % Sistemica Coord",; // 22 A 
				    "Sequenc.Comiss�o",;         // 23 A // 21 B 
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",; 
                "Vr ICM ST";
				  	}		
					  	
   ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. "S" $ MV_PAR07 .And. ! "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07// imprime apenas supervisor  // 8
       _aTitulo := {	"Filial"		,;			//01
				    "Tipo"			,;			//02
		 		    "Dt. Emiss�o"	,;			//03
		 		    "Dt. Baixa"		,;			//04
		 		    "Documento"		,;			//05
				    "Parcela"		,;			//06
				    "Rede"			,;			//07
				    "Desc Rede"		,;			//08
				    "Cliente"		,;			//09
				    "Loja"			,;			//10
				    "Raz�o Social"	,;			//11
				    "Valor Original",;			//12
				    "Vlr Compensado",;			//13
				    "Vlr Desconto"	,;			//14
				    "Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Supervisor" 	,;			//17
				    "Nome sup."     ,;			//18
				    "Vlr Com Sup"	,;			//19
				    "% Com Sup"		,;			//20
                    "% Com Nota Sup",;          // 21 A
                    "Media % Sistemica Sup",;   // 22 A
				    "Sequenc.Comiss�o",;         // 23 A // 21 B 
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",;
                "Vr ICM ST";
				  	}		
					  	
   ElseIf ! "G" $ MV_PAR07 .And. ! "C" $ MV_PAR07 .And. ! "S" $ MV_PAR07 .And. "V" $ MV_PAR07 .And. ! "N" $ MV_PAR07 // imprime apenas vendedor  // 9
       _aTitulo := {"Filial"		,;			//01
				    "Tipo"			,;			//02
		 		    "Dt. Emiss�o"	,;			//03
		 		    "Dt. Baixa"		,;			//04
		 		    "Documento"		,;			//05
				    "Parcela"		,;			//06
				    "Rede"			,;			//07
				    "Desc Rede"		,;			//08
				    "Cliente"		,;			//09
				    "Loja"			,;			//10
				    "Raz�o Social"	,;			//11
				    "Valor Original",;			//12
				    "Vlr Compensado",;			//13
				    "Vlr Desconto"	,;			//14
				    "Vlr Baixas Ant",;			//15
				    "Base Comiss�o" ,;			//16
				    "Representante" ,;			//17
				    "Nome rep."     ,;			//18
				    "Vlr Com Rep"	 ,;			//19
				    "% Com Rep"		,;			//20
                    "% Com Nota Rep",;          // 21 A
                    "Media % Sistemica Rep",;   // 22 A
				    "Sequenc.Comiss�o",;         // 23 A // 21 B 
					"Val.Tit.Desc.",;			//"Vr Desconto",;
                "Vr Desc Contrato",;
                "Vr Desc Verba",;
                "Vr ICM ST";
				  	}		
	
   EndIf

   //===========================================================================================
   //   COMPLEMENTO DO T�TULO DO RELAT�RIO BAIXA DETALHADO
   //===========================================================================================   
   //If MV_PAR08 == 2
      Aadd(_aTitulo,"Mix BI"      ) 
      Aadd(_aTitulo,"Item"        ) 
      Aadd(_aTitulo,"Produto"     )
      Aadd(_aTitulo,"Descri��o"   )
      Aadd(_aTitulo,"Aliq.%"      )
      Aadd(_aTitulo,"Qtde"        )
      Aadd(_aTitulo,"U.M."        )
      Aadd(_aTitulo,"Qtde 2a U.M.")
      Aadd(_aTitulo,"2a U.M."     )
      Aadd(_aTitulo,"Vlr.Uni."    )
      Aadd(_aTitulo,"Valor Total" )
      Aadd(_aTitulo,"NF.Origem"   )
      Aadd(_aTitulo,"Serie Origem") 
      Aadd(_aTitulo,"Vr Desconto") 
      Aadd(_aTitulo,"Vr Desc Compensado") 
      Aadd(_aTitulo,"Vr Verba Descontado") 
      Aadd(_aTitulo,"Vr ICM ST") 
   //EndIf

End Sequence

Return Nil

/*
===============================================================================================================================
Programa--------: ROMS025B
Autor-----------: Julio de Paula Paz
Data da Criacao-: 16/04/2019
Descri��o-------: Retornar os valores dos percentuais de comiss�es gravados na tabela SD2.
Parametros------: _cFilialNF = Codigo da filial
                  _cNRNF     = Nr da nota fiscal
                  _cSerieNf  = Serie da nota fiscal
                  _cCodCli   = Codigo do cliente
                  _cLojaCli  = Loja do cliente
                  _cProd     = Codigo do produto
Retorno---------: _aRet = {Comiss�o 1, Comiss�o 2, Comiss�o 3, Comissao 4, Valor Total SF2, Valor Total Item, Comiss�o 5}
===============================================================================================================================
*/
User Function ROMS025B(_cFilialNF As Character,_cNRNF As Character,_cSerieNf As Character,_cCodCli As Character,_cLojaCli As Character,_cProd As Character) As Array
Local _aRet As Array
Local _aOrd As Array
Local _nRegSD2 As Numeric
Local _nRegSF2 As Numeric
Local _nVTotSF2 As Numeric

_aRet     := {}
_aOrd     := SaveOrd({"SD2","SF2"})
_nRegSD2  := SD2->(Recno())
_nRegSF2  := SF2->(Recno())
_nVTotSF2 := 0

Begin Sequence
   _aRet := {0,0,0,0, _nVTotSF2,0 }
   
   SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
   If SF2->(DbSeek(U_ItKey(_cFilialNF,"D2_FILIAL")+U_ItKey(_cNRNF,"D2_DOC")+U_ItKey(_cSerieNf,"D2_SERIE")+U_ItKey(_cCodCli,"D2_CLIENTE")+U_ItKey(_cLojaCli,"D2_LOJA")))
      _nVTotSF2 := SF2->F2_VALMERC
   EndIf
   
   SD2->(DbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
   If SD2->(DbSeek(U_ItKey(_cFilialNF,"D2_FILIAL")+U_ItKey(_cNRNF,"D2_DOC")+U_ItKey(_cSerieNf,"D2_SERIE")+U_ItKey(_cCodCli,"D2_CLIENTE")+U_ItKey(_cLojaCli,"D2_LOJA")))
      Do While ! SD2->(Eof()) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == U_ItKey(_cFilialNF,"D2_FILIAL")+U_ItKey(_cNRNF,"D2_DOC")+U_ItKey(_cSerieNf,"D2_SERIE")+U_ItKey(_cCodCli,"D2_CLIENTE")+U_ItKey(_cLojaCli,"D2_LOJA")
         If SD2->D2_COD == U_ItKey(_cProd,"D2_COD")
            _aRet := {SD2->D2_COMIS1, SD2->D2_COMIS2, SD2->D2_COMIS3, SD2->D2_COMIS4, _nVTotSF2, SD2->D2_TOTAL, SD2->D2_COMIS5}
         EndIf   
         
         SD2->(DbSkip())   
      EndDo
   EndIf      
     
End Sequence

RestOrd(_aOrd)
SD2->(DbGoTo(_nRegSD2))
SF2->(DbGoTo(_nRegSF2))

Return _aRet

/*
===============================================================================================================================
Programa--------: ROMS025P
Autor-----------: Julio de Paula Paz
Data da Criacao-: 29/03/2019
Descri��o-------: Fun��o que processa a impress�o dos dados do relat�rio - Previs�o de Comiss�o
Parametros------: _cFilialNF = Filial
                  _cCodCli   = Codigo do Cliente
				  _cLojaCli  = Loja do Cliente
				  _cPrefixo  = Prefixo
				  _cNRNF     = Numero NF
Retorno---------: _aParcelas = {{Nr Parcela, Percentual Parcela},{Nr Parcela, Percentual Parcela},...}
===============================================================================================================================
*/   
Static Function ROMS025P(_cFilialNF As Character, _cCodCli As Character, _cLojaCli As Character, _cPrefixo As Character, _cNRNF As Character) As Array
Local _aParcelas As Array
Local _aOrd As Array
Local _nRegAtu As Numeric
Local _nTotParc As Numeric
Local _aTitulosSE1 As Array
Local _nI As Numeric

_aParcelas := {}
_aOrd := SaveOrd({"SE1"})
_nRegAtu := SE1->(Recno())
_nTotParc := 0
_aTitulosSE1 := {}
_nI := 0

Begin Sequence
   SE1->(DbSetOrder(2)) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 

   If SE1->(DbSeek(U_ItKey(_cFilialNF,"E1_FILIAL")+U_ItKey(_cCodCli,"E1_CLIENTE")+U_ItKey(_cLojaCli,"E1_LOJA")+U_ItKey(_cPrefixo,"E1_PREFIXO")+U_ItKey(_cNRNF,"E1_NUM")  ))
      
	  _aParcelas   := {}
      _nTotParc    := 0
      _aTitulosSE1 := {}

      Do While ! SE1->(Eof()) .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == U_ItKey(_cFilialNF,"E1_FILIAL")+U_ItKey(_cCodCli,"E1_CLIENTE")+U_ItKey(_cLojaCli,"E1_LOJA")+U_ItKey(_cPrefixo,"E1_PREFIXO")+U_ItKey(_cNRNF,"E1_NUM")
         If AllTrim(SE1->E1_TIPO) == "NF"
		    If SE1->E1_SALDO > 0    //   1               2             3             4               5              6              7
			   Aadd(_aTitulosSE1,{SE1->E1_PARCELA, SE1->E1_SALDO,SE1->E1_COMIS1,SE1->E1_COMIS2,SE1->E1_COMIS3,SE1->E1_COMIS4, SE1->E1_VALOR})
			EndIf

            _nTotParc += SE1->E1_SALDO
         EndIf
               
         SE1->(DbSkip())
      EndDo
   EndIf

   For _nI := 1 To Len(_aTitulosSE1)
       Aadd(_aParcelas, {_aTitulosSE1[_nI,1],;   // Nr. da Parcela      1
 	                     _aTitulosSE1[_nI,2] / _nTotParc,; // % da Parcela   2
						 _aTitulosSE1[_nI,3],;   // % Comis1  3
						 _aTitulosSE1[_nI,4],;   // % Comis2  4
						 _aTitulosSE1[_nI,5],;   // % Comis3  5
						 _aTitulosSE1[_nI,6],;   // % Comis4  6
						 _aTitulosSE1[_nI,7],;   // Valor do T�tulo  7
						 _aTitulosSE1[_nI,2]})   // Saldo do T�tulo  8
   Next

   If Empty(_aParcelas) //  1     2  3  4  5  6  7   8
      Aadd(_aParcelas, {Space(2), 1, 1, 1, 1 ,1 ,1 , 1})
   EndIf

End Sequence

RestOrd(_aOrd)
SE1->(DbGoTo(_nRegAtu))

Return _aParcelas


/*
===============================================================================================================================
Programa--------: ROMS025R
Autor-----------: Julio de Paula Paz
Data da Criacao-: 29/03/2019
Descri��o-------: Fun��o que processa a impress�o dos dados do relat�rio - Previs�o de Comiss�o
Parametros------: _cParcela     = Numero da Parcela
                  _nBaseComiss  = Valor base de Comiss�o
                  _nPercParcela = Percentual da Parcela  
                  _cFilialNF    = Filial
                  _cCodCli      = Codigo do Cliente
				  _cLojaCli     = Loja do Cliente
				  _cPrefixo     = Prefixo
				  _cNRNF        = Numero NF
Retorno---------: _aRet = {Nr Parcela, Comiss�o 1, Percentual 1, Comiss�o 2, Percentual 2, Comiss�o 3, Percentual 3, 
                           Comiss�o 4, Percentual 4, Comiss�o 4, Percentual 4}
===============================================================================================================================
*/   
Static Function ROMS025R(_cParcela As Character, _nBaseComiss As Numeric, _nPercParcela As Numeric ,_cFilialNF As Character, _cCodCli As Character, _cLojaCli As Character, _cPrefixo As Character, _cNRNF As Character) As Array
Local _aRet As Array
Local _aOrd As Array
Local _nRegAtu As Numeric
Local _nValBaseCom As Numeric
Local _nValCom1 As Numeric
Local _nValCom2 As Numeric
Local _nValCom3 As Numeric
Local _nValCom4 As Numeric
Local _nValCom5 As Numeric
Local _nPerCom1 As Numeric
Local _nPerCom2 As Numeric
Local _nPerCom3 As Numeric
Local _nPerCom4 As Numeric
Local _nPerCom5 As Numeric
Local _nTotalBase As Numeric

_aRet := {}
_aOrd := SaveOrd({"SD2"})
_nRegAtu := SD2->(Recno())
_nValBaseCom := 0
_nValCom1 := 0
_nValCom2 := 0
_nValCom3 := 0
_nValCom4 := 0
_nValCom5 := 0
_nPerCom1 := 0
_nPerCom2 := 0
_nPerCom3 := 0
_nPerCom4 := 0
_nPerCom5 := 0
_nTotalBase := 0

Begin Sequence
   _aRet = {_cParcela, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

   _nValBaseCom := _nBaseComiss 
   If _nValBaseCom == 0
      Break
   EndIf 
   
   _nValCom1 := 0
   _nValCom2 := 0
   _nValCom3 := 0
   _nValCom4 := 0
   _nValCom5 := 0
   _nTotalBase := 0

   SD2->(DbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM   
   SD2->(DbSeek(_cFilialNF+_cNRNF+_cPrefixo+_cCodCli+_cLojaCli))
   Do While ! SD2->(Eof()) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == _cFilialNF+_cNRNF+_cPrefixo+_cCodCli+_cLojaCli
      _nValCom1 += ((SD2->D2_COMIS1 / 100) * _nValBaseCom) 
      _nValCom2 += ((SD2->D2_COMIS2 / 100) * _nValBaseCom) 
      _nValCom3 += ((SD2->D2_COMIS3 / 100) * _nValBaseCom) 
      _nValCom4 += ((SD2->D2_COMIS4 / 100) * _nValBaseCom) 
      _nValCom5 += ((SD2->D2_COMIS5 / 100) * _nValBaseCom) 

      _nTotalBase += _nValBaseCom

      SD2->(DbSkip())
   EndDo

   _nPerCom1 := _nValCom1 / _nTotalBase //_nValBaseCom
   _nPerCom2 := _nValCom2 / _nTotalBase //_nValBaseCom
   _nPerCom3 := _nValCom3 / _nTotalBase //_nValBaseCom
   _nPerCom4 := _nValCom4 / _nTotalBase //_nValBaseCom
   _nPerCom5 := _nValCom5 / _nTotalBase //_nValBaseCom 

   _nValCom1 := (_nPerCom1 * _nValBaseCom) 
   _nValCom2 := (_nPerCom2 * _nValBaseCom) 
   _nValCom3 := (_nPerCom3 * _nValBaseCom) 
   _nValCom4 := (_nPerCom4 * _nValBaseCom) 
   _nValCom5 := (_nPerCom5 * _nValBaseCom) 

   _nPerCom1 := _nPerCom1 * 100
   _nPerCom2 := _nPerCom2 * 100
   _nPerCom3 := _nPerCom3 * 100 
   _nPerCom4 := _nPerCom4 * 100
   _nPerCom5 := _nPerCom5 * 100 

          //    1          2          3          4          5          6          7          8           9         10         11
   _aRet = {_cParcela, _nValCom1, _nPerCom1, _nValCom2, _nPerCom2, _nValCom3, _nPerCom3, _nValCom4, _nPerCom4, _nValCom5, _nPerCom5}

End Sequence

RestOrd(_aOrd)
SD2->(DbGoTo(_nRegAtu))

Return _aRet  

/*
===============================================================================================================================
Programa--------: U_ROMS025I
Autor-----------: Julio de Paula Paz
Data da Criacao-: 21/11/2019
Descri��o-------: Retorna valores num�ricos passados por par�mentro formatado ou n�o.
Parametros------: _nValorDado = Valor do dado num�rico passado por par�metro.
                  _cPicture   = Picture de formata��o.
                  _lFormataN  = Formata Numero.
Retorno---------: _xRet = valor numerico sem formata��o, ou
                        = valor alfanum�rico sem formata��o.                                             
===============================================================================================================================
*/
User Function ROMS025I(_nValorDado As Numeric,_cPicture As Character,_lFormataN As Logical) As Character
Local _xRet As Numeric

_xRet := 0

Default _lFormataN := .F. 
Default _cPicture  := "@E 999,999,999.99"

Begin Sequence
   If _lFormataN
      _xRet := Transform(_nValorDado,_cPicture)
   Else
      _xRet := _nValorDado
   EndIf

End Sequence

Return _xRet
