#INCLUDE "RWMAKE.CH"

#DEFINE _ENTER CHR(13)+CHR(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบPrograma  ณ FA070CA4 บ Autor ณ Fabiano Dias da Silva บ Data da Criacao  ณ 15/03/2011                						บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDescricao ณ O ponto de entrada FA070CA4 sera executado apos confirmacao do cancelamento da baixa do contas a receber,    บฑฑ
ฑฑบ          ณ para diante disso efetuar o cancelamento do debito gerado na comissao da baixa.         						บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 																										        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ 															                               						บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ 																  							                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUsuario   ณ                                                                                          					บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSetor     ณ OMS                                                                                				   			บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            			          	ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                   						บฑฑ
ฑฑฬออออออออออัออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออัออออออออออออออออออออออออออออออออออัอออออออออออออนฑฑ
ฑฑบAutor     ณ Data     ณ Motivo da Alteracao  				               ณUsuario(Filial+Matricula+Nome)    ณSetor        บฑฑ
ฑฑบฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤบฑฑ
ฑฑบ          ณ          ณ                    							   ณ                                  ณ   	        บฑฑ
ฑฑศออออออออออฯออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออฯออออออออออออออออออออออออออออออออออฯอออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function FA070CA4

Local _lRet     := .T.  
Local _cNumero  := SE1->E1_NUM
Local _cSerie   := IIF(SE1->E1_PREFIXO <> 'MAN',SE1->E1_PREFIXO,Space(3)) 
Local _cParcela := SE1->E1_PARCELA
Local _cTipo    := SE1->E1_TIPO
Local _cCliente := SE1->E1_CLIENTE
Local _cLoja    := SE1->E1_LOJA
Local _cSeq     := SE5->E5_SEQ  
Local _cMotBaixa:= SE5->E5_MOTBX   
    
Local _cAlias  := ""
Local _cFiltro := "%"
Local _aArea   := {}
Local _aAlias  := {}  

