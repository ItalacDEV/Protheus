/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           |
------------------:------------:----------------------------------------------------------------------------------------------:
	Josué Danich   | 16/02/2016 | Incluida pergunta de continua caso seja liberação completa - Chamado 14099                   | 
------------------:------------:----------------------------------------------------------------------------------------------:
  Josué Danich    | 19/02/2016 | Ajuste de campo de liberação completa - Chamado 14097                                        |
===============================================================================================================================
*/
//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#include "protheus.ch"
#include "topconn.ch"

/*
===============================================================================================================================
Programa----------: MT450MAN
Autor-------------: Talita Teixeira
Data da Criacao---: 14/02/2014    
===============================================================================================================================
Descrição---------: Validacao do usuario para liberação de credito manual através da rotina Analise Credito Pedido 
===============================================================================================================================
Uso---------------: Italac 
===============================================================================================================================
Parametros--------: Lógico - Procede ou não a liberação de crédito do pedido
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User Function MT450MAN()

Local _aArea 	:= GetArea()
Local _lRet		:= .F.
Local _cUsuario	:= U_UCFG001(1)
Local _aUsuAut	:= {}
Local _cTemp		:= ""  

//================================================================================
//Verifica se usuário tem permissão para liberar crédito
//================================================================================
DbSelectArea("ZZL")  
ZZL->( DbSetOrder(1) )
ZZL->( DbSeek(xFilial("ZZL")+_cUsuario) )

If ZZL->ZZL_LIBCRE == 'S'

	aAdd(_aUsuAut, _cTemp)
	_cTemp := ""
	_lRet := .T.		

Else

	xmaghelpfis("INFORMAÇÃO","Usuário sem acesso para liberação de pedido por crédito ","Favor contactar o departamento de informática informando do erro ocorrido.")

EndIf	

//================================================================================
//Verifica se é liberação completa e se usuário confirma
//================================================================================
SC5->( Dbsetorder(1))
SC5->( Dbseek(SC9->C9_FILIAL+SC9->C9_PEDIDO) )

If _lret .and. SC5->C5_I_LIBC == 1 //Se teve liberação completa inicial

	//Alerta usuário
	If messagebox("Esse pedido terá o crédito liberado de forma permanente! Confirma?", "Liberação Completa", 52) != 6
	
		_lRet := .F.
		Reclock("SC5",.F.)

		//Marca C5_I_LIBC sem liberação completa
		SC5->C5_I_LIBC := 0
		
		SC5->( Msunlock() )
		
		
	Else
	
		Reclock("SC5",.F.)

		//Marca C5_I_LIBC com liberação completa
		SC5->C5_I_LIBC := 2
		
		SC5->( Msunlock() )
	
	Endif
	
Endif
	 
	
RestArea(_aArea)
	
Return _lRet