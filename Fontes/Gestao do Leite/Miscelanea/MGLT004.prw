/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                            
-------------------------------:-----------------------------------------------------------------------------------------------
 Alexandre Villar | 22/12/2015 | Tratativa na cl�usula "ORDER BY" para remover a refer�ncia num�rica. Chamado 13062            
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 02/02/2018 | Filtrar filiais que tem no SmartQuestion e Ajustes de tela para a vers�o 12. Chamados: 23351
-------------------------------------------------------------------------------------------------------------------------------
 Lucas Borges     | 28/09/2018 | Retirada valida��o do campo ZLU_DESPRO e transferida para o Privil�gio. Rotina reescrita e 
 				  |			   | alterada de AGLT026 para MGLT004. Chamados: 26404
===============================================================================================================================
*/

#INCLUDE "PROTHEUS.CH"

/*
===============================================================================================================================
Programa----------: MGLT004
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 28/09/2018
===============================================================================================================================
Descri��o---------: Rotina para Inativa��o de Produtores que n�o tiveram coleta de leite no per�odo informado
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function MGLT004()

Private _cPerg		:= "MGLT004"
Private _oSelf		:= nil

//============================================
//Cria interface principal
//============================================
tNewProcess():New(	_cPerg											,; // Fun��o inicial
					"Inativa Produtores"						,; // Descri��o da Rotina
					{|_oSelf| MGLT004P(_oSelf) }				,; // Fun��o do processamento
					"Rotina para efetuar a desativa��o dos produtores que n�o realizaram " +;
					"movimenta��o de entrada de Leite de acordo com os par�metros informados." ,; // Descri��o da Funcionalidade
					_cPerg											,; // Configura��o dos Par�metros
					{}												,; // Op��es adicionais para o painel lateral
					.F.												,; // Define cria��o do Painel auxiliar
					0												,; // Tamanho do Painel Auxiliar
					''												,; // Descri��o do Painel Auxiliar
					.T.												 ) // Op��o para cria��o de apenas uma r�gua de processamento


Return

/*
===============================================================================================================================
Programa----------: MGLT004P
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 28/09/2018
===============================================================================================================================
Descri��o---------: Realiza o processamento da rotina.
===============================================================================================================================
Parametros--------: _oSelf
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
Static Function MGLT004P(_oSelf)

Local _cFiltro		:= "%"
Local _cFiltroFilial:= SuperGetMV("LT_FILPROD", .F. ,"01,02,04,06,09,0A,0B,40,10,11,20,23,24,25") //filiais com integra��o com o SmartQuestion
Local _cAlias		:= GetNextAlias()
Local _nCountRec	:= 0
Local _nI,_nSQ		:= 0
Local _nProcessado	:= 0
Local _aLstFor		:= {}

_oSelf:SetRegua1(2)
_oSelf:IncRegua1("Buscando produtores...")
//====================================================================================================
// Monta filtro para os Setores informados
//====================================================================================================
_cFiltro  += " AND ZL3.ZL3_SETOR IN "+ FormatIn( AllTrim(MV_PAR03) , ';' )
_cFiltro  += "%"

//====================================================================================================
// SQL para verificar os produtores dos Setores que nao movimentaram entrada de leite no periodo
//====================================================================================================
BeginSQL Alias _cAlias
SELECT A2.A2_COD, A2.A2_LOJA, A2.A2_NOME
  FROM %Table:SA2% A2, %Table:ZL3% ZL3
 WHERE A2.D_E_L_E_T_ = ' '
   AND ZL3.D_E_L_E_T_ = ' '
   AND A2.A2_FILIAL = %xFilial:SA2%
   AND A2.A2_L_LI_RO = ZL3.ZL3_COD
   AND A2.A2_COD LIKE 'P%'
   AND A2_L_ATIVO = 'S'
   %exp:_cFiltro%
   AND A2.A2_COD NOT IN
       (SELECT ZLD_RETIRO
          FROM %Table:ZLD% ZLD
         WHERE ZLD.D_E_L_E_T_ = ' '
           AND ZLD.ZLD_FILIAL = %xFilial:ZLD%
           AND ZLD_DTCOLE BETWEEN %exp:DToS(MV_PAR01)% AND %exp:DToS(MV_PAR02)%
           AND ZLD.ZLD_RETIRO = A2.A2_COD
           AND ZLD.ZLD_RETILJ = A2.A2_LOJA
        UNION ALL
        SELECT ZLW_RETIRO
          FROM %Table:ZLW% ZLW
         WHERE ZLW.D_E_L_E_T_ = ' '
           AND ZLW.ZLW_FILIAL = %xFilial:ZLW%
           AND ZLW_DTCOLE BETWEEN %exp:DToS(MV_PAR01)% AND %exp:DToS(MV_PAR02)%
           AND ZLW.ZLW_RETIRO = A2.A2_COD
           AND ZLW.ZLW_RETILJ = A2.A2_LOJA)
 ORDER BY A2.A2_COD, A2.A2_LOJA
EndSQL

Count To _nCountRec
(_cAlias)->( DbGotop() )
_oSelf:IncRegua1("Montando janela de sele��o...")

//====================================================================================================
// Verifica os dados selecionados e exibe tela para sele��o dos produtores
//====================================================================================================
If _nCountRec > 0
	Do While (_cAlias)->(!Eof())
		aAdd( _aLstFor , { .F. , (_cAlias)->A2_COD , (_cAlias)->A2_LOJA , (_cAlias)->A2_NOME } )
		(_cAlias)->( DBSkip() )
	EndDo
	(_cAlias)->( DBCloseArea() )
	
	DBSelectArea("SA2")
	SA2->( DBSetOrder(1) )
	//====================================================================================================
	// Exibe a tela e confirma��o antes de processar a atualiza��o de status
	//====================================================================================================
	Do While .T.
	
		If U_ITListBox(	"Desativa��o de Fornecedores inativos",{ "X" , "C�digo" , "Loja" , "Nome" } , @_aLstFor , .T. , 2 ,;
					AllTrim(Str(_nCountRec,9))+" registros encontrados no Per�odo solicitado de "+ DToC(MV_PAR01) +" at� "+ DToC(MV_PAR02)+" dos setores: "+AllTrim(MV_PAR03))
			If MsgYesNo("Confirma o processamento de desativa��o dos Fornecedores selecionados ?")
				_oSelf:SetRegua2(_nCountRec)
				_nProcessado:=0
				_nSQ:=0
				For _nI := 1 To Len(_aLstFor)
					_oSelf:IncRegua2("Processando a desativa��o ["+ StrZero(_nI,6) +"] de ["+ StrZero(Len(_aLstFor),6) +"]")
						If _aLstFor[_nI][01]
						setAtivo( _aLstFor[_nI][02] , _aLstFor[_nI][03] , _cFiltroFilial, @_nSQ )
						_nProcessado++
					EndIf
				Next _nI
				If _nProcessado = 0
					MsgStop("Nenhum produtor marcado Marque pelo menos um produtor.","MGLT00402")
					Loop
				Else
					MsgInfo("Foram inativados "+ALLTRIM(STR(_nProcessado))+" produtores com sucesso e "+ALLTRIM(STR(_nSQ))+" marcado(s) para envio para o SmartQuestion!","MGLT00403")
					Exit
				EndIf
			Else
				Loop
			EndIf
		Else
			Return(.F.)
		EndIf
		Exit
	EndDo

Else
	MsgAlert("N�o foram encontrados registros para processar com os filtros informados! Verifique os par�metros digitados.","MGLT00404")
	Return()
EndIf

Return

/*
===============================================================================================================================
Programa----------: setAtivo
Autor-------------: Lucas Borges Ferreira
Data da Criacao---: 28/09/2018
===============================================================================================================================
Descri��o---------: Inativa o produtor
===============================================================================================================================
Parametros--------: cpProd -> c�digo que ser� inativado
------------------: cpLoja -> loja que ser� inativada
------------------: _cFiltroFilial -> filiais que possuem integra��o com SmartQuestion
------------------: _nSQ -> Contador de registros alterados para integra��o
===============================================================================================================================
Retorno-----------: _nSQ -> Incrementa o contador
===============================================================================================================================
*/
Static Function setAtivo( cpProd , cpLoja , _cFiltroFilial, _nSQ )

SA2->( DBSeek( xFilial("SA2") + cpProd + cpLoja ) )

SA2->( RecLock( "SA2" , .F. ) )
SA2->A2_L_ATIVO	:= 'N'
SA2->A2_L_DTDES	:= SubStr( DtoS(MV_PAR01) , 5 , 2 ) + SubStr( DtoS( MV_PAR02 ) , 1 , 4 )
If SubStr( SA2->A2_L_LI_RO,1,2) $ _cFiltroFilial
	_nSQ++
	SA2->A2_L_SMQST := 'P'
EndIf
SA2->( MsUnLock() )

Return