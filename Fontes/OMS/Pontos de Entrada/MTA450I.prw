/*
=====================================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL
=====================================================================================================================================
       Autor      |    Data    |                                             Motivo                                                 |
------------------:------------:----------------------------------------------------------------------------------------------------:
 Jerry            | 11/02/2020 | Alterado Avaliação de Crédito tratando PV com produto Queijo e Cond. de Pagto A Vista. Chamado 31881
=====================================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#Include	"Protheus.Ch"

/*
===============================================================================================================================
Programa----------: MTA450I
Autor-------------: Josué Danich Prestes
Data da Criacao---: 16/02/2016
===============================================================================================================================
Descrição---------: PE para gravar lib completa na tela de liberação de crédito (MATA450) - Chamado 14099
===============================================================================================================================
Uso---------------: Italac 
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/

User function MTA450I()

Local _ntotal := 0
Local _aarea 	:= GetArea()     
Local _ntolporc := u_itgetmv("IT_TOLPC",10) //Percentual Tolerância para Produto PA do Tipo Queijo.

SC5->( Dbsetorder(1))
SC5->( Dbseek(SC9->C9_FILIAL+SC9->C9_PEDIDO) )

If SC5->C5_I_LIBC == 1 //Se teve liberação completa inicial

	Reclock("SC5",.F.)

	//Marca C5_I_LIBC com liberação completa para que ao PE na avaliação de crédito sempre aprove esse pedido
	SC5->C5_I_LIBC := 2

	//Grava aprovador, data e hora da liberação completa
	SC5->C5_I_LIBCA 	:= cusername
	SC5->C5_I_LIBCD	 	:= date()
	SC5->C5_I_LIBCT 	:= time()
	SC5->C5_I_LIBL	:=  DATE() + 7

	//Grava valor do pedido no momento da liberação
	SC6->( Dbsetorder(1))
	SC6->( Dbseek(SC5->C5_FILIAL+SC5->C5_NUM) )

	Do while SC6->C6_FILIAL == SC5->C5_FILIAL .and. SC6->C6_NUM == SC5->C5_NUM

		If (posicione("SB1",1,xfilial("SB1")+alltrim(SC6->C6_PRODUTO),"B1_I_QQUEI") == 'S')
			_ntotal +=  (SC6->C6_VALOR + ( (SC6->C6_VALOR*_ntolporc)/100) )
		Else 
			_ntotal +=  SC6->C6_VALOR
		EndIf

 		SC6->( Dbskip() )
	
	Enddo

	SC5->C5_I_LIBCV	:= _ntotal 

	SC5->( Msunlock() )

	Restarea(_aarea)
	
Endif
						
Return