Local _aMes    :={"Janeiro","Fevereiro","Mar็o","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ  Salva a area. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
CtrlArea(1,@_aArea,@_aAlias,{"SE1","SE5","SE3","SEF"})

/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se o motivo da baixa foi igual a NOR, pois diante disso ณ
//ณos titulos com baixa igual a NOR passaram por uma avaliacao      ณ
//ณpara constatar se a comissao ja foi fechada.                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/   
If _cMotBaixa == 'NOR' 

	_cAlias:= GetNextAlias() 
		    
	/*
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDefine filtros da query.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	*/                         
	_cFiltro += " AND E3_FILIAL = '"  + xFilial("SE3") + "'"
	_cFiltro += " AND E3_NUM = '"     + _cNumero       + "'"
	_cFiltro += " AND E3_SERIE = '"   + _cSerie        + "'"
	_cFiltro += " AND E3_PARCELA = '" + _cParcela      + "'"
	_cFiltro += " AND E3_TIPO = '"    + _cTipo         + "'"
	_cFiltro += " AND E3_CODCLI = '"  + _cCliente      + "'"
	_cFiltro += " AND E3_LOJA = '"    + _cLoja         + "'"
	_cFiltro += " AND E3_SEQ = '"     + _cSeq          + "'"
	_cFiltro += " AND E3_I_FECH = 'S'"
	_cFiltro += " AND E3_I_ORIGE <> 'MT100AGR'" //Esta clausula foi solicitada a sua inclusao por Tiago Correa no dia 13/06/11
	_cFiltro += "%"
	
	/*
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se a comissao encontra-se com o status fechada.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	*/  
	BeginSql alias _cAlias	
		SELECT
	      E3_EMISSAO
		FROM
		      %table:SE3%
		WHERE
		      D_E_L_E_T_ = ' '
		      %exp:_cFiltro%				
	EndSql   
	
	dbSelectArea(_cAlias)
	(_cAlias)->(dbGotop())
	              	
	/*
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณA baixa que esta sendo feito o cancelamento ou exclusao nao         ณ
	//ณpodera ser excluida pois a baixa encontra-se com a comissao fechada.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	*/
	If (_cAlias)->(!Eof())
	
		_lRet:= .F.	  
		
		xMagHelpFis("INFORMAวรO",;
		            "Nใo poderแ ser realizado o cancelamento ou exclusใo da baixa do tํtulo! Pois: Essa baixa gerou comissใo no m๊s de " +;
		             _aMes[Val(SubStr((_cAlias)->E3_EMISSAO,5,2))] + " de " + SubStr((_cAlias)->E3_EMISSAO,1,4)+ " onde jแ foi paga a comissใo ao Vendedor.",;
		            "Pois o tํtulo com os dados especificados abaixo encontra-se com a comissใo fechada. " + _ENTER  +;
		            'Tํtulo: ' + _cNumero + ' - '  + 'Parcela: ' + _cParcela + ' - ' +;
		            'Prefixo: '+ _cSerie  + _ENTER  + 'Cliente: ' + _cCliente + ' - ' + 'Loja: ' + _cLoja  + _ENTER  +;
		            'Sequencia da baixa: '+ _cSeq )	 
	EndIf     
	
	
	/*
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se podera ser realizada a exclusao da comissao de debito ณ
	//ณgerada por uma baixa, o padrao do sistem nao trata esta questao.  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	*/  
  	If _lRet .And. _cTipo == 'NCC'         
  
		dbSelectArea("SE3")					 
		SE3->(dbOrderNickName("IT_COMISSA"))//E3_FILIAL+E3_NUM+E3_SERIE+E3_PARCELA+E3_TIPO+E3_CODCLI+E3_LOJA+E3_SEQ                                                                                           
		If SE3->(dbSeek(xFilial("SE3") + _cNumero + _cSerie + _cParcela + _cTipo + _cCliente + _cLoja + _cSeq))
		     
			While SE3->(!Eof()) .And.;
			      SE3->E3_FILIAL == xFilial("SE3") .And. SE3->E3_NUM == _cNumero .And. SE3->E3_SERIE == _cSerie .And. SE3->E3_PARCELA == _cParcela .And.;
			      SE3->E3_TIPO == _cTipo .And. SE3->E3_CODCLI == _cCliente .And. SE3->E3_LOJA == _cLoja .And. SE3->E3_SEQ == _cSeq
			        	      
					/*
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณVerifica se o debito da comissao foi gerado a partir da baixa de uma NCC.ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					*/
					If AllTrim(SE3->E3_I_ORIGE) == 'SACI008'
					
						RecLock("SE3",.F.) 
						
							dbDelete()
									
						SE3->(MsUnlock())     
					
					EndIf
			      	
			SE3->(dbSkip())
			EndDo      		
		EndIf   	
	EndIf          

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Restaura a area. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
CtrlArea(2,_aArea,_aAlias)

Return _lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CtrlArea บ Autor ณ Microsiga          บ Data ณ  00/00/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Static Function auxiliar no GetArea e ResArea retornando   บฑฑ
ฑฑบ          ณ o ponteiro nos Aliases descritos na chamada da Funcao.     บฑฑ
ฑฑบ          ณ Exemplo:                                                   บฑฑ
ฑฑบ          ณ Local _aArea  := {} // Array que contera o GetArea         บฑฑ
ฑฑบ          ณ Local _aAlias := {} // Array que contera o                 บฑฑ
ฑฑบ          ณ                     // Alias(), IndexOrd(), Recno()        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ // Chama a Funcao como GetArea                             บฑฑ
ฑฑบ          ณ P_CtrlArea(1,@_aArea,@_aAlias,{"SL1","SL2","SL4"})         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ // Chama a Funcao como RestArea                            บฑฑ
ฑฑบ          ณ P_CtrlArea(2,_aArea,_aAlias)                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nTipo   = 1=GetArea / 2=RestArea                           บฑฑ
ฑฑบ          ณ _aArea  = Array passado por referencia que contera GetArea บฑฑ
ฑฑบ          ณ _aAlias = Array passado por referencia que contera         บฑฑ
ฑฑบ          ณ           {Alias(), IndexOrd(), Recno()}                   บฑฑ
ฑฑบ          ณ _aArqs  = Array com Aliases que se deseja Salvar o GetArea บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtrlArea(_nTipo,_aArea,_aAlias,_aArqs)

Local _nN := 0

// Tipo 1 = GetArea()
If _nTipo == 1
	_aArea := GetArea()
	For _nN := 1 To Len(_aArqs)
		DbSelectArea(_aArqs[_nN])
		AAdd(_aAlias,{ _aArqs[_nN], IndexOrd(), Recno() })
	Next
	// Tipo 2 = RestArea()
Else
	For _nN := 1 To Len(_aAlias)
		DbSelectArea(_aAlias[_nN,1])
		DbSetOrder(_aAlias[_nN,2])
		DbGoto(_aAlias[_nN,3])
	Next
	RestArea(_aArea)
Endif

Return  