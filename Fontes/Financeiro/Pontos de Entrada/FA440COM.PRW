/*
===============================================================================================================================
               ULTIMAS ATUALIZAÇÕES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
 Autor            |    Data    |                              Motivo                      										 
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 09/12/2015 | Validacao e gravacao e log para Gestao de Fechamento de Comissao - Chamado 11158                 
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 06/01/2016 | Aj calc do último mês do ano na det. de data ínicio e data fim  - Chamado 13540
-------------------------------------------------------------------------------------------------------------------------------
 Josué Danich     | 17/12/2018 | Workaround para calcular vend bloqueado - Chamado 26771  
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 14/01/2020 | Alterar rotina recalculo comissões para permitir usuário selecionar opcão Ambos. Chamado 31607. 
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#define	MB_OK				0
/*
===============================================================================================================================
Programa----------: FA440COM
Autor-------------: Josué Danich Prestes
Data da Criacao---: 27/07/2015
===============================================================================================================================
Descrição---------: P.E. para validar se rotina de recalculo pode rodar
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
*/

User Function FN440COM()

Local _cDataF    	:= GetMv("IT_COMFECH")  // Data do fechamento
Local _nmes      	:= month(stod(substr(_cDataf,4,4)+substr(_cDataf,1,2)+'01'))
Local _nano      	:= year(stod(substr(_cDataf,4,4)+substr(_cDataf,1,2)+'01'))
Local _npar5     	:= u_itGetMv("IT_FIN44005",2) // mv_par05 = Considera Juros    ? Sim/NÆo 
Local _npar6     	:= u_itGetMv("IT_FIN44006",1) // mv_par06 = Considera Descontos? Sim/NÆo   
Local _npar7     	:= u_itGetMv("IT_FIN44007",2) // mv_par07 = Calcula Comiss s/NCC? Sim/NÆo     
//Local _npar8     	:= u_itGetMv("IT_FIN44008",3) // mv_par08 = Calcular           ? Ambas/Emissao/Baixa  
Local _cPar8     	:= u_itGetMv("IT_FIN44008","13") // mv_par08 = Calcular           ? Ambas/Emissao/Baixa  
Local _npar9     	:= u_itGetMv("IT_FIN44009",1) // mv_par09 = Considera Data     ? Data Baixa/Data Disponib.  
Local _nparA     	:= u_itGetMv("IT_FIN4400A",1) // mv_par10 = Comis. Vend. Bloqueado ?      
Local _nparB     	:= u_itGetMv("IT_FIN4400B",1) // mv_par11 = Calc.Comiss.s/ RA ?           
Local _cmensagem 	:= " "
Local _aAlertas 	:= {}
Local _ni 			:= 1
Local _ddataf 	:= date()
Local _cDataF34 	:= ""
Local _nmes34    	:= 0
Local _nano34   	:= 0

//================================================================================
//Verifica se usuário pode rodar a rotina
//================================================================================

DBSelectArea('ZZL')
ZZL->( DBSetOrder(3) )

If !(ZZL->( DBSeek( xFilial('ZZL') + RetCodUsr() ) ) .And. ZZL->ZZL_ADMCMS == 'S')

    Alert("Usuário " + alltrim(substr(cUsuario,7,15)) + " sem permissão para cálculo de comissões!") 
    
    //======================================================================================
    //muda data inicial e data final para uma data impossível de modo que não rode o cálculo
    //======================================================================================
    mv_par01 = stod('20010101')
    mv_par02 = stod('20010101')
    return     

End If



_dDataf := stod(strzero(_nano,4)+strzero(_nmes,2)+"01")

//================================================================================
//verifica se as datas não afetam período de comissão já fechado
//================================================================================

If mv_par01 < _dDataF .or.mv_par02 < _dDataF
  
    aadd(_aalertas,"Período até " + dtoc(_dDataF-1) + " já encerrado!")
  
End If 


//================================================================================	
//se está no gestão de fechamento de comissões força a data para o mês inteiro
//================================================================================
If alltrim(funname()) == 'MOMS009'


 	_cDataF34 	:= ZC9->ZC9_COMP  // Data do fechamento posicionado
 	_nmes34   	:= month(stod(substr(_cDataf34,4,4)+substr(_cDataf34,1,2)+'01'))
 	_nano34   	:= year(stod(substr(_cDataf34,4,4)+substr(_cDataf34,1,2)+'01'))
	
	If MV_PAR01 != STOD(strzero(_nano34,4)+strzero(_nmes34,2)+'01')
	
		aadd(_aalertas,"Data inicial precisa ser 01/" + strzero(_nmes34,2) + "/" + substr(strzero(_nano34,4),3,2)+ ".")
	
	Endif
	
	If _nmes34 == 12
	
		_nmes34 := 1
		_nano34++
		
	Else
	
		_nmes34++
		
	Endif
	
	If MV_PAR02 !=  STOD(strzero(_nano34,4)+strzero(_nmes34,2)+'01') - 1
	
		aadd(_aalertas,"Data final precisa ser " + dtoc(STOD(strzero(_nano34,4)+strzero(_nmes34,2)+'01') - 1) + ".")
	
	Endif
	
Endif

//================================================================================	
//verifica se usuário pode mudar parâmetros
//================================================================================

DBSelectArea('ZZL')
ZZL->( DBSetOrder(3) )

