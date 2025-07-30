/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor        |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
Lucas Borges  | 17/10/2019 | Removidos os Warning na compilação da release 12.1.25. Chamado 28346
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes e Defines da Rotina. 
//====================================================================================================
#Include "Protheus.Ch"
#INCLUDE "APWIZARD.CH"

/*
===============================================================================================================================
Programa----------: CCOM002
Autor-------------: Josué Danich Prestes
Data da Criacao---: 23/07/2015
===============================================================================================================================
Descrição---------: Consulta títulos previstos para pedido de compras - Chamado 10828
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function CCOM002(_ntipo)

Local _aVencto  := {} 
Local _aBrowse  := {}    
Local _aBrowseT  := {}
Local _aArea := (GetArea())
Local _cCodigo  := ""
Local _nValTit  := 0      
Local _nValIpi  := 0      
Local _dDataRef := Ctod("//")        
Local _odlg := NIL
Local _oVencto := NIL
Local _dDataFat := Ctod("//")
Local _cfilial := ""
Local _cpedido := ""
Local _nY := 1    
Local _nC7PRECO  :=  0
Local _nC7QUANT  :=  0
Local _nC7VLDESC :=  0
Local _cC7QUJE   :=  0
Local _nI2		:= 0
Default _ntipo := 1

//se for tipo um lê dados do banco
if _ntipo == 1
    
  //carrega dados do sc7
  _cfilial := SC7->C7_FILIAL
  _cpedido := SC7->C7_NUM

  dbSelectArea("SC7")
  SC7->( dbSetOrder(1) )
  SC7->( dbgotop() )

  If SC7-> ( dbSeek(_cfilial + _cpedido) )

    do while alltrim(SC7->C7_FILIAL)+alltrim(SC7->C7_NUM) == alltrim(_cfilial)+alltrim(_cpedido)     
   
      //só continua se tiver data de faturamento marcada
      if SC7->C7_I_DTFAT > ctod('01/01/2001')  
    
        _nValTit := ( ( ( SC7->C7_PRECO * SC7->C7_QUANT ) - SC7->C7_VLDESC ) / SC7->C7_QUANT ) * ( SC7->C7_QUANT - SC7->C7_QUJE )
        _dDataRef := SC7->C7_I_DTFAT
        _ccodigo := SC7->C7_COND 
        _nvalipi := SC7->C7_IPI
        _dDataFat := SC7->C7_I_DTFAT

        _aVencto := Condicao(_nValTit,_ccodigo,_nvalipi,_dDataRef,0)                          

        For _nY := 1 To Len(_aVencto)
	     
	       //se achar mesmo faturamento e mesmo vencimento só incrementa
	       _nposi := aScan(_aBrowse,{|x| x[1] == SC7->C7_I_DTFAT .and. x[2] == DataValida( _aVencto[_nY][1] ) })
	   
	       if _nposi   > 0
	          _aBrowse[_nposi][3] += _aVencto[_nY][2]
	       else    
	         aadd(_aBrowse,{SC7->C7_I_DTFAT, DataValida( _aVencto[_nY][1] ),_aVencto[_nY][2]})
	        endif
	     
	    Next _nY

      Endif
    
      SC7->( DbSkip ())
      
    enddo
    
  endif
  
else
  
    //procura dados pelo acols
    for _nI2 := 1 To Len( acols )   
   
      //só continua se tiver data de faturamento marcada
      _dDataRef	:= ACOLS[_nI2][aScan(aHeader,{|x|AllTrim(x[2])=="C7_I_DTFAT"})]
      
      if _dDataRef > ctod('01/01/2001')  
    
        _nC7PRECO  :=  ACOLS[_nI2][aScan(aHeader,{|x|AllTrim(x[2])=="C7_PRECO"})]
        _nC7QUANT  :=  ACOLS[_nI2][aScan(aHeader,{|x|AllTrim(x[2])=="C7_QUANT"})]
        _nC7VLDESC :=  ACOLS[_nI2][aScan(aHeader,{|x|AllTrim(x[2])=="C7_VLDESC"})]
        
        //VERIFICA SE NÃO FOR INCLUSÃO PUXA POSSÍVEL QUANTIDADE JÁ ENTREGUE
        If .not. inclui
        
          dbSelectArea("SC7")
          SC7->( dbSetOrder(1) )
          SC7->( dbgotop() )
          SC7-> ( dbSeek( SC7->C7_FILIAL + SC7->C7_NUM + ACOLS[_nI2][aScan(aHeader,{|x|AllTrim(x[2])=="C7_ITEM"})] ) )
          
          _cC7QUJE := SC7->C7_QUJE
          
        Else
        
          _cC7QUJE   :=  0
        
        Endif
        
        _nValTit := ( ( ( _nC7PRECO * _nC7QUANT ) - _nC7VLDESC ) / _nC7QUANT ) * ( _nC7QUANT - _cC7QUJE )
        _ccodigo := ccondicao
        _nvalipi := ACOLS[_nI2][aScan(aHeader,{|x|AllTrim(x[2])=="C7_IPI"})]
        
        _aVencto := Condicao(_nValTit,_ccodigo,_nvalipi,_dDataRef,0)                          

        For _nY := 1 To Len(_aVencto)
	     
	       //se achar mesmo faturamento e mesmo vencimento só incrementa
	       _nposi := aScan(_aBrowse,{|x| x[1] == _dDataRef .and. x[2] == DataValida( _aVencto[_nY][1] ) })
	   
	       if _nposi   > 0
	          _aBrowse[_nposi][3] += _aVencto[_nY][2]
	       else    
	         aadd(_aBrowse,{_dDataRef, DataValida( _aVencto[_nY][1] ),_aVencto[_nY][2]})
	        endif
	     
	    Next _nY

      Endif
    
      SC7->( DbSkip ())
      
    next _nY2
    
endif
  
  
if len(_aBrowse) > 0
  
    //ordena por data de faturamento + data de vencimento
    _aBrowse := aSort( _aBrowse ,,, {|x,y| dtos(x[01])+dtos(x[02]) < dtos(y[01]) + dtos(y[02]) } )

    
    //Converte valor em string e adiciona linha de separação entre faturamentos
    _nY := 1
    _dDatafat := _aBrowse[_nY][1]
  
    For _nY := 1 To Len(_aBrowse)

      if _aBrowse[_nY][1] ==  _dDatafat
      
        aadd(_aBrowseT, { _aBrowse[_nY][1], _aBrowse[_nY][2], TransForm(_aBrowse[_nY][3],"@E 999,999,999.99")})
    
      Else
    
        aadd( _aBrowseT, { "              ", "                    ", "                 "})
        aadd(_aBrowseT, { _aBrowse[_nY][1], _aBrowse[_nY][2], TransForm(_aBrowse[_nY][3],"@E 999,999,999.99")})
        _dDatafat := _aBrowse[_nY][1]
 
      Endif
    
    Next
    
  
	DEFINE MSDIALOG _oDlg TITLE OemToAnsi("Titulos previstos para o saldo do pedido " + alltrim(SC7->C7_FILIAL)+ " / " + alltrim(SC7->C7_NUM)  ) FROM 09,00 TO 28,80 
	                                                                                                        
		@ 005,004 LISTBOX _oVencto FIELDS TITLE OemtoAnsi("        Faturamento"),OemtoAnsi("            Vencimento"),OemtoAnsi("          Valor") SIZE 310,120 PIXEL
		_oVencto:SetArray(_aBrowseT)
		_oVencto:bLine := {|| _aBrowseT[_oVencto:nAt] }
	
	DEFINE SBUTTON FROM 130 ,280 TYPE 1 PIXEL ACTION (_oDlg:End()) ENABLE OF _oDlg Pixel
	
    ACTIVATE MSDIALOG _oDlg CENTERED
	
Else
  
    alert("Não há items válidos com data de faturamento no pedido " + _cfilial + " / " + _cpedido)
  
EndIf


RestArea(_aArea)

Return