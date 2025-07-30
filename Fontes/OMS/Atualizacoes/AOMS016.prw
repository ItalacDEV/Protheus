/*
===============================================================================================================================
                                    ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL
===============================================================================================================================
       Autor      |    Data    |                                           Motivo                                              
-------------------------------------------------------------------------------------------------------------------------------
 Alex Wallauer    | 24/08/2017 | Ajuste para o Tratamento da Opera��o Triangular - Chamado 14473
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================
#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"
/*
===============================================================================================================================
Programa----------: AOMS016()
Autor-------------: Frederico O. C. Jr
Data da Criacao---: 30/07/2009 
===============================================================================================================================
Descri��o---------: Executado quando o cliente ou vendedor sao digitados no pedido de venda, pois o percentual de comissao dos
                    produtos deve ser recalculado, sempre que uma destas entidades eh digitada ou alterada no pedido.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================*/
User Function AOMS016()

Local aArea :=	GetArea()
Local nX := 0
Local nN := N //Restaura o valor de n, que eh a variavel publica do protheus que indica a linha do aCols.

//Processa todos os itens do Pedido.
For nX := 1 To Len(aCols)
	//Muda o valor de N.
	N := nX
	
	//Chama a funcao de recalculo da comissao.
	U_AOMS013(.T.)
Next nX

//Restaura o valor da variavel padrao.
N := nN

//Refresh para atualizacao do Rodape do Pedido de Venda.
If type("oGetDad") = 'O' .AND. type("oGetDad:oWnd") = 'O'//Ajuste para o Tratamento da Opera��o Triangular
	Ma410Rodap(oGetDad)
	oGetDad:Refresh()       
EndIf

RestArea(aArea)
Return