/*
===============================================================================================================================
               ULTIMAS ATUALIZA��ES EFETUADAS - CONSULTAR LOG DO VERSIONADOR PARA HISTORICO COMPLETO
===============================================================================================================================
       Autor      |    Data    |                                             Motivo                                           
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 29/12/2021 | Inclus�o de rotina para visualizar legendas dos cadastro clientes. Chamado 30177.
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 17/02/2022 | Inclus�o da Op��o Vincula��o Clientes X Tipos de Transporte no menu. Chamado 37652. 
-------------------------------------------------------------------------------------------------------------------------------
 Julio Paz        | 02/12/2022 | Desenvolver rotina para listar Cadastro de Condi��es de Pagamento Personalizada. Chamado 41566
===============================================================================================================================
*/

//====================================================================================================
// Definicoes de Includes da Rotina.
//====================================================================================================

#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*
===============================================================================================================================
Programa--------: CRM980MDef
Autor-----------: Igor Melga�o
Data da Criacao-: 24/08/2021
===============================================================================================================================
Descri��o---------: Ponto de entrada para inclus�o de op��es de menu, no MBrowse do cadastro de clientes. Permite a inclus�o de
                    op��es de menu no array arotina do cadastro de clientes. Substitui o ponto MA030ROT.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: _aRot = Array com as op��es de menu a serem adicinadas no array aRotina do cadastro de clientes.
===============================================================================================================================
*/
User Function CRM980MDef()
Local aRotina := {}
//----------------------------------------------------------------------------------------------------------
// [n][1] - Nome da Funcionalidade
// [n][2] - Fun��o de Usu�rio
// [n][3] - Opera��o (1-Pesquisa; 2-Visualiza��o; 3-Inclusão; 4-Altera��o; 5-Exclusão)
// [n][4] - Acesso relacionado a rotina, se esta posi��o não for informada nenhum acesso ser� validado
//----------------------------------------------------------------------------------------------------------

Begin Sequence
   
   Aadd(aRotina,{"Clientes x Tipos Transportes" ,"U_AOMS131"     ,MODEL_OPERATION_UPDATE,0})
   Aadd(aRotina,{"WF Lib.Clientes"              ,"U_MOMS041"     ,MODEL_OPERATION_VIEW  ,0})
   Aadd(aRotina,{"Listagem Cond.Pagto"          ,"U_ROMS072"     ,MODEL_OPERATION_VIEW  ,0})
   Aadd(aRotina,{"Legenda"                      ,"U_CRM980LEG()" ,MODEL_OPERATION_VIEW  ,0})

End Sequence

Return( aRotina )

/*
===============================================================================================================================
Programa----------: CRM980LEG()
Autor-------------: Julio de Paula Paz
Data--------------: 23/12/2021
===============================================================================================================================
Descri��o---------: Fun��o utilizada para exibir a legenda.
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
*/
User Function CRM980LEG()
aLegenda :=	{	{"BR_VERDE"		, "Ativo"	},;
					{"BR_VERMELHO"	, "Inativo"	},;
				   {"BR_CINZA"	   , "Bloq. Valida��o Desc Contratual"	} }

BrwLegenda("Status Cadastro de Clientes.","Legenda",aLegenda)

Return Nil 