If !(ZZL->( DBSeek( xFilial('ZZL') + RetCodUsr() ) ) .And. ZZL->ZZL_RECOM == "S")

   //================================================================================
  //Verifica se perguntas estão respondidas de acordo com parâmetros
  //================================================================================

  // mv_par05 = Considera Juros    ? Sim/NÆo                                  
  if mv_par05 != _npar5
 
    if _npar5 == 1
      aadd(_aalertas,"Considera Juros precisa ser igual a Sim")
    Else
      aadd(_aalertas,"Considera Juros precisa ser igual a Não")
    Endif
    
  endif

  // mv_par06 = Considera Descontos? Sim/NÆo   
  if mv_par06 != _npar6
 
    if _npar6 == 1
      aadd(_aalertas,"Considera Descontos?  precisa ser igual a Sim")
    Else
      aadd(_aalertas,"Considera Descontos?  precisa ser igual a Não")
    Endif
    
  endif

  // mv_par07 = Calcula Comiss s/NCC? Sim/NÆo       
  if mv_par07 != _npar7
 
    if _npar7 == 1
      aadd(_aalertas,"Calcula Comiss s/NCC? precisa ser igual a Sim")
    Else
      aadd(_aalertas,"Calcula Comiss s/NCC? precisa ser igual a Não")
    Endif
    
  endif

  // mv_par08 = Calcular ? Ambas/Emissao/Baixa   				
  if !(Str(mv_par08,1) $ _cPar8) 
    if "1" $ _cPar8 // _npar8 == 1
      aadd(_aalertas,"Calcular precisa ser igual a Ambas")
    Elseif "2" $ _cPar8 // _npar8 == 2
      aadd(_aalertas,"Calcular precisa ser igual a Emissao")
    else
      aadd(_aalertas,"Calcular precisa ser igual a Baixa")
    Endif
    
  endif

  // mv_par09 = Considera Data     ? Data Baixa/Data Disponib.    
  if mv_par09 != _npar9
 
    if _npar9 == 1
      aadd(_aalertas,"Considera Data precisa ser igual a Baixa")
    Else
      aadd(_aalertas,"Considera Data precisa ser igual a Disponib.")
    Endif
    
  endif
  
  // mv_par10 = Comis. Vend. Bloqueado ?   
  if mv_par10 != _nparA
 
    if _nparA == 1
      aadd(_aalertas,"Comis. Vend. Bloqueado ? precisa ser igual a Sim")
    Else
      aadd(_aalertas,"Comis. Vend. Bloqueado ? precisa ser igual a Não")
    Endif
    
  endif
  
  // mv_par09 = Considera Data     ? Data Baixa/Data Disponib.    
  if mv_par11 != _nparB
 
    if _nparB == 1
      aadd(_aalertas,"Calc.Comiss.s/ RA precisa ser igual a Sim")
   Else
      aadd(_aalertas,"Calc.Comiss.s/ RA precisa ser igual a Não")
    Endif
    
  endif

endif

//================================================================================
//se teve qualquer alerta na verificação monta mensagem e impede o processamento
//================================================================================

if len(_aalertas) > 0
  
    _cMensagem := "<html>"
	_cMensagem += "<body>"
	_cMensagem += "<strong>"
	_cMensagem += "<p>"
	_cMensagem += "Foram encontrados problemas com o processo!<br>"
	_cMensagem += "Recálculo não será efetuado, corrija o processo e execute novamente.<br>"
	_cMensagem += "</p>
	_cMensagem += "</strong>
	_cMensagem += "<hr>"
		
   for _ni = 1 to len(_aalertas)
  
  		_cMensagem += "<p>"
		_cMensagem += _aalertas[_ni] 
		_cMensagem += "</p>
		if _ni < len(_aalertas) 
		  _cMensagem += "<hr>"
		endif
		
	next
	
	_cMensagem += "</body>"
	_cMensagem += "</html>"
				
	MessageBox(_cMensagem, "Problema no processo", MB_OK)
  
    //======================================================================================
    //muda data inicial e data final para uma data impossível de modo que não rode o cálculo
    //======================================================================================
    
 	 mv_par01 = stod('20010101')
   	 mv_par02 = stod('20010101')
 
else

	//================================================================================
	//se está tudo ok grava na ZC8 o log da execução com os parâmetros usados
	//================================================================================
	
	_cmensagem := "Parâmetros: " + dtoc(mv_par01) + "|" +  dtoc(mv_par02)
	_cmensagem += "|"+mv_par03+"|"+mv_par04+"|"+iif(mv_par05==1,"Sim","Não")+"|"+iif(mv_par06==1,"Sim","Não")+"|"+iif(mv_par07==1,"Sim","Não")
	_cmensagem += "|"+iif(mv_par08==1,"Sim","Não")+"|"+iif(mv_par09==1,"Sim","Não")+"|"+iif(mv_par10==1,"Sim","Não")+"|"+iif(mv_par11==1,"Sim","Não")
	
	RecLock("ZC8",.T.)
 
	ZC8->ZC8_FILIAL     := xFilial("ZC8")   
	ZC8->ZC8_SEQ        := U_MOMS009C()  //Gera nova sequência do ZC8
	ZC8->ZC8_ROTINA     := "Recalculo de Comissao - Filial " + cfilant + " - " + funname()
	ZC8->ZC8_DATA       := DATE()
	ZC8->ZC8_HORA       := TIME()
	ZC8->ZC8_USER       := CUSERNAME
	ZC8->ZC8_CODUSU     := __CUSERID
	ZC8->ZC8_OBS        := _cmensagem
	ZC8->ZC8_COMP       := strzero(_nmes,2) + "/" + strzero(_nano,4)
 
	ZC8->(MSUNLOCK())
	
endif  


Return